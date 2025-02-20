/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module measure_theory.integral.circle_integral
! leanprover-community/mathlib commit fd4551cfe4b7484b81c2c9ba3405edae27659676
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Integral.IntervalIntegral
import Mathbin.Analysis.Calculus.Deriv.Zpow
import Mathbin.Analysis.NormedSpace.Pointwise
import Mathbin.Analysis.SpecialFunctions.NonIntegrable
import Mathbin.Analysis.Analytic.Basic

/-!
# Integral over a circle in `ℂ`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `∮ z in C(c, R), f z` to be the integral $\oint_{|z-c|=|R|} f(z)\,dz$ and
prove some properties of this integral. We give definition and prove most lemmas for a function
`f : ℂ → E`, where `E` is a complex Banach space. For this reason,
some lemmas use, e.g., `(z - c)⁻¹ • f z` instead of `f z / (z - c)`.

## Main definitions

* `circle_map c R`: the exponential map $θ ↦ c + R e^{θi}$;

* `circle_integrable f c R`: a function `f : ℂ → E` is integrable on the circle with center `c` and
  radius `R` if `f ∘ circle_map c R` is integrable on `[0, 2π]`;

* `circle_integral f c R`: the integral $\oint_{|z-c|=|R|} f(z)\,dz$, defined as
  $\int_{0}^{2π}(c + Re^{θ i})' f(c+Re^{θ i})\,dθ$;

* `cauchy_power_series f c R`: the power series that is equal to
  $\sum_{n=0}^{\infty} \oint_{|z-c|=R} \left(\frac{w-c}{z - c}\right)^n \frac{1}{z-c}f(z)\,dz$ at
  `w - c`. The coefficients of this power series depend only on `f ∘ circle_map c R`, and the power
  series converges to `f w` if `f` is differentiable on the closed ball `metric.closed_ball c R`
  and `w` belongs to the corresponding open ball.

## Main statements

* `has_fpower_series_on_cauchy_integral`: for any circle integrable function `f`, the power series
  `cauchy_power_series f c R`, `R > 0`, converges to the Cauchy integral
  `(2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), (z - w)⁻¹ • f z` on the open disc `metric.ball c R`;

* `circle_integral.integral_sub_zpow_of_undef`, `circle_integral.integral_sub_zpow_of_ne`, and
  `circle_integral.integral_sub_inv_of_mem_ball`: formulas for `∮ z in C(c, R), (z - w) ^ n`,
  `n : ℤ`. These lemmas cover the following cases:

  - `circle_integral.integral_sub_zpow_of_undef`, `n < 0` and `|w - c| = |R|`: in this case the
    function is not integrable, so the integral is equal to its default value (zero);

  - `circle_integral.integral_sub_zpow_of_ne`, `n ≠ -1`: in the cases not covered by the previous
    lemma, we have `(z - w) ^ n = ((z - w) ^ (n + 1) / (n + 1))'`, thus the integral equals zero;

  - `circle_integral.integral_sub_inv_of_mem_ball`, `n = -1`, `|w - c| < R`: in this case the
    integral is equal to `2πi`.

  The case `n = -1`, `|w -c| > R` is not covered by these lemmas. While it is possible to construct
  an explicit primitive, it is easier to apply Cauchy theorem, so we postpone the proof till we have
  this theorem (see #10000).

## Notation

- `∮ z in C(c, R), f z`: notation for the integral $\oint_{|z-c|=|R|} f(z)\,dz$, defined as
  $\int_{0}^{2π}(c + Re^{θ i})' f(c+Re^{θ i})\,dθ$.

## Tags

integral, circle, Cauchy integral
-/


variable {E : Type _} [NormedAddCommGroup E]

noncomputable section

open scoped Real NNReal Interval Pointwise Topology

open Complex MeasureTheory TopologicalSpace Metric Function Set Filter Asymptotics

/-!
### `circle_map`, a parametrization of a circle
-/


#print circleMap /-
/-- The exponential map $θ ↦ c + R e^{θi}$. The range of this map is the circle in `ℂ` with center
`c` and radius `|R|`. -/
def circleMap (c : ℂ) (R : ℝ) : ℝ → ℂ := fun θ => c + R * exp (θ * I)
#align circle_map circleMap
-/

#print periodic_circleMap /-
/-- `circle_map` is `2π`-periodic. -/
theorem periodic_circleMap (c : ℂ) (R : ℝ) : Periodic (circleMap c R) (2 * π) := fun θ => by
  simp [circleMap, add_mul, exp_periodic _]
#align periodic_circle_map periodic_circleMap
-/

#print Set.Countable.preimage_circleMap /-
theorem Set.Countable.preimage_circleMap {s : Set ℂ} (hs : s.Countable) (c : ℂ) {R : ℝ}
    (hR : R ≠ 0) : (circleMap c R ⁻¹' s).Countable :=
  show (coe ⁻¹' ((· * I) ⁻¹' (exp ⁻¹' ((· * ·) R ⁻¹' ((· + ·) c ⁻¹' s))))).Countable from
    (((hs.Preimage (add_right_injective _)).Preimage <|
                mul_right_injective₀ <| ofReal_ne_zero.2 hR).preimage_cexp.Preimage <|
          mul_left_injective₀ I_ne_zero).Preimage
      ofReal_injective
#align set.countable.preimage_circle_map Set.Countable.preimage_circleMap
-/

#print circleMap_sub_center /-
@[simp]
theorem circleMap_sub_center (c : ℂ) (R : ℝ) (θ : ℝ) : circleMap c R θ - c = circleMap 0 R θ := by
  simp [circleMap]
#align circle_map_sub_center circleMap_sub_center
-/

#print circleMap_zero /-
theorem circleMap_zero (R θ : ℝ) : circleMap 0 R θ = R * exp (θ * I) :=
  zero_add _
#align circle_map_zero circleMap_zero
-/

#print abs_circleMap_zero /-
@[simp]
theorem abs_circleMap_zero (R : ℝ) (θ : ℝ) : abs (circleMap 0 R θ) = |R| := by simp [circleMap]
#align abs_circle_map_zero abs_circleMap_zero
-/

#print circleMap_mem_sphere' /-
theorem circleMap_mem_sphere' (c : ℂ) (R : ℝ) (θ : ℝ) : circleMap c R θ ∈ sphere c (|R|) := by simp
#align circle_map_mem_sphere' circleMap_mem_sphere'
-/

#print circleMap_mem_sphere /-
theorem circleMap_mem_sphere (c : ℂ) {R : ℝ} (hR : 0 ≤ R) (θ : ℝ) : circleMap c R θ ∈ sphere c R :=
  by simpa only [_root_.abs_of_nonneg hR] using circleMap_mem_sphere' c R θ
#align circle_map_mem_sphere circleMap_mem_sphere
-/

#print circleMap_mem_closedBall /-
theorem circleMap_mem_closedBall (c : ℂ) {R : ℝ} (hR : 0 ≤ R) (θ : ℝ) :
    circleMap c R θ ∈ closedBall c R :=
  sphere_subset_closedBall (circleMap_mem_sphere c hR θ)
#align circle_map_mem_closed_ball circleMap_mem_closedBall
-/

#print circleMap_not_mem_ball /-
theorem circleMap_not_mem_ball (c : ℂ) (R : ℝ) (θ : ℝ) : circleMap c R θ ∉ ball c R := by
  simp [dist_eq, le_abs_self]
#align circle_map_not_mem_ball circleMap_not_mem_ball
-/

#print circleMap_ne_mem_ball /-
theorem circleMap_ne_mem_ball {c : ℂ} {R : ℝ} {w : ℂ} (hw : w ∈ ball c R) (θ : ℝ) :
    circleMap c R θ ≠ w :=
  (ne_of_mem_of_not_mem hw (circleMap_not_mem_ball _ _ _)).symm
#align circle_map_ne_mem_ball circleMap_ne_mem_ball
-/

#print range_circleMap /-
/-- The range of `circle_map c R` is the circle with center `c` and radius `|R|`. -/
@[simp]
theorem range_circleMap (c : ℂ) (R : ℝ) : range (circleMap c R) = sphere c (|R|) :=
  calc
    range (circleMap c R) = c +ᵥ R • range fun θ : ℝ => exp (θ * I) := by
      simp only [← image_vadd, ← image_smul, ← range_comp, vadd_eq_add, circleMap, (· ∘ ·),
        real_smul]
    _ = sphere c (|R|) := by simp [smul_sphere R (0 : ℂ) zero_le_one]
#align range_circle_map range_circleMap
-/

#print image_circleMap_Ioc /-
/-- The image of `(0, 2π]` under `circle_map c R` is the circle with center `c` and radius `|R|`. -/
@[simp]
theorem image_circleMap_Ioc (c : ℂ) (R : ℝ) : circleMap c R '' Ioc 0 (2 * π) = sphere c (|R|) := by
  rw [← range_circleMap, ← (periodic_circleMap c R).image_Ioc Real.two_pi_pos 0, zero_add]
#align image_circle_map_Ioc image_circleMap_Ioc
-/

#print circleMap_eq_center_iff /-
@[simp]
theorem circleMap_eq_center_iff {c : ℂ} {R : ℝ} {θ : ℝ} : circleMap c R θ = c ↔ R = 0 := by
  simp [circleMap, exp_ne_zero]
#align circle_map_eq_center_iff circleMap_eq_center_iff
-/

#print circleMap_zero_radius /-
@[simp]
theorem circleMap_zero_radius (c : ℂ) : circleMap c 0 = const ℝ c :=
  funext fun θ => circleMap_eq_center_iff.2 rfl
#align circle_map_zero_radius circleMap_zero_radius
-/

#print circleMap_ne_center /-
theorem circleMap_ne_center {c : ℂ} {R : ℝ} (hR : R ≠ 0) {θ : ℝ} : circleMap c R θ ≠ c :=
  mt circleMap_eq_center_iff.1 hR
#align circle_map_ne_center circleMap_ne_center
-/

#print hasDerivAt_circleMap /-
theorem hasDerivAt_circleMap (c : ℂ) (R : ℝ) (θ : ℝ) :
    HasDerivAt (circleMap c R) (circleMap 0 R θ * I) θ := by
  simpa only [mul_assoc, one_mul, of_real_clm_apply, circleMap, of_real_one, zero_add] using
    ((of_real_clm.has_deriv_at.mul_const I).cexp.const_mul (R : ℂ)).const_add c
#align has_deriv_at_circle_map hasDerivAt_circleMap
-/

#print differentiable_circleMap /-
/- TODO: prove `cont_diff ℝ (circle_map c R)`. This needs a version of `cont_diff.mul`
for multiplication in a normed algebra over the base field. -/
theorem differentiable_circleMap (c : ℂ) (R : ℝ) : Differentiable ℝ (circleMap c R) := fun θ =>
  (hasDerivAt_circleMap c R θ).DifferentiableAt
#align differentiable_circle_map differentiable_circleMap
-/

#print continuous_circleMap /-
@[continuity]
theorem continuous_circleMap (c : ℂ) (R : ℝ) : Continuous (circleMap c R) :=
  (differentiable_circleMap c R).Continuous
#align continuous_circle_map continuous_circleMap
-/

#print measurable_circleMap /-
@[measurability]
theorem measurable_circleMap (c : ℂ) (R : ℝ) : Measurable (circleMap c R) :=
  (continuous_circleMap c R).Measurable
#align measurable_circle_map measurable_circleMap
-/

#print deriv_circleMap /-
@[simp]
theorem deriv_circleMap (c : ℂ) (R : ℝ) (θ : ℝ) : deriv (circleMap c R) θ = circleMap 0 R θ * I :=
  (hasDerivAt_circleMap _ _ _).deriv
#align deriv_circle_map deriv_circleMap
-/

#print deriv_circleMap_eq_zero_iff /-
theorem deriv_circleMap_eq_zero_iff {c : ℂ} {R : ℝ} {θ : ℝ} : deriv (circleMap c R) θ = 0 ↔ R = 0 :=
  by simp [I_ne_zero]
#align deriv_circle_map_eq_zero_iff deriv_circleMap_eq_zero_iff
-/

#print deriv_circleMap_ne_zero /-
theorem deriv_circleMap_ne_zero {c : ℂ} {R : ℝ} {θ : ℝ} (hR : R ≠ 0) :
    deriv (circleMap c R) θ ≠ 0 :=
  mt deriv_circleMap_eq_zero_iff.1 hR
#align deriv_circle_map_ne_zero deriv_circleMap_ne_zero
-/

#print lipschitzWith_circleMap /-
theorem lipschitzWith_circleMap (c : ℂ) (R : ℝ) : LipschitzWith R.nnabs (circleMap c R) :=
  lipschitzWith_of_nnnorm_deriv_le (differentiable_circleMap _ _) fun θ =>
    NNReal.coe_le_coe.1 <| by simp
#align lipschitz_with_circle_map lipschitzWith_circleMap
-/

#print continuous_circleMap_inv /-
theorem continuous_circleMap_inv {R : ℝ} {z w : ℂ} (hw : w ∈ ball z R) :
    Continuous fun θ => (circleMap z R θ - w)⁻¹ :=
  by
  have : ∀ θ, circleMap z R θ - w ≠ 0 := by simp_rw [sub_ne_zero];
    exact fun θ => circleMap_ne_mem_ball hw θ
  continuity
#align continuous_circle_map_inv continuous_circleMap_inv
-/

/-!
### Integrability of a function on a circle
-/


#print CircleIntegrable /-
/-- We say that a function `f : ℂ → E` is integrable on the circle with center `c` and radius `R` if
the function `f ∘ circle_map c R` is integrable on `[0, 2π]`.

Note that the actual function used in the definition of `circle_integral` is
`(deriv (circle_map c R) θ) • f (circle_map c R θ)`. Integrability of this function is equivalent
to integrability of `f ∘ circle_map c R` whenever `R ≠ 0`. -/
def CircleIntegrable (f : ℂ → E) (c : ℂ) (R : ℝ) : Prop :=
  IntervalIntegrable (fun θ : ℝ => f (circleMap c R θ)) volume 0 (2 * π)
#align circle_integrable CircleIntegrable
-/

#print circleIntegrable_const /-
@[simp]
theorem circleIntegrable_const (a : E) (c : ℂ) (R : ℝ) : CircleIntegrable (fun _ => a) c R :=
  intervalIntegrable_const
#align circle_integrable_const circleIntegrable_const
-/

namespace CircleIntegrable

variable {f g : ℂ → E} {c : ℂ} {R : ℝ}

#print CircleIntegrable.add /-
theorem add (hf : CircleIntegrable f c R) (hg : CircleIntegrable g c R) :
    CircleIntegrable (f + g) c R :=
  hf.add hg
#align circle_integrable.add CircleIntegrable.add
-/

#print CircleIntegrable.neg /-
theorem neg (hf : CircleIntegrable f c R) : CircleIntegrable (-f) c R :=
  hf.neg
#align circle_integrable.neg CircleIntegrable.neg
-/

#print CircleIntegrable.out /-
/-- The function we actually integrate over `[0, 2π]` in the definition of `circle_integral` is
integrable. -/
theorem out [NormedSpace ℂ E] (hf : CircleIntegrable f c R) :
    IntervalIntegrable (fun θ : ℝ => deriv (circleMap c R) θ • f (circleMap c R θ)) volume 0
      (2 * π) :=
  by
  simp only [CircleIntegrable, deriv_circleMap, intervalIntegrable_iff] at *
  refine' (hf.norm.const_mul (|R|)).mono' _ _
  ·
    exact
      ((continuous_circleMap _ _).AEStronglyMeasurable.mul_const I).smul hf.ae_strongly_measurable
  · simp [norm_smul]
#align circle_integrable.out CircleIntegrable.out
-/

end CircleIntegrable

#print circleIntegrable_zero_radius /-
@[simp]
theorem circleIntegrable_zero_radius {f : ℂ → E} {c : ℂ} : CircleIntegrable f c 0 := by
  simp [CircleIntegrable]
#align circle_integrable_zero_radius circleIntegrable_zero_radius
-/

#print circleIntegrable_iff /-
theorem circleIntegrable_iff [NormedSpace ℂ E] {f : ℂ → E} {c : ℂ} (R : ℝ) :
    CircleIntegrable f c R ↔
      IntervalIntegrable (fun θ : ℝ => deriv (circleMap c R) θ • f (circleMap c R θ)) volume 0
        (2 * π) :=
  by
  by_cases h₀ : R = 0
  · simp [h₀]
  refine' ⟨fun h => h.out, fun h => _⟩
  simp only [CircleIntegrable, intervalIntegrable_iff, deriv_circleMap] at h ⊢
  refine' (h.norm.const_mul (|R|)⁻¹).mono' _ _
  · have H : ∀ {θ}, circleMap 0 R θ * I ≠ 0 := fun θ => by simp [h₀, I_ne_zero]
    simpa only [inv_smul_smul₀ H] using
      ((continuous_circleMap 0 R).AEStronglyMeasurable.mul_const
                  I).AEMeasurable.inv.AEStronglyMeasurable.smul
        h.ae_strongly_measurable
  · simp [norm_smul, h₀]
#align circle_integrable_iff circleIntegrable_iff
-/

#print ContinuousOn.circleIntegrable' /-
theorem ContinuousOn.circleIntegrable' {f : ℂ → E} {c : ℂ} {R : ℝ}
    (hf : ContinuousOn f (sphere c (|R|))) : CircleIntegrable f c R :=
  (hf.comp_continuous (continuous_circleMap _ _) (circleMap_mem_sphere' _ _)).IntervalIntegrable _ _
#align continuous_on.circle_integrable' ContinuousOn.circleIntegrable'
-/

#print ContinuousOn.circleIntegrable /-
theorem ContinuousOn.circleIntegrable {f : ℂ → E} {c : ℂ} {R : ℝ} (hR : 0 ≤ R)
    (hf : ContinuousOn f (sphere c R)) : CircleIntegrable f c R :=
  ContinuousOn.circleIntegrable' <| (abs_of_nonneg hR).symm ▸ hf
#align continuous_on.circle_integrable ContinuousOn.circleIntegrable
-/

#print circleIntegrable_sub_zpow_iff /-
/-- The function `λ z, (z - w) ^ n`, `n : ℤ`, is circle integrable on the circle with center `c` and
radius `|R|` if and only if `R = 0` or `0 ≤ n`, or `w` does not belong to this circle. -/
@[simp]
theorem circleIntegrable_sub_zpow_iff {c w : ℂ} {R : ℝ} {n : ℤ} :
    CircleIntegrable (fun z => (z - w) ^ n) c R ↔ R = 0 ∨ 0 ≤ n ∨ w ∉ sphere c (|R|) :=
  by
  constructor
  · intro h; contrapose! h; rcases h with ⟨hR, hn, hw⟩
    simp only [circleIntegrable_iff R, deriv_circleMap]
    rw [← image_circleMap_Ioc] at hw ; rcases hw with ⟨θ, hθ, rfl⟩
    replace hθ : θ ∈ [0, 2 * π]; exact Icc_subset_uIcc (Ioc_subset_Icc_self hθ)
    refine' not_intervalIntegrable_of_sub_inv_isBigO_punctured _ real.two_pi_pos.ne hθ
    set f : ℝ → ℂ := fun θ' => circleMap c R θ' - circleMap c R θ
    have : ∀ᶠ θ' in 𝓝[≠] θ, f θ' ∈ ball (0 : ℂ) 1 \ {0} :=
      by
      suffices : ∀ᶠ z in 𝓝[≠] circleMap c R θ, z - circleMap c R θ ∈ ball (0 : ℂ) 1 \ {0}
      exact
        ((differentiable_circleMap c R θ).HasDerivAt.tendsto_punctured_nhds
              (deriv_circleMap_ne_zero hR)).Eventually
          this
      filter_upwards [self_mem_nhdsWithin, mem_nhdsWithin_of_mem_nhds (ball_mem_nhds _ zero_lt_one)]
      simp (config := { contextual := true }) only [dist_eq, sub_eq_zero, mem_compl_iff,
        mem_singleton_iff, mem_ball, mem_diff, mem_ball_zero_iff, norm_eq_abs, not_false_iff,
        and_self_iff, imp_true_iff]
    refine'
      (((hasDerivAt_circleMap c R θ).isBigO_sub.mono inf_le_left).inv_rev
            (this.mono fun θ' h₁ h₂ => absurd h₂ h₁.2)).trans
        _
    refine' is_O.of_bound (|R|)⁻¹ (this.mono fun θ' hθ' => _)
    set x := abs (f θ')
    suffices x⁻¹ ≤ x ^ n by
      simpa only [inv_mul_cancel_left₀, abs_eq_zero.not.2 hR, norm_eq_abs, map_inv₀,
        Algebra.id.smul_eq_mul, map_mul, abs_circleMap_zero, abs_I, mul_one, abs_zpow, Ne.def,
        not_false_iff] using this
    have : x ∈ Ioo (0 : ℝ) 1 := by simpa [and_comm, x] using hθ'
    rw [← zpow_neg_one]
    refine' (zpow_strictAnti this.1 this.2).le_iff_le.2 (Int.lt_add_one_iff.1 _); exact hn
  · rintro (rfl | H)
    exacts [circleIntegrable_zero_radius,
      ((continuous_on_id.sub continuousOn_const).zpow₀ _ fun z hz =>
          H.symm.imp_left fun hw => sub_ne_zero.2 <| ne_of_mem_of_not_mem hz hw).circleIntegrable']
#align circle_integrable_sub_zpow_iff circleIntegrable_sub_zpow_iff
-/

#print circleIntegrable_sub_inv_iff /-
@[simp]
theorem circleIntegrable_sub_inv_iff {c w : ℂ} {R : ℝ} :
    CircleIntegrable (fun z => (z - w)⁻¹) c R ↔ R = 0 ∨ w ∉ sphere c (|R|) := by
  simp only [← zpow_neg_one, circleIntegrable_sub_zpow_iff]; norm_num
#align circle_integrable_sub_inv_iff circleIntegrable_sub_inv_iff
-/

variable [NormedSpace ℂ E] [CompleteSpace E]

#print circleIntegral /-
/-- Definition for $\oint_{|z-c|=R} f(z)\,dz$. -/
def circleIntegral (f : ℂ → E) (c : ℂ) (R : ℝ) : E :=
  ∫ θ : ℝ in 0 ..2 * π, deriv (circleMap c R) θ • f (circleMap c R θ)
#align circle_integral circleIntegral
-/

notation3"∮ "(...)" in ""C("c", "R")"", "r:60:(scoped f => circleIntegral f c R) => r

#print circleIntegral_def_Icc /-
theorem circleIntegral_def_Icc (f : ℂ → E) (c : ℂ) (R : ℝ) :
    ∮ z in C(c, R), f z = ∫ θ in Icc 0 (2 * π), deriv (circleMap c R) θ • f (circleMap c R θ) := by
  simp only [circleIntegral, intervalIntegral.integral_of_le real.two_pi_pos.le,
    measure.restrict_congr_set Ioc_ae_eq_Icc]
#align circle_integral_def_Icc circleIntegral_def_Icc
-/

namespace circleIntegral

#print circleIntegral.integral_radius_zero /-
@[simp]
theorem integral_radius_zero (f : ℂ → E) (c : ℂ) : ∮ z in C(c, 0), f z = 0 := by
  simp [circleIntegral]
#align circle_integral.integral_radius_zero circleIntegral.integral_radius_zero
-/

#print circleIntegral.integral_congr /-
theorem integral_congr {f g : ℂ → E} {c : ℂ} {R : ℝ} (hR : 0 ≤ R) (h : EqOn f g (sphere c R)) :
    ∮ z in C(c, R), f z = ∮ z in C(c, R), g z :=
  intervalIntegral.integral_congr fun θ hθ => by simp only [h (circleMap_mem_sphere _ hR _)]
#align circle_integral.integral_congr circleIntegral.integral_congr
-/

#print circleIntegral.integral_sub_inv_smul_sub_smul /-
theorem integral_sub_inv_smul_sub_smul (f : ℂ → E) (c w : ℂ) (R : ℝ) :
    ∮ z in C(c, R), (z - w)⁻¹ • (z - w) • f z = ∮ z in C(c, R), f z :=
  by
  rcases eq_or_ne R 0 with (rfl | hR); · simp only [integral_radius_zero]
  have : (circleMap c R ⁻¹' {w}).Countable := (countable_singleton _).preimage_circleMap c hR
  refine' intervalIntegral.integral_congr_ae ((this.ae_not_mem _).mono fun θ hθ hθ' => _)
  change circleMap c R θ ≠ w at hθ 
  simp only [inv_smul_smul₀ (sub_ne_zero.2 <| hθ)]
#align circle_integral.integral_sub_inv_smul_sub_smul circleIntegral.integral_sub_inv_smul_sub_smul
-/

#print circleIntegral.integral_undef /-
theorem integral_undef {f : ℂ → E} {c : ℂ} {R : ℝ} (hf : ¬CircleIntegrable f c R) :
    ∮ z in C(c, R), f z = 0 :=
  intervalIntegral.integral_undef (mt (circleIntegrable_iff R).mpr hf)
#align circle_integral.integral_undef circleIntegral.integral_undef
-/

#print circleIntegral.integral_sub /-
theorem integral_sub {f g : ℂ → E} {c : ℂ} {R : ℝ} (hf : CircleIntegrable f c R)
    (hg : CircleIntegrable g c R) :
    ∮ z in C(c, R), f z - g z = (∮ z in C(c, R), f z) - ∮ z in C(c, R), g z := by
  simp only [circleIntegral, smul_sub, intervalIntegral.integral_sub hf.out hg.out]
#align circle_integral.integral_sub circleIntegral.integral_sub
-/

#print circleIntegral.norm_integral_le_of_norm_le_const' /-
theorem norm_integral_le_of_norm_le_const' {f : ℂ → E} {c : ℂ} {R C : ℝ}
    (hf : ∀ z ∈ sphere c (|R|), ‖f z‖ ≤ C) : ‖∮ z in C(c, R), f z‖ ≤ 2 * π * |R| * C :=
  calc
    ‖∮ z in C(c, R), f z‖ ≤ |R| * C * |2 * π - 0| :=
      intervalIntegral.norm_integral_le_of_norm_le_const fun θ _ =>
        calc
          ‖deriv (circleMap c R) θ • f (circleMap c R θ)‖ = |R| * ‖f (circleMap c R θ)‖ := by
            simp [norm_smul]
          _ ≤ |R| * C :=
            mul_le_mul_of_nonneg_left (hf _ <| circleMap_mem_sphere' _ _ _) (abs_nonneg _)
    _ = 2 * π * |R| * C := by rw [sub_zero, _root_.abs_of_pos Real.two_pi_pos]; ac_rfl
#align circle_integral.norm_integral_le_of_norm_le_const' circleIntegral.norm_integral_le_of_norm_le_const'
-/

#print circleIntegral.norm_integral_le_of_norm_le_const /-
theorem norm_integral_le_of_norm_le_const {f : ℂ → E} {c : ℂ} {R C : ℝ} (hR : 0 ≤ R)
    (hf : ∀ z ∈ sphere c R, ‖f z‖ ≤ C) : ‖∮ z in C(c, R), f z‖ ≤ 2 * π * R * C :=
  have : |R| = R := abs_of_nonneg hR
  calc
    ‖∮ z in C(c, R), f z‖ ≤ 2 * π * |R| * C := norm_integral_le_of_norm_le_const' <| by rwa [this]
    _ = 2 * π * R * C := by rw [this]
#align circle_integral.norm_integral_le_of_norm_le_const circleIntegral.norm_integral_le_of_norm_le_const
-/

#print circleIntegral.norm_two_pi_i_inv_smul_integral_le_of_norm_le_const /-
theorem norm_two_pi_i_inv_smul_integral_le_of_norm_le_const {f : ℂ → E} {c : ℂ} {R C : ℝ}
    (hR : 0 ≤ R) (hf : ∀ z ∈ sphere c R, ‖f z‖ ≤ C) :
    ‖(2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), f z‖ ≤ R * C :=
  by
  have : ‖(2 * π * I : ℂ)⁻¹‖ = (2 * π)⁻¹ := by simp [real.pi_pos.le]
  rw [norm_smul, this, ← div_eq_inv_mul, div_le_iff Real.two_pi_pos, mul_comm (R * C), ← mul_assoc]
  exact norm_integral_le_of_norm_le_const hR hf
#align circle_integral.norm_two_pi_I_inv_smul_integral_le_of_norm_le_const circleIntegral.norm_two_pi_i_inv_smul_integral_le_of_norm_le_const
-/

#print circleIntegral.norm_integral_lt_of_norm_le_const_of_lt /-
/-- If `f` is continuous on the circle `|z - c| = R`, `R > 0`, the `‖f z‖` is less than or equal to
`C : ℝ` on this circle, and this norm is strictly less than `C` at some point `z` of the circle,
then `‖∮ z in C(c, R), f z‖ < 2 * π * R * C`. -/
theorem norm_integral_lt_of_norm_le_const_of_lt {f : ℂ → E} {c : ℂ} {R C : ℝ} (hR : 0 < R)
    (hc : ContinuousOn f (sphere c R)) (hf : ∀ z ∈ sphere c R, ‖f z‖ ≤ C)
    (hlt : ∃ z ∈ sphere c R, ‖f z‖ < C) : ‖∮ z in C(c, R), f z‖ < 2 * π * R * C :=
  by
  rw [← _root_.abs_of_pos hR, ← image_circleMap_Ioc] at hlt 
  rcases hlt with ⟨_, ⟨θ₀, hmem, rfl⟩, hlt⟩
  calc
    ‖∮ z in C(c, R), f z‖ ≤ ∫ θ in 0 ..2 * π, ‖deriv (circleMap c R) θ • f (circleMap c R θ)‖ :=
      intervalIntegral.norm_integral_le_integral_norm real.two_pi_pos.le
    _ < ∫ θ in 0 ..2 * π, R * C :=
      by
      simp only [norm_smul, deriv_circleMap, norm_eq_abs, map_mul, abs_I, mul_one,
        abs_circleMap_zero, abs_of_pos hR]
      refine'
        intervalIntegral.integral_lt_integral_of_continuousOn_of_le_of_exists_lt Real.two_pi_pos _
          continuousOn_const (fun θ hθ => _) ⟨θ₀, Ioc_subset_Icc_self hmem, _⟩
      ·
        exact
          continuous_on_const.mul
            (hc.comp (continuous_circleMap _ _).ContinuousOn fun θ hθ =>
                circleMap_mem_sphere _ hR.le _).norm
      · exact mul_le_mul_of_nonneg_left (hf _ <| circleMap_mem_sphere _ hR.le _) hR.le
      · exact (mul_lt_mul_left hR).2 hlt
    _ = 2 * π * R * C := by simp [mul_assoc]
#align circle_integral.norm_integral_lt_of_norm_le_const_of_lt circleIntegral.norm_integral_lt_of_norm_le_const_of_lt
-/

#print circleIntegral.integral_smul /-
@[simp]
theorem integral_smul {𝕜 : Type _} [IsROrC 𝕜] [NormedSpace 𝕜 E] [SMulCommClass 𝕜 ℂ E] (a : 𝕜)
    (f : ℂ → E) (c : ℂ) (R : ℝ) : ∮ z in C(c, R), a • f z = a • ∮ z in C(c, R), f z := by
  simp only [circleIntegral, ← smul_comm a, intervalIntegral.integral_smul]
#align circle_integral.integral_smul circleIntegral.integral_smul
-/

#print circleIntegral.integral_smul_const /-
@[simp]
theorem integral_smul_const (f : ℂ → ℂ) (a : E) (c : ℂ) (R : ℝ) :
    ∮ z in C(c, R), f z • a = (∮ z in C(c, R), f z) • a := by
  simp only [circleIntegral, intervalIntegral.integral_smul_const, ← smul_assoc]
#align circle_integral.integral_smul_const circleIntegral.integral_smul_const
-/

#print circleIntegral.integral_const_mul /-
@[simp]
theorem integral_const_mul (a : ℂ) (f : ℂ → ℂ) (c : ℂ) (R : ℝ) :
    ∮ z in C(c, R), a * f z = a * ∮ z in C(c, R), f z :=
  integral_smul a f c R
#align circle_integral.integral_const_mul circleIntegral.integral_const_mul
-/

#print circleIntegral.integral_sub_center_inv /-
@[simp]
theorem integral_sub_center_inv (c : ℂ) {R : ℝ} (hR : R ≠ 0) :
    ∮ z in C(c, R), (z - c)⁻¹ = 2 * π * I := by
  simp [circleIntegral, ← div_eq_mul_inv, mul_div_cancel_left _ (circleMap_ne_center hR)]
#align circle_integral.integral_sub_center_inv circleIntegral.integral_sub_center_inv
-/

#print circleIntegral.integral_eq_zero_of_hasDerivWithinAt' /-
/-- If `f' : ℂ → E` is a derivative of a complex differentiable function on the circle
`metric.sphere c |R|`, then `∮ z in C(c, R), f' z = 0`. -/
theorem integral_eq_zero_of_hasDerivWithinAt' {f f' : ℂ → E} {c : ℂ} {R : ℝ}
    (h : ∀ z ∈ sphere c (|R|), HasDerivWithinAt f (f' z) (sphere c (|R|)) z) :
    ∮ z in C(c, R), f' z = 0 :=
  by
  by_cases hi : CircleIntegrable f' c R
  · rw [← sub_eq_zero.2 ((periodic_circleMap c R).comp f).Eq]
    refine' intervalIntegral.integral_eq_sub_of_hasDerivAt (fun θ hθ => _) hi.out
    exact
      (h _ (circleMap_mem_sphere' _ _ _)).scomp_hasDerivAt θ
        (differentiable_circleMap _ _ _).HasDerivAt (circleMap_mem_sphere' _ _)
  · exact integral_undef hi
#align circle_integral.integral_eq_zero_of_has_deriv_within_at' circleIntegral.integral_eq_zero_of_hasDerivWithinAt'
-/

#print circleIntegral.integral_eq_zero_of_hasDerivWithinAt /-
/-- If `f' : ℂ → E` is a derivative of a complex differentiable function on the circle
`metric.sphere c R`, then `∮ z in C(c, R), f' z = 0`. -/
theorem integral_eq_zero_of_hasDerivWithinAt {f f' : ℂ → E} {c : ℂ} {R : ℝ} (hR : 0 ≤ R)
    (h : ∀ z ∈ sphere c R, HasDerivWithinAt f (f' z) (sphere c R) z) : ∮ z in C(c, R), f' z = 0 :=
  integral_eq_zero_of_hasDerivWithinAt' <| (abs_of_nonneg hR).symm.subst h
#align circle_integral.integral_eq_zero_of_has_deriv_within_at circleIntegral.integral_eq_zero_of_hasDerivWithinAt
-/

#print circleIntegral.integral_sub_zpow_of_undef /-
/-- If `n < 0` and `|w - c| = |R|`, then `(z - w) ^ n` is not circle integrable on the circle with
center `c` and radius `(|R|)`, so the integral `∮ z in C(c, R), (z - w) ^ n` is equal to zero. -/
theorem integral_sub_zpow_of_undef {n : ℤ} {c w : ℂ} {R : ℝ} (hn : n < 0)
    (hw : w ∈ sphere c (|R|)) : ∮ z in C(c, R), (z - w) ^ n = 0 :=
  by
  rcases eq_or_ne R 0 with (rfl | h0); · apply integral_radius_zero
  apply integral_undef
  simp [circleIntegrable_sub_zpow_iff, *]
#align circle_integral.integral_sub_zpow_of_undef circleIntegral.integral_sub_zpow_of_undef
-/

#print circleIntegral.integral_sub_zpow_of_ne /-
/-- If `n ≠ -1` is an integer number, then the integral of `(z - w) ^ n` over the circle equals
zero. -/
theorem integral_sub_zpow_of_ne {n : ℤ} (hn : n ≠ -1) (c w : ℂ) (R : ℝ) :
    ∮ z in C(c, R), (z - w) ^ n = 0 :=
  by
  rcases em (w ∈ sphere c (|R|) ∧ n < -1) with (⟨hw, hn⟩ | H)
  · exact integral_sub_zpow_of_undef (hn.trans (by decide)) hw
  push_neg at H 
  have hd :
    ∀ z, z ≠ w ∨ -1 ≤ n → HasDerivAt (fun z => (z - w) ^ (n + 1) / (n + 1)) ((z - w) ^ n) z :=
    by
    intro z hne
    convert
      ((hasDerivAt_zpow (n + 1) _ (hne.imp _ _)).comp z ((hasDerivAt_id z).sub_const w)).div_const
        _ using
      1
    · have hn' : (n + 1 : ℂ) ≠ 0 := by
        rwa [Ne, ← eq_neg_iff_add_eq_zero, ← Int.cast_one, ← Int.cast_neg, Int.cast_inj]
      simp [mul_assoc, mul_div_cancel_left _ hn']
    exacts [sub_ne_zero.2, neg_le_iff_add_nonneg.1]
  refine' integral_eq_zero_of_has_deriv_within_at' fun z hz => (hd z _).HasDerivWithinAt
  exact (ne_or_eq z w).imp_right fun h => H <| h ▸ hz
#align circle_integral.integral_sub_zpow_of_ne circleIntegral.integral_sub_zpow_of_ne
-/

end circleIntegral

#print cauchyPowerSeries /-
/-- The power series that is equal to
$\sum_{n=0}^{\infty} \oint_{|z-c|=R} \left(\frac{w-c}{z - c}\right)^n \frac{1}{z-c}f(z)\,dz$ at
`w - c`. The coefficients of this power series depend only on `f ∘ circle_map c R`, and the power
series converges to `f w` if `f` is differentiable on the closed ball `metric.closed_ball c R` and
`w` belongs to the corresponding open ball. For any circle integrable function `f`, this power
series converges to the Cauchy integral for `f`. -/
def cauchyPowerSeries (f : ℂ → E) (c : ℂ) (R : ℝ) : FormalMultilinearSeries ℂ ℂ E := fun n =>
  ContinuousMultilinearMap.mkPiField ℂ _ <|
    (2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), (z - c)⁻¹ ^ n • (z - c)⁻¹ • f z
#align cauchy_power_series cauchyPowerSeries
-/

#print cauchyPowerSeries_apply /-
theorem cauchyPowerSeries_apply (f : ℂ → E) (c : ℂ) (R : ℝ) (n : ℕ) (w : ℂ) :
    (cauchyPowerSeries f c R n fun _ => w) =
      (2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), (w / (z - c)) ^ n • (z - c)⁻¹ • f z :=
  by
  simp only [cauchyPowerSeries, ContinuousMultilinearMap.mkPiField_apply, Fin.prod_const,
    div_eq_mul_inv, mul_pow, mul_smul, circleIntegral.integral_smul, ← smul_comm (w ^ n)]
#align cauchy_power_series_apply cauchyPowerSeries_apply
-/

#print norm_cauchyPowerSeries_le /-
theorem norm_cauchyPowerSeries_le (f : ℂ → E) (c : ℂ) (R : ℝ) (n : ℕ) :
    ‖cauchyPowerSeries f c R n‖ ≤
      ((2 * π)⁻¹ * ∫ θ : ℝ in 0 ..2 * π, ‖f (circleMap c R θ)‖) * (|R|)⁻¹ ^ n :=
  calc
    ‖cauchyPowerSeries f c R n‖ = (2 * π)⁻¹ * ‖∮ z in C(c, R), (z - c)⁻¹ ^ n • (z - c)⁻¹ • f z‖ :=
      by simp [cauchyPowerSeries, norm_smul, real.pi_pos.le]
    _ ≤
        (2 * π)⁻¹ *
          ∫ θ in 0 ..2 * π,
            ‖deriv (circleMap c R) θ •
                (circleMap c R θ - c)⁻¹ ^ n • (circleMap c R θ - c)⁻¹ • f (circleMap c R θ)‖ :=
      (mul_le_mul_of_nonneg_left
        (intervalIntegral.norm_integral_le_integral_norm Real.two_pi_pos.le)
        (by simp [real.pi_pos.le]))
    _ =
        (2 * π)⁻¹ *
          ((|R|)⁻¹ ^ n * (|R| * ((|R|)⁻¹ * ∫ x : ℝ in 0 ..2 * π, ‖f (circleMap c R x)‖))) :=
      by simp [norm_smul, mul_left_comm (|R|)]
    _ ≤ ((2 * π)⁻¹ * ∫ θ : ℝ in 0 ..2 * π, ‖f (circleMap c R θ)‖) * (|R|)⁻¹ ^ n :=
      by
      rcases eq_or_ne R 0 with (rfl | hR)
      · cases n <;> simp [-mul_inv_rev, Real.two_pi_pos]
      · rw [mul_inv_cancel_left₀, mul_assoc, mul_comm ((|R|)⁻¹ ^ n)]
        rwa [Ne.def, _root_.abs_eq_zero]
#align norm_cauchy_power_series_le norm_cauchyPowerSeries_le
-/

#print le_radius_cauchyPowerSeries /-
theorem le_radius_cauchyPowerSeries (f : ℂ → E) (c : ℂ) (R : ℝ≥0) :
    ↑R ≤ (cauchyPowerSeries f c R).radius :=
  by
  refine'
    (cauchyPowerSeries f c R).le_radius_of_bound
      ((2 * π)⁻¹ * ∫ θ : ℝ in 0 ..2 * π, ‖f (circleMap c R θ)‖) fun n => _
  refine'
    (mul_le_mul_of_nonneg_right (norm_cauchyPowerSeries_le _ _ _ _)
          (pow_nonneg R.coe_nonneg _)).trans
      _
  rw [_root_.abs_of_nonneg R.coe_nonneg]
  cases' eq_or_ne (R ^ n : ℝ) 0 with hR hR
  · rw [hR, MulZeroClass.mul_zero]
    exact
      mul_nonneg (inv_nonneg.2 real.two_pi_pos.le)
        (intervalIntegral.integral_nonneg real.two_pi_pos.le fun _ _ => norm_nonneg _)
  · rw [inv_pow, inv_mul_cancel_right₀ hR]
#align le_radius_cauchy_power_series le_radius_cauchyPowerSeries
-/

#print hasSum_two_pi_I_cauchyPowerSeries_integral /-
/-- For any circle integrable function `f`, the power series `cauchy_power_series f c R` multiplied
by `2πI` converges to the integral `∮ z in C(c, R), (z - w)⁻¹ • f z` on the open disc
`metric.ball c R`. -/
theorem hasSum_two_pi_I_cauchyPowerSeries_integral {f : ℂ → E} {c : ℂ} {R : ℝ} {w : ℂ}
    (hf : CircleIntegrable f c R) (hw : abs w < R) :
    HasSum (fun n : ℕ => ∮ z in C(c, R), (w / (z - c)) ^ n • (z - c)⁻¹ • f z)
      (∮ z in C(c, R), (z - (c + w))⁻¹ • f z) :=
  by
  have hR : 0 < R := (complex.abs.nonneg w).trans_lt hw
  have hwR : abs w / R ∈ Ico (0 : ℝ) 1 :=
    ⟨div_nonneg (complex.abs.nonneg w) hR.le, (div_lt_one hR).2 hw⟩
  refine'
    intervalIntegral.hasSum_integral_of_dominated_convergence
      (fun n θ => ‖f (circleMap c R θ)‖ * (abs w / R) ^ n) (fun n => _) (fun n => _) _ _ _
  · simp only [deriv_circleMap]
    apply_rules [ae_strongly_measurable.smul, hf.def.1] <;>
      · apply Measurable.aestronglyMeasurable; measurability
  · simp [norm_smul, abs_of_pos hR, mul_left_comm R, mul_inv_cancel_left₀ hR.ne', mul_comm ‖_‖]
  · exact eventually_of_forall fun _ _ => (summable_geometric_of_lt_1 hwR.1 hwR.2).mul_left _
  ·
    simpa only [tsum_mul_left, tsum_geometric_of_lt_1 hwR.1 hwR.2] using
      hf.norm.mul_continuous_on continuousOn_const
  · refine' eventually_of_forall fun θ hθ => HasSum.const_smul _ _
    simp only [smul_smul]
    refine' HasSum.smul_const _ _
    have : ‖w / (circleMap c R θ - c)‖ < 1 := by simpa [abs_of_pos hR] using hwR.2
    convert (hasSum_geometric_of_norm_lt_1 this).mul_right _
    simp [← sub_sub, ← mul_inv, sub_mul, div_mul_cancel _ (circleMap_ne_center hR.ne')]
#align has_sum_two_pi_I_cauchy_power_series_integral hasSum_two_pi_I_cauchyPowerSeries_integral
-/

#print hasSum_cauchyPowerSeries_integral /-
/-- For any circle integrable function `f`, the power series `cauchy_power_series f c R`, `R > 0`,
converges to the Cauchy integral `(2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), (z - w)⁻¹ • f z` on the open
disc `metric.ball c R`. -/
theorem hasSum_cauchyPowerSeries_integral {f : ℂ → E} {c : ℂ} {R : ℝ} {w : ℂ}
    (hf : CircleIntegrable f c R) (hw : abs w < R) :
    HasSum (fun n => cauchyPowerSeries f c R n fun _ => w)
      ((2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), (z - (c + w))⁻¹ • f z) :=
  by
  simp only [cauchyPowerSeries_apply]
  exact (hasSum_two_pi_I_cauchyPowerSeries_integral hf hw).const_smul _
#align has_sum_cauchy_power_series_integral hasSum_cauchyPowerSeries_integral
-/

#print sum_cauchyPowerSeries_eq_integral /-
/-- For any circle integrable function `f`, the power series `cauchy_power_series f c R`, `R > 0`,
converges to the Cauchy integral `(2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), (z - w)⁻¹ • f z` on the open
disc `metric.ball c R`. -/
theorem sum_cauchyPowerSeries_eq_integral {f : ℂ → E} {c : ℂ} {R : ℝ} {w : ℂ}
    (hf : CircleIntegrable f c R) (hw : abs w < R) :
    (cauchyPowerSeries f c R).Sum w = (2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), (z - (c + w))⁻¹ • f z :=
  (hasSum_cauchyPowerSeries_integral hf hw).tsum_eq
#align sum_cauchy_power_series_eq_integral sum_cauchyPowerSeries_eq_integral
-/

#print hasFPowerSeriesOn_cauchy_integral /-
/-- For any circle integrable function `f`, the power series `cauchy_power_series f c R`, `R > 0`,
converges to the Cauchy integral `(2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), (z - w)⁻¹ • f z` on the open
disc `metric.ball c R`. -/
theorem hasFPowerSeriesOn_cauchy_integral {f : ℂ → E} {c : ℂ} {R : ℝ≥0}
    (hf : CircleIntegrable f c R) (hR : 0 < R) :
    HasFPowerSeriesOnBall (fun w => (2 * π * I : ℂ)⁻¹ • ∮ z in C(c, R), (z - w)⁻¹ • f z)
      (cauchyPowerSeries f c R) c R :=
  { r_le := le_radius_cauchyPowerSeries _ _ _
    r_pos := ENNReal.coe_pos.2 hR
    HasSum := fun y hy => by
      refine' hasSum_cauchyPowerSeries_integral hf _
      rw [← norm_eq_abs, ← coe_nnnorm, NNReal.coe_lt_coe, ← ENNReal.coe_lt_coe]
      exact mem_emetric_ball_zero_iff.1 hy }
#align has_fpower_series_on_cauchy_integral hasFPowerSeriesOn_cauchy_integral
-/

namespace circleIntegral

#print circleIntegral.integral_sub_inv_of_mem_ball /-
/-- Integral $\oint_{|z-c|=R} \frac{dz}{z-w}=2πi$ whenever $|w-c|<R$. -/
theorem integral_sub_inv_of_mem_ball {c w : ℂ} {R : ℝ} (hw : w ∈ ball c R) :
    ∮ z in C(c, R), (z - w)⁻¹ = 2 * π * I :=
  by
  have hR : 0 < R := dist_nonneg.trans_lt hw
  suffices H : HasSum (fun n : ℕ => ∮ z in C(c, R), ((w - c) / (z - c)) ^ n * (z - c)⁻¹) (2 * π * I)
  · have A : CircleIntegrable (fun _ => (1 : ℂ)) c R := continuous_on_const.circle_integrable'
    refine' (H.unique _).symm
    simpa only [smul_eq_mul, mul_one, add_sub_cancel'_right] using
      hasSum_two_pi_I_cauchyPowerSeries_integral A hw
  have H : ∀ n : ℕ, n ≠ 0 → ∮ z in C(c, R), (z - c) ^ (-n - 1 : ℤ) = 0 := by
    refine' fun n hn => integral_sub_zpow_of_ne _ _ _ _; simpa
  have : ∮ z in C(c, R), ((w - c) / (z - c)) ^ 0 * (z - c)⁻¹ = 2 * π * I := by simp [hR.ne']
  refine' this ▸ hasSum_single _ fun n hn => _
  simp only [div_eq_mul_inv, mul_pow, integral_const_mul, mul_assoc]
  rw [(integral_congr hR.le fun z hz => _).trans (H n hn), MulZeroClass.mul_zero]
  rw [← pow_succ', ← zpow_ofNat, inv_zpow, ← zpow_neg, Int.ofNat_succ, neg_add,
    sub_eq_add_neg _ (1 : ℤ)]
#align circle_integral.integral_sub_inv_of_mem_ball circleIntegral.integral_sub_inv_of_mem_ball
-/

end circleIntegral

