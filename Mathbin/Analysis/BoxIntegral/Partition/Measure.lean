import Mathbin.Analysis.BoxIntegral.Partition.Additive
import Mathbin.MeasureTheory.Measure.Lebesgue

/-!
# Box-additive functions defined by measures

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

open_locale Ennreal BigOperators Classical BoxIntegral

variable {ι : Type _}

namespace BoxIntegral

open MeasureTheory

namespace Box

theorem measure_Icc_lt_top (I : box ι) (μ : Measureₓ (ι → ℝ)) [is_locally_finite_measure μ] : μ I.Icc < ∞ :=
  show μ (Icc I.lower I.upper) < ∞ from I.is_compact_Icc.measure_lt_top

theorem measure_coe_lt_top (I : box ι) (μ : Measureₓ (ι → ℝ)) [is_locally_finite_measure μ] : μ I < ∞ :=
  (measure_mono $ coe_subset_Icc).trans_lt (I.measure_Icc_lt_top μ)

variable [Fintype ι] (I : box ι)

theorem measurable_set_coe : MeasurableSet (I : Set (ι → ℝ)) := by
  rw [coe_eq_pi]
  have := Fintype.encodable ι
  exact MeasurableSet.univ_pi fun i => measurable_set_Ioc

theorem measurable_set_Icc : MeasurableSet I.Icc :=
  measurable_set_Icc

theorem measurable_set_Ioo : MeasurableSet I.Ioo :=
  (measurable_set_pi (finite.of_fintype _).Countable).2 $ Or.inl $ fun i hi => measurable_set_Ioo

theorem coe_ae_eq_Icc : (I : Set (ι → ℝ)) =ᵐ[volume] I.Icc := by
  rw [coe_eq_pi]
  exact measure.univ_pi_Ioc_ae_eq_Icc

theorem Ioo_ae_eq_Icc : I.Ioo =ᵐ[volume] I.Icc :=
  measure.univ_pi_Ioo_ae_eq_Icc

end Box

theorem prepartition.measure_Union_to_real [Fintype ι] {I : box ι} (π : prepartition I) (μ : Measureₓ (ι → ℝ))
    [is_locally_finite_measure μ] : (μ π.Union).toReal = ∑ J in π.boxes, (μ J).toReal := by
  erw [← Ennreal.to_real_sum, π.Union_def, measure_bUnion_finset π.pairwise_disjoint]
  exacts[fun J hJ => J.measurable_set_coe, fun J hJ => (J.measure_coe_lt_top μ).Ne]

end BoxIntegral

open BoxIntegral BoxIntegral.Box

variable [Fintype ι]

namespace MeasureTheory

namespace Measureₓ

/-- If `μ` is a locally finite measure on `ℝⁿ`, then `λ J, (μ J).to_real` is a box-additive
function. -/
@[simps]
def to_box_additive (μ : Measureₓ (ι → ℝ)) [is_locally_finite_measure μ] : ι →ᵇᵃ[⊤] ℝ where
  toFun := fun J => (μ J).toReal
  sum_partition_boxes' := fun J hJ π hπ => by
    rw [← π.measure_Union_to_real, hπ.Union_eq]

end Measureₓ

end MeasureTheory

namespace BoxIntegral

open MeasureTheory

namespace Box

@[simp]
theorem volume_apply (I : box ι) : (volume : Measureₓ (ι → ℝ)).toBoxAdditive I = ∏ i, I.upper i - I.lower i := by
  rw [measure.to_box_additive_apply, coe_eq_pi, Real.volume_pi_Ioc_to_real I.lower_le_upper]

theorem volume_face_mul {n} (i : Finₓ (n + 1)) (I : box (Finₓ (n + 1))) :
    (∏ j, (I.face i).upper j - (I.face i).lower j) * (I.upper i - I.lower i) = ∏ j, I.upper j - I.lower j := by
  simp only [face_lower, face_upper, · ∘ ·, Finₓ.prod_univ_succ_above _ i, mul_comm]

end Box

namespace BoxAdditiveMap

/-- Box-additive map sending each box `I` to the continuous linear endomorphism
`x ↦ (volume I).to_real • x`. -/
protected def volume {E : Type _} [NormedGroup E] [NormedSpace ℝ E] : ι →ᵇᵃ E →L[ℝ] E :=
  (volume : Measureₓ (ι → ℝ)).toBoxAdditive.toSmul

theorem volume_apply {E : Type _} [NormedGroup E] [NormedSpace ℝ E] (I : box ι) (x : E) :
    box_additive_map.volume I x = (∏ j, I.upper j - I.lower j) • x :=
  congr_arg2ₓ (· • ·) I.volume_apply rfl

end BoxAdditiveMap

end BoxIntegral

