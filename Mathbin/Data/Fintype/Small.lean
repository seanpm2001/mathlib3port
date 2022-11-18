/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Mathbin.Data.Fintype.Card
import Mathbin.Logic.Small.Basic

/-!
# All finite types are small.

That is, any `α` with `[fintype α]` is equivalent to a type in any universe.

-/


universe w v

instance (priority := 100) small_of_fintype (α : Type v) [Fintype α] : Small.{w} α := by
  rw [small_congr (Fintype.equivFin α)]
  infer_instance
#align small_of_fintype small_of_fintype

