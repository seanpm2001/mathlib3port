/-
Copyright (c) 2014 Parikshit Khanna. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Parikshit Khanna, Jeremy Avigad, Leonardo de Moura, Floris van Doorn, Mario Carneiro

! This file was ported from Lean 3 source module data.list.count
! leanprover-community/mathlib commit 47adfab39a11a072db552f47594bf8ed2cf8a722
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.BigOperators.Basic

/-!
# Counting in lists

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves basic properties of `list.countp` and `list.count`, which count the number of
elements of a list satisfying a predicate and equal to a given element respectively. Their
definitions can be found in [`data.list.defs`](./defs).
-/


open Nat

variable {α β : Type _} {l l₁ l₂ : List α}

namespace List

section Countp

variable (p q : α → Prop) [DecidablePred p] [DecidablePred q]

#print List.countp_nil /-
@[simp]
theorem countp_nil : countp p [] = 0 :=
  rfl
#align list.countp_nil List.countp_nil
-/

#print List.countp_cons_of_pos /-
@[simp]
theorem countp_cons_of_pos {a : α} (l) (pa : p a) : countp p (a :: l) = countp p l + 1 :=
  if_pos pa
#align list.countp_cons_of_pos List.countp_cons_of_pos
-/

#print List.countp_cons_of_neg /-
@[simp]
theorem countp_cons_of_neg {a : α} (l) (pa : ¬p a) : countp p (a :: l) = countp p l :=
  if_neg pa
#align list.countp_cons_of_neg List.countp_cons_of_neg
-/

#print List.countp_cons /-
theorem countp_cons (a : α) (l) : countp p (a :: l) = countp p l + ite (p a) 1 0 := by
  by_cases h : p a <;> simp [h]
#align list.countp_cons List.countp_cons
-/

#print List.length_eq_countp_add_countp /-
theorem length_eq_countp_add_countp (l) : length l = countp p l + countp (fun a => ¬p a) l := by
  induction' l with x h ih <;> [rfl; by_cases p x] <;>
      [simp only [countp_cons_of_pos _ _ h,
        countp_cons_of_neg (fun a => ¬p a) _ (Decidable.not_not.2 h), ih, length];
      simp only [countp_cons_of_pos (fun a => ¬p a) _ h, countp_cons_of_neg _ _ h, ih, length]] <;>
    ac_rfl
#align list.length_eq_countp_add_countp List.length_eq_countp_add_countp
-/

#print List.countp_eq_length_filter /-
theorem countp_eq_length_filter (l) : countp p l = length (filter p l) := by
  induction' l with x l ih <;> [rfl; by_cases p x] <;>
      [simp only [filter_cons_of_pos _ h, countp, ih, if_pos h];
      simp only [countp_cons_of_neg _ _ h, ih, filter_cons_of_neg _ h]] <;>
    rfl
#align list.countp_eq_length_filter List.countp_eq_length_filter
-/

#print List.countp_le_length /-
theorem countp_le_length : countp p l ≤ l.length := by
  simpa only [countp_eq_length_filter] using length_filter_le _ _
#align list.countp_le_length List.countp_le_length
-/

#print List.countp_append /-
@[simp]
theorem countp_append (l₁ l₂) : countp p (l₁ ++ l₂) = countp p l₁ + countp p l₂ := by
  simp only [countp_eq_length_filter, filter_append, length_append]
#align list.countp_append List.countp_append
-/

#print List.countp_join /-
theorem countp_join : ∀ l : List (List α), countp p l.join = (l.map (countp p)).Sum
  | [] => rfl
  | a :: l => by rw [join, countp_append, map_cons, sum_cons, countp_join]
#align list.countp_join List.countp_join
-/

#print List.countp_pos /-
theorem countp_pos {l} : 0 < countp p l ↔ ∃ a ∈ l, p a := by
  simp only [countp_eq_length_filter, length_pos_iff_exists_mem, mem_filter, exists_prop]
#align list.countp_pos List.countp_pos
-/

#print List.countp_eq_zero /-
@[simp]
theorem countp_eq_zero {l} : countp p l = 0 ↔ ∀ a ∈ l, ¬p a := by
  rw [← not_iff_not, ← Ne.def, ← pos_iff_ne_zero, countp_pos]; simp
#align list.countp_eq_zero List.countp_eq_zero
-/

#print List.countp_eq_length /-
@[simp]
theorem countp_eq_length {l} : countp p l = l.length ↔ ∀ a ∈ l, p a := by
  rw [countp_eq_length_filter, filter_length_eq_length]
#align list.countp_eq_length List.countp_eq_length
-/

#print List.length_filter_lt_length_iff_exists /-
theorem length_filter_lt_length_iff_exists (l) : length (filter p l) < length l ↔ ∃ x ∈ l, ¬p x :=
  by
  rw [length_eq_countp_add_countp p l, ← countp_pos, countp_eq_length_filter, lt_add_iff_pos_right]
#align list.length_filter_lt_length_iff_exists List.length_filter_lt_length_iff_exists
-/

#print List.Sublist.countp_le /-
theorem Sublist.countp_le (s : l₁ <+ l₂) : countp p l₁ ≤ countp p l₂ := by
  simpa only [countp_eq_length_filter] using length_le_of_sublist (s.filter p)
#align list.sublist.countp_le List.Sublist.countp_le
-/

#print List.countp_filter /-
@[simp]
theorem countp_filter (l : List α) : countp p (filter q l) = countp (fun a => p a ∧ q a) l := by
  simp only [countp_eq_length_filter, filter_filter]
#align list.countp_filter List.countp_filter
-/

#print List.countp_true /-
@[simp]
theorem countp_true : (l.countp fun _ => True) = l.length := by simp
#align list.countp_true List.countp_true
-/

#print List.countp_false /-
@[simp]
theorem countp_false : (l.countp fun _ => False) = 0 := by simp
#align list.countp_false List.countp_false
-/

#print List.countp_map /-
@[simp]
theorem countp_map (p : β → Prop) [DecidablePred p] (f : α → β) :
    ∀ l, countp p (map f l) = countp (p ∘ f) l
  | [] => rfl
  | a :: l => by rw [map_cons, countp_cons, countp_cons, countp_map]
#align list.countp_map List.countp_map
-/

variable {p q}

#print List.countp_mono_left /-
theorem countp_mono_left (h : ∀ x ∈ l, p x → q x) : countp p l ≤ countp q l :=
  by
  induction' l with a l ihl; · rfl
  rw [forall_mem_cons] at h ; cases' h with ha hl
  rw [countp_cons, countp_cons]
  refine' add_le_add (ihl hl) _
  split_ifs <;> try simp only [le_rfl, zero_le]
  exact absurd (ha ‹_›) ‹_›
#align list.countp_mono_left List.countp_mono_left
-/

#print List.countp_congr /-
theorem countp_congr (h : ∀ x ∈ l, p x ↔ q x) : countp p l = countp q l :=
  le_antisymm (countp_mono_left fun x hx => (h x hx).1) (countp_mono_left fun x hx => (h x hx).2)
#align list.countp_congr List.countp_congr
-/

end Countp

/-! ### count -/


section Count

variable [DecidableEq α]

#print List.count_nil /-
@[simp]
theorem count_nil (a : α) : count a [] = 0 :=
  rfl
#align list.count_nil List.count_nil
-/

#print List.count_cons /-
theorem count_cons (a b : α) (l : List α) :
    count a (b :: l) = if a = b then succ (count a l) else count a l :=
  rfl
#align list.count_cons List.count_cons
-/

#print List.count_cons' /-
theorem count_cons' (a b : α) (l : List α) :
    count a (b :: l) = count a l + if a = b then 1 else 0 := by rw [count_cons]; split_ifs <;> rfl
#align list.count_cons' List.count_cons'
-/

#print List.count_cons_self /-
@[simp]
theorem count_cons_self (a : α) (l : List α) : count a (a :: l) = count a l + 1 :=
  if_pos rfl
#align list.count_cons_self List.count_cons_self
-/

#print List.count_cons_of_ne /-
@[simp]
theorem count_cons_of_ne {a b : α} (h : a ≠ b) (l : List α) : count a (b :: l) = count a l :=
  if_neg h
#align list.count_cons_of_ne List.count_cons_of_ne
-/

#print List.count_tail /-
theorem count_tail :
    ∀ (l : List α) (a : α) (h : 0 < l.length),
      l.tail.count a = l.count a - ite (a = List.nthLe l 0 h) 1 0
  | _ :: _, a, h => by rw [count_cons]; split_ifs <;> simp
#align list.count_tail List.count_tail
-/

#print List.count_le_length /-
theorem count_le_length (a : α) (l : List α) : count a l ≤ l.length :=
  countp_le_length _
#align list.count_le_length List.count_le_length
-/

#print List.Sublist.count_le /-
theorem Sublist.count_le (h : l₁ <+ l₂) (a : α) : count a l₁ ≤ count a l₂ :=
  h.countp_le _
#align list.sublist.count_le List.Sublist.count_le
-/

#print List.count_le_count_cons /-
theorem count_le_count_cons (a b : α) (l : List α) : count a l ≤ count a (b :: l) :=
  (sublist_cons _ _).count_le _
#align list.count_le_count_cons List.count_le_count_cons
-/

#print List.count_singleton /-
theorem count_singleton (a : α) : count a [a] = 1 :=
  if_pos rfl
#align list.count_singleton List.count_singleton
-/

#print List.count_singleton' /-
theorem count_singleton' (a b : α) : count a [b] = ite (a = b) 1 0 :=
  rfl
#align list.count_singleton' List.count_singleton'
-/

#print List.count_append /-
@[simp]
theorem count_append (a : α) : ∀ l₁ l₂, count a (l₁ ++ l₂) = count a l₁ + count a l₂ :=
  countp_append _
#align list.count_append List.count_append
-/

#print List.count_join /-
theorem count_join (l : List (List α)) (a : α) : l.join.count a = (l.map (count a)).Sum :=
  countp_join _ _
#align list.count_join List.count_join
-/

#print List.count_concat /-
theorem count_concat (a : α) (l : List α) : count a (concat l a) = succ (count a l) := by
  simp [-add_comm]
#align list.count_concat List.count_concat
-/

#print List.count_pos /-
@[simp]
theorem count_pos {a : α} {l : List α} : 0 < count a l ↔ a ∈ l := by
  simp only [count, countp_pos, exists_prop, exists_eq_right']
#align list.count_pos List.count_pos
-/

#print List.one_le_count_iff_mem /-
@[simp]
theorem one_le_count_iff_mem {a : α} {l : List α} : 1 ≤ count a l ↔ a ∈ l :=
  count_pos
#align list.one_le_count_iff_mem List.one_le_count_iff_mem
-/

#print List.count_eq_zero_of_not_mem /-
@[simp]
theorem count_eq_zero_of_not_mem {a : α} {l : List α} (h : a ∉ l) : count a l = 0 :=
  Decidable.by_contradiction fun h' => h <| count_pos.1 (Nat.pos_of_ne_zero h')
#align list.count_eq_zero_of_not_mem List.count_eq_zero_of_not_mem
-/

#print List.not_mem_of_count_eq_zero /-
theorem not_mem_of_count_eq_zero {a : α} {l : List α} (h : count a l = 0) : a ∉ l := fun h' =>
  (count_pos.2 h').ne' h
#align list.not_mem_of_count_eq_zero List.not_mem_of_count_eq_zero
-/

#print List.count_eq_zero /-
@[simp]
theorem count_eq_zero {a : α} {l} : count a l = 0 ↔ a ∉ l :=
  ⟨not_mem_of_count_eq_zero, count_eq_zero_of_not_mem⟩
#align list.count_eq_zero List.count_eq_zero
-/

#print List.count_eq_length /-
@[simp]
theorem count_eq_length {a : α} {l} : count a l = l.length ↔ ∀ b ∈ l, a = b :=
  countp_eq_length _
#align list.count_eq_length List.count_eq_length
-/

#print List.count_replicate_self /-
@[simp]
theorem count_replicate_self (a : α) (n : ℕ) : count a (replicate n a) = n := by
  rw [count, countp_eq_length_filter, filter_eq_self.2, length_replicate] <;>
    exact fun b m => (eq_of_mem_replicate m).symm
#align list.count_replicate_self List.count_replicate_self
-/

#print List.count_replicate /-
theorem count_replicate (a b : α) (n : ℕ) : count a (replicate n b) = if a = b then n else 0 :=
  by
  split_ifs with h
  exacts [h ▸ count_replicate_self _ _, count_eq_zero_of_not_mem <| mt eq_of_mem_replicate h]
#align list.count_replicate List.count_replicate
-/

#print List.filter_eq /-
theorem filter_eq (l : List α) (a : α) : l.filterₓ (Eq a) = replicate (count a l) a := by
  simp [eq_replicate, count, countp_eq_length_filter, @eq_comm _ _ a]
#align list.filter_eq List.filter_eq
-/

#print List.filter_eq' /-
theorem filter_eq' (l : List α) (a : α) : (l.filterₓ fun x => x = a) = replicate (count a l) a := by
  simp only [filter_eq, @eq_comm _ _ a]
#align list.filter_eq' List.filter_eq'
-/

#print List.le_count_iff_replicate_sublist /-
theorem le_count_iff_replicate_sublist {a : α} {l : List α} {n : ℕ} :
    n ≤ count a l ↔ replicate n a <+ l :=
  ⟨fun h => ((replicate_sublist_replicate a).2 h).trans <| filter_eq l a ▸ filter_sublist _,
    fun h => by simpa only [count_replicate_self] using h.count_le a⟩
#align list.le_count_iff_replicate_sublist List.le_count_iff_replicate_sublist
-/

#print List.replicate_count_eq_of_count_eq_length /-
theorem replicate_count_eq_of_count_eq_length {a : α} {l : List α} (h : count a l = length l) :
    replicate (count a l) a = l :=
  (le_count_iff_replicate_sublist.mp le_rfl).eq_of_length <|
    (length_replicate (count a l) a).trans h
#align list.replicate_count_eq_of_count_eq_length List.replicate_count_eq_of_count_eq_length
-/

#print List.count_filter /-
@[simp]
theorem count_filter {p} [DecidablePred p] {a} {l : List α} (h : p a) :
    count a (filter p l) = count a l := by
  simp only [count, countp_filter, show (fun b => a = b ∧ p b) = Eq a by ext b; constructor <;> cc]
#align list.count_filter List.count_filter
-/

#print List.count_bind /-
theorem count_bind {α β} [DecidableEq β] (l : List α) (f : α → List β) (x : β) :
    count x (l.bind f) = sum (map (count x ∘ f) l) := by rw [List.bind, count_join, map_map]
#align list.count_bind List.count_bind
-/

#print List.count_map_of_injective /-
@[simp]
theorem count_map_of_injective {α β} [DecidableEq α] [DecidableEq β] (l : List α) (f : α → β)
    (hf : Function.Injective f) (x : α) : count (f x) (map f l) = count x l := by
  simp only [count, countp_map, (· ∘ ·), hf.eq_iff]
#align list.count_map_of_injective List.count_map_of_injective
-/

#print List.count_le_count_map /-
theorem count_le_count_map [DecidableEq β] (l : List α) (f : α → β) (x : α) :
    count x l ≤ count (f x) (map f l) :=
  by
  rw [count, count, countp_map]
  exact countp_mono_left fun y hyl => congr_arg f
#align list.count_le_count_map List.count_le_count_map
-/

#print List.count_erase /-
theorem count_erase (a b : α) : ∀ l : List α, count a (l.eraseₓ b) = count a l - ite (a = b) 1 0
  | [] => by simp
  | c :: l => by
    rw [erase_cons]
    by_cases hc : c = b
    · rw [if_pos hc, hc, count_cons', Nat.add_sub_cancel]
    · rw [if_neg hc, count_cons', count_cons', count_erase]
      by_cases ha : a = b
      · rw [← ha, eq_comm] at hc 
        rw [if_pos ha, if_neg hc, add_zero, add_zero]
      · rw [if_neg ha, tsub_zero, tsub_zero]
#align list.count_erase List.count_erase
-/

#print List.count_erase_self /-
@[simp]
theorem count_erase_self (a : α) (l : List α) : count a (List.erase l a) = count a l - 1 := by
  rw [count_erase, if_pos rfl]
#align list.count_erase_self List.count_erase_self
-/

#print List.count_erase_of_ne /-
@[simp]
theorem count_erase_of_ne {a b : α} (ab : a ≠ b) (l : List α) : count a (l.eraseₓ b) = count a l :=
  by rw [count_erase, if_neg ab, tsub_zero]
#align list.count_erase_of_ne List.count_erase_of_ne
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (a' «expr ≠ » a) -/
#print List.prod_map_eq_pow_single /-
@[to_additive]
theorem prod_map_eq_pow_single [Monoid β] {l : List α} (a : α) (f : α → β)
    (hf : ∀ (a') (_ : a' ≠ a), a' ∈ l → f a' = 1) : (l.map f).Prod = f a ^ l.count a :=
  by
  induction' l with a' as h generalizing a
  · rw [map_nil, prod_nil, count_nil, pow_zero]
  · specialize h a fun a' ha' hfa' => hf a' ha' (mem_cons_of_mem _ hfa')
    rw [List.map_cons, List.prod_cons, count_cons, h]
    split_ifs with ha'
    · rw [ha', pow_succ]
    · rw [hf a' (Ne.symm ha') (List.mem_cons_self a' as), one_mul]
#align list.prod_map_eq_pow_single List.prod_map_eq_pow_single
#align list.sum_map_eq_nsmul_single List.sum_map_eq_nsmul_single
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (a' «expr ≠ » a) -/
#print List.prod_eq_pow_single /-
@[to_additive]
theorem prod_eq_pow_single [Monoid α] {l : List α} (a : α)
    (h : ∀ (a') (_ : a' ≠ a), a' ∈ l → a' = 1) : l.Prod = a ^ l.count a :=
  trans (by rw [map_id'']) (prod_map_eq_pow_single a id h)
#align list.prod_eq_pow_single List.prod_eq_pow_single
#align list.sum_eq_nsmul_single List.sum_eq_nsmul_single
-/

end Count

end List

