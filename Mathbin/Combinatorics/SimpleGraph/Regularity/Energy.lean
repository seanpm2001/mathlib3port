/-
Copyright (c) 2022 Yaël Dillies, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Bhavik Mehta

! This file was ported from Lean 3 source module combinatorics.simple_graph.regularity.energy
! leanprover-community/mathlib commit bf7ef0e83e5b7e6c1169e97f055e58a2e4e9d52d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Order
import Mathbin.Algebra.Module.Basic
import Mathbin.Combinatorics.SimpleGraph.Density
import Mathbin.Data.Rat.BigOperators

/-!
# Energy of a partition

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the energy of a partition.

The energy is the auxiliary quantity that drives the induction process in the proof of Szemerédi's
Regularity Lemma. As long as we do not have a suitable equipartition, we will find a new one that
has an energy greater than the previous one plus some fixed constant.

## References

[Yaël Dillies, Bhavik Mehta, *Formalising Szemerédi’s Regularity Lemma in Lean*][srl_itp]
-/


open Finset

open scoped BigOperators

variable {α : Type _} [DecidableEq α] {s : Finset α} (P : Finpartition s) (G : SimpleGraph α)
  [DecidableRel G.Adj]

namespace Finpartition

#print Finpartition.energy /-
/-- The energy of a partition, also known as index. Auxiliary quantity for Szemerédi's regularity
lemma.  -/
def energy : ℚ :=
  (∑ uv in P.parts.offDiag, G.edgeDensity uv.1 uv.2 ^ 2) / P.parts.card ^ 2
#align finpartition.energy Finpartition.energy
-/

#print Finpartition.energy_nonneg /-
theorem energy_nonneg : 0 ≤ P.energy G :=
  div_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) <| sq_nonneg _
#align finpartition.energy_nonneg Finpartition.energy_nonneg
-/

#print Finpartition.energy_le_one /-
theorem energy_le_one : P.energy G ≤ 1 :=
  div_le_of_nonneg_of_le_mul (sq_nonneg _) zero_le_one <|
    calc
      ∑ uv in P.parts.offDiag, G.edgeDensity uv.1 uv.2 ^ 2 ≤ P.parts.offDiag.card • 1 :=
        sum_le_card_nsmul _ _ 1 fun uv _ =>
          (sq_le_one_iff <| G.edgeDensity_nonneg _ _).2 <| G.edgeDensity_le_one _ _
      _ = P.parts.offDiag.card := (Nat.smul_one_eq_coe _)
      _ ≤ _ := by rw [off_diag_card, one_mul, ← Nat.cast_pow, Nat.cast_le, sq]; exact tsub_le_self
#align finpartition.energy_le_one Finpartition.energy_le_one
-/

#print Finpartition.coe_energy /-
@[simp, norm_cast]
theorem coe_energy {𝕜 : Type _} [LinearOrderedField 𝕜] :
    (P.energy G : 𝕜) = (∑ uv in P.parts.offDiag, G.edgeDensity uv.1 uv.2 ^ 2) / P.parts.card ^ 2 :=
  by rw [energy]; norm_cast
#align finpartition.coe_energy Finpartition.coe_energy
-/

end Finpartition

