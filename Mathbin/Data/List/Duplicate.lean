/-
Copyright (c) 2021 Yakov Pechersky. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yakov Pechersky, Chris Hughes

! This file was ported from Lean 3 source module data.list.duplicate
! leanprover-community/mathlib commit f694c7dead66f5d4c80f446c796a5aad14707f0e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.Nodup

/-!
# List duplicates

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `list.duplicate x l : Prop` is an inductive property that holds when `x` is a duplicate in `l`

## Implementation details

In this file, `x ∈+ l` notation is shorthand for `list.duplicate x l`.

-/


variable {α : Type _}

namespace List

#print List.Duplicate /-
/-- Property that an element `x : α` of `l : list α` can be found in the list more than once. -/
inductive Duplicate (x : α) : List α → Prop
  | cons_mem {l : List α} : x ∈ l → duplicate (x :: l)
  | cons_duplicate {y : α} {l : List α} : duplicate l → duplicate (y :: l)
#align list.duplicate List.Duplicate
-/

local infixl:50 " ∈+ " => List.Duplicate

variable {l : List α} {x : α}

#print List.Mem.duplicate_cons_self /-
theorem Mem.duplicate_cons_self (h : x ∈ l) : x ∈+ x :: l :=
  Duplicate.cons_mem h
#align list.mem.duplicate_cons_self List.Mem.duplicate_cons_self
-/

#print List.Duplicate.duplicate_cons /-
theorem Duplicate.duplicate_cons (h : x ∈+ l) (y : α) : x ∈+ y :: l :=
  Duplicate.cons_duplicate h
#align list.duplicate.duplicate_cons List.Duplicate.duplicate_cons
-/

#print List.Duplicate.mem /-
theorem Duplicate.mem (h : x ∈+ l) : x ∈ l :=
  by
  induction' h with l' h y l' h hm
  · exact mem_cons_self _ _
  · exact mem_cons_of_mem _ hm
#align list.duplicate.mem List.Duplicate.mem
-/

#print List.Duplicate.mem_cons_self /-
theorem Duplicate.mem_cons_self (h : x ∈+ x :: l) : x ∈ l :=
  by
  cases' h with _ h _ _ h
  · exact h
  · exact h.mem
#align list.duplicate.mem_cons_self List.Duplicate.mem_cons_self
-/

#print List.duplicate_cons_self_iff /-
@[simp]
theorem duplicate_cons_self_iff : x ∈+ x :: l ↔ x ∈ l :=
  ⟨Duplicate.mem_cons_self, Mem.duplicate_cons_self⟩
#align list.duplicate_cons_self_iff List.duplicate_cons_self_iff
-/

#print List.Duplicate.ne_nil /-
theorem Duplicate.ne_nil (h : x ∈+ l) : l ≠ [] := fun H => (mem_nil_iff x).mp (H ▸ h.Mem)
#align list.duplicate.ne_nil List.Duplicate.ne_nil
-/

#print List.not_duplicate_nil /-
@[simp]
theorem not_duplicate_nil (x : α) : ¬x ∈+ [] := fun H => H.ne_nil rfl
#align list.not_duplicate_nil List.not_duplicate_nil
-/

#print List.Duplicate.ne_singleton /-
theorem Duplicate.ne_singleton (h : x ∈+ l) (y : α) : l ≠ [y] :=
  by
  induction' h with l' h z l' h hm
  · simp [ne_nil_of_mem h]
  · simp [ne_nil_of_mem h.mem]
#align list.duplicate.ne_singleton List.Duplicate.ne_singleton
-/

#print List.not_duplicate_singleton /-
@[simp]
theorem not_duplicate_singleton (x y : α) : ¬x ∈+ [y] := fun H => H.ne_singleton _ rfl
#align list.not_duplicate_singleton List.not_duplicate_singleton
-/

#print List.Duplicate.elim_nil /-
theorem Duplicate.elim_nil (h : x ∈+ []) : False :=
  not_duplicate_nil x h
#align list.duplicate.elim_nil List.Duplicate.elim_nil
-/

#print List.Duplicate.elim_singleton /-
theorem Duplicate.elim_singleton {y : α} (h : x ∈+ [y]) : False :=
  not_duplicate_singleton x y h
#align list.duplicate.elim_singleton List.Duplicate.elim_singleton
-/

#print List.duplicate_cons_iff /-
theorem duplicate_cons_iff {y : α} : x ∈+ y :: l ↔ y = x ∧ x ∈ l ∨ x ∈+ l :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · cases' h with _ hm _ _ hm
    · exact Or.inl ⟨rfl, hm⟩
    · exact Or.inr hm
  · rcases h with (⟨rfl | h⟩ | h)
    · simpa
    · exact h.cons_duplicate
#align list.duplicate_cons_iff List.duplicate_cons_iff
-/

#print List.Duplicate.of_duplicate_cons /-
theorem Duplicate.of_duplicate_cons {y : α} (h : x ∈+ y :: l) (hx : x ≠ y) : x ∈+ l := by
  simpa [duplicate_cons_iff, hx.symm] using h
#align list.duplicate.of_duplicate_cons List.Duplicate.of_duplicate_cons
-/

#print List.duplicate_cons_iff_of_ne /-
theorem duplicate_cons_iff_of_ne {y : α} (hne : x ≠ y) : x ∈+ y :: l ↔ x ∈+ l := by
  simp [duplicate_cons_iff, hne.symm]
#align list.duplicate_cons_iff_of_ne List.duplicate_cons_iff_of_ne
-/

#print List.Duplicate.mono_sublist /-
theorem Duplicate.mono_sublist {l' : List α} (hx : x ∈+ l) (h : l <+ l') : x ∈+ l' :=
  by
  induction' h with l₁ l₂ y h IH l₁ l₂ y h IH
  · exact hx
  · exact (IH hx).duplicate_cons _
  · rw [duplicate_cons_iff] at hx ⊢
    rcases hx with (⟨rfl, hx⟩ | hx)
    · simp [h.subset hx]
    · simp [IH hx]
#align list.duplicate.mono_sublist List.Duplicate.mono_sublist
-/

#print List.duplicate_iff_sublist /-
/-- The contrapositive of `list.nodup_iff_sublist`. -/
theorem duplicate_iff_sublist : x ∈+ l ↔ [x, x] <+ l :=
  by
  induction' l with y l IH
  · simp
  · by_cases hx : x = y
    · simp [hx, cons_sublist_cons_iff, singleton_sublist]
    · rw [duplicate_cons_iff_of_ne hx, IH]
      refine' ⟨sublist_cons_of_sublist y, fun h => _⟩
      cases h
      · assumption
      · contradiction
#align list.duplicate_iff_sublist List.duplicate_iff_sublist
-/

#print List.nodup_iff_forall_not_duplicate /-
theorem nodup_iff_forall_not_duplicate : Nodup l ↔ ∀ x : α, ¬x ∈+ l := by
  simp_rw [nodup_iff_sublist, duplicate_iff_sublist]
#align list.nodup_iff_forall_not_duplicate List.nodup_iff_forall_not_duplicate
-/

#print List.exists_duplicate_iff_not_nodup /-
theorem exists_duplicate_iff_not_nodup : (∃ x : α, x ∈+ l) ↔ ¬Nodup l := by
  simp [nodup_iff_forall_not_duplicate]
#align list.exists_duplicate_iff_not_nodup List.exists_duplicate_iff_not_nodup
-/

#print List.Duplicate.not_nodup /-
theorem Duplicate.not_nodup (h : x ∈+ l) : ¬Nodup l := fun H =>
  nodup_iff_forall_not_duplicate.mp H _ h
#align list.duplicate.not_nodup List.Duplicate.not_nodup
-/

#print List.duplicate_iff_two_le_count /-
theorem duplicate_iff_two_le_count [DecidableEq α] : x ∈+ l ↔ 2 ≤ count x l := by
  simp [duplicate_iff_sublist, le_count_iff_replicate_sublist]
#align list.duplicate_iff_two_le_count List.duplicate_iff_two_le_count
-/

#print List.decidableDuplicate /-
instance decidableDuplicate [DecidableEq α] (x : α) : ∀ l : List α, Decidable (x ∈+ l)
  | [] => isFalse (not_duplicate_nil x)
  | y :: l =>
    match decidable_duplicate l with
    | is_true h => isTrue (h.duplicate_cons y)
    | is_false h =>
      if hx : y = x ∧ x ∈ l then isTrue (hx.left.symm ▸ hx.right.duplicate_cons_self)
      else isFalse (by simpa [duplicate_cons_iff, h] using hx)
#align list.decidable_duplicate List.decidableDuplicate
-/

end List

