/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.monoid.basic
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Monoid.Defs
import Mathbin.Algebra.Group.InjSurj
import Mathbin.Order.Hom.Basic

/-!
# Ordered monoids

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file develops some additional material on ordered monoids.
-/


open Function

universe u

variable {α : Type u} {β : Type _}

#print Function.Injective.orderedCommMonoid /-
/-- Pullback an `ordered_comm_monoid` under an injective map.
See note [reducible non-instances]. -/
@[reducible,
  to_additive Function.Injective.orderedAddCommMonoid
      "Pullback an `ordered_add_comm_monoid` under an injective map."]
def Function.Injective.orderedCommMonoid [OrderedCommMonoid α] {β : Type _} [One β] [Mul β]
    [Pow β ℕ] (f : β → α) (hf : Function.Injective f) (one : f 1 = 1)
    (mul : ∀ x y, f (x * y) = f x * f y) (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n) :
    OrderedCommMonoid β :=
  { PartialOrder.lift f hf, hf.CommMonoid f one mul npow with
    mul_le_mul_left := fun a b ab c =>
      show f (c * a) ≤ f (c * b) by rw [mul, mul]; apply mul_le_mul_left'; exact ab }
#align function.injective.ordered_comm_monoid Function.Injective.orderedCommMonoid
#align function.injective.ordered_add_comm_monoid Function.Injective.orderedAddCommMonoid
-/

#print Function.Injective.linearOrderedCommMonoid /-
/-- Pullback a `linear_ordered_comm_monoid` under an injective map.
See note [reducible non-instances]. -/
@[reducible,
  to_additive Function.Injective.linearOrderedAddCommMonoid
      "Pullback an `ordered_add_comm_monoid` under an injective map."]
def Function.Injective.linearOrderedCommMonoid [LinearOrderedCommMonoid α] {β : Type _} [One β]
    [Mul β] [Pow β ℕ] [Sup β] [Inf β] (f : β → α) (hf : Function.Injective f) (one : f 1 = 1)
    (mul : ∀ x y, f (x * y) = f x * f y) (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n)
    (hsup : ∀ x y, f (x ⊔ y) = max (f x) (f y)) (hinf : ∀ x y, f (x ⊓ y) = min (f x) (f y)) :
    LinearOrderedCommMonoid β :=
  { hf.OrderedCommMonoid f one mul npow, LinearOrder.lift f hf hsup hinf with }
#align function.injective.linear_ordered_comm_monoid Function.Injective.linearOrderedCommMonoid
#align function.injective.linear_ordered_add_comm_monoid Function.Injective.linearOrderedAddCommMonoid
-/

#print OrderEmbedding.mulLeft /-
-- TODO find a better home for the next two constructions.
/-- The order embedding sending `b` to `a * b`, for some fixed `a`.
See also `order_iso.mul_left` when working in an ordered group. -/
@[to_additive
      "The order embedding sending `b` to `a + b`, for some fixed `a`.\n  See also `order_iso.add_left` when working in an additive ordered group.",
  simps]
def OrderEmbedding.mulLeft {α : Type _} [Mul α] [LinearOrder α] [CovariantClass α α (· * ·) (· < ·)]
    (m : α) : α ↪o α :=
  OrderEmbedding.ofStrictMono (fun n => m * n) fun a b w => mul_lt_mul_left' w m
#align order_embedding.mul_left OrderEmbedding.mulLeft
#align order_embedding.add_left OrderEmbedding.addLeft
-/

#print OrderEmbedding.mulRight /-
/-- The order embedding sending `b` to `b * a`, for some fixed `a`.
See also `order_iso.mul_right` when working in an ordered group. -/
@[to_additive
      "The order embedding sending `b` to `b + a`, for some fixed `a`.\n  See also `order_iso.add_right` when working in an additive ordered group.",
  simps]
def OrderEmbedding.mulRight {α : Type _} [Mul α] [LinearOrder α]
    [CovariantClass α α (swap (· * ·)) (· < ·)] (m : α) : α ↪o α :=
  OrderEmbedding.ofStrictMono (fun n => n * m) fun a b w => mul_lt_mul_right' w m
#align order_embedding.mul_right OrderEmbedding.mulRight
#align order_embedding.add_right OrderEmbedding.addRight
-/

