/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Yaël Dillies, Bhavik Mehta

! This file was ported from Lean 3 source module data.finset.sigma
! leanprover-community/mathlib commit cc70d9141824ea8982d1562ce009952f2c3ece30
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finset.Lattice
import Mathbin.Data.Set.Sigma

/-!
# Finite sets in a sigma type

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines a few `finset` constructions on `Σ i, α i`.

## Main declarations

* `finset.sigma`: Given a finset `s` in `ι` and finsets `t i` in each `α i`, `s.sigma t` is the
  finset of the dependent sum `Σ i, α i`
* `finset.sigma_lift`: Lifts maps `α i → β i → finset (γ i)` to a map
  `Σ i, α i → Σ i, β i → finset (Σ i, γ i)`.

## TODO

`finset.sigma_lift` can be generalized to any alternative functor. But to make the generalization
worth it, we must first refactor the functor library so that the `alternative` instance for `finset`
is computable and universe-polymorphic.
-/


open Function Multiset

variable {ι : Type _}

namespace Finset

section Sigma

variable {α : ι → Type _} {β : Type _} (s s₁ s₂ : Finset ι) (t t₁ t₂ : ∀ i, Finset (α i))

#print Finset.sigma /-
/-- `s.sigma t` is the finset of dependent pairs `⟨i, a⟩` such that `i ∈ s` and `a ∈ t i`. -/
protected def sigma : Finset (Σ i, α i) :=
  ⟨_, s.Nodup.Sigma fun i => (t i).Nodup⟩
#align finset.sigma Finset.sigma
-/

variable {s s₁ s₂ t t₁ t₂}

#print Finset.mem_sigma /-
@[simp]
theorem mem_sigma {a : Σ i, α i} : a ∈ s.Sigma t ↔ a.1 ∈ s ∧ a.2 ∈ t a.1 :=
  mem_sigma
#align finset.mem_sigma Finset.mem_sigma
-/

#print Finset.coe_sigma /-
@[simp, norm_cast]
theorem coe_sigma (s : Finset ι) (t : ∀ i, Finset (α i)) :
    (s.Sigma t : Set (Σ i, α i)) = (s : Set ι).Sigma fun i => t i :=
  Set.ext fun _ => mem_sigma
#align finset.coe_sigma Finset.coe_sigma
-/

#print Finset.sigma_nonempty /-
@[simp]
theorem sigma_nonempty : (s.Sigma t).Nonempty ↔ ∃ i ∈ s, (t i).Nonempty := by simp [Finset.Nonempty]
#align finset.sigma_nonempty Finset.sigma_nonempty
-/

#print Finset.sigma_eq_empty /-
@[simp]
theorem sigma_eq_empty : s.Sigma t = ∅ ↔ ∀ i ∈ s, t i = ∅ := by
  simp only [← not_nonempty_iff_eq_empty, sigma_nonempty, not_exists]
#align finset.sigma_eq_empty Finset.sigma_eq_empty
-/

#print Finset.sigma_mono /-
@[mono]
theorem sigma_mono (hs : s₁ ⊆ s₂) (ht : ∀ i, t₁ i ⊆ t₂ i) : s₁.Sigma t₁ ⊆ s₂.Sigma t₂ :=
  fun ⟨i, a⟩ h =>
  let ⟨hi, ha⟩ := mem_sigma.1 h
  mem_sigma.2 ⟨hs hi, ht i ha⟩
#align finset.sigma_mono Finset.sigma_mono
-/

#print Finset.pairwiseDisjoint_map_sigmaMk /-
theorem pairwiseDisjoint_map_sigmaMk :
    (s : Set ι).PairwiseDisjoint fun i => (t i).map (Embedding.sigmaMk i) :=
  by
  intro i hi j hj hij
  rw [Function.onFun, disjoint_left]
  simp_rw [mem_map, Function.Embedding.sigmaMk_apply]
  rintro _ ⟨y, hy, rfl⟩ ⟨z, hz, hz'⟩
  exact hij (congr_arg Sigma.fst hz'.symm)
#align finset.pairwise_disjoint_map_sigma_mk Finset.pairwiseDisjoint_map_sigmaMk
-/

#print Finset.disjiUnion_map_sigma_mk /-
@[simp]
theorem disjiUnion_map_sigma_mk :
    s.disjUnionₓ (fun i => (t i).map (Embedding.sigmaMk i)) pairwiseDisjoint_map_sigmaMk =
      s.Sigma t :=
  rfl
#align finset.disj_Union_map_sigma_mk Finset.disjiUnion_map_sigma_mk
-/

#print Finset.sigma_eq_biUnion /-
theorem sigma_eq_biUnion [DecidableEq (Σ i, α i)] (s : Finset ι) (t : ∀ i, Finset (α i)) :
    s.Sigma t = s.biUnion fun i => (t i).map <| Embedding.sigmaMk i := by ext ⟨x, y⟩;
  simp [and_left_comm]
#align finset.sigma_eq_bUnion Finset.sigma_eq_biUnion
-/

variable (s t) (f : (Σ i, α i) → β)

#print Finset.sup_sigma /-
theorem sup_sigma [SemilatticeSup β] [OrderBot β] :
    (s.Sigma t).sup f = s.sup fun i => (t i).sup fun b => f ⟨i, b⟩ :=
  by
  simp only [le_antisymm_iff, Finset.sup_le_iff, mem_sigma, and_imp, Sigma.forall]
  exact
    ⟨fun i a hi ha => (le_sup hi).trans' <| le_sup ha, fun i hi a ha =>
      le_sup <| mem_sigma.2 ⟨hi, ha⟩⟩
#align finset.sup_sigma Finset.sup_sigma
-/

#print Finset.inf_sigma /-
theorem inf_sigma [SemilatticeInf β] [OrderTop β] :
    (s.Sigma t).inf f = s.inf fun i => (t i).inf fun b => f ⟨i, b⟩ :=
  @sup_sigma _ _ βᵒᵈ _ _ _ _ _
#align finset.inf_sigma Finset.inf_sigma
-/

end Sigma

section SigmaLift

variable {α β γ : ι → Type _} [DecidableEq ι]

#print Finset.sigmaLift /-
/-- Lifts maps `α i → β i → finset (γ i)` to a map `Σ i, α i → Σ i, β i → finset (Σ i, γ i)`. -/
def sigmaLift (f : ∀ ⦃i⦄, α i → β i → Finset (γ i)) (a : Sigma α) (b : Sigma β) :
    Finset (Sigma γ) :=
  dite (a.1 = b.1) (fun h => (f (h.rec a.2) b.2).map <| Embedding.sigmaMk _) fun _ => ∅
#align finset.sigma_lift Finset.sigmaLift
-/

#print Finset.mem_sigmaLift /-
theorem mem_sigmaLift (f : ∀ ⦃i⦄, α i → β i → Finset (γ i)) (a : Sigma α) (b : Sigma β)
    (x : Sigma γ) :
    x ∈ sigmaLift f a b ↔ ∃ (ha : a.1 = x.1) (hb : b.1 = x.1), x.2 ∈ f (ha.rec a.2) (hb.rec b.2) :=
  by
  obtain ⟨⟨i, a⟩, j, b⟩ := a, b
  obtain rfl | h := Decidable.eq_or_ne i j
  · constructor
    · simp_rw [sigma_lift, dif_pos rfl, mem_map, embedding.sigma_mk_apply]
      rintro ⟨x, hx, rfl⟩
      exact ⟨rfl, rfl, hx⟩
    · rintro ⟨⟨⟩, ⟨⟩, hx⟩
      rw [sigma_lift, dif_pos rfl, mem_map]
      exact ⟨_, hx, by simp [Sigma.ext_iff]⟩
  · rw [sigma_lift, dif_neg h]
    refine' iff_of_false (not_mem_empty _) _
    rintro ⟨⟨⟩, ⟨⟩, _⟩
    exact h rfl
#align finset.mem_sigma_lift Finset.mem_sigmaLift
-/

#print Finset.mk_mem_sigmaLift /-
theorem mk_mem_sigmaLift (f : ∀ ⦃i⦄, α i → β i → Finset (γ i)) (i : ι) (a : α i) (b : β i)
    (x : γ i) : (⟨i, x⟩ : Sigma γ) ∈ sigmaLift f ⟨i, a⟩ ⟨i, b⟩ ↔ x ∈ f a b :=
  by
  rw [sigma_lift, dif_pos rfl, mem_map]
  refine' ⟨_, fun hx => ⟨_, hx, rfl⟩⟩
  rintro ⟨x, hx, _, rfl⟩
  exact hx
#align finset.mk_mem_sigma_lift Finset.mk_mem_sigmaLift
-/

#print Finset.not_mem_sigmaLift_of_ne_left /-
theorem not_mem_sigmaLift_of_ne_left (f : ∀ ⦃i⦄, α i → β i → Finset (γ i)) (a : Sigma α)
    (b : Sigma β) (x : Sigma γ) (h : a.1 ≠ x.1) : x ∉ sigmaLift f a b := by rw [mem_sigma_lift];
  exact fun H => h H.fst
#align finset.not_mem_sigma_lift_of_ne_left Finset.not_mem_sigmaLift_of_ne_left
-/

#print Finset.not_mem_sigmaLift_of_ne_right /-
theorem not_mem_sigmaLift_of_ne_right (f : ∀ ⦃i⦄, α i → β i → Finset (γ i)) {a : Sigma α}
    (b : Sigma β) {x : Sigma γ} (h : b.1 ≠ x.1) : x ∉ sigmaLift f a b := by rw [mem_sigma_lift];
  exact fun H => h H.snd.fst
#align finset.not_mem_sigma_lift_of_ne_right Finset.not_mem_sigmaLift_of_ne_right
-/

variable {f g : ∀ ⦃i⦄, α i → β i → Finset (γ i)} {a : Σ i, α i} {b : Σ i, β i}

#print Finset.sigmaLift_nonempty /-
theorem sigmaLift_nonempty :
    (sigmaLift f a b).Nonempty ↔ ∃ h : a.1 = b.1, (f (h.rec a.2) b.2).Nonempty :=
  by
  simp_rw [nonempty_iff_ne_empty]
  convert dite_ne_right_iff
  ext h
  simp_rw [← nonempty_iff_ne_empty]
  exact map_nonempty.symm
#align finset.sigma_lift_nonempty Finset.sigmaLift_nonempty
-/

#print Finset.sigmaLift_eq_empty /-
theorem sigmaLift_eq_empty : sigmaLift f a b = ∅ ↔ ∀ h : a.1 = b.1, f (h.rec a.2) b.2 = ∅ :=
  by
  convert dite_eq_right_iff
  exact forall_congr fun h => propext map_eq_empty.symm
#align finset.sigma_lift_eq_empty Finset.sigmaLift_eq_empty
-/

#print Finset.sigmaLift_mono /-
theorem sigmaLift_mono (h : ∀ ⦃i⦄ ⦃a : α i⦄ ⦃b : β i⦄, f a b ⊆ g a b) (a : Σ i, α i)
    (b : Σ i, β i) : sigmaLift f a b ⊆ sigmaLift g a b :=
  by
  rintro x hx
  rw [mem_sigma_lift] at hx ⊢
  obtain ⟨ha, hb, hx⟩ := hx
  exact ⟨ha, hb, h hx⟩
#align finset.sigma_lift_mono Finset.sigmaLift_mono
-/

variable (f a b)

#print Finset.card_sigmaLift /-
theorem card_sigmaLift :
    (sigmaLift f a b).card = dite (a.1 = b.1) (fun h => (f (h.rec a.2) b.2).card) fun _ => 0 := by
  convert apply_dite _ _ _ _; ext h; exact (card_map _).symm
#align finset.card_sigma_lift Finset.card_sigmaLift
-/

end SigmaLift

end Finset

