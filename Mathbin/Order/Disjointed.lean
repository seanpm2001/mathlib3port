/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Yaël Dillies

! This file was ported from Lean 3 source module order.disjointed
! leanprover-community/mathlib commit 68d1483e8a718ec63219f0e227ca3f0140361086
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.PartialSups

/-!
# Consecutive differences of sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the way to make a sequence of elements into a sequence of disjoint elements with
the same partial sups.

For a sequence `f : ℕ → α`, this new sequence will be `f 0`, `f 1 \ f 0`, `f 2 \ (f 0 ⊔ f 1)`.
It is actually unique, as `disjointed_unique` shows.

## Main declarations

* `disjointed f`: The sequence `f 0`, `f 1 \ f 0`, `f 2 \ (f 0 ⊔ f 1)`, ....
* `partial_sups_disjointed`: `disjointed f` has the same partial sups as `f`.
* `disjoint_disjointed`: The elements of `disjointed f` are pairwise disjoint.
* `disjointed_unique`: `disjointed f` is the only pairwise disjoint sequence having the same partial
  sups as `f`.
* `supr_disjointed`: `disjointed f` has the same supremum as `f`. Limiting case of
  `partial_sups_disjointed`.

We also provide set notation variants of some lemmas.

## TODO

Find a useful statement of `disjointed_rec_succ`.

One could generalize `disjointed` to any locally finite bot preorder domain, in place of `ℕ`.
Related to the TODO in the module docstring of `order.partial_sups`.
-/


variable {α β : Type _}

section GeneralizedBooleanAlgebra

variable [GeneralizedBooleanAlgebra α]

#print disjointed /-
/-- If `f : ℕ → α` is a sequence of elements, then `disjointed f` is the sequence formed by
subtracting each element from the nexts. This is the unique disjoint sequence whose partial sups
are the same as the original sequence. -/
def disjointed (f : ℕ → α) : ℕ → α
  | 0 => f 0
  | n + 1 => f (n + 1) \ partialSups f n
#align disjointed disjointed
-/

#print disjointed_zero /-
@[simp]
theorem disjointed_zero (f : ℕ → α) : disjointed f 0 = f 0 :=
  rfl
#align disjointed_zero disjointed_zero
-/

#print disjointed_succ /-
theorem disjointed_succ (f : ℕ → α) (n : ℕ) : disjointed f (n + 1) = f (n + 1) \ partialSups f n :=
  rfl
#align disjointed_succ disjointed_succ
-/

#print disjointed_le_id /-
theorem disjointed_le_id : disjointed ≤ (id : (ℕ → α) → ℕ → α) :=
  by
  rintro f n
  cases n
  · rfl
  · exact sdiff_le
#align disjointed_le_id disjointed_le_id
-/

#print disjointed_le /-
theorem disjointed_le (f : ℕ → α) : disjointed f ≤ f :=
  disjointed_le_id f
#align disjointed_le disjointed_le
-/

#print disjoint_disjointed /-
theorem disjoint_disjointed (f : ℕ → α) : Pairwise (Disjoint on disjointed f) :=
  by
  refine' (Symmetric.pairwise_on Disjoint.symm _).2 fun m n h => _
  cases n
  · exact (Nat.not_lt_zero _ h).elim
  exact
    disjoint_sdiff_self_right.mono_left
      ((disjointed_le f m).trans (le_partialSups_of_le f (Nat.lt_add_one_iff.1 h)))
#align disjoint_disjointed disjoint_disjointed
-/

#print disjointedRec /-
/-- An induction principle for `disjointed`. To define/prove something on `disjointed f n`, it's
enough to define/prove it for `f n` and being able to extend through diffs. -/
def disjointedRec {f : ℕ → α} {p : α → Sort _} (hdiff : ∀ ⦃t i⦄, p t → p (t \ f i)) :
    ∀ ⦃n⦄, p (f n) → p (disjointed f n)
  | 0 => id
  | n + 1 => fun h => by
    suffices H : ∀ k, p (f (n + 1) \ partialSups f k)
    · exact H n
    rintro k
    induction' k with k ih
    · exact hdiff h
    rw [partialSups_succ, ← sdiff_sdiff_left]
    exact hdiff ih
#align disjointed_rec disjointedRec
-/

#print disjointedRec_zero /-
@[simp]
theorem disjointedRec_zero {f : ℕ → α} {p : α → Sort _} (hdiff : ∀ ⦃t i⦄, p t → p (t \ f i))
    (h₀ : p (f 0)) : disjointedRec hdiff h₀ = h₀ :=
  rfl
#align disjointed_rec_zero disjointedRec_zero
-/

#print Monotone.disjointed_eq /-
-- TODO: Find a useful statement of `disjointed_rec_succ`.
theorem Monotone.disjointed_eq {f : ℕ → α} (hf : Monotone f) (n : ℕ) :
    disjointed f (n + 1) = f (n + 1) \ f n := by rw [disjointed_succ, hf.partial_sups_eq]
#align monotone.disjointed_eq Monotone.disjointed_eq
-/

#print partialSups_disjointed /-
@[simp]
theorem partialSups_disjointed (f : ℕ → α) : partialSups (disjointed f) = partialSups f :=
  by
  ext n
  induction' n with k ih
  · rw [partialSups_zero, partialSups_zero, disjointed_zero]
  · rw [partialSups_succ, partialSups_succ, disjointed_succ, ih, sup_sdiff_self_right]
#align partial_sups_disjointed partialSups_disjointed
-/

#print disjointed_unique /-
/-- `disjointed f` is the unique sequence that is pairwise disjoint and has the same partial sups
as `f`. -/
theorem disjointed_unique {f d : ℕ → α} (hdisj : Pairwise (Disjoint on d))
    (hsups : partialSups d = partialSups f) : d = disjointed f :=
  by
  ext n
  cases n
  · rw [← partialSups_zero d, hsups, partialSups_zero, disjointed_zero]
  suffices h : d n.succ = partialSups d n.succ \ partialSups d n
  · rw [h, hsups, partialSups_succ, disjointed_succ, sup_sdiff, sdiff_self, bot_sup_eq]
  rw [partialSups_succ, sup_sdiff, sdiff_self, bot_sup_eq, eq_comm, sdiff_eq_self_iff_disjoint]
  suffices h : ∀ m ≤ n, Disjoint (partialSups d m) (d n.succ)
  · exact h n le_rfl
  rintro m hm
  induction' m with m ih
  · exact hdisj (Nat.succ_ne_zero _).symm
  rw [partialSups_succ, disjoint_iff, inf_sup_right, sup_eq_bot_iff, ← disjoint_iff, ← disjoint_iff]
  exact ⟨ih (Nat.le_of_succ_le hm), hdisj (Nat.lt_succ_of_le hm).Ne⟩
#align disjointed_unique disjointed_unique
-/

end GeneralizedBooleanAlgebra

section CompleteBooleanAlgebra

variable [CompleteBooleanAlgebra α]

#print iSup_disjointed /-
theorem iSup_disjointed (f : ℕ → α) : (⨆ n, disjointed f n) = ⨆ n, f n :=
  iSup_eq_iSup_of_partialSups_eq_partialSups (partialSups_disjointed f)
#align supr_disjointed iSup_disjointed
-/

#print disjointed_eq_inf_compl /-
theorem disjointed_eq_inf_compl (f : ℕ → α) (n : ℕ) : disjointed f n = f n ⊓ ⨅ i < n, f iᶜ :=
  by
  cases n
  · rw [disjointed_zero, eq_comm, inf_eq_left]
    simp_rw [le_iInf_iff]
    exact fun i hi => (i.not_lt_zero hi).elim
  simp_rw [disjointed_succ, partialSups_eq_biSup, sdiff_eq, compl_iSup]
  congr
  ext i
  rw [Nat.lt_succ_iff]
#align disjointed_eq_inf_compl disjointed_eq_inf_compl
-/

end CompleteBooleanAlgebra

/-! ### Set notation variants of lemmas -/


#print disjointed_subset /-
theorem disjointed_subset (f : ℕ → Set α) (n : ℕ) : disjointed f n ⊆ f n :=
  disjointed_le f n
#align disjointed_subset disjointed_subset
-/

#print iUnion_disjointed /-
theorem iUnion_disjointed {f : ℕ → Set α} : (⋃ n, disjointed f n) = ⋃ n, f n :=
  iSup_disjointed f
#align Union_disjointed iUnion_disjointed
-/

#print disjointed_eq_inter_compl /-
theorem disjointed_eq_inter_compl (f : ℕ → Set α) (n : ℕ) : disjointed f n = f n ∩ ⋂ i < n, f iᶜ :=
  disjointed_eq_inf_compl f n
#align disjointed_eq_inter_compl disjointed_eq_inter_compl
-/

#print preimage_find_eq_disjointed /-
theorem preimage_find_eq_disjointed (s : ℕ → Set α) (H : ∀ x, ∃ n, x ∈ s n)
    [∀ x n, Decidable (x ∈ s n)] (n : ℕ) : (fun x => Nat.find (H x)) ⁻¹' {n} = disjointed s n := by
  ext x; simp [Nat.find_eq_iff, disjointed_eq_inter_compl]
#align preimage_find_eq_disjointed preimage_find_eq_disjointed
-/

