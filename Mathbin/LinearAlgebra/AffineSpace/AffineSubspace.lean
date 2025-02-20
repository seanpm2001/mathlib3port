/-
Copyright (c) 2020 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers

! This file was ported from Lean 3 source module linear_algebra.affine_space.affine_subspace
! leanprover-community/mathlib commit cb3ceec8485239a61ed51d944cb9a95b68c6bafc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.AffineSpace.AffineEquiv

/-!
# Affine spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines affine subspaces (over modules) and the affine span of a set of points.

## Main definitions

* `affine_subspace k P` is the type of affine subspaces.  Unlike
  affine spaces, affine subspaces are allowed to be empty, and lemmas
  that do not apply to empty affine subspaces have `nonempty`
  hypotheses.  There is a `complete_lattice` structure on affine
  subspaces.
* `affine_subspace.direction` gives the `submodule` spanned by the
  pairwise differences of points in an `affine_subspace`.  There are
  various lemmas relating to the set of vectors in the `direction`,
  and relating the lattice structure on affine subspaces to that on
  their directions.
* `affine_subspace.parallel`, notation `∥`, gives the property of two affine subspaces being
  parallel (one being a translate of the other).
* `affine_span` gives the affine subspace spanned by a set of points,
  with `vector_span` giving its direction.  `affine_span` is defined
  in terms of `span_points`, which gives an explicit description of
  the points contained in the affine span; `span_points` itself should
  generally only be used when that description is required, with
  `affine_span` being the main definition for other purposes.  Two
  other descriptions of the affine span are proved equivalent: it is
  the `Inf` of affine subspaces containing the points, and (if
  `[nontrivial k]`) it contains exactly those points that are affine
  combinations of points in the given set.

## Implementation notes

`out_param` is used in the definiton of `add_torsor V P` to make `V` an implicit argument (deduced
from `P`) in most cases; `include V` is needed in many cases for `V`, and type classes using it, to
be added as implicit arguments to individual lemmas.  As for modules, `k` is an explicit argument
rather than implied by `P` or `V`.

This file only provides purely algebraic definitions and results.
Those depending on analysis or topology are defined elsewhere; see
`analysis.normed_space.add_torsor` and `topology.algebra.affine`.

## References

* https://en.wikipedia.org/wiki/Affine_space
* https://en.wikipedia.org/wiki/Principal_homogeneous_space
-/


noncomputable section

open scoped BigOperators Affine

open Set

section

variable (k : Type _) {V : Type _} {P : Type _} [Ring k] [AddCommGroup V] [Module k V]

variable [affine_space V P]

#print vectorSpan /-
/-- The submodule spanning the differences of a (possibly empty) set
of points. -/
def vectorSpan (s : Set P) : Submodule k V :=
  Submodule.span k (s -ᵥ s)
#align vector_span vectorSpan
-/

#print vectorSpan_def /-
/-- The definition of `vector_span`, for rewriting. -/
theorem vectorSpan_def (s : Set P) : vectorSpan k s = Submodule.span k (s -ᵥ s) :=
  rfl
#align vector_span_def vectorSpan_def
-/

#print vectorSpan_mono /-
/-- `vector_span` is monotone. -/
theorem vectorSpan_mono {s₁ s₂ : Set P} (h : s₁ ⊆ s₂) : vectorSpan k s₁ ≤ vectorSpan k s₂ :=
  Submodule.span_mono (vsub_self_mono h)
#align vector_span_mono vectorSpan_mono
-/

variable (P)

#print vectorSpan_empty /-
/-- The `vector_span` of the empty set is `⊥`. -/
@[simp]
theorem vectorSpan_empty : vectorSpan k (∅ : Set P) = (⊥ : Submodule k V) := by
  rw [vectorSpan_def, vsub_empty, Submodule.span_empty]
#align vector_span_empty vectorSpan_empty
-/

variable {P}

#print vectorSpan_singleton /-
/-- The `vector_span` of a single point is `⊥`. -/
@[simp]
theorem vectorSpan_singleton (p : P) : vectorSpan k ({p} : Set P) = ⊥ := by simp [vectorSpan_def]
#align vector_span_singleton vectorSpan_singleton
-/

#print vsub_set_subset_vectorSpan /-
/-- The `s -ᵥ s` lies within the `vector_span k s`. -/
theorem vsub_set_subset_vectorSpan (s : Set P) : s -ᵥ s ⊆ ↑(vectorSpan k s) :=
  Submodule.subset_span
#align vsub_set_subset_vector_span vsub_set_subset_vectorSpan
-/

#print vsub_mem_vectorSpan /-
/-- Each pairwise difference is in the `vector_span`. -/
theorem vsub_mem_vectorSpan {s : Set P} {p1 p2 : P} (hp1 : p1 ∈ s) (hp2 : p2 ∈ s) :
    p1 -ᵥ p2 ∈ vectorSpan k s :=
  vsub_set_subset_vectorSpan k s (vsub_mem_vsub hp1 hp2)
#align vsub_mem_vector_span vsub_mem_vectorSpan
-/

#print spanPoints /-
/-- The points in the affine span of a (possibly empty) set of
points. Use `affine_span` instead to get an `affine_subspace k P`. -/
def spanPoints (s : Set P) : Set P :=
  {p | ∃ p1 ∈ s, ∃ v ∈ vectorSpan k s, p = v +ᵥ p1}
#align span_points spanPoints
-/

#print mem_spanPoints /-
/-- A point in a set is in its affine span. -/
theorem mem_spanPoints (p : P) (s : Set P) : p ∈ s → p ∈ spanPoints k s
  | hp => ⟨p, hp, 0, Submodule.zero_mem _, (zero_vadd V p).symm⟩
#align mem_span_points mem_spanPoints
-/

#print subset_spanPoints /-
/-- A set is contained in its `span_points`. -/
theorem subset_spanPoints (s : Set P) : s ⊆ spanPoints k s := fun p => mem_spanPoints k p s
#align subset_span_points subset_spanPoints
-/

#print spanPoints_nonempty /-
/-- The `span_points` of a set is nonempty if and only if that set
is. -/
@[simp]
theorem spanPoints_nonempty (s : Set P) : (spanPoints k s).Nonempty ↔ s.Nonempty :=
  by
  constructor
  · contrapose
    rw [Set.not_nonempty_iff_eq_empty, Set.not_nonempty_iff_eq_empty]
    intro h
    simp [h, spanPoints]
  · exact fun h => h.mono (subset_spanPoints _ _)
#align span_points_nonempty spanPoints_nonempty
-/

#print vadd_mem_spanPoints_of_mem_spanPoints_of_mem_vectorSpan /-
/-- Adding a point in the affine span and a vector in the spanning
submodule produces a point in the affine span. -/
theorem vadd_mem_spanPoints_of_mem_spanPoints_of_mem_vectorSpan {s : Set P} {p : P} {v : V}
    (hp : p ∈ spanPoints k s) (hv : v ∈ vectorSpan k s) : v +ᵥ p ∈ spanPoints k s :=
  by
  rcases hp with ⟨p2, ⟨hp2, ⟨v2, ⟨hv2, hv2p⟩⟩⟩⟩
  rw [hv2p, vadd_vadd]
  use p2, hp2, v + v2, (vectorSpan k s).add_mem hv hv2, rfl
#align vadd_mem_span_points_of_mem_span_points_of_mem_vector_span vadd_mem_spanPoints_of_mem_spanPoints_of_mem_vectorSpan
-/

#print vsub_mem_vectorSpan_of_mem_spanPoints_of_mem_spanPoints /-
/-- Subtracting two points in the affine span produces a vector in the
spanning submodule. -/
theorem vsub_mem_vectorSpan_of_mem_spanPoints_of_mem_spanPoints {s : Set P} {p1 p2 : P}
    (hp1 : p1 ∈ spanPoints k s) (hp2 : p2 ∈ spanPoints k s) : p1 -ᵥ p2 ∈ vectorSpan k s :=
  by
  rcases hp1 with ⟨p1a, ⟨hp1a, ⟨v1, ⟨hv1, hv1p⟩⟩⟩⟩
  rcases hp2 with ⟨p2a, ⟨hp2a, ⟨v2, ⟨hv2, hv2p⟩⟩⟩⟩
  rw [hv1p, hv2p, vsub_vadd_eq_vsub_sub (v1 +ᵥ p1a), vadd_vsub_assoc, add_comm, add_sub_assoc]
  have hv1v2 : v1 - v2 ∈ vectorSpan k s :=
    by
    rw [sub_eq_add_neg]
    apply (vectorSpan k s).add_mem hv1
    rw [← neg_one_smul k v2]
    exact (vectorSpan k s).smul_mem (-1 : k) hv2
  refine' (vectorSpan k s).add_mem _ hv1v2
  exact vsub_mem_vectorSpan k hp1a hp2a
#align vsub_mem_vector_span_of_mem_span_points_of_mem_span_points vsub_mem_vectorSpan_of_mem_spanPoints_of_mem_spanPoints
-/

end

#print AffineSubspace /-
/-- An `affine_subspace k P` is a subset of an `affine_space V P`
that, if not empty, has an affine space structure induced by a
corresponding subspace of the `module k V`. -/
structure AffineSubspace (k : Type _) {V : Type _} (P : Type _) [Ring k] [AddCommGroup V]
    [Module k V] [affine_space V P] where
  carrier : Set P
  smul_vsub_vadd_mem :
    ∀ (c : k) {p1 p2 p3 : P},
      p1 ∈ carrier → p2 ∈ carrier → p3 ∈ carrier → c • (p1 -ᵥ p2 : V) +ᵥ p3 ∈ carrier
#align affine_subspace AffineSubspace
-/

namespace Submodule

variable {k V : Type _} [Ring k] [AddCommGroup V] [Module k V]

#print Submodule.toAffineSubspace /-
/-- Reinterpret `p : submodule k V` as an `affine_subspace k V`. -/
def toAffineSubspace (p : Submodule k V) : AffineSubspace k V
    where
  carrier := p
  smul_vsub_vadd_mem c p₁ p₂ p₃ h₁ h₂ h₃ := p.add_mem (p.smul_mem _ (p.sub_mem h₁ h₂)) h₃
#align submodule.to_affine_subspace Submodule.toAffineSubspace
-/

end Submodule

namespace AffineSubspace

variable (k : Type _) {V : Type _} (P : Type _) [Ring k] [AddCommGroup V] [Module k V]
  [affine_space V P]

instance : SetLike (AffineSubspace k P) P
    where
  coe := carrier
  coe_injective' p q _ := by cases p <;> cases q <;> congr

#print AffineSubspace.mem_coe /-
/-- A point is in an affine subspace coerced to a set if and only if
it is in that affine subspace. -/
@[simp]
theorem mem_coe (p : P) (s : AffineSubspace k P) : p ∈ (s : Set P) ↔ p ∈ s :=
  Iff.rfl
#align affine_subspace.mem_coe AffineSubspace.mem_coe
-/

variable {k P}

#print AffineSubspace.direction /-
/-- The direction of an affine subspace is the submodule spanned by
the pairwise differences of points.  (Except in the case of an empty
affine subspace, where the direction is the zero submodule, every
vector in the direction is the difference of two points in the affine
subspace.) -/
def direction (s : AffineSubspace k P) : Submodule k V :=
  vectorSpan k (s : Set P)
#align affine_subspace.direction AffineSubspace.direction
-/

#print AffineSubspace.direction_eq_vectorSpan /-
/-- The direction equals the `vector_span`. -/
theorem direction_eq_vectorSpan (s : AffineSubspace k P) : s.direction = vectorSpan k (s : Set P) :=
  rfl
#align affine_subspace.direction_eq_vector_span AffineSubspace.direction_eq_vectorSpan
-/

#print AffineSubspace.directionOfNonempty /-
/-- Alternative definition of the direction when the affine subspace
is nonempty.  This is defined so that the order on submodules (as used
in the definition of `submodule.span`) can be used in the proof of
`coe_direction_eq_vsub_set`, and is not intended to be used beyond
that proof. -/
def directionOfNonempty {s : AffineSubspace k P} (h : (s : Set P).Nonempty) : Submodule k V
    where
  carrier := (s : Set P) -ᵥ s
  zero_mem' := by
    cases' h with p hp
    exact vsub_self p ▸ vsub_mem_vsub hp hp
  add_mem' := by
    intro a b ha hb
    rcases ha with ⟨p1, p2, hp1, hp2, rfl⟩
    rcases hb with ⟨p3, p4, hp3, hp4, rfl⟩
    rw [← vadd_vsub_assoc]
    refine' vsub_mem_vsub _ hp4
    convert s.smul_vsub_vadd_mem 1 hp1 hp2 hp3
    rw [one_smul]
  smul_mem' := by
    intro c v hv
    rcases hv with ⟨p1, p2, hp1, hp2, rfl⟩
    rw [← vadd_vsub (c • (p1 -ᵥ p2)) p2]
    refine' vsub_mem_vsub _ hp2
    exact s.smul_vsub_vadd_mem c hp1 hp2 hp2
#align affine_subspace.direction_of_nonempty AffineSubspace.directionOfNonempty
-/

#print AffineSubspace.directionOfNonempty_eq_direction /-
/-- `direction_of_nonempty` gives the same submodule as
`direction`. -/
theorem directionOfNonempty_eq_direction {s : AffineSubspace k P} (h : (s : Set P).Nonempty) :
    directionOfNonempty h = s.direction :=
  le_antisymm (vsub_set_subset_vectorSpan k s) (Submodule.span_le.2 Set.Subset.rfl)
#align affine_subspace.direction_of_nonempty_eq_direction AffineSubspace.directionOfNonempty_eq_direction
-/

#print AffineSubspace.coe_direction_eq_vsub_set /-
/-- The set of vectors in the direction of a nonempty affine subspace
is given by `vsub_set`. -/
theorem coe_direction_eq_vsub_set {s : AffineSubspace k P} (h : (s : Set P).Nonempty) :
    (s.direction : Set V) = (s : Set P) -ᵥ s :=
  directionOfNonempty_eq_direction h ▸ rfl
#align affine_subspace.coe_direction_eq_vsub_set AffineSubspace.coe_direction_eq_vsub_set
-/

#print AffineSubspace.mem_direction_iff_eq_vsub /-
/-- A vector is in the direction of a nonempty affine subspace if and
only if it is the subtraction of two vectors in the subspace. -/
theorem mem_direction_iff_eq_vsub {s : AffineSubspace k P} (h : (s : Set P).Nonempty) (v : V) :
    v ∈ s.direction ↔ ∃ p1 ∈ s, ∃ p2 ∈ s, v = p1 -ᵥ p2 :=
  by
  rw [← SetLike.mem_coe, coe_direction_eq_vsub_set h]
  exact
    ⟨fun ⟨p1, p2, hp1, hp2, hv⟩ => ⟨p1, hp1, p2, hp2, hv.symm⟩, fun ⟨p1, hp1, p2, hp2, hv⟩ =>
      ⟨p1, p2, hp1, hp2, hv.symm⟩⟩
#align affine_subspace.mem_direction_iff_eq_vsub AffineSubspace.mem_direction_iff_eq_vsub
-/

#print AffineSubspace.vadd_mem_of_mem_direction /-
/-- Adding a vector in the direction to a point in the subspace
produces a point in the subspace. -/
theorem vadd_mem_of_mem_direction {s : AffineSubspace k P} {v : V} (hv : v ∈ s.direction) {p : P}
    (hp : p ∈ s) : v +ᵥ p ∈ s :=
  by
  rw [mem_direction_iff_eq_vsub ⟨p, hp⟩] at hv 
  rcases hv with ⟨p1, hp1, p2, hp2, hv⟩
  rw [hv]
  convert s.smul_vsub_vadd_mem 1 hp1 hp2 hp
  rw [one_smul]
#align affine_subspace.vadd_mem_of_mem_direction AffineSubspace.vadd_mem_of_mem_direction
-/

#print AffineSubspace.vsub_mem_direction /-
/-- Subtracting two points in the subspace produces a vector in the
direction. -/
theorem vsub_mem_direction {s : AffineSubspace k P} {p1 p2 : P} (hp1 : p1 ∈ s) (hp2 : p2 ∈ s) :
    p1 -ᵥ p2 ∈ s.direction :=
  vsub_mem_vectorSpan k hp1 hp2
#align affine_subspace.vsub_mem_direction AffineSubspace.vsub_mem_direction
-/

#print AffineSubspace.vadd_mem_iff_mem_direction /-
/-- Adding a vector to a point in a subspace produces a point in the
subspace if and only if the vector is in the direction. -/
theorem vadd_mem_iff_mem_direction {s : AffineSubspace k P} (v : V) {p : P} (hp : p ∈ s) :
    v +ᵥ p ∈ s ↔ v ∈ s.direction :=
  ⟨fun h => by simpa using vsub_mem_direction h hp, fun h => vadd_mem_of_mem_direction h hp⟩
#align affine_subspace.vadd_mem_iff_mem_direction AffineSubspace.vadd_mem_iff_mem_direction
-/

#print AffineSubspace.vadd_mem_iff_mem_of_mem_direction /-
/-- Adding a vector in the direction to a point produces a point in the subspace if and only if
the original point is in the subspace. -/
theorem vadd_mem_iff_mem_of_mem_direction {s : AffineSubspace k P} {v : V} (hv : v ∈ s.direction)
    {p : P} : v +ᵥ p ∈ s ↔ p ∈ s :=
  by
  refine' ⟨fun h => _, fun h => vadd_mem_of_mem_direction hv h⟩
  convert vadd_mem_of_mem_direction (Submodule.neg_mem _ hv) h
  simp
#align affine_subspace.vadd_mem_iff_mem_of_mem_direction AffineSubspace.vadd_mem_iff_mem_of_mem_direction
-/

#print AffineSubspace.coe_direction_eq_vsub_set_right /-
/-- Given a point in an affine subspace, the set of vectors in its
direction equals the set of vectors subtracting that point on the
right. -/
theorem coe_direction_eq_vsub_set_right {s : AffineSubspace k P} {p : P} (hp : p ∈ s) :
    (s.direction : Set V) = (· -ᵥ p) '' s :=
  by
  rw [coe_direction_eq_vsub_set ⟨p, hp⟩]
  refine' le_antisymm _ _
  · rintro v ⟨p1, p2, hp1, hp2, rfl⟩
    exact ⟨p1 -ᵥ p2 +ᵥ p, vadd_mem_of_mem_direction (vsub_mem_direction hp1 hp2) hp, vadd_vsub _ _⟩
  · rintro v ⟨p2, hp2, rfl⟩
    exact ⟨p2, p, hp2, hp, rfl⟩
#align affine_subspace.coe_direction_eq_vsub_set_right AffineSubspace.coe_direction_eq_vsub_set_right
-/

#print AffineSubspace.coe_direction_eq_vsub_set_left /-
/-- Given a point in an affine subspace, the set of vectors in its
direction equals the set of vectors subtracting that point on the
left. -/
theorem coe_direction_eq_vsub_set_left {s : AffineSubspace k P} {p : P} (hp : p ∈ s) :
    (s.direction : Set V) = (· -ᵥ ·) p '' s := by
  ext v
  rw [SetLike.mem_coe, ← Submodule.neg_mem_iff, ← SetLike.mem_coe,
    coe_direction_eq_vsub_set_right hp, Set.mem_image_iff_bex, Set.mem_image_iff_bex]
  conv_lhs =>
    congr
    ext
    rw [← neg_vsub_eq_vsub_rev, neg_inj]
#align affine_subspace.coe_direction_eq_vsub_set_left AffineSubspace.coe_direction_eq_vsub_set_left
-/

#print AffineSubspace.mem_direction_iff_eq_vsub_right /-
/-- Given a point in an affine subspace, a vector is in its direction
if and only if it results from subtracting that point on the right. -/
theorem mem_direction_iff_eq_vsub_right {s : AffineSubspace k P} {p : P} (hp : p ∈ s) (v : V) :
    v ∈ s.direction ↔ ∃ p2 ∈ s, v = p2 -ᵥ p :=
  by
  rw [← SetLike.mem_coe, coe_direction_eq_vsub_set_right hp]
  exact ⟨fun ⟨p2, hp2, hv⟩ => ⟨p2, hp2, hv.symm⟩, fun ⟨p2, hp2, hv⟩ => ⟨p2, hp2, hv.symm⟩⟩
#align affine_subspace.mem_direction_iff_eq_vsub_right AffineSubspace.mem_direction_iff_eq_vsub_right
-/

#print AffineSubspace.mem_direction_iff_eq_vsub_left /-
/-- Given a point in an affine subspace, a vector is in its direction
if and only if it results from subtracting that point on the left. -/
theorem mem_direction_iff_eq_vsub_left {s : AffineSubspace k P} {p : P} (hp : p ∈ s) (v : V) :
    v ∈ s.direction ↔ ∃ p2 ∈ s, v = p -ᵥ p2 :=
  by
  rw [← SetLike.mem_coe, coe_direction_eq_vsub_set_left hp]
  exact ⟨fun ⟨p2, hp2, hv⟩ => ⟨p2, hp2, hv.symm⟩, fun ⟨p2, hp2, hv⟩ => ⟨p2, hp2, hv.symm⟩⟩
#align affine_subspace.mem_direction_iff_eq_vsub_left AffineSubspace.mem_direction_iff_eq_vsub_left
-/

#print AffineSubspace.vsub_right_mem_direction_iff_mem /-
/-- Given a point in an affine subspace, a result of subtracting that
point on the right is in the direction if and only if the other point
is in the subspace. -/
theorem vsub_right_mem_direction_iff_mem {s : AffineSubspace k P} {p : P} (hp : p ∈ s) (p2 : P) :
    p2 -ᵥ p ∈ s.direction ↔ p2 ∈ s :=
  by
  rw [mem_direction_iff_eq_vsub_right hp]
  simp
#align affine_subspace.vsub_right_mem_direction_iff_mem AffineSubspace.vsub_right_mem_direction_iff_mem
-/

#print AffineSubspace.vsub_left_mem_direction_iff_mem /-
/-- Given a point in an affine subspace, a result of subtracting that
point on the left is in the direction if and only if the other point
is in the subspace. -/
theorem vsub_left_mem_direction_iff_mem {s : AffineSubspace k P} {p : P} (hp : p ∈ s) (p2 : P) :
    p -ᵥ p2 ∈ s.direction ↔ p2 ∈ s :=
  by
  rw [mem_direction_iff_eq_vsub_left hp]
  simp
#align affine_subspace.vsub_left_mem_direction_iff_mem AffineSubspace.vsub_left_mem_direction_iff_mem
-/

#print AffineSubspace.coe_injective /-
/-- Two affine subspaces are equal if they have the same points. -/
theorem coe_injective : Function.Injective (coe : AffineSubspace k P → Set P) :=
  SetLike.coe_injective
#align affine_subspace.coe_injective AffineSubspace.coe_injective
-/

#print AffineSubspace.ext /-
@[ext]
theorem ext {p q : AffineSubspace k P} (h : ∀ x, x ∈ p ↔ x ∈ q) : p = q :=
  SetLike.ext h
#align affine_subspace.ext AffineSubspace.ext
-/

#print AffineSubspace.ext_iff /-
@[simp]
theorem ext_iff (s₁ s₂ : AffineSubspace k P) : (s₁ : Set P) = s₂ ↔ s₁ = s₂ :=
  SetLike.ext'_iff.symm
#align affine_subspace.ext_iff AffineSubspace.ext_iff
-/

#print AffineSubspace.ext_of_direction_eq /-
/-- Two affine subspaces with the same direction and nonempty
intersection are equal. -/
theorem ext_of_direction_eq {s1 s2 : AffineSubspace k P} (hd : s1.direction = s2.direction)
    (hn : ((s1 : Set P) ∩ s2).Nonempty) : s1 = s2 :=
  by
  ext p
  have hq1 := Set.mem_of_mem_inter_left hn.some_mem
  have hq2 := Set.mem_of_mem_inter_right hn.some_mem
  constructor
  · intro hp
    rw [← vsub_vadd p hn.some]
    refine' vadd_mem_of_mem_direction _ hq2
    rw [← hd]
    exact vsub_mem_direction hp hq1
  · intro hp
    rw [← vsub_vadd p hn.some]
    refine' vadd_mem_of_mem_direction _ hq1
    rw [hd]
    exact vsub_mem_direction hp hq2
#align affine_subspace.ext_of_direction_eq AffineSubspace.ext_of_direction_eq
-/

#print AffineSubspace.toAddTorsor /-
-- See note [reducible non instances]
/-- This is not an instance because it loops with `add_torsor.nonempty`. -/
@[reducible]
def toAddTorsor (s : AffineSubspace k P) [Nonempty s] : AddTorsor s.direction s
    where
  vadd a b := ⟨(a : V) +ᵥ (b : P), vadd_mem_of_mem_direction a.2 b.2⟩
  zero_vadd := by simp
  add_vadd a b c := by ext; apply add_vadd
  vsub a b := ⟨(a : P) -ᵥ (b : P), (vsub_left_mem_direction_iff_mem a.2 _).mpr b.2⟩
  Nonempty := by infer_instance
  vsub_vadd' a b := by ext; apply AddTorsor.vsub_vadd'
  vadd_vsub' a b := by ext; apply AddTorsor.vadd_vsub'
#align affine_subspace.to_add_torsor AffineSubspace.toAddTorsor
-/

attribute [local instance] to_add_torsor

#print AffineSubspace.coe_vsub /-
@[simp, norm_cast]
theorem coe_vsub (s : AffineSubspace k P) [Nonempty s] (a b : s) : ↑(a -ᵥ b) = (a : P) -ᵥ (b : P) :=
  rfl
#align affine_subspace.coe_vsub AffineSubspace.coe_vsub
-/

#print AffineSubspace.coe_vadd /-
@[simp, norm_cast]
theorem coe_vadd (s : AffineSubspace k P) [Nonempty s] (a : s.direction) (b : s) :
    ↑(a +ᵥ b) = (a : V) +ᵥ (b : P) :=
  rfl
#align affine_subspace.coe_vadd AffineSubspace.coe_vadd
-/

#print AffineSubspace.subtype /-
/-- Embedding of an affine subspace to the ambient space, as an affine map. -/
protected def subtype (s : AffineSubspace k P) [Nonempty s] : s →ᵃ[k] P
    where
  toFun := coe
  linear := s.direction.Subtype
  map_vadd' p v := rfl
#align affine_subspace.subtype AffineSubspace.subtype
-/

#print AffineSubspace.subtype_linear /-
@[simp]
theorem subtype_linear (s : AffineSubspace k P) [Nonempty s] :
    s.Subtype.linear = s.direction.Subtype :=
  rfl
#align affine_subspace.subtype_linear AffineSubspace.subtype_linear
-/

#print AffineSubspace.subtype_apply /-
theorem subtype_apply (s : AffineSubspace k P) [Nonempty s] (p : s) : s.Subtype p = p :=
  rfl
#align affine_subspace.subtype_apply AffineSubspace.subtype_apply
-/

#print AffineSubspace.coeSubtype /-
@[simp]
theorem coeSubtype (s : AffineSubspace k P) [Nonempty s] : (s.Subtype : s → P) = coe :=
  rfl
#align affine_subspace.coe_subtype AffineSubspace.coeSubtype
-/

#print AffineSubspace.injective_subtype /-
theorem injective_subtype (s : AffineSubspace k P) [Nonempty s] : Function.Injective s.Subtype :=
  Subtype.coe_injective
#align affine_subspace.injective_subtype AffineSubspace.injective_subtype
-/

#print AffineSubspace.eq_iff_direction_eq_of_mem /-
/-- Two affine subspaces with nonempty intersection are equal if and
only if their directions are equal. -/
theorem eq_iff_direction_eq_of_mem {s₁ s₂ : AffineSubspace k P} {p : P} (h₁ : p ∈ s₁)
    (h₂ : p ∈ s₂) : s₁ = s₂ ↔ s₁.direction = s₂.direction :=
  ⟨fun h => h ▸ rfl, fun h => ext_of_direction_eq h ⟨p, h₁, h₂⟩⟩
#align affine_subspace.eq_iff_direction_eq_of_mem AffineSubspace.eq_iff_direction_eq_of_mem
-/

#print AffineSubspace.mk' /-
/-- Construct an affine subspace from a point and a direction. -/
def mk' (p : P) (direction : Submodule k V) : AffineSubspace k P
    where
  carrier := {q | ∃ v ∈ direction, q = v +ᵥ p}
  smul_vsub_vadd_mem c p1 p2 p3 hp1 hp2 hp3 :=
    by
    rcases hp1 with ⟨v1, hv1, hp1⟩
    rcases hp2 with ⟨v2, hv2, hp2⟩
    rcases hp3 with ⟨v3, hv3, hp3⟩
    use c • (v1 - v2) + v3, direction.add_mem (direction.smul_mem c (direction.sub_mem hv1 hv2)) hv3
    simp [hp1, hp2, hp3, vadd_vadd]
#align affine_subspace.mk' AffineSubspace.mk'
-/

#print AffineSubspace.self_mem_mk' /-
/-- An affine subspace constructed from a point and a direction contains
that point. -/
theorem self_mem_mk' (p : P) (direction : Submodule k V) : p ∈ mk' p direction :=
  ⟨0, ⟨direction.zero_mem, (zero_vadd _ _).symm⟩⟩
#align affine_subspace.self_mem_mk' AffineSubspace.self_mem_mk'
-/

#print AffineSubspace.vadd_mem_mk' /-
/-- An affine subspace constructed from a point and a direction contains
the result of adding a vector in that direction to that point. -/
theorem vadd_mem_mk' {v : V} (p : P) {direction : Submodule k V} (hv : v ∈ direction) :
    v +ᵥ p ∈ mk' p direction :=
  ⟨v, hv, rfl⟩
#align affine_subspace.vadd_mem_mk' AffineSubspace.vadd_mem_mk'
-/

#print AffineSubspace.mk'_nonempty /-
/-- An affine subspace constructed from a point and a direction is
nonempty. -/
theorem mk'_nonempty (p : P) (direction : Submodule k V) : (mk' p direction : Set P).Nonempty :=
  ⟨p, self_mem_mk' p direction⟩
#align affine_subspace.mk'_nonempty AffineSubspace.mk'_nonempty
-/

#print AffineSubspace.direction_mk' /-
/-- The direction of an affine subspace constructed from a point and a
direction. -/
@[simp]
theorem direction_mk' (p : P) (direction : Submodule k V) :
    (mk' p direction).direction = direction := by
  ext v
  rw [mem_direction_iff_eq_vsub (mk'_nonempty _ _)]
  constructor
  · rintro ⟨p1, ⟨v1, hv1, hp1⟩, p2, ⟨v2, hv2, hp2⟩, hv⟩
    rw [hv, hp1, hp2, vadd_vsub_vadd_cancel_right]
    exact direction.sub_mem hv1 hv2
  · exact fun hv => ⟨v +ᵥ p, vadd_mem_mk' _ hv, p, self_mem_mk' _ _, (vadd_vsub _ _).symm⟩
#align affine_subspace.direction_mk' AffineSubspace.direction_mk'
-/

#print AffineSubspace.mem_mk'_iff_vsub_mem /-
/-- A point lies in an affine subspace constructed from another point and a direction if and only
if their difference is in that direction. -/
theorem mem_mk'_iff_vsub_mem {p₁ p₂ : P} {direction : Submodule k V} :
    p₂ ∈ mk' p₁ direction ↔ p₂ -ᵥ p₁ ∈ direction :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · rw [← direction_mk' p₁ direction]
    exact vsub_mem_direction h (self_mem_mk' _ _)
  · rw [← vsub_vadd p₂ p₁]
    exact vadd_mem_mk' p₁ h
#align affine_subspace.mem_mk'_iff_vsub_mem AffineSubspace.mem_mk'_iff_vsub_mem
-/

#print AffineSubspace.mk'_eq /-
/-- Constructing an affine subspace from a point in a subspace and
that subspace's direction yields the original subspace. -/
@[simp]
theorem mk'_eq {s : AffineSubspace k P} {p : P} (hp : p ∈ s) : mk' p s.direction = s :=
  ext_of_direction_eq (direction_mk' p s.direction) ⟨p, Set.mem_inter (self_mem_mk' _ _) hp⟩
#align affine_subspace.mk'_eq AffineSubspace.mk'_eq
-/

#print AffineSubspace.spanPoints_subset_coe_of_subset_coe /-
/-- If an affine subspace contains a set of points, it contains the
`span_points` of that set. -/
theorem spanPoints_subset_coe_of_subset_coe {s : Set P} {s1 : AffineSubspace k P} (h : s ⊆ s1) :
    spanPoints k s ⊆ s1 := by
  rintro p ⟨p1, hp1, v, hv, hp⟩
  rw [hp]
  have hp1s1 : p1 ∈ (s1 : Set P) := Set.mem_of_mem_of_subset hp1 h
  refine' vadd_mem_of_mem_direction _ hp1s1
  have hs : vectorSpan k s ≤ s1.direction := vectorSpan_mono k h
  rw [SetLike.le_def] at hs 
  rw [← SetLike.mem_coe]
  exact Set.mem_of_mem_of_subset hv hs
#align affine_subspace.span_points_subset_coe_of_subset_coe AffineSubspace.spanPoints_subset_coe_of_subset_coe
-/

end AffineSubspace

#print AffineMap.lineMap_mem /-
theorem AffineMap.lineMap_mem {k V P : Type _} [Ring k] [AddCommGroup V] [Module k V]
    [AddTorsor V P] {Q : AffineSubspace k P} {p₀ p₁ : P} (c : k) (h₀ : p₀ ∈ Q) (h₁ : p₁ ∈ Q) :
    AffineMap.lineMap p₀ p₁ c ∈ Q :=
  by
  rw [AffineMap.lineMap_apply]
  exact Q.smul_vsub_vadd_mem c h₁ h₀ h₀
#align affine_map.line_map_mem AffineMap.lineMap_mem
-/

section affineSpan

variable (k : Type _) {V : Type _} {P : Type _} [Ring k] [AddCommGroup V] [Module k V]
  [affine_space V P]

#print affineSpan /-
/-- The affine span of a set of points is the smallest affine subspace
containing those points. (Actually defined here in terms of spans in
modules.) -/
def affineSpan (s : Set P) : AffineSubspace k P
    where
  carrier := spanPoints k s
  smul_vsub_vadd_mem c p1 p2 p3 hp1 hp2 hp3 :=
    vadd_mem_spanPoints_of_mem_spanPoints_of_mem_vectorSpan k hp3
      ((vectorSpan k s).smul_mem c
        (vsub_mem_vectorSpan_of_mem_spanPoints_of_mem_spanPoints k hp1 hp2))
#align affine_span affineSpan
-/

#print coe_affineSpan /-
/-- The affine span, converted to a set, is `span_points`. -/
@[simp]
theorem coe_affineSpan (s : Set P) : (affineSpan k s : Set P) = spanPoints k s :=
  rfl
#align coe_affine_span coe_affineSpan
-/

#print subset_affineSpan /-
/-- A set is contained in its affine span. -/
theorem subset_affineSpan (s : Set P) : s ⊆ affineSpan k s :=
  subset_spanPoints k s
#align subset_affine_span subset_affineSpan
-/

#print direction_affineSpan /-
/-- The direction of the affine span is the `vector_span`. -/
theorem direction_affineSpan (s : Set P) : (affineSpan k s).direction = vectorSpan k s :=
  by
  apply le_antisymm
  · refine' Submodule.span_le.2 _
    rintro v ⟨p1, p3, ⟨p2, hp2, v1, hv1, hp1⟩, ⟨p4, hp4, v2, hv2, hp3⟩, rfl⟩
    rw [hp1, hp3, vsub_vadd_eq_vsub_sub, vadd_vsub_assoc, SetLike.mem_coe]
    exact
      (vectorSpan k s).sub_mem ((vectorSpan k s).add_mem hv1 (vsub_mem_vectorSpan k hp2 hp4)) hv2
  · exact vectorSpan_mono k (subset_spanPoints k s)
#align direction_affine_span direction_affineSpan
-/

#print mem_affineSpan /-
/-- A point in a set is in its affine span. -/
theorem mem_affineSpan {p : P} {s : Set P} (hp : p ∈ s) : p ∈ affineSpan k s :=
  mem_spanPoints k p s hp
#align mem_affine_span mem_affineSpan
-/

end affineSpan

namespace AffineSubspace

variable {k : Type _} {V : Type _} {P : Type _} [Ring k] [AddCommGroup V] [Module k V]
  [S : affine_space V P]

instance : CompleteLattice (AffineSubspace k P) :=
  {
    PartialOrder.lift (coe : AffineSubspace k P → Set P)
      coe_injective with
    sup := fun s1 s2 => affineSpan k (s1 ∪ s2)
    le_sup_left := fun s1 s2 =>
      Set.Subset.trans (Set.subset_union_left s1 s2) (subset_spanPoints k _)
    le_sup_right := fun s1 s2 =>
      Set.Subset.trans (Set.subset_union_right s1 s2) (subset_spanPoints k _)
    sup_le := fun s1 s2 s3 hs1 hs2 => spanPoints_subset_coe_of_subset_coe (Set.union_subset hs1 hs2)
    inf := fun s1 s2 =>
      mk (s1 ∩ s2) fun c p1 p2 p3 hp1 hp2 hp3 =>
        ⟨s1.smul_vsub_vadd_mem c hp1.1 hp2.1 hp3.1, s2.smul_vsub_vadd_mem c hp1.2 hp2.2 hp3.2⟩
    inf_le_left := fun _ _ => Set.inter_subset_left _ _
    inf_le_right := fun _ _ => Set.inter_subset_right _ _
    le_inf := fun _ _ _ => Set.subset_inter
    top :=
      { carrier := Set.univ
        smul_vsub_vadd_mem := fun _ _ _ _ _ _ _ => Set.mem_univ _ }
    le_top := fun _ _ _ => Set.mem_univ _
    bot :=
      { carrier := ∅
        smul_vsub_vadd_mem := fun _ _ _ _ => False.elim }
    bot_le := fun _ _ => False.elim
    sSup := fun s => affineSpan k (⋃ s' ∈ s, (s' : Set P))
    sInf := fun s =>
      mk (⋂ s' ∈ s, (s' : Set P)) fun c p1 p2 p3 hp1 hp2 hp3 =>
        Set.mem_iInter₂.2 fun s2 hs2 => by
          rw [Set.mem_iInter₂] at *
          exact s2.smul_vsub_vadd_mem c (hp1 s2 hs2) (hp2 s2 hs2) (hp3 s2 hs2)
    le_sup := fun _ _ h => Set.Subset.trans (Set.subset_biUnion_of_mem h) (subset_spanPoints k _)
    sup_le := fun _ _ h => spanPoints_subset_coe_of_subset_coe (Set.iUnion₂_subset h)
    inf_le := fun _ _ => Set.biInter_subset_of_mem
    le_inf := fun _ _ => Set.subset_iInter₂ }

instance : Inhabited (AffineSubspace k P) :=
  ⟨⊤⟩

#print AffineSubspace.le_def /-
/-- The `≤` order on subspaces is the same as that on the corresponding
sets. -/
theorem le_def (s1 s2 : AffineSubspace k P) : s1 ≤ s2 ↔ (s1 : Set P) ⊆ s2 :=
  Iff.rfl
#align affine_subspace.le_def AffineSubspace.le_def
-/

#print AffineSubspace.le_def' /-
/-- One subspace is less than or equal to another if and only if all
its points are in the second subspace. -/
theorem le_def' (s1 s2 : AffineSubspace k P) : s1 ≤ s2 ↔ ∀ p ∈ s1, p ∈ s2 :=
  Iff.rfl
#align affine_subspace.le_def' AffineSubspace.le_def'
-/

#print AffineSubspace.lt_def /-
/-- The `<` order on subspaces is the same as that on the corresponding
sets. -/
theorem lt_def (s1 s2 : AffineSubspace k P) : s1 < s2 ↔ (s1 : Set P) ⊂ s2 :=
  Iff.rfl
#align affine_subspace.lt_def AffineSubspace.lt_def
-/

#print AffineSubspace.not_le_iff_exists /-
/-- One subspace is not less than or equal to another if and only if
it has a point not in the second subspace. -/
theorem not_le_iff_exists (s1 s2 : AffineSubspace k P) : ¬s1 ≤ s2 ↔ ∃ p ∈ s1, p ∉ s2 :=
  Set.not_subset
#align affine_subspace.not_le_iff_exists AffineSubspace.not_le_iff_exists
-/

#print AffineSubspace.exists_of_lt /-
/-- If a subspace is less than another, there is a point only in the
second. -/
theorem exists_of_lt {s1 s2 : AffineSubspace k P} (h : s1 < s2) : ∃ p ∈ s2, p ∉ s1 :=
  Set.exists_of_ssubset h
#align affine_subspace.exists_of_lt AffineSubspace.exists_of_lt
-/

#print AffineSubspace.lt_iff_le_and_exists /-
/-- A subspace is less than another if and only if it is less than or
equal to the second subspace and there is a point only in the
second. -/
theorem lt_iff_le_and_exists (s1 s2 : AffineSubspace k P) : s1 < s2 ↔ s1 ≤ s2 ∧ ∃ p ∈ s2, p ∉ s1 :=
  by rw [lt_iff_le_not_le, not_le_iff_exists]
#align affine_subspace.lt_iff_le_and_exists AffineSubspace.lt_iff_le_and_exists
-/

#print AffineSubspace.eq_of_direction_eq_of_nonempty_of_le /-
/-- If an affine subspace is nonempty and contained in another with
the same direction, they are equal. -/
theorem eq_of_direction_eq_of_nonempty_of_le {s₁ s₂ : AffineSubspace k P}
    (hd : s₁.direction = s₂.direction) (hn : (s₁ : Set P).Nonempty) (hle : s₁ ≤ s₂) : s₁ = s₂ :=
  let ⟨p, hp⟩ := hn
  ext_of_direction_eq hd ⟨p, hp, hle hp⟩
#align affine_subspace.eq_of_direction_eq_of_nonempty_of_le AffineSubspace.eq_of_direction_eq_of_nonempty_of_le
-/

variable (k V)

#print AffineSubspace.affineSpan_eq_sInf /-
/-- The affine span is the `Inf` of subspaces containing the given
points. -/
theorem affineSpan_eq_sInf (s : Set P) : affineSpan k s = sInf {s' | s ⊆ s'} :=
  le_antisymm (spanPoints_subset_coe_of_subset_coe <| Set.subset_iInter₂ fun _ => id)
    (sInf_le (subset_spanPoints k _))
#align affine_subspace.affine_span_eq_Inf AffineSubspace.affineSpan_eq_sInf
-/

variable (P)

#print AffineSubspace.gi /-
/-- The Galois insertion formed by `affine_span` and coercion back to
a set. -/
protected def gi : GaloisInsertion (affineSpan k) (coe : AffineSubspace k P → Set P)
    where
  choice s _ := affineSpan k s
  gc s1 s2 :=
    ⟨fun h => Set.Subset.trans (subset_spanPoints k s1) h, spanPoints_subset_coe_of_subset_coe⟩
  le_l_u _ := subset_spanPoints k _
  choice_eq _ _ := rfl
#align affine_subspace.gi AffineSubspace.gi
-/

#print AffineSubspace.span_empty /-
/-- The span of the empty set is `⊥`. -/
@[simp]
theorem span_empty : affineSpan k (∅ : Set P) = ⊥ :=
  (AffineSubspace.gi k V P).gc.l_bot
#align affine_subspace.span_empty AffineSubspace.span_empty
-/

#print AffineSubspace.span_univ /-
/-- The span of `univ` is `⊤`. -/
@[simp]
theorem span_univ : affineSpan k (Set.univ : Set P) = ⊤ :=
  eq_top_iff.2 <| subset_spanPoints k _
#align affine_subspace.span_univ AffineSubspace.span_univ
-/

variable {k V P}

#print affineSpan_le /-
theorem affineSpan_le {s : Set P} {Q : AffineSubspace k P} : affineSpan k s ≤ Q ↔ s ⊆ (Q : Set P) :=
  (AffineSubspace.gi k V P).gc _ _
#align affine_span_le affineSpan_le
-/

variable (k V) {P} {p₁ p₂ : P}

#print AffineSubspace.coe_affineSpan_singleton /-
/-- The affine span of a single point, coerced to a set, contains just
that point. -/
@[simp]
theorem coe_affineSpan_singleton (p : P) : (affineSpan k ({p} : Set P) : Set P) = {p} :=
  by
  ext x
  rw [mem_coe, ← vsub_right_mem_direction_iff_mem (mem_affineSpan k (Set.mem_singleton p)) _,
    direction_affineSpan]
  simp
#align affine_subspace.coe_affine_span_singleton AffineSubspace.coe_affineSpan_singleton
-/

#print AffineSubspace.mem_affineSpan_singleton /-
/-- A point is in the affine span of a single point if and only if
they are equal. -/
@[simp]
theorem mem_affineSpan_singleton : p₁ ∈ affineSpan k ({p₂} : Set P) ↔ p₁ = p₂ := by simp [← mem_coe]
#align affine_subspace.mem_affine_span_singleton AffineSubspace.mem_affineSpan_singleton
-/

#print AffineSubspace.preimage_coe_affineSpan_singleton /-
@[simp]
theorem preimage_coe_affineSpan_singleton (x : P) :
    (coe : affineSpan k ({x} : Set P) → P) ⁻¹' {x} = univ :=
  eq_univ_of_forall fun y => (AffineSubspace.mem_affineSpan_singleton _ _).1 y.2
#align affine_subspace.preimage_coe_affine_span_singleton AffineSubspace.preimage_coe_affineSpan_singleton
-/

#print AffineSubspace.span_union /-
/-- The span of a union of sets is the sup of their spans. -/
theorem span_union (s t : Set P) : affineSpan k (s ∪ t) = affineSpan k s ⊔ affineSpan k t :=
  (AffineSubspace.gi k V P).gc.l_sup
#align affine_subspace.span_union AffineSubspace.span_union
-/

#print AffineSubspace.span_iUnion /-
/-- The span of a union of an indexed family of sets is the sup of
their spans. -/
theorem span_iUnion {ι : Type _} (s : ι → Set P) :
    affineSpan k (⋃ i, s i) = ⨆ i, affineSpan k (s i) :=
  (AffineSubspace.gi k V P).gc.l_iSup
#align affine_subspace.span_Union AffineSubspace.span_iUnion
-/

variable (P)

#print AffineSubspace.top_coe /-
/-- `⊤`, coerced to a set, is the whole set of points. -/
@[simp]
theorem top_coe : ((⊤ : AffineSubspace k P) : Set P) = Set.univ :=
  rfl
#align affine_subspace.top_coe AffineSubspace.top_coe
-/

variable {P}

#print AffineSubspace.mem_top /-
/-- All points are in `⊤`. -/
theorem mem_top (p : P) : p ∈ (⊤ : AffineSubspace k P) :=
  Set.mem_univ p
#align affine_subspace.mem_top AffineSubspace.mem_top
-/

variable (P)

#print AffineSubspace.direction_top /-
/-- The direction of `⊤` is the whole module as a submodule. -/
@[simp]
theorem direction_top : (⊤ : AffineSubspace k P).direction = ⊤ :=
  by
  cases' S.nonempty with p
  ext v
  refine' ⟨imp_intro Submodule.mem_top, fun hv => _⟩
  have hpv : (v +ᵥ p -ᵥ p : V) ∈ (⊤ : AffineSubspace k P).direction :=
    vsub_mem_direction (mem_top k V _) (mem_top k V _)
  rwa [vadd_vsub] at hpv 
#align affine_subspace.direction_top AffineSubspace.direction_top
-/

#print AffineSubspace.bot_coe /-
/-- `⊥`, coerced to a set, is the empty set. -/
@[simp]
theorem bot_coe : ((⊥ : AffineSubspace k P) : Set P) = ∅ :=
  rfl
#align affine_subspace.bot_coe AffineSubspace.bot_coe
-/

#print AffineSubspace.bot_ne_top /-
theorem bot_ne_top : (⊥ : AffineSubspace k P) ≠ ⊤ :=
  by
  intro contra
  rw [← ext_iff, bot_coe, top_coe] at contra 
  exact Set.empty_ne_univ contra
#align affine_subspace.bot_ne_top AffineSubspace.bot_ne_top
-/

instance : Nontrivial (AffineSubspace k P) :=
  ⟨⟨⊥, ⊤, bot_ne_top k V P⟩⟩

#print AffineSubspace.nonempty_of_affineSpan_eq_top /-
theorem nonempty_of_affineSpan_eq_top {s : Set P} (h : affineSpan k s = ⊤) : s.Nonempty :=
  by
  rw [Set.nonempty_iff_ne_empty]
  rintro rfl
  rw [AffineSubspace.span_empty] at h 
  exact bot_ne_top k V P h
#align affine_subspace.nonempty_of_affine_span_eq_top AffineSubspace.nonempty_of_affineSpan_eq_top
-/

#print AffineSubspace.vectorSpan_eq_top_of_affineSpan_eq_top /-
/-- If the affine span of a set is `⊤`, then the vector span of the same set is the `⊤`. -/
theorem vectorSpan_eq_top_of_affineSpan_eq_top {s : Set P} (h : affineSpan k s = ⊤) :
    vectorSpan k s = ⊤ := by rw [← direction_affineSpan, h, direction_top]
#align affine_subspace.vector_span_eq_top_of_affine_span_eq_top AffineSubspace.vectorSpan_eq_top_of_affineSpan_eq_top
-/

#print AffineSubspace.affineSpan_eq_top_iff_vectorSpan_eq_top_of_nonempty /-
/-- For a nonempty set, the affine span is `⊤` iff its vector span is `⊤`. -/
theorem affineSpan_eq_top_iff_vectorSpan_eq_top_of_nonempty {s : Set P} (hs : s.Nonempty) :
    affineSpan k s = ⊤ ↔ vectorSpan k s = ⊤ :=
  by
  refine' ⟨vector_span_eq_top_of_affine_span_eq_top k V P, _⟩
  intro h
  suffices Nonempty (affineSpan k s)
    by
    obtain ⟨p, hp : p ∈ affineSpan k s⟩ := this
    rw [eq_iff_direction_eq_of_mem hp (mem_top k V p), direction_affineSpan, h, direction_top]
  obtain ⟨x, hx⟩ := hs
  exact ⟨⟨x, mem_affineSpan k hx⟩⟩
#align affine_subspace.affine_span_eq_top_iff_vector_span_eq_top_of_nonempty AffineSubspace.affineSpan_eq_top_iff_vectorSpan_eq_top_of_nonempty
-/

#print AffineSubspace.affineSpan_eq_top_iff_vectorSpan_eq_top_of_nontrivial /-
/-- For a non-trivial space, the affine span of a set is `⊤` iff its vector span is `⊤`. -/
theorem affineSpan_eq_top_iff_vectorSpan_eq_top_of_nontrivial {s : Set P} [Nontrivial P] :
    affineSpan k s = ⊤ ↔ vectorSpan k s = ⊤ :=
  by
  cases' s.eq_empty_or_nonempty with hs hs
  · simp [hs, subsingleton_iff_bot_eq_top, AddTorsor.subsingleton_iff V P, not_subsingleton]
  · rw [affine_span_eq_top_iff_vector_span_eq_top_of_nonempty k V P hs]
#align affine_subspace.affine_span_eq_top_iff_vector_span_eq_top_of_nontrivial AffineSubspace.affineSpan_eq_top_iff_vectorSpan_eq_top_of_nontrivial
-/

#print AffineSubspace.card_pos_of_affineSpan_eq_top /-
theorem card_pos_of_affineSpan_eq_top {ι : Type _} [Fintype ι] {p : ι → P}
    (h : affineSpan k (range p) = ⊤) : 0 < Fintype.card ι :=
  by
  obtain ⟨-, ⟨i, -⟩⟩ := nonempty_of_affine_span_eq_top k V P h
  exact fintype.card_pos_iff.mpr ⟨i⟩
#align affine_subspace.card_pos_of_affine_span_eq_top AffineSubspace.card_pos_of_affineSpan_eq_top
-/

variable {P}

#print AffineSubspace.not_mem_bot /-
/-- No points are in `⊥`. -/
theorem not_mem_bot (p : P) : p ∉ (⊥ : AffineSubspace k P) :=
  Set.not_mem_empty p
#align affine_subspace.not_mem_bot AffineSubspace.not_mem_bot
-/

variable (P)

#print AffineSubspace.direction_bot /-
/-- The direction of `⊥` is the submodule `⊥`. -/
@[simp]
theorem direction_bot : (⊥ : AffineSubspace k P).direction = ⊥ := by
  rw [direction_eq_vector_span, bot_coe, vectorSpan_def, vsub_empty, Submodule.span_empty]
#align affine_subspace.direction_bot AffineSubspace.direction_bot
-/

variable {k V P}

#print AffineSubspace.coe_eq_bot_iff /-
@[simp]
theorem coe_eq_bot_iff (Q : AffineSubspace k P) : (Q : Set P) = ∅ ↔ Q = ⊥ :=
  coe_injective.eq_iff' (bot_coe _ _ _)
#align affine_subspace.coe_eq_bot_iff AffineSubspace.coe_eq_bot_iff
-/

#print AffineSubspace.coe_eq_univ_iff /-
@[simp]
theorem coe_eq_univ_iff (Q : AffineSubspace k P) : (Q : Set P) = univ ↔ Q = ⊤ :=
  coe_injective.eq_iff' (top_coe _ _ _)
#align affine_subspace.coe_eq_univ_iff AffineSubspace.coe_eq_univ_iff
-/

#print AffineSubspace.nonempty_iff_ne_bot /-
theorem nonempty_iff_ne_bot (Q : AffineSubspace k P) : (Q : Set P).Nonempty ↔ Q ≠ ⊥ := by
  rw [nonempty_iff_ne_empty]; exact not_congr Q.coe_eq_bot_iff
#align affine_subspace.nonempty_iff_ne_bot AffineSubspace.nonempty_iff_ne_bot
-/

#print AffineSubspace.eq_bot_or_nonempty /-
theorem eq_bot_or_nonempty (Q : AffineSubspace k P) : Q = ⊥ ∨ (Q : Set P).Nonempty := by
  rw [nonempty_iff_ne_bot]; apply eq_or_ne
#align affine_subspace.eq_bot_or_nonempty AffineSubspace.eq_bot_or_nonempty
-/

#print AffineSubspace.subsingleton_of_subsingleton_span_eq_top /-
theorem subsingleton_of_subsingleton_span_eq_top {s : Set P} (h₁ : s.Subsingleton)
    (h₂ : affineSpan k s = ⊤) : Subsingleton P :=
  by
  obtain ⟨p, hp⟩ := AffineSubspace.nonempty_of_affineSpan_eq_top k V P h₂
  have : s = {p} := subset.antisymm (fun q hq => h₁ hq hp) (by simp [hp])
  rw [this, ← AffineSubspace.ext_iff, AffineSubspace.coe_affineSpan_singleton,
    AffineSubspace.top_coe, eq_comm, ← subsingleton_iff_singleton (mem_univ _)] at h₂ 
  exact subsingleton_of_univ_subsingleton h₂
#align affine_subspace.subsingleton_of_subsingleton_span_eq_top AffineSubspace.subsingleton_of_subsingleton_span_eq_top
-/

#print AffineSubspace.eq_univ_of_subsingleton_span_eq_top /-
theorem eq_univ_of_subsingleton_span_eq_top {s : Set P} (h₁ : s.Subsingleton)
    (h₂ : affineSpan k s = ⊤) : s = (univ : Set P) :=
  by
  obtain ⟨p, hp⟩ := AffineSubspace.nonempty_of_affineSpan_eq_top k V P h₂
  have : s = {p} := subset.antisymm (fun q hq => h₁ hq hp) (by simp [hp])
  rw [this, eq_comm, ← subsingleton_iff_singleton (mem_univ p), subsingleton_univ_iff]
  exact subsingleton_of_subsingleton_span_eq_top h₁ h₂
#align affine_subspace.eq_univ_of_subsingleton_span_eq_top AffineSubspace.eq_univ_of_subsingleton_span_eq_top
-/

#print AffineSubspace.direction_eq_top_iff_of_nonempty /-
/-- A nonempty affine subspace is `⊤` if and only if its direction is
`⊤`. -/
@[simp]
theorem direction_eq_top_iff_of_nonempty {s : AffineSubspace k P} (h : (s : Set P).Nonempty) :
    s.direction = ⊤ ↔ s = ⊤ := by
  constructor
  · intro hd
    rw [← direction_top k V P] at hd 
    refine' ext_of_direction_eq hd _
    simp [h]
  · rintro rfl
    simp
#align affine_subspace.direction_eq_top_iff_of_nonempty AffineSubspace.direction_eq_top_iff_of_nonempty
-/

#print AffineSubspace.inf_coe /-
/-- The inf of two affine subspaces, coerced to a set, is the
intersection of the two sets of points. -/
@[simp]
theorem inf_coe (s1 s2 : AffineSubspace k P) : (s1 ⊓ s2 : Set P) = s1 ∩ s2 :=
  rfl
#align affine_subspace.inf_coe AffineSubspace.inf_coe
-/

#print AffineSubspace.mem_inf_iff /-
/-- A point is in the inf of two affine subspaces if and only if it is
in both of them. -/
theorem mem_inf_iff (p : P) (s1 s2 : AffineSubspace k P) : p ∈ s1 ⊓ s2 ↔ p ∈ s1 ∧ p ∈ s2 :=
  Iff.rfl
#align affine_subspace.mem_inf_iff AffineSubspace.mem_inf_iff
-/

#print AffineSubspace.direction_inf /-
/-- The direction of the inf of two affine subspaces is less than or
equal to the inf of their directions. -/
theorem direction_inf (s1 s2 : AffineSubspace k P) :
    (s1 ⊓ s2).direction ≤ s1.direction ⊓ s2.direction :=
  by
  repeat' rw [direction_eq_vector_span, vectorSpan_def]
  exact
    le_inf (sInf_le_sInf fun p hp => trans (vsub_self_mono (inter_subset_left _ _)) hp)
      (sInf_le_sInf fun p hp => trans (vsub_self_mono (inter_subset_right _ _)) hp)
#align affine_subspace.direction_inf AffineSubspace.direction_inf
-/

#print AffineSubspace.direction_inf_of_mem /-
/-- If two affine subspaces have a point in common, the direction of
their inf equals the inf of their directions. -/
theorem direction_inf_of_mem {s₁ s₂ : AffineSubspace k P} {p : P} (h₁ : p ∈ s₁) (h₂ : p ∈ s₂) :
    (s₁ ⊓ s₂).direction = s₁.direction ⊓ s₂.direction :=
  by
  ext v
  rw [Submodule.mem_inf, ← vadd_mem_iff_mem_direction v h₁, ← vadd_mem_iff_mem_direction v h₂, ←
    vadd_mem_iff_mem_direction v ((mem_inf_iff p s₁ s₂).2 ⟨h₁, h₂⟩), mem_inf_iff]
#align affine_subspace.direction_inf_of_mem AffineSubspace.direction_inf_of_mem
-/

#print AffineSubspace.direction_inf_of_mem_inf /-
/-- If two affine subspaces have a point in their inf, the direction
of their inf equals the inf of their directions. -/
theorem direction_inf_of_mem_inf {s₁ s₂ : AffineSubspace k P} {p : P} (h : p ∈ s₁ ⊓ s₂) :
    (s₁ ⊓ s₂).direction = s₁.direction ⊓ s₂.direction :=
  direction_inf_of_mem ((mem_inf_iff p s₁ s₂).1 h).1 ((mem_inf_iff p s₁ s₂).1 h).2
#align affine_subspace.direction_inf_of_mem_inf AffineSubspace.direction_inf_of_mem_inf
-/

#print AffineSubspace.direction_le /-
/-- If one affine subspace is less than or equal to another, the same
applies to their directions. -/
theorem direction_le {s1 s2 : AffineSubspace k P} (h : s1 ≤ s2) : s1.direction ≤ s2.direction :=
  by
  repeat' rw [direction_eq_vector_span, vectorSpan_def]
  exact vectorSpan_mono k h
#align affine_subspace.direction_le AffineSubspace.direction_le
-/

#print AffineSubspace.direction_lt_of_nonempty /-
/-- If one nonempty affine subspace is less than another, the same
applies to their directions -/
theorem direction_lt_of_nonempty {s1 s2 : AffineSubspace k P} (h : s1 < s2)
    (hn : (s1 : Set P).Nonempty) : s1.direction < s2.direction :=
  by
  cases' hn with p hp
  rw [lt_iff_le_and_exists] at h 
  rcases h with ⟨hle, p2, hp2, hp2s1⟩
  rw [SetLike.lt_iff_le_and_exists]
  use direction_le hle, p2 -ᵥ p, vsub_mem_direction hp2 (hle hp)
  intro hm
  rw [vsub_right_mem_direction_iff_mem hp p2] at hm 
  exact hp2s1 hm
#align affine_subspace.direction_lt_of_nonempty AffineSubspace.direction_lt_of_nonempty
-/

#print AffineSubspace.sup_direction_le /-
/-- The sup of the directions of two affine subspaces is less than or
equal to the direction of their sup. -/
theorem sup_direction_le (s1 s2 : AffineSubspace k P) :
    s1.direction ⊔ s2.direction ≤ (s1 ⊔ s2).direction :=
  by
  repeat' rw [direction_eq_vector_span, vectorSpan_def]
  exact
    sup_le
      (sInf_le_sInf fun p hp => Set.Subset.trans (vsub_self_mono (le_sup_left : s1 ≤ s1 ⊔ s2)) hp)
      (sInf_le_sInf fun p hp => Set.Subset.trans (vsub_self_mono (le_sup_right : s2 ≤ s1 ⊔ s2)) hp)
#align affine_subspace.sup_direction_le AffineSubspace.sup_direction_le
-/

#print AffineSubspace.sup_direction_lt_of_nonempty_of_inter_empty /-
/-- The sup of the directions of two nonempty affine subspaces with
empty intersection is less than the direction of their sup. -/
theorem sup_direction_lt_of_nonempty_of_inter_empty {s1 s2 : AffineSubspace k P}
    (h1 : (s1 : Set P).Nonempty) (h2 : (s2 : Set P).Nonempty) (he : (s1 ∩ s2 : Set P) = ∅) :
    s1.direction ⊔ s2.direction < (s1 ⊔ s2).direction :=
  by
  cases' h1 with p1 hp1
  cases' h2 with p2 hp2
  rw [SetLike.lt_iff_le_and_exists]
  use sup_direction_le s1 s2, p2 -ᵥ p1,
    vsub_mem_direction ((le_sup_right : s2 ≤ s1 ⊔ s2) hp2) ((le_sup_left : s1 ≤ s1 ⊔ s2) hp1)
  intro h
  rw [Submodule.mem_sup] at h 
  rcases h with ⟨v1, hv1, v2, hv2, hv1v2⟩
  rw [← sub_eq_zero, sub_eq_add_neg, neg_vsub_eq_vsub_rev, add_comm v1, add_assoc, ←
    vadd_vsub_assoc, ← neg_neg v2, add_comm, ← sub_eq_add_neg, ← vsub_vadd_eq_vsub_sub,
    vsub_eq_zero_iff_eq] at hv1v2 
  refine' Set.Nonempty.ne_empty _ he
  use v1 +ᵥ p1, vadd_mem_of_mem_direction hv1 hp1
  rw [hv1v2]
  exact vadd_mem_of_mem_direction (Submodule.neg_mem _ hv2) hp2
#align affine_subspace.sup_direction_lt_of_nonempty_of_inter_empty AffineSubspace.sup_direction_lt_of_nonempty_of_inter_empty
-/

#print AffineSubspace.inter_nonempty_of_nonempty_of_sup_direction_eq_top /-
/-- If the directions of two nonempty affine subspaces span the whole
module, they have nonempty intersection. -/
theorem inter_nonempty_of_nonempty_of_sup_direction_eq_top {s1 s2 : AffineSubspace k P}
    (h1 : (s1 : Set P).Nonempty) (h2 : (s2 : Set P).Nonempty)
    (hd : s1.direction ⊔ s2.direction = ⊤) : ((s1 : Set P) ∩ s2).Nonempty :=
  by
  by_contra h
  rw [Set.not_nonempty_iff_eq_empty] at h 
  have hlt := sup_direction_lt_of_nonempty_of_inter_empty h1 h2 h
  rw [hd] at hlt 
  exact not_top_lt hlt
#align affine_subspace.inter_nonempty_of_nonempty_of_sup_direction_eq_top AffineSubspace.inter_nonempty_of_nonempty_of_sup_direction_eq_top
-/

#print AffineSubspace.inter_eq_singleton_of_nonempty_of_isCompl /-
/-- If the directions of two nonempty affine subspaces are complements
of each other, they intersect in exactly one point. -/
theorem inter_eq_singleton_of_nonempty_of_isCompl {s1 s2 : AffineSubspace k P}
    (h1 : (s1 : Set P).Nonempty) (h2 : (s2 : Set P).Nonempty)
    (hd : IsCompl s1.direction s2.direction) : ∃ p, (s1 : Set P) ∩ s2 = {p} :=
  by
  cases' inter_nonempty_of_nonempty_of_sup_direction_eq_top h1 h2 hd.sup_eq_top with p hp
  use p
  ext q
  rw [Set.mem_singleton_iff]
  constructor
  · rintro ⟨hq1, hq2⟩
    have hqp : q -ᵥ p ∈ s1.direction ⊓ s2.direction :=
      ⟨vsub_mem_direction hq1 hp.1, vsub_mem_direction hq2 hp.2⟩
    rwa [hd.inf_eq_bot, Submodule.mem_bot, vsub_eq_zero_iff_eq] at hqp 
  · exact fun h => h.symm ▸ hp
#align affine_subspace.inter_eq_singleton_of_nonempty_of_is_compl AffineSubspace.inter_eq_singleton_of_nonempty_of_isCompl
-/

#print AffineSubspace.affineSpan_coe /-
/-- Coercing a subspace to a set then taking the affine span produces
the original subspace. -/
@[simp]
theorem affineSpan_coe (s : AffineSubspace k P) : affineSpan k (s : Set P) = s :=
  by
  refine' le_antisymm _ (subset_spanPoints _ _)
  rintro p ⟨p1, hp1, v, hv, rfl⟩
  exact vadd_mem_of_mem_direction hv hp1
#align affine_subspace.affine_span_coe AffineSubspace.affineSpan_coe
-/

end AffineSubspace

section AffineSpace'

variable (k : Type _) {V : Type _} {P : Type _} [Ring k] [AddCommGroup V] [Module k V]
  [affine_space V P]

variable {ι : Type _}

open AffineSubspace Set

#print vectorSpan_eq_span_vsub_set_left /-
/-- The `vector_span` is the span of the pairwise subtractions with a
given point on the left. -/
theorem vectorSpan_eq_span_vsub_set_left {s : Set P} {p : P} (hp : p ∈ s) :
    vectorSpan k s = Submodule.span k ((· -ᵥ ·) p '' s) :=
  by
  rw [vectorSpan_def]
  refine' le_antisymm _ (Submodule.span_mono _)
  · rw [Submodule.span_le]
    rintro v ⟨p1, p2, hp1, hp2, hv⟩
    rw [← vsub_sub_vsub_cancel_left p1 p2 p] at hv 
    rw [← hv, SetLike.mem_coe, Submodule.mem_span]
    exact fun m hm => Submodule.sub_mem _ (hm ⟨p2, hp2, rfl⟩) (hm ⟨p1, hp1, rfl⟩)
  · rintro v ⟨p2, hp2, hv⟩
    exact ⟨p, p2, hp, hp2, hv⟩
#align vector_span_eq_span_vsub_set_left vectorSpan_eq_span_vsub_set_left
-/

#print vectorSpan_eq_span_vsub_set_right /-
/-- The `vector_span` is the span of the pairwise subtractions with a
given point on the right. -/
theorem vectorSpan_eq_span_vsub_set_right {s : Set P} {p : P} (hp : p ∈ s) :
    vectorSpan k s = Submodule.span k ((· -ᵥ p) '' s) :=
  by
  rw [vectorSpan_def]
  refine' le_antisymm _ (Submodule.span_mono _)
  · rw [Submodule.span_le]
    rintro v ⟨p1, p2, hp1, hp2, hv⟩
    rw [← vsub_sub_vsub_cancel_right p1 p2 p] at hv 
    rw [← hv, SetLike.mem_coe, Submodule.mem_span]
    exact fun m hm => Submodule.sub_mem _ (hm ⟨p1, hp1, rfl⟩) (hm ⟨p2, hp2, rfl⟩)
  · rintro v ⟨p2, hp2, hv⟩
    exact ⟨p2, p, hp2, hp, hv⟩
#align vector_span_eq_span_vsub_set_right vectorSpan_eq_span_vsub_set_right
-/

#print vectorSpan_eq_span_vsub_set_left_ne /-
/-- The `vector_span` is the span of the pairwise subtractions with a
given point on the left, excluding the subtraction of that point from
itself. -/
theorem vectorSpan_eq_span_vsub_set_left_ne {s : Set P} {p : P} (hp : p ∈ s) :
    vectorSpan k s = Submodule.span k ((· -ᵥ ·) p '' (s \ {p})) :=
  by
  conv_lhs =>
    rw [vectorSpan_eq_span_vsub_set_left k hp, ← Set.insert_eq_of_mem hp, ←
      Set.insert_diff_singleton, Set.image_insert_eq]
  simp [Submodule.span_insert_eq_span]
#align vector_span_eq_span_vsub_set_left_ne vectorSpan_eq_span_vsub_set_left_ne
-/

#print vectorSpan_eq_span_vsub_set_right_ne /-
/-- The `vector_span` is the span of the pairwise subtractions with a
given point on the right, excluding the subtraction of that point from
itself. -/
theorem vectorSpan_eq_span_vsub_set_right_ne {s : Set P} {p : P} (hp : p ∈ s) :
    vectorSpan k s = Submodule.span k ((· -ᵥ p) '' (s \ {p})) :=
  by
  conv_lhs =>
    rw [vectorSpan_eq_span_vsub_set_right k hp, ← Set.insert_eq_of_mem hp, ←
      Set.insert_diff_singleton, Set.image_insert_eq]
  simp [Submodule.span_insert_eq_span]
#align vector_span_eq_span_vsub_set_right_ne vectorSpan_eq_span_vsub_set_right_ne
-/

#print vectorSpan_eq_span_vsub_finset_right_ne /-
/-- The `vector_span` is the span of the pairwise subtractions with a
given point on the right, excluding the subtraction of that point from
itself. -/
theorem vectorSpan_eq_span_vsub_finset_right_ne [DecidableEq P] [DecidableEq V] {s : Finset P}
    {p : P} (hp : p ∈ s) :
    vectorSpan k (s : Set P) = Submodule.span k ((s.eraseₓ p).image (· -ᵥ p)) := by
  simp [vectorSpan_eq_span_vsub_set_right_ne _ (finset.mem_coe.mpr hp)]
#align vector_span_eq_span_vsub_finset_right_ne vectorSpan_eq_span_vsub_finset_right_ne
-/

#print vectorSpan_image_eq_span_vsub_set_left_ne /-
/-- The `vector_span` of the image of a function is the span of the
pairwise subtractions with a given point on the left, excluding the
subtraction of that point from itself. -/
theorem vectorSpan_image_eq_span_vsub_set_left_ne (p : ι → P) {s : Set ι} {i : ι} (hi : i ∈ s) :
    vectorSpan k (p '' s) = Submodule.span k ((· -ᵥ ·) (p i) '' (p '' (s \ {i}))) :=
  by
  conv_lhs =>
    rw [vectorSpan_eq_span_vsub_set_left k (Set.mem_image_of_mem p hi), ← Set.insert_eq_of_mem hi, ←
      Set.insert_diff_singleton, Set.image_insert_eq, Set.image_insert_eq]
  simp [Submodule.span_insert_eq_span]
#align vector_span_image_eq_span_vsub_set_left_ne vectorSpan_image_eq_span_vsub_set_left_ne
-/

#print vectorSpan_image_eq_span_vsub_set_right_ne /-
/-- The `vector_span` of the image of a function is the span of the
pairwise subtractions with a given point on the right, excluding the
subtraction of that point from itself. -/
theorem vectorSpan_image_eq_span_vsub_set_right_ne (p : ι → P) {s : Set ι} {i : ι} (hi : i ∈ s) :
    vectorSpan k (p '' s) = Submodule.span k ((· -ᵥ p i) '' (p '' (s \ {i}))) :=
  by
  conv_lhs =>
    rw [vectorSpan_eq_span_vsub_set_right k (Set.mem_image_of_mem p hi), ← Set.insert_eq_of_mem hi,
      ← Set.insert_diff_singleton, Set.image_insert_eq, Set.image_insert_eq]
  simp [Submodule.span_insert_eq_span]
#align vector_span_image_eq_span_vsub_set_right_ne vectorSpan_image_eq_span_vsub_set_right_ne
-/

#print vectorSpan_range_eq_span_range_vsub_left /-
/-- The `vector_span` of an indexed family is the span of the pairwise
subtractions with a given point on the left. -/
theorem vectorSpan_range_eq_span_range_vsub_left (p : ι → P) (i0 : ι) :
    vectorSpan k (Set.range p) = Submodule.span k (Set.range fun i : ι => p i0 -ᵥ p i) := by
  rw [vectorSpan_eq_span_vsub_set_left k (Set.mem_range_self i0), ← Set.range_comp]
#align vector_span_range_eq_span_range_vsub_left vectorSpan_range_eq_span_range_vsub_left
-/

#print vectorSpan_range_eq_span_range_vsub_right /-
/-- The `vector_span` of an indexed family is the span of the pairwise
subtractions with a given point on the right. -/
theorem vectorSpan_range_eq_span_range_vsub_right (p : ι → P) (i0 : ι) :
    vectorSpan k (Set.range p) = Submodule.span k (Set.range fun i : ι => p i -ᵥ p i0) := by
  rw [vectorSpan_eq_span_vsub_set_right k (Set.mem_range_self i0), ← Set.range_comp]
#align vector_span_range_eq_span_range_vsub_right vectorSpan_range_eq_span_range_vsub_right
-/

#print vectorSpan_range_eq_span_range_vsub_left_ne /-
/-- The `vector_span` of an indexed family is the span of the pairwise
subtractions with a given point on the left, excluding the subtraction
of that point from itself. -/
theorem vectorSpan_range_eq_span_range_vsub_left_ne (p : ι → P) (i₀ : ι) :
    vectorSpan k (Set.range p) =
      Submodule.span k (Set.range fun i : { x // x ≠ i₀ } => p i₀ -ᵥ p i) :=
  by
  rw [← Set.image_univ, vectorSpan_image_eq_span_vsub_set_left_ne k _ (Set.mem_univ i₀)]
  congr with v
  simp only [Set.mem_range, Set.mem_image, Set.mem_diff, Set.mem_singleton_iff, Subtype.exists,
    Subtype.coe_mk]
  constructor
  · rintro ⟨x, ⟨i₁, ⟨⟨hi₁u, hi₁⟩, rfl⟩⟩, hv⟩
    exact ⟨i₁, hi₁, hv⟩
  · exact fun ⟨i₁, hi₁, hv⟩ => ⟨p i₁, ⟨i₁, ⟨Set.mem_univ _, hi₁⟩, rfl⟩, hv⟩
#align vector_span_range_eq_span_range_vsub_left_ne vectorSpan_range_eq_span_range_vsub_left_ne
-/

#print vectorSpan_range_eq_span_range_vsub_right_ne /-
/-- The `vector_span` of an indexed family is the span of the pairwise
subtractions with a given point on the right, excluding the subtraction
of that point from itself. -/
theorem vectorSpan_range_eq_span_range_vsub_right_ne (p : ι → P) (i₀ : ι) :
    vectorSpan k (Set.range p) =
      Submodule.span k (Set.range fun i : { x // x ≠ i₀ } => p i -ᵥ p i₀) :=
  by
  rw [← Set.image_univ, vectorSpan_image_eq_span_vsub_set_right_ne k _ (Set.mem_univ i₀)]
  congr with v
  simp only [Set.mem_range, Set.mem_image, Set.mem_diff, Set.mem_singleton_iff, Subtype.exists,
    Subtype.coe_mk]
  constructor
  · rintro ⟨x, ⟨i₁, ⟨⟨hi₁u, hi₁⟩, rfl⟩⟩, hv⟩
    exact ⟨i₁, hi₁, hv⟩
  · exact fun ⟨i₁, hi₁, hv⟩ => ⟨p i₁, ⟨i₁, ⟨Set.mem_univ _, hi₁⟩, rfl⟩, hv⟩
#align vector_span_range_eq_span_range_vsub_right_ne vectorSpan_range_eq_span_range_vsub_right_ne
-/

section

variable {s : Set P}

#print affineSpan_nonempty /-
/-- The affine span of a set is nonempty if and only if that set is. -/
theorem affineSpan_nonempty : (affineSpan k s : Set P).Nonempty ↔ s.Nonempty :=
  spanPoints_nonempty k s
#align affine_span_nonempty affineSpan_nonempty
-/

alias affineSpan_nonempty ↔ _ _root_.set.nonempty.affine_span
#align set.nonempty.affine_span Set.Nonempty.affineSpan

/-- The affine span of a nonempty set is nonempty. -/
instance [Nonempty s] : Nonempty (affineSpan k s) :=
  ((nonempty_coe_sort.1 ‹_›).affineSpan _).to_subtype

#print affineSpan_eq_bot /-
/-- The affine span of a set is `⊥` if and only if that set is empty. -/
@[simp]
theorem affineSpan_eq_bot : affineSpan k s = ⊥ ↔ s = ∅ := by
  rw [← not_iff_not, ← Ne.def, ← Ne.def, ← nonempty_iff_ne_bot, affineSpan_nonempty,
    nonempty_iff_ne_empty]
#align affine_span_eq_bot affineSpan_eq_bot
-/

#print bot_lt_affineSpan /-
@[simp]
theorem bot_lt_affineSpan : ⊥ < affineSpan k s ↔ s.Nonempty := by
  rw [bot_lt_iff_ne_bot, nonempty_iff_ne_empty]; exact (affineSpan_eq_bot _).Not
#align bot_lt_affine_span bot_lt_affineSpan
-/

end

variable {k}

#print affineSpan_induction /-
/-- An induction principle for span membership. If `p` holds for all elements of `s` and is
preserved under certain affine combinations, then `p` holds for all elements of the span of `s`.
-/
theorem affineSpan_induction {x : P} {s : Set P} {p : P → Prop} (h : x ∈ affineSpan k s)
    (Hs : ∀ x : P, x ∈ s → p x)
    (Hc : ∀ (c : k) (u v w : P), p u → p v → p w → p (c • (u -ᵥ v) +ᵥ w)) : p x :=
  (@affineSpan_le _ _ _ _ _ _ _ _ ⟨p, Hc⟩).mpr Hs h
#align affine_span_induction affineSpan_induction
-/

#print affineSpan_induction' /-
/-- A dependent version of `affine_span_induction`. -/
theorem affineSpan_induction' {s : Set P} {p : ∀ x, x ∈ affineSpan k s → Prop}
    (Hs : ∀ (y) (hys : y ∈ s), p y (subset_affineSpan k _ hys))
    (Hc :
      ∀ (c : k) (u hu v hv w hw),
        p u hu →
          p v hv → p w hw → p (c • (u -ᵥ v) +ᵥ w) (AffineSubspace.smul_vsub_vadd_mem _ _ hu hv hw))
    {x : P} (h : x ∈ affineSpan k s) : p x h :=
  by
  refine' Exists.elim _ fun (hx : x ∈ affineSpan k s) (hc : p x hx) => hc
  refine' @affineSpan_induction k V P _ _ _ _ _ _ _ h _ _
  · exact fun y hy => ⟨subset_affineSpan _ _ hy, Hs y hy⟩
  ·
    exact fun c u v w hu hv hw =>
      Exists.elim hu fun hu' hu =>
        Exists.elim hv fun hv' hv =>
          Exists.elim hw fun hw' hw =>
            ⟨AffineSubspace.smul_vsub_vadd_mem _ _ hu' hv' hw', Hc _ _ _ _ _ _ _ hu hv hw⟩
#align affine_span_induction' affineSpan_induction'
-/

section WithLocalInstance

attribute [local instance] AffineSubspace.toAddTorsor

#print affineSpan_coe_preimage_eq_top /-
/-- A set, considered as a subset of its spanned affine subspace, spans the whole subspace. -/
@[simp]
theorem affineSpan_coe_preimage_eq_top (A : Set P) [Nonempty A] :
    affineSpan k ((coe : affineSpan k A → P) ⁻¹' A) = ⊤ :=
  by
  rw [eq_top_iff]
  rintro ⟨x, hx⟩ -
  refine' affineSpan_induction' (fun y hy => _) (fun c u hu v hv w hw => _) hx
  · exact subset_affineSpan _ _ hy
  · exact AffineSubspace.smul_vsub_vadd_mem _ _
#align affine_span_coe_preimage_eq_top affineSpan_coe_preimage_eq_top
-/

end WithLocalInstance

#print affineSpan_singleton_union_vadd_eq_top_of_span_eq_top /-
/-- Suppose a set of vectors spans `V`.  Then a point `p`, together
with those vectors added to `p`, spans `P`. -/
theorem affineSpan_singleton_union_vadd_eq_top_of_span_eq_top {s : Set V} (p : P)
    (h : Submodule.span k (Set.range (coe : s → V)) = ⊤) :
    affineSpan k ({p} ∪ (fun v => v +ᵥ p) '' s) = ⊤ :=
  by
  convert
    ext_of_direction_eq _
      ⟨p, mem_affineSpan k (Set.mem_union_left _ (Set.mem_singleton _)), mem_top k V p⟩
  rw [direction_affineSpan, direction_top,
    vectorSpan_eq_span_vsub_set_right k (Set.mem_union_left _ (Set.mem_singleton _) : p ∈ _),
    eq_top_iff, ← h]
  apply Submodule.span_mono
  rintro v ⟨v', rfl⟩
  use (v' : V) +ᵥ p
  simp
#align affine_span_singleton_union_vadd_eq_top_of_span_eq_top affineSpan_singleton_union_vadd_eq_top_of_span_eq_top
-/

variable (k)

#print vectorSpan_pair /-
/-- The `vector_span` of two points is the span of their difference. -/
theorem vectorSpan_pair (p₁ p₂ : P) : vectorSpan k ({p₁, p₂} : Set P) = k ∙ p₁ -ᵥ p₂ := by
  rw [vectorSpan_eq_span_vsub_set_left k (mem_insert p₁ _), image_pair, vsub_self,
    Submodule.span_insert_zero]
#align vector_span_pair vectorSpan_pair
-/

#print vectorSpan_pair_rev /-
/-- The `vector_span` of two points is the span of their difference (reversed). -/
theorem vectorSpan_pair_rev (p₁ p₂ : P) : vectorSpan k ({p₁, p₂} : Set P) = k ∙ p₂ -ᵥ p₁ := by
  rw [pair_comm, vectorSpan_pair]
#align vector_span_pair_rev vectorSpan_pair_rev
-/

#print vsub_mem_vectorSpan_pair /-
/-- The difference between two points lies in their `vector_span`. -/
theorem vsub_mem_vectorSpan_pair (p₁ p₂ : P) : p₁ -ᵥ p₂ ∈ vectorSpan k ({p₁, p₂} : Set P) :=
  vsub_mem_vectorSpan _ (Set.mem_insert _ _) (Set.mem_insert_of_mem _ (Set.mem_singleton _))
#align vsub_mem_vector_span_pair vsub_mem_vectorSpan_pair
-/

#print vsub_rev_mem_vectorSpan_pair /-
/-- The difference between two points (reversed) lies in their `vector_span`. -/
theorem vsub_rev_mem_vectorSpan_pair (p₁ p₂ : P) : p₂ -ᵥ p₁ ∈ vectorSpan k ({p₁, p₂} : Set P) :=
  vsub_mem_vectorSpan _ (Set.mem_insert_of_mem _ (Set.mem_singleton _)) (Set.mem_insert _ _)
#align vsub_rev_mem_vector_span_pair vsub_rev_mem_vectorSpan_pair
-/

variable {k}

#print smul_vsub_mem_vectorSpan_pair /-
/-- A multiple of the difference between two points lies in their `vector_span`. -/
theorem smul_vsub_mem_vectorSpan_pair (r : k) (p₁ p₂ : P) :
    r • (p₁ -ᵥ p₂) ∈ vectorSpan k ({p₁, p₂} : Set P) :=
  Submodule.smul_mem _ _ (vsub_mem_vectorSpan_pair k p₁ p₂)
#align smul_vsub_mem_vector_span_pair smul_vsub_mem_vectorSpan_pair
-/

#print smul_vsub_rev_mem_vectorSpan_pair /-
/-- A multiple of the difference between two points (reversed) lies in their `vector_span`. -/
theorem smul_vsub_rev_mem_vectorSpan_pair (r : k) (p₁ p₂ : P) :
    r • (p₂ -ᵥ p₁) ∈ vectorSpan k ({p₁, p₂} : Set P) :=
  Submodule.smul_mem _ _ (vsub_rev_mem_vectorSpan_pair k p₁ p₂)
#align smul_vsub_rev_mem_vector_span_pair smul_vsub_rev_mem_vectorSpan_pair
-/

#print mem_vectorSpan_pair /-
/-- A vector lies in the `vector_span` of two points if and only if it is a multiple of their
difference. -/
theorem mem_vectorSpan_pair {p₁ p₂ : P} {v : V} :
    v ∈ vectorSpan k ({p₁, p₂} : Set P) ↔ ∃ r : k, r • (p₁ -ᵥ p₂) = v := by
  rw [vectorSpan_pair, Submodule.mem_span_singleton]
#align mem_vector_span_pair mem_vectorSpan_pair
-/

#print mem_vectorSpan_pair_rev /-
/-- A vector lies in the `vector_span` of two points if and only if it is a multiple of their
difference (reversed). -/
theorem mem_vectorSpan_pair_rev {p₁ p₂ : P} {v : V} :
    v ∈ vectorSpan k ({p₁, p₂} : Set P) ↔ ∃ r : k, r • (p₂ -ᵥ p₁) = v := by
  rw [vectorSpan_pair_rev, Submodule.mem_span_singleton]
#align mem_vector_span_pair_rev mem_vectorSpan_pair_rev
-/

variable (k)

notation "line[" k ", " p₁ ", " p₂ "]" =>
  affineSpan k (insert p₁ (@singleton _ _ Set.hasSingleton p₂))

#print left_mem_affineSpan_pair /-
/-- The first of two points lies in their affine span. -/
theorem left_mem_affineSpan_pair (p₁ p₂ : P) : p₁ ∈ line[k, p₁, p₂] :=
  mem_affineSpan _ (Set.mem_insert _ _)
#align left_mem_affine_span_pair left_mem_affineSpan_pair
-/

#print right_mem_affineSpan_pair /-
/-- The second of two points lies in their affine span. -/
theorem right_mem_affineSpan_pair (p₁ p₂ : P) : p₂ ∈ line[k, p₁, p₂] :=
  mem_affineSpan _ (Set.mem_insert_of_mem _ (Set.mem_singleton _))
#align right_mem_affine_span_pair right_mem_affineSpan_pair
-/

variable {k}

#print AffineMap.lineMap_mem_affineSpan_pair /-
/-- A combination of two points expressed with `line_map` lies in their affine span. -/
theorem AffineMap.lineMap_mem_affineSpan_pair (r : k) (p₁ p₂ : P) :
    AffineMap.lineMap p₁ p₂ r ∈ line[k, p₁, p₂] :=
  AffineMap.lineMap_mem _ (left_mem_affineSpan_pair _ _ _) (right_mem_affineSpan_pair _ _ _)
#align affine_map.line_map_mem_affine_span_pair AffineMap.lineMap_mem_affineSpan_pair
-/

#print AffineMap.lineMap_rev_mem_affineSpan_pair /-
/-- A combination of two points expressed with `line_map` (with the two points reversed) lies in
their affine span. -/
theorem AffineMap.lineMap_rev_mem_affineSpan_pair (r : k) (p₁ p₂ : P) :
    AffineMap.lineMap p₂ p₁ r ∈ line[k, p₁, p₂] :=
  AffineMap.lineMap_mem _ (right_mem_affineSpan_pair _ _ _) (left_mem_affineSpan_pair _ _ _)
#align affine_map.line_map_rev_mem_affine_span_pair AffineMap.lineMap_rev_mem_affineSpan_pair
-/

#print smul_vsub_vadd_mem_affineSpan_pair /-
/-- A multiple of the difference of two points added to the first point lies in their affine
span. -/
theorem smul_vsub_vadd_mem_affineSpan_pair (r : k) (p₁ p₂ : P) :
    r • (p₂ -ᵥ p₁) +ᵥ p₁ ∈ line[k, p₁, p₂] :=
  AffineMap.lineMap_mem_affineSpan_pair _ _ _
#align smul_vsub_vadd_mem_affine_span_pair smul_vsub_vadd_mem_affineSpan_pair
-/

#print smul_vsub_rev_vadd_mem_affineSpan_pair /-
/-- A multiple of the difference of two points added to the second point lies in their affine
span. -/
theorem smul_vsub_rev_vadd_mem_affineSpan_pair (r : k) (p₁ p₂ : P) :
    r • (p₁ -ᵥ p₂) +ᵥ p₂ ∈ line[k, p₁, p₂] :=
  AffineMap.lineMap_rev_mem_affineSpan_pair _ _ _
#align smul_vsub_rev_vadd_mem_affine_span_pair smul_vsub_rev_vadd_mem_affineSpan_pair
-/

#print vadd_left_mem_affineSpan_pair /-
/-- A vector added to the first point lies in the affine span of two points if and only if it is
a multiple of their difference. -/
theorem vadd_left_mem_affineSpan_pair {p₁ p₂ : P} {v : V} :
    v +ᵥ p₁ ∈ line[k, p₁, p₂] ↔ ∃ r : k, r • (p₂ -ᵥ p₁) = v := by
  rw [vadd_mem_iff_mem_direction _ (left_mem_affineSpan_pair _ _ _), direction_affineSpan,
    mem_vectorSpan_pair_rev]
#align vadd_left_mem_affine_span_pair vadd_left_mem_affineSpan_pair
-/

#print vadd_right_mem_affineSpan_pair /-
/-- A vector added to the second point lies in the affine span of two points if and only if it is
a multiple of their difference. -/
theorem vadd_right_mem_affineSpan_pair {p₁ p₂ : P} {v : V} :
    v +ᵥ p₂ ∈ line[k, p₁, p₂] ↔ ∃ r : k, r • (p₁ -ᵥ p₂) = v := by
  rw [vadd_mem_iff_mem_direction _ (right_mem_affineSpan_pair _ _ _), direction_affineSpan,
    mem_vectorSpan_pair]
#align vadd_right_mem_affine_span_pair vadd_right_mem_affineSpan_pair
-/

#print affineSpan_pair_le_of_mem_of_mem /-
/-- The span of two points that lie in an affine subspace is contained in that subspace. -/
theorem affineSpan_pair_le_of_mem_of_mem {p₁ p₂ : P} {s : AffineSubspace k P} (hp₁ : p₁ ∈ s)
    (hp₂ : p₂ ∈ s) : line[k, p₁, p₂] ≤ s :=
  by
  rw [affineSpan_le, Set.insert_subset_iff, Set.singleton_subset_iff]
  exact ⟨hp₁, hp₂⟩
#align affine_span_pair_le_of_mem_of_mem affineSpan_pair_le_of_mem_of_mem
-/

#print affineSpan_pair_le_of_left_mem /-
/-- One line is contained in another differing in the first point if the first point of the first
line is contained in the second line. -/
theorem affineSpan_pair_le_of_left_mem {p₁ p₂ p₃ : P} (h : p₁ ∈ line[k, p₂, p₃]) :
    line[k, p₁, p₃] ≤ line[k, p₂, p₃] :=
  affineSpan_pair_le_of_mem_of_mem h (right_mem_affineSpan_pair _ _ _)
#align affine_span_pair_le_of_left_mem affineSpan_pair_le_of_left_mem
-/

#print affineSpan_pair_le_of_right_mem /-
/-- One line is contained in another differing in the second point if the second point of the
first line is contained in the second line. -/
theorem affineSpan_pair_le_of_right_mem {p₁ p₂ p₃ : P} (h : p₁ ∈ line[k, p₂, p₃]) :
    line[k, p₂, p₁] ≤ line[k, p₂, p₃] :=
  affineSpan_pair_le_of_mem_of_mem (left_mem_affineSpan_pair _ _ _) h
#align affine_span_pair_le_of_right_mem affineSpan_pair_le_of_right_mem
-/

variable (k)

#print affineSpan_mono /-
/-- `affine_span` is monotone. -/
@[mono]
theorem affineSpan_mono {s₁ s₂ : Set P} (h : s₁ ⊆ s₂) : affineSpan k s₁ ≤ affineSpan k s₂ :=
  spanPoints_subset_coe_of_subset_coe (Set.Subset.trans h (subset_affineSpan k _))
#align affine_span_mono affineSpan_mono
-/

#print affineSpan_insert_affineSpan /-
/-- Taking the affine span of a set, adding a point and taking the
span again produces the same results as adding the point to the set
and taking the span. -/
theorem affineSpan_insert_affineSpan (p : P) (ps : Set P) :
    affineSpan k (insert p (affineSpan k ps : Set P)) = affineSpan k (insert p ps) := by
  rw [Set.insert_eq, Set.insert_eq, span_union, span_union, affine_span_coe]
#align affine_span_insert_affine_span affineSpan_insert_affineSpan
-/

#print affineSpan_insert_eq_affineSpan /-
/-- If a point is in the affine span of a set, adding it to that set
does not change the affine span. -/
theorem affineSpan_insert_eq_affineSpan {p : P} {ps : Set P} (h : p ∈ affineSpan k ps) :
    affineSpan k (insert p ps) = affineSpan k ps :=
  by
  rw [← mem_coe] at h 
  rw [← affineSpan_insert_affineSpan, Set.insert_eq_of_mem h, affine_span_coe]
#align affine_span_insert_eq_affine_span affineSpan_insert_eq_affineSpan
-/

variable {k}

#print vectorSpan_insert_eq_vectorSpan /-
/-- If a point is in the affine span of a set, adding it to that set
does not change the vector span. -/
theorem vectorSpan_insert_eq_vectorSpan {p : P} {ps : Set P} (h : p ∈ affineSpan k ps) :
    vectorSpan k (insert p ps) = vectorSpan k ps := by
  simp_rw [← direction_affineSpan, affineSpan_insert_eq_affineSpan _ h]
#align vector_span_insert_eq_vector_span vectorSpan_insert_eq_vectorSpan
-/

end AffineSpace'

namespace AffineSubspace

variable {k : Type _} {V : Type _} {P : Type _} [Ring k] [AddCommGroup V] [Module k V]
  [affine_space V P]

#print AffineSubspace.direction_sup /-
/-- The direction of the sup of two nonempty affine subspaces is the
sup of the two directions and of any one difference between points in
the two subspaces. -/
theorem direction_sup {s1 s2 : AffineSubspace k P} {p1 p2 : P} (hp1 : p1 ∈ s1) (hp2 : p2 ∈ s2) :
    (s1 ⊔ s2).direction = s1.direction ⊔ s2.direction ⊔ k ∙ p2 -ᵥ p1 :=
  by
  refine' le_antisymm _ _
  · change (affineSpan k ((s1 : Set P) ∪ s2)).direction ≤ _
    rw [← mem_coe] at hp1 
    rw [direction_affineSpan, vectorSpan_eq_span_vsub_set_right k (Set.mem_union_left _ hp1),
      Submodule.span_le]
    rintro v ⟨p3, hp3, rfl⟩
    cases hp3
    · rw [sup_assoc, sup_comm, SetLike.mem_coe, Submodule.mem_sup]
      use 0, Submodule.zero_mem _, p3 -ᵥ p1, vsub_mem_direction hp3 hp1
      rw [zero_add]
    · rw [sup_assoc, SetLike.mem_coe, Submodule.mem_sup]
      use 0, Submodule.zero_mem _, p3 -ᵥ p1
      rw [and_comm', zero_add]
      use rfl
      rw [← vsub_add_vsub_cancel p3 p2 p1, Submodule.mem_sup]
      use p3 -ᵥ p2, vsub_mem_direction hp3 hp2, p2 -ᵥ p1, Submodule.mem_span_singleton_self _
  · refine' sup_le (sup_direction_le _ _) _
    rw [direction_eq_vector_span, vectorSpan_def]
    exact
      sInf_le_sInf fun p hp =>
        Set.Subset.trans
          (Set.singleton_subset_iff.2
            (vsub_mem_vsub (mem_spanPoints k p2 _ (Set.mem_union_right _ hp2))
              (mem_spanPoints k p1 _ (Set.mem_union_left _ hp1))))
          hp
#align affine_subspace.direction_sup AffineSubspace.direction_sup
-/

#print AffineSubspace.direction_affineSpan_insert /-
/-- The direction of the span of the result of adding a point to a
nonempty affine subspace is the sup of the direction of that subspace
and of any one difference between that point and a point in the
subspace. -/
theorem direction_affineSpan_insert {s : AffineSubspace k P} {p1 p2 : P} (hp1 : p1 ∈ s) :
    (affineSpan k (insert p2 (s : Set P))).direction = Submodule.span k {p2 -ᵥ p1} ⊔ s.direction :=
  by
  rw [sup_comm, ← Set.union_singleton, ← coe_affine_span_singleton k V p2]
  change (s ⊔ affineSpan k {p2}).direction = _
  rw [direction_sup hp1 (mem_affineSpan k (Set.mem_singleton _)), direction_affineSpan]
  simp
#align affine_subspace.direction_affine_span_insert AffineSubspace.direction_affineSpan_insert
-/

#print AffineSubspace.mem_affineSpan_insert_iff /-
/-- Given a point `p1` in an affine subspace `s`, and a point `p2`, a
point `p` is in the span of `s` with `p2` added if and only if it is a
multiple of `p2 -ᵥ p1` added to a point in `s`. -/
theorem mem_affineSpan_insert_iff {s : AffineSubspace k P} {p1 : P} (hp1 : p1 ∈ s) (p2 p : P) :
    p ∈ affineSpan k (insert p2 (s : Set P)) ↔
      ∃ (r : k) (p0 : P) (hp0 : p0 ∈ s), p = r • (p2 -ᵥ p1 : V) +ᵥ p0 :=
  by
  rw [← mem_coe] at hp1 
  rw [← vsub_right_mem_direction_iff_mem (mem_affineSpan k (Set.mem_insert_of_mem _ hp1)),
    direction_affine_span_insert hp1, Submodule.mem_sup]
  constructor
  · rintro ⟨v1, hv1, v2, hv2, hp⟩
    rw [Submodule.mem_span_singleton] at hv1 
    rcases hv1 with ⟨r, rfl⟩
    use r, v2 +ᵥ p1, vadd_mem_of_mem_direction hv2 hp1
    symm at hp 
    rw [← sub_eq_zero, ← vsub_vadd_eq_vsub_sub, vsub_eq_zero_iff_eq] at hp 
    rw [hp, vadd_vadd]
  · rintro ⟨r, p3, hp3, rfl⟩
    use r • (p2 -ᵥ p1), Submodule.mem_span_singleton.2 ⟨r, rfl⟩, p3 -ᵥ p1,
      vsub_mem_direction hp3 hp1
    rw [vadd_vsub_assoc, add_comm]
#align affine_subspace.mem_affine_span_insert_iff AffineSubspace.mem_affineSpan_insert_iff
-/

end AffineSubspace

section MapComap

variable {k V₁ P₁ V₂ P₂ V₃ P₃ : Type _} [Ring k]

variable [AddCommGroup V₁] [Module k V₁] [AddTorsor V₁ P₁]

variable [AddCommGroup V₂] [Module k V₂] [AddTorsor V₂ P₂]

variable [AddCommGroup V₃] [Module k V₃] [AddTorsor V₃ P₃]

section

variable (f : P₁ →ᵃ[k] P₂)

#print AffineMap.vectorSpan_image_eq_submodule_map /-
@[simp]
theorem AffineMap.vectorSpan_image_eq_submodule_map {s : Set P₁} :
    Submodule.map f.linear (vectorSpan k s) = vectorSpan k (f '' s) := by
  simp [f.image_vsub_image, vectorSpan_def]
#align affine_map.vector_span_image_eq_submodule_map AffineMap.vectorSpan_image_eq_submodule_map
-/

namespace AffineSubspace

#print AffineSubspace.map /-
/-- The image of an affine subspace under an affine map as an affine subspace. -/
def map (s : AffineSubspace k P₁) : AffineSubspace k P₂
    where
  carrier := f '' s
  smul_vsub_vadd_mem :=
    by
    rintro t - - - ⟨p₁, h₁, rfl⟩ ⟨p₂, h₂, rfl⟩ ⟨p₃, h₃, rfl⟩
    use t • (p₁ -ᵥ p₂) +ᵥ p₃
    suffices t • (p₁ -ᵥ p₂) +ᵥ p₃ ∈ s by simp [this]
    exact s.smul_vsub_vadd_mem t h₁ h₂ h₃
#align affine_subspace.map AffineSubspace.map
-/

#print AffineSubspace.coe_map /-
@[simp]
theorem coe_map (s : AffineSubspace k P₁) : (s.map f : Set P₂) = f '' s :=
  rfl
#align affine_subspace.coe_map AffineSubspace.coe_map
-/

#print AffineSubspace.mem_map /-
@[simp]
theorem mem_map {f : P₁ →ᵃ[k] P₂} {x : P₂} {s : AffineSubspace k P₁} :
    x ∈ s.map f ↔ ∃ y ∈ s, f y = x :=
  mem_image_iff_bex
#align affine_subspace.mem_map AffineSubspace.mem_map
-/

#print AffineSubspace.mem_map_of_mem /-
theorem mem_map_of_mem {x : P₁} {s : AffineSubspace k P₁} (h : x ∈ s) : f x ∈ s.map f :=
  Set.mem_image_of_mem _ h
#align affine_subspace.mem_map_of_mem AffineSubspace.mem_map_of_mem
-/

#print AffineSubspace.mem_map_iff_mem_of_injective /-
theorem mem_map_iff_mem_of_injective {f : P₁ →ᵃ[k] P₂} {x : P₁} {s : AffineSubspace k P₁}
    (hf : Function.Injective f) : f x ∈ s.map f ↔ x ∈ s :=
  hf.mem_set_image
#align affine_subspace.mem_map_iff_mem_of_injective AffineSubspace.mem_map_iff_mem_of_injective
-/

#print AffineSubspace.map_bot /-
@[simp]
theorem map_bot : (⊥ : AffineSubspace k P₁).map f = ⊥ :=
  coe_injective <| image_empty f
#align affine_subspace.map_bot AffineSubspace.map_bot
-/

#print AffineSubspace.map_eq_bot_iff /-
@[simp]
theorem map_eq_bot_iff {s : AffineSubspace k P₁} : s.map f = ⊥ ↔ s = ⊥ :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · rwa [← coe_eq_bot_iff, coe_map, image_eq_empty, coe_eq_bot_iff] at h 
  · rw [h, map_bot]
#align affine_subspace.map_eq_bot_iff AffineSubspace.map_eq_bot_iff
-/

#print AffineSubspace.map_id /-
@[simp]
theorem map_id (s : AffineSubspace k P₁) : s.map (AffineMap.id k P₁) = s :=
  coe_injective <| image_id _
#align affine_subspace.map_id AffineSubspace.map_id
-/

#print AffineSubspace.map_map /-
theorem map_map (s : AffineSubspace k P₁) (f : P₁ →ᵃ[k] P₂) (g : P₂ →ᵃ[k] P₃) :
    (s.map f).map g = s.map (g.comp f) :=
  coe_injective <| image_image _ _ _
#align affine_subspace.map_map AffineSubspace.map_map
-/

#print AffineSubspace.map_direction /-
@[simp]
theorem map_direction (s : AffineSubspace k P₁) : (s.map f).direction = s.direction.map f.linear :=
  by simp [direction_eq_vector_span]
#align affine_subspace.map_direction AffineSubspace.map_direction
-/

#print AffineSubspace.map_span /-
theorem map_span (s : Set P₁) : (affineSpan k s).map f = affineSpan k (f '' s) :=
  by
  rcases s.eq_empty_or_nonempty with (rfl | ⟨p, hp⟩); · simp
  apply ext_of_direction_eq
  · simp [direction_affineSpan]
  ·
    exact
      ⟨f p, mem_image_of_mem f (subset_affineSpan k _ hp),
        subset_affineSpan k _ (mem_image_of_mem f hp)⟩
#align affine_subspace.map_span AffineSubspace.map_span
-/

end AffineSubspace

namespace AffineMap

#print AffineMap.map_top_of_surjective /-
@[simp]
theorem map_top_of_surjective (hf : Function.Surjective f) : AffineSubspace.map f ⊤ = ⊤ :=
  by
  rw [← AffineSubspace.ext_iff]
  exact image_univ_of_surjective hf
#align affine_map.map_top_of_surjective AffineMap.map_top_of_surjective
-/

#print AffineMap.span_eq_top_of_surjective /-
theorem span_eq_top_of_surjective {s : Set P₁} (hf : Function.Surjective f)
    (h : affineSpan k s = ⊤) : affineSpan k (f '' s) = ⊤ := by
  rw [← AffineSubspace.map_span, h, map_top_of_surjective f hf]
#align affine_map.span_eq_top_of_surjective AffineMap.span_eq_top_of_surjective
-/

end AffineMap

namespace AffineEquiv

#print AffineEquiv.span_eq_top_iff /-
theorem span_eq_top_iff {s : Set P₁} (e : P₁ ≃ᵃ[k] P₂) :
    affineSpan k s = ⊤ ↔ affineSpan k (e '' s) = ⊤ :=
  by
  refine' ⟨(e : P₁ →ᵃ[k] P₂).span_eq_top_of_surjective e.surjective, _⟩
  intro h
  have : s = e.symm '' (e '' s) := by simp [← image_comp]
  rw [this]
  exact (e.symm : P₂ →ᵃ[k] P₁).span_eq_top_of_surjective e.symm.surjective h
#align affine_equiv.span_eq_top_iff AffineEquiv.span_eq_top_iff
-/

end AffineEquiv

end

namespace AffineSubspace

#print AffineSubspace.comap /-
/-- The preimage of an affine subspace under an affine map as an affine subspace. -/
def comap (f : P₁ →ᵃ[k] P₂) (s : AffineSubspace k P₂) : AffineSubspace k P₁
    where
  carrier := f ⁻¹' s
  smul_vsub_vadd_mem t p₁ p₂ p₃ (hp₁ : f p₁ ∈ s) (hp₂ : f p₂ ∈ s) (hp₃ : f p₃ ∈ s) :=
    show f _ ∈ s by
      rw [AffineMap.map_vadd, LinearMap.map_smul, AffineMap.linearMap_vsub]
      apply s.smul_vsub_vadd_mem _ hp₁ hp₂ hp₃
#align affine_subspace.comap AffineSubspace.comap
-/

#print AffineSubspace.coe_comap /-
@[simp]
theorem coe_comap (f : P₁ →ᵃ[k] P₂) (s : AffineSubspace k P₂) : (s.comap f : Set P₁) = f ⁻¹' ↑s :=
  rfl
#align affine_subspace.coe_comap AffineSubspace.coe_comap
-/

#print AffineSubspace.mem_comap /-
@[simp]
theorem mem_comap {f : P₁ →ᵃ[k] P₂} {x : P₁} {s : AffineSubspace k P₂} : x ∈ s.comap f ↔ f x ∈ s :=
  Iff.rfl
#align affine_subspace.mem_comap AffineSubspace.mem_comap
-/

#print AffineSubspace.comap_mono /-
theorem comap_mono {f : P₁ →ᵃ[k] P₂} {s t : AffineSubspace k P₂} : s ≤ t → s.comap f ≤ t.comap f :=
  preimage_mono
#align affine_subspace.comap_mono AffineSubspace.comap_mono
-/

#print AffineSubspace.comap_top /-
@[simp]
theorem comap_top {f : P₁ →ᵃ[k] P₂} : (⊤ : AffineSubspace k P₂).comap f = ⊤ := by rw [← ext_iff];
  exact preimage_univ
#align affine_subspace.comap_top AffineSubspace.comap_top
-/

#print AffineSubspace.comap_id /-
@[simp]
theorem comap_id (s : AffineSubspace k P₁) : s.comap (AffineMap.id k P₁) = s :=
  coe_injective rfl
#align affine_subspace.comap_id AffineSubspace.comap_id
-/

#print AffineSubspace.comap_comap /-
theorem comap_comap (s : AffineSubspace k P₃) (f : P₁ →ᵃ[k] P₂) (g : P₂ →ᵃ[k] P₃) :
    (s.comap g).comap f = s.comap (g.comp f) :=
  coe_injective rfl
#align affine_subspace.comap_comap AffineSubspace.comap_comap
-/

#print AffineSubspace.map_le_iff_le_comap /-
-- lemmas about map and comap derived from the galois connection
theorem map_le_iff_le_comap {f : P₁ →ᵃ[k] P₂} {s : AffineSubspace k P₁} {t : AffineSubspace k P₂} :
    s.map f ≤ t ↔ s ≤ t.comap f :=
  image_subset_iff
#align affine_subspace.map_le_iff_le_comap AffineSubspace.map_le_iff_le_comap
-/

#print AffineSubspace.gc_map_comap /-
theorem gc_map_comap (f : P₁ →ᵃ[k] P₂) : GaloisConnection (map f) (comap f) := fun _ _ =>
  map_le_iff_le_comap
#align affine_subspace.gc_map_comap AffineSubspace.gc_map_comap
-/

#print AffineSubspace.map_comap_le /-
theorem map_comap_le (f : P₁ →ᵃ[k] P₂) (s : AffineSubspace k P₂) : (s.comap f).map f ≤ s :=
  (gc_map_comap f).l_u_le _
#align affine_subspace.map_comap_le AffineSubspace.map_comap_le
-/

#print AffineSubspace.le_comap_map /-
theorem le_comap_map (f : P₁ →ᵃ[k] P₂) (s : AffineSubspace k P₁) : s ≤ (s.map f).comap f :=
  (gc_map_comap f).le_u_l _
#align affine_subspace.le_comap_map AffineSubspace.le_comap_map
-/

#print AffineSubspace.map_sup /-
theorem map_sup (s t : AffineSubspace k P₁) (f : P₁ →ᵃ[k] P₂) : (s ⊔ t).map f = s.map f ⊔ t.map f :=
  (gc_map_comap f).l_sup
#align affine_subspace.map_sup AffineSubspace.map_sup
-/

#print AffineSubspace.map_iSup /-
theorem map_iSup {ι : Sort _} (f : P₁ →ᵃ[k] P₂) (s : ι → AffineSubspace k P₁) :
    (iSup s).map f = ⨆ i, (s i).map f :=
  (gc_map_comap f).l_iSup
#align affine_subspace.map_supr AffineSubspace.map_iSup
-/

#print AffineSubspace.comap_inf /-
theorem comap_inf (s t : AffineSubspace k P₂) (f : P₁ →ᵃ[k] P₂) :
    (s ⊓ t).comap f = s.comap f ⊓ t.comap f :=
  (gc_map_comap f).u_inf
#align affine_subspace.comap_inf AffineSubspace.comap_inf
-/

#print AffineSubspace.comap_supr /-
theorem comap_supr {ι : Sort _} (f : P₁ →ᵃ[k] P₂) (s : ι → AffineSubspace k P₂) :
    (iInf s).comap f = ⨅ i, (s i).comap f :=
  (gc_map_comap f).u_iInf
#align affine_subspace.comap_supr AffineSubspace.comap_supr
-/

#print AffineSubspace.comap_symm /-
@[simp]
theorem comap_symm (e : P₁ ≃ᵃ[k] P₂) (s : AffineSubspace k P₁) :
    s.comap (e.symm : P₂ →ᵃ[k] P₁) = s.map e :=
  coe_injective <| e.preimage_symm _
#align affine_subspace.comap_symm AffineSubspace.comap_symm
-/

#print AffineSubspace.map_symm /-
@[simp]
theorem map_symm (e : P₁ ≃ᵃ[k] P₂) (s : AffineSubspace k P₂) :
    s.map (e.symm : P₂ →ᵃ[k] P₁) = s.comap e :=
  coe_injective <| e.image_symm _
#align affine_subspace.map_symm AffineSubspace.map_symm
-/

#print AffineSubspace.comap_span /-
theorem comap_span (f : P₁ ≃ᵃ[k] P₂) (s : Set P₂) :
    (affineSpan k s).comap (f : P₁ →ᵃ[k] P₂) = affineSpan k (f ⁻¹' s) := by
  rw [← map_symm, map_span, AffineEquiv.coe_coe, f.image_symm]
#align affine_subspace.comap_span AffineSubspace.comap_span
-/

end AffineSubspace

end MapComap

namespace AffineSubspace

open AffineEquiv

variable {k : Type _} {V : Type _} {P : Type _} [Ring k] [AddCommGroup V] [Module k V]

variable [affine_space V P]

#print AffineSubspace.Parallel /-
/-- Two affine subspaces are parallel if one is related to the other by adding the same vector
to all points. -/
def Parallel (s₁ s₂ : AffineSubspace k P) : Prop :=
  ∃ v : V, s₂ = s₁.map (constVAdd k P v)
#align affine_subspace.parallel AffineSubspace.Parallel
-/

scoped[Affine] infixl:50 " ∥ " => AffineSubspace.Parallel

#print AffineSubspace.Parallel.symm /-
@[symm]
theorem Parallel.symm {s₁ s₂ : AffineSubspace k P} (h : s₁ ∥ s₂) : s₂ ∥ s₁ :=
  by
  rcases h with ⟨v, rfl⟩
  refine' ⟨-v, _⟩
  rw [map_map, ← coe_trans_to_affine_map, ← const_vadd_add, neg_add_self, const_vadd_zero,
    coe_refl_to_affine_map, map_id]
#align affine_subspace.parallel.symm AffineSubspace.Parallel.symm
-/

#print AffineSubspace.parallel_comm /-
theorem parallel_comm {s₁ s₂ : AffineSubspace k P} : s₁ ∥ s₂ ↔ s₂ ∥ s₁ :=
  ⟨Parallel.symm, Parallel.symm⟩
#align affine_subspace.parallel_comm AffineSubspace.parallel_comm
-/

#print AffineSubspace.Parallel.refl /-
@[refl]
theorem Parallel.refl (s : AffineSubspace k P) : s ∥ s :=
  ⟨0, by simp⟩
#align affine_subspace.parallel.refl AffineSubspace.Parallel.refl
-/

#print AffineSubspace.Parallel.trans /-
@[trans]
theorem Parallel.trans {s₁ s₂ s₃ : AffineSubspace k P} (h₁₂ : s₁ ∥ s₂) (h₂₃ : s₂ ∥ s₃) : s₁ ∥ s₃ :=
  by
  rcases h₁₂ with ⟨v₁₂, rfl⟩
  rcases h₂₃ with ⟨v₂₃, rfl⟩
  refine' ⟨v₂₃ + v₁₂, _⟩
  rw [map_map, ← coe_trans_to_affine_map, ← const_vadd_add]
#align affine_subspace.parallel.trans AffineSubspace.Parallel.trans
-/

#print AffineSubspace.Parallel.direction_eq /-
theorem Parallel.direction_eq {s₁ s₂ : AffineSubspace k P} (h : s₁ ∥ s₂) :
    s₁.direction = s₂.direction := by
  rcases h with ⟨v, rfl⟩
  simp
#align affine_subspace.parallel.direction_eq AffineSubspace.Parallel.direction_eq
-/

#print AffineSubspace.parallel_bot_iff_eq_bot /-
@[simp]
theorem parallel_bot_iff_eq_bot {s : AffineSubspace k P} : s ∥ ⊥ ↔ s = ⊥ :=
  by
  refine' ⟨fun h => _, fun h => h ▸ parallel.refl _⟩
  rcases h with ⟨v, h⟩
  rwa [eq_comm, map_eq_bot_iff] at h 
#align affine_subspace.parallel_bot_iff_eq_bot AffineSubspace.parallel_bot_iff_eq_bot
-/

#print AffineSubspace.bot_parallel_iff_eq_bot /-
@[simp]
theorem bot_parallel_iff_eq_bot {s : AffineSubspace k P} : ⊥ ∥ s ↔ s = ⊥ := by
  rw [parallel_comm, parallel_bot_iff_eq_bot]
#align affine_subspace.bot_parallel_iff_eq_bot AffineSubspace.bot_parallel_iff_eq_bot
-/

#print AffineSubspace.parallel_iff_direction_eq_and_eq_bot_iff_eq_bot /-
theorem parallel_iff_direction_eq_and_eq_bot_iff_eq_bot {s₁ s₂ : AffineSubspace k P} :
    s₁ ∥ s₂ ↔ s₁.direction = s₂.direction ∧ (s₁ = ⊥ ↔ s₂ = ⊥) :=
  by
  refine' ⟨fun h => ⟨h.direction_eq, _, _⟩, fun h => _⟩
  · rintro rfl; exact bot_parallel_iff_eq_bot.1 h
  · rintro rfl; exact parallel_bot_iff_eq_bot.1 h
  · rcases h with ⟨hd, hb⟩
    by_cases hs₁ : s₁ = ⊥
    · rw [hs₁, bot_parallel_iff_eq_bot]
      exact hb.1 hs₁
    · have hs₂ : s₂ ≠ ⊥ := hb.not.1 hs₁
      rcases(nonempty_iff_ne_bot s₁).2 hs₁ with ⟨p₁, hp₁⟩
      rcases(nonempty_iff_ne_bot s₂).2 hs₂ with ⟨p₂, hp₂⟩
      refine' ⟨p₂ -ᵥ p₁, (eq_iff_direction_eq_of_mem hp₂ _).2 _⟩
      · rw [mem_map]
        refine' ⟨p₁, hp₁, _⟩
        simp
      · simpa using hd.symm
#align affine_subspace.parallel_iff_direction_eq_and_eq_bot_iff_eq_bot AffineSubspace.parallel_iff_direction_eq_and_eq_bot_iff_eq_bot
-/

#print AffineSubspace.Parallel.vectorSpan_eq /-
theorem Parallel.vectorSpan_eq {s₁ s₂ : Set P} (h : affineSpan k s₁ ∥ affineSpan k s₂) :
    vectorSpan k s₁ = vectorSpan k s₂ :=
  by
  simp_rw [← direction_affineSpan]
  exact h.direction_eq
#align affine_subspace.parallel.vector_span_eq AffineSubspace.Parallel.vectorSpan_eq
-/

#print AffineSubspace.affineSpan_parallel_iff_vectorSpan_eq_and_eq_empty_iff_eq_empty /-
theorem affineSpan_parallel_iff_vectorSpan_eq_and_eq_empty_iff_eq_empty {s₁ s₂ : Set P} :
    affineSpan k s₁ ∥ affineSpan k s₂ ↔ vectorSpan k s₁ = vectorSpan k s₂ ∧ (s₁ = ∅ ↔ s₂ = ∅) :=
  by
  simp_rw [← direction_affineSpan, ← affineSpan_eq_bot k]
  exact parallel_iff_direction_eq_and_eq_bot_iff_eq_bot
#align affine_subspace.affine_span_parallel_iff_vector_span_eq_and_eq_empty_iff_eq_empty AffineSubspace.affineSpan_parallel_iff_vectorSpan_eq_and_eq_empty_iff_eq_empty
-/

#print AffineSubspace.affineSpan_pair_parallel_iff_vectorSpan_eq /-
theorem affineSpan_pair_parallel_iff_vectorSpan_eq {p₁ p₂ p₃ p₄ : P} :
    line[k, p₁, p₂] ∥ line[k, p₃, p₄] ↔
      vectorSpan k ({p₁, p₂} : Set P) = vectorSpan k ({p₃, p₄} : Set P) :=
  by
  simp [affine_span_parallel_iff_vector_span_eq_and_eq_empty_iff_eq_empty, ←
    not_nonempty_iff_eq_empty]
#align affine_subspace.affine_span_pair_parallel_iff_vector_span_eq AffineSubspace.affineSpan_pair_parallel_iff_vectorSpan_eq
-/

end AffineSubspace

