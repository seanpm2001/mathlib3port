/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Aaron Anderson

! This file was ported from Lean 3 source module data.finsupp.order
! leanprover-community/mathlib commit fac369018417f980cec5fcdafc766a69f88d8cfe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finsupp.Defs

/-!
# Pointwise order on finitely supported functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file lifts order structures on `α` to `ι →₀ α`.

## Main declarations

* `finsupp.order_embedding_to_fun`: The order embedding from finitely supported functions to
  functions.
* `finsupp.order_iso_multiset`: The order isomorphism between `ℕ`-valued finitely supported
  functions and multisets.
-/


noncomputable section

open scoped BigOperators

open Finset

variable {ι α : Type _}

namespace Finsupp

/-! ### Order structures -/


section Zero

variable [Zero α]

section LE

variable [LE α]

instance : LE (ι →₀ α) :=
  ⟨fun f g => ∀ i, f i ≤ g i⟩

#print Finsupp.le_def /-
theorem le_def {f g : ι →₀ α} : f ≤ g ↔ ∀ i, f i ≤ g i :=
  Iff.rfl
#align finsupp.le_def Finsupp.le_def
-/

#print Finsupp.orderEmbeddingToFun /-
/-- The order on `finsupp`s over a partial order embeds into the order on functions -/
def orderEmbeddingToFun : (ι →₀ α) ↪o (ι → α)
    where
  toFun f := f
  inj' f g h := Finsupp.ext fun i => by dsimp at h ; rw [h]
  map_rel_iff' a b := (@le_def _ _ _ _ a b).symm
#align finsupp.order_embedding_to_fun Finsupp.orderEmbeddingToFun
-/

#print Finsupp.orderEmbeddingToFun_apply /-
@[simp]
theorem orderEmbeddingToFun_apply {f : ι →₀ α} {i : ι} : orderEmbeddingToFun f i = f i :=
  rfl
#align finsupp.order_embedding_to_fun_apply Finsupp.orderEmbeddingToFun_apply
-/

end LE

section Preorder

variable [Preorder α]

instance : Preorder (ι →₀ α) :=
  { Finsupp.hasLe with
    le_refl := fun f i => le_rfl
    le_trans := fun f g h hfg hgh i => (hfg i).trans (hgh i) }

#print Finsupp.monotone_toFun /-
theorem monotone_toFun : Monotone (Finsupp.toFun : (ι →₀ α) → ι → α) := fun f g h a => le_def.1 h a
#align finsupp.monotone_to_fun Finsupp.monotone_toFun
-/

end Preorder

instance [PartialOrder α] : PartialOrder (ι →₀ α) :=
  { Finsupp.preorder with le_antisymm := fun f g hfg hgf => ext fun i => (hfg i).antisymm (hgf i) }

instance [SemilatticeInf α] : SemilatticeInf (ι →₀ α) :=
  { Finsupp.partialOrder with
    inf := zipWith (· ⊓ ·) inf_idem
    inf_le_left := fun f g i => inf_le_left
    inf_le_right := fun f g i => inf_le_right
    le_inf := fun f g i h1 h2 s => le_inf (h1 s) (h2 s) }

#print Finsupp.inf_apply /-
@[simp]
theorem inf_apply [SemilatticeInf α] {i : ι} {f g : ι →₀ α} : (f ⊓ g) i = f i ⊓ g i :=
  rfl
#align finsupp.inf_apply Finsupp.inf_apply
-/

instance [SemilatticeSup α] : SemilatticeSup (ι →₀ α) :=
  { Finsupp.partialOrder with
    sup := zipWith (· ⊔ ·) sup_idem
    le_sup_left := fun f g i => le_sup_left
    le_sup_right := fun f g i => le_sup_right
    sup_le := fun f g h hf hg i => sup_le (hf i) (hg i) }

#print Finsupp.sup_apply /-
@[simp]
theorem sup_apply [SemilatticeSup α] {i : ι} {f g : ι →₀ α} : (f ⊔ g) i = f i ⊔ g i :=
  rfl
#align finsupp.sup_apply Finsupp.sup_apply
-/

#print Finsupp.lattice /-
instance lattice [Lattice α] : Lattice (ι →₀ α) :=
  { Finsupp.semilatticeInf, Finsupp.semilatticeSup with }
#align finsupp.lattice Finsupp.lattice
-/

end Zero

/-! ### Algebraic order structures -/


instance [OrderedAddCommMonoid α] : OrderedAddCommMonoid (ι →₀ α) :=
  { Finsupp.addCommMonoid, Finsupp.partialOrder with
    add_le_add_left := fun a b h c s => add_le_add_left (h s) (c s) }

instance [OrderedCancelAddCommMonoid α] : OrderedCancelAddCommMonoid (ι →₀ α) :=
  { Finsupp.orderedAddCommMonoid with
    le_of_add_le_add_left := fun f g i h s => le_of_add_le_add_left (h s) }

instance [OrderedAddCommMonoid α] [ContravariantClass α α (· + ·) (· ≤ ·)] :
    ContravariantClass (ι →₀ α) (ι →₀ α) (· + ·) (· ≤ ·) :=
  ⟨fun f g h H x => le_of_add_le_add_left <| H x⟩

section CanonicallyOrderedAddMonoid

variable [CanonicallyOrderedAddMonoid α]

instance : OrderBot (ι →₀ α) where
  bot := 0
  bot_le := by simp only [le_def, coe_zero, Pi.zero_apply, imp_true_iff, zero_le]

#print Finsupp.bot_eq_zero /-
protected theorem bot_eq_zero : (⊥ : ι →₀ α) = 0 :=
  rfl
#align finsupp.bot_eq_zero Finsupp.bot_eq_zero
-/

#print Finsupp.add_eq_zero_iff /-
@[simp]
theorem add_eq_zero_iff (f g : ι →₀ α) : f + g = 0 ↔ f = 0 ∧ g = 0 := by simp [ext_iff, forall_and]
#align finsupp.add_eq_zero_iff Finsupp.add_eq_zero_iff
-/

#print Finsupp.le_iff' /-
theorem le_iff' (f g : ι →₀ α) {s : Finset ι} (hf : f.support ⊆ s) : f ≤ g ↔ ∀ i ∈ s, f i ≤ g i :=
  ⟨fun h s hs => h s, fun h s => by
    classical exact
      if H : s ∈ f.support then h s (hf H) else (not_mem_support_iff.1 H).symm ▸ zero_le (g s)⟩
#align finsupp.le_iff' Finsupp.le_iff'
-/

#print Finsupp.le_iff /-
theorem le_iff (f g : ι →₀ α) : f ≤ g ↔ ∀ i ∈ f.support, f i ≤ g i :=
  le_iff' f g <| Subset.refl _
#align finsupp.le_iff Finsupp.le_iff
-/

#print Finsupp.decidableLE /-
instance decidableLE [DecidableRel (@LE.le α _)] : DecidableRel (@LE.le (ι →₀ α) _) := fun f g =>
  decidable_of_iff _ (le_iff f g).symm
#align finsupp.decidable_le Finsupp.decidableLE
-/

#print Finsupp.single_le_iff /-
@[simp]
theorem single_le_iff {i : ι} {x : α} {f : ι →₀ α} : single i x ≤ f ↔ x ≤ f i :=
  (le_iff' _ _ support_single_subset).trans <| by simp
#align finsupp.single_le_iff Finsupp.single_le_iff
-/

variable [Sub α] [OrderedSub α] {f g : ι →₀ α} {i : ι} {a b : α}

#print Finsupp.tsub /-
/-- This is called `tsub` for truncated subtraction, to distinguish it with subtraction in an
additive group. -/
instance tsub : Sub (ι →₀ α) :=
  ⟨zipWith (fun m n => m - n) (tsub_self 0)⟩
#align finsupp.tsub Finsupp.tsub
-/

instance : OrderedSub (ι →₀ α) :=
  ⟨fun n m k => forall_congr' fun x => tsub_le_iff_right⟩

instance : CanonicallyOrderedAddMonoid (ι →₀ α) :=
  { Finsupp.orderBot,
    Finsupp.orderedAddCommMonoid with
    exists_add_of_le := fun f g h => ⟨g - f, ext fun x => (add_tsub_cancel_of_le <| h x).symm⟩
    le_self_add := fun f g x => le_self_add }

#print Finsupp.coe_tsub /-
@[simp]
theorem coe_tsub (f g : ι →₀ α) : ⇑(f - g) = f - g :=
  rfl
#align finsupp.coe_tsub Finsupp.coe_tsub
-/

#print Finsupp.tsub_apply /-
theorem tsub_apply (f g : ι →₀ α) (a : ι) : (f - g) a = f a - g a :=
  rfl
#align finsupp.tsub_apply Finsupp.tsub_apply
-/

#print Finsupp.single_tsub /-
@[simp]
theorem single_tsub : single i (a - b) = single i a - single i b :=
  by
  ext j
  obtain rfl | h := eq_or_ne i j
  · rw [tsub_apply, single_eq_same, single_eq_same, single_eq_same]
  · rw [tsub_apply, single_eq_of_ne h, single_eq_of_ne h, single_eq_of_ne h, tsub_self]
#align finsupp.single_tsub Finsupp.single_tsub
-/

#print Finsupp.support_tsub /-
theorem support_tsub {f1 f2 : ι →₀ α} : (f1 - f2).support ⊆ f1.support := by
  simp (config := { contextual := true }) only [subset_iff, tsub_eq_zero_iff_le, mem_support_iff,
    Ne.def, coe_tsub, Pi.sub_apply, not_imp_not, zero_le, imp_true_iff]
#align finsupp.support_tsub Finsupp.support_tsub
-/

#print Finsupp.subset_support_tsub /-
theorem subset_support_tsub [DecidableEq ι] {f1 f2 : ι →₀ α} :
    f1.support \ f2.support ⊆ (f1 - f2).support := by
  simp (config := { contextual := true }) [subset_iff]
#align finsupp.subset_support_tsub Finsupp.subset_support_tsub
-/

end CanonicallyOrderedAddMonoid

section CanonicallyLinearOrderedAddMonoid

variable [CanonicallyLinearOrderedAddMonoid α]

#print Finsupp.support_inf /-
@[simp]
theorem support_inf [DecidableEq ι] (f g : ι →₀ α) : (f ⊓ g).support = f.support ∩ g.support :=
  by
  ext
  simp only [inf_apply, mem_support_iff, Ne.def, Finset.mem_union, Finset.mem_filter,
    Finset.mem_inter]
  simp only [inf_eq_min, ← nonpos_iff_eq_zero, min_le_iff, not_or]
#align finsupp.support_inf Finsupp.support_inf
-/

#print Finsupp.support_sup /-
@[simp]
theorem support_sup [DecidableEq ι] (f g : ι →₀ α) : (f ⊔ g).support = f.support ∪ g.support :=
  by
  ext
  simp only [Finset.mem_union, mem_support_iff, sup_apply, Ne.def, ← bot_eq_zero]
  rw [_root_.sup_eq_bot_iff, not_and_or]
#align finsupp.support_sup Finsupp.support_sup
-/

#print Finsupp.disjoint_iff /-
theorem disjoint_iff {f g : ι →₀ α} : Disjoint f g ↔ Disjoint f.support g.support := by
  classical
  rw [disjoint_iff, disjoint_iff, Finsupp.bot_eq_zero, ← Finsupp.support_eq_empty,
    Finsupp.support_inf]
  rfl
#align finsupp.disjoint_iff Finsupp.disjoint_iff
-/

end CanonicallyLinearOrderedAddMonoid

/-! ### Some lemmas about `ℕ` -/


section Nat

#print Finsupp.sub_single_one_add /-
theorem sub_single_one_add {a : ι} {u u' : ι →₀ ℕ} (h : u a ≠ 0) :
    u - single a 1 + u' = u + u' - single a 1 :=
  tsub_add_eq_add_tsub <| single_le_iff.mpr <| Nat.one_le_iff_ne_zero.mpr h
#align finsupp.sub_single_one_add Finsupp.sub_single_one_add
-/

#print Finsupp.add_sub_single_one /-
theorem add_sub_single_one {a : ι} {u u' : ι →₀ ℕ} (h : u' a ≠ 0) :
    u + (u' - single a 1) = u + u' - single a 1 :=
  (add_tsub_assoc_of_le (single_le_iff.mpr <| Nat.one_le_iff_ne_zero.mpr h) _).symm
#align finsupp.add_sub_single_one Finsupp.add_sub_single_one
-/

end Nat

end Finsupp

