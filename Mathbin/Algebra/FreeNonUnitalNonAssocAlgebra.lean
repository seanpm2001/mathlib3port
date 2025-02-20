/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.free_non_unital_non_assoc_algebra
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Free
import Mathbin.Algebra.MonoidAlgebra.Basic

/-!
# Free algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given a semiring `R` and a type `X`, we construct the free non-unital, non-associative algebra on
`X` with coefficients in `R`, together with its universal property. The construction is valuable
because it can be used to build free algebras with more structure, e.g., free Lie algebras.

Note that elsewhere we have a construction of the free unital, associative algebra. This is called
`free_algebra`.

## Main definitions

  * `free_non_unital_non_assoc_algebra`
  * `free_non_unital_non_assoc_algebra.lift`
  * `free_non_unital_non_assoc_algebra.of`

## Implementation details

We construct the free algebra as the magma algebra, with coefficients in `R`, of the free magma on
`X`. However we regard this as an implementation detail and thus deliberately omit the lemmas
`of_apply` and `lift_apply`, and we mark `free_non_unital_non_assoc_algebra` and `lift` as
irreducible once we have established the universal property.

## Tags

free algebra, non-unital, non-associative, free magma, magma algebra, universal property,
forgetful functor, adjoint functor
-/


universe u v w

noncomputable section

variable (R : Type u) (X : Type v) [Semiring R]

#print FreeNonUnitalNonAssocAlgebra /-
/-- The free non-unital, non-associative algebra on the type `X` with coefficients in `R`. -/
abbrev FreeNonUnitalNonAssocAlgebra :=
  MonoidAlgebra R (FreeMagma X)
#align free_non_unital_non_assoc_algebra FreeNonUnitalNonAssocAlgebra
-/

namespace FreeNonUnitalNonAssocAlgebra

variable {X}

#print FreeNonUnitalNonAssocAlgebra.of /-
/-- The embedding of `X` into the free algebra with coefficients in `R`. -/
def of : X → FreeNonUnitalNonAssocAlgebra R X :=
  MonoidAlgebra.ofMagma R _ ∘ FreeMagma.of
#align free_non_unital_non_assoc_algebra.of FreeNonUnitalNonAssocAlgebra.of
-/

variable {A : Type w} [NonUnitalNonAssocSemiring A]

variable [Module R A] [IsScalarTower R A A] [SMulCommClass R A A]

#print FreeNonUnitalNonAssocAlgebra.lift /-
/-- The functor `X ↦ free_non_unital_non_assoc_algebra R X` from the category of types to the
category of non-unital, non-associative algebras over `R` is adjoint to the forgetful functor in the
other direction. -/
def lift : (X → A) ≃ (FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A) :=
  FreeMagma.lift.trans (MonoidAlgebra.liftMagma R)
#align free_non_unital_non_assoc_algebra.lift FreeNonUnitalNonAssocAlgebra.lift
-/

#print FreeNonUnitalNonAssocAlgebra.lift_symm_apply /-
@[simp]
theorem lift_symm_apply (F : FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A) :
    (lift R).symm F = F ∘ of R :=
  rfl
#align free_non_unital_non_assoc_algebra.lift_symm_apply FreeNonUnitalNonAssocAlgebra.lift_symm_apply
-/

#print FreeNonUnitalNonAssocAlgebra.of_comp_lift /-
@[simp]
theorem of_comp_lift (f : X → A) : lift R f ∘ of R = f :=
  (lift R).left_inv f
#align free_non_unital_non_assoc_algebra.of_comp_lift FreeNonUnitalNonAssocAlgebra.of_comp_lift
-/

#print FreeNonUnitalNonAssocAlgebra.lift_unique /-
@[simp]
theorem lift_unique (f : X → A) (F : FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A) :
    F ∘ of R = f ↔ F = lift R f :=
  (lift R).symm_apply_eq
#align free_non_unital_non_assoc_algebra.lift_unique FreeNonUnitalNonAssocAlgebra.lift_unique
-/

#print FreeNonUnitalNonAssocAlgebra.lift_of_apply /-
@[simp]
theorem lift_of_apply (f : X → A) (x) : lift R f (of R x) = f x :=
  congr_fun (of_comp_lift _ f) x
#align free_non_unital_non_assoc_algebra.lift_of_apply FreeNonUnitalNonAssocAlgebra.lift_of_apply
-/

#print FreeNonUnitalNonAssocAlgebra.lift_comp_of /-
@[simp]
theorem lift_comp_of (F : FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A) : lift R (F ∘ of R) = F :=
  (lift R).apply_symm_apply F
#align free_non_unital_non_assoc_algebra.lift_comp_of FreeNonUnitalNonAssocAlgebra.lift_comp_of
-/

#print FreeNonUnitalNonAssocAlgebra.hom_ext /-
@[ext]
theorem hom_ext {F₁ F₂ : FreeNonUnitalNonAssocAlgebra R X →ₙₐ[R] A}
    (h : ∀ x, F₁ (of R x) = F₂ (of R x)) : F₁ = F₂ :=
  (lift R).symm.Injective <| funext h
#align free_non_unital_non_assoc_algebra.hom_ext FreeNonUnitalNonAssocAlgebra.hom_ext
-/

end FreeNonUnitalNonAssocAlgebra

