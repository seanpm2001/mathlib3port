/-
Copyright (c) 2022 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module analysis.normed_space.matrix_exponential
! leanprover-community/mathlib commit 5d0c76894ada7940957143163d7b921345474cbc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Exponential
import Mathbin.Analysis.Matrix
import Mathbin.LinearAlgebra.Matrix.Zpow
import Mathbin.LinearAlgebra.Matrix.Hermitian
import Mathbin.LinearAlgebra.Matrix.Symmetric
import Mathbin.Topology.UniformSpace.Matrix

/-!
# Lemmas about the matrix exponential

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we provide results about `exp` on `matrix`s over a topological or normed algebra.
Note that generic results over all topological spaces such as `exp_zero` can be used on matrices
without issue, so are not repeated here. The topological results specific to matrices are:

* `matrix.exp_transpose`
* `matrix.exp_conj_transpose`
* `matrix.exp_diagonal`
* `matrix.exp_block_diagonal`
* `matrix.exp_block_diagonal'`

Lemmas like `exp_add_of_commute` require a canonical norm on the type; while there are multiple
sensible choices for the norm of a `matrix` (`matrix.normed_add_comm_group`,
`matrix.frobenius_normed_add_comm_group`, `matrix.linfty_op_normed_add_comm_group`), none of them
are canonical. In an application where a particular norm is chosen using
`local attribute [instance]`, then the usual lemmas about `exp` are fine. When choosing a norm is
undesirable, the results in this file can be used.

In this file, we copy across the lemmas about `exp`, but hide the requirement for a norm inside the
proof.

* `matrix.exp_add_of_commute`
* `matrix.exp_sum_of_commute`
* `matrix.exp_nsmul`
* `matrix.is_unit_exp`
* `matrix.exp_units_conj`
* `matrix.exp_units_conj'`

Additionally, we prove some results about `matrix.has_inv` and `matrix.div_inv_monoid`, as the
results for general rings are instead stated about `ring.inverse`:

* `matrix.exp_neg`
* `matrix.exp_zsmul`
* `matrix.exp_conj`
* `matrix.exp_conj'`

## Implementation notes

This file runs into some sharp edges on typeclass search in lean 3, especially regarding pi types.
To work around this, we copy a handful of instances for when lean can't find them by itself.
Hopefully we will be able to remove these in Lean 4.

## TODO

* Show that `matrix.det (exp 𝕂 A) = exp 𝕂 (matrix.trace A)`

## References

* https://en.wikipedia.org/wiki/Matrix_exponential
-/


open scoped Matrix BigOperators

section HacksForPiInstanceSearch

#print Function.topologicalRing /-
/-- A special case of `pi.topological_ring` for when `R` is not dependently typed. -/
instance Function.topologicalRing (I : Type _) (R : Type _) [NonUnitalRing R] [TopologicalSpace R]
    [TopologicalRing R] : TopologicalRing (I → R) :=
  Pi.instTopologicalRing
#align function.topological_ring Function.topologicalRing
-/

#print Function.algebraRing /-
/-- A special case of `function.algebra` for when A is a `ring` not a `semiring` -/
instance Function.algebraRing (I : Type _) {R : Type _} (A : Type _) [CommSemiring R] [Ring A]
    [Algebra R A] : Algebra R (I → A) :=
  Pi.algebra _ _
#align function.algebra_ring Function.algebraRing
-/

#print Pi.matrixAlgebra /-
/-- A special case of `pi.algebra` for when `f = λ i, matrix (m i) (m i) A`. -/
instance Pi.matrixAlgebra (I R A : Type _) (m : I → Type _) [CommSemiring R] [Semiring A]
    [Algebra R A] [∀ i, Fintype (m i)] [∀ i, DecidableEq (m i)] :
    Algebra R (∀ i, Matrix (m i) (m i) A) :=
  @Pi.algebra I R (fun i => Matrix (m i) (m i) A) _ _ fun i => Matrix.instAlgebra
#align pi.matrix_algebra Pi.matrixAlgebra
-/

#print Pi.matrix_topologicalRing /-
/-- A special case of `pi.topological_ring` for when `f = λ i, matrix (m i) (m i) A`. -/
instance Pi.matrix_topologicalRing (I A : Type _) (m : I → Type _) [Ring A] [TopologicalSpace A]
    [TopologicalRing A] [∀ i, Fintype (m i)] : TopologicalRing (∀ i, Matrix (m i) (m i) A) :=
  @Pi.instTopologicalRing _ (fun i => Matrix (m i) (m i) A) _ _ fun i => Matrix.topologicalRing
#align pi.matrix_topological_ring Pi.matrix_topologicalRing
-/

end HacksForPiInstanceSearch

variable (𝕂 : Type _) {m n p : Type _} {n' : m → Type _} {𝔸 : Type _}

namespace Matrix

section Topological

section Ring

variable [Fintype m] [DecidableEq m] [Fintype n] [DecidableEq n] [∀ i, Fintype (n' i)]
  [∀ i, DecidableEq (n' i)] [Field 𝕂] [Ring 𝔸] [TopologicalSpace 𝔸] [TopologicalRing 𝔸]
  [Algebra 𝕂 𝔸] [T2Space 𝔸]

#print Matrix.exp_diagonal /-
theorem exp_diagonal (v : m → 𝔸) : exp 𝕂 (diagonal v) = diagonal (exp 𝕂 v) := by
  simp_rw [exp_eq_tsum, diagonal_pow, ← diagonal_smul, ← diagonal_tsum]
#align matrix.exp_diagonal Matrix.exp_diagonal
-/

#print Matrix.exp_blockDiagonal /-
theorem exp_blockDiagonal (v : m → Matrix n n 𝔸) :
    exp 𝕂 (blockDiagonal v) = blockDiagonal (exp 𝕂 v) := by
  simp_rw [exp_eq_tsum, ← block_diagonal_pow, ← block_diagonal_smul, ← block_diagonal_tsum]
#align matrix.exp_block_diagonal Matrix.exp_blockDiagonal
-/

#print Matrix.exp_blockDiagonal' /-
theorem exp_blockDiagonal' (v : ∀ i, Matrix (n' i) (n' i) 𝔸) :
    exp 𝕂 (blockDiagonal' v) = blockDiagonal' (exp 𝕂 v) := by
  simp_rw [exp_eq_tsum, ← block_diagonal'_pow, ← block_diagonal'_smul, ← block_diagonal'_tsum]
#align matrix.exp_block_diagonal' Matrix.exp_blockDiagonal'
-/

#print Matrix.exp_conjTranspose /-
theorem exp_conjTranspose [StarRing 𝔸] [ContinuousStar 𝔸] (A : Matrix m m 𝔸) :
    exp 𝕂 Aᴴ = (exp 𝕂 A)ᴴ :=
  (star_exp A).symm
#align matrix.exp_conj_transpose Matrix.exp_conjTranspose
-/

#print Matrix.IsHermitian.exp /-
theorem IsHermitian.exp [StarRing 𝔸] [ContinuousStar 𝔸] {A : Matrix m m 𝔸} (h : A.IsHermitian) :
    (exp 𝕂 A).IsHermitian :=
  (exp_conjTranspose _ _).symm.trans <| congr_arg _ h
#align matrix.is_hermitian.exp Matrix.IsHermitian.exp
-/

end Ring

section CommRing

variable [Fintype m] [DecidableEq m] [Field 𝕂] [CommRing 𝔸] [TopologicalSpace 𝔸] [TopologicalRing 𝔸]
  [Algebra 𝕂 𝔸] [T2Space 𝔸]

#print Matrix.exp_transpose /-
theorem exp_transpose (A : Matrix m m 𝔸) : exp 𝕂 Aᵀ = (exp 𝕂 A)ᵀ := by
  simp_rw [exp_eq_tsum, transpose_tsum, transpose_smul, transpose_pow]
#align matrix.exp_transpose Matrix.exp_transpose
-/

#print Matrix.IsSymm.exp /-
theorem IsSymm.exp {A : Matrix m m 𝔸} (h : A.IsSymm) : (exp 𝕂 A).IsSymm :=
  (exp_transpose _ _).symm.trans <| congr_arg _ h
#align matrix.is_symm.exp Matrix.IsSymm.exp
-/

end CommRing

end Topological

section Normed

variable [IsROrC 𝕂] [Fintype m] [DecidableEq m] [Fintype n] [DecidableEq n] [∀ i, Fintype (n' i)]
  [∀ i, DecidableEq (n' i)] [NormedRing 𝔸] [NormedAlgebra 𝕂 𝔸] [CompleteSpace 𝔸]

#print Matrix.exp_add_of_commute /-
theorem exp_add_of_commute (A B : Matrix m m 𝔸) (h : Commute A B) :
    exp 𝕂 (A + B) = exp 𝕂 A ⬝ exp 𝕂 B :=
  by
  letI : SeminormedRing (Matrix m m 𝔸) := Matrix.linftyOpSemiNormedRing
  letI : NormedRing (Matrix m m 𝔸) := Matrix.linftyOpNormedRing
  letI : NormedAlgebra 𝕂 (Matrix m m 𝔸) := Matrix.linftyOpNormedAlgebra
  exact exp_add_of_commute h
#align matrix.exp_add_of_commute Matrix.exp_add_of_commute
-/

#print Matrix.exp_sum_of_commute /-
theorem exp_sum_of_commute {ι} (s : Finset ι) (f : ι → Matrix m m 𝔸)
    (h : (s : Set ι).Pairwise fun i j => Commute (f i) (f j)) :
    exp 𝕂 (∑ i in s, f i) =
      s.noncommProd (fun i => exp 𝕂 (f i)) fun i hi j hj _ => (h.of_refl hi hj).exp 𝕂 :=
  by
  letI : SeminormedRing (Matrix m m 𝔸) := Matrix.linftyOpSemiNormedRing
  letI : NormedRing (Matrix m m 𝔸) := Matrix.linftyOpNormedRing
  letI : NormedAlgebra 𝕂 (Matrix m m 𝔸) := Matrix.linftyOpNormedAlgebra
  exact exp_sum_of_commute s f h
#align matrix.exp_sum_of_commute Matrix.exp_sum_of_commute
-/

#print Matrix.exp_nsmul /-
theorem exp_nsmul (n : ℕ) (A : Matrix m m 𝔸) : exp 𝕂 (n • A) = exp 𝕂 A ^ n :=
  by
  letI : SeminormedRing (Matrix m m 𝔸) := Matrix.linftyOpSemiNormedRing
  letI : NormedRing (Matrix m m 𝔸) := Matrix.linftyOpNormedRing
  letI : NormedAlgebra 𝕂 (Matrix m m 𝔸) := Matrix.linftyOpNormedAlgebra
  exact exp_nsmul n A
#align matrix.exp_nsmul Matrix.exp_nsmul
-/

#print Matrix.isUnit_exp /-
theorem isUnit_exp (A : Matrix m m 𝔸) : IsUnit (exp 𝕂 A) :=
  by
  letI : SeminormedRing (Matrix m m 𝔸) := Matrix.linftyOpSemiNormedRing
  letI : NormedRing (Matrix m m 𝔸) := Matrix.linftyOpNormedRing
  letI : NormedAlgebra 𝕂 (Matrix m m 𝔸) := Matrix.linftyOpNormedAlgebra
  exact isUnit_exp _ A
#align matrix.is_unit_exp Matrix.isUnit_exp
-/

#print Matrix.exp_units_conj /-
theorem exp_units_conj (U : (Matrix m m 𝔸)ˣ) (A : Matrix m m 𝔸) :
    exp 𝕂 (↑U ⬝ A ⬝ ↑U⁻¹ : Matrix m m 𝔸) = ↑U ⬝ exp 𝕂 A ⬝ ↑U⁻¹ :=
  by
  letI : SeminormedRing (Matrix m m 𝔸) := Matrix.linftyOpSemiNormedRing
  letI : NormedRing (Matrix m m 𝔸) := Matrix.linftyOpNormedRing
  letI : NormedAlgebra 𝕂 (Matrix m m 𝔸) := Matrix.linftyOpNormedAlgebra
  exact exp_units_conj _ U A
#align matrix.exp_units_conj Matrix.exp_units_conj
-/

#print Matrix.exp_units_conj' /-
theorem exp_units_conj' (U : (Matrix m m 𝔸)ˣ) (A : Matrix m m 𝔸) :
    exp 𝕂 (↑U⁻¹ ⬝ A ⬝ U : Matrix m m 𝔸) = ↑U⁻¹ ⬝ exp 𝕂 A ⬝ U :=
  exp_units_conj 𝕂 U⁻¹ A
#align matrix.exp_units_conj' Matrix.exp_units_conj'
-/

end Normed

section NormedComm

variable [IsROrC 𝕂] [Fintype m] [DecidableEq m] [Fintype n] [DecidableEq n] [∀ i, Fintype (n' i)]
  [∀ i, DecidableEq (n' i)] [NormedCommRing 𝔸] [NormedAlgebra 𝕂 𝔸] [CompleteSpace 𝔸]

#print Matrix.exp_neg /-
theorem exp_neg (A : Matrix m m 𝔸) : exp 𝕂 (-A) = (exp 𝕂 A)⁻¹ :=
  by
  rw [nonsing_inv_eq_ring_inverse]
  letI : SeminormedRing (Matrix m m 𝔸) := Matrix.linftyOpSemiNormedRing
  letI : NormedRing (Matrix m m 𝔸) := Matrix.linftyOpNormedRing
  letI : NormedAlgebra 𝕂 (Matrix m m 𝔸) := Matrix.linftyOpNormedAlgebra
  exact (Ring.inverse_exp _ A).symm
#align matrix.exp_neg Matrix.exp_neg
-/

#print Matrix.exp_zsmul /-
theorem exp_zsmul (z : ℤ) (A : Matrix m m 𝔸) : exp 𝕂 (z • A) = exp 𝕂 A ^ z :=
  by
  obtain ⟨n, rfl | rfl⟩ := z.eq_coe_or_neg
  · rw [zpow_ofNat, coe_nat_zsmul, exp_nsmul]
  · have : IsUnit (exp 𝕂 A).det := (Matrix.isUnit_iff_isUnit_det _).mp (isUnit_exp _ _)
    rw [Matrix.zpow_neg this, zpow_ofNat, neg_smul, exp_neg, coe_nat_zsmul, exp_nsmul]
#align matrix.exp_zsmul Matrix.exp_zsmul
-/

#print Matrix.exp_conj /-
theorem exp_conj (U : Matrix m m 𝔸) (A : Matrix m m 𝔸) (hy : IsUnit U) :
    exp 𝕂 (U ⬝ A ⬝ U⁻¹) = U ⬝ exp 𝕂 A ⬝ U⁻¹ :=
  let ⟨u, hu⟩ := hy
  hu ▸ by simpa only [Matrix.coe_units_inv] using exp_units_conj 𝕂 u A
#align matrix.exp_conj Matrix.exp_conj
-/

#print Matrix.exp_conj' /-
theorem exp_conj' (U : Matrix m m 𝔸) (A : Matrix m m 𝔸) (hy : IsUnit U) :
    exp 𝕂 (U⁻¹ ⬝ A ⬝ U) = U⁻¹ ⬝ exp 𝕂 A ⬝ U :=
  let ⟨u, hu⟩ := hy
  hu ▸ by simpa only [Matrix.coe_units_inv] using exp_units_conj' 𝕂 u A
#align matrix.exp_conj' Matrix.exp_conj'
-/

end NormedComm

end Matrix

