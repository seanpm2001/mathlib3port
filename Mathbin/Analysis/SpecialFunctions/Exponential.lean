/-
Copyright (c) 2021 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker, Eric Wieser

! This file was ported from Lean 3 source module analysis.special_functions.exponential
! leanprover-community/mathlib commit c20927220ef87bb4962ba08bf6da2ce3cf50a6dd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Exponential
import Mathbin.Analysis.Calculus.FderivAnalytic
import Mathbin.Topology.MetricSpace.CauSeqFilter

/-!
# Calculus results on exponential in a Banach algebra

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we prove basic properties about the derivative of the exponential map `exp 𝕂`
in a Banach algebra `𝔸` over a field `𝕂`. We keep them separate from the main file
`analysis/normed_space/exponential` in order to minimize dependencies.

## Main results

We prove most result for an arbitrary field `𝕂`, and then specialize to `𝕂 = ℝ` or `𝕂 = ℂ`.

### General case

- `has_strict_fderiv_at_exp_zero_of_radius_pos` : `exp 𝕂` has strict Fréchet-derivative
  `1 : 𝔸 →L[𝕂] 𝔸` at zero, as long as it converges on a neighborhood of zero
  (see also `has_strict_deriv_at_exp_zero_of_radius_pos` for the case `𝔸 = 𝕂`)
- `has_strict_fderiv_at_exp_of_lt_radius` : if `𝕂` has characteristic zero and `𝔸` is commutative,
  then given a point `x` in the disk of convergence, `exp 𝕂` has strict Fréchet-derivative
  `exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸` at x (see also `has_strict_deriv_at_exp_of_lt_radius` for the case
  `𝔸 = 𝕂`)
- `has_strict_fderiv_at_exp_smul_const_of_mem_ball`: even when `𝔸` is non-commutative, if we have
  an intermediate algebra `𝕊` which is commutative, then the function `(u : 𝕊) ↦ exp 𝕂 (u • x)`,
  still has strict Fréchet-derivative `exp 𝕂 (t • x) • (1 : 𝕊 →L[𝕂] 𝕊).smul_right x` at `t` if
  `t • x` is in the radius of convergence.

### `𝕂 = ℝ` or `𝕂 = ℂ`

- `has_strict_fderiv_at_exp_zero` : `exp 𝕂` has strict Fréchet-derivative `1 : 𝔸 →L[𝕂] 𝔸` at zero
  (see also `has_strict_deriv_at_exp_zero` for the case `𝔸 = 𝕂`)
- `has_strict_fderiv_at_exp` : if `𝔸` is commutative, then given any point `x`, `exp 𝕂` has strict
  Fréchet-derivative `exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸` at x (see also `has_strict_deriv_at_exp` for the
  case `𝔸 = 𝕂`)
- `has_strict_fderiv_at_exp_smul_const`: even when `𝔸` is non-commutative, if we have
  an intermediate algebra `𝕊` which is commutative, then the function `(u : 𝕊) ↦ exp 𝕂 (u • x)`
  still has strict Fréchet-derivative `exp 𝕂 (t • x) • (1 : 𝔸 →L[𝕂] 𝔸).smul_right x` at `t`.

### Compatibilty with `real.exp` and `complex.exp`

- `complex.exp_eq_exp_ℂ` : `complex.exp = exp ℂ ℂ`
- `real.exp_eq_exp_ℝ` : `real.exp = exp ℝ ℝ`

-/


open Filter IsROrC ContinuousMultilinearMap NormedField Asymptotics

open scoped Nat Topology BigOperators ENNReal

section AnyFieldAnyAlgebra

variable {𝕂 𝔸 : Type _} [NontriviallyNormedField 𝕂] [NormedRing 𝔸] [NormedAlgebra 𝕂 𝔸]
  [CompleteSpace 𝔸]

#print hasStrictFDerivAt_exp_zero_of_radius_pos /-
/-- The exponential in a Banach-algebra `𝔸` over a normed field `𝕂` has strict Fréchet-derivative
`1 : 𝔸 →L[𝕂] 𝔸` at zero, as long as it converges on a neighborhood of zero. -/
theorem hasStrictFDerivAt_exp_zero_of_radius_pos (h : 0 < (expSeries 𝕂 𝔸).radius) :
    HasStrictFDerivAt (exp 𝕂) (1 : 𝔸 →L[𝕂] 𝔸) 0 :=
  by
  convert (hasFPowerSeriesAt_exp_zero_of_radius_pos h).HasStrictFDerivAt
  ext x
  change x = expSeries 𝕂 𝔸 1 fun _ => x
  simp [expSeries_apply_eq]
#align has_strict_fderiv_at_exp_zero_of_radius_pos hasStrictFDerivAt_exp_zero_of_radius_pos
-/

#print hasFDerivAt_exp_zero_of_radius_pos /-
/-- The exponential in a Banach-algebra `𝔸` over a normed field `𝕂` has Fréchet-derivative
`1 : 𝔸 →L[𝕂] 𝔸` at zero, as long as it converges on a neighborhood of zero. -/
theorem hasFDerivAt_exp_zero_of_radius_pos (h : 0 < (expSeries 𝕂 𝔸).radius) :
    HasFDerivAt (exp 𝕂) (1 : 𝔸 →L[𝕂] 𝔸) 0 :=
  (hasStrictFDerivAt_exp_zero_of_radius_pos h).HasFDerivAt
#align has_fderiv_at_exp_zero_of_radius_pos hasFDerivAt_exp_zero_of_radius_pos
-/

end AnyFieldAnyAlgebra

section AnyFieldCommAlgebra

variable {𝕂 𝔸 : Type _} [NontriviallyNormedField 𝕂] [NormedCommRing 𝔸] [NormedAlgebra 𝕂 𝔸]
  [CompleteSpace 𝔸]

#print hasFDerivAt_exp_of_mem_ball /-
/-- The exponential map in a commutative Banach-algebra `𝔸` over a normed field `𝕂` of
characteristic zero has Fréchet-derivative `exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸` at any point `x` in the
disk of convergence. -/
theorem hasFDerivAt_exp_of_mem_ball [CharZero 𝕂] {x : 𝔸}
    (hx : x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasFDerivAt (exp 𝕂) (exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸) x :=
  by
  have hpos : 0 < (expSeries 𝕂 𝔸).radius := (zero_le _).trans_lt hx
  rw [hasFDerivAt_iff_isLittleO_nhds_zero]
  suffices
    (fun h => exp 𝕂 x * (exp 𝕂 (0 + h) - exp 𝕂 0 - ContinuousLinearMap.id 𝕂 𝔸 h)) =ᶠ[𝓝 0] fun h =>
      exp 𝕂 (x + h) - exp 𝕂 x - exp 𝕂 x • ContinuousLinearMap.id 𝕂 𝔸 h
    by
    refine' (is_o.const_mul_left _ _).congr' this (eventually_eq.refl _ _)
    rw [← hasFDerivAt_iff_isLittleO_nhds_zero]
    exact hasFDerivAt_exp_zero_of_radius_pos hpos
  have : ∀ᶠ h in 𝓝 (0 : 𝔸), h ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius :=
    EMetric.ball_mem_nhds _ hpos
  filter_upwards [this] with _ hh
  rw [exp_add_of_mem_ball hx hh, exp_zero, zero_add, ContinuousLinearMap.id_apply, smul_eq_mul]
  ring
#align has_fderiv_at_exp_of_mem_ball hasFDerivAt_exp_of_mem_ball
-/

#print hasStrictFDerivAt_exp_of_mem_ball /-
/-- The exponential map in a commutative Banach-algebra `𝔸` over a normed field `𝕂` of
characteristic zero has strict Fréchet-derivative `exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸` at any point `x` in
the disk of convergence. -/
theorem hasStrictFDerivAt_exp_of_mem_ball [CharZero 𝕂] {x : 𝔸}
    (hx : x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasStrictFDerivAt (exp 𝕂) (exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸) x :=
  let ⟨p, hp⟩ := analyticAt_exp_of_mem_ball x hx
  hp.HasFDerivAt.unique (hasFDerivAt_exp_of_mem_ball hx) ▸ hp.HasStrictFDerivAt
#align has_strict_fderiv_at_exp_of_mem_ball hasStrictFDerivAt_exp_of_mem_ball
-/

end AnyFieldCommAlgebra

section deriv

variable {𝕂 : Type _} [NontriviallyNormedField 𝕂] [CompleteSpace 𝕂]

#print hasStrictDerivAt_exp_of_mem_ball /-
/-- The exponential map in a complete normed field `𝕂` of characteristic zero has strict derivative
`exp 𝕂 x` at any point `x` in the disk of convergence. -/
theorem hasStrictDerivAt_exp_of_mem_ball [CharZero 𝕂] {x : 𝕂}
    (hx : x ∈ EMetric.ball (0 : 𝕂) (expSeries 𝕂 𝕂).radius) : HasStrictDerivAt (exp 𝕂) (exp 𝕂 x) x :=
  by simpa using (hasStrictFDerivAt_exp_of_mem_ball hx).HasStrictDerivAt
#align has_strict_deriv_at_exp_of_mem_ball hasStrictDerivAt_exp_of_mem_ball
-/

#print hasDerivAt_exp_of_mem_ball /-
/-- The exponential map in a complete normed field `𝕂` of characteristic zero has derivative
`exp 𝕂 x` at any point `x` in the disk of convergence. -/
theorem hasDerivAt_exp_of_mem_ball [CharZero 𝕂] {x : 𝕂}
    (hx : x ∈ EMetric.ball (0 : 𝕂) (expSeries 𝕂 𝕂).radius) : HasDerivAt (exp 𝕂) (exp 𝕂 x) x :=
  (hasStrictDerivAt_exp_of_mem_ball hx).HasDerivAt
#align has_deriv_at_exp_of_mem_ball hasDerivAt_exp_of_mem_ball
-/

#print hasStrictDerivAt_exp_zero_of_radius_pos /-
/-- The exponential map in a complete normed field `𝕂` of characteristic zero has strict derivative
`1` at zero, as long as it converges on a neighborhood of zero. -/
theorem hasStrictDerivAt_exp_zero_of_radius_pos (h : 0 < (expSeries 𝕂 𝕂).radius) :
    HasStrictDerivAt (exp 𝕂) (1 : 𝕂) 0 :=
  (hasStrictFDerivAt_exp_zero_of_radius_pos h).HasStrictDerivAt
#align has_strict_deriv_at_exp_zero_of_radius_pos hasStrictDerivAt_exp_zero_of_radius_pos
-/

#print hasDerivAt_exp_zero_of_radius_pos /-
/-- The exponential map in a complete normed field `𝕂` of characteristic zero has derivative
`1` at zero, as long as it converges on a neighborhood of zero. -/
theorem hasDerivAt_exp_zero_of_radius_pos (h : 0 < (expSeries 𝕂 𝕂).radius) :
    HasDerivAt (exp 𝕂) (1 : 𝕂) 0 :=
  (hasStrictDerivAt_exp_zero_of_radius_pos h).HasDerivAt
#align has_deriv_at_exp_zero_of_radius_pos hasDerivAt_exp_zero_of_radius_pos
-/

end deriv

section IsROrCAnyAlgebra

variable {𝕂 𝔸 : Type _} [IsROrC 𝕂] [NormedRing 𝔸] [NormedAlgebra 𝕂 𝔸] [CompleteSpace 𝔸]

#print hasStrictFDerivAt_exp_zero /-
/-- The exponential in a Banach-algebra `𝔸` over `𝕂 = ℝ` or `𝕂 = ℂ` has strict Fréchet-derivative
`1 : 𝔸 →L[𝕂] 𝔸` at zero. -/
theorem hasStrictFDerivAt_exp_zero : HasStrictFDerivAt (exp 𝕂) (1 : 𝔸 →L[𝕂] 𝔸) 0 :=
  hasStrictFDerivAt_exp_zero_of_radius_pos (expSeries_radius_pos 𝕂 𝔸)
#align has_strict_fderiv_at_exp_zero hasStrictFDerivAt_exp_zero
-/

#print hasFDerivAt_exp_zero /-
/-- The exponential in a Banach-algebra `𝔸` over `𝕂 = ℝ` or `𝕂 = ℂ` has Fréchet-derivative
`1 : 𝔸 →L[𝕂] 𝔸` at zero. -/
theorem hasFDerivAt_exp_zero : HasFDerivAt (exp 𝕂) (1 : 𝔸 →L[𝕂] 𝔸) 0 :=
  hasStrictFDerivAt_exp_zero.HasFDerivAt
#align has_fderiv_at_exp_zero hasFDerivAt_exp_zero
-/

end IsROrCAnyAlgebra

section IsROrCCommAlgebra

variable {𝕂 𝔸 : Type _} [IsROrC 𝕂] [NormedCommRing 𝔸] [NormedAlgebra 𝕂 𝔸] [CompleteSpace 𝔸]

#print hasStrictFDerivAt_exp /-
/-- The exponential map in a commutative Banach-algebra `𝔸` over `𝕂 = ℝ` or `𝕂 = ℂ` has strict
Fréchet-derivative `exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸` at any point `x`. -/
theorem hasStrictFDerivAt_exp {x : 𝔸} : HasStrictFDerivAt (exp 𝕂) (exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸) x :=
  hasStrictFDerivAt_exp_of_mem_ball ((expSeries_radius_eq_top 𝕂 𝔸).symm ▸ edist_lt_top _ _)
#align has_strict_fderiv_at_exp hasStrictFDerivAt_exp
-/

#print hasFDerivAt_exp /-
/-- The exponential map in a commutative Banach-algebra `𝔸` over `𝕂 = ℝ` or `𝕂 = ℂ` has
Fréchet-derivative `exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸` at any point `x`. -/
theorem hasFDerivAt_exp {x : 𝔸} : HasFDerivAt (exp 𝕂) (exp 𝕂 x • 1 : 𝔸 →L[𝕂] 𝔸) x :=
  hasStrictFDerivAt_exp.HasFDerivAt
#align has_fderiv_at_exp hasFDerivAt_exp
-/

end IsROrCCommAlgebra

section DerivROrC

variable {𝕂 : Type _} [IsROrC 𝕂]

#print hasStrictDerivAt_exp /-
/-- The exponential map in `𝕂 = ℝ` or `𝕂 = ℂ` has strict derivative `exp 𝕂 x` at any point
`x`. -/
theorem hasStrictDerivAt_exp {x : 𝕂} : HasStrictDerivAt (exp 𝕂) (exp 𝕂 x) x :=
  hasStrictDerivAt_exp_of_mem_ball ((expSeries_radius_eq_top 𝕂 𝕂).symm ▸ edist_lt_top _ _)
#align has_strict_deriv_at_exp hasStrictDerivAt_exp
-/

#print hasDerivAt_exp /-
/-- The exponential map in `𝕂 = ℝ` or `𝕂 = ℂ` has derivative `exp 𝕂 x` at any point `x`. -/
theorem hasDerivAt_exp {x : 𝕂} : HasDerivAt (exp 𝕂) (exp 𝕂 x) x :=
  hasStrictDerivAt_exp.HasDerivAt
#align has_deriv_at_exp hasDerivAt_exp
-/

#print hasStrictDerivAt_exp_zero /-
/-- The exponential map in `𝕂 = ℝ` or `𝕂 = ℂ` has strict derivative `1` at zero. -/
theorem hasStrictDerivAt_exp_zero : HasStrictDerivAt (exp 𝕂) (1 : 𝕂) 0 :=
  hasStrictDerivAt_exp_zero_of_radius_pos (expSeries_radius_pos 𝕂 𝕂)
#align has_strict_deriv_at_exp_zero hasStrictDerivAt_exp_zero
-/

#print hasDerivAt_exp_zero /-
/-- The exponential map in `𝕂 = ℝ` or `𝕂 = ℂ` has derivative `1` at zero. -/
theorem hasDerivAt_exp_zero : HasDerivAt (exp 𝕂) (1 : 𝕂) 0 :=
  hasStrictDerivAt_exp_zero.HasDerivAt
#align has_deriv_at_exp_zero hasDerivAt_exp_zero
-/

end DerivROrC

#print Complex.exp_eq_exp_ℂ /-
theorem Complex.exp_eq_exp_ℂ : Complex.exp = exp ℂ :=
  by
  refine' funext fun x => _
  rw [Complex.exp, exp_eq_tsum_div]
  exact tendsto_nhds_unique x.exp'.tendsto_limit (expSeries_div_summable ℝ x).HasSum.tendsto_sum_nat
#align complex.exp_eq_exp_ℂ Complex.exp_eq_exp_ℂ
-/

#print Real.exp_eq_exp_ℝ /-
theorem Real.exp_eq_exp_ℝ : Real.exp = exp ℝ := by ext x;
  exact_mod_cast congr_fun Complex.exp_eq_exp_ℂ x
#align real.exp_eq_exp_ℝ Real.exp_eq_exp_ℝ
-/

/-! ### Derivative of $\exp (ux)$ by $u$

Note that since for `x : 𝔸` we have `normed_ring 𝔸` not `normed_comm_ring 𝔸`, we cannot deduce
these results from `has_fderiv_at_exp_of_mem_ball` applied to the algebra `𝔸`.

One possible solution for that would be to apply `has_fderiv_at_exp_of_mem_ball` to the
commutative algebra `algebra.elemental_algebra 𝕊 x`. Unfortunately we don't have all the required
API, so we leave that to a future refactor (see leanprover-community/mathlib#19062 for discussion).

We could also go the other way around and deduce `has_fderiv_at_exp_of_mem_ball` from
`has_fderiv_at_exp_smul_const_of_mem_ball` applied to `𝕊 := 𝔸`, `x := (1 : 𝔸)`, and `t := x`.
However, doing so would make the aformentioned `elemental_algebra` refactor harder, so for now we
just prove these two lemmas independently.

A last strategy would be to deduce everything from the more general non-commutative case,
$$\frac{d}{dt}e^{x(t)} = \int_0^1 e^{sx(t)} \left(\frac{d}{dt}e^{x(t)}\right) e^{(1-s)x(t)} ds$$
but this is harder to prove, and typically is shown by going via these results first.

TODO: prove this result too!
-/


section exp_smul

variable {𝕂 𝕊 𝔸 : Type _}

variable (𝕂)

open scoped Topology

open Asymptotics Filter

section MemBall

variable [NontriviallyNormedField 𝕂] [CharZero 𝕂]

variable [NormedCommRing 𝕊] [NormedRing 𝔸]

variable [NormedSpace 𝕂 𝕊] [NormedAlgebra 𝕂 𝔸] [Algebra 𝕊 𝔸] [ContinuousSMul 𝕊 𝔸]

variable [IsScalarTower 𝕂 𝕊 𝔸]

variable [CompleteSpace 𝔸]

#print hasFDerivAt_exp_smul_const_of_mem_ball /-
theorem hasFDerivAt_exp_smul_const_of_mem_ball (x : 𝔸) (t : 𝕊)
    (htx : t • x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x)) (exp 𝕂 (t • x) • (1 : 𝕊 →L[𝕂] 𝕊).smul_right x) t :=
  by
  -- TODO: prove this via `has_fderiv_at_exp_of_mem_ball` using the commutative ring
  -- `algebra.elemental_algebra 𝕊 x`. See leanprover-community/mathlib#19062 for discussion.
  have hpos : 0 < (expSeries 𝕂 𝔸).radius := (zero_le _).trans_lt htx
  rw [hasFDerivAt_iff_isLittleO_nhds_zero]
  suffices
    (fun h =>
        exp 𝕂 (t • x) *
          (exp 𝕂 ((0 + h) • x) - exp 𝕂 ((0 : 𝕊) • x) - ((1 : 𝕊 →L[𝕂] 𝕊).smul_right x) h)) =ᶠ[𝓝 0]
      fun h =>
      exp 𝕂 ((t + h) • x) - exp 𝕂 (t • x) - (exp 𝕂 (t • x) • (1 : 𝕊 →L[𝕂] 𝕊).smul_right x) h
    by
    refine' (is_o.const_mul_left _ _).congr' this (eventually_eq.refl _ _)
    rw [←
      @hasFDerivAt_iff_isLittleO_nhds_zero _ _ _ _ _ _ _ _ (fun u => exp 𝕂 (u • x))
        ((1 : 𝕊 →L[𝕂] 𝕊).smul_right x) 0]
    have : HasFDerivAt (exp 𝕂) (1 : 𝔸 →L[𝕂] 𝔸) ((1 : 𝕊 →L[𝕂] 𝕊).smul_right x 0) :=
      by
      rw [ContinuousLinearMap.smulRight_apply, ContinuousLinearMap.one_apply, zero_smul]
      exact hasFDerivAt_exp_zero_of_radius_pos hpos
    exact this.comp 0 ((1 : 𝕊 →L[𝕂] 𝕊).smul_right x).HasFDerivAt
  have : tendsto (fun h : 𝕊 => h • x) (𝓝 0) (𝓝 0) :=
    by
    rw [← zero_smul 𝕊 x]
    exact tendsto_id.smul_const x
  have : ∀ᶠ h in 𝓝 (0 : 𝕊), h • x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius :=
    this.eventually (EMetric.ball_mem_nhds _ hpos)
  filter_upwards [this]
  intro h hh
  have : Commute (t • x) (h • x) := ((Commute.refl x).smul_left t).smul_right h
  rw [add_smul t h, exp_add_of_commute_of_mem_ball this htx hh, zero_add, zero_smul, exp_zero,
    ContinuousLinearMap.smulRight_apply, ContinuousLinearMap.one_apply,
    ContinuousLinearMap.smul_apply, ContinuousLinearMap.smulRight_apply,
    ContinuousLinearMap.one_apply, smul_eq_mul, mul_sub_left_distrib, mul_sub_left_distrib, mul_one]
#align has_fderiv_at_exp_smul_const_of_mem_ball hasFDerivAt_exp_smul_const_of_mem_ball
-/

#print hasFDerivAt_exp_smul_const_of_mem_ball' /-
theorem hasFDerivAt_exp_smul_const_of_mem_ball' (x : 𝔸) (t : 𝕊)
    (htx : t • x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x))
      (((1 : 𝕊 →L[𝕂] 𝕊).smul_right x).smul_right (exp 𝕂 (t • x))) t :=
  by
  convert hasFDerivAt_exp_smul_const_of_mem_ball 𝕂 _ _ htx using 1
  ext t'
  show Commute (t' • x) (exp 𝕂 (t • x))
  exact (((Commute.refl x).smul_left t').smul_right t).exp_right 𝕂
#align has_fderiv_at_exp_smul_const_of_mem_ball' hasFDerivAt_exp_smul_const_of_mem_ball'
-/

#print hasStrictFDerivAt_exp_smul_const_of_mem_ball /-
theorem hasStrictFDerivAt_exp_smul_const_of_mem_ball (x : 𝔸) (t : 𝕊)
    (htx : t • x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasStrictFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x)) (exp 𝕂 (t • x) • (1 : 𝕊 →L[𝕂] 𝕊).smul_right x)
      t :=
  let ⟨p, hp⟩ := analyticAt_exp_of_mem_ball (t • x) htx
  have deriv₁ : HasStrictFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x)) _ t :=
    hp.HasStrictFDerivAt.comp t ((ContinuousLinearMap.id 𝕂 𝕊).smul_right x).HasStrictFDerivAt
  have deriv₂ : HasFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x)) _ t :=
    hasFDerivAt_exp_smul_const_of_mem_ball 𝕂 x t htx
  deriv₁.HasFDerivAt.unique deriv₂ ▸ deriv₁
#align has_strict_fderiv_at_exp_smul_const_of_mem_ball hasStrictFDerivAt_exp_smul_const_of_mem_ball
-/

#print hasStrictFDerivAt_exp_smul_const_of_mem_ball' /-
theorem hasStrictFDerivAt_exp_smul_const_of_mem_ball' (x : 𝔸) (t : 𝕊)
    (htx : t • x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasStrictFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x))
      (((1 : 𝕊 →L[𝕂] 𝕊).smul_right x).smul_right (exp 𝕂 (t • x))) t :=
  by
  let ⟨p, hp⟩ := analyticAt_exp_of_mem_ball (t • x) htx
  convert hasStrictFDerivAt_exp_smul_const_of_mem_ball 𝕂 _ _ htx using 1
  ext t'
  show Commute (t' • x) (exp 𝕂 (t • x))
  exact (((Commute.refl x).smul_left t').smul_right t).exp_right 𝕂
#align has_strict_fderiv_at_exp_smul_const_of_mem_ball' hasStrictFDerivAt_exp_smul_const_of_mem_ball'
-/

variable {𝕂}

#print hasStrictDerivAt_exp_smul_const_of_mem_ball /-
theorem hasStrictDerivAt_exp_smul_const_of_mem_ball (x : 𝔸) (t : 𝕂)
    (htx : t • x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasStrictDerivAt (fun u : 𝕂 => exp 𝕂 (u • x)) (exp 𝕂 (t • x) * x) t := by
  simpa using (hasStrictFDerivAt_exp_smul_const_of_mem_ball 𝕂 x t htx).HasStrictDerivAt
#align has_strict_deriv_at_exp_smul_const_of_mem_ball hasStrictDerivAt_exp_smul_const_of_mem_ball
-/

#print hasStrictDerivAt_exp_smul_const_of_mem_ball' /-
theorem hasStrictDerivAt_exp_smul_const_of_mem_ball' (x : 𝔸) (t : 𝕂)
    (htx : t • x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasStrictDerivAt (fun u : 𝕂 => exp 𝕂 (u • x)) (x * exp 𝕂 (t • x)) t := by
  simpa using (hasStrictFDerivAt_exp_smul_const_of_mem_ball' 𝕂 x t htx).HasStrictDerivAt
#align has_strict_deriv_at_exp_smul_const_of_mem_ball' hasStrictDerivAt_exp_smul_const_of_mem_ball'
-/

#print hasDerivAt_exp_smul_const_of_mem_ball /-
theorem hasDerivAt_exp_smul_const_of_mem_ball (x : 𝔸) (t : 𝕂)
    (htx : t • x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasDerivAt (fun u : 𝕂 => exp 𝕂 (u • x)) (exp 𝕂 (t • x) * x) t :=
  (hasStrictDerivAt_exp_smul_const_of_mem_ball x t htx).HasDerivAt
#align has_deriv_at_exp_smul_const_of_mem_ball hasDerivAt_exp_smul_const_of_mem_ball
-/

#print hasDerivAt_exp_smul_const_of_mem_ball' /-
theorem hasDerivAt_exp_smul_const_of_mem_ball' (x : 𝔸) (t : 𝕂)
    (htx : t • x ∈ EMetric.ball (0 : 𝔸) (expSeries 𝕂 𝔸).radius) :
    HasDerivAt (fun u : 𝕂 => exp 𝕂 (u • x)) (x * exp 𝕂 (t • x)) t :=
  (hasStrictDerivAt_exp_smul_const_of_mem_ball' x t htx).HasDerivAt
#align has_deriv_at_exp_smul_const_of_mem_ball' hasDerivAt_exp_smul_const_of_mem_ball'
-/

end MemBall

section IsROrC

variable [IsROrC 𝕂]

variable [NormedCommRing 𝕊] [NormedRing 𝔸]

variable [NormedAlgebra 𝕂 𝕊] [NormedAlgebra 𝕂 𝔸] [Algebra 𝕊 𝔸] [ContinuousSMul 𝕊 𝔸]

variable [IsScalarTower 𝕂 𝕊 𝔸]

variable [CompleteSpace 𝔸]

variable (𝕂)

#print hasFDerivAt_exp_smul_const /-
theorem hasFDerivAt_exp_smul_const (x : 𝔸) (t : 𝕊) :
    HasFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x)) (exp 𝕂 (t • x) • (1 : 𝕊 →L[𝕂] 𝕊).smul_right x) t :=
  hasFDerivAt_exp_smul_const_of_mem_ball 𝕂 _ _ <|
    (expSeries_radius_eq_top 𝕂 𝔸).symm ▸ edist_lt_top _ _
#align has_fderiv_at_exp_smul_const hasFDerivAt_exp_smul_const
-/

#print hasFDerivAt_exp_smul_const' /-
theorem hasFDerivAt_exp_smul_const' (x : 𝔸) (t : 𝕊) :
    HasFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x))
      (((1 : 𝕊 →L[𝕂] 𝕊).smul_right x).smul_right (exp 𝕂 (t • x))) t :=
  hasFDerivAt_exp_smul_const_of_mem_ball' 𝕂 _ _ <|
    (expSeries_radius_eq_top 𝕂 𝔸).symm ▸ edist_lt_top _ _
#align has_fderiv_at_exp_smul_const' hasFDerivAt_exp_smul_const'
-/

#print hasStrictFDerivAt_exp_smul_const /-
theorem hasStrictFDerivAt_exp_smul_const (x : 𝔸) (t : 𝕊) :
    HasStrictFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x)) (exp 𝕂 (t • x) • (1 : 𝕊 →L[𝕂] 𝕊).smul_right x)
      t :=
  hasStrictFDerivAt_exp_smul_const_of_mem_ball 𝕂 _ _ <|
    (expSeries_radius_eq_top 𝕂 𝔸).symm ▸ edist_lt_top _ _
#align has_strict_fderiv_at_exp_smul_const hasStrictFDerivAt_exp_smul_const
-/

#print hasStrictFDerivAt_exp_smul_const' /-
theorem hasStrictFDerivAt_exp_smul_const' (x : 𝔸) (t : 𝕊) :
    HasStrictFDerivAt (fun u : 𝕊 => exp 𝕂 (u • x))
      (((1 : 𝕊 →L[𝕂] 𝕊).smul_right x).smul_right (exp 𝕂 (t • x))) t :=
  hasStrictFDerivAt_exp_smul_const_of_mem_ball' 𝕂 _ _ <|
    (expSeries_radius_eq_top 𝕂 𝔸).symm ▸ edist_lt_top _ _
#align has_strict_fderiv_at_exp_smul_const' hasStrictFDerivAt_exp_smul_const'
-/

variable {𝕂}

#print hasStrictDerivAt_exp_smul_const /-
theorem hasStrictDerivAt_exp_smul_const (x : 𝔸) (t : 𝕂) :
    HasStrictDerivAt (fun u : 𝕂 => exp 𝕂 (u • x)) (exp 𝕂 (t • x) * x) t :=
  hasStrictDerivAt_exp_smul_const_of_mem_ball _ _ <|
    (expSeries_radius_eq_top 𝕂 𝔸).symm ▸ edist_lt_top _ _
#align has_strict_deriv_at_exp_smul_const hasStrictDerivAt_exp_smul_const
-/

#print hasStrictDerivAt_exp_smul_const' /-
theorem hasStrictDerivAt_exp_smul_const' (x : 𝔸) (t : 𝕂) :
    HasStrictDerivAt (fun u : 𝕂 => exp 𝕂 (u • x)) (x * exp 𝕂 (t • x)) t :=
  hasStrictDerivAt_exp_smul_const_of_mem_ball' _ _ <|
    (expSeries_radius_eq_top 𝕂 𝔸).symm ▸ edist_lt_top _ _
#align has_strict_deriv_at_exp_smul_const' hasStrictDerivAt_exp_smul_const'
-/

#print hasDerivAt_exp_smul_const /-
theorem hasDerivAt_exp_smul_const (x : 𝔸) (t : 𝕂) :
    HasDerivAt (fun u : 𝕂 => exp 𝕂 (u • x)) (exp 𝕂 (t • x) * x) t :=
  hasDerivAt_exp_smul_const_of_mem_ball _ _ <| (expSeries_radius_eq_top 𝕂 𝔸).symm ▸ edist_lt_top _ _
#align has_deriv_at_exp_smul_const hasDerivAt_exp_smul_const
-/

#print hasDerivAt_exp_smul_const' /-
theorem hasDerivAt_exp_smul_const' (x : 𝔸) (t : 𝕂) :
    HasDerivAt (fun u : 𝕂 => exp 𝕂 (u • x)) (x * exp 𝕂 (t • x)) t :=
  hasDerivAt_exp_smul_const_of_mem_ball' _ _ <|
    (expSeries_radius_eq_top 𝕂 𝔸).symm ▸ edist_lt_top _ _
#align has_deriv_at_exp_smul_const' hasDerivAt_exp_smul_const'
-/

end IsROrC

end exp_smul

