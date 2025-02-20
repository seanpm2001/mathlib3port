/-
Copyright (c) 2023 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying

! This file was ported from Lean 3 source module probability.kernel.invariance
! leanprover-community/mathlib commit 2a0ce625dbb0ffbc7d1316597de0b25c1ec75303
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.Kernel.Composition

/-!
# Invariance of measures along a kernel

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We say that a measure `μ` is invariant with respect to a kernel `κ` if its push-forward along the
kernel `μ.bind κ` is the same measure.

## Main definitions

* `probability_theory.kernel.invariant`: invariance of a given measure with respect to a kernel.

## Useful lemmas

* `probability_theory.kernel.const_bind_eq_comp_const`, and
  `probability_theory.kernel.comp_const_apply_eq_bind` established the relationship between
  the push-forward measure and the composition of kernels.

-/


open MeasureTheory

open scoped MeasureTheory ENNReal ProbabilityTheory

namespace ProbabilityTheory

variable {α β γ : Type _} {mα : MeasurableSpace α} {mβ : MeasurableSpace β} {mγ : MeasurableSpace γ}

namespace Kernel

/-! ### Push-forward of measures along a kernel -/


#print ProbabilityTheory.kernel.bind_add /-
@[simp]
theorem bind_add (μ ν : Measure α) (κ : kernel α β) : (μ + ν).bind κ = μ.bind κ + ν.bind κ :=
  by
  ext1 s hs
  rw [measure.bind_apply hs (kernel.measurable _), lintegral_add_measure, measure.coe_add,
    Pi.add_apply, measure.bind_apply hs (kernel.measurable _),
    measure.bind_apply hs (kernel.measurable _)]
#align probability_theory.kernel.bind_add ProbabilityTheory.kernel.bind_add
-/

#print ProbabilityTheory.kernel.bind_smul /-
@[simp]
theorem bind_smul (κ : kernel α β) (μ : Measure α) (r : ℝ≥0∞) : (r • μ).bind κ = r • μ.bind κ :=
  by
  ext1 s hs
  rw [measure.bind_apply hs (kernel.measurable _), lintegral_smul_measure, measure.coe_smul,
    Pi.smul_apply, measure.bind_apply hs (kernel.measurable _), smul_eq_mul]
#align probability_theory.kernel.bind_smul ProbabilityTheory.kernel.bind_smul
-/

#print ProbabilityTheory.kernel.const_bind_eq_comp_const /-
theorem const_bind_eq_comp_const (κ : kernel α β) (μ : Measure α) :
    const α (μ.bind κ) = κ ∘ₖ const α μ :=
  by
  ext a s hs : 2
  simp_rw [comp_apply' _ _ _ hs, const_apply, measure.bind_apply hs (kernel.measurable _)]
#align probability_theory.kernel.const_bind_eq_comp_const ProbabilityTheory.kernel.const_bind_eq_comp_const
-/

#print ProbabilityTheory.kernel.comp_const_apply_eq_bind /-
theorem comp_const_apply_eq_bind (κ : kernel α β) (μ : Measure α) (a : α) :
    (κ ∘ₖ const α μ) a = μ.bind κ := by
  rw [← const_apply (μ.bind κ) a, const_bind_eq_comp_const κ μ]
#align probability_theory.kernel.comp_const_apply_eq_bind ProbabilityTheory.kernel.comp_const_apply_eq_bind
-/

/-! ### Invariant measures of kernels -/


#print ProbabilityTheory.kernel.Invariant /-
/-- A measure `μ` is invariant with respect to the kernel `κ` if the push-forward measure of `μ`
along `κ` equals `μ`. -/
def Invariant (κ : kernel α α) (μ : Measure α) : Prop :=
  μ.bind κ = μ
#align probability_theory.kernel.invariant ProbabilityTheory.kernel.Invariant
-/

variable {κ η : kernel α α} {μ : Measure α}

#print ProbabilityTheory.kernel.Invariant.def /-
theorem Invariant.def (hκ : Invariant κ μ) : μ.bind κ = μ :=
  hκ
#align probability_theory.kernel.invariant.def ProbabilityTheory.kernel.Invariant.def
-/

#print ProbabilityTheory.kernel.Invariant.comp_const /-
theorem Invariant.comp_const (hκ : Invariant κ μ) : κ ∘ₖ const α μ = const α μ := by
  rw [← const_bind_eq_comp_const κ μ, hκ.def]
#align probability_theory.kernel.invariant.comp_const ProbabilityTheory.kernel.Invariant.comp_const
-/

#print ProbabilityTheory.kernel.Invariant.comp /-
theorem Invariant.comp [IsSFiniteKernel κ] (hκ : Invariant κ μ) (hη : Invariant η μ) :
    Invariant (κ ∘ₖ η) μ := by
  cases' isEmpty_or_nonempty α with _ hα
  · exact Subsingleton.elim _ _
  ·
    simp_rw [invariant, ← comp_const_apply_eq_bind (κ ∘ₖ η) μ hα.some, comp_assoc, hη.comp_const,
      hκ.comp_const, const_apply]
#align probability_theory.kernel.invariant.comp ProbabilityTheory.kernel.Invariant.comp
-/

end Kernel

end ProbabilityTheory

