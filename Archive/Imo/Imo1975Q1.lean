/-
Copyright (c) 2022 Mantas Bakšys. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mantas Bakšys

! This file was ported from Lean 3 source module imo.imo1975_q1
! leanprover-community/mathlib commit 308826471968962c6b59c7ff82a22757386603e3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Real.Basic
import Mathbin.Data.Nat.Interval
import Mathbin.Algebra.Order.Rearrangement
import Mathbin.Algebra.BigOperators.Ring

/-!
# IMO 1975 Q1

Let `x₁, x₂, ... , xₙ` and `y₁, y₂, ... , yₙ` be two sequences of real numbers, such that
`x₁ ≥ x₂ ≥ ... ≥ xₙ` and `y₁ ≥ y₂ ≥ ... ≥ yₙ`. Prove that if `z₁, z₂, ... , zₙ` is any permutation
of `y₁, y₂, ... , yₙ`, then `∑ (xᵢ - yᵢ)^2 ≤ ∑ (xᵢ - zᵢ)^2`

# Solution

Firstly, we expand the squares withing both sums and distribute into separate finite sums. Then,
noting that `∑ yᵢ ^ 2 = ∑ zᵢ ^ 2`, it remains to prove that `∑ xᵢ * zᵢ ≤ ∑ xᵢ * yᵢ`, which is true
by the Rearrangement Inequality
-/


open scoped BigOperators

/- Let `n` be a natural number, `x` and `y` be as in the problem statement and `σ` be the
permutation of natural numbers such that `z = y ∘ σ` -/
variable (n : ℕ) (σ : Equiv.Perm ℕ) (hσ : {x | σ x ≠ x} ⊆ Finset.Icc 1 n) (x y : ℕ → ℝ)

variable (hx : AntitoneOn x (Finset.Icc 1 n))

variable (hy : AntitoneOn y (Finset.Icc 1 n))

theorem imo1975_q1 :
    ∑ i in Finset.Icc 1 n, (x i - y i) ^ 2 ≤ ∑ i in Finset.Icc 1 n, (x i - y (σ i)) ^ 2 :=
  by
  simp only [sub_sq, Finset.sum_add_distrib, Finset.sum_sub_distrib]
  -- a finite sum is invariant if we permute the order of summation
  have hσy : ∑ i : ℕ in Finset.Icc 1 n, y i ^ 2 = ∑ i : ℕ in Finset.Icc 1 n, y (σ i) ^ 2 := by
    rw [← Equiv.Perm.sum_comp σ (Finset.Icc 1 n) _ hσ]
  -- let's cancel terms appearing on both sides
  norm_num [hσy, mul_assoc, ← Finset.mul_sum]
  -- what's left to prove is a version of the rearrangement inequality
  apply MonovaryOn.sum_mul_comp_perm_le_sum_mul _ hσ
  -- finally we need to show that `x` and `y` 'vary' together on `[1, n]` and this is due to both of
  -- them being `decreasing`
  exact AntitoneOn.monovaryOn hx hy
#align imo1975_q1 imo1975_q1

