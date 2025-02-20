/-
Copyright (c) 2022 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang

! This file was ported from Lean 3 source module category_theory.sites.surjective
! leanprover-community/mathlib commit 087c325ae0ab42dbdd5dee55bc37d3d5a0bf2197
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Sites.Subsheaf
import Mathbin.CategoryTheory.Sites.CompatibleSheafification

/-!

# Locally surjective morphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

- `is_locally_surjective` : A morphism of presheaves valued in a concrete category is locally
  surjective with respect to a grothendieck topology if every section in the target is locally
  in the set-theoretic image, i.e. the image sheaf coincides with the target.

## Main results

- `to_sheafify_is_locally_surjective` : `to_sheafify` is locally surjective.

-/


universe v u w v' u' w'

open Opposite CategoryTheory CategoryTheory.GrothendieckTopology

namespace CategoryTheory

variable {C : Type u} [Category.{v} C] (J : GrothendieckTopology C)

attribute [local instance] concrete_category.has_coe_to_sort concrete_category.has_coe_to_fun

variable {A : Type u'} [Category.{v'} A] [ConcreteCategory.{w'} A]

#print CategoryTheory.imageSieve /-
/-- Given `f : F ⟶ G`, a morphism between presieves, and `s : G.obj (op U)`, this is the sieve
of `U` consisting of the `i : V ⟶ U` such that `s` restricted along `i` is in the image of `f`. -/
@[simps (config := lemmasOnly)]
def imageSieve {F G : Cᵒᵖ ⥤ A} (f : F ⟶ G) {U : C} (s : G.obj (op U)) : Sieve U
    where
  arrows V i := ∃ t : F.obj (op V), f.app _ t = G.map i.op s
  downward_closed' := by
    rintro V W i ⟨t, ht⟩ j
    refine' ⟨F.map j.op t, _⟩
    rw [op_comp, G.map_comp, comp_apply, ← ht, elementwise_of f.naturality]
#align category_theory.image_sieve CategoryTheory.imageSieve
-/

#print CategoryTheory.imageSieve_eq_sieveOfSection /-
theorem imageSieve_eq_sieveOfSection {F G : Cᵒᵖ ⥤ A} (f : F ⟶ G) {U : C} (s : G.obj (op U)) :
    imageSieve f s = (imagePresheaf (whiskerRight f (forget A))).sieveOfSection s :=
  rfl
#align category_theory.image_sieve_eq_sieve_of_section CategoryTheory.imageSieve_eq_sieveOfSection
-/

#print CategoryTheory.imageSieve_whisker_forget /-
theorem imageSieve_whisker_forget {F G : Cᵒᵖ ⥤ A} (f : F ⟶ G) {U : C} (s : G.obj (op U)) :
    imageSieve (whiskerRight f (forget A)) s = imageSieve f s :=
  rfl
#align category_theory.image_sieve_whisker_forget CategoryTheory.imageSieve_whisker_forget
-/

#print CategoryTheory.imageSieve_app /-
theorem imageSieve_app {F G : Cᵒᵖ ⥤ A} (f : F ⟶ G) {U : C} (s : F.obj (op U)) :
    imageSieve f (f.app _ s) = ⊤ := by
  ext V i
  simp only [sieve.top_apply, iff_true_iff, image_sieve_apply]
  have := elementwise_of (f.naturality i.op)
  exact ⟨F.map i.op s, this s⟩
#align category_theory.image_sieve_app CategoryTheory.imageSieve_app
-/

#print CategoryTheory.IsLocallySurjective /-
/-- A morphism of presheaves `f : F ⟶ G` is locally surjective with respect to a grothendieck
topology if every section of `G` is locally in the image of `f`. -/
def IsLocallySurjective {F G : Cᵒᵖ ⥤ A} (f : F ⟶ G) : Prop :=
  ∀ (U : C) (s : G.obj (op U)), imageSieve f s ∈ J U
#align category_theory.is_locally_surjective CategoryTheory.IsLocallySurjective
-/

#print CategoryTheory.isLocallySurjective_iff_imagePresheaf_sheafify_eq_top /-
theorem isLocallySurjective_iff_imagePresheaf_sheafify_eq_top {F G : Cᵒᵖ ⥤ A} (f : F ⟶ G) :
    IsLocallySurjective J f ↔ (imagePresheaf (whiskerRight f (forget A))).sheafify J = ⊤ :=
  by
  simp only [subpresheaf.ext_iff, Function.funext_iff, Set.ext_iff, top_subpresheaf_obj,
    Set.top_eq_univ, Set.mem_univ, iff_true_iff]
  exact ⟨fun H U => H (unop U), fun H U => H (op U)⟩
#align category_theory.is_locally_surjective_iff_image_presheaf_sheafify_eq_top CategoryTheory.isLocallySurjective_iff_imagePresheaf_sheafify_eq_top
-/

#print CategoryTheory.isLocallySurjective_iff_imagePresheaf_sheafify_eq_top' /-
theorem isLocallySurjective_iff_imagePresheaf_sheafify_eq_top' {F G : Cᵒᵖ ⥤ Type w} (f : F ⟶ G) :
    IsLocallySurjective J f ↔ (imagePresheaf f).sheafify J = ⊤ :=
  by
  simp only [subpresheaf.ext_iff, Function.funext_iff, Set.ext_iff, top_subpresheaf_obj,
    Set.top_eq_univ, Set.mem_univ, iff_true_iff]
  exact ⟨fun H U => H (unop U), fun H U => H (op U)⟩
#align category_theory.is_locally_surjective_iff_image_presheaf_sheafify_eq_top' CategoryTheory.isLocallySurjective_iff_imagePresheaf_sheafify_eq_top'
-/

#print CategoryTheory.isLocallySurjective_iff_isIso /-
theorem isLocallySurjective_iff_isIso {F G : Sheaf J (Type w)} (f : F ⟶ G) :
    IsLocallySurjective J f.1 ↔ IsIso (imageSheafι f) :=
  by
  rw [image_sheaf_ι, is_locally_surjective_iff_image_presheaf_sheafify_eq_top',
    subpresheaf.eq_top_iff_is_iso]
  exact
    ⟨fun h => @is_iso_of_reflects_iso _ _ (image_sheaf_ι f) (Sheaf_to_presheaf J _) h _, fun h =>
      @functor.map_is_iso _ _ (Sheaf_to_presheaf J _) _ h⟩
#align category_theory.is_locally_surjective_iff_is_iso CategoryTheory.isLocallySurjective_iff_isIso
-/

#print CategoryTheory.isLocallySurjective_iff_whisker_forget /-
theorem isLocallySurjective_iff_whisker_forget {F G : Cᵒᵖ ⥤ A} (f : F ⟶ G) :
    IsLocallySurjective J f ↔ IsLocallySurjective J (whiskerRight f (forget A)) := by
  simpa only [is_locally_surjective_iff_image_presheaf_sheafify_eq_top]
#align category_theory.is_locally_surjective_iff_whisker_forget CategoryTheory.isLocallySurjective_iff_whisker_forget
-/

#print CategoryTheory.isLocallySurjective_of_surjective /-
theorem isLocallySurjective_of_surjective {F G : Cᵒᵖ ⥤ A} (f : F ⟶ G)
    (H : ∀ U, Function.Surjective (f.app U)) : IsLocallySurjective J f :=
  by
  intro U s
  obtain ⟨t, rfl⟩ := H _ s
  rw [image_sieve_app]
  exact J.top_mem _
#align category_theory.is_locally_surjective_of_surjective CategoryTheory.isLocallySurjective_of_surjective
-/

#print CategoryTheory.isLocallySurjective_of_iso /-
theorem isLocallySurjective_of_iso {F G : Cᵒᵖ ⥤ A} (f : F ⟶ G) [IsIso f] :
    IsLocallySurjective J f :=
  by
  apply is_locally_surjective_of_surjective
  intro U
  apply Function.Bijective.surjective
  rw [← is_iso_iff_bijective]
  infer_instance
#align category_theory.is_locally_surjective_of_iso CategoryTheory.isLocallySurjective_of_iso
-/

#print CategoryTheory.IsLocallySurjective.comp /-
theorem IsLocallySurjective.comp {F₁ F₂ F₃ : Cᵒᵖ ⥤ A} {f₁ : F₁ ⟶ F₂} {f₂ : F₂ ⟶ F₃}
    (h₁ : IsLocallySurjective J f₁) (h₂ : IsLocallySurjective J f₂) :
    IsLocallySurjective J (f₁ ≫ f₂) := by
  intro U s
  have :
    (sieve.bind (image_sieve f₂ s) fun _ _ h => image_sieve f₁ h.some) ≤ image_sieve (f₁ ≫ f₂) s :=
    by
    rintro V i ⟨W, i, j, H, ⟨t', ht'⟩, rfl⟩
    refine' ⟨t', _⟩
    rw [op_comp, F₃.map_comp, nat_trans.comp_app, comp_apply, comp_apply, ht',
      elementwise_of f₂.naturality, H.some_spec]
  apply J.superset_covering this
  apply J.bind_covering
  · apply h₂
  · intros; apply h₁
#align category_theory.is_locally_surjective.comp CategoryTheory.IsLocallySurjective.comp
-/

section

variable (F : Cᵒᵖ ⥤ Type max u v)

#print CategoryTheory.sheafificationIsoImagePresheaf /-
/-- The image of `F` in `J.sheafify F` is isomorphic to the sheafification. -/
noncomputable def sheafificationIsoImagePresheaf :
    J.sheafify F ≅ ((imagePresheaf (J.toSheafify F)).sheafify J).toPresheaf
    where
  Hom :=
    J.sheafifyLift (toImagePresheafSheafify J _)
      ((isSheaf_iff_isSheaf_of_type J _).mpr <|
        Subpresheaf.sheafify_isSheaf _ <|
          (isSheaf_iff_isSheaf_of_type J _).mp <| sheafify_isSheaf J _)
  inv := Subpresheaf.ι _
  hom_inv_id' :=
    J.sheafify_hom_ext _ _ (J.sheafify_isSheaf _) (by simp [to_image_presheaf_sheafify])
  inv_hom_id' :=
    by
    rw [← cancel_mono (subpresheaf.ι _), category.id_comp, category.assoc]
    refine' Eq.trans _ (category.comp_id _)
    congr 1
    exact J.sheafify_hom_ext _ _ (J.sheafify_is_sheaf _) (by simp [to_image_presheaf_sheafify])
    infer_instance
#align category_theory.sheafification_iso_image_presheaf CategoryTheory.sheafificationIsoImagePresheaf
-/

-- We need to sheafify
variable {B : Type w} [Category.{max u v} B] [ConcreteCategory.{max u v} B]
  [∀ X : C, Limits.HasColimitsOfShape (J.cover X)ᵒᵖ B]
  [∀ (P : Cᵒᵖ ⥤ B) (X : C) (S : J.cover X), Limits.HasMultiequalizer (S.index P)]
  [∀ (X : C) (W : J.cover X) (P : Cᵒᵖ ⥤ B),
      Limits.PreservesLimit (W.index P).multicospan (forget B)]
  [∀ X : C, Limits.PreservesColimitsOfShape (J.cover X)ᵒᵖ (forget B)]
  [∀ (α β : Type max u v) (fst snd : β → α),
      Limits.HasLimitsOfShape (Limits.WalkingMulticospan fst snd) B]

#print CategoryTheory.toSheafify_isLocallySurjective /-
theorem toSheafify_isLocallySurjective (F : Cᵒᵖ ⥤ B) : IsLocallySurjective J (J.toSheafify F) :=
  by
  rw [is_locally_surjective_iff_whisker_forget, ← to_sheafify_comp_sheafify_comp_iso_inv]
  apply is_locally_surjective.comp
  · rw [is_locally_surjective_iff_image_presheaf_sheafify_eq_top, subpresheaf.eq_top_iff_is_iso]
    exact is_iso.of_iso_inv (sheafification_iso_image_presheaf J (F ⋙ forget B))
  · exact is_locally_surjective_of_iso _ _
#align category_theory.to_sheafify_is_locally_surjective CategoryTheory.toSheafify_isLocallySurjective
-/

end

end CategoryTheory

