/-
Copyright (c) 2019 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Sébastien Gouëzel, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.fderiv.restrict_scalars
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Fderiv.Basic

/-!
# The derivative of the scalar restriction of a linear map

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For detailed documentation of the Fréchet derivative,
see the module docstring of `analysis/calculus/fderiv/basic.lean`.

This file contains the usual formulas (and existence assertions) for the derivative of
the scalar restriction of a linear map.
-/


open Filter Asymptotics ContinuousLinearMap Set Metric

open scoped Topology Classical NNReal Filter Asymptotics ENNReal

noncomputable section

section RestrictScalars

/-!
### Restricting from `ℂ` to `ℝ`, or generally from `𝕜'` to `𝕜`

If a function is differentiable over `ℂ`, then it is differentiable over `ℝ`. In this paragraph,
we give variants of this statement, in the general situation where `ℂ` and `ℝ` are replaced
respectively by `𝕜'` and `𝕜` where `𝕜'` is a normed algebra over `𝕜`.
-/


variable (𝕜 : Type _) [NontriviallyNormedField 𝕜]

variable {𝕜' : Type _} [NontriviallyNormedField 𝕜'] [NormedAlgebra 𝕜 𝕜']

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E] [NormedSpace 𝕜' E]

variable [IsScalarTower 𝕜 𝕜' E]

variable {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F] [NormedSpace 𝕜' F]

variable [IsScalarTower 𝕜 𝕜' F]

variable {f : E → F} {f' : E →L[𝕜'] F} {s : Set E} {x : E}

#print HasStrictFDerivAt.restrictScalars /-
theorem HasStrictFDerivAt.restrictScalars (h : HasStrictFDerivAt f f' x) :
    HasStrictFDerivAt f (f'.restrictScalars 𝕜) x :=
  h
#align has_strict_fderiv_at.restrict_scalars HasStrictFDerivAt.restrictScalars
-/

#print HasFDerivAtFilter.restrictScalars /-
theorem HasFDerivAtFilter.restrictScalars {L} (h : HasFDerivAtFilter f f' x L) :
    HasFDerivAtFilter f (f'.restrictScalars 𝕜) x L :=
  h
#align has_fderiv_at_filter.restrict_scalars HasFDerivAtFilter.restrictScalars
-/

#print HasFDerivAt.restrictScalars /-
theorem HasFDerivAt.restrictScalars (h : HasFDerivAt f f' x) :
    HasFDerivAt f (f'.restrictScalars 𝕜) x :=
  h
#align has_fderiv_at.restrict_scalars HasFDerivAt.restrictScalars
-/

#print HasFDerivWithinAt.restrictScalars /-
theorem HasFDerivWithinAt.restrictScalars (h : HasFDerivWithinAt f f' s x) :
    HasFDerivWithinAt f (f'.restrictScalars 𝕜) s x :=
  h
#align has_fderiv_within_at.restrict_scalars HasFDerivWithinAt.restrictScalars
-/

#print DifferentiableAt.restrictScalars /-
theorem DifferentiableAt.restrictScalars (h : DifferentiableAt 𝕜' f x) : DifferentiableAt 𝕜 f x :=
  (h.HasFDerivAt.restrictScalars 𝕜).DifferentiableAt
#align differentiable_at.restrict_scalars DifferentiableAt.restrictScalars
-/

#print DifferentiableWithinAt.restrictScalars /-
theorem DifferentiableWithinAt.restrictScalars (h : DifferentiableWithinAt 𝕜' f s x) :
    DifferentiableWithinAt 𝕜 f s x :=
  (h.HasFDerivWithinAt.restrictScalars 𝕜).DifferentiableWithinAt
#align differentiable_within_at.restrict_scalars DifferentiableWithinAt.restrictScalars
-/

#print DifferentiableOn.restrictScalars /-
theorem DifferentiableOn.restrictScalars (h : DifferentiableOn 𝕜' f s) : DifferentiableOn 𝕜 f s :=
  fun x hx => (h x hx).restrictScalars 𝕜
#align differentiable_on.restrict_scalars DifferentiableOn.restrictScalars
-/

#print Differentiable.restrictScalars /-
theorem Differentiable.restrictScalars (h : Differentiable 𝕜' f) : Differentiable 𝕜 f := fun x =>
  (h x).restrictScalars 𝕜
#align differentiable.restrict_scalars Differentiable.restrictScalars
-/

#print hasFDerivWithinAt_of_restrictScalars /-
theorem hasFDerivWithinAt_of_restrictScalars {g' : E →L[𝕜] F} (h : HasFDerivWithinAt f g' s x)
    (H : f'.restrictScalars 𝕜 = g') : HasFDerivWithinAt f f' s x := by rw [← H] at h ; exact h
#align has_fderiv_within_at_of_restrict_scalars hasFDerivWithinAt_of_restrictScalars
-/

#print hasFDerivAt_of_restrictScalars /-
theorem hasFDerivAt_of_restrictScalars {g' : E →L[𝕜] F} (h : HasFDerivAt f g' x)
    (H : f'.restrictScalars 𝕜 = g') : HasFDerivAt f f' x := by rw [← H] at h ; exact h
#align has_fderiv_at_of_restrict_scalars hasFDerivAt_of_restrictScalars
-/

#print DifferentiableAt.fderiv_restrictScalars /-
theorem DifferentiableAt.fderiv_restrictScalars (h : DifferentiableAt 𝕜' f x) :
    fderiv 𝕜 f x = (fderiv 𝕜' f x).restrictScalars 𝕜 :=
  (h.HasFDerivAt.restrictScalars 𝕜).fderiv
#align differentiable_at.fderiv_restrict_scalars DifferentiableAt.fderiv_restrictScalars
-/

#print differentiableWithinAt_iff_restrictScalars /-
theorem differentiableWithinAt_iff_restrictScalars (hf : DifferentiableWithinAt 𝕜 f s x)
    (hs : UniqueDiffWithinAt 𝕜 s x) :
    DifferentiableWithinAt 𝕜' f s x ↔
      ∃ g' : E →L[𝕜'] F, g'.restrictScalars 𝕜 = fderivWithin 𝕜 f s x :=
  by
  constructor
  · rintro ⟨g', hg'⟩
    exact ⟨g', hs.eq (hg'.restrict_scalars 𝕜) hf.has_fderiv_within_at⟩
  · rintro ⟨f', hf'⟩
    exact ⟨f', hasFDerivWithinAt_of_restrictScalars 𝕜 hf.has_fderiv_within_at hf'⟩
#align differentiable_within_at_iff_restrict_scalars differentiableWithinAt_iff_restrictScalars
-/

#print differentiableAt_iff_restrictScalars /-
theorem differentiableAt_iff_restrictScalars (hf : DifferentiableAt 𝕜 f x) :
    DifferentiableAt 𝕜' f x ↔ ∃ g' : E →L[𝕜'] F, g'.restrictScalars 𝕜 = fderiv 𝕜 f x :=
  by
  rw [← differentiableWithinAt_univ, ← fderivWithin_univ]
  exact
    differentiableWithinAt_iff_restrictScalars 𝕜 hf.differentiable_within_at uniqueDiffWithinAt_univ
#align differentiable_at_iff_restrict_scalars differentiableAt_iff_restrictScalars
-/

end RestrictScalars

