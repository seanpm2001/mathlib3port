/-
Copyright (c) 2019 Gabriel Ebner. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.deriv.prod
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Deriv.Basic
import Mathbin.Analysis.Calculus.Fderiv.Prod

/-!
# Derivatives of functions taking values in product types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove lemmas about derivatives of functions `f : 𝕜 → E × F` and of functions
`f : 𝕜 → (Π i, E i)`.

For a more detailed overview of one-dimensional derivatives in mathlib, see the module docstring of
`analysis/calculus/deriv/basic`.

## Keywords

derivative
-/


universe u v w

open scoped Classical Topology BigOperators Filter

open Filter Asymptotics Set

variable {𝕜 : Type u} [NontriviallyNormedField 𝕜]

variable {F : Type v} [NormedAddCommGroup F] [NormedSpace 𝕜 F]

variable {E : Type w} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

variable {f f₀ f₁ g : 𝕜 → F}

variable {f' f₀' f₁' g' : F}

variable {x : 𝕜}

variable {s t : Set 𝕜}

variable {L L₁ L₂ : Filter 𝕜}

section CartesianProduct

/-! ### Derivative of the cartesian product of two functions -/


variable {G : Type w} [NormedAddCommGroup G] [NormedSpace 𝕜 G]

variable {f₂ : 𝕜 → G} {f₂' : G}

#print HasDerivAtFilter.prod /-
theorem HasDerivAtFilter.prod (hf₁ : HasDerivAtFilter f₁ f₁' x L)
    (hf₂ : HasDerivAtFilter f₂ f₂' x L) : HasDerivAtFilter (fun x => (f₁ x, f₂ x)) (f₁', f₂') x L :=
  hf₁.Prod hf₂
#align has_deriv_at_filter.prod HasDerivAtFilter.prod
-/

#print HasDerivWithinAt.prod /-
theorem HasDerivWithinAt.prod (hf₁ : HasDerivWithinAt f₁ f₁' s x)
    (hf₂ : HasDerivWithinAt f₂ f₂' s x) : HasDerivWithinAt (fun x => (f₁ x, f₂ x)) (f₁', f₂') s x :=
  hf₁.Prod hf₂
#align has_deriv_within_at.prod HasDerivWithinAt.prod
-/

#print HasDerivAt.prod /-
theorem HasDerivAt.prod (hf₁ : HasDerivAt f₁ f₁' x) (hf₂ : HasDerivAt f₂ f₂' x) :
    HasDerivAt (fun x => (f₁ x, f₂ x)) (f₁', f₂') x :=
  hf₁.Prod hf₂
#align has_deriv_at.prod HasDerivAt.prod
-/

#print HasStrictDerivAt.prod /-
theorem HasStrictDerivAt.prod (hf₁ : HasStrictDerivAt f₁ f₁' x) (hf₂ : HasStrictDerivAt f₂ f₂' x) :
    HasStrictDerivAt (fun x => (f₁ x, f₂ x)) (f₁', f₂') x :=
  hf₁.Prod hf₂
#align has_strict_deriv_at.prod HasStrictDerivAt.prod
-/

end CartesianProduct

section Pi

/-! ### Derivatives of functions `f : 𝕜 → Π i, E i` -/


variable {ι : Type _} [Fintype ι] {E' : ι → Type _} [∀ i, NormedAddCommGroup (E' i)]
  [∀ i, NormedSpace 𝕜 (E' i)] {φ : 𝕜 → ∀ i, E' i} {φ' : ∀ i, E' i}

#print hasStrictDerivAt_pi /-
@[simp]
theorem hasStrictDerivAt_pi :
    HasStrictDerivAt φ φ' x ↔ ∀ i, HasStrictDerivAt (fun x => φ x i) (φ' i) x :=
  hasStrictFDerivAt_pi'
#align has_strict_deriv_at_pi hasStrictDerivAt_pi
-/

#print hasDerivAtFilter_pi /-
@[simp]
theorem hasDerivAtFilter_pi :
    HasDerivAtFilter φ φ' x L ↔ ∀ i, HasDerivAtFilter (fun x => φ x i) (φ' i) x L :=
  hasFDerivAtFilter_pi'
#align has_deriv_at_filter_pi hasDerivAtFilter_pi
-/

#print hasDerivAt_pi /-
theorem hasDerivAt_pi : HasDerivAt φ φ' x ↔ ∀ i, HasDerivAt (fun x => φ x i) (φ' i) x :=
  hasDerivAtFilter_pi
#align has_deriv_at_pi hasDerivAt_pi
-/

#print hasDerivWithinAt_pi /-
theorem hasDerivWithinAt_pi :
    HasDerivWithinAt φ φ' s x ↔ ∀ i, HasDerivWithinAt (fun x => φ x i) (φ' i) s x :=
  hasDerivAtFilter_pi
#align has_deriv_within_at_pi hasDerivWithinAt_pi
-/

#print derivWithin_pi /-
theorem derivWithin_pi (h : ∀ i, DifferentiableWithinAt 𝕜 (fun x => φ x i) s x)
    (hs : UniqueDiffWithinAt 𝕜 s x) :
    derivWithin φ s x = fun i => derivWithin (fun x => φ x i) s x :=
  (hasDerivWithinAt_pi.2 fun i => (h i).HasDerivWithinAt).derivWithin hs
#align deriv_within_pi derivWithin_pi
-/

#print deriv_pi /-
theorem deriv_pi (h : ∀ i, DifferentiableAt 𝕜 (fun x => φ x i) x) :
    deriv φ x = fun i => deriv (fun x => φ x i) x :=
  (hasDerivAt_pi.2 fun i => (h i).HasDerivAt).deriv
#align deriv_pi deriv_pi
-/

end Pi

