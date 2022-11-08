/-
Copyright (c) 2020 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Floris van Doorn
-/
import Mathbin.Analysis.Calculus.IteratedDeriv
import Mathbin.Analysis.InnerProductSpace.EuclideanDist
import Mathbin.MeasureTheory.Function.LocallyIntegrable
import Mathbin.MeasureTheory.Integral.SetIntegral

/-!
# Infinitely smooth bump function

In this file we construct several infinitely smooth functions with properties that an analytic
function cannot have:

* `exp_neg_inv_glue` is equal to zero for `x ≤ 0` and is strictly positive otherwise; it is given by
  `x ↦ exp (-1/x)` for `x > 0`;

* `real.smooth_transition` is equal to zero for `x ≤ 0` and is equal to one for `x ≥ 1`; it is given
  by `exp_neg_inv_glue x / (exp_neg_inv_glue x + exp_neg_inv_glue (1 - x))`;

* `f : cont_diff_bump_of_inner c`, where `c` is a point in an inner product space, is
  a bundled smooth function such that

  - `f` is equal to `1` in `metric.closed_ball c f.r`;
  - `support f = metric.ball c f.R`;
  - `0 ≤ f x ≤ 1` for all `x`.

  The structure `cont_diff_bump_of_inner` contains the data required to construct the
  function: real numbers `r`, `R`, and proofs of `0 < r < R`. The function itself is available
  through `coe_fn`.

* If `f : cont_diff_bump_of_inner c` and `μ` is a measure on the domain of `f`, then `f.normed μ`
  is a smooth bump function with integral `1` w.r.t. `μ`.

* `f : cont_diff_bump c`, where `c` is a point in a finite dimensional real vector space, is a
  bundled smooth function such that

  - `f` is equal to `1` in `euclidean.closed_ball c f.r`;
  - `support f = euclidean.ball c f.R`;
  - `0 ≤ f x ≤ 1` for all `x`.

  The structure `cont_diff_bump` contains the data required to construct the function: real
  numbers `r`, `R`, and proofs of `0 < r < R`. The function itself is available through `coe_fn`.
-/


noncomputable section

open Classical TopologicalSpace

open Polynomial Real Filter Set Function

open Polynomial

/-- `exp_neg_inv_glue` is the real function given by `x ↦ exp (-1/x)` for `x > 0` and `0`
for `x ≤ 0`. It is a basic building block to construct smooth partitions of unity. Its main property
is that it vanishes for `x ≤ 0`, it is positive for `x > 0`, and the junction between the two
behaviors is flat enough to retain smoothness. The fact that this function is `C^∞` is proved in
`exp_neg_inv_glue.smooth`. -/
def expNegInvGlue (x : ℝ) : ℝ :=
  if x ≤ 0 then 0 else exp (-x⁻¹)

namespace expNegInvGlue

/-- Our goal is to prove that `exp_neg_inv_glue` is `C^∞`. For this, we compute its successive
derivatives for `x > 0`. The `n`-th derivative is of the form `P_aux n (x) exp(-1/x) / x^(2 n)`,
where `P_aux n` is computed inductively. -/
noncomputable def pAux : ℕ → ℝ[X]
  | 0 => 1
  | n + 1 => X ^ 2 * (P_aux n).derivative + (1 - c ↑(2 * n) * X) * P_aux n

/-- Formula for the `n`-th derivative of `exp_neg_inv_glue`, as an auxiliary function `f_aux`. -/
def fAux (n : ℕ) (x : ℝ) : ℝ :=
  if x ≤ 0 then 0 else (pAux n).eval x * exp (-x⁻¹) / x ^ (2 * n)

/-- The `0`-th auxiliary function `f_aux 0` coincides with `exp_neg_inv_glue`, by definition. -/
theorem f_aux_zero_eq : fAux 0 = expNegInvGlue := by
  ext x
  by_cases h:x ≤ 0
  · simp [expNegInvGlue, f_aux, h]
    
  · simp [h, expNegInvGlue, f_aux, ne_of_gt (not_le.1 h), P_aux]
    

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in apply_rules #[["[", expr pow_ne_zero, "]"], []]: ./././Mathport/Syntax/Translate/Basic.lean:348:22: unsupported: parse error -/
/-- For positive values, the derivative of the `n`-th auxiliary function `f_aux n`
(given in this statement in unfolded form) is the `n+1`-th auxiliary function, since
the polynomial `P_aux (n+1)` was chosen precisely to ensure this. -/
theorem fAuxDeriv (n : ℕ) (x : ℝ) (hx : x ≠ 0) :
    HasDerivAt (fun x => (pAux n).eval x * exp (-x⁻¹) / x ^ (2 * n))
      ((pAux (n + 1)).eval x * exp (-x⁻¹) / x ^ (2 * (n + 1))) x :=
  by
  simp only [P_aux, eval_add, eval_sub, eval_mul, eval_pow, eval_X, eval_C, eval_one]
  convert
    (((P_aux n).HasDerivAt x).mul ((has_deriv_at_exp _).comp x (hasDerivAtInv hx).neg)).div (hasDerivAtPow (2 * n) x)
      (pow_ne_zero _ hx) using
    1
  rw [div_eq_div_iff]
  · have := pow_ne_zero 2 hx
    field_simp only
    cases n
    · simp only [mul_zero, Nat.cast_zero, mul_one]
      ring
      
    · rw [(id rfl : 2 * n.succ - 1 = 2 * n + 1)]
      ring
      
    
  all_goals
    trace
      "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in apply_rules #[[\"[\", expr pow_ne_zero, \"]\"], []]: ./././Mathport/Syntax/Translate/Basic.lean:348:22: unsupported: parse error"

/-- For positive values, the derivative of the `n`-th auxiliary function `f_aux n`
is the `n+1`-th auxiliary function. -/
theorem fAuxDerivPos (n : ℕ) (x : ℝ) (hx : 0 < x) :
    HasDerivAt (fAux n) ((pAux (n + 1)).eval x * exp (-x⁻¹) / x ^ (2 * (n + 1))) x := by
  apply (f_aux_deriv n x (ne_of_gt hx)).congr_of_eventually_eq
  filter_upwards [lt_mem_nhds hx] with _ hy
  simp [f_aux, hy.not_le]

/-- To get differentiability at `0` of the auxiliary functions, we need to know that their limit
is `0`, to be able to apply general differentiability extension theorems. This limit is checked in
this lemma. -/
theorem f_aux_limit (n : ℕ) : Tendsto (fun x => (pAux n).eval x * exp (-x⁻¹) / x ^ (2 * n)) (𝓝[>] 0) (𝓝 0) := by
  have A : tendsto (fun x => (P_aux n).eval x) (𝓝[>] 0) (𝓝 ((P_aux n).eval 0)) := (P_aux n).ContinuousWithinAt
  have B : tendsto (fun x => exp (-x⁻¹) / x ^ (2 * n)) (𝓝[>] 0) (𝓝 0) := by
    convert (tendsto_pow_mul_exp_neg_at_top_nhds_0 (2 * n)).comp tendsto_inv_zero_at_top
    ext x
    field_simp
  convert A.mul B <;> simp [mul_div_assoc]

/-- Deduce from the limiting behavior at `0` of its derivative and general differentiability
extension theorems that the auxiliary function `f_aux n` is differentiable at `0`,
with derivative `0`. -/
theorem fAuxDerivZero (n : ℕ) : HasDerivAt (fAux n) 0 0 := by
  -- we check separately differentiability on the left and on the right
  have A : HasDerivWithinAt (f_aux n) (0 : ℝ) (Iic 0) 0 := by
    apply (hasDerivAtConst (0 : ℝ) (0 : ℝ)).HasDerivWithinAt.congr
    · intro y hy
      simp at hy
      simp [f_aux, hy]
      
    · simp [f_aux, le_refl]
      
  have B : HasDerivWithinAt (f_aux n) (0 : ℝ) (Ici 0) 0 := by
    have diff : DifferentiableOn ℝ (f_aux n) (Ioi 0) := fun x hx =>
      (f_aux_deriv_pos n x hx).DifferentiableAt.DifferentiableWithinAt
    -- next line is the nontrivial bit of this proof, appealing to differentiability
    -- extension results.
    apply hasDerivAtIntervalLeftEndpointOfTendstoDeriv diff _ self_mem_nhds_within
    · refine' (f_aux_limit (n + 1)).congr' _
      apply mem_of_superset self_mem_nhds_within fun x hx => _
      simp [(f_aux_deriv_pos n x hx).deriv]
      
    · have : f_aux n 0 = 0 := by simp [f_aux, le_refl]
      simp only [ContinuousWithinAt, this]
      refine' (f_aux_limit n).congr' _
      apply mem_of_superset self_mem_nhds_within fun x hx => _
      have : ¬x ≤ 0 := by simpa using hx
      simp [f_aux, this]
      
  simpa using A.union B

/-- At every point, the auxiliary function `f_aux n` has a derivative which is
equal to `f_aux (n+1)`. -/
theorem fAuxHasDerivAt (n : ℕ) (x : ℝ) : HasDerivAt (fAux n) (fAux (n + 1) x) x := by
  -- check separately the result for `x < 0`, where it is trivial, for `x > 0`, where it is done
  -- in `f_aux_deriv_pos`, and for `x = 0`, done in
  -- `f_aux_deriv_zero`.
  rcases lt_trichotomy x 0 with (hx | hx | hx)
  · have : f_aux (n + 1) x = 0 := by simp [f_aux, le_of_lt hx]
    rw [this]
    apply (hasDerivAtConst x (0 : ℝ)).congr_of_eventually_eq
    filter_upwards [gt_mem_nhds hx] with _ hy
    simp [f_aux, hy.le]
    
  · have : f_aux (n + 1) 0 = 0 := by simp [f_aux, le_refl]
    rw [hx, this]
    exact f_aux_deriv_zero n
    
  · have : f_aux (n + 1) x = (P_aux (n + 1)).eval x * exp (-x⁻¹) / x ^ (2 * (n + 1)) := by simp [f_aux, not_le_of_gt hx]
    rw [this]
    exact f_aux_deriv_pos n x hx
    

/-- The successive derivatives of the auxiliary function `f_aux 0` are the
functions `f_aux n`, by induction. -/
theorem f_aux_iterated_deriv (n : ℕ) : iteratedDeriv n (fAux 0) = fAux n := by
  induction' n with n IH
  · simp
    
  · simp [iterated_deriv_succ, IH]
    ext x
    exact (f_aux_has_deriv_at n x).deriv
    

/-- The function `exp_neg_inv_glue` is smooth. -/
protected theorem contDiff {n} : ContDiff ℝ n expNegInvGlue := by
  rw [← f_aux_zero_eq]
  apply contDiffOfDifferentiableIteratedDeriv fun m hm => _
  rw [f_aux_iterated_deriv m]
  exact fun x => (f_aux_has_deriv_at m x).DifferentiableAt

/-- The function `exp_neg_inv_glue` vanishes on `(-∞, 0]`. -/
theorem zero_of_nonpos {x : ℝ} (hx : x ≤ 0) : expNegInvGlue x = 0 := by simp [expNegInvGlue, hx]

/-- The function `exp_neg_inv_glue` is positive on `(0, +∞)`. -/
theorem pos_of_pos {x : ℝ} (hx : 0 < x) : 0 < expNegInvGlue x := by simp [expNegInvGlue, not_le.2 hx, exp_pos]

/-- The function exp_neg_inv_glue` is nonnegative. -/
theorem nonneg (x : ℝ) : 0 ≤ expNegInvGlue x := by
  cases le_or_gt x 0
  · exact ge_of_eq (zero_of_nonpos h)
    
  · exact le_of_lt (pos_of_pos h)
    

end expNegInvGlue

/-- An infinitely smooth function `f : ℝ → ℝ` such that `f x = 0` for `x ≤ 0`,
`f x = 1` for `1 ≤ x`, and `0 < f x < 1` for `0 < x < 1`. -/
def Real.smoothTransition (x : ℝ) : ℝ :=
  expNegInvGlue x / (expNegInvGlue x + expNegInvGlue (1 - x))

namespace Real

namespace SmoothTransition

variable {x : ℝ}

open expNegInvGlue

theorem pos_denom (x) : 0 < expNegInvGlue x + expNegInvGlue (1 - x) :=
  ((@zero_lt_one ℝ _ _).lt_or_lt x).elim (fun hx => add_pos_of_pos_of_nonneg (pos_of_pos hx) (nonneg _)) fun hx =>
    add_pos_of_nonneg_of_pos (nonneg _) (pos_of_pos <| sub_pos.2 hx)

theorem one_of_one_le (h : 1 ≤ x) : smoothTransition x = 1 :=
  (div_eq_one_iff_eq <| (pos_denom x).ne').2 <| by rw [zero_of_nonpos (sub_nonpos.2 h), add_zero]

theorem zero_of_nonpos (h : x ≤ 0) : smoothTransition x = 0 := by rw [smooth_transition, zero_of_nonpos h, zero_div]

@[simp]
protected theorem zero : smoothTransition 0 = 0 :=
  zero_of_nonpos le_rfl

@[simp]
protected theorem one : smoothTransition 1 = 1 :=
  one_of_one_le le_rfl

theorem le_one (x : ℝ) : smoothTransition x ≤ 1 :=
  (div_le_one (pos_denom x)).2 <| le_add_of_nonneg_right (nonneg _)

theorem nonneg (x : ℝ) : 0 ≤ smoothTransition x :=
  div_nonneg (expNegInvGlue.nonneg _) (pos_denom x).le

theorem lt_one_of_lt_one (h : x < 1) : smoothTransition x < 1 :=
  (div_lt_one <| pos_denom x).2 <| lt_add_of_pos_right _ <| pos_of_pos <| sub_pos.2 h

theorem pos_of_pos (h : 0 < x) : 0 < smoothTransition x :=
  div_pos (expNegInvGlue.pos_of_pos h) (pos_denom x)

protected theorem contDiff {n} : ContDiff ℝ n smoothTransition :=
  (expNegInvGlue.contDiff.div
      (expNegInvGlue.contDiff.add <| expNegInvGlue.contDiff.comp <| contDiffConst.sub contDiffId))
    fun x => (pos_denom x).ne'

protected theorem contDiffAt {x n} : ContDiffAt ℝ n smoothTransition x :=
  smoothTransition.contDiff.ContDiffAt

protected theorem continuous : Continuous smoothTransition :=
  (@smoothTransition.contDiff 0).Continuous

end SmoothTransition

end Real

variable {E X : Type _}

/-- `f : cont_diff_bump_of_inner c`, where `c` is a point in an inner product space, is a
bundled smooth function such that

- `f` is equal to `1` in `metric.closed_ball c f.r`;
- `support f = metric.ball c f.R`;
- `0 ≤ f x ≤ 1` for all `x`.

The structure `cont_diff_bump_of_inner` contains the data required to construct the function:
real numbers `r`, `R`, and proofs of `0 < r < R`. The function itself is available through
`coe_fn`. -/
structure ContDiffBumpOfInner (c : E) where
  (R r : ℝ)
  r_pos : 0 < r
  r_lt_R : r < R

namespace ContDiffBumpOfInner

theorem R_pos {c : E} (f : ContDiffBumpOfInner c) : 0 < f.r :=
  f.r_pos.trans f.r_lt_R

instance (c : E) : Inhabited (ContDiffBumpOfInner c) :=
  ⟨⟨1, 2, zero_lt_one, one_lt_two⟩⟩

variable [InnerProductSpace ℝ E] [NormedAddCommGroup X] [NormedSpace ℝ X]

variable {c : E} (f : ContDiffBumpOfInner c) {x : E} {n : ℕ∞}

/-- The function defined by `f : cont_diff_bump_of_inner c`. Use automatic coercion to
function instead. -/
def toFun (f : ContDiffBumpOfInner c) : E → ℝ := fun x => Real.smoothTransition ((f.r - dist x c) / (f.r - f.R))

instance : CoeFun (ContDiffBumpOfInner c) fun _ => E → ℝ :=
  ⟨toFun⟩

protected theorem def (x : E) : f x = Real.smoothTransition ((f.r - dist x c) / (f.r - f.R)) :=
  rfl

protected theorem sub (x : E) : f (c - x) = f (c + x) := by simp_rw [f.def, dist_self_sub_left, dist_self_add_left]

protected theorem neg (f : ContDiffBumpOfInner (0 : E)) (x : E) : f (-x) = f x := by
  simp_rw [← zero_sub, f.sub, zero_add]

open Real (smoothTransition)

open Real.smoothTransition Metric

theorem one_of_mem_closed_ball (hx : x ∈ ClosedBall c f.R) : f x = 1 :=
  one_of_one_le <| (one_le_div (sub_pos.2 f.r_lt_R)).2 <| sub_le_sub_left hx _

theorem nonneg : 0 ≤ f x :=
  nonneg _

/-- A version of `cont_diff_bump_of_inner.nonneg` with `x` explicit -/
theorem nonneg' (x : E) : 0 ≤ f x :=
  f.Nonneg

theorem le_one : f x ≤ 1 :=
  le_one _

theorem pos_of_mem_ball (hx : x ∈ Ball c f.r) : 0 < f x :=
  pos_of_pos <| div_pos (sub_pos.2 hx) (sub_pos.2 f.r_lt_R)

theorem lt_one_of_lt_dist (h : f.R < dist x c) : f x < 1 :=
  lt_one_of_lt_one <| (div_lt_one (sub_pos.2 f.r_lt_R)).2 <| sub_lt_sub_left h _

theorem zero_of_le_dist (hx : f.r ≤ dist x c) : f x = 0 :=
  zero_of_nonpos <| div_nonpos_of_nonpos_of_nonneg (sub_nonpos.2 hx) (sub_nonneg.2 f.r_lt_R.le)

theorem support_eq : Support (f : E → ℝ) = Metric.Ball c f.r := by
  ext x
  suffices f x ≠ 0 ↔ dist x c < f.R by simpa [mem_support]
  cases' lt_or_le (dist x c) f.R with hx hx
  · simp [hx, (f.pos_of_mem_ball hx).ne']
    
  · simp [hx.not_lt, f.zero_of_le_dist hx]
    

theorem tsupport_eq : Tsupport f = ClosedBall c f.r := by simp_rw [Tsupport, f.support_eq, closure_ball _ f.R_pos.ne']

protected theorem has_compact_support [FiniteDimensional ℝ E] : HasCompactSupport f := by
  simp_rw [HasCompactSupport, f.tsupport_eq, is_compact_closed_ball]

theorem eventually_eq_one_of_mem_ball (h : x ∈ Ball c f.R) : f =ᶠ[𝓝 x] 1 :=
  ((is_open_lt (continuous_id.dist continuous_const) continuous_const).eventually_mem h).mono fun z hz =>
    f.one_of_mem_closed_ball (le_of_lt hz)

theorem eventually_eq_one : f =ᶠ[𝓝 c] 1 :=
  f.eventually_eq_one_of_mem_ball (mem_ball_self f.r_pos)

/-- `cont_diff_bump` is `𝒞ⁿ` in all its arguments. -/
protected theorem _root_.cont_diff_at.cont_diff_bump {c g : X → E} {f : ∀ x, ContDiffBumpOfInner (c x)} {x : X}
    (hc : ContDiffAt ℝ n c x) (hr : ContDiffAt ℝ n (fun x => (f x).R) x) (hR : ContDiffAt ℝ n (fun x => (f x).r) x)
    (hg : ContDiffAt ℝ n g x) : ContDiffAt ℝ n (fun x => f x (g x)) x := by
  rcases eq_or_ne (g x) (c x) with (hx | hx)
  · have : (fun x => f x (g x)) =ᶠ[𝓝 x] fun x => 1 := by
      have : dist (g x) (c x) < (f x).R := by simp_rw [hx, dist_self, (f x).r_pos]
      have := ContinuousAt.eventually_lt (hg.continuous_at.dist hc.continuous_at) hr.continuous_at this
      exact eventually_of_mem this fun x hx => (f x).one_of_mem_closed_ball (mem_set_of_eq.mp hx).le
    exact cont_diff_at_const.congr_of_eventually_eq this
    
  · refine' real.smooth_transition.cont_diff_at.comp x _
    refine' (hR.sub <| hg.dist hc hx).div (hR.sub hr) (sub_pos.mpr (f x).r_lt_R).ne'
    

theorem _root_.cont_diff.cont_diff_bump {c g : X → E} {f : ∀ x, ContDiffBumpOfInner (c x)} (hc : ContDiff ℝ n c)
    (hr : ContDiff ℝ n fun x => (f x).R) (hR : ContDiff ℝ n fun x => (f x).r) (hg : ContDiff ℝ n g) :
    ContDiff ℝ n fun x => f x (g x) := by
  rw [cont_diff_iff_cont_diff_at] at *
  exact fun x => (hc x).contDiffBump (hr x) (hR x) (hg x)

protected theorem contDiff : ContDiff ℝ n f :=
  contDiffConst.contDiffBump contDiffConst contDiffConst contDiffId

protected theorem contDiffAt : ContDiffAt ℝ n f x :=
  f.ContDiff.ContDiffAt

protected theorem contDiffWithinAt {s : Set E} : ContDiffWithinAt ℝ n f s x :=
  f.ContDiffAt.ContDiffWithinAt

protected theorem continuous : Continuous f :=
  cont_diff_zero.mp f.ContDiff

open MeasureTheory

variable [MeasurableSpace E] {μ : Measure E}

/-- A bump function normed so that `∫ x, f.normed μ x ∂μ = 1`. -/
protected def normed (μ : Measure E) : E → ℝ := fun x => f x / ∫ x, f x ∂μ

theorem normed_def {μ : Measure E} (x : E) : f.normed μ x = f x / ∫ x, f x ∂μ :=
  rfl

theorem nonneg_normed (x : E) : 0 ≤ f.normed μ x :=
  div_nonneg f.Nonneg <| integral_nonneg f.nonneg'

theorem contDiffNormed {n : ℕ∞} : ContDiff ℝ n (f.normed μ) :=
  f.ContDiff.div_const

theorem continuous_normed : Continuous (f.normed μ) :=
  f.Continuous.div_const

theorem normed_sub (x : E) : f.normed μ (c - x) = f.normed μ (c + x) := by simp_rw [f.normed_def, f.sub]

theorem normed_neg (f : ContDiffBumpOfInner (0 : E)) (x : E) : f.normed μ (-x) = f.normed μ x := by
  simp_rw [f.normed_def, f.neg]

variable [BorelSpace E] [FiniteDimensional ℝ E] [IsLocallyFiniteMeasure μ]

protected theorem integrable : Integrable f μ :=
  f.Continuous.integrableOfHasCompactSupport f.HasCompactSupport

protected theorem integrableNormed : Integrable (f.normed μ) μ :=
  f.Integrable.div_const _

variable [μ.IsOpenPosMeasure]

theorem integral_pos : 0 < ∫ x, f x ∂μ := by
  refine' (integral_pos_iff_support_of_nonneg f.nonneg' f.integrable).mpr _
  rw [f.support_eq]
  refine' is_open_ball.measure_pos _ (nonempty_ball.mpr f.R_pos)

theorem integral_normed : (∫ x, f.normed μ x ∂μ) = 1 := by
  simp_rw [ContDiffBumpOfInner.normed, div_eq_mul_inv, mul_comm (f _), ← smul_eq_mul, integral_smul]
  exact inv_mul_cancel f.integral_pos.ne'

theorem support_normed_eq : Support (f.normed μ) = Metric.Ball c f.r := by
  simp_rw [ContDiffBumpOfInner.normed, support_div, f.support_eq, support_const f.integral_pos.ne', inter_univ]

theorem tsupport_normed_eq : Tsupport (f.normed μ) = Metric.ClosedBall c f.r := by
  simp_rw [Tsupport, f.support_normed_eq, closure_ball _ f.R_pos.ne']

theorem has_compact_support_normed : HasCompactSupport (f.normed μ) := by
  simp_rw [HasCompactSupport, f.tsupport_normed_eq, is_compact_closed_ball]

theorem tendsto_support_normed_small_sets {ι} {φ : ι → ContDiffBumpOfInner c} {l : Filter ι}
    (hφ : Tendsto (fun i => (φ i).r) l (𝓝 0)) :
    Tendsto (fun i => Support fun x => (φ i).normed μ x) l (𝓝 c).smallSets := by
  simp_rw [NormedAddCommGroup.tendsto_nhds_zero, Real.norm_eq_abs, abs_eq_self.mpr (φ _).R_pos.le] at hφ
  rw [tendsto_small_sets_iff]
  intro t ht
  rcases metric.mem_nhds_iff.mp ht with ⟨ε, hε, ht⟩
  refine' (hφ ε hε).mono fun i hi => subset_trans _ ht
  simp_rw [(φ i).support_normed_eq]
  exact ball_subset_ball hi.le

variable (μ)

theorem integral_normed_smul (z : X) [CompleteSpace X] : (∫ x, f.normed μ x • z ∂μ) = z := by
  simp_rw [integral_smul_const, f.integral_normed, one_smul]

end ContDiffBumpOfInner

/-- `f : cont_diff_bump c`, where `c` is a point in a finite dimensional real vector space, is
a bundled smooth function such that

  - `f` is equal to `1` in `euclidean.closed_ball c f.r`;
  - `support f = euclidean.ball c f.R`;
  - `0 ≤ f x ≤ 1` for all `x`.

The structure `cont_diff_bump` contains the data required to construct the function: real
numbers `r`, `R`, and proofs of `0 < r < R`. The function itself is available through `coe_fn`.-/
structure ContDiffBump [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E] (c : E) extends
  ContDiffBumpOfInner (toEuclidean c)

namespace ContDiffBump

variable [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E] {c x : E} (f : ContDiffBump c)

/-- The function defined by `f : cont_diff_bump c`. Use automatic coercion to function
instead. -/
def toFun (f : ContDiffBump c) : E → ℝ :=
  f.toContDiffBumpOfInner ∘ toEuclidean

instance : CoeFun (ContDiffBump c) fun _ => E → ℝ :=
  ⟨toFun⟩

instance (c : E) : Inhabited (ContDiffBump c) :=
  ⟨⟨default⟩⟩

theorem R_pos : 0 < f.r :=
  f.toContDiffBumpOfInner.R_pos

theorem coe_eq_comp : ⇑f = f.toContDiffBumpOfInner ∘ toEuclidean :=
  rfl

theorem one_of_mem_closed_ball (hx : x ∈ Euclidean.ClosedBall c f.R) : f x = 1 :=
  f.toContDiffBumpOfInner.one_of_mem_closed_ball hx

theorem nonneg : 0 ≤ f x :=
  f.toContDiffBumpOfInner.Nonneg

theorem le_one : f x ≤ 1 :=
  f.toContDiffBumpOfInner.le_one

theorem pos_of_mem_ball (hx : x ∈ Euclidean.Ball c f.r) : 0 < f x :=
  f.toContDiffBumpOfInner.pos_of_mem_ball hx

theorem lt_one_of_lt_dist (h : f.R < Euclidean.dist x c) : f x < 1 :=
  f.toContDiffBumpOfInner.lt_one_of_lt_dist h

theorem zero_of_le_dist (hx : f.r ≤ Euclidean.dist x c) : f x = 0 :=
  f.toContDiffBumpOfInner.zero_of_le_dist hx

theorem support_eq : Support (f : E → ℝ) = Euclidean.Ball c f.r := by
  rw [Euclidean.ball_eq_preimage, ← f.to_cont_diff_bump_of_inner.support_eq, ← support_comp_eq_preimage, coe_eq_comp]

theorem tsupport_eq : Tsupport f = Euclidean.ClosedBall c f.r := by
  rw [Tsupport, f.support_eq, Euclidean.closure_ball _ f.R_pos.ne']

protected theorem has_compact_support : HasCompactSupport f := by
  simp_rw [HasCompactSupport, f.tsupport_eq, Euclidean.is_compact_closed_ball]

theorem eventually_eq_one_of_mem_ball (h : x ∈ Euclidean.Ball c f.R) : f =ᶠ[𝓝 x] 1 :=
  toEuclidean.ContinuousAt (f.toContDiffBumpOfInner.eventually_eq_one_of_mem_ball h)

theorem eventually_eq_one : f =ᶠ[𝓝 c] 1 :=
  f.eventually_eq_one_of_mem_ball <| Euclidean.mem_ball_self f.r_pos

protected theorem contDiff {n} : ContDiff ℝ n f :=
  f.toContDiffBumpOfInner.ContDiff.comp (toEuclidean : E ≃L[ℝ] _).ContDiff

protected theorem contDiffAt {n} : ContDiffAt ℝ n f x :=
  f.ContDiff.ContDiffAt

protected theorem contDiffWithinAt {s n} : ContDiffWithinAt ℝ n f s x :=
  f.ContDiffAt.ContDiffWithinAt

theorem exists_tsupport_subset {s : Set E} (hs : s ∈ 𝓝 c) : ∃ f : ContDiffBump c, Tsupport f ⊆ s :=
  let ⟨R, h0, hR⟩ := Euclidean.nhds_basis_closed_ball.mem_iff.1 hs
  ⟨⟨⟨R / 2, R, half_pos h0, half_lt_self h0⟩⟩, by rwa [tsupport_eq]⟩

theorem exists_closure_subset {R : ℝ} (hR : 0 < R) {s : Set E} (hs : IsClosed s) (hsR : s ⊆ Euclidean.Ball c R) :
    ∃ f : ContDiffBump c, f.r = R ∧ s ⊆ Euclidean.Ball c f.R := by
  rcases Euclidean.exists_pos_lt_subset_ball hR hs hsR with ⟨r, hr, hsr⟩
  exact ⟨⟨⟨r, R, hr.1, hr.2⟩⟩, rfl, hsr⟩

end ContDiffBump

open FiniteDimensional Metric

/-- If `E` is a finite dimensional normed space over `ℝ`, then for any point `x : E` and its
neighborhood `s` there exists an infinitely smooth function with the following properties:

* `f y = 1` in a neighborhood of `x`;
* `f y = 0` outside of `s`;
*  moreover, `tsupport f ⊆ s` and `f` has compact support;
* `f y ∈ [0, 1]` for all `y`.

This lemma is a simple wrapper around lemmas about bundled smooth bump functions, see
`cont_diff_bump`. -/
theorem exists_cont_diff_bump_function_of_mem_nhds [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    {x : E} {s : Set E} (hs : s ∈ 𝓝 x) :
    ∃ f : E → ℝ, f =ᶠ[𝓝 x] 1 ∧ (∀ y, f y ∈ IccCat (0 : ℝ) 1) ∧ ContDiff ℝ ⊤ f ∧ HasCompactSupport f ∧ Tsupport f ⊆ s :=
  let ⟨f, hf⟩ := ContDiffBump.exists_tsupport_subset hs
  ⟨f, f.eventually_eq_one, fun y => ⟨f.Nonneg, f.le_one⟩, f.ContDiff, f.HasCompactSupport, hf⟩

