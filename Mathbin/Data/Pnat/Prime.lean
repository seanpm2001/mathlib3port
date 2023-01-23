/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Neil Strickland

! This file was ported from Lean 3 source module data.pnat.prime
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Prime
import Mathbin.Data.Pnat.Basic

/-!
# Primality and GCD on pnat

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file extends the theory of `ℕ+` with `gcd`, `lcm` and `prime` functions, analogous to those on
`nat`.
-/


namespace Nat.Primes

#print Nat.Primes.coePnat /-
instance coePnat : Coe Nat.Primes ℕ+ :=
  ⟨fun p => ⟨(p : ℕ), p.property.Pos⟩⟩
#align nat.primes.coe_pnat Nat.Primes.coePnat
-/

#print Nat.Primes.coe_pnat_nat /-
@[norm_cast]
theorem coe_pnat_nat (p : Nat.Primes) : ((p : ℕ+) : ℕ) = p :=
  rfl
#align nat.primes.coe_pnat_nat Nat.Primes.coe_pnat_nat
-/

#print Nat.Primes.coe_pnat_injective /-
theorem coe_pnat_injective : Function.Injective (coe : Nat.Primes → ℕ+) := fun p q h =>
  Subtype.ext (congr_arg Subtype.val h : _)
#align nat.primes.coe_pnat_injective Nat.Primes.coe_pnat_injective
-/

#print Nat.Primes.coe_pnat_inj /-
@[norm_cast]
theorem coe_pnat_inj (p q : Nat.Primes) : (p : ℕ+) = (q : ℕ+) ↔ p = q :=
  coe_pnat_injective.eq_iff
#align nat.primes.coe_pnat_inj Nat.Primes.coe_pnat_inj
-/

end Nat.Primes

namespace PNat

open _Root_.Nat

#print PNat.gcd /-
/-- The greatest common divisor (gcd) of two positive natural numbers,
  viewed as positive natural number. -/
def gcd (n m : ℕ+) : ℕ+ :=
  ⟨Nat.gcd (n : ℕ) (m : ℕ), Nat.gcd_pos_of_pos_left (m : ℕ) n.Pos⟩
#align pnat.gcd PNat.gcd
-/

#print PNat.lcm /-
/-- The least common multiple (lcm) of two positive natural numbers,
  viewed as positive natural number. -/
def lcm (n m : ℕ+) : ℕ+ :=
  ⟨Nat.lcm (n : ℕ) (m : ℕ), by
    let h := mul_pos n.pos m.pos
    rw [← gcd_mul_lcm (n : ℕ) (m : ℕ), mul_comm] at h
    exact pos_of_dvd_of_pos (Dvd.intro (Nat.gcd (n : ℕ) (m : ℕ)) rfl) h⟩
#align pnat.lcm PNat.lcm
-/

#print PNat.gcd_coe /-
@[simp, norm_cast]
theorem gcd_coe (n m : ℕ+) : (gcd n m : ℕ) = Nat.gcd n m :=
  rfl
#align pnat.gcd_coe PNat.gcd_coe
-/

#print PNat.lcm_coe /-
@[simp, norm_cast]
theorem lcm_coe (n m : ℕ+) : (lcm n m : ℕ) = Nat.lcm n m :=
  rfl
#align pnat.lcm_coe PNat.lcm_coe
-/

/- warning: pnat.gcd_dvd_left -> PNat.gcd_dvd_left is a dubious translation:
lean 3 declaration is
  forall (n : PNat) (m : PNat), Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) (PNat.gcd n m) n
but is expected to have type
  forall (n : PNat) (m : PNat), Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) (PNat.gcd n m) n
Case conversion may be inaccurate. Consider using '#align pnat.gcd_dvd_left PNat.gcd_dvd_leftₓ'. -/
theorem gcd_dvd_left (n m : ℕ+) : gcd n m ∣ n :=
  dvd_iff.2 (Nat.gcd_dvd_left (n : ℕ) (m : ℕ))
#align pnat.gcd_dvd_left PNat.gcd_dvd_left

/- warning: pnat.gcd_dvd_right -> PNat.gcd_dvd_right is a dubious translation:
lean 3 declaration is
  forall (n : PNat) (m : PNat), Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) (PNat.gcd n m) m
but is expected to have type
  forall (n : PNat) (m : PNat), Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) (PNat.gcd n m) m
Case conversion may be inaccurate. Consider using '#align pnat.gcd_dvd_right PNat.gcd_dvd_rightₓ'. -/
theorem gcd_dvd_right (n m : ℕ+) : gcd n m ∣ m :=
  dvd_iff.2 (Nat.gcd_dvd_right (n : ℕ) (m : ℕ))
#align pnat.gcd_dvd_right PNat.gcd_dvd_right

/- warning: pnat.dvd_gcd -> PNat.dvd_gcd is a dubious translation:
lean 3 declaration is
  forall {m : PNat} {n : PNat} {k : PNat}, (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) k m) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) k n) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) k (PNat.gcd m n))
but is expected to have type
  forall {m : PNat} {n : PNat} {k : PNat}, (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) k m) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) k n) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) k (PNat.gcd m n))
Case conversion may be inaccurate. Consider using '#align pnat.dvd_gcd PNat.dvd_gcdₓ'. -/
theorem dvd_gcd {m n k : ℕ+} (hm : k ∣ m) (hn : k ∣ n) : k ∣ gcd m n :=
  dvd_iff.2 (@Nat.dvd_gcd (m : ℕ) (n : ℕ) (k : ℕ) (dvd_iff.1 hm) (dvd_iff.1 hn))
#align pnat.dvd_gcd PNat.dvd_gcd

/- warning: pnat.dvd_lcm_left -> PNat.dvd_lcm_left is a dubious translation:
lean 3 declaration is
  forall (n : PNat) (m : PNat), Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) n (PNat.lcm n m)
but is expected to have type
  forall (n : PNat) (m : PNat), Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) n (PNat.lcm n m)
Case conversion may be inaccurate. Consider using '#align pnat.dvd_lcm_left PNat.dvd_lcm_leftₓ'. -/
theorem dvd_lcm_left (n m : ℕ+) : n ∣ lcm n m :=
  dvd_iff.2 (Nat.dvd_lcm_left (n : ℕ) (m : ℕ))
#align pnat.dvd_lcm_left PNat.dvd_lcm_left

/- warning: pnat.dvd_lcm_right -> PNat.dvd_lcm_right is a dubious translation:
lean 3 declaration is
  forall (n : PNat) (m : PNat), Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) m (PNat.lcm n m)
but is expected to have type
  forall (n : PNat) (m : PNat), Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) m (PNat.lcm n m)
Case conversion may be inaccurate. Consider using '#align pnat.dvd_lcm_right PNat.dvd_lcm_rightₓ'. -/
theorem dvd_lcm_right (n m : ℕ+) : m ∣ lcm n m :=
  dvd_iff.2 (Nat.dvd_lcm_right (n : ℕ) (m : ℕ))
#align pnat.dvd_lcm_right PNat.dvd_lcm_right

/- warning: pnat.lcm_dvd -> PNat.lcm_dvd is a dubious translation:
lean 3 declaration is
  forall {m : PNat} {n : PNat} {k : PNat}, (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) m k) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) n k) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) (PNat.lcm m n) k)
but is expected to have type
  forall {m : PNat} {n : PNat} {k : PNat}, (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) m k) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) n k) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) (PNat.lcm m n) k)
Case conversion may be inaccurate. Consider using '#align pnat.lcm_dvd PNat.lcm_dvdₓ'. -/
theorem lcm_dvd {m n k : ℕ+} (hm : m ∣ k) (hn : n ∣ k) : lcm m n ∣ k :=
  dvd_iff.2 (@Nat.lcm_dvd (m : ℕ) (n : ℕ) (k : ℕ) (dvd_iff.1 hm) (dvd_iff.1 hn))
#align pnat.lcm_dvd PNat.lcm_dvd

/- warning: pnat.gcd_mul_lcm -> PNat.gcd_mul_lcm is a dubious translation:
lean 3 declaration is
  forall (n : PNat) (m : PNat), Eq.{1} PNat (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) (PNat.gcd n m) (PNat.lcm n m)) (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) n m)
but is expected to have type
  forall (n : PNat) (m : PNat), Eq.{1} PNat (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) (PNat.gcd n m) (PNat.lcm n m)) (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) n m)
Case conversion may be inaccurate. Consider using '#align pnat.gcd_mul_lcm PNat.gcd_mul_lcmₓ'. -/
theorem gcd_mul_lcm (n m : ℕ+) : gcd n m * lcm n m = n * m :=
  Subtype.eq (Nat.gcd_mul_lcm (n : ℕ) (m : ℕ))
#align pnat.gcd_mul_lcm PNat.gcd_mul_lcm

/- warning: pnat.eq_one_of_lt_two -> PNat.eq_one_of_lt_two is a dubious translation:
lean 3 declaration is
  forall {n : PNat}, (LT.lt.{0} PNat (Preorder.toLT.{0} PNat (PartialOrder.toPreorder.{0} PNat (OrderedCancelCommMonoid.toPartialOrder.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid)))) n (OfNat.ofNat.{0} PNat 2 (OfNat.mk.{0} PNat 2 (bit0.{0} PNat PNat.hasAdd (One.one.{0} PNat PNat.hasOne))))) -> (Eq.{1} PNat n (OfNat.ofNat.{0} PNat 1 (OfNat.mk.{0} PNat 1 (One.one.{0} PNat PNat.hasOne))))
but is expected to have type
  forall {n : PNat}, (LT.lt.{0} PNat (Preorder.toLT.{0} PNat (PartialOrder.toPreorder.{0} PNat (OrderedCancelCommMonoid.toPartialOrder.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid)))) n (OfNat.ofNat.{0} PNat 2 (instOfNatPNatHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) -> (Eq.{1} PNat n (OfNat.ofNat.{0} PNat 1 (instOfNatPNatHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))))
Case conversion may be inaccurate. Consider using '#align pnat.eq_one_of_lt_two PNat.eq_one_of_lt_twoₓ'. -/
theorem eq_one_of_lt_two {n : ℕ+} : n < 2 → n = 1 :=
  by
  intro h; apply le_antisymm; swap; apply PNat.one_le
  change n < 1 + 1 at h; rw [PNat.lt_add_one_iff] at h; apply h
#align pnat.eq_one_of_lt_two PNat.eq_one_of_lt_two

section Prime

/-! ### Prime numbers -/


#print PNat.Prime /-
/-- Primality predicate for `ℕ+`, defined in terms of `nat.prime`. -/
def Prime (p : ℕ+) : Prop :=
  (p : ℕ).Prime
#align pnat.prime PNat.Prime
-/

/- warning: pnat.prime.one_lt -> PNat.Prime.one_lt is a dubious translation:
lean 3 declaration is
  forall {p : PNat}, (PNat.Prime p) -> (LT.lt.{0} PNat (Preorder.toLT.{0} PNat (PartialOrder.toPreorder.{0} PNat (OrderedCancelCommMonoid.toPartialOrder.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid)))) (OfNat.ofNat.{0} PNat 1 (OfNat.mk.{0} PNat 1 (One.one.{0} PNat PNat.hasOne))) p)
but is expected to have type
  forall {p : PNat}, (PNat.Prime p) -> (LT.lt.{0} PNat (Preorder.toLT.{0} PNat (PartialOrder.toPreorder.{0} PNat (OrderedCancelCommMonoid.toPartialOrder.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid)))) (OfNat.ofNat.{0} PNat 1 (instOfNatPNatHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))) p)
Case conversion may be inaccurate. Consider using '#align pnat.prime.one_lt PNat.Prime.one_ltₓ'. -/
theorem Prime.one_lt {p : ℕ+} : p.Prime → 1 < p :=
  Nat.Prime.one_lt
#align pnat.prime.one_lt PNat.Prime.one_lt

/- warning: pnat.prime_two -> PNat.prime_two is a dubious translation:
lean 3 declaration is
  PNat.Prime (OfNat.ofNat.{0} PNat 2 (OfNat.mk.{0} PNat 2 (bit0.{0} PNat PNat.hasAdd (One.one.{0} PNat PNat.hasOne))))
but is expected to have type
  PNat.Prime (OfNat.ofNat.{0} PNat 2 (instOfNatPNatHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))
Case conversion may be inaccurate. Consider using '#align pnat.prime_two PNat.prime_twoₓ'. -/
theorem prime_two : (2 : ℕ+).Prime :=
  Nat.prime_two
#align pnat.prime_two PNat.prime_two

/- warning: pnat.dvd_prime -> PNat.dvd_prime is a dubious translation:
lean 3 declaration is
  forall {p : PNat} {m : PNat}, (PNat.Prime p) -> (Iff (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) m p) (Or (Eq.{1} PNat m (OfNat.ofNat.{0} PNat 1 (OfNat.mk.{0} PNat 1 (One.one.{0} PNat PNat.hasOne)))) (Eq.{1} PNat m p)))
but is expected to have type
  forall {p : PNat} {m : PNat}, (PNat.Prime p) -> (Iff (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) m p) (Or (Eq.{1} PNat m (OfNat.ofNat.{0} PNat 1 (instOfNatPNatHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0))))) (Eq.{1} PNat m p)))
Case conversion may be inaccurate. Consider using '#align pnat.dvd_prime PNat.dvd_primeₓ'. -/
theorem dvd_prime {p m : ℕ+} (pp : p.Prime) : m ∣ p ↔ m = 1 ∨ m = p :=
  by
  rw [PNat.dvd_iff]
  rw [Nat.dvd_prime pp]
  simp
#align pnat.dvd_prime PNat.dvd_prime

#print PNat.Prime.ne_one /-
theorem Prime.ne_one {p : ℕ+} : p.Prime → p ≠ 1 :=
  by
  intro pp
  intro contra
  apply Nat.Prime.ne_one pp
  rw [PNat.coe_eq_one_iff]
  apply contra
#align pnat.prime.ne_one PNat.Prime.ne_one
-/

#print PNat.not_prime_one /-
@[simp]
theorem not_prime_one : ¬(1 : ℕ+).Prime :=
  Nat.not_prime_one
#align pnat.not_prime_one PNat.not_prime_one
-/

/- warning: pnat.prime.not_dvd_one -> PNat.Prime.not_dvd_one is a dubious translation:
lean 3 declaration is
  forall {p : PNat}, (PNat.Prime p) -> (Not (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) p (OfNat.ofNat.{0} PNat 1 (OfNat.mk.{0} PNat 1 (One.one.{0} PNat PNat.hasOne)))))
but is expected to have type
  forall {p : PNat}, (PNat.Prime p) -> (Not (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) p (OfNat.ofNat.{0} PNat 1 (instOfNatPNatHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0))))))
Case conversion may be inaccurate. Consider using '#align pnat.prime.not_dvd_one PNat.Prime.not_dvd_oneₓ'. -/
theorem Prime.not_dvd_one {p : ℕ+} : p.Prime → ¬p ∣ 1 := fun pp : p.Prime =>
  by
  rw [dvd_iff]
  apply Nat.Prime.not_dvd_one pp
#align pnat.prime.not_dvd_one PNat.Prime.not_dvd_one

/- warning: pnat.exists_prime_and_dvd -> PNat.exists_prime_and_dvd is a dubious translation:
lean 3 declaration is
  forall {n : PNat}, (Ne.{1} PNat n (OfNat.ofNat.{0} PNat 1 (OfNat.mk.{0} PNat 1 (One.one.{0} PNat PNat.hasOne)))) -> (Exists.{1} PNat (fun (p : PNat) => And (PNat.Prime p) (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) p n)))
but is expected to have type
  forall {n : PNat}, (Ne.{1} PNat n (OfNat.ofNat.{0} PNat 1 (instOfNatPNatHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0))))) -> (Exists.{1} PNat (fun (p : PNat) => And (PNat.Prime p) (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) p n)))
Case conversion may be inaccurate. Consider using '#align pnat.exists_prime_and_dvd PNat.exists_prime_and_dvdₓ'. -/
theorem exists_prime_and_dvd {n : ℕ+} (hn : n ≠ 1) : ∃ p : ℕ+, p.Prime ∧ p ∣ n :=
  by
  obtain ⟨p, hp⟩ := Nat.exists_prime_and_dvd (mt coe_eq_one_iff.mp hn)
  exists (⟨p, Nat.Prime.pos hp.left⟩ : ℕ+); rw [dvd_iff]; apply hp
#align pnat.exists_prime_and_dvd PNat.exists_prime_and_dvd

end Prime

section Coprime

/-! ### Coprime numbers and gcd -/


#print PNat.Coprime /-
/-- Two pnats are coprime if their gcd is 1. -/
def Coprime (m n : ℕ+) : Prop :=
  m.gcd n = 1
#align pnat.coprime PNat.Coprime
-/

#print PNat.coprime_coe /-
@[simp, norm_cast]
theorem coprime_coe {m n : ℕ+} : Nat.Coprime ↑m ↑n ↔ m.Coprime n :=
  by
  unfold coprime
  unfold Nat.Coprime
  rw [← coe_inj]
  simp
#align pnat.coprime_coe PNat.coprime_coe
-/

/- warning: pnat.coprime.mul -> PNat.Coprime.mul is a dubious translation:
lean 3 declaration is
  forall {k : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m k) -> (PNat.Coprime n k) -> (PNat.Coprime (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) m n) k)
but is expected to have type
  forall {k : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m k) -> (PNat.Coprime n k) -> (PNat.Coprime (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) m n) k)
Case conversion may be inaccurate. Consider using '#align pnat.coprime.mul PNat.Coprime.mulₓ'. -/
theorem Coprime.mul {k m n : ℕ+} : m.Coprime k → n.Coprime k → (m * n).Coprime k :=
  by
  repeat' rw [← coprime_coe]
  rw [mul_coe]
  apply Nat.Coprime.mul
#align pnat.coprime.mul PNat.Coprime.mul

/- warning: pnat.coprime.mul_right -> PNat.Coprime.mul_right is a dubious translation:
lean 3 declaration is
  forall {k : PNat} {m : PNat} {n : PNat}, (PNat.Coprime k m) -> (PNat.Coprime k n) -> (PNat.Coprime k (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) m n))
but is expected to have type
  forall {k : PNat} {m : PNat} {n : PNat}, (PNat.Coprime k m) -> (PNat.Coprime k n) -> (PNat.Coprime k (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) m n))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.mul_right PNat.Coprime.mul_rightₓ'. -/
theorem Coprime.mul_right {k m n : ℕ+} : k.Coprime m → k.Coprime n → k.Coprime (m * n) :=
  by
  repeat' rw [← coprime_coe]
  rw [mul_coe]
  apply Nat.Coprime.mul_right
#align pnat.coprime.mul_right PNat.Coprime.mul_right

#print PNat.gcd_comm /-
theorem gcd_comm {m n : ℕ+} : m.gcd n = n.gcd m :=
  by
  apply Eq
  simp only [gcd_coe]
  apply Nat.gcd_comm
#align pnat.gcd_comm PNat.gcd_comm
-/

/- warning: pnat.gcd_eq_left_iff_dvd -> PNat.gcd_eq_left_iff_dvd is a dubious translation:
lean 3 declaration is
  forall {m : PNat} {n : PNat}, Iff (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) m n) (Eq.{1} PNat (PNat.gcd m n) m)
but is expected to have type
  forall {m : PNat} {n : PNat}, Iff (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) m n) (Eq.{1} PNat (PNat.gcd m n) m)
Case conversion may be inaccurate. Consider using '#align pnat.gcd_eq_left_iff_dvd PNat.gcd_eq_left_iff_dvdₓ'. -/
theorem gcd_eq_left_iff_dvd {m n : ℕ+} : m ∣ n ↔ m.gcd n = m :=
  by
  rw [dvd_iff]
  rw [Nat.gcd_eq_left_iff_dvd]
  rw [← coe_inj]
  simp
#align pnat.gcd_eq_left_iff_dvd PNat.gcd_eq_left_iff_dvd

/- warning: pnat.gcd_eq_right_iff_dvd -> PNat.gcd_eq_right_iff_dvd is a dubious translation:
lean 3 declaration is
  forall {m : PNat} {n : PNat}, Iff (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) m n) (Eq.{1} PNat (PNat.gcd n m) m)
but is expected to have type
  forall {m : PNat} {n : PNat}, Iff (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) m n) (Eq.{1} PNat (PNat.gcd n m) m)
Case conversion may be inaccurate. Consider using '#align pnat.gcd_eq_right_iff_dvd PNat.gcd_eq_right_iff_dvdₓ'. -/
theorem gcd_eq_right_iff_dvd {m n : ℕ+} : m ∣ n ↔ n.gcd m = m :=
  by
  rw [gcd_comm]
  apply gcd_eq_left_iff_dvd
#align pnat.gcd_eq_right_iff_dvd PNat.gcd_eq_right_iff_dvd

/- warning: pnat.coprime.gcd_mul_left_cancel -> PNat.Coprime.gcd_mul_left_cancel is a dubious translation:
lean 3 declaration is
  forall (m : PNat) {n : PNat} {k : PNat}, (PNat.Coprime k n) -> (Eq.{1} PNat (PNat.gcd (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) k m) n) (PNat.gcd m n))
but is expected to have type
  forall (m : PNat) {n : PNat} {k : PNat}, (PNat.Coprime k n) -> (Eq.{1} PNat (PNat.gcd (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) k m) n) (PNat.gcd m n))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.gcd_mul_left_cancel PNat.Coprime.gcd_mul_left_cancelₓ'. -/
theorem Coprime.gcd_mul_left_cancel (m : ℕ+) {n k : ℕ+} : k.Coprime n → (k * m).gcd n = m.gcd n :=
  by
  intro h; apply Eq; simp only [gcd_coe, mul_coe]
  apply Nat.Coprime.gcd_mul_left_cancel; simpa
#align pnat.coprime.gcd_mul_left_cancel PNat.Coprime.gcd_mul_left_cancel

/- warning: pnat.coprime.gcd_mul_right_cancel -> PNat.Coprime.gcd_mul_right_cancel is a dubious translation:
lean 3 declaration is
  forall (m : PNat) {n : PNat} {k : PNat}, (PNat.Coprime k n) -> (Eq.{1} PNat (PNat.gcd (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) m k) n) (PNat.gcd m n))
but is expected to have type
  forall (m : PNat) {n : PNat} {k : PNat}, (PNat.Coprime k n) -> (Eq.{1} PNat (PNat.gcd (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) m k) n) (PNat.gcd m n))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.gcd_mul_right_cancel PNat.Coprime.gcd_mul_right_cancelₓ'. -/
theorem Coprime.gcd_mul_right_cancel (m : ℕ+) {n k : ℕ+} : k.Coprime n → (m * k).gcd n = m.gcd n :=
  by rw [mul_comm]; apply coprime.gcd_mul_left_cancel
#align pnat.coprime.gcd_mul_right_cancel PNat.Coprime.gcd_mul_right_cancel

/- warning: pnat.coprime.gcd_mul_left_cancel_right -> PNat.Coprime.gcd_mul_left_cancel_right is a dubious translation:
lean 3 declaration is
  forall (m : PNat) {n : PNat} {k : PNat}, (PNat.Coprime k m) -> (Eq.{1} PNat (PNat.gcd m (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) k n)) (PNat.gcd m n))
but is expected to have type
  forall (m : PNat) {n : PNat} {k : PNat}, (PNat.Coprime k m) -> (Eq.{1} PNat (PNat.gcd m (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) k n)) (PNat.gcd m n))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.gcd_mul_left_cancel_right PNat.Coprime.gcd_mul_left_cancel_rightₓ'. -/
theorem Coprime.gcd_mul_left_cancel_right (m : ℕ+) {n k : ℕ+} :
    k.Coprime m → m.gcd (k * n) = m.gcd n := by intro h; iterate 2 rw [gcd_comm]; symm;
  apply coprime.gcd_mul_left_cancel _ h
#align pnat.coprime.gcd_mul_left_cancel_right PNat.Coprime.gcd_mul_left_cancel_right

/- warning: pnat.coprime.gcd_mul_right_cancel_right -> PNat.Coprime.gcd_mul_right_cancel_right is a dubious translation:
lean 3 declaration is
  forall (m : PNat) {n : PNat} {k : PNat}, (PNat.Coprime k m) -> (Eq.{1} PNat (PNat.gcd m (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) n k)) (PNat.gcd m n))
but is expected to have type
  forall (m : PNat) {n : PNat} {k : PNat}, (PNat.Coprime k m) -> (Eq.{1} PNat (PNat.gcd m (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) n k)) (PNat.gcd m n))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.gcd_mul_right_cancel_right PNat.Coprime.gcd_mul_right_cancel_rightₓ'. -/
theorem Coprime.gcd_mul_right_cancel_right (m : ℕ+) {n k : ℕ+} :
    k.Coprime m → m.gcd (n * k) = m.gcd n := by rw [mul_comm];
  apply coprime.gcd_mul_left_cancel_right
#align pnat.coprime.gcd_mul_right_cancel_right PNat.Coprime.gcd_mul_right_cancel_right

#print PNat.one_gcd /-
@[simp]
theorem one_gcd {n : ℕ+} : gcd 1 n = 1 :=
  by
  rw [← gcd_eq_left_iff_dvd]
  apply one_dvd
#align pnat.one_gcd PNat.one_gcd
-/

#print PNat.gcd_one /-
@[simp]
theorem gcd_one {n : ℕ+} : gcd n 1 = 1 := by
  rw [gcd_comm]
  apply one_gcd
#align pnat.gcd_one PNat.gcd_one
-/

#print PNat.Coprime.symm /-
@[symm]
theorem Coprime.symm {m n : ℕ+} : m.Coprime n → n.Coprime m :=
  by
  unfold coprime
  rw [gcd_comm]
  simp
#align pnat.coprime.symm PNat.Coprime.symm
-/

#print PNat.one_coprime /-
@[simp]
theorem one_coprime {n : ℕ+} : (1 : ℕ+).Coprime n :=
  one_gcd
#align pnat.one_coprime PNat.one_coprime
-/

#print PNat.coprime_one /-
@[simp]
theorem coprime_one {n : ℕ+} : n.Coprime 1 :=
  Coprime.symm one_coprime
#align pnat.coprime_one PNat.coprime_one
-/

/- warning: pnat.coprime.coprime_dvd_left -> PNat.Coprime.coprime_dvd_left is a dubious translation:
lean 3 declaration is
  forall {m : PNat} {k : PNat} {n : PNat}, (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) m k) -> (PNat.Coprime k n) -> (PNat.Coprime m n)
but is expected to have type
  forall {m : PNat} {k : PNat} {n : PNat}, (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) m k) -> (PNat.Coprime k n) -> (PNat.Coprime m n)
Case conversion may be inaccurate. Consider using '#align pnat.coprime.coprime_dvd_left PNat.Coprime.coprime_dvd_leftₓ'. -/
theorem Coprime.coprime_dvd_left {m k n : ℕ+} : m ∣ k → k.Coprime n → m.Coprime n :=
  by
  rw [dvd_iff]
  repeat' rw [← coprime_coe]
  apply Nat.Coprime.coprime_dvd_left
#align pnat.coprime.coprime_dvd_left PNat.Coprime.coprime_dvd_left

/- warning: pnat.coprime.factor_eq_gcd_left -> PNat.Coprime.factor_eq_gcd_left is a dubious translation:
lean 3 declaration is
  forall {a : PNat} {b : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) a m) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) b n) -> (Eq.{1} PNat a (PNat.gcd (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) a b) m))
but is expected to have type
  forall {a : PNat} {b : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) a m) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) b n) -> (Eq.{1} PNat a (PNat.gcd (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) a b) m))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.factor_eq_gcd_left PNat.Coprime.factor_eq_gcd_leftₓ'. -/
theorem Coprime.factor_eq_gcd_left {a b m n : ℕ+} (cop : m.Coprime n) (am : a ∣ m) (bn : b ∣ n) :
    a = (a * b).gcd m := by
  rw [gcd_eq_left_iff_dvd] at am
  conv_lhs => rw [← am]; symm
  apply coprime.gcd_mul_right_cancel a
  apply coprime.coprime_dvd_left bn cop.symm
#align pnat.coprime.factor_eq_gcd_left PNat.Coprime.factor_eq_gcd_left

/- warning: pnat.coprime.factor_eq_gcd_right -> PNat.Coprime.factor_eq_gcd_right is a dubious translation:
lean 3 declaration is
  forall {a : PNat} {b : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) a m) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) b n) -> (Eq.{1} PNat a (PNat.gcd (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) b a) m))
but is expected to have type
  forall {a : PNat} {b : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) a m) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) b n) -> (Eq.{1} PNat a (PNat.gcd (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) b a) m))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.factor_eq_gcd_right PNat.Coprime.factor_eq_gcd_rightₓ'. -/
theorem Coprime.factor_eq_gcd_right {a b m n : ℕ+} (cop : m.Coprime n) (am : a ∣ m) (bn : b ∣ n) :
    a = (b * a).gcd m := by rw [mul_comm]; apply coprime.factor_eq_gcd_left cop am bn
#align pnat.coprime.factor_eq_gcd_right PNat.Coprime.factor_eq_gcd_right

/- warning: pnat.coprime.factor_eq_gcd_left_right -> PNat.Coprime.factor_eq_gcd_left_right is a dubious translation:
lean 3 declaration is
  forall {a : PNat} {b : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) a m) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) b n) -> (Eq.{1} PNat a (PNat.gcd m (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) a b)))
but is expected to have type
  forall {a : PNat} {b : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) a m) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) b n) -> (Eq.{1} PNat a (PNat.gcd m (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) a b)))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.factor_eq_gcd_left_right PNat.Coprime.factor_eq_gcd_left_rightₓ'. -/
theorem Coprime.factor_eq_gcd_left_right {a b m n : ℕ+} (cop : m.Coprime n) (am : a ∣ m)
    (bn : b ∣ n) : a = m.gcd (a * b) := by rw [gcd_comm]; apply coprime.factor_eq_gcd_left cop am bn
#align pnat.coprime.factor_eq_gcd_left_right PNat.Coprime.factor_eq_gcd_left_right

/- warning: pnat.coprime.factor_eq_gcd_right_right -> PNat.Coprime.factor_eq_gcd_right_right is a dubious translation:
lean 3 declaration is
  forall {a : PNat} {b : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) a m) -> (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) b n) -> (Eq.{1} PNat a (PNat.gcd m (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) b a)))
but is expected to have type
  forall {a : PNat} {b : PNat} {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) a m) -> (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) b n) -> (Eq.{1} PNat a (PNat.gcd m (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) b a)))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.factor_eq_gcd_right_right PNat.Coprime.factor_eq_gcd_right_rightₓ'. -/
theorem Coprime.factor_eq_gcd_right_right {a b m n : ℕ+} (cop : m.Coprime n) (am : a ∣ m)
    (bn : b ∣ n) : a = m.gcd (b * a) := by rw [gcd_comm];
  apply coprime.factor_eq_gcd_right cop am bn
#align pnat.coprime.factor_eq_gcd_right_right PNat.Coprime.factor_eq_gcd_right_right

/- warning: pnat.coprime.gcd_mul -> PNat.Coprime.gcd_mul is a dubious translation:
lean 3 declaration is
  forall (k : PNat) {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Eq.{1} PNat (PNat.gcd k (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) m n)) (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat PNat.hasMul) (PNat.gcd k m) (PNat.gcd k n)))
but is expected to have type
  forall (k : PNat) {m : PNat} {n : PNat}, (PNat.Coprime m n) -> (Eq.{1} PNat (PNat.gcd k (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) m n)) (HMul.hMul.{0, 0, 0} PNat PNat PNat (instHMul.{0} PNat instPNatMul) (PNat.gcd k m) (PNat.gcd k n)))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.gcd_mul PNat.Coprime.gcd_mulₓ'. -/
theorem Coprime.gcd_mul (k : ℕ+) {m n : ℕ+} (h : m.Coprime n) : k.gcd (m * n) = k.gcd m * k.gcd n :=
  by
  rw [← coprime_coe] at h; apply Eq
  simp only [gcd_coe, mul_coe]; apply Nat.Coprime.gcd_mul k h
#align pnat.coprime.gcd_mul PNat.Coprime.gcd_mul

/- warning: pnat.gcd_eq_left -> PNat.gcd_eq_left is a dubious translation:
lean 3 declaration is
  forall {m : PNat} {n : PNat}, (Dvd.Dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) m n) -> (Eq.{1} PNat (PNat.gcd m n) m)
but is expected to have type
  forall {m : PNat} {n : PNat}, (Dvd.dvd.{0} PNat (semigroupDvd.{0} PNat (Monoid.toSemigroup.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat instPNatLinearOrderedCancelCommMonoid))))))) m n) -> (Eq.{1} PNat (PNat.gcd m n) m)
Case conversion may be inaccurate. Consider using '#align pnat.gcd_eq_left PNat.gcd_eq_leftₓ'. -/
theorem gcd_eq_left {m n : ℕ+} : m ∣ n → m.gcd n = m :=
  by
  rw [dvd_iff]
  intro h
  apply Eq
  simp only [gcd_coe]
  apply Nat.gcd_eq_left h
#align pnat.gcd_eq_left PNat.gcd_eq_left

/- warning: pnat.coprime.pow -> PNat.Coprime.pow is a dubious translation:
lean 3 declaration is
  forall {m : PNat} {n : PNat} (k : Nat) (l : Nat), (PNat.Coprime m n) -> (PNat.Coprime (HPow.hPow.{0, 0, 0} PNat Nat PNat (instHPow.{0, 0} PNat Nat (Monoid.Pow.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) m k) (HPow.hPow.{0, 0, 0} PNat Nat PNat (instHPow.{0, 0} PNat Nat (Monoid.Pow.{0} PNat (RightCancelMonoid.toMonoid.{0} PNat (CancelMonoid.toRightCancelMonoid.{0} PNat (CancelCommMonoid.toCancelMonoid.{0} PNat (OrderedCancelCommMonoid.toCancelCommMonoid.{0} PNat (LinearOrderedCancelCommMonoid.toOrderedCancelCommMonoid.{0} PNat PNat.linearOrderedCancelCommMonoid))))))) n l))
but is expected to have type
  forall {m : PNat} {n : PNat} (k : Nat) (l : Nat), (PNat.Coprime m n) -> (Nat.coprime (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat instPowNat) (PNat.val m) k) (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat instPowNat) (PNat.val n) l))
Case conversion may be inaccurate. Consider using '#align pnat.coprime.pow PNat.Coprime.powₓ'. -/
theorem Coprime.pow {m n : ℕ+} (k l : ℕ) (h : m.Coprime n) : (m ^ k).Coprime (n ^ l) := by
  rw [← coprime_coe] at *; simp only [pow_coe]; apply Nat.Coprime.pow; apply h
#align pnat.coprime.pow PNat.Coprime.pow

end Coprime

end PNat

