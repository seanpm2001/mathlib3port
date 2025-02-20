/-
Copyright (c) 2020 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn

! This file was ported from Lean 3 source module logic.encodable.lattice
! leanprover-community/mathlib commit f2f413b9d4be3a02840d0663dace76e8fe3da053
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Encodable.Basic
import Mathbin.Logic.Pairwise

/-!
# Lattice operations on encodable types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Lemmas about lattice and set operations on encodable types

## Implementation Notes

This is a separate file, to avoid unnecessary imports in basic files.

Previously some of these results were in the `measure_theory` folder.
-/


open Set

namespace Encodable

variable {α : Type _} {β : Type _} [Encodable β]

#print Encodable.iSup_decode₂ /-
theorem iSup_decode₂ [CompleteLattice α] (f : β → α) :
    (⨆ (i : ℕ) (b ∈ decode₂ β i), f b) = ⨆ b, f b := by rw [iSup_comm]; simp [mem_decode₂]
#align encodable.supr_decode₂ Encodable.iSup_decode₂
-/

#print Encodable.iUnion_decode₂ /-
theorem iUnion_decode₂ (f : β → Set α) : (⋃ (i : ℕ) (b ∈ decode₂ β i), f b) = ⋃ b, f b :=
  iSup_decode₂ f
#align encodable.Union_decode₂ Encodable.iUnion_decode₂
-/

#print Encodable.iUnion_decode₂_cases /-
@[elab_as_elim]
theorem iUnion_decode₂_cases {f : β → Set α} {C : Set α → Prop} (H0 : C ∅) (H1 : ∀ b, C (f b)) {n} :
    C (⋃ b ∈ decode₂ β n, f b) :=
  match decode₂ β n with
  | none => by simp; apply H0
  | some b => by convert H1 b; simp [ext_iff]
#align encodable.Union_decode₂_cases Encodable.iUnion_decode₂_cases
-/

#print Encodable.iUnion_decode₂_disjoint_on /-
theorem iUnion_decode₂_disjoint_on {f : β → Set α} (hd : Pairwise (Disjoint on f)) :
    Pairwise (Disjoint on fun i => ⋃ b ∈ decode₂ β i, f b) :=
  by
  rintro i j ij
  refine' disjoint_left.mpr fun x => _
  suffices ∀ a, encode a = i → x ∈ f a → ∀ b, encode b = j → x ∉ f b by simpa [decode₂_eq_some]
  rintro a rfl ha b rfl hb
  exact (hd (mt (congr_arg encode) ij)).le_bot ⟨ha, hb⟩
#align encodable.Union_decode₂_disjoint_on Encodable.iUnion_decode₂_disjoint_on
-/

end Encodable

