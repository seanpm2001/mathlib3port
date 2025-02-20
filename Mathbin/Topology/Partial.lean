/-
Copyright (c) 2018 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module topology.partial
! leanprover-community/mathlib commit 34ee86e6a59d911a8e4f89b68793ee7577ae79c7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.ContinuousOn
import Mathbin.Order.Filter.Partial

/-!
# Partial functions and topological spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove properties of `filter.ptendsto` etc in topological spaces. We also introduce
`pcontinuous`, a version of `continuous` for partially defined functions.
-/


open Filter

open scoped Topology

variable {α β : Type _} [TopologicalSpace α]

#print rtendsto_nhds /-
theorem rtendsto_nhds {r : Rel β α} {l : Filter β} {a : α} :
    RTendsto r l (𝓝 a) ↔ ∀ s, IsOpen s → a ∈ s → r.Core s ∈ l :=
  all_mem_nhds_filter _ _ (fun s t => id) _
#align rtendsto_nhds rtendsto_nhds
-/

#print rtendsto'_nhds /-
theorem rtendsto'_nhds {r : Rel β α} {l : Filter β} {a : α} :
    RTendsto' r l (𝓝 a) ↔ ∀ s, IsOpen s → a ∈ s → r.Preimage s ∈ l := by rw [rtendsto'_def];
  apply all_mem_nhds_filter; apply Rel.preimage_mono
#align rtendsto'_nhds rtendsto'_nhds
-/

#print ptendsto_nhds /-
theorem ptendsto_nhds {f : β →. α} {l : Filter β} {a : α} :
    PTendsto f l (𝓝 a) ↔ ∀ s, IsOpen s → a ∈ s → f.Core s ∈ l :=
  rtendsto_nhds
#align ptendsto_nhds ptendsto_nhds
-/

#print ptendsto'_nhds /-
theorem ptendsto'_nhds {f : β →. α} {l : Filter β} {a : α} :
    PTendsto' f l (𝓝 a) ↔ ∀ s, IsOpen s → a ∈ s → f.Preimage s ∈ l :=
  rtendsto'_nhds
#align ptendsto'_nhds ptendsto'_nhds
-/

/-! ### Continuity and partial functions -/


variable [TopologicalSpace β]

#print PContinuous /-
/-- Continuity of a partial function -/
def PContinuous (f : α →. β) :=
  ∀ s, IsOpen s → IsOpen (f.Preimage s)
#align pcontinuous PContinuous
-/

#print open_dom_of_pcontinuous /-
theorem open_dom_of_pcontinuous {f : α →. β} (h : PContinuous f) : IsOpen f.Dom := by
  rw [← PFun.preimage_univ] <;> exact h _ isOpen_univ
#align open_dom_of_pcontinuous open_dom_of_pcontinuous
-/

#print pcontinuous_iff' /-
theorem pcontinuous_iff' {f : α →. β} :
    PContinuous f ↔ ∀ {x y} (h : y ∈ f x), PTendsto' f (𝓝 x) (𝓝 y) :=
  by
  constructor
  · intro h x y h'
    simp only [ptendsto'_def, mem_nhds_iff]
    rintro s ⟨t, tsubs, opent, yt⟩
    exact ⟨f.preimage t, PFun.preimage_mono _ tsubs, h _ opent, ⟨y, yt, h'⟩⟩
  intro hf s os
  rw [isOpen_iff_nhds]
  rintro x ⟨y, ys, fxy⟩ t
  rw [mem_principal]
  intro (h : f.preimage s ⊆ t)
  change t ∈ 𝓝 x
  apply mem_of_superset _ h
  have h' : ∀ s ∈ 𝓝 y, f.preimage s ∈ 𝓝 x := by
    intro s hs
    have : ptendsto' f (𝓝 x) (𝓝 y) := hf fxy
    rw [ptendsto'_def] at this 
    exact this s hs
  show f.preimage s ∈ 𝓝 x
  apply h'; rw [mem_nhds_iff]; exact ⟨s, Set.Subset.refl _, os, ys⟩
#align pcontinuous_iff' pcontinuous_iff'
-/

#print continuousWithinAt_iff_ptendsto_res /-
theorem continuousWithinAt_iff_ptendsto_res (f : α → β) {x : α} {s : Set α} :
    ContinuousWithinAt f s x ↔ PTendsto (PFun.res f s) (𝓝 x) (𝓝 (f x)) :=
  tendsto_iff_ptendsto _ _ _ _
#align continuous_within_at_iff_ptendsto_res continuousWithinAt_iff_ptendsto_res
-/

