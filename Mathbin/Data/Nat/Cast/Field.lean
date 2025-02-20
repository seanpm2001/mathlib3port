/-
Copyright (c) 2014 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Yaël Dillies, Patrick Stevens

! This file was ported from Lean 3 source module data.nat.cast.field
! leanprover-community/mathlib commit acee671f47b8e7972a1eb6f4eed74b4b3abce829
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Field.Basic
import Mathbin.Algebra.Order.Ring.CharZero
import Mathbin.Data.Nat.Cast.Basic

/-!
# Cast of naturals into fields

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file concerns the canonical homomorphism `ℕ → F`, where `F` is a field.

## Main results

 * `nat.cast_div`: if `n` divides `m`, then `↑(m / n) = ↑m / ↑n`
 * `nat.cast_div_le`: in all cases, `↑(m / n) ≤ ↑m / ↑ n`
-/


namespace Nat

variable {α : Type _}

#print Nat.cast_div /-
@[simp]
theorem cast_div [DivisionSemiring α] {m n : ℕ} (n_dvd : n ∣ m) (n_nonzero : (n : α) ≠ 0) :
    ((m / n : ℕ) : α) = m / n := by
  rcases n_dvd with ⟨k, rfl⟩
  have : n ≠ 0 := by rintro rfl; simpa using n_nonzero
  rw [Nat.mul_div_cancel_left _ this.bot_lt, mul_comm n k, cast_mul, mul_div_cancel _ n_nonzero]
#align nat.cast_div Nat.cast_div
-/

#print Nat.cast_div_div_div_cancel_right /-
theorem cast_div_div_div_cancel_right [DivisionSemiring α] [CharZero α] {m n d : ℕ} (hn : d ∣ n)
    (hm : d ∣ m) : (↑(m / d) : α) / (↑(n / d) : α) = (m : α) / n :=
  by
  rcases eq_or_ne d 0 with (rfl | hd); · simp [zero_dvd_iff.mp hm]
  replace hd : (d : α) ≠ 0; · norm_cast; assumption
  simp [hd, hm, hn, div_div_div_cancel_right _ hd]
#align nat.cast_div_div_div_cancel_right Nat.cast_div_div_div_cancel_right
-/

section LinearOrderedSemifield

variable [LinearOrderedSemifield α]

#print Nat.cast_div_le /-
/-- Natural division is always less than division in the field. -/
theorem cast_div_le {m n : ℕ} : ((m / n : ℕ) : α) ≤ m / n :=
  by
  cases n
  · rw [cast_zero, div_zero, Nat.div_zero, cast_zero]
  rwa [le_div_iff, ← Nat.cast_mul]
  exact Nat.cast_le.2 (Nat.div_mul_le_self m n.succ)
  · exact Nat.cast_pos.2 n.succ_pos
#align nat.cast_div_le Nat.cast_div_le
-/

#print Nat.inv_pos_of_nat /-
theorem inv_pos_of_nat {n : ℕ} : 0 < ((n : α) + 1)⁻¹ :=
  inv_pos.2 <| add_pos_of_nonneg_of_pos n.cast_nonneg zero_lt_one
#align nat.inv_pos_of_nat Nat.inv_pos_of_nat
-/

#print Nat.one_div_pos_of_nat /-
theorem one_div_pos_of_nat {n : ℕ} : 0 < 1 / ((n : α) + 1) := by rw [one_div]; exact inv_pos_of_nat
#align nat.one_div_pos_of_nat Nat.one_div_pos_of_nat
-/

#print Nat.one_div_le_one_div /-
theorem one_div_le_one_div {n m : ℕ} (h : n ≤ m) : 1 / ((m : α) + 1) ≤ 1 / ((n : α) + 1) := by
  refine' one_div_le_one_div_of_le _ _; exact Nat.cast_add_one_pos _; simpa
#align nat.one_div_le_one_div Nat.one_div_le_one_div
-/

#print Nat.one_div_lt_one_div /-
theorem one_div_lt_one_div {n m : ℕ} (h : n < m) : 1 / ((m : α) + 1) < 1 / ((n : α) + 1) := by
  refine' one_div_lt_one_div_of_lt _ _; exact Nat.cast_add_one_pos _; simpa
#align nat.one_div_lt_one_div Nat.one_div_lt_one_div
-/

end LinearOrderedSemifield

end Nat

