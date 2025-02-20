/-
Copyright (c) 2021 Jakob Scholbach. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jakob Scholbach

! This file was ported from Lean 3 source module algebra.char_p.exp_char
! leanprover-community/mathlib commit 932872382355f00112641d305ba0619305dc8642
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.CharP.Basic
import Mathbin.Data.Nat.Prime

/-!
# Exponential characteristic

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the exponential characteristic and establishes a few basic results relating
it to the (ordinary characteristic).
The definition is stated for a semiring, but the actual results are for nontrivial rings
(as far as exponential characteristic one is concerned), respectively a ring without zero-divisors
(for prime characteristic).

## Main results
- `exp_char`: the definition of exponential characteristic
- `exp_char_is_prime_or_one`: the exponential characteristic is a prime or one
- `char_eq_exp_char_iff`: the characteristic equals the exponential characteristic iff the
  characteristic is prime

## Tags
exponential characteristic, characteristic
-/


universe u

variable (R : Type u)

section Semiring

variable [Semiring R]

#print ExpChar /-
/-- The definition of the exponential characteristic of a semiring. -/
class inductive ExpChar (R : Type u) [Semiring R] : ℕ → Prop
  | zero [CharZero R] : ExpChar 1
  | Prime {q : ℕ} (hprime : q.Prime) [hchar : CharP R q] : ExpChar q
#align exp_char ExpChar
-/

#print expChar_one_of_char_zero /-
/-- The exponential characteristic is one if the characteristic is zero. -/
theorem expChar_one_of_char_zero (q : ℕ) [hp : CharP R 0] [hq : ExpChar R q] : q = 1 :=
  by
  cases' hq with q hq_one hq_prime
  · rfl
  · exact False.elim (lt_irrefl _ ((hp.eq R hq_hchar).symm ▸ hq_prime : (0 : ℕ).Prime).Pos)
#align exp_char_one_of_char_zero expChar_one_of_char_zero
-/

#print char_eq_expChar_iff /-
/-- The characteristic equals the exponential characteristic iff the former is prime. -/
theorem char_eq_expChar_iff (p q : ℕ) [hp : CharP R p] [hq : ExpChar R q] : p = q ↔ p.Prime :=
  by
  cases' hq with q hq_one hq_prime
  · apply iff_of_false
    · rintro rfl
      exact one_ne_zero (hp.eq R (CharP.ofCharZero R))
    · intro pprime
      rw [(CharP.eq R hp inferInstance : p = 0)] at pprime 
      exact Nat.not_prime_zero pprime
  · exact ⟨fun hpq => hpq.symm ▸ hq_prime, fun _ => CharP.eq R hp hq_hchar⟩
#align char_eq_exp_char_iff char_eq_expChar_iff
-/

section Nontrivial

variable [Nontrivial R]

#print char_zero_of_expChar_one /-
/-- The exponential characteristic is one if the characteristic is zero. -/
theorem char_zero_of_expChar_one (p : ℕ) [hp : CharP R p] [hq : ExpChar R 1] : p = 0 :=
  by
  cases hq
  · exact CharP.eq R hp inferInstance
  · exact False.elim (CharP.char_ne_one R 1 rfl)
#align char_zero_of_exp_char_one char_zero_of_expChar_one
-/

#print charZero_of_expChar_one' /-
-- see Note [lower instance priority]
/-- The characteristic is zero if the exponential characteristic is one. -/
instance (priority := 100) charZero_of_expChar_one' [hq : ExpChar R 1] : CharZero R :=
  by
  cases hq
  · assumption
  · exact False.elim (CharP.char_ne_one R 1 rfl)
#align char_zero_of_exp_char_one' charZero_of_expChar_one'
-/

#print expChar_one_iff_char_zero /-
/-- The exponential characteristic is one iff the characteristic is zero. -/
theorem expChar_one_iff_char_zero (p q : ℕ) [CharP R p] [ExpChar R q] : q = 1 ↔ p = 0 :=
  by
  constructor
  · rintro rfl
    exact char_zero_of_expChar_one R p
  · rintro rfl
    exact expChar_one_of_char_zero R q
#align exp_char_one_iff_char_zero expChar_one_iff_char_zero
-/

section NoZeroDivisors

variable [NoZeroDivisors R]

#print char_prime_of_ne_zero /-
/-- A helper lemma: the characteristic is prime if it is non-zero. -/
theorem char_prime_of_ne_zero {p : ℕ} [hp : CharP R p] (p_ne_zero : p ≠ 0) : Nat.Prime p :=
  by
  cases' CharP.char_is_prime_or_zero R p with h h
  · exact h
  · contradiction
#align char_prime_of_ne_zero char_prime_of_ne_zero
-/

#print expChar_is_prime_or_one /-
/-- The exponential characteristic is a prime number or one. -/
theorem expChar_is_prime_or_one (q : ℕ) [hq : ExpChar R q] : Nat.Prime q ∨ q = 1 :=
  or_iff_not_imp_right.mpr fun h =>
    by
    cases' CharP.exists R with p hp
    have p_ne_zero : p ≠ 0 := by
      intro p_zero
      have : CharP R 0 := by rwa [← p_zero]
      have : q = 1 := expChar_one_of_char_zero R q
      contradiction
    have p_eq_q : p = q := (char_eq_expChar_iff R p q).mpr (char_prime_of_ne_zero R p_ne_zero)
    cases' CharP.char_is_prime_or_zero R p with pprime
    · rwa [p_eq_q] at pprime 
    · contradiction
#align exp_char_is_prime_or_one expChar_is_prime_or_one
-/

end NoZeroDivisors

end Nontrivial

end Semiring

