/-
Copyright (c) 2021 Eric Weiser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module algebra.algebra.subalgebra.pointwise
! leanprover-community/mathlib commit 932872382355f00112641d305ba0619305dc8642
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Operations
import Mathbin.Algebra.Algebra.Subalgebra.Basic
import Mathbin.RingTheory.Subring.Pointwise
import Mathbin.RingTheory.Adjoin.Basic

/-!
# Pointwise actions on subalgebras.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

If `R'` acts on an `R`-algebra `A` (so that `R'` and `R` actions commute)
then we get an `R'` action on the collection of `R`-subalgebras.
-/


namespace Subalgebra

section Pointwise

variable {R : Type _} {A : Type _} [CommSemiring R] [Semiring A] [Algebra R A]

#print Subalgebra.mul_toSubmodule_le /-
theorem mul_toSubmodule_le (S T : Subalgebra R A) :
    S.toSubmodule * T.toSubmodule ≤ (S ⊔ T).toSubmodule :=
  by
  rw [Submodule.mul_le]
  intro y hy z hz
  show y * z ∈ S ⊔ T
  exact mul_mem (Algebra.mem_sup_left hy) (Algebra.mem_sup_right hz)
#align subalgebra.mul_to_submodule_le Subalgebra.mul_toSubmodule_le
-/

#print Subalgebra.mul_self /-
/-- As submodules, subalgebras are idempotent. -/
@[simp]
theorem mul_self (S : Subalgebra R A) : S.toSubmodule * S.toSubmodule = S.toSubmodule :=
  by
  apply le_antisymm
  · refine' (mul_to_submodule_le _ _).trans_eq _
    rw [sup_idem]
  · intro x hx1
    rw [← mul_one x]
    exact Submodule.mul_mem_mul hx1 (show (1 : A) ∈ S from one_mem S)
#align subalgebra.mul_self Subalgebra.mul_self
-/

#print Subalgebra.mul_toSubmodule /-
/-- When `A` is commutative, `subalgebra.mul_to_submodule_le` is strict. -/
theorem mul_toSubmodule {R : Type _} {A : Type _} [CommSemiring R] [CommSemiring A] [Algebra R A]
    (S T : Subalgebra R A) : S.toSubmodule * T.toSubmodule = (S ⊔ T).toSubmodule :=
  by
  refine' le_antisymm (mul_to_submodule_le _ _) _
  rintro x (hx : x ∈ Algebra.adjoin R (S ∪ T : Set A))
  refine'
    Algebra.adjoin_induction hx (fun x hx => _) (fun r => _) (fun _ _ => Submodule.add_mem _)
      fun x y hx hy => _
  · cases' hx with hxS hxT
    · rw [← mul_one x]
      exact Submodule.mul_mem_mul hxS (show (1 : A) ∈ T from one_mem T)
    · rw [← one_mul x]
      exact Submodule.mul_mem_mul (show (1 : A) ∈ S from one_mem S) hxT
  · rw [← one_mul (algebraMap _ _ _)]
    exact Submodule.mul_mem_mul (show (1 : A) ∈ S from one_mem S) (algebra_map_mem _ _)
  have := Submodule.mul_mem_mul hx hy
  rwa [mul_assoc, mul_comm _ T.to_submodule, ← mul_assoc _ _ S.to_submodule, mul_self,
    mul_comm T.to_submodule, ← mul_assoc, mul_self] at this 
#align subalgebra.mul_to_submodule Subalgebra.mul_toSubmodule
-/

variable {R' : Type _} [Semiring R'] [MulSemiringAction R' A] [SMulCommClass R' R A]

#print Subalgebra.pointwiseMulAction /-
/-- The action on a subalgebra corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale. -/
protected def pointwiseMulAction : MulAction R' (Subalgebra R A)
    where
  smul a S := S.map (MulSemiringAction.toAlgHom _ _ a)
  one_smul S := (congr_arg (fun f => S.map f) (AlgHom.ext <| one_smul R')).trans S.map_id
  mul_smul a₁ a₂ S :=
    (congr_arg (fun f => S.map f) (AlgHom.ext <| mul_smul _ _)).trans (S.map_map _ _).symm
#align subalgebra.pointwise_mul_action Subalgebra.pointwiseMulAction
-/

scoped[Pointwise] attribute [instance] Subalgebra.pointwiseMulAction

open scoped Pointwise

#print Subalgebra.coe_pointwise_smul /-
@[simp]
theorem coe_pointwise_smul (m : R') (S : Subalgebra R A) : ↑(m • S) = m • (S : Set A) :=
  rfl
#align subalgebra.coe_pointwise_smul Subalgebra.coe_pointwise_smul
-/

#print Subalgebra.pointwise_smul_toSubsemiring /-
@[simp]
theorem pointwise_smul_toSubsemiring (m : R') (S : Subalgebra R A) :
    (m • S).toSubsemiring = m • S.toSubsemiring :=
  rfl
#align subalgebra.pointwise_smul_to_subsemiring Subalgebra.pointwise_smul_toSubsemiring
-/

#print Subalgebra.pointwise_smul_toSubmodule /-
@[simp]
theorem pointwise_smul_toSubmodule (m : R') (S : Subalgebra R A) :
    (m • S).toSubmodule = m • S.toSubmodule :=
  rfl
#align subalgebra.pointwise_smul_to_submodule Subalgebra.pointwise_smul_toSubmodule
-/

#print Subalgebra.pointwise_smul_toSubring /-
@[simp]
theorem pointwise_smul_toSubring {R' R A : Type _} [Semiring R'] [CommRing R] [Ring A]
    [MulSemiringAction R' A] [Algebra R A] [SMulCommClass R' R A] (m : R') (S : Subalgebra R A) :
    (m • S).toSubring = m • S.toSubring :=
  rfl
#align subalgebra.pointwise_smul_to_subring Subalgebra.pointwise_smul_toSubring
-/

#print Subalgebra.smul_mem_pointwise_smul /-
theorem smul_mem_pointwise_smul (m : R') (r : A) (S : Subalgebra R A) : r ∈ S → m • r ∈ m • S :=
  (Set.smul_mem_smul_set : _ → _ ∈ m • (S : Set A))
#align subalgebra.smul_mem_pointwise_smul Subalgebra.smul_mem_pointwise_smul
-/

end Pointwise

end Subalgebra

