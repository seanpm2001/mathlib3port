/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module data.mv_polynomial.funext
! leanprover-community/mathlib commit 0b89934139d3be96f9dab477f10c20f9f93da580
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.RingDivision
import Mathbin.Data.MvPolynomial.Rename
import Mathbin.RingTheory.Polynomial.Basic
import Mathbin.Data.MvPolynomial.Polynomial

/-!
## Function extensionality for multivariate polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we show that two multivariate polynomials over an infinite integral domain are equal
if they are equal upon evaluating them on an arbitrary assignment of the variables.

# Main declaration

* `mv_polynomial.funext`: two polynomials `φ ψ : mv_polynomial σ R`
  over an infinite integral domain `R` are equal if `eval x φ = eval x ψ` for all `x : σ → R`.

-/


namespace MvPolynomial

variable {R : Type _} [CommRing R] [IsDomain R] [Infinite R]

private theorem funext_fin {n : ℕ} {p : MvPolynomial (Fin n) R}
    (h : ∀ x : Fin n → R, eval x p = 0) : p = 0 :=
  by
  induction' n with n ih
  · apply (MvPolynomial.isEmptyRingEquiv R (Fin 0)).Injective
    rw [RingEquiv.map_zero]
    convert h _
  · apply (finSuccEquiv R n).Injective
    simp only [AlgEquiv.map_zero]
    refine' Polynomial.funext fun q => _
    rw [Polynomial.eval_zero]
    apply ih fun x => _
    calc
      _ = _ := eval_polynomial_eval_fin_succ_equiv p _ _
      _ = 0 := h _

#print MvPolynomial.funext /-
/-- Two multivariate polynomials over an infinite integral domain are equal
if they are equal upon evaluating them on an arbitrary assignment of the variables. -/
theorem funext {σ : Type _} {p q : MvPolynomial σ R} (h : ∀ x : σ → R, eval x p = eval x q) :
    p = q :=
  by
  suffices ∀ p, (∀ x : σ → R, eval x p = 0) → p = 0 by rw [← sub_eq_zero, this (p - q)];
    simp only [h, RingHom.map_sub, forall_const, sub_self]
  clear h p q
  intro p h
  obtain ⟨n, f, hf, p, rfl⟩ := exists_fin_rename p
  suffices p = 0 by rw [this, AlgHom.map_zero]
  apply funext_fin
  intro x
  classical
  convert h (Function.extend f x 0)
  simp only [eval, eval₂_hom_rename, Function.extend_comp hf]
#align mv_polynomial.funext MvPolynomial.funext
-/

#print MvPolynomial.funext_iff /-
theorem funext_iff {σ : Type _} {p q : MvPolynomial σ R} :
    p = q ↔ ∀ x : σ → R, eval x p = eval x q :=
  ⟨by rintro rfl <;> simp only [forall_const, eq_self_iff_true], funext⟩
#align mv_polynomial.funext_iff MvPolynomial.funext_iff
-/

end MvPolynomial

