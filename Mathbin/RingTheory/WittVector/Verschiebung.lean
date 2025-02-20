/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module ring_theory.witt_vector.verschiebung
! leanprover-community/mathlib commit 9240e8be927a0955b9a82c6c85ef499ee3a626b8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.WittVector.Basic
import Mathbin.RingTheory.WittVector.IsPoly

/-!
## The Verschiebung operator

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## References

* [Hazewinkel, *Witt Vectors*][Haze09]

* [Commelin and Lewis, *Formalizing the Ring of Witt Vectors*][CL21]
-/


namespace WittVector

open MvPolynomial

variable {p : ℕ} {R S : Type _} [hp : Fact p.Prime] [CommRing R] [CommRing S]

local notation "𝕎" => WittVector p

-- type as `\bbW`
noncomputable section

#print WittVector.verschiebungFun /-
/-- `verschiebung_fun x` shifts the coefficients of `x` up by one,
by inserting 0 as the 0th coefficient.
`x.coeff i` then becomes `(verchiebung_fun x).coeff (i + 1)`.

`verschiebung_fun` is the underlying function of the additive monoid hom `witt_vector.verschiebung`.
-/
def verschiebungFun (x : 𝕎 R) : 𝕎 R :=
  mk' p fun n => if n = 0 then 0 else x.coeff (n - 1)
#align witt_vector.verschiebung_fun WittVector.verschiebungFun
-/

#print WittVector.verschiebungFun_coeff /-
theorem verschiebungFun_coeff (x : 𝕎 R) (n : ℕ) :
    (verschiebungFun x).coeff n = if n = 0 then 0 else x.coeff (n - 1) := by
  rw [verschiebung_fun, coeff_mk]
#align witt_vector.verschiebung_fun_coeff WittVector.verschiebungFun_coeff
-/

#print WittVector.verschiebungFun_coeff_zero /-
theorem verschiebungFun_coeff_zero (x : 𝕎 R) : (verschiebungFun x).coeff 0 = 0 := by
  rw [verschiebung_fun_coeff, if_pos rfl]
#align witt_vector.verschiebung_fun_coeff_zero WittVector.verschiebungFun_coeff_zero
-/

#print WittVector.verschiebungFun_coeff_succ /-
@[simp]
theorem verschiebungFun_coeff_succ (x : 𝕎 R) (n : ℕ) :
    (verschiebungFun x).coeff n.succ = x.coeff n :=
  rfl
#align witt_vector.verschiebung_fun_coeff_succ WittVector.verschiebungFun_coeff_succ
-/

#print WittVector.ghostComponent_zero_verschiebungFun /-
@[ghost_simps]
theorem ghostComponent_zero_verschiebungFun (x : 𝕎 R) : ghostComponent 0 (verschiebungFun x) = 0 :=
  by
  rw [ghost_component_apply, aeval_wittPolynomial, Finset.range_one, Finset.sum_singleton,
    verschiebung_fun_coeff_zero, pow_zero, pow_zero, pow_one, one_mul]
#align witt_vector.ghost_component_zero_verschiebung_fun WittVector.ghostComponent_zero_verschiebungFun
-/

#print WittVector.ghostComponent_verschiebungFun /-
@[ghost_simps]
theorem ghostComponent_verschiebungFun (x : 𝕎 R) (n : ℕ) :
    ghostComponent (n + 1) (verschiebungFun x) = p * ghostComponent n x :=
  by
  simp only [ghost_component_apply, aeval_wittPolynomial]
  rw [Finset.sum_range_succ', verschiebung_fun_coeff, if_pos rfl, zero_pow (pow_pos hp.1.Pos _),
    MulZeroClass.mul_zero, add_zero, Finset.mul_sum, Finset.sum_congr rfl]
  rintro i -
  simp only [pow_succ, mul_assoc, verschiebung_fun_coeff, if_neg (Nat.succ_ne_zero i),
    Nat.succ_sub_succ, tsub_zero]
#align witt_vector.ghost_component_verschiebung_fun WittVector.ghostComponent_verschiebungFun
-/

#print WittVector.verschiebungPoly /-
/-- The 0th Verschiebung polynomial is 0. For `n > 0`, the `n`th Verschiebung polynomial is the
variable `X (n-1)`.
-/
def verschiebungPoly (n : ℕ) : MvPolynomial ℕ ℤ :=
  if n = 0 then 0 else X (n - 1)
#align witt_vector.verschiebung_poly WittVector.verschiebungPoly
-/

#print WittVector.verschiebungPoly_zero /-
@[simp]
theorem verschiebungPoly_zero : verschiebungPoly 0 = 0 :=
  rfl
#align witt_vector.verschiebung_poly_zero WittVector.verschiebungPoly_zero
-/

#print WittVector.aeval_verschiebung_poly' /-
theorem aeval_verschiebung_poly' (x : 𝕎 R) (n : ℕ) :
    aeval x.coeff (verschiebungPoly n) = (verschiebungFun x).coeff n :=
  by
  cases n
  · simp only [verschiebung_poly, verschiebung_fun_coeff_zero, if_pos rfl, AlgHom.map_zero]
  ·
    rw [verschiebung_poly, verschiebung_fun_coeff_succ, if_neg n.succ_ne_zero, aeval_X,
      Nat.succ_eq_add_one, add_tsub_cancel_right]
#align witt_vector.aeval_verschiebung_poly' WittVector.aeval_verschiebung_poly'
-/

variable (p)

#print WittVector.verschiebungFun_isPoly /-
/-- `witt_vector.verschiebung` has polynomial structure given by `witt_vector.verschiebung_poly`.
-/
@[is_poly]
theorem verschiebungFun_isPoly : IsPoly p fun R _Rcr => @verschiebungFun p R _Rcr :=
  by
  use verschiebung_poly
  simp only [aeval_verschiebung_poly', eq_self_iff_true, forall₃_true_iff]
#align witt_vector.verschiebung_fun_is_poly WittVector.verschiebungFun_isPoly
-/

variable {p}

#print WittVector.verschiebung /-
/--
`verschiebung x` shifts the coefficients of `x` up by one, by inserting 0 as the 0th coefficient.
`x.coeff i` then becomes `(verchiebung x).coeff (i + 1)`.

This is a additive monoid hom with underlying function `verschiebung_fun`.
-/
noncomputable def verschiebung : 𝕎 R →+ 𝕎 R
    where
  toFun := verschiebungFun
  map_zero' := by
    ext ⟨⟩ <;> rw [verschiebung_fun_coeff] <;>
      simp only [if_true, eq_self_iff_true, zero_coeff, if_t_t]
  map_add' := by ghost_calc _ _; rintro ⟨⟩ <;> ghost_simp
#align witt_vector.verschiebung WittVector.verschiebung
-/

#print WittVector.verschiebung_isPoly /-
/-- `witt_vector.verschiebung` is a polynomial function. -/
@[is_poly]
theorem verschiebung_isPoly : IsPoly p fun R _Rcr => @verschiebung p R hp _Rcr :=
  verschiebungFun_isPoly p
#align witt_vector.verschiebung_is_poly WittVector.verschiebung_isPoly
-/

#print WittVector.map_verschiebung /-
/-- verschiebung is a natural transformation -/
@[simp]
theorem map_verschiebung (f : R →+* S) (x : 𝕎 R) :
    map f (verschiebung x) = verschiebung (map f x) := by ext ⟨-, -⟩; exact f.map_zero; rfl
#align witt_vector.map_verschiebung WittVector.map_verschiebung
-/

#print WittVector.ghostComponent_zero_verschiebung /-
@[ghost_simps]
theorem ghostComponent_zero_verschiebung (x : 𝕎 R) : ghostComponent 0 (verschiebung x) = 0 :=
  ghostComponent_zero_verschiebungFun _
#align witt_vector.ghost_component_zero_verschiebung WittVector.ghostComponent_zero_verschiebung
-/

#print WittVector.ghostComponent_verschiebung /-
@[ghost_simps]
theorem ghostComponent_verschiebung (x : 𝕎 R) (n : ℕ) :
    ghostComponent (n + 1) (verschiebung x) = p * ghostComponent n x :=
  ghostComponent_verschiebungFun _ _
#align witt_vector.ghost_component_verschiebung WittVector.ghostComponent_verschiebung
-/

#print WittVector.verschiebung_coeff_zero /-
@[simp]
theorem verschiebung_coeff_zero (x : 𝕎 R) : (verschiebung x).coeff 0 = 0 :=
  rfl
#align witt_vector.verschiebung_coeff_zero WittVector.verschiebung_coeff_zero
-/

#print WittVector.verschiebung_coeff_add_one /-
-- simp_nf complains if this is simp
theorem verschiebung_coeff_add_one (x : 𝕎 R) (n : ℕ) : (verschiebung x).coeff (n + 1) = x.coeff n :=
  rfl
#align witt_vector.verschiebung_coeff_add_one WittVector.verschiebung_coeff_add_one
-/

#print WittVector.verschiebung_coeff_succ /-
@[simp]
theorem verschiebung_coeff_succ (x : 𝕎 R) (n : ℕ) : (verschiebung x).coeff n.succ = x.coeff n :=
  rfl
#align witt_vector.verschiebung_coeff_succ WittVector.verschiebung_coeff_succ
-/

#print WittVector.aeval_verschiebungPoly /-
theorem aeval_verschiebungPoly (x : 𝕎 R) (n : ℕ) :
    aeval x.coeff (verschiebungPoly n) = (verschiebung x).coeff n :=
  aeval_verschiebung_poly' x n
#align witt_vector.aeval_verschiebung_poly WittVector.aeval_verschiebungPoly
-/

#print WittVector.bind₁_verschiebungPoly_wittPolynomial /-
@[simp]
theorem bind₁_verschiebungPoly_wittPolynomial (n : ℕ) :
    bind₁ verschiebungPoly (wittPolynomial p ℤ n) =
      if n = 0 then 0 else p * wittPolynomial p ℤ (n - 1) :=
  by
  apply MvPolynomial.funext
  intro x
  split_ifs with hn
  · simp only [hn, verschiebung_poly_zero, wittPolynomial_zero, bind₁_X_right]
  · obtain ⟨n, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn
    rw [Nat.succ_eq_add_one, add_tsub_cancel_right, RingHom.map_mul, map_natCast, hom_bind₁]
    calc
      _ = ghost_component (n + 1) (verschiebung <| mk p x) := _
      _ = _ := _
    · apply eval₂_hom_congr (RingHom.ext_int _ _) _ rfl
      simp only [← aeval_verschiebung_poly, coeff_mk]
      funext k
      exact eval₂_hom_congr (RingHom.ext_int _ _) rfl rfl
    · rw [ghost_component_verschiebung]; rfl
#align witt_vector.bind₁_verschiebung_poly_witt_polynomial WittVector.bind₁_verschiebungPoly_wittPolynomial
-/

end WittVector

