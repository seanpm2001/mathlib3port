/-
Copyright (c) 2020 Aaron Anderson, Jalex Stark. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson, Jalex Stark, Eric Wieser

! This file was ported from Lean 3 source module linear_algebra.matrix.charpoly.minpoly
! leanprover-community/mathlib commit 61db041ab8e4aaf8cb5c7dc10a7d4ff261997536
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Matrix.Charpoly.Coeff
import Mathbin.LinearAlgebra.Matrix.ToLin
import Mathbin.RingTheory.PowerBasis

/-!
# The minimal polynomial divides the characteristic polynomial of a matrix.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This also includes some miscellaneous results about `minpoly` on matrices.
-/


noncomputable section

universe u v w

open Polynomial Matrix

variable {R : Type u} [CommRing R]

variable {n : Type v} [DecidableEq n] [Fintype n]

variable {N : Type w} [AddCommGroup N] [Module R N]

open Finset

namespace Matrix

open scoped Matrix

variable (M : Matrix n n R)

#print Matrix.minpoly_toLin' /-
@[simp]
theorem minpoly_toLin' : minpoly R M.toLin' = minpoly R M :=
  minpoly.minpoly_algEquiv (toLinAlgEquiv' : Matrix n n R ≃ₐ[R] _) M
#align matrix.minpoly_to_lin' Matrix.minpoly_toLin'
-/

#print Matrix.minpoly_toLin /-
@[simp]
theorem minpoly_toLin (b : Basis n R N) (M : Matrix n n R) :
    minpoly R (toLin b b M) = minpoly R M :=
  minpoly.minpoly_algEquiv (toLinAlgEquiv b : Matrix n n R ≃ₐ[R] _) M
#align matrix.minpoly_to_lin Matrix.minpoly_toLin
-/

#print Matrix.isIntegral /-
theorem isIntegral : IsIntegral R M :=
  ⟨M.charpoly, ⟨charpoly_monic M, aeval_self_charpoly M⟩⟩
#align matrix.is_integral Matrix.isIntegral
-/

#print Matrix.minpoly_dvd_charpoly /-
theorem minpoly_dvd_charpoly {K : Type _} [Field K] (M : Matrix n n K) : minpoly K M ∣ M.charpoly :=
  minpoly.dvd _ _ (aeval_self_charpoly M)
#align matrix.minpoly_dvd_charpoly Matrix.minpoly_dvd_charpoly
-/

end Matrix

namespace LinearMap

#print LinearMap.minpoly_toMatrix' /-
@[simp]
theorem minpoly_toMatrix' (f : (n → R) →ₗ[R] n → R) : minpoly R f.toMatrix' = minpoly R f :=
  minpoly.minpoly_algEquiv (toMatrixAlgEquiv' : _ ≃ₐ[R] Matrix n n R) f
#align linear_map.minpoly_to_matrix' LinearMap.minpoly_toMatrix'
-/

#print LinearMap.minpoly_toMatrix /-
@[simp]
theorem minpoly_toMatrix (b : Basis n R N) (f : N →ₗ[R] N) :
    minpoly R (toMatrix b b f) = minpoly R f :=
  minpoly.minpoly_algEquiv (toMatrixAlgEquiv b : _ ≃ₐ[R] Matrix n n R) f
#align linear_map.minpoly_to_matrix LinearMap.minpoly_toMatrix
-/

end LinearMap

section PowerBasis

open Algebra

#print charpoly_leftMulMatrix /-
/-- The characteristic polynomial of the map `λ x, a * x` is the minimal polynomial of `a`.

In combination with `det_eq_sign_charpoly_coeff` or `trace_eq_neg_charpoly_coeff`
and a bit of rewriting, this will allow us to conclude the
field norm resp. trace of `x` is the product resp. sum of `x`'s conjugates.
-/
theorem charpoly_leftMulMatrix {S : Type _} [Ring S] [Algebra R S] (h : PowerBasis R S) :
    (leftMulMatrix h.Basis h.gen).charpoly = minpoly R h.gen :=
  by
  cases subsingleton_or_nontrivial R; · apply Subsingleton.elim
  apply minpoly.unique' R h.gen (charpoly_monic _)
  · apply (injective_iff_map_eq_zero (left_mul_matrix _)).mp (left_mul_matrix_injective h.basis)
    rw [← Polynomial.aeval_algHom_apply, aeval_self_charpoly]
  refine' fun q hq => or_iff_not_imp_left.2 fun h0 => _
  rw [Matrix.charpoly_degree_eq_dim, Fintype.card_fin] at hq 
  contrapose! hq; exact h.dim_le_degree_of_root h0 hq
#align charpoly_left_mul_matrix charpoly_leftMulMatrix
-/

end PowerBasis

