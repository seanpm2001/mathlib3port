/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

! This file was ported from Lean 3 source module set_theory.cardinal.schroeder_bernstein
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.FixedPoints
import Mathbin.Order.Zorn

/-!
# Schröder-Bernstein theorem, well-ordering of cardinals

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves the Schröder-Bernstein theorem (see `schroeder_bernstein`), the well-ordering of
cardinals (see `min_injective`) and the totality of their order (see `total`).

## Notes

Cardinals are naturally ordered by `α ≤ β ↔ ∃ f : a → β, injective f`:
* `schroeder_bernstein` states that, given injections `α → β` and `β → α`, one can get a
  bijection `α → β`. This corresponds to the antisymmetry of the order.
* The order is also well-founded: any nonempty set of cardinals has a minimal element.
  `min_injective` states that by saying that there exists an element of the set that injects into
  all others.

Cardinals are defined and further developed in the file `set_theory.cardinal`.
-/


open Set Function

open scoped Classical

universe u v

namespace Function

namespace Embedding

section antisymm

variable {α : Type u} {β : Type v}

#print Function.Embedding.schroeder_bernstein /-
/-- **The Schröder-Bernstein Theorem**:
Given injections `α → β` and `β → α`, we can get a bijection `α → β`. -/
theorem schroeder_bernstein {f : α → β} {g : β → α} (hf : Function.Injective f)
    (hg : Function.Injective g) : ∃ h : α → β, Bijective h :=
  by
  cases' isEmpty_or_nonempty β with hβ hβ
  · have : IsEmpty α := Function.isEmpty f
    exact ⟨_, ((Equiv.equivEmpty α).trans (Equiv.equivEmpty β).symm).Bijective⟩
  set F : Set α →o Set α :=
    { toFun := fun s => (g '' (f '' s)ᶜ)ᶜ
      monotone' := fun s t hst =>
        compl_subset_compl.mpr <| image_subset _ <| compl_subset_compl.mpr <| image_subset _ hst }
  set s : Set α := F.lfp
  have hs : (g '' (f '' s)ᶜ)ᶜ = s := F.map_lfp
  have hns : g '' (f '' s)ᶜ = sᶜ := compl_injective (by simp [hs])
  set g' := inv_fun g
  have g'g : left_inverse g' g := left_inverse_inv_fun hg
  have hg'ns : g' '' sᶜ = (f '' s)ᶜ := by rw [← hns, g'g.image_image]
  set h : α → β := s.piecewise f g'
  have : surjective h := by rw [← range_iff_surjective, range_piecewise, hg'ns, union_compl_self]
  have : injective h :=
    by
    refine' (injective_piecewise_iff _).2 ⟨hf.inj_on _, _, _⟩
    · intro x hx y hy hxy
      obtain ⟨x', hx', rfl⟩ : x ∈ g '' (f '' s)ᶜ := by rwa [hns]
      obtain ⟨y', hy', rfl⟩ : y ∈ g '' (f '' s)ᶜ := by rwa [hns]
      rw [g'g _, g'g _] at hxy ; rw [hxy]
    · intro x hx y hy hxy
      obtain ⟨y', hy', rfl⟩ : y ∈ g '' (f '' s)ᶜ := by rwa [hns]
      rw [g'g _] at hxy 
      exact hy' ⟨x, hx, hxy⟩
  exact ⟨h, ‹injective h›, ‹surjective h›⟩
#align function.embedding.schroeder_bernstein Function.Embedding.schroeder_bernstein
-/

#print Function.Embedding.antisymm /-
/-- **The Schröder-Bernstein Theorem**: Given embeddings `α ↪ β` and `β ↪ α`, there exists an
equivalence `α ≃ β`. -/
theorem antisymm : (α ↪ β) → (β ↪ α) → Nonempty (α ≃ β)
  | ⟨e₁, h₁⟩, ⟨e₂, h₂⟩ =>
    let ⟨f, hf⟩ := schroeder_bernstein h₁ h₂
    ⟨Equiv.ofBijective f hf⟩
#align function.embedding.antisymm Function.Embedding.antisymm
-/

end antisymm

section Wo

parameter {ι : Type u} (β : ι → Type v)

@[reducible]
private def sets :=
  {s : Set (∀ i, β i) | ∀ x ∈ s, ∀ y ∈ s, ∀ (i), (x : ∀ i, β i) i = y i → x = y}

#print Function.Embedding.min_injective /-
/-- The cardinals are well-ordered. We express it here by the fact that in any set of cardinals
there is an element that injects into the others. See `cardinal.linear_order` for (one of) the
lattice instances. -/
theorem min_injective [I : Nonempty ι] : ∃ i, Nonempty (∀ j, β i ↪ β j) :=
  let ⟨s, hs, ms⟩ :=
    show ∃ s ∈ sets, ∀ a ∈ sets, s ⊆ a → a = s from
      zorn_subset sets fun c hc hcc =>
        ⟨⋃₀ c, fun x ⟨p, hpc, hxp⟩ y ⟨q, hqc, hyq⟩ i hi =>
          (hcc.Total hpc hqc).elim (fun h => hc hqc x (h hxp) y hyq i hi) fun h =>
            hc hpc x hxp y (h hyq) i hi,
          fun _ => subset_sUnion_of_mem⟩
  let ⟨i, e⟩ :=
    show ∃ i, ∀ y, ∃ x ∈ s, (x : ∀ i, β i) i = y from
      by_contradiction fun h =>
        have h : ∀ i, ∃ y, ∀ x ∈ s, (x : ∀ i, β i) i ≠ y := by
          simpa only [not_exists, not_forall] using h
        let ⟨f, hf⟩ := Classical.axiom_of_choice h
        have : f ∈ s :=
          have : insert f s ∈ sets := fun x hx y hy =>
            by
            cases hx <;> cases hy; · simp [hx, hy]
            · subst x; exact fun i e => (hf i y hy e.symm).elim
            · subst y; exact fun i e => (hf i x hx e).elim
            · exact hs x hx y hy
          ms _ this (subset_insert f s) ▸ mem_insert _ _
        let ⟨i⟩ := I
        hf i f this rfl
  let ⟨f, hf⟩ := Classical.axiom_of_choice e
  ⟨i,
    ⟨fun j =>
      ⟨fun a => f a j, fun a b e' => by
        let ⟨sa, ea⟩ := hf a
        let ⟨sb, eb⟩ := hf b
        rw [← ea, ← eb, hs _ sa _ sb _ e']⟩⟩⟩
#align function.embedding.min_injective Function.Embedding.min_injective
-/

end Wo

#print Function.Embedding.total /-
/-- The cardinals are totally ordered. See `cardinal.linear_order` for (one of) the lattice
instance. -/
theorem total (α : Type u) (β : Type v) : Nonempty (α ↪ β) ∨ Nonempty (β ↪ α) :=
  match @min_injective Bool (fun b => cond b (ULift α) (ULift.{max u v, v} β)) ⟨true⟩ with
  | ⟨tt, ⟨h⟩⟩ =>
    let ⟨f, hf⟩ := h false
    Or.inl ⟨Embedding.congr Equiv.ulift Equiv.ulift ⟨f, hf⟩⟩
  | ⟨ff, ⟨h⟩⟩ =>
    let ⟨f, hf⟩ := h true
    Or.inr ⟨Embedding.congr Equiv.ulift Equiv.ulift ⟨f, hf⟩⟩
#align function.embedding.total Function.Embedding.total
-/

end Embedding

end Function

