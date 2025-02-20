/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module analysis.analytic.uniqueness
! leanprover-community/mathlib commit 8af7091a43227e179939ba132e54e54e9f3b089a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Analytic.Linear
import Mathbin.Analysis.Analytic.Composition
import Mathbin.Analysis.NormedSpace.Completion

/-!
# Uniqueness principle for analytic functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We show that two analytic functions which coincide around a point coincide on whole connected sets,
in `analytic_on.eq_on_of_preconnected_of_eventually_eq`.
-/


variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {E : Type _} [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F]

open Set

open scoped Topology ENNReal

namespace AnalyticOn

#print AnalyticOn.eqOn_zero_of_preconnected_of_eventuallyEq_zero_aux /-
/-- If an analytic function vanishes around a point, then it is uniformly zero along
a connected set. Superseded by `eq_on_zero_of_preconnected_of_locally_zero` which does not assume
completeness of the target space. -/
theorem eqOn_zero_of_preconnected_of_eventuallyEq_zero_aux [CompleteSpace F] {f : E → F} {U : Set E}
    (hf : AnalyticOn 𝕜 f U) (hU : IsPreconnected U) {z₀ : E} (h₀ : z₀ ∈ U) (hfz₀ : f =ᶠ[𝓝 z₀] 0) :
    EqOn f 0 U :=
  by
  /- Let `u` be the set of points around which `f` vanishes. It is clearly open. We have to show
    that its limit points in `U` still belong to it, from which the inclusion `U ⊆ u` will follow
    by connectedness. -/
  let u := {x | f =ᶠ[𝓝 x] 0}
  suffices main : closure u ∩ U ⊆ u
  · have Uu : U ⊆ u :=
      hU.subset_of_closure_inter_subset isOpen_setOf_eventually_nhds ⟨z₀, h₀, hfz₀⟩ main
    intro z hz
    simpa using mem_of_mem_nhds (Uu hz)
  /- Take a limit point `x`, then a ball `B (x, r)` on which it has a power series expansion, and
    then `y ∈ B (x, r/2) ∩ u`. Then `f` has a power series expansion on `B (y, r/2)` as it is
    contained in `B (x, r)`. All the coefficients in this series expansion vanish, as `f` is zero on a
    neighborhood of `y`. Therefore, `f` is zero on `B (y, r/2)`. As this ball contains `x`, it follows
    that `f` vanishes on a neighborhood of `x`, proving the claim. -/
  rintro x ⟨xu, xU⟩
  rcases hf x xU with ⟨p, r, hp⟩
  obtain ⟨y, yu, hxy⟩ : ∃ y ∈ u, edist x y < r / 2
  exact EMetric.mem_closure_iff.1 xu (r / 2) (ENNReal.half_pos hp.r_pos.ne')
  let q := p.change_origin (y - x)
  have has_series : HasFPowerSeriesOnBall f q y (r / 2) :=
    by
    have A : (‖y - x‖₊ : ℝ≥0∞) < r / 2 := by rwa [edist_comm, edist_eq_coe_nnnorm_sub] at hxy 
    have := hp.change_origin (A.trans_le ENNReal.half_le_self)
    simp only [add_sub_cancel'_right] at this 
    apply this.mono (ENNReal.half_pos hp.r_pos.ne')
    apply ENNReal.le_sub_of_add_le_left ENNReal.coe_ne_top
    apply (add_le_add A.le (le_refl (r / 2))).trans (le_of_eq _)
    exact ENNReal.add_halves _
  have M : EMetric.ball y (r / 2) ∈ 𝓝 x := emetric.is_open_ball.mem_nhds hxy
  filter_upwards [M] with z hz
  have A : HasSum (fun n : ℕ => q n fun i : Fin n => z - y) (f z) := has_series.has_sum_sub hz
  have B : HasSum (fun n : ℕ => q n fun i : Fin n => z - y) 0 :=
    by
    have : HasFPowerSeriesAt 0 q y := has_series.has_fpower_series_at.congr yu
    convert hasSum_zero
    ext n
    exact this.apply_eq_zero n _
  exact HasSum.unique A B
#align analytic_on.eq_on_zero_of_preconnected_of_eventually_eq_zero_aux AnalyticOn.eqOn_zero_of_preconnected_of_eventuallyEq_zero_aux
-/

#print AnalyticOn.eqOn_zero_of_preconnected_of_eventuallyEq_zero /-
/-- The *identity principle* for analytic functions: If an analytic function vanishes in a whole
neighborhood of a point `z₀`, then it is uniformly zero along a connected set. For a one-dimensional
version assuming only that the function vanishes at some points arbitrarily close to `z₀`, see
`eq_on_zero_of_preconnected_of_frequently_eq_zero`. -/
theorem eqOn_zero_of_preconnected_of_eventuallyEq_zero {f : E → F} {U : Set E}
    (hf : AnalyticOn 𝕜 f U) (hU : IsPreconnected U) {z₀ : E} (h₀ : z₀ ∈ U) (hfz₀ : f =ᶠ[𝓝 z₀] 0) :
    EqOn f 0 U := by
  let F' := UniformSpace.Completion F
  set e : F →L[𝕜] F' := UniformSpace.Completion.toComplL
  have : AnalyticOn 𝕜 (e ∘ f) U := fun x hx => (e.analytic_at _).comp (hf x hx)
  have A : eq_on (e ∘ f) 0 U :=
    by
    apply eq_on_zero_of_preconnected_of_eventually_eq_zero_aux this hU h₀
    filter_upwards [hfz₀] with x hx
    simp only [hx, Function.comp_apply, Pi.zero_apply, map_zero]
  intro z hz
  have : e (f z) = e 0 := by simpa only using A hz
  exact UniformSpace.Completion.coe_injective F this
#align analytic_on.eq_on_zero_of_preconnected_of_eventually_eq_zero AnalyticOn.eqOn_zero_of_preconnected_of_eventuallyEq_zero
-/

#print AnalyticOn.eqOn_of_preconnected_of_eventuallyEq /-
/-- The *identity principle* for analytic functions: If two analytic functions coincide in a whole
neighborhood of a point `z₀`, then they coincide globally along a connected set.
For a one-dimensional version assuming only that the functions coincide at some points
arbitrarily close to `z₀`, see `eq_on_of_preconnected_of_frequently_eq`. -/
theorem eqOn_of_preconnected_of_eventuallyEq {f g : E → F} {U : Set E} (hf : AnalyticOn 𝕜 f U)
    (hg : AnalyticOn 𝕜 g U) (hU : IsPreconnected U) {z₀ : E} (h₀ : z₀ ∈ U) (hfg : f =ᶠ[𝓝 z₀] g) :
    EqOn f g U := by
  have hfg' : f - g =ᶠ[𝓝 z₀] 0 := hfg.mono fun z h => by simp [h]
  simpa [sub_eq_zero] using fun z hz =>
    (hf.sub hg).eqOn_zero_of_preconnected_of_eventuallyEq_zero hU h₀ hfg' hz
#align analytic_on.eq_on_of_preconnected_of_eventually_eq AnalyticOn.eqOn_of_preconnected_of_eventuallyEq
-/

#print AnalyticOn.eq_of_eventuallyEq /-
/-- The *identity principle* for analytic functions: If two analytic functions on a normed space
coincide in a neighborhood of a point `z₀`, then they coincide everywhere.
For a one-dimensional version assuming only that the functions coincide at some points
arbitrarily close to `z₀`, see `eq_of_frequently_eq`. -/
theorem eq_of_eventuallyEq {f g : E → F} [PreconnectedSpace E] (hf : AnalyticOn 𝕜 f univ)
    (hg : AnalyticOn 𝕜 g univ) {z₀ : E} (hfg : f =ᶠ[𝓝 z₀] g) : f = g :=
  funext fun x =>
    eqOn_of_preconnected_of_eventuallyEq hf hg isPreconnected_univ (mem_univ z₀) hfg (mem_univ x)
#align analytic_on.eq_of_eventually_eq AnalyticOn.eq_of_eventuallyEq
-/

end AnalyticOn

