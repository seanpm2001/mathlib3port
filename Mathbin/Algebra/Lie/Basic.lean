/-
Copyright (c) 2019 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.basic
! leanprover-community/mathlib commit ee05e9ce1322178f0c12004eb93c00d2c8c00ed2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Equiv
import Mathbin.Data.Bracket
import Mathbin.LinearAlgebra.Basic
import Mathbin.Tactic.NoncommRing

/-!
# Lie algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines Lie rings and Lie algebras over a commutative ring together with their
modules, morphisms and equivalences, as well as various lemmas to make these definitions usable.

## Main definitions

  * `lie_ring`
  * `lie_algebra`
  * `lie_ring_module`
  * `lie_module`
  * `lie_hom`
  * `lie_equiv`
  * `lie_module_hom`
  * `lie_module_equiv`

## Notation

Working over a fixed commutative ring `R`, we introduce the notations:
 * `L →ₗ⁅R⁆ L'` for a morphism of Lie algebras,
 * `L ≃ₗ⁅R⁆ L'` for an equivalence of Lie algebras,
 * `M →ₗ⁅R,L⁆ N` for a morphism of Lie algebra modules `M`, `N` over a Lie algebra `L`,
 * `M ≃ₗ⁅R,L⁆ N` for an equivalence of Lie algebra modules `M`, `N` over a Lie algebra `L`.

## Implementation notes

Lie algebras are defined as modules with a compatible Lie ring structure and thus, like modules,
are partially unbundled.

## References
* [N. Bourbaki, *Lie Groups and Lie Algebras, Chapters 1--3*](bourbaki1975)

## Tags

lie bracket, jacobi identity, lie ring, lie algebra, lie module
-/


universe u v w w₁ w₂

open Function

#print LieRing /-
/-- A Lie ring is an additive group with compatible product, known as the bracket, satisfying the
Jacobi identity. -/
@[protect_proj]
class LieRing (L : Type v) extends AddCommGroup L, Bracket L L where
  add_lie : ∀ x y z : L, ⁅x + y, z⁆ = ⁅x, z⁆ + ⁅y, z⁆
  lie_add : ∀ x y z : L, ⁅x, y + z⁆ = ⁅x, y⁆ + ⁅x, z⁆
  lie_self : ∀ x : L, ⁅x, x⁆ = 0
  leibniz_lie : ∀ x y z : L, ⁅x, ⁅y, z⁆⁆ = ⁅⁅x, y⁆, z⁆ + ⁅y, ⁅x, z⁆⁆
#align lie_ring LieRing
-/

#print LieAlgebra /-
/-- A Lie algebra is a module with compatible product, known as the bracket, satisfying the Jacobi
identity. Forgetting the scalar multiplication, every Lie algebra is a Lie ring. -/
@[protect_proj]
class LieAlgebra (R : Type u) (L : Type v) [CommRing R] [LieRing L] extends Module R L where
  lie_smul : ∀ (t : R) (x y : L), ⁅x, t • y⁆ = t • ⁅x, y⁆
#align lie_algebra LieAlgebra
-/

#print LieRingModule /-
/-- A Lie ring module is an additive group, together with an additive action of a
Lie ring on this group, such that the Lie bracket acts as the commutator of endomorphisms.
(For representations of Lie *algebras* see `lie_module`.) -/
@[protect_proj]
class LieRingModule (L : Type v) (M : Type w) [LieRing L] [AddCommGroup M] extends Bracket L M where
  add_lie : ∀ (x y : L) (m : M), ⁅x + y, m⁆ = ⁅x, m⁆ + ⁅y, m⁆
  lie_add : ∀ (x : L) (m n : M), ⁅x, m + n⁆ = ⁅x, m⁆ + ⁅x, n⁆
  leibniz_lie : ∀ (x y : L) (m : M), ⁅x, ⁅y, m⁆⁆ = ⁅⁅x, y⁆, m⁆ + ⁅y, ⁅x, m⁆⁆
#align lie_ring_module LieRingModule
-/

#print LieModule /-
/-- A Lie module is a module over a commutative ring, together with a linear action of a Lie
algebra on this module, such that the Lie bracket acts as the commutator of endomorphisms. -/
@[protect_proj]
class LieModule (R : Type u) (L : Type v) (M : Type w) [CommRing R] [LieRing L] [LieAlgebra R L]
    [AddCommGroup M] [Module R M] [LieRingModule L M] where
  smul_lie : ∀ (t : R) (x : L) (m : M), ⁅t • x, m⁆ = t • ⁅x, m⁆
  lie_smul : ∀ (t : R) (x : L) (m : M), ⁅x, t • m⁆ = t • ⁅x, m⁆
#align lie_module LieModule
-/

section BasicProperties

variable {R : Type u} {L : Type v} {M : Type w} {N : Type w₁}

variable [CommRing R] [LieRing L] [LieAlgebra R L]

variable [AddCommGroup M] [Module R M] [LieRingModule L M] [LieModule R L M]

variable [AddCommGroup N] [Module R N] [LieRingModule L N] [LieModule R L N]

variable (t : R) (x y z : L) (m n : M)

#print add_lie /-
@[simp]
theorem add_lie : ⁅x + y, m⁆ = ⁅x, m⁆ + ⁅y, m⁆ :=
  LieRingModule.add_lie x y m
#align add_lie add_lie
-/

#print lie_add /-
@[simp]
theorem lie_add : ⁅x, m + n⁆ = ⁅x, m⁆ + ⁅x, n⁆ :=
  LieRingModule.lie_add x m n
#align lie_add lie_add
-/

#print smul_lie /-
@[simp]
theorem smul_lie : ⁅t • x, m⁆ = t • ⁅x, m⁆ :=
  LieModule.smul_lie t x m
#align smul_lie smul_lie
-/

#print lie_smul /-
@[simp]
theorem lie_smul : ⁅x, t • m⁆ = t • ⁅x, m⁆ :=
  LieModule.lie_smul t x m
#align lie_smul lie_smul
-/

#print leibniz_lie /-
theorem leibniz_lie : ⁅x, ⁅y, m⁆⁆ = ⁅⁅x, y⁆, m⁆ + ⁅y, ⁅x, m⁆⁆ :=
  LieRingModule.leibniz_lie x y m
#align leibniz_lie leibniz_lie
-/

#print lie_zero /-
@[simp]
theorem lie_zero : ⁅x, 0⁆ = (0 : M) :=
  (AddMonoidHom.mk' _ (lie_add x)).map_zero
#align lie_zero lie_zero
-/

#print zero_lie /-
@[simp]
theorem zero_lie : ⁅(0 : L), m⁆ = 0 :=
  (AddMonoidHom.mk' (fun x : L => ⁅x, m⁆) fun x y => add_lie x y m).map_zero
#align zero_lie zero_lie
-/

#print lie_self /-
@[simp]
theorem lie_self : ⁅x, x⁆ = 0 :=
  LieRing.lie_self x
#align lie_self lie_self
-/

#print lieRingSelfModule /-
instance lieRingSelfModule : LieRingModule L L :=
  { (inferInstance : LieRing L) with }
#align lie_ring_self_module lieRingSelfModule
-/

#print lie_skew /-
@[simp]
theorem lie_skew : -⁅y, x⁆ = ⁅x, y⁆ :=
  by
  have h : ⁅x + y, x⁆ + ⁅x + y, y⁆ = 0 := by rw [← lie_add]; apply lie_self
  simpa [neg_eq_iff_add_eq_zero] using h
#align lie_skew lie_skew
-/

#print lieAlgebraSelfModule /-
/-- Every Lie algebra is a module over itself. -/
instance lieAlgebraSelfModule : LieModule R L L
    where
  smul_lie t x m := by rw [← lie_skew, ← lie_skew x m, LieAlgebra.lie_smul, smul_neg]
  lie_smul := by apply LieAlgebra.lie_smul
#align lie_algebra_self_module lieAlgebraSelfModule
-/

#print neg_lie /-
@[simp]
theorem neg_lie : ⁅-x, m⁆ = -⁅x, m⁆ := by rw [← sub_eq_zero, sub_neg_eq_add, ← add_lie]; simp
#align neg_lie neg_lie
-/

#print lie_neg /-
@[simp]
theorem lie_neg : ⁅x, -m⁆ = -⁅x, m⁆ := by rw [← sub_eq_zero, sub_neg_eq_add, ← lie_add]; simp
#align lie_neg lie_neg
-/

#print sub_lie /-
@[simp]
theorem sub_lie : ⁅x - y, m⁆ = ⁅x, m⁆ - ⁅y, m⁆ := by simp [sub_eq_add_neg]
#align sub_lie sub_lie
-/

#print lie_sub /-
@[simp]
theorem lie_sub : ⁅x, m - n⁆ = ⁅x, m⁆ - ⁅x, n⁆ := by simp [sub_eq_add_neg]
#align lie_sub lie_sub
-/

#print nsmul_lie /-
@[simp]
theorem nsmul_lie (n : ℕ) : ⁅n • x, m⁆ = n • ⁅x, m⁆ :=
  AddMonoidHom.map_nsmul ⟨fun x : L => ⁅x, m⁆, zero_lie m, fun _ _ => add_lie _ _ _⟩ _ _
#align nsmul_lie nsmul_lie
-/

#print lie_nsmul /-
@[simp]
theorem lie_nsmul (n : ℕ) : ⁅x, n • m⁆ = n • ⁅x, m⁆ :=
  AddMonoidHom.map_nsmul ⟨fun m : M => ⁅x, m⁆, lie_zero x, fun _ _ => lie_add _ _ _⟩ _ _
#align lie_nsmul lie_nsmul
-/

#print zsmul_lie /-
@[simp]
theorem zsmul_lie (a : ℤ) : ⁅a • x, m⁆ = a • ⁅x, m⁆ :=
  AddMonoidHom.map_zsmul ⟨fun x : L => ⁅x, m⁆, zero_lie m, fun _ _ => add_lie _ _ _⟩ _ _
#align zsmul_lie zsmul_lie
-/

#print lie_zsmul /-
@[simp]
theorem lie_zsmul (a : ℤ) : ⁅x, a • m⁆ = a • ⁅x, m⁆ :=
  AddMonoidHom.map_zsmul ⟨fun m : M => ⁅x, m⁆, lie_zero x, fun _ _ => lie_add _ _ _⟩ _ _
#align lie_zsmul lie_zsmul
-/

#print lie_lie /-
@[simp]
theorem lie_lie : ⁅⁅x, y⁆, m⁆ = ⁅x, ⁅y, m⁆⁆ - ⁅y, ⁅x, m⁆⁆ := by rw [leibniz_lie, add_sub_cancel]
#align lie_lie lie_lie
-/

#print lie_jacobi /-
theorem lie_jacobi : ⁅x, ⁅y, z⁆⁆ + ⁅y, ⁅z, x⁆⁆ + ⁅z, ⁅x, y⁆⁆ = 0 := by
  rw [← neg_neg ⁅x, y⁆, lie_neg z, lie_skew y x, ← lie_skew, lie_lie]; abel
#align lie_jacobi lie_jacobi
-/

#print LieRing.intLieAlgebra /-
instance LieRing.intLieAlgebra : LieAlgebra ℤ L where lie_smul n x y := lie_zsmul x y n
#align lie_ring.int_lie_algebra LieRing.intLieAlgebra
-/

instance : LieRingModule L (M →ₗ[R] N)
    where
  bracket x f :=
    { toFun := fun m => ⁅x, f m⁆ - f ⁅x, m⁆
      map_add' := fun m n => by simp only [lie_add, LinearMap.map_add]; abel
      map_smul' := fun t m => by
        simp only [smul_sub, LinearMap.map_smul, lie_smul, RingHom.id_apply] }
  add_lie x y f := by
    ext n; simp only [add_lie, LinearMap.coe_mk, LinearMap.add_apply, LinearMap.map_add]
    abel
  lie_add x f g := by ext n; simp only [LinearMap.coe_mk, lie_add, LinearMap.add_apply]; abel
  leibniz_lie x y f := by
    ext n
    simp only [lie_lie, LinearMap.coe_mk, LinearMap.map_sub, LinearMap.add_apply, lie_sub]
    abel

#print LieHom.lie_apply /-
@[simp]
theorem LieHom.lie_apply (f : M →ₗ[R] N) (x : L) (m : M) : ⁅x, f⁆ m = ⁅x, f m⁆ - f ⁅x, m⁆ :=
  rfl
#align lie_hom.lie_apply LieHom.lie_apply
-/

instance : LieModule R L (M →ₗ[R] N)
    where
  smul_lie t x f := by
    ext n
    simp only [smul_sub, smul_lie, LinearMap.smul_apply, LieHom.lie_apply, LinearMap.map_smul]
  lie_smul t x f := by ext n; simp only [smul_sub, LinearMap.smul_apply, LieHom.lie_apply, lie_smul]

end BasicProperties

#print LieHom /-
/-- A morphism of Lie algebras is a linear map respecting the bracket operations. -/
structure LieHom (R : Type u) (L : Type v) (L' : Type w) [CommRing R] [LieRing L] [LieAlgebra R L]
    [LieRing L'] [LieAlgebra R L'] extends L →ₗ[R] L' where
  map_lie' : ∀ {x y : L}, to_fun ⁅x, y⁆ = ⁅to_fun x, to_fun y⁆
#align lie_hom LieHom
-/

attribute [nolint doc_blame] LieHom.toLinearMap

notation:25 L " →ₗ⁅" R:25 "⁆ " L':0 => LieHom R L L'

namespace LieHom

variable {R : Type u} {L₁ : Type v} {L₂ : Type w} {L₃ : Type w₁}

variable [CommRing R]

variable [LieRing L₁] [LieAlgebra R L₁]

variable [LieRing L₂] [LieAlgebra R L₂]

variable [LieRing L₃] [LieAlgebra R L₃]

instance : Coe (L₁ →ₗ⁅R⁆ L₂) (L₁ →ₗ[R] L₂) :=
  ⟨LieHom.toLinearMap⟩

/-- see Note [function coercion] -/
instance : CoeFun (L₁ →ₗ⁅R⁆ L₂) fun _ => L₁ → L₂ :=
  ⟨fun f => f.toLinearMap.toFun⟩

/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def Simps.apply (h : L₁ →ₗ⁅R⁆ L₂) : L₁ → L₂ :=
  h
#align lie_hom.simps.apply LieHom.Simps.apply

initialize_simps_projections LieHom (to_linear_map_to_fun → apply)

#print LieHom.coe_toLinearMap /-
@[simp, norm_cast]
theorem coe_toLinearMap (f : L₁ →ₗ⁅R⁆ L₂) : ((f : L₁ →ₗ[R] L₂) : L₁ → L₂) = f :=
  rfl
#align lie_hom.coe_to_linear_map LieHom.coe_toLinearMap
-/

#print LieHom.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe (f : L₁ →ₗ⁅R⁆ L₂) : f.toFun = ⇑f :=
  rfl
#align lie_hom.to_fun_eq_coe LieHom.toFun_eq_coe
-/

#print LieHom.map_smul /-
@[simp]
theorem map_smul (f : L₁ →ₗ⁅R⁆ L₂) (c : R) (x : L₁) : f (c • x) = c • f x :=
  LinearMap.map_smul (f : L₁ →ₗ[R] L₂) c x
#align lie_hom.map_smul LieHom.map_smul
-/

#print LieHom.map_add /-
@[simp]
theorem map_add (f : L₁ →ₗ⁅R⁆ L₂) (x y : L₁) : f (x + y) = f x + f y :=
  LinearMap.map_add (f : L₁ →ₗ[R] L₂) x y
#align lie_hom.map_add LieHom.map_add
-/

#print LieHom.map_sub /-
@[simp]
theorem map_sub (f : L₁ →ₗ⁅R⁆ L₂) (x y : L₁) : f (x - y) = f x - f y :=
  LinearMap.map_sub (f : L₁ →ₗ[R] L₂) x y
#align lie_hom.map_sub LieHom.map_sub
-/

#print LieHom.map_neg /-
@[simp]
theorem map_neg (f : L₁ →ₗ⁅R⁆ L₂) (x : L₁) : f (-x) = -f x :=
  LinearMap.map_neg (f : L₁ →ₗ[R] L₂) x
#align lie_hom.map_neg LieHom.map_neg
-/

#print LieHom.map_lie /-
@[simp]
theorem map_lie (f : L₁ →ₗ⁅R⁆ L₂) (x y : L₁) : f ⁅x, y⁆ = ⁅f x, f y⁆ :=
  LieHom.map_lie' f
#align lie_hom.map_lie LieHom.map_lie
-/

#print LieHom.map_zero /-
@[simp]
theorem map_zero (f : L₁ →ₗ⁅R⁆ L₂) : f 0 = 0 :=
  (f : L₁ →ₗ[R] L₂).map_zero
#align lie_hom.map_zero LieHom.map_zero
-/

#print LieHom.id /-
/-- The identity map is a morphism of Lie algebras. -/
def id : L₁ →ₗ⁅R⁆ L₁ :=
  { (LinearMap.id : L₁ →ₗ[R] L₁) with map_lie' := fun x y => rfl }
#align lie_hom.id LieHom.id
-/

#print LieHom.coe_id /-
@[simp]
theorem coe_id : ((id : L₁ →ₗ⁅R⁆ L₁) : L₁ → L₁) = id :=
  rfl
#align lie_hom.coe_id LieHom.coe_id
-/

#print LieHom.id_apply /-
theorem id_apply (x : L₁) : (id : L₁ →ₗ⁅R⁆ L₁) x = x :=
  rfl
#align lie_hom.id_apply LieHom.id_apply
-/

/-- The constant 0 map is a Lie algebra morphism. -/
instance : Zero (L₁ →ₗ⁅R⁆ L₂) :=
  ⟨{ (0 : L₁ →ₗ[R] L₂) with map_lie' := by simp }⟩

#print LieHom.coe_zero /-
@[norm_cast, simp]
theorem coe_zero : ((0 : L₁ →ₗ⁅R⁆ L₂) : L₁ → L₂) = 0 :=
  rfl
#align lie_hom.coe_zero LieHom.coe_zero
-/

#print LieHom.zero_apply /-
theorem zero_apply (x : L₁) : (0 : L₁ →ₗ⁅R⁆ L₂) x = 0 :=
  rfl
#align lie_hom.zero_apply LieHom.zero_apply
-/

/-- The identity map is a Lie algebra morphism. -/
instance : One (L₁ →ₗ⁅R⁆ L₁) :=
  ⟨id⟩

#print LieHom.coe_one /-
@[simp]
theorem coe_one : ((1 : L₁ →ₗ⁅R⁆ L₁) : L₁ → L₁) = id :=
  rfl
#align lie_hom.coe_one LieHom.coe_one
-/

#print LieHom.one_apply /-
theorem one_apply (x : L₁) : (1 : L₁ →ₗ⁅R⁆ L₁) x = x :=
  rfl
#align lie_hom.one_apply LieHom.one_apply
-/

instance : Inhabited (L₁ →ₗ⁅R⁆ L₂) :=
  ⟨0⟩

#print LieHom.coe_injective /-
theorem coe_injective : @Function.Injective (L₁ →ₗ⁅R⁆ L₂) (L₁ → L₂) coeFn := by
  rintro ⟨⟨f, _⟩⟩ ⟨⟨g, _⟩⟩ ⟨h⟩ <;> congr
#align lie_hom.coe_injective LieHom.coe_injective
-/

#print LieHom.ext /-
@[ext]
theorem ext {f g : L₁ →ₗ⁅R⁆ L₂} (h : ∀ x, f x = g x) : f = g :=
  coe_injective <| funext h
#align lie_hom.ext LieHom.ext
-/

#print LieHom.ext_iff /-
theorem ext_iff {f g : L₁ →ₗ⁅R⁆ L₂} : f = g ↔ ∀ x, f x = g x :=
  ⟨by rintro rfl x; rfl, ext⟩
#align lie_hom.ext_iff LieHom.ext_iff
-/

#print LieHom.congr_fun /-
theorem congr_fun {f g : L₁ →ₗ⁅R⁆ L₂} (h : f = g) (x : L₁) : f x = g x :=
  h ▸ rfl
#align lie_hom.congr_fun LieHom.congr_fun
-/

#print LieHom.mk_coe /-
@[simp]
theorem mk_coe (f : L₁ →ₗ⁅R⁆ L₂) (h₁ h₂ h₃) : (⟨⟨f, h₁, h₂⟩, h₃⟩ : L₁ →ₗ⁅R⁆ L₂) = f := by ext; rfl
#align lie_hom.mk_coe LieHom.mk_coe
-/

#print LieHom.coe_mk /-
@[simp]
theorem coe_mk (f : L₁ → L₂) (h₁ h₂ h₃) : ((⟨⟨f, h₁, h₂⟩, h₃⟩ : L₁ →ₗ⁅R⁆ L₂) : L₁ → L₂) = f :=
  rfl
#align lie_hom.coe_mk LieHom.coe_mk
-/

#print LieHom.comp /-
/-- The composition of morphisms is a morphism. -/
def comp (f : L₂ →ₗ⁅R⁆ L₃) (g : L₁ →ₗ⁅R⁆ L₂) : L₁ →ₗ⁅R⁆ L₃ :=
  { LinearMap.comp f.toLinearMap g.toLinearMap with
    map_lie' := fun x y => by change f (g ⁅x, y⁆) = ⁅f (g x), f (g y)⁆; rw [map_lie, map_lie] }
#align lie_hom.comp LieHom.comp
-/

#print LieHom.comp_apply /-
theorem comp_apply (f : L₂ →ₗ⁅R⁆ L₃) (g : L₁ →ₗ⁅R⁆ L₂) (x : L₁) : f.comp g x = f (g x) :=
  rfl
#align lie_hom.comp_apply LieHom.comp_apply
-/

#print LieHom.coe_comp /-
@[norm_cast, simp]
theorem coe_comp (f : L₂ →ₗ⁅R⁆ L₃) (g : L₁ →ₗ⁅R⁆ L₂) : (f.comp g : L₁ → L₃) = f ∘ g :=
  rfl
#align lie_hom.coe_comp LieHom.coe_comp
-/

#print LieHom.coe_linearMap_comp /-
@[norm_cast, simp]
theorem coe_linearMap_comp (f : L₂ →ₗ⁅R⁆ L₃) (g : L₁ →ₗ⁅R⁆ L₂) :
    (f.comp g : L₁ →ₗ[R] L₃) = (f : L₂ →ₗ[R] L₃).comp (g : L₁ →ₗ[R] L₂) :=
  rfl
#align lie_hom.coe_linear_map_comp LieHom.coe_linearMap_comp
-/

#print LieHom.comp_id /-
@[simp]
theorem comp_id (f : L₁ →ₗ⁅R⁆ L₂) : f.comp (id : L₁ →ₗ⁅R⁆ L₁) = f := by ext; rfl
#align lie_hom.comp_id LieHom.comp_id
-/

#print LieHom.id_comp /-
@[simp]
theorem id_comp (f : L₁ →ₗ⁅R⁆ L₂) : (id : L₂ →ₗ⁅R⁆ L₂).comp f = f := by ext; rfl
#align lie_hom.id_comp LieHom.id_comp
-/

#print LieHom.inverse /-
/-- The inverse of a bijective morphism is a morphism. -/
def inverse (f : L₁ →ₗ⁅R⁆ L₂) (g : L₂ → L₁) (h₁ : Function.LeftInverse g f)
    (h₂ : Function.RightInverse g f) : L₂ →ₗ⁅R⁆ L₁ :=
  { LinearMap.inverse f.toLinearMap g h₁ h₂ with
    map_lie' := fun x y =>
      calc
        g ⁅x, y⁆ = g ⁅f (g x), f (g y)⁆ := by conv_lhs => rw [← h₂ x, ← h₂ y]
        _ = g (f ⁅g x, g y⁆) := by rw [map_lie]
        _ = ⁅g x, g y⁆ := h₁ _ }
#align lie_hom.inverse LieHom.inverse
-/

end LieHom

section ModulePullBack

variable {R : Type u} {L₁ : Type v} {L₂ : Type w} (M : Type w₁)

variable [CommRing R] [LieRing L₁] [LieAlgebra R L₁] [LieRing L₂] [LieAlgebra R L₂]

variable [AddCommGroup M] [LieRingModule L₂ M]

variable (f : L₁ →ₗ⁅R⁆ L₂)

#print LieRingModule.compLieHom /-
/-- A Lie ring module may be pulled back along a morphism of Lie algebras.

See note [reducible non-instances]. -/
@[reducible]
def LieRingModule.compLieHom : LieRingModule L₁ M
    where
  bracket x m := ⁅f x, m⁆
  lie_add x := lie_add (f x)
  add_lie x y m := by simp only [LieHom.map_add, add_lie]
  leibniz_lie x y m := by simp only [lie_lie, sub_add_cancel, LieHom.map_lie]
#align lie_ring_module.comp_lie_hom LieRingModule.compLieHom
-/

#print LieRingModule.compLieHom_apply /-
theorem LieRingModule.compLieHom_apply (x : L₁) (m : M) :
    haveI := LieRingModule.compLieHom M f
    ⁅x, m⁆ = ⁅f x, m⁆ :=
  rfl
#align lie_ring_module.comp_lie_hom_apply LieRingModule.compLieHom_apply
-/

#print LieModule.compLieHom /-
/-- A Lie module may be pulled back along a morphism of Lie algebras.

See note [reducible non-instances]. -/
@[reducible]
def LieModule.compLieHom [Module R M] [LieModule R L₂ M] :
    @LieModule R L₁ M _ _ _ _ _ (LieRingModule.compLieHom M f)
    where
  smul_lie t x m := by simp only [smul_lie, LieHom.map_smul]
  lie_smul t x m := by simp only [lie_smul]
#align lie_module.comp_lie_hom LieModule.compLieHom
-/

end ModulePullBack

#print LieEquiv /-
/-- An equivalence of Lie algebras is a morphism which is also a linear equivalence. We could
instead define an equivalence to be a morphism which is also a (plain) equivalence. However it is
more convenient to define via linear equivalence to get `.to_linear_equiv` for free. -/
structure LieEquiv (R : Type u) (L : Type v) (L' : Type w) [CommRing R] [LieRing L] [LieAlgebra R L]
    [LieRing L'] [LieAlgebra R L'] extends L →ₗ⁅R⁆ L' where
  invFun : L' → L
  left_inv : Function.LeftInverse inv_fun to_lie_hom.toFun
  right_inv : Function.RightInverse inv_fun to_lie_hom.toFun
#align lie_equiv LieEquiv
-/

attribute [nolint doc_blame] LieEquiv.toLieHom

notation:50 L " ≃ₗ⁅" R "⁆ " L' => LieEquiv R L L'

namespace LieEquiv

variable {R : Type u} {L₁ : Type v} {L₂ : Type w} {L₃ : Type w₁}

variable [CommRing R] [LieRing L₁] [LieRing L₂] [LieRing L₃]

variable [LieAlgebra R L₁] [LieAlgebra R L₂] [LieAlgebra R L₃]

#print LieEquiv.toLinearEquiv /-
/-- Consider an equivalence of Lie algebras as a linear equivalence. -/
def toLinearEquiv (f : L₁ ≃ₗ⁅R⁆ L₂) : L₁ ≃ₗ[R] L₂ :=
  { f.toLieHom, f with }
#align lie_equiv.to_linear_equiv LieEquiv.toLinearEquiv
-/

#print LieEquiv.hasCoeToLieHom /-
instance hasCoeToLieHom : Coe (L₁ ≃ₗ⁅R⁆ L₂) (L₁ →ₗ⁅R⁆ L₂) :=
  ⟨toLieHom⟩
#align lie_equiv.has_coe_to_lie_hom LieEquiv.hasCoeToLieHom
-/

#print LieEquiv.hasCoeToLinearEquiv /-
instance hasCoeToLinearEquiv : Coe (L₁ ≃ₗ⁅R⁆ L₂) (L₁ ≃ₗ[R] L₂) :=
  ⟨toLinearEquiv⟩
#align lie_equiv.has_coe_to_linear_equiv LieEquiv.hasCoeToLinearEquiv
-/

/-- see Note [function coercion] -/
instance : CoeFun (L₁ ≃ₗ⁅R⁆ L₂) fun _ => L₁ → L₂ :=
  ⟨fun e => e.toLieHom.toFun⟩

#print LieEquiv.coe_to_lieHom /-
@[simp, norm_cast]
theorem coe_to_lieHom (e : L₁ ≃ₗ⁅R⁆ L₂) : ((e : L₁ →ₗ⁅R⁆ L₂) : L₁ → L₂) = e :=
  rfl
#align lie_equiv.coe_to_lie_hom LieEquiv.coe_to_lieHom
-/

#print LieEquiv.coe_to_linearEquiv /-
@[simp, norm_cast]
theorem coe_to_linearEquiv (e : L₁ ≃ₗ⁅R⁆ L₂) : ((e : L₁ ≃ₗ[R] L₂) : L₁ → L₂) = e :=
  rfl
#align lie_equiv.coe_to_linear_equiv LieEquiv.coe_to_linearEquiv
-/

#print LieEquiv.to_linearEquiv_mk /-
@[simp]
theorem to_linearEquiv_mk (f : L₁ →ₗ⁅R⁆ L₂) (g h₁ h₂) :
    (mk f g h₁ h₂ : L₁ ≃ₗ[R] L₂) =
      { f with
        invFun := g
        left_inv := h₁
        right_inv := h₂ } :=
  rfl
#align lie_equiv.to_linear_equiv_mk LieEquiv.to_linearEquiv_mk
-/

#print LieEquiv.coe_linearEquiv_injective /-
theorem coe_linearEquiv_injective : Injective (coe : (L₁ ≃ₗ⁅R⁆ L₂) → L₁ ≃ₗ[R] L₂) :=
  by
  intro f₁ f₂ h; cases f₁; cases f₂; dsimp at h ; simp only at h 
  congr; exacts [LieHom.coe_injective h.1, h.2]
#align lie_equiv.coe_linear_equiv_injective LieEquiv.coe_linearEquiv_injective
-/

#print LieEquiv.coe_injective /-
theorem coe_injective : @Injective (L₁ ≃ₗ⁅R⁆ L₂) (L₁ → L₂) coeFn :=
  LinearEquiv.coe_injective.comp coe_linearEquiv_injective
#align lie_equiv.coe_injective LieEquiv.coe_injective
-/

#print LieEquiv.ext /-
@[ext]
theorem ext {f g : L₁ ≃ₗ⁅R⁆ L₂} (h : ∀ x, f x = g x) : f = g :=
  coe_injective <| funext h
#align lie_equiv.ext LieEquiv.ext
-/

instance : One (L₁ ≃ₗ⁅R⁆ L₁) :=
  ⟨{ (1 : L₁ ≃ₗ[R] L₁) with map_lie' := fun x y => rfl }⟩

#print LieEquiv.one_apply /-
@[simp]
theorem one_apply (x : L₁) : (1 : L₁ ≃ₗ⁅R⁆ L₁) x = x :=
  rfl
#align lie_equiv.one_apply LieEquiv.one_apply
-/

instance : Inhabited (L₁ ≃ₗ⁅R⁆ L₁) :=
  ⟨1⟩

#print LieEquiv.refl /-
/-- Lie algebra equivalences are reflexive. -/
@[refl]
def refl : L₁ ≃ₗ⁅R⁆ L₁ :=
  1
#align lie_equiv.refl LieEquiv.refl
-/

#print LieEquiv.refl_apply /-
@[simp]
theorem refl_apply (x : L₁) : (refl : L₁ ≃ₗ⁅R⁆ L₁) x = x :=
  rfl
#align lie_equiv.refl_apply LieEquiv.refl_apply
-/

#print LieEquiv.symm /-
/-- Lie algebra equivalences are symmetric. -/
@[symm]
def symm (e : L₁ ≃ₗ⁅R⁆ L₂) : L₂ ≃ₗ⁅R⁆ L₁ :=
  { LieHom.inverse e.toLieHom e.invFun e.left_inv e.right_inv, e.toLinearEquiv.symm with }
#align lie_equiv.symm LieEquiv.symm
-/

#print LieEquiv.symm_symm /-
@[simp]
theorem symm_symm (e : L₁ ≃ₗ⁅R⁆ L₂) : e.symm.symm = e := by ext; rfl
#align lie_equiv.symm_symm LieEquiv.symm_symm
-/

#print LieEquiv.apply_symm_apply /-
@[simp]
theorem apply_symm_apply (e : L₁ ≃ₗ⁅R⁆ L₂) : ∀ x, e (e.symm x) = x :=
  e.toLinearEquiv.apply_symm_apply
#align lie_equiv.apply_symm_apply LieEquiv.apply_symm_apply
-/

#print LieEquiv.symm_apply_apply /-
@[simp]
theorem symm_apply_apply (e : L₁ ≃ₗ⁅R⁆ L₂) : ∀ x, e.symm (e x) = x :=
  e.toLinearEquiv.symm_apply_apply
#align lie_equiv.symm_apply_apply LieEquiv.symm_apply_apply
-/

#print LieEquiv.refl_symm /-
@[simp]
theorem refl_symm : (refl : L₁ ≃ₗ⁅R⁆ L₁).symm = refl :=
  rfl
#align lie_equiv.refl_symm LieEquiv.refl_symm
-/

#print LieEquiv.trans /-
/-- Lie algebra equivalences are transitive. -/
@[trans]
def trans (e₁ : L₁ ≃ₗ⁅R⁆ L₂) (e₂ : L₂ ≃ₗ⁅R⁆ L₃) : L₁ ≃ₗ⁅R⁆ L₃ :=
  { LieHom.comp e₂.toLieHom e₁.toLieHom, LinearEquiv.trans e₁.toLinearEquiv e₂.toLinearEquiv with }
#align lie_equiv.trans LieEquiv.trans
-/

#print LieEquiv.self_trans_symm /-
@[simp]
theorem self_trans_symm (e : L₁ ≃ₗ⁅R⁆ L₂) : e.trans e.symm = refl :=
  ext e.symm_apply_apply
#align lie_equiv.self_trans_symm LieEquiv.self_trans_symm
-/

#print LieEquiv.symm_trans_self /-
@[simp]
theorem symm_trans_self (e : L₁ ≃ₗ⁅R⁆ L₂) : e.symm.trans e = refl :=
  e.symm.self_trans_symm
#align lie_equiv.symm_trans_self LieEquiv.symm_trans_self
-/

#print LieEquiv.trans_apply /-
@[simp]
theorem trans_apply (e₁ : L₁ ≃ₗ⁅R⁆ L₂) (e₂ : L₂ ≃ₗ⁅R⁆ L₃) (x : L₁) : (e₁.trans e₂) x = e₂ (e₁ x) :=
  rfl
#align lie_equiv.trans_apply LieEquiv.trans_apply
-/

#print LieEquiv.symm_trans /-
@[simp]
theorem symm_trans (e₁ : L₁ ≃ₗ⁅R⁆ L₂) (e₂ : L₂ ≃ₗ⁅R⁆ L₃) :
    (e₁.trans e₂).symm = e₂.symm.trans e₁.symm :=
  rfl
#align lie_equiv.symm_trans LieEquiv.symm_trans
-/

#print LieEquiv.bijective /-
protected theorem bijective (e : L₁ ≃ₗ⁅R⁆ L₂) : Function.Bijective ((e : L₁ →ₗ⁅R⁆ L₂) : L₁ → L₂) :=
  e.toLinearEquiv.Bijective
#align lie_equiv.bijective LieEquiv.bijective
-/

#print LieEquiv.injective /-
protected theorem injective (e : L₁ ≃ₗ⁅R⁆ L₂) : Function.Injective ((e : L₁ →ₗ⁅R⁆ L₂) : L₁ → L₂) :=
  e.toLinearEquiv.Injective
#align lie_equiv.injective LieEquiv.injective
-/

#print LieEquiv.surjective /-
protected theorem surjective (e : L₁ ≃ₗ⁅R⁆ L₂) :
    Function.Surjective ((e : L₁ →ₗ⁅R⁆ L₂) : L₁ → L₂) :=
  e.toLinearEquiv.Surjective
#align lie_equiv.surjective LieEquiv.surjective
-/

#print LieEquiv.ofBijective /-
/-- A bijective morphism of Lie algebras yields an equivalence of Lie algebras. -/
@[simps]
noncomputable def ofBijective (f : L₁ →ₗ⁅R⁆ L₂) (h : Function.Bijective f) : L₁ ≃ₗ⁅R⁆ L₂ :=
  {
    LinearEquiv.ofBijective (f : L₁ →ₗ[R] L₂)
      h with
    toFun := f
    map_lie' := f.map_lie }
#align lie_equiv.of_bijective LieEquiv.ofBijective
-/

end LieEquiv

section LieModuleMorphisms

variable (R : Type u) (L : Type v) (M : Type w) (N : Type w₁) (P : Type w₂)

variable [CommRing R] [LieRing L] [LieAlgebra R L]

variable [AddCommGroup M] [AddCommGroup N] [AddCommGroup P]

variable [Module R M] [Module R N] [Module R P]

variable [LieRingModule L M] [LieRingModule L N] [LieRingModule L P]

variable [LieModule R L M] [LieModule R L N] [LieModule R L P]

#print LieModuleHom /-
/-- A morphism of Lie algebra modules is a linear map which commutes with the action of the Lie
algebra. -/
structure LieModuleHom extends M →ₗ[R] N where
  map_lie' : ∀ {x : L} {m : M}, to_fun ⁅x, m⁆ = ⁅x, to_fun m⁆
#align lie_module_hom LieModuleHom
-/

attribute [nolint doc_blame] LieModuleHom.toLinearMap

notation:25 M " →ₗ⁅" R "," L:25 "⁆ " N:0 => LieModuleHom R L M N

namespace LieModuleHom

variable {R L M N P}

instance : Coe (M →ₗ⁅R,L⁆ N) (M →ₗ[R] N) :=
  ⟨LieModuleHom.toLinearMap⟩

/-- see Note [function coercion] -/
instance : CoeFun (M →ₗ⁅R,L⁆ N) fun _ => M → N :=
  ⟨fun f => f.toLinearMap.toFun⟩

#print LieModuleHom.coe_toLinearMap /-
@[simp, norm_cast]
theorem coe_toLinearMap (f : M →ₗ⁅R,L⁆ N) : ((f : M →ₗ[R] N) : M → N) = f :=
  rfl
#align lie_module_hom.coe_to_linear_map LieModuleHom.coe_toLinearMap
-/

#print LieModuleHom.map_smul /-
@[simp]
theorem map_smul (f : M →ₗ⁅R,L⁆ N) (c : R) (x : M) : f (c • x) = c • f x :=
  LinearMap.map_smul (f : M →ₗ[R] N) c x
#align lie_module_hom.map_smul LieModuleHom.map_smul
-/

#print LieModuleHom.map_add /-
@[simp]
theorem map_add (f : M →ₗ⁅R,L⁆ N) (x y : M) : f (x + y) = f x + f y :=
  LinearMap.map_add (f : M →ₗ[R] N) x y
#align lie_module_hom.map_add LieModuleHom.map_add
-/

#print LieModuleHom.map_sub /-
@[simp]
theorem map_sub (f : M →ₗ⁅R,L⁆ N) (x y : M) : f (x - y) = f x - f y :=
  LinearMap.map_sub (f : M →ₗ[R] N) x y
#align lie_module_hom.map_sub LieModuleHom.map_sub
-/

#print LieModuleHom.map_neg /-
@[simp]
theorem map_neg (f : M →ₗ⁅R,L⁆ N) (x : M) : f (-x) = -f x :=
  LinearMap.map_neg (f : M →ₗ[R] N) x
#align lie_module_hom.map_neg LieModuleHom.map_neg
-/

#print LieModuleHom.map_lie /-
@[simp]
theorem map_lie (f : M →ₗ⁅R,L⁆ N) (x : L) (m : M) : f ⁅x, m⁆ = ⁅x, f m⁆ :=
  LieModuleHom.map_lie' f
#align lie_module_hom.map_lie LieModuleHom.map_lie
-/

#print LieModuleHom.map_lie₂ /-
theorem map_lie₂ (f : M →ₗ⁅R,L⁆ N →ₗ[R] P) (x : L) (m : M) (n : N) :
    ⁅x, f m n⁆ = f ⁅x, m⁆ n + f m ⁅x, n⁆ := by simp only [sub_add_cancel, map_lie, LieHom.lie_apply]
#align lie_module_hom.map_lie₂ LieModuleHom.map_lie₂
-/

#print LieModuleHom.map_zero /-
@[simp]
theorem map_zero (f : M →ₗ⁅R,L⁆ N) : f 0 = 0 :=
  LinearMap.map_zero (f : M →ₗ[R] N)
#align lie_module_hom.map_zero LieModuleHom.map_zero
-/

#print LieModuleHom.id /-
/-- The identity map is a morphism of Lie modules. -/
def id : M →ₗ⁅R,L⁆ M :=
  { (LinearMap.id : M →ₗ[R] M) with map_lie' := fun x m => rfl }
#align lie_module_hom.id LieModuleHom.id
-/

#print LieModuleHom.coe_id /-
@[simp]
theorem coe_id : ((id : M →ₗ⁅R,L⁆ M) : M → M) = id :=
  rfl
#align lie_module_hom.coe_id LieModuleHom.coe_id
-/

#print LieModuleHom.id_apply /-
theorem id_apply (x : M) : (id : M →ₗ⁅R,L⁆ M) x = x :=
  rfl
#align lie_module_hom.id_apply LieModuleHom.id_apply
-/

/-- The constant 0 map is a Lie module morphism. -/
instance : Zero (M →ₗ⁅R,L⁆ N) :=
  ⟨{ (0 : M →ₗ[R] N) with map_lie' := by simp }⟩

#print LieModuleHom.coe_zero /-
@[norm_cast, simp]
theorem coe_zero : ((0 : M →ₗ⁅R,L⁆ N) : M → N) = 0 :=
  rfl
#align lie_module_hom.coe_zero LieModuleHom.coe_zero
-/

#print LieModuleHom.zero_apply /-
theorem zero_apply (m : M) : (0 : M →ₗ⁅R,L⁆ N) m = 0 :=
  rfl
#align lie_module_hom.zero_apply LieModuleHom.zero_apply
-/

/-- The identity map is a Lie module morphism. -/
instance : One (M →ₗ⁅R,L⁆ M) :=
  ⟨id⟩

instance : Inhabited (M →ₗ⁅R,L⁆ N) :=
  ⟨0⟩

#print LieModuleHom.coe_injective /-
theorem coe_injective : @Function.Injective (M →ₗ⁅R,L⁆ N) (M → N) coeFn := by
  rintro ⟨⟨f, _⟩⟩ ⟨⟨g, _⟩⟩ ⟨h⟩; congr
#align lie_module_hom.coe_injective LieModuleHom.coe_injective
-/

#print LieModuleHom.ext /-
@[ext]
theorem ext {f g : M →ₗ⁅R,L⁆ N} (h : ∀ m, f m = g m) : f = g :=
  coe_injective <| funext h
#align lie_module_hom.ext LieModuleHom.ext
-/

#print LieModuleHom.ext_iff /-
theorem ext_iff {f g : M →ₗ⁅R,L⁆ N} : f = g ↔ ∀ m, f m = g m :=
  ⟨by rintro rfl m; rfl, ext⟩
#align lie_module_hom.ext_iff LieModuleHom.ext_iff
-/

#print LieModuleHom.congr_fun /-
theorem congr_fun {f g : M →ₗ⁅R,L⁆ N} (h : f = g) (x : M) : f x = g x :=
  h ▸ rfl
#align lie_module_hom.congr_fun LieModuleHom.congr_fun
-/

#print LieModuleHom.mk_coe /-
@[simp]
theorem mk_coe (f : M →ₗ⁅R,L⁆ N) (h) : (⟨f, h⟩ : M →ₗ⁅R,L⁆ N) = f := by ext; rfl
#align lie_module_hom.mk_coe LieModuleHom.mk_coe
-/

#print LieModuleHom.coe_mk /-
@[simp]
theorem coe_mk (f : M →ₗ[R] N) (h) : ((⟨f, h⟩ : M →ₗ⁅R,L⁆ N) : M → N) = f := by ext; rfl
#align lie_module_hom.coe_mk LieModuleHom.coe_mk
-/

#print LieModuleHom.coe_linear_mk /-
@[norm_cast, simp]
theorem coe_linear_mk (f : M →ₗ[R] N) (h) : ((⟨f, h⟩ : M →ₗ⁅R,L⁆ N) : M →ₗ[R] N) = f := by ext; rfl
#align lie_module_hom.coe_linear_mk LieModuleHom.coe_linear_mk
-/

#print LieModuleHom.comp /-
/-- The composition of Lie module morphisms is a morphism. -/
def comp (f : N →ₗ⁅R,L⁆ P) (g : M →ₗ⁅R,L⁆ N) : M →ₗ⁅R,L⁆ P :=
  { LinearMap.comp f.toLinearMap g.toLinearMap with
    map_lie' := fun x m => by change f (g ⁅x, m⁆) = ⁅x, f (g m)⁆; rw [map_lie, map_lie] }
#align lie_module_hom.comp LieModuleHom.comp
-/

#print LieModuleHom.comp_apply /-
theorem comp_apply (f : N →ₗ⁅R,L⁆ P) (g : M →ₗ⁅R,L⁆ N) (m : M) : f.comp g m = f (g m) :=
  rfl
#align lie_module_hom.comp_apply LieModuleHom.comp_apply
-/

#print LieModuleHom.coe_comp /-
@[norm_cast, simp]
theorem coe_comp (f : N →ₗ⁅R,L⁆ P) (g : M →ₗ⁅R,L⁆ N) : (f.comp g : M → P) = f ∘ g :=
  rfl
#align lie_module_hom.coe_comp LieModuleHom.coe_comp
-/

#print LieModuleHom.coe_linearMap_comp /-
@[norm_cast, simp]
theorem coe_linearMap_comp (f : N →ₗ⁅R,L⁆ P) (g : M →ₗ⁅R,L⁆ N) :
    (f.comp g : M →ₗ[R] P) = (f : N →ₗ[R] P).comp (g : M →ₗ[R] N) :=
  rfl
#align lie_module_hom.coe_linear_map_comp LieModuleHom.coe_linearMap_comp
-/

#print LieModuleHom.inverse /-
/-- The inverse of a bijective morphism of Lie modules is a morphism of Lie modules. -/
def inverse (f : M →ₗ⁅R,L⁆ N) (g : N → M) (h₁ : Function.LeftInverse g f)
    (h₂ : Function.RightInverse g f) : N →ₗ⁅R,L⁆ M :=
  { LinearMap.inverse f.toLinearMap g h₁ h₂ with
    map_lie' := fun x n =>
      calc
        g ⁅x, n⁆ = g ⁅x, f (g n)⁆ := by rw [h₂]
        _ = g (f ⁅x, g n⁆) := by rw [map_lie]
        _ = ⁅x, g n⁆ := h₁ _ }
#align lie_module_hom.inverse LieModuleHom.inverse
-/

instance : Add (M →ₗ⁅R,L⁆ N)
    where add f g := { (f : M →ₗ[R] N) + (g : M →ₗ[R] N) with map_lie' := by simp }

instance : Sub (M →ₗ⁅R,L⁆ N)
    where sub f g := { (f : M →ₗ[R] N) - (g : M →ₗ[R] N) with map_lie' := by simp }

instance : Neg (M →ₗ⁅R,L⁆ N) where neg f := { -(f : M →ₗ[R] N) with map_lie' := by simp }

#print LieModuleHom.coe_add /-
@[norm_cast, simp]
theorem coe_add (f g : M →ₗ⁅R,L⁆ N) : ⇑(f + g) = f + g :=
  rfl
#align lie_module_hom.coe_add LieModuleHom.coe_add
-/

#print LieModuleHom.add_apply /-
theorem add_apply (f g : M →ₗ⁅R,L⁆ N) (m : M) : (f + g) m = f m + g m :=
  rfl
#align lie_module_hom.add_apply LieModuleHom.add_apply
-/

#print LieModuleHom.coe_sub /-
@[norm_cast, simp]
theorem coe_sub (f g : M →ₗ⁅R,L⁆ N) : ⇑(f - g) = f - g :=
  rfl
#align lie_module_hom.coe_sub LieModuleHom.coe_sub
-/

#print LieModuleHom.sub_apply /-
theorem sub_apply (f g : M →ₗ⁅R,L⁆ N) (m : M) : (f - g) m = f m - g m :=
  rfl
#align lie_module_hom.sub_apply LieModuleHom.sub_apply
-/

#print LieModuleHom.coe_neg /-
@[norm_cast, simp]
theorem coe_neg (f : M →ₗ⁅R,L⁆ N) : ⇑(-f) = -f :=
  rfl
#align lie_module_hom.coe_neg LieModuleHom.coe_neg
-/

#print LieModuleHom.neg_apply /-
theorem neg_apply (f : M →ₗ⁅R,L⁆ N) (m : M) : (-f) m = -f m :=
  rfl
#align lie_module_hom.neg_apply LieModuleHom.neg_apply
-/

#print LieModuleHom.hasNsmul /-
instance hasNsmul : SMul ℕ (M →ₗ⁅R,L⁆ N)
    where smul n f := { n • (f : M →ₗ[R] N) with map_lie' := fun x m => by simp }
#align lie_module_hom.has_nsmul LieModuleHom.hasNsmul
-/

#print LieModuleHom.coe_nsmul /-
@[norm_cast, simp]
theorem coe_nsmul (n : ℕ) (f : M →ₗ⁅R,L⁆ N) : ⇑(n • f) = n • f :=
  rfl
#align lie_module_hom.coe_nsmul LieModuleHom.coe_nsmul
-/

#print LieModuleHom.nsmul_apply /-
theorem nsmul_apply (n : ℕ) (f : M →ₗ⁅R,L⁆ N) (m : M) : (n • f) m = n • f m :=
  rfl
#align lie_module_hom.nsmul_apply LieModuleHom.nsmul_apply
-/

#print LieModuleHom.hasZsmul /-
instance hasZsmul : SMul ℤ (M →ₗ⁅R,L⁆ N)
    where smul z f := { z • (f : M →ₗ[R] N) with map_lie' := fun x m => by simp }
#align lie_module_hom.has_zsmul LieModuleHom.hasZsmul
-/

#print LieModuleHom.coe_zsmul /-
@[norm_cast, simp]
theorem coe_zsmul (z : ℤ) (f : M →ₗ⁅R,L⁆ N) : ⇑(z • f) = z • f :=
  rfl
#align lie_module_hom.coe_zsmul LieModuleHom.coe_zsmul
-/

#print LieModuleHom.zsmul_apply /-
theorem zsmul_apply (z : ℤ) (f : M →ₗ⁅R,L⁆ N) (m : M) : (z • f) m = z • f m :=
  rfl
#align lie_module_hom.zsmul_apply LieModuleHom.zsmul_apply
-/

instance : AddCommGroup (M →ₗ⁅R,L⁆ N) :=
  coe_injective.AddCommGroup _ coe_zero coe_add coe_neg coe_sub (fun _ _ => coe_nsmul _ _)
    fun _ _ => coe_zsmul _ _

instance : SMul R (M →ₗ⁅R,L⁆ N) where smul t f := { t • (f : M →ₗ[R] N) with map_lie' := by simp }

#print LieModuleHom.coe_smul /-
@[norm_cast, simp]
theorem coe_smul (t : R) (f : M →ₗ⁅R,L⁆ N) : ⇑(t • f) = t • f :=
  rfl
#align lie_module_hom.coe_smul LieModuleHom.coe_smul
-/

#print LieModuleHom.smul_apply /-
theorem smul_apply (t : R) (f : M →ₗ⁅R,L⁆ N) (m : M) : (t • f) m = t • f m :=
  rfl
#align lie_module_hom.smul_apply LieModuleHom.smul_apply
-/

instance : Module R (M →ₗ⁅R,L⁆ N) :=
  Function.Injective.module R ⟨fun f => f.toLinearMap.toFun, rfl, coe_add⟩ coe_injective coe_smul

end LieModuleHom

#print LieModuleEquiv /-
/-- An equivalence of Lie algebra modules is a linear equivalence which is also a morphism of
Lie algebra modules. -/
structure LieModuleEquiv extends M →ₗ⁅R,L⁆ N where
  invFun : N → M
  left_inv : Function.LeftInverse inv_fun to_fun
  right_inv : Function.RightInverse inv_fun to_fun
#align lie_module_equiv LieModuleEquiv
-/

attribute [nolint doc_blame] LieModuleEquiv.toLieModuleHom

notation:25 M " ≃ₗ⁅" R "," L:25 "⁆ " N:0 => LieModuleEquiv R L M N

namespace LieModuleEquiv

variable {R L M N P}

#print LieModuleEquiv.toLinearEquiv /-
/-- View an equivalence of Lie modules as a linear equivalence. -/
def toLinearEquiv (e : M ≃ₗ⁅R,L⁆ N) : M ≃ₗ[R] N :=
  { e with }
#align lie_module_equiv.to_linear_equiv LieModuleEquiv.toLinearEquiv
-/

#print LieModuleEquiv.toEquiv /-
/-- View an equivalence of Lie modules as a type level equivalence. -/
def toEquiv (e : M ≃ₗ⁅R,L⁆ N) : M ≃ N :=
  { e with }
#align lie_module_equiv.to_equiv LieModuleEquiv.toEquiv
-/

#print LieModuleEquiv.hasCoeToEquiv /-
instance hasCoeToEquiv : Coe (M ≃ₗ⁅R,L⁆ N) (M ≃ N) :=
  ⟨toEquiv⟩
#align lie_module_equiv.has_coe_to_equiv LieModuleEquiv.hasCoeToEquiv
-/

#print LieModuleEquiv.hasCoeToLieModuleHom /-
instance hasCoeToLieModuleHom : Coe (M ≃ₗ⁅R,L⁆ N) (M →ₗ⁅R,L⁆ N) :=
  ⟨toLieModuleHom⟩
#align lie_module_equiv.has_coe_to_lie_module_hom LieModuleEquiv.hasCoeToLieModuleHom
-/

#print LieModuleEquiv.hasCoeToLinearEquiv /-
instance hasCoeToLinearEquiv : Coe (M ≃ₗ⁅R,L⁆ N) (M ≃ₗ[R] N) :=
  ⟨toLinearEquiv⟩
#align lie_module_equiv.has_coe_to_linear_equiv LieModuleEquiv.hasCoeToLinearEquiv
-/

/-- see Note [function coercion] -/
instance : CoeFun (M ≃ₗ⁅R,L⁆ N) fun _ => M → N :=
  ⟨fun e => e.toLieModuleHom.toFun⟩

#print LieModuleEquiv.injective /-
theorem injective (e : M ≃ₗ⁅R,L⁆ N) : Function.Injective e :=
  e.toEquiv.Injective
#align lie_module_equiv.injective LieModuleEquiv.injective
-/

#print LieModuleEquiv.coe_mk /-
@[simp]
theorem coe_mk (f : M →ₗ⁅R,L⁆ N) (inv_fun h₁ h₂) :
    ((⟨f, inv_fun, h₁, h₂⟩ : M ≃ₗ⁅R,L⁆ N) : M → N) = f :=
  rfl
#align lie_module_equiv.coe_mk LieModuleEquiv.coe_mk
-/

#print LieModuleEquiv.coe_to_lieModuleHom /-
@[simp, norm_cast]
theorem coe_to_lieModuleHom (e : M ≃ₗ⁅R,L⁆ N) : ((e : M →ₗ⁅R,L⁆ N) : M → N) = e :=
  rfl
#align lie_module_equiv.coe_to_lie_module_hom LieModuleEquiv.coe_to_lieModuleHom
-/

#print LieModuleEquiv.coe_to_linearEquiv /-
@[simp, norm_cast]
theorem coe_to_linearEquiv (e : M ≃ₗ⁅R,L⁆ N) : ((e : M ≃ₗ[R] N) : M → N) = e :=
  rfl
#align lie_module_equiv.coe_to_linear_equiv LieModuleEquiv.coe_to_linearEquiv
-/

#print LieModuleEquiv.toEquiv_injective /-
theorem toEquiv_injective : Function.Injective (toEquiv : (M ≃ₗ⁅R,L⁆ N) → M ≃ N) := fun e₁ e₂ h =>
  by
  rcases e₁ with ⟨⟨⟩⟩; rcases e₂ with ⟨⟨⟩⟩
  have inj := Equiv.mk.inj h
  dsimp at inj 
  apply lie_module_equiv.mk.inj_eq.mpr
  constructor
  · congr
    ext
    rw [inj.1]
  · exact inj.2
#align lie_module_equiv.to_equiv_injective LieModuleEquiv.toEquiv_injective
-/

#print LieModuleEquiv.ext /-
@[ext]
theorem ext (e₁ e₂ : M ≃ₗ⁅R,L⁆ N) (h : ∀ m, e₁ m = e₂ m) : e₁ = e₂ :=
  toEquiv_injective (Equiv.ext h)
#align lie_module_equiv.ext LieModuleEquiv.ext
-/

instance : One (M ≃ₗ⁅R,L⁆ M) :=
  ⟨{ (1 : M ≃ₗ[R] M) with map_lie' := fun x m => rfl }⟩

#print LieModuleEquiv.one_apply /-
@[simp]
theorem one_apply (m : M) : (1 : M ≃ₗ⁅R,L⁆ M) m = m :=
  rfl
#align lie_module_equiv.one_apply LieModuleEquiv.one_apply
-/

instance : Inhabited (M ≃ₗ⁅R,L⁆ M) :=
  ⟨1⟩

#print LieModuleEquiv.refl /-
/-- Lie module equivalences are reflexive. -/
@[refl]
def refl : M ≃ₗ⁅R,L⁆ M :=
  1
#align lie_module_equiv.refl LieModuleEquiv.refl
-/

#print LieModuleEquiv.refl_apply /-
@[simp]
theorem refl_apply (m : M) : (refl : M ≃ₗ⁅R,L⁆ M) m = m :=
  rfl
#align lie_module_equiv.refl_apply LieModuleEquiv.refl_apply
-/

#print LieModuleEquiv.symm /-
/-- Lie module equivalences are syemmtric. -/
@[symm]
def symm (e : M ≃ₗ⁅R,L⁆ N) : N ≃ₗ⁅R,L⁆ M :=
  { LieModuleHom.inverse e.toLieModuleHom e.invFun e.left_inv e.right_inv,
    (e : M ≃ₗ[R] N).symm with }
#align lie_module_equiv.symm LieModuleEquiv.symm
-/

#print LieModuleEquiv.apply_symm_apply /-
@[simp]
theorem apply_symm_apply (e : M ≃ₗ⁅R,L⁆ N) : ∀ x, e (e.symm x) = x :=
  e.toLinearEquiv.apply_symm_apply
#align lie_module_equiv.apply_symm_apply LieModuleEquiv.apply_symm_apply
-/

#print LieModuleEquiv.symm_apply_apply /-
@[simp]
theorem symm_apply_apply (e : M ≃ₗ⁅R,L⁆ N) : ∀ x, e.symm (e x) = x :=
  e.toLinearEquiv.symm_apply_apply
#align lie_module_equiv.symm_apply_apply LieModuleEquiv.symm_apply_apply
-/

#print LieModuleEquiv.symm_symm /-
@[simp]
theorem symm_symm (e : M ≃ₗ⁅R,L⁆ N) : e.symm.symm = e := by ext;
  apply_fun e.symm using e.symm.injective; simp
#align lie_module_equiv.symm_symm LieModuleEquiv.symm_symm
-/

#print LieModuleEquiv.trans /-
/-- Lie module equivalences are transitive. -/
@[trans]
def trans (e₁ : M ≃ₗ⁅R,L⁆ N) (e₂ : N ≃ₗ⁅R,L⁆ P) : M ≃ₗ⁅R,L⁆ P :=
  { LieModuleHom.comp e₂.toLieModuleHom e₁.toLieModuleHom,
    LinearEquiv.trans e₁.toLinearEquiv e₂.toLinearEquiv with }
#align lie_module_equiv.trans LieModuleEquiv.trans
-/

#print LieModuleEquiv.trans_apply /-
@[simp]
theorem trans_apply (e₁ : M ≃ₗ⁅R,L⁆ N) (e₂ : N ≃ₗ⁅R,L⁆ P) (m : M) : (e₁.trans e₂) m = e₂ (e₁ m) :=
  rfl
#align lie_module_equiv.trans_apply LieModuleEquiv.trans_apply
-/

#print LieModuleEquiv.symm_trans /-
@[simp]
theorem symm_trans (e₁ : M ≃ₗ⁅R,L⁆ N) (e₂ : N ≃ₗ⁅R,L⁆ P) :
    (e₁.trans e₂).symm = e₂.symm.trans e₁.symm :=
  rfl
#align lie_module_equiv.symm_trans LieModuleEquiv.symm_trans
-/

#print LieModuleEquiv.self_trans_symm /-
@[simp]
theorem self_trans_symm (e : M ≃ₗ⁅R,L⁆ N) : e.trans e.symm = refl :=
  ext _ _ e.symm_apply_apply
#align lie_module_equiv.self_trans_symm LieModuleEquiv.self_trans_symm
-/

#print LieModuleEquiv.symm_trans_self /-
@[simp]
theorem symm_trans_self (e : M ≃ₗ⁅R,L⁆ N) : e.symm.trans e = refl :=
  ext _ _ e.apply_symm_apply
#align lie_module_equiv.symm_trans_self LieModuleEquiv.symm_trans_self
-/

end LieModuleEquiv

end LieModuleMorphisms

