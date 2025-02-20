/-
Copyright (c) 2020 James Arthur. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: James Arthur, Chris Hughes, Shing Tak Lam

! This file was ported from Lean 3 source module analysis.special_functions.arsinh
! leanprover-community/mathlib commit 36938f775671ff28bea1c0310f1608e4afbb22e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Trigonometric.Deriv
import Mathbin.Analysis.SpecialFunctions.Log.Basic

/-!
# Inverse of the sinh function

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that sinh is bijective and hence has an
inverse, arsinh.

## Main definitions

- `real.arsinh`: The inverse function of `real.sinh`.

- `real.sinh_equiv`, `real.sinh_order_iso`, `real.sinh_homeomorph`: `real.sinh` as an `equiv`,
  `order_iso`, and `homeomorph`, respectively.

## Main Results

- `real.sinh_surjective`, `real.sinh_bijective`: `real.sinh` is surjective and bijective;

- `real.arsinh_injective`, `real.arsinh_surjective`, `real.arsinh_bijective`: `real.arsinh` is
  injective, surjective, and bijective;

- `real.continuous_arsinh`, `real.differentiable_arsinh`, `real.cont_diff_arsinh`: `real.arsinh` is
  continuous, differentiable, and continuously differentiable; we also provide dot notation
  convenience lemmas like `filter.tendsto.arsinh` and `cont_diff_at.arsinh`.

## Tags

arsinh, arcsinh, argsinh, asinh, sinh injective, sinh bijective, sinh surjective
-/


noncomputable section

open Function Filter Set

open scoped Topology

namespace Real

variable {x y : ℝ}

#print Real.arsinh /-
/-- `arsinh` is defined using a logarithm, `arsinh x = log (x + sqrt(1 + x^2))`. -/
@[pp_nodot]
def arsinh (x : ℝ) :=
  log (x + sqrt (1 + x ^ 2))
#align real.arsinh Real.arsinh
-/

#print Real.exp_arsinh /-
theorem exp_arsinh (x : ℝ) : exp (arsinh x) = x + sqrt (1 + x ^ 2) :=
  by
  apply exp_log
  rw [← neg_lt_iff_pos_add']
  calc
    -x ≤ sqrt (x ^ 2) := le_sqrt_of_sq_le (neg_pow_bit0 _ _).le
    _ < sqrt (1 + x ^ 2) := sqrt_lt_sqrt (sq_nonneg _) (lt_one_add _)
#align real.exp_arsinh Real.exp_arsinh
-/

#print Real.arsinh_zero /-
@[simp]
theorem arsinh_zero : arsinh 0 = 0 := by simp [arsinh]
#align real.arsinh_zero Real.arsinh_zero
-/

#print Real.arsinh_neg /-
@[simp]
theorem arsinh_neg (x : ℝ) : arsinh (-x) = -arsinh x :=
  by
  rw [← exp_eq_exp, exp_arsinh, exp_neg, exp_arsinh]
  apply eq_inv_of_mul_eq_one_left
  rw [neg_sq, neg_add_eq_sub, add_comm x, mul_comm, ← sq_sub_sq, sq_sqrt, add_sub_cancel]
  exact add_nonneg zero_le_one (sq_nonneg _)
#align real.arsinh_neg Real.arsinh_neg
-/

#print Real.sinh_arsinh /-
/-- `arsinh` is the right inverse of `sinh`. -/
@[simp]
theorem sinh_arsinh (x : ℝ) : sinh (arsinh x) = x := by
  rw [sinh_eq, ← arsinh_neg, exp_arsinh, exp_arsinh, neg_sq]; field_simp
#align real.sinh_arsinh Real.sinh_arsinh
-/

#print Real.cosh_arsinh /-
@[simp]
theorem cosh_arsinh (x : ℝ) : cosh (arsinh x) = sqrt (1 + x ^ 2) := by
  rw [← sqrt_sq (cosh_pos _).le, cosh_sq', sinh_arsinh]
#align real.cosh_arsinh Real.cosh_arsinh
-/

#print Real.sinh_surjective /-
/-- `sinh` is surjective, `∀ b, ∃ a, sinh a = b`. In this case, we use `a = arsinh b`. -/
theorem sinh_surjective : Surjective sinh :=
  LeftInverse.surjective sinh_arsinh
#align real.sinh_surjective Real.sinh_surjective
-/

#print Real.sinh_bijective /-
/-- `sinh` is bijective, both injective and surjective. -/
theorem sinh_bijective : Bijective sinh :=
  ⟨sinh_injective, sinh_surjective⟩
#align real.sinh_bijective Real.sinh_bijective
-/

#print Real.arsinh_sinh /-
/-- `arsinh` is the left inverse of `sinh`. -/
@[simp]
theorem arsinh_sinh (x : ℝ) : arsinh (sinh x) = x :=
  rightInverse_of_injective_of_leftInverse sinh_injective sinh_arsinh x
#align real.arsinh_sinh Real.arsinh_sinh
-/

#print Real.sinhEquiv /-
/-- `real.sinh` as an `equiv`. -/
@[simps]
def sinhEquiv : ℝ ≃ ℝ where
  toFun := sinh
  invFun := arsinh
  left_inv := arsinh_sinh
  right_inv := sinh_arsinh
#align real.sinh_equiv Real.sinhEquiv
-/

#print Real.sinhOrderIso /-
/-- `real.sinh` as an `order_iso`. -/
@[simps (config := { fullyApplied := false })]
def sinhOrderIso : ℝ ≃o ℝ where
  toEquiv := sinhEquiv
  map_rel_iff' := @sinh_le_sinh
#align real.sinh_order_iso Real.sinhOrderIso
-/

#print Real.sinhHomeomorph /-
/-- `real.sinh` as a `homeomorph`. -/
@[simps (config := { fullyApplied := false })]
def sinhHomeomorph : ℝ ≃ₜ ℝ :=
  sinhOrderIso.toHomeomorph
#align real.sinh_homeomorph Real.sinhHomeomorph
-/

#print Real.arsinh_bijective /-
theorem arsinh_bijective : Bijective arsinh :=
  sinhEquiv.symm.Bijective
#align real.arsinh_bijective Real.arsinh_bijective
-/

#print Real.arsinh_injective /-
theorem arsinh_injective : Injective arsinh :=
  sinhEquiv.symm.Injective
#align real.arsinh_injective Real.arsinh_injective
-/

#print Real.arsinh_surjective /-
theorem arsinh_surjective : Surjective arsinh :=
  sinhEquiv.symm.Surjective
#align real.arsinh_surjective Real.arsinh_surjective
-/

#print Real.arsinh_strictMono /-
theorem arsinh_strictMono : StrictMono arsinh :=
  sinhOrderIso.symm.StrictMono
#align real.arsinh_strict_mono Real.arsinh_strictMono
-/

#print Real.arsinh_inj /-
@[simp]
theorem arsinh_inj : arsinh x = arsinh y ↔ x = y :=
  arsinh_injective.eq_iff
#align real.arsinh_inj Real.arsinh_inj
-/

#print Real.arsinh_le_arsinh /-
@[simp]
theorem arsinh_le_arsinh : arsinh x ≤ arsinh y ↔ x ≤ y :=
  sinhOrderIso.symm.le_iff_le
#align real.arsinh_le_arsinh Real.arsinh_le_arsinh
-/

#print Real.arsinh_lt_arsinh /-
@[simp]
theorem arsinh_lt_arsinh : arsinh x < arsinh y ↔ x < y :=
  sinhOrderIso.symm.lt_iff_lt
#align real.arsinh_lt_arsinh Real.arsinh_lt_arsinh
-/

#print Real.arsinh_eq_zero_iff /-
@[simp]
theorem arsinh_eq_zero_iff : arsinh x = 0 ↔ x = 0 :=
  arsinh_injective.eq_iff' arsinh_zero
#align real.arsinh_eq_zero_iff Real.arsinh_eq_zero_iff
-/

#print Real.arsinh_nonneg_iff /-
@[simp]
theorem arsinh_nonneg_iff : 0 ≤ arsinh x ↔ 0 ≤ x := by rw [← sinh_le_sinh, sinh_zero, sinh_arsinh]
#align real.arsinh_nonneg_iff Real.arsinh_nonneg_iff
-/

#print Real.arsinh_nonpos_iff /-
@[simp]
theorem arsinh_nonpos_iff : arsinh x ≤ 0 ↔ x ≤ 0 := by rw [← sinh_le_sinh, sinh_zero, sinh_arsinh]
#align real.arsinh_nonpos_iff Real.arsinh_nonpos_iff
-/

#print Real.arsinh_pos_iff /-
@[simp]
theorem arsinh_pos_iff : 0 < arsinh x ↔ 0 < x :=
  lt_iff_lt_of_le_iff_le arsinh_nonpos_iff
#align real.arsinh_pos_iff Real.arsinh_pos_iff
-/

#print Real.arsinh_neg_iff /-
@[simp]
theorem arsinh_neg_iff : arsinh x < 0 ↔ x < 0 :=
  lt_iff_lt_of_le_iff_le arsinh_nonneg_iff
#align real.arsinh_neg_iff Real.arsinh_neg_iff
-/

#print Real.hasStrictDerivAt_arsinh /-
theorem hasStrictDerivAt_arsinh (x : ℝ) : HasStrictDerivAt arsinh (sqrt (1 + x ^ 2))⁻¹ x :=
  by
  convert
    sinh_homeomorph.to_local_homeomorph.has_strict_deriv_at_symm (mem_univ x) (cosh_pos _).ne'
      (has_strict_deriv_at_sinh _)
  exact (cosh_arsinh _).symm
#align real.has_strict_deriv_at_arsinh Real.hasStrictDerivAt_arsinh
-/

#print Real.hasDerivAt_arsinh /-
theorem hasDerivAt_arsinh (x : ℝ) : HasDerivAt arsinh (sqrt (1 + x ^ 2))⁻¹ x :=
  (hasStrictDerivAt_arsinh x).HasDerivAt
#align real.has_deriv_at_arsinh Real.hasDerivAt_arsinh
-/

#print Real.differentiable_arsinh /-
theorem differentiable_arsinh : Differentiable ℝ arsinh := fun x =>
  (hasDerivAt_arsinh x).DifferentiableAt
#align real.differentiable_arsinh Real.differentiable_arsinh
-/

#print Real.contDiff_arsinh /-
theorem contDiff_arsinh {n : ℕ∞} : ContDiff ℝ n arsinh :=
  sinhHomeomorph.contDiff_symm_deriv (fun x => (cosh_pos x).ne') hasDerivAt_sinh contDiff_sinh
#align real.cont_diff_arsinh Real.contDiff_arsinh
-/

#print Real.continuous_arsinh /-
@[continuity]
theorem continuous_arsinh : Continuous arsinh :=
  sinhHomeomorph.symm.Continuous
#align real.continuous_arsinh Real.continuous_arsinh
-/

end Real

open Real

#print Filter.Tendsto.arsinh /-
theorem Filter.Tendsto.arsinh {α : Type _} {l : Filter α} {f : α → ℝ} {a : ℝ}
    (h : Tendsto f l (𝓝 a)) : Tendsto (fun x => arsinh (f x)) l (𝓝 (arsinh a)) :=
  (continuous_arsinh.Tendsto _).comp h
#align filter.tendsto.arsinh Filter.Tendsto.arsinh
-/

section Continuous

variable {X : Type _} [TopologicalSpace X] {f : X → ℝ} {s : Set X} {a : X}

#print ContinuousAt.arsinh /-
theorem ContinuousAt.arsinh (h : ContinuousAt f a) : ContinuousAt (fun x => arsinh (f x)) a :=
  h.arsinh
#align continuous_at.arsinh ContinuousAt.arsinh
-/

#print ContinuousWithinAt.arsinh /-
theorem ContinuousWithinAt.arsinh (h : ContinuousWithinAt f s a) :
    ContinuousWithinAt (fun x => arsinh (f x)) s a :=
  h.arsinh
#align continuous_within_at.arsinh ContinuousWithinAt.arsinh
-/

#print ContinuousOn.arsinh /-
theorem ContinuousOn.arsinh (h : ContinuousOn f s) : ContinuousOn (fun x => arsinh (f x)) s :=
  fun x hx => (h x hx).arsinh
#align continuous_on.arsinh ContinuousOn.arsinh
-/

#print Continuous.arsinh /-
theorem Continuous.arsinh (h : Continuous f) : Continuous fun x => arsinh (f x) :=
  continuous_arsinh.comp h
#align continuous.arsinh Continuous.arsinh
-/

end Continuous

section fderiv

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E] {f : E → ℝ} {s : Set E} {a : E}
  {f' : E →L[ℝ] ℝ} {n : ℕ∞}

#print HasStrictFDerivAt.arsinh /-
theorem HasStrictFDerivAt.arsinh (hf : HasStrictFDerivAt f f' a) :
    HasStrictFDerivAt (fun x => arsinh (f x)) ((sqrt (1 + f a ^ 2))⁻¹ • f') a :=
  (hasStrictDerivAt_arsinh _).comp_hasStrictFDerivAt a hf
#align has_strict_fderiv_at.arsinh HasStrictFDerivAt.arsinh
-/

#print HasFDerivAt.arsinh /-
theorem HasFDerivAt.arsinh (hf : HasFDerivAt f f' a) :
    HasFDerivAt (fun x => arsinh (f x)) ((sqrt (1 + f a ^ 2))⁻¹ • f') a :=
  (hasDerivAt_arsinh _).comp_hasFDerivAt a hf
#align has_fderiv_at.arsinh HasFDerivAt.arsinh
-/

#print HasFDerivWithinAt.arsinh /-
theorem HasFDerivWithinAt.arsinh (hf : HasFDerivWithinAt f f' s a) :
    HasFDerivWithinAt (fun x => arsinh (f x)) ((sqrt (1 + f a ^ 2))⁻¹ • f') s a :=
  (hasDerivAt_arsinh _).comp_hasFDerivWithinAt a hf
#align has_fderiv_within_at.arsinh HasFDerivWithinAt.arsinh
-/

#print DifferentiableAt.arsinh /-
theorem DifferentiableAt.arsinh (h : DifferentiableAt ℝ f a) :
    DifferentiableAt ℝ (fun x => arsinh (f x)) a :=
  (differentiable_arsinh _).comp a h
#align differentiable_at.arsinh DifferentiableAt.arsinh
-/

#print DifferentiableWithinAt.arsinh /-
theorem DifferentiableWithinAt.arsinh (h : DifferentiableWithinAt ℝ f s a) :
    DifferentiableWithinAt ℝ (fun x => arsinh (f x)) s a :=
  (differentiable_arsinh _).comp_differentiableWithinAt a h
#align differentiable_within_at.arsinh DifferentiableWithinAt.arsinh
-/

#print DifferentiableOn.arsinh /-
theorem DifferentiableOn.arsinh (h : DifferentiableOn ℝ f s) :
    DifferentiableOn ℝ (fun x => arsinh (f x)) s := fun x hx => (h x hx).arsinh
#align differentiable_on.arsinh DifferentiableOn.arsinh
-/

#print Differentiable.arsinh /-
theorem Differentiable.arsinh (h : Differentiable ℝ f) : Differentiable ℝ fun x => arsinh (f x) :=
  differentiable_arsinh.comp h
#align differentiable.arsinh Differentiable.arsinh
-/

#print ContDiffAt.arsinh /-
theorem ContDiffAt.arsinh (h : ContDiffAt ℝ n f a) : ContDiffAt ℝ n (fun x => arsinh (f x)) a :=
  contDiff_arsinh.ContDiffAt.comp a h
#align cont_diff_at.arsinh ContDiffAt.arsinh
-/

#print ContDiffWithinAt.arsinh /-
theorem ContDiffWithinAt.arsinh (h : ContDiffWithinAt ℝ n f s a) :
    ContDiffWithinAt ℝ n (fun x => arsinh (f x)) s a :=
  contDiff_arsinh.ContDiffAt.comp_contDiffWithinAt a h
#align cont_diff_within_at.arsinh ContDiffWithinAt.arsinh
-/

#print ContDiff.arsinh /-
theorem ContDiff.arsinh (h : ContDiff ℝ n f) : ContDiff ℝ n fun x => arsinh (f x) :=
  contDiff_arsinh.comp h
#align cont_diff.arsinh ContDiff.arsinh
-/

#print ContDiffOn.arsinh /-
theorem ContDiffOn.arsinh (h : ContDiffOn ℝ n f s) : ContDiffOn ℝ n (fun x => arsinh (f x)) s :=
  fun x hx => (h x hx).arsinh
#align cont_diff_on.arsinh ContDiffOn.arsinh
-/

end fderiv

section deriv

variable {f : ℝ → ℝ} {s : Set ℝ} {a f' : ℝ}

#print HasStrictDerivAt.arsinh /-
theorem HasStrictDerivAt.arsinh (hf : HasStrictDerivAt f f' a) :
    HasStrictDerivAt (fun x => arsinh (f x)) ((sqrt (1 + f a ^ 2))⁻¹ • f') a :=
  (hasStrictDerivAt_arsinh _).comp a hf
#align has_strict_deriv_at.arsinh HasStrictDerivAt.arsinh
-/

#print HasDerivAt.arsinh /-
theorem HasDerivAt.arsinh (hf : HasDerivAt f f' a) :
    HasDerivAt (fun x => arsinh (f x)) ((sqrt (1 + f a ^ 2))⁻¹ • f') a :=
  (hasDerivAt_arsinh _).comp a hf
#align has_deriv_at.arsinh HasDerivAt.arsinh
-/

#print HasDerivWithinAt.arsinh /-
theorem HasDerivWithinAt.arsinh (hf : HasDerivWithinAt f f' s a) :
    HasDerivWithinAt (fun x => arsinh (f x)) ((sqrt (1 + f a ^ 2))⁻¹ • f') s a :=
  (hasDerivAt_arsinh _).comp_hasDerivWithinAt a hf
#align has_deriv_within_at.arsinh HasDerivWithinAt.arsinh
-/

end deriv

