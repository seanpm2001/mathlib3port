/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alexander Bentkamp, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.convex.normed
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Jensen
import Mathbin.Analysis.Convex.Topology
import Mathbin.Analysis.Normed.Group.Pointwise
import Mathbin.Analysis.NormedSpace.Ray

/-!
# Topological and metric properties of convex sets in normed spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We prove the following facts:

* `convex_on_norm`, `convex_on_dist` : norm and distance to a fixed point is convex on any convex
  set;
* `convex_on_univ_norm`, `convex_on_univ_dist` : norm and distance to a fixed point is convex on
  the whole space;
* `convex_hull_ediam`, `convex_hull_diam` : convex hull of a set has the same (e)metric diameter
  as the original set;
* `bounded_convex_hull` : convex hull of a set is bounded if and only if the original set
  is bounded.
* `bounded_std_simplex`, `is_closed_std_simplex`, `compact_std_simplex`: topological properties
  of the standard simplex.
-/


variable {ι : Type _} {E : Type _}

open Metric Set

open scoped Pointwise Convex

variable [SeminormedAddCommGroup E] [NormedSpace ℝ E] {s t : Set E}

#print convexOn_norm /-
/-- The norm on a real normed space is convex on any convex set. See also `seminorm.convex_on`
and `convex_on_univ_norm`. -/
theorem convexOn_norm (hs : Convex ℝ s) : ConvexOn ℝ s norm :=
  ⟨hs, fun x hx y hy a b ha hb hab =>
    calc
      ‖a • x + b • y‖ ≤ ‖a • x‖ + ‖b • y‖ := norm_add_le _ _
      _ = a * ‖x‖ + b * ‖y‖ := by
        rw [norm_smul, norm_smul, Real.norm_of_nonneg ha, Real.norm_of_nonneg hb]⟩
#align convex_on_norm convexOn_norm
-/

#print convexOn_univ_norm /-
/-- The norm on a real normed space is convex on the whole space. See also `seminorm.convex_on`
and `convex_on_norm`. -/
theorem convexOn_univ_norm : ConvexOn ℝ univ (norm : E → ℝ) :=
  convexOn_norm convex_univ
#align convex_on_univ_norm convexOn_univ_norm
-/

#print convexOn_dist /-
theorem convexOn_dist (z : E) (hs : Convex ℝ s) : ConvexOn ℝ s fun z' => dist z' z := by
  simpa [dist_eq_norm, preimage_preimage] using
    (convexOn_norm (hs.translate (-z))).comp_affineMap (AffineMap.id ℝ E - AffineMap.const ℝ E z)
#align convex_on_dist convexOn_dist
-/

#print convexOn_univ_dist /-
theorem convexOn_univ_dist (z : E) : ConvexOn ℝ univ fun z' => dist z' z :=
  convexOn_dist z convex_univ
#align convex_on_univ_dist convexOn_univ_dist
-/

#print convex_ball /-
theorem convex_ball (a : E) (r : ℝ) : Convex ℝ (Metric.ball a r) := by
  simpa only [Metric.ball, sep_univ] using (convexOn_univ_dist a).convex_lt r
#align convex_ball convex_ball
-/

#print convex_closedBall /-
theorem convex_closedBall (a : E) (r : ℝ) : Convex ℝ (Metric.closedBall a r) := by
  simpa only [Metric.closedBall, sep_univ] using (convexOn_univ_dist a).convex_le r
#align convex_closed_ball convex_closedBall
-/

#print Convex.thickening /-
theorem Convex.thickening (hs : Convex ℝ s) (δ : ℝ) : Convex ℝ (thickening δ s) := by
  rw [← add_ball_zero]; exact hs.add (convex_ball 0 _)
#align convex.thickening Convex.thickening
-/

#print Convex.cthickening /-
theorem Convex.cthickening (hs : Convex ℝ s) (δ : ℝ) : Convex ℝ (cthickening δ s) :=
  by
  obtain hδ | hδ := le_total 0 δ
  · rw [cthickening_eq_Inter_thickening hδ]
    exact convex_iInter₂ fun _ _ => hs.thickening _
  · rw [cthickening_of_nonpos hδ]
    exact hs.closure
#align convex.cthickening Convex.cthickening
-/

#print convexHull_exists_dist_ge /-
/-- Given a point `x` in the convex hull of `s` and a point `y`, there exists a point
of `s` at distance at least `dist x y` from `y`. -/
theorem convexHull_exists_dist_ge {s : Set E} {x : E} (hx : x ∈ convexHull ℝ s) (y : E) :
    ∃ x' ∈ s, dist x y ≤ dist x' y :=
  (convexOn_dist y (convex_convexHull ℝ _)).exists_ge_of_mem_convexHull hx
#align convex_hull_exists_dist_ge convexHull_exists_dist_ge
-/

#print convexHull_exists_dist_ge2 /-
/-- Given a point `x` in the convex hull of `s` and a point `y` in the convex hull of `t`,
there exist points `x' ∈ s` and `y' ∈ t` at distance at least `dist x y`. -/
theorem convexHull_exists_dist_ge2 {s t : Set E} {x y : E} (hx : x ∈ convexHull ℝ s)
    (hy : y ∈ convexHull ℝ t) : ∃ x' ∈ s, ∃ y' ∈ t, dist x y ≤ dist x' y' :=
  by
  rcases convexHull_exists_dist_ge hx y with ⟨x', hx', Hx'⟩
  rcases convexHull_exists_dist_ge hy x' with ⟨y', hy', Hy'⟩
  use x', hx', y', hy'
  exact le_trans Hx' (dist_comm y x' ▸ dist_comm y' x' ▸ Hy')
#align convex_hull_exists_dist_ge2 convexHull_exists_dist_ge2
-/

#print convexHull_ediam /-
/-- Emetric diameter of the convex hull of a set `s` equals the emetric diameter of `s. -/
@[simp]
theorem convexHull_ediam (s : Set E) : EMetric.diam (convexHull ℝ s) = EMetric.diam s :=
  by
  refine' (EMetric.diam_le fun x hx y hy => _).antisymm (EMetric.diam_mono <| subset_convexHull ℝ s)
  rcases convexHull_exists_dist_ge2 hx hy with ⟨x', hx', y', hy', H⟩
  rw [edist_dist]
  apply le_trans (ENNReal.ofReal_le_ofReal H)
  rw [← edist_dist]
  exact EMetric.edist_le_diam_of_mem hx' hy'
#align convex_hull_ediam convexHull_ediam
-/

#print convexHull_diam /-
/-- Diameter of the convex hull of a set `s` equals the emetric diameter of `s. -/
@[simp]
theorem convexHull_diam (s : Set E) : Metric.diam (convexHull ℝ s) = Metric.diam s := by
  simp only [Metric.diam, convexHull_ediam]
#align convex_hull_diam convexHull_diam
-/

#print bounded_convexHull /-
/-- Convex hull of `s` is bounded if and only if `s` is bounded. -/
@[simp]
theorem bounded_convexHull {s : Set E} : Metric.Bounded (convexHull ℝ s) ↔ Metric.Bounded s := by
  simp only [Metric.bounded_iff_ediam_ne_top, convexHull_ediam]
#align bounded_convex_hull bounded_convexHull
-/

#print NormedSpace.path_connected /-
instance (priority := 100) NormedSpace.path_connected : PathConnectedSpace E :=
  TopologicalAddGroup.pathConnectedSpace
#align normed_space.path_connected NormedSpace.path_connected
-/

#print NormedSpace.loc_path_connected /-
instance (priority := 100) NormedSpace.loc_path_connected : LocPathConnectedSpace E :=
  locPathConnected_of_bases (fun x => Metric.nhds_basis_ball) fun x r r_pos =>
    (convex_ball x r).IsPathConnected <| by simp [r_pos]
#align normed_space.loc_path_connected NormedSpace.loc_path_connected
-/

#print dist_add_dist_of_mem_segment /-
theorem dist_add_dist_of_mem_segment {x y z : E} (h : y ∈ [x -[ℝ] z]) :
    dist x y + dist y z = dist x z :=
  by
  simp only [dist_eq_norm, mem_segment_iff_sameRay] at *
  simpa only [sub_add_sub_cancel', norm_sub_rev] using h.norm_add.symm
#align dist_add_dist_of_mem_segment dist_add_dist_of_mem_segment
-/

#print isConnected_setOf_sameRay /-
/-- The set of vectors in the same ray as `x` is connected. -/
theorem isConnected_setOf_sameRay (x : E) : IsConnected {y | SameRay ℝ x y} :=
  by
  by_cases hx : x = 0; · simpa [hx] using isConnected_univ
  simp_rw [← exists_nonneg_left_iff_sameRay hx]
  exact is_connected_Ici.image _ (continuous_id.smul continuous_const).ContinuousOn
#align is_connected_set_of_same_ray isConnected_setOf_sameRay
-/

#print isConnected_setOf_sameRay_and_ne_zero /-
/-- The set of nonzero vectors in the same ray as the nonzero vector `x` is connected. -/
theorem isConnected_setOf_sameRay_and_ne_zero {x : E} (hx : x ≠ 0) :
    IsConnected {y | SameRay ℝ x y ∧ y ≠ 0} :=
  by
  simp_rw [← exists_pos_left_iff_sameRay_and_ne_zero hx]
  exact is_connected_Ioi.image _ (continuous_id.smul continuous_const).ContinuousOn
#align is_connected_set_of_same_ray_and_ne_zero isConnected_setOf_sameRay_and_ne_zero
-/

