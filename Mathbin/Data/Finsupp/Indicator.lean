/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module data.finsupp.indicator
! leanprover-community/mathlib commit 842328d9df7e96fd90fc424e115679c15fb23a71
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finsupp.Defs

/-!
# Building finitely supported functions off finsets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines `finsupp.indicator` to help create finsupps from finsets.

## Main declarations

* `finsupp.indicator`: Turns a map from a `finset` into a `finsupp` from the entire type.
-/


noncomputable section

open Finset Function

variable {ι α : Type _}

namespace Finsupp

variable [Zero α] {s : Finset ι} (f : ∀ i ∈ s, α) {i : ι}

#print Finsupp.indicator /-
/-- Create an element of `ι →₀ α` from a finset `s` and a function `f` defined on this finset. -/
def indicator (s : Finset ι) (f : ∀ i ∈ s, α) : ι →₀ α
    where
  toFun i :=
    haveI := Classical.decEq ι
    if H : i ∈ s then f i H else 0
  support :=
    haveI := Classical.decEq α
    (s.attach.filter fun i : s => f i.1 i.2 ≠ 0).map (embedding.subtype _)
  mem_support_toFun i := by
    letI := Classical.decEq α
    rw [mem_map, dite_ne_right_iff]
    exact
      ⟨fun ⟨⟨j, hj⟩, hf, rfl⟩ => ⟨hj, (mem_filter.1 hf).2⟩, fun ⟨hi, hf⟩ =>
        ⟨⟨i, hi⟩, mem_filter.2 <| ⟨mem_attach _ _, hf⟩, rfl⟩⟩
#align finsupp.indicator Finsupp.indicator
-/

#print Finsupp.indicator_of_mem /-
theorem indicator_of_mem (hi : i ∈ s) (f : ∀ i ∈ s, α) : indicator s f i = f i hi :=
  @dif_pos _ (id _) hi _ _ _
#align finsupp.indicator_of_mem Finsupp.indicator_of_mem
-/

#print Finsupp.indicator_of_not_mem /-
theorem indicator_of_not_mem (hi : i ∉ s) (f : ∀ i ∈ s, α) : indicator s f i = 0 :=
  @dif_neg _ (id _) hi _ _ _
#align finsupp.indicator_of_not_mem Finsupp.indicator_of_not_mem
-/

variable (s i)

#print Finsupp.indicator_apply /-
@[simp]
theorem indicator_apply [DecidableEq ι] : indicator s f i = if hi : i ∈ s then f i hi else 0 := by
  convert rfl
#align finsupp.indicator_apply Finsupp.indicator_apply
-/

#print Finsupp.indicator_injective /-
theorem indicator_injective : Injective fun f : ∀ i ∈ s, α => indicator s f :=
  by
  intro a b h
  ext i hi
  rw [← indicator_of_mem hi a, ← indicator_of_mem hi b]
  exact congr_fun h i
#align finsupp.indicator_injective Finsupp.indicator_injective
-/

#print Finsupp.support_indicator_subset /-
theorem support_indicator_subset : ((indicator s f).support : Set ι) ⊆ s :=
  by
  intro i hi
  rw [mem_coe, mem_support_iff] at hi 
  by_contra
  exact hi (indicator_of_not_mem h _)
#align finsupp.support_indicator_subset Finsupp.support_indicator_subset
-/

#print Finsupp.single_eq_indicator /-
theorem single_eq_indicator (i : ι) (b : α) : single i b = indicator {i} fun _ _ => b := by
  classical
  ext
  simp [single_apply, indicator_apply, @eq_comm _ a]
#align finsupp.single_eq_indicator Finsupp.single_eq_indicator
-/

end Finsupp

