/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.monoidal.functor_category
! leanprover-community/mathlib commit 575b4ea3738b017e30fb205cb9b4a8742e5e82b6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Monoidal.Braided
import Mathbin.CategoryTheory.Functor.Category
import Mathbin.CategoryTheory.Functor.Const

/-!
# Monoidal structure on `C ⥤ D` when `D` is monoidal.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

When `C` is any category, and `D` is a monoidal category,
there is a natural "pointwise" monoidal structure on `C ⥤ D`.

The initial intended application is tensor product of presheaves.
-/


universe v₁ v₂ u₁ u₂

open CategoryTheory

open CategoryTheory.MonoidalCategory

namespace CategoryTheory.Monoidal

variable {C : Type u₁} [Category.{v₁} C]

variable {D : Type u₂} [Category.{v₂} D] [MonoidalCategory.{v₂} D]

namespace FunctorCategory

variable (F G F' G' : C ⥤ D)

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.FunctorCategory.tensorObj /-
/-- (An auxiliary definition for `functor_category_monoidal`.)
Tensor product of functors `C ⥤ D`, when `D` is monoidal.
 -/
@[simps]
def tensorObj : C ⥤ D where
  obj X := F.obj X ⊗ G.obj X
  map X Y f := F.map f ⊗ G.map f
  map_id' X := by rw [F.map_id, G.map_id, tensor_id]
  map_comp' X Y Z f g := by rw [F.map_comp, G.map_comp, tensor_comp]
#align category_theory.monoidal.functor_category.tensor_obj CategoryTheory.Monoidal.FunctorCategory.tensorObj
-/

variable {F G F' G'}

variable (α : F ⟶ G) (β : F' ⟶ G')

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.FunctorCategory.tensorHom /-
/-- (An auxiliary definition for `functor_category_monoidal`.)
Tensor product of natural transformations into `D`, when `D` is monoidal.
-/
@[simps]
def tensorHom : tensorObj F F' ⟶ tensorObj G G'
    where
  app X := α.app X ⊗ β.app X
  naturality' X Y f := by dsimp; rw [← tensor_comp, α.naturality, β.naturality, tensor_comp]
#align category_theory.monoidal.functor_category.tensor_hom CategoryTheory.Monoidal.FunctorCategory.tensorHom
-/

end FunctorCategory

open CategoryTheory.Monoidal.FunctorCategory

#print CategoryTheory.Monoidal.functorCategoryMonoidal /-
/-- When `C` is any category, and `D` is a monoidal category,
the functor category `C ⥤ D` has a natural pointwise monoidal structure,
where `(F ⊗ G).obj X = F.obj X ⊗ G.obj X`.
-/
instance functorCategoryMonoidal : MonoidalCategory (C ⥤ D)
    where
  tensorObj F G := tensorObj F G
  tensorHom F G F' G' α β := tensorHom α β
  tensor_id' F G := by ext; dsimp; rw [tensor_id]
  tensor_comp' F G H F' G' H' α β γ δ := by ext; dsimp; rw [tensor_comp]
  tensorUnit := (CategoryTheory.Functor.const C).obj (𝟙_ D)
  leftUnitor F :=
    NatIso.ofComponents (fun X => λ_ (F.obj X)) fun X Y f => by dsimp; rw [left_unitor_naturality]
  rightUnitor F :=
    NatIso.ofComponents (fun X => ρ_ (F.obj X)) fun X Y f => by dsimp; rw [right_unitor_naturality]
  associator F G H :=
    NatIso.ofComponents (fun X => α_ (F.obj X) (G.obj X) (H.obj X)) fun X Y f => by dsimp;
      rw [associator_naturality]
  leftUnitor_naturality' F G α := by ext X; dsimp; rw [left_unitor_naturality]
  rightUnitor_naturality' F G α := by ext X; dsimp; rw [right_unitor_naturality]
  associator_naturality' F G H F' G' H' α β γ := by ext X; dsimp; rw [associator_naturality]
  triangle' F G := by ext X; dsimp; rw [triangle]
  pentagon' F G H K := by ext X; dsimp; rw [pentagon]
#align category_theory.monoidal.functor_category_monoidal CategoryTheory.Monoidal.functorCategoryMonoidal
-/

#print CategoryTheory.Monoidal.tensorUnit_obj /-
@[simp]
theorem tensorUnit_obj {X} : (𝟙_ (C ⥤ D)).obj X = 𝟙_ D :=
  rfl
#align category_theory.monoidal.tensor_unit_obj CategoryTheory.Monoidal.tensorUnit_obj
-/

#print CategoryTheory.Monoidal.tensorUnit_map /-
@[simp]
theorem tensorUnit_map {X Y} {f : X ⟶ Y} : (𝟙_ (C ⥤ D)).map f = 𝟙 (𝟙_ D) :=
  rfl
#align category_theory.monoidal.tensor_unit_map CategoryTheory.Monoidal.tensorUnit_map
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.tensorObj_obj /-
@[simp]
theorem tensorObj_obj {F G : C ⥤ D} {X} : (F ⊗ G).obj X = F.obj X ⊗ G.obj X :=
  rfl
#align category_theory.monoidal.tensor_obj_obj CategoryTheory.Monoidal.tensorObj_obj
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.tensorObj_map /-
@[simp]
theorem tensorObj_map {F G : C ⥤ D} {X Y} {f : X ⟶ Y} : (F ⊗ G).map f = F.map f ⊗ G.map f :=
  rfl
#align category_theory.monoidal.tensor_obj_map CategoryTheory.Monoidal.tensorObj_map
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.tensorHom_app /-
@[simp]
theorem tensorHom_app {F G F' G' : C ⥤ D} {α : F ⟶ G} {β : F' ⟶ G'} {X} :
    (α ⊗ β).app X = α.app X ⊗ β.app X :=
  rfl
#align category_theory.monoidal.tensor_hom_app CategoryTheory.Monoidal.tensorHom_app
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.leftUnitor_hom_app /-
@[simp]
theorem leftUnitor_hom_app {F : C ⥤ D} {X} :
    ((λ_ F).Hom : 𝟙_ _ ⊗ F ⟶ F).app X = (λ_ (F.obj X)).Hom :=
  rfl
#align category_theory.monoidal.left_unitor_hom_app CategoryTheory.Monoidal.leftUnitor_hom_app
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.leftUnitor_inv_app /-
@[simp]
theorem leftUnitor_inv_app {F : C ⥤ D} {X} :
    ((λ_ F).inv : F ⟶ 𝟙_ _ ⊗ F).app X = (λ_ (F.obj X)).inv :=
  rfl
#align category_theory.monoidal.left_unitor_inv_app CategoryTheory.Monoidal.leftUnitor_inv_app
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.rightUnitor_hom_app /-
@[simp]
theorem rightUnitor_hom_app {F : C ⥤ D} {X} :
    ((ρ_ F).Hom : F ⊗ 𝟙_ _ ⟶ F).app X = (ρ_ (F.obj X)).Hom :=
  rfl
#align category_theory.monoidal.right_unitor_hom_app CategoryTheory.Monoidal.rightUnitor_hom_app
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.rightUnitor_inv_app /-
@[simp]
theorem rightUnitor_inv_app {F : C ⥤ D} {X} :
    ((ρ_ F).inv : F ⟶ F ⊗ 𝟙_ _).app X = (ρ_ (F.obj X)).inv :=
  rfl
#align category_theory.monoidal.right_unitor_inv_app CategoryTheory.Monoidal.rightUnitor_inv_app
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.associator_hom_app /-
@[simp]
theorem associator_hom_app {F G H : C ⥤ D} {X} :
    ((α_ F G H).Hom : (F ⊗ G) ⊗ H ⟶ F ⊗ G ⊗ H).app X = (α_ (F.obj X) (G.obj X) (H.obj X)).Hom :=
  rfl
#align category_theory.monoidal.associator_hom_app CategoryTheory.Monoidal.associator_hom_app
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.Monoidal.associator_inv_app /-
@[simp]
theorem associator_inv_app {F G H : C ⥤ D} {X} :
    ((α_ F G H).inv : F ⊗ G ⊗ H ⟶ (F ⊗ G) ⊗ H).app X = (α_ (F.obj X) (G.obj X) (H.obj X)).inv :=
  rfl
#align category_theory.monoidal.associator_inv_app CategoryTheory.Monoidal.associator_inv_app
-/

section BraidedCategory

open CategoryTheory.BraidedCategory

variable [BraidedCategory.{v₂} D]

#print CategoryTheory.Monoidal.functorCategoryBraided /-
/-- When `C` is any category, and `D` is a braided monoidal category,
the natural pointwise monoidal structure on the functor category `C ⥤ D`
is also braided.
-/
instance functorCategoryBraided : BraidedCategory (C ⥤ D)
    where
  braiding F G := NatIso.ofComponents (fun X => β_ _ _) (by tidy)
  hexagon_forward' F G H := by ext X; apply hexagon_forward
  hexagon_reverse' F G H := by ext X; apply hexagon_reverse
#align category_theory.monoidal.functor_category_braided CategoryTheory.Monoidal.functorCategoryBraided
-/

example : BraidedCategory (C ⥤ D) :=
  CategoryTheory.Monoidal.functorCategoryBraided

end BraidedCategory

section SymmetricCategory

open CategoryTheory.SymmetricCategory

variable [SymmetricCategory.{v₂} D]

#print CategoryTheory.Monoidal.functorCategorySymmetric /-
/-- When `C` is any category, and `D` is a symmetric monoidal category,
the natural pointwise monoidal structure on the functor category `C ⥤ D`
is also symmetric.
-/
instance functorCategorySymmetric : SymmetricCategory (C ⥤ D)
    where symmetry' F G := by ext X; apply symmetry
#align category_theory.monoidal.functor_category_symmetric CategoryTheory.Monoidal.functorCategorySymmetric
-/

end SymmetricCategory

end CategoryTheory.Monoidal

