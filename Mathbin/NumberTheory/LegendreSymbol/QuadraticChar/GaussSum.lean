/-
Copyright (c) 2022 Michael Stoll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Michael Stoll

! This file was ported from Lean 3 source module number_theory.legendre_symbol.quadratic_char.gauss_sum
! leanprover-community/mathlib commit 08b63ab58a6ec1157ebeafcbbe6c7a3fb3c9f6d5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.NumberTheory.LegendreSymbol.QuadraticChar.Basic
import Mathbin.NumberTheory.LegendreSymbol.GaussSum

/-!
# Quadratic characters of finite fields

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Further facts relying on Gauss sums.

-/


/-!
### Basic properties of the quadratic character

We prove some properties of the quadratic character.
We work with a finite field `F` here.
The interesting case is when the characteristic of `F` is odd.
-/


section SpecialValues

open ZMod MulChar

variable {F : Type _} [Field F] [Fintype F]

#print quadraticChar_two /-
/-- The value of the quadratic character at `2` -/
theorem quadraticChar_two [DecidableEq F] (hF : ringChar F ≠ 2) :
    quadraticChar F 2 = χ₈ (Fintype.card F) :=
  IsQuadratic.eq_of_eq_coe (quadraticChar_isQuadratic F) isQuadratic_χ₈ hF
    ((quadraticChar_eq_pow_of_char_ne_two' hF 2).trans (FiniteField.two_pow_card hF))
#align quadratic_char_two quadraticChar_two
-/

#print FiniteField.isSquare_two_iff /-
/-- `2` is a square in `F` iff `#F` is not congruent to `3` or `5` mod `8`. -/
theorem FiniteField.isSquare_two_iff :
    IsSquare (2 : F) ↔ Fintype.card F % 8 ≠ 3 ∧ Fintype.card F % 8 ≠ 5 := by
  classical
  by_cases hF : ringChar F = 2
  focus
    have h := FiniteField.even_card_of_char_two hF
    simp only [FiniteField.isSquare_of_char_two hF, true_iff_iff]
  rotate_left
  focus
    have h := FiniteField.odd_card_of_char_ne_two hF
    rw [← quadraticChar_one_iff_isSquare (Ring.two_ne_zero hF), quadraticChar_two hF,
      χ₈_nat_eq_if_mod_eight]
    simp only [h, Nat.one_ne_zero, if_false, ite_eq_left_iff, Ne.def, (by decide : (-1 : ℤ) ≠ 1),
      imp_false, Classical.not_not]
  all_goals
    rw [← Nat.mod_mod_of_dvd _ (by norm_num : 2 ∣ 8)] at h 
    have h₁ := Nat.mod_lt (Fintype.card F) (by decide : 0 < 8)
    revert h₁ h
    generalize Fintype.card F % 8 = n
    decide!
#align finite_field.is_square_two_iff FiniteField.isSquare_two_iff
-/

#print quadraticChar_neg_two /-
/-- The value of the quadratic character at `-2` -/
theorem quadraticChar_neg_two [DecidableEq F] (hF : ringChar F ≠ 2) :
    quadraticChar F (-2) = χ₈' (Fintype.card F) := by
  rw [(by norm_num : (-2 : F) = -1 * 2), map_mul, χ₈'_eq_χ₄_mul_χ₈, quadraticChar_neg_one hF,
    quadraticChar_two hF, @cast_nat_cast _ (ZMod 4) _ _ _ (by norm_num : 4 ∣ 8)]
#align quadratic_char_neg_two quadraticChar_neg_two
-/

#print FiniteField.isSquare_neg_two_iff /-
/-- `-2` is a square in `F` iff `#F` is not congruent to `5` or `7` mod `8`. -/
theorem FiniteField.isSquare_neg_two_iff :
    IsSquare (-2 : F) ↔ Fintype.card F % 8 ≠ 5 ∧ Fintype.card F % 8 ≠ 7 := by
  classical
  by_cases hF : ringChar F = 2
  focus
    have h := FiniteField.even_card_of_char_two hF
    simp only [FiniteField.isSquare_of_char_two hF, true_iff_iff]
  rotate_left
  focus
    have h := FiniteField.odd_card_of_char_ne_two hF
    rw [← quadraticChar_one_iff_isSquare (neg_ne_zero.mpr (Ring.two_ne_zero hF)),
      quadraticChar_neg_two hF, χ₈'_nat_eq_if_mod_eight]
    simp only [h, Nat.one_ne_zero, if_false, ite_eq_left_iff, Ne.def, (by decide : (-1 : ℤ) ≠ 1),
      imp_false, Classical.not_not]
  all_goals
    rw [← Nat.mod_mod_of_dvd _ (by norm_num : 2 ∣ 8)] at h 
    have h₁ := Nat.mod_lt (Fintype.card F) (by decide : 0 < 8)
    revert h₁ h
    generalize Fintype.card F % 8 = n
    decide!
#align finite_field.is_square_neg_two_iff FiniteField.isSquare_neg_two_iff
-/

#print quadraticChar_card_card /-
/-- The relation between the values of the quadratic character of one field `F` at the
cardinality of another field `F'` and of the quadratic character of `F'` at the cardinality
of `F`. -/
theorem quadraticChar_card_card [DecidableEq F] (hF : ringChar F ≠ 2) {F' : Type _} [Field F']
    [Fintype F'] [DecidableEq F'] (hF' : ringChar F' ≠ 2) (h : ringChar F' ≠ ringChar F) :
    quadraticChar F (Fintype.card F') = quadraticChar F' (quadraticChar F (-1) * Fintype.card F) :=
  by
  let χ := (quadraticChar F).ringHomComp (algebraMap ℤ F')
  have hχ₁ : χ.is_nontrivial :=
    by
    obtain ⟨a, ha⟩ := quadraticChar_exists_neg_one hF
    have hu : IsUnit a := by
      contrapose ha
      exact ne_of_eq_of_ne (map_nonunit (quadraticChar F) ha) (mt zero_eq_neg.mp one_ne_zero)
    use hu.unit
    simp only [IsUnit.unit_spec, ring_hom_comp_apply, eq_intCast, Ne.def, ha]
    rw [Int.cast_neg, Int.cast_one]
    exact Ring.neg_one_ne_one_of_char_ne_two hF'
  have hχ₂ : χ.is_quadratic := is_quadratic.comp (quadraticChar_isQuadratic F) _
  have h := Char.card_pow_card hχ₁ hχ₂ h hF'
  rw [← quadraticChar_eq_pow_of_char_ne_two' hF'] at h 
  exact
    (is_quadratic.eq_of_eq_coe (quadraticChar_isQuadratic F') (quadraticChar_isQuadratic F) hF'
        h).symm
#align quadratic_char_card_card quadraticChar_card_card
-/

#print quadraticChar_odd_prime /-
/-- The value of the quadratic character at an odd prime `p` different from `ring_char F`. -/
theorem quadraticChar_odd_prime [DecidableEq F] (hF : ringChar F ≠ 2) {p : ℕ} [Fact p.Prime]
    (hp₁ : p ≠ 2) (hp₂ : ringChar F ≠ p) :
    quadraticChar F p = quadraticChar (ZMod p) (χ₄ (Fintype.card F) * Fintype.card F) :=
  by
  rw [← quadraticChar_neg_one hF]
  have h :=
    quadraticChar_card_card hF (ne_of_eq_of_ne (ring_char_zmod_n p) hp₁)
      (ne_of_eq_of_ne (ring_char_zmod_n p) hp₂.symm)
  rwa [card p] at h 
#align quadratic_char_odd_prime quadraticChar_odd_prime
-/

#print FiniteField.isSquare_odd_prime_iff /-
/-- An odd prime `p` is a square in `F` iff the quadratic character of `zmod p` does not
take the value `-1` on `χ₄(#F) * #F`. -/
theorem FiniteField.isSquare_odd_prime_iff (hF : ringChar F ≠ 2) {p : ℕ} [Fact p.Prime]
    (hp : p ≠ 2) :
    IsSquare (p : F) ↔ quadraticChar (ZMod p) (χ₄ (Fintype.card F) * Fintype.card F) ≠ -1 := by
  classical
  by_cases hFp : ringChar F = p
  · rw [show (p : F) = 0 by rw [← hFp]; exact ringChar.Nat.cast_ringChar]
    simp only [isSquare_zero, Ne.def, true_iff_iff, map_mul]
    obtain ⟨n, _, hc⟩ := FiniteField.card F (ringChar F)
    have hchar : ringChar F = ringChar (ZMod p) := by rw [hFp]; exact (ring_char_zmod_n p).symm
    conv =>
      congr
      lhs
      congr
      skip
      rw [hc, Nat.cast_pow, map_pow, hchar, map_ring_char]
    simp only [zero_pow n.pos, MulZeroClass.mul_zero, zero_eq_neg, one_ne_zero, not_false_iff]
  · rw [← Iff.not_left (@quadraticChar_neg_one_iff_not_isSquare F _ _ _ _),
      quadraticChar_odd_prime hF hp]
    exact hFp
#align finite_field.is_square_odd_prime_iff FiniteField.isSquare_odd_prime_iff
-/

end SpecialValues

