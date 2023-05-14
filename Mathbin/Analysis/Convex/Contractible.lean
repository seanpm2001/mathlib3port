/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.convex.contractible
! leanprover-community/mathlib commit 3339976e2bcae9f1c81e620836d1eb736e3c4700
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Star
import Mathbin.Topology.Homotopy.Contractible

/-!
# A convex set is contractible

In this file we prove that a (star) convex set in a real topological vector space is a contractible
topological space.
-/


variable {E : Type _} [AddCommGroup E] [Module ℝ E] [TopologicalSpace E] [ContinuousAdd E]
  [ContinuousSMul ℝ E] {s : Set E} {x : E}

/- warning: star_convex.contractible_space -> StarConvex.contractibleSpace is a dubious translation:
lean 3 declaration is
  forall {E : Type.{u1}} [_inst_1 : AddCommGroup.{u1} E] [_inst_2 : Module.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)] [_inst_3 : TopologicalSpace.{u1} E] [_inst_4 : ContinuousAdd.{u1} E _inst_3 (AddZeroClass.toHasAdd.{u1} E (AddMonoid.toAddZeroClass.{u1} E (SubNegMonoid.toAddMonoid.{u1} E (AddGroup.toSubNegMonoid.{u1} E (AddCommGroup.toAddGroup.{u1} E _inst_1)))))] [_inst_5 : ContinuousSMul.{0, u1} Real E (SMulZeroClass.toHasSmul.{0, u1} Real E (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (SMulWithZero.toSmulZeroClass.{0, u1} Real E (MulZeroClass.toHasZero.{0} Real (MulZeroOneClass.toMulZeroClass.{0} Real (MonoidWithZero.toMulZeroOneClass.{0} Real (Semiring.toMonoidWithZero.{0} Real Real.semiring)))) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E (Semiring.toMonoidWithZero.{0} Real Real.semiring) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_3] {s : Set.{u1} E} {x : E}, (StarConvex.{0, u1} Real E Real.orderedSemiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) (SMulZeroClass.toHasSmul.{0, u1} Real E (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (SMulWithZero.toSmulZeroClass.{0, u1} Real E (MulZeroClass.toHasZero.{0} Real (MulZeroOneClass.toMulZeroClass.{0} Real (MonoidWithZero.toMulZeroOneClass.{0} Real (Semiring.toMonoidWithZero.{0} Real Real.semiring)))) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E (Semiring.toMonoidWithZero.{0} Real Real.semiring) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) x s) -> (Set.Nonempty.{u1} E s) -> (ContractibleSpace.{u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} E) Type.{u1} (Set.hasCoeToSort.{u1} E) s) (Subtype.topologicalSpace.{u1} E (fun (x : E) => Membership.Mem.{u1, u1} E (Set.{u1} E) (Set.hasMem.{u1} E) x s) _inst_3))
but is expected to have type
  forall {E : Type.{u1}} [_inst_1 : AddCommGroup.{u1} E] [_inst_2 : Module.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)] [_inst_3 : TopologicalSpace.{u1} E] [_inst_4 : ContinuousAdd.{u1} E _inst_3 (AddZeroClass.toAdd.{u1} E (AddMonoid.toAddZeroClass.{u1} E (SubNegMonoid.toAddMonoid.{u1} E (AddGroup.toSubNegMonoid.{u1} E (AddCommGroup.toAddGroup.{u1} E _inst_1)))))] [_inst_5 : ContinuousSMul.{0, u1} Real E (SMulZeroClass.toSMul.{0, u1} Real E (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (SMulWithZero.toSMulZeroClass.{0, u1} Real E Real.instZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E Real.instMonoidWithZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_3] {s : Set.{u1} E} {x : E}, (StarConvex.{0, u1} Real E Real.orderedSemiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) (SMulZeroClass.toSMul.{0, u1} Real E (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (SMulWithZero.toSMulZeroClass.{0, u1} Real E Real.instZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E Real.instMonoidWithZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) x s) -> (Set.Nonempty.{u1} E s) -> (ContractibleSpace.{u1} (Set.Elem.{u1} E s) (instTopologicalSpaceSubtype.{u1} E (fun (x : E) => Membership.mem.{u1, u1} E (Set.{u1} E) (Set.instMembershipSet.{u1} E) x s) _inst_3))
Case conversion may be inaccurate. Consider using '#align star_convex.contractible_space StarConvex.contractibleSpaceₓ'. -/
/-- A non-empty star convex set is a contractible space. -/
protected theorem StarConvex.contractibleSpace (h : StarConvex ℝ x s) (hne : s.Nonempty) :
    ContractibleSpace s :=
  by
  refine'
    (contractible_iff_id_nullhomotopic _).2
      ⟨⟨x, h.mem hne⟩, ⟨⟨⟨fun p => ⟨p.1.1 • x + (1 - p.1.1) • p.2, _⟩, _⟩, fun x => _, fun x => _⟩⟩⟩
  · exact h p.2.2 p.1.2.1 (sub_nonneg.2 p.1.2.2) (add_sub_cancel'_right _ _)
  ·
    exact
      ((continuous_subtype_val.fst'.smul continuous_const).add
            ((continuous_const.sub continuous_subtype_val.fst').smul
              continuous_subtype_val.snd')).subtype_mk
        _
  · ext1
    simp
  · ext1
    simp
#align star_convex.contractible_space StarConvex.contractibleSpace

/- warning: convex.contractible_space -> Convex.contractibleSpace is a dubious translation:
lean 3 declaration is
  forall {E : Type.{u1}} [_inst_1 : AddCommGroup.{u1} E] [_inst_2 : Module.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)] [_inst_3 : TopologicalSpace.{u1} E] [_inst_4 : ContinuousAdd.{u1} E _inst_3 (AddZeroClass.toHasAdd.{u1} E (AddMonoid.toAddZeroClass.{u1} E (SubNegMonoid.toAddMonoid.{u1} E (AddGroup.toSubNegMonoid.{u1} E (AddCommGroup.toAddGroup.{u1} E _inst_1)))))] [_inst_5 : ContinuousSMul.{0, u1} Real E (SMulZeroClass.toHasSmul.{0, u1} Real E (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (SMulWithZero.toSmulZeroClass.{0, u1} Real E (MulZeroClass.toHasZero.{0} Real (MulZeroOneClass.toMulZeroClass.{0} Real (MonoidWithZero.toMulZeroOneClass.{0} Real (Semiring.toMonoidWithZero.{0} Real Real.semiring)))) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E (Semiring.toMonoidWithZero.{0} Real Real.semiring) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_3] {s : Set.{u1} E}, (Convex.{0, u1} Real E Real.orderedSemiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) (SMulZeroClass.toHasSmul.{0, u1} Real E (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (SMulWithZero.toSmulZeroClass.{0, u1} Real E (MulZeroClass.toHasZero.{0} Real (MulZeroOneClass.toMulZeroClass.{0} Real (MonoidWithZero.toMulZeroOneClass.{0} Real (Semiring.toMonoidWithZero.{0} Real Real.semiring)))) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E (Semiring.toMonoidWithZero.{0} Real Real.semiring) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) s) -> (Set.Nonempty.{u1} E s) -> (ContractibleSpace.{u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} E) Type.{u1} (Set.hasCoeToSort.{u1} E) s) (Subtype.topologicalSpace.{u1} E (fun (x : E) => Membership.Mem.{u1, u1} E (Set.{u1} E) (Set.hasMem.{u1} E) x s) _inst_3))
but is expected to have type
  forall {E : Type.{u1}} [_inst_1 : AddCommGroup.{u1} E] [_inst_2 : Module.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)] [_inst_3 : TopologicalSpace.{u1} E] [_inst_4 : ContinuousAdd.{u1} E _inst_3 (AddZeroClass.toAdd.{u1} E (AddMonoid.toAddZeroClass.{u1} E (SubNegMonoid.toAddMonoid.{u1} E (AddGroup.toSubNegMonoid.{u1} E (AddCommGroup.toAddGroup.{u1} E _inst_1)))))] [_inst_5 : ContinuousSMul.{0, u1} Real E (SMulZeroClass.toSMul.{0, u1} Real E (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (SMulWithZero.toSMulZeroClass.{0, u1} Real E Real.instZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E Real.instMonoidWithZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_3] {s : Set.{u1} E}, (Convex.{0, u1} Real E Real.orderedSemiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) (SMulZeroClass.toSMul.{0, u1} Real E (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (SMulWithZero.toSMulZeroClass.{0, u1} Real E Real.instZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E Real.instMonoidWithZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) s) -> (Set.Nonempty.{u1} E s) -> (ContractibleSpace.{u1} (Set.Elem.{u1} E s) (instTopologicalSpaceSubtype.{u1} E (fun (x : E) => Membership.mem.{u1, u1} E (Set.{u1} E) (Set.instMembershipSet.{u1} E) x s) _inst_3))
Case conversion may be inaccurate. Consider using '#align convex.contractible_space Convex.contractibleSpaceₓ'. -/
/-- A non-empty convex set is a contractible space. -/
protected theorem Convex.contractibleSpace (hs : Convex ℝ s) (hne : s.Nonempty) :
    ContractibleSpace s :=
  let ⟨x, hx⟩ := hne
  (hs.StarConvex hx).ContractibleSpace hne
#align convex.contractible_space Convex.contractibleSpace

/- warning: real_topological_vector_space.contractible_space -> RealTopologicalVectorSpace.contractibleSpace is a dubious translation:
lean 3 declaration is
  forall {E : Type.{u1}} [_inst_1 : AddCommGroup.{u1} E] [_inst_2 : Module.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)] [_inst_3 : TopologicalSpace.{u1} E] [_inst_4 : ContinuousAdd.{u1} E _inst_3 (AddZeroClass.toHasAdd.{u1} E (AddMonoid.toAddZeroClass.{u1} E (SubNegMonoid.toAddMonoid.{u1} E (AddGroup.toSubNegMonoid.{u1} E (AddCommGroup.toAddGroup.{u1} E _inst_1)))))] [_inst_5 : ContinuousSMul.{0, u1} Real E (SMulZeroClass.toHasSmul.{0, u1} Real E (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (SMulWithZero.toSmulZeroClass.{0, u1} Real E (MulZeroClass.toHasZero.{0} Real (MulZeroOneClass.toMulZeroClass.{0} Real (MonoidWithZero.toMulZeroOneClass.{0} Real (Semiring.toMonoidWithZero.{0} Real Real.semiring)))) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E (Semiring.toMonoidWithZero.{0} Real Real.semiring) (AddZeroClass.toHasZero.{u1} E (AddMonoid.toAddZeroClass.{u1} E (AddCommMonoid.toAddMonoid.{u1} E (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_3], ContractibleSpace.{u1} E _inst_3
but is expected to have type
  forall {E : Type.{u1}} [_inst_1 : AddCommGroup.{u1} E] [_inst_2 : Module.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1)] [_inst_3 : TopologicalSpace.{u1} E] [_inst_4 : ContinuousAdd.{u1} E _inst_3 (AddZeroClass.toAdd.{u1} E (AddMonoid.toAddZeroClass.{u1} E (SubNegMonoid.toAddMonoid.{u1} E (AddGroup.toSubNegMonoid.{u1} E (AddCommGroup.toAddGroup.{u1} E _inst_1)))))] [_inst_5 : ContinuousSMul.{0, u1} Real E (SMulZeroClass.toSMul.{0, u1} Real E (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (SMulWithZero.toSMulZeroClass.{0, u1} Real E Real.instZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (MulActionWithZero.toSMulWithZero.{0, u1} Real E Real.instMonoidWithZeroReal (NegZeroClass.toZero.{u1} E (SubNegZeroMonoid.toNegZeroClass.{u1} E (SubtractionMonoid.toSubNegZeroMonoid.{u1} E (SubtractionCommMonoid.toSubtractionMonoid.{u1} E (AddCommGroup.toDivisionAddCommMonoid.{u1} E _inst_1))))) (Module.toMulActionWithZero.{0, u1} Real E Real.semiring (AddCommGroup.toAddCommMonoid.{u1} E _inst_1) _inst_2)))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_3], ContractibleSpace.{u1} E _inst_3
Case conversion may be inaccurate. Consider using '#align real_topological_vector_space.contractible_space RealTopologicalVectorSpace.contractibleSpaceₓ'. -/
instance (priority := 100) RealTopologicalVectorSpace.contractibleSpace : ContractibleSpace E :=
  (Homeomorph.Set.univ E).contractibleSpace_iff.mp <|
    convex_univ.ContractibleSpace Set.univ_nonempty
#align real_topological_vector_space.contractible_space RealTopologicalVectorSpace.contractibleSpace

