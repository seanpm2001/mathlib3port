/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module algebra.char_p.two
! leanprover-community/mathlib commit 10bf4f825ad729c5653adc039dafa3622e7f93c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.CharP.Basic

/-!
# Lemmas about rings of characteristic two

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains results about `char_p R 2`, in the `char_two` namespace.

The lemmas in this file with a `_sq` suffix are just special cases of the `_pow_char` lemmas
elsewhere, with a shorter name for ease of discovery, and no need for a `[fact (prime 2)]` argument.
-/


variable {R ι : Type _}

namespace CharTwo

section Semiring

variable [Semiring R] [CharP R 2]

#print CharTwo.two_eq_zero /-
theorem two_eq_zero : (2 : R) = 0 := by rw [← Nat.cast_two, CharP.cast_eq_zero]
#align char_two.two_eq_zero CharTwo.two_eq_zero
-/

#print CharTwo.add_self_eq_zero /-
@[simp]
theorem add_self_eq_zero (x : R) : x + x = 0 := by rw [← two_smul R x, two_eq_zero, zero_smul]
#align char_two.add_self_eq_zero CharTwo.add_self_eq_zero
-/

#print CharTwo.bit0_eq_zero /-
@[simp]
theorem bit0_eq_zero : (bit0 : R → R) = 0 := by funext; exact add_self_eq_zero _
#align char_two.bit0_eq_zero CharTwo.bit0_eq_zero
-/

#print CharTwo.bit0_apply_eq_zero /-
theorem bit0_apply_eq_zero (x : R) : (bit0 x : R) = 0 := by simp
#align char_two.bit0_apply_eq_zero CharTwo.bit0_apply_eq_zero
-/

#print CharTwo.bit1_eq_one /-
@[simp]
theorem bit1_eq_one : (bit1 : R → R) = 1 := by funext; simp [bit1]
#align char_two.bit1_eq_one CharTwo.bit1_eq_one
-/

#print CharTwo.bit1_apply_eq_one /-
theorem bit1_apply_eq_one (x : R) : (bit1 x : R) = 1 := by simp
#align char_two.bit1_apply_eq_one CharTwo.bit1_apply_eq_one
-/

end Semiring

section Ring

variable [Ring R] [CharP R 2]

#print CharTwo.neg_eq /-
@[simp]
theorem neg_eq (x : R) : -x = x := by
  rw [neg_eq_iff_add_eq_zero, ← two_smul R x, two_eq_zero, zero_smul]
#align char_two.neg_eq CharTwo.neg_eq
-/

#print CharTwo.neg_eq' /-
theorem neg_eq' : Neg.neg = (id : R → R) :=
  funext neg_eq
#align char_two.neg_eq' CharTwo.neg_eq'
-/

#print CharTwo.sub_eq_add /-
@[simp]
theorem sub_eq_add (x y : R) : x - y = x + y := by rw [sub_eq_add_neg, neg_eq]
#align char_two.sub_eq_add CharTwo.sub_eq_add
-/

#print CharTwo.sub_eq_add' /-
theorem sub_eq_add' : Sub.sub = ((· + ·) : R → R → R) :=
  funext fun x => funext fun y => sub_eq_add x y
#align char_two.sub_eq_add' CharTwo.sub_eq_add'
-/

end Ring

section CommSemiring

variable [CommSemiring R] [CharP R 2]

#print CharTwo.add_sq /-
theorem add_sq (x y : R) : (x + y) ^ 2 = x ^ 2 + y ^ 2 :=
  add_pow_char _ _ _
#align char_two.add_sq CharTwo.add_sq
-/

#print CharTwo.add_mul_self /-
theorem add_mul_self (x y : R) : (x + y) * (x + y) = x * x + y * y := by
  rw [← pow_two, ← pow_two, ← pow_two, add_sq]
#align char_two.add_mul_self CharTwo.add_mul_self
-/

open scoped BigOperators

#print CharTwo.list_sum_sq /-
theorem list_sum_sq (l : List R) : l.Sum ^ 2 = (l.map (· ^ 2)).Sum :=
  list_sum_pow_char _ _
#align char_two.list_sum_sq CharTwo.list_sum_sq
-/

#print CharTwo.list_sum_mul_self /-
theorem list_sum_mul_self (l : List R) : l.Sum * l.Sum = (List.map (fun x => x * x) l).Sum := by
  simp_rw [← pow_two, list_sum_sq]
#align char_two.list_sum_mul_self CharTwo.list_sum_mul_self
-/

#print CharTwo.multiset_sum_sq /-
theorem multiset_sum_sq (l : Multiset R) : l.Sum ^ 2 = (l.map (· ^ 2)).Sum :=
  multiset_sum_pow_char _ _
#align char_two.multiset_sum_sq CharTwo.multiset_sum_sq
-/

#print CharTwo.multiset_sum_mul_self /-
theorem multiset_sum_mul_self (l : Multiset R) :
    l.Sum * l.Sum = (Multiset.map (fun x => x * x) l).Sum := by simp_rw [← pow_two, multiset_sum_sq]
#align char_two.multiset_sum_mul_self CharTwo.multiset_sum_mul_self
-/

#print CharTwo.sum_sq /-
theorem sum_sq (s : Finset ι) (f : ι → R) : (∑ i in s, f i) ^ 2 = ∑ i in s, f i ^ 2 :=
  sum_pow_char _ _ _
#align char_two.sum_sq CharTwo.sum_sq
-/

#print CharTwo.sum_mul_self /-
theorem sum_mul_self (s : Finset ι) (f : ι → R) :
    (∑ i in s, f i) * ∑ i in s, f i = ∑ i in s, f i * f i := by simp_rw [← pow_two, sum_sq]
#align char_two.sum_mul_self CharTwo.sum_mul_self
-/

end CommSemiring

end CharTwo

section ringChar

variable [Ring R]

#print neg_one_eq_one_iff /-
theorem neg_one_eq_one_iff [Nontrivial R] : (-1 : R) = 1 ↔ ringChar R = 2 :=
  by
  refine' ⟨fun h => _, fun h => @CharTwo.neg_eq _ (ringChar.of_eq h) 1⟩
  rw [eq_comm, ← sub_eq_zero, sub_neg_eq_add, ← Nat.cast_one, ← Nat.cast_add] at h 
  exact ((Nat.dvd_prime Nat.prime_two).mp (ringChar.dvd h)).resolve_left CharP.ringChar_ne_one
#align neg_one_eq_one_iff neg_one_eq_one_iff
-/

#print orderOf_neg_one /-
@[simp]
theorem orderOf_neg_one [Nontrivial R] : orderOf (-1 : R) = if ringChar R = 2 then 1 else 2 :=
  by
  split_ifs
  · rw [neg_one_eq_one_iff.2 h, orderOf_one]
  apply orderOf_eq_prime
  · simp
  simpa [neg_one_eq_one_iff] using h
#align order_of_neg_one orderOf_neg_one
-/

end ringChar

