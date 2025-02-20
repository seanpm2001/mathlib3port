/-
Copyright (c) 2020 Zhouhang Zhou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Zhouhang Zhou

! This file was ported from Lean 3 source module algebra.indicator_function
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Support

/-!
# Indicator function

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

- `indicator (s : set α) (f : α → β) (a : α)` is `f a` if `a ∈ s` and is `0` otherwise.
- `mul_indicator (s : set α) (f : α → β) (a : α)` is `f a` if `a ∈ s` and is `1` otherwise.


## Implementation note

In mathematics, an indicator function or a characteristic function is a function
used to indicate membership of an element in a set `s`,
having the value `1` for all elements of `s` and the value `0` otherwise.
But since it is usually used to restrict a function to a certain set `s`,
we let the indicator function take the value `f x` for some function `f`, instead of `1`.
If the usual indicator function is needed, just set `f` to be the constant function `λx, 1`.

The indicator function is implemented non-computably, to avoid having to pass around `decidable`
arguments. This is in contrast with the design of `pi.single` or `set.piecewise`.

## Tags
indicator, characteristic
-/


open scoped BigOperators

open Function

variable {α β ι M N : Type _}

namespace Set

section One

variable [One M] [One N] {s t : Set α} {f g : α → M} {a : α}

#print Set.indicator /-
/-- `indicator s f a` is `f a` if `a ∈ s`, `0` otherwise.  -/
noncomputable def indicator {M} [Zero M] (s : Set α) (f : α → M) : α → M
  | x =>
    haveI := Classical.decPred (· ∈ s)
    if x ∈ s then f x else 0
#align set.indicator Set.indicator
-/

#print Set.mulIndicator /-
/-- `mul_indicator s f a` is `f a` if `a ∈ s`, `1` otherwise.  -/
@[to_additive]
noncomputable def mulIndicator (s : Set α) (f : α → M) : α → M
  | x =>
    haveI := Classical.decPred (· ∈ s)
    if x ∈ s then f x else 1
#align set.mul_indicator Set.mulIndicator
#align set.indicator Set.indicator
-/

#print Set.piecewise_eq_mulIndicator /-
@[simp, to_additive]
theorem piecewise_eq_mulIndicator [DecidablePred (· ∈ s)] : s.piecewise f 1 = s.mulIndicator f :=
  funext fun x => @if_congr _ _ _ _ (id _) _ _ _ _ Iff.rfl rfl rfl
#align set.piecewise_eq_mul_indicator Set.piecewise_eq_mulIndicator
#align set.piecewise_eq_indicator Set.piecewise_eq_indicator
-/

#print Set.mulIndicator_apply /-
@[to_additive]
theorem mulIndicator_apply (s : Set α) (f : α → M) (a : α) [Decidable (a ∈ s)] :
    mulIndicator s f a = if a ∈ s then f a else 1 := by convert rfl
#align set.mul_indicator_apply Set.mulIndicator_apply
#align set.indicator_apply Set.indicator_apply
-/

#print Set.mulIndicator_of_mem /-
@[simp, to_additive]
theorem mulIndicator_of_mem (h : a ∈ s) (f : α → M) : mulIndicator s f a = f a :=
  letI := Classical.dec (a ∈ s)
  if_pos h
#align set.mul_indicator_of_mem Set.mulIndicator_of_mem
#align set.indicator_of_mem Set.indicator_of_mem
-/

#print Set.mulIndicator_of_not_mem /-
@[simp, to_additive]
theorem mulIndicator_of_not_mem (h : a ∉ s) (f : α → M) : mulIndicator s f a = 1 :=
  letI := Classical.dec (a ∈ s)
  if_neg h
#align set.mul_indicator_of_not_mem Set.mulIndicator_of_not_mem
#align set.indicator_of_not_mem Set.indicator_of_not_mem
-/

#print Set.mulIndicator_eq_one_or_self /-
@[to_additive]
theorem mulIndicator_eq_one_or_self (s : Set α) (f : α → M) (a : α) :
    mulIndicator s f a = 1 ∨ mulIndicator s f a = f a :=
  by
  by_cases h : a ∈ s
  · exact Or.inr (mul_indicator_of_mem h f)
  · exact Or.inl (mul_indicator_of_not_mem h f)
#align set.mul_indicator_eq_one_or_self Set.mulIndicator_eq_one_or_self
#align set.indicator_eq_zero_or_self Set.indicator_eq_zero_or_self
-/

#print Set.mulIndicator_apply_eq_self /-
@[simp, to_additive]
theorem mulIndicator_apply_eq_self : s.mulIndicator f a = f a ↔ a ∉ s → f a = 1 :=
  letI := Classical.dec (a ∈ s)
  ite_eq_left_iff.trans (by rw [@eq_comm _ (f a)])
#align set.mul_indicator_apply_eq_self Set.mulIndicator_apply_eq_self
#align set.indicator_apply_eq_self Set.indicator_apply_eq_self
-/

#print Set.mulIndicator_eq_self /-
@[simp, to_additive]
theorem mulIndicator_eq_self : s.mulIndicator f = f ↔ mulSupport f ⊆ s := by
  simp only [funext_iff, subset_def, mem_mul_support, mul_indicator_apply_eq_self, not_imp_comm]
#align set.mul_indicator_eq_self Set.mulIndicator_eq_self
#align set.indicator_eq_self Set.indicator_eq_self
-/

#print Set.mulIndicator_eq_self_of_superset /-
@[to_additive]
theorem mulIndicator_eq_self_of_superset (h1 : s.mulIndicator f = f) (h2 : s ⊆ t) :
    t.mulIndicator f = f := by rw [mul_indicator_eq_self] at h1 ⊢; exact subset.trans h1 h2
#align set.mul_indicator_eq_self_of_superset Set.mulIndicator_eq_self_of_superset
#align set.indicator_eq_self_of_superset Set.indicator_eq_self_of_superset
-/

#print Set.mulIndicator_apply_eq_one /-
@[simp, to_additive]
theorem mulIndicator_apply_eq_one : mulIndicator s f a = 1 ↔ a ∈ s → f a = 1 :=
  letI := Classical.dec (a ∈ s)
  ite_eq_right_iff
#align set.mul_indicator_apply_eq_one Set.mulIndicator_apply_eq_one
#align set.indicator_apply_eq_zero Set.indicator_apply_eq_zero
-/

#print Set.mulIndicator_eq_one /-
@[simp, to_additive]
theorem mulIndicator_eq_one : (mulIndicator s f = fun x => 1) ↔ Disjoint (mulSupport f) s := by
  simp only [funext_iff, mul_indicator_apply_eq_one, Set.disjoint_left, mem_mul_support,
    not_imp_not]
#align set.mul_indicator_eq_one Set.mulIndicator_eq_one
#align set.indicator_eq_zero Set.indicator_eq_zero
-/

#print Set.mulIndicator_eq_one' /-
@[simp, to_additive]
theorem mulIndicator_eq_one' : mulIndicator s f = 1 ↔ Disjoint (mulSupport f) s :=
  mulIndicator_eq_one
#align set.mul_indicator_eq_one' Set.mulIndicator_eq_one'
#align set.indicator_eq_zero' Set.indicator_eq_zero'
-/

#print Set.mulIndicator_apply_ne_one /-
@[to_additive]
theorem mulIndicator_apply_ne_one {a : α} : s.mulIndicator f a ≠ 1 ↔ a ∈ s ∩ mulSupport f := by
  simp only [Ne.def, mul_indicator_apply_eq_one, not_imp, mem_inter_iff, mem_mul_support]
#align set.mul_indicator_apply_ne_one Set.mulIndicator_apply_ne_one
#align set.indicator_apply_ne_zero Set.indicator_apply_ne_zero
-/

#print Set.mulSupport_mulIndicator /-
@[simp, to_additive]
theorem mulSupport_mulIndicator :
    Function.mulSupport (s.mulIndicator f) = s ∩ Function.mulSupport f :=
  ext fun x => by simp [Function.mem_mulSupport, mul_indicator_apply_eq_one]
#align set.mul_support_mul_indicator Set.mulSupport_mulIndicator
#align set.support_indicator Set.support_indicator
-/

#print Set.mem_of_mulIndicator_ne_one /-
/-- If a multiplicative indicator function is not equal to `1` at a point, then that point is in the
set. -/
@[to_additive
      "If an additive indicator function is not equal to `0` at a point, then that point is\nin the set."]
theorem mem_of_mulIndicator_ne_one (h : mulIndicator s f a ≠ 1) : a ∈ s :=
  not_imp_comm.1 (fun hn => mulIndicator_of_not_mem hn f) h
#align set.mem_of_mul_indicator_ne_one Set.mem_of_mulIndicator_ne_one
#align set.mem_of_indicator_ne_zero Set.mem_of_indicator_ne_zero
-/

#print Set.eqOn_mulIndicator /-
@[to_additive]
theorem eqOn_mulIndicator : EqOn (mulIndicator s f) f s := fun x hx => mulIndicator_of_mem hx f
#align set.eq_on_mul_indicator Set.eqOn_mulIndicator
#align set.eq_on_indicator Set.eqOn_indicator
-/

#print Set.mulSupport_mulIndicator_subset /-
@[to_additive]
theorem mulSupport_mulIndicator_subset : mulSupport (s.mulIndicator f) ⊆ s := fun x hx =>
  hx.imp_symm fun h => mulIndicator_of_not_mem h f
#align set.mul_support_mul_indicator_subset Set.mulSupport_mulIndicator_subset
#align set.support_indicator_subset Set.support_indicator_subset
-/

#print Set.mulIndicator_mulSupport /-
@[simp, to_additive]
theorem mulIndicator_mulSupport : mulIndicator (mulSupport f) f = f :=
  mulIndicator_eq_self.2 Subset.rfl
#align set.mul_indicator_mul_support Set.mulIndicator_mulSupport
#align set.indicator_support Set.indicator_support
-/

#print Set.mulIndicator_range_comp /-
@[simp, to_additive]
theorem mulIndicator_range_comp {ι : Sort _} (f : ι → α) (g : α → M) :
    mulIndicator (range f) g ∘ f = g ∘ f :=
  letI := Classical.decPred (· ∈ range f)
  piecewise_range_comp _ _ _
#align set.mul_indicator_range_comp Set.mulIndicator_range_comp
#align set.indicator_range_comp Set.indicator_range_comp
-/

#print Set.mulIndicator_congr /-
@[to_additive]
theorem mulIndicator_congr (h : EqOn f g s) : mulIndicator s f = mulIndicator s g :=
  funext fun x => by simp only [mul_indicator]; split_ifs; · exact h h_1; rfl
#align set.mul_indicator_congr Set.mulIndicator_congr
#align set.indicator_congr Set.indicator_congr
-/

#print Set.mulIndicator_univ /-
@[simp, to_additive]
theorem mulIndicator_univ (f : α → M) : mulIndicator (univ : Set α) f = f :=
  mulIndicator_eq_self.2 <| subset_univ _
#align set.mul_indicator_univ Set.mulIndicator_univ
#align set.indicator_univ Set.indicator_univ
-/

#print Set.mulIndicator_empty /-
@[simp, to_additive]
theorem mulIndicator_empty (f : α → M) : mulIndicator (∅ : Set α) f = fun a => 1 :=
  mulIndicator_eq_one.2 <| disjoint_empty _
#align set.mul_indicator_empty Set.mulIndicator_empty
#align set.indicator_empty Set.indicator_empty
-/

#print Set.mulIndicator_empty' /-
@[to_additive]
theorem mulIndicator_empty' (f : α → M) : mulIndicator (∅ : Set α) f = 1 :=
  mulIndicator_empty f
#align set.mul_indicator_empty' Set.mulIndicator_empty'
#align set.indicator_empty' Set.indicator_empty'
-/

variable (M)

#print Set.mulIndicator_one /-
@[simp, to_additive]
theorem mulIndicator_one (s : Set α) : (mulIndicator s fun x => (1 : M)) = fun x => (1 : M) :=
  mulIndicator_eq_one.2 <| by simp only [mul_support_one, empty_disjoint]
#align set.mul_indicator_one Set.mulIndicator_one
#align set.indicator_zero Set.indicator_zero
-/

#print Set.mulIndicator_one' /-
@[simp, to_additive]
theorem mulIndicator_one' {s : Set α} : s.mulIndicator (1 : α → M) = 1 :=
  mulIndicator_one M s
#align set.mul_indicator_one' Set.mulIndicator_one'
#align set.indicator_zero' Set.indicator_zero'
-/

variable {M}

#print Set.mulIndicator_mulIndicator /-
@[to_additive]
theorem mulIndicator_mulIndicator (s t : Set α) (f : α → M) :
    mulIndicator s (mulIndicator t f) = mulIndicator (s ∩ t) f :=
  funext fun x => by simp only [mul_indicator]; split_ifs;
    repeat' simp_all (config := { contextual := true })
#align set.mul_indicator_mul_indicator Set.mulIndicator_mulIndicator
#align set.indicator_indicator Set.indicator_indicator
-/

#print Set.mulIndicator_inter_mulSupport /-
@[simp, to_additive]
theorem mulIndicator_inter_mulSupport (s : Set α) (f : α → M) :
    mulIndicator (s ∩ mulSupport f) f = mulIndicator s f := by
  rw [← mul_indicator_mul_indicator, mul_indicator_mul_support]
#align set.mul_indicator_inter_mul_support Set.mulIndicator_inter_mulSupport
#align set.indicator_inter_support Set.indicator_inter_support
-/

#print Set.comp_mulIndicator /-
@[to_additive]
theorem comp_mulIndicator (h : M → β) (f : α → M) {s : Set α} {x : α} [DecidablePred (· ∈ s)] :
    h (s.mulIndicator f x) = s.piecewise (h ∘ f) (const α (h 1)) x := by
  letI := Classical.decPred (· ∈ s) <;> convert s.apply_piecewise f (const α 1) fun _ => h
#align set.comp_mul_indicator Set.comp_mulIndicator
#align set.comp_indicator Set.comp_indicator
-/

#print Set.mulIndicator_comp_right /-
@[to_additive]
theorem mulIndicator_comp_right {s : Set α} (f : β → α) {g : α → M} {x : β} :
    mulIndicator (f ⁻¹' s) (g ∘ f) x = mulIndicator s g (f x) := by simp only [mul_indicator];
  split_ifs <;> rfl
#align set.mul_indicator_comp_right Set.mulIndicator_comp_right
#align set.indicator_comp_right Set.indicator_comp_right
-/

#print Set.mulIndicator_image /-
@[to_additive]
theorem mulIndicator_image {s : Set α} {f : β → M} {g : α → β} (hg : Injective g) {x : α} :
    mulIndicator (g '' s) f (g x) = mulIndicator s (f ∘ g) x := by
  rw [← mul_indicator_comp_right, preimage_image_eq _ hg]
#align set.mul_indicator_image Set.mulIndicator_image
#align set.indicator_image Set.indicator_image
-/

#print Set.mulIndicator_comp_of_one /-
@[to_additive]
theorem mulIndicator_comp_of_one {g : M → N} (hg : g 1 = 1) :
    mulIndicator s (g ∘ f) = g ∘ mulIndicator s f :=
  by
  funext
  simp only [mul_indicator]
  split_ifs <;> simp [*]
#align set.mul_indicator_comp_of_one Set.mulIndicator_comp_of_one
#align set.indicator_comp_of_zero Set.indicator_comp_of_zero
-/

#print Set.comp_mulIndicator_const /-
@[to_additive]
theorem comp_mulIndicator_const (c : M) (f : M → N) (hf : f 1 = 1) :
    (fun x => f (s.mulIndicator (fun x => c) x)) = s.mulIndicator fun x => f c :=
  (mulIndicator_comp_of_one hf).symm
#align set.comp_mul_indicator_const Set.comp_mulIndicator_const
#align set.comp_indicator_const Set.comp_indicator_const
-/

#print Set.mulIndicator_preimage /-
@[to_additive]
theorem mulIndicator_preimage (s : Set α) (f : α → M) (B : Set M) :
    mulIndicator s f ⁻¹' B = s.ite (f ⁻¹' B) (1 ⁻¹' B) :=
  letI := Classical.decPred (· ∈ s)
  piecewise_preimage s f 1 B
#align set.mul_indicator_preimage Set.mulIndicator_preimage
#align set.indicator_preimage Set.indicator_preimage
-/

#print Set.mulIndicator_one_preimage /-
@[to_additive]
theorem mulIndicator_one_preimage (s : Set M) :
    t.mulIndicator 1 ⁻¹' s ∈ ({Set.univ, ∅} : Set (Set α)) := by
  classical
  rw [mul_indicator_one', preimage_one]
  split_ifs <;> simp
#align set.mul_indicator_one_preimage Set.mulIndicator_one_preimage
#align set.indicator_zero_preimage Set.indicator_zero_preimage
-/

#print Set.mulIndicator_const_preimage_eq_union /-
@[to_additive]
theorem mulIndicator_const_preimage_eq_union (U : Set α) (s : Set M) (a : M) [Decidable (a ∈ s)]
    [Decidable ((1 : M) ∈ s)] :
    (U.mulIndicator fun x => a) ⁻¹' s = (if a ∈ s then U else ∅) ∪ if (1 : M) ∈ s then Uᶜ else ∅ :=
  by
  rw [mul_indicator_preimage, preimage_one, preimage_const]
  split_ifs <;> simp [← compl_eq_univ_diff]
#align set.mul_indicator_const_preimage_eq_union Set.mulIndicator_const_preimage_eq_union
#align set.indicator_const_preimage_eq_union Set.indicator_const_preimage_eq_union
-/

#print Set.mulIndicator_const_preimage /-
@[to_additive]
theorem mulIndicator_const_preimage (U : Set α) (s : Set M) (a : M) :
    (U.mulIndicator fun x => a) ⁻¹' s ∈ ({Set.univ, U, Uᶜ, ∅} : Set (Set α)) := by
  classical
  rw [mul_indicator_const_preimage_eq_union]
  split_ifs <;> simp
#align set.mul_indicator_const_preimage Set.mulIndicator_const_preimage
#align set.indicator_const_preimage Set.indicator_const_preimage
-/

#print Set.indicator_one_preimage /-
theorem indicator_one_preimage [Zero M] (U : Set α) (s : Set M) :
    U.indicator 1 ⁻¹' s ∈ ({Set.univ, U, Uᶜ, ∅} : Set (Set α)) :=
  indicator_const_preimage _ _ 1
#align set.indicator_one_preimage Set.indicator_one_preimage
-/

#print Set.mulIndicator_preimage_of_not_mem /-
@[to_additive]
theorem mulIndicator_preimage_of_not_mem (s : Set α) (f : α → M) {t : Set M} (ht : (1 : M) ∉ t) :
    mulIndicator s f ⁻¹' t = f ⁻¹' t ∩ s := by
  simp [mul_indicator_preimage, Pi.one_def, Set.preimage_const_of_not_mem ht]
#align set.mul_indicator_preimage_of_not_mem Set.mulIndicator_preimage_of_not_mem
#align set.indicator_preimage_of_not_mem Set.indicator_preimage_of_not_mem
-/

#print Set.mem_range_mulIndicator /-
@[to_additive]
theorem mem_range_mulIndicator {r : M} {s : Set α} {f : α → M} :
    r ∈ range (mulIndicator s f) ↔ r = 1 ∧ s ≠ univ ∨ r ∈ f '' s := by
  simp [mul_indicator, ite_eq_iff, exists_or, eq_univ_iff_forall, and_comm', or_comm',
    @eq_comm _ r 1]
#align set.mem_range_mul_indicator Set.mem_range_mulIndicator
#align set.mem_range_indicator Set.mem_range_indicator
-/

#print Set.mulIndicator_rel_mulIndicator /-
@[to_additive]
theorem mulIndicator_rel_mulIndicator {r : M → M → Prop} (h1 : r 1 1) (ha : a ∈ s → r (f a) (g a)) :
    r (mulIndicator s f a) (mulIndicator s g a) := by simp only [mul_indicator];
  split_ifs with has has; exacts [ha has, h1]
#align set.mul_indicator_rel_mul_indicator Set.mulIndicator_rel_mulIndicator
#align set.indicator_rel_indicator Set.indicator_rel_indicator
-/

end One

section Monoid

variable [MulOneClass M] {s t : Set α} {f g : α → M} {a : α}

#print Set.mulIndicator_union_mul_inter_apply /-
@[to_additive]
theorem mulIndicator_union_mul_inter_apply (f : α → M) (s t : Set α) (a : α) :
    mulIndicator (s ∪ t) f a * mulIndicator (s ∩ t) f a = mulIndicator s f a * mulIndicator t f a :=
  by by_cases hs : a ∈ s <;> by_cases ht : a ∈ t <;> simp [*]
#align set.mul_indicator_union_mul_inter_apply Set.mulIndicator_union_mul_inter_apply
#align set.indicator_union_add_inter_apply Set.indicator_union_add_inter_apply
-/

#print Set.mulIndicator_union_mul_inter /-
@[to_additive]
theorem mulIndicator_union_mul_inter (f : α → M) (s t : Set α) :
    mulIndicator (s ∪ t) f * mulIndicator (s ∩ t) f = mulIndicator s f * mulIndicator t f :=
  funext <| mulIndicator_union_mul_inter_apply f s t
#align set.mul_indicator_union_mul_inter Set.mulIndicator_union_mul_inter
#align set.indicator_union_add_inter Set.indicator_union_add_inter
-/

#print Set.mulIndicator_union_of_not_mem_inter /-
@[to_additive]
theorem mulIndicator_union_of_not_mem_inter (h : a ∉ s ∩ t) (f : α → M) :
    mulIndicator (s ∪ t) f a = mulIndicator s f a * mulIndicator t f a := by
  rw [← mul_indicator_union_mul_inter_apply f s t, mul_indicator_of_not_mem h, mul_one]
#align set.mul_indicator_union_of_not_mem_inter Set.mulIndicator_union_of_not_mem_inter
#align set.indicator_union_of_not_mem_inter Set.indicator_union_of_not_mem_inter
-/

#print Set.mulIndicator_union_of_disjoint /-
@[to_additive]
theorem mulIndicator_union_of_disjoint (h : Disjoint s t) (f : α → M) :
    mulIndicator (s ∪ t) f = fun a => mulIndicator s f a * mulIndicator t f a :=
  funext fun a => mulIndicator_union_of_not_mem_inter (fun ha => h.le_bot ha) _
#align set.mul_indicator_union_of_disjoint Set.mulIndicator_union_of_disjoint
#align set.indicator_union_of_disjoint Set.indicator_union_of_disjoint
-/

#print Set.mulIndicator_mul /-
@[to_additive]
theorem mulIndicator_mul (s : Set α) (f g : α → M) :
    (mulIndicator s fun a => f a * g a) = fun a => mulIndicator s f a * mulIndicator s g a := by
  funext; simp only [mul_indicator]; split_ifs; · rfl; rw [mul_one]
#align set.mul_indicator_mul Set.mulIndicator_mul
#align set.indicator_add Set.indicator_add
-/

#print Set.mulIndicator_mul' /-
@[to_additive]
theorem mulIndicator_mul' (s : Set α) (f g : α → M) :
    mulIndicator s (f * g) = mulIndicator s f * mulIndicator s g :=
  mulIndicator_mul s f g
#align set.mul_indicator_mul' Set.mulIndicator_mul'
#align set.indicator_add' Set.indicator_add'
-/

#print Set.mulIndicator_compl_mul_self_apply /-
@[simp, to_additive]
theorem mulIndicator_compl_mul_self_apply (s : Set α) (f : α → M) (a : α) :
    mulIndicator (sᶜ) f a * mulIndicator s f a = f a :=
  by_cases (fun ha : a ∈ s => by simp [ha]) fun ha => by simp [ha]
#align set.mul_indicator_compl_mul_self_apply Set.mulIndicator_compl_mul_self_apply
#align set.indicator_compl_add_self_apply Set.indicator_compl_add_self_apply
-/

#print Set.mulIndicator_compl_mul_self /-
@[simp, to_additive]
theorem mulIndicator_compl_mul_self (s : Set α) (f : α → M) :
    mulIndicator (sᶜ) f * mulIndicator s f = f :=
  funext <| mulIndicator_compl_mul_self_apply s f
#align set.mul_indicator_compl_mul_self Set.mulIndicator_compl_mul_self
#align set.indicator_compl_add_self Set.indicator_compl_add_self
-/

#print Set.mulIndicator_self_mul_compl_apply /-
@[simp, to_additive]
theorem mulIndicator_self_mul_compl_apply (s : Set α) (f : α → M) (a : α) :
    mulIndicator s f a * mulIndicator (sᶜ) f a = f a :=
  by_cases (fun ha : a ∈ s => by simp [ha]) fun ha => by simp [ha]
#align set.mul_indicator_self_mul_compl_apply Set.mulIndicator_self_mul_compl_apply
#align set.indicator_self_add_compl_apply Set.indicator_self_add_compl_apply
-/

#print Set.mulIndicator_self_mul_compl /-
@[simp, to_additive]
theorem mulIndicator_self_mul_compl (s : Set α) (f : α → M) :
    mulIndicator s f * mulIndicator (sᶜ) f = f :=
  funext <| mulIndicator_self_mul_compl_apply s f
#align set.mul_indicator_self_mul_compl Set.mulIndicator_self_mul_compl
#align set.indicator_self_add_compl Set.indicator_self_add_compl
-/

#print Set.mulIndicator_mul_eq_left /-
@[to_additive]
theorem mulIndicator_mul_eq_left {f g : α → M} (h : Disjoint (mulSupport f) (mulSupport g)) :
    (mulSupport f).mulIndicator (f * g) = f :=
  by
  refine' (mul_indicator_congr fun x hx => _).trans mul_indicator_mul_support
  have : g x = 1 := nmem_mul_support.1 (disjoint_left.1 h hx)
  rw [Pi.mul_apply, this, mul_one]
#align set.mul_indicator_mul_eq_left Set.mulIndicator_mul_eq_left
#align set.indicator_add_eq_left Set.indicator_add_eq_left
-/

#print Set.mulIndicator_mul_eq_right /-
@[to_additive]
theorem mulIndicator_mul_eq_right {f g : α → M} (h : Disjoint (mulSupport f) (mulSupport g)) :
    (mulSupport g).mulIndicator (f * g) = g :=
  by
  refine' (mul_indicator_congr fun x hx => _).trans mul_indicator_mul_support
  have : f x = 1 := nmem_mul_support.1 (disjoint_right.1 h hx)
  rw [Pi.mul_apply, this, one_mul]
#align set.mul_indicator_mul_eq_right Set.mulIndicator_mul_eq_right
#align set.indicator_add_eq_right Set.indicator_add_eq_right
-/

#print Set.mulIndicator_mul_compl_eq_piecewise /-
@[to_additive]
theorem mulIndicator_mul_compl_eq_piecewise [DecidablePred (· ∈ s)] (f g : α → M) :
    s.mulIndicator f * sᶜ.mulIndicator g = s.piecewise f g :=
  by
  ext x
  by_cases h : x ∈ s
  ·
    rw [piecewise_eq_of_mem _ _ _ h, Pi.mul_apply, Set.mulIndicator_of_mem h,
      Set.mulIndicator_of_not_mem (Set.not_mem_compl_iff.2 h), mul_one]
  ·
    rw [piecewise_eq_of_not_mem _ _ _ h, Pi.mul_apply, Set.mulIndicator_of_not_mem h,
      Set.mulIndicator_of_mem (Set.mem_compl h), one_mul]
#align set.mul_indicator_mul_compl_eq_piecewise Set.mulIndicator_mul_compl_eq_piecewise
#align set.indicator_add_compl_eq_piecewise Set.indicator_add_compl_eq_piecewise
-/

#print Set.mulIndicatorHom /-
/-- `set.mul_indicator` as a `monoid_hom`. -/
@[to_additive "`set.indicator` as an `add_monoid_hom`."]
noncomputable def mulIndicatorHom {α} (M) [MulOneClass M] (s : Set α) : (α → M) →* α → M
    where
  toFun := mulIndicator s
  map_one' := mulIndicator_one M s
  map_mul' := mulIndicator_mul s
#align set.mul_indicator_hom Set.mulIndicatorHom
#align set.indicator_hom Set.indicatorHom
-/

end Monoid

section DistribMulAction

variable {A : Type _} [AddMonoid A] [Monoid M] [DistribMulAction M A]

#print Set.indicator_smul_apply /-
theorem indicator_smul_apply (s : Set α) (r : α → M) (f : α → A) (x : α) :
    indicator s (fun x => r x • f x) x = r x • indicator s f x := by dsimp only [indicator];
  split_ifs; exacts [rfl, (smul_zero (r x)).symm]
#align set.indicator_smul_apply Set.indicator_smul_apply
-/

#print Set.indicator_smul /-
theorem indicator_smul (s : Set α) (r : α → M) (f : α → A) :
    (indicator s fun x : α => r x • f x) = fun x : α => r x • indicator s f x :=
  funext <| indicator_smul_apply s r f
#align set.indicator_smul Set.indicator_smul
-/

#print Set.indicator_const_smul_apply /-
theorem indicator_const_smul_apply (s : Set α) (r : M) (f : α → A) (x : α) :
    indicator s (fun x => r • f x) x = r • indicator s f x :=
  indicator_smul_apply s (fun x => r) f x
#align set.indicator_const_smul_apply Set.indicator_const_smul_apply
-/

#print Set.indicator_const_smul /-
theorem indicator_const_smul (s : Set α) (r : M) (f : α → A) :
    (indicator s fun x : α => r • f x) = fun x : α => r • indicator s f x :=
  funext <| indicator_const_smul_apply s r f
#align set.indicator_const_smul Set.indicator_const_smul
-/

end DistribMulAction

section Group

variable {G : Type _} [Group G] {s t : Set α} {f g : α → G} {a : α}

#print Set.mulIndicator_inv' /-
@[to_additive]
theorem mulIndicator_inv' (s : Set α) (f : α → G) : mulIndicator s f⁻¹ = (mulIndicator s f)⁻¹ :=
  (mulIndicatorHom G s).map_inv f
#align set.mul_indicator_inv' Set.mulIndicator_inv'
#align set.indicator_neg' Set.indicator_neg'
-/

#print Set.mulIndicator_inv /-
@[to_additive]
theorem mulIndicator_inv (s : Set α) (f : α → G) :
    (mulIndicator s fun a => (f a)⁻¹) = fun a => (mulIndicator s f a)⁻¹ :=
  mulIndicator_inv' s f
#align set.mul_indicator_inv Set.mulIndicator_inv
#align set.indicator_neg Set.indicator_neg
-/

#print Set.mulIndicator_div /-
@[to_additive]
theorem mulIndicator_div (s : Set α) (f g : α → G) :
    (mulIndicator s fun a => f a / g a) = fun a => mulIndicator s f a / mulIndicator s g a :=
  (mulIndicatorHom G s).map_div f g
#align set.mul_indicator_div Set.mulIndicator_div
#align set.indicator_sub Set.indicator_sub
-/

#print Set.mulIndicator_div' /-
@[to_additive]
theorem mulIndicator_div' (s : Set α) (f g : α → G) :
    mulIndicator s (f / g) = mulIndicator s f / mulIndicator s g :=
  mulIndicator_div s f g
#align set.mul_indicator_div' Set.mulIndicator_div'
#align set.indicator_sub' Set.indicator_sub'
-/

#print Set.mulIndicator_compl /-
@[to_additive indicator_compl']
theorem mulIndicator_compl (s : Set α) (f : α → G) :
    mulIndicator (sᶜ) f = f * (mulIndicator s f)⁻¹ :=
  eq_mul_inv_of_mul_eq <| s.mulIndicator_compl_mul_self f
#align set.mul_indicator_compl Set.mulIndicator_compl
#align set.indicator_compl' Set.indicator_compl'
-/

#print Set.indicator_compl /-
theorem indicator_compl {G} [AddGroup G] (s : Set α) (f : α → G) :
    indicator (sᶜ) f = f - indicator s f := by rw [sub_eq_add_neg, indicator_compl']
#align set.indicator_compl Set.indicator_compl
-/

#print Set.mulIndicator_diff /-
@[to_additive indicator_diff']
theorem mulIndicator_diff (h : s ⊆ t) (f : α → G) :
    mulIndicator (t \ s) f = mulIndicator t f * (mulIndicator s f)⁻¹ :=
  eq_mul_inv_of_mul_eq <|
    by
    rw [Pi.mul_def, ← mul_indicator_union_of_disjoint, diff_union_self,
      union_eq_self_of_subset_right h]
    exact disjoint_sdiff_self_left
#align set.mul_indicator_diff Set.mulIndicator_diff
#align set.indicator_diff' Set.indicator_diff'
-/

#print Set.indicator_diff /-
theorem indicator_diff {G : Type _} [AddGroup G] {s t : Set α} (h : s ⊆ t) (f : α → G) :
    indicator (t \ s) f = indicator t f - indicator s f := by rw [indicator_diff' h, sub_eq_add_neg]
#align set.indicator_diff Set.indicator_diff
-/

end Group

section CommMonoid

variable [CommMonoid M]

#print Set.prod_mulIndicator_subset_of_eq_one /-
/-- Consider a product of `g i (f i)` over a `finset`.  Suppose `g` is a
function such as `pow`, which maps a second argument of `1` to
`1`. Then if `f` is replaced by the corresponding multiplicative indicator
function, the `finset` may be replaced by a possibly larger `finset`
without changing the value of the sum. -/
@[to_additive]
theorem prod_mulIndicator_subset_of_eq_one [One N] (f : α → N) (g : α → N → M) {s t : Finset α}
    (h : s ⊆ t) (hg : ∀ a, g a 1 = 1) :
    ∏ i in s, g i (f i) = ∏ i in t, g i (mulIndicator (↑s) f i) :=
  by
  rw [← Finset.prod_subset h _]
  · apply Finset.prod_congr rfl
    intro i hi
    congr
    symm
    exact mul_indicator_of_mem hi _
  · refine' fun i hi hn => _
    convert hg i
    exact mul_indicator_of_not_mem hn _
#align set.prod_mul_indicator_subset_of_eq_one Set.prod_mulIndicator_subset_of_eq_one
#align set.sum_indicator_subset_of_eq_zero Set.sum_indicator_subset_of_eq_zero
-/

/-- Consider a sum of `g i (f i)` over a `finset`. Suppose `g` is a
function such as multiplication, which maps a second argument of 0 to
0.  (A typical use case would be a weighted sum of `f i * h i` or `f i
• h i`, where `f` gives the weights that are multiplied by some other
function `h`.)  Then if `f` is replaced by the corresponding indicator
function, the `finset` may be replaced by a possibly larger `finset`
without changing the value of the sum. -/
add_decl_doc Set.sum_indicator_subset_of_eq_zero

#print Set.prod_mulIndicator_subset /-
/-- Taking the product of an indicator function over a possibly larger `finset` is the same as
taking the original function over the original `finset`. -/
@[to_additive
      "Summing an indicator function over a possibly larger `finset` is the same as summing\nthe original function over the original `finset`."]
theorem prod_mulIndicator_subset (f : α → M) {s t : Finset α} (h : s ⊆ t) :
    ∏ i in s, f i = ∏ i in t, mulIndicator (↑s) f i :=
  prod_mulIndicator_subset_of_eq_one _ (fun a b => b) h fun _ => rfl
#align set.prod_mul_indicator_subset Set.prod_mulIndicator_subset
#align set.sum_indicator_subset Set.sum_indicator_subset
-/

#print Finset.prod_mulIndicator_eq_prod_filter /-
@[to_additive]
theorem Finset.prod_mulIndicator_eq_prod_filter (s : Finset ι) (f : ι → α → M) (t : ι → Set α)
    (g : ι → α) [DecidablePred fun i => g i ∈ t i] :
    ∏ i in s, mulIndicator (t i) (f i) (g i) = ∏ i in s.filterₓ fun i => g i ∈ t i, f i (g i) :=
  by
  refine' (Finset.prod_filter_mul_prod_filter_not s (fun i => g i ∈ t i) _).symm.trans _
  refine' Eq.trans _ (mul_one _)
  exact
    congr_arg₂ (· * ·)
      (Finset.prod_congr rfl fun x hx => mul_indicator_of_mem (Finset.mem_filter.1 hx).2 _)
      (Finset.prod_eq_one fun x hx => mul_indicator_of_not_mem (Finset.mem_filter.1 hx).2 _)
#align finset.prod_mul_indicator_eq_prod_filter Finset.prod_mulIndicator_eq_prod_filter
#align finset.sum_indicator_eq_sum_filter Finset.sum_indicator_eq_sum_filter
-/

#print Set.mulIndicator_finset_prod /-
@[to_additive]
theorem mulIndicator_finset_prod (I : Finset ι) (s : Set α) (f : ι → α → M) :
    mulIndicator s (∏ i in I, f i) = ∏ i in I, mulIndicator s (f i) :=
  (mulIndicatorHom M s).map_prod _ _
#align set.mul_indicator_finset_prod Set.mulIndicator_finset_prod
#align set.indicator_finset_sum Set.indicator_finset_sum
-/

#print Set.mulIndicator_finset_biUnion /-
@[to_additive]
theorem mulIndicator_finset_biUnion {ι} (I : Finset ι) (s : ι → Set α) {f : α → M} :
    (∀ i ∈ I, ∀ j ∈ I, i ≠ j → Disjoint (s i) (s j)) →
      mulIndicator (⋃ i ∈ I, s i) f = fun a => ∏ i in I, mulIndicator (s i) f a :=
  by
  classical
  refine' Finset.induction_on I _ _
  · intro h; funext; simp
  intro a I haI ih hI
  funext
  rw [Finset.prod_insert haI, Finset.set_biUnion_insert, mul_indicator_union_of_not_mem_inter, ih _]
  · intro i hi j hj hij
    exact hI i (Finset.mem_insert_of_mem hi) j (Finset.mem_insert_of_mem hj) hij
  simp only [not_exists, exists_prop, mem_Union, mem_inter_iff, not_and]
  intro hx a' ha'
  refine' disjoint_left.1 (hI a (Finset.mem_insert_self _ _) a' (Finset.mem_insert_of_mem ha') _) hx
  exact (ne_of_mem_of_not_mem ha' haI).symm
#align set.mul_indicator_finset_bUnion Set.mulIndicator_finset_biUnion
#align set.indicator_finset_bUnion Set.indicator_finset_biUnion
-/

#print Set.mulIndicator_finset_biUnion_apply /-
@[to_additive]
theorem mulIndicator_finset_biUnion_apply {ι} (I : Finset ι) (s : ι → Set α) {f : α → M}
    (h : ∀ i ∈ I, ∀ j ∈ I, i ≠ j → Disjoint (s i) (s j)) (x : α) :
    mulIndicator (⋃ i ∈ I, s i) f x = ∏ i in I, mulIndicator (s i) f x := by
  rw [Set.mulIndicator_finset_biUnion I s h]
#align set.mul_indicator_finset_bUnion_apply Set.mulIndicator_finset_biUnion_apply
#align set.indicator_finset_bUnion_apply Set.indicator_finset_biUnion_apply
-/

end CommMonoid

section MulZeroClass

variable [MulZeroClass M] {s t : Set α} {f g : α → M} {a : α}

#print Set.indicator_mul /-
theorem indicator_mul (s : Set α) (f g : α → M) :
    (indicator s fun a => f a * g a) = fun a => indicator s f a * indicator s g a := by funext;
  simp only [indicator]; split_ifs; · rfl; rw [MulZeroClass.mul_zero]
#align set.indicator_mul Set.indicator_mul
-/

#print Set.indicator_mul_left /-
theorem indicator_mul_left (s : Set α) (f g : α → M) :
    indicator s (fun a => f a * g a) a = indicator s f a * g a := by simp only [indicator];
  split_ifs; · rfl; rw [MulZeroClass.zero_mul]
#align set.indicator_mul_left Set.indicator_mul_left
-/

#print Set.indicator_mul_right /-
theorem indicator_mul_right (s : Set α) (f g : α → M) :
    indicator s (fun a => f a * g a) a = f a * indicator s g a := by simp only [indicator];
  split_ifs; · rfl; rw [MulZeroClass.mul_zero]
#align set.indicator_mul_right Set.indicator_mul_right
-/

#print Set.inter_indicator_mul /-
theorem inter_indicator_mul {t1 t2 : Set α} (f g : α → M) (x : α) :
    (t1 ∩ t2).indicator (fun x => f x * g x) x = t1.indicator f x * t2.indicator g x := by
  rw [← Set.indicator_indicator]; simp [indicator]
#align set.inter_indicator_mul Set.inter_indicator_mul
-/

end MulZeroClass

section MulZeroOneClass

variable [MulZeroOneClass M]

#print Set.inter_indicator_one /-
theorem inter_indicator_one {s t : Set α} :
    (s ∩ t).indicator (1 : _ → M) = s.indicator 1 * t.indicator 1 :=
  funext fun _ => by simpa only [← inter_indicator_mul, Pi.mul_apply, Pi.one_apply, one_mul]
#align set.inter_indicator_one Set.inter_indicator_one
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Set.indicator_prod_one /-
theorem indicator_prod_one {s : Set α} {t : Set β} {x : α} {y : β} :
    (s ×ˢ t).indicator (1 : _ → M) (x, y) = s.indicator 1 x * t.indicator 1 y := by
  classical simp [indicator_apply, ← ite_and]
#align set.indicator_prod_one Set.indicator_prod_one
-/

variable (M) [Nontrivial M]

#print Set.indicator_eq_zero_iff_not_mem /-
theorem indicator_eq_zero_iff_not_mem {U : Set α} {x : α} : indicator U 1 x = (0 : M) ↔ x ∉ U := by
  classical simp [indicator_apply, imp_false]
#align set.indicator_eq_zero_iff_not_mem Set.indicator_eq_zero_iff_not_mem
-/

#print Set.indicator_eq_one_iff_mem /-
theorem indicator_eq_one_iff_mem {U : Set α} {x : α} : indicator U 1 x = (1 : M) ↔ x ∈ U := by
  classical simp [indicator_apply, imp_false]
#align set.indicator_eq_one_iff_mem Set.indicator_eq_one_iff_mem
-/

#print Set.indicator_one_inj /-
theorem indicator_one_inj {U V : Set α} (h : indicator U (1 : α → M) = indicator V 1) : U = V := by
  ext; simp_rw [← indicator_eq_one_iff_mem M, h]
#align set.indicator_one_inj Set.indicator_one_inj
-/

end MulZeroOneClass

section Order

variable [One M] {s t : Set α} {f g : α → M} {a : α} {y : M}

section

variable [LE M]

#print Set.mulIndicator_apply_le' /-
@[to_additive]
theorem mulIndicator_apply_le' (hfg : a ∈ s → f a ≤ y) (hg : a ∉ s → 1 ≤ y) :
    mulIndicator s f a ≤ y := by
  by_cases ha : a ∈ s
  · simpa [ha] using hfg ha
  · simpa [ha] using hg ha
#align set.mul_indicator_apply_le' Set.mulIndicator_apply_le'
#align set.indicator_apply_le' Set.indicator_apply_le'
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (a «expr ∉ » s) -/
#print Set.mulIndicator_le' /-
@[to_additive]
theorem mulIndicator_le' (hfg : ∀ a ∈ s, f a ≤ g a) (hg : ∀ (a) (_ : a ∉ s), 1 ≤ g a) :
    mulIndicator s f ≤ g := fun a => mulIndicator_apply_le' (hfg _) (hg _)
#align set.mul_indicator_le' Set.mulIndicator_le'
#align set.indicator_le' Set.indicator_le'
-/

#print Set.le_mulIndicator_apply /-
@[to_additive]
theorem le_mulIndicator_apply {y} (hfg : a ∈ s → y ≤ g a) (hf : a ∉ s → y ≤ 1) :
    y ≤ mulIndicator s g a :=
  @mulIndicator_apply_le' α Mᵒᵈ ‹_› _ _ _ _ _ hfg hf
#align set.le_mul_indicator_apply Set.le_mulIndicator_apply
#align set.le_indicator_apply Set.le_indicator_apply
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (a «expr ∉ » s) -/
#print Set.le_mulIndicator /-
@[to_additive]
theorem le_mulIndicator (hfg : ∀ a ∈ s, f a ≤ g a) (hf : ∀ (a) (_ : a ∉ s), f a ≤ 1) :
    f ≤ mulIndicator s g := fun a => le_mulIndicator_apply (hfg _) (hf _)
#align set.le_mul_indicator Set.le_mulIndicator
#align set.le_indicator Set.le_indicator
-/

end

variable [Preorder M]

#print Set.one_le_mulIndicator_apply /-
@[to_additive indicator_apply_nonneg]
theorem one_le_mulIndicator_apply (h : a ∈ s → 1 ≤ f a) : 1 ≤ mulIndicator s f a :=
  le_mulIndicator_apply h fun _ => le_rfl
#align set.one_le_mul_indicator_apply Set.one_le_mulIndicator_apply
#align set.indicator_apply_nonneg Set.indicator_apply_nonneg
-/

#print Set.one_le_mulIndicator /-
@[to_additive indicator_nonneg]
theorem one_le_mulIndicator (h : ∀ a ∈ s, 1 ≤ f a) (a : α) : 1 ≤ mulIndicator s f a :=
  one_le_mulIndicator_apply (h a)
#align set.one_le_mul_indicator Set.one_le_mulIndicator
#align set.indicator_nonneg Set.indicator_nonneg
-/

#print Set.mulIndicator_apply_le_one /-
@[to_additive]
theorem mulIndicator_apply_le_one (h : a ∈ s → f a ≤ 1) : mulIndicator s f a ≤ 1 :=
  mulIndicator_apply_le' h fun _ => le_rfl
#align set.mul_indicator_apply_le_one Set.mulIndicator_apply_le_one
#align set.indicator_apply_nonpos Set.indicator_apply_nonpos
-/

#print Set.mulIndicator_le_one /-
@[to_additive]
theorem mulIndicator_le_one (h : ∀ a ∈ s, f a ≤ 1) (a : α) : mulIndicator s f a ≤ 1 :=
  mulIndicator_apply_le_one (h a)
#align set.mul_indicator_le_one Set.mulIndicator_le_one
#align set.indicator_nonpos Set.indicator_nonpos
-/

#print Set.mulIndicator_le_mulIndicator /-
@[to_additive]
theorem mulIndicator_le_mulIndicator (h : f a ≤ g a) : mulIndicator s f a ≤ mulIndicator s g a :=
  mulIndicator_rel_mulIndicator le_rfl fun _ => h
#align set.mul_indicator_le_mul_indicator Set.mulIndicator_le_mulIndicator
#align set.indicator_le_indicator Set.indicator_le_indicator
-/

attribute [mono] mul_indicator_le_mul_indicator indicator_le_indicator

#print Set.mulIndicator_le_mulIndicator_of_subset /-
@[to_additive]
theorem mulIndicator_le_mulIndicator_of_subset (h : s ⊆ t) (hf : ∀ a, 1 ≤ f a) (a : α) :
    mulIndicator s f a ≤ mulIndicator t f a :=
  mulIndicator_apply_le'
    (fun ha => le_mulIndicator_apply (fun _ => le_rfl) fun hat => (hat <| h ha).elim) fun ha =>
    one_le_mulIndicator_apply fun _ => hf _
#align set.mul_indicator_le_mul_indicator_of_subset Set.mulIndicator_le_mulIndicator_of_subset
#align set.indicator_le_indicator_of_subset Set.indicator_le_indicator_of_subset
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x «expr ∉ » s) -/
#print Set.mulIndicator_le_self' /-
@[to_additive]
theorem mulIndicator_le_self' (hf : ∀ (x) (_ : x ∉ s), 1 ≤ f x) : mulIndicator s f ≤ f :=
  mulIndicator_le' (fun _ _ => le_rfl) hf
#align set.mul_indicator_le_self' Set.mulIndicator_le_self'
#align set.indicator_le_self' Set.indicator_le_self'
-/

#print Set.mulIndicator_iUnion_apply /-
@[to_additive]
theorem mulIndicator_iUnion_apply {ι M} [CompleteLattice M] [One M] (h1 : (⊥ : M) = 1)
    (s : ι → Set α) (f : α → M) (x : α) :
    mulIndicator (⋃ i, s i) f x = ⨆ i, mulIndicator (s i) f x :=
  by
  by_cases hx : x ∈ ⋃ i, s i
  · rw [mul_indicator_of_mem hx]
    rw [mem_Union] at hx 
    refine' le_antisymm _ (iSup_le fun i => mul_indicator_le_self' (fun x hx => h1 ▸ bot_le) x)
    rcases hx with ⟨i, hi⟩
    exact le_iSup_of_le i (ge_of_eq <| mul_indicator_of_mem hi _)
  · rw [mul_indicator_of_not_mem hx]
    simp only [mem_Union, not_exists] at hx 
    simp [hx, ← h1]
#align set.mul_indicator_Union_apply Set.mulIndicator_iUnion_apply
#align set.indicator_Union_apply Set.indicator_iUnion_apply
-/

end Order

section CanonicallyOrderedMonoid

variable [CanonicallyOrderedMonoid M]

#print Set.mulIndicator_le_self /-
@[to_additive]
theorem mulIndicator_le_self (s : Set α) (f : α → M) : mulIndicator s f ≤ f :=
  mulIndicator_le_self' fun _ _ => one_le _
#align set.mul_indicator_le_self Set.mulIndicator_le_self
#align set.indicator_le_self Set.indicator_le_self
-/

#print Set.mulIndicator_apply_le /-
@[to_additive]
theorem mulIndicator_apply_le {a : α} {s : Set α} {f g : α → M} (hfg : a ∈ s → f a ≤ g a) :
    mulIndicator s f a ≤ g a :=
  mulIndicator_apply_le' hfg fun _ => one_le _
#align set.mul_indicator_apply_le Set.mulIndicator_apply_le
#align set.indicator_apply_le Set.indicator_apply_le
-/

#print Set.mulIndicator_le /-
@[to_additive]
theorem mulIndicator_le {s : Set α} {f g : α → M} (hfg : ∀ a ∈ s, f a ≤ g a) :
    mulIndicator s f ≤ g :=
  mulIndicator_le' hfg fun _ _ => one_le _
#align set.mul_indicator_le Set.mulIndicator_le
#align set.indicator_le Set.indicator_le
-/

end CanonicallyOrderedMonoid

#print Set.indicator_le_indicator_nonneg /-
theorem indicator_le_indicator_nonneg {β} [LinearOrder β] [Zero β] (s : Set α) (f : α → β) :
    s.indicator f ≤ {x | 0 ≤ f x}.indicator f :=
  by
  intro x
  classical
  simp_rw [indicator_apply]
  split_ifs
  · exact le_rfl
  · exact (not_le.mp h_1).le
  · exact h_1
  · exact le_rfl
#align set.indicator_le_indicator_nonneg Set.indicator_le_indicator_nonneg
-/

#print Set.indicator_nonpos_le_indicator /-
theorem indicator_nonpos_le_indicator {β} [LinearOrder β] [Zero β] (s : Set α) (f : α → β) :
    {x | f x ≤ 0}.indicator f ≤ s.indicator f :=
  @indicator_le_indicator_nonneg α βᵒᵈ _ _ s f
#align set.indicator_nonpos_le_indicator Set.indicator_nonpos_le_indicator
-/

end Set

#print MonoidHom.map_mulIndicator /-
@[to_additive]
theorem MonoidHom.map_mulIndicator {M N : Type _} [MulOneClass M] [MulOneClass N] (f : M →* N)
    (s : Set α) (g : α → M) (x : α) : f (s.mulIndicator g x) = s.mulIndicator (f ∘ g) x :=
  congr_fun (Set.mulIndicator_comp_of_one f.map_one).symm x
#align monoid_hom.map_mul_indicator MonoidHom.map_mulIndicator
#align add_monoid_hom.map_indicator AddMonoidHom.map_indicator
-/

