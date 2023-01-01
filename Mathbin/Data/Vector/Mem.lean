/-
Copyright (c) 2022 Devon Tuma. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Devon Tuma

! This file was ported from Lean 3 source module data.vector.mem
! leanprover-community/mathlib commit 9aba7801eeecebb61f58a5763c2b6dd1b47dc6ef
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Vector.Basic

/-!
# Theorems about membership of elements in vectors

This file contains theorems for membership in a `v.to_list` for a vector `v`.
Having the length available in the type allows some of the lemmas to be
  simpler and more general than the original version for lists.
In particular we can avoid some assumptions about types being `inhabited`,
  and make more general statements about `head` and `tail`.
-/


namespace Vector

variable {α β : Type _} {n : ℕ} (a a' : α)

@[simp]
theorem nth_mem (i : Fin n) (v : Vector α n) : v.nth i ∈ v.toList :=
  by
  rw [nth_eq_nth_le]
  exact List.nth_le_mem _ _ _
#align vector.nth_mem Vector.nth_mem

theorem mem_iff_nth (v : Vector α n) : a ∈ v.toList ↔ ∃ i, v.nth i = a := by
  simp only [List.mem_iff_nth_le, Fin.exists_iff, Vector.nth_eq_nth_le] <;>
    exact
      ⟨fun ⟨i, hi, h⟩ => ⟨i, by rwa [to_list_length] at hi, h⟩, fun ⟨i, hi, h⟩ =>
        ⟨i, by rwa [to_list_length], h⟩⟩
#align vector.mem_iff_nth Vector.mem_iff_nth

theorem not_mem_nil : a ∉ (Vector.nil : Vector α 0).toList :=
  id
#align vector.not_mem_nil Vector.not_mem_nil

theorem not_mem_zero (v : Vector α 0) : a ∉ v.toList :=
  (Vector.eq_nil v).symm ▸ not_mem_nil a
#align vector.not_mem_zero Vector.not_mem_zero

theorem mem_cons_iff (v : Vector α n) : a' ∈ (a ::ᵥ v).toList ↔ a' = a ∨ a' ∈ v.toList := by
  rw [Vector.toList_cons, List.mem_cons_iff]
#align vector.mem_cons_iff Vector.mem_cons_iff

theorem mem_succ_iff (v : Vector α (n + 1)) : a ∈ v.toList ↔ a = v.head ∨ a ∈ v.tail.toList :=
  by
  obtain ⟨a', v', h⟩ := exists_eq_cons v
  simp_rw [h, Vector.mem_cons_iff, Vector.head_cons, Vector.tail_cons]
#align vector.mem_succ_iff Vector.mem_succ_iff

theorem mem_cons_self (v : Vector α n) : a ∈ (a ::ᵥ v).toList :=
  (Vector.mem_iff_nth a (a ::ᵥ v)).2 ⟨0, Vector.nth_cons_zero a v⟩
#align vector.mem_cons_self Vector.mem_cons_self

@[simp]
theorem head_mem (v : Vector α (n + 1)) : v.head ∈ v.toList :=
  (Vector.mem_iff_nth v.head v).2 ⟨0, Vector.nth_zero v⟩
#align vector.head_mem Vector.head_mem

theorem mem_cons_of_mem (v : Vector α n) (ha' : a' ∈ v.toList) : a' ∈ (a ::ᵥ v).toList :=
  (Vector.mem_cons_iff a a' v).2 (Or.inr ha')
#align vector.mem_cons_of_mem Vector.mem_cons_of_mem

theorem mem_of_mem_tail (v : Vector α n) (ha : a ∈ v.tail.toList) : a ∈ v.toList :=
  by
  induction' n with n hn
  · exact False.elim (Vector.not_mem_zero a v.tail ha)
  · exact (mem_succ_iff a v).2 (Or.inr ha)
#align vector.mem_of_mem_tail Vector.mem_of_mem_tail

theorem mem_map_iff (b : β) (v : Vector α n) (f : α → β) :
    b ∈ (v.map f).toList ↔ ∃ a : α, a ∈ v.toList ∧ f a = b := by
  rw [Vector.to_list_map, List.mem_map]
#align vector.mem_map_iff Vector.mem_map_iff

theorem not_mem_map_zero (b : β) (v : Vector α 0) (f : α → β) : b ∉ (v.map f).toList := by
  simpa only [Vector.eq_nil v, Vector.map_nil, Vector.toList_nil] using List.not_mem_nil b
#align vector.not_mem_map_zero Vector.not_mem_map_zero

theorem mem_map_succ_iff (b : β) (v : Vector α (n + 1)) (f : α → β) :
    b ∈ (v.map f).toList ↔ f v.head = b ∨ ∃ a : α, a ∈ v.tail.toList ∧ f a = b := by
  rw [mem_succ_iff, head_map, tail_map, mem_map_iff, @eq_comm _ b]
#align vector.mem_map_succ_iff Vector.mem_map_succ_iff

end Vector

