/-
Copyright (c) 2021 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying, Rémy Degenne

! This file was ported from Lean 3 source module probability.process.adapted
! leanprover-community/mathlib commit 44b58b42794e5abe2bf86397c38e26b587e07e59
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.Process.Filtration
import Mathbin.Topology.Instances.Discrete

/-!
# Adapted and progressively measurable processes

This file defines some standard definition from the theory of stochastic processes including
filtrations and stopping times. These definitions are used to model the amount of information
at a specific time and are the first step in formalizing stochastic processes.

## Main definitions

* `measure_theory.adapted`: a sequence of functions `u` is said to be adapted to a
  filtration `f` if at each point in time `i`, `u i` is `f i`-strongly measurable
* `measure_theory.prog_measurable`: a sequence of functions `u` is said to be progressively
  measurable with respect to a filtration `f` if at each point in time `i`, `u` restricted to
  `set.Iic i × Ω` is strongly measurable with respect to the product `measurable_space` structure
  where the σ-algebra used for `Ω` is `f i`.

## Main results

* `adapted.prog_measurable_of_continuous`: a continuous adapted process is progressively measurable.

## Tags

adapted, progressively measurable

-/


open Filter Order TopologicalSpace

open Classical MeasureTheory Nnreal Ennreal TopologicalSpace BigOperators

namespace MeasureTheory

variable {Ω β ι : Type _} {m : MeasurableSpace Ω} [TopologicalSpace β] [Preorder ι]
  {u v : ι → Ω → β} {f : Filtration ι m}

/-- A sequence of functions `u` is adapted to a filtration `f` if for all `i`,
`u i` is `f i`-measurable. -/
def Adapted (f : Filtration ι m) (u : ι → Ω → β) : Prop :=
  ∀ i : ι, strongly_measurable[f i] (u i)
#align measure_theory.adapted MeasureTheory.Adapted

namespace Adapted

@[protected, to_additive]
theorem mul [Mul β] [HasContinuousMul β] (hu : Adapted f u) (hv : Adapted f v) :
    Adapted f (u * v) := fun i => (hu i).mul (hv i)
#align measure_theory.adapted.mul MeasureTheory.Adapted.mul

@[protected, to_additive]
theorem div [Div β] [HasContinuousDiv β] (hu : Adapted f u) (hv : Adapted f v) :
    Adapted f (u / v) := fun i => (hu i).div (hv i)
#align measure_theory.adapted.div MeasureTheory.Adapted.div

@[protected, to_additive]
theorem inv [Group β] [TopologicalGroup β] (hu : Adapted f u) : Adapted f u⁻¹ := fun i => (hu i).inv
#align measure_theory.adapted.inv MeasureTheory.Adapted.inv

@[protected]
theorem smul [HasSmul ℝ β] [HasContinuousSmul ℝ β] (c : ℝ) (hu : Adapted f u) : Adapted f (c • u) :=
  fun i => (hu i).const_smul c
#align measure_theory.adapted.smul MeasureTheory.Adapted.smul

@[protected]
theorem strongly_measurable {i : ι} (hf : Adapted f u) : strongly_measurable[m] (u i) :=
  (hf i).mono (f.le i)
#align measure_theory.adapted.strongly_measurable MeasureTheory.Adapted.strongly_measurable

theorem strongly_measurable_le {i j : ι} (hf : Adapted f u) (hij : i ≤ j) :
    strongly_measurable[f j] (u i) :=
  (hf i).mono (f.mono hij)
#align measure_theory.adapted.strongly_measurable_le MeasureTheory.Adapted.strongly_measurable_le

end Adapted

theorem adapted_const (f : Filtration ι m) (x : β) : Adapted f fun _ _ => x := fun i =>
  strongly_measurable_const
#align measure_theory.adapted_const MeasureTheory.adapted_const

variable (β)

theorem adapted_zero [Zero β] (f : Filtration ι m) : Adapted f (0 : ι → Ω → β) := fun i =>
  @strongly_measurable_zero Ω β (f i) _ _
#align measure_theory.adapted_zero MeasureTheory.adapted_zero

variable {β}

theorem Filtration.adapted_natural [MetrizableSpace β] [mβ : MeasurableSpace β] [BorelSpace β]
    {u : ι → Ω → β} (hum : ∀ i, strongly_measurable[m] (u i)) :
    Adapted (Filtration.natural u hum) u := by
  intro i
  refine' strongly_measurable.mono _ (le_supᵢ₂_of_le i (le_refl i) le_rfl)
  rw [strongly_measurable_iff_measurable_separable]
  exact ⟨measurable_iff_comap_le.2 le_rfl, (hum i).is_separable_range⟩
#align measure_theory.filtration.adapted_natural MeasureTheory.Filtration.adapted_natural

/-- Progressively measurable process. A sequence of functions `u` is said to be progressively
measurable with respect to a filtration `f` if at each point in time `i`, `u` restricted to
`set.Iic i × Ω` is measurable with respect to the product `measurable_space` structure where the
σ-algebra used for `Ω` is `f i`.
The usual definition uses the interval `[0,i]`, which we replace by `set.Iic i`. We recover the
usual definition for index types `ℝ≥0` or `ℕ`. -/
def ProgMeasurable [MeasurableSpace ι] (f : Filtration ι m) (u : ι → Ω → β) : Prop :=
  ∀ i, strongly_measurable[Subtype.measurableSpace.Prod (f i)] fun p : Set.Iic i × Ω => u p.1 p.2
#align measure_theory.prog_measurable MeasureTheory.ProgMeasurable

theorem prog_measurable_const [MeasurableSpace ι] (f : Filtration ι m) (b : β) :
    ProgMeasurable f (fun _ _ => b : ι → Ω → β) := fun i =>
  @strongly_measurable_const _ _ (Subtype.measurableSpace.Prod (f i)) _ _
#align measure_theory.prog_measurable_const MeasureTheory.prog_measurable_const

namespace ProgMeasurable

variable [MeasurableSpace ι]

protected theorem adapted (h : ProgMeasurable f u) : Adapted f u :=
  by
  intro i
  have : u i = (fun p : Set.Iic i × Ω => u p.1 p.2) ∘ fun x => (⟨i, set.mem_Iic.mpr le_rfl⟩, x) :=
    rfl
  rw [this]
  exact (h i).compMeasurable measurable_prod_mk_left
#align measure_theory.prog_measurable.adapted MeasureTheory.ProgMeasurable.adapted

protected theorem comp {t : ι → Ω → ι} [TopologicalSpace ι] [BorelSpace ι] [MetrizableSpace ι]
    (h : ProgMeasurable f u) (ht : ProgMeasurable f t) (ht_le : ∀ i ω, t i ω ≤ i) :
    ProgMeasurable f fun i ω => u (t i ω) ω :=
  by
  intro i
  have :
    (fun p : ↥(Set.Iic i) × Ω => u (t (p.fst : ι) p.snd) p.snd) =
      (fun p : ↥(Set.Iic i) × Ω => u (p.fst : ι) p.snd) ∘ fun p : ↥(Set.Iic i) × Ω =>
        (⟨t (p.fst : ι) p.snd, set.mem_Iic.mpr ((ht_le _ _).trans p.fst.prop)⟩, p.snd) :=
    rfl
  rw [this]
  exact (h i).compMeasurable ((ht i).Measurable.subtype_mk.prod_mk measurable_snd)
#align measure_theory.prog_measurable.comp MeasureTheory.ProgMeasurable.comp

section Arithmetic

@[to_additive]
protected theorem mul [Mul β] [HasContinuousMul β] (hu : ProgMeasurable f u)
    (hv : ProgMeasurable f v) : ProgMeasurable f fun i ω => u i ω * v i ω := fun i =>
  (hu i).mul (hv i)
#align measure_theory.prog_measurable.mul MeasureTheory.ProgMeasurable.mul

@[to_additive]
protected theorem finset_prod' {γ} [CommMonoid β] [HasContinuousMul β] {U : γ → ι → Ω → β}
    {s : Finset γ} (h : ∀ c ∈ s, ProgMeasurable f (U c)) : ProgMeasurable f (∏ c in s, U c) :=
  Finset.prod_induction U (ProgMeasurable f) (fun _ _ => ProgMeasurable.mul)
    (prog_measurable_const _ 1) h
#align measure_theory.prog_measurable.finset_prod' MeasureTheory.ProgMeasurable.finset_prod'

@[to_additive]
protected theorem finset_prod {γ} [CommMonoid β] [HasContinuousMul β] {U : γ → ι → Ω → β}
    {s : Finset γ} (h : ∀ c ∈ s, ProgMeasurable f (U c)) :
    ProgMeasurable f fun i a => ∏ c in s, U c i a :=
  by
  convert prog_measurable.finset_prod' h
  ext (i a)
  simp only [Finset.prod_apply]
#align measure_theory.prog_measurable.finset_prod MeasureTheory.ProgMeasurable.finset_prod

@[to_additive]
protected theorem inv [Group β] [TopologicalGroup β] (hu : ProgMeasurable f u) :
    ProgMeasurable f fun i ω => (u i ω)⁻¹ := fun i => (hu i).inv
#align measure_theory.prog_measurable.inv MeasureTheory.ProgMeasurable.inv

@[to_additive]
protected theorem div [Group β] [TopologicalGroup β] (hu : ProgMeasurable f u)
    (hv : ProgMeasurable f v) : ProgMeasurable f fun i ω => u i ω / v i ω := fun i =>
  (hu i).div (hv i)
#align measure_theory.prog_measurable.div MeasureTheory.ProgMeasurable.div

end Arithmetic

end ProgMeasurable

theorem prog_measurable_of_tendsto' {γ} [MeasurableSpace ι] [PseudoMetrizableSpace β]
    (fltr : Filter γ) [fltr.ne_bot] [fltr.IsCountablyGenerated] {U : γ → ι → Ω → β}
    (h : ∀ l, ProgMeasurable f (U l)) (h_tendsto : Tendsto U fltr (𝓝 u)) : ProgMeasurable f u :=
  by
  intro i
  apply
    @strongly_measurable_of_tendsto (Set.Iic i × Ω) β γ (MeasurableSpace.prod _ (f i)) _ _ fltr _ _
      _ _ fun l => h l i
  rw [tendsto_pi_nhds] at h_tendsto⊢
  intro x
  specialize h_tendsto x.fst
  rw [tendsto_nhds] at h_tendsto⊢
  exact fun s hs h_mem => h_tendsto { g | g x.snd ∈ s } (hs.Preimage (continuous_apply x.snd)) h_mem
#align measure_theory.prog_measurable_of_tendsto' MeasureTheory.prog_measurable_of_tendsto'

theorem prog_measurable_of_tendsto [MeasurableSpace ι] [PseudoMetrizableSpace β] {U : ℕ → ι → Ω → β}
    (h : ∀ l, ProgMeasurable f (U l)) (h_tendsto : Tendsto U atTop (𝓝 u)) : ProgMeasurable f u :=
  prog_measurable_of_tendsto' atTop h h_tendsto
#align measure_theory.prog_measurable_of_tendsto MeasureTheory.prog_measurable_of_tendsto

/-- A continuous and adapted process is progressively measurable. -/
theorem Adapted.prog_measurable_of_continuous [TopologicalSpace ι] [MetrizableSpace ι]
    [SecondCountableTopology ι] [MeasurableSpace ι] [OpensMeasurableSpace ι]
    [PseudoMetrizableSpace β] (h : Adapted f u) (hu_cont : ∀ ω, Continuous fun i => u i ω) :
    ProgMeasurable f u := fun i =>
  @strongly_measurable_uncurry_of_continuous_of_strongly_measurable _ _ (Set.Iic i) _ _ _ _ _ _ _
    (f i) _ (fun ω => (hu_cont ω).comp continuous_induced_dom) fun j => (h j).mono (f.mono j.Prop)
#align
  measure_theory.adapted.prog_measurable_of_continuous MeasureTheory.Adapted.prog_measurable_of_continuous

/-- For filtrations indexed by a discrete order, `adapted` and `prog_measurable` are equivalent.
This lemma provides `adapted f u → prog_measurable f u`.
See `prog_measurable.adapted` for the reverse direction, which is true more generally. -/
theorem Adapted.prog_measurable_of_discrete [TopologicalSpace ι] [DiscreteTopology ι]
    [SecondCountableTopology ι] [MeasurableSpace ι] [OpensMeasurableSpace ι]
    [PseudoMetrizableSpace β] (h : Adapted f u) : ProgMeasurable f u :=
  h.prog_measurable_of_continuous fun _ => continuous_of_discrete_topology
#align
  measure_theory.adapted.prog_measurable_of_discrete MeasureTheory.Adapted.prog_measurable_of_discrete

-- this dot notation will make more sense once we have a more general definition for predictable
theorem Predictable.adapted {f : Filtration ℕ m} {u : ℕ → Ω → β} (hu : Adapted f fun n => u (n + 1))
    (hu0 : strongly_measurable[f 0] (u 0)) : Adapted f u := fun n =>
  match n with
  | 0 => hu0
  | n + 1 => (hu n).mono (f.mono n.le_succ)
#align measure_theory.predictable.adapted MeasureTheory.Predictable.adapted

end MeasureTheory

