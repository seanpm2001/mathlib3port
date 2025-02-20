/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.convex.measure
! leanprover-community/mathlib commit fd4551cfe4b7484b81c2c9ba3405edae27659676
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Topology
import Mathbin.Analysis.NormedSpace.AddTorsorBases
import Mathbin.MeasureTheory.Measure.Lebesgue.EqHaar

/-!
# Convex sets are null-measurable

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Let `E` be a finite dimensional real vector space, let `μ` be a Haar measure on `E`, let `s` be a
convex set in `E`. Then the frontier of `s` has measure zero (see `convex.add_haar_frontier`), hence
`s` is a `measure_theory.null_measurable_set` (see `convex.null_measurable_set`).
-/


open MeasureTheory MeasureTheory.Measure Set Metric Filter

open FiniteDimensional (finrank)

open scoped Topology NNReal ENNReal

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E] [MeasurableSpace E] [BorelSpace E]
  [FiniteDimensional ℝ E] (μ : Measure E) [IsAddHaarMeasure μ] {s : Set E}

namespace Convex

#print Convex.add_haar_frontier /-
/-- Haar measure of the frontier of a convex set is zero. -/
theorem add_haar_frontier (hs : Convex ℝ s) : μ (frontier s) = 0 :=
  by
  /- If `s` is included in a hyperplane, then `frontier s ⊆ closure s` is included in the same
    hyperplane, hence it has measure zero. -/
  cases' ne_or_eq (affineSpan ℝ s) ⊤ with hspan hspan
  · refine' measure_mono_null _ (add_haar_affine_subspace _ _ hspan)
    exact
      frontier_subset_closure.trans
        (closure_minimal (subset_affineSpan _ _) (affineSpan ℝ s).closed_of_finiteDimensional)
  rw [← hs.interior_nonempty_iff_affine_span_eq_top] at hspan 
  rcases hspan with ⟨x, hx⟩
  /- Without loss of generality, `s` is bounded. Indeed, `∂s ⊆ ⋃ n, ∂(s ∩ ball x (n + 1))`, hence it
    suffices to prove that `∀ n, μ (s ∩ ball x (n + 1)) = 0`; the latter set is bounded.
    -/
  suffices H : ∀ t : Set E, Convex ℝ t → x ∈ interior t → bounded t → μ (frontier t) = 0
  · set B : ℕ → Set E := fun n => ball x (n + 1)
    have : μ (⋃ n : ℕ, frontier (s ∩ B n)) = 0 :=
      by
      refine'
        measure_Union_null fun n =>
          H _ (hs.inter (convex_ball _ _)) _ (bounded_ball.mono (inter_subset_right _ _))
      rw [interior_inter, is_open_ball.interior_eq]
      exact ⟨hx, mem_ball_self (add_pos_of_nonneg_of_pos n.cast_nonneg zero_lt_one)⟩
    refine' measure_mono_null (fun y hy => _) this; clear this
    set N : ℕ := ⌊dist y x⌋₊
    refine' mem_Union.2 ⟨N, _⟩
    have hN : y ∈ B N := by simp only [B, N]; simp [Nat.lt_floor_add_one]
    suffices : y ∈ frontier (s ∩ B N) ∩ B N; exact this.1
    rw [frontier_inter_open_inter is_open_ball]
    exact ⟨hy, hN⟩
  clear hx hs s; intro s hs hx hb
  /- Since `s` is bounded, we have `μ (interior s) ≠ ∞`, hence it suffices to prove
    `μ (closure s) ≤ μ (interior s)`. -/
  replace hb : μ (interior s) ≠ ∞;
  exact (hb.mono interior_subset).measure_lt_top.Ne
  suffices μ (closure s) ≤ μ (interior s) by
    rwa [frontier, measure_diff interior_subset_closure is_open_interior.measurable_set hb,
      tsub_eq_zero_iff_le]
  /- Due to `convex.closure_subset_image_homothety_interior_of_one_lt`, for any `r > 1` we have
    `closure s ⊆ homothety x r '' interior s`, hence `μ (closure s) ≤ r ^ d * μ (interior s)`,
    where `d = finrank ℝ E`. -/
  set d : ℕ := FiniteDimensional.finrank ℝ E
  have : ∀ r : ℝ≥0, 1 < r → μ (closure s) ≤ ↑(r ^ d) * μ (interior s) :=
    by
    intro r hr
    refine'
      (measure_mono <| hs.closure_subset_image_homothety_interior_of_one_lt hx r hr).trans_eq _
    rw [add_haar_image_homothety, ← NNReal.coe_pow, NNReal.abs_eq, ENNReal.ofReal_coe_nnreal]
  have : ∀ᶠ r in 𝓝[>] (1 : ℝ≥0), μ (closure s) ≤ ↑(r ^ d) * μ (interior s) :=
    mem_of_superset self_mem_nhdsWithin this
  -- Taking the limit as `r → 1`, we get `μ (closure s) ≤ μ (interior s)`.
  refine' ge_of_tendsto _ this
  refine'
    (((ENNReal.continuous_mul_const hb).comp
              (ennreal.continuous_coe.comp (continuous_pow d))).tendsto'
          _ _ _).mono_left
      nhdsWithin_le_nhds
  simp
#align convex.add_haar_frontier Convex.add_haar_frontier
-/

#print Convex.nullMeasurableSet /-
/-- A convex set in a finite dimensional real vector space is null measurable with respect to an
additive Haar measure on this space. -/
protected theorem nullMeasurableSet (hs : Convex ℝ s) : NullMeasurableSet s μ :=
  nullMeasurableSet_of_null_frontier (hs.add_haar_frontier μ)
#align convex.null_measurable_set Convex.nullMeasurableSet
-/

end Convex

