/-
Copyright (c) 2021 Eric Rodriguez. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Rodriguez
-/
import Mathbin.Data.Fintype.Card
import Mathbin.Logic.Equiv.Fin
import Mathbin.Logic.Equiv.Embedding

/-!
# Number of embeddings

This file establishes the cardinality of `α ↪ β` in full generality.
-/


-- mathport name: finset.card
local notation "|" x "|" => Finset.card x

-- mathport name: fintype.card
local notation "‖" x "‖" => Fintype.card x

open Function

open Nat BigOperators

namespace Fintype

theorem card_embedding_eq_of_unique {α β : Type _} [Unique α] [Fintype β] [Fintype (α ↪ β)] : ‖α ↪ β‖ = ‖β‖ :=
  card_congr Equiv.uniqueEmbeddingEquivResult
#align fintype.card_embedding_eq_of_unique Fintype.card_embedding_eq_of_unique

-- Establishes the cardinality of the type of all injections between two finite types.
@[simp]
theorem card_embedding_eq {α β} [Fintype α] [Fintype β] [Fintype (α ↪ β)] : ‖α ↪ β‖ = ‖β‖.descFactorial ‖α‖ := by
  classical induction' ‹Fintype α› using Fintype.induction_empty_option with α₁ α₂ h₂ e ih α h ih
    · rw [card_pempty, Nat.desc_factorial_zero, card_eq_one_iff]
      exact ⟨embedding.of_is_empty, fun x => FunLike.ext _ _ isEmptyElim⟩
      
#align fintype.card_embedding_eq Fintype.card_embedding_eq

/- The cardinality of embeddings from an infinite type to a finite type is zero.
This is a re-statement of the pigeonhole principle. -/
@[simp]
theorem card_embedding_eq_of_infinite {α β : Type _} [Infinite α] [Fintype β] [Fintype (α ↪ β)] : ‖α ↪ β‖ = 0 :=
  card_eq_zero
#align fintype.card_embedding_eq_of_infinite Fintype.card_embedding_eq_of_infinite

end Fintype

