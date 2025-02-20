/-
Copyright (c) 2022 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers

! This file was ported from Lean 3 source module analysis.convex.between
! leanprover-community/mathlib commit 571e13cacbed7bf042fd3058ce27157101433842
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Intervals.Group
import Mathbin.Analysis.Convex.Segment
import Mathbin.LinearAlgebra.AffineSpace.FiniteDimensional
import Mathbin.Tactic.FieldSimp
import Mathbin.Algebra.CharP.Invertible

/-!
# Betweenness in affine spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines notions of a point in an affine space being between two given points.

## Main definitions

* `affine_segment R x y`: The segment of points weakly between `x` and `y`.
* `wbtw R x y z`: The point `y` is weakly between `x` and `z`.
* `sbtw R x y z`: The point `y` is strictly between `x` and `z`.

-/


variable (R : Type _) {V V' P P' : Type _}

open AffineEquiv AffineMap

open scoped BigOperators

section OrderedRing

variable [OrderedRing R] [AddCommGroup V] [Module R V] [AddTorsor V P]

variable [AddCommGroup V'] [Module R V'] [AddTorsor V' P']

#print affineSegment /-
/-- The segment of points weakly between `x` and `y`. When convexity is refactored to support
abstract affine combination spaces, this will no longer need to be a separate definition from
`segment`. However, lemmas involving `+ᵥ` or `-ᵥ` will still be relevant after such a
refactoring, as distinct from versions involving `+` or `-` in a module. -/
def affineSegment (x y : P) :=
  lineMap x y '' Set.Icc (0 : R) 1
#align affine_segment affineSegment
-/

#print affineSegment_eq_segment /-
theorem affineSegment_eq_segment (x y : V) : affineSegment R x y = segment R x y := by
  rw [segment_eq_image_lineMap, affineSegment]
#align affine_segment_eq_segment affineSegment_eq_segment
-/

#print affineSegment_comm /-
theorem affineSegment_comm (x y : P) : affineSegment R x y = affineSegment R y x :=
  by
  refine' Set.ext fun z => _
  constructor <;>
    · rintro ⟨t, ht, hxy⟩
      refine' ⟨1 - t, _, _⟩
      · rwa [Set.sub_mem_Icc_iff_right, sub_self, sub_zero]
      · rwa [line_map_apply_one_sub]
#align affine_segment_comm affineSegment_comm
-/

#print left_mem_affineSegment /-
theorem left_mem_affineSegment (x y : P) : x ∈ affineSegment R x y :=
  ⟨0, Set.left_mem_Icc.2 zero_le_one, lineMap_apply_zero _ _⟩
#align left_mem_affine_segment left_mem_affineSegment
-/

#print right_mem_affineSegment /-
theorem right_mem_affineSegment (x y : P) : y ∈ affineSegment R x y :=
  ⟨1, Set.right_mem_Icc.2 zero_le_one, lineMap_apply_one _ _⟩
#align right_mem_affine_segment right_mem_affineSegment
-/

#print affineSegment_same /-
@[simp]
theorem affineSegment_same (x : P) : affineSegment R x x = {x} := by
  simp_rw [affineSegment, line_map_same, AffineMap.coe_const,
    (set.nonempty_Icc.mpr zero_le_one).image_const]
#align affine_segment_same affineSegment_same
-/

variable {R}

#print affineSegment_image /-
@[simp]
theorem affineSegment_image (f : P →ᵃ[R] P') (x y : P) :
    f '' affineSegment R x y = affineSegment R (f x) (f y) :=
  by
  rw [affineSegment, affineSegment, Set.image_image, ← comp_line_map]
  rfl
#align affine_segment_image affineSegment_image
-/

variable (R)

#print affineSegment_const_vadd_image /-
@[simp]
theorem affineSegment_const_vadd_image (x y : P) (v : V) :
    (· +ᵥ ·) v '' affineSegment R x y = affineSegment R (v +ᵥ x) (v +ᵥ y) :=
  affineSegment_image (AffineEquiv.constVAdd R P v : P →ᵃ[R] P) x y
#align affine_segment_const_vadd_image affineSegment_const_vadd_image
-/

#print affineSegment_vadd_const_image /-
@[simp]
theorem affineSegment_vadd_const_image (x y : V) (p : P) :
    (· +ᵥ p) '' affineSegment R x y = affineSegment R (x +ᵥ p) (y +ᵥ p) :=
  affineSegment_image (AffineEquiv.vaddConst R p : V →ᵃ[R] P) x y
#align affine_segment_vadd_const_image affineSegment_vadd_const_image
-/

#print affineSegment_const_vsub_image /-
@[simp]
theorem affineSegment_const_vsub_image (x y p : P) :
    (· -ᵥ ·) p '' affineSegment R x y = affineSegment R (p -ᵥ x) (p -ᵥ y) :=
  affineSegment_image (AffineEquiv.constVSub R p : P →ᵃ[R] V) x y
#align affine_segment_const_vsub_image affineSegment_const_vsub_image
-/

#print affineSegment_vsub_const_image /-
@[simp]
theorem affineSegment_vsub_const_image (x y p : P) :
    (· -ᵥ p) '' affineSegment R x y = affineSegment R (x -ᵥ p) (y -ᵥ p) :=
  affineSegment_image ((AffineEquiv.vaddConst R p).symm : P →ᵃ[R] V) x y
#align affine_segment_vsub_const_image affineSegment_vsub_const_image
-/

variable {R}

#print mem_const_vadd_affineSegment /-
@[simp]
theorem mem_const_vadd_affineSegment {x y z : P} (v : V) :
    v +ᵥ z ∈ affineSegment R (v +ᵥ x) (v +ᵥ y) ↔ z ∈ affineSegment R x y := by
  rw [← affineSegment_const_vadd_image, (AddAction.injective v).mem_set_image]
#align mem_const_vadd_affine_segment mem_const_vadd_affineSegment
-/

#print mem_vadd_const_affineSegment /-
@[simp]
theorem mem_vadd_const_affineSegment {x y z : V} (p : P) :
    z +ᵥ p ∈ affineSegment R (x +ᵥ p) (y +ᵥ p) ↔ z ∈ affineSegment R x y := by
  rw [← affineSegment_vadd_const_image, (vadd_right_injective p).mem_set_image]
#align mem_vadd_const_affine_segment mem_vadd_const_affineSegment
-/

variable {R}

#print mem_const_vsub_affineSegment /-
@[simp]
theorem mem_const_vsub_affineSegment {x y z : P} (p : P) :
    p -ᵥ z ∈ affineSegment R (p -ᵥ x) (p -ᵥ y) ↔ z ∈ affineSegment R x y := by
  rw [← affineSegment_const_vsub_image, (vsub_right_injective p).mem_set_image]
#align mem_const_vsub_affine_segment mem_const_vsub_affineSegment
-/

#print mem_vsub_const_affineSegment /-
@[simp]
theorem mem_vsub_const_affineSegment {x y z : P} (p : P) :
    z -ᵥ p ∈ affineSegment R (x -ᵥ p) (y -ᵥ p) ↔ z ∈ affineSegment R x y := by
  rw [← affineSegment_vsub_const_image, (vsub_left_injective p).mem_set_image]
#align mem_vsub_const_affine_segment mem_vsub_const_affineSegment
-/

variable (R)

#print Wbtw /-
/-- The point `y` is weakly between `x` and `z`. -/
def Wbtw (x y z : P) : Prop :=
  y ∈ affineSegment R x z
#align wbtw Wbtw
-/

#print Sbtw /-
/-- The point `y` is strictly between `x` and `z`. -/
def Sbtw (x y z : P) : Prop :=
  Wbtw R x y z ∧ y ≠ x ∧ y ≠ z
#align sbtw Sbtw
-/

variable {R}

#print Wbtw.map /-
theorem Wbtw.map {x y z : P} (h : Wbtw R x y z) (f : P →ᵃ[R] P') : Wbtw R (f x) (f y) (f z) :=
  by
  rw [Wbtw, ← affineSegment_image]
  exact Set.mem_image_of_mem _ h
#align wbtw.map Wbtw.map
-/

#print Function.Injective.wbtw_map_iff /-
theorem Function.Injective.wbtw_map_iff {x y z : P} {f : P →ᵃ[R] P'} (hf : Function.Injective f) :
    Wbtw R (f x) (f y) (f z) ↔ Wbtw R x y z :=
  by
  refine' ⟨fun h => _, fun h => h.map _⟩
  rwa [Wbtw, ← affineSegment_image, hf.mem_set_image] at h 
#align function.injective.wbtw_map_iff Function.Injective.wbtw_map_iff
-/

#print Function.Injective.sbtw_map_iff /-
theorem Function.Injective.sbtw_map_iff {x y z : P} {f : P →ᵃ[R] P'} (hf : Function.Injective f) :
    Sbtw R (f x) (f y) (f z) ↔ Sbtw R x y z := by simp_rw [Sbtw, hf.wbtw_map_iff, hf.ne_iff]
#align function.injective.sbtw_map_iff Function.Injective.sbtw_map_iff
-/

#print AffineEquiv.wbtw_map_iff /-
@[simp]
theorem AffineEquiv.wbtw_map_iff {x y z : P} (f : P ≃ᵃ[R] P') :
    Wbtw R (f x) (f y) (f z) ↔ Wbtw R x y z :=
  by
  refine' Function.Injective.wbtw_map_iff (_ : Function.Injective f.to_affine_map)
  exact f.injective
#align affine_equiv.wbtw_map_iff AffineEquiv.wbtw_map_iff
-/

#print AffineEquiv.sbtw_map_iff /-
@[simp]
theorem AffineEquiv.sbtw_map_iff {x y z : P} (f : P ≃ᵃ[R] P') :
    Sbtw R (f x) (f y) (f z) ↔ Sbtw R x y z :=
  by
  refine' Function.Injective.sbtw_map_iff (_ : Function.Injective f.to_affine_map)
  exact f.injective
#align affine_equiv.sbtw_map_iff AffineEquiv.sbtw_map_iff
-/

#print wbtw_const_vadd_iff /-
@[simp]
theorem wbtw_const_vadd_iff {x y z : P} (v : V) :
    Wbtw R (v +ᵥ x) (v +ᵥ y) (v +ᵥ z) ↔ Wbtw R x y z :=
  mem_const_vadd_affineSegment _
#align wbtw_const_vadd_iff wbtw_const_vadd_iff
-/

#print wbtw_vadd_const_iff /-
@[simp]
theorem wbtw_vadd_const_iff {x y z : V} (p : P) :
    Wbtw R (x +ᵥ p) (y +ᵥ p) (z +ᵥ p) ↔ Wbtw R x y z :=
  mem_vadd_const_affineSegment _
#align wbtw_vadd_const_iff wbtw_vadd_const_iff
-/

#print wbtw_const_vsub_iff /-
@[simp]
theorem wbtw_const_vsub_iff {x y z : P} (p : P) :
    Wbtw R (p -ᵥ x) (p -ᵥ y) (p -ᵥ z) ↔ Wbtw R x y z :=
  mem_const_vsub_affineSegment _
#align wbtw_const_vsub_iff wbtw_const_vsub_iff
-/

#print wbtw_vsub_const_iff /-
@[simp]
theorem wbtw_vsub_const_iff {x y z : P} (p : P) :
    Wbtw R (x -ᵥ p) (y -ᵥ p) (z -ᵥ p) ↔ Wbtw R x y z :=
  mem_vsub_const_affineSegment _
#align wbtw_vsub_const_iff wbtw_vsub_const_iff
-/

#print sbtw_const_vadd_iff /-
@[simp]
theorem sbtw_const_vadd_iff {x y z : P} (v : V) :
    Sbtw R (v +ᵥ x) (v +ᵥ y) (v +ᵥ z) ↔ Sbtw R x y z := by
  simp_rw [Sbtw, wbtw_const_vadd_iff, (AddAction.injective v).ne_iff]
#align sbtw_const_vadd_iff sbtw_const_vadd_iff
-/

#print sbtw_vadd_const_iff /-
@[simp]
theorem sbtw_vadd_const_iff {x y z : V} (p : P) :
    Sbtw R (x +ᵥ p) (y +ᵥ p) (z +ᵥ p) ↔ Sbtw R x y z := by
  simp_rw [Sbtw, wbtw_vadd_const_iff, (vadd_right_injective p).ne_iff]
#align sbtw_vadd_const_iff sbtw_vadd_const_iff
-/

#print sbtw_const_vsub_iff /-
@[simp]
theorem sbtw_const_vsub_iff {x y z : P} (p : P) :
    Sbtw R (p -ᵥ x) (p -ᵥ y) (p -ᵥ z) ↔ Sbtw R x y z := by
  simp_rw [Sbtw, wbtw_const_vsub_iff, (vsub_right_injective p).ne_iff]
#align sbtw_const_vsub_iff sbtw_const_vsub_iff
-/

#print sbtw_vsub_const_iff /-
@[simp]
theorem sbtw_vsub_const_iff {x y z : P} (p : P) :
    Sbtw R (x -ᵥ p) (y -ᵥ p) (z -ᵥ p) ↔ Sbtw R x y z := by
  simp_rw [Sbtw, wbtw_vsub_const_iff, (vsub_left_injective p).ne_iff]
#align sbtw_vsub_const_iff sbtw_vsub_const_iff
-/

#print Sbtw.wbtw /-
theorem Sbtw.wbtw {x y z : P} (h : Sbtw R x y z) : Wbtw R x y z :=
  h.1
#align sbtw.wbtw Sbtw.wbtw
-/

#print Sbtw.ne_left /-
theorem Sbtw.ne_left {x y z : P} (h : Sbtw R x y z) : y ≠ x :=
  h.2.1
#align sbtw.ne_left Sbtw.ne_left
-/

#print Sbtw.left_ne /-
theorem Sbtw.left_ne {x y z : P} (h : Sbtw R x y z) : x ≠ y :=
  h.2.1.symm
#align sbtw.left_ne Sbtw.left_ne
-/

#print Sbtw.ne_right /-
theorem Sbtw.ne_right {x y z : P} (h : Sbtw R x y z) : y ≠ z :=
  h.2.2
#align sbtw.ne_right Sbtw.ne_right
-/

#print Sbtw.right_ne /-
theorem Sbtw.right_ne {x y z : P} (h : Sbtw R x y z) : z ≠ y :=
  h.2.2.symm
#align sbtw.right_ne Sbtw.right_ne
-/

#print Sbtw.mem_image_Ioo /-
theorem Sbtw.mem_image_Ioo {x y z : P} (h : Sbtw R x y z) : y ∈ lineMap x z '' Set.Ioo (0 : R) 1 :=
  by
  rcases h with ⟨⟨t, ht, rfl⟩, hyx, hyz⟩
  rcases Set.eq_endpoints_or_mem_Ioo_of_mem_Icc ht with (rfl | rfl | ho)
  · exfalso; simpa using hyx
  · exfalso; simpa using hyz
  · exact ⟨t, ho, rfl⟩
#align sbtw.mem_image_Ioo Sbtw.mem_image_Ioo
-/

#print Wbtw.mem_affineSpan /-
theorem Wbtw.mem_affineSpan {x y z : P} (h : Wbtw R x y z) : y ∈ line[R, x, z] :=
  by
  rcases h with ⟨r, ⟨-, rfl⟩⟩
  exact line_map_mem_affine_span_pair _ _ _
#align wbtw.mem_affine_span Wbtw.mem_affineSpan
-/

#print wbtw_comm /-
theorem wbtw_comm {x y z : P} : Wbtw R x y z ↔ Wbtw R z y x := by
  rw [Wbtw, Wbtw, affineSegment_comm]
#align wbtw_comm wbtw_comm
-/

alias wbtw_comm ↔ Wbtw.symm _
#align wbtw.symm Wbtw.symm

#print sbtw_comm /-
theorem sbtw_comm {x y z : P} : Sbtw R x y z ↔ Sbtw R z y x := by
  rw [Sbtw, Sbtw, wbtw_comm, ← and_assoc', ← and_assoc', and_right_comm]
#align sbtw_comm sbtw_comm
-/

alias sbtw_comm ↔ Sbtw.symm _
#align sbtw.symm Sbtw.symm

variable (R)

#print wbtw_self_left /-
@[simp]
theorem wbtw_self_left (x y : P) : Wbtw R x x y :=
  left_mem_affineSegment _ _ _
#align wbtw_self_left wbtw_self_left
-/

#print wbtw_self_right /-
@[simp]
theorem wbtw_self_right (x y : P) : Wbtw R x y y :=
  right_mem_affineSegment _ _ _
#align wbtw_self_right wbtw_self_right
-/

#print wbtw_self_iff /-
@[simp]
theorem wbtw_self_iff {x y : P} : Wbtw R x y x ↔ y = x :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · simpa [Wbtw, affineSegment] using h
  · rw [h]
    exact wbtw_self_left R x x
#align wbtw_self_iff wbtw_self_iff
-/

#print not_sbtw_self_left /-
@[simp]
theorem not_sbtw_self_left (x y : P) : ¬Sbtw R x x y := fun h => h.ne_left rfl
#align not_sbtw_self_left not_sbtw_self_left
-/

#print not_sbtw_self_right /-
@[simp]
theorem not_sbtw_self_right (x y : P) : ¬Sbtw R x y y := fun h => h.ne_right rfl
#align not_sbtw_self_right not_sbtw_self_right
-/

variable {R}

#print Wbtw.left_ne_right_of_ne_left /-
theorem Wbtw.left_ne_right_of_ne_left {x y z : P} (h : Wbtw R x y z) (hne : y ≠ x) : x ≠ z :=
  by
  rintro rfl
  rw [wbtw_self_iff] at h 
  exact hne h
#align wbtw.left_ne_right_of_ne_left Wbtw.left_ne_right_of_ne_left
-/

#print Wbtw.left_ne_right_of_ne_right /-
theorem Wbtw.left_ne_right_of_ne_right {x y z : P} (h : Wbtw R x y z) (hne : y ≠ z) : x ≠ z :=
  by
  rintro rfl
  rw [wbtw_self_iff] at h 
  exact hne h
#align wbtw.left_ne_right_of_ne_right Wbtw.left_ne_right_of_ne_right
-/

#print Sbtw.left_ne_right /-
theorem Sbtw.left_ne_right {x y z : P} (h : Sbtw R x y z) : x ≠ z :=
  h.Wbtw.left_ne_right_of_ne_left h.2.1
#align sbtw.left_ne_right Sbtw.left_ne_right
-/

#print sbtw_iff_mem_image_Ioo_and_ne /-
theorem sbtw_iff_mem_image_Ioo_and_ne [NoZeroSMulDivisors R V] {x y z : P} :
    Sbtw R x y z ↔ y ∈ lineMap x z '' Set.Ioo (0 : R) 1 ∧ x ≠ z :=
  by
  refine' ⟨fun h => ⟨h.mem_image_Ioo, h.left_ne_right⟩, fun h => _⟩
  rcases h with ⟨⟨t, ht, rfl⟩, hxz⟩
  refine' ⟨⟨t, Set.mem_Icc_of_Ioo ht, rfl⟩, _⟩
  rw [line_map_apply, ← @vsub_ne_zero V, ← @vsub_ne_zero V _ _ _ _ z, vadd_vsub_assoc,
    vadd_vsub_assoc, ← neg_vsub_eq_vsub_rev z x, ← @neg_one_smul R, ← add_smul, ← sub_eq_add_neg]
  simp [smul_ne_zero, hxz.symm, sub_eq_zero, ht.1.Ne.symm, ht.2.Ne]
#align sbtw_iff_mem_image_Ioo_and_ne sbtw_iff_mem_image_Ioo_and_ne
-/

variable (R)

#print not_sbtw_self /-
@[simp]
theorem not_sbtw_self (x y : P) : ¬Sbtw R x y x := fun h => h.left_ne_right rfl
#align not_sbtw_self not_sbtw_self
-/

#print wbtw_swap_left_iff /-
theorem wbtw_swap_left_iff [NoZeroSMulDivisors R V] {x y : P} (z : P) :
    Wbtw R x y z ∧ Wbtw R y x z ↔ x = y := by
  constructor
  · rintro ⟨hxyz, hyxz⟩
    rcases hxyz with ⟨ty, hty, rfl⟩
    rcases hyxz with ⟨tx, htx, hx⟩
    simp_rw [line_map_apply, ← add_vadd] at hx 
    rw [← @vsub_eq_zero_iff_eq V, vadd_vsub, vsub_vadd_eq_vsub_sub, smul_sub, smul_smul, ← sub_smul,
      ← add_smul, smul_eq_zero] at hx 
    rcases hx with (h | h)
    · nth_rw 1 [← mul_one tx] at h 
      rw [← mul_sub, add_eq_zero_iff_neg_eq] at h 
      have h' : ty = 0 := by
        refine' le_antisymm _ hty.1
        rw [← h, Left.neg_nonpos_iff]
        exact mul_nonneg htx.1 (sub_nonneg.2 hty.2)
      simp [h']
    · rw [vsub_eq_zero_iff_eq] at h 
      simp [h]
  · rintro rfl
    exact ⟨wbtw_self_left _ _ _, wbtw_self_left _ _ _⟩
#align wbtw_swap_left_iff wbtw_swap_left_iff
-/

#print wbtw_swap_right_iff /-
theorem wbtw_swap_right_iff [NoZeroSMulDivisors R V] (x : P) {y z : P} :
    Wbtw R x y z ∧ Wbtw R x z y ↔ y = z :=
  by
  nth_rw 1 [wbtw_comm]
  nth_rw 2 [wbtw_comm]
  rw [eq_comm]
  exact wbtw_swap_left_iff R x
#align wbtw_swap_right_iff wbtw_swap_right_iff
-/

#print wbtw_rotate_iff /-
theorem wbtw_rotate_iff [NoZeroSMulDivisors R V] (x : P) {y z : P} :
    Wbtw R x y z ∧ Wbtw R z x y ↔ x = y := by rw [wbtw_comm, wbtw_swap_right_iff, eq_comm]
#align wbtw_rotate_iff wbtw_rotate_iff
-/

variable {R}

#print Wbtw.swap_left_iff /-
theorem Wbtw.swap_left_iff [NoZeroSMulDivisors R V] {x y z : P} (h : Wbtw R x y z) :
    Wbtw R y x z ↔ x = y := by rw [← wbtw_swap_left_iff R z, and_iff_right h]
#align wbtw.swap_left_iff Wbtw.swap_left_iff
-/

#print Wbtw.swap_right_iff /-
theorem Wbtw.swap_right_iff [NoZeroSMulDivisors R V] {x y z : P} (h : Wbtw R x y z) :
    Wbtw R x z y ↔ y = z := by rw [← wbtw_swap_right_iff R x, and_iff_right h]
#align wbtw.swap_right_iff Wbtw.swap_right_iff
-/

#print Wbtw.rotate_iff /-
theorem Wbtw.rotate_iff [NoZeroSMulDivisors R V] {x y z : P} (h : Wbtw R x y z) :
    Wbtw R z x y ↔ x = y := by rw [← wbtw_rotate_iff R x, and_iff_right h]
#align wbtw.rotate_iff Wbtw.rotate_iff
-/

#print Sbtw.not_swap_left /-
theorem Sbtw.not_swap_left [NoZeroSMulDivisors R V] {x y z : P} (h : Sbtw R x y z) :
    ¬Wbtw R y x z := fun hs => h.left_ne (h.Wbtw.swap_left_iff.1 hs)
#align sbtw.not_swap_left Sbtw.not_swap_left
-/

#print Sbtw.not_swap_right /-
theorem Sbtw.not_swap_right [NoZeroSMulDivisors R V] {x y z : P} (h : Sbtw R x y z) :
    ¬Wbtw R x z y := fun hs => h.ne_right (h.Wbtw.swap_right_iff.1 hs)
#align sbtw.not_swap_right Sbtw.not_swap_right
-/

#print Sbtw.not_rotate /-
theorem Sbtw.not_rotate [NoZeroSMulDivisors R V] {x y z : P} (h : Sbtw R x y z) : ¬Wbtw R z x y :=
  fun hs => h.left_ne (h.Wbtw.rotate_iff.1 hs)
#align sbtw.not_rotate Sbtw.not_rotate
-/

#print wbtw_lineMap_iff /-
@[simp]
theorem wbtw_lineMap_iff [NoZeroSMulDivisors R V] {x y : P} {r : R} :
    Wbtw R x (lineMap x y r) y ↔ x = y ∨ r ∈ Set.Icc (0 : R) 1 :=
  by
  by_cases hxy : x = y; · simp [hxy]
  rw [or_iff_right hxy, Wbtw, affineSegment, (line_map_injective R hxy).mem_set_image]
#align wbtw_line_map_iff wbtw_lineMap_iff
-/

#print sbtw_lineMap_iff /-
@[simp]
theorem sbtw_lineMap_iff [NoZeroSMulDivisors R V] {x y : P} {r : R} :
    Sbtw R x (lineMap x y r) y ↔ x ≠ y ∧ r ∈ Set.Ioo (0 : R) 1 :=
  by
  rw [sbtw_iff_mem_image_Ioo_and_ne, and_comm', and_congr_right]
  intro hxy
  rw [(line_map_injective R hxy).mem_set_image]
#align sbtw_line_map_iff sbtw_lineMap_iff
-/

#print wbtw_mul_sub_add_iff /-
@[simp]
theorem wbtw_mul_sub_add_iff [NoZeroDivisors R] {x y r : R} :
    Wbtw R x (r * (y - x) + x) y ↔ x = y ∨ r ∈ Set.Icc (0 : R) 1 :=
  wbtw_lineMap_iff
#align wbtw_mul_sub_add_iff wbtw_mul_sub_add_iff
-/

#print sbtw_mul_sub_add_iff /-
@[simp]
theorem sbtw_mul_sub_add_iff [NoZeroDivisors R] {x y r : R} :
    Sbtw R x (r * (y - x) + x) y ↔ x ≠ y ∧ r ∈ Set.Ioo (0 : R) 1 :=
  sbtw_lineMap_iff
#align sbtw_mul_sub_add_iff sbtw_mul_sub_add_iff
-/

#print wbtw_zero_one_iff /-
@[simp]
theorem wbtw_zero_one_iff {x : R} : Wbtw R 0 x 1 ↔ x ∈ Set.Icc (0 : R) 1 :=
  by
  simp_rw [Wbtw, affineSegment, Set.mem_image, line_map_apply_ring]
  simp
#align wbtw_zero_one_iff wbtw_zero_one_iff
-/

#print wbtw_one_zero_iff /-
@[simp]
theorem wbtw_one_zero_iff {x : R} : Wbtw R 1 x 0 ↔ x ∈ Set.Icc (0 : R) 1 := by
  rw [wbtw_comm, wbtw_zero_one_iff]
#align wbtw_one_zero_iff wbtw_one_zero_iff
-/

#print sbtw_zero_one_iff /-
@[simp]
theorem sbtw_zero_one_iff {x : R} : Sbtw R 0 x 1 ↔ x ∈ Set.Ioo (0 : R) 1 :=
  by
  rw [Sbtw, wbtw_zero_one_iff, Set.mem_Icc, Set.mem_Ioo]
  exact
    ⟨fun h => ⟨h.1.1.lt_of_ne (Ne.symm h.2.1), h.1.2.lt_of_ne h.2.2⟩, fun h =>
      ⟨⟨h.1.le, h.2.le⟩, h.1.ne', h.2.Ne⟩⟩
#align sbtw_zero_one_iff sbtw_zero_one_iff
-/

#print sbtw_one_zero_iff /-
@[simp]
theorem sbtw_one_zero_iff {x : R} : Sbtw R 1 x 0 ↔ x ∈ Set.Ioo (0 : R) 1 := by
  rw [sbtw_comm, sbtw_zero_one_iff]
#align sbtw_one_zero_iff sbtw_one_zero_iff
-/

#print Wbtw.trans_left /-
theorem Wbtw.trans_left {w x y z : P} (h₁ : Wbtw R w y z) (h₂ : Wbtw R w x y) : Wbtw R w x z :=
  by
  rcases h₁ with ⟨t₁, ht₁, rfl⟩
  rcases h₂ with ⟨t₂, ht₂, rfl⟩
  refine' ⟨t₂ * t₁, ⟨mul_nonneg ht₂.1 ht₁.1, mul_le_one ht₂.2 ht₁.1 ht₁.2⟩, _⟩
  simp [line_map_apply, smul_smul]
#align wbtw.trans_left Wbtw.trans_left
-/

#print Wbtw.trans_right /-
theorem Wbtw.trans_right {w x y z : P} (h₁ : Wbtw R w x z) (h₂ : Wbtw R x y z) : Wbtw R w y z :=
  by
  rw [wbtw_comm] at *
  exact h₁.trans_left h₂
#align wbtw.trans_right Wbtw.trans_right
-/

#print Wbtw.trans_sbtw_left /-
theorem Wbtw.trans_sbtw_left [NoZeroSMulDivisors R V] {w x y z : P} (h₁ : Wbtw R w y z)
    (h₂ : Sbtw R w x y) : Sbtw R w x z :=
  by
  refine' ⟨h₁.trans_left h₂.wbtw, h₂.ne_left, _⟩
  rintro rfl
  exact h₂.right_ne ((wbtw_swap_right_iff R w).1 ⟨h₁, h₂.wbtw⟩)
#align wbtw.trans_sbtw_left Wbtw.trans_sbtw_left
-/

#print Wbtw.trans_sbtw_right /-
theorem Wbtw.trans_sbtw_right [NoZeroSMulDivisors R V] {w x y z : P} (h₁ : Wbtw R w x z)
    (h₂ : Sbtw R x y z) : Sbtw R w y z :=
  by
  rw [wbtw_comm] at *
  rw [sbtw_comm] at *
  exact h₁.trans_sbtw_left h₂
#align wbtw.trans_sbtw_right Wbtw.trans_sbtw_right
-/

#print Sbtw.trans_left /-
theorem Sbtw.trans_left [NoZeroSMulDivisors R V] {w x y z : P} (h₁ : Sbtw R w y z)
    (h₂ : Sbtw R w x y) : Sbtw R w x z :=
  h₁.Wbtw.trans_sbtw_left h₂
#align sbtw.trans_left Sbtw.trans_left
-/

#print Sbtw.trans_right /-
theorem Sbtw.trans_right [NoZeroSMulDivisors R V] {w x y z : P} (h₁ : Sbtw R w x z)
    (h₂ : Sbtw R x y z) : Sbtw R w y z :=
  h₁.Wbtw.trans_sbtw_right h₂
#align sbtw.trans_right Sbtw.trans_right
-/

#print Wbtw.trans_left_ne /-
theorem Wbtw.trans_left_ne [NoZeroSMulDivisors R V] {w x y z : P} (h₁ : Wbtw R w y z)
    (h₂ : Wbtw R w x y) (h : y ≠ z) : x ≠ z :=
  by
  rintro rfl
  exact h (h₁.swap_right_iff.1 h₂)
#align wbtw.trans_left_ne Wbtw.trans_left_ne
-/

#print Wbtw.trans_right_ne /-
theorem Wbtw.trans_right_ne [NoZeroSMulDivisors R V] {w x y z : P} (h₁ : Wbtw R w x z)
    (h₂ : Wbtw R x y z) (h : w ≠ x) : w ≠ y :=
  by
  rintro rfl
  exact h (h₁.swap_left_iff.1 h₂)
#align wbtw.trans_right_ne Wbtw.trans_right_ne
-/

#print Sbtw.trans_wbtw_left_ne /-
theorem Sbtw.trans_wbtw_left_ne [NoZeroSMulDivisors R V] {w x y z : P} (h₁ : Sbtw R w y z)
    (h₂ : Wbtw R w x y) : x ≠ z :=
  h₁.Wbtw.trans_left_ne h₂ h₁.ne_right
#align sbtw.trans_wbtw_left_ne Sbtw.trans_wbtw_left_ne
-/

#print Sbtw.trans_wbtw_right_ne /-
theorem Sbtw.trans_wbtw_right_ne [NoZeroSMulDivisors R V] {w x y z : P} (h₁ : Sbtw R w x z)
    (h₂ : Wbtw R x y z) : w ≠ y :=
  h₁.Wbtw.trans_right_ne h₂ h₁.left_ne
#align sbtw.trans_wbtw_right_ne Sbtw.trans_wbtw_right_ne
-/

#print Sbtw.affineCombination_of_mem_affineSpan_pair /-
theorem Sbtw.affineCombination_of_mem_affineSpan_pair [NoZeroDivisors R] [NoZeroSMulDivisors R V]
    {ι : Type _} {p : ι → P} (ha : AffineIndependent R p) {w w₁ w₂ : ι → R} {s : Finset ι}
    (hw : ∑ i in s, w i = 1) (hw₁ : ∑ i in s, w₁ i = 1) (hw₂ : ∑ i in s, w₂ i = 1)
    (h :
      s.affineCombination R p w ∈ line[R, s.affineCombination R p w₁, s.affineCombination R p w₂])
    {i : ι} (his : i ∈ s) (hs : Sbtw R (w₁ i) (w i) (w₂ i)) :
    Sbtw R (s.affineCombination R p w₁) (s.affineCombination R p w) (s.affineCombination R p w₂) :=
  by
  rw [affineCombination_mem_affineSpan_pair ha hw hw₁ hw₂] at h 
  rcases h with ⟨r, hr⟩
  dsimp only at hr 
  rw [hr i his, sbtw_mul_sub_add_iff] at hs 
  change ∀ i ∈ s, w i = (r • (w₂ - w₁) + w₁) i at hr 
  rw [s.affine_combination_congr hr fun _ _ => rfl]
  dsimp only
  rw [← s.weighted_vsub_vadd_affine_combination, s.weighted_vsub_const_smul, ←
    s.affine_combination_vsub, ← line_map_apply, sbtw_lineMap_iff, and_iff_left hs.2, ←
    @vsub_ne_zero V, s.affine_combination_vsub]
  intro hz
  have hw₁w₂ : ∑ i in s, (w₁ - w₂) i = 0 := by
    simp_rw [Pi.sub_apply, Finset.sum_sub_distrib, hw₁, hw₂, sub_self]
  refine' hs.1 _
  have ha' := ha s (w₁ - w₂) hw₁w₂ hz i his
  rwa [Pi.sub_apply, sub_eq_zero] at ha' 
#align sbtw.affine_combination_of_mem_affine_span_pair Sbtw.affineCombination_of_mem_affineSpan_pair
-/

end OrderedRing

section StrictOrderedCommRing

variable [StrictOrderedCommRing R] [AddCommGroup V] [Module R V] [AddTorsor V P]

variable {R}

#print Wbtw.sameRay_vsub /-
theorem Wbtw.sameRay_vsub {x y z : P} (h : Wbtw R x y z) : SameRay R (y -ᵥ x) (z -ᵥ y) :=
  by
  rcases h with ⟨t, ⟨ht0, ht1⟩, rfl⟩
  simp_rw [line_map_apply]
  rcases ht0.lt_or_eq with (ht0' | rfl); swap; · simp
  rcases ht1.lt_or_eq with (ht1' | rfl); swap; · simp
  refine' Or.inr (Or.inr ⟨1 - t, t, sub_pos.2 ht1', ht0', _⟩)
  simp [vsub_vadd_eq_vsub_sub, smul_sub, smul_smul, ← sub_smul]
  ring_nf
#align wbtw.same_ray_vsub Wbtw.sameRay_vsub
-/

#print Wbtw.sameRay_vsub_left /-
theorem Wbtw.sameRay_vsub_left {x y z : P} (h : Wbtw R x y z) : SameRay R (y -ᵥ x) (z -ᵥ x) :=
  by
  rcases h with ⟨t, ⟨ht0, ht1⟩, rfl⟩
  simpa [line_map_apply] using SameRay.sameRay_nonneg_smul_left (z -ᵥ x) ht0
#align wbtw.same_ray_vsub_left Wbtw.sameRay_vsub_left
-/

#print Wbtw.sameRay_vsub_right /-
theorem Wbtw.sameRay_vsub_right {x y z : P} (h : Wbtw R x y z) : SameRay R (z -ᵥ x) (z -ᵥ y) :=
  by
  rcases h with ⟨t, ⟨ht0, ht1⟩, rfl⟩
  simpa [line_map_apply, vsub_vadd_eq_vsub_sub, sub_smul] using
    SameRay.sameRay_nonneg_smul_right (z -ᵥ x) (sub_nonneg.2 ht1)
#align wbtw.same_ray_vsub_right Wbtw.sameRay_vsub_right
-/

end StrictOrderedCommRing

section LinearOrderedRing

variable [LinearOrderedRing R] [AddCommGroup V] [Module R V] [AddTorsor V P]

variable {R}

#print sbtw_of_sbtw_of_sbtw_of_mem_affineSpan_pair /-
/-- Suppose lines from two vertices of a triangle to interior points of the opposite side meet at
`p`. Then `p` lies in the interior of the first (and by symmetry the other) segment from a
vertex to the point on the opposite side. -/
theorem sbtw_of_sbtw_of_sbtw_of_mem_affineSpan_pair [NoZeroSMulDivisors R V]
    {t : Affine.Triangle R P} {i₁ i₂ i₃ : Fin 3} (h₁₂ : i₁ ≠ i₂) {p₁ p₂ p : P}
    (h₁ : Sbtw R (t.points i₂) p₁ (t.points i₃)) (h₂ : Sbtw R (t.points i₁) p₂ (t.points i₃))
    (h₁' : p ∈ line[R, t.points i₁, p₁]) (h₂' : p ∈ line[R, t.points i₂, p₂]) :
    Sbtw R (t.points i₁) p p₁ :=
  by
  -- Should not be needed; see comments on local instances in `data.sign`.
  letI : DecidableRel ((· < ·) : R → R → Prop) := LinearOrderedRing.decidableLt
  have h₁₃ : i₁ ≠ i₃ := by rintro rfl; simpa using h₂
  have h₂₃ : i₂ ≠ i₃ := by rintro rfl; simpa using h₁
  have h3 : ∀ i : Fin 3, i = i₁ ∨ i = i₂ ∨ i = i₃ := by clear h₁ h₂ h₁' h₂'; decide!
  have hu : (Finset.univ : Finset (Fin 3)) = {i₁, i₂, i₃} := by clear h₁ h₂ h₁' h₂'; decide!
  have hp : p ∈ affineSpan R (Set.range t.points) :=
    by
    have hle : line[R, t.points i₁, p₁] ≤ affineSpan R (Set.range t.points) :=
      by
      refine' affineSpan_pair_le_of_mem_of_mem (mem_affineSpan _ (Set.mem_range_self _)) _
      have hle : line[R, t.points i₂, t.points i₃] ≤ affineSpan R (Set.range t.points) := by
        refine' affineSpan_mono _ _; simp [Set.insert_subset_iff]
      rw [AffineSubspace.le_def'] at hle 
      exact hle _ h₁.wbtw.mem_affine_span
    rw [AffineSubspace.le_def'] at hle 
    exact hle _ h₁'
  have h₁i := h₁.mem_image_Ioo
  have h₂i := h₂.mem_image_Ioo
  rw [Set.mem_image] at h₁i h₂i 
  rcases h₁i with ⟨r₁, ⟨hr₁0, hr₁1⟩, rfl⟩
  rcases h₂i with ⟨r₂, ⟨hr₂0, hr₂1⟩, rfl⟩
  rcases eq_affineCombination_of_mem_affineSpan_of_fintype hp with ⟨w, hw, rfl⟩
  have h₁s :=
    sign_eq_of_affineCombination_mem_affineSpan_single_lineMap t.independent hw (Finset.mem_univ _)
      (Finset.mem_univ _) (Finset.mem_univ _) h₁₂ h₁₃ h₂₃ hr₁0 hr₁1 h₁'
  have h₂s :=
    sign_eq_of_affineCombination_mem_affineSpan_single_lineMap t.independent hw (Finset.mem_univ _)
      (Finset.mem_univ _) (Finset.mem_univ _) h₁₂.symm h₂₃ h₁₃ hr₂0 hr₂1 h₂'
  dsimp only at h₁s h₂s 
  rw [←
    finset.univ.affine_combination_affine_combination_single_weights R t.points
      (Finset.mem_univ i₁),
    ←
    finset.univ.affine_combination_affine_combination_line_map_weights t.points (Finset.mem_univ _)
      (Finset.mem_univ _)] at
    h₁' ⊢
  refine'
    Sbtw.affineCombination_of_mem_affineSpan_pair t.independent hw
      (finset.univ.sum_affine_combination_single_weights R (Finset.mem_univ _))
      (finset.univ.sum_affine_combination_line_map_weights (Finset.mem_univ _) (Finset.mem_univ _)
        _)
      h₁' (Finset.mem_univ i₁) _
  rw [Finset.affineCombinationSingleWeights_apply_self,
    Finset.affineCombinationLineMapWeights_apply_of_ne h₁₂ h₁₃, sbtw_one_zero_iff]
  have hs : ∀ i : Fin 3, SignType.sign (w i) = SignType.sign (w i₃) :=
    by
    intro i
    rcases h3 i with (rfl | rfl | rfl)
    · exact h₂s
    · exact h₁s
    · rfl
  have hss : SignType.sign (∑ i, w i) = 1 := by simp [hw]
  have hs' := sign_sum Finset.univ_nonempty (SignType.sign (w i₃)) fun i _ => hs i
  rw [hs'] at hss 
  simp_rw [hss, sign_eq_one_iff] at hs 
  refine' ⟨hs i₁, _⟩
  rw [hu] at hw 
  rw [Finset.sum_insert, Finset.sum_insert, Finset.sum_singleton] at hw 
  · by_contra hle
    rw [not_lt] at hle 
    exact (hle.trans_lt (lt_add_of_pos_right _ (Left.add_pos (hs i₂) (hs i₃)))).ne' hw
  · simp [h₂₃]
  · simp [h₁₂, h₁₃]
#align sbtw_of_sbtw_of_sbtw_of_mem_affine_span_pair sbtw_of_sbtw_of_sbtw_of_mem_affineSpan_pair
-/

end LinearOrderedRing

section LinearOrderedField

variable [LinearOrderedField R] [AddCommGroup V] [Module R V] [AddTorsor V P]

variable {R}

#print wbtw_iff_left_eq_or_right_mem_image_Ici /-
theorem wbtw_iff_left_eq_or_right_mem_image_Ici {x y z : P} :
    Wbtw R x y z ↔ x = y ∨ z ∈ lineMap x y '' Set.Ici (1 : R) :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · rcases h with ⟨r, ⟨hr0, hr1⟩, rfl⟩
    rcases hr0.lt_or_eq with (hr0' | rfl)
    · rw [Set.mem_image]
      refine' Or.inr ⟨r⁻¹, one_le_inv hr0' hr1, _⟩
      simp only [line_map_apply, smul_smul, vadd_vsub]
      rw [inv_mul_cancel hr0'.ne', one_smul, vsub_vadd]
    · simp
  · rcases h with (rfl | ⟨r, ⟨hr, rfl⟩⟩)
    · exact wbtw_self_left _ _ _
    · rw [Set.mem_Ici] at hr 
      refine' ⟨r⁻¹, ⟨inv_nonneg.2 (zero_le_one.trans hr), inv_le_one hr⟩, _⟩
      simp only [line_map_apply, smul_smul, vadd_vsub]
      rw [inv_mul_cancel (one_pos.trans_le hr).ne', one_smul, vsub_vadd]
#align wbtw_iff_left_eq_or_right_mem_image_Ici wbtw_iff_left_eq_or_right_mem_image_Ici
-/

#print Wbtw.right_mem_image_Ici_of_left_ne /-
theorem Wbtw.right_mem_image_Ici_of_left_ne {x y z : P} (h : Wbtw R x y z) (hne : x ≠ y) :
    z ∈ lineMap x y '' Set.Ici (1 : R) :=
  (wbtw_iff_left_eq_or_right_mem_image_Ici.1 h).resolve_left hne
#align wbtw.right_mem_image_Ici_of_left_ne Wbtw.right_mem_image_Ici_of_left_ne
-/

#print Wbtw.right_mem_affineSpan_of_left_ne /-
theorem Wbtw.right_mem_affineSpan_of_left_ne {x y z : P} (h : Wbtw R x y z) (hne : x ≠ y) :
    z ∈ line[R, x, y] :=
  by
  rcases h.right_mem_image_Ici_of_left_ne hne with ⟨r, ⟨-, rfl⟩⟩
  exact line_map_mem_affine_span_pair _ _ _
#align wbtw.right_mem_affine_span_of_left_ne Wbtw.right_mem_affineSpan_of_left_ne
-/

#print sbtw_iff_left_ne_and_right_mem_image_Ioi /-
theorem sbtw_iff_left_ne_and_right_mem_image_Ioi {x y z : P} :
    Sbtw R x y z ↔ x ≠ y ∧ z ∈ lineMap x y '' Set.Ioi (1 : R) :=
  by
  refine' ⟨fun h => ⟨h.left_ne, _⟩, fun h => _⟩
  · obtain ⟨r, ⟨hr, rfl⟩⟩ := h.wbtw.right_mem_image_Ici_of_left_ne h.left_ne
    rw [Set.mem_Ici] at hr 
    rcases hr.lt_or_eq with (hrlt | rfl)
    · exact Set.mem_image_of_mem _ hrlt
    · exfalso; simpa using h
  · rcases h with ⟨hne, r, hr, rfl⟩
    rw [Set.mem_Ioi] at hr 
    refine'
      ⟨wbtw_iff_left_eq_or_right_mem_image_Ici.2
          (Or.inr (Set.mem_image_of_mem _ (Set.mem_of_mem_of_subset hr Set.Ioi_subset_Ici_self))),
        hne.symm, _⟩
    rw [line_map_apply, ← @vsub_ne_zero V, vsub_vadd_eq_vsub_sub]
    nth_rw 1 [← one_smul R (y -ᵥ x)]
    rw [← sub_smul, smul_ne_zero_iff, vsub_ne_zero, sub_ne_zero]
    exact ⟨hr.ne, hne.symm⟩
#align sbtw_iff_left_ne_and_right_mem_image_IoI sbtw_iff_left_ne_and_right_mem_image_Ioi
-/

#print Sbtw.right_mem_image_Ioi /-
theorem Sbtw.right_mem_image_Ioi {x y z : P} (h : Sbtw R x y z) :
    z ∈ lineMap x y '' Set.Ioi (1 : R) :=
  (sbtw_iff_left_ne_and_right_mem_image_Ioi.1 h).2
#align sbtw.right_mem_image_Ioi Sbtw.right_mem_image_Ioi
-/

#print Sbtw.right_mem_affineSpan /-
theorem Sbtw.right_mem_affineSpan {x y z : P} (h : Sbtw R x y z) : z ∈ line[R, x, y] :=
  h.Wbtw.right_mem_affineSpan_of_left_ne h.left_ne
#align sbtw.right_mem_affine_span Sbtw.right_mem_affineSpan
-/

#print wbtw_iff_right_eq_or_left_mem_image_Ici /-
theorem wbtw_iff_right_eq_or_left_mem_image_Ici {x y z : P} :
    Wbtw R x y z ↔ z = y ∨ x ∈ lineMap z y '' Set.Ici (1 : R) := by
  rw [wbtw_comm, wbtw_iff_left_eq_or_right_mem_image_Ici]
#align wbtw_iff_right_eq_or_left_mem_image_Ici wbtw_iff_right_eq_or_left_mem_image_Ici
-/

#print Wbtw.left_mem_image_Ici_of_right_ne /-
theorem Wbtw.left_mem_image_Ici_of_right_ne {x y z : P} (h : Wbtw R x y z) (hne : z ≠ y) :
    x ∈ lineMap z y '' Set.Ici (1 : R) :=
  h.symm.right_mem_image_Ici_of_left_ne hne
#align wbtw.left_mem_image_Ici_of_right_ne Wbtw.left_mem_image_Ici_of_right_ne
-/

#print Wbtw.left_mem_affineSpan_of_right_ne /-
theorem Wbtw.left_mem_affineSpan_of_right_ne {x y z : P} (h : Wbtw R x y z) (hne : z ≠ y) :
    x ∈ line[R, z, y] :=
  h.symm.right_mem_affineSpan_of_left_ne hne
#align wbtw.left_mem_affine_span_of_right_ne Wbtw.left_mem_affineSpan_of_right_ne
-/

#print sbtw_iff_right_ne_and_left_mem_image_Ioi /-
theorem sbtw_iff_right_ne_and_left_mem_image_Ioi {x y z : P} :
    Sbtw R x y z ↔ z ≠ y ∧ x ∈ lineMap z y '' Set.Ioi (1 : R) := by
  rw [sbtw_comm, sbtw_iff_left_ne_and_right_mem_image_Ioi]
#align sbtw_iff_right_ne_and_left_mem_image_IoI sbtw_iff_right_ne_and_left_mem_image_Ioi
-/

#print Sbtw.left_mem_image_Ioi /-
theorem Sbtw.left_mem_image_Ioi {x y z : P} (h : Sbtw R x y z) :
    x ∈ lineMap z y '' Set.Ioi (1 : R) :=
  h.symm.right_mem_image_Ioi
#align sbtw.left_mem_image_Ioi Sbtw.left_mem_image_Ioi
-/

#print Sbtw.left_mem_affineSpan /-
theorem Sbtw.left_mem_affineSpan {x y z : P} (h : Sbtw R x y z) : x ∈ line[R, z, y] :=
  h.symm.right_mem_affineSpan
#align sbtw.left_mem_affine_span Sbtw.left_mem_affineSpan
-/

#print wbtw_smul_vadd_smul_vadd_of_nonneg_of_le /-
theorem wbtw_smul_vadd_smul_vadd_of_nonneg_of_le (x : P) (v : V) {r₁ r₂ : R} (hr₁ : 0 ≤ r₁)
    (hr₂ : r₁ ≤ r₂) : Wbtw R x (r₁ • v +ᵥ x) (r₂ • v +ᵥ x) :=
  by
  refine' ⟨r₁ / r₂, ⟨div_nonneg hr₁ (hr₁.trans hr₂), div_le_one_of_le hr₂ (hr₁.trans hr₂)⟩, _⟩
  by_cases h : r₁ = 0; · simp [h]
  simp [line_map_apply, smul_smul, ((hr₁.lt_of_ne' h).trans_le hr₂).Ne.symm]
#align wbtw_smul_vadd_smul_vadd_of_nonneg_of_le wbtw_smul_vadd_smul_vadd_of_nonneg_of_le
-/

#print wbtw_or_wbtw_smul_vadd_of_nonneg /-
theorem wbtw_or_wbtw_smul_vadd_of_nonneg (x : P) (v : V) {r₁ r₂ : R} (hr₁ : 0 ≤ r₁) (hr₂ : 0 ≤ r₂) :
    Wbtw R x (r₁ • v +ᵥ x) (r₂ • v +ᵥ x) ∨ Wbtw R x (r₂ • v +ᵥ x) (r₁ • v +ᵥ x) :=
  by
  rcases le_total r₁ r₂ with (h | h)
  · exact Or.inl (wbtw_smul_vadd_smul_vadd_of_nonneg_of_le x v hr₁ h)
  · exact Or.inr (wbtw_smul_vadd_smul_vadd_of_nonneg_of_le x v hr₂ h)
#align wbtw_or_wbtw_smul_vadd_of_nonneg wbtw_or_wbtw_smul_vadd_of_nonneg
-/

#print wbtw_smul_vadd_smul_vadd_of_nonpos_of_le /-
theorem wbtw_smul_vadd_smul_vadd_of_nonpos_of_le (x : P) (v : V) {r₁ r₂ : R} (hr₁ : r₁ ≤ 0)
    (hr₂ : r₂ ≤ r₁) : Wbtw R x (r₁ • v +ᵥ x) (r₂ • v +ᵥ x) := by
  convert
      wbtw_smul_vadd_smul_vadd_of_nonneg_of_le x (-v) (Left.nonneg_neg_iff.2 hr₁)
        (neg_le_neg_iff.2 hr₂) using
      1 <;>
    rw [neg_smul_neg]
#align wbtw_smul_vadd_smul_vadd_of_nonpos_of_le wbtw_smul_vadd_smul_vadd_of_nonpos_of_le
-/

#print wbtw_or_wbtw_smul_vadd_of_nonpos /-
theorem wbtw_or_wbtw_smul_vadd_of_nonpos (x : P) (v : V) {r₁ r₂ : R} (hr₁ : r₁ ≤ 0) (hr₂ : r₂ ≤ 0) :
    Wbtw R x (r₁ • v +ᵥ x) (r₂ • v +ᵥ x) ∨ Wbtw R x (r₂ • v +ᵥ x) (r₁ • v +ᵥ x) :=
  by
  rcases le_total r₁ r₂ with (h | h)
  · exact Or.inr (wbtw_smul_vadd_smul_vadd_of_nonpos_of_le x v hr₂ h)
  · exact Or.inl (wbtw_smul_vadd_smul_vadd_of_nonpos_of_le x v hr₁ h)
#align wbtw_or_wbtw_smul_vadd_of_nonpos wbtw_or_wbtw_smul_vadd_of_nonpos
-/

#print wbtw_smul_vadd_smul_vadd_of_nonpos_of_nonneg /-
theorem wbtw_smul_vadd_smul_vadd_of_nonpos_of_nonneg (x : P) (v : V) {r₁ r₂ : R} (hr₁ : r₁ ≤ 0)
    (hr₂ : 0 ≤ r₂) : Wbtw R (r₁ • v +ᵥ x) x (r₂ • v +ᵥ x) := by
  convert
      wbtw_smul_vadd_smul_vadd_of_nonneg_of_le (r₁ • v +ᵥ x) v (Left.nonneg_neg_iff.2 hr₁)
        (neg_le_sub_iff_le_add.2 ((le_add_iff_nonneg_left r₁).2 hr₂)) using
      1 <;>
    simp [sub_smul, ← add_vadd]
#align wbtw_smul_vadd_smul_vadd_of_nonpos_of_nonneg wbtw_smul_vadd_smul_vadd_of_nonpos_of_nonneg
-/

#print wbtw_smul_vadd_smul_vadd_of_nonneg_of_nonpos /-
theorem wbtw_smul_vadd_smul_vadd_of_nonneg_of_nonpos (x : P) (v : V) {r₁ r₂ : R} (hr₁ : 0 ≤ r₁)
    (hr₂ : r₂ ≤ 0) : Wbtw R (r₁ • v +ᵥ x) x (r₂ • v +ᵥ x) :=
  by
  rw [wbtw_comm]
  exact wbtw_smul_vadd_smul_vadd_of_nonpos_of_nonneg x v hr₂ hr₁
#align wbtw_smul_vadd_smul_vadd_of_nonneg_of_nonpos wbtw_smul_vadd_smul_vadd_of_nonneg_of_nonpos
-/

#print Wbtw.trans_left_right /-
theorem Wbtw.trans_left_right {w x y z : P} (h₁ : Wbtw R w y z) (h₂ : Wbtw R w x y) :
    Wbtw R x y z := by
  rcases h₁ with ⟨t₁, ht₁, rfl⟩
  rcases h₂ with ⟨t₂, ht₂, rfl⟩
  refine'
    ⟨(t₁ - t₂ * t₁) / (1 - t₂ * t₁),
      ⟨div_nonneg (sub_nonneg.2 (mul_le_of_le_one_left ht₁.1 ht₂.2))
          (sub_nonneg.2 (mul_le_one ht₂.2 ht₁.1 ht₁.2)),
        div_le_one_of_le (sub_le_sub_right ht₁.2 _) (sub_nonneg.2 (mul_le_one ht₂.2 ht₁.1 ht₁.2))⟩,
      _⟩
  simp only [line_map_apply, smul_smul, ← add_vadd, vsub_vadd_eq_vsub_sub, smul_sub, ← sub_smul, ←
    add_smul, vadd_vsub, vadd_right_cancel_iff, div_mul_eq_mul_div, div_sub_div_same]
  nth_rw 1 [← mul_one (t₁ - t₂ * t₁)]
  rw [← mul_sub, mul_div_assoc]
  by_cases h : 1 - t₂ * t₁ = 0
  · rw [sub_eq_zero, eq_comm] at h 
    rw [h]
    suffices t₁ = 1 by simp [this]
    exact
      eq_of_le_of_not_lt ht₁.2 fun ht₁lt =>
        (mul_lt_one_of_nonneg_of_lt_one_right ht₂.2 ht₁.1 ht₁lt).Ne h
  · rw [div_self h]
    ring_nf
#align wbtw.trans_left_right Wbtw.trans_left_right
-/

#print Wbtw.trans_right_left /-
theorem Wbtw.trans_right_left {w x y z : P} (h₁ : Wbtw R w x z) (h₂ : Wbtw R x y z) :
    Wbtw R w x y := by
  rw [wbtw_comm] at *
  exact h₁.trans_left_right h₂
#align wbtw.trans_right_left Wbtw.trans_right_left
-/

#print Sbtw.trans_left_right /-
theorem Sbtw.trans_left_right {w x y z : P} (h₁ : Sbtw R w y z) (h₂ : Sbtw R w x y) :
    Sbtw R x y z :=
  ⟨h₁.Wbtw.trans_left_right h₂.Wbtw, h₂.right_ne, h₁.ne_right⟩
#align sbtw.trans_left_right Sbtw.trans_left_right
-/

#print Sbtw.trans_right_left /-
theorem Sbtw.trans_right_left {w x y z : P} (h₁ : Sbtw R w x z) (h₂ : Sbtw R x y z) :
    Sbtw R w x y :=
  ⟨h₁.Wbtw.trans_right_left h₂.Wbtw, h₁.ne_left, h₂.left_ne⟩
#align sbtw.trans_right_left Sbtw.trans_right_left
-/

#print Wbtw.collinear /-
theorem Wbtw.collinear {x y z : P} (h : Wbtw R x y z) : Collinear R ({x, y, z} : Set P) :=
  by
  rw [collinear_iff_exists_forall_eq_smul_vadd]
  refine' ⟨x, z -ᵥ x, _⟩
  intro p hp
  simp_rw [Set.mem_insert_iff, Set.mem_singleton_iff] at hp 
  rcases hp with (rfl | rfl | rfl)
  · refine' ⟨0, _⟩; simp
  · rcases h with ⟨t, -, rfl⟩
    exact ⟨t, rfl⟩
  · refine' ⟨1, _⟩; simp
#align wbtw.collinear Wbtw.collinear
-/

#print Collinear.wbtw_or_wbtw_or_wbtw /-
theorem Collinear.wbtw_or_wbtw_or_wbtw {x y z : P} (h : Collinear R ({x, y, z} : Set P)) :
    Wbtw R x y z ∨ Wbtw R y z x ∨ Wbtw R z x y :=
  by
  rw [collinear_iff_of_mem (Set.mem_insert _ _)] at h 
  rcases h with ⟨v, h⟩
  simp_rw [Set.mem_insert_iff, Set.mem_singleton_iff] at h 
  have hy := h y (Or.inr (Or.inl rfl))
  have hz := h z (Or.inr (Or.inr rfl))
  rcases hy with ⟨ty, rfl⟩
  rcases hz with ⟨tz, rfl⟩
  rcases lt_trichotomy ty 0 with (hy0 | rfl | hy0)
  · rcases lt_trichotomy tz 0 with (hz0 | rfl | hz0)
    · nth_rw 2 [wbtw_comm]
      rw [← or_assoc']
      exact Or.inl (wbtw_or_wbtw_smul_vadd_of_nonpos _ _ hy0.le hz0.le)
    · simp
    · exact Or.inr (Or.inr (wbtw_smul_vadd_smul_vadd_of_nonneg_of_nonpos _ _ hz0.le hy0.le))
  · simp
  · rcases lt_trichotomy tz 0 with (hz0 | rfl | hz0)
    · refine' Or.inr (Or.inr (wbtw_smul_vadd_smul_vadd_of_nonpos_of_nonneg _ _ hz0.le hy0.le))
    · simp
    · nth_rw 2 [wbtw_comm]
      rw [← or_assoc']
      exact Or.inl (wbtw_or_wbtw_smul_vadd_of_nonneg _ _ hy0.le hz0.le)
#align collinear.wbtw_or_wbtw_or_wbtw Collinear.wbtw_or_wbtw_or_wbtw
-/

#print wbtw_iff_sameRay_vsub /-
theorem wbtw_iff_sameRay_vsub {x y z : P} : Wbtw R x y z ↔ SameRay R (y -ᵥ x) (z -ᵥ y) :=
  by
  refine' ⟨Wbtw.sameRay_vsub, fun h => _⟩
  rcases h with (h | h | ⟨r₁, r₂, hr₁, hr₂, h⟩)
  · rw [vsub_eq_zero_iff_eq] at h ; simp [h]
  · rw [vsub_eq_zero_iff_eq] at h ; simp [h]
  · refine'
      ⟨r₂ / (r₁ + r₂),
        ⟨div_nonneg hr₂.le (add_nonneg hr₁.le hr₂.le),
          div_le_one_of_le (le_add_of_nonneg_left hr₁.le) (add_nonneg hr₁.le hr₂.le)⟩,
        _⟩
    have h' : z = r₂⁻¹ • r₁ • (y -ᵥ x) +ᵥ y := by simp [h, hr₂.ne']
    rw [eq_comm]
    simp only [line_map_apply, h', vadd_vsub_assoc, smul_smul, ← add_smul, eq_vadd_iff_vsub_eq,
      smul_add]
    convert (one_smul _ _).symm
    field_simp [(add_pos hr₁ hr₂).ne', hr₂.ne']
    ring
#align wbtw_iff_same_ray_vsub wbtw_iff_sameRay_vsub
-/

variable (R)

#print wbtw_pointReflection /-
theorem wbtw_pointReflection (x y : P) : Wbtw R y x (pointReflection R x y) :=
  by
  refine' ⟨2⁻¹, ⟨by norm_num, by norm_num⟩, _⟩
  rw [line_map_apply, point_reflection_apply, vadd_vsub_assoc, ← two_smul R (x -ᵥ y)]
  simp
#align wbtw_point_reflection wbtw_pointReflection
-/

#print sbtw_pointReflection_of_ne /-
theorem sbtw_pointReflection_of_ne {x y : P} (h : x ≠ y) : Sbtw R y x (pointReflection R x y) :=
  by
  refine' ⟨wbtw_pointReflection _ _ _, h, _⟩
  nth_rw 1 [← point_reflection_self R x]
  exact (point_reflection_involutive R x).Injective.Ne h
#align sbtw_point_reflection_of_ne sbtw_pointReflection_of_ne
-/

#print wbtw_midpoint /-
theorem wbtw_midpoint (x y : P) : Wbtw R x (midpoint R x y) y := by
  convert wbtw_pointReflection R (midpoint R x y) x; simp
#align wbtw_midpoint wbtw_midpoint
-/

#print sbtw_midpoint_of_ne /-
theorem sbtw_midpoint_of_ne {x y : P} (h : x ≠ y) : Sbtw R x (midpoint R x y) y :=
  by
  have h : midpoint R x y ≠ x := by simp [h]
  convert sbtw_pointReflection_of_ne R h
  simp
#align sbtw_midpoint_of_ne sbtw_midpoint_of_ne
-/

end LinearOrderedField

