/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.box_integral.partition.measure
! leanprover-community/mathlib commit 36938f775671ff28bea1c0310f1608e4afbb22e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.BoxIntegral.Partition.Additive
import Mathbin.MeasureTheory.Measure.Lebesgue.Basic

/-!
# Box-additive functions defined by measures

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove a few simple facts about rectangular boxes, partitions, and measures:

- given a box `I : box ι`, its coercion to `set (ι → ℝ)` and `I.Icc` are measurable sets;
- if `μ` is a locally finite measure, then `(I : set (ι → ℝ))` and `I.Icc` have finite measure;
- if `μ` is a locally finite measure, then `λ J, (μ J).to_real` is a box additive function.

For the last statement, we both prove it as a proposition and define a bundled
`box_integral.box_additive` function.

### Tags

rectangular box, measure
-/


open Set

noncomputable section

open scoped ENNReal BigOperators Classical BoxIntegral

variable {ι : Type _}

namespace BoxIntegral

open MeasureTheory

namespace Box

variable (I : Box ι)

#print BoxIntegral.Box.measure_Icc_lt_top /-
theorem measure_Icc_lt_top (μ : Measure (ι → ℝ)) [IsLocallyFiniteMeasure μ] : μ I.Icc < ∞ :=
  show μ (Icc I.lower I.upper) < ∞ from I.isCompact_Icc.measure_lt_top
#align box_integral.box.measure_Icc_lt_top BoxIntegral.Box.measure_Icc_lt_top
-/

#print BoxIntegral.Box.measure_coe_lt_top /-
theorem measure_coe_lt_top (μ : Measure (ι → ℝ)) [IsLocallyFiniteMeasure μ] : μ I < ∞ :=
  (measure_mono <| coe_subset_Icc).trans_lt (I.measure_Icc_lt_top μ)
#align box_integral.box.measure_coe_lt_top BoxIntegral.Box.measure_coe_lt_top
-/

section Countable

variable [Countable ι]

#print BoxIntegral.Box.measurableSet_coe /-
theorem measurableSet_coe : MeasurableSet (I : Set (ι → ℝ)) := by rw [coe_eq_pi];
  exact MeasurableSet.univ_pi fun i => measurableSet_Ioc
#align box_integral.box.measurable_set_coe BoxIntegral.Box.measurableSet_coe
-/

#print BoxIntegral.Box.measurableSet_Icc /-
theorem measurableSet_Icc : MeasurableSet I.Icc :=
  measurableSet_Icc
#align box_integral.box.measurable_set_Icc BoxIntegral.Box.measurableSet_Icc
-/

#print BoxIntegral.Box.measurableSet_Ioo /-
theorem measurableSet_Ioo : MeasurableSet I.Ioo :=
  MeasurableSet.univ_pi fun i => measurableSet_Ioo
#align box_integral.box.measurable_set_Ioo BoxIntegral.Box.measurableSet_Ioo
-/

end Countable

variable [Fintype ι]

#print BoxIntegral.Box.coe_ae_eq_Icc /-
theorem coe_ae_eq_Icc : (I : Set (ι → ℝ)) =ᵐ[volume] I.Icc := by rw [coe_eq_pi];
  exact measure.univ_pi_Ioc_ae_eq_Icc
#align box_integral.box.coe_ae_eq_Icc BoxIntegral.Box.coe_ae_eq_Icc
-/

#print BoxIntegral.Box.Ioo_ae_eq_Icc /-
theorem Ioo_ae_eq_Icc : I.Ioo =ᵐ[volume] I.Icc :=
  Measure.univ_pi_Ioo_ae_eq_Icc
#align box_integral.box.Ioo_ae_eq_Icc BoxIntegral.Box.Ioo_ae_eq_Icc
-/

end Box

#print BoxIntegral.Prepartition.measure_iUnion_toReal /-
theorem Prepartition.measure_iUnion_toReal [Finite ι] {I : Box ι} (π : Prepartition I)
    (μ : Measure (ι → ℝ)) [IsLocallyFiniteMeasure μ] :
    (μ π.iUnion).toReal = ∑ J in π.boxes, (μ J).toReal :=
  by
  erw [← ENNReal.toReal_sum, π.Union_def, measure_bUnion_finset π.pairwise_disjoint]
  exacts [fun J hJ => J.measurableSet_coe, fun J hJ => (J.measure_coe_lt_top μ).Ne]
#align box_integral.prepartition.measure_Union_to_real BoxIntegral.Prepartition.measure_iUnion_toReal
-/

end BoxIntegral

open BoxIntegral BoxIntegral.Box

variable [Fintype ι]

namespace MeasureTheory

namespace Measure

#print MeasureTheory.Measure.toBoxAdditive /-
/-- If `μ` is a locally finite measure on `ℝⁿ`, then `λ J, (μ J).to_real` is a box-additive
function. -/
@[simps]
def toBoxAdditive (μ : Measure (ι → ℝ)) [IsLocallyFiniteMeasure μ] : ι →ᵇᵃ[⊤] ℝ
    where
  toFun J := (μ J).toReal
  sum_partition_boxes' J hJ π hπ := by rw [← π.measure_Union_to_real, hπ.Union_eq]
#align measure_theory.measure.to_box_additive MeasureTheory.Measure.toBoxAdditive
-/

end Measure

end MeasureTheory

namespace BoxIntegral

open MeasureTheory

namespace Box

#print BoxIntegral.Box.volume_apply /-
@[simp]
theorem volume_apply (I : Box ι) :
    (volume : Measure (ι → ℝ)).toBoxAdditive I = ∏ i, (I.upper i - I.lower i) := by
  rw [measure.to_box_additive_apply, coe_eq_pi, Real.volume_pi_Ioc_toReal I.lower_le_upper]
#align box_integral.box.volume_apply BoxIntegral.Box.volume_apply
-/

#print BoxIntegral.Box.volume_face_mul /-
theorem volume_face_mul {n} (i : Fin (n + 1)) (I : Box (Fin (n + 1))) :
    (∏ j, ((I.face i).upper j - (I.face i).lower j)) * (I.upper i - I.lower i) =
      ∏ j, (I.upper j - I.lower j) :=
  by simp only [face_lower, face_upper, (· ∘ ·), Fin.prod_univ_succAbove _ i, mul_comm]
#align box_integral.box.volume_face_mul BoxIntegral.Box.volume_face_mul
-/

end Box

namespace BoxAdditiveMap

#print BoxIntegral.BoxAdditiveMap.volume /-
/-- Box-additive map sending each box `I` to the continuous linear endomorphism
`x ↦ (volume I).to_real • x`. -/
protected def volume {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E] : ι →ᵇᵃ E →L[ℝ] E :=
  (volume : Measure (ι → ℝ)).toBoxAdditive.toSMul
#align box_integral.box_additive_map.volume BoxIntegral.BoxAdditiveMap.volume
-/

#print BoxIntegral.BoxAdditiveMap.volume_apply /-
theorem volume_apply {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E] (I : Box ι) (x : E) :
    BoxAdditiveMap.volume I x = (∏ j, (I.upper j - I.lower j)) • x :=
  congr_arg₂ (· • ·) I.volume_apply rfl
#align box_integral.box_additive_map.volume_apply BoxIntegral.BoxAdditiveMap.volume_apply
-/

end BoxAdditiveMap

end BoxIntegral

