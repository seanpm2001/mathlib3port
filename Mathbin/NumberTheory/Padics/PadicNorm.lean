/-
Copyright (c) 2018 Robert Y. Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Y. Lewis

! This file was ported from Lean 3 source module number_theory.padics.padic_norm
! leanprover-community/mathlib commit cb3ceec8485239a61ed51d944cb9a95b68c6bafc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.NumberTheory.Padics.PadicVal

/-!
# p-adic norm

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the `p`-adic norm on `ℚ`.

The `p`-adic valuation on `ℚ` is the difference of the multiplicities of `p` in the numerator and
denominator of `q`. This function obeys the standard properties of a valuation, with the appropriate
assumptions on `p`.

The valuation induces a norm on `ℚ`. This norm is a nonarchimedean absolute value.
It takes values in {0} ∪ {1/p^k | k ∈ ℤ}.

## Notations

This file uses the local notation `/.` for `rat.mk`.

## Implementation notes

Much, but not all, of this file assumes that `p` is prime. This assumption is inferred automatically
by taking `[fact p.prime]` as a type class argument.

## References

* [F. Q. Gouvêa, *p-adic numbers*][gouvea1997]
* [R. Y. Lewis, *A formal proof of Hensel's lemma over the p-adic integers*][lewis2019]
* <https://en.wikipedia.org/wiki/P-adic_number>

## Tags

p-adic, p adic, padic, norm, valuation
-/


#print padicNorm /-
/-- If `q ≠ 0`, the `p`-adic norm of a rational `q` is `p ^ -padic_val_rat p q`.
If `q = 0`, the `p`-adic norm of `q` is `0`. -/
def padicNorm (p : ℕ) (q : ℚ) : ℚ :=
  if q = 0 then 0 else (p : ℚ) ^ (-padicValRat p q)
#align padic_norm padicNorm
-/

namespace padicNorm

open padicValRat

variable {p : ℕ}

#print padicNorm.eq_zpow_of_nonzero /-
/-- Unfolds the definition of the `p`-adic norm of `q` when `q ≠ 0`. -/
@[simp]
protected theorem eq_zpow_of_nonzero {q : ℚ} (hq : q ≠ 0) :
    padicNorm p q = p ^ (-padicValRat p q) := by simp [hq, padicNorm]
#align padic_norm.eq_zpow_of_nonzero padicNorm.eq_zpow_of_nonzero
-/

#print padicNorm.nonneg /-
/-- The `p`-adic norm is nonnegative. -/
protected theorem nonneg (q : ℚ) : 0 ≤ padicNorm p q :=
  if hq : q = 0 then by simp [hq, padicNorm]
  else by
    unfold padicNorm <;> split_ifs
    apply zpow_nonneg
    exact_mod_cast Nat.zero_le _
#align padic_norm.nonneg padicNorm.nonneg
-/

#print padicNorm.zero /-
/-- The `p`-adic norm of `0` is `0`. -/
@[simp]
protected theorem zero : padicNorm p 0 = 0 := by simp [padicNorm]
#align padic_norm.zero padicNorm.zero
-/

#print padicNorm.one /-
/-- The `p`-adic norm of `1` is `1`. -/
@[simp]
protected theorem one : padicNorm p 1 = 1 := by simp [padicNorm]
#align padic_norm.one padicNorm.one
-/

#print padicNorm.padicNorm_p /-
/-- The `p`-adic norm of `p` is `p⁻¹` if `p > 1`.

See also `padic_norm.padic_norm_p_of_prime` for a version assuming `p` is prime. -/
theorem padicNorm_p (hp : 1 < p) : padicNorm p p = p⁻¹ := by
  simp [padicNorm, (pos_of_gt hp).ne', padicValNat.self hp]
#align padic_norm.padic_norm_p padicNorm.padicNorm_p
-/

#print padicNorm.padicNorm_p_of_prime /-
/-- The `p`-adic norm of `p` is `p⁻¹` if `p` is prime.

See also `padic_norm.padic_norm_p` for a version assuming `1 < p`. -/
@[simp]
theorem padicNorm_p_of_prime [Fact p.Prime] : padicNorm p p = p⁻¹ :=
  padicNorm_p <| Nat.Prime.one_lt (Fact.out _)
#align padic_norm.padic_norm_p_of_prime padicNorm.padicNorm_p_of_prime
-/

#print padicNorm.padicNorm_of_prime_of_ne /-
/-- The `p`-adic norm of `q` is `1` if `q` is prime and not equal to `p`. -/
theorem padicNorm_of_prime_of_ne {q : ℕ} [p_prime : Fact p.Prime] [q_prime : Fact q.Prime]
    (neq : p ≠ q) : padicNorm p q = 1 :=
  by
  have p : padicValRat p q = 0 := by exact_mod_cast @padicValNat_primes p q p_prime q_prime neq
  simp [padicNorm, p, q_prime.1.1, q_prime.1.NeZero]
#align padic_norm.padic_norm_of_prime_of_ne padicNorm.padicNorm_of_prime_of_ne
-/

#print padicNorm.padicNorm_p_lt_one /-
/-- The `p`-adic norm of `p` is less than `1` if `1 < p`.

See also `padic_norm.padic_norm_p_lt_one_of_prime` for a version assuming `p` is prime. -/
theorem padicNorm_p_lt_one (hp : 1 < p) : padicNorm p p < 1 :=
  by
  rw [padic_norm_p hp, inv_lt_one_iff]
  exact_mod_cast Or.inr hp
#align padic_norm.padic_norm_p_lt_one padicNorm.padicNorm_p_lt_one
-/

#print padicNorm.padicNorm_p_lt_one_of_prime /-
/-- The `p`-adic norm of `p` is less than `1` if `p` is prime.

See also `padic_norm.padic_norm_p_lt_one` for a version assuming `1 < p`. -/
theorem padicNorm_p_lt_one_of_prime [Fact p.Prime] : padicNorm p p < 1 :=
  padicNorm_p_lt_one <| Nat.Prime.one_lt (Fact.out _)
#align padic_norm.padic_norm_p_lt_one_of_prime padicNorm.padicNorm_p_lt_one_of_prime
-/

#print padicNorm.values_discrete /-
/-- `padic_norm p q` takes discrete values `p ^ -z` for `z : ℤ`. -/
protected theorem values_discrete {q : ℚ} (hq : q ≠ 0) : ∃ z : ℤ, padicNorm p q = p ^ (-z) :=
  ⟨padicValRat p q, by simp [padicNorm, hq]⟩
#align padic_norm.values_discrete padicNorm.values_discrete
-/

#print padicNorm.neg /-
/-- `padic_norm p` is symmetric. -/
@[simp]
protected theorem neg (q : ℚ) : padicNorm p (-q) = padicNorm p q :=
  if hq : q = 0 then by simp [hq] else by simp [padicNorm, hq]
#align padic_norm.neg padicNorm.neg
-/

variable [hp : Fact p.Prime]

#print padicNorm.nonzero /-
/-- If `q ≠ 0`, then `padic_norm p q ≠ 0`. -/
protected theorem nonzero {q : ℚ} (hq : q ≠ 0) : padicNorm p q ≠ 0 :=
  by
  rw [padicNorm.eq_zpow_of_nonzero hq]
  apply zpow_ne_zero_of_ne_zero
  exact_mod_cast ne_of_gt hp.1.Pos
#align padic_norm.nonzero padicNorm.nonzero
-/

#print padicNorm.zero_of_padicNorm_eq_zero /-
/-- If the `p`-adic norm of `q` is 0, then `q` is `0`. -/
theorem zero_of_padicNorm_eq_zero {q : ℚ} (h : padicNorm p q = 0) : q = 0 :=
  by
  apply by_contradiction; intro hq
  unfold padicNorm at h ; rw [if_neg hq] at h 
  apply absurd h
  apply zpow_ne_zero_of_ne_zero
  exact_mod_cast hp.1.NeZero
#align padic_norm.zero_of_padic_norm_eq_zero padicNorm.zero_of_padicNorm_eq_zero
-/

#print padicNorm.mul /-
/-- The `p`-adic norm is multiplicative. -/
@[simp]
protected theorem mul (q r : ℚ) : padicNorm p (q * r) = padicNorm p q * padicNorm p r :=
  if hq : q = 0 then by simp [hq]
  else
    if hr : r = 0 then by simp [hr]
    else by
      have : q * r ≠ 0 := mul_ne_zero hq hr
      have : (p : ℚ) ≠ 0 := by simp [hp.1.NeZero]
      simp [padicNorm, *, padicValRat.mul, zpow_add₀ this, mul_comm]
#align padic_norm.mul padicNorm.mul
-/

#print padicNorm.div /-
/-- The `p`-adic norm respects division. -/
@[simp]
protected theorem div (q r : ℚ) : padicNorm p (q / r) = padicNorm p q / padicNorm p r :=
  if hr : r = 0 then by simp [hr]
  else eq_div_of_mul_eq (padicNorm.nonzero hr) (by rw [← padicNorm.mul, div_mul_cancel _ hr])
#align padic_norm.div padicNorm.div
-/

#print padicNorm.of_int /-
/-- The `p`-adic norm of an integer is at most `1`. -/
protected theorem of_int (z : ℤ) : padicNorm p z ≤ 1 :=
  if hz : z = 0 then by simp [hz, zero_le_one]
  else by
    unfold padicNorm
    rw [if_neg _]
    · refine' zpow_le_one_of_nonpos _ _
      · exact_mod_cast le_of_lt hp.1.one_lt
      · rw [padicValRat.of_int, neg_nonpos]
        norm_cast; simp
    exact_mod_cast hz
#align padic_norm.of_int padicNorm.of_int
-/

private theorem nonarchimedean_aux {q r : ℚ} (h : padicValRat p q ≤ padicValRat p r) :
    padicNorm p (q + r) ≤ max (padicNorm p q) (padicNorm p r) :=
  have hnqp : padicNorm p q ≥ 0 := padicNorm.nonneg _
  have hnrp : padicNorm p r ≥ 0 := padicNorm.nonneg _
  if hq : q = 0 then by simp [hq, max_eq_right hnrp, le_max_right]
  else
    if hr : r = 0 then by simp [hr, max_eq_left hnqp, le_max_left]
    else
      if hqr : q + r = 0 then le_trans (by simpa [hqr] using hnqp) (le_max_left _ _)
      else by
        unfold padicNorm; split_ifs
        apply le_max_iff.2
        left
        apply zpow_le_of_le
        · exact_mod_cast le_of_lt hp.1.one_lt
        · apply neg_le_neg
          have : padicValRat p q = min (padicValRat p q) (padicValRat p r) := (min_eq_left h).symm
          rw [this]
          apply min_le_padic_val_rat_add <;> assumption

#print padicNorm.nonarchimedean /-
/-- The `p`-adic norm is nonarchimedean: the norm of `p + q` is at most the max of the norm of `p`
and the norm of `q`. -/
protected theorem nonarchimedean {q r : ℚ} :
    padicNorm p (q + r) ≤ max (padicNorm p q) (padicNorm p r) :=
  by
  wlog hle : padicValRat p q ≤ padicValRat p r generalizing q r
  · rw [add_comm, max_comm]; exact this (le_of_not_le hle)
  exact nonarchimedean_aux hle
#align padic_norm.nonarchimedean padicNorm.nonarchimedean
-/

#print padicNorm.triangle_ineq /-
/-- The `p`-adic norm respects the triangle inequality: the norm of `p + q` is at most the norm of
`p` plus the norm of `q`. -/
theorem triangle_ineq (q r : ℚ) : padicNorm p (q + r) ≤ padicNorm p q + padicNorm p r :=
  calc
    padicNorm p (q + r) ≤ max (padicNorm p q) (padicNorm p r) := padicNorm.nonarchimedean
    _ ≤ padicNorm p q + padicNorm p r :=
      max_le_add_of_nonneg (padicNorm.nonneg _) (padicNorm.nonneg _)
#align padic_norm.triangle_ineq padicNorm.triangle_ineq
-/

#print padicNorm.sub /-
/-- The `p`-adic norm of a difference is at most the max of each component. Restates the archimedean
property of the `p`-adic norm. -/
protected theorem sub {q r : ℚ} : padicNorm p (q - r) ≤ max (padicNorm p q) (padicNorm p r) := by
  rw [sub_eq_add_neg, ← padicNorm.neg r] <;> apply padicNorm.nonarchimedean
#align padic_norm.sub padicNorm.sub
-/

#print padicNorm.add_eq_max_of_ne /-
/-- If the `p`-adic norms of `q` and `r` are different, then the norm of `q + r` is equal to the max
of the norms of `q` and `r`. -/
theorem add_eq_max_of_ne {q r : ℚ} (hne : padicNorm p q ≠ padicNorm p r) :
    padicNorm p (q + r) = max (padicNorm p q) (padicNorm p r) :=
  by
  wlog hlt : padicNorm p r < padicNorm p q
  · rw [add_comm, max_comm]; exact this hne.symm (hne.lt_or_lt.resolve_right hlt)
  have : padicNorm p q ≤ max (padicNorm p (q + r)) (padicNorm p r) :=
    calc
      padicNorm p q = padicNorm p (q + r - r) := by congr <;> ring
      _ ≤ max (padicNorm p (q + r)) (padicNorm p (-r)) := padicNorm.nonarchimedean
      _ = max (padicNorm p (q + r)) (padicNorm p r) := by simp
  have hnge : padicNorm p r ≤ padicNorm p (q + r) :=
    by
    apply le_of_not_gt
    intro hgt
    rw [max_eq_right_of_lt hgt] at this 
    apply not_lt_of_ge this
    assumption
  have : padicNorm p q ≤ padicNorm p (q + r) := by rwa [max_eq_left hnge] at this 
  apply _root_.le_antisymm
  · apply padicNorm.nonarchimedean
  · rwa [max_eq_left_of_lt hlt]
#align padic_norm.add_eq_max_of_ne padicNorm.add_eq_max_of_ne
-/

/-- The `p`-adic norm is an absolute value: positive-definite and multiplicative, satisfying the
triangle inequality. -/
instance : IsAbsoluteValue (padicNorm p)
    where
  abv_nonneg := padicNorm.nonneg
  abv_eq_zero _ := ⟨zero_of_padicNorm_eq_zero, fun hx => by simpa only [hx]⟩
  abv_add := padicNorm.triangle_ineq
  abv_mul := padicNorm.mul

#print padicNorm.dvd_iff_norm_le /-
theorem dvd_iff_norm_le {n : ℕ} {z : ℤ} : ↑(p ^ n) ∣ z ↔ padicNorm p z ≤ p ^ (-n : ℤ) :=
  by
  unfold padicNorm; split_ifs with hz
  · norm_cast at hz 
    have : 0 ≤ (p ^ n : ℚ) := by apply pow_nonneg; exact_mod_cast le_of_lt hp.1.Pos
    simp [hz, this]
  · rw [zpow_le_iff_le, neg_le_neg_iff, padicValRat.of_int,
      padicValInt.of_ne_one_ne_zero hp.1.ne_one _]
    · norm_cast
      rw [← PartENat.coe_le_coe, PartENat.natCast_get, ← multiplicity.pow_dvd_iff_le_multiplicity]
      simp
    · exact_mod_cast hz
    · exact_mod_cast hp.1.one_lt
#align padic_norm.dvd_iff_norm_le padicNorm.dvd_iff_norm_le
-/

#print padicNorm.int_eq_one_iff /-
/-- The `p`-adic norm of an integer `m` is one iff `p` doesn't divide `m`. -/
theorem int_eq_one_iff (m : ℤ) : padicNorm p m = 1 ↔ ¬(p : ℤ) ∣ m :=
  by
  nth_rw 2 [← pow_one p]
  simp only [dvd_iff_norm_le, Int.cast_ofNat, Nat.cast_one, zpow_neg, zpow_one, not_le]
  constructor
  · intro h
    rw [h, inv_lt_one_iff_of_pos] <;> norm_cast
    · exact Nat.Prime.one_lt (Fact.out _)
    · exact Nat.Prime.pos (Fact.out _)
  · simp only [padicNorm]
    split_ifs
    · rw [inv_lt_zero, ← Nat.cast_zero, Nat.cast_lt]
      intro h; exact (Nat.not_lt_zero p h).elim
    · have : 1 < (p : ℚ) := by norm_cast <;> exact Nat.Prime.one_lt (Fact.out _ : Nat.Prime p)
      rw [← zpow_neg_one, zpow_lt_iff_lt this]
      have : 0 ≤ padicValRat p m; simp only [of_int, Nat.cast_nonneg]
      intro h
      rw [← zpow_zero (p : ℚ), zpow_inj] <;> linarith
#align padic_norm.int_eq_one_iff padicNorm.int_eq_one_iff
-/

#print padicNorm.int_lt_one_iff /-
theorem int_lt_one_iff (m : ℤ) : padicNorm p m < 1 ↔ (p : ℤ) ∣ m :=
  by
  rw [← not_iff_not, ← int_eq_one_iff, eq_iff_le_not_lt]
  simp only [padicNorm.of_int, true_and_iff]
#align padic_norm.int_lt_one_iff padicNorm.int_lt_one_iff
-/

#print padicNorm.of_nat /-
theorem of_nat (m : ℕ) : padicNorm p m ≤ 1 :=
  padicNorm.of_int (m : ℤ)
#align padic_norm.of_nat padicNorm.of_nat
-/

#print padicNorm.nat_eq_one_iff /-
/-- The `p`-adic norm of a natural `m` is one iff `p` doesn't divide `m`. -/
theorem nat_eq_one_iff (m : ℕ) : padicNorm p m = 1 ↔ ¬p ∣ m := by
  simp only [← Int.coe_nat_dvd, ← int_eq_one_iff, Int.cast_ofNat]
#align padic_norm.nat_eq_one_iff padicNorm.nat_eq_one_iff
-/

#print padicNorm.nat_lt_one_iff /-
theorem nat_lt_one_iff (m : ℕ) : padicNorm p m < 1 ↔ p ∣ m := by
  simp only [← Int.coe_nat_dvd, ← int_lt_one_iff, Int.cast_ofNat]
#align padic_norm.nat_lt_one_iff padicNorm.nat_lt_one_iff
-/

open scoped BigOperators

#print padicNorm.sum_lt /-
theorem sum_lt {α : Type _} {F : α → ℚ} {t : ℚ} {s : Finset α} :
    s.Nonempty → (∀ i ∈ s, padicNorm p (F i) < t) → padicNorm p (∑ i in s, F i) < t := by
  classical
  refine' s.induction_on (by rintro ⟨-, ⟨⟩⟩) _
  rintro a S haS IH - ht
  by_cases hs : S.nonempty
  · rw [Finset.sum_insert haS]
    exact
      lt_of_le_of_lt padicNorm.nonarchimedean
        (max_lt (ht a (Finset.mem_insert_self a S))
          (IH hs fun b hb => ht b (Finset.mem_insert_of_mem hb)))
  · simp_all
#align padic_norm.sum_lt padicNorm.sum_lt
-/

#print padicNorm.sum_le /-
theorem sum_le {α : Type _} {F : α → ℚ} {t : ℚ} {s : Finset α} :
    s.Nonempty → (∀ i ∈ s, padicNorm p (F i) ≤ t) → padicNorm p (∑ i in s, F i) ≤ t := by
  classical
  refine' s.induction_on (by rintro ⟨-, ⟨⟩⟩) _
  rintro a S haS IH - ht
  by_cases hs : S.nonempty
  · rw [Finset.sum_insert haS]
    exact
      padic_norm.nonarchimedean.trans
        (max_le (ht a (Finset.mem_insert_self a S))
          (IH hs fun b hb => ht b (Finset.mem_insert_of_mem hb)))
  · simp_all
#align padic_norm.sum_le padicNorm.sum_le
-/

#print padicNorm.sum_lt' /-
theorem sum_lt' {α : Type _} {F : α → ℚ} {t : ℚ} {s : Finset α}
    (hF : ∀ i ∈ s, padicNorm p (F i) < t) (ht : 0 < t) : padicNorm p (∑ i in s, F i) < t :=
  by
  obtain rfl | hs := Finset.eq_empty_or_nonempty s
  · simp [ht]
  · exact sum_lt hs hF
#align padic_norm.sum_lt' padicNorm.sum_lt'
-/

#print padicNorm.sum_le' /-
theorem sum_le' {α : Type _} {F : α → ℚ} {t : ℚ} {s : Finset α}
    (hF : ∀ i ∈ s, padicNorm p (F i) ≤ t) (ht : 0 ≤ t) : padicNorm p (∑ i in s, F i) ≤ t :=
  by
  obtain rfl | hs := Finset.eq_empty_or_nonempty s
  · simp [ht]
  · exact sum_le hs hF
#align padic_norm.sum_le' padicNorm.sum_le'
-/

end padicNorm

