/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module algebra.squarefree
! leanprover-community/mathlib commit 00d163e35035c3577c1c79fa53b68de17781ffc1
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.UniqueFactorizationDomain

/-!
# Squarefree elements of monoids

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
An element of a monoid is squarefree when it is not divisible by any squares
except the squares of units.

Results about squarefree natural numbers are proved in `data/nat/squarefree`.

## Main Definitions
 - `squarefree r` indicates that `r` is only divisible by `x * x` if `x` is a unit.

## Main Results
 - `multiplicity.squarefree_iff_multiplicity_le_one`: `x` is `squarefree` iff for every `y`, either
  `multiplicity y x ≤ 1` or `is_unit y`.
 - `unique_factorization_monoid.squarefree_iff_nodup_factors`: A nonzero element `x` of a unique
 factorization monoid is squarefree iff `factors x` has no duplicate factors.

## Tags
squarefree, multiplicity

-/


variable {R : Type _}

#print Squarefree /-
/-- An element of a monoid is squarefree if the only squares that
  divide it are the squares of units. -/
def Squarefree [Monoid R] (r : R) : Prop :=
  ∀ x : R, x * x ∣ r → IsUnit x
#align squarefree Squarefree
-/

#print IsUnit.squarefree /-
@[simp]
theorem IsUnit.squarefree [CommMonoid R] {x : R} (h : IsUnit x) : Squarefree x := fun y hdvd =>
  isUnit_of_mul_isUnit_left (isUnit_of_dvd_unit hdvd h)
#align is_unit.squarefree IsUnit.squarefree
-/

#print squarefree_one /-
@[simp]
theorem squarefree_one [CommMonoid R] : Squarefree (1 : R) :=
  isUnit_one.Squarefree
#align squarefree_one squarefree_one
-/

#print not_squarefree_zero /-
@[simp]
theorem not_squarefree_zero [MonoidWithZero R] [Nontrivial R] : ¬Squarefree (0 : R) :=
  by
  erw [not_forall]
  exact ⟨0, by simp⟩
#align not_squarefree_zero not_squarefree_zero
-/

#print Squarefree.ne_zero /-
theorem Squarefree.ne_zero [MonoidWithZero R] [Nontrivial R] {m : R} (hm : Squarefree (m : R)) :
    m ≠ 0 := by
  rintro rfl
  exact not_squarefree_zero hm
#align squarefree.ne_zero Squarefree.ne_zero
-/

#print Irreducible.squarefree /-
@[simp]
theorem Irreducible.squarefree [CommMonoid R] {x : R} (h : Irreducible x) : Squarefree x :=
  by
  rintro y ⟨z, hz⟩
  rw [mul_assoc] at hz 
  rcases h.is_unit_or_is_unit hz with (hu | hu)
  · exact hu
  · apply isUnit_of_mul_isUnit_left hu
#align irreducible.squarefree Irreducible.squarefree
-/

#print Prime.squarefree /-
@[simp]
theorem Prime.squarefree [CancelCommMonoidWithZero R] {x : R} (h : Prime x) : Squarefree x :=
  h.Irreducible.Squarefree
#align prime.squarefree Prime.squarefree
-/

#print Squarefree.of_mul_left /-
theorem Squarefree.of_mul_left [CommMonoid R] {m n : R} (hmn : Squarefree (m * n)) : Squarefree m :=
  fun p hp => hmn p (dvd_mul_of_dvd_left hp n)
#align squarefree.of_mul_left Squarefree.of_mul_left
-/

#print Squarefree.of_mul_right /-
theorem Squarefree.of_mul_right [CommMonoid R] {m n : R} (hmn : Squarefree (m * n)) :
    Squarefree n := fun p hp => hmn p (dvd_mul_of_dvd_right hp m)
#align squarefree.of_mul_right Squarefree.of_mul_right
-/

#print Squarefree.squarefree_of_dvd /-
theorem Squarefree.squarefree_of_dvd [CommMonoid R] {x y : R} (hdvd : x ∣ y) (hsq : Squarefree y) :
    Squarefree x := fun a h => hsq _ (h.trans hdvd)
#align squarefree.squarefree_of_dvd Squarefree.squarefree_of_dvd
-/

section SquarefreeGcdOfSquarefree

variable {α : Type _} [CancelCommMonoidWithZero α] [GCDMonoid α]

#print Squarefree.gcd_right /-
theorem Squarefree.gcd_right (a : α) {b : α} (hb : Squarefree b) : Squarefree (gcd a b) :=
  hb.squarefree_of_dvd (gcd_dvd_right _ _)
#align squarefree.gcd_right Squarefree.gcd_right
-/

#print Squarefree.gcd_left /-
theorem Squarefree.gcd_left {a : α} (b : α) (ha : Squarefree a) : Squarefree (gcd a b) :=
  ha.squarefree_of_dvd (gcd_dvd_left _ _)
#align squarefree.gcd_left Squarefree.gcd_left
-/

end SquarefreeGcdOfSquarefree

namespace multiplicity

section CommMonoid

variable [CommMonoid R] [DecidableRel (Dvd.Dvd : R → R → Prop)]

#print multiplicity.squarefree_iff_multiplicity_le_one /-
theorem squarefree_iff_multiplicity_le_one (r : R) :
    Squarefree r ↔ ∀ x : R, multiplicity x r ≤ 1 ∨ IsUnit x :=
  by
  refine' forall_congr' fun a => _
  rw [← sq, pow_dvd_iff_le_multiplicity, or_iff_not_imp_left, not_le, imp_congr _ Iff.rfl]
  simpa using PartENat.add_one_le_iff_lt (PartENat.natCast_ne_top 1)
#align multiplicity.squarefree_iff_multiplicity_le_one multiplicity.squarefree_iff_multiplicity_le_one
-/

end CommMonoid

section CancelCommMonoidWithZero

variable [CancelCommMonoidWithZero R] [WfDvdMonoid R]

#print multiplicity.finite_prime_left /-
theorem finite_prime_left {a b : R} (ha : Prime a) (hb : b ≠ 0) : multiplicity.Finite a b := by
  classical
  revert hb
  refine'
    WfDvdMonoid.induction_on_irreducible b (by contradiction) (fun u hu hu' => _)
      fun b p hb hp ih hpb => _
  · rw [multiplicity.finite_iff_dom, multiplicity.isUnit_right ha.not_unit hu]
    exact PartENat.dom_natCast 0
  · refine'
      multiplicity.finite_mul ha
        (multiplicity.finite_iff_dom.mpr
          (PartENat.dom_of_le_natCast (show multiplicity a p ≤ ↑1 from _)))
        (ih hb)
    norm_cast
    exact
      ((multiplicity.squarefree_iff_multiplicity_le_one p).mp hp.squarefree a).resolve_right
        ha.not_unit
#align multiplicity.finite_prime_left multiplicity.finite_prime_left
-/

end CancelCommMonoidWithZero

end multiplicity

section Irreducible

variable [CommMonoidWithZero R] [WfDvdMonoid R]

#print irreducible_sq_not_dvd_iff_eq_zero_and_no_irreducibles_or_squarefree /-
theorem irreducible_sq_not_dvd_iff_eq_zero_and_no_irreducibles_or_squarefree (r : R) :
    (∀ x : R, Irreducible x → ¬x * x ∣ r) ↔ (r = 0 ∧ ∀ x : R, ¬Irreducible x) ∨ Squarefree r :=
  by
  symm
  constructor
  · rintro (⟨rfl, h⟩ | h)
    · simpa using h
    intro x hx t
    exact hx.not_unit (h x t)
  intro h
  rcases eq_or_ne r 0 with (rfl | hr)
  · exact Or.inl (by simpa using h)
  right
  intro x hx
  by_contra i
  have : x ≠ 0 := by
    rintro rfl
    apply hr
    simpa only [zero_dvd_iff, MulZeroClass.mul_zero] using hx
  obtain ⟨j, hj₁, hj₂⟩ := WfDvdMonoid.exists_irreducible_factor i this
  exact h _ hj₁ ((mul_dvd_mul hj₂ hj₂).trans hx)
#align irreducible_sq_not_dvd_iff_eq_zero_and_no_irreducibles_or_squarefree irreducible_sq_not_dvd_iff_eq_zero_and_no_irreducibles_or_squarefree
-/

#print squarefree_iff_irreducible_sq_not_dvd_of_ne_zero /-
theorem squarefree_iff_irreducible_sq_not_dvd_of_ne_zero {r : R} (hr : r ≠ 0) :
    Squarefree r ↔ ∀ x : R, Irreducible x → ¬x * x ∣ r := by
  simpa [hr] using (irreducible_sq_not_dvd_iff_eq_zero_and_no_irreducibles_or_squarefree r).symm
#align squarefree_iff_irreducible_sq_not_dvd_of_ne_zero squarefree_iff_irreducible_sq_not_dvd_of_ne_zero
-/

#print squarefree_iff_irreducible_sq_not_dvd_of_exists_irreducible /-
theorem squarefree_iff_irreducible_sq_not_dvd_of_exists_irreducible {r : R}
    (hr : ∃ x : R, Irreducible x) : Squarefree r ↔ ∀ x : R, Irreducible x → ¬x * x ∣ r :=
  by
  rw [irreducible_sq_not_dvd_iff_eq_zero_and_no_irreducibles_or_squarefree, ← not_exists]
  simp only [hr, not_true, false_or_iff, and_false_iff]
#align squarefree_iff_irreducible_sq_not_dvd_of_exists_irreducible squarefree_iff_irreducible_sq_not_dvd_of_exists_irreducible
-/

end Irreducible

section IsRadical

variable [CancelCommMonoidWithZero R]

#print IsRadical.squarefree /-
theorem IsRadical.squarefree {x : R} (h0 : x ≠ 0) (h : IsRadical x) : Squarefree x :=
  by
  rintro z ⟨w, rfl⟩
  specialize h 2 (z * w) ⟨w, by simp_rw [pow_two, mul_left_comm, ← mul_assoc]⟩
  rwa [← one_mul (z * w), mul_assoc, mul_dvd_mul_iff_right, ← isUnit_iff_dvd_one] at h 
  rw [mul_assoc, mul_ne_zero_iff] at h0 ; exact h0.2
#align is_radical.squarefree IsRadical.squarefree
-/

variable [GCDMonoid R]

#print Squarefree.isRadical /-
theorem Squarefree.isRadical {x : R} (hx : Squarefree x) : IsRadical x :=
  (isRadical_iff_pow_one_lt 2 one_lt_two).2 fun y hy =>
    And.right <|
      (dvd_gcd_iff x x y).1
        (by
          by_cases gcd x y = 0; · rw [h]; apply dvd_zero
          replace hy := ((dvd_gcd_iff x x _).2 ⟨dvd_rfl, hy⟩).trans gcd_pow_right_dvd_pow_gcd
          obtain ⟨z, hz⟩ := gcd_dvd_left x y
          nth_rw 1 [hz] at hy ⊢
          rw [pow_two, mul_dvd_mul_iff_left h] at hy 
          obtain ⟨w, hw⟩ := hy
          exact (hx z ⟨w, by rwa [mul_right_comm, ← hw]⟩).mul_right_dvd.2 dvd_rfl)
#align squarefree.is_radical Squarefree.isRadical
-/

#print isRadical_iff_squarefree_or_zero /-
theorem isRadical_iff_squarefree_or_zero {x : R} : IsRadical x ↔ Squarefree x ∨ x = 0 :=
  ⟨fun hx => (em <| x = 0).elim Or.inr fun h => Or.inl <| hx.Squarefree h,
    Or.ndrec Squarefree.isRadical <| by rintro rfl; rw [zero_isRadical_iff]; infer_instance⟩
#align is_radical_iff_squarefree_or_zero isRadical_iff_squarefree_or_zero
-/

#print isRadical_iff_squarefree_of_ne_zero /-
theorem isRadical_iff_squarefree_of_ne_zero {x : R} (h : x ≠ 0) : IsRadical x ↔ Squarefree x :=
  ⟨IsRadical.squarefree h, Squarefree.isRadical⟩
#align is_radical_iff_squarefree_of_ne_zero isRadical_iff_squarefree_of_ne_zero
-/

end IsRadical

namespace UniqueFactorizationMonoid

variable [CancelCommMonoidWithZero R] [UniqueFactorizationMonoid R]

#print UniqueFactorizationMonoid.squarefree_iff_nodup_normalizedFactors /-
theorem squarefree_iff_nodup_normalizedFactors [NormalizationMonoid R] [DecidableEq R] {x : R}
    (x0 : x ≠ 0) : Squarefree x ↔ Multiset.Nodup (normalizedFactors x) :=
  by
  have drel : DecidableRel (Dvd.Dvd : R → R → Prop) := by classical infer_instance
  haveI := drel
  rw [multiplicity.squarefree_iff_multiplicity_le_one, Multiset.nodup_iff_count_le_one]
  haveI := nontrivial_of_ne x 0 x0
  constructor <;> intro h a
  · by_cases hmem : a ∈ normalized_factors x
    · have ha := irreducible_of_normalized_factor _ hmem
      rcases h a with (h | h)
      · rw [← normalize_normalized_factor _ hmem]
        rw [multiplicity_eq_count_normalized_factors ha x0] at h 
        assumption_mod_cast
      · have := ha.1; contradiction
    · simp [Multiset.count_eq_zero_of_not_mem hmem]
  · rw [or_iff_not_imp_right]; intro hu
    by_cases h0 : a = 0
    · simp [h0, x0]
    rcases WfDvdMonoid.exists_irreducible_factor hu h0 with ⟨b, hib, hdvd⟩
    apply le_trans (multiplicity.multiplicity_le_multiplicity_of_dvd_left hdvd)
    rw [multiplicity_eq_count_normalized_factors hib x0]
    specialize h (normalize b)
    assumption_mod_cast
#align unique_factorization_monoid.squarefree_iff_nodup_normalized_factors UniqueFactorizationMonoid.squarefree_iff_nodup_normalizedFactors
-/

#print UniqueFactorizationMonoid.dvd_pow_iff_dvd_of_squarefree /-
theorem dvd_pow_iff_dvd_of_squarefree {x y : R} {n : ℕ} (hsq : Squarefree x) (h0 : n ≠ 0) :
    x ∣ y ^ n ↔ x ∣ y := by
  classical
  haveI := UniqueFactorizationMonoid.toGCDMonoid R
  exact ⟨hsq.is_radical n y, fun h => h.pow h0⟩
#align unique_factorization_monoid.dvd_pow_iff_dvd_of_squarefree UniqueFactorizationMonoid.dvd_pow_iff_dvd_of_squarefree
-/

end UniqueFactorizationMonoid

namespace Int

#print Int.squarefree_natAbs /-
@[simp]
theorem squarefree_natAbs {n : ℤ} : Squarefree n.natAbs ↔ Squarefree n := by
  simp_rw [Squarefree, nat_abs_surjective.forall, ← nat_abs_mul, nat_abs_dvd_iff_dvd,
    is_unit_iff_nat_abs_eq, Nat.isUnit_iff]
#align int.squarefree_nat_abs Int.squarefree_natAbs
-/

#print Int.squarefree_coe_nat /-
@[simp]
theorem squarefree_coe_nat {n : ℕ} : Squarefree (n : ℤ) ↔ Squarefree n := by
  rw [← squarefree_nat_abs, nat_abs_of_nat]
#align int.squarefree_coe_nat Int.squarefree_coe_nat
-/

end Int

