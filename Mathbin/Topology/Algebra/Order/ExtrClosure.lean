/-
Copyright (c) 2022 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module topology.algebra.order.extr_closure
! leanprover-community/mathlib commit 50832daea47b195a48b5b33b1c8b2162c48c3afc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.LocalExtr
import Mathbin.Topology.Order.Basic

/-!
# Maximum/minimum on the closure of a set

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove several versions of the following statement: if `f : X → Y` has a (local or
not) maximum (or minimum) on a set `s` at a point `a` and is continuous on the closure of `s`, then
`f` has an extremum of the same type on `closure s` at `a`.
-/


open Filter Set

open scoped Topology

variable {X Y : Type _} [TopologicalSpace X] [TopologicalSpace Y] [Preorder Y]
  [OrderClosedTopology Y] {f g : X → Y} {s : Set X} {a : X}

#print IsMaxOn.closure /-
protected theorem IsMaxOn.closure (h : IsMaxOn f s a) (hc : ContinuousOn f (closure s)) :
    IsMaxOn f (closure s) a := fun x hx =>
  ContinuousWithinAt.closure_le hx ((hc x hx).mono subset_closure) continuousWithinAt_const h
#align is_max_on.closure IsMaxOn.closure
-/

#print IsMinOn.closure /-
protected theorem IsMinOn.closure (h : IsMinOn f s a) (hc : ContinuousOn f (closure s)) :
    IsMinOn f (closure s) a :=
  h.dual.closure hc
#align is_min_on.closure IsMinOn.closure
-/

#print IsExtrOn.closure /-
protected theorem IsExtrOn.closure (h : IsExtrOn f s a) (hc : ContinuousOn f (closure s)) :
    IsExtrOn f (closure s) a :=
  h.elim (fun h => Or.inl <| h.closure hc) fun h => Or.inr <| h.closure hc
#align is_extr_on.closure IsExtrOn.closure
-/

#print IsLocalMaxOn.closure /-
protected theorem IsLocalMaxOn.closure (h : IsLocalMaxOn f s a) (hc : ContinuousOn f (closure s)) :
    IsLocalMaxOn f (closure s) a :=
  by
  rcases mem_nhdsWithin.1 h with ⟨U, Uo, aU, hU⟩
  refine' mem_nhdsWithin.2 ⟨U, Uo, aU, _⟩
  rintro x ⟨hxU, hxs⟩
  refine' ContinuousWithinAt.closure_le _ _ continuousWithinAt_const hU
  · rwa [mem_closure_iff_nhdsWithin_neBot, nhdsWithin_inter_of_mem, ←
      mem_closure_iff_nhdsWithin_neBot]
    exact nhdsWithin_le_nhds (Uo.mem_nhds hxU)
  · exact (hc _ hxs).mono ((inter_subset_right _ _).trans subset_closure)
#align is_local_max_on.closure IsLocalMaxOn.closure
-/

#print IsLocalMinOn.closure /-
protected theorem IsLocalMinOn.closure (h : IsLocalMinOn f s a) (hc : ContinuousOn f (closure s)) :
    IsLocalMinOn f (closure s) a :=
  IsLocalMaxOn.closure h.dual hc
#align is_local_min_on.closure IsLocalMinOn.closure
-/

#print IsLocalExtrOn.closure /-
protected theorem IsLocalExtrOn.closure (h : IsLocalExtrOn f s a)
    (hc : ContinuousOn f (closure s)) : IsLocalExtrOn f (closure s) a :=
  h.elim (fun h => Or.inl <| h.closure hc) fun h => Or.inr <| h.closure hc
#align is_local_extr_on.closure IsLocalExtrOn.closure
-/

