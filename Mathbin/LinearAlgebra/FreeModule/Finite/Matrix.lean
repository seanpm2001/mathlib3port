/-
Copyright (c) 2021 Riccardo Brasca. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Riccardo Brasca

! This file was ported from Lean 3 source module linear_algebra.free_module.finite.matrix
! leanprover-community/mathlib commit f2b757fc5c341d88741b9c4630b1e8ba973c5726
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Finrank
import Mathbin.LinearAlgebra.FreeModule.Finite.Rank
import Mathbin.LinearAlgebra.Matrix.ToLin

/-!
# Finite and free modules using matrices

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We provide some instances for finite and free modules involving matrices.

## Main results

* `module.free.linear_map` : if `M` and `N` are finite and free, then `M →ₗ[R] N` is free.
* `module.finite.of_basis` : A free module with a basis indexed by a `fintype` is finite.
* `module.finite.linear_map` : if `M` and `N` are finite and free, then `M →ₗ[R] N`
  is finite.
-/


universe u v w

variable (R : Type u) (M : Type v) (N : Type w)

open Module.Free (chooseBasis)

open FiniteDimensional (finrank)

section CommRing

variable [CommRing R] [AddCommGroup M] [Module R M] [Module.Free R M]

variable [AddCommGroup N] [Module R N] [Module.Free R N]

#print Module.Free.linearMap /-
instance Module.Free.linearMap [Module.Finite R M] [Module.Finite R N] :
    Module.Free R (M →ₗ[R] N) :=
  by
  cases subsingleton_or_nontrivial R
  · apply Module.Free.of_subsingleton'
  classical exact
    Module.Free.of_equiv (LinearMap.toMatrix (choose_basis R M) (choose_basis R N)).symm
#align module.free.linear_map Module.Free.linearMap
-/

variable {R}

#print Module.Finite.linearMap /-
instance Module.Finite.linearMap [Module.Finite R M] [Module.Finite R N] :
    Module.Finite R (M →ₗ[R] N) :=
  by
  cases subsingleton_or_nontrivial R
  · infer_instance
  classical
  have f := (LinearMap.toMatrix (choose_basis R M) (choose_basis R N)).symm
  exact Module.Finite.of_surjective f.to_linear_map (LinearEquiv.surjective f)
#align module.finite.linear_map Module.Finite.linearMap
-/

end CommRing

section Integer

variable [AddCommGroup M] [Module.Finite ℤ M] [Module.Free ℤ M]

variable [AddCommGroup N] [Module.Finite ℤ N] [Module.Free ℤ N]

#print Module.Finite.addMonoidHom /-
instance Module.Finite.addMonoidHom : Module.Finite ℤ (M →+ N) :=
  Module.Finite.equiv (addMonoidHomLequivInt ℤ).symm
#align module.finite.add_monoid_hom Module.Finite.addMonoidHom
-/

#print Module.Free.addMonoidHom /-
instance Module.Free.addMonoidHom : Module.Free ℤ (M →+ N) :=
  letI : Module.Free ℤ (M →ₗ[ℤ] N) := Module.Free.linearMap _ _ _
  Module.Free.of_equiv (addMonoidHomLequivInt ℤ).symm
#align module.free.add_monoid_hom Module.Free.addMonoidHom
-/

end Integer

section CommRing

variable [CommRing R] [StrongRankCondition R]

variable [AddCommGroup M] [Module R M] [Module.Free R M] [Module.Finite R M]

variable [AddCommGroup N] [Module R N] [Module.Free R N] [Module.Finite R N]

#print FiniteDimensional.finrank_linearMap /-
/-- The finrank of `M →ₗ[R] N` is `(finrank R M) * (finrank R N)`. -/
theorem FiniteDimensional.finrank_linearMap : finrank R (M →ₗ[R] N) = finrank R M * finrank R N :=
  by
  classical
  letI := nontrivial_of_invariantBasisNumber R
  have h := LinearMap.toMatrix (choose_basis R M) (choose_basis R N)
  simp_rw [h.finrank_eq, FiniteDimensional.finrank_matrix,
    FiniteDimensional.finrank_eq_card_chooseBasisIndex, mul_comm]
#align finite_dimensional.finrank_linear_map FiniteDimensional.finrank_linearMap
-/

end CommRing

#print Matrix.rank_vecMulVec /-
theorem Matrix.rank_vecMulVec {K m n : Type u} [CommRing K] [StrongRankCondition K] [Fintype n]
    [DecidableEq n] (w : m → K) (v : n → K) : (Matrix.vecMulVec w v).toLin'.rank ≤ 1 :=
  by
  rw [Matrix.vecMulVec_eq, Matrix.toLin'_mul]
  refine' le_trans (LinearMap.rank_comp_le_left _ _) _
  refine' (LinearMap.rank_le_domain _).trans_eq _
  rw [rank_fun', Fintype.card_unit, Nat.cast_one]
#align matrix.rank_vec_mul_vec Matrix.rank_vecMulVec
-/

