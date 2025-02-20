/-
Copyright (c) 2022 Yaël Dillies, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Bhavik Mehta

! This file was ported from Lean 3 source module combinatorics.simple_graph.density
! leanprover-community/mathlib commit ee05e9ce1322178f0c12004eb93c00d2c8c00ed2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Combinatorics.SimpleGraph.Basic
import Mathbin.Order.Partition.Finpartition
import Mathbin.Tactic.Positivity

/-!
# Edge density

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the number and density of edges of a relation/graph.

## Main declarations

Between two finsets of vertices,
* `rel.interedges`: Finset of edges of a relation.
* `rel.edge_density`: Edge density of a relation.
* `simple_graph.interedges`: Finset of edges of a graph.
* `simple_graph.edge_density`: Edge density of a graph.
-/


open Finset

open scoped BigOperators

variable {𝕜 ι κ α β : Type _}

/-! ### Density of a relation -/


namespace Rel

section Asymmetric

variable [LinearOrderedField 𝕜] (r : α → β → Prop) [∀ a, DecidablePred (r a)] {s s₁ s₂ : Finset α}
  {t t₁ t₂ : Finset β} {a : α} {b : β} {δ : 𝕜}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Rel.interedges /-
/-- Finset of edges of a relation between two finsets of vertices. -/
def interedges (s : Finset α) (t : Finset β) : Finset (α × β) :=
  (s ×ˢ t).filterₓ fun e => r e.1 e.2
#align rel.interedges Rel.interedges
-/

#print Rel.edgeDensity /-
/-- Edge density of a relation between two finsets of vertices. -/
def edgeDensity (s : Finset α) (t : Finset β) : ℚ :=
  (interedges r s t).card / (s.card * t.card)
#align rel.edge_density Rel.edgeDensity
-/

variable {r}

#print Rel.mem_interedges_iff /-
theorem mem_interedges_iff {x : α × β} : x ∈ interedges r s t ↔ x.1 ∈ s ∧ x.2 ∈ t ∧ r x.1 x.2 := by
  simp only [interedges, and_assoc', mem_filter, Finset.mem_product]
#align rel.mem_interedges_iff Rel.mem_interedges_iff
-/

#print Rel.mk_mem_interedges_iff /-
theorem mk_mem_interedges_iff : (a, b) ∈ interedges r s t ↔ a ∈ s ∧ b ∈ t ∧ r a b :=
  mem_interedges_iff
#align rel.mk_mem_interedges_iff Rel.mk_mem_interedges_iff
-/

#print Rel.interedges_empty_left /-
@[simp]
theorem interedges_empty_left (t : Finset β) : interedges r ∅ t = ∅ := by
  rw [interedges, Finset.empty_product, filter_empty]
#align rel.interedges_empty_left Rel.interedges_empty_left
-/

#print Rel.interedges_mono /-
theorem interedges_mono (hs : s₂ ⊆ s₁) (ht : t₂ ⊆ t₁) : interedges r s₂ t₂ ⊆ interedges r s₁ t₁ :=
  fun x => by simp_rw [mem_interedges_iff]; exact fun h => ⟨hs h.1, ht h.2.1, h.2.2⟩
#align rel.interedges_mono Rel.interedges_mono
-/

variable (r)

#print Rel.card_interedges_add_card_interedges_compl /-
theorem card_interedges_add_card_interedges_compl (s : Finset α) (t : Finset β) :
    (interedges r s t).card + (interedges (fun x y => ¬r x y) s t).card = s.card * t.card := by
  classical
  rw [← card_product, interedges, interedges, ← card_union_eq, filter_union_filter_neg_eq]
  convert disjoint_filter.2 fun x _ => Classical.not_not.2
#align rel.card_interedges_add_card_interedges_compl Rel.card_interedges_add_card_interedges_compl
-/

#print Rel.interedges_disjoint_left /-
theorem interedges_disjoint_left {s s' : Finset α} (hs : Disjoint s s') (t : Finset β) :
    Disjoint (interedges r s t) (interedges r s' t) :=
  by
  rw [Finset.disjoint_left] at hs ⊢
  rintro x hx hy
  rw [mem_interedges_iff] at hx hy 
  exact hs hx.1 hy.1
#align rel.interedges_disjoint_left Rel.interedges_disjoint_left
-/

#print Rel.interedges_disjoint_right /-
theorem interedges_disjoint_right (s : Finset α) {t t' : Finset β} (ht : Disjoint t t') :
    Disjoint (interedges r s t) (interedges r s t') :=
  by
  rw [Finset.disjoint_left] at ht ⊢
  rintro x hx hy
  rw [mem_interedges_iff] at hx hy 
  exact ht hx.2.1 hy.2.1
#align rel.interedges_disjoint_right Rel.interedges_disjoint_right
-/

section DecidableEq

variable [DecidableEq α] [DecidableEq β]

#print Rel.interedges_biUnion_left /-
theorem interedges_biUnion_left (s : Finset ι) (t : Finset β) (f : ι → Finset α) :
    interedges r (s.biUnion f) t = s.biUnion fun a => interedges r (f a) t :=
  ext fun a => by simp only [mem_bUnion, mem_interedges_iff, exists_and_right]
#align rel.interedges_bUnion_left Rel.interedges_biUnion_left
-/

#print Rel.interedges_biUnion_right /-
theorem interedges_biUnion_right (s : Finset α) (t : Finset ι) (f : ι → Finset β) :
    interedges r s (t.biUnion f) = t.biUnion fun b => interedges r s (f b) :=
  ext fun a => by simp only [mem_interedges_iff, mem_bUnion, ← exists_and_left, ← exists_and_right]
#align rel.interedges_bUnion_right Rel.interedges_biUnion_right
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Rel.interedges_biUnion /-
theorem interedges_biUnion (s : Finset ι) (t : Finset κ) (f : ι → Finset α) (g : κ → Finset β) :
    interedges r (s.biUnion f) (t.biUnion g) =
      (s ×ˢ t).biUnion fun ab => interedges r (f ab.1) (g ab.2) :=
  by simp_rw [product_bUnion, interedges_bUnion_left, interedges_bUnion_right]
#align rel.interedges_bUnion Rel.interedges_biUnion
-/

end DecidableEq

#print Rel.card_interedges_le_mul /-
theorem card_interedges_le_mul (s : Finset α) (t : Finset β) :
    (interedges r s t).card ≤ s.card * t.card :=
  (card_filter_le _ _).trans (card_product _ _).le
#align rel.card_interedges_le_mul Rel.card_interedges_le_mul
-/

#print Rel.edgeDensity_nonneg /-
theorem edgeDensity_nonneg (s : Finset α) (t : Finset β) : 0 ≤ edgeDensity r s t := by
  apply div_nonneg <;> exact_mod_cast Nat.zero_le _
#align rel.edge_density_nonneg Rel.edgeDensity_nonneg
-/

#print Rel.edgeDensity_le_one /-
theorem edgeDensity_le_one (s : Finset α) (t : Finset β) : edgeDensity r s t ≤ 1 :=
  div_le_one_of_le (by exact_mod_cast card_interedges_le_mul _ _ _) <| by
    exact_mod_cast Nat.zero_le _
#align rel.edge_density_le_one Rel.edgeDensity_le_one
-/

#print Rel.edgeDensity_add_edgeDensity_compl /-
theorem edgeDensity_add_edgeDensity_compl (hs : s.Nonempty) (ht : t.Nonempty) :
    edgeDensity r s t + edgeDensity (fun x y => ¬r x y) s t = 1 :=
  by
  rw [edge_density, edge_density, div_add_div_same, div_eq_one_iff_eq]
  · exact_mod_cast card_interedges_add_card_interedges_compl r s t
  · exact_mod_cast (mul_pos hs.card_pos ht.card_pos).ne'
#align rel.edge_density_add_edge_density_compl Rel.edgeDensity_add_edgeDensity_compl
-/

#print Rel.edgeDensity_empty_left /-
@[simp]
theorem edgeDensity_empty_left (t : Finset β) : edgeDensity r ∅ t = 0 := by
  rw [edge_density, Finset.card_empty, Nat.cast_zero, MulZeroClass.zero_mul, div_zero]
#align rel.edge_density_empty_left Rel.edgeDensity_empty_left
-/

#print Rel.edgeDensity_empty_right /-
@[simp]
theorem edgeDensity_empty_right (s : Finset α) : edgeDensity r s ∅ = 0 := by
  rw [edge_density, Finset.card_empty, Nat.cast_zero, MulZeroClass.mul_zero, div_zero]
#align rel.edge_density_empty_right Rel.edgeDensity_empty_right
-/

#print Rel.card_interedges_finpartition_left /-
theorem card_interedges_finpartition_left [DecidableEq α] (P : Finpartition s) (t : Finset β) :
    (interedges r s t).card = ∑ a in P.parts, (interedges r a t).card := by
  classical
  simp_rw [← P.bUnion_parts, interedges_bUnion_left, id.def]
  rw [card_bUnion]
  exact fun x hx y hy h => interedges_disjoint_left r (P.disjoint hx hy h) _
#align rel.card_interedges_finpartition_left Rel.card_interedges_finpartition_left
-/

#print Rel.card_interedges_finpartition_right /-
theorem card_interedges_finpartition_right [DecidableEq β] (s : Finset α) (P : Finpartition t) :
    (interedges r s t).card = ∑ b in P.parts, (interedges r s b).card := by
  classical
  simp_rw [← P.bUnion_parts, interedges_bUnion_right, id]
  rw [card_bUnion]
  exact fun x hx y hy h => interedges_disjoint_right r _ (P.disjoint hx hy h)
#align rel.card_interedges_finpartition_right Rel.card_interedges_finpartition_right
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Rel.card_interedges_finpartition /-
theorem card_interedges_finpartition [DecidableEq α] [DecidableEq β] (P : Finpartition s)
    (Q : Finpartition t) :
    (interedges r s t).card = ∑ ab in P.parts ×ˢ Q.parts, (interedges r ab.1 ab.2).card := by
  simp_rw [card_interedges_finpartition_left _ P, card_interedges_finpartition_right _ _ Q,
    sum_product]
#align rel.card_interedges_finpartition Rel.card_interedges_finpartition
-/

#print Rel.mul_edgeDensity_le_edgeDensity /-
theorem mul_edgeDensity_le_edgeDensity (hs : s₂ ⊆ s₁) (ht : t₂ ⊆ t₁) (hs₂ : s₂.Nonempty)
    (ht₂ : t₂.Nonempty) :
    (s₂.card : ℚ) / s₁.card * (t₂.card / t₁.card) * edgeDensity r s₂ t₂ ≤ edgeDensity r s₁ t₁ :=
  by
  have hst : (s₂.card : ℚ) * t₂.card ≠ 0 := by simp [hs₂.ne_empty, ht₂.ne_empty]
  rw [edge_density, edge_density, div_mul_div_comm, mul_comm, div_mul_div_cancel _ hst]
  refine' div_le_div_of_le (by exact_mod_cast (s₁.card * t₁.card).zero_le) _
  exact_mod_cast card_le_of_subset (interedges_mono hs ht)
#align rel.mul_edge_density_le_edge_density Rel.mul_edgeDensity_le_edgeDensity
-/

#print Rel.edgeDensity_sub_edgeDensity_le_one_sub_mul /-
theorem edgeDensity_sub_edgeDensity_le_one_sub_mul (hs : s₂ ⊆ s₁) (ht : t₂ ⊆ t₁) (hs₂ : s₂.Nonempty)
    (ht₂ : t₂.Nonempty) :
    edgeDensity r s₂ t₂ - edgeDensity r s₁ t₁ ≤ 1 - s₂.card / s₁.card * (t₂.card / t₁.card) :=
  by
  refine' (sub_le_sub_left (mul_edge_density_le_edge_density r hs ht hs₂ ht₂) _).trans _
  refine' le_trans _ (mul_le_of_le_one_right _ (edge_density_le_one r s₂ t₂))
  · rw [sub_mul, one_mul]
  refine' sub_nonneg_of_le (mul_le_one _ (by positivity) _) <;>
    exact div_le_one_of_le (Nat.cast_le.2 (card_le_of_subset ‹_›)) (Nat.cast_nonneg _)
#align rel.edge_density_sub_edge_density_le_one_sub_mul Rel.edgeDensity_sub_edgeDensity_le_one_sub_mul
-/

#print Rel.abs_edgeDensity_sub_edgeDensity_le_one_sub_mul /-
theorem abs_edgeDensity_sub_edgeDensity_le_one_sub_mul (hs : s₂ ⊆ s₁) (ht : t₂ ⊆ t₁)
    (hs₂ : s₂.Nonempty) (ht₂ : t₂.Nonempty) :
    |edgeDensity r s₂ t₂ - edgeDensity r s₁ t₁| ≤ 1 - s₂.card / s₁.card * (t₂.card / t₁.card) :=
  by
  have habs : abs (edge_density r s₂ t₂ - edge_density r s₁ t₁) ≤ 1 :=
    by
    rw [abs_sub_le_iff, ← sub_zero (1 : ℚ)]
    constructor <;> exact sub_le_sub (edge_density_le_one r _ _) (edge_density_nonneg r _ _)
  refine' abs_sub_le_iff.2 ⟨edge_density_sub_edge_density_le_one_sub_mul r hs ht hs₂ ht₂, _⟩
  rw [← add_sub_cancel (edge_density r s₁ t₁) (edge_density (fun x y => ¬r x y) s₁ t₁), ←
    add_sub_cancel (edge_density r s₂ t₂) (edge_density (fun x y => ¬r x y) s₂ t₂),
    edge_density_add_edge_density_compl _ (hs₂.mono hs) (ht₂.mono ht),
    edge_density_add_edge_density_compl _ hs₂ ht₂, sub_sub_sub_cancel_left]
  exact edge_density_sub_edge_density_le_one_sub_mul _ hs ht hs₂ ht₂
#align rel.abs_edge_density_sub_edge_density_le_one_sub_mul Rel.abs_edgeDensity_sub_edgeDensity_le_one_sub_mul
-/

#print Rel.abs_edgeDensity_sub_edgeDensity_le_two_mul_sub_sq /-
theorem abs_edgeDensity_sub_edgeDensity_le_two_mul_sub_sq (hs : s₂ ⊆ s₁) (ht : t₂ ⊆ t₁)
    (hδ₀ : 0 ≤ δ) (hδ₁ : δ < 1) (hs₂ : (1 - δ) * s₁.card ≤ s₂.card)
    (ht₂ : (1 - δ) * t₁.card ≤ t₂.card) :
    |(edgeDensity r s₂ t₂ : 𝕜) - edgeDensity r s₁ t₁| ≤ 2 * δ - δ ^ 2 :=
  by
  have hδ' : 0 ≤ 2 * δ - δ ^ 2 := by
    rw [sub_nonneg, sq]
    exact mul_le_mul_of_nonneg_right (hδ₁.le.trans (by norm_num)) hδ₀
  rw [← sub_pos] at hδ₁ 
  obtain rfl | hs₂' := s₂.eq_empty_or_nonempty
  · rw [Finset.card_empty, Nat.cast_zero] at hs₂ 
    simpa [edge_density, (nonpos_of_mul_nonpos_right hs₂ hδ₁).antisymm (Nat.cast_nonneg _)] using
      hδ'
  obtain rfl | ht₂' := t₂.eq_empty_or_nonempty
  · rw [Finset.card_empty, Nat.cast_zero] at ht₂ 
    simpa [edge_density, (nonpos_of_mul_nonpos_right ht₂ hδ₁).antisymm (Nat.cast_nonneg _)] using
      hδ'
  rw [show 2 * δ - δ ^ 2 = 1 - (1 - δ) * (1 - δ) by ring]
  norm_cast
  refine'
    (Rat.cast_le.2 <| abs_edge_density_sub_edge_density_le_one_sub_mul r hs ht hs₂' ht₂').trans _
  push_cast
  have := hs₂'.mono hs
  have := ht₂'.mono ht
  refine' sub_le_sub_left (mul_le_mul ((le_div_iff _).2 hs₂) ((le_div_iff _).2 ht₂) hδ₁.le _) _ <;>
    positivity
#align rel.abs_edge_density_sub_edge_density_le_two_mul_sub_sq Rel.abs_edgeDensity_sub_edgeDensity_le_two_mul_sub_sq
-/

#print Rel.abs_edgeDensity_sub_edgeDensity_le_two_mul /-
/-- If `s₂ ⊆ s₁`, `t₂ ⊆ t₁` and they take up all but a `δ`-proportion, then the difference in edge
densities is at most `2 * δ`. -/
theorem abs_edgeDensity_sub_edgeDensity_le_two_mul (hs : s₂ ⊆ s₁) (ht : t₂ ⊆ t₁) (hδ : 0 ≤ δ)
    (hscard : (1 - δ) * s₁.card ≤ s₂.card) (htcard : (1 - δ) * t₁.card ≤ t₂.card) :
    |(edgeDensity r s₂ t₂ : 𝕜) - edgeDensity r s₁ t₁| ≤ 2 * δ :=
  by
  cases lt_or_le δ 1
  ·
    exact
      (abs_edge_density_sub_edge_density_le_two_mul_sub_sq r hs ht hδ h hscard htcard).trans
        ((sub_le_self_iff _).2 <| sq_nonneg δ)
  rw [two_mul]
  refine' (abs_sub _ _).trans (add_le_add (le_trans _ h) (le_trans _ h)) <;>
    · rw [abs_of_nonneg]
      exact_mod_cast edge_density_le_one r _ _
      exact_mod_cast edge_density_nonneg r _ _
#align rel.abs_edge_density_sub_edge_density_le_two_mul Rel.abs_edgeDensity_sub_edgeDensity_le_two_mul
-/

end Asymmetric

section Symmetric

variable (r : α → α → Prop) [DecidableRel r] {s s₁ s₂ t t₁ t₂ : Finset α} {a b : α}

variable {r} (hr : Symmetric r)

#print Rel.swap_mem_interedges_iff /-
@[simp]
theorem swap_mem_interedges_iff {x : α × α} : x.symm ∈ interedges r s t ↔ x ∈ interedges r t s := by
  rw [mem_interedges_iff, mem_interedges_iff, hr.iff]; exact and_left_comm
#align rel.swap_mem_interedges_iff Rel.swap_mem_interedges_iff
-/

#print Rel.mk_mem_interedges_comm /-
theorem mk_mem_interedges_comm : (a, b) ∈ interedges r s t ↔ (b, a) ∈ interedges r t s :=
  @swap_mem_interedges_iff _ _ _ _ _ hr (b, a)
#align rel.mk_mem_interedges_comm Rel.mk_mem_interedges_comm
-/

#print Rel.card_interedges_comm /-
theorem card_interedges_comm (s t : Finset α) : (interedges r s t).card = (interedges r t s).card :=
  Finset.card_congr (fun (x : α × α) _ => x.symm) (fun x => (swap_mem_interedges_iff hr).2)
    (fun _ _ _ _ h => Prod.swap_injective h) fun x h =>
    ⟨x.symm, (swap_mem_interedges_iff hr).2 h, x.swap_swap⟩
#align rel.card_interedges_comm Rel.card_interedges_comm
-/

#print Rel.edgeDensity_comm /-
theorem edgeDensity_comm (s t : Finset α) : edgeDensity r s t = edgeDensity r t s := by
  rw [edge_density, mul_comm, card_interedges_comm hr, edge_density]
#align rel.edge_density_comm Rel.edgeDensity_comm
-/

end Symmetric

end Rel

open Rel

/-! ### Density of a graph -/


namespace SimpleGraph

variable (G : SimpleGraph α) [DecidableRel G.Adj] {s s₁ s₂ t t₁ t₂ : Finset α} {a b : α}

#print SimpleGraph.interedges /-
/-- Finset of edges of a relation between two finsets of vertices. -/
def interedges (s t : Finset α) : Finset (α × α) :=
  interedges G.Adj s t
#align simple_graph.interedges SimpleGraph.interedges
-/

#print SimpleGraph.edgeDensity /-
/-- Density of edges of a graph between two finsets of vertices. -/
def edgeDensity : Finset α → Finset α → ℚ :=
  edgeDensity G.Adj
#align simple_graph.edge_density SimpleGraph.edgeDensity
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print SimpleGraph.interedges_def /-
theorem interedges_def (s t : Finset α) :
    G.interedges s t = (s ×ˢ t).filterₓ fun e => G.Adj e.1 e.2 :=
  rfl
#align simple_graph.interedges_def SimpleGraph.interedges_def
-/

#print SimpleGraph.edgeDensity_def /-
theorem edgeDensity_def (s t : Finset α) :
    G.edgeDensity s t = (G.interedges s t).card / (s.card * t.card) :=
  rfl
#align simple_graph.edge_density_def SimpleGraph.edgeDensity_def
-/

#print SimpleGraph.card_interedges_div_card /-
@[simp]
theorem card_interedges_div_card (s t : Finset α) :
    ((G.interedges s t).card : ℚ) / (s.card * t.card) = G.edgeDensity s t :=
  rfl
#align simple_graph.card_interedges_div_card SimpleGraph.card_interedges_div_card
-/

#print SimpleGraph.mem_interedges_iff /-
theorem mem_interedges_iff {x : α × α} : x ∈ G.interedges s t ↔ x.1 ∈ s ∧ x.2 ∈ t ∧ G.Adj x.1 x.2 :=
  mem_interedges_iff
#align simple_graph.mem_interedges_iff SimpleGraph.mem_interedges_iff
-/

#print SimpleGraph.mk_mem_interedges_iff /-
theorem mk_mem_interedges_iff : (a, b) ∈ G.interedges s t ↔ a ∈ s ∧ b ∈ t ∧ G.Adj a b :=
  mk_mem_interedges_iff
#align simple_graph.mk_mem_interedges_iff SimpleGraph.mk_mem_interedges_iff
-/

#print SimpleGraph.interedges_empty_left /-
@[simp]
theorem interedges_empty_left (t : Finset α) : G.interedges ∅ t = ∅ :=
  interedges_empty_left _
#align simple_graph.interedges_empty_left SimpleGraph.interedges_empty_left
-/

#print SimpleGraph.interedges_mono /-
theorem interedges_mono : s₂ ⊆ s₁ → t₂ ⊆ t₁ → G.interedges s₂ t₂ ⊆ G.interedges s₁ t₁ :=
  interedges_mono
#align simple_graph.interedges_mono SimpleGraph.interedges_mono
-/

#print SimpleGraph.interedges_disjoint_left /-
theorem interedges_disjoint_left (hs : Disjoint s₁ s₂) (t : Finset α) :
    Disjoint (G.interedges s₁ t) (G.interedges s₂ t) :=
  interedges_disjoint_left _ hs _
#align simple_graph.interedges_disjoint_left SimpleGraph.interedges_disjoint_left
-/

#print SimpleGraph.interedges_disjoint_right /-
theorem interedges_disjoint_right (s : Finset α) (ht : Disjoint t₁ t₂) :
    Disjoint (G.interedges s t₁) (G.interedges s t₂) :=
  interedges_disjoint_right _ _ ht
#align simple_graph.interedges_disjoint_right SimpleGraph.interedges_disjoint_right
-/

section DecidableEq

variable [DecidableEq α]

#print SimpleGraph.interedges_biUnion_left /-
theorem interedges_biUnion_left (s : Finset ι) (t : Finset α) (f : ι → Finset α) :
    G.interedges (s.biUnion f) t = s.biUnion fun a => G.interedges (f a) t :=
  interedges_biUnion_left _ _ _ _
#align simple_graph.interedges_bUnion_left SimpleGraph.interedges_biUnion_left
-/

#print SimpleGraph.interedges_biUnion_right /-
theorem interedges_biUnion_right (s : Finset α) (t : Finset ι) (f : ι → Finset α) :
    G.interedges s (t.biUnion f) = t.biUnion fun b => G.interedges s (f b) :=
  interedges_biUnion_right _ _ _ _
#align simple_graph.interedges_bUnion_right SimpleGraph.interedges_biUnion_right
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print SimpleGraph.interedges_biUnion /-
theorem interedges_biUnion (s : Finset ι) (t : Finset κ) (f : ι → Finset α) (g : κ → Finset α) :
    G.interedges (s.biUnion f) (t.biUnion g) =
      (s ×ˢ t).biUnion fun ab => G.interedges (f ab.1) (g ab.2) :=
  interedges_biUnion _ _ _ _ _
#align simple_graph.interedges_bUnion SimpleGraph.interedges_biUnion
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print SimpleGraph.card_interedges_add_card_interedges_compl /-
theorem card_interedges_add_card_interedges_compl (h : Disjoint s t) :
    (G.interedges s t).card + (Gᶜ.interedges s t).card = s.card * t.card :=
  by
  rw [← card_product, interedges_def, interedges_def]
  have : ((s ×ˢ t).filterₓ fun e => Gᶜ.Adj e.1 e.2) = (s ×ˢ t).filterₓ fun e => ¬G.adj e.1 e.2 :=
    by
    refine' filter_congr fun x hx => _
    rw [mem_product] at hx 
    rw [compl_adj, and_iff_right (h.forall_ne_finset hx.1 hx.2)]
  rw [this, ← card_union_eq, filter_union_filter_neg_eq]
  exact disjoint_filter.2 fun x _ => Classical.not_not.2
#align simple_graph.card_interedges_add_card_interedges_compl SimpleGraph.card_interedges_add_card_interedges_compl
-/

#print SimpleGraph.edgeDensity_add_edgeDensity_compl /-
theorem edgeDensity_add_edgeDensity_compl (hs : s.Nonempty) (ht : t.Nonempty) (h : Disjoint s t) :
    G.edgeDensity s t + Gᶜ.edgeDensity s t = 1 :=
  by
  rw [edge_density_def, edge_density_def, div_add_div_same, div_eq_one_iff_eq]
  · exact_mod_cast card_interedges_add_card_interedges_compl _ h
  · positivity
#align simple_graph.edge_density_add_edge_density_compl SimpleGraph.edgeDensity_add_edgeDensity_compl
-/

end DecidableEq

#print SimpleGraph.card_interedges_le_mul /-
theorem card_interedges_le_mul (s t : Finset α) : (G.interedges s t).card ≤ s.card * t.card :=
  card_interedges_le_mul _ _ _
#align simple_graph.card_interedges_le_mul SimpleGraph.card_interedges_le_mul
-/

#print SimpleGraph.edgeDensity_nonneg /-
theorem edgeDensity_nonneg (s t : Finset α) : 0 ≤ G.edgeDensity s t :=
  edgeDensity_nonneg _ _ _
#align simple_graph.edge_density_nonneg SimpleGraph.edgeDensity_nonneg
-/

#print SimpleGraph.edgeDensity_le_one /-
theorem edgeDensity_le_one (s t : Finset α) : G.edgeDensity s t ≤ 1 :=
  edgeDensity_le_one _ _ _
#align simple_graph.edge_density_le_one SimpleGraph.edgeDensity_le_one
-/

#print SimpleGraph.edgeDensity_empty_left /-
@[simp]
theorem edgeDensity_empty_left (t : Finset α) : G.edgeDensity ∅ t = 0 :=
  edgeDensity_empty_left _ _
#align simple_graph.edge_density_empty_left SimpleGraph.edgeDensity_empty_left
-/

#print SimpleGraph.edgeDensity_empty_right /-
@[simp]
theorem edgeDensity_empty_right (s : Finset α) : G.edgeDensity s ∅ = 0 :=
  edgeDensity_empty_right _ _
#align simple_graph.edge_density_empty_right SimpleGraph.edgeDensity_empty_right
-/

#print SimpleGraph.swap_mem_interedges_iff /-
@[simp]
theorem swap_mem_interedges_iff {x : α × α} : x.symm ∈ G.interedges s t ↔ x ∈ G.interedges t s :=
  swap_mem_interedges_iff G.symm
#align simple_graph.swap_mem_interedges_iff SimpleGraph.swap_mem_interedges_iff
-/

#print SimpleGraph.mk_mem_interedges_comm /-
theorem mk_mem_interedges_comm : (a, b) ∈ G.interedges s t ↔ (b, a) ∈ G.interedges t s :=
  mk_mem_interedges_comm G.symm
#align simple_graph.mk_mem_interedges_comm SimpleGraph.mk_mem_interedges_comm
-/

#print SimpleGraph.edgeDensity_comm /-
theorem edgeDensity_comm (s t : Finset α) : G.edgeDensity s t = G.edgeDensity t s :=
  edgeDensity_comm G.symm s t
#align simple_graph.edge_density_comm SimpleGraph.edgeDensity_comm
-/

end SimpleGraph

namespace Tactic

open Positivity

/-- Extension for the `positivity` tactic: `rel.edge_density` and `simple_graph.edge_density` are
always nonnegative. -/
@[positivity]
unsafe def positivity_edge_density : expr → tactic strictness
  | q(Rel.edgeDensity $(r) $(s) $(t)) =>
    nonnegative <$> mk_mapp `` Rel.edgeDensity_nonneg [none, none, r, none, s, t]
  | q(SimpleGraph.edgeDensity $(G) $(s) $(t)) =>
    nonnegative <$> mk_mapp `` SimpleGraph.edgeDensity_nonneg [none, G, none, s, t]
  | e =>
    pp e >>=
      fail ∘
        format.bracket "The expression `"
          "` isn't of the form `rel.edge_density r s t` nor `simple_graph.edge_density G s t`"
#align tactic.positivity_edge_density tactic.positivity_edge_density

end Tactic

