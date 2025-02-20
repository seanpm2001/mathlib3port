/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Eric Wieer

! This file was ported from Lean 3 source module data.matrix.rank
! leanprover-community/mathlib commit fe8d0ff42c3c24d789f491dc2622b6cac3d61564
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.FreeModule.Finite.Rank
import Mathbin.LinearAlgebra.Matrix.ToLin
import Mathbin.LinearAlgebra.FiniteDimensional
import Mathbin.LinearAlgebra.Matrix.DotProduct
import Mathbin.Data.Complex.Module

/-!
# Rank of matrices

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The rank of a matrix `A` is defined to be the rank of range of the linear map corresponding to `A`.
This definition does not depend on the choice of basis, see `matrix.rank_eq_finrank_range_to_lin`.

## Main declarations

* `matrix.rank`: the rank of a matrix

## TODO

* Do a better job of generalizing over `ℚ`, `ℝ`, and `ℂ` in `matrix.rank_transpose` and
  `matrix.rank_conj_transpose`. See
  [this Zulip thread](https://leanprover.zulipchat.com/#narrow/stream/116395-maths/topic/row.20rank.20equals.20column.20rank/near/350462992).

-/


open scoped Matrix

namespace Matrix

open FiniteDimensional

variable {l m n o R : Type _} [m_fin : Fintype m] [Fintype n] [Fintype o]

section CommRing

variable [CommRing R]

#print Matrix.rank /-
/-- The rank of a matrix is the rank of its image. -/
noncomputable def rank (A : Matrix m n R) : ℕ :=
  finrank R A.mulVecLin.range
#align matrix.rank Matrix.rank
-/

#print Matrix.rank_one /-
@[simp]
theorem rank_one [StrongRankCondition R] [DecidableEq n] :
    rank (1 : Matrix n n R) = Fintype.card n := by
  rw [rank, mul_vec_lin_one, LinearMap.range_id, finrank_top, finrank_pi]
#align matrix.rank_one Matrix.rank_one
-/

#print Matrix.rank_zero /-
@[simp]
theorem rank_zero [Nontrivial R] : rank (0 : Matrix m n R) = 0 := by
  rw [rank, mul_vec_lin_zero, LinearMap.range_zero, finrank_bot]
#align matrix.rank_zero Matrix.rank_zero
-/

#print Matrix.rank_le_card_width /-
theorem rank_le_card_width [StrongRankCondition R] (A : Matrix m n R) : A.rank ≤ Fintype.card n :=
  by
  haveI : Module.Finite R (n → R) := Module.Finite.pi
  haveI : Module.Free R (n → R) := Module.Free.pi _ _
  exact A.mul_vec_lin.finrank_range_le.trans_eq (finrank_pi _)
#align matrix.rank_le_card_width Matrix.rank_le_card_width
-/

#print Matrix.rank_le_width /-
theorem rank_le_width [StrongRankCondition R] {m n : ℕ} (A : Matrix (Fin m) (Fin n) R) :
    A.rank ≤ n :=
  A.rank_le_card_width.trans <| (Fintype.card_fin n).le
#align matrix.rank_le_width Matrix.rank_le_width
-/

#print Matrix.rank_mul_le_left /-
theorem rank_mul_le_left [StrongRankCondition R] (A : Matrix m n R) (B : Matrix n o R) :
    (A ⬝ B).rank ≤ A.rank := by
  rw [rank, rank, mul_vec_lin_mul]
  exact Cardinal.toNat_le_of_le_of_lt_aleph0 (rank_lt_aleph_0 _ _) (LinearMap.rank_comp_le_left _ _)
#align matrix.rank_mul_le_left Matrix.rank_mul_le_left
-/

#print Matrix.rank_mul_le_right /-
theorem rank_mul_le_right [StrongRankCondition R] (A : Matrix l m R) (B : Matrix m n R) :
    (A ⬝ B).rank ≤ B.rank := by
  rw [rank, rank, mul_vec_lin_mul]
  exact
    finrank_le_finrank_of_rank_le_rank (LinearMap.lift_rank_comp_le_right _ _) (rank_lt_aleph_0 _ _)
#align matrix.rank_mul_le_right Matrix.rank_mul_le_right
-/

#print Matrix.rank_mul_le /-
theorem rank_mul_le [StrongRankCondition R] (A : Matrix m n R) (B : Matrix n o R) :
    (A ⬝ B).rank ≤ min A.rank B.rank :=
  le_min (rank_mul_le_left _ _) (rank_mul_le_right _ _)
#align matrix.rank_mul_le Matrix.rank_mul_le
-/

#print Matrix.rank_unit /-
theorem rank_unit [StrongRankCondition R] [DecidableEq n] (A : (Matrix n n R)ˣ) :
    (A : Matrix n n R).rank = Fintype.card n :=
  by
  refine' le_antisymm (rank_le_card_width A) _
  have := rank_mul_le_left (A : Matrix n n R) (↑A⁻¹ : Matrix n n R)
  rwa [← mul_eq_mul, ← Units.val_mul, mul_inv_self, Units.val_one, rank_one] at this 
#align matrix.rank_unit Matrix.rank_unit
-/

#print Matrix.rank_of_isUnit /-
theorem rank_of_isUnit [StrongRankCondition R] [DecidableEq n] (A : Matrix n n R) (h : IsUnit A) :
    A.rank = Fintype.card n := by obtain ⟨A, rfl⟩ := h; exact rank_unit A
#align matrix.rank_of_is_unit Matrix.rank_of_isUnit
-/

#print Matrix.rank_submatrix_le /-
/-- Taking a subset of the rows and permuting the columns reduces the rank. -/
theorem rank_submatrix_le [StrongRankCondition R] [Fintype m] (f : n → m) (e : n ≃ m)
    (A : Matrix m m R) : rank (A.submatrix f e) ≤ rank A :=
  by
  rw [rank, rank, mul_vec_lin_submatrix, LinearMap.range_comp, LinearMap.range_comp,
    show LinearMap.funLeft R R e.symm = LinearEquiv.funCongrLeft R R e.symm from rfl,
    LinearEquiv.range, Submodule.map_top]
  exact Submodule.finrank_map_le _ _
#align matrix.rank_submatrix_le Matrix.rank_submatrix_le
-/

#print Matrix.rank_reindex /-
theorem rank_reindex [Fintype m] (e₁ e₂ : m ≃ n) (A : Matrix m m R) :
    rank (reindex e₁ e₂ A) = rank A := by
  rw [rank, rank, mul_vec_lin_reindex, LinearMap.range_comp, LinearMap.range_comp,
    LinearEquiv.range, Submodule.map_top, LinearEquiv.finrank_map_eq]
#align matrix.rank_reindex Matrix.rank_reindex
-/

#print Matrix.rank_submatrix /-
@[simp]
theorem rank_submatrix [Fintype m] (A : Matrix m m R) (e₁ e₂ : n ≃ m) :
    rank (A.submatrix e₁ e₂) = rank A := by
  simpa only [reindex_apply] using rank_reindex e₁.symm e₂.symm A
#align matrix.rank_submatrix Matrix.rank_submatrix
-/

#print Matrix.rank_eq_finrank_range_toLin /-
theorem rank_eq_finrank_range_toLin [DecidableEq n] {M₁ M₂ : Type _} [AddCommGroup M₁]
    [AddCommGroup M₂] [Module R M₁] [Module R M₂] (A : Matrix m n R) (v₁ : Basis m R M₁)
    (v₂ : Basis n R M₂) : A.rank = finrank R (toLin v₂ v₁ A).range :=
  by
  let e₁ := (Pi.basisFun R m).Equiv v₁ (Equiv.refl _)
  let e₂ := (Pi.basisFun R n).Equiv v₂ (Equiv.refl _)
  have range_e₂ : (e₂ : (n → R) →ₗ[R] M₂).range = ⊤ := by rw [LinearMap.range_eq_top];
    exact e₂.surjective
  refine' LinearEquiv.finrank_eq (e₁.of_submodules _ _ _)
  rw [← LinearMap.range_comp, ← LinearMap.range_comp_of_range_eq_top (to_lin v₂ v₁ A) range_e₂]
  congr 1
  apply LinearMap.pi_ext'; rintro i; apply LinearMap.ext_ring
  have aux₁ := to_lin_self (Pi.basisFun R n) (Pi.basisFun R m) A i
  have aux₂ := Basis.equiv_apply (Pi.basisFun R n) i v₂
  rw [to_lin_eq_to_lin', to_lin'_apply'] at aux₁ 
  rw [Pi.basisFun_apply, LinearMap.coe_stdBasis] at aux₁ aux₂ 
  simp only [LinearMap.comp_apply, e₁, e₂, LinearEquiv.coe_coe, Equiv.refl_apply, aux₁, aux₂,
    LinearMap.coe_single, to_lin_self, LinearEquiv.map_sum, LinearEquiv.map_smul, Basis.equiv_apply]
#align matrix.rank_eq_finrank_range_to_lin Matrix.rank_eq_finrank_range_toLin
-/

#print Matrix.rank_le_card_height /-
theorem rank_le_card_height [StrongRankCondition R] (A : Matrix m n R) : A.rank ≤ Fintype.card m :=
  by
  haveI : Module.Finite R (m → R) := Module.Finite.pi
  haveI : Module.Free R (m → R) := Module.Free.pi _ _
  exact (Submodule.finrank_le _).trans (finrank_pi R).le
#align matrix.rank_le_card_height Matrix.rank_le_card_height
-/

#print Matrix.rank_le_height /-
theorem rank_le_height [StrongRankCondition R] {m n : ℕ} (A : Matrix (Fin m) (Fin n) R) :
    A.rank ≤ m :=
  A.rank_le_card_height.trans <| (Fintype.card_fin m).le
#align matrix.rank_le_height Matrix.rank_le_height
-/

#print Matrix.rank_eq_finrank_span_cols /-
/-- The rank of a matrix is the rank of the space spanned by its columns. -/
theorem rank_eq_finrank_span_cols (A : Matrix m n R) :
    A.rank = finrank R (Submodule.span R (Set.range Aᵀ)) := by rw [rank, Matrix.range_mulVecLin]
#align matrix.rank_eq_finrank_span_cols Matrix.rank_eq_finrank_span_cols
-/

end CommRing

/-! ### Lemmas about transpose and conjugate transpose

This section contains lemmas about the rank of `matrix.transpose` and `matrix.conj_transpose`.

Unfortunately the proofs are essentially duplicated between the two; `ℚ` is a linearly-ordered ring
but can't be a star-ordered ring, while `ℂ` is star-ordered (with `open_locale complex_order`) but
not linearly ordered. For now we don't prove the transpose case for `ℂ`.

TODO: the lemmas `matrix.rank_transpose` and `matrix.rank_conj_transpose` current follow a short
proof that is a simple consequence of `matrix.rank_transpose_mul_self` and
`matrix.rank_conj_transpose_mul_self`. This proof pulls in unecessary assumptions on `R`, and should
be replaced with a proof that uses Gaussian reduction or argues via linear combinations.
-/


section StarOrderedField

variable [Fintype m] [Field R] [PartialOrder R] [StarOrderedRing R]

#print Matrix.ker_mulVecLin_conjTranspose_mul_self /-
theorem ker_mulVecLin_conjTranspose_mul_self (A : Matrix m n R) :
    LinearMap.ker (Aᴴ ⬝ A).mulVecLin = LinearMap.ker (mulVecLin A) :=
  by
  ext x
  simp only [LinearMap.mem_ker, mul_vec_lin_apply, ← mul_vec_mul_vec]
  constructor
  · intro h
    replace h := congr_arg (dot_product (star x)) h
    rwa [dot_product_mul_vec, dot_product_zero, vec_mul_conj_transpose, star_star,
      dot_product_star_self_eq_zero] at h 
  · intro h; rw [h, mul_vec_zero]
#align matrix.ker_mul_vec_lin_conj_transpose_mul_self Matrix.ker_mulVecLin_conjTranspose_mul_self
-/

#print Matrix.rank_conjTranspose_mul_self /-
theorem rank_conjTranspose_mul_self (A : Matrix m n R) : (Aᴴ ⬝ A).rank = A.rank :=
  by
  dsimp only [rank]
  refine' add_left_injective (finrank R A.mul_vec_lin.ker) _
  dsimp only
  rw [LinearMap.finrank_range_add_finrank_ker, ← (Aᴴ ⬝ A).mulVecLin.finrank_range_add_finrank_ker]
  congr 1
  rw [ker_mul_vec_lin_conj_transpose_mul_self]
#align matrix.rank_conj_transpose_mul_self Matrix.rank_conjTranspose_mul_self
-/

#print Matrix.rank_conjTranspose /-
-- this follows the proof here https://math.stackexchange.com/a/81903/1896
/-- TODO: prove this in greater generality. -/
@[simp]
theorem rank_conjTranspose (A : Matrix m n R) : Aᴴ.rank = A.rank :=
  le_antisymm
    (((rank_conjTranspose_mul_self _).symm.trans_le <| rank_mul_le_left _ _).trans_eq <|
      congr_arg _ <| conjTranspose_conjTranspose _)
    ((rank_conjTranspose_mul_self _).symm.trans_le <| rank_mul_le_left _ _)
#align matrix.rank_conj_transpose Matrix.rank_conjTranspose
-/

#print Matrix.rank_self_mul_conjTranspose /-
@[simp]
theorem rank_self_mul_conjTranspose (A : Matrix m n R) : (A ⬝ Aᴴ).rank = A.rank := by
  simpa only [rank_conj_transpose, conj_transpose_conj_transpose] using
    rank_conj_transpose_mul_self Aᴴ
#align matrix.rank_self_mul_conj_transpose Matrix.rank_self_mul_conjTranspose
-/

end StarOrderedField

section LinearOrderedField

variable [Fintype m] [LinearOrderedField R]

#print Matrix.ker_mulVecLin_transpose_mul_self /-
theorem ker_mulVecLin_transpose_mul_self (A : Matrix m n R) :
    LinearMap.ker (Aᵀ ⬝ A).mulVecLin = LinearMap.ker (mulVecLin A) :=
  by
  ext x
  simp only [LinearMap.mem_ker, mul_vec_lin_apply, ← mul_vec_mul_vec]
  constructor
  · intro h
    replace h := congr_arg (dot_product x) h
    rwa [dot_product_mul_vec, dot_product_zero, vec_mul_transpose, dot_product_self_eq_zero] at h 
  · intro h; rw [h, mul_vec_zero]
#align matrix.ker_mul_vec_lin_transpose_mul_self Matrix.ker_mulVecLin_transpose_mul_self
-/

#print Matrix.rank_transpose_mul_self /-
theorem rank_transpose_mul_self (A : Matrix m n R) : (Aᵀ ⬝ A).rank = A.rank :=
  by
  dsimp only [rank]
  refine' add_left_injective (finrank R A.mul_vec_lin.ker) _
  dsimp only
  rw [LinearMap.finrank_range_add_finrank_ker, ← (Aᵀ ⬝ A).mulVecLin.finrank_range_add_finrank_ker]
  congr 1
  rw [ker_mul_vec_lin_transpose_mul_self]
#align matrix.rank_transpose_mul_self Matrix.rank_transpose_mul_self
-/

#print Matrix.rank_transpose /-
/-- TODO: prove this in greater generality. -/
@[simp]
theorem rank_transpose (A : Matrix m n R) : Aᵀ.rank = A.rank :=
  le_antisymm ((rank_transpose_mul_self _).symm.trans_le <| rank_mul_le_left _ _)
    ((rank_transpose_mul_self _).symm.trans_le <| rank_mul_le_left _ _)
#align matrix.rank_transpose Matrix.rank_transpose
-/

#print Matrix.rank_self_mul_transpose /-
@[simp]
theorem rank_self_mul_transpose (A : Matrix m n R) : (A ⬝ Aᵀ).rank = A.rank := by
  simpa only [rank_transpose, transpose_transpose] using rank_transpose_mul_self Aᵀ
#align matrix.rank_self_mul_transpose Matrix.rank_self_mul_transpose
-/

end LinearOrderedField

#print Matrix.rank_eq_finrank_span_row /-
/-- The rank of a matrix is the rank of the space spanned by its rows.

TODO: prove this in a generality that works for `ℂ` too, not just `ℚ` and `ℝ`. -/
theorem rank_eq_finrank_span_row [LinearOrderedField R] [Finite m] (A : Matrix m n R) :
    A.rank = finrank R (Submodule.span R (Set.range A)) :=
  by
  cases nonempty_fintype m
  rw [← rank_transpose, rank_eq_finrank_span_cols, transpose_transpose]
#align matrix.rank_eq_finrank_span_row Matrix.rank_eq_finrank_span_row
-/

end Matrix

