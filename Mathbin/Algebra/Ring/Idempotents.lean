/-
Copyright (c) 2022 Christopher Hoskin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Christopher Hoskin
-/
import Mathbin.Algebra.Ring.Basic
import Mathbin.Algebra.GroupPower.Basic
import Mathbin.Tactic.NthRewrite.Default

/-!
# Idempotents

This file defines idempotents for an arbitary multiplication and proves some basic results,
including:

* `is_idempotent_elem.mul_of_commute`: In a semigroup, the product of two commuting idempotents is
  an idempotent;
* `is_idempotent_elem.one_sub_iff`: In a (non-associative) ring, `p` is an idempotent if and only if
  `1-p` is an idempotent.
* `is_idempotent_elem.pow_succ_eq`: In a monoid `p ^ (n+1) = p` for `p` an idempotent and `n` a
  natural number.

## Tags

projection, idempotent
-/


variable {M N S M₀ M₁ R G G₀ : Type _}

variable [Mul M] [Monoidₓ N] [Semigroupₓ S] [MulZeroClassₓ M₀] [MulOneClassₓ M₁] [NonAssocRing R] [Groupₓ G]
  [GroupWithZeroₓ G₀]

/-- An element `p` is said to be idempotent if `p * p = p`
-/
def IsIdempotentElem (p : M) : Prop :=
  p * p = p

namespace IsIdempotentElem

theorem of_is_idempotent [IsIdempotent M (· * ·)] (a : M) : IsIdempotentElem a :=
  IsIdempotent.idempotent a

theorem eq {p : M} (h : IsIdempotentElem p) : p * p = p :=
  h

theorem mul_of_commute {p q : S} (h : Commute p q) (h₁ : IsIdempotentElem p) (h₂ : IsIdempotentElem q) :
    IsIdempotentElem (p * q) := by
  rw [IsIdempotentElem, mul_assoc, ← mul_assoc q, ← h.eq, mul_assoc p, h₂.eq, ← mul_assoc, h₁.eq]

theorem zero : IsIdempotentElem (0 : M₀) :=
  mul_zero _

theorem one : IsIdempotentElem (1 : M₁) :=
  mul_oneₓ _

theorem one_sub {p : R} (h : IsIdempotentElem p) : IsIdempotentElem (1 - p) := by
  rw [IsIdempotentElem] at h
  rw [IsIdempotentElem, mul_sub_left_distrib, mul_oneₓ, sub_mul, one_mulₓ, h, sub_self, sub_zero]

@[simp]
theorem one_sub_iff {p : R} : IsIdempotentElem (1 - p) ↔ IsIdempotentElem p :=
  ⟨fun h => sub_sub_cancel 1 p ▸ h.one_sub, IsIdempotentElem.one_sub⟩

theorem pow {p : N} (n : ℕ) (h : IsIdempotentElem p) : IsIdempotentElem (p ^ n) := by
  induction' n with n ih
  · rw [pow_zeroₓ]
    apply one
    
  · unfold IsIdempotentElem
    rw [pow_succₓ, ← mul_assoc, ← pow_mul_comm', mul_assoc (p ^ n), h.eq, pow_mul_comm', mul_assoc, ih.eq]
    

theorem pow_succ_eq {p : N} (n : ℕ) (h : IsIdempotentElem p) : p ^ (n + 1) = p := by
  induction' n with n ih
  · rw [Nat.zero_add, pow_oneₓ]
    
  · rw [pow_succₓ, ih, h.eq]
    

@[simp]
theorem iff_eq_one {p : G} : IsIdempotentElem p ↔ p = 1 := by
  constructor
  · intro h
    rw [← mul_left_invₓ p]
    nth_rw_rhs 1[← h.eq]
    rw [← mul_assoc, mul_left_invₓ, one_mulₓ]
    
  · intro h
    rw [h]
    apply one
    

@[simp]
theorem iff_eq_zero_or_one {p : G₀} : IsIdempotentElem p ↔ p = 0 ∨ p = 1 := by
  refine' ⟨fun h => or_iff_not_imp_left.mpr fun hp => _, _⟩
  · rw [← mul_inv_cancel hp]
    nth_rw_rhs 0[← h.eq]
    rw [mul_assoc, mul_inv_cancel hp, mul_oneₓ]
    
  · rintro (h₁ | h₂)
    · rw [h₁]
      exact zero
      
    · rw [h₂]
      exact one
      
    

/-! ### Instances on `subtype is_idempotent_elem` -/


section Instances

instance : Zero { p : M₀ // IsIdempotentElem p } where
  zero := ⟨0, zero⟩

@[simp]
theorem coe_zero : ↑(0 : { p : M₀ // IsIdempotentElem p }) = (0 : M₀) :=
  rfl

instance : One { p : M₁ // IsIdempotentElem p } where
  one := ⟨1, one⟩

@[simp]
theorem coe_one : ↑(1 : { p : M₁ // IsIdempotentElem p }) = (1 : M₁) :=
  rfl

instance : HasCompl { p : R // IsIdempotentElem p } :=
  ⟨fun p => ⟨1 - p, p.Prop.one_sub⟩⟩

@[simp]
theorem coe_compl (p : { p : R // IsIdempotentElem p }) : ↑(pᶜ) = (1 : R) - ↑p :=
  rfl

@[simp]
theorem compl_compl (p : { p : R // IsIdempotentElem p }) : pᶜᶜ = p :=
  Subtype.ext <| sub_sub_cancel _ _

@[simp]
theorem zero_compl : (0 : { p : R // IsIdempotentElem p })ᶜ = 1 :=
  Subtype.ext <| sub_zero _

@[simp]
theorem one_compl : (1 : { p : R // IsIdempotentElem p })ᶜ = 0 :=
  Subtype.ext <| sub_self _

end Instances

end IsIdempotentElem

