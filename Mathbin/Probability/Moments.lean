/-
Copyright (c) 2022 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne

! This file was ported from Lean 3 source module probability.moments
! leanprover-community/mathlib commit 1b089e3bdc3ce6b39cd472543474a0a137128c6c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.Variance

/-!
# Moments and moment generating function

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `probability_theory.moment X p μ`: `p`th moment of a real random variable `X` with respect to
  measure `μ`, `μ[X^p]`
* `probability_theory.central_moment X p μ`:`p`th central moment of `X` with respect to measure `μ`,
  `μ[(X - μ[X])^p]`
* `probability_theory.mgf X μ t`: moment generating function of `X` with respect to measure `μ`,
  `μ[exp(t*X)]`
* `probability_theory.cgf X μ t`: cumulant generating function, logarithm of the moment generating
  function

## Main results

* `probability_theory.indep_fun.mgf_add`: if two real random variables `X` and `Y` are independent
  and their mgf are defined at `t`, then `mgf (X + Y) μ t = mgf X μ t * mgf Y μ t`
* `probability_theory.indep_fun.cgf_add`: if two real random variables `X` and `Y` are independent
  and their mgf are defined at `t`, then `cgf (X + Y) μ t = cgf X μ t + cgf Y μ t`
* `probability_theory.measure_ge_le_exp_cgf` and `probability_theory.measure_le_le_exp_cgf`:
  Chernoff bound on the upper (resp. lower) tail of a random variable. For `t` nonnegative such that
  the cgf exists, `ℙ(ε ≤ X) ≤ exp(- t*ε + cgf X ℙ t)`. See also
  `probability_theory.measure_ge_le_exp_mul_mgf` and
  `probability_theory.measure_le_le_exp_mul_mgf` for versions of these results using `mgf` instead
  of `cgf`.

-/


open MeasureTheory Filter Finset Real

noncomputable section

open scoped BigOperators MeasureTheory ProbabilityTheory ENNReal NNReal

namespace ProbabilityTheory

variable {Ω ι : Type _} {m : MeasurableSpace Ω} {X : Ω → ℝ} {p : ℕ} {μ : Measure Ω}

#print ProbabilityTheory.moment /-
/-- Moment of a real random variable, `μ[X ^ p]`. -/
def moment (X : Ω → ℝ) (p : ℕ) (μ : Measure Ω) : ℝ :=
  μ[X ^ p]
#align probability_theory.moment ProbabilityTheory.moment
-/

#print ProbabilityTheory.centralMoment /-
/-- Central moment of a real random variable, `μ[(X - μ[X]) ^ p]`. -/
def centralMoment (X : Ω → ℝ) (p : ℕ) (μ : Measure Ω) : ℝ :=
  μ[(X - fun x => μ[X]) ^ p]
#align probability_theory.central_moment ProbabilityTheory.centralMoment
-/

#print ProbabilityTheory.moment_zero /-
@[simp]
theorem moment_zero (hp : p ≠ 0) : moment 0 p μ = 0 := by
  simp only [moment, hp, zero_pow', Ne.def, not_false_iff, Pi.zero_apply, integral_const,
    Algebra.id.smul_eq_mul, MulZeroClass.mul_zero]
#align probability_theory.moment_zero ProbabilityTheory.moment_zero
-/

#print ProbabilityTheory.centralMoment_zero /-
@[simp]
theorem centralMoment_zero (hp : p ≠ 0) : centralMoment 0 p μ = 0 := by
  simp only [central_moment, hp, Pi.zero_apply, integral_const, Algebra.id.smul_eq_mul,
    MulZeroClass.mul_zero, zero_sub, Pi.pow_apply, Pi.neg_apply, neg_zero, zero_pow', Ne.def,
    not_false_iff]
#align probability_theory.central_moment_zero ProbabilityTheory.centralMoment_zero
-/

#print ProbabilityTheory.centralMoment_one' /-
theorem centralMoment_one' [IsFiniteMeasure μ] (h_int : Integrable X μ) :
    centralMoment X 1 μ = (1 - (μ Set.univ).toReal) * μ[X] :=
  by
  simp only [central_moment, Pi.sub_apply, pow_one]
  rw [integral_sub h_int (integrable_const _)]
  simp only [sub_mul, integral_const, Algebra.id.smul_eq_mul, one_mul]
#align probability_theory.central_moment_one' ProbabilityTheory.centralMoment_one'
-/

#print ProbabilityTheory.centralMoment_one /-
@[simp]
theorem centralMoment_one [IsProbabilityMeasure μ] : centralMoment X 1 μ = 0 :=
  by
  by_cases h_int : integrable X μ
  · rw [central_moment_one' h_int]
    simp only [measure_univ, ENNReal.one_toReal, sub_self, MulZeroClass.zero_mul]
  · simp only [central_moment, Pi.sub_apply, pow_one]
    have : ¬integrable (fun x => X x - integral μ X) μ :=
      by
      refine' fun h_sub => h_int _
      have h_add : X = (fun x => X x - integral μ X) + fun x => integral μ X := by ext1 x; simp
      rw [h_add]
      exact h_sub.add (integrable_const _)
    rw [integral_undef this]
#align probability_theory.central_moment_one ProbabilityTheory.centralMoment_one
-/

#print ProbabilityTheory.centralMoment_two_eq_variance /-
theorem centralMoment_two_eq_variance [IsFiniteMeasure μ] (hX : Memℒp X 2 μ) :
    centralMoment X 2 μ = variance X μ := by rw [hX.variance_eq]; rfl
#align probability_theory.central_moment_two_eq_variance ProbabilityTheory.centralMoment_two_eq_variance
-/

section MomentGeneratingFunction

variable {t : ℝ}

#print ProbabilityTheory.mgf /-
/-- Moment generating function of a real random variable `X`: `λ t, μ[exp(t*X)]`. -/
def mgf (X : Ω → ℝ) (μ : Measure Ω) (t : ℝ) : ℝ :=
  μ[fun ω => exp (t * X ω)]
#align probability_theory.mgf ProbabilityTheory.mgf
-/

#print ProbabilityTheory.cgf /-
/-- Cumulant generating function of a real random variable `X`: `λ t, log μ[exp(t*X)]`. -/
def cgf (X : Ω → ℝ) (μ : Measure Ω) (t : ℝ) : ℝ :=
  log (mgf X μ t)
#align probability_theory.cgf ProbabilityTheory.cgf
-/

#print ProbabilityTheory.mgf_zero_fun /-
@[simp]
theorem mgf_zero_fun : mgf 0 μ t = (μ Set.univ).toReal := by
  simp only [mgf, Pi.zero_apply, MulZeroClass.mul_zero, exp_zero, integral_const,
    Algebra.id.smul_eq_mul, mul_one]
#align probability_theory.mgf_zero_fun ProbabilityTheory.mgf_zero_fun
-/

#print ProbabilityTheory.cgf_zero_fun /-
@[simp]
theorem cgf_zero_fun : cgf 0 μ t = log (μ Set.univ).toReal := by simp only [cgf, mgf_zero_fun]
#align probability_theory.cgf_zero_fun ProbabilityTheory.cgf_zero_fun
-/

#print ProbabilityTheory.mgf_zero_measure /-
@[simp]
theorem mgf_zero_measure : mgf X (0 : Measure Ω) t = 0 := by simp only [mgf, integral_zero_measure]
#align probability_theory.mgf_zero_measure ProbabilityTheory.mgf_zero_measure
-/

#print ProbabilityTheory.cgf_zero_measure /-
@[simp]
theorem cgf_zero_measure : cgf X (0 : Measure Ω) t = 0 := by
  simp only [cgf, log_zero, mgf_zero_measure]
#align probability_theory.cgf_zero_measure ProbabilityTheory.cgf_zero_measure
-/

#print ProbabilityTheory.mgf_const' /-
@[simp]
theorem mgf_const' (c : ℝ) : mgf (fun _ => c) μ t = (μ Set.univ).toReal * exp (t * c) := by
  simp only [mgf, integral_const, Algebra.id.smul_eq_mul]
#align probability_theory.mgf_const' ProbabilityTheory.mgf_const'
-/

#print ProbabilityTheory.mgf_const /-
@[simp]
theorem mgf_const (c : ℝ) [IsProbabilityMeasure μ] : mgf (fun _ => c) μ t = exp (t * c) := by
  simp only [mgf_const', measure_univ, ENNReal.one_toReal, one_mul]
#align probability_theory.mgf_const ProbabilityTheory.mgf_const
-/

#print ProbabilityTheory.cgf_const' /-
@[simp]
theorem cgf_const' [IsFiniteMeasure μ] (hμ : μ ≠ 0) (c : ℝ) :
    cgf (fun _ => c) μ t = log (μ Set.univ).toReal + t * c :=
  by
  simp only [cgf, mgf_const']
  rw [log_mul _ (exp_pos _).ne']
  · rw [log_exp _]
  · rw [Ne.def, ENNReal.toReal_eq_zero_iff, measure.measure_univ_eq_zero]
    simp only [hμ, measure_ne_top μ Set.univ, or_self_iff, not_false_iff]
#align probability_theory.cgf_const' ProbabilityTheory.cgf_const'
-/

#print ProbabilityTheory.cgf_const /-
@[simp]
theorem cgf_const [IsProbabilityMeasure μ] (c : ℝ) : cgf (fun _ => c) μ t = t * c := by
  simp only [cgf, mgf_const, log_exp]
#align probability_theory.cgf_const ProbabilityTheory.cgf_const
-/

#print ProbabilityTheory.mgf_zero' /-
@[simp]
theorem mgf_zero' : mgf X μ 0 = (μ Set.univ).toReal := by
  simp only [mgf, MulZeroClass.zero_mul, exp_zero, integral_const, Algebra.id.smul_eq_mul, mul_one]
#align probability_theory.mgf_zero' ProbabilityTheory.mgf_zero'
-/

#print ProbabilityTheory.mgf_zero /-
@[simp]
theorem mgf_zero [IsProbabilityMeasure μ] : mgf X μ 0 = 1 := by
  simp only [mgf_zero', measure_univ, ENNReal.one_toReal]
#align probability_theory.mgf_zero ProbabilityTheory.mgf_zero
-/

#print ProbabilityTheory.cgf_zero' /-
@[simp]
theorem cgf_zero' : cgf X μ 0 = log (μ Set.univ).toReal := by simp only [cgf, mgf_zero']
#align probability_theory.cgf_zero' ProbabilityTheory.cgf_zero'
-/

#print ProbabilityTheory.cgf_zero /-
@[simp]
theorem cgf_zero [IsProbabilityMeasure μ] : cgf X μ 0 = 0 := by
  simp only [cgf_zero', measure_univ, ENNReal.one_toReal, log_one]
#align probability_theory.cgf_zero ProbabilityTheory.cgf_zero
-/

#print ProbabilityTheory.mgf_undef /-
theorem mgf_undef (hX : ¬Integrable (fun ω => exp (t * X ω)) μ) : mgf X μ t = 0 := by
  simp only [mgf, integral_undef hX]
#align probability_theory.mgf_undef ProbabilityTheory.mgf_undef
-/

#print ProbabilityTheory.cgf_undef /-
theorem cgf_undef (hX : ¬Integrable (fun ω => exp (t * X ω)) μ) : cgf X μ t = 0 := by
  simp only [cgf, mgf_undef hX, log_zero]
#align probability_theory.cgf_undef ProbabilityTheory.cgf_undef
-/

#print ProbabilityTheory.mgf_nonneg /-
theorem mgf_nonneg : 0 ≤ mgf X μ t :=
  by
  refine' integral_nonneg _
  intro ω
  simp only [Pi.zero_apply]
  exact (exp_pos _).le
#align probability_theory.mgf_nonneg ProbabilityTheory.mgf_nonneg
-/

#print ProbabilityTheory.mgf_pos' /-
theorem mgf_pos' (hμ : μ ≠ 0) (h_int_X : Integrable (fun ω => exp (t * X ω)) μ) : 0 < mgf X μ t :=
  by
  simp_rw [mgf]
  have : ∫ x : Ω, exp (t * X x) ∂μ = ∫ x : Ω in Set.univ, exp (t * X x) ∂μ := by
    simp only [measure.restrict_univ]
  rw [this, set_integral_pos_iff_support_of_nonneg_ae _ _]
  · have h_eq_univ : (Function.support fun x : Ω => exp (t * X x)) = Set.univ :=
      by
      ext1 x
      simp only [Function.mem_support, Set.mem_univ, iff_true_iff]
      exact (exp_pos _).ne'
    rw [h_eq_univ, Set.inter_univ _]
    refine' Ne.bot_lt _
    simp only [hμ, ENNReal.bot_eq_zero, Ne.def, measure.measure_univ_eq_zero, not_false_iff]
  · refine' eventually_of_forall fun x => _
    rw [Pi.zero_apply]
    exact (exp_pos _).le
  · rwa [integrable_on_univ]
#align probability_theory.mgf_pos' ProbabilityTheory.mgf_pos'
-/

#print ProbabilityTheory.mgf_pos /-
theorem mgf_pos [IsProbabilityMeasure μ] (h_int_X : Integrable (fun ω => exp (t * X ω)) μ) :
    0 < mgf X μ t :=
  mgf_pos' (IsProbabilityMeasure.ne_zero μ) h_int_X
#align probability_theory.mgf_pos ProbabilityTheory.mgf_pos
-/

#print ProbabilityTheory.mgf_neg /-
theorem mgf_neg : mgf (-X) μ t = mgf X μ (-t) := by simp_rw [mgf, Pi.neg_apply, mul_neg, neg_mul]
#align probability_theory.mgf_neg ProbabilityTheory.mgf_neg
-/

#print ProbabilityTheory.cgf_neg /-
theorem cgf_neg : cgf (-X) μ t = cgf X μ (-t) := by simp_rw [cgf, mgf_neg]
#align probability_theory.cgf_neg ProbabilityTheory.cgf_neg
-/

#print ProbabilityTheory.IndepFun.exp_mul /-
/-- This is a trivial application of `indep_fun.comp` but it will come up frequently. -/
theorem IndepFun.exp_mul {X Y : Ω → ℝ} (h_indep : IndepFun X Y μ) (s t : ℝ) :
    IndepFun (fun ω => exp (s * X ω)) (fun ω => exp (t * Y ω)) μ :=
  by
  have h_meas : ∀ t, Measurable fun x => exp (t * x) := fun t => (measurable_id'.const_mul t).exp
  change indep_fun ((fun x => exp (s * x)) ∘ X) ((fun x => exp (t * x)) ∘ Y) μ
  exact indep_fun.comp h_indep (h_meas s) (h_meas t)
#align probability_theory.indep_fun.exp_mul ProbabilityTheory.IndepFun.exp_mul
-/

#print ProbabilityTheory.IndepFun.mgf_add /-
theorem IndepFun.mgf_add {X Y : Ω → ℝ} (h_indep : IndepFun X Y μ)
    (hX : AEStronglyMeasurable (fun ω => exp (t * X ω)) μ)
    (hY : AEStronglyMeasurable (fun ω => exp (t * Y ω)) μ) :
    mgf (X + Y) μ t = mgf X μ t * mgf Y μ t :=
  by
  simp_rw [mgf, Pi.add_apply, mul_add, exp_add]
  exact (h_indep.exp_mul t t).integral_mul hX hY
#align probability_theory.indep_fun.mgf_add ProbabilityTheory.IndepFun.mgf_add
-/

#print ProbabilityTheory.IndepFun.mgf_add' /-
theorem IndepFun.mgf_add' {X Y : Ω → ℝ} (h_indep : IndepFun X Y μ) (hX : AEStronglyMeasurable X μ)
    (hY : AEStronglyMeasurable Y μ) : mgf (X + Y) μ t = mgf X μ t * mgf Y μ t :=
  by
  have A : Continuous fun x : ℝ => exp (t * x) := by continuity
  have h'X : ae_strongly_measurable (fun ω => exp (t * X ω)) μ :=
    A.ae_strongly_measurable.comp_ae_measurable hX.ae_measurable
  have h'Y : ae_strongly_measurable (fun ω => exp (t * Y ω)) μ :=
    A.ae_strongly_measurable.comp_ae_measurable hY.ae_measurable
  exact h_indep.mgf_add h'X h'Y
#align probability_theory.indep_fun.mgf_add' ProbabilityTheory.IndepFun.mgf_add'
-/

#print ProbabilityTheory.IndepFun.cgf_add /-
theorem IndepFun.cgf_add {X Y : Ω → ℝ} (h_indep : IndepFun X Y μ)
    (h_int_X : Integrable (fun ω => exp (t * X ω)) μ)
    (h_int_Y : Integrable (fun ω => exp (t * Y ω)) μ) : cgf (X + Y) μ t = cgf X μ t + cgf Y μ t :=
  by
  by_cases hμ : μ = 0
  · simp [hμ]
  simp only [cgf, h_indep.mgf_add h_int_X.ae_strongly_measurable h_int_Y.ae_strongly_measurable]
  exact log_mul (mgf_pos' hμ h_int_X).ne' (mgf_pos' hμ h_int_Y).ne'
#align probability_theory.indep_fun.cgf_add ProbabilityTheory.IndepFun.cgf_add
-/

#print ProbabilityTheory.aestronglyMeasurable_exp_mul_add /-
theorem aestronglyMeasurable_exp_mul_add {X Y : Ω → ℝ}
    (h_int_X : AEStronglyMeasurable (fun ω => exp (t * X ω)) μ)
    (h_int_Y : AEStronglyMeasurable (fun ω => exp (t * Y ω)) μ) :
    AEStronglyMeasurable (fun ω => exp (t * (X + Y) ω)) μ :=
  by
  simp_rw [Pi.add_apply, mul_add, exp_add]
  exact ae_strongly_measurable.mul h_int_X h_int_Y
#align probability_theory.ae_strongly_measurable_exp_mul_add ProbabilityTheory.aestronglyMeasurable_exp_mul_add
-/

#print ProbabilityTheory.aestronglyMeasurable_exp_mul_sum /-
theorem aestronglyMeasurable_exp_mul_sum {X : ι → Ω → ℝ} {s : Finset ι}
    (h_int : ∀ i ∈ s, AEStronglyMeasurable (fun ω => exp (t * X i ω)) μ) :
    AEStronglyMeasurable (fun ω => exp (t * (∑ i in s, X i) ω)) μ := by
  classical
  induction' s using Finset.induction_on with i s hi_notin_s h_rec h_int
  · simp only [Pi.zero_apply, sum_apply, sum_empty, MulZeroClass.mul_zero, exp_zero]
    exact ae_strongly_measurable_const
  · have : ∀ i : ι, i ∈ s → ae_strongly_measurable (fun ω : Ω => exp (t * X i ω)) μ := fun i hi =>
      h_int i (mem_insert_of_mem hi)
    specialize h_rec this
    rw [sum_insert hi_notin_s]
    apply ae_strongly_measurable_exp_mul_add (h_int i (mem_insert_self _ _)) h_rec
#align probability_theory.ae_strongly_measurable_exp_mul_sum ProbabilityTheory.aestronglyMeasurable_exp_mul_sum
-/

#print ProbabilityTheory.IndepFun.integrable_exp_mul_add /-
theorem IndepFun.integrable_exp_mul_add {X Y : Ω → ℝ} (h_indep : IndepFun X Y μ)
    (h_int_X : Integrable (fun ω => exp (t * X ω)) μ)
    (h_int_Y : Integrable (fun ω => exp (t * Y ω)) μ) :
    Integrable (fun ω => exp (t * (X + Y) ω)) μ :=
  by
  simp_rw [Pi.add_apply, mul_add, exp_add]
  exact (h_indep.exp_mul t t).integrable_mul h_int_X h_int_Y
#align probability_theory.indep_fun.integrable_exp_mul_add ProbabilityTheory.IndepFun.integrable_exp_mul_add
-/

#print ProbabilityTheory.iIndepFun.integrable_exp_mul_sum /-
theorem iIndepFun.integrable_exp_mul_sum [IsProbabilityMeasure μ] {X : ι → Ω → ℝ}
    (h_indep : iIndepFun (fun i => inferInstance) X μ) (h_meas : ∀ i, Measurable (X i))
    {s : Finset ι} (h_int : ∀ i ∈ s, Integrable (fun ω => exp (t * X i ω)) μ) :
    Integrable (fun ω => exp (t * (∑ i in s, X i) ω)) μ := by
  classical
  induction' s using Finset.induction_on with i s hi_notin_s h_rec h_int
  · simp only [Pi.zero_apply, sum_apply, sum_empty, MulZeroClass.mul_zero, exp_zero]
    exact integrable_const _
  · have : ∀ i : ι, i ∈ s → integrable (fun ω : Ω => exp (t * X i ω)) μ := fun i hi =>
      h_int i (mem_insert_of_mem hi)
    specialize h_rec this
    rw [sum_insert hi_notin_s]
    refine' indep_fun.integrable_exp_mul_add _ (h_int i (mem_insert_self _ _)) h_rec
    exact (h_indep.indep_fun_finset_sum_of_not_mem h_meas hi_notin_s).symm
#align probability_theory.Indep_fun.integrable_exp_mul_sum ProbabilityTheory.iIndepFun.integrable_exp_mul_sum
-/

#print ProbabilityTheory.iIndepFun.mgf_sum /-
theorem iIndepFun.mgf_sum [IsProbabilityMeasure μ] {X : ι → Ω → ℝ}
    (h_indep : iIndepFun (fun i => inferInstance) X μ) (h_meas : ∀ i, Measurable (X i))
    (s : Finset ι) : mgf (∑ i in s, X i) μ t = ∏ i in s, mgf (X i) μ t := by
  classical
  induction' s using Finset.induction_on with i s hi_notin_s h_rec h_int
  · simp only [sum_empty, mgf_zero_fun, measure_univ, ENNReal.one_toReal, prod_empty]
  · have h_int' : ∀ i : ι, ae_strongly_measurable (fun ω : Ω => exp (t * X i ω)) μ := fun i =>
      ((h_meas i).const_mul t).exp.AEStronglyMeasurable
    rw [sum_insert hi_notin_s,
      indep_fun.mgf_add (h_indep.indep_fun_finset_sum_of_not_mem h_meas hi_notin_s).symm (h_int' i)
        (ae_strongly_measurable_exp_mul_sum fun i hi => h_int' i),
      h_rec, prod_insert hi_notin_s]
#align probability_theory.Indep_fun.mgf_sum ProbabilityTheory.iIndepFun.mgf_sum
-/

#print ProbabilityTheory.iIndepFun.cgf_sum /-
theorem iIndepFun.cgf_sum [IsProbabilityMeasure μ] {X : ι → Ω → ℝ}
    (h_indep : iIndepFun (fun i => inferInstance) X μ) (h_meas : ∀ i, Measurable (X i))
    {s : Finset ι} (h_int : ∀ i ∈ s, Integrable (fun ω => exp (t * X i ω)) μ) :
    cgf (∑ i in s, X i) μ t = ∑ i in s, cgf (X i) μ t :=
  by
  simp_rw [cgf]
  rw [← log_prod _ _ fun j hj => _]
  · rw [h_indep.mgf_sum h_meas]
  · exact (mgf_pos (h_int j hj)).ne'
#align probability_theory.Indep_fun.cgf_sum ProbabilityTheory.iIndepFun.cgf_sum
-/

#print ProbabilityTheory.measure_ge_le_exp_mul_mgf /-
/-- **Chernoff bound** on the upper tail of a real random variable. -/
theorem measure_ge_le_exp_mul_mgf [IsFiniteMeasure μ] (ε : ℝ) (ht : 0 ≤ t)
    (h_int : Integrable (fun ω => exp (t * X ω)) μ) :
    (μ {ω | ε ≤ X ω}).toReal ≤ exp (-t * ε) * mgf X μ t :=
  by
  cases' ht.eq_or_lt with ht_zero_eq ht_pos
  · rw [ht_zero_eq.symm]
    simp only [neg_zero, MulZeroClass.zero_mul, exp_zero, mgf_zero', one_mul]
    rw [ENNReal.toReal_le_toReal (measure_ne_top μ _) (measure_ne_top μ _)]
    exact measure_mono (Set.subset_univ _)
  calc
    (μ {ω | ε ≤ X ω}).toReal = (μ {ω | exp (t * ε) ≤ exp (t * X ω)}).toReal :=
      by
      congr with ω
      simp only [exp_le_exp, eq_iff_iff]
      exact
        ⟨fun h => mul_le_mul_of_nonneg_left h ht_pos.le, fun h => le_of_mul_le_mul_left h ht_pos⟩
    _ ≤ (exp (t * ε))⁻¹ * μ[fun ω => exp (t * X ω)] :=
      by
      have :
        exp (t * ε) * (μ {ω | exp (t * ε) ≤ exp (t * X ω)}).toReal ≤ μ[fun ω => exp (t * X ω)] :=
        mul_meas_ge_le_integral_of_nonneg (fun x => (exp_pos _).le) h_int _
      rwa [mul_comm (exp (t * ε))⁻¹, ← div_eq_mul_inv, le_div_iff' (exp_pos _)]
    _ = exp (-t * ε) * mgf X μ t := by rw [neg_mul, exp_neg]; rfl
#align probability_theory.measure_ge_le_exp_mul_mgf ProbabilityTheory.measure_ge_le_exp_mul_mgf
-/

#print ProbabilityTheory.measure_le_le_exp_mul_mgf /-
/-- **Chernoff bound** on the lower tail of a real random variable. -/
theorem measure_le_le_exp_mul_mgf [IsFiniteMeasure μ] (ε : ℝ) (ht : t ≤ 0)
    (h_int : Integrable (fun ω => exp (t * X ω)) μ) :
    (μ {ω | X ω ≤ ε}).toReal ≤ exp (-t * ε) * mgf X μ t :=
  by
  rw [← neg_neg t, ← mgf_neg, neg_neg, ← neg_mul_neg (-t)]
  refine' Eq.trans_le _ (measure_ge_le_exp_mul_mgf (-ε) (neg_nonneg.mpr ht) _)
  · congr with ω
    simp only [Pi.neg_apply, neg_le_neg_iff]
  · simp_rw [Pi.neg_apply, neg_mul_neg]
    exact h_int
#align probability_theory.measure_le_le_exp_mul_mgf ProbabilityTheory.measure_le_le_exp_mul_mgf
-/

#print ProbabilityTheory.measure_ge_le_exp_cgf /-
/-- **Chernoff bound** on the upper tail of a real random variable. -/
theorem measure_ge_le_exp_cgf [IsFiniteMeasure μ] (ε : ℝ) (ht : 0 ≤ t)
    (h_int : Integrable (fun ω => exp (t * X ω)) μ) :
    (μ {ω | ε ≤ X ω}).toReal ≤ exp (-t * ε + cgf X μ t) :=
  by
  refine' (measure_ge_le_exp_mul_mgf ε ht h_int).trans _
  rw [exp_add]
  exact mul_le_mul le_rfl (le_exp_log _) mgf_nonneg (exp_pos _).le
#align probability_theory.measure_ge_le_exp_cgf ProbabilityTheory.measure_ge_le_exp_cgf
-/

#print ProbabilityTheory.measure_le_le_exp_cgf /-
/-- **Chernoff bound** on the lower tail of a real random variable. -/
theorem measure_le_le_exp_cgf [IsFiniteMeasure μ] (ε : ℝ) (ht : t ≤ 0)
    (h_int : Integrable (fun ω => exp (t * X ω)) μ) :
    (μ {ω | X ω ≤ ε}).toReal ≤ exp (-t * ε + cgf X μ t) :=
  by
  refine' (measure_le_le_exp_mul_mgf ε ht h_int).trans _
  rw [exp_add]
  exact mul_le_mul le_rfl (le_exp_log _) mgf_nonneg (exp_pos _).le
#align probability_theory.measure_le_le_exp_cgf ProbabilityTheory.measure_le_le_exp_cgf
-/

end MomentGeneratingFunction

end ProbabilityTheory

