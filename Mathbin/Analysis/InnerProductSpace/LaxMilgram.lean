/-
Copyright (c) 2022 Daniel Roca González. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Roca González

! This file was ported from Lean 3 source module analysis.inner_product_space.lax_milgram
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.Projection
import Mathbin.Analysis.InnerProductSpace.Dual
import Mathbin.Analysis.NormedSpace.Banach
import Mathbin.Analysis.NormedSpace.OperatorNorm
import Mathbin.Topology.MetricSpace.Antilipschitz

/-!
# The Lax-Milgram Theorem

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We consider an Hilbert space `V` over `ℝ`
equipped with a bounded bilinear form `B : V →L[ℝ] V →L[ℝ] ℝ`.

Recall that a bilinear form `B : V →L[ℝ] V →L[ℝ] ℝ` is *coercive*
iff `∃ C, (0 < C) ∧ ∀ u, C * ‖u‖ * ‖u‖ ≤ B u u`.
Under the hypothesis that `B` is coercive
we prove the Lax-Milgram theorem:
that is, the map `inner_product_space.continuous_linear_map_of_bilin` from
`analysis.inner_product_space.dual` can be upgraded to a continuous equivalence
`is_coercive.continuous_linear_equiv_of_bilin : V ≃L[ℝ] V`.

## References

* We follow the notes of Peter Howard's Spring 2020 *M612: Partial Differential Equations* lecture,
  see[howard]

## Tags

dual, Lax-Milgram
-/


noncomputable section

open IsROrC LinearMap ContinuousLinearMap InnerProductSpace

open LinearMap (ker range)

open scoped RealInnerProductSpace NNReal

universe u

namespace IsCoercive

variable {V : Type u} [NormedAddCommGroup V] [InnerProductSpace ℝ V] [CompleteSpace V]

variable {B : V →L[ℝ] V →L[ℝ] ℝ}

local postfix:1024 "♯" => @continuousLinearMapOfBilin ℝ V _ _ _ _

#print IsCoercive.bounded_below /-
theorem bounded_below (coercive : IsCoercive B) : ∃ C, 0 < C ∧ ∀ v, C * ‖v‖ ≤ ‖B♯ v‖ :=
  by
  rcases coercive with ⟨C, C_ge_0, coercivity⟩
  refine' ⟨C, C_ge_0, _⟩
  intro v
  by_cases h : 0 < ‖v‖
  · refine' (mul_le_mul_right h).mp _
    calc
      C * ‖v‖ * ‖v‖ ≤ B v v := coercivity v
      _ = ⟪B♯ v, v⟫_ℝ := (continuous_linear_map_of_bilin_apply ℝ B v v).symm
      _ ≤ ‖B♯ v‖ * ‖v‖ := real_inner_le_norm (B♯ v) v
  · have : v = 0 := by simpa using h
    simp [this]
#align is_coercive.bounded_below IsCoercive.bounded_below
-/

#print IsCoercive.antilipschitz /-
theorem antilipschitz (coercive : IsCoercive B) : ∃ C : ℝ≥0, 0 < C ∧ AntilipschitzWith C B♯ :=
  by
  rcases coercive.bounded_below with ⟨C, C_pos, below_bound⟩
  refine' ⟨C⁻¹.toNNReal, real.to_nnreal_pos.mpr (inv_pos.mpr C_pos), _⟩
  refine' ContinuousLinearMap.antilipschitz_of_bound B♯ _
  simp_rw [Real.coe_toNNReal', max_eq_left_of_lt (inv_pos.mpr C_pos), ←
    inv_mul_le_iff (inv_pos.mpr C_pos)]
  simpa using below_bound
#align is_coercive.antilipschitz IsCoercive.antilipschitz
-/

#print IsCoercive.ker_eq_bot /-
theorem ker_eq_bot (coercive : IsCoercive B) : ker B♯ = ⊥ :=
  by
  rw [LinearMapClass.ker_eq_bot]
  rcases coercive.antilipschitz with ⟨_, _, antilipschitz⟩
  exact antilipschitz.injective
#align is_coercive.ker_eq_bot IsCoercive.ker_eq_bot
-/

#print IsCoercive.closed_range /-
theorem closed_range (coercive : IsCoercive B) : IsClosed (range B♯ : Set V) :=
  by
  rcases coercive.antilipschitz with ⟨_, _, antilipschitz⟩
  exact antilipschitz.is_closed_range B♯.UniformContinuous
#align is_coercive.closed_range IsCoercive.closed_range
-/

#print IsCoercive.range_eq_top /-
theorem range_eq_top (coercive : IsCoercive B) : range B♯ = ⊤ :=
  by
  haveI := coercive.closed_range.complete_space_coe
  rw [← (range B♯).orthogonal_orthogonal]
  rw [Submodule.eq_top_iff']
  intro v w mem_w_orthogonal
  rcases coercive with ⟨C, C_pos, coercivity⟩
  obtain rfl : w = 0 :=
    by
    rw [← norm_eq_zero, ← mul_self_eq_zero, ← mul_right_inj' C_pos.ne', MulZeroClass.mul_zero, ←
      mul_assoc]
    apply le_antisymm
    ·
      calc
        C * ‖w‖ * ‖w‖ ≤ B w w := coercivity w
        _ = ⟪B♯ w, w⟫_ℝ := (continuous_linear_map_of_bilin_apply ℝ B w w).symm
        _ = 0 := mem_w_orthogonal _ ⟨w, rfl⟩
    · exact mul_nonneg (mul_nonneg C_pos.le (norm_nonneg w)) (norm_nonneg w)
  exact inner_zero_left _
#align is_coercive.range_eq_top IsCoercive.range_eq_top
-/

#print IsCoercive.continuousLinearEquivOfBilin /-
/-- The Lax-Milgram equivalence of a coercive bounded bilinear operator:
for all `v : V`, `continuous_linear_equiv_of_bilin B v` is the unique element `V`
such that `⟪continuous_linear_equiv_of_bilin B v, w⟫ = B v w`.
The Lax-Milgram theorem states that this is a continuous equivalence.
-/
def continuousLinearEquivOfBilin (coercive : IsCoercive B) : V ≃L[ℝ] V :=
  ContinuousLinearEquiv.ofBijective B♯ coercive.ker_eq_bot coercive.range_eq_top
#align is_coercive.continuous_linear_equiv_of_bilin IsCoercive.continuousLinearEquivOfBilin
-/

#print IsCoercive.continuousLinearEquivOfBilin_apply /-
@[simp]
theorem continuousLinearEquivOfBilin_apply (coercive : IsCoercive B) (v w : V) :
    ⟪coercive.continuousLinearEquivOfBilin v, w⟫_ℝ = B v w :=
  continuousLinearMapOfBilin_apply ℝ B v w
#align is_coercive.continuous_linear_equiv_of_bilin_apply IsCoercive.continuousLinearEquivOfBilin_apply
-/

#print IsCoercive.unique_continuousLinearEquivOfBilin /-
theorem unique_continuousLinearEquivOfBilin (coercive : IsCoercive B) {v f : V}
    (is_lax_milgram : ∀ w, ⟪f, w⟫_ℝ = B v w) : f = coercive.continuousLinearEquivOfBilin v :=
  unique_continuousLinearMapOfBilin ℝ B is_lax_milgram
#align is_coercive.unique_continuous_linear_equiv_of_bilin IsCoercive.unique_continuousLinearEquivOfBilin
-/

end IsCoercive

