/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Yury Kudryashov

! This file was ported from Lean 3 source module algebra.order.group.bounds
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Bounds.Basic
import Mathbin.Algebra.Order.Group.Defs

/-!
# Least upper bound and the greatest lower bound in linear ordered additive commutative groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


variable {α : Type _}

section LinearOrderedAddCommGroup

variable [LinearOrderedAddCommGroup α] {s : Set α} {a ε : α}

#print IsGLB.exists_between_self_add /-
theorem IsGLB.exists_between_self_add (h : IsGLB s a) (hε : 0 < ε) : ∃ b ∈ s, a ≤ b ∧ b < a + ε :=
  h.exists_between <| lt_add_of_pos_right _ hε
#align is_glb.exists_between_self_add IsGLB.exists_between_self_add
-/

#print IsGLB.exists_between_self_add' /-
theorem IsGLB.exists_between_self_add' (h : IsGLB s a) (h₂ : a ∉ s) (hε : 0 < ε) :
    ∃ b ∈ s, a < b ∧ b < a + ε :=
  h.exists_between' h₂ <| lt_add_of_pos_right _ hε
#align is_glb.exists_between_self_add' IsGLB.exists_between_self_add'
-/

#print IsLUB.exists_between_sub_self /-
theorem IsLUB.exists_between_sub_self (h : IsLUB s a) (hε : 0 < ε) : ∃ b ∈ s, a - ε < b ∧ b ≤ a :=
  h.exists_between <| sub_lt_self _ hε
#align is_lub.exists_between_sub_self IsLUB.exists_between_sub_self
-/

#print IsLUB.exists_between_sub_self' /-
theorem IsLUB.exists_between_sub_self' (h : IsLUB s a) (h₂ : a ∉ s) (hε : 0 < ε) :
    ∃ b ∈ s, a - ε < b ∧ b < a :=
  h.exists_between' h₂ <| sub_lt_self _ hε
#align is_lub.exists_between_sub_self' IsLUB.exists_between_sub_self'
-/

end LinearOrderedAddCommGroup

