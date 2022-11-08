/-
Copyright (c) 2014 Parikshit Khanna. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Parikshit Khanna, Jeremy Avigad, Leonardo de Moura, Floris van Doorn, Mario Carneiro
-/
import Mathbin.Data.List.BigOperators

/-!
# Counting in lists

This file proves basic properties of `list.countp` and `list.count`, which count the number of
elements of a list satisfying a predicate and equal to a given element respectively. Their
definitions can be found in [`data.list.defs`](./defs).
-/


open Nat

variable {α β : Type _} {l l₁ l₂ : List α}

namespace List

section Countp

variable (p q : α → Prop) [DecidablePred p] [DecidablePred q]

@[simp]
theorem countp_nil : countp p [] = 0 :=
  rfl

@[simp]
theorem countp_cons_of_pos {a : α} (l) (pa : p a) : countp p (a :: l) = countp p l + 1 :=
  if_pos pa

@[simp]
theorem countp_cons_of_neg {a : α} (l) (pa : ¬p a) : countp p (a :: l) = countp p l :=
  if_neg pa

theorem countp_cons (a : α) (l) : countp p (a :: l) = countp p l + ite (p a) 1 0 := by by_cases h:p a <;> simp [h]

theorem length_eq_countp_add_countp (l) : length l = countp p l + countp (fun a => ¬p a) l := by
  induction' l with x h ih <;> [rfl, by_cases p x] <;>
      [simp only [countp_cons_of_pos _ _ h, countp_cons_of_neg (fun a => ¬p a) _ (Decidable.not_not.2 h), ih, length],
      simp only [countp_cons_of_pos (fun a => ¬p a) _ h, countp_cons_of_neg _ _ h, ih, length]] <;>
    ac_rfl

theorem countp_eq_length_filter (l) : countp p l = length (filter' p l) := by
  induction' l with x l ih <;> [rfl, by_cases p x] <;> [simp only [filter_cons_of_pos _ h, countp, ih, if_pos h],
      simp only [countp_cons_of_neg _ _ h, ih, filter_cons_of_neg _ h]] <;>
    rfl

theorem countp_le_length : countp p l ≤ l.length := by simpa only [countp_eq_length_filter] using length_filter_le _ _

@[simp]
theorem countp_append (l₁ l₂) : countp p (l₁ ++ l₂) = countp p l₁ + countp p l₂ := by
  simp only [countp_eq_length_filter, filter_append, length_append]

theorem countp_join : ∀ l : List (List α), countp p l.join = (l.map (countp p)).Sum
  | [] => rfl
  | a :: l => by rw [join, countp_append, map_cons, sum_cons, countp_join]

theorem countp_pos {l} : 0 < countp p l ↔ ∃ a ∈ l, p a := by
  simp only [countp_eq_length_filter, length_pos_iff_exists_mem, mem_filter, exists_prop]

@[simp]
theorem countp_eq_zero {l} : countp p l = 0 ↔ ∀ a ∈ l, ¬p a := by
  rw [← not_iff_not, ← Ne.def, ← pos_iff_ne_zero, countp_pos]
  simp

@[simp]
theorem countp_eq_length {l} : countp p l = l.length ↔ ∀ a ∈ l, p a := by
  rw [countp_eq_length_filter, filter_length_eq_length]

theorem length_filter_lt_length_iff_exists (l) : length (filter' p l) < length l ↔ ∃ x ∈ l, ¬p x := by
  rw [length_eq_countp_add_countp p l, ← countp_pos, countp_eq_length_filter, lt_add_iff_pos_right]

theorem Sublist.countp_le (s : l₁ <+ l₂) : countp p l₁ ≤ countp p l₂ := by
  simpa only [countp_eq_length_filter] using length_le_of_sublist (s.filter p)

@[simp]
theorem countp_filter (l : List α) : countp p (filter' q l) = countp (fun a => p a ∧ q a) l := by
  simp only [countp_eq_length_filter, filter_filter]

@[simp]
theorem countp_true : (l.countp fun _ => True) = l.length := by simp

@[simp]
theorem countp_false : (l.countp fun _ => False) = 0 := by simp

@[simp]
theorem countp_map (p : β → Prop) [DecidablePred p] (f : α → β) : ∀ l, countp p (map f l) = countp (p ∘ f) l
  | [] => rfl
  | a :: l => by rw [map_cons, countp_cons, countp_cons, countp_map]

variable {p q}

theorem countp_mono_left (h : ∀ x ∈ l, p x → q x) : countp p l ≤ countp q l := by
  induction' l with a l ihl
  · rfl
    
  rw [forall_mem_cons] at h
  cases' h with ha hl
  rw [countp_cons, countp_cons]
  refine' add_le_add (ihl hl) _
  split_ifs <;> try simp only [le_rfl, zero_le]
  exact absurd (ha ‹_›) ‹_›

theorem countp_congr (h : ∀ x ∈ l, p x ↔ q x) : countp p l = countp q l :=
  le_antisymm (countp_mono_left fun x hx => (h x hx).1) (countp_mono_left fun x hx => (h x hx).2)

end Countp

/-! ### count -/


section Count

variable [DecidableEq α]

@[simp]
theorem count_nil (a : α) : count a [] = 0 :=
  rfl

theorem count_cons (a b : α) (l : List α) : count a (b :: l) = if a = b then succ (count a l) else count a l :=
  rfl

theorem count_cons' (a b : α) (l : List α) : count a (b :: l) = count a l + if a = b then 1 else 0 := by
  rw [count_cons]
  split_ifs <;> rfl

@[simp]
theorem count_cons_self (a : α) (l : List α) : count a (a :: l) = count a l + 1 :=
  if_pos rfl

@[simp]
theorem count_cons_of_ne {a b : α} (h : a ≠ b) (l : List α) : count a (b :: l) = count a l :=
  if_neg h

theorem count_tail :
    ∀ (l : List α) (a : α) (h : 0 < l.length), l.tail.count a = l.count a - ite (a = List.nthLe l 0 h) 1 0
  | _ :: _, a, h => by
    rw [count_cons]
    split_ifs <;> simp

theorem count_le_length (a : α) (l : List α) : count a l ≤ l.length :=
  countp_le_length _

theorem Sublist.count_le (h : l₁ <+ l₂) (a : α) : count a l₁ ≤ count a l₂ :=
  h.countp_le _

theorem count_le_count_cons (a b : α) (l : List α) : count a l ≤ count a (b :: l) :=
  (sublist_cons _ _).count_le _

theorem count_singleton (a : α) : count a [a] = 1 :=
  if_pos rfl

theorem count_singleton' (a b : α) : count a [b] = ite (a = b) 1 0 :=
  rfl

@[simp]
theorem count_append (a : α) : ∀ l₁ l₂, count a (l₁ ++ l₂) = count a l₁ + count a l₂ :=
  countp_append _

theorem count_join (l : List (List α)) (a : α) : l.join.count a = (l.map (count a)).Sum :=
  countp_join _ _

theorem count_concat (a : α) (l : List α) : count a (concat l a) = succ (count a l) := by simp [-add_comm]

@[simp]
theorem count_pos {a : α} {l : List α} : 0 < count a l ↔ a ∈ l := by
  simp only [count, countp_pos, exists_prop, exists_eq_right']

@[simp]
theorem one_le_count_iff_mem {a : α} {l : List α} : 1 ≤ count a l ↔ a ∈ l :=
  count_pos

@[simp]
theorem count_eq_zero_of_not_mem {a : α} {l : List α} (h : a ∉ l) : count a l = 0 :=
  Decidable.by_contradiction fun h' => h <| count_pos.1 (Nat.pos_of_ne_zero h')

theorem not_mem_of_count_eq_zero {a : α} {l : List α} (h : count a l = 0) : a ∉ l := fun h' => (count_pos.2 h').ne' h

@[simp]
theorem count_eq_zero {a : α} {l} : count a l = 0 ↔ a ∉ l :=
  ⟨not_mem_of_count_eq_zero, count_eq_zero_of_not_mem⟩

@[simp]
theorem count_eq_length {a : α} {l} : count a l = l.length ↔ ∀ b ∈ l, a = b :=
  countp_eq_length _

@[simp]
theorem count_repeat (a : α) (n : ℕ) : count a (repeat a n) = n := by
  rw [count, countp_eq_length_filter, filter_eq_self.2, length_repeat] <;> exact fun b m => (eq_of_mem_repeat m).symm

theorem le_count_iff_repeat_sublist {a : α} {l : List α} {n : ℕ} : n ≤ count a l ↔ repeat a n <+ l :=
  ⟨fun h =>
    ((repeat_sublist_repeat a).2 h).trans <| by
      have : filter' (Eq a) l = repeat a (count a l) :=
        eq_repeat.2 ⟨by simp only [count, countp_eq_length_filter], fun b m => (of_mem_filter m).symm⟩
      rw [← this] <;> apply filter_sublist,
    fun h => by simpa only [count_repeat] using h.count_le a⟩

theorem repeat_count_eq_of_count_eq_length {a : α} {l : List α} (h : count a l = length l) : repeat a (count a l) = l :=
  (le_count_iff_repeat_sublist.mp le_rfl).eq_of_length <| (length_repeat a (count a l)).trans h

@[simp]
theorem count_filter {p} [DecidablePred p] {a} {l : List α} (h : p a) : count a (filter' p l) = count a l := by
  simp only [count, countp_filter,
    show (fun b => a = b ∧ p b) = Eq a by
      ext b
      constructor <;> cc]

theorem count_bind {α β} [DecidableEq β] (l : List α) (f : α → List β) (x : β) :
    count x (l.bind f) = sum (map (count x ∘ f) l) := by rw [List.bind, count_join, map_map]

@[simp]
theorem count_map_of_injective {α β} [DecidableEq α] [DecidableEq β] (l : List α) (f : α → β)
    (hf : Function.Injective f) (x : α) : count (f x) (map f l) = count x l := by
  simp only [count, countp_map, (· ∘ ·), hf.eq_iff]

theorem count_le_count_map [DecidableEq β] (l : List α) (f : α → β) (x : α) : count x l ≤ count (f x) (map f l) := by
  rw [count, count, countp_map]
  exact countp_mono_left fun y hyl => congr_arg f

theorem count_erase (a b : α) : ∀ l : List α, count a (l.erase b) = count a l - ite (a = b) 1 0
  | [] => by simp
  | c :: l => by
    rw [erase_cons]
    by_cases hc:c = b
    · rw [if_pos hc, hc, count_cons', Nat.add_sub_cancel]
      
    · rw [if_neg hc, count_cons', count_cons', count_erase]
      by_cases ha:a = b
      · rw [← ha, eq_comm] at hc
        rw [if_pos ha, if_neg hc, add_zero, add_zero]
        
      · rw [if_neg ha, tsub_zero, tsub_zero]
        
      

@[simp]
theorem count_erase_self (a : α) (l : List α) : count a (List.erase' l a) = count a l - 1 := by
  rw [count_erase, if_pos rfl]

@[simp]
theorem count_erase_of_ne {a b : α} (ab : a ≠ b) (l : List α) : count a (l.erase b) = count a l := by
  rw [count_erase, if_neg ab, tsub_zero]

/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (a' «expr ≠ » a) -/
@[to_additive]
theorem prod_map_eq_pow_single [Monoid β] {l : List α} (a : α) (f : α → β)
    (hf : ∀ (a') (_ : a' ≠ a), a' ∈ l → f a' = 1) : (l.map f).Prod = f a ^ l.count a := by
  induction' l with a' as h generalizing a
  · rw [map_nil, prod_nil, count_nil, pow_zero]
    
  · specialize h a fun a' ha' hfa' => hf a' ha' (mem_cons_of_mem _ hfa')
    rw [List.map_cons, List.prod_cons, count_cons, h]
    split_ifs with ha'
    · rw [ha', pow_succ]
      
    · rw [hf a' (Ne.symm ha') (List.mem_cons_self a' as), one_mul]
      
    

/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (a' «expr ≠ » a) -/
@[to_additive]
theorem prod_eq_pow_single [Monoid α] {l : List α} (a : α) (h : ∀ (a') (_ : a' ≠ a), a' ∈ l → a' = 1) :
    l.Prod = a ^ l.count a :=
  trans (by rw [map_id'']) (prod_map_eq_pow_single a id h)

end Count

end List

