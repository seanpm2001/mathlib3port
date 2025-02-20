/-
Copyright (c) 2022 Moritz Doll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll

! This file was ported from Lean 3 source module analysis.inner_product_space.linear_pmap
! leanprover-community/mathlib commit 9240e8be927a0955b9a82c6c85ef499ee3a626b8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.Adjoint
import Mathbin.Topology.Algebra.Module.LinearPmap
import Mathbin.Topology.Algebra.Module.Basic

/-!

# Partially defined linear operators on Hilbert spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We will develop the basics of the theory of unbounded operators on Hilbert spaces.

## Main definitions

* `linear_pmap.is_formal_adjoint`: An operator `T` is a formal adjoint of `S` if for all `x` in the
  domain of `T` and `y` in the domain of `S`, we have that `⟪T x, y⟫ = ⟪x, S y⟫`.
* `linear_pmap.adjoint`: The adjoint of a map `E →ₗ.[𝕜] F` as a map `F →ₗ.[𝕜] E`.

## Main statements

* `linear_pmap.adjoint_is_formal_adjoint`: The adjoint is a formal adjoint
* `linear_pmap.is_formal_adjoint.le_adjoint`: Every formal adjoint is contained in the adjoint
* `continuous_linear_map.to_pmap_adjoint_eq_adjoint_to_pmap_of_dense`: The adjoint on
  `continuous_linear_map` and `linear_pmap` coincide.

## Notation

* For `T : E →ₗ.[𝕜] F` the adjoint can be written as `T†`.
  This notation is localized in `linear_pmap`.

## Implementation notes

We use the junk value pattern to define the adjoint for all `linear_pmap`s. In the case that
`T : E →ₗ.[𝕜] F` is not densely defined the adjoint `T†` is the zero map from `T.adjoint_domain` to
`E`.

## References

* [J. Weidmann, *Linear Operators in Hilbert Spaces*][weidmann_linear]

## Tags

Unbounded operators, closed operators
-/


noncomputable section

open IsROrC

open scoped ComplexConjugate Classical

variable {𝕜 E F G : Type _} [IsROrC 𝕜]

variable [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]

variable [NormedAddCommGroup F] [InnerProductSpace 𝕜 F]

local notation "⟪" x ", " y "⟫" => @inner 𝕜 _ _ x y

namespace LinearPMap

#print LinearPMap.IsFormalAdjoint /-
/-- An operator `T` is a formal adjoint of `S` if for all `x` in the domain of `T` and `y` in the
domain of `S`, we have that `⟪T x, y⟫ = ⟪x, S y⟫`. -/
def IsFormalAdjoint (T : E →ₗ.[𝕜] F) (S : F →ₗ.[𝕜] E) : Prop :=
  ∀ (x : T.domain) (y : S.domain), ⟪T x, y⟫ = ⟪(x : E), S y⟫
#align linear_pmap.is_formal_adjoint LinearPMap.IsFormalAdjoint
-/

variable {T : E →ₗ.[𝕜] F} {S : F →ₗ.[𝕜] E}

#print LinearPMap.IsFormalAdjoint.symm /-
@[protected]
theorem IsFormalAdjoint.symm (h : T.IsFormalAdjoint S) : S.IsFormalAdjoint T := fun y _ => by
  rw [← inner_conj_symm, ← inner_conj_symm (y : F), h]
#align linear_pmap.is_formal_adjoint.symm LinearPMap.IsFormalAdjoint.symm
-/

variable (T)

#print LinearPMap.adjointDomain /-
/-- The domain of the adjoint operator.

This definition is needed to construct the adjoint operator and the preferred version to use is
`T.adjoint.domain` instead of `T.adjoint_domain`. -/
def adjointDomain : Submodule 𝕜 F
    where
  carrier := {y | Continuous ((innerₛₗ 𝕜 y).comp T.toFun)}
  zero_mem' := by
    rw [Set.mem_setOf_eq, LinearMap.map_zero, LinearMap.zero_comp]
    exact continuous_zero
  add_mem' x y hx hy := by rw [Set.mem_setOf_eq, LinearMap.map_add] at *; exact hx.add hy
  smul_mem' a x hx := by
    rw [Set.mem_setOf_eq, LinearMap.map_smulₛₗ] at *
    exact hx.const_smul (conj a)
#align linear_pmap.adjoint_domain LinearPMap.adjointDomain
-/

#print LinearPMap.adjointDomainMkClm /-
/-- The operator `λ x, ⟪y, T x⟫` considered as a continuous linear operator from `T.adjoint_domain`
to `𝕜`. -/
def adjointDomainMkClm (y : T.adjointDomain) : T.domain →L[𝕜] 𝕜 :=
  ⟨(innerₛₗ 𝕜 (y : F)).comp T.toFun, y.Prop⟩
#align linear_pmap.adjoint_domain_mk_clm LinearPMap.adjointDomainMkClm
-/

#print LinearPMap.adjointDomainMkClm_apply /-
theorem adjointDomainMkClm_apply (y : T.adjointDomain) (x : T.domain) :
    adjointDomainMkClm T y x = ⟪(y : F), T x⟫ :=
  rfl
#align linear_pmap.adjoint_domain_mk_clm_apply LinearPMap.adjointDomainMkClm_apply
-/

variable {T}

variable (hT : Dense (T.domain : Set E))

#print LinearPMap.adjointDomainMkClmExtend /-
/-- The unique continuous extension of the operator `adjoint_domain_mk_clm` to `E`. -/
def adjointDomainMkClmExtend (y : T.adjointDomain) : E →L[𝕜] 𝕜 :=
  (T.adjointDomainMkClm y).extend (Submodule.subtypeL T.domain) hT.denseRange_val
    uniformEmbedding_subtype_val.to_uniformInducing
#align linear_pmap.adjoint_domain_mk_clm_extend LinearPMap.adjointDomainMkClmExtend
-/

#print LinearPMap.adjointDomainMkClmExtend_apply /-
@[simp]
theorem adjointDomainMkClmExtend_apply (y : T.adjointDomain) (x : T.domain) :
    adjointDomainMkClmExtend hT y (x : E) = ⟪(y : F), T x⟫ :=
  ContinuousLinearMap.extend_eq _ _ _ _ _
#align linear_pmap.adjoint_domain_mk_clm_extend_apply LinearPMap.adjointDomainMkClmExtend_apply
-/

variable [CompleteSpace E]

#print LinearPMap.adjointAux /-
/-- The adjoint as a linear map from its domain to `E`.

This is an auxiliary definition needed to define the adjoint operator as a `linear_pmap` without
the assumption that `T.domain` is dense. -/
def adjointAux : T.adjointDomain →ₗ[𝕜] E
    where
  toFun y := (InnerProductSpace.toDual 𝕜 E).symm (adjointDomainMkClmExtend hT y)
  map_add' x y :=
    hT.eq_of_inner_left fun _ => by
      simp only [inner_add_left, Submodule.coe_add, InnerProductSpace.toDual_symm_apply,
        adjoint_domain_mk_clm_extend_apply]
  map_smul' _ _ :=
    hT.eq_of_inner_left fun _ => by
      simp only [inner_smul_left, Submodule.coe_smul_of_tower, RingHom.id_apply,
        InnerProductSpace.toDual_symm_apply, adjoint_domain_mk_clm_extend_apply]
#align linear_pmap.adjoint_aux LinearPMap.adjointAux
-/

#print LinearPMap.adjointAux_inner /-
theorem adjointAux_inner (y : T.adjointDomain) (x : T.domain) :
    ⟪adjointAux hT y, x⟫ = ⟪(y : F), T x⟫ := by
  simp only [adjoint_aux, LinearMap.coe_mk, InnerProductSpace.toDual_symm_apply,
    adjoint_domain_mk_clm_extend_apply]
#align linear_pmap.adjoint_aux_inner LinearPMap.adjointAux_inner
-/

#print LinearPMap.adjointAux_unique /-
theorem adjointAux_unique (y : T.adjointDomain) {x₀ : E}
    (hx₀ : ∀ x : T.domain, ⟪x₀, x⟫ = ⟪(y : F), T x⟫) : adjointAux hT y = x₀ :=
  hT.eq_of_inner_left fun v => (adjointAux_inner hT _ _).trans (hx₀ v).symm
#align linear_pmap.adjoint_aux_unique LinearPMap.adjointAux_unique
-/

variable (T)

#print LinearPMap.adjoint /-
/-- The adjoint operator as a partially defined linear operator. -/
def adjoint : F →ₗ.[𝕜] E where
  domain := T.adjointDomain
  toFun := if hT : Dense (T.domain : Set E) then adjointAux hT else 0
#align linear_pmap.adjoint LinearPMap.adjoint
-/

scoped postfix:1024 "†" => LinearPMap.adjoint

#print LinearPMap.mem_adjoint_domain_iff /-
theorem mem_adjoint_domain_iff (y : F) : y ∈ T†.domain ↔ Continuous ((innerₛₗ 𝕜 y).comp T.toFun) :=
  Iff.rfl
#align linear_pmap.mem_adjoint_domain_iff LinearPMap.mem_adjoint_domain_iff
-/

variable {T}

#print LinearPMap.mem_adjoint_domain_of_exists /-
theorem mem_adjoint_domain_of_exists (y : F) (h : ∃ w : E, ∀ x : T.domain, ⟪w, x⟫ = ⟪y, T x⟫) :
    y ∈ T†.domain := by
  cases' h with w hw
  rw [T.mem_adjoint_domain_iff]
  have : Continuous ((innerSL 𝕜 w).comp T.domain.subtypeL) := by continuity
  convert this using 1
  exact funext fun x => (hw x).symm
#align linear_pmap.mem_adjoint_domain_of_exists LinearPMap.mem_adjoint_domain_of_exists
-/

#print LinearPMap.adjoint_apply_of_not_dense /-
theorem adjoint_apply_of_not_dense (hT : ¬Dense (T.domain : Set E)) (y : T†.domain) : T† y = 0 :=
  by
  change (if hT : Dense (T.domain : Set E) then adjoint_aux hT else 0) y = _
  simp only [hT, not_false_iff, dif_neg, LinearMap.zero_apply]
#align linear_pmap.adjoint_apply_of_not_dense LinearPMap.adjoint_apply_of_not_dense
-/

#print LinearPMap.adjoint_apply_of_dense /-
theorem adjoint_apply_of_dense (y : T†.domain) : T† y = adjointAux hT y :=
  by
  change (if hT : Dense (T.domain : Set E) then adjoint_aux hT else 0) y = _
  simp only [hT, dif_pos, LinearMap.coe_mk]
#align linear_pmap.adjoint_apply_of_dense LinearPMap.adjoint_apply_of_dense
-/

#print LinearPMap.adjoint_apply_eq /-
theorem adjoint_apply_eq (y : T†.domain) {x₀ : E} (hx₀ : ∀ x : T.domain, ⟪x₀, x⟫ = ⟪(y : F), T x⟫) :
    T† y = x₀ :=
  (adjoint_apply_of_dense hT y).symm ▸ adjointAux_unique hT _ hx₀
#align linear_pmap.adjoint_apply_eq LinearPMap.adjoint_apply_eq
-/

#print LinearPMap.adjoint_isFormalAdjoint /-
/-- The fundamental property of the adjoint. -/
theorem adjoint_isFormalAdjoint : T†.IsFormalAdjoint T := fun x =>
  (adjoint_apply_of_dense hT x).symm ▸ adjointAux_inner hT x
#align linear_pmap.adjoint_is_formal_adjoint LinearPMap.adjoint_isFormalAdjoint
-/

#print LinearPMap.IsFormalAdjoint.le_adjoint /-
/-- The adjoint is maximal in the sense that it contains every formal adjoint. -/
theorem IsFormalAdjoint.le_adjoint (h : T.IsFormalAdjoint S) : S ≤ T† :=
  ⟨-- Trivially, every `x : S.domain` is in `T.adjoint.domain`
  fun x hx =>
    mem_adjoint_domain_of_exists _
      ⟨S ⟨x, hx⟩, h.symm ⟨x, hx⟩⟩,-- Equality on `S.domain` follows from equality
  -- `⟪v, S x⟫ = ⟪v, T.adjoint y⟫` for all `v : T.domain`:
  fun _ _ hxy => (adjoint_apply_eq hT _ fun _ => by rw [h.symm, hxy]).symm⟩
#align linear_pmap.is_formal_adjoint.le_adjoint LinearPMap.IsFormalAdjoint.le_adjoint
-/

end LinearPMap

namespace ContinuousLinearMap

variable [CompleteSpace E] [CompleteSpace F]

variable (A : E →L[𝕜] F) {p : Submodule 𝕜 E}

#print ContinuousLinearMap.toPMap_adjoint_eq_adjoint_toPMap_of_dense /-
/-- Restricting `A` to a dense submodule and taking the `linear_pmap.adjoint` is the same
as taking the `continuous_linear_map.adjoint` interpreted as a `linear_pmap`. -/
theorem toPMap_adjoint_eq_adjoint_toPMap_of_dense (hp : Dense (p : Set E)) :
    (A.toPMap p).adjoint = A.adjoint.toPMap ⊤ :=
  by
  ext
  · simp only [to_linear_map_eq_coe, LinearMap.toPMap_domain, Submodule.mem_top, iff_true_iff,
      LinearPMap.mem_adjoint_domain_iff, LinearMap.coe_comp, innerₛₗ_apply_coe]
    exact ((innerSL 𝕜 x).comp <| A.comp <| Submodule.subtypeL _).cont
  intro x y hxy
  refine' LinearPMap.adjoint_apply_eq hp _ fun v => _
  simp only [adjoint_inner_left, hxy, LinearMap.toPMap_apply, to_linear_map_eq_coe, coe_coe]
#align continuous_linear_map.to_pmap_adjoint_eq_adjoint_to_pmap_of_dense ContinuousLinearMap.toPMap_adjoint_eq_adjoint_toPMap_of_dense
-/

end ContinuousLinearMap

