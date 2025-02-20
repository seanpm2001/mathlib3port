/-
Copyright (c) 2019 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module data.list.nat_antidiagonal
! leanprover-community/mathlib commit f2f413b9d4be3a02840d0663dace76e8fe3da053
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.Nodup
import Mathbin.Data.List.Range

/-!
# Antidiagonals in ℕ × ℕ as lists

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the antidiagonals of ℕ × ℕ as lists: the `n`-th antidiagonal is the list of
pairs `(i, j)` such that `i + j = n`. This is useful for polynomial multiplication and more
generally for sums going from `0` to `n`.

## Notes

Files `data.multiset.nat_antidiagonal` and `data.finset.nat_antidiagonal` successively turn the
`list` definition we have here into `multiset` and `finset`.
-/


open List Function Nat

namespace List

namespace Nat

#print List.Nat.antidiagonal /-
/-- The antidiagonal of a natural number `n` is the list of pairs `(i, j)` such that `i + j = n`. -/
def antidiagonal (n : ℕ) : List (ℕ × ℕ) :=
  (range (n + 1)).map fun i => (i, n - i)
#align list.nat.antidiagonal List.Nat.antidiagonal
-/

#print List.Nat.mem_antidiagonal /-
/-- A pair (i, j) is contained in the antidiagonal of `n` if and only if `i + j = n`. -/
@[simp]
theorem mem_antidiagonal {n : ℕ} {x : ℕ × ℕ} : x ∈ antidiagonal n ↔ x.1 + x.2 = n :=
  by
  rw [antidiagonal, mem_map]; constructor
  · rintro ⟨i, hi, rfl⟩; rw [mem_range, lt_succ_iff] at hi ; exact add_tsub_cancel_of_le hi
  · rintro rfl; refine' ⟨x.fst, _, _⟩
    · rw [mem_range, add_assoc, lt_add_iff_pos_right]; exact zero_lt_succ _
    · exact Prod.ext rfl (add_tsub_cancel_left _ _)
#align list.nat.mem_antidiagonal List.Nat.mem_antidiagonal
-/

#print List.Nat.length_antidiagonal /-
/-- The length of the antidiagonal of `n` is `n + 1`. -/
@[simp]
theorem length_antidiagonal (n : ℕ) : (antidiagonal n).length = n + 1 := by
  rw [antidiagonal, length_map, length_range]
#align list.nat.length_antidiagonal List.Nat.length_antidiagonal
-/

#print List.Nat.antidiagonal_zero /-
/-- The antidiagonal of `0` is the list `[(0, 0)]` -/
@[simp]
theorem antidiagonal_zero : antidiagonal 0 = [(0, 0)] :=
  rfl
#align list.nat.antidiagonal_zero List.Nat.antidiagonal_zero
-/

#print List.Nat.nodup_antidiagonal /-
/-- The antidiagonal of `n` does not contain duplicate entries. -/
theorem nodup_antidiagonal (n : ℕ) : Nodup (antidiagonal n) :=
  (nodup_range _).map (@LeftInverse.injective ℕ (ℕ × ℕ) Prod.fst (fun i => (i, n - i)) fun i => rfl)
#align list.nat.nodup_antidiagonal List.Nat.nodup_antidiagonal
-/

#print List.Nat.antidiagonal_succ /-
@[simp]
theorem antidiagonal_succ {n : ℕ} :
    antidiagonal (n + 1) = (0, n + 1) :: (antidiagonal n).map (Prod.map Nat.succ id) :=
  by
  simp only [antidiagonal, range_succ_eq_map, map_cons, true_and_iff, Nat.add_succ_sub_one,
    add_zero, id.def, eq_self_iff_true, tsub_zero, map_map, Prod.map_mk]
  apply congr (congr rfl _) rfl
  ext <;> simp
#align list.nat.antidiagonal_succ List.Nat.antidiagonal_succ
-/

#print List.Nat.antidiagonal_succ' /-
theorem antidiagonal_succ' {n : ℕ} :
    antidiagonal (n + 1) = (antidiagonal n).map (Prod.map id Nat.succ) ++ [(n + 1, 0)] :=
  by
  simp only [antidiagonal, range_succ, add_tsub_cancel_left, map_append, append_assoc, tsub_self,
    singleton_append, map_map, map]
  congr 1
  apply map_congr
  simp (config := { contextual := true }) [le_of_lt, Nat.succ_eq_add_one, Nat.sub_add_comm]
#align list.nat.antidiagonal_succ' List.Nat.antidiagonal_succ'
-/

#print List.Nat.antidiagonal_succ_succ' /-
theorem antidiagonal_succ_succ' {n : ℕ} :
    antidiagonal (n + 2) =
      (0, n + 2) :: (antidiagonal n).map (Prod.map Nat.succ Nat.succ) ++ [(n + 2, 0)] :=
  by rw [antidiagonal_succ']; simpa
#align list.nat.antidiagonal_succ_succ' List.Nat.antidiagonal_succ_succ'
-/

#print List.Nat.map_swap_antidiagonal /-
theorem map_swap_antidiagonal {n : ℕ} : (antidiagonal n).map Prod.swap = (antidiagonal n).reverse :=
  by
  rw [antidiagonal, map_map, Prod.swap, ← List.map_reverse, range_eq_range', reverse_range', ←
    range_eq_range', map_map]
  apply map_congr
  simp (config := { contextual := true }) [Nat.sub_sub_self, lt_succ_iff]
#align list.nat.map_swap_antidiagonal List.Nat.map_swap_antidiagonal
-/

end Nat

end List

