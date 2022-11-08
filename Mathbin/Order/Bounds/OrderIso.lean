/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Yury Kudryashov
-/
import Mathbin.Order.Bounds.Basic
import Mathbin.Order.Hom.Basic

/-!
# Order isomorhpisms and bounds.
-/


variable {α β : Type _}

open Set

namespace OrderIso

variable [Preorder α] [Preorder β] (f : α ≃o β)

theorem upper_bounds_image {s : Set α} : UpperBounds (f '' s) = f '' UpperBounds s :=
  Subset.antisymm
    (fun x hx => ⟨f.symm x, fun y hy => f.le_symm_apply.2 (hx <| mem_image_of_mem _ hy), f.apply_symm_apply x⟩)
    f.Monotone.image_upper_bounds_subset_upper_bounds_image

theorem lower_bounds_image {s : Set α} : LowerBounds (f '' s) = f '' LowerBounds s :=
  @upper_bounds_image αᵒᵈ βᵒᵈ _ _ f.dual _

@[simp]
theorem is_lub_image {s : Set α} {x : β} : IsLub (f '' s) x ↔ IsLub s (f.symm x) :=
  ⟨fun h => IsLub.of_image (fun _ _ => f.le_iff_le) ((f.apply_symm_apply x).symm ▸ h), fun h =>
    (IsLub.of_image fun _ _ => f.symm.le_iff_le) <| (f.symm_image_image s).symm ▸ h⟩

theorem is_lub_image' {s : Set α} {x : α} : IsLub (f '' s) (f x) ↔ IsLub s x := by rw [is_lub_image, f.symm_apply_apply]

@[simp]
theorem is_glb_image {s : Set α} {x : β} : IsGlb (f '' s) x ↔ IsGlb s (f.symm x) :=
  f.dual.is_lub_image

theorem is_glb_image' {s : Set α} {x : α} : IsGlb (f '' s) (f x) ↔ IsGlb s x :=
  f.dual.is_lub_image'

@[simp]
theorem is_lub_preimage {s : Set β} {x : α} : IsLub (f ⁻¹' s) x ↔ IsLub s (f x) := by
  rw [← f.symm_symm, ← image_eq_preimage, is_lub_image]

theorem is_lub_preimage' {s : Set β} {x : β} : IsLub (f ⁻¹' s) (f.symm x) ↔ IsLub s x := by
  rw [is_lub_preimage, f.apply_symm_apply]

@[simp]
theorem is_glb_preimage {s : Set β} {x : α} : IsGlb (f ⁻¹' s) x ↔ IsGlb s (f x) :=
  f.dual.is_lub_preimage

theorem is_glb_preimage' {s : Set β} {x : β} : IsGlb (f ⁻¹' s) (f.symm x) ↔ IsGlb s x :=
  f.dual.is_lub_preimage'

end OrderIso

