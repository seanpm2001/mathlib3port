/-
Copyright (c) 2020 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Anatole Dedecker

! This file was ported from Lean 3 source module topology.extend_from
! leanprover-community/mathlib commit 0a0ec35061ed9960bf0e7ffb0335f44447b58977
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Separation

/-!
# Extending a function from a subset

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The main definition of this file is `extend_from A f` where `f : X → Y`
and `A : set X`. This defines a new function `g : X → Y` which maps any
`x₀ : X` to the limit of `f` as `x` tends to `x₀`, if such a limit exists.

This is analoguous to the way `dense_inducing.extend` "extends" a function
`f : X → Z` to a function `g : Y → Z` along a dense inducing `i : X → Y`.

The main theorem we prove about this definition is `continuous_on_extend_from`
which states that, for `extend_from A f` to be continuous on a set `B ⊆ closure A`,
it suffices that `f` converges within `A` at any point of `B`, provided that
`f` is a function to a T₃ space.

-/


noncomputable section

open scoped Topology

open Filter Set

variable {X Y : Type _} [TopologicalSpace X] [TopologicalSpace Y]

#print extendFrom /-
/-- Extend a function from a set `A`. The resulting function `g` is such that
at any `x₀`, if `f` converges to some `y` as `x` tends to `x₀` within `A`,
then `g x₀` is defined to be one of these `y`. Else, `g x₀` could be anything. -/
def extendFrom (A : Set X) (f : X → Y) : X → Y := fun x => @limUnder _ ⟨f x⟩ (𝓝[A] x) f
#align extend_from extendFrom
-/

#print tendsto_extendFrom /-
/-- If `f` converges to some `y` as `x` tends to `x₀` within `A`,
then `f` tends to `extend_from A f x` as `x` tends to `x₀`. -/
theorem tendsto_extendFrom {A : Set X} {f : X → Y} {x : X} (h : ∃ y, Tendsto f (𝓝[A] x) (𝓝 y)) :
    Tendsto f (𝓝[A] x) (𝓝 <| extendFrom A f x) :=
  tendsto_nhds_limUnder h
#align tendsto_extend_from tendsto_extendFrom
-/

#print extendFrom_eq /-
theorem extendFrom_eq [T2Space Y] {A : Set X} {f : X → Y} {x : X} {y : Y} (hx : x ∈ closure A)
    (hf : Tendsto f (𝓝[A] x) (𝓝 y)) : extendFrom A f x = y :=
  haveI := mem_closure_iff_nhds_within_ne_bot.mp hx
  tendsto_nhds_unique (tendsto_nhds_limUnder ⟨y, hf⟩) hf
#align extend_from_eq extendFrom_eq
-/

#print extendFrom_extends /-
theorem extendFrom_extends [T2Space Y] {f : X → Y} {A : Set X} (hf : ContinuousOn f A) :
    ∀ x ∈ A, extendFrom A f x = f x := fun x x_in => extendFrom_eq (subset_closure x_in) (hf x x_in)
#align extend_from_extends extendFrom_extends
-/

#print continuousOn_extendFrom /-
/-- If `f` is a function to a T₃ space `Y` which has a limit within `A` at any
point of a set `B ⊆ closure A`, then `extend_from A f` is continuous on `B`. -/
theorem continuousOn_extendFrom [RegularSpace Y] {f : X → Y} {A B : Set X} (hB : B ⊆ closure A)
    (hf : ∀ x ∈ B, ∃ y, Tendsto f (𝓝[A] x) (𝓝 y)) : ContinuousOn (extendFrom A f) B :=
  by
  set φ := extendFrom A f
  intro x x_in
  suffices ∀ V' ∈ 𝓝 (φ x), IsClosed V' → φ ⁻¹' V' ∈ 𝓝[B] x by
    simpa [ContinuousWithinAt, (closed_nhds_basis _).tendsto_right_iff]
  intro V' V'_in V'_closed
  obtain ⟨V, V_in, V_op, hV⟩ : ∃ V ∈ 𝓝 x, IsOpen V ∧ V ∩ A ⊆ f ⁻¹' V' :=
    by
    have := tendsto_extendFrom (hf x x_in)
    rcases(nhdsWithin_basis_open x A).tendsto_left_iffₓ.mp this V' V'_in with ⟨V, ⟨hxV, V_op⟩, hV⟩
    use V, IsOpen.mem_nhds V_op hxV, V_op, hV
  suffices : ∀ y ∈ V ∩ B, φ y ∈ V'
  exact mem_of_superset (inter_mem_inf V_in <| mem_principal_self B) this
  rintro y ⟨hyV, hyB⟩
  haveI := mem_closure_iff_nhds_within_ne_bot.mp (hB hyB)
  have limy : tendsto f (𝓝[A] y) (𝓝 <| φ y) := tendsto_extendFrom (hf y hyB)
  have hVy : V ∈ 𝓝 y := IsOpen.mem_nhds V_op hyV
  have : V ∩ A ∈ 𝓝[A] y := by simpa [inter_comm] using inter_mem_nhdsWithin _ hVy
  exact V'_closed.mem_of_tendsto limy (mem_of_superset this hV)
#align continuous_on_extend_from continuousOn_extendFrom
-/

#print continuous_extendFrom /-
/-- If a function `f` to a T₃ space `Y` has a limit within a
dense set `A` for any `x`, then `extend_from A f` is continuous. -/
theorem continuous_extendFrom [RegularSpace Y] {f : X → Y} {A : Set X} (hA : Dense A)
    (hf : ∀ x, ∃ y, Tendsto f (𝓝[A] x) (𝓝 y)) : Continuous (extendFrom A f) :=
  by
  rw [continuous_iff_continuousOn_univ]
  exact continuousOn_extendFrom (fun x _ => hA x) (by simpa using hf)
#align continuous_extend_from continuous_extendFrom
-/

