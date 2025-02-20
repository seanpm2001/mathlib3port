/-
Copyright (c) 2022 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module category_theory.limits.essentially_small
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.Products
import Mathbin.CategoryTheory.EssentiallySmall

/-!
# Limits over essentially small indexing categories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

If `C` has limits of size `w` and `J` is `w`-essentially small, then `C` has limits of shape `J`.

-/


universe w₁ w₂ v₁ v₂ u₁ u₂

noncomputable section

open CategoryTheory

namespace CategoryTheory.Limits

variable (J : Type u₂) [Category.{v₂} J] (C : Type u₁) [Category.{v₁} C]

#print CategoryTheory.Limits.hasLimitsOfShape_of_essentiallySmall /-
theorem hasLimitsOfShape_of_essentiallySmall [EssentiallySmall.{w₁} J]
    [HasLimitsOfSize.{w₁, w₁} C] : HasLimitsOfShape J C :=
  hasLimitsOfShape_of_equivalence <| Equivalence.symm <| equivSmallModel.{w₁} J
#align category_theory.limits.has_limits_of_shape_of_essentially_small CategoryTheory.Limits.hasLimitsOfShape_of_essentiallySmall
-/

#print CategoryTheory.Limits.hasColimitsOfShape_of_essentiallySmall /-
theorem hasColimitsOfShape_of_essentiallySmall [EssentiallySmall.{w₁} J]
    [HasColimitsOfSize.{w₁, w₁} C] : HasColimitsOfShape J C :=
  hasColimitsOfShape_of_equivalence <| Equivalence.symm <| equivSmallModel.{w₁} J
#align category_theory.limits.has_colimits_of_shape_of_essentially_small CategoryTheory.Limits.hasColimitsOfShape_of_essentiallySmall
-/

#print CategoryTheory.Limits.hasProductsOfShape_of_small /-
theorem hasProductsOfShape_of_small (β : Type w₂) [Small.{w₁} β] [HasProducts.{w₁} C] :
    HasProductsOfShape β C :=
  hasLimitsOfShape_of_equivalence <| Discrete.equivalence <| Equiv.symm <| equivShrink β
#align category_theory.limits.has_products_of_shape_of_small CategoryTheory.Limits.hasProductsOfShape_of_small
-/

#print CategoryTheory.Limits.hasCoproductsOfShape_of_small /-
theorem hasCoproductsOfShape_of_small (β : Type w₂) [Small.{w₁} β] [HasCoproducts.{w₁} C] :
    HasCoproductsOfShape β C :=
  hasColimitsOfShape_of_equivalence <| Discrete.equivalence <| Equiv.symm <| equivShrink β
#align category_theory.limits.has_coproducts_of_shape_of_small CategoryTheory.Limits.hasCoproductsOfShape_of_small
-/

end CategoryTheory.Limits

