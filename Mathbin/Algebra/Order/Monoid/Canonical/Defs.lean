/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.monoid.canonical.defs
! leanprover-community/mathlib commit e8638a0fcaf73e4500469f368ef9494e495099b3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.BoundedOrder
import Mathbin.Order.MinMax
import Mathbin.Algebra.NeZero
import Mathbin.Algebra.Order.Monoid.Defs

/-!
# Canonically ordered monoids

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


universe u

variable {α : Type u}

#print ExistsMulOfLE /-
/-- An `ordered_comm_monoid` with one-sided 'division' in the sense that
if `a ≤ b`, there is some `c` for which `a * c = b`. This is a weaker version
of the condition on canonical orderings defined by `canonically_ordered_monoid`. -/
class ExistsMulOfLE (α : Type u) [Mul α] [LE α] : Prop where
  exists_mul_of_le : ∀ {a b : α}, a ≤ b → ∃ c : α, b = a * c
#align has_exists_mul_of_le ExistsMulOfLE
-/

#print ExistsAddOfLE /-
/-- An `ordered_add_comm_monoid` with one-sided 'subtraction' in the sense that
if `a ≤ b`, then there is some `c` for which `a + c = b`. This is a weaker version
of the condition on canonical orderings defined by `canonically_ordered_add_monoid`. -/
class ExistsAddOfLE (α : Type u) [Add α] [LE α] : Prop where
  exists_add_of_le : ∀ {a b : α}, a ≤ b → ∃ c : α, b = a + c
#align has_exists_add_of_le ExistsAddOfLE
-/

attribute [to_additive] ExistsMulOfLE

export ExistsMulOfLE (exists_mul_of_le)

export ExistsAddOfLE (exists_add_of_le)

#print Group.existsMulOfLE /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) Group.existsMulOfLE (α : Type u) [Group α] [LE α] : ExistsMulOfLE α :=
  ⟨fun a b hab => ⟨a⁻¹ * b, (mul_inv_cancel_left _ _).symm⟩⟩
#align group.has_exists_mul_of_le Group.existsMulOfLE
#align add_group.has_exists_add_of_le AddGroup.existsAddOfLE
-/

section MulOneClass

variable [MulOneClass α] [Preorder α] [ContravariantClass α α (· * ·) (· < ·)] [ExistsMulOfLE α]
  {a b : α}

#print exists_one_lt_mul_of_lt' /-
@[to_additive]
theorem exists_one_lt_mul_of_lt' (h : a < b) : ∃ c, 1 < c ∧ a * c = b := by
  obtain ⟨c, rfl⟩ := exists_mul_of_le h.le; exact ⟨c, one_lt_of_lt_mul_right h, rfl⟩
#align exists_one_lt_mul_of_lt' exists_one_lt_mul_of_lt'
#align exists_pos_add_of_lt' exists_pos_add_of_lt'
-/

end MulOneClass

section ExistsMulOfLE

variable [LinearOrder α] [DenselyOrdered α] [Monoid α] [ExistsMulOfLE α]
  [CovariantClass α α (· * ·) (· < ·)] [ContravariantClass α α (· * ·) (· < ·)] {a b : α}

#print le_of_forall_one_lt_le_mul /-
@[to_additive]
theorem le_of_forall_one_lt_le_mul (h : ∀ ε : α, 1 < ε → a ≤ b * ε) : a ≤ b :=
  le_of_forall_le_of_dense fun x hxb =>
    by
    obtain ⟨ε, rfl⟩ := exists_mul_of_le hxb.le
    exact h _ ((lt_mul_iff_one_lt_right' b).1 hxb)
#align le_of_forall_one_lt_le_mul le_of_forall_one_lt_le_mul
#align le_of_forall_pos_le_add le_of_forall_pos_le_add
-/

#print le_of_forall_one_lt_lt_mul' /-
@[to_additive]
theorem le_of_forall_one_lt_lt_mul' (h : ∀ ε : α, 1 < ε → a < b * ε) : a ≤ b :=
  le_of_forall_one_lt_le_mul fun ε hε => (h _ hε).le
#align le_of_forall_one_lt_lt_mul' le_of_forall_one_lt_lt_mul'
#align le_of_forall_pos_lt_add' le_of_forall_pos_lt_add'
-/

#print le_iff_forall_one_lt_lt_mul' /-
@[to_additive]
theorem le_iff_forall_one_lt_lt_mul' : a ≤ b ↔ ∀ ε, 1 < ε → a < b * ε :=
  ⟨fun h ε => lt_mul_of_le_of_one_lt h, le_of_forall_one_lt_lt_mul'⟩
#align le_iff_forall_one_lt_lt_mul' le_iff_forall_one_lt_lt_mul'
#align le_iff_forall_pos_lt_add' le_iff_forall_pos_lt_add'
-/

end ExistsMulOfLE

#print CanonicallyOrderedAddMonoid /-
/-- A canonically ordered additive monoid is an ordered commutative additive monoid
  in which the ordering coincides with the subtractibility relation,
  which is to say, `a ≤ b` iff there exists `c` with `b = a + c`.
  This is satisfied by the natural numbers, for example, but not
  the integers or other nontrivial `ordered_add_comm_group`s. -/
@[protect_proj]
class CanonicallyOrderedAddMonoid (α : Type _) extends OrderedAddCommMonoid α, Bot α where
  bot_le : ∀ x : α, ⊥ ≤ x
  exists_add_of_le : ∀ {a b : α}, a ≤ b → ∃ c, b = a + c
  le_self_add : ∀ a b : α, a ≤ a + b
#align canonically_ordered_add_monoid CanonicallyOrderedAddMonoid
-/

#print CanonicallyOrderedAddMonoid.toOrderBot /-
-- see Note [lower instance priority]
instance (priority := 100) CanonicallyOrderedAddMonoid.toOrderBot (α : Type u)
    [h : CanonicallyOrderedAddMonoid α] : OrderBot α :=
  { h with }
#align canonically_ordered_add_monoid.to_order_bot CanonicallyOrderedAddMonoid.toOrderBot
-/

#print CanonicallyOrderedMonoid /-
/-- A canonically ordered monoid is an ordered commutative monoid
  in which the ordering coincides with the divisibility relation,
  which is to say, `a ≤ b` iff there exists `c` with `b = a * c`.
  Examples seem rare; it seems more likely that the `order_dual`
  of a naturally-occurring lattice satisfies this than the lattice
  itself (for example, dual of the lattice of ideals of a PID or
  Dedekind domain satisfy this; collections of all things ≤ 1 seem to
  be more natural that collections of all things ≥ 1).
-/
@[protect_proj, to_additive]
class CanonicallyOrderedMonoid (α : Type _) extends OrderedCommMonoid α, Bot α where
  bot_le : ∀ x : α, ⊥ ≤ x
  exists_mul_of_le : ∀ {a b : α}, a ≤ b → ∃ c, b = a * c
  le_self_mul : ∀ a b : α, a ≤ a * b
#align canonically_ordered_monoid CanonicallyOrderedMonoid
#align canonically_ordered_add_monoid CanonicallyOrderedAddMonoid
-/

#print CanonicallyOrderedMonoid.toOrderBot /-
-- see Note [lower instance priority]
@[to_additive]
instance (priority := 100) CanonicallyOrderedMonoid.toOrderBot (α : Type u)
    [h : CanonicallyOrderedMonoid α] : OrderBot α :=
  { h with }
#align canonically_ordered_monoid.to_order_bot CanonicallyOrderedMonoid.toOrderBot
#align canonically_ordered_add_monoid.to_order_bot CanonicallyOrderedAddMonoid.toOrderBot
-/

#print CanonicallyOrderedMonoid.existsMulOfLE /-
-- see Note [lower instance priority]
@[to_additive]
instance (priority := 100) CanonicallyOrderedMonoid.existsMulOfLE (α : Type u)
    [h : CanonicallyOrderedMonoid α] : ExistsMulOfLE α :=
  { h with }
#align canonically_ordered_monoid.has_exists_mul_of_le CanonicallyOrderedMonoid.existsMulOfLE
#align canonically_ordered_add_monoid.has_exists_add_of_le CanonicallyOrderedAddMonoid.existsAddOfLE
-/

section CanonicallyOrderedMonoid

variable [CanonicallyOrderedMonoid α] {a b c d : α}

#print le_self_mul /-
@[to_additive]
theorem le_self_mul : a ≤ a * c :=
  CanonicallyOrderedMonoid.le_self_mul _ _
#align le_self_mul le_self_mul
#align le_self_add le_self_add
-/

#print le_mul_self /-
@[to_additive]
theorem le_mul_self : a ≤ b * a := by rw [mul_comm]; exact le_self_mul
#align le_mul_self le_mul_self
#align le_add_self le_add_self
-/

#print self_le_mul_right /-
@[to_additive]
theorem self_le_mul_right (a b : α) : a ≤ a * b :=
  le_self_mul
#align self_le_mul_right self_le_mul_right
#align self_le_add_right self_le_add_right
-/

#print self_le_mul_left /-
@[to_additive]
theorem self_le_mul_left (a b : α) : a ≤ b * a :=
  le_mul_self
#align self_le_mul_left self_le_mul_left
#align self_le_add_left self_le_add_left
-/

#print le_of_mul_le_left /-
@[to_additive]
theorem le_of_mul_le_left : a * b ≤ c → a ≤ c :=
  le_self_mul.trans
#align le_of_mul_le_left le_of_mul_le_left
#align le_of_add_le_left le_of_add_le_left
-/

#print le_of_mul_le_right /-
@[to_additive]
theorem le_of_mul_le_right : a * b ≤ c → b ≤ c :=
  le_mul_self.trans
#align le_of_mul_le_right le_of_mul_le_right
#align le_of_add_le_right le_of_add_le_right
-/

#print le_mul_of_le_left /-
@[to_additive]
theorem le_mul_of_le_left : a ≤ b → a ≤ b * c :=
  le_self_mul.trans'
#align le_mul_of_le_left le_mul_of_le_left
#align le_add_of_le_left le_add_of_le_left
-/

#print le_mul_of_le_right /-
@[to_additive]
theorem le_mul_of_le_right : a ≤ c → a ≤ b * c :=
  le_mul_self.trans'
#align le_mul_of_le_right le_mul_of_le_right
#align le_add_of_le_right le_add_of_le_right
-/

#print le_iff_exists_mul /-
@[to_additive]
theorem le_iff_exists_mul : a ≤ b ↔ ∃ c, b = a * c :=
  ⟨exists_mul_of_le, by rintro ⟨c, rfl⟩; exact le_self_mul⟩
#align le_iff_exists_mul le_iff_exists_mul
#align le_iff_exists_add le_iff_exists_add
-/

#print le_iff_exists_mul' /-
@[to_additive]
theorem le_iff_exists_mul' : a ≤ b ↔ ∃ c, b = c * a := by
  simpa only [mul_comm _ a] using le_iff_exists_mul
#align le_iff_exists_mul' le_iff_exists_mul'
#align le_iff_exists_add' le_iff_exists_add'
-/

#print one_le /-
@[simp, to_additive zero_le]
theorem one_le (a : α) : 1 ≤ a :=
  le_iff_exists_mul.mpr ⟨a, (one_mul _).symm⟩
#align one_le one_le
#align zero_le zero_le
-/

#print bot_eq_one /-
@[to_additive]
theorem bot_eq_one : (⊥ : α) = 1 :=
  le_antisymm bot_le (one_le ⊥)
#align bot_eq_one bot_eq_one
#align bot_eq_zero bot_eq_zero
-/

#print mul_eq_one_iff /-
--TODO: This is a special case of `mul_eq_one`. We need the instance
-- `canonically_ordered_monoid α → unique αˣ`
@[simp, to_additive]
theorem mul_eq_one_iff : a * b = 1 ↔ a = 1 ∧ b = 1 :=
  mul_eq_one_iff' (one_le _) (one_le _)
#align mul_eq_one_iff mul_eq_one_iff
#align add_eq_zero_iff add_eq_zero_iff
-/

#print le_one_iff_eq_one /-
@[simp, to_additive]
theorem le_one_iff_eq_one : a ≤ 1 ↔ a = 1 :=
  (one_le a).le_iff_eq
#align le_one_iff_eq_one le_one_iff_eq_one
#align nonpos_iff_eq_zero nonpos_iff_eq_zero
-/

#print one_lt_iff_ne_one /-
@[to_additive]
theorem one_lt_iff_ne_one : 1 < a ↔ a ≠ 1 :=
  (one_le a).lt_iff_ne.trans ne_comm
#align one_lt_iff_ne_one one_lt_iff_ne_one
#align pos_iff_ne_zero pos_iff_ne_zero
-/

#print eq_one_or_one_lt /-
@[to_additive]
theorem eq_one_or_one_lt : a = 1 ∨ 1 < a :=
  (one_le a).eq_or_lt.imp_left Eq.symm
#align eq_one_or_one_lt eq_one_or_one_lt
#align eq_zero_or_pos eq_zero_or_pos
-/

#print one_lt_mul_iff /-
@[simp, to_additive add_pos_iff]
theorem one_lt_mul_iff : 1 < a * b ↔ 1 < a ∨ 1 < b := by
  simp only [one_lt_iff_ne_one, Ne.def, mul_eq_one_iff, not_and_or]
#align one_lt_mul_iff one_lt_mul_iff
#align add_pos_iff add_pos_iff
-/

#print exists_one_lt_mul_of_lt /-
@[to_additive]
theorem exists_one_lt_mul_of_lt (h : a < b) : ∃ (c : _) (hc : 1 < c), a * c = b :=
  by
  obtain ⟨c, hc⟩ := le_iff_exists_mul.1 h.le
  refine' ⟨c, one_lt_iff_ne_one.2 _, hc.symm⟩
  rintro rfl
  simpa [hc, lt_irrefl] using h
#align exists_one_lt_mul_of_lt exists_one_lt_mul_of_lt
#align exists_pos_add_of_lt exists_pos_add_of_lt
-/

#print le_mul_left /-
@[to_additive]
theorem le_mul_left (h : a ≤ c) : a ≤ b * c :=
  calc
    a = 1 * a := by simp
    _ ≤ b * c := mul_le_mul' (one_le _) h
#align le_mul_left le_mul_left
#align le_add_left le_add_left
-/

#print le_mul_right /-
@[to_additive]
theorem le_mul_right (h : a ≤ b) : a ≤ b * c :=
  calc
    a = a * 1 := by simp
    _ ≤ b * c := mul_le_mul' h (one_le _)
#align le_mul_right le_mul_right
#align le_add_right le_add_right
-/

#print lt_iff_exists_mul /-
@[to_additive]
theorem lt_iff_exists_mul [CovariantClass α α (· * ·) (· < ·)] : a < b ↔ ∃ c > 1, b = a * c :=
  by
  simp_rw [lt_iff_le_and_ne, and_comm', le_iff_exists_mul, ← exists_and_left, exists_prop]
  apply exists_congr; intro c
  rw [and_congr_left_iff, gt_iff_lt]; rintro rfl
  constructor
  · rw [one_lt_iff_ne_one]; apply mt; rintro rfl; rw [mul_one]
  · rw [← (self_le_mul_right a c).lt_iff_ne]; apply lt_mul_of_one_lt_right'
#align lt_iff_exists_mul lt_iff_exists_mul
#align lt_iff_exists_add lt_iff_exists_add
-/

end CanonicallyOrderedMonoid

#print pos_of_gt /-
theorem pos_of_gt {M : Type _} [CanonicallyOrderedAddMonoid M] {n m : M} (h : n < m) : 0 < m :=
  lt_of_le_of_lt (zero_le _) h
#align pos_of_gt pos_of_gt
-/

namespace NeZero

#print NeZero.pos /-
theorem pos {M} (a : M) [CanonicallyOrderedAddMonoid M] [NeZero a] : 0 < a :=
  (zero_le a).lt_of_ne <| NeZero.out.symm
#align ne_zero.pos NeZero.pos
-/

#print NeZero.of_gt /-
theorem of_gt {M} [CanonicallyOrderedAddMonoid M] {x y : M} (h : x < y) : NeZero y :=
  of_pos <| pos_of_gt h
#align ne_zero.of_gt NeZero.of_gt
-/

#print NeZero.of_gt' /-
-- 1 < p is still an often-used `fact`, due to `nat.prime` implying it, and it implying `nontrivial`
-- on `zmod`'s ring structure. We cannot just set this to be any `x < y`, else that becomes a
-- metavariable and it will hugely slow down typeclass inference.
instance (priority := 10) of_gt' {M} [CanonicallyOrderedAddMonoid M] [One M] {y : M}
    [Fact (1 < y)] : NeZero y :=
  of_gt <| Fact.out <| 1 < y
#align ne_zero.of_gt' NeZero.of_gt'
-/

#print NeZero.bit0 /-
instance bit0 {M} [CanonicallyOrderedAddMonoid M] {x : M} [NeZero x] : NeZero (bit0 x) :=
  of_pos <| bit0_pos <| NeZero.pos x
#align ne_zero.bit0 NeZero.bit0
-/

end NeZero

#print CanonicallyLinearOrderedAddMonoid /-
/-- A canonically linear-ordered additive monoid is a canonically ordered additive monoid
    whose ordering is a linear order. -/
@[protect_proj]
class CanonicallyLinearOrderedAddMonoid (α : Type _) extends CanonicallyOrderedAddMonoid α,
    LinearOrder α
#align canonically_linear_ordered_add_monoid CanonicallyLinearOrderedAddMonoid
-/

#print CanonicallyLinearOrderedMonoid /-
/-- A canonically linear-ordered monoid is a canonically ordered monoid
    whose ordering is a linear order. -/
@[protect_proj, to_additive]
class CanonicallyLinearOrderedMonoid (α : Type _) extends CanonicallyOrderedMonoid α, LinearOrder α
#align canonically_linear_ordered_monoid CanonicallyLinearOrderedMonoid
#align canonically_linear_ordered_add_monoid CanonicallyLinearOrderedAddMonoid
-/

section CanonicallyLinearOrderedMonoid

variable [CanonicallyLinearOrderedMonoid α]

#print CanonicallyLinearOrderedMonoid.semilatticeSup /-
-- see Note [lower instance priority]
@[to_additive]
instance (priority := 100) CanonicallyLinearOrderedMonoid.semilatticeSup : SemilatticeSup α :=
  { LinearOrder.toLattice with }
#align canonically_linear_ordered_monoid.semilattice_sup CanonicallyLinearOrderedMonoid.semilatticeSup
#align canonically_linear_ordered_add_monoid.semilattice_sup CanonicallyLinearOrderedAddMonoid.semilatticeSup
-/

#print min_mul_distrib /-
@[to_additive]
theorem min_mul_distrib (a b c : α) : min a (b * c) = min a (min a b * min a c) :=
  by
  cases' le_total a b with hb hb
  · simp [hb, le_mul_right]
  · cases' le_total a c with hc hc
    · simp [hc, le_mul_left]
    · simp [hb, hc]
#align min_mul_distrib min_mul_distrib
#align min_add_distrib min_add_distrib
-/

#print min_mul_distrib' /-
@[to_additive]
theorem min_mul_distrib' (a b c : α) : min (a * b) c = min (min a c * min b c) c := by
  simpa [min_comm _ c] using min_mul_distrib c a b
#align min_mul_distrib' min_mul_distrib'
#align min_add_distrib' min_add_distrib'
-/

#print one_min /-
@[simp, to_additive]
theorem one_min (a : α) : min 1 a = 1 :=
  min_eq_left (one_le a)
#align one_min one_min
#align zero_min zero_min
-/

#print min_one /-
@[simp, to_additive]
theorem min_one (a : α) : min a 1 = 1 :=
  min_eq_right (one_le a)
#align min_one min_one
#align min_zero min_zero
-/

#print bot_eq_one' /-
/-- In a linearly ordered monoid, we are happy for `bot_eq_one` to be a `@[simp]` lemma. -/
@[simp,
  to_additive
      "In a linearly ordered monoid, we are happy for `bot_eq_zero` to be a `@[simp]` lemma"]
theorem bot_eq_one' : (⊥ : α) = 1 :=
  bot_eq_one
#align bot_eq_one' bot_eq_one'
#align bot_eq_zero' bot_eq_zero'
-/

end CanonicallyLinearOrderedMonoid

