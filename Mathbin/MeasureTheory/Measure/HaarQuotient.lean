/-
Copyright (c) 2022 Alex Kontorovich and Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alex Kontorovich, Heather Macbeth
-/
import Mathbin.MeasureTheory.Measure.Haar
import Mathbin.MeasureTheory.Group.FundamentalDomain
import Mathbin.Topology.CompactOpen
import Mathbin.Algebra.Group.Opposite

/-!
# Haar quotient measure

In this file, we consider properties of fundamental domains and measures for the action of a
subgroup of a group `G` on `G` itself.

## Main results

* `measure_theory.is_fundamental_domain.smul_invariant_measure_map `: given a subgroup `Γ` of a
  topological group `G`, the pushforward to the coset space `G ⧸ Γ` of the restriction of a both
  left- and right-invariant measure on `G` to a fundamental domain `𝓕` is a `G`-invariant measure
  on `G ⧸ Γ`.

* `measure_theory.is_fundamental_domain.is_mul_left_invariant_map `: given a normal subgroup `Γ` of
  a topological group `G`, the pushforward to the quotient group `G ⧸ Γ` of the restriction of
  a both left- and right-invariant measure on `G` to a fundamental domain `𝓕` is a left-invariant
  measure on `G ⧸ Γ`.

Note that a group `G` with Haar measure that is both left and right invariant is called
**unimodular**.
-/


open Set MeasureTheory TopologicalSpace MeasureTheory.Measure

open Pointwise Nnreal

variable {G : Type _} [Group G] [MeasurableSpace G] [TopologicalSpace G] [TopologicalGroup G] [BorelSpace G]
  {μ : Measure G} {Γ : Subgroup G}

/-- Given a subgroup `Γ` of `G` and a right invariant measure `μ` on `G`, the measure is also
  invariant under the action of `Γ` on `G` by **right** multiplication. -/
@[to_additive
      "Given a subgroup `Γ` of an additive group `G` and a right invariant measure `μ` on\n  `G`, the measure is also invariant under the action of `Γ` on `G` by **right** addition."]
theorem Subgroup.smulInvariantMeasure [μ.IsMulRightInvariant] : SmulInvariantMeasure Γ.opposite G μ :=
  { measure_preimage_smul := by
      rintro ⟨c, hc⟩ s hs
      dsimp [(· • ·)]
      refine' measure_preimage_mul_right μ (MulOpposite.unop c) s }

/-- Measurability of the action of the topological group `G` on the left-coset space `G/Γ`. -/
@[to_additive "Measurability of the action of the additive topological group `G` on the left-coset\n  space `G/Γ`."]
instance QuotientGroup.hasMeasurableSmul [MeasurableSpace (G ⧸ Γ)] [BorelSpace (G ⧸ Γ)] :
    HasMeasurableSmul G (G ⧸ Γ) where
  measurableConstSmul g := (continuous_const_smul g).Measurable
  measurableSmulConst x := (QuotientGroup.continuous_smul₁ x).Measurable

variable {𝓕 : Set G} (h𝓕 : IsFundamentalDomain Γ.opposite 𝓕 μ)

include h𝓕

variable [Countable Γ] [MeasurableSpace (G ⧸ Γ)] [BorelSpace (G ⧸ Γ)]

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:52:50: missing argument -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr μ «expr ⁻¹' »(has_mul.mul g, «expr ∩ »(π_preA, «expr ⁻¹' »(has_mul.mul «expr ⁻¹»(g), 𝓕)))]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg -/
/-- The pushforward to the coset space `G ⧸ Γ` of the restriction of a both left- and right-
  invariant measure on `G` to a fundamental domain `𝓕` is a `G`-invariant measure on `G ⧸ Γ`. -/
@[to_additive
      "The pushforward to the coset space `G ⧸ Γ` of the restriction of a both left- and\n  right-invariant measure on an additive topological group `G` to a fundamental domain `𝓕` is a\n  `G`-invariant measure on `G ⧸ Γ`."]
theorem MeasureTheory.IsFundamentalDomain.smulInvariantMeasureMap [μ.IsMulLeftInvariant] [μ.IsMulRightInvariant] :
    SmulInvariantMeasure G (G ⧸ Γ) (Measure.map QuotientGroup.mk (μ.restrict 𝓕)) :=
  { measure_preimage_smul := by
      let π : G → G ⧸ Γ := QuotientGroup.mk
      have meas_π : Measurable π := continuous_quotient_mk.measurable
      have 𝓕meas : null_measurable_set 𝓕 μ := h𝓕.null_measurable_set
      intro g A hA
      have meas_πA : MeasurableSet (π ⁻¹' A) := measurableSetPreimage meas_π hA
      rw [measure.map_apply meas_π hA, measure.map_apply meas_π (measurableSetPreimage (measurable_const_smul g) hA),
        measure.restrict_apply₀' 𝓕meas, measure.restrict_apply₀' 𝓕meas]
      set π_preA := π ⁻¹' A
      have : QuotientGroup.mk ⁻¹' ((fun x : G ⧸ Γ => g • x) ⁻¹' A) = Mul.mul g ⁻¹' π_preA := by
        ext1
        simp
      rw [this]
      have : μ (Mul.mul g ⁻¹' π_preA ∩ 𝓕) = μ (π_preA ∩ Mul.mul g⁻¹ ⁻¹' 𝓕) := by
        trace
          "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr μ «expr ⁻¹' »(has_mul.mul g, «expr ∩ »(π_preA, «expr ⁻¹' »(has_mul.mul «expr ⁻¹»(g), 𝓕)))]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg"
        · rw [preimage_inter]
          congr
          rw [← preimage_comp, comp_mul_left, mul_left_inv]
          ext
          simp
          
        rw [measure_preimage_mul]
      rw [this]
      haveI : smul_invariant_measure (↥Γ.opposite) G μ := Subgroup.smulInvariantMeasure
      haveI : smul_invariant_measure G G μ := ⟨fun c s hs => measure_preimage_mul μ c s⟩
      -- Lean can generate the next instance but it has no additive version of the autogenerated proof
      haveI : SmulCommClass G Γ.opposite G := ⟨fun a b c => (mul_assoc _ _ _).symm⟩
      have h𝓕_translate_fundom : is_fundamental_domain Γ.opposite (g • 𝓕) μ := h𝓕.smul_of_comm g
      rw [h𝓕.measure_set_eq h𝓕_translate_fundom meas_πA, ← preimage_smul_inv]
      rfl
      rintro ⟨γ, γ_in_Γ⟩
      ext
      have : π (x * MulOpposite.unop γ) = π x := by simpa [QuotientGroup.eq'] using γ_in_Γ
      simp [(· • ·), this] }

/-- Assuming `Γ` is a normal subgroup of a topological group `G`, the pushforward to the quotient
  group `G ⧸ Γ` of the restriction of a both left- and right-invariant measure on `G` to a
  fundamental domain `𝓕` is a left-invariant measure on `G ⧸ Γ`. -/
@[to_additive
      "Assuming `Γ` is a normal subgroup of an additive topological group `G`, the\n  pushforward to the quotient group `G ⧸ Γ` of the restriction of a both left- and right-invariant\n  measure on `G` to a fundamental domain `𝓕` is a left-invariant measure on `G ⧸ Γ`."]
theorem MeasureTheory.IsFundamentalDomain.isMulLeftInvariantMap [Subgroup.Normal Γ] [μ.IsMulLeftInvariant]
    [μ.IsMulRightInvariant] : (Measure.map (QuotientGroup.mk' Γ) (μ.restrict 𝓕)).IsMulLeftInvariant :=
  { map_mul_left_eq_self := by
      intro x
      apply measure.ext
      intro A hA
      obtain ⟨x₁, _⟩ := @Quotient.exists_rep _ (QuotientGroup.leftRel Γ) x
      haveI := h𝓕.smul_invariant_measure_map
      convert measure_preimage_smul x₁ ((measure.map QuotientGroup.mk) (μ.restrict 𝓕)) A using 1
      rw [← h, measure.map_apply]
      · rfl
        
      · exact measurable_const_mul _
        
      · exact hA
         }

variable [T2Space (G ⧸ Γ)] [SecondCountableTopology (G ⧸ Γ)] (K : PositiveCompacts (G ⧸ Γ))

/-- Given a normal subgroup `Γ` of a topological group `G` with Haar measure `μ`, which is also
  right-invariant, and a finite volume fundamental domain `𝓕`, the pushforward to the quotient
  group `G ⧸ Γ` of the restriction of `μ` to `𝓕` is a multiple of Haar measure on `G ⧸ Γ`. -/
@[to_additive
      "Given a normal subgroup `Γ` of an additive topological group `G` with Haar measure\n  `μ`, which is also right-invariant, and a finite volume fundamental domain `𝓕`, the pushforward\n  to the quotient group `G ⧸ Γ` of the restriction of `μ` to `𝓕` is a multiple of Haar measure on\n  `G ⧸ Γ`."]
theorem MeasureTheory.IsFundamentalDomain.map_restrict_quotient [Subgroup.Normal Γ]
    [MeasureTheory.Measure.IsHaarMeasure μ] [μ.IsMulRightInvariant] (h𝓕_finite : μ 𝓕 < ⊤) :
    Measure.map (QuotientGroup.mk' Γ) (μ.restrict 𝓕) =
      μ (𝓕 ∩ QuotientGroup.mk' Γ ⁻¹' K) • MeasureTheory.Measure.haarMeasure K :=
  by
  let π : G →* G ⧸ Γ := QuotientGroup.mk' Γ
  have meas_π : Measurable π := continuous_quotient_mk.measurable
  have 𝓕meas : null_measurable_set 𝓕 μ := h𝓕.null_measurable_set
  haveI : is_finite_measure (μ.restrict 𝓕) :=
    ⟨by
      rw [measure.restrict_apply₀' 𝓕meas, univ_inter]
      exact h𝓕_finite⟩
  -- the measure is left-invariant, so by the uniqueness of Haar measure it's enough to show that
  -- it has the stated size on the reference compact set `K`.
  haveI : (measure.map (QuotientGroup.mk' Γ) (μ.restrict 𝓕)).IsMulLeftInvariant := h𝓕.is_mul_left_invariant_map
  rw [measure.haar_measure_unique (measure.map (QuotientGroup.mk' Γ) (μ.restrict 𝓕)) K, measure.map_apply meas_π,
    measure.restrict_apply₀' 𝓕meas, inter_comm]
  exact K.is_compact.measurable_set

/-- Given a normal subgroup `Γ` of a topological group `G` with Haar measure `μ`, which is also
  right-invariant, and a finite volume fundamental domain `𝓕`, the quotient map to `G ⧸ Γ` is
  measure-preserving between appropriate multiples of Haar measure on `G` and `G ⧸ Γ`. -/
@[to_additive MeasurePreservingQuotientAddGroup.mk'
      "Given a normal subgroup `Γ` of an additive\n  topological group `G` with Haar measure `μ`, which is also right-invariant, and a finite volume\n  fundamental domain `𝓕`, the quotient map to `G ⧸ Γ` is measure-preserving between appropriate\n  multiples of Haar measure on `G` and `G ⧸ Γ`."]
theorem MeasurePreservingQuotientGroup.mk' [Subgroup.Normal Γ] [MeasureTheory.Measure.IsHaarMeasure μ]
    [μ.IsMulRightInvariant] (h𝓕_finite : μ 𝓕 < ⊤) (c : ℝ≥0) (h : μ (𝓕 ∩ QuotientGroup.mk' Γ ⁻¹' K) = c) :
    MeasurePreserving (QuotientGroup.mk' Γ) (μ.restrict 𝓕) (c • MeasureTheory.Measure.haarMeasure K) :=
  { Measurable := continuous_quotient_mk.Measurable, map_eq := by rw [h𝓕.map_restrict_quotient K h𝓕_finite, h] <;> rfl }

