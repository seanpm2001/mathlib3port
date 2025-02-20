/-
Copyright (c) 2019 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Yury Kudryashov

! This file was ported from Lean 3 source module topology.algebra.infinite_sum.real
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Intervals
import Mathbin.Topology.Algebra.InfiniteSum.Order
import Mathbin.Topology.Instances.Real

/-!
# Infinite sum in the reals

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides lemmas about Cauchy sequences in terms of infinite sums.
-/


open Filter Finset

open scoped BigOperators NNReal Topology

variable {α : Type _}

#print cauchySeq_of_edist_le_of_summable /-
/-- If the extended distance between consecutive points of a sequence is estimated
by a summable series of `nnreal`s, then the original sequence is a Cauchy sequence. -/
theorem cauchySeq_of_edist_le_of_summable [PseudoEMetricSpace α] {f : ℕ → α} (d : ℕ → ℝ≥0)
    (hf : ∀ n, edist (f n) (f n.succ) ≤ d n) (hd : Summable d) : CauchySeq f :=
  by
  refine' EMetric.cauchySeq_iff_NNReal.2 fun ε εpos => _
  -- Actually we need partial sums of `d` to be a Cauchy sequence
  replace hd : CauchySeq fun n : ℕ => ∑ x in range n, d x :=
    let ⟨_, H⟩ := hd
    H.tendsto_sum_nat.cauchy_seq
  -- Now we take the same `N` as in one of the definitions of a Cauchy sequence
  refine' (Metric.cauchySeq_iff'.1 hd ε (NNReal.coe_pos.2 εpos)).imp fun N hN n hn => _
  have hsum := hN n hn
  -- We simplify the known inequality
  rw [dist_nndist, NNReal.nndist_eq, ← sum_range_add_sum_Ico _ hn, add_tsub_cancel_left] at hsum 
  norm_cast at hsum 
  replace hsum := lt_of_le_of_lt (le_max_left _ _) hsum
  rw [edist_comm]
  -- Then use `hf` to simplify the goal to the same form
  apply lt_of_le_of_lt (edist_le_Ico_sum_of_edist_le hn fun k _ _ => hf k)
  assumption_mod_cast
#align cauchy_seq_of_edist_le_of_summable cauchySeq_of_edist_le_of_summable
-/

variable [PseudoMetricSpace α] {f : ℕ → α} {a : α}

#print cauchySeq_of_dist_le_of_summable /-
/-- If the distance between consecutive points of a sequence is estimated by a summable series,
then the original sequence is a Cauchy sequence. -/
theorem cauchySeq_of_dist_le_of_summable (d : ℕ → ℝ) (hf : ∀ n, dist (f n) (f n.succ) ≤ d n)
    (hd : Summable d) : CauchySeq f :=
  by
  refine' Metric.cauchySeq_iff'.2 fun ε εpos => _
  replace hd : CauchySeq fun n : ℕ => ∑ x in range n, d x :=
    let ⟨_, H⟩ := hd
    H.tendsto_sum_nat.cauchy_seq
  refine' (Metric.cauchySeq_iff'.1 hd ε εpos).imp fun N hN n hn => _
  have hsum := hN n hn
  rw [Real.dist_eq, ← sum_Ico_eq_sub _ hn] at hsum 
  calc
    dist (f n) (f N) = dist (f N) (f n) := dist_comm _ _
    _ ≤ ∑ x in Ico N n, d x := (dist_le_Ico_sum_of_dist_le hn fun k _ _ => hf k)
    _ ≤ |∑ x in Ico N n, d x| := (le_abs_self _)
    _ < ε := hsum
#align cauchy_seq_of_dist_le_of_summable cauchySeq_of_dist_le_of_summable
-/

#print cauchySeq_of_summable_dist /-
theorem cauchySeq_of_summable_dist (h : Summable fun n => dist (f n) (f n.succ)) : CauchySeq f :=
  cauchySeq_of_dist_le_of_summable _ (fun _ => le_rfl) h
#align cauchy_seq_of_summable_dist cauchySeq_of_summable_dist
-/

#print dist_le_tsum_of_dist_le_of_tendsto /-
theorem dist_le_tsum_of_dist_le_of_tendsto (d : ℕ → ℝ) (hf : ∀ n, dist (f n) (f n.succ) ≤ d n)
    (hd : Summable d) {a : α} (ha : Tendsto f atTop (𝓝 a)) (n : ℕ) :
    dist (f n) a ≤ ∑' m, d (n + m) :=
  by
  refine' le_of_tendsto (tendsto_const_nhds.dist ha) (eventually_at_top.2 ⟨n, fun m hnm => _⟩)
  refine' le_trans (dist_le_Ico_sum_of_dist_le hnm fun k _ _ => hf k) _
  rw [sum_Ico_eq_sum_range]
  refine' sum_le_tsum (range _) (fun _ _ => le_trans dist_nonneg (hf _)) _
  exact hd.comp_injective (add_right_injective n)
#align dist_le_tsum_of_dist_le_of_tendsto dist_le_tsum_of_dist_le_of_tendsto
-/

#print dist_le_tsum_of_dist_le_of_tendsto₀ /-
theorem dist_le_tsum_of_dist_le_of_tendsto₀ (d : ℕ → ℝ) (hf : ∀ n, dist (f n) (f n.succ) ≤ d n)
    (hd : Summable d) (ha : Tendsto f atTop (𝓝 a)) : dist (f 0) a ≤ tsum d := by
  simpa only [zero_add] using dist_le_tsum_of_dist_le_of_tendsto d hf hd ha 0
#align dist_le_tsum_of_dist_le_of_tendsto₀ dist_le_tsum_of_dist_le_of_tendsto₀
-/

#print dist_le_tsum_dist_of_tendsto /-
theorem dist_le_tsum_dist_of_tendsto (h : Summable fun n => dist (f n) (f n.succ))
    (ha : Tendsto f atTop (𝓝 a)) (n) : dist (f n) a ≤ ∑' m, dist (f (n + m)) (f (n + m).succ) :=
  show dist (f n) a ≤ ∑' m, (fun x => dist (f x) (f x.succ)) (n + m) from
    dist_le_tsum_of_dist_le_of_tendsto (fun n => dist (f n) (f n.succ)) (fun _ => le_rfl) h ha n
#align dist_le_tsum_dist_of_tendsto dist_le_tsum_dist_of_tendsto
-/

#print dist_le_tsum_dist_of_tendsto₀ /-
theorem dist_le_tsum_dist_of_tendsto₀ (h : Summable fun n => dist (f n) (f n.succ))
    (ha : Tendsto f atTop (𝓝 a)) : dist (f 0) a ≤ ∑' n, dist (f n) (f n.succ) := by
  simpa only [zero_add] using dist_le_tsum_dist_of_tendsto h ha 0
#align dist_le_tsum_dist_of_tendsto₀ dist_le_tsum_dist_of_tendsto₀
-/

