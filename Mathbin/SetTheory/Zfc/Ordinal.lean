/-
Copyright (c) 2022 Violeta Hernández Palacios. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Violeta Hernández Palacios

! This file was ported from Lean 3 source module set_theory.zfc.ordinal
! leanprover-community/mathlib commit 25a9423c6b2c8626e91c688bfd6c1d0a986a3e6e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.SetTheory.Zfc.Basic

/-!
# Von Neumann ordinals

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file works towards the development of von Neumann ordinals, i.e. transitive sets, well-ordered
under `∈`. We currently only have an initial development of transitive sets.

Further development can be found on the branch `von_neumann_v2`.

## Definitions

- `Set.is_transitive` means that every element of a set is a subset.

## Todo

- Define von Neumann ordinals.
- Define the basic arithmetic operations on ordinals from a purely set-theoretic perspective.
- Prove the equivalences between these definitions and those provided in
  `set_theory/ordinal/arithmetic.lean`.
-/


universe u

variable {x y z : ZFSet.{u}}

namespace ZFSet

#print ZFSet.IsTransitive /-
/-- A transitive set is one where every element is a subset. -/
def IsTransitive (x : ZFSet) : Prop :=
  ∀ y ∈ x, y ⊆ x
#align Set.is_transitive ZFSet.IsTransitive
-/

#print ZFSet.empty_isTransitive /-
@[simp]
theorem empty_isTransitive : IsTransitive ∅ := fun y hy => (not_mem_empty y hy).elim
#align Set.empty_is_transitive ZFSet.empty_isTransitive
-/

#print ZFSet.IsTransitive.subset_of_mem /-
theorem IsTransitive.subset_of_mem (h : x.IsTransitive) : y ∈ x → y ⊆ x :=
  h y
#align Set.is_transitive.subset_of_mem ZFSet.IsTransitive.subset_of_mem
-/

#print ZFSet.isTransitive_iff_mem_trans /-
theorem isTransitive_iff_mem_trans : z.IsTransitive ↔ ∀ {x y : ZFSet}, x ∈ y → y ∈ z → x ∈ z :=
  ⟨fun h x y hx hy => h.subset_of_mem hy hx, fun H x hx y hy => H hy hx⟩
#align Set.is_transitive_iff_mem_trans ZFSet.isTransitive_iff_mem_trans
-/

alias is_transitive_iff_mem_trans ↔ is_transitive.mem_trans _
#align Set.is_transitive.mem_trans ZFSet.IsTransitive.mem_trans

#print ZFSet.IsTransitive.inter /-
protected theorem IsTransitive.inter (hx : x.IsTransitive) (hy : y.IsTransitive) :
    (x ∩ y).IsTransitive := fun z hz w hw => by rw [mem_inter] at hz ⊢;
  exact ⟨hx.mem_trans hw hz.1, hy.mem_trans hw hz.2⟩
#align Set.is_transitive.inter ZFSet.IsTransitive.inter
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ZFSet.IsTransitive.sUnion /-
protected theorem IsTransitive.sUnion (h : x.IsTransitive) : (⋃₀ x).IsTransitive := fun y hy z hz =>
  by
  rcases mem_sUnion.1 hy with ⟨w, hw, hw'⟩
  exact mem_sUnion_of_mem hz (h.mem_trans hw' hw)
#align Set.is_transitive.sUnion ZFSet.IsTransitive.sUnion
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ZFSet.IsTransitive.sUnion' /-
theorem IsTransitive.sUnion' (H : ∀ y ∈ x, IsTransitive y) : (⋃₀ x).IsTransitive := fun y hy z hz =>
  by
  rcases mem_sUnion.1 hy with ⟨w, hw, hw'⟩
  exact mem_sUnion_of_mem ((H w hw).mem_trans hz hw') hw
#align Set.is_transitive.sUnion' ZFSet.IsTransitive.sUnion'
-/

#print ZFSet.IsTransitive.union /-
protected theorem IsTransitive.union (hx : x.IsTransitive) (hy : y.IsTransitive) :
    (x ∪ y).IsTransitive := by
  rw [← sUnion_pair]
  apply is_transitive.sUnion' fun z => _
  rw [mem_pair]
  rintro (rfl | rfl)
  assumption'
#align Set.is_transitive.union ZFSet.IsTransitive.union
-/

#print ZFSet.IsTransitive.powerset /-
protected theorem IsTransitive.powerset (h : x.IsTransitive) : (powerset x).IsTransitive :=
  fun y hy z hz => by rw [mem_powerset] at hy ⊢; exact h.subset_of_mem (hy hz)
#align Set.is_transitive.powerset ZFSet.IsTransitive.powerset
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ZFSet.isTransitive_iff_sUnion_subset /-
theorem isTransitive_iff_sUnion_subset : x.IsTransitive ↔ ⋃₀ x ⊆ x :=
  ⟨fun h y hy => by rcases mem_sUnion.1 hy with ⟨z, hz, hz'⟩; exact h.mem_trans hz' hz,
    fun H y hy z hz => H <| mem_sUnion_of_mem hz hy⟩
#align Set.is_transitive_iff_sUnion_subset ZFSet.isTransitive_iff_sUnion_subset
-/

alias is_transitive_iff_sUnion_subset ↔ is_transitive.sUnion_subset _
#align Set.is_transitive.sUnion_subset ZFSet.IsTransitive.sUnion_subset

#print ZFSet.isTransitive_iff_subset_powerset /-
theorem isTransitive_iff_subset_powerset : x.IsTransitive ↔ x ⊆ powerset x :=
  ⟨fun h y hy => mem_powerset.2 <| h.subset_of_mem hy, fun H y hy z hz => mem_powerset.1 (H hy) hz⟩
#align Set.is_transitive_iff_subset_powerset ZFSet.isTransitive_iff_subset_powerset
-/

alias is_transitive_iff_subset_powerset ↔ is_transitive.subset_powerset _
#align Set.is_transitive.subset_powerset ZFSet.IsTransitive.subset_powerset

end ZFSet

