/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module data.int.order.units
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Int.Order.Basic
import Mathbin.Data.Int.Units
import Mathbin.Algebra.GroupPower.Order

/-!
# Lemmas about units in `ℤ`, which interact with the order structure.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


namespace Int

#print Int.isUnit_iff_abs_eq /-
theorem isUnit_iff_abs_eq {x : ℤ} : IsUnit x ↔ abs x = 1 := by
  rw [is_unit_iff_nat_abs_eq, abs_eq_nat_abs, ← Int.ofNat_one, coe_nat_inj']
#align int.is_unit_iff_abs_eq Int.isUnit_iff_abs_eq
-/

#print Int.isUnit_sq /-
theorem isUnit_sq {a : ℤ} (ha : IsUnit a) : a ^ 2 = 1 := by rw [sq, is_unit_mul_self ha]
#align int.is_unit_sq Int.isUnit_sq
-/

#print Int.units_sq /-
@[simp]
theorem units_sq (u : ℤˣ) : u ^ 2 = 1 := by
  rw [Units.ext_iff, Units.val_pow_eq_pow_val, Units.val_one, is_unit_sq u.is_unit]
#align int.units_sq Int.units_sq
-/

alias units_sq ← units_pow_two
#align int.units_pow_two Int.units_pow_two

#print Int.units_mul_self /-
@[simp]
theorem units_mul_self (u : ℤˣ) : u * u = 1 := by rw [← sq, units_sq]
#align int.units_mul_self Int.units_mul_self
-/

#print Int.units_inv_eq_self /-
@[simp]
theorem units_inv_eq_self (u : ℤˣ) : u⁻¹ = u := by rw [inv_eq_iff_mul_eq_one, units_mul_self]
#align int.units_inv_eq_self Int.units_inv_eq_self
-/

#print Int.units_coe_mul_self /-
-- `units.coe_mul` is a "wrong turn" for the simplifier, this undoes it and simplifies further
@[simp]
theorem units_coe_mul_self (u : ℤˣ) : (u * u : ℤ) = 1 := by
  rw [← Units.val_mul, units_mul_self, Units.val_one]
#align int.units_coe_mul_self Int.units_coe_mul_self
-/

#print Int.neg_one_pow_ne_zero /-
@[simp]
theorem neg_one_pow_ne_zero {n : ℕ} : (-1 : ℤ) ^ n ≠ 0 :=
  pow_ne_zero _ (abs_pos.mp (by simp))
#align int.neg_one_pow_ne_zero Int.neg_one_pow_ne_zero
-/

#print Int.sq_eq_one_of_sq_lt_four /-
theorem sq_eq_one_of_sq_lt_four {x : ℤ} (h1 : x ^ 2 < 4) (h2 : x ≠ 0) : x ^ 2 = 1 :=
  sq_eq_one_iff.mpr
    ((abs_eq (zero_le_one' ℤ)).mp
      (le_antisymm (lt_add_one_iff.mp (abs_lt_of_sq_lt_sq h1 zero_le_two))
        (sub_one_lt_iff.mp (abs_pos.mpr h2))))
#align int.sq_eq_one_of_sq_lt_four Int.sq_eq_one_of_sq_lt_four
-/

#print Int.sq_eq_one_of_sq_le_three /-
theorem sq_eq_one_of_sq_le_three {x : ℤ} (h1 : x ^ 2 ≤ 3) (h2 : x ≠ 0) : x ^ 2 = 1 :=
  sq_eq_one_of_sq_lt_four (lt_of_le_of_lt h1 (lt_add_one 3)) h2
#align int.sq_eq_one_of_sq_le_three Int.sq_eq_one_of_sq_le_three
-/

#print Int.units_pow_eq_pow_mod_two /-
theorem units_pow_eq_pow_mod_two (u : ℤˣ) (n : ℕ) : u ^ n = u ^ (n % 2) := by
  conv =>
      lhs
      rw [← Nat.mod_add_div n 2] <;>
    rw [pow_add, pow_mul, units_sq, one_pow, mul_one]
#align int.units_pow_eq_pow_mod_two Int.units_pow_eq_pow_mod_two
-/

end Int

