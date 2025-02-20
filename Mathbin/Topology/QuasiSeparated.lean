/-
Copyright (c) 2022 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang

! This file was ported from Lean 3 source module topology.quasi_separated
! leanprover-community/mathlib commit ac34df03f74e6f797efd6991df2e3b7f7d8d33e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.SubsetProperties
import Mathbin.Topology.Separation
import Mathbin.Topology.NoetherianSpace

/-!
# Quasi-separated spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A topological space is quasi-separated if the intersections of any pairs of compact open subsets
are still compact.
Notable examples include spectral spaces, Noetherian spaces, and Hausdorff spaces.

A non-example is the interval `[0, 1]` with doubled origin: the two copies of `[0, 1]` are compact
open subsets, but their intersection `(0, 1]` is not.

## Main results

- `is_quasi_separated`: A subset `s` of a topological space is quasi-separated if the intersections
of any pairs of compact open subsets of `s` are still compact.
- `quasi_separated_space`: A topological space is quasi-separated if the intersections of any pairs
of compact open subsets are still compact.
- `quasi_separated_space.of_open_embedding`: If `f : α → β` is an open embedding, and `β` is
  a quasi-separated space, then so is `α`.
-/


open TopologicalSpace

variable {α β : Type _} [TopologicalSpace α] [TopologicalSpace β] {f : α → β}

#print IsQuasiSeparated /-
/-- A subset `s` of a topological space is quasi-separated if the intersections of any pairs of
compact open subsets of `s` are still compact.

Note that this is equivalent to `s` being a `quasi_separated_space` only when `s` is open. -/
def IsQuasiSeparated (s : Set α) : Prop :=
  ∀ U V : Set α, U ⊆ s → IsOpen U → IsCompact U → V ⊆ s → IsOpen V → IsCompact V → IsCompact (U ∩ V)
#align is_quasi_separated IsQuasiSeparated
-/

#print QuasiSeparatedSpace /-
/-- A topological space is quasi-separated if the intersections of any pairs of compact open
subsets are still compact. -/
@[mk_iff]
class QuasiSeparatedSpace (α : Type _) [TopologicalSpace α] : Prop where
  inter_isCompact :
    ∀ U V : Set α, IsOpen U → IsCompact U → IsOpen V → IsCompact V → IsCompact (U ∩ V)
#align quasi_separated_space QuasiSeparatedSpace
-/

#print isQuasiSeparated_univ_iff /-
theorem isQuasiSeparated_univ_iff {α : Type _} [TopologicalSpace α] :
    IsQuasiSeparated (Set.univ : Set α) ↔ QuasiSeparatedSpace α :=
  by
  rw [quasiSeparatedSpace_iff]
  simp [IsQuasiSeparated]
#align is_quasi_separated_univ_iff isQuasiSeparated_univ_iff
-/

#print isQuasiSeparated_univ /-
theorem isQuasiSeparated_univ {α : Type _} [TopologicalSpace α] [QuasiSeparatedSpace α] :
    IsQuasiSeparated (Set.univ : Set α) :=
  isQuasiSeparated_univ_iff.mpr inferInstance
#align is_quasi_separated_univ isQuasiSeparated_univ
-/

#print IsQuasiSeparated.image_of_embedding /-
theorem IsQuasiSeparated.image_of_embedding {s : Set α} (H : IsQuasiSeparated s) (h : Embedding f) :
    IsQuasiSeparated (f '' s) := by
  intro U V hU hU' hU'' hV hV' hV''
  convert
    (H (f ⁻¹' U) (f ⁻¹' V) _ (h.continuous.1 _ hU') _ _ (h.continuous.1 _ hV') _).image h.continuous
  · symm
    rw [← Set.preimage_inter, Set.image_preimage_eq_inter_range, Set.inter_eq_left_iff_subset]
    exact (Set.inter_subset_left _ _).trans (hU.trans (Set.image_subset_range _ _))
  · intro x hx; rw [← (h.inj.inj_on _).mem_image_iff (Set.subset_univ _) trivial]; exact hU hx
  · rw [h.is_compact_iff_is_compact_image]
    convert hU''
    rw [Set.image_preimage_eq_inter_range, Set.inter_eq_left_iff_subset]
    exact hU.trans (Set.image_subset_range _ _)
  · intro x hx; rw [← (h.inj.inj_on _).mem_image_iff (Set.subset_univ _) trivial]; exact hV hx
  · rw [h.is_compact_iff_is_compact_image]
    convert hV''
    rw [Set.image_preimage_eq_inter_range, Set.inter_eq_left_iff_subset]
    exact hV.trans (Set.image_subset_range _ _)
#align is_quasi_separated.image_of_embedding IsQuasiSeparated.image_of_embedding
-/

#print OpenEmbedding.isQuasiSeparated_iff /-
theorem OpenEmbedding.isQuasiSeparated_iff (h : OpenEmbedding f) {s : Set α} :
    IsQuasiSeparated s ↔ IsQuasiSeparated (f '' s) :=
  by
  refine' ⟨fun hs => hs.image_of_embedding h.to_embedding, _⟩
  intro H U V hU hU' hU'' hV hV' hV''
  rw [h.to_embedding.is_compact_iff_is_compact_image, Set.image_inter h.inj]
  exact
    H (f '' U) (f '' V) (Set.image_subset _ hU) (h.is_open_map _ hU') (hU''.image h.continuous)
      (Set.image_subset _ hV) (h.is_open_map _ hV') (hV''.image h.continuous)
#align open_embedding.is_quasi_separated_iff OpenEmbedding.isQuasiSeparated_iff
-/

#print isQuasiSeparated_iff_quasiSeparatedSpace /-
theorem isQuasiSeparated_iff_quasiSeparatedSpace (s : Set α) (hs : IsOpen s) :
    IsQuasiSeparated s ↔ QuasiSeparatedSpace s :=
  by
  rw [← isQuasiSeparated_univ_iff]
  convert hs.open_embedding_subtype_coe.is_quasi_separated_iff.symm <;> simp
#align is_quasi_separated_iff_quasi_separated_space isQuasiSeparated_iff_quasiSeparatedSpace
-/

#print IsQuasiSeparated.of_subset /-
theorem IsQuasiSeparated.of_subset {s t : Set α} (ht : IsQuasiSeparated t) (h : s ⊆ t) :
    IsQuasiSeparated s := by
  intro U V hU hU' hU'' hV hV' hV''
  exact ht U V (hU.trans h) hU' hU'' (hV.trans h) hV' hV''
#align is_quasi_separated.of_subset IsQuasiSeparated.of_subset
-/

#print T2Space.to_quasiSeparatedSpace /-
instance (priority := 100) T2Space.to_quasiSeparatedSpace [T2Space α] : QuasiSeparatedSpace α :=
  ⟨fun U V hU hU' hV hV' => hU'.inter hV'⟩
#align t2_space.to_quasi_separated_space T2Space.to_quasiSeparatedSpace
-/

#print NoetherianSpace.to_quasiSeparatedSpace /-
instance (priority := 100) NoetherianSpace.to_quasiSeparatedSpace [NoetherianSpace α] :
    QuasiSeparatedSpace α :=
  ⟨fun _ _ _ _ _ _ => NoetherianSpace.isCompact _⟩
#align noetherian_space.to_quasi_separated_space NoetherianSpace.to_quasiSeparatedSpace
-/

#print IsQuasiSeparated.of_quasiSeparatedSpace /-
theorem IsQuasiSeparated.of_quasiSeparatedSpace (s : Set α) [QuasiSeparatedSpace α] :
    IsQuasiSeparated s :=
  isQuasiSeparated_univ.of_subset (Set.subset_univ _)
#align is_quasi_separated.of_quasi_separated_space IsQuasiSeparated.of_quasiSeparatedSpace
-/

#print QuasiSeparatedSpace.of_openEmbedding /-
theorem QuasiSeparatedSpace.of_openEmbedding (h : OpenEmbedding f) [QuasiSeparatedSpace β] :
    QuasiSeparatedSpace α :=
  isQuasiSeparated_univ_iff.mp
    (h.isQuasiSeparated_iff.mpr <| IsQuasiSeparated.of_quasiSeparatedSpace _)
#align quasi_separated_space.of_open_embedding QuasiSeparatedSpace.of_openEmbedding
-/

