/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Floris van Doorn, Amelia Livingston, Yury Kudryashov,
Neil Strickland, Aaron Anderson

! This file was ported from Lean 3 source module algebra.divisibility.basic
! leanprover-community/mathlib commit e8638a0fcaf73e4500469f368ef9494e495099b3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.Group

/-!
# Divisibility

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the basics of the divisibility relation in the context of `(comm_)` `monoid`s.

## Main definitions

 * `monoid.has_dvd`

## Implementation notes

The divisibility relation is defined for all monoids, and as such, depends on the order of
  multiplication if the monoid is not commutative. There are two possible conventions for
  divisibility in the noncommutative context, and this relation follows the convention for ordinals,
  so `a | b` is defined as `∃ c, b = a * c`.

## Tags

divisibility, divides
-/


variable {α : Type _}

section Semigroup

variable [Semigroup α] {a b c : α}

#print semigroupDvd /-
/-- There are two possible conventions for divisibility, which coincide in a `comm_monoid`.
    This matches the convention for ordinals. -/
instance (priority := 100) semigroupDvd : Dvd α :=
  Dvd.mk fun a b => ∃ c, b = a * c
#align semigroup_has_dvd semigroupDvd
-/

#print Dvd.intro /-
-- TODO: this used to not have `c` explicit, but that seems to be important
--       for use with tactics, similar to `exists.intro`
theorem Dvd.intro (c : α) (h : a * c = b) : a ∣ b :=
  Exists.intro c h.symm
#align dvd.intro Dvd.intro
-/

alias Dvd.intro ← dvd_of_mul_right_eq
#align dvd_of_mul_right_eq dvd_of_mul_right_eq

#print exists_eq_mul_right_of_dvd /-
theorem exists_eq_mul_right_of_dvd (h : a ∣ b) : ∃ c, b = a * c :=
  h
#align exists_eq_mul_right_of_dvd exists_eq_mul_right_of_dvd
-/

#print Dvd.elim /-
theorem Dvd.elim {P : Prop} {a b : α} (H₁ : a ∣ b) (H₂ : ∀ c, b = a * c → P) : P :=
  Exists.elim H₁ H₂
#align dvd.elim Dvd.elim
-/

attribute [local simp] mul_assoc mul_comm mul_left_comm

#print dvd_trans /-
@[trans]
theorem dvd_trans : a ∣ b → b ∣ c → a ∣ c
  | ⟨d, h₁⟩, ⟨e, h₂⟩ => ⟨d * e, h₁ ▸ h₂.trans <| mul_assoc a d e⟩
#align dvd_trans dvd_trans
-/

alias dvd_trans ← Dvd.Dvd.trans
#align has_dvd.dvd.trans Dvd.Dvd.trans

instance : IsTrans α (· ∣ ·) :=
  ⟨fun a b c => dvd_trans⟩

#print dvd_mul_right /-
@[simp]
theorem dvd_mul_right (a b : α) : a ∣ a * b :=
  Dvd.intro b rfl
#align dvd_mul_right dvd_mul_right
-/

#print dvd_mul_of_dvd_left /-
theorem dvd_mul_of_dvd_left (h : a ∣ b) (c : α) : a ∣ b * c :=
  h.trans (dvd_mul_right b c)
#align dvd_mul_of_dvd_left dvd_mul_of_dvd_left
-/

alias dvd_mul_of_dvd_left ← Dvd.Dvd.mul_right
#align has_dvd.dvd.mul_right Dvd.Dvd.mul_right

#print dvd_of_mul_right_dvd /-
theorem dvd_of_mul_right_dvd (h : a * b ∣ c) : a ∣ c :=
  (dvd_mul_right a b).trans h
#align dvd_of_mul_right_dvd dvd_of_mul_right_dvd
-/

section map_dvd

variable {M N : Type _} [Monoid M] [Monoid N]

#print map_dvd /-
theorem map_dvd {F : Type _} [MulHomClass F M N] (f : F) {a b} : a ∣ b → f a ∣ f b
  | ⟨c, h⟩ => ⟨f c, h.symm ▸ map_mul f a c⟩
#align map_dvd map_dvd
-/

#print MulHom.map_dvd /-
theorem MulHom.map_dvd (f : M →ₙ* N) {a b} : a ∣ b → f a ∣ f b :=
  map_dvd f
#align mul_hom.map_dvd MulHom.map_dvd
-/

#print MonoidHom.map_dvd /-
theorem MonoidHom.map_dvd (f : M →* N) {a b} : a ∣ b → f a ∣ f b :=
  map_dvd f
#align monoid_hom.map_dvd MonoidHom.map_dvd
-/

end map_dvd

end Semigroup

section Monoid

variable [Monoid α] {a b : α}

#print dvd_refl /-
@[refl, simp]
theorem dvd_refl (a : α) : a ∣ a :=
  Dvd.intro 1 (mul_one a)
#align dvd_refl dvd_refl
-/

#print dvd_rfl /-
theorem dvd_rfl : ∀ {a : α}, a ∣ a :=
  dvd_refl
#align dvd_rfl dvd_rfl
-/

instance : IsRefl α (· ∣ ·) :=
  ⟨dvd_refl⟩

#print one_dvd /-
theorem one_dvd (a : α) : 1 ∣ a :=
  Dvd.intro a (one_mul a)
#align one_dvd one_dvd
-/

#print dvd_of_eq /-
theorem dvd_of_eq (h : a = b) : a ∣ b := by rw [h]
#align dvd_of_eq dvd_of_eq
-/

alias dvd_of_eq ← Eq.dvd
#align eq.dvd Eq.dvd

end Monoid

section CommSemigroup

variable [CommSemigroup α] {a b c : α}

#print Dvd.intro_left /-
theorem Dvd.intro_left (c : α) (h : c * a = b) : a ∣ b :=
  Dvd.intro _ (by rw [mul_comm] at h ; apply h)
#align dvd.intro_left Dvd.intro_left
-/

alias Dvd.intro_left ← dvd_of_mul_left_eq
#align dvd_of_mul_left_eq dvd_of_mul_left_eq

#print exists_eq_mul_left_of_dvd /-
theorem exists_eq_mul_left_of_dvd (h : a ∣ b) : ∃ c, b = c * a :=
  Dvd.elim h fun c => fun H1 : b = a * c => Exists.intro c (Eq.trans H1 (mul_comm a c))
#align exists_eq_mul_left_of_dvd exists_eq_mul_left_of_dvd
-/

#print dvd_iff_exists_eq_mul_left /-
theorem dvd_iff_exists_eq_mul_left : a ∣ b ↔ ∃ c, b = c * a :=
  ⟨exists_eq_mul_left_of_dvd, by rintro ⟨c, rfl⟩; exact ⟨c, mul_comm _ _⟩⟩
#align dvd_iff_exists_eq_mul_left dvd_iff_exists_eq_mul_left
-/

#print Dvd.elim_left /-
theorem Dvd.elim_left {P : Prop} (h₁ : a ∣ b) (h₂ : ∀ c, b = c * a → P) : P :=
  Exists.elim (exists_eq_mul_left_of_dvd h₁) fun c => fun h₃ : b = c * a => h₂ c h₃
#align dvd.elim_left Dvd.elim_left
-/

#print dvd_mul_left /-
@[simp]
theorem dvd_mul_left (a b : α) : a ∣ b * a :=
  Dvd.intro b (mul_comm a b)
#align dvd_mul_left dvd_mul_left
-/

#print dvd_mul_of_dvd_right /-
theorem dvd_mul_of_dvd_right (h : a ∣ b) (c : α) : a ∣ c * b := by rw [mul_comm];
  exact h.mul_right _
#align dvd_mul_of_dvd_right dvd_mul_of_dvd_right
-/

alias dvd_mul_of_dvd_right ← Dvd.Dvd.mul_left
#align has_dvd.dvd.mul_left Dvd.Dvd.mul_left

attribute [local simp] mul_assoc mul_comm mul_left_comm

#print mul_dvd_mul /-
theorem mul_dvd_mul : ∀ {a b c d : α}, a ∣ b → c ∣ d → a * c ∣ b * d
  | a, _, c, _, ⟨e, rfl⟩, ⟨f, rfl⟩ => ⟨e * f, by simp⟩
#align mul_dvd_mul mul_dvd_mul
-/

#print dvd_of_mul_left_dvd /-
theorem dvd_of_mul_left_dvd (h : a * b ∣ c) : b ∣ c :=
  Dvd.elim h fun d ceq => Dvd.intro (a * d) (by simp [ceq])
#align dvd_of_mul_left_dvd dvd_of_mul_left_dvd
-/

end CommSemigroup

section CommMonoid

variable [CommMonoid α] {a b : α}

#print mul_dvd_mul_left /-
theorem mul_dvd_mul_left (a : α) {b c : α} (h : b ∣ c) : a * b ∣ a * c :=
  mul_dvd_mul (dvd_refl a) h
#align mul_dvd_mul_left mul_dvd_mul_left
-/

#print mul_dvd_mul_right /-
theorem mul_dvd_mul_right (h : a ∣ b) (c : α) : a * c ∣ b * c :=
  mul_dvd_mul h (dvd_refl c)
#align mul_dvd_mul_right mul_dvd_mul_right
-/

#print pow_dvd_pow_of_dvd /-
theorem pow_dvd_pow_of_dvd {a b : α} (h : a ∣ b) : ∀ n : ℕ, a ^ n ∣ b ^ n
  | 0 => by rw [pow_zero, pow_zero]
  | n + 1 => by rw [pow_succ, pow_succ]; exact mul_dvd_mul h (pow_dvd_pow_of_dvd n)
#align pow_dvd_pow_of_dvd pow_dvd_pow_of_dvd
-/

end CommMonoid

