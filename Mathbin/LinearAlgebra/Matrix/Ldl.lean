/-
Copyright (c) 2022 Alexander Bentkamp. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alexander Bentkamp

! This file was ported from Lean 3 source module linear_algebra.matrix.ldl
! leanprover-community/mathlib commit 2a0ce625dbb0ffbc7d1316597de0b25c1ec75303
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.GramSchmidtOrtho
import Mathbin.LinearAlgebra.Matrix.PosDef

/-! # LDL decomposition

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves the LDL-decomposition of matricies: Any positive definite matrix `S` can be
decomposed as `S = LDLᴴ` where `L` is a lower-triangular matrix and `D` is a diagonal matrix.

## Main definitions

 * `LDL.lower` is the lower triangular matrix `L`.
 * `LDL.lower_inv` is the inverse of the lower triangular matrix `L`.
 * `LDL.diag` is the diagonal matrix `D`.

## Main result

* `ldl_decomposition` states that any positive definite matrix can be decomposed as `LDLᴴ`.

## TODO

* Prove that `LDL.lower` is lower triangular from `LDL.lower_inv_triangular`.

-/


variable {𝕜 : Type _} [IsROrC 𝕜]

variable {n : Type _} [LinearOrder n] [IsWellOrder n (· < ·)] [LocallyFiniteOrderBot n]

local notation "⟪" x ", " y "⟫ₑ" => @inner 𝕜 _ _ ((PiLp.equiv 2 _).symm x) ((PiLp.equiv _ _).symm y)

open Matrix

open scoped Matrix

variable {S : Matrix n n 𝕜} [Fintype n] (hS : S.PosDef)

#print LDL.lowerInv /-
/-- The inverse of the lower triangular matrix `L` of the LDL-decomposition. It is obtained by
applying Gram-Schmidt-Orthogonalization w.r.t. the inner product induced by `Sᵀ` on the standard
basis vectors `pi.basis_fun`. -/
noncomputable def LDL.lowerInv : Matrix n n 𝕜 :=
  @gramSchmidt 𝕜 (n → 𝕜) _ (_ : _) (InnerProductSpace.ofMatrix hS.transpose) n _ _ _
    (Pi.basisFun 𝕜 n)
#align LDL.lower_inv LDL.lowerInv
-/

#print LDL.lowerInv_eq_gramSchmidtBasis /-
theorem LDL.lowerInv_eq_gramSchmidtBasis :
    LDL.lowerInv hS =
      ((Pi.basisFun 𝕜 n).toMatrix
          (@gramSchmidtBasis 𝕜 (n → 𝕜) _ (_ : _) (InnerProductSpace.ofMatrix hS.transpose) n _ _ _
            (Pi.basisFun 𝕜 n)))ᵀ :=
  by
  ext i j
  rw [LDL.lowerInv, Basis.coePiBasisFun.toMatrix_eq_transpose, coe_gramSchmidtBasis]
  rfl
#align LDL.lower_inv_eq_gram_schmidt_basis LDL.lowerInv_eq_gramSchmidtBasis
-/

#print LDL.invertibleLowerInv /-
noncomputable instance LDL.invertibleLowerInv : Invertible (LDL.lowerInv hS) :=
  by
  rw [LDL.lowerInv_eq_gramSchmidtBasis]
  haveI :=
    Basis.invertibleToMatrix (Pi.basisFun 𝕜 n)
      (@gramSchmidtBasis 𝕜 (n → 𝕜) _ (_ : _) (inner_product_space.of_matrix hS.transpose) n _ _ _
        (Pi.basisFun 𝕜 n))
  infer_instance
#align LDL.invertible_lower_inv LDL.invertibleLowerInv
-/

#print LDL.lowerInv_orthogonal /-
theorem LDL.lowerInv_orthogonal {i j : n} (h₀ : i ≠ j) :
    ⟪LDL.lowerInv hS i, Sᵀ.mulVec (LDL.lowerInv hS j)⟫ₑ = 0 :=
  @gramSchmidt_orthogonal 𝕜 _ _ (_ : _) (InnerProductSpace.ofMatrix hS.transpose) _ _ _ _ _ _ _ h₀
#align LDL.lower_inv_orthogonal LDL.lowerInv_orthogonal
-/

#print LDL.diagEntries /-
/-- The entries of the diagonal matrix `D` of the LDL decomposition. -/
noncomputable def LDL.diagEntries : n → 𝕜 := fun i =>
  ⟪star (LDL.lowerInv hS i), S.mulVec (star (LDL.lowerInv hS i))⟫ₑ
#align LDL.diag_entries LDL.diagEntries
-/

#print LDL.diag /-
/-- The diagonal matrix `D` of the LDL decomposition. -/
noncomputable def LDL.diag : Matrix n n 𝕜 :=
  Matrix.diagonal (LDL.diagEntries hS)
#align LDL.diag LDL.diag
-/

#print LDL.lowerInv_triangular /-
theorem LDL.lowerInv_triangular {i j : n} (hij : i < j) : LDL.lowerInv hS i j = 0 := by
  rw [←
    @gramSchmidt_triangular 𝕜 (n → 𝕜) _ (_ : _) (inner_product_space.of_matrix hS.transpose) n _ _ _
      i j hij (Pi.basisFun 𝕜 n),
    Pi.basisFun_repr, LDL.lowerInv]
#align LDL.lower_inv_triangular LDL.lowerInv_triangular
-/

#print LDL.diag_eq_lowerInv_conj /-
/-- Inverse statement of **LDL decomposition**: we can conjugate a positive definite matrix
by some lower triangular matrix and get a diagonal matrix. -/
theorem LDL.diag_eq_lowerInv_conj : LDL.diag hS = LDL.lowerInv hS ⬝ S ⬝ (LDL.lowerInv hS)ᴴ :=
  by
  ext i j
  by_cases hij : i = j
  ·
    simpa only [hij, LDL.diag, diagonal_apply_eq, LDL.diagEntries, Matrix.mul_assoc,
      EuclideanSpace.inner_piLp_equiv_symm, star_star]
  · simp only [LDL.diag, hij, diagonal_apply_ne, Ne.def, not_false_iff, mul_mul_apply]
    rw [conj_transpose, transpose_map, transpose_transpose, dot_product_mul_vec,
      (LDL.lowerInv_orthogonal hS fun h : j = i => hij h.symm).symm, ← inner_conj_symm,
      mul_vec_transpose, EuclideanSpace.inner_piLp_equiv_symm, ← IsROrC.star_def, ←
      star_dot_product_star, dot_product_comm, star_star]
    rfl
#align LDL.diag_eq_lower_inv_conj LDL.diag_eq_lowerInv_conj
-/

#print LDL.lower /-
/-- The lower triangular matrix `L` of the LDL decomposition. -/
noncomputable def LDL.lower :=
  (LDL.lowerInv hS)⁻¹
#align LDL.lower LDL.lower
-/

#print LDL.lower_conj_diag /-
/-- **LDL decomposition**: any positive definite matrix `S` can be
decomposed as `S = LDLᴴ` where `L` is a lower-triangular matrix and `D` is a diagonal matrix.  -/
theorem LDL.lower_conj_diag : LDL.lower hS ⬝ LDL.diag hS ⬝ (LDL.lower hS)ᴴ = S :=
  by
  rw [LDL.lower, conj_transpose_nonsing_inv, Matrix.mul_assoc,
    Matrix.inv_mul_eq_iff_eq_mul_of_invertible (LDL.lowerInv hS),
    Matrix.mul_inv_eq_iff_eq_mul_of_invertible]
  exact LDL.diag_eq_lowerInv_conj hS
#align LDL.lower_conj_diag LDL.lower_conj_diag
-/

