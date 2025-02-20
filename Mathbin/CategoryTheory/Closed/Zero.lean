/-
Copyright (c) 2020 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta

! This file was ported from Lean 3 source module category_theory.closed.zero
! leanprover-community/mathlib commit fd4551cfe4b7484b81c2c9ba3405edae27659676
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Closed.Cartesian
import Mathbin.CategoryTheory.Punit
import Mathbin.CategoryTheory.Conj
import Mathbin.CategoryTheory.Limits.Shapes.ZeroObjects

/-!
# A cartesian closed category with zero object is trivial

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A cartesian closed category with zero object is trivial: it is equivalent to the category with one
object and one morphism.

## References

* https://mathoverflow.net/a/136480

-/


universe v u

noncomputable section

namespace CategoryTheory

open Category Limits

variable {C : Type u} [Category.{v} C]

variable [HasFiniteProducts C] [CartesianClosed C]

#print CategoryTheory.uniqueHomsetOfInitialIsoTerminal /-
/-- If a cartesian closed category has an initial object which is isomorphic to the terminal object,
then each homset has exactly one element.
-/
def uniqueHomsetOfInitialIsoTerminal [HasInitial C] (i : ⊥_ C ≅ ⊤_ C) (X Y : C) : Unique (X ⟶ Y) :=
  Equiv.unique <|
    calc
      (X ⟶ Y) ≃ (X ⨯ ⊤_ C ⟶ Y) := Iso.homCongr (prod.rightUnitor _).symm (Iso.refl _)
      _ ≃ (X ⨯ ⊥_ C ⟶ Y) := (Iso.homCongr (prod.mapIso (Iso.refl _) i.symm) (Iso.refl _))
      _ ≃ (⊥_ C ⟶ Y ^^ X) := (exp.adjunction _).homEquiv _ _
#align category_theory.unique_homset_of_initial_iso_terminal CategoryTheory.uniqueHomsetOfInitialIsoTerminal
-/

open scoped ZeroObject

#print CategoryTheory.uniqueHomsetOfZero /-
/-- If a cartesian closed category has a zero object, each homset has exactly one element. -/
def uniqueHomsetOfZero [HasZeroObject C] (X Y : C) : Unique (X ⟶ Y) :=
  by
  haveI : has_initial C := has_zero_object.has_initial
  apply unique_homset_of_initial_iso_terminal _ X Y
  refine' ⟨default, (default : ⊤_ C ⟶ 0) ≫ default, _, _⟩ <;> simp
#align category_theory.unique_homset_of_zero CategoryTheory.uniqueHomsetOfZero
-/

attribute [local instance] unique_homset_of_zero

#print CategoryTheory.equivPUnit /-
/-- A cartesian closed category with a zero object is equivalent to the category with one object and
one morphism.
-/
def equivPUnit [HasZeroObject C] : C ≌ Discrete PUnit :=
  Equivalence.mk (Functor.star C) (Functor.fromPUnit 0)
    (NatIso.ofComponents
      (fun X =>
        { Hom := default
          inv := default })
      fun X Y f => by decide)
    (Functor.punitExt _ _)
#align category_theory.equiv_punit CategoryTheory.equivPUnit
-/

end CategoryTheory

