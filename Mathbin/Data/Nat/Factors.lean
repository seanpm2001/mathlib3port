/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Jeremy Avigad, Mario Carneiro

! This file was ported from Lean 3 source module data.nat.factors
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Prime
import Mathbin.Data.List.Prime
import Mathbin.Data.List.Sort
import Mathbin.Tactic.NthRewrite.Default

/-!
# Prime numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file deals with the factors of natural numbers.

## Important declarations

- `nat.factors n`: the prime factorization of `n`
- `nat.factors_unique`: uniqueness of the prime factorisation

-/


open Bool Subtype

open scoped Nat

namespace Nat

#print Nat.factors /-
/-- `factors n` is the prime factorization of `n`, listed in increasing order. -/
def factors : ℕ → List ℕ
  | 0 => []
  | 1 => []
  | n@(k + 2) =>
    let m := minFac n
    have : n / m < n := factors_lemma
    m :: factors (n / m)
#align nat.factors Nat.factors
-/

#print Nat.factors_zero /-
@[simp]
theorem factors_zero : factors 0 = [] := by rw [factors]
#align nat.factors_zero Nat.factors_zero
-/

#print Nat.factors_one /-
@[simp]
theorem factors_one : factors 1 = [] := by rw [factors]
#align nat.factors_one Nat.factors_one
-/

#print Nat.prime_of_mem_factors /-
theorem prime_of_mem_factors : ∀ {n p}, p ∈ factors n → Prime p
  | 0 => by simp
  | 1 => by simp
  | n@(k + 2) => fun p h =>
    let m := minFac n
    have : n / m < n := factors_lemma
    have h₁ : p = m ∨ p ∈ factors (n / m) := (List.mem_cons _ _ _).1 (by rwa [factors] at h )
    Or.cases_on h₁ (fun h₂ => h₂.symm ▸ minFac_prime (by decide)) prime_of_mem_factors
#align nat.prime_of_mem_factors Nat.prime_of_mem_factors
-/

#print Nat.pos_of_mem_factors /-
theorem pos_of_mem_factors {n p : ℕ} (h : p ∈ factors n) : 0 < p :=
  Prime.pos (prime_of_mem_factors h)
#align nat.pos_of_mem_factors Nat.pos_of_mem_factors
-/

#print Nat.prod_factors /-
theorem prod_factors : ∀ {n}, n ≠ 0 → List.prod (factors n) = n
  | 0 => by simp
  | 1 => by simp
  | n@(k + 2) => fun h =>
    let m := minFac n
    have : n / m < n := factors_lemma
    show (factors n).Prod = n
      by
      have h₁ : n / m ≠ 0 := fun h =>
        by
        have : n = 0 * m := (Nat.div_eq_iff_eq_mul_left (minFac_pos _) (minFac_dvd _)).1 h
        rw [MulZeroClass.zero_mul] at this  <;> exact (show k + 2 ≠ 0 by decide) this
      rw [factors, List.prod_cons, prod_factors h₁, Nat.mul_div_cancel' (min_fac_dvd _)]
#align nat.prod_factors Nat.prod_factors
-/

#print Nat.factors_prime /-
theorem factors_prime {p : ℕ} (hp : Nat.Prime p) : p.factors = [p] :=
  by
  have : p = p - 2 + 2 := (tsub_eq_iff_eq_add_of_le hp.two_le).mp rfl
  rw [this, Nat.factors]
  simp only [Eq.symm this]
  have : Nat.minFac p = p := (nat.prime_def_min_fac.mp hp).2
  constructor
  · exact this
  · simp only [this, Nat.factors, Nat.div_self (Nat.Prime.pos hp)]
#align nat.factors_prime Nat.factors_prime
-/

#print Nat.factors_chain /-
theorem factors_chain : ∀ {n a}, (∀ p, Prime p → p ∣ n → a ≤ p) → List.Chain (· ≤ ·) a (factors n)
  | 0 => fun a h => by simp
  | 1 => fun a h => by simp
  | n@(k + 2) => fun a h => by
    let m := minFac n
    have : n / m < n := factors_lemma
    rw [factors]
    refine' List.Chain.cons ((le_min_fac.2 h).resolve_left (by decide)) (factors_chain _)
    exact fun p pp d => min_fac_le_of_dvd pp.two_le (d.trans <| div_dvd_of_dvd <| min_fac_dvd _)
#align nat.factors_chain Nat.factors_chain
-/

#print Nat.factors_chain_2 /-
theorem factors_chain_2 (n) : List.Chain (· ≤ ·) 2 (factors n) :=
  factors_chain fun p pp _ => pp.two_le
#align nat.factors_chain_2 Nat.factors_chain_2
-/

#print Nat.factors_chain' /-
theorem factors_chain' (n) : List.Chain' (· ≤ ·) (factors n) :=
  @List.Chain'.tail _ _ (_ :: _) (factors_chain_2 _)
#align nat.factors_chain' Nat.factors_chain'
-/

#print Nat.factors_sorted /-
theorem factors_sorted (n : ℕ) : List.Sorted (· ≤ ·) (factors n) :=
  List.chain'_iff_pairwise.1 (factors_chain' _)
#align nat.factors_sorted Nat.factors_sorted
-/

#print Nat.factors_add_two /-
/-- `factors` can be constructed inductively by extracting `min_fac`, for sufficiently large `n`. -/
theorem factors_add_two (n : ℕ) :
    factors (n + 2) = minFac (n + 2) :: factors ((n + 2) / minFac (n + 2)) := by rw [factors]
#align nat.factors_add_two Nat.factors_add_two
-/

#print Nat.factors_eq_nil /-
@[simp]
theorem factors_eq_nil (n : ℕ) : n.factors = [] ↔ n = 0 ∨ n = 1 :=
  by
  constructor <;> intro h
  · rcases n with (_ | _ | n)
    · exact Or.inl rfl
    · exact Or.inr rfl
    · rw [factors] at h ; injection h
  · rcases h with (rfl | rfl)
    · exact factors_zero
    · exact factors_one
#align nat.factors_eq_nil Nat.factors_eq_nil
-/

#print Nat.eq_of_perm_factors /-
theorem eq_of_perm_factors {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) (h : a.factors ~ b.factors) :
    a = b := by simpa [prod_factors ha, prod_factors hb] using List.Perm.prod_eq h
#align nat.eq_of_perm_factors Nat.eq_of_perm_factors
-/

section

open List

#print Nat.mem_factors_iff_dvd /-
theorem mem_factors_iff_dvd {n p : ℕ} (hn : n ≠ 0) (hp : Prime p) : p ∈ factors n ↔ p ∣ n :=
  ⟨fun h => prod_factors hn ▸ List.dvd_prod h, fun h =>
    mem_list_primes_of_dvd_prod (prime_iff.mp hp) (fun p h => prime_iff.mp (prime_of_mem_factors h))
      ((prod_factors hn).symm ▸ h)⟩
#align nat.mem_factors_iff_dvd Nat.mem_factors_iff_dvd
-/

#print Nat.dvd_of_mem_factors /-
theorem dvd_of_mem_factors {n p : ℕ} (h : p ∈ n.factors) : p ∣ n :=
  by
  rcases n.eq_zero_or_pos with (rfl | hn)
  · exact dvd_zero p
  · rwa [← mem_factors_iff_dvd hn.ne' (prime_of_mem_factors h)]
#align nat.dvd_of_mem_factors Nat.dvd_of_mem_factors
-/

#print Nat.mem_factors /-
theorem mem_factors {n p} (hn : n ≠ 0) : p ∈ factors n ↔ Prime p ∧ p ∣ n :=
  ⟨fun h => ⟨prime_of_mem_factors h, dvd_of_mem_factors h⟩, fun ⟨hprime, hdvd⟩ =>
    (mem_factors_iff_dvd hn hprime).mpr hdvd⟩
#align nat.mem_factors Nat.mem_factors
-/

#print Nat.le_of_mem_factors /-
theorem le_of_mem_factors {n p : ℕ} (h : p ∈ n.factors) : p ≤ n :=
  by
  rcases n.eq_zero_or_pos with (rfl | hn)
  · rw [factors_zero] at h ; cases h
  · exact le_of_dvd hn (dvd_of_mem_factors h)
#align nat.le_of_mem_factors Nat.le_of_mem_factors
-/

#print Nat.factors_unique /-
/-- **Fundamental theorem of arithmetic**-/
theorem factors_unique {n : ℕ} {l : List ℕ} (h₁ : Prod l = n) (h₂ : ∀ p ∈ l, Prime p) :
    l ~ factors n := by
  refine' perm_of_prod_eq_prod _ _ _
  · rw [h₁]
    refine' (prod_factors _).symm
    rintro rfl
    rw [prod_eq_zero_iff] at h₁ 
    exact Prime.ne_zero (h₂ 0 h₁) rfl
  · simp_rw [← prime_iff]; exact h₂
  · simp_rw [← prime_iff]; exact fun p => prime_of_mem_factors
#align nat.factors_unique Nat.factors_unique
-/

#print Nat.Prime.factors_pow /-
theorem Prime.factors_pow {p : ℕ} (hp : p.Prime) (n : ℕ) : (p ^ n).factors = List.replicate n p :=
  by
  symm
  rw [← List.replicate_perm]
  apply Nat.factors_unique (List.prod_replicate n p)
  intro q hq
  rwa [eq_of_mem_replicate hq]
#align nat.prime.factors_pow Nat.Prime.factors_pow
-/

#print Nat.eq_prime_pow_of_unique_prime_dvd /-
theorem eq_prime_pow_of_unique_prime_dvd {n p : ℕ} (hpos : n ≠ 0)
    (h : ∀ {d}, Nat.Prime d → d ∣ n → d = p) : n = p ^ n.factors.length :=
  by
  set k := n.factors.length
  rw [← prod_factors hpos, ← prod_replicate k p,
    eq_replicate_of_mem fun d hd => h (prime_of_mem_factors hd) (dvd_of_mem_factors hd)]
#align nat.eq_prime_pow_of_unique_prime_dvd Nat.eq_prime_pow_of_unique_prime_dvd
-/

#print Nat.perm_factors_mul /-
/-- For positive `a` and `b`, the prime factors of `a * b` are the union of those of `a` and `b` -/
theorem perm_factors_mul {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) :
    (a * b).factors ~ a.factors ++ b.factors :=
  by
  refine' (factors_unique _ _).symm
  · rw [List.prod_append, prod_factors ha, prod_factors hb]
  · intro p hp
    rw [List.mem_append] at hp 
    cases hp <;> exact prime_of_mem_factors hp
#align nat.perm_factors_mul Nat.perm_factors_mul
-/

#print Nat.perm_factors_mul_of_coprime /-
/-- For coprime `a` and `b`, the prime factors of `a * b` are the union of those of `a` and `b` -/
theorem perm_factors_mul_of_coprime {a b : ℕ} (hab : coprime a b) :
    (a * b).factors ~ a.factors ++ b.factors :=
  by
  rcases a.eq_zero_or_pos with (rfl | ha)
  · simp [(coprime_zero_left _).mp hab]
  rcases b.eq_zero_or_pos with (rfl | hb)
  · simp [(coprime_zero_right _).mp hab]
  exact perm_factors_mul ha.ne' hb.ne'
#align nat.perm_factors_mul_of_coprime Nat.perm_factors_mul_of_coprime
-/

#print Nat.factors_sublist_right /-
theorem factors_sublist_right {n k : ℕ} (h : k ≠ 0) : n.factors <+ (n * k).factors :=
  by
  cases n
  · rw [MulZeroClass.zero_mul]
  apply sublist_of_subperm_of_sorted _ (factors_sorted _) (factors_sorted _)
  rw [(perm_factors_mul n.succ_ne_zero h).subperm_left]
  exact (sublist_append_left _ _).Subperm
#align nat.factors_sublist_right Nat.factors_sublist_right
-/

#print Nat.factors_sublist_of_dvd /-
theorem factors_sublist_of_dvd {n k : ℕ} (h : n ∣ k) (h' : k ≠ 0) : n.factors <+ k.factors :=
  by
  obtain ⟨a, rfl⟩ := h
  exact factors_sublist_right (right_ne_zero_of_mul h')
#align nat.factors_sublist_of_dvd Nat.factors_sublist_of_dvd
-/

#print Nat.factors_subset_right /-
theorem factors_subset_right {n k : ℕ} (h : k ≠ 0) : n.factors ⊆ (n * k).factors :=
  (factors_sublist_right h).Subset
#align nat.factors_subset_right Nat.factors_subset_right
-/

#print Nat.factors_subset_of_dvd /-
theorem factors_subset_of_dvd {n k : ℕ} (h : n ∣ k) (h' : k ≠ 0) : n.factors ⊆ k.factors :=
  (factors_sublist_of_dvd h h').Subset
#align nat.factors_subset_of_dvd Nat.factors_subset_of_dvd
-/

#print Nat.dvd_of_factors_subperm /-
theorem dvd_of_factors_subperm {a b : ℕ} (ha : a ≠ 0) (h : a.factors <+~ b.factors) : a ∣ b :=
  by
  rcases b.eq_zero_or_pos with (rfl | hb)
  · exact dvd_zero _
  rcases a with (_ | _ | a)
  · exact (ha rfl).elim
  · exact one_dvd _
  use (b.factors.diff a.succ.succ.factors).Prod
  nth_rw 1 [← Nat.prod_factors ha]
  rw [← List.prod_append,
    List.Perm.prod_eq <| List.subperm_append_diff_self_of_count_le <| list.subperm_ext_iff.mp h,
    Nat.prod_factors hb.ne']
#align nat.dvd_of_factors_subperm Nat.dvd_of_factors_subperm
-/

end

#print Nat.mem_factors_mul /-
theorem mem_factors_mul {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) {p : ℕ} :
    p ∈ (a * b).factors ↔ p ∈ a.factors ∨ p ∈ b.factors :=
  by
  rw [mem_factors (mul_ne_zero ha hb), mem_factors ha, mem_factors hb, ← and_or_left]
  simpa only [and_congr_right_iff] using prime.dvd_mul
#align nat.mem_factors_mul Nat.mem_factors_mul
-/

#print Nat.coprime_factors_disjoint /-
/-- The sets of factors of coprime `a` and `b` are disjoint -/
theorem coprime_factors_disjoint {a b : ℕ} (hab : a.coprime b) :
    List.Disjoint a.factors b.factors := by
  intro q hqa hqb
  apply not_prime_one
  rw [← eq_one_of_dvd_coprimes hab (dvd_of_mem_factors hqa) (dvd_of_mem_factors hqb)]
  exact prime_of_mem_factors hqa
#align nat.coprime_factors_disjoint Nat.coprime_factors_disjoint
-/

#print Nat.mem_factors_mul_of_coprime /-
theorem mem_factors_mul_of_coprime {a b : ℕ} (hab : coprime a b) (p : ℕ) :
    p ∈ (a * b).factors ↔ p ∈ a.factors ∪ b.factors :=
  by
  rcases a.eq_zero_or_pos with (rfl | ha)
  · simp [(coprime_zero_left _).mp hab]
  rcases b.eq_zero_or_pos with (rfl | hb)
  · simp [(coprime_zero_right _).mp hab]
  rw [mem_factors_mul ha.ne' hb.ne', List.mem_union]
#align nat.mem_factors_mul_of_coprime Nat.mem_factors_mul_of_coprime
-/

open List

#print Nat.mem_factors_mul_left /-
/-- If `p` is a prime factor of `a` then `p` is also a prime factor of `a * b` for any `b > 0` -/
theorem mem_factors_mul_left {p a b : ℕ} (hpa : p ∈ a.factors) (hb : b ≠ 0) : p ∈ (a * b).factors :=
  by
  rcases eq_or_ne a 0 with (rfl | ha)
  · simpa using hpa
  apply (mem_factors_mul ha hb).2 (Or.inl hpa)
#align nat.mem_factors_mul_left Nat.mem_factors_mul_left
-/

#print Nat.mem_factors_mul_right /-
/-- If `p` is a prime factor of `b` then `p` is also a prime factor of `a * b` for any `a > 0` -/
theorem mem_factors_mul_right {p a b : ℕ} (hpb : p ∈ b.factors) (ha : a ≠ 0) :
    p ∈ (a * b).factors := by rw [mul_comm]; exact mem_factors_mul_left hpb ha
#align nat.mem_factors_mul_right Nat.mem_factors_mul_right
-/

#print Nat.eq_two_pow_or_exists_odd_prime_and_dvd /-
theorem eq_two_pow_or_exists_odd_prime_and_dvd (n : ℕ) :
    (∃ k : ℕ, n = 2 ^ k) ∨ ∃ p, Nat.Prime p ∧ p ∣ n ∧ Odd p :=
  (eq_or_ne n 0).elim (fun hn => Or.inr ⟨3, prime_three, hn.symm ▸ dvd_zero 3, ⟨1, rfl⟩⟩) fun hn =>
    or_iff_not_imp_right.mpr fun H =>
      ⟨n.factors.length,
        eq_prime_pow_of_unique_prime_dvd hn fun p hprime hdvd =>
          hprime.eq_two_or_odd'.resolve_right fun hodd => H ⟨p, hprime, hdvd, hodd⟩⟩
#align nat.eq_two_pow_or_exists_odd_prime_and_dvd Nat.eq_two_pow_or_exists_odd_prime_and_dvd
-/

end Nat

assert_not_exists Multiset

