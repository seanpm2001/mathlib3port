/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Chris Hughes

! This file was ported from Lean 3 source module ring_theory.euclidean_domain
! leanprover-community/mathlib commit bf9bbbcf0c1c1ead18280b0d010e417b10abb1b6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GcdMonoid.Basic
import Mathbin.Algebra.EuclideanDomain.Basic
import Mathbin.RingTheory.Ideal.Basic
import Mathbin.RingTheory.PrincipalIdealDomain

/-!
# Lemmas about Euclidean domains

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Various about Euclidean domains are proved; all of them seem to be true
more generally for principal ideal domains, so these lemmas should
probably be reproved in more generality and this file perhaps removed?

## Tags

euclidean domain
-/


noncomputable section

open scoped Classical

open EuclideanDomain Set Ideal

section GCDMonoid

variable {R : Type _} [EuclideanDomain R] [GCDMonoid R] {p q : R}

#print gcd_ne_zero_of_left /-
theorem gcd_ne_zero_of_left (hp : p ≠ 0) : GCDMonoid.gcd p q ≠ 0 := fun h =>
  hp <| eq_zero_of_zero_dvd (h ▸ gcd_dvd_left p q)
#align gcd_ne_zero_of_left gcd_ne_zero_of_left
-/

#print gcd_ne_zero_of_right /-
theorem gcd_ne_zero_of_right (hp : q ≠ 0) : GCDMonoid.gcd p q ≠ 0 := fun h =>
  hp <| eq_zero_of_zero_dvd (h ▸ gcd_dvd_right p q)
#align gcd_ne_zero_of_right gcd_ne_zero_of_right
-/

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:132:4: warning: unsupported: rw with cfg: { occs := occurrences.pos[occurrences.pos] «expr[ ,]»([1]) } -/
#print left_div_gcd_ne_zero /-
theorem left_div_gcd_ne_zero {p q : R} (hp : p ≠ 0) : p / GCDMonoid.gcd p q ≠ 0 :=
  by
  obtain ⟨r, hr⟩ := GCDMonoid.gcd_dvd_left p q
  obtain ⟨pq0, r0⟩ : GCDMonoid.gcd p q ≠ 0 ∧ r ≠ 0 := mul_ne_zero_iff.mp (hr ▸ hp)
  rw [hr, mul_comm, mul_div_cancel _ pq0]
  exact r0
#align left_div_gcd_ne_zero left_div_gcd_ne_zero
-/

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:132:4: warning: unsupported: rw with cfg: { occs := occurrences.pos[occurrences.pos] «expr[ ,]»([1]) } -/
#print right_div_gcd_ne_zero /-
theorem right_div_gcd_ne_zero {p q : R} (hq : q ≠ 0) : q / GCDMonoid.gcd p q ≠ 0 :=
  by
  obtain ⟨r, hr⟩ := GCDMonoid.gcd_dvd_right p q
  obtain ⟨pq0, r0⟩ : GCDMonoid.gcd p q ≠ 0 ∧ r ≠ 0 := mul_ne_zero_iff.mp (hr ▸ hq)
  rw [hr, mul_comm, mul_div_cancel _ pq0]
  exact r0
#align right_div_gcd_ne_zero right_div_gcd_ne_zero
-/

#print isCoprime_div_gcd_div_gcd /-
theorem isCoprime_div_gcd_div_gcd (hq : q ≠ 0) :
    IsCoprime (p / GCDMonoid.gcd p q) (q / GCDMonoid.gcd p q) :=
  (gcd_isUnit_iff _ _).1 <|
    isUnit_gcd_of_eq_mul_gcd
        (EuclideanDomain.mul_div_cancel' (gcd_ne_zero_of_right hq) <| gcd_dvd_left _ _).symm
        (EuclideanDomain.mul_div_cancel' (gcd_ne_zero_of_right hq) <| gcd_dvd_right _ _).symm <|
      gcd_ne_zero_of_right hq
#align is_coprime_div_gcd_div_gcd isCoprime_div_gcd_div_gcd
-/

end GCDMonoid

namespace EuclideanDomain

#print EuclideanDomain.gcdMonoid /-
/-- Create a `gcd_monoid` whose `gcd_monoid.gcd` matches `euclidean_domain.gcd`. -/
def gcdMonoid (R) [EuclideanDomain R] : GCDMonoid R
    where
  gcd := gcd
  lcm := lcm
  gcd_dvd_left := gcd_dvd_left
  gcd_dvd_right := gcd_dvd_right
  dvd_gcd a b c := dvd_gcd
  gcd_mul_lcm a b := by rw [EuclideanDomain.gcd_mul_lcm]
  lcm_zero_left := lcm_zero_left
  lcm_zero_right := lcm_zero_right
#align euclidean_domain.gcd_monoid EuclideanDomain.gcdMonoid
-/

variable {α : Type _} [EuclideanDomain α] [DecidableEq α]

#print EuclideanDomain.span_gcd /-
theorem span_gcd {α} [EuclideanDomain α] (x y : α) :
    span ({gcd x y} : Set α) = span ({x, y} : Set α) :=
  letI := EuclideanDomain.gcdMonoid α
  span_gcd x y
#align euclidean_domain.span_gcd EuclideanDomain.span_gcd
-/

#print EuclideanDomain.gcd_isUnit_iff /-
theorem gcd_isUnit_iff {α} [EuclideanDomain α] {x y : α} : IsUnit (gcd x y) ↔ IsCoprime x y :=
  letI := EuclideanDomain.gcdMonoid α
  gcd_isUnit_iff x y
#align euclidean_domain.gcd_is_unit_iff EuclideanDomain.gcd_isUnit_iff
-/

#print EuclideanDomain.isCoprime_of_dvd /-
-- this should be proved for UFDs surely?
theorem isCoprime_of_dvd {α} [EuclideanDomain α] {x y : α} (nonzero : ¬(x = 0 ∧ y = 0))
    (H : ∀ z ∈ nonunits α, z ≠ 0 → z ∣ x → ¬z ∣ y) : IsCoprime x y :=
  letI := EuclideanDomain.gcdMonoid α
  isCoprime_of_dvd x y nonzero H
#align euclidean_domain.is_coprime_of_dvd EuclideanDomain.isCoprime_of_dvd
-/

#print EuclideanDomain.dvd_or_coprime /-
-- this should be proved for UFDs surely?
theorem dvd_or_coprime {α} [EuclideanDomain α] (x y : α) (h : Irreducible x) :
    x ∣ y ∨ IsCoprime x y :=
  letI := EuclideanDomain.gcdMonoid α
  dvd_or_coprime x y h
#align euclidean_domain.dvd_or_coprime EuclideanDomain.dvd_or_coprime
-/

end EuclideanDomain

