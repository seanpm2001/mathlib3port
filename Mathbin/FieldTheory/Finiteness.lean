/-
Copyright (c) 2019 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes

! This file was ported from Lean 3 source module field_theory.finiteness
! leanprover-community/mathlib commit 25a9423c6b2c8626e91c688bfd6c1d0a986a3e6e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Finiteness
import Mathbin.LinearAlgebra.Dimension

/-!
# A module over a division ring is noetherian if and only if it is finite.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


universe u v

open scoped Classical Cardinal

open Cardinal Submodule Module Function

namespace IsNoetherian

variable {K : Type u} {V : Type v} [DivisionRing K] [AddCommGroup V] [Module K V]

#print IsNoetherian.iff_rank_lt_aleph0 /-
/-- A module over a division ring is noetherian if and only if
its dimension (as a cardinal) is strictly less than the first infinite cardinal `ℵ₀`.
-/
theorem iff_rank_lt_aleph0 : IsNoetherian K V ↔ Module.rank K V < ℵ₀ :=
  by
  let b := Basis.ofVectorSpace K V
  rw [← b.mk_eq_rank'', lt_aleph_0_iff_set_finite]
  constructor
  · intro
    exact finite_of_linearIndependent (Basis.ofVectorSpaceIndex.linearIndependent K V)
  · intro hbfinite
    refine'
      @isNoetherian_of_linearEquiv K (⊤ : Submodule K V) V _ _ _ _ _ (LinearEquiv.ofTop _ rfl)
        (id _)
    refine' isNoetherian_of_fg_of_noetherian _ ⟨Set.Finite.toFinset hbfinite, _⟩
    rw [Set.Finite.coe_toFinset, ← b.span_eq, Basis.coe_ofVectorSpace, Subtype.range_coe]
#align is_noetherian.iff_rank_lt_aleph_0 IsNoetherian.iff_rank_lt_aleph0
-/

variable (K V)

#print IsNoetherian.rank_lt_aleph0 /-
/-- The dimension of a noetherian module over a division ring, as a cardinal,
is strictly less than the first infinite cardinal `ℵ₀`. -/
theorem rank_lt_aleph0 : ∀ [IsNoetherian K V], Module.rank K V < ℵ₀ :=
  IsNoetherian.iff_rank_lt_aleph0.1
#align is_noetherian.rank_lt_aleph_0 IsNoetherian.rank_lt_aleph0
-/

variable {K V}

#print IsNoetherian.fintypeBasisIndex /-
/-- In a noetherian module over a division ring, all bases are indexed by a finite type. -/
noncomputable def fintypeBasisIndex {ι : Type _} [IsNoetherian K V] (b : Basis ι K V) : Fintype ι :=
  b.fintypeIndexOfRankLtAleph0 (rank_lt_aleph0 K V)
#align is_noetherian.fintype_basis_index IsNoetherian.fintypeBasisIndex
-/

/-- In a noetherian module over a division ring,
`basis.of_vector_space` is indexed by a finite type. -/
noncomputable instance [IsNoetherian K V] : Fintype (Basis.ofVectorSpaceIndex K V) :=
  fintypeBasisIndex (Basis.ofVectorSpace K V)

#print IsNoetherian.finite_basis_index /-
/-- In a noetherian module over a division ring,
if a basis is indexed by a set, that set is finite. -/
theorem finite_basis_index {ι : Type _} {s : Set ι} [IsNoetherian K V] (b : Basis s K V) :
    s.Finite :=
  b.finite_index_of_rank_lt_aleph0 (rank_lt_aleph0 K V)
#align is_noetherian.finite_basis_index IsNoetherian.finite_basis_index
-/

variable (K V)

#print IsNoetherian.finsetBasisIndex /-
/-- In a noetherian module over a division ring,
there exists a finite basis. This is the indexing `finset`. -/
noncomputable def finsetBasisIndex [IsNoetherian K V] : Finset V :=
  (finite_basis_index (Basis.ofVectorSpace K V)).toFinset
#align is_noetherian.finset_basis_index IsNoetherian.finsetBasisIndex
-/

#print IsNoetherian.coe_finsetBasisIndex /-
@[simp]
theorem coe_finsetBasisIndex [IsNoetherian K V] :
    (↑(finsetBasisIndex K V) : Set V) = Basis.ofVectorSpaceIndex K V :=
  Set.Finite.coe_toFinset _
#align is_noetherian.coe_finset_basis_index IsNoetherian.coe_finsetBasisIndex
-/

#print IsNoetherian.coeSort_finsetBasisIndex /-
@[simp]
theorem coeSort_finsetBasisIndex [IsNoetherian K V] :
    (finsetBasisIndex K V : Type _) = Basis.ofVectorSpaceIndex K V :=
  Set.Finite.coeSort_toFinset _
#align is_noetherian.coe_sort_finset_basis_index IsNoetherian.coeSort_finsetBasisIndex
-/

#print IsNoetherian.finsetBasis /-
/-- In a noetherian module over a division ring, there exists a finite basis.
This is indexed by the `finset` `finite_dimensional.finset_basis_index`.
This is in contrast to the result `finite_basis_index (basis.of_vector_space K V)`,
which provides a set and a `set.finite`.
-/
noncomputable def finsetBasis [IsNoetherian K V] : Basis (finsetBasisIndex K V) K V :=
  (Basis.ofVectorSpace K V).reindex (by simp)
#align is_noetherian.finset_basis IsNoetherian.finsetBasis
-/

#print IsNoetherian.range_finsetBasis /-
@[simp]
theorem range_finsetBasis [IsNoetherian K V] :
    Set.range (finsetBasis K V) = Basis.ofVectorSpaceIndex K V := by
  rw [finset_basis, Basis.range_reindex, Basis.range_ofVectorSpace]
#align is_noetherian.range_finset_basis IsNoetherian.range_finsetBasis
-/

variable {K V}

#print IsNoetherian.iff_fg /-
/-- A module over a division ring is noetherian if and only if it is finitely generated. -/
theorem iff_fg : IsNoetherian K V ↔ Module.Finite K V :=
  by
  constructor
  · intro h
    exact ⟨⟨finset_basis_index K V, by convert (finset_basis K V).span_eq; simp⟩⟩
  · rintro ⟨s, hs⟩
    rw [IsNoetherian.iff_rank_lt_aleph0, ← rank_top, ← hs]
    exact lt_of_le_of_lt (rank_span_le _) s.finite_to_set.lt_aleph_0
#align is_noetherian.iff_fg IsNoetherian.iff_fg
-/

end IsNoetherian

