/-
Copyright (c) 2021 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Zhouhang Zhou, Yury Kudryashov
-/
import Mathbin.MeasureTheory.Function.L1Space
import Mathbin.Analysis.NormedSpace.IndicatorFunction

/-! # Functions integrable on a set and at a filter

We define `integrable_on f s μ := integrable f (μ.restrict s)` and prove theorems like
`integrable_on_union : integrable_on f (s ∪ t) μ ↔ integrable_on f s μ ∧ integrable_on f t μ`.

Next we define a predicate `integrable_at_filter (f : α → E) (l : filter α) (μ : measure α)`
saying that `f` is integrable at some set `s ∈ l` and prove that a measurable function is integrable
at `l` with respect to `μ` provided that `f` is bounded above at `l ⊓ μ.ae` and `μ` is finite
at `l`.

-/


noncomputable section

open Set Filter TopologicalSpace MeasureTheory Function

open Classical TopologicalSpace Interval BigOperators Filter Ennreal MeasureTheory

variable {α β E F : Type _} [MeasurableSpace α]

section

variable [TopologicalSpace β] {l l' : Filter α} {f g : α → β} {μ ν : Measure α}

/-- A function `f` is strongly measurable at a filter `l` w.r.t. a measure `μ` if it is
ae strongly measurable w.r.t. `μ.restrict s` for some `s ∈ l`. -/
def StronglyMeasurableAtFilter (f : α → β) (l : Filter α)
    (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) :=
  ∃ s ∈ l, AeStronglyMeasurable f (μ.restrict s)

@[simp]
theorem stronglyMeasurableAtBot {f : α → β} : StronglyMeasurableAtFilter f ⊥ μ :=
  ⟨∅, mem_bot, by simp⟩

protected theorem StronglyMeasurableAtFilter.eventually (h : StronglyMeasurableAtFilter f l μ) :
    ∀ᶠ s in l.smallSets, AeStronglyMeasurable f (μ.restrict s) :=
  (eventually_small_sets' fun s t => AeStronglyMeasurable.monoSet).2 h

protected theorem StronglyMeasurableAtFilter.filterMono (h : StronglyMeasurableAtFilter f l μ) (h' : l' ≤ l) :
    StronglyMeasurableAtFilter f l' μ :=
  let ⟨s, hsl, hs⟩ := h
  ⟨s, h' hsl, hs⟩

protected theorem MeasureTheory.AeStronglyMeasurable.stronglyMeasurableAtFilter (h : AeStronglyMeasurable f μ) :
    StronglyMeasurableAtFilter f l μ :=
  ⟨Univ, univ_mem, by rwa [measure.restrict_univ]⟩

theorem AeStronglyMeasurable.stronglyMeasurableAtFilterOfMem {s} (h : AeStronglyMeasurable f (μ.restrict s))
    (hl : s ∈ l) : StronglyMeasurableAtFilter f l μ :=
  ⟨s, hl, h⟩

protected theorem MeasureTheory.StronglyMeasurable.stronglyMeasurableAtFilter (h : StronglyMeasurable f) :
    StronglyMeasurableAtFilter f l μ :=
  h.AeStronglyMeasurable.StronglyMeasurableAtFilter

end

namespace MeasureTheory

section NormedAddCommGroup

theorem hasFiniteIntegralRestrictOfBounded [NormedAddCommGroup E] {f : α → E} {s : Set α} {μ : Measure α} {C}
    (hs : μ s < ∞) (hf : ∀ᵐ x ∂μ.restrict s, ∥f x∥ ≤ C) : HasFiniteIntegral f (μ.restrict s) :=
  haveI : is_finite_measure (μ.restrict s) := ⟨by rwa [measure.restrict_apply_univ]⟩
  has_finite_integral_of_bounded hf

variable [NormedAddCommGroup E] {f g : α → E} {s t : Set α} {μ ν : Measure α}

/-- A function is `integrable_on` a set `s` if it is almost everywhere strongly measurable on `s`
and if the integral of its pointwise norm over `s` is less than infinity. -/
def IntegrableOn (f : α → E) (s : Set α) (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) : Prop :=
  Integrable f (μ.restrict s)

theorem IntegrableOn.integrable (h : IntegrableOn f s μ) : Integrable f (μ.restrict s) :=
  h

@[simp]
theorem integrableOnEmpty : IntegrableOn f ∅ μ := by simp [integrable_on, integrable_zero_measure]

@[simp]
theorem integrable_on_univ : IntegrableOn f Univ μ ↔ Integrable f μ := by rw [integrable_on, measure.restrict_univ]

theorem integrableOnZero : IntegrableOn (fun _ => (0 : E)) s μ :=
  integrableZero _ _ _

@[simp]
theorem integrable_on_const {C : E} : IntegrableOn (fun _ => C) s μ ↔ C = 0 ∨ μ s < ∞ :=
  integrable_const_iff.trans <| by rw [measure.restrict_apply_univ]

theorem IntegrableOn.mono (h : IntegrableOn f t ν) (hs : s ⊆ t) (hμ : μ ≤ ν) : IntegrableOn f s μ :=
  h.monoMeasure <| Measure.restrict_mono hs hμ

theorem IntegrableOn.monoSet (h : IntegrableOn f t μ) (hst : s ⊆ t) : IntegrableOn f s μ :=
  h.mono hst le_rfl

theorem IntegrableOn.monoMeasure (h : IntegrableOn f s ν) (hμ : μ ≤ ν) : IntegrableOn f s μ :=
  h.mono (Subset.refl _) hμ

theorem IntegrableOn.monoSetAe (h : IntegrableOn f t μ) (hst : s ≤ᵐ[μ] t) : IntegrableOn f s μ :=
  h.Integrable.monoMeasure <| Measure.restrict_mono_ae hst

theorem IntegrableOn.congrSetAe (h : IntegrableOn f t μ) (hst : s =ᵐ[μ] t) : IntegrableOn f s μ :=
  h.monoSetAe hst.le

theorem IntegrableOn.congrFun' (h : IntegrableOn f s μ) (hst : f =ᵐ[μ.restrict s] g) : IntegrableOn g s μ :=
  Integrable.congr h hst

theorem IntegrableOn.congrFun (h : IntegrableOn f s μ) (hst : EqOn f g s) (hs : MeasurableSet s) : IntegrableOn g s μ :=
  h.congrFun' ((ae_restrict_iff' hs).2 (eventually_of_forall hst))

theorem Integrable.integrableOn (h : Integrable f μ) : IntegrableOn f s μ :=
  h.monoMeasure <| measure.restrict_le_self

theorem Integrable.integrableOn' (h : Integrable f (μ.restrict s)) : IntegrableOn f s μ :=
  h

theorem IntegrableOn.restrict (h : IntegrableOn f s μ) (hs : MeasurableSet s) : IntegrableOn f s (μ.restrict t) := by
  rw [integrable_on, measure.restrict_restrict hs]
  exact h.mono_set (inter_subset_left _ _)

theorem IntegrableOn.leftOfUnion (h : IntegrableOn f (s ∪ t) μ) : IntegrableOn f s μ :=
  h.monoSet <| subset_union_left _ _

theorem IntegrableOn.rightOfUnion (h : IntegrableOn f (s ∪ t) μ) : IntegrableOn f t μ :=
  h.monoSet <| subset_union_right _ _

theorem IntegrableOn.union (hs : IntegrableOn f s μ) (ht : IntegrableOn f t μ) : IntegrableOn f (s ∪ t) μ :=
  (hs.addMeasure ht).monoMeasure <| Measure.restrict_union_le _ _

@[simp]
theorem integrable_on_union : IntegrableOn f (s ∪ t) μ ↔ IntegrableOn f s μ ∧ IntegrableOn f t μ :=
  ⟨fun h => ⟨h.leftOfUnion, h.rightOfUnion⟩, fun h => h.1.union h.2⟩

@[simp]
theorem integrable_on_singleton_iff {x : α} [MeasurableSingletonClass α] : IntegrableOn f {x} μ ↔ f x = 0 ∨ μ {x} < ∞ :=
  by
  have : f =ᵐ[μ.restrict {x}] fun y => f x := by
    filter_upwards [ae_restrict_mem (measurable_set_singleton x)] with _ ha
    simp only [mem_singleton_iff.1 ha]
  rw [integrable_on, integrable_congr this, integrable_const_iff]
  simp

@[simp]
theorem integrable_on_finite_bUnion {s : Set β} (hs : s.Finite) {t : β → Set α} :
    IntegrableOn f (⋃ i ∈ s, t i) μ ↔ ∀ i ∈ s, IntegrableOn f (t i) μ := by
  apply hs.induction_on
  · simp
    
  · intro a s ha hs hf
    simp [hf, or_imp, forall_and]
    

@[simp]
theorem integrable_on_finset_Union {s : Finset β} {t : β → Set α} :
    IntegrableOn f (⋃ i ∈ s, t i) μ ↔ ∀ i ∈ s, IntegrableOn f (t i) μ :=
  integrable_on_finite_bUnion s.finite_to_set

@[simp]
theorem integrable_on_finite_Union [Finite β] {t : β → Set α} :
    IntegrableOn f (⋃ i, t i) μ ↔ ∀ i, IntegrableOn f (t i) μ := by
  cases nonempty_fintype β
  simpa using @integrable_on_finset_Union _ _ _ _ _ f μ Finset.univ t

theorem IntegrableOn.addMeasure (hμ : IntegrableOn f s μ) (hν : IntegrableOn f s ν) : IntegrableOn f s (μ + ν) := by
  delta integrable_on
  rw [measure.restrict_add]
  exact hμ.integrable.add_measure hν

@[simp]
theorem integrable_on_add_measure : IntegrableOn f s (μ + ν) ↔ IntegrableOn f s μ ∧ IntegrableOn f s ν :=
  ⟨fun h => ⟨h.monoMeasure (Measure.le_add_right le_rfl), h.monoMeasure (Measure.le_add_left le_rfl)⟩, fun h =>
    h.1.addMeasure h.2⟩

theorem _root_.measurable_embedding.integrable_on_map_iff [MeasurableSpace β] {e : α → β} (he : MeasurableEmbedding e)
    {f : β → E} {μ : Measure α} {s : Set β} : IntegrableOn f s (Measure.map e μ) ↔ IntegrableOn (f ∘ e) (e ⁻¹' s) μ :=
  by simp only [integrable_on, he.restrict_map, he.integrable_map_iff]

theorem integrable_on_map_equiv [MeasurableSpace β] (e : α ≃ᵐ β) {f : β → E} {μ : Measure α} {s : Set β} :
    IntegrableOn f s (Measure.map e μ) ↔ IntegrableOn (f ∘ e) (e ⁻¹' s) μ := by
  simp only [integrable_on, e.restrict_map, integrable_map_equiv e]

theorem MeasurePreserving.integrable_on_comp_preimage [MeasurableSpace β] {e : α → β} {ν} (h₁ : MeasurePreserving e μ ν)
    (h₂ : MeasurableEmbedding e) {f : β → E} {s : Set β} : IntegrableOn (f ∘ e) (e ⁻¹' s) μ ↔ IntegrableOn f s ν :=
  (h₁.restrictPreimageEmb h₂ s).integrable_comp_emb h₂

theorem MeasurePreserving.integrable_on_image [MeasurableSpace β] {e : α → β} {ν} (h₁ : MeasurePreserving e μ ν)
    (h₂ : MeasurableEmbedding e) {f : β → E} {s : Set α} : IntegrableOn f (e '' s) ν ↔ IntegrableOn (f ∘ e) s μ :=
  ((h₁.restrictImageEmb h₂ s).integrable_comp_emb h₂).symm

theorem integrable_indicator_iff (hs : MeasurableSet s) : Integrable (indicator s f) μ ↔ IntegrableOn f s μ := by
  simp [integrable_on, integrable, has_finite_integral, nnnorm_indicator_eq_indicator_nnnorm, Ennreal.coe_indicator,
    lintegral_indicator _ hs, ae_strongly_measurable_indicator_iff hs]

theorem IntegrableOn.indicator (h : IntegrableOn f s μ) (hs : MeasurableSet s) : Integrable (indicator s f) μ :=
  (integrable_indicator_iff hs).2 h

theorem Integrable.indicator (h : Integrable f μ) (hs : MeasurableSet s) : Integrable (indicator s f) μ :=
  h.IntegrableOn.indicator hs

theorem integrableIndicatorConstLp {E} [NormedAddCommGroup E] {p : ℝ≥0∞} {s : Set α} (hs : MeasurableSet s)
    (hμs : μ s ≠ ∞) (c : E) : Integrable (indicatorConstLp p hs hμs c) μ := by
  rw [integrable_congr indicator_const_Lp_coe_fn, integrable_indicator_iff hs, integrable_on, integrable_const_iff,
    lt_top_iff_ne_top]
  right
  simpa only [Set.univ_inter, MeasurableSet.univ, measure.restrict_apply] using hμs

theorem integrable_on_iff_integable_of_support_subset {f : α → E} {s : Set α} (h1s : Support f ⊆ s)
    (h2s : MeasurableSet s) : IntegrableOn f s μ ↔ Integrable f μ := by
  refine' ⟨fun h => _, fun h => h.IntegrableOn⟩
  rwa [← indicator_eq_self.2 h1s, integrable_indicator_iff h2s]

theorem integrableOnLpOfMeasureNeTop {E} [NormedAddCommGroup E] {p : ℝ≥0∞} {s : Set α} (f : lp E p μ) (hp : 1 ≤ p)
    (hμs : μ s ≠ ∞) : IntegrableOn f s μ := by
  refine' mem_ℒp_one_iff_integrable.mp _
  have hμ_restrict_univ : (μ.restrict s) Set.Univ < ∞ := by
    simpa only [Set.univ_inter, MeasurableSet.univ, measure.restrict_apply, lt_top_iff_ne_top]
  haveI hμ_finite : is_finite_measure (μ.restrict s) := ⟨hμ_restrict_univ⟩
  exact ((Lp.mem_ℒp _).restrict s).memℒpOfExponentLe hp

theorem Integrable.lintegral_lt_top {f : α → ℝ} (hf : Integrable f μ) : (∫⁻ x, Ennreal.ofReal (f x) ∂μ) < ∞ :=
  calc
    (∫⁻ x, Ennreal.ofReal (f x) ∂μ) ≤ ∫⁻ x, ↑∥f x∥₊ ∂μ := lintegral_of_real_le_lintegral_nnnorm f
    _ < ∞ := hf.2
    

theorem IntegrableOn.set_lintegral_lt_top {f : α → ℝ} {s : Set α} (hf : IntegrableOn f s μ) :
    (∫⁻ x in s, Ennreal.ofReal (f x) ∂μ) < ∞ :=
  Integrable.lintegral_lt_top hf

/-- We say that a function `f` is *integrable at filter* `l` if it is integrable on some
set `s ∈ l`. Equivalently, it is eventually integrable on `s` in `l.small_sets`. -/
def IntegrableAtFilter (f : α → E) (l : Filter α) (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) :=
  ∃ s ∈ l, IntegrableOn f s μ

variable {l l' : Filter α}

protected theorem IntegrableAtFilter.eventually (h : IntegrableAtFilter f l μ) :
    ∀ᶠ s in l.smallSets, IntegrableOn f s μ :=
  Iff.mpr (eventually_small_sets' fun s t hst ht => ht.monoSet hst) h

theorem IntegrableAtFilter.filterMono (hl : l ≤ l') (hl' : IntegrableAtFilter f l' μ) : IntegrableAtFilter f l μ :=
  let ⟨s, hs, hsf⟩ := hl'
  ⟨s, hl hs, hsf⟩

theorem IntegrableAtFilter.infOfLeft (hl : IntegrableAtFilter f l μ) : IntegrableAtFilter f (l ⊓ l') μ :=
  hl.filter_mono inf_le_left

theorem IntegrableAtFilter.infOfRight (hl : IntegrableAtFilter f l μ) : IntegrableAtFilter f (l' ⊓ l) μ :=
  hl.filter_mono inf_le_right

@[simp]
theorem IntegrableAtFilter.inf_ae_iff {l : Filter α} : IntegrableAtFilter f (l ⊓ μ.ae) μ ↔ IntegrableAtFilter f l μ :=
  by
  refine' ⟨_, fun h => h.filter_mono inf_le_left⟩
  rintro ⟨s, ⟨t, ht, u, hu, rfl⟩, hf⟩
  refine' ⟨t, ht, _⟩
  refine' hf.integrable.mono_measure fun v hv => _
  simp only [measure.restrict_apply hv]
  refine' measure_mono_ae ((mem_of_superset hu) fun x hx => _)
  exact fun ⟨hv, ht⟩ => ⟨hv, ⟨ht, hx⟩⟩

alias integrable_at_filter.inf_ae_iff ↔ integrable_at_filter.of_inf_ae _

/-- If `μ` is a measure finite at filter `l` and `f` is a function such that its norm is bounded
above at `l`, then `f` is integrable at `l`. -/
theorem Measure.FiniteAtFilter.integrableAtFilter {l : Filter α} [IsMeasurablyGenerated l]
    (hfm : StronglyMeasurableAtFilter f l μ) (hμ : μ.FiniteAtFilter l) (hf : l.IsBoundedUnder (· ≤ ·) (norm ∘ f)) :
    IntegrableAtFilter f l μ := by
  obtain ⟨C, hC⟩ : ∃ C, ∀ᶠ s in l.small_sets, ∀ x ∈ s, ∥f x∥ ≤ C
  exact hf.imp fun C hC => eventually_small_sets.2 ⟨_, hC, fun t => id⟩
  rcases(hfm.eventually.and (hμ.eventually.and hC)).exists_measurable_mem_of_small_sets with ⟨s, hsl, hsm, hfm, hμ, hC⟩
  refine' ⟨s, hsl, ⟨hfm, has_finite_integral_restrict_of_bounded hμ _⟩⟩
  exact C
  rw [ae_restrict_eq hsm, eventually_inf_principal]
  exact eventually_of_forall hC

theorem Measure.FiniteAtFilter.integrableAtFilterOfTendstoAe {l : Filter α} [IsMeasurablyGenerated l]
    (hfm : StronglyMeasurableAtFilter f l μ) (hμ : μ.FiniteAtFilter l) {b} (hf : Tendsto f (l ⊓ μ.ae) (𝓝 b)) :
    IntegrableAtFilter f l μ :=
  (hμ.inf_of_left.IntegrableAtFilter (hfm.filter_mono inf_le_left) hf.norm.is_bounded_under_le).ofInfAe

alias measure.finite_at_filter.integrable_at_filter_of_tendsto_ae ← _root_.filter.tendsto.integrable_at_filter_ae

theorem Measure.FiniteAtFilter.integrableAtFilterOfTendsto {l : Filter α} [IsMeasurablyGenerated l]
    (hfm : StronglyMeasurableAtFilter f l μ) (hμ : μ.FiniteAtFilter l) {b} (hf : Tendsto f l (𝓝 b)) :
    IntegrableAtFilter f l μ :=
  hμ.IntegrableAtFilter hfm hf.norm.is_bounded_under_le

alias measure.finite_at_filter.integrable_at_filter_of_tendsto ← _root_.filter.tendsto.integrable_at_filter

theorem integrable_add_of_disjoint {f g : α → E} (h : Disjoint (Support f) (Support g)) (hf : StronglyMeasurable f)
    (hg : StronglyMeasurable g) : Integrable (f + g) μ ↔ Integrable f μ ∧ Integrable g μ := by
  refine' ⟨fun hfg => ⟨_, _⟩, fun h => h.1.add h.2⟩
  · rw [← indicator_add_eq_left h]
    exact hfg.indicator hf.measurable_set_support
    
  · rw [← indicator_add_eq_right h]
    exact hfg.indicator hg.measurable_set_support
    

end NormedAddCommGroup

end MeasureTheory

open MeasureTheory

variable [NormedAddCommGroup E]

/-- A function which is continuous on a set `s` is almost everywhere measurable with respect to
`μ.restrict s`. -/
theorem ContinuousOn.aeMeasurable [TopologicalSpace α] [OpensMeasurableSpace α] [MeasurableSpace β] [TopologicalSpace β]
    [BorelSpace β] {f : α → β} {s : Set α} {μ : Measure α} (hf : ContinuousOn f s) (hs : MeasurableSet s) :
    AeMeasurable f (μ.restrict s) := by
  nontriviality α
  inhabit α
  have : (piecewise s f fun _ => f default) =ᵐ[μ.restrict s] f := piecewise_ae_eq_restrict hs
  refine' ⟨piecewise s f fun _ => f default, _, this.symm⟩
  apply measurableOfIsOpen
  intro t ht
  obtain ⟨u, u_open, hu⟩ : ∃ u : Set α, IsOpen u ∧ f ⁻¹' t ∩ s = u ∩ s := _root_.continuous_on_iff'.1 hf t ht
  rw [piecewise_preimage, Set.Ite, hu]
  exact (u_open.measurable_set.inter hs).union ((measurableConst ht.measurable_set).diff hs)

/-- A function which is continuous on a separable set `s` is almost everywhere strongly measurable
with respect to `μ.restrict s`. -/
theorem ContinuousOn.aeStronglyMeasurableOfIsSeparable [TopologicalSpace α] [PseudoMetrizableSpace α]
    [OpensMeasurableSpace α] [TopologicalSpace β] [PseudoMetrizableSpace β] {f : α → β} {s : Set α} {μ : Measure α}
    (hf : ContinuousOn f s) (hs : MeasurableSet s) (h's : TopologicalSpace.IsSeparable s) :
    AeStronglyMeasurable f (μ.restrict s) := by
  letI := pseudo_metrizable_space_pseudo_metric α
  borelize β
  rw [ae_strongly_measurable_iff_ae_measurable_separable]
  refine' ⟨hf.ae_measurable hs, f '' s, hf.is_separable_image h's, _⟩
  exact mem_of_superset (self_mem_ae_restrict hs) (subset_preimage_image _ _)

/-- A function which is continuous on a set `s` is almost everywhere strongly measurable with
respect to `μ.restrict s` when either the source space or the target space is second-countable. -/
theorem ContinuousOn.aeStronglyMeasurable [TopologicalSpace α] [TopologicalSpace β]
    [h : SecondCountableTopologyEither α β] [OpensMeasurableSpace α] [PseudoMetrizableSpace β] {f : α → β} {s : Set α}
    {μ : Measure α} (hf : ContinuousOn f s) (hs : MeasurableSet s) : AeStronglyMeasurable f (μ.restrict s) := by
  borelize β
  refine'
    ae_strongly_measurable_iff_ae_measurable_separable.2
      ⟨hf.ae_measurable hs, f '' s, _, mem_of_superset (self_mem_ae_restrict hs) (subset_preimage_image _ _)⟩
  cases h.out
  · let f' : s → β := s.restrict f
    have A : Continuous f' := continuous_on_iff_continuous_restrict.1 hf
    have B : is_separable (univ : Set s) := is_separable_of_separable_space _
    convert is_separable.image B A using 1
    ext x
    simp
    
  · exact is_separable_of_separable_space _
    

theorem ContinuousOn.integrableAtNhdsWithinOfIsSeparable [TopologicalSpace α] [PseudoMetrizableSpace α]
    [OpensMeasurableSpace α] {μ : Measure α} [IsLocallyFiniteMeasure μ] {a : α} {t : Set α} {f : α → E}
    (hft : ContinuousOn f t) (ht : MeasurableSet t) (h't : TopologicalSpace.IsSeparable t) (ha : a ∈ t) :
    IntegrableAtFilter f (𝓝[t] a) μ :=
  haveI : (𝓝[t] a).IsMeasurablyGenerated := ht.nhds_within_is_measurably_generated _
  (hft a ha).IntegrableAtFilter ⟨_, self_mem_nhds_within, hft.ae_strongly_measurable_of_is_separable ht h't⟩
    (μ.finite_at_nhds_within _ _)

theorem ContinuousOn.integrableAtNhdsWithin [TopologicalSpace α] [SecondCountableTopologyEither α E]
    [OpensMeasurableSpace α] {μ : Measure α} [IsLocallyFiniteMeasure μ] {a : α} {t : Set α} {f : α → E}
    (hft : ContinuousOn f t) (ht : MeasurableSet t) (ha : a ∈ t) : IntegrableAtFilter f (𝓝[t] a) μ :=
  haveI : (𝓝[t] a).IsMeasurablyGenerated := ht.nhds_within_is_measurably_generated _
  (hft a ha).IntegrableAtFilter ⟨_, self_mem_nhds_within, hft.ae_strongly_measurable ht⟩ (μ.finite_at_nhds_within _ _)

/-- If a function is continuous on an open set `s`, then it is strongly measurable at the filter
`𝓝 x` for all `x ∈ s` if either the source space or the target space is second-countable. -/
theorem ContinuousOn.stronglyMeasurableAtFilter [TopologicalSpace α] [OpensMeasurableSpace α] [TopologicalSpace β]
    [PseudoMetrizableSpace β] [SecondCountableTopologyEither α β] {f : α → β} {s : Set α} {μ : Measure α}
    (hs : IsOpen s) (hf : ContinuousOn f s) : ∀ x ∈ s, StronglyMeasurableAtFilter f (𝓝 x) μ := fun x hx =>
  ⟨s, IsOpen.mem_nhds hs hx, hf.AeStronglyMeasurable hs.MeasurableSet⟩

theorem ContinuousAt.stronglyMeasurableAtFilter [TopologicalSpace α] [OpensMeasurableSpace α]
    [SecondCountableTopologyEither α E] {f : α → E} {s : Set α} {μ : Measure α} (hs : IsOpen s)
    (hf : ∀ x ∈ s, ContinuousAt f x) : ∀ x ∈ s, StronglyMeasurableAtFilter f (𝓝 x) μ :=
  ContinuousOn.stronglyMeasurableAtFilter hs <| ContinuousAt.continuous_on hf

theorem Continuous.stronglyMeasurableAtFilter [TopologicalSpace α] [OpensMeasurableSpace α] [TopologicalSpace β]
    [PseudoMetrizableSpace β] [SecondCountableTopologyEither α β] {f : α → β} (hf : Continuous f) (μ : Measure α)
    (l : Filter α) : StronglyMeasurableAtFilter f l μ :=
  hf.StronglyMeasurable.StronglyMeasurableAtFilter

/-- If a function is continuous on a measurable set `s`, then it is measurable at the filter
  `𝓝[s] x` for all `x`. -/
theorem ContinuousOn.stronglyMeasurableAtFilterNhdsWithin {α β : Type _} [MeasurableSpace α] [TopologicalSpace α]
    [OpensMeasurableSpace α] [TopologicalSpace β] [PseudoMetrizableSpace β] [SecondCountableTopologyEither α β]
    {f : α → β} {s : Set α} {μ : Measure α} (hf : ContinuousOn f s) (hs : MeasurableSet s) (x : α) :
    StronglyMeasurableAtFilter f (𝓝[s] x) μ :=
  ⟨s, self_mem_nhds_within, hf.AeStronglyMeasurable hs⟩

