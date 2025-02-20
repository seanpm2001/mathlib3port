/-
Copyright (c) 2022 John Nicol. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: John Nicol

! This file was ported from Lean 3 source module number_theory.wilson
! leanprover-community/mathlib commit 087c325ae0ab42dbdd5dee55bc37d3d5a0bf2197
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.FieldTheory.Finite.Basic

/-!
# Wilson's theorem.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains a proof of Wilson's theorem.

The heavy lifting is mostly done by the previous `wilsons_lemma`,
but here we also prove the other logical direction.

This could be generalized to similar results about finite abelian groups.

## References

* [Wilson's Theorem](https://en.wikipedia.org/wiki/Wilson%27s_theorem)

## TODO

* Give `wilsons_lemma` a descriptive name.
-/


open Finset Nat FiniteField ZMod

open scoped BigOperators Nat

namespace ZMod

variable (p : ℕ) [Fact p.Prime]

#print ZMod.wilsons_lemma /-
/-- **Wilson's Lemma**: the product of `1`, ..., `p-1` is `-1` modulo `p`. -/
@[simp]
theorem wilsons_lemma : ((p - 1)! : ZMod p) = -1 :=
  by
  refine'
    calc
      ((p - 1)! : ZMod p) = ∏ x in Ico 1 (succ (p - 1)), x := by
        rw [← Finset.prod_Ico_id_eq_factorial, prod_nat_cast]
      _ = ∏ x : (ZMod p)ˣ, x := _
      _ = -1 := by
        simp_rw [← Units.coeHom_apply, ← (Units.coeHom (ZMod p)).map_prod,
          prod_univ_units_id_eq_neg_one, Units.coeHom_apply, Units.val_neg, Units.val_one]
  have hp : 0 < p := (Fact.out p.prime).Pos
  symm
  refine' prod_bij (fun a _ => (a : ZMod p).val) _ _ _ _
  · intro a ha
    rw [mem_Ico, ← Nat.succ_sub hp, Nat.succ_sub_one]
    constructor
    · apply Nat.pos_of_ne_zero; rw [← @val_zero p]
      intro h; apply Units.ne_zero a (val_injective p h)
    · exact val_lt _
  · intro a ha; simp only [cast_id, nat_cast_val]
  · intro _ _ _ _ h; rw [Units.ext_iff]; exact val_injective p h
  · intro b hb
    rw [mem_Ico, Nat.succ_le_iff, ← succ_sub hp, succ_sub_one, pos_iff_ne_zero] at hb 
    refine' ⟨Units.mk0 b _, Finset.mem_univ _, _⟩
    · intro h; apply hb.1; apply_fun val at h 
      simpa only [val_cast_of_lt hb.right, val_zero] using h
    · simp only [val_cast_of_lt hb.right, Units.val_mk0]
#align zmod.wilsons_lemma ZMod.wilsons_lemma
-/

#print ZMod.prod_Ico_one_prime /-
@[simp]
theorem prod_Ico_one_prime : ∏ x in Ico 1 p, (x : ZMod p) = -1 :=
  by
  conv in Ico 1 p => rw [← succ_sub_one p, succ_sub (Fact.out p.prime).Pos]
  rw [← prod_nat_cast, Finset.prod_Ico_id_eq_factorial, wilsons_lemma]
#align zmod.prod_Ico_one_prime ZMod.prod_Ico_one_prime
-/

end ZMod

namespace Nat

variable {n : ℕ}

#print Nat.prime_of_fac_equiv_neg_one /-
/-- For `n ≠ 1`, `(n-1)!` is congruent to `-1` modulo `n` only if n is prime. -/
theorem prime_of_fac_equiv_neg_one (h : ((n - 1)! : ZMod n) = -1) (h1 : n ≠ 1) : Prime n :=
  by
  rcases eq_or_ne n 0 with (rfl | h0)
  · norm_num at h 
  replace h1 : 1 < n := n.two_le_iff.mpr ⟨h0, h1⟩
  by_contra h2
  obtain ⟨m, hm1, hm2 : 1 < m, hm3⟩ := exists_dvd_of_not_prime2 h1 h2
  have hm : m ∣ (n - 1)! := Nat.dvd_factorial (pos_of_gt hm2) (le_pred_of_lt hm3)
  refine' hm2.ne' (nat.dvd_one.mp ((Nat.dvd_add_right hm).mp (hm1.trans _)))
  rw [← ZMod.nat_cast_zmod_eq_zero_iff_dvd, cast_add, cast_one, h, add_left_neg]
#align nat.prime_of_fac_equiv_neg_one Nat.prime_of_fac_equiv_neg_one
-/

#print Nat.prime_iff_fac_equiv_neg_one /-
/-- **Wilson's Theorem**: For `n ≠ 1`, `(n-1)!` is congruent to `-1` modulo `n` iff n is prime. -/
theorem prime_iff_fac_equiv_neg_one (h : n ≠ 1) : Prime n ↔ ((n - 1)! : ZMod n) = -1 :=
  by
  refine' ⟨fun h1 => _, fun h2 => prime_of_fac_equiv_neg_one h2 h⟩
  haveI := Fact.mk h1
  exact ZMod.wilsons_lemma n
#align nat.prime_iff_fac_equiv_neg_one Nat.prime_iff_fac_equiv_neg_one
-/

end Nat

assert_not_exists legendreSym.quadratic_reciprocity

