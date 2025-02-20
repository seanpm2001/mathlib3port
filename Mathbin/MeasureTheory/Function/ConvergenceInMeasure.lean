/-
Copyright (c) 2022 Rémy Degenne, Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne, Kexing Ying

! This file was ported from Lean 3 source module measure_theory.function.convergence_in_measure
! leanprover-community/mathlib commit 2ebc1d6c2fed9f54c95bbc3998eaa5570527129a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Pow.Real
import Mathbin.MeasureTheory.Function.Egorov
import Mathbin.MeasureTheory.Function.LpSpace

/-!
# Convergence in measure

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define convergence in measure which is one of the many notions of convergence in probability.
A sequence of functions `f` is said to converge in measure to some function `g`
if for all `ε > 0`, the measure of the set `{x | ε ≤ dist (f i x) (g x)}` tends to 0 as `i`
converges along some given filter `l`.

Convergence in measure is most notably used in the formulation of the weak law of large numbers
and is also useful in theorems such as the Vitali convergence theorem. This file provides some
basic lemmas for working with convergence in measure and establishes some relations between
convergence in measure and other notions of convergence.

## Main definitions

* `measure_theory.tendsto_in_measure (μ : measure α) (f : ι → α → E) (g : α → E)`: `f` converges
  in `μ`-measure to `g`.

## Main results

* `measure_theory.tendsto_in_measure_of_tendsto_ae`: convergence almost everywhere in a finite
  measure space implies convergence in measure.
* `measure_theory.tendsto_in_measure.exists_seq_tendsto_ae`: if `f` is a sequence of functions
  which converges in measure to `g`, then `f` has a subsequence which convergence almost
  everywhere to `g`.
* `measure_theory.tendsto_in_measure_of_tendsto_snorm`: convergence in Lp implies convergence
  in measure.
-/


open TopologicalSpace Filter

open scoped NNReal ENNReal MeasureTheory Topology

namespace MeasureTheory

variable {α ι E : Type _} {m : MeasurableSpace α} {μ : Measure α}

#print MeasureTheory.TendstoInMeasure /-
/-- A sequence of functions `f` is said to converge in measure to some function `g` if for all
`ε > 0`, the measure of the set `{x | ε ≤ dist (f i x) (g x)}` tends to 0 as `i` converges along
some given filter `l`. -/
def TendstoInMeasure [Dist E] {m : MeasurableSpace α} (μ : Measure α) (f : ι → α → E) (l : Filter ι)
    (g : α → E) : Prop :=
  ∀ (ε) (hε : 0 < ε), Tendsto (fun i => μ {x | ε ≤ dist (f i x) (g x)}) l (𝓝 0)
#align measure_theory.tendsto_in_measure MeasureTheory.TendstoInMeasure
-/

#print MeasureTheory.tendstoInMeasure_iff_norm /-
theorem tendstoInMeasure_iff_norm [SeminormedAddCommGroup E] {l : Filter ι} {f : ι → α → E}
    {g : α → E} :
    TendstoInMeasure μ f l g ↔
      ∀ (ε) (hε : 0 < ε), Tendsto (fun i => μ {x | ε ≤ ‖f i x - g x‖}) l (𝓝 0) :=
  by simp_rw [tendsto_in_measure, dist_eq_norm]
#align measure_theory.tendsto_in_measure_iff_norm MeasureTheory.tendstoInMeasure_iff_norm
-/

namespace TendstoInMeasure

variable [Dist E] {l : Filter ι} {f f' : ι → α → E} {g g' : α → E}

#print MeasureTheory.TendstoInMeasure.congr' /-
protected theorem congr' (h_left : ∀ᶠ i in l, f i =ᵐ[μ] f' i) (h_right : g =ᵐ[μ] g')
    (h_tendsto : TendstoInMeasure μ f l g) : TendstoInMeasure μ f' l g' :=
  by
  intro ε hε
  suffices (fun i => μ {x | ε ≤ dist (f' i x) (g' x)}) =ᶠ[l] fun i => μ {x | ε ≤ dist (f i x) (g x)}
    by
    rw [tendsto_congr' this]
    exact h_tendsto ε hε
  filter_upwards [h_left] with i h_ae_eq
  refine' measure_congr _
  filter_upwards [h_ae_eq, h_right] with x hxf hxg
  rw [eq_iff_iff]
  change ε ≤ dist (f' i x) (g' x) ↔ ε ≤ dist (f i x) (g x)
  rw [hxg, hxf]
#align measure_theory.tendsto_in_measure.congr' MeasureTheory.TendstoInMeasure.congr'
-/

#print MeasureTheory.TendstoInMeasure.congr /-
protected theorem congr (h_left : ∀ i, f i =ᵐ[μ] f' i) (h_right : g =ᵐ[μ] g')
    (h_tendsto : TendstoInMeasure μ f l g) : TendstoInMeasure μ f' l g' :=
  TendstoInMeasure.congr' (eventually_of_forall h_left) h_right h_tendsto
#align measure_theory.tendsto_in_measure.congr MeasureTheory.TendstoInMeasure.congr
-/

#print MeasureTheory.TendstoInMeasure.congr_left /-
theorem congr_left (h : ∀ i, f i =ᵐ[μ] f' i) (h_tendsto : TendstoInMeasure μ f l g) :
    TendstoInMeasure μ f' l g :=
  h_tendsto.congr h EventuallyEq.rfl
#align measure_theory.tendsto_in_measure.congr_left MeasureTheory.TendstoInMeasure.congr_left
-/

#print MeasureTheory.TendstoInMeasure.congr_right /-
theorem congr_right (h : g =ᵐ[μ] g') (h_tendsto : TendstoInMeasure μ f l g) :
    TendstoInMeasure μ f l g' :=
  h_tendsto.congr (fun i => EventuallyEq.rfl) h
#align measure_theory.tendsto_in_measure.congr_right MeasureTheory.TendstoInMeasure.congr_right
-/

end TendstoInMeasure

section ExistsSeqTendstoAe

variable [MetricSpace E]

variable {f : ℕ → α → E} {g : α → E}

#print MeasureTheory.tendstoInMeasure_of_tendsto_ae_of_stronglyMeasurable /-
/-- Auxiliary lemma for `tendsto_in_measure_of_tendsto_ae`. -/
theorem tendstoInMeasure_of_tendsto_ae_of_stronglyMeasurable [IsFiniteMeasure μ]
    (hf : ∀ n, StronglyMeasurable (f n)) (hg : StronglyMeasurable g)
    (hfg : ∀ᵐ x ∂μ, Tendsto (fun n => f n x) atTop (𝓝 (g x))) : TendstoInMeasure μ f atTop g :=
  by
  refine' fun ε hε => ennreal.tendsto_at_top_zero.mpr fun δ hδ => _
  by_cases hδi : δ = ∞
  · simp only [hδi, imp_true_iff, le_top, exists_const]
  lift δ to ℝ≥0 using hδi
  rw [gt_iff_lt, ENNReal.coe_pos, ← NNReal.coe_pos] at hδ 
  obtain ⟨t, htm, ht, hunif⟩ := tendsto_uniformly_on_of_ae_tendsto' hf hg hfg hδ
  rw [ENNReal.ofReal_coe_nnreal] at ht 
  rw [Metric.tendstoUniformlyOn_iff] at hunif 
  obtain ⟨N, hN⟩ := eventually_at_top.1 (hunif ε hε)
  refine' ⟨N, fun n hn => _⟩
  suffices : {x : α | ε ≤ dist (f n x) (g x)} ⊆ t; exact (measure_mono this).trans ht
  rw [← Set.compl_subset_compl]
  intro x hx
  rw [Set.mem_compl_iff, Set.nmem_setOf_iff, dist_comm, not_le]
  exact hN n hn x hx
#align measure_theory.tendsto_in_measure_of_tendsto_ae_of_strongly_measurable MeasureTheory.tendstoInMeasure_of_tendsto_ae_of_stronglyMeasurable
-/

#print MeasureTheory.tendstoInMeasure_of_tendsto_ae /-
/-- Convergence a.e. implies convergence in measure in a finite measure space. -/
theorem tendstoInMeasure_of_tendsto_ae [IsFiniteMeasure μ] (hf : ∀ n, AEStronglyMeasurable (f n) μ)
    (hfg : ∀ᵐ x ∂μ, Tendsto (fun n => f n x) atTop (𝓝 (g x))) : TendstoInMeasure μ f atTop g :=
  by
  have hg : ae_strongly_measurable g μ := aestronglyMeasurable_of_tendsto_ae _ hf hfg
  refine' tendsto_in_measure.congr (fun i => (hf i).ae_eq_mk.symm) hg.ae_eq_mk.symm _
  refine'
    tendsto_in_measure_of_tendsto_ae_of_strongly_measurable (fun i => (hf i).stronglyMeasurable_mk)
      hg.strongly_measurable_mk _
  have hf_eq_ae : ∀ᵐ x ∂μ, ∀ n, (hf n).mk (f n) x = f n x :=
    ae_all_iff.mpr fun n => (hf n).ae_eq_mk.symm
  filter_upwards [hf_eq_ae, hg.ae_eq_mk, hfg] with x hxf hxg hxfg
  rw [← hxg, funext fun n => hxf n]
  exact hxfg
#align measure_theory.tendsto_in_measure_of_tendsto_ae MeasureTheory.tendstoInMeasure_of_tendsto_ae
-/

namespace ExistsSeqTendstoAe

#print MeasureTheory.ExistsSeqTendstoAe.exists_nat_measure_lt_two_inv /-
theorem exists_nat_measure_lt_two_inv (hfg : TendstoInMeasure μ f atTop g) (n : ℕ) :
    ∃ N, ∀ m ≥ N, μ {x | 2⁻¹ ^ n ≤ dist (f m x) (g x)} ≤ 2⁻¹ ^ n :=
  by
  specialize hfg (2⁻¹ ^ n) (by simp only [zero_lt_bit0, pow_pos, zero_lt_one, inv_pos])
  rw [ENNReal.tendsto_atTop_zero] at hfg 
  exact hfg (2⁻¹ ^ n) (pos_iff_ne_zero.mpr fun h_zero => by simpa using pow_eq_zero h_zero)
#align measure_theory.exists_seq_tendsto_ae.exists_nat_measure_lt_two_inv MeasureTheory.ExistsSeqTendstoAe.exists_nat_measure_lt_two_inv
-/

#print MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeqAux /-
/-- Given a sequence of functions `f` which converges in measure to `g`,
`seq_tendsto_ae_seq_aux` is a sequence such that
`∀ m ≥ seq_tendsto_ae_seq_aux n, μ {x | 2⁻¹ ^ n ≤ dist (f m x) (g x)} ≤ 2⁻¹ ^ n`. -/
noncomputable def seqTendstoAeSeqAux (hfg : TendstoInMeasure μ f atTop g) (n : ℕ) :=
  Classical.choose (exists_nat_measure_lt_two_inv hfg n)
#align measure_theory.exists_seq_tendsto_ae.seq_tendsto_ae_seq_aux MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeqAux
-/

#print MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeq /-
/-- Transformation of `seq_tendsto_ae_seq_aux` to makes sure it is strictly monotone. -/
noncomputable def seqTendstoAeSeq (hfg : TendstoInMeasure μ f atTop g) : ℕ → ℕ
  | 0 => seqTendstoAeSeqAux hfg 0
  | n + 1 => max (seqTendstoAeSeqAux hfg (n + 1)) (seq_tendsto_ae_seq n + 1)
#align measure_theory.exists_seq_tendsto_ae.seq_tendsto_ae_seq MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeq
-/

#print MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeq_succ /-
theorem seqTendstoAeSeq_succ (hfg : TendstoInMeasure μ f atTop g) {n : ℕ} :
    seqTendstoAeSeq hfg (n + 1) =
      max (seqTendstoAeSeqAux hfg (n + 1)) (seqTendstoAeSeq hfg n + 1) :=
  by rw [seq_tendsto_ae_seq]
#align measure_theory.exists_seq_tendsto_ae.seq_tendsto_ae_seq_succ MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeq_succ
-/

#print MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeq_spec /-
theorem seqTendstoAeSeq_spec (hfg : TendstoInMeasure μ f atTop g) (n k : ℕ)
    (hn : seqTendstoAeSeq hfg n ≤ k) : μ {x | 2⁻¹ ^ n ≤ dist (f k x) (g x)} ≤ 2⁻¹ ^ n :=
  by
  cases n
  · exact Classical.choose_spec (exists_nat_measure_lt_two_inv hfg 0) k hn
  ·
    exact
      Classical.choose_spec (exists_nat_measure_lt_two_inv hfg _) _ (le_trans (le_max_left _ _) hn)
#align measure_theory.exists_seq_tendsto_ae.seq_tendsto_ae_seq_spec MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeq_spec
-/

#print MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeq_strictMono /-
theorem seqTendstoAeSeq_strictMono (hfg : TendstoInMeasure μ f atTop g) :
    StrictMono (seqTendstoAeSeq hfg) :=
  by
  refine' strictMono_nat_of_lt_succ fun n => _
  rw [seq_tendsto_ae_seq_succ]
  exact lt_of_lt_of_le (lt_add_one <| seq_tendsto_ae_seq hfg n) (le_max_right _ _)
#align measure_theory.exists_seq_tendsto_ae.seq_tendsto_ae_seq_strict_mono MeasureTheory.ExistsSeqTendstoAe.seqTendstoAeSeq_strictMono
-/

end ExistsSeqTendstoAe

#print MeasureTheory.TendstoInMeasure.exists_seq_tendsto_ae /-
/-- If `f` is a sequence of functions which converges in measure to `g`, then there exists a
subsequence of `f` which converges a.e. to `g`. -/
theorem TendstoInMeasure.exists_seq_tendsto_ae (hfg : TendstoInMeasure μ f atTop g) :
    ∃ ns : ℕ → ℕ, StrictMono ns ∧ ∀ᵐ x ∂μ, Tendsto (fun i => f (ns i) x) atTop (𝓝 (g x)) :=
  by
  /- Since `f` tends to `g` in measure, it has a subsequence `k ↦ f (ns k)` such that
    `μ {|f (ns k) - g| ≥ 2⁻ᵏ} ≤ 2⁻ᵏ` for all `k`. Defining
    `s := ⋂ k, ⋃ i ≥ k, {|f (ns k) - g| ≥ 2⁻ᵏ}`, we see that `μ s = 0` by the
    first Borel-Cantelli lemma.
  
    On the other hand, as `s` is precisely the set for which `f (ns k)`
    doesn't converge to `g`, `f (ns k)` converges almost everywhere to `g` as required. -/
  have h_lt_ε_real : ∀ (ε : ℝ) (hε : 0 < ε), ∃ k : ℕ, 2 * 2⁻¹ ^ k < ε :=
    by
    intro ε hε
    obtain ⟨k, h_k⟩ : ∃ k : ℕ, 2⁻¹ ^ k < ε := exists_pow_lt_of_lt_one hε (by norm_num)
    refine' ⟨k + 1, (le_of_eq _).trans_lt h_k⟩
    rw [pow_add]; ring
  set ns := exists_seq_tendsto_ae.seq_tendsto_ae_seq hfg
  use ns
  let S k := {x | 2⁻¹ ^ k ≤ dist (f (ns k) x) (g x)}
  have hμS_le : ∀ k, μ (S k) ≤ 2⁻¹ ^ k := fun k =>
    exists_seq_tendsto_ae.seq_tendsto_ae_seq_spec hfg k (ns k) le_rfl
  set s := filter.at_top.limsup S with hs
  have hμs : μ s = 0 :=
    by
    refine' measure_limsup_eq_zero (ne_of_lt <| lt_of_le_of_lt (ENNReal.tsum_le_tsum hμS_le) _)
    simp only [ENNReal.tsum_geometric, ENNReal.one_sub_inv_two, inv_inv]
    decide
  have h_tendsto : ∀ x ∈ sᶜ, tendsto (fun i => f (ns i) x) at_top (𝓝 (g x)) :=
    by
    refine' fun x hx => metric.tendsto_at_top.mpr fun ε hε => _
    rw [hs, limsup_eq_infi_supr_of_nat] at hx 
    simp only [Set.iSup_eq_iUnion, Set.iInf_eq_iInter, Set.compl_iInter, Set.compl_iUnion,
      Set.mem_iUnion, Set.mem_iInter, Set.mem_compl_iff, Set.mem_setOf_eq, not_le] at hx 
    obtain ⟨N, hNx⟩ := hx
    obtain ⟨k, hk_lt_ε⟩ := h_lt_ε_real ε hε
    refine' ⟨max N (k - 1), fun n hn_ge => lt_of_le_of_lt _ hk_lt_ε⟩
    specialize hNx n ((le_max_left _ _).trans hn_ge)
    have h_inv_n_le_k : (2 : ℝ)⁻¹ ^ n ≤ 2 * 2⁻¹ ^ k :=
      by
      rw [mul_comm, ← inv_mul_le_iff' (zero_lt_two' ℝ)]
      conv_lhs =>
        congr
        rw [← pow_one (2 : ℝ)⁻¹]
      rw [← pow_add, add_comm]
      exact
        pow_le_pow_of_le_one (one_div (2 : ℝ) ▸ one_half_pos.le) (inv_le_one one_le_two)
          ((le_tsub_add.trans (add_le_add_right (le_max_right _ _) 1)).trans
            (add_le_add_right hn_ge 1))
    exact le_trans hNx.le h_inv_n_le_k
  rw [ae_iff]
  refine'
    ⟨exists_seq_tendsto_ae.seq_tendsto_ae_seq_strict_mono hfg, measure_mono_null (fun x => _) hμs⟩
  rw [Set.mem_setOf_eq, ← @Classical.not_not (x ∈ s), not_imp_not]
  exact h_tendsto x
#align measure_theory.tendsto_in_measure.exists_seq_tendsto_ae MeasureTheory.TendstoInMeasure.exists_seq_tendsto_ae
-/

#print MeasureTheory.TendstoInMeasure.exists_seq_tendstoInMeasure_atTop /-
theorem TendstoInMeasure.exists_seq_tendstoInMeasure_atTop {u : Filter ι} [NeBot u]
    [IsCountablyGenerated u] {f : ι → α → E} {g : α → E} (hfg : TendstoInMeasure μ f u g) :
    ∃ ns : ℕ → ι, TendstoInMeasure μ (fun n => f (ns n)) atTop g :=
  by
  obtain ⟨ns, h_tendsto_ns⟩ : ∃ ns : ℕ → ι, tendsto ns at_top u := exists_seq_tendsto u
  exact ⟨ns, fun ε hε => (hfg ε hε).comp h_tendsto_ns⟩
#align measure_theory.tendsto_in_measure.exists_seq_tendsto_in_measure_at_top MeasureTheory.TendstoInMeasure.exists_seq_tendstoInMeasure_atTop
-/

#print MeasureTheory.TendstoInMeasure.exists_seq_tendsto_ae' /-
theorem TendstoInMeasure.exists_seq_tendsto_ae' {u : Filter ι} [NeBot u] [IsCountablyGenerated u]
    {f : ι → α → E} {g : α → E} (hfg : TendstoInMeasure μ f u g) :
    ∃ ns : ℕ → ι, ∀ᵐ x ∂μ, Tendsto (fun i => f (ns i) x) atTop (𝓝 (g x)) :=
  by
  obtain ⟨ms, hms⟩ := hfg.exists_seq_tendsto_in_measure_at_top
  obtain ⟨ns, -, hns⟩ := hms.exists_seq_tendsto_ae
  exact ⟨ms ∘ ns, hns⟩
#align measure_theory.tendsto_in_measure.exists_seq_tendsto_ae' MeasureTheory.TendstoInMeasure.exists_seq_tendsto_ae'
-/

end ExistsSeqTendstoAe

section AeMeasurableOf

variable [MeasurableSpace E] [NormedAddCommGroup E] [BorelSpace E]

#print MeasureTheory.TendstoInMeasure.aeMeasurable /-
theorem TendstoInMeasure.aeMeasurable {u : Filter ι} [NeBot u] [IsCountablyGenerated u]
    {f : ι → α → E} {g : α → E} (hf : ∀ n, AEMeasurable (f n) μ)
    (h_tendsto : TendstoInMeasure μ f u g) : AEMeasurable g μ :=
  by
  obtain ⟨ns, hns⟩ := h_tendsto.exists_seq_tendsto_ae'
  exact aemeasurable_of_tendsto_metrizable_ae at_top (fun n => hf (ns n)) hns
#align measure_theory.tendsto_in_measure.ae_measurable MeasureTheory.TendstoInMeasure.aeMeasurable
-/

end AeMeasurableOf

section TendstoInMeasureOf

variable [NormedAddCommGroup E] {p : ℝ≥0∞}

variable {f : ι → α → E} {g : α → E}

#print MeasureTheory.tendstoInMeasure_of_tendsto_snorm_of_stronglyMeasurable /-
/-- This lemma is superceded by `measure_theory.tendsto_in_measure_of_tendsto_snorm` where we
allow `p = ∞` and only require `ae_strongly_measurable`. -/
theorem tendstoInMeasure_of_tendsto_snorm_of_stronglyMeasurable (hp_ne_zero : p ≠ 0)
    (hp_ne_top : p ≠ ∞) (hf : ∀ n, StronglyMeasurable (f n)) (hg : StronglyMeasurable g)
    {l : Filter ι} (hfg : Tendsto (fun n => snorm (f n - g) p μ) l (𝓝 0)) :
    TendstoInMeasure μ f l g := by
  intro ε hε
  replace hfg :=
    ENNReal.Tendsto.const_mul (tendsto.ennrpow_const p.to_real hfg)
      (Or.inr <| @ENNReal.ofReal_ne_top (1 / ε ^ p.to_real))
  simp only [MulZeroClass.mul_zero,
    ENNReal.zero_rpow_of_pos (ENNReal.toReal_pos hp_ne_zero hp_ne_top)] at hfg 
  rw [ENNReal.tendsto_nhds_zero] at hfg ⊢
  intro δ hδ
  refine' (hfg δ hδ).mono fun n hn => _
  refine' le_trans _ hn
  rw [ENNReal.ofReal_div_of_pos (Real.rpow_pos_of_pos hε _), ENNReal.ofReal_one, mul_comm,
    mul_one_div, ENNReal.le_div_iff_mul_le _ (Or.inl ENNReal.ofReal_ne_top), mul_comm]
  · convert
      mul_meas_ge_le_pow_snorm' μ hp_ne_zero hp_ne_top ((hf n).sub hg).AEStronglyMeasurable
        (ENNReal.ofReal ε)
    · exact (ENNReal.ofReal_rpow_of_pos hε).symm
    · ext x
      rw [dist_eq_norm, ← ENNReal.ofReal_le_ofReal_iff (norm_nonneg _), ofReal_norm_eq_coe_nnnorm]
      exact Iff.rfl
  · rw [Ne, ENNReal.ofReal_eq_zero, not_le]
    exact Or.inl (Real.rpow_pos_of_pos hε _)
#align measure_theory.tendsto_in_measure_of_tendsto_snorm_of_strongly_measurable MeasureTheory.tendstoInMeasure_of_tendsto_snorm_of_stronglyMeasurable
-/

#print MeasureTheory.tendstoInMeasure_of_tendsto_snorm_of_ne_top /-
/-- This lemma is superceded by `measure_theory.tendsto_in_measure_of_tendsto_snorm` where we
allow `p = ∞`. -/
theorem tendstoInMeasure_of_tendsto_snorm_of_ne_top (hp_ne_zero : p ≠ 0) (hp_ne_top : p ≠ ∞)
    (hf : ∀ n, AEStronglyMeasurable (f n) μ) (hg : AEStronglyMeasurable g μ) {l : Filter ι}
    (hfg : Tendsto (fun n => snorm (f n - g) p μ) l (𝓝 0)) : TendstoInMeasure μ f l g :=
  by
  refine' tendsto_in_measure.congr (fun i => (hf i).ae_eq_mk.symm) hg.ae_eq_mk.symm _
  refine'
    tendsto_in_measure_of_tendsto_snorm_of_strongly_measurable hp_ne_zero hp_ne_top
      (fun i => (hf i).stronglyMeasurable_mk) hg.strongly_measurable_mk _
  have : (fun n => snorm ((hf n).mk (f n) - hg.mk g) p μ) = fun n => snorm (f n - g) p μ := by
    ext1 n; refine' snorm_congr_ae (eventually_eq.sub (hf n).ae_eq_mk.symm hg.ae_eq_mk.symm)
  rw [this]
  exact hfg
#align measure_theory.tendsto_in_measure_of_tendsto_snorm_of_ne_top MeasureTheory.tendstoInMeasure_of_tendsto_snorm_of_ne_top
-/

#print MeasureTheory.tendstoInMeasure_of_tendsto_snorm_top /-
/-- See also `measure_theory.tendsto_in_measure_of_tendsto_snorm` which work for general
Lp-convergence for all `p ≠ 0`. -/
theorem tendstoInMeasure_of_tendsto_snorm_top {E} [NormedAddCommGroup E] {f : ι → α → E} {g : α → E}
    {l : Filter ι} (hfg : Tendsto (fun n => snorm (f n - g) ∞ μ) l (𝓝 0)) :
    TendstoInMeasure μ f l g := by
  intro δ hδ
  simp only [snorm_exponent_top, snorm_ess_sup] at hfg 
  rw [ENNReal.tendsto_nhds_zero] at hfg ⊢
  intro ε hε
  specialize
    hfg (ENNReal.ofReal δ / 2)
      (ENNReal.div_pos_iff.2 ⟨(ENNReal.ofReal_pos.2 hδ).Ne.symm, ENNReal.two_ne_top⟩)
  refine' hfg.mono fun n hn => _
  simp only [true_and_iff, gt_iff_lt, ge_iff_le, zero_tsub, zero_le, zero_add, Set.mem_Icc,
    Pi.sub_apply] at *
  have : essSup (fun x : α => (‖f n x - g x‖₊ : ℝ≥0∞)) μ < ENNReal.ofReal δ :=
    lt_of_le_of_lt hn
      (ENNReal.half_lt_self (ENNReal.ofReal_pos.2 hδ).Ne.symm ennreal.of_real_lt_top.ne)
  refine' ((le_of_eq _).trans (ae_lt_of_essSup_lt this).le).trans hε.le
  congr with x
  simp only [ENNReal.ofReal_le_iff_le_toReal ennreal.coe_lt_top.ne, ENNReal.coe_toReal, not_lt,
    coe_nnnorm, Set.mem_setOf_eq, Set.mem_compl_iff]
  rw [← dist_eq_norm (f n x) (g x)]
  rfl
#align measure_theory.tendsto_in_measure_of_tendsto_snorm_top MeasureTheory.tendstoInMeasure_of_tendsto_snorm_top
-/

#print MeasureTheory.tendstoInMeasure_of_tendsto_snorm /-
/-- Convergence in Lp implies convergence in measure. -/
theorem tendstoInMeasure_of_tendsto_snorm {l : Filter ι} (hp_ne_zero : p ≠ 0)
    (hf : ∀ n, AEStronglyMeasurable (f n) μ) (hg : AEStronglyMeasurable g μ)
    (hfg : Tendsto (fun n => snorm (f n - g) p μ) l (𝓝 0)) : TendstoInMeasure μ f l g :=
  by
  by_cases hp_ne_top : p = ∞
  · subst hp_ne_top
    exact tendsto_in_measure_of_tendsto_snorm_top hfg
  · exact tendsto_in_measure_of_tendsto_snorm_of_ne_top hp_ne_zero hp_ne_top hf hg hfg
#align measure_theory.tendsto_in_measure_of_tendsto_snorm MeasureTheory.tendstoInMeasure_of_tendsto_snorm
-/

#print MeasureTheory.tendstoInMeasure_of_tendsto_Lp /-
/-- Convergence in Lp implies convergence in measure. -/
theorem tendstoInMeasure_of_tendsto_Lp [hp : Fact (1 ≤ p)] {f : ι → Lp E p μ} {g : Lp E p μ}
    {l : Filter ι} (hfg : Tendsto f l (𝓝 g)) : TendstoInMeasure μ (fun n => f n) l g :=
  tendstoInMeasure_of_tendsto_snorm (zero_lt_one.trans_le hp.elim).Ne.symm
    (fun n => Lp.aestronglyMeasurable _) (Lp.aestronglyMeasurable _)
    ((Lp.tendsto_Lp_iff_tendsto_ℒp' _ _).mp hfg)
#align measure_theory.tendsto_in_measure_of_tendsto_Lp MeasureTheory.tendstoInMeasure_of_tendsto_Lp
-/

end TendstoInMeasureOf

end MeasureTheory

