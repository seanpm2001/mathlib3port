/-
Copyright (c) 2020 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn

! This file was ported from Lean 3 source module measure_theory.constructions.prod.integral
! leanprover-community/mathlib commit c20927220ef87bb4962ba08bf6da2ce3cf50a6dd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Constructions.Prod.Basic
import Mathbin.MeasureTheory.Integral.SetIntegral

/-!
# Integration with respect to the product measure

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove Fubini's theorem.

## Main results

* `measure_theory.integrable_prod_iff` states that a binary function is integrable iff both
  * `y ↦ f (x, y)` is integrable for almost every `x`, and
  * the function `x ↦ ∫ ‖f (x, y)‖ dy` is integrable.
* `measure_theory.integral_prod`: Fubini's theorem. It states that for a integrable function
  `α × β → E` (where `E` is a second countable Banach space) we have
  `∫ z, f z ∂(μ.prod ν) = ∫ x, ∫ y, f (x, y) ∂ν ∂μ`. This theorem has the same variants as
  Tonelli's theorem (see `measure_theory.lintegral_prod`). The lemma
  `measure_theory.integrable.integral_prod_right` states that the inner integral of the right-hand
  side is integrable.

## Tags

product measure, Fubini's theorem, Fubini-Tonelli theorem
-/


noncomputable section

open scoped Classical Topology ENNReal MeasureTheory

open Set Function Real ENNReal

open MeasureTheory MeasurableSpace MeasureTheory.Measure

open TopologicalSpace

open Filter hiding prod_eq map

variable {α α' β β' γ E : Type _}

variable [MeasurableSpace α] [MeasurableSpace α'] [MeasurableSpace β] [MeasurableSpace β']

variable [MeasurableSpace γ]

variable {μ μ' : Measure α} {ν ν' : Measure β} {τ : Measure γ}

variable [NormedAddCommGroup E]

/-! ### Measurability

Before we define the product measure, we can talk about the measurability of operations on binary
functions. We show that if `f` is a binary measurable function, then the function that integrates
along one of the variables (using either the Lebesgue or Bochner integral) is measurable.
-/


#print measurableSet_integrable /-
theorem measurableSet_integrable [SigmaFinite ν] ⦃f : α → β → E⦄
    (hf : StronglyMeasurable (uncurry f)) : MeasurableSet {x | Integrable (f x) ν} :=
  by
  simp_rw [integrable, hf.of_uncurry_left.ae_strongly_measurable, true_and_iff]
  exact measurableSet_lt (Measurable.lintegral_prod_right hf.ennnorm) measurable_const
#align measurable_set_integrable measurableSet_integrable
-/

section

variable [NormedSpace ℝ E] [CompleteSpace E]

#print MeasureTheory.StronglyMeasurable.integral_prod_right /-
/-- The Bochner integral is measurable. This shows that the integrand of (the right-hand-side of)
  Fubini's theorem is measurable.
  This version has `f` in curried form. -/
theorem MeasureTheory.StronglyMeasurable.integral_prod_right [SigmaFinite ν] ⦃f : α → β → E⦄
    (hf : StronglyMeasurable (uncurry f)) : StronglyMeasurable fun x => ∫ y, f x y ∂ν :=
  by
  borelize E
  haveI : separable_space (range (uncurry f) ∪ {0} : Set E) :=
    hf.separable_space_range_union_singleton
  let s : ℕ → simple_func (α × β) E :=
    simple_func.approx_on _ hf.measurable (range (uncurry f) ∪ {0}) 0 (by simp)
  let s' : ℕ → α → simple_func β E := fun n x => (s n).comp (Prod.mk x) measurable_prod_mk_left
  let f' : ℕ → α → E := fun n => {x | integrable (f x) ν}.indicator fun x => (s' n x).integral ν
  have hf' : ∀ n, strongly_measurable (f' n) :=
    by
    intro n; refine' strongly_measurable.indicator _ (measurableSet_integrable hf)
    have : ∀ x, ((s' n x).range.filterₓ fun x => x ≠ 0) ⊆ (s n).range :=
      by
      intro x; refine' Finset.Subset.trans (Finset.filter_subset _ _) _; intro y
      simp_rw [simple_func.mem_range]; rintro ⟨z, rfl⟩; exact ⟨(x, z), rfl⟩
    simp only [simple_func.integral_eq_sum_of_subset (this _)]
    refine' Finset.stronglyMeasurable_sum _ fun x _ => _
    refine' (Measurable.ennreal_toReal _).StronglyMeasurable.smul_const _
    simp (config := { singlePass := true }) only [simple_func.coe_comp, preimage_comp]
    apply measurable_measure_prod_mk_left
    exact (s n).measurableSet_fiber x
  have h2f' : tendsto f' at_top (𝓝 fun x : α => ∫ y : β, f x y ∂ν) :=
    by
    rw [tendsto_pi_nhds]; intro x
    by_cases hfx : integrable (f x) ν
    · have : ∀ n, integrable (s' n x) ν := by
        intro n; apply (hfx.norm.add hfx.norm).mono' (s' n x).AEStronglyMeasurable
        apply eventually_of_forall; intro y
        simp_rw [s', simple_func.coe_comp]; exact simple_func.norm_approx_on_zero_le _ _ (x, y) n
      simp only [f', hfx, simple_func.integral_eq_integral _ (this _), indicator_of_mem,
        mem_set_of_eq]
      refine'
        tendsto_integral_of_dominated_convergence (fun y => ‖f x y‖ + ‖f x y‖)
          (fun n => (s' n x).AEStronglyMeasurable) (hfx.norm.add hfx.norm) _ _
      · exact fun n => eventually_of_forall fun y => simple_func.norm_approx_on_zero_le _ _ (x, y) n
      · refine' eventually_of_forall fun y => simple_func.tendsto_approx_on _ _ _
        apply subset_closure
        simp [-uncurry_apply_pair]
    · simp [f', hfx, integral_undef]
  exact stronglyMeasurable_of_tendsto _ hf' h2f'
#align measure_theory.strongly_measurable.integral_prod_right MeasureTheory.StronglyMeasurable.integral_prod_right
-/

#print MeasureTheory.StronglyMeasurable.integral_prod_right' /-
/-- The Bochner integral is measurable. This shows that the integrand of (the right-hand-side of)
  Fubini's theorem is measurable. -/
theorem MeasureTheory.StronglyMeasurable.integral_prod_right' [SigmaFinite ν] ⦃f : α × β → E⦄
    (hf : StronglyMeasurable f) : StronglyMeasurable fun x => ∫ y, f (x, y) ∂ν := by
  rw [← uncurry_curry f] at hf ; exact hf.integral_prod_right
#align measure_theory.strongly_measurable.integral_prod_right' MeasureTheory.StronglyMeasurable.integral_prod_right'
-/

#print MeasureTheory.StronglyMeasurable.integral_prod_left /-
/-- The Bochner integral is measurable. This shows that the integrand of (the right-hand-side of)
  the symmetric version of Fubini's theorem is measurable.
  This version has `f` in curried form. -/
theorem MeasureTheory.StronglyMeasurable.integral_prod_left [SigmaFinite μ] ⦃f : α → β → E⦄
    (hf : StronglyMeasurable (uncurry f)) : StronglyMeasurable fun y => ∫ x, f x y ∂μ :=
  (hf.comp_measurable measurable_swap).integral_prod_right'
#align measure_theory.strongly_measurable.integral_prod_left MeasureTheory.StronglyMeasurable.integral_prod_left
-/

#print MeasureTheory.StronglyMeasurable.integral_prod_left' /-
/-- The Bochner integral is measurable. This shows that the integrand of (the right-hand-side of)
  the symmetric version of Fubini's theorem is measurable. -/
theorem MeasureTheory.StronglyMeasurable.integral_prod_left' [SigmaFinite μ] ⦃f : α × β → E⦄
    (hf : StronglyMeasurable f) : StronglyMeasurable fun y => ∫ x, f (x, y) ∂μ :=
  (hf.comp_measurable measurable_swap).integral_prod_right'
#align measure_theory.strongly_measurable.integral_prod_left' MeasureTheory.StronglyMeasurable.integral_prod_left'
-/

end

/-! ### The product measure -/


namespace MeasureTheory

namespace Measure

variable [SigmaFinite ν]

#print MeasureTheory.Measure.integrable_measure_prod_mk_left /-
theorem integrable_measure_prod_mk_left {s : Set (α × β)} (hs : MeasurableSet s)
    (h2s : (μ.Prod ν) s ≠ ∞) : Integrable (fun x => (ν (Prod.mk x ⁻¹' s)).toReal) μ :=
  by
  refine' ⟨(measurable_measure_prod_mk_left hs).ennreal_toReal.AEMeasurable.AEStronglyMeasurable, _⟩
  simp_rw [has_finite_integral, ennnorm_eq_of_real to_real_nonneg]
  convert h2s.lt_top using 1; simp_rw [prod_apply hs]; apply lintegral_congr_ae
  refine' (ae_measure_lt_top hs h2s).mp _; apply eventually_of_forall; intro x hx
  rw [lt_top_iff_ne_top] at hx ; simp [of_real_to_real, hx]
#align measure_theory.measure.integrable_measure_prod_mk_left MeasureTheory.Measure.integrable_measure_prod_mk_left
-/

end Measure

open Measure

end MeasureTheory

open MeasureTheory.Measure

section

#print MeasureTheory.AEStronglyMeasurable.prod_swap /-
theorem MeasureTheory.AEStronglyMeasurable.prod_swap {γ : Type _} [TopologicalSpace γ]
    [SigmaFinite μ] [SigmaFinite ν] {f : β × α → γ} (hf : AEStronglyMeasurable f (ν.Prod μ)) :
    AEStronglyMeasurable (fun z : α × β => f z.symm) (μ.Prod ν) := by rw [← prod_swap] at hf ;
  exact hf.comp_measurable measurable_swap
#align measure_theory.ae_strongly_measurable.prod_swap MeasureTheory.AEStronglyMeasurable.prod_swap
-/

#print MeasureTheory.AEStronglyMeasurable.fst /-
theorem MeasureTheory.AEStronglyMeasurable.fst {γ} [TopologicalSpace γ] [SigmaFinite ν] {f : α → γ}
    (hf : AEStronglyMeasurable f μ) : AEStronglyMeasurable (fun z : α × β => f z.1) (μ.Prod ν) :=
  hf.comp_quasiMeasurePreserving quasiMeasurePreserving_fst
#align measure_theory.ae_strongly_measurable.fst MeasureTheory.AEStronglyMeasurable.fst
-/

#print MeasureTheory.AEStronglyMeasurable.snd /-
theorem MeasureTheory.AEStronglyMeasurable.snd {γ} [TopologicalSpace γ] [SigmaFinite ν] {f : β → γ}
    (hf : AEStronglyMeasurable f ν) : AEStronglyMeasurable (fun z : α × β => f z.2) (μ.Prod ν) :=
  hf.comp_quasiMeasurePreserving quasiMeasurePreserving_snd
#align measure_theory.ae_strongly_measurable.snd MeasureTheory.AEStronglyMeasurable.snd
-/

#print MeasureTheory.AEStronglyMeasurable.integral_prod_right' /-
/-- The Bochner integral is a.e.-measurable.
  This shows that the integrand of (the right-hand-side of) Fubini's theorem is a.e.-measurable. -/
theorem MeasureTheory.AEStronglyMeasurable.integral_prod_right' [SigmaFinite ν] [NormedSpace ℝ E]
    [CompleteSpace E] ⦃f : α × β → E⦄ (hf : AEStronglyMeasurable f (μ.Prod ν)) :
    AEStronglyMeasurable (fun x => ∫ y, f (x, y) ∂ν) μ :=
  ⟨fun x => ∫ y, hf.mk f (x, y) ∂ν, hf.stronglyMeasurable_mk.integral_prod_right', by
    filter_upwards [ae_ae_of_ae_prod hf.ae_eq_mk] with _ hx using integral_congr_ae hx⟩
#align measure_theory.ae_strongly_measurable.integral_prod_right' MeasureTheory.AEStronglyMeasurable.integral_prod_right'
-/

#print MeasureTheory.AEStronglyMeasurable.prod_mk_left /-
theorem MeasureTheory.AEStronglyMeasurable.prod_mk_left {γ : Type _} [SigmaFinite ν]
    [TopologicalSpace γ] {f : α × β → γ} (hf : AEStronglyMeasurable f (μ.Prod ν)) :
    ∀ᵐ x ∂μ, AEStronglyMeasurable (fun y => f (x, y)) ν :=
  by
  filter_upwards [ae_ae_of_ae_prod hf.ae_eq_mk] with x hx
  exact
    ⟨fun y => hf.mk f (x, y), hf.strongly_measurable_mk.comp_measurable measurable_prod_mk_left, hx⟩
#align measure_theory.ae_strongly_measurable.prod_mk_left MeasureTheory.AEStronglyMeasurable.prod_mk_left
-/

end

namespace MeasureTheory

variable [SigmaFinite ν]

/-! ### Integrability on a product -/


section

#print MeasureTheory.Integrable.swap /-
theorem Integrable.swap [SigmaFinite μ] ⦃f : α × β → E⦄ (hf : Integrable f (μ.Prod ν)) :
    Integrable (f ∘ Prod.swap) (ν.Prod μ) :=
  ⟨hf.AEStronglyMeasurable.prod_swap,
    (lintegral_prod_swap _ hf.AEStronglyMeasurable.ennnorm : _).le.trans_lt hf.HasFiniteIntegral⟩
#align measure_theory.integrable.swap MeasureTheory.Integrable.swap
-/

#print MeasureTheory.integrable_swap_iff /-
theorem integrable_swap_iff [SigmaFinite μ] ⦃f : α × β → E⦄ :
    Integrable (f ∘ Prod.swap) (ν.Prod μ) ↔ Integrable f (μ.Prod ν) :=
  ⟨fun hf => by convert hf.swap; ext ⟨x, y⟩; rfl, fun hf => hf.symm⟩
#align measure_theory.integrable_swap_iff MeasureTheory.integrable_swap_iff
-/

#print MeasureTheory.hasFiniteIntegral_prod_iff /-
theorem hasFiniteIntegral_prod_iff ⦃f : α × β → E⦄ (h1f : StronglyMeasurable f) :
    HasFiniteIntegral f (μ.Prod ν) ↔
      (∀ᵐ x ∂μ, HasFiniteIntegral (fun y => f (x, y)) ν) ∧
        HasFiniteIntegral (fun x => ∫ y, ‖f (x, y)‖ ∂ν) μ :=
  by
  simp only [has_finite_integral, lintegral_prod_of_measurable _ h1f.ennnorm]
  have : ∀ x, ∀ᵐ y ∂ν, 0 ≤ ‖f (x, y)‖ := fun x => eventually_of_forall fun y => norm_nonneg _
  simp_rw [integral_eq_lintegral_of_nonneg_ae (this _)
      (h1f.norm.comp_measurable measurable_prod_mk_left).AEStronglyMeasurable,
    ennnorm_eq_of_real to_real_nonneg, ofReal_norm_eq_coe_nnnorm]
  -- this fact is probably too specialized to be its own lemma
  have : ∀ {p q r : Prop} (h1 : r → p), (r ↔ p ∧ q) ↔ p → (r ↔ q) := fun p q r h1 => by
    rw [← and_congr_right_iff, and_iff_right_of_imp h1]
  rw [this]
  · intro h2f; rw [lintegral_congr_ae]
    refine' h2f.mp _; apply eventually_of_forall; intro x hx; dsimp only
    rw [of_real_to_real]; rw [← lt_top_iff_ne_top]; exact hx
  · intro h2f; refine' ae_lt_top _ h2f.ne; exact h1f.ennnorm.lintegral_prod_right'
#align measure_theory.has_finite_integral_prod_iff MeasureTheory.hasFiniteIntegral_prod_iff
-/

#print MeasureTheory.hasFiniteIntegral_prod_iff' /-
theorem hasFiniteIntegral_prod_iff' ⦃f : α × β → E⦄ (h1f : AEStronglyMeasurable f (μ.Prod ν)) :
    HasFiniteIntegral f (μ.Prod ν) ↔
      (∀ᵐ x ∂μ, HasFiniteIntegral (fun y => f (x, y)) ν) ∧
        HasFiniteIntegral (fun x => ∫ y, ‖f (x, y)‖ ∂ν) μ :=
  by
  rw [has_finite_integral_congr h1f.ae_eq_mk,
    has_finite_integral_prod_iff h1f.strongly_measurable_mk]
  apply and_congr
  · apply eventually_congr
    filter_upwards [ae_ae_of_ae_prod h1f.ae_eq_mk.symm]
    intro x hx
    exact has_finite_integral_congr hx
  · apply has_finite_integral_congr
    filter_upwards [ae_ae_of_ae_prod h1f.ae_eq_mk.symm] with _ hx using
      integral_congr_ae (eventually_eq.fun_comp hx _)
  · infer_instance
#align measure_theory.has_finite_integral_prod_iff' MeasureTheory.hasFiniteIntegral_prod_iff'
-/

#print MeasureTheory.integrable_prod_iff /-
/-- A binary function is integrable if the function `y ↦ f (x, y)` is integrable for almost every
  `x` and the function `x ↦ ∫ ‖f (x, y)‖ dy` is integrable. -/
theorem integrable_prod_iff ⦃f : α × β → E⦄ (h1f : AEStronglyMeasurable f (μ.Prod ν)) :
    Integrable f (μ.Prod ν) ↔
      (∀ᵐ x ∂μ, Integrable (fun y => f (x, y)) ν) ∧ Integrable (fun x => ∫ y, ‖f (x, y)‖ ∂ν) μ :=
  by
  simp [integrable, h1f, has_finite_integral_prod_iff', h1f.norm.integral_prod_right',
    h1f.prod_mk_left]
#align measure_theory.integrable_prod_iff MeasureTheory.integrable_prod_iff
-/

#print MeasureTheory.integrable_prod_iff' /-
/-- A binary function is integrable if the function `x ↦ f (x, y)` is integrable for almost every
  `y` and the function `y ↦ ∫ ‖f (x, y)‖ dx` is integrable. -/
theorem integrable_prod_iff' [SigmaFinite μ] ⦃f : α × β → E⦄
    (h1f : AEStronglyMeasurable f (μ.Prod ν)) :
    Integrable f (μ.Prod ν) ↔
      (∀ᵐ y ∂ν, Integrable (fun x => f (x, y)) μ) ∧ Integrable (fun y => ∫ x, ‖f (x, y)‖ ∂μ) ν :=
  by convert integrable_prod_iff h1f.prod_swap using 1; rw [integrable_swap_iff]
#align measure_theory.integrable_prod_iff' MeasureTheory.integrable_prod_iff'
-/

#print MeasureTheory.Integrable.prod_left_ae /-
theorem Integrable.prod_left_ae [SigmaFinite μ] ⦃f : α × β → E⦄ (hf : Integrable f (μ.Prod ν)) :
    ∀ᵐ y ∂ν, Integrable (fun x => f (x, y)) μ :=
  ((integrable_prod_iff' hf.AEStronglyMeasurable).mp hf).1
#align measure_theory.integrable.prod_left_ae MeasureTheory.Integrable.prod_left_ae
-/

#print MeasureTheory.Integrable.prod_right_ae /-
theorem Integrable.prod_right_ae [SigmaFinite μ] ⦃f : α × β → E⦄ (hf : Integrable f (μ.Prod ν)) :
    ∀ᵐ x ∂μ, Integrable (fun y => f (x, y)) ν :=
  hf.symm.prod_left_ae
#align measure_theory.integrable.prod_right_ae MeasureTheory.Integrable.prod_right_ae
-/

#print MeasureTheory.Integrable.integral_norm_prod_left /-
theorem Integrable.integral_norm_prod_left ⦃f : α × β → E⦄ (hf : Integrable f (μ.Prod ν)) :
    Integrable (fun x => ∫ y, ‖f (x, y)‖ ∂ν) μ :=
  ((integrable_prod_iff hf.AEStronglyMeasurable).mp hf).2
#align measure_theory.integrable.integral_norm_prod_left MeasureTheory.Integrable.integral_norm_prod_left
-/

#print MeasureTheory.Integrable.integral_norm_prod_right /-
theorem Integrable.integral_norm_prod_right [SigmaFinite μ] ⦃f : α × β → E⦄
    (hf : Integrable f (μ.Prod ν)) : Integrable (fun y => ∫ x, ‖f (x, y)‖ ∂μ) ν :=
  hf.symm.integral_norm_prod_left
#align measure_theory.integrable.integral_norm_prod_right MeasureTheory.Integrable.integral_norm_prod_right
-/

#print MeasureTheory.integrable_prod_mul /-
theorem integrable_prod_mul {L : Type _} [IsROrC L] {f : α → L} {g : β → L} (hf : Integrable f μ)
    (hg : Integrable g ν) : Integrable (fun z : α × β => f z.1 * g z.2) (μ.Prod ν) :=
  by
  refine' (integrable_prod_iff _).2 ⟨_, _⟩
  · exact hf.1.fst.mul hg.1.snd
  · exact eventually_of_forall fun x => hg.const_mul (f x)
  · simpa only [norm_mul, integral_mul_left] using hf.norm.mul_const _
#align measure_theory.integrable_prod_mul MeasureTheory.integrable_prod_mul
-/

end

variable [NormedSpace ℝ E] [CompleteSpace E]

#print MeasureTheory.Integrable.integral_prod_left /-
theorem Integrable.integral_prod_left ⦃f : α × β → E⦄ (hf : Integrable f (μ.Prod ν)) :
    Integrable (fun x => ∫ y, f (x, y) ∂ν) μ :=
  Integrable.mono hf.integral_norm_prod_left hf.AEStronglyMeasurable.integral_prod_right' <|
    eventually_of_forall fun x =>
      (norm_integral_le_integral_norm _).trans_eq <|
        (norm_of_nonneg <|
            integral_nonneg_of_ae <|
              eventually_of_forall fun y => (norm_nonneg (f (x, y)) : _)).symm
#align measure_theory.integrable.integral_prod_left MeasureTheory.Integrable.integral_prod_left
-/

#print MeasureTheory.Integrable.integral_prod_right /-
theorem Integrable.integral_prod_right [SigmaFinite μ] ⦃f : α × β → E⦄
    (hf : Integrable f (μ.Prod ν)) : Integrable (fun y => ∫ x, f (x, y) ∂μ) ν :=
  hf.symm.integral_prod_left
#align measure_theory.integrable.integral_prod_right MeasureTheory.Integrable.integral_prod_right
-/

/-! ### The Bochner integral on a product -/


variable [SigmaFinite μ]

#print MeasureTheory.integral_prod_swap /-
theorem integral_prod_swap (f : α × β → E) (hf : AEStronglyMeasurable f (μ.Prod ν)) :
    ∫ z, f z.symm ∂ν.Prod μ = ∫ z, f z ∂μ.Prod ν :=
  by
  rw [← prod_swap] at hf 
  rw [← integral_map measurable_swap.ae_measurable hf, prod_swap]
#align measure_theory.integral_prod_swap MeasureTheory.integral_prod_swap
-/

variable {E' : Type _} [NormedAddCommGroup E'] [CompleteSpace E'] [NormedSpace ℝ E']

/-! Some rules about the sum/difference of double integrals. They follow from `integral_add`, but
  we separate them out as separate lemmas, because they involve quite some steps. -/


#print MeasureTheory.integral_fn_integral_add /-
/-- Integrals commute with addition inside another integral. `F` can be any function. -/
theorem integral_fn_integral_add ⦃f g : α × β → E⦄ (F : E → E') (hf : Integrable f (μ.Prod ν))
    (hg : Integrable g (μ.Prod ν)) :
    ∫ x, F (∫ y, f (x, y) + g (x, y) ∂ν) ∂μ = ∫ x, F (∫ y, f (x, y) ∂ν + ∫ y, g (x, y) ∂ν) ∂μ :=
  by
  refine' integral_congr_ae _
  filter_upwards [hf.prod_right_ae, hg.prod_right_ae] with _ h2f h2g
  simp [integral_add h2f h2g]
#align measure_theory.integral_fn_integral_add MeasureTheory.integral_fn_integral_add
-/

#print MeasureTheory.integral_fn_integral_sub /-
/-- Integrals commute with subtraction inside another integral.
  `F` can be any measurable function. -/
theorem integral_fn_integral_sub ⦃f g : α × β → E⦄ (F : E → E') (hf : Integrable f (μ.Prod ν))
    (hg : Integrable g (μ.Prod ν)) :
    ∫ x, F (∫ y, f (x, y) - g (x, y) ∂ν) ∂μ = ∫ x, F (∫ y, f (x, y) ∂ν - ∫ y, g (x, y) ∂ν) ∂μ :=
  by
  refine' integral_congr_ae _
  filter_upwards [hf.prod_right_ae, hg.prod_right_ae] with _ h2f h2g
  simp [integral_sub h2f h2g]
#align measure_theory.integral_fn_integral_sub MeasureTheory.integral_fn_integral_sub
-/

#print MeasureTheory.lintegral_fn_integral_sub /-
/-- Integrals commute with subtraction inside a lower Lebesgue integral.
  `F` can be any function. -/
theorem lintegral_fn_integral_sub ⦃f g : α × β → E⦄ (F : E → ℝ≥0∞) (hf : Integrable f (μ.Prod ν))
    (hg : Integrable g (μ.Prod ν)) :
    ∫⁻ x, F (∫ y, f (x, y) - g (x, y) ∂ν) ∂μ = ∫⁻ x, F (∫ y, f (x, y) ∂ν - ∫ y, g (x, y) ∂ν) ∂μ :=
  by
  refine' lintegral_congr_ae _
  filter_upwards [hf.prod_right_ae, hg.prod_right_ae] with _ h2f h2g
  simp [integral_sub h2f h2g]
#align measure_theory.lintegral_fn_integral_sub MeasureTheory.lintegral_fn_integral_sub
-/

#print MeasureTheory.integral_integral_add /-
/-- Double integrals commute with addition. -/
theorem integral_integral_add ⦃f g : α × β → E⦄ (hf : Integrable f (μ.Prod ν))
    (hg : Integrable g (μ.Prod ν)) :
    ∫ x, ∫ y, f (x, y) + g (x, y) ∂ν ∂μ = ∫ x, ∫ y, f (x, y) ∂ν ∂μ + ∫ x, ∫ y, g (x, y) ∂ν ∂μ :=
  (integral_fn_integral_add id hf hg).trans <|
    integral_add hf.integral_prod_left hg.integral_prod_left
#align measure_theory.integral_integral_add MeasureTheory.integral_integral_add
-/

#print MeasureTheory.integral_integral_add' /-
/-- Double integrals commute with addition. This is the version with `(f + g) (x, y)`
  (instead of `f (x, y) + g (x, y)`) in the LHS. -/
theorem integral_integral_add' ⦃f g : α × β → E⦄ (hf : Integrable f (μ.Prod ν))
    (hg : Integrable g (μ.Prod ν)) :
    ∫ x, ∫ y, (f + g) (x, y) ∂ν ∂μ = ∫ x, ∫ y, f (x, y) ∂ν ∂μ + ∫ x, ∫ y, g (x, y) ∂ν ∂μ :=
  integral_integral_add hf hg
#align measure_theory.integral_integral_add' MeasureTheory.integral_integral_add'
-/

#print MeasureTheory.integral_integral_sub /-
/-- Double integrals commute with subtraction. -/
theorem integral_integral_sub ⦃f g : α × β → E⦄ (hf : Integrable f (μ.Prod ν))
    (hg : Integrable g (μ.Prod ν)) :
    ∫ x, ∫ y, f (x, y) - g (x, y) ∂ν ∂μ = ∫ x, ∫ y, f (x, y) ∂ν ∂μ - ∫ x, ∫ y, g (x, y) ∂ν ∂μ :=
  (integral_fn_integral_sub id hf hg).trans <|
    integral_sub hf.integral_prod_left hg.integral_prod_left
#align measure_theory.integral_integral_sub MeasureTheory.integral_integral_sub
-/

#print MeasureTheory.integral_integral_sub' /-
/-- Double integrals commute with subtraction. This is the version with `(f - g) (x, y)`
  (instead of `f (x, y) - g (x, y)`) in the LHS. -/
theorem integral_integral_sub' ⦃f g : α × β → E⦄ (hf : Integrable f (μ.Prod ν))
    (hg : Integrable g (μ.Prod ν)) :
    ∫ x, ∫ y, (f - g) (x, y) ∂ν ∂μ = ∫ x, ∫ y, f (x, y) ∂ν ∂μ - ∫ x, ∫ y, g (x, y) ∂ν ∂μ :=
  integral_integral_sub hf hg
#align measure_theory.integral_integral_sub' MeasureTheory.integral_integral_sub'
-/

#print MeasureTheory.continuous_integral_integral /-
/-- The map that sends an L¹-function `f : α × β → E` to `∫∫f` is continuous. -/
theorem continuous_integral_integral :
    Continuous fun f : α × β →₁[μ.Prod ν] E => ∫ x, ∫ y, f (x, y) ∂ν ∂μ :=
  by
  rw [continuous_iff_continuousAt]; intro g
  refine'
    tendsto_integral_of_L1 _ (L1.integrable_coe_fn g).integral_prod_left
      (eventually_of_forall fun h => (L1.integrable_coe_fn h).integral_prod_left) _
  simp_rw [←
    lintegral_fn_integral_sub (fun x => (‖x‖₊ : ℝ≥0∞)) (L1.integrable_coe_fn _)
      (L1.integrable_coe_fn g)]
  refine' tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds _ (fun i => zero_le _) _
  · exact fun i => ∫⁻ x, ∫⁻ y, ‖i (x, y) - g (x, y)‖₊ ∂ν ∂μ
  swap; · exact fun i => lintegral_mono fun x => ennnorm_integral_le_lintegral_ennnorm _
  show
    tendsto (fun i : α × β →₁[μ.prod ν] E => ∫⁻ x, ∫⁻ y : β, ‖i (x, y) - g (x, y)‖₊ ∂ν ∂μ) (𝓝 g)
      (𝓝 0)
  have : ∀ i : α × β →₁[μ.prod ν] E, Measurable fun z => (‖i z - g z‖₊ : ℝ≥0∞) := fun i =>
    ((Lp.strongly_measurable i).sub (Lp.strongly_measurable g)).ennnorm
  simp_rw [← lintegral_prod_of_measurable _ (this _), ← L1.of_real_norm_sub_eq_lintegral, ←
    of_real_zero]
  refine' (continuous_of_real.tendsto 0).comp _
  rw [← tendsto_iff_norm_tendsto_zero]; exact tendsto_id
#align measure_theory.continuous_integral_integral MeasureTheory.continuous_integral_integral
-/

#print MeasureTheory.integral_prod /-
/-- **Fubini's Theorem**: For integrable functions on `α × β`,
  the Bochner integral of `f` is equal to the iterated Bochner integral.
  `integrable_prod_iff` can be useful to show that the function in question in integrable.
  `measure_theory.integrable.integral_prod_right` is useful to show that the inner integral
  of the right-hand side is integrable. -/
theorem integral_prod :
    ∀ (f : α × β → E) (hf : Integrable f (μ.Prod ν)),
      ∫ z, f z ∂μ.Prod ν = ∫ x, ∫ y, f (x, y) ∂ν ∂μ :=
  by
  apply integrable.induction
  · intro c s hs h2s
    simp_rw [integral_indicator hs, ← indicator_comp_right, Function.comp,
      integral_indicator (measurable_prod_mk_left hs), set_integral_const, integral_smul_const,
      integral_to_real (measurable_measure_prod_mk_left hs).AEMeasurable
        (ae_measure_lt_top hs h2s.ne),
      prod_apply hs]
  · intro f g hfg i_f i_g hf hg
    simp_rw [integral_add' i_f i_g, integral_integral_add' i_f i_g, hf, hg]
  · exact isClosed_eq continuous_integral continuous_integral_integral
  · intro f g hfg i_f hf; convert hf using 1
    · exact integral_congr_ae hfg.symm
    · refine' integral_congr_ae _
      refine' (ae_ae_of_ae_prod hfg).mp _
      apply eventually_of_forall; intro x hfgx
      exact integral_congr_ae (ae_eq_symm hfgx)
#align measure_theory.integral_prod MeasureTheory.integral_prod
-/

#print MeasureTheory.integral_prod_symm /-
/-- Symmetric version of **Fubini's Theorem**: For integrable functions on `α × β`,
  the Bochner integral of `f` is equal to the iterated Bochner integral.
  This version has the integrals on the right-hand side in the other order. -/
theorem integral_prod_symm (f : α × β → E) (hf : Integrable f (μ.Prod ν)) :
    ∫ z, f z ∂μ.Prod ν = ∫ y, ∫ x, f (x, y) ∂μ ∂ν := by
  simp_rw [← integral_prod_swap f hf.ae_strongly_measurable]; exact integral_prod _ hf.swap
#align measure_theory.integral_prod_symm MeasureTheory.integral_prod_symm
-/

#print MeasureTheory.integral_integral /-
/-- Reversed version of **Fubini's Theorem**. -/
theorem integral_integral {f : α → β → E} (hf : Integrable (uncurry f) (μ.Prod ν)) :
    ∫ x, ∫ y, f x y ∂ν ∂μ = ∫ z, f z.1 z.2 ∂μ.Prod ν :=
  (integral_prod _ hf).symm
#align measure_theory.integral_integral MeasureTheory.integral_integral
-/

#print MeasureTheory.integral_integral_symm /-
/-- Reversed version of **Fubini's Theorem** (symmetric version). -/
theorem integral_integral_symm {f : α → β → E} (hf : Integrable (uncurry f) (μ.Prod ν)) :
    ∫ x, ∫ y, f x y ∂ν ∂μ = ∫ z, f z.2 z.1 ∂ν.Prod μ :=
  (integral_prod_symm _ hf.symm).symm
#align measure_theory.integral_integral_symm MeasureTheory.integral_integral_symm
-/

#print MeasureTheory.integral_integral_swap /-
/-- Change the order of Bochner integration. -/
theorem integral_integral_swap ⦃f : α → β → E⦄ (hf : Integrable (uncurry f) (μ.Prod ν)) :
    ∫ x, ∫ y, f x y ∂ν ∂μ = ∫ y, ∫ x, f x y ∂μ ∂ν :=
  (integral_integral hf).trans (integral_prod_symm _ hf)
#align measure_theory.integral_integral_swap MeasureTheory.integral_integral_swap
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print MeasureTheory.set_integral_prod /-
/-- **Fubini's Theorem** for set integrals. -/
theorem set_integral_prod (f : α × β → E) {s : Set α} {t : Set β}
    (hf : IntegrableOn f (s ×ˢ t) (μ.Prod ν)) :
    ∫ z in s ×ˢ t, f z ∂μ.Prod ν = ∫ x in s, ∫ y in t, f (x, y) ∂ν ∂μ :=
  by
  simp only [← measure.prod_restrict s t, integrable_on] at hf ⊢
  exact integral_prod f hf
#align measure_theory.set_integral_prod MeasureTheory.set_integral_prod
-/

#print MeasureTheory.integral_prod_mul /-
theorem integral_prod_mul {L : Type _} [IsROrC L] (f : α → L) (g : β → L) :
    ∫ z, f z.1 * g z.2 ∂μ.Prod ν = (∫ x, f x ∂μ) * ∫ y, g y ∂ν :=
  by
  by_cases h : integrable (fun z : α × β => f z.1 * g z.2) (μ.prod ν)
  · rw [integral_prod _ h]
    simp_rw [integral_mul_left, integral_mul_right]
  have H : ¬integrable f μ ∨ ¬integrable g ν :=
    by
    contrapose! h
    exact integrable_prod_mul h.1 h.2
  cases H <;> simp [integral_undef h, integral_undef H]
#align measure_theory.integral_prod_mul MeasureTheory.integral_prod_mul
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print MeasureTheory.set_integral_prod_mul /-
theorem set_integral_prod_mul {L : Type _} [IsROrC L] (f : α → L) (g : β → L) (s : Set α)
    (t : Set β) : ∫ z in s ×ˢ t, f z.1 * g z.2 ∂μ.Prod ν = (∫ x in s, f x ∂μ) * ∫ y in t, g y ∂ν :=
  by simp only [← measure.prod_restrict s t, integrable_on, integral_prod_mul]
#align measure_theory.set_integral_prod_mul MeasureTheory.set_integral_prod_mul
-/

end MeasureTheory

