/-
Copyright (c) 2021 Henry Swanson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Henry Swanson

! This file was ported from Lean 3 source module combinatorics.derangements.finite
! leanprover-community/mathlib commit 31ca6f9cf5f90a6206092cd7f84b359dcb6d52e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Combinatorics.Derangements.Basic
import Mathbin.Data.Fintype.BigOperators
import Mathbin.Tactic.DeltaInstance
import Mathbin.Tactic.Ring

/-!
# Derangements on fintypes

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains lemmas that describe the cardinality of `derangements α` when `α` is a fintype.

# Main definitions

* `card_derangements_invariant`: A lemma stating that the number of derangements on a type `α`
    depends only on the cardinality of `α`.
* `num_derangements n`: The number of derangements on an n-element set, defined in a computation-
    friendly way.
* `card_derangements_eq_num_derangements`: Proof that `num_derangements` really does compute the
    number of derangements.
* `num_derangements_sum`: A lemma giving an expression for `num_derangements n` in terms of
    factorials.
-/


open derangements Equiv Fintype

open scoped BigOperators

variable {α : Type _} [DecidableEq α] [Fintype α]

instance : DecidablePred (derangements α) := fun _ => Fintype.decidableForallFintype

instance : Fintype (derangements α) := by delta_instance derangements

#print card_derangements_invariant /-
theorem card_derangements_invariant {α β : Type _} [Fintype α] [DecidableEq α] [Fintype β]
    [DecidableEq β] (h : card α = card β) : card (derangements α) = card (derangements β) :=
  Fintype.card_congr (Equiv.derangementsCongr <| equivOfCardEq h)
#align card_derangements_invariant card_derangements_invariant
-/

#print card_derangements_fin_add_two /-
theorem card_derangements_fin_add_two (n : ℕ) :
    card (derangements (Fin (n + 2))) =
      (n + 1) * card (derangements (Fin n)) + (n + 1) * card (derangements (Fin (n + 1))) :=
  by
  -- get some basic results about the size of fin (n+1) plus or minus an element
  have h1 : ∀ a : Fin (n + 1), card ({a}ᶜ : Set (Fin (n + 1))) = card (Fin n) :=
    by
    intro a
    simp only [Fintype.card_fin, Finset.card_fin, Fintype.card_ofFinset, Finset.filter_ne' _ a,
      Set.mem_compl_singleton_iff, Finset.card_erase_of_mem (Finset.mem_univ a),
      add_tsub_cancel_right]
  have h2 : card (Fin (n + 2)) = card (Option (Fin (n + 1))) := by simp only [card_fin, card_option]
  -- rewrite the LHS and substitute in our fintype-level equivalence
  simp only [card_derangements_invariant h2,
    card_congr
      (@derangements_recursion_equiv (Fin (n + 1))
        _),-- push the cardinality through the Σ and ⊕ so that we can use `card_n`
    card_sigma,
    card_sum, card_derangements_invariant (h1 _), Finset.sum_const, nsmul_eq_mul, Finset.card_fin,
    mul_add, Nat.cast_id]
#align card_derangements_fin_add_two card_derangements_fin_add_two
-/

#print numDerangements /-
/-- The number of derangements of an `n`-element set. -/
def numDerangements : ℕ → ℕ
  | 0 => 1
  | 1 => 0
  | n + 2 => (n + 1) * (numDerangements n + numDerangements (n + 1))
#align num_derangements numDerangements
-/

#print numDerangements_zero /-
@[simp]
theorem numDerangements_zero : numDerangements 0 = 1 :=
  rfl
#align num_derangements_zero numDerangements_zero
-/

#print numDerangements_one /-
@[simp]
theorem numDerangements_one : numDerangements 1 = 0 :=
  rfl
#align num_derangements_one numDerangements_one
-/

#print numDerangements_add_two /-
theorem numDerangements_add_two (n : ℕ) :
    numDerangements (n + 2) = (n + 1) * (numDerangements n + numDerangements (n + 1)) :=
  rfl
#align num_derangements_add_two numDerangements_add_two
-/

#print numDerangements_succ /-
theorem numDerangements_succ (n : ℕ) :
    (numDerangements (n + 1) : ℤ) = (n + 1) * (numDerangements n : ℤ) - (-1) ^ n :=
  by
  induction' n with n hn
  · rfl
  · simp only [numDerangements_add_two, hn, pow_succ, Int.ofNat_mul, Int.ofNat_add, Int.ofNat_succ]
    ring
#align num_derangements_succ numDerangements_succ
-/

#print card_derangements_fin_eq_numDerangements /-
theorem card_derangements_fin_eq_numDerangements {n : ℕ} :
    card (derangements (Fin n)) = numDerangements n :=
  by
  induction' n using Nat.strong_induction_on with n hyp
  obtain _ | _ | n := n; · rfl; · rfl
  -- knock out cases 0 and 1
  -- now we have n ≥ 2. rewrite everything in terms of card_derangements, so that we can use
  -- `card_derangements_fin_add_two`
  rw [numDerangements_add_two, card_derangements_fin_add_two, mul_add,
    hyp _ (Nat.lt_add_of_pos_right zero_lt_two), hyp _ (lt_add_one _)]
#align card_derangements_fin_eq_num_derangements card_derangements_fin_eq_numDerangements
-/

#print card_derangements_eq_numDerangements /-
theorem card_derangements_eq_numDerangements (α : Type _) [Fintype α] [DecidableEq α] :
    card (derangements α) = numDerangements (card α) :=
  by
  rw [← card_derangements_invariant (card_fin _)]
  exact card_derangements_fin_eq_numDerangements
#align card_derangements_eq_num_derangements card_derangements_eq_numDerangements
-/

#print numDerangements_sum /-
theorem numDerangements_sum (n : ℕ) :
    (numDerangements n : ℤ) =
      ∑ k in Finset.range (n + 1), (-1 : ℤ) ^ k * Nat.ascFactorial k (n - k) :=
  by
  induction' n with n hn; · rfl
  rw [Finset.sum_range_succ, numDerangements_succ, hn, Finset.mul_sum, tsub_self,
    Nat.ascFactorial_zero, Int.ofNat_one, mul_one, pow_succ, neg_one_mul, sub_eq_add_neg,
    add_left_inj, Finset.sum_congr rfl]
  -- show that (n + 1) * (-1)^x * asc_fac x (n - x) = (-1)^x * asc_fac x (n.succ - x)
  intro x hx
  have h_le : x ≤ n := finset.mem_range_succ_iff.mp hx
  rw [Nat.succ_sub h_le, Nat.ascFactorial_succ, add_tsub_cancel_of_le h_le, Int.ofNat_mul,
    Int.ofNat_succ, mul_left_comm]
#align num_derangements_sum numDerangements_sum
-/

