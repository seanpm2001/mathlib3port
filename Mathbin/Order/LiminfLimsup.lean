/-
Copyright (c) 2018 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Johannes Hölzl, Rémy Degenne

! This file was ported from Lean 3 source module order.liminf_limsup
! leanprover-community/mathlib commit 3e32bc908f617039c74c06ea9a897e30c30803c2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Filter.Cofinite
import Mathbin.Order.Hom.CompleteLattice

/-!
# liminfs and limsups of functions and filters

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Defines the Liminf/Limsup of a function taking values in a conditionally complete lattice, with
respect to an arbitrary filter.

We define `Limsup f` (`Liminf f`) where `f` is a filter taking values in a conditionally complete
lattice. `Limsup f` is the smallest element `a` such that, eventually, `u ≤ a` (and vice versa for
`Liminf f`). To work with the Limsup along a function `u` use `Limsup (map u f)`.

Usually, one defines the Limsup as `Inf (Sup s)` where the Inf is taken over all sets in the filter.
For instance, in ℕ along a function `u`, this is `Inf_n (Sup_{k ≥ n} u k)` (and the latter quantity
decreases with `n`, so this is in fact a limit.). There is however a difficulty: it is well possible
that `u` is not bounded on the whole space, only eventually (think of `Limsup (λx, 1/x)` on ℝ. Then
there is no guarantee that the quantity above really decreases (the value of the `Sup` beforehand is
not really well defined, as one can not use ∞), so that the Inf could be anything. So one can not
use this `Inf Sup ...` definition in conditionally complete lattices, and one has to use a less
tractable definition.

In conditionally complete lattices, the definition is only useful for filters which are eventually
bounded above (otherwise, the Limsup would morally be +∞, which does not belong to the space) and
which are frequently bounded below (otherwise, the Limsup would morally be -∞, which is not in the
space either). We start with definitions of these concepts for arbitrary filters, before turning to
the definitions of Limsup and Liminf.

In complete lattices, however, it coincides with the `Inf Sup` definition.
-/


open Filter Set

open scoped Filter

variable {α β γ ι : Type _}

namespace Filter

section Relation

#print Filter.IsBounded /-
/-- `f.is_bounded (≺)`: the filter `f` is eventually bounded w.r.t. the relation `≺`, i.e.
eventually, it is bounded by some uniform bound.
`r` will be usually instantiated with `≤` or `≥`. -/
def IsBounded (r : α → α → Prop) (f : Filter α) :=
  ∃ b, ∀ᶠ x in f, r x b
#align filter.is_bounded Filter.IsBounded
-/

#print Filter.IsBoundedUnder /-
/-- `f.is_bounded_under (≺) u`: the image of the filter `f` under `u` is eventually bounded w.r.t.
the relation `≺`, i.e. eventually, it is bounded by some uniform bound. -/
def IsBoundedUnder (r : α → α → Prop) (f : Filter β) (u : β → α) :=
  (map u f).IsBounded r
#align filter.is_bounded_under Filter.IsBoundedUnder
-/

variable {r : α → α → Prop} {f g : Filter α}

#print Filter.isBounded_iff /-
/-- `f` is eventually bounded if and only if, there exists an admissible set on which it is
bounded. -/
theorem isBounded_iff : f.IsBounded r ↔ ∃ s ∈ f.sets, ∃ b, s ⊆ {x | r x b} :=
  Iff.intro (fun ⟨b, hb⟩ => ⟨{a | r a b}, hb, b, Subset.refl _⟩) fun ⟨s, hs, b, hb⟩ =>
    ⟨b, mem_of_superset hs hb⟩
#align filter.is_bounded_iff Filter.isBounded_iff
-/

#print Filter.isBoundedUnder_of /-
/-- A bounded function `u` is in particular eventually bounded. -/
theorem isBoundedUnder_of {f : Filter β} {u : β → α} : (∃ b, ∀ x, r (u x) b) → f.IsBoundedUnder r u
  | ⟨b, hb⟩ => ⟨b, show ∀ᶠ x in f, r (u x) b from eventually_of_forall hb⟩
#align filter.is_bounded_under_of Filter.isBoundedUnder_of
-/

#print Filter.isBounded_bot /-
theorem isBounded_bot : IsBounded r ⊥ ↔ Nonempty α := by simp [is_bounded, exists_true_iff_nonempty]
#align filter.is_bounded_bot Filter.isBounded_bot
-/

#print Filter.isBounded_top /-
theorem isBounded_top : IsBounded r ⊤ ↔ ∃ t, ∀ x, r x t := by simp [is_bounded, eq_univ_iff_forall]
#align filter.is_bounded_top Filter.isBounded_top
-/

#print Filter.isBounded_principal /-
theorem isBounded_principal (s : Set α) : IsBounded r (𝓟 s) ↔ ∃ t, ∀ x ∈ s, r x t := by
  simp [is_bounded, subset_def]
#align filter.is_bounded_principal Filter.isBounded_principal
-/

#print Filter.isBounded_sup /-
theorem isBounded_sup [IsTrans α r] (hr : ∀ b₁ b₂, ∃ b, r b₁ b ∧ r b₂ b) :
    IsBounded r f → IsBounded r g → IsBounded r (f ⊔ g)
  | ⟨b₁, h₁⟩, ⟨b₂, h₂⟩ =>
    let ⟨b, rb₁b, rb₂b⟩ := hr b₁ b₂
    ⟨b, eventually_sup.mpr ⟨h₁.mono fun x h => trans h rb₁b, h₂.mono fun x h => trans h rb₂b⟩⟩
#align filter.is_bounded_sup Filter.isBounded_sup
-/

#print Filter.IsBounded.mono /-
theorem IsBounded.mono (h : f ≤ g) : IsBounded r g → IsBounded r f
  | ⟨b, hb⟩ => ⟨b, h hb⟩
#align filter.is_bounded.mono Filter.IsBounded.mono
-/

#print Filter.IsBoundedUnder.mono /-
theorem IsBoundedUnder.mono {f g : Filter β} {u : β → α} (h : f ≤ g) :
    g.IsBoundedUnder r u → f.IsBoundedUnder r u := fun hg => hg.mono (map_mono h)
#align filter.is_bounded_under.mono Filter.IsBoundedUnder.mono
-/

#print Filter.IsBoundedUnder.mono_le /-
theorem IsBoundedUnder.mono_le [Preorder β] {l : Filter α} {u v : α → β}
    (hu : IsBoundedUnder (· ≤ ·) l u) (hv : v ≤ᶠ[l] u) : IsBoundedUnder (· ≤ ·) l v :=
  hu.imp fun b hb => (eventually_map.1 hb).mp <| hv.mono fun x => le_trans
#align filter.is_bounded_under.mono_le Filter.IsBoundedUnder.mono_le
-/

#print Filter.IsBoundedUnder.mono_ge /-
theorem IsBoundedUnder.mono_ge [Preorder β] {l : Filter α} {u v : α → β}
    (hu : IsBoundedUnder (· ≥ ·) l u) (hv : u ≤ᶠ[l] v) : IsBoundedUnder (· ≥ ·) l v :=
  @IsBoundedUnder.mono_le α βᵒᵈ _ _ _ _ hu hv
#align filter.is_bounded_under.mono_ge Filter.IsBoundedUnder.mono_ge
-/

#print Filter.isBoundedUnder_const /-
theorem isBoundedUnder_const [IsRefl α r] {l : Filter β} {a : α} : IsBoundedUnder r l fun _ => a :=
  ⟨a, eventually_map.2 <| eventually_of_forall fun _ => refl _⟩
#align filter.is_bounded_under_const Filter.isBoundedUnder_const
-/

#print Filter.IsBounded.isBoundedUnder /-
theorem IsBounded.isBoundedUnder {q : β → β → Prop} {u : α → β}
    (hf : ∀ a₀ a₁, r a₀ a₁ → q (u a₀) (u a₁)) : f.IsBounded r → f.IsBoundedUnder q u
  | ⟨b, h⟩ => ⟨u b, show ∀ᶠ x in f, q (u x) (u b) from h.mono fun x => hf x b⟩
#align filter.is_bounded.is_bounded_under Filter.IsBounded.isBoundedUnder
-/

#print Filter.not_isBoundedUnder_of_tendsto_atTop /-
theorem not_isBoundedUnder_of_tendsto_atTop [Preorder β] [NoMaxOrder β] {f : α → β} {l : Filter α}
    [l.ne_bot] (hf : Tendsto f l atTop) : ¬IsBoundedUnder (· ≤ ·) l f :=
  by
  rintro ⟨b, hb⟩
  rw [eventually_map] at hb 
  obtain ⟨b', h⟩ := exists_gt b
  have hb' := (tendsto_at_top.mp hf) b'
  have : {x : α | f x ≤ b} ∩ {x : α | b' ≤ f x} = ∅ :=
    eq_empty_of_subset_empty fun x hx => (not_le_of_lt h) (le_trans hx.2 hx.1)
  exact (nonempty_of_mem (hb.and hb')).ne_empty this
#align filter.not_is_bounded_under_of_tendsto_at_top Filter.not_isBoundedUnder_of_tendsto_atTop
-/

#print Filter.not_isBoundedUnder_of_tendsto_atBot /-
theorem not_isBoundedUnder_of_tendsto_atBot [Preorder β] [NoMinOrder β] {f : α → β} {l : Filter α}
    [l.ne_bot] (hf : Tendsto f l atBot) : ¬IsBoundedUnder (· ≥ ·) l f :=
  @not_isBoundedUnder_of_tendsto_atTop α βᵒᵈ _ _ _ _ _ hf
#align filter.not_is_bounded_under_of_tendsto_at_bot Filter.not_isBoundedUnder_of_tendsto_atBot
-/

#print Filter.IsBoundedUnder.bddAbove_range_of_cofinite /-
theorem IsBoundedUnder.bddAbove_range_of_cofinite [SemilatticeSup β] {f : α → β}
    (hf : IsBoundedUnder (· ≤ ·) cofinite f) : BddAbove (range f) :=
  by
  rcases hf with ⟨b, hb⟩
  haveI : Nonempty β := ⟨b⟩
  rw [← image_univ, ← union_compl_self {x | f x ≤ b}, image_union, bddAbove_union]
  exact ⟨⟨b, ball_image_iff.2 fun x => id⟩, (hb.image f).BddAbove⟩
#align filter.is_bounded_under.bdd_above_range_of_cofinite Filter.IsBoundedUnder.bddAbove_range_of_cofinite
-/

#print Filter.IsBoundedUnder.bddBelow_range_of_cofinite /-
theorem IsBoundedUnder.bddBelow_range_of_cofinite [SemilatticeInf β] {f : α → β}
    (hf : IsBoundedUnder (· ≥ ·) cofinite f) : BddBelow (range f) :=
  @IsBoundedUnder.bddAbove_range_of_cofinite α βᵒᵈ _ _ hf
#align filter.is_bounded_under.bdd_below_range_of_cofinite Filter.IsBoundedUnder.bddBelow_range_of_cofinite
-/

#print Filter.IsBoundedUnder.bddAbove_range /-
theorem IsBoundedUnder.bddAbove_range [SemilatticeSup β] {f : ℕ → β}
    (hf : IsBoundedUnder (· ≤ ·) atTop f) : BddAbove (range f) := by
  rw [← Nat.cofinite_eq_atTop] at hf ; exact hf.bdd_above_range_of_cofinite
#align filter.is_bounded_under.bdd_above_range Filter.IsBoundedUnder.bddAbove_range
-/

#print Filter.IsBoundedUnder.bddBelow_range /-
theorem IsBoundedUnder.bddBelow_range [SemilatticeInf β] {f : ℕ → β}
    (hf : IsBoundedUnder (· ≥ ·) atTop f) : BddBelow (range f) :=
  @IsBoundedUnder.bddAbove_range βᵒᵈ _ _ hf
#align filter.is_bounded_under.bdd_below_range Filter.IsBoundedUnder.bddBelow_range
-/

#print Filter.IsCobounded /-
/-- `is_cobounded (≺) f` states that the filter `f` does not tend to infinity w.r.t. `≺`. This is
also called frequently bounded. Will be usually instantiated with `≤` or `≥`.

There is a subtlety in this definition: we want `f.is_cobounded` to hold for any `f` in the case of
complete lattices. This will be relevant to deduce theorems on complete lattices from their
versions on conditionally complete lattices with additional assumptions. We have to be careful in
the edge case of the trivial filter containing the empty set: the other natural definition
  `¬ ∀ a, ∀ᶠ n in f, a ≤ n`
would not work as well in this case.
-/
def IsCobounded (r : α → α → Prop) (f : Filter α) :=
  ∃ b, ∀ a, (∀ᶠ x in f, r x a) → r b a
#align filter.is_cobounded Filter.IsCobounded
-/

#print Filter.IsCoboundedUnder /-
/-- `is_cobounded_under (≺) f u` states that the image of the filter `f` under the map `u` does not
tend to infinity w.r.t. `≺`. This is also called frequently bounded. Will be usually instantiated
with `≤` or `≥`. -/
def IsCoboundedUnder (r : α → α → Prop) (f : Filter β) (u : β → α) :=
  (map u f).IsCobounded r
#align filter.is_cobounded_under Filter.IsCoboundedUnder
-/

#print Filter.IsCobounded.mk /-
/-- To check that a filter is frequently bounded, it suffices to have a witness
which bounds `f` at some point for every admissible set.

This is only an implication, as the other direction is wrong for the trivial filter.-/
theorem IsCobounded.mk [IsTrans α r] (a : α) (h : ∀ s ∈ f, ∃ x ∈ s, r a x) : f.IsCobounded r :=
  ⟨a, fun y s =>
    let ⟨x, h₁, h₂⟩ := h _ s
    trans h₂ h₁⟩
#align filter.is_cobounded.mk Filter.IsCobounded.mk
-/

#print Filter.IsBounded.isCobounded_flip /-
/-- A filter which is eventually bounded is in particular frequently bounded (in the opposite
direction). At least if the filter is not trivial. -/
theorem IsBounded.isCobounded_flip [IsTrans α r] [NeBot f] : f.IsBounded r → f.IsCobounded (flip r)
  | ⟨a, ha⟩ =>
    ⟨a, fun b hb =>
      let ⟨x, rxa, rbx⟩ := (ha.And hb).exists
      show r b a from trans rbx rxa⟩
#align filter.is_bounded.is_cobounded_flip Filter.IsBounded.isCobounded_flip
-/

#print Filter.IsBounded.isCobounded_ge /-
theorem IsBounded.isCobounded_ge [Preorder α] [NeBot f] (h : f.IsBounded (· ≤ ·)) :
    f.IsCobounded (· ≥ ·) :=
  h.isCobounded_flip
#align filter.is_bounded.is_cobounded_ge Filter.IsBounded.isCobounded_ge
-/

#print Filter.IsBounded.isCobounded_le /-
theorem IsBounded.isCobounded_le [Preorder α] [NeBot f] (h : f.IsBounded (· ≥ ·)) :
    f.IsCobounded (· ≤ ·) :=
  h.isCobounded_flip
#align filter.is_bounded.is_cobounded_le Filter.IsBounded.isCobounded_le
-/

#print Filter.isCobounded_bot /-
theorem isCobounded_bot : IsCobounded r ⊥ ↔ ∃ b, ∀ x, r b x := by simp [is_cobounded]
#align filter.is_cobounded_bot Filter.isCobounded_bot
-/

#print Filter.isCobounded_top /-
theorem isCobounded_top : IsCobounded r ⊤ ↔ Nonempty α := by
  simp (config := { contextual := true }) [is_cobounded, eq_univ_iff_forall,
    exists_true_iff_nonempty]
#align filter.is_cobounded_top Filter.isCobounded_top
-/

#print Filter.isCobounded_principal /-
theorem isCobounded_principal (s : Set α) :
    (𝓟 s).IsCobounded r ↔ ∃ b, ∀ a, (∀ x ∈ s, r x a) → r b a := by simp [is_cobounded, subset_def]
#align filter.is_cobounded_principal Filter.isCobounded_principal
-/

#print Filter.IsCobounded.mono /-
theorem IsCobounded.mono (h : f ≤ g) : f.IsCobounded r → g.IsCobounded r
  | ⟨b, hb⟩ => ⟨b, fun a ha => hb a (h ha)⟩
#align filter.is_cobounded.mono Filter.IsCobounded.mono
-/

end Relation

#print Filter.isCobounded_le_of_bot /-
theorem isCobounded_le_of_bot [Preorder α] [OrderBot α] {f : Filter α} : f.IsCobounded (· ≤ ·) :=
  ⟨⊥, fun a h => bot_le⟩
#align filter.is_cobounded_le_of_bot Filter.isCobounded_le_of_bot
-/

#print Filter.isCobounded_ge_of_top /-
theorem isCobounded_ge_of_top [Preorder α] [OrderTop α] {f : Filter α} : f.IsCobounded (· ≥ ·) :=
  ⟨⊤, fun a h => le_top⟩
#align filter.is_cobounded_ge_of_top Filter.isCobounded_ge_of_top
-/

#print Filter.isBounded_le_of_top /-
theorem isBounded_le_of_top [Preorder α] [OrderTop α] {f : Filter α} : f.IsBounded (· ≤ ·) :=
  ⟨⊤, eventually_of_forall fun _ => le_top⟩
#align filter.is_bounded_le_of_top Filter.isBounded_le_of_top
-/

#print Filter.isBounded_ge_of_bot /-
theorem isBounded_ge_of_bot [Preorder α] [OrderBot α] {f : Filter α} : f.IsBounded (· ≥ ·) :=
  ⟨⊥, eventually_of_forall fun _ => bot_le⟩
#align filter.is_bounded_ge_of_bot Filter.isBounded_ge_of_bot
-/

#print OrderIso.isBoundedUnder_le_comp /-
@[simp]
theorem OrderIso.isBoundedUnder_le_comp [Preorder α] [Preorder β] (e : α ≃o β) {l : Filter γ}
    {u : γ → α} : (IsBoundedUnder (· ≤ ·) l fun x => e (u x)) ↔ IsBoundedUnder (· ≤ ·) l u :=
  e.Surjective.exists.trans <| exists_congr fun a => by simp only [eventually_map, e.le_iff_le]
#align order_iso.is_bounded_under_le_comp OrderIso.isBoundedUnder_le_comp
-/

#print OrderIso.isBoundedUnder_ge_comp /-
@[simp]
theorem OrderIso.isBoundedUnder_ge_comp [Preorder α] [Preorder β] (e : α ≃o β) {l : Filter γ}
    {u : γ → α} : (IsBoundedUnder (· ≥ ·) l fun x => e (u x)) ↔ IsBoundedUnder (· ≥ ·) l u :=
  e.dual.isBoundedUnder_le_comp
#align order_iso.is_bounded_under_ge_comp OrderIso.isBoundedUnder_ge_comp
-/

#print Filter.isBoundedUnder_le_inv /-
@[simp, to_additive]
theorem isBoundedUnder_le_inv [OrderedCommGroup α] {l : Filter β} {u : β → α} :
    (IsBoundedUnder (· ≤ ·) l fun x => (u x)⁻¹) ↔ IsBoundedUnder (· ≥ ·) l u :=
  (OrderIso.inv α).isBoundedUnder_ge_comp
#align filter.is_bounded_under_le_inv Filter.isBoundedUnder_le_inv
#align filter.is_bounded_under_le_neg Filter.isBoundedUnder_le_neg
-/

#print Filter.isBoundedUnder_ge_inv /-
@[simp, to_additive]
theorem isBoundedUnder_ge_inv [OrderedCommGroup α] {l : Filter β} {u : β → α} :
    (IsBoundedUnder (· ≥ ·) l fun x => (u x)⁻¹) ↔ IsBoundedUnder (· ≤ ·) l u :=
  (OrderIso.inv α).isBoundedUnder_le_comp
#align filter.is_bounded_under_ge_inv Filter.isBoundedUnder_ge_inv
#align filter.is_bounded_under_ge_neg Filter.isBoundedUnder_ge_neg
-/

#print Filter.IsBoundedUnder.sup /-
theorem IsBoundedUnder.sup [SemilatticeSup α] {f : Filter β} {u v : β → α} :
    f.IsBoundedUnder (· ≤ ·) u →
      f.IsBoundedUnder (· ≤ ·) v → f.IsBoundedUnder (· ≤ ·) fun a => u a ⊔ v a
  | ⟨bu, (hu : ∀ᶠ x in f, u x ≤ bu)⟩, ⟨bv, (hv : ∀ᶠ x in f, v x ≤ bv)⟩ =>
    ⟨bu ⊔ bv,
      show ∀ᶠ x in f, u x ⊔ v x ≤ bu ⊔ bv by filter_upwards [hu, hv] with _ using sup_le_sup⟩
#align filter.is_bounded_under.sup Filter.IsBoundedUnder.sup
-/

#print Filter.isBoundedUnder_le_sup /-
@[simp]
theorem isBoundedUnder_le_sup [SemilatticeSup α] {f : Filter β} {u v : β → α} :
    (f.IsBoundedUnder (· ≤ ·) fun a => u a ⊔ v a) ↔
      f.IsBoundedUnder (· ≤ ·) u ∧ f.IsBoundedUnder (· ≤ ·) v :=
  ⟨fun h =>
    ⟨h.mono_le <| eventually_of_forall fun _ => le_sup_left,
      h.mono_le <| eventually_of_forall fun _ => le_sup_right⟩,
    fun h => h.1.sup h.2⟩
#align filter.is_bounded_under_le_sup Filter.isBoundedUnder_le_sup
-/

#print Filter.IsBoundedUnder.inf /-
theorem IsBoundedUnder.inf [SemilatticeInf α] {f : Filter β} {u v : β → α} :
    f.IsBoundedUnder (· ≥ ·) u →
      f.IsBoundedUnder (· ≥ ·) v → f.IsBoundedUnder (· ≥ ·) fun a => u a ⊓ v a :=
  @IsBoundedUnder.sup αᵒᵈ β _ _ _ _
#align filter.is_bounded_under.inf Filter.IsBoundedUnder.inf
-/

#print Filter.isBoundedUnder_ge_inf /-
@[simp]
theorem isBoundedUnder_ge_inf [SemilatticeInf α] {f : Filter β} {u v : β → α} :
    (f.IsBoundedUnder (· ≥ ·) fun a => u a ⊓ v a) ↔
      f.IsBoundedUnder (· ≥ ·) u ∧ f.IsBoundedUnder (· ≥ ·) v :=
  @isBoundedUnder_le_sup αᵒᵈ _ _ _ _ _
#align filter.is_bounded_under_ge_inf Filter.isBoundedUnder_ge_inf
-/

#print Filter.isBoundedUnder_le_abs /-
theorem isBoundedUnder_le_abs [LinearOrderedAddCommGroup α] {f : Filter β} {u : β → α} :
    (f.IsBoundedUnder (· ≤ ·) fun a => |u a|) ↔
      f.IsBoundedUnder (· ≤ ·) u ∧ f.IsBoundedUnder (· ≥ ·) u :=
  isBoundedUnder_le_sup.trans <| and_congr Iff.rfl isBoundedUnder_le_neg
#align filter.is_bounded_under_le_abs Filter.isBoundedUnder_le_abs
-/

/-- Filters are automatically bounded or cobounded in complete lattices. To use the same statements
in complete and conditionally complete lattices but let automation fill automatically the
boundedness proofs in complete lattices, we use the tactic `is_bounded_default` in the statements,
in the form `(hf : f.is_bounded (≥) . is_bounded_default)`. -/
unsafe def is_bounded_default : tactic Unit :=
  tactic.applyc `` is_cobounded_le_of_bot <|>
    tactic.applyc `` is_cobounded_ge_of_top <|>
      tactic.applyc `` is_bounded_le_of_top <|> tactic.applyc `` is_bounded_ge_of_bot
#align filter.is_bounded_default filter.is_bounded_default

section ConditionallyCompleteLattice

variable [ConditionallyCompleteLattice α]

#print Filter.limsSup /-
/-- The `Limsup` of a filter `f` is the infimum of the `a` such that, eventually for `f`,
holds `x ≤ a`. -/
def limsSup (f : Filter α) : α :=
  sInf {a | ∀ᶠ n in f, n ≤ a}
#align filter.Limsup Filter.limsSup
-/

#print Filter.limsInf /-
/-- The `Liminf` of a filter `f` is the supremum of the `a` such that, eventually for `f`,
holds `x ≥ a`. -/
def limsInf (f : Filter α) : α :=
  sSup {a | ∀ᶠ n in f, a ≤ n}
#align filter.Liminf Filter.limsInf
-/

#print Filter.limsup /-
/-- The `limsup` of a function `u` along a filter `f` is the infimum of the `a` such that,
eventually for `f`, holds `u x ≤ a`. -/
def limsup (u : β → α) (f : Filter β) : α :=
  limsSup (map u f)
#align filter.limsup Filter.limsup
-/

#print Filter.liminf /-
/-- The `liminf` of a function `u` along a filter `f` is the supremum of the `a` such that,
eventually for `f`, holds `u x ≥ a`. -/
def liminf (u : β → α) (f : Filter β) : α :=
  limsInf (map u f)
#align filter.liminf Filter.liminf
-/

#print Filter.blimsup /-
/-- The `blimsup` of a function `u` along a filter `f`, bounded by a predicate `p`, is the infimum
of the `a` such that, eventually for `f`, `u x ≤ a` whenever `p x` holds. -/
def blimsup (u : β → α) (f : Filter β) (p : β → Prop) :=
  sInf {a | ∀ᶠ x in f, p x → u x ≤ a}
#align filter.blimsup Filter.blimsup
-/

#print Filter.bliminf /-
/-- The `bliminf` of a function `u` along a filter `f`, bounded by a predicate `p`, is the supremum
of the `a` such that, eventually for `f`, `a ≤ u x` whenever `p x` holds. -/
def bliminf (u : β → α) (f : Filter β) (p : β → Prop) :=
  sSup {a | ∀ᶠ x in f, p x → a ≤ u x}
#align filter.bliminf Filter.bliminf
-/

section

variable {f : Filter β} {u : β → α} {p : β → Prop}

#print Filter.limsup_eq /-
theorem limsup_eq : limsup u f = sInf {a | ∀ᶠ n in f, u n ≤ a} :=
  rfl
#align filter.limsup_eq Filter.limsup_eq
-/

#print Filter.liminf_eq /-
theorem liminf_eq : liminf u f = sSup {a | ∀ᶠ n in f, a ≤ u n} :=
  rfl
#align filter.liminf_eq Filter.liminf_eq
-/

#print Filter.blimsup_eq /-
theorem blimsup_eq : blimsup u f p = sInf {a | ∀ᶠ x in f, p x → u x ≤ a} :=
  rfl
#align filter.blimsup_eq Filter.blimsup_eq
-/

#print Filter.bliminf_eq /-
theorem bliminf_eq : bliminf u f p = sSup {a | ∀ᶠ x in f, p x → a ≤ u x} :=
  rfl
#align filter.bliminf_eq Filter.bliminf_eq
-/

end

#print Filter.blimsup_true /-
@[simp]
theorem blimsup_true (f : Filter β) (u : β → α) : (blimsup u f fun x => True) = limsup u f := by
  simp [blimsup_eq, limsup_eq]
#align filter.blimsup_true Filter.blimsup_true
-/

#print Filter.bliminf_true /-
@[simp]
theorem bliminf_true (f : Filter β) (u : β → α) : (bliminf u f fun x => True) = liminf u f := by
  simp [bliminf_eq, liminf_eq]
#align filter.bliminf_true Filter.bliminf_true
-/

#print Filter.blimsup_eq_limsup_subtype /-
theorem blimsup_eq_limsup_subtype {f : Filter β} {u : β → α} {p : β → Prop} :
    blimsup u f p = limsup (u ∘ (coe : {x | p x} → β)) (comap coe f) :=
  by
  simp only [blimsup_eq, limsup_eq, Function.comp_apply, eventually_comap, SetCoe.forall,
    Subtype.coe_mk, mem_set_of_eq]
  congr
  ext a
  exact
    eventually_congr
      (eventually_of_forall fun x =>
        ⟨fun hx y hy hxy => hxy.symm ▸ hx (hxy ▸ hy), fun hx hx' => hx x hx' rfl⟩)
#align filter.blimsup_eq_limsup_subtype Filter.blimsup_eq_limsup_subtype
-/

#print Filter.bliminf_eq_liminf_subtype /-
theorem bliminf_eq_liminf_subtype {f : Filter β} {u : β → α} {p : β → Prop} :
    bliminf u f p = liminf (u ∘ (coe : {x | p x} → β)) (comap coe f) :=
  @blimsup_eq_limsup_subtype αᵒᵈ β _ f u p
#align filter.bliminf_eq_liminf_subtype Filter.bliminf_eq_liminf_subtype
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsSup_le_of_le /-
theorem limsSup_le_of_le {f : Filter α} {a}
    (hf : f.IsCobounded (· ≤ ·) := by
      run_tac
        is_bounded_default)
    (h : ∀ᶠ n in f, n ≤ a) : limsSup f ≤ a :=
  csInf_le hf h
#align filter.Limsup_le_of_le Filter.limsSup_le_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.le_limsInf_of_le /-
theorem le_limsInf_of_le {f : Filter α} {a}
    (hf : f.IsCobounded (· ≥ ·) := by
      run_tac
        is_bounded_default)
    (h : ∀ᶠ n in f, a ≤ n) : a ≤ limsInf f :=
  le_csSup hf h
#align filter.le_Liminf_of_le Filter.le_limsInf_of_le
-/

/- warning: filter.limsup_le_of_le clashes with filter.Limsup_le_of_le -> Filter.limsSup_le_of_le
Case conversion may be inaccurate. Consider using '#align filter.limsup_le_of_le Filter.limsSup_le_of_leₓ'. -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsSup_le_of_le /-
theorem limsSup_le_of_le {f : Filter β} {u : β → α} {a}
    (hf : f.IsCoboundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h : ∀ᶠ n in f, u n ≤ a) : limsup u f ≤ a :=
  csInf_le hf h
#align filter.limsup_le_of_le Filter.limsSup_le_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.le_liminf_of_le /-
theorem le_liminf_of_le {f : Filter β} {u : β → α} {a}
    (hf : f.IsCoboundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default)
    (h : ∀ᶠ n in f, a ≤ u n) : a ≤ liminf u f :=
  le_csSup hf h
#align filter.le_liminf_of_le Filter.le_liminf_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.le_limsSup_of_le /-
theorem le_limsSup_of_le {f : Filter α} {a}
    (hf : f.IsBounded (· ≤ ·) := by
      run_tac
        is_bounded_default)
    (h : ∀ b, (∀ᶠ n in f, n ≤ b) → a ≤ b) : a ≤ limsSup f :=
  le_csInf hf h
#align filter.le_Limsup_of_le Filter.le_limsSup_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsInf_le_of_le /-
theorem limsInf_le_of_le {f : Filter α} {a}
    (hf : f.IsBounded (· ≥ ·) := by
      run_tac
        is_bounded_default)
    (h : ∀ b, (∀ᶠ n in f, b ≤ n) → b ≤ a) : limsInf f ≤ a :=
  csSup_le hf h
#align filter.Liminf_le_of_le Filter.limsInf_le_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.le_limsup_of_le /-
theorem le_limsup_of_le {f : Filter β} {u : β → α} {a}
    (hf : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h : ∀ b, (∀ᶠ n in f, u n ≤ b) → a ≤ b) : a ≤ limsup u f :=
  le_csInf hf h
#align filter.le_limsup_of_le Filter.le_limsup_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.liminf_le_of_le /-
theorem liminf_le_of_le {f : Filter β} {u : β → α} {a}
    (hf : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default)
    (h : ∀ b, (∀ᶠ n in f, b ≤ u n) → b ≤ a) : liminf u f ≤ a :=
  csSup_le hf h
#align filter.liminf_le_of_le Filter.liminf_le_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsInf_le_limsSup /-
theorem limsInf_le_limsSup {f : Filter α} [NeBot f]
    (h₁ : f.IsBounded (· ≤ ·) := by
      run_tac
        is_bounded_default)
    (h₂ : f.IsBounded (· ≥ ·) := by
      run_tac
        is_bounded_default) :
    limsInf f ≤ limsSup f :=
  limsInf_le_of_le h₂ fun a₀ ha₀ =>
    le_limsSup_of_le h₁ fun a₁ ha₁ =>
      show a₀ ≤ a₁ from
        let ⟨b, hb₀, hb₁⟩ := (ha₀.And ha₁).exists
        le_trans hb₀ hb₁
#align filter.Liminf_le_Limsup Filter.limsInf_le_limsSup
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.liminf_le_limsup /-
theorem liminf_le_limsup {f : Filter β} [NeBot f] {u : β → α}
    (h : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h' : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    liminf u f ≤ limsup u f :=
  limsInf_le_limsSup h h'
#align filter.liminf_le_limsup Filter.liminf_le_limsup
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsSup_le_limsSup /-
theorem limsSup_le_limsSup {f g : Filter α}
    (hf : f.IsCobounded (· ≤ ·) := by
      run_tac
        is_bounded_default)
    (hg : g.IsBounded (· ≤ ·) := by
      run_tac
        is_bounded_default)
    (h : ∀ a, (∀ᶠ n in g, n ≤ a) → ∀ᶠ n in f, n ≤ a) : limsSup f ≤ limsSup g :=
  csInf_le_csInf hf hg h
#align filter.Limsup_le_Limsup Filter.limsSup_le_limsSup
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsInf_le_limsInf /-
theorem limsInf_le_limsInf {f g : Filter α}
    (hf : f.IsBounded (· ≥ ·) := by
      run_tac
        is_bounded_default)
    (hg : g.IsCobounded (· ≥ ·) := by
      run_tac
        is_bounded_default)
    (h : ∀ a, (∀ᶠ n in f, a ≤ n) → ∀ᶠ n in g, a ≤ n) : limsInf f ≤ limsInf g :=
  csSup_le_csSup hg hf h
#align filter.Liminf_le_Liminf Filter.limsInf_le_limsInf
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsup_le_limsup /-
theorem limsup_le_limsup {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} {u v : α → β}
    (h : u ≤ᶠ[f] v)
    (hu : f.IsCoboundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (hv : f.IsBoundedUnder (· ≤ ·) v := by
      run_tac
        is_bounded_default) :
    limsup u f ≤ limsup v f :=
  limsSup_le_limsSup hu hv fun b => h.trans
#align filter.limsup_le_limsup Filter.limsup_le_limsup
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.liminf_le_liminf /-
theorem liminf_le_liminf {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} {u v : α → β}
    (h : ∀ᶠ a in f, u a ≤ v a)
    (hu : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default)
    (hv : f.IsCoboundedUnder (· ≥ ·) v := by
      run_tac
        is_bounded_default) :
    liminf u f ≤ liminf v f :=
  @limsup_le_limsup βᵒᵈ α _ _ _ _ h hv hu
#align filter.liminf_le_liminf Filter.liminf_le_liminf
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsSup_le_limsSup_of_le /-
theorem limsSup_le_limsSup_of_le {f g : Filter α} (h : f ≤ g)
    (hf : f.IsCobounded (· ≤ ·) := by
      run_tac
        is_bounded_default)
    (hg : g.IsBounded (· ≤ ·) := by
      run_tac
        is_bounded_default) :
    limsSup f ≤ limsSup g :=
  limsSup_le_limsSup hf hg fun a ha => h ha
#align filter.Limsup_le_Limsup_of_le Filter.limsSup_le_limsSup_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsInf_le_limsInf_of_le /-
theorem limsInf_le_limsInf_of_le {f g : Filter α} (h : g ≤ f)
    (hf : f.IsBounded (· ≥ ·) := by
      run_tac
        is_bounded_default)
    (hg : g.IsCobounded (· ≥ ·) := by
      run_tac
        is_bounded_default) :
    limsInf f ≤ limsInf g :=
  limsInf_le_limsInf hf hg fun a ha => h ha
#align filter.Liminf_le_Liminf_of_le Filter.limsInf_le_limsInf_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.limsup_le_limsup_of_le /-
theorem limsup_le_limsup_of_le {α β} [ConditionallyCompleteLattice β] {f g : Filter α} (h : f ≤ g)
    {u : α → β}
    (hf : f.IsCoboundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (hg : g.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default) :
    limsup u f ≤ limsup u g :=
  limsSup_le_limsSup_of_le (map_mono h) hf hg
#align filter.limsup_le_limsup_of_le Filter.limsup_le_limsup_of_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.liminf_le_liminf_of_le /-
theorem liminf_le_liminf_of_le {α β} [ConditionallyCompleteLattice β] {f g : Filter α} (h : g ≤ f)
    {u : α → β}
    (hf : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default)
    (hg : g.IsCoboundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    liminf u f ≤ liminf u g :=
  limsInf_le_limsInf_of_le (map_mono h) hf hg
#align filter.liminf_le_liminf_of_le Filter.liminf_le_liminf_of_le
-/

#print Filter.limsSup_principal /-
theorem limsSup_principal {s : Set α} (h : BddAbove s) (hs : s.Nonempty) : limsSup (𝓟 s) = sSup s :=
  by simp [Limsup] <;> exact csInf_upper_bounds_eq_csSup h hs
#align filter.Limsup_principal Filter.limsSup_principal
-/

#print Filter.limsInf_principal /-
theorem limsInf_principal {s : Set α} (h : BddBelow s) (hs : s.Nonempty) : limsInf (𝓟 s) = sInf s :=
  @limsSup_principal αᵒᵈ _ s h hs
#align filter.Liminf_principal Filter.limsInf_principal
-/

#print Filter.limsup_congr /-
theorem limsup_congr {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} {u v : α → β}
    (h : ∀ᶠ a in f, u a = v a) : limsup u f = limsup v f :=
  by
  rw [limsup_eq]
  congr with b
  exact eventually_congr (h.mono fun x hx => by simp [hx])
#align filter.limsup_congr Filter.limsup_congr
-/

#print Filter.blimsup_congr /-
theorem blimsup_congr {f : Filter β} {u v : β → α} {p : β → Prop} (h : ∀ᶠ a in f, p a → u a = v a) :
    blimsup u f p = blimsup v f p := by
  rw [blimsup_eq]
  congr with b
  refine' eventually_congr (h.mono fun x hx => ⟨fun h₁ h₂ => _, fun h₁ h₂ => _⟩)
  · rw [← hx h₂]; exact h₁ h₂
  · rw [hx h₂]; exact h₁ h₂
#align filter.blimsup_congr Filter.blimsup_congr
-/

#print Filter.bliminf_congr /-
theorem bliminf_congr {f : Filter β} {u v : β → α} {p : β → Prop} (h : ∀ᶠ a in f, p a → u a = v a) :
    bliminf u f p = bliminf v f p :=
  @blimsup_congr αᵒᵈ _ _ _ _ _ _ h
#align filter.bliminf_congr Filter.bliminf_congr
-/

#print Filter.liminf_congr /-
theorem liminf_congr {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} {u v : α → β}
    (h : ∀ᶠ a in f, u a = v a) : liminf u f = liminf v f :=
  @limsup_congr βᵒᵈ _ _ _ _ _ h
#align filter.liminf_congr Filter.liminf_congr
-/

#print Filter.limsup_const /-
theorem limsup_const {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} [NeBot f]
    (b : β) : limsup (fun x => b) f = b := by
  simpa only [limsup_eq, eventually_const] using csInf_Ici
#align filter.limsup_const Filter.limsup_const
-/

#print Filter.liminf_const /-
theorem liminf_const {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} [NeBot f]
    (b : β) : liminf (fun x => b) f = b :=
  @limsup_const βᵒᵈ α _ f _ b
#align filter.liminf_const Filter.liminf_const
-/

end ConditionallyCompleteLattice

section CompleteLattice

variable [CompleteLattice α]

#print Filter.limsSup_bot /-
@[simp]
theorem limsSup_bot : limsSup (⊥ : Filter α) = ⊥ :=
  bot_unique <| sInf_le <| by simp
#align filter.Limsup_bot Filter.limsSup_bot
-/

#print Filter.limsInf_bot /-
@[simp]
theorem limsInf_bot : limsInf (⊥ : Filter α) = ⊤ :=
  top_unique <| le_sSup <| by simp
#align filter.Liminf_bot Filter.limsInf_bot
-/

#print Filter.limsSup_top /-
@[simp]
theorem limsSup_top : limsSup (⊤ : Filter α) = ⊤ :=
  top_unique <| le_sInf <| by simp [eq_univ_iff_forall] <;> exact fun b hb => top_unique <| hb _
#align filter.Limsup_top Filter.limsSup_top
-/

#print Filter.limsInf_top /-
@[simp]
theorem limsInf_top : limsInf (⊤ : Filter α) = ⊥ :=
  bot_unique <| sSup_le <| by simp [eq_univ_iff_forall] <;> exact fun b hb => bot_unique <| hb _
#align filter.Liminf_top Filter.limsInf_top
-/

#print Filter.blimsup_false /-
@[simp]
theorem blimsup_false {f : Filter β} {u : β → α} : (blimsup u f fun x => False) = ⊥ := by
  simp [blimsup_eq]
#align filter.blimsup_false Filter.blimsup_false
-/

#print Filter.bliminf_false /-
@[simp]
theorem bliminf_false {f : Filter β} {u : β → α} : (bliminf u f fun x => False) = ⊤ := by
  simp [bliminf_eq]
#align filter.bliminf_false Filter.bliminf_false
-/

#print Filter.limsup_const_bot /-
/-- Same as limsup_const applied to `⊥` but without the `ne_bot f` assumption -/
theorem limsup_const_bot {f : Filter β} : limsup (fun x : β => (⊥ : α)) f = (⊥ : α) :=
  by
  rw [limsup_eq, eq_bot_iff]
  exact sInf_le (eventually_of_forall fun x => le_rfl)
#align filter.limsup_const_bot Filter.limsup_const_bot
-/

#print Filter.liminf_const_top /-
/-- Same as limsup_const applied to `⊤` but without the `ne_bot f` assumption -/
theorem liminf_const_top {f : Filter β} : liminf (fun x : β => (⊤ : α)) f = (⊤ : α) :=
  @limsup_const_bot αᵒᵈ β _ _
#align filter.liminf_const_top Filter.liminf_const_top
-/

#print Filter.HasBasis.limsSup_eq_iInf_sSup /-
theorem HasBasis.limsSup_eq_iInf_sSup {ι} {p : ι → Prop} {s} {f : Filter α} (h : f.HasBasis p s) :
    limsSup f = ⨅ (i) (hi : p i), sSup (s i) :=
  le_antisymm (le_iInf₂ fun i hi => sInf_le <| h.eventually_iff.2 ⟨i, hi, fun x => le_sSup⟩)
    (le_sInf fun a ha =>
      let ⟨i, hi, ha⟩ := h.eventually_iff.1 ha
      iInf₂_le_of_le _ hi <| sSup_le ha)
#align filter.has_basis.Limsup_eq_infi_Sup Filter.HasBasis.limsSup_eq_iInf_sSup
-/

#print Filter.HasBasis.limsInf_eq_iSup_sInf /-
theorem HasBasis.limsInf_eq_iSup_sInf {p : ι → Prop} {s : ι → Set α} {f : Filter α}
    (h : f.HasBasis p s) : limsInf f = ⨆ (i) (hi : p i), sInf (s i) :=
  @HasBasis.limsSup_eq_iInf_sSup αᵒᵈ _ _ _ _ _ h
#align filter.has_basis.Liminf_eq_supr_Inf Filter.HasBasis.limsInf_eq_iSup_sInf
-/

#print Filter.limsSup_eq_iInf_sSup /-
theorem limsSup_eq_iInf_sSup {f : Filter α} : limsSup f = ⨅ s ∈ f, sSup s :=
  f.basis_sets.limsSup_eq_iInf_sSup
#align filter.Limsup_eq_infi_Sup Filter.limsSup_eq_iInf_sSup
-/

#print Filter.limsInf_eq_iSup_sInf /-
theorem limsInf_eq_iSup_sInf {f : Filter α} : limsInf f = ⨆ s ∈ f, sInf s :=
  @limsSup_eq_iInf_sSup αᵒᵈ _ _
#align filter.Liminf_eq_supr_Inf Filter.limsInf_eq_iSup_sInf
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic filter.is_bounded_default -/
#print Filter.limsup_le_iSup /-
theorem limsup_le_iSup {f : Filter β} {u : β → α} : limsup u f ≤ ⨆ n, u n :=
  limsSup_le_of_le
    (by
      run_tac
        is_bounded_default)
    (eventually_of_forall (le_iSup u))
#align filter.limsup_le_supr Filter.limsup_le_iSup
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic filter.is_bounded_default -/
#print Filter.iInf_le_liminf /-
theorem iInf_le_liminf {f : Filter β} {u : β → α} : (⨅ n, u n) ≤ liminf u f :=
  le_liminf_of_le
    (by
      run_tac
        is_bounded_default)
    (eventually_of_forall (iInf_le u))
#align filter.infi_le_liminf Filter.iInf_le_liminf
-/

#print Filter.limsup_eq_iInf_iSup /-
/-- In a complete lattice, the limsup of a function is the infimum over sets `s` in the filter
of the supremum of the function over `s` -/
theorem limsup_eq_iInf_iSup {f : Filter β} {u : β → α} : limsup u f = ⨅ s ∈ f, ⨆ a ∈ s, u a :=
  (f.basis_sets.map u).limsSup_eq_iInf_sSup.trans <| by simp only [sSup_image, id]
#align filter.limsup_eq_infi_supr Filter.limsup_eq_iInf_iSup
-/

#print Filter.limsup_eq_iInf_iSup_of_nat /-
theorem limsup_eq_iInf_iSup_of_nat {u : ℕ → α} : limsup u atTop = ⨅ n : ℕ, ⨆ i ≥ n, u i :=
  (atTop_basis.map u).limsSup_eq_iInf_sSup.trans <| by simp only [sSup_image, iInf_const] <;> rfl
#align filter.limsup_eq_infi_supr_of_nat Filter.limsup_eq_iInf_iSup_of_nat
-/

#print Filter.limsup_eq_iInf_iSup_of_nat' /-
theorem limsup_eq_iInf_iSup_of_nat' {u : ℕ → α} : limsup u atTop = ⨅ n : ℕ, ⨆ i : ℕ, u (i + n) := by
  simp only [limsup_eq_infi_supr_of_nat, iSup_ge_eq_iSup_nat_add]
#align filter.limsup_eq_infi_supr_of_nat' Filter.limsup_eq_iInf_iSup_of_nat'
-/

#print Filter.HasBasis.limsup_eq_iInf_iSup /-
theorem HasBasis.limsup_eq_iInf_iSup {p : ι → Prop} {s : ι → Set β} {f : Filter β} {u : β → α}
    (h : f.HasBasis p s) : limsup u f = ⨅ (i) (hi : p i), ⨆ a ∈ s i, u a :=
  (h.map u).limsSup_eq_iInf_sSup.trans <| by simp only [sSup_image, id]
#align filter.has_basis.limsup_eq_infi_supr Filter.HasBasis.limsup_eq_iInf_iSup
-/

#print Filter.blimsup_congr' /-
theorem blimsup_congr' {f : Filter β} {p q : β → Prop} {u : β → α}
    (h : ∀ᶠ x in f, u x ≠ ⊥ → (p x ↔ q x)) : blimsup u f p = blimsup u f q :=
  by
  simp only [blimsup_eq]
  congr
  ext a
  refine' eventually_congr (h.mono fun b hb => _)
  cases' eq_or_ne (u b) ⊥ with hu hu; · simp [hu]
  rw [hb hu]
#align filter.blimsup_congr' Filter.blimsup_congr'
-/

#print Filter.bliminf_congr' /-
theorem bliminf_congr' {f : Filter β} {p q : β → Prop} {u : β → α}
    (h : ∀ᶠ x in f, u x ≠ ⊤ → (p x ↔ q x)) : bliminf u f p = bliminf u f q :=
  @blimsup_congr' αᵒᵈ β _ _ _ _ _ h
#align filter.bliminf_congr' Filter.bliminf_congr'
-/

#print Filter.blimsup_eq_iInf_biSup /-
theorem blimsup_eq_iInf_biSup {f : Filter β} {p : β → Prop} {u : β → α} :
    blimsup u f p = ⨅ s ∈ f, ⨆ (b) (hb : p b ∧ b ∈ s), u b :=
  by
  refine' le_antisymm (sInf_le_sInf _) (infi_le_iff.mpr fun a ha => le_Inf_iff.mpr fun a' ha' => _)
  · rintro - ⟨s, rfl⟩
    simp only [mem_set_of_eq, le_iInf_iff]
    conv =>
      congr
      ext
      rw [Imp.swap]
    refine'
      eventually_imp_distrib_left.mpr fun h => eventually_iff_exists_mem.2 ⟨s, h, fun x h₁ h₂ => _⟩
    exact @le_iSup₂ α β (fun b => p b ∧ b ∈ s) _ (fun b hb => u b) x ⟨h₂, h₁⟩
  · obtain ⟨s, hs, hs'⟩ := eventually_iff_exists_mem.mp ha'
    simp_rw [Imp.swap] at hs' 
    exact (le_infi_iff.mp (ha s) hs).trans (by simpa only [iSup₂_le_iff, and_imp])
#align filter.blimsup_eq_infi_bsupr Filter.blimsup_eq_iInf_biSup
-/

#print Filter.blimsup_eq_iInf_biSup_of_nat /-
theorem blimsup_eq_iInf_biSup_of_nat {p : ℕ → Prop} {u : ℕ → α} :
    blimsup u atTop p = ⨅ i, ⨆ (j) (hj : p j ∧ i ≤ j), u j := by
  simp only [blimsup_eq_limsup_subtype, mem_preimage, mem_Ici, Function.comp_apply, ciInf_pos,
    iSup_subtype, (at_top_basis.comap (coe : {x | p x} → ℕ)).limsup_eq_iInf_iSup, mem_set_of_eq,
    Subtype.coe_mk, iSup_and]
#align filter.blimsup_eq_infi_bsupr_of_nat Filter.blimsup_eq_iInf_biSup_of_nat
-/

#print Filter.liminf_eq_iSup_iInf /-
/-- In a complete lattice, the liminf of a function is the infimum over sets `s` in the filter
of the supremum of the function over `s` -/
theorem liminf_eq_iSup_iInf {f : Filter β} {u : β → α} : liminf u f = ⨆ s ∈ f, ⨅ a ∈ s, u a :=
  @limsup_eq_iInf_iSup αᵒᵈ β _ _ _
#align filter.liminf_eq_supr_infi Filter.liminf_eq_iSup_iInf
-/

#print Filter.liminf_eq_iSup_iInf_of_nat /-
theorem liminf_eq_iSup_iInf_of_nat {u : ℕ → α} : liminf u atTop = ⨆ n : ℕ, ⨅ i ≥ n, u i :=
  @limsup_eq_iInf_iSup_of_nat αᵒᵈ _ u
#align filter.liminf_eq_supr_infi_of_nat Filter.liminf_eq_iSup_iInf_of_nat
-/

#print Filter.liminf_eq_iSup_iInf_of_nat' /-
theorem liminf_eq_iSup_iInf_of_nat' {u : ℕ → α} : liminf u atTop = ⨆ n : ℕ, ⨅ i : ℕ, u (i + n) :=
  @limsup_eq_iInf_iSup_of_nat' αᵒᵈ _ _
#align filter.liminf_eq_supr_infi_of_nat' Filter.liminf_eq_iSup_iInf_of_nat'
-/

#print Filter.HasBasis.liminf_eq_iSup_iInf /-
theorem HasBasis.liminf_eq_iSup_iInf {p : ι → Prop} {s : ι → Set β} {f : Filter β} {u : β → α}
    (h : f.HasBasis p s) : liminf u f = ⨆ (i) (hi : p i), ⨅ a ∈ s i, u a :=
  @HasBasis.limsup_eq_iInf_iSup αᵒᵈ _ _ _ _ _ _ _ h
#align filter.has_basis.liminf_eq_supr_infi Filter.HasBasis.liminf_eq_iSup_iInf
-/

#print Filter.bliminf_eq_iSup_biInf /-
theorem bliminf_eq_iSup_biInf {f : Filter β} {p : β → Prop} {u : β → α} :
    bliminf u f p = ⨆ s ∈ f, ⨅ (b) (hb : p b ∧ b ∈ s), u b :=
  @blimsup_eq_iInf_biSup αᵒᵈ β _ f p u
#align filter.bliminf_eq_supr_binfi Filter.bliminf_eq_iSup_biInf
-/

#print Filter.bliminf_eq_iSup_biInf_of_nat /-
theorem bliminf_eq_iSup_biInf_of_nat {p : ℕ → Prop} {u : ℕ → α} :
    bliminf u atTop p = ⨆ i, ⨅ (j) (hj : p j ∧ i ≤ j), u j :=
  @blimsup_eq_iInf_biSup_of_nat αᵒᵈ _ p u
#align filter.bliminf_eq_supr_binfi_of_nat Filter.bliminf_eq_iSup_biInf_of_nat
-/

#print Filter.limsup_eq_sInf_sSup /-
theorem limsup_eq_sInf_sSup {ι R : Type _} (F : Filter ι) [CompleteLattice R] (a : ι → R) :
    limsup a F = sInf ((fun I => sSup (a '' I)) '' F.sets) :=
  by
  refine' le_antisymm _ _
  · rw [limsup_eq]
    refine' sInf_le_sInf fun x hx => _
    rcases(mem_image _ F.sets x).mp hx with ⟨I, ⟨I_mem_F, hI⟩⟩
    filter_upwards [I_mem_F] with i hi
    exact hI ▸ le_sSup (mem_image_of_mem _ hi)
  · refine'
      le_Inf_iff.mpr fun b hb =>
        sInf_le_of_le (mem_image_of_mem _ <| filter.mem_sets.mpr hb) <| sSup_le _
    rintro _ ⟨_, h, rfl⟩
    exact h
#align filter.limsup_eq_Inf_Sup Filter.limsup_eq_sInf_sSup
-/

#print Filter.liminf_eq_sSup_sInf /-
theorem liminf_eq_sSup_sInf {ι R : Type _} (F : Filter ι) [CompleteLattice R] (a : ι → R) :
    liminf a F = sSup ((fun I => sInf (a '' I)) '' F.sets) :=
  @Filter.limsup_eq_sInf_sSup ι (OrderDual R) _ _ a
#align filter.liminf_eq_Sup_Inf Filter.liminf_eq_sSup_sInf
-/

#print Filter.liminf_nat_add /-
@[simp]
theorem liminf_nat_add (f : ℕ → α) (k : ℕ) : liminf (fun i => f (i + k)) atTop = liminf f atTop :=
  by simp_rw [liminf_eq_supr_infi_of_nat]; exact iSup_iInf_ge_nat_add f k
#align filter.liminf_nat_add Filter.liminf_nat_add
-/

#print Filter.limsup_nat_add /-
@[simp]
theorem limsup_nat_add (f : ℕ → α) (k : ℕ) : limsup (fun i => f (i + k)) atTop = limsup f atTop :=
  @liminf_nat_add αᵒᵈ _ f k
#align filter.limsup_nat_add Filter.limsup_nat_add
-/

#print Filter.liminf_le_of_frequently_le' /-
theorem liminf_le_of_frequently_le' {α β} [CompleteLattice β] {f : Filter α} {u : α → β} {x : β}
    (h : ∃ᶠ a in f, u a ≤ x) : liminf u f ≤ x :=
  by
  rw [liminf_eq]
  refine' sSup_le fun b hb => _
  have hbx : ∃ᶠ a in f, b ≤ x := by
    revert h
    rw [← not_imp_not, not_frequently, not_frequently]
    exact fun h => hb.mp (h.mono fun a hbx hba hax => hbx (hba.trans hax))
  exact hbx.exists.some_spec
#align filter.liminf_le_of_frequently_le' Filter.liminf_le_of_frequently_le'
-/

#print Filter.le_limsup_of_frequently_le' /-
theorem le_limsup_of_frequently_le' {α β} [CompleteLattice β] {f : Filter α} {u : α → β} {x : β}
    (h : ∃ᶠ a in f, x ≤ u a) : x ≤ limsup u f :=
  @liminf_le_of_frequently_le' _ βᵒᵈ _ _ _ _ h
#align filter.le_limsup_of_frequently_le' Filter.le_limsup_of_frequently_le'
-/

#print Filter.CompleteLatticeHom.apply_limsup_iterate /-
/-- If `f : α → α` is a morphism of complete lattices, then the limsup of its iterates of any
`a : α` is a fixed point. -/
@[simp]
theorem CompleteLatticeHom.apply_limsup_iterate (f : CompleteLatticeHom α α) (a : α) :
    f (limsup (fun n => (f^[n]) a) atTop) = limsup (fun n => (f^[n]) a) atTop :=
  by
  rw [limsup_eq_infi_supr_of_nat', map_iInf]
  simp_rw [_root_.map_supr, ← Function.comp_apply f, ← Function.iterate_succ' f, ← Nat.add_succ]
  conv_rhs => rw [iInf_split _ ((· < ·) (0 : ℕ))]
  simp only [not_lt, le_zero_iff, iInf_iInf_eq_left, add_zero, iInf_nat_gt_zero_eq, left_eq_inf]
  refine' (iInf_le (fun i => ⨆ j, (f^[j + (i + 1)]) a) 0).trans _
  simp only [zero_add, Function.comp_apply, iSup_le_iff]
  exact fun i => le_iSup (fun i => (f^[i]) a) (i + 1)
#align filter.complete_lattice_hom.apply_limsup_iterate Filter.CompleteLatticeHom.apply_limsup_iterate
-/

#print Filter.CompleteLatticeHom.apply_liminf_iterate /-
/-- If `f : α → α` is a morphism of complete lattices, then the liminf of its iterates of any
`a : α` is a fixed point. -/
theorem CompleteLatticeHom.apply_liminf_iterate (f : CompleteLatticeHom α α) (a : α) :
    f (liminf (fun n => (f^[n]) a) atTop) = liminf (fun n => (f^[n]) a) atTop :=
  (CompleteLatticeHom.dual f).apply_limsup_iterate _
#align filter.complete_lattice_hom.apply_liminf_iterate Filter.CompleteLatticeHom.apply_liminf_iterate
-/

variable {f g : Filter β} {p q : β → Prop} {u v : β → α}

#print Filter.blimsup_mono /-
theorem blimsup_mono (h : ∀ x, p x → q x) : blimsup u f p ≤ blimsup u f q :=
  sInf_le_sInf fun a ha => ha.mono <| by tauto
#align filter.blimsup_mono Filter.blimsup_mono
-/

#print Filter.bliminf_antitone /-
theorem bliminf_antitone (h : ∀ x, p x → q x) : bliminf u f q ≤ bliminf u f p :=
  sSup_le_sSup fun a ha => ha.mono <| by tauto
#align filter.bliminf_antitone Filter.bliminf_antitone
-/

#print Filter.mono_blimsup' /-
theorem mono_blimsup' (h : ∀ᶠ x in f, p x → u x ≤ v x) : blimsup u f p ≤ blimsup v f p :=
  sInf_le_sInf fun a ha => (ha.And h).mono fun x hx hx' => (hx.2 hx').trans (hx.1 hx')
#align filter.mono_blimsup' Filter.mono_blimsup'
-/

#print Filter.mono_blimsup /-
theorem mono_blimsup (h : ∀ x, p x → u x ≤ v x) : blimsup u f p ≤ blimsup v f p :=
  mono_blimsup' <| eventually_of_forall h
#align filter.mono_blimsup Filter.mono_blimsup
-/

#print Filter.mono_bliminf' /-
theorem mono_bliminf' (h : ∀ᶠ x in f, p x → u x ≤ v x) : bliminf u f p ≤ bliminf v f p :=
  sSup_le_sSup fun a ha => (ha.And h).mono fun x hx hx' => (hx.1 hx').trans (hx.2 hx')
#align filter.mono_bliminf' Filter.mono_bliminf'
-/

#print Filter.mono_bliminf /-
theorem mono_bliminf (h : ∀ x, p x → u x ≤ v x) : bliminf u f p ≤ bliminf v f p :=
  mono_bliminf' <| eventually_of_forall h
#align filter.mono_bliminf Filter.mono_bliminf
-/

#print Filter.bliminf_antitone_filter /-
theorem bliminf_antitone_filter (h : f ≤ g) : bliminf u g p ≤ bliminf u f p :=
  sSup_le_sSup fun a ha => ha.filter_mono h
#align filter.bliminf_antitone_filter Filter.bliminf_antitone_filter
-/

#print Filter.blimsup_monotone_filter /-
theorem blimsup_monotone_filter (h : f ≤ g) : blimsup u f p ≤ blimsup u g p :=
  sInf_le_sInf fun a ha => ha.filter_mono h
#align filter.blimsup_monotone_filter Filter.blimsup_monotone_filter
-/

#print Filter.blimsup_and_le_inf /-
@[simp]
theorem blimsup_and_le_inf : (blimsup u f fun x => p x ∧ q x) ≤ blimsup u f p ⊓ blimsup u f q :=
  le_inf (blimsup_mono <| by tauto) (blimsup_mono <| by tauto)
#align filter.blimsup_and_le_inf Filter.blimsup_and_le_inf
-/

#print Filter.bliminf_sup_le_and /-
@[simp]
theorem bliminf_sup_le_and : bliminf u f p ⊔ bliminf u f q ≤ bliminf u f fun x => p x ∧ q x :=
  @blimsup_and_le_inf αᵒᵈ β _ f p q u
#align filter.bliminf_sup_le_and Filter.bliminf_sup_le_and
-/

#print Filter.blimsup_sup_le_or /-
/-- See also `filter.blimsup_or_eq_sup`. -/
@[simp]
theorem blimsup_sup_le_or : blimsup u f p ⊔ blimsup u f q ≤ blimsup u f fun x => p x ∨ q x :=
  sup_le (blimsup_mono <| by tauto) (blimsup_mono <| by tauto)
#align filter.blimsup_sup_le_or Filter.blimsup_sup_le_or
-/

#print Filter.bliminf_or_le_inf /-
/-- See also `filter.bliminf_or_eq_inf`. -/
@[simp]
theorem bliminf_or_le_inf : (bliminf u f fun x => p x ∨ q x) ≤ bliminf u f p ⊓ bliminf u f q :=
  @blimsup_sup_le_or αᵒᵈ β _ f p q u
#align filter.bliminf_or_le_inf Filter.bliminf_or_le_inf
-/

#print Filter.OrderIso.apply_blimsup /-
theorem OrderIso.apply_blimsup [CompleteLattice γ] (e : α ≃o γ) :
    e (blimsup u f p) = blimsup (e ∘ u) f p :=
  by
  simp only [blimsup_eq, map_Inf, Function.comp_apply]
  congr
  ext c
  obtain ⟨a, rfl⟩ := e.surjective c
  simp
#align filter.order_iso.apply_blimsup Filter.OrderIso.apply_blimsup
-/

#print Filter.OrderIso.apply_bliminf /-
theorem OrderIso.apply_bliminf [CompleteLattice γ] (e : α ≃o γ) :
    e (bliminf u f p) = bliminf (e ∘ u) f p :=
  @OrderIso.apply_blimsup αᵒᵈ β γᵒᵈ _ f p u _ e.dual
#align filter.order_iso.apply_bliminf Filter.OrderIso.apply_bliminf
-/

#print Filter.SupHom.apply_blimsup_le /-
theorem SupHom.apply_blimsup_le [CompleteLattice γ] (g : sSupHom α γ) :
    g (blimsup u f p) ≤ blimsup (g ∘ u) f p :=
  by
  simp only [blimsup_eq_infi_bsupr]
  refine' ((OrderHomClass.mono g).map_iInf₂_le _).trans _
  simp only [_root_.map_supr]
#align filter.Sup_hom.apply_blimsup_le Filter.SupHom.apply_blimsup_le
-/

#print Filter.InfHom.le_apply_bliminf /-
theorem InfHom.le_apply_bliminf [CompleteLattice γ] (g : sInfHom α γ) :
    bliminf (g ∘ u) f p ≤ g (bliminf u f p) :=
  @SupHom.apply_blimsup_le αᵒᵈ β γᵒᵈ _ f p u _ g.dual
#align filter.Inf_hom.le_apply_bliminf Filter.InfHom.le_apply_bliminf
-/

end CompleteLattice

section CompleteDistribLattice

variable [CompleteDistribLattice α] {f : Filter β} {p q : β → Prop} {u : β → α}

#print Filter.blimsup_or_eq_sup /-
@[simp]
theorem blimsup_or_eq_sup : (blimsup u f fun x => p x ∨ q x) = blimsup u f p ⊔ blimsup u f q :=
  by
  refine' le_antisymm _ blimsup_sup_le_or
  simp only [blimsup_eq, sInf_sup_eq, sup_sInf_eq, le_iInf₂_iff, mem_set_of_eq]
  refine' fun a' ha' a ha => sInf_le ((ha.And ha').mono fun b h hb => _)
  exact Or.elim hb (fun hb => le_sup_of_le_left <| h.1 hb) fun hb => le_sup_of_le_right <| h.2 hb
#align filter.blimsup_or_eq_sup Filter.blimsup_or_eq_sup
-/

#print Filter.bliminf_or_eq_inf /-
@[simp]
theorem bliminf_or_eq_inf : (bliminf u f fun x => p x ∨ q x) = bliminf u f p ⊓ bliminf u f q :=
  @blimsup_or_eq_sup αᵒᵈ β _ f p q u
#align filter.bliminf_or_eq_inf Filter.bliminf_or_eq_inf
-/

#print Filter.sup_limsup /-
theorem sup_limsup [NeBot f] (a : α) : a ⊔ limsup u f = limsup (fun x => a ⊔ u x) f :=
  by
  simp only [limsup_eq_infi_supr, iSup_sup_eq, sup_iInf₂_eq]
  congr; ext s; congr; ext hs; congr
  exact (biSup_const (nonempty_of_mem hs)).symm
#align filter.sup_limsup Filter.sup_limsup
-/

#print Filter.inf_liminf /-
theorem inf_liminf [NeBot f] (a : α) : a ⊓ liminf u f = liminf (fun x => a ⊓ u x) f :=
  @sup_limsup αᵒᵈ β _ f _ _ _
#align filter.inf_liminf Filter.inf_liminf
-/

#print Filter.sup_liminf /-
theorem sup_liminf (a : α) : a ⊔ liminf u f = liminf (fun x => a ⊔ u x) f :=
  by
  simp only [liminf_eq_supr_infi]
  rw [sup_comm, biSup_sup (⟨univ, univ_mem⟩ : ∃ i : Set β, i ∈ f)]
  simp_rw [iInf₂_sup_eq, @sup_comm _ _ a]
#align filter.sup_liminf Filter.sup_liminf
-/

#print Filter.inf_limsup /-
theorem inf_limsup (a : α) : a ⊓ limsup u f = limsup (fun x => a ⊓ u x) f :=
  @sup_liminf αᵒᵈ β _ f _ _
#align filter.inf_limsup Filter.inf_limsup
-/

end CompleteDistribLattice

section CompleteBooleanAlgebra

variable [CompleteBooleanAlgebra α] (f : Filter β) (u : β → α)

#print Filter.limsup_compl /-
theorem limsup_compl : limsup u fᶜ = liminf (compl ∘ u) f := by
  simp only [limsup_eq_infi_supr, liminf_eq_supr_infi, compl_iInf, compl_iSup]
#align filter.limsup_compl Filter.limsup_compl
-/

#print Filter.liminf_compl /-
theorem liminf_compl : liminf u fᶜ = limsup (compl ∘ u) f := by
  simp only [limsup_eq_infi_supr, liminf_eq_supr_infi, compl_iInf, compl_iSup]
#align filter.liminf_compl Filter.liminf_compl
-/

#print Filter.limsup_sdiff /-
theorem limsup_sdiff (a : α) : limsup u f \ a = limsup (fun b => u b \ a) f :=
  by
  simp only [limsup_eq_infi_supr, sdiff_eq]
  rw [biInf_inf (⟨univ, univ_mem⟩ : ∃ i : Set β, i ∈ f)]
  simp_rw [inf_comm, inf_iSup₂_eq, inf_comm]
#align filter.limsup_sdiff Filter.limsup_sdiff
-/

#print Filter.liminf_sdiff /-
theorem liminf_sdiff [NeBot f] (a : α) : liminf u f \ a = liminf (fun b => u b \ a) f := by
  simp only [sdiff_eq, @inf_comm _ _ _ (aᶜ), inf_liminf]
#align filter.liminf_sdiff Filter.liminf_sdiff
-/

#print Filter.sdiff_limsup /-
theorem sdiff_limsup [NeBot f] (a : α) : a \ limsup u f = liminf (fun b => a \ u b) f :=
  by
  rw [← compl_inj_iff]
  simp only [sdiff_eq, liminf_compl, (· ∘ ·), compl_inf, compl_compl, sup_limsup]
#align filter.sdiff_limsup Filter.sdiff_limsup
-/

#print Filter.sdiff_liminf /-
theorem sdiff_liminf (a : α) : a \ liminf u f = limsup (fun b => a \ u b) f :=
  by
  rw [← compl_inj_iff]
  simp only [sdiff_eq, limsup_compl, (· ∘ ·), compl_inf, compl_compl, sup_liminf]
#align filter.sdiff_liminf Filter.sdiff_liminf
-/

end CompleteBooleanAlgebra

section SetLattice

variable {p : ι → Prop} {s : ι → Set α}

#print Filter.cofinite.blimsup_set_eq /-
theorem cofinite.blimsup_set_eq : blimsup s cofinite p = {x | {n | p n ∧ x ∈ s n}.Infinite} :=
  by
  simp only [blimsup_eq, le_eq_subset, eventually_cofinite, not_forall, Inf_eq_sInter, exists_prop]
  ext x
  refine' ⟨fun h => _, fun hx t h => _⟩ <;> contrapose! h
  · simp only [mem_sInter, mem_set_of_eq, not_forall, exists_prop]
    exact ⟨{x}ᶜ, by simpa using h, by simp⟩
  · exact hx.mono fun i hi => ⟨hi.1, fun hit => h (hit hi.2)⟩
#align filter.cofinite.blimsup_set_eq Filter.cofinite.blimsup_set_eq
-/

#print Filter.cofinite.bliminf_set_eq /-
theorem cofinite.bliminf_set_eq : bliminf s cofinite p = {x | {n | p n ∧ x ∉ s n}.Finite} :=
  by
  rw [← compl_inj_iff]
  simpa only [bliminf_eq_supr_binfi, compl_iInf, compl_iSup, ← blimsup_eq_infi_bsupr,
    cofinite.blimsup_set_eq]
#align filter.cofinite.bliminf_set_eq Filter.cofinite.bliminf_set_eq
-/

#print Filter.cofinite.limsup_set_eq /-
/-- In other words, `limsup cofinite s` is the set of elements lying inside the family `s`
infinitely often. -/
theorem cofinite.limsup_set_eq : limsup s cofinite = {x | {n | x ∈ s n}.Infinite} := by
  simp only [← cofinite.blimsup_true s, cofinite.blimsup_set_eq, true_and_iff]
#align filter.cofinite.limsup_set_eq Filter.cofinite.limsup_set_eq
-/

#print Filter.cofinite.liminf_set_eq /-
/-- In other words, `liminf cofinite s` is the set of elements lying outside the family `s`
finitely often. -/
theorem cofinite.liminf_set_eq : liminf s cofinite = {x | {n | x ∉ s n}.Finite} := by
  simp only [← cofinite.bliminf_true s, cofinite.bliminf_set_eq, true_and_iff]
#align filter.cofinite.liminf_set_eq Filter.cofinite.liminf_set_eq
-/

#print Filter.exists_forall_mem_of_hasBasis_mem_blimsup /-
theorem exists_forall_mem_of_hasBasis_mem_blimsup {l : Filter β} {b : ι → Set β} {q : ι → Prop}
    (hl : l.HasBasis q b) {u : β → Set α} {p : β → Prop} {x : α} (hx : x ∈ blimsup u l p) :
    ∃ f : {i | q i} → β, ∀ i, x ∈ u (f i) ∧ p (f i) ∧ f i ∈ b i :=
  by
  rw [blimsup_eq_infi_bsupr] at hx 
  simp only [supr_eq_Union, infi_eq_Inter, mem_Inter, mem_Union, exists_prop] at hx 
  choose g hg hg' using hx
  refine' ⟨fun i : {i | q i} => g (b i) (hl.mem_of_mem i.2), fun i => ⟨_, _⟩⟩
  · exact hg' (b i) (hl.mem_of_mem i.2)
  · exact hg (b i) (hl.mem_of_mem i.2)
#align filter.exists_forall_mem_of_has_basis_mem_blimsup Filter.exists_forall_mem_of_hasBasis_mem_blimsup
-/

#print Filter.exists_forall_mem_of_hasBasis_mem_blimsup' /-
theorem exists_forall_mem_of_hasBasis_mem_blimsup' {l : Filter β} {b : ι → Set β}
    (hl : l.HasBasis (fun _ => True) b) {u : β → Set α} {p : β → Prop} {x : α}
    (hx : x ∈ blimsup u l p) : ∃ f : ι → β, ∀ i, x ∈ u (f i) ∧ p (f i) ∧ f i ∈ b i :=
  by
  obtain ⟨f, hf⟩ := exists_forall_mem_of_has_basis_mem_blimsup hl hx
  exact ⟨fun i => f ⟨i, trivial⟩, fun i => hf ⟨i, trivial⟩⟩
#align filter.exists_forall_mem_of_has_basis_mem_blimsup' Filter.exists_forall_mem_of_hasBasis_mem_blimsup'
-/

end SetLattice

section ConditionallyCompleteLinearOrder

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.frequently_lt_of_lt_limsSup /-
theorem frequently_lt_of_lt_limsSup {f : Filter α} [ConditionallyCompleteLinearOrder α] {a : α}
    (hf : f.IsCobounded (· ≤ ·) := by
      run_tac
        is_bounded_default)
    (h : a < limsSup f) : ∃ᶠ n in f, a < n :=
  by
  contrapose! h
  simp only [not_frequently, not_lt] at h 
  exact Limsup_le_of_le hf h
#align filter.frequently_lt_of_lt_Limsup Filter.frequently_lt_of_lt_limsSup
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.frequently_lt_of_limsInf_lt /-
theorem frequently_lt_of_limsInf_lt {f : Filter α} [ConditionallyCompleteLinearOrder α] {a : α}
    (hf : f.IsCobounded (· ≥ ·) := by
      run_tac
        is_bounded_default)
    (h : limsInf f < a) : ∃ᶠ n in f, n < a :=
  @frequently_lt_of_lt_limsSup (OrderDual α) f _ a hf h
#align filter.frequently_lt_of_Liminf_lt Filter.frequently_lt_of_limsInf_lt
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.eventually_lt_of_lt_liminf /-
theorem eventually_lt_of_lt_liminf {f : Filter α} [ConditionallyCompleteLinearOrder β] {u : α → β}
    {b : β} (h : b < liminf u f)
    (hu : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    ∀ᶠ a in f, b < u a :=
  by
  obtain ⟨c, hc, hbc⟩ : ∃ (c : β) (hc : c ∈ {c : β | ∀ᶠ n : α in f, c ≤ u n}), b < c :=
    exists_lt_of_lt_csSup hu h
  exact hc.mono fun x hx => lt_of_lt_of_le hbc hx
#align filter.eventually_lt_of_lt_liminf Filter.eventually_lt_of_lt_liminf
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.eventually_lt_of_limsup_lt /-
theorem eventually_lt_of_limsup_lt {f : Filter α} [ConditionallyCompleteLinearOrder β] {u : α → β}
    {b : β} (h : limsup u f < b)
    (hu : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default) :
    ∀ᶠ a in f, u a < b :=
  @eventually_lt_of_lt_liminf _ βᵒᵈ _ _ _ _ h hu
#align filter.eventually_lt_of_limsup_lt Filter.eventually_lt_of_limsup_lt
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.le_limsup_of_frequently_le /-
theorem le_limsup_of_frequently_le {α β} [ConditionallyCompleteLinearOrder β] {f : Filter α}
    {u : α → β} {b : β} (hu_le : ∃ᶠ x in f, b ≤ u x)
    (hu : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default) :
    b ≤ limsup u f := by
  revert hu_le
  rw [← not_imp_not, not_frequently]
  simp_rw [← lt_iff_not_ge]
  exact fun h => eventually_lt_of_limsup_lt h hu
#align filter.le_limsup_of_frequently_le Filter.le_limsup_of_frequently_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.liminf_le_of_frequently_le /-
theorem liminf_le_of_frequently_le {α β} [ConditionallyCompleteLinearOrder β] {f : Filter α}
    {u : α → β} {b : β} (hu_le : ∃ᶠ x in f, u x ≤ b)
    (hu : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    liminf u f ≤ b :=
  @le_limsup_of_frequently_le _ βᵒᵈ _ f u b hu_le hu
#align filter.liminf_le_of_frequently_le Filter.liminf_le_of_frequently_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.frequently_lt_of_lt_limsup /-
theorem frequently_lt_of_lt_limsup {α β} [ConditionallyCompleteLinearOrder β] {f : Filter α}
    {u : α → β} {b : β}
    (hu : f.IsCoboundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h : b < limsup u f) : ∃ᶠ x in f, b < u x :=
  by
  contrapose! h
  apply Limsup_le_of_le hu
  simpa using h
#align filter.frequently_lt_of_lt_limsup Filter.frequently_lt_of_lt_limsup
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print Filter.frequently_lt_of_liminf_lt /-
theorem frequently_lt_of_liminf_lt {α β} [ConditionallyCompleteLinearOrder β] {f : Filter α}
    {u : α → β} {b : β}
    (hu : f.IsCoboundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default)
    (h : liminf u f < b) : ∃ᶠ x in f, u x < b :=
  @frequently_lt_of_lt_limsup _ βᵒᵈ _ f u b hu h
#align filter.frequently_lt_of_liminf_lt Filter.frequently_lt_of_liminf_lt
-/

end ConditionallyCompleteLinearOrder

end Filter

section Order

open Filter

#print Monotone.isBoundedUnder_le_comp /-
theorem Monotone.isBoundedUnder_le_comp [Nonempty β] [LinearOrder β] [Preorder γ] [NoMaxOrder γ]
    {g : β → γ} {f : α → β} {l : Filter α} (hg : Monotone g) (hg' : Tendsto g atTop atTop) :
    IsBoundedUnder (· ≤ ·) l (g ∘ f) ↔ IsBoundedUnder (· ≤ ·) l f :=
  by
  refine' ⟨_, fun h => h.IsBoundedUnder hg⟩
  rintro ⟨c, hc⟩; rw [eventually_map] at hc 
  obtain ⟨b, hb⟩ : ∃ b, ∀ a ≥ b, c < g a := eventually_at_top.1 (hg'.eventually_gt_at_top c)
  exact ⟨b, hc.mono fun x hx => not_lt.1 fun h => (hb _ h.le).not_le hx⟩
#align monotone.is_bounded_under_le_comp Monotone.isBoundedUnder_le_comp
-/

#print Monotone.isBoundedUnder_ge_comp /-
theorem Monotone.isBoundedUnder_ge_comp [Nonempty β] [LinearOrder β] [Preorder γ] [NoMinOrder γ]
    {g : β → γ} {f : α → β} {l : Filter α} (hg : Monotone g) (hg' : Tendsto g atBot atBot) :
    IsBoundedUnder (· ≥ ·) l (g ∘ f) ↔ IsBoundedUnder (· ≥ ·) l f :=
  hg.dual.isBoundedUnder_le_comp hg'
#align monotone.is_bounded_under_ge_comp Monotone.isBoundedUnder_ge_comp
-/

#print Antitone.isBoundedUnder_le_comp /-
theorem Antitone.isBoundedUnder_le_comp [Nonempty β] [LinearOrder β] [Preorder γ] [NoMaxOrder γ]
    {g : β → γ} {f : α → β} {l : Filter α} (hg : Antitone g) (hg' : Tendsto g atBot atTop) :
    IsBoundedUnder (· ≤ ·) l (g ∘ f) ↔ IsBoundedUnder (· ≥ ·) l f :=
  hg.dual_right.isBoundedUnder_ge_comp hg'
#align antitone.is_bounded_under_le_comp Antitone.isBoundedUnder_le_comp
-/

#print Antitone.isBoundedUnder_ge_comp /-
theorem Antitone.isBoundedUnder_ge_comp [Nonempty β] [LinearOrder β] [Preorder γ] [NoMinOrder γ]
    {g : β → γ} {f : α → β} {l : Filter α} (hg : Antitone g) (hg' : Tendsto g atTop atBot) :
    IsBoundedUnder (· ≥ ·) l (g ∘ f) ↔ IsBoundedUnder (· ≤ ·) l f :=
  hg.dual_right.isBoundedUnder_le_comp hg'
#align antitone.is_bounded_under_ge_comp Antitone.isBoundedUnder_ge_comp
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print GaloisConnection.l_limsup_le /-
theorem GaloisConnection.l_limsup_le [ConditionallyCompleteLattice β]
    [ConditionallyCompleteLattice γ] {f : Filter α} {v : α → β} {l : β → γ} {u : γ → β}
    (gc : GaloisConnection l u)
    (hlv : f.IsBoundedUnder (· ≤ ·) fun x => l (v x) := by
      run_tac
        is_bounded_default)
    (hv_co : f.IsCoboundedUnder (· ≤ ·) v := by
      run_tac
        is_bounded_default) :
    l (limsup v f) ≤ limsup (fun x => l (v x)) f :=
  by
  refine' le_Limsup_of_le hlv fun c hc => _
  rw [Filter.eventually_map] at hc 
  simp_rw [gc _ _] at hc ⊢
  exact Limsup_le_of_le hv_co hc
#align galois_connection.l_limsup_le GaloisConnection.l_limsup_le
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print OrderIso.limsup_apply /-
theorem OrderIso.limsup_apply {γ} [ConditionallyCompleteLattice β] [ConditionallyCompleteLattice γ]
    {f : Filter α} {u : α → β} (g : β ≃o γ)
    (hu : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (hu_co : f.IsCoboundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (hgu : f.IsBoundedUnder (· ≤ ·) fun x => g (u x) := by
      run_tac
        is_bounded_default)
    (hgu_co : f.IsCoboundedUnder (· ≤ ·) fun x => g (u x) := by
      run_tac
        is_bounded_default) :
    g (limsup u f) = limsup (fun x => g (u x)) f :=
  by
  refine' le_antisymm (g.to_galois_connection.l_limsup_le hgu hu_co) _
  rw [← g.symm.symm_apply_apply <| limsup (fun x => g (u x)) f, g.symm_symm]
  refine' g.monotone _
  have hf : u = fun i => g.symm (g (u i)) := funext fun i => (g.symm_apply_apply (u i)).symm
  nth_rw 1 [hf]
  refine' g.symm.to_galois_connection.l_limsup_le _ hgu_co
  simp_rw [g.symm_apply_apply]
  exact hu
#align order_iso.limsup_apply OrderIso.limsup_apply
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic is_bounded_default -/
#print OrderIso.liminf_apply /-
theorem OrderIso.liminf_apply {γ} [ConditionallyCompleteLattice β] [ConditionallyCompleteLattice γ]
    {f : Filter α} {u : α → β} (g : β ≃o γ)
    (hu : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default)
    (hu_co : f.IsCoboundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default)
    (hgu : f.IsBoundedUnder (· ≥ ·) fun x => g (u x) := by
      run_tac
        is_bounded_default)
    (hgu_co : f.IsCoboundedUnder (· ≥ ·) fun x => g (u x) := by
      run_tac
        is_bounded_default) :
    g (liminf u f) = liminf (fun x => g (u x)) f :=
  @OrderIso.limsup_apply α βᵒᵈ γᵒᵈ _ _ f u g.dual hu hu_co hgu hgu_co
#align order_iso.liminf_apply OrderIso.liminf_apply
-/

end Order

