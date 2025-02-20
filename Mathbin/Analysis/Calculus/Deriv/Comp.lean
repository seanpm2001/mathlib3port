/-
Copyright (c) 2019 Gabriel Ebner. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner, Sébastien Gouëzel, Yury Kudryashov, Yuyang Zhao

! This file was ported from Lean 3 source module analysis.calculus.deriv.comp
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Deriv.Basic
import Mathbin.Analysis.Calculus.Fderiv.Comp
import Mathbin.Analysis.Calculus.Fderiv.RestrictScalars

/-!
# One-dimensional derivatives of compositions of functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove the chain rule for the following cases:

* `has_deriv_at.comp` etc: `f : 𝕜' → 𝕜'` composed with `g : 𝕜 → 𝕜'`;
* `has_deriv_at.scomp` etc: `f : 𝕜' → E` composed with `g : 𝕜 → 𝕜'`;
* `has_fderiv_at.comp_has_deriv_at` etc: `f : E → F` composed with `g : 𝕜 → E`;

Here `𝕜` is the base normed field, `E` and `F` are normed spaces over `𝕜` and `𝕜'` is an algebra
over `𝕜` (e.g., `𝕜'=𝕜` or `𝕜=ℝ`, `𝕜'=ℂ`).

For a more detailed overview of one-dimensional derivatives in mathlib, see the module docstring of
`analysis/calculus/deriv/basic`.

## Keywords

derivative, chain rule
-/


universe u v w

open scoped Classical Topology BigOperators Filter ENNReal

open Filter Asymptotics Set

open ContinuousLinearMap (smul_right smulRight_one_eq_iff)

variable {𝕜 : Type u} [NontriviallyNormedField 𝕜]

variable {F : Type v} [NormedAddCommGroup F] [NormedSpace 𝕜 F]

variable {E : Type w} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

variable {f f₀ f₁ g : 𝕜 → F}

variable {f' f₀' f₁' g' : F}

variable {x : 𝕜}

variable {s t : Set 𝕜}

variable {L L₁ L₂ : Filter 𝕜}

section Composition

/-!
### Derivative of the composition of a vector function and a scalar function

We use `scomp` in lemmas on composition of vector valued and scalar valued functions, and `comp`
in lemmas on composition of scalar valued functions, in analogy for `smul` and `mul` (and also
because the `comp` version with the shorter name will show up much more often in applications).
The formula for the derivative involves `smul` in `scomp` lemmas, which can be reduced to
usual multiplication in `comp` lemmas.
-/


/- For composition lemmas, we put x explicit to help the elaborator, as otherwise Lean tends to
get confused since there are too many possibilities for composition -/
variable {𝕜' : Type _} [NontriviallyNormedField 𝕜'] [NormedAlgebra 𝕜 𝕜'] [NormedSpace 𝕜' F]
  [IsScalarTower 𝕜 𝕜' F] {s' t' : Set 𝕜'} {h : 𝕜 → 𝕜'} {h₁ : 𝕜 → 𝕜} {h₂ : 𝕜' → 𝕜'} {h' h₂' : 𝕜'}
  {h₁' : 𝕜} {g₁ : 𝕜' → F} {g₁' : F} {L' : Filter 𝕜'} (x)

#print HasDerivAtFilter.scomp /-
theorem HasDerivAtFilter.scomp (hg : HasDerivAtFilter g₁ g₁' (h x) L')
    (hh : HasDerivAtFilter h h' x L) (hL : Tendsto h L L') :
    HasDerivAtFilter (g₁ ∘ h) (h' • g₁') x L := by
  simpa using ((hg.restrict_scalars 𝕜).comp x hh hL).HasDerivAtFilter
#align has_deriv_at_filter.scomp HasDerivAtFilter.scomp
-/

#print HasDerivWithinAt.scomp_hasDerivAt /-
theorem HasDerivWithinAt.scomp_hasDerivAt (hg : HasDerivWithinAt g₁ g₁' s' (h x))
    (hh : HasDerivAt h h' x) (hs : ∀ x, h x ∈ s') : HasDerivAt (g₁ ∘ h) (h' • g₁') x :=
  hg.scomp x hh <| tendsto_inf.2 ⟨hh.ContinuousAt, tendsto_principal.2 <| eventually_of_forall hs⟩
#align has_deriv_within_at.scomp_has_deriv_at HasDerivWithinAt.scomp_hasDerivAt
-/

#print HasDerivWithinAt.scomp /-
theorem HasDerivWithinAt.scomp (hg : HasDerivWithinAt g₁ g₁' t' (h x))
    (hh : HasDerivWithinAt h h' s x) (hst : MapsTo h s t') :
    HasDerivWithinAt (g₁ ∘ h) (h' • g₁') s x :=
  hg.scomp x hh <| hh.ContinuousWithinAt.tendsto_nhdsWithin hst
#align has_deriv_within_at.scomp HasDerivWithinAt.scomp
-/

#print HasDerivAt.scomp /-
/-- The chain rule. -/
theorem HasDerivAt.scomp (hg : HasDerivAt g₁ g₁' (h x)) (hh : HasDerivAt h h' x) :
    HasDerivAt (g₁ ∘ h) (h' • g₁') x :=
  hg.scomp x hh hh.ContinuousAt
#align has_deriv_at.scomp HasDerivAt.scomp
-/

#print HasStrictDerivAt.scomp /-
theorem HasStrictDerivAt.scomp (hg : HasStrictDerivAt g₁ g₁' (h x)) (hh : HasStrictDerivAt h h' x) :
    HasStrictDerivAt (g₁ ∘ h) (h' • g₁') x := by
  simpa using ((hg.restrict_scalars 𝕜).comp x hh).HasStrictDerivAt
#align has_strict_deriv_at.scomp HasStrictDerivAt.scomp
-/

#print HasDerivAt.scomp_hasDerivWithinAt /-
theorem HasDerivAt.scomp_hasDerivWithinAt (hg : HasDerivAt g₁ g₁' (h x))
    (hh : HasDerivWithinAt h h' s x) : HasDerivWithinAt (g₁ ∘ h) (h' • g₁') s x :=
  HasDerivWithinAt.scomp x hg.HasDerivWithinAt hh (mapsTo_univ _ _)
#align has_deriv_at.scomp_has_deriv_within_at HasDerivAt.scomp_hasDerivWithinAt
-/

#print derivWithin.scomp /-
theorem derivWithin.scomp (hg : DifferentiableWithinAt 𝕜' g₁ t' (h x))
    (hh : DifferentiableWithinAt 𝕜 h s x) (hs : MapsTo h s t') (hxs : UniqueDiffWithinAt 𝕜 s x) :
    derivWithin (g₁ ∘ h) s x = derivWithin h s x • derivWithin g₁ t' (h x) :=
  (HasDerivWithinAt.scomp x hg.HasDerivWithinAt hh.HasDerivWithinAt hs).derivWithin hxs
#align deriv_within.scomp derivWithin.scomp
-/

#print deriv.scomp /-
theorem deriv.scomp (hg : DifferentiableAt 𝕜' g₁ (h x)) (hh : DifferentiableAt 𝕜 h x) :
    deriv (g₁ ∘ h) x = deriv h x • deriv g₁ (h x) :=
  (HasDerivAt.scomp x hg.HasDerivAt hh.HasDerivAt).deriv
#align deriv.scomp deriv.scomp
-/

/-! ### Derivative of the composition of a scalar and vector functions -/


#print HasDerivAtFilter.comp_hasFDerivAtFilter /-
theorem HasDerivAtFilter.comp_hasFDerivAtFilter {f : E → 𝕜'} {f' : E →L[𝕜] 𝕜'} (x) {L'' : Filter E}
    (hh₂ : HasDerivAtFilter h₂ h₂' (f x) L') (hf : HasFDerivAtFilter f f' x L'')
    (hL : Tendsto f L'' L') : HasFDerivAtFilter (h₂ ∘ f) (h₂' • f') x L'' := by
  convert (hh₂.restrict_scalars 𝕜).comp x hf hL; ext x; simp [mul_comm]
#align has_deriv_at_filter.comp_has_fderiv_at_filter HasDerivAtFilter.comp_hasFDerivAtFilter
-/

#print HasStrictDerivAt.comp_hasStrictFDerivAt /-
theorem HasStrictDerivAt.comp_hasStrictFDerivAt {f : E → 𝕜'} {f' : E →L[𝕜] 𝕜'} (x)
    (hh : HasStrictDerivAt h₂ h₂' (f x)) (hf : HasStrictFDerivAt f f' x) :
    HasStrictFDerivAt (h₂ ∘ f) (h₂' • f') x :=
  by
  rw [HasStrictDerivAt] at hh 
  convert (hh.restrict_scalars 𝕜).comp x hf
  ext x
  simp [mul_comm]
#align has_strict_deriv_at.comp_has_strict_fderiv_at HasStrictDerivAt.comp_hasStrictFDerivAt
-/

#print HasDerivAt.comp_hasFDerivAt /-
theorem HasDerivAt.comp_hasFDerivAt {f : E → 𝕜'} {f' : E →L[𝕜] 𝕜'} (x)
    (hh : HasDerivAt h₂ h₂' (f x)) (hf : HasFDerivAt f f' x) : HasFDerivAt (h₂ ∘ f) (h₂' • f') x :=
  hh.comp_hasFDerivAtFilter x hf hf.ContinuousAt
#align has_deriv_at.comp_has_fderiv_at HasDerivAt.comp_hasFDerivAt
-/

#print HasDerivAt.comp_hasFDerivWithinAt /-
theorem HasDerivAt.comp_hasFDerivWithinAt {f : E → 𝕜'} {f' : E →L[𝕜] 𝕜'} {s} (x)
    (hh : HasDerivAt h₂ h₂' (f x)) (hf : HasFDerivWithinAt f f' s x) :
    HasFDerivWithinAt (h₂ ∘ f) (h₂' • f') s x :=
  hh.comp_hasFDerivAtFilter x hf hf.ContinuousWithinAt
#align has_deriv_at.comp_has_fderiv_within_at HasDerivAt.comp_hasFDerivWithinAt
-/

#print HasDerivWithinAt.comp_hasFDerivWithinAt /-
theorem HasDerivWithinAt.comp_hasFDerivWithinAt {f : E → 𝕜'} {f' : E →L[𝕜] 𝕜'} {s t} (x)
    (hh : HasDerivWithinAt h₂ h₂' t (f x)) (hf : HasFDerivWithinAt f f' s x) (hst : MapsTo f s t) :
    HasFDerivWithinAt (h₂ ∘ f) (h₂' • f') s x :=
  hh.comp_hasFDerivAtFilter x hf <| hf.ContinuousWithinAt.tendsto_nhdsWithin hst
#align has_deriv_within_at.comp_has_fderiv_within_at HasDerivWithinAt.comp_hasFDerivWithinAt
-/

/-! ### Derivative of the composition of two scalar functions -/


#print HasDerivAtFilter.comp /-
theorem HasDerivAtFilter.comp (hh₂ : HasDerivAtFilter h₂ h₂' (h x) L')
    (hh : HasDerivAtFilter h h' x L) (hL : Tendsto h L L') :
    HasDerivAtFilter (h₂ ∘ h) (h₂' * h') x L := by rw [mul_comm]; exact hh₂.scomp x hh hL
#align has_deriv_at_filter.comp HasDerivAtFilter.comp
-/

#print HasDerivWithinAt.comp /-
theorem HasDerivWithinAt.comp (hh₂ : HasDerivWithinAt h₂ h₂' s' (h x))
    (hh : HasDerivWithinAt h h' s x) (hst : MapsTo h s s') :
    HasDerivWithinAt (h₂ ∘ h) (h₂' * h') s x := by rw [mul_comm]; exact hh₂.scomp x hh hst
#align has_deriv_within_at.comp HasDerivWithinAt.comp
-/

#print HasDerivAt.comp /-
/-- The chain rule. -/
theorem HasDerivAt.comp (hh₂ : HasDerivAt h₂ h₂' (h x)) (hh : HasDerivAt h h' x) :
    HasDerivAt (h₂ ∘ h) (h₂' * h') x :=
  hh₂.comp x hh hh.ContinuousAt
#align has_deriv_at.comp HasDerivAt.comp
-/

#print HasStrictDerivAt.comp /-
theorem HasStrictDerivAt.comp (hh₂ : HasStrictDerivAt h₂ h₂' (h x)) (hh : HasStrictDerivAt h h' x) :
    HasStrictDerivAt (h₂ ∘ h) (h₂' * h') x := by rw [mul_comm]; exact hh₂.scomp x hh
#align has_strict_deriv_at.comp HasStrictDerivAt.comp
-/

#print HasDerivAt.comp_hasDerivWithinAt /-
theorem HasDerivAt.comp_hasDerivWithinAt (hh₂ : HasDerivAt h₂ h₂' (h x))
    (hh : HasDerivWithinAt h h' s x) : HasDerivWithinAt (h₂ ∘ h) (h₂' * h') s x :=
  hh₂.HasDerivWithinAt.comp x hh (mapsTo_univ _ _)
#align has_deriv_at.comp_has_deriv_within_at HasDerivAt.comp_hasDerivWithinAt
-/

#print derivWithin.comp /-
theorem derivWithin.comp (hh₂ : DifferentiableWithinAt 𝕜' h₂ s' (h x))
    (hh : DifferentiableWithinAt 𝕜 h s x) (hs : MapsTo h s s') (hxs : UniqueDiffWithinAt 𝕜 s x) :
    derivWithin (h₂ ∘ h) s x = derivWithin h₂ s' (h x) * derivWithin h s x :=
  (hh₂.HasDerivWithinAt.comp x hh.HasDerivWithinAt hs).derivWithin hxs
#align deriv_within.comp derivWithin.comp
-/

#print deriv.comp /-
theorem deriv.comp (hh₂ : DifferentiableAt 𝕜' h₂ (h x)) (hh : DifferentiableAt 𝕜 h x) :
    deriv (h₂ ∘ h) x = deriv h₂ (h x) * deriv h x :=
  (hh₂.HasDerivAt.comp x hh.HasDerivAt).deriv
#align deriv.comp deriv.comp
-/

#print HasDerivAtFilter.iterate /-
protected theorem HasDerivAtFilter.iterate {f : 𝕜 → 𝕜} {f' : 𝕜} (hf : HasDerivAtFilter f f' x L)
    (hL : Tendsto f L L) (hx : f x = x) (n : ℕ) : HasDerivAtFilter (f^[n]) (f' ^ n) x L :=
  by
  have := hf.iterate hL hx n
  rwa [ContinuousLinearMap.smulRight_one_pow] at this 
#align has_deriv_at_filter.iterate HasDerivAtFilter.iterate
-/

#print HasDerivAt.iterate /-
protected theorem HasDerivAt.iterate {f : 𝕜 → 𝕜} {f' : 𝕜} (hf : HasDerivAt f f' x) (hx : f x = x)
    (n : ℕ) : HasDerivAt (f^[n]) (f' ^ n) x :=
  by
  have := HasFDerivAt.iterate hf hx n
  rwa [ContinuousLinearMap.smulRight_one_pow] at this 
#align has_deriv_at.iterate HasDerivAt.iterate
-/

#print HasDerivWithinAt.iterate /-
protected theorem HasDerivWithinAt.iterate {f : 𝕜 → 𝕜} {f' : 𝕜} (hf : HasDerivWithinAt f f' s x)
    (hx : f x = x) (hs : MapsTo f s s) (n : ℕ) : HasDerivWithinAt (f^[n]) (f' ^ n) s x :=
  by
  have := HasFDerivWithinAt.iterate hf hx hs n
  rwa [ContinuousLinearMap.smulRight_one_pow] at this 
#align has_deriv_within_at.iterate HasDerivWithinAt.iterate
-/

#print HasStrictDerivAt.iterate /-
protected theorem HasStrictDerivAt.iterate {f : 𝕜 → 𝕜} {f' : 𝕜} (hf : HasStrictDerivAt f f' x)
    (hx : f x = x) (n : ℕ) : HasStrictDerivAt (f^[n]) (f' ^ n) x :=
  by
  have := hf.iterate hx n
  rwa [ContinuousLinearMap.smulRight_one_pow] at this 
#align has_strict_deriv_at.iterate HasStrictDerivAt.iterate
-/

end Composition

section CompositionVector

/-! ### Derivative of the composition of a function between vector spaces and a function on `𝕜` -/


open ContinuousLinearMap

variable {l : F → E} {l' : F →L[𝕜] E}

variable (x)

#print HasFDerivWithinAt.comp_hasDerivWithinAt /-
/-- The composition `l ∘ f` where `l : F → E` and `f : 𝕜 → F`, has a derivative within a set
equal to the Fréchet derivative of `l` applied to the derivative of `f`. -/
theorem HasFDerivWithinAt.comp_hasDerivWithinAt {t : Set F} (hl : HasFDerivWithinAt l l' t (f x))
    (hf : HasDerivWithinAt f f' s x) (hst : MapsTo f s t) : HasDerivWithinAt (l ∘ f) (l' f') s x :=
  by
  simpa only [one_apply, one_smul, smul_right_apply, coe_comp', (· ∘ ·)] using
    (hl.comp x hf.has_fderiv_within_at hst).HasDerivWithinAt
#align has_fderiv_within_at.comp_has_deriv_within_at HasFDerivWithinAt.comp_hasDerivWithinAt
-/

#print HasFDerivAt.comp_hasDerivWithinAt /-
theorem HasFDerivAt.comp_hasDerivWithinAt (hl : HasFDerivAt l l' (f x))
    (hf : HasDerivWithinAt f f' s x) : HasDerivWithinAt (l ∘ f) (l' f') s x :=
  hl.HasFDerivWithinAt.comp_hasDerivWithinAt x hf (mapsTo_univ _ _)
#align has_fderiv_at.comp_has_deriv_within_at HasFDerivAt.comp_hasDerivWithinAt
-/

#print HasFDerivAt.comp_hasDerivAt /-
/-- The composition `l ∘ f` where `l : F → E` and `f : 𝕜 → F`, has a derivative equal to the
Fréchet derivative of `l` applied to the derivative of `f`. -/
theorem HasFDerivAt.comp_hasDerivAt (hl : HasFDerivAt l l' (f x)) (hf : HasDerivAt f f' x) :
    HasDerivAt (l ∘ f) (l' f') x :=
  hasDerivWithinAt_univ.mp <| hl.comp_hasDerivWithinAt x hf.HasDerivWithinAt
#align has_fderiv_at.comp_has_deriv_at HasFDerivAt.comp_hasDerivAt
-/

#print HasStrictFDerivAt.comp_hasStrictDerivAt /-
theorem HasStrictFDerivAt.comp_hasStrictDerivAt (hl : HasStrictFDerivAt l l' (f x))
    (hf : HasStrictDerivAt f f' x) : HasStrictDerivAt (l ∘ f) (l' f') x := by
  simpa only [one_apply, one_smul, smul_right_apply, coe_comp', (· ∘ ·)] using
    (hl.comp x hf.has_strict_fderiv_at).HasStrictDerivAt
#align has_strict_fderiv_at.comp_has_strict_deriv_at HasStrictFDerivAt.comp_hasStrictDerivAt
-/

#print fderivWithin.comp_derivWithin /-
theorem fderivWithin.comp_derivWithin {t : Set F} (hl : DifferentiableWithinAt 𝕜 l t (f x))
    (hf : DifferentiableWithinAt 𝕜 f s x) (hs : MapsTo f s t) (hxs : UniqueDiffWithinAt 𝕜 s x) :
    derivWithin (l ∘ f) s x = (fderivWithin 𝕜 l t (f x) : F → E) (derivWithin f s x) :=
  (hl.HasFDerivWithinAt.comp_hasDerivWithinAt x hf.HasDerivWithinAt hs).derivWithin hxs
#align fderiv_within.comp_deriv_within fderivWithin.comp_derivWithin
-/

#print fderiv.comp_deriv /-
theorem fderiv.comp_deriv (hl : DifferentiableAt 𝕜 l (f x)) (hf : DifferentiableAt 𝕜 f x) :
    deriv (l ∘ f) x = (fderiv 𝕜 l (f x) : F → E) (deriv f x) :=
  (hl.HasFDerivAt.comp_hasDerivAt x hf.HasDerivAt).deriv
#align fderiv.comp_deriv fderiv.comp_deriv
-/

end CompositionVector

