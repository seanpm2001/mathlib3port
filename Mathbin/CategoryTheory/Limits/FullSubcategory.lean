/-
Copyright (c) 2022 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module category_theory.limits.full_subcategory
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Creates

/-!
# Limits in full subcategories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We introduce the notion of a property closed under taking limits and show that if `P` is closed
under taking limits, then limits in `full_subcategory P` can be constructed from limits in `C`.
More precisely, the inclusion creates such limits.

-/


noncomputable section

universe w' w v u

open CategoryTheory

namespace CategoryTheory.Limits

#print CategoryTheory.Limits.ClosedUnderLimitsOfShape /-
/-- We say that a property is closed under limits of shape `J` if whenever all objects in a
    `J`-shaped diagram have the property, any limit of this diagram also has the property. -/
def ClosedUnderLimitsOfShape {C : Type u} [Category.{v} C] (J : Type w) [Category.{w'} J]
    (P : C → Prop) : Prop :=
  ∀ ⦃F : J ⥤ C⦄ ⦃c : Cone F⦄ (hc : IsLimit c), (∀ j, P (F.obj j)) → P c.pt
#align category_theory.limits.closed_under_limits_of_shape CategoryTheory.Limits.ClosedUnderLimitsOfShape
-/

#print CategoryTheory.Limits.ClosedUnderColimitsOfShape /-
/-- We say that a property is closed under colimits of shape `J` if whenever all objects in a
    `J`-shaped diagram have the property, any colimit of this diagram also has the property. -/
def ClosedUnderColimitsOfShape {C : Type u} [Category.{v} C] (J : Type w) [Category.{w'} J]
    (P : C → Prop) : Prop :=
  ∀ ⦃F : J ⥤ C⦄ ⦃c : Cocone F⦄ (hc : IsColimit c), (∀ j, P (F.obj j)) → P c.pt
#align category_theory.limits.closed_under_colimits_of_shape CategoryTheory.Limits.ClosedUnderColimitsOfShape
-/

section

variable {C : Type u} [Category.{v} C] {J : Type w} [Category.{w'} J] {P : C → Prop}

#print CategoryTheory.Limits.ClosedUnderLimitsOfShape.limit /-
theorem ClosedUnderLimitsOfShape.limit (h : ClosedUnderLimitsOfShape J P) {F : J ⥤ C} [HasLimit F] :
    (∀ j, P (F.obj j)) → P (limit F) :=
  h (limit.isLimit _)
#align category_theory.limits.closed_under_limits_of_shape.limit CategoryTheory.Limits.ClosedUnderLimitsOfShape.limit
-/

#print CategoryTheory.Limits.ClosedUnderColimitsOfShape.colimit /-
theorem ClosedUnderColimitsOfShape.colimit (h : ClosedUnderColimitsOfShape J P) {F : J ⥤ C}
    [HasColimit F] : (∀ j, P (F.obj j)) → P (colimit F) :=
  h (colimit.isColimit _)
#align category_theory.limits.closed_under_colimits_of_shape.colimit CategoryTheory.Limits.ClosedUnderColimitsOfShape.colimit
-/

end

section

variable {J : Type w} [Category.{w'} J] {C : Type u} [Category.{v} C] {P : C → Prop}

#print CategoryTheory.Limits.createsLimitFullSubcategoryInclusion' /-
/-- If a `J`-shaped diagram in `full_subcategory P` has a limit cone in `C` whose cone point lives
    in the full subcategory, then this defines a limit in the full subcategory. -/
def createsLimitFullSubcategoryInclusion' (F : J ⥤ FullSubcategory P)
    {c : Cone (F ⋙ fullSubcategoryInclusion P)} (hc : IsLimit c) (h : P c.pt) :
    CreatesLimit F (fullSubcategoryInclusion P) :=
  createsLimitOfFullyFaithfulOfIso' hc ⟨_, h⟩ (Iso.refl _)
#align category_theory.limits.creates_limit_full_subcategory_inclusion' CategoryTheory.Limits.createsLimitFullSubcategoryInclusion'
-/

#print CategoryTheory.Limits.createsLimitFullSubcategoryInclusion /-
/-- If a `J`-shaped diagram in `full_subcategory P` has a limit in `C` whose cone point lives in the
    full subcategory, then this defines a limit in the full subcategory. -/
def createsLimitFullSubcategoryInclusion (F : J ⥤ FullSubcategory P)
    [HasLimit (F ⋙ fullSubcategoryInclusion P)] (h : P (limit (F ⋙ fullSubcategoryInclusion P))) :
    CreatesLimit F (fullSubcategoryInclusion P) :=
  createsLimitFullSubcategoryInclusion' F (limit.isLimit _) h
#align category_theory.limits.creates_limit_full_subcategory_inclusion CategoryTheory.Limits.createsLimitFullSubcategoryInclusion
-/

#print CategoryTheory.Limits.createsColimitFullSubcategoryInclusion' /-
/-- If a `J`-shaped diagram in `full_subcategory P` has a colimit cocone in `C` whose cocone point
    lives in the full subcategory, then this defines a colimit in the full subcategory. -/
def createsColimitFullSubcategoryInclusion' (F : J ⥤ FullSubcategory P)
    {c : Cocone (F ⋙ fullSubcategoryInclusion P)} (hc : IsColimit c) (h : P c.pt) :
    CreatesColimit F (fullSubcategoryInclusion P) :=
  createsColimitOfFullyFaithfulOfIso' hc ⟨_, h⟩ (Iso.refl _)
#align category_theory.limits.creates_colimit_full_subcategory_inclusion' CategoryTheory.Limits.createsColimitFullSubcategoryInclusion'
-/

#print CategoryTheory.Limits.createsColimitFullSubcategoryInclusion /-
/-- If a `J`-shaped diagram in `full_subcategory P` has a colimit in `C` whose cocone point lives in
    the full subcategory, then this defines a colimit in the full subcategory. -/
def createsColimitFullSubcategoryInclusion (F : J ⥤ FullSubcategory P)
    [HasColimit (F ⋙ fullSubcategoryInclusion P)]
    (h : P (colimit (F ⋙ fullSubcategoryInclusion P))) :
    CreatesColimit F (fullSubcategoryInclusion P) :=
  createsColimitFullSubcategoryInclusion' F (colimit.isColimit _) h
#align category_theory.limits.creates_colimit_full_subcategory_inclusion CategoryTheory.Limits.createsColimitFullSubcategoryInclusion
-/

#print CategoryTheory.Limits.createsLimitFullSubcategoryInclusionOfClosed /-
/-- If `P` is closed under limits of shape `J`, then the inclusion creates such limits. -/
def createsLimitFullSubcategoryInclusionOfClosed (h : ClosedUnderLimitsOfShape J P)
    (F : J ⥤ FullSubcategory P) [HasLimit (F ⋙ fullSubcategoryInclusion P)] :
    CreatesLimit F (fullSubcategoryInclusion P) :=
  createsLimitFullSubcategoryInclusion F (h.limit fun j => (F.obj j).property)
#align category_theory.limits.creates_limit_full_subcategory_inclusion_of_closed CategoryTheory.Limits.createsLimitFullSubcategoryInclusionOfClosed
-/

#print CategoryTheory.Limits.createsLimitsOfShapeFullSubcategoryInclusion /-
/-- If `P` is closed under limits of shape `J`, then the inclusion creates such limits. -/
def createsLimitsOfShapeFullSubcategoryInclusion (h : ClosedUnderLimitsOfShape J P)
    [HasLimitsOfShape J C] : CreatesLimitsOfShape J (fullSubcategoryInclusion P)
    where CreatesLimit F := createsLimitFullSubcategoryInclusionOfClosed h F
#align category_theory.limits.creates_limits_of_shape_full_subcategory_inclusion CategoryTheory.Limits.createsLimitsOfShapeFullSubcategoryInclusion
-/

#print CategoryTheory.Limits.hasLimit_of_closed_under_limits /-
theorem hasLimit_of_closed_under_limits (h : ClosedUnderLimitsOfShape J P)
    (F : J ⥤ FullSubcategory P) [HasLimit (F ⋙ fullSubcategoryInclusion P)] : HasLimit F :=
  have : CreatesLimit F (fullSubcategoryInclusion P) :=
    createsLimitFullSubcategoryInclusionOfClosed h F
  has_limit_of_created F (full_subcategory_inclusion P)
#align category_theory.limits.has_limit_of_closed_under_limits CategoryTheory.Limits.hasLimit_of_closed_under_limits
-/

#print CategoryTheory.Limits.hasLimitsOfShape_of_closed_under_limits /-
theorem hasLimitsOfShape_of_closed_under_limits (h : ClosedUnderLimitsOfShape J P)
    [HasLimitsOfShape J C] : HasLimitsOfShape J (FullSubcategory P) :=
  { HasLimit := fun F => hasLimit_of_closed_under_limits h F }
#align category_theory.limits.has_limits_of_shape_of_closed_under_limits CategoryTheory.Limits.hasLimitsOfShape_of_closed_under_limits
-/

#print CategoryTheory.Limits.createsColimitFullSubcategoryInclusionOfClosed /-
/-- If `P` is closed under colimits of shape `J`, then the inclusion creates such colimits. -/
def createsColimitFullSubcategoryInclusionOfClosed (h : ClosedUnderColimitsOfShape J P)
    (F : J ⥤ FullSubcategory P) [HasColimit (F ⋙ fullSubcategoryInclusion P)] :
    CreatesColimit F (fullSubcategoryInclusion P) :=
  createsColimitFullSubcategoryInclusion F (h.colimit fun j => (F.obj j).property)
#align category_theory.limits.creates_colimit_full_subcategory_inclusion_of_closed CategoryTheory.Limits.createsColimitFullSubcategoryInclusionOfClosed
-/

#print CategoryTheory.Limits.createsColimitsOfShapeFullSubcategoryInclusion /-
/-- If `P` is closed under colimits of shape `J`, then the inclusion creates such colimits. -/
def createsColimitsOfShapeFullSubcategoryInclusion (h : ClosedUnderColimitsOfShape J P)
    [HasColimitsOfShape J C] : CreatesColimitsOfShape J (fullSubcategoryInclusion P)
    where CreatesColimit F := createsColimitFullSubcategoryInclusionOfClosed h F
#align category_theory.limits.creates_colimits_of_shape_full_subcategory_inclusion CategoryTheory.Limits.createsColimitsOfShapeFullSubcategoryInclusion
-/

#print CategoryTheory.Limits.hasColimit_of_closed_under_colimits /-
theorem hasColimit_of_closed_under_colimits (h : ClosedUnderColimitsOfShape J P)
    (F : J ⥤ FullSubcategory P) [HasColimit (F ⋙ fullSubcategoryInclusion P)] : HasColimit F :=
  have : CreatesColimit F (fullSubcategoryInclusion P) :=
    createsColimitFullSubcategoryInclusionOfClosed h F
  has_colimit_of_created F (full_subcategory_inclusion P)
#align category_theory.limits.has_colimit_of_closed_under_colimits CategoryTheory.Limits.hasColimit_of_closed_under_colimits
-/

#print CategoryTheory.Limits.hasColimitsOfShape_of_closed_under_colimits /-
theorem hasColimitsOfShape_of_closed_under_colimits (h : ClosedUnderColimitsOfShape J P)
    [HasColimitsOfShape J C] : HasColimitsOfShape J (FullSubcategory P) :=
  { HasColimit := fun F => hasColimit_of_closed_under_colimits h F }
#align category_theory.limits.has_colimits_of_shape_of_closed_under_colimits CategoryTheory.Limits.hasColimitsOfShape_of_closed_under_colimits
-/

end

end CategoryTheory.Limits

