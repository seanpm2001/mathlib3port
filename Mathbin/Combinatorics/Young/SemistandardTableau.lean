/-
Copyright (c) 2022 Jake Levinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jake Levinson

! This file was ported from Lean 3 source module combinatorics.young.semistandard_tableau
! leanprover-community/mathlib commit 50832daea47b195a48b5b33b1c8b2162c48c3afc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Combinatorics.Young.YoungDiagram

/-!
# Semistandard Young tableaux

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A semistandard Young tableau is a filling of a Young diagram by natural numbers, such that
the entries are weakly increasing left-to-right along rows (i.e. for fixed `i`), and
strictly-increasing top-to-bottom along columns (i.e. for fixed `j`).

An example of an SSYT of shape `μ = [4, 2, 1]` is:

```text
0 0 0 2
1 1
2
```

We represent an SSYT as a function `ℕ → ℕ → ℕ`, which is required to be zero for all pairs
`(i, j) ∉ μ` and to satisfy the row-weak and column-strict conditions on `μ`.


## Main definitions

- `ssyt (μ : young_diagram)` : semistandard Young tableaux of shape `μ`. There is
  a `has_coe_to_fun` instance such that `T i j` is value of the `(i, j)` entry of the SSYT `T`.
- `ssyt.highest_weight (μ : young_diagram)`: the semistandard Young tableau whose `i`th row
  consists entirely of `i`s, for each `i`.

## Tags

Semistandard Young tableau

## References

<https://en.wikipedia.org/wiki/Young_tableau>

-/


#print Ssyt /-
/-- A semistandard Young tableau (SSYT) is a filling of the cells of a Young diagram by natural
numbers, such that the entries in each row are weakly increasing (left to right), and the entries
in each column are strictly increasing (top to bottom).

Here, an SSYT is represented as an unrestricted function `ℕ → ℕ → ℕ` that, for reasons
of extensionality, is required to vanish outside `μ`. -/
structure Ssyt (μ : YoungDiagram) where
  entry : ℕ → ℕ → ℕ
  row_weak' : ∀ {i j1 j2 : ℕ}, j1 < j2 → (i, j2) ∈ μ → entry i j1 ≤ entry i j2
  col_strict' : ∀ {i1 i2 j : ℕ}, i1 < i2 → (i2, j) ∈ μ → entry i1 j < entry i2 j
  zeros' : ∀ {i j}, (i, j) ∉ μ → entry i j = 0
#align ssyt Ssyt
-/

namespace Ssyt

#print Ssyt.funLike /-
instance funLike {μ : YoungDiagram} : FunLike (Ssyt μ) ℕ fun _ => ℕ → ℕ
    where
  coe := Ssyt.entry
  coe_injective' T T' h := by cases T; cases T'; congr
#align ssyt.fun_like Ssyt.funLike
-/

/-- Helper instance for when there's too many metavariables to apply
`fun_like.has_coe_to_fun` directly. -/
instance {μ : YoungDiagram} : CoeFun (Ssyt μ) fun _ => ℕ → ℕ → ℕ :=
  FunLike.hasCoeToFun

#print Ssyt.to_fun_eq_coe /-
@[simp]
theorem to_fun_eq_coe {μ : YoungDiagram} {T : Ssyt μ} : T.entry = (T : ℕ → ℕ → ℕ) :=
  rfl
#align ssyt.to_fun_eq_coe Ssyt.to_fun_eq_coe
-/

#print Ssyt.ext /-
@[ext]
theorem ext {μ : YoungDiagram} {T T' : Ssyt μ} (h : ∀ i j, T i j = T' i j) : T = T' :=
  FunLike.ext T T' fun x => by funext; apply h
#align ssyt.ext Ssyt.ext
-/

#print Ssyt.copy /-
/-- Copy of an `ssyt μ` with a new `entry` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy {μ : YoungDiagram} (T : Ssyt μ) (entry' : ℕ → ℕ → ℕ) (h : entry' = T) : Ssyt μ
    where
  entry := entry'
  row_weak' _ _ _ := h.symm ▸ T.row_weak'
  col_strict' _ _ _ := h.symm ▸ T.col_strict'
  zeros' _ _ := h.symm ▸ T.zeros'
#align ssyt.copy Ssyt.copy
-/

#print Ssyt.coe_copy /-
@[simp]
theorem coe_copy {μ : YoungDiagram} (T : Ssyt μ) (entry' : ℕ → ℕ → ℕ) (h : entry' = T) :
    ⇑(T.copy entry' h) = entry' :=
  rfl
#align ssyt.coe_copy Ssyt.coe_copy
-/

#print Ssyt.copy_eq /-
theorem copy_eq {μ : YoungDiagram} (T : Ssyt μ) (entry' : ℕ → ℕ → ℕ) (h : entry' = T) :
    T.copy entry' h = T :=
  FunLike.ext' h
#align ssyt.copy_eq Ssyt.copy_eq
-/

#print Ssyt.row_weak /-
theorem row_weak {μ : YoungDiagram} (T : Ssyt μ) {i j1 j2 : ℕ} (hj : j1 < j2)
    (hcell : (i, j2) ∈ μ) : T i j1 ≤ T i j2 :=
  T.row_weak' hj hcell
#align ssyt.row_weak Ssyt.row_weak
-/

#print Ssyt.col_strict /-
theorem col_strict {μ : YoungDiagram} (T : Ssyt μ) {i1 i2 j : ℕ} (hi : i1 < i2)
    (hcell : (i2, j) ∈ μ) : T i1 j < T i2 j :=
  T.col_strict' hi hcell
#align ssyt.col_strict Ssyt.col_strict
-/

#print Ssyt.zeros /-
theorem zeros {μ : YoungDiagram} (T : Ssyt μ) {i j : ℕ} (not_cell : (i, j) ∉ μ) : T i j = 0 :=
  T.zeros' not_cell
#align ssyt.zeros Ssyt.zeros
-/

#print Ssyt.row_weak_of_le /-
theorem row_weak_of_le {μ : YoungDiagram} (T : Ssyt μ) {i j1 j2 : ℕ} (hj : j1 ≤ j2)
    (cell : (i, j2) ∈ μ) : T i j1 ≤ T i j2 := by cases eq_or_lt_of_le hj; subst h;
  exact T.row_weak h cell
#align ssyt.row_weak_of_le Ssyt.row_weak_of_le
-/

#print Ssyt.col_weak /-
theorem col_weak {μ : YoungDiagram} (T : Ssyt μ) {i1 i2 j : ℕ} (hi : i1 ≤ i2) (cell : (i2, j) ∈ μ) :
    T i1 j ≤ T i2 j := by cases eq_or_lt_of_le hi; subst h; exact le_of_lt (T.col_strict h cell)
#align ssyt.col_weak Ssyt.col_weak
-/

#print Ssyt.highestWeight /-
/-- The "highest weight" SSYT of a given shape is has all i's in row i, for each i. -/
def highestWeight (μ : YoungDiagram) : Ssyt μ
    where
  entry i j := if (i, j) ∈ μ then i else 0
  row_weak' i j1 j2 hj hcell := by
    rw [if_pos hcell, if_pos (μ.up_left_mem (by rfl) (le_of_lt hj) hcell)]
  col_strict' i1 i2 j hi hcell := by
    rwa [if_pos hcell, if_pos (μ.up_left_mem (le_of_lt hi) (by rfl) hcell)]
  zeros' i j not_cell := if_neg not_cell
#align ssyt.highest_weight Ssyt.highestWeight
-/

#print Ssyt.highestWeight_apply /-
@[simp]
theorem highestWeight_apply {μ : YoungDiagram} {i j : ℕ} :
    highestWeight μ i j = if (i, j) ∈ μ then i else 0 :=
  rfl
#align ssyt.highest_weight_apply Ssyt.highestWeight_apply
-/

instance {μ : YoungDiagram} : Inhabited (Ssyt μ) :=
  ⟨Ssyt.highestWeight μ⟩

end Ssyt

