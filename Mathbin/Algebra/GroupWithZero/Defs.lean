/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin
-/
import Mathbin.Algebra.Group.Defs
import Mathbin.Logic.Nontrivial

/-!
# Typeclasses for groups with an adjoined zero element

This file provides just the typeclass definitions, and the projection lemmas that expose their
members.

## Main definitions

* `group_with_zero`
* `comm_group_with_zero`
-/


universe u

-- We have to fix the universe of `G₀` here, since the default argument to
-- `group_with_zero.div'` cannot contain a universe metavariable.
variable {G₀ : Type u} {M₀ M₀' G₀' : Type _}

section

#print MulZeroClass /-
/-- Typeclass for expressing that a type `M₀` with multiplication and a zero satisfies
`0 * a = 0` and `a * 0 = 0` for all `a : M₀`. -/
@[protect_proj]
class MulZeroClass (M₀ : Type _) extends Mul M₀, Zero M₀ where
  zero_mul : ∀ a : M₀, 0 * a = 0
  mul_zero : ∀ a : M₀, a * 0 = 0
-/

section MulZeroClass

variable [MulZeroClass M₀] {a b : M₀}

@[ematch, simp]
theorem zero_mul (a : M₀) : 0 * a = 0 :=
  MulZeroClass.zero_mul a

@[ematch, simp]
theorem mul_zero (a : M₀) : a * 0 = 0 :=
  MulZeroClass.mul_zero a

end MulZeroClass

/-- Predicate typeclass for expressing that `a * b = 0` implies `a = 0` or `b = 0`
for all `a` and `b` of type `G₀`. -/
class NoZeroDivisors (M₀ : Type _) [Mul M₀] [Zero M₀] : Prop where
  eq_zero_or_eq_zero_of_mul_eq_zero : ∀ {a b : M₀}, a * b = 0 → a = 0 ∨ b = 0

export NoZeroDivisors (eq_zero_or_eq_zero_of_mul_eq_zero)

#print SemigroupWithZero /-
/-- A type `S₀` is a "semigroup with zero” if it is a semigroup with zero element, and `0` is left
and right absorbing. -/
@[protect_proj]
class SemigroupWithZero (S₀ : Type _) extends Semigroup S₀, MulZeroClass S₀
-/

#print MulZeroOneClass /-
/- By defining this _after_ `semigroup_with_zero`, we ensure that searches for `mul_zero_class` find
this class first. -/
/-- A typeclass for non-associative monoids with zero elements. -/
@[protect_proj]
class MulZeroOneClass (M₀ : Type _) extends MulOneClass M₀, MulZeroClass M₀
-/

#print MonoidWithZero /-
/-- A type `M₀` is a “monoid with zero” if it is a monoid with zero element, and `0` is left
and right absorbing. -/
@[protect_proj]
class MonoidWithZero (M₀ : Type _) extends Monoid M₀, MulZeroOneClass M₀
-/

#print MonoidWithZero.toSemigroupWithZero /-
-- see Note [lower instance priority]
instance (priority := 100) MonoidWithZero.toSemigroupWithZero (M₀ : Type _) [MonoidWithZero M₀] :
    SemigroupWithZero M₀ :=
  { ‹MonoidWithZero M₀› with }
-/

/-- A type `M` is a `cancel_monoid_with_zero` if it is a monoid with zero element, `0` is left
and right absorbing, and left/right multiplication by a non-zero element is injective. -/
@[protect_proj]
class CancelMonoidWithZero (M₀ : Type _) extends MonoidWithZero M₀ where
  mul_left_cancel_of_ne_zero : ∀ {a b c : M₀}, a ≠ 0 → a * b = a * c → b = c
  mul_right_cancel_of_ne_zero : ∀ {a b c : M₀}, b ≠ 0 → a * b = c * b → a = c

section CancelMonoidWithZero

variable [CancelMonoidWithZero M₀] {a b c : M₀}

theorem mul_left_cancel₀ (ha : a ≠ 0) (h : a * b = a * c) : b = c :=
  CancelMonoidWithZero.mul_left_cancel_of_ne_zero ha h

theorem mul_right_cancel₀ (hb : b ≠ 0) (h : a * b = c * b) : a = c :=
  CancelMonoidWithZero.mul_right_cancel_of_ne_zero hb h

theorem mul_right_injective₀ (ha : a ≠ 0) : Function.Injective ((· * ·) a) := fun b c => mul_left_cancel₀ ha

theorem mul_left_injective₀ (hb : b ≠ 0) : Function.Injective fun a => a * b := fun a c => mul_right_cancel₀ hb

end CancelMonoidWithZero

/-- A type `M` is a commutative “monoid with zero” if it is a commutative monoid with zero
element, and `0` is left and right absorbing. -/
@[protect_proj]
class CommMonoidWithZero (M₀ : Type _) extends CommMonoid M₀, MonoidWithZero M₀

/-- A type `M` is a `cancel_comm_monoid_with_zero` if it is a commutative monoid with zero element,
 `0` is left and right absorbing,
  and left/right multiplication by a non-zero element is injective. -/
@[protect_proj]
class CancelCommMonoidWithZero (M₀ : Type _) extends CommMonoidWithZero M₀, CancelMonoidWithZero M₀

#print GroupWithZero /-
/-- A type `G₀` is a “group with zero” if it is a monoid with zero element (distinct from `1`)
such that every nonzero element is invertible.
The type is required to come with an “inverse” function, and the inverse of `0` must be `0`.

Examples include division rings and the ordered monoids that are the
target of valuations in general valuation theory.-/
class GroupWithZero (G₀ : Type u) extends MonoidWithZero G₀, DivInvMonoid G₀, Nontrivial G₀ where
  inv_zero : (0 : G₀)⁻¹ = 0
  mul_inv_cancel : ∀ a : G₀, a ≠ 0 → a * a⁻¹ = 1
-/

section GroupWithZero

variable [GroupWithZero G₀]

@[simp]
theorem inv_zero : (0 : G₀)⁻¹ = 0 :=
  GroupWithZero.inv_zero

@[simp]
theorem mul_inv_cancel {a : G₀} (h : a ≠ 0) : a * a⁻¹ = 1 :=
  GroupWithZero.mul_inv_cancel a h

end GroupWithZero

/-- A type `G₀` is a commutative “group with zero”
if it is a commutative monoid with zero element (distinct from `1`)
such that every nonzero element is invertible.
The type is required to come with an “inverse” function, and the inverse of `0` must be `0`. -/
class CommGroupWithZero (G₀ : Type _) extends CommMonoidWithZero G₀, GroupWithZero G₀

end

