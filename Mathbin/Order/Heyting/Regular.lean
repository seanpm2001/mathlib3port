/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Mathbin.Order.GaloisConnection

/-!
# Heyting regular elements

This file defines Heyting regular elements, elements of an Heyting algebra that are their own double
complement, and proves that they form a boolean algebra.

From a logic standpoint, this means that we can perform classical logic within intuitionistic logic
by simply double-negating all propositions. This is practical for synthetic computability theory.

## Main declarations

* `is_regular`: `a` is Heyting-regular if `aᶜᶜ = a`.
* `regular`: The subtype of Heyting-regular elements.
* `regular.boolean_algebra`: Heyting-regular elements form a boolean algebra.

## References

* [Francis Borceux, *Handbook of Categorical Algebra III*][borceux-vol3]
-/


open Function

variable {α : Type _}

namespace Heyting

section HasCompl

variable [HasCompl α] {a : α}

/-- An element of an Heyting algebra is regular if its double complement is itself. -/
def IsRegular (a : α) : Prop :=
  aᶜᶜ = a
#align heyting.is_regular Heyting.IsRegular

protected theorem IsRegular.eq : IsRegular a → aᶜᶜ = a :=
  id
#align heyting.is_regular.eq Heyting.IsRegular.eq

instance IsRegular.decidablePred [DecidableEq α] : @DecidablePred α IsRegular := fun _ => ‹DecidableEq α› _ _
#align heyting.is_regular.decidable_pred Heyting.IsRegular.decidablePred

end HasCompl

section HeytingAlgebra

variable [HeytingAlgebra α] {a b : α}

theorem is_regular_bot : IsRegular (⊥ : α) := by rw [is_regular, compl_bot, compl_top]
#align heyting.is_regular_bot Heyting.is_regular_bot

theorem is_regular_top : IsRegular (⊤ : α) := by rw [is_regular, compl_top, compl_bot]
#align heyting.is_regular_top Heyting.is_regular_top

theorem IsRegular.inf (ha : IsRegular a) (hb : IsRegular b) : IsRegular (a ⊓ b) := by
  rw [is_regular, compl_compl_inf_distrib, ha.eq, hb.eq]
#align heyting.is_regular.inf Heyting.IsRegular.inf

theorem IsRegular.himp (ha : IsRegular a) (hb : IsRegular b) : IsRegular (a ⇨ b) := by
  rw [is_regular, compl_compl_himp_distrib, ha.eq, hb.eq]
#align heyting.is_regular.himp Heyting.IsRegular.himp

theorem is_regular_compl (a : α) : IsRegular (aᶜ) :=
  compl_compl_compl _
#align heyting.is_regular_compl Heyting.is_regular_compl

protected theorem IsRegular.disjoint_compl_left_iff (ha : IsRegular a) : Disjoint (aᶜ) b ↔ b ≤ a := by
  rw [← le_compl_iff_disjoint_left, ha.eq]
#align heyting.is_regular.disjoint_compl_left_iff Heyting.IsRegular.disjoint_compl_left_iff

protected theorem IsRegular.disjoint_compl_right_iff (hb : IsRegular b) : Disjoint a (bᶜ) ↔ a ≤ b := by
  rw [← le_compl_iff_disjoint_right, hb.eq]
#align heyting.is_regular.disjoint_compl_right_iff Heyting.IsRegular.disjoint_compl_right_iff

-- See note [reducible non-instances]
/-- A Heyting algebra with regular excluded middle is a boolean algebra. -/
@[reducible]
def _root_.boolean_algebra.of_regular (h : ∀ a : α, IsRegular (a ⊔ aᶜ)) : BooleanAlgebra α :=
  have : ∀ a : α, IsCompl a (aᶜ) := fun a =>
    ⟨disjoint_compl_right, codisjoint_iff.2 <| by erw [← (h a).Eq, compl_sup, inf_compl_eq_bot, compl_bot]⟩
  { ‹HeytingAlgebra α›, GeneralizedHeytingAlgebra.toDistribLattice with
    himp_eq := fun a b => eq_of_forall_le_iff fun c => le_himp_iff.trans (this _).le_sup_right_iff_inf_left_le.symm,
    inf_compl_le_bot := fun a => (this _).1.le_bot, top_le_sup_compl := fun a => (this _).2.top_le }
#align heyting._root_.boolean_algebra.of_regular heyting._root_.boolean_algebra.of_regular

variable (α)

/-- The boolean algebra of Heyting regular elements. -/
def Regular : Type _ :=
  { a : α // IsRegular a }
#align heyting.regular Heyting.Regular

variable {α}

namespace Regular

instance : Coe (Regular α) α :=
  coeSubtype

theorem coe_injective : Injective (coe : Regular α → α) :=
  Subtype.coe_injective
#align heyting.regular.coe_injective Heyting.Regular.coe_injective

@[simp]
theorem coe_inj {a b : Regular α} : (a : α) = b ↔ a = b :=
  Subtype.coe_inj
#align heyting.regular.coe_inj Heyting.Regular.coe_inj

instance : HasTop (Regular α) :=
  ⟨⟨⊤, is_regular_top⟩⟩

instance : HasBot (Regular α) :=
  ⟨⟨⊥, is_regular_bot⟩⟩

instance : HasInf (Regular α) :=
  ⟨fun a b => ⟨a ⊓ b, a.2.inf b.2⟩⟩

instance : HasHimp (Regular α) :=
  ⟨fun a b => ⟨a ⇨ b, a.2.himp b.2⟩⟩

instance : HasCompl (Regular α) :=
  ⟨fun a => ⟨aᶜ, is_regular_compl _⟩⟩

@[simp, norm_cast]
theorem coe_top : ((⊤ : Regular α) : α) = ⊤ :=
  rfl
#align heyting.regular.coe_top Heyting.Regular.coe_top

@[simp, norm_cast]
theorem coe_bot : ((⊥ : Regular α) : α) = ⊥ :=
  rfl
#align heyting.regular.coe_bot Heyting.Regular.coe_bot

@[simp, norm_cast]
theorem coe_inf (a b : Regular α) : (↑(a ⊓ b) : α) = a ⊓ b :=
  rfl
#align heyting.regular.coe_inf Heyting.Regular.coe_inf

@[simp, norm_cast]
theorem coe_himp (a b : Regular α) : (↑(a ⇨ b) : α) = a ⇨ b :=
  rfl
#align heyting.regular.coe_himp Heyting.Regular.coe_himp

@[simp, norm_cast]
theorem coe_compl (a : Regular α) : (↑(aᶜ) : α) = aᶜ :=
  rfl
#align heyting.regular.coe_compl Heyting.Regular.coe_compl

instance : Inhabited (Regular α) :=
  ⟨⊥⟩

instance : SemilatticeInf (Regular α) :=
  coe_injective.SemilatticeInf _ coe_inf

instance : BoundedOrder (Regular α) :=
  BoundedOrder.lift coe (fun _ _ => id) coe_top coe_bot

@[simp, norm_cast]
theorem coe_le_coe {a b : Regular α} : (a : α) ≤ b ↔ a ≤ b :=
  Iff.rfl
#align heyting.regular.coe_le_coe Heyting.Regular.coe_le_coe

@[simp, norm_cast]
theorem coe_lt_coe {a b : Regular α} : (a : α) < b ↔ a < b :=
  Iff.rfl
#align heyting.regular.coe_lt_coe Heyting.Regular.coe_lt_coe

/-- **Regularization** of `a`. The smallest regular element greater than `a`. -/
def toRegular : α →o Regular α :=
  ⟨fun a => ⟨aᶜᶜ, is_regular_compl _⟩, fun a b h => coe_le_coe.1 <| compl_le_compl <| compl_le_compl h⟩
#align heyting.regular.to_regular Heyting.Regular.toRegular

@[simp, norm_cast]
theorem coe_to_regular (a : α) : (toRegular a : α) = aᶜᶜ :=
  rfl
#align heyting.regular.coe_to_regular Heyting.Regular.coe_to_regular

@[simp]
theorem to_regular_coe (a : Regular α) : toRegular (a : α) = a :=
  coe_injective a.2
#align heyting.regular.to_regular_coe Heyting.Regular.to_regular_coe

/-- The Galois insertion between `regular.to_regular` and `coe`. -/
def gi : GaloisInsertion toRegular (coe : Regular α → α) where
  choice a ha := ⟨a, ha.antisymm le_compl_compl⟩
  gc a b := coe_le_coe.symm.trans <| ⟨le_compl_compl.trans, fun h => (compl_anti <| compl_anti h).trans_eq b.2⟩
  le_l_u _ := le_compl_compl
  choice_eq a ha := coe_injective <| le_compl_compl.antisymm ha
#align heyting.regular.gi Heyting.Regular.gi

instance : Lattice (Regular α) :=
  gi.liftLattice

@[simp, norm_cast]
theorem coe_sup (a b : Regular α) : (↑(a ⊔ b) : α) = (a ⊔ b)ᶜᶜ :=
  rfl
#align heyting.regular.coe_sup Heyting.Regular.coe_sup

instance : BooleanAlgebra (Regular α) :=
  { Regular.lattice, Regular.boundedOrder, Regular.hasHimp, Regular.hasCompl with
    le_sup_inf := fun a b c =>
      coe_le_coe.1 <| by
        dsimp
        rw [sup_inf_left, compl_compl_inf_distrib],
    inf_compl_le_bot := fun a => coe_le_coe.1 <| disjoint_iff_inf_le.1 disjoint_compl_right,
    top_le_sup_compl := fun a =>
      coe_le_coe.1 <| by
        dsimp
        rw [compl_sup, inf_compl_eq_bot, compl_bot]
        rfl,
    himp_eq := fun a b =>
      coe_injective
        (by
          dsimp
          rw [compl_sup, a.prop.eq]
          refine' eq_of_forall_le_iff fun c => le_himp_iff.trans _
          rw [le_compl_iff_disjoint_right, disjoint_left_comm, b.prop.disjoint_compl_left_iff]) }

@[simp, norm_cast]
theorem coe_sdiff (a b : Regular α) : (↑(a \ b) : α) = a ⊓ bᶜ :=
  rfl
#align heyting.regular.coe_sdiff Heyting.Regular.coe_sdiff

end Regular

end HeytingAlgebra

variable [BooleanAlgebra α]

theorem is_regular_of_boolean : ∀ a : α, IsRegular a :=
  compl_compl
#align heyting.is_regular_of_boolean Heyting.is_regular_of_boolean

/-- A decidable proposition is intuitionistically Heyting-regular. -/
@[nolint decidable_classical]
theorem is_regular_of_decidable (p : Prop) [Decidable p] : IsRegular p :=
  propext <| Decidable.not_not_iff _
#align heyting.is_regular_of_decidable Heyting.is_regular_of_decidable

end Heyting

