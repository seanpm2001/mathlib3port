/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro

! This file was ported from Lean 3 source module algebra.order.ring.abs
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Ring.Defs
import Mathbin.Algebra.Ring.Divisibility
import Mathbin.Algebra.Order.Group.Abs

/-!
# Absolute values in linear ordered rings.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


variable {α : Type _}

section LinearOrderedRing

variable [LinearOrderedRing α] {a b c : α}

#print abs_one /-
@[simp]
theorem abs_one : |(1 : α)| = 1 :=
  abs_of_pos zero_lt_one
#align abs_one abs_one
-/

#print abs_two /-
@[simp]
theorem abs_two : |(2 : α)| = 2 :=
  abs_of_pos zero_lt_two
#align abs_two abs_two
-/

#print abs_mul /-
theorem abs_mul (a b : α) : |a * b| = |a| * |b| :=
  by
  rw [abs_eq (mul_nonneg (abs_nonneg a) (abs_nonneg b))]
  cases' le_total a 0 with ha ha <;> cases' le_total b 0 with hb hb <;>
    simp only [abs_of_nonpos, abs_of_nonneg, true_or_iff, or_true_iff, eq_self_iff_true, neg_mul,
      mul_neg, neg_neg, *]
#align abs_mul abs_mul
-/

#print absHom /-
/-- `abs` as a `monoid_with_zero_hom`. -/
def absHom : α →*₀ α :=
  ⟨abs, abs_zero, abs_one, abs_mul⟩
#align abs_hom absHom
-/

#print abs_mul_abs_self /-
@[simp]
theorem abs_mul_abs_self (a : α) : |a| * |a| = a * a :=
  abs_by_cases (fun x => x * x = a * a) rfl (neg_mul_neg a a)
#align abs_mul_abs_self abs_mul_abs_self
-/

#print abs_mul_self /-
@[simp]
theorem abs_mul_self (a : α) : |a * a| = a * a := by rw [abs_mul, abs_mul_abs_self]
#align abs_mul_self abs_mul_self
-/

#print abs_eq_self /-
@[simp]
theorem abs_eq_self : |a| = a ↔ 0 ≤ a := by simp [abs_eq_max_neg]
#align abs_eq_self abs_eq_self
-/

#print abs_eq_neg_self /-
@[simp]
theorem abs_eq_neg_self : |a| = -a ↔ a ≤ 0 := by simp [abs_eq_max_neg]
#align abs_eq_neg_self abs_eq_neg_self
-/

#print abs_cases /-
/-- For an element `a` of a linear ordered ring, either `abs a = a` and `0 ≤ a`,
    or `abs a = -a` and `a < 0`.
    Use cases on this lemma to automate linarith in inequalities -/
theorem abs_cases (a : α) : |a| = a ∧ 0 ≤ a ∨ |a| = -a ∧ a < 0 :=
  by
  by_cases 0 ≤ a
  · left
    exact ⟨abs_eq_self.mpr h, h⟩
  · right
    push_neg at h 
    exact ⟨abs_eq_neg_self.mpr (le_of_lt h), h⟩
#align abs_cases abs_cases
-/

#print max_zero_add_max_neg_zero_eq_abs_self /-
@[simp]
theorem max_zero_add_max_neg_zero_eq_abs_self (a : α) : max a 0 + max (-a) 0 = |a| :=
  by
  symm
  rcases le_total 0 a with (ha | ha) <;> simp [ha]
#align max_zero_add_max_neg_zero_eq_abs_self max_zero_add_max_neg_zero_eq_abs_self
-/

#print abs_eq_iff_mul_self_eq /-
theorem abs_eq_iff_mul_self_eq : |a| = |b| ↔ a * a = b * b :=
  by
  rw [← abs_mul_abs_self, ← abs_mul_abs_self b]
  exact (mul_self_inj (abs_nonneg a) (abs_nonneg b)).symm
#align abs_eq_iff_mul_self_eq abs_eq_iff_mul_self_eq
-/

#print abs_lt_iff_mul_self_lt /-
theorem abs_lt_iff_mul_self_lt : |a| < |b| ↔ a * a < b * b :=
  by
  rw [← abs_mul_abs_self, ← abs_mul_abs_self b]
  exact mul_self_lt_mul_self_iff (abs_nonneg a) (abs_nonneg b)
#align abs_lt_iff_mul_self_lt abs_lt_iff_mul_self_lt
-/

#print abs_le_iff_mul_self_le /-
theorem abs_le_iff_mul_self_le : |a| ≤ |b| ↔ a * a ≤ b * b :=
  by
  rw [← abs_mul_abs_self, ← abs_mul_abs_self b]
  exact mul_self_le_mul_self_iff (abs_nonneg a) (abs_nonneg b)
#align abs_le_iff_mul_self_le abs_le_iff_mul_self_le
-/

#print abs_le_one_iff_mul_self_le_one /-
theorem abs_le_one_iff_mul_self_le_one : |a| ≤ 1 ↔ a * a ≤ 1 := by
  simpa only [abs_one, one_mul] using @abs_le_iff_mul_self_le α _ a 1
#align abs_le_one_iff_mul_self_le_one abs_le_one_iff_mul_self_le_one
-/

end LinearOrderedRing

section LinearOrderedCommRing

variable [LinearOrderedCommRing α] {a b c d : α}

#print abs_sub_sq /-
theorem abs_sub_sq (a b : α) : |a - b| * |a - b| = a * a + b * b - (1 + 1) * a * b :=
  by
  rw [abs_mul_abs_self]
  simp only [mul_add, add_comm, add_left_comm, mul_comm, sub_eq_add_neg, mul_one, mul_neg,
    neg_add_rev, neg_neg]
#align abs_sub_sq abs_sub_sq
-/

end LinearOrderedCommRing

section

variable [Ring α] [LinearOrder α] {a b : α}

#print abs_dvd /-
@[simp]
theorem abs_dvd (a b : α) : |a| ∣ b ↔ a ∣ b := by
  cases' abs_choice a with h h <;> simp only [h, neg_dvd]
#align abs_dvd abs_dvd
-/

#print abs_dvd_self /-
theorem abs_dvd_self (a : α) : |a| ∣ a :=
  (abs_dvd a a).mpr (dvd_refl a)
#align abs_dvd_self abs_dvd_self
-/

#print dvd_abs /-
@[simp]
theorem dvd_abs (a b : α) : a ∣ |b| ↔ a ∣ b := by
  cases' abs_choice b with h h <;> simp only [h, dvd_neg]
#align dvd_abs dvd_abs
-/

#print self_dvd_abs /-
theorem self_dvd_abs (a : α) : a ∣ |a| :=
  (dvd_abs a a).mpr (dvd_refl a)
#align self_dvd_abs self_dvd_abs
-/

#print abs_dvd_abs /-
theorem abs_dvd_abs (a b : α) : |a| ∣ |b| ↔ a ∣ b :=
  (abs_dvd _ _).trans (dvd_abs _ _)
#align abs_dvd_abs abs_dvd_abs
-/

end

