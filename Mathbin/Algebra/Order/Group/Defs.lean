/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.group.defs
! leanprover-community/mathlib commit b599f4e4e5cf1fbcb4194503671d3d9e569c1fce
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Hom.Basic
import Mathbin.Algebra.Order.Sub.Defs
import Mathbin.Algebra.Order.Monoid.Cancel.Defs

/-!
# Ordered groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file develops the basics of ordered groups.

## Implementation details

Unfortunately, the number of `'` appended to lemmas in this file
may differ between the multiplicative and the additive version of a lemma.
The reason is that we did not want to change existing names in the library.
-/


open Function

universe u

variable {α : Type u}

#print OrderedAddCommGroup /-
/-- An ordered additive commutative group is an additive commutative group
with a partial order in which addition is strictly monotone. -/
@[protect_proj]
class OrderedAddCommGroup (α : Type u) extends AddCommGroup α, PartialOrder α where
  add_le_add_left : ∀ a b : α, a ≤ b → ∀ c : α, c + a ≤ c + b
#align ordered_add_comm_group OrderedAddCommGroup
-/

#print OrderedCommGroup /-
/-- An ordered commutative group is an commutative group
with a partial order in which multiplication is strictly monotone. -/
@[protect_proj]
class OrderedCommGroup (α : Type u) extends CommGroup α, PartialOrder α where
  mul_le_mul_left : ∀ a b : α, a ≤ b → ∀ c : α, c * a ≤ c * b
#align ordered_comm_group OrderedCommGroup
-/

attribute [to_additive] OrderedCommGroup

#print OrderedCommGroup.to_covariantClass_left_le /-
@[to_additive]
instance OrderedCommGroup.to_covariantClass_left_le (α : Type u) [OrderedCommGroup α] :
    CovariantClass α α (· * ·) (· ≤ ·)
    where elim a b c bc := OrderedCommGroup.mul_le_mul_left b c bc a
#align ordered_comm_group.to_covariant_class_left_le OrderedCommGroup.to_covariantClass_left_le
#align ordered_add_comm_group.to_covariant_class_left_le OrderedAddCommGroup.to_covariantClass_left_le
-/

#print OrderedCommGroup.toOrderedCancelCommMonoid /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) OrderedCommGroup.toOrderedCancelCommMonoid [OrderedCommGroup α] :
    OrderedCancelCommMonoid α :=
  { ‹OrderedCommGroup α› with le_of_mul_le_mul_left := fun a b c => le_of_mul_le_mul_left' }
#align ordered_comm_group.to_ordered_cancel_comm_monoid OrderedCommGroup.toOrderedCancelCommMonoid
#align ordered_add_comm_group.to_ordered_cancel_add_comm_monoid OrderedAddCommGroup.toOrderedCancelAddCommMonoid
-/

example (α : Type u) [OrderedAddCommGroup α] : CovariantClass α α (swap (· + ·)) (· < ·) :=
  AddRightCancelSemigroup.covariant_swap_add_lt_of_covariant_swap_add_le α

#print OrderedCommGroup.to_contravariantClass_left_le /-
-- Backporting note: this instance is not used,
-- and causes timeouts when interacting with etaExperiment.
/-- A choice-free shortcut instance. -/
@[to_additive "A choice-free shortcut instance."]
theorem OrderedCommGroup.to_contravariantClass_left_le (α : Type u) [OrderedCommGroup α] :
    ContravariantClass α α (· * ·) (· ≤ ·) :=
  { elim := fun a b c bc => by simpa using mul_le_mul_left' bc a⁻¹ }
#align ordered_comm_group.to_contravariant_class_left_le OrderedCommGroup.to_contravariantClass_left_le
#align ordered_add_comm_group.to_contravariant_class_left_le OrderedAddCommGroup.to_contravariantClass_left_le
-/

#print OrderedCommGroup.to_contravariantClass_right_le /-
-- Backporting note: this instance is not used,
-- and causes timeouts when interacting with etaExperiment.
/-- A choice-free shortcut instance. -/
@[to_additive "A choice-free shortcut instance."]
theorem OrderedCommGroup.to_contravariantClass_right_le (α : Type u) [OrderedCommGroup α] :
    ContravariantClass α α (swap (· * ·)) (· ≤ ·) :=
  { elim := fun a b c bc => by simpa using mul_le_mul_right' bc a⁻¹ }
#align ordered_comm_group.to_contravariant_class_right_le OrderedCommGroup.to_contravariantClass_right_le
#align ordered_add_comm_group.to_contravariant_class_right_le OrderedAddCommGroup.to_contravariantClass_right_le
-/

section Group

variable [Group α]

section TypeclassesLeftLe

variable [LE α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b c d : α}

#print Left.inv_le_one_iff /-
/-- Uses `left` co(ntra)variant. -/
@[simp, to_additive Left.neg_nonpos_iff "Uses `left` co(ntra)variant."]
theorem Left.inv_le_one_iff : a⁻¹ ≤ 1 ↔ 1 ≤ a := by rw [← mul_le_mul_iff_left a]; simp
#align left.inv_le_one_iff Left.inv_le_one_iff
#align left.neg_nonpos_iff Left.neg_nonpos_iff
-/

#print Left.one_le_inv_iff /-
/-- Uses `left` co(ntra)variant. -/
@[simp, to_additive Left.nonneg_neg_iff "Uses `left` co(ntra)variant."]
theorem Left.one_le_inv_iff : 1 ≤ a⁻¹ ↔ a ≤ 1 := by rw [← mul_le_mul_iff_left a]; simp
#align left.one_le_inv_iff Left.one_le_inv_iff
#align left.nonneg_neg_iff Left.nonneg_neg_iff
-/

#print le_inv_mul_iff_mul_le /-
@[simp, to_additive]
theorem le_inv_mul_iff_mul_le : b ≤ a⁻¹ * c ↔ a * b ≤ c := by rw [← mul_le_mul_iff_left a]; simp
#align le_inv_mul_iff_mul_le le_inv_mul_iff_mul_le
#align le_neg_add_iff_add_le le_neg_add_iff_add_le
-/

#print inv_mul_le_iff_le_mul /-
@[simp, to_additive]
theorem inv_mul_le_iff_le_mul : b⁻¹ * a ≤ c ↔ a ≤ b * c := by
  rw [← mul_le_mul_iff_left b, mul_inv_cancel_left]
#align inv_mul_le_iff_le_mul inv_mul_le_iff_le_mul
#align neg_add_le_iff_le_add neg_add_le_iff_le_add
-/

#print inv_le_iff_one_le_mul' /-
@[to_additive neg_le_iff_add_nonneg']
theorem inv_le_iff_one_le_mul' : a⁻¹ ≤ b ↔ 1 ≤ a * b :=
  (mul_le_mul_iff_left a).symm.trans <| by rw [mul_inv_self]
#align inv_le_iff_one_le_mul' inv_le_iff_one_le_mul'
#align neg_le_iff_add_nonneg' neg_le_iff_add_nonneg'
-/

#print le_inv_iff_mul_le_one_left /-
@[to_additive]
theorem le_inv_iff_mul_le_one_left : a ≤ b⁻¹ ↔ b * a ≤ 1 :=
  (mul_le_mul_iff_left b).symm.trans <| by rw [mul_inv_self]
#align le_inv_iff_mul_le_one_left le_inv_iff_mul_le_one_left
#align le_neg_iff_add_nonpos_left le_neg_iff_add_nonpos_left
-/

#print le_inv_mul_iff_le /-
@[to_additive]
theorem le_inv_mul_iff_le : 1 ≤ b⁻¹ * a ↔ b ≤ a := by
  rw [← mul_le_mul_iff_left b, mul_one, mul_inv_cancel_left]
#align le_inv_mul_iff_le le_inv_mul_iff_le
#align le_neg_add_iff_le le_neg_add_iff_le
-/

#print inv_mul_le_one_iff /-
@[to_additive]
theorem inv_mul_le_one_iff : a⁻¹ * b ≤ 1 ↔ b ≤ a :=
  trans inv_mul_le_iff_le_mul <| by rw [mul_one]
#align inv_mul_le_one_iff inv_mul_le_one_iff
#align neg_add_nonpos_iff neg_add_nonpos_iff
-/

end TypeclassesLeftLe

section TypeclassesLeftLt

variable [LT α] [CovariantClass α α (· * ·) (· < ·)] {a b c : α}

#print Left.one_lt_inv_iff /-
/-- Uses `left` co(ntra)variant. -/
@[simp, to_additive Left.neg_pos_iff "Uses `left` co(ntra)variant."]
theorem Left.one_lt_inv_iff : 1 < a⁻¹ ↔ a < 1 := by
  rw [← mul_lt_mul_iff_left a, mul_inv_self, mul_one]
#align left.one_lt_inv_iff Left.one_lt_inv_iff
#align left.neg_pos_iff Left.neg_pos_iff
-/

#print Left.inv_lt_one_iff /-
/-- Uses `left` co(ntra)variant. -/
@[simp, to_additive Left.neg_neg_iff "Uses `left` co(ntra)variant."]
theorem Left.inv_lt_one_iff : a⁻¹ < 1 ↔ 1 < a := by
  rw [← mul_lt_mul_iff_left a, mul_inv_self, mul_one]
#align left.inv_lt_one_iff Left.inv_lt_one_iff
#align left.neg_neg_iff Left.neg_neg_iff
-/

#print lt_inv_mul_iff_mul_lt /-
@[simp, to_additive]
theorem lt_inv_mul_iff_mul_lt : b < a⁻¹ * c ↔ a * b < c := by rw [← mul_lt_mul_iff_left a]; simp
#align lt_inv_mul_iff_mul_lt lt_inv_mul_iff_mul_lt
#align lt_neg_add_iff_add_lt lt_neg_add_iff_add_lt
-/

#print inv_mul_lt_iff_lt_mul /-
@[simp, to_additive]
theorem inv_mul_lt_iff_lt_mul : b⁻¹ * a < c ↔ a < b * c := by
  rw [← mul_lt_mul_iff_left b, mul_inv_cancel_left]
#align inv_mul_lt_iff_lt_mul inv_mul_lt_iff_lt_mul
#align neg_add_lt_iff_lt_add neg_add_lt_iff_lt_add
-/

#print inv_lt_iff_one_lt_mul' /-
@[to_additive]
theorem inv_lt_iff_one_lt_mul' : a⁻¹ < b ↔ 1 < a * b :=
  (mul_lt_mul_iff_left a).symm.trans <| by rw [mul_inv_self]
#align inv_lt_iff_one_lt_mul' inv_lt_iff_one_lt_mul'
#align neg_lt_iff_pos_add' neg_lt_iff_pos_add'
-/

#print lt_inv_iff_mul_lt_one' /-
@[to_additive]
theorem lt_inv_iff_mul_lt_one' : a < b⁻¹ ↔ b * a < 1 :=
  (mul_lt_mul_iff_left b).symm.trans <| by rw [mul_inv_self]
#align lt_inv_iff_mul_lt_one' lt_inv_iff_mul_lt_one'
#align lt_neg_iff_add_neg' lt_neg_iff_add_neg'
-/

#print lt_inv_mul_iff_lt /-
@[to_additive]
theorem lt_inv_mul_iff_lt : 1 < b⁻¹ * a ↔ b < a := by
  rw [← mul_lt_mul_iff_left b, mul_one, mul_inv_cancel_left]
#align lt_inv_mul_iff_lt lt_inv_mul_iff_lt
#align lt_neg_add_iff_lt lt_neg_add_iff_lt
-/

#print inv_mul_lt_one_iff /-
@[to_additive]
theorem inv_mul_lt_one_iff : a⁻¹ * b < 1 ↔ b < a :=
  trans inv_mul_lt_iff_lt_mul <| by rw [mul_one]
#align inv_mul_lt_one_iff inv_mul_lt_one_iff
#align neg_add_neg_iff neg_add_neg_iff
-/

end TypeclassesLeftLt

section TypeclassesRightLe

variable [LE α] [CovariantClass α α (swap (· * ·)) (· ≤ ·)] {a b c : α}

#print Right.inv_le_one_iff /-
/-- Uses `right` co(ntra)variant. -/
@[simp, to_additive Right.neg_nonpos_iff "Uses `right` co(ntra)variant."]
theorem Right.inv_le_one_iff : a⁻¹ ≤ 1 ↔ 1 ≤ a := by rw [← mul_le_mul_iff_right a]; simp
#align right.inv_le_one_iff Right.inv_le_one_iff
#align right.neg_nonpos_iff Right.neg_nonpos_iff
-/

#print Right.one_le_inv_iff /-
/-- Uses `right` co(ntra)variant. -/
@[simp, to_additive Right.nonneg_neg_iff "Uses `right` co(ntra)variant."]
theorem Right.one_le_inv_iff : 1 ≤ a⁻¹ ↔ a ≤ 1 := by rw [← mul_le_mul_iff_right a]; simp
#align right.one_le_inv_iff Right.one_le_inv_iff
#align right.nonneg_neg_iff Right.nonneg_neg_iff
-/

#print inv_le_iff_one_le_mul /-
@[to_additive neg_le_iff_add_nonneg]
theorem inv_le_iff_one_le_mul : a⁻¹ ≤ b ↔ 1 ≤ b * a :=
  (mul_le_mul_iff_right a).symm.trans <| by rw [inv_mul_self]
#align inv_le_iff_one_le_mul inv_le_iff_one_le_mul
#align neg_le_iff_add_nonneg neg_le_iff_add_nonneg
-/

#print le_inv_iff_mul_le_one_right /-
@[to_additive]
theorem le_inv_iff_mul_le_one_right : a ≤ b⁻¹ ↔ a * b ≤ 1 :=
  (mul_le_mul_iff_right b).symm.trans <| by rw [inv_mul_self]
#align le_inv_iff_mul_le_one_right le_inv_iff_mul_le_one_right
#align le_neg_iff_add_nonpos_right le_neg_iff_add_nonpos_right
-/

#print mul_inv_le_iff_le_mul /-
@[simp, to_additive]
theorem mul_inv_le_iff_le_mul : a * b⁻¹ ≤ c ↔ a ≤ c * b :=
  (mul_le_mul_iff_right b).symm.trans <| by rw [inv_mul_cancel_right]
#align mul_inv_le_iff_le_mul mul_inv_le_iff_le_mul
#align add_neg_le_iff_le_add add_neg_le_iff_le_add
-/

#print le_mul_inv_iff_mul_le /-
@[simp, to_additive]
theorem le_mul_inv_iff_mul_le : c ≤ a * b⁻¹ ↔ c * b ≤ a :=
  (mul_le_mul_iff_right b).symm.trans <| by rw [inv_mul_cancel_right]
#align le_mul_inv_iff_mul_le le_mul_inv_iff_mul_le
#align le_add_neg_iff_add_le le_add_neg_iff_add_le
-/

#print mul_inv_le_one_iff_le /-
@[simp, to_additive]
theorem mul_inv_le_one_iff_le : a * b⁻¹ ≤ 1 ↔ a ≤ b :=
  mul_inv_le_iff_le_mul.trans <| by rw [one_mul]
#align mul_inv_le_one_iff_le mul_inv_le_one_iff_le
#align add_neg_nonpos_iff_le add_neg_nonpos_iff_le
-/

#print le_mul_inv_iff_le /-
@[to_additive]
theorem le_mul_inv_iff_le : 1 ≤ a * b⁻¹ ↔ b ≤ a := by
  rw [← mul_le_mul_iff_right b, one_mul, inv_mul_cancel_right]
#align le_mul_inv_iff_le le_mul_inv_iff_le
#align le_add_neg_iff_le le_add_neg_iff_le
-/

#print mul_inv_le_one_iff /-
@[to_additive]
theorem mul_inv_le_one_iff : b * a⁻¹ ≤ 1 ↔ b ≤ a :=
  trans mul_inv_le_iff_le_mul <| by rw [one_mul]
#align mul_inv_le_one_iff mul_inv_le_one_iff
#align add_neg_nonpos_iff add_neg_nonpos_iff
-/

end TypeclassesRightLe

section TypeclassesRightLt

variable [LT α] [CovariantClass α α (swap (· * ·)) (· < ·)] {a b c : α}

#print Right.inv_lt_one_iff /-
/-- Uses `right` co(ntra)variant. -/
@[simp, to_additive Right.neg_neg_iff "Uses `right` co(ntra)variant."]
theorem Right.inv_lt_one_iff : a⁻¹ < 1 ↔ 1 < a := by
  rw [← mul_lt_mul_iff_right a, inv_mul_self, one_mul]
#align right.inv_lt_one_iff Right.inv_lt_one_iff
#align right.neg_neg_iff Right.neg_neg_iff
-/

#print Right.one_lt_inv_iff /-
/-- Uses `right` co(ntra)variant. -/
@[simp, to_additive Right.neg_pos_iff "Uses `right` co(ntra)variant."]
theorem Right.one_lt_inv_iff : 1 < a⁻¹ ↔ a < 1 := by
  rw [← mul_lt_mul_iff_right a, inv_mul_self, one_mul]
#align right.one_lt_inv_iff Right.one_lt_inv_iff
#align right.neg_pos_iff Right.neg_pos_iff
-/

#print inv_lt_iff_one_lt_mul /-
@[to_additive]
theorem inv_lt_iff_one_lt_mul : a⁻¹ < b ↔ 1 < b * a :=
  (mul_lt_mul_iff_right a).symm.trans <| by rw [inv_mul_self]
#align inv_lt_iff_one_lt_mul inv_lt_iff_one_lt_mul
#align neg_lt_iff_pos_add neg_lt_iff_pos_add
-/

#print lt_inv_iff_mul_lt_one /-
@[to_additive]
theorem lt_inv_iff_mul_lt_one : a < b⁻¹ ↔ a * b < 1 :=
  (mul_lt_mul_iff_right b).symm.trans <| by rw [inv_mul_self]
#align lt_inv_iff_mul_lt_one lt_inv_iff_mul_lt_one
#align lt_neg_iff_add_neg lt_neg_iff_add_neg
-/

#print mul_inv_lt_iff_lt_mul /-
@[simp, to_additive]
theorem mul_inv_lt_iff_lt_mul : a * b⁻¹ < c ↔ a < c * b := by
  rw [← mul_lt_mul_iff_right b, inv_mul_cancel_right]
#align mul_inv_lt_iff_lt_mul mul_inv_lt_iff_lt_mul
#align add_neg_lt_iff_lt_add add_neg_lt_iff_lt_add
-/

#print lt_mul_inv_iff_mul_lt /-
@[simp, to_additive]
theorem lt_mul_inv_iff_mul_lt : c < a * b⁻¹ ↔ c * b < a :=
  (mul_lt_mul_iff_right b).symm.trans <| by rw [inv_mul_cancel_right]
#align lt_mul_inv_iff_mul_lt lt_mul_inv_iff_mul_lt
#align lt_add_neg_iff_add_lt lt_add_neg_iff_add_lt
-/

#print inv_mul_lt_one_iff_lt /-
@[simp, to_additive]
theorem inv_mul_lt_one_iff_lt : a * b⁻¹ < 1 ↔ a < b := by
  rw [← mul_lt_mul_iff_right b, inv_mul_cancel_right, one_mul]
#align inv_mul_lt_one_iff_lt inv_mul_lt_one_iff_lt
#align neg_add_neg_iff_lt neg_add_neg_iff_lt
-/

#print lt_mul_inv_iff_lt /-
@[to_additive]
theorem lt_mul_inv_iff_lt : 1 < a * b⁻¹ ↔ b < a := by
  rw [← mul_lt_mul_iff_right b, one_mul, inv_mul_cancel_right]
#align lt_mul_inv_iff_lt lt_mul_inv_iff_lt
#align lt_add_neg_iff_lt lt_add_neg_iff_lt
-/

#print mul_inv_lt_one_iff /-
@[to_additive]
theorem mul_inv_lt_one_iff : b * a⁻¹ < 1 ↔ b < a :=
  trans mul_inv_lt_iff_lt_mul <| by rw [one_mul]
#align mul_inv_lt_one_iff mul_inv_lt_one_iff
#align add_neg_neg_iff add_neg_neg_iff
-/

end TypeclassesRightLt

section TypeclassesLeftRightLe

variable [LE α] [CovariantClass α α (· * ·) (· ≤ ·)] [CovariantClass α α (swap (· * ·)) (· ≤ ·)]
  {a b c d : α}

#print inv_le_inv_iff /-
@[simp, to_additive]
theorem inv_le_inv_iff : a⁻¹ ≤ b⁻¹ ↔ b ≤ a := by
  rw [← mul_le_mul_iff_left a, ← mul_le_mul_iff_right b]; simp
#align inv_le_inv_iff inv_le_inv_iff
#align neg_le_neg_iff neg_le_neg_iff
-/

alias neg_le_neg_iff ↔ le_of_neg_le_neg _
#align le_of_neg_le_neg le_of_neg_le_neg

#print mul_inv_le_inv_mul_iff /-
@[to_additive]
theorem mul_inv_le_inv_mul_iff : a * b⁻¹ ≤ d⁻¹ * c ↔ d * a ≤ c * b := by
  rw [← mul_le_mul_iff_left d, ← mul_le_mul_iff_right b, mul_inv_cancel_left, mul_assoc,
    inv_mul_cancel_right]
#align mul_inv_le_inv_mul_iff mul_inv_le_inv_mul_iff
#align add_neg_le_neg_add_iff add_neg_le_neg_add_iff
-/

#print div_le_self_iff /-
@[simp, to_additive]
theorem div_le_self_iff (a : α) {b : α} : a / b ≤ a ↔ 1 ≤ b := by simp [div_eq_mul_inv]
#align div_le_self_iff div_le_self_iff
#align sub_le_self_iff sub_le_self_iff
-/

#print le_div_self_iff /-
@[simp, to_additive]
theorem le_div_self_iff (a : α) {b : α} : a ≤ a / b ↔ b ≤ 1 := by simp [div_eq_mul_inv]
#align le_div_self_iff le_div_self_iff
#align le_sub_self_iff le_sub_self_iff
-/

alias sub_le_self_iff ↔ _ sub_le_self
#align sub_le_self sub_le_self

end TypeclassesLeftRightLe

section TypeclassesLeftRightLt

variable [LT α] [CovariantClass α α (· * ·) (· < ·)] [CovariantClass α α (swap (· * ·)) (· < ·)]
  {a b c d : α}

#print inv_lt_inv_iff /-
@[simp, to_additive]
theorem inv_lt_inv_iff : a⁻¹ < b⁻¹ ↔ b < a := by
  rw [← mul_lt_mul_iff_left a, ← mul_lt_mul_iff_right b]; simp
#align inv_lt_inv_iff inv_lt_inv_iff
#align neg_lt_neg_iff neg_lt_neg_iff
-/

#print inv_lt' /-
@[to_additive neg_lt]
theorem inv_lt' : a⁻¹ < b ↔ b⁻¹ < a := by rw [← inv_lt_inv_iff, inv_inv]
#align inv_lt' inv_lt'
#align neg_lt neg_lt
-/

#print lt_inv' /-
@[to_additive lt_neg]
theorem lt_inv' : a < b⁻¹ ↔ b < a⁻¹ := by rw [← inv_lt_inv_iff, inv_inv]
#align lt_inv' lt_inv'
#align lt_neg lt_neg
-/

alias lt_inv' ↔ lt_inv_of_lt_inv _
#align lt_inv_of_lt_inv lt_inv_of_lt_inv

attribute [to_additive] lt_inv_of_lt_inv

alias inv_lt' ↔ inv_lt_of_inv_lt' _
#align inv_lt_of_inv_lt' inv_lt_of_inv_lt'

attribute [to_additive neg_lt_of_neg_lt] inv_lt_of_inv_lt'

#print mul_inv_lt_inv_mul_iff /-
@[to_additive]
theorem mul_inv_lt_inv_mul_iff : a * b⁻¹ < d⁻¹ * c ↔ d * a < c * b := by
  rw [← mul_lt_mul_iff_left d, ← mul_lt_mul_iff_right b, mul_inv_cancel_left, mul_assoc,
    inv_mul_cancel_right]
#align mul_inv_lt_inv_mul_iff mul_inv_lt_inv_mul_iff
#align add_neg_lt_neg_add_iff add_neg_lt_neg_add_iff
-/

#print div_lt_self_iff /-
@[simp, to_additive]
theorem div_lt_self_iff (a : α) {b : α} : a / b < a ↔ 1 < b := by simp [div_eq_mul_inv]
#align div_lt_self_iff div_lt_self_iff
#align sub_lt_self_iff sub_lt_self_iff
-/

alias sub_lt_self_iff ↔ _ sub_lt_self
#align sub_lt_self sub_lt_self

end TypeclassesLeftRightLt

section PreOrder

variable [Preorder α]

section LeftLe

variable [CovariantClass α α (· * ·) (· ≤ ·)] {a : α}

#print Left.inv_le_self /-
@[to_additive]
theorem Left.inv_le_self (h : 1 ≤ a) : a⁻¹ ≤ a :=
  le_trans (Left.inv_le_one_iff.mpr h) h
#align left.inv_le_self Left.inv_le_self
#align left.neg_le_self Left.neg_le_self
-/

alias Left.neg_le_self ← neg_le_self
#align neg_le_self neg_le_self

#print Left.self_le_inv /-
@[to_additive]
theorem Left.self_le_inv (h : a ≤ 1) : a ≤ a⁻¹ :=
  le_trans h (Left.one_le_inv_iff.mpr h)
#align left.self_le_inv Left.self_le_inv
#align left.self_le_neg Left.self_le_neg
-/

end LeftLe

section LeftLt

variable [CovariantClass α α (· * ·) (· < ·)] {a : α}

#print Left.inv_lt_self /-
@[to_additive]
theorem Left.inv_lt_self (h : 1 < a) : a⁻¹ < a :=
  (Left.inv_lt_one_iff.mpr h).trans h
#align left.inv_lt_self Left.inv_lt_self
#align left.neg_lt_self Left.neg_lt_self
-/

alias Left.neg_lt_self ← neg_lt_self
#align neg_lt_self neg_lt_self

#print Left.self_lt_inv /-
@[to_additive]
theorem Left.self_lt_inv (h : a < 1) : a < a⁻¹ :=
  lt_trans h (Left.one_lt_inv_iff.mpr h)
#align left.self_lt_inv Left.self_lt_inv
#align left.self_lt_neg Left.self_lt_neg
-/

end LeftLt

section RightLe

variable [CovariantClass α α (swap (· * ·)) (· ≤ ·)] {a : α}

#print Right.inv_le_self /-
@[to_additive]
theorem Right.inv_le_self (h : 1 ≤ a) : a⁻¹ ≤ a :=
  le_trans (Right.inv_le_one_iff.mpr h) h
#align right.inv_le_self Right.inv_le_self
#align right.neg_le_self Right.neg_le_self
-/

#print Right.self_le_inv /-
@[to_additive]
theorem Right.self_le_inv (h : a ≤ 1) : a ≤ a⁻¹ :=
  le_trans h (Right.one_le_inv_iff.mpr h)
#align right.self_le_inv Right.self_le_inv
#align right.self_le_neg Right.self_le_neg
-/

end RightLe

section RightLt

variable [CovariantClass α α (swap (· * ·)) (· < ·)] {a : α}

#print Right.inv_lt_self /-
@[to_additive]
theorem Right.inv_lt_self (h : 1 < a) : a⁻¹ < a :=
  (Right.inv_lt_one_iff.mpr h).trans h
#align right.inv_lt_self Right.inv_lt_self
#align right.neg_lt_self Right.neg_lt_self
-/

#print Right.self_lt_inv /-
@[to_additive]
theorem Right.self_lt_inv (h : a < 1) : a < a⁻¹ :=
  lt_trans h (Right.one_lt_inv_iff.mpr h)
#align right.self_lt_inv Right.self_lt_inv
#align right.self_lt_neg Right.self_lt_neg
-/

end RightLt

end PreOrder

end Group

section CommGroup

variable [CommGroup α]

section LE

variable [LE α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b c d : α}

#print inv_mul_le_iff_le_mul' /-
@[to_additive]
theorem inv_mul_le_iff_le_mul' : c⁻¹ * a ≤ b ↔ a ≤ b * c := by rw [inv_mul_le_iff_le_mul, mul_comm]
#align inv_mul_le_iff_le_mul' inv_mul_le_iff_le_mul'
#align neg_add_le_iff_le_add' neg_add_le_iff_le_add'
-/

#print mul_inv_le_iff_le_mul' /-
@[simp, to_additive]
theorem mul_inv_le_iff_le_mul' : a * b⁻¹ ≤ c ↔ a ≤ b * c := by
  rw [← inv_mul_le_iff_le_mul, mul_comm]
#align mul_inv_le_iff_le_mul' mul_inv_le_iff_le_mul'
#align add_neg_le_iff_le_add' add_neg_le_iff_le_add'
-/

#print mul_inv_le_mul_inv_iff' /-
@[to_additive add_neg_le_add_neg_iff]
theorem mul_inv_le_mul_inv_iff' : a * b⁻¹ ≤ c * d⁻¹ ↔ a * d ≤ c * b := by
  rw [mul_comm c, mul_inv_le_inv_mul_iff, mul_comm]
#align mul_inv_le_mul_inv_iff' mul_inv_le_mul_inv_iff'
#align add_neg_le_add_neg_iff add_neg_le_add_neg_iff
-/

end LE

section LT

variable [LT α] [CovariantClass α α (· * ·) (· < ·)] {a b c d : α}

#print inv_mul_lt_iff_lt_mul' /-
@[to_additive]
theorem inv_mul_lt_iff_lt_mul' : c⁻¹ * a < b ↔ a < b * c := by rw [inv_mul_lt_iff_lt_mul, mul_comm]
#align inv_mul_lt_iff_lt_mul' inv_mul_lt_iff_lt_mul'
#align neg_add_lt_iff_lt_add' neg_add_lt_iff_lt_add'
-/

#print mul_inv_lt_iff_le_mul' /-
@[simp, to_additive]
theorem mul_inv_lt_iff_le_mul' : a * b⁻¹ < c ↔ a < b * c := by
  rw [← inv_mul_lt_iff_lt_mul, mul_comm]
#align mul_inv_lt_iff_le_mul' mul_inv_lt_iff_le_mul'
#align add_neg_lt_iff_le_add' add_neg_lt_iff_le_add'
-/

#print mul_inv_lt_mul_inv_iff' /-
@[to_additive add_neg_lt_add_neg_iff]
theorem mul_inv_lt_mul_inv_iff' : a * b⁻¹ < c * d⁻¹ ↔ a * d < c * b := by
  rw [mul_comm c, mul_inv_lt_inv_mul_iff, mul_comm]
#align mul_inv_lt_mul_inv_iff' mul_inv_lt_mul_inv_iff'
#align add_neg_lt_add_neg_iff add_neg_lt_add_neg_iff
-/

end LT

end CommGroup

alias Left.inv_le_one_iff ↔ one_le_of_inv_le_one _
#align one_le_of_inv_le_one one_le_of_inv_le_one

attribute [to_additive] one_le_of_inv_le_one

alias Left.one_le_inv_iff ↔ le_one_of_one_le_inv _
#align le_one_of_one_le_inv le_one_of_one_le_inv

attribute [to_additive nonpos_of_neg_nonneg] le_one_of_one_le_inv

alias inv_lt_inv_iff ↔ lt_of_inv_lt_inv _
#align lt_of_inv_lt_inv lt_of_inv_lt_inv

attribute [to_additive] lt_of_inv_lt_inv

alias Left.inv_lt_one_iff ↔ one_lt_of_inv_lt_one _
#align one_lt_of_inv_lt_one one_lt_of_inv_lt_one

attribute [to_additive] one_lt_of_inv_lt_one

alias Left.inv_lt_one_iff ← inv_lt_one_iff_one_lt
#align inv_lt_one_iff_one_lt inv_lt_one_iff_one_lt

attribute [to_additive] inv_lt_one_iff_one_lt

alias Left.inv_lt_one_iff ← inv_lt_one'
#align inv_lt_one' inv_lt_one'

attribute [to_additive neg_lt_zero] inv_lt_one'

alias Left.one_lt_inv_iff ↔ inv_of_one_lt_inv _
#align inv_of_one_lt_inv inv_of_one_lt_inv

attribute [to_additive neg_of_neg_pos] inv_of_one_lt_inv

alias Left.one_lt_inv_iff ↔ _ one_lt_inv_of_inv
#align one_lt_inv_of_inv one_lt_inv_of_inv

attribute [to_additive neg_pos_of_neg] one_lt_inv_of_inv

alias le_inv_mul_iff_mul_le ↔ mul_le_of_le_inv_mul _
#align mul_le_of_le_inv_mul mul_le_of_le_inv_mul

attribute [to_additive] mul_le_of_le_inv_mul

alias le_inv_mul_iff_mul_le ↔ _ le_inv_mul_of_mul_le
#align le_inv_mul_of_mul_le le_inv_mul_of_mul_le

attribute [to_additive] le_inv_mul_of_mul_le

alias inv_mul_le_iff_le_mul ↔ _ inv_mul_le_of_le_mul
#align inv_mul_le_of_le_mul inv_mul_le_of_le_mul

attribute [to_additive] inv_mul_le_iff_le_mul

alias lt_inv_mul_iff_mul_lt ↔ mul_lt_of_lt_inv_mul _
#align mul_lt_of_lt_inv_mul mul_lt_of_lt_inv_mul

attribute [to_additive] mul_lt_of_lt_inv_mul

alias lt_inv_mul_iff_mul_lt ↔ _ lt_inv_mul_of_mul_lt
#align lt_inv_mul_of_mul_lt lt_inv_mul_of_mul_lt

attribute [to_additive] lt_inv_mul_of_mul_lt

alias inv_mul_lt_iff_lt_mul ↔ lt_mul_of_inv_mul_lt inv_mul_lt_of_lt_mul
#align lt_mul_of_inv_mul_lt lt_mul_of_inv_mul_lt
#align inv_mul_lt_of_lt_mul inv_mul_lt_of_lt_mul

attribute [to_additive] lt_mul_of_inv_mul_lt

attribute [to_additive] inv_mul_lt_of_lt_mul

alias lt_mul_of_inv_mul_lt ← lt_mul_of_inv_mul_lt_left
#align lt_mul_of_inv_mul_lt_left lt_mul_of_inv_mul_lt_left

attribute [to_additive] lt_mul_of_inv_mul_lt_left

alias Left.inv_le_one_iff ← inv_le_one'
#align inv_le_one' inv_le_one'

attribute [to_additive neg_nonpos] inv_le_one'

alias Left.one_le_inv_iff ← one_le_inv'
#align one_le_inv' one_le_inv'

attribute [to_additive neg_nonneg] one_le_inv'

alias Left.one_lt_inv_iff ← one_lt_inv'
#align one_lt_inv' one_lt_inv'

attribute [to_additive neg_pos] one_lt_inv'

alias mul_lt_mul_left' ← OrderedCommGroup.mul_lt_mul_left'
#align ordered_comm_group.mul_lt_mul_left' OrderedCommGroup.mul_lt_mul_left'

attribute [to_additive OrderedAddCommGroup.add_lt_add_left] OrderedCommGroup.mul_lt_mul_left'

alias le_of_mul_le_mul_left' ← OrderedCommGroup.le_of_mul_le_mul_left
#align ordered_comm_group.le_of_mul_le_mul_left OrderedCommGroup.le_of_mul_le_mul_left

attribute [to_additive OrderedAddCommGroup.le_of_add_le_add_left]
  OrderedCommGroup.le_of_mul_le_mul_left

alias lt_of_mul_lt_mul_left' ← OrderedCommGroup.lt_of_mul_lt_mul_left
#align ordered_comm_group.lt_of_mul_lt_mul_left OrderedCommGroup.lt_of_mul_lt_mul_left

attribute [to_additive OrderedAddCommGroup.lt_of_add_lt_add_left]
  OrderedCommGroup.lt_of_mul_lt_mul_left

--  Most of the lemmas that are primed in this section appear in ordered_field. 
--  I (DT) did not try to minimise the assumptions.
section Group

variable [Group α] [LE α]

section Right

variable [CovariantClass α α (swap (· * ·)) (· ≤ ·)] {a b c d : α}

#print div_le_div_iff_right /-
@[simp, to_additive]
theorem div_le_div_iff_right (c : α) : a / c ≤ b / c ↔ a ≤ b := by
  simpa only [div_eq_mul_inv] using mul_le_mul_iff_right _
#align div_le_div_iff_right div_le_div_iff_right
#align sub_le_sub_iff_right sub_le_sub_iff_right
-/

#print div_le_div_right' /-
@[to_additive sub_le_sub_right]
theorem div_le_div_right' (h : a ≤ b) (c : α) : a / c ≤ b / c :=
  (div_le_div_iff_right c).2 h
#align div_le_div_right' div_le_div_right'
#align sub_le_sub_right sub_le_sub_right
-/

#print one_le_div' /-
@[simp, to_additive sub_nonneg]
theorem one_le_div' : 1 ≤ a / b ↔ b ≤ a := by
  rw [← mul_le_mul_iff_right b, one_mul, div_eq_mul_inv, inv_mul_cancel_right]
#align one_le_div' one_le_div'
#align sub_nonneg sub_nonneg
-/

alias sub_nonneg ↔ le_of_sub_nonneg sub_nonneg_of_le
#align le_of_sub_nonneg le_of_sub_nonneg
#align sub_nonneg_of_le sub_nonneg_of_le

#print div_le_one' /-
@[simp, to_additive sub_nonpos]
theorem div_le_one' : a / b ≤ 1 ↔ a ≤ b := by
  rw [← mul_le_mul_iff_right b, one_mul, div_eq_mul_inv, inv_mul_cancel_right]
#align div_le_one' div_le_one'
#align sub_nonpos sub_nonpos
-/

alias sub_nonpos ↔ le_of_sub_nonpos sub_nonpos_of_le
#align le_of_sub_nonpos le_of_sub_nonpos
#align sub_nonpos_of_le sub_nonpos_of_le

#print le_div_iff_mul_le /-
@[to_additive]
theorem le_div_iff_mul_le : a ≤ c / b ↔ a * b ≤ c := by
  rw [← mul_le_mul_iff_right b, div_eq_mul_inv, inv_mul_cancel_right]
#align le_div_iff_mul_le le_div_iff_mul_le
#align le_sub_iff_add_le le_sub_iff_add_le
-/

alias le_sub_iff_add_le ↔ add_le_of_le_sub_right le_sub_right_of_add_le
#align add_le_of_le_sub_right add_le_of_le_sub_right
#align le_sub_right_of_add_le le_sub_right_of_add_le

#print div_le_iff_le_mul /-
@[to_additive]
theorem div_le_iff_le_mul : a / c ≤ b ↔ a ≤ b * c := by
  rw [← mul_le_mul_iff_right c, div_eq_mul_inv, inv_mul_cancel_right]
#align div_le_iff_le_mul div_le_iff_le_mul
#align sub_le_iff_le_add sub_le_iff_le_add
-/

#print AddGroup.toHasOrderedSub /-
-- TODO: Should we get rid of `sub_le_iff_le_add` in favor of
-- (a renamed version of) `tsub_le_iff_right`?
-- see Note [lower instance priority]
instance (priority := 100) AddGroup.toHasOrderedSub {α : Type _} [AddGroup α] [LE α]
    [CovariantClass α α (swap (· + ·)) (· ≤ ·)] : OrderedSub α :=
  ⟨fun a b c => sub_le_iff_le_add⟩
#align add_group.to_has_ordered_sub AddGroup.toHasOrderedSub
-/

end Right

section Left

variable [CovariantClass α α (· * ·) (· ≤ ·)]

variable [CovariantClass α α (swap (· * ·)) (· ≤ ·)] {a b c : α}

#print div_le_div_iff_left /-
@[simp, to_additive]
theorem div_le_div_iff_left (a : α) : a / b ≤ a / c ↔ c ≤ b := by
  rw [div_eq_mul_inv, div_eq_mul_inv, ← mul_le_mul_iff_left a⁻¹, inv_mul_cancel_left,
    inv_mul_cancel_left, inv_le_inv_iff]
#align div_le_div_iff_left div_le_div_iff_left
#align sub_le_sub_iff_left sub_le_sub_iff_left
-/

#print div_le_div_left' /-
@[to_additive sub_le_sub_left]
theorem div_le_div_left' (h : a ≤ b) (c : α) : c / b ≤ c / a :=
  (div_le_div_iff_left c).2 h
#align div_le_div_left' div_le_div_left'
#align sub_le_sub_left sub_le_sub_left
-/

end Left

end Group

section CommGroup

variable [CommGroup α]

section LE

variable [LE α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b c d : α}

#print div_le_div_iff' /-
@[to_additive sub_le_sub_iff]
theorem div_le_div_iff' : a / b ≤ c / d ↔ a * d ≤ c * b := by
  simpa only [div_eq_mul_inv] using mul_inv_le_mul_inv_iff'
#align div_le_div_iff' div_le_div_iff'
#align sub_le_sub_iff sub_le_sub_iff
-/

#print le_div_iff_mul_le' /-
@[to_additive]
theorem le_div_iff_mul_le' : b ≤ c / a ↔ a * b ≤ c := by rw [le_div_iff_mul_le, mul_comm]
#align le_div_iff_mul_le' le_div_iff_mul_le'
#align le_sub_iff_add_le' le_sub_iff_add_le'
-/

alias le_sub_iff_add_le' ↔ add_le_of_le_sub_left le_sub_left_of_add_le
#align add_le_of_le_sub_left add_le_of_le_sub_left
#align le_sub_left_of_add_le le_sub_left_of_add_le

#print div_le_iff_le_mul' /-
@[to_additive]
theorem div_le_iff_le_mul' : a / b ≤ c ↔ a ≤ b * c := by rw [div_le_iff_le_mul, mul_comm]
#align div_le_iff_le_mul' div_le_iff_le_mul'
#align sub_le_iff_le_add' sub_le_iff_le_add'
-/

alias sub_le_iff_le_add' ↔ le_add_of_sub_left_le sub_left_le_of_le_add
#align le_add_of_sub_left_le le_add_of_sub_left_le
#align sub_left_le_of_le_add sub_left_le_of_le_add

#print inv_le_div_iff_le_mul /-
@[simp, to_additive]
theorem inv_le_div_iff_le_mul : b⁻¹ ≤ a / c ↔ c ≤ a * b :=
  le_div_iff_mul_le.trans inv_mul_le_iff_le_mul'
#align inv_le_div_iff_le_mul inv_le_div_iff_le_mul
#align neg_le_sub_iff_le_add neg_le_sub_iff_le_add
-/

#print inv_le_div_iff_le_mul' /-
@[to_additive]
theorem inv_le_div_iff_le_mul' : a⁻¹ ≤ b / c ↔ c ≤ a * b := by rw [inv_le_div_iff_le_mul, mul_comm]
#align inv_le_div_iff_le_mul' inv_le_div_iff_le_mul'
#align neg_le_sub_iff_le_add' neg_le_sub_iff_le_add'
-/

#print div_le_comm /-
@[to_additive]
theorem div_le_comm : a / b ≤ c ↔ a / c ≤ b :=
  div_le_iff_le_mul'.trans div_le_iff_le_mul.symm
#align div_le_comm div_le_comm
#align sub_le_comm sub_le_comm
-/

#print le_div_comm /-
@[to_additive]
theorem le_div_comm : a ≤ b / c ↔ c ≤ b / a :=
  le_div_iff_mul_le'.trans le_div_iff_mul_le.symm
#align le_div_comm le_div_comm
#align le_sub_comm le_sub_comm
-/

end LE

section Preorder

variable [Preorder α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b c d : α}

#print div_le_div'' /-
@[to_additive sub_le_sub]
theorem div_le_div'' (hab : a ≤ b) (hcd : c ≤ d) : a / d ≤ b / c :=
  by
  rw [div_eq_mul_inv, div_eq_mul_inv, mul_comm b, mul_inv_le_inv_mul_iff, mul_comm]
  exact mul_le_mul' hab hcd
#align div_le_div'' div_le_div''
#align sub_le_sub sub_le_sub
-/

end Preorder

end CommGroup

--  Most of the lemmas that are primed in this section appear in ordered_field. 
--  I (DT) did not try to minimise the assumptions.
section Group

variable [Group α] [LT α]

section Right

variable [CovariantClass α α (swap (· * ·)) (· < ·)] {a b c d : α}

#print div_lt_div_iff_right /-
@[simp, to_additive]
theorem div_lt_div_iff_right (c : α) : a / c < b / c ↔ a < b := by
  simpa only [div_eq_mul_inv] using mul_lt_mul_iff_right _
#align div_lt_div_iff_right div_lt_div_iff_right
#align sub_lt_sub_iff_right sub_lt_sub_iff_right
-/

#print div_lt_div_right' /-
@[to_additive sub_lt_sub_right]
theorem div_lt_div_right' (h : a < b) (c : α) : a / c < b / c :=
  (div_lt_div_iff_right c).2 h
#align div_lt_div_right' div_lt_div_right'
#align sub_lt_sub_right sub_lt_sub_right
-/

#print one_lt_div' /-
@[simp, to_additive sub_pos]
theorem one_lt_div' : 1 < a / b ↔ b < a := by
  rw [← mul_lt_mul_iff_right b, one_mul, div_eq_mul_inv, inv_mul_cancel_right]
#align one_lt_div' one_lt_div'
#align sub_pos sub_pos
-/

alias sub_pos ↔ lt_of_sub_pos sub_pos_of_lt
#align lt_of_sub_pos lt_of_sub_pos
#align sub_pos_of_lt sub_pos_of_lt

#print div_lt_one' /-
@[simp, to_additive sub_neg]
theorem div_lt_one' : a / b < 1 ↔ a < b := by
  rw [← mul_lt_mul_iff_right b, one_mul, div_eq_mul_inv, inv_mul_cancel_right]
#align div_lt_one' div_lt_one'
#align sub_neg sub_neg
-/

alias sub_neg ↔ lt_of_sub_neg sub_neg_of_lt
#align lt_of_sub_neg lt_of_sub_neg
#align sub_neg_of_lt sub_neg_of_lt

alias sub_neg ← sub_lt_zero
#align sub_lt_zero sub_lt_zero

#print lt_div_iff_mul_lt /-
@[to_additive]
theorem lt_div_iff_mul_lt : a < c / b ↔ a * b < c := by
  rw [← mul_lt_mul_iff_right b, div_eq_mul_inv, inv_mul_cancel_right]
#align lt_div_iff_mul_lt lt_div_iff_mul_lt
#align lt_sub_iff_add_lt lt_sub_iff_add_lt
-/

alias lt_sub_iff_add_lt ↔ add_lt_of_lt_sub_right lt_sub_right_of_add_lt
#align add_lt_of_lt_sub_right add_lt_of_lt_sub_right
#align lt_sub_right_of_add_lt lt_sub_right_of_add_lt

#print div_lt_iff_lt_mul /-
@[to_additive]
theorem div_lt_iff_lt_mul : a / c < b ↔ a < b * c := by
  rw [← mul_lt_mul_iff_right c, div_eq_mul_inv, inv_mul_cancel_right]
#align div_lt_iff_lt_mul div_lt_iff_lt_mul
#align sub_lt_iff_lt_add sub_lt_iff_lt_add
-/

alias sub_lt_iff_lt_add ↔ lt_add_of_sub_right_lt sub_right_lt_of_lt_add
#align lt_add_of_sub_right_lt lt_add_of_sub_right_lt
#align sub_right_lt_of_lt_add sub_right_lt_of_lt_add

end Right

section Left

variable [CovariantClass α α (· * ·) (· < ·)] [CovariantClass α α (swap (· * ·)) (· < ·)]
  {a b c : α}

#print div_lt_div_iff_left /-
@[simp, to_additive]
theorem div_lt_div_iff_left (a : α) : a / b < a / c ↔ c < b := by
  rw [div_eq_mul_inv, div_eq_mul_inv, ← mul_lt_mul_iff_left a⁻¹, inv_mul_cancel_left,
    inv_mul_cancel_left, inv_lt_inv_iff]
#align div_lt_div_iff_left div_lt_div_iff_left
#align sub_lt_sub_iff_left sub_lt_sub_iff_left
-/

#print inv_lt_div_iff_lt_mul /-
@[simp, to_additive]
theorem inv_lt_div_iff_lt_mul : a⁻¹ < b / c ↔ c < a * b := by
  rw [div_eq_mul_inv, lt_mul_inv_iff_mul_lt, inv_mul_lt_iff_lt_mul]
#align inv_lt_div_iff_lt_mul inv_lt_div_iff_lt_mul
#align neg_lt_sub_iff_lt_add neg_lt_sub_iff_lt_add
-/

#print div_lt_div_left' /-
@[to_additive sub_lt_sub_left]
theorem div_lt_div_left' (h : a < b) (c : α) : c / b < c / a :=
  (div_lt_div_iff_left c).2 h
#align div_lt_div_left' div_lt_div_left'
#align sub_lt_sub_left sub_lt_sub_left
-/

end Left

end Group

section CommGroup

variable [CommGroup α]

section LT

variable [LT α] [CovariantClass α α (· * ·) (· < ·)] {a b c d : α}

#print div_lt_div_iff' /-
@[to_additive sub_lt_sub_iff]
theorem div_lt_div_iff' : a / b < c / d ↔ a * d < c * b := by
  simpa only [div_eq_mul_inv] using mul_inv_lt_mul_inv_iff'
#align div_lt_div_iff' div_lt_div_iff'
#align sub_lt_sub_iff sub_lt_sub_iff
-/

#print lt_div_iff_mul_lt' /-
@[to_additive]
theorem lt_div_iff_mul_lt' : b < c / a ↔ a * b < c := by rw [lt_div_iff_mul_lt, mul_comm]
#align lt_div_iff_mul_lt' lt_div_iff_mul_lt'
#align lt_sub_iff_add_lt' lt_sub_iff_add_lt'
-/

alias lt_sub_iff_add_lt' ↔ add_lt_of_lt_sub_left lt_sub_left_of_add_lt
#align add_lt_of_lt_sub_left add_lt_of_lt_sub_left
#align lt_sub_left_of_add_lt lt_sub_left_of_add_lt

#print div_lt_iff_lt_mul' /-
@[to_additive]
theorem div_lt_iff_lt_mul' : a / b < c ↔ a < b * c := by rw [div_lt_iff_lt_mul, mul_comm]
#align div_lt_iff_lt_mul' div_lt_iff_lt_mul'
#align sub_lt_iff_lt_add' sub_lt_iff_lt_add'
-/

alias sub_lt_iff_lt_add' ↔ lt_add_of_sub_left_lt sub_left_lt_of_lt_add
#align lt_add_of_sub_left_lt lt_add_of_sub_left_lt
#align sub_left_lt_of_lt_add sub_left_lt_of_lt_add

#print inv_lt_div_iff_lt_mul' /-
@[to_additive]
theorem inv_lt_div_iff_lt_mul' : b⁻¹ < a / c ↔ c < a * b :=
  lt_div_iff_mul_lt.trans inv_mul_lt_iff_lt_mul'
#align inv_lt_div_iff_lt_mul' inv_lt_div_iff_lt_mul'
#align neg_lt_sub_iff_lt_add' neg_lt_sub_iff_lt_add'
-/

#print div_lt_comm /-
@[to_additive]
theorem div_lt_comm : a / b < c ↔ a / c < b :=
  div_lt_iff_lt_mul'.trans div_lt_iff_lt_mul.symm
#align div_lt_comm div_lt_comm
#align sub_lt_comm sub_lt_comm
-/

#print lt_div_comm /-
@[to_additive]
theorem lt_div_comm : a < b / c ↔ c < b / a :=
  lt_div_iff_mul_lt'.trans lt_div_iff_mul_lt.symm
#align lt_div_comm lt_div_comm
#align lt_sub_comm lt_sub_comm
-/

end LT

section Preorder

variable [Preorder α] [CovariantClass α α (· * ·) (· < ·)] {a b c d : α}

#print div_lt_div'' /-
@[to_additive sub_lt_sub]
theorem div_lt_div'' (hab : a < b) (hcd : c < d) : a / d < b / c :=
  by
  rw [div_eq_mul_inv, div_eq_mul_inv, mul_comm b, mul_inv_lt_inv_mul_iff, mul_comm]
  exact mul_lt_mul_of_lt_of_lt hab hcd
#align div_lt_div'' div_lt_div''
#align sub_lt_sub sub_lt_sub
-/

end Preorder

end CommGroup

section LinearOrder

variable [Group α] [LinearOrder α]

#print cmp_div_one' /-
@[simp, to_additive cmp_sub_zero]
theorem cmp_div_one' [CovariantClass α α (swap (· * ·)) (· ≤ ·)] (a b : α) :
    cmp (a / b) 1 = cmp a b := by rw [← cmp_mul_right' _ _ b, one_mul, div_mul_cancel']
#align cmp_div_one' cmp_div_one'
#align cmp_sub_zero cmp_sub_zero
-/

variable [CovariantClass α α (· * ·) (· ≤ ·)]

section VariableNames

variable {a b c : α}

#print le_of_forall_one_lt_lt_mul /-
@[to_additive]
theorem le_of_forall_one_lt_lt_mul (h : ∀ ε : α, 1 < ε → a < b * ε) : a ≤ b :=
  le_of_not_lt fun h₁ => lt_irrefl a (by simpa using h _ (lt_inv_mul_iff_lt.mpr h₁))
#align le_of_forall_one_lt_lt_mul le_of_forall_one_lt_lt_mul
#align le_of_forall_pos_lt_add le_of_forall_pos_lt_add
-/

#print le_iff_forall_one_lt_lt_mul /-
@[to_additive]
theorem le_iff_forall_one_lt_lt_mul : a ≤ b ↔ ∀ ε, 1 < ε → a < b * ε :=
  ⟨fun h ε => lt_mul_of_le_of_one_lt h, le_of_forall_one_lt_lt_mul⟩
#align le_iff_forall_one_lt_lt_mul le_iff_forall_one_lt_lt_mul
#align le_iff_forall_pos_lt_add le_iff_forall_pos_lt_add
-/

#print div_le_inv_mul_iff /-
/-  I (DT) introduced this lemma to prove (the additive version `sub_le_sub_flip` of)
`div_le_div_flip` below.  Now I wonder what is the point of either of these lemmas... -/
@[to_additive]
theorem div_le_inv_mul_iff [CovariantClass α α (swap (· * ·)) (· ≤ ·)] : a / b ≤ a⁻¹ * b ↔ a ≤ b :=
  by
  rw [div_eq_mul_inv, mul_inv_le_inv_mul_iff]
  exact
    ⟨fun h => not_lt.mp fun k => not_lt.mpr h (mul_lt_mul_of_lt_of_lt k k), fun h =>
      mul_le_mul' h h⟩
#align div_le_inv_mul_iff div_le_inv_mul_iff
#align sub_le_neg_add_iff sub_le_neg_add_iff
-/

#print div_le_div_flip /-
--  What is the point of this lemma?  See comment about `div_le_inv_mul_iff` above.
@[simp, to_additive]
theorem div_le_div_flip {α : Type _} [CommGroup α] [LinearOrder α]
    [CovariantClass α α (· * ·) (· ≤ ·)] {a b : α} : a / b ≤ b / a ↔ a ≤ b :=
  by
  rw [div_eq_mul_inv b, mul_comm]
  exact div_le_inv_mul_iff
#align div_le_div_flip div_le_div_flip
#align sub_le_sub_flip sub_le_sub_flip
-/

end VariableNames

end LinearOrder

/-!
### Linearly ordered commutative groups
-/


#print LinearOrderedAddCommGroup /-
/-- A linearly ordered additive commutative group is an
additive commutative group with a linear order in which
addition is monotone. -/
@[protect_proj]
class LinearOrderedAddCommGroup (α : Type u) extends OrderedAddCommGroup α, LinearOrder α
#align linear_ordered_add_comm_group LinearOrderedAddCommGroup
-/

#print LinearOrderedAddCommGroupWithTop /-
/-- A linearly ordered commutative monoid with an additively absorbing `⊤` element.
  Instances should include number systems with an infinite element adjoined.` -/
@[protect_proj]
class LinearOrderedAddCommGroupWithTop (α : Type _) extends LinearOrderedAddCommMonoidWithTop α,
    SubNegMonoid α, Nontrivial α where
  neg_top : -(⊤ : α) = ⊤
  add_neg_cancel : ∀ a : α, a ≠ ⊤ → a + -a = 0
#align linear_ordered_add_comm_group_with_top LinearOrderedAddCommGroupWithTop
-/

#print LinearOrderedCommGroup /-
/-- A linearly ordered commutative group is a
commutative group with a linear order in which
multiplication is monotone. -/
@[protect_proj, to_additive]
class LinearOrderedCommGroup (α : Type u) extends OrderedCommGroup α, LinearOrder α
#align linear_ordered_comm_group LinearOrderedCommGroup
#align linear_ordered_add_comm_group LinearOrderedAddCommGroup
-/

section LinearOrderedCommGroup

variable [LinearOrderedCommGroup α] {a b c : α}

#print LinearOrderedCommGroup.mul_lt_mul_left' /-
@[to_additive LinearOrderedAddCommGroup.add_lt_add_left]
theorem LinearOrderedCommGroup.mul_lt_mul_left' (a b : α) (h : a < b) (c : α) : c * a < c * b :=
  mul_lt_mul_left' h c
#align linear_ordered_comm_group.mul_lt_mul_left' LinearOrderedCommGroup.mul_lt_mul_left'
#align linear_ordered_add_comm_group.add_lt_add_left LinearOrderedAddCommGroup.add_lt_add_left
-/

#print eq_one_of_inv_eq' /-
@[to_additive eq_zero_of_neg_eq]
theorem eq_one_of_inv_eq' (h : a⁻¹ = a) : a = 1 :=
  match lt_trichotomy a 1 with
  | Or.inl h₁ =>
    have : 1 < a := h ▸ one_lt_inv_of_inv h₁
    absurd h₁ this.asymm
  | Or.inr (Or.inl h₁) => h₁
  | Or.inr (Or.inr h₁) =>
    have : a < 1 := h ▸ inv_lt_one'.mpr h₁
    absurd h₁ this.asymm
#align eq_one_of_inv_eq' eq_one_of_inv_eq'
#align eq_zero_of_neg_eq eq_zero_of_neg_eq
-/

#print exists_one_lt' /-
@[to_additive exists_zero_lt]
theorem exists_one_lt' [Nontrivial α] : ∃ a : α, 1 < a :=
  by
  obtain ⟨y, hy⟩ := Decidable.exists_ne (1 : α)
  cases hy.lt_or_lt
  · exact ⟨y⁻¹, one_lt_inv'.mpr h⟩
  · exact ⟨y, h⟩
#align exists_one_lt' exists_one_lt'
#align exists_zero_lt exists_zero_lt
-/

#print LinearOrderedCommGroup.to_noMaxOrder /-
-- see Note [lower instance priority]
@[to_additive]
instance (priority := 100) LinearOrderedCommGroup.to_noMaxOrder [Nontrivial α] : NoMaxOrder α :=
  ⟨by
    obtain ⟨y, hy⟩ : ∃ a : α, 1 < a := exists_one_lt'
    exact fun a => ⟨a * y, lt_mul_of_one_lt_right' a hy⟩⟩
#align linear_ordered_comm_group.to_no_max_order LinearOrderedCommGroup.to_noMaxOrder
#align linear_ordered_add_comm_group.to_no_max_order LinearOrderedAddCommGroup.to_noMaxOrder
-/

#print LinearOrderedCommGroup.to_noMinOrder /-
-- see Note [lower instance priority]
@[to_additive]
instance (priority := 100) LinearOrderedCommGroup.to_noMinOrder [Nontrivial α] : NoMinOrder α :=
  ⟨by
    obtain ⟨y, hy⟩ : ∃ a : α, 1 < a := exists_one_lt'
    exact fun a => ⟨a / y, (div_lt_self_iff a).mpr hy⟩⟩
#align linear_ordered_comm_group.to_no_min_order LinearOrderedCommGroup.to_noMinOrder
#align linear_ordered_add_comm_group.to_no_min_order LinearOrderedAddCommGroup.to_noMinOrder
-/

#print LinearOrderedCommGroup.toLinearOrderedCancelCommMonoid /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) LinearOrderedCommGroup.toLinearOrderedCancelCommMonoid :
    LinearOrderedCancelCommMonoid α :=
  { ‹LinearOrderedCommGroup α›, OrderedCommGroup.toOrderedCancelCommMonoid with }
#align linear_ordered_comm_group.to_linear_ordered_cancel_comm_monoid LinearOrderedCommGroup.toLinearOrderedCancelCommMonoid
#align linear_ordered_add_comm_group.to_linear_ordered_cancel_add_comm_monoid LinearOrderedAddCommGroup.toLinearOrderedAddCancelCommMonoid
-/

end LinearOrderedCommGroup

namespace AddCommGroup

#print AddCommGroup.PositiveCone /-
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic order_laws_tac -/
/-- A collection of elements in an `add_comm_group` designated as "non-negative".
This is useful for constructing an `ordered_add_commm_group`
by choosing a positive cone in an exisiting `add_comm_group`. -/
@[nolint has_nonempty_instance]
structure PositiveCone (α : Type _) [AddCommGroup α] where
  NonNeg : α → Prop
  Pos : α → Prop := fun a => nonneg a ∧ ¬nonneg (-a)
  pos_iff : ∀ a, Pos a ↔ nonneg a ∧ ¬nonneg (-a) := by
    run_tac
      order_laws_tac
  zero_nonneg : nonneg 0
  add_nonneg : ∀ {a b}, nonneg a → nonneg b → nonneg (a + b)
  nonneg_antisymm : ∀ {a}, nonneg a → nonneg (-a) → a = 0
#align add_comm_group.positive_cone AddCommGroup.PositiveCone
-/

#print AddCommGroup.TotalPositiveCone /-
/-- A positive cone in an `add_comm_group` induces a linear order if
for every `a`, either `a` or `-a` is non-negative. -/
@[nolint has_nonempty_instance]
structure TotalPositiveCone (α : Type _) [AddCommGroup α] extends PositiveCone α where
  nonnegDecidable : DecidablePred nonneg
  nonneg_total : ∀ a : α, nonneg a ∨ nonneg (-a)
#align add_comm_group.total_positive_cone AddCommGroup.TotalPositiveCone
-/

/-- Forget that a `total_positive_cone` is total. -/
add_decl_doc total_positive_cone.to_positive_cone

end AddCommGroup

namespace OrderedAddCommGroup

open AddCommGroup

#print OrderedAddCommGroup.mkOfPositiveCone /-
/-- Construct an `ordered_add_comm_group` by
designating a positive cone in an existing `add_comm_group`. -/
def mkOfPositiveCone {α : Type _} [AddCommGroup α] (C : PositiveCone α) : OrderedAddCommGroup α :=
  { ‹AddCommGroup α› with
    le := fun a b => C.NonNeg (b - a)
    lt := fun a b => C.Pos (b - a)
    lt_iff_le_not_le := fun a b => by simp <;> rw [C.pos_iff] <;> simp
    le_refl := fun a => by simp [C.zero_nonneg]
    le_trans := fun a b c nab nbc => by
      simp [-sub_eq_add_neg] <;> rw [← sub_add_sub_cancel] <;> exact C.add_nonneg nbc nab
    le_antisymm := fun a b nab nba =>
      eq_of_sub_eq_zero <| C.nonneg_antisymm nba (by rw [neg_sub] <;> exact nab)
    add_le_add_left := fun a b nab c => by simpa [(· ≤ ·), Preorder.Le] using nab }
#align ordered_add_comm_group.mk_of_positive_cone OrderedAddCommGroup.mkOfPositiveCone
-/

end OrderedAddCommGroup

namespace LinearOrderedAddCommGroup

open AddCommGroup

#print LinearOrderedAddCommGroup.mkOfPositiveCone /-
/-- Construct a `linear_ordered_add_comm_group` by
designating a positive cone in an existing `add_comm_group`
such that for every `a`, either `a` or `-a` is non-negative. -/
def mkOfPositiveCone {α : Type _} [AddCommGroup α] (C : TotalPositiveCone α) :
    LinearOrderedAddCommGroup α :=
  {
    OrderedAddCommGroup.mkOfPositiveCone
      C.toPositiveCone with
    le_total := fun a b => by convert C.nonneg_total (b - a); change C.nonneg _ = _; congr; simp
    decidableLe := fun a b => C.nonnegDecidable _ }
#align linear_ordered_add_comm_group.mk_of_positive_cone LinearOrderedAddCommGroup.mkOfPositiveCone
-/

end LinearOrderedAddCommGroup

section NormNumLemmas

/- The following lemmas are stated so that the `norm_num` tactic can use them with the
expected signatures.  -/
variable [OrderedCommGroup α] {a b : α}

#print inv_le_inv' /-
@[to_additive neg_le_neg]
theorem inv_le_inv' : a ≤ b → b⁻¹ ≤ a⁻¹ :=
  inv_le_inv_iff.mpr
#align inv_le_inv' inv_le_inv'
#align neg_le_neg neg_le_neg
-/

#print inv_lt_inv' /-
@[to_additive neg_lt_neg]
theorem inv_lt_inv' : a < b → b⁻¹ < a⁻¹ :=
  inv_lt_inv_iff.mpr
#align inv_lt_inv' inv_lt_inv'
#align neg_lt_neg neg_lt_neg
-/

#print inv_lt_one_of_one_lt /-
--  The additive version is also a `linarith` lemma.
@[to_additive]
theorem inv_lt_one_of_one_lt : 1 < a → a⁻¹ < 1 :=
  inv_lt_one_iff_one_lt.mpr
#align inv_lt_one_of_one_lt inv_lt_one_of_one_lt
#align neg_neg_of_pos neg_neg_of_pos
-/

#print inv_le_one_of_one_le /-
--  The additive version is also a `linarith` lemma.
@[to_additive]
theorem inv_le_one_of_one_le : 1 ≤ a → a⁻¹ ≤ 1 :=
  inv_le_one'.mpr
#align inv_le_one_of_one_le inv_le_one_of_one_le
#align neg_nonpos_of_nonneg neg_nonpos_of_nonneg
-/

#print one_le_inv_of_le_one /-
@[to_additive neg_nonneg_of_nonpos]
theorem one_le_inv_of_le_one : a ≤ 1 → 1 ≤ a⁻¹ :=
  one_le_inv'.mpr
#align one_le_inv_of_le_one one_le_inv_of_le_one
#align neg_nonneg_of_nonpos neg_nonneg_of_nonpos
-/

end NormNumLemmas

section

variable {β : Type _} [Group α] [Preorder α] [CovariantClass α α (· * ·) (· ≤ ·)]
  [CovariantClass α α (swap (· * ·)) (· ≤ ·)] [Preorder β] {f : β → α} {s : Set β}

#print Monotone.inv /-
@[to_additive]
theorem Monotone.inv (hf : Monotone f) : Antitone fun x => (f x)⁻¹ := fun x y hxy =>
  inv_le_inv_iff.2 (hf hxy)
#align monotone.inv Monotone.inv
#align monotone.neg Monotone.neg
-/

#print Antitone.inv /-
@[to_additive]
theorem Antitone.inv (hf : Antitone f) : Monotone fun x => (f x)⁻¹ := fun x y hxy =>
  inv_le_inv_iff.2 (hf hxy)
#align antitone.inv Antitone.inv
#align antitone.neg Antitone.neg
-/

#print MonotoneOn.inv /-
@[to_additive]
theorem MonotoneOn.inv (hf : MonotoneOn f s) : AntitoneOn (fun x => (f x)⁻¹) s :=
  fun x hx y hy hxy => inv_le_inv_iff.2 (hf hx hy hxy)
#align monotone_on.inv MonotoneOn.inv
#align monotone_on.neg MonotoneOn.neg
-/

#print AntitoneOn.inv /-
@[to_additive]
theorem AntitoneOn.inv (hf : AntitoneOn f s) : MonotoneOn (fun x => (f x)⁻¹) s :=
  fun x hx y hy hxy => inv_le_inv_iff.2 (hf hx hy hxy)
#align antitone_on.inv AntitoneOn.inv
#align antitone_on.neg AntitoneOn.neg
-/

end

section

variable {β : Type _} [Group α] [Preorder α] [CovariantClass α α (· * ·) (· < ·)]
  [CovariantClass α α (swap (· * ·)) (· < ·)] [Preorder β] {f : β → α} {s : Set β}

#print StrictMono.inv /-
@[to_additive]
theorem StrictMono.inv (hf : StrictMono f) : StrictAnti fun x => (f x)⁻¹ := fun x y hxy =>
  inv_lt_inv_iff.2 (hf hxy)
#align strict_mono.inv StrictMono.inv
#align strict_mono.neg StrictMono.neg
-/

#print StrictAnti.inv /-
@[to_additive]
theorem StrictAnti.inv (hf : StrictAnti f) : StrictMono fun x => (f x)⁻¹ := fun x y hxy =>
  inv_lt_inv_iff.2 (hf hxy)
#align strict_anti.inv StrictAnti.inv
#align strict_anti.neg StrictAnti.neg
-/

#print StrictMonoOn.inv /-
@[to_additive]
theorem StrictMonoOn.inv (hf : StrictMonoOn f s) : StrictAntiOn (fun x => (f x)⁻¹) s :=
  fun x hx y hy hxy => inv_lt_inv_iff.2 (hf hx hy hxy)
#align strict_mono_on.inv StrictMonoOn.inv
#align strict_mono_on.neg StrictMonoOn.neg
-/

#print StrictAntiOn.inv /-
@[to_additive]
theorem StrictAntiOn.inv (hf : StrictAntiOn f s) : StrictMonoOn (fun x => (f x)⁻¹) s :=
  fun x hx y hy hxy => inv_lt_inv_iff.2 (hf hx hy hxy)
#align strict_anti_on.inv StrictAntiOn.inv
#align strict_anti_on.neg StrictAntiOn.neg
-/

end

