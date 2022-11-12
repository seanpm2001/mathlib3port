/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser
-/
import Mathbin.GroupTheory.Subgroup.Basic
import Mathbin.GroupTheory.Submonoid.Pointwise
import Mathbin.GroupTheory.GroupAction.ConjAct

/-! # Pointwise instances on `subgroup` and `add_subgroup`s

This file provides the actions

* `subgroup.pointwise_mul_action`
* `add_subgroup.pointwise_mul_action`

which matches the action of `mul_action_set`.

These actions are available in the `pointwise` locale.

## Implementation notes

This file is almost identical to `group_theory/submonoid/pointwise.lean`. Where possible, try to
keep them in sync.
-/


open Set

variable {α : Type _} {G : Type _} {A : Type _} [Group G] [AddGroup A]

namespace Subgroup

section Monoid

variable [Monoid α] [MulDistribMulAction α G]

/-- The action on a subgroup corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale. -/
protected def pointwiseMulAction : MulAction α (Subgroup G) where
  smul a S := S.map (MulDistribMulAction.toMonoidEnd _ _ a)
  one_smul S := (congr_arg (fun f => S.map f) (MonoidHom.map_one _)).trans S.map_id
  mul_smul a₁ a₂ S := (congr_arg (fun f => S.map f) (MonoidHom.map_mul _ _ _)).trans (S.map_map _ _).symm
#align subgroup.pointwise_mul_action Subgroup.pointwiseMulAction

localized [Pointwise] attribute [instance] Subgroup.pointwiseMulAction

open Pointwise

theorem pointwise_smul_def {a : α} (S : Subgroup G) : a • S = S.map (MulDistribMulAction.toMonoidEnd _ _ a) :=
  rfl
#align subgroup.pointwise_smul_def Subgroup.pointwise_smul_def

@[simp]
theorem coe_pointwise_smul (a : α) (S : Subgroup G) : ↑(a • S) = a • (S : Set G) :=
  rfl
#align subgroup.coe_pointwise_smul Subgroup.coe_pointwise_smul

@[simp]
theorem pointwise_smul_to_submonoid (a : α) (S : Subgroup G) : (a • S).toSubmonoid = a • S.toSubmonoid :=
  rfl
#align subgroup.pointwise_smul_to_submonoid Subgroup.pointwise_smul_to_submonoid

theorem smul_mem_pointwise_smul (m : G) (a : α) (S : Subgroup G) : m ∈ S → a • m ∈ a • S :=
  (Set.smul_mem_smul_set : _ → _ ∈ a • (S : Set G))
#align subgroup.smul_mem_pointwise_smul Subgroup.smul_mem_pointwise_smul

theorem mem_smul_pointwise_iff_exists (m : G) (a : α) (S : Subgroup G) : m ∈ a • S ↔ ∃ s : G, s ∈ S ∧ a • s = m :=
  (Set.mem_smul_set : m ∈ a • (S : Set G) ↔ _)
#align subgroup.mem_smul_pointwise_iff_exists Subgroup.mem_smul_pointwise_iff_exists

@[simp]
theorem smul_bot (a : α) : a • (⊥ : Subgroup G) = ⊥ := by simp [SetLike.ext_iff, mem_smul_pointwise_iff_exists, eq_comm]
#align subgroup.smul_bot Subgroup.smul_bot

instance pointwise_central_scalar [MulDistribMulAction αᵐᵒᵖ G] [IsCentralScalar α G] : IsCentralScalar α (Subgroup G) :=
  ⟨fun a S => (congr_arg fun f => S.map f) <| MonoidHom.ext <| op_smul_eq_smul _⟩
#align subgroup.pointwise_central_scalar Subgroup.pointwise_central_scalar

theorem conj_smul_le_of_le {P H : Subgroup G} (hP : P ≤ H) (h : H) : MulAut.conj (h : G) • P ≤ H := by
  rintro - ⟨g, hg, rfl⟩
  exact H.mul_mem (H.mul_mem h.2 (hP hg)) (H.inv_mem h.2)
#align subgroup.conj_smul_le_of_le Subgroup.conj_smul_le_of_le

theorem conj_smul_subgroup_of {P H : Subgroup G} (hP : P ≤ H) (h : H) :
    MulAut.conj h • P.subgroupOf H = (MulAut.conj (h : G) • P).subgroupOf H := by
  refine' le_antisymm _ _
  · rintro - ⟨g, hg, rfl⟩
    exact ⟨g, hg, rfl⟩
    
  · rintro p ⟨g, hg, hp⟩
    exact ⟨⟨g, hP hg⟩, hg, Subtype.ext hp⟩
    
#align subgroup.conj_smul_subgroup_of Subgroup.conj_smul_subgroup_of

end Monoid

section Group

variable [Group α] [MulDistribMulAction α G]

open Pointwise

@[simp]
theorem smul_mem_pointwise_smul_iff {a : α} {S : Subgroup G} {x : G} : a • x ∈ a • S ↔ x ∈ S :=
  smul_mem_smul_set_iff
#align subgroup.smul_mem_pointwise_smul_iff Subgroup.smul_mem_pointwise_smul_iff

theorem mem_pointwise_smul_iff_inv_smul_mem {a : α} {S : Subgroup G} {x : G} : x ∈ a • S ↔ a⁻¹ • x ∈ S :=
  mem_smul_set_iff_inv_smul_mem
#align subgroup.mem_pointwise_smul_iff_inv_smul_mem Subgroup.mem_pointwise_smul_iff_inv_smul_mem

theorem mem_inv_pointwise_smul_iff {a : α} {S : Subgroup G} {x : G} : x ∈ a⁻¹ • S ↔ a • x ∈ S :=
  mem_inv_smul_set_iff
#align subgroup.mem_inv_pointwise_smul_iff Subgroup.mem_inv_pointwise_smul_iff

@[simp]
theorem pointwise_smul_le_pointwise_smul_iff {a : α} {S T : Subgroup G} : a • S ≤ a • T ↔ S ≤ T :=
  set_smul_subset_set_smul_iff
#align subgroup.pointwise_smul_le_pointwise_smul_iff Subgroup.pointwise_smul_le_pointwise_smul_iff

theorem pointwise_smul_subset_iff {a : α} {S T : Subgroup G} : a • S ≤ T ↔ S ≤ a⁻¹ • T :=
  set_smul_subset_iff
#align subgroup.pointwise_smul_subset_iff Subgroup.pointwise_smul_subset_iff

theorem subset_pointwise_smul_iff {a : α} {S T : Subgroup G} : S ≤ a • T ↔ a⁻¹ • S ≤ T :=
  subset_set_smul_iff
#align subgroup.subset_pointwise_smul_iff Subgroup.subset_pointwise_smul_iff

@[simp]
theorem smul_inf (a : α) (S T : Subgroup G) : a • (S ⊓ T) = a • S ⊓ a • T := by
  simp [SetLike.ext_iff, mem_pointwise_smul_iff_inv_smul_mem]
#align subgroup.smul_inf Subgroup.smul_inf

/-- Applying a `mul_distrib_mul_action` results in an isomorphic subgroup -/
@[simps]
def equivSmul (a : α) (H : Subgroup G) : H ≃* (a • H : Subgroup G) :=
  (MulDistribMulAction.toMulEquiv G a).subgroupMap H
#align subgroup.equiv_smul Subgroup.equivSmul

theorem subgroup_mul_singleton {H : Subgroup G} {h : G} (hh : h ∈ H) : (H : Set G) * {h} = H := by
  refine' le_antisymm _ fun h' hh' => ⟨h' * h⁻¹, h, H.mul_mem hh' (H.inv_mem hh), rfl, inv_mul_cancel_right h' h⟩
  rintro _ ⟨h', h, hh', rfl : _ = _, rfl⟩
  exact H.mul_mem hh' hh
#align subgroup.subgroup_mul_singleton Subgroup.subgroup_mul_singleton

theorem singleton_mul_subgroup {H : Subgroup G} {h : G} (hh : h ∈ H) : {h} * (H : Set G) = H := by
  refine' le_antisymm _ fun h' hh' => ⟨h, h⁻¹ * h', rfl, H.mul_mem (H.inv_mem hh) hh', mul_inv_cancel_left h h'⟩
  rintro _ ⟨h, h', rfl : _ = _, hh', rfl⟩
  exact H.mul_mem hh hh'
#align subgroup.singleton_mul_subgroup Subgroup.singleton_mul_subgroup

theorem Normal.conj_act {G : Type _} [Group G] {H : Subgroup G} (hH : H.Normal) (g : ConjAct G) : g • H = H := by
  ext
  constructor
  · intro h
    have := hH.conj_mem (g⁻¹ • x) _ (ConjAct.ofConjAct g)
    rw [Subgroup.mem_pointwise_smul_iff_inv_smul_mem] at h
    dsimp at *
    rw [ConjAct.smul_def] at *
    simp only [ConjAct.of_conj_act_inv, ConjAct.of_conj_act_to_conj_act, inv_inv] at *
    convert this
    simp only [← mul_assoc, mul_right_inv, one_mul, mul_inv_cancel_right]
    rw [Subgroup.mem_pointwise_smul_iff_inv_smul_mem] at h
    exact h
    
  · intro h
    rw [Subgroup.mem_pointwise_smul_iff_inv_smul_mem, ConjAct.smul_def]
    apply hH.conj_mem
    exact h
    
#align subgroup.normal.conj_act Subgroup.Normal.conj_act

@[simp]
theorem smul_normal (g : G) (H : Subgroup G) [h : Normal H] : MulAut.conj g • H = H :=
  h.ConjAct g
#align subgroup.smul_normal Subgroup.smul_normal

end Group

section GroupWithZero

variable [GroupWithZero α] [MulDistribMulAction α G]

open Pointwise

@[simp]
theorem smul_mem_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) (S : Subgroup G) (x : G) : a • x ∈ a • S ↔ x ∈ S :=
  smul_mem_smul_set_iff₀ ha (S : Set G) x
#align subgroup.smul_mem_pointwise_smul_iff₀ Subgroup.smul_mem_pointwise_smul_iff₀

theorem mem_pointwise_smul_iff_inv_smul_mem₀ {a : α} (ha : a ≠ 0) (S : Subgroup G) (x : G) : x ∈ a • S ↔ a⁻¹ • x ∈ S :=
  mem_smul_set_iff_inv_smul_mem₀ ha (S : Set G) x
#align subgroup.mem_pointwise_smul_iff_inv_smul_mem₀ Subgroup.mem_pointwise_smul_iff_inv_smul_mem₀

theorem mem_inv_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) (S : Subgroup G) (x : G) : x ∈ a⁻¹ • S ↔ a • x ∈ S :=
  mem_inv_smul_set_iff₀ ha (S : Set G) x
#align subgroup.mem_inv_pointwise_smul_iff₀ Subgroup.mem_inv_pointwise_smul_iff₀

@[simp]
theorem pointwise_smul_le_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) {S T : Subgroup G} : a • S ≤ a • T ↔ S ≤ T :=
  set_smul_subset_set_smul_iff₀ ha
#align subgroup.pointwise_smul_le_pointwise_smul_iff₀ Subgroup.pointwise_smul_le_pointwise_smul_iff₀

theorem pointwise_smul_le_iff₀ {a : α} (ha : a ≠ 0) {S T : Subgroup G} : a • S ≤ T ↔ S ≤ a⁻¹ • T :=
  set_smul_subset_iff₀ ha
#align subgroup.pointwise_smul_le_iff₀ Subgroup.pointwise_smul_le_iff₀

theorem le_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) {S T : Subgroup G} : S ≤ a • T ↔ a⁻¹ • S ≤ T :=
  subset_set_smul_iff₀ ha
#align subgroup.le_pointwise_smul_iff₀ Subgroup.le_pointwise_smul_iff₀

end GroupWithZero

end Subgroup

namespace AddSubgroup

section Monoid

variable [Monoid α] [DistribMulAction α A]

/-- The action on an additive subgroup corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale. -/
protected def pointwiseMulAction : MulAction α (AddSubgroup A) where
  smul a S := S.map (DistribMulAction.toAddMonoidEnd _ _ a)
  one_smul S := (congr_arg (fun f => S.map f) (MonoidHom.map_one _)).trans S.map_id
  mul_smul a₁ a₂ S := (congr_arg (fun f => S.map f) (MonoidHom.map_mul _ _ _)).trans (S.map_map _ _).symm
#align add_subgroup.pointwise_mul_action AddSubgroup.pointwiseMulAction

localized [Pointwise] attribute [instance] AddSubgroup.pointwiseMulAction

open Pointwise

@[simp]
theorem coe_pointwise_smul (a : α) (S : AddSubgroup A) : ↑(a • S) = a • (S : Set A) :=
  rfl
#align add_subgroup.coe_pointwise_smul AddSubgroup.coe_pointwise_smul

@[simp]
theorem pointwise_smul_to_add_submonoid (a : α) (S : AddSubgroup A) : (a • S).toAddSubmonoid = a • S.toAddSubmonoid :=
  rfl
#align add_subgroup.pointwise_smul_to_add_submonoid AddSubgroup.pointwise_smul_to_add_submonoid

theorem smul_mem_pointwise_smul (m : A) (a : α) (S : AddSubgroup A) : m ∈ S → a • m ∈ a • S :=
  (Set.smul_mem_smul_set : _ → _ ∈ a • (S : Set A))
#align add_subgroup.smul_mem_pointwise_smul AddSubgroup.smul_mem_pointwise_smul

theorem mem_smul_pointwise_iff_exists (m : A) (a : α) (S : AddSubgroup A) : m ∈ a • S ↔ ∃ s : A, s ∈ S ∧ a • s = m :=
  (Set.mem_smul_set : m ∈ a • (S : Set A) ↔ _)
#align add_subgroup.mem_smul_pointwise_iff_exists AddSubgroup.mem_smul_pointwise_iff_exists

instance pointwise_central_scalar [DistribMulAction αᵐᵒᵖ A] [IsCentralScalar α A] : IsCentralScalar α (AddSubgroup A) :=
  ⟨fun a S => (congr_arg fun f => S.map f) <| AddMonoidHom.ext <| op_smul_eq_smul _⟩
#align add_subgroup.pointwise_central_scalar AddSubgroup.pointwise_central_scalar

end Monoid

section Group

variable [Group α] [DistribMulAction α A]

open Pointwise

@[simp]
theorem smul_mem_pointwise_smul_iff {a : α} {S : AddSubgroup A} {x : A} : a • x ∈ a • S ↔ x ∈ S :=
  smul_mem_smul_set_iff
#align add_subgroup.smul_mem_pointwise_smul_iff AddSubgroup.smul_mem_pointwise_smul_iff

theorem mem_pointwise_smul_iff_inv_smul_mem {a : α} {S : AddSubgroup A} {x : A} : x ∈ a • S ↔ a⁻¹ • x ∈ S :=
  mem_smul_set_iff_inv_smul_mem
#align add_subgroup.mem_pointwise_smul_iff_inv_smul_mem AddSubgroup.mem_pointwise_smul_iff_inv_smul_mem

theorem mem_inv_pointwise_smul_iff {a : α} {S : AddSubgroup A} {x : A} : x ∈ a⁻¹ • S ↔ a • x ∈ S :=
  mem_inv_smul_set_iff
#align add_subgroup.mem_inv_pointwise_smul_iff AddSubgroup.mem_inv_pointwise_smul_iff

@[simp]
theorem pointwise_smul_le_pointwise_smul_iff {a : α} {S T : AddSubgroup A} : a • S ≤ a • T ↔ S ≤ T :=
  set_smul_subset_set_smul_iff
#align add_subgroup.pointwise_smul_le_pointwise_smul_iff AddSubgroup.pointwise_smul_le_pointwise_smul_iff

theorem pointwise_smul_le_iff {a : α} {S T : AddSubgroup A} : a • S ≤ T ↔ S ≤ a⁻¹ • T :=
  set_smul_subset_iff
#align add_subgroup.pointwise_smul_le_iff AddSubgroup.pointwise_smul_le_iff

theorem le_pointwise_smul_iff {a : α} {S T : AddSubgroup A} : S ≤ a • T ↔ a⁻¹ • S ≤ T :=
  subset_set_smul_iff
#align add_subgroup.le_pointwise_smul_iff AddSubgroup.le_pointwise_smul_iff

end Group

section GroupWithZero

variable [GroupWithZero α] [DistribMulAction α A]

open Pointwise

@[simp]
theorem smul_mem_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) (S : AddSubgroup A) (x : A) : a • x ∈ a • S ↔ x ∈ S :=
  smul_mem_smul_set_iff₀ ha (S : Set A) x
#align add_subgroup.smul_mem_pointwise_smul_iff₀ AddSubgroup.smul_mem_pointwise_smul_iff₀

theorem mem_pointwise_smul_iff_inv_smul_mem₀ {a : α} (ha : a ≠ 0) (S : AddSubgroup A) (x : A) :
    x ∈ a • S ↔ a⁻¹ • x ∈ S :=
  mem_smul_set_iff_inv_smul_mem₀ ha (S : Set A) x
#align add_subgroup.mem_pointwise_smul_iff_inv_smul_mem₀ AddSubgroup.mem_pointwise_smul_iff_inv_smul_mem₀

theorem mem_inv_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) (S : AddSubgroup A) (x : A) : x ∈ a⁻¹ • S ↔ a • x ∈ S :=
  mem_inv_smul_set_iff₀ ha (S : Set A) x
#align add_subgroup.mem_inv_pointwise_smul_iff₀ AddSubgroup.mem_inv_pointwise_smul_iff₀

@[simp]
theorem pointwise_smul_le_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) {S T : AddSubgroup A} : a • S ≤ a • T ↔ S ≤ T :=
  set_smul_subset_set_smul_iff₀ ha
#align add_subgroup.pointwise_smul_le_pointwise_smul_iff₀ AddSubgroup.pointwise_smul_le_pointwise_smul_iff₀

theorem pointwise_smul_le_iff₀ {a : α} (ha : a ≠ 0) {S T : AddSubgroup A} : a • S ≤ T ↔ S ≤ a⁻¹ • T :=
  set_smul_subset_iff₀ ha
#align add_subgroup.pointwise_smul_le_iff₀ AddSubgroup.pointwise_smul_le_iff₀

theorem le_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) {S T : AddSubgroup A} : S ≤ a • T ↔ a⁻¹ • S ≤ T :=
  subset_set_smul_iff₀ ha
#align add_subgroup.le_pointwise_smul_iff₀ AddSubgroup.le_pointwise_smul_iff₀

end GroupWithZero

end AddSubgroup

