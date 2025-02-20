/-
Copyright (c) 2020 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel, Johan Commelin, Scott Morrison

! This file was ported from Lean 3 source module category_theory.abelian.basic
! leanprover-community/mathlib commit a5ff45a1c92c278b03b52459a620cfd9c49ebc80
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Constructions.Pullbacks
import Mathbin.CategoryTheory.Preadditive.Biproducts
import Mathbin.CategoryTheory.Limits.Shapes.Images
import Mathbin.CategoryTheory.Limits.Constructions.LimitsOfProductsAndEqualizers
import Mathbin.CategoryTheory.Abelian.NonPreadditive

/-!
# Abelian categories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains the definition and basic properties of abelian categories.

There are many definitions of abelian category. Our definition is as follows:
A category is called abelian if it is preadditive,
has a finite products, kernels and cokernels,
and if every monomorphism and epimorphism is normal.

It should be noted that if we also assume coproducts, then preadditivity is
actually a consequence of the other properties, as we show in
`non_preadditive_abelian.lean`. However, this fact is of little practical
relevance, since essentially all interesting abelian categories come with a
preadditive structure. In this way, by requiring preadditivity, we allow the
user to pass in the "native" preadditive structure for the specific category they are
working with.

## Main definitions

* `abelian` is the type class indicating that a category is abelian. It extends `preadditive`.
* `abelian.image f` is `kernel (cokernel.π f)`, and
* `abelian.coimage f` is `cokernel (kernel.ι f)`.

## Main results

* In an abelian category, mono + epi = iso.
* If `f : X ⟶ Y`, then the map `factor_thru_image f : X ⟶ image f` is an epimorphism, and the map
  `factor_thru_coimage f : coimage f ⟶ Y` is a monomorphism.
* Factoring through the image and coimage is a strong epi-mono factorisation. This means that
  * every abelian category has images. We provide the isomorphism
    `image_iso_image : abelian.image f ≅ limits.image f`.
  * the canonical morphism `coimage_image_comparison : coimage f ⟶ image f`
    is an isomorphism.
* We provide the alternate characterisation of an abelian category as a category with
  (co)kernels and finite products, and in which the canonical coimage-image comparison morphism
  is always an isomorphism.
* Every epimorphism is a cokernel of its kernel. Every monomorphism is a kernel of its cokernel.
* The pullback of an epimorphism is an epimorphism. The pushout of a monomorphism is a monomorphism.
  (This is not to be confused with the fact that the pullback of a monomorphism is a monomorphism,
  which is true in any category).

## Implementation notes

The typeclass `abelian` does not extend `non_preadditive_abelian`,
to avoid having to deal with comparing the two `has_zero_morphisms` instances
(one from `preadditive` in `abelian`, and the other a field of `non_preadditive_abelian`).
As a consequence, at the beginning of this file we trivially build
a `non_preadditive_abelian` instance from an `abelian` instance,
and use this to restate a number of theorems,
in each case just reusing the proof from `non_preadditive_abelian.lean`.

We don't show this yet, but abelian categories are finitely complete and finitely cocomplete.
However, the limits we can construct at this level of generality will most likely be less nice than
the ones that can be created in specific applications. For this reason, we adopt the following
convention:

* If the statement of a theorem involves limits, the existence of these limits should be made an
  explicit typeclass parameter.
* If a limit only appears in a proof, but not in the statement of a theorem, the limit should not
  be a typeclass parameter, but instead be created using `abelian.has_pullbacks` or a similar
  definition.

## References

* [F. Borceux, *Handbook of Categorical Algebra 2*][borceux-vol2]
* [P. Aluffi, *Algebra: Chapter 0*][aluffi2016]

-/


noncomputable section

open CategoryTheory

open CategoryTheory.Preadditive

open CategoryTheory.Limits

universe v u

namespace CategoryTheory

variable {C : Type u} [Category.{v} C]

variable (C)

#print CategoryTheory.Abelian /-
/-- A (preadditive) category `C` is called abelian if it has all finite products,
all kernels and cokernels, and if every monomorphism is the kernel of some morphism
and every epimorphism is the cokernel of some morphism.

(This definition implies the existence of zero objects:
finite products give a terminal object, and in a preadditive category
any terminal object is a zero object.)
-/
class Abelian extends Preadditive C, NormalMonoCategory C, NormalEpiCategory C where
  [HasFiniteProducts : HasFiniteProducts C]
  [HasKernels : HasKernels C]
  [HasCokernels : HasCokernels C]
#align category_theory.abelian CategoryTheory.Abelian
-/

attribute [instance 100] abelian.has_finite_products

attribute [instance 100] abelian.has_kernels abelian.has_cokernels

end CategoryTheory

open CategoryTheory

/-!
We begin by providing an alternative constructor:
a preadditive category with kernels, cokernels, and finite products,
in which the coimage-image comparison morphism is always an isomorphism,
is an abelian category.
-/


namespace CategoryTheory.Abelian

variable {C : Type u} [Category.{v} C] [Preadditive C]

variable [Limits.HasKernels C] [Limits.HasCokernels C]

namespace OfCoimageImageComparisonIsIso

#print CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.imageMonoFactorisation /-
/-- The factorisation of a morphism through its abelian image. -/
@[simps]
def imageMonoFactorisation {X Y : C} (f : X ⟶ Y) : MonoFactorisation f
    where
  i := Abelian.image f
  m := kernel.ι _
  m_mono := inferInstance
  e := kernel.lift _ f (cokernel.condition _)
  fac := kernel.lift_ι _ _ _
#align category_theory.abelian.of_coimage_image_comparison_is_iso.image_mono_factorisation CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.imageMonoFactorisation
-/

#print CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.imageMonoFactorisation_e' /-
theorem imageMonoFactorisation_e' {X Y : C} (f : X ⟶ Y) :
    (imageMonoFactorisation f).e = cokernel.π _ ≫ Abelian.coimageImageComparison f :=
  by
  ext
  simp only [abelian.coimage_image_comparison, image_mono_factorisation_e, category.assoc,
    cokernel.π_desc_assoc]
#align category_theory.abelian.of_coimage_image_comparison_is_iso.image_mono_factorisation_e' CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.imageMonoFactorisation_e'
-/

#print CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.imageFactorisation /-
/-- If the coimage-image comparison morphism for a morphism `f` is an isomorphism,
we obtain an image factorisation of `f`. -/
def imageFactorisation {X Y : C} (f : X ⟶ Y) [IsIso (Abelian.coimageImageComparison f)] :
    ImageFactorisation f where
  f := imageMonoFactorisation f
  IsImage :=
    { lift := fun F => inv (Abelian.coimageImageComparison f) ≫ cokernel.desc _ F.e F.kernel_ι_comp
      lift_fac := fun F =>
        by
        simp only [image_mono_factorisation_m, is_iso.inv_comp_eq, category.assoc,
          abelian.coimage_image_comparison]
        ext
        simp only [cokernel.π_desc_assoc, mono_factorisation.fac, image.fac] }
#align category_theory.abelian.of_coimage_image_comparison_is_iso.image_factorisation CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.imageFactorisation
-/

instance [HasZeroObject C] {X Y : C} (f : X ⟶ Y) [Mono f]
    [IsIso (Abelian.coimageImageComparison f)] : IsIso (imageMonoFactorisation f).e := by
  rw [image_mono_factorisation_e']; exact is_iso.comp_is_iso

instance [HasZeroObject C] {X Y : C} (f : X ⟶ Y) [Epi f] : IsIso (imageMonoFactorisation f).m := by
  dsimp; infer_instance

variable [∀ {X Y : C} (f : X ⟶ Y), IsIso (Abelian.coimageImageComparison f)]

#print CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.hasImages /-
/-- A category in which coimage-image comparisons are all isomorphisms has images. -/
theorem hasImages : HasImages C :=
  { HasImage := fun X Y f => { exists_image := ⟨imageFactorisation f⟩ } }
#align category_theory.abelian.of_coimage_image_comparison_is_iso.has_images CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.hasImages
-/

variable [Limits.HasFiniteProducts C]

attribute [local instance] limits.has_finite_biproducts.of_has_finite_products

#print CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.normalMonoCategory /-
/-- A category with finite products in which coimage-image comparisons are all isomorphisms
is a normal mono category.
-/
def normalMonoCategory : NormalMonoCategory C
    where normalMonoOfMono X Y f m :=
    { z := _
      g := cokernel.π f
      w := by simp
      IsLimit := by
        haveI : limits.has_images C := has_images
        haveI : has_equalizers C := preadditive.has_equalizers_of_has_kernels
        haveI : has_zero_object C := limits.has_zero_object_of_has_finite_biproducts _
        have aux : _ := _
        refine' is_limit_aux _ (fun A => limit.lift _ _ ≫ inv (image_mono_factorisation f).e) aux _
        · intro A g hg
          rw [kernel_fork.ι_of_ι] at hg 
          rw [← cancel_mono f, hg, ← aux, kernel_fork.ι_of_ι]
        · intro A
          simp only [kernel_fork.ι_of_ι, category.assoc]
          convert limit.lift_π _ _ using 2
          rw [is_iso.inv_comp_eq, eq_comm]
          exact (image_mono_factorisation f).fac }
#align category_theory.abelian.of_coimage_image_comparison_is_iso.normal_mono_category CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.normalMonoCategory
-/

#print CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.normalEpiCategory /-
/-- A category with finite products in which coimage-image comparisons are all isomorphisms
is a normal epi category.
-/
def normalEpiCategory : NormalEpiCategory C
    where normalEpiOfEpi X Y f m :=
    { w := kernel f
      g := kernel.ι _
      w := kernel.condition _
      IsColimit := by
        haveI : limits.has_images C := has_images
        haveI : has_equalizers C := preadditive.has_equalizers_of_has_kernels
        haveI : has_zero_object C := limits.has_zero_object_of_has_finite_biproducts _
        have aux : _ := _
        refine'
          is_colimit_aux _
            (fun A =>
              inv (image_mono_factorisation f).m ≫
                inv (abelian.coimage_image_comparison f) ≫ colimit.desc _ _)
            aux _
        · intro A g hg
          rw [cokernel_cofork.π_of_π] at hg 
          rw [← cancel_epi f, hg, ← aux, cokernel_cofork.π_of_π]
        · intro A
          simp only [cokernel_cofork.π_of_π, ← category.assoc]
          convert colimit.ι_desc _ _ using 2
          rw [is_iso.comp_inv_eq, is_iso.comp_inv_eq, eq_comm, ← image_mono_factorisation_e']
          exact (image_mono_factorisation f).fac }
#align category_theory.abelian.of_coimage_image_comparison_is_iso.normal_epi_category CategoryTheory.Abelian.OfCoimageImageComparisonIsIso.normalEpiCategory
-/

end OfCoimageImageComparisonIsIso

variable [∀ {X Y : C} (f : X ⟶ Y), IsIso (Abelian.coimageImageComparison f)]
  [Limits.HasFiniteProducts C]

attribute [local instance] of_coimage_image_comparison_is_iso.normal_mono_category

attribute [local instance] of_coimage_image_comparison_is_iso.normal_epi_category

#print CategoryTheory.Abelian.ofCoimageImageComparisonIsIso /-
/-- A preadditive category with kernels, cokernels, and finite products,
in which the coimage-image comparison morphism is always an isomorphism,
is an abelian category.

The Stacks project uses this characterisation at the definition of an abelian category.
See <https://stacks.math.columbia.edu/tag/0109>.
-/
def ofCoimageImageComparisonIsIso : Abelian C where
#align category_theory.abelian.of_coimage_image_comparison_is_iso CategoryTheory.Abelian.ofCoimageImageComparisonIsIso
-/

end CategoryTheory.Abelian

namespace CategoryTheory.Abelian

variable {C : Type u} [Category.{v} C] [Abelian C]

#print CategoryTheory.Abelian.hasFiniteBiproducts /-
-- Porting note: this should be an instance,
-- but triggers https://github.com/leanprover/lean4/issues/2055
-- We set it as a local instance instead.
-- @[priority 100] instance
/-- An abelian category has finite biproducts. -/
theorem hasFiniteBiproducts : HasFiniteBiproducts C :=
  Limits.HasFiniteBiproducts.of_hasFiniteProducts
#align category_theory.abelian.has_finite_biproducts CategoryTheory.Abelian.hasFiniteBiproducts
-/

attribute [local instance] has_finite_biproducts

#print CategoryTheory.Abelian.hasBinaryBiproducts /-
instance (priority := 100) hasBinaryBiproducts : HasBinaryBiproducts C :=
  Limits.hasBinaryBiproducts_of_finite_biproducts _
#align category_theory.abelian.has_binary_biproducts CategoryTheory.Abelian.hasBinaryBiproducts
-/

#print CategoryTheory.Abelian.hasZeroObject /-
instance (priority := 100) hasZeroObject : HasZeroObject C :=
  hasZeroObject_of_hasInitial_object
#align category_theory.abelian.has_zero_object CategoryTheory.Abelian.hasZeroObject
-/

section ToNonPreadditiveAbelian

#print CategoryTheory.Abelian.nonPreadditiveAbelian /-
/-- Every abelian category is, in particular, `non_preadditive_abelian`. -/
def nonPreadditiveAbelian : NonPreadditiveAbelian C :=
  { ‹Abelian C› with }
#align category_theory.abelian.non_preadditive_abelian CategoryTheory.Abelian.nonPreadditiveAbelian
-/

end ToNonPreadditiveAbelian

section

/-! We now promote some instances that were constructed using `non_preadditive_abelian`. -/


attribute [local instance] non_preadditive_abelian

variable {P Q : C} (f : P ⟶ Q)

/-- The map `p : P ⟶ image f` is an epimorphism -/
instance : Epi (Abelian.factorThruImage f) := by infer_instance

#print CategoryTheory.Abelian.isIso_factorThruImage /-
instance isIso_factorThruImage [Mono f] : IsIso (Abelian.factorThruImage f) := by infer_instance
#align category_theory.abelian.is_iso_factor_thru_image CategoryTheory.Abelian.isIso_factorThruImage
-/

/-- The canonical morphism `i : coimage f ⟶ Q` is a monomorphism -/
instance : Mono (Abelian.factorThruCoimage f) := by infer_instance

#print CategoryTheory.Abelian.isIso_factorThruCoimage /-
instance isIso_factorThruCoimage [Epi f] : IsIso (Abelian.factorThruCoimage f) := by infer_instance
#align category_theory.abelian.is_iso_factor_thru_coimage CategoryTheory.Abelian.isIso_factorThruCoimage
-/

end

section Factor

attribute [local instance] non_preadditive_abelian

variable {P Q : C} (f : P ⟶ Q)

section

#print CategoryTheory.Abelian.mono_of_kernel_ι_eq_zero /-
theorem mono_of_kernel_ι_eq_zero (h : kernel.ι f = 0) : Mono f :=
  mono_of_kernel_zero h
#align category_theory.abelian.mono_of_kernel_ι_eq_zero CategoryTheory.Abelian.mono_of_kernel_ι_eq_zero
-/

#print CategoryTheory.Abelian.epi_of_cokernel_π_eq_zero /-
theorem epi_of_cokernel_π_eq_zero (h : cokernel.π f = 0) : Epi f :=
  by
  apply normal_mono_category.epi_of_zero_cokernel _ (cokernel f)
  simp_rw [← h]
  exact is_colimit.of_iso_colimit (colimit.is_colimit (parallel_pair f 0)) (iso_of_π _)
#align category_theory.abelian.epi_of_cokernel_π_eq_zero CategoryTheory.Abelian.epi_of_cokernel_π_eq_zero
-/

end

section

variable {f}

#print CategoryTheory.Abelian.image_ι_comp_eq_zero /-
theorem image_ι_comp_eq_zero {R : C} {g : Q ⟶ R} (h : f ≫ g = 0) : Abelian.image.ι f ≫ g = 0 :=
  zero_of_epi_comp (Abelian.factorThruImage f) <| by simp [h]
#align category_theory.abelian.image_ι_comp_eq_zero CategoryTheory.Abelian.image_ι_comp_eq_zero
-/

#print CategoryTheory.Abelian.comp_coimage_π_eq_zero /-
theorem comp_coimage_π_eq_zero {R : C} {g : Q ⟶ R} (h : f ≫ g = 0) : f ≫ Abelian.coimage.π g = 0 :=
  zero_of_comp_mono (Abelian.factorThruCoimage g) <| by simp [h]
#align category_theory.abelian.comp_coimage_π_eq_zero CategoryTheory.Abelian.comp_coimage_π_eq_zero
-/

end

#print CategoryTheory.Abelian.imageStrongEpiMonoFactorisation /-
/-- Factoring through the image is a strong epi-mono factorisation. -/
@[simps]
def imageStrongEpiMonoFactorisation : StrongEpiMonoFactorisation f
    where
  i := Abelian.image f
  m := image.ι f
  m_mono := by infer_instance
  e := Abelian.factorThruImage f
  e_strongEpi := strongEpi_of_epi _
#align category_theory.abelian.image_strong_epi_mono_factorisation CategoryTheory.Abelian.imageStrongEpiMonoFactorisation
-/

#print CategoryTheory.Abelian.coimageStrongEpiMonoFactorisation /-
/-- Factoring through the coimage is a strong epi-mono factorisation. -/
@[simps]
def coimageStrongEpiMonoFactorisation : StrongEpiMonoFactorisation f
    where
  i := Abelian.coimage f
  m := Abelian.factorThruCoimage f
  m_mono := by infer_instance
  e := coimage.π f
  e_strongEpi := strongEpi_of_epi _
#align category_theory.abelian.coimage_strong_epi_mono_factorisation CategoryTheory.Abelian.coimageStrongEpiMonoFactorisation
-/

end Factor

section HasStrongEpiMonoFactorisations

/-- An abelian category has strong epi-mono factorisations. -/
instance (priority := 100) : HasStrongEpiMonoFactorisations C :=
  HasStrongEpiMonoFactorisations.mk fun X Y f => imageStrongEpiMonoFactorisation f

-- In particular, this means that it has well-behaved images.
example : HasImages C := by infer_instance

example : HasImageMaps C := by infer_instance

end HasStrongEpiMonoFactorisations

section Images

variable {X Y : C} (f : X ⟶ Y)

/-- The coimage-image comparison morphism is always an isomorphism in an abelian category.
See `category_theory.abelian.of_coimage_image_comparison_is_iso` for the converse.
-/
instance : IsIso (coimageImageComparison f) :=
  by
  convert
    is_iso.of_iso
      (is_image.iso_ext (coimage_strong_epi_mono_factorisation f).toMonoIsImage
        (image_strong_epi_mono_factorisation f).toMonoIsImage)
  ext
  change _ = _ ≫ (image_strong_epi_mono_factorisation f).m
  simp [-image_strong_epi_mono_factorisation_to_mono_factorisation_m]

#print CategoryTheory.Abelian.coimageIsoImage /-
/-- There is a canonical isomorphism between the abelian coimage and the abelian image of a
    morphism. -/
abbrev coimageIsoImage : Abelian.coimage f ≅ Abelian.image f :=
  asIso (coimageImageComparison f)
#align category_theory.abelian.coimage_iso_image CategoryTheory.Abelian.coimageIsoImage
-/

#print CategoryTheory.Abelian.coimageIsoImage' /-
/-- There is a canonical isomorphism between the abelian coimage and the categorical image of a
    morphism. -/
abbrev coimageIsoImage' : Abelian.coimage f ≅ image f :=
  IsImage.isoExt (coimageStrongEpiMonoFactorisation f).toMonoIsImage (Image.isImage f)
#align category_theory.abelian.coimage_iso_image' CategoryTheory.Abelian.coimageIsoImage'
-/

#print CategoryTheory.Abelian.coimageIsoImage'_hom /-
theorem coimageIsoImage'_hom :
    (coimageIsoImage' f).Hom =
      cokernel.desc _ (factorThruImage f) (by simp [← cancel_mono (limits.image.ι f)]) :=
  by
  ext
  simp only [← cancel_mono (limits.image.ι f), is_image.iso_ext_hom, cokernel.π_desc,
    category.assoc, is_image.lift_ι, coimage_strong_epi_mono_factorisation_to_mono_factorisation_m,
    limits.image.fac]
#align category_theory.abelian.coimage_iso_image'_hom CategoryTheory.Abelian.coimageIsoImage'_hom
-/

#print CategoryTheory.Abelian.factorThruImage_comp_coimageIsoImage'_inv /-
theorem factorThruImage_comp_coimageIsoImage'_inv :
    factorThruImage f ≫ (coimageIsoImage' f).inv = cokernel.π _ := by
  simp only [is_image.iso_ext_inv, image.is_image_lift, image.fac_lift,
    coimage_strong_epi_mono_factorisation_to_mono_factorisation_e]
#align category_theory.abelian.factor_thru_image_comp_coimage_iso_image'_inv CategoryTheory.Abelian.factorThruImage_comp_coimageIsoImage'_inv
-/

#print CategoryTheory.Abelian.imageIsoImage /-
/-- There is a canonical isomorphism between the abelian image and the categorical image of a
    morphism. -/
abbrev imageIsoImage : Abelian.image f ≅ image f :=
  IsImage.isoExt (imageStrongEpiMonoFactorisation f).toMonoIsImage (Image.isImage f)
#align category_theory.abelian.image_iso_image CategoryTheory.Abelian.imageIsoImage
-/

#print CategoryTheory.Abelian.imageIsoImage_hom_comp_image_ι /-
theorem imageIsoImage_hom_comp_image_ι : (imageIsoImage f).Hom ≫ Limits.image.ι _ = kernel.ι _ := by
  simp only [is_image.iso_ext_hom, is_image.lift_ι,
    image_strong_epi_mono_factorisation_to_mono_factorisation_m]
#align category_theory.abelian.image_iso_image_hom_comp_image_ι CategoryTheory.Abelian.imageIsoImage_hom_comp_image_ι
-/

#print CategoryTheory.Abelian.imageIsoImage_inv /-
theorem imageIsoImage_inv :
    (imageIsoImage f).inv =
      kernel.lift _ (Limits.image.ι f) (by simp [← cancel_epi (factor_thru_image f)]) :=
  by
  ext
  simp only [is_image.iso_ext_inv, image.is_image_lift, limits.image.fac_lift,
    image_strong_epi_mono_factorisation_to_mono_factorisation_e, category.assoc, kernel.lift_ι,
    limits.image.fac]
#align category_theory.abelian.image_iso_image_inv CategoryTheory.Abelian.imageIsoImage_inv
-/

end Images

section CokernelOfKernel

variable {X Y : C} {f : X ⟶ Y}

attribute [local instance] non_preadditive_abelian

#print CategoryTheory.Abelian.epiIsCokernelOfKernel /-
/-- In an abelian category, an epi is the cokernel of its kernel. More precisely:
    If `f` is an epimorphism and `s` is some limit kernel cone on `f`, then `f` is a cokernel
    of `fork.ι s`. -/
def epiIsCokernelOfKernel [Epi f] (s : Fork f 0) (h : IsLimit s) :
    IsColimit (CokernelCofork.ofπ f (KernelFork.condition s)) :=
  NonPreadditiveAbelian.epiIsCokernelOfKernel s h
#align category_theory.abelian.epi_is_cokernel_of_kernel CategoryTheory.Abelian.epiIsCokernelOfKernel
-/

#print CategoryTheory.Abelian.monoIsKernelOfCokernel /-
/-- In an abelian category, a mono is the kernel of its cokernel. More precisely:
    If `f` is a monomorphism and `s` is some colimit cokernel cocone on `f`, then `f` is a kernel
    of `cofork.π s`. -/
def monoIsKernelOfCokernel [Mono f] (s : Cofork f 0) (h : IsColimit s) :
    IsLimit (KernelFork.ofι f (CokernelCofork.condition s)) :=
  NonPreadditiveAbelian.monoIsKernelOfCokernel s h
#align category_theory.abelian.mono_is_kernel_of_cokernel CategoryTheory.Abelian.monoIsKernelOfCokernel
-/

variable (f)

#print CategoryTheory.Abelian.epiDesc /-
/-- In an abelian category, any morphism that turns to zero when precomposed with the kernel of an
    epimorphism factors through that epimorphism. -/
def epiDesc [Epi f] {T : C} (g : X ⟶ T) (hg : kernel.ι f ≫ g = 0) : Y ⟶ T :=
  (epiIsCokernelOfKernel _ (limit.isLimit _)).desc (CokernelCofork.ofπ _ hg)
#align category_theory.abelian.epi_desc CategoryTheory.Abelian.epiDesc
-/

#print CategoryTheory.Abelian.comp_epiDesc /-
@[simp, reassoc]
theorem comp_epiDesc [Epi f] {T : C} (g : X ⟶ T) (hg : kernel.ι f ≫ g = 0) :
    f ≫ epiDesc f g hg = g :=
  (epiIsCokernelOfKernel _ (limit.isLimit _)).fac (CokernelCofork.ofπ _ hg) WalkingParallelPair.one
#align category_theory.abelian.comp_epi_desc CategoryTheory.Abelian.comp_epiDesc
-/

#print CategoryTheory.Abelian.monoLift /-
/-- In an abelian category, any morphism that turns to zero when postcomposed with the cokernel of a
    monomorphism factors through that monomorphism. -/
def monoLift [Mono f] {T : C} (g : T ⟶ Y) (hg : g ≫ cokernel.π f = 0) : T ⟶ X :=
  (monoIsKernelOfCokernel _ (colimit.isColimit _)).lift (KernelFork.ofι _ hg)
#align category_theory.abelian.mono_lift CategoryTheory.Abelian.monoLift
-/

#print CategoryTheory.Abelian.monoLift_comp /-
@[simp, reassoc]
theorem monoLift_comp [Mono f] {T : C} (g : T ⟶ Y) (hg : g ≫ cokernel.π f = 0) :
    monoLift f g hg ≫ f = g :=
  (monoIsKernelOfCokernel _ (colimit.isColimit _)).fac (KernelFork.ofι _ hg)
    WalkingParallelPair.zero
#align category_theory.abelian.mono_lift_comp CategoryTheory.Abelian.monoLift_comp
-/

end CokernelOfKernel

section

#print CategoryTheory.Abelian.hasEqualizers /-
instance (priority := 100) hasEqualizers : HasEqualizers C :=
  Preadditive.hasEqualizers_of_hasKernels
#align category_theory.abelian.has_equalizers CategoryTheory.Abelian.hasEqualizers
-/

#print CategoryTheory.Abelian.hasPullbacks /-
/-- Any abelian category has pullbacks -/
instance (priority := 100) hasPullbacks : HasPullbacks C :=
  hasPullbacks_of_hasBinaryProducts_of_hasEqualizers C
#align category_theory.abelian.has_pullbacks CategoryTheory.Abelian.hasPullbacks
-/

end

section

#print CategoryTheory.Abelian.hasCoequalizers /-
instance (priority := 100) hasCoequalizers : HasCoequalizers C :=
  Preadditive.hasCoequalizers_of_hasCokernels
#align category_theory.abelian.has_coequalizers CategoryTheory.Abelian.hasCoequalizers
-/

#print CategoryTheory.Abelian.hasPushouts /-
/-- Any abelian category has pushouts -/
instance (priority := 100) hasPushouts : HasPushouts C :=
  hasPushouts_of_hasBinaryCoproducts_of_hasCoequalizers C
#align category_theory.abelian.has_pushouts CategoryTheory.Abelian.hasPushouts
-/

#print CategoryTheory.Abelian.hasFiniteLimits /-
instance (priority := 100) hasFiniteLimits : HasFiniteLimits C :=
  Limits.hasFiniteLimits_of_hasEqualizers_and_finite_products
#align category_theory.abelian.has_finite_limits CategoryTheory.Abelian.hasFiniteLimits
-/

#print CategoryTheory.Abelian.hasFiniteColimits /-
instance (priority := 100) hasFiniteColimits : HasFiniteColimits C :=
  Limits.hasFiniteColimits_of_hasCoequalizers_and_finite_coproducts
#align category_theory.abelian.has_finite_colimits CategoryTheory.Abelian.hasFiniteColimits
-/

end

namespace PullbackToBiproductIsKernel

variable [Limits.HasPullbacks C] {X Y Z : C} (f : X ⟶ Z) (g : Y ⟶ Z)

/-! This section contains a slightly technical result about pullbacks and biproducts.
    We will need it in the proof that the pullback of an epimorphism is an epimorpism. -/


#print CategoryTheory.Abelian.PullbackToBiproductIsKernel.pullbackToBiproduct /-
/-- The canonical map `pullback f g ⟶ X ⊞ Y` -/
abbrev pullbackToBiproduct : pullback f g ⟶ X ⊞ Y :=
  biprod.lift pullback.fst pullback.snd
#align category_theory.abelian.pullback_to_biproduct_is_kernel.pullback_to_biproduct CategoryTheory.Abelian.PullbackToBiproductIsKernel.pullbackToBiproduct
-/

#print CategoryTheory.Abelian.PullbackToBiproductIsKernel.pullbackToBiproductFork /-
/-- The canonical map `pullback f g ⟶ X ⊞ Y` induces a kernel cone on the map
    `biproduct X Y ⟶ Z` induced by `f` and `g`. A slightly more intuitive way to think of
    this may be that it induces an equalizer fork on the maps induced by `(f, 0)` and
    `(0, g)`. -/
abbrev pullbackToBiproductFork : KernelFork (biprod.desc f (-g)) :=
  KernelFork.ofι (pullbackToBiproduct f g) <| by
    rw [biprod.lift_desc, comp_neg, pullback.condition, add_right_neg]
#align category_theory.abelian.pullback_to_biproduct_is_kernel.pullback_to_biproduct_fork CategoryTheory.Abelian.PullbackToBiproductIsKernel.pullbackToBiproductFork
-/

#print CategoryTheory.Abelian.PullbackToBiproductIsKernel.isLimitPullbackToBiproduct /-
/-- The canonical map `pullback f g ⟶ X ⊞ Y` is a kernel of the map induced by
    `(f, -g)`. -/
def isLimitPullbackToBiproduct : IsLimit (pullbackToBiproductFork f g) :=
  Fork.IsLimit.mk _
    (fun s =>
      pullback.lift (Fork.ι s ≫ biprod.fst) (Fork.ι s ≫ biprod.snd) <|
        sub_eq_zero.1 <| by
          rw [category.assoc, category.assoc, ← comp_sub, sub_eq_add_neg, ← comp_neg, ←
            biprod.desc_eq, kernel_fork.condition s])
    (fun s => by
      ext <;> rw [fork.ι_of_ι, category.assoc]
      · rw [biprod.lift_fst, pullback.lift_fst]
      · rw [biprod.lift_snd, pullback.lift_snd])
    fun s m h => by ext <;> simp [← h]
#align category_theory.abelian.pullback_to_biproduct_is_kernel.is_limit_pullback_to_biproduct CategoryTheory.Abelian.PullbackToBiproductIsKernel.isLimitPullbackToBiproduct
-/

end PullbackToBiproductIsKernel

namespace BiproductToPushoutIsCokernel

variable [Limits.HasPushouts C] {W X Y Z : C} (f : X ⟶ Y) (g : X ⟶ Z)

#print CategoryTheory.Abelian.BiproductToPushoutIsCokernel.biproductToPushout /-
/-- The canonical map `Y ⊞ Z ⟶ pushout f g` -/
abbrev biproductToPushout : Y ⊞ Z ⟶ pushout f g :=
  biprod.desc pushout.inl pushout.inr
#align category_theory.abelian.biproduct_to_pushout_is_cokernel.biproduct_to_pushout CategoryTheory.Abelian.BiproductToPushoutIsCokernel.biproductToPushout
-/

#print CategoryTheory.Abelian.BiproductToPushoutIsCokernel.biproductToPushoutCofork /-
/-- The canonical map `Y ⊞ Z ⟶ pushout f g` induces a cokernel cofork on the map
    `X ⟶ Y ⊞ Z` induced by `f` and `-g`. -/
abbrev biproductToPushoutCofork : CokernelCofork (biprod.lift f (-g)) :=
  CokernelCofork.ofπ (biproductToPushout f g) <| by
    rw [biprod.lift_desc, neg_comp, pushout.condition, add_right_neg]
#align category_theory.abelian.biproduct_to_pushout_is_cokernel.biproduct_to_pushout_cofork CategoryTheory.Abelian.BiproductToPushoutIsCokernel.biproductToPushoutCofork
-/

#print CategoryTheory.Abelian.BiproductToPushoutIsCokernel.isColimitBiproductToPushout /-
/-- The cofork induced by the canonical map `Y ⊞ Z ⟶ pushout f g` is in fact a colimit cokernel
    cofork. -/
def isColimitBiproductToPushout : IsColimit (biproductToPushoutCofork f g) :=
  Cofork.IsColimit.mk _
    (fun s =>
      pushout.desc (biprod.inl ≫ Cofork.π s) (biprod.inr ≫ Cofork.π s) <|
        sub_eq_zero.1 <| by
          rw [← category.assoc, ← category.assoc, ← sub_comp, sub_eq_add_neg, ← neg_comp, ←
            biprod.lift_eq, cofork.condition s, zero_comp])
    (fun s => by ext <;> simp) fun s m h => by ext <;> simp [← h]
#align category_theory.abelian.biproduct_to_pushout_is_cokernel.is_colimit_biproduct_to_pushout CategoryTheory.Abelian.BiproductToPushoutIsCokernel.isColimitBiproductToPushout
-/

end BiproductToPushoutIsCokernel

section EpiPullback

variable [Limits.HasPullbacks C] {W X Y Z : C} (f : X ⟶ Z) (g : Y ⟶ Z)

#print CategoryTheory.Abelian.epi_pullback_of_epi_f /-
/-- In an abelian category, the pullback of an epimorphism is an epimorphism.
    Proof from [aluffi2016, IX.2.3], cf. [borceux-vol2, 1.7.6] -/
instance epi_pullback_of_epi_f [Epi f] : Epi (pullback.snd : pullback f g ⟶ Y) :=
  -- It will suffice to consider some morphism e : Y ⟶ R such that
    -- pullback.snd ≫ e = 0 and show that e = 0.
    epi_of_cancel_zero
    _ fun R e h =>
    by
    -- Consider the morphism u := (0, e) : X ⊞ Y⟶ R.
    let u := biprod.desc (0 : X ⟶ R) e
    -- The composite pullback f g ⟶ X ⊞ Y ⟶ R is zero by assumption.
    have hu : pullback_to_biproduct_is_kernel.pullback_to_biproduct f g ≫ u = 0 := by simpa
    -- pullback_to_biproduct f g is a kernel of (f, -g), so (f, -g) is a
    -- cokernel of pullback_to_biproduct f g
    have :=
      epi_is_cokernel_of_kernel _
        (pullback_to_biproduct_is_kernel.is_limit_pullback_to_biproduct f g)
    -- We use this fact to obtain a factorization of u through (f, -g) via some d : Z ⟶ R.
    obtain ⟨d, hd⟩ := cokernel_cofork.is_colimit.desc' this u hu
    change Z ⟶ R at d 
    change biprod.desc f (-g) ≫ d = u at hd 
    -- But then f ≫ d = 0:
    have : f ≫ d = 0;
    calc
      f ≫ d = (biprod.inl ≫ biprod.desc f (-g)) ≫ d := by rw [biprod.inl_desc]
      _ = biprod.inl ≫ u := by rw [category.assoc, hd]
      _ = 0 := biprod.inl_desc _ _
    -- But f is an epimorphism, so d = 0...
    have : d = 0 := (cancel_epi f).1 (by simpa)
    -- ...or, in other words, e = 0.
    calc
      e = biprod.inr ≫ u := by rw [biprod.inr_desc]
      _ = biprod.inr ≫ biprod.desc f (-g) ≫ d := by rw [← hd]
      _ = biprod.inr ≫ biprod.desc f (-g) ≫ 0 := by rw [this]
      _ = (biprod.inr ≫ biprod.desc f (-g)) ≫ 0 := by rw [← category.assoc]
      _ = 0 := has_zero_morphisms.comp_zero _ _
#align category_theory.abelian.epi_pullback_of_epi_f CategoryTheory.Abelian.epi_pullback_of_epi_f
-/

#print CategoryTheory.Abelian.epi_pullback_of_epi_g /-
/-- In an abelian category, the pullback of an epimorphism is an epimorphism. -/
instance epi_pullback_of_epi_g [Epi g] : Epi (pullback.fst : pullback f g ⟶ X) :=
  -- It will suffice to consider some morphism e : X ⟶ R such that
    -- pullback.fst ≫ e = 0 and show that e = 0.
    epi_of_cancel_zero
    _ fun R e h =>
    by
    -- Consider the morphism u := (e, 0) : X ⊞ Y ⟶ R.
    let u := biprod.desc e (0 : Y ⟶ R)
    -- The composite pullback f g ⟶ X ⊞ Y ⟶ R is zero by assumption.
    have hu : pullback_to_biproduct_is_kernel.pullback_to_biproduct f g ≫ u = 0 := by simpa
    -- pullback_to_biproduct f g is a kernel of (f, -g), so (f, -g) is a
    -- cokernel of pullback_to_biproduct f g
    have :=
      epi_is_cokernel_of_kernel _
        (pullback_to_biproduct_is_kernel.is_limit_pullback_to_biproduct f g)
    -- We use this fact to obtain a factorization of u through (f, -g) via some d : Z ⟶ R.
    obtain ⟨d, hd⟩ := cokernel_cofork.is_colimit.desc' this u hu
    change Z ⟶ R at d 
    change biprod.desc f (-g) ≫ d = u at hd 
    -- But then (-g) ≫ d = 0:
    have : (-g) ≫ d = 0;
    calc
      (-g) ≫ d = (biprod.inr ≫ biprod.desc f (-g)) ≫ d := by rw [biprod.inr_desc]
      _ = biprod.inr ≫ u := by rw [category.assoc, hd]
      _ = 0 := biprod.inr_desc _ _
    -- But g is an epimorphism, thus so is -g, so d = 0...
    have : d = 0 := (cancel_epi (-g)).1 (by simpa)
    -- ...or, in other words, e = 0.
    calc
      e = biprod.inl ≫ u := by rw [biprod.inl_desc]
      _ = biprod.inl ≫ biprod.desc f (-g) ≫ d := by rw [← hd]
      _ = biprod.inl ≫ biprod.desc f (-g) ≫ 0 := by rw [this]
      _ = (biprod.inl ≫ biprod.desc f (-g)) ≫ 0 := by rw [← category.assoc]
      _ = 0 := has_zero_morphisms.comp_zero _ _
#align category_theory.abelian.epi_pullback_of_epi_g CategoryTheory.Abelian.epi_pullback_of_epi_g
-/

#print CategoryTheory.Abelian.epi_snd_of_isLimit /-
theorem epi_snd_of_isLimit [Epi f] {s : PullbackCone f g} (hs : IsLimit s) : Epi s.snd :=
  by
  convert epi_of_epi_fac (is_limit.cone_point_unique_up_to_iso_hom_comp (limit.is_limit _) hs _)
  · rfl
  · exact abelian.epi_pullback_of_epi_f _ _
#align category_theory.abelian.epi_snd_of_is_limit CategoryTheory.Abelian.epi_snd_of_isLimit
-/

#print CategoryTheory.Abelian.epi_fst_of_isLimit /-
theorem epi_fst_of_isLimit [Epi g] {s : PullbackCone f g} (hs : IsLimit s) : Epi s.fst :=
  by
  convert epi_of_epi_fac (is_limit.cone_point_unique_up_to_iso_hom_comp (limit.is_limit _) hs _)
  · rfl
  · exact abelian.epi_pullback_of_epi_g _ _
#align category_theory.abelian.epi_fst_of_is_limit CategoryTheory.Abelian.epi_fst_of_isLimit
-/

#print CategoryTheory.Abelian.epi_fst_of_factor_thru_epi_mono_factorization /-
/-- Suppose `f` and `g` are two morphisms with a common codomain and suppose we have written `g` as
    an epimorphism followed by a monomorphism. If `f` factors through the mono part of this
    factorization, then any pullback of `g` along `f` is an epimorphism. -/
theorem epi_fst_of_factor_thru_epi_mono_factorization (g₁ : Y ⟶ W) [Epi g₁] (g₂ : W ⟶ Z) [Mono g₂]
    (hg : g₁ ≫ g₂ = g) (f' : X ⟶ W) (hf : f' ≫ g₂ = f) (t : PullbackCone f g) (ht : IsLimit t) :
    Epi t.fst := by
  apply epi_fst_of_is_limit _ _ (pullback_cone.is_limit_of_factors f g g₂ f' g₁ hf hg t ht)
#align category_theory.abelian.epi_fst_of_factor_thru_epi_mono_factorization CategoryTheory.Abelian.epi_fst_of_factor_thru_epi_mono_factorization
-/

end EpiPullback

section MonoPushout

variable [Limits.HasPushouts C] {W X Y Z : C} (f : X ⟶ Y) (g : X ⟶ Z)

#print CategoryTheory.Abelian.mono_pushout_of_mono_f /-
instance mono_pushout_of_mono_f [Mono f] : Mono (pushout.inr : Z ⟶ pushout f g) :=
  mono_of_cancel_zero _ fun R e h =>
    by
    let u := biprod.lift (0 : R ⟶ Y) e
    have hu : u ≫ biproduct_to_pushout_is_cokernel.biproduct_to_pushout f g = 0 := by simpa
    have :=
      mono_is_kernel_of_cokernel _
        (biproduct_to_pushout_is_cokernel.is_colimit_biproduct_to_pushout f g)
    obtain ⟨d, hd⟩ := kernel_fork.is_limit.lift' this u hu
    change R ⟶ X at d 
    change d ≫ biprod.lift f (-g) = u at hd 
    have : d ≫ f = 0;
    calc
      d ≫ f = d ≫ biprod.lift f (-g) ≫ biprod.fst := by rw [biprod.lift_fst]
      _ = u ≫ biprod.fst := by rw [← category.assoc, hd]
      _ = 0 := biprod.lift_fst _ _
    have : d = 0 := (cancel_mono f).1 (by simpa)
    calc
      e = u ≫ biprod.snd := by rw [biprod.lift_snd]
      _ = (d ≫ biprod.lift f (-g)) ≫ biprod.snd := by rw [← hd]
      _ = (0 ≫ biprod.lift f (-g)) ≫ biprod.snd := by rw [this]
      _ = 0 ≫ biprod.lift f (-g) ≫ biprod.snd := by rw [category.assoc]
      _ = 0 := zero_comp
#align category_theory.abelian.mono_pushout_of_mono_f CategoryTheory.Abelian.mono_pushout_of_mono_f
-/

#print CategoryTheory.Abelian.mono_pushout_of_mono_g /-
instance mono_pushout_of_mono_g [Mono g] : Mono (pushout.inl : Y ⟶ pushout f g) :=
  mono_of_cancel_zero _ fun R e h =>
    by
    let u := biprod.lift e (0 : R ⟶ Z)
    have hu : u ≫ biproduct_to_pushout_is_cokernel.biproduct_to_pushout f g = 0 := by simpa
    have :=
      mono_is_kernel_of_cokernel _
        (biproduct_to_pushout_is_cokernel.is_colimit_biproduct_to_pushout f g)
    obtain ⟨d, hd⟩ := kernel_fork.is_limit.lift' this u hu
    change R ⟶ X at d 
    change d ≫ biprod.lift f (-g) = u at hd 
    have : d ≫ (-g) = 0;
    calc
      d ≫ (-g) = d ≫ biprod.lift f (-g) ≫ biprod.snd := by rw [biprod.lift_snd]
      _ = u ≫ biprod.snd := by rw [← category.assoc, hd]
      _ = 0 := biprod.lift_snd _ _
    have : d = 0 := (cancel_mono (-g)).1 (by simpa)
    calc
      e = u ≫ biprod.fst := by rw [biprod.lift_fst]
      _ = (d ≫ biprod.lift f (-g)) ≫ biprod.fst := by rw [← hd]
      _ = (0 ≫ biprod.lift f (-g)) ≫ biprod.fst := by rw [this]
      _ = 0 ≫ biprod.lift f (-g) ≫ biprod.fst := by rw [category.assoc]
      _ = 0 := zero_comp
#align category_theory.abelian.mono_pushout_of_mono_g CategoryTheory.Abelian.mono_pushout_of_mono_g
-/

#print CategoryTheory.Abelian.mono_inr_of_isColimit /-
theorem mono_inr_of_isColimit [Mono f] {s : PushoutCocone f g} (hs : IsColimit s) : Mono s.inr :=
  by
  convert
    mono_of_mono_fac (is_colimit.comp_cocone_point_unique_up_to_iso_hom hs (colimit.is_colimit _) _)
  · rfl
  · exact abelian.mono_pushout_of_mono_f _ _
#align category_theory.abelian.mono_inr_of_is_colimit CategoryTheory.Abelian.mono_inr_of_isColimit
-/

#print CategoryTheory.Abelian.mono_inl_of_isColimit /-
theorem mono_inl_of_isColimit [Mono g] {s : PushoutCocone f g} (hs : IsColimit s) : Mono s.inl :=
  by
  convert
    mono_of_mono_fac (is_colimit.comp_cocone_point_unique_up_to_iso_hom hs (colimit.is_colimit _) _)
  · rfl
  · exact abelian.mono_pushout_of_mono_g _ _
#align category_theory.abelian.mono_inl_of_is_colimit CategoryTheory.Abelian.mono_inl_of_isColimit
-/

#print CategoryTheory.Abelian.mono_inl_of_factor_thru_epi_mono_factorization /-
/-- Suppose `f` and `g` are two morphisms with a common domain and suppose we have written `g` as
    an epimorphism followed by a monomorphism. If `f` factors through the epi part of this
    factorization, then any pushout of `g` along `f` is a monomorphism. -/
theorem mono_inl_of_factor_thru_epi_mono_factorization (f : X ⟶ Y) (g : X ⟶ Z) (g₁ : X ⟶ W) [Epi g₁]
    (g₂ : W ⟶ Z) [Mono g₂] (hg : g₁ ≫ g₂ = g) (f' : W ⟶ Y) (hf : g₁ ≫ f' = f)
    (t : PushoutCocone f g) (ht : IsColimit t) : Mono t.inl := by
  apply mono_inl_of_is_colimit _ _ (pushout_cocone.is_colimit_of_factors _ _ _ _ _ hf hg t ht)
#align category_theory.abelian.mono_inl_of_factor_thru_epi_mono_factorization CategoryTheory.Abelian.mono_inl_of_factor_thru_epi_mono_factorization
-/

end MonoPushout

end CategoryTheory.Abelian

namespace CategoryTheory.NonPreadditiveAbelian

variable (C : Type u) [Category.{v} C] [NonPreadditiveAbelian C]

#print CategoryTheory.NonPreadditiveAbelian.abelian /-
/-- Every non_preadditive_abelian category can be promoted to an abelian category. -/
def abelian : Abelian C :=
  {/- We need the `convert`s here because the instances we have are slightly different from the
       instances we need: `has_kernels` depends on an instance of `has_zero_morphisms`. In the
       case of `non_preadditive_abelian`, this instance is an explicit argument. However, in the case
       of `abelian`, the `has_zero_morphisms` instance is derived from `preadditive`. So we need to
       transform an instance of "has kernels with non_preadditive_abelian.has_zero_morphisms" to an
       instance of "has kernels with non_preadditive_abelian.preadditive.has_zero_morphisms". Luckily,
       we have a `subsingleton` instance for `has_zero_morphisms`, so `convert` can immediately close
       the goal it creates for the two instances of `has_zero_morphisms`, and the proof is complete. -/
    NonPreadditiveAbelian.preadditive with
    HasFiniteProducts := by infer_instance
    HasKernels := by convert (by infer_instance : limits.has_kernels C)
    HasCokernels := by convert (by infer_instance : limits.has_cokernels C)
    normalMonoOfMono := by intros; convert normal_mono_of_mono f
    normalEpiOfEpi := by intros; convert normal_epi_of_epi f }
#align category_theory.non_preadditive_abelian.abelian CategoryTheory.NonPreadditiveAbelian.abelian
-/

end CategoryTheory.NonPreadditiveAbelian

