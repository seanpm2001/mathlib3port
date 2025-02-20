/-
Copyright (c) 2021 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes

! This file was ported from Lean 3 source module ring_theory.nakayama
! leanprover-community/mathlib commit 33c67ae661dd8988516ff7f247b0be3018cdd952
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.JacobsonIdeal

/-!
# Nakayama's lemma

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains some alternative statements of Nakayama's Lemma as found in
[Stacks: Nakayama's Lemma](https://stacks.math.columbia.edu/tag/00DV).

## Main statements

* `submodule.eq_smul_of_le_smul_of_le_jacobson` - A version of (2) in
  [Stacks: Nakayama's Lemma](https://stacks.math.columbia.edu/tag/00DV).,
  generalising to the Jacobson of any ideal.
* `submodule.eq_bot_of_le_smul_of_le_jacobson_bot` - Statement (2) in
  [Stacks: Nakayama's Lemma](https://stacks.math.columbia.edu/tag/00DV).

* `submodule.smul_sup_eq_smul_sup_of_le_smul_of_le_jacobson` - A version of (4) in
  [Stacks: Nakayama's Lemma](https://stacks.math.columbia.edu/tag/00DV).,
  generalising to the Jacobson of any ideal.
* `submodule.smul_sup_eq_of_le_smul_of_le_jacobson_bot` - Statement (4) in
  [Stacks: Nakayama's Lemma](https://stacks.math.columbia.edu/tag/00DV).

Note that a version of Statement (1) in
[Stacks: Nakayama's Lemma](https://stacks.math.columbia.edu/tag/00DV) can be found in
`ring_theory/noetherian` under the name
`submodule.exists_sub_one_mem_and_smul_eq_zero_of_fg_of_le_smul`

## References
* [Stacks: Nakayama's Lemma](https://stacks.math.columbia.edu/tag/00DV)

## Tags
Nakayama, Jacobson
-/


variable {R M : Type _} [CommRing R] [AddCommGroup M] [Module R M]

open Ideal

namespace Submodule

#print Submodule.eq_smul_of_le_smul_of_le_jacobson /-
/-- *Nakayama's Lemma** - A slightly more general version of (2) in
[Stacks 00DV](https://stacks.math.columbia.edu/tag/00DV).
See also `eq_bot_of_le_smul_of_le_jacobson_bot` for the special case when `J = ⊥`.  -/
theorem eq_smul_of_le_smul_of_le_jacobson {I J : Ideal R} {N : Submodule R M} (hN : N.FG)
    (hIN : N ≤ I • N) (hIjac : I ≤ jacobson J) : N = J • N :=
  by
  refine' le_antisymm _ (Submodule.smul_le.2 fun _ _ _ => Submodule.smul_mem _ _)
  intro n hn
  cases' Submodule.exists_sub_one_mem_and_smul_eq_zero_of_fg_of_le_smul I N hN hIN with r hr
  cases' exists_mul_sub_mem_of_sub_one_mem_jacobson r (hIjac hr.1) with s hs
  have : n = -(s * r - 1) • n := by
    rw [neg_sub, sub_smul, mul_smul, hr.2 n hn, one_smul, smul_zero, sub_zero]
  rw [this]
  exact Submodule.smul_mem_smul (Submodule.neg_mem _ hs) hn
#align submodule.eq_smul_of_le_smul_of_le_jacobson Submodule.eq_smul_of_le_smul_of_le_jacobson
-/

#print Submodule.eq_bot_of_le_smul_of_le_jacobson_bot /-
/-- *Nakayama's Lemma** - Statement (2) in
[Stacks 00DV](https://stacks.math.columbia.edu/tag/00DV).
See also `eq_smul_of_le_smul_of_le_jacobson` for a generalisation
to the `jacobson` of any ideal -/
theorem eq_bot_of_le_smul_of_le_jacobson_bot (I : Ideal R) (N : Submodule R M) (hN : N.FG)
    (hIN : N ≤ I • N) (hIjac : I ≤ jacobson ⊥) : N = ⊥ := by
  rw [eq_smul_of_le_smul_of_le_jacobson hN hIN hIjac, Submodule.bot_smul]
#align submodule.eq_bot_of_le_smul_of_le_jacobson_bot Submodule.eq_bot_of_le_smul_of_le_jacobson_bot
-/

#print Submodule.smul_sup_eq_smul_sup_of_le_smul_of_le_jacobson /-
/-- *Nakayama's Lemma** - A slightly more general version of (4) in
[Stacks 00DV](https://stacks.math.columbia.edu/tag/00DV).
See also `smul_sup_eq_of_le_smul_of_le_jacobson_bot` for the special case when `J = ⊥`.  -/
theorem smul_sup_eq_smul_sup_of_le_smul_of_le_jacobson {I J : Ideal R} {N N' : Submodule R M}
    (hN' : N'.FG) (hIJ : I ≤ jacobson J) (hNN : N ⊔ N' ≤ N ⊔ I • N') : N ⊔ I • N' = N ⊔ J • N' :=
  by
  have hNN' : N ⊔ N' = N ⊔ I • N' :=
    le_antisymm hNN (sup_le_sup_left (Submodule.smul_le.2 fun _ _ _ => Submodule.smul_mem _ _) _)
  have h_comap := Submodule.comap_injective_of_surjective (LinearMap.range_eq_top.1 N.range_mkq)
  have : (I • N').map N.mkq = N'.map N.mkq :=
    by
    rw [← h_comap.eq_iff]
    simpa [comap_map_eq, sup_comm, eq_comm] using hNN'
  have :=
    @Submodule.eq_smul_of_le_smul_of_le_jacobson _ _ _ _ _ I J (N'.map N.mkq) (hN'.map _)
      (by rw [← map_smul'', this] <;> exact le_rfl) hIJ
  rw [← map_smul'', ← h_comap.eq_iff, comap_map_eq, comap_map_eq, Submodule.ker_mkQ, sup_comm,
    hNN'] at this 
  rw [this, sup_comm]
#align submodule.smul_sup_eq_smul_sup_of_le_smul_of_le_jacobson Submodule.smul_sup_eq_smul_sup_of_le_smul_of_le_jacobson
-/

#print Submodule.smul_sup_le_of_le_smul_of_le_jacobson_bot /-
/-- *Nakayama's Lemma** - Statement (4) in
[Stacks 00DV](https://stacks.math.columbia.edu/tag/00DV).
See also `smul_sup_eq_smul_sup_of_le_smul_of_le_jacobson` for a generalisation
to the `jacobson` of any ideal -/
theorem smul_sup_le_of_le_smul_of_le_jacobson_bot {I : Ideal R} {N N' : Submodule R M} (hN' : N'.FG)
    (hIJ : I ≤ jacobson ⊥) (hNN : N ⊔ N' ≤ N ⊔ I • N') : I • N' ≤ N := by
  rw [← sup_eq_left, smul_sup_eq_smul_sup_of_le_smul_of_le_jacobson hN' hIJ hNN, bot_smul,
    sup_bot_eq]
#align submodule.smul_sup_le_of_le_smul_of_le_jacobson_bot Submodule.smul_sup_le_of_le_smul_of_le_jacobson_bot
-/

end Submodule

