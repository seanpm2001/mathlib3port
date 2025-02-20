/-
Copyright (c) 2022 Junyan Xu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa, Junyan Xu

! This file was ported from Lean 3 source module data.dfinsupp.ne_locus
! leanprover-community/mathlib commit 13a5329a8625701af92e9a96ffc90fa787fff24d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Dfinsupp.Basic

/-!
# Locus of unequal values of finitely supported dependent functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Let `N : α → Type*` be a type family, assume that `N a` has a `0` for all `a : α` and let
`f g : Π₀ a, N a` be finitely supported dependent functions.

## Main definition

* `dfinsupp.ne_locus f g : finset α`, the finite subset of `α` where `f` and `g` differ.
In the case in which `N a` is an additive group for all `a`, `dfinsupp.ne_locus f g` coincides with
`dfinsupp.support (f - g)`.
-/


variable {α : Type _} {N : α → Type _}

namespace Dfinsupp

variable [DecidableEq α]

section NHasZero

variable [∀ a, DecidableEq (N a)] [∀ a, Zero (N a)] (f g : Π₀ a, N a)

#print Dfinsupp.neLocus /-
/-- Given two finitely supported functions `f g : α →₀ N`, `finsupp.ne_locus f g` is the `finset`
where `f` and `g` differ. This generalizes `(f - g).support` to situations without subtraction. -/
def neLocus (f g : Π₀ a, N a) : Finset α :=
  (f.support ∪ g.support).filterₓ fun x => f x ≠ g x
#align dfinsupp.ne_locus Dfinsupp.neLocus
-/

#print Dfinsupp.mem_neLocus /-
@[simp]
theorem mem_neLocus {f g : Π₀ a, N a} {a : α} : a ∈ f.neLocus g ↔ f a ≠ g a := by
  simpa only [ne_locus, Finset.mem_filter, Finset.mem_union, mem_support_iff,
    and_iff_right_iff_imp] using Ne.ne_or_ne _
#align dfinsupp.mem_ne_locus Dfinsupp.mem_neLocus
-/

#print Dfinsupp.not_mem_neLocus /-
theorem not_mem_neLocus {f g : Π₀ a, N a} {a : α} : a ∉ f.neLocus g ↔ f a = g a :=
  mem_neLocus.Not.trans not_ne_iff
#align dfinsupp.not_mem_ne_locus Dfinsupp.not_mem_neLocus
-/

#print Dfinsupp.coe_neLocus /-
@[simp]
theorem coe_neLocus : ↑(f.neLocus g) = {x | f x ≠ g x} :=
  Set.ext fun x => mem_neLocus
#align dfinsupp.coe_ne_locus Dfinsupp.coe_neLocus
-/

#print Dfinsupp.neLocus_eq_empty /-
@[simp]
theorem neLocus_eq_empty {f g : Π₀ a, N a} : f.neLocus g = ∅ ↔ f = g :=
  ⟨fun h =>
    ext fun a =>
      Classical.not_not.mp (mem_neLocus.Not.mp (Finset.eq_empty_iff_forall_not_mem.mp h a)),
    fun h => h ▸ by simp only [ne_locus, Ne.def, eq_self_iff_true, not_true, Finset.filter_False]⟩
#align dfinsupp.ne_locus_eq_empty Dfinsupp.neLocus_eq_empty
-/

#print Dfinsupp.nonempty_neLocus_iff /-
@[simp]
theorem nonempty_neLocus_iff {f g : Π₀ a, N a} : (f.neLocus g).Nonempty ↔ f ≠ g :=
  Finset.nonempty_iff_ne_empty.trans neLocus_eq_empty.Not
#align dfinsupp.nonempty_ne_locus_iff Dfinsupp.nonempty_neLocus_iff
-/

#print Dfinsupp.neLocus_comm /-
theorem neLocus_comm : f.neLocus g = g.neLocus f := by
  simp_rw [ne_locus, Finset.union_comm, ne_comm]
#align dfinsupp.ne_locus_comm Dfinsupp.neLocus_comm
-/

#print Dfinsupp.neLocus_zero_right /-
@[simp]
theorem neLocus_zero_right : f.neLocus 0 = f.support := by ext;
  rw [mem_ne_locus, mem_support_iff, coe_zero, Pi.zero_apply]
#align dfinsupp.ne_locus_zero_right Dfinsupp.neLocus_zero_right
-/

#print Dfinsupp.neLocus_zero_left /-
@[simp]
theorem neLocus_zero_left : (0 : Π₀ a, N a).neLocus f = f.support :=
  (neLocus_comm _ _).trans (neLocus_zero_right _)
#align dfinsupp.ne_locus_zero_left Dfinsupp.neLocus_zero_left
-/

end NHasZero

section NeLocusAndMaps

variable {M P : α → Type _} [∀ a, Zero (N a)] [∀ a, Zero (M a)] [∀ a, Zero (P a)]

#print Dfinsupp.subset_mapRange_neLocus /-
theorem subset_mapRange_neLocus [∀ a, DecidableEq (N a)] [∀ a, DecidableEq (M a)] (f g : Π₀ a, N a)
    {F : ∀ a, N a → M a} (F0 : ∀ a, F a 0 = 0) :
    (f.mapRange F F0).neLocus (g.mapRange F F0) ⊆ f.neLocus g := fun a => by
  simpa only [mem_ne_locus, map_range_apply, not_imp_not] using congr_arg (F a)
#align dfinsupp.subset_map_range_ne_locus Dfinsupp.subset_mapRange_neLocus
-/

#print Dfinsupp.zipWith_neLocus_eq_left /-
theorem zipWith_neLocus_eq_left [∀ a, DecidableEq (N a)] [∀ a, DecidableEq (P a)]
    {F : ∀ a, M a → N a → P a} (F0 : ∀ a, F a 0 0 = 0) (f : Π₀ a, M a) (g₁ g₂ : Π₀ a, N a)
    (hF : ∀ a f, Function.Injective fun g => F a f g) :
    (zipWith F F0 f g₁).neLocus (zipWith F F0 f g₂) = g₁.neLocus g₂ := by ext;
  simpa only [mem_ne_locus] using (hF a _).ne_iff
#align dfinsupp.zip_with_ne_locus_eq_left Dfinsupp.zipWith_neLocus_eq_left
-/

#print Dfinsupp.zipWith_neLocus_eq_right /-
theorem zipWith_neLocus_eq_right [∀ a, DecidableEq (M a)] [∀ a, DecidableEq (P a)]
    {F : ∀ a, M a → N a → P a} (F0 : ∀ a, F a 0 0 = 0) (f₁ f₂ : Π₀ a, M a) (g : Π₀ a, N a)
    (hF : ∀ a g, Function.Injective fun f => F a f g) :
    (zipWith F F0 f₁ g).neLocus (zipWith F F0 f₂ g) = f₁.neLocus f₂ := by ext;
  simpa only [mem_ne_locus] using (hF a _).ne_iff
#align dfinsupp.zip_with_ne_locus_eq_right Dfinsupp.zipWith_neLocus_eq_right
-/

#print Dfinsupp.mapRange_neLocus_eq /-
theorem mapRange_neLocus_eq [∀ a, DecidableEq (N a)] [∀ a, DecidableEq (M a)] (f g : Π₀ a, N a)
    {F : ∀ a, N a → M a} (F0 : ∀ a, F a 0 = 0) (hF : ∀ a, Function.Injective (F a)) :
    (f.mapRange F F0).neLocus (g.mapRange F F0) = f.neLocus g := by ext;
  simpa only [mem_ne_locus] using (hF a).ne_iff
#align dfinsupp.map_range_ne_locus_eq Dfinsupp.mapRange_neLocus_eq
-/

end NeLocusAndMaps

variable [∀ a, DecidableEq (N a)]

#print Dfinsupp.neLocus_add_left /-
@[simp]
theorem neLocus_add_left [∀ a, AddLeftCancelMonoid (N a)] (f g h : Π₀ a, N a) :
    (f + g).neLocus (f + h) = g.neLocus h :=
  zipWith_neLocus_eq_left _ _ _ _ fun a => add_right_injective
#align dfinsupp.ne_locus_add_left Dfinsupp.neLocus_add_left
-/

#print Dfinsupp.neLocus_add_right /-
@[simp]
theorem neLocus_add_right [∀ a, AddRightCancelMonoid (N a)] (f g h : Π₀ a, N a) :
    (f + h).neLocus (g + h) = f.neLocus g :=
  zipWith_neLocus_eq_right _ _ _ _ fun a => add_left_injective
#align dfinsupp.ne_locus_add_right Dfinsupp.neLocus_add_right
-/

section AddGroup

variable [∀ a, AddGroup (N a)] (f f₁ f₂ g g₁ g₂ : Π₀ a, N a)

#print Dfinsupp.neLocus_neg_neg /-
@[simp]
theorem neLocus_neg_neg : neLocus (-f) (-g) = f.neLocus g :=
  mapRange_neLocus_eq _ _ (fun a => neg_zero) fun a => neg_injective
#align dfinsupp.ne_locus_neg_neg Dfinsupp.neLocus_neg_neg
-/

#print Dfinsupp.neLocus_neg /-
theorem neLocus_neg : neLocus (-f) g = f.neLocus (-g) := by rw [← ne_locus_neg_neg, neg_neg]
#align dfinsupp.ne_locus_neg Dfinsupp.neLocus_neg
-/

#print Dfinsupp.neLocus_eq_support_sub /-
theorem neLocus_eq_support_sub : f.neLocus g = (f - g).support := by
  rw [← @ne_locus_add_right α N _ _ _ _ _ (-g), add_right_neg, ne_locus_zero_right, sub_eq_add_neg]
#align dfinsupp.ne_locus_eq_support_sub Dfinsupp.neLocus_eq_support_sub
-/

#print Dfinsupp.neLocus_sub_left /-
@[simp]
theorem neLocus_sub_left : neLocus (f - g₁) (f - g₂) = neLocus g₁ g₂ := by
  simp only [sub_eq_add_neg, @ne_locus_add_left α N _ _ _, ne_locus_neg_neg]
#align dfinsupp.ne_locus_sub_left Dfinsupp.neLocus_sub_left
-/

#print Dfinsupp.neLocus_sub_right /-
@[simp]
theorem neLocus_sub_right : neLocus (f₁ - g) (f₂ - g) = neLocus f₁ f₂ := by
  simpa only [sub_eq_add_neg] using @ne_locus_add_right α N _ _ _ _ _ _
#align dfinsupp.ne_locus_sub_right Dfinsupp.neLocus_sub_right
-/

#print Dfinsupp.neLocus_self_add_right /-
@[simp]
theorem neLocus_self_add_right : neLocus f (f + g) = g.support := by
  rw [← ne_locus_zero_left, ← @ne_locus_add_left α N _ _ _ f 0 g, add_zero]
#align dfinsupp.ne_locus_self_add_right Dfinsupp.neLocus_self_add_right
-/

#print Dfinsupp.neLocus_self_add_left /-
@[simp]
theorem neLocus_self_add_left : neLocus (f + g) f = g.support := by
  rw [ne_locus_comm, ne_locus_self_add_right]
#align dfinsupp.ne_locus_self_add_left Dfinsupp.neLocus_self_add_left
-/

#print Dfinsupp.neLocus_self_sub_right /-
@[simp]
theorem neLocus_self_sub_right : neLocus f (f - g) = g.support := by
  rw [sub_eq_add_neg, ne_locus_self_add_right, support_neg]
#align dfinsupp.ne_locus_self_sub_right Dfinsupp.neLocus_self_sub_right
-/

#print Dfinsupp.neLocus_self_sub_left /-
@[simp]
theorem neLocus_self_sub_left : neLocus (f - g) f = g.support := by
  rw [ne_locus_comm, ne_locus_self_sub_right]
#align dfinsupp.ne_locus_self_sub_left Dfinsupp.neLocus_self_sub_left
-/

end AddGroup

end Dfinsupp

