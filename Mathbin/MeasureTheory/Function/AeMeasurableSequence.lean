/-
Copyright (c) 2021 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne

! This file was ported from Lean 3 source module measure_theory.function.ae_measurable_sequence
! leanprover-community/mathlib commit b5ad141426bb005414324f89719c77c0aa3ec612
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.MeasurableSpace

/-!
# Sequence of measurable functions associated to a sequence of a.e.-measurable functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define here tools to prove statements about limits (infi, supr...) of sequences of
`ae_measurable` functions.
Given a sequence of a.e.-measurable functions `f : ι → α → β` with hypothesis
`hf : ∀ i, ae_measurable (f i) μ`, and a pointwise property `p : α → (ι → β) → Prop` such that we
have `hp : ∀ᵐ x ∂μ, p x (λ n, f n x)`, we define a sequence of measurable functions `ae_seq hf p`
and a measurable set `ae_seq_set hf p`, such that
* `μ (ae_seq_set hf p)ᶜ = 0`
* `x ∈ ae_seq_set hf p → ∀ i : ι, ae_seq hf hp i x = f i x`
* `x ∈ ae_seq_set hf p → p x (λ n, f n x)`
-/


open MeasureTheory

open scoped Classical

variable {ι : Sort _} {α β γ : Type _} [MeasurableSpace α] [MeasurableSpace β] {f : ι → α → β}
  {μ : Measure α} {p : α → (ι → β) → Prop}

#print aeSeqSet /-
/-- If we have the additional hypothesis `∀ᵐ x ∂μ, p x (λ n, f n x)`, this is a measurable set
whose complement has measure 0 such that for all `x ∈ ae_seq_set`, `f i x` is equal to
`(hf i).mk (f i) x` for all `i` and we have the pointwise property `p x (λ n, f n x)`. -/
def aeSeqSet (hf : ∀ i, AEMeasurable (f i) μ) (p : α → (ι → β) → Prop) : Set α :=
  toMeasurable μ ({x | (∀ i, f i x = (hf i).mk (f i) x) ∧ p x fun n => f n x}ᶜ)ᶜ
#align ae_seq_set aeSeqSet
-/

#print aeSeq /-
/-- A sequence of measurable functions that are equal to `f` and verify property `p` on the
measurable set `ae_seq_set hf p`. -/
noncomputable def aeSeq (hf : ∀ i, AEMeasurable (f i) μ) (p : α → (ι → β) → Prop) : ι → α → β :=
  fun i x => ite (x ∈ aeSeqSet hf p) ((hf i).mk (f i) x) (⟨f i x⟩ : Nonempty β).some
#align ae_seq aeSeq
-/

namespace aeSeq

section MemAeSeqSet

#print aeSeq.mk_eq_fun_of_mem_aeSeqSet /-
theorem mk_eq_fun_of_mem_aeSeqSet (hf : ∀ i, AEMeasurable (f i) μ) {x : α} (hx : x ∈ aeSeqSet hf p)
    (i : ι) : (hf i).mk (f i) x = f i x :=
  haveI h_ss : aeSeqSet hf p ⊆ {x | ∀ i, f i x = (hf i).mk (f i) x} :=
    by
    rw [aeSeqSet, ← compl_compl {x | ∀ i, f i x = (hf i).mk (f i) x}, Set.compl_subset_compl]
    refine' Set.Subset.trans (set.compl_subset_compl.mpr fun x h => _) (subset_to_measurable _ _)
    exact h.1
  (h_ss hx i).symm
#align ae_seq.mk_eq_fun_of_mem_ae_seq_set aeSeq.mk_eq_fun_of_mem_aeSeqSet
-/

#print aeSeq.aeSeq_eq_mk_of_mem_aeSeqSet /-
theorem aeSeq_eq_mk_of_mem_aeSeqSet (hf : ∀ i, AEMeasurable (f i) μ) {x : α}
    (hx : x ∈ aeSeqSet hf p) (i : ι) : aeSeq hf p i x = (hf i).mk (f i) x := by
  simp only [aeSeq, hx, if_true]
#align ae_seq.ae_seq_eq_mk_of_mem_ae_seq_set aeSeq.aeSeq_eq_mk_of_mem_aeSeqSet
-/

#print aeSeq.aeSeq_eq_fun_of_mem_aeSeqSet /-
theorem aeSeq_eq_fun_of_mem_aeSeqSet (hf : ∀ i, AEMeasurable (f i) μ) {x : α}
    (hx : x ∈ aeSeqSet hf p) (i : ι) : aeSeq hf p i x = f i x := by
  simp only [ae_seq_eq_mk_of_mem_ae_seq_set hf hx i, mk_eq_fun_of_mem_ae_seq_set hf hx i]
#align ae_seq.ae_seq_eq_fun_of_mem_ae_seq_set aeSeq.aeSeq_eq_fun_of_mem_aeSeqSet
-/

#print aeSeq.prop_of_mem_aeSeqSet /-
theorem prop_of_mem_aeSeqSet (hf : ∀ i, AEMeasurable (f i) μ) {x : α} (hx : x ∈ aeSeqSet hf p) :
    p x fun n => aeSeq hf p n x :=
  by
  simp only [aeSeq, hx, if_true]
  rw [funext fun n => mk_eq_fun_of_mem_ae_seq_set hf hx n]
  have h_ss : aeSeqSet hf p ⊆ {x | p x fun n => f n x} :=
    by
    rw [← compl_compl {x | p x fun n => f n x}, aeSeqSet, Set.compl_subset_compl]
    refine' Set.Subset.trans (set.compl_subset_compl.mpr _) (subset_to_measurable _ _)
    exact fun x hx => hx.2
  have hx' := Set.mem_of_subset_of_mem h_ss hx
  exact hx'
#align ae_seq.prop_of_mem_ae_seq_set aeSeq.prop_of_mem_aeSeqSet
-/

#print aeSeq.fun_prop_of_mem_aeSeqSet /-
theorem fun_prop_of_mem_aeSeqSet (hf : ∀ i, AEMeasurable (f i) μ) {x : α} (hx : x ∈ aeSeqSet hf p) :
    p x fun n => f n x :=
  by
  have h_eq : (fun n => f n x) = fun n => aeSeq hf p n x :=
    funext fun n => (ae_seq_eq_fun_of_mem_ae_seq_set hf hx n).symm
  rw [h_eq]
  exact prop_of_mem_ae_seq_set hf hx
#align ae_seq.fun_prop_of_mem_ae_seq_set aeSeq.fun_prop_of_mem_aeSeqSet
-/

end MemAeSeqSet

#print aeSeq.aeSeqSet_measurableSet /-
theorem aeSeqSet_measurableSet {hf : ∀ i, AEMeasurable (f i) μ} : MeasurableSet (aeSeqSet hf p) :=
  (measurableSet_toMeasurable _ _).compl
#align ae_seq.ae_seq_set_measurable_set aeSeq.aeSeqSet_measurableSet
-/

#print aeSeq.measurable /-
theorem measurable (hf : ∀ i, AEMeasurable (f i) μ) (p : α → (ι → β) → Prop) (i : ι) :
    Measurable (aeSeq hf p i) :=
  Measurable.ite aeSeqSet_measurableSet (hf i).measurable_mk <| measurable_const' fun x y => rfl
#align ae_seq.measurable aeSeq.measurable
-/

#print aeSeq.measure_compl_aeSeqSet_eq_zero /-
theorem measure_compl_aeSeqSet_eq_zero [Countable ι] (hf : ∀ i, AEMeasurable (f i) μ)
    (hp : ∀ᵐ x ∂μ, p x fun n => f n x) : μ (aeSeqSet hf pᶜ) = 0 :=
  by
  rw [aeSeqSet, compl_compl, measure_to_measurable]
  have hf_eq := fun i => (hf i).ae_eq_mk
  simp_rw [Filter.EventuallyEq, ← ae_all_iff] at hf_eq 
  exact Filter.Eventually.and hf_eq hp
#align ae_seq.measure_compl_ae_seq_set_eq_zero aeSeq.measure_compl_aeSeqSet_eq_zero
-/

#print aeSeq.aeSeq_eq_mk_ae /-
theorem aeSeq_eq_mk_ae [Countable ι] (hf : ∀ i, AEMeasurable (f i) μ)
    (hp : ∀ᵐ x ∂μ, p x fun n => f n x) : ∀ᵐ a : α ∂μ, ∀ i : ι, aeSeq hf p i a = (hf i).mk (f i) a :=
  haveI h_ss : aeSeqSet hf p ⊆ {a : α | ∀ i, aeSeq hf p i a = (hf i).mk (f i) a} := fun x hx i => by
    simp only [aeSeq, hx, if_true]
  le_antisymm
    (le_trans (measure_mono (set.compl_subset_compl.mpr h_ss))
      (le_of_eq (measure_compl_ae_seq_set_eq_zero hf hp)))
    (zero_le _)
#align ae_seq.ae_seq_eq_mk_ae aeSeq.aeSeq_eq_mk_ae
-/

#print aeSeq.aeSeq_eq_fun_ae /-
theorem aeSeq_eq_fun_ae [Countable ι] (hf : ∀ i, AEMeasurable (f i) μ)
    (hp : ∀ᵐ x ∂μ, p x fun n => f n x) : ∀ᵐ a : α ∂μ, ∀ i : ι, aeSeq hf p i a = f i a :=
  haveI h_ss : {a : α | ¬∀ i : ι, aeSeq hf p i a = f i a} ⊆ aeSeqSet hf pᶜ := fun x =>
    mt fun hx i => ae_seq_eq_fun_of_mem_ae_seq_set hf hx i
  measure_mono_null h_ss (measure_compl_ae_seq_set_eq_zero hf hp)
#align ae_seq.ae_seq_eq_fun_ae aeSeq.aeSeq_eq_fun_ae
-/

#print aeSeq.aeSeq_n_eq_fun_n_ae /-
theorem aeSeq_n_eq_fun_n_ae [Countable ι] (hf : ∀ i, AEMeasurable (f i) μ)
    (hp : ∀ᵐ x ∂μ, p x fun n => f n x) (n : ι) : aeSeq hf p n =ᵐ[μ] f n :=
  ae_all_iff.mp (aeSeq_eq_fun_ae hf hp) n
#align ae_seq.ae_seq_n_eq_fun_n_ae aeSeq.aeSeq_n_eq_fun_n_ae
-/

#print aeSeq.iSup /-
theorem iSup [CompleteLattice β] [Countable ι] (hf : ∀ i, AEMeasurable (f i) μ)
    (hp : ∀ᵐ x ∂μ, p x fun n => f n x) : (⨆ n, aeSeq hf p n) =ᵐ[μ] ⨆ n, f n :=
  by
  simp_rw [Filter.EventuallyEq, ae_iff, iSup_apply]
  have h_ss : aeSeqSet hf p ⊆ {a : α | (⨆ i : ι, aeSeq hf p i a) = ⨆ i : ι, f i a} :=
    by
    intro x hx
    congr
    exact funext fun i => ae_seq_eq_fun_of_mem_ae_seq_set hf hx i
  exact measure_mono_null (set.compl_subset_compl.mpr h_ss) (measure_compl_ae_seq_set_eq_zero hf hp)
#align ae_seq.supr aeSeq.iSup
-/

end aeSeq

