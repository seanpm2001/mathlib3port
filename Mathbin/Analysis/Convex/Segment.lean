/-
Copyright (c) 2019 Alexander Bentkamp. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alexander Bentkamp, Yury Kudryashov, Yaël Dillies

! This file was ported from Lean 3 source module analysis.convex.segment
! leanprover-community/mathlib commit cb3ceec8485239a61ed51d944cb9a95b68c6bafc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Invertible
import Mathbin.Algebra.Order.Smul
import Mathbin.LinearAlgebra.AffineSpace.Midpoint
import Mathbin.LinearAlgebra.Ray
import Mathbin.Tactic.Positivity

/-!
# Segments in vector spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In a 𝕜-vector space, we define the following objects and properties.
* `segment 𝕜 x y`: Closed segment joining `x` and `y`.
* `open_segment 𝕜 x y`: Open segment joining `x` and `y`.

## Notations

We provide the following notation:
* `[x -[𝕜] y] = segment 𝕜 x y` in locale `convex`

## TODO

Generalize all this file to affine spaces.

Should we rename `segment` and `open_segment` to `convex.Icc` and `convex.Ioo`? Should we also
define `clopen_segment`/`convex.Ico`/`convex.Ioc`?
-/


variable {𝕜 E F G ι : Type _} {π : ι → Type _}

open Function Set

open scoped Pointwise

section OrderedSemiring

variable [OrderedSemiring 𝕜] [AddCommMonoid E]

section SMul

variable (𝕜) [SMul 𝕜 E] {s : Set E} {x y : E}

#print segment /-
/-- Segments in a vector space. -/
def segment (x y : E) : Set E :=
  {z : E | ∃ (a b : 𝕜) (ha : 0 ≤ a) (hb : 0 ≤ b) (hab : a + b = 1), a • x + b • y = z}
#align segment segment
-/

#print openSegment /-
/-- Open segment in a vector space. Note that `open_segment 𝕜 x x = {x}` instead of being `∅` when
the base semiring has some element between `0` and `1`. -/
def openSegment (x y : E) : Set E :=
  {z : E | ∃ (a b : 𝕜) (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1), a • x + b • y = z}
#align open_segment openSegment
-/

scoped[Convex] notation "[" x " -[" 𝕜 "] " y "]" => segment 𝕜 x y

#print segment_eq_image₂ /-
theorem segment_eq_image₂ (x y : E) :
    [x -[𝕜] y] = (fun p : 𝕜 × 𝕜 => p.1 • x + p.2 • y) '' {p | 0 ≤ p.1 ∧ 0 ≤ p.2 ∧ p.1 + p.2 = 1} :=
  by simp only [segment, image, Prod.exists, mem_set_of_eq, exists_prop, and_assoc']
#align segment_eq_image₂ segment_eq_image₂
-/

#print openSegment_eq_image₂ /-
theorem openSegment_eq_image₂ (x y : E) :
    openSegment 𝕜 x y =
      (fun p : 𝕜 × 𝕜 => p.1 • x + p.2 • y) '' {p | 0 < p.1 ∧ 0 < p.2 ∧ p.1 + p.2 = 1} :=
  by simp only [openSegment, image, Prod.exists, mem_set_of_eq, exists_prop, and_assoc']
#align open_segment_eq_image₂ openSegment_eq_image₂
-/

#print segment_symm /-
theorem segment_symm (x y : E) : [x -[𝕜] y] = [y -[𝕜] x] :=
  Set.ext fun z =>
    ⟨fun ⟨a, b, ha, hb, hab, H⟩ => ⟨b, a, hb, ha, (add_comm _ _).trans hab, (add_comm _ _).trans H⟩,
      fun ⟨a, b, ha, hb, hab, H⟩ =>
      ⟨b, a, hb, ha, (add_comm _ _).trans hab, (add_comm _ _).trans H⟩⟩
#align segment_symm segment_symm
-/

#print openSegment_symm /-
theorem openSegment_symm (x y : E) : openSegment 𝕜 x y = openSegment 𝕜 y x :=
  Set.ext fun z =>
    ⟨fun ⟨a, b, ha, hb, hab, H⟩ => ⟨b, a, hb, ha, (add_comm _ _).trans hab, (add_comm _ _).trans H⟩,
      fun ⟨a, b, ha, hb, hab, H⟩ =>
      ⟨b, a, hb, ha, (add_comm _ _).trans hab, (add_comm _ _).trans H⟩⟩
#align open_segment_symm openSegment_symm
-/

#print openSegment_subset_segment /-
theorem openSegment_subset_segment (x y : E) : openSegment 𝕜 x y ⊆ [x -[𝕜] y] :=
  fun z ⟨a, b, ha, hb, hab, hz⟩ => ⟨a, b, ha.le, hb.le, hab, hz⟩
#align open_segment_subset_segment openSegment_subset_segment
-/

#print segment_subset_iff /-
theorem segment_subset_iff :
    [x -[𝕜] y] ⊆ s ↔ ∀ a b : 𝕜, 0 ≤ a → 0 ≤ b → a + b = 1 → a • x + b • y ∈ s :=
  ⟨fun H a b ha hb hab => H ⟨a, b, ha, hb, hab, rfl⟩, fun H z ⟨a, b, ha, hb, hab, hz⟩ =>
    hz ▸ H a b ha hb hab⟩
#align segment_subset_iff segment_subset_iff
-/

#print openSegment_subset_iff /-
theorem openSegment_subset_iff :
    openSegment 𝕜 x y ⊆ s ↔ ∀ a b : 𝕜, 0 < a → 0 < b → a + b = 1 → a • x + b • y ∈ s :=
  ⟨fun H a b ha hb hab => H ⟨a, b, ha, hb, hab, rfl⟩, fun H z ⟨a, b, ha, hb, hab, hz⟩ =>
    hz ▸ H a b ha hb hab⟩
#align open_segment_subset_iff openSegment_subset_iff
-/

end SMul

open scoped Convex

section MulActionWithZero

variable (𝕜) [MulActionWithZero 𝕜 E]

#print left_mem_segment /-
theorem left_mem_segment (x y : E) : x ∈ [x -[𝕜] y] :=
  ⟨1, 0, zero_le_one, le_refl 0, add_zero 1, by rw [zero_smul, one_smul, add_zero]⟩
#align left_mem_segment left_mem_segment
-/

#print right_mem_segment /-
theorem right_mem_segment (x y : E) : y ∈ [x -[𝕜] y] :=
  segment_symm 𝕜 y x ▸ left_mem_segment 𝕜 y x
#align right_mem_segment right_mem_segment
-/

end MulActionWithZero

section Module

variable (𝕜) [Module 𝕜 E] {s : Set E} {x y z : E}

#print segment_same /-
@[simp]
theorem segment_same (x : E) : [x -[𝕜] x] = {x} :=
  Set.ext fun z =>
    ⟨fun ⟨a, b, ha, hb, hab, hz⟩ => by
      simpa only [(add_smul _ _ _).symm, mem_singleton_iff, hab, one_smul, eq_comm] using hz,
      fun h => mem_singleton_iff.1 h ▸ left_mem_segment 𝕜 z z⟩
#align segment_same segment_same
-/

#print insert_endpoints_openSegment /-
theorem insert_endpoints_openSegment (x y : E) :
    insert x (insert y (openSegment 𝕜 x y)) = [x -[𝕜] y] :=
  by
  simp only [subset_antisymm_iff, insert_subset, left_mem_segment, right_mem_segment,
    openSegment_subset_segment, true_and_iff]
  rintro z ⟨a, b, ha, hb, hab, rfl⟩
  refine' hb.eq_or_gt.imp _ fun hb' => ha.eq_or_gt.imp _ fun ha' => _
  · rintro rfl
    rw [← add_zero a, hab, one_smul, zero_smul, add_zero]
  · rintro rfl
    rw [← zero_add b, hab, one_smul, zero_smul, zero_add]
  · exact ⟨a, b, ha', hb', hab, rfl⟩
#align insert_endpoints_open_segment insert_endpoints_openSegment
-/

variable {𝕜}

#print mem_openSegment_of_ne_left_right /-
theorem mem_openSegment_of_ne_left_right (hx : x ≠ z) (hy : y ≠ z) (hz : z ∈ [x -[𝕜] y]) :
    z ∈ openSegment 𝕜 x y :=
  by
  rw [← insert_endpoints_openSegment] at hz 
  exact (hz.resolve_left hx.symm).resolve_left hy.symm
#align mem_open_segment_of_ne_left_right mem_openSegment_of_ne_left_right
-/

#print openSegment_subset_iff_segment_subset /-
theorem openSegment_subset_iff_segment_subset (hx : x ∈ s) (hy : y ∈ s) :
    openSegment 𝕜 x y ⊆ s ↔ [x -[𝕜] y] ⊆ s := by
  simp only [← insert_endpoints_openSegment, insert_subset, *, true_and_iff]
#align open_segment_subset_iff_segment_subset openSegment_subset_iff_segment_subset
-/

end Module

end OrderedSemiring

open scoped Convex

section OrderedRing

variable (𝕜) [OrderedRing 𝕜] [AddCommGroup E] [AddCommGroup F] [AddCommGroup G] [Module 𝕜 E]
  [Module 𝕜 F]

section DenselyOrdered

variable [Nontrivial 𝕜] [DenselyOrdered 𝕜]

#print openSegment_same /-
@[simp]
theorem openSegment_same (x : E) : openSegment 𝕜 x x = {x} :=
  Set.ext fun z =>
    ⟨fun ⟨a, b, ha, hb, hab, hz⟩ => by
      simpa only [← add_smul, mem_singleton_iff, hab, one_smul, eq_comm] using hz, fun h : z = x =>
      by
      obtain ⟨a, ha₀, ha₁⟩ := DenselyOrdered.dense (0 : 𝕜) 1 zero_lt_one
      refine' ⟨a, 1 - a, ha₀, sub_pos_of_lt ha₁, add_sub_cancel'_right _ _, _⟩
      rw [← add_smul, add_sub_cancel'_right, one_smul, h]⟩
#align open_segment_same openSegment_same
-/

end DenselyOrdered

#print segment_eq_image /-
theorem segment_eq_image (x y : E) :
    [x -[𝕜] y] = (fun θ : 𝕜 => (1 - θ) • x + θ • y) '' Icc (0 : 𝕜) 1 :=
  Set.ext fun z =>
    ⟨fun ⟨a, b, ha, hb, hab, hz⟩ =>
      ⟨b, ⟨hb, hab ▸ le_add_of_nonneg_left ha⟩, hab ▸ hz ▸ by simp only [add_sub_cancel]⟩,
      fun ⟨θ, ⟨hθ₀, hθ₁⟩, hz⟩ => ⟨1 - θ, θ, sub_nonneg.2 hθ₁, hθ₀, sub_add_cancel _ _, hz⟩⟩
#align segment_eq_image segment_eq_image
-/

#print openSegment_eq_image /-
theorem openSegment_eq_image (x y : E) :
    openSegment 𝕜 x y = (fun θ : 𝕜 => (1 - θ) • x + θ • y) '' Ioo (0 : 𝕜) 1 :=
  Set.ext fun z =>
    ⟨fun ⟨a, b, ha, hb, hab, hz⟩ =>
      ⟨b, ⟨hb, hab ▸ lt_add_of_pos_left _ ha⟩, hab ▸ hz ▸ by simp only [add_sub_cancel]⟩,
      fun ⟨θ, ⟨hθ₀, hθ₁⟩, hz⟩ => ⟨1 - θ, θ, sub_pos.2 hθ₁, hθ₀, sub_add_cancel _ _, hz⟩⟩
#align open_segment_eq_image openSegment_eq_image
-/

#print segment_eq_image' /-
theorem segment_eq_image' (x y : E) :
    [x -[𝕜] y] = (fun θ : 𝕜 => x + θ • (y - x)) '' Icc (0 : 𝕜) 1 := by
  convert segment_eq_image 𝕜 x y; ext θ; simp only [smul_sub, sub_smul, one_smul]; abel
#align segment_eq_image' segment_eq_image'
-/

#print openSegment_eq_image' /-
theorem openSegment_eq_image' (x y : E) :
    openSegment 𝕜 x y = (fun θ : 𝕜 => x + θ • (y - x)) '' Ioo (0 : 𝕜) 1 := by
  convert openSegment_eq_image 𝕜 x y; ext θ; simp only [smul_sub, sub_smul, one_smul]; abel
#align open_segment_eq_image' openSegment_eq_image'
-/

#print segment_eq_image_lineMap /-
theorem segment_eq_image_lineMap (x y : E) : [x -[𝕜] y] = AffineMap.lineMap x y '' Icc (0 : 𝕜) 1 :=
  by convert segment_eq_image 𝕜 x y; ext; exact AffineMap.lineMap_apply_module _ _ _
#align segment_eq_image_line_map segment_eq_image_lineMap
-/

#print openSegment_eq_image_lineMap /-
theorem openSegment_eq_image_lineMap (x y : E) :
    openSegment 𝕜 x y = AffineMap.lineMap x y '' Ioo (0 : 𝕜) 1 := by
  convert openSegment_eq_image 𝕜 x y; ext; exact AffineMap.lineMap_apply_module _ _ _
#align open_segment_eq_image_line_map openSegment_eq_image_lineMap
-/

#print image_segment /-
@[simp]
theorem image_segment (f : E →ᵃ[𝕜] F) (a b : E) : f '' [a -[𝕜] b] = [f a -[𝕜] f b] :=
  Set.ext fun x => by
    simp_rw [segment_eq_image_lineMap, mem_image, exists_exists_and_eq_and, AffineMap.apply_lineMap]
#align image_segment image_segment
-/

#print image_openSegment /-
@[simp]
theorem image_openSegment (f : E →ᵃ[𝕜] F) (a b : E) :
    f '' openSegment 𝕜 a b = openSegment 𝕜 (f a) (f b) :=
  Set.ext fun x => by
    simp_rw [openSegment_eq_image_lineMap, mem_image, exists_exists_and_eq_and,
      AffineMap.apply_lineMap]
#align image_open_segment image_openSegment
-/

#print vadd_segment /-
@[simp]
theorem vadd_segment [AddTorsor G E] [VAddCommClass G E E] (a : G) (b c : E) :
    a +ᵥ [b -[𝕜] c] = [a +ᵥ b -[𝕜] a +ᵥ c] :=
  image_segment 𝕜 ⟨_, LinearMap.id, fun _ _ => vadd_comm _ _ _⟩ b c
#align vadd_segment vadd_segment
-/

#print vadd_openSegment /-
@[simp]
theorem vadd_openSegment [AddTorsor G E] [VAddCommClass G E E] (a : G) (b c : E) :
    a +ᵥ openSegment 𝕜 b c = openSegment 𝕜 (a +ᵥ b) (a +ᵥ c) :=
  image_openSegment 𝕜 ⟨_, LinearMap.id, fun _ _ => vadd_comm _ _ _⟩ b c
#align vadd_open_segment vadd_openSegment
-/

#print mem_segment_translate /-
@[simp]
theorem mem_segment_translate (a : E) {x b c} : a + x ∈ [a + b -[𝕜] a + c] ↔ x ∈ [b -[𝕜] c] := by
  simp_rw [← vadd_eq_add, ← vadd_segment, vadd_mem_vadd_set_iff]
#align mem_segment_translate mem_segment_translate
-/

#print mem_openSegment_translate /-
@[simp]
theorem mem_openSegment_translate (a : E) {x b c : E} :
    a + x ∈ openSegment 𝕜 (a + b) (a + c) ↔ x ∈ openSegment 𝕜 b c := by
  simp_rw [← vadd_eq_add, ← vadd_openSegment, vadd_mem_vadd_set_iff]
#align mem_open_segment_translate mem_openSegment_translate
-/

#print segment_translate_preimage /-
theorem segment_translate_preimage (a b c : E) :
    (fun x => a + x) ⁻¹' [a + b -[𝕜] a + c] = [b -[𝕜] c] :=
  Set.ext fun x => mem_segment_translate 𝕜 a
#align segment_translate_preimage segment_translate_preimage
-/

#print openSegment_translate_preimage /-
theorem openSegment_translate_preimage (a b c : E) :
    (fun x => a + x) ⁻¹' openSegment 𝕜 (a + b) (a + c) = openSegment 𝕜 b c :=
  Set.ext fun x => mem_openSegment_translate 𝕜 a
#align open_segment_translate_preimage openSegment_translate_preimage
-/

#print segment_translate_image /-
theorem segment_translate_image (a b c : E) : (fun x => a + x) '' [b -[𝕜] c] = [a + b -[𝕜] a + c] :=
  segment_translate_preimage 𝕜 a b c ▸ image_preimage_eq _ <| add_left_surjective a
#align segment_translate_image segment_translate_image
-/

#print openSegment_translate_image /-
theorem openSegment_translate_image (a b c : E) :
    (fun x => a + x) '' openSegment 𝕜 b c = openSegment 𝕜 (a + b) (a + c) :=
  openSegment_translate_preimage 𝕜 a b c ▸ image_preimage_eq _ <| add_left_surjective a
#align open_segment_translate_image openSegment_translate_image
-/

end OrderedRing

#print sameRay_of_mem_segment /-
theorem sameRay_of_mem_segment [StrictOrderedCommRing 𝕜] [AddCommGroup E] [Module 𝕜 E] {x y z : E}
    (h : x ∈ [y -[𝕜] z]) : SameRay 𝕜 (x - y) (z - x) :=
  by
  rw [segment_eq_image'] at h 
  rcases h with ⟨θ, ⟨hθ₀, hθ₁⟩, rfl⟩
  simpa only [add_sub_cancel', ← sub_sub, sub_smul, one_smul] using
    (SameRay.sameRay_nonneg_smul_left (z - y) hθ₀).nonneg_smul_right (sub_nonneg.2 hθ₁)
#align same_ray_of_mem_segment sameRay_of_mem_segment
-/

section LinearOrderedRing

variable [LinearOrderedRing 𝕜] [AddCommGroup E] [Module 𝕜 E] {x y : E}

#print midpoint_mem_segment /-
theorem midpoint_mem_segment [Invertible (2 : 𝕜)] (x y : E) : midpoint 𝕜 x y ∈ [x -[𝕜] y] :=
  by
  rw [segment_eq_image_lineMap]
  exact ⟨⅟ 2, ⟨inv_of_nonneg.mpr zero_le_two, invOf_le_one one_le_two⟩, rfl⟩
#align midpoint_mem_segment midpoint_mem_segment
-/

#print mem_segment_sub_add /-
theorem mem_segment_sub_add [Invertible (2 : 𝕜)] (x y : E) : x ∈ [x - y -[𝕜] x + y] := by
  convert @midpoint_mem_segment 𝕜 _ _ _ _ _ _ _; rw [midpoint_sub_add]
#align mem_segment_sub_add mem_segment_sub_add
-/

#print mem_segment_add_sub /-
theorem mem_segment_add_sub [Invertible (2 : 𝕜)] (x y : E) : x ∈ [x + y -[𝕜] x - y] := by
  convert @midpoint_mem_segment 𝕜 _ _ _ _ _ _ _; rw [midpoint_add_sub]
#align mem_segment_add_sub mem_segment_add_sub
-/

#print left_mem_openSegment_iff /-
@[simp]
theorem left_mem_openSegment_iff [DenselyOrdered 𝕜] [NoZeroSMulDivisors 𝕜 E] :
    x ∈ openSegment 𝕜 x y ↔ x = y := by
  constructor
  · rintro ⟨a, b, ha, hb, hab, hx⟩
    refine' smul_right_injective _ hb.ne' ((add_right_inj (a • x)).1 _)
    rw [hx, ← add_smul, hab, one_smul]
  · rintro rfl
    rw [openSegment_same]
    exact mem_singleton _
#align left_mem_open_segment_iff left_mem_openSegment_iff
-/

#print right_mem_openSegment_iff /-
@[simp]
theorem right_mem_openSegment_iff [DenselyOrdered 𝕜] [NoZeroSMulDivisors 𝕜 E] :
    y ∈ openSegment 𝕜 x y ↔ x = y := by rw [openSegment_symm, left_mem_openSegment_iff, eq_comm]
#align right_mem_open_segment_iff right_mem_openSegment_iff
-/

end LinearOrderedRing

section LinearOrderedSemifield

variable [LinearOrderedSemifield 𝕜] [AddCommGroup E] [Module 𝕜 E] {x y z : E}

#print mem_segment_iff_div /-
theorem mem_segment_iff_div :
    x ∈ [y -[𝕜] z] ↔
      ∃ a b : 𝕜, 0 ≤ a ∧ 0 ≤ b ∧ 0 < a + b ∧ (a / (a + b)) • y + (b / (a + b)) • z = x :=
  by
  constructor
  · rintro ⟨a, b, ha, hb, hab, rfl⟩
    use a, b, ha, hb
    simp [*]
  · rintro ⟨a, b, ha, hb, hab, rfl⟩
    refine' ⟨a / (a + b), b / (a + b), div_nonneg ha hab.le, div_nonneg hb hab.le, _, rfl⟩
    rw [← add_div, div_self hab.ne']
#align mem_segment_iff_div mem_segment_iff_div
-/

#print mem_openSegment_iff_div /-
theorem mem_openSegment_iff_div :
    x ∈ openSegment 𝕜 y z ↔ ∃ a b : 𝕜, 0 < a ∧ 0 < b ∧ (a / (a + b)) • y + (b / (a + b)) • z = x :=
  by
  constructor
  · rintro ⟨a, b, ha, hb, hab, rfl⟩
    use a, b, ha, hb
    rw [hab, div_one, div_one]
  · rintro ⟨a, b, ha, hb, rfl⟩
    have hab : 0 < a + b := by positivity
    refine' ⟨a / (a + b), b / (a + b), by positivity, by positivity, _, rfl⟩
    rw [← add_div, div_self hab.ne']
#align mem_open_segment_iff_div mem_openSegment_iff_div
-/

end LinearOrderedSemifield

section LinearOrderedField

variable [LinearOrderedField 𝕜] [AddCommGroup E] [Module 𝕜 E] {x y z : E}

#print mem_segment_iff_sameRay /-
theorem mem_segment_iff_sameRay : x ∈ [y -[𝕜] z] ↔ SameRay 𝕜 (x - y) (z - x) :=
  by
  refine' ⟨sameRay_of_mem_segment, fun h => _⟩
  rcases h.exists_eq_smul_add with ⟨a, b, ha, hb, hab, hxy, hzx⟩
  rw [add_comm, sub_add_sub_cancel] at hxy hzx 
  rw [← mem_segment_translate _ (-x), neg_add_self]
  refine' ⟨b, a, hb, ha, add_comm a b ▸ hab, _⟩
  rw [← sub_eq_neg_add, ← neg_sub, hxy, ← sub_eq_neg_add, hzx, smul_neg, smul_comm, neg_add_self]
#align mem_segment_iff_same_ray mem_segment_iff_sameRay
-/

open AffineMap

#print openSegment_subset_union /-
/-- If `z = line_map x y c` is a point on the line passing through `x` and `y`, then the open
segment `open_segment 𝕜 x y` is included in the union of the open segments `open_segment 𝕜 x z`,
`open_segment 𝕜 z y`, and the point `z`. Informally, `(x, y) ⊆ {z} ∪ (x, z) ∪ (z, y)`. -/
theorem openSegment_subset_union (x y : E) {z : E} (hz : z ∈ range (lineMap x y : 𝕜 → E)) :
    openSegment 𝕜 x y ⊆ insert z (openSegment 𝕜 x z ∪ openSegment 𝕜 z y) :=
  by
  rcases hz with ⟨c, rfl⟩
  simp only [openSegment_eq_image_lineMap, ← maps_to']
  rintro a ⟨h₀, h₁⟩
  rcases lt_trichotomy a c with (hac | rfl | hca)
  · right; left
    have hc : 0 < c := h₀.trans hac
    refine' ⟨a / c, ⟨div_pos h₀ hc, (div_lt_one hc).2 hac⟩, _⟩
    simp only [← homothety_eq_line_map, ← homothety_mul_apply, div_mul_cancel _ hc.ne']
  · left; rfl
  · right; right
    have hc : 0 < 1 - c := sub_pos.2 (hca.trans h₁)
    simp only [← line_map_apply_one_sub y]
    refine'
      ⟨(a - c) / (1 - c), ⟨div_pos (sub_pos.2 hca) hc, (div_lt_one hc).2 <| sub_lt_sub_right h₁ _⟩,
        _⟩
    simp only [← homothety_eq_line_map, ← homothety_mul_apply, sub_mul, one_mul,
      div_mul_cancel _ hc.ne', sub_sub_sub_cancel_right]
#align open_segment_subset_union openSegment_subset_union
-/

end LinearOrderedField

/-!
#### Segments in an ordered space

Relates `segment`, `open_segment` and `set.Icc`, `set.Ico`, `set.Ioc`, `set.Ioo`
-/


section OrderedSemiring

variable [OrderedSemiring 𝕜]

section OrderedAddCommMonoid

variable [OrderedAddCommMonoid E] [Module 𝕜 E] [OrderedSMul 𝕜 E] {x y : E}

#print segment_subset_Icc /-
theorem segment_subset_Icc (h : x ≤ y) : [x -[𝕜] y] ⊆ Icc x y :=
  by
  rintro z ⟨a, b, ha, hb, hab, rfl⟩
  constructor
  calc
    x = a • x + b • x := (Convex.combo_self hab _).symm
    _ ≤ a • x + b • y := add_le_add_left (smul_le_smul_of_nonneg h hb) _
  calc
    a • x + b • y ≤ a • y + b • y := add_le_add_right (smul_le_smul_of_nonneg h ha) _
    _ = y := Convex.combo_self hab _
#align segment_subset_Icc segment_subset_Icc
-/

end OrderedAddCommMonoid

section OrderedCancelAddCommMonoid

variable [OrderedCancelAddCommMonoid E] [Module 𝕜 E] [OrderedSMul 𝕜 E] {x y : E}

#print openSegment_subset_Ioo /-
theorem openSegment_subset_Ioo (h : x < y) : openSegment 𝕜 x y ⊆ Ioo x y :=
  by
  rintro z ⟨a, b, ha, hb, hab, rfl⟩
  constructor
  calc
    x = a • x + b • x := (Convex.combo_self hab _).symm
    _ < a • x + b • y := add_lt_add_left (smul_lt_smul_of_pos h hb) _
  calc
    a • x + b • y < a • y + b • y := add_lt_add_right (smul_lt_smul_of_pos h ha) _
    _ = y := Convex.combo_self hab _
#align open_segment_subset_Ioo openSegment_subset_Ioo
-/

end OrderedCancelAddCommMonoid

section LinearOrderedAddCommMonoid

variable [LinearOrderedAddCommMonoid E] [Module 𝕜 E] [OrderedSMul 𝕜 E] {𝕜} {a b : 𝕜}

#print segment_subset_uIcc /-
theorem segment_subset_uIcc (x y : E) : [x -[𝕜] y] ⊆ uIcc x y :=
  by
  cases le_total x y
  · rw [uIcc_of_le h]
    exact segment_subset_Icc h
  · rw [uIcc_of_ge h, segment_symm]
    exact segment_subset_Icc h
#align segment_subset_uIcc segment_subset_uIcc
-/

#print Convex.min_le_combo /-
theorem Convex.min_le_combo (x y : E) (ha : 0 ≤ a) (hb : 0 ≤ b) (hab : a + b = 1) :
    min x y ≤ a • x + b • y :=
  (segment_subset_uIcc x y ⟨_, _, ha, hb, hab, rfl⟩).1
#align convex.min_le_combo Convex.min_le_combo
-/

#print Convex.combo_le_max /-
theorem Convex.combo_le_max (x y : E) (ha : 0 ≤ a) (hb : 0 ≤ b) (hab : a + b = 1) :
    a • x + b • y ≤ max x y :=
  (segment_subset_uIcc x y ⟨_, _, ha, hb, hab, rfl⟩).2
#align convex.combo_le_max Convex.combo_le_max
-/

end LinearOrderedAddCommMonoid

end OrderedSemiring

section LinearOrderedField

variable [LinearOrderedField 𝕜] {x y z : 𝕜}

#print Icc_subset_segment /-
theorem Icc_subset_segment : Icc x y ⊆ [x -[𝕜] y] :=
  by
  rintro z ⟨hxz, hyz⟩
  obtain rfl | h := (hxz.trans hyz).eq_or_lt
  · rw [segment_same]
    exact hyz.antisymm hxz
  rw [← sub_nonneg] at hxz hyz 
  rw [← sub_pos] at h 
  refine' ⟨(y - z) / (y - x), (z - x) / (y - x), div_nonneg hyz h.le, div_nonneg hxz h.le, _, _⟩
  · rw [← add_div, sub_add_sub_cancel, div_self h.ne']
  ·
    rw [smul_eq_mul, smul_eq_mul, ← mul_div_right_comm, ← mul_div_right_comm, ← add_div,
      div_eq_iff h.ne', add_comm, sub_mul, sub_mul, mul_comm x, sub_add_sub_cancel, mul_sub]
#align Icc_subset_segment Icc_subset_segment
-/

#print segment_eq_Icc /-
@[simp]
theorem segment_eq_Icc (h : x ≤ y) : [x -[𝕜] y] = Icc x y :=
  (segment_subset_Icc h).antisymm Icc_subset_segment
#align segment_eq_Icc segment_eq_Icc
-/

#print Ioo_subset_openSegment /-
theorem Ioo_subset_openSegment : Ioo x y ⊆ openSegment 𝕜 x y := fun z hz =>
  mem_openSegment_of_ne_left_right hz.1.Ne hz.2.ne' <| Icc_subset_segment <| Ioo_subset_Icc_self hz
#align Ioo_subset_open_segment Ioo_subset_openSegment
-/

#print openSegment_eq_Ioo /-
@[simp]
theorem openSegment_eq_Ioo (h : x < y) : openSegment 𝕜 x y = Ioo x y :=
  (openSegment_subset_Ioo h).antisymm Ioo_subset_openSegment
#align open_segment_eq_Ioo openSegment_eq_Ioo
-/

#print segment_eq_Icc' /-
theorem segment_eq_Icc' (x y : 𝕜) : [x -[𝕜] y] = Icc (min x y) (max x y) :=
  by
  cases le_total x y
  · rw [segment_eq_Icc h, max_eq_right h, min_eq_left h]
  · rw [segment_symm, segment_eq_Icc h, max_eq_left h, min_eq_right h]
#align segment_eq_Icc' segment_eq_Icc'
-/

#print openSegment_eq_Ioo' /-
theorem openSegment_eq_Ioo' (hxy : x ≠ y) : openSegment 𝕜 x y = Ioo (min x y) (max x y) :=
  by
  cases hxy.lt_or_lt
  · rw [openSegment_eq_Ioo h, max_eq_right h.le, min_eq_left h.le]
  · rw [openSegment_symm, openSegment_eq_Ioo h, max_eq_left h.le, min_eq_right h.le]
#align open_segment_eq_Ioo' openSegment_eq_Ioo'
-/

#print segment_eq_uIcc /-
theorem segment_eq_uIcc (x y : 𝕜) : [x -[𝕜] y] = uIcc x y :=
  segment_eq_Icc' _ _
#align segment_eq_uIcc segment_eq_uIcc
-/

#print Convex.mem_Icc /-
/-- A point is in an `Icc` iff it can be expressed as a convex combination of the endpoints. -/
theorem Convex.mem_Icc (h : x ≤ y) :
    z ∈ Icc x y ↔ ∃ a b, 0 ≤ a ∧ 0 ≤ b ∧ a + b = 1 ∧ a * x + b * y = z := by
  rw [← segment_eq_Icc h]; simp_rw [← exists_prop]; rfl
#align convex.mem_Icc Convex.mem_Icc
-/

#print Convex.mem_Ioo /-
/-- A point is in an `Ioo` iff it can be expressed as a strict convex combination of the endpoints.
-/
theorem Convex.mem_Ioo (h : x < y) :
    z ∈ Ioo x y ↔ ∃ a b, 0 < a ∧ 0 < b ∧ a + b = 1 ∧ a * x + b * y = z := by
  rw [← openSegment_eq_Ioo h]; simp_rw [← exists_prop]; rfl
#align convex.mem_Ioo Convex.mem_Ioo
-/

#print Convex.mem_Ioc /-
/-- A point is in an `Ioc` iff it can be expressed as a semistrict convex combination of the
endpoints. -/
theorem Convex.mem_Ioc (h : x < y) :
    z ∈ Ioc x y ↔ ∃ a b, 0 ≤ a ∧ 0 < b ∧ a + b = 1 ∧ a * x + b * y = z :=
  by
  refine' ⟨fun hz => _, _⟩
  · obtain ⟨a, b, ha, hb, hab, rfl⟩ := (Convex.mem_Icc h.le).1 (Ioc_subset_Icc_self hz)
    obtain rfl | hb' := hb.eq_or_lt
    · rw [add_zero] at hab 
      rw [hab, one_mul, MulZeroClass.zero_mul, add_zero] at hz 
      exact (hz.1.Ne rfl).elim
    · exact ⟨a, b, ha, hb', hab, rfl⟩
  · rintro ⟨a, b, ha, hb, hab, rfl⟩
    obtain rfl | ha' := ha.eq_or_lt
    · rw [zero_add] at hab 
      rwa [hab, one_mul, MulZeroClass.zero_mul, zero_add, right_mem_Ioc]
    · exact Ioo_subset_Ioc_self ((Convex.mem_Ioo h).2 ⟨a, b, ha', hb, hab, rfl⟩)
#align convex.mem_Ioc Convex.mem_Ioc
-/

#print Convex.mem_Ico /-
/-- A point is in an `Ico` iff it can be expressed as a semistrict convex combination of the
endpoints. -/
theorem Convex.mem_Ico (h : x < y) :
    z ∈ Ico x y ↔ ∃ a b, 0 < a ∧ 0 ≤ b ∧ a + b = 1 ∧ a * x + b * y = z :=
  by
  refine' ⟨fun hz => _, _⟩
  · obtain ⟨a, b, ha, hb, hab, rfl⟩ := (Convex.mem_Icc h.le).1 (Ico_subset_Icc_self hz)
    obtain rfl | ha' := ha.eq_or_lt
    · rw [zero_add] at hab 
      rw [hab, one_mul, MulZeroClass.zero_mul, zero_add] at hz 
      exact (hz.2.Ne rfl).elim
    · exact ⟨a, b, ha', hb, hab, rfl⟩
  · rintro ⟨a, b, ha, hb, hab, rfl⟩
    obtain rfl | hb' := hb.eq_or_lt
    · rw [add_zero] at hab 
      rwa [hab, one_mul, MulZeroClass.zero_mul, add_zero, left_mem_Ico]
    · exact Ioo_subset_Ico_self ((Convex.mem_Ioo h).2 ⟨a, b, ha, hb', hab, rfl⟩)
#align convex.mem_Ico Convex.mem_Ico
-/

end LinearOrderedField

namespace Prod

variable [OrderedSemiring 𝕜] [AddCommMonoid E] [AddCommMonoid F] [Module 𝕜 E] [Module 𝕜 F]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Prod.segment_subset /-
theorem segment_subset (x y : E × F) : segment 𝕜 x y ⊆ segment 𝕜 x.1 y.1 ×ˢ segment 𝕜 x.2 y.2 :=
  by
  rintro z ⟨a, b, ha, hb, hab, hz⟩
  exact ⟨⟨a, b, ha, hb, hab, congr_arg Prod.fst hz⟩, a, b, ha, hb, hab, congr_arg Prod.snd hz⟩
#align prod.segment_subset Prod.segment_subset
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Prod.openSegment_subset /-
theorem openSegment_subset (x y : E × F) :
    openSegment 𝕜 x y ⊆ openSegment 𝕜 x.1 y.1 ×ˢ openSegment 𝕜 x.2 y.2 :=
  by
  rintro z ⟨a, b, ha, hb, hab, hz⟩
  exact ⟨⟨a, b, ha, hb, hab, congr_arg Prod.fst hz⟩, a, b, ha, hb, hab, congr_arg Prod.snd hz⟩
#align prod.open_segment_subset Prod.openSegment_subset
-/

#print Prod.image_mk_segment_left /-
theorem image_mk_segment_left (x₁ x₂ : E) (y : F) :
    (fun x => (x, y)) '' [x₁ -[𝕜] x₂] = [(x₁, y) -[𝕜] (x₂, y)] :=
  by
  ext ⟨x', y'⟩
  simp_rw [Set.mem_image, segment, Set.mem_setOf, Prod.smul_mk, Prod.mk_add_mk, Prod.mk.inj_iff, ←
    exists_and_right, @exists_comm E, exists_eq_left']
  refine' exists₅_congr fun a b ha hb hab => _
  rw [Convex.combo_self hab]
#align prod.image_mk_segment_left Prod.image_mk_segment_left
-/

#print Prod.image_mk_segment_right /-
theorem image_mk_segment_right (x : E) (y₁ y₂ : F) :
    (fun y => (x, y)) '' [y₁ -[𝕜] y₂] = [(x, y₁) -[𝕜] (x, y₂)] :=
  by
  ext ⟨x', y'⟩
  simp_rw [Set.mem_image, segment, Set.mem_setOf, Prod.smul_mk, Prod.mk_add_mk, Prod.mk.inj_iff, ←
    exists_and_right, @exists_comm F, exists_eq_left']
  refine' exists₅_congr fun a b ha hb hab => _
  rw [Convex.combo_self hab]
#align prod.image_mk_segment_right Prod.image_mk_segment_right
-/

#print Prod.image_mk_openSegment_left /-
theorem image_mk_openSegment_left (x₁ x₂ : E) (y : F) :
    (fun x => (x, y)) '' openSegment 𝕜 x₁ x₂ = openSegment 𝕜 (x₁, y) (x₂, y) :=
  by
  ext ⟨x', y'⟩
  simp_rw [Set.mem_image, openSegment, Set.mem_setOf, Prod.smul_mk, Prod.mk_add_mk, Prod.mk.inj_iff,
    ← exists_and_right, @exists_comm E, exists_eq_left']
  refine' exists₅_congr fun a b ha hb hab => _
  rw [Convex.combo_self hab]
#align prod.image_mk_open_segment_left Prod.image_mk_openSegment_left
-/

#print Prod.image_mk_openSegment_right /-
@[simp]
theorem image_mk_openSegment_right (x : E) (y₁ y₂ : F) :
    (fun y => (x, y)) '' openSegment 𝕜 y₁ y₂ = openSegment 𝕜 (x, y₁) (x, y₂) :=
  by
  ext ⟨x', y'⟩
  simp_rw [Set.mem_image, openSegment, Set.mem_setOf, Prod.smul_mk, Prod.mk_add_mk, Prod.mk.inj_iff,
    ← exists_and_right, @exists_comm F, exists_eq_left']
  refine' exists₅_congr fun a b ha hb hab => _
  rw [Convex.combo_self hab]
#align prod.image_mk_open_segment_right Prod.image_mk_openSegment_right
-/

end Prod

namespace Pi

variable [OrderedSemiring 𝕜] [∀ i, AddCommMonoid (π i)] [∀ i, Module 𝕜 (π i)] {s : Set ι}

#print Pi.segment_subset /-
theorem segment_subset (x y : ∀ i, π i) : segment 𝕜 x y ⊆ s.pi fun i => segment 𝕜 (x i) (y i) := by
  rintro z ⟨a, b, ha, hb, hab, hz⟩ i -; exact ⟨a, b, ha, hb, hab, congr_fun hz i⟩
#align pi.segment_subset Pi.segment_subset
-/

#print Pi.openSegment_subset /-
theorem openSegment_subset (x y : ∀ i, π i) :
    openSegment 𝕜 x y ⊆ s.pi fun i => openSegment 𝕜 (x i) (y i) := by
  rintro z ⟨a, b, ha, hb, hab, hz⟩ i -; exact ⟨a, b, ha, hb, hab, congr_fun hz i⟩
#align pi.open_segment_subset Pi.openSegment_subset
-/

variable [DecidableEq ι]

#print Pi.image_update_segment /-
theorem image_update_segment (i : ι) (x₁ x₂ : π i) (y : ∀ i, π i) :
    update y i '' [x₁ -[𝕜] x₂] = [update y i x₁ -[𝕜] update y i x₂] :=
  by
  ext z
  simp_rw [Set.mem_image, segment, Set.mem_setOf, ← update_smul, ← update_add, update_eq_iff, ←
    exists_and_right, @exists_comm (π i), exists_eq_left']
  refine' exists₅_congr fun a b ha hb hab => _
  rw [Convex.combo_self hab]
#align pi.image_update_segment Pi.image_update_segment
-/

#print Pi.image_update_openSegment /-
theorem image_update_openSegment (i : ι) (x₁ x₂ : π i) (y : ∀ i, π i) :
    update y i '' openSegment 𝕜 x₁ x₂ = openSegment 𝕜 (update y i x₁) (update y i x₂) :=
  by
  ext z
  simp_rw [Set.mem_image, openSegment, Set.mem_setOf, ← update_smul, ← update_add, update_eq_iff, ←
    exists_and_right, @exists_comm (π i), exists_eq_left']
  refine' exists₅_congr fun a b ha hb hab => _
  rw [Convex.combo_self hab]
#align pi.image_update_open_segment Pi.image_update_openSegment
-/

end Pi

