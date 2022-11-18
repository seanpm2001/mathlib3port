/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Yaël Dillies
-/
import Mathbin.Order.LocallyFinite

/-!
# Intervals as finsets

This file provides basic results about all the `finset.Ixx`, which are defined in
`order.locally_finite`.

## TODO

This file was originally only about `finset.Ico a b` where `a b : ℕ`. No care has yet been taken to
generalize these lemmas properly and many lemmas about `Icc`, `Ioc`, `Ioo` are missing. In general,
what's to do is taking the lemmas in `data.x.intervals` and abstract away the concrete structure.

Complete the API. See
https://github.com/leanprover-community/mathlib/pull/14448#discussion_r906109235
for some ideas.
-/


open BigOperators

variable {ι α : Type _}

namespace Finset

section Preorder

variable [Preorder α]

section LocallyFiniteOrder

variable [LocallyFiniteOrder α] {a a₁ a₂ b b₁ b₂ c x : α}

@[simp]
theorem nonempty_Icc : (icc a b).Nonempty ↔ a ≤ b := by rw [← coe_nonempty, coe_Icc, Set.nonempty_Icc]
#align finset.nonempty_Icc Finset.nonempty_Icc

@[simp]
theorem nonempty_Ico : (ico a b).Nonempty ↔ a < b := by rw [← coe_nonempty, coe_Ico, Set.nonempty_Ico]
#align finset.nonempty_Ico Finset.nonempty_Ico

@[simp]
theorem nonempty_Ioc : (ioc a b).Nonempty ↔ a < b := by rw [← coe_nonempty, coe_Ioc, Set.nonempty_Ioc]
#align finset.nonempty_Ioc Finset.nonempty_Ioc

@[simp]
theorem nonempty_Ioo [DenselyOrdered α] : (ioo a b).Nonempty ↔ a < b := by
  rw [← coe_nonempty, coe_Ioo, Set.nonempty_Ioo]
#align finset.nonempty_Ioo Finset.nonempty_Ioo

@[simp]
theorem Icc_eq_empty_iff : icc a b = ∅ ↔ ¬a ≤ b := by rw [← coe_eq_empty, coe_Icc, Set.Icc_eq_empty_iff]
#align finset.Icc_eq_empty_iff Finset.Icc_eq_empty_iff

@[simp]
theorem Ico_eq_empty_iff : ico a b = ∅ ↔ ¬a < b := by rw [← coe_eq_empty, coe_Ico, Set.Ico_eq_empty_iff]
#align finset.Ico_eq_empty_iff Finset.Ico_eq_empty_iff

@[simp]
theorem Ioc_eq_empty_iff : ioc a b = ∅ ↔ ¬a < b := by rw [← coe_eq_empty, coe_Ioc, Set.Ioc_eq_empty_iff]
#align finset.Ioc_eq_empty_iff Finset.Ioc_eq_empty_iff

@[simp]
theorem Ioo_eq_empty_iff [DenselyOrdered α] : ioo a b = ∅ ↔ ¬a < b := by
  rw [← coe_eq_empty, coe_Ioo, Set.Ioo_eq_empty_iff]
#align finset.Ioo_eq_empty_iff Finset.Ioo_eq_empty_iff

alias Icc_eq_empty_iff ↔ _ Icc_eq_empty

alias Ico_eq_empty_iff ↔ _ Ico_eq_empty

alias Ioc_eq_empty_iff ↔ _ Ioc_eq_empty

@[simp]
theorem Ioo_eq_empty (h : ¬a < b) : ioo a b = ∅ :=
  eq_empty_iff_forall_not_mem.2 fun x hx => h ((mem_Ioo.1 hx).1.trans (mem_Ioo.1 hx).2)
#align finset.Ioo_eq_empty Finset.Ioo_eq_empty

@[simp]
theorem Icc_eq_empty_of_lt (h : b < a) : icc a b = ∅ :=
  Icc_eq_empty h.not_le
#align finset.Icc_eq_empty_of_lt Finset.Icc_eq_empty_of_lt

@[simp]
theorem Ico_eq_empty_of_le (h : b ≤ a) : ico a b = ∅ :=
  Ico_eq_empty h.not_lt
#align finset.Ico_eq_empty_of_le Finset.Ico_eq_empty_of_le

@[simp]
theorem Ioc_eq_empty_of_le (h : b ≤ a) : ioc a b = ∅ :=
  Ioc_eq_empty h.not_lt
#align finset.Ioc_eq_empty_of_le Finset.Ioc_eq_empty_of_le

@[simp]
theorem Ioo_eq_empty_of_le (h : b ≤ a) : ioo a b = ∅ :=
  Ioo_eq_empty h.not_lt
#align finset.Ioo_eq_empty_of_le Finset.Ioo_eq_empty_of_le

@[simp]
theorem left_mem_Icc : a ∈ icc a b ↔ a ≤ b := by simp only [mem_Icc, true_and_iff, le_rfl]
#align finset.left_mem_Icc Finset.left_mem_Icc

@[simp]
theorem left_mem_Ico : a ∈ ico a b ↔ a < b := by simp only [mem_Ico, true_and_iff, le_refl]
#align finset.left_mem_Ico Finset.left_mem_Ico

@[simp]
theorem right_mem_Icc : b ∈ icc a b ↔ a ≤ b := by simp only [mem_Icc, and_true_iff, le_rfl]
#align finset.right_mem_Icc Finset.right_mem_Icc

@[simp]
theorem right_mem_Ioc : b ∈ ioc a b ↔ a < b := by simp only [mem_Ioc, and_true_iff, le_rfl]
#align finset.right_mem_Ioc Finset.right_mem_Ioc

@[simp]
theorem left_not_mem_Ioc : a ∉ ioc a b := fun h => lt_irrefl _ (mem_Ioc.1 h).1
#align finset.left_not_mem_Ioc Finset.left_not_mem_Ioc

@[simp]
theorem left_not_mem_Ioo : a ∉ ioo a b := fun h => lt_irrefl _ (mem_Ioo.1 h).1
#align finset.left_not_mem_Ioo Finset.left_not_mem_Ioo

@[simp]
theorem right_not_mem_Ico : b ∉ ico a b := fun h => lt_irrefl _ (mem_Ico.1 h).2
#align finset.right_not_mem_Ico Finset.right_not_mem_Ico

@[simp]
theorem right_not_mem_Ioo : b ∉ ioo a b := fun h => lt_irrefl _ (mem_Ioo.1 h).2
#align finset.right_not_mem_Ioo Finset.right_not_mem_Ioo

theorem Icc_subset_Icc (ha : a₂ ≤ a₁) (hb : b₁ ≤ b₂) : icc a₁ b₁ ⊆ icc a₂ b₂ := by
  simpa [← coe_subset] using Set.Icc_subset_Icc ha hb
#align finset.Icc_subset_Icc Finset.Icc_subset_Icc

theorem Ico_subset_Ico (ha : a₂ ≤ a₁) (hb : b₁ ≤ b₂) : ico a₁ b₁ ⊆ ico a₂ b₂ := by
  simpa [← coe_subset] using Set.Ico_subset_Ico ha hb
#align finset.Ico_subset_Ico Finset.Ico_subset_Ico

theorem Ioc_subset_Ioc (ha : a₂ ≤ a₁) (hb : b₁ ≤ b₂) : ioc a₁ b₁ ⊆ ioc a₂ b₂ := by
  simpa [← coe_subset] using Set.Ioc_subset_Ioc ha hb
#align finset.Ioc_subset_Ioc Finset.Ioc_subset_Ioc

theorem Ioo_subset_Ioo (ha : a₂ ≤ a₁) (hb : b₁ ≤ b₂) : ioo a₁ b₁ ⊆ ioo a₂ b₂ := by
  simpa [← coe_subset] using Set.Ioo_subset_Ioo ha hb
#align finset.Ioo_subset_Ioo Finset.Ioo_subset_Ioo

theorem Icc_subset_Icc_left (h : a₁ ≤ a₂) : icc a₂ b ⊆ icc a₁ b :=
  Icc_subset_Icc h le_rfl
#align finset.Icc_subset_Icc_left Finset.Icc_subset_Icc_left

theorem Ico_subset_Ico_left (h : a₁ ≤ a₂) : ico a₂ b ⊆ ico a₁ b :=
  Ico_subset_Ico h le_rfl
#align finset.Ico_subset_Ico_left Finset.Ico_subset_Ico_left

theorem Ioc_subset_Ioc_left (h : a₁ ≤ a₂) : ioc a₂ b ⊆ ioc a₁ b :=
  Ioc_subset_Ioc h le_rfl
#align finset.Ioc_subset_Ioc_left Finset.Ioc_subset_Ioc_left

theorem Ioo_subset_Ioo_left (h : a₁ ≤ a₂) : ioo a₂ b ⊆ ioo a₁ b :=
  Ioo_subset_Ioo h le_rfl
#align finset.Ioo_subset_Ioo_left Finset.Ioo_subset_Ioo_left

theorem Icc_subset_Icc_right (h : b₁ ≤ b₂) : icc a b₁ ⊆ icc a b₂ :=
  Icc_subset_Icc le_rfl h
#align finset.Icc_subset_Icc_right Finset.Icc_subset_Icc_right

theorem Ico_subset_Ico_right (h : b₁ ≤ b₂) : ico a b₁ ⊆ ico a b₂ :=
  Ico_subset_Ico le_rfl h
#align finset.Ico_subset_Ico_right Finset.Ico_subset_Ico_right

theorem Ioc_subset_Ioc_right (h : b₁ ≤ b₂) : ioc a b₁ ⊆ ioc a b₂ :=
  Ioc_subset_Ioc le_rfl h
#align finset.Ioc_subset_Ioc_right Finset.Ioc_subset_Ioc_right

theorem Ioo_subset_Ioo_right (h : b₁ ≤ b₂) : ioo a b₁ ⊆ ioo a b₂ :=
  Ioo_subset_Ioo le_rfl h
#align finset.Ioo_subset_Ioo_right Finset.Ioo_subset_Ioo_right

theorem Ico_subset_Ioo_left (h : a₁ < a₂) : ico a₂ b ⊆ ioo a₁ b := by
  rw [← coe_subset, coe_Ico, coe_Ioo]
  exact Set.Ico_subset_Ioo_left h
#align finset.Ico_subset_Ioo_left Finset.Ico_subset_Ioo_left

theorem Ioc_subset_Ioo_right (h : b₁ < b₂) : ioc a b₁ ⊆ ioo a b₂ := by
  rw [← coe_subset, coe_Ioc, coe_Ioo]
  exact Set.Ioc_subset_Ioo_right h
#align finset.Ioc_subset_Ioo_right Finset.Ioc_subset_Ioo_right

theorem Icc_subset_Ico_right (h : b₁ < b₂) : icc a b₁ ⊆ ico a b₂ := by
  rw [← coe_subset, coe_Icc, coe_Ico]
  exact Set.Icc_subset_Ico_right h
#align finset.Icc_subset_Ico_right Finset.Icc_subset_Ico_right

theorem Ioo_subset_Ico_self : ioo a b ⊆ ico a b := by
  rw [← coe_subset, coe_Ioo, coe_Ico]
  exact Set.Ioo_subset_Ico_self
#align finset.Ioo_subset_Ico_self Finset.Ioo_subset_Ico_self

theorem Ioo_subset_Ioc_self : ioo a b ⊆ ioc a b := by
  rw [← coe_subset, coe_Ioo, coe_Ioc]
  exact Set.Ioo_subset_Ioc_self
#align finset.Ioo_subset_Ioc_self Finset.Ioo_subset_Ioc_self

theorem Ico_subset_Icc_self : ico a b ⊆ icc a b := by
  rw [← coe_subset, coe_Ico, coe_Icc]
  exact Set.Ico_subset_Icc_self
#align finset.Ico_subset_Icc_self Finset.Ico_subset_Icc_self

theorem Ioc_subset_Icc_self : ioc a b ⊆ icc a b := by
  rw [← coe_subset, coe_Ioc, coe_Icc]
  exact Set.Ioc_subset_Icc_self
#align finset.Ioc_subset_Icc_self Finset.Ioc_subset_Icc_self

theorem Ioo_subset_Icc_self : ioo a b ⊆ icc a b :=
  Ioo_subset_Ico_self.trans Ico_subset_Icc_self
#align finset.Ioo_subset_Icc_self Finset.Ioo_subset_Icc_self

theorem Icc_subset_Icc_iff (h₁ : a₁ ≤ b₁) : icc a₁ b₁ ⊆ icc a₂ b₂ ↔ a₂ ≤ a₁ ∧ b₁ ≤ b₂ := by
  rw [← coe_subset, coe_Icc, coe_Icc, Set.Icc_subset_Icc_iff h₁]
#align finset.Icc_subset_Icc_iff Finset.Icc_subset_Icc_iff

theorem Icc_subset_Ioo_iff (h₁ : a₁ ≤ b₁) : icc a₁ b₁ ⊆ ioo a₂ b₂ ↔ a₂ < a₁ ∧ b₁ < b₂ := by
  rw [← coe_subset, coe_Icc, coe_Ioo, Set.Icc_subset_Ioo_iff h₁]
#align finset.Icc_subset_Ioo_iff Finset.Icc_subset_Ioo_iff

theorem Icc_subset_Ico_iff (h₁ : a₁ ≤ b₁) : icc a₁ b₁ ⊆ ico a₂ b₂ ↔ a₂ ≤ a₁ ∧ b₁ < b₂ := by
  rw [← coe_subset, coe_Icc, coe_Ico, Set.Icc_subset_Ico_iff h₁]
#align finset.Icc_subset_Ico_iff Finset.Icc_subset_Ico_iff

theorem Icc_subset_Ioc_iff (h₁ : a₁ ≤ b₁) : icc a₁ b₁ ⊆ ioc a₂ b₂ ↔ a₂ < a₁ ∧ b₁ ≤ b₂ :=
  (Icc_subset_Ico_iff h₁.dual).trans and_comm
#align finset.Icc_subset_Ioc_iff Finset.Icc_subset_Ioc_iff

--TODO: `Ico_subset_Ioo_iff`, `Ioc_subset_Ioo_iff`
theorem Icc_ssubset_Icc_left (hI : a₂ ≤ b₂) (ha : a₂ < a₁) (hb : b₁ ≤ b₂) : icc a₁ b₁ ⊂ icc a₂ b₂ := by
  rw [← coe_ssubset, coe_Icc, coe_Icc]
  exact Set.Icc_ssubset_Icc_left hI ha hb
#align finset.Icc_ssubset_Icc_left Finset.Icc_ssubset_Icc_left

theorem Icc_ssubset_Icc_right (hI : a₂ ≤ b₂) (ha : a₂ ≤ a₁) (hb : b₁ < b₂) : icc a₁ b₁ ⊂ icc a₂ b₂ := by
  rw [← coe_ssubset, coe_Icc, coe_Icc]
  exact Set.Icc_ssubset_Icc_right hI ha hb
#align finset.Icc_ssubset_Icc_right Finset.Icc_ssubset_Icc_right

variable (a)

@[simp]
theorem Ico_self : ico a a = ∅ :=
  Ico_eq_empty <| lt_irrefl _
#align finset.Ico_self Finset.Ico_self

@[simp]
theorem Ioc_self : ioc a a = ∅ :=
  Ioc_eq_empty <| lt_irrefl _
#align finset.Ioc_self Finset.Ioc_self

@[simp]
theorem Ioo_self : ioo a a = ∅ :=
  Ioo_eq_empty <| lt_irrefl _
#align finset.Ioo_self Finset.Ioo_self

variable {a}

/-- A set with upper and lower bounds in a locally finite order is a fintype -/
def _root_.set.fintype_of_mem_bounds {s : Set α} [DecidablePred (· ∈ s)] (ha : a ∈ lowerBounds s)
    (hb : b ∈ upperBounds s) : Fintype s :=
  (Set.fintypeSubset (Set.icc a b)) fun x hx => ⟨ha hx, hb hx⟩
#align finset._root_.set.fintype_of_mem_bounds finset._root_.set.fintype_of_mem_bounds

theorem _root_.bdd_below.finite_of_bdd_above {s : Set α} (h₀ : BddBelow s) (h₁ : BddAbove s) : s.Finite := by
  let ⟨a, ha⟩ := h₀
  let ⟨b, hb⟩ := h₁
  classical exact ⟨Set.fintypeOfMemBounds ha hb⟩
#align finset._root_.bdd_below.finite_of_bdd_above finset._root_.bdd_below.finite_of_bdd_above

section Filter

theorem Ico_filter_lt_of_le_left [DecidablePred (· < c)] (hca : c ≤ a) : (ico a b).filter (· < c) = ∅ :=
  filter_false_of_mem fun x hx => (hca.trans (mem_Ico.1 hx).1).not_lt
#align finset.Ico_filter_lt_of_le_left Finset.Ico_filter_lt_of_le_left

theorem Ico_filter_lt_of_right_le [DecidablePred (· < c)] (hbc : b ≤ c) : (ico a b).filter (· < c) = ico a b :=
  filter_true_of_mem fun x hx => (mem_Ico.1 hx).2.trans_le hbc
#align finset.Ico_filter_lt_of_right_le Finset.Ico_filter_lt_of_right_le

theorem Ico_filter_lt_of_le_right [DecidablePred (· < c)] (hcb : c ≤ b) : (ico a b).filter (· < c) = ico a c := by
  ext x
  rw [mem_filter, mem_Ico, mem_Ico, and_right_comm]
  exact and_iff_left_of_imp fun h => h.2.trans_le hcb
#align finset.Ico_filter_lt_of_le_right Finset.Ico_filter_lt_of_le_right

theorem Ico_filter_le_of_le_left {a b c : α} [DecidablePred ((· ≤ ·) c)] (hca : c ≤ a) :
    (ico a b).filter ((· ≤ ·) c) = ico a b :=
  filter_true_of_mem fun x hx => hca.trans (mem_Ico.1 hx).1
#align finset.Ico_filter_le_of_le_left Finset.Ico_filter_le_of_le_left

theorem Ico_filter_le_of_right_le {a b : α} [DecidablePred ((· ≤ ·) b)] : (ico a b).filter ((· ≤ ·) b) = ∅ :=
  filter_false_of_mem fun x hx => (mem_Ico.1 hx).2.not_le
#align finset.Ico_filter_le_of_right_le Finset.Ico_filter_le_of_right_le

theorem Ico_filter_le_of_left_le {a b c : α} [DecidablePred ((· ≤ ·) c)] (hac : a ≤ c) :
    (ico a b).filter ((· ≤ ·) c) = ico c b := by
  ext x
  rw [mem_filter, mem_Ico, mem_Ico, and_comm', and_left_comm]
  exact and_iff_right_of_imp fun h => hac.trans h.1
#align finset.Ico_filter_le_of_left_le Finset.Ico_filter_le_of_left_le

theorem Icc_filter_lt_of_lt_right {a b c : α} [DecidablePred (· < c)] (h : b < c) :
    (icc a b).filter (· < c) = icc a b :=
  (Finset.filter_eq_self _).2 fun x hx => lt_of_le_of_lt (mem_Icc.1 hx).2 h
#align finset.Icc_filter_lt_of_lt_right Finset.Icc_filter_lt_of_lt_right

theorem Ioc_filter_lt_of_lt_right {a b c : α} [DecidablePred (· < c)] (h : b < c) :
    (ioc a b).filter (· < c) = ioc a b :=
  (Finset.filter_eq_self _).2 fun x hx => lt_of_le_of_lt (mem_Ioc.1 hx).2 h
#align finset.Ioc_filter_lt_of_lt_right Finset.Ioc_filter_lt_of_lt_right

theorem Iic_filter_lt_of_lt_right {α} [Preorder α] [LocallyFiniteOrderBot α] {a c : α} [DecidablePred (· < c)]
    (h : a < c) : (iic a).filter (· < c) = iic a :=
  (Finset.filter_eq_self _).2 fun x hx => lt_of_le_of_lt (mem_Iic.1 hx) h
#align finset.Iic_filter_lt_of_lt_right Finset.Iic_filter_lt_of_lt_right

variable (a b) [Fintype α]

theorem filter_lt_lt_eq_Ioo [DecidablePred fun j => a < j ∧ j < b] : (univ.filter fun j => a < j ∧ j < b) = ioo a b :=
  by
  ext
  simp
#align finset.filter_lt_lt_eq_Ioo Finset.filter_lt_lt_eq_Ioo

theorem filter_lt_le_eq_Ioc [DecidablePred fun j => a < j ∧ j ≤ b] : (univ.filter fun j => a < j ∧ j ≤ b) = ioc a b :=
  by
  ext
  simp
#align finset.filter_lt_le_eq_Ioc Finset.filter_lt_le_eq_Ioc

theorem filter_le_lt_eq_Ico [DecidablePred fun j => a ≤ j ∧ j < b] : (univ.filter fun j => a ≤ j ∧ j < b) = ico a b :=
  by
  ext
  simp
#align finset.filter_le_lt_eq_Ico Finset.filter_le_lt_eq_Ico

theorem filter_le_le_eq_Icc [DecidablePred fun j => a ≤ j ∧ j ≤ b] : (univ.filter fun j => a ≤ j ∧ j ≤ b) = icc a b :=
  by
  ext
  simp
#align finset.filter_le_le_eq_Icc Finset.filter_le_le_eq_Icc

end Filter

section LocallyFiniteOrderTop

variable [LocallyFiniteOrderTop α]

theorem Icc_subset_Ici_self : icc a b ⊆ ici a := by simpa [← coe_subset] using Set.Icc_subset_Ici_self
#align finset.Icc_subset_Ici_self Finset.Icc_subset_Ici_self

theorem Ico_subset_Ici_self : ico a b ⊆ ici a := by simpa [← coe_subset] using Set.Ico_subset_Ici_self
#align finset.Ico_subset_Ici_self Finset.Ico_subset_Ici_self

theorem Ioc_subset_Ioi_self : ioc a b ⊆ ioi a := by simpa [← coe_subset] using Set.Ioc_subset_Ioi_self
#align finset.Ioc_subset_Ioi_self Finset.Ioc_subset_Ioi_self

theorem Ioo_subset_Ioi_self : ioo a b ⊆ ioi a := by simpa [← coe_subset] using Set.Ioo_subset_Ioi_self
#align finset.Ioo_subset_Ioi_self Finset.Ioo_subset_Ioi_self

theorem Ioc_subset_Ici_self : ioc a b ⊆ ici a :=
  Ioc_subset_Icc_self.trans Icc_subset_Ici_self
#align finset.Ioc_subset_Ici_self Finset.Ioc_subset_Ici_self

theorem Ioo_subset_Ici_self : ioo a b ⊆ ici a :=
  Ioo_subset_Ico_self.trans Ico_subset_Ici_self
#align finset.Ioo_subset_Ici_self Finset.Ioo_subset_Ici_self

end LocallyFiniteOrderTop

section LocallyFiniteOrderBot

variable [LocallyFiniteOrderBot α]

theorem Icc_subset_Iic_self : icc a b ⊆ iic b := by simpa [← coe_subset] using Set.Icc_subset_Iic_self
#align finset.Icc_subset_Iic_self Finset.Icc_subset_Iic_self

theorem Ioc_subset_Iic_self : ioc a b ⊆ iic b := by simpa [← coe_subset] using Set.Ioc_subset_Iic_self
#align finset.Ioc_subset_Iic_self Finset.Ioc_subset_Iic_self

theorem Ico_subset_Iio_self : ico a b ⊆ iio b := by simpa [← coe_subset] using Set.Ico_subset_Iio_self
#align finset.Ico_subset_Iio_self Finset.Ico_subset_Iio_self

theorem Ioo_subset_Iio_self : ioo a b ⊆ iio b := by simpa [← coe_subset] using Set.Ioo_subset_Iio_self
#align finset.Ioo_subset_Iio_self Finset.Ioo_subset_Iio_self

theorem Ico_subset_Iic_self : ico a b ⊆ iic b :=
  Ico_subset_Icc_self.trans Icc_subset_Iic_self
#align finset.Ico_subset_Iic_self Finset.Ico_subset_Iic_self

theorem Ioo_subset_Iic_self : ioo a b ⊆ iic b :=
  Ioo_subset_Ioc_self.trans Ioc_subset_Iic_self
#align finset.Ioo_subset_Iic_self Finset.Ioo_subset_Iic_self

end LocallyFiniteOrderBot

end LocallyFiniteOrder

section LocallyFiniteOrderTop

variable [LocallyFiniteOrderTop α] {a : α}

theorem Ioi_subset_Ici_self : ioi a ⊆ ici a := by simpa [← coe_subset] using Set.Ioi_subset_Ici_self
#align finset.Ioi_subset_Ici_self Finset.Ioi_subset_Ici_self

theorem _root_.bdd_below.finite {s : Set α} (hs : BddBelow s) : s.Finite :=
  let ⟨a, ha⟩ := hs
  (ici a).finite_to_set.Subset fun x hx => mem_Ici.2 <| ha hx
#align finset._root_.bdd_below.finite finset._root_.bdd_below.finite

variable [Fintype α]

theorem filter_lt_eq_Ioi [DecidablePred ((· < ·) a)] : univ.filter ((· < ·) a) = ioi a := by
  ext
  simp
#align finset.filter_lt_eq_Ioi Finset.filter_lt_eq_Ioi

theorem filter_le_eq_Ici [DecidablePred ((· ≤ ·) a)] : univ.filter ((· ≤ ·) a) = ici a := by
  ext
  simp
#align finset.filter_le_eq_Ici Finset.filter_le_eq_Ici

end LocallyFiniteOrderTop

section LocallyFiniteOrderBot

variable [LocallyFiniteOrderBot α] {a : α}

theorem Iio_subset_Iic_self : iio a ⊆ iic a := by simpa [← coe_subset] using Set.Iio_subset_Iic_self
#align finset.Iio_subset_Iic_self Finset.Iio_subset_Iic_self

theorem _root_.bdd_above.finite {s : Set α} (hs : BddAbove s) : s.Finite :=
  hs.dual.Finite
#align finset._root_.bdd_above.finite finset._root_.bdd_above.finite

variable [Fintype α]

theorem filter_gt_eq_Iio [DecidablePred (· < a)] : univ.filter (· < a) = iio a := by
  ext
  simp
#align finset.filter_gt_eq_Iio Finset.filter_gt_eq_Iio

theorem filter_ge_eq_Iic [DecidablePred (· ≤ a)] : univ.filter (· ≤ a) = iic a := by
  ext
  simp
#align finset.filter_ge_eq_Iic Finset.filter_ge_eq_Iic

end LocallyFiniteOrderBot

variable [LocallyFiniteOrderTop α] [LocallyFiniteOrderBot α]

theorem disjoint_Ioi_Iio (a : α) : Disjoint (ioi a) (iio a) :=
  disjoint_left.2 fun b hab hba => (mem_Ioi.1 hab).not_lt <| mem_Iio.1 hba
#align finset.disjoint_Ioi_Iio Finset.disjoint_Ioi_Iio

end Preorder

section PartialOrder

variable [PartialOrder α] [LocallyFiniteOrder α] {a b c : α}

@[simp]
theorem Icc_self (a : α) : icc a a = {a} := by rw [← coe_eq_singleton, coe_Icc, Set.Icc_self]
#align finset.Icc_self Finset.Icc_self

@[simp]
theorem Icc_eq_singleton_iff : icc a b = {c} ↔ a = c ∧ b = c := by
  rw [← coe_eq_singleton, coe_Icc, Set.Icc_eq_singleton_iff]
#align finset.Icc_eq_singleton_iff Finset.Icc_eq_singleton_iff

theorem Ico_disjoint_Ico_consecutive (a b c : α) : Disjoint (ico a b) (ico b c) :=
  disjoint_left.2 fun x hab hbc => (mem_Ico.mp hab).2.not_le (mem_Ico.mp hbc).1
#align finset.Ico_disjoint_Ico_consecutive Finset.Ico_disjoint_Ico_consecutive

section DecidableEq

variable [DecidableEq α]

@[simp]
theorem Icc_erase_left (a b : α) : (icc a b).erase a = ioc a b := by simp [← coe_inj]
#align finset.Icc_erase_left Finset.Icc_erase_left

@[simp]
theorem Icc_erase_right (a b : α) : (icc a b).erase b = ico a b := by simp [← coe_inj]
#align finset.Icc_erase_right Finset.Icc_erase_right

@[simp]
theorem Ico_erase_left (a b : α) : (ico a b).erase a = ioo a b := by simp [← coe_inj]
#align finset.Ico_erase_left Finset.Ico_erase_left

@[simp]
theorem Ioc_erase_right (a b : α) : (ioc a b).erase b = ioo a b := by simp [← coe_inj]
#align finset.Ioc_erase_right Finset.Ioc_erase_right

@[simp]
theorem Icc_diff_both (a b : α) : icc a b \ {a, b} = ioo a b := by simp [← coe_inj]
#align finset.Icc_diff_both Finset.Icc_diff_both

@[simp]
theorem Ico_insert_right (h : a ≤ b) : insert b (ico a b) = icc a b := by
  rw [← coe_inj, coe_insert, coe_Icc, coe_Ico, Set.insert_eq, Set.union_comm, Set.Ico_union_right h]
#align finset.Ico_insert_right Finset.Ico_insert_right

@[simp]
theorem Ioc_insert_left (h : a ≤ b) : insert a (ioc a b) = icc a b := by
  rw [← coe_inj, coe_insert, coe_Ioc, coe_Icc, Set.insert_eq, Set.union_comm, Set.Ioc_union_left h]
#align finset.Ioc_insert_left Finset.Ioc_insert_left

@[simp]
theorem Ioo_insert_left (h : a < b) : insert a (ioo a b) = ico a b := by
  rw [← coe_inj, coe_insert, coe_Ioo, coe_Ico, Set.insert_eq, Set.union_comm, Set.Ioo_union_left h]
#align finset.Ioo_insert_left Finset.Ioo_insert_left

@[simp]
theorem Ioo_insert_right (h : a < b) : insert b (ioo a b) = ioc a b := by
  rw [← coe_inj, coe_insert, coe_Ioo, coe_Ioc, Set.insert_eq, Set.union_comm, Set.Ioo_union_right h]
#align finset.Ioo_insert_right Finset.Ioo_insert_right

@[simp]
theorem Icc_diff_Ico_self (h : a ≤ b) : icc a b \ ico a b = {b} := by simp [← coe_inj, h]
#align finset.Icc_diff_Ico_self Finset.Icc_diff_Ico_self

@[simp]
theorem Icc_diff_Ioc_self (h : a ≤ b) : icc a b \ ioc a b = {a} := by simp [← coe_inj, h]
#align finset.Icc_diff_Ioc_self Finset.Icc_diff_Ioc_self

@[simp]
theorem Icc_diff_Ioo_self (h : a ≤ b) : icc a b \ ioo a b = {a, b} := by simp [← coe_inj, h]
#align finset.Icc_diff_Ioo_self Finset.Icc_diff_Ioo_self

@[simp]
theorem Ico_diff_Ioo_self (h : a < b) : ico a b \ ioo a b = {a} := by simp [← coe_inj, h]
#align finset.Ico_diff_Ioo_self Finset.Ico_diff_Ioo_self

@[simp]
theorem Ioc_diff_Ioo_self (h : a < b) : ioc a b \ ioo a b = {b} := by simp [← coe_inj, h]
#align finset.Ioc_diff_Ioo_self Finset.Ioc_diff_Ioo_self

@[simp]
theorem Ico_inter_Ico_consecutive (a b c : α) : ico a b ∩ ico b c = ∅ :=
  (Ico_disjoint_Ico_consecutive a b c).eq_bot
#align finset.Ico_inter_Ico_consecutive Finset.Ico_inter_Ico_consecutive

end DecidableEq

-- Those lemmas are purposefully the other way around
theorem Icc_eq_cons_Ico (h : a ≤ b) : icc a b = (ico a b).cons b right_not_mem_Ico := by
  classical rw [cons_eq_insert, Ico_insert_right h]
#align finset.Icc_eq_cons_Ico Finset.Icc_eq_cons_Ico

theorem Icc_eq_cons_Ioc (h : a ≤ b) : icc a b = (ioc a b).cons a left_not_mem_Ioc := by
  classical rw [cons_eq_insert, Ioc_insert_left h]
#align finset.Icc_eq_cons_Ioc Finset.Icc_eq_cons_Ioc

theorem Ico_filter_le_left {a b : α} [DecidablePred (· ≤ a)] (hab : a < b) : ((ico a b).filter fun x => x ≤ a) = {a} :=
  by
  ext x
  rw [mem_filter, mem_Ico, mem_singleton, and_right_comm, ← le_antisymm_iff, eq_comm]
  exact and_iff_left_of_imp fun h => h.le.trans_lt hab
#align finset.Ico_filter_le_left Finset.Ico_filter_le_left

theorem card_Ico_eq_card_Icc_sub_one (a b : α) : (ico a b).card = (icc a b).card - 1 := by classical
  by_cases h : a ≤ b
  · rw [← Ico_insert_right h, card_insert_of_not_mem right_not_mem_Ico]
    exact (Nat.add_sub_cancel _ _).symm
    
  · rw [Ico_eq_empty fun h' => h h'.le, Icc_eq_empty h, card_empty, zero_tsub]
    
#align finset.card_Ico_eq_card_Icc_sub_one Finset.card_Ico_eq_card_Icc_sub_one

theorem card_Ioc_eq_card_Icc_sub_one (a b : α) : (ioc a b).card = (icc a b).card - 1 :=
  @card_Ico_eq_card_Icc_sub_one αᵒᵈ _ _ _ _
#align finset.card_Ioc_eq_card_Icc_sub_one Finset.card_Ioc_eq_card_Icc_sub_one

theorem card_Ioo_eq_card_Ico_sub_one (a b : α) : (ioo a b).card = (ico a b).card - 1 := by classical
  by_cases h : a ≤ b
  · obtain rfl | h' := h.eq_or_lt
    · rw [Ioo_self, Ico_self, card_empty]
      
    rw [← Ioo_insert_left h', card_insert_of_not_mem left_not_mem_Ioo]
    exact (Nat.add_sub_cancel _ _).symm
    
  · rw [Ioo_eq_empty fun h' => h h'.le, Ico_eq_empty fun h' => h h'.le, card_empty, zero_tsub]
    
#align finset.card_Ioo_eq_card_Ico_sub_one Finset.card_Ioo_eq_card_Ico_sub_one

theorem card_Ioo_eq_card_Ioc_sub_one (a b : α) : (ioo a b).card = (ioc a b).card - 1 :=
  @card_Ioo_eq_card_Ico_sub_one αᵒᵈ _ _ _ _
#align finset.card_Ioo_eq_card_Ioc_sub_one Finset.card_Ioo_eq_card_Ioc_sub_one

theorem card_Ioo_eq_card_Icc_sub_two (a b : α) : (ioo a b).card = (icc a b).card - 2 := by
  rw [card_Ioo_eq_card_Ico_sub_one, card_Ico_eq_card_Icc_sub_one]
  rfl
#align finset.card_Ioo_eq_card_Icc_sub_two Finset.card_Ioo_eq_card_Icc_sub_two

end PartialOrder

section BoundedPartialOrder

variable [PartialOrder α]

section OrderTop

variable [LocallyFiniteOrderTop α]

@[simp]
theorem Ici_erase [DecidableEq α] (a : α) : (ici a).erase a = ioi a := by
  ext
  simp_rw [Finset.mem_erase, mem_Ici, mem_Ioi, lt_iff_le_and_ne, and_comm', ne_comm]
#align finset.Ici_erase Finset.Ici_erase

@[simp]
theorem Ioi_insert [DecidableEq α] (a : α) : insert a (ioi a) = ici a := by
  ext
  simp_rw [Finset.mem_insert, mem_Ici, mem_Ioi, le_iff_lt_or_eq, or_comm', eq_comm]
#align finset.Ioi_insert Finset.Ioi_insert

@[simp]
theorem not_mem_Ioi_self {b : α} : b ∉ ioi b := fun h => lt_irrefl _ (mem_Ioi.1 h)
#align finset.not_mem_Ioi_self Finset.not_mem_Ioi_self

-- Purposefully written the other way around
theorem Ici_eq_cons_Ioi (a : α) : ici a = (ioi a).cons a not_mem_Ioi_self := by
  classical rw [cons_eq_insert, Ioi_insert]
#align finset.Ici_eq_cons_Ioi Finset.Ici_eq_cons_Ioi

theorem card_Ioi_eq_card_Ici_sub_one (a : α) : (ioi a).card = (ici a).card - 1 := by
  rw [Ici_eq_cons_Ioi, card_cons, add_tsub_cancel_right]
#align finset.card_Ioi_eq_card_Ici_sub_one Finset.card_Ioi_eq_card_Ici_sub_one

end OrderTop

section OrderBot

variable [LocallyFiniteOrderBot α]

@[simp]
theorem Iic_erase [DecidableEq α] (b : α) : (iic b).erase b = iio b := by
  ext
  simp_rw [Finset.mem_erase, mem_Iic, mem_Iio, lt_iff_le_and_ne, and_comm']
#align finset.Iic_erase Finset.Iic_erase

@[simp]
theorem Iio_insert [DecidableEq α] (b : α) : insert b (iio b) = iic b := by
  ext
  simp_rw [Finset.mem_insert, mem_Iic, mem_Iio, le_iff_lt_or_eq, or_comm']
#align finset.Iio_insert Finset.Iio_insert

@[simp]
theorem not_mem_Iio_self {b : α} : b ∉ iio b := fun h => lt_irrefl _ (mem_Iio.1 h)
#align finset.not_mem_Iio_self Finset.not_mem_Iio_self

-- Purposefully written the other way around
theorem Iic_eq_cons_Iio (b : α) : iic b = (iio b).cons b not_mem_Iio_self := by
  classical rw [cons_eq_insert, Iio_insert]
#align finset.Iic_eq_cons_Iio Finset.Iic_eq_cons_Iio

theorem card_Iio_eq_card_Iic_sub_one (a : α) : (iio a).card = (iic a).card - 1 := by
  rw [Iic_eq_cons_Iio, card_cons, add_tsub_cancel_right]
#align finset.card_Iio_eq_card_Iic_sub_one Finset.card_Iio_eq_card_Iic_sub_one

end OrderBot

end BoundedPartialOrder

section LinearOrder

variable [LinearOrder α]

section LocallyFiniteOrder

variable [LocallyFiniteOrder α] {a b : α}

theorem Ico_subset_Ico_iff {a₁ b₁ a₂ b₂ : α} (h : a₁ < b₁) : ico a₁ b₁ ⊆ ico a₂ b₂ ↔ a₂ ≤ a₁ ∧ b₁ ≤ b₂ := by
  rw [← coe_subset, coe_Ico, coe_Ico, Set.Ico_subset_Ico_iff h]
#align finset.Ico_subset_Ico_iff Finset.Ico_subset_Ico_iff

theorem Ico_union_Ico_eq_Ico {a b c : α} (hab : a ≤ b) (hbc : b ≤ c) : ico a b ∪ ico b c = ico a c := by
  rw [← coe_inj, coe_union, coe_Ico, coe_Ico, coe_Ico, Set.Ico_union_Ico_eq_Ico hab hbc]
#align finset.Ico_union_Ico_eq_Ico Finset.Ico_union_Ico_eq_Ico

@[simp]
theorem Ioc_union_Ioc_eq_Ioc {a b c : α} (h₁ : a ≤ b) (h₂ : b ≤ c) : ioc a b ∪ ioc b c = ioc a c := by
  rw [← coe_inj, coe_union, coe_Ioc, coe_Ioc, coe_Ioc, Set.Ioc_union_Ioc_eq_Ioc h₁ h₂]
#align finset.Ioc_union_Ioc_eq_Ioc Finset.Ioc_union_Ioc_eq_Ioc

theorem Ico_subset_Ico_union_Ico {a b c : α} : ico a c ⊆ ico a b ∪ ico b c := by
  rw [← coe_subset, coe_union, coe_Ico, coe_Ico, coe_Ico]
  exact Set.Ico_subset_Ico_union_Ico
#align finset.Ico_subset_Ico_union_Ico Finset.Ico_subset_Ico_union_Ico

theorem Ico_union_Ico' {a b c d : α} (hcb : c ≤ b) (had : a ≤ d) : ico a b ∪ ico c d = ico (min a c) (max b d) := by
  rw [← coe_inj, coe_union, coe_Ico, coe_Ico, coe_Ico, Set.Ico_union_Ico' hcb had]
#align finset.Ico_union_Ico' Finset.Ico_union_Ico'

theorem Ico_union_Ico {a b c d : α} (h₁ : min a b ≤ max c d) (h₂ : min c d ≤ max a b) :
    ico a b ∪ ico c d = ico (min a c) (max b d) := by
  rw [← coe_inj, coe_union, coe_Ico, coe_Ico, coe_Ico, Set.Ico_union_Ico h₁ h₂]
#align finset.Ico_union_Ico Finset.Ico_union_Ico

theorem Ico_inter_Ico {a b c d : α} : ico a b ∩ ico c d = ico (max a c) (min b d) := by
  rw [← coe_inj, coe_inter, coe_Ico, coe_Ico, coe_Ico, ← inf_eq_min, ← sup_eq_max, Set.Ico_inter_Ico]
#align finset.Ico_inter_Ico Finset.Ico_inter_Ico

@[simp]
theorem Ico_filter_lt (a b c : α) : ((ico a b).filter fun x => x < c) = ico a (min b c) := by
  cases le_total b c
  · rw [Ico_filter_lt_of_right_le h, min_eq_left h]
    
  · rw [Ico_filter_lt_of_le_right h, min_eq_right h]
    
#align finset.Ico_filter_lt Finset.Ico_filter_lt

@[simp]
theorem Ico_filter_le (a b c : α) : ((ico a b).filter fun x => c ≤ x) = ico (max a c) b := by
  cases le_total a c
  · rw [Ico_filter_le_of_left_le h, max_eq_right h]
    
  · rw [Ico_filter_le_of_le_left h, max_eq_left h]
    
#align finset.Ico_filter_le Finset.Ico_filter_le

@[simp]
theorem Ioo_filter_lt (a b c : α) : (ioo a b).filter (· < c) = ioo a (min b c) := by
  ext
  simp [and_assoc']
#align finset.Ioo_filter_lt Finset.Ioo_filter_lt

@[simp]
theorem Iio_filter_lt {α} [LinearOrder α] [LocallyFiniteOrderBot α] (a b : α) :
    (iio a).filter (· < b) = iio (min a b) := by
  ext
  simp [and_assoc']
#align finset.Iio_filter_lt Finset.Iio_filter_lt

@[simp]
theorem Ico_diff_Ico_left (a b c : α) : ico a b \ ico a c = ico (max a c) b := by
  cases le_total a c
  · ext x
    rw [mem_sdiff, mem_Ico, mem_Ico, mem_Ico, max_eq_right h, and_right_comm, not_and, not_lt]
    exact and_congr_left' ⟨fun hx => hx.2 hx.1, fun hx => ⟨h.trans hx, fun _ => hx⟩⟩
    
  · rw [Ico_eq_empty_of_le h, sdiff_empty, max_eq_left h]
    
#align finset.Ico_diff_Ico_left Finset.Ico_diff_Ico_left

@[simp]
theorem Ico_diff_Ico_right (a b c : α) : ico a b \ ico c b = ico a (min b c) := by
  cases le_total b c
  · rw [Ico_eq_empty_of_le h, sdiff_empty, min_eq_left h]
    
  · ext x
    rw [mem_sdiff, mem_Ico, mem_Ico, mem_Ico, min_eq_right h, and_assoc', not_and', not_le]
    exact and_congr_right' ⟨fun hx => hx.2 hx.1, fun hx => ⟨hx.trans_le h, fun _ => hx⟩⟩
    
#align finset.Ico_diff_Ico_right Finset.Ico_diff_Ico_right

end LocallyFiniteOrder

variable [Fintype α] [LocallyFiniteOrderTop α] [LocallyFiniteOrderBot α]

theorem Ioi_disj_union_Iio (a : α) : (ioi a).disjUnion (iio a) (disjoint_Ioi_Iio a) = ({a} : Finset α)ᶜ := by
  ext
  simp [eq_comm]
#align finset.Ioi_disj_union_Iio Finset.Ioi_disj_union_Iio

end LinearOrder

section OrderedCancelAddCommMonoid

variable [OrderedCancelAddCommMonoid α] [HasExistsAddOfLe α] [DecidableEq α] [LocallyFiniteOrder α]

theorem image_add_left_Icc (a b c : α) : (icc a b).image ((· + ·) c) = icc (c + a) (c + b) := by
  ext x
  rw [mem_image, mem_Icc]
  constructor
  · rintro ⟨y, hy, rfl⟩
    rw [mem_Icc] at hy
    exact ⟨add_le_add_left hy.1 c, add_le_add_left hy.2 c⟩
    
  · intro hx
    obtain ⟨y, hy⟩ := exists_add_of_le hx.1
    rw [add_assoc] at hy
    rw [hy] at hx
    exact ⟨a + y, mem_Icc.2 ⟨le_of_add_le_add_left hx.1, le_of_add_le_add_left hx.2⟩, hy.symm⟩
    
#align finset.image_add_left_Icc Finset.image_add_left_Icc

theorem image_add_left_Ico (a b c : α) : (ico a b).image ((· + ·) c) = ico (c + a) (c + b) := by
  ext x
  rw [mem_image, mem_Ico]
  constructor
  · rintro ⟨y, hy, rfl⟩
    rw [mem_Ico] at hy
    exact ⟨add_le_add_left hy.1 c, add_lt_add_left hy.2 c⟩
    
  · intro hx
    obtain ⟨y, hy⟩ := exists_add_of_le hx.1
    rw [add_assoc] at hy
    rw [hy] at hx
    exact ⟨a + y, mem_Ico.2 ⟨le_of_add_le_add_left hx.1, lt_of_add_lt_add_left hx.2⟩, hy.symm⟩
    
#align finset.image_add_left_Ico Finset.image_add_left_Ico

theorem image_add_left_Ioc (a b c : α) : (ioc a b).image ((· + ·) c) = ioc (c + a) (c + b) := by
  ext x
  rw [mem_image, mem_Ioc]
  refine' ⟨_, fun hx => _⟩
  · rintro ⟨y, hy, rfl⟩
    rw [mem_Ioc] at hy
    exact ⟨add_lt_add_left hy.1 c, add_le_add_left hy.2 c⟩
    
  · obtain ⟨y, hy⟩ := exists_add_of_le hx.1.le
    rw [add_assoc] at hy
    rw [hy] at hx
    exact ⟨a + y, mem_Ioc.2 ⟨lt_of_add_lt_add_left hx.1, le_of_add_le_add_left hx.2⟩, hy.symm⟩
    
#align finset.image_add_left_Ioc Finset.image_add_left_Ioc

theorem image_add_left_Ioo (a b c : α) : (ioo a b).image ((· + ·) c) = ioo (c + a) (c + b) := by
  ext x
  rw [mem_image, mem_Ioo]
  refine' ⟨_, fun hx => _⟩
  · rintro ⟨y, hy, rfl⟩
    rw [mem_Ioo] at hy
    exact ⟨add_lt_add_left hy.1 c, add_lt_add_left hy.2 c⟩
    
  · obtain ⟨y, hy⟩ := exists_add_of_le hx.1.le
    rw [add_assoc] at hy
    rw [hy] at hx
    exact ⟨a + y, mem_Ioo.2 ⟨lt_of_add_lt_add_left hx.1, lt_of_add_lt_add_left hx.2⟩, hy.symm⟩
    
#align finset.image_add_left_Ioo Finset.image_add_left_Ioo

theorem image_add_right_Icc (a b c : α) : (icc a b).image (· + c) = icc (a + c) (b + c) := by
  simp_rw [add_comm _ c]
  exact image_add_left_Icc a b c
#align finset.image_add_right_Icc Finset.image_add_right_Icc

theorem image_add_right_Ico (a b c : α) : (ico a b).image (· + c) = ico (a + c) (b + c) := by
  simp_rw [add_comm _ c]
  exact image_add_left_Ico a b c
#align finset.image_add_right_Ico Finset.image_add_right_Ico

theorem image_add_right_Ioc (a b c : α) : (ioc a b).image (· + c) = ioc (a + c) (b + c) := by
  simp_rw [add_comm _ c]
  exact image_add_left_Ioc a b c
#align finset.image_add_right_Ioc Finset.image_add_right_Ioc

theorem image_add_right_Ioo (a b c : α) : (ioo a b).image (· + c) = ioo (a + c) (b + c) := by
  simp_rw [add_comm _ c]
  exact image_add_left_Ioo a b c
#align finset.image_add_right_Ioo Finset.image_add_right_Ioo

end OrderedCancelAddCommMonoid

@[to_additive]
theorem prod_prod_Ioi_mul_eq_prod_prod_off_diag [Fintype ι] [LinearOrder ι] [LocallyFiniteOrderTop ι]
    [LocallyFiniteOrderBot ι] [CommMonoid α] (f : ι → ι → α) :
    (∏ i, ∏ j in ioi i, f j i * f i j) = ∏ i, ∏ j in {i}ᶜ, f j i := by
  simp_rw [← Ioi_disj_union_Iio, prod_disj_union, prod_mul_distrib]
  congr 1
  rw [prod_sigma', prod_sigma']
  refine' prod_bij' (fun i hi => ⟨i.2, i.1⟩) _ _ (fun i hi => ⟨i.2, i.1⟩) _ _ _ <;> simp
#align finset.prod_prod_Ioi_mul_eq_prod_prod_off_diag Finset.prod_prod_Ioi_mul_eq_prod_prod_off_diag

end Finset

