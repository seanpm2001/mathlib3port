/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module topology.omega_complete_partial_order
! leanprover-community/mathlib commit 4c19a16e4b705bf135cf9a80ac18fcc99c438514
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Basic
import Mathbin.Order.OmegaCompletePartialOrder

/-!
# Scott Topological Spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A type of topological spaces whose notion
of continuity is equivalent to continuity in ωCPOs.

## Reference

 * https://ncatlab.org/nlab/show/Scott+topology

-/


open Set OmegaCompletePartialOrder

open scoped Classical

universe u

namespace Scott

#print Scott.IsωSup /-
/-- `x` is an `ω`-Sup of a chain `c` if it is the least upper bound of the range of `c`. -/
def IsωSup {α : Type u} [Preorder α] (c : Chain α) (x : α) : Prop :=
  (∀ i, c i ≤ x) ∧ ∀ y, (∀ i, c i ≤ y) → x ≤ y
#align Scott.is_ωSup Scott.IsωSup
-/

#print Scott.isωSup_iff_isLUB /-
theorem isωSup_iff_isLUB {α : Type u} [Preorder α] {c : Chain α} {x : α} :
    IsωSup c x ↔ IsLUB (range c) x := by simp [is_ωSup, IsLUB, IsLeast, upperBounds, lowerBounds]
#align Scott.is_ωSup_iff_is_lub Scott.isωSup_iff_isLUB
-/

variable (α : Type u) [OmegaCompletePartialOrder α]

#print Scott.IsOpen /-
/-- The characteristic function of open sets is monotone and preserves
the limits of chains. -/
def IsOpen (s : Set α) : Prop :=
  Continuous' fun x => x ∈ s
#align Scott.is_open Scott.IsOpen
-/

#print Scott.isOpen_univ /-
theorem isOpen_univ : IsOpen α univ :=
  ⟨fun x y h hx => mem_univ _, @CompleteLattice.top_continuous α Prop _ _⟩
#align Scott.is_open_univ Scott.isOpen_univ
-/

#print Scott.IsOpen.inter /-
theorem IsOpen.inter (s t : Set α) : IsOpen α s → IsOpen α t → IsOpen α (s ∩ t) :=
  CompleteLattice.inf_continuous'
#align Scott.is_open.inter Scott.IsOpen.inter
-/

#print Scott.isOpen_sUnion /-
theorem isOpen_sUnion (s : Set (Set α)) (hs : ∀ t ∈ s, IsOpen α t) : IsOpen α (⋃₀ s) :=
  by
  simp only [IsOpen] at hs ⊢
  convert CompleteLattice.sSup_continuous' (setOf ⁻¹' s) _
  · ext1 x
    simp only [sSup_apply, set_of_bijective.surjective.exists, exists_prop, mem_preimage,
      SetCoe.exists, iSup_Prop_eq, mem_set_of_eq, Subtype.coe_mk, mem_sUnion]
  · intro p hp
    exact hs (setOf p) (mem_preimage.1 hp)
#align Scott.is_open_sUnion Scott.isOpen_sUnion
-/

end Scott

#print Scott /-
/-- A Scott topological space is defined on preorders
such that their open sets, seen as a function `α → Prop`,
preserves the joins of ω-chains  -/
@[reducible]
def Scott (α : Type u) :=
  α
#align Scott Scott
-/

#print Scott.topologicalSpace /-
instance Scott.topologicalSpace (α : Type u) [OmegaCompletePartialOrder α] :
    TopologicalSpace (Scott α) where
  IsOpen := Scott.IsOpen α
  isOpen_univ := Scott.isOpen_univ α
  isOpen_inter := Scott.IsOpen.inter α
  isOpen_sUnion := Scott.isOpen_sUnion α
#align Scott.topological_space Scott.topologicalSpace
-/

section notBelow

variable {α : Type _} [OmegaCompletePartialOrder α] (y : Scott α)

#print notBelow /-
/-- `not_below` is an open set in `Scott α` used
to prove the monotonicity of continuous functions -/
def notBelow :=
  {x | ¬x ≤ y}
#align not_below notBelow
-/

#print notBelow_isOpen /-
theorem notBelow_isOpen : IsOpen (notBelow y) :=
  by
  have h : Monotone (notBelow y) := by
    intro x y' h
    simp only [notBelow, setOf, le_Prop_eq]
    intro h₀ h₁; apply h₀ (le_trans h h₁)
  exists h; rintro c
  apply eq_of_forall_ge_iff; intro z
  rw [ωSup_le_iff]
  simp only [ωSup_le_iff, notBelow, mem_set_of_eq, le_Prop_eq, OrderHom.coe_fun_mk, chain.map_coe,
    Function.comp_apply, exists_imp, not_forall]
#align not_below_is_open notBelow_isOpen
-/

end notBelow

open Scott hiding IsOpen

open OmegaCompletePartialOrder

#print isωSup_ωSup /-
theorem isωSup_ωSup {α} [OmegaCompletePartialOrder α] (c : Chain α) : IsωSup c (ωSup c) :=
  by
  constructor
  · apply le_ωSup
  · apply ωSup_le
#align is_ωSup_ωSup isωSup_ωSup
-/

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:568:11: unsupported: specialize non-hyp -/
#print scottContinuous_of_continuous /-
theorem scottContinuous_of_continuous {α β} [OmegaCompletePartialOrder α]
    [OmegaCompletePartialOrder β] (f : Scott α → Scott β) (hf : Continuous f) :
    OmegaCompletePartialOrder.Continuous' f :=
  by
  simp only [continuous_def, (· ⁻¹' ·)] at hf 
  have h : Monotone f := by
    intro x y h
    cases' hf {x | ¬x ≤ f y} (notBelow_isOpen _) with hf hf'; clear hf'
    specialize hf h; simp only [preimage, mem_set_of_eq, le_Prop_eq] at hf 
    by_contra H; apply hf H le_rfl
  exists h; intro c
  apply eq_of_forall_ge_iff; intro z
  specialize
    «./././Mathport/Syntax/Translate/Tactic/Lean3.lean:568:11: unsupported: specialize non-hyp»
  cases hf; specialize hf_h c
  simp only [notBelow, OrderHom.coe_fun_mk, eq_iff_iff, mem_set_of_eq] at hf_h 
  rw [← not_iff_not]
  simp only [ωSup_le_iff, hf_h, ωSup, iSup, Sup, CompleteLattice.sup, CompleteSemilatticeSup.sup,
    exists_prop, mem_range, OrderHom.coe_fun_mk, chain.map_coe, Function.comp_apply, eq_iff_iff,
    not_forall]
  tauto
#align Scott_continuous_of_continuous scottContinuous_of_continuous
-/

#print continuous_of_scottContinuous /-
theorem continuous_of_scottContinuous {α β} [OmegaCompletePartialOrder α]
    [OmegaCompletePartialOrder β] (f : Scott α → Scott β)
    (hf : OmegaCompletePartialOrder.Continuous' f) : Continuous f :=
  by
  rw [continuous_def]
  intro s hs
  change continuous' (s ∘ f)
  cases' hs with hs hs'
  cases' hf with hf hf'
  apply continuous.of_bundled
  apply continuous_comp _ _ hf' hs'
#align continuous_of_Scott_continuous continuous_of_scottContinuous
-/

