/-
Copyright (c) 2019 Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot

! This file was ported from Lean 3 source module topology.uniform_space.pi
! leanprover-community/mathlib commit 0a0ec35061ed9960bf0e7ffb0335f44447b58977
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.UniformSpace.Cauchy
import Mathbin.Topology.UniformSpace.Separation

/-!
# Indexed product of uniform spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


noncomputable section

open scoped uniformity Topology

section

open Filter UniformSpace

universe u

variable {ι : Type _} (α : ι → Type u) [U : ∀ i, UniformSpace (α i)]

#print Pi.uniformSpace /-
instance Pi.uniformSpace : UniformSpace (∀ i, α i) :=
  UniformSpace.ofCoreEq (⨅ i, UniformSpace.comap (fun a : ∀ i, α i => a i) (U i)).toCore
      Pi.topologicalSpace <|
    Eq.symm toTopologicalSpace_iInf
#align Pi.uniform_space Pi.uniformSpace
-/

#print Pi.uniformity /-
theorem Pi.uniformity : 𝓤 (∀ i, α i) = ⨅ i : ι, (Filter.comap fun a => (a.1 i, a.2 i)) <| 𝓤 (α i) :=
  iInf_uniformity
#align Pi.uniformity Pi.uniformity
-/

variable {α}

#print uniformContinuous_pi /-
theorem uniformContinuous_pi {β : Type _} [UniformSpace β] {f : β → ∀ i, α i} :
    UniformContinuous f ↔ ∀ i, UniformContinuous fun x => f x i := by
  simp only [UniformContinuous, Pi.uniformity, tendsto_infi, tendsto_comap_iff]
#align uniform_continuous_pi uniformContinuous_pi
-/

variable (α)

#print Pi.uniformContinuous_proj /-
theorem Pi.uniformContinuous_proj (i : ι) : UniformContinuous fun a : ∀ i : ι, α i => a i :=
  uniformContinuous_pi.1 uniformContinuous_id i
#align Pi.uniform_continuous_proj Pi.uniformContinuous_proj
-/

#print Pi.complete /-
instance Pi.complete [∀ i, CompleteSpace (α i)] : CompleteSpace (∀ i, α i) :=
  ⟨by
    intro f hf
    haveI := hf.1
    have : ∀ i, ∃ x : α i, Filter.map (fun a : ∀ i, α i => a i) f ≤ 𝓝 x :=
      by
      intro i
      have key : Cauchy (map (fun a : ∀ i : ι, α i => a i) f) :=
        hf.map (Pi.uniformContinuous_proj α i)
      exact cauchy_iff_exists_le_nhds.1 key
    choose x hx using this
    use x
    rwa [nhds_pi, le_pi]⟩
#align Pi.complete Pi.complete
-/

#print Pi.separated /-
instance Pi.separated [∀ i, SeparatedSpace (α i)] : SeparatedSpace (∀ i, α i) :=
  separated_def.2 fun x y H => by
    ext i
    apply eq_of_separated_of_uniform_continuous (Pi.uniformContinuous_proj α i)
    apply H
#align Pi.separated Pi.separated
-/

end

