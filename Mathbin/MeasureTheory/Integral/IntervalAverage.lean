/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module measure_theory.integral.interval_average
! leanprover-community/mathlib commit 7e5137f579de09a059a5ce98f364a04e221aabf0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Integral.IntervalIntegral
import Mathbin.MeasureTheory.Integral.Average

/-!
# Integral average over an interval

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we introduce notation `⨍ x in a..b, f x` for the average `⨍ x in Ι a b, f x` of `f`
over the interval `Ι a b = set.Ioc (min a b) (max a b)` w.r.t. the Lebesgue measure, then prove
formulas for this average:

* `interval_average_eq`: `⨍ x in a..b, f x = (b - a)⁻¹ • ∫ x in a..b, f x`;
* `interval_average_eq_div`: `⨍ x in a..b, f x = (∫ x in a..b, f x) / (b - a)`.

We also prove that `⨍ x in a..b, f x = ⨍ x in b..a, f x`, see `interval_average_symm`.

## Notation

`⨍ x in a..b, f x`: average of `f` over the interval `Ι a b` w.r.t. the Lebesgue measure.

-/


open MeasureTheory Set TopologicalSpace

open scoped Interval

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]

notation3"⨍ "(...)" in "a".."b", "r:60:(scoped f => average Measure.restrict volume Ι a b f) => r

#print interval_average_symm /-
theorem interval_average_symm (f : ℝ → E) (a b : ℝ) : ⨍ x in a..b, f x = ⨍ x in b..a, f x := by
  rw [set_average_eq, set_average_eq, uIoc_swap]
#align interval_average_symm interval_average_symm
-/

#print interval_average_eq /-
theorem interval_average_eq (f : ℝ → E) (a b : ℝ) :
    ⨍ x in a..b, f x = (b - a)⁻¹ • ∫ x in a..b, f x :=
  by
  cases' le_or_lt a b with h h
  ·
    rw [set_average_eq, uIoc_of_le h, Real.volume_Ioc, intervalIntegral.integral_of_le h,
      ENNReal.toReal_ofReal (sub_nonneg.2 h)]
  ·
    rw [set_average_eq, uIoc_of_lt h, Real.volume_Ioc, intervalIntegral.integral_of_ge h.le,
      ENNReal.toReal_ofReal (sub_nonneg.2 h.le), smul_neg, ← neg_smul, ← inv_neg, neg_sub]
#align interval_average_eq interval_average_eq
-/

#print interval_average_eq_div /-
theorem interval_average_eq_div (f : ℝ → ℝ) (a b : ℝ) :
    ⨍ x in a..b, f x = (∫ x in a..b, f x) / (b - a) := by
  rw [interval_average_eq, smul_eq_mul, div_eq_inv_mul]
#align interval_average_eq_div interval_average_eq_div
-/

