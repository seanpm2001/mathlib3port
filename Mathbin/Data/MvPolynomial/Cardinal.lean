/-
Copyright (c) 2021 Chris Hughes, Junyan Xu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Junyan Xu

! This file was ported from Lean 3 source module data.mv_polynomial.cardinal
! leanprover-community/mathlib commit 31ca6f9cf5f90a6206092cd7f84b359dcb6d52e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finsupp.Fintype
import Mathbin.Data.MvPolynomial.Equiv
import Mathbin.SetTheory.Cardinal.Ordinal

/-!
# Cardinality of Multivariate Polynomial Ring

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The main result in this file is `mv_polynomial.cardinal_mk_le_max`, which says that
the cardinality of `mv_polynomial σ R` is bounded above by the maximum of `#R`, `#σ`
and `ℵ₀`.
-/


universe u v

open Cardinal

open scoped Cardinal

namespace MvPolynomial

section TwoUniverses

variable {σ : Type u} {R : Type v} [CommSemiring R]

#print MvPolynomial.cardinal_mk_eq_max_lift /-
@[simp]
theorem cardinal_mk_eq_max_lift [Nonempty σ] [Nontrivial R] :
    (#MvPolynomial σ R) = max (max (Cardinal.lift.{u} <| (#R)) <| Cardinal.lift.{v} <| (#σ)) ℵ₀ :=
  (mk_finsupp_lift_of_infinite _ R).trans <| by
    rw [mk_finsupp_nat, max_assoc, lift_max, lift_aleph_0, max_comm]
#align mv_polynomial.cardinal_mk_eq_max_lift MvPolynomial.cardinal_mk_eq_max_lift
-/

#print MvPolynomial.cardinal_mk_eq_lift /-
@[simp]
theorem cardinal_mk_eq_lift [IsEmpty σ] : (#MvPolynomial σ R) = Cardinal.lift.{u} (#R) :=
  ((isEmptyRingEquiv R σ).toEquiv.trans Equiv.ulift.{u}.symm).cardinal_eq
#align mv_polynomial.cardinal_mk_eq_lift MvPolynomial.cardinal_mk_eq_lift
-/

#print MvPolynomial.cardinal_lift_mk_le_max /-
theorem cardinal_lift_mk_le_max {σ : Type u} {R : Type v} [CommSemiring R] :
    (#MvPolynomial σ R) ≤ max (max (Cardinal.lift.{u} <| (#R)) <| Cardinal.lift.{v} <| (#σ)) ℵ₀ :=
  by
  cases subsingleton_or_nontrivial R
  · exact (mk_eq_one _).trans_le (le_max_of_le_right one_le_aleph_0)
  cases isEmpty_or_nonempty σ
  · exact cardinal_mk_eq_lift.trans_le (le_max_of_le_left <| le_max_left _ _)
  · exact cardinal_mk_eq_max_lift.le
#align mv_polynomial.cardinal_lift_mk_le_max MvPolynomial.cardinal_lift_mk_le_max
-/

end TwoUniverses

variable {σ R : Type u} [CommSemiring R]

#print MvPolynomial.cardinal_mk_eq_max /-
theorem cardinal_mk_eq_max [Nonempty σ] [Nontrivial R] :
    (#MvPolynomial σ R) = max (max (#R) (#σ)) ℵ₀ := by simp
#align mv_polynomial.cardinal_mk_eq_max MvPolynomial.cardinal_mk_eq_max
-/

#print MvPolynomial.cardinal_mk_le_max /-
/-- The cardinality of the multivariate polynomial ring, `mv_polynomial σ R` is at most the maximum
of `#R`, `#σ` and `ℵ₀` -/
theorem cardinal_mk_le_max : (#MvPolynomial σ R) ≤ max (max (#R) (#σ)) ℵ₀ :=
  cardinal_lift_mk_le_max.trans <| by rw [lift_id, lift_id]
#align mv_polynomial.cardinal_mk_le_max MvPolynomial.cardinal_mk_le_max
-/

end MvPolynomial

