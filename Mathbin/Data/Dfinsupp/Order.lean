/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module data.dfinsupp.order
! leanprover-community/mathlib commit 50832daea47b195a48b5b33b1c8b2162c48c3afc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Dfinsupp.Basic

/-!
# Pointwise order on finitely supported dependent functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file lifts order structures on the `α i` to `Π₀ i, α i`.

## Main declarations

* `dfinsupp.order_embedding_to_fun`: The order embedding from finitely supported dependent functions
  to functions.

-/


open scoped BigOperators

open Finset

variable {ι : Type _} {α : ι → Type _}

namespace Dfinsupp

/-! ### Order structures -/


section Zero

variable (α) [∀ i, Zero (α i)]

section LE

variable [∀ i, LE (α i)]

instance : LE (Π₀ i, α i) :=
  ⟨fun f g => ∀ i, f i ≤ g i⟩

variable {α}

#print Dfinsupp.le_def /-
theorem le_def {f g : Π₀ i, α i} : f ≤ g ↔ ∀ i, f i ≤ g i :=
  Iff.rfl
#align dfinsupp.le_def Dfinsupp.le_def
-/

#print Dfinsupp.orderEmbeddingToFun /-
/-- The order on `dfinsupp`s over a partial order embeds into the order on functions -/
def orderEmbeddingToFun : (Π₀ i, α i) ↪o ∀ i, α i
    where
  toFun := coeFn
  inj' := coeFn_injective
  map_rel_iff' a b := (@le_def _ _ _ _ a b).symm
#align dfinsupp.order_embedding_to_fun Dfinsupp.orderEmbeddingToFun
-/

#print Dfinsupp.orderEmbeddingToFun_apply /-
@[simp]
theorem orderEmbeddingToFun_apply {f : Π₀ i, α i} {i : ι} : orderEmbeddingToFun f i = f i :=
  rfl
#align dfinsupp.order_embedding_to_fun_apply Dfinsupp.orderEmbeddingToFun_apply
-/

end LE

section Preorder

variable [∀ i, Preorder (α i)]

instance : Preorder (Π₀ i, α i) :=
  { Dfinsupp.hasLe α with
    le_refl := fun f i => le_rfl
    le_trans := fun f g h hfg hgh i => (hfg i).trans (hgh i) }

#print Dfinsupp.coeFn_mono /-
theorem coeFn_mono : Monotone (coeFn : (Π₀ i, α i) → ∀ i, α i) := fun f g => le_def.1
#align dfinsupp.coe_fn_mono Dfinsupp.coeFn_mono
-/

end Preorder

instance [∀ i, PartialOrder (α i)] : PartialOrder (Π₀ i, α i) :=
  { Dfinsupp.preorder α with
    le_antisymm := fun f g hfg hgf => ext fun i => (hfg i).antisymm (hgf i) }

instance [∀ i, SemilatticeInf (α i)] : SemilatticeInf (Π₀ i, α i) :=
  {
    Dfinsupp.partialOrder
      α with
    inf := zipWith (fun _ => (· ⊓ ·)) fun _ => inf_idem
    inf_le_left := fun f g i => by rw [zip_with_apply]; exact inf_le_left
    inf_le_right := fun f g i => by rw [zip_with_apply]; exact inf_le_right
    le_inf := fun f g h hf hg i => by rw [zip_with_apply]; exact le_inf (hf i) (hg i) }

#print Dfinsupp.inf_apply /-
@[simp]
theorem inf_apply [∀ i, SemilatticeInf (α i)] (f g : Π₀ i, α i) (i : ι) : (f ⊓ g) i = f i ⊓ g i :=
  zipWith_apply _ _ _ _ _
#align dfinsupp.inf_apply Dfinsupp.inf_apply
-/

instance [∀ i, SemilatticeSup (α i)] : SemilatticeSup (Π₀ i, α i) :=
  {
    Dfinsupp.partialOrder
      α with
    sup := zipWith (fun _ => (· ⊔ ·)) fun _ => sup_idem
    le_sup_left := fun f g i => by rw [zip_with_apply]; exact le_sup_left
    le_sup_right := fun f g i => by rw [zip_with_apply]; exact le_sup_right
    sup_le := fun f g h hf hg i => by rw [zip_with_apply]; exact sup_le (hf i) (hg i) }

#print Dfinsupp.sup_apply /-
@[simp]
theorem sup_apply [∀ i, SemilatticeSup (α i)] (f g : Π₀ i, α i) (i : ι) : (f ⊔ g) i = f i ⊔ g i :=
  zipWith_apply _ _ _ _ _
#align dfinsupp.sup_apply Dfinsupp.sup_apply
-/

#print Dfinsupp.lattice /-
instance lattice [∀ i, Lattice (α i)] : Lattice (Π₀ i, α i) :=
  { Dfinsupp.semilatticeInf α, Dfinsupp.semilatticeSup α with }
#align dfinsupp.lattice Dfinsupp.lattice
-/

end Zero

/-! ### Algebraic order structures -/


instance (α : ι → Type _) [∀ i, OrderedAddCommMonoid (α i)] : OrderedAddCommMonoid (Π₀ i, α i) :=
  { Dfinsupp.addCommMonoid, Dfinsupp.partialOrder α with
    add_le_add_left := fun a b h c i => by rw [add_apply, add_apply];
      exact add_le_add_left (h i) (c i) }

instance (α : ι → Type _) [∀ i, OrderedCancelAddCommMonoid (α i)] :
    OrderedCancelAddCommMonoid (Π₀ i, α i) :=
  { Dfinsupp.orderedAddCommMonoid α with
    le_of_add_le_add_left := fun f g h H i =>
      by
      specialize H i
      rw [add_apply, add_apply] at H 
      exact le_of_add_le_add_left H }

instance [∀ i, OrderedAddCommMonoid (α i)] [∀ i, ContravariantClass (α i) (α i) (· + ·) (· ≤ ·)] :
    ContravariantClass (Π₀ i, α i) (Π₀ i, α i) (· + ·) (· ≤ ·) :=
  ⟨fun f g h H i => by specialize H i; rw [add_apply, add_apply] at H ;
    exact le_of_add_le_add_left H⟩

section CanonicallyOrderedAddMonoid

variable (α) [∀ i, CanonicallyOrderedAddMonoid (α i)]

instance : OrderBot (Π₀ i, α i) where
  bot := 0
  bot_le := by simp only [le_def, coe_zero, Pi.zero_apply, imp_true_iff, zero_le]

variable {α}

#print Dfinsupp.bot_eq_zero /-
protected theorem bot_eq_zero : (⊥ : Π₀ i, α i) = 0 :=
  rfl
#align dfinsupp.bot_eq_zero Dfinsupp.bot_eq_zero
-/

#print Dfinsupp.add_eq_zero_iff /-
@[simp]
theorem add_eq_zero_iff (f g : Π₀ i, α i) : f + g = 0 ↔ f = 0 ∧ g = 0 := by
  simp [ext_iff, forall_and]
#align dfinsupp.add_eq_zero_iff Dfinsupp.add_eq_zero_iff
-/

section Le

variable [DecidableEq ι] [∀ (i) (x : α i), Decidable (x ≠ 0)] {f g : Π₀ i, α i} {s : Finset ι}

#print Dfinsupp.le_iff' /-
theorem le_iff' (hf : f.support ⊆ s) : f ≤ g ↔ ∀ i ∈ s, f i ≤ g i :=
  ⟨fun h s hs => h s, fun h s =>
    if H : s ∈ f.support then h s (hf H) else (not_mem_support_iff.1 H).symm ▸ zero_le (g s)⟩
#align dfinsupp.le_iff' Dfinsupp.le_iff'
-/

#print Dfinsupp.le_iff /-
theorem le_iff : f ≤ g ↔ ∀ i ∈ f.support, f i ≤ g i :=
  le_iff' <| Subset.refl _
#align dfinsupp.le_iff Dfinsupp.le_iff
-/

variable (α)

#print Dfinsupp.decidableLE /-
instance decidableLE [∀ i, DecidableRel (@LE.le (α i) _)] : DecidableRel (@LE.le (Π₀ i, α i) _) :=
  fun f g => decidable_of_iff _ le_iff.symm
#align dfinsupp.decidable_le Dfinsupp.decidableLE
-/

variable {α}

#print Dfinsupp.single_le_iff /-
@[simp]
theorem single_le_iff {i : ι} {a : α i} : single i a ≤ f ↔ a ≤ f i :=
  (le_iff' support_single_subset).trans <| by simp
#align dfinsupp.single_le_iff Dfinsupp.single_le_iff
-/

end Le

variable (α) [∀ i, Sub (α i)] [∀ i, OrderedSub (α i)] {f g : Π₀ i, α i} {i : ι} {a b : α i}

#print Dfinsupp.tsub /-
/-- This is called `tsub` for truncated subtraction, to distinguish it with subtraction in an
additive group. -/
instance tsub : Sub (Π₀ i, α i) :=
  ⟨zipWith (fun i m n => m - n) fun i => tsub_self 0⟩
#align dfinsupp.tsub Dfinsupp.tsub
-/

variable {α}

#print Dfinsupp.tsub_apply /-
theorem tsub_apply (f g : Π₀ i, α i) (i : ι) : (f - g) i = f i - g i :=
  zipWith_apply _ _ _ _ _
#align dfinsupp.tsub_apply Dfinsupp.tsub_apply
-/

#print Dfinsupp.coe_tsub /-
@[simp]
theorem coe_tsub (f g : Π₀ i, α i) : ⇑(f - g) = f - g := by ext i; exact tsub_apply f g i
#align dfinsupp.coe_tsub Dfinsupp.coe_tsub
-/

variable (α)

instance : OrderedSub (Π₀ i, α i) :=
  ⟨fun n m k => forall_congr' fun i => by rw [add_apply, tsub_apply]; exact tsub_le_iff_right⟩

instance : CanonicallyOrderedAddMonoid (Π₀ i, α i) :=
  { Dfinsupp.orderBot α,
    Dfinsupp.orderedAddCommMonoid
      α with
    exists_add_of_le := fun f g h =>
      ⟨g - f, by ext i; rw [add_apply, tsub_apply]; exact (add_tsub_cancel_of_le <| h i).symm⟩
    le_self_add := fun f g i => by rw [add_apply]; exact le_self_add }

variable {α} [DecidableEq ι]

#print Dfinsupp.single_tsub /-
@[simp]
theorem single_tsub : single i (a - b) = single i a - single i b :=
  by
  ext j
  obtain rfl | h := eq_or_ne i j
  · rw [tsub_apply, single_eq_same, single_eq_same, single_eq_same]
  · rw [tsub_apply, single_eq_of_ne h, single_eq_of_ne h, single_eq_of_ne h, tsub_self]
#align dfinsupp.single_tsub Dfinsupp.single_tsub
-/

variable [∀ (i) (x : α i), Decidable (x ≠ 0)]

#print Dfinsupp.support_tsub /-
theorem support_tsub : (f - g).support ⊆ f.support := by
  simp (config := { contextual := true }) only [subset_iff, tsub_eq_zero_iff_le, mem_support_iff,
    Ne.def, coe_tsub, Pi.sub_apply, not_imp_not, zero_le, imp_true_iff]
#align dfinsupp.support_tsub Dfinsupp.support_tsub
-/

#print Dfinsupp.subset_support_tsub /-
theorem subset_support_tsub : f.support \ g.support ⊆ (f - g).support := by
  simp (config := { contextual := true }) [subset_iff]
#align dfinsupp.subset_support_tsub Dfinsupp.subset_support_tsub
-/

end CanonicallyOrderedAddMonoid

section CanonicallyLinearOrderedAddMonoid

variable [∀ i, CanonicallyLinearOrderedAddMonoid (α i)] [DecidableEq ι] {f g : Π₀ i, α i}

#print Dfinsupp.support_inf /-
@[simp]
theorem support_inf : (f ⊓ g).support = f.support ∩ g.support :=
  by
  ext
  simp only [inf_apply, mem_support_iff, Ne.def, Finset.mem_union, Finset.mem_filter,
    Finset.mem_inter]
  simp only [inf_eq_min, ← nonpos_iff_eq_zero, min_le_iff, not_or]
#align dfinsupp.support_inf Dfinsupp.support_inf
-/

#print Dfinsupp.support_sup /-
@[simp]
theorem support_sup : (f ⊔ g).support = f.support ∪ g.support :=
  by
  ext
  simp only [Finset.mem_union, mem_support_iff, sup_apply, Ne.def, ← bot_eq_zero]
  rw [_root_.sup_eq_bot_iff, not_and_or]
#align dfinsupp.support_sup Dfinsupp.support_sup
-/

#print Dfinsupp.disjoint_iff /-
theorem disjoint_iff : Disjoint f g ↔ Disjoint f.support g.support :=
  by
  rw [disjoint_iff, disjoint_iff, Dfinsupp.bot_eq_zero, ← Dfinsupp.support_eq_empty,
    Dfinsupp.support_inf]
  rfl
#align dfinsupp.disjoint_iff Dfinsupp.disjoint_iff
-/

end CanonicallyLinearOrderedAddMonoid

end Dfinsupp

