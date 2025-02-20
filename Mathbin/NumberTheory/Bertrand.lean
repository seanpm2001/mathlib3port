/-
Copyright (c) 2020 Patrick Stevens. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Stevens, Bolton Bailey

! This file was ported from Lean 3 source module number_theory.bertrand
! leanprover-community/mathlib commit 08b63ab58a6ec1157ebeafcbbe6c7a3fb3c9f6d5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Choose.Factorization
import Mathbin.Data.Nat.PrimeNormNum
import Mathbin.NumberTheory.Primorial
import Mathbin.Analysis.Convex.SpecificFunctions.Basic
import Mathbin.Analysis.Convex.SpecificFunctions.Deriv

/-!
# Bertrand's Postulate

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains a proof of Bertrand's postulate: That between any positive number and its
double there is a prime.

The proof follows the outline of the Erdős proof presented in "Proofs from THE BOOK": One considers
the prime factorization of `(2 * n).choose n`, and splits the constituent primes up into various
groups, then upper bounds the contribution of each group. This upper bounds the central binomial
coefficient, and if the postulate does not hold, this upper bound conflicts with a simple lower
bound for large enough `n`. This proves the result holds for large enough `n`, and for smaller `n`
an explicit list of primes is provided which covers the remaining cases.

As in the [Metamath implementation](carneiro2015arithmetic), we rely on some optimizations from
[Shigenori Tochiori](tochiori_bertrand). In particular we use the cleaner bound on the central
binomial coefficient given in `nat.four_pow_lt_mul_central_binom`.

## References

* [M. Aigner and G. M. Ziegler _Proofs from THE BOOK_][aigner1999proofs]
* [S. Tochiori, _Considering the Proof of “There is a Prime between n and 2n”_][tochiori_bertrand]
* [M. Carneiro, _Arithmetic in Metamath, Case Study: Bertrand's Postulate_][carneiro2015arithmetic]

## Tags

Bertrand, prime, binomial coefficients
-/


open scoped BigOperators

section Real

open Real

namespace Bertrand

#print Bertrand.real_main_inequality /-
/-- A reified version of the `bertrand.main_inequality` below.
This is not best possible: it actually holds for 464 ≤ x.
-/
theorem real_main_inequality {x : ℝ} (n_large : (512 : ℝ) ≤ x) :
    x * (2 * x) ^ sqrt (2 * x) * 4 ^ (2 * x / 3) ≤ 4 ^ x :=
  by
  let f : ℝ → ℝ := fun x => log x + sqrt (2 * x) * log (2 * x) - log 4 / 3 * x
  have hf' : ∀ x, 0 < x → 0 < x * (2 * x) ^ sqrt (2 * x) / 4 ^ (x / 3) := fun x h =>
    div_pos (mul_pos h (rpow_pos_of_pos (mul_pos two_pos h) _)) (rpow_pos_of_pos four_pos _)
  have hf : ∀ x, 0 < x → f x = log (x * (2 * x) ^ sqrt (2 * x) / 4 ^ (x / 3)) :=
    by
    intro x h5
    have h6 := mul_pos (zero_lt_two' ℝ) h5
    have h7 := rpow_pos_of_pos h6 (sqrt (2 * x))
    rw [log_div (mul_pos h5 h7).ne' (rpow_pos_of_pos four_pos _).ne', log_mul h5.ne' h7.ne',
      log_rpow h6, log_rpow zero_lt_four, ← mul_div_right_comm, ← mul_div, mul_comm x]
  have h5 : 0 < x := lt_of_lt_of_le (by norm_num1) n_large
  rw [← div_le_one (rpow_pos_of_pos four_pos x), ← div_div_eq_mul_div, ← rpow_sub four_pos, ←
    mul_div 2 x, mul_div_left_comm, ← mul_one_sub, (by norm_num1 : (1 : ℝ) - 2 / 3 = 1 / 3),
    mul_one_div, ← log_nonpos_iff (hf' x h5), ← hf x h5]
  have h : ConcaveOn ℝ (Set.Ioi 0.5) f := by
    refine'
        ((strict_concave_on_log_Ioi.concave_on.subset (Set.Ioi_subset_Ioi _) (convex_Ioi 0.5)).add
              ((strict_concave_on_sqrt_mul_log_Ioi.concave_on.comp_linear_map
                    ((2 : ℝ) • LinearMap.id)).Subset
                (fun a ha => lt_of_eq_of_lt _ ((mul_lt_mul_left two_pos).mpr ha))
                (convex_Ioi 0.5))).sub
          ((convexOn_id (convex_Ioi (0.5 : ℝ))).smul (div_nonneg (log_nonneg _) _)) <;>
      norm_num1
  suffices ∃ x1 x2, 0.5 < x1 ∧ x1 < x2 ∧ x2 ≤ x ∧ 0 ≤ f x1 ∧ f x2 ≤ 0
    by
    obtain ⟨x1, x2, h1, h2, h0, h3, h4⟩ := this
    exact (h.right_le_of_le_left'' h1 ((h1.trans h2).trans_le h0) h2 h0 (h4.trans h3)).trans h4
  refine' ⟨18, 512, by norm_num1, by norm_num1, le_trans (by norm_num1) n_large, _, _⟩
  · have : sqrt (2 * 18) = 6 := (sqrt_eq_iff_mul_self_eq_of_pos (by norm_num1)).mpr (by norm_num1)
    rw [hf, log_nonneg_iff (hf' 18 _), this] <;> norm_num1
  · have : sqrt (2 * 512) = 32 := (sqrt_eq_iff_mul_self_eq_of_pos (by norm_num1)).mpr (by norm_num1)
    rw [hf, log_nonpos_iff (hf' _ _), this, div_le_one (rpow_pos_of_pos four_pos _), ←
        rpow_le_rpow_iff _ (rpow_pos_of_pos four_pos _).le three_pos, ← rpow_mul] <;>
      norm_num1
#align bertrand.real_main_inequality Bertrand.real_main_inequality
-/

end Bertrand

end Real

section Nat

open Nat

#print bertrand_main_inequality /-
/-- The inequality which contradicts Bertrand's postulate, for large enough `n`.
-/
theorem bertrand_main_inequality {n : ℕ} (n_large : 512 ≤ n) :
    n * (2 * n) ^ sqrt (2 * n) * 4 ^ (2 * n / 3) ≤ 4 ^ n :=
  by
  rw [← @cast_le ℝ]
  simp only [cast_bit0, cast_add, cast_one, cast_mul, cast_pow, ← Real.rpow_nat_cast]
  have n_pos : 0 < n := (by decide : 0 < 512).trans_le n_large
  have n2_pos : 1 ≤ 2 * n := mul_pos (by decide) n_pos
  refine' trans (mul_le_mul _ _ _ _) (Bertrand.real_main_inequality (by exact_mod_cast n_large))
  · refine' mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg _)
    refine' Real.rpow_le_rpow_of_exponent_le (by exact_mod_cast n2_pos) _
    exact_mod_cast Real.nat_sqrt_le_real_sqrt
  · exact Real.rpow_le_rpow_of_exponent_le (by norm_num1) (cast_div_le.trans (by norm_cast))
  · exact Real.rpow_nonneg_of_nonneg (by norm_num1) _
  · refine' mul_nonneg (Nat.cast_nonneg _) _
    exact Real.rpow_nonneg_of_nonneg (mul_nonneg zero_le_two (Nat.cast_nonneg _)) _
#align bertrand_main_inequality bertrand_main_inequality
-/

#print centralBinom_factorization_small /-
/-- A lemma that tells us that, in the case where Bertrand's postulate does not hold, the prime
factorization of the central binomial coefficent only has factors at most `2 * n / 3 + 1`.
-/
theorem centralBinom_factorization_small (n : ℕ) (n_large : 2 < n)
    (no_prime : ¬∃ p : ℕ, p.Prime ∧ n < p ∧ p ≤ 2 * n) :
    centralBinom n = ∏ p in Finset.range (2 * n / 3 + 1), p ^ (centralBinom n).factorization p :=
  by
  refine' (Eq.trans _ n.prod_pow_factorization_central_binom).symm
  apply Finset.prod_subset
  · exact Finset.range_subset.2 (add_le_add_right (Nat.div_le_self _ _) _)
  intro x hx h2x
  rw [Finset.mem_range, lt_succ_iff] at hx h2x 
  rw [not_le, div_lt_iff_lt_mul' three_pos, mul_comm x] at h2x 
  replace no_prime := not_exists.mp no_prime x
  rw [← and_assoc', not_and', not_and_or, not_lt] at no_prime 
  cases' no_prime hx with h h
  · rw [factorization_eq_zero_of_non_prime n.central_binom h, pow_zero]
  · rw [factorization_central_binom_of_two_mul_self_lt_three_mul n_large h h2x, pow_zero]
#align central_binom_factorization_small centralBinom_factorization_small
-/

#print centralBinom_le_of_no_bertrand_prime /-
/-- An upper bound on the central binomial coefficient used in the proof of Bertrand's postulate.
The bound splits the prime factors of `central_binom n` into those
1. At most `sqrt (2 * n)`, which contribute at most `2 * n` for each such prime.
2. Between `sqrt (2 * n)` and `2 * n / 3`, which contribute at most `4^(2 * n / 3)` in total.
3. Between `2 * n / 3` and `n`, which do not exist.
4. Between `n` and `2 * n`, which would not exist in the case where Bertrand's postulate is false.
5. Above `2 * n`, which do not exist.
-/
theorem centralBinom_le_of_no_bertrand_prime (n : ℕ) (n_big : 2 < n)
    (no_prime : ¬∃ p : ℕ, Nat.Prime p ∧ n < p ∧ p ≤ 2 * n) :
    centralBinom n ≤ (2 * n) ^ sqrt (2 * n) * 4 ^ (2 * n / 3) :=
  by
  have n_pos : 0 < n := (Nat.zero_le _).trans_lt n_big
  have n2_pos : 1 ≤ 2 * n := mul_pos (zero_lt_two' ℕ) n_pos
  let S := (Finset.range (2 * n / 3 + 1)).filterₓ Nat.Prime
  let f x := x ^ n.central_binom.factorization x
  have : ∏ x : ℕ in S, f x = ∏ x : ℕ in Finset.range (2 * n / 3 + 1), f x :=
    by
    refine' Finset.prod_filter_of_ne fun p hp h => _
    contrapose! h; dsimp only [f]
    rw [factorization_eq_zero_of_non_prime n.central_binom h, pow_zero]
  rw [centralBinom_factorization_small n n_big no_prime, ← this, ←
    Finset.prod_filter_mul_prod_filter_not S (· ≤ sqrt (2 * n))]
  apply mul_le_mul'
  · refine' (Finset.prod_le_prod' fun p hp => (_ : f p ≤ 2 * n)).trans _
    · exact pow_factorization_choose_le (mul_pos two_pos n_pos)
    have : (Finset.Icc 1 (sqrt (2 * n))).card = sqrt (2 * n) := by rw [card_Icc, Nat.add_sub_cancel]
    rw [Finset.prod_const]
    refine' pow_le_pow n2_pos ((Finset.card_le_of_subset fun x hx => _).trans this.le)
    obtain ⟨h1, h2⟩ := Finset.mem_filter.1 hx
    exact finset.mem_Icc.mpr ⟨(Finset.mem_filter.1 h1).2.one_lt.le, h2⟩
  · refine' le_trans _ (primorial_le_4_pow (2 * n / 3))
    refine' (Finset.prod_le_prod' fun p hp => (_ : f p ≤ p)).trans _
    · obtain ⟨h1, h2⟩ := Finset.mem_filter.1 hp
      refine' (pow_le_pow (Finset.mem_filter.1 h1).2.one_lt.le _).trans (pow_one p).le
      exact Nat.factorization_choose_le_one (sqrt_lt'.mp <| not_le.1 h2)
    refine' Finset.prod_le_prod_of_subset_of_one_le' (Finset.filter_subset _ _) _
    exact fun p hp _ => (Finset.mem_filter.1 hp).2.one_lt.le
#align central_binom_le_of_no_bertrand_prime centralBinom_le_of_no_bertrand_prime
-/

namespace Nat

#print Nat.exists_prime_lt_and_le_two_mul_eventually /-
/-- Proves that Bertrand's postulate holds for all sufficiently large `n`.
-/
theorem exists_prime_lt_and_le_two_mul_eventually (n : ℕ) (n_big : 512 ≤ n) :
    ∃ p : ℕ, p.Prime ∧ n < p ∧ p ≤ 2 * n :=
  by
  -- Assume there is no prime in the range.
  by_contra no_prime
  -- Then we have the above sub-exponential bound on the size of this central binomial coefficient.
  -- We now couple this bound with an exponential lower bound on the central binomial coefficient,
  -- yielding an inequality which we have seen is false for large enough n.
  have H1 : n * (2 * n) ^ sqrt (2 * n) * 4 ^ (2 * n / 3) ≤ 4 ^ n := bertrand_main_inequality n_big
  have H2 : 4 ^ n < n * n.central_binom :=
    Nat.four_pow_lt_mul_centralBinom n (le_trans (by norm_num1) n_big)
  have H3 : n.central_binom ≤ (2 * n) ^ sqrt (2 * n) * 4 ^ (2 * n / 3) :=
    centralBinom_le_of_no_bertrand_prime n (lt_of_lt_of_le (by norm_num1) n_big) no_prime
  rw [mul_assoc] at H1 ; exact not_le.2 H2 ((mul_le_mul_left' H3 n).trans H1)
#align nat.exists_prime_lt_and_le_two_mul_eventually Nat.exists_prime_lt_and_le_two_mul_eventually
-/

#print Nat.exists_prime_lt_and_le_two_mul_succ /-
/-- Proves that Bertrand's postulate holds over all positive naturals less than n by identifying a
descending list of primes, each no more than twice the next, such that the list contains a witness
for each number ≤ n.
-/
theorem exists_prime_lt_and_le_two_mul_succ {n} (q) {p : ℕ} (prime_p : Nat.Prime p)
    (covering : p ≤ 2 * q) (H : n < q → ∃ p : ℕ, p.Prime ∧ n < p ∧ p ≤ 2 * n) (hn : n < p) :
    ∃ p : ℕ, p.Prime ∧ n < p ∧ p ≤ 2 * n :=
  by
  by_cases p ≤ 2 * n; · exact ⟨p, prime_p, hn, h⟩
  exact H (lt_of_mul_lt_mul_left' (lt_of_lt_of_le (not_le.1 h) covering))
#align nat.exists_prime_lt_and_le_two_mul_succ Nat.exists_prime_lt_and_le_two_mul_succ
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
#print Nat.exists_prime_lt_and_le_two_mul /-
/--
**Bertrand's Postulate**: For any positive natural number, there is a prime which is greater than
it, but no more than twice as large.
-/
theorem exists_prime_lt_and_le_two_mul (n : ℕ) (hn0 : n ≠ 0) :
    ∃ p, Nat.Prime p ∧ n < p ∧ p ≤ 2 * n :=
  by
  -- Split into cases whether `n` is large or small
  cases lt_or_le 511 n
  -- If `n` is large, apply the lemma derived from the inequalities on the central binomial
  -- coefficient.
  · exact exists_prime_lt_and_le_two_mul_eventually n h
  replace h : n < 521 := h.trans_lt (by norm_num1)
  revert h
  -- For small `n`, supply a list of primes to cover the initial cases.
  run_tac
    [317, 163, 83, 43, 23, 13, 7, 5, 3, 2].mapM' fun n => sorry
  exact fun h2 => ⟨2, prime_two, h2, Nat.mul_le_mul_left 2 (Nat.pos_of_ne_zero hn0)⟩
#align nat.exists_prime_lt_and_le_two_mul Nat.exists_prime_lt_and_le_two_mul
-/

alias Nat.exists_prime_lt_and_le_two_mul ← bertrand
#align nat.bertrand Nat.bertrand

end Nat

end Nat

