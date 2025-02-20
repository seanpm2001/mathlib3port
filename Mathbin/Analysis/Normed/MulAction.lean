/-
Copyright (c) 2023 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module analysis.normed.mul_action
! leanprover-community/mathlib commit a87d22575d946e1e156fc1edd1e1269600a8a282
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.MetricSpace.Algebra
import Mathbin.Analysis.Normed.Field.Basic

/-!
# Lemmas for `has_bounded_smul` over normed additive groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Lemmas which hold only in `normed_space α β` are provided in another file.

Notably we prove that `non_unital_semi_normed_ring`s have bounded actions by left- and right-
multiplication. This allows downstream files to write general results about `bounded_smul`, and then
deduce `const_mul` and `mul_const` results as an immediate corollary.
-/


variable {α β : Type _}

section SeminormedAddGroup

variable [SeminormedAddGroup α] [SeminormedAddGroup β] [SMulZeroClass α β]

variable [BoundedSMul α β]

#print norm_smul_le /-
theorem norm_smul_le (r : α) (x : β) : ‖r • x‖ ≤ ‖r‖ * ‖x‖ := by
  simpa [smul_zero] using dist_smul_pair r 0 x
#align norm_smul_le norm_smul_le
-/

#print nnnorm_smul_le /-
theorem nnnorm_smul_le (r : α) (x : β) : ‖r • x‖₊ ≤ ‖r‖₊ * ‖x‖₊ :=
  norm_smul_le _ _
#align nnnorm_smul_le nnnorm_smul_le
-/

#print dist_smul_le /-
theorem dist_smul_le (s : α) (x y : β) : dist (s • x) (s • y) ≤ ‖s‖ * dist x y := by
  simpa only [dist_eq_norm, sub_zero] using dist_smul_pair s x y
#align dist_smul_le dist_smul_le
-/

#print nndist_smul_le /-
theorem nndist_smul_le (s : α) (x y : β) : nndist (s • x) (s • y) ≤ ‖s‖₊ * nndist x y :=
  dist_smul_le s x y
#align nndist_smul_le nndist_smul_le
-/

#print edist_smul_le /-
theorem edist_smul_le (s : α) (x y : β) : edist (s • x) (s • y) ≤ ‖s‖₊ • edist x y := by
  simpa only [edist_nndist, ENNReal.coe_mul] using ennreal.coe_le_coe.mpr (nndist_smul_le s x y)
#align edist_smul_le edist_smul_le
-/

#print lipschitzWith_smul /-
theorem lipschitzWith_smul (s : α) : LipschitzWith ‖s‖₊ ((· • ·) s : β → β) :=
  lipschitzWith_iff_dist_le_mul.2 <| dist_smul_le _
#align lipschitz_with_smul lipschitzWith_smul
-/

end SeminormedAddGroup

#print NonUnitalSeminormedRing.to_boundedSMul /-
/-- Left multiplication is bounded. -/
instance NonUnitalSeminormedRing.to_boundedSMul [NonUnitalSeminormedRing α] : BoundedSMul α α
    where
  dist_smul_pair' x y₁ y₂ := by simpa [mul_sub, dist_eq_norm] using norm_mul_le x (y₁ - y₂)
  dist_pair_smul' x₁ x₂ y := by simpa [sub_mul, dist_eq_norm] using norm_mul_le (x₁ - x₂) y
#align non_unital_semi_normed_ring.to_has_bounded_smul NonUnitalSeminormedRing.to_boundedSMul
-/

#print NonUnitalSeminormedRing.to_has_bounded_op_smul /-
/-- Right multiplication is bounded. -/
instance NonUnitalSeminormedRing.to_has_bounded_op_smul [NonUnitalSeminormedRing α] :
    BoundedSMul αᵐᵒᵖ α
    where
  dist_smul_pair' x y₁ y₂ := by
    simpa [sub_mul, dist_eq_norm, mul_comm] using norm_mul_le (y₁ - y₂) x.unop
  dist_pair_smul' x₁ x₂ y := by
    simpa [mul_sub, dist_eq_norm, mul_comm] using norm_mul_le y (x₁ - x₂).unop
#align non_unital_semi_normed_ring.to_has_bounded_op_smul NonUnitalSeminormedRing.to_has_bounded_op_smul
-/

section SeminormedRing

variable [SeminormedRing α] [SeminormedAddCommGroup β] [Module α β]

#print BoundedSMul.of_norm_smul_le /-
theorem BoundedSMul.of_norm_smul_le (h : ∀ (r : α) (x : β), ‖r • x‖ ≤ ‖r‖ * ‖x‖) :
    BoundedSMul α β :=
  { dist_smul_pair' := fun a b₁ b₂ => by simpa [smul_sub, dist_eq_norm] using h a (b₁ - b₂)
    dist_pair_smul' := fun a₁ a₂ b => by simpa [sub_smul, dist_eq_norm] using h (a₁ - a₂) b }
#align has_bounded_smul.of_norm_smul_le BoundedSMul.of_norm_smul_le
-/

end SeminormedRing

section NormedDivisionRing

variable [NormedDivisionRing α] [SeminormedAddGroup β]

variable [MulActionWithZero α β] [BoundedSMul α β]

#print norm_smul /-
theorem norm_smul (r : α) (x : β) : ‖r • x‖ = ‖r‖ * ‖x‖ :=
  by
  by_cases h : r = 0
  · simp [h, zero_smul α x]
  · refine' le_antisymm (norm_smul_le r x) _
    calc
      ‖r‖ * ‖x‖ = ‖r‖ * ‖r⁻¹ • r • x‖ := by rw [inv_smul_smul₀ h]
      _ ≤ ‖r‖ * (‖r⁻¹‖ * ‖r • x‖) := (mul_le_mul_of_nonneg_left (norm_smul_le _ _) (norm_nonneg _))
      _ = ‖r • x‖ := by rw [norm_inv, ← mul_assoc, mul_inv_cancel (mt norm_eq_zero.1 h), one_mul]
#align norm_smul norm_smul
-/

#print nnnorm_smul /-
theorem nnnorm_smul (r : α) (x : β) : ‖r • x‖₊ = ‖r‖₊ * ‖x‖₊ :=
  NNReal.eq <| norm_smul r x
#align nnnorm_smul nnnorm_smul
-/

end NormedDivisionRing

section NormedDivisionRingModule

variable [NormedDivisionRing α] [SeminormedAddCommGroup β]

variable [Module α β] [BoundedSMul α β]

#print dist_smul₀ /-
theorem dist_smul₀ (s : α) (x y : β) : dist (s • x) (s • y) = ‖s‖ * dist x y := by
  simp_rw [dist_eq_norm, (norm_smul _ _).symm, smul_sub]
#align dist_smul₀ dist_smul₀
-/

#print nndist_smul₀ /-
theorem nndist_smul₀ (s : α) (x y : β) : nndist (s • x) (s • y) = ‖s‖₊ * nndist x y :=
  NNReal.eq <| dist_smul₀ s x y
#align nndist_smul₀ nndist_smul₀
-/

#print edist_smul₀ /-
theorem edist_smul₀ (s : α) (x y : β) : edist (s • x) (s • y) = ‖s‖₊ • edist x y := by
  simp only [edist_nndist, nndist_smul₀, ENNReal.coe_mul, ENNReal.smul_def, smul_eq_mul]
#align edist_smul₀ edist_smul₀
-/

end NormedDivisionRingModule

