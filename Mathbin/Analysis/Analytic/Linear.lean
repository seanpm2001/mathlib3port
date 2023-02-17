/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module analysis.analytic.linear
! leanprover-community/mathlib commit 740acc0e6f9adf4423f92a485d0456fc271482da
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Analytic.Basic

/-!
# Linear functions are analytic

In this file we prove that a `continuous_linear_map` defines an analytic function with
the formal power series `f x = f a + f (x - a)`.
-/


variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {E : Type _} [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F] {G : Type _}
  [NormedAddCommGroup G] [NormedSpace 𝕜 G]

open Topology Classical BigOperators Nnreal Ennreal

open Set Filter Asymptotics

noncomputable section

namespace ContinuousLinearMap

/-- Formal power series of a continuous linear map `f : E →L[𝕜] F` at `x : E`:
`f y = f x + f (y - x)`. -/
@[simp]
def fpowerSeries (f : E →L[𝕜] F) (x : E) : FormalMultilinearSeries 𝕜 E F
  | 0 => ContinuousMultilinearMap.curry0 𝕜 _ (f x)
  | 1 => (continuousMultilinearCurryFin1 𝕜 E F).symm f
  | _ => 0
#align continuous_linear_map.fpower_series ContinuousLinearMap.fpowerSeries

@[simp]
theorem fpowerSeries_apply_add_two (f : E →L[𝕜] F) (x : E) (n : ℕ) : f.fpowerSeries x (n + 2) = 0 :=
  rfl
#align continuous_linear_map.fpower_series_apply_add_two ContinuousLinearMap.fpowerSeries_apply_add_two

@[simp]
theorem fpowerSeries_radius (f : E →L[𝕜] F) (x : E) : (f.fpowerSeries x).radius = ∞ :=
  (f.fpowerSeries x).radius_eq_top_of_forall_image_add_eq_zero 2 fun n => rfl
#align continuous_linear_map.fpower_series_radius ContinuousLinearMap.fpowerSeries_radius

protected theorem hasFpowerSeriesOnBall (f : E →L[𝕜] F) (x : E) :
    HasFpowerSeriesOnBall f (f.fpowerSeries x) x ∞ :=
  { r_le := by simp
    r_pos := Ennreal.coe_lt_top
    HasSum := fun y _ =>
      (hasSum_nat_add_iff' 2).1 <| by simp [Finset.sum_range_succ, ← sub_sub, hasSum_zero] }
#align continuous_linear_map.has_fpower_series_on_ball ContinuousLinearMap.hasFpowerSeriesOnBall

protected theorem hasFpowerSeriesAt (f : E →L[𝕜] F) (x : E) :
    HasFpowerSeriesAt f (f.fpowerSeries x) x :=
  ⟨∞, f.HasFpowerSeriesOnBall x⟩
#align continuous_linear_map.has_fpower_series_at ContinuousLinearMap.hasFpowerSeriesAt

protected theorem analyticAt (f : E →L[𝕜] F) (x : E) : AnalyticAt 𝕜 f x :=
  (f.HasFpowerSeriesAt x).AnalyticAt
#align continuous_linear_map.analytic_at ContinuousLinearMap.analyticAt

/-- Reinterpret a bilinear map `f : E →L[𝕜] F →L[𝕜] G` as a multilinear map
`(E × F) [×2]→L[𝕜] G`. This multilinear map is the second term in the formal
multilinear series expansion of `uncurry f`. It is given by
`f.uncurry_bilinear ![(x, y), (x', y')] = f x y'`. -/
def uncurryBilinear (f : E →L[𝕜] F →L[𝕜] G) : E × F[×2]→L[𝕜] G :=
  @ContinuousLinearMap.uncurryLeft 𝕜 1 (fun _ => E × F) G _ _ _ _ _ <|
    (↑(continuousMultilinearCurryFin1 𝕜 (E × F) G).symm : (E × F →L[𝕜] G) →L[𝕜] _).comp <|
      f.bilinearComp (fst _ _ _) (snd _ _ _)
#align continuous_linear_map.uncurry_bilinear ContinuousLinearMap.uncurryBilinear

@[simp]
theorem uncurryBilinear_apply (f : E →L[𝕜] F →L[𝕜] G) (m : Fin 2 → E × F) :
    f.uncurryBilinear m = f (m 0).1 (m 1).2 :=
  rfl
#align continuous_linear_map.uncurry_bilinear_apply ContinuousLinearMap.uncurryBilinear_apply

/-- Formal multilinear series expansion of a bilinear function `f : E →L[𝕜] F →L[𝕜] G`. -/
@[simp]
def fpowerSeriesBilinear (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) : FormalMultilinearSeries 𝕜 (E × F) G
  | 0 => ContinuousMultilinearMap.curry0 𝕜 _ (f x.1 x.2)
  | 1 => (continuousMultilinearCurryFin1 𝕜 (E × F) G).symm (f.deriv₂ x)
  | 2 => f.uncurryBilinear
  | _ => 0
#align continuous_linear_map.fpower_series_bilinear ContinuousLinearMap.fpowerSeriesBilinear

@[simp]
theorem fpowerSeriesBilinear_radius (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) :
    (f.fpowerSeriesBilinear x).radius = ∞ :=
  (f.fpowerSeriesBilinear x).radius_eq_top_of_forall_image_add_eq_zero 3 fun n => rfl
#align continuous_linear_map.fpower_series_bilinear_radius ContinuousLinearMap.fpowerSeriesBilinear_radius

protected theorem hasFpowerSeriesOnBallBilinear (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) :
    HasFpowerSeriesOnBall (fun x : E × F => f x.1 x.2) (f.fpowerSeriesBilinear x) x ∞ :=
  { r_le := by simp
    r_pos := Ennreal.coe_lt_top
    HasSum := fun y _ =>
      (hasSum_nat_add_iff' 3).1 <|
        by
        simp only [Finset.sum_range_succ, Finset.sum_range_one, Prod.fst_add, Prod.snd_add,
          f.map_add_add]
        dsimp; simp only [add_comm, sub_self, hasSum_zero] }
#align continuous_linear_map.has_fpower_series_on_ball_bilinear ContinuousLinearMap.hasFpowerSeriesOnBallBilinear

protected theorem hasFpowerSeriesAtBilinear (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) :
    HasFpowerSeriesAt (fun x : E × F => f x.1 x.2) (f.fpowerSeriesBilinear x) x :=
  ⟨∞, f.hasFpowerSeriesOnBallBilinear x⟩
#align continuous_linear_map.has_fpower_series_at_bilinear ContinuousLinearMap.hasFpowerSeriesAtBilinear

protected theorem analyticAt_bilinear (f : E →L[𝕜] F →L[𝕜] G) (x : E × F) :
    AnalyticAt 𝕜 (fun x : E × F => f x.1 x.2) x :=
  (f.hasFpowerSeriesAtBilinear x).AnalyticAt
#align continuous_linear_map.analytic_at_bilinear ContinuousLinearMap.analyticAt_bilinear

end ContinuousLinearMap

