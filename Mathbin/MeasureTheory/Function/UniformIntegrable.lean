/-
Copyright (c) 2022 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying

! This file was ported from Lean 3 source module measure_theory.function.uniform_integrable
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Function.ConvergenceInMeasure
import Mathbin.MeasureTheory.Function.L1Space

/-!
# Uniform integrability

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains the definitions for uniform integrability (both in the measure theory sense
as well as the probability theory sense). This file also contains the Vitali convergence theorem
which estabishes a relation between uniform integrability, convergence in measure and
Lp convergence.

Uniform integrability plays a vital role in the theory of martingales most notably is used to
fomulate the martingale convergence theorem.

## Main definitions

* `measure_theory.unif_integrable`: uniform integrability in the measure theory sense.
  In particular, a sequence of functions `f` is uniformly integrable if for all `ε > 0`, there
  exists some `δ > 0` such that for all sets `s` of smaller measure than `δ`, the Lp-norm of
  `f i` restricted `s` is smaller than `ε` for all `i`.
* `measure_theory.uniform_integrable`: uniform integrability in the probability theory sense.
  In particular, a sequence of measurable functions `f` is uniformly integrable in the
  probability theory sense if it is uniformly integrable in the measure theory sense and
  has uniformly bounded Lp-norm.

# Main results

* `measure_theory.unif_integrable_fintype`: a finite sequence of Lp functions is uniformly
  integrable.
* `measure_theory.tendsto_Lp_of_tendsto_ae`: a sequence of Lp functions which is uniformly
  integrable converges in Lp if they converge almost everywhere.
* `measure_theory.tendsto_in_measure_iff_tendsto_Lp`: Vitali convergence theorem:
  a sequence of Lp functions converges in Lp if and only if it is uniformly integrable
  and converges in measure.

## Tags
uniform integrable, uniformly absolutely continuous integral, Vitali convergence theorem
-/


noncomputable section

open scoped Classical MeasureTheory NNReal ENNReal Topology BigOperators

namespace MeasureTheory

open Set Filter TopologicalSpace

variable {α β ι : Type _} {m : MeasurableSpace α} {μ : Measure α} [NormedAddCommGroup β]

#print MeasureTheory.UnifIntegrable /-
/-- Uniform integrability in the measure theory sense.

A sequence of functions `f` is said to be uniformly integrable if for all `ε > 0`, there exists
some `δ > 0` such that for all sets `s` with measure less than `δ`, the Lp-norm of `f i`
restricted on `s` is less than `ε`.

Uniform integrablility is also known as uniformly absolutely continuous integrals. -/
def UnifIntegrable {m : MeasurableSpace α} (f : ι → α → β) (p : ℝ≥0∞) (μ : Measure α) : Prop :=
  ∀ ⦃ε : ℝ⦄ (hε : 0 < ε),
    ∃ (δ : ℝ) (hδ : 0 < δ),
      ∀ i s,
        MeasurableSet s → μ s ≤ ENNReal.ofReal δ → snorm (s.indicator (f i)) p μ ≤ ENNReal.ofReal ε
#align measure_theory.unif_integrable MeasureTheory.UnifIntegrable
-/

#print MeasureTheory.UniformIntegrable /-
/-- In probability theory, a family of measurable functions is uniformly integrable if it is
uniformly integrable in the measure theory sense and is uniformly bounded. -/
def UniformIntegrable {m : MeasurableSpace α} (f : ι → α → β) (p : ℝ≥0∞) (μ : Measure α) : Prop :=
  (∀ i, AEStronglyMeasurable (f i) μ) ∧ UnifIntegrable f p μ ∧ ∃ C : ℝ≥0, ∀ i, snorm (f i) p μ ≤ C
#align measure_theory.uniform_integrable MeasureTheory.UniformIntegrable
-/

namespace UniformIntegrable

#print MeasureTheory.UniformIntegrable.aeStronglyMeasurable /-
protected theorem aeStronglyMeasurable {f : ι → α → β} {p : ℝ≥0∞} (hf : UniformIntegrable f p μ)
    (i : ι) : AEStronglyMeasurable (f i) μ :=
  hf.1 i
#align measure_theory.uniform_integrable.ae_strongly_measurable MeasureTheory.UniformIntegrable.aeStronglyMeasurable
-/

#print MeasureTheory.UniformIntegrable.unifIntegrable /-
protected theorem unifIntegrable {f : ι → α → β} {p : ℝ≥0∞} (hf : UniformIntegrable f p μ) :
    UnifIntegrable f p μ :=
  hf.2.1
#align measure_theory.uniform_integrable.unif_integrable MeasureTheory.UniformIntegrable.unifIntegrable
-/

#print MeasureTheory.UniformIntegrable.memℒp /-
protected theorem memℒp {f : ι → α → β} {p : ℝ≥0∞} (hf : UniformIntegrable f p μ) (i : ι) :
    Memℒp (f i) p μ :=
  ⟨hf.1 i,
    let ⟨_, _, hC⟩ := hf.2
    lt_of_le_of_lt (hC i) ENNReal.coe_lt_top⟩
#align measure_theory.uniform_integrable.mem_ℒp MeasureTheory.UniformIntegrable.memℒp
-/

end UniformIntegrable

section UnifIntegrable

/-! ### `unif_integrable`

This section deals with uniform integrability in the measure theory sense. -/


namespace UnifIntegrable

variable {f g : ι → α → β} {p : ℝ≥0∞}

#print MeasureTheory.UnifIntegrable.add /-
protected theorem add (hf : UnifIntegrable f p μ) (hg : UnifIntegrable g p μ) (hp : 1 ≤ p)
    (hf_meas : ∀ i, AEStronglyMeasurable (f i) μ) (hg_meas : ∀ i, AEStronglyMeasurable (g i) μ) :
    UnifIntegrable (f + g) p μ := by
  intro ε hε
  have hε2 : 0 < ε / 2 := half_pos hε
  obtain ⟨δ₁, hδ₁_pos, hfδ₁⟩ := hf hε2
  obtain ⟨δ₂, hδ₂_pos, hgδ₂⟩ := hg hε2
  refine' ⟨min δ₁ δ₂, lt_min hδ₁_pos hδ₂_pos, fun i s hs hμs => _⟩
  simp_rw [Pi.add_apply, indicator_add']
  refine' (snorm_add_le ((hf_meas i).indicator hs) ((hg_meas i).indicator hs) hp).trans _
  have hε_halves : ENNReal.ofReal ε = ENNReal.ofReal (ε / 2) + ENNReal.ofReal (ε / 2) := by
    rw [← ENNReal.ofReal_add hε2.le hε2.le, add_halves]
  rw [hε_halves]
  exact
    add_le_add (hfδ₁ i s hs (hμs.trans (ENNReal.ofReal_le_ofReal (min_le_left _ _))))
      (hgδ₂ i s hs (hμs.trans (ENNReal.ofReal_le_ofReal (min_le_right _ _))))
#align measure_theory.unif_integrable.add MeasureTheory.UnifIntegrable.add
-/

#print MeasureTheory.UnifIntegrable.neg /-
protected theorem neg (hf : UnifIntegrable f p μ) : UnifIntegrable (-f) p μ := by
  simp_rw [unif_integrable, Pi.neg_apply, indicator_neg', snorm_neg]; exact hf
#align measure_theory.unif_integrable.neg MeasureTheory.UnifIntegrable.neg
-/

#print MeasureTheory.UnifIntegrable.sub /-
protected theorem sub (hf : UnifIntegrable f p μ) (hg : UnifIntegrable g p μ) (hp : 1 ≤ p)
    (hf_meas : ∀ i, AEStronglyMeasurable (f i) μ) (hg_meas : ∀ i, AEStronglyMeasurable (g i) μ) :
    UnifIntegrable (f - g) p μ := by rw [sub_eq_add_neg];
  exact hf.add hg.neg hp hf_meas fun i => (hg_meas i).neg
#align measure_theory.unif_integrable.sub MeasureTheory.UnifIntegrable.sub
-/

#print MeasureTheory.UnifIntegrable.ae_eq /-
protected theorem ae_eq (hf : UnifIntegrable f p μ) (hfg : ∀ n, f n =ᵐ[μ] g n) :
    UnifIntegrable g p μ := by
  intro ε hε
  obtain ⟨δ, hδ_pos, hfδ⟩ := hf hε
  refine' ⟨δ, hδ_pos, fun n s hs hμs => (le_of_eq <| snorm_congr_ae _).trans (hfδ n s hs hμs)⟩
  filter_upwards [hfg n] with x hx
  simp_rw [indicator_apply, hx]
#align measure_theory.unif_integrable.ae_eq MeasureTheory.UnifIntegrable.ae_eq
-/

end UnifIntegrable

#print MeasureTheory.unifIntegrable_zero_meas /-
theorem unifIntegrable_zero_meas [MeasurableSpace α] {p : ℝ≥0∞} {f : ι → α → β} :
    UnifIntegrable f p (0 : Measure α) := fun ε hε => ⟨1, one_pos, fun i s hs hμs => by simp⟩
#align measure_theory.unif_integrable_zero_meas MeasureTheory.unifIntegrable_zero_meas
-/

#print MeasureTheory.unifIntegrable_congr_ae /-
theorem unifIntegrable_congr_ae {p : ℝ≥0∞} {f g : ι → α → β} (hfg : ∀ n, f n =ᵐ[μ] g n) :
    UnifIntegrable f p μ ↔ UnifIntegrable g p μ :=
  ⟨fun hf => hf.ae_eq hfg, fun hg => hg.ae_eq fun n => (hfg n).symm⟩
#align measure_theory.unif_integrable_congr_ae MeasureTheory.unifIntegrable_congr_ae
-/

#print MeasureTheory.tendsto_indicator_ge /-
theorem tendsto_indicator_ge (f : α → β) (x : α) :
    Tendsto (fun M : ℕ => {x | (M : ℝ) ≤ ‖f x‖₊}.indicator f x) atTop (𝓝 0) :=
  by
  refine' @tendsto_atTop_of_eventually_const _ _ _ _ _ _ _ (Nat.ceil (‖f x‖₊ : ℝ) + 1) fun n hn => _
  rw [indicator_of_not_mem]
  simp only [not_le, mem_set_of_eq]
  refine' lt_of_le_of_lt (Nat.le_ceil _) _
  refine' lt_of_lt_of_le (lt_add_one _) _
  norm_cast
  rwa [ge_iff_le, coe_nnnorm] at hn 
#align measure_theory.tendsto_indicator_ge MeasureTheory.tendsto_indicator_ge
-/

variable (μ) {p : ℝ≥0∞}

section

variable {f : α → β}

#print MeasureTheory.Memℒp.integral_indicator_norm_ge_le /-
/-- This lemma is weaker than `measure_theory.mem_ℒp.integral_indicator_norm_ge_nonneg_le`
as the latter provides `0 ≤ M` and does not require the measurability of `f`. -/
theorem Memℒp.integral_indicator_norm_ge_le (hf : Memℒp f 1 μ) (hmeas : StronglyMeasurable f)
    {ε : ℝ} (hε : 0 < ε) : ∃ M : ℝ, ∫⁻ x, ‖{x | M ≤ ‖f x‖₊}.indicator f x‖₊ ∂μ ≤ ENNReal.ofReal ε :=
  by
  have htendsto :
    ∀ᵐ x ∂μ, tendsto (fun M : ℕ => {x | (M : ℝ) ≤ ‖f x‖₊}.indicator f x) at_top (𝓝 0) :=
    univ_mem' (id fun x => tendsto_indicator_ge f x)
  have hmeas : ∀ M : ℕ, ae_strongly_measurable ({x | (M : ℝ) ≤ ‖f x‖₊}.indicator f) μ :=
    by
    intro M
    apply hf.1.indicator
    apply
      strongly_measurable.measurable_set_le strongly_measurable_const
        hmeas.nnnorm.measurable.coe_nnreal_real.strongly_measurable
  have hbound : has_finite_integral (fun x => ‖f x‖) μ :=
    by
    rw [mem_ℒp_one_iff_integrable] at hf 
    exact hf.norm.2
  have := tendsto_lintegral_norm_of_dominated_convergence hmeas hbound _ htendsto
  · rw [ENNReal.tendsto_atTop_zero] at this 
    obtain ⟨M, hM⟩ := this (ENNReal.ofReal ε) (ENNReal.ofReal_pos.2 hε)
    simp only [true_and_iff, ge_iff_le, zero_tsub, zero_le, sub_zero, zero_add, coe_nnnorm,
      mem_Icc] at hM 
    refine' ⟨M, _⟩
    convert hM M le_rfl
    ext1 x
    simp only [coe_nnnorm, ENNReal.ofReal_eq_coe_nnreal (norm_nonneg _)]
    rfl
  · refine' fun n => univ_mem' (id fun x => _)
    by_cases hx : (n : ℝ) ≤ ‖f x‖
    · dsimp
      rwa [indicator_of_mem]
    · dsimp
      rw [indicator_of_not_mem, norm_zero]
      · exact norm_nonneg _
      · assumption
#align measure_theory.mem_ℒp.integral_indicator_norm_ge_le MeasureTheory.Memℒp.integral_indicator_norm_ge_le
-/

#print MeasureTheory.Memℒp.integral_indicator_norm_ge_nonneg_le_of_meas /-
/-- This lemma is superceded by `measure_theory.mem_ℒp.integral_indicator_norm_ge_nonneg_le`
which does not require measurability. -/
theorem Memℒp.integral_indicator_norm_ge_nonneg_le_of_meas (hf : Memℒp f 1 μ)
    (hmeas : StronglyMeasurable f) {ε : ℝ} (hε : 0 < ε) :
    ∃ M : ℝ, 0 ≤ M ∧ ∫⁻ x, ‖{x | M ≤ ‖f x‖₊}.indicator f x‖₊ ∂μ ≤ ENNReal.ofReal ε :=
  let ⟨M, hM⟩ := hf.integral_indicator_norm_ge_le μ hmeas hε
  ⟨max M 0, le_max_right _ _, by simpa⟩
#align measure_theory.mem_ℒp.integral_indicator_norm_ge_nonneg_le_of_meas MeasureTheory.Memℒp.integral_indicator_norm_ge_nonneg_le_of_meas
-/

#print MeasureTheory.Memℒp.integral_indicator_norm_ge_nonneg_le /-
theorem Memℒp.integral_indicator_norm_ge_nonneg_le (hf : Memℒp f 1 μ) {ε : ℝ} (hε : 0 < ε) :
    ∃ M : ℝ, 0 ≤ M ∧ ∫⁻ x, ‖{x | M ≤ ‖f x‖₊}.indicator f x‖₊ ∂μ ≤ ENNReal.ofReal ε :=
  by
  have hf_mk : mem_ℒp (hf.1.mk f) 1 μ := (mem_ℒp_congr_ae hf.1.ae_eq_mk).mp hf
  obtain ⟨M, hM_pos, hfM⟩ :=
    hf_mk.integral_indicator_norm_ge_nonneg_le_of_meas μ hf.1.stronglyMeasurable_mk hε
  refine' ⟨M, hM_pos, (le_of_eq _).trans hfM⟩
  refine' lintegral_congr_ae _
  filter_upwards [hf.1.ae_eq_mk] with x hx
  simp only [indicator_apply, coe_nnnorm, mem_set_of_eq, ENNReal.coe_eq_coe, hx.symm]
#align measure_theory.mem_ℒp.integral_indicator_norm_ge_nonneg_le MeasureTheory.Memℒp.integral_indicator_norm_ge_nonneg_le
-/

#print MeasureTheory.Memℒp.snormEssSup_indicator_norm_ge_eq_zero /-
theorem Memℒp.snormEssSup_indicator_norm_ge_eq_zero (hf : Memℒp f ∞ μ)
    (hmeas : StronglyMeasurable f) : ∃ M : ℝ, snormEssSup ({x | M ≤ ‖f x‖₊}.indicator f) μ = 0 :=
  by
  have hbdd : snorm_ess_sup f μ < ∞ := hf.snorm_lt_top
  refine' ⟨(snorm f ∞ μ + 1).toReal, _⟩
  rw [snorm_ess_sup_indicator_eq_snorm_ess_sup_restrict]
  have : μ.restrict {x : α | (snorm f ⊤ μ + 1).toReal ≤ ‖f x‖₊} = 0 :=
    by
    simp only [coe_nnnorm, snorm_exponent_top, measure.restrict_eq_zero]
    have :
      {x : α | (snorm_ess_sup f μ + 1).toReal ≤ ‖f x‖} ⊆ {x : α | snorm_ess_sup f μ < ‖f x‖₊} :=
      by
      intro x hx
      rw [mem_set_of_eq, ← ENNReal.toReal_lt_toReal hbdd.ne ennreal.coe_lt_top.ne,
        ENNReal.coe_toReal, coe_nnnorm]
      refine' lt_of_lt_of_le _ hx
      rw [ENNReal.toReal_lt_toReal hbdd.ne]
      · exact ENNReal.lt_add_right hbdd.ne one_ne_zero
      · exact (ENNReal.add_lt_top.2 ⟨hbdd, ENNReal.one_lt_top⟩).Ne
    rw [← nonpos_iff_eq_zero]
    refine' (measure_mono this).trans _
    have hle := coe_nnnorm_ae_le_snorm_ess_sup f μ
    simp_rw [ae_iff, not_le] at hle 
    exact nonpos_iff_eq_zero.2 hle
  rw [this, snorm_ess_sup_measure_zero]
  exact measurableSet_le measurable_const hmeas.nnnorm.measurable.subtype_coe
#align measure_theory.mem_ℒp.snorm_ess_sup_indicator_norm_ge_eq_zero MeasureTheory.Memℒp.snormEssSup_indicator_norm_ge_eq_zero
-/

#print MeasureTheory.Memℒp.snorm_indicator_norm_ge_le /-
/- This lemma is slightly weaker than `measure_theory.mem_ℒp.snorm_indicator_norm_ge_pos_le` as the
latter provides `0 < M`. -/
theorem Memℒp.snorm_indicator_norm_ge_le (hf : Memℒp f p μ) (hmeas : StronglyMeasurable f) {ε : ℝ}
    (hε : 0 < ε) : ∃ M : ℝ, snorm ({x | M ≤ ‖f x‖₊}.indicator f) p μ ≤ ENNReal.ofReal ε :=
  by
  by_cases hp_ne_zero : p = 0
  · refine' ⟨1, hp_ne_zero.symm ▸ _⟩
    simp [snorm_exponent_zero]
  by_cases hp_ne_top : p = ∞
  · subst hp_ne_top
    obtain ⟨M, hM⟩ := hf.snorm_ess_sup_indicator_norm_ge_eq_zero μ hmeas
    refine' ⟨M, _⟩
    simp only [snorm_exponent_top, hM, zero_le]
  obtain ⟨M, hM', hM⟩ :=
    @mem_ℒp.integral_indicator_norm_ge_nonneg_le _ _ _ μ _ (fun x => ‖f x‖ ^ p.to_real)
      (hf.norm_rpow hp_ne_zero hp_ne_top) _ (Real.rpow_pos_of_pos hε p.to_real)
  refine' ⟨M ^ (1 / p.to_real), _⟩
  rw [snorm_eq_lintegral_rpow_nnnorm hp_ne_zero hp_ne_top, ← ENNReal.rpow_one (ENNReal.ofReal ε)]
  conv_rhs => rw [← mul_one_div_cancel (ENNReal.toReal_pos hp_ne_zero hp_ne_top).Ne.symm]
  rw [ENNReal.rpow_mul,
    ENNReal.rpow_le_rpow_iff (one_div_pos.2 <| ENNReal.toReal_pos hp_ne_zero hp_ne_top),
    ENNReal.ofReal_rpow_of_pos hε]
  convert hM
  ext1 x
  rw [ENNReal.coe_rpow_of_nonneg _ ENNReal.toReal_nonneg, nnnorm_indicator_eq_indicator_nnnorm,
    nnnorm_indicator_eq_indicator_nnnorm]
  have hiff : M ^ (1 / p.to_real) ≤ ‖f x‖₊ ↔ M ≤ ‖‖f x‖ ^ p.to_real‖₊ := by
    rw [coe_nnnorm, coe_nnnorm, Real.norm_rpow_of_nonneg (norm_nonneg _), norm_norm, ←
      Real.rpow_le_rpow_iff hM' (Real.rpow_nonneg_of_nonneg (norm_nonneg _) _)
        (one_div_pos.2 <| ENNReal.toReal_pos hp_ne_zero hp_ne_top),
      ← Real.rpow_mul (norm_nonneg _),
      mul_one_div_cancel (ENNReal.toReal_pos hp_ne_zero hp_ne_top).Ne.symm, Real.rpow_one]
  by_cases hx : x ∈ {x : α | M ^ (1 / p.to_real) ≤ ‖f x‖₊}
  · rw [Set.indicator_of_mem hx, Set.indicator_of_mem, Real.nnnorm_of_nonneg]; rfl
    change _ ≤ _
    rwa [← hiff]
  · rw [Set.indicator_of_not_mem hx, Set.indicator_of_not_mem]
    · simp [(ENNReal.toReal_pos hp_ne_zero hp_ne_top).Ne.symm]
    · change ¬_ ≤ _
      rwa [← hiff]
#align measure_theory.mem_ℒp.snorm_indicator_norm_ge_le MeasureTheory.Memℒp.snorm_indicator_norm_ge_le
-/

#print MeasureTheory.Memℒp.snorm_indicator_norm_ge_pos_le /-
/-- This lemma implies that a single function is uniformly integrable (in the probability sense). -/
theorem Memℒp.snorm_indicator_norm_ge_pos_le (hf : Memℒp f p μ) (hmeas : StronglyMeasurable f)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ M : ℝ, 0 < M ∧ snorm ({x | M ≤ ‖f x‖₊}.indicator f) p μ ≤ ENNReal.ofReal ε :=
  by
  obtain ⟨M, hM⟩ := hf.snorm_indicator_norm_ge_le μ hmeas hε
  refine'
    ⟨max M 1, lt_of_lt_of_le zero_lt_one (le_max_right _ _), le_trans (snorm_mono fun x => _) hM⟩
  rw [norm_indicator_eq_indicator_norm, norm_indicator_eq_indicator_norm]
  refine' indicator_le_indicator_of_subset (fun x hx => _) (fun x => norm_nonneg _) x
  change max _ _ ≤ _ at hx 
  -- removing the `change` breaks the proof!
  exact (max_le_iff.1 hx).1
#align measure_theory.mem_ℒp.snorm_indicator_norm_ge_pos_le MeasureTheory.Memℒp.snorm_indicator_norm_ge_pos_le
-/

end

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:38: in filter_upwards #[[], [], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error @ arg 0: next failed, no more args -/
#print MeasureTheory.snorm_indicator_le_of_bound /-
theorem snorm_indicator_le_of_bound {f : α → β} (hp_top : p ≠ ∞) {ε : ℝ} (hε : 0 < ε) {M : ℝ}
    (hf : ∀ x, ‖f x‖ < M) :
    ∃ (δ : ℝ) (hδ : 0 < δ),
      ∀ s,
        MeasurableSet s → μ s ≤ ENNReal.ofReal δ → snorm (s.indicator f) p μ ≤ ENNReal.ofReal ε :=
  by
  by_cases hM : M ≤ 0
  · refine' ⟨1, zero_lt_one, fun s hs hμ => _⟩
    rw [(_ : f = 0)]
    · simp [hε.le]
    · ext x
      rw [Pi.zero_apply, ← norm_le_zero_iff]
      exact (lt_of_lt_of_le (hf x) hM).le
  rw [not_le] at hM 
  refine' ⟨(ε / M) ^ p.to_real, Real.rpow_pos_of_pos (div_pos hε hM) _, fun s hs hμ => _⟩
  by_cases hp : p = 0
  · simp [hp]
  rw [snorm_indicator_eq_snorm_restrict hs]
  have haebdd : ∀ᵐ x ∂μ.restrict s, ‖f x‖ ≤ M :=
    by
    trace
      "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:38: in filter_upwards #[[], [], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error @ arg 0: next failed, no more args"
    exact fun x => (hf x).le
  refine' le_trans (snorm_le_of_ae_bound haebdd) _
  rw [measure.restrict_apply MeasurableSet.univ, univ_inter, ←
    ENNReal.le_div_iff_mul_le (Or.inl _) (Or.inl ENNReal.ofReal_ne_top)]
  · rw [← one_div, ENNReal.rpow_one_div_le_iff (ENNReal.toReal_pos hp hp_top)]
    refine' le_trans hμ _
    rw [← ENNReal.ofReal_rpow_of_pos (div_pos hε hM),
      ENNReal.rpow_le_rpow_iff (ENNReal.toReal_pos hp hp_top), ENNReal.ofReal_div_of_pos hM]
    exact le_rfl
  · simpa only [ENNReal.ofReal_eq_zero, not_le, Ne.def]
#align measure_theory.snorm_indicator_le_of_bound MeasureTheory.snorm_indicator_le_of_bound
-/

section

variable {f : α → β}

#print MeasureTheory.Memℒp.snorm_indicator_le' /-
/-- Auxiliary lemma for `measure_theory.mem_ℒp.snorm_indicator_le`. -/
theorem Memℒp.snorm_indicator_le' (hp_one : 1 ≤ p) (hp_top : p ≠ ∞) (hf : Memℒp f p μ)
    (hmeas : StronglyMeasurable f) {ε : ℝ} (hε : 0 < ε) :
    ∃ (δ : ℝ) (hδ : 0 < δ),
      ∀ s,
        MeasurableSet s →
          μ s ≤ ENNReal.ofReal δ → snorm (s.indicator f) p μ ≤ 2 * ENNReal.ofReal ε :=
  by
  obtain ⟨M, hMpos, hM⟩ := hf.snorm_indicator_norm_ge_pos_le μ hmeas hε
  obtain ⟨δ, hδpos, hδ⟩ :=
    @snorm_indicator_le_of_bound _ _ _ μ _ _ ({x | ‖f x‖ < M}.indicator f) hp_top _ hε M _
  · refine' ⟨δ, hδpos, fun s hs hμs => _⟩
    rw [(_ : f = {x : α | M ≤ ‖f x‖₊}.indicator f + {x : α | ‖f x‖ < M}.indicator f)]
    · rw [snorm_indicator_eq_snorm_restrict hs]
      refine' le_trans (snorm_add_le _ _ hp_one) _
      ·
        exact
          strongly_measurable.ae_strongly_measurable
            (hmeas.indicator
              (measurableSet_le measurable_const hmeas.nnnorm.measurable.subtype_coe))
      ·
        exact
          strongly_measurable.ae_strongly_measurable
            (hmeas.indicator
              (measurableSet_lt hmeas.nnnorm.measurable.subtype_coe measurable_const))
      · rw [two_mul]
        refine' add_le_add (le_trans (snorm_mono_measure _ measure.restrict_le_self) hM) _
        rw [← snorm_indicator_eq_snorm_restrict hs]
        exact hδ s hs hμs
    · ext x
      by_cases hx : M ≤ ‖f x‖
      · rw [Pi.add_apply, indicator_of_mem, indicator_of_not_mem, add_zero] <;> simpa
      · rw [Pi.add_apply, indicator_of_not_mem, indicator_of_mem, zero_add] <;> simpa using hx
  · intro x
    rw [norm_indicator_eq_indicator_norm, indicator_apply]
    split_ifs
    exacts [h, hMpos]
#align measure_theory.mem_ℒp.snorm_indicator_le' MeasureTheory.Memℒp.snorm_indicator_le'
-/

#print MeasureTheory.Memℒp.snorm_indicator_le_of_meas /-
/-- This lemma is superceded by `measure_theory.mem_ℒp.snorm_indicator_le` which does not require
measurability on `f`. -/
theorem Memℒp.snorm_indicator_le_of_meas (hp_one : 1 ≤ p) (hp_top : p ≠ ∞) (hf : Memℒp f p μ)
    (hmeas : StronglyMeasurable f) {ε : ℝ} (hε : 0 < ε) :
    ∃ (δ : ℝ) (hδ : 0 < δ),
      ∀ s,
        MeasurableSet s → μ s ≤ ENNReal.ofReal δ → snorm (s.indicator f) p μ ≤ ENNReal.ofReal ε :=
  by
  obtain ⟨δ, hδpos, hδ⟩ := hf.snorm_indicator_le' μ hp_one hp_top hmeas (half_pos hε)
  refine' ⟨δ, hδpos, fun s hs hμs => le_trans (hδ s hs hμs) _⟩
  rw [ENNReal.ofReal_div_of_pos zero_lt_two, (by norm_num : ENNReal.ofReal 2 = 2),
      ENNReal.mul_div_cancel'] <;>
    norm_num
#align measure_theory.mem_ℒp.snorm_indicator_le_of_meas MeasureTheory.Memℒp.snorm_indicator_le_of_meas
-/

#print MeasureTheory.Memℒp.snorm_indicator_le /-
theorem Memℒp.snorm_indicator_le (hp_one : 1 ≤ p) (hp_top : p ≠ ∞) (hf : Memℒp f p μ) {ε : ℝ}
    (hε : 0 < ε) :
    ∃ (δ : ℝ) (hδ : 0 < δ),
      ∀ s,
        MeasurableSet s → μ s ≤ ENNReal.ofReal δ → snorm (s.indicator f) p μ ≤ ENNReal.ofReal ε :=
  by
  have hℒp := hf
  obtain ⟨⟨f', hf', heq⟩, hnorm⟩ := hf
  obtain ⟨δ, hδpos, hδ⟩ := (hℒp.ae_eq HEq).snorm_indicator_le_of_meas μ hp_one hp_top hf' hε
  refine' ⟨δ, hδpos, fun s hs hμs => _⟩
  convert hδ s hs hμs using 1
  rw [snorm_indicator_eq_snorm_restrict hs, snorm_indicator_eq_snorm_restrict hs]
  refine' snorm_congr_ae heq.restrict
#align measure_theory.mem_ℒp.snorm_indicator_le MeasureTheory.Memℒp.snorm_indicator_le
-/

#print MeasureTheory.unifIntegrable_const /-
/-- A constant function is uniformly integrable. -/
theorem unifIntegrable_const {g : α → β} (hp : 1 ≤ p) (hp_ne_top : p ≠ ∞) (hg : Memℒp g p μ) :
    UnifIntegrable (fun n : ι => g) p μ := by
  intro ε hε
  obtain ⟨δ, hδ_pos, hgδ⟩ := hg.snorm_indicator_le μ hp hp_ne_top hε
  exact ⟨δ, hδ_pos, fun i => hgδ⟩
#align measure_theory.unif_integrable_const MeasureTheory.unifIntegrable_const
-/

#print MeasureTheory.unifIntegrable_subsingleton /-
/-- A single function is uniformly integrable. -/
theorem unifIntegrable_subsingleton [Subsingleton ι] (hp_one : 1 ≤ p) (hp_top : p ≠ ∞)
    {f : ι → α → β} (hf : ∀ i, Memℒp (f i) p μ) : UnifIntegrable f p μ :=
  by
  intro ε hε
  by_cases hι : Nonempty ι
  · cases' hι with i
    obtain ⟨δ, hδpos, hδ⟩ := (hf i).snorm_indicator_le μ hp_one hp_top hε
    refine' ⟨δ, hδpos, fun j s hs hμs => _⟩
    convert hδ s hs hμs
  · exact ⟨1, zero_lt_one, fun i => False.elim <| hι <| Nonempty.intro i⟩
#align measure_theory.unif_integrable_subsingleton MeasureTheory.unifIntegrable_subsingleton
-/

#print MeasureTheory.unifIntegrable_fin /-
/-- This lemma is less general than `measure_theory.unif_integrable_fintype` which applies to
all sequences indexed by a finite type. -/
theorem unifIntegrable_fin (hp_one : 1 ≤ p) (hp_top : p ≠ ∞) {n : ℕ} {f : Fin n → α → β}
    (hf : ∀ i, Memℒp (f i) p μ) : UnifIntegrable f p μ :=
  by
  revert f
  induction' n with n h
  · exact fun f hf => unif_integrable_subsingleton μ hp_one hp_top hf
  intro f hfLp ε hε
  set g : Fin n → α → β := fun k => f k with hg
  have hgLp : ∀ i, mem_ℒp (g i) p μ := fun i => hfLp i
  obtain ⟨δ₁, hδ₁pos, hδ₁⟩ := h hgLp hε
  obtain ⟨δ₂, hδ₂pos, hδ₂⟩ := (hfLp n).snorm_indicator_le μ hp_one hp_top hε
  refine' ⟨min δ₁ δ₂, lt_min hδ₁pos hδ₂pos, fun i s hs hμs => _⟩
  by_cases hi : i.val < n
  · rw [(_ : f i = g ⟨i.val, hi⟩)]
    · exact hδ₁ _ s hs (le_trans hμs <| ENNReal.ofReal_le_ofReal <| min_le_left _ _)
    · rw [hg]; simp
  · rw [(_ : i = n)]
    · exact hδ₂ _ hs (le_trans hμs <| ENNReal.ofReal_le_ofReal <| min_le_right _ _)
    · have hi' := Fin.is_lt i
      rw [Nat.lt_succ_iff] at hi' 
      rw [not_lt] at hi 
      simp [← le_antisymm hi' hi]
#align measure_theory.unif_integrable_fin MeasureTheory.unifIntegrable_fin
-/

#print MeasureTheory.unifIntegrable_finite /-
/-- A finite sequence of Lp functions is uniformly integrable. -/
theorem unifIntegrable_finite [Finite ι] (hp_one : 1 ≤ p) (hp_top : p ≠ ∞) {f : ι → α → β}
    (hf : ∀ i, Memℒp (f i) p μ) : UnifIntegrable f p μ :=
  by
  obtain ⟨n, hn⟩ := Finite.exists_equiv_fin ι
  intro ε hε
  set g : Fin n → α → β := f ∘ hn.some.symm with hgeq
  have hg : ∀ i, mem_ℒp (g i) p μ := fun _ => hf _
  obtain ⟨δ, hδpos, hδ⟩ := unif_integrable_fin μ hp_one hp_top hg hε
  refine' ⟨δ, hδpos, fun i s hs hμs => _⟩
  specialize hδ (hn.some i) s hs hμs
  simp_rw [hgeq, Function.comp_apply, Equiv.symm_apply_apply] at hδ 
  assumption
#align measure_theory.unif_integrable_finite MeasureTheory.unifIntegrable_finite
-/

end

#print MeasureTheory.snorm_sub_le_of_dist_bdd /-
theorem snorm_sub_le_of_dist_bdd {p : ℝ≥0∞} (hp' : p ≠ ∞) {s : Set α} (hs : measurable_set[m] s)
    {f g : α → β} {c : ℝ} (hc : 0 ≤ c) (hf : ∀ x ∈ s, dist (f x) (g x) ≤ c) :
    snorm (s.indicator (f - g)) p μ ≤ ENNReal.ofReal c * μ s ^ (1 / p.toReal) :=
  by
  by_cases hp : p = 0
  · simp [hp]
  have : ∀ x, ‖s.indicator (f - g) x‖ ≤ ‖s.indicator (fun x => c) x‖ :=
    by
    intro x
    by_cases hx : x ∈ s
    · rw [indicator_of_mem hx, indicator_of_mem hx, Pi.sub_apply, ← dist_eq_norm, Real.norm_eq_abs,
        abs_of_nonneg hc]
      exact hf x hx
    · simp [indicator_of_not_mem hx]
  refine' le_trans (snorm_mono this) _
  rw [snorm_indicator_const hs hp hp']
  refine' mul_le_mul_right' (le_of_eq _) _
  rw [← ofReal_norm_eq_coe_nnnorm, Real.norm_eq_abs, abs_of_nonneg hc]
#align measure_theory.snorm_sub_le_of_dist_bdd MeasureTheory.snorm_sub_le_of_dist_bdd
-/

#print MeasureTheory.tendsto_Lp_of_tendsto_ae_of_meas /-
/-- A sequence of uniformly integrable functions which converges μ-a.e. converges in Lp. -/
theorem tendsto_Lp_of_tendsto_ae_of_meas [IsFiniteMeasure μ] (hp : 1 ≤ p) (hp' : p ≠ ∞)
    {f : ℕ → α → β} {g : α → β} (hf : ∀ n, StronglyMeasurable (f n)) (hg : StronglyMeasurable g)
    (hg' : Memℒp g p μ) (hui : UnifIntegrable f p μ)
    (hfg : ∀ᵐ x ∂μ, Tendsto (fun n => f n x) atTop (𝓝 (g x))) :
    Tendsto (fun n => snorm (f n - g) p μ) atTop (𝓝 0) :=
  by
  rw [ENNReal.tendsto_atTop_zero]
  intro ε hε
  by_cases ε < ∞; swap
  · rw [not_lt, top_le_iff] at h 
    exact ⟨0, fun n hn => by simp [h]⟩
  by_cases hμ : μ = 0
  · exact ⟨0, fun n hn => by simp [hμ]⟩
  have hε' : 0 < ε.to_real / 3 :=
    div_pos (ENNReal.toReal_pos (gt_iff_lt.1 hε).Ne.symm h.ne) (by norm_num)
  have hdivp : 0 ≤ 1 / p.to_real := by
    refine' one_div_nonneg.2 _
    rw [← ENNReal.zero_toReal, ENNReal.toReal_le_toReal ENNReal.zero_ne_top hp']
    exact le_trans (zero_le _) hp
  have hpow : 0 < measure_univ_nnreal μ ^ (1 / p.to_real) :=
    Real.rpow_pos_of_pos (measure_univ_nnreal_pos hμ) _
  obtain ⟨δ₁, hδ₁, hsnorm₁⟩ := hui hε'
  obtain ⟨δ₂, hδ₂, hsnorm₂⟩ := hg'.snorm_indicator_le μ hp hp' hε'
  obtain ⟨t, htm, ht₁, ht₂⟩ := tendsto_uniformly_on_of_ae_tendsto' hf hg hfg (lt_min hδ₁ hδ₂)
  rw [Metric.tendstoUniformlyOn_iff] at ht₂ 
  specialize
    ht₂ (ε.to_real / (3 * measure_univ_nnreal μ ^ (1 / p.to_real)))
      (div_pos (ENNReal.toReal_pos (gt_iff_lt.1 hε).Ne.symm h.ne) (mul_pos (by norm_num) hpow))
  obtain ⟨N, hN⟩ := eventually_at_top.1 ht₂; clear ht₂
  refine' ⟨N, fun n hn => _⟩
  rw [← t.indicator_self_add_compl (f n - g)]
  refine'
    le_trans
      (snorm_add_le (((hf n).sub hg).indicator htm).AEStronglyMeasurable
        (((hf n).sub hg).indicator htm.compl).AEStronglyMeasurable hp)
      _
  rw [sub_eq_add_neg, indicator_add' t, indicator_neg']
  refine'
    le_trans
      (add_le_add_right
        (snorm_add_le ((hf n).indicator htm).AEStronglyMeasurable
          (hg.indicator htm).neg.AEStronglyMeasurable hp)
        _)
      _
  have hnf : snorm (t.indicator (f n)) p μ ≤ ENNReal.ofReal (ε.to_real / 3) :=
    by
    refine' hsnorm₁ n t htm (le_trans ht₁ _)
    rw [ENNReal.ofReal_le_ofReal_iff hδ₁.le]
    exact min_le_left _ _
  have hng : snorm (t.indicator g) p μ ≤ ENNReal.ofReal (ε.to_real / 3) :=
    by
    refine' hsnorm₂ t htm (le_trans ht₁ _)
    rw [ENNReal.ofReal_le_ofReal_iff hδ₂.le]
    exact min_le_right _ _
  have hlt : snorm (tᶜ.indicator (f n - g)) p μ ≤ ENNReal.ofReal (ε.to_real / 3) :=
    by
    specialize hN n hn
    have :=
      snorm_sub_le_of_dist_bdd μ hp' htm.compl _ fun x hx =>
        (dist_comm (g x) (f n x) ▸ (hN x hx).le :
          dist (f n x) (g x) ≤ ε.to_real / (3 * measure_univ_nnreal μ ^ (1 / p.to_real)))
    refine' le_trans this _
    rw [div_mul_eq_div_mul_one_div, ← ENNReal.ofReal_toReal (measure_lt_top μ (tᶜ)).Ne,
      ENNReal.ofReal_rpow_of_nonneg ENNReal.toReal_nonneg hdivp, ← ENNReal.ofReal_mul, mul_assoc]
    · refine' ENNReal.ofReal_le_ofReal (mul_le_of_le_one_right hε'.le _)
      rw [mul_comm, mul_one_div, div_le_one]
      · refine'
          Real.rpow_le_rpow ENNReal.toReal_nonneg
            (ENNReal.toReal_le_of_le_ofReal (measure_univ_nnreal_pos hμ).le _) hdivp
        rw [ENNReal.ofReal_coe_nnreal, coe_measure_univ_nnreal]
        exact measure_mono (subset_univ _)
      · exact Real.rpow_pos_of_pos (measure_univ_nnreal_pos hμ) _
    · refine' mul_nonneg hε'.le (one_div_nonneg.2 hpow.le)
    · rw [div_mul_eq_div_mul_one_div]
      exact mul_nonneg hε'.le (one_div_nonneg.2 hpow.le)
  have : ENNReal.ofReal (ε.to_real / 3) = ε / 3 :=
    by
    rw [ENNReal.ofReal_div_of_pos (show (0 : ℝ) < 3 by norm_num), ENNReal.ofReal_toReal h.ne]
    simp
  rw [this] at hnf hng hlt 
  rw [snorm_neg, ← ENNReal.add_thirds ε, ← sub_eq_add_neg]
  exact add_le_add_three hnf hng hlt
#align measure_theory.tendsto_Lp_of_tendsto_ae_of_meas MeasureTheory.tendsto_Lp_of_tendsto_ae_of_meas
-/

#print MeasureTheory.tendsto_Lp_of_tendsto_ae /-
/-- A sequence of uniformly integrable functions which converges μ-a.e. converges in Lp. -/
theorem tendsto_Lp_of_tendsto_ae [IsFiniteMeasure μ] (hp : 1 ≤ p) (hp' : p ≠ ∞) {f : ℕ → α → β}
    {g : α → β} (hf : ∀ n, AEStronglyMeasurable (f n) μ) (hg : Memℒp g p μ)
    (hui : UnifIntegrable f p μ) (hfg : ∀ᵐ x ∂μ, Tendsto (fun n => f n x) atTop (𝓝 (g x))) :
    Tendsto (fun n => snorm (f n - g) p μ) atTop (𝓝 0) :=
  by
  suffices tendsto (fun n : ℕ => snorm ((hf n).mk (f n) - hg.1.mk g) p μ) at_top (𝓝 0)
    by
    convert this
    exact funext fun n => snorm_congr_ae ((hf n).ae_eq_mk.sub hg.1.ae_eq_mk)
  refine'
    tendsto_Lp_of_tendsto_ae_of_meas μ hp hp' (fun n => (hf n).stronglyMeasurable_mk)
      hg.1.stronglyMeasurable_mk (hg.ae_eq hg.1.ae_eq_mk) (hui.ae_eq fun n => (hf n).ae_eq_mk) _
  have h_ae_forall_eq : ∀ᵐ x ∂μ, ∀ n, f n x = (hf n).mk (f n) x :=
    by
    rw [ae_all_iff]
    exact fun n => (hf n).ae_eq_mk
  filter_upwards [hfg, h_ae_forall_eq, hg.1.ae_eq_mk] with x hx_tendsto hxf_eq hxg_eq
  rw [← hxg_eq]
  convert hx_tendsto
  ext1 n
  exact (hxf_eq n).symm
#align measure_theory.tendsto_Lp_of_tendsto_ae MeasureTheory.tendsto_Lp_of_tendsto_ae
-/

variable {f : ℕ → α → β} {g : α → β}

#print MeasureTheory.unifIntegrable_of_tendsto_Lp_zero /-
theorem unifIntegrable_of_tendsto_Lp_zero (hp : 1 ≤ p) (hp' : p ≠ ∞) (hf : ∀ n, Memℒp (f n) p μ)
    (hf_tendsto : Tendsto (fun n => snorm (f n) p μ) atTop (𝓝 0)) : UnifIntegrable f p μ :=
  by
  intro ε hε
  rw [ENNReal.tendsto_atTop_zero] at hf_tendsto 
  obtain ⟨N, hN⟩ := hf_tendsto (ENNReal.ofReal ε) (by simpa)
  set F : Fin N → α → β := fun n => f n
  have hF : ∀ n, mem_ℒp (F n) p μ := fun n => hf n
  obtain ⟨δ₁, hδpos₁, hδ₁⟩ := unif_integrable_fin μ hp hp' hF hε
  refine' ⟨δ₁, hδpos₁, fun n s hs hμs => _⟩
  by_cases hn : n < N
  · exact hδ₁ ⟨n, hn⟩ s hs hμs
  · exact (snorm_indicator_le _).trans (hN n (not_lt.1 hn))
#align measure_theory.unif_integrable_of_tendsto_Lp_zero MeasureTheory.unifIntegrable_of_tendsto_Lp_zero
-/

#print MeasureTheory.unifIntegrable_of_tendsto_Lp /-
/-- Convergence in Lp implies uniform integrability. -/
theorem unifIntegrable_of_tendsto_Lp (hp : 1 ≤ p) (hp' : p ≠ ∞) (hf : ∀ n, Memℒp (f n) p μ)
    (hg : Memℒp g p μ) (hfg : Tendsto (fun n => snorm (f n - g) p μ) atTop (𝓝 0)) :
    UnifIntegrable f p μ :=
  by
  have : f = (fun n => g) + fun n => f n - g := by ext1 n; simp
  rw [this]
  refine'
    unif_integrable.add _ _ hp (fun _ => hg.ae_strongly_measurable) fun n =>
      (hf n).1.sub hg.ae_strongly_measurable
  · exact unif_integrable_const μ hp hp' hg
  · exact unif_integrable_of_tendsto_Lp_zero μ hp hp' (fun n => (hf n).sub hg) hfg
#align measure_theory.unif_integrable_of_tendsto_Lp MeasureTheory.unifIntegrable_of_tendsto_Lp
-/

#print MeasureTheory.tendsto_Lp_of_tendstoInMeasure /-
/-- Forward direction of Vitali's convergence theorem: if `f` is a sequence of uniformly integrable
functions that converge in measure to some function `g` in a finite measure space, then `f`
converge in Lp to `g`. -/
theorem tendsto_Lp_of_tendstoInMeasure [IsFiniteMeasure μ] (hp : 1 ≤ p) (hp' : p ≠ ∞)
    (hf : ∀ n, AEStronglyMeasurable (f n) μ) (hg : Memℒp g p μ) (hui : UnifIntegrable f p μ)
    (hfg : TendstoInMeasure μ f atTop g) : Tendsto (fun n => snorm (f n - g) p μ) atTop (𝓝 0) :=
  by
  refine' tendsto_of_subseq_tendsto fun ns hns => _
  obtain ⟨ms, hms, hms'⟩ := tendsto_in_measure.exists_seq_tendsto_ae fun ε hε => (hfg ε hε).comp hns
  exact
    ⟨ms,
      tendsto_Lp_of_tendsto_ae μ hp hp' (fun _ => hf _) hg
        (fun ε hε =>
          let ⟨δ, hδ, hδ'⟩ := hui hε
          ⟨δ, hδ, fun i s hs hμs => hδ' _ s hs hμs⟩)
        hms'⟩
#align measure_theory.tendsto_Lp_of_tendsto_in_measure MeasureTheory.tendsto_Lp_of_tendstoInMeasure
-/

#print MeasureTheory.tendstoInMeasure_iff_tendsto_Lp /-
/-- **Vitali's convergence theorem**: A sequence of functions `f` converges to `g` in Lp if and
only if it is uniformly integrable and converges to `g` in measure. -/
theorem tendstoInMeasure_iff_tendsto_Lp [IsFiniteMeasure μ] (hp : 1 ≤ p) (hp' : p ≠ ∞)
    (hf : ∀ n, Memℒp (f n) p μ) (hg : Memℒp g p μ) :
    TendstoInMeasure μ f atTop g ∧ UnifIntegrable f p μ ↔
      Tendsto (fun n => snorm (f n - g) p μ) atTop (𝓝 0) :=
  ⟨fun h => tendsto_Lp_of_tendstoInMeasure μ hp hp' (fun n => (hf n).1) hg h.2 h.1, fun h =>
    ⟨tendstoInMeasure_of_tendsto_snorm (lt_of_lt_of_le zero_lt_one hp).Ne.symm
        (fun n => (hf n).AEStronglyMeasurable) hg.AEStronglyMeasurable h,
      unifIntegrable_of_tendsto_Lp μ hp hp' hf hg h⟩⟩
#align measure_theory.tendsto_in_measure_iff_tendsto_Lp MeasureTheory.tendstoInMeasure_iff_tendsto_Lp
-/

#print MeasureTheory.unifIntegrable_of' /-
/-- This lemma is superceded by `unif_integrable_of` which do not require `C` to be positive. -/
theorem unifIntegrable_of' (hp : 1 ≤ p) (hp' : p ≠ ∞) {f : ι → α → β}
    (hf : ∀ i, StronglyMeasurable (f i))
    (h :
      ∀ ε : ℝ,
        0 < ε →
          ∃ C : ℝ≥0,
            0 < C ∧ ∀ i, snorm ({x | C ≤ ‖f i x‖₊}.indicator (f i)) p μ ≤ ENNReal.ofReal ε) :
    UnifIntegrable f p μ :=
  by
  have hpzero := (lt_of_lt_of_le zero_lt_one hp).Ne.symm
  by_cases hμ : μ Set.univ = 0
  · rw [measure.measure_univ_eq_zero] at hμ 
    exact hμ.symm ▸ unif_integrable_zero_meas
  intro ε hε
  obtain ⟨C, hCpos, hC⟩ := h (ε / 2) (half_pos hε)
  refine'
    ⟨(ε / (2 * C)) ^ ENNReal.toReal p,
      Real.rpow_pos_of_pos (div_pos hε (mul_pos two_pos (NNReal.coe_pos.2 hCpos))) _,
      fun i s hs hμs => _⟩
  by_cases hμs' : μ s = 0
  · rw [(snorm_eq_zero_iff ((hf i).indicator hs).AEStronglyMeasurable hpzero).2
        (indicator_meas_zero hμs')]
    norm_num
  calc
    snorm (indicator s (f i)) p μ ≤
        snorm (indicator (s ∩ {x | C ≤ ‖f i x‖₊}) (f i)) p μ +
          snorm (indicator (s ∩ {x | ‖f i x‖₊ < C}) (f i)) p μ :=
      by
      refine'
        le_trans (Eq.le _)
          (snorm_add_le
            (strongly_measurable.ae_strongly_measurable
              ((hf i).indicator
                (hs.inter (strongly_measurable_const.measurable_set_le (hf i).nnnorm))))
            (strongly_measurable.ae_strongly_measurable
              ((hf i).indicator
                (hs.inter ((hf i).nnnorm.measurableSet_lt strongly_measurable_const))))
            hp)
      congr
      change
        _ = fun x =>
          (s ∩ {x : α | C ≤ ‖f i x‖₊}).indicator (f i) x +
            (s ∩ {x : α | ‖f i x‖₊ < C}).indicator (f i) x
      rw [← Set.indicator_union_of_disjoint]
      · congr
        rw [← inter_union_distrib_left,
          (by ext; simp [le_or_lt] : {x : α | C ≤ ‖f i x‖₊} ∪ {x : α | ‖f i x‖₊ < C} = Set.univ),
          inter_univ]
      · refine' (Disjoint.inf_right' _ _).inf_left' _
        rw [disjoint_iff_inf_le]
        rintro x ⟨hx₁ : _ ≤ _, hx₂ : _ < _⟩
        exact False.elim (hx₂.ne (eq_of_le_of_not_lt hx₁ (not_lt.2 hx₂.le)).symm)
    _ ≤ snorm (indicator {x | C ≤ ‖f i x‖₊} (f i)) p μ + C * μ s ^ (1 / ENNReal.toReal p) :=
      by
      refine'
        add_le_add (snorm_mono fun x => norm_indicator_le_of_subset (inter_subset_right _ _) _ _) _
      rw [← indicator_indicator]
      rw [snorm_indicator_eq_snorm_restrict]
      have : ∀ᵐ x ∂μ.restrict s, ‖{x : α | ‖f i x‖₊ < C}.indicator (f i) x‖ ≤ C :=
        by
        refine' ae_of_all _ _
        simp_rw [norm_indicator_eq_indicator_norm]
        exact indicator_le' (fun x (hx : _ < _) => hx.le) fun _ _ => NNReal.coe_nonneg _
      refine' le_trans (snorm_le_of_ae_bound this) _
      rw [mul_comm, measure.restrict_apply' hs, univ_inter, ENNReal.ofReal_coe_nnreal, one_div]
      exacts [le_rfl, hs]
    _ ≤ ENNReal.ofReal (ε / 2) + C * ENNReal.ofReal (ε / (2 * C)) :=
      by
      refine' add_le_add (hC i) (mul_le_mul_left' _ _)
      rwa [ENNReal.rpow_one_div_le_iff (ENNReal.toReal_pos hpzero hp'),
        ENNReal.ofReal_rpow_of_pos (div_pos hε (mul_pos two_pos (NNReal.coe_pos.2 hCpos)))]
    _ ≤ ENNReal.ofReal (ε / 2) + ENNReal.ofReal (ε / 2) :=
      by
      refine' add_le_add_left _ _
      rw [← ENNReal.ofReal_coe_nnreal, ← ENNReal.ofReal_mul (NNReal.coe_nonneg _), ← div_div,
        mul_div_cancel' _ (NNReal.coe_pos.2 hCpos).Ne.symm]
      exact le_rfl
    _ ≤ ENNReal.ofReal ε :=
      by
      rw [← ENNReal.ofReal_add (half_pos hε).le (half_pos hε).le, add_halves]
      exact le_rfl
#align measure_theory.unif_integrable_of' MeasureTheory.unifIntegrable_of'
-/

#print MeasureTheory.unifIntegrable_of /-
theorem unifIntegrable_of (hp : 1 ≤ p) (hp' : p ≠ ∞) {f : ι → α → β}
    (hf : ∀ i, AEStronglyMeasurable (f i) μ)
    (h :
      ∀ ε : ℝ,
        0 < ε → ∃ C : ℝ≥0, ∀ i, snorm ({x | C ≤ ‖f i x‖₊}.indicator (f i)) p μ ≤ ENNReal.ofReal ε) :
    UnifIntegrable f p μ := by
  set g : ι → α → β := fun i => (hf i).some
  refine'
    (unif_integrable_of' μ hp hp' (fun i => (Exists.choose_spec <| hf i).1) fun ε hε => _).ae_eq
      fun i => (Exists.choose_spec <| hf i).2.symm
  obtain ⟨C, hC⟩ := h ε hε
  have hCg : ∀ i, snorm ({x | C ≤ ‖g i x‖₊}.indicator (g i)) p μ ≤ ENNReal.ofReal ε :=
    by
    intro i
    refine' le_trans (le_of_eq <| snorm_congr_ae _) (hC i)
    filter_upwards [(Exists.choose_spec <| hf i).2] with x hx
    by_cases hfx : x ∈ {x | C ≤ ‖f i x‖₊}
    · rw [indicator_of_mem hfx, indicator_of_mem, hx]
      rwa [mem_set_of, hx] at hfx 
    · rw [indicator_of_not_mem hfx, indicator_of_not_mem]
      rwa [mem_set_of, hx] at hfx 
  refine' ⟨max C 1, lt_max_of_lt_right one_pos, fun i => le_trans (snorm_mono fun x => _) (hCg i)⟩
  rw [norm_indicator_eq_indicator_norm, norm_indicator_eq_indicator_norm]
  exact
    indicator_le_indicator_of_subset (fun x hx => le_trans (le_max_left _ _) hx)
      (fun _ => norm_nonneg _) _
#align measure_theory.unif_integrable_of MeasureTheory.unifIntegrable_of
-/

end UnifIntegrable

section UniformIntegrable

/-! `uniform_integrable`

In probability theory, uniform integrability normally refers to the condition that a sequence
of function `(fₙ)` satisfies for all `ε > 0`, there exists some `C ≥ 0` such that
`∫ x in {|fₙ| ≥ C}, fₙ x ∂μ ≤ ε` for all `n`.

In this section, we will develope some API for `uniform_integrable` and prove that
`uniform_integrable` is equivalent to this definition of uniform integrability.
-/


variable {p : ℝ≥0∞} {f : ι → α → β}

#print MeasureTheory.uniformIntegrable_zero_meas /-
theorem uniformIntegrable_zero_meas [MeasurableSpace α] : UniformIntegrable f p (0 : Measure α) :=
  ⟨fun n => aestronglyMeasurable_zero_measure _, unifIntegrable_zero_meas, 0, fun i =>
    snorm_measure_zero.le⟩
#align measure_theory.uniform_integrable_zero_meas MeasureTheory.uniformIntegrable_zero_meas
-/

#print MeasureTheory.UniformIntegrable.ae_eq /-
theorem UniformIntegrable.ae_eq {g : ι → α → β} (hf : UniformIntegrable f p μ)
    (hfg : ∀ n, f n =ᵐ[μ] g n) : UniformIntegrable g p μ :=
  by
  obtain ⟨hfm, hunif, C, hC⟩ := hf
  refine' ⟨fun i => (hfm i).congr (hfg i), (unif_integrable_congr_ae hfg).1 hunif, C, fun i => _⟩
  rw [← snorm_congr_ae (hfg i)]
  exact hC i
#align measure_theory.uniform_integrable.ae_eq MeasureTheory.UniformIntegrable.ae_eq
-/

#print MeasureTheory.uniformIntegrable_congr_ae /-
theorem uniformIntegrable_congr_ae {g : ι → α → β} (hfg : ∀ n, f n =ᵐ[μ] g n) :
    UniformIntegrable f p μ ↔ UniformIntegrable g p μ :=
  ⟨fun h => h.ae_eq hfg, fun h => h.ae_eq fun i => (hfg i).symm⟩
#align measure_theory.uniform_integrable_congr_ae MeasureTheory.uniformIntegrable_congr_ae
-/

#print MeasureTheory.uniformIntegrable_finite /-
/-- A finite sequence of Lp functions is uniformly integrable in the probability sense. -/
theorem uniformIntegrable_finite [Finite ι] (hp_one : 1 ≤ p) (hp_top : p ≠ ∞)
    (hf : ∀ i, Memℒp (f i) p μ) : UniformIntegrable f p μ :=
  by
  cases nonempty_fintype ι
  refine' ⟨fun n => (hf n).1, unif_integrable_finite μ hp_one hp_top hf, _⟩
  by_cases hι : Nonempty ι
  · choose ae_meas hf using hf
    set C :=
      (finset.univ.image fun i : ι => snorm (f i) p μ).max'
        ⟨snorm (f hι.some) p μ, Finset.mem_image.2 ⟨hι.some, Finset.mem_univ _, rfl⟩⟩
    refine' ⟨C.to_nnreal, fun i => _⟩
    rw [ENNReal.coe_toNNReal]
    · exact Finset.le_max' _ _ (Finset.mem_image.2 ⟨i, Finset.mem_univ _, rfl⟩)
    · refine' ne_of_lt ((Finset.max'_lt_iff _ _).2 fun y hy => _)
      rw [Finset.mem_image] at hy 
      obtain ⟨i, -, rfl⟩ := hy
      exact hf i
  · exact ⟨0, fun i => False.elim <| hι <| Nonempty.intro i⟩
#align measure_theory.uniform_integrable_finite MeasureTheory.uniformIntegrable_finite
-/

#print MeasureTheory.uniformIntegrable_subsingleton /-
/-- A single function is uniformly integrable in the probability sense. -/
theorem uniformIntegrable_subsingleton [Subsingleton ι] (hp_one : 1 ≤ p) (hp_top : p ≠ ∞)
    (hf : ∀ i, Memℒp (f i) p μ) : UniformIntegrable f p μ :=
  uniformIntegrable_finite hp_one hp_top hf
#align measure_theory.uniform_integrable_subsingleton MeasureTheory.uniformIntegrable_subsingleton
-/

#print MeasureTheory.uniformIntegrable_const /-
/-- A constant sequence of functions is uniformly integrable in the probability sense. -/
theorem uniformIntegrable_const {g : α → β} (hp : 1 ≤ p) (hp_ne_top : p ≠ ∞) (hg : Memℒp g p μ) :
    UniformIntegrable (fun n : ι => g) p μ :=
  ⟨fun i => hg.1, unifIntegrable_const μ hp hp_ne_top hg,
    ⟨(snorm g p μ).toNNReal, fun i => le_of_eq (ENNReal.coe_toNNReal hg.2.Ne).symm⟩⟩
#align measure_theory.uniform_integrable_const MeasureTheory.uniformIntegrable_const
-/

#print MeasureTheory.uniformIntegrable_of' /-
/-- This lemma is superceded by `uniform_integrable_of` which only requires
`ae_strongly_measurable`. -/
theorem uniformIntegrable_of' [IsFiniteMeasure μ] (hp : 1 ≤ p) (hp' : p ≠ ∞)
    (hf : ∀ i, StronglyMeasurable (f i))
    (h :
      ∀ ε : ℝ,
        0 < ε → ∃ C : ℝ≥0, ∀ i, snorm ({x | C ≤ ‖f i x‖₊}.indicator (f i)) p μ ≤ ENNReal.ofReal ε) :
    UniformIntegrable f p μ :=
  by
  refine'
    ⟨fun i => (hf i).AEStronglyMeasurable,
      unif_integrable_of μ hp hp' (fun i => (hf i).AEStronglyMeasurable) h, _⟩
  obtain ⟨C, hC⟩ := h 1 one_pos
  refine' ⟨(C * μ univ ^ p.to_real⁻¹ + 1 : ℝ≥0∞).toNNReal, fun i => _⟩
  calc
    snorm (f i) p μ ≤
        snorm ({x : α | ‖f i x‖₊ < C}.indicator (f i)) p μ +
          snorm ({x : α | C ≤ ‖f i x‖₊}.indicator (f i)) p μ :=
      by
      refine'
        le_trans (snorm_mono fun x => _)
          (snorm_add_le
            (strongly_measurable.ae_strongly_measurable
              ((hf i).indicator ((hf i).nnnorm.measurableSet_lt strongly_measurable_const)))
            (strongly_measurable.ae_strongly_measurable
              ((hf i).indicator (strongly_measurable_const.measurable_set_le (hf i).nnnorm)))
            hp)
      · rw [Pi.add_apply, indicator_apply]
        split_ifs with hx
        · rw [indicator_of_not_mem, add_zero]
          simpa using hx
        · rw [indicator_of_mem, zero_add]
          simpa using hx
    _ ≤ C * μ univ ^ p.to_real⁻¹ + 1 :=
      by
      have : ∀ᵐ x ∂μ, ‖{x : α | ‖f i x‖₊ < C}.indicator (f i) x‖₊ ≤ C :=
        by
        refine' eventually_of_forall _
        simp_rw [nnnorm_indicator_eq_indicator_nnnorm]
        exact indicator_le fun x (hx : _ < _) => hx.le
      refine' add_le_add (le_trans (snorm_le_of_ae_bound this) _) (ENNReal.ofReal_one ▸ hC i)
      rw [ENNReal.ofReal_coe_nnreal, mul_comm]
      exact le_rfl
    _ = (C * μ univ ^ p.to_real⁻¹ + 1 : ℝ≥0∞).toNNReal :=
      by
      rw [ENNReal.coe_toNNReal]
      exact
        ENNReal.add_ne_top.2
          ⟨ENNReal.mul_ne_top ENNReal.coe_ne_top
              (ENNReal.rpow_ne_top_of_nonneg (inv_nonneg.2 ENNReal.toReal_nonneg)
                (measure_lt_top _ _).Ne),
            ENNReal.one_ne_top⟩
#align measure_theory.uniform_integrable_of' MeasureTheory.uniformIntegrable_of'
-/

#print MeasureTheory.uniformIntegrable_of /-
/-- A sequene of functions `(fₙ)` is uniformly integrable in the probability sense if for all
`ε > 0`, there exists some `C` such that `∫ x in {|fₙ| ≥ C}, fₙ x ∂μ ≤ ε` for all `n`. -/
theorem uniformIntegrable_of [IsFiniteMeasure μ] (hp : 1 ≤ p) (hp' : p ≠ ∞)
    (hf : ∀ i, AEStronglyMeasurable (f i) μ)
    (h :
      ∀ ε : ℝ,
        0 < ε → ∃ C : ℝ≥0, ∀ i, snorm ({x | C ≤ ‖f i x‖₊}.indicator (f i)) p μ ≤ ENNReal.ofReal ε) :
    UniformIntegrable f p μ :=
  by
  set g : ι → α → β := fun i => (hf i).some
  have hgmeas : ∀ i, strongly_measurable (g i) := fun i => (Exists.choose_spec <| hf i).1
  have hgeq : ∀ i, g i =ᵐ[μ] f i := fun i => (Exists.choose_spec <| hf i).2.symm
  refine' (uniform_integrable_of' hp hp' hgmeas fun ε hε => _).ae_eq hgeq
  obtain ⟨C, hC⟩ := h ε hε
  refine' ⟨C, fun i => le_trans (le_of_eq <| snorm_congr_ae _) (hC i)⟩
  filter_upwards [(Exists.choose_spec <| hf i).2] with x hx
  by_cases hfx : x ∈ {x | C ≤ ‖f i x‖₊}
  · rw [indicator_of_mem hfx, indicator_of_mem, hx]
    rwa [mem_set_of, hx] at hfx 
  · rw [indicator_of_not_mem hfx, indicator_of_not_mem]
    rwa [mem_set_of, hx] at hfx 
#align measure_theory.uniform_integrable_of MeasureTheory.uniformIntegrable_of
-/

#print MeasureTheory.UniformIntegrable.spec' /-
/-- This lemma is superceded by `uniform_integrable.spec` which does not require measurability. -/
theorem UniformIntegrable.spec' (hp : p ≠ 0) (hp' : p ≠ ∞) (hf : ∀ i, StronglyMeasurable (f i))
    (hfu : UniformIntegrable f p μ) {ε : ℝ} (hε : 0 < ε) :
    ∃ C : ℝ≥0, ∀ i, snorm ({x | C ≤ ‖f i x‖₊}.indicator (f i)) p μ ≤ ENNReal.ofReal ε :=
  by
  obtain ⟨-, hfu, M, hM⟩ := hfu
  obtain ⟨δ, hδpos, hδ⟩ := hfu hε
  obtain ⟨C, hC⟩ : ∃ C : ℝ≥0, ∀ i, μ {x | C ≤ ‖f i x‖₊} ≤ ENNReal.ofReal δ :=
    by
    by_contra hcon; push_neg at hcon 
    choose ℐ hℐ using hcon
    lift δ to ℝ≥0 using hδpos.le
    have : ∀ C : ℝ≥0, C • (δ : ℝ≥0∞) ^ (1 / p.to_real) ≤ snorm (f (ℐ C)) p μ :=
      by
      intro C
      calc
        C • (δ : ℝ≥0∞) ^ (1 / p.to_real) ≤ C • μ {x | C ≤ ‖f (ℐ C) x‖₊} ^ (1 / p.to_real) :=
          by
          rw [ENNReal.smul_def, ENNReal.smul_def, smul_eq_mul, smul_eq_mul]
          simp_rw [ENNReal.ofReal_coe_nnreal] at hℐ 
          refine'
            mul_le_mul' le_rfl
              (ENNReal.rpow_le_rpow (hℐ C).le (one_div_nonneg.2 ENNReal.toReal_nonneg))
        _ ≤ snorm ({x | C ≤ ‖f (ℐ C) x‖₊}.indicator (f (ℐ C))) p μ :=
          by
          refine'
            snorm_indicator_ge_of_bdd_below hp hp' _
              (measurableSet_le measurable_const (hf _).nnnorm.Measurable)
              (eventually_of_forall fun x hx => _)
          rwa [nnnorm_indicator_eq_indicator_nnnorm, indicator_of_mem hx]
        _ ≤ snorm (f (ℐ C)) p μ := snorm_indicator_le _
    specialize this (2 * max M 1 * δ⁻¹ ^ (1 / p.to_real))
    rw [ENNReal.coe_rpow_of_nonneg _ (one_div_nonneg.2 ENNReal.toReal_nonneg), ← ENNReal.coe_smul,
      smul_eq_mul, mul_assoc, NNReal.inv_rpow,
      inv_mul_cancel (NNReal.rpow_pos (NNReal.coe_pos.1 hδpos)).Ne.symm, mul_one, ENNReal.coe_mul, ←
      NNReal.inv_rpow] at this 
    refine'
      (lt_of_le_of_lt (le_trans (hM <| ℐ <| 2 * max M 1 * δ⁻¹ ^ (1 / p.to_real)) (le_max_left M 1))
            (lt_of_lt_of_le _ this)).Ne
        rfl
    rw [← ENNReal.coe_one, ← WithTop.coe_max, ← ENNReal.coe_mul, ENNReal.coe_lt_coe]
    exact lt_two_mul_self (lt_max_of_lt_right one_pos)
  exact ⟨C, fun i => hδ i _ (measurableSet_le measurable_const (hf i).nnnorm.Measurable) (hC i)⟩
#align measure_theory.uniform_integrable.spec' MeasureTheory.UniformIntegrable.spec'
-/

#print MeasureTheory.UniformIntegrable.spec /-
theorem UniformIntegrable.spec (hp : p ≠ 0) (hp' : p ≠ ∞) (hfu : UniformIntegrable f p μ) {ε : ℝ}
    (hε : 0 < ε) :
    ∃ C : ℝ≥0, ∀ i, snorm ({x | C ≤ ‖f i x‖₊}.indicator (f i)) p μ ≤ ENNReal.ofReal ε :=
  by
  set g : ι → α → β := fun i => (hfu.1 i).some
  have hgmeas : ∀ i, strongly_measurable (g i) := fun i => (Exists.choose_spec <| hfu.1 i).1
  have hgunif : uniform_integrable g p μ := hfu.ae_eq fun i => (Exists.choose_spec <| hfu.1 i).2
  obtain ⟨C, hC⟩ := hgunif.spec' hp hp' hgmeas hε
  refine' ⟨C, fun i => le_trans (le_of_eq <| snorm_congr_ae _) (hC i)⟩
  filter_upwards [(Exists.choose_spec <| hfu.1 i).2] with x hx
  by_cases hfx : x ∈ {x | C ≤ ‖f i x‖₊}
  · rw [indicator_of_mem hfx, indicator_of_mem, hx]
    rwa [mem_set_of, hx] at hfx 
  · rw [indicator_of_not_mem hfx, indicator_of_not_mem]
    rwa [mem_set_of, hx] at hfx 
#align measure_theory.uniform_integrable.spec MeasureTheory.UniformIntegrable.spec
-/

#print MeasureTheory.uniformIntegrable_iff /-
/-- The definition of uniform integrable in mathlib is equivalent to the definition commonly
found in literature. -/
theorem uniformIntegrable_iff [IsFiniteMeasure μ] (hp : 1 ≤ p) (hp' : p ≠ ∞) :
    UniformIntegrable f p μ ↔
      (∀ i, AEStronglyMeasurable (f i) μ) ∧
        ∀ ε : ℝ,
          0 < ε →
            ∃ C : ℝ≥0, ∀ i, snorm ({x | C ≤ ‖f i x‖₊}.indicator (f i)) p μ ≤ ENNReal.ofReal ε :=
  ⟨fun h => ⟨h.1, fun ε => h.spec (lt_of_lt_of_le zero_lt_one hp).Ne.symm hp'⟩, fun h =>
    uniformIntegrable_of hp hp' h.1 h.2⟩
#align measure_theory.uniform_integrable_iff MeasureTheory.uniformIntegrable_iff
-/

#print MeasureTheory.uniformIntegrable_average /-
/-- The averaging of a uniformly integrable sequence is also uniformly integrable. -/
theorem uniformIntegrable_average (hp : 1 ≤ p) {f : ℕ → α → ℝ} (hf : UniformIntegrable f p μ) :
    UniformIntegrable (fun n => (∑ i in Finset.range n, f i) / n) p μ :=
  by
  obtain ⟨hf₁, hf₂, hf₃⟩ := hf
  refine' ⟨fun n => _, fun ε hε => _, _⟩
  · simp_rw [div_eq_mul_inv]
    exact
      (Finset.aestronglyMeasurable_sum' _ fun i _ => hf₁ i).mul
        (ae_strongly_measurable_const : ae_strongly_measurable (fun x => (↑n : ℝ)⁻¹) μ)
  · obtain ⟨δ, hδ₁, hδ₂⟩ := hf₂ hε
    refine' ⟨δ, hδ₁, fun n s hs hle => _⟩
    simp_rw [div_eq_mul_inv, Finset.sum_mul, Set.indicator_finset_sum]
    refine' le_trans (snorm_sum_le (fun i hi => ((hf₁ i).mul_const (↑n)⁻¹).indicator hs) hp) _
    have : ∀ i, s.indicator (f i * (↑n)⁻¹) = (↑n : ℝ)⁻¹ • s.indicator (f i) :=
      by
      intro i
      rw [mul_comm, (_ : (↑n)⁻¹ * f i = fun ω => (↑n : ℝ)⁻¹ • f i ω)]
      · rw [Set.indicator_const_smul s (↑n)⁻¹ (f i)]
        rfl
      · rfl
    simp_rw [this, snorm_const_smul, ← Finset.mul_sum, nnnorm_inv, Real.nnnorm_coe_nat]
    by_cases hn : (↑(↑n : ℝ≥0)⁻¹ : ℝ≥0∞) = 0
    · simp only [hn, MulZeroClass.zero_mul, zero_le]
    refine' le_trans _ (_ : ↑(↑n : ℝ≥0)⁻¹ * n • ENNReal.ofReal ε ≤ ENNReal.ofReal ε)
    · refine' (ENNReal.mul_le_mul_left hn ENNReal.coe_ne_top).2 _
      conv_rhs => rw [← Finset.card_range n]
      exact Finset.sum_le_card_nsmul _ _ _ fun i hi => hδ₂ _ _ hs hle
    · simp only [ENNReal.coe_eq_zero, inv_eq_zero, Nat.cast_eq_zero] at hn 
      rw [nsmul_eq_mul, ← mul_assoc, ENNReal.coe_inv, ENNReal.coe_nat,
        ENNReal.inv_mul_cancel _ (ENNReal.nat_ne_top _), one_mul]
      · exact le_rfl
      all_goals simpa only [Ne.def, Nat.cast_eq_zero]
  · obtain ⟨C, hC⟩ := hf₃
    simp_rw [div_eq_mul_inv, Finset.sum_mul]
    refine' ⟨C, fun n => (snorm_sum_le (fun i hi => (hf₁ i).mul_const (↑n)⁻¹) hp).trans _⟩
    have : ∀ i, (fun ω => f i ω * (↑n)⁻¹) = (↑n : ℝ)⁻¹ • fun ω => f i ω :=
      by
      intro i
      ext ω
      simp only [mul_comm, Pi.smul_apply, Algebra.id.smul_eq_mul]
    simp_rw [this, snorm_const_smul, ← Finset.mul_sum, nnnorm_inv, Real.nnnorm_coe_nat]
    by_cases hn : (↑(↑n : ℝ≥0)⁻¹ : ℝ≥0∞) = 0
    · simp only [hn, MulZeroClass.zero_mul, zero_le]
    refine' le_trans _ (_ : ↑(↑n : ℝ≥0)⁻¹ * (n • C : ℝ≥0∞) ≤ C)
    · refine' (ENNReal.mul_le_mul_left hn ENNReal.coe_ne_top).2 _
      conv_rhs => rw [← Finset.card_range n]
      exact Finset.sum_le_card_nsmul _ _ _ fun i hi => hC i
    · simp only [ENNReal.coe_eq_zero, inv_eq_zero, Nat.cast_eq_zero] at hn 
      rw [nsmul_eq_mul, ← mul_assoc, ENNReal.coe_inv, ENNReal.coe_nat,
        ENNReal.inv_mul_cancel _ (ENNReal.nat_ne_top _), one_mul]
      · exact le_rfl
      all_goals simpa only [Ne.def, Nat.cast_eq_zero]
#align measure_theory.uniform_integrable_average MeasureTheory.uniformIntegrable_average
-/

end UniformIntegrable

end MeasureTheory

