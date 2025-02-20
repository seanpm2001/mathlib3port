/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module algebra.dual_number
! leanprover-community/mathlib commit 290a7ba01fbcab1b64757bdaa270d28f4dcede35
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.TrivSqZeroExt

/-!
# Dual numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The dual numbers over `R` are of the form `a + bε`, where `a` and `b` are typically elements of a
commutative ring `R`, and `ε` is a symbol satisfying `ε^2 = 0`. They are a special case of
`triv_sq_zero_ext R M` with `M = R`.

## Notation

In the `dual_number` locale:

* `R[ε]` is a shorthand for `dual_number R`
* `ε` is a shorthand for `dual_number.eps`

## Main definitions

* `dual_number`
* `dual_number.eps`
* `dual_number.lift`

## Implementation notes

Rather than duplicating the API of `triv_sq_zero_ext`, this file reuses the functions there.

## References

* https://en.wikipedia.org/wiki/Dual_number
-/


variable {R : Type _}

#print DualNumber /-
/-- The type of dual numbers, numbers of the form $a + bε$ where $ε^2 = 0$.-/
abbrev DualNumber (R : Type _) : Type _ :=
  TrivSqZeroExt R R
#align dual_number DualNumber
-/

#print DualNumber.eps /-
/-- The unit element $ε$ that squares to zero. -/
def DualNumber.eps [Zero R] [One R] : DualNumber R :=
  TrivSqZeroExt.inr 1
#align dual_number.eps DualNumber.eps
-/

scoped[DualNumber] notation "ε" => DualNumber.eps

scoped[DualNumber] postfix:1024 "[ε]" => DualNumber

open scoped DualNumber

namespace DualNumber

open TrivSqZeroExt

#print DualNumber.fst_eps /-
@[simp]
theorem fst_eps [Zero R] [One R] : fst ε = (0 : R) :=
  fst_inr _ _
#align dual_number.fst_eps DualNumber.fst_eps
-/

#print DualNumber.snd_eps /-
@[simp]
theorem snd_eps [Zero R] [One R] : snd ε = (1 : R) :=
  snd_inr _ _
#align dual_number.snd_eps DualNumber.snd_eps
-/

#print DualNumber.snd_mul /-
/-- A version of `triv_sq_zero_ext.snd_mul` with `*` instead of `•`. -/
@[simp]
theorem snd_mul [Semiring R] (x y : R[ε]) : snd (x * y) = fst x * snd y + snd x * fst y :=
  snd_mul _ _
#align dual_number.snd_mul DualNumber.snd_mul
-/

#print DualNumber.eps_mul_eps /-
@[simp]
theorem eps_mul_eps [Semiring R] : (ε * ε : R[ε]) = 0 :=
  inr_mul_inr _ _ _
#align dual_number.eps_mul_eps DualNumber.eps_mul_eps
-/

#print DualNumber.inr_eq_smul_eps /-
@[simp]
theorem inr_eq_smul_eps [MulZeroOneClass R] (r : R) : inr r = (r • ε : R[ε]) :=
  ext (MulZeroClass.mul_zero r).symm (mul_one r).symm
#align dual_number.inr_eq_smul_eps DualNumber.inr_eq_smul_eps
-/

#print DualNumber.algHom_ext /-
/-- For two algebra morphisms out of `R[ε]` to agree, it suffices for them to agree on `ε`. -/
@[ext]
theorem algHom_ext {A} [CommSemiring R] [Semiring A] [Algebra R A] ⦃f g : R[ε] →ₐ[R] A⦄
    (h : f ε = g ε) : f = g :=
  algHom_ext' <| LinearMap.ext_ring <| h
#align dual_number.alg_hom_ext DualNumber.algHom_ext
-/

variable {A : Type _} [CommSemiring R] [Semiring A] [Algebra R A]

#print DualNumber.lift /-
/-- A universal property of the dual numbers, providing a unique `R[ε] →ₐ[R] A` for every element
of `A` which squares to `0`.

This isomorphism is named to match the very similar `complex.lift`. -/
@[simps (config := { attrs := [] })]
def lift : { e : A // e * e = 0 } ≃ (R[ε] →ₐ[R] A) :=
  Equiv.trans
    (show { e : A // e * e = 0 } ≃ { f : R →ₗ[R] A // ∀ x y, f x * f y = 0 } from
      (LinearMap.ringLmapEquivSelf R ℕ A).symm.toEquiv.subtypeEquiv fun a =>
        by
        dsimp
        simp_rw [smul_mul_smul]
        refine' ⟨fun h x y => h.symm ▸ smul_zero _, fun h => by simpa using h 1 1⟩)
    TrivSqZeroExt.lift
#align dual_number.lift DualNumber.lift
-/

#print DualNumber.lift_apply_eps /-
-- When applied to `ε`, `dual_number.lift` produces the element of `A` that squares to 0.
@[simp]
theorem lift_apply_eps (e : { e : A // e * e = 0 }) : lift e (ε : R[ε]) = e :=
  (TrivSqZeroExt.liftAux_apply_inr _ _ _).trans <| one_smul _ _
#align dual_number.lift_apply_eps DualNumber.lift_apply_eps
-/

#print DualNumber.lift_eps /-
-- Lifting `dual_number.eps` itself gives the identity.
@[simp]
theorem lift_eps : lift ⟨ε, eps_mul_eps⟩ = AlgHom.id R R[ε] :=
  algHom_ext <| lift_apply_eps _
#align dual_number.lift_eps DualNumber.lift_eps
-/

end DualNumber

