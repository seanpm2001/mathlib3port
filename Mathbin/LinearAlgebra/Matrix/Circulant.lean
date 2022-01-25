import Mathbin.LinearAlgebra.Matrix.Symmetric

/-!
# Circulant matrices

This file contains the definition and basic results about circulant matrices.
Given a vector `v : n → α` indexed by a type that is endowed with subtraction,
`matrix.circulant v` is the matrix whose `(i, j)`th entry is `v (i - j)`.

## Main results

- `matrix.circulant`: the circulant matrix generated by a given vector `v : n → α`.
- `matrix.circulant_mul`: the product of two circulant matrices `circulant v` and `circulant w` is
                          the circulant matrix generated by `mul_vec (circulant v) w`.
- `matrix.circulant_mul_comm`: multiplication of circulant matrices commutes when the elements do.

## Implementation notes

`matrix.fin.foo` is the `fin n` version of `matrix.foo`.
Namely, the index type of the circulant matrices in discussion is `fin n`.

## Tags

circulant, matrix
-/


variable {α β m n R : Type _}

namespace Matrix

open Function

open_locale Matrix BigOperators

/-- Given the condition `[has_sub n]` and a vector `v : n → α`,
    we define `circulant v` to be the circulant matrix generated by `v` of type `matrix n n α`.
    The `(i,j)`th entry is defined to be `v (i - j)`. -/
@[simp]
def circulant [Sub n] (v : n → α) : Matrix n n α
  | i, j => v (i - j)

theorem circulant_col_zero_eq [AddGroupₓ n] (v : n → α) (i : n) : circulant v i 0 = v i :=
  congr_argₓ v (sub_zero _)

theorem circulant_injective [AddGroupₓ n] : injective (circulant : (n → α) → Matrix n n α) := by
  intro v w h
  ext k
  rw [← circulant_col_zero_eq v, ← circulant_col_zero_eq w, h]

theorem fin.circulant_injective : ∀ n, injective fun v : Finₓ n → α => circulant v
  | 0 => by
    decide
  | n + 1 => circulant_injective

@[simp]
theorem circulant_inj [AddGroupₓ n] {v w : n → α} : circulant v = circulant w ↔ v = w :=
  circulant_injective.eq_iff

@[simp]
theorem fin.circulant_inj {n} {v w : Finₓ n → α} : circulant v = circulant w ↔ v = w :=
  (fin.circulant_injective n).eq_iff

theorem transpose_circulant [AddGroupₓ n] (v : n → α) : (circulant v)ᵀ = circulant fun i => v (-i) := by
  ext <;> simp

theorem conj_transpose_circulant [HasStar α] [AddGroupₓ n] (v : n → α) :
    (circulant v)ᴴ = circulant (star fun i => v (-i)) := by
  ext <;> simp

theorem fin.transpose_circulant : ∀ {n} v : Finₓ n → α, (circulant v)ᵀ = circulant fun i => v (-i)
  | 0 => by
    decide
  | n + 1 => transpose_circulant

theorem fin.conj_transpose_circulant [HasStar α] :
    ∀ {n} v : Finₓ n → α, (circulant v)ᴴ = circulant (star fun i => v (-i))
  | 0 => by
    decide
  | n + 1 => conj_transpose_circulant

theorem map_circulant [Sub n] (v : n → α) (f : α → β) : (circulant v).map f = circulant fun i => f (v i) :=
  ext $ fun _ _ => rfl

theorem circulant_neg [Neg α] [Sub n] (v : n → α) : circulant (-v) = -circulant v :=
  ext $ fun _ _ => rfl

@[simp]
theorem circulant_zero α n [Zero α] [Sub n] : circulant 0 = (0 : Matrix n n α) :=
  ext $ fun _ _ => rfl

theorem circulant_add [Add α] [Sub n] (v w : n → α) : circulant (v + w) = circulant v + circulant w :=
  ext $ fun _ _ => rfl

theorem circulant_sub [Sub α] [Sub n] (v w : n → α) : circulant (v - w) = circulant v - circulant w :=
  ext $ fun _ _ => rfl

/-- The product of two circulant matrices `circulant v` and `circulant w` is
    the circulant matrix generated by `mul_vec (circulant v) w`. -/
theorem circulant_mul [Semiringₓ α] [Fintype n] [AddGroupₓ n] (v w : n → α) :
    circulant v ⬝ circulant w = circulant (mul_vec (circulant v) w) := by
  ext i j
  simp only [mul_apply, mul_vec, circulant, dot_product]
  refine' Fintype.sum_equiv (Equivₓ.subRight j) _ _ _
  intro x
  simp only [Equivₓ.sub_right_apply, sub_sub_sub_cancel_right]

theorem fin.circulant_mul [Semiringₓ α] :
    ∀ {n} v w : Finₓ n → α, circulant v ⬝ circulant w = circulant (mul_vec (circulant v) w)
  | 0 => by
    decide
  | n + 1 => circulant_mul

/-- Multiplication of circulant matrices commutes when the elements do. -/
theorem circulant_mul_comm [CommSemigroupₓ α] [AddCommMonoidₓ α] [Fintype n] [AddCommGroupₓ n] (v w : n → α) :
    circulant v ⬝ circulant w = circulant w ⬝ circulant v := by
  ext i j
  simp only [mul_apply, circulant, mul_comm]
  refine' Fintype.sum_equiv ((Equivₓ.subLeft i).trans (Equivₓ.addRight j)) _ _ _
  intro x
  congr 2
  · simp
    
  · simp only [Equivₓ.coe_add_right, Function.comp_app, Equivₓ.coe_trans, Equivₓ.sub_left_apply]
    abel
    

theorem fin.circulant_mul_comm [CommSemigroupₓ α] [AddCommMonoidₓ α] :
    ∀ {n} v w : Finₓ n → α, circulant v ⬝ circulant w = circulant w ⬝ circulant v
  | 0 => by
    decide
  | n + 1 => circulant_mul_comm

/-- `k • circulant v` is another circulant matrix `circulant (k • v)`. -/
theorem circulant_smul [Sub n] [HasScalar R α] (k : R) (v : n → α) : circulant (k • v) = k • circulant v := by
  ext <;> simp

@[simp]
theorem circulant_single_one α n [Zero α] [One α] [DecidableEq n] [AddGroupₓ n] :
    circulant (Pi.single 0 1 : n → α) = (1 : Matrix n n α) := by
  ext i j
  simp [one_apply, Pi.single_apply, sub_eq_zero]

@[simp]
theorem circulant_single n [Semiringₓ α] [DecidableEq n] [AddGroupₓ n] [Fintype n] (a : α) :
    circulant (Pi.single 0 a : n → α) = scalar n a := by
  ext i j
  simp [Pi.single_apply, one_apply, sub_eq_zero]

/-- Note we use `↑i = 0` instead of `i = 0` as `fin 0` has no `0`.
This means that we cannot state this with `pi.single` as we did with `matrix.circulant_single`. -/
theorem fin.circulant_ite α [Zero α] [One α] : ∀ n, circulant (fun i => ite (↑i = 0) 1 0 : Finₓ n → α) = 1
  | 0 => by
    decide
  | n + 1 => by
    rw [← circulant_single_one]
    congr with j
    simp only [Pi.single_apply, Finₓ.ext_iff]
    congr

/-- A circulant of `v` is symmetric iff `v` equals its reverse. -/
theorem circulant_is_symm_iff [AddGroupₓ n] {v : n → α} : (circulant v).IsSymm ↔ ∀ i, v (-i) = v i := by
  rw [IsSymm, transpose_circulant, circulant_inj, funext_iff]

theorem fin.circulant_is_symm_iff : ∀ {n} {v : Finₓ n → α}, (circulant v).IsSymm ↔ ∀ i, v (-i) = v i
  | 0 => fun v => by
    simp [is_symm.ext_iff, IsEmpty.forall_iff]
  | n + 1 => fun v => circulant_is_symm_iff

/-- If `circulant v` is symmetric, `∀ i j : I, v (- i) = v i`. -/
theorem circulant_is_symm_apply [AddGroupₓ n] {v : n → α} (h : (circulant v).IsSymm) (i : n) : v (-i) = v i :=
  circulant_is_symm_iff.1 h i

theorem fin.circulant_is_symm_apply {n} {v : Finₓ n → α} (h : (circulant v).IsSymm) (i : Finₓ n) : v (-i) = v i :=
  fin.circulant_is_symm_iff.1 h i

end Matrix

