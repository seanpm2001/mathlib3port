/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module topology.algebra.order.group
! leanprover-community/mathlib commit 3dadefa3f544b1db6214777fe47910739b54c66a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Order.Basic
import Mathbin.Topology.Algebra.Group.Basic

/-!
# Topology on a linear ordered additive commutative group

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that a linear ordered additive commutative group with order topology is a
topological group. We also prove continuity of `abs : G → G` and provide convenience lemmas like
`continuous_at.abs`.
-/


open Set Filter

open scoped Topology Filter

variable {α G : Type _} [TopologicalSpace G] [LinearOrderedAddCommGroup G] [OrderTopology G]

variable {l : Filter α} {f g : α → G}

#print LinearOrderedAddCommGroup.topologicalAddGroup /-
-- see Note [lower instance priority]
instance (priority := 100) LinearOrderedAddCommGroup.topologicalAddGroup : TopologicalAddGroup G
    where
  continuous_add := by
    refine' continuous_iff_continuousAt.2 _
    rintro ⟨a, b⟩
    refine' LinearOrderedAddCommGroup.tendsto_nhds.2 fun ε ε0 => _
    rcases dense_or_discrete 0 ε with (⟨δ, δ0, δε⟩ | ⟨h₁, h₂⟩)
    · -- If there exists `δ ∈ (0, ε)`, then we choose `δ`-nhd of `a` and `(ε-δ)`-nhd of `b`
      filter_upwards [(eventually_abs_sub_lt a δ0).prod_nhds
          (eventually_abs_sub_lt b (sub_pos.2 δε))]
      rintro ⟨x, y⟩ ⟨hx : |x - a| < δ, hy : |y - b| < ε - δ⟩
      rw [add_sub_add_comm]
      calc
        |x - a + (y - b)| ≤ |x - a| + |y - b| := abs_add _ _
        _ < δ + (ε - δ) := (add_lt_add hx hy)
        _ = ε := add_sub_cancel'_right _ _
    · -- Otherwise `ε`-nhd of each point `a` is `{a}`
      have hε : ∀ {x y}, |x - y| < ε → x = y :=
        by
        intro x y h
        simpa [sub_eq_zero] using h₂ _ h
      filter_upwards [(eventually_abs_sub_lt a ε0).prod_nhds (eventually_abs_sub_lt b ε0)]
      rintro ⟨x, y⟩ ⟨hx : |x - a| < ε, hy : |y - b| < ε⟩
      simpa [hε hx, hε hy]
  continuous_neg :=
    continuous_iff_continuousAt.2 fun a =>
      LinearOrderedAddCommGroup.tendsto_nhds.2 fun ε ε0 =>
        (eventually_abs_sub_lt a ε0).mono fun x hx => by rwa [neg_sub_neg, abs_sub_comm]
#align linear_ordered_add_comm_group.topological_add_group LinearOrderedAddCommGroup.topologicalAddGroup
-/

#print continuous_abs /-
@[continuity]
theorem continuous_abs : Continuous (abs : G → G) :=
  continuous_id.max continuous_neg
#align continuous_abs continuous_abs
-/

#print Filter.Tendsto.abs /-
protected theorem Filter.Tendsto.abs {a : G} (h : Tendsto f l (𝓝 a)) :
    Tendsto (fun x => |f x|) l (𝓝 (|a|)) :=
  (continuous_abs.Tendsto _).comp h
#align filter.tendsto.abs Filter.Tendsto.abs
-/

#print tendsto_zero_iff_abs_tendsto_zero /-
theorem tendsto_zero_iff_abs_tendsto_zero (f : α → G) :
    Tendsto f l (𝓝 0) ↔ Tendsto (abs ∘ f) l (𝓝 0) :=
  by
  refine' ⟨fun h => (abs_zero : |(0 : G)| = 0) ▸ h.abs, fun h => _⟩
  have : tendsto (fun a => -|f a|) l (𝓝 0) := (neg_zero : -(0 : G) = 0) ▸ h.neg
  exact
    tendsto_of_tendsto_of_tendsto_of_le_of_le this h (fun x => neg_abs_le_self <| f x) fun x =>
      le_abs_self <| f x
#align tendsto_zero_iff_abs_tendsto_zero tendsto_zero_iff_abs_tendsto_zero
-/

variable [TopologicalSpace α] {a : α} {s : Set α}

#print Continuous.abs /-
protected theorem Continuous.abs (h : Continuous f) : Continuous fun x => |f x| :=
  continuous_abs.comp h
#align continuous.abs Continuous.abs
-/

#print ContinuousAt.abs /-
protected theorem ContinuousAt.abs (h : ContinuousAt f a) : ContinuousAt (fun x => |f x|) a :=
  h.abs
#align continuous_at.abs ContinuousAt.abs
-/

#print ContinuousWithinAt.abs /-
protected theorem ContinuousWithinAt.abs (h : ContinuousWithinAt f s a) :
    ContinuousWithinAt (fun x => |f x|) s a :=
  h.abs
#align continuous_within_at.abs ContinuousWithinAt.abs
-/

#print ContinuousOn.abs /-
protected theorem ContinuousOn.abs (h : ContinuousOn f s) : ContinuousOn (fun x => |f x|) s :=
  fun x hx => (h x hx).abs
#align continuous_on.abs ContinuousOn.abs
-/

#print tendsto_abs_nhdsWithin_zero /-
theorem tendsto_abs_nhdsWithin_zero : Tendsto (abs : G → G) (𝓝[≠] 0) (𝓝[>] 0) :=
  (continuous_abs.tendsto' (0 : G) 0 abs_zero).inf <|
    tendsto_principal_principal.2 fun x => abs_pos.2
#align tendsto_abs_nhds_within_zero tendsto_abs_nhdsWithin_zero
-/

