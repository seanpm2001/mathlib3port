/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.multiset.range
! leanprover-community/mathlib commit f2f413b9d4be3a02840d0663dace76e8fe3da053
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Multiset.Basic
import Mathbin.Data.List.Range

/-! # `multiset.range n` gives `{0, 1, ..., n-1}` as a multiset. 

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.-/


open List Nat

namespace Multiset

#print Multiset.range /-
-- range
/-- `range n` is the multiset lifted from the list `range n`,
  that is, the set `{0, 1, ..., n-1}`. -/
def range (n : ℕ) : Multiset ℕ :=
  range n
#align multiset.range Multiset.range
-/

#print Multiset.coe_range /-
theorem coe_range (n : ℕ) : ↑(List.range n) = range n :=
  rfl
#align multiset.coe_range Multiset.coe_range
-/

#print Multiset.range_zero /-
@[simp]
theorem range_zero : range 0 = 0 :=
  rfl
#align multiset.range_zero Multiset.range_zero
-/

#print Multiset.range_succ /-
@[simp]
theorem range_succ (n : ℕ) : range (succ n) = n ::ₘ range n := by
  rw [range, range_succ, ← coe_add, add_comm] <;> rfl
#align multiset.range_succ Multiset.range_succ
-/

#print Multiset.card_range /-
@[simp]
theorem card_range (n : ℕ) : card (range n) = n :=
  length_range _
#align multiset.card_range Multiset.card_range
-/

#print Multiset.range_subset /-
theorem range_subset {m n : ℕ} : range m ⊆ range n ↔ m ≤ n :=
  range_subset
#align multiset.range_subset Multiset.range_subset
-/

#print Multiset.mem_range /-
@[simp]
theorem mem_range {m n : ℕ} : m ∈ range n ↔ m < n :=
  mem_range
#align multiset.mem_range Multiset.mem_range
-/

#print Multiset.not_mem_range_self /-
@[simp]
theorem not_mem_range_self {n : ℕ} : n ∉ range n :=
  not_mem_range_self
#align multiset.not_mem_range_self Multiset.not_mem_range_self
-/

#print Multiset.self_mem_range_succ /-
theorem self_mem_range_succ (n : ℕ) : n ∈ range (n + 1) :=
  List.self_mem_range_succ n
#align multiset.self_mem_range_succ Multiset.self_mem_range_succ
-/

#print Multiset.range_add /-
theorem range_add (a b : ℕ) : range (a + b) = range a + (range b).map fun x => a + x :=
  congr_arg coe (List.range_add _ _)
#align multiset.range_add Multiset.range_add
-/

#print Multiset.range_disjoint_map_add /-
theorem range_disjoint_map_add (a : ℕ) (m : Multiset ℕ) :
    (range a).Disjoint (m.map fun x => a + x) :=
  by
  intro x hxa hxb
  rw [range, mem_coe, List.mem_range] at hxa 
  obtain ⟨c, _, rfl⟩ := mem_map.1 hxb
  exact (self_le_add_right _ _).not_lt hxa
#align multiset.range_disjoint_map_add Multiset.range_disjoint_map_add
-/

#print Multiset.range_add_eq_union /-
theorem range_add_eq_union (a b : ℕ) : range (a + b) = range a ∪ (range b).map fun x => a + x := by
  rw [range_add, add_eq_union_iff_disjoint]; apply range_disjoint_map_add
#align multiset.range_add_eq_union Multiset.range_add_eq_union
-/

end Multiset

