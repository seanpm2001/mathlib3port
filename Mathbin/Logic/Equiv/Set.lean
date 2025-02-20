/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Mario Carneiro

! This file was ported from Lean 3 source module logic.equiv.set
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Function
import Mathbin.Logic.Equiv.Defs

/-!
# Equivalences and sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we provide lemmas linking equivalences to sets.

Some notable definitions are:

* `equiv.of_injective`: an injective function is (noncomputably) equivalent to its range.
* `equiv.set_congr`: two equal sets are equivalent as types.
* `equiv.set.union`: a disjoint union of sets is equivalent to their `sum`.

This file is separate from `equiv/basic` such that we do not require the full lattice structure
on sets before defining what an equivalence is.
-/


open Function Set

universe u v w z

variable {α : Sort u} {β : Sort v} {γ : Sort w}

namespace Equiv

#print Equiv.range_eq_univ /-
@[simp]
theorem range_eq_univ {α : Type _} {β : Type _} (e : α ≃ β) : range e = univ :=
  eq_univ_of_forall e.Surjective
#align equiv.range_eq_univ Equiv.range_eq_univ
-/

#print Equiv.image_eq_preimage /-
protected theorem image_eq_preimage {α β} (e : α ≃ β) (s : Set α) : e '' s = e.symm ⁻¹' s :=
  Set.ext fun x => mem_image_iff_of_inverse e.left_inv e.right_inv
#align equiv.image_eq_preimage Equiv.image_eq_preimage
-/

#print Set.mem_image_equiv /-
theorem Set.mem_image_equiv {α β} {S : Set α} {f : α ≃ β} {x : β} : x ∈ f '' S ↔ f.symm x ∈ S :=
  Set.ext_iff.mp (f.image_eq_preimage S) x
#align set.mem_image_equiv Set.mem_image_equiv
-/

#print Set.image_equiv_eq_preimage_symm /-
/-- Alias for `equiv.image_eq_preimage` -/
theorem Set.image_equiv_eq_preimage_symm {α β} (S : Set α) (f : α ≃ β) : f '' S = f.symm ⁻¹' S :=
  f.image_eq_preimage S
#align set.image_equiv_eq_preimage_symm Set.image_equiv_eq_preimage_symm
-/

#print Set.preimage_equiv_eq_image_symm /-
/-- Alias for `equiv.image_eq_preimage` -/
theorem Set.preimage_equiv_eq_image_symm {α β} (S : Set α) (f : β ≃ α) : f ⁻¹' S = f.symm '' S :=
  (f.symm.image_eq_preimage S).symm
#align set.preimage_equiv_eq_image_symm Set.preimage_equiv_eq_image_symm
-/

#print Equiv.subset_image /-
@[simp]
protected theorem subset_image {α β} (e : α ≃ β) (s : Set α) (t : Set β) :
    e.symm '' t ⊆ s ↔ t ⊆ e '' s := by rw [image_subset_iff, e.image_eq_preimage]
#align equiv.subset_image Equiv.subset_image
-/

#print Equiv.subset_image' /-
@[simp]
protected theorem subset_image' {α β} (e : α ≃ β) (s : Set α) (t : Set β) :
    s ⊆ e.symm '' t ↔ e '' s ⊆ t :=
  calc
    s ⊆ e.symm '' t ↔ e.symm.symm '' s ⊆ t := by rw [e.symm.subset_image]
    _ ↔ e '' s ⊆ t := by rw [e.symm_symm]
#align equiv.subset_image' Equiv.subset_image'
-/

#print Equiv.symm_image_image /-
@[simp]
theorem symm_image_image {α β} (e : α ≃ β) (s : Set α) : e.symm '' (e '' s) = s :=
  e.leftInverse_symm.image_image s
#align equiv.symm_image_image Equiv.symm_image_image
-/

#print Equiv.eq_image_iff_symm_image_eq /-
theorem eq_image_iff_symm_image_eq {α β} (e : α ≃ β) (s : Set α) (t : Set β) :
    t = e '' s ↔ e.symm '' t = s :=
  (e.symm.Injective.image_injective.eq_iff' (e.symm_image_image s)).symm
#align equiv.eq_image_iff_symm_image_eq Equiv.eq_image_iff_symm_image_eq
-/

#print Equiv.image_symm_image /-
@[simp]
theorem image_symm_image {α β} (e : α ≃ β) (s : Set β) : e '' (e.symm '' s) = s :=
  e.symm.symm_image_image s
#align equiv.image_symm_image Equiv.image_symm_image
-/

#print Equiv.image_preimage /-
@[simp]
theorem image_preimage {α β} (e : α ≃ β) (s : Set β) : e '' (e ⁻¹' s) = s :=
  e.Surjective.image_preimage s
#align equiv.image_preimage Equiv.image_preimage
-/

#print Equiv.preimage_image /-
@[simp]
theorem preimage_image {α β} (e : α ≃ β) (s : Set α) : e ⁻¹' (e '' s) = s :=
  e.Injective.preimage_image s
#align equiv.preimage_image Equiv.preimage_image
-/

#print Equiv.image_compl /-
protected theorem image_compl {α β} (f : Equiv α β) (s : Set α) : f '' sᶜ = (f '' s)ᶜ :=
  image_compl_eq f.Bijective
#align equiv.image_compl Equiv.image_compl
-/

#print Equiv.symm_preimage_preimage /-
@[simp]
theorem symm_preimage_preimage {α β} (e : α ≃ β) (s : Set β) : e.symm ⁻¹' (e ⁻¹' s) = s :=
  e.rightInverse_symm.preimage_preimage s
#align equiv.symm_preimage_preimage Equiv.symm_preimage_preimage
-/

#print Equiv.preimage_symm_preimage /-
@[simp]
theorem preimage_symm_preimage {α β} (e : α ≃ β) (s : Set α) : e ⁻¹' (e.symm ⁻¹' s) = s :=
  e.leftInverse_symm.preimage_preimage s
#align equiv.preimage_symm_preimage Equiv.preimage_symm_preimage
-/

#print Equiv.preimage_subset /-
@[simp]
theorem preimage_subset {α β} (e : α ≃ β) (s t : Set β) : e ⁻¹' s ⊆ e ⁻¹' t ↔ s ⊆ t :=
  e.Surjective.preimage_subset_preimage_iff
#align equiv.preimage_subset Equiv.preimage_subset
-/

#print Equiv.image_subset /-
@[simp]
theorem image_subset {α β} (e : α ≃ β) (s t : Set α) : e '' s ⊆ e '' t ↔ s ⊆ t :=
  image_subset_image_iff e.Injective
#align equiv.image_subset Equiv.image_subset
-/

#print Equiv.image_eq_iff_eq /-
@[simp]
theorem image_eq_iff_eq {α β} (e : α ≃ β) (s t : Set α) : e '' s = e '' t ↔ s = t :=
  image_eq_image e.Injective
#align equiv.image_eq_iff_eq Equiv.image_eq_iff_eq
-/

#print Equiv.preimage_eq_iff_eq_image /-
theorem preimage_eq_iff_eq_image {α β} (e : α ≃ β) (s t) : e ⁻¹' s = t ↔ s = e '' t :=
  preimage_eq_iff_eq_image e.Bijective
#align equiv.preimage_eq_iff_eq_image Equiv.preimage_eq_iff_eq_image
-/

#print Equiv.eq_preimage_iff_image_eq /-
theorem eq_preimage_iff_image_eq {α β} (e : α ≃ β) (s t) : s = e ⁻¹' t ↔ e '' s = t :=
  eq_preimage_iff_image_eq e.Bijective
#align equiv.eq_preimage_iff_image_eq Equiv.eq_preimage_iff_image_eq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Equiv.prod_assoc_preimage /-
@[simp]
theorem prod_assoc_preimage {α β γ} {s : Set α} {t : Set β} {u : Set γ} :
    Equiv.prodAssoc α β γ ⁻¹' s ×ˢ t ×ˢ u = (s ×ˢ t) ×ˢ u := by ext; simp [and_assoc']
#align equiv.prod_assoc_preimage Equiv.prod_assoc_preimage
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Equiv.prod_assoc_symm_preimage /-
@[simp]
theorem prod_assoc_symm_preimage {α β γ} {s : Set α} {t : Set β} {u : Set γ} :
    (Equiv.prodAssoc α β γ).symm ⁻¹' (s ×ˢ t) ×ˢ u = s ×ˢ t ×ˢ u := by ext; simp [and_assoc']
#align equiv.prod_assoc_symm_preimage Equiv.prod_assoc_symm_preimage
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Equiv.prod_assoc_image /-
-- `@[simp]` doesn't like these lemmas, as it uses `set.image_congr'` to turn `equiv.prod_assoc`
-- into a lambda expression and then unfold it.
theorem prod_assoc_image {α β γ} {s : Set α} {t : Set β} {u : Set γ} :
    Equiv.prodAssoc α β γ '' (s ×ˢ t) ×ˢ u = s ×ˢ t ×ˢ u := by
  simpa only [Equiv.image_eq_preimage] using prod_assoc_symm_preimage
#align equiv.prod_assoc_image Equiv.prod_assoc_image
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Equiv.prod_assoc_symm_image /-
theorem prod_assoc_symm_image {α β γ} {s : Set α} {t : Set β} {u : Set γ} :
    (Equiv.prodAssoc α β γ).symm '' s ×ˢ t ×ˢ u = (s ×ˢ t) ×ˢ u := by
  simpa only [Equiv.image_eq_preimage] using prod_assoc_preimage
#align equiv.prod_assoc_symm_image Equiv.prod_assoc_symm_image
-/

#print Equiv.setProdEquivSigma /-
/-- A set `s` in `α × β` is equivalent to the sigma-type `Σ x, {y | (x, y) ∈ s}`. -/
def setProdEquivSigma {α β : Type _} (s : Set (α × β)) : s ≃ Σ x : α, {y | (x, y) ∈ s}
    where
  toFun x := ⟨x.1.1, x.1.2, by simp⟩
  invFun x := ⟨(x.1, x.2.1), x.2.2⟩
  left_inv := fun ⟨⟨x, y⟩, h⟩ => rfl
  right_inv := fun ⟨x, y, h⟩ => rfl
#align equiv.set_prod_equiv_sigma Equiv.setProdEquivSigma
-/

#print Equiv.setCongr /-
/-- The subtypes corresponding to equal sets are equivalent. -/
@[simps apply]
def setCongr {α : Type _} {s t : Set α} (h : s = t) : s ≃ t :=
  subtypeEquivProp h
#align equiv.set_congr Equiv.setCongr
-/

#print Equiv.image /-
-- We could construct this using `equiv.set.image e s e.injective`,
-- but this definition provides an explicit inverse.
/-- A set is equivalent to its image under an equivalence.
-/
@[simps]
def image {α β : Type _} (e : α ≃ β) (s : Set α) : s ≃ e '' s
    where
  toFun x := ⟨e x.1, by simp⟩
  invFun y := ⟨e.symm y.1, by rcases y with ⟨-, ⟨a, ⟨m, rfl⟩⟩⟩; simpa using m⟩
  left_inv x := by simp
  right_inv y := by simp
#align equiv.image Equiv.image
-/

namespace Set

#print Equiv.Set.univ /-
/-- `univ α` is equivalent to `α`. -/
@[simps apply symm_apply]
protected def univ (α) : @univ α ≃ α :=
  ⟨coe, fun a => ⟨a, trivial⟩, fun ⟨a, _⟩ => rfl, fun a => rfl⟩
#align equiv.set.univ Equiv.Set.univ
-/

#print Equiv.Set.empty /-
/-- An empty set is equivalent to the `empty` type. -/
protected def empty (α) : (∅ : Set α) ≃ Empty :=
  equivEmpty _
#align equiv.set.empty Equiv.Set.empty
-/

#print Equiv.Set.pempty /-
/-- An empty set is equivalent to a `pempty` type. -/
protected def pempty (α) : (∅ : Set α) ≃ PEmpty :=
  equivPEmpty _
#align equiv.set.pempty Equiv.Set.pempty
-/

#print Equiv.Set.union' /-
/-- If sets `s` and `t` are separated by a decidable predicate, then `s ∪ t` is equivalent to
`s ⊕ t`. -/
protected def union' {α} {s t : Set α} (p : α → Prop) [DecidablePred p] (hs : ∀ x ∈ s, p x)
    (ht : ∀ x ∈ t, ¬p x) : (s ∪ t : Set α) ≃ Sum s t
    where
  toFun x :=
    if hp : p x then Sum.inl ⟨_, x.2.resolve_right fun xt => ht _ xt hp⟩
    else Sum.inr ⟨_, x.2.resolve_left fun xs => hp (hs _ xs)⟩
  invFun o :=
    match o with
    | Sum.inl x => ⟨x, Or.inl x.2⟩
    | Sum.inr x => ⟨x, Or.inr x.2⟩
  left_inv := fun ⟨x, h'⟩ => by by_cases p x <;> simp [union'._match_1, h] <;> congr
  right_inv o := by
    rcases o with (⟨x, h⟩ | ⟨x, h⟩) <;> dsimp [union'._match_1] <;> [simp [hs _ h]; simp [ht _ h]]
#align equiv.set.union' Equiv.Set.union'
-/

#print Equiv.Set.union /-
/-- If sets `s` and `t` are disjoint, then `s ∪ t` is equivalent to `s ⊕ t`. -/
protected def union {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅) :
    (s ∪ t : Set α) ≃ Sum s t :=
  Set.union' (fun x => x ∈ s) (fun _ => id) fun x xt xs => H ⟨xs, xt⟩
#align equiv.set.union Equiv.Set.union
-/

#print Equiv.Set.union_apply_left /-
theorem union_apply_left {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅)
    {a : (s ∪ t : Set α)} (ha : ↑a ∈ s) : Equiv.Set.union H a = Sum.inl ⟨a, ha⟩ :=
  dif_pos ha
#align equiv.set.union_apply_left Equiv.Set.union_apply_left
-/

#print Equiv.Set.union_apply_right /-
theorem union_apply_right {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅)
    {a : (s ∪ t : Set α)} (ha : ↑a ∈ t) : Equiv.Set.union H a = Sum.inr ⟨a, ha⟩ :=
  dif_neg fun h => H ⟨h, ha⟩
#align equiv.set.union_apply_right Equiv.Set.union_apply_right
-/

#print Equiv.Set.union_symm_apply_left /-
@[simp]
theorem union_symm_apply_left {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅)
    (a : s) : (Equiv.Set.union H).symm (Sum.inl a) = ⟨a, subset_union_left _ _ a.2⟩ :=
  rfl
#align equiv.set.union_symm_apply_left Equiv.Set.union_symm_apply_left
-/

#print Equiv.Set.union_symm_apply_right /-
@[simp]
theorem union_symm_apply_right {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅)
    (a : t) : (Equiv.Set.union H).symm (Sum.inr a) = ⟨a, subset_union_right _ _ a.2⟩ :=
  rfl
#align equiv.set.union_symm_apply_right Equiv.Set.union_symm_apply_right
-/

#print Equiv.Set.singleton /-
/-- A singleton set is equivalent to a `punit` type. -/
protected def singleton {α} (a : α) : ({a} : Set α) ≃ PUnit.{u} :=
  ⟨fun _ => PUnit.unit, fun _ => ⟨a, mem_singleton _⟩, fun ⟨x, h⟩ => by simp at h ; subst x,
    fun ⟨⟩ => rfl⟩
#align equiv.set.singleton Equiv.Set.singleton
-/

#print Equiv.Set.ofEq /-
/-- Equal sets are equivalent.

TODO: this is the same as `equiv.set_congr`! -/
@[simps apply symm_apply]
protected def ofEq {α : Type u} {s t : Set α} (h : s = t) : s ≃ t :=
  Equiv.setCongr h
#align equiv.set.of_eq Equiv.Set.ofEq
-/

#print Equiv.Set.insert /-
/-- If `a ∉ s`, then `insert a s` is equivalent to `s ⊕ punit`. -/
protected def insert {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s) :
    (insert a s : Set α) ≃ Sum s PUnit.{u + 1} :=
  calc
    (insert a s : Set α) ≃ ↥(s ∪ {a}) := Equiv.Set.ofEq (by simp)
    _ ≃ Sum s ({a} : Set α) := (Equiv.Set.union fun x ⟨hx, hx'⟩ => by simp_all)
    _ ≃ Sum s PUnit.{u + 1} := sumCongr (Equiv.refl _) (Equiv.Set.singleton _)
#align equiv.set.insert Equiv.Set.insert
-/

#print Equiv.Set.insert_symm_apply_inl /-
@[simp]
theorem insert_symm_apply_inl {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s)
    (b : s) : (Equiv.Set.insert H).symm (Sum.inl b) = ⟨b, Or.inr b.2⟩ :=
  rfl
#align equiv.set.insert_symm_apply_inl Equiv.Set.insert_symm_apply_inl
-/

#print Equiv.Set.insert_symm_apply_inr /-
@[simp]
theorem insert_symm_apply_inr {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s)
    (b : PUnit.{u + 1}) : (Equiv.Set.insert H).symm (Sum.inr b) = ⟨a, Or.inl rfl⟩ :=
  rfl
#align equiv.set.insert_symm_apply_inr Equiv.Set.insert_symm_apply_inr
-/

#print Equiv.Set.insert_apply_left /-
@[simp]
theorem insert_apply_left {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s) :
    Equiv.Set.insert H ⟨a, Or.inl rfl⟩ = Sum.inr PUnit.unit :=
  (Equiv.Set.insert H).apply_eq_iff_eq_symm_apply.2 rfl
#align equiv.set.insert_apply_left Equiv.Set.insert_apply_left
-/

#print Equiv.Set.insert_apply_right /-
@[simp]
theorem insert_apply_right {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s) (b : s) :
    Equiv.Set.insert H ⟨b, Or.inr b.2⟩ = Sum.inl b :=
  (Equiv.Set.insert H).apply_eq_iff_eq_symm_apply.2 rfl
#align equiv.set.insert_apply_right Equiv.Set.insert_apply_right
-/

#print Equiv.Set.sumCompl /-
/-- If `s : set α` is a set with decidable membership, then `s ⊕ sᶜ` is equivalent to `α`. -/
protected def sumCompl {α} (s : Set α) [DecidablePred (· ∈ s)] : Sum s (sᶜ : Set α) ≃ α :=
  calc
    Sum s (sᶜ : Set α) ≃ ↥(s ∪ sᶜ) := (Equiv.Set.union (by simp [Set.ext_iff])).symm
    _ ≃ @univ α := (Equiv.Set.ofEq (by simp))
    _ ≃ α := Equiv.Set.univ _
#align equiv.set.sum_compl Equiv.Set.sumCompl
-/

#print Equiv.Set.sumCompl_apply_inl /-
@[simp]
theorem sumCompl_apply_inl {α : Type u} (s : Set α) [DecidablePred (· ∈ s)] (x : s) :
    Equiv.Set.sumCompl s (Sum.inl x) = x :=
  rfl
#align equiv.set.sum_compl_apply_inl Equiv.Set.sumCompl_apply_inl
-/

#print Equiv.Set.sumCompl_apply_inr /-
@[simp]
theorem sumCompl_apply_inr {α : Type u} (s : Set α) [DecidablePred (· ∈ s)] (x : sᶜ) :
    Equiv.Set.sumCompl s (Sum.inr x) = x :=
  rfl
#align equiv.set.sum_compl_apply_inr Equiv.Set.sumCompl_apply_inr
-/

#print Equiv.Set.sumCompl_symm_apply_of_mem /-
theorem sumCompl_symm_apply_of_mem {α : Type u} {s : Set α} [DecidablePred (· ∈ s)] {x : α}
    (hx : x ∈ s) : (Equiv.Set.sumCompl s).symm x = Sum.inl ⟨x, hx⟩ :=
  by
  have : ↑(⟨x, Or.inl hx⟩ : (s ∪ sᶜ : Set α)) ∈ s := hx
  rw [Equiv.Set.sumCompl]
  simpa using set.union_apply_left _ this
#align equiv.set.sum_compl_symm_apply_of_mem Equiv.Set.sumCompl_symm_apply_of_mem
-/

#print Equiv.Set.sumCompl_symm_apply_of_not_mem /-
theorem sumCompl_symm_apply_of_not_mem {α : Type u} {s : Set α} [DecidablePred (· ∈ s)] {x : α}
    (hx : x ∉ s) : (Equiv.Set.sumCompl s).symm x = Sum.inr ⟨x, hx⟩ :=
  by
  have : ↑(⟨x, Or.inr hx⟩ : (s ∪ sᶜ : Set α)) ∈ sᶜ := hx
  rw [Equiv.Set.sumCompl]
  simpa using set.union_apply_right _ this
#align equiv.set.sum_compl_symm_apply_of_not_mem Equiv.Set.sumCompl_symm_apply_of_not_mem
-/

#print Equiv.Set.sumCompl_symm_apply /-
@[simp]
theorem sumCompl_symm_apply {α : Type _} {s : Set α} [DecidablePred (· ∈ s)] {x : s} :
    (Equiv.Set.sumCompl s).symm x = Sum.inl x := by
  cases' x with x hx <;> exact set.sum_compl_symm_apply_of_mem hx
#align equiv.set.sum_compl_symm_apply Equiv.Set.sumCompl_symm_apply
-/

#print Equiv.Set.sumCompl_symm_apply_compl /-
@[simp]
theorem sumCompl_symm_apply_compl {α : Type _} {s : Set α} [DecidablePred (· ∈ s)] {x : sᶜ} :
    (Equiv.Set.sumCompl s).symm x = Sum.inr x := by
  cases' x with x hx <;> exact set.sum_compl_symm_apply_of_not_mem hx
#align equiv.set.sum_compl_symm_apply_compl Equiv.Set.sumCompl_symm_apply_compl
-/

#print Equiv.Set.sumDiffSubset /-
/-- `sum_diff_subset s t` is the natural equivalence between
`s ⊕ (t \ s)` and `t`, where `s` and `t` are two sets. -/
protected def sumDiffSubset {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)] :
    Sum s (t \ s : Set α) ≃ t :=
  calc
    Sum s (t \ s : Set α) ≃ (s ∪ t \ s : Set α) :=
      (Equiv.Set.union (by simp [inter_diff_self])).symm
    _ ≃ t := Equiv.Set.ofEq (by simp [union_diff_self, union_eq_self_of_subset_left h])
#align equiv.set.sum_diff_subset Equiv.Set.sumDiffSubset
-/

#print Equiv.Set.sumDiffSubset_apply_inl /-
@[simp]
theorem sumDiffSubset_apply_inl {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)] (x : s) :
    Equiv.Set.sumDiffSubset h (Sum.inl x) = inclusion h x :=
  rfl
#align equiv.set.sum_diff_subset_apply_inl Equiv.Set.sumDiffSubset_apply_inl
-/

#print Equiv.Set.sumDiffSubset_apply_inr /-
@[simp]
theorem sumDiffSubset_apply_inr {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)] (x : t \ s) :
    Equiv.Set.sumDiffSubset h (Sum.inr x) = inclusion (diff_subset t s) x :=
  rfl
#align equiv.set.sum_diff_subset_apply_inr Equiv.Set.sumDiffSubset_apply_inr
-/

#print Equiv.Set.sumDiffSubset_symm_apply_of_mem /-
theorem sumDiffSubset_symm_apply_of_mem {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)]
    {x : t} (hx : x.1 ∈ s) : (Equiv.Set.sumDiffSubset h).symm x = Sum.inl ⟨x, hx⟩ :=
  by
  apply (Equiv.Set.sumDiffSubset h).Injective
  simp only [apply_symm_apply, sum_diff_subset_apply_inl]
  exact Subtype.eq rfl
#align equiv.set.sum_diff_subset_symm_apply_of_mem Equiv.Set.sumDiffSubset_symm_apply_of_mem
-/

#print Equiv.Set.sumDiffSubset_symm_apply_of_not_mem /-
theorem sumDiffSubset_symm_apply_of_not_mem {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)]
    {x : t} (hx : x.1 ∉ s) : (Equiv.Set.sumDiffSubset h).symm x = Sum.inr ⟨x, ⟨x.2, hx⟩⟩ :=
  by
  apply (Equiv.Set.sumDiffSubset h).Injective
  simp only [apply_symm_apply, sum_diff_subset_apply_inr]
  exact Subtype.eq rfl
#align equiv.set.sum_diff_subset_symm_apply_of_not_mem Equiv.Set.sumDiffSubset_symm_apply_of_not_mem
-/

#print Equiv.Set.unionSumInter /-
/-- If `s` is a set with decidable membership, then the sum of `s ∪ t` and `s ∩ t` is equivalent
to `s ⊕ t`. -/
protected def unionSumInter {α : Type u} (s t : Set α) [DecidablePred (· ∈ s)] :
    Sum (s ∪ t : Set α) (s ∩ t : Set α) ≃ Sum s t :=
  calc
    Sum (s ∪ t : Set α) (s ∩ t : Set α) ≃ Sum (s ∪ t \ s : Set α) (s ∩ t : Set α) := by
      rw [union_diff_self]
    _ ≃ Sum (Sum s (t \ s : Set α)) (s ∩ t : Set α) :=
      (sumCongr (Set.union <| subset_empty_iff.2 (inter_diff_self _ _)) (Equiv.refl _))
    _ ≃ Sum s (Sum (t \ s : Set α) (s ∩ t : Set α)) := (sumAssoc _ _ _)
    _ ≃ Sum s (t \ s ∪ s ∩ t : Set α) :=
      (sumCongr (Equiv.refl _)
        (by
          refine' (set.union' (· ∉ s) _ _).symm
          exacts [fun x hx => hx.2, fun x hx => not_not_intro hx.1]))
    _ ≃ Sum s t := by rw [(_ : t \ s ∪ s ∩ t = t)]; rw [union_comm, inter_comm, inter_union_diff]
#align equiv.set.union_sum_inter Equiv.Set.unionSumInter
-/

#print Equiv.Set.compl /-
/-- Given an equivalence `e₀` between sets `s : set α` and `t : set β`, the set of equivalences
`e : α ≃ β` such that `e ↑x = ↑(e₀ x)` for each `x : s` is equivalent to the set of equivalences
between `sᶜ` and `tᶜ`. -/
protected def compl {α : Type u} {β : Type v} {s : Set α} {t : Set β} [DecidablePred (· ∈ s)]
    [DecidablePred (· ∈ t)] (e₀ : s ≃ t) :
    { e : α ≃ β // ∀ x : s, e x = e₀ x } ≃ ((sᶜ : Set α) ≃ (tᶜ : Set β))
    where
  toFun e :=
    subtypeEquiv e fun a =>
      not_congr <|
        Iff.symm <|
          MapsTo.mem_iff (mapsTo_iff_exists_map_subtype.2 ⟨e₀, e.2⟩)
            (SurjOn.mapsTo_compl
              (surjOn_iff_exists_map_subtype.2 ⟨t, e₀, Subset.refl t, e₀.Surjective, e.2⟩)
              e.1.Injective)
  invFun e₁ :=
    Subtype.mk
      (calc
        α ≃ Sum s (sᶜ : Set α) := (Set.sumCompl s).symm
        _ ≃ Sum t (tᶜ : Set β) := (e₀.sumCongr e₁)
        _ ≃ β := Set.sumCompl t)
      fun x => by
      simp only [Sum.map_inl, trans_apply, sum_congr_apply, set.sum_compl_apply_inl,
        set.sum_compl_symm_apply]
  left_inv e := by
    ext x
    by_cases hx : x ∈ s
    ·
      simp only [set.sum_compl_symm_apply_of_mem hx, ← e.prop ⟨x, hx⟩, Sum.map_inl, sum_congr_apply,
        trans_apply, Subtype.coe_mk, set.sum_compl_apply_inl]
    ·
      simp only [set.sum_compl_symm_apply_of_not_mem hx, Sum.map_inr, subtype_equiv_apply,
        set.sum_compl_apply_inr, trans_apply, sum_congr_apply, Subtype.coe_mk]
  right_inv e :=
    Equiv.ext fun x => by
      simp only [Sum.map_inr, subtype_equiv_apply, set.sum_compl_apply_inr, Function.comp_apply,
        sum_congr_apply, Equiv.coe_trans, Subtype.coe_eta, Subtype.coe_mk,
        set.sum_compl_symm_apply_compl]
#align equiv.set.compl Equiv.Set.compl
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Equiv.Set.prod /-
/-- The set product of two sets is equivalent to the type product of their coercions to types. -/
protected def prod {α β} (s : Set α) (t : Set β) : ↥(s ×ˢ t) ≃ s × t :=
  @subtypeProdEquivProd α β s t
#align equiv.set.prod Equiv.Set.prod
-/

#print Equiv.Set.univPi /-
/-- The set `set.pi set.univ s` is equivalent to `Π a, s a`. -/
@[simps]
protected def univPi {α : Type _} {β : α → Type _} (s : ∀ a, Set (β a)) : pi univ s ≃ ∀ a, s a
    where
  toFun f a := ⟨(f : ∀ a, β a) a, f.2 a (mem_univ a)⟩
  invFun f := ⟨fun a => f a, fun a ha => (f a).2⟩
  left_inv := fun ⟨f, hf⟩ => by ext a; rfl
  right_inv f := by ext a; rfl
#align equiv.set.univ_pi Equiv.Set.univPi
-/

#print Equiv.Set.imageOfInjOn /-
/-- If a function `f` is injective on a set `s`, then `s` is equivalent to `f '' s`. -/
protected noncomputable def imageOfInjOn {α β} (f : α → β) (s : Set α) (H : InjOn f s) :
    s ≃ f '' s :=
  ⟨fun p => ⟨f p, mem_image_of_mem f p.2⟩, fun p =>
    ⟨Classical.choose p.2, (Classical.choose_spec p.2).1⟩, fun ⟨x, h⟩ =>
    Subtype.eq
      (H (Classical.choose_spec (mem_image_of_mem f h)).1 h
        (Classical.choose_spec (mem_image_of_mem f h)).2),
    fun ⟨y, h⟩ => Subtype.eq (Classical.choose_spec h).2⟩
#align equiv.set.image_of_inj_on Equiv.Set.imageOfInjOn
-/

#print Equiv.Set.image /-
/-- If `f` is an injective function, then `s` is equivalent to `f '' s`. -/
@[simps apply]
protected noncomputable def image {α β} (f : α → β) (s : Set α) (H : Injective f) : s ≃ f '' s :=
  Equiv.Set.imageOfInjOn f s (H.InjOn s)
#align equiv.set.image Equiv.Set.image
-/

#print Equiv.Set.image_symm_apply /-
@[simp]
protected theorem image_symm_apply {α β} (f : α → β) (s : Set α) (H : Injective f) (x : α)
    (h : x ∈ s) : (Set.image f s H).symm ⟨f x, ⟨x, ⟨h, rfl⟩⟩⟩ = ⟨x, h⟩ :=
  by
  apply (Set.image f s H).Injective
  simp [(Set.image f s H).apply_symm_apply]
#align equiv.set.image_symm_apply Equiv.Set.image_symm_apply
-/

#print Equiv.Set.image_symm_preimage /-
theorem image_symm_preimage {α β} {f : α → β} (hf : Injective f) (u s : Set α) :
    (fun x => (Set.image f s hf).symm x : f '' s → α) ⁻¹' u = coe ⁻¹' (f '' u) :=
  by
  ext ⟨b, a, has, rfl⟩
  have : ∀ h : ∃ a', a' ∈ s ∧ a' = a, Classical.choose h = a := fun h => (Classical.choose_spec h).2
  simp [Equiv.Set.image, Equiv.Set.imageOfInjOn, hf.eq_iff, this]
#align equiv.set.image_symm_preimage Equiv.Set.image_symm_preimage
-/

#print Equiv.Set.congr /-
/-- If `α` is equivalent to `β`, then `set α` is equivalent to `set β`. -/
@[simps]
protected def congr {α β : Type _} (e : α ≃ β) : Set α ≃ Set β :=
  ⟨fun s => e '' s, fun t => e.symm '' t, symm_image_image e, symm_image_image e.symm⟩
#align equiv.set.congr Equiv.Set.congr
-/

#print Equiv.Set.sep /-
/-- The set `{x ∈ s | t x}` is equivalent to the set of `x : s` such that `t x`. -/
protected def sep {α : Type u} (s : Set α) (t : α → Prop) :
    ({x ∈ s | t x} : Set α) ≃ {x : s | t x} :=
  (Equiv.subtypeSubtypeEquivSubtypeInter s t).symm
#align equiv.set.sep Equiv.Set.sep
-/

#print Equiv.Set.powerset /-
/-- The set `𝒫 S := {x | x ⊆ S}` is equivalent to the type `set S`. -/
protected def powerset {α} (S : Set α) : 𝒫 S ≃ Set S
    where
  toFun := fun x : 𝒫 S => coe ⁻¹' (x : Set α)
  invFun := fun x : Set S => ⟨coe '' x, by rintro _ ⟨a : S, _, rfl⟩ <;> exact a.2⟩
  left_inv x := by ext y <;> exact ⟨fun ⟨⟨_, _⟩, h, rfl⟩ => h, fun h => ⟨⟨_, x.2 h⟩, h, rfl⟩⟩
  right_inv x := by ext <;> simp
#align equiv.set.powerset Equiv.Set.powerset
-/

#print Equiv.Set.rangeSplittingImageEquiv /-
/-- If `s` is a set in `range f`,
then its image under `range_splitting f` is in bijection (via `f`) with `s`.
-/
@[simps]
noncomputable def rangeSplittingImageEquiv {α β : Type _} (f : α → β) (s : Set (range f)) :
    rangeSplitting f '' s ≃ s
    where
  toFun x :=
    ⟨⟨f x, by simp⟩, by rcases x with ⟨x, ⟨y, ⟨m, rfl⟩⟩⟩; simpa [apply_range_splitting f] using m⟩
  invFun x := ⟨rangeSplitting f x, ⟨x, ⟨x.2, rfl⟩⟩⟩
  left_inv x := by rcases x with ⟨x, ⟨y, ⟨m, rfl⟩⟩⟩; simp [apply_range_splitting f]
  right_inv x := by simp [apply_range_splitting f]
#align equiv.set.range_splitting_image_equiv Equiv.Set.rangeSplittingImageEquiv
-/

end Set

#print Equiv.ofLeftInverse /-
/-- If `f : α → β` has a left-inverse when `α` is nonempty, then `α` is computably equivalent to the
range of `f`.

While awkward, the `nonempty α` hypothesis on `f_inv` and `hf` allows this to be used when `α` is
empty too. This hypothesis is absent on analogous definitions on stronger `equiv`s like
`linear_equiv.of_left_inverse` and `ring_equiv.of_left_inverse` as their typeclass assumptions
are already sufficient to ensure non-emptiness. -/
@[simps]
def ofLeftInverse {α β : Sort _} (f : α → β) (f_inv : Nonempty α → β → α)
    (hf : ∀ h : Nonempty α, LeftInverse (f_inv h) f) : α ≃ range f
    where
  toFun a := ⟨f a, a, rfl⟩
  invFun b := f_inv (nonempty_of_exists b.2) b
  left_inv a := hf ⟨a⟩ a
  right_inv := fun ⟨b, a, ha⟩ =>
    Subtype.eq <| show f (f_inv ⟨a⟩ b) = b from Eq.trans (congr_arg f <| ha ▸ hf _ a) ha
#align equiv.of_left_inverse Equiv.ofLeftInverse
-/

#print Equiv.ofLeftInverse' /-
/-- If `f : α → β` has a left-inverse, then `α` is computably equivalent to the range of `f`.

Note that if `α` is empty, no such `f_inv` exists and so this definition can't be used, unlike
the stronger but less convenient `of_left_inverse`. -/
abbrev ofLeftInverse' {α β : Sort _} (f : α → β) (f_inv : β → α) (hf : LeftInverse f_inv f) :
    α ≃ range f :=
  ofLeftInverse f (fun _ => f_inv) fun _ => hf
#align equiv.of_left_inverse' Equiv.ofLeftInverse'
-/

#print Equiv.ofInjective /-
/-- If `f : α → β` is an injective function, then domain `α` is equivalent to the range of `f`. -/
@[simps apply]
noncomputable def ofInjective {α β} (f : α → β) (hf : Injective f) : α ≃ range f :=
  Equiv.ofLeftInverse f (fun h => Function.invFun f) fun h => Function.leftInverse_invFun hf
#align equiv.of_injective Equiv.ofInjective
-/

#print Equiv.apply_ofInjective_symm /-
theorem apply_ofInjective_symm {α β} {f : α → β} (hf : Injective f) (b : range f) :
    f ((ofInjective f hf).symm b) = b :=
  Subtype.ext_iff.1 <| (ofInjective f hf).apply_symm_apply b
#align equiv.apply_of_injective_symm Equiv.apply_ofInjective_symm
-/

#print Equiv.ofInjective_symm_apply /-
@[simp]
theorem ofInjective_symm_apply {α β} {f : α → β} (hf : Injective f) (a : α) :
    (ofInjective f hf).symm ⟨f a, ⟨a, rfl⟩⟩ = a :=
  by
  apply (of_injective f hf).Injective
  simp [apply_of_injective_symm hf]
#align equiv.of_injective_symm_apply Equiv.ofInjective_symm_apply
-/

#print Equiv.coe_ofInjective_symm /-
theorem coe_ofInjective_symm {α β} {f : α → β} (hf : Injective f) :
    ((ofInjective f hf).symm : range f → α) = rangeSplitting f := by ext ⟨y, x, rfl⟩; apply hf;
  simp [apply_range_splitting f]
#align equiv.coe_of_injective_symm Equiv.coe_ofInjective_symm
-/

#print Equiv.self_comp_ofInjective_symm /-
@[simp]
theorem self_comp_ofInjective_symm {α β} {f : α → β} (hf : Injective f) :
    f ∘ (ofInjective f hf).symm = coe :=
  funext fun x => apply_ofInjective_symm hf x
#align equiv.self_comp_of_injective_symm Equiv.self_comp_ofInjective_symm
-/

#print Equiv.ofLeftInverse_eq_ofInjective /-
theorem ofLeftInverse_eq_ofInjective {α β : Type _} (f : α → β) (f_inv : Nonempty α → β → α)
    (hf : ∀ h : Nonempty α, LeftInverse (f_inv h) f) :
    ofLeftInverse f f_inv hf =
      ofInjective f
        ((em (Nonempty α)).elim (fun h => (hf h).Injective) fun h _ _ _ => by
          haveI : Subsingleton α := subsingleton_of_not_nonempty h; simp) :=
  by ext; simp
#align equiv.of_left_inverse_eq_of_injective Equiv.ofLeftInverse_eq_ofInjective
-/

#print Equiv.ofLeftInverse'_eq_ofInjective /-
theorem ofLeftInverse'_eq_ofInjective {α β : Type _} (f : α → β) (f_inv : β → α)
    (hf : LeftInverse f_inv f) : ofLeftInverse' f f_inv hf = ofInjective f hf.Injective := by ext;
  simp
#align equiv.of_left_inverse'_eq_of_injective Equiv.ofLeftInverse'_eq_ofInjective
-/

#print Equiv.set_forall_iff /-
protected theorem set_forall_iff {α β} (e : α ≃ β) {p : Set α → Prop} :
    (∀ a, p a) ↔ ∀ a, p (e ⁻¹' a) :=
  e.Injective.preimage_surjective.forall
#align equiv.set_forall_iff Equiv.set_forall_iff
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Equiv.preimage_piEquivPiSubtypeProd_symm_pi /-
theorem preimage_piEquivPiSubtypeProd_symm_pi {α : Type _} {β : α → Type _} (p : α → Prop)
    [DecidablePred p] (s : ∀ i, Set (β i)) :
    (piEquivPiSubtypeProd p β).symm ⁻¹' pi univ s =
      (pi univ fun i : { i // p i } => s i) ×ˢ pi univ fun i : { i // ¬p i } => s i :=
  by
  ext ⟨f, g⟩
  simp only [mem_preimage, mem_univ_pi, prod_mk_mem_set_prod_eq, Subtype.forall, ← forall_and]
  refine' forall_congr' fun i => _
  dsimp only [Subtype.coe_mk]
  by_cases hi : p i <;> simp [hi]
#align equiv.preimage_pi_equiv_pi_subtype_prod_symm_pi Equiv.preimage_piEquivPiSubtypeProd_symm_pi
-/

#print Equiv.sigmaPreimageEquiv /-
-- See also `equiv.sigma_fiber_equiv`.
/-- `sigma_fiber_equiv f` for `f : α → β` is the natural equivalence between
the type of all preimages of points under `f` and the total space `α`. -/
@[simps]
def sigmaPreimageEquiv {α β} (f : α → β) : (Σ b, f ⁻¹' {b}) ≃ α :=
  sigmaFiberEquiv f
#align equiv.sigma_preimage_equiv Equiv.sigmaPreimageEquiv
-/

#print Equiv.ofPreimageEquiv /-
-- See also `equiv.of_fiber_equiv`.
/-- A family of equivalences between preimages of points gives an equivalence between domains. -/
@[simps]
def ofPreimageEquiv {α β γ} {f : α → γ} {g : β → γ} (e : ∀ c, f ⁻¹' {c} ≃ g ⁻¹' {c}) : α ≃ β :=
  Equiv.ofFiberEquiv e
#align equiv.of_preimage_equiv Equiv.ofPreimageEquiv
-/

#print Equiv.ofPreimageEquiv_map /-
theorem ofPreimageEquiv_map {α β γ} {f : α → γ} {g : β → γ} (e : ∀ c, f ⁻¹' {c} ≃ g ⁻¹' {c})
    (a : α) : g (ofPreimageEquiv e a) = f a :=
  Equiv.ofFiberEquiv_map e a
#align equiv.of_preimage_equiv_map Equiv.ofPreimageEquiv_map
-/

end Equiv

#print Set.BijOn.equiv /-
/-- If a function is a bijection between two sets `s` and `t`, then it induces an
equivalence between the types `↥s` and `↥t`. -/
noncomputable def Set.BijOn.equiv {α : Type _} {β : Type _} {s : Set α} {t : Set β} (f : α → β)
    (h : BijOn f s t) : s ≃ t :=
  Equiv.ofBijective _ h.Bijective
#align set.bij_on.equiv Set.BijOn.equiv
-/

/-- The composition of an updated function with an equiv on a subset can be expressed as an
updated function. -/
theorem dite_comp_equiv_update {α : Type _} {β : Sort _} {γ : Sort _} {s : Set α} (e : β ≃ s)
    (v : β → γ) (w : α → γ) (j : β) (x : γ) [DecidableEq β] [DecidableEq α]
    [∀ j, Decidable (j ∈ s)] :
    (fun i : α => if h : i ∈ s then (Function.update v j x) (e.symm ⟨i, h⟩) else w i) =
      Function.update (fun i : α => if h : i ∈ s then v (e.symm ⟨i, h⟩) else w i) (e j) x :=
  by
  ext i
  by_cases h : i ∈ s
  · rw [dif_pos h, Function.update_apply_equiv_apply, Equiv.symm_symm, Function.comp,
      Function.update_apply, Function.update_apply, dif_pos h]
    have h_coe : (⟨i, h⟩ : s) = e j ↔ i = e j := subtype.ext_iff.trans (by rw [Subtype.coe_mk])
    simp_rw [h_coe]
  · have : i ≠ e j := by contrapose! h; have : (e j : α) ∈ s := (e j).2; rwa [← h] at this 
    simp [h, this]
#align dite_comp_equiv_update dite_comp_equiv_updateₓ

