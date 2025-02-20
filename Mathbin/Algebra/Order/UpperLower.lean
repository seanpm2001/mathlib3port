/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module algebra.order.upper_lower
! leanprover-community/mathlib commit ad0089aca372256fe53dde13ca0dfea569bf5ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Group.Defs
import Mathbin.Data.Set.Pointwise.Smul
import Mathbin.Order.UpperLower.Basic

/-!
# Algebraic operations on upper/lower sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Upper/lower sets are preserved under pointwise algebraic operations in ordered groups.
-/


open Function Set

open scoped Pointwise

section OrderedCommMonoid

variable {α : Type _} [OrderedCommMonoid α] {s : Set α} {x : α}

#print IsUpperSet.smul_subset /-
@[to_additive]
theorem IsUpperSet.smul_subset (hs : IsUpperSet s) (hx : 1 ≤ x) : x • s ⊆ s :=
  smul_set_subset_iff.2 fun y => hs <| le_mul_of_one_le_left' hx
#align is_upper_set.smul_subset IsUpperSet.smul_subset
#align is_upper_set.vadd_subset IsUpperSet.vadd_subset
-/

#print IsLowerSet.smul_subset /-
@[to_additive]
theorem IsLowerSet.smul_subset (hs : IsLowerSet s) (hx : x ≤ 1) : x • s ⊆ s :=
  smul_set_subset_iff.2 fun y => hs <| mul_le_of_le_one_left' hx
#align is_lower_set.smul_subset IsLowerSet.smul_subset
#align is_lower_set.vadd_subset IsLowerSet.vadd_subset
-/

end OrderedCommMonoid

section OrderedCommGroup

variable {α : Type _} [OrderedCommGroup α] {s t : Set α} {a : α}

#print IsUpperSet.smul /-
@[to_additive]
theorem IsUpperSet.smul (hs : IsUpperSet s) : IsUpperSet (a • s) :=
  by
  rintro _ y hxy ⟨x, hx, rfl⟩
  exact mem_smul_set_iff_inv_smul_mem.2 (hs (le_inv_mul_iff_mul_le.2 hxy) hx)
#align is_upper_set.smul IsUpperSet.smul
#align is_upper_set.vadd IsUpperSet.vadd
-/

#print IsLowerSet.smul /-
@[to_additive]
theorem IsLowerSet.smul (hs : IsLowerSet s) : IsLowerSet (a • s) :=
  hs.ofDual.smul
#align is_lower_set.smul IsLowerSet.smul
#align is_lower_set.vadd IsLowerSet.vadd
-/

#print Set.OrdConnected.smul /-
@[to_additive]
theorem Set.OrdConnected.smul (hs : s.OrdConnected) : (a • s).OrdConnected :=
  by
  rw [← hs.upper_closure_inter_lower_closure, smul_set_inter]
  exact (upperClosure _).upper.smul.OrdConnected.inter (lowerClosure _).lower.smul.OrdConnected
#align set.ord_connected.smul Set.OrdConnected.smul
#align set.ord_connected.vadd Set.OrdConnected.vadd
-/

#print IsUpperSet.mul_left /-
@[to_additive]
theorem IsUpperSet.mul_left (ht : IsUpperSet t) : IsUpperSet (s * t) := by
  rw [← smul_eq_mul, ← bUnion_smul_set]; exact isUpperSet_iUnion₂ fun x hx => ht.smul
#align is_upper_set.mul_left IsUpperSet.mul_left
#align is_upper_set.add_left IsUpperSet.add_left
-/

#print IsUpperSet.mul_right /-
@[to_additive]
theorem IsUpperSet.mul_right (hs : IsUpperSet s) : IsUpperSet (s * t) := by rw [mul_comm];
  exact hs.mul_left
#align is_upper_set.mul_right IsUpperSet.mul_right
#align is_upper_set.add_right IsUpperSet.add_right
-/

#print IsLowerSet.mul_left /-
@[to_additive]
theorem IsLowerSet.mul_left (ht : IsLowerSet t) : IsLowerSet (s * t) :=
  ht.ofDual.mul_left
#align is_lower_set.mul_left IsLowerSet.mul_left
#align is_lower_set.add_left IsLowerSet.add_left
-/

#print IsLowerSet.mul_right /-
@[to_additive]
theorem IsLowerSet.mul_right (hs : IsLowerSet s) : IsLowerSet (s * t) :=
  hs.ofDual.mul_right
#align is_lower_set.mul_right IsLowerSet.mul_right
#align is_lower_set.add_right IsLowerSet.add_right
-/

#print IsUpperSet.inv /-
@[to_additive]
theorem IsUpperSet.inv (hs : IsUpperSet s) : IsLowerSet s⁻¹ := fun x y h => hs <| inv_le_inv' h
#align is_upper_set.inv IsUpperSet.inv
#align is_upper_set.neg IsUpperSet.neg
-/

#print IsLowerSet.inv /-
@[to_additive]
theorem IsLowerSet.inv (hs : IsLowerSet s) : IsUpperSet s⁻¹ := fun x y h => hs <| inv_le_inv' h
#align is_lower_set.inv IsLowerSet.inv
#align is_lower_set.neg IsLowerSet.neg
-/

#print IsUpperSet.div_left /-
@[to_additive]
theorem IsUpperSet.div_left (ht : IsUpperSet t) : IsLowerSet (s / t) := by rw [div_eq_mul_inv];
  exact ht.inv.mul_left
#align is_upper_set.div_left IsUpperSet.div_left
#align is_upper_set.sub_left IsUpperSet.sub_left
-/

#print IsUpperSet.div_right /-
@[to_additive]
theorem IsUpperSet.div_right (hs : IsUpperSet s) : IsUpperSet (s / t) := by rw [div_eq_mul_inv];
  exact hs.mul_right
#align is_upper_set.div_right IsUpperSet.div_right
#align is_upper_set.sub_right IsUpperSet.sub_right
-/

#print IsLowerSet.div_left /-
@[to_additive]
theorem IsLowerSet.div_left (ht : IsLowerSet t) : IsUpperSet (s / t) :=
  ht.ofDual.div_left
#align is_lower_set.div_left IsLowerSet.div_left
#align is_lower_set.sub_left IsLowerSet.sub_left
-/

#print IsLowerSet.div_right /-
@[to_additive]
theorem IsLowerSet.div_right (hs : IsLowerSet s) : IsLowerSet (s / t) :=
  hs.ofDual.div_right
#align is_lower_set.div_right IsLowerSet.div_right
#align is_lower_set.sub_right IsLowerSet.sub_right
-/

namespace UpperSet

@[to_additive]
instance : One (UpperSet α) :=
  ⟨Ici 1⟩

@[to_additive]
instance : Mul (UpperSet α) :=
  ⟨fun s t => ⟨image2 (· * ·) s t, s.2.mul_right⟩⟩

@[to_additive]
instance : Div (UpperSet α) :=
  ⟨fun s t => ⟨image2 (· / ·) s t, s.2.div_right⟩⟩

@[to_additive]
instance : SMul α (UpperSet α) :=
  ⟨fun a s => ⟨(· • ·) a '' s, s.2.smul⟩⟩

#print UpperSet.coe_one /-
@[simp, norm_cast, to_additive]
theorem coe_one : ((1 : UpperSet α) : Set α) = Set.Ici 1 :=
  rfl
#align upper_set.coe_one UpperSet.coe_one
#align upper_set.coe_zero UpperSet.coe_zero
-/

@[simp, norm_cast, to_additive]
theorem coe_smul (a : α) (s : UpperSet α) : (↑(a • s) : Set α) = a • s :=
  rfl
#align upper_set.coe_smul UpperSet.coe_smul
#align upper_set.coe_vadd UpperSet.coe_vadd

#print UpperSet.coe_mul /-
@[simp, norm_cast, to_additive]
theorem coe_mul (s t : UpperSet α) : (↑(s * t) : Set α) = s * t :=
  rfl
#align upper_set.coe_mul UpperSet.coe_mul
#align upper_set.coe_add UpperSet.coe_add
-/

#print UpperSet.coe_div /-
@[simp, norm_cast, to_additive]
theorem coe_div (s t : UpperSet α) : (↑(s / t) : Set α) = s / t :=
  rfl
#align upper_set.coe_div UpperSet.coe_div
#align upper_set.coe_sub UpperSet.coe_sub
-/

#print UpperSet.Ici_one /-
@[simp, to_additive]
theorem Ici_one : Ici (1 : α) = 1 :=
  rfl
#align upper_set.Ici_one UpperSet.Ici_one
#align upper_set.Ici_zero UpperSet.Ici_zero
-/

@[to_additive]
instance : MulAction α (UpperSet α) :=
  SetLike.coe_injective.MulAction _ coe_smul

@[to_additive]
instance : CommSemigroup (UpperSet α) :=
  { (SetLike.coe_injective.CommSemigroup _ coe_mul : CommSemigroup (UpperSet α)) with
    mul := (· * ·) }

@[to_additive]
private theorem one_mul (s : UpperSet α) : 1 * s = s :=
  SetLike.coe_injective <|
    (subset_mul_right _ left_mem_Ici).antisymm' <| by rw [← smul_eq_mul, ← bUnion_smul_set];
      exact Union₂_subset fun _ => s.upper.smul_subset

@[to_additive]
instance : CommMonoid (UpperSet α) :=
  { UpperSet.commSemigroup with
    one := 1
    one_mul := one_mul
    mul_one := fun s => by rw [mul_comm]; exact one_mul _ }

end UpperSet

namespace LowerSet

@[to_additive]
instance : One (LowerSet α) :=
  ⟨Iic 1⟩

@[to_additive]
instance : Mul (LowerSet α) :=
  ⟨fun s t => ⟨image2 (· * ·) s t, s.2.mul_right⟩⟩

@[to_additive]
instance : Div (LowerSet α) :=
  ⟨fun s t => ⟨image2 (· / ·) s t, s.2.div_right⟩⟩

@[to_additive]
instance : SMul α (LowerSet α) :=
  ⟨fun a s => ⟨(· • ·) a '' s, s.2.smul⟩⟩

@[simp, norm_cast, to_additive]
theorem coe_smul (a : α) (s : LowerSet α) : (↑(a • s) : Set α) = a • s :=
  rfl
#align lower_set.coe_smul LowerSet.coe_smul
#align lower_set.coe_vadd LowerSet.coe_vadd

#print LowerSet.coe_mul /-
@[simp, norm_cast, to_additive]
theorem coe_mul (s t : LowerSet α) : (↑(s * t) : Set α) = s * t :=
  rfl
#align lower_set.coe_mul LowerSet.coe_mul
#align lower_set.coe_add LowerSet.coe_add
-/

#print LowerSet.coe_div /-
@[simp, norm_cast, to_additive]
theorem coe_div (s t : LowerSet α) : (↑(s / t) : Set α) = s / t :=
  rfl
#align lower_set.coe_div LowerSet.coe_div
#align lower_set.coe_sub LowerSet.coe_sub
-/

#print LowerSet.Iic_one /-
@[simp, to_additive]
theorem Iic_one : Iic (1 : α) = 1 :=
  rfl
#align lower_set.Iic_one LowerSet.Iic_one
#align lower_set.Iic_zero LowerSet.Iic_zero
-/

@[to_additive]
instance : MulAction α (LowerSet α) :=
  SetLike.coe_injective.MulAction _ coe_smul

@[to_additive]
instance : CommSemigroup (LowerSet α) :=
  { (SetLike.coe_injective.CommSemigroup _ coe_mul : CommSemigroup (LowerSet α)) with
    mul := (· * ·) }

@[to_additive]
private theorem one_mul (s : LowerSet α) : 1 * s = s :=
  SetLike.coe_injective <|
    (subset_mul_right _ right_mem_Iic).antisymm' <| by rw [← smul_eq_mul, ← bUnion_smul_set];
      exact Union₂_subset fun _ => s.lower.smul_subset

@[to_additive]
instance : CommMonoid (LowerSet α) :=
  { LowerSet.commSemigroup with
    one := 1
    one_mul := one_mul
    mul_one := fun s => by rw [mul_comm]; exact one_mul _ }

end LowerSet

variable (a s t)

#print upperClosure_one /-
@[simp, to_additive]
theorem upperClosure_one : upperClosure (1 : Set α) = 1 :=
  upperClosure_singleton _
#align upper_closure_one upperClosure_one
#align upper_closure_zero upperClosure_zero
-/

#print lowerClosure_one /-
@[simp, to_additive]
theorem lowerClosure_one : lowerClosure (1 : Set α) = 1 :=
  lowerClosure_singleton _
#align lower_closure_one lowerClosure_one
#align lower_closure_zero lowerClosure_zero
-/

#print upperClosure_smul /-
@[simp, to_additive]
theorem upperClosure_smul : upperClosure (a • s) = a • upperClosure s :=
  upperClosure_image <| OrderIso.mulLeft a
#align upper_closure_smul upperClosure_smul
#align upper_closure_vadd upperClosure_vadd
-/

#print lowerClosure_smul /-
@[simp, to_additive]
theorem lowerClosure_smul : lowerClosure (a • s) = a • lowerClosure s :=
  lowerClosure_image <| OrderIso.mulLeft a
#align lower_closure_smul lowerClosure_smul
#align lower_closure_vadd lowerClosure_vadd
-/

#print mul_upperClosure /-
@[to_additive]
theorem mul_upperClosure : s * upperClosure t = upperClosure (s * t) := by
  simp_rw [← smul_eq_mul, ← bUnion_smul_set, upperClosure_iUnion, upperClosure_smul,
    UpperSet.coe_iInf₂, UpperSet.coe_smul]
#align mul_upper_closure mul_upperClosure
#align add_upper_closure add_upperClosure
-/

#print mul_lowerClosure /-
@[to_additive]
theorem mul_lowerClosure : s * lowerClosure t = lowerClosure (s * t) := by
  simp_rw [← smul_eq_mul, ← bUnion_smul_set, lowerClosure_iUnion, lowerClosure_smul,
    LowerSet.coe_iSup₂, LowerSet.coe_smul]
#align mul_lower_closure mul_lowerClosure
#align add_lower_closure add_lowerClosure
-/

#print upperClosure_mul /-
@[to_additive]
theorem upperClosure_mul : ↑(upperClosure s) * t = upperClosure (s * t) := by
  simp_rw [mul_comm _ t]; exact mul_upperClosure _ _
#align upper_closure_mul upperClosure_mul
#align upper_closure_add upperClosure_add
-/

#print lowerClosure_mul /-
@[to_additive]
theorem lowerClosure_mul : ↑(lowerClosure s) * t = lowerClosure (s * t) := by
  simp_rw [mul_comm _ t]; exact mul_lowerClosure _ _
#align lower_closure_mul lowerClosure_mul
#align lower_closure_add lowerClosure_add
-/

#print upperClosure_mul_distrib /-
@[simp, to_additive]
theorem upperClosure_mul_distrib : upperClosure (s * t) = upperClosure s * upperClosure t :=
  SetLike.coe_injective <| by
    rw [UpperSet.coe_mul, mul_upperClosure, upperClosure_mul, UpperSet.upperClosure]
#align upper_closure_mul_distrib upperClosure_mul_distrib
#align upper_closure_add_distrib upperClosure_add_distrib
-/

#print lowerClosure_mul_distrib /-
@[simp, to_additive]
theorem lowerClosure_mul_distrib : lowerClosure (s * t) = lowerClosure s * lowerClosure t :=
  SetLike.coe_injective <| by
    rw [LowerSet.coe_mul, mul_lowerClosure, lowerClosure_mul, LowerSet.lowerClosure]
#align lower_closure_mul_distrib lowerClosure_mul_distrib
#align lower_closure_add_distrib lowerClosure_add_distrib
-/

end OrderedCommGroup

