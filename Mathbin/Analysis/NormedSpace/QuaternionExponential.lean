/-
Copyright (c) 2023 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module analysis.normed_space.quaternion_exponential
! leanprover-community/mathlib commit 7e5137f579de09a059a5ce98f364a04e221aabf0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Quaternion
import Mathbin.Analysis.NormedSpace.Exponential
import Mathbin.Analysis.SpecialFunctions.Trigonometric.Series

/-!
# Lemmas about `exp` on `quaternion`s

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains results about `exp` on `quaternion ℝ`.

## Main results

* `quaternion.exp_eq`: the general expansion of the quaternion exponential in terms of `real.cos`
  and `real.sin`.
* `quaternion.exp_of_re_eq_zero`: the special case when the quaternion has a zero real part.
* `quaternion.norm_exp`: the norm of the quaternion exponential is the norm of the exponential of
  the real part.

-/


open scoped Quaternion Nat

namespace Quaternion

#print Quaternion.exp_coe /-
@[simp, norm_cast]
theorem exp_coe (r : ℝ) : exp ℝ (r : ℍ[ℝ]) = ↑(exp ℝ r) :=
  (map_exp ℝ (algebraMap ℝ ℍ[ℝ]) (continuous_algebraMap _ _) _).symm
#align quaternion.exp_coe Quaternion.exp_coe
-/

#print Quaternion.hasSum_expSeries_of_imaginary /-
/-- Auxiliary result; if the power series corresponding to `real.cos` and `real.sin` evaluated
at `‖q‖` tend to `c` and `s`, then the exponential series tends to `c + (s / ‖q‖)`. -/
theorem hasSum_expSeries_of_imaginary {q : Quaternion ℝ} (hq : q.re = 0) {c s : ℝ}
    (hc : HasSum (fun n => (-1) ^ n * ‖q‖ ^ (2 * n) / (2 * n)!) c)
    (hs : HasSum (fun n => (-1) ^ n * ‖q‖ ^ (2 * n + 1) / (2 * n + 1)!) s) :
    HasSum (fun n => expSeries ℝ _ n fun _ => q) (↑c + (s / ‖q‖) • q) :=
  by
  replace hc := has_sum_coe.mpr hc
  replace hs := (hs.div_const ‖q‖).smul_const q
  obtain rfl | hq0 := eq_or_ne q 0
  · simp_rw [expSeries_apply_zero, norm_zero, div_zero, zero_smul, add_zero]
    simp_rw [norm_zero] at hc 
    convert hc
    ext (_ | n) : 1
    ·
      rw [pow_zero, MulZeroClass.mul_zero, pow_zero, Nat.factorial_zero, Nat.cast_one, div_one,
        one_mul, Pi.single_eq_same, coe_one]
    ·
      rw [zero_pow (mul_pos two_pos (Nat.succ_pos _)), MulZeroClass.mul_zero, zero_div,
        Pi.single_eq_of_ne n.succ_ne_zero, coe_zero]
  simp_rw [expSeries_apply_eq]
  have hq2 : q ^ 2 = -norm_sq q := sq_eq_neg_norm_sq.mpr hq
  have hqn := norm_ne_zero_iff.mpr hq0
  refine' HasSum.even_add_odd _ _
  · convert hc using 1
    ext n : 1
    let k : ℝ := ↑(2 * n)!
    calc
      k⁻¹ • q ^ (2 * n) = k⁻¹ • (-norm_sq q) ^ n := by rw [pow_mul, hq2]
      _ = k⁻¹ • ↑((-1) ^ n * ‖q‖ ^ (2 * n)) := _
      _ = ↑((-1) ^ n * ‖q‖ ^ (2 * n) / k) := _
    · congr 1
      rw [neg_pow, norm_sq_eq_norm_sq, pow_mul, sq]
      push_cast
    · rw [← coe_mul_eq_smul, div_eq_mul_inv]
      norm_cast
      ring_nf
  · convert hs using 1
    ext n : 1
    let k : ℝ := ↑(2 * n + 1)!
    calc
      k⁻¹ • q ^ (2 * n + 1) = k⁻¹ • ((-norm_sq q) ^ n * q) := by rw [pow_succ', pow_mul, hq2]
      _ = k⁻¹ • ((-1) ^ n * ‖q‖ ^ (2 * n)) • q := _
      _ = ((-1) ^ n * ‖q‖ ^ (2 * n + 1) / k / ‖q‖) • q := _
    · congr 1
      rw [neg_pow, norm_sq_eq_norm_sq, pow_mul, sq, ← coe_mul_eq_smul]
      push_cast
    · rw [smul_smul]
      congr 1
      simp_rw [pow_succ', mul_div_assoc, div_div_cancel_left' hqn]
      ring
#align quaternion.has_sum_exp_series_of_imaginary Quaternion.hasSum_expSeries_of_imaginary
-/

#print Quaternion.exp_of_re_eq_zero /-
/-- The closed form for the quaternion exponential on imaginary quaternions. -/
theorem exp_of_re_eq_zero (q : Quaternion ℝ) (hq : q.re = 0) :
    exp ℝ q = ↑(Real.cos ‖q‖) + (Real.sin ‖q‖ / ‖q‖) • q :=
  by
  rw [exp_eq_tsum]
  refine' HasSum.tsum_eq _
  simp_rw [← expSeries_apply_eq]
  exact has_sum_exp_series_of_imaginary hq (Real.hasSum_cos _) (Real.hasSum_sin _)
#align quaternion.exp_of_re_eq_zero Quaternion.exp_of_re_eq_zero
-/

#print Quaternion.exp_eq /-
/-- The closed form for the quaternion exponential on arbitrary quaternions. -/
theorem exp_eq (q : Quaternion ℝ) :
    exp ℝ q = exp ℝ q.re • (↑(Real.cos ‖q.im‖) + (Real.sin ‖q.im‖ / ‖q.im‖) • q.im) :=
  by
  rw [← exp_of_re_eq_zero q.im q.im_re, ← coe_mul_eq_smul, ← exp_coe, ← exp_add_of_commute,
    re_add_im]
  exact Algebra.commutes q.re (_ : ℍ[ℝ])
#align quaternion.exp_eq Quaternion.exp_eq
-/

#print Quaternion.re_exp /-
theorem re_exp (q : ℍ[ℝ]) : (exp ℝ q).re = exp ℝ q.re * Real.cos ‖q - q.re‖ := by simp [exp_eq]
#align quaternion.re_exp Quaternion.re_exp
-/

#print Quaternion.im_exp /-
theorem im_exp (q : ℍ[ℝ]) : (exp ℝ q).im = (exp ℝ q.re * (Real.sin ‖q.im‖ / ‖q.im‖)) • q.im := by
  simp [exp_eq, smul_smul]
#align quaternion.im_exp Quaternion.im_exp
-/

#print Quaternion.normSq_exp /-
theorem normSq_exp (q : ℍ[ℝ]) : normSq (exp ℝ q) = exp ℝ q.re ^ 2 :=
  calc
    normSq (exp ℝ q) =
        normSq (exp ℝ q.re • (↑(Real.cos ‖q.im‖) + (Real.sin ‖q.im‖ / ‖q.im‖) • q.im)) :=
      by rw [exp_eq]
    _ = exp ℝ q.re ^ 2 * normSq (↑(Real.cos ‖q.im‖) + (Real.sin ‖q.im‖ / ‖q.im‖) • q.im) := by
      rw [norm_sq_smul]
    _ = exp ℝ q.re ^ 2 * (Real.cos ‖q.im‖ ^ 2 + Real.sin ‖q.im‖ ^ 2) :=
      by
      congr 1
      obtain hv | hv := eq_or_ne ‖q.im‖ 0
      · simp [hv]
      rw [norm_sq_add, norm_sq_smul, star_smul, coe_mul_eq_smul, smul_re, smul_re, star_re, im_re,
        smul_zero, smul_zero, MulZeroClass.mul_zero, add_zero, div_pow, norm_sq_coe,
        norm_sq_eq_norm_sq, ← sq, div_mul_cancel _ (pow_ne_zero _ hv)]
    _ = exp ℝ q.re ^ 2 := by rw [Real.cos_sq_add_sin_sq, mul_one]
#align quaternion.norm_sq_exp Quaternion.normSq_exp
-/

#print Quaternion.norm_exp /-
/-- Note that this implies that exponentials of pure imaginary quaternions are unit quaternions
since in that case the RHS is `1` via `exp_zero` and `norm_one`. -/
@[simp]
theorem norm_exp (q : ℍ[ℝ]) : ‖exp ℝ q‖ = ‖exp ℝ q.re‖ := by
  rw [norm_eq_sqrt_real_inner (exp ℝ q), inner_self, norm_sq_exp, Real.sqrt_sq_eq_abs,
    Real.norm_eq_abs]
#align quaternion.norm_exp Quaternion.norm_exp
-/

end Quaternion

