/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Adam Topaz, Johan Commelin, Joël Riou

! This file was ported from Lean 3 source module category_theory.preadditive.opposite
! leanprover-community/mathlib commit 86d1873c01a723aba6788f0b9051ae3d23b4c1c3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Preadditive.AdditiveFunctor
import Mathbin.Logic.Equiv.TransferInstance

/-!
# If `C` is preadditive, `Cᵒᵖ` has a natural preadditive structure.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


open Opposite

namespace CategoryTheory

variable (C : Type _) [Category C] [Preadditive C]

instance : Preadditive Cᵒᵖ
    where
  homGroup X Y := Equiv.addCommGroup (opEquiv X Y)
  add_comp X Y Z f f' g :=
    congr_arg Quiver.Hom.op (Preadditive.comp_add _ _ _ g.unop f.unop f'.unop)
  comp_add X Y Z f g g' :=
    congr_arg Quiver.Hom.op (Preadditive.add_comp _ _ _ g.unop g'.unop f.unop)

#print CategoryTheory.moduleEndLeft /-
instance moduleEndLeft {X : Cᵒᵖ} {Y : C} : Module (End X) (unop X ⟶ Y)
    where
  smul_add r f g := Preadditive.comp_add _ _ _ _ _ _
  smul_zero r := Limits.comp_zero
  add_smul r s f := Preadditive.add_comp _ _ _ _ _ _
  zero_smul f := Limits.zero_comp
#align category_theory.module_End_left CategoryTheory.moduleEndLeft
-/

#print CategoryTheory.unop_zero /-
@[simp]
theorem unop_zero (X Y : Cᵒᵖ) : (0 : X ⟶ Y).unop = 0 :=
  rfl
#align category_theory.unop_zero CategoryTheory.unop_zero
-/

#print CategoryTheory.unop_add /-
@[simp]
theorem unop_add {X Y : Cᵒᵖ} (f g : X ⟶ Y) : (f + g).unop = f.unop + g.unop :=
  rfl
#align category_theory.unop_add CategoryTheory.unop_add
-/

#print CategoryTheory.unop_zsmul /-
@[simp]
theorem unop_zsmul {X Y : Cᵒᵖ} (k : ℤ) (f : X ⟶ Y) : (k • f).unop = k • f.unop :=
  rfl
#align category_theory.unop_zsmul CategoryTheory.unop_zsmul
-/

#print CategoryTheory.unop_neg /-
@[simp]
theorem unop_neg {X Y : Cᵒᵖ} (f : X ⟶ Y) : (-f).unop = -f.unop :=
  rfl
#align category_theory.unop_neg CategoryTheory.unop_neg
-/

#print CategoryTheory.op_zero /-
@[simp]
theorem op_zero (X Y : C) : (0 : X ⟶ Y).op = 0 :=
  rfl
#align category_theory.op_zero CategoryTheory.op_zero
-/

#print CategoryTheory.op_add /-
@[simp]
theorem op_add {X Y : C} (f g : X ⟶ Y) : (f + g).op = f.op + g.op :=
  rfl
#align category_theory.op_add CategoryTheory.op_add
-/

#print CategoryTheory.op_zsmul /-
@[simp]
theorem op_zsmul {X Y : C} (k : ℤ) (f : X ⟶ Y) : (k • f).op = k • f.op :=
  rfl
#align category_theory.op_zsmul CategoryTheory.op_zsmul
-/

#print CategoryTheory.op_neg /-
@[simp]
theorem op_neg {X Y : C} (f : X ⟶ Y) : (-f).op = -f.op :=
  rfl
#align category_theory.op_neg CategoryTheory.op_neg
-/

variable {C}

#print CategoryTheory.unopHom /-
/-- `unop` induces morphisms of monoids on hom groups of a preadditive category -/
@[simps]
def unopHom (X Y : Cᵒᵖ) : (X ⟶ Y) →+ (Opposite.unop Y ⟶ Opposite.unop X) :=
  AddMonoidHom.mk' (fun f => f.unop) fun f g => unop_add _ f g
#align category_theory.unop_hom CategoryTheory.unopHom
-/

#print CategoryTheory.unop_sum /-
@[simp]
theorem unop_sum (X Y : Cᵒᵖ) {ι : Type _} (s : Finset ι) (f : ι → (X ⟶ Y)) :
    (s.Sum f).unop = s.Sum fun i => (f i).unop :=
  (unopHom X Y).map_sum _ _
#align category_theory.unop_sum CategoryTheory.unop_sum
-/

#print CategoryTheory.opHom /-
/-- `op` induces morphisms of monoids on hom groups of a preadditive category -/
@[simps]
def opHom (X Y : C) : (X ⟶ Y) →+ (Opposite.op Y ⟶ Opposite.op X) :=
  AddMonoidHom.mk' (fun f => f.op) fun f g => op_add _ f g
#align category_theory.op_hom CategoryTheory.opHom
-/

#print CategoryTheory.op_sum /-
@[simp]
theorem op_sum (X Y : C) {ι : Type _} (s : Finset ι) (f : ι → (X ⟶ Y)) :
    (s.Sum f).op = s.Sum fun i => (f i).op :=
  (opHom X Y).map_sum _ _
#align category_theory.op_sum CategoryTheory.op_sum
-/

variable {D : Type _} [Category D] [Preadditive D]

#print CategoryTheory.Functor.op_additive /-
instance Functor.op_additive (F : C ⥤ D) [F.Additive] : F.op.Additive where
#align category_theory.functor.op_additive CategoryTheory.Functor.op_additive
-/

#print CategoryTheory.Functor.rightOp_additive /-
instance Functor.rightOp_additive (F : Cᵒᵖ ⥤ D) [F.Additive] : F.rightOp.Additive where
#align category_theory.functor.right_op_additive CategoryTheory.Functor.rightOp_additive
-/

#print CategoryTheory.Functor.leftOp_additive /-
instance Functor.leftOp_additive (F : C ⥤ Dᵒᵖ) [F.Additive] : F.leftOp.Additive where
#align category_theory.functor.left_op_additive CategoryTheory.Functor.leftOp_additive
-/

#print CategoryTheory.Functor.unop_additive /-
instance Functor.unop_additive (F : Cᵒᵖ ⥤ Dᵒᵖ) [F.Additive] : F.unop.Additive where
#align category_theory.functor.unop_additive CategoryTheory.Functor.unop_additive
-/

end CategoryTheory

