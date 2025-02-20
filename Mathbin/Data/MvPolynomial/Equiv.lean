/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Johan Commelin, Mario Carneiro

! This file was ported from Lean 3 source module data.mv_polynomial.equiv
! leanprover-community/mathlib commit 2f5b500a507264de86d666a5f87ddb976e2d8de4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.MvPolynomial.Rename
import Mathbin.Data.Polynomial.AlgebraMap
import Mathbin.Data.MvPolynomial.Variables
import Mathbin.Data.Finsupp.Fin
import Mathbin.Logic.Equiv.Fin
import Mathbin.Algebra.BigOperators.Fin

/-!
# Equivalences between polynomial rings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file establishes a number of equivalences between polynomial rings,
based on equivalences between the underlying types.

## Notation

As in other polynomial files, we typically use the notation:

+ `σ : Type*` (indexing the variables)

+ `R : Type*` `[comm_semiring R]` (the coefficients)

+ `s : σ →₀ ℕ`, a function from `σ` to `ℕ` which is zero away from a finite set.
This will give rise to a monomial in `mv_polynomial σ R` which mathematicians might call `X^s`

+ `a : R`

+ `i : σ`, with corresponding monomial `X i`, often denoted `X_i` by mathematicians

+ `p : mv_polynomial σ R`

## Tags

equivalence, isomorphism, morphism, ring hom, hom

-/


noncomputable section

open scoped BigOperators Polynomial

open Set Function Finsupp AddMonoidAlgebra

universe u v w x

variable {R : Type u} {S₁ : Type v} {S₂ : Type w} {S₃ : Type x}

namespace MvPolynomial

variable {σ : Type _} {a a' a₁ a₂ : R} {e : ℕ} {s : σ →₀ ℕ}

section Equiv

variable (R) [CommSemiring R]

#print MvPolynomial.pUnitAlgEquiv /-
/-- The ring isomorphism between multivariable polynomials in a single variable and
polynomials over the ground ring.
-/
@[simps]
def pUnitAlgEquiv : MvPolynomial PUnit R ≃ₐ[R] R[X]
    where
  toFun := eval₂ Polynomial.C fun u : PUnit => Polynomial.X
  invFun := Polynomial.eval₂ MvPolynomial.C (X PUnit.unit)
  left_inv :=
    by
    let f : R[X] →+* MvPolynomial PUnit R := Polynomial.eval₂RingHom MvPolynomial.C (X PUnit.unit)
    let g : MvPolynomial PUnit R →+* R[X] := eval₂_hom Polynomial.C fun u : PUnit => Polynomial.X
    show ∀ p, f.comp g p = p
    apply is_id
    · ext a; dsimp; rw [eval₂_C, Polynomial.eval₂_C]
    · rintro ⟨⟩; dsimp; rw [eval₂_X, Polynomial.eval₂_X]
  right_inv p :=
    Polynomial.induction_on p (fun a => by rw [Polynomial.eval₂_C, MvPolynomial.eval₂_C])
      (fun p q hp hq => by rw [Polynomial.eval₂_add, MvPolynomial.eval₂_add, hp, hq]) fun p n hp =>
      by
      rw [Polynomial.eval₂_mul, Polynomial.eval₂_pow, Polynomial.eval₂_X, Polynomial.eval₂_C,
        eval₂_mul, eval₂_C, eval₂_pow, eval₂_X]
  map_mul' _ _ := eval₂_mul _ _
  map_add' _ _ := eval₂_add _ _
  commutes' _ := eval₂_C _ _ _
#align mv_polynomial.punit_alg_equiv MvPolynomial.pUnitAlgEquiv
-/

section Map

variable {R} (σ)

#print MvPolynomial.mapEquiv /-
/-- If `e : A ≃+* B` is an isomorphism of rings, then so is `map e`. -/
@[simps apply]
def mapEquiv [CommSemiring S₁] [CommSemiring S₂] (e : S₁ ≃+* S₂) :
    MvPolynomial σ S₁ ≃+* MvPolynomial σ S₂ :=
  { map (e : S₁ →+* S₂) with
    toFun := map (e : S₁ →+* S₂)
    invFun := map (e.symm : S₂ →+* S₁)
    left_inv := map_leftInverse e.left_inv
    right_inv := map_rightInverse e.right_inv }
#align mv_polynomial.map_equiv MvPolynomial.mapEquiv
-/

#print MvPolynomial.mapEquiv_refl /-
@[simp]
theorem mapEquiv_refl : mapEquiv σ (RingEquiv.refl R) = RingEquiv.refl _ :=
  RingEquiv.ext map_id
#align mv_polynomial.map_equiv_refl MvPolynomial.mapEquiv_refl
-/

#print MvPolynomial.mapEquiv_symm /-
@[simp]
theorem mapEquiv_symm [CommSemiring S₁] [CommSemiring S₂] (e : S₁ ≃+* S₂) :
    (mapEquiv σ e).symm = mapEquiv σ e.symm :=
  rfl
#align mv_polynomial.map_equiv_symm MvPolynomial.mapEquiv_symm
-/

#print MvPolynomial.mapEquiv_trans /-
@[simp]
theorem mapEquiv_trans [CommSemiring S₁] [CommSemiring S₂] [CommSemiring S₃] (e : S₁ ≃+* S₂)
    (f : S₂ ≃+* S₃) : (mapEquiv σ e).trans (mapEquiv σ f) = mapEquiv σ (e.trans f) :=
  RingEquiv.ext (map_map e f)
#align mv_polynomial.map_equiv_trans MvPolynomial.mapEquiv_trans
-/

variable {A₁ A₂ A₃ : Type _} [CommSemiring A₁] [CommSemiring A₂] [CommSemiring A₃]

variable [Algebra R A₁] [Algebra R A₂] [Algebra R A₃]

#print MvPolynomial.mapAlgEquiv /-
/-- If `e : A ≃ₐ[R] B` is an isomorphism of `R`-algebras, then so is `map e`. -/
@[simps apply]
def mapAlgEquiv (e : A₁ ≃ₐ[R] A₂) : MvPolynomial σ A₁ ≃ₐ[R] MvPolynomial σ A₂ :=
  { mapAlgHom (e : A₁ →ₐ[R] A₂), mapEquiv σ (e : A₁ ≃+* A₂) with toFun := map (e : A₁ →+* A₂) }
#align mv_polynomial.map_alg_equiv MvPolynomial.mapAlgEquiv
-/

#print MvPolynomial.mapAlgEquiv_refl /-
@[simp]
theorem mapAlgEquiv_refl : mapAlgEquiv σ (AlgEquiv.refl : A₁ ≃ₐ[R] A₁) = AlgEquiv.refl :=
  AlgEquiv.ext map_id
#align mv_polynomial.map_alg_equiv_refl MvPolynomial.mapAlgEquiv_refl
-/

#print MvPolynomial.mapAlgEquiv_symm /-
@[simp]
theorem mapAlgEquiv_symm (e : A₁ ≃ₐ[R] A₂) : (mapAlgEquiv σ e).symm = mapAlgEquiv σ e.symm :=
  rfl
#align mv_polynomial.map_alg_equiv_symm MvPolynomial.mapAlgEquiv_symm
-/

#print MvPolynomial.mapAlgEquiv_trans /-
@[simp]
theorem mapAlgEquiv_trans (e : A₁ ≃ₐ[R] A₂) (f : A₂ ≃ₐ[R] A₃) :
    (mapAlgEquiv σ e).trans (mapAlgEquiv σ f) = mapAlgEquiv σ (e.trans f) :=
  AlgEquiv.ext (map_map e f)
#align mv_polynomial.map_alg_equiv_trans MvPolynomial.mapAlgEquiv_trans
-/

end Map

section

variable (S₁ S₂ S₃)

#print MvPolynomial.sumToIter /-
/-- The function from multivariable polynomials in a sum of two types,
to multivariable polynomials in one of the types,
with coefficents in multivariable polynomials in the other type.

See `sum_ring_equiv` for the ring isomorphism.
-/
def sumToIter : MvPolynomial (Sum S₁ S₂) R →+* MvPolynomial S₁ (MvPolynomial S₂ R) :=
  eval₂Hom (C.comp C) fun bc => Sum.recOn bc X (C ∘ X)
#align mv_polynomial.sum_to_iter MvPolynomial.sumToIter
-/

#print MvPolynomial.sumToIter_C /-
@[simp]
theorem sumToIter_C (a : R) : sumToIter R S₁ S₂ (C a) = C (C a) :=
  eval₂_C _ _ a
#align mv_polynomial.sum_to_iter_C MvPolynomial.sumToIter_C
-/

#print MvPolynomial.sumToIter_Xl /-
@[simp]
theorem sumToIter_Xl (b : S₁) : sumToIter R S₁ S₂ (X (Sum.inl b)) = X b :=
  eval₂_X _ _ (Sum.inl b)
#align mv_polynomial.sum_to_iter_Xl MvPolynomial.sumToIter_Xl
-/

#print MvPolynomial.sumToIter_Xr /-
@[simp]
theorem sumToIter_Xr (c : S₂) : sumToIter R S₁ S₂ (X (Sum.inr c)) = C (X c) :=
  eval₂_X _ _ (Sum.inr c)
#align mv_polynomial.sum_to_iter_Xr MvPolynomial.sumToIter_Xr
-/

#print MvPolynomial.iterToSum /-
/-- The function from multivariable polynomials in one type,
with coefficents in multivariable polynomials in another type,
to multivariable polynomials in the sum of the two types.

See `sum_ring_equiv` for the ring isomorphism.
-/
def iterToSum : MvPolynomial S₁ (MvPolynomial S₂ R) →+* MvPolynomial (Sum S₁ S₂) R :=
  eval₂Hom (eval₂Hom C (X ∘ Sum.inr)) (X ∘ Sum.inl)
#align mv_polynomial.iter_to_sum MvPolynomial.iterToSum
-/

#print MvPolynomial.iterToSum_C_C /-
theorem iterToSum_C_C (a : R) : iterToSum R S₁ S₂ (C (C a)) = C a :=
  Eq.trans (eval₂_C _ _ (C a)) (eval₂_C _ _ _)
#align mv_polynomial.iter_to_sum_C_C MvPolynomial.iterToSum_C_C
-/

#print MvPolynomial.iterToSum_X /-
theorem iterToSum_X (b : S₁) : iterToSum R S₁ S₂ (X b) = X (Sum.inl b) :=
  eval₂_X _ _ _
#align mv_polynomial.iter_to_sum_X MvPolynomial.iterToSum_X
-/

#print MvPolynomial.iterToSum_C_X /-
theorem iterToSum_C_X (c : S₂) : iterToSum R S₁ S₂ (C (X c)) = X (Sum.inr c) :=
  Eq.trans (eval₂_C _ _ (X c)) (eval₂_X _ _ _)
#align mv_polynomial.iter_to_sum_C_X MvPolynomial.iterToSum_C_X
-/

variable (σ)

#print MvPolynomial.isEmptyAlgEquiv /-
/-- The algebra isomorphism between multivariable polynomials in no variables
and the ground ring. -/
@[simps]
def isEmptyAlgEquiv [he : IsEmpty σ] : MvPolynomial σ R ≃ₐ[R] R :=
  AlgEquiv.ofAlgHom (aeval (IsEmpty.elim he)) (Algebra.ofId _ _)
    (by ext; simp [Algebra.ofId_apply, algebra_map_eq]) (by ext i m; exact IsEmpty.elim' he i)
#align mv_polynomial.is_empty_alg_equiv MvPolynomial.isEmptyAlgEquiv
-/

#print MvPolynomial.isEmptyRingEquiv /-
/-- The ring isomorphism between multivariable polynomials in no variables
and the ground ring. -/
@[simps]
def isEmptyRingEquiv [he : IsEmpty σ] : MvPolynomial σ R ≃+* R :=
  (isEmptyAlgEquiv R σ).toRingEquiv
#align mv_polynomial.is_empty_ring_equiv MvPolynomial.isEmptyRingEquiv
-/

variable {σ}

#print MvPolynomial.mvPolynomialEquivMvPolynomial /-
/-- A helper function for `sum_ring_equiv`. -/
@[simps]
def mvPolynomialEquivMvPolynomial [CommSemiring S₃] (f : MvPolynomial S₁ R →+* MvPolynomial S₂ S₃)
    (g : MvPolynomial S₂ S₃ →+* MvPolynomial S₁ R) (hfgC : (f.comp g).comp C = C)
    (hfgX : ∀ n, f (g (X n)) = X n) (hgfC : (g.comp f).comp C = C) (hgfX : ∀ n, g (f (X n)) = X n) :
    MvPolynomial S₁ R ≃+* MvPolynomial S₂ S₃
    where
  toFun := f
  invFun := g
  left_inv := is_id (RingHom.comp _ _) hgfC hgfX
  right_inv := is_id (RingHom.comp _ _) hfgC hfgX
  map_mul' := f.map_mul
  map_add' := f.map_add
#align mv_polynomial.mv_polynomial_equiv_mv_polynomial MvPolynomial.mvPolynomialEquivMvPolynomial
-/

#print MvPolynomial.sumRingEquiv /-
/-- The ring isomorphism between multivariable polynomials in a sum of two types,
and multivariable polynomials in one of the types,
with coefficents in multivariable polynomials in the other type.
-/
def sumRingEquiv : MvPolynomial (Sum S₁ S₂) R ≃+* MvPolynomial S₁ (MvPolynomial S₂ R) :=
  by
  apply
    @mv_polynomial_equiv_mv_polynomial R (Sum S₁ S₂) _ _ _ _ (sum_to_iter R S₁ S₂)
      (iter_to_sum R S₁ S₂)
  · refine' RingHom.ext fun p => _
    rw [RingHom.comp_apply]
    convert hom_eq_hom ((sum_to_iter R S₁ S₂).comp ((iter_to_sum R S₁ S₂).comp C)) C _ _ p
    · ext1 a; dsimp; rw [iter_to_sum_C_C R S₁ S₂, sum_to_iter_C R S₁ S₂]
    · intro c; dsimp; rw [iter_to_sum_C_X R S₁ S₂, sum_to_iter_Xr R S₁ S₂]
  · intro b; rw [iter_to_sum_X R S₁ S₂, sum_to_iter_Xl R S₁ S₂]
  · ext1 a;
    rw [RingHom.comp_apply, RingHom.comp_apply, sum_to_iter_C R S₁ S₂, iter_to_sum_C_C R S₁ S₂]
  · intro n; cases' n with b c
    · rw [sum_to_iter_Xl, iter_to_sum_X]
    · rw [sum_to_iter_Xr, iter_to_sum_C_X]
#align mv_polynomial.sum_ring_equiv MvPolynomial.sumRingEquiv
-/

#print MvPolynomial.sumAlgEquiv /-
/-- The algebra isomorphism between multivariable polynomials in a sum of two types,
and multivariable polynomials in one of the types,
with coefficents in multivariable polynomials in the other type.
-/
def sumAlgEquiv : MvPolynomial (Sum S₁ S₂) R ≃ₐ[R] MvPolynomial S₁ (MvPolynomial S₂ R) :=
  { sumRingEquiv R S₁ S₂ with
    commutes' := by
      intro r
      have A : algebraMap R (MvPolynomial S₁ (MvPolynomial S₂ R)) r = (C (C r) : _) := by rfl
      have B : algebraMap R (MvPolynomial (Sum S₁ S₂) R) r = C r := by rfl
      simp only [sum_ring_equiv, sum_to_iter_C, mv_polynomial_equiv_mv_polynomial_apply,
        RingEquiv.toFun_eq_coe, A, B] }
#align mv_polynomial.sum_alg_equiv MvPolynomial.sumAlgEquiv
-/

section

-- this speeds up typeclass search in the lemma below
attribute [local instance 2000] IsScalarTower.right

#print MvPolynomial.optionEquivLeft /-
/-- The algebra isomorphism between multivariable polynomials in `option S₁` and
polynomials with coefficients in `mv_polynomial S₁ R`.
-/
@[simps]
def optionEquivLeft : MvPolynomial (Option S₁) R ≃ₐ[R] Polynomial (MvPolynomial S₁ R) :=
  AlgEquiv.ofAlgHom (MvPolynomial.aeval fun o => o.elim Polynomial.X fun s => Polynomial.C (X s))
    (Polynomial.aevalTower (MvPolynomial.rename some) (X none))
    (by ext : 2 <;> simp [← Polynomial.C_eq_algebraMap]) (by ext i : 2 <;> cases i <;> simp)
#align mv_polynomial.option_equiv_left MvPolynomial.optionEquivLeft
-/

end

#print MvPolynomial.optionEquivRight /-
/-- The algebra isomorphism between multivariable polynomials in `option S₁` and
multivariable polynomials with coefficients in polynomials.
-/
def optionEquivRight : MvPolynomial (Option S₁) R ≃ₐ[R] MvPolynomial S₁ R[X] :=
  AlgEquiv.ofAlgHom (MvPolynomial.aeval fun o => o.elim (C Polynomial.X) X)
    (MvPolynomial.aevalTower (Polynomial.aeval (X none)) fun i => X (Option.some i))
    (by
      ext : 2 <;>
        simp only [MvPolynomial.algebraMap_eq, Option.elim', AlgHom.coe_comp, AlgHom.id_comp,
          IsScalarTower.coe_toAlgHom', comp_app, aeval_tower_C, Polynomial.aeval_X, aeval_X,
          Option.elim', aeval_tower_X, AlgHom.coe_id, id.def, eq_self_iff_true, imp_true_iff])
    (by
      ext ⟨i⟩ : 2 <;>
        simp only [Option.elim', AlgHom.coe_comp, comp_app, aeval_X, aeval_tower_C,
          Polynomial.aeval_X, AlgHom.coe_id, id.def, aeval_tower_X])
#align mv_polynomial.option_equiv_right MvPolynomial.optionEquivRight
-/

variable (n : ℕ)

#print MvPolynomial.finSuccEquiv /-
/-- The algebra isomorphism between multivariable polynomials in `fin (n + 1)` and
polynomials over multivariable polynomials in `fin n`.
-/
def finSuccEquiv : MvPolynomial (Fin (n + 1)) R ≃ₐ[R] Polynomial (MvPolynomial (Fin n) R) :=
  (renameEquiv R (finSuccEquiv n)).trans (optionEquivLeft R (Fin n))
#align mv_polynomial.fin_succ_equiv MvPolynomial.finSuccEquiv
-/

#print MvPolynomial.finSuccEquiv_eq /-
theorem finSuccEquiv_eq :
    (finSuccEquiv R n : MvPolynomial (Fin (n + 1)) R →+* Polynomial (MvPolynomial (Fin n) R)) =
      eval₂Hom (Polynomial.C.comp (C : R →+* MvPolynomial (Fin n) R)) fun i : Fin (n + 1) =>
        Fin.cases Polynomial.X (fun k => Polynomial.C (X k)) i :=
  by
  ext : 2
  · simp only [finSuccEquiv, option_equiv_left_apply, aeval_C, AlgEquiv.coe_trans, RingHom.coe_coe,
      coe_eval₂_hom, comp_app, rename_equiv_apply, eval₂_C, RingHom.coe_comp, rename_C]
    rfl
  · intro i
    refine' Fin.cases _ _ i <;> simp [finSuccEquiv]
#align mv_polynomial.fin_succ_equiv_eq MvPolynomial.finSuccEquiv_eq
-/

#print MvPolynomial.finSuccEquiv_apply /-
@[simp]
theorem finSuccEquiv_apply (p : MvPolynomial (Fin (n + 1)) R) :
    finSuccEquiv R n p =
      eval₂Hom (Polynomial.C.comp (C : R →+* MvPolynomial (Fin n) R))
        (fun i : Fin (n + 1) => Fin.cases Polynomial.X (fun k => Polynomial.C (X k)) i) p :=
  by rw [← fin_succ_equiv_eq]; rfl
#align mv_polynomial.fin_succ_equiv_apply MvPolynomial.finSuccEquiv_apply
-/

#print MvPolynomial.finSuccEquiv_comp_C_eq_C /-
theorem finSuccEquiv_comp_C_eq_C {R : Type u} [CommSemiring R] (n : ℕ) :
    (↑(MvPolynomial.finSuccEquiv R n).symm : Polynomial (MvPolynomial (Fin n) R) →+* _).comp
        (Polynomial.C.comp MvPolynomial.C) =
      (MvPolynomial.C : R →+* MvPolynomial (Fin n.succ) R) :=
  by
  refine' RingHom.ext fun x => _
  rw [RingHom.comp_apply]
  refine'
    (MvPolynomial.finSuccEquiv R n).Injective
      (trans ((MvPolynomial.finSuccEquiv R n).apply_symm_apply _) _)
  simp only [MvPolynomial.finSuccEquiv_apply, MvPolynomial.eval₂Hom_C]
#align mv_polynomial.fin_succ_equiv_comp_C_eq_C MvPolynomial.finSuccEquiv_comp_C_eq_C
-/

variable {n} {R}

#print MvPolynomial.finSuccEquiv_X_zero /-
theorem finSuccEquiv_X_zero : finSuccEquiv R n (X 0) = Polynomial.X := by simp
#align mv_polynomial.fin_succ_equiv_X_zero MvPolynomial.finSuccEquiv_X_zero
-/

#print MvPolynomial.finSuccEquiv_X_succ /-
theorem finSuccEquiv_X_succ {j : Fin n} : finSuccEquiv R n (X j.succ) = Polynomial.C (X j) := by
  simp
#align mv_polynomial.fin_succ_equiv_X_succ MvPolynomial.finSuccEquiv_X_succ
-/

#print MvPolynomial.finSuccEquiv_coeff_coeff /-
/-- The coefficient of `m` in the `i`-th coefficient of `fin_succ_equiv R n f` equals the
    coefficient of `finsupp.cons i m` in `f`. -/
theorem finSuccEquiv_coeff_coeff (m : Fin n →₀ ℕ) (f : MvPolynomial (Fin (n + 1)) R) (i : ℕ) :
    coeff m (Polynomial.coeff (finSuccEquiv R n f) i) = coeff (m.cons i) f :=
  by
  induction' f using MvPolynomial.induction_on' with j r p q hp hq generalizing i m
  swap
  · simp only [(finSuccEquiv R n).map_add, Polynomial.coeff_add, coeff_add, hp, hq]
  simp only [fin_succ_equiv_apply, coe_eval₂_hom, eval₂_monomial, RingHom.coe_comp, prod_pow,
    Polynomial.coeff_C_mul, coeff_C_mul, coeff_monomial, Fin.prod_univ_succ, Fin.cases_zero,
    Fin.cases_succ, ← RingHom.map_prod, ← RingHom.map_pow]
  rw [← mul_boole, mul_comm (Polynomial.X ^ j 0), Polynomial.coeff_C_mul_X_pow]; congr 1
  obtain rfl | hjmi := eq_or_ne j (m.cons i)
  ·
    simpa only [cons_zero, cons_succ, if_pos rfl, monomial_eq, C_1, one_mul, prod_pow] using
      coeff_monomial m m (1 : R)
  · simp only [hjmi, if_false]
    obtain hij | rfl := ne_or_eq i (j 0)
    · simp only [hij, if_false, coeff_zero]
    simp only [eq_self_iff_true, if_true]
    have hmj : m ≠ j.tail := by rintro rfl; rw [cons_tail] at hjmi ; contradiction
    simpa only [monomial_eq, C_1, one_mul, prod_pow, Finsupp.tail_apply, if_neg hmj.symm] using
      coeff_monomial m j.tail (1 : R)
#align mv_polynomial.fin_succ_equiv_coeff_coeff MvPolynomial.finSuccEquiv_coeff_coeff
-/

#print MvPolynomial.eval_eq_eval_mv_eval' /-
theorem eval_eq_eval_mv_eval' (s : Fin n → R) (y : R) (f : MvPolynomial (Fin (n + 1)) R) :
    eval (Fin.cons y s : Fin (n + 1) → R) f =
      Polynomial.eval y (Polynomial.map (eval s) (finSuccEquiv R n f)) :=
  by
  -- turn this into a def `polynomial.map_alg_hom`
  let φ : (MvPolynomial (Fin n) R)[X] →ₐ[R] R[X] :=
    { Polynomial.mapRingHom (eval s) with
      commutes' := fun r => by convert Polynomial.map_C _; exact (eval_C _).symm }
  show
    aeval (Fin.cons y s : Fin (n + 1) → R) f =
      (Polynomial.aeval y).comp (φ.comp (finSuccEquiv R n).toAlgHom) f
  congr 2
  apply MvPolynomial.algHom_ext
  rw [Fin.forall_fin_succ]
  simp only [aeval_X, Fin.cons_zero, AlgEquiv.toAlgHom_eq_coe, AlgHom.coe_comp,
    Polynomial.coe_aeval_eq_eval, Polynomial.map_C, AlgHom.coe_mks, RingHom.toFun_eq_coe,
    Polynomial.coe_mapRingHom, AlgEquiv.coe_algHom, comp_app, fin_succ_equiv_apply, eval₂_hom_X',
    Fin.cases_zero, Polynomial.map_X, Polynomial.eval_X, eq_self_iff_true, Fin.cons_succ,
    Fin.cases_succ, eval_X, Polynomial.eval_C, imp_true_iff, and_self_iff]
#align mv_polynomial.eval_eq_eval_mv_eval' MvPolynomial.eval_eq_eval_mv_eval'
-/

#print MvPolynomial.coeff_eval_eq_eval_coeff /-
theorem coeff_eval_eq_eval_coeff (s' : Fin n → R) (f : Polynomial (MvPolynomial (Fin n) R))
    (i : ℕ) : Polynomial.coeff (Polynomial.map (eval s') f) i = eval s' (Polynomial.coeff f i) := by
  simp only [Polynomial.coeff_map]
#align mv_polynomial.coeff_eval_eq_eval_coeff MvPolynomial.coeff_eval_eq_eval_coeff
-/

#print MvPolynomial.support_coeff_finSuccEquiv /-
theorem support_coeff_finSuccEquiv {f : MvPolynomial (Fin (n + 1)) R} {i : ℕ} {m : Fin n →₀ ℕ} :
    m ∈ (Polynomial.coeff ((finSuccEquiv R n) f) i).support ↔ Finsupp.cons i m ∈ f.support :=
  by
  apply Iff.intro
  · intro h
    simpa [← fin_succ_equiv_coeff_coeff] using h
  · intro h
    simpa [mem_support_iff, ← fin_succ_equiv_coeff_coeff m f i] using h
#align mv_polynomial.support_coeff_fin_succ_equiv MvPolynomial.support_coeff_finSuccEquiv
-/

#print MvPolynomial.finSuccEquiv_support /-
theorem finSuccEquiv_support (f : MvPolynomial (Fin (n + 1)) R) :
    (finSuccEquiv R n f).support = Finset.image (fun m : Fin (n + 1) →₀ ℕ => m 0) f.support :=
  by
  ext i
  rw [Polynomial.mem_support_iff, Finset.mem_image, nonzero_iff_exists]
  constructor
  · rintro ⟨m, hm⟩
    refine' ⟨cons i m, _, cons_zero _ _⟩
    rw [← support_coeff_fin_succ_equiv]
    simpa using hm
  · rintro ⟨m, h, rfl⟩
    refine' ⟨tail m, _⟩
    rwa [← coeff, ← mem_support_iff, support_coeff_fin_succ_equiv, cons_tail]
#align mv_polynomial.fin_succ_equiv_support MvPolynomial.finSuccEquiv_support
-/

#print MvPolynomial.finSuccEquiv_support' /-
theorem finSuccEquiv_support' {f : MvPolynomial (Fin (n + 1)) R} {i : ℕ} :
    Finset.image (Finsupp.cons i) (Polynomial.coeff ((finSuccEquiv R n) f) i).support =
      f.support.filterₓ fun m => m 0 = i :=
  by
  ext m
  rw [Finset.mem_filter, Finset.mem_image, mem_support_iff]
  conv_lhs =>
    congr
    ext
    rw [mem_support_iff, fin_succ_equiv_coeff_coeff, Ne.def]
  constructor
  · rintro ⟨m', ⟨h, hm'⟩⟩
    simp only [← hm']
    exact ⟨h, by rw [cons_zero]⟩
  · intro h
    use tail m
    rw [← h.2, cons_tail]
    simp [h.1]
#align mv_polynomial.fin_succ_equiv_support' MvPolynomial.finSuccEquiv_support'
-/

#print MvPolynomial.support_finSuccEquiv_nonempty /-
theorem support_finSuccEquiv_nonempty {f : MvPolynomial (Fin (n + 1)) R} (h : f ≠ 0) :
    (finSuccEquiv R n f).support.Nonempty :=
  by
  by_contra c
  simp only [Finset.not_nonempty_iff_eq_empty, Polynomial.support_eq_empty] at c 
  have t'' : finSuccEquiv R n f ≠ 0 :=
    by
    let ii := (finSuccEquiv R n).symm
    have h' : f = 0 :=
      calc
        f = ii (finSuccEquiv R n f) := by
          simpa only [ii, ← AlgEquiv.invFun_eq_symm] using ((finSuccEquiv R n).left_inv f).symm
        _ = ii 0 := by rw [c]
        _ = 0 := by simp
    simpa [h'] using h
  simpa [c] using h
#align mv_polynomial.support_fin_succ_equiv_nonempty MvPolynomial.support_finSuccEquiv_nonempty
-/

#print MvPolynomial.degree_finSuccEquiv /-
theorem degree_finSuccEquiv {f : MvPolynomial (Fin (n + 1)) R} (h : f ≠ 0) :
    (finSuccEquiv R n f).degree = degreeOf 0 f :=
  by
  have h' : ((finSuccEquiv R n f).support.sup fun x => x) = degree_of 0 f := by
    rw [degree_of_eq_sup, fin_succ_equiv_support f, Finset.sup_image]
  rw [Polynomial.degree, ← h', Finset.coe_sup_of_nonempty (support_fin_succ_equiv_nonempty h),
    Finset.max_eq_sup_coe]
#align mv_polynomial.degree_fin_succ_equiv MvPolynomial.degree_finSuccEquiv
-/

#print MvPolynomial.natDegree_finSuccEquiv /-
theorem natDegree_finSuccEquiv (f : MvPolynomial (Fin (n + 1)) R) :
    (finSuccEquiv R n f).natDegree = degreeOf 0 f :=
  by
  by_cases c : f = 0
  · rw [c, (finSuccEquiv R n).map_zero, Polynomial.natDegree_zero, degree_of_zero]
  · rw [Polynomial.natDegree, degree_fin_succ_equiv (by simpa only [Ne.def])]
    simp
#align mv_polynomial.nat_degree_fin_succ_equiv MvPolynomial.natDegree_finSuccEquiv
-/

#print MvPolynomial.degreeOf_coeff_finSuccEquiv /-
theorem degreeOf_coeff_finSuccEquiv (p : MvPolynomial (Fin (n + 1)) R) (j : Fin n) (i : ℕ) :
    degreeOf j (Polynomial.coeff (finSuccEquiv R n p) i) ≤ degreeOf j.succ p :=
  by
  rw [degree_of_eq_sup, degree_of_eq_sup, Finset.sup_le_iff]
  intro m hm
  rw [← Finsupp.cons_succ j i m]
  convert Finset.le_sup (support_coeff_fin_succ_equiv.1 hm)
  rfl
#align mv_polynomial.degree_of_coeff_fin_succ_equiv MvPolynomial.degreeOf_coeff_finSuccEquiv
-/

end

end Equiv

end MvPolynomial

