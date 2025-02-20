/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.tensor_product
! leanprover-community/mathlib commit 575b4ea3738b017e30fb205cb9b4a8742e5e82b6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Lie.Abelian

/-!
# Tensor products of Lie modules

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Tensor products of Lie modules carry natural Lie module structures.

## Tags

lie module, tensor product, universal property
-/


universe u v w w₁ w₂ w₃

variable {R : Type u} [CommRing R]

open LieModule

namespace TensorProduct

open scoped TensorProduct

namespace LieModule

variable {L : Type v} {M : Type w} {N : Type w₁} {P : Type w₂} {Q : Type w₃}

variable [LieRing L] [LieAlgebra R L]

variable [AddCommGroup M] [Module R M] [LieRingModule L M] [LieModule R L M]

variable [AddCommGroup N] [Module R N] [LieRingModule L N] [LieModule R L N]

variable [AddCommGroup P] [Module R P] [LieRingModule L P] [LieModule R L P]

variable [AddCommGroup Q] [Module R Q] [LieRingModule L Q] [LieModule R L Q]

attribute [local ext] TensorProduct.ext

#print TensorProduct.LieModule.hasBracketAux /-
/-- It is useful to define the bracket via this auxiliary function so that we have a type-theoretic
expression of the fact that `L` acts by linear endomorphisms. It simplifies the proofs in
`lie_ring_module` below. -/
def hasBracketAux (x : L) : Module.End R (M ⊗[R] N) :=
  (toEndomorphism R L M x).rTensor N + (toEndomorphism R L N x).lTensor M
#align tensor_product.lie_module.has_bracket_aux TensorProduct.LieModule.hasBracketAux
-/

#print TensorProduct.LieModule.lieRingModule /-
/-- The tensor product of two Lie modules is a Lie ring module. -/
instance lieRingModule : LieRingModule L (M ⊗[R] N)
    where
  bracket x := hasBracketAux x
  add_lie x y t :=
    by
    simp only [has_bracket_aux, LinearMap.lTensor_add, LinearMap.rTensor_add, LieHom.map_add,
      LinearMap.add_apply]
    abel
  lie_add x := LinearMap.map_add _
  leibniz_lie x y t :=
    by
    suffices
      (has_bracket_aux x).comp (has_bracket_aux y) =
        has_bracket_aux ⁅x, y⁆ + (has_bracket_aux y).comp (has_bracket_aux x)
      by simp only [← LinearMap.add_apply]; rw [← LinearMap.comp_apply, this]; rfl
    ext m n
    simp only [has_bracket_aux, LieRing.of_associative_ring_bracket, LinearMap.mul_apply, mk_apply,
      LinearMap.lTensor_sub, LinearMap.compr₂_apply, Function.comp_apply, LinearMap.coe_comp,
      LinearMap.rTensor_tmul, LieHom.map_lie, to_endomorphism_apply_apply, LinearMap.add_apply,
      LinearMap.map_add, LinearMap.rTensor_sub, LinearMap.sub_apply, LinearMap.lTensor_tmul]
    abel
#align tensor_product.lie_module.lie_ring_module TensorProduct.LieModule.lieRingModule
-/

#print TensorProduct.LieModule.lieModule /-
/-- The tensor product of two Lie modules is a Lie module. -/
instance lieModule : LieModule R L (M ⊗[R] N)
    where
  smul_lie c x t := by
    change has_bracket_aux (c • x) _ = c • has_bracket_aux _ _
    simp only [has_bracket_aux, smul_add, LinearMap.rTensor_smul, LinearMap.smul_apply,
      LinearMap.lTensor_smul, LieHom.map_smul, LinearMap.add_apply]
  lie_smul c x := LinearMap.map_smul _ c
#align tensor_product.lie_module.lie_module TensorProduct.LieModule.lieModule
-/

#print TensorProduct.LieModule.lie_tmul_right /-
@[simp]
theorem lie_tmul_right (x : L) (m : M) (n : N) : ⁅x, m ⊗ₜ[R] n⁆ = ⁅x, m⁆ ⊗ₜ n + m ⊗ₜ ⁅x, n⁆ :=
  show hasBracketAux x (m ⊗ₜ[R] n) = _ by
    simp only [has_bracket_aux, LinearMap.rTensor_tmul, to_endomorphism_apply_apply,
      LinearMap.add_apply, LinearMap.lTensor_tmul]
#align tensor_product.lie_module.lie_tmul_right TensorProduct.LieModule.lie_tmul_right
-/

variable (R L M N P Q)

#print TensorProduct.LieModule.lift /-
/-- The universal property for tensor product of modules of a Lie algebra: the `R`-linear
tensor-hom adjunction is equivariant with respect to the `L` action. -/
def lift : (M →ₗ[R] N →ₗ[R] P) ≃ₗ⁅R,L⁆ M ⊗[R] N →ₗ[R] P :=
  { TensorProduct.lift.equiv R M N P with
    map_lie' := fun x f => by
      ext m n;
      simp only [mk_apply, LinearMap.compr₂_apply, lie_tmul_right, LinearMap.sub_apply,
        lift.equiv_apply, LinearEquiv.toFun_eq_coe, LieHom.lie_apply, LinearMap.map_add]
      abel }
#align tensor_product.lie_module.lift TensorProduct.LieModule.lift
-/

#print TensorProduct.LieModule.lift_apply /-
@[simp]
theorem lift_apply (f : M →ₗ[R] N →ₗ[R] P) (m : M) (n : N) : lift R L M N P f (m ⊗ₜ n) = f m n :=
  rfl
#align tensor_product.lie_module.lift_apply TensorProduct.LieModule.lift_apply
-/

#print TensorProduct.LieModule.liftLie /-
/-- A weaker form of the universal property for tensor product of modules of a Lie algebra.

Note that maps `f` of type `M →ₗ⁅R,L⁆ N →ₗ[R] P` are exactly those `R`-bilinear maps satisfying
`⁅x, f m n⁆ = f ⁅x, m⁆ n + f m ⁅x, n⁆` for all `x, m, n` (see e.g, `lie_module_hom.map_lie₂`). -/
def liftLie : (M →ₗ⁅R,L⁆ N →ₗ[R] P) ≃ₗ[R] M ⊗[R] N →ₗ⁅R,L⁆ P :=
  maxTrivLinearMapEquivLieModuleHom.symm ≪≫ₗ ↑(maxTrivEquiv (lift R L M N P)) ≪≫ₗ
    maxTrivLinearMapEquivLieModuleHom
#align tensor_product.lie_module.lift_lie TensorProduct.LieModule.liftLie
-/

#print TensorProduct.LieModule.coe_liftLie_eq_lift_coe /-
@[simp]
theorem coe_liftLie_eq_lift_coe (f : M →ₗ⁅R,L⁆ N →ₗ[R] P) :
    ⇑(liftLie R L M N P f) = lift R L M N P f :=
  by
  suffices (lift_lie R L M N P f : M ⊗[R] N →ₗ[R] P) = lift R L M N P f by
    rw [← this, LieModuleHom.coe_toLinearMap]
  ext m n
  simp only [lift_lie, LinearEquiv.trans_apply, LieModuleEquiv.coe_to_linearEquiv,
    coe_linear_map_max_triv_linear_map_equiv_lie_module_hom, coe_max_triv_equiv_apply,
    coe_linear_map_max_triv_linear_map_equiv_lie_module_hom_symm]
#align tensor_product.lie_module.coe_lift_lie_eq_lift_coe TensorProduct.LieModule.coe_liftLie_eq_lift_coe
-/

#print TensorProduct.LieModule.liftLie_apply /-
theorem liftLie_apply (f : M →ₗ⁅R,L⁆ N →ₗ[R] P) (m : M) (n : N) :
    liftLie R L M N P f (m ⊗ₜ n) = f m n := by
  simp only [coe_lift_lie_eq_lift_coe, LieModuleHom.coe_toLinearMap, lift_apply]
#align tensor_product.lie_module.lift_lie_apply TensorProduct.LieModule.liftLie_apply
-/

variable {R L M N P Q}

#print TensorProduct.LieModule.map /-
/-- A pair of Lie module morphisms `f : M → P` and `g : N → Q`, induce a Lie module morphism:
`M ⊗ N → P ⊗ Q`. -/
def map (f : M →ₗ⁅R,L⁆ P) (g : N →ₗ⁅R,L⁆ Q) : M ⊗[R] N →ₗ⁅R,L⁆ P ⊗[R] Q :=
  { map (f : M →ₗ[R] P) (g : N →ₗ[R] Q) with
    map_lie' := fun x t => by
      simp only [LinearMap.toFun_eq_coe]
      apply t.induction_on
      · simp only [LinearMap.map_zero, lie_zero]
      · intro m n;
        simp only [LieModuleHom.coe_toLinearMap, lie_tmul_right, LieModuleHom.map_lie, map_tmul,
          LinearMap.map_add]
      · intro t₁ t₂ ht₁ ht₂; simp only [ht₁, ht₂, lie_add, LinearMap.map_add] }
#align tensor_product.lie_module.map TensorProduct.LieModule.map
-/

#print TensorProduct.LieModule.coe_linearMap_map /-
@[simp]
theorem coe_linearMap_map (f : M →ₗ⁅R,L⁆ P) (g : N →ₗ⁅R,L⁆ Q) :
    (map f g : M ⊗[R] N →ₗ[R] P ⊗[R] Q) = TensorProduct.map (f : M →ₗ[R] P) (g : N →ₗ[R] Q) :=
  rfl
#align tensor_product.lie_module.coe_linear_map_map TensorProduct.LieModule.coe_linearMap_map
-/

#print TensorProduct.LieModule.map_tmul /-
@[simp]
theorem map_tmul (f : M →ₗ⁅R,L⁆ P) (g : N →ₗ⁅R,L⁆ Q) (m : M) (n : N) :
    map f g (m ⊗ₜ n) = f m ⊗ₜ g n :=
  map_tmul f g m n
#align tensor_product.lie_module.map_tmul TensorProduct.LieModule.map_tmul
-/

#print TensorProduct.LieModule.mapIncl /-
/-- Given Lie submodules `M' ⊆ M` and `N' ⊆ N`, this is the natural map: `M' ⊗ N' → M ⊗ N`. -/
def mapIncl (M' : LieSubmodule R L M) (N' : LieSubmodule R L N) : M' ⊗[R] N' →ₗ⁅R,L⁆ M ⊗[R] N :=
  map M'.incl N'.incl
#align tensor_product.lie_module.map_incl TensorProduct.LieModule.mapIncl
-/

#print TensorProduct.LieModule.mapIncl_def /-
@[simp]
theorem mapIncl_def (M' : LieSubmodule R L M) (N' : LieSubmodule R L N) :
    mapIncl M' N' = map M'.incl N'.incl :=
  rfl
#align tensor_product.lie_module.map_incl_def TensorProduct.LieModule.mapIncl_def
-/

end LieModule

end TensorProduct

namespace LieModule

open scoped TensorProduct

variable (R) (L : Type v) (M : Type w)

variable [LieRing L] [LieAlgebra R L]

variable [AddCommGroup M] [Module R M] [LieRingModule L M] [LieModule R L M]

#print LieModule.toModuleHom /-
/-- The action of the Lie algebra on one of its modules, regarded as a morphism of Lie modules. -/
def toModuleHom : L ⊗[R] M →ₗ⁅R,L⁆ M :=
  TensorProduct.LieModule.liftLie R L L M M
    { (toEndomorphism R L M : L →ₗ[R] M →ₗ[R] M) with
      map_lie' := fun x m => by ext n; simp [LieRing.of_associative_ring_bracket] }
#align lie_module.to_module_hom LieModule.toModuleHom
-/

#print LieModule.toModuleHom_apply /-
@[simp]
theorem toModuleHom_apply (x : L) (m : M) : toModuleHom R L M (x ⊗ₜ m) = ⁅x, m⁆ := by
  simp only [to_module_hom, TensorProduct.LieModule.liftLie_apply, to_endomorphism_apply_apply,
    LieHom.coe_toLinearMap, LieModuleHom.coe_mk, LinearMap.coe_mk, LinearMap.toFun_eq_coe]
#align lie_module.to_module_hom_apply LieModule.toModuleHom_apply
-/

end LieModule

namespace LieSubmodule

open scoped TensorProduct

open TensorProduct.LieModule

open LieModule

variable {L : Type v} {M : Type w}

variable [LieRing L] [LieAlgebra R L]

variable [AddCommGroup M] [Module R M] [LieRingModule L M] [LieModule R L M]

variable (I : LieIdeal R L) (N : LieSubmodule R L M)

#print LieSubmodule.lieIdeal_oper_eq_tensor_map_range /-
/-- A useful alternative characterisation of Lie ideal operations on Lie submodules.

Given a Lie ideal `I ⊆ L` and a Lie submodule `N ⊆ M`, by tensoring the inclusion maps and then
applying the action of `L` on `M`, we obtain morphism of Lie modules `f : I ⊗ N → L ⊗ M → M`.

This lemma states that `⁅I, N⁆ = range f`. -/
theorem lieIdeal_oper_eq_tensor_map_range :
    ⁅I, N⁆ = ((toModuleHom R L M).comp (mapIncl I N : ↥I ⊗ ↥N →ₗ⁅R,L⁆ L ⊗ M)).range :=
  by
  rw [← coe_to_submodule_eq_iff, lie_ideal_oper_eq_linear_span, LieModuleHom.coeSubmodule_range,
    LieModuleHom.coe_linearMap_comp, LinearMap.range_comp, map_incl_def, coe_linear_map_map,
    TensorProduct.map_range_eq_span_tmul, Submodule.map_span]
  congr; ext m; constructor
  · rintro ⟨⟨x, hx⟩, ⟨n, hn⟩, rfl⟩; use x ⊗ₜ n; constructor
    · use ⟨x, hx⟩, ⟨n, hn⟩; simp
    · simp
  · rintro ⟨t, ⟨⟨x, hx⟩, ⟨n, hn⟩, rfl⟩, h⟩; rw [← h]; use ⟨x, hx⟩, ⟨n, hn⟩; simp
#align lie_submodule.lie_ideal_oper_eq_tensor_map_range LieSubmodule.lieIdeal_oper_eq_tensor_map_range
-/

end LieSubmodule

