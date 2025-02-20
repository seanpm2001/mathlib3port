/-
Copyright (c) 2021 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying, Eric Wieser

! This file was ported from Lean 3 source module data.real.sign
! leanprover-community/mathlib commit cc70d9141824ea8982d1562ce009952f2c3ece30
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Real.Basic

/-!
# Real sign function

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file introduces and contains some results about `real.sign` which maps negative
real numbers to -1, positive real numbers to 1, and 0 to 0.

## Main definitions

 * `real.sign r` is $\begin{cases} -1 & \text{if } r < 0, \\
                               ~~\, 0 & \text{if } r = 0, \\
                               ~~\, 1 & \text{if } r > 0. \end{cases}$

## Tags

sign function
-/


namespace Real

#print Real.sign /-
/-- The sign function that maps negative real numbers to -1, positive numbers to 1, and 0
otherwise. -/
noncomputable def sign (r : ℝ) : ℝ :=
  if r < 0 then -1 else if 0 < r then 1 else 0
#align real.sign Real.sign
-/

#print Real.sign_of_neg /-
theorem sign_of_neg {r : ℝ} (hr : r < 0) : sign r = -1 := by rw [SignType.sign, if_pos hr]
#align real.sign_of_neg Real.sign_of_neg
-/

#print Real.sign_of_pos /-
theorem sign_of_pos {r : ℝ} (hr : 0 < r) : sign r = 1 := by
  rw [SignType.sign, if_pos hr, if_neg hr.not_lt]
#align real.sign_of_pos Real.sign_of_pos
-/

#print Real.sign_zero /-
@[simp]
theorem sign_zero : sign 0 = 0 := by rw [SignType.sign, if_neg (lt_irrefl _), if_neg (lt_irrefl _)]
#align real.sign_zero Real.sign_zero
-/

#print Real.sign_one /-
@[simp]
theorem sign_one : sign 1 = 1 :=
  sign_of_pos <| by norm_num
#align real.sign_one Real.sign_one
-/

#print Real.sign_apply_eq /-
theorem sign_apply_eq (r : ℝ) : sign r = -1 ∨ sign r = 0 ∨ sign r = 1 :=
  by
  obtain hn | rfl | hp := lt_trichotomy r (0 : ℝ)
  · exact Or.inl <| sign_of_neg hn
  · exact Or.inr <| Or.inl <| sign_zero
  · exact Or.inr <| Or.inr <| sign_of_pos hp
#align real.sign_apply_eq Real.sign_apply_eq
-/

#print Real.sign_apply_eq_of_ne_zero /-
/-- This lemma is useful for working with `ℝˣ` -/
theorem sign_apply_eq_of_ne_zero (r : ℝ) (h : r ≠ 0) : sign r = -1 ∨ sign r = 1 :=
  by
  obtain hn | rfl | hp := lt_trichotomy r (0 : ℝ)
  · exact Or.inl <| sign_of_neg hn
  · exact (h rfl).elim
  · exact Or.inr <| sign_of_pos hp
#align real.sign_apply_eq_of_ne_zero Real.sign_apply_eq_of_ne_zero
-/

#print Real.sign_eq_zero_iff /-
@[simp]
theorem sign_eq_zero_iff {r : ℝ} : sign r = 0 ↔ r = 0 :=
  by
  refine' ⟨fun h => _, fun h => h.symm ▸ sign_zero⟩
  obtain hn | rfl | hp := lt_trichotomy r (0 : ℝ)
  · rw [sign_of_neg hn, neg_eq_zero] at h ; exact (one_ne_zero h).elim
  · rfl
  · rw [sign_of_pos hp] at h ; exact (one_ne_zero h).elim
#align real.sign_eq_zero_iff Real.sign_eq_zero_iff
-/

#print Real.sign_int_cast /-
theorem sign_int_cast (z : ℤ) : sign (z : ℝ) = ↑(Int.sign z) :=
  by
  obtain hn | rfl | hp := lt_trichotomy z (0 : ℤ)
  ·
    rw [sign_of_neg (int.cast_lt_zero.mpr hn), Int.sign_eq_neg_one_of_neg hn, Int.cast_neg,
      Int.cast_one]
  · rw [Int.cast_zero, sign_zero, Int.sign_zero, Int.cast_zero]
  · rw [sign_of_pos (int.cast_pos.mpr hp), Int.sign_eq_one_of_pos hp, Int.cast_one]
#align real.sign_int_cast Real.sign_int_cast
-/

#print Real.sign_neg /-
theorem sign_neg {r : ℝ} : sign (-r) = -sign r :=
  by
  obtain hn | rfl | hp := lt_trichotomy r (0 : ℝ)
  · rw [sign_of_neg hn, sign_of_pos (neg_pos.mpr hn), neg_neg]
  · rw [sign_zero, neg_zero, sign_zero]
  · rw [sign_of_pos hp, sign_of_neg (neg_lt_zero.mpr hp)]
#align real.sign_neg Real.sign_neg
-/

#print Real.sign_mul_nonneg /-
theorem sign_mul_nonneg (r : ℝ) : 0 ≤ sign r * r :=
  by
  obtain hn | rfl | hp := lt_trichotomy r (0 : ℝ)
  · rw [sign_of_neg hn]
    exact mul_nonneg_of_nonpos_of_nonpos (by norm_num) hn.le
  · rw [MulZeroClass.mul_zero]
  · rw [sign_of_pos hp, one_mul]
    exact hp.le
#align real.sign_mul_nonneg Real.sign_mul_nonneg
-/

#print Real.sign_mul_pos_of_ne_zero /-
theorem sign_mul_pos_of_ne_zero (r : ℝ) (hr : r ≠ 0) : 0 < sign r * r :=
  by
  refine' lt_of_le_of_ne (sign_mul_nonneg r) fun h => hr _
  have hs0 := (zero_eq_mul.mp h).resolve_right hr
  exact sign_eq_zero_iff.mp hs0
#align real.sign_mul_pos_of_ne_zero Real.sign_mul_pos_of_ne_zero
-/

#print Real.inv_sign /-
@[simp]
theorem inv_sign (r : ℝ) : (sign r)⁻¹ = sign r :=
  by
  obtain hn | hz | hp := sign_apply_eq r
  · rw [hn]; norm_num
  · rw [hz]; exact inv_zero
  · rw [hp]; exact inv_one
#align real.inv_sign Real.inv_sign
-/

#print Real.sign_inv /-
@[simp]
theorem sign_inv (r : ℝ) : sign r⁻¹ = sign r :=
  by
  obtain hn | rfl | hp := lt_trichotomy r (0 : ℝ)
  · rw [sign_of_neg hn, sign_of_neg (inv_lt_zero.mpr hn)]
  · rw [sign_zero, inv_zero, sign_zero]
  · rw [sign_of_pos hp, sign_of_pos (inv_pos.mpr hp)]
#align real.sign_inv Real.sign_inv
-/

end Real

