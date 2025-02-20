/-
Copyright (c) 2021 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne, Kexing Ying

! This file was ported from Lean 3 source module probability.martingale.basic
! leanprover-community/mathlib commit f2ad3645af9effcdb587637dc28a6074edc813f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.Notation
import Mathbin.Probability.Process.Stopping

/-!
# Martingales

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A family of functions `f : ι → Ω → E` is a martingale with respect to a filtration `ℱ` if every
`f i` is integrable, `f` is adapted with respect to `ℱ` and for all `i ≤ j`,
`μ[f j | ℱ i] =ᵐ[μ] f i`. On the other hand, `f : ι → Ω → E` is said to be a supermartingale
with respect to the filtration `ℱ` if `f i` is integrable, `f` is adapted with resepct to `ℱ`
and for all `i ≤ j`, `μ[f j | ℱ i] ≤ᵐ[μ] f i`. Finally, `f : ι → Ω → E` is said to be a
submartingale with respect to the filtration `ℱ` if `f i` is integrable, `f` is adapted with
resepct to `ℱ` and for all `i ≤ j`, `f i ≤ᵐ[μ] μ[f j | ℱ i]`.

The definitions of filtration and adapted can be found in `probability.stopping`.

### Definitions

* `measure_theory.martingale f ℱ μ`: `f` is a martingale with respect to filtration `ℱ` and
  measure `μ`.
* `measure_theory.supermartingale f ℱ μ`: `f` is a supermartingale with respect to
  filtration `ℱ` and measure `μ`.
* `measure_theory.submartingale f ℱ μ`: `f` is a submartingale with respect to filtration `ℱ` and
  measure `μ`.

### Results

* `measure_theory.martingale_condexp f ℱ μ`: the sequence `λ i, μ[f | ℱ i, ℱ.le i])` is a
  martingale with respect to `ℱ` and `μ`.

-/


open TopologicalSpace Filter

open scoped NNReal ENNReal MeasureTheory ProbabilityTheory BigOperators

namespace MeasureTheory

variable {Ω E ι : Type _} [Preorder ι] {m0 : MeasurableSpace Ω} {μ : Measure Ω}
  [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E] {f g : ι → Ω → E} {ℱ : Filtration ι m0}

#print MeasureTheory.Martingale /-
/-- A family of functions `f : ι → Ω → E` is a martingale with respect to a filtration `ℱ` if `f`
is adapted with respect to `ℱ` and for all `i ≤ j`, `μ[f j | ℱ i] =ᵐ[μ] f i`. -/
def Martingale (f : ι → Ω → E) (ℱ : Filtration ι m0)
    (μ : Measure Ω := by exact MeasureTheory.MeasureSpace.volume) : Prop :=
  Adapted ℱ f ∧ ∀ i j, i ≤ j → μ[f j|ℱ i] =ᵐ[μ] f i
#align measure_theory.martingale MeasureTheory.Martingale
-/

#print MeasureTheory.Supermartingale /-
/-- A family of integrable functions `f : ι → Ω → E` is a supermartingale with respect to a
filtration `ℱ` if `f` is adapted with respect to `ℱ` and for all `i ≤ j`,
`μ[f j | ℱ.le i] ≤ᵐ[μ] f i`. -/
def Supermartingale [LE E] (f : ι → Ω → E) (ℱ : Filtration ι m0)
    (μ : Measure Ω := by exact MeasureTheory.MeasureSpace.volume) : Prop :=
  Adapted ℱ f ∧ (∀ i j, i ≤ j → μ[f j|ℱ i] ≤ᵐ[μ] f i) ∧ ∀ i, Integrable (f i) μ
#align measure_theory.supermartingale MeasureTheory.Supermartingale
-/

#print MeasureTheory.Submartingale /-
/-- A family of integrable functions `f : ι → Ω → E` is a submartingale with respect to a
filtration `ℱ` if `f` is adapted with respect to `ℱ` and for all `i ≤ j`,
`f i ≤ᵐ[μ] μ[f j | ℱ.le i]`. -/
def Submartingale [LE E] (f : ι → Ω → E) (ℱ : Filtration ι m0)
    (μ : Measure Ω := by exact MeasureTheory.MeasureSpace.volume) : Prop :=
  Adapted ℱ f ∧ (∀ i j, i ≤ j → f i ≤ᵐ[μ] μ[f j|ℱ i]) ∧ ∀ i, Integrable (f i) μ
#align measure_theory.submartingale MeasureTheory.Submartingale
-/

#print MeasureTheory.martingale_const /-
theorem martingale_const (ℱ : Filtration ι m0) (μ : Measure Ω) [IsFiniteMeasure μ] (x : E) :
    Martingale (fun _ _ => x) ℱ μ :=
  ⟨adapted_const ℱ _, fun i j hij => by rw [condexp_const (ℱ.le _)]⟩
#align measure_theory.martingale_const MeasureTheory.martingale_const
-/

#print MeasureTheory.martingale_const_fun /-
theorem martingale_const_fun [OrderBot ι] (ℱ : Filtration ι m0) (μ : Measure Ω) [IsFiniteMeasure μ]
    {f : Ω → E} (hf : strongly_measurable[ℱ ⊥] f) (hfint : Integrable f μ) :
    Martingale (fun _ => f) ℱ μ :=
  by
  refine' ⟨fun i => hf.mono <| ℱ.mono bot_le, fun i j hij => _⟩
  rw [condexp_of_strongly_measurable (ℱ.le _) (hf.mono <| ℱ.mono bot_le) hfint]
  infer_instance
#align measure_theory.martingale_const_fun MeasureTheory.martingale_const_fun
-/

variable (E)

#print MeasureTheory.martingale_zero /-
theorem martingale_zero (ℱ : Filtration ι m0) (μ : Measure Ω) : Martingale (0 : ι → Ω → E) ℱ μ :=
  ⟨adapted_zero E ℱ, fun i j hij => by rw [Pi.zero_apply, condexp_zero]; simp⟩
#align measure_theory.martingale_zero MeasureTheory.martingale_zero
-/

variable {E}

namespace Martingale

#print MeasureTheory.Martingale.adapted /-
@[protected]
theorem adapted (hf : Martingale f ℱ μ) : Adapted ℱ f :=
  hf.1
#align measure_theory.martingale.adapted MeasureTheory.Martingale.adapted
-/

#print MeasureTheory.Martingale.stronglyMeasurable /-
@[protected]
theorem stronglyMeasurable (hf : Martingale f ℱ μ) (i : ι) : strongly_measurable[ℱ i] (f i) :=
  hf.Adapted i
#align measure_theory.martingale.strongly_measurable MeasureTheory.Martingale.stronglyMeasurable
-/

#print MeasureTheory.Martingale.condexp_ae_eq /-
theorem condexp_ae_eq (hf : Martingale f ℱ μ) {i j : ι} (hij : i ≤ j) : μ[f j|ℱ i] =ᵐ[μ] f i :=
  hf.2 i j hij
#align measure_theory.martingale.condexp_ae_eq MeasureTheory.Martingale.condexp_ae_eq
-/

#print MeasureTheory.Martingale.integrable /-
@[protected]
theorem integrable (hf : Martingale f ℱ μ) (i : ι) : Integrable (f i) μ :=
  integrable_condexp.congr (hf.condexp_ae_eq (le_refl i))
#align measure_theory.martingale.integrable MeasureTheory.Martingale.integrable
-/

#print MeasureTheory.Martingale.set_integral_eq /-
theorem set_integral_eq [SigmaFiniteFiltration μ ℱ] (hf : Martingale f ℱ μ) {i j : ι} (hij : i ≤ j)
    {s : Set Ω} (hs : measurable_set[ℱ i] s) : ∫ ω in s, f i ω ∂μ = ∫ ω in s, f j ω ∂μ :=
  by
  rw [← @set_integral_condexp _ _ _ _ _ (ℱ i) m0 _ _ _ (ℱ.le i) _ (hf.integrable j) hs]
  refine' set_integral_congr_ae (ℱ.le i s hs) _
  filter_upwards [hf.2 i j hij] with _ heq _ using HEq.symm
#align measure_theory.martingale.set_integral_eq MeasureTheory.Martingale.set_integral_eq
-/

#print MeasureTheory.Martingale.add /-
theorem add (hf : Martingale f ℱ μ) (hg : Martingale g ℱ μ) : Martingale (f + g) ℱ μ :=
  by
  refine' ⟨hf.adapted.add hg.adapted, fun i j hij => _⟩
  exact (condexp_add (hf.integrable j) (hg.integrable j)).trans ((hf.2 i j hij).add (hg.2 i j hij))
#align measure_theory.martingale.add MeasureTheory.Martingale.add
-/

#print MeasureTheory.Martingale.neg /-
theorem neg (hf : Martingale f ℱ μ) : Martingale (-f) ℱ μ :=
  ⟨hf.Adapted.neg, fun i j hij => (condexp_neg (f j)).trans (hf.2 i j hij).neg⟩
#align measure_theory.martingale.neg MeasureTheory.Martingale.neg
-/

#print MeasureTheory.Martingale.sub /-
theorem sub (hf : Martingale f ℱ μ) (hg : Martingale g ℱ μ) : Martingale (f - g) ℱ μ := by
  rw [sub_eq_add_neg]; exact hf.add hg.neg
#align measure_theory.martingale.sub MeasureTheory.Martingale.sub
-/

#print MeasureTheory.Martingale.smul /-
theorem smul (c : ℝ) (hf : Martingale f ℱ μ) : Martingale (c • f) ℱ μ :=
  by
  refine' ⟨hf.adapted.smul c, fun i j hij => _⟩
  refine' (condexp_smul c (f j)).trans ((hf.2 i j hij).mono fun x hx => _)
  rw [Pi.smul_apply, hx, Pi.smul_apply, Pi.smul_apply]
#align measure_theory.martingale.smul MeasureTheory.Martingale.smul
-/

#print MeasureTheory.Martingale.supermartingale /-
theorem supermartingale [Preorder E] (hf : Martingale f ℱ μ) : Supermartingale f ℱ μ :=
  ⟨hf.1, fun i j hij => (hf.2 i j hij).le, fun i => hf.Integrable i⟩
#align measure_theory.martingale.supermartingale MeasureTheory.Martingale.supermartingale
-/

#print MeasureTheory.Martingale.submartingale /-
theorem submartingale [Preorder E] (hf : Martingale f ℱ μ) : Submartingale f ℱ μ :=
  ⟨hf.1, fun i j hij => (hf.2 i j hij).symm.le, fun i => hf.Integrable i⟩
#align measure_theory.martingale.submartingale MeasureTheory.Martingale.submartingale
-/

end Martingale

#print MeasureTheory.martingale_iff /-
theorem martingale_iff [PartialOrder E] :
    Martingale f ℱ μ ↔ Supermartingale f ℱ μ ∧ Submartingale f ℱ μ :=
  ⟨fun hf => ⟨hf.Supermartingale, hf.Submartingale⟩, fun ⟨hf₁, hf₂⟩ =>
    ⟨hf₁.1, fun i j hij => (hf₁.2.1 i j hij).antisymm (hf₂.2.1 i j hij)⟩⟩
#align measure_theory.martingale_iff MeasureTheory.martingale_iff
-/

#print MeasureTheory.martingale_condexp /-
theorem martingale_condexp (f : Ω → E) (ℱ : Filtration ι m0) (μ : Measure Ω)
    [SigmaFiniteFiltration μ ℱ] : Martingale (fun i => μ[f|ℱ i]) ℱ μ :=
  ⟨fun i => stronglyMeasurable_condexp, fun i j hij => condexp_condexp_of_le (ℱ.mono hij) (ℱ.le j)⟩
#align measure_theory.martingale_condexp MeasureTheory.martingale_condexp
-/

namespace Supermartingale

#print MeasureTheory.Supermartingale.adapted /-
@[protected]
theorem adapted [LE E] (hf : Supermartingale f ℱ μ) : Adapted ℱ f :=
  hf.1
#align measure_theory.supermartingale.adapted MeasureTheory.Supermartingale.adapted
-/

#print MeasureTheory.Supermartingale.stronglyMeasurable /-
@[protected]
theorem stronglyMeasurable [LE E] (hf : Supermartingale f ℱ μ) (i : ι) :
    strongly_measurable[ℱ i] (f i) :=
  hf.Adapted i
#align measure_theory.supermartingale.strongly_measurable MeasureTheory.Supermartingale.stronglyMeasurable
-/

#print MeasureTheory.Supermartingale.integrable /-
@[protected]
theorem integrable [LE E] (hf : Supermartingale f ℱ μ) (i : ι) : Integrable (f i) μ :=
  hf.2.2 i
#align measure_theory.supermartingale.integrable MeasureTheory.Supermartingale.integrable
-/

#print MeasureTheory.Supermartingale.condexp_ae_le /-
theorem condexp_ae_le [LE E] (hf : Supermartingale f ℱ μ) {i j : ι} (hij : i ≤ j) :
    μ[f j|ℱ i] ≤ᵐ[μ] f i :=
  hf.2.1 i j hij
#align measure_theory.supermartingale.condexp_ae_le MeasureTheory.Supermartingale.condexp_ae_le
-/

#print MeasureTheory.Supermartingale.set_integral_le /-
theorem set_integral_le [SigmaFiniteFiltration μ ℱ] {f : ι → Ω → ℝ} (hf : Supermartingale f ℱ μ)
    {i j : ι} (hij : i ≤ j) {s : Set Ω} (hs : measurable_set[ℱ i] s) :
    ∫ ω in s, f j ω ∂μ ≤ ∫ ω in s, f i ω ∂μ :=
  by
  rw [← set_integral_condexp (ℱ.le i) (hf.integrable j) hs]
  refine' set_integral_mono_ae integrable_condexp.integrable_on (hf.integrable i).IntegrableOn _
  filter_upwards [hf.2.1 i j hij] with _ heq using HEq
#align measure_theory.supermartingale.set_integral_le MeasureTheory.Supermartingale.set_integral_le
-/

#print MeasureTheory.Supermartingale.add /-
theorem add [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)] (hf : Supermartingale f ℱ μ)
    (hg : Supermartingale g ℱ μ) : Supermartingale (f + g) ℱ μ :=
  by
  refine' ⟨hf.1.add hg.1, fun i j hij => _, fun i => (hf.2.2 i).add (hg.2.2 i)⟩
  refine' (condexp_add (hf.integrable j) (hg.integrable j)).le.trans _
  filter_upwards [hf.2.1 i j hij, hg.2.1 i j hij]
  intros
  refine' add_le_add _ _ <;> assumption
#align measure_theory.supermartingale.add MeasureTheory.Supermartingale.add
-/

#print MeasureTheory.Supermartingale.add_martingale /-
theorem add_martingale [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)]
    (hf : Supermartingale f ℱ μ) (hg : Martingale g ℱ μ) : Supermartingale (f + g) ℱ μ :=
  hf.add hg.Supermartingale
#align measure_theory.supermartingale.add_martingale MeasureTheory.Supermartingale.add_martingale
-/

#print MeasureTheory.Supermartingale.neg /-
theorem neg [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)] (hf : Supermartingale f ℱ μ) :
    Submartingale (-f) ℱ μ :=
  by
  refine' ⟨hf.1.neg, fun i j hij => _, fun i => (hf.2.2 i).neg⟩
  refine' eventually_le.trans _ (condexp_neg (f j)).symm.le
  filter_upwards [hf.2.1 i j hij] with _ _
  simpa
#align measure_theory.supermartingale.neg MeasureTheory.Supermartingale.neg
-/

end Supermartingale

namespace Submartingale

#print MeasureTheory.Submartingale.adapted /-
@[protected]
theorem adapted [LE E] (hf : Submartingale f ℱ μ) : Adapted ℱ f :=
  hf.1
#align measure_theory.submartingale.adapted MeasureTheory.Submartingale.adapted
-/

#print MeasureTheory.Submartingale.stronglyMeasurable /-
@[protected]
theorem stronglyMeasurable [LE E] (hf : Submartingale f ℱ μ) (i : ι) :
    strongly_measurable[ℱ i] (f i) :=
  hf.Adapted i
#align measure_theory.submartingale.strongly_measurable MeasureTheory.Submartingale.stronglyMeasurable
-/

#print MeasureTheory.Submartingale.integrable /-
@[protected]
theorem integrable [LE E] (hf : Submartingale f ℱ μ) (i : ι) : Integrable (f i) μ :=
  hf.2.2 i
#align measure_theory.submartingale.integrable MeasureTheory.Submartingale.integrable
-/

#print MeasureTheory.Submartingale.ae_le_condexp /-
theorem ae_le_condexp [LE E] (hf : Submartingale f ℱ μ) {i j : ι} (hij : i ≤ j) :
    f i ≤ᵐ[μ] μ[f j|ℱ i] :=
  hf.2.1 i j hij
#align measure_theory.submartingale.ae_le_condexp MeasureTheory.Submartingale.ae_le_condexp
-/

#print MeasureTheory.Submartingale.add /-
theorem add [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)] (hf : Submartingale f ℱ μ)
    (hg : Submartingale g ℱ μ) : Submartingale (f + g) ℱ μ :=
  by
  refine' ⟨hf.1.add hg.1, fun i j hij => _, fun i => (hf.2.2 i).add (hg.2.2 i)⟩
  refine' eventually_le.trans _ (condexp_add (hf.integrable j) (hg.integrable j)).symm.le
  filter_upwards [hf.2.1 i j hij, hg.2.1 i j hij]
  intros
  refine' add_le_add _ _ <;> assumption
#align measure_theory.submartingale.add MeasureTheory.Submartingale.add
-/

#print MeasureTheory.Submartingale.add_martingale /-
theorem add_martingale [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)] (hf : Submartingale f ℱ μ)
    (hg : Martingale g ℱ μ) : Submartingale (f + g) ℱ μ :=
  hf.add hg.Submartingale
#align measure_theory.submartingale.add_martingale MeasureTheory.Submartingale.add_martingale
-/

#print MeasureTheory.Submartingale.neg /-
theorem neg [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)] (hf : Submartingale f ℱ μ) :
    Supermartingale (-f) ℱ μ :=
  by
  refine' ⟨hf.1.neg, fun i j hij => (condexp_neg (f j)).le.trans _, fun i => (hf.2.2 i).neg⟩
  filter_upwards [hf.2.1 i j hij] with _ _
  simpa
#align measure_theory.submartingale.neg MeasureTheory.Submartingale.neg
-/

#print MeasureTheory.Submartingale.set_integral_le /-
/-- The converse of this lemma is `measure_theory.submartingale_of_set_integral_le`. -/
theorem set_integral_le [SigmaFiniteFiltration μ ℱ] {f : ι → Ω → ℝ} (hf : Submartingale f ℱ μ)
    {i j : ι} (hij : i ≤ j) {s : Set Ω} (hs : measurable_set[ℱ i] s) :
    ∫ ω in s, f i ω ∂μ ≤ ∫ ω in s, f j ω ∂μ :=
  by
  rw [← neg_le_neg_iff, ← integral_neg, ← integral_neg]
  exact supermartingale.set_integral_le hf.neg hij hs
#align measure_theory.submartingale.set_integral_le MeasureTheory.Submartingale.set_integral_le
-/

#print MeasureTheory.Submartingale.sub_supermartingale /-
theorem sub_supermartingale [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)]
    (hf : Submartingale f ℱ μ) (hg : Supermartingale g ℱ μ) : Submartingale (f - g) ℱ μ := by
  rw [sub_eq_add_neg]; exact hf.add hg.neg
#align measure_theory.submartingale.sub_supermartingale MeasureTheory.Submartingale.sub_supermartingale
-/

#print MeasureTheory.Submartingale.sub_martingale /-
theorem sub_martingale [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)] (hf : Submartingale f ℱ μ)
    (hg : Martingale g ℱ μ) : Submartingale (f - g) ℱ μ :=
  hf.sub_supermartingale hg.Supermartingale
#align measure_theory.submartingale.sub_martingale MeasureTheory.Submartingale.sub_martingale
-/

#print MeasureTheory.Submartingale.sup /-
protected theorem sup {f g : ι → Ω → ℝ} (hf : Submartingale f ℱ μ) (hg : Submartingale g ℱ μ) :
    Submartingale (f ⊔ g) ℱ μ :=
  by
  refine'
    ⟨fun i => @strongly_measurable.sup _ _ _ _ (ℱ i) _ _ _ (hf.adapted i) (hg.adapted i),
      fun i j hij => _, fun i => integrable.sup (hf.integrable _) (hg.integrable _)⟩
  refine' eventually_le.sup_le _ _
  ·
    exact
      eventually_le.trans (hf.2.1 i j hij)
        (condexp_mono (hf.integrable _) (integrable.sup (hf.integrable j) (hg.integrable j))
          (eventually_of_forall fun x => le_max_left _ _))
  ·
    exact
      eventually_le.trans (hg.2.1 i j hij)
        (condexp_mono (hg.integrable _) (integrable.sup (hf.integrable j) (hg.integrable j))
          (eventually_of_forall fun x => le_max_right _ _))
#align measure_theory.submartingale.sup MeasureTheory.Submartingale.sup
-/

#print MeasureTheory.Submartingale.pos /-
protected theorem pos {f : ι → Ω → ℝ} (hf : Submartingale f ℱ μ) : Submartingale (f⁺) ℱ μ :=
  hf.sup (martingale_zero _ _ _).Submartingale
#align measure_theory.submartingale.pos MeasureTheory.Submartingale.pos
-/

end Submartingale

section Submartingale

#print MeasureTheory.submartingale_of_set_integral_le /-
theorem submartingale_of_set_integral_le [IsFiniteMeasure μ] {f : ι → Ω → ℝ} (hadp : Adapted ℱ f)
    (hint : ∀ i, Integrable (f i) μ)
    (hf :
      ∀ i j : ι,
        i ≤ j → ∀ s : Set Ω, measurable_set[ℱ i] s → ∫ ω in s, f i ω ∂μ ≤ ∫ ω in s, f j ω ∂μ) :
    Submartingale f ℱ μ := by
  refine' ⟨hadp, fun i j hij => _, hint⟩
  suffices f i ≤ᵐ[μ.trim (ℱ.le i)] μ[f j|ℱ i] by exact ae_le_of_ae_le_trim this
  suffices 0 ≤ᵐ[μ.trim (ℱ.le i)] μ[f j|ℱ i] - f i
    by
    filter_upwards [this] with x hx
    rwa [← sub_nonneg]
  refine'
    ae_nonneg_of_forall_set_integral_nonneg
      ((integrable_condexp.sub (hint i)).trim _ (strongly_measurable_condexp.sub <| hadp i))
      fun s hs h's => _
  specialize hf i j hij s hs
  rwa [← set_integral_trim _ (strongly_measurable_condexp.sub <| hadp i) hs,
    integral_sub' integrable_condexp.integrable_on (hint i).IntegrableOn, sub_nonneg,
    set_integral_condexp (ℱ.le i) (hint j) hs]
#align measure_theory.submartingale_of_set_integral_le MeasureTheory.submartingale_of_set_integral_le
-/

#print MeasureTheory.submartingale_of_condexp_sub_nonneg /-
theorem submartingale_of_condexp_sub_nonneg [IsFiniteMeasure μ] {f : ι → Ω → ℝ} (hadp : Adapted ℱ f)
    (hint : ∀ i, Integrable (f i) μ) (hf : ∀ i j, i ≤ j → 0 ≤ᵐ[μ] μ[f j - f i|ℱ i]) :
    Submartingale f ℱ μ := by
  refine' ⟨hadp, fun i j hij => _, hint⟩
  rw [← condexp_of_strongly_measurable (ℱ.le _) (hadp _) (hint _), ← eventually_sub_nonneg]
  exact eventually_le.trans (hf i j hij) (condexp_sub (hint _) (hint _)).le
  infer_instance
#align measure_theory.submartingale_of_condexp_sub_nonneg MeasureTheory.submartingale_of_condexp_sub_nonneg
-/

#print MeasureTheory.Submartingale.condexp_sub_nonneg /-
theorem Submartingale.condexp_sub_nonneg {f : ι → Ω → ℝ} (hf : Submartingale f ℱ μ) {i j : ι}
    (hij : i ≤ j) : 0 ≤ᵐ[μ] μ[f j - f i|ℱ i] :=
  by
  by_cases h : sigma_finite (μ.trim (ℱ.le i))
  swap; · rw [condexp_of_not_sigma_finite (ℱ.le i) h]
  refine' eventually_le.trans _ (condexp_sub (hf.integrable _) (hf.integrable _)).symm.le
  rw [eventually_sub_nonneg,
    condexp_of_strongly_measurable (ℱ.le _) (hf.adapted _) (hf.integrable _)]
  · exact hf.2.1 i j hij
  · exact h
#align measure_theory.submartingale.condexp_sub_nonneg MeasureTheory.Submartingale.condexp_sub_nonneg
-/

#print MeasureTheory.submartingale_iff_condexp_sub_nonneg /-
theorem submartingale_iff_condexp_sub_nonneg [IsFiniteMeasure μ] {f : ι → Ω → ℝ} :
    Submartingale f ℱ μ ↔
      Adapted ℱ f ∧ (∀ i, Integrable (f i) μ) ∧ ∀ i j, i ≤ j → 0 ≤ᵐ[μ] μ[f j - f i|ℱ i] :=
  ⟨fun h => ⟨h.Adapted, h.Integrable, fun i j => h.condexp_sub_nonneg⟩, fun ⟨hadp, hint, h⟩ =>
    submartingale_of_condexp_sub_nonneg hadp hint h⟩
#align measure_theory.submartingale_iff_condexp_sub_nonneg MeasureTheory.submartingale_iff_condexp_sub_nonneg
-/

end Submartingale

namespace Supermartingale

#print MeasureTheory.Supermartingale.sub_submartingale /-
theorem sub_submartingale [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)]
    (hf : Supermartingale f ℱ μ) (hg : Submartingale g ℱ μ) : Supermartingale (f - g) ℱ μ := by
  rw [sub_eq_add_neg]; exact hf.add hg.neg
#align measure_theory.supermartingale.sub_submartingale MeasureTheory.Supermartingale.sub_submartingale
-/

#print MeasureTheory.Supermartingale.sub_martingale /-
theorem sub_martingale [Preorder E] [CovariantClass E E (· + ·) (· ≤ ·)]
    (hf : Supermartingale f ℱ μ) (hg : Martingale g ℱ μ) : Supermartingale (f - g) ℱ μ :=
  hf.sub_submartingale hg.Submartingale
#align measure_theory.supermartingale.sub_martingale MeasureTheory.Supermartingale.sub_martingale
-/

section

variable {F : Type _} [NormedLatticeAddCommGroup F] [NormedSpace ℝ F] [CompleteSpace F]
  [OrderedSMul ℝ F]

#print MeasureTheory.Supermartingale.smul_nonneg /-
theorem smul_nonneg {f : ι → Ω → F} {c : ℝ} (hc : 0 ≤ c) (hf : Supermartingale f ℱ μ) :
    Supermartingale (c • f) ℱ μ :=
  by
  refine' ⟨hf.1.smul c, fun i j hij => _, fun i => (hf.2.2 i).smul c⟩
  refine' (condexp_smul c (f j)).le.trans _
  filter_upwards [hf.2.1 i j hij] with _ hle
  simp_rw [Pi.smul_apply]
  exact smul_le_smul_of_nonneg hle hc
#align measure_theory.supermartingale.smul_nonneg MeasureTheory.Supermartingale.smul_nonneg
-/

#print MeasureTheory.Supermartingale.smul_nonpos /-
theorem smul_nonpos {f : ι → Ω → F} {c : ℝ} (hc : c ≤ 0) (hf : Supermartingale f ℱ μ) :
    Submartingale (c • f) ℱ μ :=
  by
  rw [← neg_neg c, (by ext i x; simp : - -c • f = -(-c • f))]
  exact (hf.smul_nonneg <| neg_nonneg.2 hc).neg
#align measure_theory.supermartingale.smul_nonpos MeasureTheory.Supermartingale.smul_nonpos
-/

end

end Supermartingale

namespace Submartingale

section

variable {F : Type _} [NormedLatticeAddCommGroup F] [NormedSpace ℝ F] [CompleteSpace F]
  [OrderedSMul ℝ F]

#print MeasureTheory.Submartingale.smul_nonneg /-
theorem smul_nonneg {f : ι → Ω → F} {c : ℝ} (hc : 0 ≤ c) (hf : Submartingale f ℱ μ) :
    Submartingale (c • f) ℱ μ :=
  by
  rw [← neg_neg c, (by ext i x; simp : - -c • f = -(c • -f))]
  exact supermartingale.neg (hf.neg.smul_nonneg hc)
#align measure_theory.submartingale.smul_nonneg MeasureTheory.Submartingale.smul_nonneg
-/

#print MeasureTheory.Submartingale.smul_nonpos /-
theorem smul_nonpos {f : ι → Ω → F} {c : ℝ} (hc : c ≤ 0) (hf : Submartingale f ℱ μ) :
    Supermartingale (c • f) ℱ μ :=
  by
  rw [← neg_neg c, (by ext i x; simp : - -c • f = -(-c • f))]
  exact (hf.smul_nonneg <| neg_nonneg.2 hc).neg
#align measure_theory.submartingale.smul_nonpos MeasureTheory.Submartingale.smul_nonpos
-/

end

end Submartingale

section Nat

variable {𝒢 : Filtration ℕ m0}

#print MeasureTheory.submartingale_of_set_integral_le_succ /-
theorem submartingale_of_set_integral_le_succ [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ}
    (hadp : Adapted 𝒢 f) (hint : ∀ i, Integrable (f i) μ)
    (hf : ∀ i, ∀ s : Set Ω, measurable_set[𝒢 i] s → ∫ ω in s, f i ω ∂μ ≤ ∫ ω in s, f (i + 1) ω ∂μ) :
    Submartingale f 𝒢 μ :=
  by
  refine' submartingale_of_set_integral_le hadp hint fun i j hij s hs => _
  induction' hij with k hk₁ hk₂
  · exact le_rfl
  · exact le_trans hk₂ (hf k s (𝒢.mono hk₁ _ hs))
#align measure_theory.submartingale_of_set_integral_le_succ MeasureTheory.submartingale_of_set_integral_le_succ
-/

#print MeasureTheory.supermartingale_of_set_integral_succ_le /-
theorem supermartingale_of_set_integral_succ_le [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ}
    (hadp : Adapted 𝒢 f) (hint : ∀ i, Integrable (f i) μ)
    (hf : ∀ i, ∀ s : Set Ω, measurable_set[𝒢 i] s → ∫ ω in s, f (i + 1) ω ∂μ ≤ ∫ ω in s, f i ω ∂μ) :
    Supermartingale f 𝒢 μ := by
  rw [← neg_neg f]
  refine' (submartingale_of_set_integral_le_succ hadp.neg (fun i => (hint i).neg) _).neg
  simpa only [integral_neg, Pi.neg_apply, neg_le_neg_iff]
#align measure_theory.supermartingale_of_set_integral_succ_le MeasureTheory.supermartingale_of_set_integral_succ_le
-/

#print MeasureTheory.martingale_of_set_integral_eq_succ /-
theorem martingale_of_set_integral_eq_succ [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ} (hadp : Adapted 𝒢 f)
    (hint : ∀ i, Integrable (f i) μ)
    (hf : ∀ i, ∀ s : Set Ω, measurable_set[𝒢 i] s → ∫ ω in s, f i ω ∂μ = ∫ ω in s, f (i + 1) ω ∂μ) :
    Martingale f 𝒢 μ :=
  martingale_iff.2
    ⟨supermartingale_of_set_integral_succ_le hadp hint fun i s hs => (hf i s hs).ge,
      submartingale_of_set_integral_le_succ hadp hint fun i s hs => (hf i s hs).le⟩
#align measure_theory.martingale_of_set_integral_eq_succ MeasureTheory.martingale_of_set_integral_eq_succ
-/

#print MeasureTheory.submartingale_nat /-
theorem submartingale_nat [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ} (hadp : Adapted 𝒢 f)
    (hint : ∀ i, Integrable (f i) μ) (hf : ∀ i, f i ≤ᵐ[μ] μ[f (i + 1)|𝒢 i]) : Submartingale f 𝒢 μ :=
  by
  refine' submartingale_of_set_integral_le_succ hadp hint fun i s hs => _
  have : ∫ ω in s, f (i + 1) ω ∂μ = ∫ ω in s, (μ[f (i + 1)|𝒢 i]) ω ∂μ :=
    (set_integral_condexp (𝒢.le i) (hint _) hs).symm
  rw [this]
  exact set_integral_mono_ae (hint i).IntegrableOn integrable_condexp.integrable_on (hf i)
#align measure_theory.submartingale_nat MeasureTheory.submartingale_nat
-/

#print MeasureTheory.supermartingale_nat /-
theorem supermartingale_nat [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ} (hadp : Adapted 𝒢 f)
    (hint : ∀ i, Integrable (f i) μ) (hf : ∀ i, μ[f (i + 1)|𝒢 i] ≤ᵐ[μ] f i) :
    Supermartingale f 𝒢 μ := by
  rw [← neg_neg f]
  refine'
    (submartingale_nat hadp.neg (fun i => (hint i).neg) fun i =>
        eventually_le.trans _ (condexp_neg _).symm.le).neg
  filter_upwards [hf i] with x hx using neg_le_neg hx
#align measure_theory.supermartingale_nat MeasureTheory.supermartingale_nat
-/

#print MeasureTheory.martingale_nat /-
theorem martingale_nat [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ} (hadp : Adapted 𝒢 f)
    (hint : ∀ i, Integrable (f i) μ) (hf : ∀ i, f i =ᵐ[μ] μ[f (i + 1)|𝒢 i]) : Martingale f 𝒢 μ :=
  martingale_iff.2
    ⟨supermartingale_nat hadp hint fun i => (hf i).symm.le,
      submartingale_nat hadp hint fun i => (hf i).le⟩
#align measure_theory.martingale_nat MeasureTheory.martingale_nat
-/

#print MeasureTheory.submartingale_of_condexp_sub_nonneg_nat /-
theorem submartingale_of_condexp_sub_nonneg_nat [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ}
    (hadp : Adapted 𝒢 f) (hint : ∀ i, Integrable (f i) μ)
    (hf : ∀ i, 0 ≤ᵐ[μ] μ[f (i + 1) - f i|𝒢 i]) : Submartingale f 𝒢 μ :=
  by
  refine' submartingale_nat hadp hint fun i => _
  rw [← condexp_of_strongly_measurable (𝒢.le _) (hadp _) (hint _), ← eventually_sub_nonneg]
  exact eventually_le.trans (hf i) (condexp_sub (hint _) (hint _)).le
  infer_instance
#align measure_theory.submartingale_of_condexp_sub_nonneg_nat MeasureTheory.submartingale_of_condexp_sub_nonneg_nat
-/

#print MeasureTheory.supermartingale_of_condexp_sub_nonneg_nat /-
theorem supermartingale_of_condexp_sub_nonneg_nat [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ}
    (hadp : Adapted 𝒢 f) (hint : ∀ i, Integrable (f i) μ)
    (hf : ∀ i, 0 ≤ᵐ[μ] μ[f i - f (i + 1)|𝒢 i]) : Supermartingale f 𝒢 μ :=
  by
  rw [← neg_neg f]
  refine' (submartingale_of_condexp_sub_nonneg_nat hadp.neg (fun i => (hint i).neg) _).neg
  simpa only [Pi.zero_apply, Pi.neg_apply, neg_sub_neg]
#align measure_theory.supermartingale_of_condexp_sub_nonneg_nat MeasureTheory.supermartingale_of_condexp_sub_nonneg_nat
-/

#print MeasureTheory.martingale_of_condexp_sub_eq_zero_nat /-
theorem martingale_of_condexp_sub_eq_zero_nat [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ}
    (hadp : Adapted 𝒢 f) (hint : ∀ i, Integrable (f i) μ)
    (hf : ∀ i, μ[f (i + 1) - f i|𝒢 i] =ᵐ[μ] 0) : Martingale f 𝒢 μ :=
  by
  refine'
    martingale_iff.2
      ⟨supermartingale_of_condexp_sub_nonneg_nat hadp hint fun i => _,
        submartingale_of_condexp_sub_nonneg_nat hadp hint fun i => (hf i).symm.le⟩
  rw [← neg_sub]
  refine' (eventually_eq.trans _ (condexp_neg _).symm).le
  filter_upwards [hf i] with x hx
  simpa only [Pi.zero_apply, Pi.neg_apply, zero_eq_neg]
#align measure_theory.martingale_of_condexp_sub_eq_zero_nat MeasureTheory.martingale_of_condexp_sub_eq_zero_nat
-/

#print MeasureTheory.Submartingale.zero_le_of_predictable /-
-- Note that one cannot use `submartingale.zero_le_of_predictable` to prove the other two
-- corresponding lemmas without imposing more restrictions to the ordering of `E`
/-- A predictable submartingale is a.e. greater equal than its initial state. -/
theorem Submartingale.zero_le_of_predictable [Preorder E] [SigmaFiniteFiltration μ 𝒢]
    {f : ℕ → Ω → E} (hfmgle : Submartingale f 𝒢 μ) (hfadp : Adapted 𝒢 fun n => f (n + 1)) (n : ℕ) :
    f 0 ≤ᵐ[μ] f n := by
  induction' n with k ih
  · rfl
  ·
    exact
      ih.trans
        ((hfmgle.2.1 k (k + 1) k.le_succ).trans_eq <|
          germ.coe_eq.mp <|
            congr_arg coe <|
              condexp_of_strongly_measurable (𝒢.le _) (hfadp _) <| hfmgle.integrable _)
#align measure_theory.submartingale.zero_le_of_predictable MeasureTheory.Submartingale.zero_le_of_predictable
-/

#print MeasureTheory.Supermartingale.le_zero_of_predictable /-
/-- A predictable supermartingale is a.e. less equal than its initial state. -/
theorem Supermartingale.le_zero_of_predictable [Preorder E] [SigmaFiniteFiltration μ 𝒢]
    {f : ℕ → Ω → E} (hfmgle : Supermartingale f 𝒢 μ) (hfadp : Adapted 𝒢 fun n => f (n + 1))
    (n : ℕ) : f n ≤ᵐ[μ] f 0 := by
  induction' n with k ih
  · rfl
  ·
    exact
      ((germ.coe_eq.mp <|
                  congr_arg coe <|
                    condexp_of_strongly_measurable (𝒢.le _) (hfadp _) <|
                      hfmgle.integrable _).symm.trans_le
            (hfmgle.2.1 k (k + 1) k.le_succ)).trans
        ih
#align measure_theory.supermartingale.le_zero_of_predictable MeasureTheory.Supermartingale.le_zero_of_predictable
-/

#print MeasureTheory.Martingale.eq_zero_of_predictable /-
/-- A predictable martingale is a.e. equal to its initial state. -/
theorem Martingale.eq_zero_of_predictable [SigmaFiniteFiltration μ 𝒢] {f : ℕ → Ω → E}
    (hfmgle : Martingale f 𝒢 μ) (hfadp : Adapted 𝒢 fun n => f (n + 1)) (n : ℕ) : f n =ᵐ[μ] f 0 :=
  by
  induction' n with k ih
  · rfl
  ·
    exact
      ((germ.coe_eq.mp
                  (congr_arg coe <|
                    condexp_of_strongly_measurable (𝒢.le _) (hfadp _)
                      (hfmgle.integrable _))).symm.trans
            (hfmgle.2 k (k + 1) k.le_succ)).trans
        ih
#align measure_theory.martingale.eq_zero_of_predictable MeasureTheory.Martingale.eq_zero_of_predictable
-/

namespace Submartingale

#print MeasureTheory.Submartingale.integrable_stoppedValue /-
@[protected]
theorem integrable_stoppedValue [LE E] {f : ℕ → Ω → E} (hf : Submartingale f 𝒢 μ) {τ : Ω → ℕ}
    (hτ : IsStoppingTime 𝒢 τ) {N : ℕ} (hbdd : ∀ ω, τ ω ≤ N) : Integrable (stoppedValue f τ) μ :=
  integrable_stoppedValue ℕ hτ hf.Integrable hbdd
#align measure_theory.submartingale.integrable_stopped_value MeasureTheory.Submartingale.integrable_stoppedValue
-/

end Submartingale

#print MeasureTheory.Submartingale.sum_mul_sub /-
theorem Submartingale.sum_mul_sub [IsFiniteMeasure μ] {R : ℝ} {ξ f : ℕ → Ω → ℝ}
    (hf : Submartingale f 𝒢 μ) (hξ : Adapted 𝒢 ξ) (hbdd : ∀ n ω, ξ n ω ≤ R)
    (hnonneg : ∀ n ω, 0 ≤ ξ n ω) :
    Submartingale (fun n => ∑ k in Finset.range n, ξ k * (f (k + 1) - f k)) 𝒢 μ :=
  by
  have hξbdd : ∀ i, ∃ C, ∀ ω, |ξ i ω| ≤ C := fun i =>
    ⟨R, fun ω => (abs_of_nonneg (hnonneg i ω)).trans_le (hbdd i ω)⟩
  have hint : ∀ m, integrable (∑ k in Finset.range m, ξ k * (f (k + 1) - f k)) μ := fun m =>
    integrable_finset_sum' _ fun i hi =>
      integrable.bdd_mul ((hf.integrable _).sub (hf.integrable _))
        hξ.strongly_measurable.ae_strongly_measurable (hξbdd _)
  have hadp : adapted 𝒢 fun n => ∑ k in Finset.range n, ξ k * (f (k + 1) - f k) :=
    by
    intro m
    refine' Finset.stronglyMeasurable_sum' _ fun i hi => _
    rw [Finset.mem_range] at hi 
    exact
      (hξ.strongly_measurable_le hi.le).mul
        ((hf.adapted.strongly_measurable_le (Nat.succ_le_of_lt hi)).sub
          (hf.adapted.strongly_measurable_le hi.le))
  refine' submartingale_of_condexp_sub_nonneg_nat hadp hint fun i => _
  simp only [← Finset.sum_Ico_eq_sub _ (Nat.le_succ _), Finset.sum_apply, Pi.mul_apply,
    Pi.sub_apply, Nat.Ico_succ_singleton, Finset.sum_singleton]
  exact
    eventually_le.trans
      (eventually_le.mul_nonneg (eventually_of_forall (hnonneg _))
        (hf.condexp_sub_nonneg (Nat.le_succ _)))
      (condexp_strongly_measurable_mul (hξ _)
            (((hf.integrable _).sub (hf.integrable _)).bdd_mul
              hξ.strongly_measurable.ae_strongly_measurable (hξbdd _))
            ((hf.integrable _).sub (hf.integrable _))).symm.le
#align measure_theory.submartingale.sum_mul_sub MeasureTheory.Submartingale.sum_mul_sub
-/

#print MeasureTheory.Submartingale.sum_mul_sub' /-
/-- Given a discrete submartingale `f` and a predictable process `ξ` (i.e. `ξ (n + 1)` is adapted)
the process defined by `λ n, ∑ k in finset.range n, ξ (k + 1) * (f (k + 1) - f k)` is also a
submartingale. -/
theorem Submartingale.sum_mul_sub' [IsFiniteMeasure μ] {R : ℝ} {ξ f : ℕ → Ω → ℝ}
    (hf : Submartingale f 𝒢 μ) (hξ : Adapted 𝒢 fun n => ξ (n + 1)) (hbdd : ∀ n ω, ξ n ω ≤ R)
    (hnonneg : ∀ n ω, 0 ≤ ξ n ω) :
    Submartingale (fun n => ∑ k in Finset.range n, ξ (k + 1) * (f (k + 1) - f k)) 𝒢 μ :=
  hf.sum_mul_sub hξ (fun n => hbdd _) fun n => hnonneg _
#align measure_theory.submartingale.sum_mul_sub' MeasureTheory.Submartingale.sum_mul_sub'
-/

end Nat

end MeasureTheory

