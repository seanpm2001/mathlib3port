/-
Copyright (c) 2023 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module analysis.calculus.fderiv.star
! leanprover-community/mathlib commit a87d22575d946e1e156fc1edd1e1269600a8a282
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Fderiv.Linear
import Mathbin.Analysis.Calculus.Fderiv.Comp
import Mathbin.Analysis.Calculus.Fderiv.Equiv
import Mathbin.Analysis.NormedSpace.Star.Basic

/-!
# Star operations on derivatives

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For detailed documentation of the Fréchet derivative,
see the module docstring of `analysis/calculus/fderiv/basic.lean`.

This file contains the usual formulas (and existence assertions) for the derivative of the star
operation. Note that these only apply when the field that the derivative is respect to has a trivial
star operation; which as should be expected rules out `𝕜 = ℂ`.
-/


open scoped Classical

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] [StarRing 𝕜] [TrivialStar 𝕜]

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

variable {F : Type _} [NormedAddCommGroup F] [StarAddMonoid F] [NormedSpace 𝕜 F] [StarModule 𝕜 F]
  [ContinuousStar F]

variable {f : E → F}

variable {f' : E →L[𝕜] F}

variable (e : E →L[𝕜] F)

variable {x : E}

variable {s : Set E}

variable {L : Filter E}

#print HasStrictFDerivAt.star /-
theorem HasStrictFDerivAt.star (h : HasStrictFDerivAt f f' x) :
    HasStrictFDerivAt (fun x => star (f x)) (((starL' 𝕜 : F ≃L[𝕜] F) : F →L[𝕜] F) ∘L f') x :=
  (starL' 𝕜 : F ≃L[𝕜] F).toContinuousLinearMap.HasStrictFDerivAt.comp x h
#align has_strict_fderiv_at.star HasStrictFDerivAt.star
-/

#print HasFDerivAtFilter.star /-
theorem HasFDerivAtFilter.star (h : HasFDerivAtFilter f f' x L) :
    HasFDerivAtFilter (fun x => star (f x)) (((starL' 𝕜 : F ≃L[𝕜] F) : F →L[𝕜] F) ∘L f') x L :=
  (starL' 𝕜 : F ≃L[𝕜] F).toContinuousLinearMap.HasFDerivAtFilter.comp x h Filter.tendsto_map
#align has_fderiv_at_filter.star HasFDerivAtFilter.star
-/

#print HasFDerivWithinAt.star /-
theorem HasFDerivWithinAt.star (h : HasFDerivWithinAt f f' s x) :
    HasFDerivWithinAt (fun x => star (f x)) (((starL' 𝕜 : F ≃L[𝕜] F) : F →L[𝕜] F) ∘L f') s x :=
  h.unit
#align has_fderiv_within_at.star HasFDerivWithinAt.star
-/

#print HasFDerivAt.star /-
theorem HasFDerivAt.star (h : HasFDerivAt f f' x) :
    HasFDerivAt (fun x => star (f x)) (((starL' 𝕜 : F ≃L[𝕜] F) : F →L[𝕜] F) ∘L f') x :=
  h.unit
#align has_fderiv_at.star HasFDerivAt.star
-/

#print DifferentiableWithinAt.star /-
theorem DifferentiableWithinAt.star (h : DifferentiableWithinAt 𝕜 f s x) :
    DifferentiableWithinAt 𝕜 (fun y => star (f y)) s x :=
  h.HasFDerivWithinAt.unit.DifferentiableWithinAt
#align differentiable_within_at.star DifferentiableWithinAt.star
-/

#print differentiableWithinAt_star_iff /-
@[simp]
theorem differentiableWithinAt_star_iff :
    DifferentiableWithinAt 𝕜 (fun y => star (f y)) s x ↔ DifferentiableWithinAt 𝕜 f s x :=
  (starL' 𝕜 : F ≃L[𝕜] F).comp_differentiableWithinAt_iff
#align differentiable_within_at_star_iff differentiableWithinAt_star_iff
-/

#print DifferentiableAt.star /-
theorem DifferentiableAt.star (h : DifferentiableAt 𝕜 f x) :
    DifferentiableAt 𝕜 (fun y => star (f y)) x :=
  h.HasFDerivAt.unit.DifferentiableAt
#align differentiable_at.star DifferentiableAt.star
-/

#print differentiableAt_star_iff /-
@[simp]
theorem differentiableAt_star_iff :
    DifferentiableAt 𝕜 (fun y => star (f y)) x ↔ DifferentiableAt 𝕜 f x :=
  (starL' 𝕜 : F ≃L[𝕜] F).comp_differentiableAt_iff
#align differentiable_at_star_iff differentiableAt_star_iff
-/

#print DifferentiableOn.star /-
theorem DifferentiableOn.star (h : DifferentiableOn 𝕜 f s) :
    DifferentiableOn 𝕜 (fun y => star (f y)) s := fun x hx => (h x hx).unit
#align differentiable_on.star DifferentiableOn.star
-/

#print differentiableOn_star_iff /-
@[simp]
theorem differentiableOn_star_iff :
    DifferentiableOn 𝕜 (fun y => star (f y)) s ↔ DifferentiableOn 𝕜 f s :=
  (starL' 𝕜 : F ≃L[𝕜] F).comp_differentiableOn_iff
#align differentiable_on_star_iff differentiableOn_star_iff
-/

#print Differentiable.star /-
theorem Differentiable.star (h : Differentiable 𝕜 f) : Differentiable 𝕜 fun y => star (f y) :=
  fun x => (h x).unit
#align differentiable.star Differentiable.star
-/

#print differentiable_star_iff /-
@[simp]
theorem differentiable_star_iff : (Differentiable 𝕜 fun y => star (f y)) ↔ Differentiable 𝕜 f :=
  (starL' 𝕜 : F ≃L[𝕜] F).comp_differentiable_iff
#align differentiable_star_iff differentiable_star_iff
-/

#print fderivWithin_star /-
theorem fderivWithin_star (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (fun y => star (f y)) s x =
      ((starL' 𝕜 : F ≃L[𝕜] F) : F →L[𝕜] F) ∘L fderivWithin 𝕜 f s x :=
  (starL' 𝕜 : F ≃L[𝕜] F).comp_fderivWithin hxs
#align fderiv_within_star fderivWithin_star
-/

#print fderiv_star /-
@[simp]
theorem fderiv_star :
    fderiv 𝕜 (fun y => star (f y)) x = ((starL' 𝕜 : F ≃L[𝕜] F) : F →L[𝕜] F) ∘L fderiv 𝕜 f x :=
  (starL' 𝕜 : F ≃L[𝕜] F).comp_fderiv
#align fderiv_star fderiv_star
-/

