/-
Copyright (c) 2020 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module algebra.homology.exact
! leanprover-community/mathlib commit 8eb9c42d4d34c77f6ee84ea766ae4070233a973c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Homology.ImageToKernel

/-!
# Exact sequences

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In a category with zero morphisms, images, and equalizers we say that `f : A ⟶ B` and `g : B ⟶ C`
are exact if `f ≫ g = 0` and the natural map `image f ⟶ kernel g` is an epimorphism.

In any preadditive category this is equivalent to the homology at `B` vanishing.

However in general it is weaker than other reasonable definitions of exactness,
particularly that
1. the inclusion map `image.ι f` is a kernel of `g` or
2. `image f ⟶ kernel g` is an isomorphism or
3. `image_subobject f = kernel_subobject f`.
However when the category is abelian, these all become equivalent;
these results are found in `category_theory/abelian/exact.lean`.

# Main results
* Suppose that cokernels exist and that `f` and `g` are exact.
  If `s` is any kernel fork over `g` and `t` is any cokernel cofork over `f`,
  then `fork.ι s ≫ cofork.π t = 0`.
* Precomposing the first morphism with an epimorphism retains exactness.
  Postcomposing the second morphism with a monomorphism retains exactness.
* If `f` and `g` are exact and `i` is an isomorphism,
  then `f ≫ i.hom` and `i.inv ≫ g` are also exact.

# Future work
* Short exact sequences, split exact sequences, the splitting lemma (maybe only for abelian
  categories?)
* Two adjacent maps in a chain complex are exact iff the homology vanishes

-/


universe v v₂ u u₂

open CategoryTheory

open CategoryTheory.Limits

variable {V : Type u} [Category.{v} V]

variable [HasImages V]

namespace CategoryTheory

#print CategoryTheory.Exact /-
-- One nice feature of this definition is that we have
-- `epi f → exact g h → exact (f ≫ g) h` and `exact f g → mono h → exact f (g ≫ h)`,
-- which do not necessarily hold in a non-abelian category with the usual definition of `exact`.
/-- Two morphisms `f : A ⟶ B`, `g : B ⟶ C` are called exact if `w : f ≫ g = 0` and the natural map
`image_to_kernel f g w : image_subobject f ⟶ kernel_subobject g` is an epimorphism.

In any preadditive category, this is equivalent to `w : f ≫ g = 0` and `homology f g w ≅ 0`.

In an abelian category, this is equivalent to `image_to_kernel f g w` being an isomorphism,
and hence equivalent to the usual definition,
`image_subobject f = kernel_subobject g`.
-/
structure Exact [HasZeroMorphisms V] [HasKernels V] {A B C : V} (f : A ⟶ B) (g : B ⟶ C) : Prop where
  w : f ≫ g = 0
  Epi : Epi (imageToKernel f g w)
#align category_theory.exact CategoryTheory.Exact
-/

-- This works as an instance even though `exact` itself is not a class, as long as the goal is
-- literally of the form `epi (image_to_kernel f g h.w)` (where `h : exact f g`). If the proof of
-- `f ≫ g = 0` looks different, we are out of luck and have to add the instance by hand.
attribute [instance] exact.epi

attribute [reassoc] exact.w

section

variable [HasZeroObject V] [Preadditive V] [HasKernels V] [HasCokernels V]

open scoped ZeroObject

#print CategoryTheory.Preadditive.exact_iff_homology_zero /-
/-- In any preadditive category,
composable morphisms `f g` are exact iff they compose to zero and the homology vanishes.
-/
theorem Preadditive.exact_iff_homology_zero {A B C : V} (f : A ⟶ B) (g : B ⟶ C) :
    Exact f g ↔ ∃ w : f ≫ g = 0, Nonempty (homology f g w ≅ 0) :=
  ⟨fun h => ⟨h.w, ⟨cokernel.ofEpi _⟩⟩, fun h =>
    by
    obtain ⟨w, ⟨i⟩⟩ := h
    exact ⟨w, preadditive.epi_of_cokernel_zero ((cancel_mono i.hom).mp (by ext))⟩⟩
#align category_theory.preadditive.exact_iff_homology_zero CategoryTheory.Preadditive.exact_iff_homology_zero
-/

#print CategoryTheory.Preadditive.exact_of_iso_of_exact /-
theorem Preadditive.exact_of_iso_of_exact {A₁ B₁ C₁ A₂ B₂ C₂ : V} (f₁ : A₁ ⟶ B₁) (g₁ : B₁ ⟶ C₁)
    (f₂ : A₂ ⟶ B₂) (g₂ : B₂ ⟶ C₂) (α : Arrow.mk f₁ ≅ Arrow.mk f₂) (β : Arrow.mk g₁ ≅ Arrow.mk g₂)
    (p : α.Hom.right = β.Hom.left) (h : Exact f₁ g₁) : Exact f₂ g₂ :=
  by
  rw [preadditive.exact_iff_homology_zero] at h ⊢
  rcases h with ⟨w₁, ⟨i⟩⟩
  suffices w₂ : f₂ ≫ g₂ = 0; exact ⟨w₂, ⟨(homology.mapIso w₁ w₂ α β p).symm.trans i⟩⟩
  rw [← cancel_epi α.hom.left, ← cancel_mono β.inv.right, comp_zero, zero_comp, ← w₁]
  simp only [← arrow.mk_hom f₁, ← arrow.left_hom_inv_right α.hom, ← arrow.mk_hom g₁, ←
    arrow.left_hom_inv_right β.hom, p]
  simp only [arrow.mk_hom, is_iso.inv_hom_id_assoc, category.assoc, ← arrow.inv_right,
    is_iso.iso.inv_hom]
#align category_theory.preadditive.exact_of_iso_of_exact CategoryTheory.Preadditive.exact_of_iso_of_exact
-/

#print CategoryTheory.Preadditive.exact_of_iso_of_exact' /-
/-- A reformulation of `preadditive.exact_of_iso_of_exact` that does not involve the arrow
category. -/
theorem Preadditive.exact_of_iso_of_exact' {A₁ B₁ C₁ A₂ B₂ C₂ : V} (f₁ : A₁ ⟶ B₁) (g₁ : B₁ ⟶ C₁)
    (f₂ : A₂ ⟶ B₂) (g₂ : B₂ ⟶ C₂) (α : A₁ ≅ A₂) (β : B₁ ≅ B₂) (γ : C₁ ≅ C₂)
    (hsq₁ : α.Hom ≫ f₂ = f₁ ≫ β.Hom) (hsq₂ : β.Hom ≫ g₂ = g₁ ≫ γ.Hom) (h : Exact f₁ g₁) :
    Exact f₂ g₂ :=
  Preadditive.exact_of_iso_of_exact f₁ g₁ f₂ g₂ (Arrow.isoMk α β hsq₁) (Arrow.isoMk β γ hsq₂) rfl h
#align category_theory.preadditive.exact_of_iso_of_exact' CategoryTheory.Preadditive.exact_of_iso_of_exact'
-/

#print CategoryTheory.Preadditive.exact_iff_exact_of_iso /-
theorem Preadditive.exact_iff_exact_of_iso {A₁ B₁ C₁ A₂ B₂ C₂ : V} (f₁ : A₁ ⟶ B₁) (g₁ : B₁ ⟶ C₁)
    (f₂ : A₂ ⟶ B₂) (g₂ : B₂ ⟶ C₂) (α : Arrow.mk f₁ ≅ Arrow.mk f₂) (β : Arrow.mk g₁ ≅ Arrow.mk g₂)
    (p : α.Hom.right = β.Hom.left) : Exact f₁ g₁ ↔ Exact f₂ g₂ :=
  ⟨Preadditive.exact_of_iso_of_exact _ _ _ _ _ _ p,
    Preadditive.exact_of_iso_of_exact _ _ _ _ α.symm β.symm
      (by
        rw [← cancel_mono α.hom.right]
        simp only [iso.symm_hom, ← comma.comp_right, α.inv_hom_id]
        simp only [p, ← comma.comp_left, arrow.id_right, arrow.id_left, iso.inv_hom_id]
        rfl)⟩
#align category_theory.preadditive.exact_iff_exact_of_iso CategoryTheory.Preadditive.exact_iff_exact_of_iso
-/

end

section

variable [HasZeroMorphisms V] [HasKernels V]

#print CategoryTheory.comp_eq_zero_of_image_eq_kernel /-
theorem comp_eq_zero_of_image_eq_kernel {A B C : V} (f : A ⟶ B) (g : B ⟶ C)
    (p : imageSubobject f = kernelSubobject g) : f ≫ g = 0 :=
  by
  rw [← image_subobject_arrow_comp f, category.assoc]
  convert comp_zero
  rw [p]
  simp
#align category_theory.comp_eq_zero_of_image_eq_kernel CategoryTheory.comp_eq_zero_of_image_eq_kernel
-/

#print CategoryTheory.imageToKernel_isIso_of_image_eq_kernel /-
theorem imageToKernel_isIso_of_image_eq_kernel {A B C : V} (f : A ⟶ B) (g : B ⟶ C)
    (p : imageSubobject f = kernelSubobject g) :
    IsIso (imageToKernel f g (comp_eq_zero_of_image_eq_kernel f g p)) :=
  by
  refine' ⟨⟨subobject.of_le _ _ p.ge, _⟩⟩
  dsimp [imageToKernel]
  simp only [subobject.of_le_comp_of_le, subobject.of_le_refl]
  simp
#align category_theory.image_to_kernel_is_iso_of_image_eq_kernel CategoryTheory.imageToKernel_isIso_of_image_eq_kernel
-/

#print CategoryTheory.exact_of_image_eq_kernel /-
-- We'll prove the converse later, when `V` is abelian.
theorem exact_of_image_eq_kernel {A B C : V} (f : A ⟶ B) (g : B ⟶ C)
    (p : imageSubobject f = kernelSubobject g) : Exact f g :=
  { w := comp_eq_zero_of_image_eq_kernel f g p
    Epi := by
      haveI := image_to_kernel_is_iso_of_image_eq_kernel f g p
      infer_instance }
#align category_theory.exact_of_image_eq_kernel CategoryTheory.exact_of_image_eq_kernel
-/

end

variable {A B C D : V} {f : A ⟶ B} {g : B ⟶ C} {h : C ⟶ D}

attribute [local instance] epi_comp

section

variable [HasZeroMorphisms V] [HasEqualizers V]

#print CategoryTheory.exact_comp_hom_inv_comp /-
theorem exact_comp_hom_inv_comp (i : B ≅ D) (h : Exact f g) : Exact (f ≫ i.Hom) (i.inv ≫ g) :=
  by
  refine' ⟨by simp [h.w], _⟩
  rw [imageToKernel_comp_hom_inv_comp]
  haveI := h.epi
  infer_instance
#align category_theory.exact_comp_hom_inv_comp CategoryTheory.exact_comp_hom_inv_comp
-/

#print CategoryTheory.exact_comp_inv_hom_comp /-
theorem exact_comp_inv_hom_comp (i : D ≅ B) (h : Exact f g) : Exact (f ≫ i.inv) (i.Hom ≫ g) :=
  exact_comp_hom_inv_comp i.symm h
#align category_theory.exact_comp_inv_hom_comp CategoryTheory.exact_comp_inv_hom_comp
-/

#print CategoryTheory.exact_comp_hom_inv_comp_iff /-
theorem exact_comp_hom_inv_comp_iff (i : B ≅ D) : Exact (f ≫ i.Hom) (i.inv ≫ g) ↔ Exact f g :=
  ⟨fun h => by simpa using exact_comp_inv_hom_comp i h, exact_comp_hom_inv_comp i⟩
#align category_theory.exact_comp_hom_inv_comp_iff CategoryTheory.exact_comp_hom_inv_comp_iff
-/

#print CategoryTheory.exact_epi_comp /-
theorem exact_epi_comp (hgh : Exact g h) [Epi f] : Exact (f ≫ g) h :=
  by
  refine' ⟨by simp [hgh.w], _⟩
  rw [imageToKernel_comp_left]
  infer_instance
#align category_theory.exact_epi_comp CategoryTheory.exact_epi_comp
-/

#print CategoryTheory.exact_iso_comp /-
@[simp]
theorem exact_iso_comp [IsIso f] : Exact (f ≫ g) h ↔ Exact g h :=
  ⟨fun w => by rw [← is_iso.inv_hom_id_assoc f g]; exact exact_epi_comp w, fun w =>
    exact_epi_comp w⟩
#align category_theory.exact_iso_comp CategoryTheory.exact_iso_comp
-/

#print CategoryTheory.exact_comp_mono /-
theorem exact_comp_mono (hfg : Exact f g) [Mono h] : Exact f (g ≫ h) :=
  by
  refine' ⟨by simp [hfg.w_assoc], _⟩
  rw [imageToKernel_comp_right f g h hfg.w]
  infer_instance
#align category_theory.exact_comp_mono CategoryTheory.exact_comp_mono
-/

#print CategoryTheory.exact_comp_mono_iff /-
/-- The dual of this lemma is only true when `V` is abelian, see `abelian.exact_epi_comp_iff`. -/
theorem exact_comp_mono_iff [Mono h] : Exact f (g ≫ h) ↔ Exact f g :=
  by
  refine'
    ⟨fun hfg => ⟨zero_of_comp_mono h (by rw [category.assoc, hfg.1]), _⟩, fun h =>
      exact_comp_mono h⟩
  rw [← (iso.eq_comp_inv _).1 (imageToKernel_comp_mono _ _ h hfg.1)]
  haveI := hfg.2; infer_instance
#align category_theory.exact_comp_mono_iff CategoryTheory.exact_comp_mono_iff
-/

#print CategoryTheory.exact_comp_iso /-
@[simp]
theorem exact_comp_iso [IsIso h] : Exact f (g ≫ h) ↔ Exact f g :=
  exact_comp_mono_iff
#align category_theory.exact_comp_iso CategoryTheory.exact_comp_iso
-/

#print CategoryTheory.exact_kernelSubobject_arrow /-
theorem exact_kernelSubobject_arrow : Exact (kernelSubobject f).arrow f :=
  by
  refine' ⟨by simp, _⟩
  apply @is_iso.epi_of_iso _ _ _ _ _ _
  exact ⟨⟨factor_thru_image_subobject _, by ext; simp, by ext; simp⟩⟩
#align category_theory.exact_kernel_subobject_arrow CategoryTheory.exact_kernelSubobject_arrow
-/

#print CategoryTheory.exact_kernel_ι /-
theorem exact_kernel_ι : Exact (kernel.ι f) f := by rw [← kernel_subobject_arrow', exact_iso_comp];
  exact exact_kernel_subobject_arrow
#align category_theory.exact_kernel_ι CategoryTheory.exact_kernel_ι
-/

instance (h : Exact f g) : Epi (factorThruKernelSubobject g f h.w) :=
  by
  rw [← factorThruImageSubobject_comp_imageToKernel]
  apply epi_comp

instance (h : Exact f g) : Epi (kernel.lift g f h.w) :=
  by
  rw [← factor_thru_kernel_subobject_comp_kernel_subobject_iso]
  apply epi_comp

variable (A)

#print CategoryTheory.kernelSubobject_arrow_eq_zero_of_exact_zero_left /-
theorem kernelSubobject_arrow_eq_zero_of_exact_zero_left (h : Exact (0 : A ⟶ B) g) :
    (kernelSubobject g).arrow = 0 :=
  by
  rw [← cancel_epi (imageToKernel (0 : A ⟶ B) g h.w), ←
    cancel_epi (factor_thru_image_subobject (0 : A ⟶ B))]
  simp
#align category_theory.kernel_subobject_arrow_eq_zero_of_exact_zero_left CategoryTheory.kernelSubobject_arrow_eq_zero_of_exact_zero_left
-/

#print CategoryTheory.kernel_ι_eq_zero_of_exact_zero_left /-
theorem kernel_ι_eq_zero_of_exact_zero_left (h : Exact (0 : A ⟶ B) g) : kernel.ι g = 0 := by
  rw [← kernel_subobject_arrow']; simp [kernel_subobject_arrow_eq_zero_of_exact_zero_left A h]
#align category_theory.kernel_ι_eq_zero_of_exact_zero_left CategoryTheory.kernel_ι_eq_zero_of_exact_zero_left
-/

#print CategoryTheory.exact_zero_left_of_mono /-
theorem exact_zero_left_of_mono [HasZeroObject V] [Mono g] : Exact (0 : A ⟶ B) g :=
  ⟨by simp, imageToKernel_epi_of_zero_of_mono _⟩
#align category_theory.exact_zero_left_of_mono CategoryTheory.exact_zero_left_of_mono
-/

end

section HasCokernels

variable [HasZeroMorphisms V] [HasEqualizers V] [HasCokernels V] (f g)

#print CategoryTheory.kernel_comp_cokernel /-
@[simp, reassoc]
theorem kernel_comp_cokernel (h : Exact f g) : kernel.ι g ≫ cokernel.π f = 0 :=
  by
  rw [← kernel_subobject_arrow', category.assoc]
  convert comp_zero
  apply zero_of_epi_comp (imageToKernel f g h.w) _
  rw [imageToKernel_arrow_assoc, ← image_subobject_arrow, category.assoc, ← iso.eq_inv_comp]
  ext
  simp
#align category_theory.kernel_comp_cokernel CategoryTheory.kernel_comp_cokernel
-/

#print CategoryTheory.comp_eq_zero_of_exact /-
theorem comp_eq_zero_of_exact (h : Exact f g) {X Y : V} {ι : X ⟶ B} (hι : ι ≫ g = 0) {π : B ⟶ Y}
    (hπ : f ≫ π = 0) : ι ≫ π = 0 := by
  rw [← kernel.lift_ι _ _ hι, ← cokernel.π_desc _ _ hπ, category.assoc,
    kernel_comp_cokernel_assoc _ _ h, zero_comp, comp_zero]
#align category_theory.comp_eq_zero_of_exact CategoryTheory.comp_eq_zero_of_exact
-/

#print CategoryTheory.fork_ι_comp_cofork_π /-
@[simp, reassoc]
theorem fork_ι_comp_cofork_π (h : Exact f g) (s : KernelFork g) (t : CokernelCofork f) :
    Fork.ι s ≫ Cofork.π t = 0 :=
  comp_eq_zero_of_exact f g h (KernelFork.condition s) (CokernelCofork.condition t)
#align category_theory.fork_ι_comp_cofork_π CategoryTheory.fork_ι_comp_cofork_π
-/

end HasCokernels

section

variable [HasZeroObject V]

open scoped ZeroObject

section

variable [HasZeroMorphisms V] [HasKernels V]

#print CategoryTheory.exact_of_zero /-
theorem exact_of_zero {A C : V} (f : A ⟶ 0) (g : 0 ⟶ C) : Exact f g :=
  by
  obtain rfl : f = 0 := by ext
  obtain rfl : g = 0 := by ext
  fconstructor
  · simp
  · exact imageToKernel_epi_of_zero_of_mono 0
#align category_theory.exact_of_zero CategoryTheory.exact_of_zero
-/

#print CategoryTheory.exact_zero_mono /-
theorem exact_zero_mono {B C : V} (f : B ⟶ C) [Mono f] : Exact (0 : 0 ⟶ B) f :=
  ⟨by simp, inferInstance⟩
#align category_theory.exact_zero_mono CategoryTheory.exact_zero_mono
-/

#print CategoryTheory.exact_epi_zero /-
theorem exact_epi_zero {A B : V} (f : A ⟶ B) [Epi f] : Exact f (0 : B ⟶ 0) :=
  ⟨by simp, inferInstance⟩
#align category_theory.exact_epi_zero CategoryTheory.exact_epi_zero
-/

end

section

variable [Preadditive V]

#print CategoryTheory.mono_iff_exact_zero_left /-
theorem mono_iff_exact_zero_left [HasKernels V] {B C : V} (f : B ⟶ C) :
    Mono f ↔ Exact (0 : 0 ⟶ B) f :=
  ⟨fun h => exact_zero_mono _, fun h =>
    Preadditive.mono_of_kernel_iso_zero
      ((kernelSubobjectIso f).symm ≪≫ isoZeroOfEpiZero (by simpa using h.epi))⟩
#align category_theory.mono_iff_exact_zero_left CategoryTheory.mono_iff_exact_zero_left
-/

#print CategoryTheory.epi_iff_exact_zero_right /-
theorem epi_iff_exact_zero_right [HasEqualizers V] {A B : V} (f : A ⟶ B) :
    Epi f ↔ Exact f (0 : B ⟶ 0) :=
  ⟨fun h => exact_epi_zero _, fun h => by
    have e₁ := h.epi
    rw [imageToKernel_zero_right] at e₁ 
    have e₂ :
      epi
        (((image_subobject f).arrow ≫ inv (kernel_subobject 0).arrow) ≫
          (kernel_subobject 0).arrow) :=
      @epi_comp _ _ _ _ _ _ e₁ _ _
    rw [category.assoc, is_iso.inv_hom_id, category.comp_id] at e₂ 
    rw [← image_subobject_arrow] at e₂ 
    skip
    haveI : epi (image.ι f) := epi_of_epi (image_subobject_iso f).Hom (image.ι f)
    apply epi_of_epi_image⟩
#align category_theory.epi_iff_exact_zero_right CategoryTheory.epi_iff_exact_zero_right
-/

end

end

namespace Functor

variable [HasZeroMorphisms V] [HasKernels V] {W : Type u₂} [Category.{v₂} W]

variable [HasImages W] [HasZeroMorphisms W] [HasKernels W]

#print CategoryTheory.Functor.ReflectsExactSequences /-
/-- A functor reflects exact sequences if any composable pair of morphisms that is mapped to an
    exact pair is itself exact. -/
class ReflectsExactSequences (F : V ⥤ W) where
  reflects : ∀ {A B C : V} (f : A ⟶ B) (g : B ⟶ C), Exact (F.map f) (F.map g) → Exact f g
#align category_theory.functor.reflects_exact_sequences CategoryTheory.Functor.ReflectsExactSequences
-/

#print CategoryTheory.Functor.exact_of_exact_map /-
theorem exact_of_exact_map (F : V ⥤ W) [ReflectsExactSequences F] {A B C : V} {f : A ⟶ B}
    {g : B ⟶ C} (hfg : Exact (F.map f) (F.map g)) : Exact f g :=
  ReflectsExactSequences.reflects f g hfg
#align category_theory.functor.exact_of_exact_map CategoryTheory.Functor.exact_of_exact_map
-/

end Functor

end CategoryTheory

