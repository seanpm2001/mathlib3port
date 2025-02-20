/-
Copyright (c) 2018 Michael Jendrusch. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Michael Jendrusch, Scott Morrison, Bhavik Mehta, Jakob von Raumer

! This file was ported from Lean 3 source module category_theory.monoidal.coherence_lemmas
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Monoidal.Coherence

/-!
# Lemmas which are consequences of monoidal coherence

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

These lemmas are all proved `by coherence`.

## Future work
Investigate whether these lemmas are really needed,
or if they can be replaced by use of the `coherence` tactic.
-/


open CategoryTheory

open CategoryTheory.Category

open CategoryTheory.Iso

namespace CategoryTheory.MonoidalCategory

variable {C : Type _} [Category C] [MonoidalCategory C]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.leftUnitor_tensor' /-
-- See Proposition 2.2.4 of <http://www-math.mit.edu/~etingof/egnobookfinal.pdf>
@[reassoc]
theorem leftUnitor_tensor' (X Y : C) : (α_ (𝟙_ C) X Y).Hom ≫ (λ_ (X ⊗ Y)).Hom = (λ_ X).Hom ⊗ 𝟙 Y :=
  by coherence
#align category_theory.monoidal_category.left_unitor_tensor' CategoryTheory.MonoidalCategory.leftUnitor_tensor'
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.leftUnitor_tensor /-
@[reassoc, simp]
theorem leftUnitor_tensor (X Y : C) : (λ_ (X ⊗ Y)).Hom = (α_ (𝟙_ C) X Y).inv ≫ ((λ_ X).Hom ⊗ 𝟙 Y) :=
  by coherence
#align category_theory.monoidal_category.left_unitor_tensor CategoryTheory.MonoidalCategory.leftUnitor_tensor
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.leftUnitor_tensor_inv /-
@[reassoc]
theorem leftUnitor_tensor_inv (X Y : C) :
    (λ_ (X ⊗ Y)).inv = ((λ_ X).inv ⊗ 𝟙 Y) ≫ (α_ (𝟙_ C) X Y).Hom := by coherence
#align category_theory.monoidal_category.left_unitor_tensor_inv CategoryTheory.MonoidalCategory.leftUnitor_tensor_inv
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.id_tensor_rightUnitor_inv /-
@[reassoc]
theorem id_tensor_rightUnitor_inv (X Y : C) : 𝟙 X ⊗ (ρ_ Y).inv = (ρ_ _).inv ≫ (α_ _ _ _).Hom := by
  coherence
#align category_theory.monoidal_category.id_tensor_right_unitor_inv CategoryTheory.MonoidalCategory.id_tensor_rightUnitor_inv
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.leftUnitor_inv_tensor_id /-
@[reassoc]
theorem leftUnitor_inv_tensor_id (X Y : C) : (λ_ X).inv ⊗ 𝟙 Y = (λ_ _).inv ≫ (α_ _ _ _).inv := by
  coherence
#align category_theory.monoidal_category.left_unitor_inv_tensor_id CategoryTheory.MonoidalCategory.leftUnitor_inv_tensor_id
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.pentagon_inv_inv_hom /-
@[reassoc]
theorem pentagon_inv_inv_hom (W X Y Z : C) :
    (α_ W (X ⊗ Y) Z).inv ≫ ((α_ W X Y).inv ⊗ 𝟙 Z) ≫ (α_ (W ⊗ X) Y Z).Hom =
      (𝟙 W ⊗ (α_ X Y Z).Hom) ≫ (α_ W X (Y ⊗ Z)).inv :=
  by coherence
#align category_theory.monoidal_category.pentagon_inv_inv_hom CategoryTheory.MonoidalCategory.pentagon_inv_inv_hom
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.triangle_assoc_comp_right_inv /-
@[simp, reassoc]
theorem triangle_assoc_comp_right_inv (X Y : C) :
    ((ρ_ X).inv ⊗ 𝟙 Y) ≫ (α_ X (𝟙_ C) Y).Hom = 𝟙 X ⊗ (λ_ Y).inv := by coherence
#align category_theory.monoidal_category.triangle_assoc_comp_right_inv CategoryTheory.MonoidalCategory.triangle_assoc_comp_right_inv
-/

#print CategoryTheory.MonoidalCategory.unitors_equal /-
theorem unitors_equal : (λ_ (𝟙_ C)).Hom = (ρ_ (𝟙_ C)).Hom := by coherence
#align category_theory.monoidal_category.unitors_equal CategoryTheory.MonoidalCategory.unitors_equal
-/

#print CategoryTheory.MonoidalCategory.unitors_inv_equal /-
theorem unitors_inv_equal : (λ_ (𝟙_ C)).inv = (ρ_ (𝟙_ C)).inv := by coherence
#align category_theory.monoidal_category.unitors_inv_equal CategoryTheory.MonoidalCategory.unitors_inv_equal
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.pentagon_hom_inv /-
@[reassoc]
theorem pentagon_hom_inv {W X Y Z : C} :
    (α_ W X (Y ⊗ Z)).Hom ≫ (𝟙 W ⊗ (α_ X Y Z).inv) =
      (α_ (W ⊗ X) Y Z).inv ≫ ((α_ W X Y).Hom ⊗ 𝟙 Z) ≫ (α_ W (X ⊗ Y) Z).Hom :=
  by coherence
#align category_theory.monoidal_category.pentagon_hom_inv CategoryTheory.MonoidalCategory.pentagon_hom_inv
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.pentagon_inv_hom /-
@[reassoc]
theorem pentagon_inv_hom (W X Y Z : C) :
    (α_ (W ⊗ X) Y Z).inv ≫ ((α_ W X Y).Hom ⊗ 𝟙 Z) =
      (α_ W X (Y ⊗ Z)).Hom ≫ (𝟙 W ⊗ (α_ X Y Z).inv) ≫ (α_ W (X ⊗ Y) Z).inv :=
  by coherence
#align category_theory.monoidal_category.pentagon_inv_hom CategoryTheory.MonoidalCategory.pentagon_inv_hom
-/

end CategoryTheory.MonoidalCategory

