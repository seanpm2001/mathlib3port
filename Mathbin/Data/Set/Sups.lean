/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module data.set.sups
! leanprover-community/mathlib commit 97eab48559068f3d6313da387714ef25768fb730
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.NAry
import Mathbin.Order.UpperLower.Basic

/-!
# Set family operations

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines a few binary operations on `set α` for use in set family combinatorics.

## Main declarations

* `s ⊻ t`: Set of elements of the form `a ⊔ b` where `a ∈ s`, `b ∈ t`.
* `s ⊼ t`: Set of elements of the form `a ⊓ b` where `a ∈ s`, `b ∈ t`.

## Notation

We define the following notation in locale `set_family`:
* `s ⊻ t`
* `s ⊼ t`

## References

[B. Bollobás, *Combinatorics*][bollobas1986]
-/


open Function

variable {α : Type _}

#print HasSups /-
/-- Notation typeclass for pointwise supremum `⊻`. -/
class HasSups (α : Type _) where
  sups : α → α → α
#align has_sups HasSups
-/

#print HasInfs /-
/-- Notation typeclass for pointwise infimum `⊼`. -/
class HasInfs (α : Type _) where
  infs : α → α → α
#align has_infs HasInfs
-/

infixl:74
  " ⊻ " =>-- This notation is meant to have higher precedence than `⊔` and `⊓`, but still within the realm of
  -- other binary operations
  HasSups.sups

infixl:75 " ⊼ " => HasInfs.infs

namespace Set

section Sups

variable [SemilatticeSup α] (s s₁ s₂ t t₁ t₂ u v : Set α)

#print Set.hasSups /-
/-- `s ⊻ t` is the set of elements of the form `a ⊔ b` where `a ∈ s`, `b ∈ t`. -/
protected def hasSups : HasSups (Set α) :=
  ⟨image2 (· ⊔ ·)⟩
#align set.has_sups Set.hasSups
-/

scoped[SetFamily] attribute [instance] Set.hasSups

variable {s s₁ s₂ t t₁ t₂ u} {a b c : α}

#print Set.mem_sups /-
@[simp]
theorem mem_sups : c ∈ s ⊻ t ↔ ∃ a ∈ s, ∃ b ∈ t, a ⊔ b = c := by simp [(· ⊻ ·)]
#align set.mem_sups Set.mem_sups
-/

#print Set.sup_mem_sups /-
theorem sup_mem_sups : a ∈ s → b ∈ t → a ⊔ b ∈ s ⊻ t :=
  mem_image2_of_mem
#align set.sup_mem_sups Set.sup_mem_sups
-/

#print Set.sups_subset /-
theorem sups_subset : s₁ ⊆ s₂ → t₁ ⊆ t₂ → s₁ ⊻ t₁ ⊆ s₂ ⊻ t₂ :=
  image2_subset
#align set.sups_subset Set.sups_subset
-/

#print Set.sups_subset_left /-
theorem sups_subset_left : t₁ ⊆ t₂ → s ⊻ t₁ ⊆ s ⊻ t₂ :=
  image2_subset_left
#align set.sups_subset_left Set.sups_subset_left
-/

#print Set.sups_subset_right /-
theorem sups_subset_right : s₁ ⊆ s₂ → s₁ ⊻ t ⊆ s₂ ⊻ t :=
  image2_subset_right
#align set.sups_subset_right Set.sups_subset_right
-/

#print Set.image_subset_sups_left /-
theorem image_subset_sups_left : b ∈ t → (fun a => a ⊔ b) '' s ⊆ s ⊻ t :=
  image_subset_image2_left
#align set.image_subset_sups_left Set.image_subset_sups_left
-/

#print Set.image_subset_sups_right /-
theorem image_subset_sups_right : a ∈ s → (· ⊔ ·) a '' t ⊆ s ⊻ t :=
  image_subset_image2_right
#align set.image_subset_sups_right Set.image_subset_sups_right
-/

#print Set.forall_sups_iff /-
theorem forall_sups_iff {p : α → Prop} : (∀ c ∈ s ⊻ t, p c) ↔ ∀ a ∈ s, ∀ b ∈ t, p (a ⊔ b) :=
  forall_image2_iff
#align set.forall_sups_iff Set.forall_sups_iff
-/

#print Set.sups_subset_iff /-
@[simp]
theorem sups_subset_iff : s ⊻ t ⊆ u ↔ ∀ a ∈ s, ∀ b ∈ t, a ⊔ b ∈ u :=
  image2_subset_iff
#align set.sups_subset_iff Set.sups_subset_iff
-/

#print Set.sups_nonempty /-
@[simp]
theorem sups_nonempty : (s ⊻ t).Nonempty ↔ s.Nonempty ∧ t.Nonempty :=
  image2_nonempty_iff
#align set.sups_nonempty Set.sups_nonempty
-/

#print Set.Nonempty.sups /-
protected theorem Nonempty.sups : s.Nonempty → t.Nonempty → (s ⊻ t).Nonempty :=
  Nonempty.image2
#align set.nonempty.sups Set.Nonempty.sups
-/

#print Set.Nonempty.of_sups_left /-
theorem Nonempty.of_sups_left : (s ⊻ t).Nonempty → s.Nonempty :=
  Nonempty.of_image2_left
#align set.nonempty.of_sups_left Set.Nonempty.of_sups_left
-/

#print Set.Nonempty.of_sups_right /-
theorem Nonempty.of_sups_right : (s ⊻ t).Nonempty → t.Nonempty :=
  Nonempty.of_image2_right
#align set.nonempty.of_sups_right Set.Nonempty.of_sups_right
-/

#print Set.empty_sups /-
@[simp]
theorem empty_sups : ∅ ⊻ t = ∅ :=
  image2_empty_left
#align set.empty_sups Set.empty_sups
-/

#print Set.sups_empty /-
@[simp]
theorem sups_empty : s ⊻ ∅ = ∅ :=
  image2_empty_right
#align set.sups_empty Set.sups_empty
-/

#print Set.sups_eq_empty /-
@[simp]
theorem sups_eq_empty : s ⊻ t = ∅ ↔ s = ∅ ∨ t = ∅ :=
  image2_eq_empty_iff
#align set.sups_eq_empty Set.sups_eq_empty
-/

#print Set.singleton_sups /-
@[simp]
theorem singleton_sups : {a} ⊻ t = t.image fun b => a ⊔ b :=
  image2_singleton_left
#align set.singleton_sups Set.singleton_sups
-/

#print Set.sups_singleton /-
@[simp]
theorem sups_singleton : s ⊻ {b} = s.image fun a => a ⊔ b :=
  image2_singleton_right
#align set.sups_singleton Set.sups_singleton
-/

#print Set.singleton_sups_singleton /-
theorem singleton_sups_singleton : ({a} ⊻ {b} : Set α) = {a ⊔ b} :=
  image2_singleton
#align set.singleton_sups_singleton Set.singleton_sups_singleton
-/

#print Set.sups_union_left /-
theorem sups_union_left : (s₁ ∪ s₂) ⊻ t = s₁ ⊻ t ∪ s₂ ⊻ t :=
  image2_union_left
#align set.sups_union_left Set.sups_union_left
-/

#print Set.sups_union_right /-
theorem sups_union_right : s ⊻ (t₁ ∪ t₂) = s ⊻ t₁ ∪ s ⊻ t₂ :=
  image2_union_right
#align set.sups_union_right Set.sups_union_right
-/

#print Set.sups_inter_subset_left /-
theorem sups_inter_subset_left : (s₁ ∩ s₂) ⊻ t ⊆ s₁ ⊻ t ∩ s₂ ⊻ t :=
  image2_inter_subset_left
#align set.sups_inter_subset_left Set.sups_inter_subset_left
-/

#print Set.sups_inter_subset_right /-
theorem sups_inter_subset_right : s ⊻ (t₁ ∩ t₂) ⊆ s ⊻ t₁ ∩ s ⊻ t₂ :=
  image2_inter_subset_right
#align set.sups_inter_subset_right Set.sups_inter_subset_right
-/

variable (s t u v)

#print Set.iUnion_image_sup_left /-
theorem iUnion_image_sup_left : (⋃ a ∈ s, (· ⊔ ·) a '' t) = s ⊻ t :=
  iUnion_image_left _
#align set.Union_image_sup_left Set.iUnion_image_sup_left
-/

#print Set.iUnion_image_sup_right /-
theorem iUnion_image_sup_right : (⋃ b ∈ t, (· ⊔ b) '' s) = s ⊻ t :=
  iUnion_image_right _
#align set.Union_image_sup_right Set.iUnion_image_sup_right
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Set.image_sup_prod /-
@[simp]
theorem image_sup_prod (s t : Set α) : (s ×ˢ t).image (uncurry (· ⊔ ·)) = s ⊻ t :=
  image_uncurry_prod _ _ _
#align set.image_sup_prod Set.image_sup_prod
-/

#print Set.sups_assoc /-
theorem sups_assoc : s ⊻ t ⊻ u = s ⊻ (t ⊻ u) :=
  image2_assoc fun _ _ _ => sup_assoc
#align set.sups_assoc Set.sups_assoc
-/

#print Set.sups_comm /-
theorem sups_comm : s ⊻ t = t ⊻ s :=
  image2_comm fun _ _ => sup_comm
#align set.sups_comm Set.sups_comm
-/

#print Set.sups_left_comm /-
theorem sups_left_comm : s ⊻ (t ⊻ u) = t ⊻ (s ⊻ u) :=
  image2_left_comm sup_left_comm
#align set.sups_left_comm Set.sups_left_comm
-/

#print Set.sups_right_comm /-
theorem sups_right_comm : s ⊻ t ⊻ u = s ⊻ u ⊻ t :=
  image2_right_comm sup_right_comm
#align set.sups_right_comm Set.sups_right_comm
-/

#print Set.sups_sups_sups_comm /-
theorem sups_sups_sups_comm : s ⊻ t ⊻ (u ⊻ v) = s ⊻ u ⊻ (t ⊻ v) :=
  image2_image2_image2_comm sup_sup_sup_comm
#align set.sups_sups_sups_comm Set.sups_sups_sups_comm
-/

end Sups

section Infs

variable [SemilatticeInf α] (s s₁ s₂ t t₁ t₂ u v : Set α)

#print Set.hasInfs /-
/-- `s ⊼ t` is the set of elements of the form `a ⊓ b` where `a ∈ s`, `b ∈ t`. -/
protected def hasInfs : HasInfs (Set α) :=
  ⟨image2 (· ⊓ ·)⟩
#align set.has_infs Set.hasInfs
-/

scoped[SetFamily] attribute [instance] Set.hasInfs

variable {s s₁ s₂ t t₁ t₂ u} {a b c : α}

#print Set.mem_infs /-
@[simp]
theorem mem_infs : c ∈ s ⊼ t ↔ ∃ a ∈ s, ∃ b ∈ t, a ⊓ b = c := by simp [(· ⊼ ·)]
#align set.mem_infs Set.mem_infs
-/

#print Set.inf_mem_infs /-
theorem inf_mem_infs : a ∈ s → b ∈ t → a ⊓ b ∈ s ⊼ t :=
  mem_image2_of_mem
#align set.inf_mem_infs Set.inf_mem_infs
-/

#print Set.infs_subset /-
theorem infs_subset : s₁ ⊆ s₂ → t₁ ⊆ t₂ → s₁ ⊼ t₁ ⊆ s₂ ⊼ t₂ :=
  image2_subset
#align set.infs_subset Set.infs_subset
-/

#print Set.infs_subset_left /-
theorem infs_subset_left : t₁ ⊆ t₂ → s ⊼ t₁ ⊆ s ⊼ t₂ :=
  image2_subset_left
#align set.infs_subset_left Set.infs_subset_left
-/

#print Set.infs_subset_right /-
theorem infs_subset_right : s₁ ⊆ s₂ → s₁ ⊼ t ⊆ s₂ ⊼ t :=
  image2_subset_right
#align set.infs_subset_right Set.infs_subset_right
-/

#print Set.image_subset_infs_left /-
theorem image_subset_infs_left : b ∈ t → (fun a => a ⊓ b) '' s ⊆ s ⊼ t :=
  image_subset_image2_left
#align set.image_subset_infs_left Set.image_subset_infs_left
-/

#print Set.image_subset_infs_right /-
theorem image_subset_infs_right : a ∈ s → (· ⊓ ·) a '' t ⊆ s ⊼ t :=
  image_subset_image2_right
#align set.image_subset_infs_right Set.image_subset_infs_right
-/

#print Set.forall_infs_iff /-
theorem forall_infs_iff {p : α → Prop} : (∀ c ∈ s ⊼ t, p c) ↔ ∀ a ∈ s, ∀ b ∈ t, p (a ⊓ b) :=
  forall_image2_iff
#align set.forall_infs_iff Set.forall_infs_iff
-/

#print Set.infs_subset_iff /-
@[simp]
theorem infs_subset_iff : s ⊼ t ⊆ u ↔ ∀ a ∈ s, ∀ b ∈ t, a ⊓ b ∈ u :=
  image2_subset_iff
#align set.infs_subset_iff Set.infs_subset_iff
-/

#print Set.infs_nonempty /-
@[simp]
theorem infs_nonempty : (s ⊼ t).Nonempty ↔ s.Nonempty ∧ t.Nonempty :=
  image2_nonempty_iff
#align set.infs_nonempty Set.infs_nonempty
-/

#print Set.Nonempty.infs /-
protected theorem Nonempty.infs : s.Nonempty → t.Nonempty → (s ⊼ t).Nonempty :=
  Nonempty.image2
#align set.nonempty.infs Set.Nonempty.infs
-/

#print Set.Nonempty.of_infs_left /-
theorem Nonempty.of_infs_left : (s ⊼ t).Nonempty → s.Nonempty :=
  Nonempty.of_image2_left
#align set.nonempty.of_infs_left Set.Nonempty.of_infs_left
-/

#print Set.Nonempty.of_infs_right /-
theorem Nonempty.of_infs_right : (s ⊼ t).Nonempty → t.Nonempty :=
  Nonempty.of_image2_right
#align set.nonempty.of_infs_right Set.Nonempty.of_infs_right
-/

#print Set.empty_infs /-
@[simp]
theorem empty_infs : ∅ ⊼ t = ∅ :=
  image2_empty_left
#align set.empty_infs Set.empty_infs
-/

#print Set.infs_empty /-
@[simp]
theorem infs_empty : s ⊼ ∅ = ∅ :=
  image2_empty_right
#align set.infs_empty Set.infs_empty
-/

#print Set.infs_eq_empty /-
@[simp]
theorem infs_eq_empty : s ⊼ t = ∅ ↔ s = ∅ ∨ t = ∅ :=
  image2_eq_empty_iff
#align set.infs_eq_empty Set.infs_eq_empty
-/

#print Set.singleton_infs /-
@[simp]
theorem singleton_infs : {a} ⊼ t = t.image fun b => a ⊓ b :=
  image2_singleton_left
#align set.singleton_infs Set.singleton_infs
-/

#print Set.infs_singleton /-
@[simp]
theorem infs_singleton : s ⊼ {b} = s.image fun a => a ⊓ b :=
  image2_singleton_right
#align set.infs_singleton Set.infs_singleton
-/

#print Set.singleton_infs_singleton /-
theorem singleton_infs_singleton : ({a} ⊼ {b} : Set α) = {a ⊓ b} :=
  image2_singleton
#align set.singleton_infs_singleton Set.singleton_infs_singleton
-/

#print Set.infs_union_left /-
theorem infs_union_left : (s₁ ∪ s₂) ⊼ t = s₁ ⊼ t ∪ s₂ ⊼ t :=
  image2_union_left
#align set.infs_union_left Set.infs_union_left
-/

#print Set.infs_union_right /-
theorem infs_union_right : s ⊼ (t₁ ∪ t₂) = s ⊼ t₁ ∪ s ⊼ t₂ :=
  image2_union_right
#align set.infs_union_right Set.infs_union_right
-/

#print Set.infs_inter_subset_left /-
theorem infs_inter_subset_left : (s₁ ∩ s₂) ⊼ t ⊆ s₁ ⊼ t ∩ s₂ ⊼ t :=
  image2_inter_subset_left
#align set.infs_inter_subset_left Set.infs_inter_subset_left
-/

#print Set.infs_inter_subset_right /-
theorem infs_inter_subset_right : s ⊼ (t₁ ∩ t₂) ⊆ s ⊼ t₁ ∩ s ⊼ t₂ :=
  image2_inter_subset_right
#align set.infs_inter_subset_right Set.infs_inter_subset_right
-/

variable (s t u v)

#print Set.iUnion_image_inf_left /-
theorem iUnion_image_inf_left : (⋃ a ∈ s, (· ⊓ ·) a '' t) = s ⊼ t :=
  iUnion_image_left _
#align set.Union_image_inf_left Set.iUnion_image_inf_left
-/

#print Set.iUnion_image_inf_right /-
theorem iUnion_image_inf_right : (⋃ b ∈ t, (· ⊓ b) '' s) = s ⊼ t :=
  iUnion_image_right _
#align set.Union_image_inf_right Set.iUnion_image_inf_right
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Set.image_inf_prod /-
@[simp]
theorem image_inf_prod (s t : Set α) : (s ×ˢ t).image (uncurry (· ⊓ ·)) = s ⊼ t :=
  image_uncurry_prod _ _ _
#align set.image_inf_prod Set.image_inf_prod
-/

#print Set.infs_assoc /-
theorem infs_assoc : s ⊼ t ⊼ u = s ⊼ (t ⊼ u) :=
  image2_assoc fun _ _ _ => inf_assoc
#align set.infs_assoc Set.infs_assoc
-/

#print Set.infs_comm /-
theorem infs_comm : s ⊼ t = t ⊼ s :=
  image2_comm fun _ _ => inf_comm
#align set.infs_comm Set.infs_comm
-/

#print Set.infs_left_comm /-
theorem infs_left_comm : s ⊼ (t ⊼ u) = t ⊼ (s ⊼ u) :=
  image2_left_comm inf_left_comm
#align set.infs_left_comm Set.infs_left_comm
-/

#print Set.infs_right_comm /-
theorem infs_right_comm : s ⊼ t ⊼ u = s ⊼ u ⊼ t :=
  image2_right_comm inf_right_comm
#align set.infs_right_comm Set.infs_right_comm
-/

#print Set.infs_infs_infs_comm /-
theorem infs_infs_infs_comm : s ⊼ t ⊼ (u ⊼ v) = s ⊼ u ⊼ (t ⊼ v) :=
  image2_image2_image2_comm inf_inf_inf_comm
#align set.infs_infs_infs_comm Set.infs_infs_infs_comm
-/

end Infs

open scoped SetFamily

section DistribLattice

variable [DistribLattice α] (s t u : Set α)

#print Set.sups_infs_subset_left /-
theorem sups_infs_subset_left : s ⊻ t ⊼ u ⊆ (s ⊻ t) ⊼ (s ⊻ u) :=
  image2_distrib_subset_left fun _ _ _ => sup_inf_left
#align set.sups_infs_subset_left Set.sups_infs_subset_left
-/

#print Set.sups_infs_subset_right /-
theorem sups_infs_subset_right : t ⊼ u ⊻ s ⊆ (t ⊻ s) ⊼ (u ⊻ s) :=
  image2_distrib_subset_right fun _ _ _ => sup_inf_right
#align set.sups_infs_subset_right Set.sups_infs_subset_right
-/

#print Set.infs_sups_subset_left /-
theorem infs_sups_subset_left : s ⊼ (t ⊻ u) ⊆ s ⊼ t ⊻ s ⊼ u :=
  image2_distrib_subset_left fun _ _ _ => inf_sup_left
#align set.infs_sups_subset_left Set.infs_sups_subset_left
-/

#print Set.infs_sups_subset_right /-
theorem infs_sups_subset_right : (t ⊻ u) ⊼ s ⊆ t ⊼ s ⊻ u ⊼ s :=
  image2_distrib_subset_right fun _ _ _ => inf_sup_right
#align set.infs_sups_subset_right Set.infs_sups_subset_right
-/

end DistribLattice

end Set

open scoped SetFamily

#print upperClosure_sups /-
@[simp]
theorem upperClosure_sups [SemilatticeSup α] (s t : Set α) :
    upperClosure (s ⊻ t) = upperClosure s ⊔ upperClosure t :=
  by
  ext a
  simp only [SetLike.mem_coe, mem_upperClosure, Set.mem_sups, exists_and_left, exists_prop,
    UpperSet.coe_sup, Set.mem_inter_iff]
  constructor
  · rintro ⟨_, ⟨b, hb, c, hc, rfl⟩, ha⟩
    exact ⟨⟨b, hb, le_sup_left.trans ha⟩, c, hc, le_sup_right.trans ha⟩
  · rintro ⟨⟨b, hb, hab⟩, c, hc, hac⟩
    exact ⟨_, ⟨b, hb, c, hc, rfl⟩, sup_le hab hac⟩
#align upper_closure_sups upperClosure_sups
-/

#print lowerClosure_infs /-
@[simp]
theorem lowerClosure_infs [SemilatticeInf α] (s t : Set α) :
    lowerClosure (s ⊼ t) = lowerClosure s ⊓ lowerClosure t :=
  by
  ext a
  simp only [SetLike.mem_coe, mem_lowerClosure, Set.mem_infs, exists_and_left, exists_prop,
    LowerSet.coe_sup, Set.mem_inter_iff]
  constructor
  · rintro ⟨_, ⟨b, hb, c, hc, rfl⟩, ha⟩
    exact ⟨⟨b, hb, ha.trans inf_le_left⟩, c, hc, ha.trans inf_le_right⟩
  · rintro ⟨⟨b, hb, hab⟩, c, hc, hac⟩
    exact ⟨_, ⟨b, hb, c, hc, rfl⟩, le_inf hab hac⟩
#align lower_closure_infs lowerClosure_infs
-/

