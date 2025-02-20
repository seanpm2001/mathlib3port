/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module measure_theory.group.action
! leanprover-community/mathlib commit 61b5e2755ccb464b68d05a9acf891ae04992d09d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Group.MeasurableEquiv
import Mathbin.MeasureTheory.Measure.Regular
import Mathbin.Dynamics.Ergodic.MeasurePreserving
import Mathbin.Dynamics.Minimal

/-!
# Measures invariant under group actions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A measure `μ : measure α` is said to be *invariant* under an action of a group `G` if scalar
multiplication by `c : G` is a measure preserving map for all `c`. In this file we define a
typeclass for measures invariant under action of an (additive or multiplicative) group and prove
some basic properties of such measures.
-/


open scoped ENNReal NNReal Pointwise Topology

open MeasureTheory MeasureTheory.Measure Set Function

namespace MeasureTheory

variable {G M α : Type _} {s : Set α}

#print MeasureTheory.VAddInvariantMeasure /-
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`measure_preimage_vadd] [] -/
/-- A measure `μ : measure α` is invariant under an additive action of `M` on `α` if for any
measurable set `s : set α` and `c : M`, the measure of its preimage under `λ x, c +ᵥ x` is equal to
the measure of `s`. -/
class VAddInvariantMeasure (M α : Type _) [VAdd M α] {_ : MeasurableSpace α} (μ : Measure α) :
    Prop where
  measure_preimage_vadd : ∀ (c : M) ⦃s : Set α⦄, MeasurableSet s → μ ((fun x => c +ᵥ x) ⁻¹' s) = μ s
#align measure_theory.vadd_invariant_measure MeasureTheory.VAddInvariantMeasure
-/

#print MeasureTheory.SMulInvariantMeasure /-
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`measure_preimage_smul] [] -/
/-- A measure `μ : measure α` is invariant under a multiplicative action of `M` on `α` if for any
measurable set `s : set α` and `c : M`, the measure of its preimage under `λ x, c • x` is equal to
the measure of `s`. -/
@[to_additive]
class SMulInvariantMeasure (M α : Type _) [SMul M α] {_ : MeasurableSpace α} (μ : Measure α) :
    Prop where
  measure_preimage_smul : ∀ (c : M) ⦃s : Set α⦄, MeasurableSet s → μ ((fun x => c • x) ⁻¹' s) = μ s
#align measure_theory.smul_invariant_measure MeasureTheory.SMulInvariantMeasure
#align measure_theory.vadd_invariant_measure MeasureTheory.VAddInvariantMeasure
-/

namespace SmulInvariantMeasure

#print MeasureTheory.SMulInvariantMeasure.zero /-
@[to_additive]
instance zero [MeasurableSpace α] [SMul M α] : SMulInvariantMeasure M α 0 :=
  ⟨fun _ _ _ => rfl⟩
#align measure_theory.smul_invariant_measure.zero MeasureTheory.SMulInvariantMeasure.zero
#align measure_theory.vadd_invariant_measure.zero MeasureTheory.VAddInvariantMeasure.zero
-/

variable [SMul M α] {m : MeasurableSpace α} {μ ν : Measure α}

#print MeasureTheory.SMulInvariantMeasure.add /-
@[to_additive]
instance add [SMulInvariantMeasure M α μ] [SMulInvariantMeasure M α ν] :
    SMulInvariantMeasure M α (μ + ν) :=
  ⟨fun c s hs =>
    show _ + _ = _ + _ from
      congr_arg₂ (· + ·) (measure_preimage_smul μ c hs) (measure_preimage_smul ν c hs)⟩
#align measure_theory.smul_invariant_measure.add MeasureTheory.SMulInvariantMeasure.add
#align measure_theory.vadd_invariant_measure.add MeasureTheory.VAddInvariantMeasure.add
-/

#print MeasureTheory.SMulInvariantMeasure.smul /-
@[to_additive]
instance smul [SMulInvariantMeasure M α μ] (c : ℝ≥0∞) : SMulInvariantMeasure M α (c • μ) :=
  ⟨fun a s hs => show c • _ = c • _ from congr_arg ((· • ·) c) (measure_preimage_smul μ a hs)⟩
#align measure_theory.smul_invariant_measure.smul MeasureTheory.SMulInvariantMeasure.smul
#align measure_theory.vadd_invariant_measure.vadd MeasureTheory.VAddInvariantMeasure.vadd
-/

#print MeasureTheory.SMulInvariantMeasure.smul_nnreal /-
@[to_additive]
instance smul_nnreal [SMulInvariantMeasure M α μ] (c : ℝ≥0) : SMulInvariantMeasure M α (c • μ) :=
  SMulInvariantMeasure.smul c
#align measure_theory.smul_invariant_measure.smul_nnreal MeasureTheory.SMulInvariantMeasure.smul_nnreal
#align measure_theory.vadd_invariant_measure.vadd_nnreal MeasureTheory.VAddInvariantMeasure.vadd_nnreal
-/

end SmulInvariantMeasure

section MeasurableSMul

variable {m : MeasurableSpace α} [MeasurableSpace M] [SMul M α] [MeasurableSMul M α] (c : M)
  (μ : Measure α) [SMulInvariantMeasure M α μ]

#print MeasureTheory.measurePreserving_smul /-
@[simp, to_additive]
theorem measurePreserving_smul : MeasurePreserving ((· • ·) c) μ μ :=
  { Measurable := measurable_const_smul c
    map_eq := by
      ext1 s hs
      rw [map_apply (measurable_const_smul c) hs]
      exact smul_invariant_measure.measure_preimage_smul μ c hs }
#align measure_theory.measure_preserving_smul MeasureTheory.measurePreserving_smul
#align measure_theory.measure_preserving_vadd MeasureTheory.measurePreserving_vadd
-/

#print MeasureTheory.map_smul /-
@[simp, to_additive]
theorem map_smul : map ((· • ·) c) μ = μ :=
  (measurePreserving_smul c μ).map_eq
#align measure_theory.map_smul MeasureTheory.map_smul
#align measure_theory.map_vadd MeasureTheory.map_vadd
-/

end MeasurableSMul

variable (G) {m : MeasurableSpace α} [Group G] [MulAction G α] [MeasurableSpace G]
  [MeasurableSMul G α] (c : G) (μ : Measure α)

#print MeasureTheory.smulInvariantMeasure_tfae /-
/-- Equivalent definitions of a measure invariant under a multiplicative action of a group.

- 0: `smul_invariant_measure G α μ`;

- 1: for every `c : G` and a measurable set `s`, the measure of the preimage of `s` under scalar
     multiplication by `c` is equal to the measure of `s`;

- 2: for every `c : G` and a measurable set `s`, the measure of the image `c • s` of `s` under
     scalar multiplication by `c` is equal to the measure of `s`;

- 3, 4: properties 2, 3 for any set, including non-measurable ones;

- 5: for any `c : G`, scalar multiplication by `c` maps `μ` to `μ`;

- 6: for any `c : G`, scalar multiplication by `c` is a measure preserving map. -/
@[to_additive]
theorem smulInvariantMeasure_tfae :
    TFAE
      [SMulInvariantMeasure G α μ, ∀ (c : G) (s), MeasurableSet s → μ ((· • ·) c ⁻¹' s) = μ s,
        ∀ (c : G) (s), MeasurableSet s → μ (c • s) = μ s, ∀ (c : G) (s), μ ((· • ·) c ⁻¹' s) = μ s,
        ∀ (c : G) (s), μ (c • s) = μ s, ∀ c : G, Measure.map ((· • ·) c) μ = μ,
        ∀ c : G, MeasurePreserving ((· • ·) c) μ μ] :=
  by
  tfae_have 1 ↔ 2; exact ⟨fun h => h.1, fun h => ⟨h⟩⟩
  tfae_have 1 → 6; · intro h c; exact (measure_preserving_smul c μ).map_eq
  tfae_have 6 → 7; exact fun H c => ⟨measurable_const_smul c, H c⟩
  tfae_have 7 → 4; exact fun H c => (H c).measure_preimage_emb (measurableEmbedding_const_smul c)
  tfae_have 4 → 5; exact fun H c s => by rw [← preimage_smul_inv]; apply H
  tfae_have 5 → 3; exact fun H c s hs => H c s
  tfae_have 3 → 2; · intro H c s hs; rw [preimage_smul]; exact H c⁻¹ s hs
  tfae_finish
#align measure_theory.smul_invariant_measure_tfae MeasureTheory.smulInvariantMeasure_tfae
#align measure_theory.vadd_invariant_measure_tfae MeasureTheory.vaddInvariantMeasure_tfae
-/

/-- Equivalent definitions of a measure invariant under an additive action of a group.

- 0: `vadd_invariant_measure G α μ`;

- 1: for every `c : G` and a measurable set `s`, the measure of the preimage of `s` under
     vector addition `(+ᵥ) c` is equal to the measure of `s`;

- 2: for every `c : G` and a measurable set `s`, the measure of the image `c +ᵥ s` of `s` under
     vector addition `(+ᵥ) c` is equal to the measure of `s`;

- 3, 4: properties 2, 3 for any set, including non-measurable ones;

- 5: for any `c : G`, vector addition of `c` maps `μ` to `μ`;

- 6: for any `c : G`, vector addition of `c` is a measure preserving map. -/
add_decl_doc vadd_invariant_measure_tfae

variable {G} [SMulInvariantMeasure G α μ]

#print MeasureTheory.measure_preimage_smul /-
@[simp, to_additive]
theorem measure_preimage_smul (s : Set α) : μ ((· • ·) c ⁻¹' s) = μ s :=
  ((smulInvariantMeasure_tfae G μ).out 0 3).mp ‹_› c s
#align measure_theory.measure_preimage_smul MeasureTheory.measure_preimage_smul
#align measure_theory.measure_preimage_vadd MeasureTheory.measure_preimage_vadd
-/

#print MeasureTheory.measure_smul /-
@[simp, to_additive]
theorem measure_smul (s : Set α) : μ (c • s) = μ s :=
  ((smulInvariantMeasure_tfae G μ).out 0 4).mp ‹_› c s
#align measure_theory.measure_smul MeasureTheory.measure_smul
#align measure_theory.measure_vadd MeasureTheory.measure_vadd
-/

variable {μ}

#print MeasureTheory.NullMeasurableSet.smul /-
@[to_additive]
theorem NullMeasurableSet.smul {s} (hs : NullMeasurableSet s μ) (c : G) :
    NullMeasurableSet (c • s) μ := by
  simpa only [← preimage_smul_inv] using
    hs.preimage (measure_preserving_smul _ _).QuasiMeasurePreserving
#align measure_theory.null_measurable_set.smul MeasureTheory.NullMeasurableSet.smul
#align measure_theory.null_measurable_set.vadd MeasureTheory.NullMeasurableSet.vadd
-/

#print MeasureTheory.measure_smul_null /-
theorem measure_smul_null {s} (h : μ s = 0) (c : G) : μ (c • s) = 0 := by rwa [measure_smul]
#align measure_theory.measure_smul_null MeasureTheory.measure_smul_null
-/

section IsMinimal

variable (G) [TopologicalSpace α] [ContinuousConstSMul G α] [MulAction.IsMinimal G α] {K U : Set α}

#print MeasureTheory.measure_isOpen_pos_of_smulInvariant_of_compact_ne_zero /-
/-- If measure `μ` is invariant under a group action and is nonzero on a compact set `K`, then it is
positive on any nonempty open set. In case of a regular measure, one can assume `μ ≠ 0` instead of
`μ K ≠ 0`, see `measure_theory.measure_is_open_pos_of_smul_invariant_of_ne_zero`. -/
@[to_additive]
theorem measure_isOpen_pos_of_smulInvariant_of_compact_ne_zero (hK : IsCompact K) (hμK : μ K ≠ 0)
    (hU : IsOpen U) (hne : U.Nonempty) : 0 < μ U :=
  let ⟨t, ht⟩ := hK.exists_finite_cover_smul G hU hne
  pos_iff_ne_zero.2 fun hμU =>
    hμK <|
      measure_mono_null ht <|
        (measure_biUnion_null_iff t.countable_toSet).2 fun _ _ => by rwa [measure_smul]
#align measure_theory.measure_is_open_pos_of_smul_invariant_of_compact_ne_zero MeasureTheory.measure_isOpen_pos_of_smulInvariant_of_compact_ne_zero
#align measure_theory.measure_is_open_pos_of_vadd_invariant_of_compact_ne_zero MeasureTheory.measure_isOpen_pos_of_vaddInvariant_of_compact_ne_zero
-/

/-- If measure `μ` is invariant under an additive group action and is nonzero on a compact set `K`,
then it is positive on any nonempty open set. In case of a regular measure, one can assume `μ ≠ 0`
instead of `μ K ≠ 0`, see `measure_theory.measure_is_open_pos_of_vadd_invariant_of_ne_zero`. -/
add_decl_doc measure_is_open_pos_of_vadd_invariant_of_compact_ne_zero

#print MeasureTheory.isLocallyFiniteMeasure_of_smulInvariant /-
@[to_additive]
theorem isLocallyFiniteMeasure_of_smulInvariant (hU : IsOpen U) (hne : U.Nonempty) (hμU : μ U ≠ ∞) :
    IsLocallyFiniteMeasure μ :=
  ⟨fun x =>
    let ⟨g, hg⟩ := hU.exists_smul_mem G x hne
    ⟨(· • ·) g ⁻¹' U, (hU.Preimage (continuous_id.const_smul _)).mem_nhds hg,
      Ne.lt_top <| by rwa [measure_preimage_smul]⟩⟩
#align measure_theory.is_locally_finite_measure_of_smul_invariant MeasureTheory.isLocallyFiniteMeasure_of_smulInvariant
#align measure_theory.is_locally_finite_measure_of_vadd_invariant MeasureTheory.isLocallyFiniteMeasure_of_vaddInvariant
-/

variable [Measure.Regular μ]

#print MeasureTheory.measure_isOpen_pos_of_smulInvariant_of_ne_zero /-
@[to_additive]
theorem measure_isOpen_pos_of_smulInvariant_of_ne_zero (hμ : μ ≠ 0) (hU : IsOpen U)
    (hne : U.Nonempty) : 0 < μ U :=
  let ⟨K, hK, hμK⟩ := Regular.exists_compact_not_null.mpr hμ
  measure_isOpen_pos_of_smulInvariant_of_compact_ne_zero G hK hμK hU hne
#align measure_theory.measure_is_open_pos_of_smul_invariant_of_ne_zero MeasureTheory.measure_isOpen_pos_of_smulInvariant_of_ne_zero
#align measure_theory.measure_is_open_pos_of_vadd_invariant_of_ne_zero MeasureTheory.measure_isOpen_pos_of_vaddInvariant_of_ne_zero
-/

#print MeasureTheory.measure_pos_iff_nonempty_of_smulInvariant /-
@[to_additive]
theorem measure_pos_iff_nonempty_of_smulInvariant (hμ : μ ≠ 0) (hU : IsOpen U) :
    0 < μ U ↔ U.Nonempty :=
  ⟨fun h => nonempty_of_measure_ne_zero h.ne',
    measure_isOpen_pos_of_smulInvariant_of_ne_zero G hμ hU⟩
#align measure_theory.measure_pos_iff_nonempty_of_smul_invariant MeasureTheory.measure_pos_iff_nonempty_of_smulInvariant
#align measure_theory.measure_pos_iff_nonempty_of_vadd_invariant MeasureTheory.measure_pos_iff_nonempty_of_vaddInvariant
-/

#print MeasureTheory.measure_eq_zero_iff_eq_empty_of_smulInvariant /-
@[to_additive]
theorem measure_eq_zero_iff_eq_empty_of_smulInvariant (hμ : μ ≠ 0) (hU : IsOpen U) :
    μ U = 0 ↔ U = ∅ := by
  rw [← not_iff_not, ← Ne.def, ← pos_iff_ne_zero,
    measure_pos_iff_nonempty_of_smul_invariant G hμ hU, nonempty_iff_ne_empty]
#align measure_theory.measure_eq_zero_iff_eq_empty_of_smul_invariant MeasureTheory.measure_eq_zero_iff_eq_empty_of_smulInvariant
#align measure_theory.measure_eq_zero_iff_eq_empty_of_vadd_invariant MeasureTheory.measure_eq_zero_iff_eq_empty_of_vaddInvariant
-/

end IsMinimal

#print MeasureTheory.smul_ae_eq_self_of_mem_zpowers /-
theorem smul_ae_eq_self_of_mem_zpowers {x y : G} (hs : (x • s : Set α) =ᵐ[μ] s)
    (hy : y ∈ Subgroup.zpowers x) : (y • s : Set α) =ᵐ[μ] s :=
  by
  obtain ⟨k, rfl⟩ := subgroup.mem_zpowers_iff.mp hy
  let e : α ≃ α := MulAction.toPermHom G α x
  have he : quasi_measure_preserving e μ μ := (measure_preserving_smul x μ).QuasiMeasurePreserving
  have he' : quasi_measure_preserving e.symm μ μ :=
    (measure_preserving_smul x⁻¹ μ).QuasiMeasurePreserving
  simpa only [MulAction.toPermHom_apply, MulAction.toPerm_apply, image_smul, ←
    MonoidHom.map_zpow] using he.image_zpow_ae_eq he' k hs
#align measure_theory.smul_ae_eq_self_of_mem_zpowers MeasureTheory.smul_ae_eq_self_of_mem_zpowers
-/

#print MeasureTheory.vadd_ae_eq_self_of_mem_zmultiples /-
theorem vadd_ae_eq_self_of_mem_zmultiples {G : Type _} [MeasurableSpace G] [AddGroup G]
    [AddAction G α] [VAddInvariantMeasure G α μ] [MeasurableVAdd G α] {x y : G}
    (hs : (x +ᵥ s : Set α) =ᵐ[μ] s) (hy : y ∈ AddSubgroup.zmultiples x) :
    (y +ᵥ s : Set α) =ᵐ[μ] s :=
  by
  letI : MeasurableSpace (Multiplicative G) := (by infer_instance : MeasurableSpace G)
  letI : smul_invariant_measure (Multiplicative G) α μ :=
    ⟨fun g => vadd_invariant_measure.measure_preimage_vadd μ (Multiplicative.toAdd g)⟩
  letI : MeasurableSMul (Multiplicative G) α :=
    { measurable_const_smul := fun g => measurable_const_vadd (Multiplicative.toAdd g)
      measurable_smul_const := fun a =>
        @measurable_vadd_const (Multiplicative G) α (by infer_instance : VAdd G α) _ _
          (by infer_instance : MeasurableVAdd G α) a }
  exact @smul_ae_eq_self_of_mem_zpowers (Multiplicative G) α _ _ _ _ _ _ _ _ _ _ hs hy
#align measure_theory.vadd_ae_eq_self_of_mem_zmultiples MeasureTheory.vadd_ae_eq_self_of_mem_zmultiples
-/

attribute [to_additive vadd_ae_eq_self_of_mem_zmultiples] smul_ae_eq_self_of_mem_zpowers

end MeasureTheory

