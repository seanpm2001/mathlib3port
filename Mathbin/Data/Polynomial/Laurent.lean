/-
Copyright (c) 2022 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa

! This file was ported from Lean 3 source module data.polynomial.laurent
! leanprover-community/mathlib commit 2ed2c6310e6f1c5562bdf6bfbda55ebbf6891abe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.AlgebraMap
import Mathbin.RingTheory.Localization.Basic

/-!  # Laurent polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We introduce Laurent polynomials over a semiring `R`.  Mathematically, they are expressions of the
form
$$
\sum_{i \in \mathbb{Z}} a_i T ^ i
$$
where the sum extends over a finite subset of `ℤ`.  Thus, negative exponents are allowed.  The
coefficients come from the semiring `R` and the variable `T` commutes with everything.

Since we are going to convert back and forth between polynomials and Laurent polynomials, we
decided to maintain some distinction by using the symbol `T`, rather than `X`, as the variable for
Laurent polynomials

## Notation
The symbol `R[T;T⁻¹]` stands for `laurent_polynomial R`.  We also define

* `C : R →+* R[T;T⁻¹]` the inclusion of constant polynomials, analogous to the one for `R[X]`;
* `T : ℤ → R[T;T⁻¹]` the sequence of powers of the variable `T`.

## Implementation notes

We define Laurent polynomials as `add_monoid_algebra R ℤ`.
Thus, they are essentially `finsupp`s `ℤ →₀ R`.
This choice differs from the current irreducible design of `polynomial`, that instead shields away
the implementation via `finsupp`s.  It is closer to the original definition of polynomials.

As a consequence, `laurent_polynomial` plays well with polynomials, but there is a little roughness
in establishing the API, since the `finsupp` implementation of `R[X]` is well-shielded.

Unlike the case of polynomials, I felt that the exponent notation was not too easy to use, as only
natural exponents would be allowed.  Moreover, in the end, it seems likely that we should aim to
perform computations on exponents in `ℤ` anyway and separating this via the symbol `T` seems
convenient.

I made a *heavy* use of `simp` lemmas, aiming to bring Laurent polynomials to the form `C a * T n`.
Any comments or suggestions for improvements is greatly appreciated!

##  Future work
Lots is missing!
-- (Riccardo) add inclusion into Laurent series.
-- (Riccardo) giving a morphism (as `R`-alg, so in the commutative case)
  from `R[T,T⁻¹]` to `S` is the same as choosing a unit of `S`.
-- A "better" definition of `trunc` would be as an `R`-linear map.  This works:
--  ```
--  def trunc : R[T;T⁻¹] →[R] R[X] :=
--  begin
--    refine (_ : add_monoid_algebra R ℕ →[R] R[X]).comp _,
--    { exact ⟨(to_finsupp_iso R).symm, by simp⟩ },
--    { refine ⟨λ r, comap_domain _ r (set.inj_on_of_injective (λ a b ab, int.of_nat.inj ab) _), _⟩,
--      exact λ r f, comap_domain_smul _ _ _ }
--  end
--  ```
--  but it would make sense to bundle the maps better, for a smoother user experience.
--  I (DT) did not have the strength to embark on this (possibly short!) journey, after getting to
--  this stage of the Laurent process!
--  This would likely involve adding a `comap_domain` analogue of
--  `add_monoid_algebra.map_domain_alg_hom` and an `R`-linear version of
--  `polynomial.to_finsupp_iso`.
-- Add `degree, int_degree, int_trailing_degree, leading_coeff, trailing_coeff,...`.
-/


open scoped Polynomial BigOperators

open Polynomial AddMonoidAlgebra Finsupp

noncomputable section

variable {R : Type _}

#print LaurentPolynomial /-
/-- The semiring of Laurent polynomials with coefficients in the semiring `R`.
We denote it by `R[T;T⁻¹]`.
The ring homomorphism `C : R →+* R[T;T⁻¹]` includes `R` as the constant polynomials. -/
abbrev LaurentPolynomial (R : Type _) [Semiring R] :=
  AddMonoidAlgebra R ℤ
#align laurent_polynomial LaurentPolynomial
-/

local notation:9000 R "[T;T⁻¹]" => LaurentPolynomial R

#print Polynomial.toLaurent /-
/-- The ring homomorphism, taking a polynomial with coefficients in `R` to a Laurent polynomial
with coefficients in `R`. -/
def Polynomial.toLaurent [Semiring R] : R[X] →+* R[T;T⁻¹] :=
  (mapDomainRingHom R Int.ofNatHom).comp (toFinsuppIso R)
#align polynomial.to_laurent Polynomial.toLaurent
-/

#print Polynomial.toLaurent_apply /-
/-- This is not a simp lemma, as it is usually preferable to use the lemmas about `C` and `X`
instead. -/
theorem Polynomial.toLaurent_apply [Semiring R] (p : R[X]) :
    p.toLaurent = p.toFinsupp.mapDomain coe :=
  rfl
#align polynomial.to_laurent_apply Polynomial.toLaurent_apply
-/

#print Polynomial.toLaurentAlg /-
/-- The `R`-algebra map, taking a polynomial with coefficients in `R` to a Laurent polynomial
with coefficients in `R`. -/
def Polynomial.toLaurentAlg [CommSemiring R] : R[X] →ₐ[R] R[T;T⁻¹] :=
  by
  refine' AlgHom.comp _ (to_finsupp_iso_alg R).toAlgHom
  exact map_domain_alg_hom R R Int.ofNatHom
#align polynomial.to_laurent_alg Polynomial.toLaurentAlg
-/

#print Polynomial.toLaurentAlg_apply /-
@[simp]
theorem Polynomial.toLaurentAlg_apply [CommSemiring R] (f : R[X]) : f.toLaurentAlg = f.toLaurent :=
  rfl
#align polynomial.to_laurent_alg_apply Polynomial.toLaurentAlg_apply
-/

namespace LaurentPolynomial

section Semiring

variable [Semiring R]

#print LaurentPolynomial.single_zero_one_eq_one /-
theorem single_zero_one_eq_one : (single 0 1 : R[T;T⁻¹]) = (1 : R[T;T⁻¹]) :=
  rfl
#align laurent_polynomial.single_zero_one_eq_one LaurentPolynomial.single_zero_one_eq_one
-/

/-!  ### The functions `C` and `T`. -/


#print LaurentPolynomial.C /-
/-- The ring homomorphism `C`, including `R` into the ring of Laurent polynomials over `R` as
the constant Laurent polynomials. -/
def C : R →+* R[T;T⁻¹] :=
  singleZeroRingHom
#align laurent_polynomial.C LaurentPolynomial.C
-/

#print LaurentPolynomial.algebraMap_apply /-
theorem algebraMap_apply {R A : Type _} [CommSemiring R] [Semiring A] [Algebra R A] (r : R) :
    algebraMap R (LaurentPolynomial A) r = C (algebraMap R A r) :=
  rfl
#align laurent_polynomial.algebra_map_apply LaurentPolynomial.algebraMap_apply
-/

#print LaurentPolynomial.C_eq_algebraMap /-
/-- When we have `[comm_semiring R]`, the function `C` is the same as `algebra_map R R[T;T⁻¹]`.
(But note that `C` is defined when `R` is not necessarily commutative, in which case
`algebra_map` is not available.)
-/
theorem C_eq_algebraMap {R : Type _} [CommSemiring R] (r : R) : C r = algebraMap R R[T;T⁻¹] r :=
  rfl
#align laurent_polynomial.C_eq_algebra_map LaurentPolynomial.C_eq_algebraMap
-/

#print LaurentPolynomial.single_eq_C /-
theorem single_eq_C (r : R) : single 0 r = C r :=
  rfl
#align laurent_polynomial.single_eq_C LaurentPolynomial.single_eq_C
-/

#print LaurentPolynomial.T /-
/-- The function `n ↦ T ^ n`, implemented as a sequence `ℤ → R[T;T⁻¹]`.

Using directly `T ^ n` does not work, since we want the exponents to be of Type `ℤ` and there
is no `ℤ`-power defined on `R[T;T⁻¹]`.  Using that `T` is a unit introduces extra coercions.
For these reasons, the definition of `T` is as a sequence. -/
def T (n : ℤ) : R[T;T⁻¹] :=
  single n 1
#align laurent_polynomial.T LaurentPolynomial.T
-/

#print LaurentPolynomial.T_zero /-
@[simp]
theorem T_zero : (T 0 : R[T;T⁻¹]) = 1 :=
  rfl
#align laurent_polynomial.T_zero LaurentPolynomial.T_zero
-/

#print LaurentPolynomial.T_add /-
theorem T_add (m n : ℤ) : (T (m + n) : R[T;T⁻¹]) = T m * T n := by convert single_mul_single.symm;
  simp [T]
#align laurent_polynomial.T_add LaurentPolynomial.T_add
-/

#print LaurentPolynomial.T_sub /-
theorem T_sub (m n : ℤ) : (T (m - n) : R[T;T⁻¹]) = T m * T (-n) := by rw [← T_add, sub_eq_add_neg]
#align laurent_polynomial.T_sub LaurentPolynomial.T_sub
-/

#print LaurentPolynomial.T_pow /-
@[simp]
theorem T_pow (m : ℤ) (n : ℕ) : (T m ^ n : R[T;T⁻¹]) = T (n * m) := by
  rw [T, T, single_pow n, one_pow, nsmul_eq_mul]
#align laurent_polynomial.T_pow LaurentPolynomial.T_pow
-/

#print LaurentPolynomial.mul_T_assoc /-
/-- The `simp` version of `mul_assoc`, in the presence of `T`'s. -/
@[simp]
theorem mul_T_assoc (f : R[T;T⁻¹]) (m n : ℤ) : f * T m * T n = f * T (m + n) := by
  simp [← T_add, mul_assoc]
#align laurent_polynomial.mul_T_assoc LaurentPolynomial.mul_T_assoc
-/

#print LaurentPolynomial.single_eq_C_mul_T /-
@[simp]
theorem single_eq_C_mul_T (r : R) (n : ℤ) : (single n r : R[T;T⁻¹]) = (C r * T n : R[T;T⁻¹]) := by
  convert single_mul_single.symm <;> simp
#align laurent_polynomial.single_eq_C_mul_T LaurentPolynomial.single_eq_C_mul_T
-/

#print Polynomial.toLaurent_C_mul_T /-
-- This lemma locks in the right changes and is what Lean proved directly.
-- The actual `simp`-normal form of a Laurent monomial is `C a * T n`, whenever it can be reached.
@[simp]
theorem Polynomial.toLaurent_C_mul_T (n : ℕ) (r : R) :
    ((Polynomial.monomial n r).toLaurent : R[T;T⁻¹]) = C r * T n :=
  show mapDomain coe (monomial n r).toFinsupp = (C r * T n : R[T;T⁻¹]) by
    rw [to_finsupp_monomial, map_domain_single, single_eq_C_mul_T]
#align polynomial.to_laurent_C_mul_T Polynomial.toLaurent_C_mul_T
-/

#print Polynomial.toLaurent_C /-
@[simp]
theorem Polynomial.toLaurent_C (r : R) : (Polynomial.C r).toLaurent = C r :=
  by
  convert Polynomial.toLaurent_C_mul_T 0 r
  simp only [Int.ofNat_zero, T_zero, mul_one]
#align polynomial.to_laurent_C Polynomial.toLaurent_C
-/

#print Polynomial.toLaurent_X /-
@[simp]
theorem Polynomial.toLaurent_X : (Polynomial.X.toLaurent : R[T;T⁻¹]) = T 1 :=
  by
  have : (Polynomial.X : R[X]) = monomial 1 1 := by simp [← C_mul_X_pow_eq_monomial]
  simp [this, Polynomial.toLaurent_C_mul_T]
#align polynomial.to_laurent_X Polynomial.toLaurent_X
-/

#print Polynomial.toLaurent_one /-
@[simp]
theorem Polynomial.toLaurent_one : (Polynomial.toLaurent : R[X] → R[T;T⁻¹]) 1 = 1 :=
  map_one Polynomial.toLaurent
#align polynomial.to_laurent_one Polynomial.toLaurent_one
-/

#print Polynomial.toLaurent_C_mul_eq /-
@[simp]
theorem Polynomial.toLaurent_C_mul_eq (r : R) (f : R[X]) :
    (Polynomial.C r * f).toLaurent = C r * f.toLaurent := by
  simp only [_root_.map_mul, Polynomial.toLaurent_C]
#align polynomial.to_laurent_C_mul_eq Polynomial.toLaurent_C_mul_eq
-/

#print Polynomial.toLaurent_X_pow /-
@[simp]
theorem Polynomial.toLaurent_X_pow (n : ℕ) : (X ^ n : R[X]).toLaurent = T n := by
  simp only [map_pow, Polynomial.toLaurent_X, T_pow, mul_one]
#align polynomial.to_laurent_X_pow Polynomial.toLaurent_X_pow
-/

#print Polynomial.toLaurent_C_mul_X_pow /-
@[simp]
theorem Polynomial.toLaurent_C_mul_X_pow (n : ℕ) (r : R) :
    (Polynomial.C r * X ^ n).toLaurent = C r * T n := by
  simp only [_root_.map_mul, Polynomial.toLaurent_C, Polynomial.toLaurent_X_pow]
#align polynomial.to_laurent_C_mul_X_pow Polynomial.toLaurent_C_mul_X_pow
-/

#print LaurentPolynomial.invertibleT /-
instance invertibleT (n : ℤ) : Invertible (T n : R[T;T⁻¹])
    where
  invOf := T (-n)
  invOf_mul_self := by rw [← T_add, add_left_neg, T_zero]
  mul_invOf_self := by rw [← T_add, add_right_neg, T_zero]
#align laurent_polynomial.invertible_T LaurentPolynomial.invertibleT
-/

#print LaurentPolynomial.invOf_T /-
@[simp]
theorem invOf_T (n : ℤ) : ⅟ (T n : R[T;T⁻¹]) = T (-n) :=
  rfl
#align laurent_polynomial.inv_of_T LaurentPolynomial.invOf_T
-/

#print LaurentPolynomial.isUnit_T /-
theorem isUnit_T (n : ℤ) : IsUnit (T n : R[T;T⁻¹]) :=
  isUnit_of_invertible _
#align laurent_polynomial.is_unit_T LaurentPolynomial.isUnit_T
-/

#print LaurentPolynomial.induction_on /-
@[elab_as_elim]
protected theorem induction_on {M : R[T;T⁻¹] → Prop} (p : R[T;T⁻¹]) (h_C : ∀ a, M (C a))
    (h_add : ∀ {p q}, M p → M q → M (p + q))
    (h_C_mul_T : ∀ (n : ℕ) (a : R), M (C a * T n) → M (C a * T (n + 1)))
    (h_C_mul_T_Z : ∀ (n : ℕ) (a : R), M (C a * T (-n)) → M (C a * T (-n - 1))) : M p :=
  by
  have A : ∀ {n : ℤ} {a : R}, M (C a * T n) :=
    by
    intro n a
    apply n.induction_on
    · simpa only [T_zero, mul_one] using h_C a
    · exact fun m => h_C_mul_T m a
    · exact fun m => h_C_mul_T_Z m a
  have B : ∀ s : Finset ℤ, M (s.Sum fun n : ℤ => C (p.to_fun n) * T n) :=
    by
    apply Finset.induction
    · convert h_C 0; simp only [Finset.sum_empty, _root_.map_zero]
    · intro n s ns ih; rw [Finset.sum_insert ns]; exact h_add A ih
  convert B p.support
  ext a
  simp_rw [← single_eq_C_mul_T, Finset.sum_apply', single_apply, Finset.sum_ite_eq']
  split_ifs with h h
  · rfl
  · exact finsupp.not_mem_support_iff.mp h
#align laurent_polynomial.induction_on LaurentPolynomial.induction_on
-/

#print LaurentPolynomial.induction_on' /-
/-- To prove something about Laurent polynomials, it suffices to show that
* the condition is closed under taking sums, and
* it holds for monomials.
-/
@[elab_as_elim]
protected theorem induction_on' {M : R[T;T⁻¹] → Prop} (p : R[T;T⁻¹])
    (h_add : ∀ p q, M p → M q → M (p + q)) (h_C_mul_T : ∀ (n : ℤ) (a : R), M (C a * T n)) : M p :=
  by
  refine' p.induction_on (fun a => _) h_add _ _ <;> try exact fun n f _ => h_C_mul_T _ f
  convert h_C_mul_T 0 a
  exact (mul_one _).symm
#align laurent_polynomial.induction_on' LaurentPolynomial.induction_on'
-/

#print LaurentPolynomial.commute_T /-
theorem commute_T (n : ℤ) (f : R[T;T⁻¹]) : Commute (T n) f :=
  f.inductionOn' (fun p q Tp Tq => Commute.add_right Tp Tq) fun m a =>
    show T n * _ = _
      by
      rw [T, T, ← single_eq_C, single_mul_single, single_mul_single, single_mul_single]
      simp [add_comm]
#align laurent_polynomial.commute_T LaurentPolynomial.commute_T
-/

#print LaurentPolynomial.T_mul /-
@[simp]
theorem T_mul (n : ℤ) (f : R[T;T⁻¹]) : T n * f = f * T n :=
  (commute_T n f).Eq
#align laurent_polynomial.T_mul LaurentPolynomial.T_mul
-/

#print LaurentPolynomial.trunc /-
/-- `trunc : R[T;T⁻¹] →+ R[X]` maps a Laurent polynomial `f` to the polynomial whose terms of
nonnegative degree coincide with the ones of `f`.  The terms of negative degree of `f` "vanish".
`trunc` is a left-inverse to `polynomial.to_laurent`. -/
def trunc : R[T;T⁻¹] →+ R[X] :=
  (toFinsuppIso R).symm.toAddMonoidHom.comp <| comapDomain.addMonoidHom fun a b => Int.ofNat.inj
#align laurent_polynomial.trunc LaurentPolynomial.trunc
-/

#print LaurentPolynomial.trunc_C_mul_T /-
@[simp]
theorem trunc_C_mul_T (n : ℤ) (r : R) : trunc (C r * T n) = ite (0 ≤ n) (monomial n.toNat r) 0 :=
  by
  apply (to_finsupp_iso R).Injective
  rw [← single_eq_C_mul_T, Trunc, AddMonoidHom.coe_comp, Function.comp_apply,
    comap_domain.add_monoid_hom_apply, to_finsupp_iso_apply]
  by_cases n0 : 0 ≤ n
  · lift n to ℕ using n0
    erw [comap_domain_single, to_finsupp_iso_symm_apply]
    simp only [Int.coe_nat_nonneg, Int.toNat_coe_nat, if_true, to_finsupp_iso_apply,
      to_finsupp_monomial]
  · lift -n to ℕ using (neg_pos.mpr (not_le.mp n0)).le with m
    rw [to_finsupp_iso_apply, to_finsupp_inj, if_neg n0]
    erw [to_finsupp_iso_symm_apply]
    ext a
    have := ((not_le.mp n0).trans_le (Int.ofNat_zero_le a)).ne'
    simp only [coeff, comap_domain_apply, Int.ofNat_eq_coe, coeff_zero, single_apply_eq_zero, this,
      IsEmpty.forall_iff]
#align laurent_polynomial.trunc_C_mul_T LaurentPolynomial.trunc_C_mul_T
-/

#print LaurentPolynomial.leftInverse_trunc_toLaurent /-
@[simp]
theorem leftInverse_trunc_toLaurent :
    Function.LeftInverse (trunc : R[T;T⁻¹] → R[X]) Polynomial.toLaurent :=
  by
  refine' fun f => f.inductionOn' _ _
  · exact fun f g hf hg => by simp only [hf, hg, _root_.map_add]
  ·
    exact fun n r => by
      simp only [Polynomial.toLaurent_C_mul_T, trunc_C_mul_T, Int.coe_nat_nonneg, Int.toNat_coe_nat,
        if_true]
#align laurent_polynomial.left_inverse_trunc_to_laurent LaurentPolynomial.leftInverse_trunc_toLaurent
-/

#print Polynomial.trunc_toLaurent /-
@[simp]
theorem Polynomial.trunc_toLaurent (f : R[X]) : trunc f.toLaurent = f :=
  leftInverse_trunc_toLaurent _
#align polynomial.trunc_to_laurent Polynomial.trunc_toLaurent
-/

#print Polynomial.toLaurent_injective /-
theorem Polynomial.toLaurent_injective :
    Function.Injective (Polynomial.toLaurent : R[X] → R[T;T⁻¹]) :=
  leftInverse_trunc_toLaurent.Injective
#align polynomial.to_laurent_injective Polynomial.toLaurent_injective
-/

#print Polynomial.toLaurent_inj /-
@[simp]
theorem Polynomial.toLaurent_inj (f g : R[X]) : f.toLaurent = g.toLaurent ↔ f = g :=
  ⟨fun h => Polynomial.toLaurent_injective h, congr_arg _⟩
#align polynomial.to_laurent_inj Polynomial.toLaurent_inj
-/

#print Polynomial.toLaurent_ne_zero /-
theorem Polynomial.toLaurent_ne_zero {f : R[X]} : f ≠ 0 ↔ f.toLaurent ≠ 0 :=
  (map_ne_zero_iff _ Polynomial.toLaurent_injective).symm
#align polynomial.to_laurent_ne_zero Polynomial.toLaurent_ne_zero
-/

#print LaurentPolynomial.exists_T_pow /-
theorem exists_T_pow (f : R[T;T⁻¹]) : ∃ (n : ℕ) (f' : R[X]), f'.toLaurent = f * T n :=
  by
  apply f.induction_on' _ fun n a => _ <;> clear f
  · rintro f g ⟨m, fn, hf⟩ ⟨n, gn, hg⟩
    refine' ⟨m + n, fn * X ^ n + gn * X ^ m, _⟩
    simp only [hf, hg, add_mul, add_comm (n : ℤ), map_add, map_mul, Polynomial.toLaurent_X_pow,
      mul_T_assoc, Int.ofNat_add]
  · cases' n with n n
    · exact ⟨0, Polynomial.C a * X ^ n, by simp⟩
    · refine' ⟨n + 1, Polynomial.C a, _⟩
      simp only [Int.negSucc_eq, Polynomial.toLaurent_C, Int.ofNat_succ, mul_T_assoc, add_left_neg,
        T_zero, mul_one]
#align laurent_polynomial.exists_T_pow LaurentPolynomial.exists_T_pow
-/

#print LaurentPolynomial.induction_on_mul_T /-
/-- This is a version of `exists_T_pow` stated as an induction principle. -/
@[elab_as_elim]
theorem induction_on_mul_T {Q : R[T;T⁻¹] → Prop} (f : R[T;T⁻¹])
    (Qf : ∀ {f : R[X]} {n : ℕ}, Q (f.toLaurent * T (-n))) : Q f :=
  by
  rcases f.exists_T_pow with ⟨n, f', hf⟩
  rw [← mul_one f, ← T_zero, ← Nat.cast_zero, ← Nat.sub_self n, Nat.cast_sub rfl.le, T_sub, ←
    mul_assoc, ← hf]
  exact Qf
#align laurent_polynomial.induction_on_mul_T LaurentPolynomial.induction_on_mul_T
-/

#print LaurentPolynomial.reduce_to_polynomial_of_mul_T /-
/-- Suppose that `Q` is a statement about Laurent polynomials such that
* `Q` is true on *ordinary* polynomials;
* `Q (f * T)` implies `Q f`;
it follow that `Q` is true on all Laurent polynomials. -/
theorem reduce_to_polynomial_of_mul_T (f : R[T;T⁻¹]) {Q : R[T;T⁻¹] → Prop}
    (Qf : ∀ f : R[X], Q f.toLaurent) (QT : ∀ f, Q (f * T 1) → Q f) : Q f :=
  by
  induction' f using LaurentPolynomial.induction_on_mul_T with f n
  induction' n with n hn
  · simpa only [Int.ofNat_zero, neg_zero, T_zero, mul_one] using Qf _
  · convert QT _ _
    simpa using hn
#align laurent_polynomial.reduce_to_polynomial_of_mul_T LaurentPolynomial.reduce_to_polynomial_of_mul_T
-/

section Support

#print LaurentPolynomial.support_C_mul_T /-
theorem support_C_mul_T (a : R) (n : ℤ) : (C a * T n).support ⊆ {n} := by
  simpa only [← single_eq_C_mul_T] using support_single_subset
#align laurent_polynomial.support_C_mul_T LaurentPolynomial.support_C_mul_T
-/

#print LaurentPolynomial.support_C_mul_T_of_ne_zero /-
theorem support_C_mul_T_of_ne_zero {a : R} (a0 : a ≠ 0) (n : ℤ) : (C a * T n).support = {n} :=
  by
  rw [← single_eq_C_mul_T]
  exact support_single_ne_zero _ a0
#align laurent_polynomial.support_C_mul_T_of_ne_zero LaurentPolynomial.support_C_mul_T_of_ne_zero
-/

#print LaurentPolynomial.toLaurent_support /-
/-- The support of a polynomial `f` is a finset in `ℕ`.  The lemma `to_laurent_support f`
shows that the support of `f.to_laurent` is the same finset, but viewed in `ℤ` under the natural
inclusion `ℕ ↪ ℤ`. -/
theorem toLaurent_support (f : R[X]) : f.toLaurent.support = f.support.map Nat.castEmbedding :=
  by
  generalize hd : f.support = s
  revert f
  refine' Finset.induction_on s _ _ <;> clear s
  ·
    simp (config := { contextual := true }) only [Polynomial.support_eq_empty, map_zero,
      Finsupp.support_zero, eq_self_iff_true, imp_true_iff, Finset.map_empty]
  · intro a s as hf f fs
    have : (erase a f).toLaurent.support = s.map Nat.castEmbedding :=
      hf (f.erase a)
        (by
          simp only [fs, Finset.erase_eq_of_not_mem as, Polynomial.support_erase,
            Finset.erase_insert_eq_erase])
    rw [← monomial_add_erase f a, Finset.map_insert, ← this, map_add, Polynomial.toLaurent_C_mul_T,
      support_add_eq, Finset.insert_eq]
    · congr
      exact support_C_mul_T_of_ne_zero (polynomial.mem_support_iff.mp (by simp [fs])) _
    · rw [this]
      exact Disjoint.mono_left (support_C_mul_T _ _) (by simpa)
#align laurent_polynomial.to_laurent_support LaurentPolynomial.toLaurent_support
-/

end Support

section Degrees

#print LaurentPolynomial.degree /-
/-- The degree of a Laurent polynomial takes values in `with_bot ℤ`.
If `f : R[T;T⁻¹]` is a Laurent polynomial, then `f.degree` is the maximum of its support of `f`,
or `⊥`, if `f = 0`. -/
def degree (f : R[T;T⁻¹]) : WithBot ℤ :=
  f.support.max
#align laurent_polynomial.degree LaurentPolynomial.degree
-/

#print LaurentPolynomial.degree_zero /-
@[simp]
theorem degree_zero : degree (0 : R[T;T⁻¹]) = ⊥ :=
  rfl
#align laurent_polynomial.degree_zero LaurentPolynomial.degree_zero
-/

#print LaurentPolynomial.degree_eq_bot_iff /-
@[simp]
theorem degree_eq_bot_iff {f : R[T;T⁻¹]} : f.degree = ⊥ ↔ f = 0 :=
  by
  refine' ⟨fun h => _, fun h => by rw [h, degree_zero]⟩
  rw [degree, Finset.max_eq_sup_withBot] at h 
  ext n
  refine' not_not.mp fun f0 => _
  simp_rw [Finset.sup_eq_bot_iff, Finsupp.mem_support_iff, Ne.def, WithBot.coe_ne_bot] at h 
  exact h n f0
#align laurent_polynomial.degree_eq_bot_iff LaurentPolynomial.degree_eq_bot_iff
-/

section ExactDegrees

open scoped Classical

#print LaurentPolynomial.degree_C_mul_T /-
@[simp]
theorem degree_C_mul_T (n : ℤ) (a : R) (a0 : a ≠ 0) : (C a * T n).degree = n :=
  by
  rw [degree]
  convert Finset.max_singleton
  refine' support_eq_singleton.mpr _
  simp only [← single_eq_C_mul_T, single_eq_same, a0, Ne.def, not_false_iff, eq_self_iff_true,
    and_self_iff]
#align laurent_polynomial.degree_C_mul_T LaurentPolynomial.degree_C_mul_T
-/

#print LaurentPolynomial.degree_C_mul_T_ite /-
theorem degree_C_mul_T_ite (n : ℤ) (a : R) : (C a * T n).degree = ite (a = 0) ⊥ n := by
  split_ifs with h h <;>
    simp only [h, map_zero, MulZeroClass.zero_mul, degree_zero, degree_C_mul_T, Ne.def,
      not_false_iff]
#align laurent_polynomial.degree_C_mul_T_ite LaurentPolynomial.degree_C_mul_T_ite
-/

#print LaurentPolynomial.degree_T /-
@[simp]
theorem degree_T [Nontrivial R] (n : ℤ) : (T n : R[T;T⁻¹]).degree = n :=
  by
  rw [← one_mul (T n), ← map_one C]
  exact degree_C_mul_T n 1 (one_ne_zero : (1 : R) ≠ 0)
#align laurent_polynomial.degree_T LaurentPolynomial.degree_T
-/

#print LaurentPolynomial.degree_C /-
theorem degree_C {a : R} (a0 : a ≠ 0) : (C a).degree = 0 :=
  by
  rw [← mul_one (C a), ← T_zero]
  exact degree_C_mul_T 0 a a0
#align laurent_polynomial.degree_C LaurentPolynomial.degree_C
-/

#print LaurentPolynomial.degree_C_ite /-
theorem degree_C_ite (a : R) : (C a).degree = ite (a = 0) ⊥ 0 := by
  split_ifs with h h <;> simp only [h, map_zero, degree_zero, degree_C, Ne.def, not_false_iff]
#align laurent_polynomial.degree_C_ite LaurentPolynomial.degree_C_ite
-/

end ExactDegrees

section DegreeBounds

#print LaurentPolynomial.degree_C_mul_T_le /-
theorem degree_C_mul_T_le (n : ℤ) (a : R) : (C a * T n).degree ≤ n :=
  by
  by_cases a0 : a = 0
  · simp only [a0, map_zero, MulZeroClass.zero_mul, degree_zero, bot_le]
  · exact (degree_C_mul_T n a a0).le
#align laurent_polynomial.degree_C_mul_T_le LaurentPolynomial.degree_C_mul_T_le
-/

#print LaurentPolynomial.degree_T_le /-
theorem degree_T_le (n : ℤ) : (T n : R[T;T⁻¹]).degree ≤ n :=
  (le_of_eq (by rw [map_one, one_mul])).trans (degree_C_mul_T_le n (1 : R))
#align laurent_polynomial.degree_T_le LaurentPolynomial.degree_T_le
-/

#print LaurentPolynomial.degree_C_le /-
theorem degree_C_le (a : R) : (C a).degree ≤ 0 :=
  (le_of_eq (by rw [T_zero, mul_one])).trans (degree_C_mul_T_le 0 a)
#align laurent_polynomial.degree_C_le LaurentPolynomial.degree_C_le
-/

end DegreeBounds

end Degrees

instance : Module R[X] R[T;T⁻¹] :=
  Module.compHom _ Polynomial.toLaurent

instance (R : Type _) [Semiring R] : IsScalarTower R[X] R[X] R[T;T⁻¹]
    where smul_assoc x y z := by simp only [SMul.smul, SMul.comp.smul, map_mul, mul_assoc]

end Semiring

section CommSemiring

variable [CommSemiring R]

#print LaurentPolynomial.algebraPolynomial /-
instance algebraPolynomial (R : Type _) [CommSemiring R] : Algebra R[X] R[T;T⁻¹] :=
  { Polynomial.toLaurent with
    commutes' := fun f l => by simp [mul_comm]
    smul_def' := fun f l => rfl }
#align laurent_polynomial.algebra_polynomial LaurentPolynomial.algebraPolynomial
-/

#print LaurentPolynomial.algebraMap_X_pow /-
theorem algebraMap_X_pow (n : ℕ) : algebraMap R[X] R[T;T⁻¹] (X ^ n) = T n :=
  Polynomial.toLaurent_X_pow n
#align laurent_polynomial.algebra_map_X_pow LaurentPolynomial.algebraMap_X_pow
-/

#print LaurentPolynomial.algebraMap_eq_toLaurent /-
@[simp]
theorem algebraMap_eq_toLaurent (f : R[X]) : algebraMap R[X] R[T;T⁻¹] f = f.toLaurent :=
  rfl
#align laurent_polynomial.algebra_map_eq_to_laurent LaurentPolynomial.algebraMap_eq_toLaurent
-/

#print LaurentPolynomial.isLocalization /-
theorem isLocalization : IsLocalization (Submonoid.closure ({X} : Set R[X])) R[T;T⁻¹] :=
  { map_units := fun t => by
      cases' t with t ht
      rcases submonoid.mem_closure_singleton.mp ht with ⟨n, rfl⟩
      simp only [is_unit_T n, SetLike.coe_mk, algebra_map_eq_to_laurent, Polynomial.toLaurent_X_pow]
    surj := fun f =>
      by
      induction' f using LaurentPolynomial.induction_on_mul_T with f n
      have := (Submonoid.closure ({X} : Set R[X])).pow_mem Submonoid.mem_closure_singleton_self n
      refine' ⟨(f, ⟨_, this⟩), _⟩
      simp only [SetLike.coe_mk, algebra_map_eq_to_laurent, Polynomial.toLaurent_X_pow, mul_T_assoc,
        add_left_neg, T_zero, mul_one]
    eq_iff_exists := fun f g =>
      by
      rw [algebra_map_eq_to_laurent, algebra_map_eq_to_laurent, Polynomial.toLaurent_inj]
      refine' ⟨_, _⟩
      · rintro rfl
        exact ⟨1, rfl⟩
      · rintro ⟨⟨h, hX⟩, h⟩
        rcases submonoid.mem_closure_singleton.mp hX with ⟨n, rfl⟩
        exact mul_X_pow_injective n h }
#align laurent_polynomial.is_localization LaurentPolynomial.isLocalization
-/

end CommSemiring

end LaurentPolynomial

