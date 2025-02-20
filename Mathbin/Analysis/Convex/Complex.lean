/-
Copyright (c) 2019 Yury Kudriashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudriashov, Yaël Dillies

! This file was ported from Lean 3 source module analysis.convex.complex
! leanprover-community/mathlib commit fe8d0ff42c3c24d789f491dc2622b6cac3d61564
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Basic
import Mathbin.Data.Complex.Module

/-!
# Convexity of half spaces in ℂ

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The open and closed half-spaces in ℂ given by an inequality on either the real or imaginary part
are all convex over ℝ.
-/


#print convex_halfspace_re_lt /-
theorem convex_halfspace_re_lt (r : ℝ) : Convex ℝ {c : ℂ | c.re < r} :=
  convex_halfspace_lt (IsLinearMap.mk Complex.add_re Complex.smul_re) _
#align convex_halfspace_re_lt convex_halfspace_re_lt
-/

#print convex_halfspace_re_le /-
theorem convex_halfspace_re_le (r : ℝ) : Convex ℝ {c : ℂ | c.re ≤ r} :=
  convex_halfspace_le (IsLinearMap.mk Complex.add_re Complex.smul_re) _
#align convex_halfspace_re_le convex_halfspace_re_le
-/

#print convex_halfspace_re_gt /-
theorem convex_halfspace_re_gt (r : ℝ) : Convex ℝ {c : ℂ | r < c.re} :=
  convex_halfspace_gt (IsLinearMap.mk Complex.add_re Complex.smul_re) _
#align convex_halfspace_re_gt convex_halfspace_re_gt
-/

#print convex_halfspace_re_ge /-
theorem convex_halfspace_re_ge (r : ℝ) : Convex ℝ {c : ℂ | r ≤ c.re} :=
  convex_halfspace_ge (IsLinearMap.mk Complex.add_re Complex.smul_re) _
#align convex_halfspace_re_ge convex_halfspace_re_ge
-/

#print convex_halfspace_im_lt /-
theorem convex_halfspace_im_lt (r : ℝ) : Convex ℝ {c : ℂ | c.im < r} :=
  convex_halfspace_lt (IsLinearMap.mk Complex.add_im Complex.smul_im) _
#align convex_halfspace_im_lt convex_halfspace_im_lt
-/

#print convex_halfspace_im_le /-
theorem convex_halfspace_im_le (r : ℝ) : Convex ℝ {c : ℂ | c.im ≤ r} :=
  convex_halfspace_le (IsLinearMap.mk Complex.add_im Complex.smul_im) _
#align convex_halfspace_im_le convex_halfspace_im_le
-/

#print convex_halfspace_im_gt /-
theorem convex_halfspace_im_gt (r : ℝ) : Convex ℝ {c : ℂ | r < c.im} :=
  convex_halfspace_gt (IsLinearMap.mk Complex.add_im Complex.smul_im) _
#align convex_halfspace_im_gt convex_halfspace_im_gt
-/

#print convex_halfspace_im_ge /-
theorem convex_halfspace_im_ge (r : ℝ) : Convex ℝ {c : ℂ | r ≤ c.im} :=
  convex_halfspace_ge (IsLinearMap.mk Complex.add_im Complex.smul_im) _
#align convex_halfspace_im_ge convex_halfspace_im_ge
-/

