/-
Copyright (c) 2022 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen, Alex J. Best

! This file was ported from Lean 3 source module linear_algebra.quotient_pi
! leanprover-community/mathlib commit 814d76e2247d5ba8bc024843552da1278bfe9e5c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Pi
import Mathbin.LinearAlgebra.Quotient

/-!
# Submodule quotients and direct sums

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains some results on the quotient of a module by a direct sum of submodules,
and the direct sum of quotients of modules by submodules.

# Main definitions

 * `submodule.pi_quotient_lift`: create a map out of the direct sum of quotients
 * `submodule.quotient_pi_lift`: create a map out of the quotient of a direct sum
 * `submodule.quotient_pi`: the quotient of a direct sum is the direct sum of quotients.

-/


namespace Submodule

open LinearMap

variable {ι R : Type _} [CommRing R]

variable {Ms : ι → Type _} [∀ i, AddCommGroup (Ms i)] [∀ i, Module R (Ms i)]

variable {N : Type _} [AddCommGroup N] [Module R N]

variable {Ns : ι → Type _} [∀ i, AddCommGroup (Ns i)] [∀ i, Module R (Ns i)]

#print Submodule.piQuotientLift /-
/-- Lift a family of maps to the direct sum of quotients. -/
def piQuotientLift [Fintype ι] [DecidableEq ι] (p : ∀ i, Submodule R (Ms i)) (q : Submodule R N)
    (f : ∀ i, Ms i →ₗ[R] N) (hf : ∀ i, p i ≤ q.comap (f i)) : (∀ i, Ms i ⧸ p i) →ₗ[R] N ⧸ q :=
  lsum R (fun i => Ms i ⧸ p i) R fun i => (p i).mapQ q (f i) (hf i)
#align submodule.pi_quotient_lift Submodule.piQuotientLift
-/

#print Submodule.piQuotientLift_mk /-
@[simp]
theorem piQuotientLift_mk [Fintype ι] [DecidableEq ι] (p : ∀ i, Submodule R (Ms i))
    (q : Submodule R N) (f : ∀ i, Ms i →ₗ[R] N) (hf : ∀ i, p i ≤ q.comap (f i)) (x : ∀ i, Ms i) :
    (piQuotientLift p q f hf fun i => Quotient.mk (x i)) = Quotient.mk (lsum _ _ R f x) := by
  rw [pi_quotient_lift, lsum_apply, sum_apply, ← mkq_apply, lsum_apply, sum_apply,
      _root_.map_sum] <;>
    simp only [coe_proj, mapq_apply, mkq_apply, comp_apply]
#align submodule.pi_quotient_lift_mk Submodule.piQuotientLift_mk
-/

#print Submodule.piQuotientLift_single /-
@[simp]
theorem piQuotientLift_single [Fintype ι] [DecidableEq ι] (p : ∀ i, Submodule R (Ms i))
    (q : Submodule R N) (f : ∀ i, Ms i →ₗ[R] N) (hf : ∀ i, p i ≤ q.comap (f i)) (i)
    (x : Ms i ⧸ p i) : piQuotientLift p q f hf (Pi.single i x) = mapQ _ _ (f i) (hf i) x :=
  by
  simp_rw [pi_quotient_lift, lsum_apply, sum_apply, comp_apply, proj_apply]
  rw [Finset.sum_eq_single i]
  · rw [Pi.single_eq_same]
  · rintro j - hj; rw [Pi.single_eq_of_ne hj, _root_.map_zero]
  · intros; have := Finset.mem_univ i; contradiction
#align submodule.pi_quotient_lift_single Submodule.piQuotientLift_single
-/

#print Submodule.quotientPiLift /-
/-- Lift a family of maps to a quotient of direct sums. -/
def quotientPiLift (p : ∀ i, Submodule R (Ms i)) (f : ∀ i, Ms i →ₗ[R] Ns i)
    (hf : ∀ i, p i ≤ ker (f i)) : (∀ i, Ms i) ⧸ pi Set.univ p →ₗ[R] ∀ i, Ns i :=
  (pi Set.univ p).liftQ (LinearMap.pi fun i => (f i).comp (proj i)) fun x hx =>
    mem_ker.mpr <| by ext i; simpa using hf i (mem_pi.mp hx i (Set.mem_univ i))
#align submodule.quotient_pi_lift Submodule.quotientPiLift
-/

#print Submodule.quotientPiLift_mk /-
@[simp]
theorem quotientPiLift_mk (p : ∀ i, Submodule R (Ms i)) (f : ∀ i, Ms i →ₗ[R] Ns i)
    (hf : ∀ i, p i ≤ ker (f i)) (x : ∀ i, Ms i) :
    quotientPiLift p f hf (Quotient.mk x) = fun i => f i (x i) :=
  rfl
#align submodule.quotient_pi_lift_mk Submodule.quotientPiLift_mk
-/

#print Submodule.quotientPi /-
/-- The quotient of a direct sum is the direct sum of quotients. -/
@[simps]
def quotientPi [Fintype ι] [DecidableEq ι] (p : ∀ i, Submodule R (Ms i)) :
    ((∀ i, Ms i) ⧸ pi Set.univ p) ≃ₗ[R] ∀ i, Ms i ⧸ p i :=
  {
    quotientPiLift p (fun i => (p i).mkQ) fun i => by
      simp with
    toFun := quotientPiLift p (fun i => (p i).mkQ) fun i => by simp
    invFun := piQuotientLift p (pi Set.univ p) single fun i => le_comap_single_pi p
    left_inv := fun x =>
      Quotient.inductionOn' x fun x' => by
        simp_rw [Quotient.mk''_eq_mk', quotient_pi_lift_mk, mkq_apply, pi_quotient_lift_mk,
          lsum_single, id_apply]
    right_inv := by
      rw [Function.rightInverse_iff_comp, ← coe_comp, ← @id_coe R]
      refine' congr_arg _ (pi_ext fun i x => Quotient.inductionOn' x fun x' => funext fun j => _)
      rw [comp_apply, pi_quotient_lift_single, Quotient.mk''_eq_mk', mapq_apply,
        quotient_pi_lift_mk, id_apply]
      by_cases hij : i = j <;> simp only [mkq_apply, coe_single]
      · subst hij; simp only [Pi.single_eq_same]
      · simp only [Pi.single_eq_of_ne (Ne.symm hij), quotient.mk_zero] }
#align submodule.quotient_pi Submodule.quotientPi
-/

end Submodule

