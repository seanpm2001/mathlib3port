/-
Copyright (c) 2022 Martin Zinkevich. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Martin Zinkevich

! This file was ported from Lean 3 source module measure_theory.measure.sub
! leanprover-community/mathlib commit a2706b55e8d7f7e9b1f93143f0b88f2e34a11eea
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.MeasureSpace

/-!
# Subtraction of measures

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `μ - ν` to be the least measure `τ` such that `μ ≤ τ + ν`.
It is the equivalent of `(μ - ν) ⊔ 0` if `μ` and `ν` were signed measures.
Compare with `ennreal.has_sub`.
Specifically, note that if you have `α = {1,2}`, and  `μ {1} = 2`, `μ {2} = 0`, and
`ν {2} = 2`, `ν {1} = 0`, then `(μ - ν) {1, 2} = 2`. However, if `μ ≤ ν`, and
`ν univ ≠ ∞`, then `(μ - ν) + ν = μ`.
-/


open Set

namespace MeasureTheory

namespace Measure

#print MeasureTheory.Measure.instSub /-
/-- The measure `μ - ν` is defined to be the least measure `τ` such that `μ ≤ τ + ν`.
It is the equivalent of `(μ - ν) ⊔ 0` if `μ` and `ν` were signed measures.
Compare with `ennreal.has_sub`.
Specifically, note that if you have `α = {1,2}`, and  `μ {1} = 2`, `μ {2} = 0`, and
`ν {2} = 2`, `ν {1} = 0`, then `(μ - ν) {1, 2} = 2`. However, if `μ ≤ ν`, and
`ν univ ≠ ∞`, then `(μ - ν) + ν = μ`. -/
noncomputable instance instSub {α : Type _} [MeasurableSpace α] : Sub (Measure α) :=
  ⟨fun μ ν => sInf {τ | μ ≤ τ + ν}⟩
#align measure_theory.measure.has_sub MeasureTheory.Measure.instSub
-/

variable {α : Type _} {m : MeasurableSpace α} {μ ν : Measure α} {s : Set α}

#print MeasureTheory.Measure.sub_def /-
theorem sub_def : μ - ν = sInf {d | μ ≤ d + ν} :=
  rfl
#align measure_theory.measure.sub_def MeasureTheory.Measure.sub_def
-/

#print MeasureTheory.Measure.sub_le_of_le_add /-
theorem sub_le_of_le_add {d} (h : μ ≤ d + ν) : μ - ν ≤ d :=
  sInf_le h
#align measure_theory.measure.sub_le_of_le_add MeasureTheory.Measure.sub_le_of_le_add
-/

#print MeasureTheory.Measure.sub_eq_zero_of_le /-
theorem sub_eq_zero_of_le (h : μ ≤ ν) : μ - ν = 0 :=
  nonpos_iff_eq_zero'.1 <| sub_le_of_le_add <| by rwa [zero_add]
#align measure_theory.measure.sub_eq_zero_of_le MeasureTheory.Measure.sub_eq_zero_of_le
-/

#print MeasureTheory.Measure.sub_le /-
theorem sub_le : μ - ν ≤ μ :=
  sub_le_of_le_add <| Measure.le_add_right le_rfl
#align measure_theory.measure.sub_le MeasureTheory.Measure.sub_le
-/

#print MeasureTheory.Measure.sub_top /-
@[simp]
theorem sub_top : μ - ⊤ = 0 :=
  sub_eq_zero_of_le le_top
#align measure_theory.measure.sub_top MeasureTheory.Measure.sub_top
-/

#print MeasureTheory.Measure.zero_sub /-
@[simp]
theorem zero_sub : 0 - μ = 0 :=
  sub_eq_zero_of_le μ.zero_le
#align measure_theory.measure.zero_sub MeasureTheory.Measure.zero_sub
-/

#print MeasureTheory.Measure.sub_self /-
@[simp]
theorem sub_self : μ - μ = 0 :=
  sub_eq_zero_of_le le_rfl
#align measure_theory.measure.sub_self MeasureTheory.Measure.sub_self
-/

#print MeasureTheory.Measure.sub_apply /-
/-- This application lemma only works in special circumstances. Given knowledge of
when `μ ≤ ν` and `ν ≤ μ`, a more general application lemma can be written. -/
theorem sub_apply [IsFiniteMeasure ν] (h₁ : MeasurableSet s) (h₂ : ν ≤ μ) : (μ - ν) s = μ s - ν s :=
  by
  -- We begin by defining `measure_sub`, which will be equal to `(μ - ν)`.
  let measure_sub : Measure α :=
    @MeasureTheory.Measure.ofMeasurable α _
      (fun (t : Set α) (h_t_measurable_set : MeasurableSet t) => μ t - ν t) (by simp)
      (by
        intro g h_meas h_disj; simp only; rw [ENNReal.tsum_sub]
        repeat' rw [← MeasureTheory.measure_iUnion h_disj h_meas]
        exacts [MeasureTheory.measure_ne_top _ _, fun i => h₂ _ (h_meas _)])
  -- Now, we demonstrate `μ - ν = measure_sub`, and apply it.
  · have h_measure_sub_add : ν + measure_sub = μ :=
      by
      ext t h_t_measurable_set
      simp only [Pi.add_apply, coe_add]
      rw [MeasureTheory.Measure.ofMeasurable_apply _ h_t_measurable_set, add_comm,
        tsub_add_cancel_of_le (h₂ t h_t_measurable_set)]
    have h_measure_sub_eq : μ - ν = measure_sub :=
      by
      rw [MeasureTheory.Measure.sub_def]; apply le_antisymm
      · apply @sInf_le (Measure α) measure.complete_semilattice_Inf
        simp [le_refl, add_comm, h_measure_sub_add]
      apply @le_sInf (Measure α) measure.complete_semilattice_Inf
      intro d h_d; rw [← h_measure_sub_add, mem_set_of_eq, add_comm d] at h_d 
      apply measure.le_of_add_le_add_left h_d
    rw [h_measure_sub_eq]
    apply measure.of_measurable_apply _ h₁
#align measure_theory.measure.sub_apply MeasureTheory.Measure.sub_apply
-/

#print MeasureTheory.Measure.sub_add_cancel_of_le /-
theorem sub_add_cancel_of_le [IsFiniteMeasure ν] (h₁ : ν ≤ μ) : μ - ν + ν = μ :=
  by
  ext s h_s_meas
  rw [add_apply, sub_apply h_s_meas h₁, tsub_add_cancel_of_le (h₁ s h_s_meas)]
#align measure_theory.measure.sub_add_cancel_of_le MeasureTheory.Measure.sub_add_cancel_of_le
-/

#print MeasureTheory.Measure.restrict_sub_eq_restrict_sub_restrict /-
theorem restrict_sub_eq_restrict_sub_restrict (h_meas_s : MeasurableSet s) :
    (μ - ν).restrict s = μ.restrict s - ν.restrict s :=
  by
  repeat' rw [sub_def]
  have h_nonempty : {d | μ ≤ d + ν}.Nonempty := ⟨μ, measure.le_add_right le_rfl⟩
  rw [restrict_Inf_eq_Inf_restrict h_nonempty h_meas_s]
  apply le_antisymm
  · refine' sInf_le_sInf_of_forall_exists_le _
    intro ν' h_ν'_in; rw [mem_set_of_eq] at h_ν'_in 
    refine' ⟨ν'.restrict s, _, restrict_le_self⟩
    refine' ⟨ν' + (⊤ : Measure α).restrict (sᶜ), _, _⟩
    · rw [mem_set_of_eq, add_right_comm, measure.le_iff]
      intro t h_meas_t
      repeat' rw [← measure_inter_add_diff t h_meas_s]
      refine' add_le_add _ _
      · rw [add_apply, add_apply]
        apply le_add_right _
        rw [← restrict_eq_self μ (inter_subset_right _ _), ←
          restrict_eq_self ν (inter_subset_right _ _)]
        apply h_ν'_in _ (h_meas_t.inter h_meas_s)
      · rw [add_apply, restrict_apply (h_meas_t.diff h_meas_s), diff_eq, inter_assoc, inter_self, ←
          add_apply]
        have h_mu_le_add_top : μ ≤ ν' + ν + ⊤ := by simp only [add_top, le_top]
        exact measure.le_iff'.1 h_mu_le_add_top _
    · ext1 t h_meas_t
      simp [restrict_apply h_meas_t, restrict_apply (h_meas_t.inter h_meas_s), inter_assoc]
  · refine' sInf_le_sInf_of_forall_exists_le _
    refine' ball_image_iff.2 fun t h_t_in => ⟨t.restrict s, _, le_rfl⟩
    rw [Set.mem_setOf_eq, ← restrict_add]
    exact restrict_mono subset.rfl h_t_in
#align measure_theory.measure.restrict_sub_eq_restrict_sub_restrict MeasureTheory.Measure.restrict_sub_eq_restrict_sub_restrict
-/

#print MeasureTheory.Measure.sub_apply_eq_zero_of_restrict_le_restrict /-
theorem sub_apply_eq_zero_of_restrict_le_restrict (h_le : μ.restrict s ≤ ν.restrict s)
    (h_meas_s : MeasurableSet s) : (μ - ν) s = 0 := by
  rw [← restrict_apply_self, restrict_sub_eq_restrict_sub_restrict, sub_eq_zero_of_le] <;> simp [*]
#align measure_theory.measure.sub_apply_eq_zero_of_restrict_le_restrict MeasureTheory.Measure.sub_apply_eq_zero_of_restrict_le_restrict
-/

#print MeasureTheory.Measure.isFiniteMeasure_sub /-
instance isFiniteMeasure_sub [IsFiniteMeasure μ] : IsFiniteMeasure (μ - ν) :=
  isFiniteMeasure_of_le μ sub_le
#align measure_theory.measure.is_finite_measure_sub MeasureTheory.Measure.isFiniteMeasure_sub
-/

end Measure

end MeasureTheory

