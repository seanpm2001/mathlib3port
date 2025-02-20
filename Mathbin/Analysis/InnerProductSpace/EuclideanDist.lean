/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.inner_product_space.euclidean_dist
! leanprover-community/mathlib commit 36938f775671ff28bea1c0310f1608e4afbb22e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.Calculus
import Mathbin.Analysis.InnerProductSpace.PiL2

/-!
# Euclidean distance on a finite dimensional space

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

When we define a smooth bump function on a normed space, it is useful to have a smooth distance on
the space. Since the default distance is not guaranteed to be smooth, we define `to_euclidean` to be
an equivalence between a finite dimensional topological vector space and the standard Euclidean
space of the same dimension.
Then we define `euclidean.dist x y = dist (to_euclidean x) (to_euclidean y)` and
provide some definitions (`euclidean.ball`, `euclidean.closed_ball`) and simple lemmas about this
distance. This way we hide the usage of `to_euclidean` behind an API.
-/


open scoped Topology

open Set

variable {E : Type _} [AddCommGroup E] [TopologicalSpace E] [TopologicalAddGroup E] [T2Space E]
  [Module ℝ E] [ContinuousSMul ℝ E] [FiniteDimensional ℝ E]

noncomputable section

open FiniteDimensional

#print toEuclidean /-
/-- If `E` is a finite dimensional space over `ℝ`, then `to_euclidean` is a continuous `ℝ`-linear
equivalence between `E` and the Euclidean space of the same dimension. -/
def toEuclidean : E ≃L[ℝ] EuclideanSpace ℝ (Fin <| finrank ℝ E) :=
  ContinuousLinearEquiv.ofFinrankEq finrank_euclideanSpace_fin.symm
#align to_euclidean toEuclidean
-/

namespace Euclidean

#print Euclidean.dist /-
/-- If `x` and `y` are two points in a finite dimensional space over `ℝ`, then `euclidean.dist x y`
is the distance between these points in the metric defined by some inner product space structure on
`E`. -/
def dist (x y : E) : ℝ :=
  dist (toEuclidean x) (toEuclidean y)
#align euclidean.dist Euclidean.dist
-/

#print Euclidean.closedBall /-
/-- Closed ball w.r.t. the euclidean distance. -/
def closedBall (x : E) (r : ℝ) : Set E :=
  {y | dist y x ≤ r}
#align euclidean.closed_ball Euclidean.closedBall
-/

#print Euclidean.ball /-
/-- Open ball w.r.t. the euclidean distance. -/
def ball (x : E) (r : ℝ) : Set E :=
  {y | dist y x < r}
#align euclidean.ball Euclidean.ball
-/

#print Euclidean.ball_eq_preimage /-
theorem ball_eq_preimage (x : E) (r : ℝ) :
    ball x r = toEuclidean ⁻¹' Metric.ball (toEuclidean x) r :=
  rfl
#align euclidean.ball_eq_preimage Euclidean.ball_eq_preimage
-/

#print Euclidean.closedBall_eq_preimage /-
theorem closedBall_eq_preimage (x : E) (r : ℝ) :
    closedBall x r = toEuclidean ⁻¹' Metric.closedBall (toEuclidean x) r :=
  rfl
#align euclidean.closed_ball_eq_preimage Euclidean.closedBall_eq_preimage
-/

#print Euclidean.ball_subset_closedBall /-
theorem ball_subset_closedBall {x : E} {r : ℝ} : ball x r ⊆ closedBall x r := fun y (hy : _ < _) =>
  le_of_lt hy
#align euclidean.ball_subset_closed_ball Euclidean.ball_subset_closedBall
-/

#print Euclidean.isOpen_ball /-
theorem isOpen_ball {x : E} {r : ℝ} : IsOpen (ball x r) :=
  Metric.isOpen_ball.Preimage toEuclidean.Continuous
#align euclidean.is_open_ball Euclidean.isOpen_ball
-/

#print Euclidean.mem_ball_self /-
theorem mem_ball_self {x : E} {r : ℝ} (hr : 0 < r) : x ∈ ball x r :=
  Metric.mem_ball_self hr
#align euclidean.mem_ball_self Euclidean.mem_ball_self
-/

#print Euclidean.closedBall_eq_image /-
theorem closedBall_eq_image (x : E) (r : ℝ) :
    closedBall x r = toEuclidean.symm '' Metric.closedBall (toEuclidean x) r := by
  rw [to_euclidean.image_symm_eq_preimage, closed_ball_eq_preimage]
#align euclidean.closed_ball_eq_image Euclidean.closedBall_eq_image
-/

#print Euclidean.isCompact_closedBall /-
theorem isCompact_closedBall {x : E} {r : ℝ} : IsCompact (closedBall x r) :=
  by
  rw [closed_ball_eq_image]
  exact (is_compact_closed_ball _ _).image to_euclidean.symm.continuous
#align euclidean.is_compact_closed_ball Euclidean.isCompact_closedBall
-/

#print Euclidean.isClosed_closedBall /-
theorem isClosed_closedBall {x : E} {r : ℝ} : IsClosed (closedBall x r) :=
  isCompact_closedBall.IsClosed
#align euclidean.is_closed_closed_ball Euclidean.isClosed_closedBall
-/

#print Euclidean.closure_ball /-
theorem closure_ball (x : E) {r : ℝ} (h : r ≠ 0) : closure (ball x r) = closedBall x r := by
  rw [ball_eq_preimage, ← to_euclidean.preimage_closure, closure_ball (toEuclidean x) h,
    closed_ball_eq_preimage]
#align euclidean.closure_ball Euclidean.closure_ball
-/

#print Euclidean.exists_pos_lt_subset_ball /-
theorem exists_pos_lt_subset_ball {R : ℝ} {s : Set E} {x : E} (hR : 0 < R) (hs : IsClosed s)
    (h : s ⊆ ball x R) : ∃ r ∈ Ioo 0 R, s ⊆ ball x r :=
  by
  rw [ball_eq_preimage, ← image_subset_iff] at h 
  rcases exists_pos_lt_subset_ball hR (to_euclidean.is_closed_image.2 hs) h with ⟨r, hr, hsr⟩
  exact ⟨r, hr, image_subset_iff.1 hsr⟩
#align euclidean.exists_pos_lt_subset_ball Euclidean.exists_pos_lt_subset_ball
-/

#print Euclidean.nhds_basis_closedBall /-
theorem nhds_basis_closedBall {x : E} : (𝓝 x).HasBasis (fun r : ℝ => 0 < r) (closedBall x) :=
  by
  rw [to_euclidean.to_homeomorph.nhds_eq_comap x]
  exact metric.nhds_basis_closed_ball.comap _
#align euclidean.nhds_basis_closed_ball Euclidean.nhds_basis_closedBall
-/

#print Euclidean.closedBall_mem_nhds /-
theorem closedBall_mem_nhds {x : E} {r : ℝ} (hr : 0 < r) : closedBall x r ∈ 𝓝 x :=
  nhds_basis_closedBall.mem_of_mem hr
#align euclidean.closed_ball_mem_nhds Euclidean.closedBall_mem_nhds
-/

#print Euclidean.nhds_basis_ball /-
theorem nhds_basis_ball {x : E} : (𝓝 x).HasBasis (fun r : ℝ => 0 < r) (ball x) :=
  by
  rw [to_euclidean.to_homeomorph.nhds_eq_comap x]
  exact metric.nhds_basis_ball.comap _
#align euclidean.nhds_basis_ball Euclidean.nhds_basis_ball
-/

#print Euclidean.ball_mem_nhds /-
theorem ball_mem_nhds {x : E} {r : ℝ} (hr : 0 < r) : ball x r ∈ 𝓝 x :=
  nhds_basis_ball.mem_of_mem hr
#align euclidean.ball_mem_nhds Euclidean.ball_mem_nhds
-/

end Euclidean

variable {F : Type _} [NormedAddCommGroup F] [NormedSpace ℝ F] {G : Type _} [NormedAddCommGroup G]
  [NormedSpace ℝ G] [FiniteDimensional ℝ G] {f g : F → G} {n : ℕ∞}

#print ContDiff.euclidean_dist /-
theorem ContDiff.euclidean_dist (hf : ContDiff ℝ n f) (hg : ContDiff ℝ n g) (h : ∀ x, f x ≠ g x) :
    ContDiff ℝ n fun x => Euclidean.dist (f x) (g x) :=
  by
  simp only [Euclidean.dist]
  apply @ContDiff.dist ℝ
  exacts [(@toEuclidean G _ _ _ _ _ _ _).ContDiff.comp hf,
    (@toEuclidean G _ _ _ _ _ _ _).ContDiff.comp hg, fun x => to_euclidean.injective.ne (h x)]
#align cont_diff.euclidean_dist ContDiff.euclidean_dist
-/

