/-
Copyright (c) 2022 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying

! This file was ported from Lean 3 source module probability.borel_cantelli
! leanprover-community/mathlib commit e8e130de9dba4ed6897183c3193c752ffadbcc77
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.Martingale.BorelCantelli
import Mathbin.Probability.ConditionalExpectation
import Mathbin.Probability.Independence.Basic

/-!

# The second Borel-Cantelli lemma

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains the second Borel-Cantelli lemma which states that, given a sequence of
independent sets `(sₙ)` in a probability space, if `∑ n, μ sₙ = ∞`, then the limsup of `sₙ` has
measure 1. We employ a proof using Lévy's generalized Borel-Cantelli by choosing an appropriate
filtration.

## Main result

- `probability_theory.measure_limsup_eq_one`: the second Borel-Cantelli lemma.

-/


open scoped MeasureTheory ProbabilityTheory ENNReal BigOperators Topology

open MeasureTheory ProbabilityTheory MeasurableSpace TopologicalSpace

namespace ProbabilityTheory

variable {Ω : Type _} {m0 : MeasurableSpace Ω} {μ : Measure Ω} [IsProbabilityMeasure μ]

section BorelCantelli

variable {ι β : Type _} [LinearOrder ι] [mβ : MeasurableSpace β] [NormedAddCommGroup β]
  [BorelSpace β] {f : ι → Ω → β} {i j : ι} {s : ι → Set Ω}

#print ProbabilityTheory.iIndepFun.indep_comap_natural_of_lt /-
theorem iIndepFun.indep_comap_natural_of_lt (hf : ∀ i, StronglyMeasurable (f i))
    (hfi : iIndepFun (fun i => mβ) f μ) (hij : i < j) :
    Indep (MeasurableSpace.comap (f j) mβ) (Filtration.natural f hf i) μ :=
  by
  suffices
    indep (⨆ k ∈ {j}, MeasurableSpace.comap (f k) mβ)
      (⨆ k ∈ {k | k ≤ i}, MeasurableSpace.comap (f k) mβ) μ
    by rwa [iSup_singleton] at this 
  exact indep_supr_of_disjoint (fun k => (hf k).Measurable.comap_le) hfi (by simpa)
#align probability_theory.Indep_fun.indep_comap_natural_of_lt ProbabilityTheory.iIndepFun.indep_comap_natural_of_lt
-/

#print ProbabilityTheory.iIndepFun.condexp_natural_ae_eq_of_lt /-
theorem iIndepFun.condexp_natural_ae_eq_of_lt [SecondCountableTopology β] [CompleteSpace β]
    [NormedSpace ℝ β] (hf : ∀ i, StronglyMeasurable (f i)) (hfi : iIndepFun (fun i => mβ) f μ)
    (hij : i < j) : μ[f j|Filtration.natural f hf i] =ᵐ[μ] fun ω => μ[f j] :=
  condexp_indep_eq (hf j).Measurable.comap_le (Filtration.le _ _)
    (comap_measurable <| f j).StronglyMeasurable (hfi.indep_comap_natural_of_lt hf hij)
#align probability_theory.Indep_fun.condexp_natural_ae_eq_of_lt ProbabilityTheory.iIndepFun.condexp_natural_ae_eq_of_lt
-/

#print ProbabilityTheory.iIndepSet.condexp_indicator_filtrationOfSet_ae_eq /-
theorem iIndepSet.condexp_indicator_filtrationOfSet_ae_eq (hsm : ∀ n, MeasurableSet (s n))
    (hs : iIndepSet s μ) (hij : i < j) :
    μ[(s j).indicator (fun ω => 1 : Ω → ℝ)|filtrationOfSet hsm i] =ᵐ[μ] fun ω => (μ (s j)).toReal :=
  by
  rw [filtration.filtration_of_set_eq_natural hsm]
  refine' (Indep_fun.condexp_natural_ae_eq_of_lt _ hs.Indep_fun_indicator hij).trans _
  · simp only [integral_indicator_const _ (hsm _), Algebra.id.smul_eq_mul, mul_one]
  · infer_instance
#align probability_theory.Indep_set.condexp_indicator_filtration_of_set_ae_eq ProbabilityTheory.iIndepSet.condexp_indicator_filtrationOfSet_ae_eq
-/

open Filter

#print ProbabilityTheory.measure_limsup_eq_one /-
/-- **The second Borel-Cantelli lemma**: Given a sequence of independent sets `(sₙ)` such that
`∑ n, μ sₙ = ∞`, `limsup sₙ` has measure 1. -/
theorem measure_limsup_eq_one {s : ℕ → Set Ω} (hsm : ∀ n, MeasurableSet (s n)) (hs : iIndepSet s μ)
    (hs' : ∑' n, μ (s n) = ∞) : μ (limsup s atTop) = 1 :=
  by
  rw [measure_congr
      (eventually_eq_set.2 (ae_mem_limsup_at_top_iff μ <| measurable_set_filtration_of_set' hsm) :
        (limsup s at_top : Set Ω) =ᵐ[μ]
          {ω |
            tendsto
              (fun n =>
                ∑ k in Finset.range n,
                  (μ[(s (k + 1)).indicator (1 : Ω → ℝ)|filtration_of_set hsm k]) ω)
              at_top at_top})]
  suffices
    {ω |
        tendsto
          (fun n =>
            ∑ k in Finset.range n, (μ[(s (k + 1)).indicator (1 : Ω → ℝ)|filtration_of_set hsm k]) ω)
          at_top at_top} =ᵐ[μ]
      Set.univ
    by rw [measure_congr this, measure_univ]
  have : ∀ᵐ ω ∂μ, ∀ n, (μ[(s (n + 1)).indicator (1 : Ω → ℝ)|filtration_of_set hsm n]) ω = _ :=
    ae_all_iff.2 fun n => hs.condexp_indicator_filtration_of_set_ae_eq hsm n.lt_succ_self
  filter_upwards [this] with ω hω
  refine' eq_true (_ : tendsto _ _ _)
  simp_rw [hω]
  have htends : tendsto (fun n => ∑ k in Finset.range n, μ (s (k + 1))) at_top (𝓝 ∞) :=
    by
    rw [← ENNReal.tsum_add_one_eq_top hs' (measure_ne_top _ _)]
    exact ENNReal.tendsto_nat_tsum _
  rw [ENNReal.tendsto_nhds_top_iff_nnreal] at htends 
  refine' tendsto_at_top_at_top_of_monotone' _ _
  · refine' monotone_nat_of_le_succ fun n => _
    rw [← sub_nonneg, Finset.sum_range_succ_sub_sum]
    exact ENNReal.toReal_nonneg
  · rintro ⟨B, hB⟩
    refine' not_eventually.2 (frequently_of_forall fun n => _) (htends B.to_nnreal)
    rw [mem_upperBounds] at hB 
    specialize hB (∑ k : ℕ in Finset.range n, μ (s (k + 1))).toReal _
    · refine' ⟨n, _⟩
      rw [ENNReal.toReal_sum]
      exact fun _ _ => measure_ne_top _ _
    · rw [not_lt, ← ENNReal.toReal_le_toReal (ENNReal.sum_lt_top _).Ne ENNReal.coe_ne_top]
      · exact hB.trans (by simp)
      · exact fun _ _ => measure_ne_top _ _
#align probability_theory.measure_limsup_eq_one ProbabilityTheory.measure_limsup_eq_one
-/

end BorelCantelli

end ProbabilityTheory

