/-
Copyright (c) 2022 Tian Chen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tian Chen, Mantas Bakšys

! This file was ported from Lean 3 source module number_theory.multiplicity
! leanprover-community/mathlib commit 33c67ae661dd8988516ff7f247b0be3018cdd952
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GeomSum
import Mathbin.Data.Int.Parity
import Mathbin.Data.Zmod.Basic
import Mathbin.NumberTheory.Padics.PadicVal
import Mathbin.RingTheory.Ideal.QuotientOperations

/-!
# Multiplicity in Number Theory

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains results in number theory relating to multiplicity.

## Main statements

* `multiplicity.int.pow_sub_pow` is the lifting the exponent lemma for odd primes.
  We also prove several variations of the lemma.

## References

* [Wikipedia, *Lifting-the-exponent lemma*]
  (https://en.wikipedia.org/wiki/Lifting-the-exponent_lemma)
-/


open Ideal Ideal.Quotient Finset

open scoped BigOperators

variable {R : Type _} {n : ℕ}

section CommRing

variable [CommRing R] {a b x y : R}

#print dvd_geom_sum₂_iff_of_dvd_sub /-
theorem dvd_geom_sum₂_iff_of_dvd_sub {x y p : R} (h : p ∣ x - y) :
    p ∣ ∑ i in range n, x ^ i * y ^ (n - 1 - i) ↔ p ∣ n * y ^ (n - 1) :=
  by
  rw [← mem_span_singleton, ← Ideal.Quotient.eq] at h 
  simp only [← mem_span_singleton, ← eq_zero_iff_mem, RingHom.map_geom_sum₂, h, geom_sum₂_self,
    _root_.map_mul, map_pow, map_natCast]
#align dvd_geom_sum₂_iff_of_dvd_sub dvd_geom_sum₂_iff_of_dvd_sub
-/

#print dvd_geom_sum₂_iff_of_dvd_sub' /-
theorem dvd_geom_sum₂_iff_of_dvd_sub' {x y p : R} (h : p ∣ x - y) :
    p ∣ ∑ i in range n, x ^ i * y ^ (n - 1 - i) ↔ p ∣ n * x ^ (n - 1) := by
  rw [geom_sum₂_comm, dvd_geom_sum₂_iff_of_dvd_sub] <;> simpa using h.neg_right
#align dvd_geom_sum₂_iff_of_dvd_sub' dvd_geom_sum₂_iff_of_dvd_sub'
-/

#print dvd_geom_sum₂_self /-
theorem dvd_geom_sum₂_self {x y : R} (h : ↑n ∣ x - y) :
    ↑n ∣ ∑ i in range n, x ^ i * y ^ (n - 1 - i) :=
  (dvd_geom_sum₂_iff_of_dvd_sub h).mpr (dvd_mul_right _ _)
#align dvd_geom_sum₂_self dvd_geom_sum₂_self
-/

#print sq_dvd_add_pow_sub_sub /-
theorem sq_dvd_add_pow_sub_sub (p x : R) (n : ℕ) :
    p ^ 2 ∣ (x + p) ^ n - x ^ (n - 1) * p * n - x ^ n :=
  by
  cases n
  · simp only [pow_zero, Nat.cast_zero, MulZeroClass.mul_zero, sub_zero, sub_self, dvd_zero]
  · simp only [Nat.succ_sub_succ_eq_sub, tsub_zero, Nat.cast_succ, add_pow, Finset.sum_range_succ,
      Nat.choose_self, Nat.succ_sub _, tsub_self, pow_one, Nat.choose_succ_self_right, pow_zero,
      mul_one, Nat.cast_zero, zero_add, Nat.succ_eq_add_one]
    suffices p ^ 2 ∣ ∑ i : ℕ in range n, x ^ i * p ^ (n + 1 - i) * ↑((n + 1).choose i) by
      convert this <;> abel
    · apply Finset.dvd_sum
      intro y hy
      calc
        p ^ 2 ∣ p ^ (n + 1 - y) :=
          pow_dvd_pow p (le_tsub_of_add_le_left (by linarith [finset.mem_range.mp hy]))
        _ ∣ x ^ y * p ^ (n + 1 - y) * ↑((n + 1).choose y) :=
          dvd_mul_of_dvd_left (dvd_mul_left _ _) ((n + 1).choose y)
#align sq_dvd_add_pow_sub_sub sq_dvd_add_pow_sub_sub
-/

#print not_dvd_geom_sum₂ /-
theorem not_dvd_geom_sum₂ {p : R} (hp : Prime p) (hxy : p ∣ x - y) (hx : ¬p ∣ x) (hn : ¬p ∣ n) :
    ¬p ∣ ∑ i in range n, x ^ i * y ^ (n - 1 - i) := fun h =>
  hx <|
    hp.dvd_of_dvd_pow <| (hp.dvd_or_dvd <| (dvd_geom_sum₂_iff_of_dvd_sub' hxy).mp h).resolve_left hn
#align not_dvd_geom_sum₂ not_dvd_geom_sum₂
-/

variable {p : ℕ} (a b)

#print odd_sq_dvd_geom_sum₂_sub /-
theorem odd_sq_dvd_geom_sum₂_sub (hp : Odd p) :
    ↑p ^ 2 ∣ ∑ i in range p, (a + p * b) ^ i * a ^ (p - 1 - i) - p * a ^ (p - 1) :=
  by
  have h1 : ∀ i, ↑p ^ 2 ∣ (a + ↑p * b) ^ i - (a ^ (i - 1) * (↑p * b) * ↑i + a ^ i) :=
    by
    intro i
    calc
      ↑p ^ 2 ∣ (↑p * b) ^ 2 := by simp only [mul_pow, dvd_mul_right]
      _ ∣ (a + ↑p * b) ^ i - (a ^ (i - 1) * (↑p * b) * ↑i + a ^ i) := by
        simp only [sq_dvd_add_pow_sub_sub (↑p * b) a i, ← sub_sub]
  simp_rw [← mem_span_singleton, ← Ideal.Quotient.eq] at *
  calc
    Ideal.Quotient.mk (span {↑p ^ 2}) (∑ i in range p, (a + ↑p * b) ^ i * a ^ (p - 1 - i)) =
        ∑ i : ℕ in Finset.range p,
          mk (span {↑p ^ 2}) ((a ^ (i - 1) * (↑p * b) * ↑i + a ^ i) * a ^ (p - 1 - i)) :=
      by simp_rw [RingHom.map_geom_sum₂, ← map_pow, h1, ← _root_.map_mul]
    _ =
        mk (span {↑p ^ 2})
            (∑ x : ℕ in Finset.range p, a ^ (x - 1) * (a ^ (p - 1 - x) * (↑p * (b * ↑x)))) +
          mk (span {↑p ^ 2}) (∑ x : ℕ in Finset.range p, a ^ (x + (p - 1 - x))) :=
      by
      ring
      simp only [← pow_add, map_add, Finset.sum_add_distrib, ← map_sum]
    _ =
        mk (span {↑p ^ 2})
            (∑ x : ℕ in Finset.range p, a ^ (x - 1) * (a ^ (p - 1 - x) * (↑p * (b * ↑x)))) +
          mk (span {↑p ^ 2}) (∑ x : ℕ in Finset.range p, a ^ (p - 1)) :=
      by
      rw [add_right_inj, Finset.sum_congr rfl]
      intro x hx
      rw [← Nat.add_sub_assoc _ x, Nat.add_sub_cancel_left]
      exact Nat.le_pred_of_lt (finset.mem_range.mp hx)
    _ =
        mk (span {↑p ^ 2})
            (∑ x : ℕ in Finset.range p, a ^ (x - 1) * (a ^ (p - 1 - x) * (↑p * (b * ↑x)))) +
          mk (span {↑p ^ 2}) (↑p * a ^ (p - 1)) :=
      by simp only [add_right_inj, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
    _ =
        mk (span {↑p ^ 2}) (↑p * b * ∑ x : ℕ in Finset.range p, a ^ (p - 2) * x) +
          mk (span {↑p ^ 2}) (↑p * a ^ (p - 1)) :=
      by
      simp only [Finset.mul_sum, ← mul_assoc, ← pow_add]
      rw [Finset.sum_congr rfl]
      rintro (⟨⟩ | ⟨x⟩) hx
      · rw [Nat.cast_zero, MulZeroClass.mul_zero, MulZeroClass.mul_zero]
      · have : x.succ - 1 + (p - 1 - x.succ) = p - 2 :=
          by
          rw [← Nat.add_sub_assoc (Nat.le_pred_of_lt (finset.mem_range.mp hx))]
          exact congr_arg Nat.pred (Nat.add_sub_cancel_left _ _)
        rw [this]
        ring1
    _ = mk (span {↑p ^ 2}) (↑p * a ^ (p - 1)) :=
      by
      simp only [add_left_eq_self, ← Finset.mul_sum]
      norm_cast
      simp only [Finset.sum_range_id, Nat.cast_mul, _root_.map_mul,
        Nat.mul_div_assoc _ (even_iff_two_dvd.mp (Nat.Odd.sub_odd hp odd_one))]
      ring
      simp only [← map_pow, mul_eq_zero_of_left, Ideal.Quotient.eq_zero_iff_mem, mem_span_singleton]
#align odd_sq_dvd_geom_sum₂_sub odd_sq_dvd_geom_sum₂_sub
-/

namespace multiplicity

section IntegralDomain

variable [IsDomain R] [@DecidableRel R (· ∣ ·)]

#print multiplicity.pow_sub_pow_of_prime /-
theorem pow_sub_pow_of_prime {p : R} (hp : Prime p) {x y : R} (hxy : p ∣ x - y) (hx : ¬p ∣ x)
    {n : ℕ} (hn : ¬p ∣ n) : multiplicity p (x ^ n - y ^ n) = multiplicity p (x - y) := by
  rw [← geom_sum₂_mul, multiplicity.mul hp, multiplicity_eq_zero.2 (not_dvd_geom_sum₂ hp hxy hx hn),
    zero_add]
#align multiplicity.pow_sub_pow_of_prime multiplicity.pow_sub_pow_of_prime
-/

variable (hp : Prime (p : R)) (hp1 : Odd p) (hxy : ↑p ∣ x - y) (hx : ¬↑p ∣ x)

#print multiplicity.geom_sum₂_eq_one /-
theorem geom_sum₂_eq_one : multiplicity (↑p) (∑ i in range p, x ^ i * y ^ (p - 1 - i)) = 1 :=
  by
  rw [← Nat.cast_one]
  refine' multiplicity.eq_coe_iff.2 ⟨_, _⟩
  · rw [pow_one]
    exact dvd_geom_sum₂_self hxy
  rw [dvd_iff_dvd_of_dvd_sub hxy] at hx 
  cases' hxy with k hk
  rw [one_add_one_eq_two, eq_add_of_sub_eq' hk]
  refine' mt (dvd_iff_dvd_of_dvd_sub (@odd_sq_dvd_geom_sum₂_sub _ _ y k _ hp1)).mp _
  rw [pow_two, mul_dvd_mul_iff_left hp.ne_zero]
  exact mt hp.dvd_of_dvd_pow hx
#align multiplicity.geom_sum₂_eq_one multiplicity.geom_sum₂_eq_one
-/

#print multiplicity.pow_prime_sub_pow_prime /-
theorem pow_prime_sub_pow_prime :
    multiplicity (↑p) (x ^ p - y ^ p) = multiplicity (↑p) (x - y) + 1 := by
  rw [← geom_sum₂_mul, multiplicity.mul hp, geom_sum₂_eq_one hp hp1 hxy hx, add_comm]
#align multiplicity.pow_prime_sub_pow_prime multiplicity.pow_prime_sub_pow_prime
-/

#print multiplicity.pow_prime_pow_sub_pow_prime_pow /-
theorem pow_prime_pow_sub_pow_prime_pow (a : ℕ) :
    multiplicity (↑p) (x ^ p ^ a - y ^ p ^ a) = multiplicity (↑p) (x - y) + a :=
  by
  induction' a with a h_ind
  · rw [Nat.cast_zero, add_zero, pow_zero, pow_one, pow_one]
  rw [← Nat.add_one, Nat.cast_add, Nat.cast_one, ← add_assoc, ← h_ind, pow_succ', pow_mul, pow_mul]
  apply pow_prime_sub_pow_prime hp hp1
  · rw [← geom_sum₂_mul]
    exact dvd_mul_of_dvd_right hxy _
  · exact fun h => hx (hp.dvd_of_dvd_pow h)
#align multiplicity.pow_prime_pow_sub_pow_prime_pow multiplicity.pow_prime_pow_sub_pow_prime_pow
-/

end IntegralDomain

section LiftingTheExponent

variable (hp : Nat.Prime p) (hp1 : Odd p)

#print multiplicity.Int.pow_sub_pow /-
/-- **Lifting the exponent lemma** for odd primes. -/
theorem Int.pow_sub_pow {x y : ℤ} (hxy : ↑p ∣ x - y) (hx : ¬↑p ∣ x) (n : ℕ) :
    multiplicity (↑p) (x ^ n - y ^ n) = multiplicity (↑p) (x - y) + multiplicity p n :=
  by
  cases n
  · simp only [multiplicity.zero, add_top, pow_zero, sub_self]
  have h : (multiplicity _ _).Dom := finite_nat_iff.mpr ⟨hp.ne_one, n.succ_pos⟩
  rcases eq_coe_iff.mp (PartENat.natCast_get h).symm with ⟨⟨k, hk⟩, hpn⟩
  conv_lhs => rw [hk, pow_mul, pow_mul]
  rw [Nat.prime_iff_prime_int] at hp 
  rw [pow_sub_pow_of_prime hp, pow_prime_pow_sub_pow_prime_pow hp hp1 hxy hx, PartENat.natCast_get]
  · rw [← geom_sum₂_mul]
    exact dvd_mul_of_dvd_right hxy _
  · exact fun h => hx (hp.dvd_of_dvd_pow h)
  · rw [Int.coe_nat_dvd]
    rintro ⟨c, rfl⟩
    refine' hpn ⟨c, _⟩
    rwa [pow_succ', mul_assoc]
#align multiplicity.int.pow_sub_pow multiplicity.Int.pow_sub_pow
-/

#print multiplicity.Int.pow_add_pow /-
theorem Int.pow_add_pow {x y : ℤ} (hxy : ↑p ∣ x + y) (hx : ¬↑p ∣ x) {n : ℕ} (hn : Odd n) :
    multiplicity (↑p) (x ^ n + y ^ n) = multiplicity (↑p) (x + y) + multiplicity p n :=
  by
  rw [← sub_neg_eq_add] at hxy 
  rw [← sub_neg_eq_add, ← sub_neg_eq_add, ← Odd.neg_pow hn]
  exact int.pow_sub_pow hp hp1 hxy hx n
#align multiplicity.int.pow_add_pow multiplicity.Int.pow_add_pow
-/

#print multiplicity.Nat.pow_sub_pow /-
theorem Nat.pow_sub_pow {x y : ℕ} (hxy : p ∣ x - y) (hx : ¬p ∣ x) (n : ℕ) :
    multiplicity p (x ^ n - y ^ n) = multiplicity p (x - y) + multiplicity p n :=
  by
  obtain hyx | hyx := le_total y x
  · iterate 2 rw [← int.coe_nat_multiplicity]
    rw [Int.ofNat_sub (Nat.pow_le_pow_of_le_left hyx n)]
    rw [← Int.coe_nat_dvd] at hxy hx 
    push_cast at *
    exact int.pow_sub_pow hp hp1 hxy hx n
  ·
    simp only [nat.sub_eq_zero_iff_le.mpr hyx,
      nat.sub_eq_zero_iff_le.mpr (Nat.pow_le_pow_of_le_left hyx n), multiplicity.zero,
      PartENat.top_add]
#align multiplicity.nat.pow_sub_pow multiplicity.Nat.pow_sub_pow
-/

#print multiplicity.Nat.pow_add_pow /-
theorem Nat.pow_add_pow {x y : ℕ} (hxy : p ∣ x + y) (hx : ¬p ∣ x) {n : ℕ} (hn : Odd n) :
    multiplicity p (x ^ n + y ^ n) = multiplicity p (x + y) + multiplicity p n :=
  by
  iterate 2 rw [← int.coe_nat_multiplicity]
  rw [← Int.coe_nat_dvd] at hxy hx 
  push_cast at *
  exact int.pow_add_pow hp hp1 hxy hx hn
#align multiplicity.nat.pow_add_pow multiplicity.Nat.pow_add_pow
-/

end LiftingTheExponent

end multiplicity

end CommRing

#print pow_two_pow_sub_pow_two_pow /-
theorem pow_two_pow_sub_pow_two_pow [CommRing R] {x y : R} (n : ℕ) :
    x ^ 2 ^ n - y ^ 2 ^ n = (∏ i in Finset.range n, (x ^ 2 ^ i + y ^ 2 ^ i)) * (x - y) :=
  by
  induction' n with d hd
  · simp only [pow_zero, pow_one, Finset.range_zero, Finset.prod_empty, one_mul]
  · suffices x ^ 2 ^ d.succ - y ^ 2 ^ d.succ = (x ^ 2 ^ d + y ^ 2 ^ d) * (x ^ 2 ^ d - y ^ 2 ^ d) by
      rw [this, hd, Finset.prod_range_succ, ← mul_assoc, mul_comm (x ^ 2 ^ d + y ^ 2 ^ d)]
    · ring1
#align pow_two_pow_sub_pow_two_pow pow_two_pow_sub_pow_two_pow
-/

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Misc2.lean:80:4: warning: unsupported fin_cases 'using hy' clause -/
#print Int.sq_mod_four_eq_one_of_odd /-
theorem Int.sq_mod_four_eq_one_of_odd {x : ℤ} : Odd x → x ^ 2 % 4 = 1 :=
  by
  intro hx
  -- Replace `x : ℤ` with `y : zmod 4`
  replace hx : x % (2 : ℕ) = 1 % (2 : ℕ);
  · rw [Int.odd_iff] at hx ; norm_num [hx]
  calc
    x ^ 2 % (4 : ℕ) = 1 % (4 : ℕ) := _
    _ = 1 := by norm_num
  rw [← ZMod.int_cast_eq_int_cast_iff'] at hx ⊢
  push_cast
  rw [← map_intCast (ZMod.castHom (show 2 ∣ 4 by norm_num) (ZMod 2)) x] at hx 
  set y : ZMod 4 := x
  change ZMod.castHom _ (ZMod 2) y = _ at hx 
  -- Now we can just consider each of the 4 possible values for y
        fin_cases y <;>
        rw [hy] at hx ⊢ <;>
      revert hx <;>
    decide
#align int.sq_mod_four_eq_one_of_odd Int.sq_mod_four_eq_one_of_odd
-/

#print Int.two_pow_two_pow_add_two_pow_two_pow /-
theorem Int.two_pow_two_pow_add_two_pow_two_pow {x y : ℤ} (hx : ¬2 ∣ x) (hxy : 4 ∣ x - y) (i : ℕ) :
    multiplicity 2 (x ^ 2 ^ i + y ^ 2 ^ i) = ↑(1 : ℕ) :=
  by
  have hx_odd : Odd x := by rwa [Int.odd_iff_not_even, even_iff_two_dvd]
  have hxy_even : Even (x - y) := even_iff_two_dvd.mpr (dvd_trans (by norm_num) hxy)
  have hy_odd : Odd y := by simpa using hx_odd.sub_even hxy_even
  refine' multiplicity.eq_coe_iff.mpr ⟨_, _⟩
  · rw [pow_one, ← even_iff_two_dvd]
    exact hx_odd.pow.add_odd hy_odd.pow
  cases' i with i
  · intro hxy'
    have : 2 * 2 ∣ 2 * x := by convert dvd_add hxy hxy'; ring
    have : 2 ∣ x := (mul_dvd_mul_iff_left (by norm_num)).mp this
    contradiction
  suffices ∀ x : ℤ, Odd x → x ^ 2 ^ (i + 1) % 4 = 1
    by
    rw [show (2 ^ (1 + 1) : ℤ) = 4 by norm_num, Int.dvd_iff_emod_eq_zero, Int.add_emod,
      this _ hx_odd, this _ hy_odd]
    norm_num
  intro x hx
  rw [pow_succ, mul_comm, pow_mul, Int.sq_mod_four_eq_one_of_odd hx.pow]
#align int.two_pow_two_pow_add_two_pow_two_pow Int.two_pow_two_pow_add_two_pow_two_pow
-/

#print Int.two_pow_two_pow_sub_pow_two_pow /-
theorem Int.two_pow_two_pow_sub_pow_two_pow {x y : ℤ} (n : ℕ) (hxy : 4 ∣ x - y) (hx : ¬2 ∣ x) :
    multiplicity 2 (x ^ 2 ^ n - y ^ 2 ^ n) = multiplicity 2 (x - y) + n := by
  simp only [pow_two_pow_sub_pow_two_pow n, multiplicity.mul Int.prime_two,
    multiplicity.Finset.prod Int.prime_two, add_comm, Nat.cast_one, Finset.sum_const,
    Finset.card_range, nsmul_one, Int.two_pow_two_pow_add_two_pow_two_pow hx hxy]
#align int.two_pow_two_pow_sub_pow_two_pow Int.two_pow_two_pow_sub_pow_two_pow
-/

#print Int.two_pow_sub_pow' /-
theorem Int.two_pow_sub_pow' {x y : ℤ} (n : ℕ) (hxy : 4 ∣ x - y) (hx : ¬2 ∣ x) :
    multiplicity 2 (x ^ n - y ^ n) = multiplicity 2 (x - y) + multiplicity (2 : ℤ) n :=
  by
  have hx_odd : Odd x := by rwa [Int.odd_iff_not_even, even_iff_two_dvd]
  have hxy_even : Even (x - y) := even_iff_two_dvd.mpr (dvd_trans (by norm_num) hxy)
  have hy_odd : Odd y := by simpa using hx_odd.sub_even hxy_even
  cases n
  · simp only [pow_zero, sub_self, multiplicity.zero, Int.ofNat_zero, PartENat.add_top]
  have h : (multiplicity 2 n.succ).Dom := multiplicity.finite_nat_iff.mpr ⟨by norm_num, n.succ_pos⟩
  rcases multiplicity.eq_coe_iff.mp (PartENat.natCast_get h).symm with ⟨⟨k, hk⟩, hpn⟩
  rw [hk, pow_mul, pow_mul, multiplicity.pow_sub_pow_of_prime,
    Int.two_pow_two_pow_sub_pow_two_pow _ hxy hx, ← hk, PartENat.natCast_get]
  · norm_cast
  · exact Int.prime_two
  · simpa only [even_iff_two_dvd] using hx_odd.pow.sub_odd hy_odd.pow
  · simpa only [even_iff_two_dvd, Int.odd_iff_not_even] using hx_odd.pow
  erw [Int.coe_nat_dvd]
  -- `erw` to deal with `2 : ℤ` vs `(2 : ℕ) : ℤ`
  contrapose! hpn
  rw [pow_succ']
  conv_rhs => rw [hk]
  exact mul_dvd_mul_left _ hpn
#align int.two_pow_sub_pow' Int.two_pow_sub_pow'
-/

#print Int.two_pow_sub_pow /-
/-- **Lifting the exponent lemma** for `p = 2` -/
theorem Int.two_pow_sub_pow {x y : ℤ} {n : ℕ} (hxy : 2 ∣ x - y) (hx : ¬2 ∣ x) (hn : Even n) :
    multiplicity 2 (x ^ n - y ^ n) + 1 =
      multiplicity 2 (x + y) + multiplicity 2 (x - y) + multiplicity (2 : ℤ) n :=
  by
  have hy : Odd y := by
    rw [← even_iff_two_dvd, ← Int.odd_iff_not_even] at hx 
    replace hxy := (@even_neg _ _ (x - y)).mpr (even_iff_two_dvd.mpr hxy)
    convert Even.add_odd hxy hx
    abel
  cases' hn with d hd
  subst hd
  simp only [← two_mul, pow_mul]
  have hxy4 : 4 ∣ x ^ 2 - y ^ 2 :=
    by
    rw [Int.dvd_iff_emod_eq_zero, Int.sub_emod, Int.sq_mod_four_eq_one_of_odd _,
      Int.sq_mod_four_eq_one_of_odd hy]
    · norm_num
    · simp only [Int.odd_iff_not_even, even_iff_two_dvd, hx, not_false_iff]
  rw [Int.two_pow_sub_pow' d hxy4 _, sq_sub_sq, ← Int.ofNat_mul_out, multiplicity.mul Int.prime_two,
    multiplicity.mul Int.prime_two]
  suffices multiplicity (2 : ℤ) ↑(2 : ℕ) = 1 by rw [this, add_comm (1 : PartENat), ← add_assoc]
  · norm_cast
    rw [multiplicity.multiplicity_self _ _]
    · apply Prime.not_unit
      simp only [← Nat.prime_iff, Nat.prime_two]
    · exact two_ne_zero
  · rw [← even_iff_two_dvd, ← Int.odd_iff_not_even]
    apply Odd.pow
    simp only [Int.odd_iff_not_even, even_iff_two_dvd, hx, not_false_iff]
#align int.two_pow_sub_pow Int.two_pow_sub_pow
-/

#print Nat.two_pow_sub_pow /-
theorem Nat.two_pow_sub_pow {x y : ℕ} (hxy : 2 ∣ x - y) (hx : ¬2 ∣ x) {n : ℕ} (hn : Even n) :
    multiplicity 2 (x ^ n - y ^ n) + 1 =
      multiplicity 2 (x + y) + multiplicity 2 (x - y) + multiplicity 2 n :=
  by
  obtain hyx | hyx := le_total y x
  · iterate 3 rw [← multiplicity.Int.coe_nat_multiplicity]
    have hxyn : y ^ n ≤ x ^ n := pow_le_pow_of_le_left' hyx _
    simp only [Int.ofNat_sub hyx, Int.ofNat_sub (pow_le_pow_of_le_left' hyx _), Int.ofNat_add,
      Int.coe_nat_pow]
    rw [← Int.coe_nat_dvd] at hx 
    rw [← Int.coe_nat_dvd, Int.ofNat_sub hyx] at hxy 
    convert Int.two_pow_sub_pow hxy hx hn using 2
    rw [← multiplicity.Int.coe_nat_multiplicity]
    rfl
  ·
    simp only [nat.sub_eq_zero_iff_le.mpr hyx,
      nat.sub_eq_zero_iff_le.mpr (pow_le_pow_of_le_left' hyx n), multiplicity.zero,
      PartENat.top_add, PartENat.add_top]
#align nat.two_pow_sub_pow Nat.two_pow_sub_pow
-/

namespace padicValNat

variable {x y : ℕ}

#print padicValNat.pow_two_sub_pow /-
theorem pow_two_sub_pow (hyx : y < x) (hxy : 2 ∣ x - y) (hx : ¬2 ∣ x) {n : ℕ} (hn : 0 < n)
    (hneven : Even n) :
    padicValNat 2 (x ^ n - y ^ n) + 1 =
      padicValNat 2 (x + y) + padicValNat 2 (x - y) + padicValNat 2 n :=
  by
  simp only [← PartENat.natCast_inj, Nat.cast_add]
  iterate 4 rw [padicValNat_def, PartENat.natCast_get]
  · convert Nat.two_pow_sub_pow hxy hx hneven using 2
  · exact hn
  · exact Nat.sub_pos_of_lt hyx
  · linarith
  · simp only [tsub_pos_iff_lt, pow_lt_pow_of_lt_left hyx (@zero_le' _ y _) hn]
#align padic_val_nat.pow_two_sub_pow padicValNat.pow_two_sub_pow
-/

variable {p : ℕ} [hp : Fact p.Prime] (hp1 : Odd p)

#print padicValNat.pow_sub_pow /-
theorem pow_sub_pow (hyx : y < x) (hxy : p ∣ x - y) (hx : ¬p ∣ x) {n : ℕ} (hn : 0 < n) :
    padicValNat p (x ^ n - y ^ n) = padicValNat p (x - y) + padicValNat p n :=
  by
  rw [← PartENat.natCast_inj, Nat.cast_add]
  iterate 3 rw [padicValNat_def, PartENat.natCast_get]
  · exact multiplicity.Nat.pow_sub_pow hp.out hp1 hxy hx n
  · exact hn
  · exact Nat.sub_pos_of_lt hyx
  · exact Nat.sub_pos_of_lt (Nat.pow_lt_pow_of_lt_left hyx hn)
#align padic_val_nat.pow_sub_pow padicValNat.pow_sub_pow
-/

#print padicValNat.pow_add_pow /-
theorem pow_add_pow (hxy : p ∣ x + y) (hx : ¬p ∣ x) {n : ℕ} (hn : Odd n) :
    padicValNat p (x ^ n + y ^ n) = padicValNat p (x + y) + padicValNat p n :=
  by
  cases y
  · have := dvd_zero p; contradiction
  rw [← PartENat.natCast_inj, Nat.cast_add]
  iterate 3 rw [padicValNat_def, PartENat.natCast_get]
  · exact multiplicity.Nat.pow_add_pow hp.out hp1 hxy hx hn
  · exact Odd.pos hn
  · simp only [add_pos_iff, Nat.succ_pos', or_true_iff]
  · exact Nat.lt_add_left _ _ _ (pow_pos y.succ_pos _)
#align padic_val_nat.pow_add_pow padicValNat.pow_add_pow
-/

end padicValNat

