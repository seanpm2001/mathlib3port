/-
Copyright (c) 2020 Jean Lo. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jean Lo

! This file was ported from Lean 3 source module dynamics.flow
! leanprover-community/mathlib commit ef7acf407d265ad4081c8998687e994fa80ba70c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.Group.Basic
import Mathbin.Logic.Function.Iterate

/-!
# Flows and invariant sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines a flow on a topological space `α` by a topological
monoid `τ` as a continuous monoid-act of `τ` on `α`. Anticipating the
cases where `τ` is one of `ℕ`, `ℤ`, `ℝ⁺`, or `ℝ`, we use additive
notation for the monoids, though the definition does not require
commutativity.

A subset `s` of `α` is invariant under a family of maps `ϕₜ : α → α`
if `ϕₜ s ⊆ s` for all `t`. In many cases `ϕ` will be a flow on
`α`. For the cases where `ϕ` is a flow by an ordered (additive,
commutative) monoid, we additionally define forward invariance, where
`t` ranges over those elements which are nonnegative.

Additionally, we define such constructions as the restriction of a
flow onto an invariant subset, and the time-reveral of a flow by a
group.
-/


open Set Function Filter

/-!
### Invariant sets
-/


section Invariant

variable {τ : Type _} {α : Type _}

#print IsInvariant /-
/-- A set `s ⊆ α` is invariant under `ϕ : τ → α → α` if
    `ϕ t s ⊆ s` for all `t` in `τ`. -/
def IsInvariant (ϕ : τ → α → α) (s : Set α) : Prop :=
  ∀ t, MapsTo (ϕ t) s s
#align is_invariant IsInvariant
-/

variable (ϕ : τ → α → α) (s : Set α)

#print isInvariant_iff_image /-
theorem isInvariant_iff_image : IsInvariant ϕ s ↔ ∀ t, ϕ t '' s ⊆ s := by
  simp_rw [IsInvariant, maps_to']
#align is_invariant_iff_image isInvariant_iff_image
-/

#print IsFwInvariant /-
/-- A set `s ⊆ α` is forward-invariant under `ϕ : τ → α → α` if
    `ϕ t s ⊆ s` for all `t ≥ 0`. -/
def IsFwInvariant [Preorder τ] [Zero τ] (ϕ : τ → α → α) (s : Set α) : Prop :=
  ∀ ⦃t⦄, 0 ≤ t → MapsTo (ϕ t) s s
#align is_fw_invariant IsFwInvariant
-/

#print IsInvariant.isFwInvariant /-
theorem IsInvariant.isFwInvariant [Preorder τ] [Zero τ] {ϕ : τ → α → α} {s : Set α}
    (h : IsInvariant ϕ s) : IsFwInvariant ϕ s := fun t ht => h t
#align is_invariant.is_fw_invariant IsInvariant.isFwInvariant
-/

#print IsFwInvariant.isInvariant /-
/-- If `τ` is a `canonically_ordered_add_monoid` (e.g., `ℕ` or `ℝ≥0`), then the notions
`is_fw_invariant` and `is_invariant` are equivalent. -/
theorem IsFwInvariant.isInvariant [CanonicallyOrderedAddMonoid τ] {ϕ : τ → α → α} {s : Set α}
    (h : IsFwInvariant ϕ s) : IsInvariant ϕ s := fun t => h (zero_le t)
#align is_fw_invariant.is_invariant IsFwInvariant.isInvariant
-/

#print isFwInvariant_iff_isInvariant /-
/-- If `τ` is a `canonically_ordered_add_monoid` (e.g., `ℕ` or `ℝ≥0`), then the notions
`is_fw_invariant` and `is_invariant` are equivalent. -/
theorem isFwInvariant_iff_isInvariant [CanonicallyOrderedAddMonoid τ] {ϕ : τ → α → α} {s : Set α} :
    IsFwInvariant ϕ s ↔ IsInvariant ϕ s :=
  ⟨IsFwInvariant.isInvariant, IsInvariant.isFwInvariant⟩
#align is_fw_invariant_iff_is_invariant isFwInvariant_iff_isInvariant
-/

end Invariant

/-!
### Flows
-/


#print Flow /-
/-- A flow on a topological space `α` by an a additive topological
    monoid `τ` is a continuous monoid action of `τ` on `α`.-/
structure Flow (τ : Type _) [TopologicalSpace τ] [AddMonoid τ] [ContinuousAdd τ] (α : Type _)
    [TopologicalSpace α] where
  toFun : τ → α → α
  cont' : Continuous (uncurry to_fun)
  map_add' : ∀ t₁ t₂ x, to_fun (t₁ + t₂) x = to_fun t₁ (to_fun t₂ x)
  map_zero' : ∀ x, to_fun 0 x = x
#align flow Flow
-/

namespace Flow

variable {τ : Type _} [AddMonoid τ] [TopologicalSpace τ] [ContinuousAdd τ] {α : Type _}
  [TopologicalSpace α] (ϕ : Flow τ α)

instance : Inhabited (Flow τ α) :=
  ⟨{  toFun := fun _ x => x
      cont' := continuous_snd
      map_add' := fun _ _ _ => rfl
      map_zero' := fun _ => rfl }⟩

instance : CoeFun (Flow τ α) fun _ => τ → α → α :=
  ⟨Flow.toFun⟩

#print Flow.ext /-
@[ext]
theorem ext : ∀ {ϕ₁ ϕ₂ : Flow τ α}, (∀ t x, ϕ₁ t x = ϕ₂ t x) → ϕ₁ = ϕ₂
  | ⟨f₁, _, _, _⟩, ⟨f₂, _, _, _⟩, h => by congr; funext; exact h _ _
#align flow.ext Flow.ext
-/

#print Flow.continuous /-
@[continuity]
protected theorem continuous {β : Type _} [TopologicalSpace β] {t : β → τ} (ht : Continuous t)
    {f : β → α} (hf : Continuous f) : Continuous fun x => ϕ (t x) (f x) :=
  ϕ.cont'.comp (ht.prod_mk hf)
#align flow.continuous Flow.continuous
-/

alias Flow.continuous ← _root_.continuous.flow
#align continuous.flow Continuous.flow

#print Flow.map_add /-
theorem map_add (t₁ t₂ : τ) (x : α) : ϕ (t₁ + t₂) x = ϕ t₁ (ϕ t₂ x) :=
  ϕ.map_add' _ _ _
#align flow.map_add Flow.map_add
-/

#print Flow.map_zero /-
@[simp]
theorem map_zero : ϕ 0 = id :=
  funext ϕ.map_zero'
#align flow.map_zero Flow.map_zero
-/

#print Flow.map_zero_apply /-
theorem map_zero_apply (x : α) : ϕ 0 x = x :=
  ϕ.map_zero' x
#align flow.map_zero_apply Flow.map_zero_apply
-/

#print Flow.fromIter /-
/-- Iterations of a continuous function from a topological space `α`
    to itself defines a semiflow by `ℕ` on `α`. -/
def fromIter {g : α → α} (h : Continuous g) : Flow ℕ α
    where
  toFun n x := (g^[n]) x
  cont' := continuous_uncurry_of_discreteTopology_left (Continuous.iterate h)
  map_add' := iterate_add_apply _
  map_zero' x := rfl
#align flow.from_iter Flow.fromIter
-/

#print Flow.restrict /-
/-- Restriction of a flow onto an invariant set. -/
def restrict {s : Set α} (h : IsInvariant ϕ s) : Flow τ ↥s
    where
  toFun t := (h t).restrict _ _ _
  cont' := (ϕ.Continuous continuous_fst continuous_subtype_val.snd').subtype_mk _
  map_add' _ _ _ := Subtype.ext (map_add _ _ _ _)
  map_zero' _ := Subtype.ext (map_zero_apply _ _)
#align flow.restrict Flow.restrict
-/

end Flow

namespace Flow

variable {τ : Type _} [AddCommGroup τ] [TopologicalSpace τ] [TopologicalAddGroup τ] {α : Type _}
  [TopologicalSpace α] (ϕ : Flow τ α)

#print Flow.isInvariant_iff_image_eq /-
theorem isInvariant_iff_image_eq (s : Set α) : IsInvariant ϕ s ↔ ∀ t, ϕ t '' s = s :=
  (isInvariant_iff_image _ _).trans
    (Iff.intro
      (fun h t => Subset.antisymm (h t) fun _ hx => ⟨_, h (-t) ⟨_, hx, rfl⟩, by simp [← map_add]⟩)
      fun h t => by rw [h t])
#align flow.is_invariant_iff_image_eq Flow.isInvariant_iff_image_eq
-/

#print Flow.reverse /-
/-- The time-reversal of a flow `ϕ` by a (commutative, additive) group
    is defined `ϕ.reverse t x = ϕ (-t) x`. -/
def reverse : Flow τ α where
  toFun t := ϕ (-t)
  cont' := ϕ.Continuous continuous_fst.neg continuous_snd
  map_add' _ _ _ := by rw [neg_add, map_add]
  map_zero' _ := by rw [neg_zero, map_zero_apply]
#align flow.reverse Flow.reverse
-/

#print Flow.toHomeomorph /-
/-- The map `ϕ t` as a homeomorphism. -/
def toHomeomorph (t : τ) : α ≃ₜ α where
  toFun := ϕ t
  invFun := ϕ (-t)
  left_inv x := by rw [← map_add, neg_add_self, map_zero_apply]
  right_inv x := by rw [← map_add, add_neg_self, map_zero_apply]
#align flow.to_homeomorph Flow.toHomeomorph
-/

#print Flow.image_eq_preimage /-
theorem image_eq_preimage (t : τ) (s : Set α) : ϕ t '' s = ϕ (-t) ⁻¹' s :=
  (ϕ.toHomeomorph t).toEquiv.image_eq_preimage s
#align flow.image_eq_preimage Flow.image_eq_preimage
-/

end Flow

