/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module category_theory.preadditive.functor_category
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Preadditive.Basic

/-!
# Preadditive structure on functor categories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

If `C` and `D` are categories and `D` is preadditive,
then `C ⥤ D` is also preadditive.

-/


open scoped BigOperators

namespace CategoryTheory

open CategoryTheory.Limits Preadditive

variable {C D : Type _} [Category C] [Category D] [Preadditive D]

#print CategoryTheory.functorCategoryPreadditive /-
instance functorCategoryPreadditive : Preadditive (C ⥤ D)
    where
  homGroup F G :=
    { add := fun α β =>
        { app := fun X => α.app X + β.app X
          naturality' := by intros; rw [comp_add, add_comp, α.naturality, β.naturality] }
      zero :=
        { app := fun X => 0
          naturality' := by intros; rw [zero_comp, comp_zero] }
      neg := fun α =>
        { app := fun X => -α.app X
          naturality' := by intros; rw [comp_neg, neg_comp, α.naturality] }
      sub := fun α β =>
        { app := fun X => α.app X - β.app X
          naturality' := by intros; rw [comp_sub, sub_comp, α.naturality, β.naturality] }
      add_assoc := by intros; ext; apply add_assoc
      zero_add := by intros; ext; apply zero_add
      add_zero := by intros; ext; apply add_zero
      sub_eq_add_neg := by intros; ext; apply sub_eq_add_neg
      add_left_neg := by intros; ext; apply add_left_neg
      add_comm := by intros; ext; apply add_comm }
  add_comp := by intros; ext; apply add_comp
  comp_add := by intros; ext; apply comp_add
#align category_theory.functor_category_preadditive CategoryTheory.functorCategoryPreadditive
-/

namespace NatTrans

variable {F G : C ⥤ D}

#print CategoryTheory.NatTrans.appHom /-
/-- Application of a natural transformation at a fixed object,
as group homomorphism -/
@[simps]
def appHom (X : C) : (F ⟶ G) →+ (F.obj X ⟶ G.obj X)
    where
  toFun α := α.app X
  map_zero' := rfl
  map_add' _ _ := rfl
#align category_theory.nat_trans.app_hom CategoryTheory.NatTrans.appHom
-/

#print CategoryTheory.NatTrans.app_zero /-
@[simp]
theorem app_zero (X : C) : (0 : F ⟶ G).app X = 0 :=
  rfl
#align category_theory.nat_trans.app_zero CategoryTheory.NatTrans.app_zero
-/

#print CategoryTheory.NatTrans.app_add /-
@[simp]
theorem app_add (X : C) (α β : F ⟶ G) : (α + β).app X = α.app X + β.app X :=
  rfl
#align category_theory.nat_trans.app_add CategoryTheory.NatTrans.app_add
-/

#print CategoryTheory.NatTrans.app_sub /-
@[simp]
theorem app_sub (X : C) (α β : F ⟶ G) : (α - β).app X = α.app X - β.app X :=
  rfl
#align category_theory.nat_trans.app_sub CategoryTheory.NatTrans.app_sub
-/

#print CategoryTheory.NatTrans.app_neg /-
@[simp]
theorem app_neg (X : C) (α : F ⟶ G) : (-α).app X = -α.app X :=
  rfl
#align category_theory.nat_trans.app_neg CategoryTheory.NatTrans.app_neg
-/

#print CategoryTheory.NatTrans.app_nsmul /-
@[simp]
theorem app_nsmul (X : C) (α : F ⟶ G) (n : ℕ) : (n • α).app X = n • α.app X :=
  (appHom X).map_nsmul α n
#align category_theory.nat_trans.app_nsmul CategoryTheory.NatTrans.app_nsmul
-/

#print CategoryTheory.NatTrans.app_zsmul /-
@[simp]
theorem app_zsmul (X : C) (α : F ⟶ G) (n : ℤ) : (n • α).app X = n • α.app X :=
  (appHom X : (F ⟶ G) →+ (F.obj X ⟶ G.obj X)).map_zsmul α n
#align category_theory.nat_trans.app_zsmul CategoryTheory.NatTrans.app_zsmul
-/

#print CategoryTheory.NatTrans.app_sum /-
@[simp]
theorem app_sum {ι : Type _} (s : Finset ι) (X : C) (α : ι → (F ⟶ G)) :
    (∑ i in s, α i).app X = ∑ i in s, (α i).app X := by rw [← app_hom_apply, AddMonoidHom.map_sum];
  rfl
#align category_theory.nat_trans.app_sum CategoryTheory.NatTrans.app_sum
-/

end NatTrans

end CategoryTheory

