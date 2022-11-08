/-
Copyright (c) 2014 Robert Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Mathbin.Algebra.Order.Field.Basic
import Mathbin.Data.Fintype.Basic

/-!
# Lemmas about (finite domain) functions into fields.

We split this from `algebra.order.field.basic` to avoid importing the finiteness hierarchy there.
-/


variable {α ι : Type _} [LinearOrderedSemifield α]

theorem Pi.exists_forall_pos_add_lt [HasExistsAddOfLe α] [Finite ι] {x y : ι → α} (h : ∀ i, x i < y i) :
    ∃ ε, 0 < ε ∧ ∀ i, x i + ε < y i := by
  cases nonempty_fintype ι
  cases is_empty_or_nonempty ι
  · exact ⟨1, zero_lt_one, isEmptyElim⟩
    
  choose ε hε hxε using fun i => exists_pos_add_of_lt' (h i)
  obtain rfl : x + ε = y := funext hxε
  have hε : 0 < finset.univ.inf' Finset.univ_nonempty ε := (Finset.lt_inf'_iff _).2 fun i _ => hε _
  exact
    ⟨_, half_pos hε, fun i => add_lt_add_left ((half_lt_self hε).trans_le <| Finset.inf'_le _ <| Finset.mem_univ _) _⟩

