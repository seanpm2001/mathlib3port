/-
Copyright (c) 2022 Paul Reichert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Paul Reichert

! This file was ported from Lean 3 source module linear_algebra.affine_space.restrict
! leanprover-community/mathlib commit cb3ceec8485239a61ed51d944cb9a95b68c6bafc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.AffineSpace.AffineSubspace

/-!
# Affine map restrictions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines restrictions of affine maps.

## Main definitions

* The domain and codomain of an affine map can be restricted using
  `affine_map.restrict`.

## Main theorems

* The associated linear map of the restriction is the restriction of the
  linear map associated to the original affine map.
* The restriction is injective if the original map is injective.
* The restriction in surjective if the codomain is the image of the domain.
-/


variable {k V₁ P₁ V₂ P₂ : Type _} [Ring k] [AddCommGroup V₁] [AddCommGroup V₂] [Module k V₁]
  [Module k V₂] [AddTorsor V₁ P₁] [AddTorsor V₂ P₂]

#print AffineSubspace.nonempty_map /-
-- not an instance because it loops with `nonempty`
theorem AffineSubspace.nonempty_map {E : AffineSubspace k P₁} [Ene : Nonempty E] {φ : P₁ →ᵃ[k] P₂} :
    Nonempty (E.map φ) := by
  obtain ⟨x, hx⟩ := id Ene
  refine' ⟨⟨φ x, affine_subspace.mem_map.mpr ⟨x, hx, rfl⟩⟩⟩
#align affine_subspace.nonempty_map AffineSubspace.nonempty_map
-/

attribute [local instance, local nolint fails_quickly] AffineSubspace.nonempty_map

attribute [local instance, local nolint fails_quickly] AffineSubspace.toAddTorsor

#print AffineMap.restrict /-
/-- Restrict domain and codomain of an affine map to the given subspaces. -/
def AffineMap.restrict (φ : P₁ →ᵃ[k] P₂) {E : AffineSubspace k P₁} {F : AffineSubspace k P₂}
    [Nonempty E] [Nonempty F] (hEF : E.map φ ≤ F) : E →ᵃ[k] F :=
  by
  refine' ⟨_, _, _⟩
  · exact fun x => ⟨φ x, hEF <| affine_subspace.mem_map.mpr ⟨x, x.property, rfl⟩⟩
  · refine' φ.linear.restrict (_ : E.direction ≤ F.direction.comap φ.linear)
    rw [← Submodule.map_le_iff_le_comap, ← AffineSubspace.map_direction]
    exact AffineSubspace.direction_le hEF
  · intro p v
    simp only [Subtype.ext_iff, Subtype.coe_mk, AffineSubspace.coe_vadd]
    apply AffineMap.map_vadd
#align affine_map.restrict AffineMap.restrict
-/

#print AffineMap.restrict.coe_apply /-
theorem AffineMap.restrict.coe_apply (φ : P₁ →ᵃ[k] P₂) {E : AffineSubspace k P₁}
    {F : AffineSubspace k P₂} [Nonempty E] [Nonempty F] (hEF : E.map φ ≤ F) (x : E) :
    ↑(φ.restrict hEF x) = φ x :=
  rfl
#align affine_map.restrict.coe_apply AffineMap.restrict.coe_apply
-/

#print AffineMap.restrict.linear_aux /-
theorem AffineMap.restrict.linear_aux {φ : P₁ →ᵃ[k] P₂} {E : AffineSubspace k P₁}
    {F : AffineSubspace k P₂} (hEF : E.map φ ≤ F) : E.direction ≤ F.direction.comap φ.linear :=
  by
  rw [← Submodule.map_le_iff_le_comap, ← AffineSubspace.map_direction]
  exact AffineSubspace.direction_le hEF
#align affine_map.restrict.linear_aux AffineMap.restrict.linear_aux
-/

#print AffineMap.restrict.linear /-
theorem AffineMap.restrict.linear (φ : P₁ →ᵃ[k] P₂) {E : AffineSubspace k P₁}
    {F : AffineSubspace k P₂} [Nonempty E] [Nonempty F] (hEF : E.map φ ≤ F) :
    (φ.restrict hEF).linear = φ.linear.restrict (AffineMap.restrict.linear_aux hEF) :=
  rfl
#align affine_map.restrict.linear AffineMap.restrict.linear
-/

#print AffineMap.restrict.injective /-
theorem AffineMap.restrict.injective {φ : P₁ →ᵃ[k] P₂} (hφ : Function.Injective φ)
    {E : AffineSubspace k P₁} {F : AffineSubspace k P₂} [Nonempty E] [Nonempty F]
    (hEF : E.map φ ≤ F) : Function.Injective (AffineMap.restrict φ hEF) :=
  by
  intro x y h
  simp only [Subtype.ext_iff, Subtype.coe_mk, AffineMap.restrict.coe_apply] at h ⊢
  exact hφ h
#align affine_map.restrict.injective AffineMap.restrict.injective
-/

#print AffineMap.restrict.surjective /-
theorem AffineMap.restrict.surjective (φ : P₁ →ᵃ[k] P₂) {E : AffineSubspace k P₁}
    {F : AffineSubspace k P₂} [Nonempty E] [Nonempty F] (h : E.map φ = F) :
    Function.Surjective (AffineMap.restrict φ (le_of_eq h)) :=
  by
  rintro ⟨x, hx : x ∈ F⟩
  rw [← h, AffineSubspace.mem_map] at hx 
  obtain ⟨y, hy, rfl⟩ := hx
  exact ⟨⟨y, hy⟩, rfl⟩
#align affine_map.restrict.surjective AffineMap.restrict.surjective
-/

#print AffineMap.restrict.bijective /-
theorem AffineMap.restrict.bijective {E : AffineSubspace k P₁} [Nonempty E] {φ : P₁ →ᵃ[k] P₂}
    (hφ : Function.Injective φ) : Function.Bijective (φ.restrict (le_refl (E.map φ))) :=
  ⟨AffineMap.restrict.injective hφ _, AffineMap.restrict.surjective _ rfl⟩
#align affine_map.restrict.bijective AffineMap.restrict.bijective
-/

