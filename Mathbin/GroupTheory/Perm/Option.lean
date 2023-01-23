/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module group_theory.perm.option
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Perm
import Mathbin.GroupTheory.Perm.Sign
import Mathbin.Logic.Equiv.Option

/-!
# Permutations of `option α`
-/


open Equiv

@[simp]
theorem Equiv.optionCongr_one {α : Type _} : (1 : Perm α).optionCongr = 1 :=
  Equiv.optionCongr_refl
#align equiv.option_congr_one Equiv.optionCongr_one

@[simp]
theorem Equiv.optionCongr_swap {α : Type _} [DecidableEq α] (x y : α) :
    optionCongr (swap x y) = swap (some x) (some y) :=
  by
  ext (_ | i)
  · simp [swap_apply_of_ne_of_ne]
  · by_cases hx : i = x
    simp [hx, swap_apply_of_ne_of_ne]
    by_cases hy : i = y <;> simp [hx, hy, swap_apply_of_ne_of_ne]
#align equiv.option_congr_swap Equiv.optionCongr_swap

@[simp]
theorem Equiv.optionCongr_sign {α : Type _} [DecidableEq α] [Fintype α] (e : Perm α) :
    Perm.sign e.optionCongr = Perm.sign e :=
  by
  apply perm.swap_induction_on e
  · simp [perm.one_def]
  · intro f x y hne h
    simp [h, hne, perm.mul_def, ← Equiv.optionCongr_trans]
#align equiv.option_congr_sign Equiv.optionCongr_sign

@[simp]
theorem map_equiv_removeNone {α : Type _} [DecidableEq α] (σ : Perm (Option α)) :
    (removeNone σ).optionCongr = swap none (σ none) * σ :=
  by
  ext1 x
  have : Option.map (⇑(remove_none σ)) x = (swap none (σ none)) (σ x) :=
    by
    cases x
    · simp
    · cases h : σ (some x)
      · simp [remove_none_none _ h]
      · have hn : σ (some x) ≠ none := by simp [h]
        have hσn : σ (some x) ≠ σ none := σ.injective.ne (by simp)
        simp [remove_none_some _ ⟨_, h⟩, ← h, swap_apply_of_ne_of_ne hn hσn]
  simpa using this
#align map_equiv_remove_none map_equiv_removeNone

/-- Permutations of `option α` are equivalent to fixing an
`option α` and permuting the remaining with a `perm α`.
The fixed `option α` is swapped with `none`. -/
@[simps]
def Equiv.Perm.decomposeOption {α : Type _} [DecidableEq α] : Perm (Option α) ≃ Option α × Perm α
    where
  toFun σ := (σ none, removeNone σ)
  invFun i := swap none i.1 * i.2.optionCongr
  left_inv σ := by simp
  right_inv := fun ⟨x, σ⟩ =>
    by
    have : remove_none (swap none x * σ.option_congr) = σ :=
      Equiv.optionCongr_injective (by simp [← mul_assoc])
    simp [← perm.eq_inv_iff_eq, this]
#align equiv.perm.decompose_option Equiv.Perm.decomposeOption

theorem Equiv.Perm.decomposeOption_symm_of_none_apply {α : Type _} [DecidableEq α] (e : Perm α)
    (i : Option α) : Equiv.Perm.decomposeOption.symm (none, e) i = i.map e := by simp
#align equiv.perm.decompose_option_symm_of_none_apply Equiv.Perm.decomposeOption_symm_of_none_apply

theorem Equiv.Perm.decomposeOption_symm_sign {α : Type _} [DecidableEq α] [Fintype α] (e : Perm α) :
    Perm.sign (Equiv.Perm.decomposeOption.symm (none, e)) = Perm.sign e := by simp
#align equiv.perm.decompose_option_symm_sign Equiv.Perm.decomposeOption_symm_sign

/-- The set of all permutations of `option α` can be constructed by augmenting the set of
permutations of `α` by each element of `option α` in turn. -/
theorem Finset.univ_perm_option {α : Type _} [DecidableEq α] [Fintype α] :
    @Finset.univ (perm <| Option α) _ =
      (Finset.univ : Finset <| Option α × Perm α).map Equiv.Perm.decomposeOption.symm.toEmbedding :=
  (Finset.univ_map_equiv_to_embedding _).symm
#align finset.univ_perm_option Finset.univ_perm_option

