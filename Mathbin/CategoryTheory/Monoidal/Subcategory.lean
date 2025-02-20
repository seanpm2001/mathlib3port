/-
Copyright (c) 2022 Antoine Labelle. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antoine Labelle

! This file was ported from Lean 3 source module category_theory.monoidal.subcategory
! leanprover-community/mathlib commit 7e5137f579de09a059a5ce98f364a04e221aabf0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Monoidal.Braided
import Mathbin.CategoryTheory.Monoidal.Linear
import Mathbin.CategoryTheory.Preadditive.AdditiveFunctor
import Mathbin.CategoryTheory.Linear.LinearFunctor
import Mathbin.CategoryTheory.Closed.Monoidal

/-!
# Full monoidal subcategories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given a monidal category `C` and a monoidal predicate on `C`, that is a function `P : C → Prop`
closed under `𝟙_` and `⊗`, we can put a monoidal structure on `{X : C // P X}` (the category
structure is defined in `category_theory.full_subcategory`).

When `C` is also braided/symmetric, the full monoidal subcategory also inherits the
braided/symmetric structure.

## TODO
* Add monoidal/braided versions of `category_theory.full_subcategory.lift`
-/


universe u v

namespace CategoryTheory

namespace MonoidalCategory

open Iso

variable {C : Type u} [Category.{v} C] [MonoidalCategory C] (P : C → Prop)

#print CategoryTheory.MonoidalCategory.MonoidalPredicate /-
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- A property `C → Prop` is a monoidal predicate if it is closed under `𝟙_` and `⊗`.
-/
class MonoidalPredicate : Prop where
  prop_id' : P (𝟙_ C) := by obviously
  prop_tensor' : ∀ {X Y}, P X → P Y → P (X ⊗ Y) := by obviously
#align category_theory.monoidal_category.monoidal_predicate CategoryTheory.MonoidalCategory.MonoidalPredicate
-/

restate_axiom monoidal_predicate.prop_id'

restate_axiom monoidal_predicate.prop_tensor'

open MonoidalPredicate

variable [MonoidalPredicate P]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.MonoidalCategory.fullMonoidalSubcategory /-
/--
When `P` is a monoidal predicate, the full subcategory for `P` inherits the monoidal structure of
  `C`.
-/
instance fullMonoidalSubcategory : MonoidalCategory (FullSubcategory P)
    where
  tensorObj X Y := ⟨X.1 ⊗ Y.1, prop_tensor X.2 Y.2⟩
  tensorHom X₁ Y₁ X₂ Y₂ f g := by
    change X₁.1 ⊗ X₂.1 ⟶ Y₁.1 ⊗ Y₂.1
    change X₁.1 ⟶ Y₁.1 at f ; change X₂.1 ⟶ Y₂.1 at g ; exact f ⊗ g
  tensorUnit := ⟨𝟙_ C, prop_id⟩
  associator X Y Z :=
    ⟨(α_ X.1 Y.1 Z.1).Hom, (α_ X.1 Y.1 Z.1).inv, hom_inv_id (α_ X.1 Y.1 Z.1),
      inv_hom_id (α_ X.1 Y.1 Z.1)⟩
  leftUnitor X := ⟨(λ_ X.1).Hom, (λ_ X.1).inv, hom_inv_id (λ_ X.1), inv_hom_id (λ_ X.1)⟩
  rightUnitor X := ⟨(ρ_ X.1).Hom, (ρ_ X.1).inv, hom_inv_id (ρ_ X.1), inv_hom_id (ρ_ X.1)⟩
  tensor_id' X Y := tensor_id X.1 Y.1
  tensor_comp' X₁ Y₁ Z₁ X₂ Y₂ Z₂ f₁ f₂ g₁ g₂ := tensor_comp f₁ f₂ g₁ g₂
  associator_naturality' X₁ X₂ X₃ Y₁ Y₂ Y₃ f₁ f₂ f₃ := associator_naturality f₁ f₂ f₃
  leftUnitor_naturality' X Y f := leftUnitor_naturality f
  rightUnitor_naturality' X Y f := rightUnitor_naturality f
  pentagon' W X Y Z := pentagon W.1 X.1 Y.1 Z.1
  triangle' X Y := triangle X.1 Y.1
#align category_theory.monoidal_category.full_monoidal_subcategory CategoryTheory.MonoidalCategory.fullMonoidalSubcategory
-/

#print CategoryTheory.MonoidalCategory.fullMonoidalSubcategoryInclusion /-
/-- The forgetful monoidal functor from a full monoidal subcategory into the original category
("forgetting" the condition).
-/
@[simps]
def fullMonoidalSubcategoryInclusion : MonoidalFunctor (FullSubcategory P) C
    where
  toFunctor := fullSubcategoryInclusion P
  ε := 𝟙 _
  μ X Y := 𝟙 _
#align category_theory.monoidal_category.full_monoidal_subcategory_inclusion CategoryTheory.MonoidalCategory.fullMonoidalSubcategoryInclusion
-/

#print CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.full /-
instance fullMonoidalSubcategory.full : Full (fullMonoidalSubcategoryInclusion P).toFunctor :=
  FullSubcategory.full P
#align category_theory.monoidal_category.full_monoidal_subcategory.full CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.full
-/

#print CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.faithful /-
instance fullMonoidalSubcategory.faithful :
    Faithful (fullMonoidalSubcategoryInclusion P).toFunctor :=
  FullSubcategory.faithful P
#align category_theory.monoidal_category.full_monoidal_subcategory.faithful CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.faithful
-/

section

variable [Preadditive C]

#print CategoryTheory.MonoidalCategory.fullMonoidalSubcategoryInclusion_additive /-
instance fullMonoidalSubcategoryInclusion_additive :
    (fullMonoidalSubcategoryInclusion P).toFunctor.Additive :=
  Functor.fullSubcategoryInclusion_additive _
#align category_theory.monoidal_category.full_monoidal_subcategory_inclusion_additive CategoryTheory.MonoidalCategory.fullMonoidalSubcategoryInclusion_additive
-/

instance [MonoidalPreadditive C] : MonoidalPreadditive (FullSubcategory P) :=
  monoidalPreadditive_of_faithful (fullMonoidalSubcategoryInclusion P)

variable (R : Type _) [Ring R] [Linear R C]

#print CategoryTheory.MonoidalCategory.fullMonoidalSubcategoryInclusion_linear /-
instance fullMonoidalSubcategoryInclusion_linear :
    (fullMonoidalSubcategoryInclusion P).toFunctor.Linear R :=
  Functor.fullSubcategoryInclusionLinear R _
#align category_theory.monoidal_category.full_monoidal_subcategory_inclusion_linear CategoryTheory.MonoidalCategory.fullMonoidalSubcategoryInclusion_linear
-/

instance [MonoidalPreadditive C] [MonoidalLinear R C] : MonoidalLinear R (FullSubcategory P) :=
  monoidalLinearOfFaithful R (fullMonoidalSubcategoryInclusion P)

end

variable {P} {P' : C → Prop} [MonoidalPredicate P']

#print CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.map /-
/-- An implication of predicates `P → P'` induces a monoidal functor between full monoidal
subcategories. -/
@[simps]
def fullMonoidalSubcategory.map (h : ∀ ⦃X⦄, P X → P' X) :
    MonoidalFunctor (FullSubcategory P) (FullSubcategory P')
    where
  toFunctor := FullSubcategory.map h
  ε := 𝟙 _
  μ X Y := 𝟙 _
#align category_theory.monoidal_category.full_monoidal_subcategory.map CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.map
-/

#print CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.mapFull /-
instance fullMonoidalSubcategory.mapFull (h : ∀ ⦃X⦄, P X → P' X) :
    Full (fullMonoidalSubcategory.map h).toFunctor where preimage X Y f := f
#align category_theory.monoidal_category.full_monoidal_subcategory.map_full CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.mapFull
-/

#print CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.map_faithful /-
instance fullMonoidalSubcategory.map_faithful (h : ∀ ⦃X⦄, P X → P' X) :
    Faithful (fullMonoidalSubcategory.map h).toFunctor where
#align category_theory.monoidal_category.full_monoidal_subcategory.map_faithful CategoryTheory.MonoidalCategory.fullMonoidalSubcategory.map_faithful
-/

section Braided

variable (P) [BraidedCategory C]

#print CategoryTheory.MonoidalCategory.fullBraidedSubcategory /-
/-- The braided structure on a full subcategory inherited by the braided structure on `C`.
-/
instance fullBraidedSubcategory : BraidedCategory (FullSubcategory P) :=
  braidedCategoryOfFaithful (fullMonoidalSubcategoryInclusion P)
    (fun X Y =>
      ⟨(β_ X.1 Y.1).Hom, (β_ X.1 Y.1).inv, (β_ X.1 Y.1).hom_inv_id, (β_ X.1 Y.1).inv_hom_id⟩)
    fun X Y => by tidy
#align category_theory.monoidal_category.full_braided_subcategory CategoryTheory.MonoidalCategory.fullBraidedSubcategory
-/

#print CategoryTheory.MonoidalCategory.fullBraidedSubcategoryInclusion /-
/-- The forgetful braided functor from a full braided subcategory into the original category
("forgetting" the condition).
-/
@[simps]
def fullBraidedSubcategoryInclusion : BraidedFunctor (FullSubcategory P) C
    where
  toMonoidalFunctor := fullMonoidalSubcategoryInclusion P
  braided' X Y := by rw [is_iso.eq_inv_comp]; tidy
#align category_theory.monoidal_category.full_braided_subcategory_inclusion CategoryTheory.MonoidalCategory.fullBraidedSubcategoryInclusion
-/

#print CategoryTheory.MonoidalCategory.fullBraidedSubcategory.full /-
instance fullBraidedSubcategory.full : Full (fullBraidedSubcategoryInclusion P).toFunctor :=
  fullMonoidalSubcategory.full P
#align category_theory.monoidal_category.full_braided_subcategory.full CategoryTheory.MonoidalCategory.fullBraidedSubcategory.full
-/

#print CategoryTheory.MonoidalCategory.fullBraidedSubcategory.faithful /-
instance fullBraidedSubcategory.faithful : Faithful (fullBraidedSubcategoryInclusion P).toFunctor :=
  fullMonoidalSubcategory.faithful P
#align category_theory.monoidal_category.full_braided_subcategory.faithful CategoryTheory.MonoidalCategory.fullBraidedSubcategory.faithful
-/

variable {P}

#print CategoryTheory.MonoidalCategory.fullBraidedSubcategory.map /-
/-- An implication of predicates `P → P'` induces a braided functor between full braided
subcategories. -/
@[simps]
def fullBraidedSubcategory.map (h : ∀ ⦃X⦄, P X → P' X) :
    BraidedFunctor (FullSubcategory P) (FullSubcategory P')
    where
  toMonoidalFunctor := fullMonoidalSubcategory.map h
  braided' X Y := by rw [is_iso.eq_inv_comp]; tidy
#align category_theory.monoidal_category.full_braided_subcategory.map CategoryTheory.MonoidalCategory.fullBraidedSubcategory.map
-/

#print CategoryTheory.MonoidalCategory.fullBraidedSubcategory.mapFull /-
instance fullBraidedSubcategory.mapFull (h : ∀ ⦃X⦄, P X → P' X) :
    Full (fullBraidedSubcategory.map h).toFunctor :=
  fullMonoidalSubcategory.mapFull h
#align category_theory.monoidal_category.full_braided_subcategory.map_full CategoryTheory.MonoidalCategory.fullBraidedSubcategory.mapFull
-/

#print CategoryTheory.MonoidalCategory.fullBraidedSubcategory.map_faithful /-
instance fullBraidedSubcategory.map_faithful (h : ∀ ⦃X⦄, P X → P' X) :
    Faithful (fullBraidedSubcategory.map h).toFunctor :=
  fullMonoidalSubcategory.map_faithful h
#align category_theory.monoidal_category.full_braided_subcategory.map_faithful CategoryTheory.MonoidalCategory.fullBraidedSubcategory.map_faithful
-/

end Braided

section Symmetric

variable (P) [SymmetricCategory C]

#print CategoryTheory.MonoidalCategory.fullSymmetricSubcategory /-
instance fullSymmetricSubcategory : SymmetricCategory (FullSubcategory P) :=
  symmetricCategoryOfFaithful (fullBraidedSubcategoryInclusion P)
#align category_theory.monoidal_category.full_symmetric_subcategory CategoryTheory.MonoidalCategory.fullSymmetricSubcategory
-/

end Symmetric

section Closed

variable (P) [MonoidalClosed C]

#print CategoryTheory.MonoidalCategory.ClosedPredicate /-
/-- A property `C → Prop` is a closed predicate if it is closed under taking internal homs
-/
class ClosedPredicate : Prop where
  prop_ihom' : ∀ {X Y}, P X → P Y → P ((ihom X).obj Y) := by obviously
#align category_theory.monoidal_category.closed_predicate CategoryTheory.MonoidalCategory.ClosedPredicate
-/

restate_axiom closed_predicate.prop_ihom'

open ClosedPredicate

variable [ClosedPredicate P]

#print CategoryTheory.MonoidalCategory.fullMonoidalClosedSubcategory /-
instance fullMonoidalClosedSubcategory : MonoidalClosed (FullSubcategory P)
    where closed' X :=
    {
      isAdj :=
        { right :=
            FullSubcategory.lift P (fullSubcategoryInclusion P ⋙ ihom X.1) fun Y => propIhom X.2 Y.2
          adj :=
            Adjunction.mkOfUnitCounit
              { Unit :=
                  { app := fun Y => (ihom.coev X.1).app Y.1
                    naturality' := fun Y Z f => ihom.coev_naturality X.1 f }
                counit :=
                  { app := fun Y => (ihom.ev X.1).app Y.1
                    naturality' := fun Y Z f => ihom.ev_naturality X.1 f }
                left_triangle := by ext Y; simp; exact ihom.ev_coev X.1 Y.1
                right_triangle := by ext Y; simp; exact ihom.coev_ev X.1 Y.1 } } }
#align category_theory.monoidal_category.full_monoidal_closed_subcategory CategoryTheory.MonoidalCategory.fullMonoidalClosedSubcategory
-/

#print CategoryTheory.MonoidalCategory.fullMonoidalClosedSubcategory_ihom_obj /-
@[simp]
theorem fullMonoidalClosedSubcategory_ihom_obj (X Y : FullSubcategory P) :
    ((ihom X).obj Y).obj = (ihom X.obj).obj Y.obj :=
  rfl
#align category_theory.monoidal_category.full_monoidal_closed_subcategory_ihom_obj CategoryTheory.MonoidalCategory.fullMonoidalClosedSubcategory_ihom_obj
-/

#print CategoryTheory.MonoidalCategory.fullMonoidalClosedSubcategory_ihom_map /-
@[simp]
theorem fullMonoidalClosedSubcategory_ihom_map (X : FullSubcategory P) {Y Z : FullSubcategory P}
    (f : Y ⟶ Z) : (ihom X).map f = (ihom X.obj).map f :=
  rfl
#align category_theory.monoidal_category.full_monoidal_closed_subcategory_ihom_map CategoryTheory.MonoidalCategory.fullMonoidalClosedSubcategory_ihom_map
-/

end Closed

end MonoidalCategory

end CategoryTheory

