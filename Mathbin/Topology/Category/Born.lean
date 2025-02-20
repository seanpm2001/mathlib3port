/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module topology.category.Born
! leanprover-community/mathlib commit 1dac236edca9b4b6f5f00b1ad831e35f89472837
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.ConcreteCategory.BundledHom
import Mathbin.Topology.Bornology.Hom

/-!
# The category of bornologies

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This defines `Born`, the category of bornologies.
-/


universe u

open CategoryTheory

#print Born /-
/-- The category of bornologies. -/
def Born :=
  Bundled Bornology
#align Born Born
-/

namespace Born

instance : CoeSort Born (Type _) :=
  Bundled.hasCoeToSort

instance (X : Born) : Bornology X :=
  X.str

#print Born.of /-
/-- Construct a bundled `Born` from a `bornology`. -/
def of (α : Type _) [Bornology α] : Born :=
  Bundled.of α
#align Born.of Born.of
-/

instance : Inhabited Born :=
  ⟨of PUnit⟩

instance : BundledHom @LocallyBoundedMap
    where
  toFun _ _ _ _ := coeFn
  id := @LocallyBoundedMap.id
  comp := @LocallyBoundedMap.comp
  hom_ext X Y _ _ := FunLike.coe_injective

instance : LargeCategory.{u} Born :=
  BundledHom.category LocallyBoundedMap

instance : ConcreteCategory Born :=
  BundledHom.concreteCategory LocallyBoundedMap

end Born

