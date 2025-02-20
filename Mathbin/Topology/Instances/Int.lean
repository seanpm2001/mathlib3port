/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

! This file was ported from Lean 3 source module topology.instances.int
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Int.Interval
import Mathbin.Topology.MetricSpace.Basic
import Mathbin.Order.Filter.Archimedean

/-!
# Topology on the integers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The structure of a metric space on `ℤ` is introduced in this file, induced from `ℝ`.
-/


noncomputable section

open Metric Set Filter

namespace Int

instance : Dist ℤ :=
  ⟨fun x y => dist (x : ℝ) y⟩

#print Int.dist_eq /-
theorem dist_eq (x y : ℤ) : dist x y = |x - y| :=
  rfl
#align int.dist_eq Int.dist_eq
-/

#print Int.dist_cast_real /-
@[norm_cast, simp]
theorem dist_cast_real (x y : ℤ) : dist (x : ℝ) y = dist x y :=
  rfl
#align int.dist_cast_real Int.dist_cast_real
-/

#print Int.pairwise_one_le_dist /-
theorem pairwise_one_le_dist : Pairwise fun m n : ℤ => 1 ≤ dist m n :=
  by
  intro m n hne
  rw [dist_eq]; norm_cast; rwa [← zero_add (1 : ℤ), Int.add_one_le_iff, abs_pos, sub_ne_zero]
#align int.pairwise_one_le_dist Int.pairwise_one_le_dist
-/

#print Int.uniformEmbedding_coe_real /-
theorem uniformEmbedding_coe_real : UniformEmbedding (coe : ℤ → ℝ) :=
  uniformEmbedding_bot_of_pairwise_le_dist zero_lt_one pairwise_one_le_dist
#align int.uniform_embedding_coe_real Int.uniformEmbedding_coe_real
-/

#print Int.closedEmbedding_coe_real /-
theorem closedEmbedding_coe_real : ClosedEmbedding (coe : ℤ → ℝ) :=
  closedEmbedding_of_pairwise_le_dist zero_lt_one pairwise_one_le_dist
#align int.closed_embedding_coe_real Int.closedEmbedding_coe_real
-/

instance : MetricSpace ℤ :=
  Int.uniformEmbedding_coe_real.comapMetricSpace _

#print Int.preimage_ball /-
theorem preimage_ball (x : ℤ) (r : ℝ) : coe ⁻¹' ball (x : ℝ) r = ball x r :=
  rfl
#align int.preimage_ball Int.preimage_ball
-/

#print Int.preimage_closedBall /-
theorem preimage_closedBall (x : ℤ) (r : ℝ) : coe ⁻¹' closedBall (x : ℝ) r = closedBall x r :=
  rfl
#align int.preimage_closed_ball Int.preimage_closedBall
-/

#print Int.ball_eq_Ioo /-
theorem ball_eq_Ioo (x : ℤ) (r : ℝ) : ball x r = Ioo ⌊↑x - r⌋ ⌈↑x + r⌉ := by
  rw [← preimage_ball, Real.ball_eq_Ioo, preimage_Ioo]
#align int.ball_eq_Ioo Int.ball_eq_Ioo
-/

#print Int.closedBall_eq_Icc /-
theorem closedBall_eq_Icc (x : ℤ) (r : ℝ) : closedBall x r = Icc ⌈↑x - r⌉ ⌊↑x + r⌋ := by
  rw [← preimage_closed_ball, Real.closedBall_eq_Icc, preimage_Icc]
#align int.closed_ball_eq_Icc Int.closedBall_eq_Icc
-/

instance : ProperSpace ℤ :=
  ⟨by
    intro x r
    rw [closed_ball_eq_Icc]
    exact (Set.finite_Icc _ _).IsCompact⟩

#print Int.cocompact_eq /-
@[simp]
theorem cocompact_eq : cocompact ℤ = atBot ⊔ atTop := by
  simp only [← comap_dist_right_atTop_eq_cocompact (0 : ℤ), dist_eq, sub_zero, cast_zero, ←
    cast_abs, ← @comap_comap _ _ _ _ abs, Int.comap_cast_atTop, comap_abs_at_top]
#align int.cocompact_eq Int.cocompact_eq
-/

#print Int.cofinite_eq /-
@[simp]
theorem cofinite_eq : (cofinite : Filter ℤ) = atBot ⊔ atTop := by
  rw [← cocompact_eq_cofinite, cocompact_eq]
#align int.cofinite_eq Int.cofinite_eq
-/

end Int

