/-
Copyright (c) 2021 Henry Swanson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Henry Swanson, Patrick Massot

! This file was ported from Lean 3 source module combinatorics.derangements.exponential
! leanprover-community/mathlib commit c20927220ef87bb4962ba08bf6da2ce3cf50a6dd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Exponential
import Mathbin.Combinatorics.Derangements.Finite
import Mathbin.Order.Filter.Basic

/-!
# Derangement exponential series

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves that the probability of a permutation on n elements being a derangement is 1/e.
The specific lemma is `num_derangements_tendsto_inv_e`.
-/


open Filter

open scoped BigOperators

open scoped Topology

#print numDerangements_tendsto_inv_e /-
theorem numDerangements_tendsto_inv_e :
    Tendsto (fun n => (numDerangements n : ℝ) / n.factorial) atTop (𝓝 (Real.exp (-1))) :=
  by
  -- we show that d(n)/n! is the partial sum of exp(-1), but offset by 1.
  -- this isn't entirely obvious, since we have to ensure that asc_factorial and
  -- factorial interact in the right way, e.g., that k ≤ n always
  let s : ℕ → ℝ := fun n => ∑ k in Finset.range n, (-1 : ℝ) ^ k / k.factorial
  suffices ∀ n : ℕ, (numDerangements n : ℝ) / n.factorial = s (n + 1)
    by
    simp_rw [this]
    -- shift the function by 1, and then use the fact that the partial sums
    -- converge to the infinite sum
    rw [tendsto_add_at_top_iff_nat 1]
    apply HasSum.tendsto_sum_nat
    -- there's no specific lemma for ℝ that ∑ x^k/k! sums to exp(x), but it's
    -- true in more general fields, so use that lemma
    rw [Real.exp_eq_exp_ℝ]
    exact expSeries_div_hasSum_exp ℝ (-1 : ℝ)
  intro n
  rw [← Int.cast_ofNat, numDerangements_sum]
  push_cast
  rw [Finset.sum_div]
  -- get down to individual terms
  refine' Finset.sum_congr (refl _) _
  intro k hk
  have h_le : k ≤ n := finset.mem_range_succ_iff.mp hk
  rw [Nat.ascFactorial_eq_div, add_tsub_cancel_of_le h_le]
  push_cast [Nat.factorial_dvd_factorial h_le]
  field_simp [Nat.factorial_ne_zero]
  ring
#align num_derangements_tendsto_inv_e numDerangements_tendsto_inv_e
-/

