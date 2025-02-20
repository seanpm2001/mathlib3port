/-
Copyright (c) 2019 Zhouhang Zhou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Zhouhang Zhou

! This file was ported from Lean 3 source module measure_theory.function.l1_space
! leanprover-community/mathlib commit ccdbfb6e5614667af5aa3ab2d50885e0ef44a46f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Function.LpOrder

/-!
# Integrable functions and `L¹` space

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In the first part of this file, the predicate `integrable` is defined and basic properties of
integrable functions are proved.

Such a predicate is already available under the name `mem_ℒp 1`. We give a direct definition which
is easier to use, and show that it is equivalent to `mem_ℒp 1`

In the second part, we establish an API between `integrable` and the space `L¹` of equivalence
classes of integrable functions, already defined as a special case of `L^p` spaces for `p = 1`.

## Notation

* `α →₁[μ] β` is the type of `L¹` space, where `α` is a `measure_space` and `β` is a
  `normed_add_comm_group` with a `second_countable_topology`. `f : α →ₘ β` is a "function" in `L¹`.
  In comments, `[f]` is also used to denote an `L¹` function.

  `₁` can be typed as `\1`.

## Main definitions

* Let `f : α → β` be a function, where `α` is a `measure_space` and `β` a `normed_add_comm_group`.
  Then `has_finite_integral f` means `(∫⁻ a, ‖f a‖₊) < ∞`.

* If `β` is moreover a `measurable_space` then `f` is called `integrable` if
  `f` is `measurable` and `has_finite_integral f` holds.

## Implementation notes

To prove something for an arbitrary integrable function, a useful theorem is
`integrable.induction` in the file `set_integral`.

## Tags

integrable, function space, l1

-/


noncomputable section

open scoped Classical Topology BigOperators ENNReal MeasureTheory NNReal

open Set Filter TopologicalSpace ENNReal Emetric MeasureTheory

variable {α β γ δ : Type _} {m : MeasurableSpace α} {μ ν : Measure α} [MeasurableSpace δ]

variable [NormedAddCommGroup β]

variable [NormedAddCommGroup γ]

namespace MeasureTheory

/-! ### Some results about the Lebesgue integral involving a normed group -/


#print MeasureTheory.lintegral_nnnorm_eq_lintegral_edist /-
theorem lintegral_nnnorm_eq_lintegral_edist (f : α → β) :
    ∫⁻ a, ‖f a‖₊ ∂μ = ∫⁻ a, edist (f a) 0 ∂μ := by simp only [edist_eq_coe_nnnorm]
#align measure_theory.lintegral_nnnorm_eq_lintegral_edist MeasureTheory.lintegral_nnnorm_eq_lintegral_edist
-/

#print MeasureTheory.lintegral_norm_eq_lintegral_edist /-
theorem lintegral_norm_eq_lintegral_edist (f : α → β) :
    ∫⁻ a, ENNReal.ofReal ‖f a‖ ∂μ = ∫⁻ a, edist (f a) 0 ∂μ := by
  simp only [ofReal_norm_eq_coe_nnnorm, edist_eq_coe_nnnorm]
#align measure_theory.lintegral_norm_eq_lintegral_edist MeasureTheory.lintegral_norm_eq_lintegral_edist
-/

#print MeasureTheory.lintegral_edist_triangle /-
theorem lintegral_edist_triangle {f g h : α → β} (hf : AEStronglyMeasurable f μ)
    (hh : AEStronglyMeasurable h μ) :
    ∫⁻ a, edist (f a) (g a) ∂μ ≤ ∫⁻ a, edist (f a) (h a) ∂μ + ∫⁻ a, edist (g a) (h a) ∂μ :=
  by
  rw [← lintegral_add_left' (hf.edist hh)]
  refine' lintegral_mono fun a => _
  apply edist_triangle_right
#align measure_theory.lintegral_edist_triangle MeasureTheory.lintegral_edist_triangle
-/

#print MeasureTheory.lintegral_nnnorm_zero /-
theorem lintegral_nnnorm_zero : ∫⁻ a : α, ‖(0 : β)‖₊ ∂μ = 0 := by simp
#align measure_theory.lintegral_nnnorm_zero MeasureTheory.lintegral_nnnorm_zero
-/

#print MeasureTheory.lintegral_nnnorm_add_left /-
theorem lintegral_nnnorm_add_left {f : α → β} (hf : AEStronglyMeasurable f μ) (g : α → γ) :
    ∫⁻ a, ‖f a‖₊ + ‖g a‖₊ ∂μ = ∫⁻ a, ‖f a‖₊ ∂μ + ∫⁻ a, ‖g a‖₊ ∂μ :=
  lintegral_add_left' hf.ennnorm _
#align measure_theory.lintegral_nnnorm_add_left MeasureTheory.lintegral_nnnorm_add_left
-/

#print MeasureTheory.lintegral_nnnorm_add_right /-
theorem lintegral_nnnorm_add_right (f : α → β) {g : α → γ} (hg : AEStronglyMeasurable g μ) :
    ∫⁻ a, ‖f a‖₊ + ‖g a‖₊ ∂μ = ∫⁻ a, ‖f a‖₊ ∂μ + ∫⁻ a, ‖g a‖₊ ∂μ :=
  lintegral_add_right' _ hg.ennnorm
#align measure_theory.lintegral_nnnorm_add_right MeasureTheory.lintegral_nnnorm_add_right
-/

#print MeasureTheory.lintegral_nnnorm_neg /-
theorem lintegral_nnnorm_neg {f : α → β} : ∫⁻ a, ‖(-f) a‖₊ ∂μ = ∫⁻ a, ‖f a‖₊ ∂μ := by
  simp only [Pi.neg_apply, nnnorm_neg]
#align measure_theory.lintegral_nnnorm_neg MeasureTheory.lintegral_nnnorm_neg
-/

/-! ### The predicate `has_finite_integral` -/


#print MeasureTheory.HasFiniteIntegral /-
/-- `has_finite_integral f μ` means that the integral `∫⁻ a, ‖f a‖ ∂μ` is finite.
  `has_finite_integral f` means `has_finite_integral f volume`. -/
def HasFiniteIntegral {m : MeasurableSpace α} (f : α → β)
    (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) : Prop :=
  ∫⁻ a, ‖f a‖₊ ∂μ < ∞
#align measure_theory.has_finite_integral MeasureTheory.HasFiniteIntegral
-/

#print MeasureTheory.hasFiniteIntegral_iff_norm /-
theorem hasFiniteIntegral_iff_norm (f : α → β) :
    HasFiniteIntegral f μ ↔ ∫⁻ a, ENNReal.ofReal ‖f a‖ ∂μ < ∞ := by
  simp only [has_finite_integral, ofReal_norm_eq_coe_nnnorm]
#align measure_theory.has_finite_integral_iff_norm MeasureTheory.hasFiniteIntegral_iff_norm
-/

#print MeasureTheory.hasFiniteIntegral_iff_edist /-
theorem hasFiniteIntegral_iff_edist (f : α → β) :
    HasFiniteIntegral f μ ↔ ∫⁻ a, edist (f a) 0 ∂μ < ∞ := by
  simp only [has_finite_integral_iff_norm, edist_dist, dist_zero_right]
#align measure_theory.has_finite_integral_iff_edist MeasureTheory.hasFiniteIntegral_iff_edist
-/

#print MeasureTheory.hasFiniteIntegral_iff_ofReal /-
theorem hasFiniteIntegral_iff_ofReal {f : α → ℝ} (h : 0 ≤ᵐ[μ] f) :
    HasFiniteIntegral f μ ↔ ∫⁻ a, ENNReal.ofReal (f a) ∂μ < ∞ := by
  rw [has_finite_integral, lintegral_nnnorm_eq_of_ae_nonneg h]
#align measure_theory.has_finite_integral_iff_of_real MeasureTheory.hasFiniteIntegral_iff_ofReal
-/

#print MeasureTheory.hasFiniteIntegral_iff_ofNNReal /-
theorem hasFiniteIntegral_iff_ofNNReal {f : α → ℝ≥0} :
    HasFiniteIntegral (fun x => (f x : ℝ)) μ ↔ ∫⁻ a, f a ∂μ < ∞ := by
  simp [has_finite_integral_iff_norm]
#align measure_theory.has_finite_integral_iff_of_nnreal MeasureTheory.hasFiniteIntegral_iff_ofNNReal
-/

#print MeasureTheory.HasFiniteIntegral.mono /-
theorem HasFiniteIntegral.mono {f : α → β} {g : α → γ} (hg : HasFiniteIntegral g μ)
    (h : ∀ᵐ a ∂μ, ‖f a‖ ≤ ‖g a‖) : HasFiniteIntegral f μ :=
  by
  simp only [has_finite_integral_iff_norm] at *
  calc
    ∫⁻ a, ENNReal.ofReal ‖f a‖ ∂μ ≤ ∫⁻ a : α, ENNReal.ofReal ‖g a‖ ∂μ :=
      lintegral_mono_ae (h.mono fun a h => of_real_le_of_real h)
    _ < ∞ := hg
#align measure_theory.has_finite_integral.mono MeasureTheory.HasFiniteIntegral.mono
-/

#print MeasureTheory.HasFiniteIntegral.mono' /-
theorem HasFiniteIntegral.mono' {f : α → β} {g : α → ℝ} (hg : HasFiniteIntegral g μ)
    (h : ∀ᵐ a ∂μ, ‖f a‖ ≤ g a) : HasFiniteIntegral f μ :=
  hg.mono <| h.mono fun x hx => le_trans hx (le_abs_self _)
#align measure_theory.has_finite_integral.mono' MeasureTheory.HasFiniteIntegral.mono'
-/

#print MeasureTheory.HasFiniteIntegral.congr' /-
theorem HasFiniteIntegral.congr' {f : α → β} {g : α → γ} (hf : HasFiniteIntegral f μ)
    (h : ∀ᵐ a ∂μ, ‖f a‖ = ‖g a‖) : HasFiniteIntegral g μ :=
  hf.mono <| EventuallyEq.le <| EventuallyEq.symm h
#align measure_theory.has_finite_integral.congr' MeasureTheory.HasFiniteIntegral.congr'
-/

#print MeasureTheory.hasFiniteIntegral_congr' /-
theorem hasFiniteIntegral_congr' {f : α → β} {g : α → γ} (h : ∀ᵐ a ∂μ, ‖f a‖ = ‖g a‖) :
    HasFiniteIntegral f μ ↔ HasFiniteIntegral g μ :=
  ⟨fun hf => hf.congr' h, fun hg => hg.congr' <| EventuallyEq.symm h⟩
#align measure_theory.has_finite_integral_congr' MeasureTheory.hasFiniteIntegral_congr'
-/

#print MeasureTheory.HasFiniteIntegral.congr /-
theorem HasFiniteIntegral.congr {f g : α → β} (hf : HasFiniteIntegral f μ) (h : f =ᵐ[μ] g) :
    HasFiniteIntegral g μ :=
  hf.congr' <| h.fun_comp norm
#align measure_theory.has_finite_integral.congr MeasureTheory.HasFiniteIntegral.congr
-/

#print MeasureTheory.hasFiniteIntegral_congr /-
theorem hasFiniteIntegral_congr {f g : α → β} (h : f =ᵐ[μ] g) :
    HasFiniteIntegral f μ ↔ HasFiniteIntegral g μ :=
  hasFiniteIntegral_congr' <| h.fun_comp norm
#align measure_theory.has_finite_integral_congr MeasureTheory.hasFiniteIntegral_congr
-/

#print MeasureTheory.hasFiniteIntegral_const_iff /-
theorem hasFiniteIntegral_const_iff {c : β} :
    HasFiniteIntegral (fun x : α => c) μ ↔ c = 0 ∨ μ univ < ∞ := by
  simp [has_finite_integral, lintegral_const, lt_top_iff_ne_top, ENNReal.mul_eq_top,
    or_iff_not_imp_left]
#align measure_theory.has_finite_integral_const_iff MeasureTheory.hasFiniteIntegral_const_iff
-/

#print MeasureTheory.hasFiniteIntegral_const /-
theorem hasFiniteIntegral_const [IsFiniteMeasure μ] (c : β) :
    HasFiniteIntegral (fun x : α => c) μ :=
  hasFiniteIntegral_const_iff.2 (Or.inr <| measure_lt_top _ _)
#align measure_theory.has_finite_integral_const MeasureTheory.hasFiniteIntegral_const
-/

#print MeasureTheory.hasFiniteIntegral_of_bounded /-
theorem hasFiniteIntegral_of_bounded [IsFiniteMeasure μ] {f : α → β} {C : ℝ}
    (hC : ∀ᵐ a ∂μ, ‖f a‖ ≤ C) : HasFiniteIntegral f μ :=
  (hasFiniteIntegral_const C).mono' hC
#align measure_theory.has_finite_integral_of_bounded MeasureTheory.hasFiniteIntegral_of_bounded
-/

#print MeasureTheory.HasFiniteIntegral.mono_measure /-
theorem HasFiniteIntegral.mono_measure {f : α → β} (h : HasFiniteIntegral f ν) (hμ : μ ≤ ν) :
    HasFiniteIntegral f μ :=
  lt_of_le_of_lt (lintegral_mono' hμ le_rfl) h
#align measure_theory.has_finite_integral.mono_measure MeasureTheory.HasFiniteIntegral.mono_measure
-/

#print MeasureTheory.HasFiniteIntegral.add_measure /-
theorem HasFiniteIntegral.add_measure {f : α → β} (hμ : HasFiniteIntegral f μ)
    (hν : HasFiniteIntegral f ν) : HasFiniteIntegral f (μ + ν) :=
  by
  simp only [has_finite_integral, lintegral_add_measure] at *
  exact add_lt_top.2 ⟨hμ, hν⟩
#align measure_theory.has_finite_integral.add_measure MeasureTheory.HasFiniteIntegral.add_measure
-/

#print MeasureTheory.HasFiniteIntegral.left_of_add_measure /-
theorem HasFiniteIntegral.left_of_add_measure {f : α → β} (h : HasFiniteIntegral f (μ + ν)) :
    HasFiniteIntegral f μ :=
  h.mono_measure <| Measure.le_add_right <| le_rfl
#align measure_theory.has_finite_integral.left_of_add_measure MeasureTheory.HasFiniteIntegral.left_of_add_measure
-/

#print MeasureTheory.HasFiniteIntegral.right_of_add_measure /-
theorem HasFiniteIntegral.right_of_add_measure {f : α → β} (h : HasFiniteIntegral f (μ + ν)) :
    HasFiniteIntegral f ν :=
  h.mono_measure <| Measure.le_add_left <| le_rfl
#align measure_theory.has_finite_integral.right_of_add_measure MeasureTheory.HasFiniteIntegral.right_of_add_measure
-/

#print MeasureTheory.hasFiniteIntegral_add_measure /-
@[simp]
theorem hasFiniteIntegral_add_measure {f : α → β} :
    HasFiniteIntegral f (μ + ν) ↔ HasFiniteIntegral f μ ∧ HasFiniteIntegral f ν :=
  ⟨fun h => ⟨h.left_of_add_measure, h.right_of_add_measure⟩, fun h => h.1.add_measure h.2⟩
#align measure_theory.has_finite_integral_add_measure MeasureTheory.hasFiniteIntegral_add_measure
-/

#print MeasureTheory.HasFiniteIntegral.smul_measure /-
theorem HasFiniteIntegral.smul_measure {f : α → β} (h : HasFiniteIntegral f μ) {c : ℝ≥0∞}
    (hc : c ≠ ∞) : HasFiniteIntegral f (c • μ) :=
  by
  simp only [has_finite_integral, lintegral_smul_measure] at *
  exact mul_lt_top hc h.ne
#align measure_theory.has_finite_integral.smul_measure MeasureTheory.HasFiniteIntegral.smul_measure
-/

#print MeasureTheory.hasFiniteIntegral_zero_measure /-
@[simp]
theorem hasFiniteIntegral_zero_measure {m : MeasurableSpace α} (f : α → β) :
    HasFiniteIntegral f (0 : Measure α) := by
  simp only [has_finite_integral, lintegral_zero_measure, WithTop.zero_lt_top]
#align measure_theory.has_finite_integral_zero_measure MeasureTheory.hasFiniteIntegral_zero_measure
-/

variable (α β μ)

#print MeasureTheory.hasFiniteIntegral_zero /-
@[simp]
theorem hasFiniteIntegral_zero : HasFiniteIntegral (fun a : α => (0 : β)) μ := by
  simp [has_finite_integral]
#align measure_theory.has_finite_integral_zero MeasureTheory.hasFiniteIntegral_zero
-/

variable {α β μ}

#print MeasureTheory.HasFiniteIntegral.neg /-
theorem HasFiniteIntegral.neg {f : α → β} (hfi : HasFiniteIntegral f μ) :
    HasFiniteIntegral (-f) μ := by simpa [has_finite_integral] using hfi
#align measure_theory.has_finite_integral.neg MeasureTheory.HasFiniteIntegral.neg
-/

#print MeasureTheory.hasFiniteIntegral_neg_iff /-
@[simp]
theorem hasFiniteIntegral_neg_iff {f : α → β} : HasFiniteIntegral (-f) μ ↔ HasFiniteIntegral f μ :=
  ⟨fun h => neg_neg f ▸ h.neg, HasFiniteIntegral.neg⟩
#align measure_theory.has_finite_integral_neg_iff MeasureTheory.hasFiniteIntegral_neg_iff
-/

#print MeasureTheory.HasFiniteIntegral.norm /-
theorem HasFiniteIntegral.norm {f : α → β} (hfi : HasFiniteIntegral f μ) :
    HasFiniteIntegral (fun a => ‖f a‖) μ :=
  by
  have eq : (fun a => (nnnorm ‖f a‖ : ℝ≥0∞)) = fun a => (‖f a‖₊ : ℝ≥0∞) := by funext;
    rw [nnnorm_norm]
  rwa [has_finite_integral, Eq]
#align measure_theory.has_finite_integral.norm MeasureTheory.HasFiniteIntegral.norm
-/

#print MeasureTheory.hasFiniteIntegral_norm_iff /-
theorem hasFiniteIntegral_norm_iff (f : α → β) :
    HasFiniteIntegral (fun a => ‖f a‖) μ ↔ HasFiniteIntegral f μ :=
  hasFiniteIntegral_congr' <| eventually_of_forall fun x => norm_norm (f x)
#align measure_theory.has_finite_integral_norm_iff MeasureTheory.hasFiniteIntegral_norm_iff
-/

#print MeasureTheory.hasFiniteIntegral_toReal_of_lintegral_ne_top /-
theorem hasFiniteIntegral_toReal_of_lintegral_ne_top {f : α → ℝ≥0∞} (hf : ∫⁻ x, f x ∂μ ≠ ∞) :
    HasFiniteIntegral (fun x => (f x).toReal) μ :=
  by
  have :
    ∀ x, (‖(f x).toReal‖₊ : ℝ≥0∞) = @coe ℝ≥0 ℝ≥0∞ _ (⟨(f x).toReal, ENNReal.toReal_nonneg⟩ : ℝ≥0) :=
    by intro x; rw [Real.nnnorm_of_nonneg]
  simp_rw [has_finite_integral, this]
  refine' lt_of_le_of_lt (lintegral_mono fun x => _) (lt_top_iff_ne_top.2 hf)
  by_cases hfx : f x = ∞
  · simp [hfx]
  · lift f x to ℝ≥0 using hfx with fx
    simp [← h]
#align measure_theory.has_finite_integral_to_real_of_lintegral_ne_top MeasureTheory.hasFiniteIntegral_toReal_of_lintegral_ne_top
-/

#print MeasureTheory.isFiniteMeasure_withDensity_ofReal /-
theorem isFiniteMeasure_withDensity_ofReal {f : α → ℝ} (hfi : HasFiniteIntegral f μ) :
    IsFiniteMeasure (μ.withDensity fun x => ENNReal.ofReal <| f x) :=
  by
  refine' is_finite_measure_with_density ((lintegral_mono fun x => _).trans_lt hfi).Ne
  exact Real.ofReal_le_ennnorm (f x)
#align measure_theory.is_finite_measure_with_density_of_real MeasureTheory.isFiniteMeasure_withDensity_ofReal
-/

section DominatedConvergence

variable {F : ℕ → α → β} {f : α → β} {bound : α → ℝ}

#print MeasureTheory.all_ae_ofReal_F_le_bound /-
theorem all_ae_ofReal_F_le_bound (h : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a) :
    ∀ n, ∀ᵐ a ∂μ, ENNReal.ofReal ‖F n a‖ ≤ ENNReal.ofReal (bound a) := fun n =>
  (h n).mono fun a h => ENNReal.ofReal_le_ofReal h
#align measure_theory.all_ae_of_real_F_le_bound MeasureTheory.all_ae_ofReal_F_le_bound
-/

#print MeasureTheory.all_ae_tendsto_ofReal_norm /-
theorem all_ae_tendsto_ofReal_norm (h : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop <| 𝓝 <| f a) :
    ∀ᵐ a ∂μ, Tendsto (fun n => ENNReal.ofReal ‖F n a‖) atTop <| 𝓝 <| ENNReal.ofReal ‖f a‖ :=
  h.mono fun a h => tendsto_ofReal <| Tendsto.comp (Continuous.tendsto continuous_norm _) h
#align measure_theory.all_ae_tendsto_of_real_norm MeasureTheory.all_ae_tendsto_ofReal_norm
-/

#print MeasureTheory.all_ae_ofReal_f_le_bound /-
theorem all_ae_ofReal_f_le_bound (h_bound : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a)
    (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop (𝓝 (f a))) :
    ∀ᵐ a ∂μ, ENNReal.ofReal ‖f a‖ ≤ ENNReal.ofReal (bound a) :=
  by
  have F_le_bound := all_ae_of_real_F_le_bound h_bound
  rw [← ae_all_iff] at F_le_bound 
  apply F_le_bound.mp ((all_ae_tendsto_of_real_norm h_lim).mono _)
  intro a tendsto_norm F_le_bound
  exact le_of_tendsto' tendsto_norm F_le_bound
#align measure_theory.all_ae_of_real_f_le_bound MeasureTheory.all_ae_ofReal_f_le_bound
-/

#print MeasureTheory.hasFiniteIntegral_of_dominated_convergence /-
theorem hasFiniteIntegral_of_dominated_convergence {F : ℕ → α → β} {f : α → β} {bound : α → ℝ}
    (bound_has_finite_integral : HasFiniteIntegral bound μ)
    (h_bound : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a)
    (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop (𝓝 (f a))) : HasFiniteIntegral f μ :=
  by
  /- `‖F n a‖ ≤ bound a` and `‖F n a‖ --> ‖f a‖` implies `‖f a‖ ≤ bound a`,
    and so `∫ ‖f‖ ≤ ∫ bound < ∞` since `bound` is has_finite_integral -/
  rw [has_finite_integral_iff_norm]
  calc
    ∫⁻ a, ENNReal.ofReal ‖f a‖ ∂μ ≤ ∫⁻ a, ENNReal.ofReal (bound a) ∂μ :=
      lintegral_mono_ae <| all_ae_of_real_f_le_bound h_bound h_lim
    _ < ∞ := by
      rw [← has_finite_integral_iff_of_real]
      · exact bound_has_finite_integral
      exact (h_bound 0).mono fun a h => le_trans (norm_nonneg _) h
#align measure_theory.has_finite_integral_of_dominated_convergence MeasureTheory.hasFiniteIntegral_of_dominated_convergence
-/

#print MeasureTheory.tendsto_lintegral_norm_of_dominated_convergence /-
theorem tendsto_lintegral_norm_of_dominated_convergence {F : ℕ → α → β} {f : α → β} {bound : α → ℝ}
    (F_measurable : ∀ n, AEStronglyMeasurable (F n) μ)
    (bound_has_finite_integral : HasFiniteIntegral bound μ)
    (h_bound : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a)
    (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop (𝓝 (f a))) :
    Tendsto (fun n => ∫⁻ a, ENNReal.ofReal ‖F n a - f a‖ ∂μ) atTop (𝓝 0) :=
  by
  have f_measurable : AEStronglyMeasurable f μ :=
    aestronglyMeasurable_of_tendsto_ae _ F_measurable h_lim
  let b a := 2 * ENNReal.ofReal (bound a)
  /- `‖F n a‖ ≤ bound a` and `F n a --> f a` implies `‖f a‖ ≤ bound a`, and thus by the
    triangle inequality, have `‖F n a - f a‖ ≤ 2 * (bound a). -/
  have hb : ∀ n, ∀ᵐ a ∂μ, ENNReal.ofReal ‖F n a - f a‖ ≤ b a :=
    by
    intro n
    filter_upwards [all_ae_of_real_F_le_bound h_bound n,
      all_ae_of_real_f_le_bound h_bound h_lim] with a h₁ h₂
    calc
      ENNReal.ofReal ‖F n a - f a‖ ≤ ENNReal.ofReal ‖F n a‖ + ENNReal.ofReal ‖f a‖ :=
        by
        rw [← ENNReal.ofReal_add]
        apply of_real_le_of_real
        · apply norm_sub_le; · exact norm_nonneg _; · exact norm_nonneg _
      _ ≤ ENNReal.ofReal (bound a) + ENNReal.ofReal (bound a) := (add_le_add h₁ h₂)
      _ = b a := by rw [← two_mul]
  -- On the other hand, `F n a --> f a` implies that `‖F n a - f a‖ --> 0`
  have h : ∀ᵐ a ∂μ, Tendsto (fun n => ENNReal.ofReal ‖F n a - f a‖) atTop (𝓝 0) :=
    by
    rw [← ENNReal.ofReal_zero]
    refine' h_lim.mono fun a h => (continuous_of_real.tendsto _).comp _
    rwa [← tendsto_iff_norm_tendsto_zero]
  /- Therefore, by the dominated convergence theorem for nonnegative integration, have
    ` ∫ ‖f a - F n a‖ --> 0 ` -/
  suffices h : tendsto (fun n => ∫⁻ a, ENNReal.ofReal ‖F n a - f a‖ ∂μ) at_top (𝓝 (∫⁻ a : α, 0 ∂μ))
  · rwa [lintegral_zero] at h 
  -- Using the dominated convergence theorem.
  refine' tendsto_lintegral_of_dominated_convergence' _ _ hb _ _
  -- Show `λa, ‖f a - F n a‖` is almost everywhere measurable for all `n`
  ·
    exact fun n =>
      measurable_of_real.comp_ae_measurable ((F_measurable n).sub f_measurable).norm.AEMeasurable
  -- Show `2 * bound` is has_finite_integral
  · rw [has_finite_integral_iff_of_real] at bound_has_finite_integral 
    ·
      calc
        ∫⁻ a, b a ∂μ = 2 * ∫⁻ a, ENNReal.ofReal (bound a) ∂μ := by rw [lintegral_const_mul'];
          exact coe_ne_top
        _ ≠ ∞ := mul_ne_top coe_ne_top bound_has_finite_integral.ne
    filter_upwards [h_bound 0] with _ h using le_trans (norm_nonneg _) h
  -- Show `‖f a - F n a‖ --> 0`
  · exact h
#align measure_theory.tendsto_lintegral_norm_of_dominated_convergence MeasureTheory.tendsto_lintegral_norm_of_dominated_convergence
-/

end DominatedConvergence

section PosPart

/-! Lemmas used for defining the positive part of a `L¹` function -/


#print MeasureTheory.HasFiniteIntegral.max_zero /-
theorem HasFiniteIntegral.max_zero {f : α → ℝ} (hf : HasFiniteIntegral f μ) :
    HasFiniteIntegral (fun a => max (f a) 0) μ :=
  hf.mono <| eventually_of_forall fun x => by simp [abs_le, le_abs_self]
#align measure_theory.has_finite_integral.max_zero MeasureTheory.HasFiniteIntegral.max_zero
-/

#print MeasureTheory.HasFiniteIntegral.min_zero /-
theorem HasFiniteIntegral.min_zero {f : α → ℝ} (hf : HasFiniteIntegral f μ) :
    HasFiniteIntegral (fun a => min (f a) 0) μ :=
  hf.mono <|
    eventually_of_forall fun x => by
      simp [abs_le, neg_le, neg_le_abs_self, abs_eq_max_neg, le_total]
#align measure_theory.has_finite_integral.min_zero MeasureTheory.HasFiniteIntegral.min_zero
-/

end PosPart

section NormedSpace

variable {𝕜 : Type _}

#print MeasureTheory.HasFiniteIntegral.smul /-
theorem HasFiniteIntegral.smul [NormedAddCommGroup 𝕜] [SMulZeroClass 𝕜 β] [BoundedSMul 𝕜 β] (c : 𝕜)
    {f : α → β} : HasFiniteIntegral f μ → HasFiniteIntegral (c • f) μ :=
  by
  simp only [has_finite_integral]; intro hfi
  calc
    ∫⁻ a : α, ‖c • f a‖₊ ∂μ ≤ ∫⁻ a : α, ‖c‖₊ * ‖f a‖₊ ∂μ :=
      by
      refine' lintegral_mono _
      intro i
      exact_mod_cast (nnnorm_smul_le c (f i) : _)
    _ < ∞ := by
      rw [lintegral_const_mul']
      exacts [mul_lt_top coe_ne_top hfi.ne, coe_ne_top]
#align measure_theory.has_finite_integral.smul MeasureTheory.HasFiniteIntegral.smul
-/

#print MeasureTheory.hasFiniteIntegral_smul_iff /-
theorem hasFiniteIntegral_smul_iff [NormedRing 𝕜] [MulActionWithZero 𝕜 β] [BoundedSMul 𝕜 β] {c : 𝕜}
    (hc : IsUnit c) (f : α → β) : HasFiniteIntegral (c • f) μ ↔ HasFiniteIntegral f μ :=
  by
  obtain ⟨c, rfl⟩ := hc
  constructor
  · intro h
    simpa only [smul_smul, Units.inv_mul, one_smul] using h.smul (↑c⁻¹ : 𝕜)
  exact has_finite_integral.smul _
#align measure_theory.has_finite_integral_smul_iff MeasureTheory.hasFiniteIntegral_smul_iff
-/

#print MeasureTheory.HasFiniteIntegral.const_mul /-
theorem HasFiniteIntegral.const_mul [NormedRing 𝕜] {f : α → 𝕜} (h : HasFiniteIntegral f μ) (c : 𝕜) :
    HasFiniteIntegral (fun x => c * f x) μ :=
  h.smul c
#align measure_theory.has_finite_integral.const_mul MeasureTheory.HasFiniteIntegral.const_mul
-/

#print MeasureTheory.HasFiniteIntegral.mul_const /-
theorem HasFiniteIntegral.mul_const [NormedRing 𝕜] {f : α → 𝕜} (h : HasFiniteIntegral f μ) (c : 𝕜) :
    HasFiniteIntegral (fun x => f x * c) μ :=
  h.smul (MulOpposite.op c)
#align measure_theory.has_finite_integral.mul_const MeasureTheory.HasFiniteIntegral.mul_const
-/

end NormedSpace

/-! ### The predicate `integrable` -/


#print MeasureTheory.Integrable /-
-- variables [measurable_space β] [measurable_space γ] [measurable_space δ]
/-- `integrable f μ` means that `f` is measurable and that the integral `∫⁻ a, ‖f a‖ ∂μ` is finite.
  `integrable f` means `integrable f volume`. -/
def Integrable {α} {m : MeasurableSpace α} (f : α → β)
    (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) : Prop :=
  AEStronglyMeasurable f μ ∧ HasFiniteIntegral f μ
#align measure_theory.integrable MeasureTheory.Integrable
-/

#print MeasureTheory.memℒp_one_iff_integrable /-
theorem memℒp_one_iff_integrable {f : α → β} : Memℒp f 1 μ ↔ Integrable f μ := by
  simp_rw [integrable, has_finite_integral, mem_ℒp, snorm_one_eq_lintegral_nnnorm]
#align measure_theory.mem_ℒp_one_iff_integrable MeasureTheory.memℒp_one_iff_integrable
-/

#print MeasureTheory.Integrable.aestronglyMeasurable /-
theorem Integrable.aestronglyMeasurable {f : α → β} (hf : Integrable f μ) :
    AEStronglyMeasurable f μ :=
  hf.1
#align measure_theory.integrable.ae_strongly_measurable MeasureTheory.Integrable.aestronglyMeasurable
-/

#print MeasureTheory.Integrable.aemeasurable /-
theorem Integrable.aemeasurable [MeasurableSpace β] [BorelSpace β] {f : α → β}
    (hf : Integrable f μ) : AEMeasurable f μ :=
  hf.AEStronglyMeasurable.AEMeasurable
#align measure_theory.integrable.ae_measurable MeasureTheory.Integrable.aemeasurable
-/

#print MeasureTheory.Integrable.hasFiniteIntegral /-
theorem Integrable.hasFiniteIntegral {f : α → β} (hf : Integrable f μ) : HasFiniteIntegral f μ :=
  hf.2
#align measure_theory.integrable.has_finite_integral MeasureTheory.Integrable.hasFiniteIntegral
-/

#print MeasureTheory.Integrable.mono /-
theorem Integrable.mono {f : α → β} {g : α → γ} (hg : Integrable g μ)
    (hf : AEStronglyMeasurable f μ) (h : ∀ᵐ a ∂μ, ‖f a‖ ≤ ‖g a‖) : Integrable f μ :=
  ⟨hf, hg.HasFiniteIntegral.mono h⟩
#align measure_theory.integrable.mono MeasureTheory.Integrable.mono
-/

#print MeasureTheory.Integrable.mono' /-
theorem Integrable.mono' {f : α → β} {g : α → ℝ} (hg : Integrable g μ)
    (hf : AEStronglyMeasurable f μ) (h : ∀ᵐ a ∂μ, ‖f a‖ ≤ g a) : Integrable f μ :=
  ⟨hf, hg.HasFiniteIntegral.mono' h⟩
#align measure_theory.integrable.mono' MeasureTheory.Integrable.mono'
-/

#print MeasureTheory.Integrable.congr' /-
theorem Integrable.congr' {f : α → β} {g : α → γ} (hf : Integrable f μ)
    (hg : AEStronglyMeasurable g μ) (h : ∀ᵐ a ∂μ, ‖f a‖ = ‖g a‖) : Integrable g μ :=
  ⟨hg, hf.HasFiniteIntegral.congr' h⟩
#align measure_theory.integrable.congr' MeasureTheory.Integrable.congr'
-/

#print MeasureTheory.integrable_congr' /-
theorem integrable_congr' {f : α → β} {g : α → γ} (hf : AEStronglyMeasurable f μ)
    (hg : AEStronglyMeasurable g μ) (h : ∀ᵐ a ∂μ, ‖f a‖ = ‖g a‖) :
    Integrable f μ ↔ Integrable g μ :=
  ⟨fun h2f => h2f.congr' hg h, fun h2g => h2g.congr' hf <| EventuallyEq.symm h⟩
#align measure_theory.integrable_congr' MeasureTheory.integrable_congr'
-/

#print MeasureTheory.Integrable.congr /-
theorem Integrable.congr {f g : α → β} (hf : Integrable f μ) (h : f =ᵐ[μ] g) : Integrable g μ :=
  ⟨hf.1.congr h, hf.2.congr h⟩
#align measure_theory.integrable.congr MeasureTheory.Integrable.congr
-/

#print MeasureTheory.integrable_congr /-
theorem integrable_congr {f g : α → β} (h : f =ᵐ[μ] g) : Integrable f μ ↔ Integrable g μ :=
  ⟨fun hf => hf.congr h, fun hg => hg.congr h.symm⟩
#align measure_theory.integrable_congr MeasureTheory.integrable_congr
-/

#print MeasureTheory.integrable_const_iff /-
theorem integrable_const_iff {c : β} : Integrable (fun x : α => c) μ ↔ c = 0 ∨ μ univ < ∞ :=
  by
  have : ae_strongly_measurable (fun x : α => c) μ := ae_strongly_measurable_const
  rw [integrable, and_iff_right this, has_finite_integral_const_iff]
#align measure_theory.integrable_const_iff MeasureTheory.integrable_const_iff
-/

#print MeasureTheory.integrable_const /-
@[simp]
theorem integrable_const [IsFiniteMeasure μ] (c : β) : Integrable (fun x : α => c) μ :=
  integrable_const_iff.2 <| Or.inr <| measure_lt_top _ _
#align measure_theory.integrable_const MeasureTheory.integrable_const
-/

#print MeasureTheory.Memℒp.integrable_norm_rpow /-
theorem Memℒp.integrable_norm_rpow {f : α → β} {p : ℝ≥0∞} (hf : Memℒp f p μ) (hp_ne_zero : p ≠ 0)
    (hp_ne_top : p ≠ ∞) : Integrable (fun x : α => ‖f x‖ ^ p.toReal) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable]
  exact hf.norm_rpow hp_ne_zero hp_ne_top
#align measure_theory.mem_ℒp.integrable_norm_rpow MeasureTheory.Memℒp.integrable_norm_rpow
-/

#print MeasureTheory.Memℒp.integrable_norm_rpow' /-
theorem Memℒp.integrable_norm_rpow' [IsFiniteMeasure μ] {f : α → β} {p : ℝ≥0∞} (hf : Memℒp f p μ) :
    Integrable (fun x : α => ‖f x‖ ^ p.toReal) μ :=
  by
  by_cases h_zero : p = 0
  · simp [h_zero, integrable_const]
  by_cases h_top : p = ∞
  · simp [h_top, integrable_const]
  exact hf.integrable_norm_rpow h_zero h_top
#align measure_theory.mem_ℒp.integrable_norm_rpow' MeasureTheory.Memℒp.integrable_norm_rpow'
-/

#print MeasureTheory.Integrable.mono_measure /-
theorem Integrable.mono_measure {f : α → β} (h : Integrable f ν) (hμ : μ ≤ ν) : Integrable f μ :=
  ⟨h.AEStronglyMeasurable.mono_measure hμ, h.HasFiniteIntegral.mono_measure hμ⟩
#align measure_theory.integrable.mono_measure MeasureTheory.Integrable.mono_measure
-/

#print MeasureTheory.Integrable.of_measure_le_smul /-
theorem Integrable.of_measure_le_smul {μ' : Measure α} (c : ℝ≥0∞) (hc : c ≠ ∞) (hμ'_le : μ' ≤ c • μ)
    {f : α → β} (hf : Integrable f μ) : Integrable f μ' := by
  rw [← mem_ℒp_one_iff_integrable] at hf ⊢; exact hf.of_measure_le_smul c hc hμ'_le
#align measure_theory.integrable.of_measure_le_smul MeasureTheory.Integrable.of_measure_le_smul
-/

#print MeasureTheory.Integrable.add_measure /-
theorem Integrable.add_measure {f : α → β} (hμ : Integrable f μ) (hν : Integrable f ν) :
    Integrable f (μ + ν) :=
  by
  simp_rw [← mem_ℒp_one_iff_integrable] at hμ hν ⊢
  refine' ⟨hμ.ae_strongly_measurable.add_measure hν.ae_strongly_measurable, _⟩
  rw [snorm_one_add_measure, ENNReal.add_lt_top]
  exact ⟨hμ.snorm_lt_top, hν.snorm_lt_top⟩
#align measure_theory.integrable.add_measure MeasureTheory.Integrable.add_measure
-/

#print MeasureTheory.Integrable.left_of_add_measure /-
theorem Integrable.left_of_add_measure {f : α → β} (h : Integrable f (μ + ν)) : Integrable f μ := by
  rw [← mem_ℒp_one_iff_integrable] at h ⊢; exact h.left_of_add_measure
#align measure_theory.integrable.left_of_add_measure MeasureTheory.Integrable.left_of_add_measure
-/

#print MeasureTheory.Integrable.right_of_add_measure /-
theorem Integrable.right_of_add_measure {f : α → β} (h : Integrable f (μ + ν)) : Integrable f ν :=
  by rw [← mem_ℒp_one_iff_integrable] at h ⊢; exact h.right_of_add_measure
#align measure_theory.integrable.right_of_add_measure MeasureTheory.Integrable.right_of_add_measure
-/

#print MeasureTheory.integrable_add_measure /-
@[simp]
theorem integrable_add_measure {f : α → β} :
    Integrable f (μ + ν) ↔ Integrable f μ ∧ Integrable f ν :=
  ⟨fun h => ⟨h.left_of_add_measure, h.right_of_add_measure⟩, fun h => h.1.add_measure h.2⟩
#align measure_theory.integrable_add_measure MeasureTheory.integrable_add_measure
-/

#print MeasureTheory.integrable_zero_measure /-
@[simp]
theorem integrable_zero_measure {m : MeasurableSpace α} {f : α → β} :
    Integrable f (0 : Measure α) :=
  ⟨aestronglyMeasurable_zero_measure f, hasFiniteIntegral_zero_measure f⟩
#align measure_theory.integrable_zero_measure MeasureTheory.integrable_zero_measure
-/

#print MeasureTheory.integrable_finset_sum_measure /-
theorem integrable_finset_sum_measure {ι} {m : MeasurableSpace α} {f : α → β} {μ : ι → Measure α}
    {s : Finset ι} : Integrable f (∑ i in s, μ i) ↔ ∀ i ∈ s, Integrable f (μ i) := by
  induction s using Finset.induction_on <;> simp [*]
#align measure_theory.integrable_finset_sum_measure MeasureTheory.integrable_finset_sum_measure
-/

#print MeasureTheory.Integrable.smul_measure /-
theorem Integrable.smul_measure {f : α → β} (h : Integrable f μ) {c : ℝ≥0∞} (hc : c ≠ ∞) :
    Integrable f (c • μ) := by rw [← mem_ℒp_one_iff_integrable] at h ⊢; exact h.smul_measure hc
#align measure_theory.integrable.smul_measure MeasureTheory.Integrable.smul_measure
-/

#print MeasureTheory.integrable_smul_measure /-
theorem integrable_smul_measure {f : α → β} {c : ℝ≥0∞} (h₁ : c ≠ 0) (h₂ : c ≠ ∞) :
    Integrable f (c • μ) ↔ Integrable f μ :=
  ⟨fun h => by
    simpa only [smul_smul, ENNReal.inv_mul_cancel h₁ h₂, one_smul] using
      h.smul_measure (ENNReal.inv_ne_top.2 h₁),
    fun h => h.smul_measure h₂⟩
#align measure_theory.integrable_smul_measure MeasureTheory.integrable_smul_measure
-/

#print MeasureTheory.integrable_inv_smul_measure /-
theorem integrable_inv_smul_measure {f : α → β} {c : ℝ≥0∞} (h₁ : c ≠ 0) (h₂ : c ≠ ∞) :
    Integrable f (c⁻¹ • μ) ↔ Integrable f μ :=
  integrable_smul_measure (by simpa using h₂) (by simpa using h₁)
#align measure_theory.integrable_inv_smul_measure MeasureTheory.integrable_inv_smul_measure
-/

#print MeasureTheory.Integrable.to_average /-
theorem Integrable.to_average {f : α → β} (h : Integrable f μ) : Integrable f ((μ univ)⁻¹ • μ) :=
  by
  rcases eq_or_ne μ 0 with (rfl | hne)
  · rwa [smul_zero]
  · apply h.smul_measure; simpa
#align measure_theory.integrable.to_average MeasureTheory.Integrable.to_average
-/

#print MeasureTheory.integrable_average /-
theorem integrable_average [IsFiniteMeasure μ] {f : α → β} :
    Integrable f ((μ univ)⁻¹ • μ) ↔ Integrable f μ :=
  (eq_or_ne μ 0).byCases (fun h => by simp [h]) fun h =>
    integrable_smul_measure (ENNReal.inv_ne_zero.2 <| measure_ne_top _ _)
      (ENNReal.inv_ne_top.2 <| mt Measure.measure_univ_eq_zero.1 h)
#align measure_theory.integrable_average MeasureTheory.integrable_average
-/

#print MeasureTheory.integrable_map_measure /-
theorem integrable_map_measure {f : α → δ} {g : δ → β}
    (hg : AEStronglyMeasurable g (Measure.map f μ)) (hf : AEMeasurable f μ) :
    Integrable g (Measure.map f μ) ↔ Integrable (g ∘ f) μ := by
  simp_rw [← mem_ℒp_one_iff_integrable]; exact mem_ℒp_map_measure_iff hg hf
#align measure_theory.integrable_map_measure MeasureTheory.integrable_map_measure
-/

#print MeasureTheory.Integrable.comp_aemeasurable /-
theorem Integrable.comp_aemeasurable {f : α → δ} {g : δ → β} (hg : Integrable g (Measure.map f μ))
    (hf : AEMeasurable f μ) : Integrable (g ∘ f) μ :=
  (integrable_map_measure hg.AEStronglyMeasurable hf).mp hg
#align measure_theory.integrable.comp_ae_measurable MeasureTheory.Integrable.comp_aemeasurable
-/

#print MeasureTheory.Integrable.comp_measurable /-
theorem Integrable.comp_measurable {f : α → δ} {g : δ → β} (hg : Integrable g (Measure.map f μ))
    (hf : Measurable f) : Integrable (g ∘ f) μ :=
  hg.comp_aemeasurable hf.AEMeasurable
#align measure_theory.integrable.comp_measurable MeasureTheory.Integrable.comp_measurable
-/

#print MeasurableEmbedding.integrable_map_iff /-
theorem MeasurableEmbedding.integrable_map_iff {f : α → δ} (hf : MeasurableEmbedding f)
    {g : δ → β} : Integrable g (Measure.map f μ) ↔ Integrable (g ∘ f) μ := by
  simp_rw [← mem_ℒp_one_iff_integrable]; exact hf.mem_ℒp_map_measure_iff
#align measurable_embedding.integrable_map_iff MeasurableEmbedding.integrable_map_iff
-/

#print MeasureTheory.integrable_map_equiv /-
theorem integrable_map_equiv (f : α ≃ᵐ δ) (g : δ → β) :
    Integrable g (Measure.map f μ) ↔ Integrable (g ∘ f) μ := by
  simp_rw [← mem_ℒp_one_iff_integrable]; exact f.mem_ℒp_map_measure_iff
#align measure_theory.integrable_map_equiv MeasureTheory.integrable_map_equiv
-/

#print MeasureTheory.MeasurePreserving.integrable_comp /-
theorem MeasurePreserving.integrable_comp {ν : Measure δ} {g : δ → β} {f : α → δ}
    (hf : MeasurePreserving f μ ν) (hg : AEStronglyMeasurable g ν) :
    Integrable (g ∘ f) μ ↔ Integrable g ν := by rw [← hf.map_eq] at hg ⊢;
  exact (integrable_map_measure hg hf.measurable.ae_measurable).symm
#align measure_theory.measure_preserving.integrable_comp MeasureTheory.MeasurePreserving.integrable_comp
-/

#print MeasureTheory.MeasurePreserving.integrable_comp_emb /-
theorem MeasurePreserving.integrable_comp_emb {f : α → δ} {ν} (h₁ : MeasurePreserving f μ ν)
    (h₂ : MeasurableEmbedding f) {g : δ → β} : Integrable (g ∘ f) μ ↔ Integrable g ν :=
  h₁.map_eq ▸ Iff.symm h₂.integrable_map_iff
#align measure_theory.measure_preserving.integrable_comp_emb MeasureTheory.MeasurePreserving.integrable_comp_emb
-/

#print MeasureTheory.lintegral_edist_lt_top /-
theorem lintegral_edist_lt_top {f g : α → β} (hf : Integrable f μ) (hg : Integrable g μ) :
    ∫⁻ a, edist (f a) (g a) ∂μ < ∞ :=
  lt_of_le_of_lt (lintegral_edist_triangle hf.AEStronglyMeasurable aestronglyMeasurable_zero)
    (ENNReal.add_lt_top.2 <|
      by
      simp_rw [Pi.zero_apply, ← has_finite_integral_iff_edist]
      exact ⟨hf.has_finite_integral, hg.has_finite_integral⟩)
#align measure_theory.lintegral_edist_lt_top MeasureTheory.lintegral_edist_lt_top
-/

variable (α β μ)

#print MeasureTheory.integrable_zero /-
@[simp]
theorem integrable_zero : Integrable (fun _ => (0 : β)) μ := by
  simp [integrable, ae_strongly_measurable_const]
#align measure_theory.integrable_zero MeasureTheory.integrable_zero
-/

variable {α β μ}

#print MeasureTheory.Integrable.add' /-
theorem Integrable.add' {f g : α → β} (hf : Integrable f μ) (hg : Integrable g μ) :
    HasFiniteIntegral (f + g) μ :=
  calc
    ∫⁻ a, ‖f a + g a‖₊ ∂μ ≤ ∫⁻ a, ‖f a‖₊ + ‖g a‖₊ ∂μ :=
      lintegral_mono fun a => by exact_mod_cast nnnorm_add_le _ _
    _ = _ := (lintegral_nnnorm_add_left hf.AEStronglyMeasurable _)
    _ < ∞ := add_lt_top.2 ⟨hf.HasFiniteIntegral, hg.HasFiniteIntegral⟩
#align measure_theory.integrable.add' MeasureTheory.Integrable.add'
-/

#print MeasureTheory.Integrable.add /-
theorem Integrable.add {f g : α → β} (hf : Integrable f μ) (hg : Integrable g μ) :
    Integrable (f + g) μ :=
  ⟨hf.AEStronglyMeasurable.add hg.AEStronglyMeasurable, hf.add' hg⟩
#align measure_theory.integrable.add MeasureTheory.Integrable.add
-/

#print MeasureTheory.integrable_finset_sum' /-
theorem integrable_finset_sum' {ι} (s : Finset ι) {f : ι → α → β}
    (hf : ∀ i ∈ s, Integrable (f i) μ) : Integrable (∑ i in s, f i) μ :=
  Finset.sum_induction f (fun g => Integrable g μ) (fun _ _ => Integrable.add)
    (integrable_zero _ _ _) hf
#align measure_theory.integrable_finset_sum' MeasureTheory.integrable_finset_sum'
-/

#print MeasureTheory.integrable_finset_sum /-
theorem integrable_finset_sum {ι} (s : Finset ι) {f : ι → α → β}
    (hf : ∀ i ∈ s, Integrable (f i) μ) : Integrable (fun a => ∑ i in s, f i a) μ := by
  simpa only [← Finset.sum_apply] using integrable_finset_sum' s hf
#align measure_theory.integrable_finset_sum MeasureTheory.integrable_finset_sum
-/

#print MeasureTheory.Integrable.neg /-
theorem Integrable.neg {f : α → β} (hf : Integrable f μ) : Integrable (-f) μ :=
  ⟨hf.AEStronglyMeasurable.neg, hf.HasFiniteIntegral.neg⟩
#align measure_theory.integrable.neg MeasureTheory.Integrable.neg
-/

#print MeasureTheory.integrable_neg_iff /-
@[simp]
theorem integrable_neg_iff {f : α → β} : Integrable (-f) μ ↔ Integrable f μ :=
  ⟨fun h => neg_neg f ▸ h.neg, Integrable.neg⟩
#align measure_theory.integrable_neg_iff MeasureTheory.integrable_neg_iff
-/

#print MeasureTheory.Integrable.sub /-
theorem Integrable.sub {f g : α → β} (hf : Integrable f μ) (hg : Integrable g μ) :
    Integrable (f - g) μ := by simpa only [sub_eq_add_neg] using hf.add hg.neg
#align measure_theory.integrable.sub MeasureTheory.Integrable.sub
-/

#print MeasureTheory.Integrable.norm /-
theorem Integrable.norm {f : α → β} (hf : Integrable f μ) : Integrable (fun a => ‖f a‖) μ :=
  ⟨hf.AEStronglyMeasurable.norm, hf.HasFiniteIntegral.norm⟩
#align measure_theory.integrable.norm MeasureTheory.Integrable.norm
-/

#print MeasureTheory.Integrable.inf /-
theorem Integrable.inf {β} [NormedLatticeAddCommGroup β] {f g : α → β} (hf : Integrable f μ)
    (hg : Integrable g μ) : Integrable (f ⊓ g) μ := by rw [← mem_ℒp_one_iff_integrable] at hf hg ⊢;
  exact hf.inf hg
#align measure_theory.integrable.inf MeasureTheory.Integrable.inf
-/

#print MeasureTheory.Integrable.sup /-
theorem Integrable.sup {β} [NormedLatticeAddCommGroup β] {f g : α → β} (hf : Integrable f μ)
    (hg : Integrable g μ) : Integrable (f ⊔ g) μ := by rw [← mem_ℒp_one_iff_integrable] at hf hg ⊢;
  exact hf.sup hg
#align measure_theory.integrable.sup MeasureTheory.Integrable.sup
-/

#print MeasureTheory.Integrable.abs /-
theorem Integrable.abs {β} [NormedLatticeAddCommGroup β] {f : α → β} (hf : Integrable f μ) :
    Integrable (fun a => |f a|) μ := by rw [← mem_ℒp_one_iff_integrable] at hf ⊢; exact hf.abs
#align measure_theory.integrable.abs MeasureTheory.Integrable.abs
-/

#print MeasureTheory.Integrable.bdd_mul /-
theorem Integrable.bdd_mul {F : Type _} [NormedDivisionRing F] {f g : α → F} (hint : Integrable g μ)
    (hm : AEStronglyMeasurable f μ) (hfbdd : ∃ C, ∀ x, ‖f x‖ ≤ C) :
    Integrable (fun x => f x * g x) μ :=
  by
  cases' isEmpty_or_nonempty α with hα hα
  · rw [μ.eq_zero_of_is_empty]
    exact integrable_zero_measure
  · refine' ⟨hm.mul hint.1, _⟩
    obtain ⟨C, hC⟩ := hfbdd
    have hCnonneg : 0 ≤ C := le_trans (norm_nonneg _) (hC hα.some)
    have : (fun x => ‖f x * g x‖₊) ≤ fun x => ⟨C, hCnonneg⟩ * ‖g x‖₊ :=
      by
      intro x
      simp only [nnnorm_mul]
      exact mul_le_mul_of_nonneg_right (hC x) (zero_le _)
    refine' lt_of_le_of_lt (lintegral_mono_nnreal this) _
    simp only [ENNReal.coe_mul]
    rw [lintegral_const_mul' _ _ ENNReal.coe_ne_top]
    exact ENNReal.mul_lt_top ENNReal.coe_ne_top (ne_of_lt hint.2)
#align measure_theory.integrable.bdd_mul MeasureTheory.Integrable.bdd_mul
-/

#print MeasureTheory.Integrable.essSup_smul /-
/-- Hölder's inequality for integrable functions: the scalar multiplication of an integrable
vector-valued function by a scalar function with finite essential supremum is integrable. -/
theorem Integrable.essSup_smul {𝕜 : Type _} [NormedField 𝕜] [NormedSpace 𝕜 β] {f : α → β}
    (hf : Integrable f μ) {g : α → 𝕜} (g_ae_strongly_measurable : AEStronglyMeasurable g μ)
    (ess_sup_g : essSup (fun x => (‖g x‖₊ : ℝ≥0∞)) μ ≠ ∞) : Integrable (fun x : α => g x • f x) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at *
  refine' ⟨g_ae_strongly_measurable.smul hf.1, _⟩
  have h : (1 : ℝ≥0∞) / 1 = 1 / ∞ + 1 / 1 := by norm_num
  have hg' : snorm g ∞ μ ≠ ∞ := by rwa [snorm_exponent_top]
  calc
    snorm (fun x : α => g x • f x) 1 μ ≤ _ :=
      MeasureTheory.snorm_smul_le_mul_snorm hf.1 g_ae_strongly_measurable h
    _ < ∞ := ENNReal.mul_lt_top hg' hf.2.Ne
#align measure_theory.integrable.ess_sup_smul MeasureTheory.Integrable.essSup_smul
-/

#print MeasureTheory.Integrable.smul_essSup /-
/-- Hölder's inequality for integrable functions: the scalar multiplication of an integrable
scalar-valued function by a vector-value function with finite essential supremum is integrable. -/
theorem Integrable.smul_essSup {𝕜 : Type _} [NormedRing 𝕜] [Module 𝕜 β] [BoundedSMul 𝕜 β]
    {f : α → 𝕜} (hf : Integrable f μ) {g : α → β}
    (g_ae_strongly_measurable : AEStronglyMeasurable g μ)
    (ess_sup_g : essSup (fun x => (‖g x‖₊ : ℝ≥0∞)) μ ≠ ∞) : Integrable (fun x : α => f x • g x) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at *
  refine' ⟨hf.1.smul g_ae_strongly_measurable, _⟩
  have h : (1 : ℝ≥0∞) / 1 = 1 / 1 + 1 / ∞ := by norm_num
  have hg' : snorm g ∞ μ ≠ ∞ := by rwa [snorm_exponent_top]
  calc
    snorm (fun x : α => f x • g x) 1 μ ≤ _ :=
      MeasureTheory.snorm_smul_le_mul_snorm g_ae_strongly_measurable hf.1 h
    _ < ∞ := ENNReal.mul_lt_top hf.2.Ne hg'
#align measure_theory.integrable.smul_ess_sup MeasureTheory.Integrable.smul_essSup
-/

#print MeasureTheory.integrable_norm_iff /-
theorem integrable_norm_iff {f : α → β} (hf : AEStronglyMeasurable f μ) :
    Integrable (fun a => ‖f a‖) μ ↔ Integrable f μ := by
  simp_rw [integrable, and_iff_right hf, and_iff_right hf.norm, has_finite_integral_norm_iff]
#align measure_theory.integrable_norm_iff MeasureTheory.integrable_norm_iff
-/

#print MeasureTheory.integrable_of_norm_sub_le /-
theorem integrable_of_norm_sub_le {f₀ f₁ : α → β} {g : α → ℝ} (hf₁_m : AEStronglyMeasurable f₁ μ)
    (hf₀_i : Integrable f₀ μ) (hg_i : Integrable g μ) (h : ∀ᵐ a ∂μ, ‖f₀ a - f₁ a‖ ≤ g a) :
    Integrable f₁ μ :=
  haveI : ∀ᵐ a ∂μ, ‖f₁ a‖ ≤ ‖f₀ a‖ + g a := by
    apply h.mono
    intro a ha
    calc
      ‖f₁ a‖ ≤ ‖f₀ a‖ + ‖f₀ a - f₁ a‖ := norm_le_insert _ _
      _ ≤ ‖f₀ a‖ + g a := add_le_add_left ha _
  integrable.mono' (hf₀_i.norm.add hg_i) hf₁_m this
#align measure_theory.integrable_of_norm_sub_le MeasureTheory.integrable_of_norm_sub_le
-/

#print MeasureTheory.Integrable.prod_mk /-
theorem Integrable.prod_mk {f : α → β} {g : α → γ} (hf : Integrable f μ) (hg : Integrable g μ) :
    Integrable (fun x => (f x, g x)) μ :=
  ⟨hf.AEStronglyMeasurable.prod_mk hg.AEStronglyMeasurable,
    (hf.norm.add' hg.norm).mono <|
      eventually_of_forall fun x =>
        calc
          max ‖f x‖ ‖g x‖ ≤ ‖f x‖ + ‖g x‖ := max_le_add_of_nonneg (norm_nonneg _) (norm_nonneg _)
          _ ≤ ‖‖f x‖ + ‖g x‖‖ := le_abs_self _⟩
#align measure_theory.integrable.prod_mk MeasureTheory.Integrable.prod_mk
-/

#print MeasureTheory.Memℒp.integrable /-
theorem Memℒp.integrable {q : ℝ≥0∞} (hq1 : 1 ≤ q) {f : α → β} [IsFiniteMeasure μ]
    (hfq : Memℒp f q μ) : Integrable f μ :=
  memℒp_one_iff_integrable.mp (hfq.memℒp_of_exponent_le hq1)
#align measure_theory.mem_ℒp.integrable MeasureTheory.Memℒp.integrable
-/

#print MeasureTheory.Integrable.measure_ge_lt_top /-
/-- A non-quantitative version of Markov inequality for integrable functions: the measure of points
where `‖f x‖ ≥ ε` is finite for all positive `ε`. -/
theorem Integrable.measure_ge_lt_top {f : α → β} (hf : Integrable f μ) {ε : ℝ} (hε : 0 < ε) :
    μ {x | ε ≤ ‖f x‖} < ∞ :=
  by
  rw [show {x | ε ≤ ‖f x‖} = {x | ENNReal.ofReal ε ≤ ‖f x‖₊} by
      simp only [ENNReal.ofReal, Real.toNNReal_le_iff_le_coe, ENNReal.coe_le_coe, coe_nnnorm]]
  refine' (meas_ge_le_mul_pow_snorm μ one_ne_zero ENNReal.one_ne_top hf.1 _).trans_lt _
  · simpa only [Ne.def, ENNReal.ofReal_eq_zero, not_le] using hε
  apply ENNReal.mul_lt_top
  ·
    simpa only [ENNReal.one_toReal, ENNReal.rpow_one, Ne.def, ENNReal.inv_eq_top,
      ENNReal.ofReal_eq_zero, not_le] using hε
  simpa only [ENNReal.one_toReal, ENNReal.rpow_one] using
    (mem_ℒp_one_iff_integrable.2 hf).snorm_ne_top
#align measure_theory.integrable.measure_ge_lt_top MeasureTheory.Integrable.measure_ge_lt_top
-/

#print MeasureTheory.LipschitzWith.integrable_comp_iff_of_antilipschitz /-
theorem LipschitzWith.integrable_comp_iff_of_antilipschitz {K K'} {f : α → β} {g : β → γ}
    (hg : LipschitzWith K g) (hg' : AntilipschitzWith K' g) (g0 : g 0 = 0) :
    Integrable (g ∘ f) μ ↔ Integrable f μ := by
  simp [← mem_ℒp_one_iff_integrable, hg.mem_ℒp_comp_iff_of_antilipschitz hg' g0]
#align measure_theory.lipschitz_with.integrable_comp_iff_of_antilipschitz MeasureTheory.LipschitzWith.integrable_comp_iff_of_antilipschitz
-/

#print MeasureTheory.Integrable.real_toNNReal /-
theorem Integrable.real_toNNReal {f : α → ℝ} (hf : Integrable f μ) :
    Integrable (fun x => ((f x).toNNReal : ℝ)) μ :=
  by
  refine'
    ⟨hf.ae_strongly_measurable.ae_measurable.real_toNNReal.coeNNRealReal.AEStronglyMeasurable, _⟩
  rw [has_finite_integral_iff_norm]
  refine' lt_of_le_of_lt _ ((has_finite_integral_iff_norm _).1 hf.has_finite_integral)
  apply lintegral_mono
  intro x
  simp [ENNReal.ofReal_le_ofReal, abs_le, le_abs_self]
#align measure_theory.integrable.real_to_nnreal MeasureTheory.Integrable.real_toNNReal
-/

#print MeasureTheory.ofReal_toReal_ae_eq /-
theorem ofReal_toReal_ae_eq {f : α → ℝ≥0∞} (hf : ∀ᵐ x ∂μ, f x < ∞) :
    (fun x => ENNReal.ofReal (f x).toReal) =ᵐ[μ] f :=
  by
  filter_upwards [hf]
  intro x hx
  simp only [hx.ne, of_real_to_real, Ne.def, not_false_iff]
#align measure_theory.of_real_to_real_ae_eq MeasureTheory.ofReal_toReal_ae_eq
-/

#print MeasureTheory.coe_toNNReal_ae_eq /-
theorem coe_toNNReal_ae_eq {f : α → ℝ≥0∞} (hf : ∀ᵐ x ∂μ, f x < ∞) :
    (fun x => ((f x).toNNReal : ℝ≥0∞)) =ᵐ[μ] f :=
  by
  filter_upwards [hf]
  intro x hx
  simp only [hx.ne, Ne.def, not_false_iff, coe_to_nnreal]
#align measure_theory.coe_to_nnreal_ae_eq MeasureTheory.coe_toNNReal_ae_eq
-/

section

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]

#print MeasureTheory.integrable_withDensity_iff_integrable_coe_smul /-
theorem integrable_withDensity_iff_integrable_coe_smul {f : α → ℝ≥0} (hf : Measurable f)
    {g : α → E} :
    Integrable g (μ.withDensity fun x => f x) ↔ Integrable (fun x => (f x : ℝ) • g x) μ :=
  by
  by_cases H : ae_strongly_measurable (fun x : α => (f x : ℝ) • g x) μ
  · simp only [integrable, aestronglyMeasurable_withDensity_iff hf, has_finite_integral, H,
      true_and_iff]
    rw [lintegral_with_density_eq_lintegral_mul₀' hf.coe_nnreal_ennreal.ae_measurable]
    · congr
      ext1 x
      simp only [nnnorm_smul, NNReal.nnnorm_eq, coe_mul, Pi.mul_apply]
    · rw [ae_measurable_with_density_ennreal_iff hf]
      convert H.ennnorm
      ext1 x
      simp only [nnnorm_smul, NNReal.nnnorm_eq, coe_mul]
  · simp only [integrable, aestronglyMeasurable_withDensity_iff hf, H, false_and_iff]
#align measure_theory.integrable_with_density_iff_integrable_coe_smul MeasureTheory.integrable_withDensity_iff_integrable_coe_smul
-/

#print MeasureTheory.integrable_withDensity_iff_integrable_smul /-
theorem integrable_withDensity_iff_integrable_smul {f : α → ℝ≥0} (hf : Measurable f) {g : α → E} :
    Integrable g (μ.withDensity fun x => f x) ↔ Integrable (fun x => f x • g x) μ :=
  integrable_withDensity_iff_integrable_coe_smul hf
#align measure_theory.integrable_with_density_iff_integrable_smul MeasureTheory.integrable_withDensity_iff_integrable_smul
-/

#print MeasureTheory.integrable_withDensity_iff_integrable_smul' /-
theorem integrable_withDensity_iff_integrable_smul' {f : α → ℝ≥0∞} (hf : Measurable f)
    (hflt : ∀ᵐ x ∂μ, f x < ∞) {g : α → E} :
    Integrable g (μ.withDensity f) ↔ Integrable (fun x => (f x).toReal • g x) μ :=
  by
  rw [← with_density_congr_ae (coe_to_nnreal_ae_eq hflt),
    integrable_with_density_iff_integrable_smul]
  · rfl
  · exact hf.ennreal_to_nnreal
#align measure_theory.integrable_with_density_iff_integrable_smul' MeasureTheory.integrable_withDensity_iff_integrable_smul'
-/

#print MeasureTheory.integrable_withDensity_iff_integrable_coe_smul₀ /-
theorem integrable_withDensity_iff_integrable_coe_smul₀ {f : α → ℝ≥0} (hf : AEMeasurable f μ)
    {g : α → E} :
    Integrable g (μ.withDensity fun x => f x) ↔ Integrable (fun x => (f x : ℝ) • g x) μ :=
  calc
    Integrable g (μ.withDensity fun x => f x) ↔ Integrable g (μ.withDensity fun x => hf.mk f x) :=
      by
      suffices (fun x => (f x : ℝ≥0∞)) =ᵐ[μ] fun x => hf.mk f x by rw [with_density_congr_ae this]
      filter_upwards [hf.ae_eq_mk] with x hx
      simp [hx]
    _ ↔ Integrable (fun x => (hf.mk f x : ℝ) • g x) μ :=
      (integrable_withDensity_iff_integrable_coe_smul hf.measurable_mk)
    _ ↔ Integrable (fun x => (f x : ℝ) • g x) μ :=
      by
      apply integrable_congr
      filter_upwards [hf.ae_eq_mk] with x hx
      simp [hx]
#align measure_theory.integrable_with_density_iff_integrable_coe_smul₀ MeasureTheory.integrable_withDensity_iff_integrable_coe_smul₀
-/

#print MeasureTheory.integrable_withDensity_iff_integrable_smul₀ /-
theorem integrable_withDensity_iff_integrable_smul₀ {f : α → ℝ≥0} (hf : AEMeasurable f μ)
    {g : α → E} : Integrable g (μ.withDensity fun x => f x) ↔ Integrable (fun x => f x • g x) μ :=
  integrable_withDensity_iff_integrable_coe_smul₀ hf
#align measure_theory.integrable_with_density_iff_integrable_smul₀ MeasureTheory.integrable_withDensity_iff_integrable_smul₀
-/

end

#print MeasureTheory.integrable_withDensity_iff /-
theorem integrable_withDensity_iff {f : α → ℝ≥0∞} (hf : Measurable f) (hflt : ∀ᵐ x ∂μ, f x < ∞)
    {g : α → ℝ} : Integrable g (μ.withDensity f) ↔ Integrable (fun x => g x * (f x).toReal) μ :=
  by
  have : (fun x => g x * (f x).toReal) = fun x => (f x).toReal • g x := by simp [mul_comm]
  rw [this]
  exact integrable_with_density_iff_integrable_smul' hf hflt
#align measure_theory.integrable_with_density_iff MeasureTheory.integrable_withDensity_iff
-/

section

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]

#print MeasureTheory.memℒ1_smul_of_L1_withDensity /-
theorem memℒ1_smul_of_L1_withDensity {f : α → ℝ≥0} (f_meas : Measurable f)
    (u : Lp E 1 (μ.withDensity fun x => f x)) : Memℒp (fun x => f x • u x) 1 μ :=
  memℒp_one_iff_integrable.2 <|
    (integrable_withDensity_iff_integrable_smul f_meas).1 <| memℒp_one_iff_integrable.1 (Lp.memℒp u)
#align measure_theory.mem_ℒ1_smul_of_L1_with_density MeasureTheory.memℒ1_smul_of_L1_withDensity
-/

variable (μ)

#print MeasureTheory.withDensitySMulLI /-
/-- The map `u ↦ f • u` is an isometry between the `L^1` spaces for `μ.with_density f` and `μ`. -/
noncomputable def withDensitySMulLI {f : α → ℝ≥0} (f_meas : Measurable f) :
    Lp E 1 (μ.withDensity fun x => f x) →ₗᵢ[ℝ] Lp E 1 μ
    where
  toFun u := (memℒ1_smul_of_L1_withDensity f_meas u).toLp _
  map_add' := by
    intro u v
    ext1
    filter_upwards [(mem_ℒ1_smul_of_L1_with_density f_meas u).coeFn_toLp,
      (mem_ℒ1_smul_of_L1_with_density f_meas v).coeFn_toLp,
      (mem_ℒ1_smul_of_L1_with_density f_meas (u + v)).coeFn_toLp,
      Lp.coe_fn_add ((mem_ℒ1_smul_of_L1_with_density f_meas u).toLp _)
        ((mem_ℒ1_smul_of_L1_with_density f_meas v).toLp _),
      (ae_with_density_iff f_meas.coe_nnreal_ennreal).1 (Lp.coe_fn_add u v)]
    intro x hu hv huv h' h''
    rw [huv, h', Pi.add_apply, hu, hv]
    rcases eq_or_ne (f x) 0 with (hx | hx)
    · simp only [hx, zero_smul, add_zero]
    · rw [h'' _, Pi.add_apply, smul_add]
      simpa only [Ne.def, ENNReal.coe_eq_zero] using hx
  map_smul' := by
    intro r u
    ext1
    filter_upwards [(ae_with_density_iff f_meas.coe_nnreal_ennreal).1 (Lp.coe_fn_smul r u),
      (mem_ℒ1_smul_of_L1_with_density f_meas (r • u)).coeFn_toLp,
      Lp.coe_fn_smul r ((mem_ℒ1_smul_of_L1_with_density f_meas u).toLp _),
      (mem_ℒ1_smul_of_L1_with_density f_meas u).coeFn_toLp]
    intro x h h' h'' h'''
    rw [RingHom.id_apply, h', h'', Pi.smul_apply, h''']
    rcases eq_or_ne (f x) 0 with (hx | hx)
    · simp only [hx, zero_smul, smul_zero]
    · rw [h _, smul_comm, Pi.smul_apply]
      simpa only [Ne.def, ENNReal.coe_eq_zero] using hx
  norm_map' := by
    intro u
    simp only [snorm, LinearMap.coe_mk, Lp.norm_to_Lp, one_ne_zero, ENNReal.one_ne_top,
      ENNReal.one_toReal, if_false, snorm', ENNReal.rpow_one, _root_.div_one, Lp.norm_def]
    rw [lintegral_with_density_eq_lintegral_mul_non_measurable _ f_meas.coe_nnreal_ennreal
        (Filter.eventually_of_forall fun x => ENNReal.coe_lt_top)]
    congr 1
    apply lintegral_congr_ae
    filter_upwards [(mem_ℒ1_smul_of_L1_with_density f_meas u).coeFn_toLp] with x hx
    rw [hx, Pi.mul_apply]
    change ↑‖(f x : ℝ) • u x‖₊ = ↑(f x) * ↑‖u x‖₊
    simp only [nnnorm_smul, NNReal.nnnorm_eq, ENNReal.coe_mul]
#align measure_theory.with_density_smul_li MeasureTheory.withDensitySMulLI
-/

#print MeasureTheory.withDensitySMulLI_apply /-
@[simp]
theorem withDensitySMulLI_apply {f : α → ℝ≥0} (f_meas : Measurable f)
    (u : Lp E 1 (μ.withDensity fun x => f x)) :
    withDensitySMulLI μ f_meas u =
      (memℒ1_smul_of_L1_withDensity f_meas u).toLp fun x => f x • u x :=
  rfl
#align measure_theory.with_density_smul_li_apply MeasureTheory.withDensitySMulLI_apply
-/

end

#print MeasureTheory.mem_ℒ1_toReal_of_lintegral_ne_top /-
theorem mem_ℒ1_toReal_of_lintegral_ne_top {f : α → ℝ≥0∞} (hfm : AEMeasurable f μ)
    (hfi : ∫⁻ x, f x ∂μ ≠ ∞) : Memℒp (fun x => (f x).toReal) 1 μ :=
  by
  rw [mem_ℒp, snorm_one_eq_lintegral_nnnorm]
  exact
    ⟨(AEMeasurable.ennreal_toReal hfm).AEStronglyMeasurable,
      has_finite_integral_to_real_of_lintegral_ne_top hfi⟩
#align measure_theory.mem_ℒ1_to_real_of_lintegral_ne_top MeasureTheory.mem_ℒ1_toReal_of_lintegral_ne_top
-/

#print MeasureTheory.integrable_toReal_of_lintegral_ne_top /-
theorem integrable_toReal_of_lintegral_ne_top {f : α → ℝ≥0∞} (hfm : AEMeasurable f μ)
    (hfi : ∫⁻ x, f x ∂μ ≠ ∞) : Integrable (fun x => (f x).toReal) μ :=
  memℒp_one_iff_integrable.1 <| mem_ℒ1_toReal_of_lintegral_ne_top hfm hfi
#align measure_theory.integrable_to_real_of_lintegral_ne_top MeasureTheory.integrable_toReal_of_lintegral_ne_top
-/

section PosPart

/-! ### Lemmas used for defining the positive part of a `L¹` function -/


#print MeasureTheory.Integrable.pos_part /-
theorem Integrable.pos_part {f : α → ℝ} (hf : Integrable f μ) :
    Integrable (fun a => max (f a) 0) μ :=
  ⟨(hf.AEStronglyMeasurable.AEMeasurable.max aemeasurable_const).AEStronglyMeasurable,
    hf.HasFiniteIntegral.max_zero⟩
#align measure_theory.integrable.pos_part MeasureTheory.Integrable.pos_part
-/

#print MeasureTheory.Integrable.neg_part /-
theorem Integrable.neg_part {f : α → ℝ} (hf : Integrable f μ) :
    Integrable (fun a => max (-f a) 0) μ :=
  hf.neg.posPart
#align measure_theory.integrable.neg_part MeasureTheory.Integrable.neg_part
-/

end PosPart

section BoundedSMul

variable {𝕜 : Type _}

#print MeasureTheory.Integrable.smul /-
theorem Integrable.smul [NormedAddCommGroup 𝕜] [SMulZeroClass 𝕜 β] [BoundedSMul 𝕜 β] (c : 𝕜)
    {f : α → β} (hf : Integrable f μ) : Integrable (c • f) μ :=
  ⟨hf.AEStronglyMeasurable.const_smul c, hf.HasFiniteIntegral.smul c⟩
#align measure_theory.integrable.smul MeasureTheory.Integrable.smul
-/

#print IsUnit.integrable_smul_iff /-
theorem IsUnit.integrable_smul_iff [NormedRing 𝕜] [Module 𝕜 β] [BoundedSMul 𝕜 β] {c : 𝕜}
    (hc : IsUnit c) (f : α → β) : Integrable (c • f) μ ↔ Integrable f μ :=
  and_congr hc.aestronglyMeasurable_const_smul_iff (hasFiniteIntegral_smul_iff hc f)
#align measure_theory.is_unit.integrable_smul_iff IsUnit.integrable_smul_iff
-/

#print MeasureTheory.integrable_smul_iff /-
theorem integrable_smul_iff [NormedDivisionRing 𝕜] [Module 𝕜 β] [BoundedSMul 𝕜 β] {c : 𝕜}
    (hc : c ≠ 0) (f : α → β) : Integrable (c • f) μ ↔ Integrable f μ :=
  (IsUnit.mk0 _ hc).integrable_smul_iff f
#align measure_theory.integrable_smul_iff MeasureTheory.integrable_smul_iff
-/

variable [NormedRing 𝕜] [Module 𝕜 β] [BoundedSMul 𝕜 β]

#print MeasureTheory.Integrable.smul_of_top_right /-
theorem Integrable.smul_of_top_right {f : α → β} {φ : α → 𝕜} (hf : Integrable f μ)
    (hφ : Memℒp φ ∞ μ) : Integrable (φ • f) μ := by rw [← mem_ℒp_one_iff_integrable] at hf ⊢;
  exact mem_ℒp.smul_of_top_right hf hφ
#align measure_theory.integrable.smul_of_top_right MeasureTheory.Integrable.smul_of_top_right
-/

#print MeasureTheory.Integrable.smul_of_top_left /-
theorem Integrable.smul_of_top_left {f : α → β} {φ : α → 𝕜} (hφ : Integrable φ μ)
    (hf : Memℒp f ∞ μ) : Integrable (φ • f) μ := by rw [← mem_ℒp_one_iff_integrable] at hφ ⊢;
  exact mem_ℒp.smul_of_top_left hf hφ
#align measure_theory.integrable.smul_of_top_left MeasureTheory.Integrable.smul_of_top_left
-/

#print MeasureTheory.Integrable.smul_const /-
theorem Integrable.smul_const {f : α → 𝕜} (hf : Integrable f μ) (c : β) :
    Integrable (fun x => f x • c) μ :=
  hf.smul_of_top_left (memℒp_top_const c)
#align measure_theory.integrable.smul_const MeasureTheory.Integrable.smul_const
-/

end BoundedSMul

section NormedSpaceOverCompleteField

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] [CompleteSpace 𝕜]

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

#print MeasureTheory.integrable_smul_const /-
theorem integrable_smul_const {f : α → 𝕜} {c : E} (hc : c ≠ 0) :
    Integrable (fun x => f x • c) μ ↔ Integrable f μ :=
  by
  simp_rw [integrable, aestronglyMeasurable_smul_const_iff hc, and_congr_right_iff,
    has_finite_integral, nnnorm_smul, ENNReal.coe_mul]
  intro hf; rw [lintegral_mul_const' _ _ ENNReal.coe_ne_top, ENNReal.mul_lt_top_iff]
  have : ∀ x : ℝ≥0∞, x = 0 → x < ∞ := by simp
  simp [hc, or_iff_left_of_imp (this _)]
#align measure_theory.integrable_smul_const MeasureTheory.integrable_smul_const
-/

end NormedSpaceOverCompleteField

section NormedRing

variable {𝕜 : Type _} [NormedRing 𝕜] {f : α → 𝕜}

#print MeasureTheory.Integrable.const_mul /-
theorem Integrable.const_mul {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable (fun x => c * f x) μ :=
  h.smul c
#align measure_theory.integrable.const_mul MeasureTheory.Integrable.const_mul
-/

#print MeasureTheory.Integrable.const_mul' /-
theorem Integrable.const_mul' {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable ((fun x : α => c) * f) μ :=
  Integrable.const_mul h c
#align measure_theory.integrable.const_mul' MeasureTheory.Integrable.const_mul'
-/

#print MeasureTheory.Integrable.mul_const /-
theorem Integrable.mul_const {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable (fun x => f x * c) μ :=
  h.smul (MulOpposite.op c)
#align measure_theory.integrable.mul_const MeasureTheory.Integrable.mul_const
-/

#print MeasureTheory.Integrable.mul_const' /-
theorem Integrable.mul_const' {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable (f * fun x : α => c) μ :=
  Integrable.mul_const h c
#align measure_theory.integrable.mul_const' MeasureTheory.Integrable.mul_const'
-/

#print MeasureTheory.integrable_const_mul_iff /-
theorem integrable_const_mul_iff {c : 𝕜} (hc : IsUnit c) (f : α → 𝕜) :
    Integrable (fun x => c * f x) μ ↔ Integrable f μ :=
  hc.integrable_smul_iff f
#align measure_theory.integrable_const_mul_iff MeasureTheory.integrable_const_mul_iff
-/

#print MeasureTheory.integrable_mul_const_iff /-
theorem integrable_mul_const_iff {c : 𝕜} (hc : IsUnit c) (f : α → 𝕜) :
    Integrable (fun x => f x * c) μ ↔ Integrable f μ :=
  hc.op.integrable_smul_iff f
#align measure_theory.integrable_mul_const_iff MeasureTheory.integrable_mul_const_iff
-/

#print MeasureTheory.Integrable.bdd_mul' /-
theorem Integrable.bdd_mul' {f g : α → 𝕜} {c : ℝ} (hg : Integrable g μ)
    (hf : AEStronglyMeasurable f μ) (hf_bound : ∀ᵐ x ∂μ, ‖f x‖ ≤ c) :
    Integrable (fun x => f x * g x) μ :=
  by
  refine' integrable.mono' (hg.norm.smul c) (hf.mul hg.1) _
  filter_upwards [hf_bound] with x hx
  rw [Pi.smul_apply, smul_eq_mul]
  exact (norm_mul_le _ _).trans (mul_le_mul_of_nonneg_right hx (norm_nonneg _))
#align measure_theory.integrable.bdd_mul' MeasureTheory.Integrable.bdd_mul'
-/

end NormedRing

section NormedDivisionRing

variable {𝕜 : Type _} [NormedDivisionRing 𝕜] {f : α → 𝕜}

#print MeasureTheory.Integrable.div_const /-
theorem Integrable.div_const {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable (fun x => f x / c) μ := by simp_rw [div_eq_mul_inv, h.mul_const]
#align measure_theory.integrable.div_const MeasureTheory.Integrable.div_const
-/

end NormedDivisionRing

section IsROrC

variable {𝕜 : Type _} [IsROrC 𝕜] {f : α → 𝕜}

#print MeasureTheory.Integrable.ofReal /-
theorem Integrable.ofReal {f : α → ℝ} (hf : Integrable f μ) : Integrable (fun x => (f x : 𝕜)) μ :=
  by rw [← mem_ℒp_one_iff_integrable] at hf ⊢; exact hf.of_real
#align measure_theory.integrable.of_real MeasureTheory.Integrable.ofReal
-/

#print MeasureTheory.Integrable.re_im_iff /-
theorem Integrable.re_im_iff :
    Integrable (fun x => IsROrC.re (f x)) μ ∧ Integrable (fun x => IsROrC.im (f x)) μ ↔
      Integrable f μ :=
  by simp_rw [← mem_ℒp_one_iff_integrable]; exact mem_ℒp_re_im_iff
#align measure_theory.integrable.re_im_iff MeasureTheory.Integrable.re_im_iff
-/

#print MeasureTheory.Integrable.re /-
theorem Integrable.re (hf : Integrable f μ) : Integrable (fun x => IsROrC.re (f x)) μ := by
  rw [← mem_ℒp_one_iff_integrable] at hf ⊢; exact hf.re
#align measure_theory.integrable.re MeasureTheory.Integrable.re
-/

#print MeasureTheory.Integrable.im /-
theorem Integrable.im (hf : Integrable f μ) : Integrable (fun x => IsROrC.im (f x)) μ := by
  rw [← mem_ℒp_one_iff_integrable] at hf ⊢; exact hf.im
#align measure_theory.integrable.im MeasureTheory.Integrable.im
-/

end IsROrC

section Trim

variable {H : Type _} [NormedAddCommGroup H] {m0 : MeasurableSpace α} {μ' : Measure α} {f : α → H}

#print MeasureTheory.Integrable.trim /-
theorem Integrable.trim (hm : m ≤ m0) (hf_int : Integrable f μ') (hf : strongly_measurable[m] f) :
    Integrable f (μ'.trim hm) :=
  by
  refine' ⟨hf.ae_strongly_measurable, _⟩
  rw [has_finite_integral, lintegral_trim hm _]
  · exact hf_int.2
  · exact @strongly_measurable.ennnorm _ m _ _ f hf
#align measure_theory.integrable.trim MeasureTheory.Integrable.trim
-/

#print MeasureTheory.integrable_of_integrable_trim /-
theorem integrable_of_integrable_trim (hm : m ≤ m0) (hf_int : Integrable f (μ'.trim hm)) :
    Integrable f μ' := by
  obtain ⟨hf_meas_ae, hf⟩ := hf_int
  refine' ⟨aestronglyMeasurable_of_aestronglyMeasurable_trim hm hf_meas_ae, _⟩
  rw [has_finite_integral] at hf ⊢
  rwa [lintegral_trim_ae hm _] at hf 
  exact ae_strongly_measurable.ennnorm hf_meas_ae
#align measure_theory.integrable_of_integrable_trim MeasureTheory.integrable_of_integrable_trim
-/

end Trim

section SigmaFinite

variable {E : Type _} {m0 : MeasurableSpace α} [NormedAddCommGroup E]

#print MeasureTheory.integrable_of_forall_fin_meas_le' /-
theorem integrable_of_forall_fin_meas_le' {μ : Measure α} (hm : m ≤ m0) [SigmaFinite (μ.trim hm)]
    (C : ℝ≥0∞) (hC : C < ∞) {f : α → E} (hf_meas : AEStronglyMeasurable f μ)
    (hf : ∀ s, measurable_set[m] s → μ s ≠ ∞ → ∫⁻ x in s, ‖f x‖₊ ∂μ ≤ C) : Integrable f μ :=
  ⟨hf_meas, (lintegral_le_of_forall_fin_meas_le' hm C hf_meas.ennnorm hf).trans_lt hC⟩
#align measure_theory.integrable_of_forall_fin_meas_le' MeasureTheory.integrable_of_forall_fin_meas_le'
-/

#print MeasureTheory.integrable_of_forall_fin_meas_le /-
theorem integrable_of_forall_fin_meas_le [SigmaFinite μ] (C : ℝ≥0∞) (hC : C < ∞) {f : α → E}
    (hf_meas : AEStronglyMeasurable f μ)
    (hf : ∀ s : Set α, MeasurableSet s → μ s ≠ ∞ → ∫⁻ x in s, ‖f x‖₊ ∂μ ≤ C) : Integrable f μ :=
  @integrable_of_forall_fin_meas_le' _ _ _ _ _ _ _ (by rwa [trim_eq_self]) C hC _ hf_meas hf
#align measure_theory.integrable_of_forall_fin_meas_le MeasureTheory.integrable_of_forall_fin_meas_le
-/

end SigmaFinite

/-! ### The predicate `integrable` on measurable functions modulo a.e.-equality -/


namespace AeEqFun

section

#print MeasureTheory.AEEqFun.Integrable /-
/-- A class of almost everywhere equal functions is `integrable` if its function representative
is integrable. -/
def Integrable (f : α →ₘ[μ] β) : Prop :=
  Integrable f μ
#align measure_theory.ae_eq_fun.integrable MeasureTheory.AEEqFun.Integrable
-/

#print MeasureTheory.AEEqFun.integrable_mk /-
theorem integrable_mk {f : α → β} (hf : AEStronglyMeasurable f μ) :
    Integrable (mk f hf : α →ₘ[μ] β) ↔ MeasureTheory.Integrable f μ :=
  by
  simp [integrable]
  apply integrable_congr
  exact coe_fn_mk f hf
#align measure_theory.ae_eq_fun.integrable_mk MeasureTheory.AEEqFun.integrable_mk
-/

#print MeasureTheory.AEEqFun.integrable_coeFn /-
theorem integrable_coeFn {f : α →ₘ[μ] β} : MeasureTheory.Integrable f μ ↔ Integrable f := by
  rw [← integrable_mk, mk_coe_fn]
#align measure_theory.ae_eq_fun.integrable_coe_fn MeasureTheory.AEEqFun.integrable_coeFn
-/

#print MeasureTheory.AEEqFun.integrable_zero /-
theorem integrable_zero : Integrable (0 : α →ₘ[μ] β) :=
  (integrable_zero α β μ).congr (coeFn_mk _ _).symm
#align measure_theory.ae_eq_fun.integrable_zero MeasureTheory.AEEqFun.integrable_zero
-/

end

section

#print MeasureTheory.AEEqFun.Integrable.neg /-
theorem Integrable.neg {f : α →ₘ[μ] β} : Integrable f → Integrable (-f) :=
  induction_on f fun f hfm hfi => (integrable_mk _).2 ((integrable_mk hfm).1 hfi).neg
#align measure_theory.ae_eq_fun.integrable.neg MeasureTheory.AEEqFun.Integrable.neg
-/

section

#print MeasureTheory.AEEqFun.integrable_iff_mem_L1 /-
theorem integrable_iff_mem_L1 {f : α →ₘ[μ] β} : Integrable f ↔ f ∈ (α →₁[μ] β) := by
  rw [← integrable_coe_fn, ← mem_ℒp_one_iff_integrable, Lp.mem_Lp_iff_mem_ℒp]
#align measure_theory.ae_eq_fun.integrable_iff_mem_L1 MeasureTheory.AEEqFun.integrable_iff_mem_L1
-/

#print MeasureTheory.AEEqFun.Integrable.add /-
theorem Integrable.add {f g : α →ₘ[μ] β} : Integrable f → Integrable g → Integrable (f + g) :=
  by
  refine' induction_on₂ f g fun f hf g hg hfi hgi => _
  simp only [integrable_mk, mk_add_mk] at hfi hgi ⊢
  exact hfi.add hgi
#align measure_theory.ae_eq_fun.integrable.add MeasureTheory.AEEqFun.Integrable.add
-/

#print MeasureTheory.AEEqFun.Integrable.sub /-
theorem Integrable.sub {f g : α →ₘ[μ] β} (hf : Integrable f) (hg : Integrable g) :
    Integrable (f - g) :=
  (sub_eq_add_neg f g).symm ▸ hf.add hg.neg
#align measure_theory.ae_eq_fun.integrable.sub MeasureTheory.AEEqFun.Integrable.sub
-/

end

section BoundedSMul

variable {𝕜 : Type _} [NormedRing 𝕜] [Module 𝕜 β] [BoundedSMul 𝕜 β]

#print MeasureTheory.AEEqFun.Integrable.smul /-
theorem Integrable.smul {c : 𝕜} {f : α →ₘ[μ] β} : Integrable f → Integrable (c • f) :=
  induction_on f fun f hfm hfi => (integrable_mk _).2 <| ((integrable_mk hfm).1 hfi).smul _
#align measure_theory.ae_eq_fun.integrable.smul MeasureTheory.AEEqFun.Integrable.smul
-/

end BoundedSMul

end

end AeEqFun

namespace L1

#print MeasureTheory.L1.integrable_coeFn /-
theorem integrable_coeFn (f : α →₁[μ] β) : Integrable f μ := by rw [← mem_ℒp_one_iff_integrable];
  exact Lp.mem_ℒp f
#align measure_theory.L1.integrable_coe_fn MeasureTheory.L1.integrable_coeFn
-/

#print MeasureTheory.L1.hasFiniteIntegral_coeFn /-
theorem hasFiniteIntegral_coeFn (f : α →₁[μ] β) : HasFiniteIntegral f μ :=
  (integrable_coeFn f).HasFiniteIntegral
#align measure_theory.L1.has_finite_integral_coe_fn MeasureTheory.L1.hasFiniteIntegral_coeFn
-/

#print MeasureTheory.L1.stronglyMeasurable_coeFn /-
theorem stronglyMeasurable_coeFn (f : α →₁[μ] β) : StronglyMeasurable f :=
  Lp.stronglyMeasurable f
#align measure_theory.L1.strongly_measurable_coe_fn MeasureTheory.L1.stronglyMeasurable_coeFn
-/

#print MeasureTheory.L1.measurable_coeFn /-
theorem measurable_coeFn [MeasurableSpace β] [BorelSpace β] (f : α →₁[μ] β) : Measurable f :=
  (Lp.stronglyMeasurable f).Measurable
#align measure_theory.L1.measurable_coe_fn MeasureTheory.L1.measurable_coeFn
-/

#print MeasureTheory.L1.aestronglyMeasurable_coeFn /-
theorem aestronglyMeasurable_coeFn (f : α →₁[μ] β) : AEStronglyMeasurable f μ :=
  Lp.aestronglyMeasurable f
#align measure_theory.L1.ae_strongly_measurable_coe_fn MeasureTheory.L1.aestronglyMeasurable_coeFn
-/

#print MeasureTheory.L1.aemeasurable_coeFn /-
theorem aemeasurable_coeFn [MeasurableSpace β] [BorelSpace β] (f : α →₁[μ] β) : AEMeasurable f μ :=
  (Lp.stronglyMeasurable f).Measurable.AEMeasurable
#align measure_theory.L1.ae_measurable_coe_fn MeasureTheory.L1.aemeasurable_coeFn
-/

#print MeasureTheory.L1.edist_def /-
theorem edist_def (f g : α →₁[μ] β) : edist f g = ∫⁻ a, edist (f a) (g a) ∂μ := by
  simp [Lp.edist_def, snorm, snorm']; simp [edist_eq_coe_nnnorm_sub]
#align measure_theory.L1.edist_def MeasureTheory.L1.edist_def
-/

#print MeasureTheory.L1.dist_def /-
theorem dist_def (f g : α →₁[μ] β) : dist f g = (∫⁻ a, edist (f a) (g a) ∂μ).toReal := by
  simp [Lp.dist_def, snorm, snorm']; simp [edist_eq_coe_nnnorm_sub]
#align measure_theory.L1.dist_def MeasureTheory.L1.dist_def
-/

#print MeasureTheory.L1.norm_def /-
theorem norm_def (f : α →₁[μ] β) : ‖f‖ = (∫⁻ a, ‖f a‖₊ ∂μ).toReal := by
  simp [Lp.norm_def, snorm, snorm']
#align measure_theory.L1.norm_def MeasureTheory.L1.norm_def
-/

#print MeasureTheory.L1.norm_sub_eq_lintegral /-
/-- Computing the norm of a difference between two L¹-functions. Note that this is not a
  special case of `norm_def` since `(f - g) x` and `f x - g x` are not equal
  (but only a.e.-equal). -/
theorem norm_sub_eq_lintegral (f g : α →₁[μ] β) :
    ‖f - g‖ = (∫⁻ x, (‖f x - g x‖₊ : ℝ≥0∞) ∂μ).toReal :=
  by
  rw [norm_def]
  congr 1
  rw [lintegral_congr_ae]
  filter_upwards [Lp.coe_fn_sub f g] with _ ha
  simp only [ha, Pi.sub_apply]
#align measure_theory.L1.norm_sub_eq_lintegral MeasureTheory.L1.norm_sub_eq_lintegral
-/

#print MeasureTheory.L1.ofReal_norm_eq_lintegral /-
theorem ofReal_norm_eq_lintegral (f : α →₁[μ] β) : ENNReal.ofReal ‖f‖ = ∫⁻ x, (‖f x‖₊ : ℝ≥0∞) ∂μ :=
  by rw [norm_def, ENNReal.ofReal_toReal]; exact ne_of_lt (has_finite_integral_coe_fn f)
#align measure_theory.L1.of_real_norm_eq_lintegral MeasureTheory.L1.ofReal_norm_eq_lintegral
-/

#print MeasureTheory.L1.ofReal_norm_sub_eq_lintegral /-
/-- Computing the norm of a difference between two L¹-functions. Note that this is not a
  special case of `of_real_norm_eq_lintegral` since `(f - g) x` and `f x - g x` are not equal
  (but only a.e.-equal). -/
theorem ofReal_norm_sub_eq_lintegral (f g : α →₁[μ] β) :
    ENNReal.ofReal ‖f - g‖ = ∫⁻ x, (‖f x - g x‖₊ : ℝ≥0∞) ∂μ :=
  by
  simp_rw [of_real_norm_eq_lintegral, ← edist_eq_coe_nnnorm]
  apply lintegral_congr_ae
  filter_upwards [Lp.coe_fn_sub f g] with _ ha
  simp only [ha, Pi.sub_apply]
#align measure_theory.L1.of_real_norm_sub_eq_lintegral MeasureTheory.L1.ofReal_norm_sub_eq_lintegral
-/

end L1

namespace Integrable

#print MeasureTheory.Integrable.toL1 /-
/-- Construct the equivalence class `[f]` of an integrable function `f`, as a member of the
space `L1 β 1 μ`. -/
def toL1 (f : α → β) (hf : Integrable f μ) : α →₁[μ] β :=
  (memℒp_one_iff_integrable.2 hf).toLp f
#align measure_theory.integrable.to_L1 MeasureTheory.Integrable.toL1
-/

#print MeasureTheory.Integrable.toL1_coeFn /-
@[simp]
theorem toL1_coeFn (f : α →₁[μ] β) (hf : Integrable f μ) : hf.toL1 f = f := by
  simp [integrable.to_L1]
#align measure_theory.integrable.to_L1_coe_fn MeasureTheory.Integrable.toL1_coeFn
-/

#print MeasureTheory.Integrable.coeFn_toL1 /-
theorem coeFn_toL1 {f : α → β} (hf : Integrable f μ) : hf.toL1 f =ᵐ[μ] f :=
  AEEqFun.coeFn_mk _ _
#align measure_theory.integrable.coe_fn_to_L1 MeasureTheory.Integrable.coeFn_toL1
-/

#print MeasureTheory.Integrable.toL1_zero /-
@[simp]
theorem toL1_zero (h : Integrable (0 : α → β) μ) : h.toL1 0 = 0 :=
  rfl
#align measure_theory.integrable.to_L1_zero MeasureTheory.Integrable.toL1_zero
-/

#print MeasureTheory.Integrable.toL1_eq_mk /-
@[simp]
theorem toL1_eq_mk (f : α → β) (hf : Integrable f μ) :
    (hf.toL1 f : α →ₘ[μ] β) = AEEqFun.mk f hf.AEStronglyMeasurable :=
  rfl
#align measure_theory.integrable.to_L1_eq_mk MeasureTheory.Integrable.toL1_eq_mk
-/

#print MeasureTheory.Integrable.toL1_eq_toL1_iff /-
@[simp]
theorem toL1_eq_toL1_iff (f g : α → β) (hf : Integrable f μ) (hg : Integrable g μ) :
    toL1 f hf = toL1 g hg ↔ f =ᵐ[μ] g :=
  Memℒp.toLp_eq_toLp_iff _ _
#align measure_theory.integrable.to_L1_eq_to_L1_iff MeasureTheory.Integrable.toL1_eq_toL1_iff
-/

#print MeasureTheory.Integrable.toL1_add /-
theorem toL1_add (f g : α → β) (hf : Integrable f μ) (hg : Integrable g μ) :
    toL1 (f + g) (hf.add hg) = toL1 f hf + toL1 g hg :=
  rfl
#align measure_theory.integrable.to_L1_add MeasureTheory.Integrable.toL1_add
-/

#print MeasureTheory.Integrable.toL1_neg /-
theorem toL1_neg (f : α → β) (hf : Integrable f μ) : toL1 (-f) (Integrable.neg hf) = -toL1 f hf :=
  rfl
#align measure_theory.integrable.to_L1_neg MeasureTheory.Integrable.toL1_neg
-/

#print MeasureTheory.Integrable.toL1_sub /-
theorem toL1_sub (f g : α → β) (hf : Integrable f μ) (hg : Integrable g μ) :
    toL1 (f - g) (hf.sub hg) = toL1 f hf - toL1 g hg :=
  rfl
#align measure_theory.integrable.to_L1_sub MeasureTheory.Integrable.toL1_sub
-/

#print MeasureTheory.Integrable.norm_toL1 /-
theorem norm_toL1 (f : α → β) (hf : Integrable f μ) :
    ‖hf.toL1 f‖ = ENNReal.toReal (∫⁻ a, edist (f a) 0 ∂μ) := by simp [to_L1, snorm, snorm'];
  simp [edist_eq_coe_nnnorm]
#align measure_theory.integrable.norm_to_L1 MeasureTheory.Integrable.norm_toL1
-/

#print MeasureTheory.Integrable.norm_toL1_eq_lintegral_norm /-
theorem norm_toL1_eq_lintegral_norm (f : α → β) (hf : Integrable f μ) :
    ‖hf.toL1 f‖ = ENNReal.toReal (∫⁻ a, ENNReal.ofReal ‖f a‖ ∂μ) := by
  rw [norm_to_L1, lintegral_norm_eq_lintegral_edist]
#align measure_theory.integrable.norm_to_L1_eq_lintegral_norm MeasureTheory.Integrable.norm_toL1_eq_lintegral_norm
-/

#print MeasureTheory.Integrable.edist_toL1_toL1 /-
@[simp]
theorem edist_toL1_toL1 (f g : α → β) (hf : Integrable f μ) (hg : Integrable g μ) :
    edist (hf.toL1 f) (hg.toL1 g) = ∫⁻ a, edist (f a) (g a) ∂μ := by
  simp [integrable.to_L1, snorm, snorm']; simp [edist_eq_coe_nnnorm_sub]
#align measure_theory.integrable.edist_to_L1_to_L1 MeasureTheory.Integrable.edist_toL1_toL1
-/

#print MeasureTheory.Integrable.edist_toL1_zero /-
@[simp]
theorem edist_toL1_zero (f : α → β) (hf : Integrable f μ) :
    edist (hf.toL1 f) 0 = ∫⁻ a, edist (f a) 0 ∂μ := by simp [integrable.to_L1, snorm, snorm'];
  simp [edist_eq_coe_nnnorm]
#align measure_theory.integrable.edist_to_L1_zero MeasureTheory.Integrable.edist_toL1_zero
-/

variable {𝕜 : Type _} [NormedRing 𝕜] [Module 𝕜 β] [BoundedSMul 𝕜 β]

#print MeasureTheory.Integrable.toL1_smul /-
theorem toL1_smul (f : α → β) (hf : Integrable f μ) (k : 𝕜) :
    toL1 (fun a => k • f a) (hf.smul k) = k • toL1 f hf :=
  rfl
#align measure_theory.integrable.to_L1_smul MeasureTheory.Integrable.toL1_smul
-/

#print MeasureTheory.Integrable.toL1_smul' /-
theorem toL1_smul' (f : α → β) (hf : Integrable f μ) (k : 𝕜) :
    toL1 (k • f) (hf.smul k) = k • toL1 f hf :=
  rfl
#align measure_theory.integrable.to_L1_smul' MeasureTheory.Integrable.toL1_smul'
-/

end Integrable

end MeasureTheory

open MeasureTheory

variable {E : Type _} [NormedAddCommGroup E] {𝕜 : Type _} [NontriviallyNormedField 𝕜]
  [NormedSpace 𝕜 E] {H : Type _} [NormedAddCommGroup H] [NormedSpace 𝕜 H]

#print MeasureTheory.Integrable.apply_continuousLinearMap /-
theorem MeasureTheory.Integrable.apply_continuousLinearMap {φ : α → H →L[𝕜] E}
    (φ_int : Integrable φ μ) (v : H) : Integrable (fun a => φ a v) μ :=
  (φ_int.norm.mul_const ‖v‖).mono' (φ_int.AEStronglyMeasurable.apply_continuousLinearMap v)
    (eventually_of_forall fun a => (φ a).le_opNorm v)
#align measure_theory.integrable.apply_continuous_linear_map MeasureTheory.Integrable.apply_continuousLinearMap
-/

#print ContinuousLinearMap.integrable_comp /-
theorem ContinuousLinearMap.integrable_comp {φ : α → H} (L : H →L[𝕜] E) (φ_int : Integrable φ μ) :
    Integrable (fun a : α => L (φ a)) μ :=
  ((Integrable.norm φ_int).const_mul ‖L‖).mono'
    (L.Continuous.comp_aestronglyMeasurable φ_int.AEStronglyMeasurable)
    (eventually_of_forall fun a => L.le_opNorm (φ a))
#align continuous_linear_map.integrable_comp ContinuousLinearMap.integrable_comp
-/

