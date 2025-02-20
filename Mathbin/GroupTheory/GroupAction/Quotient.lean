/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Thomas Browning

! This file was ported from Lean 3 source module group_theory.group_action.quotient
! leanprover-community/mathlib commit 34ee86e6a59d911a8e4f89b68793ee7577ae79c7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.GroupAction
import Mathbin.Data.Fintype.BigOperators
import Mathbin.Dynamics.PeriodicPts
import Mathbin.GroupTheory.GroupAction.ConjAct
import Mathbin.GroupTheory.Commutator
import Mathbin.GroupTheory.Coset

/-!
# Properties of group actions involving quotient groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves properties of group actions which use the quotient group construction, notably
* the orbit-stabilizer theorem `card_orbit_mul_card_stabilizer_eq_card_group`
* the class formula `card_eq_sum_card_group_div_card_stabilizer'`
* Burnside's lemma `sum_card_fixed_by_eq_card_orbits_mul_card_group`
-/


universe u v w

variable {α : Type u} {β : Type v} {γ : Type w}

open Function

open scoped BigOperators

namespace MulAction

variable [Group α]

section QuotientAction

open Subgroup MulOpposite QuotientGroup

variable (β) [Monoid β] [MulAction β α] (H : Subgroup α)

#print MulAction.QuotientAction /-
/-- A typeclass for when a `mul_action β α` descends to the quotient `α ⧸ H`. -/
class QuotientAction : Prop where
  inv_mul_mem : ∀ (b : β) {a a' : α}, a⁻¹ * a' ∈ H → (b • a)⁻¹ * b • a' ∈ H
#align mul_action.quotient_action MulAction.QuotientAction
-/

#print AddAction.QuotientAction /-
/-- A typeclass for when an `add_action β α` descends to the quotient `α ⧸ H`. -/
class AddAction.QuotientAction {α : Type _} (β : Type _) [AddGroup α] [AddMonoid β] [AddAction β α]
    (H : AddSubgroup α) : Prop where
  inv_mul_mem : ∀ (b : β) {a a' : α}, -a + a' ∈ H → -(b +ᵥ a) + (b +ᵥ a') ∈ H
#align add_action.quotient_action AddAction.QuotientAction
-/

attribute [to_additive AddAction.QuotientAction] MulAction.QuotientAction

#print MulAction.left_quotientAction /-
@[to_additive]
instance left_quotientAction : QuotientAction α H :=
  ⟨fun _ _ _ _ => by rwa [smul_eq_mul, smul_eq_mul, mul_inv_rev, mul_assoc, inv_mul_cancel_left]⟩
#align mul_action.left_quotient_action MulAction.left_quotientAction
#align add_action.left_quotient_action AddAction.left_quotientAction
-/

#print MulAction.right_quotientAction /-
@[to_additive]
instance right_quotientAction : QuotientAction H.normalizer.opposite H :=
  ⟨fun b c _ _ => by
    rwa [smul_def, smul_def, smul_eq_mul_unop, smul_eq_mul_unop, mul_inv_rev, ← mul_assoc,
      mem_normalizer_iff'.mp b.prop, mul_assoc, mul_inv_cancel_left]⟩
#align mul_action.right_quotient_action MulAction.right_quotientAction
#align add_action.right_quotient_action AddAction.right_quotientAction
-/

#print MulAction.right_quotientAction' /-
@[to_additive]
instance right_quotientAction' [hH : H.Normal] : QuotientAction αᵐᵒᵖ H :=
  ⟨fun _ _ _ _ => by
    rwa [smul_eq_mul_unop, smul_eq_mul_unop, mul_inv_rev, mul_assoc, hH.mem_comm_iff, mul_assoc,
      mul_inv_cancel_right]⟩
#align mul_action.right_quotient_action' MulAction.right_quotientAction'
#align add_action.right_quotient_action' AddAction.right_quotientAction'
-/

#print MulAction.quotient /-
@[to_additive]
instance quotient [QuotientAction β H] : MulAction β (α ⧸ H)
    where
  smul b :=
    Quotient.map' ((· • ·) b) fun a a' h =>
      leftRel_apply.mpr <| QuotientAction.inv_mul_mem b <| leftRel_apply.mp h
  one_smul q := Quotient.inductionOn' q fun a => congr_arg Quotient.mk'' (one_smul β a)
  mul_smul b b' q := Quotient.inductionOn' q fun a => congr_arg Quotient.mk'' (mul_smul b b' a)
#align mul_action.quotient MulAction.quotient
#align add_action.quotient AddAction.quotient
-/

variable {β}

#print MulAction.Quotient.smul_mk /-
@[simp, to_additive]
theorem Quotient.smul_mk [QuotientAction β H] (b : β) (a : α) :
    (b • QuotientGroup.mk a : α ⧸ H) = QuotientGroup.mk (b • a) :=
  rfl
#align mul_action.quotient.smul_mk MulAction.Quotient.smul_mk
#align add_action.quotient.vadd_mk AddAction.Quotient.vadd_mk
-/

#print MulAction.Quotient.smul_coe /-
@[simp, to_additive]
theorem Quotient.smul_coe [QuotientAction β H] (b : β) (a : α) : (b • a : α ⧸ H) = ↑(b • a) :=
  rfl
#align mul_action.quotient.smul_coe MulAction.Quotient.smul_coe
#align add_action.quotient.vadd_coe AddAction.Quotient.vadd_coe
-/

#print MulAction.Quotient.mk_smul_out' /-
@[simp, to_additive]
theorem Quotient.mk_smul_out' [QuotientAction β H] (b : β) (q : α ⧸ H) :
    QuotientGroup.mk (b • q.out') = b • q := by rw [← quotient.smul_mk, QuotientGroup.out_eq']
#align mul_action.quotient.mk_smul_out' MulAction.Quotient.mk_smul_out'
#align add_action.quotient.mk_vadd_out' AddAction.Quotient.mk_vadd_out'
-/

#print MulAction.Quotient.coe_smul_out' /-
@[simp, to_additive]
theorem Quotient.coe_smul_out' [QuotientAction β H] (b : β) (q : α ⧸ H) : ↑(b • q.out') = b • q :=
  Quotient.mk_smul_out' H b q
#align mul_action.quotient.coe_smul_out' MulAction.Quotient.coe_smul_out'
#align add_action.quotient.coe_vadd_out' AddAction.Quotient.coe_vadd_out'
-/

#print QuotientGroup.out'_conj_pow_minimalPeriod_mem /-
theorem QuotientGroup.out'_conj_pow_minimalPeriod_mem (a : α) (q : α ⧸ H) :
    q.out'⁻¹ * a ^ Function.minimalPeriod ((· • ·) a) q * q.out' ∈ H := by
  rw [mul_assoc, ← QuotientGroup.eq', QuotientGroup.out_eq', ← smul_eq_mul, quotient.mk_smul_out',
    eq_comm, pow_smul_eq_iff_minimal_period_dvd]
#align quotient_group.out'_conj_pow_minimal_period_mem QuotientGroup.out'_conj_pow_minimalPeriod_mem
-/

end QuotientAction

open QuotientGroup

#print MulActionHom.toQuotient /-
/-- The canonical map to the left cosets. -/
def MulActionHom.toQuotient (H : Subgroup α) : α →[α] α ⧸ H :=
  ⟨coe, Quotient.smul_coe H⟩
#align mul_action_hom.to_quotient MulActionHom.toQuotient
-/

#print MulActionHom.toQuotient_apply /-
@[simp]
theorem MulActionHom.toQuotient_apply (H : Subgroup α) (g : α) : MulActionHom.toQuotient H g = g :=
  rfl
#align mul_action_hom.to_quotient_apply MulActionHom.toQuotient_apply
-/

#print MulAction.mulLeftCosetsCompSubtypeVal /-
@[to_additive]
instance mulLeftCosetsCompSubtypeVal (H I : Subgroup α) : MulAction I (α ⧸ H) :=
  MulAction.compHom (α ⧸ H) (Subgroup.subtype I)
#align mul_action.mul_left_cosets_comp_subtype_val MulAction.mulLeftCosetsCompSubtypeVal
#align add_action.add_left_cosets_comp_subtype_val AddAction.addLeftCosetsCompSubtypeVal
-/

variable (α) {β} [MulAction α β] (x : β)

#print MulAction.ofQuotientStabilizer /-
/-- The canonical map from the quotient of the stabilizer to the set. -/
@[to_additive "The canonical map from the quotient of the stabilizer to the set. "]
def ofQuotientStabilizer (g : α ⧸ MulAction.stabilizer α x) : β :=
  Quotient.liftOn' g (· • x) fun g1 g2 H =>
    calc
      g1 • x = g1 • (g1⁻¹ * g2) • x := congr_arg _ (leftRel_apply.mp H).symm
      _ = g2 • x := by rw [smul_smul, mul_inv_cancel_left]
#align mul_action.of_quotient_stabilizer MulAction.ofQuotientStabilizer
#align add_action.of_quotient_stabilizer AddAction.ofQuotientStabilizer
-/

#print MulAction.ofQuotientStabilizer_mk /-
@[simp, to_additive]
theorem ofQuotientStabilizer_mk (g : α) : ofQuotientStabilizer α x (QuotientGroup.mk g) = g • x :=
  rfl
#align mul_action.of_quotient_stabilizer_mk MulAction.ofQuotientStabilizer_mk
#align add_action.of_quotient_stabilizer_mk AddAction.ofQuotientStabilizer_mk
-/

#print MulAction.ofQuotientStabilizer_mem_orbit /-
@[to_additive]
theorem ofQuotientStabilizer_mem_orbit (g) : ofQuotientStabilizer α x g ∈ orbit α x :=
  Quotient.inductionOn' g fun g => ⟨g, rfl⟩
#align mul_action.of_quotient_stabilizer_mem_orbit MulAction.ofQuotientStabilizer_mem_orbit
#align add_action.of_quotient_stabilizer_mem_orbit AddAction.ofQuotientStabilizer_mem_orbit
-/

#print MulAction.ofQuotientStabilizer_smul /-
@[to_additive]
theorem ofQuotientStabilizer_smul (g : α) (g' : α ⧸ MulAction.stabilizer α x) :
    ofQuotientStabilizer α x (g • g') = g • ofQuotientStabilizer α x g' :=
  Quotient.inductionOn' g' fun _ => mul_smul _ _ _
#align mul_action.of_quotient_stabilizer_smul MulAction.ofQuotientStabilizer_smul
#align add_action.of_quotient_stabilizer_vadd AddAction.ofQuotientStabilizer_vadd
-/

#print MulAction.injective_ofQuotientStabilizer /-
@[to_additive]
theorem injective_ofQuotientStabilizer : Function.Injective (ofQuotientStabilizer α x) :=
  fun y₁ y₂ =>
  Quotient.inductionOn₂' y₁ y₂ fun g₁ g₂ (H : g₁ • x = g₂ • x) =>
    Quotient.sound' <| by rw [left_rel_apply]; show (g₁⁻¹ * g₂) • x = x;
      rw [mul_smul, ← H, inv_smul_smul]
#align mul_action.injective_of_quotient_stabilizer MulAction.injective_ofQuotientStabilizer
#align add_action.injective_of_quotient_stabilizer AddAction.injective_ofQuotientStabilizer
-/

#print MulAction.orbitEquivQuotientStabilizer /-
/-- Orbit-stabilizer theorem. -/
@[to_additive "Orbit-stabilizer theorem."]
noncomputable def orbitEquivQuotientStabilizer (b : β) : orbit α b ≃ α ⧸ stabilizer α b :=
  Equiv.symm <|
    Equiv.ofBijective (fun g => ⟨ofQuotientStabilizer α b g, ofQuotientStabilizer_mem_orbit α b g⟩)
      ⟨fun x y hxy => injective_ofQuotientStabilizer α b (by convert congr_arg Subtype.val hxy),
        fun ⟨b, ⟨g, hgb⟩⟩ => ⟨g, Subtype.eq hgb⟩⟩
#align mul_action.orbit_equiv_quotient_stabilizer MulAction.orbitEquivQuotientStabilizer
#align add_action.orbit_equiv_quotient_stabilizer AddAction.orbitEquivQuotientStabilizer
-/

#print MulAction.orbitProdStabilizerEquivGroup /-
/-- Orbit-stabilizer theorem. -/
@[to_additive "Orbit-stabilizer theorem."]
noncomputable def orbitProdStabilizerEquivGroup (b : β) : orbit α b × stabilizer α b ≃ α :=
  (Equiv.prodCongr (orbitEquivQuotientStabilizer α _) (Equiv.refl _)).trans
    Subgroup.groupEquivQuotientProdSubgroup.symm
#align mul_action.orbit_prod_stabilizer_equiv_group MulAction.orbitProdStabilizerEquivGroup
#align add_action.orbit_sum_stabilizer_equiv_add_group AddAction.orbitSumStabilizerEquivAddGroup
-/

#print MulAction.card_orbit_mul_card_stabilizer_eq_card_group /-
/-- Orbit-stabilizer theorem. -/
@[to_additive "Orbit-stabilizer theorem."]
theorem card_orbit_mul_card_stabilizer_eq_card_group (b : β) [Fintype α] [Fintype <| orbit α b]
    [Fintype <| stabilizer α b] :
    Fintype.card (orbit α b) * Fintype.card (stabilizer α b) = Fintype.card α := by
  rw [← Fintype.card_prod, Fintype.card_congr (orbit_prod_stabilizer_equiv_group α b)]
#align mul_action.card_orbit_mul_card_stabilizer_eq_card_group MulAction.card_orbit_mul_card_stabilizer_eq_card_group
#align add_action.card_orbit_add_card_stabilizer_eq_card_add_group AddAction.card_orbit_add_card_stabilizer_eq_card_addGroup
-/

#print MulAction.orbitEquivQuotientStabilizer_symm_apply /-
@[simp, to_additive]
theorem orbitEquivQuotientStabilizer_symm_apply (b : β) (a : α) :
    ((orbitEquivQuotientStabilizer α b).symm a : β) = a • b :=
  rfl
#align mul_action.orbit_equiv_quotient_stabilizer_symm_apply MulAction.orbitEquivQuotientStabilizer_symm_apply
#align add_action.orbit_equiv_quotient_stabilizer_symm_apply AddAction.orbitEquivQuotientStabilizer_symm_apply
-/

#print MulAction.stabilizer_quotient /-
@[simp, to_additive]
theorem stabilizer_quotient {G} [Group G] (H : Subgroup G) :
    MulAction.stabilizer G ((1 : G) : G ⧸ H) = H := by ext; simp [QuotientGroup.eq]
#align mul_action.stabilizer_quotient MulAction.stabilizer_quotient
#align add_action.stabilizer_quotient AddAction.stabilizer_quotient
-/

variable (β)

local notation "Ω" => Quotient <| orbitRel α β

#print MulAction.selfEquivSigmaOrbitsQuotientStabilizer' /-
/-- **Class formula** : given `G` a group acting on `X` and `φ` a function mapping each orbit of `X`
under this action (that is, each element of the quotient of `X` by the relation `orbit_rel G X`) to
an element in this orbit, this gives a (noncomputable) bijection between `X` and the disjoint union
of `G/Stab(φ(ω))` over all orbits `ω`. In most cases you'll want `φ` to be `quotient.out'`, so we
provide `mul_action.self_equiv_sigma_orbits_quotient_stabilizer` as a special case. -/
@[to_additive
      "**Class formula** : given `G` an additive group acting on `X` and `φ` a function\nmapping each orbit of `X` under this action (that is, each element of the quotient of `X` by the\nrelation `orbit_rel G X`) to an element in this orbit, this gives a (noncomputable) bijection\nbetween `X` and the disjoint union of `G/Stab(φ(ω))` over all orbits `ω`. In most cases you'll want\n`φ` to be `quotient.out'`, so we provide `add_action.self_equiv_sigma_orbits_quotient_stabilizer`\nas a special case. "]
noncomputable def selfEquivSigmaOrbitsQuotientStabilizer' {φ : Ω → β}
    (hφ : LeftInverse Quotient.mk'' φ) : β ≃ Σ ω : Ω, α ⧸ stabilizer α (φ ω) :=
  calc
    β ≃ Σ ω : Ω, orbitRel.Quotient.orbit ω := selfEquivSigmaOrbits' α β
    _ ≃ Σ ω : Ω, α ⧸ stabilizer α (φ ω) :=
      Equiv.sigmaCongrRight fun ω =>
        (Equiv.Set.ofEq <| orbitRel.Quotient.orbit_eq_orbit_out _ hφ).trans <|
          orbitEquivQuotientStabilizer α (φ ω)
#align mul_action.self_equiv_sigma_orbits_quotient_stabilizer' MulAction.selfEquivSigmaOrbitsQuotientStabilizer'
#align add_action.self_equiv_sigma_orbits_quotient_stabilizer' AddAction.selfEquivSigmaOrbitsQuotientStabilizer'
-/

#print MulAction.card_eq_sum_card_group_div_card_stabilizer' /-
/-- **Class formula** for a finite group acting on a finite type. See
`mul_action.card_eq_sum_card_group_div_card_stabilizer` for a specialized version using
`quotient.out'`. -/
@[to_additive
      "**Class formula** for a finite group acting on a finite type. See\n`add_action.card_eq_sum_card_add_group_div_card_stabilizer` for a specialized version using\n`quotient.out'`."]
theorem card_eq_sum_card_group_div_card_stabilizer' [Fintype α] [Fintype β] [Fintype Ω]
    [∀ b : β, Fintype <| stabilizer α b] {φ : Ω → β} (hφ : LeftInverse Quotient.mk'' φ) :
    Fintype.card β = ∑ ω : Ω, Fintype.card α / Fintype.card (stabilizer α (φ ω)) := by
  classical
  have :
    ∀ ω : Ω,
      Fintype.card α / Fintype.card ↥(stabilizer α (φ ω)) = Fintype.card (α ⧸ stabilizer α (φ ω)) :=
    by
    intro ω
    rw [Fintype.card_congr (@Subgroup.groupEquivQuotientProdSubgroup α _ (stabilizer α <| φ ω)),
      Fintype.card_prod, Nat.mul_div_cancel]
    exact fintype.card_pos_iff.mpr (by infer_instance)
  simp_rw [this, ← Fintype.card_sigma,
    Fintype.card_congr (self_equiv_sigma_orbits_quotient_stabilizer' α β hφ)]
#align mul_action.card_eq_sum_card_group_div_card_stabilizer' MulAction.card_eq_sum_card_group_div_card_stabilizer'
#align add_action.card_eq_sum_card_add_group_sub_card_stabilizer' AddAction.card_eq_sum_card_addGroup_sub_card_stabilizer'
-/

#print MulAction.selfEquivSigmaOrbitsQuotientStabilizer /-
/-- **Class formula**. This is a special case of
`mul_action.self_equiv_sigma_orbits_quotient_stabilizer'` with `φ = quotient.out'`. -/
@[to_additive
      "**Class formula**. This is a special case of\n`add_action.self_equiv_sigma_orbits_quotient_stabilizer'` with `φ = quotient.out'`. "]
noncomputable def selfEquivSigmaOrbitsQuotientStabilizer : β ≃ Σ ω : Ω, α ⧸ stabilizer α ω.out' :=
  selfEquivSigmaOrbitsQuotientStabilizer' α β Quotient.out_eq'
#align mul_action.self_equiv_sigma_orbits_quotient_stabilizer MulAction.selfEquivSigmaOrbitsQuotientStabilizer
#align add_action.self_equiv_sigma_orbits_quotient_stabilizer AddAction.selfEquivSigmaOrbitsQuotientStabilizer
-/

#print MulAction.card_eq_sum_card_group_div_card_stabilizer /-
/-- **Class formula** for a finite group acting on a finite type. -/
@[to_additive "**Class formula** for a finite group acting on a finite type."]
theorem card_eq_sum_card_group_div_card_stabilizer [Fintype α] [Fintype β] [Fintype Ω]
    [∀ b : β, Fintype <| stabilizer α b] :
    Fintype.card β = ∑ ω : Ω, Fintype.card α / Fintype.card (stabilizer α ω.out') :=
  card_eq_sum_card_group_div_card_stabilizer' α β Quotient.out_eq'
#align mul_action.card_eq_sum_card_group_div_card_stabilizer MulAction.card_eq_sum_card_group_div_card_stabilizer
#align add_action.card_eq_sum_card_add_group_sub_card_stabilizer AddAction.card_eq_sum_card_addGroup_sub_card_stabilizer
-/

#print MulAction.sigmaFixedByEquivOrbitsProdGroup /-
/-- **Burnside's lemma** : a (noncomputable) bijection between the disjoint union of all
`{x ∈ X | g • x = x}` for `g ∈ G` and the product `G × X/G`, where `G` is a group acting on `X` and
`X/G`denotes the quotient of `X` by the relation `orbit_rel G X`. -/
@[to_additive
      "**Burnside's lemma** : a (noncomputable) bijection between the disjoint union of all\n`{x ∈ X | g • x = x}` for `g ∈ G` and the product `G × X/G`, where `G` is an additive group acting\non `X` and `X/G`denotes the quotient of `X` by the relation `orbit_rel G X`. "]
noncomputable def sigmaFixedByEquivOrbitsProdGroup : (Σ a : α, fixedBy α β a) ≃ Ω × α :=
  calc
    (Σ a : α, fixedBy α β a) ≃ { ab : α × β // ab.1 • ab.2 = ab.2 } :=
      (Equiv.subtypeProdEquivSigmaSubtype _).symm
    _ ≃ { ba : β × α // ba.2 • ba.1 = ba.1 } :=
      ((Equiv.prodComm α β).subtypeEquiv fun ab => Iff.rfl)
    _ ≃ Σ b : β, stabilizer α b :=
      (Equiv.subtypeProdEquivSigmaSubtype fun (b : β) a => a ∈ stabilizer α b)
    _ ≃ Σ ωb : Σ ω : Ω, orbit α ω.out', stabilizer α (ωb.2 : β) :=
      (selfEquivSigmaOrbits α β).sigmaCongrLeft'
    _ ≃ Σ ω : Ω, Σ b : orbit α ω.out', stabilizer α (b : β) :=
      (Equiv.sigmaAssoc fun (ω : Ω) (b : orbit α ω.out') => stabilizer α (b : β))
    _ ≃ Σ ω : Ω, Σ b : orbit α ω.out', stabilizer α ω.out' :=
      (Equiv.sigmaCongrRight fun ω =>
        Equiv.sigmaCongrRight fun ⟨b, hb⟩ => (stabilizerEquivStabilizerOfOrbitRel hb).toEquiv)
    _ ≃ Σ ω : Ω, orbit α ω.out' × stabilizer α ω.out' :=
      (Equiv.sigmaCongrRight fun ω => Equiv.sigmaEquivProd _ _)
    _ ≃ Σ ω : Ω, α := (Equiv.sigmaCongrRight fun ω => orbitProdStabilizerEquivGroup α ω.out')
    _ ≃ Ω × α := Equiv.sigmaEquivProd Ω α
#align mul_action.sigma_fixed_by_equiv_orbits_prod_group MulAction.sigmaFixedByEquivOrbitsProdGroup
#align add_action.sigma_fixed_by_equiv_orbits_sum_add_group AddAction.sigmaFixedByEquivOrbitsSumAddGroup
-/

#print MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group /-
/-- **Burnside's lemma** : given a finite group `G` acting on a set `X`, the average number of
elements fixed by each `g ∈ G` is the number of orbits. -/
@[to_additive
      "**Burnside's lemma** : given a finite additive group `G` acting on a set `X`,\nthe average number of elements fixed by each `g ∈ G` is the number of orbits. "]
theorem sum_card_fixedBy_eq_card_orbits_mul_card_group [Fintype α] [∀ a, Fintype <| fixedBy α β a]
    [Fintype Ω] : ∑ a : α, Fintype.card (fixedBy α β a) = Fintype.card Ω * Fintype.card α := by
  rw [← Fintype.card_prod, ← Fintype.card_sigma,
    Fintype.card_congr (sigma_fixed_by_equiv_orbits_prod_group α β)]
#align mul_action.sum_card_fixed_by_eq_card_orbits_mul_card_group MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group
#align add_action.sum_card_fixed_by_eq_card_orbits_add_card_add_group AddAction.sum_card_fixedBy_eq_card_orbits_add_card_addGroup
-/

#print MulAction.isPretransitive_quotient /-
@[to_additive]
instance isPretransitive_quotient (G) [Group G] (H : Subgroup G) : IsPretransitive G (G ⧸ H)
    where exists_smul_eq := by
    rintro ⟨x⟩ ⟨y⟩
    refine' ⟨y * x⁻¹, quotient_group.eq.mpr _⟩
    simp only [smul_eq_mul, H.one_mem, mul_left_inv, inv_mul_cancel_right]
#align mul_action.is_pretransitive_quotient MulAction.isPretransitive_quotient
#align add_action.is_pretransitive_quotient AddAction.isPretransitive_quotient
-/

end MulAction

namespace Subgroup

variable {G : Type _} [Group G] (H : Subgroup G)

#print Subgroup.normalCore_eq_ker /-
theorem normalCore_eq_ker : H.normalCore = (MulAction.toPermHom G (G ⧸ H)).ker :=
  by
  refine'
    le_antisymm
      (fun g hg =>
        Equiv.Perm.ext fun q =>
          QuotientGroup.induction_on q fun g' =>
            (MulAction.Quotient.smul_mk H g g').trans (quotient_group.eq.mpr _))
      (subgroup.normal_le_normal_core.mpr fun g hg => _)
  · rw [smul_eq_mul, mul_inv_rev, ← inv_inv g', inv_inv]
    exact H.normal_core.inv_mem hg g'⁻¹
  · rw [← H.inv_mem_iff, ← mul_one g⁻¹, ← QuotientGroup.eq, ← mul_one g]
    exact (MulAction.Quotient.smul_mk H g 1).symm.trans (equiv.perm.ext_iff.mp hg (1 : G))
#align subgroup.normal_core_eq_ker Subgroup.normalCore_eq_ker
-/

open QuotientGroup

#print Subgroup.quotientCentralizerEmbedding /-
/-- Cosets of the centralizer of an element embed into the set of commutators. -/
noncomputable def quotientCentralizerEmbedding (g : G) :
    G ⧸ centralizer (zpowers (g : G)) ↪ commutatorSet G :=
  ((MulAction.orbitEquivQuotientStabilizer (ConjAct G) g).trans
            (quotientEquivOfEq (ConjAct.stabilizer_eq_centralizer g))).symm.toEmbedding.trans
    ⟨fun x =>
      ⟨x * g⁻¹,
        let ⟨_, x, rfl⟩ := x
        ⟨x, g, rfl⟩⟩,
      fun x y => Subtype.ext ∘ mul_right_cancel ∘ Subtype.ext_iff.mp⟩
#align subgroup.quotient_centralizer_embedding Subgroup.quotientCentralizerEmbedding
-/

#print Subgroup.quotientCentralizerEmbedding_apply /-
theorem quotientCentralizerEmbedding_apply (g : G) (x : G) :
    quotientCentralizerEmbedding g x = ⟨⁅x, g⁆, x, g, rfl⟩ :=
  rfl
#align subgroup.quotient_centralizer_embedding_apply Subgroup.quotientCentralizerEmbedding_apply
-/

#print Subgroup.quotientCenterEmbedding /-
/-- If `G` is generated by `S`, then the quotient by the center embeds into `S`-indexed sequences
of commutators. -/
noncomputable def quotientCenterEmbedding {S : Set G} (hS : closure S = ⊤) :
    G ⧸ center G ↪ S → commutatorSet G :=
  (quotientEquivOfEq (center_eq_infi' S hS)).toEmbedding.trans
    ((quotientiInfEmbedding _).trans
      (Function.Embedding.piCongrRight fun g => quotientCentralizerEmbedding g))
#align subgroup.quotient_center_embedding Subgroup.quotientCenterEmbedding
-/

#print Subgroup.quotientCenterEmbedding_apply /-
theorem quotientCenterEmbedding_apply {S : Set G} (hS : closure S = ⊤) (g : G) (s : S) :
    quotientCenterEmbedding hS g s = ⟨⁅g, s⁆, g, s, rfl⟩ :=
  rfl
#align subgroup.quotient_center_embedding_apply Subgroup.quotientCenterEmbedding_apply
-/

end Subgroup

