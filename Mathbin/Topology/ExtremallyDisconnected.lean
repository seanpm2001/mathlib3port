/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module topology.extremally_disconnected
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.StoneCech

/-!
# Extremally disconnected spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

An extremally disconnected topological space is a space in which the closure of every open set is
open. Such spaces are also called Stonean spaces. They are the projective objects in the category of
compact Hausdorff spaces.

## Main declarations

* `extremally_disconnected`: Predicate for a space to be extremally disconnected.
* `compact_t2.projective`: ¨Predicate for a topological space to be a projective object in the
  category of compact Hausdorff spaces.
* `compact_t2.projective.extremally_disconnected`: Compact Hausdorff spaces that are
  projective are extremally disconnected.

# TODO

Prove the converse to `compact_t2.projective.extremally_disconnected`, namely that a compact,
Hausdorff, extremally disconnected space is a projective object in the category of compact Hausdorff
spaces.

## References

[Gleason, *Projective topological spaces*][gleason1958]
-/


noncomputable section

open Set

open scoped Classical

universe u v w

variable (X : Type u) [TopologicalSpace X]

open Function

#print ExtremallyDisconnected /-
/-- An extremally disconnected topological space is a space
in which the closure of every open set is open. -/
class ExtremallyDisconnected : Prop where
  open_closure : ∀ U : Set X, IsOpen U → IsOpen (closure U)
#align extremally_disconnected ExtremallyDisconnected
-/

section

#print CompactT2.Projective /-
/-- The assertion `compact_t2.projective` states that given continuous maps
`f : X → Z` and `g : Y → Z` with `g` surjective between `t_2`, compact topological spaces,
there exists a continuous lift `h : X → Y`, such that `f = g ∘ h`. -/
def CompactT2.Projective : Prop :=
  ∀ {Y Z : Type u} [TopologicalSpace Y] [TopologicalSpace Z],
    ∀ [CompactSpace Y] [T2Space Y] [CompactSpace Z] [T2Space Z],
      ∀ {f : X → Z} {g : Y → Z} (hf : Continuous f) (hg : Continuous g) (g_sur : surjective g),
        ∃ h : X → Y, Continuous h ∧ g ∘ h = f
#align compact_t2.projective CompactT2.Projective
-/

end

variable {X}

#print StoneCech.projective /-
theorem StoneCech.projective [DiscreteTopology X] : CompactT2.Projective (StoneCech X) :=
  by
  intro Y Z _tsY _tsZ _csY _t2Y _csZ _csZ f g hf hg g_sur
  let s : Z → Y := fun z => Classical.choose <| g_sur z
  have hs : g ∘ s = id := funext fun z => Classical.choose_spec (g_sur z)
  let t := s ∘ f ∘ stoneCechUnit
  have ht : Continuous t := continuous_of_discreteTopology
  let h : StoneCech X → Y := stoneCechExtend ht
  have hh : Continuous h := continuous_stoneCechExtend ht
  refine' ⟨h, hh, dense_range_stone_cech_unit.equalizer (hg.comp hh) hf _⟩
  rw [comp.assoc, stoneCechExtend_extends ht, ← comp.assoc, hs, comp.left_id]
#align stone_cech.projective StoneCech.projective
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CompactT2.Projective.extremallyDisconnected /-
protected theorem CompactT2.Projective.extremallyDisconnected [CompactSpace X] [T2Space X]
    (h : CompactT2.Projective X) : ExtremallyDisconnected X :=
  by
  refine' { open_closure := fun U hU => _ }
  let Z₁ : Set (X × Bool) := Uᶜ ×ˢ {tt}
  let Z₂ : Set (X × Bool) := closure U ×ˢ {ff}
  let Z : Set (X × Bool) := Z₁ ∪ Z₂
  have hZ₁₂ : Disjoint Z₁ Z₂ := disjoint_left.2 fun x hx₁ hx₂ => by cases hx₁.2.symm.trans hx₂.2
  have hZ₁ : IsClosed Z₁ := hU.is_closed_compl.prod (T1Space.t1 _)
  have hZ₂ : IsClosed Z₂ := is_closed_closure.prod (T1Space.t1 ff)
  have hZ : IsClosed Z := hZ₁.union hZ₂
  let f : Z → X := Prod.fst ∘ Subtype.val
  have f_cont : Continuous f := continuous_fst.comp continuous_subtype_val
  have f_sur : surjective f := by
    intro x
    by_cases hx : x ∈ U
    · exact ⟨⟨(x, ff), Or.inr ⟨subset_closure hx, Set.mem_singleton _⟩⟩, rfl⟩
    · exact ⟨⟨(x, tt), Or.inl ⟨hx, Set.mem_singleton _⟩⟩, rfl⟩
  haveI : CompactSpace Z := is_compact_iff_compact_space.mp hZ.is_compact
  obtain ⟨g, hg, g_sec⟩ := h continuous_id f_cont f_sur
  let φ := coe ∘ g
  have hφ : Continuous φ := continuous_subtype_val.comp hg
  have hφ₁ : ∀ x, (φ x).1 = x := congr_fun g_sec
  suffices closure U = φ ⁻¹' Z₂
    by
    rw [this, Set.preimage_comp, ← isClosed_compl_iff, ← preimage_compl, ←
      preimage_subtype_coe_eq_compl subset.rfl]
    · exact hZ₁.preimage hφ
    · rw [hZ₁₂.inter_eq, inter_empty]
  refine' (closure_minimal _ <| hZ₂.preimage hφ).antisymm fun x hx => _
  · rintro x hx
    have : φ x ∈ Z₁ ∪ Z₂ := (g x).2
    simpa [hx, hφ₁] using this
  · rw [← hφ₁ x]
    exact hx.1
#align compact_t2.projective.extremally_disconnected CompactT2.Projective.extremallyDisconnected
-/

