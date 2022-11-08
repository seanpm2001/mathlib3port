/-
Copyright (c) 2022 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth
-/
import Mathbin.Analysis.InnerProductSpace.Dual
import Mathbin.Analysis.InnerProductSpace.Orientation
import Mathbin.Tactic.LinearCombination

/-!
# Oriented two-dimensional real inner product spaces

This file defines constructions specific to the geometry of an oriented two-dimensional real inner
product space `E`.

## Main declarations

* `orientation.area_form`: an antisymmetric bilinear form `E →ₗ[ℝ] E →ₗ[ℝ] ℝ` (usual notation `ω`).
  Morally, when `ω` is evaluated on two vectors, it gives the oriented area of the parallelogram
  they span. (But mathlib does not yet have a construction of oriented area, and in fact the
  construction of oriented area should pass through `ω`.)

* `orientation.right_angle_rotation`: an isometric automorphism `E ≃ₗᵢ[ℝ] E` (usual notation `J`).
  This automorphism squares to -1.  In a later file, rotations (`orientation.rotation`) are defined,
  in such a way that this automorphism is equal to rotation by 90 degrees.

* `orientation.basis_right_angle_rotation`: for a nonzero vector `x` in `E`, the basis `![x, J x]`
  for `E`.

* `orientation.kahler`: a complex-valued real-bilinear map `E →ₗ[ℝ] E →ₗ[ℝ] ℂ`. Its real part is the
  inner product and its imaginary part is `orientation.area_form`.  For vectors `x` and `y` in `E`,
  the complex number `o.kahler x y` has modulus `∥x∥ * ∥y∥`. In a later file, oriented angles
  (`orientation.oangle`) are defined, in such a way that the argument of `o.kahler x y` is the
  oriented angle from `x` to `y`.

## Main results

* `orientation.right_angle_rotation_right_angle_rotation`: the identity `J (J x) = - x`

* `orientation.nonneg_inner_and_area_form_eq_zero_iff_same_ray`: `x`, `y` are in the same ray, if
  and only if `0 ≤ ⟪x, y⟫` and `ω x y = 0`

* `orientation.kahler_mul`: the identity `o.kahler x a * o.kahler a y = ∥a∥ ^ 2 * o.kahler x y`

* `complex.area_form`, `complex.right_angle_rotation`, `complex.kahler`: the concrete
  interpretations of `area_form`, `right_angle_rotation`, `kahler` for the oriented real inner
  product space `ℂ`

* `orientation.area_form_map_complex`, `orientation.right_angle_rotation_map_complex`,
  `orientation.kahler_map_complex`: given an orientation-preserving isometry from `E` to `ℂ`,
  expressions for `area_form`, `right_angle_rotation`, `kahler` as the pullback of their concrete
  interpretations on `ℂ`

## Implementation notes

Notation `ω` for `orientation.area_form` and `J` for `orientation.right_angle_rotation` should be
defined locally in each file which uses them, since otherwise one would need a more cumbersome
notation which mentions the orientation explicitly (something like `ω[o]`).  Write

```
local notation `ω` := o.area_form
local notation `J` := o.right_angle_rotation
```

-/


noncomputable section

open RealInnerProductSpace ComplexConjugate

open FiniteDimensional

attribute [local instance] fact_finite_dimensional_of_finrank_eq_succ

variable {E : Type _} [InnerProductSpace ℝ E] [Fact (finrank ℝ E = 2)] (o : Orientation ℝ E (Fin 2))

namespace Orientation

include o

/-- An antisymmetric bilinear form on an oriented real inner product space of dimension 2 (usual
notation `ω`).  When evaluated on two vectors, it gives the oriented area of the parallelogram they
span. -/
irreducible_def areaForm : E →ₗ[ℝ] E →ₗ[ℝ] ℝ := by
  let z : AlternatingMap ℝ E ℝ (Fin 0) ≃ₗ[ℝ] ℝ := alternating_map.const_linear_equiv_of_is_empty.symm
  let y : AlternatingMap ℝ E ℝ (Fin 1) →ₗ[ℝ] E →ₗ[ℝ] ℝ :=
    LinearMap.llcomp ℝ E (AlternatingMap ℝ E ℝ (Fin 0)) ℝ z ∘ₗ AlternatingMap.curryLeftLinearMap
  exact y ∘ₗ AlternatingMap.curryLeftLinearMap o.volume_form

omit o

-- mathport name: exprω
local notation "ω" => o.areaForm

theorem area_form_to_volume_form (x y : E) : ω x y = o.volumeForm ![x, y] := by simp [area_form]

@[simp]
theorem area_form_apply_self (x : E) : ω x x = 0 := by
  rw [area_form_to_volume_form]
  refine' o.volume_form.map_eq_zero_of_eq ![x, x] _ (_ : (0 : Fin 2) ≠ 1)
  · simp
    
  · norm_num
    

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
theorem area_form_swap (x y : E) : ω x y = -ω y x := by
  simp only [area_form_to_volume_form]
  convert o.volume_form.map_swap ![y, x] (_ : (0 : Fin 2) ≠ 1)
  · ext i
    fin_cases i <;> rfl
    
  · norm_num
    

@[simp]
theorem area_form_neg_orientation : (-o).areaForm = -o.areaForm := by
  ext (x y)
  simp [area_form_to_volume_form]

/-- Continuous linear map version of `orientation.area_form`, useful for calculus. -/
def areaForm' : E →L[ℝ] E →L[ℝ] ℝ :=
  (↑(LinearMap.toContinuousLinearMap : (E →ₗ[ℝ] ℝ) ≃ₗ[ℝ] E →L[ℝ] ℝ) ∘ₗ o.areaForm).toContinuousLinearMap

@[simp]
theorem area_form'_apply (x : E) : o.areaForm' x = (o.areaForm x).toContinuousLinearMap :=
  rfl

theorem abs_area_form_le (x y : E) : |ω x y| ≤ ∥x∥ * ∥y∥ := by
  simpa [area_form_to_volume_form, Fin.prod_univ_succ] using o.abs_volume_form_apply_le ![x, y]

theorem area_form_le (x y : E) : ω x y ≤ ∥x∥ * ∥y∥ := by
  simpa [area_form_to_volume_form, Fin.prod_univ_succ] using o.volume_form_apply_le ![x, y]

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
theorem abs_area_form_of_orthogonal {x y : E} (h : ⟪x, y⟫ = 0) : |ω x y| = ∥x∥ * ∥y∥ := by
  rw [o.area_form_to_volume_form, o.abs_volume_form_apply_of_pairwise_orthogonal]
  · simp [Fin.prod_univ_succ]
    
  intro i j hij
  fin_cases i <;> fin_cases j
  · simpa
    
  · simpa using h
    
  · simpa [real_inner_comm] using h
    
  · simpa
    

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
theorem area_form_map {F : Type _} [InnerProductSpace ℝ F] [Fact (finrank ℝ F = 2)] (φ : E ≃ₗᵢ[ℝ] F) (x y : F) :
    (Orientation.map (Fin 2) φ.toLinearEquiv o).areaForm x y = o.areaForm (φ.symm x) (φ.symm y) := by
  have : φ.symm ∘ ![x, y] = ![φ.symm x, φ.symm y] := by
    ext i
    fin_cases i <;> rfl
  simp [area_form_to_volume_form, volume_form_map, this]

/-- The area form is invariant under pullback by a positively-oriented isometric automorphism. -/
theorem area_form_comp_linear_isometry_equiv (φ : E ≃ₗᵢ[ℝ] E) (hφ : 0 < (φ.toLinearEquiv : E →ₗ[ℝ] E).det) (x y : E) :
    o.areaForm (φ x) (φ y) = o.areaForm x y := by
  convert o.area_form_map φ (φ x) (φ y)
  · symm
    rwa [← o.map_eq_iff_det_pos φ.to_linear_equiv] at hφ
    rw [Fact.out (finrank ℝ E = 2), Fintype.card_fin]
    
  · simp
    
  · simp
    

/-- Auxiliary construction for `orientation.right_angle_rotation`, rotation by 90 degrees in an
oriented real inner product space of dimension 2. -/
irreducible_def rightAngleRotationAux₁ : E →ₗ[ℝ] E :=
  let to_dual : E ≃ₗ[ℝ] E →ₗ[ℝ] ℝ :=
    (InnerProductSpace.toDual ℝ E).toLinearEquiv ≪≫ₗ LinearMap.toContinuousLinearMap.symm
  ↑to_dual.symm ∘ₗ ω

@[simp]
theorem inner_right_angle_rotation_aux₁_left (x y : E) : ⟪o.rightAngleRotationAux₁ x, y⟫ = ω x y := by
  simp [right_angle_rotation_aux₁]

@[simp]
theorem inner_right_angle_rotation_aux₁_right (x y : E) : ⟪x, o.rightAngleRotationAux₁ y⟫ = -ω x y := by
  rw [real_inner_comm]
  simp [o.area_form_swap y x]

/-- Auxiliary construction for `orientation.right_angle_rotation`, rotation by 90 degrees in an
oriented real inner product space of dimension 2. -/
def rightAngleRotationAux₂ : E →ₗᵢ[ℝ] E :=
  { -- hw'₀,
      o.rightAngleRotationAux₁ with
    norm_map' := fun x => by
      dsimp
      refine' le_antisymm _ _
      · cases' eq_or_lt_of_le (norm_nonneg (o.right_angle_rotation_aux₁ x)) with h h
        · rw [← h]
          positivity
          
        refine' le_of_mul_le_mul_right _ h
        rw [← real_inner_self_eq_norm_mul_norm, o.inner_right_angle_rotation_aux₁_left]
        exact o.area_form_le x (o.right_angle_rotation_aux₁ x)
        
      · let K : Submodule ℝ E := ℝ ∙ x
        have : Nontrivial Kᗮ := by
          apply @FiniteDimensional.nontrivial_of_finrank_pos ℝ
          have : finrank ℝ K ≤ Finset.card {x} := by
            rw [← Set.to_finset_singleton]
            exact finrank_span_le_card ({x} : Set E)
          have : Finset.card {x} = 1 := Finset.card_singleton x
          have : finrank ℝ K + finrank ℝ Kᗮ = finrank ℝ E := K.finrank_add_finrank_orthogonal
          have : finrank ℝ E = 2 := Fact.out _
          linarith
        obtain ⟨w, hw₀⟩ : ∃ w : Kᗮ, w ≠ 0 := exists_ne 0
        have hw' : ⟪x, (w : E)⟫ = 0 := inner_right_of_mem_orthogonal_singleton x w.2
        have hw : (w : E) ≠ 0 := fun h => hw₀ (submodule.coe_eq_zero.mp h)
        refine' le_of_mul_le_mul_right _ (by rwa [norm_pos_iff] : 0 < ∥(w : E)∥)
        rw [← o.abs_area_form_of_orthogonal hw']
        rw [← o.inner_right_angle_rotation_aux₁_left x w]
        exact abs_real_inner_le_norm (o.right_angle_rotation_aux₁ x) w
         }

@[simp]
theorem right_angle_rotation_aux₁_right_angle_rotation_aux₁ (x : E) :
    o.rightAngleRotationAux₁ (o.rightAngleRotationAux₁ x) = -x := by
  apply ext_inner_left ℝ
  intro y
  have : ⟪o.right_angle_rotation_aux₁ y, o.right_angle_rotation_aux₁ x⟫ = ⟪y, x⟫ :=
    LinearIsometry.inner_map_map o.right_angle_rotation_aux₂ y x
  rw [o.inner_right_angle_rotation_aux₁_right, ← o.inner_right_angle_rotation_aux₁_left, this, inner_neg_right]

/-- An isometric automorphism of an oriented real inner product space of dimension 2 (usual notation
`J`). This automorphism squares to -1.  We will define rotations in such a way that this
automorphism is equal to rotation by 90 degrees. -/
irreducible_def rightAngleRotation : E ≃ₗᵢ[ℝ] E :=
  LinearIsometryEquiv.ofLinearIsometry o.rightAngleRotationAux₂ (-o.rightAngleRotationAux₁)
    (by ext <;> simp [right_angle_rotation_aux₂]) (by ext <;> simp [right_angle_rotation_aux₂])

-- mathport name: exprJ
local notation "J" => o.rightAngleRotation

@[simp]
theorem inner_right_angle_rotation_left (x y : E) : ⟪J x, y⟫ = ω x y := by
  rw [right_angle_rotation]
  exact o.inner_right_angle_rotation_aux₁_left x y

@[simp]
theorem inner_right_angle_rotation_right (x y : E) : ⟪x, J y⟫ = -ω x y := by
  rw [right_angle_rotation]
  exact o.inner_right_angle_rotation_aux₁_right x y

@[simp]
theorem right_angle_rotation_right_angle_rotation (x : E) : J (J x) = -x := by
  rw [right_angle_rotation]
  exact o.right_angle_rotation_aux₁_right_angle_rotation_aux₁ x

@[simp]
theorem right_angle_rotation_symm :
    LinearIsometryEquiv.symm J = LinearIsometryEquiv.trans J (LinearIsometryEquiv.neg ℝ) := by
  rw [right_angle_rotation]
  exact LinearIsometryEquiv.to_linear_isometry_injective rfl

@[simp]
theorem inner_right_angle_rotation_self (x : E) : ⟪J x, x⟫ = 0 := by simp

theorem inner_right_angle_rotation_swap (x y : E) : ⟪x, J y⟫ = -⟪J x, y⟫ := by simp

theorem inner_right_angle_rotation_swap' (x y : E) : ⟪J x, y⟫ = -⟪x, J y⟫ := by
  simp [o.inner_right_angle_rotation_swap x y]

theorem inner_comp_right_angle_rotation (x y : E) : ⟪J x, J y⟫ = ⟪x, y⟫ :=
  LinearIsometryEquiv.inner_map_map J x y

@[simp]
theorem area_form_right_angle_rotation_left (x y : E) : ω (J x) y = -⟪x, y⟫ := by
  rw [← o.inner_comp_right_angle_rotation, o.inner_right_angle_rotation_right, neg_neg]

@[simp]
theorem area_form_right_angle_rotation_right (x y : E) : ω x (J y) = ⟪x, y⟫ := by
  rw [← o.inner_right_angle_rotation_left, o.inner_comp_right_angle_rotation]

@[simp]
theorem area_form_comp_right_angle_rotation (x y : E) : ω (J x) (J y) = ω x y := by simp

@[simp]
theorem right_angle_rotation_trans_right_angle_rotation : LinearIsometryEquiv.trans J J = LinearIsometryEquiv.neg ℝ :=
  by ext <;> simp

theorem right_angle_rotation_neg_orientation (x : E) : (-o).rightAngleRotation x = -o.rightAngleRotation x := by
  apply ext_inner_right ℝ
  intro y
  rw [inner_right_angle_rotation_left]
  simp

@[simp]
theorem right_angle_rotation_trans_neg_orientation :
    (-o).rightAngleRotation = o.rightAngleRotation.trans (LinearIsometryEquiv.neg ℝ) :=
  LinearIsometryEquiv.ext <| o.right_angle_rotation_neg_orientation

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:52:50: missing argument -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr inner.real(exprJ() (φ.symm x), φ.symm y)]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg -/
/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:52:50: missing argument -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr inner.real(φ (exprJ() (φ.symm x)), φ (φ.symm y))]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg -/
theorem right_angle_rotation_map {F : Type _} [InnerProductSpace ℝ F] [Fact (finrank ℝ F = 2)] (φ : E ≃ₗᵢ[ℝ] F)
    (x : F) : (Orientation.map (Fin 2) φ.toLinearEquiv o).rightAngleRotation x = φ (o.rightAngleRotation (φ.symm x)) :=
  by
  apply ext_inner_right ℝ
  intro y
  rw [inner_right_angle_rotation_left]
  trace
    "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr inner.real(exprJ() (φ.symm x), φ.symm y)]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg"
  · simp [o.area_form_map]
    
  trace
    "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr inner.real(φ (exprJ() (φ.symm x)), φ (φ.symm y))]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg"
  · rw [φ.inner_map_map]
    
  · simp
    

/-- `J` commutes with any positively-oriented isometric automorphism. -/
theorem linear_isometry_equiv_comp_right_angle_rotation (φ : E ≃ₗᵢ[ℝ] E) (hφ : 0 < (φ.toLinearEquiv : E →ₗ[ℝ] E).det)
    (x : E) : φ (J x) = J (φ x) := by
  convert (o.right_angle_rotation_map φ (φ x)).symm
  · simp
    
  · symm
    rwa [← o.map_eq_iff_det_pos φ.to_linear_equiv] at hφ
    rw [Fact.out (finrank ℝ E = 2), Fintype.card_fin]
    

theorem right_angle_rotation_map' {F : Type _} [InnerProductSpace ℝ F] [Fact (finrank ℝ F = 2)] (φ : E ≃ₗᵢ[ℝ] F) :
    (Orientation.map (Fin 2) φ.toLinearEquiv o).rightAngleRotation = (φ.symm.trans o.rightAngleRotation).trans φ :=
  LinearIsometryEquiv.ext <| o.right_angle_rotation_map φ

/-- `J` commutes with any positively-oriented isometric automorphism. -/
theorem linear_isometry_equiv_comp_right_angle_rotation' (φ : E ≃ₗᵢ[ℝ] E) (hφ : 0 < (φ.toLinearEquiv : E →ₗ[ℝ] E).det) :
    LinearIsometryEquiv.trans J φ = φ.trans J :=
  LinearIsometryEquiv.ext <| o.linear_isometry_equiv_comp_right_angle_rotation φ hφ

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
/-- For a nonzero vector `x` in an oriented two-dimensional real inner product space `E`,
`![x, J x]` forms an (orthogonal) basis for `E`. -/
def basisRightAngleRotation (x : E) (hx : x ≠ 0) : Basis (Fin 2) ℝ E :=
  @basisOfLinearIndependentOfCardEqFinrank _ _ _ _ _ _ _ _ ![x, J x]
    (linear_independent_of_ne_zero_of_inner_eq_zero (fun i => by fin_cases i <;> simp [hx])
      (by
        intro i j hij
        fin_cases i <;> fin_cases j
        · simpa
          
        · simp
          
        · simp
          
        · simpa
          ))
    (Fact.out (finrank ℝ E = 2)).symm

@[simp]
theorem coe_basis_right_angle_rotation (x : E) (hx : x ≠ 0) : ⇑(o.basisRightAngleRotation x hx) = ![x, J x] :=
  coe_basis_of_linear_independent_of_card_eq_finrank _ _

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
/-- For vectors `a x y : E`, the identity `⟪a, x⟫ * ⟪a, y⟫ + ω a x * ω a y = ∥a∥ ^ 2 * ⟪x, y⟫`. (See
`orientation.inner_mul_inner_add_area_form_mul_area_form` for the "applied" form.)-/
theorem inner_mul_inner_add_area_form_mul_area_form' (a x : E) :
    ⟪a, x⟫ • @innerₛₗ ℝ _ _ _ a + ω a x • ω a = ∥a∥ ^ 2 • @innerₛₗ ℝ _ _ _ x := by
  by_cases ha:a = 0
  · simp [ha]
    
  apply (o.basis_right_angle_rotation a ha).ext
  intro i
  fin_cases i
  · simp only [real_inner_self_eq_norm_sq, Algebra.id.smul_eq_mul, innerₛₗ_apply, LinearMap.smul_apply,
      LinearMap.add_apply, Matrix.cons_val_zero, o.coe_basis_right_angle_rotation, o.area_form_apply_self,
      real_inner_comm]
    ring
    
  · simp only [real_inner_self_eq_norm_sq, Algebra.id.smul_eq_mul, innerₛₗ_apply, LinearMap.smul_apply, neg_inj,
      LinearMap.add_apply, Matrix.cons_val_one, Matrix.head_cons, o.coe_basis_right_angle_rotation,
      o.area_form_right_angle_rotation_right, o.area_form_apply_self, o.inner_right_angle_rotation_right]
    rw [o.area_form_swap]
    ring
    

/-- For vectors `a x y : E`, the identity `⟪a, x⟫ * ⟪a, y⟫ + ω a x * ω a y = ∥a∥ ^ 2 * ⟪x, y⟫`. -/
theorem inner_mul_inner_add_area_form_mul_area_form (a x y : E) : ⟪a, x⟫ * ⟪a, y⟫ + ω a x * ω a y = ∥a∥ ^ 2 * ⟪x, y⟫ :=
  congr_arg (fun f : E →ₗ[ℝ] ℝ => f y) (o.inner_mul_inner_add_area_form_mul_area_form' a x)

theorem inner_sq_add_area_form_sq (a b : E) : ⟪a, b⟫ ^ 2 + ω a b ^ 2 = ∥a∥ ^ 2 * ∥b∥ ^ 2 := by
  simpa [sq, real_inner_self_eq_norm_sq] using o.inner_mul_inner_add_area_form_mul_area_form a b b

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
/-- For vectors `a x y : E`, the identity `⟪a, x⟫ * ω a y - ω a x * ⟪a, y⟫ = ∥a∥ ^ 2 * ω x y`. (See
`orientation.inner_mul_area_form_sub` for the "applied" form.) -/
theorem inner_mul_area_form_sub' (a x : E) : ⟪a, x⟫ • ω a - ω a x • @innerₛₗ ℝ _ _ _ a = ∥a∥ ^ 2 • ω x := by
  by_cases ha:a = 0
  · simp [ha]
    
  apply (o.basis_right_angle_rotation a ha).ext
  intro i
  fin_cases i
  · simp only [o.coe_basis_right_angle_rotation, o.area_form_apply_self, o.area_form_swap a x,
      real_inner_self_eq_norm_sq, Algebra.id.smul_eq_mul, innerₛₗ_apply, LinearMap.sub_apply, LinearMap.smul_apply,
      Matrix.cons_val_zero]
    ring
    
  · simp only [o.area_form_right_angle_rotation_right, o.area_form_apply_self, o.coe_basis_right_angle_rotation,
      o.inner_right_angle_rotation_right, real_inner_self_eq_norm_sq, real_inner_comm, Algebra.id.smul_eq_mul,
      innerₛₗ_apply, LinearMap.smul_apply, LinearMap.sub_apply, Matrix.cons_val_one, Matrix.head_cons]
    ring
    

/-- For vectors `a x y : E`, the identity `⟪a, x⟫ * ω a y - ω a x * ⟪a, y⟫ = ∥a∥ ^ 2 * ω x y`. -/
theorem inner_mul_area_form_sub (a x y : E) : ⟪a, x⟫ * ω a y - ω a x * ⟪a, y⟫ = ∥a∥ ^ 2 * ω x y :=
  congr_arg (fun f : E →ₗ[ℝ] ℝ => f y) (o.inner_mul_area_form_sub' a x)

theorem nonneg_inner_and_area_form_eq_zero_iff_same_ray (x y : E) : 0 ≤ ⟪x, y⟫ ∧ ω x y = 0 ↔ SameRay ℝ x y := by
  by_cases hx:x = 0
  · simp [hx]
    
  constructor
  · let a : ℝ := (o.basis_right_angle_rotation x hx).repr y 0
    let b : ℝ := (o.basis_right_angle_rotation x hx).repr y 1
    suffices 0 ≤ a * ∥x∥ ^ 2 ∧ b * ∥x∥ ^ 2 = 0 → SameRay ℝ x (a • x + b • J x) by
      -- TODO trace the `dsimp` lemmas in this block to make a single `simp only`
      rw [← (o.basis_right_angle_rotation x hx).sum_repr y]
      simp only [Fin.sum_univ_succ, coe_basis_right_angle_rotation]
      dsimp
      simp only [o.area_form_apply_self, map_smul, map_add, map_zero, inner_smul_left, inner_smul_right, inner_add_left,
        inner_add_right, inner_zero_right, LinearMap.add_apply, Matrix.cons_val_one]
      dsimp
      simp only [o.area_form_right_angle_rotation_right, mul_zero, add_zero, zero_add, neg_zero,
        o.inner_right_angle_rotation_right, o.area_form_apply_self, real_inner_self_eq_norm_sq]
      exact this
    rintro ⟨ha, hb⟩
    have hx' : 0 < ∥x∥ := by simpa using hx
    have ha' : 0 ≤ a := nonneg_of_mul_nonneg_left ha (by positivity)
    have hb' : b = 0 := eq_zero_of_ne_zero_of_mul_right_eq_zero (pow_ne_zero 2 hx'.ne') hb
    simpa [hb'] using same_ray_nonneg_smul_right x ha'
    
  · intro h
    obtain ⟨r, hr, rfl⟩ := h.exists_nonneg_left hx
    simp only [inner_smul_right, real_inner_self_eq_norm_sq, LinearMap.map_smulₛₗ, area_form_apply_self,
      Algebra.id.smul_eq_mul, mul_zero, eq_self_iff_true, and_true_iff]
    positivity
    

/-- A complex-valued real-bilinear map on an oriented real inner product space of dimension 2. Its
real part is the inner product and its imaginary part is `orientation.area_form`.

On `ℂ` with the standard orientation, `kahler w z = conj w * z`; see `complex.kahler`. -/
def kahler : E →ₗ[ℝ] E →ₗ[ℝ] ℂ :=
  LinearMap.llcomp ℝ E ℝ ℂ Complex.ofRealClm ∘ₗ @innerₛₗ ℝ E _ _ +
    LinearMap.llcomp ℝ E ℝ ℂ ((LinearMap.lsmul ℝ ℂ).flip Complex.i) ∘ₗ ω

theorem kahler_apply_apply (x y : E) : o.kahler x y = ⟪x, y⟫ + ω x y • Complex.i :=
  rfl

theorem kahler_swap (x y : E) : o.kahler x y = conj (o.kahler y x) := by
  simp only [kahler_apply_apply]
  rw [real_inner_comm, area_form_swap]
  simp

@[simp]
theorem kahler_apply_self (x : E) : o.kahler x x = ∥x∥ ^ 2 := by simp [kahler_apply_apply, real_inner_self_eq_norm_sq]

@[simp]
theorem kahler_right_angle_rotation_left (x y : E) : o.kahler (J x) y = -Complex.i * o.kahler x y := by
  simp only [o.area_form_right_angle_rotation_left, o.inner_right_angle_rotation_left, o.kahler_apply_apply,
    Complex.of_real_neg, Complex.real_smul]
  linear_combination ω x y * Complex.I_sq

@[simp]
theorem kahler_right_angle_rotation_right (x y : E) : o.kahler x (J y) = Complex.i * o.kahler x y := by
  simp only [o.area_form_right_angle_rotation_right, o.inner_right_angle_rotation_right, o.kahler_apply_apply,
    Complex.of_real_neg, Complex.real_smul]
  linear_combination-ω x y * Complex.I_sq

@[simp]
theorem kahler_comp_right_angle_rotation (x y : E) : o.kahler (J x) (J y) = o.kahler x y := by
  simp only [kahler_right_angle_rotation_left, kahler_right_angle_rotation_right]
  linear_combination-o.kahler x y * Complex.I_sq

@[simp]
theorem kahler_neg_orientation (x y : E) : (-o).kahler x y = conj (o.kahler x y) := by simp [kahler_apply_apply]

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:52:50: missing argument -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr «expr * »((«expr↑ »(«expr ^ »(«expr∥ ∥»(a), 2)) : exprℂ()), o.kahler x y)]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg -/
theorem kahler_mul (a x y : E) : o.kahler x a * o.kahler a y = ∥a∥ ^ 2 * o.kahler x y := by
  trace
    "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr «expr * »((«expr↑ »(«expr ^ »(«expr∥ ∥»(a), 2)) : exprℂ()), o.kahler x y)]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg"
  · ext
    · simp only [o.kahler_apply_apply, Complex.add_im, Complex.add_re, Complex.I_im, Complex.I_re, Complex.mul_im,
        Complex.mul_re, Complex.of_real_im, Complex.of_real_re, Complex.real_smul]
      rw [real_inner_comm a x, o.area_form_swap x a]
      linear_combination o.inner_mul_inner_add_area_form_mul_area_form a x y
      
    · simp only [o.kahler_apply_apply, Complex.add_im, Complex.add_re, Complex.I_im, Complex.I_re, Complex.mul_im,
        Complex.mul_re, Complex.of_real_im, Complex.of_real_re, Complex.real_smul]
      rw [real_inner_comm a x, o.area_form_swap x a]
      linear_combination o.inner_mul_area_form_sub a x y
      
    
  · norm_cast
    

theorem norm_sq_kahler (x y : E) : Complex.normSq (o.kahler x y) = ∥x∥ ^ 2 * ∥y∥ ^ 2 := by
  simpa [kahler_apply_apply, Complex.normSq, sq] using o.inner_sq_add_area_form_sq x y

theorem abs_kahler (x y : E) : Complex.abs (o.kahler x y) = ∥x∥ * ∥y∥ := by
  rw [← sq_eq_sq, Complex.sq_abs]
  · linear_combination o.norm_sq_kahler x y
    
  · positivity
    
  · positivity
    

theorem norm_kahler (x y : E) : ∥o.kahler x y∥ = ∥x∥ * ∥y∥ := by simpa using o.abs_kahler x y

theorem eq_zero_or_eq_zero_of_kahler_eq_zero {x y : E} (hx : o.kahler x y = 0) : x = 0 ∨ y = 0 := by
  have : ∥x∥ * ∥y∥ = 0 := by simpa [hx] using (o.norm_kahler x y).symm
  cases' eq_zero_or_eq_zero_of_mul_eq_zero this with h h
  · left
    simpa using h
    
  · right
    simpa using h
    

theorem kahler_eq_zero_iff (x y : E) : o.kahler x y = 0 ↔ x = 0 ∨ y = 0 := by
  refine' ⟨o.eq_zero_or_eq_zero_of_kahler_eq_zero, _⟩
  rintro (rfl | rfl) <;> simp

theorem kahler_ne_zero {x y : E} (hx : x ≠ 0) (hy : y ≠ 0) : o.kahler x y ≠ 0 := by
  apply mt o.eq_zero_or_eq_zero_of_kahler_eq_zero
  tauto

theorem kahler_ne_zero_iff (x y : E) : o.kahler x y ≠ 0 ↔ x ≠ 0 ∧ y ≠ 0 := by
  refine' ⟨_, fun h => o.kahler_ne_zero h.1 h.2⟩
  contrapose
  simp only [not_and_or, not_not, kahler_apply_apply, Complex.real_smul]
  rintro (rfl | rfl) <;> simp

theorem kahler_map {F : Type _} [InnerProductSpace ℝ F] [Fact (finrank ℝ F = 2)] (φ : E ≃ₗᵢ[ℝ] F) (x y : F) :
    (Orientation.map (Fin 2) φ.toLinearEquiv o).kahler x y = o.kahler (φ.symm x) (φ.symm y) := by
  simp [kahler_apply_apply, area_form_map]

/-- The bilinear map `kahler` is invariant under pullback by a positively-oriented isometric
automorphism. -/
theorem kahler_comp_linear_isometry_equiv (φ : E ≃ₗᵢ[ℝ] E) (hφ : 0 < (φ.toLinearEquiv : E →ₗ[ℝ] E).det) (x y : E) :
    o.kahler (φ x) (φ y) = o.kahler x y := by simp [kahler_apply_apply, o.area_form_comp_linear_isometry_equiv φ hφ]

end Orientation

namespace Complex

attribute [local instance] Complex.finrank_real_complex_fact

@[simp]
protected theorem area_form (w z : ℂ) : Complex.orientation.areaForm w z = (conj w * z).im := by
  let o := Complex.orientation
  simp only [o.area_form_to_volume_form, o.volume_form_robust Complex.orthonormalBasisOneI rfl, Basis.det_apply,
    Matrix.det_fin_two, Basis.to_matrix_apply, to_basis_orthonormal_basis_one_I, Matrix.cons_val_zero,
    coe_basis_one_I_repr, Matrix.cons_val_one, Matrix.head_cons, mul_im, conj_re, conj_im]
  ring

@[simp]
protected theorem right_angle_rotation (z : ℂ) : Complex.orientation.rightAngleRotation z = I * z := by
  apply ext_inner_right ℝ
  intro w
  rw [Orientation.inner_right_angle_rotation_left]
  simp only [Complex.area_form, Complex.inner, mul_re, mul_im, conj_re, conj_im, map_mul, conj_I, neg_re, neg_im, I_re,
    I_im]
  ring

@[simp]
protected theorem kahler (w z : ℂ) : Complex.orientation.kahler w z = conj w * z := by
  rw [Orientation.kahler_apply_apply]
  ext1 <;> simp

end Complex

namespace Orientation

-- mathport name: exprω
local notation "ω" => o.areaForm

-- mathport name: exprJ
local notation "J" => o.rightAngleRotation

open Complex

/-- The area form on an oriented real inner product space of dimension 2 can be evaluated in terms
of a complex-number representation of the space. -/
theorem area_form_map_complex (f : E ≃ₗᵢ[ℝ] ℂ) (hf : Orientation.map (Fin 2) f.toLinearEquiv o = Complex.orientation)
    (x y : E) : ω x y = (conj (f x) * f y).im := by
  rw [← Complex.area_form, ← hf, o.area_form_map]
  simp

/-- The rotation by 90 degrees on an oriented real inner product space of dimension 2 can be
evaluated in terms of a complex-number representation of the space. -/
theorem right_angle_rotation_map_complex (f : E ≃ₗᵢ[ℝ] ℂ)
    (hf : Orientation.map (Fin 2) f.toLinearEquiv o = Complex.orientation) (x : E) : f (J x) = I * f x := by
  rw [← Complex.right_angle_rotation, ← hf, o.right_angle_rotation_map]
  simp

/-- The Kahler form on an oriented real inner product space of dimension 2 can be evaluated in terms
of a complex-number representation of the space. -/
theorem kahler_map_complex (f : E ≃ₗᵢ[ℝ] ℂ) (hf : Orientation.map (Fin 2) f.toLinearEquiv o = Complex.orientation)
    (x y : E) : o.kahler x y = conj (f x) * f y := by
  rw [← Complex.kahler, ← hf, o.kahler_map]
  simp

end Orientation

