/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Kenny Lau

! This file was ported from Lean 3 source module data.list.zip
! leanprover-community/mathlib commit be24ec5de6701447e5df5ca75400ffee19d65659
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.BigOperators.Basic
import Mathbin.Algebra.Order.Monoid.MinMax

/-!
# zip & unzip

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides results about `list.zip_with`, `list.zip` and `list.unzip` (definitions are in
core Lean).
`zip_with f l₁ l₂` applies `f : α → β → γ` pointwise to a list `l₁ : list α` and `l₂ : list β`. It
applies, until one of the lists is exhausted. For example,
`zip_with f [0, 1, 2] [6.28, 31] = [f 0 6.28, f 1 31]`.
`zip` is `zip_with` applied to `prod.mk`. For example,
`zip [a₁, a₂] [b₁, b₂, b₃] = [(a₁, b₁), (a₂, b₂)]`.
`unzip` undoes `zip`. For example, `unzip [(a₁, b₁), (a₂, b₂)] = ([a₁, a₂], [b₁, b₂])`.
-/


universe u

open Nat

namespace List

variable {α : Type u} {β γ δ ε : Type _}

#print List.zipWith_cons_cons /-
@[simp]
theorem zipWith_cons_cons (f : α → β → γ) (a : α) (b : β) (l₁ : List α) (l₂ : List β) :
    zipWith f (a :: l₁) (b :: l₂) = f a b :: zipWith f l₁ l₂ :=
  rfl
#align list.zip_with_cons_cons List.zipWith_cons_cons
-/

#print List.zip_cons_cons /-
@[simp]
theorem zip_cons_cons (a : α) (b : β) (l₁ : List α) (l₂ : List β) :
    zip (a :: l₁) (b :: l₂) = (a, b) :: zip l₁ l₂ :=
  rfl
#align list.zip_cons_cons List.zip_cons_cons
-/

#print List.zipWith_nil_left /-
@[simp]
theorem zipWith_nil_left (f : α → β → γ) (l) : zipWith f [] l = [] :=
  rfl
#align list.zip_with_nil_left List.zipWith_nil_left
-/

#print List.zipWith_nil_right /-
@[simp]
theorem zipWith_nil_right (f : α → β → γ) (l) : zipWith f l [] = [] := by cases l <;> rfl
#align list.zip_with_nil_right List.zipWith_nil_right
-/

#print List.zipWith_eq_nil_iff /-
@[simp]
theorem zipWith_eq_nil_iff {f : α → β → γ} {l l'} : zipWith f l l' = [] ↔ l = [] ∨ l' = [] := by
  cases l <;> cases l' <;> simp
#align list.zip_with_eq_nil_iff List.zipWith_eq_nil_iff
-/

#print List.zip_nil_left /-
@[simp]
theorem zip_nil_left (l : List α) : zip ([] : List β) l = [] :=
  rfl
#align list.zip_nil_left List.zip_nil_left
-/

#print List.zip_nil_right /-
@[simp]
theorem zip_nil_right (l : List α) : zip l ([] : List β) = [] :=
  zipWith_nil_right _ l
#align list.zip_nil_right List.zip_nil_right
-/

#print List.zip_swap /-
@[simp]
theorem zip_swap : ∀ (l₁ : List α) (l₂ : List β), (zip l₁ l₂).map Prod.swap = zip l₂ l₁
  | [], l₂ => (zip_nil_right _).symm
  | l₁, [] => by rw [zip_nil_right] <;> rfl
  | a :: l₁, b :: l₂ => by
    simp only [zip_cons_cons, map_cons, zip_swap l₁ l₂, Prod.swap_prod_mk] <;> constructor <;> rfl
#align list.zip_swap List.zip_swap
-/

/- warning: list.length_zip_with clashes with list.length_map₂ -> List.length_zipWith
Case conversion may be inaccurate. Consider using '#align list.length_zip_with List.length_zipWithₓ'. -/
#print List.length_zipWith /-
@[simp]
theorem length_zipWith (f : α → β → γ) :
    ∀ (l₁ : List α) (l₂ : List β), length (zipWith f l₁ l₂) = min (length l₁) (length l₂)
  | [], l₂ => rfl
  | l₁, [] => by simp only [length, min_zero, zip_with_nil_right]
  | a :: l₁, b :: l₂ => by simp [length, zip_cons_cons, length_zip_with l₁ l₂, min_add_add_right]
#align list.length_zip_with List.length_zipWith
-/

#print List.length_zip /-
@[simp]
theorem length_zip :
    ∀ (l₁ : List α) (l₂ : List β), length (zip l₁ l₂) = min (length l₁) (length l₂) :=
  length_zipWith _
#align list.length_zip List.length_zip
-/

#print List.all₂_zipWith /-
theorem all₂_zipWith {f : α → β → γ} {p : γ → Prop} :
    ∀ {l₁ : List α} {l₂ : List β} (h : length l₁ = length l₂),
      All₂ p (zipWith f l₁ l₂) ↔ Forall₂ (fun x y => p (f x y)) l₁ l₂
  | [], [], _ => by simp
  | a :: l₁, b :: l₂, h => by simp only [length_cons, add_left_inj] at h ; simp [all₂_zip_with h]
#align list.all₂_zip_with List.all₂_zipWith
-/

#print List.lt_length_left_of_zipWith /-
theorem lt_length_left_of_zipWith {f : α → β → γ} {i : ℕ} {l : List α} {l' : List β}
    (h : i < (zipWith f l l').length) : i < l.length := by rw [length_zip_with, lt_min_iff] at h ;
  exact h.left
#align list.lt_length_left_of_zip_with List.lt_length_left_of_zipWith
-/

#print List.lt_length_right_of_zipWith /-
theorem lt_length_right_of_zipWith {f : α → β → γ} {i : ℕ} {l : List α} {l' : List β}
    (h : i < (zipWith f l l').length) : i < l'.length := by rw [length_zip_with, lt_min_iff] at h ;
  exact h.right
#align list.lt_length_right_of_zip_with List.lt_length_right_of_zipWith
-/

#print List.lt_length_left_of_zip /-
theorem lt_length_left_of_zip {i : ℕ} {l : List α} {l' : List β} (h : i < (zip l l').length) :
    i < l.length :=
  lt_length_left_of_zipWith h
#align list.lt_length_left_of_zip List.lt_length_left_of_zip
-/

#print List.lt_length_right_of_zip /-
theorem lt_length_right_of_zip {i : ℕ} {l : List α} {l' : List β} (h : i < (zip l l').length) :
    i < l'.length :=
  lt_length_right_of_zipWith h
#align list.lt_length_right_of_zip List.lt_length_right_of_zip
-/

#print List.zip_append /-
theorem zip_append :
    ∀ {l₁ r₁ : List α} {l₂ r₂ : List β} (h : length l₁ = length l₂),
      zip (l₁ ++ r₁) (l₂ ++ r₂) = zip l₁ l₂ ++ zip r₁ r₂
  | [], r₁, l₂, r₂, h => by simp only [eq_nil_of_length_eq_zero h.symm] <;> rfl
  | l₁, r₁, [], r₂, h => by simp only [eq_nil_of_length_eq_zero h] <;> rfl
  | a :: l₁, r₁, b :: l₂, r₂, h => by
    simp only [cons_append, zip_cons_cons, zip_append (succ.inj h)] <;> constructor <;> rfl
#align list.zip_append List.zip_append
-/

#print List.zip_map /-
theorem zip_map (f : α → γ) (g : β → δ) :
    ∀ (l₁ : List α) (l₂ : List β), zip (l₁.map f) (l₂.map g) = (zip l₁ l₂).map (Prod.map f g)
  | [], l₂ => rfl
  | l₁, [] => by simp only [map, zip_nil_right]
  | a :: l₁, b :: l₂ => by
    simp only [map, zip_cons_cons, zip_map l₁ l₂, Prod.map] <;> constructor <;> rfl
#align list.zip_map List.zip_map
-/

#print List.zip_map_left /-
theorem zip_map_left (f : α → γ) (l₁ : List α) (l₂ : List β) :
    zip (l₁.map f) l₂ = (zip l₁ l₂).map (Prod.map f id) := by rw [← zip_map, map_id]
#align list.zip_map_left List.zip_map_left
-/

#print List.zip_map_right /-
theorem zip_map_right (f : β → γ) (l₁ : List α) (l₂ : List β) :
    zip l₁ (l₂.map f) = (zip l₁ l₂).map (Prod.map id f) := by rw [← zip_map, map_id]
#align list.zip_map_right List.zip_map_right
-/

#print List.zipWith_map /-
@[simp]
theorem zipWith_map {μ} (f : γ → δ → μ) (g : α → γ) (h : β → δ) (as : List α) (bs : List β) :
    zipWith f (as.map g) (bs.map h) = zipWith (fun a b => f (g a) (h b)) as bs :=
  by
  induction as generalizing bs
  · simp
  · cases bs <;> simp [*]
#align list.zip_with_map List.zipWith_map
-/

#print List.zipWith_map_left /-
theorem zipWith_map_left (f : α → β → γ) (g : δ → α) (l : List δ) (l' : List β) :
    zipWith f (l.map g) l' = zipWith (f ∘ g) l l' := by convert zip_with_map f g id l l';
  exact Eq.symm (List.map_id _)
#align list.zip_with_map_left List.zipWith_map_left
-/

#print List.zipWith_map_right /-
theorem zipWith_map_right (f : α → β → γ) (l : List α) (g : δ → β) (l' : List δ) :
    zipWith f l (l'.map g) = zipWith (fun x => f x ∘ g) l l' := by
  convert List.zipWith_map f id g l l'; exact Eq.symm (List.map_id _)
#align list.zip_with_map_right List.zipWith_map_right
-/

#print List.zip_map' /-
theorem zip_map' (f : α → β) (g : α → γ) :
    ∀ l : List α, zip (l.map f) (l.map g) = l.map fun a => (f a, g a)
  | [] => rfl
  | a :: l => by simp only [map, zip_cons_cons, zip_map' l] <;> constructor <;> rfl
#align list.zip_map' List.zip_map'
-/

#print List.map_zipWith /-
theorem map_zipWith {δ : Type _} (f : α → β) (g : γ → δ → α) (l : List γ) (l' : List δ) :
    map f (zipWith g l l') = zipWith (fun x y => f (g x y)) l l' :=
  by
  induction' l with hd tl hl generalizing l'
  · simp
  · cases l'
    · simp
    · simp [hl]
#align list.map_zip_with List.map_zipWith
-/

#print List.mem_zip /-
theorem mem_zip {a b} : ∀ {l₁ : List α} {l₂ : List β}, (a, b) ∈ zip l₁ l₂ → a ∈ l₁ ∧ b ∈ l₂
  | _ :: l₁, _ :: l₂, Or.inl rfl => ⟨Or.inl rfl, Or.inl rfl⟩
  | a' :: l₁, b' :: l₂, Or.inr h => by
    constructor <;> simp only [mem_cons_iff, or_true_iff, mem_zip h]
#align list.mem_zip List.mem_zip
-/

#print List.map_fst_zip /-
theorem map_fst_zip :
    ∀ (l₁ : List α) (l₂ : List β), l₁.length ≤ l₂.length → map Prod.fst (zip l₁ l₂) = l₁
  | [], bs, _ => rfl
  | a :: as, b :: bs, h => by simp at h ; simp! [*]
  | a :: as, [], h => by simp at h ; contradiction
#align list.map_fst_zip List.map_fst_zip
-/

#print List.map_snd_zip /-
theorem map_snd_zip :
    ∀ (l₁ : List α) (l₂ : List β), l₂.length ≤ l₁.length → map Prod.snd (zip l₁ l₂) = l₂
  | _, [], _ => by rw [zip_nil_right]; rfl
  | [], b :: bs, h => by simp at h ; contradiction
  | a :: as, b :: bs, h => by simp at h ; simp! [*]
#align list.map_snd_zip List.map_snd_zip
-/

#print List.unzip_nil /-
@[simp]
theorem unzip_nil : unzip (@nil (α × β)) = ([], []) :=
  rfl
#align list.unzip_nil List.unzip_nil
-/

#print List.unzip_cons /-
@[simp]
theorem unzip_cons (a : α) (b : β) (l : List (α × β)) :
    unzip ((a, b) :: l) = (a :: (unzip l).1, b :: (unzip l).2) := by
  rw [unzip] <;> cases unzip l <;> rfl
#align list.unzip_cons List.unzip_cons
-/

#print List.unzip_eq_map /-
theorem unzip_eq_map : ∀ l : List (α × β), unzip l = (l.map Prod.fst, l.map Prod.snd)
  | [] => rfl
  | (a, b) :: l => by simp only [unzip_cons, map_cons, unzip_eq_map l]
#align list.unzip_eq_map List.unzip_eq_map
-/

#print List.unzip_left /-
theorem unzip_left (l : List (α × β)) : (unzip l).1 = l.map Prod.fst := by simp only [unzip_eq_map]
#align list.unzip_left List.unzip_left
-/

#print List.unzip_right /-
theorem unzip_right (l : List (α × β)) : (unzip l).2 = l.map Prod.snd := by simp only [unzip_eq_map]
#align list.unzip_right List.unzip_right
-/

#print List.unzip_swap /-
theorem unzip_swap (l : List (α × β)) : unzip (l.map Prod.swap) = (unzip l).symm := by
  simp only [unzip_eq_map, map_map] <;> constructor <;> rfl
#align list.unzip_swap List.unzip_swap
-/

#print List.zip_unzip /-
theorem zip_unzip : ∀ l : List (α × β), zip (unzip l).1 (unzip l).2 = l
  | [] => rfl
  | (a, b) :: l => by simp only [unzip_cons, zip_cons_cons, zip_unzip l] <;> constructor <;> rfl
#align list.zip_unzip List.zip_unzip
-/

#print List.unzip_zip_left /-
theorem unzip_zip_left :
    ∀ {l₁ : List α} {l₂ : List β}, length l₁ ≤ length l₂ → (unzip (zip l₁ l₂)).1 = l₁
  | [], l₂, h => rfl
  | l₁, [], h => by rw [eq_nil_of_length_eq_zero (Nat.eq_zero_of_le_zero h)] <;> rfl
  | a :: l₁, b :: l₂, h => by
    simp only [zip_cons_cons, unzip_cons, unzip_zip_left (le_of_succ_le_succ h)] <;> constructor <;>
      rfl
#align list.unzip_zip_left List.unzip_zip_left
-/

#print List.unzip_zip_right /-
theorem unzip_zip_right {l₁ : List α} {l₂ : List β} (h : length l₂ ≤ length l₁) :
    (unzip (zip l₁ l₂)).2 = l₂ := by rw [← zip_swap, unzip_swap] <;> exact unzip_zip_left h
#align list.unzip_zip_right List.unzip_zip_right
-/

#print List.unzip_zip /-
theorem unzip_zip {l₁ : List α} {l₂ : List β} (h : length l₁ = length l₂) :
    unzip (zip l₁ l₂) = (l₁, l₂) := by
  rw [← @Prod.mk.eta _ _ (unzip (zip l₁ l₂)), unzip_zip_left (le_of_eq h),
    unzip_zip_right (ge_of_eq h)]
#align list.unzip_zip List.unzip_zip
-/

#print List.zip_of_prod /-
theorem zip_of_prod {l : List α} {l' : List β} {lp : List (α × β)} (hl : lp.map Prod.fst = l)
    (hr : lp.map Prod.snd = l') : lp = l.zip l' := by
  rw [← hl, ← hr, ← zip_unzip lp, ← unzip_left, ← unzip_right, zip_unzip, zip_unzip]
#align list.zip_of_prod List.zip_of_prod
-/

#print List.map_prod_left_eq_zip /-
theorem map_prod_left_eq_zip {l : List α} (f : α → β) :
    (l.map fun x => (x, f x)) = l.zip (l.map f) := by rw [← zip_map']; congr; exact map_id _
#align list.map_prod_left_eq_zip List.map_prod_left_eq_zip
-/

#print List.map_prod_right_eq_zip /-
theorem map_prod_right_eq_zip {l : List α} (f : α → β) :
    (l.map fun x => (f x, x)) = (l.map f).zip l := by rw [← zip_map']; congr; exact map_id _
#align list.map_prod_right_eq_zip List.map_prod_right_eq_zip
-/

#print List.zipWith_comm /-
theorem zipWith_comm (f : α → β → γ) :
    ∀ (la : List α) (lb : List β), zipWith f la lb = zipWith (fun b a => f a b) lb la
  | [], _ => (List.zipWith_nil_right _ _).symm
  | a :: as, [] => rfl
  | a :: as, b :: bs => congr_arg _ (zip_with_comm as bs)
#align list.zip_with_comm List.zipWith_comm
-/

#print List.zipWith_congr /-
@[congr]
theorem zipWith_congr (f g : α → β → γ) (la : List α) (lb : List β)
    (h : List.Forall₂ (fun a b => f a b = g a b) la lb) : zipWith f la lb = zipWith g la lb :=
  by
  induction' h with a b as bs hfg habs ih
  · rfl
  · exact congr_arg₂ _ hfg ih
#align list.zip_with_congr List.zipWith_congr
-/

#print List.zipWith_comm_of_comm /-
theorem zipWith_comm_of_comm (f : α → α → β) (comm : ∀ x y : α, f x y = f y x) (l l' : List α) :
    zipWith f l l' = zipWith f l' l := by rw [zip_with_comm]; simp only [comm]
#align list.zip_with_comm_of_comm List.zipWith_comm_of_comm
-/

#print List.zipWith_same /-
@[simp]
theorem zipWith_same (f : α → α → δ) : ∀ l : List α, zipWith f l l = l.map fun a => f a a
  | [] => rfl
  | x :: xs => congr_arg _ (zip_with_same xs)
#align list.zip_with_same List.zipWith_same
-/

#print List.zipWith_zipWith_left /-
theorem zipWith_zipWith_left (f : δ → γ → ε) (g : α → β → δ) :
    ∀ (la : List α) (lb : List β) (lc : List γ),
      zipWith f (zipWith g la lb) lc = zipWith3 (fun a b c => f (g a b) c) la lb lc
  | [], _, _ => rfl
  | a :: as, [], _ => rfl
  | a :: as, b :: bs, [] => rfl
  | a :: as, b :: bs, c :: cs => congr_arg (cons _) <| zip_with_zip_with_left as bs cs
#align list.zip_with_zip_with_left List.zipWith_zipWith_left
-/

#print List.zipWith_zipWith_right /-
theorem zipWith_zipWith_right (f : α → δ → ε) (g : β → γ → δ) :
    ∀ (la : List α) (lb : List β) (lc : List γ),
      zipWith f la (zipWith g lb lc) = zipWith3 (fun a b c => f a (g b c)) la lb lc
  | [], _, _ => rfl
  | a :: as, [], _ => rfl
  | a :: as, b :: bs, [] => rfl
  | a :: as, b :: bs, c :: cs => congr_arg (cons _) <| zip_with_zip_with_right as bs cs
#align list.zip_with_zip_with_right List.zipWith_zipWith_right
-/

#print List.zipWith3_same_left /-
@[simp]
theorem zipWith3_same_left (f : α → α → β → γ) :
    ∀ (la : List α) (lb : List β), zipWith3 f la la lb = zipWith (fun a b => f a a b) la lb
  | [], _ => rfl
  | a :: as, [] => rfl
  | a :: as, b :: bs => congr_arg (cons _) <| zip_with3_same_left as bs
#align list.zip_with3_same_left List.zipWith3_same_left
-/

#print List.zipWith3_same_mid /-
@[simp]
theorem zipWith3_same_mid (f : α → β → α → γ) :
    ∀ (la : List α) (lb : List β), zipWith3 f la lb la = zipWith (fun a b => f a b a) la lb
  | [], _ => rfl
  | a :: as, [] => rfl
  | a :: as, b :: bs => congr_arg (cons _) <| zip_with3_same_mid as bs
#align list.zip_with3_same_mid List.zipWith3_same_mid
-/

#print List.zipWith3_same_right /-
@[simp]
theorem zipWith3_same_right (f : α → β → β → γ) :
    ∀ (la : List α) (lb : List β), zipWith3 f la lb lb = zipWith (fun a b => f a b b) la lb
  | [], _ => rfl
  | a :: as, [] => rfl
  | a :: as, b :: bs => congr_arg (cons _) <| zip_with3_same_right as bs
#align list.zip_with3_same_right List.zipWith3_same_right
-/

instance (f : α → α → β) [IsSymmOp α β f] : IsSymmOp (List α) (List β) (zipWith f) :=
  ⟨zipWith_comm_of_comm f IsSymmOp.symm_op⟩

#print List.length_revzip /-
@[simp]
theorem length_revzip (l : List α) : length (revzip l) = length l := by
  simp only [revzip, length_zip, length_reverse, min_self]
#align list.length_revzip List.length_revzip
-/

#print List.unzip_revzip /-
@[simp]
theorem unzip_revzip (l : List α) : (revzip l).unzip = (l, l.reverse) :=
  unzip_zip (length_reverse l).symm
#align list.unzip_revzip List.unzip_revzip
-/

#print List.revzip_map_fst /-
@[simp]
theorem revzip_map_fst (l : List α) : (revzip l).map Prod.fst = l := by
  rw [← unzip_left, unzip_revzip]
#align list.revzip_map_fst List.revzip_map_fst
-/

#print List.revzip_map_snd /-
@[simp]
theorem revzip_map_snd (l : List α) : (revzip l).map Prod.snd = l.reverse := by
  rw [← unzip_right, unzip_revzip]
#align list.revzip_map_snd List.revzip_map_snd
-/

#print List.reverse_revzip /-
theorem reverse_revzip (l : List α) : reverse l.revzip = revzip l.reverse := by
  rw [← zip_unzip.{u, u} (revzip l).reverse, unzip_eq_map] <;> simp <;> simp [revzip]
#align list.reverse_revzip List.reverse_revzip
-/

#print List.revzip_swap /-
theorem revzip_swap (l : List α) : (revzip l).map Prod.swap = revzip l.reverse := by simp [revzip]
#align list.revzip_swap List.revzip_swap
-/

#print List.get?_zip_with /-
theorem get?_zip_with (f : α → β → γ) (l₁ : List α) (l₂ : List β) (i : ℕ) :
    (zipWith f l₁ l₂).get? i = ((l₁.get? i).map f).bind fun g => (l₂.get? i).map g :=
  by
  induction l₁ generalizing l₂ i
  · simp [zip_with, (· <*> ·)]
  · cases l₂ <;> simp only [zip_with, Seq.seq, Functor.map, nth, Option.map_none']
    · cases (l₁_hd :: l₁_tl).get? i <;> rfl
    · cases i <;> simp only [Option.map_some', nth, Option.some_bind', *]
#align list.nth_zip_with List.get?_zip_with
-/

#print List.get?_zip_with_eq_some /-
theorem get?_zip_with_eq_some {α β γ} (f : α → β → γ) (l₁ : List α) (l₂ : List β) (z : γ) (i : ℕ) :
    (zipWith f l₁ l₂).get? i = some z ↔
      ∃ x y, l₁.get? i = some x ∧ l₂.get? i = some y ∧ f x y = z :=
  by
  induction l₁ generalizing l₂ i
  · simp [zip_with]
  · cases l₂ <;> simp only [zip_with, nth, exists_false, and_false_iff, false_and_iff]
    cases i <;> simp [*]
#align list.nth_zip_with_eq_some List.get?_zip_with_eq_some
-/

#print List.get?_zip_eq_some /-
theorem get?_zip_eq_some (l₁ : List α) (l₂ : List β) (z : α × β) (i : ℕ) :
    (zip l₁ l₂).get? i = some z ↔ l₁.get? i = some z.1 ∧ l₂.get? i = some z.2 :=
  by
  cases z
  rw [zip, nth_zip_with_eq_some]; constructor
  · rintro ⟨x, y, h₀, h₁, h₂⟩; cc
  · rintro ⟨h₀, h₁⟩; exact ⟨_, _, h₀, h₁, rfl⟩
#align list.nth_zip_eq_some List.get?_zip_eq_some
-/

#print List.nthLe_zipWith /-
@[simp]
theorem nthLe_zipWith {f : α → β → γ} {l : List α} {l' : List β} {i : ℕ}
    {h : i < (zipWith f l l').length} :
    (zipWith f l l').nthLe i h =
      f (l.nthLe i (lt_length_left_of_zipWith h)) (l'.nthLe i (lt_length_right_of_zipWith h)) :=
  by
  rw [← Option.some_inj, ← nth_le_nth, nth_zip_with_eq_some]
  refine'
    ⟨l.nth_le i (lt_length_left_of_zip_with h), l'.nth_le i (lt_length_right_of_zip_with h),
      nth_le_nth _, _⟩
  simp only [← nth_le_nth, eq_self_iff_true, and_self_iff]
#align list.nth_le_zip_with List.nthLe_zipWith
-/

#print List.nthLe_zip /-
@[simp]
theorem nthLe_zip {l : List α} {l' : List β} {i : ℕ} {h : i < (zip l l').length} :
    (zip l l').nthLe i h =
      (l.nthLe i (lt_length_left_of_zip h), l'.nthLe i (lt_length_right_of_zip h)) :=
  nthLe_zipWith
#align list.nth_le_zip List.nthLe_zip
-/

#print List.mem_zip_inits_tails /-
theorem mem_zip_inits_tails {l : List α} {init tail : List α} :
    (init, tail) ∈ zip l.inits l.tails ↔ init ++ tail = l :=
  by
  induction l generalizing init tail <;> simp_rw [tails, inits, zip_cons_cons]
  · simp
  · constructor <;> rw [mem_cons_iff, zip_map_left, mem_map, Prod.exists]
    · rintro (⟨rfl, rfl⟩ | ⟨_, _, h, rfl, rfl⟩)
      · simp
      · simp [l_ih.mp h]
    · cases init
      · simp
      · intro h
        right
        use init_tl, tail
        simp_all
#align list.mem_zip_inits_tails List.mem_zip_inits_tails
-/

#print List.map_uncurry_zip_eq_zipWith /-
theorem map_uncurry_zip_eq_zipWith (f : α → β → γ) (l : List α) (l' : List β) :
    map (Function.uncurry f) (l.zip l') = zipWith f l l' :=
  by
  induction' l with hd tl hl generalizing l'
  · simp
  · cases' l' with hd' tl'
    · simp
    · simp [hl]
#align list.map_uncurry_zip_eq_zip_with List.map_uncurry_zip_eq_zipWith
-/

#print List.sum_zipWith_distrib_left /-
@[simp]
theorem sum_zipWith_distrib_left {γ : Type _} [Semiring γ] (f : α → β → γ) (n : γ) (l : List α)
    (l' : List β) : (l.zipWith (fun x y => n * f x y) l').Sum = n * (l.zipWith f l').Sum :=
  by
  induction' l with hd tl hl generalizing f n l'
  · simp
  · cases' l' with hd' tl'
    · simp
    · simp [hl, mul_add]
#align list.sum_zip_with_distrib_left List.sum_zipWith_distrib_left
-/

section Distrib

/-! ### Operations that can be applied before or after a `zip_with` -/


variable (f : α → β → γ) (l : List α) (l' : List β) (n : ℕ)

#print List.zipWith_distrib_take /-
theorem zipWith_distrib_take : (zipWith f l l').take n = zipWith f (l.take n) (l'.take n) :=
  by
  induction' l with hd tl hl generalizing l' n
  · simp
  · cases l'
    · simp
    · cases n
      · simp
      · simp [hl]
#align list.zip_with_distrib_take List.zipWith_distrib_take
-/

#print List.zipWith_distrib_drop /-
theorem zipWith_distrib_drop : (zipWith f l l').drop n = zipWith f (l.drop n) (l'.drop n) :=
  by
  induction' l with hd tl hl generalizing l' n
  · simp
  · cases l'
    · simp
    · cases n
      · simp
      · simp [hl]
#align list.zip_with_distrib_drop List.zipWith_distrib_drop
-/

#print List.zipWith_distrib_tail /-
theorem zipWith_distrib_tail : (zipWith f l l').tail = zipWith f l.tail l'.tail := by
  simp_rw [← drop_one, zip_with_distrib_drop]
#align list.zip_with_distrib_tail List.zipWith_distrib_tail
-/

#print List.zipWith_append /-
theorem zipWith_append (f : α → β → γ) (l la : List α) (l' lb : List β) (h : l.length = l'.length) :
    zipWith f (l ++ la) (l' ++ lb) = zipWith f l l' ++ zipWith f la lb :=
  by
  induction' l with hd tl hl generalizing l'
  · have : l' = [] := eq_nil_of_length_eq_zero (by simpa using h.symm)
    simp [this]
  · cases l'
    · simpa using h
    · simp only [add_left_inj, length] at h 
      simp [hl _ h]
#align list.zip_with_append List.zipWith_append
-/

#print List.zipWith_distrib_reverse /-
theorem zipWith_distrib_reverse (h : l.length = l'.length) :
    (zipWith f l l').reverse = zipWith f l.reverse l'.reverse :=
  by
  induction' l with hd tl hl generalizing l'
  · simp
  · cases' l' with hd' tl'
    · simp
    · simp only [add_left_inj, length] at h 
      have : tl.reverse.length = tl'.reverse.length := by simp [h]
      simp [hl _ h, zip_with_append _ _ _ _ _ this]
#align list.zip_with_distrib_reverse List.zipWith_distrib_reverse
-/

end Distrib

section CommMonoid

variable [CommMonoid α]

#print List.prod_mul_prod_eq_prod_zipWith_mul_prod_drop /-
@[to_additive]
theorem prod_mul_prod_eq_prod_zipWith_mul_prod_drop :
    ∀ L L' : List α,
      L.Prod * L'.Prod =
        (zipWith (· * ·) L L').Prod * (L.drop L'.length).Prod * (L'.drop L.length).Prod
  | [], ys => by simp [Nat.zero_le]
  | xs, [] => by simp [Nat.zero_le]
  | x :: xs, y :: ys =>
    by
    simp only [drop, length, zip_with_cons_cons, prod_cons]
    rw [mul_assoc x, mul_comm xs.prod, mul_assoc y, mul_comm ys.prod,
      prod_mul_prod_eq_prod_zip_with_mul_prod_drop xs ys, mul_assoc, mul_assoc, mul_assoc,
      mul_assoc]
#align list.prod_mul_prod_eq_prod_zip_with_mul_prod_drop List.prod_mul_prod_eq_prod_zipWith_mul_prod_drop
#align list.sum_add_sum_eq_sum_zip_with_add_sum_drop List.sum_add_sum_eq_sum_zipWith_add_sum_drop
-/

#print List.prod_mul_prod_eq_prod_zipWith_of_length_eq /-
@[to_additive]
theorem prod_mul_prod_eq_prod_zipWith_of_length_eq (L L' : List α) (h : L.length = L'.length) :
    L.Prod * L'.Prod = (zipWith (· * ·) L L').Prod :=
  (prod_mul_prod_eq_prod_zipWith_mul_prod_drop L L').trans (by simp [h])
#align list.prod_mul_prod_eq_prod_zip_with_of_length_eq List.prod_mul_prod_eq_prod_zipWith_of_length_eq
#align list.sum_add_sum_eq_sum_zip_with_of_length_eq List.sum_add_sum_eq_sum_zipWith_of_length_eq
-/

end CommMonoid

end List

