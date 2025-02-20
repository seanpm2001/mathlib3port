/-
Copyright (c) 2021 Jakob von Raumer. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jakob von Raumer

! This file was ported from Lean 3 source module linear_algebra.coevaluation
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Contraction
import Mathbin.LinearAlgebra.FiniteDimensional
import Mathbin.LinearAlgebra.Dual

/-!
# The coevaluation map on finite dimensional vector spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given a finite dimensional vector space `V` over a field `K` this describes the canonical linear map
from `K` to `V ⊗ dual K V` which corresponds to the identity function on `V`.

## Tags

coevaluation, dual module, tensor product

## Future work

* Prove that this is independent of the choice of basis on `V`.
-/


noncomputable section

section coevaluation

open TensorProduct FiniteDimensional

open scoped TensorProduct BigOperators

universe u v

variable (K : Type u) [Field K]

variable (V : Type v) [AddCommGroup V] [Module K V] [FiniteDimensional K V]

#print coevaluation /-
/-- The coevaluation map is a linear map from a field `K` to a finite dimensional
  vector space `V`. -/
def coevaluation : K →ₗ[K] V ⊗[K] Module.Dual K V :=
  let bV := Basis.ofVectorSpace K V
  (Basis.singleton Unit K).constr K fun _ =>
    ∑ i : Basis.ofVectorSpaceIndex K V, bV i ⊗ₜ[K] bV.Coord i
#align coevaluation coevaluation
-/

#print coevaluation_apply_one /-
theorem coevaluation_apply_one :
    (coevaluation K V) (1 : K) =
      let bV := Basis.ofVectorSpace K V
      ∑ i : Basis.ofVectorSpaceIndex K V, bV i ⊗ₜ[K] bV.Coord i :=
  by
  simp only [coevaluation, id]
  rw [(Basis.singleton Unit K).constr_apply_fintype K]
  simp only [Fintype.univ_punit, Finset.sum_const, one_smul, Basis.singleton_repr,
    Basis.equivFun_apply, Basis.coe_ofVectorSpace, one_nsmul, Finset.card_singleton]
#align coevaluation_apply_one coevaluation_apply_one
-/

open TensorProduct

#print contractLeft_assoc_coevaluation /-
/-- This lemma corresponds to one of the coherence laws for duals in rigid categories, see
  `category_theory.monoidal.rigid`. -/
theorem contractLeft_assoc_coevaluation :
    (contractLeft K V).rTensor _ ∘ₗ
        (TensorProduct.assoc K _ _ _).symm.toLinearMap ∘ₗ
          (coevaluation K V).lTensor (Module.Dual K V) =
      (TensorProduct.lid K _).symm.toLinearMap ∘ₗ (TensorProduct.rid K _).toLinearMap :=
  by
  letI := Classical.decEq (Basis.ofVectorSpaceIndex K V)
  apply TensorProduct.ext
  apply (Basis.ofVectorSpace K V).dualBasis.ext; intro j; apply LinearMap.ext_ring
  rw [LinearMap.compr₂_apply, LinearMap.compr₂_apply, TensorProduct.mk_apply]
  simp only [LinearMap.coe_comp, Function.comp_apply, LinearEquiv.coe_toLinearMap]
  rw [rid_tmul, one_smul, lid_symm_apply]
  simp only [LinearEquiv.coe_toLinearMap, LinearMap.lTensor_tmul, coevaluation_apply_one]
  rw [TensorProduct.tmul_sum, LinearEquiv.map_sum]; simp only [assoc_symm_tmul]
  rw [LinearMap.map_sum]; simp only [LinearMap.rTensor_tmul, contractLeft_apply]
  simp only [Basis.coe_dualBasis, Basis.coord_apply, Basis.repr_self_apply, TensorProduct.ite_tmul]
  rw [Finset.sum_ite_eq']; simp only [Finset.mem_univ, if_true]
#align contract_left_assoc_coevaluation contractLeft_assoc_coevaluation
-/

#print contractLeft_assoc_coevaluation' /-
/-- This lemma corresponds to one of the coherence laws for duals in rigid categories, see
  `category_theory.monoidal.rigid`. -/
theorem contractLeft_assoc_coevaluation' :
    (contractLeft K V).lTensor _ ∘ₗ
        (TensorProduct.assoc K _ _ _).toLinearMap ∘ₗ (coevaluation K V).rTensor V =
      (TensorProduct.rid K _).symm.toLinearMap ∘ₗ (TensorProduct.lid K _).toLinearMap :=
  by
  letI := Classical.decEq (Basis.ofVectorSpaceIndex K V)
  apply TensorProduct.ext
  apply LinearMap.ext_ring; apply (Basis.ofVectorSpace K V).ext; intro j
  rw [LinearMap.compr₂_apply, LinearMap.compr₂_apply, TensorProduct.mk_apply]
  simp only [LinearMap.coe_comp, Function.comp_apply, LinearEquiv.coe_toLinearMap]
  rw [lid_tmul, one_smul, rid_symm_apply]
  simp only [LinearEquiv.coe_toLinearMap, LinearMap.rTensor_tmul, coevaluation_apply_one]
  rw [TensorProduct.sum_tmul, LinearEquiv.map_sum]; simp only [assoc_tmul]
  rw [LinearMap.map_sum]; simp only [LinearMap.lTensor_tmul, contractLeft_apply]
  simp only [Basis.coord_apply, Basis.repr_self_apply, TensorProduct.tmul_ite]
  rw [Finset.sum_ite_eq]; simp only [Finset.mem_univ, if_true]
#align contract_left_assoc_coevaluation' contractLeft_assoc_coevaluation'
-/

end coevaluation

