/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module probability.strong_law
! leanprover-community/mathlib commit 1b089e3bdc3ce6b39cd472543474a0a137128c6c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.IdentDistrib
import Mathbin.MeasureTheory.Integral.IntervalIntegral
import Mathbin.Analysis.SpecificLimits.FloorPow
import Mathbin.Analysis.PSeries
import Mathbin.Analysis.Asymptotics.SpecificAsymptotics

/-!
# The strong law of large numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We prove the strong law of large numbers, in `probability_theory.strong_law_ae`:
If `X n` is a sequence of independent identically distributed integrable real-valued random
variables, then `∑ i in range n, X i / n` converges almost surely to `𝔼[X 0]`.
We give here the strong version, due to Etemadi, that only requires pairwise independence.

This file also contains the Lᵖ version of the strong law of large numbers provided by
`probability_theory.strong_law_Lp` which shows `∑ i in range n, X i / n` converges in Lᵖ to
`𝔼[X 0]` provided `X n` is independent identically distributed and is Lᵖ.

## Implementation

We follow the proof by Etemadi
[Etemadi, *An elementary proof of the strong law of large numbers*][etemadi_strong_law],
which goes as follows.

It suffices to prove the result for nonnegative `X`, as one can prove the general result by
splitting a general `X` into its positive part and negative part.
Consider `Xₙ` a sequence of nonnegative integrable identically distributed pairwise independent
random variables. Let `Yₙ` be the truncation of `Xₙ` up to `n`. We claim that
* Almost surely, `Xₙ = Yₙ` for all but finitely many indices. Indeed, `∑ ℙ (Xₙ ≠ Yₙ)` is bounded by
  `1 + 𝔼[X]` (see `sum_prob_mem_Ioc_le` and `tsum_prob_mem_Ioi_lt_top`).
* Let `c > 1`. Along the sequence `n = c ^ k`, then `(∑_{i=0}^{n-1} Yᵢ - 𝔼[Yᵢ])/n` converges almost
  surely to `0`. This follows from a variance control, as
```
  ∑_k ℙ (|∑_{i=0}^{c^k - 1} Yᵢ - 𝔼[Yᵢ]| > c^k ε)
    ≤ ∑_k (c^k ε)^{-2} ∑_{i=0}^{c^k - 1} Var[Yᵢ]    (by Markov inequality)
    ≤ ∑_i (C/i^2) Var[Yᵢ]                           (as ∑_{c^k > i} 1/(c^k)^2 ≤ C/i^2)
    ≤ ∑_i (C/i^2) 𝔼[Yᵢ^2]
    ≤ 2C 𝔼[X^2]                                     (see `sum_variance_truncation_le`)
```
* As `𝔼[Yᵢ]` converges to `𝔼[X]`, it follows from the two previous items and Cesaro that, along
  the sequence `n = c^k`, one has `(∑_{i=0}^{n-1} Xᵢ) / n → 𝔼[X]` almost surely.
* To generalize it to all indices, we use the fact that `∑_{i=0}^{n-1} Xᵢ` is nondecreasing and
  that, if `c` is close enough to `1`, the gap between `c^k` and `c^(k+1)` is small.
-/


noncomputable section

open MeasureTheory Filter Finset Asymptotics

open Set (indicator)

open scoped Topology BigOperators MeasureTheory ProbabilityTheory ENNReal NNReal

namespace ProbabilityTheory

/-! ### Prerequisites on truncations -/


section Truncation

variable {α : Type _}

#print ProbabilityTheory.truncation /-
/-- Truncating a real-valued function to the interval `(-A, A]`. -/
def truncation (f : α → ℝ) (A : ℝ) :=
  indicator (Set.Ioc (-A) A) id ∘ f
#align probability_theory.truncation ProbabilityTheory.truncation
-/

variable {m : MeasurableSpace α} {μ : Measure α} {f : α → ℝ}

#print MeasureTheory.AEStronglyMeasurable.truncation /-
theorem MeasureTheory.AEStronglyMeasurable.truncation (hf : AEStronglyMeasurable f μ) {A : ℝ} :
    AEStronglyMeasurable (truncation f A) μ :=
  by
  apply ae_strongly_measurable.comp_ae_measurable _ hf.ae_measurable
  exact (strongly_measurable_id.indicator measurableSet_Ioc).AEStronglyMeasurable
#align measure_theory.ae_strongly_measurable.truncation MeasureTheory.AEStronglyMeasurable.truncation
-/

#print ProbabilityTheory.abs_truncation_le_bound /-
theorem abs_truncation_le_bound (f : α → ℝ) (A : ℝ) (x : α) : |truncation f A x| ≤ |A| :=
  by
  simp only [truncation, Set.indicator, Set.mem_Icc, id.def, Function.comp_apply]
  split_ifs
  · exact abs_le_abs h.2 (neg_le.2 h.1.le)
  · simp [abs_nonneg]
#align probability_theory.abs_truncation_le_bound ProbabilityTheory.abs_truncation_le_bound
-/

#print ProbabilityTheory.truncation_zero /-
@[simp]
theorem truncation_zero (f : α → ℝ) : truncation f 0 = 0 := by simp [truncation]
#align probability_theory.truncation_zero ProbabilityTheory.truncation_zero
-/

#print ProbabilityTheory.abs_truncation_le_abs_self /-
theorem abs_truncation_le_abs_self (f : α → ℝ) (A : ℝ) (x : α) : |truncation f A x| ≤ |f x| :=
  by
  simp only [truncation, indicator, Set.mem_Icc, id.def, Function.comp_apply]
  split_ifs
  · exact le_rfl
  · simp [abs_nonneg]
#align probability_theory.abs_truncation_le_abs_self ProbabilityTheory.abs_truncation_le_abs_self
-/

#print ProbabilityTheory.truncation_eq_self /-
theorem truncation_eq_self {f : α → ℝ} {A : ℝ} {x : α} (h : |f x| < A) : truncation f A x = f x :=
  by
  simp only [truncation, indicator, Set.mem_Icc, id.def, Function.comp_apply, ite_eq_left_iff]
  intro H
  apply H.elim
  simp [(abs_lt.1 h).1, (abs_lt.1 h).2.le]
#align probability_theory.truncation_eq_self ProbabilityTheory.truncation_eq_self
-/

#print ProbabilityTheory.truncation_eq_of_nonneg /-
theorem truncation_eq_of_nonneg {f : α → ℝ} {A : ℝ} (h : ∀ x, 0 ≤ f x) :
    truncation f A = indicator (Set.Ioc 0 A) id ∘ f :=
  by
  ext x
  rcases(h x).lt_or_eq with (hx | hx)
  · simp only [truncation, indicator, hx, Set.mem_Ioc, id.def, Function.comp_apply, true_and_iff]
    by_cases h'x : f x ≤ A
    · have : -A < f x := by linarith [h x]
      simp only [this, true_and_iff]
    · simp only [h'x, and_false_iff]
  · simp only [truncation, indicator, hx, id.def, Function.comp_apply, if_t_t]
#align probability_theory.truncation_eq_of_nonneg ProbabilityTheory.truncation_eq_of_nonneg
-/

#print ProbabilityTheory.truncation_nonneg /-
theorem truncation_nonneg {f : α → ℝ} (A : ℝ) {x : α} (h : 0 ≤ f x) : 0 ≤ truncation f A x :=
  Set.indicator_apply_nonneg fun _ => h
#align probability_theory.truncation_nonneg ProbabilityTheory.truncation_nonneg
-/

#print MeasureTheory.AEStronglyMeasurable.memℒp_truncation /-
theorem MeasureTheory.AEStronglyMeasurable.memℒp_truncation [IsFiniteMeasure μ]
    (hf : AEStronglyMeasurable f μ) {A : ℝ} {p : ℝ≥0∞} : Memℒp (truncation f A) p μ :=
  Memℒp.of_bound hf.truncation (|A|) (eventually_of_forall fun x => abs_truncation_le_bound _ _ _)
#align measure_theory.ae_strongly_measurable.mem_ℒp_truncation MeasureTheory.AEStronglyMeasurable.memℒp_truncation
-/

#print MeasureTheory.AEStronglyMeasurable.integrable_truncation /-
theorem MeasureTheory.AEStronglyMeasurable.integrable_truncation [IsFiniteMeasure μ]
    (hf : AEStronglyMeasurable f μ) {A : ℝ} : Integrable (truncation f A) μ := by
  rw [← mem_ℒp_one_iff_integrable]; exact hf.mem_ℒp_truncation
#align measure_theory.ae_strongly_measurable.integrable_truncation MeasureTheory.AEStronglyMeasurable.integrable_truncation
-/

#print ProbabilityTheory.moment_truncation_eq_intervalIntegral /-
theorem moment_truncation_eq_intervalIntegral (hf : AEStronglyMeasurable f μ) {A : ℝ} (hA : 0 ≤ A)
    {n : ℕ} (hn : n ≠ 0) : ∫ x, truncation f A x ^ n ∂μ = ∫ y in -A..A, y ^ n ∂Measure.map f μ :=
  by
  have M : MeasurableSet (Set.Ioc (-A) A) := measurableSet_Ioc
  change ∫ x, (fun z => indicator (Set.Ioc (-A) A) id z ^ n) (f x) ∂μ = _
  rw [← integral_map hf.ae_measurable, intervalIntegral.integral_of_le, ← integral_indicator M]
  · simp only [indicator, zero_pow' _ hn, id.def, ite_pow]
  · linarith
  · exact ((measurable_id.indicator M).pow_const n).AEStronglyMeasurable
#align probability_theory.moment_truncation_eq_interval_integral ProbabilityTheory.moment_truncation_eq_intervalIntegral
-/

#print ProbabilityTheory.moment_truncation_eq_intervalIntegral_of_nonneg /-
theorem moment_truncation_eq_intervalIntegral_of_nonneg (hf : AEStronglyMeasurable f μ) {A : ℝ}
    {n : ℕ} (hn : n ≠ 0) (h'f : 0 ≤ f) :
    ∫ x, truncation f A x ^ n ∂μ = ∫ y in 0 ..A, y ^ n ∂Measure.map f μ :=
  by
  have M : MeasurableSet (Set.Ioc 0 A) := measurableSet_Ioc
  have M' : MeasurableSet (Set.Ioc A 0) := measurableSet_Ioc
  rw [truncation_eq_of_nonneg h'f]
  change ∫ x, (fun z => indicator (Set.Ioc 0 A) id z ^ n) (f x) ∂μ = _
  rcases le_or_lt 0 A with (hA | hA)
  · rw [← integral_map hf.ae_measurable, intervalIntegral.integral_of_le hA, ← integral_indicator M]
    · simp only [indicator, zero_pow' _ hn, id.def, ite_pow]
    · exact ((measurable_id.indicator M).pow_const n).AEStronglyMeasurable
  · rw [← integral_map hf.ae_measurable, intervalIntegral.integral_of_ge hA.le, ←
      integral_indicator M']
    · simp only [Set.Ioc_eq_empty_of_le hA.le, zero_pow' _ hn, Set.indicator_empty, integral_zero,
        zero_eq_neg]
      apply integral_eq_zero_of_ae
      have : ∀ᵐ x ∂measure.map f μ, (0 : ℝ) ≤ x :=
        (ae_map_iff hf.ae_measurable measurableSet_Ici).2 (eventually_of_forall h'f)
      filter_upwards [this] with x hx
      simp only [indicator, Set.mem_Ioc, Pi.zero_apply, ite_eq_right_iff, and_imp]
      intro h'x h''x
      have : x = 0 := by linarith
      simp [this, zero_pow' _ hn]
    · exact ((measurable_id.indicator M).pow_const n).AEStronglyMeasurable
#align probability_theory.moment_truncation_eq_interval_integral_of_nonneg ProbabilityTheory.moment_truncation_eq_intervalIntegral_of_nonneg
-/

#print ProbabilityTheory.integral_truncation_eq_intervalIntegral /-
theorem integral_truncation_eq_intervalIntegral (hf : AEStronglyMeasurable f μ) {A : ℝ}
    (hA : 0 ≤ A) : ∫ x, truncation f A x ∂μ = ∫ y in -A..A, y ∂Measure.map f μ := by
  simpa using moment_truncation_eq_interval_integral hf hA one_ne_zero
#align probability_theory.integral_truncation_eq_interval_integral ProbabilityTheory.integral_truncation_eq_intervalIntegral
-/

#print ProbabilityTheory.integral_truncation_eq_intervalIntegral_of_nonneg /-
theorem integral_truncation_eq_intervalIntegral_of_nonneg (hf : AEStronglyMeasurable f μ) {A : ℝ}
    (h'f : 0 ≤ f) : ∫ x, truncation f A x ∂μ = ∫ y in 0 ..A, y ∂Measure.map f μ := by
  simpa using moment_truncation_eq_interval_integral_of_nonneg hf one_ne_zero h'f
#align probability_theory.integral_truncation_eq_interval_integral_of_nonneg ProbabilityTheory.integral_truncation_eq_intervalIntegral_of_nonneg
-/

#print ProbabilityTheory.integral_truncation_le_integral_of_nonneg /-
theorem integral_truncation_le_integral_of_nonneg (hf : Integrable f μ) (h'f : 0 ≤ f) {A : ℝ} :
    ∫ x, truncation f A x ∂μ ≤ ∫ x, f x ∂μ :=
  by
  apply
    integral_mono_of_nonneg (eventually_of_forall fun x => _) hf (eventually_of_forall fun x => _)
  · exact truncation_nonneg _ (h'f x)
  ·
    calc
      truncation f A x ≤ |truncation f A x| := le_abs_self _
      _ ≤ |f x| := (abs_truncation_le_abs_self _ _ _)
      _ = f x := abs_of_nonneg (h'f x)
#align probability_theory.integral_truncation_le_integral_of_nonneg ProbabilityTheory.integral_truncation_le_integral_of_nonneg
-/

#print ProbabilityTheory.tendsto_integral_truncation /-
/-- If a function is integrable, then the integral of its truncated versions converges to the
integral of the whole function. -/
theorem tendsto_integral_truncation {f : α → ℝ} (hf : Integrable f μ) :
    Tendsto (fun A => ∫ x, truncation f A x ∂μ) atTop (𝓝 (∫ x, f x ∂μ)) :=
  by
  refine' tendsto_integral_filter_of_dominated_convergence (fun x => abs (f x)) _ _ _ _
  · exact eventually_of_forall fun A => hf.ae_strongly_measurable.truncation
  · apply eventually_of_forall fun A => _
    apply eventually_of_forall fun x => _
    rw [Real.norm_eq_abs]
    exact abs_truncation_le_abs_self _ _ _
  · apply hf.abs
  · apply eventually_of_forall fun x => _
    apply tendsto_const_nhds.congr' _
    filter_upwards [Ioi_mem_at_top (abs (f x))] with A hA
    exact (truncation_eq_self hA).symm
#align probability_theory.tendsto_integral_truncation ProbabilityTheory.tendsto_integral_truncation
-/

#print ProbabilityTheory.IdentDistrib.truncation /-
theorem IdentDistrib.truncation {β : Type _} [MeasurableSpace β] {ν : Measure β} {f : α → ℝ}
    {g : β → ℝ} (h : IdentDistrib f g μ ν) {A : ℝ} :
    IdentDistrib (truncation f A) (truncation g A) μ ν :=
  h.comp (measurable_id.indicator measurableSet_Ioc)
#align probability_theory.ident_distrib.truncation ProbabilityTheory.IdentDistrib.truncation
-/

end Truncation

section StrongLawAe

variable {Ω : Type _} [MeasureSpace Ω] [IsProbabilityMeasure (ℙ : Measure Ω)]

section MomentEstimates

#print ProbabilityTheory.sum_prob_mem_Ioc_le /-
theorem sum_prob_mem_Ioc_le {X : Ω → ℝ} (hint : Integrable X) (hnonneg : 0 ≤ X) {K : ℕ} {N : ℕ}
    (hKN : K ≤ N) : ∑ j in range K, ℙ {ω | X ω ∈ Set.Ioc (j : ℝ) N} ≤ ENNReal.ofReal (𝔼[X] + 1) :=
  by
  let ρ : Measure ℝ := measure.map X ℙ
  haveI : is_probability_measure ρ := is_probability_measure_map hint.ae_measurable
  have A : ∑ j in range K, ∫ x in j..N, (1 : ℝ) ∂ρ ≤ 𝔼[X] + 1 :=
    calc
      ∑ j in range K, ∫ x in j..N, (1 : ℝ) ∂ρ =
          ∑ j in range K, ∑ i in Ico j N, ∫ x in i..(i + 1 : ℕ), (1 : ℝ) ∂ρ :=
        by
        apply sum_congr rfl fun j hj => _
        rw [intervalIntegral.sum_integral_adjacent_intervals_Ico ((mem_range.1 hj).le.trans hKN)]
        intro k hk
        exact continuous_const.interval_integrable _ _
      _ = ∑ i in range N, ∑ j in range (min (i + 1) K), ∫ x in i..(i + 1 : ℕ), (1 : ℝ) ∂ρ :=
        by
        simp_rw [sum_sigma']
        refine'
          sum_bij' (fun (p : Σ i : ℕ, ℕ) hp => (⟨p.2, p.1⟩ : Σ i : ℕ, ℕ)) _ (fun a ha => rfl)
            (fun (p : Σ i : ℕ, ℕ) hp => (⟨p.2, p.1⟩ : Σ i : ℕ, ℕ)) _ _ _
        · rintro ⟨i, j⟩ hij
          simp only [mem_sigma, mem_range, mem_Ico] at hij 
          simp only [hij, Nat.lt_succ_iff.2 hij.2.1, mem_sigma, mem_range, lt_min_iff, and_self_iff]
        · rintro ⟨i, j⟩ hij
          simp only [mem_sigma, mem_range, lt_min_iff] at hij 
          simp only [hij, Nat.lt_succ_iff.1 hij.2.1, mem_sigma, mem_range, mem_Ico, and_self_iff]
        · rintro ⟨i, j⟩ hij; rfl
        · rintro ⟨i, j⟩ hij; rfl
      _ ≤ ∑ i in range N, (i + 1) * ∫ x in i..(i + 1 : ℕ), (1 : ℝ) ∂ρ :=
        by
        apply sum_le_sum fun i hi => _
        simp only [Nat.cast_add, Nat.cast_one, sum_const, card_range, nsmul_eq_mul, Nat.cast_min]
        refine' mul_le_mul_of_nonneg_right (min_le_left _ _) _
        apply intervalIntegral.integral_nonneg
        · simp only [le_add_iff_nonneg_right, zero_le_one]
        · simp only [zero_le_one, imp_true_iff]
      _ ≤ ∑ i in range N, ∫ x in i..(i + 1 : ℕ), x + 1 ∂ρ :=
        by
        apply sum_le_sum fun i hi => _
        have I : (i : ℝ) ≤ (i + 1 : ℕ) := by
          simp only [Nat.cast_add, Nat.cast_one, le_add_iff_nonneg_right, zero_le_one]
        simp_rw [intervalIntegral.integral_of_le I, ← integral_mul_left]
        apply set_integral_mono_on
        · exact continuous_const.integrable_on_Ioc
        · exact (continuous_id.add continuous_const).integrableOn_Ioc
        · exact measurableSet_Ioc
        · intro x hx
          simp only [Nat.cast_add, Nat.cast_one, Set.mem_Ioc] at hx 
          simp [hx.1.le]
      _ = ∫ x in 0 ..N, x + 1 ∂ρ :=
        by
        rw [intervalIntegral.sum_integral_adjacent_intervals fun k hk => _]
        · norm_cast
        · exact (continuous_id.add continuous_const).IntervalIntegrable _ _
      _ = ∫ x in 0 ..N, x ∂ρ + ∫ x in 0 ..N, 1 ∂ρ :=
        by
        rw [intervalIntegral.integral_add]
        · exact continuous_id.interval_integrable _ _
        · exact continuous_const.interval_integrable _ _
      _ = 𝔼[truncation X N] + ∫ x in 0 ..N, 1 ∂ρ := by
        rw [integral_truncation_eq_interval_integral_of_nonneg hint.1 hnonneg]
      _ ≤ 𝔼[X] + ∫ x in 0 ..N, 1 ∂ρ :=
        (add_le_add_right (integral_truncation_le_integral_of_nonneg hint hnonneg) _)
      _ ≤ 𝔼[X] + 1 := by
        refine' add_le_add le_rfl _
        rw [intervalIntegral.integral_of_le (Nat.cast_nonneg _)]
        simp only [integral_const, measure.restrict_apply', measurableSet_Ioc, Set.univ_inter,
          Algebra.id.smul_eq_mul, mul_one]
        rw [← ENNReal.one_toReal]
        exact ENNReal.toReal_mono ENNReal.one_ne_top prob_le_one
  have B : ∀ a b, ℙ {ω | X ω ∈ Set.Ioc a b} = ENNReal.ofReal (∫ x in Set.Ioc a b, (1 : ℝ) ∂ρ) :=
    by
    intro a b
    rw [of_real_set_integral_one ρ _,
      measure.map_apply_of_ae_measurable hint.ae_measurable measurableSet_Ioc]
    rfl
  calc
    ∑ j in range K, ℙ {ω | X ω ∈ Set.Ioc (j : ℝ) N} =
        ∑ j in range K, ENNReal.ofReal (∫ x in Set.Ioc (j : ℝ) N, (1 : ℝ) ∂ρ) :=
      by simp_rw [B]
    _ = ENNReal.ofReal (∑ j in range K, ∫ x in Set.Ioc (j : ℝ) N, (1 : ℝ) ∂ρ) :=
      by
      rw [ENNReal.ofReal_sum_of_nonneg]
      simp only [integral_const, Algebra.id.smul_eq_mul, mul_one, ENNReal.toReal_nonneg,
        imp_true_iff]
    _ = ENNReal.ofReal (∑ j in range K, ∫ x in (j : ℝ)..N, (1 : ℝ) ∂ρ) :=
      by
      congr 1
      refine' sum_congr rfl fun j hj => _
      rw [intervalIntegral.integral_of_le (Nat.cast_le.2 ((mem_range.1 hj).le.trans hKN))]
    _ ≤ ENNReal.ofReal (𝔼[X] + 1) := ENNReal.ofReal_le_ofReal A
#align probability_theory.sum_prob_mem_Ioc_le ProbabilityTheory.sum_prob_mem_Ioc_le
-/

#print ProbabilityTheory.tsum_prob_mem_Ioi_lt_top /-
theorem tsum_prob_mem_Ioi_lt_top {X : Ω → ℝ} (hint : Integrable X) (hnonneg : 0 ≤ X) :
    ∑' j : ℕ, ℙ {ω | X ω ∈ Set.Ioi (j : ℝ)} < ∞ :=
  by
  suffices : ∀ K : ℕ, ∑ j in range K, ℙ {ω | X ω ∈ Set.Ioi (j : ℝ)} ≤ ENNReal.ofReal (𝔼[X] + 1)
  exact
    (le_of_tendsto_of_tendsto (ENNReal.tendsto_nat_tsum _) tendsto_const_nhds
          (eventually_of_forall this)).trans_lt
      ENNReal.ofReal_lt_top
  intro K
  have A :
    tendsto (fun N : ℕ => ∑ j in range K, ℙ {ω | X ω ∈ Set.Ioc (j : ℝ) N}) at_top
      (𝓝 (∑ j in range K, ℙ {ω | X ω ∈ Set.Ioi (j : ℝ)})) :=
    by
    refine' tendsto_finset_sum _ fun i hi => _
    have : {ω | X ω ∈ Set.Ioi (i : ℝ)} = ⋃ N : ℕ, {ω | X ω ∈ Set.Ioc (i : ℝ) N} :=
      by
      apply Set.Subset.antisymm _ _
      · intro ω hω
        obtain ⟨N, hN⟩ : ∃ N : ℕ, X ω ≤ N := exists_nat_ge (X ω)
        exact Set.mem_iUnion.2 ⟨N, hω, hN⟩
      ·
        simp (config := { contextual := true }) only [Set.mem_Ioc, Set.mem_Ioi,
          Set.iUnion_subset_iff, Set.setOf_subset_setOf, imp_true_iff]
    rw [this]
    apply tendsto_measure_Union
    intro m n hmn x hx
    exact ⟨hx.1, hx.2.trans (Nat.cast_le.2 hmn)⟩
  apply le_of_tendsto_of_tendsto A tendsto_const_nhds
  filter_upwards [Ici_mem_at_top K] with N hN
  exact sum_prob_mem_Ioc_le hint hnonneg hN
#align probability_theory.tsum_prob_mem_Ioi_lt_top ProbabilityTheory.tsum_prob_mem_Ioi_lt_top
-/

#print ProbabilityTheory.sum_variance_truncation_le /-
theorem sum_variance_truncation_le {X : Ω → ℝ} (hint : Integrable X) (hnonneg : 0 ≤ X) (K : ℕ) :
    ∑ j in range K, ((j : ℝ) ^ 2)⁻¹ * 𝔼[truncation X j ^ 2] ≤ 2 * 𝔼[X] :=
  by
  set Y := fun n : ℕ => truncation X n
  let ρ : Measure ℝ := measure.map X ℙ
  have Y2 : ∀ n, 𝔼[Y n ^ 2] = ∫ x in 0 ..n, x ^ 2 ∂ρ :=
    by
    intro n
    change 𝔼[fun x => Y n x ^ 2] = _
    rw [moment_truncation_eq_interval_integral_of_nonneg hint.1 two_ne_zero hnonneg]
  calc
    ∑ j in range K, ((j : ℝ) ^ 2)⁻¹ * 𝔼[Y j ^ 2] =
        ∑ j in range K, ((j : ℝ) ^ 2)⁻¹ * ∫ x in 0 ..j, x ^ 2 ∂ρ :=
      by simp_rw [Y2]
    _ = ∑ j in range K, ((j : ℝ) ^ 2)⁻¹ * ∑ k in range j, ∫ x in k..(k + 1 : ℕ), x ^ 2 ∂ρ :=
      by
      congr 1 with j
      congr 1
      rw [intervalIntegral.sum_integral_adjacent_intervals]
      · norm_cast
      intro k hk
      exact (continuous_id.pow _).IntervalIntegrable _ _
    _ = ∑ k in range K, (∑ j in Ioo k K, ((j : ℝ) ^ 2)⁻¹) * ∫ x in k..(k + 1 : ℕ), x ^ 2 ∂ρ :=
      by
      simp_rw [mul_sum, sum_mul, sum_sigma']
      refine'
        sum_bij' (fun (p : Σ i : ℕ, ℕ) hp => (⟨p.2, p.1⟩ : Σ i : ℕ, ℕ)) _ (fun a ha => rfl)
          (fun (p : Σ i : ℕ, ℕ) hp => (⟨p.2, p.1⟩ : Σ i : ℕ, ℕ)) _ _ _
      · rintro ⟨i, j⟩ hij
        simp only [mem_sigma, mem_range, mem_filter] at hij 
        simp [hij, mem_sigma, mem_range, and_self_iff, hij.2.trans hij.1]
      · rintro ⟨i, j⟩ hij
        simp only [mem_sigma, mem_range, mem_Ioo] at hij 
        simp only [hij, mem_sigma, mem_range, and_self_iff]
      · rintro ⟨i, j⟩ hij; rfl
      · rintro ⟨i, j⟩ hij; rfl
    _ ≤ ∑ k in range K, 2 / (k + 1) * ∫ x in k..(k + 1 : ℕ), x ^ 2 ∂ρ :=
      by
      apply sum_le_sum fun k hk => _
      refine' mul_le_mul_of_nonneg_right (sum_Ioo_inv_sq_le _ _) _
      refine' intervalIntegral.integral_nonneg_of_forall _ fun u => sq_nonneg _
      simp only [Nat.cast_add, Nat.cast_one, le_add_iff_nonneg_right, zero_le_one]
    _ ≤ ∑ k in range K, ∫ x in k..(k + 1 : ℕ), 2 * x ∂ρ :=
      by
      apply sum_le_sum fun k hk => _
      have Ik : (k : ℝ) ≤ (k + 1 : ℕ) := by simp
      rw [← intervalIntegral.integral_const_mul, intervalIntegral.integral_of_le Ik,
        intervalIntegral.integral_of_le Ik]
      refine' set_integral_mono_on _ _ measurableSet_Ioc fun x hx => _
      · apply Continuous.integrableOn_Ioc
        exact continuous_const.mul (continuous_pow 2)
      · apply Continuous.integrableOn_Ioc
        exact continuous_const.mul continuous_id'
      ·
        calc
          2 / (↑k + 1) * x ^ 2 = x / (k + 1) * (2 * x) := by ring
          _ ≤ 1 * (2 * x) :=
            (mul_le_mul_of_nonneg_right
              (by
                apply_mod_cast (div_le_one _).2 hx.2
                simp only [Nat.cast_add, Nat.cast_one]
                linarith only [show (0 : ℝ) ≤ k from Nat.cast_nonneg k])
              (mul_nonneg zero_le_two ((Nat.cast_nonneg k).trans hx.1.le)))
          _ = 2 * x := by rw [one_mul]
    _ = 2 * ∫ x in (0 : ℝ)..K, x ∂ρ :=
      by
      rw [intervalIntegral.sum_integral_adjacent_intervals fun k hk => _]
      swap; · exact (continuous_const.mul continuous_id').IntervalIntegrable _ _
      rw [intervalIntegral.integral_const_mul]
      norm_cast
    _ ≤ 2 * 𝔼[X] :=
      mul_le_mul_of_nonneg_left
        (by
          rw [← integral_truncation_eq_interval_integral_of_nonneg hint.1 hnonneg]
          exact integral_truncation_le_integral_of_nonneg hint hnonneg)
        zero_le_two
#align probability_theory.sum_variance_truncation_le ProbabilityTheory.sum_variance_truncation_le
-/

end MomentEstimates

section StrongLawNonneg

/- This paragraph proves the strong law of large numbers (almost sure version, assuming only
pairwise independence) for nonnegative random variables, following Etemadi's proof. -/
variable (X : ℕ → Ω → ℝ) (hint : Integrable (X 0))
  (hindep : Pairwise fun i j => IndepFun (X i) (X j)) (hident : ∀ i, IdentDistrib (X i) (X 0))
  (hnonneg : ∀ i ω, 0 ≤ X i ω)

#print ProbabilityTheory.strong_law_aux1 /-
/- The truncation of `Xᵢ` up to `i` satisfies the strong law of large numbers (with respect to
the truncated expectation) along the sequence `c^n`, for any `c > 1`, up to a given `ε > 0`.
This follows from a variance control. -/
theorem strong_law_aux1 {c : ℝ} (c_one : 1 < c) {ε : ℝ} (εpos : 0 < ε) :
    ∀ᵐ ω,
      ∀ᶠ n : ℕ in atTop,
        |∑ i in range ⌊c ^ n⌋₊, truncation (X i) i ω -
              𝔼[∑ i in range ⌊c ^ n⌋₊, truncation (X i) i]| <
          ε * ⌊c ^ n⌋₊ :=
  by
  /- Let `S n = ∑ i in range n, Y i` where `Y i = truncation (X i) i`. We should show that
    `|S k - 𝔼[S k]| / k ≤ ε` along the sequence of powers of `c`. For this, we apply Borel-Cantelli:
    it suffices to show that the converse probabilites are summable. From Chebyshev inequality, this
    will follow from a variance control `∑' Var[S (c^i)] / (c^i)^2 < ∞`. This is checked in `I2` using
    pairwise independence to expand the variance of the sum as the sum of the variances, and then
    a straightforward but tedious computation (essentially boiling down to the fact that the sum of
    `1/(c ^ i)^2` beyong a threshold `j` is comparable to `1/j^2`).
    Note that we have written `c^i` in the above proof sketch, but rigorously one should put integer
    parts everywhere, making things more painful. We write `u i = ⌊c^i⌋₊` for brevity. -/
  have c_pos : 0 < c := zero_lt_one.trans c_one
  let ρ : Measure ℝ := measure.map (X 0) ℙ
  have hX : ∀ i, ae_strongly_measurable (X i) ℙ := fun i =>
    (hident i).symm.aestronglyMeasurable_snd hint.1
  have A : ∀ i, strongly_measurable (indicator (Set.Ioc (-i : ℝ) i) id) := fun i =>
    strongly_measurable_id.indicator measurableSet_Ioc
  set Y := fun n : ℕ => truncation (X n) n with hY
  set S := fun n => ∑ i in range n, Y i with hS
  let u : ℕ → ℕ := fun n => ⌊c ^ n⌋₊
  have u_mono : Monotone u := fun i j hij => Nat.floor_mono (pow_le_pow c_one.le hij)
  have I1 : ∀ K, ∑ j in range K, ((j : ℝ) ^ 2)⁻¹ * Var[Y j] ≤ 2 * 𝔼[X 0] :=
    by
    intro K
    calc
      ∑ j in range K, ((j : ℝ) ^ 2)⁻¹ * Var[Y j] ≤
          ∑ j in range K, ((j : ℝ) ^ 2)⁻¹ * 𝔼[truncation (X 0) j ^ 2] :=
        by
        apply sum_le_sum fun j hj => _
        refine' mul_le_mul_of_nonneg_left _ (inv_nonneg.2 (sq_nonneg _))
        rw [(hident j).truncation.variance_eq]
        exact variance_le_expectation_sq (hX 0).truncation
      _ ≤ 2 * 𝔼[X 0] := sum_variance_truncation_le hint (hnonneg 0) K
  let C := c ^ 5 * (c - 1)⁻¹ ^ 3 * (2 * 𝔼[X 0])
  have I2 : ∀ N, ∑ i in range N, ((u i : ℝ) ^ 2)⁻¹ * Var[S (u i)] ≤ C :=
    by
    intro N
    calc
      ∑ i in range N, ((u i : ℝ) ^ 2)⁻¹ * Var[S (u i)] =
          ∑ i in range N, ((u i : ℝ) ^ 2)⁻¹ * ∑ j in range (u i), Var[Y j] :=
        by
        congr 1 with i
        congr 1
        rw [hS, indep_fun.variance_sum]
        · intro j hj
          exact (hident j).aestronglyMeasurable_fst.memℒp_truncation
        · intro k hk l hl hkl
          exact (hindep hkl).comp (A k).Measurable (A l).Measurable
      _ =
          ∑ j in range (u (N - 1)),
            (∑ i in (range N).filterₓ fun i => j < u i, ((u i : ℝ) ^ 2)⁻¹) * Var[Y j] :=
        by
        simp_rw [mul_sum, sum_mul, sum_sigma']
        refine'
          sum_bij' (fun (p : Σ i : ℕ, ℕ) hp => (⟨p.2, p.1⟩ : Σ i : ℕ, ℕ)) _ (fun a ha => rfl)
            (fun (p : Σ i : ℕ, ℕ) hp => (⟨p.2, p.1⟩ : Σ i : ℕ, ℕ)) _ _ _
        · rintro ⟨i, j⟩ hij
          simp only [mem_sigma, mem_range] at hij 
          simp only [hij.1, hij.2, mem_sigma, mem_range, mem_filter, and_true_iff]
          exact hij.2.trans_le (u_mono (Nat.le_pred_of_lt hij.1))
        · rintro ⟨i, j⟩ hij
          simp only [mem_sigma, mem_range, mem_filter] at hij 
          simp only [hij.2.1, hij.2.2, mem_sigma, mem_range, and_self_iff]
        · rintro ⟨i, j⟩ hij; rfl
        · rintro ⟨i, j⟩ hij; rfl
      _ ≤ ∑ j in range (u (N - 1)), c ^ 5 * (c - 1)⁻¹ ^ 3 / j ^ 2 * Var[Y j] :=
        by
        apply sum_le_sum fun j hj => _
        rcases@eq_zero_or_pos _ _ j with (rfl | hj)
        · simp only [Y, Nat.cast_zero, zero_pow', Ne.def, bit0_eq_zero, Nat.one_ne_zero,
            not_false_iff, div_zero, MulZeroClass.zero_mul]
          simp only [Nat.cast_zero, truncation_zero, variance_zero, MulZeroClass.mul_zero]
        apply mul_le_mul_of_nonneg_right _ (variance_nonneg _ _)
        convert sum_div_nat_floor_pow_sq_le_div_sq N (Nat.cast_pos.2 hj) c_one
        · simp only [Nat.cast_lt]
        · simp only [one_div]
      _ = c ^ 5 * (c - 1)⁻¹ ^ 3 * ∑ j in range (u (N - 1)), ((j : ℝ) ^ 2)⁻¹ * Var[Y j] := by
        simp_rw [mul_sum, div_eq_mul_inv]; ring_nf
      _ ≤ c ^ 5 * (c - 1)⁻¹ ^ 3 * (2 * 𝔼[X 0]) :=
        by
        apply mul_le_mul_of_nonneg_left (I1 _)
        apply mul_nonneg (pow_nonneg c_pos.le _)
        exact pow_nonneg (inv_nonneg.2 (sub_nonneg.2 c_one.le)) _
  have I3 :
    ∀ N,
      ∑ i in range N, ℙ {ω | (u i * ε : ℝ) ≤ |S (u i) ω - 𝔼[S (u i)]|} ≤
        ENNReal.ofReal (ε⁻¹ ^ 2 * C) :=
    by
    intro N
    calc
      ∑ i in range N, ℙ {ω | (u i * ε : ℝ) ≤ |S (u i) ω - 𝔼[S (u i)]|} ≤
          ∑ i in range N, ENNReal.ofReal (Var[S (u i)] / (u i * ε) ^ 2) :=
        by
        refine' sum_le_sum fun i hi => _
        apply meas_ge_le_variance_div_sq
        ·
          exact
            mem_ℒp_finset_sum' _ fun j hj => (hident j).aestronglyMeasurable_fst.memℒp_truncation
        · apply mul_pos (Nat.cast_pos.2 _) εpos
          refine' zero_lt_one.trans_le _
          apply Nat.le_floor
          rw [Nat.cast_one]
          apply one_le_pow_of_one_le c_one.le
      _ = ENNReal.ofReal (∑ i in range N, Var[S (u i)] / (u i * ε) ^ 2) :=
        by
        rw [ENNReal.ofReal_sum_of_nonneg fun i hi => _]
        exact div_nonneg (variance_nonneg _ _) (sq_nonneg _)
      _ ≤ ENNReal.ofReal (ε⁻¹ ^ 2 * C) :=
        by
        apply ENNReal.ofReal_le_ofReal
        simp_rw [div_eq_inv_mul, ← inv_pow, mul_inv, mul_comm _ ε⁻¹, mul_pow, mul_assoc, ← mul_sum]
        refine' mul_le_mul_of_nonneg_left _ (sq_nonneg _)
        simp_rw [inv_pow]
        exact I2 N
  have I4 : ∑' i, ℙ {ω | (u i * ε : ℝ) ≤ |S (u i) ω - 𝔼[S (u i)]|} < ∞ :=
    (le_of_tendsto_of_tendsto' (ENNReal.tendsto_nat_tsum _) tendsto_const_nhds I3).trans_lt
      ENNReal.ofReal_lt_top
  filter_upwards [ae_eventually_not_mem I4.ne] with ω hω
  simp_rw [not_le, mul_comm, S, sum_apply] at hω 
  exact hω
#align probability_theory.strong_law_aux1 ProbabilityTheory.strong_law_aux1
-/

#print ProbabilityTheory.strong_law_aux2 /-
/- The truncation of `Xᵢ` up to `i` satisfies the strong law of large numbers
(with respect to the truncated expectation) along the sequence
`c^n`, for any `c > 1`. This follows from `strong_law_aux1` by varying `ε`. -/
theorem strong_law_aux2 {c : ℝ} (c_one : 1 < c) :
    ∀ᵐ ω,
      (fun n : ℕ =>
          ∑ i in range ⌊c ^ n⌋₊, truncation (X i) i ω -
            𝔼[∑ i in range ⌊c ^ n⌋₊, truncation (X i) i]) =o[atTop]
        fun n : ℕ => (⌊c ^ n⌋₊ : ℝ) :=
  by
  obtain ⟨v, -, v_pos, v_lim⟩ :
    ∃ v : ℕ → ℝ, StrictAnti v ∧ (∀ n : ℕ, 0 < v n) ∧ tendsto v at_top (𝓝 0) :=
    exists_seq_strictAnti_tendsto (0 : ℝ)
  have := fun i => strong_law_aux1 X hint hindep hident hnonneg c_one (v_pos i)
  filter_upwards [ae_all_iff.2 this] with ω hω
  apply Asymptotics.isLittleO_iff.2 fun ε εpos => _
  obtain ⟨i, hi⟩ : ∃ i, v i < ε := ((tendsto_order.1 v_lim).2 ε εpos).exists
  filter_upwards [hω i] with n hn
  simp only [Real.norm_eq_abs, LatticeOrderedCommGroup.abs_abs, Nat.abs_cast]
  exact hn.le.trans (mul_le_mul_of_nonneg_right hi.le (Nat.cast_nonneg _))
#align probability_theory.strong_law_aux2 ProbabilityTheory.strong_law_aux2
-/

#print ProbabilityTheory.strong_law_aux3 /-
/-- The expectation of the truncated version of `Xᵢ` behaves asymptotically like the whole
expectation. This follows from convergence and Cesaro averaging. -/
theorem strong_law_aux3 :
    (fun n => 𝔼[∑ i in range n, truncation (X i) i] - n * 𝔼[X 0]) =o[atTop] (coe : ℕ → ℝ) :=
  by
  have A : tendsto (fun i => 𝔼[truncation (X i) i]) at_top (𝓝 𝔼[X 0]) :=
    by
    convert (tendsto_integral_truncation hint).comp tendsto_nat_cast_atTop_atTop
    ext i
    exact (hident i).truncation.integral_eq
  convert Asymptotics.isLittleO_sum_range_of_tendsto_zero (tendsto_sub_nhds_zero_iff.2 A)
  ext1 n
  simp only [sum_sub_distrib, sum_const, card_range, nsmul_eq_mul, sum_apply, sub_left_inj]
  rw [integral_finset_sum _ fun i hi => _]
  exact ((hident i).symm.integrable_snd hint).1.integrable_truncation
#align probability_theory.strong_law_aux3 ProbabilityTheory.strong_law_aux3
-/

#print ProbabilityTheory.strong_law_aux4 /-
/- The truncation of `Xᵢ` up to `i` satisfies the strong law of large numbers
(with respect to the original expectation) along the sequence
`c^n`, for any `c > 1`. This follows from the version from the truncated expectation, and the
fact that the truncated and the original expectations have the same asymptotic behavior. -/
theorem strong_law_aux4 {c : ℝ} (c_one : 1 < c) :
    ∀ᵐ ω,
      (fun n : ℕ => ∑ i in range ⌊c ^ n⌋₊, truncation (X i) i ω - ⌊c ^ n⌋₊ * 𝔼[X 0]) =o[atTop]
        fun n : ℕ => (⌊c ^ n⌋₊ : ℝ) :=
  by
  filter_upwards [strong_law_aux2 X hint hindep hident hnonneg c_one] with ω hω
  have A : tendsto (fun n : ℕ => ⌊c ^ n⌋₊) at_top at_top :=
    tendsto_nat_floor_at_top.comp (tendsto_pow_atTop_atTop_of_one_lt c_one)
  convert hω.add ((strong_law_aux3 X hint hident).comp_tendsto A)
  ext1 n
  simp
#align probability_theory.strong_law_aux4 ProbabilityTheory.strong_law_aux4
-/

#print ProbabilityTheory.strong_law_aux5 /-
/-- The truncated and non-truncated versions of `Xᵢ` have the same asymptotic behavior, as they
almost surely coincide at all but finitely many steps. This follows from a probability computation
and Borel-Cantelli. -/
theorem strong_law_aux5 :
    ∀ᵐ ω,
      (fun n : ℕ => ∑ i in range n, truncation (X i) i ω - ∑ i in range n, X i ω) =o[atTop]
        fun n : ℕ => (n : ℝ) :=
  by
  have A : ∑' j : ℕ, ℙ {ω | X j ω ∈ Set.Ioi (j : ℝ)} < ∞ :=
    by
    convert tsum_prob_mem_Ioi_lt_top hint (hnonneg 0)
    ext1 j
    exact (hident j).measure_mem_eq measurableSet_Ioi
  have B : ∀ᵐ ω, tendsto (fun n : ℕ => truncation (X n) n ω - X n ω) at_top (𝓝 0) :=
    by
    filter_upwards [ae_eventually_not_mem A.ne] with ω hω
    apply tendsto_const_nhds.congr' _
    filter_upwards [hω, Ioi_mem_at_top 0] with n hn npos
    simp only [truncation, indicator, Set.mem_Ioc, id.def, Function.comp_apply]
    split_ifs
    · exact (sub_self _).symm
    · have : -(n : ℝ) < X n ω := by
        apply lt_of_lt_of_le _ (hnonneg n ω)
        simpa only [Right.neg_neg_iff, Nat.cast_pos] using npos
      simp only [this, true_and_iff, not_le] at h 
      exact (hn h).elim
  filter_upwards [B] with ω hω
  convert is_o_sum_range_of_tendsto_zero hω
  ext n
  rw [sum_sub_distrib]
#align probability_theory.strong_law_aux5 ProbabilityTheory.strong_law_aux5
-/

#print ProbabilityTheory.strong_law_aux6 /-
/- `Xᵢ` satisfies the strong law of large numbers along the sequence
`c^n`, for any `c > 1`. This follows from the version for the truncated `Xᵢ`, and the fact that
`Xᵢ` and its truncated version have the same asymptotic behavior. -/
theorem strong_law_aux6 {c : ℝ} (c_one : 1 < c) :
    ∀ᵐ ω, Tendsto (fun n : ℕ => (∑ i in range ⌊c ^ n⌋₊, X i ω) / ⌊c ^ n⌋₊) atTop (𝓝 𝔼[X 0]) :=
  by
  have H : ∀ n : ℕ, (0 : ℝ) < ⌊c ^ n⌋₊ := by
    intro n
    refine' zero_lt_one.trans_le _
    simp only [Nat.one_le_cast, Nat.one_le_floor_iff, one_le_pow_of_one_le c_one.le n]
  filter_upwards [strong_law_aux4 X hint hindep hident hnonneg c_one,
    strong_law_aux5 X hint hident hnonneg] with ω hω h'ω
  rw [← tendsto_sub_nhds_zero_iff, ← Asymptotics.isLittleO_one_iff ℝ]
  have L :
    (fun n : ℕ => ∑ i in range ⌊c ^ n⌋₊, X i ω - ⌊c ^ n⌋₊ * 𝔼[X 0]) =o[at_top] fun n =>
      (⌊c ^ n⌋₊ : ℝ) :=
    by
    have A : tendsto (fun n : ℕ => ⌊c ^ n⌋₊) at_top at_top :=
      tendsto_nat_floor_at_top.comp (tendsto_pow_atTop_atTop_of_one_lt c_one)
    convert hω.sub (h'ω.comp_tendsto A)
    ext1 n
    simp only [sub_sub_sub_cancel_left]
  convert L.mul_is_O (is_O_refl (fun n : ℕ => (⌊c ^ n⌋₊ : ℝ)⁻¹) at_top) <;>
    · ext1 n
      field_simp [(H n).ne']
#align probability_theory.strong_law_aux6 ProbabilityTheory.strong_law_aux6
-/

#print ProbabilityTheory.strong_law_aux7 /-
/-- `Xᵢ` satisfies the strong law of large numbers along all integers. This follows from the
corresponding fact along the sequences `c^n`, and the fact that any integer can be sandwiched
between `c^n` and `c^(n+1)` with comparably small error if `c` is close enough to `1`
(which is formalized in `tendsto_div_of_monotone_of_tendsto_div_floor_pow`). -/
theorem strong_law_aux7 :
    ∀ᵐ ω, Tendsto (fun n : ℕ => (∑ i in range n, X i ω) / n) atTop (𝓝 𝔼[X 0]) :=
  by
  obtain ⟨c, -, cone, clim⟩ :
    ∃ c : ℕ → ℝ, StrictAnti c ∧ (∀ n : ℕ, 1 < c n) ∧ tendsto c at_top (𝓝 1) :=
    exists_seq_strictAnti_tendsto (1 : ℝ)
  have :
    ∀ k,
      ∀ᵐ ω,
        tendsto (fun n : ℕ => (∑ i in range ⌊c k ^ n⌋₊, X i ω) / ⌊c k ^ n⌋₊) at_top (𝓝 𝔼[X 0]) :=
    fun k => strong_law_aux6 X hint hindep hident hnonneg (cone k)
  filter_upwards [ae_all_iff.2 this] with ω hω
  apply tendsto_div_of_monotone_of_tendsto_div_floor_pow _ _ _ c cone clim _
  · intro m n hmn
    exact sum_le_sum_of_subset_of_nonneg (range_mono hmn) fun i hi h'i => hnonneg i ω
  · exact hω
#align probability_theory.strong_law_aux7 ProbabilityTheory.strong_law_aux7
-/

end StrongLawNonneg

#print ProbabilityTheory.strong_law_ae /-
/-- *Strong law of large numbers*, almost sure version: if `X n` is a sequence of independent
identically distributed integrable real-valued random variables, then `∑ i in range n, X i / n`
converges almost surely to `𝔼[X 0]`. We give here the strong version, due to Etemadi, that only
requires pairwise independence. -/
theorem strong_law_ae (X : ℕ → Ω → ℝ) (hint : Integrable (X 0))
    (hindep : Pairwise fun i j => IndepFun (X i) (X j)) (hident : ∀ i, IdentDistrib (X i) (X 0)) :
    ∀ᵐ ω, Tendsto (fun n : ℕ => (∑ i in range n, X i ω) / n) atTop (𝓝 𝔼[X 0]) :=
  by
  let pos : ℝ → ℝ := fun x => max x 0
  let neg : ℝ → ℝ := fun x => max (-x) 0
  have posm : Measurable Pos := measurable_id'.max measurable_const
  have negm : Measurable neg := measurable_id'.neg.max measurable_const
  have A :
    ∀ᵐ ω, tendsto (fun n : ℕ => (∑ i in range n, (Pos ∘ X i) ω) / n) at_top (𝓝 𝔼[Pos ∘ X 0]) :=
    strong_law_aux7 _ hint.pos_part (fun i j hij => (hindep hij).comp posm posm)
      (fun i => (hident i).comp posm) fun i ω => le_max_right _ _
  have B :
    ∀ᵐ ω, tendsto (fun n : ℕ => (∑ i in range n, (neg ∘ X i) ω) / n) at_top (𝓝 𝔼[neg ∘ X 0]) :=
    strong_law_aux7 _ hint.neg_part (fun i j hij => (hindep hij).comp negm negm)
      (fun i => (hident i).comp negm) fun i ω => le_max_right _ _
  filter_upwards [A, B] with ω hωpos hωneg
  convert hωpos.sub hωneg
  · simp only [← sub_div, ← sum_sub_distrib, max_zero_sub_max_neg_zero_eq_self]
  · simp only [← integral_sub hint.pos_part hint.neg_part, max_zero_sub_max_neg_zero_eq_self]
#align probability_theory.strong_law_ae ProbabilityTheory.strong_law_ae
-/

end StrongLawAe

section StrongLawLp

variable {Ω : Type _} [MeasureSpace Ω] [IsProbabilityMeasure (ℙ : Measure Ω)]

#print ProbabilityTheory.strong_law_Lp /-
/-- *Strong law of large numbers*, Lᵖ version: if `X n` is a sequence of independent
identically distributed real-valued random variables in Lᵖ, then `∑ i in range n, X i / n`
converges in Lᵖ to `𝔼[X 0]`. -/
theorem strong_law_Lp {p : ℝ≥0∞} (hp : 1 ≤ p) (hp' : p ≠ ∞) (X : ℕ → Ω → ℝ) (hℒp : Memℒp (X 0) p)
    (hindep : Pairwise fun i j => IndepFun (X i) (X j)) (hident : ∀ i, IdentDistrib (X i) (X 0)) :
    Tendsto (fun n => snorm (fun ω => (∑ i in range n, X i ω) / n - 𝔼[X 0]) p ℙ) atTop (𝓝 0) :=
  by
  have hmeas : ∀ i, ae_strongly_measurable (X i) ℙ := fun i =>
    (hident i).aestronglyMeasurable_iff.2 hℒp.1
  have hint : integrable (X 0) ℙ := hℒp.integrable hp
  have havg : ∀ n, ae_strongly_measurable (fun ω => (∑ i in range n, X i ω) / n) ℙ :=
    by
    intro n
    simp_rw [div_eq_mul_inv]
    exact ae_strongly_measurable.mul_const (ae_strongly_measurable_sum _ fun i _ => hmeas i) _
  refine'
    tendsto_Lp_of_tendsto_in_measure _ hp hp' havg (mem_ℒp_const _) _
      (tendsto_in_measure_of_tendsto_ae havg (strong_law_ae _ hint hindep hident))
  rw [(_ : (fun n ω => (∑ i in range n, X i ω) / ↑n) = fun n => (∑ i in range n, X i) / ↑n)]
  ·
    exact
      (uniform_integrable_average hp <|
            mem_ℒp.uniform_integrable_of_ident_distrib hp hp' hℒp hident).2.1
  · ext n ω
    simp only [Pi.coe_nat, Pi.div_apply, sum_apply]
#align probability_theory.strong_law_Lp ProbabilityTheory.strong_law_Lp
-/

end StrongLawLp

end ProbabilityTheory

