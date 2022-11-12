/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl
-/
import Mathbin.Data.Set.Basic
import Mathbin.Order.Lattice
import Mathbin.Order.Max

/-!
# Directed indexed families and sets

This file defines directed indexed families and directed sets. An indexed family/set is
directed iff each pair of elements has a shared upper bound.

## Main declarations

* `directed r f`: Predicate stating that the indexed family `f` is `r`-directed.
* `directed_on r s`: Predicate stating that the set `s` is `r`-directed.
* `is_directed α r`: Prop-valued mixin stating that `α` is `r`-directed. Follows the style of the
  unbundled relation classes such as `is_total`.
-/


open Function

universe u v w

variable {α : Type u} {β : Type v} {ι : Sort w} (r r' s : α → α → Prop)

-- mathport name: «expr ≼ »
local infixl:50 " ≼ " => r

/-- A family of elements of α is directed (with respect to a relation `≼` on α)
  if there is a member of the family `≼`-above any pair in the family.  -/
def Directed (f : ι → α) :=
  ∀ x y, ∃ z, f x ≼ f z ∧ f y ≼ f z
#align directed Directed

/-- A subset of α is directed if there is an element of the set `≼`-above any
  pair of elements in the set. -/
def DirectedOn (s : Set α) :=
  ∀ x ∈ s, ∀ y ∈ s, ∃ z ∈ s, x ≼ z ∧ y ≼ z
#align directed_on DirectedOn

variable {r r'}

theorem directed_on_iff_directed {s} : @DirectedOn α r s ↔ Directed r (coe : s → α) := by
  simp [Directed, DirectedOn] <;> refine' ball_congr fun x hx => by simp <;> rfl
#align directed_on_iff_directed directed_on_iff_directed

alias directed_on_iff_directed ↔ DirectedOn.directed_coe _

theorem directed_on_image {s} {f : β → α} : DirectedOn r (f '' s) ↔ DirectedOn (f ⁻¹'o r) s := by
  simp only [DirectedOn, Set.ball_image_iff, Set.bex_image_iff, Order.Preimage]
#align directed_on_image directed_on_image

theorem DirectedOn.mono' {s : Set α} (hs : DirectedOn r s) (h : ∀ ⦃a⦄, a ∈ s → ∀ ⦃b⦄, b ∈ s → r a b → r' a b) :
    DirectedOn r' s := fun x hx y hy =>
  let ⟨z, hz, hxz, hyz⟩ := hs _ hx _ hy
  ⟨z, hz, h hx hz hxz, h hy hz hyz⟩
#align directed_on.mono' DirectedOn.mono'

theorem DirectedOn.mono {s : Set α} (h : DirectedOn r s) (H : ∀ {a b}, r a b → r' a b) : DirectedOn r' s :=
  h.mono' fun _ _ _ _ => H
#align directed_on.mono DirectedOn.mono

theorem directed_comp {ι} {f : ι → β} {g : β → α} : Directed r (g ∘ f) ↔ Directed (g ⁻¹'o r) f :=
  Iff.rfl
#align directed_comp directed_comp

theorem Directed.mono {s : α → α → Prop} {ι} {f : ι → α} (H : ∀ a b, r a b → s a b) (h : Directed r f) : Directed s f :=
  fun a b =>
  let ⟨c, h₁, h₂⟩ := h a b
  ⟨c, H _ _ h₁, H _ _ h₂⟩
#align directed.mono Directed.mono

theorem Directed.mono_comp {ι} {rb : β → β → Prop} {g : α → β} {f : ι → α} (hg : ∀ ⦃x y⦄, x ≼ y → rb (g x) (g y))
    (hf : Directed r f) : Directed rb (g ∘ f) :=
  directed_comp.2 <| hf.mono hg
#align directed.mono_comp Directed.mono_comp

/-- A monotone function on a sup-semilattice is directed. -/
theorem directed_of_sup [SemilatticeSup α] {f : α → β} {r : β → β → Prop} (H : ∀ ⦃i j⦄, i ≤ j → r (f i) (f j)) :
    Directed r f := fun a b => ⟨a ⊔ b, H le_sup_left, H le_sup_right⟩
#align directed_of_sup directed_of_sup

theorem Monotone.directed_le [SemilatticeSup α] [Preorder β] {f : α → β} : Monotone f → Directed (· ≤ ·) f :=
  directed_of_sup
#align monotone.directed_le Monotone.directed_le

theorem Antitone.directed_ge [SemilatticeSup α] [Preorder β] {f : α → β} (hf : Antitone f) : Directed (· ≥ ·) f :=
  directed_of_sup hf
#align antitone.directed_ge Antitone.directed_ge

/-- A set stable by supremum is `≤`-directed. -/
theorem directed_on_of_sup_mem [SemilatticeSup α] {S : Set α} (H : ∀ ⦃i j⦄, i ∈ S → j ∈ S → i ⊔ j ∈ S) :
    DirectedOn (· ≤ ·) S := fun a ha b hb => ⟨a ⊔ b, H ha hb, le_sup_left, le_sup_right⟩
#align directed_on_of_sup_mem directed_on_of_sup_mem

theorem Directed.extend_bot [Preorder α] [OrderBot α] {e : ι → β} {f : ι → α} (hf : Directed (· ≤ ·) f)
    (he : Function.Injective e) : Directed (· ≤ ·) (Function.extend e f ⊥) := by
  intro a b
  rcases(em (∃ i, e i = a)).symm with (ha | ⟨i, rfl⟩)
  · use b
    simp [Function.extend_apply' _ _ _ ha]
    
  rcases(em (∃ i, e i = b)).symm with (hb | ⟨j, rfl⟩)
  · use e i
    simp [Function.extend_apply' _ _ _ hb]
    
  rcases hf i j with ⟨k, hi, hj⟩
  use e k
  simp only [Function.extend_apply he, *, true_and_iff]
#align directed.extend_bot Directed.extend_bot

/-- An antitone function on an inf-semilattice is directed. -/
theorem directed_of_inf [SemilatticeInf α] {r : β → β → Prop} {f : α → β} (hf : ∀ a₁ a₂, a₁ ≤ a₂ → r (f a₂) (f a₁)) :
    Directed r f := fun x y => ⟨x ⊓ y, hf _ _ inf_le_left, hf _ _ inf_le_right⟩
#align directed_of_inf directed_of_inf

theorem Monotone.directed_ge [SemilatticeInf α] [Preorder β] {f : α → β} (hf : Monotone f) : Directed (· ≥ ·) f :=
  directed_of_inf hf
#align monotone.directed_ge Monotone.directed_ge

theorem Antitone.directed_le [SemilatticeInf α] [Preorder β] {f : α → β} (hf : Antitone f) : Directed (· ≤ ·) f :=
  directed_of_inf hf
#align antitone.directed_le Antitone.directed_le

/-- A set stable by infimum is `≥`-directed. -/
theorem directed_on_of_inf_mem [SemilatticeInf α] {S : Set α} (H : ∀ ⦃i j⦄, i ∈ S → j ∈ S → i ⊓ j ∈ S) :
    DirectedOn (· ≥ ·) S := fun a ha b hb => ⟨a ⊓ b, H ha hb, inf_le_left, inf_le_right⟩
#align directed_on_of_inf_mem directed_on_of_inf_mem

/-- `is_directed α r` states that for any elements `a`, `b` there exists an element `c` such that
`r a c` and `r b c`. -/
class IsDirected (α : Type _) (r : α → α → Prop) : Prop where
  Directed (a b : α) : ∃ c, r a c ∧ r b c
#align is_directed IsDirected

theorem directed_of (r : α → α → Prop) [IsDirected α r] (a b : α) : ∃ c, r a c ∧ r b c :=
  IsDirected.directed _ _
#align directed_of directed_of

theorem directed_id [IsDirected α r] : Directed r id := by convert directed_of r
#align directed_id directed_id

theorem directed_id_iff : Directed r id ↔ IsDirected α r :=
  ⟨fun h => ⟨h⟩, @directed_id _ _⟩
#align directed_id_iff directed_id_iff

theorem directed_on_univ [IsDirected α r] : DirectedOn r Set.Univ := fun a _ b _ =>
  let ⟨c, hc⟩ := directed_of r a b
  ⟨c, trivial, hc⟩
#align directed_on_univ directed_on_univ

theorem directed_on_univ_iff : DirectedOn r Set.Univ ↔ IsDirected α r :=
  ⟨fun h =>
    ⟨fun a b =>
      let ⟨c, _, hc⟩ := h a trivial b trivial
      ⟨c, hc⟩⟩,
    @directed_on_univ _ _⟩
#align directed_on_univ_iff directed_on_univ_iff

-- see Note [lower instance priority]
instance (priority := 100) IsTotal.to_is_directed [IsTotal α r] : IsDirected α r :=
  ⟨fun a b => Or.cases_on (total_of r a b) (fun h => ⟨b, h, refl _⟩) fun h => ⟨a, refl _, h⟩⟩
#align is_total.to_is_directed IsTotal.to_is_directed

theorem is_directed_mono [IsDirected α r] (h : ∀ ⦃a b⦄, r a b → s a b) : IsDirected α s :=
  ⟨fun a b =>
    let ⟨c, ha, hb⟩ := IsDirected.directed a b
    ⟨c, h ha, h hb⟩⟩
#align is_directed_mono is_directed_mono

theorem exists_ge_ge [LE α] [IsDirected α (· ≤ ·)] (a b : α) : ∃ c, a ≤ c ∧ b ≤ c :=
  directed_of (· ≤ ·) a b
#align exists_ge_ge exists_ge_ge

theorem exists_le_le [LE α] [IsDirected α (· ≥ ·)] (a b : α) : ∃ c, c ≤ a ∧ c ≤ b :=
  directed_of (· ≥ ·) a b
#align exists_le_le exists_le_le

instance OrderDual.is_directed_ge [LE α] [IsDirected α (· ≤ ·)] : IsDirected αᵒᵈ (· ≥ ·) := by assumption
#align order_dual.is_directed_ge OrderDual.is_directed_ge

instance OrderDual.is_directed_le [LE α] [IsDirected α (· ≥ ·)] : IsDirected αᵒᵈ (· ≤ ·) := by assumption
#align order_dual.is_directed_le OrderDual.is_directed_le

section Preorder

variable [Preorder α] {a : α}

protected theorem IsMin.is_bot [IsDirected α (· ≥ ·)] (h : IsMin a) : IsBot a := fun b =>
  let ⟨c, hca, hcb⟩ := exists_le_le a b
  (h hca).trans hcb
#align is_min.is_bot IsMin.is_bot

protected theorem IsMax.is_top [IsDirected α (· ≤ ·)] (h : IsMax a) : IsTop a :=
  h.toDual.IsBot
#align is_max.is_top IsMax.is_top

theorem is_top_or_exists_gt [IsDirected α (· ≤ ·)] (a : α) : IsTop a ∨ ∃ b, a < b :=
  (em (IsMax a)).imp IsMax.is_top not_is_max_iff.mp
#align is_top_or_exists_gt is_top_or_exists_gt

theorem is_bot_or_exists_lt [IsDirected α (· ≥ ·)] (a : α) : IsBot a ∨ ∃ b, b < a :=
  @is_top_or_exists_gt αᵒᵈ _ _ a
#align is_bot_or_exists_lt is_bot_or_exists_lt

theorem is_bot_iff_is_min [IsDirected α (· ≥ ·)] : IsBot a ↔ IsMin a :=
  ⟨IsBot.is_min, IsMin.is_bot⟩
#align is_bot_iff_is_min is_bot_iff_is_min

theorem is_top_iff_is_max [IsDirected α (· ≤ ·)] : IsTop a ↔ IsMax a :=
  ⟨IsTop.is_max, IsMax.is_top⟩
#align is_top_iff_is_max is_top_iff_is_max

variable (β) [PartialOrder β]

theorem exists_lt_of_directed_ge [IsDirected β (· ≥ ·)] [Nontrivial β] : ∃ a b : β, a < b := by
  rcases exists_pair_ne β with ⟨a, b, hne⟩
  rcases is_bot_or_exists_lt a with (ha | ⟨c, hc⟩)
  exacts[⟨a, b, (ha b).lt_of_ne hne⟩, ⟨_, _, hc⟩]
#align exists_lt_of_directed_ge exists_lt_of_directed_ge

theorem exists_lt_of_directed_le [IsDirected β (· ≤ ·)] [Nontrivial β] : ∃ a b : β, a < b :=
  let ⟨a, b, h⟩ := exists_lt_of_directed_ge βᵒᵈ
  ⟨b, a, h⟩
#align exists_lt_of_directed_le exists_lt_of_directed_le

end Preorder

-- see Note [lower instance priority]
instance (priority := 100) SemilatticeSup.to_is_directed_le [SemilatticeSup α] : IsDirected α (· ≤ ·) :=
  ⟨fun a b => ⟨a ⊔ b, le_sup_left, le_sup_right⟩⟩
#align semilattice_sup.to_is_directed_le SemilatticeSup.to_is_directed_le

-- see Note [lower instance priority]
instance (priority := 100) SemilatticeInf.to_is_directed_ge [SemilatticeInf α] : IsDirected α (· ≥ ·) :=
  ⟨fun a b => ⟨a ⊓ b, inf_le_left, inf_le_right⟩⟩
#align semilattice_inf.to_is_directed_ge SemilatticeInf.to_is_directed_ge

-- see Note [lower instance priority]
instance (priority := 100) OrderTop.to_is_directed_le [LE α] [OrderTop α] : IsDirected α (· ≤ ·) :=
  ⟨fun a b => ⟨⊤, le_top, le_top⟩⟩
#align order_top.to_is_directed_le OrderTop.to_is_directed_le

-- see Note [lower instance priority]
instance (priority := 100) OrderBot.to_is_directed_ge [LE α] [OrderBot α] : IsDirected α (· ≥ ·) :=
  ⟨fun a b => ⟨⊥, bot_le, bot_le⟩⟩
#align order_bot.to_is_directed_ge OrderBot.to_is_directed_ge

