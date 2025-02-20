/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.group.densely_ordered
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Monoid.Canonical.Defs
import Mathbin.Algebra.Order.Group.Defs
import Mathbin.Algebra.Order.Monoid.OrderDual

/-!
# Lemmas about densely linearly ordered groups.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


variable {α : Type _}

section DenselyOrdered

variable [Group α] [LinearOrder α]

variable [CovariantClass α α (· * ·) (· ≤ ·)]

variable [DenselyOrdered α] {a b c : α}

#print le_of_forall_lt_one_mul_le /-
@[to_additive]
theorem le_of_forall_lt_one_mul_le (h : ∀ ε < 1, a * ε ≤ b) : a ≤ b :=
  @le_of_forall_one_lt_le_mul αᵒᵈ _ _ _ _ _ _ _ _ h
#align le_of_forall_lt_one_mul_le le_of_forall_lt_one_mul_le
#align le_of_forall_neg_add_le le_of_forall_neg_add_le
-/

#print le_of_forall_one_lt_div_le /-
@[to_additive]
theorem le_of_forall_one_lt_div_le (h : ∀ ε : α, 1 < ε → a / ε ≤ b) : a ≤ b :=
  le_of_forall_lt_one_mul_le fun ε ε1 => by
    simpa only [div_eq_mul_inv, inv_inv] using h ε⁻¹ (Left.one_lt_inv_iff.2 ε1)
#align le_of_forall_one_lt_div_le le_of_forall_one_lt_div_le
#align le_of_forall_pos_sub_le le_of_forall_pos_sub_le
-/

#print le_iff_forall_one_lt_le_mul /-
@[to_additive]
theorem le_iff_forall_one_lt_le_mul : a ≤ b ↔ ∀ ε, 1 < ε → a ≤ b * ε :=
  ⟨fun h ε ε_pos => le_mul_of_le_of_one_le h ε_pos.le, le_of_forall_one_lt_le_mul⟩
#align le_iff_forall_one_lt_le_mul le_iff_forall_one_lt_le_mul
#align le_iff_forall_pos_le_add le_iff_forall_pos_le_add
-/

#print le_iff_forall_lt_one_mul_le /-
@[to_additive]
theorem le_iff_forall_lt_one_mul_le : a ≤ b ↔ ∀ ε < 1, a * ε ≤ b :=
  @le_iff_forall_one_lt_le_mul αᵒᵈ _ _ _ _ _ _
#align le_iff_forall_lt_one_mul_le le_iff_forall_lt_one_mul_le
#align le_iff_forall_neg_add_le le_iff_forall_neg_add_le
-/

end DenselyOrdered

