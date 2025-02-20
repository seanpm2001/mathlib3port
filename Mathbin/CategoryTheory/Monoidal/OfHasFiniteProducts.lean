/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Simon Hudon

! This file was ported from Lean 3 source module category_theory.monoidal.of_has_finite_products
! leanprover-community/mathlib commit 6b31d1eebd64eab86d5bd9936bfaada6ca8b5842
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Monoidal.Braided
import Mathbin.CategoryTheory.Limits.Shapes.BinaryProducts
import Mathbin.CategoryTheory.Limits.Shapes.Terminal

/-!
# The natural monoidal structure on any category with finite (co)products.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A category with a monoidal structure provided in this way
is sometimes called a (co)cartesian category,
although this is also sometimes used to mean a finitely complete category.
(See <https://ncatlab.org/nlab/show/cartesian+category>.)

As this works with either products or coproducts,
and sometimes we want to think of a different monoidal structure entirely,
we don't set up either construct as an instance.

## Implementation
We had previously chosen to rely on `has_terminal` and `has_binary_products` instead of
`has_finite_products`, because we were later relying on the definitional form of the tensor product.
Now that `has_limit` has been refactored to be a `Prop`,
this issue is irrelevant and we could simplify the construction here.

See `category_theory.monoidal.of_chosen_finite_products` for a variant of this construction
which allows specifying a particular choice of terminal object and binary products.
-/


universe v u

noncomputable section

namespace CategoryTheory

variable (C : Type u) [Category.{v} C] {X Y : C}

open CategoryTheory.Limits

section

attribute [local tidy] tactic.case_bash

#print CategoryTheory.monoidalOfHasFiniteProducts /-
/-- A category with a terminal object and binary products has a natural monoidal structure. -/
def monoidalOfHasFiniteProducts [HasTerminal C] [HasBinaryProducts C] : MonoidalCategory C
    where
  tensorUnit := ⊤_ C
  tensorObj X Y := X ⨯ Y
  tensorHom _ _ _ _ f g := Limits.prod.map f g
  associator := prod.associator
  leftUnitor P := prod.leftUnitor P
  rightUnitor P := prod.rightUnitor P
  pentagon' := prod.pentagon
  triangle' := prod.triangle
  associator_naturality' := @prod.associator_naturality _ _ _
#align category_theory.monoidal_of_has_finite_products CategoryTheory.monoidalOfHasFiniteProducts
-/

end

section

attribute [local instance] monoidal_of_has_finite_products

open MonoidalCategory

#print CategoryTheory.symmetricOfHasFiniteProducts /-
/-- The monoidal structure coming from finite products is symmetric.
-/
@[simps]
def symmetricOfHasFiniteProducts [HasTerminal C] [HasBinaryProducts C] : SymmetricCategory C
    where
  braiding X Y := Limits.prod.braiding X Y
  braiding_naturality' X X' Y Y' f g := by dsimp [tensor_hom]; simp
  hexagon_forward' X Y Z := by dsimp [monoidal_of_has_finite_products]; simp
  hexagon_reverse' X Y Z := by dsimp [monoidal_of_has_finite_products]; simp
  symmetry' X Y := by dsimp; simp; rfl
#align category_theory.symmetric_of_has_finite_products CategoryTheory.symmetricOfHasFiniteProducts
-/

end

namespace MonoidalOfHasFiniteProducts

variable [HasTerminal C] [HasBinaryProducts C]

attribute [local instance] monoidal_of_has_finite_products

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.monoidalOfHasFiniteProducts.tensorObj /-
@[simp]
theorem tensorObj (X Y : C) : X ⊗ Y = (X ⨯ Y) :=
  rfl
#align category_theory.monoidal_of_has_finite_products.tensor_obj CategoryTheory.monoidalOfHasFiniteProducts.tensorObj
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.monoidalOfHasFiniteProducts.tensorHom /-
@[simp]
theorem tensorHom {W X Y Z : C} (f : W ⟶ X) (g : Y ⟶ Z) : f ⊗ g = Limits.prod.map f g :=
  rfl
#align category_theory.monoidal_of_has_finite_products.tensor_hom CategoryTheory.monoidalOfHasFiniteProducts.tensorHom
-/

#print CategoryTheory.monoidalOfHasFiniteProducts.leftUnitor_hom /-
@[simp]
theorem leftUnitor_hom (X : C) : (λ_ X).Hom = Limits.prod.snd :=
  rfl
#align category_theory.monoidal_of_has_finite_products.left_unitor_hom CategoryTheory.monoidalOfHasFiniteProducts.leftUnitor_hom
-/

#print CategoryTheory.monoidalOfHasFiniteProducts.leftUnitor_inv /-
@[simp]
theorem leftUnitor_inv (X : C) : (λ_ X).inv = prod.lift (terminal.from X) (𝟙 _) :=
  rfl
#align category_theory.monoidal_of_has_finite_products.left_unitor_inv CategoryTheory.monoidalOfHasFiniteProducts.leftUnitor_inv
-/

#print CategoryTheory.monoidalOfHasFiniteProducts.rightUnitor_hom /-
@[simp]
theorem rightUnitor_hom (X : C) : (ρ_ X).Hom = Limits.prod.fst :=
  rfl
#align category_theory.monoidal_of_has_finite_products.right_unitor_hom CategoryTheory.monoidalOfHasFiniteProducts.rightUnitor_hom
-/

#print CategoryTheory.monoidalOfHasFiniteProducts.rightUnitor_inv /-
@[simp]
theorem rightUnitor_inv (X : C) : (ρ_ X).inv = prod.lift (𝟙 _) (terminal.from X) :=
  rfl
#align category_theory.monoidal_of_has_finite_products.right_unitor_inv CategoryTheory.monoidalOfHasFiniteProducts.rightUnitor_inv
-/

#print CategoryTheory.monoidalOfHasFiniteProducts.associator_hom /-
-- We don't mark this as a simp lemma, even though in many particular
-- categories the right hand side will simplify significantly further.
-- For now, we'll plan to create specialised simp lemmas in each particular category.
theorem associator_hom (X Y Z : C) :
    (α_ X Y Z).Hom =
      prod.lift (Limits.prod.fst ≫ Limits.prod.fst)
        (prod.lift (Limits.prod.fst ≫ Limits.prod.snd) Limits.prod.snd) :=
  rfl
#align category_theory.monoidal_of_has_finite_products.associator_hom CategoryTheory.monoidalOfHasFiniteProducts.associator_hom
-/

end MonoidalOfHasFiniteProducts

section

attribute [local tidy] tactic.case_bash

#print CategoryTheory.monoidalOfHasFiniteCoproducts /-
/-- A category with an initial object and binary coproducts has a natural monoidal structure. -/
def monoidalOfHasFiniteCoproducts [HasInitial C] [HasBinaryCoproducts C] : MonoidalCategory C
    where
  tensorUnit := ⊥_ C
  tensorObj X Y := X ⨿ Y
  tensorHom _ _ _ _ f g := Limits.coprod.map f g
  associator := coprod.associator
  leftUnitor := coprod.leftUnitor
  rightUnitor := coprod.rightUnitor
  pentagon' := coprod.pentagon
  triangle' := coprod.triangle
  associator_naturality' := @coprod.associator_naturality _ _ _
#align category_theory.monoidal_of_has_finite_coproducts CategoryTheory.monoidalOfHasFiniteCoproducts
-/

end

section

attribute [local instance] monoidal_of_has_finite_coproducts

open MonoidalCategory

#print CategoryTheory.symmetricOfHasFiniteCoproducts /-
/-- The monoidal structure coming from finite coproducts is symmetric.
-/
@[simps]
def symmetricOfHasFiniteCoproducts [HasInitial C] [HasBinaryCoproducts C] : SymmetricCategory C
    where
  braiding := Limits.coprod.braiding
  braiding_naturality' X X' Y Y' f g := by dsimp [tensor_hom]; simp
  hexagon_forward' X Y Z := by dsimp [monoidal_of_has_finite_coproducts]; simp
  hexagon_reverse' X Y Z := by dsimp [monoidal_of_has_finite_coproducts]; simp
  symmetry' X Y := by dsimp; simp; rfl
#align category_theory.symmetric_of_has_finite_coproducts CategoryTheory.symmetricOfHasFiniteCoproducts
-/

end

namespace MonoidalOfHasFiniteCoproducts

variable [HasInitial C] [HasBinaryCoproducts C]

attribute [local instance] monoidal_of_has_finite_coproducts

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.monoidalOfHasFiniteCoproducts.tensorObj /-
@[simp]
theorem tensorObj (X Y : C) : X ⊗ Y = (X ⨿ Y) :=
  rfl
#align category_theory.monoidal_of_has_finite_coproducts.tensor_obj CategoryTheory.monoidalOfHasFiniteCoproducts.tensorObj
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.monoidalOfHasFiniteCoproducts.tensorHom /-
@[simp]
theorem tensorHom {W X Y Z : C} (f : W ⟶ X) (g : Y ⟶ Z) : f ⊗ g = Limits.coprod.map f g :=
  rfl
#align category_theory.monoidal_of_has_finite_coproducts.tensor_hom CategoryTheory.monoidalOfHasFiniteCoproducts.tensorHom
-/

#print CategoryTheory.monoidalOfHasFiniteCoproducts.leftUnitor_hom /-
@[simp]
theorem leftUnitor_hom (X : C) : (λ_ X).Hom = coprod.desc (initial.to X) (𝟙 _) :=
  rfl
#align category_theory.monoidal_of_has_finite_coproducts.left_unitor_hom CategoryTheory.monoidalOfHasFiniteCoproducts.leftUnitor_hom
-/

#print CategoryTheory.monoidalOfHasFiniteCoproducts.rightUnitor_hom /-
@[simp]
theorem rightUnitor_hom (X : C) : (ρ_ X).Hom = coprod.desc (𝟙 _) (initial.to X) :=
  rfl
#align category_theory.monoidal_of_has_finite_coproducts.right_unitor_hom CategoryTheory.monoidalOfHasFiniteCoproducts.rightUnitor_hom
-/

#print CategoryTheory.monoidalOfHasFiniteCoproducts.leftUnitor_inv /-
@[simp]
theorem leftUnitor_inv (X : C) : (λ_ X).inv = Limits.coprod.inr :=
  rfl
#align category_theory.monoidal_of_has_finite_coproducts.left_unitor_inv CategoryTheory.monoidalOfHasFiniteCoproducts.leftUnitor_inv
-/

#print CategoryTheory.monoidalOfHasFiniteCoproducts.rightUnitor_inv /-
@[simp]
theorem rightUnitor_inv (X : C) : (ρ_ X).inv = Limits.coprod.inl :=
  rfl
#align category_theory.monoidal_of_has_finite_coproducts.right_unitor_inv CategoryTheory.monoidalOfHasFiniteCoproducts.rightUnitor_inv
-/

#print CategoryTheory.monoidalOfHasFiniteCoproducts.associator_hom /-
-- We don't mark this as a simp lemma, even though in many particular
-- categories the right hand side will simplify significantly further.
-- For now, we'll plan to create specialised simp lemmas in each particular category.
theorem associator_hom (X Y Z : C) :
    (α_ X Y Z).Hom =
      coprod.desc (coprod.desc coprod.inl (coprod.inl ≫ coprod.inr)) (coprod.inr ≫ coprod.inr) :=
  rfl
#align category_theory.monoidal_of_has_finite_coproducts.associator_hom CategoryTheory.monoidalOfHasFiniteCoproducts.associator_hom
-/

end MonoidalOfHasFiniteCoproducts

end CategoryTheory

