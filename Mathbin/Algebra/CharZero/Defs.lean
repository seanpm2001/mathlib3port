/-
Copyright (c) 2014 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module algebra.char_zero.defs
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Int.Cast.Defs

/-!
# Characteristic zero

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A ring `R` is called of characteristic zero if every natural number `n` is non-zero when considered
as an element of `R`. Since this definition doesn't mention the multiplicative structure of `R`
except for the existence of `1` in this file characteristic zero is defined for additive monoids
with `1`.

## Main definition

`char_zero` is the typeclass of an additive monoid with one such that the natural homomorphism
from the natural numbers into it is injective.

## TODO

* Unify with `char_p` (possibly using an out-parameter)
-/


#print CharZero /-
/-- Typeclass for monoids with characteristic zero.
  (This is usually stated on fields but it makes sense for any additive monoid with 1.)

*Warning*: for a semiring `R`, `char_zero R` and `char_p R 0` need not coincide.
* `char_zero R` requires an injection `ℕ ↪ R`;
* `char_p R 0` asks that only `0 : ℕ` maps to `0 : R` under the map `ℕ → R`.

For instance, endowing `{0, 1}` with addition given by `max` (i.e. `1` is absorbing), shows that
`char_zero {0, 1}` does not hold and yet `char_p {0, 1} 0` does.
This example is formalized in `counterexamples/char_p_zero_ne_char_zero`.
 -/
class CharZero (R : Type _) [AddMonoidWithOne R] : Prop where
  cast_injective : Function.Injective (coe : ℕ → R)
#align char_zero CharZero
-/

#print charZero_of_inj_zero /-
theorem charZero_of_inj_zero {R : Type _} [AddGroupWithOne R] (H : ∀ n : ℕ, (n : R) = 0 → n = 0) :
    CharZero R :=
  ⟨fun m n h => by
    induction' m with m ih generalizing n; · rw [H n]; rw [← h, Nat.cast_zero]
    cases' n with n; · apply H; rw [h, Nat.cast_zero]
    simp_rw [Nat.cast_succ, add_right_cancel_iff] at h ; rwa [ih]⟩
#align char_zero_of_inj_zero charZero_of_inj_zero
-/

namespace Nat

variable {R : Type _} [AddMonoidWithOne R] [CharZero R]

#print Nat.cast_injective /-
theorem cast_injective : Function.Injective (coe : ℕ → R) :=
  CharZero.cast_injective
#align nat.cast_injective Nat.cast_injective
-/

#print Nat.cast_inj /-
@[simp, norm_cast]
theorem cast_inj {m n : ℕ} : (m : R) = n ↔ m = n :=
  cast_injective.eq_iff
#align nat.cast_inj Nat.cast_inj
-/

#print Nat.cast_eq_zero /-
@[simp, norm_cast]
theorem cast_eq_zero {n : ℕ} : (n : R) = 0 ↔ n = 0 := by rw [← cast_zero, cast_inj]
#align nat.cast_eq_zero Nat.cast_eq_zero
-/

#print Nat.cast_ne_zero /-
@[norm_cast]
theorem cast_ne_zero {n : ℕ} : (n : R) ≠ 0 ↔ n ≠ 0 :=
  not_congr cast_eq_zero
#align nat.cast_ne_zero Nat.cast_ne_zero
-/

#print Nat.cast_add_one_ne_zero /-
theorem cast_add_one_ne_zero (n : ℕ) : (n + 1 : R) ≠ 0 := by exact_mod_cast n.succ_ne_zero
#align nat.cast_add_one_ne_zero Nat.cast_add_one_ne_zero
-/

#print Nat.cast_eq_one /-
@[simp, norm_cast]
theorem cast_eq_one {n : ℕ} : (n : R) = 1 ↔ n = 1 := by rw [← cast_one, cast_inj]
#align nat.cast_eq_one Nat.cast_eq_one
-/

#print Nat.cast_ne_one /-
@[norm_cast]
theorem cast_ne_one {n : ℕ} : (n : R) ≠ 1 ↔ n ≠ 1 :=
  cast_eq_one.Not
#align nat.cast_ne_one Nat.cast_ne_one
-/

end Nat

namespace NeZero

#print NeZero.charZero /-
instance charZero {M} {n : ℕ} [NeZero n] [AddMonoidWithOne M] [CharZero M] : NeZero (n : M) :=
  ⟨Nat.cast_ne_zero.mpr out⟩
#align ne_zero.char_zero NeZero.charZero
-/

end NeZero

