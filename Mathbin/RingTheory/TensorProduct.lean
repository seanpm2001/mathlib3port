/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Johan Commelin

! This file was ported from Lean 3 source module ring_theory.tensor_product
! leanprover-community/mathlib commit 69b2e97a276619372b19cf80fc1e91b05ae2baa4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.FiniteDimensional
import Mathbin.RingTheory.Adjoin.Basic
import Mathbin.LinearAlgebra.DirectSum.Finsupp

/-!
# The tensor product of R-algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Let `R` be a (semi)ring and `A` an `R`-algebra.
In this file we:

- Define the `A`-module structure on `A ⊗ M`, for an `R`-module `M`.
- Define the `R`-algebra structure on `A ⊗ B`, for another `R`-algebra `B`.
  and provide the structure isomorphisms
  * `R ⊗[R] A ≃ₐ[R] A`
  * `A ⊗[R] R ≃ₐ[R] A`
  * `A ⊗[R] B ≃ₐ[R] B ⊗[R] A`
  * `((A ⊗[R] B) ⊗[R] C) ≃ₐ[R] (A ⊗[R] (B ⊗[R] C))`

## Main declaration

- `linear_map.base_change A f` is the `A`-linear map `A ⊗ f`, for an `R`-linear map `f`.

## Implementation notes

The heterobasic definitions below such as:
 * `tensor_product.algebra_tensor_module.curry`
 * `tensor_product.algebra_tensor_module.uncurry`
 * `tensor_product.algebra_tensor_module.lcurry`
 * `tensor_product.algebra_tensor_module.lift`
 * `tensor_product.algebra_tensor_module.lift.equiv`
 * `tensor_product.algebra_tensor_module.mk`
 * `tensor_product.algebra_tensor_module.assoc`

are just more general versions of the definitions already in `linear_algebra/tensor_product`. We
could thus consider replacing the less general definitions with these ones. If we do this, we
probably should still implement the less general ones as abbreviations to the more general ones with
fewer type arguments.
-/


universe u v₁ v₂ v₃ v₄

open scoped TensorProduct

open TensorProduct

namespace TensorProduct

variable {R A M N P : Type _}

/-!
### The `A`-module structure on `A ⊗[R] M`
-/


open LinearMap

open Algebra (lsmul)

namespace AlgebraTensorModule

section Semiring

variable [CommSemiring R] [Semiring A] [Algebra R A]

variable [AddCommMonoid M] [Module R M] [Module A M] [IsScalarTower R A M]

variable [AddCommMonoid N] [Module R N]

variable [AddCommMonoid P] [Module R P] [Module A P] [IsScalarTower R A P]

#print TensorProduct.AlgebraTensorModule.smul_eq_lsmul_rTensor /-
theorem smul_eq_lsmul_rTensor (a : A) (x : M ⊗[R] N) : a • x = (lsmul R M a).rTensor N x :=
  rfl
#align tensor_product.algebra_tensor_module.smul_eq_lsmul_rtensor TensorProduct.AlgebraTensorModule.smul_eq_lsmul_rTensor
-/

#print TensorProduct.AlgebraTensorModule.curry /-
/-- Heterobasic version of `tensor_product.curry`:

Given a linear map `M ⊗[R] N →[A] P`, compose it with the canonical
bilinear map `M →[A] N →[R] M ⊗[R] N` to form a bilinear map `M →[A] N →[R] P`. -/
@[simps]
def curry (f : M ⊗[R] N →ₗ[A] P) : M →ₗ[A] N →ₗ[R] P :=
  {
    curry (f.restrictScalars
        R) with
    toFun := curry (f.restrictScalars R)
    map_smul' := fun c x => LinearMap.ext fun y => f.map_smul c (x ⊗ₜ y) }
#align tensor_product.algebra_tensor_module.curry TensorProduct.AlgebraTensorModule.curry
-/

#print TensorProduct.AlgebraTensorModule.restrictScalars_curry /-
theorem restrictScalars_curry (f : M ⊗[R] N →ₗ[A] P) :
    RestrictScalars R (curry f) = curry (f.restrictScalars R) :=
  rfl
#align tensor_product.algebra_tensor_module.restrict_scalars_curry TensorProduct.AlgebraTensorModule.restrictScalars_curry
-/

#print TensorProduct.AlgebraTensorModule.curry_injective /-
/-- Just as `tensor_product.ext` is marked `ext` instead of `tensor_product.ext'`, this is
a better `ext` lemma than `tensor_product.algebra_tensor_module.ext` below.

See note [partially-applied ext lemmas]. -/
@[ext]
theorem curry_injective : Function.Injective (curry : (M ⊗ N →ₗ[A] P) → M →ₗ[A] N →ₗ[R] P) :=
  fun x y h =>
  LinearMap.restrictScalars_injective R <|
    curry_injective <| (congr_arg (LinearMap.restrictScalars R) h : _)
#align tensor_product.algebra_tensor_module.curry_injective TensorProduct.AlgebraTensorModule.curry_injective
-/

#print TensorProduct.AlgebraTensorModule.ext /-
theorem ext {g h : M ⊗[R] N →ₗ[A] P} (H : ∀ x y, g (x ⊗ₜ y) = h (x ⊗ₜ y)) : g = h :=
  curry_injective <| LinearMap.ext₂ H
#align tensor_product.algebra_tensor_module.ext TensorProduct.AlgebraTensorModule.ext
-/

end Semiring

section CommSemiring

variable [CommSemiring R] [CommSemiring A] [Algebra R A]

variable [AddCommMonoid M] [Module R M] [Module A M] [IsScalarTower R A M]

variable [AddCommMonoid N] [Module R N]

variable [AddCommMonoid P] [Module R P] [Module A P] [IsScalarTower R A P]

#print TensorProduct.AlgebraTensorModule.lift /-
/-- Heterobasic version of `tensor_product.lift`:

Constructing a linear map `M ⊗[R] N →[A] P` given a bilinear map `M →[A] N →[R] P` with the
property that its composition with the canonical bilinear map `M →[A] N →[R] M ⊗[R] N` is
the given bilinear map `M →[A] N →[R] P`. -/
@[simps]
def lift (f : M →ₗ[A] N →ₗ[R] P) : M ⊗[R] N →ₗ[A] P :=
  { lift (f.restrictScalars R) with
    map_smul' := fun c =>
      show
        ∀ x : M ⊗[R] N,
          (lift (f.restrictScalars R)).comp (lsmul R _ c) x =
            (lsmul R _ c).comp (lift (f.restrictScalars R)) x
        from
        ext_iff.1 <|
          TensorProduct.ext' fun x y => by
            simp only [comp_apply, Algebra.lsmul_coe, smul_tmul', lift.tmul,
              coe_restrict_scalars_eq_coe, f.map_smul, smul_apply] }
#align tensor_product.algebra_tensor_module.lift TensorProduct.AlgebraTensorModule.lift
-/

#print TensorProduct.AlgebraTensorModule.lift_tmul /-
@[simp]
theorem lift_tmul (f : M →ₗ[A] N →ₗ[R] P) (x : M) (y : N) : lift f (x ⊗ₜ y) = f x y :=
  rfl
#align tensor_product.algebra_tensor_module.lift_tmul TensorProduct.AlgebraTensorModule.lift_tmul
-/

variable (R A M N P)

#print TensorProduct.AlgebraTensorModule.uncurry /-
/-- Heterobasic version of `tensor_product.uncurry`:

Linearly constructing a linear map `M ⊗[R] N →[A] P` given a bilinear map `M →[A] N →[R] P`
with the property that its composition with the canonical bilinear map `M →[A] N →[R] M ⊗[R] N` is
the given bilinear map `M →[A] N →[R] P`. -/
@[simps]
def uncurry : (M →ₗ[A] N →ₗ[R] P) →ₗ[A] M ⊗[R] N →ₗ[A] P
    where
  toFun := lift
  map_add' f g := ext fun x y => by simp only [lift_tmul, add_apply]
  map_smul' c f := ext fun x y => by simp only [lift_tmul, smul_apply, RingHom.id_apply]
#align tensor_product.algebra_tensor_module.uncurry TensorProduct.AlgebraTensorModule.uncurry
-/

#print TensorProduct.AlgebraTensorModule.lcurry /-
/-- Heterobasic version of `tensor_product.lcurry`:

Given a linear map `M ⊗[R] N →[A] P`, compose it with the canonical
bilinear map `M →[A] N →[R] M ⊗[R] N` to form a bilinear map `M →[A] N →[R] P`. -/
@[simps]
def lcurry : (M ⊗[R] N →ₗ[A] P) →ₗ[A] M →ₗ[A] N →ₗ[R] P
    where
  toFun := curry
  map_add' f g := rfl
  map_smul' c f := rfl
#align tensor_product.algebra_tensor_module.lcurry TensorProduct.AlgebraTensorModule.lcurry
-/

#print TensorProduct.AlgebraTensorModule.lift.equiv /-
/-- Heterobasic version of `tensor_product.lift.equiv`:

A linear equivalence constructing a linear map `M ⊗[R] N →[A] P` given a
bilinear map `M →[A] N →[R] P` with the property that its composition with the
canonical bilinear map `M →[A] N →[R] M ⊗[R] N` is the given bilinear map `M →[A] N →[R] P`. -/
def lift.equiv : (M →ₗ[A] N →ₗ[R] P) ≃ₗ[A] M ⊗[R] N →ₗ[A] P :=
  LinearEquiv.ofLinear (uncurry R A M N P) (lcurry R A M N P)
    (LinearMap.ext fun f => ext fun x y => lift_tmul _ x y)
    (LinearMap.ext fun f => LinearMap.ext fun x => LinearMap.ext fun y => lift_tmul f x y)
#align tensor_product.algebra_tensor_module.lift.equiv TensorProduct.AlgebraTensorModule.lift.equiv
-/

variable (R A M N P)

#print TensorProduct.AlgebraTensorModule.mk /-
/-- Heterobasic version of `tensor_product.mk`:

The canonical bilinear map `M →[A] N →[R] M ⊗[R] N`. -/
@[simps]
def mk : M →ₗ[A] N →ₗ[R] M ⊗[R] N :=
  { mk R M N with map_smul' := fun c x => rfl }
#align tensor_product.algebra_tensor_module.mk TensorProduct.AlgebraTensorModule.mk
-/

attribute [local ext] TensorProduct.ext

#print TensorProduct.AlgebraTensorModule.assoc /-
/-- Heterobasic version of `tensor_product.assoc`:

Linear equivalence between `(M ⊗[A] N) ⊗[R] P` and `M ⊗[A] (N ⊗[R] P)`. -/
def assoc : (M ⊗[A] P) ⊗[R] N ≃ₗ[A] M ⊗[A] P ⊗[R] N :=
  LinearEquiv.ofLinear
    (lift <|
      TensorProduct.uncurry A _ _ _ <| comp (lcurry R A _ _ _) <| TensorProduct.mk A M (P ⊗[R] N))
    (TensorProduct.uncurry A _ _ _ <|
      comp (uncurry R A _ _ _) <| by apply TensorProduct.curry; exact mk R A _ _)
    (by ext; rfl)
    (by ext;
      simp only [curry_apply, TensorProduct.curry_apply, mk_apply, TensorProduct.mk_apply,
        uncurry_apply, TensorProduct.uncurry_apply, id_apply, lift_tmul, compr₂_apply,
        restrict_scalars_apply, Function.comp_apply, to_fun_eq_coe, lcurry_apply,
        LinearMap.comp_apply])
#align tensor_product.algebra_tensor_module.assoc TensorProduct.AlgebraTensorModule.assoc
-/

end CommSemiring

end AlgebraTensorModule

end TensorProduct

namespace LinearMap

open TensorProduct

/-!
### The base-change of a linear map of `R`-modules to a linear map of `A`-modules
-/


section Semiring

variable {R A B M N : Type _} [CommSemiring R]

variable [Semiring A] [Algebra R A] [Semiring B] [Algebra R B]

variable [AddCommMonoid M] [Module R M] [AddCommMonoid N] [Module R N]

variable (r : R) (f g : M →ₗ[R] N)

variable (A)

#print LinearMap.baseChange /-
/-- `base_change A f` for `f : M →ₗ[R] N` is the `A`-linear map `A ⊗[R] M →ₗ[A] A ⊗[R] N`. -/
def baseChange (f : M →ₗ[R] N) : A ⊗[R] M →ₗ[A] A ⊗[R] N
    where
  toFun := f.lTensor A
  map_add' := (f.lTensor A).map_add
  map_smul' a x :=
    show
      (f.lTensor A) (rTensor M (LinearMap.mul R A a) x) =
        (rTensor N ((LinearMap.mul R A) a)) ((lTensor A f) x)
      by
      rw [← comp_apply, ← comp_apply]
      simp only [ltensor_comp_rtensor, rtensor_comp_ltensor]
#align linear_map.base_change LinearMap.baseChange
-/

variable {A}

#print LinearMap.baseChange_tmul /-
@[simp]
theorem baseChange_tmul (a : A) (x : M) : f.base_change A (a ⊗ₜ x) = a ⊗ₜ f x :=
  rfl
#align linear_map.base_change_tmul LinearMap.baseChange_tmul
-/

#print LinearMap.baseChange_eq_ltensor /-
theorem baseChange_eq_ltensor : (f.base_change A : A ⊗ M → A ⊗ N) = f.lTensor A :=
  rfl
#align linear_map.base_change_eq_ltensor LinearMap.baseChange_eq_ltensor
-/

#print LinearMap.baseChange_add /-
@[simp]
theorem baseChange_add : (f + g).base_change A = f.base_change A + g.base_change A := by ext;
  simp [base_change_eq_ltensor]
#align linear_map.base_change_add LinearMap.baseChange_add
-/

#print LinearMap.baseChange_zero /-
@[simp]
theorem baseChange_zero : baseChange A (0 : M →ₗ[R] N) = 0 := by ext; simp [base_change_eq_ltensor]
#align linear_map.base_change_zero LinearMap.baseChange_zero
-/

#print LinearMap.baseChange_smul /-
@[simp]
theorem baseChange_smul : (r • f).base_change A = r • f.base_change A := by ext;
  simp [base_change_tmul]
#align linear_map.base_change_smul LinearMap.baseChange_smul
-/

variable (R A M N)

#print LinearMap.baseChangeHom /-
/-- `base_change` as a linear map. -/
@[simps]
def baseChangeHom : (M →ₗ[R] N) →ₗ[R] A ⊗[R] M →ₗ[A] A ⊗[R] N
    where
  toFun := baseChange A
  map_add' := baseChange_add
  map_smul' := baseChange_smul
#align linear_map.base_change_hom LinearMap.baseChangeHom
-/

end Semiring

section Ring

variable {R A B M N : Type _} [CommRing R]

variable [Ring A] [Algebra R A] [Ring B] [Algebra R B]

variable [AddCommGroup M] [Module R M] [AddCommGroup N] [Module R N]

variable (f g : M →ₗ[R] N)

#print LinearMap.baseChange_sub /-
@[simp]
theorem baseChange_sub : (f - g).base_change A = f.base_change A - g.base_change A := by ext;
  simp [base_change_eq_ltensor]
#align linear_map.base_change_sub LinearMap.baseChange_sub
-/

#print LinearMap.baseChange_neg /-
@[simp]
theorem baseChange_neg : (-f).base_change A = -f.base_change A := by ext;
  simp [base_change_eq_ltensor]
#align linear_map.base_change_neg LinearMap.baseChange_neg
-/

end Ring

end LinearMap

namespace Algebra

namespace TensorProduct

section Semiring

variable {R : Type u} [CommSemiring R]

variable {A : Type v₁} [Semiring A] [Algebra R A]

variable {B : Type v₂} [Semiring B] [Algebra R B]

/-!
### The `R`-algebra structure on `A ⊗[R] B`
-/


#print Algebra.TensorProduct.mulAux /-
/-- (Implementation detail)
The multiplication map on `A ⊗[R] B`,
for a fixed pure tensor in the first argument,
as an `R`-linear map.
-/
def mulAux (a₁ : A) (b₁ : B) : A ⊗[R] B →ₗ[R] A ⊗[R] B :=
  TensorProduct.map (LinearMap.mulLeft R a₁) (LinearMap.mulLeft R b₁)
#align algebra.tensor_product.mul_aux Algebra.TensorProduct.mulAux
-/

#print Algebra.TensorProduct.mulAux_apply /-
@[simp]
theorem mulAux_apply (a₁ a₂ : A) (b₁ b₂ : B) :
    (mulAux a₁ b₁) (a₂ ⊗ₜ[R] b₂) = (a₁ * a₂) ⊗ₜ[R] (b₁ * b₂) :=
  rfl
#align algebra.tensor_product.mul_aux_apply Algebra.TensorProduct.mulAux_apply
-/

#print Algebra.TensorProduct.mul /-
/-- (Implementation detail)
The multiplication map on `A ⊗[R] B`,
as an `R`-bilinear map.
-/
def mul : A ⊗[R] B →ₗ[R] A ⊗[R] B →ₗ[R] A ⊗[R] B :=
  TensorProduct.lift <|
    LinearMap.mk₂ R mulAux
      (fun x₁ x₂ y =>
        TensorProduct.ext' fun x' y' => by
          simp only [mul_aux_apply, LinearMap.add_apply, add_mul, add_tmul])
      (fun c x y =>
        TensorProduct.ext' fun x' y' => by
          simp only [mul_aux_apply, LinearMap.smul_apply, smul_tmul', smul_mul_assoc])
      (fun x y₁ y₂ =>
        TensorProduct.ext' fun x' y' => by
          simp only [mul_aux_apply, LinearMap.add_apply, add_mul, tmul_add])
      fun c x y =>
      TensorProduct.ext' fun x' y' => by
        simp only [mul_aux_apply, LinearMap.smul_apply, smul_tmul, smul_tmul', smul_mul_assoc]
#align algebra.tensor_product.mul Algebra.TensorProduct.mul
-/

#print Algebra.TensorProduct.mul_apply /-
@[simp]
theorem mul_apply (a₁ a₂ : A) (b₁ b₂ : B) :
    mul (a₁ ⊗ₜ[R] b₁) (a₂ ⊗ₜ[R] b₂) = (a₁ * a₂) ⊗ₜ[R] (b₁ * b₂) :=
  rfl
#align algebra.tensor_product.mul_apply Algebra.TensorProduct.mul_apply
-/

#print Algebra.TensorProduct.mul_assoc' /-
theorem mul_assoc' (mul : A ⊗[R] B →ₗ[R] A ⊗[R] B →ₗ[R] A ⊗[R] B)
    (h :
      ∀ (a₁ a₂ a₃ : A) (b₁ b₂ b₃ : B),
        mul (mul (a₁ ⊗ₜ[R] b₁) (a₂ ⊗ₜ[R] b₂)) (a₃ ⊗ₜ[R] b₃) =
          mul (a₁ ⊗ₜ[R] b₁) (mul (a₂ ⊗ₜ[R] b₂) (a₃ ⊗ₜ[R] b₃))) :
    ∀ x y z : A ⊗[R] B, mul (mul x y) z = mul x (mul y z) :=
  by
  intros
  apply TensorProduct.induction_on x
  · simp only [LinearMap.map_zero, LinearMap.zero_apply]
  apply TensorProduct.induction_on y
  · simp only [LinearMap.map_zero, forall_const, LinearMap.zero_apply]
  apply TensorProduct.induction_on z
  · simp only [LinearMap.map_zero, forall_const]
  · intros; simp only [h]
  · intros; simp only [LinearMap.map_add, *]
  · intros; simp only [LinearMap.map_add, *, LinearMap.add_apply]
  · intros; simp only [LinearMap.map_add, *, LinearMap.add_apply]
#align algebra.tensor_product.mul_assoc' Algebra.TensorProduct.mul_assoc'
-/

#print Algebra.TensorProduct.mul_assoc /-
theorem mul_assoc (x y z : A ⊗[R] B) : mul (mul x y) z = mul x (mul y z) :=
  mul_assoc' mul (by intros; simp only [mul_apply, mul_assoc]) x y z
#align algebra.tensor_product.mul_assoc Algebra.TensorProduct.mul_assoc
-/

#print Algebra.TensorProduct.one_mul /-
theorem one_mul (x : A ⊗[R] B) : mul (1 ⊗ₜ 1) x = x := by
  apply TensorProduct.induction_on x <;> simp (config := { contextual := true })
#align algebra.tensor_product.one_mul Algebra.TensorProduct.one_mul
-/

#print Algebra.TensorProduct.mul_one /-
theorem mul_one (x : A ⊗[R] B) : mul x (1 ⊗ₜ 1) = x := by
  apply TensorProduct.induction_on x <;> simp (config := { contextual := true })
#align algebra.tensor_product.mul_one Algebra.TensorProduct.mul_one
-/

instance : One (A ⊗[R] B) where one := 1 ⊗ₜ 1

instance : AddMonoidWithOne (A ⊗[R] B) :=
  AddMonoidWithOne.unary

instance : Semiring (A ⊗[R] B) :=
  { (by infer_instance : AddMonoidWithOne (A ⊗[R] B)),
    (by infer_instance : AddCommMonoid
        (A ⊗[R] B)) with
    zero := 0
    add := (· + ·)
    one := 1
    mul := fun a b => mul a b
    one_mul := one_mul
    mul_one := mul_one
    mul_assoc := mul_assoc
    zero_mul := by simp
    mul_zero := by simp
    left_distrib := by simp
    right_distrib := by simp }

#print Algebra.TensorProduct.one_def /-
theorem one_def : (1 : A ⊗[R] B) = (1 : A) ⊗ₜ (1 : B) :=
  rfl
#align algebra.tensor_product.one_def Algebra.TensorProduct.one_def
-/

#print Algebra.TensorProduct.tmul_mul_tmul /-
@[simp]
theorem tmul_mul_tmul (a₁ a₂ : A) (b₁ b₂ : B) :
    a₁ ⊗ₜ[R] b₁ * a₂ ⊗ₜ[R] b₂ = (a₁ * a₂) ⊗ₜ[R] (b₁ * b₂) :=
  rfl
#align algebra.tensor_product.tmul_mul_tmul Algebra.TensorProduct.tmul_mul_tmul
-/

#print Algebra.TensorProduct.tmul_pow /-
@[simp]
theorem tmul_pow (a : A) (b : B) (k : ℕ) : a ⊗ₜ[R] b ^ k = (a ^ k) ⊗ₜ[R] (b ^ k) :=
  by
  induction' k with k ih
  · simp [one_def]
  · simp [pow_succ, ih]
#align algebra.tensor_product.tmul_pow Algebra.TensorProduct.tmul_pow
-/

#print Algebra.TensorProduct.includeLeftRingHom /-
/-- The ring morphism `A →+* A ⊗[R] B` sending `a` to `a ⊗ₜ 1`. -/
@[simps]
def includeLeftRingHom : A →+* A ⊗[R] B
    where
  toFun a := a ⊗ₜ 1
  map_zero' := by simp
  map_add' := by simp [add_tmul]
  map_one' := rfl
  map_mul' := by simp
#align algebra.tensor_product.include_left_ring_hom Algebra.TensorProduct.includeLeftRingHom
-/

variable {S : Type _} [CommSemiring S] [Algebra S A]

#print Algebra.TensorProduct.leftAlgebra /-
instance leftAlgebra [SMulCommClass R S A] : Algebra S (A ⊗[R] B) :=
  { TensorProduct.includeLeftRingHom.comp (algebraMap S A),
    (by infer_instance :
      Module S
        (A ⊗[R]
          B)) with
    commutes' := fun r x => by
      apply TensorProduct.induction_on x
      · simp
      · intro a b; dsimp; rw [Algebra.commutes, _root_.mul_one, _root_.one_mul]
      · intro y y' h h'; dsimp at h h' ⊢; simp only [mul_add, add_mul, h, h']
    smul_def' := fun r x => by
      apply TensorProduct.induction_on x
      · simp [smul_zero]
      · intro a b; dsimp; rw [TensorProduct.smul_tmul', Algebra.smul_def r a, _root_.one_mul]
      · intros; dsimp; simp [smul_add, mul_add, *] }
#align algebra.tensor_product.left_algebra Algebra.TensorProduct.leftAlgebra
-/

-- This is for the `undergrad.yaml` list.
/-- The tensor product of two `R`-algebras is an `R`-algebra. -/
instance : Algebra R (A ⊗[R] B) :=
  inferInstance

#print Algebra.TensorProduct.algebraMap_apply /-
@[simp]
theorem algebraMap_apply [SMulCommClass R S A] (r : S) :
    (algebraMap S (A ⊗[R] B)) r = (algebraMap S A) r ⊗ₜ 1 :=
  rfl
#align algebra.tensor_product.algebra_map_apply Algebra.TensorProduct.algebraMap_apply
-/

variable {C : Type v₃} [Semiring C] [Algebra R C]

#print Algebra.TensorProduct.ext /-
@[ext]
theorem ext {g h : A ⊗[R] B →ₐ[R] C} (H : ∀ a b, g (a ⊗ₜ b) = h (a ⊗ₜ b)) : g = h :=
  by
  apply @AlgHom.toLinearMap_injective R (A ⊗[R] B) C _ _ _ _ _ _ _ _
  ext
  simp [H]
#align algebra.tensor_product.ext Algebra.TensorProduct.ext
-/

#print Algebra.TensorProduct.includeLeft /-
-- TODO: with `smul_comm_class R S A` we can have this as an `S`-algebra morphism
/-- The `R`-algebra morphism `A →ₐ[R] A ⊗[R] B` sending `a` to `a ⊗ₜ 1`. -/
def includeLeft : A →ₐ[R] A ⊗[R] B :=
  { includeLeftRingHom with commutes' := by simp }
#align algebra.tensor_product.include_left Algebra.TensorProduct.includeLeft
-/

#print Algebra.TensorProduct.includeLeft_apply /-
@[simp]
theorem includeLeft_apply (a : A) : (includeLeft : A →ₐ[R] A ⊗[R] B) a = a ⊗ₜ 1 :=
  rfl
#align algebra.tensor_product.include_left_apply Algebra.TensorProduct.includeLeft_apply
-/

#print Algebra.TensorProduct.includeRight /-
/-- The algebra morphism `B →ₐ[R] A ⊗[R] B` sending `b` to `1 ⊗ₜ b`. -/
def includeRight : B →ₐ[R] A ⊗[R] B where
  toFun b := 1 ⊗ₜ b
  map_zero' := by simp
  map_add' := by simp [tmul_add]
  map_one' := rfl
  map_mul' := by simp
  commutes' r := by
    simp only [algebraMap_apply]
    trans r • (1 : A) ⊗ₜ[R] (1 : B)
    · rw [← tmul_smul, Algebra.smul_def]; simp
    · simp [Algebra.smul_def]
#align algebra.tensor_product.include_right Algebra.TensorProduct.includeRight
-/

#print Algebra.TensorProduct.includeRight_apply /-
@[simp]
theorem includeRight_apply (b : B) : (includeRight : B →ₐ[R] A ⊗[R] B) b = 1 ⊗ₜ b :=
  rfl
#align algebra.tensor_product.include_right_apply Algebra.TensorProduct.includeRight_apply
-/

#print Algebra.TensorProduct.includeLeft_comp_algebraMap /-
theorem includeLeft_comp_algebraMap {R S T : Type _} [CommRing R] [CommRing S] [CommRing T]
    [Algebra R S] [Algebra R T] :
    (includeLeft.toRingHom.comp (algebraMap R S) : R →+* S ⊗[R] T) =
      includeRight.toRingHom.comp (algebraMap R T) :=
  by ext; simp
#align algebra.tensor_product.include_left_comp_algebra_map Algebra.TensorProduct.includeLeft_comp_algebraMap
-/

end Semiring

section Ring

variable {R : Type u} [CommRing R]

variable {A : Type v₁} [Ring A] [Algebra R A]

variable {B : Type v₂} [Ring B] [Algebra R B]

instance : Ring (A ⊗[R] B) :=
  { (by infer_instance : AddCommGroup (A ⊗[R] B)), (by infer_instance : Semiring (A ⊗[R] B)) with }

end Ring

section CommRing

variable {R : Type u} [CommRing R]

variable {A : Type v₁} [CommRing A] [Algebra R A]

variable {B : Type v₂} [CommRing B] [Algebra R B]

instance : CommRing (A ⊗[R] B) :=
  { (by infer_instance : Ring (A ⊗[R] B)) with
    mul_comm := fun x y => by
      apply TensorProduct.induction_on x
      · simp
      · intro a₁ b₁
        apply TensorProduct.induction_on y
        · simp
        · intro a₂ b₂
          simp [mul_comm]
        · intro a₂ b₂ ha hb
          simp [mul_add, add_mul, ha, hb]
      · intro x₁ x₂ h₁ h₂
        simp [mul_add, add_mul, h₁, h₂] }

section RightAlgebra

#print Algebra.TensorProduct.rightAlgebra /-
/-- `S ⊗[R] T` has a `T`-algebra structure. This is not a global instance or else the action of
`S` on `S ⊗[R] S` would be ambiguous. -/
@[reducible]
def rightAlgebra : Algebra B (A ⊗[R] B) :=
  (Algebra.TensorProduct.includeRight.toRingHom : B →+* A ⊗[R] B).toAlgebra
#align algebra.tensor_product.right_algebra Algebra.TensorProduct.rightAlgebra
-/

attribute [local instance] tensor_product.right_algebra

#print Algebra.TensorProduct.right_isScalarTower /-
instance right_isScalarTower : IsScalarTower R B (A ⊗[R] B) :=
  IsScalarTower.of_algebraMap_eq fun r => (Algebra.TensorProduct.includeRight.commutes r).symm
#align algebra.tensor_product.right_is_scalar_tower Algebra.TensorProduct.right_isScalarTower
-/

end RightAlgebra

end CommRing

/-- Verify that typeclass search finds the ring structure on `A ⊗[ℤ] B`
when `A` and `B` are merely rings, by treating both as `ℤ`-algebras.
-/
example {A : Type v₁} [Ring A] {B : Type v₂} [Ring B] : Ring (A ⊗[ℤ] B) := by infer_instance

/-- Verify that typeclass search finds the comm_ring structure on `A ⊗[ℤ] B`
when `A` and `B` are merely comm_rings, by treating both as `ℤ`-algebras.
-/
example {A : Type v₁} [CommRing A] {B : Type v₂} [CommRing B] : CommRing (A ⊗[ℤ] B) := by
  infer_instance

/-!
We now build the structure maps for the symmetric monoidal category of `R`-algebras.
-/


section Monoidal

section

variable {R : Type u} [CommSemiring R]

variable {A : Type v₁} [Semiring A] [Algebra R A]

variable {B : Type v₂} [Semiring B] [Algebra R B]

variable {C : Type v₃} [Semiring C] [Algebra R C]

variable {D : Type v₄} [Semiring D] [Algebra R D]

#print Algebra.TensorProduct.algHomOfLinearMapTensorProduct /-
/-- Build an algebra morphism from a linear map out of a tensor product,
and evidence of multiplicativity on pure tensors.
-/
def algHomOfLinearMapTensorProduct (f : A ⊗[R] B →ₗ[R] C)
    (w₁ : ∀ (a₁ a₂ : A) (b₁ b₂ : B), f ((a₁ * a₂) ⊗ₜ (b₁ * b₂)) = f (a₁ ⊗ₜ b₁) * f (a₂ ⊗ₜ b₂))
    (w₂ : ∀ r, f ((algebraMap R A) r ⊗ₜ[R] 1) = (algebraMap R C) r) : A ⊗[R] B →ₐ[R] C :=
  {
    f with
    map_one' := by rw [← (algebraMap R C).map_one, ← w₂, (algebraMap R A).map_one] <;> rfl
    map_zero' := by rw [LinearMap.toFun_eq_coe, map_zero]
    map_mul' := fun x y => by
      rw [LinearMap.toFun_eq_coe]
      apply TensorProduct.induction_on x
      · rw [MulZeroClass.zero_mul, map_zero, MulZeroClass.zero_mul]
      · intro a₁ b₁
        apply TensorProduct.induction_on y
        · rw [MulZeroClass.mul_zero, map_zero, MulZeroClass.mul_zero]
        · intro a₂ b₂
          rw [tmul_mul_tmul, w₁]
        · intro x₁ x₂ h₁ h₂
          rw [mul_add, map_add, map_add, mul_add, h₁, h₂]
      · intro x₁ x₂ h₁ h₂
        rw [add_mul, map_add, map_add, add_mul, h₁, h₂]
    commutes' := fun r => by rw [LinearMap.toFun_eq_coe, algebraMap_apply, w₂] }
#align algebra.tensor_product.alg_hom_of_linear_map_tensor_product Algebra.TensorProduct.algHomOfLinearMapTensorProduct
-/

#print Algebra.TensorProduct.algHomOfLinearMapTensorProduct_apply /-
@[simp]
theorem algHomOfLinearMapTensorProduct_apply (f w₁ w₂ x) :
    (algHomOfLinearMapTensorProduct f w₁ w₂ : A ⊗[R] B →ₐ[R] C) x = f x :=
  rfl
#align algebra.tensor_product.alg_hom_of_linear_map_tensor_product_apply Algebra.TensorProduct.algHomOfLinearMapTensorProduct_apply
-/

#print Algebra.TensorProduct.algEquivOfLinearEquivTensorProduct /-
/-- Build an algebra equivalence from a linear equivalence out of a tensor product,
and evidence of multiplicativity on pure tensors.
-/
def algEquivOfLinearEquivTensorProduct (f : A ⊗[R] B ≃ₗ[R] C)
    (w₁ : ∀ (a₁ a₂ : A) (b₁ b₂ : B), f ((a₁ * a₂) ⊗ₜ (b₁ * b₂)) = f (a₁ ⊗ₜ b₁) * f (a₂ ⊗ₜ b₂))
    (w₂ : ∀ r, f ((algebraMap R A) r ⊗ₜ[R] 1) = (algebraMap R C) r) : A ⊗[R] B ≃ₐ[R] C :=
  { algHomOfLinearMapTensorProduct (f : A ⊗[R] B →ₗ[R] C) w₁ w₂, f with }
#align algebra.tensor_product.alg_equiv_of_linear_equiv_tensor_product Algebra.TensorProduct.algEquivOfLinearEquivTensorProduct
-/

#print Algebra.TensorProduct.algEquivOfLinearEquivTensorProduct_apply /-
@[simp]
theorem algEquivOfLinearEquivTensorProduct_apply (f w₁ w₂ x) :
    (algEquivOfLinearEquivTensorProduct f w₁ w₂ : A ⊗[R] B ≃ₐ[R] C) x = f x :=
  rfl
#align algebra.tensor_product.alg_equiv_of_linear_equiv_tensor_product_apply Algebra.TensorProduct.algEquivOfLinearEquivTensorProduct_apply
-/

#print Algebra.TensorProduct.algEquivOfLinearEquivTripleTensorProduct /-
/-- Build an algebra equivalence from a linear equivalence out of a triple tensor product,
and evidence of multiplicativity on pure tensors.
-/
def algEquivOfLinearEquivTripleTensorProduct (f : (A ⊗[R] B) ⊗[R] C ≃ₗ[R] D)
    (w₁ :
      ∀ (a₁ a₂ : A) (b₁ b₂ : B) (c₁ c₂ : C),
        f ((a₁ * a₂) ⊗ₜ (b₁ * b₂) ⊗ₜ (c₁ * c₂)) = f (a₁ ⊗ₜ b₁ ⊗ₜ c₁) * f (a₂ ⊗ₜ b₂ ⊗ₜ c₂))
    (w₂ : ∀ r, f (((algebraMap R A) r ⊗ₜ[R] (1 : B)) ⊗ₜ[R] (1 : C)) = (algebraMap R D) r) :
    (A ⊗[R] B) ⊗[R] C ≃ₐ[R] D :=
  { f with
    toFun := f
    map_mul' := fun x y => by
      apply TensorProduct.induction_on x
      · simp only [map_zero, MulZeroClass.zero_mul]
      · intro ab₁ c₁
        apply TensorProduct.induction_on y
        · simp only [map_zero, MulZeroClass.mul_zero]
        · intro ab₂ c₂
          apply TensorProduct.induction_on ab₁
          · simp only [zero_tmul, map_zero, MulZeroClass.zero_mul]
          · intro a₁ b₁
            apply TensorProduct.induction_on ab₂
            · simp only [zero_tmul, map_zero, MulZeroClass.mul_zero]
            · intros; simp only [tmul_mul_tmul, w₁]
            · intro x₁ x₂ h₁ h₂
              simp only [tmul_mul_tmul] at h₁ h₂ 
              simp only [tmul_mul_tmul, mul_add, add_tmul, map_add, h₁, h₂]
          · intro x₁ x₂ h₁ h₂
            simp only [tmul_mul_tmul] at h₁ h₂ 
            simp only [tmul_mul_tmul, add_mul, add_tmul, map_add, h₁, h₂]
        · intro x₁ x₂ h₁ h₂
          simp only [tmul_mul_tmul, map_add, mul_add, add_mul, h₁, h₂]
      · intro x₁ x₂ h₁ h₂
        simp only [tmul_mul_tmul, map_add, mul_add, add_mul, h₁, h₂]
    commutes' := fun r => by simp [w₂] }
#align algebra.tensor_product.alg_equiv_of_linear_equiv_triple_tensor_product Algebra.TensorProduct.algEquivOfLinearEquivTripleTensorProduct
-/

#print Algebra.TensorProduct.algEquivOfLinearEquivTripleTensorProduct_apply /-
@[simp]
theorem algEquivOfLinearEquivTripleTensorProduct_apply (f w₁ w₂ x) :
    (algEquivOfLinearEquivTripleTensorProduct f w₁ w₂ : (A ⊗[R] B) ⊗[R] C ≃ₐ[R] D) x = f x :=
  rfl
#align algebra.tensor_product.alg_equiv_of_linear_equiv_triple_tensor_product_apply Algebra.TensorProduct.algEquivOfLinearEquivTripleTensorProduct_apply
-/

end

variable {R : Type u} [CommSemiring R]

variable {A : Type v₁} [Semiring A] [Algebra R A]

variable {B : Type v₂} [Semiring B] [Algebra R B]

variable {C : Type v₃} [Semiring C] [Algebra R C]

variable {D : Type v₄} [Semiring D] [Algebra R D]

section

variable (R A)

#print Algebra.TensorProduct.lid /-
/-- The base ring is a left identity for the tensor product of algebra, up to algebra isomorphism.
-/
protected def lid : R ⊗[R] A ≃ₐ[R] A :=
  algEquivOfLinearEquivTensorProduct (TensorProduct.lid R A) (by simp [mul_smul])
    (by simp [Algebra.smul_def])
#align algebra.tensor_product.lid Algebra.TensorProduct.lid
-/

#print Algebra.TensorProduct.lid_tmul /-
@[simp]
theorem lid_tmul (r : R) (a : A) : (TensorProduct.lid R A : R ⊗ A → A) (r ⊗ₜ a) = r • a := by
  simp [TensorProduct.lid]
#align algebra.tensor_product.lid_tmul Algebra.TensorProduct.lid_tmul
-/

#print Algebra.TensorProduct.rid /-
/-- The base ring is a right identity for the tensor product of algebra, up to algebra isomorphism.
-/
protected def rid : A ⊗[R] R ≃ₐ[R] A :=
  algEquivOfLinearEquivTensorProduct (TensorProduct.rid R A) (by simp [mul_smul])
    (by simp [Algebra.smul_def])
#align algebra.tensor_product.rid Algebra.TensorProduct.rid
-/

#print Algebra.TensorProduct.rid_tmul /-
@[simp]
theorem rid_tmul (r : R) (a : A) : (TensorProduct.rid R A : A ⊗ R → A) (a ⊗ₜ r) = r • a := by
  simp [TensorProduct.rid]
#align algebra.tensor_product.rid_tmul Algebra.TensorProduct.rid_tmul
-/

section

variable (R A B)

#print Algebra.TensorProduct.comm /-
/-- The tensor product of R-algebras is commutative, up to algebra isomorphism.
-/
protected def comm : A ⊗[R] B ≃ₐ[R] B ⊗[R] A :=
  algEquivOfLinearEquivTensorProduct (TensorProduct.comm R A B) (by simp) fun r =>
    by
    trans r • (1 : B) ⊗ₜ[R] (1 : A)
    · rw [← tmul_smul, Algebra.smul_def]; simp
    · simp [Algebra.smul_def]
#align algebra.tensor_product.comm Algebra.TensorProduct.comm
-/

#print Algebra.TensorProduct.comm_tmul /-
@[simp]
theorem comm_tmul (a : A) (b : B) :
    (TensorProduct.comm R A B : A ⊗[R] B → B ⊗[R] A) (a ⊗ₜ b) = b ⊗ₜ a := by
  simp [TensorProduct.comm]
#align algebra.tensor_product.comm_tmul Algebra.TensorProduct.comm_tmul
-/

#print Algebra.TensorProduct.adjoin_tmul_eq_top /-
theorem adjoin_tmul_eq_top : adjoin R {t : A ⊗[R] B | ∃ a b, a ⊗ₜ[R] b = t} = ⊤ :=
  top_le_iff.mp <| (top_le_iff.mpr <| span_tmul_eq_top R A B).trans (span_le_adjoin R _)
#align algebra.tensor_product.adjoin_tmul_eq_top Algebra.TensorProduct.adjoin_tmul_eq_top
-/

end

section

variable {R A B C}

#print Algebra.TensorProduct.assoc_aux_1 /-
theorem assoc_aux_1 (a₁ a₂ : A) (b₁ b₂ : B) (c₁ c₂ : C) :
    (TensorProduct.assoc R A B C) (((a₁ * a₂) ⊗ₜ[R] (b₁ * b₂)) ⊗ₜ[R] (c₁ * c₂)) =
      (TensorProduct.assoc R A B C) ((a₁ ⊗ₜ[R] b₁) ⊗ₜ[R] c₁) *
        (TensorProduct.assoc R A B C) ((a₂ ⊗ₜ[R] b₂) ⊗ₜ[R] c₂) :=
  rfl
#align algebra.tensor_product.assoc_aux_1 Algebra.TensorProduct.assoc_aux_1
-/

#print Algebra.TensorProduct.assoc_aux_2 /-
theorem assoc_aux_2 (r : R) :
    (TensorProduct.assoc R A B C) (((algebraMap R A) r ⊗ₜ[R] 1) ⊗ₜ[R] 1) =
      (algebraMap R (A ⊗ (B ⊗ C))) r :=
  rfl
#align algebra.tensor_product.assoc_aux_2 Algebra.TensorProduct.assoc_aux_2
-/

variable (R A B C)

#print Algebra.TensorProduct.assoc /-
/-- The associator for tensor product of R-algebras, as an algebra isomorphism. -/
protected def assoc : (A ⊗[R] B) ⊗[R] C ≃ₐ[R] A ⊗[R] B ⊗[R] C :=
  algEquivOfLinearEquivTripleTensorProduct
    (TensorProduct.assoc.{u, v₁, v₂, v₃} R A B C : A ⊗ B ⊗ C ≃ₗ[R] A ⊗ (B ⊗ C))
    (@Algebra.TensorProduct.assoc_aux_1.{u, v₁, v₂, v₃} R _ A _ _ B _ _ C _ _)
    (@Algebra.TensorProduct.assoc_aux_2.{u, v₁, v₂, v₃} R _ A _ _ B _ _ C _ _)
#align algebra.tensor_product.assoc Algebra.TensorProduct.assoc
-/

variable {R A B C}

#print Algebra.TensorProduct.assoc_tmul /-
@[simp]
theorem assoc_tmul (a : A) (b : B) (c : C) :
    (TensorProduct.assoc R A B C : (A ⊗[R] B) ⊗[R] C → A ⊗[R] B ⊗[R] C) (a ⊗ₜ b ⊗ₜ c) =
      a ⊗ₜ (b ⊗ₜ c) :=
  rfl
#align algebra.tensor_product.assoc_tmul Algebra.TensorProduct.assoc_tmul
-/

end

variable {R A B C D}

#print Algebra.TensorProduct.map /-
/-- The tensor product of a pair of algebra morphisms. -/
def map (f : A →ₐ[R] B) (g : C →ₐ[R] D) : A ⊗[R] C →ₐ[R] B ⊗[R] D :=
  algHomOfLinearMapTensorProduct (TensorProduct.map f.toLinearMap g.toLinearMap) (by simp)
    (by simp [AlgHom.commutes])
#align algebra.tensor_product.map Algebra.TensorProduct.map
-/

#print Algebra.TensorProduct.map_tmul /-
@[simp]
theorem map_tmul (f : A →ₐ[R] B) (g : C →ₐ[R] D) (a : A) (c : C) : map f g (a ⊗ₜ c) = f a ⊗ₜ g c :=
  rfl
#align algebra.tensor_product.map_tmul Algebra.TensorProduct.map_tmul
-/

#print Algebra.TensorProduct.map_comp_includeLeft /-
@[simp]
theorem map_comp_includeLeft (f : A →ₐ[R] B) (g : C →ₐ[R] D) :
    (map f g).comp includeLeft = includeLeft.comp f :=
  AlgHom.ext <| by simp
#align algebra.tensor_product.map_comp_include_left Algebra.TensorProduct.map_comp_includeLeft
-/

#print Algebra.TensorProduct.map_comp_includeRight /-
@[simp]
theorem map_comp_includeRight (f : A →ₐ[R] B) (g : C →ₐ[R] D) :
    (map f g).comp includeRight = includeRight.comp g :=
  AlgHom.ext <| by simp
#align algebra.tensor_product.map_comp_include_right Algebra.TensorProduct.map_comp_includeRight
-/

#print Algebra.TensorProduct.map_range /-
theorem map_range (f : A →ₐ[R] B) (g : C →ₐ[R] D) :
    (map f g).range = (includeLeft.comp f).range ⊔ (includeRight.comp g).range :=
  by
  apply le_antisymm
  · rw [← map_top, ← adjoin_tmul_eq_top, ← adjoin_image, adjoin_le_iff]
    rintro _ ⟨_, ⟨a, b, rfl⟩, rfl⟩
    rw [map_tmul, ← _root_.mul_one (f a), ← _root_.one_mul (g b), ← tmul_mul_tmul]
    exact mul_mem_sup (AlgHom.mem_range_self _ a) (AlgHom.mem_range_self _ b)
  · rw [← map_comp_include_left f g, ← map_comp_include_right f g]
    exact sup_le (AlgHom.range_comp_le_range _ _) (AlgHom.range_comp_le_range _ _)
#align algebra.tensor_product.map_range Algebra.TensorProduct.map_range
-/

#print Algebra.TensorProduct.congr /-
/-- Construct an isomorphism between tensor products of R-algebras
from isomorphisms between the tensor factors.
-/
def congr (f : A ≃ₐ[R] B) (g : C ≃ₐ[R] D) : A ⊗[R] C ≃ₐ[R] B ⊗[R] D :=
  AlgEquiv.ofAlgHom (map f g) (map f.symm g.symm) (ext fun b d => by simp) (ext fun a c => by simp)
#align algebra.tensor_product.congr Algebra.TensorProduct.congr
-/

#print Algebra.TensorProduct.congr_apply /-
@[simp]
theorem congr_apply (f : A ≃ₐ[R] B) (g : C ≃ₐ[R] D) (x) :
    congr f g x = (map (f : A →ₐ[R] B) (g : C →ₐ[R] D)) x :=
  rfl
#align algebra.tensor_product.congr_apply Algebra.TensorProduct.congr_apply
-/

#print Algebra.TensorProduct.congr_symm_apply /-
@[simp]
theorem congr_symm_apply (f : A ≃ₐ[R] B) (g : C ≃ₐ[R] D) (x) :
    (congr f g).symm x = (map (f.symm : B →ₐ[R] A) (g.symm : D →ₐ[R] C)) x :=
  rfl
#align algebra.tensor_product.congr_symm_apply Algebra.TensorProduct.congr_symm_apply
-/

end

end Monoidal

section

variable {R A B S : Type _} [CommSemiring R] [Semiring A] [Semiring B] [CommSemiring S]

variable [Algebra R A] [Algebra R B] [Algebra R S]

variable (f : A →ₐ[R] S) (g : B →ₐ[R] S)

variable (R)

#print Algebra.TensorProduct.lmul' /-
/-- `linear_map.mul'` is an alg_hom on commutative rings. -/
def lmul' : S ⊗[R] S →ₐ[R] S :=
  algHomOfLinearMapTensorProduct (LinearMap.mul' R S)
    (fun a₁ a₂ b₁ b₂ => by simp only [LinearMap.mul'_apply, mul_mul_mul_comm]) fun r => by
    simp only [LinearMap.mul'_apply, _root_.mul_one]
#align algebra.tensor_product.lmul' Algebra.TensorProduct.lmul'
-/

variable {R}

#print Algebra.TensorProduct.lmul'_toLinearMap /-
theorem lmul'_toLinearMap : (lmul' R : _ →ₐ[R] S).toLinearMap = LinearMap.mul' R S :=
  rfl
#align algebra.tensor_product.lmul'_to_linear_map Algebra.TensorProduct.lmul'_toLinearMap
-/

#print Algebra.TensorProduct.lmul'_apply_tmul /-
@[simp]
theorem lmul'_apply_tmul (a b : S) : lmul' R (a ⊗ₜ[R] b) = a * b :=
  rfl
#align algebra.tensor_product.lmul'_apply_tmul Algebra.TensorProduct.lmul'_apply_tmul
-/

#print Algebra.TensorProduct.lmul'_comp_includeLeft /-
@[simp]
theorem lmul'_comp_includeLeft : (lmul' R : _ →ₐ[R] S).comp includeLeft = AlgHom.id R S :=
  AlgHom.ext <| mul_one
#align algebra.tensor_product.lmul'_comp_include_left Algebra.TensorProduct.lmul'_comp_includeLeft
-/

#print Algebra.TensorProduct.lmul'_comp_includeRight /-
@[simp]
theorem lmul'_comp_includeRight : (lmul' R : _ →ₐ[R] S).comp includeRight = AlgHom.id R S :=
  AlgHom.ext <| one_mul
#align algebra.tensor_product.lmul'_comp_include_right Algebra.TensorProduct.lmul'_comp_includeRight
-/

#print Algebra.TensorProduct.productMap /-
/-- If `S` is commutative, for a pair of morphisms `f : A →ₐ[R] S`, `g : B →ₐ[R] S`,
We obtain a map `A ⊗[R] B →ₐ[R] S` that commutes with `f`, `g` via `a ⊗ b ↦ f(a) * g(b)`.
-/
def productMap : A ⊗[R] B →ₐ[R] S :=
  (lmul' R).comp (TensorProduct.map f g)
#align algebra.tensor_product.product_map Algebra.TensorProduct.productMap
-/

#print Algebra.TensorProduct.productMap_apply_tmul /-
@[simp]
theorem productMap_apply_tmul (a : A) (b : B) : productMap f g (a ⊗ₜ b) = f a * g b := by
  unfold product_map lmul'; simp
#align algebra.tensor_product.product_map_apply_tmul Algebra.TensorProduct.productMap_apply_tmul
-/

#print Algebra.TensorProduct.productMap_left_apply /-
theorem productMap_left_apply (a : A) : productMap f g ((includeLeft : A →ₐ[R] A ⊗ B) a) = f a := by
  simp
#align algebra.tensor_product.product_map_left_apply Algebra.TensorProduct.productMap_left_apply
-/

#print Algebra.TensorProduct.productMap_left /-
@[simp]
theorem productMap_left : (productMap f g).comp includeLeft = f :=
  AlgHom.ext <| by simp
#align algebra.tensor_product.product_map_left Algebra.TensorProduct.productMap_left
-/

#print Algebra.TensorProduct.productMap_right_apply /-
theorem productMap_right_apply (b : B) : productMap f g (includeRight b) = g b := by simp
#align algebra.tensor_product.product_map_right_apply Algebra.TensorProduct.productMap_right_apply
-/

#print Algebra.TensorProduct.productMap_right /-
@[simp]
theorem productMap_right : (productMap f g).comp includeRight = g :=
  AlgHom.ext <| by simp
#align algebra.tensor_product.product_map_right Algebra.TensorProduct.productMap_right
-/

#print Algebra.TensorProduct.productMap_range /-
theorem productMap_range : (productMap f g).range = f.range ⊔ g.range := by
  rw [product_map, AlgHom.range_comp, map_range, map_sup, ← AlgHom.range_comp, ← AlgHom.range_comp,
    ← AlgHom.comp_assoc, ← AlgHom.comp_assoc, lmul'_comp_include_left, lmul'_comp_include_right,
    AlgHom.id_comp, AlgHom.id_comp]
#align algebra.tensor_product.product_map_range Algebra.TensorProduct.productMap_range
-/

end

section

variable {R A A' B S : Type _}

variable [CommSemiring R] [CommSemiring A] [Semiring A'] [Semiring B] [CommSemiring S]

variable [Algebra R A] [Algebra R A'] [Algebra A A'] [IsScalarTower R A A'] [Algebra R B]

variable [Algebra R S] [Algebra A S] [IsScalarTower R A S]

#print Algebra.TensorProduct.productLeftAlgHom /-
/-- If `A`, `B` are `R`-algebras, `A'` is an `A`-algebra, then the product map of `f : A' →ₐ[A] S`
and `g : B →ₐ[R] S` is an `A`-algebra homomorphism. -/
@[simps]
def productLeftAlgHom (f : A' →ₐ[A] S) (g : B →ₐ[R] S) : A' ⊗[R] B →ₐ[A] S :=
  { (productMap (f.restrictScalars R) g).toRingHom with commutes' := fun r => by dsimp; simp }
#align algebra.tensor_product.product_left_alg_hom Algebra.TensorProduct.productLeftAlgHom
-/

end

section Basis

variable {k : Type _} [CommRing k] (R : Type _) [Ring R] [Algebra k R] {M : Type _}
  [AddCommMonoid M] [Module k M] {ι : Type _} (b : Basis ι k M)

#print Algebra.TensorProduct.basisAux /-
/-- Given a `k`-algebra `R` and a `k`-basis of `M,` this is a `k`-linear isomorphism
`R ⊗[k] M ≃ (ι →₀ R)` (which is in fact `R`-linear). -/
noncomputable def basisAux : R ⊗[k] M ≃ₗ[k] ι →₀ R :=
  TensorProduct.congr (Finsupp.LinearEquiv.finsuppUnique k R PUnit).symm b.repr ≪≫ₗ
    (finsuppTensorFinsupp k R k PUnit ι).trans
      (Finsupp.lcongr (Equiv.uniqueProd ι PUnit) (TensorProduct.rid k R))
#align algebra.tensor_product.basis_aux Algebra.TensorProduct.basisAux
-/

variable {R}

#print Algebra.TensorProduct.basisAux_tmul /-
theorem basisAux_tmul (r : R) (m : M) :
    basisAux R b (r ⊗ₜ m) = r • Finsupp.mapRange (algebraMap k R) (map_zero _) (b.repr m) :=
  by
  ext
  simp [basis_aux, ← Algebra.commutes, Algebra.smul_def]
#align algebra.tensor_product.basis_aux_tmul Algebra.TensorProduct.basisAux_tmul
-/

#print Algebra.TensorProduct.basisAux_map_smul /-
theorem basisAux_map_smul (r : R) (x : R ⊗[k] M) : basisAux R b (r • x) = r • basisAux R b x :=
  TensorProduct.induction_on x (by simp)
    (fun x y => by simp only [TensorProduct.smul_tmul', basis_aux_tmul, smul_assoc])
    fun x y hx hy => by simp [hx, hy]
#align algebra.tensor_product.basis_aux_map_smul Algebra.TensorProduct.basisAux_map_smul
-/

variable (R)

#print Algebra.TensorProduct.basis /-
/-- Given a `k`-algebra `R`, this is the `R`-basis of `R ⊗[k] M` induced by a `k`-basis of `M`. -/
noncomputable def basis : Basis ι R (R ⊗[k] M)
    where repr := { basisAux R b with map_smul' := basisAux_map_smul b }
#align algebra.tensor_product.basis Algebra.TensorProduct.basis
-/

variable {R}

#print Algebra.TensorProduct.basis_repr_tmul /-
@[simp]
theorem basis_repr_tmul (r : R) (m : M) :
    (basis R b).repr (r ⊗ₜ m) = r • Finsupp.mapRange (algebraMap k R) (map_zero _) (b.repr m) :=
  basisAux_tmul _ _ _
#align algebra.tensor_product.basis_repr_tmul Algebra.TensorProduct.basis_repr_tmul
-/

#print Algebra.TensorProduct.basis_repr_symm_apply /-
@[simp]
theorem basis_repr_symm_apply (r : R) (i : ι) :
    (basis R b).repr.symm (Finsupp.single i r) = r ⊗ₜ b.repr.symm (Finsupp.single i 1) := by
  simp [Basis, Equiv.uniqueProd_symm_apply, basis_aux]
#align algebra.tensor_product.basis_repr_symm_apply Algebra.TensorProduct.basis_repr_symm_apply
-/

end Basis

end TensorProduct

end Algebra

namespace Module

variable {R M N : Type _} [CommSemiring R]

variable [AddCommMonoid M] [AddCommMonoid N]

variable [Module R M] [Module R N]

#print Module.endTensorEndAlgHom /-
/-- The algebra homomorphism from `End M ⊗ End N` to `End (M ⊗ N)` sending `f ⊗ₜ g` to
the `tensor_product.map f g`, the tensor product of the two maps. -/
def endTensorEndAlgHom : End R M ⊗[R] End R N →ₐ[R] End R (M ⊗[R] N) :=
  by
  refine' Algebra.TensorProduct.algHomOfLinearMapTensorProduct (hom_tensor_hom_map R M N M N) _ _
  · intro f₁ f₂ g₁ g₂
    simp only [hom_tensor_hom_map_apply, TensorProduct.map_mul]
  · intro r
    simp only [hom_tensor_hom_map_apply]
    ext m n; simp [smul_tmul]
#align module.End_tensor_End_alg_hom Module.endTensorEndAlgHom
-/

#print Module.endTensorEndAlgHom_apply /-
theorem endTensorEndAlgHom_apply (f : End R M) (g : End R N) :
    endTensorEndAlgHom (f ⊗ₜ[R] g) = TensorProduct.map f g := by
  simp only [End_tensor_End_alg_hom, Algebra.TensorProduct.algHomOfLinearMapTensorProduct_apply,
    hom_tensor_hom_map_apply]
#align module.End_tensor_End_alg_hom_apply Module.endTensorEndAlgHom_apply
-/

end Module

#print Subalgebra.finiteDimensional_sup /-
theorem Subalgebra.finiteDimensional_sup {K L : Type _} [Field K] [CommRing L] [Algebra K L]
    (E1 E2 : Subalgebra K L) [FiniteDimensional K E1] [FiniteDimensional K E2] :
    FiniteDimensional K ↥(E1 ⊔ E2) :=
  by
  rw [← E1.range_val, ← E2.range_val, ← Algebra.TensorProduct.productMap_range]
  exact (Algebra.TensorProduct.productMap E1.val E2.val).toLinearMap.finiteDimensional_range
#align subalgebra.finite_dimensional_sup Subalgebra.finiteDimensional_sup
-/

namespace TensorProduct.Algebra

variable {R A B M : Type _}

variable [CommSemiring R] [AddCommMonoid M] [Module R M]

variable [Semiring A] [Semiring B] [Module A M] [Module B M]

variable [Algebra R A] [Algebra R B]

variable [IsScalarTower R A M] [IsScalarTower R B M]

#print TensorProduct.Algebra.moduleAux /-
/-- An auxiliary definition, used for constructing the `module (A ⊗[R] B) M` in
`tensor_product.algebra.module` below. -/
def moduleAux : A ⊗[R] B →ₗ[R] M →ₗ[R] M :=
  TensorProduct.lift
    { toFun := fun a => a • (Algebra.lsmul R M : B →ₐ[R] Module.End R M).toLinearMap
      map_add' := fun r t => by ext; simp only [add_smul, LinearMap.add_apply]
      map_smul' := fun n r => by ext;
        simp only [RingHom.id_apply, LinearMap.smul_apply, smul_assoc] }
#align tensor_product.algebra.module_aux TensorProduct.Algebra.moduleAux
-/

#print TensorProduct.Algebra.moduleAux_apply /-
theorem moduleAux_apply (a : A) (b : B) (m : M) : moduleAux (a ⊗ₜ[R] b) m = a • b • m :=
  rfl
#align tensor_product.algebra.module_aux_apply TensorProduct.Algebra.moduleAux_apply
-/

variable [SMulCommClass A B M]

#print TensorProduct.Algebra.module /-
/-- If `M` is a representation of two different `R`-algebras `A` and `B` whose actions commute,
then it is a representation the `R`-algebra `A ⊗[R] B`.

An important example arises from a semiring `S`; allowing `S` to act on itself via left and right
multiplication, the roles of `R`, `A`, `B`, `M` are played by `ℕ`, `S`, `Sᵐᵒᵖ`, `S`. This example
is important because a submodule of `S` as a `module` over `S ⊗[ℕ] Sᵐᵒᵖ` is a two-sided ideal.

NB: This is not an instance because in the case `B = A` and `M = A ⊗[R] A` we would have a diamond
of `smul` actions. Furthermore, this would not be a mere definitional diamond but a true
mathematical diamond in which `A ⊗[R] A` had two distinct scalar actions on itself: one from its
multiplication, and one from this would-be instance. Arguably we could live with this but in any
case the real fix is to address the ambiguity in notation, probably along the lines outlined here:
https://leanprover.zulipchat.com/#narrow/stream/144837-PR-reviews/topic/.234773.20base.20change/near/240929258
-/
protected def module : Module (A ⊗[R] B) M
    where
  smul x m := moduleAux x m
  zero_smul m := by simp only [map_zero, LinearMap.zero_apply]
  smul_zero x := by simp only [map_zero]
  smul_add x m₁ m₂ := by simp only [map_add]
  add_smul x y m := by simp only [map_add, LinearMap.add_apply]
  one_smul m := by simp only [module_aux_apply, Algebra.TensorProduct.one_def, one_smul]
  mul_smul x y m :=
    by
    apply TensorProduct.induction_on x <;> apply TensorProduct.induction_on y
    · simp only [MulZeroClass.mul_zero, map_zero, LinearMap.zero_apply]
    · intro a b; simp only [MulZeroClass.zero_mul, map_zero, LinearMap.zero_apply]
    · intro z w hz hw; simp only [MulZeroClass.zero_mul, map_zero, LinearMap.zero_apply]
    · intro a b; simp only [MulZeroClass.mul_zero, map_zero, LinearMap.zero_apply]
    · intro a₁ b₁ a₂ b₂
      simp only [module_aux_apply, mul_smul, smul_comm a₁ b₂, Algebra.TensorProduct.tmul_mul_tmul,
        LinearMap.mul_apply]
    · intro z w hz hw a b
      simp only at hz hw 
      simp only [mul_add, hz, hw, map_add, LinearMap.add_apply]
    · intro z w hz hw; simp only [MulZeroClass.mul_zero, map_zero, LinearMap.zero_apply]
    · intro a b z w hz hw
      simp only at hz hw 
      simp only [map_add, add_mul, LinearMap.add_apply, hz, hw]
    · intro u v hu hv z w hz hw
      simp only at hz hw 
      simp only [add_mul, hz, hw, map_add, LinearMap.add_apply]
#align tensor_product.algebra.module TensorProduct.Algebra.module
-/

attribute [local instance] TensorProduct.Algebra.module

#print TensorProduct.Algebra.smul_def /-
theorem smul_def (a : A) (b : B) (m : M) : a ⊗ₜ[R] b • m = a • b • m :=
  rfl
#align tensor_product.algebra.smul_def TensorProduct.Algebra.smul_def
-/

end TensorProduct.Algebra

