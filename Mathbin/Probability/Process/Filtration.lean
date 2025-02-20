/-
Copyright (c) 2021 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying, Rémy Degenne

! This file was ported from Lean 3 source module probability.process.filtration
! leanprover-community/mathlib commit e160cefedc932ce41c7049bf0c4b0f061d06216e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Function.ConditionalExpectation.Real

/-!
# Filtrations

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines filtrations of a measurable space and σ-finite filtrations.

## Main definitions

* `measure_theory.filtration`: a filtration on a measurable space. That is, a monotone sequence of
  sub-σ-algebras.
* `measure_theory.sigma_finite_filtration`: a filtration `f` is σ-finite with respect to a measure
  `μ` if for all `i`, `μ.trim (f.le i)` is σ-finite.
* `measure_theory.filtration.natural`: the smallest filtration that makes a process adapted. That
  notion `adapted` is not defined yet in this file. See `measure_theory.adapted`.

## Main results

* `measure_theory.filtration.complete_lattice`: filtrations are a complete lattice.

## Tags

filtration, stochastic process

-/


open Filter Order TopologicalSpace

open scoped Classical MeasureTheory NNReal ENNReal Topology BigOperators

namespace MeasureTheory

#print MeasureTheory.Filtration /-
/-- A `filtration` on a measurable space `Ω` with σ-algebra `m` is a monotone
sequence of sub-σ-algebras of `m`. -/
structure Filtration {Ω : Type _} (ι : Type _) [Preorder ι] (m : MeasurableSpace Ω) where
  seq : ι → MeasurableSpace Ω
  mono' : Monotone seq
  le' : ∀ i : ι, seq i ≤ m
#align measure_theory.filtration MeasureTheory.Filtration
-/

variable {Ω β ι : Type _} {m : MeasurableSpace Ω}

instance [Preorder ι] : CoeFun (Filtration ι m) fun _ => ι → MeasurableSpace Ω :=
  ⟨fun f => f.seq⟩

namespace Filtration

variable [Preorder ι]

#print MeasureTheory.Filtration.mono /-
protected theorem mono {i j : ι} (f : Filtration ι m) (hij : i ≤ j) : f i ≤ f j :=
  f.mono' hij
#align measure_theory.filtration.mono MeasureTheory.Filtration.mono
-/

#print MeasureTheory.Filtration.le /-
protected theorem le (f : Filtration ι m) (i : ι) : f i ≤ m :=
  f.le' i
#align measure_theory.filtration.le MeasureTheory.Filtration.le
-/

#print MeasureTheory.Filtration.ext /-
@[ext]
protected theorem ext {f g : Filtration ι m} (h : (f : ι → MeasurableSpace Ω) = g) : f = g := by
  cases f; cases g; simp only; exact h
#align measure_theory.filtration.ext MeasureTheory.Filtration.ext
-/

variable (ι)

#print MeasureTheory.Filtration.const /-
/-- The constant filtration which is equal to `m` for all `i : ι`. -/
def const (m' : MeasurableSpace Ω) (hm' : m' ≤ m) : Filtration ι m :=
  ⟨fun _ => m', monotone_const, fun _ => hm'⟩
#align measure_theory.filtration.const MeasureTheory.Filtration.const
-/

variable {ι}

#print MeasureTheory.Filtration.const_apply /-
@[simp]
theorem const_apply {m' : MeasurableSpace Ω} {hm' : m' ≤ m} (i : ι) : const ι m' hm' i = m' :=
  rfl
#align measure_theory.filtration.const_apply MeasureTheory.Filtration.const_apply
-/

instance : Inhabited (Filtration ι m) :=
  ⟨const ι m le_rfl⟩

instance : LE (Filtration ι m) :=
  ⟨fun f g => ∀ i, f i ≤ g i⟩

instance : Bot (Filtration ι m) :=
  ⟨const ι ⊥ bot_le⟩

instance : Top (Filtration ι m) :=
  ⟨const ι m le_rfl⟩

instance : Sup (Filtration ι m) :=
  ⟨fun f g =>
    { seq := fun i => f i ⊔ g i
      mono' := fun i j hij =>
        sup_le ((f.mono hij).trans le_sup_left) ((g.mono hij).trans le_sup_right)
      le' := fun i => sup_le (f.le i) (g.le i) }⟩

#print MeasureTheory.Filtration.coeFn_sup /-
@[norm_cast]
theorem coeFn_sup {f g : Filtration ι m} : ⇑(f ⊔ g) = f ⊔ g :=
  rfl
#align measure_theory.filtration.coe_fn_sup MeasureTheory.Filtration.coeFn_sup
-/

instance : Inf (Filtration ι m) :=
  ⟨fun f g =>
    { seq := fun i => f i ⊓ g i
      mono' := fun i j hij =>
        le_inf (inf_le_left.trans (f.mono hij)) (inf_le_right.trans (g.mono hij))
      le' := fun i => inf_le_left.trans (f.le i) }⟩

#print MeasureTheory.Filtration.coeFn_inf /-
@[norm_cast]
theorem coeFn_inf {f g : Filtration ι m} : ⇑(f ⊓ g) = f ⊓ g :=
  rfl
#align measure_theory.filtration.coe_fn_inf MeasureTheory.Filtration.coeFn_inf
-/

instance : SupSet (Filtration ι m) :=
  ⟨fun s =>
    { seq := fun i => sSup ((fun f : Filtration ι m => f i) '' s)
      mono' := fun i j hij => by
        refine' sSup_le fun m' hm' => _
        rw [Set.mem_image] at hm' 
        obtain ⟨f, hf_mem, hfm'⟩ := hm'
        rw [← hfm']
        refine' (f.mono hij).trans _
        have hfj_mem : f j ∈ (fun g : filtration ι m => g j) '' s := ⟨f, hf_mem, rfl⟩
        exact le_sSup hfj_mem
      le' := fun i => by
        refine' sSup_le fun m' hm' => _
        rw [Set.mem_image] at hm' 
        obtain ⟨f, hf_mem, hfm'⟩ := hm'
        rw [← hfm']
        exact f.le i }⟩

#print MeasureTheory.Filtration.sSup_def /-
theorem sSup_def (s : Set (Filtration ι m)) (i : ι) :
    sSup s i = sSup ((fun f : Filtration ι m => f i) '' s) :=
  rfl
#align measure_theory.filtration.Sup_def MeasureTheory.Filtration.sSup_def
-/

noncomputable instance : InfSet (Filtration ι m) :=
  ⟨fun s =>
    { seq := fun i => if Set.Nonempty s then sInf ((fun f : Filtration ι m => f i) '' s) else m
      mono' := fun i j hij => by
        by_cases h_nonempty : Set.Nonempty s
        swap; · simp only [h_nonempty, Set.nonempty_image_iff, if_false, le_refl]
        simp only [h_nonempty, if_true, le_sInf_iff, Set.mem_image, forall_exists_index, and_imp,
          forall_apply_eq_imp_iff₂]
        refine' fun f hf_mem => le_trans _ (f.mono hij)
        have hfi_mem : f i ∈ (fun g : filtration ι m => g i) '' s := ⟨f, hf_mem, rfl⟩
        exact sInf_le hfi_mem
      le' := fun i => by
        by_cases h_nonempty : Set.Nonempty s
        swap; · simp only [h_nonempty, if_false, le_refl]
        simp only [h_nonempty, if_true]
        obtain ⟨f, hf_mem⟩ := h_nonempty
        exact le_trans (sInf_le ⟨f, hf_mem, rfl⟩) (f.le i) }⟩

#print MeasureTheory.Filtration.sInf_def /-
theorem sInf_def (s : Set (Filtration ι m)) (i : ι) :
    sInf s i = if Set.Nonempty s then sInf ((fun f : Filtration ι m => f i) '' s) else m :=
  rfl
#align measure_theory.filtration.Inf_def MeasureTheory.Filtration.sInf_def
-/

noncomputable instance : CompleteLattice (Filtration ι m)
    where
  le := (· ≤ ·)
  le_refl f i := le_rfl
  le_trans f g h h_fg h_gh i := (h_fg i).trans (h_gh i)
  le_antisymm f g h_fg h_gf := Filtration.ext <| funext fun i => (h_fg i).antisymm (h_gf i)
  sup := (· ⊔ ·)
  le_sup_left f g i := le_sup_left
  le_sup_right f g i := le_sup_right
  sup_le f g h h_fh h_gh i := sup_le (h_fh i) (h_gh _)
  inf := (· ⊓ ·)
  inf_le_left f g i := inf_le_left
  inf_le_right f g i := inf_le_right
  le_inf f g h h_fg h_fh i := le_inf (h_fg i) (h_fh i)
  sSup := sSup
  le_sup s f hf_mem i := le_sSup ⟨f, hf_mem, rfl⟩
  sup_le s f h_forall i :=
    sSup_le fun m' hm' => by
      obtain ⟨g, hg_mem, hfm'⟩ := hm'
      rw [← hfm']
      exact h_forall g hg_mem i
  sInf := sInf
  inf_le s f hf_mem i := by
    have hs : s.nonempty := ⟨f, hf_mem⟩
    simp only [Inf_def, hs, if_true]
    exact sInf_le ⟨f, hf_mem, rfl⟩
  le_inf s f h_forall i := by
    by_cases hs : s.nonempty
    swap; · simp only [Inf_def, hs, if_false]; exact f.le i
    simp only [Inf_def, hs, if_true, le_sInf_iff, Set.mem_image, forall_exists_index, and_imp,
      forall_apply_eq_imp_iff₂]
    exact fun g hg_mem => h_forall g hg_mem i
  top := ⊤
  bot := ⊥
  le_top f i := f.le' i
  bot_le f i := bot_le

end Filtration

#print MeasureTheory.measurableSet_of_filtration /-
theorem measurableSet_of_filtration [Preorder ι] {f : Filtration ι m} {s : Set Ω} {i : ι}
    (hs : measurable_set[f i] s) : measurable_set[m] s :=
  f.le i s hs
#align measure_theory.measurable_set_of_filtration MeasureTheory.measurableSet_of_filtration
-/

#print MeasureTheory.SigmaFiniteFiltration /-
/-- A measure is σ-finite with respect to filtration if it is σ-finite with respect
to all the sub-σ-algebra of the filtration. -/
class SigmaFiniteFiltration [Preorder ι] (μ : Measure Ω) (f : Filtration ι m) : Prop where
  SigmaFinite : ∀ i : ι, SigmaFinite (μ.trim (f.le i))
#align measure_theory.sigma_finite_filtration MeasureTheory.SigmaFiniteFiltration
-/

#print MeasureTheory.sigmaFinite_of_sigmaFiniteFiltration /-
instance sigmaFinite_of_sigmaFiniteFiltration [Preorder ι] (μ : Measure Ω) (f : Filtration ι m)
    [hf : SigmaFiniteFiltration μ f] (i : ι) : SigmaFinite (μ.trim (f.le i)) := by
  apply hf.sigma_finite
#align measure_theory.sigma_finite_of_sigma_finite_filtration MeasureTheory.sigmaFinite_of_sigmaFiniteFiltration
-/

#print MeasureTheory.IsFiniteMeasure.sigmaFiniteFiltration /-
-- can't exact here
instance (priority := 100) IsFiniteMeasure.sigmaFiniteFiltration [Preorder ι] (μ : Measure Ω)
    (f : Filtration ι m) [IsFiniteMeasure μ] : SigmaFiniteFiltration μ f :=
  ⟨fun n => by infer_instance⟩
#align measure_theory.is_finite_measure.sigma_finite_filtration MeasureTheory.IsFiniteMeasure.sigmaFiniteFiltration
-/

#print MeasureTheory.Integrable.uniformIntegrable_condexp_filtration /-
/-- Given a integrable function `g`, the conditional expectations of `g` with respect to a
filtration is uniformly integrable. -/
theorem Integrable.uniformIntegrable_condexp_filtration [Preorder ι] {μ : Measure Ω}
    [IsFiniteMeasure μ] {f : Filtration ι m} {g : Ω → ℝ} (hg : Integrable g μ) :
    UniformIntegrable (fun i => μ[g|f i]) 1 μ :=
  hg.uniformIntegrable_condexp f.le
#align measure_theory.integrable.uniform_integrable_condexp_filtration MeasureTheory.Integrable.uniformIntegrable_condexp_filtration
-/

section OfSet

variable [Preorder ι]

#print MeasureTheory.filtrationOfSet /-
/-- Given a sequence of measurable sets `(sₙ)`, `filtration_of_set` is the smallest filtration
such that `sₙ` is measurable with respect to the `n`-the sub-σ-algebra in `filtration_of_set`. -/
def filtrationOfSet {s : ι → Set Ω} (hsm : ∀ i, MeasurableSet (s i)) : Filtration ι m
    where
  seq i := MeasurableSpace.generateFrom {t | ∃ j ≤ i, s j = t}
  mono' n m hnm := MeasurableSpace.generateFrom_mono fun t ⟨k, hk₁, hk₂⟩ => ⟨k, hk₁.trans hnm, hk₂⟩
  le' n := MeasurableSpace.generateFrom_le fun t ⟨k, hk₁, hk₂⟩ => hk₂ ▸ hsm k
#align measure_theory.filtration_of_set MeasureTheory.filtrationOfSet
-/

#print MeasureTheory.measurableSet_filtrationOfSet /-
theorem measurableSet_filtrationOfSet {s : ι → Set Ω} (hsm : ∀ i, measurable_set[m] (s i)) (i : ι)
    {j : ι} (hj : j ≤ i) : measurable_set[filtrationOfSet hsm i] (s j) :=
  MeasurableSpace.measurableSet_generateFrom ⟨j, hj, rfl⟩
#align measure_theory.measurable_set_filtration_of_set MeasureTheory.measurableSet_filtrationOfSet
-/

#print MeasureTheory.measurableSet_filtrationOfSet' /-
theorem measurableSet_filtrationOfSet' {s : ι → Set Ω} (hsm : ∀ n, measurable_set[m] (s n))
    (i : ι) : measurable_set[filtrationOfSet hsm i] (s i) :=
  measurableSet_filtrationOfSet hsm i le_rfl
#align measure_theory.measurable_set_filtration_of_set' MeasureTheory.measurableSet_filtrationOfSet'
-/

end OfSet

namespace Filtration

variable [TopologicalSpace β] [MetrizableSpace β] [mβ : MeasurableSpace β] [BorelSpace β]
  [Preorder ι]

#print MeasureTheory.Filtration.natural /-
/-- Given a sequence of functions, the natural filtration is the smallest sequence
of σ-algebras such that that sequence of functions is measurable with respect to
the filtration. -/
def natural (u : ι → Ω → β) (hum : ∀ i, StronglyMeasurable (u i)) : Filtration ι m
    where
  seq i := ⨆ j ≤ i, MeasurableSpace.comap (u j) mβ
  mono' i j hij := biSup_mono fun k => ge_trans hij
  le' i := by
    refine' iSup₂_le _
    rintro j hj s ⟨t, ht, rfl⟩
    exact (hum j).Measurable ht
#align measure_theory.filtration.natural MeasureTheory.Filtration.natural
-/

section

open MeasurableSpace

#print MeasureTheory.Filtration.filtrationOfSet_eq_natural /-
theorem filtrationOfSet_eq_natural [MulZeroOneClass β] [Nontrivial β] {s : ι → Set Ω}
    (hsm : ∀ i, measurable_set[m] (s i)) :
    filtrationOfSet hsm =
      natural (fun i => (s i).indicator (fun ω => 1 : Ω → β)) fun i =>
        stronglyMeasurable_one.indicator (hsm i) :=
  by
  simp only [natural, filtration_of_set, measurable_space_supr_eq]
  ext1 i
  refine' le_antisymm (generate_from_le _) (generate_from_le _)
  · rintro _ ⟨j, hij, rfl⟩
    refine' measurable_set_generate_from ⟨j, measurable_set_generate_from ⟨hij, _⟩⟩
    rw [comap_eq_generate_from]
    refine' measurable_set_generate_from ⟨{1}, measurable_set_singleton 1, _⟩
    ext x
    simp [Set.indicator_const_preimage_eq_union]
  · rintro t ⟨n, ht⟩
    suffices
      MeasurableSpace.generateFrom
          {t |
            ∃ H : n ≤ i,
              measurable_set[MeasurableSpace.comap ((s n).indicator (fun ω => 1 : Ω → β)) mβ] t} ≤
        generate_from {t | ∃ (j : ι) (H : j ≤ i), s j = t}
      by exact this _ ht
    refine' generate_from_le _
    rintro t ⟨hn, u, hu, hu'⟩
    obtain heq | heq | heq | heq := Set.indicator_const_preimage (s n) u (1 : β)
    pick_goal 4; rw [Set.mem_singleton_iff] at heq 
    all_goals rw [HEq] at hu' ; rw [← hu']
    exacts [measurable_set_empty _, MeasurableSet.univ, measurable_set_generate_from ⟨n, hn, rfl⟩,
      MeasurableSet.compl (measurable_set_generate_from ⟨n, hn, rfl⟩)]
#align measure_theory.filtration.filtration_of_set_eq_natural MeasureTheory.Filtration.filtrationOfSet_eq_natural
-/

end

section Limit

variable {E : Type _} [Zero E] [TopologicalSpace E] {ℱ : Filtration ι m} {f : ι → Ω → E}
  {μ : Measure Ω}

#print MeasureTheory.Filtration.limitProcess /-
/-- Given a process `f` and a filtration `ℱ`, if `f` converges to some `g` almost everywhere and
`g` is `⨆ n, ℱ n`-measurable, then `limit_process f ℱ μ` chooses said `g`, else it returns 0.

This definition is used to phrase the a.e. martingale convergence theorem
`submartingale.ae_tendsto_limit_process` where an L¹-bounded submartingale `f` adapted to `ℱ`
converges to `limit_process f ℱ μ` `μ`-almost everywhere. -/
noncomputable def limitProcess (f : ι → Ω → E) (ℱ : Filtration ι m)
    (μ : Measure Ω := by exact MeasureTheory.MeasureSpace.volume) :=
  if h :
      ∃ g : Ω → E,
        strongly_measurable[⨆ n, ℱ n] g ∧ ∀ᵐ ω ∂μ, Tendsto (fun n => f n ω) atTop (𝓝 (g ω)) then
    Classical.choose h
  else 0
#align measure_theory.filtration.limit_process MeasureTheory.Filtration.limitProcess
-/

#print MeasureTheory.Filtration.stronglyMeasurable_limitProcess /-
theorem stronglyMeasurable_limitProcess : strongly_measurable[⨆ n, ℱ n] (limitProcess f ℱ μ) :=
  by
  rw [limit_process]
  split_ifs with h h
  exacts [(Classical.choose_spec h).1, strongly_measurable_zero]
#align measure_theory.filtration.strongly_measurable_limit_process MeasureTheory.Filtration.stronglyMeasurable_limitProcess
-/

#print MeasureTheory.Filtration.stronglyMeasurable_limit_process' /-
theorem stronglyMeasurable_limit_process' : strongly_measurable[m] (limitProcess f ℱ μ) :=
  stronglyMeasurable_limitProcess.mono (sSup_le fun m ⟨n, hn⟩ => hn ▸ ℱ.le _)
#align measure_theory.filtration.strongly_measurable_limit_process' MeasureTheory.Filtration.stronglyMeasurable_limit_process'
-/

#print MeasureTheory.Filtration.memℒp_limitProcess_of_snorm_bdd /-
theorem memℒp_limitProcess_of_snorm_bdd {R : ℝ≥0} {p : ℝ≥0∞} {F : Type _} [NormedAddCommGroup F]
    {ℱ : Filtration ℕ m} {f : ℕ → Ω → F} (hfm : ∀ n, AEStronglyMeasurable (f n) μ)
    (hbdd : ∀ n, snorm (f n) p μ ≤ R) : Memℒp (limitProcess f ℱ μ) p μ :=
  by
  rw [limit_process]
  split_ifs with h
  · refine'
      ⟨strongly_measurable.ae_strongly_measurable
          ((Classical.choose_spec h).1.mono (sSup_le fun m ⟨n, hn⟩ => hn ▸ ℱ.le _)),
        lt_of_le_of_lt (Lp.snorm_lim_le_liminf_snorm hfm _ (Classical.choose_spec h).2)
          (lt_of_le_of_lt _ (ENNReal.coe_lt_top : ↑R < ∞))⟩
    simp_rw [liminf_eq, eventually_at_top]
    exact sSup_le fun b ⟨a, ha⟩ => (ha a le_rfl).trans (hbdd _)
  · exact zero_mem_ℒp
#align measure_theory.filtration.mem_ℒp_limit_process_of_snorm_bdd MeasureTheory.Filtration.memℒp_limitProcess_of_snorm_bdd
-/

end Limit

end Filtration

end MeasureTheory

