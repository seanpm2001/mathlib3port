/-
Copyright (c) 2022 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers

! This file was ported from Lean 3 source module algebra.order.to_interval_mod
! leanprover-community/mathlib commit 213b0cff7bc5ab6696ee07cceec80829ce42efec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Modeq
import Mathbin.Algebra.Module.Basic
import Mathbin.Algebra.Order.Archimedean
import Mathbin.Algebra.Periodic
import Mathbin.Data.Int.SuccPred
import Mathbin.GroupTheory.QuotientGroup
import Mathbin.Order.Circular

/-!
# Reducing to an interval modulo its length

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines operations that reduce a number (in an `archimedean`
`linear_ordered_add_comm_group`) to a number in a given interval, modulo the length of that
interval.

## Main definitions

* `to_Ico_div hp a b` (where `hp : 0 < p`): The unique integer such that this multiple of `p`,
  subtracted from `b`, is in `Ico a (a + p)`.
* `to_Ico_mod hp a b` (where `hp : 0 < p`): Reduce `b` to the interval `Ico a (a + p)`.
* `to_Ioc_div hp a b` (where `hp : 0 < p`): The unique integer such that this multiple of `p`,
  subtracted from `b`, is in `Ioc a (a + p)`.
* `to_Ioc_mod hp a b` (where `hp : 0 < p`): Reduce `b` to the interval `Ioc a (a + p)`.
-/


noncomputable section

section LinearOrderedAddCommGroup

variable {α : Type _} [LinearOrderedAddCommGroup α] [hα : Archimedean α] {p : α} (hp : 0 < p)
  {a b c : α} {n : ℤ}

#print toIcoDiv /-
/--
The unique integer such that this multiple of `p`, subtracted from `b`, is in `Ico a (a + p)`. -/
def toIcoDiv (a b : α) : ℤ :=
  (existsUnique_sub_zsmul_mem_Ico hp b a).some
#align to_Ico_div toIcoDiv
-/

#print sub_toIcoDiv_zsmul_mem_Ico /-
theorem sub_toIcoDiv_zsmul_mem_Ico (a b : α) : b - toIcoDiv hp a b • p ∈ Set.Ico a (a + p) :=
  (existsUnique_sub_zsmul_mem_Ico hp b a).choose_spec.1
#align sub_to_Ico_div_zsmul_mem_Ico sub_toIcoDiv_zsmul_mem_Ico
-/

#print toIcoDiv_eq_of_sub_zsmul_mem_Ico /-
theorem toIcoDiv_eq_of_sub_zsmul_mem_Ico (h : b - n • p ∈ Set.Ico a (a + p)) :
    toIcoDiv hp a b = n :=
  ((existsUnique_sub_zsmul_mem_Ico hp b a).choose_spec.2 _ h).symm
#align to_Ico_div_eq_of_sub_zsmul_mem_Ico toIcoDiv_eq_of_sub_zsmul_mem_Ico
-/

#print toIocDiv /-
/--
The unique integer such that this multiple of `p`, subtracted from `b`, is in `Ioc a (a + p)`. -/
def toIocDiv (a b : α) : ℤ :=
  (existsUnique_sub_zsmul_mem_Ioc hp b a).some
#align to_Ioc_div toIocDiv
-/

#print sub_toIocDiv_zsmul_mem_Ioc /-
theorem sub_toIocDiv_zsmul_mem_Ioc (a b : α) : b - toIocDiv hp a b • p ∈ Set.Ioc a (a + p) :=
  (existsUnique_sub_zsmul_mem_Ioc hp b a).choose_spec.1
#align sub_to_Ioc_div_zsmul_mem_Ioc sub_toIocDiv_zsmul_mem_Ioc
-/

#print toIocDiv_eq_of_sub_zsmul_mem_Ioc /-
theorem toIocDiv_eq_of_sub_zsmul_mem_Ioc (h : b - n • p ∈ Set.Ioc a (a + p)) :
    toIocDiv hp a b = n :=
  ((existsUnique_sub_zsmul_mem_Ioc hp b a).choose_spec.2 _ h).symm
#align to_Ioc_div_eq_of_sub_zsmul_mem_Ioc toIocDiv_eq_of_sub_zsmul_mem_Ioc
-/

#print toIcoMod /-
/-- Reduce `b` to the interval `Ico a (a + p)`. -/
def toIcoMod (a b : α) : α :=
  b - toIcoDiv hp a b • p
#align to_Ico_mod toIcoMod
-/

#print toIocMod /-
/-- Reduce `b` to the interval `Ioc a (a + p)`. -/
def toIocMod (a b : α) : α :=
  b - toIocDiv hp a b • p
#align to_Ioc_mod toIocMod
-/

#print toIcoMod_mem_Ico /-
theorem toIcoMod_mem_Ico (a b : α) : toIcoMod hp a b ∈ Set.Ico a (a + p) :=
  sub_toIcoDiv_zsmul_mem_Ico hp a b
#align to_Ico_mod_mem_Ico toIcoMod_mem_Ico
-/

#print toIcoMod_mem_Ico' /-
theorem toIcoMod_mem_Ico' (b : α) : toIcoMod hp 0 b ∈ Set.Ico 0 p := by
  convert toIcoMod_mem_Ico hp 0 b; exact (zero_add p).symm
#align to_Ico_mod_mem_Ico' toIcoMod_mem_Ico'
-/

#print toIocMod_mem_Ioc /-
theorem toIocMod_mem_Ioc (a b : α) : toIocMod hp a b ∈ Set.Ioc a (a + p) :=
  sub_toIocDiv_zsmul_mem_Ioc hp a b
#align to_Ioc_mod_mem_Ioc toIocMod_mem_Ioc
-/

#print left_le_toIcoMod /-
theorem left_le_toIcoMod (a b : α) : a ≤ toIcoMod hp a b :=
  (Set.mem_Ico.1 (toIcoMod_mem_Ico hp a b)).1
#align left_le_to_Ico_mod left_le_toIcoMod
-/

#print left_lt_toIocMod /-
theorem left_lt_toIocMod (a b : α) : a < toIocMod hp a b :=
  (Set.mem_Ioc.1 (toIocMod_mem_Ioc hp a b)).1
#align left_lt_to_Ioc_mod left_lt_toIocMod
-/

#print toIcoMod_lt_right /-
theorem toIcoMod_lt_right (a b : α) : toIcoMod hp a b < a + p :=
  (Set.mem_Ico.1 (toIcoMod_mem_Ico hp a b)).2
#align to_Ico_mod_lt_right toIcoMod_lt_right
-/

#print toIocMod_le_right /-
theorem toIocMod_le_right (a b : α) : toIocMod hp a b ≤ a + p :=
  (Set.mem_Ioc.1 (toIocMod_mem_Ioc hp a b)).2
#align to_Ioc_mod_le_right toIocMod_le_right
-/

#print self_sub_toIcoDiv_zsmul /-
@[simp]
theorem self_sub_toIcoDiv_zsmul (a b : α) : b - toIcoDiv hp a b • p = toIcoMod hp a b :=
  rfl
#align self_sub_to_Ico_div_zsmul self_sub_toIcoDiv_zsmul
-/

#print self_sub_toIocDiv_zsmul /-
@[simp]
theorem self_sub_toIocDiv_zsmul (a b : α) : b - toIocDiv hp a b • p = toIocMod hp a b :=
  rfl
#align self_sub_to_Ioc_div_zsmul self_sub_toIocDiv_zsmul
-/

#print toIcoDiv_zsmul_sub_self /-
@[simp]
theorem toIcoDiv_zsmul_sub_self (a b : α) : toIcoDiv hp a b • p - b = -toIcoMod hp a b := by
  rw [toIcoMod, neg_sub]
#align to_Ico_div_zsmul_sub_self toIcoDiv_zsmul_sub_self
-/

#print toIocDiv_zsmul_sub_self /-
@[simp]
theorem toIocDiv_zsmul_sub_self (a b : α) : toIocDiv hp a b • p - b = -toIocMod hp a b := by
  rw [toIocMod, neg_sub]
#align to_Ioc_div_zsmul_sub_self toIocDiv_zsmul_sub_self
-/

#print toIcoMod_sub_self /-
@[simp]
theorem toIcoMod_sub_self (a b : α) : toIcoMod hp a b - b = -toIcoDiv hp a b • p := by
  rw [toIcoMod, sub_sub_cancel_left, neg_smul]
#align to_Ico_mod_sub_self toIcoMod_sub_self
-/

#print toIocMod_sub_self /-
@[simp]
theorem toIocMod_sub_self (a b : α) : toIocMod hp a b - b = -toIocDiv hp a b • p := by
  rw [toIocMod, sub_sub_cancel_left, neg_smul]
#align to_Ioc_mod_sub_self toIocMod_sub_self
-/

#print self_sub_toIcoMod /-
@[simp]
theorem self_sub_toIcoMod (a b : α) : b - toIcoMod hp a b = toIcoDiv hp a b • p := by
  rw [toIcoMod, sub_sub_cancel]
#align self_sub_to_Ico_mod self_sub_toIcoMod
-/

#print self_sub_toIocMod /-
@[simp]
theorem self_sub_toIocMod (a b : α) : b - toIocMod hp a b = toIocDiv hp a b • p := by
  rw [toIocMod, sub_sub_cancel]
#align self_sub_to_Ioc_mod self_sub_toIocMod
-/

#print toIcoMod_add_toIcoDiv_zsmul /-
@[simp]
theorem toIcoMod_add_toIcoDiv_zsmul (a b : α) : toIcoMod hp a b + toIcoDiv hp a b • p = b := by
  rw [toIcoMod, sub_add_cancel]
#align to_Ico_mod_add_to_Ico_div_zsmul toIcoMod_add_toIcoDiv_zsmul
-/

#print toIocMod_add_toIocDiv_zsmul /-
@[simp]
theorem toIocMod_add_toIocDiv_zsmul (a b : α) : toIocMod hp a b + toIocDiv hp a b • p = b := by
  rw [toIocMod, sub_add_cancel]
#align to_Ioc_mod_add_to_Ioc_div_zsmul toIocMod_add_toIocDiv_zsmul
-/

#print toIcoDiv_zsmul_sub_toIcoMod /-
@[simp]
theorem toIcoDiv_zsmul_sub_toIcoMod (a b : α) : toIcoDiv hp a b • p + toIcoMod hp a b = b := by
  rw [add_comm, toIcoMod_add_toIcoDiv_zsmul]
#align to_Ico_div_zsmul_sub_to_Ico_mod toIcoDiv_zsmul_sub_toIcoMod
-/

#print toIocDiv_zsmul_sub_toIocMod /-
@[simp]
theorem toIocDiv_zsmul_sub_toIocMod (a b : α) : toIocDiv hp a b • p + toIocMod hp a b = b := by
  rw [add_comm, toIocMod_add_toIocDiv_zsmul]
#align to_Ioc_div_zsmul_sub_to_Ioc_mod toIocDiv_zsmul_sub_toIocMod
-/

#print toIcoMod_eq_iff /-
theorem toIcoMod_eq_iff : toIcoMod hp a b = c ↔ c ∈ Set.Ico a (a + p) ∧ ∃ z : ℤ, b = c + z • p :=
  by
  refine'
    ⟨fun h =>
      ⟨h ▸ toIcoMod_mem_Ico hp a b, toIcoDiv hp a b, h ▸ (toIcoMod_add_toIcoDiv_zsmul _ _ _).symm⟩,
      _⟩
  simp_rw [← @sub_eq_iff_eq_add]
  rintro ⟨hc, n, rfl⟩
  rw [← toIcoDiv_eq_of_sub_zsmul_mem_Ico hp hc, toIcoMod]
#align to_Ico_mod_eq_iff toIcoMod_eq_iff
-/

#print toIocMod_eq_iff /-
theorem toIocMod_eq_iff : toIocMod hp a b = c ↔ c ∈ Set.Ioc a (a + p) ∧ ∃ z : ℤ, b = c + z • p :=
  by
  refine'
    ⟨fun h =>
      ⟨h ▸ toIocMod_mem_Ioc hp a b, toIocDiv hp a b, h ▸ (toIocMod_add_toIocDiv_zsmul hp _ _).symm⟩,
      _⟩
  simp_rw [← @sub_eq_iff_eq_add]
  rintro ⟨hc, n, rfl⟩
  rw [← toIocDiv_eq_of_sub_zsmul_mem_Ioc hp hc, toIocMod]
#align to_Ioc_mod_eq_iff toIocMod_eq_iff
-/

#print toIcoDiv_apply_left /-
@[simp]
theorem toIcoDiv_apply_left (a : α) : toIcoDiv hp a a = 0 :=
  toIcoDiv_eq_of_sub_zsmul_mem_Ico hp <| by simp [hp]
#align to_Ico_div_apply_left toIcoDiv_apply_left
-/

#print toIocDiv_apply_left /-
@[simp]
theorem toIocDiv_apply_left (a : α) : toIocDiv hp a a = -1 :=
  toIocDiv_eq_of_sub_zsmul_mem_Ioc hp <| by simp [hp]
#align to_Ioc_div_apply_left toIocDiv_apply_left
-/

#print toIcoMod_apply_left /-
@[simp]
theorem toIcoMod_apply_left (a : α) : toIcoMod hp a a = a := by
  rw [toIcoMod_eq_iff hp, Set.left_mem_Ico]; exact ⟨lt_add_of_pos_right _ hp, 0, by simp⟩
#align to_Ico_mod_apply_left toIcoMod_apply_left
-/

#print toIocMod_apply_left /-
@[simp]
theorem toIocMod_apply_left (a : α) : toIocMod hp a a = a + p := by
  rw [toIocMod_eq_iff hp, Set.right_mem_Ioc]; exact ⟨lt_add_of_pos_right _ hp, -1, by simp⟩
#align to_Ioc_mod_apply_left toIocMod_apply_left
-/

#print toIcoDiv_apply_right /-
theorem toIcoDiv_apply_right (a : α) : toIcoDiv hp a (a + p) = 1 :=
  toIcoDiv_eq_of_sub_zsmul_mem_Ico hp <| by simp [hp]
#align to_Ico_div_apply_right toIcoDiv_apply_right
-/

#print toIocDiv_apply_right /-
theorem toIocDiv_apply_right (a : α) : toIocDiv hp a (a + p) = 0 :=
  toIocDiv_eq_of_sub_zsmul_mem_Ioc hp <| by simp [hp]
#align to_Ioc_div_apply_right toIocDiv_apply_right
-/

#print toIcoMod_apply_right /-
theorem toIcoMod_apply_right (a : α) : toIcoMod hp a (a + p) = a := by
  rw [toIcoMod_eq_iff hp, Set.left_mem_Ico]; exact ⟨lt_add_of_pos_right _ hp, 1, by simp⟩
#align to_Ico_mod_apply_right toIcoMod_apply_right
-/

#print toIocMod_apply_right /-
theorem toIocMod_apply_right (a : α) : toIocMod hp a (a + p) = a + p := by
  rw [toIocMod_eq_iff hp, Set.right_mem_Ioc]; exact ⟨lt_add_of_pos_right _ hp, 0, by simp⟩
#align to_Ioc_mod_apply_right toIocMod_apply_right
-/

#print toIcoDiv_add_zsmul /-
@[simp]
theorem toIcoDiv_add_zsmul (a b : α) (m : ℤ) : toIcoDiv hp a (b + m • p) = toIcoDiv hp a b + m :=
  toIcoDiv_eq_of_sub_zsmul_mem_Ico hp <| by
    simpa only [add_smul, add_sub_add_right_eq_sub] using sub_toIcoDiv_zsmul_mem_Ico hp a b
#align to_Ico_div_add_zsmul toIcoDiv_add_zsmul
-/

#print toIcoDiv_add_zsmul' /-
@[simp]
theorem toIcoDiv_add_zsmul' (a b : α) (m : ℤ) : toIcoDiv hp (a + m • p) b = toIcoDiv hp a b - m :=
  by
  refine' toIcoDiv_eq_of_sub_zsmul_mem_Ico _ _
  rw [sub_smul, ← sub_add, add_right_comm]
  simpa using sub_toIcoDiv_zsmul_mem_Ico hp a b
#align to_Ico_div_add_zsmul' toIcoDiv_add_zsmul'
-/

#print toIocDiv_add_zsmul /-
@[simp]
theorem toIocDiv_add_zsmul (a b : α) (m : ℤ) : toIocDiv hp a (b + m • p) = toIocDiv hp a b + m :=
  toIocDiv_eq_of_sub_zsmul_mem_Ioc hp <| by
    simpa only [add_smul, add_sub_add_right_eq_sub] using sub_toIocDiv_zsmul_mem_Ioc hp a b
#align to_Ioc_div_add_zsmul toIocDiv_add_zsmul
-/

#print toIocDiv_add_zsmul' /-
@[simp]
theorem toIocDiv_add_zsmul' (a b : α) (m : ℤ) : toIocDiv hp (a + m • p) b = toIocDiv hp a b - m :=
  by
  refine' toIocDiv_eq_of_sub_zsmul_mem_Ioc _ _
  rw [sub_smul, ← sub_add, add_right_comm]
  simpa using sub_toIocDiv_zsmul_mem_Ioc hp a b
#align to_Ioc_div_add_zsmul' toIocDiv_add_zsmul'
-/

#print toIcoDiv_zsmul_add /-
@[simp]
theorem toIcoDiv_zsmul_add (a b : α) (m : ℤ) : toIcoDiv hp a (m • p + b) = m + toIcoDiv hp a b := by
  rw [add_comm, toIcoDiv_add_zsmul, add_comm]
#align to_Ico_div_zsmul_add toIcoDiv_zsmul_add
-/

/-! Note we omit `to_Ico_div_zsmul_add'` as `-m + to_Ico_div hp a b` is not very convenient. -/


#print toIocDiv_zsmul_add /-
@[simp]
theorem toIocDiv_zsmul_add (a b : α) (m : ℤ) : toIocDiv hp a (m • p + b) = m + toIocDiv hp a b := by
  rw [add_comm, toIocDiv_add_zsmul, add_comm]
#align to_Ioc_div_zsmul_add toIocDiv_zsmul_add
-/

/-! Note we omit `to_Ioc_div_zsmul_add'` as `-m + to_Ioc_div hp a b` is not very convenient. -/


#print toIcoDiv_sub_zsmul /-
@[simp]
theorem toIcoDiv_sub_zsmul (a b : α) (m : ℤ) : toIcoDiv hp a (b - m • p) = toIcoDiv hp a b - m := by
  rw [sub_eq_add_neg, ← neg_smul, toIcoDiv_add_zsmul, sub_eq_add_neg]
#align to_Ico_div_sub_zsmul toIcoDiv_sub_zsmul
-/

#print toIcoDiv_sub_zsmul' /-
@[simp]
theorem toIcoDiv_sub_zsmul' (a b : α) (m : ℤ) : toIcoDiv hp (a - m • p) b = toIcoDiv hp a b + m :=
  by rw [sub_eq_add_neg, ← neg_smul, toIcoDiv_add_zsmul', sub_neg_eq_add]
#align to_Ico_div_sub_zsmul' toIcoDiv_sub_zsmul'
-/

#print toIocDiv_sub_zsmul /-
@[simp]
theorem toIocDiv_sub_zsmul (a b : α) (m : ℤ) : toIocDiv hp a (b - m • p) = toIocDiv hp a b - m := by
  rw [sub_eq_add_neg, ← neg_smul, toIocDiv_add_zsmul, sub_eq_add_neg]
#align to_Ioc_div_sub_zsmul toIocDiv_sub_zsmul
-/

#print toIocDiv_sub_zsmul' /-
@[simp]
theorem toIocDiv_sub_zsmul' (a b : α) (m : ℤ) : toIocDiv hp (a - m • p) b = toIocDiv hp a b + m :=
  by rw [sub_eq_add_neg, ← neg_smul, toIocDiv_add_zsmul', sub_neg_eq_add]
#align to_Ioc_div_sub_zsmul' toIocDiv_sub_zsmul'
-/

#print toIcoDiv_add_right /-
@[simp]
theorem toIcoDiv_add_right (a b : α) : toIcoDiv hp a (b + p) = toIcoDiv hp a b + 1 := by
  simpa only [one_zsmul] using toIcoDiv_add_zsmul hp a b 1
#align to_Ico_div_add_right toIcoDiv_add_right
-/

#print toIcoDiv_add_right' /-
@[simp]
theorem toIcoDiv_add_right' (a b : α) : toIcoDiv hp (a + p) b = toIcoDiv hp a b - 1 := by
  simpa only [one_zsmul] using toIcoDiv_add_zsmul' hp a b 1
#align to_Ico_div_add_right' toIcoDiv_add_right'
-/

#print toIocDiv_add_right /-
@[simp]
theorem toIocDiv_add_right (a b : α) : toIocDiv hp a (b + p) = toIocDiv hp a b + 1 := by
  simpa only [one_zsmul] using toIocDiv_add_zsmul hp a b 1
#align to_Ioc_div_add_right toIocDiv_add_right
-/

#print toIocDiv_add_right' /-
@[simp]
theorem toIocDiv_add_right' (a b : α) : toIocDiv hp (a + p) b = toIocDiv hp a b - 1 := by
  simpa only [one_zsmul] using toIocDiv_add_zsmul' hp a b 1
#align to_Ioc_div_add_right' toIocDiv_add_right'
-/

#print toIcoDiv_add_left /-
@[simp]
theorem toIcoDiv_add_left (a b : α) : toIcoDiv hp a (p + b) = toIcoDiv hp a b + 1 := by
  rw [add_comm, toIcoDiv_add_right]
#align to_Ico_div_add_left toIcoDiv_add_left
-/

#print toIcoDiv_add_left' /-
@[simp]
theorem toIcoDiv_add_left' (a b : α) : toIcoDiv hp (p + a) b = toIcoDiv hp a b - 1 := by
  rw [add_comm, toIcoDiv_add_right']
#align to_Ico_div_add_left' toIcoDiv_add_left'
-/

#print toIocDiv_add_left /-
@[simp]
theorem toIocDiv_add_left (a b : α) : toIocDiv hp a (p + b) = toIocDiv hp a b + 1 := by
  rw [add_comm, toIocDiv_add_right]
#align to_Ioc_div_add_left toIocDiv_add_left
-/

#print toIocDiv_add_left' /-
@[simp]
theorem toIocDiv_add_left' (a b : α) : toIocDiv hp (p + a) b = toIocDiv hp a b - 1 := by
  rw [add_comm, toIocDiv_add_right']
#align to_Ioc_div_add_left' toIocDiv_add_left'
-/

#print toIcoDiv_sub /-
@[simp]
theorem toIcoDiv_sub (a b : α) : toIcoDiv hp a (b - p) = toIcoDiv hp a b - 1 := by
  simpa only [one_zsmul] using toIcoDiv_sub_zsmul hp a b 1
#align to_Ico_div_sub toIcoDiv_sub
-/

#print toIcoDiv_sub' /-
@[simp]
theorem toIcoDiv_sub' (a b : α) : toIcoDiv hp (a - p) b = toIcoDiv hp a b + 1 := by
  simpa only [one_zsmul] using toIcoDiv_sub_zsmul' hp a b 1
#align to_Ico_div_sub' toIcoDiv_sub'
-/

#print toIocDiv_sub /-
@[simp]
theorem toIocDiv_sub (a b : α) : toIocDiv hp a (b - p) = toIocDiv hp a b - 1 := by
  simpa only [one_zsmul] using toIocDiv_sub_zsmul hp a b 1
#align to_Ioc_div_sub toIocDiv_sub
-/

#print toIocDiv_sub' /-
@[simp]
theorem toIocDiv_sub' (a b : α) : toIocDiv hp (a - p) b = toIocDiv hp a b + 1 := by
  simpa only [one_zsmul] using toIocDiv_sub_zsmul' hp a b 1
#align to_Ioc_div_sub' toIocDiv_sub'
-/

#print toIcoDiv_sub_eq_toIcoDiv_add /-
theorem toIcoDiv_sub_eq_toIcoDiv_add (a b c : α) : toIcoDiv hp a (b - c) = toIcoDiv hp (a + c) b :=
  by
  apply toIcoDiv_eq_of_sub_zsmul_mem_Ico
  rw [← sub_right_comm, Set.sub_mem_Ico_iff_left, add_right_comm]
  exact sub_toIcoDiv_zsmul_mem_Ico hp (a + c) b
#align to_Ico_div_sub_eq_to_Ico_div_add toIcoDiv_sub_eq_toIcoDiv_add
-/

#print toIocDiv_sub_eq_toIocDiv_add /-
theorem toIocDiv_sub_eq_toIocDiv_add (a b c : α) : toIocDiv hp a (b - c) = toIocDiv hp (a + c) b :=
  by
  apply toIocDiv_eq_of_sub_zsmul_mem_Ioc
  rw [← sub_right_comm, Set.sub_mem_Ioc_iff_left, add_right_comm]
  exact sub_toIocDiv_zsmul_mem_Ioc hp (a + c) b
#align to_Ioc_div_sub_eq_to_Ioc_div_add toIocDiv_sub_eq_toIocDiv_add
-/

#print toIcoDiv_sub_eq_toIcoDiv_add' /-
theorem toIcoDiv_sub_eq_toIcoDiv_add' (a b c : α) : toIcoDiv hp (a - c) b = toIcoDiv hp a (b + c) :=
  by rw [← sub_neg_eq_add, toIcoDiv_sub_eq_toIcoDiv_add, sub_eq_add_neg]
#align to_Ico_div_sub_eq_to_Ico_div_add' toIcoDiv_sub_eq_toIcoDiv_add'
-/

#print toIocDiv_sub_eq_toIocDiv_add' /-
theorem toIocDiv_sub_eq_toIocDiv_add' (a b c : α) : toIocDiv hp (a - c) b = toIocDiv hp a (b + c) :=
  by rw [← sub_neg_eq_add, toIocDiv_sub_eq_toIocDiv_add, sub_eq_add_neg]
#align to_Ioc_div_sub_eq_to_Ioc_div_add' toIocDiv_sub_eq_toIocDiv_add'
-/

#print toIcoDiv_neg /-
theorem toIcoDiv_neg (a b : α) : toIcoDiv hp a (-b) = -(toIocDiv hp (-a) b + 1) :=
  by
  suffices toIcoDiv hp a (-b) = -toIocDiv hp (-(a + p)) b by
    rwa [neg_add, ← sub_eq_add_neg, toIocDiv_sub_eq_toIocDiv_add', toIocDiv_add_right] at this 
  rw [← neg_eq_iff_eq_neg, eq_comm]
  apply toIocDiv_eq_of_sub_zsmul_mem_Ioc
  obtain ⟨hc, ho⟩ := sub_toIcoDiv_zsmul_mem_Ico hp a (-b)
  rw [← neg_lt_neg_iff, neg_sub' (-b), neg_neg, ← neg_smul] at ho 
  rw [← neg_le_neg_iff, neg_sub' (-b), neg_neg, ← neg_smul] at hc 
  refine' ⟨ho, hc.trans_eq _⟩
  rw [neg_add, neg_add_cancel_right]
#align to_Ico_div_neg toIcoDiv_neg
-/

#print toIcoDiv_neg' /-
theorem toIcoDiv_neg' (a b : α) : toIcoDiv hp (-a) b = -(toIocDiv hp a (-b) + 1) := by
  simpa only [neg_neg] using toIcoDiv_neg hp (-a) (-b)
#align to_Ico_div_neg' toIcoDiv_neg'
-/

#print toIocDiv_neg /-
theorem toIocDiv_neg (a b : α) : toIocDiv hp a (-b) = -(toIcoDiv hp (-a) b + 1) := by
  rw [← neg_neg b, toIcoDiv_neg, neg_neg, neg_neg, neg_add', neg_neg, add_sub_cancel]
#align to_Ioc_div_neg toIocDiv_neg
-/

#print toIocDiv_neg' /-
theorem toIocDiv_neg' (a b : α) : toIocDiv hp (-a) b = -(toIcoDiv hp a (-b) + 1) := by
  simpa only [neg_neg] using toIocDiv_neg hp (-a) (-b)
#align to_Ioc_div_neg' toIocDiv_neg'
-/

#print toIcoMod_add_zsmul /-
@[simp]
theorem toIcoMod_add_zsmul (a b : α) (m : ℤ) : toIcoMod hp a (b + m • p) = toIcoMod hp a b := by
  rw [toIcoMod, toIcoDiv_add_zsmul, toIcoMod, add_smul]; abel
#align to_Ico_mod_add_zsmul toIcoMod_add_zsmul
-/

#print toIcoMod_add_zsmul' /-
@[simp]
theorem toIcoMod_add_zsmul' (a b : α) (m : ℤ) :
    toIcoMod hp (a + m • p) b = toIcoMod hp a b + m • p := by
  simp only [toIcoMod, toIcoDiv_add_zsmul', sub_smul, sub_add]
#align to_Ico_mod_add_zsmul' toIcoMod_add_zsmul'
-/

#print toIocMod_add_zsmul /-
@[simp]
theorem toIocMod_add_zsmul (a b : α) (m : ℤ) : toIocMod hp a (b + m • p) = toIocMod hp a b := by
  rw [toIocMod, toIocDiv_add_zsmul, toIocMod, add_smul]; abel
#align to_Ioc_mod_add_zsmul toIocMod_add_zsmul
-/

#print toIocMod_add_zsmul' /-
@[simp]
theorem toIocMod_add_zsmul' (a b : α) (m : ℤ) :
    toIocMod hp (a + m • p) b = toIocMod hp a b + m • p := by
  simp only [toIocMod, toIocDiv_add_zsmul', sub_smul, sub_add]
#align to_Ioc_mod_add_zsmul' toIocMod_add_zsmul'
-/

#print toIcoMod_zsmul_add /-
@[simp]
theorem toIcoMod_zsmul_add (a b : α) (m : ℤ) : toIcoMod hp a (m • p + b) = toIcoMod hp a b := by
  rw [add_comm, toIcoMod_add_zsmul]
#align to_Ico_mod_zsmul_add toIcoMod_zsmul_add
-/

#print toIcoMod_zsmul_add' /-
@[simp]
theorem toIcoMod_zsmul_add' (a b : α) (m : ℤ) :
    toIcoMod hp (m • p + a) b = m • p + toIcoMod hp a b := by
  rw [add_comm, toIcoMod_add_zsmul', add_comm]
#align to_Ico_mod_zsmul_add' toIcoMod_zsmul_add'
-/

#print toIocMod_zsmul_add /-
@[simp]
theorem toIocMod_zsmul_add (a b : α) (m : ℤ) : toIocMod hp a (m • p + b) = toIocMod hp a b := by
  rw [add_comm, toIocMod_add_zsmul]
#align to_Ioc_mod_zsmul_add toIocMod_zsmul_add
-/

#print toIocMod_zsmul_add' /-
@[simp]
theorem toIocMod_zsmul_add' (a b : α) (m : ℤ) :
    toIocMod hp (m • p + a) b = m • p + toIocMod hp a b := by
  rw [add_comm, toIocMod_add_zsmul', add_comm]
#align to_Ioc_mod_zsmul_add' toIocMod_zsmul_add'
-/

#print toIcoMod_sub_zsmul /-
@[simp]
theorem toIcoMod_sub_zsmul (a b : α) (m : ℤ) : toIcoMod hp a (b - m • p) = toIcoMod hp a b := by
  rw [sub_eq_add_neg, ← neg_smul, toIcoMod_add_zsmul]
#align to_Ico_mod_sub_zsmul toIcoMod_sub_zsmul
-/

#print toIcoMod_sub_zsmul' /-
@[simp]
theorem toIcoMod_sub_zsmul' (a b : α) (m : ℤ) :
    toIcoMod hp (a - m • p) b = toIcoMod hp a b - m • p := by
  simp_rw [sub_eq_add_neg, ← neg_smul, toIcoMod_add_zsmul']
#align to_Ico_mod_sub_zsmul' toIcoMod_sub_zsmul'
-/

#print toIocMod_sub_zsmul /-
@[simp]
theorem toIocMod_sub_zsmul (a b : α) (m : ℤ) : toIocMod hp a (b - m • p) = toIocMod hp a b := by
  rw [sub_eq_add_neg, ← neg_smul, toIocMod_add_zsmul]
#align to_Ioc_mod_sub_zsmul toIocMod_sub_zsmul
-/

#print toIocMod_sub_zsmul' /-
@[simp]
theorem toIocMod_sub_zsmul' (a b : α) (m : ℤ) :
    toIocMod hp (a - m • p) b = toIocMod hp a b - m • p := by
  simp_rw [sub_eq_add_neg, ← neg_smul, toIocMod_add_zsmul']
#align to_Ioc_mod_sub_zsmul' toIocMod_sub_zsmul'
-/

#print toIcoMod_add_right /-
@[simp]
theorem toIcoMod_add_right (a b : α) : toIcoMod hp a (b + p) = toIcoMod hp a b := by
  simpa only [one_zsmul] using toIcoMod_add_zsmul hp a b 1
#align to_Ico_mod_add_right toIcoMod_add_right
-/

#print toIcoMod_add_right' /-
@[simp]
theorem toIcoMod_add_right' (a b : α) : toIcoMod hp (a + p) b = toIcoMod hp a b + p := by
  simpa only [one_zsmul] using toIcoMod_add_zsmul' hp a b 1
#align to_Ico_mod_add_right' toIcoMod_add_right'
-/

#print toIocMod_add_right /-
@[simp]
theorem toIocMod_add_right (a b : α) : toIocMod hp a (b + p) = toIocMod hp a b := by
  simpa only [one_zsmul] using toIocMod_add_zsmul hp a b 1
#align to_Ioc_mod_add_right toIocMod_add_right
-/

#print toIocMod_add_right' /-
@[simp]
theorem toIocMod_add_right' (a b : α) : toIocMod hp (a + p) b = toIocMod hp a b + p := by
  simpa only [one_zsmul] using toIocMod_add_zsmul' hp a b 1
#align to_Ioc_mod_add_right' toIocMod_add_right'
-/

#print toIcoMod_add_left /-
@[simp]
theorem toIcoMod_add_left (a b : α) : toIcoMod hp a (p + b) = toIcoMod hp a b := by
  rw [add_comm, toIcoMod_add_right]
#align to_Ico_mod_add_left toIcoMod_add_left
-/

#print toIcoMod_add_left' /-
@[simp]
theorem toIcoMod_add_left' (a b : α) : toIcoMod hp (p + a) b = p + toIcoMod hp a b := by
  rw [add_comm, toIcoMod_add_right', add_comm]
#align to_Ico_mod_add_left' toIcoMod_add_left'
-/

#print toIocMod_add_left /-
@[simp]
theorem toIocMod_add_left (a b : α) : toIocMod hp a (p + b) = toIocMod hp a b := by
  rw [add_comm, toIocMod_add_right]
#align to_Ioc_mod_add_left toIocMod_add_left
-/

#print toIocMod_add_left' /-
@[simp]
theorem toIocMod_add_left' (a b : α) : toIocMod hp (p + a) b = p + toIocMod hp a b := by
  rw [add_comm, toIocMod_add_right', add_comm]
#align to_Ioc_mod_add_left' toIocMod_add_left'
-/

#print toIcoMod_sub /-
@[simp]
theorem toIcoMod_sub (a b : α) : toIcoMod hp a (b - p) = toIcoMod hp a b := by
  simpa only [one_zsmul] using toIcoMod_sub_zsmul hp a b 1
#align to_Ico_mod_sub toIcoMod_sub
-/

#print toIcoMod_sub' /-
@[simp]
theorem toIcoMod_sub' (a b : α) : toIcoMod hp (a - p) b = toIcoMod hp a b - p := by
  simpa only [one_zsmul] using toIcoMod_sub_zsmul' hp a b 1
#align to_Ico_mod_sub' toIcoMod_sub'
-/

#print toIocMod_sub /-
@[simp]
theorem toIocMod_sub (a b : α) : toIocMod hp a (b - p) = toIocMod hp a b := by
  simpa only [one_zsmul] using toIocMod_sub_zsmul hp a b 1
#align to_Ioc_mod_sub toIocMod_sub
-/

#print toIocMod_sub' /-
@[simp]
theorem toIocMod_sub' (a b : α) : toIocMod hp (a - p) b = toIocMod hp a b - p := by
  simpa only [one_zsmul] using toIocMod_sub_zsmul' hp a b 1
#align to_Ioc_mod_sub' toIocMod_sub'
-/

#print toIcoMod_sub_eq_sub /-
theorem toIcoMod_sub_eq_sub (a b c : α) : toIcoMod hp a (b - c) = toIcoMod hp (a + c) b - c := by
  simp_rw [toIcoMod, toIcoDiv_sub_eq_toIcoDiv_add, sub_right_comm]
#align to_Ico_mod_sub_eq_sub toIcoMod_sub_eq_sub
-/

#print toIocMod_sub_eq_sub /-
theorem toIocMod_sub_eq_sub (a b c : α) : toIocMod hp a (b - c) = toIocMod hp (a + c) b - c := by
  simp_rw [toIocMod, toIocDiv_sub_eq_toIocDiv_add, sub_right_comm]
#align to_Ioc_mod_sub_eq_sub toIocMod_sub_eq_sub
-/

#print toIcoMod_add_right_eq_add /-
theorem toIcoMod_add_right_eq_add (a b c : α) : toIcoMod hp a (b + c) = toIcoMod hp (a - c) b + c :=
  by simp_rw [toIcoMod, toIcoDiv_sub_eq_toIcoDiv_add', sub_add_eq_add_sub]
#align to_Ico_mod_add_right_eq_add toIcoMod_add_right_eq_add
-/

#print toIocMod_add_right_eq_add /-
theorem toIocMod_add_right_eq_add (a b c : α) : toIocMod hp a (b + c) = toIocMod hp (a - c) b + c :=
  by simp_rw [toIocMod, toIocDiv_sub_eq_toIocDiv_add', sub_add_eq_add_sub]
#align to_Ioc_mod_add_right_eq_add toIocMod_add_right_eq_add
-/

#print toIcoMod_neg /-
theorem toIcoMod_neg (a b : α) : toIcoMod hp a (-b) = p - toIocMod hp (-a) b := by
  simp_rw [toIcoMod, toIocMod, toIcoDiv_neg, neg_smul, add_smul]; abel
#align to_Ico_mod_neg toIcoMod_neg
-/

#print toIcoMod_neg' /-
theorem toIcoMod_neg' (a b : α) : toIcoMod hp (-a) b = p - toIocMod hp a (-b) := by
  simpa only [neg_neg] using toIcoMod_neg hp (-a) (-b)
#align to_Ico_mod_neg' toIcoMod_neg'
-/

#print toIocMod_neg /-
theorem toIocMod_neg (a b : α) : toIocMod hp a (-b) = p - toIcoMod hp (-a) b := by
  simp_rw [toIocMod, toIcoMod, toIocDiv_neg, neg_smul, add_smul]; abel
#align to_Ioc_mod_neg toIocMod_neg
-/

#print toIocMod_neg' /-
theorem toIocMod_neg' (a b : α) : toIocMod hp (-a) b = p - toIcoMod hp a (-b) := by
  simpa only [neg_neg] using toIocMod_neg hp (-a) (-b)
#align to_Ioc_mod_neg' toIocMod_neg'
-/

#print toIcoMod_eq_toIcoMod /-
theorem toIcoMod_eq_toIcoMod : toIcoMod hp a b = toIcoMod hp a c ↔ ∃ n : ℤ, c - b = n • p :=
  by
  refine' ⟨fun h => ⟨toIcoDiv hp a c - toIcoDiv hp a b, _⟩, fun h => _⟩
  · conv_lhs => rw [← toIcoMod_add_toIcoDiv_zsmul hp a b, ← toIcoMod_add_toIcoDiv_zsmul hp a c]
    rw [h, sub_smul]
    abel
  · rcases h with ⟨z, hz⟩
    rw [sub_eq_iff_eq_add] at hz 
    rw [hz, toIcoMod_zsmul_add]
#align to_Ico_mod_eq_to_Ico_mod toIcoMod_eq_toIcoMod
-/

#print toIocMod_eq_toIocMod /-
theorem toIocMod_eq_toIocMod : toIocMod hp a b = toIocMod hp a c ↔ ∃ n : ℤ, c - b = n • p :=
  by
  refine' ⟨fun h => ⟨toIocDiv hp a c - toIocDiv hp a b, _⟩, fun h => _⟩
  · conv_lhs => rw [← toIocMod_add_toIocDiv_zsmul hp a b, ← toIocMod_add_toIocDiv_zsmul hp a c]
    rw [h, sub_smul]
    abel
  · rcases h with ⟨z, hz⟩
    rw [sub_eq_iff_eq_add] at hz 
    rw [hz, toIocMod_zsmul_add]
#align to_Ioc_mod_eq_to_Ioc_mod toIocMod_eq_toIocMod
-/

/-! ### Links between the `Ico` and `Ioc` variants applied to the same element -/


section IcoIoc

variable {a b}

namespace AddCommGroup

#print AddCommGroup.modEq_iff_toIcoMod_eq_left /-
theorem modEq_iff_toIcoMod_eq_left : a ≡ b [PMOD p] ↔ toIcoMod hp a b = a :=
  modEq_iff_eq_add_zsmul.trans
    ⟨by
      rintro ⟨n, rfl⟩
      rw [toIcoMod_add_zsmul, toIcoMod_apply_left], fun h => ⟨toIcoDiv hp a b, eq_add_of_sub_eq h⟩⟩
#align add_comm_group.modeq_iff_to_Ico_mod_eq_left AddCommGroup.modEq_iff_toIcoMod_eq_left
-/

#print AddCommGroup.modEq_iff_toIocMod_eq_right /-
theorem modEq_iff_toIocMod_eq_right : a ≡ b [PMOD p] ↔ toIocMod hp a b = a + p :=
  by
  refine' modeq_iff_eq_add_zsmul.trans ⟨_, fun h => ⟨toIocDiv hp a b + 1, _⟩⟩
  · rintro ⟨z, rfl⟩
    rw [toIocMod_add_zsmul, toIocMod_apply_left]
  · rwa [add_one_zsmul, add_left_comm, ← sub_eq_iff_eq_add']
#align add_comm_group.modeq_iff_to_Ioc_mod_eq_right AddCommGroup.modEq_iff_toIocMod_eq_right
-/

alias modeq_iff_to_Ico_mod_eq_left ↔ modeq.to_Ico_mod_eq_left _
#align add_comm_group.modeq.to_Ico_mod_eq_left AddCommGroup.ModEq.toIcoMod_eq_left

alias modeq_iff_to_Ioc_mod_eq_right ↔ modeq.to_Ico_mod_eq_right _
#align add_comm_group.modeq.to_Ico_mod_eq_right AddCommGroup.ModEq.toIcoMod_eq_right

variable (a b)

#print AddCommGroup.tfae_modEq /-
theorem tfae_modEq :
    TFAE
      [a ≡ b [PMOD p], ∀ z : ℤ, b - z • p ∉ Set.Ioo a (a + p), toIcoMod hp a b ≠ toIocMod hp a b,
        toIcoMod hp a b + p = toIocMod hp a b] :=
  by
  rw [modeq_iff_to_Ico_mod_eq_left hp]
  tfae_have 3 → 2
  · rw [← not_exists, not_imp_not]
    exact fun ⟨i, hi⟩ =>
      ((toIcoMod_eq_iff hp).2 ⟨Set.Ioo_subset_Ico_self hi, i, (sub_add_cancel b _).symm⟩).trans
        ((toIocMod_eq_iff hp).2 ⟨Set.Ioo_subset_Ioc_self hi, i, (sub_add_cancel b _).symm⟩).symm
  tfae_have 4 → 3
  · intro h; rw [← h, Ne, eq_comm, add_right_eq_self]; exact hp.ne'
  tfae_have 1 → 4
  · intro h
    rw [h, eq_comm, toIocMod_eq_iff, Set.right_mem_Ioc]
    refine' ⟨lt_add_of_pos_right a hp, toIcoDiv hp a b - 1, _⟩
    rw [sub_one_zsmul, add_add_add_comm, add_right_neg, add_zero]
    conv_lhs => rw [← toIcoMod_add_toIcoDiv_zsmul hp a b, h]
  tfae_have 2 → 1
  · rw [← not_exists, not_imp_comm]
    have h' := toIcoMod_mem_Ico hp a b
    exact fun h => ⟨_, h'.1.lt_of_ne' h, h'.2⟩
  tfae_finish
#align add_comm_group.tfae_modeq AddCommGroup.tfae_modEq
-/

variable {a b}

#print AddCommGroup.modEq_iff_not_forall_mem_Ioo_mod /-
theorem modEq_iff_not_forall_mem_Ioo_mod :
    a ≡ b [PMOD p] ↔ ∀ z : ℤ, b - z • p ∉ Set.Ioo a (a + p) :=
  (tfae_modEq hp a b).out 0 1
#align add_comm_group.modeq_iff_not_forall_mem_Ioo_mod AddCommGroup.modEq_iff_not_forall_mem_Ioo_mod
-/

#print AddCommGroup.modEq_iff_toIcoMod_ne_toIocMod /-
theorem modEq_iff_toIcoMod_ne_toIocMod : a ≡ b [PMOD p] ↔ toIcoMod hp a b ≠ toIocMod hp a b :=
  (tfae_modEq hp a b).out 0 2
#align add_comm_group.modeq_iff_to_Ico_mod_ne_to_Ioc_mod AddCommGroup.modEq_iff_toIcoMod_ne_toIocMod
-/

#print AddCommGroup.modEq_iff_toIcoMod_add_period_eq_toIocMod /-
theorem modEq_iff_toIcoMod_add_period_eq_toIocMod :
    a ≡ b [PMOD p] ↔ toIcoMod hp a b + p = toIocMod hp a b :=
  (tfae_modEq hp a b).out 0 3
#align add_comm_group.modeq_iff_to_Ico_mod_add_period_eq_to_Ioc_mod AddCommGroup.modEq_iff_toIcoMod_add_period_eq_toIocMod
-/

#print AddCommGroup.not_modEq_iff_toIcoMod_eq_toIocMod /-
theorem not_modEq_iff_toIcoMod_eq_toIocMod : ¬a ≡ b [PMOD p] ↔ toIcoMod hp a b = toIocMod hp a b :=
  (modEq_iff_toIcoMod_ne_toIocMod _).not_left
#align add_comm_group.not_modeq_iff_to_Ico_mod_eq_to_Ioc_mod AddCommGroup.not_modEq_iff_toIcoMod_eq_toIocMod
-/

#print AddCommGroup.not_modEq_iff_toIcoDiv_eq_toIocDiv /-
theorem not_modEq_iff_toIcoDiv_eq_toIocDiv : ¬a ≡ b [PMOD p] ↔ toIcoDiv hp a b = toIocDiv hp a b :=
  by
  rw [not_modeq_iff_to_Ico_mod_eq_to_Ioc_mod hp, toIcoMod, toIocMod, sub_right_inj,
    (zsmul_strictMono_left hp).Injective.eq_iff]
#align add_comm_group.not_modeq_iff_to_Ico_div_eq_to_Ioc_div AddCommGroup.not_modEq_iff_toIcoDiv_eq_toIocDiv
-/

#print AddCommGroup.modEq_iff_toIcoDiv_eq_toIocDiv_add_one /-
theorem modEq_iff_toIcoDiv_eq_toIocDiv_add_one :
    a ≡ b [PMOD p] ↔ toIcoDiv hp a b = toIocDiv hp a b + 1 := by
  rw [modeq_iff_to_Ico_mod_add_period_eq_to_Ioc_mod hp, toIcoMod, toIocMod, ← eq_sub_iff_add_eq,
    sub_sub, sub_right_inj, ← add_one_zsmul, (zsmul_strictMono_left hp).Injective.eq_iff]
#align add_comm_group.modeq_iff_to_Ico_div_eq_to_Ioc_div_add_one AddCommGroup.modEq_iff_toIcoDiv_eq_toIocDiv_add_one
-/

end AddCommGroup

open AddCommGroup

#print toIcoMod_inj /-
/-- If `a` and `b` fall within the same cycle WRT `c`, then they are congruent modulo `p`. -/
@[simp]
theorem toIcoMod_inj {c : α} : toIcoMod hp c a = toIcoMod hp c b ↔ a ≡ b [PMOD p] := by
  simp_rw [toIcoMod_eq_toIcoMod, modeq_iff_eq_add_zsmul, sub_eq_iff_eq_add']
#align to_Ico_mod_inj toIcoMod_inj
-/

alias toIcoMod_inj ↔ _ AddCommGroup.ModEq.toIcoMod_eq_toIcoMod
#align add_comm_group.modeq.to_Ico_mod_eq_to_Ico_mod AddCommGroup.ModEq.toIcoMod_eq_toIcoMod

#print Ico_eq_locus_Ioc_eq_iUnion_Ioo /-
theorem Ico_eq_locus_Ioc_eq_iUnion_Ioo :
    {b | toIcoMod hp a b = toIocMod hp a b} = ⋃ z : ℤ, Set.Ioo (a + z • p) (a + p + z • p) := by
  ext1;
  simp_rw [Set.mem_setOf, Set.mem_iUnion, ← Set.sub_mem_Ioo_iff_left, ←
    not_modeq_iff_to_Ico_mod_eq_to_Ioc_mod, modeq_iff_not_forall_mem_Ioo_mod hp, not_forall,
    Classical.not_not]
#align Ico_eq_locus_Ioc_eq_Union_Ioo Ico_eq_locus_Ioc_eq_iUnion_Ioo
-/

#print toIocDiv_wcovby_toIcoDiv /-
theorem toIocDiv_wcovby_toIcoDiv (a b : α) : toIocDiv hp a b ⩿ toIcoDiv hp a b :=
  by
  suffices toIocDiv hp a b = toIcoDiv hp a b ∨ toIocDiv hp a b + 1 = toIcoDiv hp a b by
    rwa [wcovby_iff_eq_or_covby, ← Order.succ_eq_iff_covby]
  rw [eq_comm, ← not_modeq_iff_to_Ico_div_eq_to_Ioc_div, eq_comm, ←
    modeq_iff_to_Ico_div_eq_to_Ioc_div_add_one]
  exact em' _
#align to_Ioc_div_wcovby_to_Ico_div toIocDiv_wcovby_toIcoDiv
-/

#print toIcoMod_le_toIocMod /-
theorem toIcoMod_le_toIocMod (a b : α) : toIcoMod hp a b ≤ toIocMod hp a b :=
  by
  rw [toIcoMod, toIocMod, sub_le_sub_iff_left]
  exact zsmul_mono_left hp.le (toIocDiv_wcovby_toIcoDiv _ _ _).le
#align to_Ico_mod_le_to_Ioc_mod toIcoMod_le_toIocMod
-/

#print toIocMod_le_toIcoMod_add /-
theorem toIocMod_le_toIcoMod_add (a b : α) : toIocMod hp a b ≤ toIcoMod hp a b + p :=
  by
  rw [toIcoMod, toIocMod, sub_add, sub_le_sub_iff_left, sub_le_iff_le_add, ← add_one_zsmul,
    (zsmul_strictMono_left hp).le_iff_le]
  apply (toIocDiv_wcovby_toIcoDiv _ _ _).le_succ
#align to_Ioc_mod_le_to_Ico_mod_add toIocMod_le_toIcoMod_add
-/

end IcoIoc

open AddCommGroup

#print toIcoMod_eq_self /-
theorem toIcoMod_eq_self : toIcoMod hp a b = b ↔ b ∈ Set.Ico a (a + p) := by
  rw [toIcoMod_eq_iff, and_iff_left]; exact ⟨0, by simp⟩
#align to_Ico_mod_eq_self toIcoMod_eq_self
-/

#print toIocMod_eq_self /-
theorem toIocMod_eq_self : toIocMod hp a b = b ↔ b ∈ Set.Ioc a (a + p) := by
  rw [toIocMod_eq_iff, and_iff_left]; exact ⟨0, by simp⟩
#align to_Ioc_mod_eq_self toIocMod_eq_self
-/

#print toIcoMod_toIcoMod /-
@[simp]
theorem toIcoMod_toIcoMod (a₁ a₂ b : α) : toIcoMod hp a₁ (toIcoMod hp a₂ b) = toIcoMod hp a₁ b :=
  (toIcoMod_eq_toIcoMod _).2 ⟨toIcoDiv hp a₂ b, self_sub_toIcoMod hp a₂ b⟩
#align to_Ico_mod_to_Ico_mod toIcoMod_toIcoMod
-/

#print toIcoMod_toIocMod /-
@[simp]
theorem toIcoMod_toIocMod (a₁ a₂ b : α) : toIcoMod hp a₁ (toIocMod hp a₂ b) = toIcoMod hp a₁ b :=
  (toIcoMod_eq_toIcoMod _).2 ⟨toIocDiv hp a₂ b, self_sub_toIocMod hp a₂ b⟩
#align to_Ico_mod_to_Ioc_mod toIcoMod_toIocMod
-/

#print toIocMod_toIocMod /-
@[simp]
theorem toIocMod_toIocMod (a₁ a₂ b : α) : toIocMod hp a₁ (toIocMod hp a₂ b) = toIocMod hp a₁ b :=
  (toIocMod_eq_toIocMod _).2 ⟨toIocDiv hp a₂ b, self_sub_toIocMod hp a₂ b⟩
#align to_Ioc_mod_to_Ioc_mod toIocMod_toIocMod
-/

#print toIocMod_toIcoMod /-
@[simp]
theorem toIocMod_toIcoMod (a₁ a₂ b : α) : toIocMod hp a₁ (toIcoMod hp a₂ b) = toIocMod hp a₁ b :=
  (toIocMod_eq_toIocMod _).2 ⟨toIcoDiv hp a₂ b, self_sub_toIcoMod hp a₂ b⟩
#align to_Ioc_mod_to_Ico_mod toIocMod_toIcoMod
-/

#print toIcoMod_periodic /-
theorem toIcoMod_periodic (a : α) : Function.Periodic (toIcoMod hp a) p :=
  toIcoMod_add_right hp a
#align to_Ico_mod_periodic toIcoMod_periodic
-/

#print toIocMod_periodic /-
theorem toIocMod_periodic (a : α) : Function.Periodic (toIocMod hp a) p :=
  toIocMod_add_right hp a
#align to_Ioc_mod_periodic toIocMod_periodic
-/

-- helper lemmas for when `a = 0`
section Zero

#print toIcoMod_zero_sub_comm /-
theorem toIcoMod_zero_sub_comm (a b : α) : toIcoMod hp 0 (a - b) = p - toIocMod hp 0 (b - a) := by
  rw [← neg_sub, toIcoMod_neg, neg_zero]
#align to_Ico_mod_zero_sub_comm toIcoMod_zero_sub_comm
-/

#print toIocMod_zero_sub_comm /-
theorem toIocMod_zero_sub_comm (a b : α) : toIocMod hp 0 (a - b) = p - toIcoMod hp 0 (b - a) := by
  rw [← neg_sub, toIocMod_neg, neg_zero]
#align to_Ioc_mod_zero_sub_comm toIocMod_zero_sub_comm
-/

#print toIcoDiv_eq_sub /-
theorem toIcoDiv_eq_sub (a b : α) : toIcoDiv hp a b = toIcoDiv hp 0 (b - a) := by
  rw [toIcoDiv_sub_eq_toIcoDiv_add, zero_add]
#align to_Ico_div_eq_sub toIcoDiv_eq_sub
-/

#print toIocDiv_eq_sub /-
theorem toIocDiv_eq_sub (a b : α) : toIocDiv hp a b = toIocDiv hp 0 (b - a) := by
  rw [toIocDiv_sub_eq_toIocDiv_add, zero_add]
#align to_Ioc_div_eq_sub toIocDiv_eq_sub
-/

#print toIcoMod_eq_sub /-
theorem toIcoMod_eq_sub (a b : α) : toIcoMod hp a b = toIcoMod hp 0 (b - a) + a := by
  rw [toIcoMod_sub_eq_sub, zero_add, sub_add_cancel]
#align to_Ico_mod_eq_sub toIcoMod_eq_sub
-/

#print toIocMod_eq_sub /-
theorem toIocMod_eq_sub (a b : α) : toIocMod hp a b = toIocMod hp 0 (b - a) + a := by
  rw [toIocMod_sub_eq_sub, zero_add, sub_add_cancel]
#align to_Ioc_mod_eq_sub toIocMod_eq_sub
-/

#print toIcoMod_add_toIocMod_zero /-
theorem toIcoMod_add_toIocMod_zero (a b : α) : toIcoMod hp 0 (a - b) + toIocMod hp 0 (b - a) = p :=
  by rw [toIcoMod_zero_sub_comm, sub_add_cancel]
#align to_Ico_mod_add_to_Ioc_mod_zero toIcoMod_add_toIocMod_zero
-/

#print toIocMod_add_toIcoMod_zero /-
theorem toIocMod_add_toIcoMod_zero (a b : α) : toIocMod hp 0 (a - b) + toIcoMod hp 0 (b - a) = p :=
  by rw [add_comm, toIcoMod_add_toIocMod_zero]
#align to_Ioc_mod_add_to_Ico_mod_zero toIocMod_add_toIcoMod_zero
-/

end Zero

#print QuotientAddGroup.equivIcoMod /-
/-- `to_Ico_mod` as an equiv from the quotient. -/
@[simps symm_apply]
def QuotientAddGroup.equivIcoMod (a : α) : α ⧸ AddSubgroup.zmultiples p ≃ Set.Ico a (a + p)
    where
  toFun b :=
    ⟨(toIcoMod_periodic hp a).lift b, QuotientAddGroup.induction_on' b <| toIcoMod_mem_Ico hp a⟩
  invFun := coe
  right_inv b := Subtype.ext <| (toIcoMod_eq_self hp).mpr b.Prop
  left_inv b := by
    induction b using QuotientAddGroup.induction_on'
    dsimp
    rw [QuotientAddGroup.eq_iff_sub_mem, toIcoMod_sub_self]
    apply AddSubgroup.zsmul_mem_zmultiples
#align quotient_add_group.equiv_Ico_mod QuotientAddGroup.equivIcoMod
-/

#print QuotientAddGroup.equivIcoMod_coe /-
@[simp]
theorem QuotientAddGroup.equivIcoMod_coe (a b : α) :
    QuotientAddGroup.equivIcoMod hp a ↑b = ⟨toIcoMod hp a b, toIcoMod_mem_Ico hp a _⟩ :=
  rfl
#align quotient_add_group.equiv_Ico_mod_coe QuotientAddGroup.equivIcoMod_coe
-/

#print QuotientAddGroup.equivIcoMod_zero /-
@[simp]
theorem QuotientAddGroup.equivIcoMod_zero (a : α) :
    QuotientAddGroup.equivIcoMod hp a 0 = ⟨toIcoMod hp a 0, toIcoMod_mem_Ico hp a _⟩ :=
  rfl
#align quotient_add_group.equiv_Ico_mod_zero QuotientAddGroup.equivIcoMod_zero
-/

#print QuotientAddGroup.equivIocMod /-
/-- `to_Ioc_mod` as an equiv from the quotient. -/
@[simps symm_apply]
def QuotientAddGroup.equivIocMod (a : α) : α ⧸ AddSubgroup.zmultiples p ≃ Set.Ioc a (a + p)
    where
  toFun b :=
    ⟨(toIocMod_periodic hp a).lift b, QuotientAddGroup.induction_on' b <| toIocMod_mem_Ioc hp a⟩
  invFun := coe
  right_inv b := Subtype.ext <| (toIocMod_eq_self hp).mpr b.Prop
  left_inv b := by
    induction b using QuotientAddGroup.induction_on'
    dsimp
    rw [QuotientAddGroup.eq_iff_sub_mem, toIocMod_sub_self]
    apply AddSubgroup.zsmul_mem_zmultiples
#align quotient_add_group.equiv_Ioc_mod QuotientAddGroup.equivIocMod
-/

#print QuotientAddGroup.equivIocMod_coe /-
@[simp]
theorem QuotientAddGroup.equivIocMod_coe (a b : α) :
    QuotientAddGroup.equivIocMod hp a ↑b = ⟨toIocMod hp a b, toIocMod_mem_Ioc hp a _⟩ :=
  rfl
#align quotient_add_group.equiv_Ioc_mod_coe QuotientAddGroup.equivIocMod_coe
-/

#print QuotientAddGroup.equivIocMod_zero /-
@[simp]
theorem QuotientAddGroup.equivIocMod_zero (a : α) :
    QuotientAddGroup.equivIocMod hp a 0 = ⟨toIocMod hp a 0, toIocMod_mem_Ioc hp a _⟩ :=
  rfl
#align quotient_add_group.equiv_Ioc_mod_zero QuotientAddGroup.equivIocMod_zero
-/

/-!
### The circular order structure on `α ⧸ add_subgroup.zmultiples p`
-/


section Circular

private theorem to_Ixx_mod_iff (x₁ x₂ x₃ : α) :
    toIcoMod hp x₁ x₂ ≤ toIocMod hp x₁ x₃ ↔ toIcoMod hp 0 (x₂ - x₁) + toIcoMod hp 0 (x₁ - x₃) ≤ p :=
  by
  rw [toIcoMod_eq_sub, toIocMod_eq_sub _ x₁, add_le_add_iff_right, ← neg_sub x₁ x₃, toIocMod_neg,
    neg_zero, le_sub_iff_add_le]

private theorem to_Ixx_mod_cyclic_left {x₁ x₂ x₃ : α} (h : toIcoMod hp x₁ x₂ ≤ toIocMod hp x₁ x₃) :
    toIcoMod hp x₂ x₃ ≤ toIocMod hp x₂ x₁ :=
  by
  let x₂' := toIcoMod hp x₁ x₂
  let x₃' := toIcoMod hp x₂' x₃
  have h : x₂' ≤ toIocMod hp x₁ x₃' := by simpa
  have h₂₁ : x₂' < x₁ + p := toIcoMod_lt_right _ _ _
  have h₃₂ : x₃' - p < x₂' := sub_lt_iff_lt_add.2 (toIcoMod_lt_right _ _ _)
  suffices hequiv : x₃' ≤ toIocMod hp x₂' x₁
  · obtain ⟨z, hd⟩ : ∃ z : ℤ, x₂ = x₂' + z • p := ((toIcoMod_eq_iff hp).1 rfl).2
    simpa [hd]
  cases' le_or_lt x₃' (x₁ + p) with h₃₁ h₁₃
  · suffices hIoc₂₁ : toIocMod hp x₂' x₁ = x₁ + p
    · exact hIoc₂₁.symm.trans_ge h₃₁
    apply (toIocMod_eq_iff hp).2
    exact ⟨⟨h₂₁, by simp [left_le_toIcoMod]⟩, -1, by simp⟩
  have hIoc₁₃ : toIocMod hp x₁ x₃' = x₃' - p :=
    by
    apply (toIocMod_eq_iff hp).2
    exact ⟨⟨lt_sub_iff_add_lt.2 h₁₃, le_of_lt (h₃₂.trans h₂₁)⟩, 1, by simp⟩
  have not_h₃₂ := (h.trans hIoc₁₃.le).not_lt
  contradiction

private theorem to_Ixx_mod_antisymm (h₁₂₃ : toIcoMod hp a b ≤ toIocMod hp a c)
    (h₁₃₂ : toIcoMod hp a c ≤ toIocMod hp a b) : b ≡ a [PMOD p] ∨ c ≡ b [PMOD p] ∨ a ≡ c [PMOD p] :=
  by
  by_contra' h
  rw [modeq_comm] at h 
  rw [← (not_modeq_iff_to_Ico_mod_eq_to_Ioc_mod hp).mp h.2.2] at h₁₂₃ 
  rw [← (not_modeq_iff_to_Ico_mod_eq_to_Ioc_mod hp).mp h.1] at h₁₃₂ 
  exact h.2.1 ((toIcoMod_inj _).1 <| h₁₃₂.antisymm h₁₂₃)

private theorem to_Ixx_mod_total' (a b c : α) :
    toIcoMod hp b a ≤ toIocMod hp b c ∨ toIcoMod hp b c ≤ toIocMod hp b a :=
  by
  /- an essential ingredient is the lemma sabing {a-b} + {b-a} = period if a ≠ b (and = 0 if a = b).
    Thus if a ≠ b and b ≠ c then ({a-b} + {b-c}) + ({c-b} + {b-a}) = 2 * period, so one of
    `{a-b} + {b-c}` and `{c-b} + {b-a}` must be `≤ period` -/
  have := congr_arg₂ (· + ·) (toIcoMod_add_toIocMod_zero hp a b) (toIcoMod_add_toIocMod_zero hp c b)
  rw [add_add_add_comm, add_comm (toIocMod _ _ _), add_add_add_comm, ← two_nsmul] at this 
  replace := min_le_of_add_le_two_nsmul this.le
  rw [min_le_iff] at this 
  rw [to_Ixx_mod_iff, to_Ixx_mod_iff]
  refine' this.imp (le_trans <| add_le_add_left _ _) (le_trans <| add_le_add_left _ _)
  · apply toIcoMod_le_toIocMod
  · apply toIcoMod_le_toIocMod

private theorem to_Ixx_mod_total (a b c : α) :
    toIcoMod hp a b ≤ toIocMod hp a c ∨ toIcoMod hp c b ≤ toIocMod hp c a :=
  (to_Ixx_mod_total' _ _ _ _).imp_right <| to_Ixx_mod_cyclic_left _

private theorem to_Ixx_mod_trans {x₁ x₂ x₃ x₄ : α}
    (h₁₂₃ : toIcoMod hp x₁ x₂ ≤ toIocMod hp x₁ x₃ ∧ ¬toIcoMod hp x₃ x₂ ≤ toIocMod hp x₃ x₁)
    (h₂₃₄ : toIcoMod hp x₂ x₄ ≤ toIocMod hp x₂ x₃ ∧ ¬toIcoMod hp x₃ x₄ ≤ toIocMod hp x₃ x₂) :
    toIcoMod hp x₁ x₄ ≤ toIocMod hp x₁ x₃ ∧ ¬toIcoMod hp x₃ x₄ ≤ toIocMod hp x₃ x₁ :=
  by
  constructor
  · suffices h : ¬x₃ ≡ x₂ [PMOD p]
    · have h₁₂₃' := to_Ixx_mod_cyclic_left _ (to_Ixx_mod_cyclic_left _ h₁₂₃.1)
      have h₂₃₄' := to_Ixx_mod_cyclic_left _ (to_Ixx_mod_cyclic_left _ h₂₃₄.1)
      rw [(not_modeq_iff_to_Ico_mod_eq_to_Ioc_mod hp).1 h] at h₂₃₄' 
      exact to_Ixx_mod_cyclic_left _ (h₁₂₃'.trans h₂₃₄')
    by_contra
    rw [(modeq_iff_to_Ico_mod_eq_left hp).1 h] at h₁₂₃ 
    exact h₁₂₃.2 (left_lt_toIocMod _ _ _).le
  · rw [not_le] at h₁₂₃ h₂₃₄ ⊢
    exact (h₁₂₃.2.trans_le (toIcoMod_le_toIocMod _ x₃ x₂)).trans h₂₃₄.2

namespace quotientAddGroup

variable [hp' : Fact (0 < p)]

instance : Btw (α ⧸ AddSubgroup.zmultiples p)
    where Btw x₁ x₂ x₃ := (equivIcoMod hp'.out 0 (x₂ - x₁) : α) ≤ equivIocMod hp'.out 0 (x₃ - x₁)

#print QuotientAddGroup.btw_coe_iff' /-
theorem btw_coe_iff' {x₁ x₂ x₃ : α} :
    Btw.Btw (x₁ : α ⧸ AddSubgroup.zmultiples p) x₂ x₃ ↔
      toIcoMod hp'.out 0 (x₂ - x₁) ≤ toIocMod hp'.out 0 (x₃ - x₁) :=
  Iff.rfl
#align quotient_add_group.btw_coe_iff' QuotientAddGroup.btw_coe_iff'
-/

#print QuotientAddGroup.btw_coe_iff /-
-- maybe harder to use than the primed one?
theorem btw_coe_iff {x₁ x₂ x₃ : α} :
    Btw.Btw (x₁ : α ⧸ AddSubgroup.zmultiples p) x₂ x₃ ↔
      toIcoMod hp'.out x₁ x₂ ≤ toIocMod hp'.out x₁ x₃ :=
  by rw [btw_coe_iff', toIocMod_sub_eq_sub, toIcoMod_sub_eq_sub, zero_add, sub_le_sub_iff_right]
#align quotient_add_group.btw_coe_iff QuotientAddGroup.btw_coe_iff
-/

#print QuotientAddGroup.circularPreorder /-
instance circularPreorder : CircularPreorder (α ⧸ AddSubgroup.zmultiples p)
    where
  btw_refl x := show _ ≤ _ by simp [sub_self, hp'.out.le]
  btw_cyclic_left x₁ x₂ x₃ h :=
    by
    induction x₁ using QuotientAddGroup.induction_on'
    induction x₂ using QuotientAddGroup.induction_on'
    induction x₃ using QuotientAddGroup.induction_on'
    simp_rw [btw_coe_iff] at h ⊢
    apply to_Ixx_mod_cyclic_left _ h
  Sbtw := _
  sbtw_iff_btw_not_btw _ _ _ := Iff.rfl
  sbtw_trans_left x₁ x₂ x₃ x₄ (h₁₂₃ : _ ∧ _) (h₂₃₄ : _ ∧ _) :=
    show _ ∧ _ by
      induction x₁ using QuotientAddGroup.induction_on'
      induction x₂ using QuotientAddGroup.induction_on'
      induction x₃ using QuotientAddGroup.induction_on'
      induction x₄ using QuotientAddGroup.induction_on'
      simp_rw [btw_coe_iff] at h₁₂₃ h₂₃₄ ⊢
      apply to_Ixx_mod_trans _ h₁₂₃ h₂₃₄
#align quotient_add_group.circular_preorder QuotientAddGroup.circularPreorder
-/

#print QuotientAddGroup.circularOrder /-
instance circularOrder : CircularOrder (α ⧸ AddSubgroup.zmultiples p) :=
  {
    QuotientAddGroup.circularPreorder with
    btw_antisymm := fun x₁ x₂ x₃ h₁₂₃ h₃₂₁ =>
      by
      induction x₁ using QuotientAddGroup.induction_on'
      induction x₂ using QuotientAddGroup.induction_on'
      induction x₃ using QuotientAddGroup.induction_on'
      rw [btw_cyclic] at h₃₂₁ 
      simp_rw [btw_coe_iff] at h₁₂₃ h₃₂₁ 
      simp_rw [← modeq_iff_eq_mod_zmultiples]
      exact to_Ixx_mod_antisymm _ h₁₂₃ h₃₂₁
    btw_total := fun x₁ x₂ x₃ =>
      by
      induction x₁ using QuotientAddGroup.induction_on'
      induction x₂ using QuotientAddGroup.induction_on'
      induction x₃ using QuotientAddGroup.induction_on'
      simp_rw [btw_coe_iff]
      apply to_Ixx_mod_total }
#align quotient_add_group.circular_order QuotientAddGroup.circularOrder
-/

end quotientAddGroup

end Circular

end LinearOrderedAddCommGroup

/-!
### Connections to `int.floor` and `int.fract`
-/


section LinearOrderedField

variable {α : Type _} [LinearOrderedField α] [FloorRing α] {p : α} (hp : 0 < p)

#print toIcoDiv_eq_floor /-
theorem toIcoDiv_eq_floor (a b : α) : toIcoDiv hp a b = ⌊(b - a) / p⌋ :=
  by
  refine' toIcoDiv_eq_of_sub_zsmul_mem_Ico hp _
  rw [Set.mem_Ico, zsmul_eq_mul, ← sub_nonneg, add_comm, sub_right_comm, ← sub_lt_iff_lt_add,
    sub_right_comm _ _ a]
  exact ⟨Int.sub_floor_div_mul_nonneg _ hp, Int.sub_floor_div_mul_lt _ hp⟩
#align to_Ico_div_eq_floor toIcoDiv_eq_floor
-/

#print toIocDiv_eq_neg_floor /-
theorem toIocDiv_eq_neg_floor (a b : α) : toIocDiv hp a b = -⌊(a + p - b) / p⌋ :=
  by
  refine' toIocDiv_eq_of_sub_zsmul_mem_Ioc hp _
  rw [Set.mem_Ioc, zsmul_eq_mul, Int.cast_neg, neg_mul, sub_neg_eq_add, ← sub_nonneg,
    sub_add_eq_sub_sub]
  refine' ⟨_, Int.sub_floor_div_mul_nonneg _ hp⟩
  rw [← add_lt_add_iff_right p, add_assoc, add_comm b, ← sub_lt_iff_lt_add, add_comm (_ * _), ←
    sub_lt_iff_lt_add]
  exact Int.sub_floor_div_mul_lt _ hp
#align to_Ioc_div_eq_neg_floor toIocDiv_eq_neg_floor
-/

#print toIcoDiv_zero_one /-
theorem toIcoDiv_zero_one (b : α) : toIcoDiv (zero_lt_one' α) 0 b = ⌊b⌋ := by
  simp [toIcoDiv_eq_floor]
#align to_Ico_div_zero_one toIcoDiv_zero_one
-/

#print toIcoMod_eq_add_fract_mul /-
theorem toIcoMod_eq_add_fract_mul (a b : α) : toIcoMod hp a b = a + Int.fract ((b - a) / p) * p :=
  by
  rw [toIcoMod, toIcoDiv_eq_floor, Int.fract]
  field_simp [hp.ne.symm]
  ring
#align to_Ico_mod_eq_add_fract_mul toIcoMod_eq_add_fract_mul
-/

#print toIcoMod_eq_fract_mul /-
theorem toIcoMod_eq_fract_mul (b : α) : toIcoMod hp 0 b = Int.fract (b / p) * p := by
  simp [toIcoMod_eq_add_fract_mul]
#align to_Ico_mod_eq_fract_mul toIcoMod_eq_fract_mul
-/

#print toIocMod_eq_sub_fract_mul /-
theorem toIocMod_eq_sub_fract_mul (a b : α) :
    toIocMod hp a b = a + p - Int.fract ((a + p - b) / p) * p :=
  by
  rw [toIocMod, toIocDiv_eq_neg_floor, Int.fract]
  field_simp [hp.ne.symm]
  ring
#align to_Ioc_mod_eq_sub_fract_mul toIocMod_eq_sub_fract_mul
-/

#print toIcoMod_zero_one /-
theorem toIcoMod_zero_one (b : α) : toIcoMod (zero_lt_one' α) 0 b = Int.fract b := by
  simp [toIcoMod_eq_add_fract_mul]
#align to_Ico_mod_zero_one toIcoMod_zero_one
-/

end LinearOrderedField

/-! ### Lemmas about unions of translates of intervals -/


section Union

open Set Int

section LinearOrderedAddCommGroup

variable {α : Type _} [LinearOrderedAddCommGroup α] [Archimedean α] {p : α} (hp : 0 < p) (a : α)

#print iUnion_Ioc_add_zsmul /-
theorem iUnion_Ioc_add_zsmul : (⋃ n : ℤ, Ioc (a + n • p) (a + (n + 1) • p)) = univ :=
  by
  refine' eq_univ_iff_forall.mpr fun b => mem_Union.mpr _
  rcases sub_toIocDiv_zsmul_mem_Ioc hp a b with ⟨hl, hr⟩
  refine' ⟨toIocDiv hp a b, ⟨lt_sub_iff_add_lt.mp hl, _⟩⟩
  rw [add_smul, one_smul, ← add_assoc]
  convert sub_le_iff_le_add.mp hr using 1; abel
#align Union_Ioc_add_zsmul iUnion_Ioc_add_zsmul
-/

#print iUnion_Ico_add_zsmul /-
theorem iUnion_Ico_add_zsmul : (⋃ n : ℤ, Ico (a + n • p) (a + (n + 1) • p)) = univ :=
  by
  refine' eq_univ_iff_forall.mpr fun b => mem_Union.mpr _
  rcases sub_toIcoDiv_zsmul_mem_Ico hp a b with ⟨hl, hr⟩
  refine' ⟨toIcoDiv hp a b, ⟨le_sub_iff_add_le.mp hl, _⟩⟩
  rw [add_smul, one_smul, ← add_assoc]
  convert sub_lt_iff_lt_add.mp hr using 1; abel
#align Union_Ico_add_zsmul iUnion_Ico_add_zsmul
-/

#print iUnion_Icc_add_zsmul /-
theorem iUnion_Icc_add_zsmul : (⋃ n : ℤ, Icc (a + n • p) (a + (n + 1) • p)) = univ := by
  simpa only [iUnion_Ioc_add_zsmul hp a, univ_subset_iff] using
    Union_mono fun n : ℤ => (Ioc_subset_Icc_self : Ioc (a + n • p) (a + (n + 1) • p) ⊆ Icc _ _)
#align Union_Icc_add_zsmul iUnion_Icc_add_zsmul
-/

#print iUnion_Ioc_zsmul /-
theorem iUnion_Ioc_zsmul : (⋃ n : ℤ, Ioc (n • p) ((n + 1) • p)) = univ := by
  simpa only [zero_add] using iUnion_Ioc_add_zsmul hp 0
#align Union_Ioc_zsmul iUnion_Ioc_zsmul
-/

#print iUnion_Ico_zsmul /-
theorem iUnion_Ico_zsmul : (⋃ n : ℤ, Ico (n • p) ((n + 1) • p)) = univ := by
  simpa only [zero_add] using iUnion_Ico_add_zsmul hp 0
#align Union_Ico_zsmul iUnion_Ico_zsmul
-/

#print iUnion_Icc_zsmul /-
theorem iUnion_Icc_zsmul : (⋃ n : ℤ, Icc (n • p) ((n + 1) • p)) = univ := by
  simpa only [zero_add] using iUnion_Icc_add_zsmul hp 0
#align Union_Icc_zsmul iUnion_Icc_zsmul
-/

end LinearOrderedAddCommGroup

section LinearOrderedRing

variable {α : Type _} [LinearOrderedRing α] [Archimedean α] (a : α)

#print iUnion_Ioc_add_int_cast /-
theorem iUnion_Ioc_add_int_cast : (⋃ n : ℤ, Ioc (a + n) (a + n + 1)) = Set.univ := by
  simpa only [zsmul_one, Int.cast_add, Int.cast_one, ← add_assoc] using
    iUnion_Ioc_add_zsmul zero_lt_one a
#align Union_Ioc_add_int_cast iUnion_Ioc_add_int_cast
-/

#print iUnion_Ico_add_int_cast /-
theorem iUnion_Ico_add_int_cast : (⋃ n : ℤ, Ico (a + n) (a + n + 1)) = Set.univ := by
  simpa only [zsmul_one, Int.cast_add, Int.cast_one, ← add_assoc] using
    iUnion_Ico_add_zsmul zero_lt_one a
#align Union_Ico_add_int_cast iUnion_Ico_add_int_cast
-/

#print iUnion_Icc_add_int_cast /-
theorem iUnion_Icc_add_int_cast : (⋃ n : ℤ, Icc (a + n) (a + n + 1)) = Set.univ := by
  simpa only [zsmul_one, Int.cast_add, Int.cast_one, ← add_assoc] using
    iUnion_Icc_add_zsmul zero_lt_one a
#align Union_Icc_add_int_cast iUnion_Icc_add_int_cast
-/

variable (α)

#print iUnion_Ioc_int_cast /-
theorem iUnion_Ioc_int_cast : (⋃ n : ℤ, Ioc (n : α) (n + 1)) = Set.univ := by
  simpa only [zero_add] using iUnion_Ioc_add_int_cast (0 : α)
#align Union_Ioc_int_cast iUnion_Ioc_int_cast
-/

#print iUnion_Ico_int_cast /-
theorem iUnion_Ico_int_cast : (⋃ n : ℤ, Ico (n : α) (n + 1)) = Set.univ := by
  simpa only [zero_add] using iUnion_Ico_add_int_cast (0 : α)
#align Union_Ico_int_cast iUnion_Ico_int_cast
-/

#print iUnion_Icc_int_cast /-
theorem iUnion_Icc_int_cast : (⋃ n : ℤ, Icc (n : α) (n + 1)) = Set.univ := by
  simpa only [zero_add] using iUnion_Icc_add_int_cast (0 : α)
#align Union_Icc_int_cast iUnion_Icc_int_cast
-/

end LinearOrderedRing

end Union

