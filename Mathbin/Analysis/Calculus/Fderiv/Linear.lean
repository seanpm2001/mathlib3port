/-
Copyright (c) 2019 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Sébastien Gouëzel, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.fderiv.linear
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Fderiv.Basic

/-!
# The derivative of bounded linear maps

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For detailed documentation of the Fréchet derivative,
see the module docstring of `analysis/calculus/fderiv/basic.lean`.

This file contains the usual formulas (and existence assertions) for the derivative of
bounded linear maps.
-/


open Filter Asymptotics ContinuousLinearMap Set Metric

open scoped Topology Classical NNReal Filter Asymptotics ENNReal

noncomputable section

section

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜]

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

variable {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F]

variable {G : Type _} [NormedAddCommGroup G] [NormedSpace 𝕜 G]

variable {G' : Type _} [NormedAddCommGroup G'] [NormedSpace 𝕜 G']

variable {f f₀ f₁ g : E → F}

variable {f' f₀' f₁' g' : E →L[𝕜] F}

variable (e : E →L[𝕜] F)

variable {x : E}

variable {s t : Set E}

variable {L L₁ L₂ : Filter E}

section ContinuousLinearMap

/-!
### Continuous linear maps

There are currently two variants of these in mathlib, the bundled version
(named `continuous_linear_map`, and denoted `E →L[𝕜] F`), and the unbundled version (with a
predicate `is_bounded_linear_map`). We give statements for both versions. -/


#print ContinuousLinearMap.hasStrictFDerivAt /-
protected theorem ContinuousLinearMap.hasStrictFDerivAt {x : E} : HasStrictFDerivAt e e x :=
  (isLittleO_zero _ _).congr_left fun x => by simp only [e.map_sub, sub_self]
#align continuous_linear_map.has_strict_fderiv_at ContinuousLinearMap.hasStrictFDerivAt
-/

#print ContinuousLinearMap.hasFDerivAtFilter /-
protected theorem ContinuousLinearMap.hasFDerivAtFilter : HasFDerivAtFilter e e x L :=
  (isLittleO_zero _ _).congr_left fun x => by simp only [e.map_sub, sub_self]
#align continuous_linear_map.has_fderiv_at_filter ContinuousLinearMap.hasFDerivAtFilter
-/

#print ContinuousLinearMap.hasFDerivWithinAt /-
protected theorem ContinuousLinearMap.hasFDerivWithinAt : HasFDerivWithinAt e e s x :=
  e.HasFDerivAtFilter
#align continuous_linear_map.has_fderiv_within_at ContinuousLinearMap.hasFDerivWithinAt
-/

#print ContinuousLinearMap.hasFDerivAt /-
protected theorem ContinuousLinearMap.hasFDerivAt : HasFDerivAt e e x :=
  e.HasFDerivAtFilter
#align continuous_linear_map.has_fderiv_at ContinuousLinearMap.hasFDerivAt
-/

#print ContinuousLinearMap.differentiableAt /-
@[simp]
protected theorem ContinuousLinearMap.differentiableAt : DifferentiableAt 𝕜 e x :=
  e.HasFDerivAt.DifferentiableAt
#align continuous_linear_map.differentiable_at ContinuousLinearMap.differentiableAt
-/

#print ContinuousLinearMap.differentiableWithinAt /-
protected theorem ContinuousLinearMap.differentiableWithinAt : DifferentiableWithinAt 𝕜 e s x :=
  e.DifferentiableAt.DifferentiableWithinAt
#align continuous_linear_map.differentiable_within_at ContinuousLinearMap.differentiableWithinAt
-/

#print ContinuousLinearMap.fderiv /-
@[simp]
protected theorem ContinuousLinearMap.fderiv : fderiv 𝕜 e x = e :=
  e.HasFDerivAt.fderiv
#align continuous_linear_map.fderiv ContinuousLinearMap.fderiv
-/

#print ContinuousLinearMap.fderivWithin /-
protected theorem ContinuousLinearMap.fderivWithin (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 e s x = e :=
  by
  rw [DifferentiableAt.fderivWithin e.differentiable_at hxs]
  exact e.fderiv
#align continuous_linear_map.fderiv_within ContinuousLinearMap.fderivWithin
-/

#print ContinuousLinearMap.differentiable /-
@[simp]
protected theorem ContinuousLinearMap.differentiable : Differentiable 𝕜 e := fun x =>
  e.DifferentiableAt
#align continuous_linear_map.differentiable ContinuousLinearMap.differentiable
-/

#print ContinuousLinearMap.differentiableOn /-
protected theorem ContinuousLinearMap.differentiableOn : DifferentiableOn 𝕜 e s :=
  e.Differentiable.DifferentiableOn
#align continuous_linear_map.differentiable_on ContinuousLinearMap.differentiableOn
-/

#print IsBoundedLinearMap.hasFDerivAtFilter /-
theorem IsBoundedLinearMap.hasFDerivAtFilter (h : IsBoundedLinearMap 𝕜 f) :
    HasFDerivAtFilter f h.toContinuousLinearMap x L :=
  h.toContinuousLinearMap.HasFDerivAtFilter
#align is_bounded_linear_map.has_fderiv_at_filter IsBoundedLinearMap.hasFDerivAtFilter
-/

#print IsBoundedLinearMap.hasFDerivWithinAt /-
theorem IsBoundedLinearMap.hasFDerivWithinAt (h : IsBoundedLinearMap 𝕜 f) :
    HasFDerivWithinAt f h.toContinuousLinearMap s x :=
  h.HasFDerivAtFilter
#align is_bounded_linear_map.has_fderiv_within_at IsBoundedLinearMap.hasFDerivWithinAt
-/

#print IsBoundedLinearMap.hasFDerivAt /-
theorem IsBoundedLinearMap.hasFDerivAt (h : IsBoundedLinearMap 𝕜 f) :
    HasFDerivAt f h.toContinuousLinearMap x :=
  h.HasFDerivAtFilter
#align is_bounded_linear_map.has_fderiv_at IsBoundedLinearMap.hasFDerivAt
-/

#print IsBoundedLinearMap.differentiableAt /-
theorem IsBoundedLinearMap.differentiableAt (h : IsBoundedLinearMap 𝕜 f) : DifferentiableAt 𝕜 f x :=
  h.HasFDerivAt.DifferentiableAt
#align is_bounded_linear_map.differentiable_at IsBoundedLinearMap.differentiableAt
-/

#print IsBoundedLinearMap.differentiableWithinAt /-
theorem IsBoundedLinearMap.differentiableWithinAt (h : IsBoundedLinearMap 𝕜 f) :
    DifferentiableWithinAt 𝕜 f s x :=
  h.DifferentiableAt.DifferentiableWithinAt
#align is_bounded_linear_map.differentiable_within_at IsBoundedLinearMap.differentiableWithinAt
-/

#print IsBoundedLinearMap.fderiv /-
theorem IsBoundedLinearMap.fderiv (h : IsBoundedLinearMap 𝕜 f) :
    fderiv 𝕜 f x = h.toContinuousLinearMap :=
  HasFDerivAt.fderiv h.HasFDerivAt
#align is_bounded_linear_map.fderiv IsBoundedLinearMap.fderiv
-/

#print IsBoundedLinearMap.fderivWithin /-
theorem IsBoundedLinearMap.fderivWithin (h : IsBoundedLinearMap 𝕜 f)
    (hxs : UniqueDiffWithinAt 𝕜 s x) : fderivWithin 𝕜 f s x = h.toContinuousLinearMap :=
  by
  rw [DifferentiableAt.fderivWithin h.differentiable_at hxs]
  exact h.fderiv
#align is_bounded_linear_map.fderiv_within IsBoundedLinearMap.fderivWithin
-/

#print IsBoundedLinearMap.differentiable /-
theorem IsBoundedLinearMap.differentiable (h : IsBoundedLinearMap 𝕜 f) : Differentiable 𝕜 f :=
  fun x => h.DifferentiableAt
#align is_bounded_linear_map.differentiable IsBoundedLinearMap.differentiable
-/

#print IsBoundedLinearMap.differentiableOn /-
theorem IsBoundedLinearMap.differentiableOn (h : IsBoundedLinearMap 𝕜 f) : DifferentiableOn 𝕜 f s :=
  h.Differentiable.DifferentiableOn
#align is_bounded_linear_map.differentiable_on IsBoundedLinearMap.differentiableOn
-/

end ContinuousLinearMap

end

