/-
Copyright (c) 2021 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Johannes Hölzl, Scott Morrison, Damiano Testa, Jens Wagemaker

! This file was ported from Lean 3 source module data.polynomial.inductions
! leanprover-community/mathlib commit 57e09a1296bfb4330ddf6624f1028ba186117d82
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.MonoidAlgebra.Division
import Mathbin.Data.Nat.Interval
import Mathbin.Data.Polynomial.Degree.Definitions
import Mathbin.Data.Polynomial.Induction

/-!
# Induction on polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains lemmas dealing with different flavours of induction on polynomials.
-/


noncomputable section

open scoped Classical BigOperators Polynomial

open Finset

namespace Polynomial

universe u v w z

variable {R : Type u} {S : Type v} {T : Type w} {A : Type z} {a b : R} {n : ℕ}

section Semiring

variable [Semiring R] {p q : R[X]}

#print Polynomial.divX /-
/-- `div_X p` returns a polynomial `q` such that `q * X + C (p.coeff 0) = p`.
  It can be used in a semiring where the usual division algorithm is not possible -/
def divX (p : R[X]) : R[X] :=
  ⟨AddMonoidAlgebra.divOf p.toFinsupp 1⟩
#align polynomial.div_X Polynomial.divX
-/

#print Polynomial.coeff_divX /-
@[simp]
theorem coeff_divX : (divX p).coeff n = p.coeff (n + 1) := by rw [add_comm]; cases p; rfl
#align polynomial.coeff_div_X Polynomial.coeff_divX
-/

#print Polynomial.divX_mul_X_add /-
theorem divX_mul_X_add (p : R[X]) : divX p * X + C (p.coeff 0) = p :=
  ext <| by rintro ⟨_ | _⟩ <;> simp [coeff_C, Nat.succ_ne_zero, coeff_mul_X]
#align polynomial.div_X_mul_X_add Polynomial.divX_mul_X_add
-/

#print Polynomial.divX_C /-
@[simp]
theorem divX_C (a : R) : divX (C a) = 0 :=
  ext fun n => by simp [coeff_div_X, coeff_C, Finsupp.single_eq_of_ne _]
#align polynomial.div_X_C Polynomial.divX_C
-/

#print Polynomial.divX_eq_zero_iff /-
theorem divX_eq_zero_iff : divX p = 0 ↔ p = C (p.coeff 0) :=
  ⟨fun h => by simpa [eq_comm, h] using div_X_mul_X_add p, fun h => by rw [h, div_X_C]⟩
#align polynomial.div_X_eq_zero_iff Polynomial.divX_eq_zero_iff
-/

#print Polynomial.divX_add /-
theorem divX_add : divX (p + q) = divX p + divX q :=
  ext <| by simp
#align polynomial.div_X_add Polynomial.divX_add
-/

#print Polynomial.degree_divX_lt /-
theorem degree_divX_lt (hp0 : p ≠ 0) : (divX p).degree < p.degree := by
  haveI := nontrivial.of_polynomial_ne hp0 <;>
    calc
      (div_X p).degree < (div_X p * X + C (p.coeff 0)).degree :=
        if h : degree p ≤ 0 then
          by
          have h' : C (p.coeff 0) ≠ 0 := by rwa [← eq_C_of_degree_le_zero h]
          rw [eq_C_of_degree_le_zero h, div_X_C, degree_zero, MulZeroClass.zero_mul, zero_add]
          exact lt_of_le_of_ne bot_le (Ne.symm (mt degree_eq_bot.1 <| by simp [h']))
        else
          by
          have hXp0 : div_X p ≠ 0 := by
            simpa [div_X_eq_zero_iff, -not_le, degree_le_zero_iff] using h
          have : leading_coeff (div_X p) * leading_coeff X ≠ 0 := by simpa
          have : degree (C (p.coeff 0)) < degree (div_X p * X) :=
            calc
              degree (C (p.coeff 0)) ≤ 0 := degree_C_le
              _ < 1 := by decide
              _ = degree (X : R[X]) := degree_X.symm
              _ ≤ degree (div_X p * X) := by
                rw [← zero_add (degree X), degree_mul' this] <;>
                  exact
                    add_le_add
                      (by
                        rw [zero_le_degree_iff, Ne.def, div_X_eq_zero_iff] <;>
                          exact fun h0 => h (h0.symm ▸ degree_C_le))
                      le_rfl
          rw [degree_add_eq_left_of_degree_lt this] <;> exact degree_lt_degree_mul_X hXp0
      _ = p.degree := congr_arg _ (div_X_mul_X_add _)
#align polynomial.degree_div_X_lt Polynomial.degree_divX_lt
-/

#print Polynomial.recOnHorner /-
/-- An induction principle for polynomials, valued in Sort* instead of Prop. -/
@[elab_as_elim]
noncomputable def recOnHorner {M : R[X] → Sort _} :
    ∀ p : R[X],
      M 0 →
        (∀ p a, coeff p 0 = 0 → a ≠ 0 → M p → M (p + C a)) → (∀ p, p ≠ 0 → M p → M (p * X)) → M p
  | p => fun M0 MC MX =>
    if hp : p = 0 then Eq.recOn hp.symm M0
    else by
      have wf : degree (divX p) < degree p := degree_divX_lt hp
      rw [← div_X_mul_X_add p] at * <;>
        exact
          if hcp0 : coeff p 0 = 0 then by
            rw [hcp0, C_0, add_zero] <;>
              exact
                MX _ (fun h : div_X p = 0 => by simpa [h, hcp0] using hp) (rec_on_horner _ M0 MC MX)
          else
            MC _ _ (coeff_mul_X_zero _) hcp0
              (if hpX0 : div_X p = 0 then
                show M (div_X p * X) by rw [hpX0, MulZeroClass.zero_mul] <;> exact M0
              else MX (div_X p) hpX0 (rec_on_horner _ M0 MC MX))
#align polynomial.rec_on_horner Polynomial.recOnHorner
-/

#print Polynomial.degree_pos_induction_on /-
/-- A property holds for all polynomials of positive `degree` with coefficients in a semiring `R`
if it holds for
* `a * X`, with `a ∈ R`,
* `p * X`, with `p ∈ R[X]`,
* `p + a`, with `a ∈ R`, `p ∈ R[X]`,
with appropriate restrictions on each term.

See `nat_degree_ne_zero_induction_on` for a similar statement involving no explicit multiplication.
 -/
@[elab_as_elim]
theorem degree_pos_induction_on {P : R[X] → Prop} (p : R[X]) (h0 : 0 < degree p)
    (hC : ∀ {a}, a ≠ 0 → P (C a * X)) (hX : ∀ {p}, 0 < degree p → P p → P (p * X))
    (hadd : ∀ {p} {a}, 0 < degree p → P p → P (p + C a)) : P p :=
  recOnHorner p (fun h => by rw [degree_zero] at h  <;> exact absurd h (by decide))
    (fun p a _ _ ih h0 =>
      have : 0 < degree p :=
        lt_of_not_ge fun h =>
          not_lt_of_ge degree_C_le <| by rwa [eq_C_of_degree_le_zero h, ← C_add] at h0 
      hadd this (ih this))
    (fun p _ ih h0' =>
      if h0 : 0 < degree p then hX h0 (ih h0)
      else by
        rw [eq_C_of_degree_le_zero (le_of_not_gt h0)] at * <;>
          exact hC fun h : coeff p 0 = 0 => by simpa [h, Nat.not_lt_zero] using h0')
    h0
#align polynomial.degree_pos_induction_on Polynomial.degree_pos_induction_on
-/

#print Polynomial.natDegree_ne_zero_induction_on /-
/-- A property holds for all polynomials of non-zero `nat_degree` with coefficients in a
semiring `R` if it holds for
* `p + a`, with `a ∈ R`, `p ∈ R[X]`,
* `p + q`, with `p, q ∈ R[X]`,
* monomials with nonzero coefficient and non-zero exponent,
with appropriate restrictions on each term.
Note that multiplication is "hidden" in the assumption on monomials, so there is no explicit
multiplication in the statement.
See `degree_pos_induction_on` for a similar statement involving more explicit multiplications.
 -/
@[elab_as_elim]
theorem natDegree_ne_zero_induction_on {M : R[X] → Prop} {f : R[X]} (f0 : f.natDegree ≠ 0)
    (h_C_add : ∀ {a p}, M p → M (C a + p)) (h_add : ∀ {p q}, M p → M q → M (p + q))
    (h_monomial : ∀ {n : ℕ} {a : R}, a ≠ 0 → n ≠ 0 → M (monomial n a)) : M f :=
  by
  suffices f.natDegree = 0 ∨ M f from Or.dcases_on this (fun h => (f0 h).elim) id
  apply f.induction_on
  · exact fun a => Or.inl (nat_degree_C _)
  · rintro p q (hp | hp) (hq | hq)
    · refine' Or.inl _
      rw [eq_C_of_nat_degree_eq_zero hp, eq_C_of_nat_degree_eq_zero hq, ← C_add, nat_degree_C]
    · refine' Or.inr _
      rw [eq_C_of_nat_degree_eq_zero hp]
      exact h_C_add hq
    · refine' Or.inr _
      rw [eq_C_of_nat_degree_eq_zero hq, add_comm]
      exact h_C_add hp
    · exact Or.inr (h_add hp hq)
  · intro n a hi
    by_cases a0 : a = 0
    · exact Or.inl (by rw [a0, C_0, MulZeroClass.zero_mul, nat_degree_zero])
    · refine' Or.inr _
      rw [C_mul_X_pow_eq_monomial]
      exact h_monomial a0 n.succ_ne_zero
#align polynomial.nat_degree_ne_zero_induction_on Polynomial.natDegree_ne_zero_induction_on
-/

end Semiring

end Polynomial

