/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Abhimanyu Pallavi Sudhir, Jean Lo, Calle Sönne, Benjamin Davidson

! This file was ported from Lean 3 source module analysis.special_functions.trigonometric.inverse_deriv
! leanprover-community/mathlib commit 36938f775671ff28bea1c0310f1608e4afbb22e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Trigonometric.Inverse
import Mathbin.Analysis.SpecialFunctions.Trigonometric.Deriv

/-!
# derivatives of the inverse trigonometric functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Derivatives of `arcsin` and `arccos`.
-/


noncomputable section

open scoped Classical Topology Filter

open Set Filter

open scoped Real

namespace Real

section Arcsin

#print Real.deriv_arcsin_aux /-
theorem deriv_arcsin_aux {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasStrictDerivAt arcsin (1 / sqrt (1 - x ^ 2)) x ∧ ContDiffAt ℝ ⊤ arcsin x :=
  by
  cases' h₁.lt_or_lt with h₁ h₁
  · have : 1 - x ^ 2 < 0 := by nlinarith [h₁]
    rw [sqrt_eq_zero'.2 this.le, div_zero]
    have : arcsin =ᶠ[𝓝 x] fun _ => -(π / 2) :=
      (gt_mem_nhds h₁).mono fun y hy => arcsin_of_le_neg_one hy.le
    exact
      ⟨(hasStrictDerivAt_const _ _).congr_of_eventuallyEq this.symm,
        cont_diff_at_const.congr_of_eventually_eq this⟩
  cases' h₂.lt_or_lt with h₂ h₂
  · have : 0 < sqrt (1 - x ^ 2) := sqrt_pos.2 (by nlinarith [h₁, h₂])
    simp only [← cos_arcsin, one_div] at this ⊢
    exact
      ⟨sin_local_homeomorph.has_strict_deriv_at_symm ⟨h₁, h₂⟩ this.ne' (has_strict_deriv_at_sin _),
        sin_local_homeomorph.cont_diff_at_symm_deriv this.ne' ⟨h₁, h₂⟩ (has_deriv_at_sin _)
          cont_diff_sin.cont_diff_at⟩
  · have : 1 - x ^ 2 < 0 := by nlinarith [h₂]
    rw [sqrt_eq_zero'.2 this.le, div_zero]
    have : arcsin =ᶠ[𝓝 x] fun _ => π / 2 := (lt_mem_nhds h₂).mono fun y hy => arcsin_of_one_le hy.le
    exact
      ⟨(hasStrictDerivAt_const _ _).congr_of_eventuallyEq this.symm,
        cont_diff_at_const.congr_of_eventually_eq this⟩
#align real.deriv_arcsin_aux Real.deriv_arcsin_aux
-/

#print Real.hasStrictDerivAt_arcsin /-
theorem hasStrictDerivAt_arcsin {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasStrictDerivAt arcsin (1 / sqrt (1 - x ^ 2)) x :=
  (deriv_arcsin_aux h₁ h₂).1
#align real.has_strict_deriv_at_arcsin Real.hasStrictDerivAt_arcsin
-/

#print Real.hasDerivAt_arcsin /-
theorem hasDerivAt_arcsin {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasDerivAt arcsin (1 / sqrt (1 - x ^ 2)) x :=
  (hasStrictDerivAt_arcsin h₁ h₂).HasDerivAt
#align real.has_deriv_at_arcsin Real.hasDerivAt_arcsin
-/

#print Real.contDiffAt_arcsin /-
theorem contDiffAt_arcsin {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) {n : ℕ∞} : ContDiffAt ℝ n arcsin x :=
  (deriv_arcsin_aux h₁ h₂).2.of_le le_top
#align real.cont_diff_at_arcsin Real.contDiffAt_arcsin
-/

#print Real.hasDerivWithinAt_arcsin_Ici /-
theorem hasDerivWithinAt_arcsin_Ici {x : ℝ} (h : x ≠ -1) :
    HasDerivWithinAt arcsin (1 / sqrt (1 - x ^ 2)) (Ici x) x :=
  by
  rcases em (x = 1) with (rfl | h')
  ·
    convert (hasDerivWithinAt_const _ _ (π / 2)).congr _ _ <;>
      simp (config := { contextual := true }) [arcsin_of_one_le]
  · exact (has_deriv_at_arcsin h h').HasDerivWithinAt
#align real.has_deriv_within_at_arcsin_Ici Real.hasDerivWithinAt_arcsin_Ici
-/

#print Real.hasDerivWithinAt_arcsin_Iic /-
theorem hasDerivWithinAt_arcsin_Iic {x : ℝ} (h : x ≠ 1) :
    HasDerivWithinAt arcsin (1 / sqrt (1 - x ^ 2)) (Iic x) x :=
  by
  rcases em (x = -1) with (rfl | h')
  ·
    convert (hasDerivWithinAt_const _ _ (-(π / 2))).congr _ _ <;>
      simp (config := { contextual := true }) [arcsin_of_le_neg_one]
  · exact (has_deriv_at_arcsin h' h).HasDerivWithinAt
#align real.has_deriv_within_at_arcsin_Iic Real.hasDerivWithinAt_arcsin_Iic
-/

#print Real.differentiableWithinAt_arcsin_Ici /-
theorem differentiableWithinAt_arcsin_Ici {x : ℝ} :
    DifferentiableWithinAt ℝ arcsin (Ici x) x ↔ x ≠ -1 :=
  by
  refine' ⟨_, fun h => (has_deriv_within_at_arcsin_Ici h).DifferentiableWithinAt⟩
  rintro h rfl
  have : sin ∘ arcsin =ᶠ[𝓝[≥] (-1 : ℝ)] id := by
    filter_upwards [Icc_mem_nhdsWithin_Ici ⟨le_rfl, neg_lt_self (zero_lt_one' ℝ)⟩] with x using
      sin_arcsin'
  have := h.has_deriv_within_at.sin.congr_of_eventually_eq this.symm (by simp)
  simpa using (uniqueDiffOn_Ici _ _ left_mem_Ici).eq_deriv _ this (hasDerivWithinAt_id _ _)
#align real.differentiable_within_at_arcsin_Ici Real.differentiableWithinAt_arcsin_Ici
-/

#print Real.differentiableWithinAt_arcsin_Iic /-
theorem differentiableWithinAt_arcsin_Iic {x : ℝ} :
    DifferentiableWithinAt ℝ arcsin (Iic x) x ↔ x ≠ 1 :=
  by
  refine' ⟨fun h => _, fun h => (has_deriv_within_at_arcsin_Iic h).DifferentiableWithinAt⟩
  rw [← neg_neg x, ← image_neg_Ici] at h 
  have := (h.comp (-x) differentiable_within_at_id.neg (maps_to_image _ _)).neg
  simpa [(· ∘ ·), differentiable_within_at_arcsin_Ici] using this
#align real.differentiable_within_at_arcsin_Iic Real.differentiableWithinAt_arcsin_Iic
-/

#print Real.differentiableAt_arcsin /-
theorem differentiableAt_arcsin {x : ℝ} : DifferentiableAt ℝ arcsin x ↔ x ≠ -1 ∧ x ≠ 1 :=
  ⟨fun h =>
    ⟨differentiableWithinAt_arcsin_Ici.1 h.DifferentiableWithinAt,
      differentiableWithinAt_arcsin_Iic.1 h.DifferentiableWithinAt⟩,
    fun h => (hasDerivAt_arcsin h.1 h.2).DifferentiableAt⟩
#align real.differentiable_at_arcsin Real.differentiableAt_arcsin
-/

#print Real.deriv_arcsin /-
@[simp]
theorem deriv_arcsin : deriv arcsin = fun x => 1 / sqrt (1 - x ^ 2) :=
  by
  funext x
  by_cases h : x ≠ -1 ∧ x ≠ 1
  · exact (has_deriv_at_arcsin h.1 h.2).deriv
  · rw [deriv_zero_of_not_differentiableAt (mt differentiable_at_arcsin.1 h)]
    simp only [not_and_or, Ne.def, Classical.not_not] at h 
    rcases h with (rfl | rfl) <;> simp
#align real.deriv_arcsin Real.deriv_arcsin
-/

#print Real.differentiableOn_arcsin /-
theorem differentiableOn_arcsin : DifferentiableOn ℝ arcsin ({-1, 1}ᶜ) := fun x hx =>
  (differentiableAt_arcsin.2
      ⟨fun h => hx (Or.inl h), fun h => hx (Or.inr h)⟩).DifferentiableWithinAt
#align real.differentiable_on_arcsin Real.differentiableOn_arcsin
-/

#print Real.contDiffOn_arcsin /-
theorem contDiffOn_arcsin {n : ℕ∞} : ContDiffOn ℝ n arcsin ({-1, 1}ᶜ) := fun x hx =>
  (contDiffAt_arcsin (mt Or.inl hx) (mt Or.inr hx)).ContDiffWithinAt
#align real.cont_diff_on_arcsin Real.contDiffOn_arcsin
-/

#print Real.contDiffAt_arcsin_iff /-
theorem contDiffAt_arcsin_iff {x : ℝ} {n : ℕ∞} : ContDiffAt ℝ n arcsin x ↔ n = 0 ∨ x ≠ -1 ∧ x ≠ 1 :=
  ⟨fun h =>
    or_iff_not_imp_left.2 fun hn =>
      differentiableAt_arcsin.1 <| h.DifferentiableAt <| ENat.one_le_iff_ne_zero.2 hn,
    fun h =>
    h.elim (fun hn => hn.symm ▸ (contDiff_zero.2 continuous_arcsin).ContDiffAt) fun hx =>
      contDiffAt_arcsin hx.1 hx.2⟩
#align real.cont_diff_at_arcsin_iff Real.contDiffAt_arcsin_iff
-/

end Arcsin

section Arccos

#print Real.hasStrictDerivAt_arccos /-
theorem hasStrictDerivAt_arccos {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasStrictDerivAt arccos (-(1 / sqrt (1 - x ^ 2))) x :=
  (hasStrictDerivAt_arcsin h₁ h₂).const_sub (π / 2)
#align real.has_strict_deriv_at_arccos Real.hasStrictDerivAt_arccos
-/

#print Real.hasDerivAt_arccos /-
theorem hasDerivAt_arccos {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasDerivAt arccos (-(1 / sqrt (1 - x ^ 2))) x :=
  (hasDerivAt_arcsin h₁ h₂).const_sub (π / 2)
#align real.has_deriv_at_arccos Real.hasDerivAt_arccos
-/

#print Real.contDiffAt_arccos /-
theorem contDiffAt_arccos {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) {n : ℕ∞} : ContDiffAt ℝ n arccos x :=
  contDiffAt_const.sub (contDiffAt_arcsin h₁ h₂)
#align real.cont_diff_at_arccos Real.contDiffAt_arccos
-/

#print Real.hasDerivWithinAt_arccos_Ici /-
theorem hasDerivWithinAt_arccos_Ici {x : ℝ} (h : x ≠ -1) :
    HasDerivWithinAt arccos (-(1 / sqrt (1 - x ^ 2))) (Ici x) x :=
  (hasDerivWithinAt_arcsin_Ici h).const_sub _
#align real.has_deriv_within_at_arccos_Ici Real.hasDerivWithinAt_arccos_Ici
-/

#print Real.hasDerivWithinAt_arccos_Iic /-
theorem hasDerivWithinAt_arccos_Iic {x : ℝ} (h : x ≠ 1) :
    HasDerivWithinAt arccos (-(1 / sqrt (1 - x ^ 2))) (Iic x) x :=
  (hasDerivWithinAt_arcsin_Iic h).const_sub _
#align real.has_deriv_within_at_arccos_Iic Real.hasDerivWithinAt_arccos_Iic
-/

#print Real.differentiableWithinAt_arccos_Ici /-
theorem differentiableWithinAt_arccos_Ici {x : ℝ} :
    DifferentiableWithinAt ℝ arccos (Ici x) x ↔ x ≠ -1 :=
  (differentiableWithinAt_const_sub_iff _).trans differentiableWithinAt_arcsin_Ici
#align real.differentiable_within_at_arccos_Ici Real.differentiableWithinAt_arccos_Ici
-/

#print Real.differentiableWithinAt_arccos_Iic /-
theorem differentiableWithinAt_arccos_Iic {x : ℝ} :
    DifferentiableWithinAt ℝ arccos (Iic x) x ↔ x ≠ 1 :=
  (differentiableWithinAt_const_sub_iff _).trans differentiableWithinAt_arcsin_Iic
#align real.differentiable_within_at_arccos_Iic Real.differentiableWithinAt_arccos_Iic
-/

#print Real.differentiableAt_arccos /-
theorem differentiableAt_arccos {x : ℝ} : DifferentiableAt ℝ arccos x ↔ x ≠ -1 ∧ x ≠ 1 :=
  (differentiableAt_const_sub_iff _).trans differentiableAt_arcsin
#align real.differentiable_at_arccos Real.differentiableAt_arccos
-/

#print Real.deriv_arccos /-
@[simp]
theorem deriv_arccos : deriv arccos = fun x => -(1 / sqrt (1 - x ^ 2)) :=
  funext fun x => (deriv_const_sub _).trans <| by simp only [deriv_arcsin]
#align real.deriv_arccos Real.deriv_arccos
-/

#print Real.differentiableOn_arccos /-
theorem differentiableOn_arccos : DifferentiableOn ℝ arccos ({-1, 1}ᶜ) :=
  differentiableOn_arcsin.const_sub _
#align real.differentiable_on_arccos Real.differentiableOn_arccos
-/

#print Real.contDiffOn_arccos /-
theorem contDiffOn_arccos {n : ℕ∞} : ContDiffOn ℝ n arccos ({-1, 1}ᶜ) :=
  contDiffOn_const.sub contDiffOn_arcsin
#align real.cont_diff_on_arccos Real.contDiffOn_arccos
-/

#print Real.contDiffAt_arccos_iff /-
theorem contDiffAt_arccos_iff {x : ℝ} {n : ℕ∞} : ContDiffAt ℝ n arccos x ↔ n = 0 ∨ x ≠ -1 ∧ x ≠ 1 :=
  by
  refine' Iff.trans ⟨fun h => _, fun h => _⟩ cont_diff_at_arcsin_iff <;>
    simpa [arccos] using (@contDiffAt_const _ _ _ _ _ _ _ _ _ _ (π / 2)).sub h
#align real.cont_diff_at_arccos_iff Real.contDiffAt_arccos_iff
-/

end Arccos

end Real

