/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.group.units
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Group.Defs
import Mathbin.Algebra.Order.Monoid.Defs
import Mathbin.Algebra.Order.Monoid.Units

/-!
# Adjoining a top element to a `linear_ordered_add_comm_group_with_top`.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


variable {α : Type _}

#print Units.orderedCommGroup /-
/-- The units of an ordered commutative monoid form an ordered commutative group. -/
@[to_additive
      "The units of an ordered commutative additive monoid form an ordered commutative\nadditive group."]
instance Units.orderedCommGroup [OrderedCommMonoid α] : OrderedCommGroup αˣ :=
  { Units.instPartialOrderUnits, Units.instCommGroupUnitsToMonoid with
    mul_le_mul_left := fun a b h c => (mul_le_mul_left' (h : (a : α) ≤ b) _ : (c : α) * a ≤ c * b) }
#align units.ordered_comm_group Units.orderedCommGroup
#align add_units.ordered_add_comm_group AddUnits.orderedAddCommGroup
-/

