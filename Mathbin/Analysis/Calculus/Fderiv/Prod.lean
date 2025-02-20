/-
Copyright (c) 2019 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Sébastien Gouëzel, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.fderiv.prod
! leanprover-community/mathlib commit e354e865255654389cc46e6032160238df2e0f40
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Fderiv.Linear
import Mathbin.Analysis.Calculus.Fderiv.Comp

/-!
# Derivative of the cartesian product of functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For detailed documentation of the Fréchet derivative,
see the module docstring of `analysis/calculus/fderiv/basic.lean`.

This file contains the usual formulas (and existence assertions) for the derivative of
cartesian products of functions, and functions into Pi-types.
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

section CartesianProduct

/-! ### Derivative of the cartesian product of two functions -/


section Prod

variable {f₂ : E → G} {f₂' : E →L[𝕜] G}

#print HasStrictFDerivAt.prod /-
protected theorem HasStrictFDerivAt.prod (hf₁ : HasStrictFDerivAt f₁ f₁' x)
    (hf₂ : HasStrictFDerivAt f₂ f₂' x) :
    HasStrictFDerivAt (fun x => (f₁ x, f₂ x)) (f₁'.Prod f₂') x :=
  hf₁.prodLeft hf₂
#align has_strict_fderiv_at.prod HasStrictFDerivAt.prod
-/

#print HasFDerivAtFilter.prod /-
theorem HasFDerivAtFilter.prod (hf₁ : HasFDerivAtFilter f₁ f₁' x L)
    (hf₂ : HasFDerivAtFilter f₂ f₂' x L) :
    HasFDerivAtFilter (fun x => (f₁ x, f₂ x)) (f₁'.Prod f₂') x L :=
  hf₁.prodLeft hf₂
#align has_fderiv_at_filter.prod HasFDerivAtFilter.prod
-/

#print HasFDerivWithinAt.prod /-
theorem HasFDerivWithinAt.prod (hf₁ : HasFDerivWithinAt f₁ f₁' s x)
    (hf₂ : HasFDerivWithinAt f₂ f₂' s x) :
    HasFDerivWithinAt (fun x => (f₁ x, f₂ x)) (f₁'.Prod f₂') s x :=
  hf₁.Prod hf₂
#align has_fderiv_within_at.prod HasFDerivWithinAt.prod
-/

#print HasFDerivAt.prod /-
theorem HasFDerivAt.prod (hf₁ : HasFDerivAt f₁ f₁' x) (hf₂ : HasFDerivAt f₂ f₂' x) :
    HasFDerivAt (fun x => (f₁ x, f₂ x)) (f₁'.Prod f₂') x :=
  hf₁.Prod hf₂
#align has_fderiv_at.prod HasFDerivAt.prod
-/

#print hasFDerivAt_prod_mk_left /-
theorem hasFDerivAt_prod_mk_left (e₀ : E) (f₀ : F) :
    HasFDerivAt (fun e : E => (e, f₀)) (inl 𝕜 E F) e₀ :=
  (hasFDerivAt_id e₀).Prod (hasFDerivAt_const f₀ e₀)
#align has_fderiv_at_prod_mk_left hasFDerivAt_prod_mk_left
-/

#print hasFDerivAt_prod_mk_right /-
theorem hasFDerivAt_prod_mk_right (e₀ : E) (f₀ : F) :
    HasFDerivAt (fun f : F => (e₀, f)) (inr 𝕜 E F) f₀ :=
  (hasFDerivAt_const e₀ f₀).Prod (hasFDerivAt_id f₀)
#align has_fderiv_at_prod_mk_right hasFDerivAt_prod_mk_right
-/

#print DifferentiableWithinAt.prod /-
theorem DifferentiableWithinAt.prod (hf₁ : DifferentiableWithinAt 𝕜 f₁ s x)
    (hf₂ : DifferentiableWithinAt 𝕜 f₂ s x) :
    DifferentiableWithinAt 𝕜 (fun x : E => (f₁ x, f₂ x)) s x :=
  (hf₁.HasFDerivWithinAt.Prod hf₂.HasFDerivWithinAt).DifferentiableWithinAt
#align differentiable_within_at.prod DifferentiableWithinAt.prod
-/

#print DifferentiableAt.prod /-
@[simp]
theorem DifferentiableAt.prod (hf₁ : DifferentiableAt 𝕜 f₁ x) (hf₂ : DifferentiableAt 𝕜 f₂ x) :
    DifferentiableAt 𝕜 (fun x : E => (f₁ x, f₂ x)) x :=
  (hf₁.HasFDerivAt.Prod hf₂.HasFDerivAt).DifferentiableAt
#align differentiable_at.prod DifferentiableAt.prod
-/

#print DifferentiableOn.prod /-
theorem DifferentiableOn.prod (hf₁ : DifferentiableOn 𝕜 f₁ s) (hf₂ : DifferentiableOn 𝕜 f₂ s) :
    DifferentiableOn 𝕜 (fun x : E => (f₁ x, f₂ x)) s := fun x hx =>
  DifferentiableWithinAt.prod (hf₁ x hx) (hf₂ x hx)
#align differentiable_on.prod DifferentiableOn.prod
-/

#print Differentiable.prod /-
@[simp]
theorem Differentiable.prod (hf₁ : Differentiable 𝕜 f₁) (hf₂ : Differentiable 𝕜 f₂) :
    Differentiable 𝕜 fun x : E => (f₁ x, f₂ x) := fun x => DifferentiableAt.prod (hf₁ x) (hf₂ x)
#align differentiable.prod Differentiable.prod
-/

#print DifferentiableAt.fderiv_prod /-
theorem DifferentiableAt.fderiv_prod (hf₁ : DifferentiableAt 𝕜 f₁ x)
    (hf₂ : DifferentiableAt 𝕜 f₂ x) :
    fderiv 𝕜 (fun x : E => (f₁ x, f₂ x)) x = (fderiv 𝕜 f₁ x).Prod (fderiv 𝕜 f₂ x) :=
  (hf₁.HasFDerivAt.Prod hf₂.HasFDerivAt).fderiv
#align differentiable_at.fderiv_prod DifferentiableAt.fderiv_prod
-/

#print DifferentiableWithinAt.fderivWithin_prod /-
theorem DifferentiableWithinAt.fderivWithin_prod (hf₁ : DifferentiableWithinAt 𝕜 f₁ s x)
    (hf₂ : DifferentiableWithinAt 𝕜 f₂ s x) (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (fun x : E => (f₁ x, f₂ x)) s x =
      (fderivWithin 𝕜 f₁ s x).Prod (fderivWithin 𝕜 f₂ s x) :=
  (hf₁.HasFDerivWithinAt.Prod hf₂.HasFDerivWithinAt).fderivWithin hxs
#align differentiable_within_at.fderiv_within_prod DifferentiableWithinAt.fderivWithin_prod
-/

end Prod

section Fst

variable {f₂ : E → F × G} {f₂' : E →L[𝕜] F × G} {p : E × F}

#print hasStrictFDerivAt_fst /-
theorem hasStrictFDerivAt_fst : HasStrictFDerivAt (@Prod.fst E F) (fst 𝕜 E F) p :=
  (fst 𝕜 E F).HasStrictFDerivAt
#align has_strict_fderiv_at_fst hasStrictFDerivAt_fst
-/

#print HasStrictFDerivAt.fst /-
protected theorem HasStrictFDerivAt.fst (h : HasStrictFDerivAt f₂ f₂' x) :
    HasStrictFDerivAt (fun x => (f₂ x).1) ((fst 𝕜 F G).comp f₂') x :=
  hasStrictFDerivAt_fst.comp x h
#align has_strict_fderiv_at.fst HasStrictFDerivAt.fst
-/

#print hasFDerivAtFilter_fst /-
theorem hasFDerivAtFilter_fst {L : Filter (E × F)} :
    HasFDerivAtFilter (@Prod.fst E F) (fst 𝕜 E F) p L :=
  (fst 𝕜 E F).HasFDerivAtFilter
#align has_fderiv_at_filter_fst hasFDerivAtFilter_fst
-/

#print HasFDerivAtFilter.fst /-
protected theorem HasFDerivAtFilter.fst (h : HasFDerivAtFilter f₂ f₂' x L) :
    HasFDerivAtFilter (fun x => (f₂ x).1) ((fst 𝕜 F G).comp f₂') x L :=
  hasFDerivAtFilter_fst.comp x h tendsto_map
#align has_fderiv_at_filter.fst HasFDerivAtFilter.fst
-/

#print hasFDerivAt_fst /-
theorem hasFDerivAt_fst : HasFDerivAt (@Prod.fst E F) (fst 𝕜 E F) p :=
  hasFDerivAtFilter_fst
#align has_fderiv_at_fst hasFDerivAt_fst
-/

#print HasFDerivAt.fst /-
protected theorem HasFDerivAt.fst (h : HasFDerivAt f₂ f₂' x) :
    HasFDerivAt (fun x => (f₂ x).1) ((fst 𝕜 F G).comp f₂') x :=
  h.fst
#align has_fderiv_at.fst HasFDerivAt.fst
-/

#print hasFDerivWithinAt_fst /-
theorem hasFDerivWithinAt_fst {s : Set (E × F)} :
    HasFDerivWithinAt (@Prod.fst E F) (fst 𝕜 E F) s p :=
  hasFDerivAtFilter_fst
#align has_fderiv_within_at_fst hasFDerivWithinAt_fst
-/

#print HasFDerivWithinAt.fst /-
protected theorem HasFDerivWithinAt.fst (h : HasFDerivWithinAt f₂ f₂' s x) :
    HasFDerivWithinAt (fun x => (f₂ x).1) ((fst 𝕜 F G).comp f₂') s x :=
  h.fst
#align has_fderiv_within_at.fst HasFDerivWithinAt.fst
-/

#print differentiableAt_fst /-
theorem differentiableAt_fst : DifferentiableAt 𝕜 Prod.fst p :=
  hasFDerivAt_fst.DifferentiableAt
#align differentiable_at_fst differentiableAt_fst
-/

#print DifferentiableAt.fst /-
@[simp]
protected theorem DifferentiableAt.fst (h : DifferentiableAt 𝕜 f₂ x) :
    DifferentiableAt 𝕜 (fun x => (f₂ x).1) x :=
  differentiableAt_fst.comp x h
#align differentiable_at.fst DifferentiableAt.fst
-/

#print differentiable_fst /-
theorem differentiable_fst : Differentiable 𝕜 (Prod.fst : E × F → E) := fun x =>
  differentiableAt_fst
#align differentiable_fst differentiable_fst
-/

#print Differentiable.fst /-
@[simp]
protected theorem Differentiable.fst (h : Differentiable 𝕜 f₂) :
    Differentiable 𝕜 fun x => (f₂ x).1 :=
  differentiable_fst.comp h
#align differentiable.fst Differentiable.fst
-/

#print differentiableWithinAt_fst /-
theorem differentiableWithinAt_fst {s : Set (E × F)} : DifferentiableWithinAt 𝕜 Prod.fst s p :=
  differentiableAt_fst.DifferentiableWithinAt
#align differentiable_within_at_fst differentiableWithinAt_fst
-/

#print DifferentiableWithinAt.fst /-
protected theorem DifferentiableWithinAt.fst (h : DifferentiableWithinAt 𝕜 f₂ s x) :
    DifferentiableWithinAt 𝕜 (fun x => (f₂ x).1) s x :=
  differentiableAt_fst.comp_differentiableWithinAt x h
#align differentiable_within_at.fst DifferentiableWithinAt.fst
-/

#print differentiableOn_fst /-
theorem differentiableOn_fst {s : Set (E × F)} : DifferentiableOn 𝕜 Prod.fst s :=
  differentiable_fst.DifferentiableOn
#align differentiable_on_fst differentiableOn_fst
-/

#print DifferentiableOn.fst /-
protected theorem DifferentiableOn.fst (h : DifferentiableOn 𝕜 f₂ s) :
    DifferentiableOn 𝕜 (fun x => (f₂ x).1) s :=
  differentiable_fst.comp_differentiableOn h
#align differentiable_on.fst DifferentiableOn.fst
-/

#print fderiv_fst /-
theorem fderiv_fst : fderiv 𝕜 Prod.fst p = fst 𝕜 E F :=
  hasFDerivAt_fst.fderiv
#align fderiv_fst fderiv_fst
-/

#print fderiv.fst /-
theorem fderiv.fst (h : DifferentiableAt 𝕜 f₂ x) :
    fderiv 𝕜 (fun x => (f₂ x).1) x = (fst 𝕜 F G).comp (fderiv 𝕜 f₂ x) :=
  h.HasFDerivAt.fst.fderiv
#align fderiv.fst fderiv.fst
-/

#print fderivWithin_fst /-
theorem fderivWithin_fst {s : Set (E × F)} (hs : UniqueDiffWithinAt 𝕜 s p) :
    fderivWithin 𝕜 Prod.fst s p = fst 𝕜 E F :=
  hasFDerivWithinAt_fst.fderivWithin hs
#align fderiv_within_fst fderivWithin_fst
-/

#print fderivWithin.fst /-
theorem fderivWithin.fst (hs : UniqueDiffWithinAt 𝕜 s x) (h : DifferentiableWithinAt 𝕜 f₂ s x) :
    fderivWithin 𝕜 (fun x => (f₂ x).1) s x = (fst 𝕜 F G).comp (fderivWithin 𝕜 f₂ s x) :=
  h.HasFDerivWithinAt.fst.fderivWithin hs
#align fderiv_within.fst fderivWithin.fst
-/

end Fst

section Snd

variable {f₂ : E → F × G} {f₂' : E →L[𝕜] F × G} {p : E × F}

#print hasStrictFDerivAt_snd /-
theorem hasStrictFDerivAt_snd : HasStrictFDerivAt (@Prod.snd E F) (snd 𝕜 E F) p :=
  (snd 𝕜 E F).HasStrictFDerivAt
#align has_strict_fderiv_at_snd hasStrictFDerivAt_snd
-/

#print HasStrictFDerivAt.snd /-
protected theorem HasStrictFDerivAt.snd (h : HasStrictFDerivAt f₂ f₂' x) :
    HasStrictFDerivAt (fun x => (f₂ x).2) ((snd 𝕜 F G).comp f₂') x :=
  hasStrictFDerivAt_snd.comp x h
#align has_strict_fderiv_at.snd HasStrictFDerivAt.snd
-/

#print hasFDerivAtFilter_snd /-
theorem hasFDerivAtFilter_snd {L : Filter (E × F)} :
    HasFDerivAtFilter (@Prod.snd E F) (snd 𝕜 E F) p L :=
  (snd 𝕜 E F).HasFDerivAtFilter
#align has_fderiv_at_filter_snd hasFDerivAtFilter_snd
-/

#print HasFDerivAtFilter.snd /-
protected theorem HasFDerivAtFilter.snd (h : HasFDerivAtFilter f₂ f₂' x L) :
    HasFDerivAtFilter (fun x => (f₂ x).2) ((snd 𝕜 F G).comp f₂') x L :=
  hasFDerivAtFilter_snd.comp x h tendsto_map
#align has_fderiv_at_filter.snd HasFDerivAtFilter.snd
-/

#print hasFDerivAt_snd /-
theorem hasFDerivAt_snd : HasFDerivAt (@Prod.snd E F) (snd 𝕜 E F) p :=
  hasFDerivAtFilter_snd
#align has_fderiv_at_snd hasFDerivAt_snd
-/

#print HasFDerivAt.snd /-
protected theorem HasFDerivAt.snd (h : HasFDerivAt f₂ f₂' x) :
    HasFDerivAt (fun x => (f₂ x).2) ((snd 𝕜 F G).comp f₂') x :=
  h.snd
#align has_fderiv_at.snd HasFDerivAt.snd
-/

#print hasFDerivWithinAt_snd /-
theorem hasFDerivWithinAt_snd {s : Set (E × F)} :
    HasFDerivWithinAt (@Prod.snd E F) (snd 𝕜 E F) s p :=
  hasFDerivAtFilter_snd
#align has_fderiv_within_at_snd hasFDerivWithinAt_snd
-/

#print HasFDerivWithinAt.snd /-
protected theorem HasFDerivWithinAt.snd (h : HasFDerivWithinAt f₂ f₂' s x) :
    HasFDerivWithinAt (fun x => (f₂ x).2) ((snd 𝕜 F G).comp f₂') s x :=
  h.snd
#align has_fderiv_within_at.snd HasFDerivWithinAt.snd
-/

#print differentiableAt_snd /-
theorem differentiableAt_snd : DifferentiableAt 𝕜 Prod.snd p :=
  hasFDerivAt_snd.DifferentiableAt
#align differentiable_at_snd differentiableAt_snd
-/

#print DifferentiableAt.snd /-
@[simp]
protected theorem DifferentiableAt.snd (h : DifferentiableAt 𝕜 f₂ x) :
    DifferentiableAt 𝕜 (fun x => (f₂ x).2) x :=
  differentiableAt_snd.comp x h
#align differentiable_at.snd DifferentiableAt.snd
-/

#print differentiable_snd /-
theorem differentiable_snd : Differentiable 𝕜 (Prod.snd : E × F → F) := fun x =>
  differentiableAt_snd
#align differentiable_snd differentiable_snd
-/

#print Differentiable.snd /-
@[simp]
protected theorem Differentiable.snd (h : Differentiable 𝕜 f₂) :
    Differentiable 𝕜 fun x => (f₂ x).2 :=
  differentiable_snd.comp h
#align differentiable.snd Differentiable.snd
-/

#print differentiableWithinAt_snd /-
theorem differentiableWithinAt_snd {s : Set (E × F)} : DifferentiableWithinAt 𝕜 Prod.snd s p :=
  differentiableAt_snd.DifferentiableWithinAt
#align differentiable_within_at_snd differentiableWithinAt_snd
-/

#print DifferentiableWithinAt.snd /-
protected theorem DifferentiableWithinAt.snd (h : DifferentiableWithinAt 𝕜 f₂ s x) :
    DifferentiableWithinAt 𝕜 (fun x => (f₂ x).2) s x :=
  differentiableAt_snd.comp_differentiableWithinAt x h
#align differentiable_within_at.snd DifferentiableWithinAt.snd
-/

#print differentiableOn_snd /-
theorem differentiableOn_snd {s : Set (E × F)} : DifferentiableOn 𝕜 Prod.snd s :=
  differentiable_snd.DifferentiableOn
#align differentiable_on_snd differentiableOn_snd
-/

#print DifferentiableOn.snd /-
protected theorem DifferentiableOn.snd (h : DifferentiableOn 𝕜 f₂ s) :
    DifferentiableOn 𝕜 (fun x => (f₂ x).2) s :=
  differentiable_snd.comp_differentiableOn h
#align differentiable_on.snd DifferentiableOn.snd
-/

#print fderiv_snd /-
theorem fderiv_snd : fderiv 𝕜 Prod.snd p = snd 𝕜 E F :=
  hasFDerivAt_snd.fderiv
#align fderiv_snd fderiv_snd
-/

#print fderiv.snd /-
theorem fderiv.snd (h : DifferentiableAt 𝕜 f₂ x) :
    fderiv 𝕜 (fun x => (f₂ x).2) x = (snd 𝕜 F G).comp (fderiv 𝕜 f₂ x) :=
  h.HasFDerivAt.snd.fderiv
#align fderiv.snd fderiv.snd
-/

#print fderivWithin_snd /-
theorem fderivWithin_snd {s : Set (E × F)} (hs : UniqueDiffWithinAt 𝕜 s p) :
    fderivWithin 𝕜 Prod.snd s p = snd 𝕜 E F :=
  hasFDerivWithinAt_snd.fderivWithin hs
#align fderiv_within_snd fderivWithin_snd
-/

#print fderivWithin.snd /-
theorem fderivWithin.snd (hs : UniqueDiffWithinAt 𝕜 s x) (h : DifferentiableWithinAt 𝕜 f₂ s x) :
    fderivWithin 𝕜 (fun x => (f₂ x).2) s x = (snd 𝕜 F G).comp (fderivWithin 𝕜 f₂ s x) :=
  h.HasFDerivWithinAt.snd.fderivWithin hs
#align fderiv_within.snd fderivWithin.snd
-/

end Snd

section Prod_map

variable {f₂ : G → G'} {f₂' : G →L[𝕜] G'} {y : G} (p : E × G)

#print HasStrictFDerivAt.prodMap /-
protected theorem HasStrictFDerivAt.prodMap (hf : HasStrictFDerivAt f f' p.1)
    (hf₂ : HasStrictFDerivAt f₂ f₂' p.2) : HasStrictFDerivAt (Prod.map f f₂) (f'.Prod_map f₂') p :=
  (hf.comp p hasStrictFDerivAt_fst).Prod (hf₂.comp p hasStrictFDerivAt_snd)
#align has_strict_fderiv_at.prod_map HasStrictFDerivAt.prodMap
-/

#print HasFDerivAt.prodMap /-
protected theorem HasFDerivAt.prodMap (hf : HasFDerivAt f f' p.1) (hf₂ : HasFDerivAt f₂ f₂' p.2) :
    HasFDerivAt (Prod.map f f₂) (f'.Prod_map f₂') p :=
  (hf.comp p hasFDerivAt_fst).Prod (hf₂.comp p hasFDerivAt_snd)
#align has_fderiv_at.prod_map HasFDerivAt.prodMap
-/

#print DifferentiableAt.prod_map /-
@[simp]
protected theorem DifferentiableAt.prod_map (hf : DifferentiableAt 𝕜 f p.1)
    (hf₂ : DifferentiableAt 𝕜 f₂ p.2) : DifferentiableAt 𝕜 (fun p : E × G => (f p.1, f₂ p.2)) p :=
  (hf.comp p differentiableAt_fst).Prod (hf₂.comp p differentiableAt_snd)
#align differentiable_at.prod_map DifferentiableAt.prod_map
-/

end Prod_map

section Pi

/-!
### Derivatives of functions `f : E → Π i, F' i`

In this section we formulate `has_*fderiv*_pi` theorems as `iff`s, and provide two versions of each
theorem:

* the version without `'` deals with `φ : Π i, E → F' i` and `φ' : Π i, E →L[𝕜] F' i`
  and is designed to deduce differentiability of `λ x i, φ i x` from differentiability
  of each `φ i`;
* the version with `'` deals with `Φ : E → Π i, F' i` and `Φ' : E →L[𝕜] Π i, F' i`
  and is designed to deduce differentiability of the components `λ x, Φ x i` from
  differentiability of `Φ`.
-/


variable {ι : Type _} [Fintype ι] {F' : ι → Type _} [∀ i, NormedAddCommGroup (F' i)]
  [∀ i, NormedSpace 𝕜 (F' i)] {φ : ∀ i, E → F' i} {φ' : ∀ i, E →L[𝕜] F' i} {Φ : E → ∀ i, F' i}
  {Φ' : E →L[𝕜] ∀ i, F' i}

#print hasStrictFDerivAt_pi' /-
@[simp]
theorem hasStrictFDerivAt_pi' :
    HasStrictFDerivAt Φ Φ' x ↔ ∀ i, HasStrictFDerivAt (fun x => Φ x i) ((proj i).comp Φ') x :=
  by
  simp only [HasStrictFDerivAt, ContinuousLinearMap.coe_pi]
  exact is_o_pi
#align has_strict_fderiv_at_pi' hasStrictFDerivAt_pi'
-/

#print hasStrictFDerivAt_pi /-
@[simp]
theorem hasStrictFDerivAt_pi :
    HasStrictFDerivAt (fun x i => φ i x) (ContinuousLinearMap.pi φ') x ↔
      ∀ i, HasStrictFDerivAt (φ i) (φ' i) x :=
  hasStrictFDerivAt_pi'
#align has_strict_fderiv_at_pi hasStrictFDerivAt_pi
-/

#print hasFDerivAtFilter_pi' /-
@[simp]
theorem hasFDerivAtFilter_pi' :
    HasFDerivAtFilter Φ Φ' x L ↔ ∀ i, HasFDerivAtFilter (fun x => Φ x i) ((proj i).comp Φ') x L :=
  by
  simp only [HasFDerivAtFilter, ContinuousLinearMap.coe_pi]
  exact is_o_pi
#align has_fderiv_at_filter_pi' hasFDerivAtFilter_pi'
-/

#print hasFDerivAtFilter_pi /-
theorem hasFDerivAtFilter_pi :
    HasFDerivAtFilter (fun x i => φ i x) (ContinuousLinearMap.pi φ') x L ↔
      ∀ i, HasFDerivAtFilter (φ i) (φ' i) x L :=
  hasFDerivAtFilter_pi'
#align has_fderiv_at_filter_pi hasFDerivAtFilter_pi
-/

#print hasFDerivAt_pi' /-
@[simp]
theorem hasFDerivAt_pi' :
    HasFDerivAt Φ Φ' x ↔ ∀ i, HasFDerivAt (fun x => Φ x i) ((proj i).comp Φ') x :=
  hasFDerivAtFilter_pi'
#align has_fderiv_at_pi' hasFDerivAt_pi'
-/

#print hasFDerivAt_pi /-
theorem hasFDerivAt_pi :
    HasFDerivAt (fun x i => φ i x) (ContinuousLinearMap.pi φ') x ↔
      ∀ i, HasFDerivAt (φ i) (φ' i) x :=
  hasFDerivAtFilter_pi
#align has_fderiv_at_pi hasFDerivAt_pi
-/

#print hasFDerivWithinAt_pi' /-
@[simp]
theorem hasFDerivWithinAt_pi' :
    HasFDerivWithinAt Φ Φ' s x ↔ ∀ i, HasFDerivWithinAt (fun x => Φ x i) ((proj i).comp Φ') s x :=
  hasFDerivAtFilter_pi'
#align has_fderiv_within_at_pi' hasFDerivWithinAt_pi'
-/

#print hasFDerivWithinAt_pi /-
theorem hasFDerivWithinAt_pi :
    HasFDerivWithinAt (fun x i => φ i x) (ContinuousLinearMap.pi φ') s x ↔
      ∀ i, HasFDerivWithinAt (φ i) (φ' i) s x :=
  hasFDerivAtFilter_pi
#align has_fderiv_within_at_pi hasFDerivWithinAt_pi
-/

#print differentiableWithinAt_pi /-
@[simp]
theorem differentiableWithinAt_pi :
    DifferentiableWithinAt 𝕜 Φ s x ↔ ∀ i, DifferentiableWithinAt 𝕜 (fun x => Φ x i) s x :=
  ⟨fun h i => (hasFDerivWithinAt_pi'.1 h.HasFDerivWithinAt i).DifferentiableWithinAt, fun h =>
    (hasFDerivWithinAt_pi.2 fun i => (h i).HasFDerivWithinAt).DifferentiableWithinAt⟩
#align differentiable_within_at_pi differentiableWithinAt_pi
-/

#print differentiableAt_pi /-
@[simp]
theorem differentiableAt_pi : DifferentiableAt 𝕜 Φ x ↔ ∀ i, DifferentiableAt 𝕜 (fun x => Φ x i) x :=
  ⟨fun h i => (hasFDerivAt_pi'.1 h.HasFDerivAt i).DifferentiableAt, fun h =>
    (hasFDerivAt_pi.2 fun i => (h i).HasFDerivAt).DifferentiableAt⟩
#align differentiable_at_pi differentiableAt_pi
-/

#print differentiableOn_pi /-
theorem differentiableOn_pi : DifferentiableOn 𝕜 Φ s ↔ ∀ i, DifferentiableOn 𝕜 (fun x => Φ x i) s :=
  ⟨fun h i x hx => differentiableWithinAt_pi.1 (h x hx) i, fun h x hx =>
    differentiableWithinAt_pi.2 fun i => h i x hx⟩
#align differentiable_on_pi differentiableOn_pi
-/

#print differentiable_pi /-
theorem differentiable_pi : Differentiable 𝕜 Φ ↔ ∀ i, Differentiable 𝕜 fun x => Φ x i :=
  ⟨fun h i x => differentiableAt_pi.1 (h x) i, fun h x => differentiableAt_pi.2 fun i => h i x⟩
#align differentiable_pi differentiable_pi
-/

#print fderivWithin_pi /-
-- TODO: find out which version (`φ` or `Φ`) works better with `rw`/`simp`
theorem fderivWithin_pi (h : ∀ i, DifferentiableWithinAt 𝕜 (φ i) s x)
    (hs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (fun x i => φ i x) s x = pi fun i => fderivWithin 𝕜 (φ i) s x :=
  (hasFDerivWithinAt_pi.2 fun i => (h i).HasFDerivWithinAt).fderivWithin hs
#align fderiv_within_pi fderivWithin_pi
-/

#print fderiv_pi /-
theorem fderiv_pi (h : ∀ i, DifferentiableAt 𝕜 (φ i) x) :
    fderiv 𝕜 (fun x i => φ i x) x = pi fun i => fderiv 𝕜 (φ i) x :=
  (hasFDerivAt_pi.2 fun i => (h i).HasFDerivAt).fderiv
#align fderiv_pi fderiv_pi
-/

end Pi

end CartesianProduct

end

