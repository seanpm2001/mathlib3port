/-
Copyright (c) 2018 Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Johannes Hölzl, Yaël Dillies

! This file was ported from Lean 3 source module analysis.normed.group.basic
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Normed.Group.Seminorm
import Mathbin.Order.LiminfLimsup
import Mathbin.Topology.Algebra.UniformGroup
import Mathbin.Topology.Instances.Rat
import Mathbin.Topology.MetricSpace.Algebra
import Mathbin.Topology.MetricSpace.IsometricSmul
import Mathbin.Topology.Sequences

/-!
# Normed (semi)groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define 10 classes:

* `has_norm`, `has_nnnorm`: auxiliary classes endowing a type `α` with a function `norm : α → ℝ`
  (notation: `‖x‖`) and `nnnorm : α → ℝ≥0` (notation: `‖x‖₊`), respectively;
* `seminormed_..._group`: A seminormed (additive) (commutative) group is an (additive) (commutative)
  group with a norm and a compatible pseudometric space structure:
  `∀ x y, dist x y = ‖x / y‖` or `∀ x y, dist x y = ‖x - y‖`, depending on the group operation.
* `normed_..._group`: A normed (additive) (commutative) group is an (additive) (commutative) group
  with a norm and a compatible metric space structure.

We also prove basic properties of (semi)normed groups and provide some instances.

## Notes

The current convention `dist x y = ‖x - y‖` means that the distance is invariant under right
addition, but actions in mathlib are usually from the left. This means we might want to change it to
`dist x y = ‖-x + y‖`.

The normed group hierarchy would lend itself well to a mixin design (that is, having
`seminormed_group` and `seminormed_add_group` not extend `group` and `add_group`), but we choose not
to for performance concerns.

## Tags

normed group
-/


variable {𝓕 𝕜 α ι κ E F G : Type _}

open Filter Function Metric

open scoped BigOperators ENNReal Filter NNReal uniformity Pointwise Topology

#print Norm /-
/-- Auxiliary class, endowing a type `E` with a function `norm : E → ℝ` with notation `‖x‖`. This
class is designed to be extended in more interesting classes specifying the properties of the norm.
-/
@[notation_class]
class Norm (E : Type _) where
  norm : E → ℝ
#align has_norm Norm
-/

#print NNNorm /-
/-- Auxiliary class, endowing a type `α` with a function `nnnorm : α → ℝ≥0` with notation `‖x‖₊`. -/
@[notation_class]
class NNNorm (E : Type _) where
  nnnorm : E → ℝ≥0
#align has_nnnorm NNNorm
-/

export Norm (norm)

export NNNorm (nnnorm)

notation "‖" e "‖" => norm e

notation "‖" e "‖₊" => nnnorm e

#print SeminormedAddGroup /-
/-- A seminormed group is an additive group endowed with a norm for which `dist x y = ‖x - y‖`
defines a pseudometric space structure. -/
class SeminormedAddGroup (E : Type _) extends Norm E, AddGroup E, PseudoMetricSpace E where
  dist := fun x y => ‖x - y‖
  dist_eq : ∀ x y, dist x y = ‖x - y‖ := by obviously
#align seminormed_add_group SeminormedAddGroup
-/

#print SeminormedGroup /-
/-- A seminormed group is a group endowed with a norm for which `dist x y = ‖x / y‖` defines a
pseudometric space structure. -/
@[to_additive]
class SeminormedGroup (E : Type _) extends Norm E, Group E, PseudoMetricSpace E where
  dist := fun x y => ‖x / y‖
  dist_eq : ∀ x y, dist x y = ‖x / y‖ := by obviously
#align seminormed_group SeminormedGroup
#align seminormed_add_group SeminormedAddGroup
-/

#print NormedAddGroup /-
/-- A normed group is an additive group endowed with a norm for which `dist x y = ‖x - y‖` defines a
metric space structure. -/
class NormedAddGroup (E : Type _) extends Norm E, AddGroup E, MetricSpace E where
  dist := fun x y => ‖x - y‖
  dist_eq : ∀ x y, dist x y = ‖x - y‖ := by obviously
#align normed_add_group NormedAddGroup
-/

#print NormedGroup /-
/-- A normed group is a group endowed with a norm for which `dist x y = ‖x / y‖` defines a metric
space structure. -/
@[to_additive]
class NormedGroup (E : Type _) extends Norm E, Group E, MetricSpace E where
  dist := fun x y => ‖x / y‖
  dist_eq : ∀ x y, dist x y = ‖x / y‖ := by obviously
#align normed_group NormedGroup
#align normed_add_group NormedAddGroup
-/

#print SeminormedAddCommGroup /-
/-- A seminormed group is an additive group endowed with a norm for which `dist x y = ‖x - y‖`
defines a pseudometric space structure. -/
class SeminormedAddCommGroup (E : Type _) extends Norm E, AddCommGroup E, PseudoMetricSpace E where
  dist := fun x y => ‖x - y‖
  dist_eq : ∀ x y, dist x y = ‖x - y‖ := by obviously
#align seminormed_add_comm_group SeminormedAddCommGroup
-/

#print SeminormedCommGroup /-
/-- A seminormed group is a group endowed with a norm for which `dist x y = ‖x / y‖`
defines a pseudometric space structure. -/
@[to_additive]
class SeminormedCommGroup (E : Type _) extends Norm E, CommGroup E, PseudoMetricSpace E where
  dist := fun x y => ‖x / y‖
  dist_eq : ∀ x y, dist x y = ‖x / y‖ := by obviously
#align seminormed_comm_group SeminormedCommGroup
#align seminormed_add_comm_group SeminormedAddCommGroup
-/

#print NormedAddCommGroup /-
/-- A normed group is an additive group endowed with a norm for which `dist x y = ‖x - y‖` defines a
metric space structure. -/
class NormedAddCommGroup (E : Type _) extends Norm E, AddCommGroup E, MetricSpace E where
  dist := fun x y => ‖x - y‖
  dist_eq : ∀ x y, dist x y = ‖x - y‖ := by obviously
#align normed_add_comm_group NormedAddCommGroup
-/

#print NormedCommGroup /-
/-- A normed group is a group endowed with a norm for which `dist x y = ‖x / y‖` defines a metric
space structure. -/
@[to_additive]
class NormedCommGroup (E : Type _) extends Norm E, CommGroup E, MetricSpace E where
  dist := fun x y => ‖x / y‖
  dist_eq : ∀ x y, dist x y = ‖x / y‖ := by obviously
#align normed_comm_group NormedCommGroup
#align normed_add_comm_group NormedAddCommGroup
-/

#print NormedGroup.toSeminormedGroup /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) NormedGroup.toSeminormedGroup [NormedGroup E] : SeminormedGroup E :=
  { ‹NormedGroup E› with }
#align normed_group.to_seminormed_group NormedGroup.toSeminormedGroup
#align normed_add_group.to_seminormed_add_group NormedAddGroup.toSeminormedAddGroup
-/

#print NormedCommGroup.toSeminormedCommGroup /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) NormedCommGroup.toSeminormedCommGroup [NormedCommGroup E] :
    SeminormedCommGroup E :=
  { ‹NormedCommGroup E› with }
#align normed_comm_group.to_seminormed_comm_group NormedCommGroup.toSeminormedCommGroup
#align normed_add_comm_group.to_seminormed_add_comm_group NormedAddCommGroup.toSeminormedAddCommGroup
-/

#print SeminormedCommGroup.toSeminormedGroup /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) SeminormedCommGroup.toSeminormedGroup [SeminormedCommGroup E] :
    SeminormedGroup E :=
  { ‹SeminormedCommGroup E› with }
#align seminormed_comm_group.to_seminormed_group SeminormedCommGroup.toSeminormedGroup
#align seminormed_add_comm_group.to_seminormed_add_group SeminormedAddCommGroup.toSeminormedAddGroup
-/

#print NormedCommGroup.toNormedGroup /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) NormedCommGroup.toNormedGroup [NormedCommGroup E] : NormedGroup E :=
  { ‹NormedCommGroup E› with }
#align normed_comm_group.to_normed_group NormedCommGroup.toNormedGroup
#align normed_add_comm_group.to_normed_add_group NormedAddCommGroup.toNormedAddGroup
-/

#print NormedGroup.ofSeparation /-
-- See note [reducible non-instances]
/-- Construct a `normed_group` from a `seminormed_group` satisfying `∀ x, ‖x‖ = 0 → x = 1`. This
avoids having to go back to the `(pseudo_)metric_space` level when declaring a `normed_group`
instance as a special case of a more general `seminormed_group` instance. -/
@[to_additive
      "Construct a `normed_add_group` from a `seminormed_add_group` satisfying\n`∀ x, ‖x‖ = 0 → x = 0`. This avoids having to go back to the `(pseudo_)metric_space` level when\ndeclaring a `normed_add_group` instance as a special case of a more general `seminormed_add_group`\ninstance.",
  reducible]
def NormedGroup.ofSeparation [SeminormedGroup E] (h : ∀ x : E, ‖x‖ = 0 → x = 1) : NormedGroup E :=
  { ‹SeminormedGroup E› with
    toMetricSpace :=
      {
        eq_of_dist_eq_zero := fun x y hxy =>
          div_eq_one.1 <| h _ <| by rwa [← ‹SeminormedGroup E›.dist_eq] } }
#align normed_group.of_separation NormedGroup.ofSeparation
#align normed_add_group.of_separation NormedAddGroup.ofSeparation
-/

#print NormedCommGroup.ofSeparation /-
-- See note [reducible non-instances]
/-- Construct a `normed_comm_group` from a `seminormed_comm_group` satisfying
`∀ x, ‖x‖ = 0 → x = 1`. This avoids having to go back to the `(pseudo_)metric_space` level when
declaring a `normed_comm_group` instance as a special case of a more general `seminormed_comm_group`
instance. -/
@[to_additive
      "Construct a `normed_add_comm_group` from a `seminormed_add_comm_group` satisfying\n`∀ x, ‖x‖ = 0 → x = 0`. This avoids having to go back to the `(pseudo_)metric_space` level when\ndeclaring a `normed_add_comm_group` instance as a special case of a more general\n`seminormed_add_comm_group` instance.",
  reducible]
def NormedCommGroup.ofSeparation [SeminormedCommGroup E] (h : ∀ x : E, ‖x‖ = 0 → x = 1) :
    NormedCommGroup E :=
  { ‹SeminormedCommGroup E›, NormedGroup.ofSeparation h with }
#align normed_comm_group.of_separation NormedCommGroup.ofSeparation
#align normed_add_comm_group.of_separation NormedAddCommGroup.ofSeparation
-/

#print SeminormedGroup.ofMulDist /-
/-- Construct a seminormed group from a multiplication-invariant distance. -/
@[to_additive "Construct a seminormed group from a translation-invariant distance."]
def SeminormedGroup.ofMulDist [Norm E] [Group E] [PseudoMetricSpace E]
    (h₁ : ∀ x : E, ‖x‖ = dist x 1) (h₂ : ∀ x y z : E, dist x y ≤ dist (x * z) (y * z)) :
    SeminormedGroup E
    where dist_eq x y := by
    rw [h₁]; apply le_antisymm
    · simpa only [div_eq_mul_inv, ← mul_right_inv y] using h₂ _ _ _
    · simpa only [div_mul_cancel', one_mul] using h₂ (x / y) 1 y
#align seminormed_group.of_mul_dist SeminormedGroup.ofMulDist
#align seminormed_add_group.of_add_dist SeminormedAddGroup.ofAddDist
-/

#print SeminormedGroup.ofMulDist' /-
/-- Construct a seminormed group from a multiplication-invariant pseudodistance. -/
@[to_additive "Construct a seminormed group from a translation-invariant pseudodistance."]
def SeminormedGroup.ofMulDist' [Norm E] [Group E] [PseudoMetricSpace E]
    (h₁ : ∀ x : E, ‖x‖ = dist x 1) (h₂ : ∀ x y z : E, dist (x * z) (y * z) ≤ dist x y) :
    SeminormedGroup E
    where dist_eq x y := by
    rw [h₁]; apply le_antisymm
    · simpa only [div_mul_cancel', one_mul] using h₂ (x / y) 1 y
    · simpa only [div_eq_mul_inv, ← mul_right_inv y] using h₂ _ _ _
#align seminormed_group.of_mul_dist' SeminormedGroup.ofMulDist'
#align seminormed_add_group.of_add_dist' SeminormedAddGroup.ofAddDist'
-/

#print SeminormedCommGroup.ofMulDist /-
/-- Construct a seminormed group from a multiplication-invariant pseudodistance. -/
@[to_additive "Construct a seminormed group from a translation-invariant pseudodistance."]
def SeminormedCommGroup.ofMulDist [Norm E] [CommGroup E] [PseudoMetricSpace E]
    (h₁ : ∀ x : E, ‖x‖ = dist x 1) (h₂ : ∀ x y z : E, dist x y ≤ dist (x * z) (y * z)) :
    SeminormedCommGroup E :=
  { SeminormedGroup.ofMulDist h₁ h₂ with }
#align seminormed_comm_group.of_mul_dist SeminormedCommGroup.ofMulDist
#align seminormed_add_comm_group.of_add_dist SeminormedAddCommGroup.ofAddDist
-/

#print SeminormedCommGroup.ofMulDist' /-
/-- Construct a seminormed group from a multiplication-invariant pseudodistance. -/
@[to_additive "Construct a seminormed group from a translation-invariant pseudodistance."]
def SeminormedCommGroup.ofMulDist' [Norm E] [CommGroup E] [PseudoMetricSpace E]
    (h₁ : ∀ x : E, ‖x‖ = dist x 1) (h₂ : ∀ x y z : E, dist (x * z) (y * z) ≤ dist x y) :
    SeminormedCommGroup E :=
  { SeminormedGroup.ofMulDist' h₁ h₂ with }
#align seminormed_comm_group.of_mul_dist' SeminormedCommGroup.ofMulDist'
#align seminormed_add_comm_group.of_add_dist' SeminormedAddCommGroup.ofAddDist'
-/

#print NormedGroup.ofMulDist /-
/-- Construct a normed group from a multiplication-invariant distance. -/
@[to_additive "Construct a normed group from a translation-invariant distance."]
def NormedGroup.ofMulDist [Norm E] [Group E] [MetricSpace E] (h₁ : ∀ x : E, ‖x‖ = dist x 1)
    (h₂ : ∀ x y z : E, dist x y ≤ dist (x * z) (y * z)) : NormedGroup E :=
  { SeminormedGroup.ofMulDist h₁ h₂ with }
#align normed_group.of_mul_dist NormedGroup.ofMulDist
#align normed_add_group.of_add_dist NormedAddGroup.ofAddDist
-/

#print NormedGroup.ofMulDist' /-
/-- Construct a normed group from a multiplication-invariant pseudodistance. -/
@[to_additive "Construct a normed group from a translation-invariant pseudodistance."]
def NormedGroup.ofMulDist' [Norm E] [Group E] [MetricSpace E] (h₁ : ∀ x : E, ‖x‖ = dist x 1)
    (h₂ : ∀ x y z : E, dist (x * z) (y * z) ≤ dist x y) : NormedGroup E :=
  { SeminormedGroup.ofMulDist' h₁ h₂ with }
#align normed_group.of_mul_dist' NormedGroup.ofMulDist'
#align normed_add_group.of_add_dist' NormedAddGroup.ofAddDist'
-/

#print NormedCommGroup.ofMulDist /-
/-- Construct a normed group from a multiplication-invariant pseudodistance. -/
@[to_additive "Construct a normed group from a translation-invariant pseudodistance."]
def NormedCommGroup.ofMulDist [Norm E] [CommGroup E] [MetricSpace E] (h₁ : ∀ x : E, ‖x‖ = dist x 1)
    (h₂ : ∀ x y z : E, dist x y ≤ dist (x * z) (y * z)) : NormedCommGroup E :=
  { NormedGroup.ofMulDist h₁ h₂ with }
#align normed_comm_group.of_mul_dist NormedCommGroup.ofMulDist
#align normed_add_comm_group.of_add_dist NormedAddCommGroup.ofAddDist
-/

#print NormedCommGroup.ofMulDist' /-
/-- Construct a normed group from a multiplication-invariant pseudodistance. -/
@[to_additive "Construct a normed group from a translation-invariant pseudodistance."]
def NormedCommGroup.ofMulDist' [Norm E] [CommGroup E] [MetricSpace E] (h₁ : ∀ x : E, ‖x‖ = dist x 1)
    (h₂ : ∀ x y z : E, dist (x * z) (y * z) ≤ dist x y) : NormedCommGroup E :=
  { NormedGroup.ofMulDist' h₁ h₂ with }
#align normed_comm_group.of_mul_dist' NormedCommGroup.ofMulDist'
#align normed_add_comm_group.of_add_dist' NormedAddCommGroup.ofAddDist'
-/

#print GroupSeminorm.toSeminormedGroup /-
/-- Construct a seminormed group from a seminorm, i.e., registering the pseudodistance and the
pseudometric space structure from the seminorm properties. Note that in most cases this instance
creates bad definitional equalities (e.g., it does not take into account a possibly existing
`uniform_space` instance on `E`). -/
@[to_additive
      "Construct a seminormed group from a seminorm, i.e., registering the pseudodistance*\nand the pseudometric space structure from the seminorm properties. Note that in most cases this\ninstance creates bad definitional equalities (e.g., it does not take into account a possibly\nexisting `uniform_space` instance on `E`)."]
def GroupSeminorm.toSeminormedGroup [Group E] (f : GroupSeminorm E) : SeminormedGroup E
    where
  dist x y := f (x / y)
  norm := f
  dist_eq x y := rfl
  dist_self x := by simp only [div_self', map_one_eq_zero]
  dist_triangle := le_map_div_add_map_div f
  dist_comm := map_div_rev f
#align group_seminorm.to_seminormed_group GroupSeminorm.toSeminormedGroup
#align add_group_seminorm.to_seminormed_add_group AddGroupSeminorm.toSeminormedAddGroup
-/

#print GroupSeminorm.toSeminormedCommGroup /-
/-- Construct a seminormed group from a seminorm, i.e., registering the pseudodistance and the
pseudometric space structure from the seminorm properties. Note that in most cases this instance
creates bad definitional equalities (e.g., it does not take into account a possibly existing
`uniform_space` instance on `E`). -/
@[to_additive
      "Construct a seminormed group from a seminorm, i.e., registering the pseudodistance*\nand the pseudometric space structure from the seminorm properties. Note that in most cases this\ninstance creates bad definitional equalities (e.g., it does not take into account a possibly\nexisting `uniform_space` instance on `E`)."]
def GroupSeminorm.toSeminormedCommGroup [CommGroup E] (f : GroupSeminorm E) :
    SeminormedCommGroup E :=
  { f.toSeminormedGroup with }
#align group_seminorm.to_seminormed_comm_group GroupSeminorm.toSeminormedCommGroup
#align add_group_seminorm.to_seminormed_add_comm_group AddGroupSeminorm.toSeminormedAddCommGroup
-/

#print GroupNorm.toNormedGroup /-
/-- Construct a normed group from a norm, i.e., registering the distance and the metric space
structure from the norm properties. Note that in most cases this instance creates bad definitional
equalities (e.g., it does not take into account a possibly existing `uniform_space` instance on
`E`). -/
@[to_additive
      "Construct a normed group from a norm, i.e., registering the distance and the metric\nspace structure from the norm properties. Note that in most cases this instance creates bad\ndefinitional equalities (e.g., it does not take into account a possibly existing `uniform_space`\ninstance on `E`)."]
def GroupNorm.toNormedGroup [Group E] (f : GroupNorm E) : NormedGroup E :=
  { f.toGroupSeminorm.toSeminormedGroup with
    eq_of_dist_eq_zero := fun x y h => div_eq_one.1 <| eq_one_of_map_eq_zero f h }
#align group_norm.to_normed_group GroupNorm.toNormedGroup
#align add_group_norm.to_normed_add_group AddGroupNorm.toNormedAddGroup
-/

#print GroupNorm.toNormedCommGroup /-
/-- Construct a normed group from a norm, i.e., registering the distance and the metric space
structure from the norm properties. Note that in most cases this instance creates bad definitional
equalities (e.g., it does not take into account a possibly existing `uniform_space` instance on
`E`). -/
@[to_additive
      "Construct a normed group from a norm, i.e., registering the distance and the metric\nspace structure from the norm properties. Note that in most cases this instance creates bad\ndefinitional equalities (e.g., it does not take into account a possibly existing `uniform_space`\ninstance on `E`)."]
def GroupNorm.toNormedCommGroup [CommGroup E] (f : GroupNorm E) : NormedCommGroup E :=
  { f.toNormedGroup with }
#align group_norm.to_normed_comm_group GroupNorm.toNormedCommGroup
#align add_group_norm.to_normed_add_comm_group AddGroupNorm.toNormedAddCommGroup
-/

instance : NormedAddCommGroup PUnit
    where
  norm := Function.const _ 0
  dist_eq _ _ := rfl

#print PUnit.norm_eq_zero /-
@[simp]
theorem PUnit.norm_eq_zero (r : PUnit) : ‖r‖ = 0 :=
  rfl
#align punit.norm_eq_zero PUnit.norm_eq_zero
-/

section SeminormedGroup

variable [SeminormedGroup E] [SeminormedGroup F] [SeminormedGroup G] {s : Set E}
  {a a₁ a₂ b b₁ b₂ : E} {r r₁ r₂ : ℝ}

#print dist_eq_norm_div /-
@[to_additive]
theorem dist_eq_norm_div (a b : E) : dist a b = ‖a / b‖ :=
  SeminormedGroup.dist_eq _ _
#align dist_eq_norm_div dist_eq_norm_div
#align dist_eq_norm_sub dist_eq_norm_sub
-/

#print dist_eq_norm_div' /-
@[to_additive]
theorem dist_eq_norm_div' (a b : E) : dist a b = ‖b / a‖ := by rw [dist_comm, dist_eq_norm_div]
#align dist_eq_norm_div' dist_eq_norm_div'
#align dist_eq_norm_sub' dist_eq_norm_sub'
-/

alias dist_eq_norm_sub ← dist_eq_norm
#align dist_eq_norm dist_eq_norm

alias dist_eq_norm_sub' ← dist_eq_norm'
#align dist_eq_norm' dist_eq_norm'

#print NormedGroup.to_isometricSMul_right /-
@[to_additive]
instance NormedGroup.to_isometricSMul_right : IsometricSMul Eᵐᵒᵖ E :=
  ⟨fun a => Isometry.of_dist_eq fun b c => by simp [dist_eq_norm_div]⟩
#align normed_group.to_has_isometric_smul_right NormedGroup.to_isometricSMul_right
#align normed_add_group.to_has_isometric_vadd_right NormedAddGroup.to_isometricVAdd_right
-/

#print dist_one_right /-
@[simp, to_additive]
theorem dist_one_right (a : E) : dist a 1 = ‖a‖ := by rw [dist_eq_norm_div, div_one]
#align dist_one_right dist_one_right
#align dist_zero_right dist_zero_right
-/

#print dist_one_left /-
@[simp, to_additive]
theorem dist_one_left : dist (1 : E) = norm :=
  funext fun a => by rw [dist_comm, dist_one_right]
#align dist_one_left dist_one_left
#align dist_zero_left dist_zero_left
-/

#print Isometry.norm_map_of_map_one /-
@[to_additive]
theorem Isometry.norm_map_of_map_one {f : E → F} (hi : Isometry f) (h₁ : f 1 = 1) (x : E) :
    ‖f x‖ = ‖x‖ := by rw [← dist_one_right, ← h₁, hi.dist_eq, dist_one_right]
#align isometry.norm_map_of_map_one Isometry.norm_map_of_map_one
#align isometry.norm_map_of_map_zero Isometry.norm_map_of_map_zero
-/

#print tendsto_norm_cocompact_atTop' /-
@[to_additive tendsto_norm_cocompact_atTop]
theorem tendsto_norm_cocompact_atTop' [ProperSpace E] : Tendsto norm (cocompact E) atTop := by
  simpa only [dist_one_right] using tendsto_dist_right_cocompact_atTop (1 : E)
#align tendsto_norm_cocompact_at_top' tendsto_norm_cocompact_atTop'
#align tendsto_norm_cocompact_at_top tendsto_norm_cocompact_atTop
-/

#print norm_div_rev /-
@[to_additive]
theorem norm_div_rev (a b : E) : ‖a / b‖ = ‖b / a‖ := by
  simpa only [dist_eq_norm_div] using dist_comm a b
#align norm_div_rev norm_div_rev
#align norm_sub_rev norm_sub_rev
-/

#print norm_inv' /-
@[simp, to_additive norm_neg]
theorem norm_inv' (a : E) : ‖a⁻¹‖ = ‖a‖ := by simpa using norm_div_rev 1 a
#align norm_inv' norm_inv'
#align norm_neg norm_neg
-/

#print dist_mul_self_right /-
@[simp, to_additive]
theorem dist_mul_self_right (a b : E) : dist b (a * b) = ‖a‖ := by
  rw [← dist_one_left, ← dist_mul_right 1 a b, one_mul]
#align dist_mul_self_right dist_mul_self_right
#align dist_add_self_right dist_add_self_right
-/

#print dist_mul_self_left /-
@[simp, to_additive]
theorem dist_mul_self_left (a b : E) : dist (a * b) b = ‖a‖ := by
  rw [dist_comm, dist_mul_self_right]
#align dist_mul_self_left dist_mul_self_left
#align dist_add_self_left dist_add_self_left
-/

#print dist_div_eq_dist_mul_left /-
@[simp, to_additive]
theorem dist_div_eq_dist_mul_left (a b c : E) : dist (a / b) c = dist a (c * b) := by
  rw [← dist_mul_right _ _ b, div_mul_cancel']
#align dist_div_eq_dist_mul_left dist_div_eq_dist_mul_left
#align dist_sub_eq_dist_add_left dist_sub_eq_dist_add_left
-/

#print dist_div_eq_dist_mul_right /-
@[simp, to_additive]
theorem dist_div_eq_dist_mul_right (a b c : E) : dist a (b / c) = dist (a * c) b := by
  rw [← dist_mul_right _ _ c, div_mul_cancel']
#align dist_div_eq_dist_mul_right dist_div_eq_dist_mul_right
#align dist_sub_eq_dist_add_right dist_sub_eq_dist_add_right
-/

#print Filter.tendsto_inv_cobounded /-
/-- In a (semi)normed group, inversion `x ↦ x⁻¹` tends to infinity at infinity. TODO: use
`bornology.cobounded` instead of `filter.comap has_norm.norm filter.at_top`. -/
@[to_additive
      "In a (semi)normed group, negation `x ↦ -x` tends to infinity at infinity. TODO: use\n`bornology.cobounded` instead of `filter.comap has_norm.norm filter.at_top`."]
theorem Filter.tendsto_inv_cobounded :
    Tendsto (Inv.inv : E → E) (comap norm atTop) (comap norm atTop) := by
  simpa only [norm_inv', tendsto_comap_iff, (· ∘ ·)] using tendsto_comap
#align filter.tendsto_inv_cobounded Filter.tendsto_inv_cobounded
#align filter.tendsto_neg_cobounded Filter.tendsto_neg_cobounded
-/

#print norm_mul_le' /-
/-- **Triangle inequality** for the norm. -/
@[to_additive norm_add_le "**Triangle inequality** for the norm."]
theorem norm_mul_le' (a b : E) : ‖a * b‖ ≤ ‖a‖ + ‖b‖ := by
  simpa [dist_eq_norm_div] using dist_triangle a 1 b⁻¹
#align norm_mul_le' norm_mul_le'
#align norm_add_le norm_add_le
-/

#print norm_mul_le_of_le /-
@[to_additive]
theorem norm_mul_le_of_le (h₁ : ‖a₁‖ ≤ r₁) (h₂ : ‖a₂‖ ≤ r₂) : ‖a₁ * a₂‖ ≤ r₁ + r₂ :=
  (norm_mul_le' a₁ a₂).trans <| add_le_add h₁ h₂
#align norm_mul_le_of_le norm_mul_le_of_le
#align norm_add_le_of_le norm_add_le_of_le
-/

#print norm_mul₃_le /-
@[to_additive norm_add₃_le]
theorem norm_mul₃_le (a b c : E) : ‖a * b * c‖ ≤ ‖a‖ + ‖b‖ + ‖c‖ :=
  norm_mul_le_of_le (norm_mul_le' _ _) le_rfl
#align norm_mul₃_le norm_mul₃_le
#align norm_add₃_le norm_add₃_le
-/

#print norm_nonneg' /-
@[simp, to_additive norm_nonneg]
theorem norm_nonneg' (a : E) : 0 ≤ ‖a‖ := by rw [← dist_one_right]; exact dist_nonneg
#align norm_nonneg' norm_nonneg'
#align norm_nonneg norm_nonneg
-/

section

open Tactic Tactic.Positivity

/-- Extension for the `positivity` tactic: norms are nonnegative. -/
@[positivity]
unsafe def _root_.tactic.positivity_norm : expr → tactic strictness
  | q(‖$(a)‖) =>
    nonnegative <$> mk_app `` norm_nonneg [a] <|> nonnegative <$> mk_app `` norm_nonneg' [a]
  | _ => failed
#align tactic.positivity_norm tactic.positivity_norm

end

#print norm_one' /-
@[simp, to_additive norm_zero]
theorem norm_one' : ‖(1 : E)‖ = 0 := by rw [← dist_one_right, dist_self]
#align norm_one' norm_one'
#align norm_zero norm_zero
-/

#print ne_one_of_norm_ne_zero /-
@[to_additive]
theorem ne_one_of_norm_ne_zero : ‖a‖ ≠ 0 → a ≠ 1 :=
  mt <| by rintro rfl; exact norm_one'
#align ne_one_of_norm_ne_zero ne_one_of_norm_ne_zero
#align ne_zero_of_norm_ne_zero ne_zero_of_norm_ne_zero
-/

#print norm_of_subsingleton' /-
@[nontriviality, to_additive norm_of_subsingleton]
theorem norm_of_subsingleton' [Subsingleton E] (a : E) : ‖a‖ = 0 := by
  rw [Subsingleton.elim a 1, norm_one']
#align norm_of_subsingleton' norm_of_subsingleton'
#align norm_of_subsingleton norm_of_subsingleton
-/

attribute [nontriviality] norm_of_subsingleton

#print zero_lt_one_add_norm_sq' /-
@[to_additive zero_lt_one_add_norm_sq]
theorem zero_lt_one_add_norm_sq' (x : E) : 0 < 1 + ‖x‖ ^ 2 := by positivity
#align zero_lt_one_add_norm_sq' zero_lt_one_add_norm_sq'
#align zero_lt_one_add_norm_sq zero_lt_one_add_norm_sq
-/

#print norm_div_le /-
@[to_additive]
theorem norm_div_le (a b : E) : ‖a / b‖ ≤ ‖a‖ + ‖b‖ := by
  simpa [dist_eq_norm_div] using dist_triangle a 1 b
#align norm_div_le norm_div_le
#align norm_sub_le norm_sub_le
-/

#print norm_div_le_of_le /-
@[to_additive]
theorem norm_div_le_of_le {r₁ r₂ : ℝ} (H₁ : ‖a₁‖ ≤ r₁) (H₂ : ‖a₂‖ ≤ r₂) : ‖a₁ / a₂‖ ≤ r₁ + r₂ :=
  (norm_div_le a₁ a₂).trans <| add_le_add H₁ H₂
#align norm_div_le_of_le norm_div_le_of_le
#align norm_sub_le_of_le norm_sub_le_of_le
-/

#print dist_le_norm_mul_norm /-
@[to_additive]
theorem dist_le_norm_mul_norm (a b : E) : dist a b ≤ ‖a‖ + ‖b‖ := by rw [dist_eq_norm_div];
  apply norm_div_le
#align dist_le_norm_mul_norm dist_le_norm_mul_norm
#align dist_le_norm_add_norm dist_le_norm_add_norm
-/

#print abs_norm_sub_norm_le' /-
@[to_additive abs_norm_sub_norm_le]
theorem abs_norm_sub_norm_le' (a b : E) : |‖a‖ - ‖b‖| ≤ ‖a / b‖ := by
  simpa [dist_eq_norm_div] using abs_dist_sub_le a b 1
#align abs_norm_sub_norm_le' abs_norm_sub_norm_le'
#align abs_norm_sub_norm_le abs_norm_sub_norm_le
-/

#print norm_sub_norm_le' /-
@[to_additive norm_sub_norm_le]
theorem norm_sub_norm_le' (a b : E) : ‖a‖ - ‖b‖ ≤ ‖a / b‖ :=
  (le_abs_self _).trans (abs_norm_sub_norm_le' a b)
#align norm_sub_norm_le' norm_sub_norm_le'
#align norm_sub_norm_le norm_sub_norm_le
-/

#print dist_norm_norm_le' /-
@[to_additive dist_norm_norm_le]
theorem dist_norm_norm_le' (a b : E) : dist ‖a‖ ‖b‖ ≤ ‖a / b‖ :=
  abs_norm_sub_norm_le' a b
#align dist_norm_norm_le' dist_norm_norm_le'
#align dist_norm_norm_le dist_norm_norm_le
-/

#print norm_le_norm_add_norm_div' /-
@[to_additive]
theorem norm_le_norm_add_norm_div' (u v : E) : ‖u‖ ≤ ‖v‖ + ‖u / v‖ := by rw [add_comm];
  refine' (norm_mul_le' _ _).trans_eq' _; rw [div_mul_cancel']
#align norm_le_norm_add_norm_div' norm_le_norm_add_norm_div'
#align norm_le_norm_add_norm_sub' norm_le_norm_add_norm_sub'
-/

#print norm_le_norm_add_norm_div /-
@[to_additive]
theorem norm_le_norm_add_norm_div (u v : E) : ‖v‖ ≤ ‖u‖ + ‖u / v‖ := by rw [norm_div_rev];
  exact norm_le_norm_add_norm_div' v u
#align norm_le_norm_add_norm_div norm_le_norm_add_norm_div
#align norm_le_norm_add_norm_sub norm_le_norm_add_norm_sub
-/

alias norm_le_norm_add_norm_sub' ← norm_le_insert'
#align norm_le_insert' norm_le_insert'

alias norm_le_norm_add_norm_sub ← norm_le_insert
#align norm_le_insert norm_le_insert

#print norm_le_mul_norm_add /-
@[to_additive]
theorem norm_le_mul_norm_add (u v : E) : ‖u‖ ≤ ‖u * v‖ + ‖v‖ :=
  calc
    ‖u‖ = ‖u * v / v‖ := by rw [mul_div_cancel'']
    _ ≤ ‖u * v‖ + ‖v‖ := norm_div_le _ _
#align norm_le_mul_norm_add norm_le_mul_norm_add
#align norm_le_add_norm_add norm_le_add_norm_add
-/

#print ball_eq' /-
@[to_additive ball_eq]
theorem ball_eq' (y : E) (ε : ℝ) : ball y ε = {x | ‖x / y‖ < ε} :=
  Set.ext fun a => by simp [dist_eq_norm_div]
#align ball_eq' ball_eq'
#align ball_eq ball_eq
-/

#print ball_one_eq /-
@[to_additive]
theorem ball_one_eq (r : ℝ) : ball (1 : E) r = {x | ‖x‖ < r} :=
  Set.ext fun a => by simp
#align ball_one_eq ball_one_eq
#align ball_zero_eq ball_zero_eq
-/

#print mem_ball_iff_norm'' /-
@[to_additive mem_ball_iff_norm]
theorem mem_ball_iff_norm'' : b ∈ ball a r ↔ ‖b / a‖ < r := by rw [mem_ball, dist_eq_norm_div]
#align mem_ball_iff_norm'' mem_ball_iff_norm''
#align mem_ball_iff_norm mem_ball_iff_norm
-/

#print mem_ball_iff_norm''' /-
@[to_additive mem_ball_iff_norm']
theorem mem_ball_iff_norm''' : b ∈ ball a r ↔ ‖a / b‖ < r := by rw [mem_ball', dist_eq_norm_div]
#align mem_ball_iff_norm''' mem_ball_iff_norm'''
#align mem_ball_iff_norm' mem_ball_iff_norm'
-/

#print mem_ball_one_iff /-
@[simp, to_additive]
theorem mem_ball_one_iff : a ∈ ball (1 : E) r ↔ ‖a‖ < r := by rw [mem_ball, dist_one_right]
#align mem_ball_one_iff mem_ball_one_iff
#align mem_ball_zero_iff mem_ball_zero_iff
-/

#print mem_closedBall_iff_norm'' /-
@[to_additive mem_closedBall_iff_norm]
theorem mem_closedBall_iff_norm'' : b ∈ closedBall a r ↔ ‖b / a‖ ≤ r := by
  rw [mem_closed_ball, dist_eq_norm_div]
#align mem_closed_ball_iff_norm'' mem_closedBall_iff_norm''
#align mem_closed_ball_iff_norm mem_closedBall_iff_norm
-/

#print mem_closedBall_one_iff /-
@[simp, to_additive]
theorem mem_closedBall_one_iff : a ∈ closedBall (1 : E) r ↔ ‖a‖ ≤ r := by
  rw [mem_closed_ball, dist_one_right]
#align mem_closed_ball_one_iff mem_closedBall_one_iff
#align mem_closed_ball_zero_iff mem_closedBall_zero_iff
-/

#print mem_closedBall_iff_norm''' /-
@[to_additive mem_closedBall_iff_norm']
theorem mem_closedBall_iff_norm''' : b ∈ closedBall a r ↔ ‖a / b‖ ≤ r := by
  rw [mem_closed_ball', dist_eq_norm_div]
#align mem_closed_ball_iff_norm''' mem_closedBall_iff_norm'''
#align mem_closed_ball_iff_norm' mem_closedBall_iff_norm'
-/

#print norm_le_of_mem_closedBall' /-
@[to_additive norm_le_of_mem_closedBall]
theorem norm_le_of_mem_closedBall' (h : b ∈ closedBall a r) : ‖b‖ ≤ ‖a‖ + r :=
  (norm_le_norm_add_norm_div' _ _).trans <| add_le_add_left (by rwa [← dist_eq_norm_div]) _
#align norm_le_of_mem_closed_ball' norm_le_of_mem_closedBall'
#align norm_le_of_mem_closed_ball norm_le_of_mem_closedBall
-/

#print norm_le_norm_add_const_of_dist_le' /-
@[to_additive norm_le_norm_add_const_of_dist_le]
theorem norm_le_norm_add_const_of_dist_le' : dist a b ≤ r → ‖a‖ ≤ ‖b‖ + r :=
  norm_le_of_mem_closedBall'
#align norm_le_norm_add_const_of_dist_le' norm_le_norm_add_const_of_dist_le'
#align norm_le_norm_add_const_of_dist_le norm_le_norm_add_const_of_dist_le
-/

#print norm_lt_of_mem_ball' /-
@[to_additive norm_lt_of_mem_ball]
theorem norm_lt_of_mem_ball' (h : b ∈ ball a r) : ‖b‖ < ‖a‖ + r :=
  (norm_le_norm_add_norm_div' _ _).trans_lt <| add_lt_add_left (by rwa [← dist_eq_norm_div]) _
#align norm_lt_of_mem_ball' norm_lt_of_mem_ball'
#align norm_lt_of_mem_ball norm_lt_of_mem_ball
-/

#print norm_div_sub_norm_div_le_norm_div /-
@[to_additive]
theorem norm_div_sub_norm_div_le_norm_div (u v w : E) : ‖u / w‖ - ‖v / w‖ ≤ ‖u / v‖ := by
  simpa only [div_div_div_cancel_right'] using norm_sub_norm_le' (u / w) (v / w)
#align norm_div_sub_norm_div_le_norm_div norm_div_sub_norm_div_le_norm_div
#align norm_sub_sub_norm_sub_le_norm_sub norm_sub_sub_norm_sub_le_norm_sub
-/

#print bounded_iff_forall_norm_le' /-
@[to_additive bounded_iff_forall_norm_le]
theorem bounded_iff_forall_norm_le' : Bounded s ↔ ∃ C, ∀ x ∈ s, ‖x‖ ≤ C := by
  simpa only [Set.subset_def, mem_closedBall_one_iff] using bounded_iff_subset_ball (1 : E)
#align bounded_iff_forall_norm_le' bounded_iff_forall_norm_le'
#align bounded_iff_forall_norm_le bounded_iff_forall_norm_le
-/

alias bounded_iff_forall_norm_le' ↔ Metric.Bounded.exists_norm_le' _
#align metric.bounded.exists_norm_le' Metric.Bounded.exists_norm_le'

alias bounded_iff_forall_norm_le ↔ Metric.Bounded.exists_norm_le _
#align metric.bounded.exists_norm_le Metric.Bounded.exists_norm_le

attribute [to_additive Metric.Bounded.exists_norm_le] Metric.Bounded.exists_norm_le'

#print Metric.Bounded.exists_pos_norm_le' /-
@[to_additive Metric.Bounded.exists_pos_norm_le]
theorem Metric.Bounded.exists_pos_norm_le' (hs : Metric.Bounded s) : ∃ R > 0, ∀ x ∈ s, ‖x‖ ≤ R :=
  let ⟨R₀, hR₀⟩ := hs.exists_norm_le'
  ⟨max R₀ 1, by positivity, fun x hx => (hR₀ x hx).trans <| le_max_left _ _⟩
#align metric.bounded.exists_pos_norm_le' Metric.Bounded.exists_pos_norm_le'
#align metric.bounded.exists_pos_norm_le Metric.Bounded.exists_pos_norm_le
-/

#print mem_sphere_iff_norm' /-
@[simp, to_additive mem_sphere_iff_norm]
theorem mem_sphere_iff_norm' : b ∈ sphere a r ↔ ‖b / a‖ = r := by simp [dist_eq_norm_div]
#align mem_sphere_iff_norm' mem_sphere_iff_norm'
#align mem_sphere_iff_norm mem_sphere_iff_norm
-/

#print mem_sphere_one_iff_norm /-
@[simp, to_additive]
theorem mem_sphere_one_iff_norm : a ∈ sphere (1 : E) r ↔ ‖a‖ = r := by simp [dist_eq_norm_div]
#align mem_sphere_one_iff_norm mem_sphere_one_iff_norm
#align mem_sphere_zero_iff_norm mem_sphere_zero_iff_norm
-/

#print norm_eq_of_mem_sphere' /-
@[simp, to_additive norm_eq_of_mem_sphere]
theorem norm_eq_of_mem_sphere' (x : sphere (1 : E) r) : ‖(x : E)‖ = r :=
  mem_sphere_one_iff_norm.mp x.2
#align norm_eq_of_mem_sphere' norm_eq_of_mem_sphere'
#align norm_eq_of_mem_sphere norm_eq_of_mem_sphere
-/

#print ne_one_of_mem_sphere /-
@[to_additive]
theorem ne_one_of_mem_sphere (hr : r ≠ 0) (x : sphere (1 : E) r) : (x : E) ≠ 1 :=
  ne_one_of_norm_ne_zero <| by rwa [norm_eq_of_mem_sphere' x]
#align ne_one_of_mem_sphere ne_one_of_mem_sphere
#align ne_zero_of_mem_sphere ne_zero_of_mem_sphere
-/

#print ne_one_of_mem_unit_sphere /-
@[to_additive ne_zero_of_mem_unit_sphere]
theorem ne_one_of_mem_unit_sphere (x : sphere (1 : E) 1) : (x : E) ≠ 1 :=
  ne_one_of_mem_sphere one_ne_zero _
#align ne_one_of_mem_unit_sphere ne_one_of_mem_unit_sphere
#align ne_zero_of_mem_unit_sphere ne_zero_of_mem_unit_sphere
-/

variable (E)

#print normGroupSeminorm /-
/-- The norm of a seminormed group as a group seminorm. -/
@[to_additive "The norm of a seminormed group as an additive group seminorm."]
def normGroupSeminorm : GroupSeminorm E :=
  ⟨norm, norm_one', norm_mul_le', norm_inv'⟩
#align norm_group_seminorm normGroupSeminorm
#align norm_add_group_seminorm normAddGroupSeminorm
-/

#print coe_normGroupSeminorm /-
@[simp, to_additive]
theorem coe_normGroupSeminorm : ⇑(normGroupSeminorm E) = norm :=
  rfl
#align coe_norm_group_seminorm coe_normGroupSeminorm
#align coe_norm_add_group_seminorm coe_normAddGroupSeminorm
-/

variable {E}

#print NormedCommGroup.tendsto_nhds_one /-
@[to_additive]
theorem NormedCommGroup.tendsto_nhds_one {f : α → E} {l : Filter α} :
    Tendsto f l (𝓝 1) ↔ ∀ ε > 0, ∀ᶠ x in l, ‖f x‖ < ε :=
  Metric.tendsto_nhds.trans <| by simp only [dist_one_right]
#align normed_comm_group.tendsto_nhds_one NormedCommGroup.tendsto_nhds_one
#align normed_add_comm_group.tendsto_nhds_zero NormedAddCommGroup.tendsto_nhds_zero
-/

#print NormedCommGroup.tendsto_nhds_nhds /-
@[to_additive]
theorem NormedCommGroup.tendsto_nhds_nhds {f : E → F} {x : E} {y : F} :
    Tendsto f (𝓝 x) (𝓝 y) ↔ ∀ ε > 0, ∃ δ > 0, ∀ x', ‖x' / x‖ < δ → ‖f x' / y‖ < ε := by
  simp_rw [Metric.tendsto_nhds_nhds, dist_eq_norm_div]
#align normed_comm_group.tendsto_nhds_nhds NormedCommGroup.tendsto_nhds_nhds
#align normed_add_comm_group.tendsto_nhds_nhds NormedAddCommGroup.tendsto_nhds_nhds
-/

#print NormedCommGroup.cauchySeq_iff /-
@[to_additive]
theorem NormedCommGroup.cauchySeq_iff [Nonempty α] [SemilatticeSup α] {u : α → E} :
    CauchySeq u ↔ ∀ ε > 0, ∃ N, ∀ m, N ≤ m → ∀ n, N ≤ n → ‖u m / u n‖ < ε := by
  simp [Metric.cauchySeq_iff, dist_eq_norm_div]
#align normed_comm_group.cauchy_seq_iff NormedCommGroup.cauchySeq_iff
#align normed_add_comm_group.cauchy_seq_iff NormedAddCommGroup.cauchySeq_iff
-/

#print NormedCommGroup.nhds_basis_norm_lt /-
@[to_additive]
theorem NormedCommGroup.nhds_basis_norm_lt (x : E) :
    (𝓝 x).HasBasis (fun ε : ℝ => 0 < ε) fun ε => {y | ‖y / x‖ < ε} := by simp_rw [← ball_eq'];
  exact Metric.nhds_basis_ball
#align normed_comm_group.nhds_basis_norm_lt NormedCommGroup.nhds_basis_norm_lt
#align normed_add_comm_group.nhds_basis_norm_lt NormedAddCommGroup.nhds_basis_norm_lt
-/

#print NormedCommGroup.nhds_one_basis_norm_lt /-
@[to_additive]
theorem NormedCommGroup.nhds_one_basis_norm_lt :
    (𝓝 (1 : E)).HasBasis (fun ε : ℝ => 0 < ε) fun ε => {y | ‖y‖ < ε} := by
  convert NormedCommGroup.nhds_basis_norm_lt (1 : E); simp
#align normed_comm_group.nhds_one_basis_norm_lt NormedCommGroup.nhds_one_basis_norm_lt
#align normed_add_comm_group.nhds_zero_basis_norm_lt NormedAddCommGroup.nhds_zero_basis_norm_lt
-/

#print NormedCommGroup.uniformity_basis_dist /-
@[to_additive]
theorem NormedCommGroup.uniformity_basis_dist :
    (𝓤 E).HasBasis (fun ε : ℝ => 0 < ε) fun ε => {p : E × E | ‖p.fst / p.snd‖ < ε} := by
  convert Metric.uniformity_basis_dist; simp [dist_eq_norm_div]
#align normed_comm_group.uniformity_basis_dist NormedCommGroup.uniformity_basis_dist
#align normed_add_comm_group.uniformity_basis_dist NormedAddCommGroup.uniformity_basis_dist
-/

open Finset

#print MonoidHomClass.lipschitz_of_bound /-
/-- A homomorphism `f` of seminormed groups is Lipschitz, if there exists a constant `C` such that
for all `x`, one has `‖f x‖ ≤ C * ‖x‖`. The analogous condition for a linear map of
(semi)normed spaces is in `normed_space.operator_norm`. -/
@[to_additive
      "A homomorphism `f` of seminormed groups is Lipschitz, if there exists a constant `C`\nsuch that for all `x`, one has `‖f x‖ ≤ C * ‖x‖`. The analogous condition for a linear map of\n(semi)normed spaces is in `normed_space.operator_norm`."]
theorem MonoidHomClass.lipschitz_of_bound [MonoidHomClass 𝓕 E F] (f : 𝓕) (C : ℝ)
    (h : ∀ x, ‖f x‖ ≤ C * ‖x‖) : LipschitzWith (Real.toNNReal C) f :=
  LipschitzWith.of_dist_le' fun x y => by simpa only [dist_eq_norm_div, map_div] using h (x / y)
#align monoid_hom_class.lipschitz_of_bound MonoidHomClass.lipschitz_of_bound
#align add_monoid_hom_class.lipschitz_of_bound AddMonoidHomClass.lipschitz_of_bound
-/

#print lipschitzOnWith_iff_norm_div_le /-
@[to_additive]
theorem lipschitzOnWith_iff_norm_div_le {f : E → F} {C : ℝ≥0} :
    LipschitzOnWith C f s ↔ ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → ‖f x / f y‖ ≤ C * ‖x / y‖ := by
  simp only [lipschitzOnWith_iff_dist_le_mul, dist_eq_norm_div]
#align lipschitz_on_with_iff_norm_div_le lipschitzOnWith_iff_norm_div_le
#align lipschitz_on_with_iff_norm_sub_le lipschitzOnWith_iff_norm_sub_le
-/

alias lipschitzOnWith_iff_norm_div_le ↔ LipschitzOnWith.norm_div_le _
#align lipschitz_on_with.norm_div_le LipschitzOnWith.norm_div_le

attribute [to_additive] LipschitzOnWith.norm_div_le

#print LipschitzOnWith.norm_div_le_of_le /-
@[to_additive]
theorem LipschitzOnWith.norm_div_le_of_le {f : E → F} {C : ℝ≥0} (h : LipschitzOnWith C f s)
    (ha : a ∈ s) (hb : b ∈ s) (hr : ‖a / b‖ ≤ r) : ‖f a / f b‖ ≤ C * r :=
  (h.norm_div_le ha hb).trans <| mul_le_mul_of_nonneg_left hr C.2
#align lipschitz_on_with.norm_div_le_of_le LipschitzOnWith.norm_div_le_of_le
#align lipschitz_on_with.norm_sub_le_of_le LipschitzOnWith.norm_sub_le_of_le
-/

#print lipschitzWith_iff_norm_div_le /-
@[to_additive]
theorem lipschitzWith_iff_norm_div_le {f : E → F} {C : ℝ≥0} :
    LipschitzWith C f ↔ ∀ x y, ‖f x / f y‖ ≤ C * ‖x / y‖ := by
  simp only [lipschitzWith_iff_dist_le_mul, dist_eq_norm_div]
#align lipschitz_with_iff_norm_div_le lipschitzWith_iff_norm_div_le
#align lipschitz_with_iff_norm_sub_le lipschitzWith_iff_norm_sub_le
-/

alias lipschitzWith_iff_norm_div_le ↔ LipschitzWith.norm_div_le _
#align lipschitz_with.norm_div_le LipschitzWith.norm_div_le

attribute [to_additive] LipschitzWith.norm_div_le

#print LipschitzWith.norm_div_le_of_le /-
@[to_additive]
theorem LipschitzWith.norm_div_le_of_le {f : E → F} {C : ℝ≥0} (h : LipschitzWith C f)
    (hr : ‖a / b‖ ≤ r) : ‖f a / f b‖ ≤ C * r :=
  (h.norm_div_le _ _).trans <| mul_le_mul_of_nonneg_left hr C.2
#align lipschitz_with.norm_div_le_of_le LipschitzWith.norm_div_le_of_le
#align lipschitz_with.norm_sub_le_of_le LipschitzWith.norm_sub_le_of_le
-/

#print MonoidHomClass.continuous_of_bound /-
/-- A homomorphism `f` of seminormed groups is continuous, if there exists a constant `C` such that
for all `x`, one has `‖f x‖ ≤ C * ‖x‖`. -/
@[to_additive
      "A homomorphism `f` of seminormed groups is continuous, if there exists a constant `C`\nsuch that for all `x`, one has `‖f x‖ ≤ C * ‖x‖`"]
theorem MonoidHomClass.continuous_of_bound [MonoidHomClass 𝓕 E F] (f : 𝓕) (C : ℝ)
    (h : ∀ x, ‖f x‖ ≤ C * ‖x‖) : Continuous f :=
  (MonoidHomClass.lipschitz_of_bound f C h).Continuous
#align monoid_hom_class.continuous_of_bound MonoidHomClass.continuous_of_bound
#align add_monoid_hom_class.continuous_of_bound AddMonoidHomClass.continuous_of_bound
-/

#print MonoidHomClass.uniformContinuous_of_bound /-
@[to_additive]
theorem MonoidHomClass.uniformContinuous_of_bound [MonoidHomClass 𝓕 E F] (f : 𝓕) (C : ℝ)
    (h : ∀ x, ‖f x‖ ≤ C * ‖x‖) : UniformContinuous f :=
  (MonoidHomClass.lipschitz_of_bound f C h).UniformContinuous
#align monoid_hom_class.uniform_continuous_of_bound MonoidHomClass.uniformContinuous_of_bound
#align add_monoid_hom_class.uniform_continuous_of_bound AddMonoidHomClass.uniformContinuous_of_bound
-/

#print IsCompact.exists_bound_of_continuous_on' /-
@[to_additive IsCompact.exists_bound_of_continuousOn]
theorem IsCompact.exists_bound_of_continuous_on' [TopologicalSpace α] {s : Set α} (hs : IsCompact s)
    {f : α → E} (hf : ContinuousOn f s) : ∃ C, ∀ x ∈ s, ‖f x‖ ≤ C :=
  (bounded_iff_forall_norm_le'.1 (hs.image_of_continuousOn hf).Bounded).imp fun C hC x hx =>
    hC _ <| Set.mem_image_of_mem _ hx
#align is_compact.exists_bound_of_continuous_on' IsCompact.exists_bound_of_continuous_on'
#align is_compact.exists_bound_of_continuous_on IsCompact.exists_bound_of_continuousOn
-/

#print MonoidHomClass.isometry_iff_norm /-
@[to_additive]
theorem MonoidHomClass.isometry_iff_norm [MonoidHomClass 𝓕 E F] (f : 𝓕) :
    Isometry f ↔ ∀ x, ‖f x‖ = ‖x‖ :=
  by
  simp only [isometry_iff_dist_eq, dist_eq_norm_div, ← map_div]
  refine' ⟨fun h x => _, fun h x y => h _⟩
  simpa using h x 1
#align monoid_hom_class.isometry_iff_norm MonoidHomClass.isometry_iff_norm
#align add_monoid_hom_class.isometry_iff_norm AddMonoidHomClass.isometry_iff_norm
-/

alias MonoidHomClass.isometry_iff_norm ↔ _ MonoidHomClass.isometry_of_norm
#align monoid_hom_class.isometry_of_norm MonoidHomClass.isometry_of_norm

attribute [to_additive] MonoidHomClass.isometry_of_norm

section Nnnorm

#print SeminormedGroup.toNNNorm /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) SeminormedGroup.toNNNorm : NNNorm E :=
  ⟨fun a => ⟨‖a‖, norm_nonneg' a⟩⟩
#align seminormed_group.to_has_nnnorm SeminormedGroup.toNNNorm
#align seminormed_add_group.to_has_nnnorm SeminormedAddGroup.toNNNorm
-/

#print coe_nnnorm' /-
@[simp, norm_cast, to_additive coe_nnnorm]
theorem coe_nnnorm' (a : E) : (‖a‖₊ : ℝ) = ‖a‖ :=
  rfl
#align coe_nnnorm' coe_nnnorm'
#align coe_nnnorm coe_nnnorm
-/

#print coe_comp_nnnorm' /-
@[simp, to_additive coe_comp_nnnorm]
theorem coe_comp_nnnorm' : (coe : ℝ≥0 → ℝ) ∘ (nnnorm : E → ℝ≥0) = norm :=
  rfl
#align coe_comp_nnnorm' coe_comp_nnnorm'
#align coe_comp_nnnorm coe_comp_nnnorm
-/

#print norm_toNNReal' /-
@[to_additive norm_toNNReal]
theorem norm_toNNReal' : ‖a‖.toNNReal = ‖a‖₊ :=
  @Real.toNNReal_coe ‖a‖₊
#align norm_to_nnreal' norm_toNNReal'
#align norm_to_nnreal norm_toNNReal
-/

#print nndist_eq_nnnorm_div /-
@[to_additive]
theorem nndist_eq_nnnorm_div (a b : E) : nndist a b = ‖a / b‖₊ :=
  NNReal.eq <| dist_eq_norm_div _ _
#align nndist_eq_nnnorm_div nndist_eq_nnnorm_div
#align nndist_eq_nnnorm_sub nndist_eq_nnnorm_sub
-/

alias nndist_eq_nnnorm_sub ← nndist_eq_nnnorm
#align nndist_eq_nnnorm nndist_eq_nnnorm

#print nnnorm_one' /-
@[simp, to_additive nnnorm_zero]
theorem nnnorm_one' : ‖(1 : E)‖₊ = 0 :=
  NNReal.eq norm_one'
#align nnnorm_one' nnnorm_one'
#align nnnorm_zero nnnorm_zero
-/

#print ne_one_of_nnnorm_ne_zero /-
@[to_additive]
theorem ne_one_of_nnnorm_ne_zero {a : E} : ‖a‖₊ ≠ 0 → a ≠ 1 :=
  mt <| by rintro rfl; exact nnnorm_one'
#align ne_one_of_nnnorm_ne_zero ne_one_of_nnnorm_ne_zero
#align ne_zero_of_nnnorm_ne_zero ne_zero_of_nnnorm_ne_zero
-/

#print nnnorm_mul_le' /-
@[to_additive nnnorm_add_le]
theorem nnnorm_mul_le' (a b : E) : ‖a * b‖₊ ≤ ‖a‖₊ + ‖b‖₊ :=
  NNReal.coe_le_coe.1 <| norm_mul_le' a b
#align nnnorm_mul_le' nnnorm_mul_le'
#align nnnorm_add_le nnnorm_add_le
-/

#print nnnorm_inv' /-
@[simp, to_additive nnnorm_neg]
theorem nnnorm_inv' (a : E) : ‖a⁻¹‖₊ = ‖a‖₊ :=
  NNReal.eq <| norm_inv' a
#align nnnorm_inv' nnnorm_inv'
#align nnnorm_neg nnnorm_neg
-/

#print nnnorm_div_le /-
@[to_additive]
theorem nnnorm_div_le (a b : E) : ‖a / b‖₊ ≤ ‖a‖₊ + ‖b‖₊ :=
  NNReal.coe_le_coe.1 <| norm_div_le _ _
#align nnnorm_div_le nnnorm_div_le
#align nnnorm_sub_le nnnorm_sub_le
-/

#print nndist_nnnorm_nnnorm_le' /-
@[to_additive nndist_nnnorm_nnnorm_le]
theorem nndist_nnnorm_nnnorm_le' (a b : E) : nndist ‖a‖₊ ‖b‖₊ ≤ ‖a / b‖₊ :=
  NNReal.coe_le_coe.1 <| dist_norm_norm_le' a b
#align nndist_nnnorm_nnnorm_le' nndist_nnnorm_nnnorm_le'
#align nndist_nnnorm_nnnorm_le nndist_nnnorm_nnnorm_le
-/

#print nnnorm_le_nnnorm_add_nnnorm_div /-
@[to_additive]
theorem nnnorm_le_nnnorm_add_nnnorm_div (a b : E) : ‖b‖₊ ≤ ‖a‖₊ + ‖a / b‖₊ :=
  norm_le_norm_add_norm_div _ _
#align nnnorm_le_nnnorm_add_nnnorm_div nnnorm_le_nnnorm_add_nnnorm_div
#align nnnorm_le_nnnorm_add_nnnorm_sub nnnorm_le_nnnorm_add_nnnorm_sub
-/

#print nnnorm_le_nnnorm_add_nnnorm_div' /-
@[to_additive]
theorem nnnorm_le_nnnorm_add_nnnorm_div' (a b : E) : ‖a‖₊ ≤ ‖b‖₊ + ‖a / b‖₊ :=
  norm_le_norm_add_norm_div' _ _
#align nnnorm_le_nnnorm_add_nnnorm_div' nnnorm_le_nnnorm_add_nnnorm_div'
#align nnnorm_le_nnnorm_add_nnnorm_sub' nnnorm_le_nnnorm_add_nnnorm_sub'
-/

alias nnnorm_le_nnnorm_add_nnnorm_sub' ← nnnorm_le_insert'
#align nnnorm_le_insert' nnnorm_le_insert'

alias nnnorm_le_nnnorm_add_nnnorm_sub ← nnnorm_le_insert
#align nnnorm_le_insert nnnorm_le_insert

#print nnnorm_le_mul_nnnorm_add /-
@[to_additive]
theorem nnnorm_le_mul_nnnorm_add (a b : E) : ‖a‖₊ ≤ ‖a * b‖₊ + ‖b‖₊ :=
  norm_le_mul_norm_add _ _
#align nnnorm_le_mul_nnnorm_add nnnorm_le_mul_nnnorm_add
#align nnnorm_le_add_nnnorm_add nnnorm_le_add_nnnorm_add
-/

#print ofReal_norm_eq_coe_nnnorm' /-
@[to_additive ofReal_norm_eq_coe_nnnorm]
theorem ofReal_norm_eq_coe_nnnorm' (a : E) : ENNReal.ofReal ‖a‖ = ‖a‖₊ :=
  ENNReal.ofReal_eq_coe_nnreal _
#align of_real_norm_eq_coe_nnnorm' ofReal_norm_eq_coe_nnnorm'
#align of_real_norm_eq_coe_nnnorm ofReal_norm_eq_coe_nnnorm
-/

#print edist_eq_coe_nnnorm_div /-
@[to_additive]
theorem edist_eq_coe_nnnorm_div (a b : E) : edist a b = ‖a / b‖₊ := by
  rw [edist_dist, dist_eq_norm_div, ofReal_norm_eq_coe_nnnorm']
#align edist_eq_coe_nnnorm_div edist_eq_coe_nnnorm_div
#align edist_eq_coe_nnnorm_sub edist_eq_coe_nnnorm_sub
-/

#print edist_eq_coe_nnnorm' /-
@[to_additive edist_eq_coe_nnnorm]
theorem edist_eq_coe_nnnorm' (x : E) : edist x 1 = (‖x‖₊ : ℝ≥0∞) := by
  rw [edist_eq_coe_nnnorm_div, div_one]
#align edist_eq_coe_nnnorm' edist_eq_coe_nnnorm'
#align edist_eq_coe_nnnorm edist_eq_coe_nnnorm
-/

#print mem_emetric_ball_one_iff /-
@[to_additive]
theorem mem_emetric_ball_one_iff {r : ℝ≥0∞} : a ∈ EMetric.ball (1 : E) r ↔ ↑‖a‖₊ < r := by
  rw [EMetric.mem_ball, edist_eq_coe_nnnorm']
#align mem_emetric_ball_one_iff mem_emetric_ball_one_iff
#align mem_emetric_ball_zero_iff mem_emetric_ball_zero_iff
-/

#print MonoidHomClass.lipschitz_of_bound_nnnorm /-
@[to_additive]
theorem MonoidHomClass.lipschitz_of_bound_nnnorm [MonoidHomClass 𝓕 E F] (f : 𝓕) (C : ℝ≥0)
    (h : ∀ x, ‖f x‖₊ ≤ C * ‖x‖₊) : LipschitzWith C f :=
  @Real.toNNReal_coe C ▸ MonoidHomClass.lipschitz_of_bound f C h
#align monoid_hom_class.lipschitz_of_bound_nnnorm MonoidHomClass.lipschitz_of_bound_nnnorm
#align add_monoid_hom_class.lipschitz_of_bound_nnnorm AddMonoidHomClass.lipschitz_of_bound_nnnorm
-/

#print MonoidHomClass.antilipschitz_of_bound /-
@[to_additive]
theorem MonoidHomClass.antilipschitz_of_bound [MonoidHomClass 𝓕 E F] (f : 𝓕) {K : ℝ≥0}
    (h : ∀ x, ‖x‖ ≤ K * ‖f x‖) : AntilipschitzWith K f :=
  AntilipschitzWith.of_le_mul_dist fun x y => by
    simpa only [dist_eq_norm_div, map_div] using h (x / y)
#align monoid_hom_class.antilipschitz_of_bound MonoidHomClass.antilipschitz_of_bound
#align add_monoid_hom_class.antilipschitz_of_bound AddMonoidHomClass.antilipschitz_of_bound
-/

#print MonoidHomClass.bound_of_antilipschitz /-
@[to_additive]
theorem MonoidHomClass.bound_of_antilipschitz [MonoidHomClass 𝓕 E F] (f : 𝓕) {K : ℝ≥0}
    (h : AntilipschitzWith K f) (x) : ‖x‖ ≤ K * ‖f x‖ := by
  simpa only [dist_one_right, map_one] using h.le_mul_dist x 1
#align monoid_hom_class.bound_of_antilipschitz MonoidHomClass.bound_of_antilipschitz
#align add_monoid_hom_class.bound_of_antilipschitz AddMonoidHomClass.bound_of_antilipschitz
-/

end Nnnorm

#print tendsto_iff_norm_tendsto_one /-
@[to_additive]
theorem tendsto_iff_norm_tendsto_one {f : α → E} {a : Filter α} {b : E} :
    Tendsto f a (𝓝 b) ↔ Tendsto (fun e => ‖f e / b‖) a (𝓝 0) := by
  convert tendsto_iff_dist_tendsto_zero; simp [dist_eq_norm_div]
#align tendsto_iff_norm_tendsto_one tendsto_iff_norm_tendsto_one
#align tendsto_iff_norm_tendsto_zero tendsto_iff_norm_tendsto_zero
-/

#print tendsto_one_iff_norm_tendsto_one /-
@[to_additive]
theorem tendsto_one_iff_norm_tendsto_one {f : α → E} {a : Filter α} :
    Tendsto f a (𝓝 1) ↔ Tendsto (fun e => ‖f e‖) a (𝓝 0) := by rw [tendsto_iff_norm_tendsto_one];
  simp only [div_one]
#align tendsto_one_iff_norm_tendsto_one tendsto_one_iff_norm_tendsto_one
#align tendsto_zero_iff_norm_tendsto_zero tendsto_zero_iff_norm_tendsto_zero
-/

#print comap_norm_nhds_one /-
@[to_additive]
theorem comap_norm_nhds_one : comap norm (𝓝 0) = 𝓝 (1 : E) := by
  simpa only [dist_one_right] using nhds_comap_dist (1 : E)
#align comap_norm_nhds_one comap_norm_nhds_one
#align comap_norm_nhds_zero comap_norm_nhds_zero
-/

#print squeeze_one_norm' /-
/-- Special case of the sandwich theorem: if the norm of `f` is eventually bounded by a real
function `a` which tends to `0`, then `f` tends to `1`. In this pair of lemmas (`squeeze_one_norm'`
and `squeeze_one_norm`), following a convention of similar lemmas in `topology.metric_space.basic`
and `topology.algebra.order`, the `'` version is phrased using "eventually" and the non-`'` version
is phrased absolutely. -/
@[to_additive
      "Special case of the sandwich theorem: if the norm of `f` is eventually bounded by a\nreal function `a` which tends to `0`, then `f` tends to `1`. In this pair of lemmas\n(`squeeze_zero_norm'` and `squeeze_zero_norm`), following a convention of similar lemmas in\n`topology.metric_space.basic` and `topology.algebra.order`, the `'` version is phrased using\n\"eventually\" and the non-`'` version is phrased absolutely."]
theorem squeeze_one_norm' {f : α → E} {a : α → ℝ} {t₀ : Filter α} (h : ∀ᶠ n in t₀, ‖f n‖ ≤ a n)
    (h' : Tendsto a t₀ (𝓝 0)) : Tendsto f t₀ (𝓝 1) :=
  tendsto_one_iff_norm_tendsto_one.2 <|
    squeeze_zero' (eventually_of_forall fun n => norm_nonneg' _) h h'
#align squeeze_one_norm' squeeze_one_norm'
#align squeeze_zero_norm' squeeze_zero_norm'
-/

#print squeeze_one_norm /-
/-- Special case of the sandwich theorem: if the norm of `f` is bounded by a real function `a` which
tends to `0`, then `f` tends to `1`. -/
@[to_additive
      "Special case of the sandwich theorem: if the norm of `f` is bounded by a real\nfunction `a` which tends to `0`, then `f` tends to `0`."]
theorem squeeze_one_norm {f : α → E} {a : α → ℝ} {t₀ : Filter α} (h : ∀ n, ‖f n‖ ≤ a n) :
    Tendsto a t₀ (𝓝 0) → Tendsto f t₀ (𝓝 1) :=
  squeeze_one_norm' <| eventually_of_forall h
#align squeeze_one_norm squeeze_one_norm
#align squeeze_zero_norm squeeze_zero_norm
-/

#print tendsto_norm_div_self /-
@[to_additive]
theorem tendsto_norm_div_self (x : E) : Tendsto (fun a => ‖a / x‖) (𝓝 x) (𝓝 0) := by
  simpa [dist_eq_norm_div] using
    tendsto_id.dist (tendsto_const_nhds : tendsto (fun a => (x : E)) (𝓝 x) _)
#align tendsto_norm_div_self tendsto_norm_div_self
#align tendsto_norm_sub_self tendsto_norm_sub_self
-/

#print tendsto_norm' /-
@[to_additive tendsto_norm]
theorem tendsto_norm' {x : E} : Tendsto (fun a => ‖a‖) (𝓝 x) (𝓝 ‖x‖) := by
  simpa using tendsto_id.dist (tendsto_const_nhds : tendsto (fun a => (1 : E)) _ _)
#align tendsto_norm' tendsto_norm'
#align tendsto_norm tendsto_norm
-/

#print tendsto_norm_one /-
@[to_additive]
theorem tendsto_norm_one : Tendsto (fun a : E => ‖a‖) (𝓝 1) (𝓝 0) := by
  simpa using tendsto_norm_div_self (1 : E)
#align tendsto_norm_one tendsto_norm_one
#align tendsto_norm_zero tendsto_norm_zero
-/

#print continuous_norm' /-
@[continuity, to_additive continuous_norm]
theorem continuous_norm' : Continuous fun a : E => ‖a‖ := by
  simpa using continuous_id.dist (continuous_const : Continuous fun a => (1 : E))
#align continuous_norm' continuous_norm'
#align continuous_norm continuous_norm
-/

#print continuous_nnnorm' /-
@[continuity, to_additive continuous_nnnorm]
theorem continuous_nnnorm' : Continuous fun a : E => ‖a‖₊ :=
  continuous_norm'.subtype_mk _
#align continuous_nnnorm' continuous_nnnorm'
#align continuous_nnnorm continuous_nnnorm
-/

#print lipschitzWith_one_norm' /-
@[to_additive lipschitzWith_one_norm]
theorem lipschitzWith_one_norm' : LipschitzWith 1 (norm : E → ℝ) := by
  simpa only [dist_one_left] using LipschitzWith.dist_right (1 : E)
#align lipschitz_with_one_norm' lipschitzWith_one_norm'
#align lipschitz_with_one_norm lipschitzWith_one_norm
-/

#print lipschitzWith_one_nnnorm' /-
@[to_additive lipschitzWith_one_nnnorm]
theorem lipschitzWith_one_nnnorm' : LipschitzWith 1 (NNNorm.nnnorm : E → ℝ≥0) :=
  lipschitzWith_one_norm'
#align lipschitz_with_one_nnnorm' lipschitzWith_one_nnnorm'
#align lipschitz_with_one_nnnorm lipschitzWith_one_nnnorm
-/

#print uniformContinuous_norm' /-
@[to_additive uniformContinuous_norm]
theorem uniformContinuous_norm' : UniformContinuous (norm : E → ℝ) :=
  lipschitzWith_one_norm'.UniformContinuous
#align uniform_continuous_norm' uniformContinuous_norm'
#align uniform_continuous_norm uniformContinuous_norm
-/

#print uniformContinuous_nnnorm' /-
@[to_additive uniformContinuous_nnnorm]
theorem uniformContinuous_nnnorm' : UniformContinuous fun a : E => ‖a‖₊ :=
  uniformContinuous_norm'.subtype_mk _
#align uniform_continuous_nnnorm' uniformContinuous_nnnorm'
#align uniform_continuous_nnnorm uniformContinuous_nnnorm
-/

#print mem_closure_one_iff_norm /-
@[to_additive]
theorem mem_closure_one_iff_norm {x : E} : x ∈ closure ({1} : Set E) ↔ ‖x‖ = 0 := by
  rw [← closed_ball_zero', mem_closedBall_one_iff, (norm_nonneg' x).le_iff_eq]
#align mem_closure_one_iff_norm mem_closure_one_iff_norm
#align mem_closure_zero_iff_norm mem_closure_zero_iff_norm
-/

#print closure_one_eq /-
@[to_additive]
theorem closure_one_eq : closure ({1} : Set E) = {x | ‖x‖ = 0} :=
  Set.ext fun x => mem_closure_one_iff_norm
#align closure_one_eq closure_one_eq
#align closure_zero_eq closure_zero_eq
-/

#print Filter.Tendsto.op_one_isBoundedUnder_le' /-
/-- A helper lemma used to prove that the (scalar or usual) product of a function that tends to one
and a bounded function tends to one. This lemma is formulated for any binary operation
`op : E → F → G` with an estimate `‖op x y‖ ≤ A * ‖x‖ * ‖y‖` for some constant A instead of
multiplication so that it can be applied to `(*)`, `flip (*)`, `(•)`, and `flip (•)`. -/
@[to_additive
      "A helper lemma used to prove that the (scalar or usual) product of a function that\ntends to zero and a bounded function tends to zero. This lemma is formulated for any binary\noperation `op : E → F → G` with an estimate `‖op x y‖ ≤ A * ‖x‖ * ‖y‖` for some constant A instead\nof multiplication so that it can be applied to `(*)`, `flip (*)`, `(•)`, and `flip (•)`."]
theorem Filter.Tendsto.op_one_isBoundedUnder_le' {f : α → E} {g : α → F} {l : Filter α}
    (hf : Tendsto f l (𝓝 1)) (hg : IsBoundedUnder (· ≤ ·) l (norm ∘ g)) (op : E → F → G)
    (h_op : ∃ A, ∀ x y, ‖op x y‖ ≤ A * ‖x‖ * ‖y‖) : Tendsto (fun x => op (f x) (g x)) l (𝓝 1) :=
  by
  cases' h_op with A h_op
  rcases hg with ⟨C, hC⟩; rw [eventually_map] at hC 
  rw [NormedCommGroup.tendsto_nhds_one] at hf ⊢
  intro ε ε₀
  rcases exists_pos_mul_lt ε₀ (A * C) with ⟨δ, δ₀, hδ⟩
  filter_upwards [hf δ δ₀, hC] with i hf hg
  refine' (h_op _ _).trans_lt _
  cases' le_total A 0 with hA hA
  ·
    exact
      (mul_nonpos_of_nonpos_of_nonneg (mul_nonpos_of_nonpos_of_nonneg hA <| norm_nonneg' _) <|
            norm_nonneg' _).trans_lt
        ε₀
  calc
    A * ‖f i‖ * ‖g i‖ ≤ A * δ * C :=
      mul_le_mul (mul_le_mul_of_nonneg_left hf.le hA) hg (norm_nonneg' _) (mul_nonneg hA δ₀.le)
    _ = A * C * δ := (mul_right_comm _ _ _)
    _ < ε := hδ
#align filter.tendsto.op_one_is_bounded_under_le' Filter.Tendsto.op_one_isBoundedUnder_le'
#align filter.tendsto.op_zero_is_bounded_under_le' Filter.Tendsto.op_zero_isBoundedUnder_le'
-/

#print Filter.Tendsto.op_one_isBoundedUnder_le /-
/-- A helper lemma used to prove that the (scalar or usual) product of a function that tends to one
and a bounded function tends to one. This lemma is formulated for any binary operation
`op : E → F → G` with an estimate `‖op x y‖ ≤ ‖x‖ * ‖y‖` instead of multiplication so that it
can be applied to `(*)`, `flip (*)`, `(•)`, and `flip (•)`. -/
@[to_additive
      "A helper lemma used to prove that the (scalar or usual) product of a function that\ntends to zero and a bounded function tends to zero. This lemma is formulated for any binary\noperation `op : E → F → G` with an estimate `‖op x y‖ ≤ ‖x‖ * ‖y‖` instead of multiplication so that\nit can be applied to `(*)`, `flip (*)`, `(•)`, and `flip (•)`."]
theorem Filter.Tendsto.op_one_isBoundedUnder_le {f : α → E} {g : α → F} {l : Filter α}
    (hf : Tendsto f l (𝓝 1)) (hg : IsBoundedUnder (· ≤ ·) l (norm ∘ g)) (op : E → F → G)
    (h_op : ∀ x y, ‖op x y‖ ≤ ‖x‖ * ‖y‖) : Tendsto (fun x => op (f x) (g x)) l (𝓝 1) :=
  hf.op_one_isBoundedUnder_le' hg op ⟨1, fun x y => (one_mul ‖x‖).symm ▸ h_op x y⟩
#align filter.tendsto.op_one_is_bounded_under_le Filter.Tendsto.op_one_isBoundedUnder_le
#align filter.tendsto.op_zero_is_bounded_under_le Filter.Tendsto.op_zero_isBoundedUnder_le
-/

section

variable {l : Filter α} {f : α → E}

#print Filter.Tendsto.norm' /-
@[to_additive Filter.Tendsto.norm]
theorem Filter.Tendsto.norm' (h : Tendsto f l (𝓝 a)) : Tendsto (fun x => ‖f x‖) l (𝓝 ‖a‖) :=
  tendsto_norm'.comp h
#align filter.tendsto.norm' Filter.Tendsto.norm'
#align filter.tendsto.norm Filter.Tendsto.norm
-/

#print Filter.Tendsto.nnnorm' /-
@[to_additive Filter.Tendsto.nnnorm]
theorem Filter.Tendsto.nnnorm' (h : Tendsto f l (𝓝 a)) : Tendsto (fun x => ‖f x‖₊) l (𝓝 ‖a‖₊) :=
  Tendsto.comp continuous_nnnorm'.ContinuousAt h
#align filter.tendsto.nnnorm' Filter.Tendsto.nnnorm'
#align filter.tendsto.nnnorm Filter.Tendsto.nnnorm
-/

end

section

variable [TopologicalSpace α] {f : α → E}

#print Continuous.norm' /-
@[to_additive Continuous.norm]
theorem Continuous.norm' : Continuous f → Continuous fun x => ‖f x‖ :=
  continuous_norm'.comp
#align continuous.norm' Continuous.norm'
#align continuous.norm Continuous.norm
-/

#print Continuous.nnnorm' /-
@[to_additive Continuous.nnnorm]
theorem Continuous.nnnorm' : Continuous f → Continuous fun x => ‖f x‖₊ :=
  continuous_nnnorm'.comp
#align continuous.nnnorm' Continuous.nnnorm'
#align continuous.nnnorm Continuous.nnnorm
-/

#print ContinuousAt.norm' /-
@[to_additive ContinuousAt.norm]
theorem ContinuousAt.norm' {a : α} (h : ContinuousAt f a) : ContinuousAt (fun x => ‖f x‖) a :=
  h.norm'
#align continuous_at.norm' ContinuousAt.norm'
#align continuous_at.norm ContinuousAt.norm
-/

#print ContinuousAt.nnnorm' /-
@[to_additive ContinuousAt.nnnorm]
theorem ContinuousAt.nnnorm' {a : α} (h : ContinuousAt f a) : ContinuousAt (fun x => ‖f x‖₊) a :=
  h.nnnorm'
#align continuous_at.nnnorm' ContinuousAt.nnnorm'
#align continuous_at.nnnorm ContinuousAt.nnnorm
-/

#print ContinuousWithinAt.norm' /-
@[to_additive ContinuousWithinAt.norm]
theorem ContinuousWithinAt.norm' {s : Set α} {a : α} (h : ContinuousWithinAt f s a) :
    ContinuousWithinAt (fun x => ‖f x‖) s a :=
  h.norm'
#align continuous_within_at.norm' ContinuousWithinAt.norm'
#align continuous_within_at.norm ContinuousWithinAt.norm
-/

#print ContinuousWithinAt.nnnorm' /-
@[to_additive ContinuousWithinAt.nnnorm]
theorem ContinuousWithinAt.nnnorm' {s : Set α} {a : α} (h : ContinuousWithinAt f s a) :
    ContinuousWithinAt (fun x => ‖f x‖₊) s a :=
  h.nnnorm'
#align continuous_within_at.nnnorm' ContinuousWithinAt.nnnorm'
#align continuous_within_at.nnnorm ContinuousWithinAt.nnnorm
-/

#print ContinuousOn.norm' /-
@[to_additive ContinuousOn.norm]
theorem ContinuousOn.norm' {s : Set α} (h : ContinuousOn f s) : ContinuousOn (fun x => ‖f x‖) s :=
  fun x hx => (h x hx).norm'
#align continuous_on.norm' ContinuousOn.norm'
#align continuous_on.norm ContinuousOn.norm
-/

#print ContinuousOn.nnnorm' /-
@[to_additive ContinuousOn.nnnorm]
theorem ContinuousOn.nnnorm' {s : Set α} (h : ContinuousOn f s) :
    ContinuousOn (fun x => ‖f x‖₊) s := fun x hx => (h x hx).nnnorm'
#align continuous_on.nnnorm' ContinuousOn.nnnorm'
#align continuous_on.nnnorm ContinuousOn.nnnorm
-/

end

#print eventually_ne_of_tendsto_norm_atTop' /-
/-- If `‖y‖ → ∞`, then we can assume `y ≠ x` for any fixed `x`. -/
@[to_additive eventually_ne_of_tendsto_norm_atTop
      "If `‖y‖→∞`, then we can assume `y≠x` for any\nfixed `x`"]
theorem eventually_ne_of_tendsto_norm_atTop' {l : Filter α} {f : α → E}
    (h : Tendsto (fun y => ‖f y‖) l atTop) (x : E) : ∀ᶠ y in l, f y ≠ x :=
  (h.eventually_ne_atTop _).mono fun x => ne_of_apply_ne norm
#align eventually_ne_of_tendsto_norm_at_top' eventually_ne_of_tendsto_norm_atTop'
#align eventually_ne_of_tendsto_norm_at_top eventually_ne_of_tendsto_norm_atTop
-/

#print SeminormedCommGroup.mem_closure_iff /-
@[to_additive]
theorem SeminormedCommGroup.mem_closure_iff : a ∈ closure s ↔ ∀ ε, 0 < ε → ∃ b ∈ s, ‖a / b‖ < ε :=
  by simp [Metric.mem_closure_iff, dist_eq_norm_div]
#align seminormed_comm_group.mem_closure_iff SeminormedCommGroup.mem_closure_iff
#align seminormed_add_comm_group.mem_closure_iff SeminormedAddCommGroup.mem_closure_iff
-/

#print norm_le_zero_iff''' /-
@[to_additive norm_le_zero_iff']
theorem norm_le_zero_iff''' [T0Space E] {a : E} : ‖a‖ ≤ 0 ↔ a = 1 :=
  by
  letI : NormedGroup E :=
    { ‹SeminormedGroup E› with toMetricSpace := MetricSpace.ofT0PseudoMetricSpace E }
  rw [← dist_one_right, dist_le_zero]
#align norm_le_zero_iff''' norm_le_zero_iff'''
#align norm_le_zero_iff' norm_le_zero_iff'
-/

#print norm_eq_zero''' /-
@[to_additive norm_eq_zero']
theorem norm_eq_zero''' [T0Space E] {a : E} : ‖a‖ = 0 ↔ a = 1 :=
  (norm_nonneg' a).le_iff_eq.symm.trans norm_le_zero_iff'''
#align norm_eq_zero''' norm_eq_zero'''
#align norm_eq_zero' norm_eq_zero'
-/

#print norm_pos_iff''' /-
@[to_additive norm_pos_iff']
theorem norm_pos_iff''' [T0Space E] {a : E} : 0 < ‖a‖ ↔ a ≠ 1 := by
  rw [← not_le, norm_le_zero_iff''']
#align norm_pos_iff''' norm_pos_iff'''
#align norm_pos_iff' norm_pos_iff'
-/

#print SeminormedGroup.tendstoUniformlyOn_one /-
@[to_additive]
theorem SeminormedGroup.tendstoUniformlyOn_one {f : ι → κ → G} {s : Set κ} {l : Filter ι} :
    TendstoUniformlyOn f 1 l s ↔ ∀ ε > 0, ∀ᶠ i in l, ∀ x ∈ s, ‖f i x‖ < ε := by
  simp_rw [tendsto_uniformly_on_iff, Pi.one_apply, dist_one_left]
#align seminormed_group.tendsto_uniformly_on_one SeminormedGroup.tendstoUniformlyOn_one
#align seminormed_add_group.tendsto_uniformly_on_zero SeminormedAddGroup.tendstoUniformlyOn_zero
-/

#print SeminormedGroup.uniformCauchySeqOnFilter_iff_tendstoUniformlyOnFilter_one /-
@[to_additive]
theorem SeminormedGroup.uniformCauchySeqOnFilter_iff_tendstoUniformlyOnFilter_one {f : ι → κ → G}
    {l : Filter ι} {l' : Filter κ} :
    UniformCauchySeqOnFilter f l l' ↔
      TendstoUniformlyOnFilter (fun n : ι × ι => fun z => f n.fst z / f n.snd z) 1 (l ×ᶠ l) l' :=
  by
  refine' ⟨fun hf u hu => _, fun hf u hu => _⟩
  · obtain ⟨ε, hε, H⟩ := uniformity_basis_dist.mem_uniformity_iff.mp hu
    refine'
      (hf {p : G × G | dist p.fst p.snd < ε} <| dist_mem_uniformity hε).mono fun x hx =>
        H 1 (f x.fst.fst x.snd / f x.fst.snd x.snd) _
    simpa [dist_eq_norm_div, norm_div_rev] using hx
  · obtain ⟨ε, hε, H⟩ := uniformity_basis_dist.mem_uniformity_iff.mp hu
    refine'
      (hf {p : G × G | dist p.fst p.snd < ε} <| dist_mem_uniformity hε).mono fun x hx =>
        H (f x.fst.fst x.snd) (f x.fst.snd x.snd) _
    simpa [dist_eq_norm_div, norm_div_rev] using hx
#align seminormed_group.uniform_cauchy_seq_on_filter_iff_tendsto_uniformly_on_filter_one SeminormedGroup.uniformCauchySeqOnFilter_iff_tendstoUniformlyOnFilter_one
#align seminormed_add_group.uniform_cauchy_seq_on_filter_iff_tendsto_uniformly_on_filter_zero SeminormedAddGroup.uniformCauchySeqOnFilter_iff_tendstoUniformlyOnFilter_zero
-/

#print SeminormedGroup.uniformCauchySeqOn_iff_tendstoUniformlyOn_one /-
@[to_additive]
theorem SeminormedGroup.uniformCauchySeqOn_iff_tendstoUniformlyOn_one {f : ι → κ → G} {s : Set κ}
    {l : Filter ι} :
    UniformCauchySeqOn f l s ↔
      TendstoUniformlyOn (fun n : ι × ι => fun z => f n.fst z / f n.snd z) 1 (l ×ᶠ l) s :=
  by
  rw [tendstoUniformlyOn_iff_tendstoUniformlyOnFilter,
    uniformCauchySeqOn_iff_uniformCauchySeqOnFilter,
    SeminormedGroup.uniformCauchySeqOnFilter_iff_tendstoUniformlyOnFilter_one]
#align seminormed_group.uniform_cauchy_seq_on_iff_tendsto_uniformly_on_one SeminormedGroup.uniformCauchySeqOn_iff_tendstoUniformlyOn_one
#align seminormed_add_group.uniform_cauchy_seq_on_iff_tendsto_uniformly_on_zero SeminormedAddGroup.uniformCauchySeqOn_iff_tendstoUniformlyOn_zero
-/

end SeminormedGroup

section Induced

variable (E F)

#print SeminormedGroup.induced /-
-- See note [reducible non-instances]
/-- A group homomorphism from a `group` to a `seminormed_group` induces a `seminormed_group`
structure on the domain. -/
@[reducible,
  to_additive
      "A group homomorphism from an `add_group` to a `seminormed_add_group` induces a\n`seminormed_add_group` structure on the domain."]
def SeminormedGroup.induced [Group E] [SeminormedGroup F] [MonoidHomClass 𝓕 E F] (f : 𝓕) :
    SeminormedGroup E :=
  { PseudoMetricSpace.induced f _ with
    norm := fun x => ‖f x‖
    dist_eq := fun x y => by simpa only [map_div, ← dist_eq_norm_div] }
#align seminormed_group.induced SeminormedGroup.induced
#align seminormed_add_group.induced SeminormedAddGroup.induced
-/

#print SeminormedCommGroup.induced /-
-- See note [reducible non-instances]
/-- A group homomorphism from a `comm_group` to a `seminormed_group` induces a
`seminormed_comm_group` structure on the domain. -/
@[reducible,
  to_additive
      "A group homomorphism from an `add_comm_group` to a `seminormed_add_group` induces a\n`seminormed_add_comm_group` structure on the domain."]
def SeminormedCommGroup.induced [CommGroup E] [SeminormedGroup F] [MonoidHomClass 𝓕 E F] (f : 𝓕) :
    SeminormedCommGroup E :=
  { SeminormedGroup.induced E F f with }
#align seminormed_comm_group.induced SeminormedCommGroup.induced
#align seminormed_add_comm_group.induced SeminormedAddCommGroup.induced
-/

#print NormedGroup.induced /-
-- See note [reducible non-instances].
/-- An injective group homomorphism from a `group` to a `normed_group` induces a `normed_group`
structure on the domain. -/
@[reducible,
  to_additive
      "An injective group homomorphism from an `add_group` to a `normed_add_group` induces a\n`normed_add_group` structure on the domain."]
def NormedGroup.induced [Group E] [NormedGroup F] [MonoidHomClass 𝓕 E F] (f : 𝓕) (h : Injective f) :
    NormedGroup E :=
  { SeminormedGroup.induced E F f, MetricSpace.induced f h _ with }
#align normed_group.induced NormedGroup.induced
#align normed_add_group.induced NormedAddGroup.induced
-/

#print NormedCommGroup.induced /-
-- See note [reducible non-instances].
/-- An injective group homomorphism from an `comm_group` to a `normed_group` induces a
`normed_comm_group` structure on the domain. -/
@[reducible,
  to_additive
      "An injective group homomorphism from an `comm_group` to a `normed_comm_group` induces a\n`normed_comm_group` structure on the domain."]
def NormedCommGroup.induced [CommGroup E] [NormedGroup F] [MonoidHomClass 𝓕 E F] (f : 𝓕)
    (h : Injective f) : NormedCommGroup E :=
  { SeminormedGroup.induced E F f, MetricSpace.induced f h _ with }
#align normed_comm_group.induced NormedCommGroup.induced
#align normed_add_comm_group.induced NormedAddCommGroup.induced
-/

end Induced

section SeminormedCommGroup

variable [SeminormedCommGroup E] [SeminormedCommGroup F] {a a₁ a₂ b b₁ b₂ : E} {r r₁ r₂ : ℝ}

#print NormedGroup.to_isometricSMul_left /-
@[to_additive]
instance NormedGroup.to_isometricSMul_left : IsometricSMul E E :=
  ⟨fun a => Isometry.of_dist_eq fun b c => by simp [dist_eq_norm_div]⟩
#align normed_group.to_has_isometric_smul_left NormedGroup.to_isometricSMul_left
#align normed_add_group.to_has_isometric_vadd_left NormedAddGroup.to_isometricVAdd_left
-/

#print dist_inv /-
@[to_additive]
theorem dist_inv (x y : E) : dist x⁻¹ y = dist x y⁻¹ := by
  simp_rw [dist_eq_norm_div, ← norm_inv' (x⁻¹ / y), inv_div, div_inv_eq_mul, mul_comm]
#align dist_inv dist_inv
#align dist_neg dist_neg
-/

#print dist_self_mul_right /-
@[simp, to_additive]
theorem dist_self_mul_right (a b : E) : dist a (a * b) = ‖b‖ := by
  rw [← dist_one_left, ← dist_mul_left a 1 b, mul_one]
#align dist_self_mul_right dist_self_mul_right
#align dist_self_add_right dist_self_add_right
-/

#print dist_self_mul_left /-
@[simp, to_additive]
theorem dist_self_mul_left (a b : E) : dist (a * b) a = ‖b‖ := by
  rw [dist_comm, dist_self_mul_right]
#align dist_self_mul_left dist_self_mul_left
#align dist_self_add_left dist_self_add_left
-/

#print dist_self_div_right /-
@[simp, to_additive]
theorem dist_self_div_right (a b : E) : dist a (a / b) = ‖b‖ := by
  rw [div_eq_mul_inv, dist_self_mul_right, norm_inv']
#align dist_self_div_right dist_self_div_right
#align dist_self_sub_right dist_self_sub_right
-/

#print dist_self_div_left /-
@[simp, to_additive]
theorem dist_self_div_left (a b : E) : dist (a / b) a = ‖b‖ := by
  rw [dist_comm, dist_self_div_right]
#align dist_self_div_left dist_self_div_left
#align dist_self_sub_left dist_self_sub_left
-/

#print dist_mul_mul_le /-
@[to_additive]
theorem dist_mul_mul_le (a₁ a₂ b₁ b₂ : E) : dist (a₁ * a₂) (b₁ * b₂) ≤ dist a₁ b₁ + dist a₂ b₂ := by
  simpa only [dist_mul_left, dist_mul_right] using dist_triangle (a₁ * a₂) (b₁ * a₂) (b₁ * b₂)
#align dist_mul_mul_le dist_mul_mul_le
#align dist_add_add_le dist_add_add_le
-/

#print dist_mul_mul_le_of_le /-
@[to_additive]
theorem dist_mul_mul_le_of_le (h₁ : dist a₁ b₁ ≤ r₁) (h₂ : dist a₂ b₂ ≤ r₂) :
    dist (a₁ * a₂) (b₁ * b₂) ≤ r₁ + r₂ :=
  (dist_mul_mul_le a₁ a₂ b₁ b₂).trans <| add_le_add h₁ h₂
#align dist_mul_mul_le_of_le dist_mul_mul_le_of_le
#align dist_add_add_le_of_le dist_add_add_le_of_le
-/

#print dist_div_div_le /-
@[to_additive]
theorem dist_div_div_le (a₁ a₂ b₁ b₂ : E) : dist (a₁ / a₂) (b₁ / b₂) ≤ dist a₁ b₁ + dist a₂ b₂ := by
  simpa only [div_eq_mul_inv, dist_inv_inv] using dist_mul_mul_le a₁ a₂⁻¹ b₁ b₂⁻¹
#align dist_div_div_le dist_div_div_le
#align dist_sub_sub_le dist_sub_sub_le
-/

#print dist_div_div_le_of_le /-
@[to_additive]
theorem dist_div_div_le_of_le (h₁ : dist a₁ b₁ ≤ r₁) (h₂ : dist a₂ b₂ ≤ r₂) :
    dist (a₁ / a₂) (b₁ / b₂) ≤ r₁ + r₂ :=
  (dist_div_div_le a₁ a₂ b₁ b₂).trans <| add_le_add h₁ h₂
#align dist_div_div_le_of_le dist_div_div_le_of_le
#align dist_sub_sub_le_of_le dist_sub_sub_le_of_le
-/

#print abs_dist_sub_le_dist_mul_mul /-
@[to_additive]
theorem abs_dist_sub_le_dist_mul_mul (a₁ a₂ b₁ b₂ : E) :
    |dist a₁ b₁ - dist a₂ b₂| ≤ dist (a₁ * a₂) (b₁ * b₂) := by
  simpa only [dist_mul_left, dist_mul_right, dist_comm b₂] using
    abs_dist_sub_le (a₁ * a₂) (b₁ * b₂) (b₁ * a₂)
#align abs_dist_sub_le_dist_mul_mul abs_dist_sub_le_dist_mul_mul
#align abs_dist_sub_le_dist_add_add abs_dist_sub_le_dist_add_add
-/

#print norm_multiset_sum_le /-
theorem norm_multiset_sum_le {E} [SeminormedAddCommGroup E] (m : Multiset E) :
    ‖m.Sum‖ ≤ (m.map fun x => ‖x‖).Sum :=
  m.le_sum_of_subadditive norm norm_zero norm_add_le
#align norm_multiset_sum_le norm_multiset_sum_le
-/

#print norm_multiset_prod_le /-
@[to_additive]
theorem norm_multiset_prod_le (m : Multiset E) : ‖m.Prod‖ ≤ (m.map fun x => ‖x‖).Sum :=
  by
  rw [← Multiplicative.ofAdd_le, ofAdd_multiset_prod, Multiset.map_map]
  refine' Multiset.le_prod_of_submultiplicative (Multiplicative.ofAdd ∘ norm) _ (fun x y => _) _
  · simp only [comp_app, norm_one', ofAdd_zero]
  · exact norm_mul_le' _ _
#align norm_multiset_prod_le norm_multiset_prod_le
#align norm_multiset_sum_le norm_multiset_sum_le
-/

#print norm_sum_le /-
theorem norm_sum_le {E} [SeminormedAddCommGroup E] (s : Finset ι) (f : ι → E) :
    ‖∑ i in s, f i‖ ≤ ∑ i in s, ‖f i‖ :=
  s.le_sum_of_subadditive norm norm_zero norm_add_le f
#align norm_sum_le norm_sum_le
-/

#print norm_prod_le /-
@[to_additive]
theorem norm_prod_le (s : Finset ι) (f : ι → E) : ‖∏ i in s, f i‖ ≤ ∑ i in s, ‖f i‖ :=
  by
  rw [← Multiplicative.ofAdd_le, ofAdd_sum]
  refine' Finset.le_prod_of_submultiplicative (Multiplicative.ofAdd ∘ norm) _ (fun x y => _) _ _
  · simp only [comp_app, norm_one', ofAdd_zero]
  · exact norm_mul_le' _ _
#align norm_prod_le norm_prod_le
#align norm_sum_le norm_sum_le
-/

#print norm_prod_le_of_le /-
@[to_additive]
theorem norm_prod_le_of_le (s : Finset ι) {f : ι → E} {n : ι → ℝ} (h : ∀ b ∈ s, ‖f b‖ ≤ n b) :
    ‖∏ b in s, f b‖ ≤ ∑ b in s, n b :=
  (norm_prod_le s f).trans <| Finset.sum_le_sum h
#align norm_prod_le_of_le norm_prod_le_of_le
#align norm_sum_le_of_le norm_sum_le_of_le
-/

#print dist_prod_prod_le_of_le /-
@[to_additive]
theorem dist_prod_prod_le_of_le (s : Finset ι) {f a : ι → E} {d : ι → ℝ}
    (h : ∀ b ∈ s, dist (f b) (a b) ≤ d b) : dist (∏ b in s, f b) (∏ b in s, a b) ≤ ∑ b in s, d b :=
  by simp only [dist_eq_norm_div, ← Finset.prod_div_distrib] at *; exact norm_prod_le_of_le s h
#align dist_prod_prod_le_of_le dist_prod_prod_le_of_le
#align dist_sum_sum_le_of_le dist_sum_sum_le_of_le
-/

#print dist_prod_prod_le /-
@[to_additive]
theorem dist_prod_prod_le (s : Finset ι) (f a : ι → E) :
    dist (∏ b in s, f b) (∏ b in s, a b) ≤ ∑ b in s, dist (f b) (a b) :=
  dist_prod_prod_le_of_le s fun _ _ => le_rfl
#align dist_prod_prod_le dist_prod_prod_le
#align dist_sum_sum_le dist_sum_sum_le
-/

#print mul_mem_ball_iff_norm /-
@[to_additive]
theorem mul_mem_ball_iff_norm : a * b ∈ ball a r ↔ ‖b‖ < r := by
  rw [mem_ball_iff_norm'', mul_div_cancel''']
#align mul_mem_ball_iff_norm mul_mem_ball_iff_norm
#align add_mem_ball_iff_norm add_mem_ball_iff_norm
-/

#print mul_mem_closedBall_iff_norm /-
@[to_additive]
theorem mul_mem_closedBall_iff_norm : a * b ∈ closedBall a r ↔ ‖b‖ ≤ r := by
  rw [mem_closedBall_iff_norm'', mul_div_cancel''']
#align mul_mem_closed_ball_iff_norm mul_mem_closedBall_iff_norm
#align add_mem_closed_ball_iff_norm add_mem_closedBall_iff_norm
-/

#print preimage_mul_ball /-
@[simp, to_additive]
theorem preimage_mul_ball (a b : E) (r : ℝ) : (· * ·) b ⁻¹' ball a r = ball (a / b) r := by ext c;
  simp only [dist_eq_norm_div, Set.mem_preimage, mem_ball, div_div_eq_mul_div, mul_comm]
#align preimage_mul_ball preimage_mul_ball
#align preimage_add_ball preimage_add_ball
-/

#print preimage_mul_closedBall /-
@[simp, to_additive]
theorem preimage_mul_closedBall (a b : E) (r : ℝ) :
    (· * ·) b ⁻¹' closedBall a r = closedBall (a / b) r :=
  by
  ext c
  simp only [dist_eq_norm_div, Set.mem_preimage, mem_closed_ball, div_div_eq_mul_div, mul_comm]
#align preimage_mul_closed_ball preimage_mul_closedBall
#align preimage_add_closed_ball preimage_add_closedBall
-/

#print preimage_mul_sphere /-
@[simp, to_additive]
theorem preimage_mul_sphere (a b : E) (r : ℝ) : (· * ·) b ⁻¹' sphere a r = sphere (a / b) r := by
  ext c; simp only [Set.mem_preimage, mem_sphere_iff_norm', div_div_eq_mul_div, mul_comm]
#align preimage_mul_sphere preimage_mul_sphere
#align preimage_add_sphere preimage_add_sphere
-/

#print norm_pow_le_mul_norm /-
@[to_additive norm_nsmul_le]
theorem norm_pow_le_mul_norm (n : ℕ) (a : E) : ‖a ^ n‖ ≤ n * ‖a‖ :=
  by
  induction' n with n ih; · simp
  simpa only [pow_succ', Nat.cast_succ, add_mul, one_mul] using norm_mul_le_of_le ih le_rfl
#align norm_pow_le_mul_norm norm_pow_le_mul_norm
#align norm_nsmul_le norm_nsmul_le
-/

#print nnnorm_pow_le_mul_norm /-
@[to_additive nnnorm_nsmul_le]
theorem nnnorm_pow_le_mul_norm (n : ℕ) (a : E) : ‖a ^ n‖₊ ≤ n * ‖a‖₊ := by
  simpa only [← NNReal.coe_le_coe, NNReal.coe_mul, NNReal.coe_nat_cast] using
    norm_pow_le_mul_norm n a
#align nnnorm_pow_le_mul_norm nnnorm_pow_le_mul_norm
#align nnnorm_nsmul_le nnnorm_nsmul_le
-/

#print pow_mem_closedBall /-
@[to_additive]
theorem pow_mem_closedBall {n : ℕ} (h : a ∈ closedBall b r) : a ^ n ∈ closedBall (b ^ n) (n • r) :=
  by
  simp only [mem_closed_ball, dist_eq_norm_div, ← div_pow] at h ⊢
  refine' (norm_pow_le_mul_norm n (a / b)).trans _
  simpa only [nsmul_eq_mul] using mul_le_mul_of_nonneg_left h n.cast_nonneg
#align pow_mem_closed_ball pow_mem_closedBall
#align nsmul_mem_closed_ball nsmul_mem_closedBall
-/

#print pow_mem_ball /-
@[to_additive]
theorem pow_mem_ball {n : ℕ} (hn : 0 < n) (h : a ∈ ball b r) : a ^ n ∈ ball (b ^ n) (n • r) :=
  by
  simp only [mem_ball, dist_eq_norm_div, ← div_pow] at h ⊢
  refine' lt_of_le_of_lt (norm_pow_le_mul_norm n (a / b)) _
  replace hn : 0 < (n : ℝ); · norm_cast; assumption
  rw [nsmul_eq_mul]
  nlinarith
#align pow_mem_ball pow_mem_ball
#align nsmul_mem_ball nsmul_mem_ball
-/

#print mul_mem_closedBall_mul_iff /-
@[simp, to_additive]
theorem mul_mem_closedBall_mul_iff {c : E} : a * c ∈ closedBall (b * c) r ↔ a ∈ closedBall b r := by
  simp only [mem_closed_ball, dist_eq_norm_div, mul_div_mul_right_eq_div]
#align mul_mem_closed_ball_mul_iff mul_mem_closedBall_mul_iff
#align add_mem_closed_ball_add_iff add_mem_closedBall_add_iff
-/

#print mul_mem_ball_mul_iff /-
@[simp, to_additive]
theorem mul_mem_ball_mul_iff {c : E} : a * c ∈ ball (b * c) r ↔ a ∈ ball b r := by
  simp only [mem_ball, dist_eq_norm_div, mul_div_mul_right_eq_div]
#align mul_mem_ball_mul_iff mul_mem_ball_mul_iff
#align add_mem_ball_add_iff add_mem_ball_add_iff
-/

#print smul_closedBall'' /-
@[to_additive]
theorem smul_closedBall'' : a • closedBall b r = closedBall (a • b) r := by ext;
  simp [mem_closed_ball, Set.mem_smul_set, dist_eq_norm_div, div_eq_inv_mul, ←
    eq_inv_mul_iff_mul_eq, mul_assoc]
#align smul_closed_ball'' smul_closedBall''
#align vadd_closed_ball'' vadd_closedBall''
-/

#print smul_ball'' /-
@[to_additive]
theorem smul_ball'' : a • ball b r = ball (a • b) r := by ext;
  simp [mem_ball, Set.mem_smul_set, dist_eq_norm_div, div_eq_inv_mul, ← eq_inv_mul_iff_mul_eq,
    mul_assoc]
#align smul_ball'' smul_ball''
#align vadd_ball'' vadd_ball''
-/

open Finset

#print controlled_prod_of_mem_closure /-
@[to_additive]
theorem controlled_prod_of_mem_closure {s : Subgroup E} (hg : a ∈ closure (s : Set E)) {b : ℕ → ℝ}
    (b_pos : ∀ n, 0 < b n) :
    ∃ v : ℕ → E,
      Tendsto (fun n => ∏ i in range (n + 1), v i) atTop (𝓝 a) ∧
        (∀ n, v n ∈ s) ∧ ‖v 0 / a‖ < b 0 ∧ ∀ n, 0 < n → ‖v n‖ < b n :=
  by
  obtain ⟨u : ℕ → E, u_in : ∀ n, u n ∈ s, lim_u : tendsto u at_top (𝓝 a)⟩ :=
    mem_closure_iff_seq_limit.mp hg
  obtain ⟨n₀, hn₀⟩ : ∃ n₀, ∀ n ≥ n₀, ‖u n / a‖ < b 0 :=
    haveI : {x | ‖x / a‖ < b 0} ∈ 𝓝 a :=
      by
      simp_rw [← dist_eq_norm_div]
      exact Metric.ball_mem_nhds _ (b_pos _)
    filter.tendsto_at_top'.mp lim_u _ this
  set z : ℕ → E := fun n => u (n + n₀)
  have lim_z : tendsto z at_top (𝓝 a) := lim_u.comp (tendsto_add_at_top_nat n₀)
  have mem_𝓤 : ∀ n, {p : E × E | ‖p.1 / p.2‖ < b (n + 1)} ∈ 𝓤 E := fun n => by
    simpa [← dist_eq_norm_div] using Metric.dist_mem_uniformity (b_pos <| n + 1)
  obtain ⟨φ : ℕ → ℕ, φ_extr : StrictMono φ, hφ : ∀ n, ‖z (φ <| n + 1) / z (φ n)‖ < b (n + 1)⟩ :=
    lim_z.cauchy_seq.subseq_mem mem_𝓤
  set w : ℕ → E := z ∘ φ
  have hw : tendsto w at_top (𝓝 a) := lim_z.comp φ_extr.tendsto_at_top
  set v : ℕ → E := fun i => if i = 0 then w 0 else w i / w (i - 1)
  refine' ⟨v, tendsto.congr (Finset.eq_prod_range_div' w) hw, _, hn₀ _ (n₀.le_add_left _), _⟩
  · rintro ⟨⟩
    · change w 0 ∈ s
      apply u_in
    · apply s.div_mem <;> apply u_in
  · intro l hl
    obtain ⟨k, rfl⟩ : ∃ k, l = k + 1; exact Nat.exists_eq_succ_of_ne_zero hl.ne'
    apply hφ
#align controlled_prod_of_mem_closure controlled_prod_of_mem_closure
#align controlled_sum_of_mem_closure controlled_sum_of_mem_closure
-/

#print controlled_prod_of_mem_closure_range /-
@[to_additive]
theorem controlled_prod_of_mem_closure_range {j : E →* F} {b : F}
    (hb : b ∈ closure (j.range : Set F)) {f : ℕ → ℝ} (b_pos : ∀ n, 0 < f n) :
    ∃ a : ℕ → E,
      Tendsto (fun n => ∏ i in range (n + 1), j (a i)) atTop (𝓝 b) ∧
        ‖j (a 0) / b‖ < f 0 ∧ ∀ n, 0 < n → ‖j (a n)‖ < f n :=
  by
  obtain ⟨v, sum_v, v_in, hv₀, hv_pos⟩ := controlled_prod_of_mem_closure hb b_pos
  choose g hg using v_in
  refine'
    ⟨g, by simpa [← hg] using sum_v, by simpa [hg 0] using hv₀, fun n hn => by
      simpa [hg] using hv_pos n hn⟩
#align controlled_prod_of_mem_closure_range controlled_prod_of_mem_closure_range
#align controlled_sum_of_mem_closure_range controlled_sum_of_mem_closure_range
-/

#print nndist_mul_mul_le /-
@[to_additive]
theorem nndist_mul_mul_le (a₁ a₂ b₁ b₂ : E) :
    nndist (a₁ * a₂) (b₁ * b₂) ≤ nndist a₁ b₁ + nndist a₂ b₂ :=
  NNReal.coe_le_coe.1 <| dist_mul_mul_le a₁ a₂ b₁ b₂
#align nndist_mul_mul_le nndist_mul_mul_le
#align nndist_add_add_le nndist_add_add_le
-/

#print edist_mul_mul_le /-
@[to_additive]
theorem edist_mul_mul_le (a₁ a₂ b₁ b₂ : E) :
    edist (a₁ * a₂) (b₁ * b₂) ≤ edist a₁ b₁ + edist a₂ b₂ := by simp only [edist_nndist]; norm_cast;
  apply nndist_mul_mul_le
#align edist_mul_mul_le edist_mul_mul_le
#align edist_add_add_le edist_add_add_le
-/

#print nnnorm_multiset_prod_le /-
@[to_additive]
theorem nnnorm_multiset_prod_le (m : Multiset E) : ‖m.Prod‖₊ ≤ (m.map fun x => ‖x‖₊).Sum :=
  NNReal.coe_le_coe.1 <| by push_cast ; rw [Multiset.map_map]; exact norm_multiset_prod_le _
#align nnnorm_multiset_prod_le nnnorm_multiset_prod_le
#align nnnorm_multiset_sum_le nnnorm_multiset_sum_le
-/

#print nnnorm_prod_le /-
@[to_additive]
theorem nnnorm_prod_le (s : Finset ι) (f : ι → E) : ‖∏ a in s, f a‖₊ ≤ ∑ a in s, ‖f a‖₊ :=
  NNReal.coe_le_coe.1 <| by push_cast ; exact norm_prod_le _ _
#align nnnorm_prod_le nnnorm_prod_le
#align nnnorm_sum_le nnnorm_sum_le
-/

#print nnnorm_prod_le_of_le /-
@[to_additive]
theorem nnnorm_prod_le_of_le (s : Finset ι) {f : ι → E} {n : ι → ℝ≥0} (h : ∀ b ∈ s, ‖f b‖₊ ≤ n b) :
    ‖∏ b in s, f b‖₊ ≤ ∑ b in s, n b :=
  (norm_prod_le_of_le s h).trans_eq NNReal.coe_sum.symm
#align nnnorm_prod_le_of_le nnnorm_prod_le_of_le
#align nnnorm_sum_le_of_le nnnorm_sum_le_of_le
-/

namespace Real

instance : Norm ℝ where norm r := |r|

#print Real.norm_eq_abs /-
@[simp]
theorem norm_eq_abs (r : ℝ) : ‖r‖ = |r| :=
  rfl
#align real.norm_eq_abs Real.norm_eq_abs
-/

instance : NormedAddCommGroup ℝ :=
  ⟨fun r y => rfl⟩

#print Real.norm_of_nonneg /-
theorem norm_of_nonneg (hr : 0 ≤ r) : ‖r‖ = r :=
  abs_of_nonneg hr
#align real.norm_of_nonneg Real.norm_of_nonneg
-/

#print Real.norm_of_nonpos /-
theorem norm_of_nonpos (hr : r ≤ 0) : ‖r‖ = -r :=
  abs_of_nonpos hr
#align real.norm_of_nonpos Real.norm_of_nonpos
-/

#print Real.le_norm_self /-
theorem le_norm_self (r : ℝ) : r ≤ ‖r‖ :=
  le_abs_self r
#align real.le_norm_self Real.le_norm_self
-/

#print Real.norm_coe_nat /-
@[simp]
theorem norm_coe_nat (n : ℕ) : ‖(n : ℝ)‖ = n :=
  abs_of_nonneg n.cast_nonneg
#align real.norm_coe_nat Real.norm_coe_nat
-/

#print Real.nnnorm_coe_nat /-
@[simp]
theorem nnnorm_coe_nat (n : ℕ) : ‖(n : ℝ)‖₊ = n :=
  NNReal.eq <| norm_coe_nat _
#align real.nnnorm_coe_nat Real.nnnorm_coe_nat
-/

#print Real.norm_two /-
@[simp]
theorem norm_two : ‖(2 : ℝ)‖ = 2 :=
  abs_of_pos zero_lt_two
#align real.norm_two Real.norm_two
-/

#print Real.nnnorm_two /-
@[simp]
theorem nnnorm_two : ‖(2 : ℝ)‖₊ = 2 :=
  NNReal.eq <| by simp
#align real.nnnorm_two Real.nnnorm_two
-/

#print Real.nnnorm_of_nonneg /-
theorem nnnorm_of_nonneg (hr : 0 ≤ r) : ‖r‖₊ = ⟨r, hr⟩ :=
  NNReal.eq <| norm_of_nonneg hr
#align real.nnnorm_of_nonneg Real.nnnorm_of_nonneg
-/

#print Real.nnnorm_abs /-
@[simp]
theorem nnnorm_abs (r : ℝ) : ‖|r|‖₊ = ‖r‖₊ := by simp [nnnorm]
#align real.nnnorm_abs Real.nnnorm_abs
-/

#print Real.ennnorm_eq_ofReal /-
theorem ennnorm_eq_ofReal (hr : 0 ≤ r) : (‖r‖₊ : ℝ≥0∞) = ENNReal.ofReal r := by
  rw [← ofReal_norm_eq_coe_nnnorm, norm_of_nonneg hr]
#align real.ennnorm_eq_of_real Real.ennnorm_eq_ofReal
-/

#print Real.ennnorm_eq_ofReal_abs /-
theorem ennnorm_eq_ofReal_abs (r : ℝ) : (‖r‖₊ : ℝ≥0∞) = ENNReal.ofReal (|r|) := by
  rw [← Real.nnnorm_abs r, Real.ennnorm_eq_ofReal (abs_nonneg _)]
#align real.ennnorm_eq_of_real_abs Real.ennnorm_eq_ofReal_abs
-/

#print Real.toNNReal_eq_nnnorm_of_nonneg /-
theorem toNNReal_eq_nnnorm_of_nonneg (hr : 0 ≤ r) : r.toNNReal = ‖r‖₊ :=
  by
  rw [Real.toNNReal_of_nonneg hr]
  congr
  rw [Real.norm_eq_abs, abs_of_nonneg hr]
#align real.to_nnreal_eq_nnnorm_of_nonneg Real.toNNReal_eq_nnnorm_of_nonneg
-/

#print Real.ofReal_le_ennnorm /-
theorem ofReal_le_ennnorm (r : ℝ) : ENNReal.ofReal r ≤ ‖r‖₊ :=
  by
  obtain hr | hr := le_total 0 r
  · exact (Real.ennnorm_eq_ofReal hr).ge
  · rw [ENNReal.ofReal_eq_zero.2 hr]
    exact bot_le
#align real.of_real_le_ennnorm Real.ofReal_le_ennnorm
-/

end Real

namespace Int

instance : NormedAddCommGroup ℤ where
  norm n := ‖(n : ℝ)‖
  dist_eq m n := by simp only [Int.dist_eq, norm, Int.cast_sub]

#print Int.norm_cast_real /-
@[norm_cast]
theorem norm_cast_real (m : ℤ) : ‖(m : ℝ)‖ = ‖m‖ :=
  rfl
#align int.norm_cast_real Int.norm_cast_real
-/

#print Int.norm_eq_abs /-
theorem norm_eq_abs (n : ℤ) : ‖n‖ = |n| :=
  rfl
#align int.norm_eq_abs Int.norm_eq_abs
-/

#print Int.norm_coe_nat /-
@[simp]
theorem norm_coe_nat (n : ℕ) : ‖(n : ℤ)‖ = n := by simp [Int.norm_eq_abs]
#align int.norm_coe_nat Int.norm_coe_nat
-/

#print NNReal.coe_natAbs /-
theorem NNReal.coe_natAbs (n : ℤ) : (n.natAbs : ℝ≥0) = ‖n‖₊ :=
  NNReal.eq <|
    calc
      ((n.natAbs : ℝ≥0) : ℝ) = (n.natAbs : ℤ) := by simp only [Int.cast_ofNat, NNReal.coe_nat_cast]
      _ = |n| := by simp only [Int.coe_natAbs, Int.cast_abs]
      _ = ‖n‖ := rfl
#align nnreal.coe_nat_abs NNReal.coe_natAbs
-/

#print Int.abs_le_floor_nnreal_iff /-
theorem abs_le_floor_nnreal_iff (z : ℤ) (c : ℝ≥0) : |z| ≤ ⌊c⌋₊ ↔ ‖z‖₊ ≤ c :=
  by
  rw [Int.abs_eq_natAbs, Int.ofNat_le, Nat.le_floor_iff (zero_le c)]
  congr
  exact NNReal.coe_natAbs z
#align int.abs_le_floor_nnreal_iff Int.abs_le_floor_nnreal_iff
-/

end Int

namespace Rat

instance : NormedAddCommGroup ℚ where
  norm r := ‖(r : ℝ)‖
  dist_eq r₁ r₂ := by simp only [Rat.dist_eq, norm, Rat.cast_sub]

#print Rat.norm_cast_real /-
@[norm_cast, simp]
theorem norm_cast_real (r : ℚ) : ‖(r : ℝ)‖ = ‖r‖ :=
  rfl
#align rat.norm_cast_real Rat.norm_cast_real
-/

#print Int.norm_cast_rat /-
@[norm_cast, simp]
theorem Int.norm_cast_rat (m : ℤ) : ‖(m : ℚ)‖ = ‖m‖ := by
  rw [← Rat.norm_cast_real, ← Int.norm_cast_real] <;> congr 1 <;> norm_cast
#align int.norm_cast_rat Int.norm_cast_rat
-/

end Rat

-- Now that we've installed the norm on `ℤ`,
-- we can state some lemmas about `zsmul`.
section

variable [SeminormedCommGroup α]

#print norm_zpow_le_mul_norm /-
@[to_additive norm_zsmul_le]
theorem norm_zpow_le_mul_norm (n : ℤ) (a : α) : ‖a ^ n‖ ≤ ‖n‖ * ‖a‖ := by
  rcases n.eq_coe_or_neg with ⟨n, rfl | rfl⟩ <;> simpa using norm_pow_le_mul_norm n a
#align norm_zpow_le_mul_norm norm_zpow_le_mul_norm
#align norm_zsmul_le norm_zsmul_le
-/

#print nnnorm_zpow_le_mul_norm /-
@[to_additive nnnorm_zsmul_le]
theorem nnnorm_zpow_le_mul_norm (n : ℤ) (a : α) : ‖a ^ n‖₊ ≤ ‖n‖₊ * ‖a‖₊ := by
  simpa only [← NNReal.coe_le_coe, NNReal.coe_mul] using norm_zpow_le_mul_norm n a
#align nnnorm_zpow_le_mul_norm nnnorm_zpow_le_mul_norm
#align nnnorm_zsmul_le nnnorm_zsmul_le
-/

end

namespace LipschitzWith

variable [PseudoEMetricSpace α] {K Kf Kg : ℝ≥0} {f g : α → E}

#print LipschitzWith.inv /-
@[to_additive]
theorem inv (hf : LipschitzWith K f) : LipschitzWith K fun x => (f x)⁻¹ := fun x y =>
  (edist_inv_inv _ _).trans_le <| hf x y
#align lipschitz_with.inv LipschitzWith.inv
#align lipschitz_with.neg LipschitzWith.neg
-/

#print LipschitzWith.mul' /-
@[to_additive add]
theorem mul' (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (Kf + Kg) fun x => f x * g x := fun x y =>
  calc
    edist (f x * g x) (f y * g y) ≤ edist (f x) (f y) + edist (g x) (g y) :=
      edist_mul_mul_le _ _ _ _
    _ ≤ Kf * edist x y + Kg * edist x y := (add_le_add (hf x y) (hg x y))
    _ = (Kf + Kg) * edist x y := (add_mul _ _ _).symm
#align lipschitz_with.mul' LipschitzWith.mul'
#align lipschitz_with.add LipschitzWith.add
-/

#print LipschitzWith.div /-
@[to_additive]
theorem div (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (Kf + Kg) fun x => f x / g x := by
  simpa only [div_eq_mul_inv] using hf.mul' hg.inv
#align lipschitz_with.div LipschitzWith.div
#align lipschitz_with.sub LipschitzWith.sub
-/

end LipschitzWith

namespace AntilipschitzWith

variable [PseudoEMetricSpace α] {K Kf Kg : ℝ≥0} {f g : α → E}

#print AntilipschitzWith.mul_lipschitzWith /-
@[to_additive]
theorem mul_lipschitzWith (hf : AntilipschitzWith Kf f) (hg : LipschitzWith Kg g) (hK : Kg < Kf⁻¹) :
    AntilipschitzWith (Kf⁻¹ - Kg)⁻¹ fun x => f x * g x :=
  by
  letI : PseudoMetricSpace α := PseudoEMetricSpace.toPseudoMetricSpace hf.edist_ne_top
  refine' AntilipschitzWith.of_le_mul_dist fun x y => _
  rw [NNReal.coe_inv, ← div_eq_inv_mul]
  rw [le_div_iff (NNReal.coe_pos.2 <| tsub_pos_iff_lt.2 hK)]
  rw [mul_comm, NNReal.coe_sub hK.le, sub_mul]
  calc
    ↑Kf⁻¹ * dist x y - Kg * dist x y ≤ dist (f x) (f y) - dist (g x) (g y) :=
      sub_le_sub (hf.mul_le_dist x y) (hg.dist_le_mul x y)
    _ ≤ _ := le_trans (le_abs_self _) (abs_dist_sub_le_dist_mul_mul _ _ _ _)
#align antilipschitz_with.mul_lipschitz_with AntilipschitzWith.mul_lipschitzWith
#align antilipschitz_with.add_lipschitz_with AntilipschitzWith.add_lipschitzWith
-/

#print AntilipschitzWith.mul_div_lipschitzWith /-
@[to_additive]
theorem mul_div_lipschitzWith (hf : AntilipschitzWith Kf f) (hg : LipschitzWith Kg (g / f))
    (hK : Kg < Kf⁻¹) : AntilipschitzWith (Kf⁻¹ - Kg)⁻¹ g := by
  simpa only [Pi.div_apply, mul_div_cancel'_right] using hf.mul_lipschitz_with hg hK
#align antilipschitz_with.mul_div_lipschitz_with AntilipschitzWith.mul_div_lipschitzWith
#align antilipschitz_with.add_sub_lipschitz_with AntilipschitzWith.add_sub_lipschitzWith
-/

#print AntilipschitzWith.le_mul_norm_div /-
@[to_additive]
theorem le_mul_norm_div {f : E → F} (hf : AntilipschitzWith K f) (x y : E) :
    ‖x / y‖ ≤ K * ‖f x / f y‖ := by simp [← dist_eq_norm_div, hf.le_mul_dist x y]
#align antilipschitz_with.le_mul_norm_div AntilipschitzWith.le_mul_norm_div
#align antilipschitz_with.le_add_norm_sub AntilipschitzWith.le_add_norm_sub
-/

end AntilipschitzWith

#print SeminormedCommGroup.to_lipschitzMul /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) SeminormedCommGroup.to_lipschitzMul : LipschitzMul E :=
  ⟨⟨1 + 1, LipschitzWith.prod_fst.mul' LipschitzWith.prod_snd⟩⟩
#align seminormed_comm_group.to_has_lipschitz_mul SeminormedCommGroup.to_lipschitzMul
#align seminormed_add_comm_group.to_has_lipschitz_add SeminormedAddCommGroup.to_lipschitzAdd
-/

#print SeminormedCommGroup.to_uniformGroup /-
-- See note [lower instance priority]
/-- A seminormed group is a uniform group, i.e., multiplication and division are uniformly
continuous. -/
@[to_additive
      "A seminormed group is a uniform additive group, i.e., addition and\nsubtraction are uniformly continuous."]
instance (priority := 100) SeminormedCommGroup.to_uniformGroup : UniformGroup E :=
  ⟨(LipschitzWith.prod_fst.div LipschitzWith.prod_snd).UniformContinuous⟩
#align seminormed_comm_group.to_uniform_group SeminormedCommGroup.to_uniformGroup
#align seminormed_add_comm_group.to_uniform_add_group SeminormedAddCommGroup.to_uniformAddGroup
-/

#print SeminormedCommGroup.toTopologicalGroup /-
-- short-circuit type class inference
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) SeminormedCommGroup.toTopologicalGroup : TopologicalGroup E :=
  inferInstance
#align seminormed_comm_group.to_topological_group SeminormedCommGroup.toTopologicalGroup
#align seminormed_add_comm_group.to_topological_add_group SeminormedAddCommGroup.toTopologicalAddGroup
-/

#print cauchySeq_prod_of_eventually_eq /-
@[to_additive]
theorem cauchySeq_prod_of_eventually_eq {u v : ℕ → E} {N : ℕ} (huv : ∀ n ≥ N, u n = v n)
    (hv : CauchySeq fun n => ∏ k in range (n + 1), v k) :
    CauchySeq fun n => ∏ k in range (n + 1), u k :=
  by
  let d : ℕ → E := fun n => ∏ k in range (n + 1), u k / v k
  rw [show (fun n => ∏ k in range (n + 1), u k) = d * fun n => ∏ k in range (n + 1), v k by ext n;
      simp [d]]
  suffices ∀ n ≥ N, d n = d N by exact (tendsto_atTop_of_eventually_const this).CauchySeq.mul hv
  intro n hn
  dsimp [d]
  rw [eventually_constant_prod _ hn]
  intro m hm
  simp [huv m hm]
#align cauchy_seq_prod_of_eventually_eq cauchySeq_prod_of_eventually_eq
#align cauchy_seq_sum_of_eventually_eq cauchySeq_sum_of_eventually_eq
-/

end SeminormedCommGroup

section NormedGroup

variable [NormedGroup E] [NormedGroup F] {a b : E}

#print norm_eq_zero'' /-
@[simp, to_additive norm_eq_zero]
theorem norm_eq_zero'' : ‖a‖ = 0 ↔ a = 1 :=
  norm_eq_zero'''
#align norm_eq_zero'' norm_eq_zero''
#align norm_eq_zero norm_eq_zero
-/

#print norm_ne_zero_iff' /-
@[to_additive norm_ne_zero_iff]
theorem norm_ne_zero_iff' : ‖a‖ ≠ 0 ↔ a ≠ 1 :=
  norm_eq_zero''.Not
#align norm_ne_zero_iff' norm_ne_zero_iff'
#align norm_ne_zero_iff norm_ne_zero_iff
-/

#print norm_pos_iff'' /-
@[simp, to_additive norm_pos_iff]
theorem norm_pos_iff'' : 0 < ‖a‖ ↔ a ≠ 1 :=
  norm_pos_iff'''
#align norm_pos_iff'' norm_pos_iff''
#align norm_pos_iff norm_pos_iff
-/

#print norm_le_zero_iff'' /-
@[simp, to_additive norm_le_zero_iff]
theorem norm_le_zero_iff'' : ‖a‖ ≤ 0 ↔ a = 1 :=
  norm_le_zero_iff'''
#align norm_le_zero_iff'' norm_le_zero_iff''
#align norm_le_zero_iff norm_le_zero_iff
-/

#print norm_div_eq_zero_iff /-
@[to_additive]
theorem norm_div_eq_zero_iff : ‖a / b‖ = 0 ↔ a = b := by rw [norm_eq_zero'', div_eq_one]
#align norm_div_eq_zero_iff norm_div_eq_zero_iff
#align norm_sub_eq_zero_iff norm_sub_eq_zero_iff
-/

#print norm_div_pos_iff /-
@[to_additive]
theorem norm_div_pos_iff : 0 < ‖a / b‖ ↔ a ≠ b := by rw [(norm_nonneg' _).lt_iff_ne, ne_comm];
  exact norm_div_eq_zero_iff.not
#align norm_div_pos_iff norm_div_pos_iff
#align norm_sub_pos_iff norm_sub_pos_iff
-/

#print eq_of_norm_div_le_zero /-
@[to_additive]
theorem eq_of_norm_div_le_zero (h : ‖a / b‖ ≤ 0) : a = b := by
  rwa [← div_eq_one, ← norm_le_zero_iff'']
#align eq_of_norm_div_le_zero eq_of_norm_div_le_zero
#align eq_of_norm_sub_le_zero eq_of_norm_sub_le_zero
-/

alias norm_div_eq_zero_iff ↔ eq_of_norm_div_eq_zero _
#align eq_of_norm_div_eq_zero eq_of_norm_div_eq_zero

attribute [to_additive] eq_of_norm_div_eq_zero

#print nnnorm_eq_zero' /-
@[simp, to_additive nnnorm_eq_zero]
theorem nnnorm_eq_zero' : ‖a‖₊ = 0 ↔ a = 1 := by
  rw [← NNReal.coe_eq_zero, coe_nnnorm', norm_eq_zero'']
#align nnnorm_eq_zero' nnnorm_eq_zero'
#align nnnorm_eq_zero nnnorm_eq_zero
-/

#print nnnorm_ne_zero_iff' /-
@[to_additive nnnorm_ne_zero_iff]
theorem nnnorm_ne_zero_iff' : ‖a‖₊ ≠ 0 ↔ a ≠ 1 :=
  nnnorm_eq_zero'.Not
#align nnnorm_ne_zero_iff' nnnorm_ne_zero_iff'
#align nnnorm_ne_zero_iff nnnorm_ne_zero_iff
-/

#print tendsto_norm_div_self_punctured_nhds /-
@[to_additive]
theorem tendsto_norm_div_self_punctured_nhds (a : E) :
    Tendsto (fun x => ‖x / a‖) (𝓝[≠] a) (𝓝[>] 0) :=
  (tendsto_norm_div_self a).inf <|
    tendsto_principal_principal.2 fun x hx => norm_pos_iff''.2 <| div_ne_one.2 hx
#align tendsto_norm_div_self_punctured_nhds tendsto_norm_div_self_punctured_nhds
#align tendsto_norm_sub_self_punctured_nhds tendsto_norm_sub_self_punctured_nhds
-/

#print tendsto_norm_nhdsWithin_one /-
@[to_additive]
theorem tendsto_norm_nhdsWithin_one : Tendsto (norm : E → ℝ) (𝓝[≠] 1) (𝓝[>] 0) :=
  tendsto_norm_one.inf <| tendsto_principal_principal.2 fun x => norm_pos_iff''.2
#align tendsto_norm_nhds_within_one tendsto_norm_nhdsWithin_one
#align tendsto_norm_nhds_within_zero tendsto_norm_nhdsWithin_zero
-/

variable (E)

#print normGroupNorm /-
/-- The norm of a normed group as a group norm. -/
@[to_additive "The norm of a normed group as an additive group norm."]
def normGroupNorm : GroupNorm E :=
  { normGroupSeminorm _ with eq_one_of_map_eq_zero' := fun _ => norm_eq_zero''.1 }
#align norm_group_norm normGroupNorm
#align norm_add_group_norm normAddGroupNorm
-/

#print coe_normGroupNorm /-
@[simp]
theorem coe_normGroupNorm : ⇑(normGroupNorm E) = norm :=
  rfl
#align coe_norm_group_norm coe_normGroupNorm
-/

end NormedGroup

section NormedAddGroup

variable [NormedAddGroup E] [TopologicalSpace α] {f : α → E}

/-! Some relations with `has_compact_support` -/


#print hasCompactSupport_norm_iff /-
theorem hasCompactSupport_norm_iff : (HasCompactSupport fun x => ‖f x‖) ↔ HasCompactSupport f :=
  hasCompactSupport_comp_left fun x => norm_eq_zero
#align has_compact_support_norm_iff hasCompactSupport_norm_iff
-/

alias hasCompactSupport_norm_iff ↔ _ HasCompactSupport.norm
#align has_compact_support.norm HasCompactSupport.norm

#print Continuous.bounded_above_of_compact_support /-
theorem Continuous.bounded_above_of_compact_support (hf : Continuous f) (h : HasCompactSupport f) :
    ∃ C, ∀ x, ‖f x‖ ≤ C := by
  simpa [bddAbove_def] using hf.norm.bdd_above_range_of_has_compact_support h.norm
#align continuous.bounded_above_of_compact_support Continuous.bounded_above_of_compact_support
-/

end NormedAddGroup

section NormedAddGroupSource

variable [NormedAddGroup α] {f : α → E}

#print HasCompactMulSupport.exists_pos_le_norm /-
@[to_additive]
theorem HasCompactMulSupport.exists_pos_le_norm [One E] (hf : HasCompactMulSupport f) :
    ∃ R : ℝ, 0 < R ∧ ∀ x : α, R ≤ ‖x‖ → f x = 1 :=
  by
  obtain ⟨K, ⟨hK1, hK2⟩⟩ := exists_compact_iff_has_compact_mul_support.mpr hf
  obtain ⟨S, hS, hS'⟩ := hK1.bounded.exists_pos_norm_le
  refine' ⟨S + 1, by positivity, fun x hx => hK2 x ((mt <| hS' x) _)⟩
  contrapose! hx
  exact lt_add_of_le_of_pos hx zero_lt_one
#align has_compact_mul_support.exists_pos_le_norm HasCompactMulSupport.exists_pos_le_norm
#align has_compact_support.exists_pos_le_norm HasCompactSupport.exists_pos_le_norm
-/

end NormedAddGroupSource

/-! ### `ulift` -/


namespace ULift

section Norm

variable [Norm E]

instance : Norm (ULift E) :=
  ⟨fun x => ‖x.down‖⟩

#print ULift.norm_def /-
theorem norm_def (x : ULift E) : ‖x‖ = ‖x.down‖ :=
  rfl
#align ulift.norm_def ULift.norm_def
-/

#print ULift.norm_up /-
@[simp]
theorem norm_up (x : E) : ‖ULift.up x‖ = ‖x‖ :=
  rfl
#align ulift.norm_up ULift.norm_up
-/

#print ULift.norm_down /-
@[simp]
theorem norm_down (x : ULift E) : ‖x.down‖ = ‖x‖ :=
  rfl
#align ulift.norm_down ULift.norm_down
-/

end Norm

section NNNorm

variable [NNNorm E]

instance : NNNorm (ULift E) :=
  ⟨fun x => ‖x.down‖₊⟩

#print ULift.nnnorm_def /-
theorem nnnorm_def (x : ULift E) : ‖x‖₊ = ‖x.down‖₊ :=
  rfl
#align ulift.nnnorm_def ULift.nnnorm_def
-/

#print ULift.nnnorm_up /-
@[simp]
theorem nnnorm_up (x : E) : ‖ULift.up x‖₊ = ‖x‖₊ :=
  rfl
#align ulift.nnnorm_up ULift.nnnorm_up
-/

#print ULift.nnnorm_down /-
@[simp]
theorem nnnorm_down (x : ULift E) : ‖x.down‖₊ = ‖x‖₊ :=
  rfl
#align ulift.nnnorm_down ULift.nnnorm_down
-/

end NNNorm

#print ULift.seminormedGroup /-
@[to_additive]
instance seminormedGroup [SeminormedGroup E] : SeminormedGroup (ULift E) :=
  SeminormedGroup.induced _ _ (⟨ULift.down, rfl, fun _ _ => rfl⟩ : ULift E →* E)
#align ulift.seminormed_group ULift.seminormedGroup
#align ulift.seminormed_add_group ULift.seminormedAddGroup
-/

#print ULift.seminormedCommGroup /-
@[to_additive]
instance seminormedCommGroup [SeminormedCommGroup E] : SeminormedCommGroup (ULift E) :=
  SeminormedCommGroup.induced _ _ (⟨ULift.down, rfl, fun _ _ => rfl⟩ : ULift E →* E)
#align ulift.seminormed_comm_group ULift.seminormedCommGroup
#align ulift.seminormed_add_comm_group ULift.seminormedAddCommGroup
-/

#print ULift.normedGroup /-
@[to_additive]
instance normedGroup [NormedGroup E] : NormedGroup (ULift E) :=
  NormedGroup.induced _ _ (⟨ULift.down, rfl, fun _ _ => rfl⟩ : ULift E →* E) down_injective
#align ulift.normed_group ULift.normedGroup
#align ulift.normed_add_group ULift.normedAddGroup
-/

#print ULift.normedCommGroup /-
@[to_additive]
instance normedCommGroup [NormedCommGroup E] : NormedCommGroup (ULift E) :=
  NormedCommGroup.induced _ _ (⟨ULift.down, rfl, fun _ _ => rfl⟩ : ULift E →* E) down_injective
#align ulift.normed_comm_group ULift.normedCommGroup
#align ulift.normed_add_comm_group ULift.normedAddCommGroup
-/

end ULift

/-! ### `additive`, `multiplicative` -/


section AdditiveMultiplicative

open Additive Multiplicative

section Norm

variable [Norm E]

instance : Norm (Additive E) :=
  ‹Norm E›

instance : Norm (Multiplicative E) :=
  ‹Norm E›

#print norm_toMul /-
@[simp]
theorem norm_toMul (x) : ‖(toMul x : E)‖ = ‖x‖ :=
  rfl
#align norm_to_mul norm_toMul
-/

#print norm_ofMul /-
@[simp]
theorem norm_ofMul (x : E) : ‖ofMul x‖ = ‖x‖ :=
  rfl
#align norm_of_mul norm_ofMul
-/

#print norm_toAdd /-
@[simp]
theorem norm_toAdd (x) : ‖(toAdd x : E)‖ = ‖x‖ :=
  rfl
#align norm_to_add norm_toAdd
-/

#print norm_ofAdd /-
@[simp]
theorem norm_ofAdd (x : E) : ‖ofAdd x‖ = ‖x‖ :=
  rfl
#align norm_of_add norm_ofAdd
-/

end Norm

section NNNorm

variable [NNNorm E]

instance : NNNorm (Additive E) :=
  ‹NNNorm E›

instance : NNNorm (Multiplicative E) :=
  ‹NNNorm E›

#print nnnorm_toMul /-
@[simp]
theorem nnnorm_toMul (x) : ‖(toMul x : E)‖₊ = ‖x‖₊ :=
  rfl
#align nnnorm_to_mul nnnorm_toMul
-/

#print nnnorm_ofMul /-
@[simp]
theorem nnnorm_ofMul (x : E) : ‖ofMul x‖₊ = ‖x‖₊ :=
  rfl
#align nnnorm_of_mul nnnorm_ofMul
-/

#print nnnorm_toAdd /-
@[simp]
theorem nnnorm_toAdd (x) : ‖(toAdd x : E)‖₊ = ‖x‖₊ :=
  rfl
#align nnnorm_to_add nnnorm_toAdd
-/

#print nnnorm_ofAdd /-
@[simp]
theorem nnnorm_ofAdd (x : E) : ‖ofAdd x‖₊ = ‖x‖₊ :=
  rfl
#align nnnorm_of_add nnnorm_ofAdd
-/

end NNNorm

instance [SeminormedGroup E] : SeminormedAddGroup (Additive E) where dist_eq := dist_eq_norm_div

instance [SeminormedAddGroup E] : SeminormedGroup (Multiplicative E)
    where dist_eq := dist_eq_norm_sub

instance [SeminormedCommGroup E] : SeminormedAddCommGroup (Additive E) :=
  { Additive.seminormedAddGroup with }

instance [SeminormedAddCommGroup E] : SeminormedCommGroup (Multiplicative E) :=
  { Multiplicative.seminormedGroup with }

instance [NormedGroup E] : NormedAddGroup (Additive E) :=
  { Additive.seminormedAddGroup with }

instance [NormedAddGroup E] : NormedGroup (Multiplicative E) :=
  { Multiplicative.seminormedGroup with }

instance [NormedCommGroup E] : NormedAddCommGroup (Additive E) :=
  { Additive.seminormedAddGroup with }

instance [NormedAddCommGroup E] : NormedCommGroup (Multiplicative E) :=
  { Multiplicative.seminormedGroup with }

end AdditiveMultiplicative

/-! ### Order dual -/


section OrderDual

open OrderDual

section Norm

variable [Norm E]

instance : Norm Eᵒᵈ :=
  ‹Norm E›

#print norm_toDual /-
@[simp]
theorem norm_toDual (x : E) : ‖toDual x‖ = ‖x‖ :=
  rfl
#align norm_to_dual norm_toDual
-/

#print norm_ofDual /-
@[simp]
theorem norm_ofDual (x : Eᵒᵈ) : ‖ofDual x‖ = ‖x‖ :=
  rfl
#align norm_of_dual norm_ofDual
-/

end Norm

section NNNorm

variable [NNNorm E]

instance : NNNorm Eᵒᵈ :=
  ‹NNNorm E›

#print nnnorm_toDual /-
@[simp]
theorem nnnorm_toDual (x : E) : ‖toDual x‖₊ = ‖x‖₊ :=
  rfl
#align nnnorm_to_dual nnnorm_toDual
-/

#print nnnorm_ofDual /-
@[simp]
theorem nnnorm_ofDual (x : Eᵒᵈ) : ‖ofDual x‖₊ = ‖x‖₊ :=
  rfl
#align nnnorm_of_dual nnnorm_ofDual
-/

end NNNorm

-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) [SeminormedGroup E] : SeminormedGroup Eᵒᵈ :=
  ‹SeminormedGroup E›

-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) [SeminormedCommGroup E] : SeminormedCommGroup Eᵒᵈ :=
  ‹SeminormedCommGroup E›

-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) [NormedGroup E] : NormedGroup Eᵒᵈ :=
  ‹NormedGroup E›

-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) [NormedCommGroup E] : NormedCommGroup Eᵒᵈ :=
  ‹NormedCommGroup E›

end OrderDual

/-! ### Binary product of normed groups -/


section Norm

variable [Norm E] [Norm F] {x : E × F} {r : ℝ}

instance : Norm (E × F) :=
  ⟨fun x => ‖x.1‖ ⊔ ‖x.2‖⟩

#print Prod.norm_def /-
theorem Prod.norm_def (x : E × F) : ‖x‖ = max ‖x.1‖ ‖x.2‖ :=
  rfl
#align prod.norm_def Prod.norm_def
-/

#print norm_fst_le /-
theorem norm_fst_le (x : E × F) : ‖x.1‖ ≤ ‖x‖ :=
  le_max_left _ _
#align norm_fst_le norm_fst_le
-/

#print norm_snd_le /-
theorem norm_snd_le (x : E × F) : ‖x.2‖ ≤ ‖x‖ :=
  le_max_right _ _
#align norm_snd_le norm_snd_le
-/

#print norm_prod_le_iff /-
theorem norm_prod_le_iff : ‖x‖ ≤ r ↔ ‖x.1‖ ≤ r ∧ ‖x.2‖ ≤ r :=
  max_le_iff
#align norm_prod_le_iff norm_prod_le_iff
-/

end Norm

section SeminormedGroup

variable [SeminormedGroup E] [SeminormedGroup F]

/-- Product of seminormed groups, using the sup norm. -/
@[to_additive "Product of seminormed groups, using the sup norm."]
instance : SeminormedGroup (E × F) :=
  ⟨fun x y => by
    simp only [Prod.norm_def, Prod.dist_eq, dist_eq_norm_div, Prod.fst_div, Prod.snd_div]⟩

#print Prod.nnorm_def /-
@[to_additive Prod.nnnorm_def']
theorem Prod.nnorm_def (x : E × F) : ‖x‖₊ = max ‖x.1‖₊ ‖x.2‖₊ :=
  rfl
#align prod.nnorm_def Prod.nnorm_def
#align prod.nnnorm_def' Prod.nnnorm_def'
-/

end SeminormedGroup

/-- Product of seminormed groups, using the sup norm. -/
@[to_additive "Product of seminormed groups, using the sup norm."]
instance [SeminormedCommGroup E] [SeminormedCommGroup F] : SeminormedCommGroup (E × F) :=
  { Prod.seminormedGroup with }

/-- Product of normed groups, using the sup norm. -/
@[to_additive "Product of normed groups, using the sup norm."]
instance [NormedGroup E] [NormedGroup F] : NormedGroup (E × F) :=
  { Prod.seminormedGroup with }

/-- Product of normed groups, using the sup norm. -/
@[to_additive "Product of normed groups, using the sup norm."]
instance [NormedCommGroup E] [NormedCommGroup F] : NormedCommGroup (E × F) :=
  { Prod.seminormedGroup with }

/-! ### Finite product of normed groups -/


section Pi

variable {π : ι → Type _} [Fintype ι]

section SeminormedGroup

variable [∀ i, SeminormedGroup (π i)] [SeminormedGroup E] (f : ∀ i, π i) {x : ∀ i, π i} {r : ℝ}

/-- Finite product of seminormed groups, using the sup norm. -/
@[to_additive "Finite product of seminormed groups, using the sup norm."]
instance : SeminormedGroup (∀ i, π i)
    where
  norm f := ↑(Finset.univ.sup fun b => ‖f b‖₊)
  dist_eq x y :=
    congr_arg (coe : ℝ≥0 → ℝ) <|
      congr_arg (Finset.sup Finset.univ) <|
        funext fun a => show nndist (x a) (y a) = ‖x a / y a‖₊ from nndist_eq_nnnorm_div (x a) (y a)

#print Pi.norm_def' /-
@[to_additive Pi.norm_def]
theorem Pi.norm_def' : ‖f‖ = ↑(Finset.univ.sup fun b => ‖f b‖₊) :=
  rfl
#align pi.norm_def' Pi.norm_def'
#align pi.norm_def Pi.norm_def
-/

#print Pi.nnnorm_def' /-
@[to_additive Pi.nnnorm_def]
theorem Pi.nnnorm_def' : ‖f‖₊ = Finset.univ.sup fun b => ‖f b‖₊ :=
  Subtype.eta _ _
#align pi.nnnorm_def' Pi.nnnorm_def'
#align pi.nnnorm_def Pi.nnnorm_def
-/

#print pi_norm_le_iff_of_nonneg' /-
/-- The seminorm of an element in a product space is `≤ r` if and only if the norm of each
component is. -/
@[to_additive pi_norm_le_iff_of_nonneg
      "The seminorm of an element in a product space is `≤ r` if\nand only if the norm of each component is."]
theorem pi_norm_le_iff_of_nonneg' (hr : 0 ≤ r) : ‖x‖ ≤ r ↔ ∀ i, ‖x i‖ ≤ r := by
  simp only [← dist_one_right, dist_pi_le_iff hr, Pi.one_apply]
#align pi_norm_le_iff_of_nonneg' pi_norm_le_iff_of_nonneg'
#align pi_norm_le_iff_of_nonneg pi_norm_le_iff_of_nonneg
-/

#print pi_nnnorm_le_iff' /-
@[to_additive pi_nnnorm_le_iff]
theorem pi_nnnorm_le_iff' {r : ℝ≥0} : ‖x‖₊ ≤ r ↔ ∀ i, ‖x i‖₊ ≤ r :=
  pi_norm_le_iff_of_nonneg' r.coe_nonneg
#align pi_nnnorm_le_iff' pi_nnnorm_le_iff'
#align pi_nnnorm_le_iff pi_nnnorm_le_iff
-/

#print pi_norm_le_iff_of_nonempty' /-
@[to_additive pi_norm_le_iff_of_nonempty]
theorem pi_norm_le_iff_of_nonempty' [Nonempty ι] : ‖f‖ ≤ r ↔ ∀ b, ‖f b‖ ≤ r :=
  by
  by_cases hr : 0 ≤ r
  · exact pi_norm_le_iff_of_nonneg' hr
  ·
    exact
      iff_of_false (fun h => hr <| (norm_nonneg' _).trans h) fun h =>
        hr <| (norm_nonneg' _).trans <| h <| Classical.arbitrary _
#align pi_norm_le_iff_of_nonempty' pi_norm_le_iff_of_nonempty'
#align pi_norm_le_iff_of_nonempty pi_norm_le_iff_of_nonempty
-/

#print pi_norm_lt_iff' /-
/-- The seminorm of an element in a product space is `< r` if and only if the norm of each
component is. -/
@[to_additive pi_norm_lt_iff
      "The seminorm of an element in a product space is `< r` if and only if\nthe norm of each component is."]
theorem pi_norm_lt_iff' (hr : 0 < r) : ‖x‖ < r ↔ ∀ i, ‖x i‖ < r := by
  simp only [← dist_one_right, dist_pi_lt_iff hr, Pi.one_apply]
#align pi_norm_lt_iff' pi_norm_lt_iff'
#align pi_norm_lt_iff pi_norm_lt_iff
-/

#print pi_nnnorm_lt_iff' /-
@[to_additive pi_nnnorm_lt_iff]
theorem pi_nnnorm_lt_iff' {r : ℝ≥0} (hr : 0 < r) : ‖x‖₊ < r ↔ ∀ i, ‖x i‖₊ < r :=
  pi_norm_lt_iff' hr
#align pi_nnnorm_lt_iff' pi_nnnorm_lt_iff'
#align pi_nnnorm_lt_iff pi_nnnorm_lt_iff
-/

#print norm_le_pi_norm' /-
@[to_additive norm_le_pi_norm]
theorem norm_le_pi_norm' (i : ι) : ‖f i‖ ≤ ‖f‖ :=
  (pi_norm_le_iff_of_nonneg' <| norm_nonneg' _).1 le_rfl i
#align norm_le_pi_norm' norm_le_pi_norm'
#align norm_le_pi_norm norm_le_pi_norm
-/

#print nnnorm_le_pi_nnnorm' /-
@[to_additive nnnorm_le_pi_nnnorm]
theorem nnnorm_le_pi_nnnorm' (i : ι) : ‖f i‖₊ ≤ ‖f‖₊ :=
  norm_le_pi_norm' _ i
#align nnnorm_le_pi_nnnorm' nnnorm_le_pi_nnnorm'
#align nnnorm_le_pi_nnnorm nnnorm_le_pi_nnnorm
-/

#print pi_norm_const_le' /-
@[to_additive pi_norm_const_le]
theorem pi_norm_const_le' (a : E) : ‖fun _ : ι => a‖ ≤ ‖a‖ :=
  (pi_norm_le_iff_of_nonneg' <| norm_nonneg' _).2 fun _ => le_rfl
#align pi_norm_const_le' pi_norm_const_le'
#align pi_norm_const_le pi_norm_const_le
-/

#print pi_nnnorm_const_le' /-
@[to_additive pi_nnnorm_const_le]
theorem pi_nnnorm_const_le' (a : E) : ‖fun _ : ι => a‖₊ ≤ ‖a‖₊ :=
  pi_norm_const_le' _
#align pi_nnnorm_const_le' pi_nnnorm_const_le'
#align pi_nnnorm_const_le pi_nnnorm_const_le
-/

#print pi_norm_const' /-
@[simp, to_additive pi_norm_const]
theorem pi_norm_const' [Nonempty ι] (a : E) : ‖fun i : ι => a‖ = ‖a‖ := by
  simpa only [← dist_one_right] using dist_pi_const a 1
#align pi_norm_const' pi_norm_const'
#align pi_norm_const pi_norm_const
-/

#print pi_nnnorm_const' /-
@[simp, to_additive pi_nnnorm_const]
theorem pi_nnnorm_const' [Nonempty ι] (a : E) : ‖fun i : ι => a‖₊ = ‖a‖₊ :=
  NNReal.eq <| pi_norm_const' a
#align pi_nnnorm_const' pi_nnnorm_const'
#align pi_nnnorm_const pi_nnnorm_const
-/

#print Pi.sum_norm_apply_le_norm' /-
/-- The $L^1$ norm is less than the $L^\infty$ norm scaled by the cardinality. -/
@[to_additive Pi.sum_norm_apply_le_norm
      "The $L^1$ norm is less than the $L^\\infty$ norm scaled by\nthe cardinality."]
theorem Pi.sum_norm_apply_le_norm' : ∑ i, ‖f i‖ ≤ Fintype.card ι • ‖f‖ :=
  Finset.sum_le_card_nsmul _ _ _ fun i hi => norm_le_pi_norm' _ i
#align pi.sum_norm_apply_le_norm' Pi.sum_norm_apply_le_norm'
#align pi.sum_norm_apply_le_norm Pi.sum_norm_apply_le_norm
-/

#print Pi.sum_nnnorm_apply_le_nnnorm' /-
/-- The $L^1$ norm is less than the $L^\infty$ norm scaled by the cardinality. -/
@[to_additive Pi.sum_nnnorm_apply_le_nnnorm
      "The $L^1$ norm is less than the $L^\\infty$ norm scaled\nby the cardinality."]
theorem Pi.sum_nnnorm_apply_le_nnnorm' : ∑ i, ‖f i‖₊ ≤ Fintype.card ι • ‖f‖₊ :=
  NNReal.coe_sum.trans_le <| Pi.sum_norm_apply_le_norm' _
#align pi.sum_nnnorm_apply_le_nnnorm' Pi.sum_nnnorm_apply_le_nnnorm'
#align pi.sum_nnnorm_apply_le_nnnorm Pi.sum_nnnorm_apply_le_nnnorm
-/

end SeminormedGroup

#print Pi.seminormedCommGroup /-
/-- Finite product of seminormed groups, using the sup norm. -/
@[to_additive "Finite product of seminormed groups, using the sup norm."]
instance Pi.seminormedCommGroup [∀ i, SeminormedCommGroup (π i)] : SeminormedCommGroup (∀ i, π i) :=
  { Pi.seminormedGroup with }
#align pi.seminormed_comm_group Pi.seminormedCommGroup
#align pi.seminormed_add_comm_group Pi.seminormedAddCommGroup
-/

#print Pi.normedGroup /-
/-- Finite product of normed groups, using the sup norm. -/
@[to_additive "Finite product of seminormed groups, using the sup norm."]
instance Pi.normedGroup [∀ i, NormedGroup (π i)] : NormedGroup (∀ i, π i) :=
  { Pi.seminormedGroup with }
#align pi.normed_group Pi.normedGroup
#align pi.normed_add_group Pi.normedAddGroup
-/

#print Pi.normedCommGroup /-
/-- Finite product of normed groups, using the sup norm. -/
@[to_additive "Finite product of seminormed groups, using the sup norm."]
instance Pi.normedCommGroup [∀ i, NormedCommGroup (π i)] : NormedCommGroup (∀ i, π i) :=
  { Pi.seminormedGroup with }
#align pi.normed_comm_group Pi.normedCommGroup
#align pi.normed_add_comm_group Pi.normedAddCommGroup
-/

end Pi

/-! ### Multiplicative opposite -/


namespace MulOpposite

/-- The (additive) norm on the multiplicative opposite is the same as the norm on the original type.

Note that we do not provide this more generally as `has_norm Eᵐᵒᵖ`, as this is not always a good
choice of norm in the multiplicative `seminormed_group E` case.

We could repeat this instance to provide a `[seminormed_group E] : seminormed_group Eᵃᵒᵖ` instance,
but that case would likely never be used.
-/
instance [SeminormedAddGroup E] : SeminormedAddGroup Eᵐᵒᵖ
    where
  norm x := ‖x.unop‖
  dist_eq _ _ := dist_eq_norm _ _
  toPseudoMetricSpace := MulOpposite.pseudoMetricSpace

#print MulOpposite.norm_op /-
theorem norm_op [SeminormedAddGroup E] (a : E) : ‖MulOpposite.op a‖ = ‖a‖ :=
  rfl
#align mul_opposite.norm_op MulOpposite.norm_op
-/

#print MulOpposite.norm_unop /-
theorem norm_unop [SeminormedAddGroup E] (a : Eᵐᵒᵖ) : ‖MulOpposite.unop a‖ = ‖a‖ :=
  rfl
#align mul_opposite.norm_unop MulOpposite.norm_unop
-/

#print MulOpposite.nnnorm_op /-
theorem nnnorm_op [SeminormedAddGroup E] (a : E) : ‖MulOpposite.op a‖₊ = ‖a‖₊ :=
  rfl
#align mul_opposite.nnnorm_op MulOpposite.nnnorm_op
-/

#print MulOpposite.nnnorm_unop /-
theorem nnnorm_unop [SeminormedAddGroup E] (a : Eᵐᵒᵖ) : ‖MulOpposite.unop a‖₊ = ‖a‖₊ :=
  rfl
#align mul_opposite.nnnorm_unop MulOpposite.nnnorm_unop
-/

instance [NormedAddGroup E] : NormedAddGroup Eᵐᵒᵖ :=
  { MulOpposite.seminormedAddGroup with }

instance [SeminormedAddCommGroup E] : SeminormedAddCommGroup Eᵐᵒᵖ
    where dist_eq _ _ := dist_eq_norm _ _

instance [NormedAddCommGroup E] : NormedAddCommGroup Eᵐᵒᵖ :=
  { MulOpposite.seminormedAddCommGroup with }

end MulOpposite

/-! ### Subgroups of normed groups -/


namespace Subgroup

section SeminormedGroup

variable [SeminormedGroup E] {s : Subgroup E}

#print Subgroup.seminormedGroup /-
/-- A subgroup of a seminormed group is also a seminormed group,
with the restriction of the norm. -/
@[to_additive
      "A subgroup of a seminormed group is also a seminormed group,\nwith the restriction of the norm."]
instance seminormedGroup : SeminormedGroup s :=
  SeminormedGroup.induced _ _ s.Subtype
#align subgroup.seminormed_group Subgroup.seminormedGroup
#align add_subgroup.seminormed_add_group AddSubgroup.seminormedAddGroup
-/

#print Subgroup.coe_norm /-
/-- If `x` is an element of a subgroup `s` of a seminormed group `E`, its norm in `s` is equal to
its norm in `E`. -/
@[simp,
  to_additive
      "If `x` is an element of a subgroup `s` of a seminormed group `E`, its norm in\n`s` is equal to its norm in `E`."]
theorem coe_norm (x : s) : ‖x‖ = ‖(x : E)‖ :=
  rfl
#align subgroup.coe_norm Subgroup.coe_norm
#align add_subgroup.coe_norm AddSubgroup.coe_norm
-/

#print Subgroup.norm_coe /-
/-- If `x` is an element of a subgroup `s` of a seminormed group `E`, its norm in `s` is equal to
its norm in `E`.

This is a reversed version of the `simp` lemma `subgroup.coe_norm` for use by `norm_cast`. -/
@[norm_cast,
  to_additive
      "If `x` is an element of a subgroup `s` of a seminormed group `E`, its norm\nin `s` is equal to its norm in `E`.\n\nThis is a reversed version of the `simp` lemma `add_subgroup.coe_norm` for use by `norm_cast`."]
theorem norm_coe {s : Subgroup E} (x : s) : ‖(x : E)‖ = ‖x‖ :=
  rfl
#align subgroup.norm_coe Subgroup.norm_coe
#align add_subgroup.norm_coe AddSubgroup.norm_coe
-/

end SeminormedGroup

#print Subgroup.seminormedCommGroup /-
@[to_additive]
instance seminormedCommGroup [SeminormedCommGroup E] {s : Subgroup E} : SeminormedCommGroup s :=
  SeminormedCommGroup.induced _ _ s.Subtype
#align subgroup.seminormed_comm_group Subgroup.seminormedCommGroup
#align add_subgroup.seminormed_add_comm_group AddSubgroup.seminormedAddCommGroup
-/

#print Subgroup.normedGroup /-
@[to_additive]
instance normedGroup [NormedGroup E] {s : Subgroup E} : NormedGroup s :=
  NormedGroup.induced _ _ s.Subtype Subtype.coe_injective
#align subgroup.normed_group Subgroup.normedGroup
#align add_subgroup.normed_add_group AddSubgroup.normedAddGroup
-/

#print Subgroup.normedCommGroup /-
@[to_additive]
instance normedCommGroup [NormedCommGroup E] {s : Subgroup E} : NormedCommGroup s :=
  NormedCommGroup.induced _ _ s.Subtype Subtype.coe_injective
#align subgroup.normed_comm_group Subgroup.normedCommGroup
#align add_subgroup.normed_add_comm_group AddSubgroup.normedAddCommGroup
-/

end Subgroup

/-! ### Submodules of normed groups -/


namespace Submodule

#print Submodule.seminormedAddCommGroup /-
-- See note [implicit instance arguments]
/-- A submodule of a seminormed group is also a seminormed group, with the restriction of the norm.
-/
instance seminormedAddCommGroup {_ : Ring 𝕜} [SeminormedAddCommGroup E] {_ : Module 𝕜 E}
    (s : Submodule 𝕜 E) : SeminormedAddCommGroup s :=
  SeminormedAddCommGroup.induced _ _ s.Subtype.toAddMonoidHom
#align submodule.seminormed_add_comm_group Submodule.seminormedAddCommGroup
-/

#print Submodule.coe_norm /-
-- See note [implicit instance arguments].
/-- If `x` is an element of a submodule `s` of a normed group `E`, its norm in `s` is equal to its
norm in `E`. -/
@[simp]
theorem coe_norm {_ : Ring 𝕜} [SeminormedAddCommGroup E] {_ : Module 𝕜 E} {s : Submodule 𝕜 E}
    (x : s) : ‖x‖ = ‖(x : E)‖ :=
  rfl
#align submodule.coe_norm Submodule.coe_norm
-/

#print Submodule.norm_coe /-
-- See note [implicit instance arguments].
/-- If `x` is an element of a submodule `s` of a normed group `E`, its norm in `E` is equal to its
norm in `s`.

This is a reversed version of the `simp` lemma `submodule.coe_norm` for use by `norm_cast`. -/
@[norm_cast]
theorem norm_coe {_ : Ring 𝕜} [SeminormedAddCommGroup E] {_ : Module 𝕜 E} {s : Submodule 𝕜 E}
    (x : s) : ‖(x : E)‖ = ‖x‖ :=
  rfl
#align submodule.norm_coe Submodule.norm_coe
-/

-- See note [implicit instance arguments].
/-- A submodule of a normed group is also a normed group, with the restriction of the norm. -/
instance {_ : Ring 𝕜} [NormedAddCommGroup E] {_ : Module 𝕜 E} (s : Submodule 𝕜 E) :
    NormedAddCommGroup s :=
  { Submodule.seminormedAddCommGroup s with }

end Submodule

