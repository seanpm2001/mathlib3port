/-
Copyright (c) 2021 Riccardo Brasca. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Riccardo Brasca

! This file was ported from Lean 3 source module linear_algebra.free_module.finite.rank
! leanprover-community/mathlib commit ce38d86c0b2d427ce208c3cee3159cb421d2b3c4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Finrank
import Mathbin.LinearAlgebra.FreeModule.Rank
import Mathbin.LinearAlgebra.FreeModule.Finite.Basic

/-!

# Rank of finite free modules

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This is a basic API for the rank of finite free modules.

-/


--TODO: many results from `linear_algebra/finite_dimensional` should be moved here.
universe u v w

variable (R : Type u) (M : Type v) (N : Type w)

open scoped TensorProduct DirectSum BigOperators Cardinal

open Cardinal FiniteDimensional Fintype

namespace FiniteDimensional

open Module.Free

section Ring

variable [Ring R]

variable [AddCommGroup M] [Module R M]

variable [AddCommGroup N] [Module R N]

#print FiniteDimensional.Submodule.finrank_map_subtype_eq /-
@[simp]
theorem Submodule.finrank_map_subtype_eq (p : Submodule R M) (q : Submodule R p) :
    finrank R (q.map p.Subtype) = finrank R q :=
  (Submodule.equivSubtypeMap p q).symm.finrank_eq
#align finite_dimensional.submodule.finrank_map_subtype_eq FiniteDimensional.Submodule.finrank_map_subtype_eq
-/

end Ring

section RingFinite

variable [Ring R] [StrongRankCondition R]

variable [AddCommGroup M] [Module R M] [Module.Finite R M]

variable [AddCommGroup N] [Module R N] [Module.Finite R N]

#print FiniteDimensional.rank_lt_aleph0 /-
/-- The rank of a finite module is finite. -/
theorem rank_lt_aleph0 : Module.rank R M < ℵ₀ :=
  by
  dsimp only [Module.rank]
  letI := nontrivial_of_invariantBasisNumber R
  obtain ⟨S, hS⟩ := module.finite_def.mp ‹_›
  refine' (ciSup_le' fun i => _).trans_lt (nat_lt_aleph_0 S.card)
  exact linearIndependent_le_span_finset _ i.prop S hS
#align finite_dimensional.rank_lt_aleph_0 FiniteDimensional.rank_lt_aleph0
-/

#print FiniteDimensional.finrank_eq_rank /-
/-- If `M` is finite, `finrank M = rank M`. -/
@[simp]
theorem finrank_eq_rank : ↑(finrank R M) = Module.rank R M := by
  rw [finrank, cast_to_nat_of_lt_aleph_0 (rank_lt_aleph_0 R M)]
#align finite_dimensional.finrank_eq_rank FiniteDimensional.finrank_eq_rank
-/

end RingFinite

section RingFree

variable [Ring R] [StrongRankCondition R]

variable [AddCommGroup M] [Module R M] [Module.Free R M] [Module.Finite R M]

variable [AddCommGroup N] [Module R N] [Module.Free R N] [Module.Finite R N]

#print FiniteDimensional.finrank_eq_card_chooseBasisIndex /-
/-- The finrank of a free module `M` over `R` is the cardinality of `choose_basis_index R M`. -/
theorem finrank_eq_card_chooseBasisIndex :
    finrank R M =
      @card (ChooseBasisIndex R M)
        (@ChooseBasisIndex.fintype R M _ _ _ _ (nontrivial_of_invariantBasisNumber R) _) :=
  by
  letI := nontrivial_of_invariantBasisNumber R
  simp [finrank, rank_eq_card_choose_basis_index]
#align finite_dimensional.finrank_eq_card_choose_basis_index FiniteDimensional.finrank_eq_card_chooseBasisIndex
-/

#print FiniteDimensional.finrank_finsupp /-
/-- The finrank of `(ι →₀ R)` is `fintype.card ι`. -/
@[simp]
theorem finrank_finsupp {ι : Type v} [Fintype ι] : finrank R (ι →₀ R) = card ι := by
  rw [finrank, rank_finsupp_self, ← mk_to_nat_eq_card, to_nat_lift]
#align finite_dimensional.finrank_finsupp FiniteDimensional.finrank_finsupp
-/

#print FiniteDimensional.finrank_pi /-
/-- The finrank of `(ι → R)` is `fintype.card ι`. -/
theorem finrank_pi {ι : Type v} [Fintype ι] : finrank R (ι → R) = card ι := by simp [finrank]
#align finite_dimensional.finrank_pi FiniteDimensional.finrank_pi
-/

#print FiniteDimensional.finrank_directSum /-
/-- The finrank of the direct sum is the sum of the finranks. -/
@[simp]
theorem finrank_directSum {ι : Type v} [Fintype ι] (M : ι → Type w) [∀ i : ι, AddCommGroup (M i)]
    [∀ i : ι, Module R (M i)] [∀ i : ι, Module.Free R (M i)] [∀ i : ι, Module.Finite R (M i)] :
    finrank R (⨁ i, M i) = ∑ i, finrank R (M i) :=
  by
  letI := nontrivial_of_invariantBasisNumber R
  simp only [finrank, fun i => rank_eq_card_choose_basis_index R (M i), rank_directSum, ← mk_sigma,
    mk_to_nat_eq_card, card_sigma]
#align finite_dimensional.finrank_direct_sum FiniteDimensional.finrank_directSum
-/

#print FiniteDimensional.finrank_prod /-
/-- The finrank of `M × N` is `(finrank R M) + (finrank R N)`. -/
@[simp]
theorem finrank_prod : finrank R (M × N) = finrank R M + finrank R N := by
  simp [finrank, rank_lt_aleph_0 R M, rank_lt_aleph_0 R N]
#align finite_dimensional.finrank_prod FiniteDimensional.finrank_prod
-/

#print FiniteDimensional.finrank_pi_fintype /-
--TODO: this should follow from `linear_equiv.finrank_eq`, that is over a field.
/-- The finrank of a finite product is the sum of the finranks. -/
theorem finrank_pi_fintype {ι : Type v} [Fintype ι] {M : ι → Type w} [∀ i : ι, AddCommGroup (M i)]
    [∀ i : ι, Module R (M i)] [∀ i : ι, Module.Free R (M i)] [∀ i : ι, Module.Finite R (M i)] :
    finrank R (∀ i, M i) = ∑ i, finrank R (M i) :=
  by
  letI := nontrivial_of_invariantBasisNumber R
  simp only [finrank, fun i => rank_eq_card_choose_basis_index R (M i), rank_pi, ← mk_sigma,
    mk_to_nat_eq_card, card_sigma]
#align finite_dimensional.finrank_pi_fintype FiniteDimensional.finrank_pi_fintype
-/

#print FiniteDimensional.finrank_matrix /-
/-- If `m` and `n` are `fintype`, the finrank of `m × n` matrices is
  `(fintype.card m) * (fintype.card n)`. -/
theorem finrank_matrix (m n : Type _) [Fintype m] [Fintype n] :
    finrank R (Matrix m n R) = card m * card n := by simp [finrank]
#align finite_dimensional.finrank_matrix FiniteDimensional.finrank_matrix
-/

variable {R M N}

#print FiniteDimensional.nonempty_linearEquiv_of_finrank_eq /-
/-- Two finite and free modules are isomorphic if they have the same (finite) rank. -/
theorem nonempty_linearEquiv_of_finrank_eq (cond : finrank R M = finrank R N) :
    Nonempty (M ≃ₗ[R] N) :=
  nonempty_linearEquiv_of_lift_rank_eq <| by simp only [← finrank_eq_rank, cond, lift_nat_cast]
#align finite_dimensional.nonempty_linear_equiv_of_finrank_eq FiniteDimensional.nonempty_linearEquiv_of_finrank_eq
-/

#print FiniteDimensional.nonempty_linearEquiv_iff_finrank_eq /-
/-- Two finite and free modules are isomorphic if and only if they have the same (finite) rank. -/
theorem nonempty_linearEquiv_iff_finrank_eq : Nonempty (M ≃ₗ[R] N) ↔ finrank R M = finrank R N :=
  ⟨fun ⟨h⟩ => h.finrank_eq, fun h => nonempty_linearEquiv_of_finrank_eq h⟩
#align finite_dimensional.nonempty_linear_equiv_iff_finrank_eq FiniteDimensional.nonempty_linearEquiv_iff_finrank_eq
-/

variable (M N)

#print LinearEquiv.ofFinrankEq /-
/-- Two finite and free modules are isomorphic if they have the same (finite) rank. -/
noncomputable def LinearEquiv.ofFinrankEq (cond : finrank R M = finrank R N) : M ≃ₗ[R] N :=
  Classical.choice <| nonempty_linearEquiv_of_finrank_eq cond
#align linear_equiv.of_finrank_eq LinearEquiv.ofFinrankEq
-/

end RingFree

section CommRing

variable [CommRing R] [StrongRankCondition R]

variable [AddCommGroup M] [Module R M] [Module.Free R M] [Module.Finite R M]

variable [AddCommGroup N] [Module R N] [Module.Free R N] [Module.Finite R N]

#print FiniteDimensional.finrank_tensorProduct /-
/-- The finrank of `M ⊗[R] N` is `(finrank R M) * (finrank R N)`. -/
@[simp]
theorem finrank_tensorProduct (M : Type v) (N : Type w) [AddCommGroup M] [Module R M]
    [Module.Free R M] [AddCommGroup N] [Module R N] [Module.Free R N] :
    finrank R (M ⊗[R] N) = finrank R M * finrank R N := by simp [finrank]
#align finite_dimensional.finrank_tensor_product FiniteDimensional.finrank_tensorProduct
-/

end CommRing

end FiniteDimensional

section

open FiniteDimensional

variable {R M N}

variable [Ring R] [StrongRankCondition R]

variable [AddCommGroup M] [Module R M]

variable [AddCommGroup N] [Module R N]

#print LinearMap.finrank_le_finrank_of_injective /-
theorem LinearMap.finrank_le_finrank_of_injective [Module.Finite R N] {f : M →ₗ[R] N}
    (hf : Function.Injective f) : finrank R M ≤ finrank R N :=
  finrank_le_finrank_of_rank_le_rank (LinearMap.lift_rank_le_of_injective _ hf) (rank_lt_aleph0 _ _)
#align linear_map.finrank_le_finrank_of_injective LinearMap.finrank_le_finrank_of_injective
-/

#print LinearMap.finrank_range_le /-
theorem LinearMap.finrank_range_le [Module.Finite R M] (f : M →ₗ[R] N) :
    finrank R f.range ≤ finrank R M :=
  finrank_le_finrank_of_rank_le_rank (lift_rank_range_le f) (rank_lt_aleph0 _ _)
#align linear_map.finrank_range_le LinearMap.finrank_range_le
-/

#print Submodule.finrank_le /-
/-- The dimension of a submodule is bounded by the dimension of the ambient space. -/
theorem Submodule.finrank_le [Module.Finite R M] (s : Submodule R M) : finrank R s ≤ finrank R M :=
  by
  simpa only [Cardinal.toNat_lift] using
    to_nat_le_of_le_of_lt_aleph_0 (rank_lt_aleph_0 _ _) (rank_submodule_le s)
#align submodule.finrank_le Submodule.finrank_le
-/

#print Submodule.finrank_quotient_le /-
/-- The dimension of a quotient is bounded by the dimension of the ambient space. -/
theorem Submodule.finrank_quotient_le [Module.Finite R M] (s : Submodule R M) :
    finrank R (M ⧸ s) ≤ finrank R M := by
  simpa only [Cardinal.toNat_lift] using
    to_nat_le_of_le_of_lt_aleph_0 (rank_lt_aleph_0 _ _)
      ((Submodule.mkQ s).rank_le_of_surjective (surjective_quot_mk _))
#align submodule.finrank_quotient_le Submodule.finrank_quotient_le
-/

#print Submodule.finrank_map_le /-
/-- Pushforwards of finite submodules have a smaller finrank. -/
theorem Submodule.finrank_map_le (f : M →ₗ[R] N) (p : Submodule R M) [Module.Finite R p] :
    finrank R (p.map f) ≤ finrank R p :=
  finrank_le_finrank_of_rank_le_rank (lift_rank_map_le _ _) (rank_lt_aleph0 _ _)
#align submodule.finrank_map_le Submodule.finrank_map_le
-/

#print Submodule.finrank_le_finrank_of_le /-
theorem Submodule.finrank_le_finrank_of_le {s t : Submodule R M} [Module.Finite R t] (hst : s ≤ t) :
    finrank R s ≤ finrank R t :=
  calc
    finrank R s = finrank R (s.comap t.Subtype) :=
      (Submodule.comapSubtypeEquivOfLe hst).finrank_eq.symm
    _ ≤ finrank R t := Submodule.finrank_le _
#align submodule.finrank_le_finrank_of_le Submodule.finrank_le_finrank_of_le
-/

end

