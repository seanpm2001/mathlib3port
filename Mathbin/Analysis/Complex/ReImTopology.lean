/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.complex.re_im_topology
! leanprover-community/mathlib commit 2ed2c6310e6f1c5562bdf6bfbda55ebbf6891abe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Complex.Basic
import Mathbin.Topology.FiberBundle.IsHomeomorphicTrivialBundle

/-!
# Closure, interior, and frontier of preimages under `re` and `im`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this fact we use the fact that `ℂ` is naturally homeomorphic to `ℝ × ℝ` to deduce some
topological properties of `complex.re` and `complex.im`.

## Main statements

Each statement about `complex.re` listed below has a counterpart about `complex.im`.

* `complex.is_homeomorphic_trivial_fiber_bundle_re`: `complex.re` turns `ℂ` into a trivial
  topological fiber bundle over `ℝ`;
* `complex.is_open_map_re`, `complex.quotient_map_re`: in particular, `complex.re` is an open map
  and is a quotient map;
* `complex.interior_preimage_re`, `complex.closure_preimage_re`, `complex.frontier_preimage_re`:
  formulas for `interior (complex.re ⁻¹' s)` etc;
* `complex.interior_set_of_re_le` etc: particular cases of the above formulas in the cases when `s`
  is one of the infinite intervals `set.Ioi a`, `set.Ici a`, `set.Iio a`, and `set.Iic a`,
  formulated as `interior {z : ℂ | z.re ≤ a} = {z | z.re < a}` etc.

## Tags

complex, real part, imaginary part, closure, interior, frontier
-/


open Set

noncomputable section

namespace Complex

#print Complex.isHomeomorphicTrivialFiberBundle_re /-
/-- `complex.re` turns `ℂ` into a trivial topological fiber bundle over `ℝ`. -/
theorem isHomeomorphicTrivialFiberBundle_re : IsHomeomorphicTrivialFiberBundle ℝ re :=
  ⟨equivRealProdClm.toHomeomorph, fun z => rfl⟩
#align complex.is_homeomorphic_trivial_fiber_bundle_re Complex.isHomeomorphicTrivialFiberBundle_re
-/

#print Complex.isHomeomorphicTrivialFiberBundle_im /-
/-- `complex.im` turns `ℂ` into a trivial topological fiber bundle over `ℝ`. -/
theorem isHomeomorphicTrivialFiberBundle_im : IsHomeomorphicTrivialFiberBundle ℝ im :=
  ⟨equivRealProdClm.toHomeomorph.trans (Homeomorph.prodComm ℝ ℝ), fun z => rfl⟩
#align complex.is_homeomorphic_trivial_fiber_bundle_im Complex.isHomeomorphicTrivialFiberBundle_im
-/

#print Complex.isOpenMap_re /-
theorem isOpenMap_re : IsOpenMap re :=
  isHomeomorphicTrivialFiberBundle_re.isOpenMap_proj
#align complex.is_open_map_re Complex.isOpenMap_re
-/

#print Complex.isOpenMap_im /-
theorem isOpenMap_im : IsOpenMap im :=
  isHomeomorphicTrivialFiberBundle_im.isOpenMap_proj
#align complex.is_open_map_im Complex.isOpenMap_im
-/

#print Complex.quotientMap_re /-
theorem quotientMap_re : QuotientMap re :=
  isHomeomorphicTrivialFiberBundle_re.quotientMap_proj
#align complex.quotient_map_re Complex.quotientMap_re
-/

#print Complex.quotientMap_im /-
theorem quotientMap_im : QuotientMap im :=
  isHomeomorphicTrivialFiberBundle_im.quotientMap_proj
#align complex.quotient_map_im Complex.quotientMap_im
-/

#print Complex.interior_preimage_re /-
theorem interior_preimage_re (s : Set ℝ) : interior (re ⁻¹' s) = re ⁻¹' interior s :=
  (isOpenMap_re.preimage_interior_eq_interior_preimage continuous_re _).symm
#align complex.interior_preimage_re Complex.interior_preimage_re
-/

#print Complex.interior_preimage_im /-
theorem interior_preimage_im (s : Set ℝ) : interior (im ⁻¹' s) = im ⁻¹' interior s :=
  (isOpenMap_im.preimage_interior_eq_interior_preimage continuous_im _).symm
#align complex.interior_preimage_im Complex.interior_preimage_im
-/

#print Complex.closure_preimage_re /-
theorem closure_preimage_re (s : Set ℝ) : closure (re ⁻¹' s) = re ⁻¹' closure s :=
  (isOpenMap_re.preimage_closure_eq_closure_preimage continuous_re _).symm
#align complex.closure_preimage_re Complex.closure_preimage_re
-/

#print Complex.closure_preimage_im /-
theorem closure_preimage_im (s : Set ℝ) : closure (im ⁻¹' s) = im ⁻¹' closure s :=
  (isOpenMap_im.preimage_closure_eq_closure_preimage continuous_im _).symm
#align complex.closure_preimage_im Complex.closure_preimage_im
-/

#print Complex.frontier_preimage_re /-
theorem frontier_preimage_re (s : Set ℝ) : frontier (re ⁻¹' s) = re ⁻¹' frontier s :=
  (isOpenMap_re.preimage_frontier_eq_frontier_preimage continuous_re _).symm
#align complex.frontier_preimage_re Complex.frontier_preimage_re
-/

#print Complex.frontier_preimage_im /-
theorem frontier_preimage_im (s : Set ℝ) : frontier (im ⁻¹' s) = im ⁻¹' frontier s :=
  (isOpenMap_im.preimage_frontier_eq_frontier_preimage continuous_im _).symm
#align complex.frontier_preimage_im Complex.frontier_preimage_im
-/

#print Complex.interior_setOf_re_le /-
@[simp]
theorem interior_setOf_re_le (a : ℝ) : interior {z : ℂ | z.re ≤ a} = {z | z.re < a} := by
  simpa only [interior_Iic] using interior_preimage_re (Iic a)
#align complex.interior_set_of_re_le Complex.interior_setOf_re_le
-/

#print Complex.interior_setOf_im_le /-
@[simp]
theorem interior_setOf_im_le (a : ℝ) : interior {z : ℂ | z.im ≤ a} = {z | z.im < a} := by
  simpa only [interior_Iic] using interior_preimage_im (Iic a)
#align complex.interior_set_of_im_le Complex.interior_setOf_im_le
-/

#print Complex.interior_setOf_le_re /-
@[simp]
theorem interior_setOf_le_re (a : ℝ) : interior {z : ℂ | a ≤ z.re} = {z | a < z.re} := by
  simpa only [interior_Ici] using interior_preimage_re (Ici a)
#align complex.interior_set_of_le_re Complex.interior_setOf_le_re
-/

#print Complex.interior_setOf_le_im /-
@[simp]
theorem interior_setOf_le_im (a : ℝ) : interior {z : ℂ | a ≤ z.im} = {z | a < z.im} := by
  simpa only [interior_Ici] using interior_preimage_im (Ici a)
#align complex.interior_set_of_le_im Complex.interior_setOf_le_im
-/

#print Complex.closure_setOf_re_lt /-
@[simp]
theorem closure_setOf_re_lt (a : ℝ) : closure {z : ℂ | z.re < a} = {z | z.re ≤ a} := by
  simpa only [closure_Iio] using closure_preimage_re (Iio a)
#align complex.closure_set_of_re_lt Complex.closure_setOf_re_lt
-/

#print Complex.closure_setOf_im_lt /-
@[simp]
theorem closure_setOf_im_lt (a : ℝ) : closure {z : ℂ | z.im < a} = {z | z.im ≤ a} := by
  simpa only [closure_Iio] using closure_preimage_im (Iio a)
#align complex.closure_set_of_im_lt Complex.closure_setOf_im_lt
-/

#print Complex.closure_setOf_lt_re /-
@[simp]
theorem closure_setOf_lt_re (a : ℝ) : closure {z : ℂ | a < z.re} = {z | a ≤ z.re} := by
  simpa only [closure_Ioi] using closure_preimage_re (Ioi a)
#align complex.closure_set_of_lt_re Complex.closure_setOf_lt_re
-/

#print Complex.closure_setOf_lt_im /-
@[simp]
theorem closure_setOf_lt_im (a : ℝ) : closure {z : ℂ | a < z.im} = {z | a ≤ z.im} := by
  simpa only [closure_Ioi] using closure_preimage_im (Ioi a)
#align complex.closure_set_of_lt_im Complex.closure_setOf_lt_im
-/

#print Complex.frontier_setOf_re_le /-
@[simp]
theorem frontier_setOf_re_le (a : ℝ) : frontier {z : ℂ | z.re ≤ a} = {z | z.re = a} := by
  simpa only [frontier_Iic] using frontier_preimage_re (Iic a)
#align complex.frontier_set_of_re_le Complex.frontier_setOf_re_le
-/

#print Complex.frontier_setOf_im_le /-
@[simp]
theorem frontier_setOf_im_le (a : ℝ) : frontier {z : ℂ | z.im ≤ a} = {z | z.im = a} := by
  simpa only [frontier_Iic] using frontier_preimage_im (Iic a)
#align complex.frontier_set_of_im_le Complex.frontier_setOf_im_le
-/

#print Complex.frontier_setOf_le_re /-
@[simp]
theorem frontier_setOf_le_re (a : ℝ) : frontier {z : ℂ | a ≤ z.re} = {z | z.re = a} := by
  simpa only [frontier_Ici] using frontier_preimage_re (Ici a)
#align complex.frontier_set_of_le_re Complex.frontier_setOf_le_re
-/

#print Complex.frontier_setOf_le_im /-
@[simp]
theorem frontier_setOf_le_im (a : ℝ) : frontier {z : ℂ | a ≤ z.im} = {z | z.im = a} := by
  simpa only [frontier_Ici] using frontier_preimage_im (Ici a)
#align complex.frontier_set_of_le_im Complex.frontier_setOf_le_im
-/

#print Complex.frontier_setOf_re_lt /-
@[simp]
theorem frontier_setOf_re_lt (a : ℝ) : frontier {z : ℂ | z.re < a} = {z | z.re = a} := by
  simpa only [frontier_Iio] using frontier_preimage_re (Iio a)
#align complex.frontier_set_of_re_lt Complex.frontier_setOf_re_lt
-/

#print Complex.frontier_setOf_im_lt /-
@[simp]
theorem frontier_setOf_im_lt (a : ℝ) : frontier {z : ℂ | z.im < a} = {z | z.im = a} := by
  simpa only [frontier_Iio] using frontier_preimage_im (Iio a)
#align complex.frontier_set_of_im_lt Complex.frontier_setOf_im_lt
-/

#print Complex.frontier_setOf_lt_re /-
@[simp]
theorem frontier_setOf_lt_re (a : ℝ) : frontier {z : ℂ | a < z.re} = {z | z.re = a} := by
  simpa only [frontier_Ioi] using frontier_preimage_re (Ioi a)
#align complex.frontier_set_of_lt_re Complex.frontier_setOf_lt_re
-/

#print Complex.frontier_setOf_lt_im /-
@[simp]
theorem frontier_setOf_lt_im (a : ℝ) : frontier {z : ℂ | a < z.im} = {z | z.im = a} := by
  simpa only [frontier_Ioi] using frontier_preimage_im (Ioi a)
#align complex.frontier_set_of_lt_im Complex.frontier_setOf_lt_im
-/

#print Complex.closure_reProdIm /-
theorem closure_reProdIm (s t : Set ℝ) : closure (s ×ℂ t) = closure s ×ℂ closure t := by
  simpa only [← preimage_eq_preimage equiv_real_prod_clm.symm.to_homeomorph.surjective,
    equiv_real_prod_clm.symm.to_homeomorph.preimage_closure] using @closure_prod_eq _ _ _ _ s t
#align complex.closure_re_prod_im Complex.closure_reProdIm
-/

#print Complex.interior_reProdIm /-
theorem interior_reProdIm (s t : Set ℝ) : interior (s ×ℂ t) = interior s ×ℂ interior t := by
  rw [re_prod_im, re_prod_im, interior_inter, interior_preimage_re, interior_preimage_im]
#align complex.interior_re_prod_im Complex.interior_reProdIm
-/

#print Complex.frontier_reProdIm /-
theorem frontier_reProdIm (s t : Set ℝ) :
    frontier (s ×ℂ t) = closure s ×ℂ frontier t ∪ frontier s ×ℂ closure t := by
  simpa only [← preimage_eq_preimage equiv_real_prod_clm.symm.to_homeomorph.surjective,
    equiv_real_prod_clm.symm.to_homeomorph.preimage_frontier] using frontier_prod_eq s t
#align complex.frontier_re_prod_im Complex.frontier_reProdIm
-/

#print Complex.frontier_setOf_le_re_and_le_im /-
theorem frontier_setOf_le_re_and_le_im (a b : ℝ) :
    frontier {z | a ≤ re z ∧ b ≤ im z} = {z | a ≤ re z ∧ im z = b ∨ re z = a ∧ b ≤ im z} := by
  simpa only [closure_Ici, frontier_Ici] using frontier_re_prod_im (Ici a) (Ici b)
#align complex.frontier_set_of_le_re_and_le_im Complex.frontier_setOf_le_re_and_le_im
-/

#print Complex.frontier_setOf_le_re_and_im_le /-
theorem frontier_setOf_le_re_and_im_le (a b : ℝ) :
    frontier {z | a ≤ re z ∧ im z ≤ b} = {z | a ≤ re z ∧ im z = b ∨ re z = a ∧ im z ≤ b} := by
  simpa only [closure_Ici, closure_Iic, frontier_Ici, frontier_Iic] using
    frontier_re_prod_im (Ici a) (Iic b)
#align complex.frontier_set_of_le_re_and_im_le Complex.frontier_setOf_le_re_and_im_le
-/

end Complex

open Complex Metric

variable {s t : Set ℝ}

#print IsOpen.reProdIm /-
theorem IsOpen.reProdIm (hs : IsOpen s) (ht : IsOpen t) : IsOpen (s ×ℂ t) :=
  (hs.Preimage continuous_re).inter (ht.Preimage continuous_im)
#align is_open.re_prod_im IsOpen.reProdIm
-/

#print IsClosed.reProdIm /-
theorem IsClosed.reProdIm (hs : IsClosed s) (ht : IsClosed t) : IsClosed (s ×ℂ t) :=
  (hs.Preimage continuous_re).inter (ht.Preimage continuous_im)
#align is_closed.re_prod_im IsClosed.reProdIm
-/

#print Metric.Bounded.reProdIm /-
theorem Metric.Bounded.reProdIm (hs : Bounded s) (ht : Bounded t) : Bounded (s ×ℂ t) :=
  antilipschitz_equivRealProd.bounded_preimage (hs.Prod ht)
#align metric.bounded.re_prod_im Metric.Bounded.reProdIm
-/

