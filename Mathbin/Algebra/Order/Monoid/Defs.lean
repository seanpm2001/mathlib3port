/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.monoid.defs
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Monoid.Lemmas
import Mathbin.Order.BoundedOrder

/-!
# Ordered monoids

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides the definitions of ordered monoids.

-/


open Function

universe u

variable {α : Type u} {β : Type _}

#print OrderedCommMonoid /-
/-- An ordered commutative monoid is a commutative monoid
with a partial order such that `a ≤ b → c * a ≤ c * b` (multiplication is monotone)
-/
@[protect_proj]
class OrderedCommMonoid (α : Type _) extends CommMonoid α, PartialOrder α where
  mul_le_mul_left : ∀ a b : α, a ≤ b → ∀ c : α, c * a ≤ c * b
#align ordered_comm_monoid OrderedCommMonoid
-/

#print OrderedAddCommMonoid /-
/-- An ordered (additive) commutative monoid is a commutative monoid
  with a partial order such that `a ≤ b → c + a ≤ c + b` (addition is monotone)
-/
@[protect_proj]
class OrderedAddCommMonoid (α : Type _) extends AddCommMonoid α, PartialOrder α where
  add_le_add_left : ∀ a b : α, a ≤ b → ∀ c : α, c + a ≤ c + b
#align ordered_add_comm_monoid OrderedAddCommMonoid
-/

attribute [to_additive] OrderedCommMonoid

section OrderedInstances

#print OrderedCommMonoid.to_covariantClass_left /-
@[to_additive]
instance OrderedCommMonoid.to_covariantClass_left (M : Type _) [OrderedCommMonoid M] :
    CovariantClass M M (· * ·) (· ≤ ·)
    where elim a b c bc := OrderedCommMonoid.mul_le_mul_left _ _ bc a
#align ordered_comm_monoid.to_covariant_class_left OrderedCommMonoid.to_covariantClass_left
#align ordered_add_comm_monoid.to_covariant_class_left OrderedAddCommMonoid.to_covariantClass_left
-/

#print OrderedCommMonoid.to_covariantClass_right /-
/- This instance can be proven with `by apply_instance`.  However, `with_bot ℕ` does not
pick up a `covariant_class M M (function.swap (*)) (≤)` instance without it (see PR #7940). -/
@[to_additive]
instance OrderedCommMonoid.to_covariantClass_right (M : Type _) [OrderedCommMonoid M] :
    CovariantClass M M (swap (· * ·)) (· ≤ ·) :=
  covariant_swap_mul_le_of_covariant_mul_le M
#align ordered_comm_monoid.to_covariant_class_right OrderedCommMonoid.to_covariantClass_right
#align ordered_add_comm_monoid.to_covariant_class_right OrderedAddCommMonoid.to_covariantClass_right
-/

#print Mul.to_covariantClass_left /-
/- This is not an instance, to avoid creating a loop in the type-class system: in a
`left_cancel_semigroup` with a `partial_order`, assuming `covariant_class M M (*) (≤)` implies
`covariant_class M M (*) (<)`, see `left_cancel_semigroup.covariant_mul_lt_of_covariant_mul_le`. -/
@[to_additive]
theorem Mul.to_covariantClass_left (M : Type _) [Mul M] [PartialOrder M]
    [CovariantClass M M (· * ·) (· < ·)] : CovariantClass M M (· * ·) (· ≤ ·) :=
  ⟨covariant_le_of_covariant_lt _ _ _ CovariantClass.elim⟩
#align has_mul.to_covariant_class_left Mul.to_covariantClass_left
#align has_add.to_covariant_class_left Add.to_covariantClass_left
-/

#print Mul.to_covariantClass_right /-
/- This is not an instance, to avoid creating a loop in the type-class system: in a
`right_cancel_semigroup` with a `partial_order`, assuming `covariant_class M M (swap (*)) (<)`
implies `covariant_class M M (swap (*)) (≤)`, see
`right_cancel_semigroup.covariant_swap_mul_lt_of_covariant_swap_mul_le`. -/
@[to_additive]
theorem Mul.to_covariantClass_right (M : Type _) [Mul M] [PartialOrder M]
    [CovariantClass M M (swap (· * ·)) (· < ·)] : CovariantClass M M (swap (· * ·)) (· ≤ ·) :=
  ⟨covariant_le_of_covariant_lt _ _ _ CovariantClass.elim⟩
#align has_mul.to_covariant_class_right Mul.to_covariantClass_right
#align has_add.to_covariant_class_right Add.to_covariantClass_right
-/

end OrderedInstances

#print bit0_pos /-
theorem bit0_pos [OrderedAddCommMonoid α] {a : α} (h : 0 < a) : 0 < bit0 a :=
  add_pos' h h
#align bit0_pos bit0_pos
-/

#print LinearOrderedAddCommMonoid /-
/-- A linearly ordered additive commutative monoid. -/
@[protect_proj]
class LinearOrderedAddCommMonoid (α : Type _) extends LinearOrder α, OrderedAddCommMonoid α
#align linear_ordered_add_comm_monoid LinearOrderedAddCommMonoid
-/

#print LinearOrderedCommMonoid /-
/-- A linearly ordered commutative monoid. -/
@[protect_proj, to_additive]
class LinearOrderedCommMonoid (α : Type _) extends LinearOrder α, OrderedCommMonoid α
#align linear_ordered_comm_monoid LinearOrderedCommMonoid
#align linear_ordered_add_comm_monoid LinearOrderedAddCommMonoid
-/

#print LinearOrderedAddCommMonoidWithTop /-
/-- A linearly ordered commutative monoid with an additively absorbing `⊤` element.
  Instances should include number systems with an infinite element adjoined.` -/
@[protect_proj]
class LinearOrderedAddCommMonoidWithTop (α : Type _) extends LinearOrderedAddCommMonoid α,
    Top α where
  le_top : ∀ x : α, x ≤ ⊤
  top_add' : ∀ x : α, ⊤ + x = ⊤
#align linear_ordered_add_comm_monoid_with_top LinearOrderedAddCommMonoidWithTop
-/

#print LinearOrderedAddCommMonoidWithTop.toOrderTop /-
-- see Note [lower instance priority]
instance (priority := 100) LinearOrderedAddCommMonoidWithTop.toOrderTop (α : Type u)
    [h : LinearOrderedAddCommMonoidWithTop α] : OrderTop α :=
  { h with }
#align linear_ordered_add_comm_monoid_with_top.to_order_top LinearOrderedAddCommMonoidWithTop.toOrderTop
-/

section LinearOrderedAddCommMonoidWithTop

variable [LinearOrderedAddCommMonoidWithTop α] {a b : α}

#print top_add /-
@[simp]
theorem top_add (a : α) : ⊤ + a = ⊤ :=
  LinearOrderedAddCommMonoidWithTop.top_add' a
#align top_add top_add
-/

#print add_top /-
@[simp]
theorem add_top (a : α) : a + ⊤ = ⊤ :=
  trans (add_comm _ _) (top_add _)
#align add_top add_top
-/

end LinearOrderedAddCommMonoidWithTop

