/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module measure_theory.measure.giry_monad
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Integral.Lebesgue

/-!
# The Giry monad

Let X be a measurable space. The collection of all measures on X again
forms a measurable space. This construction forms a monad on
measurable spaces and measurable functions, called the Giry monad.

Note that most sources use the term "Giry monad" for the restriction
to *probability* measures. Here we include all measures on X.

See also `measure_theory/category/Meas.lean`, containing an upgrade of the type-level
monad to an honest monad of the functor `Measure : Meas ⥤ Meas`.

## References

* <https://ncatlab.org/nlab/show/Giry+monad>

## Tags

giry monad
-/


noncomputable section

open Classical BigOperators Ennreal

open Classical Set Filter

variable {α β : Type _}

namespace MeasureTheory

namespace Measure

variable [MeasurableSpace α] [MeasurableSpace β]

/-- Measurability structure on `measure`: Measures are measurable w.r.t. all projections -/
instance : MeasurableSpace (Measure α) :=
  ⨆ (s : Set α) (hs : MeasurableSet s), (borel ℝ≥0∞).comap fun μ => μ s

theorem measurableCoe {s : Set α} (hs : MeasurableSet s) : Measurable fun μ : Measure α => μ s :=
  Measurable.ofComapLe <| le_supr_of_le s <| le_supr_of_le hs <| le_rfl
#align measure_theory.measure.measurable_coe MeasureTheory.Measure.measurableCoe

theorem measurableOfMeasurableCoe (f : β → Measure α)
    (h : ∀ (s : Set α) (hs : MeasurableSet s), Measurable fun b => f b s) : Measurable f :=
  Measurable.ofLeMap <|
    supr₂_le fun s hs =>
      MeasurableSpace.comap_le_iff_le_map.2 <| by rw [MeasurableSpace.map_comp] <;> exact h s hs
#align
  measure_theory.measure.measurable_of_measurable_coe MeasureTheory.Measure.measurableOfMeasurableCoe

theorem measurable_measure {μ : α → Measure β} :
    Measurable μ ↔ ∀ (s : Set β) (hs : MeasurableSet s), Measurable fun b => μ b s :=
  ⟨fun hμ s hs => (measurableCoe hs).comp hμ, measurableOfMeasurableCoe μ⟩
#align measure_theory.measure.measurable_measure MeasureTheory.Measure.measurable_measure

theorem measurableMap (f : α → β) (hf : Measurable f) : Measurable fun μ : Measure α => map f μ :=
  by 
  refine' measurable_of_measurable_coe _ fun s hs => _
  simp_rw [map_apply hf hs]
  exact measurable_coe (hf hs)
#align measure_theory.measure.measurable_map MeasureTheory.Measure.measurableMap

theorem measurableDirac : Measurable (Measure.dirac : α → Measure α) := by
  refine' measurable_of_measurable_coe _ fun s hs => _
  simp_rw [dirac_apply' _ hs]
  exact measurable_one.indicator hs
#align measure_theory.measure.measurable_dirac MeasureTheory.Measure.measurableDirac

theorem measurableLintegral {f : α → ℝ≥0∞} (hf : Measurable f) :
    Measurable fun μ : Measure α => ∫⁻ x, f x ∂μ := by
  simp only [lintegral_eq_supr_eapprox_lintegral, hf, simple_func.lintegral]
  refine' measurableSupr fun n => Finset.measurableSum _ fun i _ => _
  refine' Measurable.constMul _ _
  exact measurable_coe ((simple_func.eapprox f n).measurableSetPreimage _)
#align measure_theory.measure.measurable_lintegral MeasureTheory.Measure.measurableLintegral

/-- Monadic join on `measure` in the category of measurable spaces and measurable
functions. -/
def join (m : Measure (Measure α)) : Measure α :=
  Measure.ofMeasurable (fun s hs => ∫⁻ μ, μ s ∂m)
    (by simp only [measure_empty, lintegral_const, zero_mul])
    (by 
      intro f hf h
      simp_rw [measure_Union h hf]
      apply lintegral_tsum
      intro i; exact (measurable_coe (hf i)).AeMeasurable)
#align measure_theory.measure.join MeasureTheory.Measure.join

@[simp]
theorem join_apply {m : Measure (Measure α)} {s : Set α} (hs : MeasurableSet s) :
    join m s = ∫⁻ μ, μ s ∂m :=
  Measure.of_measurable_apply s hs
#align measure_theory.measure.join_apply MeasureTheory.Measure.join_apply

@[simp]
theorem join_zero : (0 : Measure (Measure α)).join = 0 := by
  ext1 s hs
  simp only [hs, join_apply, lintegral_zero_measure, coe_zero, Pi.zero_apply]
#align measure_theory.measure.join_zero MeasureTheory.Measure.join_zero

theorem measurableJoin : Measurable (join : Measure (Measure α) → Measure α) :=
  (measurableOfMeasurableCoe _) fun s hs => by
    simp only [join_apply hs] <;> exact measurable_lintegral (measurable_coe hs)
#align measure_theory.measure.measurable_join MeasureTheory.Measure.measurableJoin

theorem lintegral_join {m : Measure (Measure α)} {f : α → ℝ≥0∞} (hf : Measurable f) :
    (∫⁻ x, f x ∂join m) = ∫⁻ μ, ∫⁻ x, f x ∂μ ∂m := by
  simp_rw [lintegral_eq_supr_eapprox_lintegral hf, simple_func.lintegral,
    join_apply (simple_func.measurable_set_preimage _ _)]
  suffices
    ∀ (s : ℕ → Finset ℝ≥0∞) (f : ℕ → ℝ≥0∞ → Measure α → ℝ≥0∞) (hf : ∀ n r, Measurable (f n r))
      (hm : Monotone fun n μ => ∑ r in s n, r * f n r μ),
      (⨆ n, ∑ r in s n, r * ∫⁻ μ, f n r μ ∂m) = ∫⁻ μ, ⨆ n, ∑ r in s n, r * f n r μ ∂m
    by
    refine'
      this (fun n => simple_func.range (simple_func.eapprox f n))
        (fun n r μ => μ (simple_func.eapprox f n ⁻¹' {r})) _ _
    · exact fun n r => measurable_coe (simple_func.measurable_set_preimage _ _)
    · exact fun n m h μ => simple_func.lintegral_mono (simple_func.monotone_eapprox _ h) le_rfl
  intro s f hf hm
  rw [lintegral_supr _ hm]
  swap
  · exact fun n => Finset.measurableSum _ fun r _ => (hf _ _).const_mul _
  congr
  funext n
  rw [lintegral_finset_sum (s n)]
  · simp_rw [lintegral_const_mul _ (hf _ _)]
  · exact fun r _ => (hf _ _).const_mul _
#align measure_theory.measure.lintegral_join MeasureTheory.Measure.lintegral_join

/-- Monadic bind on `measure`, only works in the category of measurable spaces and measurable
functions. When the function `f` is not measurable the result is not well defined. -/
def bind (m : Measure α) (f : α → Measure β) : Measure β :=
  join (map f m)
#align measure_theory.measure.bind MeasureTheory.Measure.bind

@[simp]
theorem bind_zero_left (f : α → Measure β) : bind 0 f = 0 := by simp [bind]
#align measure_theory.measure.bind_zero_left MeasureTheory.Measure.bind_zero_left

@[simp]
theorem bind_zero_right (m : Measure α) : bind m (0 : α → Measure β) = 0 := by
  ext1 s hs
  simp only [bind, hs, join_apply, coe_zero, Pi.zero_apply]
  rw [lintegral_map (measurable_coe hs) measurableZero]
  simp only [Pi.zero_apply, coe_zero, lintegral_const, zero_mul]
#align measure_theory.measure.bind_zero_right MeasureTheory.Measure.bind_zero_right

@[simp]
theorem bind_zero_right' (m : Measure α) : bind m (fun _ => 0 : α → Measure β) = 0 :=
  bind_zero_right m
#align measure_theory.measure.bind_zero_right' MeasureTheory.Measure.bind_zero_right'

@[simp]
theorem bind_apply {m : Measure α} {f : α → Measure β} {s : Set β} (hs : MeasurableSet s)
    (hf : Measurable f) : bind m f s = ∫⁻ a, f a s ∂m := by
  rw [bind, join_apply hs, lintegral_map (measurable_coe hs) hf]
#align measure_theory.measure.bind_apply MeasureTheory.Measure.bind_apply

theorem measurableBind' {g : α → Measure β} (hg : Measurable g) : Measurable fun m => bind m g :=
  measurableJoin.comp (measurableMap _ hg)
#align measure_theory.measure.measurable_bind' MeasureTheory.Measure.measurableBind'

theorem lintegral_bind {m : Measure α} {μ : α → Measure β} {f : β → ℝ≥0∞} (hμ : Measurable μ)
    (hf : Measurable f) : (∫⁻ x, f x ∂bind m μ) = ∫⁻ a, ∫⁻ x, f x ∂μ a ∂m :=
  (lintegral_join hf).trans (lintegral_map (measurableLintegral hf) hμ)
#align measure_theory.measure.lintegral_bind MeasureTheory.Measure.lintegral_bind

theorem bind_bind {γ} [MeasurableSpace γ] {m : Measure α} {f : α → Measure β} {g : β → Measure γ}
    (hf : Measurable f) (hg : Measurable g) : bind (bind m f) g = bind m fun a => bind (f a) g := by
  ext1 s hs
  simp_rw [bind_apply hs hg, bind_apply hs ((measurable_bind' hg).comp hf),
    lintegral_bind hf ((measurable_coe hs).comp hg), bind_apply hs hg]
#align measure_theory.measure.bind_bind MeasureTheory.Measure.bind_bind

theorem bind_dirac {f : α → Measure β} (hf : Measurable f) (a : α) : bind (dirac a) f = f a := by
  ext1 s hs
  rw [bind_apply hs hf, lintegral_dirac' a ((measurable_coe hs).comp hf)]
#align measure_theory.measure.bind_dirac MeasureTheory.Measure.bind_dirac

theorem dirac_bind {m : Measure α} : bind m dirac = m := by
  ext1 s hs
  simp only [bind_apply hs measurable_dirac, dirac_apply' _ hs, lintegral_indicator 1 hs,
    Pi.one_apply, lintegral_one, restrict_apply, MeasurableSet.univ, univ_inter]
#align measure_theory.measure.dirac_bind MeasureTheory.Measure.dirac_bind

theorem join_eq_bind (μ : Measure (Measure α)) : join μ = bind μ id := by rw [bind, map_id]
#align measure_theory.measure.join_eq_bind MeasureTheory.Measure.join_eq_bind

theorem join_map_map {f : α → β} (hf : Measurable f) (μ : Measure (Measure α)) :
    join (map (map f) μ) = map f (join μ) := by
  ext1 s hs
  rw [join_apply hs, map_apply hf hs, join_apply (hf hs),
    lintegral_map (measurable_coe hs) (measurable_map f hf)]
  simp_rw [map_apply hf hs]
#align measure_theory.measure.join_map_map MeasureTheory.Measure.join_map_map

theorem join_map_join (μ : Measure (Measure (Measure α))) : join (map join μ) = join (join μ) := by
  show bind μ join = join (join μ)
  rw [join_eq_bind, join_eq_bind, bind_bind measurableId measurableId]
  apply congr_arg (bind μ)
  funext ν
  exact join_eq_bind ν
#align measure_theory.measure.join_map_join MeasureTheory.Measure.join_map_join

theorem join_map_dirac (μ : Measure α) : join (map dirac μ) = μ :=
  dirac_bind
#align measure_theory.measure.join_map_dirac MeasureTheory.Measure.join_map_dirac

theorem join_dirac (μ : Measure α) : join (dirac μ) = μ :=
  (join_eq_bind (dirac μ)).trans (bind_dirac measurableId _)
#align measure_theory.measure.join_dirac MeasureTheory.Measure.join_dirac

end Measure

end MeasureTheory

