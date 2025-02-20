/-
Copyright (c) 2023 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne

! This file was ported from Lean 3 source module probability.kernel.condexp
! leanprover-community/mathlib commit 1b089e3bdc3ce6b39cd472543474a0a137128c6c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.Kernel.CondDistrib

/-!
# Kernel associated with a conditional expectation

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define `condexp_kernel μ m`, a kernel from `Ω` to `Ω` such that for all integrable functions `f`,
`μ[f | m] =ᵐ[μ] λ ω, ∫ y, f y ∂(condexp_kernel μ m ω)`.

This kernel is defined if `Ω` is a standard Borel space. In general, `μ⟦s | m⟧` maps a measurable
set `s` to a function `Ω → ℝ≥0∞`, and for all `s` that map is unique up to a `μ`-null set. For all
`a`, the map from sets to `ℝ≥0∞` that we obtain that way verifies some of the properties of a
measure, but the fact that the `μ`-null set depends on `s` can prevent us from finding versions of
the conditional expectation that combine into a true measure. The standard Borel space assumption
on `Ω` allows us to do so.

## Main definitions

* `condexp_kernel μ m`: kernel such that `μ[f | m] =ᵐ[μ] λ ω, ∫ y, f y ∂(condexp_kernel μ m ω)`.

## Main statements

* `condexp_ae_eq_integral_condexp_kernel`: `μ[f | m] =ᵐ[μ] λ ω, ∫ y, f y ∂(condexp_kernel μ m ω)`.

-/


open MeasureTheory Set Filter TopologicalSpace

open scoped ENNReal MeasureTheory ProbabilityTheory

namespace ProbabilityTheory

section AuxLemmas

variable {Ω F : Type _} {m mΩ : MeasurableSpace Ω} {μ : Measure Ω} {f : Ω → F}

#print ProbabilityTheory.measurable_id'' /-
-- todo after the port: move to measure_theory/measurable_space, after measurable.mono
theorem measurable_id'' (hm : m ≤ mΩ) : @Measurable Ω Ω mΩ m id :=
  measurable_id.mono le_rfl hm
#align probability_theory.measurable_id'' ProbabilityTheory.measurable_id''
-/

#print ProbabilityTheory.aemeasurable_id'' /-
-- todo after the port: move to measure_theory/measurable_space, after measurable.mono
theorem aemeasurable_id'' (μ : Measure Ω) (hm : m ≤ mΩ) : @AEMeasurable Ω Ω m mΩ id μ :=
  @Measurable.aemeasurable Ω Ω mΩ m id μ (measurable_id'' hm)
#align probability_theory.ae_measurable_id'' ProbabilityTheory.aemeasurable_id''
-/

#print MeasureTheory.AEStronglyMeasurable.comp_snd_map_prod_id /-
theorem MeasureTheory.AEStronglyMeasurable.comp_snd_map_prod_id [TopologicalSpace F] (hm : m ≤ mΩ)
    (hf : AEStronglyMeasurable f μ) :
    AEStronglyMeasurable (fun x : Ω × Ω => f x.2)
      (@Measure.map Ω (Ω × Ω) (m.Prod mΩ) mΩ (fun ω => (id ω, id ω)) μ) :=
  by
  rw [← ae_strongly_measurable_comp_snd_map_prod_mk_iff (measurable_id'' hm)] at hf 
  simp_rw [id.def] at hf ⊢
  exact hf
#align measure_theory.ae_strongly_measurable.comp_snd_map_prod_id MeasureTheory.AEStronglyMeasurable.comp_snd_map_prod_id
-/

#print MeasureTheory.Integrable.comp_snd_map_prod_id /-
theorem MeasureTheory.Integrable.comp_snd_map_prod_id [NormedAddCommGroup F] (hm : m ≤ mΩ)
    (hf : Integrable f μ) :
    Integrable (fun x : Ω × Ω => f x.2)
      (@Measure.map Ω (Ω × Ω) (m.Prod mΩ) mΩ (fun ω => (id ω, id ω)) μ) :=
  by
  rw [← integrable_comp_snd_map_prod_mk_iff (measurable_id'' hm)] at hf 
  simp_rw [id.def] at hf ⊢
  exact hf
#align measure_theory.integrable.comp_snd_map_prod_id MeasureTheory.Integrable.comp_snd_map_prod_id
-/

end AuxLemmas

variable {Ω F : Type _} [TopologicalSpace Ω] {m : MeasurableSpace Ω} [mΩ : MeasurableSpace Ω]
  [PolishSpace Ω] [BorelSpace Ω] [Nonempty Ω] {μ : Measure Ω} [IsFiniteMeasure μ]
  [NormedAddCommGroup F] {f : Ω → F}

#print ProbabilityTheory.condexpKernel /-
/-- Kernel associated with the conditional expectation with respect to a σ-algebra. It satisfies
`μ[f | m] =ᵐ[μ] λ ω, ∫ y, f y ∂(condexp_kernel μ m ω)`.
It is defined as the conditional distribution of the identity given the identity, where the second
identity is understood as a map from `Ω` with the σ-algebra `mΩ` to `Ω` with σ-algebra `m`. -/
noncomputable irreducible_def condexpKernel (μ : Measure Ω) [IsFiniteMeasure μ]
    (m : MeasurableSpace Ω) : @kernel Ω Ω m mΩ :=
  @condDistrib Ω Ω Ω _ mΩ _ _ _ mΩ m id id μ _
#align probability_theory.condexp_kernel ProbabilityTheory.condexpKernel
-/

section Measurability

#print ProbabilityTheory.measurable_condexpKernel /-
theorem measurable_condexpKernel {s : Set Ω} (hs : MeasurableSet s) :
    measurable[m] fun ω => condexpKernel μ m ω s := by rw [condexp_kernel];
  convert measurable_cond_distrib hs; rw [MeasurableSpace.comap_id]
#align probability_theory.measurable_condexp_kernel ProbabilityTheory.measurable_condexpKernel
-/

#print MeasureTheory.AEStronglyMeasurable.integral_condexpKernel /-
theorem MeasureTheory.AEStronglyMeasurable.integral_condexpKernel [NormedSpace ℝ F]
    [CompleteSpace F] (hm : m ≤ mΩ) (hf : AEStronglyMeasurable f μ) :
    AEStronglyMeasurable (fun ω => ∫ y, f y ∂condexpKernel μ m ω) μ :=
  by
  rw [condexp_kernel]
  exact
    ae_strongly_measurable.integral_cond_distrib (ae_measurable_id'' μ hm) aemeasurable_id
      (hf.comp_snd_map_prod_id hm)
#align measure_theory.ae_strongly_measurable.integral_condexp_kernel MeasureTheory.AEStronglyMeasurable.integral_condexpKernel
-/

#print ProbabilityTheory.aestronglyMeasurable'_integral_condexpKernel /-
theorem aestronglyMeasurable'_integral_condexpKernel [NormedSpace ℝ F] [CompleteSpace F]
    (hm : m ≤ mΩ) (hf : AEStronglyMeasurable f μ) :
    AEStronglyMeasurable' m (fun ω => ∫ y, f y ∂condexpKernel μ m ω) μ :=
  by
  rw [condexp_kernel]
  have h :=
    ae_strongly_measurable'_integral_cond_distrib (ae_measurable_id'' μ hm) aemeasurable_id
      (hf.comp_snd_map_prod_id hm)
  rwa [MeasurableSpace.comap_id] at h 
#align probability_theory.ae_strongly_measurable'_integral_condexp_kernel ProbabilityTheory.aestronglyMeasurable'_integral_condexpKernel
-/

end Measurability

section Integrability

#print MeasureTheory.Integrable.condexpKernel_ae /-
theorem MeasureTheory.Integrable.condexpKernel_ae (hm : m ≤ mΩ) (hf_int : Integrable f μ) :
    ∀ᵐ ω ∂μ, Integrable f (condexpKernel μ m ω) :=
  by
  rw [condexp_kernel]
  exact
    integrable.cond_distrib_ae (ae_measurable_id'' μ hm) aemeasurable_id
      (hf_int.comp_snd_map_prod_id hm)
#align measure_theory.integrable.condexp_kernel_ae MeasureTheory.Integrable.condexpKernel_ae
-/

#print MeasureTheory.Integrable.integral_norm_condexpKernel /-
theorem MeasureTheory.Integrable.integral_norm_condexpKernel (hm : m ≤ mΩ)
    (hf_int : Integrable f μ) : Integrable (fun ω => ∫ y, ‖f y‖ ∂condexpKernel μ m ω) μ :=
  by
  rw [condexp_kernel]
  exact
    integrable.integral_norm_cond_distrib (ae_measurable_id'' μ hm) aemeasurable_id
      (hf_int.comp_snd_map_prod_id hm)
#align measure_theory.integrable.integral_norm_condexp_kernel MeasureTheory.Integrable.integral_norm_condexpKernel
-/

#print MeasureTheory.Integrable.norm_integral_condexpKernel /-
theorem MeasureTheory.Integrable.norm_integral_condexpKernel [NormedSpace ℝ F] [CompleteSpace F]
    (hm : m ≤ mΩ) (hf_int : Integrable f μ) :
    Integrable (fun ω => ‖∫ y, f y ∂condexpKernel μ m ω‖) μ :=
  by
  rw [condexp_kernel]
  exact
    integrable.norm_integral_cond_distrib (ae_measurable_id'' μ hm) aemeasurable_id
      (hf_int.comp_snd_map_prod_id hm)
#align measure_theory.integrable.norm_integral_condexp_kernel MeasureTheory.Integrable.norm_integral_condexpKernel
-/

#print MeasureTheory.Integrable.integral_condexpKernel /-
theorem MeasureTheory.Integrable.integral_condexpKernel [NormedSpace ℝ F] [CompleteSpace F]
    (hm : m ≤ mΩ) (hf_int : Integrable f μ) :
    Integrable (fun ω => ∫ y, f y ∂condexpKernel μ m ω) μ :=
  by
  rw [condexp_kernel]
  exact
    integrable.integral_cond_distrib (ae_measurable_id'' μ hm) aemeasurable_id
      (hf_int.comp_snd_map_prod_id hm)
#align measure_theory.integrable.integral_condexp_kernel MeasureTheory.Integrable.integral_condexpKernel
-/

#print ProbabilityTheory.integrable_toReal_condexpKernel /-
theorem integrable_toReal_condexpKernel (hm : m ≤ mΩ) {s : Set Ω} (hs : MeasurableSet s) :
    Integrable (fun ω => (condexpKernel μ m ω s).toReal) μ :=
  by
  rw [condexp_kernel]
  exact integrable_to_real_cond_distrib (ae_measurable_id'' μ hm) hs
#align probability_theory.integrable_to_real_condexp_kernel ProbabilityTheory.integrable_toReal_condexpKernel
-/

end Integrability

#print ProbabilityTheory.condexp_ae_eq_integral_condexpKernel /-
/-- The conditional expectation of `f` with respect to a σ-algebra `m` is almost everywhere equal to
the integral `∫ y, f y ∂(condexp_kernel μ m ω)`. -/
theorem condexp_ae_eq_integral_condexpKernel [NormedSpace ℝ F] [CompleteSpace F] (hm : m ≤ mΩ)
    (hf_int : Integrable f μ) : μ[f|m] =ᵐ[μ] fun ω => ∫ y, f y ∂condexpKernel μ m ω :=
  by
  have hX : @Measurable Ω Ω mΩ m id := measurable_id.mono le_rfl hm
  rw [condexp_kernel]
  refine' eventually_eq.trans _ (condexp_ae_eq_integral_cond_distrib_id hX hf_int)
  simp only [MeasurableSpace.comap_id, id.def]
#align probability_theory.condexp_ae_eq_integral_condexp_kernel ProbabilityTheory.condexp_ae_eq_integral_condexpKernel
-/

end ProbabilityTheory

