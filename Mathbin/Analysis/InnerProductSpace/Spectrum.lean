/-
Copyright (c) 2021 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth

! This file was ported from Lean 3 source module analysis.inner_product_space.spectrum
! leanprover-community/mathlib commit cff8231f04dfa33fd8f2f45792eebd862ef30cad
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.Rayleigh
import Mathbin.Analysis.InnerProductSpace.PiL2
import Mathbin.Algebra.DirectSum.Decomposition
import Mathbin.LinearAlgebra.Eigenspace.Minpoly

/-! # Spectral theory of self-adjoint operators

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file covers the spectral theory of self-adjoint operators on an inner product space.

The first part of the file covers general properties, true without any condition on boundedness or
compactness of the operator or finite-dimensionality of the underlying space, notably:
* `is_self_adjoint.conj_eigenvalue_eq_self`: the eigenvalues are real
* `is_self_adjoint.orthogonal_family_eigenspaces`: the eigenspaces are orthogonal
* `is_self_adjoint.orthogonal_supr_eigenspaces`: the restriction of the operator to the mutual
  orthogonal complement of the eigenspaces has, itself, no eigenvectors

The second part of the file covers properties of self-adjoint operators in finite dimension.
Letting `T` be a self-adjoint operator on a finite-dimensional inner product space `T`,
* The definition `is_self_adjoint.diagonalization` provides a linear isometry equivalence `E` to
  the direct sum of the eigenspaces of `T`.  The theorem
  `is_self_adjoint.diagonalization_apply_self_apply` states that, when `T` is transferred via this
  equivalence to an operator on the direct sum, it acts diagonally.
* The definition `is_self_adjoint.eigenvector_basis` provides an orthonormal basis for `E`
  consisting of eigenvectors of `T`, with `is_self_adjoint.eigenvalues` giving the corresponding
  list of eigenvalues, as real numbers.  The definition `is_self_adjoint.diagonalization_basis`
  gives the associated linear isometry equivalence from `E` to Euclidean space, and the theorem
  `is_self_adjoint.diagonalization_basis_apply_self_apply` states that, when `T` is transferred via
  this equivalence to an operator on Euclidean space, it acts diagonally.

These are forms of the *diagonalization theorem* for self-adjoint operators on finite-dimensional
inner product spaces.

## TODO

Spectral theory for compact self-adjoint operators, bounded self-adjoint operators.

## Tags

self-adjoint operator, spectral theorem, diagonalization theorem

-/


variable {𝕜 : Type _} [IsROrC 𝕜] [dec_𝕜 : DecidableEq 𝕜]

variable {E : Type _} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]

local notation "⟪" x ", " y "⟫" => @inner 𝕜 E _ x y

open scoped BigOperators ComplexConjugate

open Module.End

namespace LinearMap

namespace IsSymmetric

variable {T : E →ₗ[𝕜] E} (hT : T.IsSymmetric)

#print LinearMap.IsSymmetric.invariant_orthogonalComplement_eigenspace /-
/-- A self-adjoint operator preserves orthogonal complements of its eigenspaces. -/
theorem invariant_orthogonalComplement_eigenspace (μ : 𝕜) (v : E) (hv : v ∈ (eigenspace T μ)ᗮ) :
    T v ∈ (eigenspace T μ)ᗮ := by
  intro w hw
  have : T w = (μ : 𝕜) • w := by rwa [mem_eigenspace_iff] at hw 
  simp [← hT w, this, inner_smul_left, hv w hw]
#align linear_map.is_symmetric.invariant_orthogonal_eigenspace LinearMap.IsSymmetric.invariant_orthogonalComplement_eigenspace
-/

#print LinearMap.IsSymmetric.conj_eigenvalue_eq_self /-
/-- The eigenvalues of a self-adjoint operator are real. -/
theorem conj_eigenvalue_eq_self {μ : 𝕜} (hμ : HasEigenvalue T μ) : conj μ = μ :=
  by
  obtain ⟨v, hv₁, hv₂⟩ := hμ.exists_has_eigenvector
  rw [mem_eigenspace_iff] at hv₁ 
  simpa [hv₂, inner_smul_left, inner_smul_right, hv₁] using hT v v
#align linear_map.is_symmetric.conj_eigenvalue_eq_self LinearMap.IsSymmetric.conj_eigenvalue_eq_self
-/

#print LinearMap.IsSymmetric.orthogonalFamily_eigenspaces /-
/-- The eigenspaces of a self-adjoint operator are mutually orthogonal. -/
theorem orthogonalFamily_eigenspaces :
    OrthogonalFamily 𝕜 (fun μ => eigenspace T μ) fun μ => (eigenspace T μ).subtypeₗᵢ :=
  by
  rintro μ ν hμν ⟨v, hv⟩ ⟨w, hw⟩
  by_cases hv' : v = 0
  · simp [hv']
  have H := hT.conj_eigenvalue_eq_self (has_eigenvalue_of_has_eigenvector ⟨hv, hv'⟩)
  rw [mem_eigenspace_iff] at hv hw 
  refine' Or.resolve_left _ hμν.symm
  simpa [inner_smul_left, inner_smul_right, hv, hw, H] using (hT v w).symm
#align linear_map.is_symmetric.orthogonal_family_eigenspaces LinearMap.IsSymmetric.orthogonalFamily_eigenspaces
-/

#print LinearMap.IsSymmetric.orthogonalFamily_eigenspaces' /-
theorem orthogonalFamily_eigenspaces' :
    OrthogonalFamily 𝕜 (fun μ : Eigenvalues T => eigenspace T μ) fun μ =>
      (eigenspace T μ).subtypeₗᵢ :=
  hT.orthogonalFamily_eigenspaces.comp Subtype.coe_injective
#align linear_map.is_symmetric.orthogonal_family_eigenspaces' LinearMap.IsSymmetric.orthogonalFamily_eigenspaces'
-/

#print LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces_invariant /-
/-- The mutual orthogonal complement of the eigenspaces of a self-adjoint operator on an inner
product space is an invariant subspace of the operator. -/
theorem orthogonalComplement_iSup_eigenspaces_invariant ⦃v : E⦄ (hv : v ∈ (⨆ μ, eigenspace T μ)ᗮ) :
    T v ∈ (⨆ μ, eigenspace T μ)ᗮ :=
  by
  rw [← Submodule.iInf_orthogonal] at hv ⊢
  exact T.infi_invariant hT.invariant_orthogonal_eigenspace v hv
#align linear_map.is_symmetric.orthogonal_supr_eigenspaces_invariant LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces_invariant
-/

#print LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces /-
/-- The mutual orthogonal complement of the eigenspaces of a self-adjoint operator on an inner
product space has no eigenvalues. -/
theorem orthogonalComplement_iSup_eigenspaces (μ : 𝕜) :
    eigenspace (T.restrict hT.orthogonalComplement_iSup_eigenspaces_invariant) μ = ⊥ :=
  by
  set p : Submodule 𝕜 E := (⨆ μ, eigenspace T μ)ᗮ
  refine' eigenspace_restrict_eq_bot hT.orthogonal_supr_eigenspaces_invariant _
  have H₂ : eigenspace T μ ⟂ p := (Submodule.isOrtho_orthogonal_right _).mono_left (le_iSup _ _)
  exact H₂.disjoint
#align linear_map.is_symmetric.orthogonal_supr_eigenspaces LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces
-/

/-! ### Finite-dimensional theory -/


variable [FiniteDimensional 𝕜 E]

#print LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces_eq_bot /-
/-- The mutual orthogonal complement of the eigenspaces of a self-adjoint operator on a
finite-dimensional inner product space is trivial. -/
theorem orthogonalComplement_iSup_eigenspaces_eq_bot : (⨆ μ, eigenspace T μ)ᗮ = ⊥ :=
  by
  have hT' : is_symmetric _ := hT.restrict_invariant hT.orthogonal_supr_eigenspaces_invariant
  -- a self-adjoint operator on a nontrivial inner product space has an eigenvalue
  haveI := hT'.subsingleton_of_no_eigenvalue_finite_dimensional hT.orthogonal_supr_eigenspaces
  exact Submodule.eq_bot_of_subsingleton _
#align linear_map.is_symmetric.orthogonal_supr_eigenspaces_eq_bot LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces_eq_bot
-/

#print LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces_eq_bot' /-
theorem orthogonalComplement_iSup_eigenspaces_eq_bot' :
    (⨆ μ : Eigenvalues T, eigenspace T μ)ᗮ = ⊥ :=
  show (⨆ μ : { μ // eigenspace T μ ≠ ⊥ }, eigenspace T μ)ᗮ = ⊥ by
    rw [iSup_ne_bot_subtype, hT.orthogonal_supr_eigenspaces_eq_bot]
#align linear_map.is_symmetric.orthogonal_supr_eigenspaces_eq_bot' LinearMap.IsSymmetric.orthogonalComplement_iSup_eigenspaces_eq_bot'
-/

#print LinearMap.IsSymmetric.directSumDecomposition /-
/-- The eigenspaces of a self-adjoint operator on a finite-dimensional inner product space `E` gives
an internal direct sum decomposition of `E`.

Note this takes `hT` as a `fact` to allow it to be an instance. -/
noncomputable instance directSumDecomposition [hT : Fact T.IsSymmetric] :
    DirectSum.Decomposition fun μ : Eigenvalues T => eigenspace T μ :=
  haveI h : ∀ μ : eigenvalues T, CompleteSpace (eigenspace T μ) := fun μ => by infer_instance
  hT.out.orthogonal_family_eigenspaces'.decomposition
    (submodule.orthogonal_eq_bot_iff.mp hT.out.orthogonal_supr_eigenspaces_eq_bot')
#align linear_map.is_symmetric.direct_sum_decomposition LinearMap.IsSymmetric.directSumDecomposition
-/

#print LinearMap.IsSymmetric.directSum_decompose_apply /-
theorem directSum_decompose_apply [hT : Fact T.IsSymmetric] (x : E) (μ : Eigenvalues T) :
    DirectSum.decompose (fun μ : Eigenvalues T => eigenspace T μ) x μ =
      orthogonalProjection (eigenspace T μ) x :=
  rfl
#align linear_map.is_symmetric.direct_sum_decompose_apply LinearMap.IsSymmetric.directSum_decompose_apply
-/

#print LinearMap.IsSymmetric.direct_sum_isInternal /-
/-- The eigenspaces of a self-adjoint operator on a finite-dimensional inner product space `E` gives
an internal direct sum decomposition of `E`. -/
theorem direct_sum_isInternal : DirectSum.IsInternal fun μ : Eigenvalues T => eigenspace T μ :=
  hT.orthogonalFamily_eigenspaces'.isInternal_iff.mpr
    hT.orthogonalComplement_iSup_eigenspaces_eq_bot'
#align linear_map.is_symmetric.direct_sum_is_internal LinearMap.IsSymmetric.direct_sum_isInternal
-/

section Version1

#print LinearMap.IsSymmetric.diagonalization /-
/-- Isometry from an inner product space `E` to the direct sum of the eigenspaces of some
self-adjoint operator `T` on `E`. -/
noncomputable def diagonalization : E ≃ₗᵢ[𝕜] PiLp 2 fun μ : Eigenvalues T => eigenspace T μ :=
  hT.direct_sum_isInternal.isometryL2OfOrthogonalFamily hT.orthogonalFamily_eigenspaces'
#align linear_map.is_symmetric.diagonalization LinearMap.IsSymmetric.diagonalization
-/

#print LinearMap.IsSymmetric.diagonalization_symm_apply /-
@[simp]
theorem diagonalization_symm_apply (w : PiLp 2 fun μ : Eigenvalues T => eigenspace T μ) :
    hT.diagonalization.symm w = ∑ μ, w μ :=
  hT.direct_sum_isInternal.isometryL2OfOrthogonalFamily_symm_apply hT.orthogonalFamily_eigenspaces'
    w
#align linear_map.is_symmetric.diagonalization_symm_apply LinearMap.IsSymmetric.diagonalization_symm_apply
-/

#print LinearMap.IsSymmetric.diagonalization_apply_self_apply /-
/-- *Diagonalization theorem*, *spectral theorem*; version 1: A self-adjoint operator `T` on a
finite-dimensional inner product space `E` acts diagonally on the decomposition of `E` into the
direct sum of the eigenspaces of `T`. -/
theorem diagonalization_apply_self_apply (v : E) (μ : Eigenvalues T) :
    hT.diagonalization (T v) μ = (μ : 𝕜) • hT.diagonalization v μ :=
  by
  suffices
    ∀ w : PiLp 2 fun μ : eigenvalues T => eigenspace T μ,
      T (hT.diagonalization.symm w) = hT.diagonalization.symm fun μ => (μ : 𝕜) • w μ
    by
    simpa only [LinearIsometryEquiv.symm_apply_apply, LinearIsometryEquiv.apply_symm_apply] using
      congr_arg (fun w => hT.diagonalization w μ) (this (hT.diagonalization v))
  intro w
  have hwT : ∀ μ, T (w μ) = (μ : 𝕜) • w μ := fun μ => mem_eigenspace_iff.1 (w μ).2
  simp only [hwT, diagonalization_symm_apply, map_sum, Submodule.coe_smul_of_tower]
#align linear_map.is_symmetric.diagonalization_apply_self_apply LinearMap.IsSymmetric.diagonalization_apply_self_apply
-/

end Version1

section Version2

variable {n : ℕ} (hn : FiniteDimensional.finrank 𝕜 E = n)

#print LinearMap.IsSymmetric.eigenvectorBasis /-
/-- A choice of orthonormal basis of eigenvectors for self-adjoint operator `T` on a
finite-dimensional inner product space `E`.

TODO Postcompose with a permutation so that these eigenvectors are listed in increasing order of
eigenvalue. -/
noncomputable irreducible_def eigenvectorBasis : OrthonormalBasis (Fin n) 𝕜 E :=
  hT.direct_sum_isInternal.subordinateOrthonormalBasis hn hT.orthogonalFamily_eigenspaces'
#align linear_map.is_symmetric.eigenvector_basis LinearMap.IsSymmetric.eigenvectorBasis
-/

#print LinearMap.IsSymmetric.eigenvalues /-
/-- The sequence of real eigenvalues associated to the standard orthonormal basis of eigenvectors
for a self-adjoint operator `T` on `E`.

TODO Postcompose with a permutation so that these eigenvalues are listed in increasing order. -/
noncomputable irreducible_def eigenvalues (i : Fin n) : ℝ :=
  @IsROrC.re 𝕜 _ <|
    hT.direct_sum_isInternal.subordinateOrthonormalBasisIndex hn i hT.orthogonalFamily_eigenspaces'
#align linear_map.is_symmetric.eigenvalues LinearMap.IsSymmetric.eigenvalues
-/

#print LinearMap.IsSymmetric.hasEigenvector_eigenvectorBasis /-
theorem hasEigenvector_eigenvectorBasis (i : Fin n) :
    HasEigenvector T (hT.Eigenvalues hn i) (hT.eigenvectorBasis hn i) :=
  by
  let v : E := hT.eigenvector_basis hn i
  let μ : 𝕜 :=
    hT.direct_sum_is_internal.subordinate_orthonormal_basis_index hn i
      hT.orthogonal_family_eigenspaces'
  simp_rw [eigenvalues]
  change has_eigenvector T (IsROrC.re μ) v
  have key : has_eigenvector T μ v :=
    by
    have H₁ : v ∈ eigenspace T μ := by
      simp_rw [v, eigenvector_basis]
      exact
        hT.direct_sum_is_internal.subordinate_orthonormal_basis_subordinate hn i
          hT.orthogonal_family_eigenspaces'
    have H₂ : v ≠ 0 := by simpa using (hT.eigenvector_basis hn).toBasis.NeZero i
    exact ⟨H₁, H₂⟩
  have re_μ : ↑(IsROrC.re μ) = μ := by
    rw [← IsROrC.conj_eq_iff_re]
    exact hT.conj_eigenvalue_eq_self (has_eigenvalue_of_has_eigenvector key)
  simpa [re_μ] using key
#align linear_map.is_symmetric.has_eigenvector_eigenvector_basis LinearMap.IsSymmetric.hasEigenvector_eigenvectorBasis
-/

#print LinearMap.IsSymmetric.hasEigenvalue_eigenvalues /-
theorem hasEigenvalue_eigenvalues (i : Fin n) : HasEigenvalue T (hT.Eigenvalues hn i) :=
  Module.End.hasEigenvalue_of_hasEigenvector (hT.hasEigenvector_eigenvectorBasis hn i)
#align linear_map.is_symmetric.has_eigenvalue_eigenvalues LinearMap.IsSymmetric.hasEigenvalue_eigenvalues
-/

#print LinearMap.IsSymmetric.apply_eigenvectorBasis /-
@[simp]
theorem apply_eigenvectorBasis (i : Fin n) :
    T (hT.eigenvectorBasis hn i) = (hT.Eigenvalues hn i : 𝕜) • hT.eigenvectorBasis hn i :=
  mem_eigenspace_iff.mp (hT.hasEigenvector_eigenvectorBasis hn i).1
#align linear_map.is_symmetric.apply_eigenvector_basis LinearMap.IsSymmetric.apply_eigenvectorBasis
-/

#print LinearMap.IsSymmetric.eigenvectorBasis_apply_self_apply /-
/-- *Diagonalization theorem*, *spectral theorem*; version 2: A self-adjoint operator `T` on a
finite-dimensional inner product space `E` acts diagonally on the identification of `E` with
Euclidean space induced by an orthonormal basis of eigenvectors of `T`. -/
theorem eigenvectorBasis_apply_self_apply (v : E) (i : Fin n) :
    (hT.eigenvectorBasis hn).repr (T v) i =
      hT.Eigenvalues hn i * (hT.eigenvectorBasis hn).repr v i :=
  by
  suffices
    ∀ w : EuclideanSpace 𝕜 (Fin n),
      T ((hT.eigenvector_basis hn).repr.symm w) =
        (hT.eigenvector_basis hn).repr.symm fun i => hT.eigenvalues hn i * w i
    by
    simpa [OrthonormalBasis.sum_repr_symm] using
      congr_arg (fun v => (hT.eigenvector_basis hn).repr v i)
        (this ((hT.eigenvector_basis hn).repr v))
  intro w
  simp_rw [← OrthonormalBasis.sum_repr_symm, LinearMap.map_sum, LinearMap.map_smul,
    apply_eigenvector_basis]
  apply Fintype.sum_congr
  intro a
  rw [smul_smul, mul_comm]
#align linear_map.is_symmetric.diagonalization_basis_apply_self_apply LinearMap.IsSymmetric.eigenvectorBasis_apply_self_apply
-/

end Version2

end IsSymmetric

end LinearMap

section Nonneg

#print inner_product_apply_eigenvector /-
@[simp]
theorem inner_product_apply_eigenvector {μ : 𝕜} {v : E} {T : E →ₗ[𝕜] E}
    (h : v ∈ Module.End.eigenspace T μ) : ⟪v, T v⟫ = μ * ‖v‖ ^ 2 := by
  simp only [mem_eigenspace_iff.mp h, inner_smul_right, inner_self_eq_norm_sq_to_K]
#align inner_product_apply_eigenvector inner_product_apply_eigenvector
-/

#print eigenvalue_nonneg_of_nonneg /-
theorem eigenvalue_nonneg_of_nonneg {μ : ℝ} {T : E →ₗ[𝕜] E} (hμ : HasEigenvalue T μ)
    (hnn : ∀ x : E, 0 ≤ IsROrC.re ⟪x, T x⟫) : 0 ≤ μ :=
  by
  obtain ⟨v, hv⟩ := hμ.exists_has_eigenvector
  have hpos : 0 < ‖v‖ ^ 2 := by simpa only [sq_pos_iff, norm_ne_zero_iff] using hv.2
  have : IsROrC.re ⟪v, T v⟫ = μ * ‖v‖ ^ 2 := by
    exact_mod_cast congr_arg IsROrC.re (inner_product_apply_eigenvector hv.1)
  exact (zero_le_mul_right hpos).mp (this ▸ hnn v)
#align eigenvalue_nonneg_of_nonneg eigenvalue_nonneg_of_nonneg
-/

#print eigenvalue_pos_of_pos /-
theorem eigenvalue_pos_of_pos {μ : ℝ} {T : E →ₗ[𝕜] E} (hμ : HasEigenvalue T μ)
    (hnn : ∀ x : E, 0 < IsROrC.re ⟪x, T x⟫) : 0 < μ :=
  by
  obtain ⟨v, hv⟩ := hμ.exists_has_eigenvector
  have hpos : 0 < ‖v‖ ^ 2 := by simpa only [sq_pos_iff, norm_ne_zero_iff] using hv.2
  have : IsROrC.re ⟪v, T v⟫ = μ * ‖v‖ ^ 2 := by
    exact_mod_cast congr_arg IsROrC.re (inner_product_apply_eigenvector hv.1)
  exact (zero_lt_mul_right hpos).mp (this ▸ hnn v)
#align eigenvalue_pos_of_pos eigenvalue_pos_of_pos
-/

end Nonneg

