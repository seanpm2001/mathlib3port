/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module data.list.sort
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.OfFn
import Mathbin.Data.List.Perm

/-!
# Sorting algorithms on lists

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `list.sorted r l` to be an alias for `pairwise r l`. This alias is preferred
in the case that `r` is a `<` or `≤`-like relation. Then we define two sorting algorithms:
`list.insertion_sort` and `list.merge_sort`, and prove their correctness.
-/


open List.Perm

universe uu

namespace List

/-!
### The predicate `list.sorted`
-/


section Sorted

variable {α : Type uu} {r : α → α → Prop} {a : α} {l : List α}

#print List.Sorted /-
/-- `sorted r l` is the same as `pairwise r l`, preferred in the case that `r`
  is a `<` or `≤`-like relation (transitive and antisymmetric or asymmetric) -/
def Sorted :=
  @Pairwise
#align list.sorted List.Sorted
-/

#print List.decidableSorted /-
instance decidableSorted [DecidableRel r] (l : List α) : Decidable (Sorted r l) :=
  List.instDecidablePairwise _
#align list.decidable_sorted List.decidableSorted
-/

#print List.sorted_nil /-
@[simp]
theorem sorted_nil : Sorted r [] :=
  Pairwise.nil
#align list.sorted_nil List.sorted_nil
-/

#print List.Sorted.of_cons /-
theorem Sorted.of_cons : Sorted r (a :: l) → Sorted r l :=
  Pairwise.of_cons
#align list.sorted.of_cons List.Sorted.of_cons
-/

#print List.Sorted.tail /-
theorem Sorted.tail {r : α → α → Prop} {l : List α} (h : Sorted r l) : Sorted r l.tail :=
  h.tail
#align list.sorted.tail List.Sorted.tail
-/

#print List.rel_of_sorted_cons /-
theorem rel_of_sorted_cons {a : α} {l : List α} : Sorted r (a :: l) → ∀ b ∈ l, r a b :=
  rel_of_pairwise_cons
#align list.rel_of_sorted_cons List.rel_of_sorted_cons
-/

#print List.sorted_cons /-
@[simp]
theorem sorted_cons {a : α} {l : List α} : Sorted r (a :: l) ↔ (∀ b ∈ l, r a b) ∧ Sorted r l :=
  pairwise_cons
#align list.sorted_cons List.sorted_cons
-/

#print List.Sorted.nodup /-
protected theorem Sorted.nodup {r : α → α → Prop} [IsIrrefl α r] {l : List α} (h : Sorted r l) :
    Nodup l :=
  h.Nodup
#align list.sorted.nodup List.Sorted.nodup
-/

#print List.eq_of_perm_of_sorted /-
theorem eq_of_perm_of_sorted [IsAntisymm α r] {l₁ l₂ : List α} (p : l₁ ~ l₂) (s₁ : Sorted r l₁)
    (s₂ : Sorted r l₂) : l₁ = l₂ :=
  by
  induction' s₁ with a l₁ h₁ s₁ IH generalizing l₂
  · exact p.nil_eq
  · have : a ∈ l₂ := p.subset (mem_cons_self _ _)
    rcases mem_split this with ⟨u₂, v₂, rfl⟩
    have p' := (perm_cons a).1 (p.trans perm_middle)
    obtain rfl := IH p' (s₂.sublist <| by simp)
    change a :: u₂ ++ v₂ = u₂ ++ ([a] ++ v₂); rw [← append_assoc]; congr
    have : ∀ (x : α) (h : x ∈ u₂), x = a := fun x m =>
      antisymm ((pairwise_append.1 s₂).2.2 _ m a (mem_cons_self _ _)) (h₁ _ (by simp [m]))
    rw [(@eq_replicate _ a (length u₂ + 1) (a :: u₂)).2,
          (@eq_replicate _ a (length u₂ + 1) (u₂ ++ [a])).2] <;>
        constructor <;>
      simp [iff_true_intro this, or_comm']
#align list.eq_of_perm_of_sorted List.eq_of_perm_of_sorted
-/

#print List.sublist_of_subperm_of_sorted /-
theorem sublist_of_subperm_of_sorted [IsAntisymm α r] {l₁ l₂ : List α} (p : l₁ <+~ l₂)
    (s₁ : l₁.Sorted r) (s₂ : l₂.Sorted r) : l₁ <+ l₂ :=
  by
  let ⟨_, h, h'⟩ := p
  rwa [← eq_of_perm_of_sorted h (s₂.sublist h') s₁]
#align list.sublist_of_subperm_of_sorted List.sublist_of_subperm_of_sorted
-/

#print List.sorted_singleton /-
@[simp]
theorem sorted_singleton (a : α) : Sorted r [a] :=
  pairwise_singleton _ _
#align list.sorted_singleton List.sorted_singleton
-/

#print List.Sorted.rel_nthLe_of_lt /-
theorem Sorted.rel_nthLe_of_lt {l : List α} (h : l.Sorted r) {a b : ℕ} (ha : a < l.length)
    (hb : b < l.length) (hab : a < b) : r (l.nthLe a ha) (l.nthLe b hb) :=
  List.pairwise_iff_nthLe.1 h a b hb hab
#align list.sorted.rel_nth_le_of_lt List.Sorted.rel_nthLe_of_lt
-/

#print List.Sorted.rel_nthLe_of_le /-
theorem Sorted.rel_nthLe_of_le [IsRefl α r] {l : List α} (h : l.Sorted r) {a b : ℕ}
    (ha : a < l.length) (hb : b < l.length) (hab : a ≤ b) : r (l.nthLe a ha) (l.nthLe b hb) :=
  by
  cases' eq_or_lt_of_le hab with H H
  · subst H; exact refl _
  · exact h.rel_nth_le_of_lt _ _ H
#align list.sorted.rel_nth_le_of_le List.Sorted.rel_nthLe_of_le
-/

#print List.Sorted.rel_of_mem_take_of_mem_drop /-
theorem Sorted.rel_of_mem_take_of_mem_drop {l : List α} (h : List.Sorted r l) {k : ℕ} {x y : α}
    (hx : x ∈ List.take k l) (hy : y ∈ List.drop k l) : r x y :=
  by
  obtain ⟨iy, hiy, rfl⟩ := nth_le_of_mem hy
  obtain ⟨ix, hix, rfl⟩ := nth_le_of_mem hx
  rw [nth_le_take', nth_le_drop']
  rw [length_take] at hix 
  exact h.rel_nth_le_of_lt _ _ (ix.lt_add_right _ _ (lt_min_iff.mp hix).left)
#align list.sorted.rel_of_mem_take_of_mem_drop List.Sorted.rel_of_mem_take_of_mem_drop
-/

end Sorted

section Monotone

variable {n : ℕ} {α : Type uu} [Preorder α] {f : Fin n → α}

#print List.monotone_iff_ofFn_sorted /-
/-- A tuple is monotone if and only if the list obtained from it is sorted. -/
theorem monotone_iff_ofFn_sorted : Monotone f ↔ (ofFn f).Sorted (· ≤ ·) :=
  by
  simp_rw [sorted, pairwise_iff_nth_le, length_of_fn, nth_le_of_fn', monotone_iff_forall_lt]
  exact ⟨fun h i j hj hij => h <| fin.mk_lt_mk.mpr hij, fun h ⟨i, _⟩ ⟨j, hj⟩ hij => h i j hj hij⟩
#align list.monotone_iff_of_fn_sorted List.monotone_iff_ofFn_sorted
-/

#print Monotone.ofFn_sorted /-
/-- The list obtained from a monotone tuple is sorted. -/
theorem Monotone.ofFn_sorted (h : Monotone f) : (ofFn f).Sorted (· ≤ ·) :=
  monotone_iff_ofFn_sorted.1 h
#align list.monotone.of_fn_sorted Monotone.ofFn_sorted
-/

end Monotone

section Sort

variable {α : Type uu} (r : α → α → Prop) [DecidableRel r]

local infixl:50 " ≼ " => r

/-! ### Insertion sort -/


section InsertionSort

#print List.orderedInsert /-
/-- `ordered_insert a l` inserts `a` into `l` at such that
  `ordered_insert a l` is sorted if `l` is. -/
@[simp]
def orderedInsert (a : α) : List α → List α
  | [] => [a]
  | b :: l => if a ≼ b then a :: b :: l else b :: ordered_insert l
#align list.ordered_insert List.orderedInsert
-/

#print List.insertionSort /-
/-- `insertion_sort l` returns `l` sorted using the insertion sort algorithm. -/
@[simp]
def insertionSort : List α → List α
  | [] => []
  | b :: l => orderedInsert r b (insertion_sort l)
#align list.insertion_sort List.insertionSort
-/

#print List.orderedInsert_nil /-
@[simp]
theorem orderedInsert_nil (a : α) : [].orderedInsert r a = [a] :=
  rfl
#align list.ordered_insert_nil List.orderedInsert_nil
-/

#print List.orderedInsert_length /-
theorem orderedInsert_length : ∀ (L : List α) (a : α), (L.orderedInsert r a).length = L.length + 1
  | [], a => rfl
  | hd :: tl, a => by dsimp [ordered_insert]; split_ifs <;> simp [ordered_insert_length]
#align list.ordered_insert_length List.orderedInsert_length
-/

#print List.orderedInsert_eq_take_drop /-
/-- An alternative definition of `ordered_insert` using `take_while` and `drop_while`. -/
theorem orderedInsert_eq_take_drop (a : α) :
    ∀ l : List α,
      l.orderedInsert r a = (l.takeWhile fun b => ¬a ≼ b) ++ a :: l.dropWhileₓ fun b => ¬a ≼ b
  | [] => rfl
  | b :: l => by dsimp only [ordered_insert]; split_ifs <;> simp [take_while, drop_while, *]
#align list.ordered_insert_eq_take_drop List.orderedInsert_eq_take_drop
-/

#print List.insertionSort_cons_eq_take_drop /-
theorem insertionSort_cons_eq_take_drop (a : α) (l : List α) :
    insertionSort r (a :: l) =
      ((insertionSort r l).takeWhile fun b => ¬a ≼ b) ++
        a :: (insertionSort r l).dropWhileₓ fun b => ¬a ≼ b :=
  orderedInsert_eq_take_drop r a _
#align list.insertion_sort_cons_eq_take_drop List.insertionSort_cons_eq_take_drop
-/

section Correctness

open Perm

#print List.perm_orderedInsert /-
theorem perm_orderedInsert (a) : ∀ l : List α, orderedInsert r a l ~ a :: l
  | [] => Perm.refl _
  | b :: l => by
    by_cases a ≼ b <;> [simp [ordered_insert, h];
      simpa [ordered_insert, h] using ((perm_ordered_insert l).cons _).trans (perm.swap _ _ _)]
#align list.perm_ordered_insert List.perm_orderedInsert
-/

#print List.orderedInsert_count /-
theorem orderedInsert_count [DecidableEq α] (L : List α) (a b : α) :
    count a (L.orderedInsert r b) = count a L + if a = b then 1 else 0 :=
  by
  rw [(L.perm_ordered_insert r b).count_eq, count_cons]
  split_ifs <;> simp only [Nat.succ_eq_add_one, add_zero]
#align list.ordered_insert_count List.orderedInsert_count
-/

#print List.perm_insertionSort /-
theorem perm_insertionSort : ∀ l : List α, insertionSort r l ~ l
  | [] => Perm.nil
  | b :: l => by
    simpa [insertion_sort] using (perm_ordered_insert _ _ _).trans ((perm_insertion_sort l).cons b)
#align list.perm_insertion_sort List.perm_insertionSort
-/

variable {r}

#print List.Sorted.insertionSort_eq /-
/-- If `l` is already `list.sorted` with respect to `r`, then `insertion_sort` does not change
it. -/
theorem Sorted.insertionSort_eq : ∀ {l : List α} (h : Sorted r l), insertionSort r l = l
  | [], _ => rfl
  | [a], _ => rfl
  | a :: b :: l, h =>
    by
    rw [insertion_sort, sorted.insertion_sort_eq, ordered_insert, if_pos]
    exacts [rel_of_sorted_cons h _ (Or.inl rfl), h.tail]
#align list.sorted.insertion_sort_eq List.Sorted.insertionSort_eq
-/

section TotalAndTransitive

variable [IsTotal α r] [IsTrans α r]

#print List.Sorted.orderedInsert /-
theorem Sorted.orderedInsert (a : α) : ∀ l, Sorted r l → Sorted r (orderedInsert r a l)
  | [], h => sorted_singleton a
  | b :: l, h => by
    by_cases h' : a ≼ b
    · simpa [ordered_insert, h', h] using fun b' bm => trans h' (rel_of_sorted_cons h _ bm)
    · suffices ∀ b' : α, b' ∈ ordered_insert r a l → r b b' by
        simpa [ordered_insert, h', h.of_cons.ordered_insert l]
      intro b' bm
      cases' show b' = a ∨ b' ∈ l by simpa using (perm_ordered_insert _ _ _).Subset bm with be bm
      · subst b'; exact (total_of r _ _).resolve_left h'
      · exact rel_of_sorted_cons h _ bm
#align list.sorted.ordered_insert List.Sorted.orderedInsert
-/

variable (r)

#print List.sorted_insertionSort /-
/-- The list `list.insertion_sort r l` is `list.sorted` with respect to `r`. -/
theorem sorted_insertionSort : ∀ l, Sorted r (insertionSort r l)
  | [] => sorted_nil
  | a :: l => (sorted_insertion_sort l).orderedInsert a _
#align list.sorted_insertion_sort List.sorted_insertionSort
-/

end TotalAndTransitive

end Correctness

end InsertionSort

/-! ### Merge sort -/


section MergeSort

#print List.split /-
-- TODO(Jeremy): observation: if instead we write (a :: (split l).1, b :: (split l).2), the
-- equation compiler can't prove the third equation
/-- Split `l` into two lists of approximately equal length.

     split [1, 2, 3, 4, 5] = ([1, 3, 5], [2, 4]) -/
@[simp]
def split : List α → List α × List α
  | [] => ([], [])
  | a :: l =>
    let (l₁, l₂) := split l
    (a :: l₂, l₁)
#align list.split List.split
-/

#print List.split_cons_of_eq /-
theorem split_cons_of_eq (a : α) {l l₁ l₂ : List α} (h : split l = (l₁, l₂)) :
    split (a :: l) = (a :: l₂, l₁) := by rw [split, h] <;> rfl
#align list.split_cons_of_eq List.split_cons_of_eq
-/

#print List.length_split_le /-
theorem length_split_le :
    ∀ {l l₁ l₂ : List α}, split l = (l₁, l₂) → length l₁ ≤ length l ∧ length l₂ ≤ length l
  | [], _, _, rfl => ⟨Nat.le_refl 0, Nat.le_refl 0⟩
  | a :: l, l₁', l₂', h => by
    cases' e : split l with l₁ l₂
    injection (split_cons_of_eq _ e).symm.trans h; substs l₁' l₂'
    cases' length_split_le e with h₁ h₂
    exact ⟨Nat.succ_le_succ h₂, Nat.le_succ_of_le h₁⟩
#align list.length_split_le List.length_split_le
-/

#print List.length_split_lt /-
theorem length_split_lt {a b} {l l₁ l₂ : List α} (h : split (a :: b :: l) = (l₁, l₂)) :
    length l₁ < length (a :: b :: l) ∧ length l₂ < length (a :: b :: l) :=
  by
  cases' e : split l with l₁' l₂'
  injection (split_cons_of_eq _ (split_cons_of_eq _ e)).symm.trans h; substs l₁ l₂
  cases' length_split_le e with h₁ h₂
  exact ⟨Nat.succ_le_succ (Nat.succ_le_succ h₁), Nat.succ_le_succ (Nat.succ_le_succ h₂)⟩
#align list.length_split_lt List.length_split_lt
-/

#print List.perm_split /-
theorem perm_split : ∀ {l l₁ l₂ : List α}, split l = (l₁, l₂) → l ~ l₁ ++ l₂
  | [], _, _, rfl => Perm.refl _
  | a :: l, l₁', l₂', h => by
    cases' e : split l with l₁ l₂
    injection (split_cons_of_eq _ e).symm.trans h; substs l₁' l₂'
    exact ((perm_split e).trans perm_append_comm).cons a
#align list.perm_split List.perm_split
-/

#print List.merge /-
/-- Merge two sorted lists into one in linear time.

     merge [1, 2, 4, 5] [0, 1, 3, 4] = [0, 1, 1, 2, 3, 4, 4, 5] -/
def merge : List α → List α → List α
  | [], l' => l'
  | l, [] => l
  | a :: l, b :: l' => if a ≼ b then a :: merge l (b :: l') else b :: merge (a :: l) l'
#align list.merge List.merge
-/

#print List.mergeSort /-
/-- Implementation of a merge sort algorithm to sort a list. -/
def mergeSort : List α → List α
  | [] => []
  | [a] => [a]
  | a :: b :: l => by
    cases' e : split (a :: b :: l) with l₁ l₂
    cases' length_split_lt e with h₁ h₂
    exact merge r (merge_sort l₁) (merge_sort l₂)
termination_by' ⟨_, InvImage.wf length Nat.lt_wfRel⟩
#align list.merge_sort List.mergeSort
-/

#print List.mergeSort_cons_cons /-
theorem mergeSort_cons_cons {a b} {l l₁ l₂ : List α} (h : split (a :: b :: l) = (l₁, l₂)) :
    mergeSort r (a :: b :: l) = merge r (mergeSort r l₁) (mergeSort r l₂) :=
  by
  suffices
    ∀ (L : List α) (h1),
      @And.ndrec (fun a a (_ : length l₁ < length l + 1 + 1 ∧ length l₂ < length l + 1 + 1) => L) h1
          h1 =
        L
    by simp [merge_sort, h]; apply this
  intros; cases h1; rfl
#align list.merge_sort_cons_cons List.mergeSort_cons_cons
-/

section Correctness

#print List.perm_merge /-
theorem perm_merge : ∀ l l' : List α, merge r l l' ~ l ++ l'
  | [], [] => by simp [merge]
  | [], b :: l' => by simp [merge]
  | a :: l, [] => by simp [merge]
  | a :: l, b :: l' => by
    by_cases a ≼ b
    · simpa [merge, h] using perm_merge _ _
    · suffices b :: merge r (a :: l) l' ~ a :: (l ++ b :: l') by simpa [merge, h]
      exact ((perm_merge _ _).cons _).trans ((swap _ _ _).trans (perm_middle.symm.cons _))
#align list.perm_merge List.perm_merge
-/

#print List.perm_mergeSort /-
theorem perm_mergeSort : ∀ l : List α, mergeSort r l ~ l
  | [] => by simp [merge_sort]
  | [a] => by simp [merge_sort]
  | a :: b :: l => by
    cases' e : split (a :: b :: l) with l₁ l₂
    cases' length_split_lt e with h₁ h₂
    rw [merge_sort_cons_cons r e]
    apply (perm_merge r _ _).trans
    exact ((perm_merge_sort l₁).append (perm_merge_sort l₂)).trans (perm_split e).symm
termination_by' ⟨_, InvImage.wf length Nat.lt_wfRel⟩
#align list.perm_merge_sort List.perm_mergeSort
-/

#print List.length_mergeSort /-
@[simp]
theorem length_mergeSort (l : List α) : (mergeSort r l).length = l.length :=
  (perm_mergeSort r _).length_eq
#align list.length_merge_sort List.length_mergeSort
-/

section TotalAndTransitive

variable {r} [IsTotal α r] [IsTrans α r]

#print List.Sorted.merge /-
theorem Sorted.merge : ∀ {l l' : List α}, Sorted r l → Sorted r l' → Sorted r (merge r l l')
  | [], [], h₁, h₂ => by simp [merge]
  | [], b :: l', h₁, h₂ => by simpa [merge] using h₂
  | a :: l, [], h₁, h₂ => by simpa [merge] using h₁
  | a :: l, b :: l', h₁, h₂ => by
    by_cases a ≼ b
    · suffices ∀ (b' : α) (_ : b' ∈ merge r l (b :: l')), r a b' by
        simpa [merge, h, h₁.of_cons.merge h₂]
      intro b' bm
      rcases show b' = b ∨ b' ∈ l ∨ b' ∈ l' by
          simpa [or_left_comm] using (perm_merge _ _ _).Subset bm with
        (be | bl | bl')
      · subst b'; assumption
      · exact rel_of_sorted_cons h₁ _ bl
      · exact trans h (rel_of_sorted_cons h₂ _ bl')
    · suffices ∀ (b' : α) (_ : b' ∈ merge r (a :: l) l'), r b b' by
        simpa [merge, h, h₁.merge h₂.of_cons]
      intro b' bm
      have ba : b ≼ a := (total_of r _ _).resolve_left h
      rcases show b' = a ∨ b' ∈ l ∨ b' ∈ l' by simpa using (perm_merge _ _ _).Subset bm with
        (be | bl | bl')
      · subst b'; assumption
      · exact trans ba (rel_of_sorted_cons h₁ _ bl)
      · exact rel_of_sorted_cons h₂ _ bl'
#align list.sorted.merge List.Sorted.merge
-/

variable (r)

#print List.sorted_mergeSort /-
theorem sorted_mergeSort : ∀ l : List α, Sorted r (mergeSort r l)
  | [] => by simp [merge_sort]
  | [a] => by simp [merge_sort]
  | a :: b :: l => by
    cases' e : split (a :: b :: l) with l₁ l₂
    cases' length_split_lt e with h₁ h₂
    rw [merge_sort_cons_cons r e]
    exact (sorted_merge_sort l₁).merge (sorted_merge_sort l₂)
termination_by' ⟨_, InvImage.wf length Nat.lt_wfRel⟩
#align list.sorted_merge_sort List.sorted_mergeSort
-/

#print List.mergeSort_eq_self /-
theorem mergeSort_eq_self [IsAntisymm α r] {l : List α} : Sorted r l → mergeSort r l = l :=
  eq_of_perm_of_sorted (perm_mergeSort _ _) (sorted_mergeSort _ _)
#align list.merge_sort_eq_self List.mergeSort_eq_self
-/

#print List.mergeSort_eq_insertionSort /-
theorem mergeSort_eq_insertionSort [IsAntisymm α r] (l : List α) :
    mergeSort r l = insertionSort r l :=
  eq_of_perm_of_sorted ((perm_mergeSort r l).trans (perm_insertionSort r l).symm)
    (sorted_mergeSort r l) (sorted_insertionSort r l)
#align list.merge_sort_eq_insertion_sort List.mergeSort_eq_insertionSort
-/

end TotalAndTransitive

end Correctness

#print List.mergeSort_nil /-
@[simp]
theorem mergeSort_nil : [].mergeSort r = [] := by rw [List.mergeSort]
#align list.merge_sort_nil List.mergeSort_nil
-/

#print List.mergeSort_singleton /-
@[simp]
theorem mergeSort_singleton (a : α) : [a].mergeSort r = [a] := by rw [List.mergeSort]
#align list.merge_sort_singleton List.mergeSort_singleton
-/

end MergeSort

end Sort

-- try them out! 
--#eval insertion_sort (λ m n : ℕ, m ≤ n) [5, 27, 221, 95, 17, 43, 7, 2, 98, 567, 23, 12]
--#eval merge_sort     (λ m n : ℕ, m ≤ n) [5, 27, 221, 95, 17, 43, 7, 2, 98, 567, 23, 12]
end List

