/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Devon Tuma

! This file was ported from Lean 3 source module ring_theory.non_zero_divisors
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Submonoid.Operations
import Mathbin.GroupTheory.Submonoid.Membership

/-!
# Non-zero divisors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define the submonoid `non_zero_divisors` of a `monoid_with_zero`.

## Notations

This file declares the notation `R⁰` for the submonoid of non-zero-divisors of `R`,
in the locale `non_zero_divisors`. Use the statement `open_locale non_zero_divisors`
to access this notation in your own code.

-/


section nonZeroDivisors

#print nonZeroDivisors /-
/-- The submonoid of non-zero-divisors of a `monoid_with_zero` `R`. -/
def nonZeroDivisors (R : Type _) [MonoidWithZero R] : Submonoid R
    where
  carrier := {x | ∀ z, z * x = 0 → z = 0}
  one_mem' z hz := by rwa [mul_one] at hz 
  mul_mem' x₁ x₂ hx₁ hx₂ z hz :=
    have : z * x₁ * x₂ = 0 := by rwa [mul_assoc]
    hx₁ z <| hx₂ (z * x₁) this
#align non_zero_divisors nonZeroDivisors
-/

scoped[nonZeroDivisors] notation:9000 R "⁰" => nonZeroDivisors R

variable {M M' M₁ R R' F : Type _} [MonoidWithZero M] [MonoidWithZero M'] [CommMonoidWithZero M₁]
  [Ring R] [CommRing R']

#print mem_nonZeroDivisors_iff /-
theorem mem_nonZeroDivisors_iff {r : M} : r ∈ M⁰ ↔ ∀ x, x * r = 0 → x = 0 :=
  Iff.rfl
#align mem_non_zero_divisors_iff mem_nonZeroDivisors_iff
-/

#print mul_right_mem_nonZeroDivisors_eq_zero_iff /-
theorem mul_right_mem_nonZeroDivisors_eq_zero_iff {x r : M} (hr : r ∈ M⁰) : x * r = 0 ↔ x = 0 :=
  ⟨hr _, by simp (config := { contextual := true })⟩
#align mul_right_mem_non_zero_divisors_eq_zero_iff mul_right_mem_nonZeroDivisors_eq_zero_iff
-/

#print mul_right_coe_nonZeroDivisors_eq_zero_iff /-
@[simp]
theorem mul_right_coe_nonZeroDivisors_eq_zero_iff {x : M} {c : M⁰} : x * c = 0 ↔ x = 0 :=
  mul_right_mem_nonZeroDivisors_eq_zero_iff c.Prop
#align mul_right_coe_non_zero_divisors_eq_zero_iff mul_right_coe_nonZeroDivisors_eq_zero_iff
-/

#print mul_left_mem_nonZeroDivisors_eq_zero_iff /-
theorem mul_left_mem_nonZeroDivisors_eq_zero_iff {r x : M₁} (hr : r ∈ M₁⁰) : r * x = 0 ↔ x = 0 := by
  rw [mul_comm, mul_right_mem_nonZeroDivisors_eq_zero_iff hr]
#align mul_left_mem_non_zero_divisors_eq_zero_iff mul_left_mem_nonZeroDivisors_eq_zero_iff
-/

#print mul_left_coe_nonZeroDivisors_eq_zero_iff /-
@[simp]
theorem mul_left_coe_nonZeroDivisors_eq_zero_iff {c : M₁⁰} {x : M₁} : (c : M₁) * x = 0 ↔ x = 0 :=
  mul_left_mem_nonZeroDivisors_eq_zero_iff c.Prop
#align mul_left_coe_non_zero_divisors_eq_zero_iff mul_left_coe_nonZeroDivisors_eq_zero_iff
-/

#print mul_cancel_right_mem_nonZeroDivisors /-
theorem mul_cancel_right_mem_nonZeroDivisors {x y r : R} (hr : r ∈ R⁰) : x * r = y * r ↔ x = y :=
  by
  refine' ⟨fun h => _, congr_arg _⟩
  rw [← sub_eq_zero, ← mul_right_mem_nonZeroDivisors_eq_zero_iff hr, sub_mul, h, sub_self]
#align mul_cancel_right_mem_non_zero_divisor mul_cancel_right_mem_nonZeroDivisors
-/

#print mul_cancel_right_coe_nonZeroDivisors /-
theorem mul_cancel_right_coe_nonZeroDivisors {x y : R} {c : R⁰} : x * c = y * c ↔ x = y :=
  mul_cancel_right_mem_nonZeroDivisors c.Prop
#align mul_cancel_right_coe_non_zero_divisor mul_cancel_right_coe_nonZeroDivisors
-/

#print mul_cancel_left_mem_nonZeroDivisors /-
@[simp]
theorem mul_cancel_left_mem_nonZeroDivisors {x y r : R'} (hr : r ∈ R'⁰) : r * x = r * y ↔ x = y :=
  by simp_rw [mul_comm r, mul_cancel_right_mem_nonZeroDivisors hr]
#align mul_cancel_left_mem_non_zero_divisor mul_cancel_left_mem_nonZeroDivisors
-/

#print mul_cancel_left_coe_nonZeroDivisors /-
theorem mul_cancel_left_coe_nonZeroDivisors {x y : R'} {c : R'⁰} : (c : R') * x = c * y ↔ x = y :=
  mul_cancel_left_mem_nonZeroDivisors c.Prop
#align mul_cancel_left_coe_non_zero_divisor mul_cancel_left_coe_nonZeroDivisors
-/

#print nonZeroDivisors.ne_zero /-
theorem nonZeroDivisors.ne_zero [Nontrivial M] {x} (hx : x ∈ M⁰) : x ≠ 0 := fun h =>
  one_ne_zero (hx _ <| (one_mul _).trans h)
#align non_zero_divisors.ne_zero nonZeroDivisors.ne_zero
-/

#print nonZeroDivisors.coe_ne_zero /-
theorem nonZeroDivisors.coe_ne_zero [Nontrivial M] (x : M⁰) : (x : M) ≠ 0 :=
  nonZeroDivisors.ne_zero x.2
#align non_zero_divisors.coe_ne_zero nonZeroDivisors.coe_ne_zero
-/

#print mul_mem_nonZeroDivisors /-
theorem mul_mem_nonZeroDivisors {a b : M₁} : a * b ∈ M₁⁰ ↔ a ∈ M₁⁰ ∧ b ∈ M₁⁰ :=
  by
  constructor
  · intro h
    constructor <;> intro x h' <;> apply h
    · rw [← mul_assoc, h', MulZeroClass.zero_mul]
    · rw [mul_comm a b, ← mul_assoc, h', MulZeroClass.zero_mul]
  · rintro ⟨ha, hb⟩ x hx
    apply ha
    apply hb
    rw [mul_assoc, hx]
#align mul_mem_non_zero_divisors mul_mem_nonZeroDivisors
-/

#print isUnit_of_mem_nonZeroDivisors /-
theorem isUnit_of_mem_nonZeroDivisors {G₀ : Type _} [GroupWithZero G₀] {x : G₀}
    (hx : x ∈ nonZeroDivisors G₀) : IsUnit x :=
  ⟨⟨x, x⁻¹, mul_inv_cancel (nonZeroDivisors.ne_zero hx),
      inv_mul_cancel (nonZeroDivisors.ne_zero hx)⟩,
    rfl⟩
#align is_unit_of_mem_non_zero_divisors isUnit_of_mem_nonZeroDivisors
-/

#print eq_zero_of_ne_zero_of_mul_right_eq_zero /-
theorem eq_zero_of_ne_zero_of_mul_right_eq_zero [NoZeroDivisors M] {x y : M} (hnx : x ≠ 0)
    (hxy : y * x = 0) : y = 0 :=
  Or.resolve_right (eq_zero_or_eq_zero_of_mul_eq_zero hxy) hnx
#align eq_zero_of_ne_zero_of_mul_right_eq_zero eq_zero_of_ne_zero_of_mul_right_eq_zero
-/

#print eq_zero_of_ne_zero_of_mul_left_eq_zero /-
theorem eq_zero_of_ne_zero_of_mul_left_eq_zero [NoZeroDivisors M] {x y : M} (hnx : x ≠ 0)
    (hxy : x * y = 0) : y = 0 :=
  Or.resolve_left (eq_zero_or_eq_zero_of_mul_eq_zero hxy) hnx
#align eq_zero_of_ne_zero_of_mul_left_eq_zero eq_zero_of_ne_zero_of_mul_left_eq_zero
-/

#print mem_nonZeroDivisors_of_ne_zero /-
theorem mem_nonZeroDivisors_of_ne_zero [NoZeroDivisors M] {x : M} (hx : x ≠ 0) : x ∈ M⁰ := fun _ =>
  eq_zero_of_ne_zero_of_mul_right_eq_zero hx
#align mem_non_zero_divisors_of_ne_zero mem_nonZeroDivisors_of_ne_zero
-/

#print mem_nonZeroDivisors_iff_ne_zero /-
theorem mem_nonZeroDivisors_iff_ne_zero [NoZeroDivisors M] [Nontrivial M] {x : M} :
    x ∈ M⁰ ↔ x ≠ 0 :=
  ⟨nonZeroDivisors.ne_zero, mem_nonZeroDivisors_of_ne_zero⟩
#align mem_non_zero_divisors_iff_ne_zero mem_nonZeroDivisors_iff_ne_zero
-/

#print map_ne_zero_of_mem_nonZeroDivisors /-
theorem map_ne_zero_of_mem_nonZeroDivisors [Nontrivial M] [ZeroHomClass F M M'] (g : F)
    (hg : Function.Injective (g : M → M')) {x : M} (h : x ∈ M⁰) : g x ≠ 0 := fun h0 =>
  one_ne_zero (h 1 ((one_mul x).symm ▸ hg (trans h0 (map_zero g).symm)))
#align map_ne_zero_of_mem_non_zero_divisors map_ne_zero_of_mem_nonZeroDivisors
-/

#print map_mem_nonZeroDivisors /-
theorem map_mem_nonZeroDivisors [Nontrivial M] [NoZeroDivisors M'] [ZeroHomClass F M M'] (g : F)
    (hg : Function.Injective g) {x : M} (h : x ∈ M⁰) : g x ∈ M'⁰ := fun z hz =>
  eq_zero_of_ne_zero_of_mul_right_eq_zero (map_ne_zero_of_mem_nonZeroDivisors g hg h) hz
#align map_mem_non_zero_divisors map_mem_nonZeroDivisors
-/

#print le_nonZeroDivisors_of_noZeroDivisors /-
theorem le_nonZeroDivisors_of_noZeroDivisors [NoZeroDivisors M] {S : Submonoid M}
    (hS : (0 : M) ∉ S) : S ≤ M⁰ := fun x hx y hy =>
  Or.rec_on (eq_zero_or_eq_zero_of_mul_eq_zero hy) (fun h => h) fun h =>
    absurd (h ▸ hx : (0 : M) ∈ S) hS
#align le_non_zero_divisors_of_no_zero_divisors le_nonZeroDivisors_of_noZeroDivisors
-/

#print powers_le_nonZeroDivisors_of_noZeroDivisors /-
theorem powers_le_nonZeroDivisors_of_noZeroDivisors [NoZeroDivisors M] {a : M} (ha : a ≠ 0) :
    Submonoid.powers a ≤ M⁰ :=
  le_nonZeroDivisors_of_noZeroDivisors fun h => absurd (h.recOn fun _ hn => pow_eq_zero hn) ha
#align powers_le_non_zero_divisors_of_no_zero_divisors powers_le_nonZeroDivisors_of_noZeroDivisors
-/

#print map_le_nonZeroDivisors_of_injective /-
theorem map_le_nonZeroDivisors_of_injective [NoZeroDivisors M'] [MonoidWithZeroHomClass F M M']
    (f : F) (hf : Function.Injective f) {S : Submonoid M} (hS : S ≤ M⁰) : S.map f ≤ M'⁰ :=
  by
  cases subsingleton_or_nontrivial M
  · simp [Subsingleton.elim S ⊥]
  ·
    exact
      le_nonZeroDivisors_of_noZeroDivisors fun h =>
        let ⟨x, hx, hx0⟩ := h
        zero_ne_one
          (hS (hf (trans hx0 (map_zero f).symm) ▸ hx : 0 ∈ S) 1 (MulZeroClass.mul_zero 1)).symm
#align map_le_non_zero_divisors_of_injective map_le_nonZeroDivisors_of_injective
-/

#print nonZeroDivisors_le_comap_nonZeroDivisors_of_injective /-
theorem nonZeroDivisors_le_comap_nonZeroDivisors_of_injective [NoZeroDivisors M']
    [MonoidWithZeroHomClass F M M'] (f : F) (hf : Function.Injective f) : M⁰ ≤ M'⁰.comap f :=
  Submonoid.le_comap_of_map_le _ (map_le_nonZeroDivisors_of_injective _ hf le_rfl)
#align non_zero_divisors_le_comap_non_zero_divisors_of_injective nonZeroDivisors_le_comap_nonZeroDivisors_of_injective
-/

#print prod_zero_iff_exists_zero /-
theorem prod_zero_iff_exists_zero [NoZeroDivisors M₁] [Nontrivial M₁] {s : Multiset M₁} :
    s.Prod = 0 ↔ ∃ (r : M₁) (hr : r ∈ s), r = 0 :=
  by
  constructor; swap
  · rintro ⟨r, hrs, rfl⟩
    exact Multiset.prod_eq_zero hrs
  refine' Multiset.induction _ (fun a s ih => _) s
  · intro habs
    simpa using habs
  · rw [Multiset.prod_cons]
    intro hprod
    replace hprod := eq_zero_or_eq_zero_of_mul_eq_zero hprod
    cases' hprod with ha
    · exact ⟨a, Multiset.mem_cons_self a s, ha⟩
    · apply (ih hprod).imp _
      rintro b ⟨hb₁, hb₂⟩
      exact ⟨Multiset.mem_cons_of_mem hb₁, hb₂⟩
#align prod_zero_iff_exists_zero prod_zero_iff_exists_zero
-/

end nonZeroDivisors

