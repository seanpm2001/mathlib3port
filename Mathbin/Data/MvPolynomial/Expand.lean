/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Robert Y. Lewis

! This file was ported from Lean 3 source module data.mv_polynomial.expand
! leanprover-community/mathlib commit d64d67d000b974f0d86a2be7918cf800be6271c8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.MvPolynomial.Monad

/-!
## Expand multivariate polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given a multivariate polynomial `φ`, one may replace every occurence of `X i` by `X i ^ n`,
for some natural number `n`.
This operation is called `mv_polynomial.expand` and it is an algebra homomorphism.

### Main declaration

* `mv_polynomial.expand`: expand a polynomial by a factor of p, so `∑ aₙ xⁿ` becomes `∑ aₙ xⁿᵖ`.
-/


open scoped BigOperators

namespace MvPolynomial

variable {σ τ R S : Type _} [CommSemiring R] [CommSemiring S]

#print MvPolynomial.expand /-
/-- Expand the polynomial by a factor of p, so `∑ aₙ xⁿ` becomes `∑ aₙ xⁿᵖ`.

See also `polynomial.expand`. -/
noncomputable def expand (p : ℕ) : MvPolynomial σ R →ₐ[R] MvPolynomial σ R :=
  { (eval₂Hom C fun i => X i ^ p : MvPolynomial σ R →+* MvPolynomial σ R) with
    commutes' := fun r => eval₂Hom_C _ _ _ }
#align mv_polynomial.expand MvPolynomial.expand
-/

#print MvPolynomial.expand_C /-
@[simp]
theorem expand_C (p : ℕ) (r : R) : expand p (C r : MvPolynomial σ R) = C r :=
  eval₂Hom_C _ _ _
#align mv_polynomial.expand_C MvPolynomial.expand_C
-/

#print MvPolynomial.expand_X /-
@[simp]
theorem expand_X (p : ℕ) (i : σ) : expand p (X i : MvPolynomial σ R) = X i ^ p :=
  eval₂Hom_X' _ _ _
#align mv_polynomial.expand_X MvPolynomial.expand_X
-/

#print MvPolynomial.expand_monomial /-
@[simp]
theorem expand_monomial (p : ℕ) (d : σ →₀ ℕ) (r : R) :
    expand p (monomial d r) = C r * ∏ i in d.support, (X i ^ p) ^ d i :=
  bind₁_monomial _ _ _
#align mv_polynomial.expand_monomial MvPolynomial.expand_monomial
-/

#print MvPolynomial.expand_one_apply /-
theorem expand_one_apply (f : MvPolynomial σ R) : expand 1 f = f := by
  simp only [expand, bind₁_X_left, AlgHom.id_apply, RingHom.toFun_eq_coe, eval₂_hom_C_left,
    AlgHom.coe_toRingHom, pow_one, AlgHom.coe_mks]
#align mv_polynomial.expand_one_apply MvPolynomial.expand_one_apply
-/

#print MvPolynomial.expand_one /-
@[simp]
theorem expand_one : expand 1 = AlgHom.id R (MvPolynomial σ R) := by ext1 f;
  rw [expand_one_apply, AlgHom.id_apply]
#align mv_polynomial.expand_one MvPolynomial.expand_one
-/

#print MvPolynomial.expand_comp_bind₁ /-
theorem expand_comp_bind₁ (p : ℕ) (f : σ → MvPolynomial τ R) :
    (expand p).comp (bind₁ f) = bind₁ fun i => expand p (f i) := by apply alg_hom_ext; intro i;
  simp only [AlgHom.comp_apply, bind₁_X_right]
#align mv_polynomial.expand_comp_bind₁ MvPolynomial.expand_comp_bind₁
-/

#print MvPolynomial.expand_bind₁ /-
theorem expand_bind₁ (p : ℕ) (f : σ → MvPolynomial τ R) (φ : MvPolynomial σ R) :
    expand p (bind₁ f φ) = bind₁ (fun i => expand p (f i)) φ := by
  rw [← AlgHom.comp_apply, expand_comp_bind₁]
#align mv_polynomial.expand_bind₁ MvPolynomial.expand_bind₁
-/

#print MvPolynomial.map_expand /-
@[simp]
theorem map_expand (f : R →+* S) (p : ℕ) (φ : MvPolynomial σ R) :
    map f (expand p φ) = expand p (map f φ) := by simp [expand, map_bind₁]
#align mv_polynomial.map_expand MvPolynomial.map_expand
-/

#print MvPolynomial.rename_expand /-
@[simp]
theorem rename_expand (f : σ → τ) (p : ℕ) (φ : MvPolynomial σ R) :
    rename f (expand p φ) = expand p (rename f φ) := by simp [expand, bind₁_rename, rename_bind₁]
#align mv_polynomial.rename_expand MvPolynomial.rename_expand
-/

#print MvPolynomial.rename_comp_expand /-
@[simp]
theorem rename_comp_expand (f : σ → τ) (p : ℕ) :
    (rename f).comp (expand p) =
      (expand p).comp (rename f : MvPolynomial σ R →ₐ[R] MvPolynomial τ R) :=
  by ext1 φ; simp only [rename_expand, AlgHom.comp_apply]
#align mv_polynomial.rename_comp_expand MvPolynomial.rename_comp_expand
-/

end MvPolynomial

