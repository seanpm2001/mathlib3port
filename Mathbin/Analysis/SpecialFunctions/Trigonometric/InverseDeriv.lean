/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Abhimanyu Pallavi Sudhir, Jean Lo, Calle Sönne, Benjamin Davidson
-/
import Mathbin.Analysis.SpecialFunctions.Trigonometric.Inverse
import Mathbin.Analysis.SpecialFunctions.Trigonometric.Deriv

/-!
# derivatives of the inverse trigonometric functions

Derivatives of `arcsin` and `arccos`.
-/


noncomputable section

open Classical TopologicalSpace Filter

open Set Filter

open Real

namespace Real

section Arcsin

theorem deriv_arcsin_aux {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasStrictDerivAt arcsin (1 / sqrt (1 - x ^ 2)) x ∧ ContDiffAt ℝ ⊤ arcsin x := by
  cases' h₁.lt_or_lt with h₁ h₁
  · have : 1 - x ^ 2 < 0 := by nlinarith [h₁]
    rw [sqrt_eq_zero'.2 this.le, div_zero]
    have : arcsin =ᶠ[𝓝 x] fun _ => -(π / 2) :=
      (gt_mem_nhds h₁).mono fun y hy => arcsin_of_le_neg_one hy.le
    exact
      ⟨(hasStrictDerivAtConst _ _).congr_of_eventually_eq this.symm,
        cont_diff_at_const.congr_of_eventually_eq this⟩
  cases' h₂.lt_or_lt with h₂ h₂
  · have : 0 < sqrt (1 - x ^ 2) := sqrt_pos.2 (by nlinarith [h₁, h₂])
    simp only [← cos_arcsin, one_div] at this⊢
    exact
      ⟨sin_local_homeomorph.has_strict_deriv_at_symm ⟨h₁, h₂⟩ this.ne' (has_strict_deriv_at_sin _),
        sin_local_homeomorph.cont_diff_at_symm_deriv this.ne' ⟨h₁, h₂⟩ (has_deriv_at_sin _)
          cont_diff_sin.cont_diff_at⟩
  · have : 1 - x ^ 2 < 0 := by nlinarith [h₂]
    rw [sqrt_eq_zero'.2 this.le, div_zero]
    have : arcsin =ᶠ[𝓝 x] fun _ => π / 2 := (lt_mem_nhds h₂).mono fun y hy => arcsin_of_one_le hy.le
    exact
      ⟨(hasStrictDerivAtConst _ _).congr_of_eventually_eq this.symm,
        cont_diff_at_const.congr_of_eventually_eq this⟩
#align real.deriv_arcsin_aux Real.deriv_arcsin_aux

theorem hasStrictDerivAtArcsin {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasStrictDerivAt arcsin (1 / sqrt (1 - x ^ 2)) x :=
  (deriv_arcsin_aux h₁ h₂).1
#align real.has_strict_deriv_at_arcsin Real.hasStrictDerivAtArcsin

theorem hasDerivAtArcsin {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasDerivAt arcsin (1 / sqrt (1 - x ^ 2)) x :=
  (hasStrictDerivAtArcsin h₁ h₂).HasDerivAt
#align real.has_deriv_at_arcsin Real.hasDerivAtArcsin

theorem contDiffAtArcsin {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) {n : ℕ∞} : ContDiffAt ℝ n arcsin x :=
  (deriv_arcsin_aux h₁ h₂).2.of_le le_top
#align real.cont_diff_at_arcsin Real.contDiffAtArcsin

theorem hasDerivWithinAtArcsinIci {x : ℝ} (h : x ≠ -1) :
    HasDerivWithinAt arcsin (1 / sqrt (1 - x ^ 2)) (ici x) x := by
  rcases em (x = 1) with (rfl | h')
  ·
    convert (hasDerivWithinAtConst _ _ (π / 2)).congr _ _ <;>
      simp (config := { contextual := true }) [arcsin_of_one_le]
  · exact (has_deriv_at_arcsin h h').HasDerivWithinAt
#align real.has_deriv_within_at_arcsin_Ici Real.hasDerivWithinAtArcsinIci

theorem hasDerivWithinAtArcsinIic {x : ℝ} (h : x ≠ 1) :
    HasDerivWithinAt arcsin (1 / sqrt (1 - x ^ 2)) (iic x) x := by
  rcases em (x = -1) with (rfl | h')
  ·
    convert (hasDerivWithinAtConst _ _ (-(π / 2))).congr _ _ <;>
      simp (config := { contextual := true }) [arcsin_of_le_neg_one]
  · exact (has_deriv_at_arcsin h' h).HasDerivWithinAt
#align real.has_deriv_within_at_arcsin_Iic Real.hasDerivWithinAtArcsinIic

theorem differentiable_within_at_arcsin_Ici {x : ℝ} :
    DifferentiableWithinAt ℝ arcsin (ici x) x ↔ x ≠ -1 := by
  refine' ⟨_, fun h => (has_deriv_within_at_arcsin_Ici h).DifferentiableWithinAt⟩
  rintro h rfl
  have : sin ∘ arcsin =ᶠ[𝓝[≥] (-1 : ℝ)] id := by
    filter_upwards [Icc_mem_nhds_within_Ici
        ⟨le_rfl, neg_lt_self (zero_lt_one' ℝ)⟩] with x using sin_arcsin'
  have := h.has_deriv_within_at.sin.congr_of_eventually_eq this.symm (by simp)
  simpa using (uniqueDiffOnIci _ _ left_mem_Ici).eq_deriv _ this (hasDerivWithinAtId _ _)
#align real.differentiable_within_at_arcsin_Ici Real.differentiable_within_at_arcsin_Ici

theorem differentiable_within_at_arcsin_Iic {x : ℝ} :
    DifferentiableWithinAt ℝ arcsin (iic x) x ↔ x ≠ 1 := by
  refine' ⟨fun h => _, fun h => (has_deriv_within_at_arcsin_Iic h).DifferentiableWithinAt⟩
  rw [← neg_neg x, ← image_neg_Ici] at h
  have := (h.comp (-x) differentiable_within_at_id.neg (maps_to_image _ _)).neg
  simpa [(· ∘ ·), differentiable_within_at_arcsin_Ici] using this
#align real.differentiable_within_at_arcsin_Iic Real.differentiable_within_at_arcsin_Iic

theorem differentiable_at_arcsin {x : ℝ} : DifferentiableAt ℝ arcsin x ↔ x ≠ -1 ∧ x ≠ 1 :=
  ⟨fun h =>
    ⟨differentiable_within_at_arcsin_Ici.1 h.DifferentiableWithinAt,
      differentiable_within_at_arcsin_Iic.1 h.DifferentiableWithinAt⟩,
    fun h => (hasDerivAtArcsin h.1 h.2).DifferentiableAt⟩
#align real.differentiable_at_arcsin Real.differentiable_at_arcsin

@[simp]
theorem deriv_arcsin : deriv arcsin = fun x => 1 / sqrt (1 - x ^ 2) := by
  funext x
  by_cases h : x ≠ -1 ∧ x ≠ 1
  · exact (has_deriv_at_arcsin h.1 h.2).deriv
  · rw [deriv_zero_of_not_differentiable_at (mt differentiable_at_arcsin.1 h)]
    simp only [not_and_or, Ne.def, not_not] at h
    rcases h with (rfl | rfl) <;> simp
#align real.deriv_arcsin Real.deriv_arcsin

theorem differentiableOnArcsin : DifferentiableOn ℝ arcsin ({-1, 1}ᶜ) := fun x hx =>
  (differentiable_at_arcsin.2
      ⟨fun h => hx (Or.inl h), fun h => hx (Or.inr h)⟩).DifferentiableWithinAt
#align real.differentiable_on_arcsin Real.differentiableOnArcsin

theorem contDiffOnArcsin {n : ℕ∞} : ContDiffOn ℝ n arcsin ({-1, 1}ᶜ) := fun x hx =>
  (contDiffAtArcsin (mt Or.inl hx) (mt Or.inr hx)).ContDiffWithinAt
#align real.cont_diff_on_arcsin Real.contDiffOnArcsin

theorem cont_diff_at_arcsin_iff {x : ℝ} {n : ℕ∞} :
    ContDiffAt ℝ n arcsin x ↔ n = 0 ∨ x ≠ -1 ∧ x ≠ 1 :=
  ⟨fun h =>
    or_iff_not_imp_left.2 fun hn =>
      differentiable_at_arcsin.1 <| h.DifferentiableAt <| Enat.one_le_iff_ne_zero.2 hn,
    fun h =>
    (h.elim fun hn => hn.symm ▸ (cont_diff_zero.2 continuous_arcsin).ContDiffAt) fun hx =>
      contDiffAtArcsin hx.1 hx.2⟩
#align real.cont_diff_at_arcsin_iff Real.cont_diff_at_arcsin_iff

end Arcsin

section Arccos

theorem hasStrictDerivAtArccos {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasStrictDerivAt arccos (-(1 / sqrt (1 - x ^ 2))) x :=
  (hasStrictDerivAtArcsin h₁ h₂).const_sub (π / 2)
#align real.has_strict_deriv_at_arccos Real.hasStrictDerivAtArccos

theorem hasDerivAtArccos {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) :
    HasDerivAt arccos (-(1 / sqrt (1 - x ^ 2))) x :=
  (hasDerivAtArcsin h₁ h₂).const_sub (π / 2)
#align real.has_deriv_at_arccos Real.hasDerivAtArccos

theorem contDiffAtArccos {x : ℝ} (h₁ : x ≠ -1) (h₂ : x ≠ 1) {n : ℕ∞} : ContDiffAt ℝ n arccos x :=
  contDiffAtConst.sub (contDiffAtArcsin h₁ h₂)
#align real.cont_diff_at_arccos Real.contDiffAtArccos

theorem hasDerivWithinAtArccosIci {x : ℝ} (h : x ≠ -1) :
    HasDerivWithinAt arccos (-(1 / sqrt (1 - x ^ 2))) (ici x) x :=
  (hasDerivWithinAtArcsinIci h).const_sub _
#align real.has_deriv_within_at_arccos_Ici Real.hasDerivWithinAtArccosIci

theorem hasDerivWithinAtArccosIic {x : ℝ} (h : x ≠ 1) :
    HasDerivWithinAt arccos (-(1 / sqrt (1 - x ^ 2))) (iic x) x :=
  (hasDerivWithinAtArcsinIic h).const_sub _
#align real.has_deriv_within_at_arccos_Iic Real.hasDerivWithinAtArccosIic

theorem differentiable_within_at_arccos_Ici {x : ℝ} :
    DifferentiableWithinAt ℝ arccos (ici x) x ↔ x ≠ -1 :=
  (differentiable_within_at_const_sub_iff _).trans differentiable_within_at_arcsin_Ici
#align real.differentiable_within_at_arccos_Ici Real.differentiable_within_at_arccos_Ici

theorem differentiable_within_at_arccos_Iic {x : ℝ} :
    DifferentiableWithinAt ℝ arccos (iic x) x ↔ x ≠ 1 :=
  (differentiable_within_at_const_sub_iff _).trans differentiable_within_at_arcsin_Iic
#align real.differentiable_within_at_arccos_Iic Real.differentiable_within_at_arccos_Iic

theorem differentiable_at_arccos {x : ℝ} : DifferentiableAt ℝ arccos x ↔ x ≠ -1 ∧ x ≠ 1 :=
  (differentiable_at_const_sub_iff _).trans differentiable_at_arcsin
#align real.differentiable_at_arccos Real.differentiable_at_arccos

@[simp]
theorem deriv_arccos : deriv arccos = fun x => -(1 / sqrt (1 - x ^ 2)) :=
  funext fun x => (deriv_const_sub _).trans <| by simp only [deriv_arcsin]
#align real.deriv_arccos Real.deriv_arccos

theorem differentiableOnArccos : DifferentiableOn ℝ arccos ({-1, 1}ᶜ) :=
  differentiableOnArcsin.const_sub _
#align real.differentiable_on_arccos Real.differentiableOnArccos

theorem contDiffOnArccos {n : ℕ∞} : ContDiffOn ℝ n arccos ({-1, 1}ᶜ) :=
  contDiffOnConst.sub contDiffOnArcsin
#align real.cont_diff_on_arccos Real.contDiffOnArccos

theorem cont_diff_at_arccos_iff {x : ℝ} {n : ℕ∞} :
    ContDiffAt ℝ n arccos x ↔ n = 0 ∨ x ≠ -1 ∧ x ≠ 1 := by
  refine' Iff.trans ⟨fun h => _, fun h => _⟩ cont_diff_at_arcsin_iff <;>
    simpa [arccos] using (@contDiffAtConst _ _ _ _ _ _ _ _ _ _ (π / 2)).sub h
#align real.cont_diff_at_arccos_iff Real.cont_diff_at_arccos_iff

end Arccos

end Real

