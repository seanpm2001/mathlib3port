/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module measure_theory.measure.lebesgue.complex
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Constructions.BorelSpace.Complex
import Mathbin.MeasureTheory.Measure.Lebesgue.Basic
import Mathbin.MeasureTheory.Measure.Haar.OfBasis

/-!
# Lebesgue measure on `ℂ`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define Lebesgue measure on `ℂ`. Since `ℂ` is defined as a `structure` as the
push-forward of the volume on `ℝ²` under the natural isomorphism. There are (at least) two
frequently used ways to represent `ℝ²` in `mathlib`: `ℝ × ℝ` and `fin 2 → ℝ`. We define measurable
equivalences (`measurable_equiv`) to both types and prove that both of them are volume preserving
(in the sense of `measure_theory.measure_preserving`).
-/


open MeasureTheory

noncomputable section

namespace Complex

#print Complex.measureSpace /-
/-- Lebesgue measure on `ℂ`. -/
instance measureSpace : MeasureSpace ℂ :=
  ⟨Measure.map basisOneI.equivFun.symm volume⟩
#align complex.measure_space Complex.measureSpace
-/

#print Complex.measurableEquivPi /-
/-- Measurable equivalence between `ℂ` and `ℝ² = fin 2 → ℝ`. -/
def measurableEquivPi : ℂ ≃ᵐ (Fin 2 → ℝ) :=
  basisOneI.equivFun.toContinuousLinearEquiv.toHomeomorph.toMeasurableEquiv
#align complex.measurable_equiv_pi Complex.measurableEquivPi
-/

#print Complex.measurableEquivRealProd /-
/-- Measurable equivalence between `ℂ` and `ℝ × ℝ`. -/
def measurableEquivRealProd : ℂ ≃ᵐ ℝ × ℝ :=
  equivRealProdClm.toHomeomorph.toMeasurableEquiv
#align complex.measurable_equiv_real_prod Complex.measurableEquivRealProd
-/

#print Complex.volume_preserving_equiv_pi /-
theorem volume_preserving_equiv_pi : MeasurePreserving measurableEquivPi :=
  (measurableEquivPi.symm.Measurable.MeasurePreserving _).symm _
#align complex.volume_preserving_equiv_pi Complex.volume_preserving_equiv_pi
-/

#print Complex.volume_preserving_equiv_real_prod /-
theorem volume_preserving_equiv_real_prod : MeasurePreserving measurableEquivRealProd :=
  (volume_preserving_finTwoArrow ℝ).comp volume_preserving_equiv_pi
#align complex.volume_preserving_equiv_real_prod Complex.volume_preserving_equiv_real_prod
-/

end Complex

