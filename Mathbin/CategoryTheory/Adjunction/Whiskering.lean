/-
Copyright (c) 2021 Adam Topaz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Adam Topaz

! This file was ported from Lean 3 source module category_theory.adjunction.whiskering
! leanprover-community/mathlib commit 3dadefa3f544b1db6214777fe47910739b54c66a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Whiskering
import Mathbin.CategoryTheory.Adjunction.Basic

/-!
> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.


Given categories `C D E`, functors `F : D ⥤ E` and `G : E ⥤ D` with an adjunction
`F ⊣ G`, we provide the induced adjunction between the functor categories `C ⥤ D` and `C ⥤ E`,
and the functor categories `E ⥤ C` and `D ⥤ C`.

-/


namespace CategoryTheory.Adjunction

open CategoryTheory

variable (C : Type _) {D E : Type _} [Category C] [Category D] [Category E] {F : D ⥤ E} {G : E ⥤ D}

#print CategoryTheory.Adjunction.whiskerRight /-
--  `tidy` works for all the proofs in this definition, but it's fairly slow.
/-- Given an adjunction `F ⊣ G`, this provides the natural adjunction
  `(whiskering_right C _ _).obj F ⊣ (whiskering_right C _ _).obj G`. -/
@[simps unit_app_app counit_app_app]
protected def whiskerRight (adj : F ⊣ G) :
    (whiskeringRight C D E).obj F ⊣ (whiskeringRight C E D).obj G :=
  mkOfUnitCounit
    { Unit :=
        { app := fun X =>
            (Functor.rightUnitor _).inv ≫ whiskerLeft X adj.Unit ≫ (Functor.associator _ _ _).inv
          naturality' := by intros; ext; dsimp; simp }
      counit :=
        { app := fun X =>
            (Functor.associator _ _ _).Hom ≫ whiskerLeft X adj.counit ≫ (Functor.rightUnitor _).Hom
          naturality' := by intros; ext; dsimp; simp }
      left_triangle := by ext; dsimp; simp
      right_triangle := by ext; dsimp; simp }
#align category_theory.adjunction.whisker_right CategoryTheory.Adjunction.whiskerRight
-/

#print CategoryTheory.Adjunction.whiskerLeft /-
-- `tidy` gets stuck for `left_triangle'` and `right_triangle'`.
/-- Given an adjunction `F ⊣ G`, this provides the natural adjunction
  `(whiskering_left _ _ C).obj G ⊣ (whiskering_left _ _ C).obj F`. -/
@[simps unit_app_app counit_app_app]
protected def whiskerLeft (adj : F ⊣ G) :
    (whiskeringLeft E D C).obj G ⊣ (whiskeringLeft D E C).obj F :=
  mkOfUnitCounit
    { Unit :=
        { app := fun X =>
            (Functor.leftUnitor _).inv ≫ whiskerRight adj.Unit X ≫ (Functor.associator _ _ _).Hom
          naturality' := by intros; ext; dsimp; simp }
      counit :=
        { app := fun X =>
            (Functor.associator _ _ _).inv ≫ whiskerRight adj.counit X ≫ (Functor.leftUnitor _).Hom
          naturality' := by intros; ext; dsimp; simp }
      left_triangle := by
        ext x; dsimp
        simp only [category.id_comp, category.comp_id, ← x.map_comp]; simp
      right_triangle := by
        ext x; dsimp
        simp only [category.id_comp, category.comp_id, ← x.map_comp]; simp }
#align category_theory.adjunction.whisker_left CategoryTheory.Adjunction.whiskerLeft
-/

end CategoryTheory.Adjunction

