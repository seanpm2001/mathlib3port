/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.subobject.well_powered
! leanprover-community/mathlib commit ce38d86c0b2d427ce208c3cee3159cb421d2b3c4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Subobject.Basic
import Mathbin.CategoryTheory.EssentiallySmall

/-!
# Well-powered categories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A category `(C : Type u) [category.{v} C]` is `[well_powered C]` if
for every `X : C`, we have `small.{v} (subobject X)`.

(Note that in this situtation `subobject X : Type (max u v)`,
so this is a nontrivial condition for large categories,
but automatic for small categories.)

This is equivalent to the category `mono_over X` being `essentially_small.{v}` for all `X : C`.

When a category is well-powered, you can obtain nonconstructive witnesses as
`shrink (subobject X) : Type v`
and
`equiv_shrink (subobject X) : subobject X ≃ shrink (subobject X)`.
-/


universe v u₁ u₂

namespace CategoryTheory

variable (C : Type u₁) [Category.{v} C]

#print CategoryTheory.WellPowered /-
/--
A category (with morphisms in `Type v`) is well-powered if `subobject X` is `v`-small for every `X`.

We show in `well_powered_of_mono_over_essentially_small` and `mono_over_essentially_small`
that this is the case if and only if `mono_over X` is `v`-essentially small for every `X`.
-/
class WellPowered : Prop where
  subobject_small : ∀ X : C, Small.{v} (Subobject X) := by infer_instance
#align category_theory.well_powered CategoryTheory.WellPowered
-/

#print CategoryTheory.small_subobject /-
instance small_subobject [WellPowered C] (X : C) : Small.{v} (Subobject X) :=
  WellPowered.subobject_small X
#align category_theory.small_subobject CategoryTheory.small_subobject
-/

#print CategoryTheory.wellPowered_of_smallCategory /-
instance (priority := 100) wellPowered_of_smallCategory (C : Type u₁) [SmallCategory C] :
    WellPowered C where
#align category_theory.well_powered_of_small_category CategoryTheory.wellPowered_of_smallCategory
-/

variable {C}

#print CategoryTheory.essentiallySmall_monoOver_iff_small_subobject /-
theorem essentiallySmall_monoOver_iff_small_subobject (X : C) :
    EssentiallySmall.{v} (MonoOver X) ↔ Small.{v} (Subobject X) :=
  essentiallySmall_iff_of_thin
#align category_theory.essentially_small_mono_over_iff_small_subobject CategoryTheory.essentiallySmall_monoOver_iff_small_subobject
-/

#print CategoryTheory.wellPowered_of_essentiallySmall_monoOver /-
theorem wellPowered_of_essentiallySmall_monoOver (h : ∀ X : C, EssentiallySmall.{v} (MonoOver X)) :
    WellPowered C :=
  { subobject_small := fun X => (essentiallySmall_monoOver_iff_small_subobject X).mp (h X) }
#align category_theory.well_powered_of_essentially_small_mono_over CategoryTheory.wellPowered_of_essentiallySmall_monoOver
-/

section

variable [WellPowered C]

#print CategoryTheory.essentiallySmall_monoOver /-
instance essentiallySmall_monoOver (X : C) : EssentiallySmall.{v} (MonoOver X) :=
  (essentiallySmall_monoOver_iff_small_subobject X).mpr (WellPowered.subobject_small X)
#align category_theory.essentially_small_mono_over CategoryTheory.essentiallySmall_monoOver
-/

end

section Equivalence

variable {D : Type u₂} [Category.{v} D]

#print CategoryTheory.wellPowered_of_equiv /-
theorem wellPowered_of_equiv (e : C ≌ D) [WellPowered C] : WellPowered D :=
  wellPowered_of_essentiallySmall_monoOver fun X =>
    (essentiallySmall_congr (MonoOver.congr X e.symm)).2 <| by infer_instance
#align category_theory.well_powered_of_equiv CategoryTheory.wellPowered_of_equiv
-/

#print CategoryTheory.wellPowered_congr /-
/-- Being well-powered is preserved by equivalences, as long as the two categories involved have
    their morphisms in the same universe. -/
theorem wellPowered_congr (e : C ≌ D) : WellPowered C ↔ WellPowered D :=
  ⟨fun i => well_powered_of_equiv e, fun i => well_powered_of_equiv e.symm⟩
#align category_theory.well_powered_congr CategoryTheory.wellPowered_congr
-/

end Equivalence

end CategoryTheory

