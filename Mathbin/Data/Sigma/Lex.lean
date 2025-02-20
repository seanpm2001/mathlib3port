/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module data.sigma.lex
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Sigma.Basic
import Mathbin.Order.RelClasses

/-!
# Lexicographic order on a sigma type

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This defines the lexicographical order of two arbitrary relations on a sigma type and proves some
lemmas about `psigma.lex`, which is defined in core Lean.

Given a relation in the index type and a relation on each summand, the lexicographical order on the
sigma type relates `a` and `b` if their summands are related or they are in the same summand and
related by the summand's relation.

## See also

Related files are:
* `data.finset.colex`: Colexicographic order on finite sets.
* `data.list.lex`: Lexicographic order on lists.
* `data.sigma.order`: Lexicographic order on `Σ i, α i` per say.
* `data.psigma.order`: Lexicographic order on `Σ' i, α i`.
* `data.prod.lex`: Lexicographic order on `α × β`. Can be thought of as the special case of
  `sigma.lex` where all summands are the same
-/


namespace Sigma

variable {ι : Type _} {α : ι → Type _} {r r₁ r₂ : ι → ι → Prop} {s s₁ s₂ : ∀ i, α i → α i → Prop}
  {a b : Σ i, α i}

#print Sigma.Lex /-
/-- The lexicographical order on a sigma type. It takes in a relation on the index type and a
relation for each summand. `a` is related to `b` iff their summands are related or they are in the
same summand and are related through the summand's relation. -/
inductive Lex (r : ι → ι → Prop) (s : ∀ i, α i → α i → Prop) : ∀ a b : Σ i, α i, Prop
  | left {i j : ι} (a : α i) (b : α j) : r i j → Lex ⟨i, a⟩ ⟨j, b⟩
  | right {i : ι} (a b : α i) : s i a b → Lex ⟨i, a⟩ ⟨i, b⟩
#align sigma.lex Sigma.Lex
-/

#print Sigma.lex_iff /-
theorem lex_iff : Lex r s a b ↔ r a.1 b.1 ∨ ∃ h : a.1 = b.1, s _ (h.rec a.2) b.2 :=
  by
  constructor
  · rintro (⟨a, b, hij⟩ | ⟨a, b, hab⟩)
    · exact Or.inl hij
    · exact Or.inr ⟨rfl, hab⟩
  · obtain ⟨i, a⟩ := a
    obtain ⟨j, b⟩ := b
    dsimp only
    rintro (h | ⟨rfl, h⟩)
    · exact lex.left _ _ h
    · exact lex.right _ _ h
#align sigma.lex_iff Sigma.lex_iff
-/

#print Sigma.Lex.decidable /-
instance Lex.decidable (r : ι → ι → Prop) (s : ∀ i, α i → α i → Prop) [DecidableEq ι]
    [DecidableRel r] [∀ i, DecidableRel (s i)] : DecidableRel (Lex r s) := fun a b =>
  decidable_of_decidable_of_iff inferInstance lex_iff.symm
#align sigma.lex.decidable Sigma.Lex.decidable
-/

#print Sigma.Lex.mono /-
theorem Lex.mono (hr : ∀ a b, r₁ a b → r₂ a b) (hs : ∀ i a b, s₁ i a b → s₂ i a b) {a b : Σ i, α i}
    (h : Lex r₁ s₁ a b) : Lex r₂ s₂ a b :=
  by
  obtain ⟨a, b, hij⟩ | ⟨a, b, hab⟩ := h
  · exact lex.left _ _ (hr _ _ hij)
  · exact lex.right _ _ (hs _ _ _ hab)
#align sigma.lex.mono Sigma.Lex.mono
-/

#print Sigma.Lex.mono_left /-
theorem Lex.mono_left (hr : ∀ a b, r₁ a b → r₂ a b) {a b : Σ i, α i} (h : Lex r₁ s a b) :
    Lex r₂ s a b :=
  h.mono hr fun _ _ _ => id
#align sigma.lex.mono_left Sigma.Lex.mono_left
-/

#print Sigma.Lex.mono_right /-
theorem Lex.mono_right (hs : ∀ i a b, s₁ i a b → s₂ i a b) {a b : Σ i, α i} (h : Lex r s₁ a b) :
    Lex r s₂ a b :=
  h.mono (fun _ _ => id) hs
#align sigma.lex.mono_right Sigma.Lex.mono_right
-/

#print Sigma.lex_swap /-
theorem lex_swap : Lex r.symm s a b ↔ Lex r (fun i => (s i).symm) b a := by
  constructor <;> · rintro (⟨a, b, h⟩ | ⟨a, b, h⟩); exacts [lex.left _ _ h, lex.right _ _ h]
#align sigma.lex_swap Sigma.lex_swap
-/

instance [∀ i, IsRefl (α i) (s i)] : IsRefl _ (Lex r s) :=
  ⟨fun ⟨i, a⟩ => Lex.right _ _ <| refl _⟩

instance [IsIrrefl ι r] [∀ i, IsIrrefl (α i) (s i)] : IsIrrefl _ (Lex r s) :=
  ⟨by
    rintro _ (⟨a, b, hi⟩ | ⟨a, b, ha⟩)
    · exact irrefl _ hi
    · exact irrefl _ ha⟩

instance [IsTrans ι r] [∀ i, IsTrans (α i) (s i)] : IsTrans _ (Lex r s) :=
  ⟨by
    rintro _ _ _ (⟨a, b, hij⟩ | ⟨a, b, hab⟩) (⟨_, c, hk⟩ | ⟨_, c, hc⟩)
    · exact lex.left _ _ (trans hij hk)
    · exact lex.left _ _ hij
    · exact lex.left _ _ hk
    · exact lex.right _ _ (trans hab hc)⟩

instance [IsSymm ι r] [∀ i, IsSymm (α i) (s i)] : IsSymm _ (Lex r s) :=
  ⟨by
    rintro _ _ (⟨a, b, hij⟩ | ⟨a, b, hab⟩)
    · exact lex.left _ _ (symm hij)
    · exact lex.right _ _ (symm hab)⟩

attribute [local instance] IsAsymm.isIrrefl

instance [IsAsymm ι r] [∀ i, IsAntisymm (α i) (s i)] : IsAntisymm _ (Lex r s) :=
  ⟨by
    rintro _ _ (⟨a, b, hij⟩ | ⟨a, b, hab⟩) (⟨_, _, hji⟩ | ⟨_, _, hba⟩)
    · exact (asymm hij hji).elim
    · exact (irrefl _ hij).elim
    · exact (irrefl _ hji).elim
    · exact ext rfl (hEq_of_eq <| antisymm hab hba)⟩

instance [IsTrichotomous ι r] [∀ i, IsTotal (α i) (s i)] : IsTotal _ (Lex r s) :=
  ⟨by
    rintro ⟨i, a⟩ ⟨j, b⟩
    obtain hij | rfl | hji := trichotomous_of r i j
    · exact Or.inl (lex.left _ _ hij)
    · obtain hab | hba := total_of (s i) a b
      · exact Or.inl (lex.right _ _ hab)
      · exact Or.inr (lex.right _ _ hba)
    · exact Or.inr (lex.left _ _ hji)⟩

instance [IsTrichotomous ι r] [∀ i, IsTrichotomous (α i) (s i)] : IsTrichotomous _ (Lex r s) :=
  ⟨by
    rintro ⟨i, a⟩ ⟨j, b⟩
    obtain hij | rfl | hji := trichotomous_of r i j
    · exact Or.inl (lex.left _ _ hij)
    · obtain hab | rfl | hba := trichotomous_of (s i) a b
      · exact Or.inl (lex.right _ _ hab)
      · exact Or.inr (Or.inl rfl)
      · exact Or.inr (Or.inr <| lex.right _ _ hba)
    · exact Or.inr (Or.inr <| lex.left _ _ hji)⟩

end Sigma

/-! ### `psigma` -/


namespace PSigma

variable {ι : Sort _} {α : ι → Sort _} {r r₁ r₂ : ι → ι → Prop} {s s₁ s₂ : ∀ i, α i → α i → Prop}

#print PSigma.lex_iff /-
theorem lex_iff {a b : Σ' i, α i} :
    Lex r s a b ↔ r a.1 b.1 ∨ ∃ h : a.1 = b.1, s _ (h.rec a.2) b.2 :=
  by
  constructor
  · rintro (⟨a, b, hij⟩ | ⟨i, hab⟩)
    · exact Or.inl hij
    · exact Or.inr ⟨rfl, hab⟩
  · obtain ⟨i, a⟩ := a
    obtain ⟨j, b⟩ := b
    dsimp only
    rintro (h | ⟨rfl, h⟩)
    · exact lex.left _ _ h
    · exact lex.right _ h
#align psigma.lex_iff PSigma.lex_iff
-/

#print PSigma.Lex.decidable /-
instance Lex.decidable (r : ι → ι → Prop) (s : ∀ i, α i → α i → Prop) [DecidableEq ι]
    [DecidableRel r] [∀ i, DecidableRel (s i)] : DecidableRel (Lex r s) := fun a b =>
  decidable_of_decidable_of_iff inferInstance lex_iff.symm
#align psigma.lex.decidable PSigma.Lex.decidable
-/

#print PSigma.Lex.mono /-
theorem Lex.mono {r₁ r₂ : ι → ι → Prop} {s₁ s₂ : ∀ i, α i → α i → Prop}
    (hr : ∀ a b, r₁ a b → r₂ a b) (hs : ∀ i a b, s₁ i a b → s₂ i a b) {a b : Σ' i, α i}
    (h : Lex r₁ s₁ a b) : Lex r₂ s₂ a b :=
  by
  obtain ⟨a, b, hij⟩ | ⟨i, hab⟩ := h
  · exact lex.left _ _ (hr _ _ hij)
  · exact lex.right _ (hs _ _ _ hab)
#align psigma.lex.mono PSigma.Lex.mono
-/

#print PSigma.Lex.mono_left /-
theorem Lex.mono_left {r₁ r₂ : ι → ι → Prop} {s : ∀ i, α i → α i → Prop}
    (hr : ∀ a b, r₁ a b → r₂ a b) {a b : Σ' i, α i} (h : Lex r₁ s a b) : Lex r₂ s a b :=
  h.mono hr fun _ _ _ => id
#align psigma.lex.mono_left PSigma.Lex.mono_left
-/

#print PSigma.Lex.mono_right /-
theorem Lex.mono_right {r : ι → ι → Prop} {s₁ s₂ : ∀ i, α i → α i → Prop}
    (hs : ∀ i a b, s₁ i a b → s₂ i a b) {a b : Σ' i, α i} (h : Lex r s₁ a b) : Lex r s₂ a b :=
  h.mono (fun _ _ => id) hs
#align psigma.lex.mono_right PSigma.Lex.mono_right
-/

end PSigma

