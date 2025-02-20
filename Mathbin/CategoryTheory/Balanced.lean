/-
Copyright (c) 2022 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module category_theory.balanced
! leanprover-community/mathlib commit e97cf15cd1aec9bd5c193b2ffac5a6dc9118912b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.EpiMono

/-!
# Balanced categories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A category is called balanced if any morphism that is both monic and epic is an isomorphism.

Balanced categories arise frequently. For example, categories in which every monomorphism
(or epimorphism) is strong are balanced. Examples of this are abelian categories and toposes, such
as the category of types.

-/


universe v u

namespace CategoryTheory

variable {C : Type u} [Category.{v} C]

section

variable (C)

#print CategoryTheory.Balanced /-
/-- A category is called balanced if any morphism that is both monic and epic is an isomorphism. -/
class Balanced : Prop where
  isIso_of_mono_of_epi : ∀ {X Y : C} (f : X ⟶ Y) [Mono f] [Epi f], IsIso f
#align category_theory.balanced CategoryTheory.Balanced
-/

end

#print CategoryTheory.isIso_of_mono_of_epi /-
theorem isIso_of_mono_of_epi [Balanced C] {X Y : C} (f : X ⟶ Y) [Mono f] [Epi f] : IsIso f :=
  Balanced.isIso_of_mono_of_epi _
#align category_theory.is_iso_of_mono_of_epi CategoryTheory.isIso_of_mono_of_epi
-/

#print CategoryTheory.isIso_iff_mono_and_epi /-
theorem isIso_iff_mono_and_epi [Balanced C] {X Y : C} (f : X ⟶ Y) : IsIso f ↔ Mono f ∧ Epi f :=
  ⟨fun _ => ⟨inferInstance, inferInstance⟩, fun ⟨_, _⟩ => is_iso_of_mono_of_epi _⟩
#align category_theory.is_iso_iff_mono_and_epi CategoryTheory.isIso_iff_mono_and_epi
-/

section

attribute [local instance] is_iso_of_mono_of_epi

#print CategoryTheory.balanced_opposite /-
theorem balanced_opposite [Balanced C] : Balanced Cᵒᵖ :=
  {
    isIso_of_mono_of_epi := fun X Y f fmono fepi => by rw [← Quiver.Hom.op_unop f];
      exact is_iso_of_op _ }
#align category_theory.balanced_opposite CategoryTheory.balanced_opposite
-/

end

end CategoryTheory

