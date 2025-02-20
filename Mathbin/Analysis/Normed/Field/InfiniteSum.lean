/-
Copyright (c) 2021 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker

! This file was ported from Lean 3 source module analysis.normed.field.infinite_sum
! leanprover-community/mathlib commit 10bf4f825ad729c5653adc039dafa3622e7f93c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Normed.Field.Basic
import Mathbin.Analysis.Normed.Group.InfiniteSum

/-! # Multiplying two infinite sums in a normed ring

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we prove various results about `(∑' x : ι, f x) * (∑' y : ι', g y)` in a normed
ring. There are similar results proven in `topology/algebra/infinite_sum` (e.g `tsum_mul_tsum`),
but in a normed ring we get summability results which aren't true in general.

We first establish results about arbitrary index types, `β` and `γ`, and then we specialize to
`β = γ = ℕ` to prove the Cauchy product formula
(see `tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm`).
!-/


variable {α : Type _} {ι : Type _} {ι' : Type _} [NormedRing α]

open scoped BigOperators Classical

open Finset

/-! ### Arbitrary index types -/


/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Summable.mul_of_nonneg /-
theorem Summable.mul_of_nonneg {f : ι → ℝ} {g : ι' → ℝ} (hf : Summable f) (hg : Summable g)
    (hf' : 0 ≤ f) (hg' : 0 ≤ g) : Summable fun x : ι × ι' => f x.1 * g x.2 :=
  let ⟨s, hf⟩ := hf
  let ⟨t, hg⟩ := hg
  suffices this (∀ u : Finset (ι × ι'), ∑ x in u, f x.1 * g x.2 ≤ s * t) from
    summable_of_sum_le (fun x => mul_nonneg (hf' _) (hg' _)) this
  fun u =>
  calc
    ∑ x in u, f x.1 * g x.2 ≤ ∑ x in u.image Prod.fst ×ˢ u.image Prod.snd, f x.1 * g x.2 :=
      sum_mono_set_of_nonneg (fun x => mul_nonneg (hf' _) (hg' _)) subset_product
    _ = ∑ x in u.image Prod.fst, ∑ y in u.image Prod.snd, f x * g y := sum_product
    _ = ∑ x in u.image Prod.fst, f x * ∑ y in u.image Prod.snd, g y :=
      (sum_congr rfl fun x _ => mul_sum.symm)
    _ ≤ ∑ x in u.image Prod.fst, f x * t :=
      (sum_le_sum fun x _ =>
        mul_le_mul_of_nonneg_left (sum_le_hasSum _ (fun _ _ => hg' _) hg) (hf' _))
    _ = (∑ x in u.image Prod.fst, f x) * t := sum_mul.symm
    _ ≤ s * t :=
      mul_le_mul_of_nonneg_right (sum_le_hasSum _ (fun _ _ => hf' _) hf) (hg.NonNeg fun _ => hg' _)
#align summable.mul_of_nonneg Summable.mul_of_nonneg
-/

#print Summable.mul_norm /-
theorem Summable.mul_norm {f : ι → α} {g : ι' → α} (hf : Summable fun x => ‖f x‖)
    (hg : Summable fun x => ‖g x‖) : Summable fun x : ι × ι' => ‖f x.1 * g x.2‖ :=
  summable_of_nonneg_of_le (fun x => norm_nonneg (f x.1 * g x.2))
    (fun x => norm_mul_le (f x.1) (g x.2))
    (hf.mul_of_nonneg hg (fun x => norm_nonneg <| f x) fun x => norm_nonneg <| g x : _)
#align summable.mul_norm Summable.mul_norm
-/

#print summable_mul_of_summable_norm /-
theorem summable_mul_of_summable_norm [CompleteSpace α] {f : ι → α} {g : ι' → α}
    (hf : Summable fun x => ‖f x‖) (hg : Summable fun x => ‖g x‖) :
    Summable fun x : ι × ι' => f x.1 * g x.2 :=
  summable_of_summable_norm (hf.mul_norm hg)
#align summable_mul_of_summable_norm summable_mul_of_summable_norm
-/

#print tsum_mul_tsum_of_summable_norm /-
/-- Product of two infinites sums indexed by arbitrary types.
    See also `tsum_mul_tsum` if `f` and `g` are *not* absolutely summable. -/
theorem tsum_mul_tsum_of_summable_norm [CompleteSpace α] {f : ι → α} {g : ι' → α}
    (hf : Summable fun x => ‖f x‖) (hg : Summable fun x => ‖g x‖) :
    (∑' x, f x) * ∑' y, g y = ∑' z : ι × ι', f z.1 * g z.2 :=
  tsum_mul_tsum (summable_of_summable_norm hf) (summable_of_summable_norm hg)
    (summable_mul_of_summable_norm hf hg)
#align tsum_mul_tsum_of_summable_norm tsum_mul_tsum_of_summable_norm
-/

/-! ### `ℕ`-indexed families (Cauchy product)

We prove two versions of the Cauchy product formula. The first one is
`tsum_mul_tsum_eq_tsum_sum_range_of_summable_norm`, where the `n`-th term is a sum over
`finset.range (n+1)` involving `nat` subtraction.
In order to avoid `nat` subtraction, we also provide
`tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm`,
where the `n`-th term is a sum over all pairs `(k, l)` such that `k+l=n`, which corresponds to the
`finset` `finset.nat.antidiagonal n`. -/


section Nat

open Finset.Nat

#print summable_norm_sum_mul_antidiagonal_of_summable_norm /-
theorem summable_norm_sum_mul_antidiagonal_of_summable_norm {f g : ℕ → α}
    (hf : Summable fun x => ‖f x‖) (hg : Summable fun x => ‖g x‖) :
    Summable fun n => ‖∑ kl in antidiagonal n, f kl.1 * g kl.2‖ :=
  by
  have :=
    summable_sum_mul_antidiagonal_of_summable_mul
      (Summable.mul_of_nonneg hf hg (fun _ => norm_nonneg _) fun _ => norm_nonneg _)
  refine' summable_of_nonneg_of_le (fun _ => norm_nonneg _) _ this
  intro n
  calc
    ‖∑ kl in antidiagonal n, f kl.1 * g kl.2‖ ≤ ∑ kl in antidiagonal n, ‖f kl.1 * g kl.2‖ :=
      norm_sum_le _ _
    _ ≤ ∑ kl in antidiagonal n, ‖f kl.1‖ * ‖g kl.2‖ := sum_le_sum fun i _ => norm_mul_le _ _
#align summable_norm_sum_mul_antidiagonal_of_summable_norm summable_norm_sum_mul_antidiagonal_of_summable_norm
-/

#print tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm /-
/-- The Cauchy product formula for the product of two infinite sums indexed by `ℕ`,
    expressed by summing on `finset.nat.antidiagonal`.
    See also `tsum_mul_tsum_eq_tsum_sum_antidiagonal` if `f` and `g` are
    *not* absolutely summable. -/
theorem tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm [CompleteSpace α] {f g : ℕ → α}
    (hf : Summable fun x => ‖f x‖) (hg : Summable fun x => ‖g x‖) :
    (∑' n, f n) * ∑' n, g n = ∑' n, ∑ kl in antidiagonal n, f kl.1 * g kl.2 :=
  tsum_mul_tsum_eq_tsum_sum_antidiagonal (summable_of_summable_norm hf)
    (summable_of_summable_norm hg) (summable_mul_of_summable_norm hf hg)
#align tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm
-/

#print summable_norm_sum_mul_range_of_summable_norm /-
theorem summable_norm_sum_mul_range_of_summable_norm {f g : ℕ → α} (hf : Summable fun x => ‖f x‖)
    (hg : Summable fun x => ‖g x‖) : Summable fun n => ‖∑ k in range (n + 1), f k * g (n - k)‖ :=
  by
  simp_rw [← sum_antidiagonal_eq_sum_range_succ fun k l => f k * g l]
  exact summable_norm_sum_mul_antidiagonal_of_summable_norm hf hg
#align summable_norm_sum_mul_range_of_summable_norm summable_norm_sum_mul_range_of_summable_norm
-/

#print tsum_mul_tsum_eq_tsum_sum_range_of_summable_norm /-
/-- The Cauchy product formula for the product of two infinite sums indexed by `ℕ`,
    expressed by summing on `finset.range`.
    See also `tsum_mul_tsum_eq_tsum_sum_range` if `f` and `g` are
    *not* absolutely summable. -/
theorem tsum_mul_tsum_eq_tsum_sum_range_of_summable_norm [CompleteSpace α] {f g : ℕ → α}
    (hf : Summable fun x => ‖f x‖) (hg : Summable fun x => ‖g x‖) :
    (∑' n, f n) * ∑' n, g n = ∑' n, ∑ k in range (n + 1), f k * g (n - k) :=
  by
  simp_rw [← sum_antidiagonal_eq_sum_range_succ fun k l => f k * g l]
  exact tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm hf hg
#align tsum_mul_tsum_eq_tsum_sum_range_of_summable_norm tsum_mul_tsum_eq_tsum_sum_range_of_summable_norm
-/

end Nat

