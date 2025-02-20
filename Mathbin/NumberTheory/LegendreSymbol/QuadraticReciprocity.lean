/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Michael Stoll

! This file was ported from Lean 3 source module number_theory.legendre_symbol.quadratic_reciprocity
! leanprover-community/mathlib commit 08b63ab58a6ec1157ebeafcbbe6c7a3fb3c9f6d5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.NumberTheory.LegendreSymbol.Basic
import Mathbin.NumberTheory.LegendreSymbol.QuadraticChar.GaussSum

/-!
# Quadratic reciprocity.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main results

We prove the law of quadratic reciprocity, see `legendre_sym.quadratic_reciprocity` and
`legendre_sym.quadratic_reciprocity'`, as well as the
interpretations in terms of existence of square roots depending on the congruence mod 4,
`zmod.exists_sq_eq_prime_iff_of_mod_four_eq_one`, and
`zmod.exists_sq_eq_prime_iff_of_mod_four_eq_three`.

We also prove the supplementary laws that give conditions for when `-1` or `2`
(or `-2`) is a square modulo a prime `p`:
`legendre_sym.at_neg_one` and `zmod.exists_sq_eq_neg_one_iff` for `-1`,
`legendre_sym.at_two` and `zmod.exists_sq_eq_two_iff` for `2`,
`legendre_sym.at_neg_two` and `zmod.exists_sq_eq_neg_two_iff` for `-2`.

## Implementation notes

The proofs use results for quadratic characters on arbitrary finite fields
from `number_theory.legendre_symbol.quadratic_char.gauss_sum`, which in turn are based on
properties of quadratic Gauss sums as provided by `number_theory.legendre_symbol.gauss_sum`.

## Tags

quadratic residue, quadratic nonresidue, Legendre symbol, quadratic reciprocity
-/


open Nat

section Values

variable {p : ℕ} [Fact p.Prime]

open ZMod

/-!
### The value of the Legendre symbol at `2` and `-2`

See `jacobi_sym.at_two` and `jacobi_sym.at_neg_two` for the corresponding statements
for the Jacobi symbol.
-/


namespace legendreSym

variable (hp : p ≠ 2)

#print legendreSym.at_two /-
/-- `legendre_sym p 2` is given by `χ₈ p`. -/
theorem at_two : legendreSym p 2 = χ₈ p := by
  simp only [legendreSym, card p, quadraticChar_two ((ring_char_zmod_n p).substr hp), Int.cast_bit0,
    Int.cast_one]
#align legendre_sym.at_two legendreSym.at_two
-/

#print legendreSym.at_neg_two /-
/-- `legendre_sym p (-2)` is given by `χ₈' p`. -/
theorem at_neg_two : legendreSym p (-2) = χ₈' p := by
  simp only [legendreSym, card p, quadraticChar_neg_two ((ring_char_zmod_n p).substr hp),
    Int.cast_bit0, Int.cast_one, Int.cast_neg]
#align legendre_sym.at_neg_two legendreSym.at_neg_two
-/

end legendreSym

namespace ZMod

variable (hp : p ≠ 2)

#print ZMod.exists_sq_eq_two_iff /-
/-- `2` is a square modulo an odd prime `p` iff `p` is congruent to `1` or `7` mod `8`. -/
theorem exists_sq_eq_two_iff : IsSquare (2 : ZMod p) ↔ p % 8 = 1 ∨ p % 8 = 7 :=
  by
  rw [FiniteField.isSquare_two_iff, card p]
  have h₁ := prime.mod_two_eq_one_iff_ne_two.mpr hp
  rw [← mod_mod_of_dvd p (by norm_num : 2 ∣ 8)] at h₁ 
  have h₂ := mod_lt p (by norm_num : 0 < 8)
  revert h₂ h₁
  generalize hm : p % 8 = m; clear! p
  decide!
#align zmod.exists_sq_eq_two_iff ZMod.exists_sq_eq_two_iff
-/

#print ZMod.exists_sq_eq_neg_two_iff /-
/-- `-2` is a square modulo an odd prime `p` iff `p` is congruent to `1` or `3` mod `8`. -/
theorem exists_sq_eq_neg_two_iff : IsSquare (-2 : ZMod p) ↔ p % 8 = 1 ∨ p % 8 = 3 :=
  by
  rw [FiniteField.isSquare_neg_two_iff, card p]
  have h₁ := prime.mod_two_eq_one_iff_ne_two.mpr hp
  rw [← mod_mod_of_dvd p (by norm_num : 2 ∣ 8)] at h₁ 
  have h₂ := mod_lt p (by norm_num : 0 < 8)
  revert h₂ h₁
  generalize hm : p % 8 = m; clear! p
  decide!
#align zmod.exists_sq_eq_neg_two_iff ZMod.exists_sq_eq_neg_two_iff
-/

end ZMod

end Values

section Reciprocity

/-!
### The Law of Quadratic Reciprocity

See `jacobi_sym.quadratic_reciprocity` and variants for a version of Quadratic Reciprocity
for the Jacobi symbol.
-/


variable {p q : ℕ} [Fact p.Prime] [Fact q.Prime]

namespace legendreSym

open ZMod

#print legendreSym.quadratic_reciprocity /-
/-- The Law of Quadratic Reciprocity: if `p` and `q` are distinct odd primes, then
`(q / p) * (p / q) = (-1)^((p-1)(q-1)/4)`. -/
theorem quadratic_reciprocity (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q) :
    legendreSym q p * legendreSym p q = (-1) ^ (p / 2 * (q / 2)) :=
  by
  have hp₁ := (prime.eq_two_or_odd <| Fact.out p.prime).resolve_left hp
  have hq₁ := (prime.eq_two_or_odd <| Fact.out q.prime).resolve_left hq
  have hq₂ := (ring_char_zmod_n q).substr hq
  have h :=
    quadraticChar_odd_prime ((ring_char_zmod_n p).substr hp) hq ((ring_char_zmod_n p).substr hpq)
  rw [card p] at h 
  have nc : ∀ n r : ℕ, ((n : ℤ) : ZMod r) = n := fun n r => by norm_cast
  have nc' : (((-1) ^ (p / 2) : ℤ) : ZMod q) = (-1) ^ (p / 2) := by norm_cast
  rw [legendreSym, legendreSym, nc, nc, h, map_mul, mul_rotate', mul_comm (p / 2), ← pow_two,
    quadraticChar_sq_one (prime_ne_zero q p hpq.symm), mul_one, pow_mul, χ₄_eq_neg_one_pow hp₁, nc',
    map_pow, quadraticChar_neg_one hq₂, card q, χ₄_eq_neg_one_pow hq₁]
#align legendre_sym.quadratic_reciprocity legendreSym.quadratic_reciprocity
-/

#print legendreSym.quadratic_reciprocity' /-
/-- The Law of Quadratic Reciprocity: if `p` and `q` are odd primes, then
`(q / p) = (-1)^((p-1)(q-1)/4) * (p / q)`. -/
theorem quadratic_reciprocity' (hp : p ≠ 2) (hq : q ≠ 2) :
    legendreSym q p = (-1) ^ (p / 2 * (q / 2)) * legendreSym p q :=
  by
  cases' eq_or_ne p q with h h
  · subst p
    rw [(eq_zero_iff q q).mpr (by exact_mod_cast nat_cast_self q), MulZeroClass.mul_zero]
  · have qr := congr_arg (· * legendreSym p q) (quadratic_reciprocity hp hq h)
    have : ((q : ℤ) : ZMod p) ≠ 0 := by exact_mod_cast prime_ne_zero p q h
    simpa only [mul_assoc, ← pow_two, sq_one p this, mul_one] using qr
#align legendre_sym.quadratic_reciprocity' legendreSym.quadratic_reciprocity'
-/

#print legendreSym.quadratic_reciprocity_one_mod_four /-
/-- The Law of Quadratic Reciprocity: if `p` and `q` are odd primes and `p % 4 = 1`,
then `(q / p) = (p / q)`. -/
theorem quadratic_reciprocity_one_mod_four (hp : p % 4 = 1) (hq : q ≠ 2) :
    legendreSym q p = legendreSym p q := by
  rw [quadratic_reciprocity' (prime.mod_two_eq_one_iff_ne_two.mp (odd_of_mod_four_eq_one hp)) hq,
    pow_mul, neg_one_pow_div_two_of_one_mod_four hp, one_pow, one_mul]
#align legendre_sym.quadratic_reciprocity_one_mod_four legendreSym.quadratic_reciprocity_one_mod_four
-/

#print legendreSym.quadratic_reciprocity_three_mod_four /-
/-- The Law of Quadratic Reciprocity: if `p` and `q` are primes that are both congruent
to `3` mod `4`, then `(q / p) = -(p / q)`. -/
theorem quadratic_reciprocity_three_mod_four (hp : p % 4 = 3) (hq : q % 4 = 3) :
    legendreSym q p = -legendreSym p q :=
  by
  let nop := @neg_one_pow_div_two_of_three_mod_four
  rw [quadratic_reciprocity', pow_mul, nop hp, nop hq, neg_one_mul] <;>
    rwa [← prime.mod_two_eq_one_iff_ne_two, odd_of_mod_four_eq_three]
#align legendre_sym.quadratic_reciprocity_three_mod_four legendreSym.quadratic_reciprocity_three_mod_four
-/

end legendreSym

namespace ZMod

open legendreSym

#print ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_one /-
/-- If `p` and `q` are odd primes and `p % 4 = 1`, then `q` is a square mod `p` iff
`p` is a square mod `q`. -/
theorem exists_sq_eq_prime_iff_of_mod_four_eq_one (hp1 : p % 4 = 1) (hq1 : q ≠ 2) :
    IsSquare (q : ZMod p) ↔ IsSquare (p : ZMod q) :=
  by
  cases' eq_or_ne p q with h h
  · subst p
  ·
    rw [← eq_one_iff' p (prime_ne_zero p q h), ← eq_one_iff' q (prime_ne_zero q p h.symm),
      quadratic_reciprocity_one_mod_four hp1 hq1]
#align zmod.exists_sq_eq_prime_iff_of_mod_four_eq_one ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_one
-/

#print ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_three /-
/-- If `p` and `q` are distinct primes that are both congruent to `3` mod `4`, then `q` is
a square mod `p` iff `p` is a nonsquare mod `q`. -/
theorem exists_sq_eq_prime_iff_of_mod_four_eq_three (hp3 : p % 4 = 3) (hq3 : q % 4 = 3)
    (hpq : p ≠ q) : IsSquare (q : ZMod p) ↔ ¬IsSquare (p : ZMod q) := by
  rw [← eq_one_iff' p (prime_ne_zero p q hpq), ← eq_neg_one_iff' q,
    quadratic_reciprocity_three_mod_four hp3 hq3, neg_inj]
#align zmod.exists_sq_eq_prime_iff_of_mod_four_eq_three ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_three
-/

end ZMod

end Reciprocity

