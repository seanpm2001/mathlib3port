/-
Copyright (c) 2020 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers

! This file was ported from Lean 3 source module linear_algebra.affine_space.finite_dimensional
! leanprover-community/mathlib commit 9aba7801eeecebb61f58a5763c2b6dd1b47dc6ef
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.AffineSpace.Independent
import Mathbin.LinearAlgebra.FiniteDimensional

/-!
# Finite-dimensional subspaces of affine spaces.

This file provides a few results relating to finite-dimensional
subspaces of affine spaces.

## Main definitions

* `collinear` defines collinear sets of points as those that span a
  subspace of dimension at most 1.

-/


noncomputable section

open BigOperators Affine

section AffineSpace'

variable (k : Type _) {V : Type _} {P : Type _}

variable {ι : Type _}

include V

open AffineSubspace FiniteDimensional Module

variable [DivisionRing k] [AddCommGroup V] [Module k V] [affine_space V P]

/-- The `vector_span` of a finite set is finite-dimensional. -/
theorem finite_dimensional_vector_span_of_finite {s : Set P} (h : Set.Finite s) :
    FiniteDimensional k (vectorSpan k s) :=
  span_of_finite k <| h.vsub h
#align finite_dimensional_vector_span_of_finite finite_dimensional_vector_span_of_finite

/-- The `vector_span` of a family indexed by a `fintype` is
finite-dimensional. -/
instance finite_dimensional_vector_span_range [Finite ι] (p : ι → P) :
    FiniteDimensional k (vectorSpan k (Set.range p)) :=
  finite_dimensional_vector_span_of_finite k (Set.finite_range _)
#align finite_dimensional_vector_span_range finite_dimensional_vector_span_range

/-- The `vector_span` of a subset of a family indexed by a `fintype`
is finite-dimensional. -/
instance finite_dimensional_vector_span_image_of_finite [Finite ι] (p : ι → P) (s : Set ι) :
    FiniteDimensional k (vectorSpan k (p '' s)) :=
  finite_dimensional_vector_span_of_finite k (Set.to_finite _)
#align finite_dimensional_vector_span_image_of_finite finite_dimensional_vector_span_image_of_finite

/-- The direction of the affine span of a finite set is
finite-dimensional. -/
theorem finite_dimensional_direction_affine_span_of_finite {s : Set P} (h : Set.Finite s) :
    FiniteDimensional k (affineSpan k s).direction :=
  (direction_affine_span k s).symm ▸ finite_dimensional_vector_span_of_finite k h
#align
  finite_dimensional_direction_affine_span_of_finite finite_dimensional_direction_affine_span_of_finite

/-- The direction of the affine span of a family indexed by a
`fintype` is finite-dimensional. -/
instance finite_dimensional_direction_affine_span_range [Finite ι] (p : ι → P) :
    FiniteDimensional k (affineSpan k (Set.range p)).direction :=
  finite_dimensional_direction_affine_span_of_finite k (Set.finite_range _)
#align finite_dimensional_direction_affine_span_range finite_dimensional_direction_affine_span_range

/-- The direction of the affine span of a subset of a family indexed
by a `fintype` is finite-dimensional. -/
instance finite_dimensional_direction_affine_span_image_of_finite [Finite ι] (p : ι → P)
    (s : Set ι) : FiniteDimensional k (affineSpan k (p '' s)).direction :=
  finite_dimensional_direction_affine_span_of_finite k (Set.to_finite _)
#align
  finite_dimensional_direction_affine_span_image_of_finite finite_dimensional_direction_affine_span_image_of_finite

/-- An affine-independent family of points in a finite-dimensional affine space is finite. -/
theorem finite_of_fin_dim_affine_independent [FiniteDimensional k V] {p : ι → P}
    (hi : AffineIndependent k p) : Finite ι :=
  by
  nontriviality ι; inhabit ι
  rw [affine_independent_iff_linear_independent_vsub k p default] at hi
  letI : IsNoetherian k V := IsNoetherian.iff_fg.2 inferInstance
  exact
    (Set.finite_singleton default).finite_of_compl (Set.finite_coe_iff.1 hi.finite_of_is_noetherian)
#align finite_of_fin_dim_affine_independent finite_of_fin_dim_affine_independent

/-- An affine-independent subset of a finite-dimensional affine space is finite. -/
theorem finite_set_of_fin_dim_affine_independent [FiniteDimensional k V] {s : Set ι} {f : s → P}
    (hi : AffineIndependent k f) : s.Finite :=
  @Set.to_finite _ s (finite_of_fin_dim_affine_independent k hi)
#align finite_set_of_fin_dim_affine_independent finite_set_of_fin_dim_affine_independent

open Classical

variable {k}

/-- The `vector_span` of a finite subset of an affinely independent
family has dimension one less than its cardinality. -/
theorem AffineIndependent.finrank_vector_span_image_finset {p : ι → P} (hi : AffineIndependent k p)
    {s : Finset ι} {n : ℕ} (hc : Finset.card s = n + 1) :
    finrank k (vectorSpan k (s.image p : Set P)) = n :=
  by
  have hi' := hi.range.mono (Set.image_subset_range p ↑s)
  have hc' : (s.image p).card = n + 1 := by rwa [s.card_image_of_injective hi.injective]
  have hn : (s.image p).Nonempty := by simp [hc', ← Finset.card_pos]
  rcases hn with ⟨p₁, hp₁⟩
  have hp₁' : p₁ ∈ p '' s := by simpa using hp₁
  rw [affine_independent_set_iff_linear_independent_vsub k hp₁', ← Finset.coe_singleton, ←
    Finset.coe_image, ← Finset.coe_sdiff, Finset.sdiff_singleton_eq_erase, ← Finset.coe_image] at
    hi'
  have hc : (Finset.image (fun p : P => p -ᵥ p₁) ((Finset.image p s).erase p₁)).card = n :=
    by
    rw [Finset.card_image_of_injective _ (vsub_left_injective _), Finset.card_erase_of_mem hp₁]
    exact Nat.pred_eq_of_eq_succ hc'
  rwa [vector_span_eq_span_vsub_finset_right_ne k hp₁, finrank_span_finset_eq_card, hc]
#align
  affine_independent.finrank_vector_span_image_finset AffineIndependent.finrank_vector_span_image_finset

/-- The `vector_span` of a finite affinely independent family has
dimension one less than its cardinality. -/
theorem AffineIndependent.finrank_vector_span [Fintype ι] {p : ι → P} (hi : AffineIndependent k p)
    {n : ℕ} (hc : Fintype.card ι = n + 1) : finrank k (vectorSpan k (Set.range p)) = n :=
  by
  rw [← Finset.card_univ] at hc
  rw [← Set.image_univ, ← Finset.coe_univ, ← Finset.coe_image]
  exact hi.finrank_vector_span_image_finset hc
#align affine_independent.finrank_vector_span AffineIndependent.finrank_vector_span

/-- The `vector_span` of a finite affinely independent family whose
cardinality is one more than that of the finite-dimensional space is
`⊤`. -/
theorem AffineIndependent.vector_span_eq_top_of_card_eq_finrank_add_one [FiniteDimensional k V]
    [Fintype ι] {p : ι → P} (hi : AffineIndependent k p) (hc : Fintype.card ι = finrank k V + 1) :
    vectorSpan k (Set.range p) = ⊤ :=
  eq_top_of_finrank_eq <| hi.finrank_vector_span hc
#align
  affine_independent.vector_span_eq_top_of_card_eq_finrank_add_one AffineIndependent.vector_span_eq_top_of_card_eq_finrank_add_one

variable (k)

/-- The `vector_span` of `n + 1` points in an indexed family has
dimension at most `n`. -/
theorem finrank_vector_span_image_finset_le (p : ι → P) (s : Finset ι) {n : ℕ}
    (hc : Finset.card s = n + 1) : finrank k (vectorSpan k (s.image p : Set P)) ≤ n :=
  by
  have hn : (s.image p).Nonempty :=
    by
    rw [Finset.Nonempty.image_iff, ← Finset.card_pos, hc]
    apply Nat.succ_pos
  rcases hn with ⟨p₁, hp₁⟩
  rw [vector_span_eq_span_vsub_finset_right_ne k hp₁]
  refine' le_trans (finrank_span_finset_le_card (((s.image p).erase p₁).image fun p => p -ᵥ p₁)) _
  rw [Finset.card_image_of_injective _ (vsub_left_injective p₁), Finset.card_erase_of_mem hp₁,
    tsub_le_iff_right, ← hc]
  apply Finset.card_image_le
#align finrank_vector_span_image_finset_le finrank_vector_span_image_finset_le

/-- The `vector_span` of an indexed family of `n + 1` points has
dimension at most `n`. -/
theorem finrank_vector_span_range_le [Fintype ι] (p : ι → P) {n : ℕ} (hc : Fintype.card ι = n + 1) :
    finrank k (vectorSpan k (Set.range p)) ≤ n :=
  by
  rw [← Set.image_univ, ← Finset.coe_univ, ← Finset.coe_image]
  rw [← Finset.card_univ] at hc
  exact finrank_vector_span_image_finset_le _ _ _ hc
#align finrank_vector_span_range_le finrank_vector_span_range_le

/-- `n + 1` points are affinely independent if and only if their
`vector_span` has dimension `n`. -/
theorem affine_independent_iff_finrank_vector_span_eq [Fintype ι] (p : ι → P) {n : ℕ}
    (hc : Fintype.card ι = n + 1) :
    AffineIndependent k p ↔ finrank k (vectorSpan k (Set.range p)) = n :=
  by
  have hn : Nonempty ι := by simp [← Fintype.card_pos_iff, hc]
  cases' hn with i₁
  rw [affine_independent_iff_linear_independent_vsub _ _ i₁,
    linear_independent_iff_card_eq_finrank_span, eq_comm,
    vector_span_range_eq_span_range_vsub_right_ne k p i₁]
  congr
  rw [← Finset.card_univ] at hc
  rw [Fintype.subtype_card]
  simp [Finset.filter_ne', Finset.card_erase_of_mem, hc]
#align affine_independent_iff_finrank_vector_span_eq affine_independent_iff_finrank_vector_span_eq

/-- `n + 1` points are affinely independent if and only if their
`vector_span` has dimension at least `n`. -/
theorem affine_independent_iff_le_finrank_vector_span [Fintype ι] (p : ι → P) {n : ℕ}
    (hc : Fintype.card ι = n + 1) :
    AffineIndependent k p ↔ n ≤ finrank k (vectorSpan k (Set.range p)) :=
  by
  rw [affine_independent_iff_finrank_vector_span_eq k p hc]
  constructor
  · rintro rfl
    rfl
  · exact fun hle => le_antisymm (finrank_vector_span_range_le k p hc) hle
#align affine_independent_iff_le_finrank_vector_span affine_independent_iff_le_finrank_vector_span

/-- `n + 2` points are affinely independent if and only if their
`vector_span` does not have dimension at most `n`. -/
theorem affine_independent_iff_not_finrank_vector_span_le [Fintype ι] (p : ι → P) {n : ℕ}
    (hc : Fintype.card ι = n + 2) :
    AffineIndependent k p ↔ ¬finrank k (vectorSpan k (Set.range p)) ≤ n := by
  rw [affine_independent_iff_le_finrank_vector_span k p hc, ← Nat.lt_iff_add_one_le, lt_iff_not_ge]
#align
  affine_independent_iff_not_finrank_vector_span_le affine_independent_iff_not_finrank_vector_span_le

/-- `n + 2` points have a `vector_span` with dimension at most `n` if
and only if they are not affinely independent. -/
theorem finrank_vector_span_le_iff_not_affine_independent [Fintype ι] (p : ι → P) {n : ℕ}
    (hc : Fintype.card ι = n + 2) :
    finrank k (vectorSpan k (Set.range p)) ≤ n ↔ ¬AffineIndependent k p :=
  (not_iff_comm.1 (affine_independent_iff_not_finrank_vector_span_le k p hc).symm).symm
#align
  finrank_vector_span_le_iff_not_affine_independent finrank_vector_span_le_iff_not_affine_independent

variable {k}

/-- If the `vector_span` of a finite subset of an affinely independent
family lies in a submodule with dimension one less than its
cardinality, it equals that submodule. -/
theorem AffineIndependent.vector_span_image_finset_eq_of_le_of_card_eq_finrank_add_one {p : ι → P}
    (hi : AffineIndependent k p) {s : Finset ι} {sm : Submodule k V} [FiniteDimensional k sm]
    (hle : vectorSpan k (s.image p : Set P) ≤ sm) (hc : Finset.card s = finrank k sm + 1) :
    vectorSpan k (s.image p : Set P) = sm :=
  eq_of_le_of_finrank_eq hle <| hi.finrank_vector_span_image_finset hc
#align
  affine_independent.vector_span_image_finset_eq_of_le_of_card_eq_finrank_add_one AffineIndependent.vector_span_image_finset_eq_of_le_of_card_eq_finrank_add_one

/-- If the `vector_span` of a finite affinely independent
family lies in a submodule with dimension one less than its
cardinality, it equals that submodule. -/
theorem AffineIndependent.vector_span_eq_of_le_of_card_eq_finrank_add_one [Fintype ι] {p : ι → P}
    (hi : AffineIndependent k p) {sm : Submodule k V} [FiniteDimensional k sm]
    (hle : vectorSpan k (Set.range p) ≤ sm) (hc : Fintype.card ι = finrank k sm + 1) :
    vectorSpan k (Set.range p) = sm :=
  eq_of_le_of_finrank_eq hle <| hi.finrank_vector_span hc
#align
  affine_independent.vector_span_eq_of_le_of_card_eq_finrank_add_one AffineIndependent.vector_span_eq_of_le_of_card_eq_finrank_add_one

/-- If the `affine_span` of a finite subset of an affinely independent
family lies in an affine subspace whose direction has dimension one
less than its cardinality, it equals that subspace. -/
theorem AffineIndependent.affine_span_image_finset_eq_of_le_of_card_eq_finrank_add_one {p : ι → P}
    (hi : AffineIndependent k p) {s : Finset ι} {sp : AffineSubspace k P}
    [FiniteDimensional k sp.direction] (hle : affineSpan k (s.image p : Set P) ≤ sp)
    (hc : Finset.card s = finrank k sp.direction + 1) : affineSpan k (s.image p : Set P) = sp :=
  by
  have hn : (s.image p).Nonempty :=
    by
    rw [Finset.Nonempty.image_iff, ← Finset.card_pos, hc]
    apply Nat.succ_pos
  refine' eq_of_direction_eq_of_nonempty_of_le _ ((affine_span_nonempty k _).2 hn) hle
  have hd := direction_le hle
  rw [direction_affine_span] at hd⊢
  exact hi.vector_span_image_finset_eq_of_le_of_card_eq_finrank_add_one hd hc
#align
  affine_independent.affine_span_image_finset_eq_of_le_of_card_eq_finrank_add_one AffineIndependent.affine_span_image_finset_eq_of_le_of_card_eq_finrank_add_one

/-- If the `affine_span` of a finite affinely independent family lies
in an affine subspace whose direction has dimension one less than its
cardinality, it equals that subspace. -/
theorem AffineIndependent.affine_span_eq_of_le_of_card_eq_finrank_add_one [Fintype ι] {p : ι → P}
    (hi : AffineIndependent k p) {sp : AffineSubspace k P} [FiniteDimensional k sp.direction]
    (hle : affineSpan k (Set.range p) ≤ sp) (hc : Fintype.card ι = finrank k sp.direction + 1) :
    affineSpan k (Set.range p) = sp :=
  by
  rw [← Finset.card_univ] at hc
  rw [← Set.image_univ, ← Finset.coe_univ, ← Finset.coe_image] at hle⊢
  exact hi.affine_span_image_finset_eq_of_le_of_card_eq_finrank_add_one hle hc
#align
  affine_independent.affine_span_eq_of_le_of_card_eq_finrank_add_one AffineIndependent.affine_span_eq_of_le_of_card_eq_finrank_add_one

/-- The `affine_span` of a finite affinely independent family is `⊤` iff the
family's cardinality is one more than that of the finite-dimensional space. -/
theorem AffineIndependent.affine_span_eq_top_iff_card_eq_finrank_add_one [FiniteDimensional k V]
    [Fintype ι] {p : ι → P} (hi : AffineIndependent k p) :
    affineSpan k (Set.range p) = ⊤ ↔ Fintype.card ι = finrank k V + 1 :=
  by
  constructor
  · intro h_tot
    let n := Fintype.card ι - 1
    have hn : Fintype.card ι = n + 1 :=
      (Nat.succ_pred_eq_of_pos (card_pos_of_affine_span_eq_top k V P h_tot)).symm
    rw [hn, ← finrank_top, ← (vector_span_eq_top_of_affine_span_eq_top k V P) h_tot, ←
      hi.finrank_vector_span hn]
  · intro hc
    rw [← finrank_top, ← direction_top k V P] at hc
    exact hi.affine_span_eq_of_le_of_card_eq_finrank_add_one le_top hc
#align
  affine_independent.affine_span_eq_top_iff_card_eq_finrank_add_one AffineIndependent.affine_span_eq_top_iff_card_eq_finrank_add_one

/-- The `vector_span` of adding a point to a finite-dimensional subspace is finite-dimensional. -/
instance finite_dimensional_vector_span_insert (s : AffineSubspace k P)
    [FiniteDimensional k s.direction] (p : P) :
    FiniteDimensional k (vectorSpan k (insert p (s : Set P))) :=
  by
  rw [← direction_affine_span, ← affine_span_insert_affine_span]
  rcases(s : Set P).eq_empty_or_nonempty with (hs | ⟨p₀, hp₀⟩)
  · rw [coe_eq_bot_iff] at hs
    rw [hs, bot_coe, span_empty, bot_coe, direction_affine_span]
    convert finite_dimensional_bot _ _ <;> simp
  · rw [affine_span_coe, direction_affine_span_insert hp₀]
    infer_instance
#align finite_dimensional_vector_span_insert finite_dimensional_vector_span_insert

/-- The direction of the affine span of adding a point to a finite-dimensional subspace is
finite-dimensional. -/
instance finite_dimensional_direction_affine_span_insert (s : AffineSubspace k P)
    [FiniteDimensional k s.direction] (p : P) :
    FiniteDimensional k (affineSpan k (insert p (s : Set P))).direction :=
  (direction_affine_span k (insert p (s : Set P))).symm ▸ finite_dimensional_vector_span_insert s p
#align
  finite_dimensional_direction_affine_span_insert finite_dimensional_direction_affine_span_insert

variable (k)

/-- The `vector_span` of adding a point to a set with a finite-dimensional `vector_span` is
finite-dimensional. -/
instance finite_dimensional_vector_span_insert_set (s : Set P)
    [FiniteDimensional k (vectorSpan k s)] (p : P) :
    FiniteDimensional k (vectorSpan k (insert p s)) :=
  by
  haveI : FiniteDimensional k (affineSpan k s).direction :=
    (direction_affine_span k s).symm ▸ inferInstance
  rw [← direction_affine_span, ← affine_span_insert_affine_span, direction_affine_span]
  exact finite_dimensional_vector_span_insert (affineSpan k s) p
#align finite_dimensional_vector_span_insert_set finite_dimensional_vector_span_insert_set

/-- A set of points is collinear if their `vector_span` has dimension
at most `1`. -/
def Collinear (s : Set P) : Prop :=
  Module.rank k (vectorSpan k s) ≤ 1
#align collinear Collinear

/-- The definition of `collinear`. -/
theorem collinear_iff_dim_le_one (s : Set P) : Collinear k s ↔ Module.rank k (vectorSpan k s) ≤ 1 :=
  Iff.rfl
#align collinear_iff_dim_le_one collinear_iff_dim_le_one

variable {k}

/-- A set of points, whose `vector_span` is finite-dimensional, is
collinear if and only if their `vector_span` has dimension at most
`1`. -/
theorem collinear_iff_finrank_le_one {s : Set P} [FiniteDimensional k (vectorSpan k s)] :
    Collinear k s ↔ finrank k (vectorSpan k s) ≤ 1 :=
  by
  have h := collinear_iff_dim_le_one k s
  rw [← finrank_eq_dim] at h
  exact_mod_cast h
#align collinear_iff_finrank_le_one collinear_iff_finrank_le_one

alias collinear_iff_finrank_le_one ↔ Collinear.finrank_le_one _

/-- A subset of a collinear set is collinear. -/
theorem Collinear.subset {s₁ s₂ : Set P} (hs : s₁ ⊆ s₂) (h : Collinear k s₂) : Collinear k s₁ :=
  (dim_le_of_submodule (vectorSpan k s₁) (vectorSpan k s₂) (vector_span_mono k hs)).trans h
#align collinear.subset Collinear.subset

/-- The `vector_span` of collinear points is finite-dimensional. -/
theorem Collinear.finite_dimensional_vector_span {s : Set P} (h : Collinear k s) :
    FiniteDimensional k (vectorSpan k s) :=
  IsNoetherian.iff_fg.1
    (IsNoetherian.iff_dim_lt_aleph_0.2 (lt_of_le_of_lt h Cardinal.one_lt_aleph_0))
#align collinear.finite_dimensional_vector_span Collinear.finite_dimensional_vector_span

/-- The direction of the affine span of collinear points is finite-dimensional. -/
theorem Collinear.finite_dimensional_direction_affine_span {s : Set P} (h : Collinear k s) :
    FiniteDimensional k (affineSpan k s).direction :=
  (direction_affine_span k s).symm ▸ h.finite_dimensional_vector_span
#align
  collinear.finite_dimensional_direction_affine_span Collinear.finite_dimensional_direction_affine_span

variable (k P)

/-- The empty set is collinear. -/
theorem collinear_empty : Collinear k (∅ : Set P) :=
  by
  rw [collinear_iff_dim_le_one, vector_span_empty]
  simp
#align collinear_empty collinear_empty

variable {P}

/-- A single point is collinear. -/
theorem collinear_singleton (p : P) : Collinear k ({p} : Set P) :=
  by
  rw [collinear_iff_dim_le_one, vector_span_singleton]
  simp
#align collinear_singleton collinear_singleton

variable {k}

/-- Given a point `p₀` in a set of points, that set is collinear if and
only if the points can all be expressed as multiples of the same
vector, added to `p₀`. -/
theorem collinear_iff_of_mem {s : Set P} {p₀ : P} (h : p₀ ∈ s) :
    Collinear k s ↔ ∃ v : V, ∀ p ∈ s, ∃ r : k, p = r • v +ᵥ p₀ :=
  by
  simp_rw [collinear_iff_dim_le_one, dim_submodule_le_one_iff', Submodule.le_span_singleton_iff]
  constructor
  · rintro ⟨v₀, hv⟩
    use v₀
    intro p hp
    obtain ⟨r, hr⟩ := hv (p -ᵥ p₀) (vsub_mem_vector_span k hp h)
    use r
    rw [eq_vadd_iff_vsub_eq]
    exact hr.symm
  · rintro ⟨v, hp₀v⟩
    use v
    intro w hw
    have hs : vectorSpan k s ≤ k ∙ v :=
      by
      rw [vector_span_eq_span_vsub_set_right k h, Submodule.span_le, Set.subset_def]
      intro x hx
      rw [SetLike.mem_coe, Submodule.mem_span_singleton]
      rw [Set.mem_image] at hx
      rcases hx with ⟨p, hp, rfl⟩
      rcases hp₀v p hp with ⟨r, rfl⟩
      use r
      simp
    have hw' := SetLike.le_def.1 hs hw
    rwa [Submodule.mem_span_singleton] at hw'
#align collinear_iff_of_mem collinear_iff_of_mem

/-- A set of points is collinear if and only if they can all be
expressed as multiples of the same vector, added to the same base
point. -/
theorem collinear_iff_exists_forall_eq_smul_vadd (s : Set P) :
    Collinear k s ↔ ∃ (p₀ : P)(v : V), ∀ p ∈ s, ∃ r : k, p = r • v +ᵥ p₀ :=
  by
  rcases Set.eq_empty_or_nonempty s with (rfl | ⟨⟨p₁, hp₁⟩⟩)
  · simp [collinear_empty]
  · rw [collinear_iff_of_mem hp₁]
    constructor
    · exact fun h => ⟨p₁, h⟩
    · rintro ⟨p, v, hv⟩
      use v
      intro p₂ hp₂
      rcases hv p₂ hp₂ with ⟨r, rfl⟩
      rcases hv p₁ hp₁ with ⟨r₁, rfl⟩
      use r - r₁
      simp [vadd_vadd, ← add_smul]
#align collinear_iff_exists_forall_eq_smul_vadd collinear_iff_exists_forall_eq_smul_vadd

variable (k)

/-- Two points are collinear. -/
theorem collinear_pair (p₁ p₂ : P) : Collinear k ({p₁, p₂} : Set P) :=
  by
  rw [collinear_iff_exists_forall_eq_smul_vadd]
  use p₁, p₂ -ᵥ p₁
  intro p hp
  rw [Set.mem_insert_iff, Set.mem_singleton_iff] at hp
  cases hp
  · use 0
    simp [hp]
  · use 1
    simp [hp]
#align collinear_pair collinear_pair

variable {k}

/-- Three points are affinely independent if and only if they are not
collinear. -/
theorem affine_independent_iff_not_collinear {p : Fin 3 → P} :
    AffineIndependent k p ↔ ¬Collinear k (Set.range p) := by
  rw [collinear_iff_finrank_le_one,
    affine_independent_iff_not_finrank_vector_span_le k p (Fintype.card_fin 3)]
#align affine_independent_iff_not_collinear affine_independent_iff_not_collinear

/-- Three points are collinear if and only if they are not affinely
independent. -/
theorem collinear_iff_not_affine_independent {p : Fin 3 → P} :
    Collinear k (Set.range p) ↔ ¬AffineIndependent k p := by
  rw [collinear_iff_finrank_le_one,
    finrank_vector_span_le_iff_not_affine_independent k p (Fintype.card_fin 3)]
#align collinear_iff_not_affine_independent collinear_iff_not_affine_independent

/-- Three points are affinely independent if and only if they are not collinear. -/
theorem affine_independent_iff_not_collinear_set {p₁ p₂ p₃ : P} :
    AffineIndependent k ![p₁, p₂, p₃] ↔ ¬Collinear k ({p₁, p₂, p₃} : Set P) := by
  simp [affine_independent_iff_not_collinear, -Set.union_singleton]
#align affine_independent_iff_not_collinear_set affine_independent_iff_not_collinear_set

/-- Three points are collinear if and only if they are not affinely independent. -/
theorem collinear_iff_not_affine_independent_set {p₁ p₂ p₃ : P} :
    Collinear k ({p₁, p₂, p₃} : Set P) ↔ ¬AffineIndependent k ![p₁, p₂, p₃] :=
  affine_independent_iff_not_collinear_set.not_left.symm
#align collinear_iff_not_affine_independent_set collinear_iff_not_affine_independent_set

/-- Three points are affinely independent if and only if they are not collinear. -/
theorem affine_independent_iff_not_collinear_of_ne {p : Fin 3 → P} {i₁ i₂ i₃ : Fin 3}
    (h₁₂ : i₁ ≠ i₂) (h₁₃ : i₁ ≠ i₃) (h₂₃ : i₂ ≠ i₃) :
    AffineIndependent k p ↔ ¬Collinear k ({p i₁, p i₂, p i₃} : Set P) :=
  by
  have hu : (Finset.univ : Finset (Fin 3)) = {i₁, i₂, i₃} := by decide!
  rw [affine_independent_iff_not_collinear, ← Set.image_univ, ← Finset.coe_univ, hu,
    Finset.coe_insert, Finset.coe_insert, Finset.coe_singleton, Set.image_insert_eq, Set.image_pair]
#align affine_independent_iff_not_collinear_of_ne affine_independent_iff_not_collinear_of_ne

/-- Three points are collinear if and only if they are not affinely independent. -/
theorem collinear_iff_not_affine_independent_of_ne {p : Fin 3 → P} {i₁ i₂ i₃ : Fin 3}
    (h₁₂ : i₁ ≠ i₂) (h₁₃ : i₁ ≠ i₃) (h₂₃ : i₂ ≠ i₃) :
    Collinear k ({p i₁, p i₂, p i₃} : Set P) ↔ ¬AffineIndependent k p :=
  (affine_independent_iff_not_collinear_of_ne h₁₂ h₁₃ h₂₃).not_left.symm
#align collinear_iff_not_affine_independent_of_ne collinear_iff_not_affine_independent_of_ne

/-- If three points are not collinear, the first and second are different. -/
theorem ne₁₂_of_not_collinear {p₁ p₂ p₃ : P} (h : ¬Collinear k ({p₁, p₂, p₃} : Set P)) : p₁ ≠ p₂ :=
  by
  rintro rfl
  simpa [collinear_pair] using h
#align ne₁₂_of_not_collinear ne₁₂_of_not_collinear

/-- If three points are not collinear, the first and third are different. -/
theorem ne₁₃_of_not_collinear {p₁ p₂ p₃ : P} (h : ¬Collinear k ({p₁, p₂, p₃} : Set P)) : p₁ ≠ p₃ :=
  by
  rintro rfl
  simpa [collinear_pair] using h
#align ne₁₃_of_not_collinear ne₁₃_of_not_collinear

/-- If three points are not collinear, the second and third are different. -/
theorem ne₂₃_of_not_collinear {p₁ p₂ p₃ : P} (h : ¬Collinear k ({p₁, p₂, p₃} : Set P)) : p₂ ≠ p₃ :=
  by
  rintro rfl
  simpa [collinear_pair] using h
#align ne₂₃_of_not_collinear ne₂₃_of_not_collinear

/-- A point in a collinear set of points lies in the affine span of any two distinct points of
that set. -/
theorem Collinear.mem_affine_span_of_mem_of_ne {s : Set P} (h : Collinear k s) {p₁ p₂ p₃ : P}
    (hp₁ : p₁ ∈ s) (hp₂ : p₂ ∈ s) (hp₃ : p₃ ∈ s) (hp₁p₂ : p₁ ≠ p₂) : p₃ ∈ line[k, p₁, p₂] :=
  by
  rw [collinear_iff_of_mem hp₁] at h
  rcases h with ⟨v, h⟩
  rcases h p₂ hp₂ with ⟨r₂, rfl⟩
  rcases h p₃ hp₃ with ⟨r₃, rfl⟩
  rw [vadd_left_mem_affine_span_pair]
  refine' ⟨r₃ / r₂, _⟩
  have h₂ : r₂ ≠ 0 := by
    rintro rfl
    simpa using hp₁p₂
  simp [smul_smul, h₂]
#align collinear.mem_affine_span_of_mem_of_ne Collinear.mem_affine_span_of_mem_of_ne

/-- The affine span of any two distinct points of a collinear set of points equals the affine
span of the whole set. -/
theorem Collinear.affine_span_eq_of_ne {s : Set P} (h : Collinear k s) {p₁ p₂ : P} (hp₁ : p₁ ∈ s)
    (hp₂ : p₂ ∈ s) (hp₁p₂ : p₁ ≠ p₂) : line[k, p₁, p₂] = affineSpan k s :=
  le_antisymm (affine_span_mono _ (Set.insert_subset.2 ⟨hp₁, Set.singleton_subset_iff.2 hp₂⟩))
    (affine_span_le.2 fun p hp => h.mem_affine_span_of_mem_of_ne hp₁ hp₂ hp hp₁p₂)
#align collinear.affine_span_eq_of_ne Collinear.affine_span_eq_of_ne

/-- Given a collinear set of points, and two distinct points `p₂` and `p₃` in it, a point `p₁` is
collinear with the set if and only if it is collinear with `p₂` and `p₃`. -/
theorem Collinear.collinear_insert_iff_of_ne {s : Set P} (h : Collinear k s) {p₁ p₂ p₃ : P}
    (hp₂ : p₂ ∈ s) (hp₃ : p₃ ∈ s) (hp₂p₃ : p₂ ≠ p₃) :
    Collinear k (insert p₁ s) ↔ Collinear k ({p₁, p₂, p₃} : Set P) :=
  by
  have hv : vectorSpan k (insert p₁ s) = vectorSpan k ({p₁, p₂, p₃} : Set P) :=
    by
    conv_lhs => rw [← direction_affine_span, ← affine_span_insert_affine_span]
    conv_rhs => rw [← direction_affine_span, ← affine_span_insert_affine_span]
    rw [h.affine_span_eq_of_ne hp₂ hp₃ hp₂p₃]
  rw [Collinear, Collinear, hv]
#align collinear.collinear_insert_iff_of_ne Collinear.collinear_insert_iff_of_ne

/-- Adding a point in the affine span of a set does not change whether that set is collinear. -/
theorem collinear_insert_iff_of_mem_affine_span {s : Set P} {p : P} (h : p ∈ affineSpan k s) :
    Collinear k (insert p s) ↔ Collinear k s := by
  rw [Collinear, Collinear, vector_span_insert_eq_vector_span h]
#align collinear_insert_iff_of_mem_affine_span collinear_insert_iff_of_mem_affine_span

/-- If a point lies in the affine span of two points, those three points are collinear. -/
theorem collinear_insert_of_mem_affine_span_pair {p₁ p₂ p₃ : P} (h : p₁ ∈ line[k, p₂, p₃]) :
    Collinear k ({p₁, p₂, p₃} : Set P) :=
  by
  rw [collinear_insert_iff_of_mem_affine_span h]
  exact collinear_pair _ _ _
#align collinear_insert_of_mem_affine_span_pair collinear_insert_of_mem_affine_span_pair

/-- If two points lie in the affine span of two points, those four points are collinear. -/
theorem collinear_insert_insert_of_mem_affine_span_pair {p₁ p₂ p₃ p₄ : P}
    (h₁ : p₁ ∈ line[k, p₃, p₄]) (h₂ : p₂ ∈ line[k, p₃, p₄]) :
    Collinear k ({p₁, p₂, p₃, p₄} : Set P) :=
  by
  rw [collinear_insert_iff_of_mem_affine_span
      ((AffineSubspace.le_def' _ _).1 (affine_span_mono k (Set.subset_insert _ _)) _ h₁),
    collinear_insert_iff_of_mem_affine_span h₂]
  exact collinear_pair _ _ _
#align
  collinear_insert_insert_of_mem_affine_span_pair collinear_insert_insert_of_mem_affine_span_pair

/-- If three points lie in the affine span of two points, those five points are collinear. -/
theorem collinear_insert_insert_insert_of_mem_affine_span_pair {p₁ p₂ p₃ p₄ p₅ : P}
    (h₁ : p₁ ∈ line[k, p₄, p₅]) (h₂ : p₂ ∈ line[k, p₄, p₅]) (h₃ : p₃ ∈ line[k, p₄, p₅]) :
    Collinear k ({p₁, p₂, p₃, p₄, p₅} : Set P) :=
  by
  rw [collinear_insert_iff_of_mem_affine_span
      ((AffineSubspace.le_def' _ _).1
        (affine_span_mono k ((Set.subset_insert _ _).trans (Set.subset_insert _ _))) _ h₁),
    collinear_insert_iff_of_mem_affine_span
      ((AffineSubspace.le_def' _ _).1 (affine_span_mono k (Set.subset_insert _ _)) _ h₂),
    collinear_insert_iff_of_mem_affine_span h₃]
  exact collinear_pair _ _ _
#align
  collinear_insert_insert_insert_of_mem_affine_span_pair collinear_insert_insert_insert_of_mem_affine_span_pair

/-- If three points lie in the affine span of two points, the first four points are collinear. -/
theorem collinear_insert_insert_insert_left_of_mem_affine_span_pair {p₁ p₂ p₃ p₄ p₅ : P}
    (h₁ : p₁ ∈ line[k, p₄, p₅]) (h₂ : p₂ ∈ line[k, p₄, p₅]) (h₃ : p₃ ∈ line[k, p₄, p₅]) :
    Collinear k ({p₁, p₂, p₃, p₄} : Set P) :=
  by
  refine' (collinear_insert_insert_insert_of_mem_affine_span_pair h₁ h₂ h₃).Subset _
  simp [Set.insert_subset_insert]
#align
  collinear_insert_insert_insert_left_of_mem_affine_span_pair collinear_insert_insert_insert_left_of_mem_affine_span_pair

/-- If three points lie in the affine span of two points, the first three points are collinear. -/
theorem collinear_triple_of_mem_affine_span_pair {p₁ p₂ p₃ p₄ p₅ : P} (h₁ : p₁ ∈ line[k, p₄, p₅])
    (h₂ : p₂ ∈ line[k, p₄, p₅]) (h₃ : p₃ ∈ line[k, p₄, p₅]) : Collinear k ({p₁, p₂, p₃} : Set P) :=
  by
  refine' (collinear_insert_insert_insert_left_of_mem_affine_span_pair h₁ h₂ h₃).Subset _
  simp [Set.insert_subset_insert]
#align collinear_triple_of_mem_affine_span_pair collinear_triple_of_mem_affine_span_pair

variable (k)

/-- A set of points is coplanar if their `vector_span` has dimension at most `2`. -/
def Coplanar (s : Set P) : Prop :=
  Module.rank k (vectorSpan k s) ≤ 2
#align coplanar Coplanar

variable {k}

/-- The `vector_span` of coplanar points is finite-dimensional. -/
theorem Coplanar.finite_dimensional_vector_span {s : Set P} (h : Coplanar k s) :
    FiniteDimensional k (vectorSpan k s) :=
  by
  refine' IsNoetherian.iff_fg.1 (IsNoetherian.iff_dim_lt_aleph_0.2 (lt_of_le_of_lt h _))
  simp
#align coplanar.finite_dimensional_vector_span Coplanar.finite_dimensional_vector_span

/-- The direction of the affine span of coplanar points is finite-dimensional. -/
theorem Coplanar.finite_dimensional_direction_affine_span {s : Set P} (h : Coplanar k s) :
    FiniteDimensional k (affineSpan k s).direction :=
  (direction_affine_span k s).symm ▸ h.finite_dimensional_vector_span
#align
  coplanar.finite_dimensional_direction_affine_span Coplanar.finite_dimensional_direction_affine_span

/-- A set of points, whose `vector_span` is finite-dimensional, is coplanar if and only if their
`vector_span` has dimension at most `2`. -/
theorem coplanar_iff_finrank_le_two {s : Set P} [FiniteDimensional k (vectorSpan k s)] :
    Coplanar k s ↔ finrank k (vectorSpan k s) ≤ 2 :=
  by
  have h : Coplanar k s ↔ Module.rank k (vectorSpan k s) ≤ 2 := Iff.rfl
  rw [← finrank_eq_dim] at h
  exact_mod_cast h
#align coplanar_iff_finrank_le_two coplanar_iff_finrank_le_two

alias coplanar_iff_finrank_le_two ↔ Coplanar.finrank_le_two _

/-- A subset of a coplanar set is coplanar. -/
theorem Coplanar.subset {s₁ s₂ : Set P} (hs : s₁ ⊆ s₂) (h : Coplanar k s₂) : Coplanar k s₁ :=
  (dim_le_of_submodule (vectorSpan k s₁) (vectorSpan k s₂) (vector_span_mono k hs)).trans h
#align coplanar.subset Coplanar.subset

/-- Collinear points are coplanar. -/
theorem Collinear.coplanar {s : Set P} (h : Collinear k s) : Coplanar k s :=
  le_trans h one_le_two
#align collinear.coplanar Collinear.coplanar

variable (k) (P)

/-- The empty set is coplanar. -/
theorem coplanar_empty : Coplanar k (∅ : Set P) :=
  (collinear_empty k P).Coplanar
#align coplanar_empty coplanar_empty

variable {P}

/-- A single point is coplanar. -/
theorem coplanar_singleton (p : P) : Coplanar k ({p} : Set P) :=
  (collinear_singleton k p).Coplanar
#align coplanar_singleton coplanar_singleton

/-- Two points are coplanar. -/
theorem coplanar_pair (p₁ p₂ : P) : Coplanar k ({p₁, p₂} : Set P) :=
  (collinear_pair k p₁ p₂).Coplanar
#align coplanar_pair coplanar_pair

variable {k}

/-- Adding a point in the affine span of a set does not change whether that set is coplanar. -/
theorem coplanar_insert_iff_of_mem_affine_span {s : Set P} {p : P} (h : p ∈ affineSpan k s) :
    Coplanar k (insert p s) ↔ Coplanar k s := by
  rw [Coplanar, Coplanar, vector_span_insert_eq_vector_span h]
#align coplanar_insert_iff_of_mem_affine_span coplanar_insert_iff_of_mem_affine_span

end AffineSpace'

section DivisionRing

variable {k : Type _} {V : Type _} {P : Type _}

include V

open AffineSubspace FiniteDimensional Module

variable [DivisionRing k] [AddCommGroup V] [Module k V] [affine_space V P]

/-- Adding a point to a finite-dimensional subspace increases the dimension by at most one. -/
theorem finrank_vector_span_insert_le (s : AffineSubspace k P) (p : P) :
    finrank k (vectorSpan k (insert p (s : Set P))) ≤ finrank k s.direction + 1 :=
  by
  by_cases hf : FiniteDimensional k s.direction; swap
  · have hf' : ¬FiniteDimensional k (vectorSpan k (insert p (s : Set P))) :=
      by
      intro h
      have h' : s.direction ≤ vectorSpan k (insert p (s : Set P)) :=
        by
        conv_lhs => rw [← affine_span_coe s, direction_affine_span]
        exact vector_span_mono k (Set.subset_insert _ _)
      exact hf (Submodule.finite_dimensional_of_le h')
    rw [finrank_of_infinite_dimensional hf, finrank_of_infinite_dimensional hf', zero_add]
    exact zero_le_one
  haveI := hf
  rw [← direction_affine_span, ← affine_span_insert_affine_span]
  rcases(s : Set P).eq_empty_or_nonempty with (hs | ⟨p₀, hp₀⟩)
  · rw [coe_eq_bot_iff] at hs
    rw [hs, bot_coe, span_empty, bot_coe, direction_affine_span, direction_bot, finrank_bot,
      zero_add]
    convert zero_le_one' ℕ
    rw [← finrank_bot k V]
    convert rfl <;> simp
  · rw [affine_span_coe, direction_affine_span_insert hp₀, add_comm]
    refine' (Submodule.dim_add_le_dim_add_dim _ _).trans (add_le_add_right _ _)
    refine' finrank_le_one ⟨p -ᵥ p₀, Submodule.mem_span_singleton_self _⟩ fun v => _
    have h := v.property
    rw [Submodule.mem_span_singleton] at h
    rcases h with ⟨c, hc⟩
    refine' ⟨c, _⟩
    ext
    exact hc
#align finrank_vector_span_insert_le finrank_vector_span_insert_le

variable (k)

/-- Adding a point to a set with a finite-dimensional span increases the dimension by at most
one. -/
theorem finrank_vector_span_insert_le_set (s : Set P) (p : P) :
    finrank k (vectorSpan k (insert p s)) ≤ finrank k (vectorSpan k s) + 1 :=
  by
  rw [← direction_affine_span, ← affine_span_insert_affine_span, direction_affine_span]
  refine' (finrank_vector_span_insert_le _ _).trans (add_le_add_right _ _)
  rw [direction_affine_span]
#align finrank_vector_span_insert_le_set finrank_vector_span_insert_le_set

variable {k}

/-- Adding a point to a collinear set produces a coplanar set. -/
theorem Collinear.coplanar_insert {s : Set P} (h : Collinear k s) (p : P) :
    Coplanar k (insert p s) :=
  by
  haveI := h.finite_dimensional_vector_span
  rw [coplanar_iff_finrank_le_two]
  exact (finrank_vector_span_insert_le_set k s p).trans (add_le_add_right h.finrank_le_one _)
#align collinear.coplanar_insert Collinear.coplanar_insert

/-- A set of points in a two-dimensional space is coplanar. -/
theorem coplanar_of_finrank_eq_two (s : Set P) (h : finrank k V = 2) : Coplanar k s :=
  by
  haveI := finite_dimensional_of_finrank_eq_succ h
  rw [coplanar_iff_finrank_le_two, ← h]
  exact Submodule.finrank_le _
#align coplanar_of_finrank_eq_two coplanar_of_finrank_eq_two

/-- A set of points in a two-dimensional space is coplanar. -/
theorem coplanar_of_fact_finrank_eq_two (s : Set P) [h : Fact (finrank k V = 2)] : Coplanar k s :=
  coplanar_of_finrank_eq_two s h.out
#align coplanar_of_fact_finrank_eq_two coplanar_of_fact_finrank_eq_two

variable (k)

/-- Three points are coplanar. -/
theorem coplanar_triple (p₁ p₂ p₃ : P) : Coplanar k ({p₁, p₂, p₃} : Set P) :=
  (collinear_pair k p₂ p₃).coplanar_insert p₁
#align coplanar_triple coplanar_triple

end DivisionRing

