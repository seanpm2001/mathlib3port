/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux

! This file was ported from Lean 3 source module analysis.normed_space.star.exponential
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Exponential

/-! # The exponential map from selfadjoint to unitary

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
In this file, we establish various propreties related to the map `λ a, exp ℂ A (I • a)` between the
subtypes `self_adjoint A` and `unitary A`.

## TODO

* Show that any exponential unitary is path-connected in `unitary A` to `1 : unitary A`.
* Prove any unitary whose distance to `1 : unitary A` is less than `1` can be expressed as an
  exponential unitary.
* A unitary is in the path component of `1` if and only if it is a finite product of exponential
  unitaries.
-/


section Star

variable {A : Type _} [NormedRing A] [NormedAlgebra ℂ A] [StarRing A] [ContinuousStar A]
  [CompleteSpace A] [StarModule ℂ A]

open Complex

#print selfAdjoint.expUnitary /-
/-- The map from the selfadjoint real subspace to the unitary group. This map only makes sense
over ℂ. -/
@[simps]
noncomputable def selfAdjoint.expUnitary (a : selfAdjoint A) : unitary A :=
  ⟨exp ℂ (I • a), exp_mem_unitary_of_mem_skewAdjoint _ (a.Prop.smul_mem_skewAdjoint conj_I)⟩
#align self_adjoint.exp_unitary selfAdjoint.expUnitary
-/

open selfAdjoint

#print Commute.expUnitary_add /-
theorem Commute.expUnitary_add {a b : selfAdjoint A} (h : Commute (a : A) (b : A)) :
    expUnitary (a + b) = expUnitary a * expUnitary b :=
  by
  ext
  have hcomm : Commute (I • (a : A)) (I • (b : A))
  calc
    _ = _ := by simp only [h.eq, Algebra.smul_mul_assoc, Algebra.mul_smul_comm]
  simpa only [exp_unitary_coe, AddSubgroup.coe_add, smul_add] using exp_add_of_commute hcomm
#align commute.exp_unitary_add Commute.expUnitary_add
-/

#print Commute.expUnitary /-
theorem Commute.expUnitary {a b : selfAdjoint A} (h : Commute (a : A) (b : A)) :
    Commute (expUnitary a) (expUnitary b) :=
  calc
    expUnitary a * expUnitary b = expUnitary b * expUnitary a := by
      rw [← h.exp_unitary_add, ← h.symm.exp_unitary_add, add_comm]
#align commute.exp_unitary Commute.expUnitary
-/

end Star

