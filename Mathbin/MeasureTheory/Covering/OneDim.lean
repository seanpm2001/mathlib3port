/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module measure_theory.covering.one_dim
! leanprover-community/mathlib commit 7e5137f579de09a059a5ce98f364a04e221aabf0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Covering.DensityTheorem
import Mathbin.MeasureTheory.Measure.Lebesgue.EqHaar

/-!
# Covering theorems for Lebesgue measure in one dimension

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We have a general theory of covering theorems for doubling measures, developed notably
in `density_theorems.lean`. In this file, we expand the API for this theory in one dimension,
by showing that intervals belong to the relevant Vitali family.
-/


open Set MeasureTheory IsUnifLocDoublingMeasure Filter

open scoped Topology

namespace Real

#print Real.Icc_mem_vitaliFamily_at_right /-
theorem Icc_mem_vitaliFamily_at_right {x y : ℝ} (hxy : x < y) :
    Icc x y ∈ (VitaliFamily (volume : Measure ℝ) 1).setsAt x :=
  by
  rw [Icc_eq_closed_ball]
  refine' closed_ball_mem_vitali_family_of_dist_le_mul _ _ (by linarith)
  rw [dist_comm, Real.dist_eq, abs_of_nonneg] <;> linarith
#align real.Icc_mem_vitali_family_at_right Real.Icc_mem_vitaliFamily_at_right
-/

#print Real.tendsto_Icc_vitaliFamily_right /-
theorem tendsto_Icc_vitaliFamily_right (x : ℝ) :
    Tendsto (fun y => Icc x y) (𝓝[>] x) ((VitaliFamily (volume : Measure ℝ) 1).filterAt x) :=
  by
  refine' (VitaliFamily.tendsto_filterAt_iff _).2 ⟨_, _⟩
  · filter_upwards [self_mem_nhdsWithin] with y hy using Icc_mem_vitali_family_at_right hy
  · intro ε εpos
    have : x ∈ Ico x (x + ε) := ⟨le_refl _, by linarith⟩
    filter_upwards [Icc_mem_nhdsWithin_Ioi this] with y hy
    rw [closed_ball_eq_Icc]
    exact Icc_subset_Icc (by linarith) hy.2
#align real.tendsto_Icc_vitali_family_right Real.tendsto_Icc_vitaliFamily_right
-/

#print Real.Icc_mem_vitaliFamily_at_left /-
theorem Icc_mem_vitaliFamily_at_left {x y : ℝ} (hxy : x < y) :
    Icc x y ∈ (VitaliFamily (volume : Measure ℝ) 1).setsAt y :=
  by
  rw [Icc_eq_closed_ball]
  refine' closed_ball_mem_vitali_family_of_dist_le_mul _ _ (by linarith)
  rw [Real.dist_eq, abs_of_nonneg] <;> linarith
#align real.Icc_mem_vitali_family_at_left Real.Icc_mem_vitaliFamily_at_left
-/

#print Real.tendsto_Icc_vitaliFamily_left /-
theorem tendsto_Icc_vitaliFamily_left (x : ℝ) :
    Tendsto (fun y => Icc y x) (𝓝[<] x) ((VitaliFamily (volume : Measure ℝ) 1).filterAt x) :=
  by
  refine' (VitaliFamily.tendsto_filterAt_iff _).2 ⟨_, _⟩
  · filter_upwards [self_mem_nhdsWithin] with y hy using Icc_mem_vitali_family_at_left hy
  · intro ε εpos
    have : x ∈ Ioc (x - ε) x := ⟨by linarith, le_refl _⟩
    filter_upwards [Icc_mem_nhdsWithin_Iio this] with y hy
    rw [closed_ball_eq_Icc]
    exact Icc_subset_Icc hy.1 (by linarith)
#align real.tendsto_Icc_vitali_family_left Real.tendsto_Icc_vitaliFamily_left
-/

end Real

