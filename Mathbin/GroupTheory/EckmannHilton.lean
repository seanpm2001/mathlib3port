/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Kenny Lau, Robert Y. Lewis

! This file was ported from Lean 3 source module group_theory.eckmann_hilton
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.Defs

/-!
# Eckmann-Hilton argument

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The Eckmann-Hilton argument says that if a type carries two monoid structures that distribute
over one another, then they are equal, and in addition commutative.
The main application lies in proving that higher homotopy groups (`πₙ` for `n ≥ 2`) are commutative.

## Main declarations

* `eckmann_hilton.comm_monoid`: If a type carries a unital magma structure that distributes
  over a unital binary operation, then the magma is a commutative monoid.
* `eckmann_hilton.comm_group`: If a type carries a group structure that distributes
  over a unital binary operation, then the group is commutative.

-/


universe u

namespace EckmannHilton

variable {X : Type u}

local notation a " <" m "> " b => m a b

#print EckmannHilton.IsUnital /-
/-- `is_unital m e` expresses that `e : X` is a left and right unit
for the binary operation `m : X → X → X`. -/
structure IsUnital (m : X → X → X) (e : X) extends IsLeftId _ m e, IsRightId _ m e : Prop
#align eckmann_hilton.is_unital EckmannHilton.IsUnital
-/

#print EckmannHilton.MulOneClass.isUnital /-
@[to_additive EckmannHilton.AddZeroClass.IsUnital]
theorem MulOneClass.isUnital [G : MulOneClass X] : IsUnital (· * ·) (1 : X) :=
  IsUnital.mk (by infer_instance) (by infer_instance)
#align eckmann_hilton.mul_one_class.is_unital EckmannHilton.MulOneClass.isUnital
#align eckmann_hilton.add_zero_class.is_unital EckmannHilton.AddZeroClass.IsUnital
-/

variable {m₁ m₂ : X → X → X} {e₁ e₂ : X}

variable (h₁ : IsUnital m₁ e₁) (h₂ : IsUnital m₂ e₂)

variable (distrib : ∀ a b c d, ((a <m₂> b) <m₁> c <m₂> d) = (a <m₁> c) <m₂> b <m₁> d)

#print EckmannHilton.one /-
/-- If a type carries two unital binary operations that distribute over each other,
then they have the same unit elements.

In fact, the two operations are the same, and give a commutative monoid structure,
see `eckmann_hilton.comm_monoid`. -/
theorem one : e₁ = e₂ := by
  simpa only [h₁.left_id, h₁.right_id, h₂.left_id, h₂.right_id] using Distrib e₂ e₁ e₁ e₂
#align eckmann_hilton.one EckmannHilton.one
-/

#print EckmannHilton.mul /-
/-- If a type carries two unital binary operations that distribute over each other,
then these operations are equal.

In fact, they give a commutative monoid structure, see `eckmann_hilton.comm_monoid`. -/
theorem mul : m₁ = m₂ := by
  funext a b
  calc
    m₁ a b = m₁ (m₂ a e₁) (m₂ e₁ b) := by
      simp only [one h₁ h₂ Distrib, h₁.left_id, h₁.right_id, h₂.left_id, h₂.right_id]
    _ = m₂ a b := by simp only [Distrib, h₁.left_id, h₁.right_id, h₂.left_id, h₂.right_id]
#align eckmann_hilton.mul EckmannHilton.mul
-/

#print EckmannHilton.mul_comm /-
/-- If a type carries two unital binary operations that distribute over each other,
then these operations are commutative.

In fact, they give a commutative monoid structure, see `eckmann_hilton.comm_monoid`. -/
theorem mul_comm : IsCommutative _ m₂ :=
  ⟨fun a b => by simpa [mul h₁ h₂ Distrib, h₂.left_id, h₂.right_id] using Distrib e₂ a b e₂⟩
#align eckmann_hilton.mul_comm EckmannHilton.mul_comm
-/

#print EckmannHilton.mul_assoc /-
/-- If a type carries two unital binary operations that distribute over each other,
then these operations are associative.

In fact, they give a commutative monoid structure, see `eckmann_hilton.comm_monoid`. -/
theorem mul_assoc : IsAssociative _ m₂ :=
  ⟨fun a b c => by simpa [mul h₁ h₂ Distrib, h₂.left_id, h₂.right_id] using Distrib a b e₂ c⟩
#align eckmann_hilton.mul_assoc EckmannHilton.mul_assoc
-/

#print EckmannHilton.commMonoid /-
/-- If a type carries a unital magma structure that distributes over a unital binary
operations, then the magma structure is a commutative monoid. -/
@[reducible,
  to_additive
      "If a type carries a unital additive magma structure that distributes over\na unital binary operations, then the additive magma structure is a commutative additive monoid."]
def commMonoid [h : MulOneClass X]
    (distrib : ∀ a b c d, ((a * b) <m₁> c * d) = (a <m₁> c) * b <m₁> d) : CommMonoid X :=
  { h with
    mul := (· * ·)
    one := 1
    mul_comm := (mul_comm h₁ MulOneClass.isUnital Distrib).comm
    mul_assoc := (mul_assoc h₁ MulOneClass.isUnital Distrib).and_assoc }
#align eckmann_hilton.comm_monoid EckmannHilton.commMonoid
#align eckmann_hilton.add_comm_monoid EckmannHilton.addCommMonoid
-/

#print EckmannHilton.commGroup /-
/-- If a type carries a group structure that distributes over a unital binary operation,
then the group is commutative. -/
@[reducible,
  to_additive
      "If a type carries an additive group structure that\ndistributes over a unital binary operation, then the additive group is commutative."]
def commGroup [G : Group X] (distrib : ∀ a b c d, ((a * b) <m₁> c * d) = (a <m₁> c) * b <m₁> d) :
    CommGroup X :=
  { EckmannHilton.commMonoid h₁ Distrib, G with }
#align eckmann_hilton.comm_group EckmannHilton.commGroup
#align eckmann_hilton.add_comm_group EckmannHilton.addCommGroup
-/

end EckmannHilton

