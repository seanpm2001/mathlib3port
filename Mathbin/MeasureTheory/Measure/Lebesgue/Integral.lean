/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Sébastien Gouëzel, Yury Kudryashov

! This file was ported from Lean 3 source module measure_theory.measure.lebesgue.integral
! leanprover-community/mathlib commit 6b31d1eebd64eab86d5bd9936bfaada6ca8b5842
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Integral.SetIntegral
import Mathbin.MeasureTheory.Measure.Lebesgue.Basic

/-! # Properties of integration with respect to the Lebesgue measure 

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.-/


open Set Filter MeasureTheory MeasureTheory.Measure TopologicalSpace

section regionBetween

variable {α : Type _}

variable [MeasurableSpace α] {μ : Measure α} {f g : α → ℝ} {s : Set α}

#print volume_regionBetween_eq_integral' /-
theorem volume_regionBetween_eq_integral' [SigmaFinite μ] (f_int : IntegrableOn f s μ)
    (g_int : IntegrableOn g s μ) (hs : MeasurableSet s) (hfg : f ≤ᵐ[μ.restrict s] g) :
    μ.Prod volume (regionBetween f g s) = ENNReal.ofReal (∫ y in s, (g - f) y ∂μ) :=
  by
  have h : g - f =ᵐ[μ.restrict s] fun x => Real.toNNReal (g x - f x) :=
    hfg.mono fun x hx => (Real.coe_toNNReal _ <| sub_nonneg.2 hx).symm
  rw [volume_regionBetween_eq_lintegral f_int.ae_measurable g_int.ae_measurable hs,
    integral_congr_ae h, lintegral_congr_ae,
    lintegral_coe_eq_integral _ ((integrable_congr h).mp (g_int.sub f_int))]
  simpa only
#align volume_region_between_eq_integral' volume_regionBetween_eq_integral'
-/

#print volume_regionBetween_eq_integral /-
/-- If two functions are integrable on a measurable set, and one function is less than
    or equal to the other on that set, then the volume of the region
    between the two functions can be represented as an integral. -/
theorem volume_regionBetween_eq_integral [SigmaFinite μ] (f_int : IntegrableOn f s μ)
    (g_int : IntegrableOn g s μ) (hs : MeasurableSet s) (hfg : ∀ x ∈ s, f x ≤ g x) :
    μ.Prod volume (regionBetween f g s) = ENNReal.ofReal (∫ y in s, (g - f) y ∂μ) :=
  volume_regionBetween_eq_integral' f_int g_int hs
    ((ae_restrict_iff' hs).mpr (eventually_of_forall hfg))
#align volume_region_between_eq_integral volume_regionBetween_eq_integral
-/

end regionBetween

section SummableNormIcc

open ContinuousMap

#print Real.integrable_of_summable_norm_Icc /-
/- The following lemma is a minor variation on `integrable_of_summable_norm_restrict` in
`measure_theory.integral.set_integral`, but it is placed here because it needs to know that
`Icc a b` has volume `b - a`. -/
/-- If the sequence with `n`-th term the the sup norm of `λ x, f (x + n)` on the interval `Icc 0 1`,
for `n ∈ ℤ`, is summable, then `f` is integrable on `ℝ`. -/
theorem Real.integrable_of_summable_norm_Icc {E : Type _} [NormedAddCommGroup E] {f : C(ℝ, E)}
    (hf : Summable fun n : ℤ => ‖(f.comp <| ContinuousMap.addRight n).restrict (Icc 0 1)‖) :
    Integrable f :=
  by
  refine'
    integrable_of_summable_norm_restrict
      (summable_of_nonneg_of_le
        (fun n : ℤ =>
          mul_nonneg (norm_nonneg (f.restrict (⟨Icc n (n + 1), is_compact_Icc⟩ : compacts ℝ)))
            ENNReal.toReal_nonneg)
        (fun n => _) hf)
      (iUnion_Icc_int_cast ℝ)
  simp only [compacts.coe_mk, Real.volume_Icc, add_sub_cancel', ENNReal.toReal_ofReal zero_le_one,
    mul_one, norm_le _ (norm_nonneg _)]
  intro x
  have :=
    ((f.comp <| ContinuousMap.addRight n).restrict (Icc 0 1)).norm_coe_le_norm
      ⟨x - n, ⟨sub_nonneg.mpr x.2.1, sub_le_iff_le_add'.mpr x.2.2⟩⟩
  simpa only [ContinuousMap.restrict_apply, comp_apply, coe_add_right, Subtype.coe_mk,
    sub_add_cancel] using this
#align real.integrable_of_summable_norm_Icc Real.integrable_of_summable_norm_Icc
-/

end SummableNormIcc

/-!
### Substituting `-x` for `x`

These lemmas are stated in terms of either `Iic` or `Ioi` (neglecting `Iio` and `Ici`) to match
mathlib's conventions for integrals over finite intervals (see `interval_integral`). For the case
of finite integrals, see `interval_integral.integral_comp_neg`.
-/


#print integral_comp_neg_Iic /-
@[simp]
theorem integral_comp_neg_Iic {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [CompleteSpace E] (c : ℝ) (f : ℝ → E) : ∫ x in Iic c, f (-x) = ∫ x in Ioi (-c), f x :=
  by
  have A : MeasurableEmbedding fun x : ℝ => -x :=
    (Homeomorph.neg ℝ).ClosedEmbedding.MeasurableEmbedding
  have := A.set_integral_map f (Ici (-c))
  rw [measure.map_neg_eq_self (volume : Measure ℝ)] at this 
  simp_rw [← integral_Ici_eq_integral_Ioi, this, neg_preimage, preimage_neg_Ici, neg_neg]
#align integral_comp_neg_Iic integral_comp_neg_Iic
-/

#print integral_comp_neg_Ioi /-
@[simp]
theorem integral_comp_neg_Ioi {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [CompleteSpace E] (c : ℝ) (f : ℝ → E) : ∫ x in Ioi c, f (-x) = ∫ x in Iic (-c), f x :=
  by
  rw [← neg_neg c, ← integral_comp_neg_Iic]
  simp only [neg_neg]
#align integral_comp_neg_Ioi integral_comp_neg_Ioi
-/

