/-
Copyright (c) 2022 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module category_theory.preadditive.of_biproducts
! leanprover-community/mathlib commit 932872382355f00112641d305ba0619305dc8642
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.Biproducts
import Mathbin.GroupTheory.EckmannHilton

/-!
# Constructing a semiadditive structure from binary biproducts

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We show that any category with zero morphisms and binary biproducts is enriched over the category
of commutative monoids.

-/


noncomputable section

universe v u

open CategoryTheory

open CategoryTheory.Limits

namespace CategoryTheory.SemiadditiveOfBinaryBiproducts

variable {C : Type u} [Category.{v} C] [HasZeroMorphisms C] [HasBinaryBiproducts C]

section

variable (X Y : C)

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.leftAdd /-
/-- `f +ₗ g` is the composite `X ⟶ Y ⊞ Y ⟶ Y`, where the first map is `(f, g)` and the second map
    is `(𝟙 𝟙)`. -/
@[simp]
def leftAdd (f g : X ⟶ Y) : X ⟶ Y :=
  biprod.lift f g ≫ biprod.desc (𝟙 Y) (𝟙 Y)
#align category_theory.semiadditive_of_binary_biproducts.left_add CategoryTheory.SemiadditiveOfBinaryBiproducts.leftAdd
-/

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.rightAdd /-
/-- `f +ᵣ g` is the composite `X ⟶ X ⊞ X ⟶ Y`, where the first map is `(𝟙, 𝟙)` and the second map
    is `(f g)`. -/
@[simp]
def rightAdd (f g : X ⟶ Y) : X ⟶ Y :=
  biprod.lift (𝟙 X) (𝟙 X) ≫ biprod.desc f g
#align category_theory.semiadditive_of_binary_biproducts.right_add CategoryTheory.SemiadditiveOfBinaryBiproducts.rightAdd
-/

local infixr:65 " +ₗ " => leftAdd X Y

local infixr:65 " +ᵣ " => rightAdd X Y

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.isUnital_leftAdd /-
theorem isUnital_leftAdd : EckmannHilton.IsUnital (· +ₗ ·) 0 :=
  ⟨⟨fun f => by simp [show biprod.lift (0 : X ⟶ Y) f = f ≫ biprod.inr by ext <;> simp]⟩,
    ⟨fun f => by simp [show biprod.lift f (0 : X ⟶ Y) = f ≫ biprod.inl by ext <;> simp]⟩⟩
#align category_theory.semiadditive_of_binary_biproducts.is_unital_left_add CategoryTheory.SemiadditiveOfBinaryBiproducts.isUnital_leftAdd
-/

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.isUnital_rightAdd /-
theorem isUnital_rightAdd : EckmannHilton.IsUnital (· +ᵣ ·) 0 :=
  ⟨⟨fun f => by simp [show biprod.desc (0 : X ⟶ Y) f = biprod.snd ≫ f by ext <;> simp]⟩,
    ⟨fun f => by simp [show biprod.desc f (0 : X ⟶ Y) = biprod.fst ≫ f by ext <;> simp]⟩⟩
#align category_theory.semiadditive_of_binary_biproducts.is_unital_right_add CategoryTheory.SemiadditiveOfBinaryBiproducts.isUnital_rightAdd
-/

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.distrib /-
theorem distrib (f g h k : X ⟶ Y) : (f +ᵣ g) +ₗ h +ᵣ k = (f +ₗ h) +ᵣ g +ₗ k :=
  by
  let diag : X ⊞ X ⟶ Y ⊞ Y := biprod.lift (biprod.desc f g) (biprod.desc h k)
  have hd₁ : biprod.inl ≫ diag = biprod.lift f h := by ext <;> simp
  have hd₂ : biprod.inr ≫ diag = biprod.lift g k := by ext <;> simp
  have h₁ : biprod.lift (f +ᵣ g) (h +ᵣ k) = biprod.lift (𝟙 X) (𝟙 X) ≫ diag := by ext <;> simp
  have h₂ : diag ≫ biprod.desc (𝟙 Y) (𝟙 Y) = biprod.desc (f +ₗ h) (g +ₗ k) := by
    ext <;> simp [reassoc_of hd₁, reassoc_of hd₂]
  rw [leftAdd, h₁, category.assoc, h₂, rightAdd]
#align category_theory.semiadditive_of_binary_biproducts.distrib CategoryTheory.SemiadditiveOfBinaryBiproducts.distrib
-/

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.addCommMonoidHomOfHasBinaryBiproducts /-
/-- In a category with binary biproducts, the morphisms form a commutative monoid. -/
def addCommMonoidHomOfHasBinaryBiproducts : AddCommMonoid (X ⟶ Y)
    where
  add := (· +ᵣ ·)
  add_assoc :=
    (EckmannHilton.mul_assoc (isUnital_leftAdd X Y) (isUnital_rightAdd X Y) (distrib X Y)).and_assoc
  zero := 0
  zero_add := (isUnital_rightAdd X Y).left_id
  add_zero := (isUnital_rightAdd X Y).right_id
  add_comm :=
    (EckmannHilton.mul_comm (isUnital_leftAdd X Y) (isUnital_rightAdd X Y) (distrib X Y)).comm
#align category_theory.semiadditive_of_binary_biproducts.add_comm_monoid_hom_of_has_binary_biproducts CategoryTheory.SemiadditiveOfBinaryBiproducts.addCommMonoidHomOfHasBinaryBiproducts
-/

end

section

variable {X Y Z : C}

attribute [local instance] add_comm_monoid_hom_of_has_binary_biproducts

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.add_eq_right_addition /-
theorem add_eq_right_addition (f g : X ⟶ Y) : f + g = biprod.lift (𝟙 X) (𝟙 X) ≫ biprod.desc f g :=
  rfl
#align category_theory.semiadditive_of_binary_biproducts.add_eq_right_addition CategoryTheory.SemiadditiveOfBinaryBiproducts.add_eq_right_addition
-/

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.add_eq_left_addition /-
theorem add_eq_left_addition (f g : X ⟶ Y) : f + g = biprod.lift f g ≫ biprod.desc (𝟙 Y) (𝟙 Y) :=
  congr_fun₂ (EckmannHilton.mul (isUnital_leftAdd X Y) (isUnital_rightAdd X Y) (distrib X Y)).symm f
    g
#align category_theory.semiadditive_of_binary_biproducts.add_eq_left_addition CategoryTheory.SemiadditiveOfBinaryBiproducts.add_eq_left_addition
-/

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.add_comp /-
theorem add_comp (f g : X ⟶ Y) (h : Y ⟶ Z) : (f + g) ≫ h = f ≫ h + g ≫ h := by
  simp only [add_eq_right_addition, category.assoc]; congr; ext <;> simp
#align category_theory.semiadditive_of_binary_biproducts.add_comp CategoryTheory.SemiadditiveOfBinaryBiproducts.add_comp
-/

#print CategoryTheory.SemiadditiveOfBinaryBiproducts.comp_add /-
theorem comp_add (f : X ⟶ Y) (g h : Y ⟶ Z) : f ≫ (g + h) = f ≫ g + f ≫ h := by
  simp only [add_eq_left_addition, ← category.assoc]; congr; ext <;> simp
#align category_theory.semiadditive_of_binary_biproducts.comp_add CategoryTheory.SemiadditiveOfBinaryBiproducts.comp_add
-/

end

end CategoryTheory.SemiadditiveOfBinaryBiproducts

