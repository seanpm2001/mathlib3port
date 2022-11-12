/-
Copyright (c) 2022 Thomas Browning. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning
-/
import Mathbin.Algebra.Group.Defs
import Mathbin.Data.Bracket

/-!
# The bracket on a group given by commutator.
-/


/-- The commutator of two elements `g₁` and `g₂`. -/
instance commutatorElement {G : Type _} [Group G] : Bracket G G :=
  ⟨fun g₁ g₂ => g₁ * g₂ * g₁⁻¹ * g₂⁻¹⟩
#align commutator_element commutatorElement

theorem commutator_element_def {G : Type _} [Group G] (g₁ g₂ : G) : ⁅g₁, g₂⁆ = g₁ * g₂ * g₁⁻¹ * g₂⁻¹ :=
  rfl
#align commutator_element_def commutator_element_def

