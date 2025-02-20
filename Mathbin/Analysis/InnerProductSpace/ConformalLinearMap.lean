/-
Copyright (c) 2021 Yourong Zang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yourong Zang

! This file was ported from Lean 3 source module analysis.inner_product_space.conformal_linear_map
! leanprover-community/mathlib commit 0b7c740e25651db0ba63648fbae9f9d6f941e31b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.ConformalLinearMap
import Mathbin.Analysis.InnerProductSpace.Basic

/-!
# Conformal maps between inner product spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In an inner product space, a map is conformal iff it preserves inner products up to a scalar factor.
-/


variable {E F : Type _}

variable [NormedAddCommGroup E] [NormedAddCommGroup F]

variable [InnerProductSpace ℝ E] [InnerProductSpace ℝ F]

open LinearIsometry ContinuousLinearMap

open scoped RealInnerProductSpace

#print isConformalMap_iff /-
/-- A map between two inner product spaces is a conformal map if and only if it preserves inner
products up to a scalar factor, i.e., there exists a positive `c : ℝ` such that `⟪f u, f v⟫ = c *
⟪u, v⟫` for all `u`, `v`. -/
theorem isConformalMap_iff (f : E →L[ℝ] F) :
    IsConformalMap f ↔ ∃ c : ℝ, 0 < c ∧ ∀ u v : E, ⟪f u, f v⟫ = c * ⟪u, v⟫ :=
  by
  constructor
  · rintro ⟨c₁, hc₁, li, rfl⟩
    refine' ⟨c₁ * c₁, mul_self_pos.2 hc₁, fun u v => _⟩
    simp only [real_inner_smul_left, real_inner_smul_right, mul_assoc, coe_smul',
      coe_to_continuous_linear_map, Pi.smul_apply, inner_map_map]
  · rintro ⟨c₁, hc₁, huv⟩
    obtain ⟨c, hc, rfl⟩ : ∃ c : ℝ, 0 < c ∧ c₁ = c * c
    exact ⟨Real.sqrt c₁, Real.sqrt_pos.2 hc₁, (Real.mul_self_sqrt hc₁.le).symm⟩
    refine' ⟨c, hc.ne', (c⁻¹ • f : E →ₗ[ℝ] F).isometryOfInner fun u v => _, _⟩
    ·
      simp only [real_inner_smul_left, real_inner_smul_right, huv, mul_assoc, coe_smul,
        inv_mul_cancel_left₀ hc.ne', LinearMap.smul_apply, ContinuousLinearMap.coe_coe]
    · ext1 x
      exact (smul_inv_smul₀ hc.ne' (f x)).symm
#align is_conformal_map_iff isConformalMap_iff
-/

