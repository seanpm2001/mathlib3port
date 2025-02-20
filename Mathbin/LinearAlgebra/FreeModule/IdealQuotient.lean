/-
Copyright (c) 2022 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen

! This file was ported from Lean 3 source module linear_algebra.free_module.ideal_quotient
! leanprover-community/mathlib commit 90b0d53ee6ffa910e5c2a977ce7e2fc704647974
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Zmod.Quotient
import Mathbin.LinearAlgebra.FreeModule.Finite.Rank
import Mathbin.LinearAlgebra.FreeModule.Pid
import Mathbin.LinearAlgebra.FreeModule.StrongRankCondition
import Mathbin.LinearAlgebra.QuotientPi

/-! # Ideals in free modules over PIDs

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main results

 - `ideal.quotient_equiv_pi_span`: `S ⧸ I`, if `S` is finite free as a module over a PID `R`,
   can be written as a product of quotients of `R` by principal ideals.

-/


namespace Ideal

open scoped BigOperators DirectSum Polynomial

variable {R S ι : Type _} [CommRing R] [CommRing S] [Algebra R S]

variable [IsDomain R] [IsPrincipalIdealRing R] [IsDomain S] [Finite ι]

#print Ideal.quotientEquivPiSpan /-
/-- We can write the quotient of an ideal over a PID as a product of quotients by principal ideals.
-/
noncomputable def quotientEquivPiSpan (I : Ideal S) (b : Basis ι R S) (hI : I ≠ ⊥) :
    (S ⧸ I) ≃ₗ[R] ∀ i, R ⧸ span ({I.smithCoeffs b hI i} : Set R) :=
  by
  haveI := Fintype.ofFinite ι
  -- Choose `e : S ≃ₗ I` and a basis `b'` for `S` that turns the map
  -- `f := ((submodule.subtype I).restrict_scalars R).comp e` into a diagonal matrix:
  -- there is an `a : ι → ℤ` such that `f (b' i) = a i • b' i`.
  let a := I.smith_coeffs b hI
  let b' := I.ring_basis b hI
  let ab := I.self_basis b hI
  have ab_eq := I.self_basis_def b hI
  let e : S ≃ₗ[R] I := b'.equiv ab (Equiv.refl _)
  let f : S →ₗ[R] S := (I.subtype.restrict_scalars R).comp (e : S →ₗ[R] I)
  let f_apply : ∀ x, f x = b'.equiv ab (Equiv.refl _) x := fun x => rfl
  have ha : ∀ i, f (b' i) = a i • b' i := by intro i;
    rw [f_apply, b'.equiv_apply, Equiv.refl_apply, ab_eq]
  have mem_I_iff : ∀ x, x ∈ I ↔ ∀ i, a i ∣ b'.repr x i :=
    by
    intro x; simp_rw [ab.mem_ideal_iff', ab_eq]
    have : ∀ (c : ι → R) (i), b'.repr (∑ j : ι, c j • a j • b' j) i = a i * c i :=
      by
      intro c i
      simp only [← MulAction.mul_smul, b'.repr_sum_self, mul_comm]
    constructor
    · rintro ⟨c, rfl⟩ i; exact ⟨c i, this c i⟩
    · rintro ha
      choose c hc using ha; exact ⟨c, b'.ext_elem fun i => trans (hc i) (this c i).symm⟩
  -- Now we map everything through the linear equiv `S ≃ₗ (ι → R)`,
  -- which maps `I` to `I' := Π i, a i ℤ`.
  let I' : Submodule R (ι → R) := Submodule.pi Set.univ fun i => span ({a i} : Set R)
  have : Submodule.map (b'.equiv_fun : S →ₗ[R] ι → R) (I.restrict_scalars R) = I' :=
    by
    ext x
    simp only [Submodule.mem_map, Submodule.mem_pi, mem_span_singleton, Set.mem_univ,
      Submodule.restrictScalars_mem, mem_I_iff, smul_eq_mul, forall_true_left, LinearEquiv.coe_coe,
      Basis.equivFun_apply]
    constructor
    · rintro ⟨y, hy, rfl⟩ i; exact hy i
    · rintro hdvd
      refine' ⟨∑ i, x i • b' i, fun i => _, _⟩ <;> rwa [b'.repr_sum_self]
      · exact hdvd i
  refine' ((Submodule.Quotient.restrictScalarsEquiv R I).restrictScalars R).symm.trans _
  any_goals apply RingHom.id; any_goals infer_instance
  refine' (Submodule.Quotient.equiv (I.restrict_scalars R) I' b'.equiv_fun this).trans _
  any_goals apply RingHom.id; any_goals infer_instance
  classical
  let this.1 := Submodule.quotientPi (show ∀ i, Submodule R R from fun i => span ({a i} : Set R))
  exact this
#align ideal.quotient_equiv_pi_span Ideal.quotientEquivPiSpan
-/

#print Ideal.quotientEquivPiZMod /-
/-- Ideal quotients over a free finite extension of `ℤ` are isomorphic to a direct product of
`zmod`. -/
noncomputable def quotientEquivPiZMod (I : Ideal S) (b : Basis ι ℤ S) (hI : I ≠ ⊥) :
    S ⧸ I ≃+ ∀ i, ZMod (I.smithCoeffs b hI i).natAbs :=
  let a := I.smithCoeffs b hI
  let e := I.quotientEquivPiSpan b hI
  let e' : (∀ i : ι, ℤ ⧸ span ({a i} : Set ℤ)) ≃+ ∀ i : ι, ZMod (a i).natAbs :=
    AddEquiv.piCongrRight fun i => ↑(Int.quotientSpanEquivZMod (a i))
  (↑(e : (S ⧸ I) ≃ₗ[ℤ] _) : S ⧸ I ≃+ _).trans e'
#align ideal.quotient_equiv_pi_zmod Ideal.quotientEquivPiZMod
-/

#print Ideal.fintypeQuotientOfFreeOfNeBot /-
/-- A nonzero ideal over a free finite extension of `ℤ` has a finite quotient.

Can't be an instance because of the side condition `I ≠ ⊥`, and more importantly,
because the choice of `fintype` instance is non-canonical.
-/
noncomputable def fintypeQuotientOfFreeOfNeBot [Module.Free ℤ S] [Module.Finite ℤ S] (I : Ideal S)
    (hI : I ≠ ⊥) : Fintype (S ⧸ I) :=
  by
  let b := Module.Free.chooseBasis ℤ S
  let a := I.smithCoeffs b hI
  let e := I.quotientEquivPiZMod b hI
  haveI : ∀ i, NeZero (a i).natAbs := fun i =>
        ⟨Int.natAbs_ne_zero_of_ne_zero (smith_coeffs_ne_zero b I hI i)⟩ <;>
      classical skip <;>
    exact Fintype.ofEquiv (∀ i, ZMod (a i).natAbs) e.symm
#align ideal.fintype_quotient_of_free_of_ne_bot Ideal.fintypeQuotientOfFreeOfNeBot
-/

variable (F : Type _) [CommRing F] [Algebra F R] [Algebra F S] [IsScalarTower F R S]
  (b : Basis ι R S) {I : Ideal S} (hI : I ≠ ⊥)

#print Ideal.quotientEquivDirectSum /-
/-- Decompose `S⧸I` as a direct sum of cyclic `R`-modules
  (quotients by the ideals generated by Smith coefficients of `I`). -/
noncomputable def quotientEquivDirectSum :
    (S ⧸ I) ≃ₗ[F] ⨁ i, R ⧸ span ({I.smithCoeffs b hI i} : Set R) :=
  by
  haveI := Fintype.ofFinite ι
  apply
    ((I.quotient_equiv_pi_span b _).restrictScalars F).trans
      (DirectSum.linearEquivFunOnFintype _ _ _).symm
  exact LinearMap.IsScalarTower.compatibleSMul
#align ideal.quotient_equiv_direct_sum Ideal.quotientEquivDirectSum
-/

#print Ideal.finrank_quotient_eq_sum /-
-- why doesn't it automatically apply?
-- even after `change linear_map.compatible_smul _ (Π i, R ⧸ span _) F R`
theorem finrank_quotient_eq_sum {ι} [Fintype ι] (b : Basis ι R S) [Nontrivial F]
    [∀ i, Module.Free F (R ⧸ span ({I.smithCoeffs b hI i} : Set R))]
    [∀ i, Module.Finite F (R ⧸ span ({I.smithCoeffs b hI i} : Set R))] :
    FiniteDimensional.finrank F (S ⧸ I) =
      ∑ i, FiniteDimensional.finrank F (R ⧸ span ({I.smithCoeffs b hI i} : Set R)) :=
  by
  rw [LinearEquiv.finrank_eq <| quotient_equiv_direct_sum F b hI,
    FiniteDimensional.finrank_directSum]
#align ideal.finrank_quotient_eq_sum Ideal.finrank_quotient_eq_sum
-/

-- slow, and dot notation doesn't work
end Ideal

