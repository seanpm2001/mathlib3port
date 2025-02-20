/-
Copyright (c) 2020 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta, Thomas Read, Andrew Yang

! This file was ported from Lean 3 source module category_theory.adjunction.opposites
! leanprover-community/mathlib commit 31ca6f9cf5f90a6206092cd7f84b359dcb6d52e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Adjunction.Basic
import Mathbin.CategoryTheory.Yoneda
import Mathbin.CategoryTheory.Opposites

/-!
# Opposite adjunctions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains constructions to relate adjunctions of functors to adjunctions of their
opposites.
These constructions are used to show uniqueness of adjoints (up to natural isomorphism).

## Tags
adjunction, opposite, uniqueness
-/


open CategoryTheory

universe v₁ v₂ u₁ u₂

-- morphism levels before object levels. See note [category_theory universes].
variable {C : Type u₁} [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D]

namespace CategoryTheory.Adjunction

#print CategoryTheory.Adjunction.adjointOfOpAdjointOp /-
/-- If `G.op` is adjoint to `F.op` then `F` is adjoint to `G`. -/
@[simps unit_app counit_app]
def adjointOfOpAdjointOp (F : C ⥤ D) (G : D ⥤ C) (h : G.op ⊣ F.op) : F ⊣ G :=
  Adjunction.mkOfHomEquiv
    {
      homEquiv := fun X Y =>
        ((h.homEquiv (Opposite.op Y) (Opposite.op X)).trans (opEquiv _ _)).symm.trans
          (opEquiv _ _) }
#align category_theory.adjunction.adjoint_of_op_adjoint_op CategoryTheory.Adjunction.adjointOfOpAdjointOp
-/

#print CategoryTheory.Adjunction.adjointUnopOfAdjointOp /-
/-- If `G` is adjoint to `F.op` then `F` is adjoint to `G.unop`. -/
def adjointUnopOfAdjointOp (F : C ⥤ D) (G : Dᵒᵖ ⥤ Cᵒᵖ) (h : G ⊣ F.op) : F ⊣ G.unop :=
  adjointOfOpAdjointOp F G.unop (h.ofNatIsoLeft G.opUnopIso.symm)
#align category_theory.adjunction.adjoint_unop_of_adjoint_op CategoryTheory.Adjunction.adjointUnopOfAdjointOp
-/

#print CategoryTheory.Adjunction.unopAdjointOfOpAdjoint /-
/-- If `G.op` is adjoint to `F` then `F.unop` is adjoint to `G`. -/
def unopAdjointOfOpAdjoint (F : Cᵒᵖ ⥤ Dᵒᵖ) (G : D ⥤ C) (h : G.op ⊣ F) : F.unop ⊣ G :=
  adjointOfOpAdjointOp _ _ (h.ofNatIsoRight F.opUnopIso.symm)
#align category_theory.adjunction.unop_adjoint_of_op_adjoint CategoryTheory.Adjunction.unopAdjointOfOpAdjoint
-/

#print CategoryTheory.Adjunction.unopAdjointUnopOfAdjoint /-
/-- If `G` is adjoint to `F` then `F.unop` is adjoint to `G.unop`. -/
def unopAdjointUnopOfAdjoint (F : Cᵒᵖ ⥤ Dᵒᵖ) (G : Dᵒᵖ ⥤ Cᵒᵖ) (h : G ⊣ F) : F.unop ⊣ G.unop :=
  adjointUnopOfAdjointOp F.unop G (h.ofNatIsoRight F.opUnopIso.symm)
#align category_theory.adjunction.unop_adjoint_unop_of_adjoint CategoryTheory.Adjunction.unopAdjointUnopOfAdjoint
-/

#print CategoryTheory.Adjunction.opAdjointOpOfAdjoint /-
/-- If `G` is adjoint to `F` then `F.op` is adjoint to `G.op`. -/
@[simps unit_app counit_app]
def opAdjointOpOfAdjoint (F : C ⥤ D) (G : D ⥤ C) (h : G ⊣ F) : F.op ⊣ G.op :=
  Adjunction.mkOfHomEquiv
    {
      homEquiv := fun X Y =>
        (opEquiv _ Y).trans ((h.homEquiv _ _).symm.trans (opEquiv X (Opposite.op _)).symm) }
#align category_theory.adjunction.op_adjoint_op_of_adjoint CategoryTheory.Adjunction.opAdjointOpOfAdjoint
-/

#print CategoryTheory.Adjunction.adjointOpOfAdjointUnop /-
/-- If `G` is adjoint to `F.unop` then `F` is adjoint to `G.op`. -/
def adjointOpOfAdjointUnop (F : Cᵒᵖ ⥤ Dᵒᵖ) (G : D ⥤ C) (h : G ⊣ F.unop) : F ⊣ G.op :=
  (opAdjointOpOfAdjoint F.unop _ h).ofNatIsoLeft F.opUnopIso
#align category_theory.adjunction.adjoint_op_of_adjoint_unop CategoryTheory.Adjunction.adjointOpOfAdjointUnop
-/

#print CategoryTheory.Adjunction.opAdjointOfUnopAdjoint /-
/-- If `G.unop` is adjoint to `F` then `F.op` is adjoint to `G`. -/
def opAdjointOfUnopAdjoint (F : C ⥤ D) (G : Dᵒᵖ ⥤ Cᵒᵖ) (h : G.unop ⊣ F) : F.op ⊣ G :=
  (opAdjointOpOfAdjoint _ G.unop h).ofNatIsoRight G.opUnopIso
#align category_theory.adjunction.op_adjoint_of_unop_adjoint CategoryTheory.Adjunction.opAdjointOfUnopAdjoint
-/

#print CategoryTheory.Adjunction.adjointOfUnopAdjointUnop /-
/-- If `G.unop` is adjoint to `F.unop` then `F` is adjoint to `G`. -/
def adjointOfUnopAdjointUnop (F : Cᵒᵖ ⥤ Dᵒᵖ) (G : Dᵒᵖ ⥤ Cᵒᵖ) (h : G.unop ⊣ F.unop) : F ⊣ G :=
  (adjointOpOfAdjointUnop _ _ h).ofNatIsoRight G.opUnopIso
#align category_theory.adjunction.adjoint_of_unop_adjoint_unop CategoryTheory.Adjunction.adjointOfUnopAdjointUnop
-/

#print CategoryTheory.Adjunction.leftAdjointsCoyonedaEquiv /-
/-- If `F` and `F'` are both adjoint to `G`, there is a natural isomorphism
`F.op ⋙ coyoneda ≅ F'.op ⋙ coyoneda`.
We use this in combination with `fully_faithful_cancel_right` to show left adjoints are unique.
-/
def leftAdjointsCoyonedaEquiv {F F' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G) :
    F.op ⋙ coyoneda ≅ F'.op ⋙ coyoneda :=
  NatIso.ofComponents
    (fun X =>
      NatIso.ofComponents
        (fun Y => ((adj1.homEquiv X.unop Y).trans (adj2.homEquiv X.unop Y).symm).toIso) (by tidy))
    (by tidy)
#align category_theory.adjunction.left_adjoints_coyoneda_equiv CategoryTheory.Adjunction.leftAdjointsCoyonedaEquiv
-/

#print CategoryTheory.Adjunction.leftAdjointUniq /-
/-- If `F` and `F'` are both left adjoint to `G`, then they are naturally isomorphic. -/
def leftAdjointUniq {F F' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G) : F ≅ F' :=
  NatIso.removeOp (fullyFaithfulCancelRight _ (leftAdjointsCoyonedaEquiv adj2 adj1))
#align category_theory.adjunction.left_adjoint_uniq CategoryTheory.Adjunction.leftAdjointUniq
-/

#print CategoryTheory.Adjunction.homEquiv_leftAdjointUniq_hom_app /-
@[simp]
theorem homEquiv_leftAdjointUniq_hom_app {F F' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G)
    (x : C) : adj1.homEquiv _ _ ((leftAdjointUniq adj1 adj2).Hom.app x) = adj2.Unit.app x :=
  by
  apply (adj1.hom_equiv _ _).symm.Injective
  apply Quiver.Hom.op_inj
  apply coyoneda.map_injective
  swap; infer_instance
  ext f y
  simpa [left_adjoint_uniq, left_adjoints_coyoneda_equiv]
#align category_theory.adjunction.hom_equiv_left_adjoint_uniq_hom_app CategoryTheory.Adjunction.homEquiv_leftAdjointUniq_hom_app
-/

#print CategoryTheory.Adjunction.unit_leftAdjointUniq_hom /-
@[simp, reassoc]
theorem unit_leftAdjointUniq_hom {F F' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G) :
    adj1.Unit ≫ whiskerRight (leftAdjointUniq adj1 adj2).Hom G = adj2.Unit :=
  by
  ext x
  rw [nat_trans.comp_app, ← hom_equiv_left_adjoint_uniq_hom_app adj1 adj2]
  simp [-hom_equiv_left_adjoint_uniq_hom_app, ← G.map_comp]
#align category_theory.adjunction.unit_left_adjoint_uniq_hom CategoryTheory.Adjunction.unit_leftAdjointUniq_hom
-/

#print CategoryTheory.Adjunction.unit_leftAdjointUniq_hom_app /-
@[simp, reassoc]
theorem unit_leftAdjointUniq_hom_app {F F' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G)
    (x : C) : adj1.Unit.app x ≫ G.map ((leftAdjointUniq adj1 adj2).Hom.app x) = adj2.Unit.app x :=
  by rw [← unit_left_adjoint_uniq_hom adj1 adj2]; rfl
#align category_theory.adjunction.unit_left_adjoint_uniq_hom_app CategoryTheory.Adjunction.unit_leftAdjointUniq_hom_app
-/

#print CategoryTheory.Adjunction.leftAdjointUniq_hom_counit /-
@[simp, reassoc]
theorem leftAdjointUniq_hom_counit {F F' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G) :
    whiskerLeft G (leftAdjointUniq adj1 adj2).Hom ≫ adj2.counit = adj1.counit :=
  by
  ext x
  apply Quiver.Hom.op_inj
  apply coyoneda.map_injective
  swap; infer_instance
  ext y f
  have :
    F.map (adj2.unit.app (G.obj x)) ≫ adj1.counit.app (F'.obj (G.obj x)) ≫ adj2.counit.app x ≫ f =
      adj1.counit.app x ≫ f :=
    by erw [← adj1.counit.naturality, ← F.map_comp_assoc]; simpa
  simpa [left_adjoint_uniq, left_adjoints_coyoneda_equiv] using this
#align category_theory.adjunction.left_adjoint_uniq_hom_counit CategoryTheory.Adjunction.leftAdjointUniq_hom_counit
-/

#print CategoryTheory.Adjunction.leftAdjointUniq_hom_app_counit /-
@[simp, reassoc]
theorem leftAdjointUniq_hom_app_counit {F F' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G)
    (x : D) :
    (leftAdjointUniq adj1 adj2).Hom.app (G.obj x) ≫ adj2.counit.app x = adj1.counit.app x := by
  rw [← left_adjoint_uniq_hom_counit adj1 adj2]; rfl
#align category_theory.adjunction.left_adjoint_uniq_hom_app_counit CategoryTheory.Adjunction.leftAdjointUniq_hom_app_counit
-/

#print CategoryTheory.Adjunction.leftAdjointUniq_inv_app /-
@[simp]
theorem leftAdjointUniq_inv_app {F F' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G) (x : C) :
    (leftAdjointUniq adj1 adj2).inv.app x = (leftAdjointUniq adj2 adj1).Hom.app x :=
  rfl
#align category_theory.adjunction.left_adjoint_uniq_inv_app CategoryTheory.Adjunction.leftAdjointUniq_inv_app
-/

#print CategoryTheory.Adjunction.leftAdjointUniq_trans /-
@[simp, reassoc]
theorem leftAdjointUniq_trans {F F' F'' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G)
    (adj3 : F'' ⊣ G) :
    (leftAdjointUniq adj1 adj2).Hom ≫ (leftAdjointUniq adj2 adj3).Hom =
      (leftAdjointUniq adj1 adj3).Hom :=
  by
  ext
  apply Quiver.Hom.op_inj
  apply coyoneda.map_injective
  swap; infer_instance
  ext
  simp [left_adjoints_coyoneda_equiv, left_adjoint_uniq]
#align category_theory.adjunction.left_adjoint_uniq_trans CategoryTheory.Adjunction.leftAdjointUniq_trans
-/

#print CategoryTheory.Adjunction.leftAdjointUniq_trans_app /-
@[simp, reassoc]
theorem leftAdjointUniq_trans_app {F F' F'' : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G)
    (adj3 : F'' ⊣ G) (x : C) :
    (leftAdjointUniq adj1 adj2).Hom.app x ≫ (leftAdjointUniq adj2 adj3).Hom.app x =
      (leftAdjointUniq adj1 adj3).Hom.app x :=
  by rw [← left_adjoint_uniq_trans adj1 adj2 adj3]; rfl
#align category_theory.adjunction.left_adjoint_uniq_trans_app CategoryTheory.Adjunction.leftAdjointUniq_trans_app
-/

#print CategoryTheory.Adjunction.leftAdjointUniq_refl /-
@[simp]
theorem leftAdjointUniq_refl {F : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) :
    (leftAdjointUniq adj1 adj1).Hom = 𝟙 _ := by
  ext
  apply Quiver.Hom.op_inj
  apply coyoneda.map_injective
  swap; infer_instance
  ext
  simp [left_adjoints_coyoneda_equiv, left_adjoint_uniq]
#align category_theory.adjunction.left_adjoint_uniq_refl CategoryTheory.Adjunction.leftAdjointUniq_refl
-/

#print CategoryTheory.Adjunction.rightAdjointUniq /-
/-- If `G` and `G'` are both right adjoint to `F`, then they are naturally isomorphic. -/
def rightAdjointUniq {F : C ⥤ D} {G G' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F ⊣ G') : G ≅ G' :=
  NatIso.removeOp (leftAdjointUniq (opAdjointOpOfAdjoint _ F adj2) (opAdjointOpOfAdjoint _ _ adj1))
#align category_theory.adjunction.right_adjoint_uniq CategoryTheory.Adjunction.rightAdjointUniq
-/

#print CategoryTheory.Adjunction.homEquiv_symm_rightAdjointUniq_hom_app /-
@[simp]
theorem homEquiv_symm_rightAdjointUniq_hom_app {F : C ⥤ D} {G G' : D ⥤ C} (adj1 : F ⊣ G)
    (adj2 : F ⊣ G') (x : D) :
    (adj2.homEquiv _ _).symm ((rightAdjointUniq adj1 adj2).Hom.app x) = adj1.counit.app x :=
  by
  apply Quiver.Hom.op_inj
  convert
    hom_equiv_left_adjoint_uniq_hom_app (op_adjoint_op_of_adjoint _ F adj2)
      (op_adjoint_op_of_adjoint _ _ adj1) (Opposite.op x)
  simpa
#align category_theory.adjunction.hom_equiv_symm_right_adjoint_uniq_hom_app CategoryTheory.Adjunction.homEquiv_symm_rightAdjointUniq_hom_app
-/

#print CategoryTheory.Adjunction.unit_rightAdjointUniq_hom_app /-
@[simp, reassoc]
theorem unit_rightAdjointUniq_hom_app {F : C ⥤ D} {G G' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F ⊣ G')
    (x : C) : adj1.Unit.app x ≫ (rightAdjointUniq adj1 adj2).Hom.app (F.obj x) = adj2.Unit.app x :=
  by
  apply Quiver.Hom.op_inj
  convert
    left_adjoint_uniq_hom_app_counit (op_adjoint_op_of_adjoint _ _ adj2)
      (op_adjoint_op_of_adjoint _ _ adj1) (Opposite.op x)
  all_goals simpa
#align category_theory.adjunction.unit_right_adjoint_uniq_hom_app CategoryTheory.Adjunction.unit_rightAdjointUniq_hom_app
-/

#print CategoryTheory.Adjunction.unit_rightAdjointUniq_hom /-
@[simp, reassoc]
theorem unit_rightAdjointUniq_hom {F : C ⥤ D} {G G' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F ⊣ G') :
    adj1.Unit ≫ whiskerLeft F (rightAdjointUniq adj1 adj2).Hom = adj2.Unit := by ext x; simp
#align category_theory.adjunction.unit_right_adjoint_uniq_hom CategoryTheory.Adjunction.unit_rightAdjointUniq_hom
-/

#print CategoryTheory.Adjunction.rightAdjointUniq_hom_app_counit /-
@[simp, reassoc]
theorem rightAdjointUniq_hom_app_counit {F : C ⥤ D} {G G' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F ⊣ G')
    (x : D) :
    F.map ((rightAdjointUniq adj1 adj2).Hom.app x) ≫ adj2.counit.app x = adj1.counit.app x :=
  by
  apply Quiver.Hom.op_inj
  convert
    unit_left_adjoint_uniq_hom_app (op_adjoint_op_of_adjoint _ _ adj2)
      (op_adjoint_op_of_adjoint _ _ adj1) (Opposite.op x)
  all_goals simpa
#align category_theory.adjunction.right_adjoint_uniq_hom_app_counit CategoryTheory.Adjunction.rightAdjointUniq_hom_app_counit
-/

#print CategoryTheory.Adjunction.rightAdjointUniq_hom_counit /-
@[simp, reassoc]
theorem rightAdjointUniq_hom_counit {F : C ⥤ D} {G G' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F ⊣ G') :
    whiskerRight (rightAdjointUniq adj1 adj2).Hom F ≫ adj2.counit = adj1.counit := by ext; simp
#align category_theory.adjunction.right_adjoint_uniq_hom_counit CategoryTheory.Adjunction.rightAdjointUniq_hom_counit
-/

#print CategoryTheory.Adjunction.rightAdjointUniq_inv_app /-
@[simp]
theorem rightAdjointUniq_inv_app {F : C ⥤ D} {G G' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F ⊣ G') (x : D) :
    (rightAdjointUniq adj1 adj2).inv.app x = (rightAdjointUniq adj2 adj1).Hom.app x :=
  rfl
#align category_theory.adjunction.right_adjoint_uniq_inv_app CategoryTheory.Adjunction.rightAdjointUniq_inv_app
-/

#print CategoryTheory.Adjunction.rightAdjointUniq_trans_app /-
@[simp, reassoc]
theorem rightAdjointUniq_trans_app {F : C ⥤ D} {G G' G'' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F ⊣ G')
    (adj3 : F ⊣ G'') (x : D) :
    (rightAdjointUniq adj1 adj2).Hom.app x ≫ (rightAdjointUniq adj2 adj3).Hom.app x =
      (rightAdjointUniq adj1 adj3).Hom.app x :=
  by
  apply Quiver.Hom.op_inj
  exact
    left_adjoint_uniq_trans_app (op_adjoint_op_of_adjoint _ _ adj3)
      (op_adjoint_op_of_adjoint _ _ adj2) (op_adjoint_op_of_adjoint _ _ adj1) (Opposite.op x)
#align category_theory.adjunction.right_adjoint_uniq_trans_app CategoryTheory.Adjunction.rightAdjointUniq_trans_app
-/

#print CategoryTheory.Adjunction.rightAdjointUniq_trans /-
@[simp, reassoc]
theorem rightAdjointUniq_trans {F : C ⥤ D} {G G' G'' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F ⊣ G')
    (adj3 : F ⊣ G'') :
    (rightAdjointUniq adj1 adj2).Hom ≫ (rightAdjointUniq adj2 adj3).Hom =
      (rightAdjointUniq adj1 adj3).Hom :=
  by ext; simp
#align category_theory.adjunction.right_adjoint_uniq_trans CategoryTheory.Adjunction.rightAdjointUniq_trans
-/

#print CategoryTheory.Adjunction.rightAdjointUniq_refl /-
@[simp]
theorem rightAdjointUniq_refl {F : C ⥤ D} {G : D ⥤ C} (adj1 : F ⊣ G) :
    (rightAdjointUniq adj1 adj1).Hom = 𝟙 _ := by delta right_adjoint_uniq; simp
#align category_theory.adjunction.right_adjoint_uniq_refl CategoryTheory.Adjunction.rightAdjointUniq_refl
-/

#print CategoryTheory.Adjunction.natIsoOfLeftAdjointNatIso /-
/-- Given two adjunctions, if the left adjoints are naturally isomorphic, then so are the right
adjoints.
-/
def natIsoOfLeftAdjointNatIso {F F' : C ⥤ D} {G G' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G')
    (l : F ≅ F') : G ≅ G' :=
  rightAdjointUniq adj1 (adj2.ofNatIsoLeft l.symm)
#align category_theory.adjunction.nat_iso_of_left_adjoint_nat_iso CategoryTheory.Adjunction.natIsoOfLeftAdjointNatIso
-/

#print CategoryTheory.Adjunction.natIsoOfRightAdjointNatIso /-
/-- Given two adjunctions, if the right adjoints are naturally isomorphic, then so are the left
adjoints.
-/
def natIsoOfRightAdjointNatIso {F F' : C ⥤ D} {G G' : D ⥤ C} (adj1 : F ⊣ G) (adj2 : F' ⊣ G')
    (r : G ≅ G') : F ≅ F' :=
  leftAdjointUniq adj1 (adj2.ofNatIsoRight r.symm)
#align category_theory.adjunction.nat_iso_of_right_adjoint_nat_iso CategoryTheory.Adjunction.natIsoOfRightAdjointNatIso
-/

end CategoryTheory.Adjunction

