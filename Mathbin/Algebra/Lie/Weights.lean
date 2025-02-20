/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.weights
! leanprover-community/mathlib commit 8af7091a43227e179939ba132e54e54e9f3b089a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Lie.Nilpotent
import Mathbin.Algebra.Lie.TensorProduct
import Mathbin.Algebra.Lie.Character
import Mathbin.Algebra.Lie.Engel
import Mathbin.Algebra.Lie.CartanSubalgebra
import Mathbin.LinearAlgebra.Eigenspace.Basic
import Mathbin.RingTheory.TensorProduct

/-!
# Weights and roots of Lie modules and Lie algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Just as a key tool when studying the behaviour of a linear operator is to decompose the space on
which it acts into a sum of (generalised) eigenspaces, a key tool when studying a representation `M`
of Lie algebra `L` is to decompose `M` into a sum of simultaneous eigenspaces of `x` as `x` ranges
over `L`. These simultaneous generalised eigenspaces are known as the weight spaces of `M`.

When `L` is nilpotent, it follows from the binomial theorem that weight spaces are Lie submodules.
Even when `L` is not nilpotent, it may be useful to study its representations by restricting them
to a nilpotent subalgebra (e.g., a Cartan subalgebra). In the particular case when we view `L` as a
module over itself via the adjoint action, the weight spaces of `L` restricted to a nilpotent
subalgebra are known as root spaces.

Basic definitions and properties of the above ideas are provided in this file.

## Main definitions

  * `lie_module.weight_space`
  * `lie_module.is_weight`
  * `lie_algebra.root_space`
  * `lie_algebra.is_root`
  * `lie_algebra.root_space_weight_space_product`
  * `lie_algebra.root_space_product`
  * `lie_algebra.zero_root_subalgebra_eq_iff_is_cartan`

## References

* [N. Bourbaki, *Lie Groups and Lie Algebras, Chapters 7--9*](bourbaki1975b)

## Tags

lie character, eigenvalue, eigenspace, weight, weight vector, root, root vector
-/


universe u v w w₁ w₂ w₃

variable {R : Type u} {L : Type v} [CommRing R] [LieRing L] [LieAlgebra R L]

variable (H : LieSubalgebra R L) [LieAlgebra.IsNilpotent R H]

variable (M : Type w) [AddCommGroup M] [Module R M] [LieRingModule L M] [LieModule R L M]

namespace LieModule

open LieAlgebra

open TensorProduct

open TensorProduct.LieModule

open scoped BigOperators

open scoped TensorProduct

#print LieModule.preWeightSpace /-
/-- Given a Lie module `M` over a Lie algebra `L`, the pre-weight space of `M` with respect to a
map `χ : L → R` is the simultaneous generalized eigenspace of the action of all `x : L` on `M`,
with eigenvalues `χ x`.

See also `lie_module.weight_space`. -/
def preWeightSpace (χ : L → R) : Submodule R M :=
  ⨅ x : L, (toEndomorphism R L M x).maximalGeneralizedEigenspace (χ x)
#align lie_module.pre_weight_space LieModule.preWeightSpace
-/

#print LieModule.mem_preWeightSpace /-
theorem mem_preWeightSpace (χ : L → R) (m : M) :
    m ∈ preWeightSpace M χ ↔ ∀ x, ∃ k : ℕ, ((toEndomorphism R L M x - χ x • 1) ^ k) m = 0 := by
  simp [pre_weight_space, -LinearMap.pow_apply]
#align lie_module.mem_pre_weight_space LieModule.mem_preWeightSpace
-/

variable (R)

#print LieModule.exists_preWeightSpace_zero_le_ker_of_isNoetherian /-
theorem exists_preWeightSpace_zero_le_ker_of_isNoetherian [IsNoetherian R M] (x : L) :
    ∃ k : ℕ, preWeightSpace M (0 : L → R) ≤ (toEndomorphism R L M x ^ k).ker :=
  by
  use (to_endomorphism R L M x).maximalGeneralizedEigenspaceIndex 0
  simp only [← Module.End.generalizedEigenspace_zero, pre_weight_space, Pi.zero_apply, iInf_le, ←
    (to_endomorphism R L M x).maximalGeneralizedEigenspace_eq]
#align lie_module.exists_pre_weight_space_zero_le_ker_of_is_noetherian LieModule.exists_preWeightSpace_zero_le_ker_of_isNoetherian
-/

variable {R} (L)

#print LieModule.weight_vector_multiplication /-
/-- See also `bourbaki1975b` Chapter VII §1.1, Proposition 2 (ii). -/
protected theorem weight_vector_multiplication (M₁ : Type w₁) (M₂ : Type w₂) (M₃ : Type w₃)
    [AddCommGroup M₁] [Module R M₁] [LieRingModule L M₁] [LieModule R L M₁] [AddCommGroup M₂]
    [Module R M₂] [LieRingModule L M₂] [LieModule R L M₂] [AddCommGroup M₃] [Module R M₃]
    [LieRingModule L M₃] [LieModule R L M₃] (g : M₁ ⊗[R] M₂ →ₗ⁅R,L⁆ M₃) (χ₁ χ₂ : L → R) :
    ((g : M₁ ⊗[R] M₂ →ₗ[R] M₃).comp (mapIncl (preWeightSpace M₁ χ₁) (preWeightSpace M₂ χ₂))).range ≤
      preWeightSpace M₃ (χ₁ + χ₂) :=
  by
  -- Unpack the statement of the goal.
  intro m₃
  simp only [LieModuleHom.coe_toLinearMap, Pi.add_apply, Function.comp_apply, mem_pre_weight_space,
    LinearMap.coe_comp, TensorProduct.mapIncl, exists_imp, LinearMap.mem_range]
  rintro t rfl x
  -- Set up some notation.
  let F : Module.End R M₃ := to_endomorphism R L M₃ x - (χ₁ x + χ₂ x) • 1
  change ∃ k, (F ^ k) (g _) = 0
  -- The goal is linear in `t` so use induction to reduce to the case that `t` is a pure tensor.
  apply t.induction_on
  · use 0; simp only [LinearMap.map_zero, LieModuleHom.map_zero]
  swap
  · rintro t₁ t₂ ⟨k₁, hk₁⟩ ⟨k₂, hk₂⟩; use max k₁ k₂
    simp only [LieModuleHom.map_add, LinearMap.map_add,
      LinearMap.pow_map_zero_of_le (le_max_left k₁ k₂) hk₁,
      LinearMap.pow_map_zero_of_le (le_max_right k₁ k₂) hk₂, add_zero]
  -- Now the main argument: pure tensors.
  rintro ⟨m₁, hm₁⟩ ⟨m₂, hm₂⟩
  change ∃ k, (F ^ k) ((g : M₁ ⊗[R] M₂ →ₗ[R] M₃) (m₁ ⊗ₜ m₂)) = 0
  -- Eliminate `g` from the picture.
  let f₁ : Module.End R (M₁ ⊗[R] M₂) := (to_endomorphism R L M₁ x - χ₁ x • 1).rTensor M₂
  let f₂ : Module.End R (M₁ ⊗[R] M₂) := (to_endomorphism R L M₂ x - χ₂ x • 1).lTensor M₁
  have h_comm_square : F ∘ₗ ↑g = (g : M₁ ⊗[R] M₂ →ₗ[R] M₃).comp (f₁ + f₂) :=
    by
    ext m₁ m₂;
    simp only [← g.map_lie x (m₁ ⊗ₜ m₂), add_smul, sub_tmul, tmul_sub, smul_tmul, lie_tmul_right,
      tmul_smul, to_endomorphism_apply_apply, LieModuleHom.map_smul, LinearMap.one_apply,
      LieModuleHom.coe_toLinearMap, LinearMap.smul_apply, Function.comp_apply, LinearMap.coe_comp,
      LinearMap.rTensor_tmul, LieModuleHom.map_add, LinearMap.add_apply, LieModuleHom.map_sub,
      LinearMap.sub_apply, LinearMap.lTensor_tmul, algebra_tensor_module.curry_apply, curry_apply,
      LinearMap.toFun_eq_coe, LinearMap.coe_restrictScalars]
    abel
  rsuffices ⟨k, hk⟩ : ∃ k, ((f₁ + f₂) ^ k) (m₁ ⊗ₜ m₂) = 0
  · use k
    rw [← LinearMap.comp_apply, LinearMap.commute_pow_left_of_commute h_comm_square,
      LinearMap.comp_apply, hk, LinearMap.map_zero]
  -- Unpack the information we have about `m₁`, `m₂`.
  simp only [mem_pre_weight_space] at hm₁ hm₂ 
  obtain ⟨k₁, hk₁⟩ := hm₁ x
  obtain ⟨k₂, hk₂⟩ := hm₂ x
  have hf₁ : (f₁ ^ k₁) (m₁ ⊗ₜ m₂) = 0 := by
    simp only [hk₁, zero_tmul, LinearMap.rTensor_tmul, LinearMap.rTensor_pow]
  have hf₂ : (f₂ ^ k₂) (m₁ ⊗ₜ m₂) = 0 := by
    simp only [hk₂, tmul_zero, LinearMap.lTensor_tmul, LinearMap.lTensor_pow]
  -- It's now just an application of the binomial theorem.
  use k₁ + k₂ - 1
  have hf_comm : Commute f₁ f₂ := by ext m₁ m₂;
    simp only [LinearMap.mul_apply, LinearMap.rTensor_tmul, LinearMap.lTensor_tmul,
      algebra_tensor_module.curry_apply, LinearMap.toFun_eq_coe, LinearMap.lTensor_tmul,
      curry_apply, LinearMap.coe_restrictScalars]
  rw [hf_comm.add_pow']
  simp only [TensorProduct.mapIncl, Submodule.subtype_apply, Finset.sum_apply, Submodule.coe_mk,
    LinearMap.coeFn_sum, TensorProduct.map_tmul, LinearMap.smul_apply]
  -- The required sum is zero because each individual term is zero.
  apply Finset.sum_eq_zero
  rintro ⟨i, j⟩ hij
  -- Eliminate the binomial coefficients from the picture.
  suffices (f₁ ^ i * f₂ ^ j) (m₁ ⊗ₜ m₂) = 0 by rw [this]; apply smul_zero
  -- Finish off with appropriate case analysis.
  cases' Nat.le_or_le_of_add_eq_add_pred (finset.nat.mem_antidiagonal.mp hij) with hi hj
  ·
    rw [(hf_comm.pow_pow i j).Eq, LinearMap.mul_apply, LinearMap.pow_map_zero_of_le hi hf₁,
      LinearMap.map_zero]
  · rw [LinearMap.mul_apply, LinearMap.pow_map_zero_of_le hj hf₂, LinearMap.map_zero]
#align lie_module.weight_vector_multiplication LieModule.weight_vector_multiplication
-/

variable {L M}

#print LieModule.lie_mem_preWeightSpace_of_mem_preWeightSpace /-
theorem lie_mem_preWeightSpace_of_mem_preWeightSpace {χ₁ χ₂ : L → R} {x : L} {m : M}
    (hx : x ∈ preWeightSpace L χ₁) (hm : m ∈ preWeightSpace M χ₂) :
    ⁅x, m⁆ ∈ preWeightSpace M (χ₁ + χ₂) :=
  by
  apply LieModule.weight_vector_multiplication L L M M (to_module_hom R L M) χ₁ χ₂
  simp only [LieModuleHom.coe_toLinearMap, Function.comp_apply, LinearMap.coe_comp,
    TensorProduct.mapIncl, LinearMap.mem_range]
  use ⟨x, hx⟩ ⊗ₜ ⟨m, hm⟩
  simp only [Submodule.subtype_apply, to_module_hom_apply, TensorProduct.map_tmul]
  rfl
#align lie_module.lie_mem_pre_weight_space_of_mem_pre_weight_space LieModule.lie_mem_preWeightSpace_of_mem_preWeightSpace
-/

variable (M)

#print LieModule.weightSpace /-
/-- If a Lie algebra is nilpotent, then pre-weight spaces are Lie submodules. -/
def weightSpace [LieAlgebra.IsNilpotent R L] (χ : L → R) : LieSubmodule R L M :=
  { preWeightSpace M χ with
    lie_mem := fun x m hm => by
      rw [← zero_add χ]
      refine' lie_mem_pre_weight_space_of_mem_pre_weight_space _ hm
      suffices pre_weight_space L (0 : L → R) = ⊤ by simp only [this, Submodule.mem_top]
      exact LieAlgebra.iInf_max_gen_zero_eigenspace_eq_top_of_nilpotent R L }
#align lie_module.weight_space LieModule.weightSpace
-/

#print LieModule.mem_weightSpace /-
theorem mem_weightSpace [LieAlgebra.IsNilpotent R L] (χ : L → R) (m : M) :
    m ∈ weightSpace M χ ↔ m ∈ preWeightSpace M χ :=
  Iff.rfl
#align lie_module.mem_weight_space LieModule.mem_weightSpace
-/

#print LieModule.zero_weightSpace_eq_top_of_nilpotent' /-
/-- See also the more useful form `lie_module.zero_weight_space_eq_top_of_nilpotent`. -/
@[simp]
theorem zero_weightSpace_eq_top_of_nilpotent' [LieAlgebra.IsNilpotent R L] [IsNilpotent R L M] :
    weightSpace M (0 : L → R) = ⊤ :=
  by
  rw [← LieSubmodule.coe_toSubmodule_eq_iff, LieSubmodule.top_coeSubmodule]
  exact infi_max_gen_zero_eigenspace_eq_top_of_nilpotent R L M
#align lie_module.zero_weight_space_eq_top_of_nilpotent' LieModule.zero_weightSpace_eq_top_of_nilpotent'
-/

#print LieModule.coe_weightSpace_of_top /-
theorem coe_weightSpace_of_top [LieAlgebra.IsNilpotent R L] (χ : L → R) :
    (weightSpace M (χ ∘ (⊤ : LieSubalgebra R L).incl) : Submodule R M) = weightSpace M χ :=
  by
  ext m
  simp only [weight_space, LieSubmodule.coe_toSubmodule_mk, LieSubalgebra.coe_bracket_of_module,
    Function.comp_apply, mem_pre_weight_space]
  constructor <;> intro h x
  · obtain ⟨k, hk⟩ := h ⟨x, Set.mem_univ x⟩; use k; exact hk
  · obtain ⟨k, hk⟩ := h x; use k; exact hk
#align lie_module.coe_weight_space_of_top LieModule.coe_weightSpace_of_top
-/

#print LieModule.zero_weightSpace_eq_top_of_nilpotent /-
@[simp]
theorem zero_weightSpace_eq_top_of_nilpotent [LieAlgebra.IsNilpotent R L] [IsNilpotent R L M] :
    weightSpace M (0 : (⊤ : LieSubalgebra R L) → R) = ⊤ :=
  by
  /- We use `coe_weight_space_of_top` as a trick to circumvent the fact that we don't (yet) know
      `is_nilpotent R (⊤ : lie_subalgebra R L) M` is equivalent to `is_nilpotent R L M`. -/
  have h₀ : (0 : L → R) ∘ (⊤ : LieSubalgebra R L).incl = 0 := by ext; rfl
  rw [← LieSubmodule.coe_toSubmodule_eq_iff, LieSubmodule.top_coeSubmodule, ← h₀,
    coe_weight_space_of_top, ← infi_max_gen_zero_eigenspace_eq_top_of_nilpotent R L M]
  rfl
#align lie_module.zero_weight_space_eq_top_of_nilpotent LieModule.zero_weightSpace_eq_top_of_nilpotent
-/

#print LieModule.IsWeight /-
/-- Given a Lie module `M` of a Lie algebra `L`, a weight of `M` with respect to a nilpotent
subalgebra `H ⊆ L` is a Lie character whose corresponding weight space is non-empty. -/
def IsWeight (χ : LieCharacter R H) : Prop :=
  weightSpace M χ ≠ ⊥
#align lie_module.is_weight LieModule.IsWeight
-/

#print LieModule.isWeight_zero_of_nilpotent /-
/-- For a non-trivial nilpotent Lie module over a nilpotent Lie algebra, the zero character is a
weight with respect to the `⊤` Lie subalgebra. -/
theorem isWeight_zero_of_nilpotent [Nontrivial M] [LieAlgebra.IsNilpotent R L] [IsNilpotent R L M] :
    IsWeight (⊤ : LieSubalgebra R L) M 0 := by
  rw [is_weight, LieHom.coe_zero, zero_weight_space_eq_top_of_nilpotent]; exact top_ne_bot
#align lie_module.is_weight_zero_of_nilpotent LieModule.isWeight_zero_of_nilpotent
-/

#print LieModule.isNilpotent_toEndomorphism_weightSpace_zero /-
/-- A (nilpotent) Lie algebra acts nilpotently on the zero weight space of a Noetherian Lie
module. -/
theorem isNilpotent_toEndomorphism_weightSpace_zero [LieAlgebra.IsNilpotent R L] [IsNoetherian R M]
    (x : L) : IsNilpotent <| toEndomorphism R L (weightSpace M (0 : L → R)) x :=
  by
  obtain ⟨k, hk⟩ := exists_pre_weight_space_zero_le_ker_of_is_noetherian R M x
  use k
  ext ⟨m, hm⟩
  rw [LinearMap.zero_apply, LieSubmodule.coe_zero, Submodule.coe_eq_zero, ←
    LieSubmodule.toEndomorphism_restrict_eq_toEndomorphism, LinearMap.pow_restrict, ←
    SetLike.coe_eq_coe, LinearMap.restrict_apply, Submodule.coe_mk, Submodule.coe_zero]
  exact hk hm
#align lie_module.is_nilpotent_to_endomorphism_weight_space_zero LieModule.isNilpotent_toEndomorphism_weightSpace_zero
-/

/-- By Engel's theorem, when the Lie algebra is Noetherian, the zero weight space of a Noetherian
Lie module is nilpotent. -/
instance [LieAlgebra.IsNilpotent R L] [IsNoetherian R L] [IsNoetherian R M] :
    IsNilpotent R L (weightSpace M (0 : L → R)) :=
  isNilpotent_iff_forall.mpr <| isNilpotent_toEndomorphism_weightSpace_zero M

end LieModule

namespace LieAlgebra

open scoped TensorProduct

open TensorProduct.LieModule

open LieModule

#print LieAlgebra.rootSpace /-
/-- Given a nilpotent Lie subalgebra `H ⊆ L`, the root space of a map `χ : H → R` is the weight
space of `L` regarded as a module of `H` via the adjoint action. -/
abbrev rootSpace (χ : H → R) : LieSubmodule R H L :=
  weightSpace L χ
#align lie_algebra.root_space LieAlgebra.rootSpace
-/

#print LieAlgebra.zero_rootSpace_eq_top_of_nilpotent /-
@[simp]
theorem zero_rootSpace_eq_top_of_nilpotent [h : IsNilpotent R L] :
    rootSpace (⊤ : LieSubalgebra R L) 0 = ⊤ :=
  zero_weightSpace_eq_top_of_nilpotent L
#align lie_algebra.zero_root_space_eq_top_of_nilpotent LieAlgebra.zero_rootSpace_eq_top_of_nilpotent
-/

#print LieAlgebra.IsRoot /-
/-- A root of a Lie algebra `L` with respect to a nilpotent subalgebra `H ⊆ L` is a weight of `L`,
regarded as a module of `H` via the adjoint action. -/
abbrev IsRoot :=
  IsWeight H L
#align lie_algebra.is_root LieAlgebra.IsRoot
-/

#print LieAlgebra.rootSpace_comap_eq_weightSpace /-
@[simp]
theorem rootSpace_comap_eq_weightSpace (χ : H → R) :
    (rootSpace H χ).comap H.incl' = weightSpace H χ :=
  by
  ext x
  let f : H → Module.End R L := fun y => to_endomorphism R H L y - χ y • 1
  let g : H → Module.End R H := fun y => to_endomorphism R H H y - χ y • 1
  suffices
    (∀ y : H, ∃ k : ℕ, (f y ^ k).comp (H.incl : H →ₗ[R] L) x = 0) ↔
      ∀ y : H, ∃ k : ℕ, (H.incl : H →ₗ[R] L).comp (g y ^ k) x = 0
    by
    simp only [LieHom.coe_toLinearMap, LieSubalgebra.coe_incl, Function.comp_apply,
      LinearMap.coe_comp, Submodule.coe_eq_zero] at this 
    simp only [mem_weight_space, mem_pre_weight_space, LieSubalgebra.coe_incl',
      LieSubmodule.mem_comap, this]
  have hfg : ∀ y : H, (f y).comp (H.incl : H →ₗ[R] L) = (H.incl : H →ₗ[R] L).comp (g y) :=
    by
    rintro ⟨y, hy⟩; ext ⟨z, hz⟩
    simp only [Submodule.coe_sub, to_endomorphism_apply_apply, LieHom.coe_toLinearMap,
      LinearMap.one_apply, LieSubalgebra.coe_incl, LieSubalgebra.coe_bracket_of_module,
      LieSubalgebra.coe_bracket, LinearMap.smul_apply, Function.comp_apply,
      Submodule.coe_smul_of_tower, LinearMap.coe_comp, LinearMap.sub_apply]
  simp_rw [LinearMap.commute_pow_left_of_commute (hfg _)]
#align lie_algebra.root_space_comap_eq_weight_space LieAlgebra.rootSpace_comap_eq_weightSpace
-/

variable {H M}

#print LieAlgebra.lie_mem_weightSpace_of_mem_weightSpace /-
theorem lie_mem_weightSpace_of_mem_weightSpace {χ₁ χ₂ : H → R} {x : L} {m : M}
    (hx : x ∈ rootSpace H χ₁) (hm : m ∈ weightSpace M χ₂) : ⁅x, m⁆ ∈ weightSpace M (χ₁ + χ₂) :=
  by
  apply LieModule.weight_vector_multiplication H L M M ((to_module_hom R L M).restrictLie H) χ₁ χ₂
  simp only [LieModuleHom.coe_toLinearMap, Function.comp_apply, LinearMap.coe_comp,
    TensorProduct.mapIncl, LinearMap.mem_range]
  use ⟨x, hx⟩ ⊗ₜ ⟨m, hm⟩
  simp only [Submodule.subtype_apply, to_module_hom_apply, Submodule.coe_mk,
    LieModuleHom.coe_restrictLie, TensorProduct.map_tmul]
#align lie_algebra.lie_mem_weight_space_of_mem_weight_space LieAlgebra.lie_mem_weightSpace_of_mem_weightSpace
-/

variable (R L H M)

#print LieAlgebra.rootSpaceWeightSpaceProductAux /-
/-- Auxiliary definition for `root_space_weight_space_product`,
which is close to the deterministic timeout limit.
-/
def rootSpaceWeightSpaceProductAux {χ₁ χ₂ χ₃ : H → R} (hχ : χ₁ + χ₂ = χ₃) :
    rootSpace H χ₁ →ₗ[R] weightSpace M χ₂ →ₗ[R] weightSpace M χ₃
    where
  toFun x :=
    { toFun := fun m =>
        ⟨⁅(x : L), (m : M)⁆, hχ ▸ lie_mem_weightSpace_of_mem_weightSpace x.property m.property⟩
      map_add' := fun m n => by simp only [LieSubmodule.coe_add, lie_add]; rfl
      map_smul' := fun t m => by
        conv_lhs =>
          congr
          rw [LieSubmodule.coe_smul, lie_smul];
        rfl }
  map_add' x y := by
    ext m <;>
      rw [LinearMap.add_apply, LinearMap.coe_mk, LinearMap.coe_mk, LinearMap.coe_mk, Subtype.coe_mk,
        LieSubmodule.coe_add, LieSubmodule.coe_add, add_lie, Subtype.coe_mk, Subtype.coe_mk]
  map_smul' t x := by
    simp only [RingHom.id_apply]
    ext m
    rw [LinearMap.smul_apply, LinearMap.coe_mk, LinearMap.coe_mk, Subtype.coe_mk,
      LieSubmodule.coe_smul, smul_lie, LieSubmodule.coe_smul, Subtype.coe_mk]
#align lie_algebra.root_space_weight_space_product_aux LieAlgebra.rootSpaceWeightSpaceProductAux
-/

#print LieAlgebra.rootSpaceWeightSpaceProduct /-
/-- Given a nilpotent Lie subalgebra `H ⊆ L` together with `χ₁ χ₂ : H → R`, there is a natural
`R`-bilinear product of root vectors and weight vectors, compatible with the actions of `H`. -/
def rootSpaceWeightSpaceProduct (χ₁ χ₂ χ₃ : H → R) (hχ : χ₁ + χ₂ = χ₃) :
    rootSpace H χ₁ ⊗[R] weightSpace M χ₂ →ₗ⁅R,H⁆ weightSpace M χ₃ :=
  liftLie R H (rootSpace H χ₁) (weightSpace M χ₂) (weightSpace M χ₃)
    { toLinearMap := rootSpaceWeightSpaceProductAux R L H M hχ
      map_lie' := fun x y => by
        ext m <;>
          rw [root_space_weight_space_product_aux, LieHom.lie_apply, LieSubmodule.coe_sub,
            LinearMap.coe_mk, LinearMap.coe_mk, Subtype.coe_mk, Subtype.coe_mk,
            LieSubmodule.coe_bracket, LieSubmodule.coe_bracket, Subtype.coe_mk,
            LieSubalgebra.coe_bracket_of_module, LieSubalgebra.coe_bracket_of_module,
            LieSubmodule.coe_bracket, LieSubalgebra.coe_bracket_of_module, lie_lie] }
#align lie_algebra.root_space_weight_space_product LieAlgebra.rootSpaceWeightSpaceProduct
-/

#print LieAlgebra.coe_rootSpaceWeightSpaceProduct_tmul /-
@[simp]
theorem coe_rootSpaceWeightSpaceProduct_tmul (χ₁ χ₂ χ₃ : H → R) (hχ : χ₁ + χ₂ = χ₃)
    (x : rootSpace H χ₁) (m : weightSpace M χ₂) :
    (rootSpaceWeightSpaceProduct R L H M χ₁ χ₂ χ₃ hχ (x ⊗ₜ m) : M) = ⁅(x : L), (m : M)⁆ := by
  simp only [root_space_weight_space_product, root_space_weight_space_product_aux, lift_apply,
    LieModuleHom.coe_toLinearMap, coe_lift_lie_eq_lift_coe, Submodule.coe_mk, LinearMap.coe_mk,
    LieModuleHom.coe_mk]
#align lie_algebra.coe_root_space_weight_space_product_tmul LieAlgebra.coe_rootSpaceWeightSpaceProduct_tmul
-/

#print LieAlgebra.rootSpaceProduct /-
/-- Given a nilpotent Lie subalgebra `H ⊆ L` together with `χ₁ χ₂ : H → R`, there is a natural
`R`-bilinear product of root vectors, compatible with the actions of `H`. -/
def rootSpaceProduct (χ₁ χ₂ χ₃ : H → R) (hχ : χ₁ + χ₂ = χ₃) :
    rootSpace H χ₁ ⊗[R] rootSpace H χ₂ →ₗ⁅R,H⁆ rootSpace H χ₃ :=
  rootSpaceWeightSpaceProduct R L H L χ₁ χ₂ χ₃ hχ
#align lie_algebra.root_space_product LieAlgebra.rootSpaceProduct
-/

#print LieAlgebra.rootSpaceProduct_def /-
@[simp]
theorem rootSpaceProduct_def : rootSpaceProduct R L H = rootSpaceWeightSpaceProduct R L H L :=
  rfl
#align lie_algebra.root_space_product_def LieAlgebra.rootSpaceProduct_def
-/

#print LieAlgebra.rootSpaceProduct_tmul /-
theorem rootSpaceProduct_tmul (χ₁ χ₂ χ₃ : H → R) (hχ : χ₁ + χ₂ = χ₃) (x : rootSpace H χ₁)
    (y : rootSpace H χ₂) : (rootSpaceProduct R L H χ₁ χ₂ χ₃ hχ (x ⊗ₜ y) : L) = ⁅(x : L), (y : L)⁆ :=
  by simp only [root_space_product_def, coe_root_space_weight_space_product_tmul]
#align lie_algebra.root_space_product_tmul LieAlgebra.rootSpaceProduct_tmul
-/

#print LieAlgebra.zeroRootSubalgebra /-
/-- Given a nilpotent Lie subalgebra `H ⊆ L`, the root space of the zero map `0 : H → R` is a Lie
subalgebra of `L`. -/
def zeroRootSubalgebra : LieSubalgebra R L :=
  { (rootSpace H 0 : Submodule R L) with
    lie_mem' := fun x y hx hy =>
      by
      let xy : root_space H 0 ⊗[R] root_space H 0 := ⟨x, hx⟩ ⊗ₜ ⟨y, hy⟩
      suffices (root_space_product R L H 0 0 0 (add_zero 0) xy : L) ∈ root_space H 0 by
        rwa [root_space_product_tmul, Subtype.coe_mk, Subtype.coe_mk] at this 
      exact (root_space_product R L H 0 0 0 (add_zero 0) xy).property }
#align lie_algebra.zero_root_subalgebra LieAlgebra.zeroRootSubalgebra
-/

#print LieAlgebra.coe_zeroRootSubalgebra /-
@[simp]
theorem coe_zeroRootSubalgebra : (zeroRootSubalgebra R L H : Submodule R L) = rootSpace H 0 :=
  rfl
#align lie_algebra.coe_zero_root_subalgebra LieAlgebra.coe_zeroRootSubalgebra
-/

#print LieAlgebra.mem_zeroRootSubalgebra /-
theorem mem_zeroRootSubalgebra (x : L) :
    x ∈ zeroRootSubalgebra R L H ↔ ∀ y : H, ∃ k : ℕ, (toEndomorphism R H L y ^ k) x = 0 := by
  simp only [zero_root_subalgebra, mem_weight_space, mem_pre_weight_space, Pi.zero_apply, sub_zero,
    SetLike.mem_coe, zero_smul, LieSubmodule.mem_coeSubmodule, Submodule.mem_carrier,
    LieSubalgebra.mem_mk_iff]
#align lie_algebra.mem_zero_root_subalgebra LieAlgebra.mem_zeroRootSubalgebra
-/

#print LieAlgebra.toLieSubmodule_le_rootSpace_zero /-
theorem toLieSubmodule_le_rootSpace_zero : H.toLieSubmodule ≤ rootSpace H 0 :=
  by
  intro x hx
  simp only [LieSubalgebra.mem_toLieSubmodule] at hx 
  simp only [mem_weight_space, mem_pre_weight_space, Pi.zero_apply, sub_zero, zero_smul]
  intro y
  obtain ⟨k, hk⟩ := (inferInstance : IsNilpotent R H)
  use k
  let f : Module.End R H := to_endomorphism R H H y
  let g : Module.End R L := to_endomorphism R H L y
  have hfg : g.comp (H : Submodule R L).Subtype = (H : Submodule R L).Subtype.comp f := by ext z;
    simp only [to_endomorphism_apply_apply, Submodule.subtype_apply,
      LieSubalgebra.coe_bracket_of_module, LieSubalgebra.coe_bracket, Function.comp_apply,
      LinearMap.coe_comp]
  change (g ^ k).comp (H : Submodule R L).Subtype ⟨x, hx⟩ = 0
  rw [LinearMap.commute_pow_left_of_commute hfg k]
  have h := iterate_to_endomorphism_mem_lower_central_series R H H y ⟨x, hx⟩ k
  rw [hk, LieSubmodule.mem_bot] at h 
  simp only [Submodule.subtype_apply, Function.comp_apply, LinearMap.pow_apply, LinearMap.coe_comp,
    Submodule.coe_eq_zero]
  exact h
#align lie_algebra.to_lie_submodule_le_root_space_zero LieAlgebra.toLieSubmodule_le_rootSpace_zero
-/

#print LieAlgebra.le_zeroRootSubalgebra /-
theorem le_zeroRootSubalgebra : H ≤ zeroRootSubalgebra R L H :=
  by
  rw [← LieSubalgebra.coe_submodule_le_coe_submodule, ← H.coe_to_lie_submodule,
    coe_zero_root_subalgebra, LieSubmodule.coeSubmodule_le_coeSubmodule]
  exact to_lie_submodule_le_root_space_zero R L H
#align lie_algebra.le_zero_root_subalgebra LieAlgebra.le_zeroRootSubalgebra
-/

#print LieAlgebra.zeroRootSubalgebra_normalizer_eq_self /-
@[simp]
theorem zeroRootSubalgebra_normalizer_eq_self :
    (zeroRootSubalgebra R L H).normalizer = zeroRootSubalgebra R L H :=
  by
  refine' le_antisymm _ (LieSubalgebra.le_normalizer _)
  intro x hx
  rw [LieSubalgebra.mem_normalizer_iff] at hx 
  rw [mem_zero_root_subalgebra]
  rintro ⟨y, hy⟩
  specialize hx y (le_zero_root_subalgebra R L H hy)
  rw [mem_zero_root_subalgebra] at hx 
  obtain ⟨k, hk⟩ := hx ⟨y, hy⟩
  rw [← lie_skew, LinearMap.map_neg, neg_eq_zero] at hk 
  use k + 1
  rw [LinearMap.iterate_succ, LinearMap.coe_comp, Function.comp_apply, to_endomorphism_apply_apply,
    LieSubalgebra.coe_bracket_of_module, Submodule.coe_mk, hk]
#align lie_algebra.zero_root_subalgebra_normalizer_eq_self LieAlgebra.zeroRootSubalgebra_normalizer_eq_self
-/

#print LieAlgebra.is_cartan_of_zeroRootSubalgebra_eq /-
/-- If the zero root subalgebra of a nilpotent Lie subalgebra `H` is just `H` then `H` is a Cartan
subalgebra.

When `L` is Noetherian, it follows from Engel's theorem that the converse holds. See
`lie_algebra.zero_root_subalgebra_eq_iff_is_cartan` -/
theorem is_cartan_of_zeroRootSubalgebra_eq (h : zeroRootSubalgebra R L H = H) :
    H.IsCartanSubalgebra :=
  { nilpotent := inferInstance
    self_normalizing := by rw [← h]; exact zero_root_subalgebra_normalizer_eq_self R L H }
#align lie_algebra.is_cartan_of_zero_root_subalgebra_eq LieAlgebra.is_cartan_of_zeroRootSubalgebra_eq
-/

#print LieAlgebra.zeroRootSubalgebra_eq_of_is_cartan /-
@[simp]
theorem zeroRootSubalgebra_eq_of_is_cartan (H : LieSubalgebra R L) [H.IsCartanSubalgebra]
    [IsNoetherian R L] : zeroRootSubalgebra R L H = H :=
  by
  refine' le_antisymm _ (le_zero_root_subalgebra R L H)
  suffices root_space H 0 ≤ H.to_lie_submodule by exact fun x hx => this hx
  obtain ⟨k, hk⟩ := (root_space H 0).isNilpotent_iff_exists_self_le_ucs.mp (by infer_instance)
  exact hk.trans (LieSubmodule.ucs_le_of_normalizer_eq_self (by simp) k)
#align lie_algebra.zero_root_subalgebra_eq_of_is_cartan LieAlgebra.zeroRootSubalgebra_eq_of_is_cartan
-/

#print LieAlgebra.zeroRootSubalgebra_eq_iff_is_cartan /-
theorem zeroRootSubalgebra_eq_iff_is_cartan [IsNoetherian R L] :
    zeroRootSubalgebra R L H = H ↔ H.IsCartanSubalgebra :=
  ⟨is_cartan_of_zeroRootSubalgebra_eq R L H, by intros; simp⟩
#align lie_algebra.zero_root_subalgebra_eq_iff_is_cartan LieAlgebra.zeroRootSubalgebra_eq_iff_is_cartan
-/

end LieAlgebra

namespace LieModule

open LieAlgebra

variable {R L H}

#print LieModule.weightSpace' /-
/-- A priori, weight spaces are Lie submodules over the Lie subalgebra `H` used to define them.
However they are naturally Lie submodules over the (in general larger) Lie subalgebra
`zero_root_subalgebra R L H`. Even though it is often the case that
`zero_root_subalgebra R L H = H`, it is likely to be useful to have the flexibility not to have
to invoke this equality (as well as to work more generally). -/
def weightSpace' (χ : H → R) : LieSubmodule R (zeroRootSubalgebra R L H) M :=
  { (weightSpace M χ : Submodule R M) with
    lie_mem := fun x m hm =>
      by
      have hx : (x : L) ∈ root_space H 0 := by
        rw [← LieSubmodule.mem_coeSubmodule, ← coe_zero_root_subalgebra]; exact x.property
      rw [← zero_add χ]
      exact lie_mem_weight_space_of_mem_weight_space hx hm }
#align lie_module.weight_space' LieModule.weightSpace'
-/

#print LieModule.coe_weightSpace' /-
@[simp]
theorem coe_weightSpace' (χ : H → R) : (weightSpace' M χ : Submodule R M) = weightSpace M χ :=
  rfl
#align lie_module.coe_weight_space' LieModule.coe_weightSpace'
-/

end LieModule

