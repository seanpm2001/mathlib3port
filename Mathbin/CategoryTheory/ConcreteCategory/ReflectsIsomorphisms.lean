/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.concrete_category.reflects_isomorphisms
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.ConcreteCategory.Basic
import Mathbin.CategoryTheory.Functor.ReflectsIsomorphisms

/-!
> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A `forget₂ C D` forgetful functor between concrete categories `C` and `D`
whose forgetful functors both reflect isomorphisms, itself reflects isomorphisms.
-/


universe u

namespace CategoryTheory

instance : ReflectsIsomorphisms (forget (Type u)) where reflects X Y f i := i

variable (C : Type (u + 1)) [Category C] [ConcreteCategory.{u} C]

variable (D : Type (u + 1)) [Category D] [ConcreteCategory.{u} D]

#print CategoryTheory.reflectsIsomorphisms_forget₂ /-
-- This should not be an instance, as it causes a typeclass loop
-- with `category_theory.has_forget_to_Type`
/-- A `forget₂ C D` forgetful functor between concrete categories `C` and `D`
where `forget C` reflects isomorphisms, itself reflects isomorphisms.
-/
theorem reflectsIsomorphisms_forget₂ [HasForget₂ C D] [ReflectsIsomorphisms (forget C)] :
    ReflectsIsomorphisms (forget₂ C D) :=
  {
    reflects := fun X Y f i => by
      skip
      haveI i' : is_iso ((forget D).map ((forget₂ C D).map f)) := functor.map_is_iso (forget D) _
      haveI : is_iso ((forget C).map f) :=
        by
        have := has_forget₂.forget_comp
        dsimp at this 
        rw [← this]
        exact i'
      apply is_iso_of_reflects_iso f (forget C) }
#align category_theory.reflects_isomorphisms_forget₂ CategoryTheory.reflectsIsomorphisms_forget₂
-/

end CategoryTheory

