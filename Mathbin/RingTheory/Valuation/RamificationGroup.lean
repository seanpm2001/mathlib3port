/-
Copyright (c) 2022 Michail Karatarakis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Michail Karatarakis

! This file was ported from Lean 3 source module ring_theory.valuation.ramification_group
! leanprover-community/mathlib commit 1b089e3bdc3ce6b39cd472543474a0a137128c6c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Ideal.LocalRing
import Mathbin.RingTheory.Valuation.ValuationSubring

/-!
# Ramification groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The decomposition subgroup and inertia subgroups.

TODO: Define higher ramification groups in lower numbering
-/


namespace ValuationSubring

open scoped Pointwise

variable (K : Type _) {L : Type _} [Field K] [Field L] [Algebra K L]

#print ValuationSubring.decompositionSubgroup /-
/-- The decomposition subgroup defined as the stabilizer of the action
on the type of all valuation subrings of the field. -/
@[reducible]
def decompositionSubgroup (A : ValuationSubring L) : Subgroup (L ≃ₐ[K] L) :=
  MulAction.stabilizer (L ≃ₐ[K] L) A
#align valuation_subring.decomposition_subgroup ValuationSubring.decompositionSubgroup
-/

#print ValuationSubring.subMulAction /-
/-- The valuation subring `A` (considered as a subset of `L`)
is stable under the action of the decomposition group. -/
def subMulAction (A : ValuationSubring L) : SubMulAction (A.decompositionSubgroup K) L
    where
  carrier := A
  smul_mem' g l h := Set.mem_of_mem_of_subset (Set.smul_mem_smul_set h) g.Prop.le
#align valuation_subring.sub_mul_action ValuationSubring.subMulAction
-/

#print ValuationSubring.decompositionSubgroupMulSemiringAction /-
/-- The multiplicative action of the decomposition subgroup on `A`. -/
instance decompositionSubgroupMulSemiringAction (A : ValuationSubring L) :
    MulSemiringAction (A.decompositionSubgroup K) A :=
  {
    SubMulAction.mulAction
      (A.SubMulAction
        K) with
    smul_add := fun g k l => Subtype.ext <| smul_add g k l
    smul_zero := fun g => Subtype.ext <| smul_zero g
    smul_one := fun g => Subtype.ext <| smul_one g
    smul_mul := fun g k l => Subtype.ext <| smul_mul' g k l }
#align valuation_subring.decomposition_subgroup_mul_semiring_action ValuationSubring.decompositionSubgroupMulSemiringAction
-/

#print ValuationSubring.inertiaSubgroup /-
/-- The inertia subgroup defined as the kernel of the group homomorphism from
the decomposition subgroup to the group of automorphisms of the residue field of `A`. -/
def inertiaSubgroup (A : ValuationSubring L) : Subgroup (A.decompositionSubgroup K) :=
  MonoidHom.ker <|
    MulSemiringAction.toRingAut (A.decompositionSubgroup K) (LocalRing.ResidueField A)
#align valuation_subring.inertia_subgroup ValuationSubring.inertiaSubgroup
-/

end ValuationSubring

