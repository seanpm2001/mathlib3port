/-
Copyright (c) 2021 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying

! This file was ported from Lean 3 source module measure_theory.measure.complex
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.VectorMeasure

/-!
# Complex measure

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves some elementary results about complex measures. In particular, we prove that
a complex measure is always in the form `s + it` where `s` and `t` are signed measures.

The complex measure is defined to be vector measure over `ℂ`, this definition can be found
in `measure_theory.measure.vector_measure` and is known as `measure_theory.complex_measure`.

## Main definitions

* `measure_theory.complex_measure.re`: obtains a signed measure `s` from a complex measure `c`
  such that `s i = (c i).re` for all measurable sets `i`.
* `measure_theory.complex_measure.im`: obtains a signed measure `s` from a complex measure `c`
  such that `s i = (c i).im` for all measurable sets `i`.
* `measure_theory.signed_measure.to_complex_measure`: given two signed measures `s` and `t`,
  `s.to_complex_measure t` provides a complex measure of the form `s + it`.
* `measure_theory.complex_measure.equiv_signed_measure`: is the equivalence between the complex
  measures and the type of the product of the signed measures with itself.

# Tags

Complex measure
-/


noncomputable section

open scoped Classical MeasureTheory ENNReal NNReal

variable {α β : Type _} {m : MeasurableSpace α}

namespace MeasureTheory

open VectorMeasure

namespace ComplexMeasure

#print MeasureTheory.ComplexMeasure.re /-
/-- The real part of a complex measure is a signed measure. -/
@[simps apply]
def re : ComplexMeasure α →ₗ[ℝ] SignedMeasure α :=
  mapRangeₗ Complex.reClm Complex.continuous_re
#align measure_theory.complex_measure.re MeasureTheory.ComplexMeasure.re
-/

#print MeasureTheory.ComplexMeasure.im /-
/-- The imaginary part of a complex measure is a signed measure. -/
@[simps apply]
def im : ComplexMeasure α →ₗ[ℝ] SignedMeasure α :=
  mapRangeₗ Complex.imClm Complex.continuous_im
#align measure_theory.complex_measure.im MeasureTheory.ComplexMeasure.im
-/

#print MeasureTheory.SignedMeasure.toComplexMeasure /-
/-- Given `s` and `t` signed measures, `s + it` is a complex measure-/
@[simps]
def MeasureTheory.SignedMeasure.toComplexMeasure (s t : SignedMeasure α) : ComplexMeasure α
    where
  measureOf' i := ⟨s i, t i⟩
  empty' := by rw [s.empty, t.empty] <;> rfl
  not_measurable' i hi := by rw [s.not_measurable hi, t.not_measurable hi] <;> rfl
  m_iUnion' f hf hfdisj := (Complex.hasSum_iff _ _).2 ⟨s.m_iUnion hf hfdisj, t.m_iUnion hf hfdisj⟩
#align measure_theory.signed_measure.to_complex_measure MeasureTheory.SignedMeasure.toComplexMeasure
-/

#print MeasureTheory.SignedMeasure.toComplexMeasure_apply /-
theorem MeasureTheory.SignedMeasure.toComplexMeasure_apply {s t : SignedMeasure α} {i : Set α} :
    s.toComplexMeasure t i = ⟨s i, t i⟩ :=
  rfl
#align measure_theory.signed_measure.to_complex_measure_apply MeasureTheory.SignedMeasure.toComplexMeasure_apply
-/

#print MeasureTheory.ComplexMeasure.toComplexMeasure_to_signedMeasure /-
theorem toComplexMeasure_to_signedMeasure (c : ComplexMeasure α) : c.re.toComplexMeasure c.im = c :=
  by ext i hi <;> rfl
#align measure_theory.complex_measure.to_complex_measure_to_signed_measure MeasureTheory.ComplexMeasure.toComplexMeasure_to_signedMeasure
-/

#print MeasureTheory.SignedMeasure.re_toComplexMeasure /-
theorem MeasureTheory.SignedMeasure.re_toComplexMeasure (s t : SignedMeasure α) :
    (s.toComplexMeasure t).re = s := by ext i hi; rfl
#align measure_theory.signed_measure.re_to_complex_measure MeasureTheory.SignedMeasure.re_toComplexMeasure
-/

#print MeasureTheory.SignedMeasure.im_toComplexMeasure /-
theorem MeasureTheory.SignedMeasure.im_toComplexMeasure (s t : SignedMeasure α) :
    (s.toComplexMeasure t).im = t := by ext i hi; rfl
#align measure_theory.signed_measure.im_to_complex_measure MeasureTheory.SignedMeasure.im_toComplexMeasure
-/

#print MeasureTheory.ComplexMeasure.equivSignedMeasure /-
/-- The complex measures form an equivalence to the type of pairs of signed measures. -/
@[simps]
def equivSignedMeasure : ComplexMeasure α ≃ SignedMeasure α × SignedMeasure α
    where
  toFun c := ⟨c.re, c.im⟩
  invFun := fun ⟨s, t⟩ => s.toComplexMeasure t
  left_inv c := c.toComplexMeasure_to_signedMeasure
  right_inv := fun ⟨s, t⟩ => Prod.mk.inj_iff.2 ⟨s.re_toComplexMeasure t, s.im_toComplexMeasure t⟩
#align measure_theory.complex_measure.equiv_signed_measure MeasureTheory.ComplexMeasure.equivSignedMeasure
-/

section

variable {R : Type _} [Semiring R] [Module R ℝ]

variable [ContinuousConstSMul R ℝ] [ContinuousConstSMul R ℂ]

#print MeasureTheory.ComplexMeasure.equivSignedMeasureₗ /-
/-- The complex measures form an linear isomorphism to the type of pairs of signed measures. -/
@[simps]
def equivSignedMeasureₗ : ComplexMeasure α ≃ₗ[R] SignedMeasure α × SignedMeasure α :=
  { equivSignedMeasure with
    map_add' := fun c d => by ext i hi <;> rfl
    map_smul' := by
      intro r c; ext i hi
      · change (r • c i).re = r • (c i).re
        simp [Complex.smul_re]
      · ext i hi
        change (r • c i).im = r • (c i).im
        simp [Complex.smul_im] }
#align measure_theory.complex_measure.equiv_signed_measureₗ MeasureTheory.ComplexMeasure.equivSignedMeasureₗ
-/

end

#print MeasureTheory.ComplexMeasure.absolutelyContinuous_ennreal_iff /-
theorem absolutelyContinuous_ennreal_iff (c : ComplexMeasure α) (μ : VectorMeasure α ℝ≥0∞) :
    c ≪ᵥ μ ↔ c.re ≪ᵥ μ ∧ c.im ≪ᵥ μ := by
  constructor <;> intro h
  · constructor <;> · intro i hi; simp [h hi]
  · intro i hi
    rw [← Complex.re_add_im (c i), (_ : (c i).re = 0), (_ : (c i).im = 0)]
    exacts [by simp, h.2 hi, h.1 hi]
#align measure_theory.complex_measure.absolutely_continuous_ennreal_iff MeasureTheory.ComplexMeasure.absolutelyContinuous_ennreal_iff
-/

end ComplexMeasure

end MeasureTheory

