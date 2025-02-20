/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Neil Strickland

! This file was ported from Lean 3 source module data.pnat.prime
! leanprover-community/mathlib commit baba818b9acea366489e8ba32d2cc0fcaf50a1f7
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

#print Nat.Primes.coePNat /-
instance coePNat : Coe Nat.Primes ℕ+ :=
  ⟨fun p => ⟨(p : ℕ), p.property.Pos⟩⟩
#align nat.primes.coe_pnat Nat.Primes.coePNat
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

#print PNat.gcd_dvd_left /-
theorem gcd_dvd_left (n m : ℕ+) : gcd n m ∣ n :=
  dvd_iff.2 (Nat.gcd_dvd_left (n : ℕ) (m : ℕ))
#align pnat.gcd_dvd_left PNat.gcd_dvd_left
-/

#print PNat.gcd_dvd_right /-
theorem gcd_dvd_right (n m : ℕ+) : gcd n m ∣ m :=
  dvd_iff.2 (Nat.gcd_dvd_right (n : ℕ) (m : ℕ))
#align pnat.gcd_dvd_right PNat.gcd_dvd_right
-/

#print PNat.dvd_gcd /-
theorem dvd_gcd {m n k : ℕ+} (hm : k ∣ m) (hn : k ∣ n) : k ∣ gcd m n :=
  dvd_iff.2 (@Nat.dvd_gcd (m : ℕ) (n : ℕ) (k : ℕ) (dvd_iff.1 hm) (dvd_iff.1 hn))
#align pnat.dvd_gcd PNat.dvd_gcd
-/

#print PNat.dvd_lcm_left /-
theorem dvd_lcm_left (n m : ℕ+) : n ∣ lcm n m :=
  dvd_iff.2 (Nat.dvd_lcm_left (n : ℕ) (m : ℕ))
#align pnat.dvd_lcm_left PNat.dvd_lcm_left
-/

#print PNat.dvd_lcm_right /-
theorem dvd_lcm_right (n m : ℕ+) : m ∣ lcm n m :=
  dvd_iff.2 (Nat.dvd_lcm_right (n : ℕ) (m : ℕ))
#align pnat.dvd_lcm_right PNat.dvd_lcm_right
-/

#print PNat.lcm_dvd /-
theorem lcm_dvd {m n k : ℕ+} (hm : m ∣ k) (hn : n ∣ k) : lcm m n ∣ k :=
  dvd_iff.2 (@Nat.lcm_dvd (m : ℕ) (n : ℕ) (k : ℕ) (dvd_iff.1 hm) (dvd_iff.1 hn))
#align pnat.lcm_dvd PNat.lcm_dvd
-/

#print PNat.gcd_mul_lcm /-
theorem gcd_mul_lcm (n m : ℕ+) : gcd n m * lcm n m = n * m :=
  Subtype.eq (Nat.gcd_mul_lcm (n : ℕ) (m : ℕ))
#align pnat.gcd_mul_lcm PNat.gcd_mul_lcm
-/

#print PNat.eq_one_of_lt_two /-
theorem eq_one_of_lt_two {n : ℕ+} : n < 2 → n = 1 :=
  by
  intro h; apply le_antisymm; swap; apply PNat.one_le
  change n < 1 + 1 at h ; rw [PNat.lt_add_one_iff] at h ; apply h
#align pnat.eq_one_of_lt_two PNat.eq_one_of_lt_two
-/

section Prime

/-! ### Prime numbers -/


#print PNat.Prime /-
/-- Primality predicate for `ℕ+`, defined in terms of `nat.prime`. -/
def Prime (p : ℕ+) : Prop :=
  (p : ℕ).Prime
#align pnat.prime PNat.Prime
-/

#print PNat.Prime.one_lt /-
theorem Prime.one_lt {p : ℕ+} : p.Prime → 1 < p :=
  Nat.Prime.one_lt
#align pnat.prime.one_lt PNat.Prime.one_lt
-/

#print PNat.prime_two /-
theorem prime_two : (2 : ℕ+).Prime :=
  Nat.prime_two
#align pnat.prime_two PNat.prime_two
-/

#print PNat.dvd_prime /-
theorem dvd_prime {p m : ℕ+} (pp : p.Prime) : m ∣ p ↔ m = 1 ∨ m = p := by rw [PNat.dvd_iff];
  rw [Nat.dvd_prime pp]; simp
#align pnat.dvd_prime PNat.dvd_prime
-/

#print PNat.Prime.ne_one /-
theorem Prime.ne_one {p : ℕ+} : p.Prime → p ≠ 1 := by intro pp; intro contra;
  apply Nat.Prime.ne_one pp; rw [PNat.coe_eq_one_iff]; apply contra
#align pnat.prime.ne_one PNat.Prime.ne_one
-/

#print PNat.not_prime_one /-
@[simp]
theorem not_prime_one : ¬(1 : ℕ+).Prime :=
  Nat.not_prime_one
#align pnat.not_prime_one PNat.not_prime_one
-/

#print PNat.Prime.not_dvd_one /-
theorem Prime.not_dvd_one {p : ℕ+} : p.Prime → ¬p ∣ 1 := fun pp : p.Prime => by rw [dvd_iff];
  apply Nat.Prime.not_dvd_one pp
#align pnat.prime.not_dvd_one PNat.Prime.not_dvd_one
-/

#print PNat.exists_prime_and_dvd /-
theorem exists_prime_and_dvd {n : ℕ+} (hn : n ≠ 1) : ∃ p : ℕ+, p.Prime ∧ p ∣ n :=
  by
  obtain ⟨p, hp⟩ := Nat.exists_prime_and_dvd (mt coe_eq_one_iff.mp hn)
  exists (⟨p, Nat.Prime.pos hp.left⟩ : ℕ+); rw [dvd_iff]; apply hp
#align pnat.exists_prime_and_dvd PNat.exists_prime_and_dvd
-/

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
theorem coprime_coe {m n : ℕ+} : Nat.coprime ↑m ↑n ↔ m.coprime n := by unfold coprime;
  unfold Nat.coprime; rw [← coe_inj]; simp
#align pnat.coprime_coe PNat.coprime_coe
-/

#print PNat.Coprime.mul /-
theorem Coprime.mul {k m n : ℕ+} : m.coprime k → n.coprime k → (m * n).coprime k := by
  repeat' rw [← coprime_coe]; rw [mul_coe]; apply Nat.coprime.mul
#align pnat.coprime.mul PNat.Coprime.mul
-/

#print PNat.Coprime.mul_right /-
theorem Coprime.mul_right {k m n : ℕ+} : k.coprime m → k.coprime n → k.coprime (m * n) := by
  repeat' rw [← coprime_coe]; rw [mul_coe]; apply Nat.coprime.mul_right
#align pnat.coprime.mul_right PNat.Coprime.mul_right
-/

#print PNat.gcd_comm /-
theorem gcd_comm {m n : ℕ+} : m.gcd n = n.gcd m := by apply Eq; simp only [gcd_coe];
  apply Nat.gcd_comm
#align pnat.gcd_comm PNat.gcd_comm
-/

#print PNat.gcd_eq_left_iff_dvd /-
theorem gcd_eq_left_iff_dvd {m n : ℕ+} : m ∣ n ↔ m.gcd n = m := by rw [dvd_iff];
  rw [Nat.gcd_eq_left_iff_dvd]; rw [← coe_inj]; simp
#align pnat.gcd_eq_left_iff_dvd PNat.gcd_eq_left_iff_dvd
-/

#print PNat.gcd_eq_right_iff_dvd /-
theorem gcd_eq_right_iff_dvd {m n : ℕ+} : m ∣ n ↔ n.gcd m = m := by rw [gcd_comm];
  apply gcd_eq_left_iff_dvd
#align pnat.gcd_eq_right_iff_dvd PNat.gcd_eq_right_iff_dvd
-/

#print PNat.Coprime.gcd_mul_left_cancel /-
theorem Coprime.gcd_mul_left_cancel (m : ℕ+) {n k : ℕ+} : k.coprime n → (k * m).gcd n = m.gcd n :=
  by
  intro h; apply Eq; simp only [gcd_coe, mul_coe]
  apply Nat.coprime.gcd_mul_left_cancel; simpa
#align pnat.coprime.gcd_mul_left_cancel PNat.Coprime.gcd_mul_left_cancel
-/

#print PNat.Coprime.gcd_mul_right_cancel /-
theorem Coprime.gcd_mul_right_cancel (m : ℕ+) {n k : ℕ+} : k.coprime n → (m * k).gcd n = m.gcd n :=
  by rw [mul_comm]; apply coprime.gcd_mul_left_cancel
#align pnat.coprime.gcd_mul_right_cancel PNat.Coprime.gcd_mul_right_cancel
-/

#print PNat.Coprime.gcd_mul_left_cancel_right /-
theorem Coprime.gcd_mul_left_cancel_right (m : ℕ+) {n k : ℕ+} :
    k.coprime m → m.gcd (k * n) = m.gcd n := by intro h; iterate 2 rw [gcd_comm]; symm;
  apply coprime.gcd_mul_left_cancel _ h
#align pnat.coprime.gcd_mul_left_cancel_right PNat.Coprime.gcd_mul_left_cancel_right
-/

#print PNat.Coprime.gcd_mul_right_cancel_right /-
theorem Coprime.gcd_mul_right_cancel_right (m : ℕ+) {n k : ℕ+} :
    k.coprime m → m.gcd (n * k) = m.gcd n := by rw [mul_comm];
  apply coprime.gcd_mul_left_cancel_right
#align pnat.coprime.gcd_mul_right_cancel_right PNat.Coprime.gcd_mul_right_cancel_right
-/

#print PNat.one_gcd /-
@[simp]
theorem one_gcd {n : ℕ+} : gcd 1 n = 1 := by rw [← gcd_eq_left_iff_dvd]; apply one_dvd
#align pnat.one_gcd PNat.one_gcd
-/

#print PNat.gcd_one /-
@[simp]
theorem gcd_one {n : ℕ+} : gcd n 1 = 1 := by rw [gcd_comm]; apply one_gcd
#align pnat.gcd_one PNat.gcd_one
-/

#print PNat.Coprime.symm /-
@[symm]
theorem Coprime.symm {m n : ℕ+} : m.coprime n → n.coprime m := by unfold coprime; rw [gcd_comm];
  simp
#align pnat.coprime.symm PNat.Coprime.symm
-/

#print PNat.one_coprime /-
@[simp]
theorem one_coprime {n : ℕ+} : (1 : ℕ+).coprime n :=
  one_gcd
#align pnat.one_coprime PNat.one_coprime
-/

#print PNat.coprime_one /-
@[simp]
theorem coprime_one {n : ℕ+} : n.coprime 1 :=
  Coprime.symm one_coprime
#align pnat.coprime_one PNat.coprime_one
-/

#print PNat.Coprime.coprime_dvd_left /-
theorem Coprime.coprime_dvd_left {m k n : ℕ+} : m ∣ k → k.coprime n → m.coprime n := by
  rw [dvd_iff]; repeat' rw [← coprime_coe]; apply Nat.coprime.coprime_dvd_left
#align pnat.coprime.coprime_dvd_left PNat.Coprime.coprime_dvd_left
-/

#print PNat.Coprime.factor_eq_gcd_left /-
theorem Coprime.factor_eq_gcd_left {a b m n : ℕ+} (cop : m.coprime n) (am : a ∣ m) (bn : b ∣ n) :
    a = (a * b).gcd m := by
  rw [gcd_eq_left_iff_dvd] at am 
  conv_lhs => rw [← am]; symm
  apply coprime.gcd_mul_right_cancel a
  apply coprime.coprime_dvd_left bn cop.symm
#align pnat.coprime.factor_eq_gcd_left PNat.Coprime.factor_eq_gcd_left
-/

#print PNat.Coprime.factor_eq_gcd_right /-
theorem Coprime.factor_eq_gcd_right {a b m n : ℕ+} (cop : m.coprime n) (am : a ∣ m) (bn : b ∣ n) :
    a = (b * a).gcd m := by rw [mul_comm]; apply coprime.factor_eq_gcd_left cop am bn
#align pnat.coprime.factor_eq_gcd_right PNat.Coprime.factor_eq_gcd_right
-/

#print PNat.Coprime.factor_eq_gcd_left_right /-
theorem Coprime.factor_eq_gcd_left_right {a b m n : ℕ+} (cop : m.coprime n) (am : a ∣ m)
    (bn : b ∣ n) : a = m.gcd (a * b) := by rw [gcd_comm]; apply coprime.factor_eq_gcd_left cop am bn
#align pnat.coprime.factor_eq_gcd_left_right PNat.Coprime.factor_eq_gcd_left_right
-/

#print PNat.Coprime.factor_eq_gcd_right_right /-
theorem Coprime.factor_eq_gcd_right_right {a b m n : ℕ+} (cop : m.coprime n) (am : a ∣ m)
    (bn : b ∣ n) : a = m.gcd (b * a) := by rw [gcd_comm];
  apply coprime.factor_eq_gcd_right cop am bn
#align pnat.coprime.factor_eq_gcd_right_right PNat.Coprime.factor_eq_gcd_right_right
-/

#print PNat.Coprime.gcd_mul /-
theorem Coprime.gcd_mul (k : ℕ+) {m n : ℕ+} (h : m.coprime n) : k.gcd (m * n) = k.gcd m * k.gcd n :=
  by
  rw [← coprime_coe] at h ; apply Eq
  simp only [gcd_coe, mul_coe]; apply Nat.coprime.gcd_mul k h
#align pnat.coprime.gcd_mul PNat.Coprime.gcd_mul
-/

#print PNat.gcd_eq_left /-
theorem gcd_eq_left {m n : ℕ+} : m ∣ n → m.gcd n = m := by rw [dvd_iff]; intro h; apply Eq;
  simp only [gcd_coe]; apply Nat.gcd_eq_left h
#align pnat.gcd_eq_left PNat.gcd_eq_left
-/

#print PNat.Coprime.pow /-
theorem Coprime.pow {m n : ℕ+} (k l : ℕ) (h : m.coprime n) : (m ^ k).coprime (n ^ l) := by
  rw [← coprime_coe] at *; simp only [pow_coe]; apply Nat.coprime.pow; apply h
#align pnat.coprime.pow PNat.Coprime.pow
-/

end Coprime

end PNat

