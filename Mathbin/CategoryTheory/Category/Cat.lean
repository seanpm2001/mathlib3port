/-
Copyright (c) 2019 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module category_theory.category.Cat
! leanprover-community/mathlib commit 3dadefa3f544b1db6214777fe47910739b54c66a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.ConcreteCategory.Bundled
import Mathbin.CategoryTheory.DiscreteCategory
import Mathbin.CategoryTheory.Types
import Mathbin.CategoryTheory.Bicategory.Strict

/-!
# Category of categories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains the definition of the category `Cat` of all categories.
In this category objects are categories and
morphisms are functors between these categories.

## Implementation notes

Though `Cat` is not a concrete category, we use `bundled` to define
its carrier type.
-/


universe v u

namespace CategoryTheory

#print CategoryTheory.Cat /-
-- intended to be used with explicit universe parameters
/-- Category of categories. -/
@[nolint check_univs]
def Cat :=
  Bundled Category.{v, u}
#align category_theory.Cat CategoryTheory.Cat
-/

namespace Cat

instance : Inhabited Cat :=
  ⟨⟨Type u, CategoryTheory.types⟩⟩

instance : CoeSort Cat (Type u) :=
  ⟨Bundled.α⟩

#print CategoryTheory.Cat.str /-
instance str (C : Cat.{v, u}) : Category.{v, u} C :=
  C.str
#align category_theory.Cat.str CategoryTheory.Cat.str
-/

#print CategoryTheory.Cat.of /-
/-- Construct a bundled `Cat` from the underlying type and the typeclass. -/
def of (C : Type u) [Category.{v} C] : Cat.{v, u} :=
  Bundled.of C
#align category_theory.Cat.of CategoryTheory.Cat.of
-/

#print CategoryTheory.Cat.bicategory /-
/-- Bicategory structure on `Cat` -/
instance bicategory : Bicategory.{max v u, max v u} Cat.{v, u}
    where
  Hom C D := C ⥤ D
  id C := 𝟭 C
  comp C D E F G := F ⋙ G
  homCategory C D := Functor.category C D
  whiskerLeft C D E F G H η := whiskerLeft F η
  whiskerRight C D E F G η H := whiskerRight η H
  associator A B C D := Functor.associator
  leftUnitor A B := Functor.leftUnitor
  rightUnitor A B := Functor.rightUnitor
  pentagon A B C D E := Functor.pentagon
  triangle A B C := Functor.triangle
#align category_theory.Cat.bicategory CategoryTheory.Cat.bicategory
-/

#print CategoryTheory.Cat.bicategory.strict /-
/-- `Cat` is a strict bicategory. -/
instance bicategory.strict : Bicategory.Strict Cat.{v, u}
    where
  id_comp' C D F := by cases F <;> rfl
  comp_id' C D F := by cases F <;> rfl
  assoc' := by intros <;> rfl
#align category_theory.Cat.bicategory.strict CategoryTheory.Cat.bicategory.strict
-/

#print CategoryTheory.Cat.category /-
/-- Category structure on `Cat` -/
instance category : LargeCategory.{max v u} Cat.{v, u} :=
  StrictBicategory.category Cat.{v, u}
#align category_theory.Cat.category CategoryTheory.Cat.category
-/

#print CategoryTheory.Cat.id_map /-
@[simp]
theorem id_map {C : Cat} {X Y : C} (f : X ⟶ Y) : (𝟙 C : C ⥤ C).map f = f :=
  Functor.id_map f
#align category_theory.Cat.id_map CategoryTheory.Cat.id_map
-/

#print CategoryTheory.Cat.comp_obj /-
@[simp]
theorem comp_obj {C D E : Cat} (F : C ⟶ D) (G : D ⟶ E) (X : C) : (F ≫ G).obj X = G.obj (F.obj X) :=
  Functor.comp_obj F G X
#align category_theory.Cat.comp_obj CategoryTheory.Cat.comp_obj
-/

#print CategoryTheory.Cat.comp_map /-
@[simp]
theorem comp_map {C D E : Cat} (F : C ⟶ D) (G : D ⟶ E) {X Y : C} (f : X ⟶ Y) :
    (F ≫ G).map f = G.map (F.map f) :=
  Functor.comp_map F G f
#align category_theory.Cat.comp_map CategoryTheory.Cat.comp_map
-/

#print CategoryTheory.Cat.objects /-
/-- Functor that gets the set of objects of a category. It is not
called `forget`, because it is not a faithful functor. -/
def objects : Cat.{v, u} ⥤ Type u where
  obj C := C
  map C D F := F.obj
#align category_theory.Cat.objects CategoryTheory.Cat.objects
-/

section

attribute [local simp] eq_to_hom_map

#print CategoryTheory.Cat.equivOfIso /-
/-- Any isomorphism in `Cat` induces an equivalence of the underlying categories. -/
def equivOfIso {C D : Cat} (γ : C ≅ D) : C ≌ D
    where
  Functor := γ.Hom
  inverse := γ.inv
  unitIso := eqToIso <| Eq.symm γ.hom_inv_id
  counitIso := eqToIso γ.inv_hom_id
#align category_theory.Cat.equiv_of_iso CategoryTheory.Cat.equivOfIso
-/

end

end Cat

#print CategoryTheory.typeToCat /-
/-- Embedding `Type` into `Cat` as discrete categories.

This ought to be modelled as a 2-functor!
-/
@[simps]
def typeToCat : Type u ⥤ Cat where
  obj X := Cat.of (Discrete X)
  map X Y f := Discrete.functor (Discrete.mk ∘ f)
  map_id' X := by apply Functor.ext; tidy
  map_comp' X Y Z f g := by apply Functor.ext; tidy
#align category_theory.Type_to_Cat CategoryTheory.typeToCat
-/

instance : Faithful typeToCat.{u}
    where map_injective' X Y f g h :=
    funext fun x => congr_arg Discrete.as (Functor.congr_obj h ⟨x⟩)

instance : Full typeToCat.{u}
    where
  preimage X Y F := Discrete.as ∘ F.obj ∘ Discrete.mk
  witness' := by
    intro X Y F
    apply Functor.ext
    · intro x y f; dsimp; ext
    · rintro ⟨x⟩; ext; rfl

end CategoryTheory

