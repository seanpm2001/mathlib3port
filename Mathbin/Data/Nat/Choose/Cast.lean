/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module data.nat.choose.cast
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Choose.Basic
import Mathbin.Data.Nat.Factorial.Cast

/-!
# Cast of binomial coefficients

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file allows calculating the binomial coefficient `a.choose b` as an element of a division ring
of characteristic `0`.
-/


open scoped Nat

variable (K : Type _) [DivisionRing K] [CharZero K]

namespace Nat

#print Nat.cast_choose /-
theorem cast_choose {a b : ℕ} (h : a ≤ b) : (b.choose a : K) = b ! / (a ! * (b - a)!) :=
  by
  have : ∀ {n : ℕ}, (n ! : K) ≠ 0 := fun n => Nat.cast_ne_zero.2 (factorial_ne_zero _)
  rw [eq_div_iff_mul_eq (mul_ne_zero this this)]
  rw_mod_cast [← mul_assoc, choose_mul_factorial_mul_factorial h]
#align nat.cast_choose Nat.cast_choose
-/

#print Nat.cast_add_choose /-
theorem cast_add_choose {a b : ℕ} : ((a + b).choose a : K) = (a + b)! / (a ! * b !) := by
  rw [cast_choose K (le_add_right le_rfl), add_tsub_cancel_left]
#align nat.cast_add_choose Nat.cast_add_choose
-/

#print Nat.cast_choose_eq_pochhammer_div /-
theorem cast_choose_eq_pochhammer_div (a b : ℕ) :
    (a.choose b : K) = (pochhammer K b).eval (a - (b - 1) : ℕ) / b ! := by
  rw [eq_div_iff_mul_eq (Nat.cast_ne_zero.2 b.factorial_ne_zero : (b ! : K) ≠ 0), ← Nat.cast_mul,
    mul_comm, ← Nat.descFactorial_eq_factorial_mul_choose, ← cast_desc_factorial]
#align nat.cast_choose_eq_pochhammer_div Nat.cast_choose_eq_pochhammer_div
-/

#print Nat.cast_choose_two /-
theorem cast_choose_two (a : ℕ) : (a.choose 2 : K) = a * (a - 1) / 2 := by
  rw [← cast_desc_factorial_two, desc_factorial_eq_factorial_mul_choose, factorial_two, mul_comm,
    cast_mul, cast_two, eq_div_iff_mul_eq (two_ne_zero : (2 : K) ≠ 0)]
#align nat.cast_choose_two Nat.cast_choose_two
-/

end Nat

