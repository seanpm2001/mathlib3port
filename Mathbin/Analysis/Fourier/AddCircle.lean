/-
Copyright (c) 2021 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth, David Loeffler

! This file was ported from Lean 3 source module analysis.fourier.add_circle
! leanprover-community/mathlib commit e8e130de9dba4ed6897183c3193c752ffadbcc77
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.ExpDeriv
import Mathbin.Analysis.SpecialFunctions.Complex.Circle
import Mathbin.Analysis.InnerProductSpace.L2Space
import Mathbin.MeasureTheory.Function.ContinuousMapDense
import Mathbin.MeasureTheory.Function.L2Space
import Mathbin.MeasureTheory.Group.Integration
import Mathbin.MeasureTheory.Integral.Periodic
import Mathbin.Topology.ContinuousFunction.StoneWeierstrass
import Mathbin.MeasureTheory.Integral.FundThmCalculus

/-!

# Fourier analysis on the additive circle

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains basic results on Fourier series for functions on the additive circle
`add_circle T = ℝ / ℤ • T`.

## Main definitions

* `haar_add_circle`, Haar measure on `add_circle T`, normalized to have total measure `1`. (Note
  that this is not the same normalisation as the standard measure defined in `integral.periodic`,
  so we do not declare it as a `measure_space` instance, to avoid confusion.)
* for `n : ℤ`, `fourier n` is the monomial `λ x, exp (2 π i n x / T)`, bundled as a continuous map
  from `add_circle T` to `ℂ`.
* `fourier_basis` is the Hilbert basis of `Lp ℂ 2 haar_add_circle` given by the images of the
  monomials `fourier n`.
* `fourier_coeff f n`, for `f : add_circle T → E` (with `E` a complete normed `ℂ`-vector space), is
  the `n`-th Fourier coefficient of `f`, defined as an integral over `add_circle T`. The lemma
  `fourier_coeff_eq_interval_integral` expresses this as an integral over `[a, a + T]` for any real
  `a`.
* `fourier_coeff_on`, for `f : ℝ → E` and `a < b` reals, is the `n`-th Fourier
  coefficient of the unique periodic function of period `b - a` which agrees with `f` on `(a, b]`.
  The lemma `fourier_coeff_on_eq_integral` expresses this as an integral over `[a, b]`.

## Main statements

The theorem `span_fourier_closure_eq_top` states that the span of the monomials `fourier n` is
dense in `C(add_circle T, ℂ)`, i.e. that its `submodule.topological_closure` is `⊤`.  This follows
from the Stone-Weierstrass theorem after checking that the span is a subalgebra, is closed under
conjugation, and separates points.

Using this and general theory on approximation of Lᵖ functions by continuous functions, we deduce
(`span_fourier_Lp_closure_eq_top`) that for any `1 ≤ p < ∞`, the span of the Fourier monomials is
dense in the Lᵖ space of `add_circle T`. For `p = 2` we show (`orthonormal_fourier`) that the
monomials are also orthonormal, so they form a Hilbert basis for L², which is named as
`fourier_basis`; in particular, for `L²` functions `f`, the Fourier series of `f` converges to `f`
in the `L²` topology (`has_sum_fourier_series_L2`). Parseval's identity, `tsum_sq_fourier_coeff`, is
a direct consequence.

For continuous maps `f : add_circle T → ℂ`, the theorem
`continuous_map.has_sum_fourier_series_of_summable` states that if the sequence of Fourier
coefficients of `f` is summable, then the Fourier series `∑ (i:ℤ), f.fourier_coeff i * fourier i`
converges to `f` in the uniform-convergence topology of `C(add_circle T, ℂ)`.
-/


noncomputable section

open scoped ENNReal ComplexConjugate Real

open TopologicalSpace ContinuousMap MeasureTheory MeasureTheory.Measure Algebra Submodule Set

variable {T : ℝ}

namespace AddCircle

/-! ### Map from `add_circle` to `circle` -/


#print AddCircle.scaled_exp_map_periodic /-
theorem scaled_exp_map_periodic : Function.Periodic (fun x => expMapCircle (2 * π / T * x)) T :=
  by
  -- The case T = 0 is not interesting, but it is true, so we prove it to save hypotheses
  rcases eq_or_ne T 0 with (rfl | hT)
  · intro x; simp
  · intro x; simp_rw [mul_add]; rw [div_mul_cancel _ hT, periodic_expMapCircle]
#align add_circle.scaled_exp_map_periodic AddCircle.scaled_exp_map_periodic
-/

#print AddCircle.toCircle /-
/-- The canonical map `λ x, exp (2 π i x / T)` from `ℝ / ℤ • T` to the unit circle in `ℂ`.
If `T = 0` we understand this as the constant function 1. -/
def toCircle : AddCircle T → circle :=
  (@scaled_exp_map_periodic T).lift
#align add_circle.to_circle AddCircle.toCircle
-/

#print AddCircle.toCircle_add /-
theorem toCircle_add (x : AddCircle T) (y : AddCircle T) :
    toCircle (x + y) = toCircle x * toCircle y :=
  by
  induction x using QuotientAddGroup.induction_on'
  induction y using QuotientAddGroup.induction_on'
  simp_rw [← QuotientAddGroup.mk_add, to_circle, Function.Periodic.lift_coe, mul_add,
    expMapCircle_add]
#align add_circle.to_circle_add AddCircle.toCircle_add
-/

#print AddCircle.continuous_toCircle /-
theorem continuous_toCircle : Continuous (@toCircle T) :=
  continuous_coinduced_dom.mpr (expMapCircle.Continuous.comp <| continuous_const.mul continuous_id')
#align add_circle.continuous_to_circle AddCircle.continuous_toCircle
-/

#print AddCircle.injective_toCircle /-
theorem injective_toCircle (hT : T ≠ 0) : Function.Injective (@toCircle T) :=
  by
  intro a b h
  induction a using QuotientAddGroup.induction_on'
  induction b using QuotientAddGroup.induction_on'
  simp_rw [to_circle, Function.Periodic.lift_coe] at h 
  obtain ⟨m, hm⟩ := exp_map_circle_eq_exp_map_circle.mp h.symm
  simp_rw [QuotientAddGroup.eq, AddSubgroup.mem_zmultiples_iff, zsmul_eq_mul]
  use m
  field_simp [real.two_pi_pos.ne'] at hm 
  rw [← mul_right_inj' real.two_pi_pos.ne']
  linarith
#align add_circle.injective_to_circle AddCircle.injective_toCircle
-/

/-! ### Measure on `add_circle T`

In this file we use the Haar measure on `add_circle T` normalised to have total measure 1 (which is
**not** the same as the standard measure defined in `topology.instances.add_circle`). -/


variable [hT : Fact (0 < T)]

#print AddCircle.haarAddCircle /-
/-- Haar measure on the additive circle, normalised to have total measure 1. -/
def haarAddCircle : Measure (AddCircle T) :=
  addHaarMeasure ⊤
deriving IsAddHaarMeasure
#align add_circle.haar_add_circle AddCircle.haarAddCircle
-/

instance : IsProbabilityMeasure (@haarAddCircle T _) :=
  IsProbabilityMeasure.mk addHaarMeasure_self

#print AddCircle.volume_eq_smul_haarAddCircle /-
theorem volume_eq_smul_haarAddCircle :
    (volume : Measure (AddCircle T)) = ENNReal.ofReal T • haarAddCircle :=
  rfl
#align add_circle.volume_eq_smul_haar_add_circle AddCircle.volume_eq_smul_haarAddCircle
-/

end AddCircle

open AddCircle

section Monomials

#print fourier /-
/-- The family of exponential monomials `λ x, exp (2 π i n x / T)`, parametrized by `n : ℤ` and
considered as bundled continuous maps from `ℝ / ℤ • T` to `ℂ`. -/
def fourier (n : ℤ) : C(AddCircle T, ℂ)
    where
  toFun x := toCircle (n • x)
  continuous_toFun := continuous_induced_dom.comp <| continuous_toCircle.comp <| continuous_zsmul _
#align fourier fourier
-/

#print fourier_apply /-
@[simp]
theorem fourier_apply {n : ℤ} {x : AddCircle T} : fourier n x = toCircle (n • x) :=
  rfl
#align fourier_apply fourier_apply
-/

#print fourier_coe_apply /-
@[simp]
theorem fourier_coe_apply {n : ℤ} {x : ℝ} :
    fourier n (x : AddCircle T) = Complex.exp (2 * π * Complex.I * n * x / T) :=
  by
  rw [fourier_apply, ← QuotientAddGroup.mk_zsmul, to_circle, Function.Periodic.lift_coe,
    expMapCircle_apply, Complex.ofReal_mul, Complex.ofReal_div, Complex.ofReal_mul, zsmul_eq_mul,
    Complex.ofReal_mul, Complex.ofReal_int_cast, Complex.ofReal_bit0, Complex.ofReal_one]
  congr 1; ring
#align fourier_coe_apply fourier_coe_apply
-/

#print fourier_zero /-
@[simp]
theorem fourier_zero {x : AddCircle T} : fourier 0 x = 1 :=
  by
  induction x using QuotientAddGroup.induction_on'
  simp only [fourier_coe_apply, algebraMap.coe_zero, MulZeroClass.mul_zero, MulZeroClass.zero_mul,
    zero_div, Complex.exp_zero]
#align fourier_zero fourier_zero
-/

#print fourier_eval_zero /-
@[simp]
theorem fourier_eval_zero (n : ℤ) : fourier n (0 : AddCircle T) = 1 := by
  rw [← QuotientAddGroup.mk_zero, fourier_coe_apply, Complex.ofReal_zero, MulZeroClass.mul_zero,
    zero_div, Complex.exp_zero]
#align fourier_eval_zero fourier_eval_zero
-/

#print fourier_one /-
@[simp]
theorem fourier_one {x : AddCircle T} : fourier 1 x = toCircle x := by rw [fourier_apply, one_zsmul]
#align fourier_one fourier_one
-/

#print fourier_neg /-
@[simp]
theorem fourier_neg {n : ℤ} {x : AddCircle T} : fourier (-n) x = conj (fourier n x) :=
  by
  induction x using QuotientAddGroup.induction_on'
  simp_rw [fourier_apply, to_circle, ← QuotientAddGroup.mk_zsmul, Function.Periodic.lift_coe, ←
    coe_inv_circle_eq_conj, ← expMapCircle_neg, neg_smul, mul_neg]
#align fourier_neg fourier_neg
-/

#print fourier_add /-
@[simp]
theorem fourier_add {m n : ℤ} {x : AddCircle T} : fourier (m + n) x = fourier m x * fourier n x :=
  by simp_rw [fourier_apply, add_zsmul, to_circle_add, coe_mul_unitSphere]
#align fourier_add fourier_add
-/

#print fourier_norm /-
theorem fourier_norm [Fact (0 < T)] (n : ℤ) : ‖@fourier T n‖ = 1 :=
  by
  rw [ContinuousMap.norm_eq_iSup_norm]
  have : ∀ x : AddCircle T, ‖fourier n x‖ = 1 := fun x => abs_coe_circle _
  simp_rw [this]
  exact @ciSup_const _ _ _ Zero.nonempty _
#align fourier_norm fourier_norm
-/

#print fourier_add_half_inv_index /-
/-- For `n ≠ 0`, a translation by `T / 2 / n` negates the function `fourier n`. -/
theorem fourier_add_half_inv_index {n : ℤ} (hn : n ≠ 0) (hT : 0 < T) (x : AddCircle T) :
    fourier n (x + (T / 2 / n : ℝ)) = -fourier n x :=
  by
  rw [fourier_apply, zsmul_add, ← QuotientAddGroup.mk_zsmul, to_circle_add, coe_mul_unitSphere]
  have : (n : ℂ) ≠ 0 := by simpa using hn
  have : (@to_circle T (n • (T / 2 / n) : ℝ) : ℂ) = -1 :=
    by
    rw [zsmul_eq_mul, to_circle, Function.Periodic.lift_coe, expMapCircle_apply]
    replace hT := complex.of_real_ne_zero.mpr hT.ne'
    convert Complex.exp_pi_mul_I using 3
    field_simp; ring
  rw [this]; simp
#align fourier_add_half_inv_index fourier_add_half_inv_index
-/

#print fourierSubalgebra /-
/-- The subalgebra of `C(add_circle T, ℂ)` generated by `fourier n` for `n ∈ ℤ` . -/
def fourierSubalgebra : Subalgebra ℂ C(AddCircle T, ℂ) :=
  Algebra.adjoin ℂ (range fourier)
#align fourier_subalgebra fourierSubalgebra
-/

#print fourierSubalgebra_coe /-
/-- The subalgebra of `C(add_circle T, ℂ)` generated by `fourier n` for `n ∈ ℤ` is in fact the
linear span of these functions. -/
theorem fourierSubalgebra_coe : (@fourierSubalgebra T).toSubmodule = span ℂ (range fourier) :=
  by
  apply adjoin_eq_span_of_subset
  refine' subset.trans _ Submodule.subset_span
  intro x hx
  apply Submonoid.closure_induction hx (fun _ => id) ⟨0, _⟩
  · rintro _ _ ⟨m, rfl⟩ ⟨n, rfl⟩
    refine' ⟨m + n, _⟩
    ext1 z
    exact fourier_add
  · ext1 z; exact fourier_zero
#align fourier_subalgebra_coe fourierSubalgebra_coe
-/

#print fourierSubalgebra_conj_invariant /-
/-- The subalgebra of `C(add_circle T, ℂ)` generated by `fourier n` for `n ∈ ℤ` is invariant under
complex conjugation. -/
theorem fourierSubalgebra_conj_invariant :
    ConjInvariantSubalgebra ((@fourierSubalgebra T).restrictScalars ℝ) :=
  by
  apply subalgebra_conj_invariant
  rintro _ ⟨n, rfl⟩
  exact ⟨-n, ext fun _ => fourier_neg⟩
#align fourier_subalgebra_conj_invariant fourierSubalgebra_conj_invariant
-/

variable [hT : Fact (0 < T)]

#print fourierSubalgebra_separatesPoints /-
/-- The subalgebra of `C(add_circle T, ℂ)` generated by `fourier n` for `n ∈ ℤ`
separates points. -/
theorem fourierSubalgebra_separatesPoints : (@fourierSubalgebra T).SeparatesPoints :=
  by
  intro x y hxy
  refine' ⟨_, ⟨fourier 1, subset_adjoin ⟨1, rfl⟩, rfl⟩, _⟩
  dsimp only; rw [fourier_one, fourier_one]
  contrapose! hxy
  rw [Subtype.coe_inj] at hxy 
  exact injective_to_circle hT.elim.ne' hxy
#align fourier_subalgebra_separates_points fourierSubalgebra_separatesPoints
-/

#print fourierSubalgebra_closure_eq_top /-
/-- The subalgebra of `C(add_circle T, ℂ)` generated by `fourier n` for `n ∈ ℤ` is dense. -/
theorem fourierSubalgebra_closure_eq_top : (@fourierSubalgebra T).topologicalClosure = ⊤ :=
  ContinuousMap.subalgebra_isROrC_topologicalClosure_eq_top_of_separatesPoints fourierSubalgebra
    fourierSubalgebra_separatesPoints fourierSubalgebra_conj_invariant
#align fourier_subalgebra_closure_eq_top fourierSubalgebra_closure_eq_top
-/

#print span_fourier_closure_eq_top /-
/-- The linear span of the monomials `fourier n` is dense in `C(add_circle T, ℂ)`. -/
theorem span_fourier_closure_eq_top : (span ℂ (range <| @fourier T)).topologicalClosure = ⊤ :=
  by
  rw [← fourierSubalgebra_coe]
  exact congr_arg Subalgebra.toSubmodule fourierSubalgebra_closure_eq_top
#align span_fourier_closure_eq_top span_fourier_closure_eq_top
-/

#print fourierLp /-
/-- The family of monomials `fourier n`, parametrized by `n : ℤ` and considered as
elements of the `Lp` space of functions `add_circle T → ℂ`. -/
abbrev fourierLp (p : ℝ≥0∞) [Fact (1 ≤ p)] (n : ℤ) : Lp ℂ p (@haarAddCircle T hT) :=
  toLp p haarAddCircle ℂ (fourier n)
#align fourier_Lp fourierLp
-/

#print coeFn_fourierLp /-
theorem coeFn_fourierLp (p : ℝ≥0∞) [Fact (1 ≤ p)] (n : ℤ) :
    @fourierLp T hT p _ n =ᵐ[haarAddCircle] fourier n :=
  coeFn_toLp haarAddCircle (fourier n)
#align coe_fn_fourier_Lp coeFn_fourierLp
-/

#print span_fourierLp_closure_eq_top /-
/-- For each `1 ≤ p < ∞`, the linear span of the monomials `fourier n` is dense in
`Lp ℂ p haar_circle`. -/
theorem span_fourierLp_closure_eq_top {p : ℝ≥0∞} [Fact (1 ≤ p)] (hp : p ≠ ∞) :
    (span ℂ (range (@fourierLp T _ p _))).topologicalClosure = ⊤ :=
  by
  convert
    (ContinuousMap.toLp_denseRange ℂ (@haar_add_circle T hT) hp ℂ).topologicalClosure_map_submodule
      span_fourier_closure_eq_top
  rw [map_span, range_comp]
  simp only [ContinuousLinearMap.coe_coe]
#align span_fourier_Lp_closure_eq_top span_fourierLp_closure_eq_top
-/

#print orthonormal_fourier /-
/-- The monomials `fourier n` are an orthonormal set with respect to normalised Haar measure. -/
theorem orthonormal_fourier : Orthonormal ℂ (@fourierLp T _ 2 _) :=
  by
  rw [orthonormal_iff_ite]
  intro i j
  rw [continuous_map.inner_to_Lp (@haar_add_circle T hT) (fourier i) (fourier j)]
  simp_rw [← fourier_neg, ← fourier_add]
  split_ifs
  · simp_rw [h, neg_add_self]
    have : ⇑(@fourier T 0) = (fun x => 1 : AddCircle T → ℂ) := by ext1; exact fourier_zero
    rw [this, integral_const, measure_univ, ENNReal.one_toReal, Complex.real_smul,
      Complex.ofReal_one, mul_one]
  have hij : -i + j ≠ 0 := by
    rw [add_comm]
    exact sub_ne_zero.mpr (Ne.symm h)
  convert integral_eq_zero_of_add_right_eq_neg (fourier_add_half_inv_index hij hT.elim)
  exact MeasureTheory.IsAddLeftInvariant.isAddRightInvariant
#align orthonormal_fourier orthonormal_fourier
-/

end Monomials

section ScopeHT

-- everything from here on needs `0 < T`
variable [hT : Fact (0 < T)]

section fourierCoeff

variable {E : Type} [NormedAddCommGroup E] [NormedSpace ℂ E] [CompleteSpace E]

#print fourierCoeff /-
/-- The `n`-th Fourier coefficient of a function `add_circle T → E`, for `E` a complete normed
`ℂ`-vector space, defined as the integral over `add_circle T` of `fourier (-n) t • f t`. -/
def fourierCoeff (f : AddCircle T → E) (n : ℤ) : E :=
  ∫ t : AddCircle T, fourier (-n) t • f t ∂haarAddCircle
#align fourier_coeff fourierCoeff
-/

#print fourierCoeff_eq_intervalIntegral /-
/-- The Fourier coefficients of a function on `add_circle T` can be computed as an integral
over `[a, a + T]`, for any real `a`. -/
theorem fourierCoeff_eq_intervalIntegral (f : AddCircle T → E) (n : ℤ) (a : ℝ) :
    fourierCoeff f n = (1 / T) • ∫ x in a..a + T, @fourier T (-n) x • f x :=
  by
  have : ∀ x : ℝ, @fourier T (-n) x • f x = (fun z : AddCircle T => @fourier T (-n) z • f z) x := by
    intro x; rfl
  simp_rw [this]
  rw [fourierCoeff, AddCircle.intervalIntegral_preimage T a, volume_eq_smul_haar_add_circle,
    integral_smul_measure, ENNReal.toReal_ofReal hT.out.le, ← smul_assoc, smul_eq_mul,
    one_div_mul_cancel hT.out.ne', one_smul]
#align fourier_coeff_eq_interval_integral fourierCoeff_eq_intervalIntegral
-/

#print fourierCoeff.const_smul /-
theorem fourierCoeff.const_smul (f : AddCircle T → E) (c : ℂ) (n : ℤ) :
    fourierCoeff (c • f) n = c • fourierCoeff f n := by
  simp_rw [fourierCoeff, Pi.smul_apply, ← smul_assoc, smul_eq_mul, mul_comm, ← smul_eq_mul,
    smul_assoc, integral_smul]
#align fourier_coeff.const_smul fourierCoeff.const_smul
-/

#print fourierCoeff.const_mul /-
theorem fourierCoeff.const_mul (f : AddCircle T → ℂ) (c : ℂ) (n : ℤ) :
    fourierCoeff (fun x => c * f x) n = c * fourierCoeff f n :=
  fourierCoeff.const_smul f c n
#align fourier_coeff.const_mul fourierCoeff.const_mul
-/

#print fourierCoeffOn /-
/-- For a function on `ℝ`, the Fourier coefficients of `f` on `[a, b]` are defined as the
Fourier coefficients of the unique periodic function agreeing with `f` on `Ioc a b`. -/
def fourierCoeffOn {a b : ℝ} (hab : a < b) (f : ℝ → E) (n : ℤ) : E :=
  haveI := Fact.mk (by linarith : 0 < b - a)
  fourierCoeff (AddCircle.liftIoc (b - a) a f) n
#align fourier_coeff_on fourierCoeffOn
-/

#print fourierCoeffOn_eq_integral /-
theorem fourierCoeffOn_eq_integral {a b : ℝ} (f : ℝ → E) (n : ℤ) (hab : a < b) :
    fourierCoeffOn hab f n =
      (1 / (b - a)) • ∫ x in a..b, fourier (-n) (x : AddCircle (b - a)) • f x :=
  by
  rw [fourierCoeffOn, fourierCoeff_eq_intervalIntegral _ _ a]
  congr 1
  rw [add_sub, add_sub_cancel']
  simp_rw [intervalIntegral.integral_of_le hab.le]
  refine' set_integral_congr measurableSet_Ioc fun x hx => _
  dsimp only
  rwa [lift_Ioc_coe_apply]
  rwa [add_sub, add_sub_cancel']
#align fourier_coeff_on_eq_integral fourierCoeffOn_eq_integral
-/

#print fourierCoeffOn.const_smul /-
theorem fourierCoeffOn.const_smul {a b : ℝ} (f : ℝ → E) (c : ℂ) (n : ℤ) (hab : a < b) :
    fourierCoeffOn hab (c • f) n = c • fourierCoeffOn hab f n := by apply fourierCoeff.const_smul
#align fourier_coeff_on.const_smul fourierCoeffOn.const_smul
-/

#print fourierCoeffOn.const_mul /-
theorem fourierCoeffOn.const_mul {a b : ℝ} (f : ℝ → ℂ) (c : ℂ) (n : ℤ) (hab : a < b) :
    fourierCoeffOn hab (fun x => c * f x) n = c * fourierCoeffOn hab f n :=
  fourierCoeffOn.const_smul _ _ _ _
#align fourier_coeff_on.const_mul fourierCoeffOn.const_mul
-/

#print fourierCoeff_liftIoc_eq /-
theorem fourierCoeff_liftIoc_eq {a : ℝ} (f : ℝ → ℂ) (n : ℤ) :
    fourierCoeff (AddCircle.liftIoc T a f) n = fourierCoeffOn (lt_add_of_pos_right a hT.out) f n :=
  by
  rw [fourierCoeffOn_eq_integral, fourierCoeff_eq_intervalIntegral, add_sub_cancel' a T]
  congr 1
  refine' intervalIntegral.integral_congr_ae (ae_of_all _ fun x hx => _)
  rw [lift_Ioc_coe_apply]
  rwa [uIoc_of_le (lt_add_of_pos_right a hT.out).le] at hx 
#align fourier_coeff_lift_Ioc_eq fourierCoeff_liftIoc_eq
-/

#print fourierCoeff_liftIco_eq /-
theorem fourierCoeff_liftIco_eq {a : ℝ} (f : ℝ → ℂ) (n : ℤ) :
    fourierCoeff (AddCircle.liftIco T a f) n = fourierCoeffOn (lt_add_of_pos_right a hT.out) f n :=
  by
  rw [fourierCoeffOn_eq_integral, fourierCoeff_eq_intervalIntegral _ _ a, add_sub_cancel' a T]
  congr 1
  simp_rw [intervalIntegral.integral_of_le (lt_add_of_pos_right a hT.out).le,
    integral_Ioc_eq_integral_Ioo]
  refine' set_integral_congr measurableSet_Ioo fun x hx => _
  dsimp only
  rw [lift_Ico_coe_apply (Ioo_subset_Ico_self hx)]
#align fourier_coeff_lift_Ico_eq fourierCoeff_liftIco_eq
-/

end fourierCoeff

section FourierL2

#print fourierBasis /-
/-- We define `fourier_basis` to be a `ℤ`-indexed Hilbert basis for `Lp ℂ 2 haar_add_circle`,
which by definition is an isometric isomorphism from `Lp ℂ 2 haar_add_circle` to `ℓ²(ℤ, ℂ)`. -/
def fourierBasis : HilbertBasis ℤ ℂ (Lp ℂ 2 <| @haarAddCircle T hT) :=
  HilbertBasis.mk orthonormal_fourier (span_fourierLp_closure_eq_top (by norm_num)).ge
#align fourier_basis fourierBasis
-/

#print coe_fourierBasis /-
/-- The elements of the Hilbert basis `fourier_basis` are the functions `fourier_Lp 2`, i.e. the
monomials `fourier n` on the circle considered as elements of `L²`. -/
@[simp]
theorem coe_fourierBasis : ⇑(@fourierBasis _ hT) = fourierLp 2 :=
  HilbertBasis.coe_mk _ _
#align coe_fourier_basis coe_fourierBasis
-/

#print fourierBasis_repr /-
/-- Under the isometric isomorphism `fourier_basis` from `Lp ℂ 2 haar_circle` to `ℓ²(ℤ, ℂ)`, the
`i`-th coefficient is `fourier_coeff f i`, i.e., the integral over `add_circle T` of
`λ t, fourier (-i) t * f t` with respect to the Haar measure of total mass 1. -/
theorem fourierBasis_repr (f : Lp ℂ 2 <| @haarAddCircle T hT) (i : ℤ) :
    fourierBasis.repr f i = fourierCoeff f i :=
  by
  trans ∫ t : AddCircle T, conj ((@fourierLp T hT 2 _ i : AddCircle T → ℂ) t) * f t ∂haar_add_circle
  · simp [fourier_basis.repr_apply_apply f i, MeasureTheory.L2.inner_def]
  · apply integral_congr_ae
    filter_upwards [coeFn_fourierLp 2 i] with _ ht
    rw [ht, ← fourier_neg, smul_eq_mul]
#align fourier_basis_repr fourierBasis_repr
-/

#print hasSum_fourier_series_L2 /-
/-- The Fourier series of an `L2` function `f` sums to `f`, in the `L²` space of `add_circle T`. -/
theorem hasSum_fourier_series_L2 (f : Lp ℂ 2 <| @haarAddCircle T hT) :
    HasSum (fun i => fourierCoeff f i • fourierLp 2 i) f := by simp_rw [← fourierBasis_repr];
  simpa using HilbertBasis.hasSum_repr fourierBasis f
#align has_sum_fourier_series_L2 hasSum_fourier_series_L2
-/

#print tsum_sq_fourierCoeff /-
/-- **Parseval's identity**: for an `L²` function `f` on `add_circle T`, the sum of the squared
norms of the Fourier coefficients equals the `L²` norm of `f`. -/
theorem tsum_sq_fourierCoeff (f : Lp ℂ 2 <| @haarAddCircle T hT) :
    ∑' i : ℤ, ‖fourierCoeff f i‖ ^ 2 = ∫ t : AddCircle T, ‖f t‖ ^ 2 ∂haarAddCircle :=
  by
  simp_rw [← fourierBasis_repr]
  have H₁ : ‖fourier_basis.repr f‖ ^ 2 = ∑' i, ‖fourier_basis.repr f i‖ ^ 2 :=
    by
    exact_mod_cast lp.norm_rpow_eq_tsum _ (fourier_basis.repr f)
    norm_num
  have H₂ : ‖fourier_basis.repr f‖ ^ 2 = ‖f‖ ^ 2 := by simp
  have H₃ := congr_arg IsROrC.re (@L2.inner_def (AddCircle T) ℂ ℂ _ _ _ _ _ f f)
  rw [← integral_re] at H₃ 
  · simp only [← norm_sq_eq_inner] at H₃ 
    rw [← H₁, H₂, H₃]
  · exact L2.integrable_inner f f
#align tsum_sq_fourier_coeff tsum_sq_fourierCoeff
-/

end FourierL2

section Convergence

variable (f : C(AddCircle T, ℂ))

#print fourierCoeff_toLp /-
theorem fourierCoeff_toLp (n : ℤ) : fourierCoeff (toLp 2 haarAddCircle ℂ f) n = fourierCoeff f n :=
  integral_congr_ae
    (Filter.EventuallyEq.mul (Filter.eventually_of_forall (by tauto))
      (ContinuousMap.coeFn_toAEEqFun haarAddCircle f))
#align fourier_coeff_to_Lp fourierCoeff_toLp
-/

variable {f}

#print hasSum_fourier_series_of_summable /-
/-- If the sequence of Fourier coefficients of `f` is summable, then the Fourier series converges
uniformly to `f`. -/
theorem hasSum_fourier_series_of_summable (h : Summable (fourierCoeff f)) :
    HasSum (fun i => fourierCoeff f i • fourier i) f :=
  by
  have sum_L2 := hasSum_fourier_series_L2 (to_Lp 2 haar_add_circle ℂ f)
  simp_rw [fourierCoeff_toLp] at sum_L2 
  refine' ContinuousMap.hasSum_of_hasSum_Lp (summable_of_summable_norm _) sum_L2
  simp_rw [norm_smul, fourier_norm, mul_one, summable_norm_iff]
  exact h
#align has_sum_fourier_series_of_summable hasSum_fourier_series_of_summable
-/

#print has_pointwise_sum_fourier_series_of_summable /-
/-- If the sequence of Fourier coefficients of `f` is summable, then the Fourier series of `f`
converges everywhere pointwise to `f`. -/
theorem has_pointwise_sum_fourier_series_of_summable (h : Summable (fourierCoeff f))
    (x : AddCircle T) : HasSum (fun i => fourierCoeff f i • fourier i x) (f x) :=
  (ContinuousMap.evalClm ℂ x).HasSum (hasSum_fourier_series_of_summable h)
#align has_pointwise_sum_fourier_series_of_summable has_pointwise_sum_fourier_series_of_summable
-/

end Convergence

end ScopeHT

section deriv

open Complex intervalIntegral

open scoped Interval

variable (T)

#print hasDerivAt_fourier /-
theorem hasDerivAt_fourier (n : ℤ) (x : ℝ) :
    HasDerivAt (fun y : ℝ => fourier n (y : AddCircle T))
      (2 * π * I * n / T * fourier n (x : AddCircle T)) x :=
  by
  simp_rw [fourier_coe_apply]
  refine' (_ : HasDerivAt (fun y => exp (2 * π * I * n * y / T)) _ _).comp_ofReal
  rw [(fun α β => by ring : ∀ α β : ℂ, α * exp β = exp β * α)]
  refine' (hasDerivAt_exp _).comp x _
  convert hasDerivAt_mul_const (2 * ↑π * I * ↑n / T)
  ext1 y; ring
#align has_deriv_at_fourier hasDerivAt_fourier
-/

#print hasDerivAt_fourier_neg /-
theorem hasDerivAt_fourier_neg (n : ℤ) (x : ℝ) :
    HasDerivAt (fun y : ℝ => fourier (-n) (y : AddCircle T))
      (-2 * π * I * n / T * fourier (-n) (x : AddCircle T)) x :=
  by simpa using hasDerivAt_fourier T (-n) x
#align has_deriv_at_fourier_neg hasDerivAt_fourier_neg
-/

variable {T}

#print has_antideriv_at_fourier_neg /-
theorem has_antideriv_at_fourier_neg (hT : Fact (0 < T)) {n : ℤ} (hn : n ≠ 0) (x : ℝ) :
    HasDerivAt (fun y : ℝ => (T : ℂ) / (-2 * π * I * n) * fourier (-n) (y : AddCircle T))
      (fourier (-n) (x : AddCircle T)) x :=
  by
  convert (hasDerivAt_fourier_neg T n x).div_const (-2 * π * I * n / T) using 1
  · ext1 y; rw [div_div_eq_mul_div]; ring
  · rw [mul_div_cancel_left]
    simp only [Ne.def, div_eq_zero_iff, neg_eq_zero, mul_eq_zero, bit0_eq_zero, one_ne_zero,
      of_real_eq_zero, false_or_iff, Int.cast_eq_zero, not_or]
    exact ⟨⟨⟨Real.pi_ne_zero, I_ne_zero⟩, hn⟩, hT.out.ne'⟩
#align has_antideriv_at_fourier_neg has_antideriv_at_fourier_neg
-/

#print fourierCoeffOn_of_hasDerivAt /-
/-- Express Fourier coefficients of `f` on an interval in terms of those of its derivative. -/
theorem fourierCoeffOn_of_hasDerivAt {a b : ℝ} (hab : a < b) {f f' : ℝ → ℂ} {n : ℤ} (hn : n ≠ 0)
    (hf : ∀ x, x ∈ [a, b] → HasDerivAt f (f' x) x) (hf' : IntervalIntegrable f' volume a b) :
    fourierCoeffOn hab f n =
      1 / (-2 * π * I * n) *
        (fourier (-n) (a : AddCircle (b - a)) * (f b - f a) - (b - a) * fourierCoeffOn hab f' n) :=
  by
  rw [← of_real_sub]
  have hT : Fact (0 < b - a) := ⟨by linarith⟩
  simp_rw [fourierCoeffOn_eq_integral, smul_eq_mul, real_smul, of_real_div, of_real_one]
  conv => pattern (occs := 1 2 3) fourier _ _ * _ <;> (rw [mul_comm])
  rw [integral_mul_deriv_eq_deriv_mul hf (fun x hx => has_antideriv_at_fourier_neg hT hn x) hf'
      (((map_continuous (fourier (-n))).comp (AddCircle.continuous_mk' _)).IntervalIntegrable _ _)]
  dsimp only
  have : ∀ u v w : ℂ, u * ((b - a : ℝ) / v * w) = (b - a : ℝ) / v * (u * w) := by intros; ring
  conv in intervalIntegral _ _ _ _ =>
    congr
    ext
    rw [this]
  rw [(by ring : ((b - a : ℝ) : ℂ) / (-2 * π * I * n) = ((b - a : ℝ) : ℂ) * (1 / (-2 * π * I * n)))]
  have s2 : (b : AddCircle (b - a)) = (a : AddCircle (b - a)) := by
    simpa using coe_add_period (b - a) a
  rw [s2, integral_const_mul, ← sub_mul, mul_sub, mul_sub]
  congr 1
  · conv_lhs => rw [mul_comm, mul_div, mul_one]
    rw [div_eq_iff (of_real_ne_zero.mpr hT.out.ne')]
    ring
  · ring
#align fourier_coeff_on_of_has_deriv_at fourierCoeffOn_of_hasDerivAt
-/

end deriv

