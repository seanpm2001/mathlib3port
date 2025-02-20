/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.parametric_interval_integral
! leanprover-community/mathlib commit 7e5137f579de09a059a5ce98f364a04e221aabf0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.ParametricIntegral
import Mathbin.MeasureTheory.Integral.IntervalIntegral

/-!
# Derivatives of interval integrals depending on parameters

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we restate theorems about derivatives of integrals depending on parameters for interval
integrals.  -/


open TopologicalSpace MeasureTheory Filter Metric

open scoped Topology Filter Interval

variable {𝕜 : Type _} [IsROrC 𝕜] {μ : Measure ℝ} {E : Type _} [NormedAddCommGroup E]
  [NormedSpace ℝ E] [NormedSpace 𝕜 E] [CompleteSpace E] {H : Type _} [NormedAddCommGroup H]
  [NormedSpace 𝕜 H] {a b ε : ℝ} {bound : ℝ → ℝ}

namespace intervalIntegral

#print intervalIntegral.hasFDerivAt_integral_of_dominated_loc_of_lip /-
/-- Differentiation under integral of `x ↦ ∫ t in a..b, F x t` at a given point `x₀`, assuming
`F x₀` is integrable, `x ↦ F x a` is locally Lipschitz on a ball around `x₀` for ae `a`
(with a ball radius independent of `a`) with integrable Lipschitz bound, and `F x` is ae-measurable
for `x` in a possibly smaller neighborhood of `x₀`. -/
theorem hasFDerivAt_integral_of_dominated_loc_of_lip {F : H → ℝ → E} {F' : ℝ → H →L[𝕜] E} {x₀ : H}
    (ε_pos : 0 < ε) (hF_meas : ∀ᶠ x in 𝓝 x₀, AEStronglyMeasurable (F x) (μ.restrict (Ι a b)))
    (hF_int : IntervalIntegrable (F x₀) μ a b)
    (hF'_meas : AEStronglyMeasurable F' (μ.restrict (Ι a b)))
    (h_lip :
      ∀ᵐ t ∂μ, t ∈ Ι a b → LipschitzOnWith (Real.nnabs <| bound t) (fun x => F x t) (ball x₀ ε))
    (bound_integrable : IntervalIntegrable bound μ a b)
    (h_diff : ∀ᵐ t ∂μ, t ∈ Ι a b → HasFDerivAt (fun x => F x t) (F' t) x₀) :
    IntervalIntegrable F' μ a b ∧
      HasFDerivAt (fun x => ∫ t in a..b, F x t ∂μ) (∫ t in a..b, F' t ∂μ) x₀ :=
  by
  simp only [intervalIntegrable_iff, interval_integral_eq_integral_uIoc, ←
    ae_restrict_iff' measurableSet_uIoc] at *
  have :=
    hasFDerivAt_integral_of_dominated_loc_of_lip ε_pos hF_meas hF_int hF'_meas h_lip
      bound_integrable h_diff
  exact ⟨this.1, this.2.const_smul _⟩
#align interval_integral.has_fderiv_at_integral_of_dominated_loc_of_lip intervalIntegral.hasFDerivAt_integral_of_dominated_loc_of_lip
-/

#print intervalIntegral.hasFDerivAt_integral_of_dominated_of_fderiv_le /-
/-- Differentiation under integral of `x ↦ ∫ F x a` at a given point `x₀`, assuming
`F x₀` is integrable, `x ↦ F x a` is differentiable on a ball around `x₀` for ae `a` with
derivative norm uniformly bounded by an integrable function (the ball radius is independent of `a`),
and `F x` is ae-measurable for `x` in a possibly smaller neighborhood of `x₀`. -/
theorem hasFDerivAt_integral_of_dominated_of_fderiv_le {F : H → ℝ → E} {F' : H → ℝ → H →L[𝕜] E}
    {x₀ : H} (ε_pos : 0 < ε)
    (hF_meas : ∀ᶠ x in 𝓝 x₀, AEStronglyMeasurable (F x) (μ.restrict (Ι a b)))
    (hF_int : IntervalIntegrable (F x₀) μ a b)
    (hF'_meas : AEStronglyMeasurable (F' x₀) (μ.restrict (Ι a b)))
    (h_bound : ∀ᵐ t ∂μ, t ∈ Ι a b → ∀ x ∈ ball x₀ ε, ‖F' x t‖ ≤ bound t)
    (bound_integrable : IntervalIntegrable bound μ a b)
    (h_diff : ∀ᵐ t ∂μ, t ∈ Ι a b → ∀ x ∈ ball x₀ ε, HasFDerivAt (fun x => F x t) (F' x t) x) :
    HasFDerivAt (fun x => ∫ t in a..b, F x t ∂μ) (∫ t in a..b, F' x₀ t ∂μ) x₀ :=
  by
  simp only [intervalIntegrable_iff, interval_integral_eq_integral_uIoc, ←
    ae_restrict_iff' measurableSet_uIoc] at *
  exact
    (hasFDerivAt_integral_of_dominated_of_fderiv_le ε_pos hF_meas hF_int hF'_meas h_bound
          bound_integrable h_diff).const_smul
      _
#align interval_integral.has_fderiv_at_integral_of_dominated_of_fderiv_le intervalIntegral.hasFDerivAt_integral_of_dominated_of_fderiv_le
-/

#print intervalIntegral.hasDerivAt_integral_of_dominated_loc_of_lip /-
/-- Derivative under integral of `x ↦ ∫ F x a` at a given point `x₀ : 𝕜`, `𝕜 = ℝ` or `𝕜 = ℂ`,
assuming `F x₀` is integrable, `x ↦ F x a` is locally Lipschitz on a ball around `x₀` for ae `a`
(with ball radius independent of `a`) with integrable Lipschitz bound, and `F x` is
ae-measurable for `x` in a possibly smaller neighborhood of `x₀`. -/
theorem hasDerivAt_integral_of_dominated_loc_of_lip {F : 𝕜 → ℝ → E} {F' : ℝ → E} {x₀ : 𝕜}
    (ε_pos : 0 < ε) (hF_meas : ∀ᶠ x in 𝓝 x₀, AEStronglyMeasurable (F x) (μ.restrict (Ι a b)))
    (hF_int : IntervalIntegrable (F x₀) μ a b)
    (hF'_meas : AEStronglyMeasurable F' (μ.restrict (Ι a b)))
    (h_lipsch :
      ∀ᵐ t ∂μ, t ∈ Ι a b → LipschitzOnWith (Real.nnabs <| bound t) (fun x => F x t) (ball x₀ ε))
    (bound_integrable : IntervalIntegrable (bound : ℝ → ℝ) μ a b)
    (h_diff : ∀ᵐ t ∂μ, t ∈ Ι a b → HasDerivAt (fun x => F x t) (F' t) x₀) :
    IntervalIntegrable F' μ a b ∧
      HasDerivAt (fun x => ∫ t in a..b, F x t ∂μ) (∫ t in a..b, F' t ∂μ) x₀ :=
  by
  simp only [intervalIntegrable_iff, interval_integral_eq_integral_uIoc, ←
    ae_restrict_iff' measurableSet_uIoc] at *
  have :=
    hasDerivAt_integral_of_dominated_loc_of_lip ε_pos hF_meas hF_int hF'_meas h_lipsch
      bound_integrable h_diff
  exact ⟨this.1, this.2.const_smul _⟩
#align interval_integral.has_deriv_at_integral_of_dominated_loc_of_lip intervalIntegral.hasDerivAt_integral_of_dominated_loc_of_lip
-/

#print intervalIntegral.hasDerivAt_integral_of_dominated_loc_of_deriv_le /-
/-- Derivative under integral of `x ↦ ∫ F x a` at a given point `x₀ : 𝕜`, `𝕜 = ℝ` or `𝕜 = ℂ`,
assuming `F x₀` is integrable, `x ↦ F x a` is differentiable on an interval around `x₀` for ae `a`
(with interval radius independent of `a`) with derivative uniformly bounded by an integrable
function, and `F x` is ae-measurable for `x` in a possibly smaller neighborhood of `x₀`. -/
theorem hasDerivAt_integral_of_dominated_loc_of_deriv_le {F : 𝕜 → ℝ → E} {F' : 𝕜 → ℝ → E} {x₀ : 𝕜}
    (ε_pos : 0 < ε) (hF_meas : ∀ᶠ x in 𝓝 x₀, AEStronglyMeasurable (F x) (μ.restrict (Ι a b)))
    (hF_int : IntervalIntegrable (F x₀) μ a b)
    (hF'_meas : AEStronglyMeasurable (F' x₀) (μ.restrict (Ι a b)))
    (h_bound : ∀ᵐ t ∂μ, t ∈ Ι a b → ∀ x ∈ ball x₀ ε, ‖F' x t‖ ≤ bound t)
    (bound_integrable : IntervalIntegrable bound μ a b)
    (h_diff : ∀ᵐ t ∂μ, t ∈ Ι a b → ∀ x ∈ ball x₀ ε, HasDerivAt (fun x => F x t) (F' x t) x) :
    IntervalIntegrable (F' x₀) μ a b ∧
      HasDerivAt (fun x => ∫ t in a..b, F x t ∂μ) (∫ t in a..b, F' x₀ t ∂μ) x₀ :=
  by
  simp only [intervalIntegrable_iff, interval_integral_eq_integral_uIoc, ←
    ae_restrict_iff' measurableSet_uIoc] at *
  have :=
    hasDerivAt_integral_of_dominated_loc_of_deriv_le ε_pos hF_meas hF_int hF'_meas h_bound
      bound_integrable h_diff
  exact ⟨this.1, this.2.const_smul _⟩
#align interval_integral.has_deriv_at_integral_of_dominated_loc_of_deriv_le intervalIntegral.hasDerivAt_integral_of_dominated_loc_of_deriv_le
-/

end intervalIntegral

