/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module algebra.big_operators.nat_antidiagonal
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finset.NatAntidiagonal
import Mathbin.Algebra.BigOperators.Basic

/-!
# Big operators for `nat_antidiagonal`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains theorems relevant to big operators over `finset.nat.antidiagonal`.
-/


open scoped BigOperators

variable {M N : Type _} [CommMonoid M] [AddCommMonoid N]

namespace Finset

namespace Nat

#print Finset.Nat.prod_antidiagonal_succ /-
theorem prod_antidiagonal_succ {n : ℕ} {f : ℕ × ℕ → M} :
    ∏ p in antidiagonal (n + 1), f p = f (0, n + 1) * ∏ p in antidiagonal n, f (p.1 + 1, p.2) := by
  rw [antidiagonal_succ, prod_cons, Prod_map]; rfl
#align finset.nat.prod_antidiagonal_succ Finset.Nat.prod_antidiagonal_succ
-/

#print Finset.Nat.sum_antidiagonal_succ /-
theorem sum_antidiagonal_succ {n : ℕ} {f : ℕ × ℕ → N} :
    ∑ p in antidiagonal (n + 1), f p = f (0, n + 1) + ∑ p in antidiagonal n, f (p.1 + 1, p.2) :=
  @prod_antidiagonal_succ (Multiplicative N) _ _ _
#align finset.nat.sum_antidiagonal_succ Finset.Nat.sum_antidiagonal_succ
-/

#print Finset.Nat.prod_antidiagonal_swap /-
@[to_additive]
theorem prod_antidiagonal_swap {n : ℕ} {f : ℕ × ℕ → M} :
    ∏ p in antidiagonal n, f p.symm = ∏ p in antidiagonal n, f p := by
  nth_rw 2 [← map_swap_antidiagonal]; rw [Prod_map]; rfl
#align finset.nat.prod_antidiagonal_swap Finset.Nat.prod_antidiagonal_swap
#align finset.nat.sum_antidiagonal_swap Finset.Nat.sum_antidiagonal_swap
-/

#print Finset.Nat.prod_antidiagonal_succ' /-
theorem prod_antidiagonal_succ' {n : ℕ} {f : ℕ × ℕ → M} :
    ∏ p in antidiagonal (n + 1), f p = f (n + 1, 0) * ∏ p in antidiagonal n, f (p.1, p.2 + 1) :=
  by
  rw [← prod_antidiagonal_swap, prod_antidiagonal_succ, ← prod_antidiagonal_swap]
  rfl
#align finset.nat.prod_antidiagonal_succ' Finset.Nat.prod_antidiagonal_succ'
-/

#print Finset.Nat.sum_antidiagonal_succ' /-
theorem sum_antidiagonal_succ' {n : ℕ} {f : ℕ × ℕ → N} :
    ∑ p in antidiagonal (n + 1), f p = f (n + 1, 0) + ∑ p in antidiagonal n, f (p.1, p.2 + 1) :=
  @prod_antidiagonal_succ' (Multiplicative N) _ _ _
#align finset.nat.sum_antidiagonal_succ' Finset.Nat.sum_antidiagonal_succ'
-/

#print Finset.Nat.prod_antidiagonal_subst /-
@[to_additive]
theorem prod_antidiagonal_subst {n : ℕ} {f : ℕ × ℕ → ℕ → M} :
    ∏ p in antidiagonal n, f p n = ∏ p in antidiagonal n, f p (p.1 + p.2) :=
  prod_congr rfl fun p hp => by rw [nat.mem_antidiagonal.1 hp]
#align finset.nat.prod_antidiagonal_subst Finset.Nat.prod_antidiagonal_subst
#align finset.nat.sum_antidiagonal_subst Finset.Nat.sum_antidiagonal_subst
-/

#print Finset.Nat.prod_antidiagonal_eq_prod_range_succ_mk /-
@[to_additive]
theorem prod_antidiagonal_eq_prod_range_succ_mk {M : Type _} [CommMonoid M] (f : ℕ × ℕ → M)
    (n : ℕ) : ∏ ij in Finset.Nat.antidiagonal n, f ij = ∏ k in range n.succ, f (k, n - k) :=
  by
  convert Prod_map _ ⟨fun i => (i, n - i), fun x y h => (Prod.mk.inj h).1⟩ _
  rfl
#align finset.nat.prod_antidiagonal_eq_prod_range_succ_mk Finset.Nat.prod_antidiagonal_eq_prod_range_succ_mk
#align finset.nat.sum_antidiagonal_eq_sum_range_succ_mk Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk
-/

#print Finset.Nat.prod_antidiagonal_eq_prod_range_succ /-
/-- This lemma matches more generally than `finset.nat.prod_antidiagonal_eq_prod_range_succ_mk` when
using `rw ←`. -/
@[to_additive
      "This lemma matches more generally than\n`finset.nat.sum_antidiagonal_eq_sum_range_succ_mk` when using `rw ←`."]
theorem prod_antidiagonal_eq_prod_range_succ {M : Type _} [CommMonoid M] (f : ℕ → ℕ → M) (n : ℕ) :
    ∏ ij in Finset.Nat.antidiagonal n, f ij.1 ij.2 = ∏ k in range n.succ, f k (n - k) :=
  prod_antidiagonal_eq_prod_range_succ_mk _ _
#align finset.nat.prod_antidiagonal_eq_prod_range_succ Finset.Nat.prod_antidiagonal_eq_prod_range_succ
#align finset.nat.sum_antidiagonal_eq_sum_range_succ Finset.Nat.sum_antidiagonal_eq_sum_range_succ
-/

end Nat

end Finset

