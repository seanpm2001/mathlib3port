/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module number_theory.liouville.measure
! leanprover-community/mathlib commit 36938f775671ff28bea1c0310f1608e4afbb22e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.Lebesgue.Basic
import Mathbin.NumberTheory.Liouville.Residual
import Mathbin.NumberTheory.Liouville.LiouvilleWith
import Mathbin.Analysis.PSeries

/-!
# Volume of the set of Liouville numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that the set of Liouville numbers with exponent (irrationality measure)
strictly greater than two is a set of Lebesuge measure zero, see
`volume_Union_set_of_liouville_with`.

Since this set is a residual set, we show that the filters `residual` and `volume.ae` are disjoint.
These filters correspond to two common notions of genericity on `ℝ`: residual sets and sets of full
measure. The fact that the filters are disjoint means that two mutually exclusive properties can be
“generic” at the same time (in the sense of different “genericity” filters).

## Tags

Liouville number, Lebesgue measure, residual, generic property
-/


open scoped Filter BigOperators ENNReal Topology NNReal

open Filter Set Metric MeasureTheory Real

#print setOf_liouvilleWith_subset_aux /-
theorem setOf_liouvilleWith_subset_aux :
    {x : ℝ | ∃ p > 2, LiouvilleWith p x} ⊆
      ⋃ m : ℤ,
        (fun x : ℝ => x + m) ⁻¹'
          ⋃ n > (0 : ℕ),
            {x : ℝ |
              ∃ᶠ b : ℕ in atTop,
                ∃ a ∈ Finset.Icc (0 : ℤ) b, |x - (a : ℤ) / b| < 1 / b ^ (2 + 1 / n : ℝ)} :=
  by
  rintro x ⟨p, hp, hxp⟩
  rcases exists_nat_one_div_lt (sub_pos.2 hp) with ⟨n, hn⟩
  rw [lt_sub_iff_add_lt'] at hn 
  suffices
    ∀ y : ℝ,
      LiouvilleWith p y →
        y ∈ Ico (0 : ℝ) 1 →
          ∃ᶠ b : ℕ in at_top,
            ∃ a ∈ Finset.Icc (0 : ℤ) b, |y - a / b| < 1 / b ^ (2 + 1 / (n + 1 : ℕ) : ℝ)
    by
    simp only [mem_Union, mem_preimage]
    have hx : x + ↑(-⌊x⌋) ∈ Ico (0 : ℝ) 1 := by
      simp only [Int.floor_le, Int.lt_floor_add_one, add_neg_lt_iff_le_add', zero_add, and_self_iff,
        mem_Ico, Int.cast_neg, le_add_neg_iff_add_le]
    refine' ⟨-⌊x⌋, n + 1, n.succ_pos, this _ (hxp.add_int _) hx⟩
  clear hxp x; intro x hxp hx01
  refine' ((hxp.frequently_lt_rpow_neg hn).and_eventually (eventually_ge_at_top 1)).mono _
  rintro b ⟨⟨a, hne, hlt⟩, hb⟩
  rw [rpow_neg b.cast_nonneg, ← one_div, ← Nat.cast_succ] at hlt 
  refine' ⟨a, _, hlt⟩
  replace hb : (1 : ℝ) ≤ b; exact Nat.one_le_cast.2 hb
  have hb0 : (0 : ℝ) < b := zero_lt_one.trans_le hb
  replace hlt : |x - a / b| < 1 / b
  · refine' hlt.trans_le (one_div_le_one_div_of_le hb0 _)
    calc
      (b : ℝ) = b ^ (1 : ℝ) := (rpow_one _).symm
      _ ≤ b ^ (2 + 1 / (n + 1 : ℕ) : ℝ) := rpow_le_rpow_of_exponent_le hb (one_le_two.trans _)
    simpa using n.cast_add_one_pos.le
  rw [sub_div' _ _ _ hb0.ne', abs_div, abs_of_pos hb0, div_lt_div_right hb0, abs_sub_lt_iff,
    sub_lt_iff_lt_add, sub_lt_iff_lt_add, ← sub_lt_iff_lt_add'] at hlt 
  rw [Finset.mem_Icc, ← Int.lt_add_one_iff, ← Int.lt_add_one_iff, ← neg_lt_iff_pos_add, add_comm, ←
    @Int.cast_lt ℝ, ← @Int.cast_lt ℝ]
  push_cast
  refine' ⟨lt_of_le_of_lt _ hlt.1, hlt.2.trans_le _⟩
  · simp only [mul_nonneg hx01.left b.cast_nonneg, neg_le_sub_iff_le_add, le_add_iff_nonneg_left]
  · rw [add_le_add_iff_left]
    calc
      x * b ≤ 1 * b := mul_le_mul_of_nonneg_right hx01.2.le hb0.le
      _ = b := one_mul b
#align set_of_liouville_with_subset_aux setOf_liouvilleWith_subset_aux
-/

#print volume_iUnion_setOf_liouvilleWith /-
/-- The set of numbers satisfying the Liouville condition with some exponent `p > 2` has Lebesgue
measure zero. -/
@[simp]
theorem volume_iUnion_setOf_liouvilleWith :
    volume (⋃ (p : ℝ) (hp : 2 < p), {x : ℝ | LiouvilleWith p x}) = 0 :=
  by
  simp only [← set_of_exists]
  refine' measure_mono_null setOf_liouvilleWith_subset_aux _
  rw [measure_Union_null_iff]; intro m; rw [measure_preimage_add_right]; clear m
  refine' (measure_bUnion_null_iff <| to_countable _).2 fun n (hn : 1 ≤ n) => _
  generalize hr : (2 + 1 / n : ℝ) = r
  replace hr : 2 < r; · simp [← hr, zero_lt_one.trans_le hn]; clear hn n
  refine' measure_set_of_frequently_eq_zero _
  simp only [set_of_exists, ← Real.dist_eq, ← mem_ball, set_of_mem_eq]
  set B : ℤ → ℕ → Set ℝ := fun a b => ball (a / b) (1 / b ^ r)
  have hB : ∀ a b, volume (B a b) = ↑(2 / b ^ r : ℝ≥0) :=
    by
    intro a b
    rw [Real.volume_ball, mul_one_div, ← NNReal.coe_two, ← NNReal.coe_nat_cast, ← NNReal.coe_rpow, ←
      NNReal.coe_div, ENNReal.ofReal_coe_nnreal]
  have :
    ∀ b : ℕ, volume (⋃ a ∈ Finset.Icc (0 : ℤ) b, B a b) ≤ (2 * (b ^ (1 - r) + b ^ (-r)) : ℝ≥0) :=
    by
    intro b
    calc
      volume (⋃ a ∈ Finset.Icc (0 : ℤ) b, B a b) ≤ ∑ a in Finset.Icc (0 : ℤ) b, volume (B a b) :=
        measure_bUnion_finset_le _ _
      _ = ((b + 1) * (2 / b ^ r) : ℝ≥0) := by
        simp only [hB, Int.card_Icc, Finset.sum_const, nsmul_eq_mul, sub_zero, ← Int.ofNat_succ,
          Int.toNat_coe_nat, ← Nat.cast_succ, ENNReal.coe_mul, ENNReal.coe_nat]
      _ = _ := _
    have : 1 - r ≠ 0 := by linarith
    rw [ENNReal.coe_eq_coe]
    simp [add_mul, div_eq_mul_inv, NNReal.rpow_neg, NNReal.rpow_sub' _ this, mul_add, mul_left_comm]
  refine' ne_top_of_le_ne_top (ENNReal.tsum_coe_ne_top_iff_summable.2 _) (ENNReal.tsum_le_tsum this)
  refine' (Summable.add _ _).mul_left _ <;> simp only [NNReal.summable_rpow] <;> linarith
#align volume_Union_set_of_liouville_with volume_iUnion_setOf_liouvilleWith
-/

#print ae_not_liouvilleWith /-
theorem ae_not_liouvilleWith : ∀ᵐ x, ∀ p > (2 : ℝ), ¬LiouvilleWith p x := by
  simpa only [ae_iff, not_forall, Classical.not_not, set_of_exists] using
    volume_iUnion_setOf_liouvilleWith
#align ae_not_liouville_with ae_not_liouvilleWith
-/

#print ae_not_liouville /-
theorem ae_not_liouville : ∀ᵐ x, ¬Liouville x :=
  ae_not_liouvilleWith.mono fun x h₁ h₂ => h₁ 3 (by norm_num) (h₂.LiouvilleWith 3)
#align ae_not_liouville ae_not_liouville
-/

#print volume_setOf_liouville /-
/-- The set of Liouville numbers has Lebesgue measure zero. -/
@[simp]
theorem volume_setOf_liouville : volume {x : ℝ | Liouville x} = 0 := by
  simpa only [ae_iff, Classical.not_not] using ae_not_liouville
#align volume_set_of_liouville volume_setOf_liouville
-/

#print Real.disjoint_residual_ae /-
/-- The filters `residual ℝ` and `volume.ae` are disjoint. This means that there exists a residual
set of Lebesgue measure zero (e.g., the set of Liouville numbers). -/
theorem Real.disjoint_residual_ae : Disjoint (residual ℝ) volume.ae :=
  disjoint_of_disjoint_of_mem disjoint_compl_right eventually_residual_liouville ae_not_liouville
#align real.disjoint_residual_ae Real.disjoint_residual_ae
-/

