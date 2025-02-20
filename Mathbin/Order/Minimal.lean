/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module order.minimal
! leanprover-community/mathlib commit f16e7a22e11fc09c71f25446ac1db23a24e8a0bd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Antichain
import Mathbin.Order.UpperLower.Basic

/-!
# Minimal/maximal elements of a set

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines minimal and maximal of a set with respect to an arbitrary relation.

## Main declarations

* `maximals r s`: Maximal elements of `s` with respect to `r`.
* `minimals r s`: Minimal elements of `s` with respect to `r`.

## TODO

Do we need a `finset` version?
-/


open Function Set

variable {α : Type _} (r r₁ r₂ : α → α → Prop) (s t : Set α) (a b : α)

#print maximals /-
/-- Turns a set into an antichain by keeping only the "maximal" elements. -/
def maximals : Set α :=
  {a ∈ s | ∀ ⦃b⦄, b ∈ s → r a b → r b a}
#align maximals maximals
-/

#print minimals /-
/-- Turns a set into an antichain by keeping only the "minimal" elements. -/
def minimals : Set α :=
  {a ∈ s | ∀ ⦃b⦄, b ∈ s → r b a → r a b}
#align minimals minimals
-/

#print maximals_subset /-
theorem maximals_subset : maximals r s ⊆ s :=
  sep_subset _ _
#align maximals_subset maximals_subset
-/

#print minimals_subset /-
theorem minimals_subset : minimals r s ⊆ s :=
  sep_subset _ _
#align minimals_subset minimals_subset
-/

#print maximals_empty /-
@[simp]
theorem maximals_empty : maximals r ∅ = ∅ :=
  sep_empty _
#align maximals_empty maximals_empty
-/

#print minimals_empty /-
@[simp]
theorem minimals_empty : minimals r ∅ = ∅ :=
  sep_empty _
#align minimals_empty minimals_empty
-/

#print maximals_singleton /-
@[simp]
theorem maximals_singleton : maximals r {a} = {a} :=
  (maximals_subset _ _).antisymm <|
    singleton_subset_iff.2 <| ⟨rfl, by rintro b (rfl : b = a); exact id⟩
#align maximals_singleton maximals_singleton
-/

#print minimals_singleton /-
@[simp]
theorem minimals_singleton : minimals r {a} = {a} :=
  maximals_singleton _ _
#align minimals_singleton minimals_singleton
-/

#print maximals_swap /-
theorem maximals_swap : maximals (swap r) s = minimals r s :=
  rfl
#align maximals_swap maximals_swap
-/

#print minimals_swap /-
theorem minimals_swap : minimals (swap r) s = maximals r s :=
  rfl
#align minimals_swap minimals_swap
-/

section IsAntisymm

variable {r s t a b} [IsAntisymm α r]

#print eq_of_mem_maximals /-
theorem eq_of_mem_maximals (ha : a ∈ maximals r s) (hb : b ∈ s) (h : r a b) : a = b :=
  antisymm h <| ha.2 hb h
#align eq_of_mem_maximals eq_of_mem_maximals
-/

#print eq_of_mem_minimals /-
theorem eq_of_mem_minimals (ha : a ∈ minimals r s) (hb : b ∈ s) (h : r b a) : a = b :=
  antisymm (ha.2 hb h) h
#align eq_of_mem_minimals eq_of_mem_minimals
-/

variable (r s)

#print maximals_antichain /-
theorem maximals_antichain : IsAntichain r (maximals r s) := fun a ha b hb hab h =>
  hab <| eq_of_mem_maximals ha hb.1 h
#align maximals_antichain maximals_antichain
-/

#print minimals_antichain /-
theorem minimals_antichain : IsAntichain r (minimals r s) :=
  haveI := IsAntisymm.swap r
  (maximals_antichain _ _).symm
#align minimals_antichain minimals_antichain
-/

end IsAntisymm

#print maximals_eq_minimals /-
theorem maximals_eq_minimals [IsSymm α r] : maximals r s = minimals r s := by congr; ext a b;
  exact comm
#align maximals_eq_minimals maximals_eq_minimals
-/

variable {r r₁ r₂ s t a}

#print Set.Subsingleton.maximals_eq /-
theorem Set.Subsingleton.maximals_eq (h : s.Subsingleton) : maximals r s = s :=
  h.inductionOn (minimals_empty _) (maximals_singleton _)
#align set.subsingleton.maximals_eq Set.Subsingleton.maximals_eq
-/

#print Set.Subsingleton.minimals_eq /-
theorem Set.Subsingleton.minimals_eq (h : s.Subsingleton) : minimals r s = s :=
  h.maximals_eq
#align set.subsingleton.minimals_eq Set.Subsingleton.minimals_eq
-/

#print maximals_mono /-
theorem maximals_mono [IsAntisymm α r₂] (h : ∀ a b, r₁ a b → r₂ a b) :
    maximals r₂ s ⊆ maximals r₁ s := fun a ha =>
  ⟨ha.1, fun b hb hab => by have := eq_of_mem_maximals ha hb (h _ _ hab); subst this; exact hab⟩
#align maximals_mono maximals_mono
-/

#print minimals_mono /-
theorem minimals_mono [IsAntisymm α r₂] (h : ∀ a b, r₁ a b → r₂ a b) :
    minimals r₂ s ⊆ minimals r₁ s := fun a ha =>
  ⟨ha.1, fun b hb hab => by have := eq_of_mem_minimals ha hb (h _ _ hab); subst this; exact hab⟩
#align minimals_mono minimals_mono
-/

#print maximals_union /-
theorem maximals_union : maximals r (s ∪ t) ⊆ maximals r s ∪ maximals r t :=
  by
  intro a ha
  obtain h | h := ha.1
  · exact Or.inl ⟨h, fun b hb => ha.2 <| Or.inl hb⟩
  · exact Or.inr ⟨h, fun b hb => ha.2 <| Or.inr hb⟩
#align maximals_union maximals_union
-/

#print minimals_union /-
theorem minimals_union : minimals r (s ∪ t) ⊆ minimals r s ∪ minimals r t :=
  maximals_union
#align minimals_union minimals_union
-/

#print maximals_inter_subset /-
theorem maximals_inter_subset : maximals r s ∩ t ⊆ maximals r (s ∩ t) := fun a ha =>
  ⟨⟨ha.1.1, ha.2⟩, fun b hb => ha.1.2 hb.1⟩
#align maximals_inter_subset maximals_inter_subset
-/

#print minimals_inter_subset /-
theorem minimals_inter_subset : minimals r s ∩ t ⊆ minimals r (s ∩ t) :=
  maximals_inter_subset
#align minimals_inter_subset minimals_inter_subset
-/

#print inter_maximals_subset /-
theorem inter_maximals_subset : s ∩ maximals r t ⊆ maximals r (s ∩ t) := fun a ha =>
  ⟨⟨ha.1, ha.2.1⟩, fun b hb => ha.2.2 hb.2⟩
#align inter_maximals_subset inter_maximals_subset
-/

#print inter_minimals_subset /-
theorem inter_minimals_subset : s ∩ minimals r t ⊆ minimals r (s ∩ t) :=
  inter_maximals_subset
#align inter_minimals_subset inter_minimals_subset
-/

#print IsAntichain.maximals_eq /-
theorem IsAntichain.maximals_eq (h : IsAntichain r s) : maximals r s = s :=
  (maximals_subset _ _).antisymm fun a ha =>
    ⟨ha, fun b hb hab => by have := h.eq ha hb hab; subst this; exact hab⟩
#align is_antichain.maximals_eq IsAntichain.maximals_eq
-/

#print IsAntichain.minimals_eq /-
theorem IsAntichain.minimals_eq (h : IsAntichain r s) : minimals r s = s :=
  (minimals_subset _ _).antisymm fun a ha =>
    ⟨ha, fun b hb hab => by have := h.eq hb ha hab; subst this; exact hab⟩
#align is_antichain.minimals_eq IsAntichain.minimals_eq
-/

#print maximals_idem /-
@[simp]
theorem maximals_idem : maximals r (maximals r s) = maximals r s :=
  (maximals_subset _ _).antisymm fun a ha => ⟨ha, fun b hb => ha.2 hb.1⟩
#align maximals_idem maximals_idem
-/

#print minimals_idem /-
@[simp]
theorem minimals_idem : minimals r (minimals r s) = minimals r s :=
  maximals_idem
#align minimals_idem minimals_idem
-/

#print IsAntichain.max_maximals /-
/-- If `maximals r s` is included in but *shadows* the antichain `t`, then it is actually
equal to `t`. -/
theorem IsAntichain.max_maximals (ht : IsAntichain r t) (h : maximals r s ⊆ t)
    (hs : ∀ ⦃a⦄, a ∈ t → ∃ b ∈ maximals r s, r b a) : maximals r s = t :=
  by
  refine' h.antisymm fun a ha => _
  obtain ⟨b, hb, hr⟩ := hs ha
  rwa [of_not_not fun hab => ht (h hb) ha (Ne.symm hab) hr]
#align is_antichain.max_maximals IsAntichain.max_maximals
-/

#print IsAntichain.max_minimals /-
/-- If `minimals r s` is included in but *shadows* the antichain `t`, then it is actually
equal to `t`. -/
theorem IsAntichain.max_minimals (ht : IsAntichain r t) (h : minimals r s ⊆ t)
    (hs : ∀ ⦃a⦄, a ∈ t → ∃ b ∈ minimals r s, r a b) : minimals r s = t :=
  by
  refine' h.antisymm fun a ha => _
  obtain ⟨b, hb, hr⟩ := hs ha
  rwa [of_not_not fun hab => ht ha (h hb) hab hr]
#align is_antichain.max_minimals IsAntichain.max_minimals
-/

variable [PartialOrder α]

#print IsLeast.mem_minimals /-
theorem IsLeast.mem_minimals (h : IsLeast s a) : a ∈ minimals (· ≤ ·) s :=
  ⟨h.1, fun b hb _ => h.2 hb⟩
#align is_least.mem_minimals IsLeast.mem_minimals
-/

#print IsGreatest.mem_maximals /-
theorem IsGreatest.mem_maximals (h : IsGreatest s a) : a ∈ maximals (· ≤ ·) s :=
  ⟨h.1, fun b hb _ => h.2 hb⟩
#align is_greatest.mem_maximals IsGreatest.mem_maximals
-/

#print IsLeast.minimals_eq /-
theorem IsLeast.minimals_eq (h : IsLeast s a) : minimals (· ≤ ·) s = {a} :=
  eq_singleton_iff_unique_mem.2 ⟨h.mem_minimals, fun b hb => eq_of_mem_minimals hb h.1 <| h.2 hb.1⟩
#align is_least.minimals_eq IsLeast.minimals_eq
-/

#print IsGreatest.maximals_eq /-
theorem IsGreatest.maximals_eq (h : IsGreatest s a) : maximals (· ≤ ·) s = {a} :=
  eq_singleton_iff_unique_mem.2 ⟨h.mem_maximals, fun b hb => eq_of_mem_maximals hb h.1 <| h.2 hb.1⟩
#align is_greatest.maximals_eq IsGreatest.maximals_eq
-/

#print IsAntichain.minimals_upperClosure /-
theorem IsAntichain.minimals_upperClosure (hs : IsAntichain (· ≤ ·) s) :
    minimals (· ≤ ·) (upperClosure s : Set α) = s :=
  hs.max_minimals
    (fun a ⟨⟨b, hb, hba⟩, h⟩ => by rwa [eq_of_mem_minimals ‹a ∈ _› (subset_upperClosure hb) hba])
    fun a ha =>
    ⟨a, ⟨subset_upperClosure ha, fun b ⟨c, hc, hcb⟩ hba => by rwa [hs.eq' ha hc (hcb.trans hba)]⟩,
      le_rfl⟩
#align is_antichain.minimals_upper_closure IsAntichain.minimals_upperClosure
-/

#print IsAntichain.maximals_lowerClosure /-
theorem IsAntichain.maximals_lowerClosure (hs : IsAntichain (· ≤ ·) s) :
    maximals (· ≤ ·) (lowerClosure s : Set α) = s :=
  hs.toDual.minimals_upperClosure
#align is_antichain.maximals_lower_closure IsAntichain.maximals_lowerClosure
-/

