/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module data.bool.count
! leanprover-community/mathlib commit a11f9106a169dd302a285019e5165f8ab32ff433
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Parity
import Mathbin.Data.List.Chain

/-!
# List of booleans

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove lemmas about the number of `ff`s and `tt`s in a list of booleans. First we
prove that the number of `ff`s plus the number of `tt` equals the length of the list. Then we prove
that in a list with alternating `tt`s and `ff`s, the number of `tt`s differs from the number of
`ff`s by at most one. We provide several versions of these statements.
-/


namespace List

#print List.count_not_add_count /-
@[simp]
theorem count_not_add_count (l : List Bool) (b : Bool) : count (!b) l + count b l = length l := by
  simp only [length_eq_countp_add_countp (Eq (!b)), Bool.not_not_eq, count]
#align list.count_bnot_add_count List.count_not_add_count
-/

#print List.count_add_count_not /-
@[simp]
theorem count_add_count_not (l : List Bool) (b : Bool) : count b l + count (!b) l = length l := by
  rw [add_comm, count_bnot_add_count]
#align list.count_add_count_bnot List.count_add_count_not
-/

#print List.count_false_add_count_true /-
@[simp]
theorem count_false_add_count_true (l : List Bool) : count false l + count true l = length l :=
  count_not_add_count l true
#align list.count_ff_add_count_tt List.count_false_add_count_true
-/

#print List.count_true_add_count_false /-
@[simp]
theorem count_true_add_count_false (l : List Bool) : count true l + count false l = length l :=
  count_not_add_count l false
#align list.count_tt_add_count_ff List.count_true_add_count_false
-/

#print List.Chain.count_not /-
theorem Chain.count_not :
    ∀ {b : Bool} {l : List Bool}, Chain (· ≠ ·) b l → count (!b) l = count b l + length l % 2
  | b, [], h => rfl
  | b, x :: l, h =>
    by
    obtain rfl : b = !x := Bool.eq_not_iff.2 (rel_of_chain_cons h)
    rw [Bool.not_not, count_cons_self, count_cons_of_ne x.bnot_ne_self,
      chain.count_bnot (chain_of_chain_cons h), length, add_assoc, Nat.mod_two_add_succ_mod_two]
#align list.chain.count_bnot List.Chain.count_not
-/

namespace Chain'

variable {l : List Bool}

#print List.Chain'.count_not_eq_count /-
theorem count_not_eq_count (hl : Chain' (· ≠ ·) l) (h2 : Even (length l)) (b : Bool) :
    count (!b) l = count b l := by
  cases' l with x l; · rfl
  rw [length_cons, Nat.even_add_one, Nat.not_even_iff] at h2 
  suffices count (!x) (x :: l) = count x (x :: l) by
    cases b <;> cases x <;> try exact this <;> exact this.symm
  rw [count_cons_of_ne x.bnot_ne_self, hl.count_bnot, h2, count_cons_self]
#align list.chain'.count_bnot_eq_count List.Chain'.count_not_eq_count
-/

#print List.Chain'.count_false_eq_count_true /-
theorem count_false_eq_count_true (hl : Chain' (· ≠ ·) l) (h2 : Even (length l)) :
    count false l = count true l :=
  hl.count_not_eq_count h2 true
#align list.chain'.count_ff_eq_count_tt List.Chain'.count_false_eq_count_true
-/

#print List.Chain'.count_not_le_count_add_one /-
theorem count_not_le_count_add_one (hl : Chain' (· ≠ ·) l) (b : Bool) :
    count (!b) l ≤ count b l + 1 := by
  cases' l with x l; · exact zero_le _
  obtain rfl | rfl : b = x ∨ b = !x := by simp only [Bool.eq_not_iff, em]
  · rw [count_cons_of_ne b.bnot_ne_self, count_cons_self, hl.count_bnot, add_assoc]
    exact add_le_add_left (Nat.mod_lt _ two_pos).le _
  · rw [Bool.not_not, count_cons_self, count_cons_of_ne x.bnot_ne_self, hl.count_bnot]
    exact add_le_add_right (le_add_right le_rfl) _
#align list.chain'.count_bnot_le_count_add_one List.Chain'.count_not_le_count_add_one
-/

#print List.Chain'.count_false_le_count_true_add_one /-
theorem count_false_le_count_true_add_one (hl : Chain' (· ≠ ·) l) :
    count false l ≤ count true l + 1 :=
  hl.count_not_le_count_add_one true
#align list.chain'.count_ff_le_count_tt_add_one List.Chain'.count_false_le_count_true_add_one
-/

#print List.Chain'.count_true_le_count_false_add_one /-
theorem count_true_le_count_false_add_one (hl : Chain' (· ≠ ·) l) :
    count true l ≤ count false l + 1 :=
  hl.count_not_le_count_add_one false
#align list.chain'.count_tt_le_count_ff_add_one List.Chain'.count_true_le_count_false_add_one
-/

#print List.Chain'.two_mul_count_bool_of_even /-
theorem two_mul_count_bool_of_even (hl : Chain' (· ≠ ·) l) (h2 : Even (length l)) (b : Bool) :
    2 * count b l = length l := by
  rw [← count_bnot_add_count l b, hl.count_bnot_eq_count h2, two_mul]
#align list.chain'.two_mul_count_bool_of_even List.Chain'.two_mul_count_bool_of_even
-/

#print List.Chain'.two_mul_count_bool_eq_ite /-
theorem two_mul_count_bool_eq_ite (hl : Chain' (· ≠ ·) l) (b : Bool) :
    2 * count b l =
      if Even (length l) then length l else if b ∈ l.head? then length l + 1 else length l - 1 :=
  by
  by_cases h2 : Even (length l)
  · rw [if_pos h2, hl.two_mul_count_bool_of_even h2]
  · cases' l with x l; · exact (h2 even_zero).elim
    simp only [if_neg h2, count_cons', mul_add, head', Option.mem_some_iff, @eq_comm _ x]
    rw [length_cons, Nat.even_add_one, Classical.not_not] at h2 
    replace hl : l.chain' (· ≠ ·) := hl.tail
    rw [hl.two_mul_count_bool_of_even h2]
    split_ifs <;> simp
#align list.chain'.two_mul_count_bool_eq_ite List.Chain'.two_mul_count_bool_eq_ite
-/

#print List.Chain'.length_sub_one_le_two_mul_count_bool /-
theorem length_sub_one_le_two_mul_count_bool (hl : Chain' (· ≠ ·) l) (b : Bool) :
    length l - 1 ≤ 2 * count b l := by rw [hl.two_mul_count_bool_eq_ite];
  split_ifs <;> simp [le_tsub_add, Nat.le_succ_of_le]
#align list.chain'.length_sub_one_le_two_mul_count_bool List.Chain'.length_sub_one_le_two_mul_count_bool
-/

#print List.Chain'.length_div_two_le_count_bool /-
theorem length_div_two_le_count_bool (hl : Chain' (· ≠ ·) l) (b : Bool) :
    length l / 2 ≤ count b l :=
  by
  rw [Nat.div_le_iff_le_mul_add_pred two_pos, ← tsub_le_iff_right]
  exact length_sub_one_le_two_mul_count_bool hl b
#align list.chain'.length_div_two_le_count_bool List.Chain'.length_div_two_le_count_bool
-/

#print List.Chain'.two_mul_count_bool_le_length_add_one /-
theorem two_mul_count_bool_le_length_add_one (hl : Chain' (· ≠ ·) l) (b : Bool) :
    2 * count b l ≤ length l + 1 := by rw [hl.two_mul_count_bool_eq_ite];
  split_ifs <;> simp [Nat.le_succ_of_le]
#align list.chain'.two_mul_count_bool_le_length_add_one List.Chain'.two_mul_count_bool_le_length_add_one
-/

end Chain'

end List

