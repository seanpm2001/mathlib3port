/-
Copyright (c) 2020 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes

! This file was ported from Lean 3 source module group_theory.semidirect_product
! leanprover-community/mathlib commit 68d1483e8a718ec63219f0e227ca3f0140361086
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.Aut
import Mathbin.Logic.Function.Basic
import Mathbin.GroupTheory.Subgroup.Basic

/-!
# Semidirect product

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines semidirect products of groups, and the canonical maps in and out of the
semidirect product. The semidirect product of `N` and `G` given a hom `φ` from
`G` to the automorphism group of `N` is the product of sets with the group
`⟨n₁, g₁⟩ * ⟨n₂, g₂⟩ = ⟨n₁ * φ g₁ n₂, g₁ * g₂⟩`

## Key definitions

There are two homs into the semidirect product `inl : N →* N ⋊[φ] G` and
`inr : G →* N ⋊[φ] G`, and `lift` can be used to define maps `N ⋊[φ] G →* H`
out of the semidirect product given maps `f₁ : N →* H` and `f₂ : G →* H` that satisfy the
condition `∀ n g, f₁ (φ g n) = f₂ g * f₁ n * f₂ g⁻¹`

## Notation

This file introduces the global notation `N ⋊[φ] G` for `semidirect_product N G φ`

## Tags
group, semidirect product
-/


variable (N : Type _) (G : Type _) {H : Type _} [Group N] [Group G] [Group H]

#print SemidirectProduct /-
/-- The semidirect product of groups `N` and `G`, given a map `φ` from `G` to the automorphism
  group of `N`. It the product of sets with the group operation
  `⟨n₁, g₁⟩ * ⟨n₂, g₂⟩ = ⟨n₁ * φ g₁ n₂, g₁ * g₂⟩` -/
@[ext]
structure SemidirectProduct (φ : G →* MulAut N) where
  left : N
  right : G
  deriving DecidableEq
#align semidirect_product SemidirectProduct
-/

attribute [pp_using_anonymous_constructor] SemidirectProduct

notation:35 N " ⋊[" φ:35 "] " G:35 => SemidirectProduct N G φ

namespace SemidirectProduct

variable {N G} {φ : G →* MulAut N}

instance : Group (N ⋊[φ] G) where
  one := ⟨1, 1⟩
  mul a b := ⟨a.1 * φ a.2 b.1, a.2 * b.2⟩
  inv x := ⟨φ x.2⁻¹ x.1⁻¹, x.2⁻¹⟩
  mul_assoc a b c := by ext <;> simp [mul_assoc]
  one_mul a := ext _ _ (by simp) (one_mul a.2)
  mul_one a := ext _ _ (by simp) (mul_one _)
  mul_left_inv := fun ⟨a, b⟩ => ext _ _ (show φ b⁻¹ a⁻¹ * φ b⁻¹ a = 1 by simp) (mul_left_inv b)

instance : Inhabited (N ⋊[φ] G) :=
  ⟨1⟩

#print SemidirectProduct.one_left /-
@[simp]
theorem one_left : (1 : N ⋊[φ] G).left = 1 :=
  rfl
#align semidirect_product.one_left SemidirectProduct.one_left
-/

#print SemidirectProduct.one_right /-
@[simp]
theorem one_right : (1 : N ⋊[φ] G).right = 1 :=
  rfl
#align semidirect_product.one_right SemidirectProduct.one_right
-/

#print SemidirectProduct.inv_left /-
@[simp]
theorem inv_left (a : N ⋊[φ] G) : a⁻¹.left = φ a.right⁻¹ a.left⁻¹ :=
  rfl
#align semidirect_product.inv_left SemidirectProduct.inv_left
-/

#print SemidirectProduct.inv_right /-
@[simp]
theorem inv_right (a : N ⋊[φ] G) : a⁻¹.right = a.right⁻¹ :=
  rfl
#align semidirect_product.inv_right SemidirectProduct.inv_right
-/

#print SemidirectProduct.mul_left /-
@[simp]
theorem mul_left (a b : N ⋊[φ] G) : (a * b).left = a.left * φ a.right b.left :=
  rfl
#align semidirect_product.mul_left SemidirectProduct.mul_left
-/

#print SemidirectProduct.mul_right /-
@[simp]
theorem mul_right (a b : N ⋊[φ] G) : (a * b).right = a.right * b.right :=
  rfl
#align semidirect_product.mul_right SemidirectProduct.mul_right
-/

#print SemidirectProduct.inl /-
/-- The canonical map `N →* N ⋊[φ] G` sending `n` to `⟨n, 1⟩` -/
def inl : N →* N ⋊[φ] G where
  toFun n := ⟨n, 1⟩
  map_one' := rfl
  map_mul' := by intros <;> ext <;> simp
#align semidirect_product.inl SemidirectProduct.inl
-/

#print SemidirectProduct.left_inl /-
@[simp]
theorem left_inl (n : N) : (inl n : N ⋊[φ] G).left = n :=
  rfl
#align semidirect_product.left_inl SemidirectProduct.left_inl
-/

#print SemidirectProduct.right_inl /-
@[simp]
theorem right_inl (n : N) : (inl n : N ⋊[φ] G).right = 1 :=
  rfl
#align semidirect_product.right_inl SemidirectProduct.right_inl
-/

#print SemidirectProduct.inl_injective /-
theorem inl_injective : Function.Injective (inl : N → N ⋊[φ] G) :=
  Function.injective_iff_hasLeftInverse.2 ⟨left, left_inl⟩
#align semidirect_product.inl_injective SemidirectProduct.inl_injective
-/

#print SemidirectProduct.inl_inj /-
@[simp]
theorem inl_inj {n₁ n₂ : N} : (inl n₁ : N ⋊[φ] G) = inl n₂ ↔ n₁ = n₂ :=
  inl_injective.eq_iff
#align semidirect_product.inl_inj SemidirectProduct.inl_inj
-/

#print SemidirectProduct.inr /-
/-- The canonical map `G →* N ⋊[φ] G` sending `g` to `⟨1, g⟩` -/
def inr : G →* N ⋊[φ] G where
  toFun g := ⟨1, g⟩
  map_one' := rfl
  map_mul' := by intros <;> ext <;> simp
#align semidirect_product.inr SemidirectProduct.inr
-/

#print SemidirectProduct.left_inr /-
@[simp]
theorem left_inr (g : G) : (inr g : N ⋊[φ] G).left = 1 :=
  rfl
#align semidirect_product.left_inr SemidirectProduct.left_inr
-/

#print SemidirectProduct.right_inr /-
@[simp]
theorem right_inr (g : G) : (inr g : N ⋊[φ] G).right = g :=
  rfl
#align semidirect_product.right_inr SemidirectProduct.right_inr
-/

#print SemidirectProduct.inr_injective /-
theorem inr_injective : Function.Injective (inr : G → N ⋊[φ] G) :=
  Function.injective_iff_hasLeftInverse.2 ⟨right, right_inr⟩
#align semidirect_product.inr_injective SemidirectProduct.inr_injective
-/

#print SemidirectProduct.inr_inj /-
@[simp]
theorem inr_inj {g₁ g₂ : G} : (inr g₁ : N ⋊[φ] G) = inr g₂ ↔ g₁ = g₂ :=
  inr_injective.eq_iff
#align semidirect_product.inr_inj SemidirectProduct.inr_inj
-/

#print SemidirectProduct.inl_aut /-
theorem inl_aut (g : G) (n : N) : (inl (φ g n) : N ⋊[φ] G) = inr g * inl n * inr g⁻¹ := by
  ext <;> simp
#align semidirect_product.inl_aut SemidirectProduct.inl_aut
-/

#print SemidirectProduct.inl_aut_inv /-
theorem inl_aut_inv (g : G) (n : N) : (inl ((φ g)⁻¹ n) : N ⋊[φ] G) = inr g⁻¹ * inl n * inr g := by
  rw [← MonoidHom.map_inv, inl_aut, inv_inv]
#align semidirect_product.inl_aut_inv SemidirectProduct.inl_aut_inv
-/

#print SemidirectProduct.mk_eq_inl_mul_inr /-
@[simp]
theorem mk_eq_inl_mul_inr (g : G) (n : N) : (⟨n, g⟩ : N ⋊[φ] G) = inl n * inr g := by ext <;> simp
#align semidirect_product.mk_eq_inl_mul_inr SemidirectProduct.mk_eq_inl_mul_inr
-/

#print SemidirectProduct.inl_left_mul_inr_right /-
@[simp]
theorem inl_left_mul_inr_right (x : N ⋊[φ] G) : inl x.left * inr x.right = x := by ext <;> simp
#align semidirect_product.inl_left_mul_inr_right SemidirectProduct.inl_left_mul_inr_right
-/

#print SemidirectProduct.rightHom /-
/-- The canonical projection map `N ⋊[φ] G →* G`, as a group hom. -/
def rightHom : N ⋊[φ] G →* G where
  toFun := SemidirectProduct.right
  map_one' := rfl
  map_mul' _ _ := rfl
#align semidirect_product.right_hom SemidirectProduct.rightHom
-/

#print SemidirectProduct.rightHom_eq_right /-
@[simp]
theorem rightHom_eq_right : (rightHom : N ⋊[φ] G → G) = right :=
  rfl
#align semidirect_product.right_hom_eq_right SemidirectProduct.rightHom_eq_right
-/

#print SemidirectProduct.rightHom_comp_inl /-
@[simp]
theorem rightHom_comp_inl : (rightHom : N ⋊[φ] G →* G).comp inl = 1 := by ext <;> simp [right_hom]
#align semidirect_product.right_hom_comp_inl SemidirectProduct.rightHom_comp_inl
-/

#print SemidirectProduct.rightHom_comp_inr /-
@[simp]
theorem rightHom_comp_inr : (rightHom : N ⋊[φ] G →* G).comp inr = MonoidHom.id _ := by
  ext <;> simp [right_hom]
#align semidirect_product.right_hom_comp_inr SemidirectProduct.rightHom_comp_inr
-/

#print SemidirectProduct.rightHom_inl /-
@[simp]
theorem rightHom_inl (n : N) : rightHom (inl n : N ⋊[φ] G) = 1 := by simp [right_hom]
#align semidirect_product.right_hom_inl SemidirectProduct.rightHom_inl
-/

#print SemidirectProduct.rightHom_inr /-
@[simp]
theorem rightHom_inr (g : G) : rightHom (inr g : N ⋊[φ] G) = g := by simp [right_hom]
#align semidirect_product.right_hom_inr SemidirectProduct.rightHom_inr
-/

#print SemidirectProduct.rightHom_surjective /-
theorem rightHom_surjective : Function.Surjective (rightHom : N ⋊[φ] G → G) :=
  Function.surjective_iff_hasRightInverse.2 ⟨inr, rightHom_inr⟩
#align semidirect_product.right_hom_surjective SemidirectProduct.rightHom_surjective
-/

#print SemidirectProduct.range_inl_eq_ker_rightHom /-
theorem range_inl_eq_ker_rightHom : (inl : N →* N ⋊[φ] G).range = rightHom.ker :=
  le_antisymm (fun _ => by simp (config := { contextual := true }) [MonoidHom.mem_ker, eq_comm])
    fun x hx => ⟨x.left, by ext <;> simp_all [MonoidHom.mem_ker]⟩
#align semidirect_product.range_inl_eq_ker_right_hom SemidirectProduct.range_inl_eq_ker_rightHom
-/

section lift

variable (f₁ : N →* H) (f₂ : G →* H)
  (h : ∀ g, f₁.comp (φ g).toMonoidHom = (MulAut.conj (f₂ g)).toMonoidHom.comp f₁)

#print SemidirectProduct.lift /-
/-- Define a group hom `N ⋊[φ] G →* H`, by defining maps `N →* H` and `G →* H`  -/
def lift (f₁ : N →* H) (f₂ : G →* H)
    (h : ∀ g, f₁.comp (φ g).toMonoidHom = (MulAut.conj (f₂ g)).toMonoidHom.comp f₁) : N ⋊[φ] G →* H
    where
  toFun a := f₁ a.1 * f₂ a.2
  map_one' := by simp
  map_mul' a b := by
    have := fun n g => MonoidHom.ext_iff.1 (h n) g
    simp only [MulAut.conj_apply, MonoidHom.comp_apply, MulEquiv.coe_toMonoidHom] at this 
    simp [this, mul_assoc]
#align semidirect_product.lift SemidirectProduct.lift
-/

#print SemidirectProduct.lift_inl /-
@[simp]
theorem lift_inl (n : N) : lift f₁ f₂ h (inl n) = f₁ n := by simp [lift]
#align semidirect_product.lift_inl SemidirectProduct.lift_inl
-/

#print SemidirectProduct.lift_comp_inl /-
@[simp]
theorem lift_comp_inl : (lift f₁ f₂ h).comp inl = f₁ := by ext <;> simp
#align semidirect_product.lift_comp_inl SemidirectProduct.lift_comp_inl
-/

#print SemidirectProduct.lift_inr /-
@[simp]
theorem lift_inr (g : G) : lift f₁ f₂ h (inr g) = f₂ g := by simp [lift]
#align semidirect_product.lift_inr SemidirectProduct.lift_inr
-/

#print SemidirectProduct.lift_comp_inr /-
@[simp]
theorem lift_comp_inr : (lift f₁ f₂ h).comp inr = f₂ := by ext <;> simp
#align semidirect_product.lift_comp_inr SemidirectProduct.lift_comp_inr
-/

#print SemidirectProduct.lift_unique /-
theorem lift_unique (F : N ⋊[φ] G →* H) :
    F = lift (F.comp inl) (F.comp inr) fun _ => by ext <;> simp [inl_aut] :=
  by
  ext
  simp only [lift, MonoidHom.comp_apply, MonoidHom.coe_mk]
  rw [← F.map_mul, inl_left_mul_inr_right]
#align semidirect_product.lift_unique SemidirectProduct.lift_unique
-/

#print SemidirectProduct.hom_ext /-
/-- Two maps out of the semidirect product are equal if they're equal after composition
  with both `inl` and `inr` -/
theorem hom_ext {f g : N ⋊[φ] G →* H} (hl : f.comp inl = g.comp inl)
    (hr : f.comp inr = g.comp inr) : f = g := by rw [lift_unique f, lift_unique g]; simp only [*]
#align semidirect_product.hom_ext SemidirectProduct.hom_ext
-/

end lift

section Map

variable {N₁ : Type _} {G₁ : Type _} [Group N₁] [Group G₁] {φ₁ : G₁ →* MulAut N₁}

#print SemidirectProduct.map /-
/-- Define a map from `N ⋊[φ] G` to `N₁ ⋊[φ₁] G₁` given maps `N →* N₁` and `G →* G₁` that
  satisfy a commutativity condition `∀ n g, f₁ (φ g n) = φ₁ (f₂ g) (f₁ n)`.  -/
def map (f₁ : N →* N₁) (f₂ : G →* G₁)
    (h : ∀ g : G, f₁.comp (φ g).toMonoidHom = (φ₁ (f₂ g)).toMonoidHom.comp f₁) :
    N ⋊[φ] G →* N₁ ⋊[φ₁] G₁ where
  toFun x := ⟨f₁ x.1, f₂ x.2⟩
  map_one' := by simp
  map_mul' x y := by
    replace h := MonoidHom.ext_iff.1 (h x.right) y.left
    ext <;> simp_all
#align semidirect_product.map SemidirectProduct.map
-/

variable (f₁ : N →* N₁) (f₂ : G →* G₁)
  (h : ∀ g : G, f₁.comp (φ g).toMonoidHom = (φ₁ (f₂ g)).toMonoidHom.comp f₁)

#print SemidirectProduct.map_left /-
@[simp]
theorem map_left (g : N ⋊[φ] G) : (map f₁ f₂ h g).left = f₁ g.left :=
  rfl
#align semidirect_product.map_left SemidirectProduct.map_left
-/

#print SemidirectProduct.map_right /-
@[simp]
theorem map_right (g : N ⋊[φ] G) : (map f₁ f₂ h g).right = f₂ g.right :=
  rfl
#align semidirect_product.map_right SemidirectProduct.map_right
-/

#print SemidirectProduct.rightHom_comp_map /-
@[simp]
theorem rightHom_comp_map : rightHom.comp (map f₁ f₂ h) = f₂.comp rightHom :=
  rfl
#align semidirect_product.right_hom_comp_map SemidirectProduct.rightHom_comp_map
-/

#print SemidirectProduct.map_inl /-
@[simp]
theorem map_inl (n : N) : map f₁ f₂ h (inl n) = inl (f₁ n) := by simp [map]
#align semidirect_product.map_inl SemidirectProduct.map_inl
-/

#print SemidirectProduct.map_comp_inl /-
@[simp]
theorem map_comp_inl : (map f₁ f₂ h).comp inl = inl.comp f₁ := by ext <;> simp
#align semidirect_product.map_comp_inl SemidirectProduct.map_comp_inl
-/

#print SemidirectProduct.map_inr /-
@[simp]
theorem map_inr (g : G) : map f₁ f₂ h (inr g) = inr (f₂ g) := by simp [map]
#align semidirect_product.map_inr SemidirectProduct.map_inr
-/

#print SemidirectProduct.map_comp_inr /-
@[simp]
theorem map_comp_inr : (map f₁ f₂ h).comp inr = inr.comp f₂ := by ext <;> simp [map]
#align semidirect_product.map_comp_inr SemidirectProduct.map_comp_inr
-/

end Map

end SemidirectProduct

