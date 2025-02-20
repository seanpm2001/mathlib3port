/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module ring_theory.polynomial.content
! leanprover-community/mathlib commit cb3ceec8485239a61ed51d944cb9a95b68c6bafc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GcdMonoid.Finset
import Mathbin.Data.Polynomial.FieldDivision
import Mathbin.Data.Polynomial.EraseLead
import Mathbin.Data.Polynomial.CancelLeads

/-!
# GCD structures on polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Definitions and basic results about polynomials over GCD domains, particularly their contents
and primitive polynomials.

## Main Definitions
Let `p : R[X]`.
 - `p.content` is the `gcd` of the coefficients of `p`.
 - `p.is_primitive` indicates that `p.content = 1`.

## Main Results
 - `polynomial.content_mul`:
  If `p q : R[X]`, then `(p * q).content = p.content * q.content`.
 - `polynomial.normalized_gcd_monoid`:
  The polynomial ring of a GCD domain is itself a GCD domain.

-/


namespace Polynomial

open scoped Polynomial

section Primitive

variable {R : Type _} [CommSemiring R]

#print Polynomial.IsPrimitive /-
/-- A polynomial is primitive when the only constant polynomials dividing it are units -/
def IsPrimitive (p : R[X]) : Prop :=
  ∀ r : R, C r ∣ p → IsUnit r
#align polynomial.is_primitive Polynomial.IsPrimitive
-/

#print Polynomial.isPrimitive_iff_isUnit_of_C_dvd /-
theorem isPrimitive_iff_isUnit_of_C_dvd {p : R[X]} : p.IsPrimitive ↔ ∀ r : R, C r ∣ p → IsUnit r :=
  Iff.rfl
#align polynomial.is_primitive_iff_is_unit_of_C_dvd Polynomial.isPrimitive_iff_isUnit_of_C_dvd
-/

#print Polynomial.isPrimitive_one /-
@[simp]
theorem isPrimitive_one : IsPrimitive (1 : R[X]) := fun r h =>
  isUnit_C.mp (isUnit_of_dvd_one (C r) h)
#align polynomial.is_primitive_one Polynomial.isPrimitive_one
-/

#print Polynomial.Monic.isPrimitive /-
theorem Monic.isPrimitive {p : R[X]} (hp : p.Monic) : p.IsPrimitive :=
  by
  rintro r ⟨q, h⟩
  exact isUnit_of_mul_eq_one r (q.coeff p.nat_degree) (by rwa [← coeff_C_mul, ← h])
#align polynomial.monic.is_primitive Polynomial.Monic.isPrimitive
-/

#print Polynomial.IsPrimitive.ne_zero /-
theorem IsPrimitive.ne_zero [Nontrivial R] {p : R[X]} (hp : p.IsPrimitive) : p ≠ 0 :=
  by
  rintro rfl
  exact (hp 0 (dvd_zero (C 0))).NeZero rfl
#align polynomial.is_primitive.ne_zero Polynomial.IsPrimitive.ne_zero
-/

#print Polynomial.isPrimitive_of_dvd /-
theorem isPrimitive_of_dvd {p q : R[X]} (hp : IsPrimitive p) (hq : q ∣ p) : IsPrimitive q :=
  fun a ha => isPrimitive_iff_isUnit_of_C_dvd.mp hp a (dvd_trans ha hq)
#align polynomial.is_primitive_of_dvd Polynomial.isPrimitive_of_dvd
-/

end Primitive

variable {R : Type _} [CommRing R] [IsDomain R]

section NormalizedGCDMonoid

variable [NormalizedGCDMonoid R]

#print Polynomial.content /-
/-- `p.content` is the `gcd` of the coefficients of `p`. -/
def content (p : R[X]) : R :=
  p.support.gcd p.coeff
#align polynomial.content Polynomial.content
-/

#print Polynomial.content_dvd_coeff /-
theorem content_dvd_coeff {p : R[X]} (n : ℕ) : p.content ∣ p.coeff n :=
  by
  by_cases h : n ∈ p.support
  · apply Finset.gcd_dvd h
  rw [mem_support_iff, Classical.not_not] at h 
  rw [h]
  apply dvd_zero
#align polynomial.content_dvd_coeff Polynomial.content_dvd_coeff
-/

#print Polynomial.content_C /-
@[simp]
theorem content_C {r : R} : (C r).content = normalize r :=
  by
  rw [content]
  by_cases h0 : r = 0
  · simp [h0]
  have h : (C r).support = {0} := support_monomial _ h0
  simp [h]
#align polynomial.content_C Polynomial.content_C
-/

#print Polynomial.content_zero /-
@[simp]
theorem content_zero : content (0 : R[X]) = 0 := by rw [← C_0, content_C, normalize_zero]
#align polynomial.content_zero Polynomial.content_zero
-/

#print Polynomial.content_one /-
@[simp]
theorem content_one : content (1 : R[X]) = 1 := by rw [← C_1, content_C, normalize_one]
#align polynomial.content_one Polynomial.content_one
-/

#print Polynomial.content_X_mul /-
theorem content_X_mul {p : R[X]} : content (X * p) = content p :=
  by
  rw [content, content, Finset.gcd_def, Finset.gcd_def]
  refine' congr rfl _
  have h : (X * p).support = p.support.map ⟨Nat.succ, Nat.succ_injective⟩ :=
    by
    ext a
    simp only [exists_prop, Finset.mem_map, Function.Embedding.coeFn_mk, Ne.def, mem_support_iff]
    cases a
    · simp [coeff_X_mul_zero, Nat.succ_ne_zero]
    rw [mul_comm, coeff_mul_X]
    constructor
    · intro h
      use a
      simp [h]
    · rintro ⟨b, ⟨h1, h2⟩⟩
      rw [← Nat.succ_injective h2]
      apply h1
  rw [h]
  simp only [Finset.map_val, Function.comp_apply, Function.Embedding.coeFn_mk, Multiset.map_map]
  refine' congr (congr rfl _) rfl
  ext a
  rw [mul_comm]
  simp [coeff_mul_X]
#align polynomial.content_X_mul Polynomial.content_X_mul
-/

#print Polynomial.content_X_pow /-
@[simp]
theorem content_X_pow {k : ℕ} : content ((X : R[X]) ^ k) = 1 :=
  by
  induction' k with k hi
  · simp
  rw [pow_succ, content_X_mul, hi]
#align polynomial.content_X_pow Polynomial.content_X_pow
-/

#print Polynomial.content_X /-
@[simp]
theorem content_X : content (X : R[X]) = 1 := by rw [← mul_one X, content_X_mul, content_one]
#align polynomial.content_X Polynomial.content_X
-/

#print Polynomial.content_C_mul /-
theorem content_C_mul (r : R) (p : R[X]) : (C r * p).content = normalize r * p.content :=
  by
  by_cases h0 : r = 0; · simp [h0]
  rw [content]; rw [content]; rw [← Finset.gcd_mul_left]
  refine' congr (congr rfl _) _ <;> ext <;> simp [h0, mem_support_iff]
#align polynomial.content_C_mul Polynomial.content_C_mul
-/

#print Polynomial.content_monomial /-
@[simp]
theorem content_monomial {r : R} {k : ℕ} : content (monomial k r) = normalize r := by
  rw [← C_mul_X_pow_eq_monomial, content_C_mul, content_X_pow, mul_one]
#align polynomial.content_monomial Polynomial.content_monomial
-/

#print Polynomial.content_eq_zero_iff /-
theorem content_eq_zero_iff {p : R[X]} : content p = 0 ↔ p = 0 :=
  by
  rw [content, Finset.gcd_eq_zero_iff]
  constructor <;> intro h
  · ext n
    by_cases h0 : n ∈ p.support
    · rw [h n h0, coeff_zero]
    · rw [mem_support_iff] at h0 
      push_neg at h0 
      simp [h0]
  · intro x h0
    simp [h]
#align polynomial.content_eq_zero_iff Polynomial.content_eq_zero_iff
-/

#print Polynomial.normalize_content /-
@[simp]
theorem normalize_content {p : R[X]} : normalize p.content = p.content :=
  Finset.normalize_gcd
#align polynomial.normalize_content Polynomial.normalize_content
-/

#print Polynomial.content_eq_gcd_range_of_lt /-
theorem content_eq_gcd_range_of_lt (p : R[X]) (n : ℕ) (h : p.natDegree < n) :
    p.content = (Finset.range n).gcd p.coeff :=
  by
  apply dvd_antisymm_of_normalize_eq normalize_content Finset.normalize_gcd
  · rw [Finset.dvd_gcd_iff]
    intro i hi
    apply content_dvd_coeff _
  · apply Finset.gcd_mono
    intro i
    simp only [Nat.lt_succ_iff, mem_support_iff, Ne.def, Finset.mem_range]
    contrapose!
    intro h1
    apply coeff_eq_zero_of_nat_degree_lt (lt_of_lt_of_le h h1)
#align polynomial.content_eq_gcd_range_of_lt Polynomial.content_eq_gcd_range_of_lt
-/

#print Polynomial.content_eq_gcd_range_succ /-
theorem content_eq_gcd_range_succ (p : R[X]) :
    p.content = (Finset.range p.natDegree.succ).gcd p.coeff :=
  content_eq_gcd_range_of_lt _ _ (Nat.lt_succ_self _)
#align polynomial.content_eq_gcd_range_succ Polynomial.content_eq_gcd_range_succ
-/

#print Polynomial.content_eq_gcd_leadingCoeff_content_eraseLead /-
theorem content_eq_gcd_leadingCoeff_content_eraseLead (p : R[X]) :
    p.content = GCDMonoid.gcd p.leadingCoeff (eraseLead p).content :=
  by
  by_cases h : p = 0
  · simp [h]
  rw [← leading_coeff_eq_zero, leading_coeff, ← Ne.def, ← mem_support_iff] at h 
  rw [content, ← Finset.insert_erase h, Finset.gcd_insert, leading_coeff, content,
    erase_lead_support]
  refine' congr rfl (Finset.gcd_congr rfl fun i hi => _)
  rw [Finset.mem_erase] at hi 
  rw [erase_lead_coeff, if_neg hi.1]
#align polynomial.content_eq_gcd_leading_coeff_content_erase_lead Polynomial.content_eq_gcd_leadingCoeff_content_eraseLead
-/

#print Polynomial.dvd_content_iff_C_dvd /-
theorem dvd_content_iff_C_dvd {p : R[X]} {r : R} : r ∣ p.content ↔ C r ∣ p :=
  by
  rw [C_dvd_iff_dvd_coeff]
  constructor
  · intro h i
    apply h.trans (content_dvd_coeff _)
  · intro h
    rw [content, Finset.dvd_gcd_iff]
    intro i hi
    apply h i
#align polynomial.dvd_content_iff_C_dvd Polynomial.dvd_content_iff_C_dvd
-/

#print Polynomial.C_content_dvd /-
theorem C_content_dvd (p : R[X]) : C p.content ∣ p :=
  dvd_content_iff_C_dvd.1 dvd_rfl
#align polynomial.C_content_dvd Polynomial.C_content_dvd
-/

#print Polynomial.isPrimitive_iff_content_eq_one /-
theorem isPrimitive_iff_content_eq_one {p : R[X]} : p.IsPrimitive ↔ p.content = 1 :=
  by
  rw [← normalize_content, normalize_eq_one, is_primitive]
  simp_rw [← dvd_content_iff_C_dvd]
  exact ⟨fun h => h p.content (dvd_refl p.content), fun h r hdvd => isUnit_of_dvd_unit hdvd h⟩
#align polynomial.is_primitive_iff_content_eq_one Polynomial.isPrimitive_iff_content_eq_one
-/

#print Polynomial.IsPrimitive.content_eq_one /-
theorem IsPrimitive.content_eq_one {p : R[X]} (hp : p.IsPrimitive) : p.content = 1 :=
  isPrimitive_iff_content_eq_one.mp hp
#align polynomial.is_primitive.content_eq_one Polynomial.IsPrimitive.content_eq_one
-/

open scoped Classical

noncomputable section

section PrimPart

#print Polynomial.primPart /-
/-- The primitive part of a polynomial `p` is the primitive polynomial gained by dividing `p` by
  `p.content`. If `p = 0`, then `p.prim_part = 1`.  -/
def primPart (p : R[X]) : R[X] :=
  if p = 0 then 1 else Classical.choose (C_content_dvd p)
#align polynomial.prim_part Polynomial.primPart
-/

#print Polynomial.eq_C_content_mul_primPart /-
theorem eq_C_content_mul_primPart (p : R[X]) : p = C p.content * p.primPart :=
  by
  by_cases h : p = 0; · simp [h]
  rw [prim_part, if_neg h, ← Classical.choose_spec (C_content_dvd p)]
#align polynomial.eq_C_content_mul_prim_part Polynomial.eq_C_content_mul_primPart
-/

#print Polynomial.primPart_zero /-
@[simp]
theorem primPart_zero : primPart (0 : R[X]) = 1 :=
  if_pos rfl
#align polynomial.prim_part_zero Polynomial.primPart_zero
-/

#print Polynomial.isPrimitive_primPart /-
theorem isPrimitive_primPart (p : R[X]) : p.primPart.IsPrimitive :=
  by
  by_cases h : p = 0; · simp [h]
  rw [← content_eq_zero_iff] at h 
  rw [is_primitive_iff_content_eq_one]
  apply mul_left_cancel₀ h
  conv_rhs => rw [p.eq_C_content_mul_prim_part, mul_one, content_C_mul, normalize_content]
#align polynomial.is_primitive_prim_part Polynomial.isPrimitive_primPart
-/

#print Polynomial.content_primPart /-
theorem content_primPart (p : R[X]) : p.primPart.content = 1 :=
  p.isPrimitive_primPart.content_eq_one
#align polynomial.content_prim_part Polynomial.content_primPart
-/

#print Polynomial.primPart_ne_zero /-
theorem primPart_ne_zero (p : R[X]) : p.primPart ≠ 0 :=
  p.isPrimitive_primPart.NeZero
#align polynomial.prim_part_ne_zero Polynomial.primPart_ne_zero
-/

#print Polynomial.natDegree_primPart /-
theorem natDegree_primPart (p : R[X]) : p.primPart.natDegree = p.natDegree :=
  by
  by_cases h : C p.content = 0
  · rw [C_eq_zero, content_eq_zero_iff] at h ; simp [h]
  conv_rhs =>
    rw [p.eq_C_content_mul_prim_part, nat_degree_mul h p.prim_part_ne_zero, nat_degree_C, zero_add]
#align polynomial.nat_degree_prim_part Polynomial.natDegree_primPart
-/

#print Polynomial.IsPrimitive.primPart_eq /-
@[simp]
theorem IsPrimitive.primPart_eq {p : R[X]} (hp : p.IsPrimitive) : p.primPart = p := by
  rw [← one_mul p.prim_part, ← C_1, ← hp.content_eq_one, ← p.eq_C_content_mul_prim_part]
#align polynomial.is_primitive.prim_part_eq Polynomial.IsPrimitive.primPart_eq
-/

#print Polynomial.isUnit_primPart_C /-
theorem isUnit_primPart_C (r : R) : IsUnit (C r).primPart :=
  by
  by_cases h0 : r = 0
  · simp [h0]
  unfold IsUnit
  refine'
    ⟨⟨C ↑(norm_unit r)⁻¹, C ↑(norm_unit r), by rw [← RingHom.map_mul, Units.inv_mul, C_1], by
        rw [← RingHom.map_mul, Units.mul_inv, C_1]⟩,
      _⟩
  rw [← normalize_eq_zero, ← C_eq_zero] at h0 
  apply mul_left_cancel₀ h0
  conv_rhs => rw [← content_C, ← (C r).eq_C_content_mul_primPart]
  simp only [Units.val_mk, normalize_apply, RingHom.map_mul]
  rw [mul_assoc, ← RingHom.map_mul, Units.mul_inv, C_1, mul_one]
#align polynomial.is_unit_prim_part_C Polynomial.isUnit_primPart_C
-/

#print Polynomial.primPart_dvd /-
theorem primPart_dvd (p : R[X]) : p.primPart ∣ p :=
  Dvd.intro_left (C p.content) p.eq_C_content_mul_primPart.symm
#align polynomial.prim_part_dvd Polynomial.primPart_dvd
-/

#print Polynomial.aeval_primPart_eq_zero /-
theorem aeval_primPart_eq_zero {S : Type _} [Ring S] [IsDomain S] [Algebra R S]
    [NoZeroSMulDivisors R S] {p : R[X]} {s : S} (hpzero : p ≠ 0) (hp : aeval s p = 0) :
    aeval s p.primPart = 0 :=
  by
  rw [eq_C_content_mul_prim_part p, map_mul, aeval_C] at hp 
  have hcont : p.content ≠ 0 := fun h => hpzero (content_eq_zero_iff.1 h)
  replace hcont := Function.Injective.ne (NoZeroSMulDivisors.algebraMap_injective R S) hcont
  rw [map_zero] at hcont 
  exact eq_zero_of_ne_zero_of_mul_left_eq_zero hcont hp
#align polynomial.aeval_prim_part_eq_zero Polynomial.aeval_primPart_eq_zero
-/

#print Polynomial.eval₂_primPart_eq_zero /-
theorem eval₂_primPart_eq_zero {S : Type _} [CommRing S] [IsDomain S] {f : R →+* S}
    (hinj : Function.Injective f) {p : R[X]} {s : S} (hpzero : p ≠ 0) (hp : eval₂ f s p = 0) :
    eval₂ f s p.primPart = 0 :=
  by
  rw [eq_C_content_mul_prim_part p, eval₂_mul, eval₂_C] at hp 
  have hcont : p.content ≠ 0 := fun h => hpzero (content_eq_zero_iff.1 h)
  replace hcont := Function.Injective.ne hinj hcont
  rw [map_zero] at hcont 
  exact eq_zero_of_ne_zero_of_mul_left_eq_zero hcont hp
#align polynomial.eval₂_prim_part_eq_zero Polynomial.eval₂_primPart_eq_zero
-/

end PrimPart

#print Polynomial.gcd_content_eq_of_dvd_sub /-
theorem gcd_content_eq_of_dvd_sub {a : R} {p q : R[X]} (h : C a ∣ p - q) :
    GCDMonoid.gcd a p.content = GCDMonoid.gcd a q.content :=
  by
  rw [content_eq_gcd_range_of_lt p (max p.nat_degree q.nat_degree).succ
      (lt_of_le_of_lt (le_max_left _ _) (Nat.lt_succ_self _))]
  rw [content_eq_gcd_range_of_lt q (max p.nat_degree q.nat_degree).succ
      (lt_of_le_of_lt (le_max_right _ _) (Nat.lt_succ_self _))]
  apply Finset.gcd_eq_of_dvd_sub
  intro x hx
  cases' h with w hw
  use w.coeff x
  rw [← coeff_sub, hw, coeff_C_mul]
#align polynomial.gcd_content_eq_of_dvd_sub Polynomial.gcd_content_eq_of_dvd_sub
-/

#print Polynomial.content_mul_aux /-
theorem content_mul_aux {p q : R[X]} :
    GCDMonoid.gcd (p * q).eraseLead.content p.leadingCoeff =
      GCDMonoid.gcd (p.eraseLead * q).content p.leadingCoeff :=
  by
  rw [gcd_comm (content _) _, gcd_comm (content _) _]
  apply gcd_content_eq_of_dvd_sub
  rw [← self_sub_C_mul_X_pow, ← self_sub_C_mul_X_pow, sub_mul, sub_sub, add_comm, sub_add,
    sub_sub_cancel, leading_coeff_mul, RingHom.map_mul, mul_assoc, mul_assoc]
  apply dvd_sub (Dvd.intro _ rfl) (Dvd.intro _ rfl)
#align polynomial.content_mul_aux Polynomial.content_mul_aux
-/

#print Polynomial.content_mul /-
@[simp]
theorem content_mul {p q : R[X]} : (p * q).content = p.content * q.content := by
  classical
  suffices h : ∀ (n : ℕ) (p q : R[X]), (p * q).degree < n → (p * q).content = p.content * q.content
  · apply h
    apply lt_of_le_of_lt degree_le_nat_degree (WithBot.coe_lt_coe.2 (Nat.lt_succ_self _))
  intro n
  induction' n with n ih
  · intro p q hpq
    rw [WithBot.coe_zero, Nat.WithBot.lt_zero_iff, degree_eq_bot, mul_eq_zero] at hpq 
    rcases hpq with (rfl | rfl) <;> simp
  intro p q hpq
  by_cases p0 : p = 0
  · simp [p0]
  by_cases q0 : q = 0
  · simp [q0]
  rw [degree_eq_nat_degree (mul_ne_zero p0 q0), WithBot.coe_lt_coe, Nat.lt_succ_iff_lt_or_eq, ←
    WithBot.coe_lt_coe, ← degree_eq_nat_degree (mul_ne_zero p0 q0), nat_degree_mul p0 q0] at hpq 
  rcases hpq with (hlt | heq)
  · apply ih _ _ hlt
  rw [← p.nat_degree_prim_part, ← q.nat_degree_prim_part, ← WithBot.coe_eq_coe, WithBot.coe_add, ←
    degree_eq_nat_degree p.prim_part_ne_zero, ← degree_eq_nat_degree q.prim_part_ne_zero] at heq 
  rw [p.eq_C_content_mul_prim_part, q.eq_C_content_mul_prim_part]
  suffices h : (q.prim_part * p.prim_part).content = 1
  ·
    rw [mul_assoc, content_C_mul, content_C_mul, mul_comm p.prim_part, mul_assoc, content_C_mul,
      content_C_mul, h, mul_one, content_prim_part, content_prim_part, mul_one, mul_one]
  rw [← normalize_content, normalize_eq_one, isUnit_iff_dvd_one,
    content_eq_gcd_leading_coeff_content_erase_lead, leading_coeff_mul, gcd_comm]
  apply (gcd_mul_dvd_mul_gcd _ _ _).trans
  rw [content_mul_aux, ih, content_prim_part, mul_one, gcd_comm, ←
    content_eq_gcd_leading_coeff_content_erase_lead, content_prim_part, one_mul,
    mul_comm q.prim_part, content_mul_aux, ih, content_prim_part, mul_one, gcd_comm, ←
    content_eq_gcd_leading_coeff_content_erase_lead, content_prim_part]
  · rw [← HEq, degree_mul, WithBot.add_lt_add_iff_right]
    · apply degree_erase_lt p.prim_part_ne_zero
    · rw [Ne.def, degree_eq_bot]
      apply q.prim_part_ne_zero
  · rw [mul_comm, ← HEq, degree_mul, WithBot.add_lt_add_iff_left]
    · apply degree_erase_lt q.prim_part_ne_zero
    · rw [Ne.def, degree_eq_bot]
      apply p.prim_part_ne_zero
#align polynomial.content_mul Polynomial.content_mul
-/

#print Polynomial.IsPrimitive.mul /-
theorem IsPrimitive.mul {p q : R[X]} (hp : p.IsPrimitive) (hq : q.IsPrimitive) :
    (p * q).IsPrimitive := by
  rw [is_primitive_iff_content_eq_one, content_mul, hp.content_eq_one, hq.content_eq_one, mul_one]
#align polynomial.is_primitive.mul Polynomial.IsPrimitive.mul
-/

#print Polynomial.primPart_mul /-
@[simp]
theorem primPart_mul {p q : R[X]} (h0 : p * q ≠ 0) : (p * q).primPart = p.primPart * q.primPart :=
  by
  rw [Ne.def, ← content_eq_zero_iff, ← C_eq_zero] at h0 
  apply mul_left_cancel₀ h0
  conv_lhs =>
    rw [← (p * q).eq_C_content_mul_primPart, p.eq_C_content_mul_prim_part,
      q.eq_C_content_mul_prim_part]
  rw [content_mul, RingHom.map_mul]
  ring
#align polynomial.prim_part_mul Polynomial.primPart_mul
-/

#print Polynomial.IsPrimitive.dvd_primPart_iff_dvd /-
theorem IsPrimitive.dvd_primPart_iff_dvd {p q : R[X]} (hp : p.IsPrimitive) (hq : q ≠ 0) :
    p ∣ q.primPart ↔ p ∣ q :=
  by
  refine' ⟨fun h => h.trans (Dvd.intro_left _ q.eq_C_content_mul_prim_part.symm), fun h => _⟩
  rcases h with ⟨r, rfl⟩
  apply Dvd.intro _
  rw [prim_part_mul hq, hp.prim_part_eq]
#align polynomial.is_primitive.dvd_prim_part_iff_dvd Polynomial.IsPrimitive.dvd_primPart_iff_dvd
-/

#print Polynomial.exists_primitive_lcm_of_isPrimitive /-
theorem exists_primitive_lcm_of_isPrimitive {p q : R[X]} (hp : p.IsPrimitive) (hq : q.IsPrimitive) :
    ∃ r : R[X], r.IsPrimitive ∧ ∀ s : R[X], p ∣ s ∧ q ∣ s ↔ r ∣ s := by
  classical
  have h : ∃ (n : ℕ) (r : R[X]), r.natDegree = n ∧ r.IsPrimitive ∧ p ∣ r ∧ q ∣ r :=
    ⟨(p * q).natDegree, p * q, rfl, hp.mul hq, dvd_mul_right _ _, dvd_mul_left _ _⟩
  rcases Nat.find_spec h with ⟨r, rdeg, rprim, pr, qr⟩
  refine' ⟨r, rprim, fun s => ⟨_, fun rs => ⟨pr.trans rs, qr.trans rs⟩⟩⟩
  suffices hs : ∀ (n : ℕ) (s : R[X]), s.natDegree = n → p ∣ s ∧ q ∣ s → r ∣ s
  · apply hs s.nat_degree s rfl
  clear s
  by_contra' con
  rcases Nat.find_spec Con with ⟨s, sdeg, ⟨ps, qs⟩, rs⟩
  have s0 : s ≠ 0 := by contrapose! rs; simp [rs]
  have hs :=
    Nat.find_min' h
      ⟨_, s.nat_degree_prim_part, s.is_primitive_prim_part, (hp.dvd_prim_part_iff_dvd s0).2 ps,
        (hq.dvd_prim_part_iff_dvd s0).2 qs⟩
  rw [← rdeg] at hs 
  by_cases sC : s.nat_degree ≤ 0
  · rw [eq_C_of_nat_degree_le_zero (le_trans hs sC), is_primitive_iff_content_eq_one, content_C,
      normalize_eq_one] at rprim 
    rw [eq_C_of_nat_degree_le_zero (le_trans hs sC), ← dvd_content_iff_C_dvd] at rs 
    apply rs rprim.dvd
  have hcancel := nat_degree_cancel_leads_lt_of_nat_degree_le_nat_degree hs (lt_of_not_ge sC)
  rw [sdeg] at hcancel 
  apply Nat.find_min Con hcancel
  refine'
    ⟨_, rfl, ⟨dvd_cancel_leads_of_dvd_of_dvd pr ps, dvd_cancel_leads_of_dvd_of_dvd qr qs⟩,
      fun rcs => rs _⟩
  rw [← rprim.dvd_prim_part_iff_dvd s0]
  rw [cancel_leads, tsub_eq_zero_iff_le.mpr hs, pow_zero, mul_one] at rcs 
  have h := dvd_add rcs (Dvd.intro_left _ rfl)
  have hC0 := rprim.ne_zero
  rw [Ne.def, ← leading_coeff_eq_zero, ← C_eq_zero] at hC0 
  rw [sub_add_cancel, ← rprim.dvd_prim_part_iff_dvd (mul_ne_zero hC0 s0)] at h 
  rcases is_unit_prim_part_C r.leading_coeff with ⟨u, hu⟩
  apply h.trans (Associated.symm ⟨u, _⟩).Dvd
  rw [prim_part_mul (mul_ne_zero hC0 s0), hu, mul_comm]
#align polynomial.exists_primitive_lcm_of_is_primitive Polynomial.exists_primitive_lcm_of_isPrimitive
-/

#print Polynomial.dvd_iff_content_dvd_content_and_primPart_dvd_primPart /-
theorem dvd_iff_content_dvd_content_and_primPart_dvd_primPart {p q : R[X]} (hq : q ≠ 0) :
    p ∣ q ↔ p.content ∣ q.content ∧ p.primPart ∣ q.primPart :=
  by
  constructor <;> intro h
  · rcases h with ⟨r, rfl⟩
    rw [content_mul, p.is_primitive_prim_part.dvd_prim_part_iff_dvd hq]
    exact ⟨Dvd.intro _ rfl, p.prim_part_dvd.trans (Dvd.intro _ rfl)⟩
  · rw [p.eq_C_content_mul_prim_part, q.eq_C_content_mul_prim_part]
    exact mul_dvd_mul (RingHom.map_dvd C h.1) h.2
#align polynomial.dvd_iff_content_dvd_content_and_prim_part_dvd_prim_part Polynomial.dvd_iff_content_dvd_content_and_primPart_dvd_primPart
-/

#print Polynomial.normalizedGcdMonoid /-
instance (priority := 100) normalizedGcdMonoid : NormalizedGCDMonoid R[X] :=
  normalizedGCDMonoidOfExistsLCM fun p q =>
    by
    rcases exists_primitive_lcm_of_is_primitive p.is_primitive_prim_part
        q.is_primitive_prim_part with
      ⟨r, rprim, hr⟩
    refine' ⟨C (lcm p.content q.content) * r, fun s => _⟩
    by_cases hs : s = 0
    · simp [hs]
    by_cases hpq : C (lcm p.content q.content) = 0
    · rw [C_eq_zero, lcm_eq_zero_iff, content_eq_zero_iff, content_eq_zero_iff] at hpq 
      rcases hpq with (hpq | hpq) <;> simp [hpq, hs]
    iterate 3 rw [dvd_iff_content_dvd_content_and_prim_part_dvd_prim_part hs]
    rw [content_mul, rprim.content_eq_one, mul_one, content_C, normalize_lcm, lcm_dvd_iff,
      prim_part_mul (mul_ne_zero hpq rprim.ne_zero), rprim.prim_part_eq,
      IsUnit.mul_left_dvd _ _ _ (is_unit_prim_part_C (lcm p.content q.content)), ← hr s.prim_part]
    tauto
#align polynomial.normalized_gcd_monoid Polynomial.normalizedGcdMonoid
-/

#print Polynomial.degree_gcd_le_left /-
theorem degree_gcd_le_left {p : R[X]} (hp : p ≠ 0) (q) : (gcd p q).degree ≤ p.degree :=
  by
  have := nat_degree_le_iff_degree_le.mp (nat_degree_le_of_dvd (gcd_dvd_left p q) hp)
  rwa [degree_eq_nat_degree hp]
#align polynomial.degree_gcd_le_left Polynomial.degree_gcd_le_left
-/

#print Polynomial.degree_gcd_le_right /-
theorem degree_gcd_le_right (p) {q : R[X]} (hq : q ≠ 0) : (gcd p q).degree ≤ q.degree := by
  rw [gcd_comm]; exact degree_gcd_le_left hq p
#align polynomial.degree_gcd_le_right Polynomial.degree_gcd_le_right
-/

end NormalizedGCDMonoid

end Polynomial

