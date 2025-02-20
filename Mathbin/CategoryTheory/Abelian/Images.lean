/-
Copyright (c) 2020 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel, Scott Morrison

! This file was ported from Lean 3 source module category_theory.abelian.images
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.Kernels

/-!
# The abelian image and coimage.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In an abelian category we usually want the image of a morphism `f` to be defined as
`kernel (cokernel.π f)`, and the coimage to be defined as `cokernel (kernel.ι f)`.

We make these definitions here, as `abelian.image f` and `abelian.coimage f`
(without assuming the category is actually abelian),
and later relate these to the usual categorical notions when in an abelian category.

There is a canonical morphism `coimage_image_comparison : abelian.coimage f ⟶ abelian.image f`.
Later we show that this is always an isomorphism in an abelian category,
and conversely a category with (co)kernels and finite products in which this morphism
is always an isomorphism is an abelian category.
-/


noncomputable section

universe v u

open CategoryTheory

open CategoryTheory.Limits

namespace CategoryTheory.Abelian

variable {C : Type u} [Category.{v} C] [HasZeroMorphisms C] [HasKernels C] [HasCokernels C]

variable {P Q : C} (f : P ⟶ Q)

section Image

#print CategoryTheory.Abelian.image /-
/-- The kernel of the cokernel of `f` is called the (abelian) image of `f`. -/
protected abbrev image : C :=
  kernel (cokernel.π f)
#align category_theory.abelian.image CategoryTheory.Abelian.image
-/

#print CategoryTheory.Abelian.image.ι /-
/-- The inclusion of the image into the codomain. -/
protected abbrev image.ι : Abelian.image f ⟶ Q :=
  kernel.ι (cokernel.π f)
#align category_theory.abelian.image.ι CategoryTheory.Abelian.image.ι
-/

#print CategoryTheory.Abelian.factorThruImage /-
/-- There is a canonical epimorphism `p : P ⟶ image f` for every `f`. -/
protected abbrev factorThruImage : P ⟶ Abelian.image f :=
  kernel.lift (cokernel.π f) f <| cokernel.condition f
#align category_theory.abelian.factor_thru_image CategoryTheory.Abelian.factorThruImage
-/

#print CategoryTheory.Abelian.image.fac /-
/-- `f` factors through its image via the canonical morphism `p`. -/
@[simp, reassoc]
protected theorem image.fac : Abelian.factorThruImage f ≫ image.ι f = f :=
  kernel.lift_ι _ _ _
#align category_theory.abelian.image.fac CategoryTheory.Abelian.image.fac
-/

#print CategoryTheory.Abelian.mono_factorThruImage /-
instance mono_factorThruImage [Mono f] : Mono (Abelian.factorThruImage f) :=
  mono_of_mono_fac <| image.fac f
#align category_theory.abelian.mono_factor_thru_image CategoryTheory.Abelian.mono_factorThruImage
-/

end Image

section Coimage

#print CategoryTheory.Abelian.coimage /-
/-- The cokernel of the kernel of `f` is called the (abelian) coimage of `f`. -/
protected abbrev coimage : C :=
  cokernel (kernel.ι f)
#align category_theory.abelian.coimage CategoryTheory.Abelian.coimage
-/

#print CategoryTheory.Abelian.coimage.π /-
/-- The projection onto the coimage. -/
protected abbrev coimage.π : P ⟶ Abelian.coimage f :=
  cokernel.π (kernel.ι f)
#align category_theory.abelian.coimage.π CategoryTheory.Abelian.coimage.π
-/

#print CategoryTheory.Abelian.factorThruCoimage /-
/-- There is a canonical monomorphism `i : coimage f ⟶ Q`. -/
protected abbrev factorThruCoimage : Abelian.coimage f ⟶ Q :=
  cokernel.desc (kernel.ι f) f <| kernel.condition f
#align category_theory.abelian.factor_thru_coimage CategoryTheory.Abelian.factorThruCoimage
-/

#print CategoryTheory.Abelian.coimage.fac /-
/-- `f` factors through its coimage via the canonical morphism `p`. -/
protected theorem coimage.fac : coimage.π f ≫ Abelian.factorThruCoimage f = f :=
  cokernel.π_desc _ _ _
#align category_theory.abelian.coimage.fac CategoryTheory.Abelian.coimage.fac
-/

#print CategoryTheory.Abelian.epi_factorThruCoimage /-
instance epi_factorThruCoimage [Epi f] : Epi (Abelian.factorThruCoimage f) :=
  epi_of_epi_fac <| coimage.fac f
#align category_theory.abelian.epi_factor_thru_coimage CategoryTheory.Abelian.epi_factorThruCoimage
-/

end Coimage

#print CategoryTheory.Abelian.coimageImageComparison /-
/-- The canonical map from the abelian coimage to the abelian image.
In any abelian category this is an isomorphism.

Conversely, any additive category with kernels and cokernels and
in which this is always an isomorphism, is abelian.

See <https://stacks.math.columbia.edu/tag/0107>
-/
def coimageImageComparison : Abelian.coimage f ⟶ Abelian.image f :=
  cokernel.desc (kernel.ι f) (kernel.lift (cokernel.π f) f (by simp)) <| by ext; simp
#align category_theory.abelian.coimage_image_comparison CategoryTheory.Abelian.coimageImageComparison
-/

#print CategoryTheory.Abelian.coimageImageComparison' /-
/-- An alternative formulation of the canonical map from the abelian coimage to the abelian image.
-/
def coimageImageComparison' : Abelian.coimage f ⟶ Abelian.image f :=
  kernel.lift (cokernel.π f) (cokernel.desc (kernel.ι f) f (by simp)) (by ext; simp)
#align category_theory.abelian.coimage_image_comparison' CategoryTheory.Abelian.coimageImageComparison'
-/

#print CategoryTheory.Abelian.coimageImageComparison_eq_coimageImageComparison' /-
theorem coimageImageComparison_eq_coimageImageComparison' :
    coimageImageComparison f = coimageImageComparison' f := by ext;
  simp [coimage_image_comparison, coimage_image_comparison']
#align category_theory.abelian.coimage_image_comparison_eq_coimage_image_comparison' CategoryTheory.Abelian.coimageImageComparison_eq_coimageImageComparison'
-/

#print CategoryTheory.Abelian.coimage_image_factorisation /-
@[simp, reassoc]
theorem coimage_image_factorisation : coimage.π f ≫ coimageImageComparison f ≫ image.ι f = f := by
  simp [coimage_image_comparison]
#align category_theory.abelian.coimage_image_factorisation CategoryTheory.Abelian.coimage_image_factorisation
-/

end CategoryTheory.Abelian

