/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Yury Kudryashov

! This file was ported from Lean 3 source module algebra.algebra.prod
! leanprover-community/mathlib commit 23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Hom

/-!
# The R-algebra structure on products of R-algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The R-algebra structure on `Π i : I, A i` when each `A i` is an R-algebra.

## Main defintions

* `pi.algebra`
* `pi.eval_alg_hom`
* `pi.const_alg_hom`
-/


variable {R A B C : Type _}

variable [CommSemiring R]

variable [Semiring A] [Algebra R A] [Semiring B] [Algebra R B] [Semiring C] [Algebra R C]

namespace Prod

variable (R A B)

open Algebra

#print Prod.algebra /-
instance algebra : Algebra R (A × B) :=
  { Prod.module,
    RingHom.prod (algebraMap R A)
      (algebraMap R
        B) with
    commutes' := by rintro r ⟨a, b⟩; dsimp; rw [commutes r a, commutes r b]
    smul_def' := by rintro r ⟨a, b⟩; dsimp; rw [Algebra.smul_def r a, Algebra.smul_def r b] }
#align prod.algebra Prod.algebra
-/

variable {R A B}

#print Prod.algebraMap_apply /-
@[simp]
theorem algebraMap_apply (r : R) : algebraMap R (A × B) r = (algebraMap R A r, algebraMap R B r) :=
  rfl
#align prod.algebra_map_apply Prod.algebraMap_apply
-/

end Prod

namespace AlgHom

variable (R A B)

#print AlgHom.fst /-
/-- First projection as `alg_hom`. -/
def fst : A × B →ₐ[R] A :=
  { RingHom.fst A B with commutes' := fun r => rfl }
#align alg_hom.fst AlgHom.fst
-/

#print AlgHom.snd /-
/-- Second projection as `alg_hom`. -/
def snd : A × B →ₐ[R] B :=
  { RingHom.snd A B with commutes' := fun r => rfl }
#align alg_hom.snd AlgHom.snd
-/

variable {R A B}

#print AlgHom.prod /-
/-- The `pi.prod` of two morphisms is a morphism. -/
@[simps]
def prod (f : A →ₐ[R] B) (g : A →ₐ[R] C) : A →ₐ[R] B × C :=
  { f.toRingHom.Prod g.toRingHom with
    commutes' := fun r => by
      simp only [to_ring_hom_eq_coe, RingHom.toFun_eq_coe, RingHom.prod_apply, coe_to_ring_hom,
        commutes, Prod.algebraMap_apply] }
#align alg_hom.prod AlgHom.prod
-/

#print AlgHom.coe_prod /-
theorem coe_prod (f : A →ₐ[R] B) (g : A →ₐ[R] C) : ⇑(f.Prod g) = Pi.prod f g :=
  rfl
#align alg_hom.coe_prod AlgHom.coe_prod
-/

#print AlgHom.fst_prod /-
@[simp]
theorem fst_prod (f : A →ₐ[R] B) (g : A →ₐ[R] C) : (fst R B C).comp (prod f g) = f := by ext <;> rfl
#align alg_hom.fst_prod AlgHom.fst_prod
-/

#print AlgHom.snd_prod /-
@[simp]
theorem snd_prod (f : A →ₐ[R] B) (g : A →ₐ[R] C) : (snd R B C).comp (prod f g) = g := by ext <;> rfl
#align alg_hom.snd_prod AlgHom.snd_prod
-/

#print AlgHom.prod_fst_snd /-
@[simp]
theorem prod_fst_snd : prod (fst R A B) (snd R A B) = 1 :=
  FunLike.coe_injective Pi.prod_fst_snd
#align alg_hom.prod_fst_snd AlgHom.prod_fst_snd
-/

#print AlgHom.prodEquiv /-
/-- Taking the product of two maps with the same domain is equivalent to taking the product of
their codomains. -/
@[simps]
def prodEquiv : (A →ₐ[R] B) × (A →ₐ[R] C) ≃ (A →ₐ[R] B × C)
    where
  toFun f := f.1.Prod f.2
  invFun f := ((fst _ _ _).comp f, (snd _ _ _).comp f)
  left_inv f := by ext <;> rfl
  right_inv f := by ext <;> rfl
#align alg_hom.prod_equiv AlgHom.prodEquiv
-/

end AlgHom

