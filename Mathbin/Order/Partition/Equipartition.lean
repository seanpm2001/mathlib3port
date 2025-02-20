/-
Copyright (c) 2022 Yaël Dillies, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Bhavik Mehta

! This file was ported from Lean 3 source module order.partition.equipartition
! leanprover-community/mathlib commit 0a0ec35061ed9960bf0e7ffb0335f44447b58977
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Equitable
import Mathbin.Order.Partition.Finpartition

/-!
# Finite equipartitions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines finite equipartitions, the partitions whose parts all are the same size up to a
difference of `1`.

## Main declarations

* `finpartition.is_equipartition`: Predicate for a `finpartition` to be an equipartition.
-/


open Finset Fintype

namespace Finpartition

variable {α : Type _} [DecidableEq α] {s t : Finset α} (P : Finpartition s)

#print Finpartition.IsEquipartition /-
/-- An equipartition is a partition whose parts are all the same size, up to a difference of `1`. -/
def IsEquipartition : Prop :=
  (P.parts : Set (Finset α)).EquitableOn card
#align finpartition.is_equipartition Finpartition.IsEquipartition
-/

#print Finpartition.isEquipartition_iff_card_parts_eq_average /-
theorem isEquipartition_iff_card_parts_eq_average :
    P.IsEquipartition ↔
      ∀ a : Finset α,
        a ∈ P.parts → a.card = s.card / P.parts.card ∨ a.card = s.card / P.parts.card + 1 :=
  by simp_rw [is_equipartition, Finset.equitableOn_iff, P.sum_card_parts]
#align finpartition.is_equipartition_iff_card_parts_eq_average Finpartition.isEquipartition_iff_card_parts_eq_average
-/

variable {P}

theorem Set.Subsingleton.isEquipartition (h : (P.parts : Set (Finset α)).Subsingleton) :
    P.IsEquipartition :=
  h.EquitableOn _
#align set.subsingleton.is_equipartition Set.Subsingleton.isEquipartition

#print Finpartition.IsEquipartition.card_parts_eq_average /-
theorem IsEquipartition.card_parts_eq_average (hP : P.IsEquipartition) (ht : t ∈ P.parts) :
    t.card = s.card / P.parts.card ∨ t.card = s.card / P.parts.card + 1 :=
  P.isEquipartition_iff_card_parts_eq_average.1 hP _ ht
#align finpartition.is_equipartition.card_parts_eq_average Finpartition.IsEquipartition.card_parts_eq_average
-/

#print Finpartition.IsEquipartition.average_le_card_part /-
theorem IsEquipartition.average_le_card_part (hP : P.IsEquipartition) (ht : t ∈ P.parts) :
    s.card / P.parts.card ≤ t.card := by rw [← P.sum_card_parts]; exact equitable_on.le hP ht
#align finpartition.is_equipartition.average_le_card_part Finpartition.IsEquipartition.average_le_card_part
-/

#print Finpartition.IsEquipartition.card_part_le_average_add_one /-
theorem IsEquipartition.card_part_le_average_add_one (hP : P.IsEquipartition) (ht : t ∈ P.parts) :
    t.card ≤ s.card / P.parts.card + 1 := by rw [← P.sum_card_parts];
  exact equitable_on.le_add_one hP ht
#align finpartition.is_equipartition.card_part_le_average_add_one Finpartition.IsEquipartition.card_part_le_average_add_one
-/

/-! ### Discrete and indiscrete finpartition -/


variable (s)

#print Finpartition.bot_isEquipartition /-
theorem bot_isEquipartition : (⊥ : Finpartition s).IsEquipartition :=
  Set.equitableOn_iff_exists_eq_eq_add_one.2 ⟨1, by simp⟩
#align finpartition.bot_is_equipartition Finpartition.bot_isEquipartition
-/

#print Finpartition.top_isEquipartition /-
theorem top_isEquipartition : (⊤ : Finpartition s).IsEquipartition :=
  (parts_top_subsingleton _).IsEquipartition
#align finpartition.top_is_equipartition Finpartition.top_isEquipartition
-/

#print Finpartition.indiscrete_isEquipartition /-
theorem indiscrete_isEquipartition {hs : s ≠ ∅} : (indiscrete hs).IsEquipartition := by
  rw [is_equipartition, indiscrete_parts, coe_singleton]; exact Set.equitableOn_singleton s _
#align finpartition.indiscrete_is_equipartition Finpartition.indiscrete_isEquipartition
-/

end Finpartition

