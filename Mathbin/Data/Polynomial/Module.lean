/-
Copyright (c) 2022 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang

! This file was ported from Lean 3 source module data.polynomial.module
! leanprover-community/mathlib commit 4f81bc21e32048db7344b7867946e992cf5f68cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.FiniteType

/-!
# Polynomial module

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we define the polynomial module for an `R`-module `M`, i.e. the `R[X]`-module `M[X]`.

This is defined as an type alias `polynomial_module R M := ℕ →₀ M`, since there might be different
module structures on `ℕ →₀ M` of interest. See the docstring of `polynomial_module` for details.

-/


universe u v

open Polynomial

open scoped Polynomial BigOperators

variable (R M : Type _) [CommRing R] [AddCommGroup M] [Module R M] (I : Ideal R)

#print PolynomialModule /-
/-- The `R[X]`-module `M[X]` for an `R`-module `M`.
This is isomorphic (as an `R`-module) to `M[X]` when `M` is a ring.

We require all the module instances `module S (polynomial_module R M)` to factor through `R` except
`module R[X] (polynomial_module R M)`.
In this constraint, we have the following instances for example :
- `R` acts on `polynomial_module R R[X]`
- `R[X]` acts on `polynomial_module R R[X]` as `R[Y]` acting on `R[X][Y]`
- `R` acts on `polynomial_module R[X] R[X]`
- `R[X]` acts on `polynomial_module R[X] R[X]` as `R[X]` acting on `R[X][Y]`
- `R[X][X]` acts on `polynomial_module R[X] R[X]` as `R[X][Y]` acting on itself

This is also the reason why `R` is included in the alias, or else there will be two different
instances of `module R[X] (polynomial_module R[X])`.

See https://leanprover.zulipchat.com/#narrow/stream/144837-PR-reviews/topic/.2315065.20polynomial.20modules
for the full discussion.
-/
@[nolint unused_arguments]
def PolynomialModule :=
  ℕ →₀ M
deriving AddCommGroup, Inhabited
#align polynomial_module PolynomialModule
-/

variable {M}

variable {S : Type _} [CommSemiring S] [Algebra S R] [Module S M] [IsScalarTower S R M]

namespace PolynomialModule

/-- This is required to have the `is_scalar_tower S R M` instance to avoid diamonds. -/
@[nolint unused_arguments]
noncomputable instance : Module S (PolynomialModule R M) :=
  Finsupp.module ℕ M

instance : CoeFun (PolynomialModule R M) fun _ => ℕ → M :=
  Finsupp.coeFun

#print PolynomialModule.single /-
/-- The monomial `m * x ^ i`. This is defeq to `finsupp.single_add_hom`, and is redefined here
so that it has the desired type signature.  -/
noncomputable def single (i : ℕ) : M →+ PolynomialModule R M :=
  Finsupp.singleAddHom i
#align polynomial_module.single PolynomialModule.single
-/

#print PolynomialModule.single_apply /-
theorem single_apply (i : ℕ) (m : M) (n : ℕ) : single R i m n = ite (i = n) m 0 :=
  Finsupp.single_apply
#align polynomial_module.single_apply PolynomialModule.single_apply
-/

#print PolynomialModule.lsingle /-
/-- `polynomial_module.single` as a linear map. -/
noncomputable def lsingle (i : ℕ) : M →ₗ[R] PolynomialModule R M :=
  Finsupp.lsingle i
#align polynomial_module.lsingle PolynomialModule.lsingle
-/

#print PolynomialModule.lsingle_apply /-
theorem lsingle_apply (i : ℕ) (m : M) (n : ℕ) : lsingle R i m n = ite (i = n) m 0 :=
  Finsupp.single_apply
#align polynomial_module.lsingle_apply PolynomialModule.lsingle_apply
-/

#print PolynomialModule.single_smul /-
theorem single_smul (i : ℕ) (r : R) (m : M) : single R i (r • m) = r • single R i m :=
  (lsingle R i).map_smul r m
#align polynomial_module.single_smul PolynomialModule.single_smul
-/

variable {R}

#print PolynomialModule.induction_linear /-
theorem induction_linear {P : PolynomialModule R M → Prop} (f : PolynomialModule R M) (h0 : P 0)
    (hadd : ∀ f g, P f → P g → P (f + g)) (hsingle : ∀ a b, P (single R a b)) : P f :=
  Finsupp.induction_linear f h0 hadd hsingle
#align polynomial_module.induction_linear PolynomialModule.induction_linear
-/

#print PolynomialModule.polynomialModule /-
@[semireducible]
noncomputable instance polynomialModule : Module R[X] (PolynomialModule R M) :=
  modulePolynomialOfEndo (Finsupp.lmapDomain _ _ Nat.succ)
#align polynomial_module.polynomial_module PolynomialModule.polynomialModule
-/

instance (M : Type u) [AddCommGroup M] [Module R M] [Module S M] [IsScalarTower S R M] :
    IsScalarTower S R (PolynomialModule R M) :=
  Finsupp.isScalarTower _ _

#print PolynomialModule.isScalarTower' /-
instance isScalarTower' (M : Type u) [AddCommGroup M] [Module R M] [Module S M]
    [IsScalarTower S R M] : IsScalarTower S R[X] (PolynomialModule R M) :=
  by
  haveI : IsScalarTower R R[X] (PolynomialModule R M) := modulePolynomialOfEndo.isScalarTower _
  constructor
  intro x y z
  rw [← @IsScalarTower.algebraMap_smul S R, ← @IsScalarTower.algebraMap_smul S R, smul_assoc]
#align polynomial_module.is_scalar_tower' PolynomialModule.isScalarTower'
-/

#print PolynomialModule.monomial_smul_single /-
@[simp]
theorem monomial_smul_single (i : ℕ) (r : R) (j : ℕ) (m : M) :
    monomial i r • single R j m = single R (i + j) (r • m) :=
  by
  simp only [LinearMap.mul_apply, Polynomial.aeval_monomial, LinearMap.pow_apply,
    Module.algebraMap_end_apply, modulePolynomialOfEndo_smul_def]
  induction i generalizing r j m
  · simp [single]
  · rw [Function.iterate_succ, Function.comp_apply, Nat.succ_eq_add_one, add_assoc, ← i_ih]
    congr 2
    ext a
    dsimp [single]
    rw [Finsupp.mapDomain_single, Nat.succ_eq_one_add]
#align polynomial_module.monomial_smul_single PolynomialModule.monomial_smul_single
-/

#print PolynomialModule.monomial_smul_apply /-
@[simp]
theorem monomial_smul_apply (i : ℕ) (r : R) (g : PolynomialModule R M) (n : ℕ) :
    (monomial i r • g) n = ite (i ≤ n) (r • g (n - i)) 0 :=
  by
  induction' g using PolynomialModule.induction_linear with p q hp hq
  · simp only [smul_zero, Finsupp.zero_apply, if_t_t]
  · simp only [smul_add, Finsupp.add_apply, hp, hq]
    split_ifs; exacts [rfl, zero_add 0]
  · rw [monomial_smul_single, single_apply, single_apply, smul_ite, smul_zero, ← ite_and]
    congr
    rw [eq_iff_iff]
    constructor
    · rintro rfl; simp
    · rintro ⟨e, rfl⟩; rw [add_comm, tsub_add_cancel_of_le e]
#align polynomial_module.monomial_smul_apply PolynomialModule.monomial_smul_apply
-/

#print PolynomialModule.smul_single_apply /-
@[simp]
theorem smul_single_apply (i : ℕ) (f : R[X]) (m : M) (n : ℕ) :
    (f • single R i m) n = ite (i ≤ n) (f.coeff (n - i) • m) 0 :=
  by
  induction' f using Polynomial.induction_on' with p q hp hq
  · rw [add_smul, Finsupp.add_apply, hp, hq, coeff_add, add_smul]
    split_ifs; exacts [rfl, zero_add 0]
  · rw [monomial_smul_single, single_apply, coeff_monomial, ite_smul, zero_smul]
    by_cases h : i ≤ n
    · simp_rw [eq_tsub_iff_add_eq_of_le h, if_pos h]
    · rw [if_neg h, ite_eq_right_iff]; intro e; exfalso; linarith
#align polynomial_module.smul_single_apply PolynomialModule.smul_single_apply
-/

#print PolynomialModule.smul_apply /-
theorem smul_apply (f : R[X]) (g : PolynomialModule R M) (n : ℕ) :
    (f • g) n = ∑ x in Finset.Nat.antidiagonal n, f.coeff x.1 • g x.2 :=
  by
  induction' f using Polynomial.induction_on' with p q hp hq
  · rw [add_smul, Finsupp.add_apply, hp, hq, ← Finset.sum_add_distrib]
    congr
    ext
    rw [coeff_add, add_smul]
  · rw [Finset.Nat.sum_antidiagonal_eq_sum_range_succ fun i j => (monomial f_n f_a).coeff i • g j,
      monomial_smul_apply]
    dsimp [monomial]
    simp_rw [Finsupp.single_smul, Finsupp.single_apply]
    rw [Finset.sum_ite_eq]
    simp [Nat.lt_succ_iff]
#align polynomial_module.smul_apply PolynomialModule.smul_apply
-/

#print PolynomialModule.equivPolynomialSelf /-
/-- `polynomial_module R R` is isomorphic to `R[X]` as an `R[X]` module. -/
noncomputable def equivPolynomialSelf : PolynomialModule R R ≃ₗ[R[X]] R[X] :=
  { (Polynomial.toFinsuppIso R).symm with
    map_smul' := fun r x =>
      by
      induction' r using Polynomial.induction_on' with _ _ _ _ n p
      · simp_all only [add_smul, map_add, RingEquiv.toFun_eq_coe]
      · ext i
        dsimp
        rw [monomial_smul_apply, ← Polynomial.C_mul_X_pow_eq_monomial, mul_assoc,
          Polynomial.coeff_C_mul, Polynomial.coeff_X_pow_mul', mul_ite, MulZeroClass.mul_zero]
        simp }
#align polynomial_module.equiv_polynomial_self PolynomialModule.equivPolynomialSelf
-/

#print PolynomialModule.equivPolynomial /-
/-- `polynomial_module R S` is isomorphic to `S[X]` as an `R` module. -/
noncomputable def equivPolynomial {S : Type _} [CommRing S] [Algebra R S] :
    PolynomialModule R S ≃ₗ[R] S[X] :=
  { (Polynomial.toFinsuppIso S).symm with map_smul' := fun r x => rfl }
#align polynomial_module.equiv_polynomial PolynomialModule.equivPolynomial
-/

variable (R' : Type _) {M' : Type _} [CommRing R'] [AddCommGroup M'] [Module R' M']

variable [Algebra R R'] [Module R M'] [IsScalarTower R R' M']

#print PolynomialModule.map /-
/-- The image of a polynomial under a linear map. -/
noncomputable def map (f : M →ₗ[R] M') : PolynomialModule R M →ₗ[R] PolynomialModule R' M' :=
  Finsupp.mapRange.linearMap f
#align polynomial_module.map PolynomialModule.map
-/

#print PolynomialModule.map_single /-
@[simp]
theorem map_single (f : M →ₗ[R] M') (i : ℕ) (m : M) : map R' f (single R i m) = single R' i (f m) :=
  Finsupp.mapRange_single
#align polynomial_module.map_single PolynomialModule.map_single
-/

#print PolynomialModule.map_smul /-
theorem map_smul (f : M →ₗ[R] M') (p : R[X]) (q : PolynomialModule R M) :
    map R' f (p • q) = p.map (algebraMap R R') • map R' f q :=
  by
  apply induction_linear q
  · rw [smul_zero, map_zero, smul_zero]
  · intro f g e₁ e₂; rw [smul_add, map_add, e₁, e₂, map_add, smul_add]
  intro i m
  apply Polynomial.induction_on' p
  · intro p q e₁ e₂; rw [add_smul, map_add, e₁, e₂, Polynomial.map_add, add_smul]
  · intro j s
    rw [monomial_smul_single, map_single, Polynomial.map_monomial, map_single, monomial_smul_single,
      f.map_smul, algebraMap_smul]
#align polynomial_module.map_smul PolynomialModule.map_smul
-/

#print PolynomialModule.eval /-
/-- Evaulate a polynomial `p : polynomial_module R M` at `r : R`. -/
@[simps (config := lemmasOnly)]
def eval (r : R) : PolynomialModule R M →ₗ[R] M
    where
  toFun p := p.Sum fun i m => r ^ i • m
  map_add' x y := Finsupp.sum_add_index' (fun _ => smul_zero _) fun _ _ _ => smul_add _ _ _
  map_smul' s m := by
    refine' (Finsupp.sum_smul_index' _).trans _
    · exact fun i => smul_zero _
    · simp_rw [← smul_comm s, ← Finsupp.smul_sum]; rfl
#align polynomial_module.eval PolynomialModule.eval
-/

#print PolynomialModule.eval_single /-
@[simp]
theorem eval_single (r : R) (i : ℕ) (m : M) : eval r (single R i m) = r ^ i • m :=
  Finsupp.sum_single_index (smul_zero _)
#align polynomial_module.eval_single PolynomialModule.eval_single
-/

#print PolynomialModule.eval_lsingle /-
@[simp]
theorem eval_lsingle (r : R) (i : ℕ) (m : M) : eval r (lsingle R i m) = r ^ i • m :=
  eval_single r i m
#align polynomial_module.eval_lsingle PolynomialModule.eval_lsingle
-/

#print PolynomialModule.eval_smul /-
theorem eval_smul (p : R[X]) (q : PolynomialModule R M) (r : R) :
    eval r (p • q) = p.eval r • eval r q :=
  by
  apply induction_linear q
  · rw [smul_zero, map_zero, smul_zero]
  · intro f g e₁ e₂; rw [smul_add, map_add, e₁, e₂, map_add, smul_add]
  intro i m
  apply Polynomial.induction_on' p
  · intro p q e₁ e₂; rw [add_smul, map_add, Polynomial.eval_add, e₁, e₂, add_smul]
  · intro j s
    rw [monomial_smul_single, eval_single, Polynomial.eval_monomial, eval_single, smul_comm, ←
      smul_smul, pow_add, mul_smul]
#align polynomial_module.eval_smul PolynomialModule.eval_smul
-/

#print PolynomialModule.eval_map /-
@[simp]
theorem eval_map (f : M →ₗ[R] M') (q : PolynomialModule R M) (r : R) :
    eval (algebraMap R R' r) (map R' f q) = f (eval r q) :=
  by
  apply induction_linear q
  · simp_rw [map_zero]
  · intro f g e₁ e₂; simp_rw [map_add, e₁, e₂]
  · intro i m
    rw [map_single, eval_single, eval_single, f.map_smul, ← map_pow, algebraMap_smul]
#align polynomial_module.eval_map PolynomialModule.eval_map
-/

#print PolynomialModule.eval_map' /-
@[simp]
theorem eval_map' (f : M →ₗ[R] M) (q : PolynomialModule R M) (r : R) :
    eval r (map R f q) = f (eval r q) :=
  eval_map R f q r
#align polynomial_module.eval_map' PolynomialModule.eval_map'
-/

#print PolynomialModule.comp /-
/-- `comp p q` is the composition of `p : R[X]` and `q : M[X]` as `q(p(x))`.  -/
@[simps]
noncomputable def comp (p : R[X]) : PolynomialModule R M →ₗ[R] PolynomialModule R M :=
  ((eval p).restrictScalars R).comp (map R[X] (lsingle R 0))
#align polynomial_module.comp PolynomialModule.comp
-/

#print PolynomialModule.comp_single /-
theorem comp_single (p : R[X]) (i : ℕ) (m : M) : comp p (single R i m) = p ^ i • single R 0 m :=
  by
  rw [comp_apply]
  erw [map_single, eval_single]
  rfl
#align polynomial_module.comp_single PolynomialModule.comp_single
-/

#print PolynomialModule.comp_eval /-
theorem comp_eval (p : R[X]) (q : PolynomialModule R M) (r : R) :
    eval r (comp p q) = eval (p.eval r) q :=
  by
  rw [← LinearMap.comp_apply]
  apply induction_linear q
  · rw [map_zero, map_zero]
  · intro _ _ e₁ e₂; rw [map_add, map_add, e₁, e₂]
  · intro i m
    rw [LinearMap.comp_apply, comp_single, eval_single, eval_smul, eval_single, pow_zero, one_smul,
      Polynomial.eval_pow]
#align polynomial_module.comp_eval PolynomialModule.comp_eval
-/

#print PolynomialModule.comp_smul /-
theorem comp_smul (p p' : R[X]) (q : PolynomialModule R M) :
    comp p (p' • q) = p'.comp p • comp p q :=
  by
  rw [comp_apply, map_smul, eval_smul, Polynomial.comp, Polynomial.eval_map, comp_apply]
  rfl
#align polynomial_module.comp_smul PolynomialModule.comp_smul
-/

end PolynomialModule

