/-
Copyright (c) 2019 Seul Baek. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Seul Baek

! This file was ported from Lean 3 source module data.list.func
! leanprover-community/mathlib commit d11893b411025250c8e61ff2f12ccbd7ee35ab15
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Order.Basic

/-!
# Lists as Functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Definitions for using lists as finite representations of finitely-supported functions with domain
ℕ.

These include pointwise operations on lists, as well as get and set operations.

## Notations

An index notation is introduced in this file for setting a particular element of a list. With `as`
as a list `m` as an index, and `a` as a new element, the notation is `as {m ↦ a}`.

So, for example
`[1, 3, 5] {1 ↦ 9}` would result in `[1, 9, 5]`

This notation is in the locale `list.func`.
-/


open List

universe u v w

variable {α : Type u} {β : Type v} {γ : Type w}

namespace List

namespace Func

variable {a : α}

variable {as as1 as2 as3 : List α}

#print List.Func.neg /-
/-- Elementwise negation of a list -/
def neg [Neg α] (as : List α) :=
  as.map fun a => -a
#align list.func.neg List.Func.neg
-/

variable [Inhabited α] [Inhabited β]

#print List.Func.set /-
/-- Update element of a list by index. If the index is out of range, extend the list with default
elements
-/
@[simp]
def set (a : α) : List α → ℕ → List α
  | _ :: as, 0 => a :: as
  | [], 0 => [a]
  | h :: as, k + 1 => h :: Set as k
  | [], k + 1 => default :: Set ([] : List α) k
#align list.func.set List.Func.set
-/

scoped notation as " {" m " ↦ " a "}" => List.Func.set a as m

#print List.Func.get /-
/-- Get element of a list by index. If the index is out of range, return the default element -/
@[simp]
def get : ℕ → List α → α
  | _, [] => default
  | 0, a :: as => a
  | n + 1, a :: as => get n as
#align list.func.get List.Func.get
-/

#print List.Func.Equiv /-
/-- Pointwise equality of lists. If lists are different lengths, compare with the default
element.
-/
def Equiv (as1 as2 : List α) : Prop :=
  ∀ m : Nat, get m as1 = get m as2
#align list.func.equiv List.Func.Equiv
-/

#print List.Func.pointwise /-
/-- Pointwise operations on lists. If lists are different lengths, use the default element. -/
@[simp]
def pointwise (f : α → β → γ) : List α → List β → List γ
  | [], [] => []
  | [], b :: bs => map (f default) (b :: bs)
  | a :: as, [] => map (fun x => f x default) (a :: as)
  | a :: as, b :: bs => f a b :: pointwise as bs
#align list.func.pointwise List.Func.pointwise
-/

#print List.Func.add /-
/-- Pointwise addition on lists. If lists are different lengths, use zero. -/
def add {α : Type u} [Zero α] [Add α] : List α → List α → List α :=
  @pointwise α α α ⟨0⟩ ⟨0⟩ (· + ·)
#align list.func.add List.Func.add
-/

#print List.Func.sub /-
/-- Pointwise subtraction on lists. If lists are different lengths, use zero. -/
def sub {α : Type u} [Zero α] [Sub α] : List α → List α → List α :=
  @pointwise α α α ⟨0⟩ ⟨0⟩ (@Sub.sub α _)
#align list.func.sub List.Func.sub
-/

#print List.Func.length_set /-
-- set
theorem length_set : ∀ {m : ℕ} {as : List α}, as {m ↦ a}.length = max as.length (m + 1)
  | 0, [] => rfl
  | 0, a :: as => by rw [max_eq_left]; rfl; simp [Nat.le_add_right]
  | m + 1, [] => by simp only [Set, Nat.zero_max, length, @length_set m]
  | m + 1, a :: as => by simp only [Set, Nat.max_succ_succ, length, @length_set m]
#align list.func.length_set List.Func.length_set
-/

#print List.Func.get_nil /-
@[simp]
theorem get_nil {k : ℕ} : (get k [] : α) = default := by cases k <;> rfl
#align list.func.get_nil List.Func.get_nil
-/

#print List.Func.get_eq_default_of_le /-
theorem get_eq_default_of_le : ∀ (k : ℕ) {as : List α}, as.length ≤ k → get k as = default
  | 0, [], h1 => rfl
  | 0, a :: as, h1 => by cases h1
  | k + 1, [], h1 => rfl
  | k + 1, a :: as, h1 => by
    apply get_eq_default_of_le k
    rw [← Nat.succ_le_succ_iff]; apply h1
#align list.func.get_eq_default_of_le List.Func.get_eq_default_of_le
-/

#print List.Func.get_set /-
@[simp]
theorem get_set {a : α} : ∀ {k : ℕ} {as : List α}, get k (as {k ↦ a}) = a
  | 0, as => by cases as <;> rfl
  | k + 1, as => by cases as <;> simp [get_set]
#align list.func.get_set List.Func.get_set
-/

#print List.Func.eq_get_of_mem /-
theorem eq_get_of_mem {a : α} : ∀ {as : List α}, a ∈ as → ∃ n : Nat, ∀ d : α, a = get n as
  | [], h => by cases h
  | b :: as, h => by
    rw [mem_cons_iff] at h ; cases h
    · exists 0; intro d; apply h
    · cases' eq_get_of_mem h with n h2
      exists n + 1; apply h2
#align list.func.eq_get_of_mem List.Func.eq_get_of_mem
-/

#print List.Func.mem_get_of_le /-
theorem mem_get_of_le : ∀ {n : ℕ} {as : List α}, n < as.length → get n as ∈ as
  | _, [], h1 => by cases h1
  | 0, a :: as, _ => Or.inl rfl
  | n + 1, a :: as, h1 => by
    apply Or.inr; unfold get
    apply mem_get_of_le
    apply Nat.lt_of_succ_lt_succ h1
#align list.func.mem_get_of_le List.Func.mem_get_of_le
-/

#print List.Func.mem_get_of_ne_zero /-
theorem mem_get_of_ne_zero : ∀ {n : ℕ} {as : List α}, get n as ≠ default → get n as ∈ as
  | _, [], h1 => by exfalso; apply h1; rw [get_nil]
  | 0, a :: as, h1 => Or.inl rfl
  | n + 1, a :: as, h1 => by
    unfold get
    apply Or.inr (mem_get_of_ne_zero _)
    apply h1
#align list.func.mem_get_of_ne_zero List.Func.mem_get_of_ne_zero
-/

#print List.Func.get_set_eq_of_ne /-
theorem get_set_eq_of_ne {a : α} :
    ∀ {as : List α} (k : ℕ) (m : ℕ), m ≠ k → get m (as {k ↦ a}) = get m as
  | as, 0, m, h1 => by cases m; contradiction; cases as <;> simp only [Set, get, get_nil]
  | as, k + 1, m, h1 => by
    cases as <;> cases m
    simp only [Set, get]
    · have h3 : get m (nil {k ↦ a}) = default :=
        by
        rw [get_set_eq_of_ne k m, get_nil]
        intro hc; apply h1; simp [hc]
      apply h3
    simp only [Set, get]
    · apply get_set_eq_of_ne k m
      intro hc; apply h1; simp [hc]
#align list.func.get_set_eq_of_ne List.Func.get_set_eq_of_ne
-/

#print List.Func.get_map /-
theorem get_map {f : α → β} :
    ∀ {n : ℕ} {as : List α}, n < as.length → get n (as.map f) = f (get n as)
  | _, [], h => by cases h
  | 0, a :: as, h => rfl
  | n + 1, a :: as, h1 =>
    by
    have h2 : n < length as := by
      rw [← Nat.succ_le_iff, ← Nat.lt_succ_iff]
      apply h1
    apply get_map h2
#align list.func.get_map List.Func.get_map
-/

#print List.Func.get_map' /-
theorem get_map' {f : α → β} {n : ℕ} {as : List α} :
    f default = default → get n (as.map f) = f (get n as) :=
  by
  intro h1; by_cases h2 : n < as.length
  · apply get_map h2
  · rw [not_lt] at h2 
    rw [get_eq_default_of_le _ h2, get_eq_default_of_le, h1]
    rw [length_map]; apply h2
#align list.func.get_map' List.Func.get_map'
-/

#print List.Func.forall_val_of_forall_mem /-
theorem forall_val_of_forall_mem {as : List α} {p : α → Prop} :
    p default → (∀ x ∈ as, p x) → ∀ n, p (get n as) :=
  by
  intro h1 h2 n
  by_cases h3 : n < as.length
  · apply h2 _ (mem_get_of_le h3)
  · rw [not_lt] at h3 
    rw [get_eq_default_of_le _ h3]; apply h1
#align list.func.forall_val_of_forall_mem List.Func.forall_val_of_forall_mem
-/

#print List.Func.equiv_refl /-
-- equiv
theorem equiv_refl : Equiv as as := fun k => rfl
#align list.func.equiv_refl List.Func.equiv_refl
-/

#print List.Func.equiv_symm /-
theorem equiv_symm : Equiv as1 as2 → Equiv as2 as1 := fun h1 k => (h1 k).symm
#align list.func.equiv_symm List.Func.equiv_symm
-/

#print List.Func.equiv_trans /-
theorem equiv_trans : Equiv as1 as2 → Equiv as2 as3 → Equiv as1 as3 := fun h1 h2 k =>
  Eq.trans (h1 k) (h2 k)
#align list.func.equiv_trans List.Func.equiv_trans
-/

#print List.Func.equiv_of_eq /-
theorem equiv_of_eq : as1 = as2 → Equiv as1 as2 := by intro h1; rw [h1]; apply equiv_refl
#align list.func.equiv_of_eq List.Func.equiv_of_eq
-/

#print List.Func.eq_of_equiv /-
theorem eq_of_equiv : ∀ {as1 as2 : List α}, as1.length = as2.length → Equiv as1 as2 → as1 = as2
  | [], [], h1, h2 => rfl
  | _ :: _, [], h1, h2 => by cases h1
  | [], _ :: _, h1, h2 => by cases h1
  | a1 :: as1, a2 :: as2, h1, h2 => by
    congr
    · apply h2 0
    have h3 : as1.length = as2.length := by simpa [add_left_inj, add_comm, length] using h1
    apply eq_of_equiv h3
    intro m; apply h2 (m + 1)
#align list.func.eq_of_equiv List.Func.eq_of_equiv
-/

end Func

-- We want to drop the `inhabited` instances for a moment,
-- so we close and open the namespace
namespace Func

#print List.Func.get_neg /-
-- neg
@[simp]
theorem get_neg [AddGroup α] {k : ℕ} {as : List α} : @get α ⟨0⟩ k (neg as) = -@get α ⟨0⟩ k as := by
  unfold neg; rw [@get_map' α α ⟨0⟩]; apply neg_zero
#align list.func.get_neg List.Func.get_neg
-/

#print List.Func.length_neg /-
@[simp]
theorem length_neg [Neg α] (as : List α) : (neg as).length = as.length := by
  simp only [neg, length_map]
#align list.func.length_neg List.Func.length_neg
-/

variable [Inhabited α] [Inhabited β]

#print List.Func.nil_pointwise /-
-- pointwise
theorem nil_pointwise {f : α → β → γ} : ∀ bs : List β, pointwise f [] bs = bs.map (f default)
  | [] => rfl
  | b :: bs => by simp only [nil_pointwise bs, pointwise, eq_self_iff_true, and_self_iff, map]
#align list.func.nil_pointwise List.Func.nil_pointwise
-/

#print List.Func.pointwise_nil /-
theorem pointwise_nil {f : α → β → γ} :
    ∀ as : List α, pointwise f as [] = as.map fun a => f a default
  | [] => rfl
  | a :: as => by simp only [pointwise_nil as, pointwise, eq_self_iff_true, and_self_iff, List.map]
#align list.func.pointwise_nil List.Func.pointwise_nil
-/

#print List.Func.get_pointwise /-
theorem get_pointwise [Inhabited γ] {f : α → β → γ} (h1 : f default default = default) :
    ∀ (k : Nat) (as : List α) (bs : List β), get k (pointwise f as bs) = f (get k as) (get k bs)
  | k, [], [] => by simp only [h1, get_nil, pointwise, get]
  | 0, [], b :: bs => by simp only [get_pointwise, get_nil, pointwise, get, Nat.zero_eq, map]
  | k + 1, [], b :: bs =>
    by
    have : get k (map (f default) bs) = f default (get k bs) := by
      simpa [nil_pointwise, get_nil] using get_pointwise k [] bs
    simpa [get, get_nil, pointwise, map]
  | 0, a :: as, [] => by simp only [get_pointwise, get_nil, pointwise, get, Nat.zero_eq, map]
  | k + 1, a :: as, [] => by
    simpa [get, get_nil, pointwise, map, pointwise_nil, get_nil] using get_pointwise k as []
  | 0, a :: as, b :: bs => by simp only [pointwise, get]
  | k + 1, a :: as, b :: bs => by simp only [pointwise, get, get_pointwise k]
#align list.func.get_pointwise List.Func.get_pointwise
-/

#print List.Func.length_pointwise /-
theorem length_pointwise {f : α → β → γ} :
    ∀ {as : List α} {bs : List β}, (pointwise f as bs).length = max as.length bs.length
  | [], [] => rfl
  | [], b :: bs => by
    simp only [pointwise, length, length_map, max_eq_right (Nat.zero_le (length bs + 1))]
  | a :: as, [] => by
    simp only [pointwise, length, length_map, max_eq_left (Nat.zero_le (length as + 1))]
  | a :: as, b :: bs => by simp only [pointwise, length, Nat.max_succ_succ, @length_pointwise as bs]
#align list.func.length_pointwise List.Func.length_pointwise
-/

end Func

namespace Func

#print List.Func.get_add /-
-- add
@[simp]
theorem get_add {α : Type u} [AddMonoid α] {k : ℕ} {xs ys : List α} :
    @get α ⟨0⟩ k (add xs ys) = @get α ⟨0⟩ k xs + @get α ⟨0⟩ k ys := by apply get_pointwise;
  apply zero_add
#align list.func.get_add List.Func.get_add
-/

#print List.Func.length_add /-
@[simp]
theorem length_add {α : Type u} [Zero α] [Add α] {xs ys : List α} :
    (add xs ys).length = max xs.length ys.length :=
  @length_pointwise α α α ⟨0⟩ ⟨0⟩ _ _ _
#align list.func.length_add List.Func.length_add
-/

#print List.Func.nil_add /-
@[simp]
theorem nil_add {α : Type u} [AddMonoid α] (as : List α) : add [] as = as :=
  by
  rw [add, @nil_pointwise α α α ⟨0⟩ ⟨0⟩]
  apply Eq.trans _ (map_id as)
  congr with x
  rw [zero_add, id]
#align list.func.nil_add List.Func.nil_add
-/

#print List.Func.add_nil /-
@[simp]
theorem add_nil {α : Type u} [AddMonoid α] (as : List α) : add as [] = as :=
  by
  rw [add, @pointwise_nil α α α ⟨0⟩ ⟨0⟩]
  apply Eq.trans _ (map_id as)
  congr with x
  rw [add_zero, id]
#align list.func.add_nil List.Func.add_nil
-/

#print List.Func.map_add_map /-
theorem map_add_map {α : Type u} [AddMonoid α] (f g : α → α) {as : List α} :
    add (as.map f) (as.map g) = as.map fun x => f x + g x :=
  by
  apply @eq_of_equiv _ (⟨0⟩ : Inhabited α)
  · rw [length_map, length_add, max_eq_left, length_map]
    apply le_of_eq
    rw [length_map, length_map]
  intro m
  rw [get_add]
  by_cases h : m < length as
  · repeat' rw [@get_map α α ⟨0⟩ ⟨0⟩ _ _ _ h]
  rw [not_lt] at h 
  repeat' rw [get_eq_default_of_le m] <;> try rw [length_map]; apply h
  apply zero_add
#align list.func.map_add_map List.Func.map_add_map
-/

#print List.Func.get_sub /-
-- sub
@[simp]
theorem get_sub {α : Type u} [AddGroup α] {k : ℕ} {xs ys : List α} :
    @get α ⟨0⟩ k (sub xs ys) = @get α ⟨0⟩ k xs - @get α ⟨0⟩ k ys := by apply get_pointwise;
  apply sub_zero
#align list.func.get_sub List.Func.get_sub
-/

#print List.Func.length_sub /-
@[simp]
theorem length_sub [Zero α] [Sub α] {xs ys : List α} :
    (sub xs ys).length = max xs.length ys.length :=
  @length_pointwise α α α ⟨0⟩ ⟨0⟩ _ _ _
#align list.func.length_sub List.Func.length_sub
-/

#print List.Func.nil_sub /-
@[simp]
theorem nil_sub {α : Type _} [AddGroup α] (as : List α) : sub [] as = neg as :=
  by
  rw [sub, nil_pointwise]
  congr with x
  rw [zero_sub]
#align list.func.nil_sub List.Func.nil_sub
-/

#print List.Func.sub_nil /-
@[simp]
theorem sub_nil {α : Type _} [AddGroup α] (as : List α) : sub as [] = as :=
  by
  rw [sub, pointwise_nil]
  apply Eq.trans _ (map_id as)
  congr with x
  rw [sub_zero, id]
#align list.func.sub_nil List.Func.sub_nil
-/

end Func

end List

