/-
Copyright (c) 2018 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module data.rel
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.CompleteLattice
import Mathbin.Order.GaloisConnection

/-!
# Relations

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines bundled relations. A relation between `α` and `β` is a function `α → β → Prop`.
Relations are also known as set-valued functions, or partial multifunctions.

## Main declarations

* `rel α β`: Relation between `α` and `β`.
* `rel.inv`: `r.inv` is the `rel β α` obtained by swapping the arguments of `r`.
* `rel.dom`: Domain of a relation. `x ∈ r.dom` iff there exists `y` such that `r x y`.
* `rel.codom`: Codomain, aka range, of a relation. `y ∈ r.codom` iff there exists `x` such that
  `r x y`.
* `rel.comp`: Relation composition. Note that the arguments order follows the `category_theory/`
  one, so `r.comp s x z ↔ ∃ y, r x y ∧ s y z`.
* `rel.image`: Image of a set under a relation. `r.image s` is the set of `f x` over all `x ∈ s`.
* `rel.preimage`: Preimage of a set under a relation. Note that `r.preimage = r.inv.image`.
* `rel.core`: Core of a set. For `s : set β`, `r.core s` is the set of `x : α` such that all `y`
  related to `x` are in `s`.
* `rel.restrict_domain`: Domain-restriction of a relation to a subtype.
* `function.graph`: Graph of a function as a relation.
-/


variable {α β γ : Type _}

#print Rel /-
/-- A relation on `α` and `β`, aka a set-valued function, aka a partial multifunction -/
def Rel (α β : Type _) :=
  α → β → Prop
deriving CompleteLattice, Inhabited
#align rel Rel
-/

namespace Rel

variable {δ : Type _} (r : Rel α β)

#print Rel.inv /-
/-- The inverse relation : `r.inv x y ↔ r y x`. Note that this is *not* a groupoid inverse. -/
def inv : Rel β α :=
  flip r
#align rel.inv Rel.inv
-/

#print Rel.inv_def /-
theorem inv_def (x : α) (y : β) : r.inv y x ↔ r x y :=
  Iff.rfl
#align rel.inv_def Rel.inv_def
-/

#print Rel.inv_inv /-
theorem inv_inv : inv (inv r) = r := by ext x y; rfl
#align rel.inv_inv Rel.inv_inv
-/

#print Rel.dom /-
/-- Domain of a relation -/
def dom :=
  {x | ∃ y, r x y}
#align rel.dom Rel.dom
-/

#print Rel.dom_mono /-
theorem dom_mono {r s : Rel α β} (h : r ≤ s) : dom r ⊆ dom s := fun a ⟨b, hx⟩ => ⟨b, h a b hx⟩
#align rel.dom_mono Rel.dom_mono
-/

#print Rel.codom /-
/-- Codomain aka range of a relation -/
def codom :=
  {y | ∃ x, r x y}
#align rel.codom Rel.codom
-/

#print Rel.codom_inv /-
theorem codom_inv : r.inv.codom = r.dom := by ext x y; rfl
#align rel.codom_inv Rel.codom_inv
-/

#print Rel.dom_inv /-
theorem dom_inv : r.inv.dom = r.codom := by ext x y; rfl
#align rel.dom_inv Rel.dom_inv
-/

#print Rel.comp /-
/-- Composition of relation; note that it follows the `category_theory/` order of arguments. -/
def comp (r : Rel α β) (s : Rel β γ) : Rel α γ := fun x z => ∃ y, r x y ∧ s y z
#align rel.comp Rel.comp
-/

local infixr:0 " ∘ " => Rel.comp

#print Rel.comp_assoc /-
theorem comp_assoc (r : Rel α β) (s : Rel β γ) (t : Rel γ δ) : ((r ∘ s) ∘ t) = (r ∘ s ∘ t) :=
  by
  unfold comp; ext x w; constructor
  · rintro ⟨z, ⟨y, rxy, syz⟩, tzw⟩; exact ⟨y, rxy, z, syz, tzw⟩
  rintro ⟨y, rxy, z, syz, tzw⟩; exact ⟨z, ⟨y, rxy, syz⟩, tzw⟩
#align rel.comp_assoc Rel.comp_assoc
-/

#print Rel.comp_right_id /-
@[simp]
theorem comp_right_id (r : Rel α β) : (r ∘ @Eq β) = r := by unfold comp; ext y; simp
#align rel.comp_right_id Rel.comp_right_id
-/

#print Rel.comp_left_id /-
@[simp]
theorem comp_left_id (r : Rel α β) : (@Eq α ∘ r) = r := by unfold comp; ext x; simp
#align rel.comp_left_id Rel.comp_left_id
-/

#print Rel.inv_id /-
theorem inv_id : inv (@Eq α) = @Eq α := by ext x y; constructor <;> apply Eq.symm
#align rel.inv_id Rel.inv_id
-/

#print Rel.inv_comp /-
theorem inv_comp (r : Rel α β) (s : Rel β γ) : inv (r ∘ s) = (inv s ∘ inv r) := by ext x z;
  simp [comp, inv, flip, and_comm]
#align rel.inv_comp Rel.inv_comp
-/

#print Rel.image /-
/-- Image of a set under a relation -/
def image (s : Set α) : Set β :=
  {y | ∃ x ∈ s, r x y}
#align rel.image Rel.image
-/

#print Rel.mem_image /-
theorem mem_image (y : β) (s : Set α) : y ∈ image r s ↔ ∃ x ∈ s, r x y :=
  Iff.rfl
#align rel.mem_image Rel.mem_image
-/

#print Rel.image_subset /-
theorem image_subset : ((· ⊆ ·) ⇒ (· ⊆ ·)) r.image r.image := fun s t h y ⟨x, xs, rxy⟩ =>
  ⟨x, h xs, rxy⟩
#align rel.image_subset Rel.image_subset
-/

#print Rel.image_mono /-
theorem image_mono : Monotone r.image :=
  r.image_subset
#align rel.image_mono Rel.image_mono
-/

#print Rel.image_inter /-
theorem image_inter (s t : Set α) : r.image (s ∩ t) ⊆ r.image s ∩ r.image t :=
  r.image_mono.map_inf_le s t
#align rel.image_inter Rel.image_inter
-/

#print Rel.image_union /-
theorem image_union (s t : Set α) : r.image (s ∪ t) = r.image s ∪ r.image t :=
  le_antisymm
    (fun y ⟨x, xst, rxy⟩ =>
      xst.elim (fun xs => Or.inl ⟨x, ⟨xs, rxy⟩⟩) fun xt => Or.inr ⟨x, ⟨xt, rxy⟩⟩)
    (r.image_mono.le_map_sup s t)
#align rel.image_union Rel.image_union
-/

#print Rel.image_id /-
@[simp]
theorem image_id (s : Set α) : image (@Eq α) s = s := by ext x; simp [mem_image]
#align rel.image_id Rel.image_id
-/

#print Rel.image_comp /-
theorem image_comp (s : Rel β γ) (t : Set α) : image (r ∘ s) t = image s (image r t) :=
  by
  ext z; simp only [mem_image]; constructor
  · rintro ⟨x, xt, y, rxy, syz⟩; exact ⟨y, ⟨x, xt, rxy⟩, syz⟩
  rintro ⟨y, ⟨x, xt, rxy⟩, syz⟩; exact ⟨x, xt, y, rxy, syz⟩
#align rel.image_comp Rel.image_comp
-/

#print Rel.image_univ /-
theorem image_univ : r.image Set.univ = r.codom := by ext y; simp [mem_image, codom]
#align rel.image_univ Rel.image_univ
-/

#print Rel.preimage /-
/-- Preimage of a set under a relation `r`. Same as the image of `s` under `r.inv` -/
def preimage (s : Set β) : Set α :=
  r.inv.image s
#align rel.preimage Rel.preimage
-/

#print Rel.mem_preimage /-
theorem mem_preimage (x : α) (s : Set β) : x ∈ r.Preimage s ↔ ∃ y ∈ s, r x y :=
  Iff.rfl
#align rel.mem_preimage Rel.mem_preimage
-/

#print Rel.preimage_def /-
theorem preimage_def (s : Set β) : preimage r s = {x | ∃ y ∈ s, r x y} :=
  Set.ext fun x => mem_preimage _ _ _
#align rel.preimage_def Rel.preimage_def
-/

#print Rel.preimage_mono /-
theorem preimage_mono {s t : Set β} (h : s ⊆ t) : r.Preimage s ⊆ r.Preimage t :=
  image_mono _ h
#align rel.preimage_mono Rel.preimage_mono
-/

#print Rel.preimage_inter /-
theorem preimage_inter (s t : Set β) : r.Preimage (s ∩ t) ⊆ r.Preimage s ∩ r.Preimage t :=
  image_inter _ s t
#align rel.preimage_inter Rel.preimage_inter
-/

#print Rel.preimage_union /-
theorem preimage_union (s t : Set β) : r.Preimage (s ∪ t) = r.Preimage s ∪ r.Preimage t :=
  image_union _ s t
#align rel.preimage_union Rel.preimage_union
-/

#print Rel.preimage_id /-
theorem preimage_id (s : Set α) : preimage (@Eq α) s = s := by
  simp only [preimage, inv_id, image_id]
#align rel.preimage_id Rel.preimage_id
-/

#print Rel.preimage_comp /-
theorem preimage_comp (s : Rel β γ) (t : Set γ) : preimage (r ∘ s) t = preimage r (preimage s t) :=
  by simp only [preimage, inv_comp, image_comp]
#align rel.preimage_comp Rel.preimage_comp
-/

#print Rel.preimage_univ /-
theorem preimage_univ : r.Preimage Set.univ = r.dom := by rw [preimage, image_univ, codom_inv]
#align rel.preimage_univ Rel.preimage_univ
-/

#print Rel.core /-
/-- Core of a set `s : set β` w.r.t `r : rel α β` is the set of `x : α` that are related *only*
to elements of `s`. Other generalization of `function.preimage`. -/
def core (s : Set β) :=
  {x | ∀ y, r x y → y ∈ s}
#align rel.core Rel.core
-/

#print Rel.mem_core /-
theorem mem_core (x : α) (s : Set β) : x ∈ r.core s ↔ ∀ y, r x y → y ∈ s :=
  Iff.rfl
#align rel.mem_core Rel.mem_core
-/

#print Rel.core_subset /-
theorem core_subset : ((· ⊆ ·) ⇒ (· ⊆ ·)) r.core r.core := fun s t h x h' y rxy => h (h' y rxy)
#align rel.core_subset Rel.core_subset
-/

#print Rel.core_mono /-
theorem core_mono : Monotone r.core :=
  r.core_subset
#align rel.core_mono Rel.core_mono
-/

#print Rel.core_inter /-
theorem core_inter (s t : Set β) : r.core (s ∩ t) = r.core s ∩ r.core t :=
  Set.ext (by simp [mem_core, imp_and, forall_and])
#align rel.core_inter Rel.core_inter
-/

#print Rel.core_union /-
theorem core_union (s t : Set β) : r.core s ∪ r.core t ⊆ r.core (s ∪ t) :=
  r.core_mono.le_map_sup s t
#align rel.core_union Rel.core_union
-/

#print Rel.core_univ /-
@[simp]
theorem core_univ : r.core Set.univ = Set.univ :=
  Set.ext (by simp [mem_core])
#align rel.core_univ Rel.core_univ
-/

#print Rel.core_id /-
theorem core_id (s : Set α) : core (@Eq α) s = s := by simp [core]
#align rel.core_id Rel.core_id
-/

#print Rel.core_comp /-
theorem core_comp (s : Rel β γ) (t : Set γ) : core (r ∘ s) t = core r (core s t) :=
  by
  ext x; simp [core, comp]; constructor
  · exact fun h y rxy z => h z y rxy
  · exact fun h z y rzy => h y rzy z
#align rel.core_comp Rel.core_comp
-/

#print Rel.restrictDomain /-
/-- Restrict the domain of a relation to a subtype. -/
def restrictDomain (s : Set α) : Rel { x // x ∈ s } β := fun x y => r x.val y
#align rel.restrict_domain Rel.restrictDomain
-/

#print Rel.image_subset_iff /-
theorem image_subset_iff (s : Set α) (t : Set β) : image r s ⊆ t ↔ s ⊆ core r t :=
  Iff.intro (fun h x xs y rxy => h ⟨x, xs, rxy⟩) fun h y ⟨x, xs, rxy⟩ => h xs y rxy
#align rel.image_subset_iff Rel.image_subset_iff
-/

#print Rel.image_core_gc /-
theorem image_core_gc : GaloisConnection r.image r.core :=
  image_subset_iff _
#align rel.image_core_gc Rel.image_core_gc
-/

end Rel

namespace Function

#print Function.graph /-
/-- The graph of a function as a relation. -/
def graph (f : α → β) : Rel α β := fun x y => f x = y
#align function.graph Function.graph
-/

end Function

namespace Set

#print Set.image_eq /-
-- TODO: if image were defined with bounded quantification in corelib, the next two would
-- be definitional
theorem image_eq (f : α → β) (s : Set α) : f '' s = (Function.graph f).image s := by
  simp [Set.image, Function.graph, Rel.image]
#align set.image_eq Set.image_eq
-/

#print Set.preimage_eq /-
theorem preimage_eq (f : α → β) (s : Set β) : f ⁻¹' s = (Function.graph f).Preimage s := by
  simp [Set.preimage, Function.graph, Rel.preimage, Rel.inv, flip, Rel.image]
#align set.preimage_eq Set.preimage_eq
-/

#print Set.preimage_eq_core /-
theorem preimage_eq_core (f : α → β) (s : Set β) : f ⁻¹' s = (Function.graph f).core s := by
  simp [Set.preimage, Function.graph, Rel.core]
#align set.preimage_eq_core Set.preimage_eq_core
-/

end Set

