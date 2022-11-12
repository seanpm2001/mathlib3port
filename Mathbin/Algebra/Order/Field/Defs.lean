/-
Copyright (c) 2014 Robert Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Lewis, Leonardo de Moura, Mario Carneiro, Floris van Doorn
-/
import Mathbin.Algebra.Field.Defs
import Mathbin.Algebra.Order.Ring.Defs

/-!
# Linear ordered (semi)fields

A linear ordered (semi)field is a (semi)field equipped with a linear order such that
* addition respects the order: `a ≤ b → c + a ≤ c + b`;
* multiplication of positives is positive: `0 < a → 0 < b → 0 < a * b`;
* `0 < 1`.

## Main Definitions

* `linear_ordered_semifield`: Typeclass for linear order semifields.
* `linear_ordered_field`: Typeclass for linear ordered fields.

## Implementation details

For olean caching reasons, this file is separate to the main file, `algebra.order.field.basic`.
The lemmata are instead located there.

-/


variable {α : Type _}

/-- A linear ordered semifield is a field with a linear order respecting the operations. -/
@[protect_proj]
class LinearOrderedSemifield (α : Type _) extends LinearOrderedCommSemiring α, Semifield α
#align linear_ordered_semifield LinearOrderedSemifield

/-- A linear ordered field is a field with a linear order respecting the operations. -/
@[protect_proj]
class LinearOrderedField (α : Type _) extends LinearOrderedCommRing α, Field α
#align linear_ordered_field LinearOrderedField

-- See note [lower instance priority]
instance (priority := 100) LinearOrderedField.toLinearOrderedSemifield [LinearOrderedField α] :
    LinearOrderedSemifield α :=
  { LinearOrderedRing.toLinearOrderedSemiring, ‹LinearOrderedField α› with }
#align linear_ordered_field.to_linear_ordered_semifield LinearOrderedField.toLinearOrderedSemifield

