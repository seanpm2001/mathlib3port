/-
Copyright (c) 2017 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tim Baumann, Stephen Morgan, Scott Morrison, Floris van Doorn

! This file was ported from Lean 3 source module category_theory.natural_isomorphism
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Functor.Category
import Mathbin.CategoryTheory.Isomorphism

/-!
# Natural isomorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For the most part, natural isomorphisms are just another sort of isomorphism.

We provide some special support for extracting components:
* if `α : F ≅ G`, then `a.app X : F.obj X ≅ G.obj X`,
and building natural isomorphisms from components:
*
```
nat_iso.of_components
  (app : ∀ X : C, F.obj X ≅ G.obj X)
  (naturality : ∀ {X Y : C} (f : X ⟶ Y), F.map f ≫ (app Y).hom = (app X).hom ≫ G.map f) :
F ≅ G
```
only needing to check naturality in one direction.

## Implementation

Note that `nat_iso` is a namespace without a corresponding definition;
we put some declarations that are specifically about natural isomorphisms in the `iso`
namespace so that they are available using dot notation.
-/


open CategoryTheory

-- declare the `v`'s first; see `category_theory.category` for an explanation
universe v₁ v₂ v₃ v₄ u₁ u₂ u₃ u₄

namespace CategoryTheory

open NatTrans

variable {C : Type u₁} [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D] {E : Type u₃}
  [Category.{v₃} E]

namespace Iso

#print CategoryTheory.Iso.app /-
/-- The application of a natural isomorphism to an object. We put this definition in a different
namespace, so that we can use `α.app` -/
@[simps]
def app {F G : C ⥤ D} (α : F ≅ G) (X : C) : F.obj X ≅ G.obj X
    where
  Hom := α.Hom.app X
  inv := α.inv.app X
  hom_inv_id' := by rw [← comp_app, iso.hom_inv_id]; rfl
  inv_hom_id' := by rw [← comp_app, iso.inv_hom_id]; rfl
#align category_theory.iso.app CategoryTheory.Iso.app
-/

#print CategoryTheory.Iso.hom_inv_id_app /-
@[simp, reassoc]
theorem hom_inv_id_app {F G : C ⥤ D} (α : F ≅ G) (X : C) :
    α.Hom.app X ≫ α.inv.app X = 𝟙 (F.obj X) :=
  congr_fun (congr_arg NatTrans.app α.hom_inv_id) X
#align category_theory.iso.hom_inv_id_app CategoryTheory.Iso.hom_inv_id_app
-/

#print CategoryTheory.Iso.inv_hom_id_app /-
@[simp, reassoc]
theorem inv_hom_id_app {F G : C ⥤ D} (α : F ≅ G) (X : C) :
    α.inv.app X ≫ α.Hom.app X = 𝟙 (G.obj X) :=
  congr_fun (congr_arg NatTrans.app α.inv_hom_id) X
#align category_theory.iso.inv_hom_id_app CategoryTheory.Iso.inv_hom_id_app
-/

end Iso

namespace NatIso

open CategoryTheory.Category CategoryTheory.Functor

#print CategoryTheory.NatIso.trans_app /-
@[simp]
theorem trans_app {F G H : C ⥤ D} (α : F ≅ G) (β : G ≅ H) (X : C) :
    (α ≪≫ β).app X = α.app X ≪≫ β.app X :=
  rfl
#align category_theory.nat_iso.trans_app CategoryTheory.NatIso.trans_app
-/

#print CategoryTheory.NatIso.app_hom /-
theorem app_hom {F G : C ⥤ D} (α : F ≅ G) (X : C) : (α.app X).Hom = α.Hom.app X :=
  rfl
#align category_theory.nat_iso.app_hom CategoryTheory.NatIso.app_hom
-/

#print CategoryTheory.NatIso.app_inv /-
theorem app_inv {F G : C ⥤ D} (α : F ≅ G) (X : C) : (α.app X).inv = α.inv.app X :=
  rfl
#align category_theory.nat_iso.app_inv CategoryTheory.NatIso.app_inv
-/

variable {F G : C ⥤ D}

#print CategoryTheory.NatIso.hom_app_isIso /-
instance hom_app_isIso (α : F ≅ G) (X : C) : IsIso (α.Hom.app X) :=
  ⟨⟨α.inv.app X,
      ⟨by rw [← comp_app, iso.hom_inv_id, ← id_app], by rw [← comp_app, iso.inv_hom_id, ← id_app]⟩⟩⟩
#align category_theory.nat_iso.hom_app_is_iso CategoryTheory.NatIso.hom_app_isIso
-/

#print CategoryTheory.NatIso.inv_app_isIso /-
instance inv_app_isIso (α : F ≅ G) (X : C) : IsIso (α.inv.app X) :=
  ⟨⟨α.Hom.app X,
      ⟨by rw [← comp_app, iso.inv_hom_id, ← id_app], by rw [← comp_app, iso.hom_inv_id, ← id_app]⟩⟩⟩
#align category_theory.nat_iso.inv_app_is_iso CategoryTheory.NatIso.inv_app_isIso
-/

section

/-!
Unfortunately we need a separate set of cancellation lemmas for components of natural isomorphisms,
because the `simp` normal form is `α.hom.app X`, rather than `α.app.hom X`.

(With the later, the morphism would be visibly part of an isomorphism, so general lemmas about
isomorphisms would apply.)

In the future, we should consider a redesign that changes this simp norm form,
but for now it breaks too many proofs.
-/


variable (α : F ≅ G)

#print CategoryTheory.NatIso.cancel_natIso_hom_left /-
@[simp]
theorem cancel_natIso_hom_left {X : C} {Z : D} (g g' : G.obj X ⟶ Z) :
    α.Hom.app X ≫ g = α.Hom.app X ≫ g' ↔ g = g' := by simp only [cancel_epi]
#align category_theory.nat_iso.cancel_nat_iso_hom_left CategoryTheory.NatIso.cancel_natIso_hom_left
-/

#print CategoryTheory.NatIso.cancel_natIso_inv_left /-
@[simp]
theorem cancel_natIso_inv_left {X : C} {Z : D} (g g' : F.obj X ⟶ Z) :
    α.inv.app X ≫ g = α.inv.app X ≫ g' ↔ g = g' := by simp only [cancel_epi]
#align category_theory.nat_iso.cancel_nat_iso_inv_left CategoryTheory.NatIso.cancel_natIso_inv_left
-/

#print CategoryTheory.NatIso.cancel_natIso_hom_right /-
@[simp]
theorem cancel_natIso_hom_right {X : D} {Y : C} (f f' : X ⟶ F.obj Y) :
    f ≫ α.Hom.app Y = f' ≫ α.Hom.app Y ↔ f = f' := by simp only [cancel_mono]
#align category_theory.nat_iso.cancel_nat_iso_hom_right CategoryTheory.NatIso.cancel_natIso_hom_right
-/

#print CategoryTheory.NatIso.cancel_natIso_inv_right /-
@[simp]
theorem cancel_natIso_inv_right {X : D} {Y : C} (f f' : X ⟶ G.obj Y) :
    f ≫ α.inv.app Y = f' ≫ α.inv.app Y ↔ f = f' := by simp only [cancel_mono]
#align category_theory.nat_iso.cancel_nat_iso_inv_right CategoryTheory.NatIso.cancel_natIso_inv_right
-/

#print CategoryTheory.NatIso.cancel_natIso_hom_right_assoc /-
@[simp]
theorem cancel_natIso_hom_right_assoc {W X X' : D} {Y : C} (f : W ⟶ X) (g : X ⟶ F.obj Y)
    (f' : W ⟶ X') (g' : X' ⟶ F.obj Y) :
    f ≫ g ≫ α.Hom.app Y = f' ≫ g' ≫ α.Hom.app Y ↔ f ≫ g = f' ≫ g' := by
  simp only [← category.assoc, cancel_mono]
#align category_theory.nat_iso.cancel_nat_iso_hom_right_assoc CategoryTheory.NatIso.cancel_natIso_hom_right_assoc
-/

#print CategoryTheory.NatIso.cancel_natIso_inv_right_assoc /-
@[simp]
theorem cancel_natIso_inv_right_assoc {W X X' : D} {Y : C} (f : W ⟶ X) (g : X ⟶ G.obj Y)
    (f' : W ⟶ X') (g' : X' ⟶ G.obj Y) :
    f ≫ g ≫ α.inv.app Y = f' ≫ g' ≫ α.inv.app Y ↔ f ≫ g = f' ≫ g' := by
  simp only [← category.assoc, cancel_mono]
#align category_theory.nat_iso.cancel_nat_iso_inv_right_assoc CategoryTheory.NatIso.cancel_natIso_inv_right_assoc
-/

#print CategoryTheory.NatIso.inv_inv_app /-
@[simp]
theorem inv_inv_app {F G : C ⥤ D} (e : F ≅ G) (X : C) : inv (e.inv.app X) = e.Hom.app X := by ext;
  simp
#align category_theory.nat_iso.inv_inv_app CategoryTheory.NatIso.inv_inv_app
-/

end

variable {X Y : C}

#print CategoryTheory.NatIso.naturality_1 /-
theorem naturality_1 (α : F ≅ G) (f : X ⟶ Y) : α.inv.app X ≫ F.map f ≫ α.Hom.app Y = G.map f := by
  simp
#align category_theory.nat_iso.naturality_1 CategoryTheory.NatIso.naturality_1
-/

#print CategoryTheory.NatIso.naturality_2 /-
theorem naturality_2 (α : F ≅ G) (f : X ⟶ Y) : α.Hom.app X ≫ G.map f ≫ α.inv.app Y = F.map f := by
  simp
#align category_theory.nat_iso.naturality_2 CategoryTheory.NatIso.naturality_2
-/

#print CategoryTheory.NatIso.naturality_1' /-
theorem naturality_1' (α : F ⟶ G) (f : X ⟶ Y) [IsIso (α.app X)] :
    inv (α.app X) ≫ F.map f ≫ α.app Y = G.map f := by simp
#align category_theory.nat_iso.naturality_1' CategoryTheory.NatIso.naturality_1'
-/

#print CategoryTheory.NatIso.naturality_2' /-
@[simp, reassoc]
theorem naturality_2' (α : F ⟶ G) (f : X ⟶ Y) [IsIso (α.app Y)] :
    α.app X ≫ G.map f ≫ inv (α.app Y) = F.map f := by
  rw [← category.assoc, ← naturality, category.assoc, is_iso.hom_inv_id, category.comp_id]
#align category_theory.nat_iso.naturality_2' CategoryTheory.NatIso.naturality_2'
-/

#print CategoryTheory.NatIso.isIso_app_of_isIso /-
/-- The components of a natural isomorphism are isomorphisms.
-/
instance isIso_app_of_isIso (α : F ⟶ G) [IsIso α] (X) : IsIso (α.app X) :=
  ⟨⟨(inv α).app X,
      ⟨congr_fun (congr_arg NatTrans.app (IsIso.hom_inv_id α)) X,
        congr_fun (congr_arg NatTrans.app (IsIso.inv_hom_id α)) X⟩⟩⟩
#align category_theory.nat_iso.is_iso_app_of_is_iso CategoryTheory.NatIso.isIso_app_of_isIso
-/

#print CategoryTheory.NatIso.isIso_inv_app /-
@[simp]
theorem isIso_inv_app (α : F ⟶ G) [IsIso α] (X) : (inv α).app X = inv (α.app X) := by ext;
  rw [← nat_trans.comp_app]; simp
#align category_theory.nat_iso.is_iso_inv_app CategoryTheory.NatIso.isIso_inv_app
-/

#print CategoryTheory.NatIso.inv_map_inv_app /-
@[simp]
theorem inv_map_inv_app (F : C ⥤ D ⥤ E) {X Y : C} (e : X ≅ Y) (Z : D) :
    inv ((F.map e.inv).app Z) = (F.map e.Hom).app Z := by ext; simp
#align category_theory.nat_iso.inv_map_inv_app CategoryTheory.NatIso.inv_map_inv_app
-/

#print CategoryTheory.NatIso.ofComponents /-
/-- Construct a natural isomorphism between functors by giving object level isomorphisms,
and checking naturality only in the forward direction.
-/
@[simps]
def ofComponents (app : ∀ X : C, F.obj X ≅ G.obj X)
    (naturality : ∀ {X Y : C} (f : X ⟶ Y), F.map f ≫ (app Y).Hom = (app X).Hom ≫ G.map f) : F ≅ G
    where
  Hom := { app := fun X => (app X).Hom }
  inv :=
    { app := fun X => (app X).inv
      naturality' := fun X Y f =>
        by
        have h := congr_arg (fun f => (app X).inv ≫ f ≫ (app Y).inv) (naturality f).symm
        simp only [iso.inv_hom_id_assoc, iso.hom_inv_id, assoc, comp_id, cancel_mono] at h 
        exact h }
#align category_theory.nat_iso.of_components CategoryTheory.NatIso.ofComponents
-/

#print CategoryTheory.NatIso.ofComponents.app /-
@[simp]
theorem ofComponents.app (app' : ∀ X : C, F.obj X ≅ G.obj X) (naturality) (X) :
    (ofComponents app' naturality).app X = app' X := by tidy
#align category_theory.nat_iso.of_components.app CategoryTheory.NatIso.ofComponents.app
-/

#print CategoryTheory.NatIso.isIso_of_isIso_app /-
-- Making this an instance would cause a typeclass inference loop with `is_iso_app_of_is_iso`.
/-- A natural transformation is an isomorphism if all its components are isomorphisms.
-/
theorem isIso_of_isIso_app (α : F ⟶ G) [∀ X : C, IsIso (α.app X)] : IsIso α :=
  ⟨(IsIso.of_iso (ofComponents (fun X => asIso (α.app X)) (by tidy))).1⟩
#align category_theory.nat_iso.is_iso_of_is_iso_app CategoryTheory.NatIso.isIso_of_isIso_app
-/

#print CategoryTheory.NatIso.hcomp /-
/-- Horizontal composition of natural isomorphisms. -/
@[simps]
def hcomp {F G : C ⥤ D} {H I : D ⥤ E} (α : F ≅ G) (β : H ≅ I) : F ⋙ H ≅ G ⋙ I :=
  by
  refine' ⟨α.hom ◫ β.hom, α.inv ◫ β.inv, _, _⟩
  · ext; rw [← nat_trans.exchange]; simp; rfl
  ext; rw [← nat_trans.exchange]; simp; rfl
#align category_theory.nat_iso.hcomp CategoryTheory.NatIso.hcomp
-/

#print CategoryTheory.NatIso.isIso_map_iff /-
theorem isIso_map_iff {F₁ F₂ : C ⥤ D} (e : F₁ ≅ F₂) {X Y : C} (f : X ⟶ Y) :
    IsIso (F₁.map f) ↔ IsIso (F₂.map f) := by
  revert F₁ F₂
  suffices ∀ {F₁ F₂ : C ⥤ D} (e : F₁ ≅ F₂) (hf : is_iso (F₁.map f)), is_iso (F₂.map f) by
    exact fun F₁ F₂ e => ⟨this e, this e.symm⟩
  intro F₁ F₂ e hf
  refine' is_iso.mk ⟨e.inv.app Y ≫ inv (F₁.map f) ≫ e.hom.app X, _, _⟩
  · simp only [nat_trans.naturality_assoc, is_iso.hom_inv_id_assoc, iso.inv_hom_id_app]
  · simp only [assoc, ← e.hom.naturality, is_iso.inv_hom_id_assoc, iso.inv_hom_id_app]
#align category_theory.nat_iso.is_iso_map_iff CategoryTheory.NatIso.isIso_map_iff
-/

end NatIso

end CategoryTheory

