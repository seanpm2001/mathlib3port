/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module analysis.analytic.linear
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Analytic.Basic

/-!
# Linear functions are analytic

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that a `continuous_linear_map` defines an analytic function with
the formal power series `f x = f a + f (x - a)`.
-/


variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {E : Type _} [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F] {G : Type _}
  [NormedAddCommGroup G] [NormedSpace 𝕜 G]

open scoped Topology Classical BigOperators NNReal ENNReal

open Set Filter Asymptotics

noncomputable section

namespace ContinuousLinearMap

#print ContinuousLinearMap.fpowerSeries /-
/-- Formal power series of a continuous linear map `f : E →L[𝕜] F` at `x : E`:
`f y = f x + f (y - x)`. -/
@[simp]
def fpowerSeries (f : E →L[𝕜] F) (x : E) : FormalMultilinearSeries 𝕜 E F
  | 0 => ContinuousMultilinearMap.curry0 𝕜 _ (f x)
  | 1 => (continuousMultilinearCurryFin1 𝕜 E F).symm f
  | _ => 0
#align continuous_linear_map.fpower_series ContinuousLinearMap.fpowerSeries
-/

#print ContinuousLinearMap.fpowerSeries_apply_add_two /-
@[simp]
theorem fpowerSeries_apply_add_two (f : E →L[𝕜] F) (x : E) (n : ℕ) : f.fpowerSeries x (n + 2) = 0 :=
  rfl
#align continuous_linear_map.fpower_series_apply_add_two ContinuousLinearMap.fpowerSeries_apply_add_two
-/

#print ContinuousLinearMap.fpowerSeries_radius /-
@[simp]
theorem fpowerSeries_radius (f : E →L[𝕜] F) (x : E) : (f.fpowerSeries x).radius = ∞ :=
  (f.fpowerSeries x).radius_eq_top_of_forall_image_add_eq_zero 2 fun n => rfl
#align continuous_linear_map.fpower_series_radius ContinuousLinearMap.fpowerSeries_radius
-/

#print ContinuousLinearMap.hasFPowerSeriesOnBall /-
protected theorem hasFPowerSeriesOnBall (f : E →L[𝕜] F) (x : E) :
    HasFPowerSeriesOnBall f (f.fpowerSeries x) x ∞ :=
  { r_le := by simp
    r_pos := ENNReal.coe_lt_top
    HasSum := fun y _ =>
      (hasSum_nat_add_iff' 2).1 <| by simp [Finset.sum_range_succ, ← sub_sub, hasSum_zero] }
#align continuous_linear_map.has_fpower_series_on_ball ContinuousLinearMap.hasFPowerSeriesOnBall
-/

#print ContinuousLinearMap.hasFPowerSeriesAt /-
protected theorem hasFPowerSeriesAt (f : E →L[𝕜] F) (x : E) :
    HasFPowerSeriesAt f (f.fpowerSeries x) x :=
  ⟨∞, f.HasFPowerSeriesOnBall x⟩
#align continuous_linear_map.has_fpower_series_at ContinuousLinearMap.hasFPowerSeriesAt
-/

#print ContinuousLinearMap.analyticAt /-
protected theorem analyticAt (f : E →L[𝕜] F) (x : E) : AnalyticAt 𝕜 f x :=
  (f.HasFPowerSeriesAt x).AnalyticAt
#align continuous_linear_map.analytic_at ContinuousLinearMap.analyticAt
-/

#print ContinuousLinearMap.uncurryBilinear /-
/-- Reinterpret a bilinear map `f : E →L[𝕜] F →L[𝕜] G` as a multilinear map
`(E × F) [×2]→L[𝕜] G`. This multilinear map is the second term in the formal
multilinear series expansion of `uncurry f`. It is given by
`f.uncurry_bilinear ![(x, y), (x', y')] = f x y'`. -/
def uncurryBilinear (f : E →L[𝕜] F →L[𝕜] G) : E × F[×2]→L[𝕜] G :=
  @ContinuousLinearMap.uncurryLeft 𝕜 1 (fun _ => E × F) G _ _ _ _ _ <|
    (↑(continuousMultilinearCurryFin1 𝕜 (E × F) G).symm : (E × F →L[𝕜] G) →L[𝕜] _).comp <|
      f.bilinearComp (fst _ _ _) (snd _ _ _)
#align continuous_linear_map.uncurry_bilinear ContinuousLinearMap.uncurryBilinear
-/

#print ContinuousLinearMap.uncurryBilinear_apply /-
@[simp]
theorem uncurryBilinear_apply (f : E →L[𝕜] F →L[𝕜] G) (m : Fin 2 → E × F) :
    f.uncurryBilinear m = f (m 0).1 (m 1).2 :=
  rfl
#align continuous_linear_map.uncurry_bilinear_apply ContinuousLinearMap.uncurryBilinear_apply
-/

#print ContinuousLinearMap.fpowerSeriesBilinear /-
/-- Formal multilinear series expansion of a bilinear function `f : E →L[𝕜] F →L[𝕜] G`. -/
@[simp]
def fpowerSeriesBilinear (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) : FormalMultilinearSeries 𝕜 (E × F) G
  | 0 => ContinuousMultilinearMap.curry0 𝕜 _ (f x.1 x.2)
  | 1 => (continuousMultilinearCurryFin1 𝕜 (E × F) G).symm (f.deriv₂ x)
  | 2 => f.uncurryBilinear
  | _ => 0
#align continuous_linear_map.fpower_series_bilinear ContinuousLinearMap.fpowerSeriesBilinear
-/

#print ContinuousLinearMap.fpowerSeriesBilinear_radius /-
@[simp]
theorem fpowerSeriesBilinear_radius (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) :
    (f.fpowerSeriesBilinear x).radius = ∞ :=
  (f.fpowerSeriesBilinear x).radius_eq_top_of_forall_image_add_eq_zero 3 fun n => rfl
#align continuous_linear_map.fpower_series_bilinear_radius ContinuousLinearMap.fpowerSeriesBilinear_radius
-/

#print ContinuousLinearMap.hasFPowerSeriesOnBall_bilinear /-
protected theorem hasFPowerSeriesOnBall_bilinear (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) :
    HasFPowerSeriesOnBall (fun x : E × F => f x.1 x.2) (f.fpowerSeriesBilinear x) x ∞ :=
  { r_le := by simp
    r_pos := ENNReal.coe_lt_top
    HasSum := fun y _ =>
      (hasSum_nat_add_iff' 3).1 <|
        by
        simp only [Finset.sum_range_succ, Finset.sum_range_one, Prod.fst_add, Prod.snd_add,
          f.map_add_add]
        dsimp; simp only [add_comm, sub_self, hasSum_zero] }
#align continuous_linear_map.has_fpower_series_on_ball_bilinear ContinuousLinearMap.hasFPowerSeriesOnBall_bilinear
-/

#print ContinuousLinearMap.hasFPowerSeriesAt_bilinear /-
protected theorem hasFPowerSeriesAt_bilinear (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) :
    HasFPowerSeriesAt (fun x : E × F => f x.1 x.2) (f.fpowerSeriesBilinear x) x :=
  ⟨∞, f.hasFPowerSeriesOnBall_bilinear x⟩
#align continuous_linear_map.has_fpower_series_at_bilinear ContinuousLinearMap.hasFPowerSeriesAt_bilinear
-/

#print ContinuousLinearMap.analyticAt_bilinear /-
protected theorem analyticAt_bilinear (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) :
    AnalyticAt 𝕜 (fun x : E × F => f x.1 x.2) x :=
  (f.hasFPowerSeriesAt_bilinear x).AnalyticAt
#align continuous_linear_map.analytic_at_bilinear ContinuousLinearMap.analyticAt_bilinear
-/

end ContinuousLinearMap

