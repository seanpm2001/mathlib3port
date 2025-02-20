/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.monoidal.opposite
! leanprover-community/mathlib commit 6b31d1eebd64eab86d5bd9936bfaada6ca8b5842
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Monoidal.Coherence

/-!
# Monoidal opposites

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We write `Cᵐᵒᵖ` for the monoidal opposite of a monoidal category `C`.
-/


universe v₁ v₂ u₁ u₂

variable {C : Type u₁}

namespace CategoryTheory

open CategoryTheory.MonoidalCategory

#print CategoryTheory.MonoidalOpposite /-
/-- A type synonym for the monoidal opposite. Use the notation `Cᴹᵒᵖ`. -/
@[nolint has_nonempty_instance]
def MonoidalOpposite (C : Type u₁) :=
  C
#align category_theory.monoidal_opposite CategoryTheory.MonoidalOpposite
-/

namespace MonoidalOpposite

notation:max C "ᴹᵒᵖ" => MonoidalOpposite C

#print CategoryTheory.MonoidalOpposite.mop /-
/-- Think of an object of `C` as an object of `Cᴹᵒᵖ`. -/
@[pp_nodot]
def mop (X : C) : Cᴹᵒᵖ :=
  X
#align category_theory.monoidal_opposite.mop CategoryTheory.MonoidalOpposite.mop
-/

#print CategoryTheory.MonoidalOpposite.unmop /-
/-- Think of an object of `Cᴹᵒᵖ` as an object of `C`. -/
@[pp_nodot]
def unmop (X : Cᴹᵒᵖ) : C :=
  X
#align category_theory.monoidal_opposite.unmop CategoryTheory.MonoidalOpposite.unmop
-/

#print CategoryTheory.MonoidalOpposite.op_injective /-
theorem op_injective : Function.Injective (mop : C → Cᴹᵒᵖ) := fun _ _ => id
#align category_theory.monoidal_opposite.op_injective CategoryTheory.MonoidalOpposite.op_injective
-/

#print CategoryTheory.MonoidalOpposite.unop_injective /-
theorem unop_injective : Function.Injective (unmop : Cᴹᵒᵖ → C) := fun _ _ => id
#align category_theory.monoidal_opposite.unop_injective CategoryTheory.MonoidalOpposite.unop_injective
-/

#print CategoryTheory.MonoidalOpposite.op_inj_iff /-
@[simp]
theorem op_inj_iff (x y : C) : mop x = mop y ↔ x = y :=
  Iff.rfl
#align category_theory.monoidal_opposite.op_inj_iff CategoryTheory.MonoidalOpposite.op_inj_iff
-/

#print CategoryTheory.MonoidalOpposite.unop_inj_iff /-
@[simp]
theorem unop_inj_iff (x y : Cᴹᵒᵖ) : unmop x = unmop y ↔ x = y :=
  Iff.rfl
#align category_theory.monoidal_opposite.unop_inj_iff CategoryTheory.MonoidalOpposite.unop_inj_iff
-/

#print CategoryTheory.MonoidalOpposite.mop_unmop /-
@[simp]
theorem mop_unmop (X : Cᴹᵒᵖ) : mop (unmop X) = X :=
  rfl
#align category_theory.monoidal_opposite.mop_unmop CategoryTheory.MonoidalOpposite.mop_unmop
-/

#print CategoryTheory.MonoidalOpposite.unmop_mop /-
@[simp]
theorem unmop_mop (X : C) : unmop (mop X) = X :=
  rfl
#align category_theory.monoidal_opposite.unmop_mop CategoryTheory.MonoidalOpposite.unmop_mop
-/

#print CategoryTheory.MonoidalOpposite.monoidalOppositeCategory /-
instance monoidalOppositeCategory [I : Category.{v₁} C] : Category Cᴹᵒᵖ
    where
  Hom X Y := unmop X ⟶ unmop Y
  id X := 𝟙 (unmop X)
  comp X Y Z f g := f ≫ g
#align category_theory.monoidal_opposite.monoidal_opposite_category CategoryTheory.MonoidalOpposite.monoidalOppositeCategory
-/

end MonoidalOpposite

end CategoryTheory

open CategoryTheory

open CategoryTheory.MonoidalOpposite

variable [Category.{v₁} C]

#print Quiver.Hom.mop /-
/-- The monoidal opposite of a morphism `f : X ⟶ Y` is just `f`, thought of as `mop X ⟶ mop Y`. -/
def Quiver.Hom.mop {X Y : C} (f : X ⟶ Y) : @Quiver.Hom Cᴹᵒᵖ _ (mop X) (mop Y) :=
  f
#align quiver.hom.mop Quiver.Hom.mop
-/

#print Quiver.Hom.unmop /-
/-- We can think of a morphism `f : mop X ⟶ mop Y` as a morphism `X ⟶ Y`. -/
def Quiver.Hom.unmop {X Y : Cᴹᵒᵖ} (f : X ⟶ Y) : unmop X ⟶ unmop Y :=
  f
#align quiver.hom.unmop Quiver.Hom.unmop
-/

namespace CategoryTheory

#print CategoryTheory.mop_inj /-
theorem mop_inj {X Y : C} : Function.Injective (Quiver.Hom.mop : (X ⟶ Y) → (mop X ⟶ mop Y)) :=
  fun _ _ H => congr_arg Quiver.Hom.unmop H
#align category_theory.mop_inj CategoryTheory.mop_inj
-/

#print CategoryTheory.unmop_inj /-
theorem unmop_inj {X Y : Cᴹᵒᵖ} :
    Function.Injective (Quiver.Hom.unmop : (X ⟶ Y) → (unmop X ⟶ unmop Y)) := fun _ _ H =>
  congr_arg Quiver.Hom.mop H
#align category_theory.unmop_inj CategoryTheory.unmop_inj
-/

#print CategoryTheory.unmop_mop /-
@[simp]
theorem unmop_mop {X Y : C} {f : X ⟶ Y} : f.mop.unmop = f :=
  rfl
#align category_theory.unmop_mop CategoryTheory.unmop_mop
-/

#print CategoryTheory.mop_unmop /-
@[simp]
theorem mop_unmop {X Y : Cᴹᵒᵖ} {f : X ⟶ Y} : f.unmop.mop = f :=
  rfl
#align category_theory.mop_unmop CategoryTheory.mop_unmop
-/

#print CategoryTheory.mop_comp /-
@[simp]
theorem mop_comp {X Y Z : C} {f : X ⟶ Y} {g : Y ⟶ Z} : (f ≫ g).mop = f.mop ≫ g.mop :=
  rfl
#align category_theory.mop_comp CategoryTheory.mop_comp
-/

#print CategoryTheory.mop_id /-
@[simp]
theorem mop_id {X : C} : (𝟙 X).mop = 𝟙 (mop X) :=
  rfl
#align category_theory.mop_id CategoryTheory.mop_id
-/

#print CategoryTheory.unmop_comp /-
@[simp]
theorem unmop_comp {X Y Z : Cᴹᵒᵖ} {f : X ⟶ Y} {g : Y ⟶ Z} : (f ≫ g).unmop = f.unmop ≫ g.unmop :=
  rfl
#align category_theory.unmop_comp CategoryTheory.unmop_comp
-/

#print CategoryTheory.unmop_id /-
@[simp]
theorem unmop_id {X : Cᴹᵒᵖ} : (𝟙 X).unmop = 𝟙 (unmop X) :=
  rfl
#align category_theory.unmop_id CategoryTheory.unmop_id
-/

#print CategoryTheory.unmop_id_mop /-
@[simp]
theorem unmop_id_mop {X : C} : (𝟙 (mop X)).unmop = 𝟙 X :=
  rfl
#align category_theory.unmop_id_mop CategoryTheory.unmop_id_mop
-/

#print CategoryTheory.mop_id_unmop /-
@[simp]
theorem mop_id_unmop {X : Cᴹᵒᵖ} : (𝟙 (unmop X)).mop = 𝟙 X :=
  rfl
#align category_theory.mop_id_unmop CategoryTheory.mop_id_unmop
-/

namespace Iso

variable {X Y : C}

#print CategoryTheory.Iso.mop /-
/-- An isomorphism in `C` gives an isomorphism in `Cᴹᵒᵖ`. -/
@[simps]
def mop (f : X ≅ Y) : mop X ≅ mop Y where
  Hom := f.Hom.mop
  inv := f.inv.mop
  hom_inv_id' := unmop_inj f.hom_inv_id
  inv_hom_id' := unmop_inj f.inv_hom_id
#align category_theory.iso.mop CategoryTheory.Iso.mop
-/

end Iso

variable [MonoidalCategory.{v₁} C]

open Opposite MonoidalCategory

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.monoidalCategoryOp /-
instance monoidalCategoryOp : MonoidalCategory Cᵒᵖ
    where
  tensorObj X Y := op (unop X ⊗ unop Y)
  tensorHom X₁ Y₁ X₂ Y₂ f g := (f.unop ⊗ g.unop).op
  tensorUnit := op (𝟙_ C)
  associator X Y Z := (α_ (unop X) (unop Y) (unop Z)).symm.op
  leftUnitor X := (λ_ (unop X)).symm.op
  rightUnitor X := (ρ_ (unop X)).symm.op
  associator_naturality' := by intros; apply Quiver.Hom.unop_inj; simp
  leftUnitor_naturality' := by intros; apply Quiver.Hom.unop_inj; simp
  rightUnitor_naturality' := by intros; apply Quiver.Hom.unop_inj; simp
  triangle' := by intros; apply Quiver.Hom.unop_inj; coherence
  pentagon' := by intros; apply Quiver.Hom.unop_inj; coherence
#align category_theory.monoidal_category_op CategoryTheory.monoidalCategoryOp
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.op_tensorObj /-
theorem op_tensorObj (X Y : Cᵒᵖ) : X ⊗ Y = op (unop X ⊗ unop Y) :=
  rfl
#align category_theory.op_tensor_obj CategoryTheory.op_tensorObj
-/

#print CategoryTheory.op_tensorUnit /-
theorem op_tensorUnit : 𝟙_ Cᵒᵖ = op (𝟙_ C) :=
  rfl
#align category_theory.op_tensor_unit CategoryTheory.op_tensorUnit
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.monoidalCategoryMop /-
instance monoidalCategoryMop : MonoidalCategory Cᴹᵒᵖ
    where
  tensorObj X Y := mop (unmop Y ⊗ unmop X)
  tensorHom X₁ Y₁ X₂ Y₂ f g := (g.unmop ⊗ f.unmop).mop
  tensorUnit := mop (𝟙_ C)
  associator X Y Z := (α_ (unmop Z) (unmop Y) (unmop X)).symm.mop
  leftUnitor X := (ρ_ (unmop X)).mop
  rightUnitor X := (λ_ (unmop X)).mop
  associator_naturality' := by intros; apply unmop_inj; simp
  leftUnitor_naturality' := by intros; apply unmop_inj; simp
  rightUnitor_naturality' := by intros; apply unmop_inj; simp
  triangle' := by intros; apply unmop_inj; coherence
  pentagon' := by intros; apply unmop_inj; coherence
#align category_theory.monoidal_category_mop CategoryTheory.monoidalCategoryMop
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.mop_tensorObj /-
theorem mop_tensorObj (X Y : Cᴹᵒᵖ) : X ⊗ Y = mop (unmop Y ⊗ unmop X) :=
  rfl
#align category_theory.mop_tensor_obj CategoryTheory.mop_tensorObj
-/

#print CategoryTheory.mop_tensorUnit /-
theorem mop_tensorUnit : 𝟙_ Cᴹᵒᵖ = mop (𝟙_ C) :=
  rfl
#align category_theory.mop_tensor_unit CategoryTheory.mop_tensorUnit
-/

end CategoryTheory

