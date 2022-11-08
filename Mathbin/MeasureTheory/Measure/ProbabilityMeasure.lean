/-
Copyright (c) 2021 Kalle Kytölä. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kalle Kytölä
-/
import Mathbin.MeasureTheory.Measure.FiniteMeasure
import Mathbin.MeasureTheory.Integral.Average

/-!
# Probability measures

This file defines the type of probability measures on a given measurable space. When the underlying
space has a topology and the measurable space structure (sigma algebra) is finer than the Borel
sigma algebra, then the type of probability measures is equipped with the topology of convergence
in distribution (weak convergence of measures). The topology of convergence in distribution is the
coarsest topology w.r.t. which for every bounded continuous `ℝ≥0`-valued random variable `X`, the
expected value of `X` depends continuously on the choice of probability measure. This is a special
case of the topology of weak convergence of finite measures.

## Main definitions

The main definitions are
 * the type `measure_theory.probability_measure Ω` with the topology of convergence in
   distribution (a.k.a. convergence in law, weak convergence of measures);
 * `measure_theory.probability_measure.to_finite_measure`: Interpret a probability measure as
   a finite measure;
 * `measure_theory.finite_measure.normalize`: Normalize a finite measure to a probability measure
   (returns junk for the zero measure).

## Main results

 * `measure_theory.probability_measure.tendsto_iff_forall_integral_tendsto`: Convergence of
   probability measures is characterized by the convergence of expected values of all bounded
   continuous random variables. This shows that the chosen definition of topology coincides with
   the common textbook definition of convergence in distribution, i.e., weak convergence of
   measures. A similar characterization by the convergence of expected values (in the
   `measure_theory.lintegral` sense) of all bounded continuous nonnegative random variables is
   `measure_theory.probability_measure.tendsto_iff_forall_lintegral_tendsto`.
 * `measure_theory.finite_measure.tendsto_normalize_iff_tendsto`: The convergence of finite
   measures to a nonzero limit is characterized by the convergence of the probability-normalized
   versions and of the total masses.

TODO:
 * Probability measures form a convex space.

## Implementation notes

The topology of convergence in distribution on `measure_theory.probability_measure Ω` is inherited
weak convergence of finite measures via the mapping
`measure_theory.probability_measure.to_finite_measure`.

Like `measure_theory.finite_measure Ω`, the implementation of `measure_theory.probability_measure Ω`
is directly as a subtype of `measure_theory.measure Ω`, and the coercion to a function is the
composition `ennreal.to_nnreal` and the coercion to function of `measure_theory.measure Ω`.

## References

* [Billingsley, *Convergence of probability measures*][billingsley1999]

## Tags

convergence in distribution, convergence in law, weak convergence of measures, probability measure

-/


noncomputable section

open MeasureTheory

open Set

open Filter

open BoundedContinuousFunction

open TopologicalSpace Ennreal Nnreal BoundedContinuousFunction

namespace MeasureTheory

section ProbabilityMeasure

/-! ### Probability measures

In this section we define the type of probability measures on a measurable space `Ω`, denoted by
`measure_theory.probability_measure Ω`.

If `Ω` is moreover a topological space and the sigma algebra on `Ω` is finer than the Borel sigma
algebra (i.e. `[opens_measurable_space Ω]`), then `measure_theory.probability_measure Ω` is
equipped with the topology of weak convergence of measures. Since every probability measure is a
finite measure, this is implemented as the induced topology from the mapping
`measure_theory.probability_measure.to_finite_measure`.
-/


/-- Probability measures are defined as the subtype of measures that have the property of being
probability measures (i.e., their total mass is one). -/
def ProbabilityMeasure (Ω : Type _) [MeasurableSpace Ω] : Type _ :=
  { μ : Measure Ω // IsProbabilityMeasure μ }

namespace ProbabilityMeasure

variable {Ω : Type _} [MeasurableSpace Ω]

instance [Inhabited Ω] : Inhabited (ProbabilityMeasure Ω) :=
  ⟨⟨Measure.dirac default, Measure.dirac.isProbabilityMeasure⟩⟩

/-- A probability measure can be interpreted as a measure. -/
instance : Coe (ProbabilityMeasure Ω) (MeasureTheory.Measure Ω) :=
  coeSubtype

instance : CoeFun (ProbabilityMeasure Ω) fun _ => Set Ω → ℝ≥0 :=
  ⟨fun μ s => (μ s).toNnreal⟩

instance (μ : ProbabilityMeasure Ω) : IsProbabilityMeasure (μ : Measure Ω) :=
  μ.Prop

theorem coe_fn_eq_to_nnreal_coe_fn_to_measure (ν : ProbabilityMeasure Ω) :
    (ν : Set Ω → ℝ≥0) = fun s => ((ν : Measure Ω) s).toNnreal :=
  rfl

@[simp]
theorem val_eq_to_measure (ν : ProbabilityMeasure Ω) : ν.val = (ν : Measure Ω) :=
  rfl

theorem coe_injective : Function.Injective (coe : ProbabilityMeasure Ω → Measure Ω) :=
  Subtype.coe_injective

@[simp]
theorem coe_fn_univ (ν : ProbabilityMeasure Ω) : ν Univ = 1 :=
  congr_arg Ennreal.toNnreal ν.Prop.measure_univ

/-- A probability measure can be interpreted as a finite measure. -/
def toFiniteMeasure (μ : ProbabilityMeasure Ω) : FiniteMeasure Ω :=
  ⟨μ, inferInstance⟩

@[simp]
theorem coe_comp_to_finite_measure_eq_coe (ν : ProbabilityMeasure Ω) :
    (ν.toFiniteMeasure : Measure Ω) = (ν : Measure Ω) :=
  rfl

@[simp]
theorem coe_fn_comp_to_finite_measure_eq_coe_fn (ν : ProbabilityMeasure Ω) :
    (ν.toFiniteMeasure : Set Ω → ℝ≥0) = (ν : Set Ω → ℝ≥0) :=
  rfl

@[simp]
theorem ennreal_coe_fn_eq_coe_fn_to_measure (ν : ProbabilityMeasure Ω) (s : Set Ω) : (ν s : ℝ≥0∞) = (ν : Measure Ω) s :=
  by
  rw [← coe_fn_comp_to_finite_measure_eq_coe_fn, finite_measure.ennreal_coe_fn_eq_coe_fn_to_measure,
    coe_comp_to_finite_measure_eq_coe]

@[ext]
theorem extensionality (μ ν : ProbabilityMeasure Ω) (h : ∀ s : Set Ω, MeasurableSet s → μ s = ν s) : μ = ν := by
  ext1
  ext1 s s_mble
  simpa [ennreal_coe_fn_eq_coe_fn_to_measure] using congr_arg (coe : ℝ≥0 → ℝ≥0∞) (h s s_mble)

@[simp]
theorem mass_to_finite_measure (μ : ProbabilityMeasure Ω) : μ.toFiniteMeasure.mass = 1 :=
  μ.coe_fn_univ

theorem to_finite_measure_nonzero (μ : ProbabilityMeasure Ω) : μ.toFiniteMeasure ≠ 0 := by
  intro maybe_zero
  have mass_zero := (finite_measure.mass_zero_iff _).mpr maybe_zero
  rw [μ.mass_to_finite_measure] at mass_zero
  exact one_ne_zero mass_zero

variable [TopologicalSpace Ω] [OpensMeasurableSpace Ω]

theorem testAgainstNnLipschitz (μ : ProbabilityMeasure Ω) :
    LipschitzWith 1 fun f : Ω →ᵇ ℝ≥0 => μ.toFiniteMeasure.testAgainstNn f :=
  μ.mass_to_finite_measure ▸ μ.toFiniteMeasure.testAgainstNnLipschitz

/-- The topology of weak convergence on `measure_theory.probability_measure Ω`. This is inherited
(induced) from the topology of weak convergence of finite measures via the inclusion
`measure_theory.probability_measure.to_finite_measure`. -/
instance : TopologicalSpace (ProbabilityMeasure Ω) :=
  TopologicalSpace.induced toFiniteMeasure inferInstance

theorem to_finite_measure_continuous : Continuous (toFiniteMeasure : ProbabilityMeasure Ω → FiniteMeasure Ω) :=
  continuous_induced_dom

/-- Probability measures yield elements of the `weak_dual` of bounded continuous nonnegative
functions via `measure_theory.finite_measure.test_against_nn`, i.e., integration. -/
def toWeakDualBcnn : ProbabilityMeasure Ω → WeakDual ℝ≥0 (Ω →ᵇ ℝ≥0) :=
  finite_measure.to_weak_dual_bcnn ∘ to_finite_measure

@[simp]
theorem coe_to_weak_dual_bcnn (μ : ProbabilityMeasure Ω) : ⇑μ.toWeakDualBcnn = μ.toFiniteMeasure.testAgainstNn :=
  rfl

@[simp]
theorem to_weak_dual_bcnn_apply (μ : ProbabilityMeasure Ω) (f : Ω →ᵇ ℝ≥0) :
    μ.toWeakDualBcnn f = (∫⁻ ω, f ω ∂(μ : Measure Ω)).toNnreal :=
  rfl

theorem to_weak_dual_bcnn_continuous : Continuous fun μ : ProbabilityMeasure Ω => μ.toWeakDualBcnn :=
  FiniteMeasure.to_weak_dual_bcnn_continuous.comp to_finite_measure_continuous

/- Integration of (nonnegative bounded continuous) test functions against Borel probability
measures depends continuously on the measure. -/
theorem continuous_test_against_nn_eval (f : Ω →ᵇ ℝ≥0) :
    Continuous fun μ : ProbabilityMeasure Ω => μ.toFiniteMeasure.testAgainstNn f :=
  (FiniteMeasure.continuous_test_against_nn_eval f).comp to_finite_measure_continuous

-- The canonical mapping from probability measures to finite measures is an embedding.
theorem to_finite_measure_embedding (Ω : Type _) [MeasurableSpace Ω] [TopologicalSpace Ω] [OpensMeasurableSpace Ω] :
    Embedding (toFiniteMeasure : ProbabilityMeasure Ω → FiniteMeasure Ω) :=
  { induced := rfl, inj := fun μ ν h => Subtype.eq (by convert congr_arg coe h) }

theorem tendsto_nhds_iff_to_finite_measures_tendsto_nhds {δ : Type _} (F : Filter δ) {μs : δ → ProbabilityMeasure Ω}
    {μ₀ : ProbabilityMeasure Ω} : Tendsto μs F (𝓝 μ₀) ↔ Tendsto (to_finite_measure ∘ μs) F (𝓝 μ₀.toFiniteMeasure) :=
  Embedding.tendsto_nhds_iff (to_finite_measure_embedding Ω)

/-- A characterization of weak convergence of probability measures by the condition that the
integrals of every continuous bounded nonnegative function converge to the integral of the function
against the limit measure. -/
theorem tendsto_iff_forall_lintegral_tendsto {γ : Type _} {F : Filter γ} {μs : γ → ProbabilityMeasure Ω}
    {μ : ProbabilityMeasure Ω} :
    Tendsto μs F (𝓝 μ) ↔
      ∀ f : Ω →ᵇ ℝ≥0, Tendsto (fun i => ∫⁻ ω, f ω ∂(μs i : Measure Ω)) F (𝓝 (∫⁻ ω, f ω ∂(μ : Measure Ω))) :=
  by
  rw [tendsto_nhds_iff_to_finite_measures_tendsto_nhds]
  exact finite_measure.tendsto_iff_forall_lintegral_tendsto

/-- The characterization of weak convergence of probability measures by the usual (defining)
condition that the integrals of every continuous bounded function converge to the integral of the
function against the limit measure. -/
theorem tendsto_iff_forall_integral_tendsto {γ : Type _} {F : Filter γ} {μs : γ → ProbabilityMeasure Ω}
    {μ : ProbabilityMeasure Ω} :
    Tendsto μs F (𝓝 μ) ↔
      ∀ f : Ω →ᵇ ℝ, Tendsto (fun i => ∫ ω, f ω ∂(μs i : Measure Ω)) F (𝓝 (∫ ω, f ω ∂(μ : Measure Ω))) :=
  by
  rw [tendsto_nhds_iff_to_finite_measures_tendsto_nhds]
  rw [finite_measure.tendsto_iff_forall_integral_tendsto]
  simp only [coe_comp_to_finite_measure_eq_coe]

end ProbabilityMeasure

-- namespace
end ProbabilityMeasure

-- section
section NormalizeFiniteMeasure

/-! ### Normalization of finite measures to probability measures

This section is about normalizing finite measures to probability measures.

The weak convergence of finite measures to nonzero limit measures is characterized by
the convergence of the total mass and the convergence of the normalized probability
measures.
-/


namespace FiniteMeasure

variable {Ω : Type _} [Nonempty Ω] {m0 : MeasurableSpace Ω} (μ : FiniteMeasure Ω)

/-- Normalize a finite measure so that it becomes a probability measure, i.e., divide by the
total mass. -/
def normalize : ProbabilityMeasure Ω :=
  if zero : μ.mass = 0 then ⟨Measure.dirac ‹Nonempty Ω›.some, Measure.dirac.isProbabilityMeasure⟩
  else
    { val := μ.mass⁻¹ • μ,
      property := by
        refine' ⟨_⟩
        simp only [mass, measure.coe_nnreal_smul_apply, ← ennreal_coe_fn_eq_coe_fn_to_measure μ univ]
        norm_cast
        exact inv_mul_cancel zero }

@[simp]
theorem self_eq_mass_mul_normalize (s : Set Ω) : μ s = μ.mass * μ.normalize s := by
  by_cases μ = 0
  · rw [h]
    simp only [zero.mass, coe_fn_zero, Pi.zero_apply, zero_mul]
    
  have mass_nonzero : μ.mass ≠ 0 := by rwa [μ.mass_nonzero_iff]
  simp only [show μ ≠ 0 from h, mass_nonzero, normalize, not_false_iff, dif_neg]
  change μ s = μ.mass * (μ.mass⁻¹ • μ) s
  rw [coe_fn_smul_apply]
  simp only [mass_nonzero, Algebra.id.smul_eq_mul, mul_inv_cancel_left₀, Ne.def, not_false_iff]

theorem self_eq_mass_smul_normalize : μ = μ.mass • μ.normalize.toFiniteMeasure := by
  ext (s s_mble)
  rw [μ.self_eq_mass_mul_normalize s, coe_fn_smul_apply]
  rfl

theorem normalize_eq_of_nonzero (nonzero : μ ≠ 0) (s : Set Ω) : μ.normalize s = μ.mass⁻¹ * μ s := by
  simp only [μ.self_eq_mass_mul_normalize, μ.mass_nonzero_iff.mpr nonzero, inv_mul_cancel_left₀, Ne.def, not_false_iff]

theorem normalize_eq_inv_mass_smul_of_nonzero (nonzero : μ ≠ 0) : μ.normalize.toFiniteMeasure = μ.mass⁻¹ • μ := by
  nth_rw 2 [μ.self_eq_mass_smul_normalize]
  rw [← smul_assoc]
  simp only [μ.mass_nonzero_iff.mpr nonzero, Algebra.id.smul_eq_mul, inv_mul_cancel, Ne.def, not_false_iff, one_smul]

theorem coe_normalize_eq_of_nonzero (nonzero : μ ≠ 0) : (μ.normalize : Measure Ω) = μ.mass⁻¹ • μ := by
  ext1 s s_mble
  simp only [← μ.normalize.ennreal_coe_fn_eq_coe_fn_to_measure s, μ.normalize_eq_of_nonzero nonzero s, Ennreal.coe_mul,
    ennreal_coe_fn_eq_coe_fn_to_measure, measure.coe_nnreal_smul_apply]

@[simp]
theorem _root_.probability_measure.to_finite_measure_normalize_eq_self {m0 : MeasurableSpace Ω}
    (μ : ProbabilityMeasure Ω) : μ.toFiniteMeasure.normalize = μ := by
  ext (s s_mble)
  rw [μ.to_finite_measure.normalize_eq_of_nonzero μ.to_finite_measure_nonzero s]
  simp only [probability_measure.mass_to_finite_measure, inv_one, one_mul]
  rfl

/-- Averaging with respect to a finite measure is the same as integraing against
`measure_theory.finite_measure.normalize`. -/
theorem average_eq_integral_normalize {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    (nonzero : μ ≠ 0) (f : Ω → E) : average (μ : Measure Ω) f = ∫ ω, f ω ∂(μ.normalize : Measure Ω) := by
  rw [μ.coe_normalize_eq_of_nonzero nonzero, average]
  congr
  simp only [RingHom.to_fun_eq_coe, Ennreal.coe_of_nnreal_hom, Ennreal.coe_inv (μ.mass_nonzero_iff.mpr nonzero),
    ennreal_mass]

variable [TopologicalSpace Ω]

theorem test_against_nn_eq_mass_mul (f : Ω →ᵇ ℝ≥0) :
    μ.testAgainstNn f = μ.mass * μ.normalize.toFiniteMeasure.testAgainstNn f := by
  nth_rw 0 [μ.self_eq_mass_smul_normalize]
  rw [μ.normalize.to_finite_measure.smul_test_against_nn_apply μ.mass f]
  rfl

theorem normalize_test_against_nn (nonzero : μ ≠ 0) (f : Ω →ᵇ ℝ≥0) :
    μ.normalize.toFiniteMeasure.testAgainstNn f = μ.mass⁻¹ * μ.testAgainstNn f := by
  simp [μ.test_against_nn_eq_mass_mul, μ.mass_nonzero_iff.mpr nonzero]

variable [OpensMeasurableSpace Ω]

variable {μ}

theorem tendsto_test_against_nn_of_tendsto_normalize_test_against_nn_of_tendsto_mass {γ : Type _} {F : Filter γ}
    {μs : γ → FiniteMeasure Ω} (μs_lim : Tendsto (fun i => (μs i).normalize) F (𝓝 μ.normalize))
    (mass_lim : Tendsto (fun i => (μs i).mass) F (𝓝 μ.mass)) (f : Ω →ᵇ ℝ≥0) :
    Tendsto (fun i => (μs i).testAgainstNn f) F (𝓝 (μ.testAgainstNn f)) := by
  by_cases h_mass:μ.mass = 0
  · simp only [μ.mass_zero_iff.mp h_mass, zero.test_against_nn_apply, zero.mass, eq_self_iff_true] at *
    exact tendsto_zero_test_against_nn_of_tendsto_zero_mass mass_lim f
    
  simp_rw [fun i => (μs i).test_against_nn_eq_mass_mul f, μ.test_against_nn_eq_mass_mul f]
  rw [probability_measure.tendsto_nhds_iff_to_finite_measures_tendsto_nhds] at μs_lim
  rw [tendsto_iff_forall_test_against_nn_tendsto] at μs_lim
  have lim_pair :
    tendsto (fun i => (⟨(μs i).mass, (μs i).normalize.toFiniteMeasure.testAgainstNn f⟩ : ℝ≥0 × ℝ≥0)) F
      (𝓝 ⟨μ.mass, μ.normalize.to_finite_measure.test_against_nn f⟩) :=
    (Prod.tendsto_iff _ _).mpr ⟨mass_lim, μs_lim f⟩
  exact tendsto_mul.comp lim_pair

theorem tendsto_normalize_test_against_nn_of_tendsto {γ : Type _} {F : Filter γ} {μs : γ → FiniteMeasure Ω}
    (μs_lim : Tendsto μs F (𝓝 μ)) (nonzero : μ ≠ 0) (f : Ω →ᵇ ℝ≥0) :
    Tendsto (fun i => (μs i).normalize.toFiniteMeasure.testAgainstNn f) F
      (𝓝 (μ.normalize.toFiniteMeasure.testAgainstNn f)) :=
  by
  have lim_mass := μs_lim.mass
  have aux : {(0 : ℝ≥0)}ᶜ ∈ 𝓝 μ.mass := is_open_compl_singleton.mem_nhds (μ.mass_nonzero_iff.mpr nonzero)
  have eventually_nonzero : ∀ᶠ i in F, μs i ≠ 0 := by
    simp_rw [← mass_nonzero_iff]
    exact lim_mass aux
  have eve : ∀ᶠ i in F, (μs i).normalize.toFiniteMeasure.testAgainstNn f = (μs i).mass⁻¹ * (μs i).testAgainstNn f := by
    filter_upwards [eventually_iff.mp eventually_nonzero]
    intro i hi
    apply normalize_test_against_nn _ hi
  simp_rw [tendsto_congr' eve, μ.normalize_test_against_nn nonzero]
  have lim_pair :
    tendsto (fun i => (⟨(μs i).mass⁻¹, (μs i).testAgainstNn f⟩ : ℝ≥0 × ℝ≥0)) F (𝓝 ⟨μ.mass⁻¹, μ.test_against_nn f⟩) := by
    refine' (Prod.tendsto_iff _ _).mpr ⟨_, _⟩
    · exact (continuous_on_inv₀.continuous_at aux).Tendsto.comp lim_mass
      
    · exact tendsto_iff_forall_test_against_nn_tendsto.mp μs_lim f
      
  exact tendsto_mul.comp lim_pair

/-- If the normalized versions of finite measures converge weakly and their total masses
also converge, then the finite measures themselves converge weakly. -/
theorem tendsto_of_tendsto_normalize_test_against_nn_of_tendsto_mass {γ : Type _} {F : Filter γ}
    {μs : γ → FiniteMeasure Ω} (μs_lim : Tendsto (fun i => (μs i).normalize) F (𝓝 μ.normalize))
    (mass_lim : Tendsto (fun i => (μs i).mass) F (𝓝 μ.mass)) : Tendsto μs F (𝓝 μ) := by
  rw [tendsto_iff_forall_test_against_nn_tendsto]
  exact fun f => tendsto_test_against_nn_of_tendsto_normalize_test_against_nn_of_tendsto_mass μs_lim mass_lim f

/-- If finite measures themselves converge weakly to a nonzero limit measure, then their
normalized versions also converge weakly. -/
theorem tendsto_normalize_of_tendsto {γ : Type _} {F : Filter γ} {μs : γ → FiniteMeasure Ω}
    (μs_lim : Tendsto μs F (𝓝 μ)) (nonzero : μ ≠ 0) : Tendsto (fun i => (μs i).normalize) F (𝓝 μ.normalize) := by
  rw [probability_measure.tendsto_nhds_iff_to_finite_measures_tendsto_nhds, tendsto_iff_forall_test_against_nn_tendsto]
  exact fun f => tendsto_normalize_test_against_nn_of_tendsto μs_lim nonzero f

/-- The weak convergence of finite measures to a nonzero limit can be characterized by the weak
convergence of both their normalized versions (probability measures) and their total masses. -/
theorem tendsto_normalize_iff_tendsto {γ : Type _} {F : Filter γ} {μs : γ → FiniteMeasure Ω} (nonzero : μ ≠ 0) :
    Tendsto (fun i => (μs i).normalize) F (𝓝 μ.normalize) ∧ Tendsto (fun i => (μs i).mass) F (𝓝 μ.mass) ↔
      Tendsto μs F (𝓝 μ) :=
  by
  constructor
  · rintro ⟨normalized_lim, mass_lim⟩
    exact tendsto_of_tendsto_normalize_test_against_nn_of_tendsto_mass normalized_lim mass_lim
    
  · intro μs_lim
    refine' ⟨tendsto_normalize_of_tendsto μs_lim nonzero, μs_lim.mass⟩
    

end FiniteMeasure

--namespace
end NormalizeFiniteMeasure

-- section
end MeasureTheory

