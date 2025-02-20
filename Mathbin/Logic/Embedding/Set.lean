/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

! This file was ported from Lean 3 source module logic.embedding.set
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Embedding.Basic
import Mathbin.Data.Set.Image

/-!
# Interactions between embeddings and sets.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


universe u v w x

section Equiv

variable {α : Sort u} {β : Sort v} (f : α ≃ β)

#print Equiv.asEmbedding_range /-
@[simp]
theorem Equiv.asEmbedding_range {α β : Sort _} {p : β → Prop} (e : α ≃ Subtype p) :
    Set.range e.asEmbedding = setOf p :=
  Set.ext fun x => ⟨fun ⟨y, h⟩ => h ▸ Subtype.coe_prop (e y), fun hs => ⟨e.symm ⟨x, hs⟩, by simp⟩⟩
#align equiv.as_embedding_range Equiv.asEmbedding_range
-/

end Equiv

namespace Function

namespace Embedding

#print Function.Embedding.coeWithTop /-
/-- Embedding into `with_top α`. -/
@[simps]
def coeWithTop {α} : α ↪ WithTop α :=
  { Embedding.some with toFun := coe }
#align function.embedding.coe_with_top Function.Embedding.coeWithTop
-/

#print Function.Embedding.optionElim /-
/-- Given an embedding `f : α ↪ β` and a point outside of `set.range f`, construct an embedding
`option α ↪ β`. -/
@[simps]
def optionElim {α β} (f : α ↪ β) (x : β) (h : x ∉ Set.range f) : Option α ↪ β :=
  ⟨Option.elim' x f, Option.injective_iff.2 ⟨f.2, h⟩⟩
#align function.embedding.option_elim Function.Embedding.optionElim
-/

#print Function.Embedding.optionEmbeddingEquiv /-
/-- Equivalence between embeddings of `option α` and a sigma type over the embeddings of `α`. -/
@[simps]
def optionEmbeddingEquiv (α β) : (Option α ↪ β) ≃ Σ f : α ↪ β, ↥(Set.range fᶜ)
    where
  toFun f := ⟨some.trans f, f none, fun ⟨x, hx⟩ => Option.some_ne_none x <| f.Injective hx⟩
  invFun f := f.1.optionElim f.2 f.2.2
  left_inv f := ext <| by rintro (_ | _) <;> simp [Option.coe_def]
  right_inv := fun ⟨f, y, hy⟩ => by ext <;> simp [Option.coe_def]
#align function.embedding.option_embedding_equiv Function.Embedding.optionEmbeddingEquiv
-/

#print Function.Embedding.codRestrict /-
/-- Restrict the codomain of an embedding. -/
def codRestrict {α β} (p : Set β) (f : α ↪ β) (H : ∀ a, f a ∈ p) : α ↪ p :=
  ⟨fun a => ⟨f a, H a⟩, fun a b h => f.Injective (@congr_arg _ _ _ _ Subtype.val h)⟩
#align function.embedding.cod_restrict Function.Embedding.codRestrict
-/

#print Function.Embedding.codRestrict_apply /-
@[simp]
theorem codRestrict_apply {α β} (p) (f : α ↪ β) (H a) : codRestrict p f H a = ⟨f a, H a⟩ :=
  rfl
#align function.embedding.cod_restrict_apply Function.Embedding.codRestrict_apply
-/

open Set

#print Function.Embedding.image /-
/-- `set.image` as an embedding `set α ↪ set β`. -/
@[simps apply]
protected def image {α β} (f : α ↪ β) : Set α ↪ Set β :=
  ⟨image f, f.2.image_injective⟩
#align function.embedding.image Function.Embedding.image
-/

end Embedding

end Function

namespace Set

#print Set.embeddingOfSubset /-
/-- The injection map is an embedding between subsets. -/
@[simps apply]
def embeddingOfSubset {α} (s t : Set α) (h : s ⊆ t) : s ↪ t :=
  ⟨fun x => ⟨x.1, h x.2⟩, fun ⟨x, hx⟩ ⟨y, hy⟩ h => by congr; injection h⟩
#align set.embedding_of_subset Set.embeddingOfSubset
-/

end Set

section Subtype

variable {α : Type _}

#print subtypeOrEquiv /-
/-- A subtype `{x // p x ∨ q x}` over a disjunction of `p q : α → Prop` is equivalent to a sum of
subtypes `{x // p x} ⊕ {x // q x}` such that `¬ p x` is sent to the right, when
`disjoint p q`.

See also `equiv.sum_compl`, for when `is_compl p q`.  -/
@[simps apply]
def subtypeOrEquiv (p q : α → Prop) [DecidablePred p] (h : Disjoint p q) :
    { x // p x ∨ q x } ≃ Sum { x // p x } { x // q x }
    where
  toFun := subtypeOrLeftEmbedding p q
  invFun :=
    Sum.elim (Subtype.impEmbedding _ _ fun x hx => (Or.inl hx : p x ∨ q x))
      (Subtype.impEmbedding _ _ fun x hx => (Or.inr hx : p x ∨ q x))
  left_inv x := by
    by_cases hx : p x
    · rw [subtypeOrLeftEmbedding_apply_left _ hx]
      simp [Subtype.ext_iff]
    · rw [subtypeOrLeftEmbedding_apply_right _ hx]
      simp [Subtype.ext_iff]
  right_inv x := by
    cases x
    · simp only [Sum.elim_inl]
      rw [subtypeOrLeftEmbedding_apply_left]
      · simp
      · simpa using x.prop
    · simp only [Sum.elim_inr]
      rw [subtypeOrLeftEmbedding_apply_right]
      · simp
      · suffices ¬p x by simpa
        intro hp
        simpa using h.le_bot x ⟨hp, x.prop⟩
#align subtype_or_equiv subtypeOrEquiv
-/

#print subtypeOrEquiv_symm_inl /-
@[simp]
theorem subtypeOrEquiv_symm_inl (p q : α → Prop) [DecidablePred p] (h : Disjoint p q)
    (x : { x // p x }) : (subtypeOrEquiv p q h).symm (Sum.inl x) = ⟨x, Or.inl x.Prop⟩ :=
  rfl
#align subtype_or_equiv_symm_inl subtypeOrEquiv_symm_inl
-/

#print subtypeOrEquiv_symm_inr /-
@[simp]
theorem subtypeOrEquiv_symm_inr (p q : α → Prop) [DecidablePred p] (h : Disjoint p q)
    (x : { x // q x }) : (subtypeOrEquiv p q h).symm (Sum.inr x) = ⟨x, Or.inr x.Prop⟩ :=
  rfl
#align subtype_or_equiv_symm_inr subtypeOrEquiv_symm_inr
-/

end Subtype

