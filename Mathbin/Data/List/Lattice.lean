/-
Copyright (c) 2014 Parikshit Khanna. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Parikshit Khanna, Jeremy Avigad, Leonardo de Moura, Floris van Doorn, Mario Carneiro,
Scott Morrison

! This file was ported from Lean 3 source module data.list.lattice
! leanprover-community/mathlib commit be24ec5de6701447e5df5ca75400ffee19d65659
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.Count
import Mathbin.Data.List.Infix
import Mathbin.Algebra.Order.Monoid.MinMax

/-!
# Lattice structure of lists

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This files prove basic properties about `list.disjoint`, `list.union`, `list.inter` and
`list.bag_inter`, which are defined in core Lean and `data.list.defs`.

`l₁ ∪ l₂` is the list where all elements of `l₁` have been inserted in `l₂` in order. For example,
`[0, 0, 1, 2, 2, 3] ∪ [4, 3, 3, 0] = [1, 2, 4, 3, 3, 0]`

`l₁ ∩ l₂` is the list of elements of `l₁` in order which are in `l₂`. For example,
`[0, 0, 1, 2, 2, 3] ∪ [4, 3, 3, 0] = [0, 0, 3]`

`bag_inter l₁ l₂` is the list of elements that are in both `l₁` and `l₂`, counted with multiplicity
and in the order they appear in `l₁`. As opposed to `list.inter`, `list.bag_inter` copes well with
multiplicity. For example,
`bag_inter [0, 1, 2, 3, 2, 1, 0] [1, 0, 1, 4, 3] = [0, 1, 3, 1]`
-/


open Nat

namespace List

variable {α : Type _} {l l₁ l₂ : List α} {p : α → Prop} {a : α}

/-! ### `disjoint` -/


section Disjoint

#print List.Disjoint.symm /-
theorem Disjoint.symm (d : Disjoint l₁ l₂) : Disjoint l₂ l₁ := fun a i₂ i₁ => d i₁ i₂
#align list.disjoint.symm List.Disjoint.symm
-/

#print List.disjoint_comm /-
theorem disjoint_comm : Disjoint l₁ l₂ ↔ Disjoint l₂ l₁ :=
  ⟨Disjoint.symm, Disjoint.symm⟩
#align list.disjoint_comm List.disjoint_comm
-/

#print List.disjoint_left /-
theorem disjoint_left : Disjoint l₁ l₂ ↔ ∀ ⦃a⦄, a ∈ l₁ → a ∉ l₂ :=
  Iff.rfl
#align list.disjoint_left List.disjoint_left
-/

#print List.disjoint_right /-
theorem disjoint_right : Disjoint l₁ l₂ ↔ ∀ ⦃a⦄, a ∈ l₂ → a ∉ l₁ :=
  disjoint_comm
#align list.disjoint_right List.disjoint_right
-/

#print List.disjoint_iff_ne /-
theorem disjoint_iff_ne : Disjoint l₁ l₂ ↔ ∀ a ∈ l₁, ∀ b ∈ l₂, a ≠ b := by
  simp only [disjoint_left, imp_not_comm, forall_eq']
#align list.disjoint_iff_ne List.disjoint_iff_ne
-/

theorem disjoint_of_subset_left (ss : l₁ ⊆ l) (d : Disjoint l l₂) : Disjoint l₁ l₂ := fun x m =>
  d (ss m)
#align list.disjoint_of_subset_left List.disjoint_of_subset_leftₓ

#print List.disjoint_of_subset_right /-
theorem disjoint_of_subset_right (ss : l₂ ⊆ l) (d : Disjoint l₁ l) : Disjoint l₁ l₂ := fun x m m₁ =>
  d m (ss m₁)
#align list.disjoint_of_subset_right List.disjoint_of_subset_right
-/

#print List.disjoint_of_disjoint_cons_left /-
theorem disjoint_of_disjoint_cons_left {l₁ l₂} : Disjoint (a :: l₁) l₂ → Disjoint l₁ l₂ :=
  disjoint_of_subset_left (List.subset_cons _ _)
#align list.disjoint_of_disjoint_cons_left List.disjoint_of_disjoint_cons_left
-/

#print List.disjoint_of_disjoint_cons_right /-
theorem disjoint_of_disjoint_cons_right {l₁ l₂} : Disjoint l₁ (a :: l₂) → Disjoint l₁ l₂ :=
  disjoint_of_subset_right (List.subset_cons _ _)
#align list.disjoint_of_disjoint_cons_right List.disjoint_of_disjoint_cons_right
-/

#print List.disjoint_nil_left /-
@[simp]
theorem disjoint_nil_left (l : List α) : Disjoint [] l := fun a => (not_mem_nil a).elim
#align list.disjoint_nil_left List.disjoint_nil_left
-/

#print List.disjoint_nil_right /-
@[simp]
theorem disjoint_nil_right (l : List α) : Disjoint l [] := by rw [disjoint_comm];
  exact disjoint_nil_left _
#align list.disjoint_nil_right List.disjoint_nil_right
-/

@[simp]
theorem singleton_disjoint : Disjoint [a] l ↔ a ∉ l := by
  simp only [Disjoint, mem_singleton, forall_eq]; rfl
#align list.singleton_disjoint List.singleton_disjointₓ

#print List.disjoint_singleton /-
@[simp]
theorem disjoint_singleton : Disjoint l [a] ↔ a ∉ l := by rw [disjoint_comm, singleton_disjoint]
#align list.disjoint_singleton List.disjoint_singleton
-/

@[simp]
theorem disjoint_append_left : Disjoint (l₁ ++ l₂) l ↔ Disjoint l₁ l ∧ Disjoint l₂ l := by
  simp only [Disjoint, mem_append, or_imp, forall_and]
#align list.disjoint_append_left List.disjoint_append_leftₓ

#print List.disjoint_append_right /-
@[simp]
theorem disjoint_append_right : Disjoint l (l₁ ++ l₂) ↔ Disjoint l l₁ ∧ Disjoint l l₂ :=
  disjoint_comm.trans <| by simp only [disjoint_comm, disjoint_append_left]
#align list.disjoint_append_right List.disjoint_append_right
-/

@[simp]
theorem disjoint_cons_left : Disjoint (a :: l₁) l₂ ↔ a ∉ l₂ ∧ Disjoint l₁ l₂ :=
  (@disjoint_append_left _ l₂ [a] l₁).trans <| by simp only [singleton_disjoint]
#align list.disjoint_cons_left List.disjoint_cons_leftₓ

#print List.disjoint_cons_right /-
@[simp]
theorem disjoint_cons_right : Disjoint l₁ (a :: l₂) ↔ a ∉ l₁ ∧ Disjoint l₁ l₂ :=
  disjoint_comm.trans <| by simp only [disjoint_comm, disjoint_cons_left]
#align list.disjoint_cons_right List.disjoint_cons_right
-/

theorem disjoint_of_disjoint_append_left_left (d : Disjoint (l₁ ++ l₂) l) : Disjoint l₁ l :=
  (disjoint_append_left.1 d).1
#align list.disjoint_of_disjoint_append_left_left List.disjoint_of_disjoint_append_left_leftₓ

theorem disjoint_of_disjoint_append_left_right (d : Disjoint (l₁ ++ l₂) l) : Disjoint l₂ l :=
  (disjoint_append_left.1 d).2
#align list.disjoint_of_disjoint_append_left_right List.disjoint_of_disjoint_append_left_rightₓ

#print List.disjoint_of_disjoint_append_right_left /-
theorem disjoint_of_disjoint_append_right_left (d : Disjoint l (l₁ ++ l₂)) : Disjoint l l₁ :=
  (disjoint_append_right.1 d).1
#align list.disjoint_of_disjoint_append_right_left List.disjoint_of_disjoint_append_right_left
-/

#print List.disjoint_of_disjoint_append_right_right /-
theorem disjoint_of_disjoint_append_right_right (d : Disjoint l (l₁ ++ l₂)) : Disjoint l l₂ :=
  (disjoint_append_right.1 d).2
#align list.disjoint_of_disjoint_append_right_right List.disjoint_of_disjoint_append_right_right
-/

theorem disjoint_take_drop {m n : ℕ} (hl : l.Nodup) (h : m ≤ n) : Disjoint (l.take m) (l.drop n) :=
  by
  induction l generalizing m n
  case nil m n => simp
  case cons x xs xs_ih m
    n =>
    cases m <;> cases n <;>
      simp only [disjoint_cons_left, mem_cons_iff, disjoint_cons_right, drop, true_or_iff,
        eq_self_iff_true, not_true, false_and_iff, disjoint_nil_left, take]
    · cases h
    cases' hl with _ _ h₀ h₁; constructor
    · intro h; exact h₀ _ (mem_of_mem_drop h) rfl
    solve_by_elim (config := { max_depth := 4 }) [le_of_succ_le_succ]
#align list.disjoint_take_drop List.disjoint_take_dropₓ

end Disjoint

variable [DecidableEq α]

/-! ### `union` -/


section Union

#print List.nil_union /-
@[simp]
theorem nil_union (l : List α) : [] ∪ l = l :=
  rfl
#align list.nil_union List.nil_union
-/

@[simp]
theorem cons_union (l₁ l₂ : List α) (a : α) : a :: l₁ ∪ l₂ = insert a (l₁ ∪ l₂) :=
  rfl
#align list.cons_union List.cons_unionₓ

#print List.mem_union /-
@[simp]
theorem mem_union : a ∈ l₁ ∪ l₂ ↔ a ∈ l₁ ∨ a ∈ l₂ := by
  induction l₁ <;>
    simp only [nil_union, not_mem_nil, false_or_iff, cons_union, mem_insert_iff, mem_cons_iff,
      or_assoc', *]
#align list.mem_union List.mem_union
-/

#print List.mem_union_left /-
theorem mem_union_left (h : a ∈ l₁) (l₂ : List α) : a ∈ l₁ ∪ l₂ :=
  mem_union.2 (Or.inl h)
#align list.mem_union_left List.mem_union_left
-/

#print List.mem_union_right /-
theorem mem_union_right (l₁ : List α) (h : a ∈ l₂) : a ∈ l₁ ∪ l₂ :=
  mem_union.2 (Or.inr h)
#align list.mem_union_right List.mem_union_right
-/

#print List.sublist_suffix_of_union /-
theorem sublist_suffix_of_union : ∀ l₁ l₂ : List α, ∃ t, t <+ l₁ ∧ t ++ l₂ = l₁ ∪ l₂
  | [], l₂ => ⟨[], by rfl, rfl⟩
  | a :: l₁, l₂ =>
    let ⟨t, s, e⟩ := sublist_suffix_of_union l₁ l₂
    if h : a ∈ l₁ ∪ l₂ then
      ⟨t, sublist_cons_of_sublist _ s, by simp only [e, cons_union, insert_of_mem h]⟩
    else
      ⟨a :: t, s.cons_cons _, by
        simp only [cons_append, cons_union, e, insert_of_not_mem h] <;> constructor <;> rfl⟩
#align list.sublist_suffix_of_union List.sublist_suffix_of_union
-/

#print List.suffix_union_right /-
theorem suffix_union_right (l₁ l₂ : List α) : l₂ <:+ l₁ ∪ l₂ :=
  (sublist_suffix_of_union l₁ l₂).imp fun a => And.right
#align list.suffix_union_right List.suffix_union_right
-/

#print List.union_sublist_append /-
theorem union_sublist_append (l₁ l₂ : List α) : l₁ ∪ l₂ <+ l₁ ++ l₂ :=
  let ⟨t, s, e⟩ := sublist_suffix_of_union l₁ l₂
  e ▸ (append_sublist_append_right _).2 s
#align list.union_sublist_append List.union_sublist_append
-/

#print List.forall_mem_union /-
theorem forall_mem_union : (∀ x ∈ l₁ ∪ l₂, p x) ↔ (∀ x ∈ l₁, p x) ∧ ∀ x ∈ l₂, p x := by
  simp only [mem_union, or_imp, forall_and]
#align list.forall_mem_union List.forall_mem_union
-/

#print List.forall_mem_of_forall_mem_union_left /-
theorem forall_mem_of_forall_mem_union_left (h : ∀ x ∈ l₁ ∪ l₂, p x) : ∀ x ∈ l₁, p x :=
  (forall_mem_union.1 h).1
#align list.forall_mem_of_forall_mem_union_left List.forall_mem_of_forall_mem_union_left
-/

#print List.forall_mem_of_forall_mem_union_right /-
theorem forall_mem_of_forall_mem_union_right (h : ∀ x ∈ l₁ ∪ l₂, p x) : ∀ x ∈ l₂, p x :=
  (forall_mem_union.1 h).2
#align list.forall_mem_of_forall_mem_union_right List.forall_mem_of_forall_mem_union_right
-/

end Union

/-! ### `inter` -/


section Inter

#print List.inter_nil /-
@[simp]
theorem inter_nil (l : List α) : [] ∩ l = [] :=
  rfl
#align list.inter_nil List.inter_nil
-/

#print List.inter_cons_of_mem /-
@[simp]
theorem inter_cons_of_mem (l₁ : List α) (h : a ∈ l₂) : (a :: l₁) ∩ l₂ = a :: l₁ ∩ l₂ :=
  if_pos h
#align list.inter_cons_of_mem List.inter_cons_of_mem
-/

#print List.inter_cons_of_not_mem /-
@[simp]
theorem inter_cons_of_not_mem (l₁ : List α) (h : a ∉ l₂) : (a :: l₁) ∩ l₂ = l₁ ∩ l₂ :=
  if_neg h
#align list.inter_cons_of_not_mem List.inter_cons_of_not_mem
-/

#print List.mem_of_mem_inter_left /-
theorem mem_of_mem_inter_left : a ∈ l₁ ∩ l₂ → a ∈ l₁ :=
  mem_of_mem_filter
#align list.mem_of_mem_inter_left List.mem_of_mem_inter_left
-/

#print List.mem_of_mem_inter_right /-
theorem mem_of_mem_inter_right : a ∈ l₁ ∩ l₂ → a ∈ l₂ :=
  of_mem_filter
#align list.mem_of_mem_inter_right List.mem_of_mem_inter_right
-/

#print List.mem_inter_of_mem_of_mem /-
theorem mem_inter_of_mem_of_mem : a ∈ l₁ → a ∈ l₂ → a ∈ l₁ ∩ l₂ :=
  mem_filter_of_mem
#align list.mem_inter_of_mem_of_mem List.mem_inter_of_mem_of_mem
-/

#print List.mem_inter /-
@[simp]
theorem mem_inter : a ∈ l₁ ∩ l₂ ↔ a ∈ l₁ ∧ a ∈ l₂ :=
  mem_filter
#align list.mem_inter List.mem_inter
-/

#print List.inter_subset_left /-
theorem inter_subset_left (l₁ l₂ : List α) : l₁ ∩ l₂ ⊆ l₁ :=
  filter_subset _
#align list.inter_subset_left List.inter_subset_left
-/

#print List.inter_subset_right /-
theorem inter_subset_right (l₁ l₂ : List α) : l₁ ∩ l₂ ⊆ l₂ := fun a => mem_of_mem_inter_right
#align list.inter_subset_right List.inter_subset_right
-/

#print List.subset_inter /-
theorem subset_inter {l l₁ l₂ : List α} (h₁ : l ⊆ l₁) (h₂ : l ⊆ l₂) : l ⊆ l₁ ∩ l₂ := fun a h =>
  mem_inter.2 ⟨h₁ h, h₂ h⟩
#align list.subset_inter List.subset_inter
-/

#print List.inter_eq_nil_iff_disjoint /-
theorem inter_eq_nil_iff_disjoint : l₁ ∩ l₂ = [] ↔ Disjoint l₁ l₂ := by
  simp only [eq_nil_iff_forall_not_mem, mem_inter, not_and]; rfl
#align list.inter_eq_nil_iff_disjoint List.inter_eq_nil_iff_disjoint
-/

#print List.forall_mem_inter_of_forall_left /-
theorem forall_mem_inter_of_forall_left (h : ∀ x ∈ l₁, p x) (l₂ : List α) :
    ∀ x, x ∈ l₁ ∩ l₂ → p x :=
  BAll.imp_left (fun x => mem_of_mem_inter_left) h
#align list.forall_mem_inter_of_forall_left List.forall_mem_inter_of_forall_left
-/

#print List.forall_mem_inter_of_forall_right /-
theorem forall_mem_inter_of_forall_right (l₁ : List α) (h : ∀ x ∈ l₂, p x) :
    ∀ x, x ∈ l₁ ∩ l₂ → p x :=
  BAll.imp_left (fun x => mem_of_mem_inter_right) h
#align list.forall_mem_inter_of_forall_right List.forall_mem_inter_of_forall_right
-/

#print List.inter_reverse /-
@[simp]
theorem inter_reverse {xs ys : List α} : xs.inter ys.reverse = xs.inter ys := by
  simp only [List.inter, mem_reverse]
#align list.inter_reverse List.inter_reverse
-/

end Inter

/-! ### `bag_inter` -/


section BagInter

#print List.nil_bagInter /-
@[simp]
theorem nil_bagInter (l : List α) : [].bagInterₓ l = [] := by cases l <;> rfl
#align list.nil_bag_inter List.nil_bagInter
-/

#print List.bagInter_nil /-
@[simp]
theorem bagInter_nil (l : List α) : l.bagInterₓ [] = [] := by cases l <;> rfl
#align list.bag_inter_nil List.bagInter_nil
-/

#print List.cons_bagInter_of_pos /-
@[simp]
theorem cons_bagInter_of_pos (l₁ : List α) (h : a ∈ l₂) :
    (a :: l₁).bagInterₓ l₂ = a :: l₁.bagInterₓ (l₂.eraseₓ a) := by cases l₂ <;> exact if_pos h
#align list.cons_bag_inter_of_pos List.cons_bagInter_of_pos
-/

#print List.cons_bagInter_of_neg /-
@[simp]
theorem cons_bagInter_of_neg (l₁ : List α) (h : a ∉ l₂) :
    (a :: l₁).bagInterₓ l₂ = l₁.bagInterₓ l₂ :=
  by
  cases l₂; · simp only [bag_inter_nil]
  simp only [erase_of_not_mem h, List.bagInter, if_neg h]
#align list.cons_bag_inter_of_neg List.cons_bagInter_of_neg
-/

#print List.mem_bagInter /-
@[simp]
theorem mem_bagInter {a : α} : ∀ {l₁ l₂ : List α}, a ∈ l₁.bagInterₓ l₂ ↔ a ∈ l₁ ∧ a ∈ l₂
  | [], l₂ => by simp only [nil_bag_inter, not_mem_nil, false_and_iff]
  | b :: l₁, l₂ => by
    by_cases b ∈ l₂
    · rw [cons_bag_inter_of_pos _ h, mem_cons_iff, mem_cons_iff, mem_bag_inter]
      by_cases ba : a = b
      · simp only [ba, h, eq_self_iff_true, true_or_iff, true_and_iff]
      · simp only [mem_erase_of_ne ba, ba, false_or_iff]
    · rw [cons_bag_inter_of_neg _ h, mem_bag_inter, mem_cons_iff, or_and_right]
      symm; apply or_iff_right_of_imp
      rintro ⟨rfl, h'⟩; exact h.elim h'
#align list.mem_bag_inter List.mem_bagInter
-/

#print List.count_bagInter /-
@[simp]
theorem count_bagInter {a : α} :
    ∀ {l₁ l₂ : List α}, count a (l₁.bagInterₓ l₂) = min (count a l₁) (count a l₂)
  | [], l₂ => by simp
  | l₁, [] => by simp
  | b :: l₁, l₂ => by
    by_cases hb : b ∈ l₂
    · rw [cons_bag_inter_of_pos _ hb, count_cons', count_cons', count_bag_inter, count_erase, ←
        min_add_add_right]
      by_cases ab : a = b
      · rw [if_pos ab, tsub_add_cancel_of_le]
        rwa [succ_le_iff, count_pos, ab]
      · rw [if_neg ab, tsub_zero, add_zero, add_zero]
    · rw [cons_bag_inter_of_neg _ hb, count_bag_inter]
      by_cases ab : a = b
      · rw [← ab] at hb ; rw [count_eq_zero.2 hb, min_zero, min_zero]
      · rw [count_cons_of_ne ab]
#align list.count_bag_inter List.count_bagInter
-/

#print List.bagInter_sublist_left /-
theorem bagInter_sublist_left : ∀ l₁ l₂ : List α, l₁.bagInterₓ l₂ <+ l₁
  | [], l₂ => by simp
  | b :: l₁, l₂ =>
    by
    by_cases b ∈ l₂ <;> simp only [h, cons_bag_inter_of_pos, cons_bag_inter_of_neg, not_false_iff]
    · exact (bag_inter_sublist_left _ _).cons_cons _
    · apply sublist_cons_of_sublist; apply bag_inter_sublist_left
#align list.bag_inter_sublist_left List.bagInter_sublist_left
-/

#print List.bagInter_nil_iff_inter_nil /-
theorem bagInter_nil_iff_inter_nil : ∀ l₁ l₂ : List α, l₁.bagInterₓ l₂ = [] ↔ l₁ ∩ l₂ = []
  | [], l₂ => by simp
  | b :: l₁, l₂ => by
    by_cases h : b ∈ l₂ <;> simp [h]
    exact bag_inter_nil_iff_inter_nil l₁ l₂
#align list.bag_inter_nil_iff_inter_nil List.bagInter_nil_iff_inter_nil
-/

end BagInter

end List

