/-
Copyright (c) 2020 Alena Gusakov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alena Gusakov, Arthur Paulino, Kyle Miller

! This file was ported from Lean 3 source module combinatorics.simple_graph.matching
! leanprover-community/mathlib commit 31ca6f9cf5f90a6206092cd7f84b359dcb6d52e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Combinatorics.SimpleGraph.DegreeSum
import Mathbin.Combinatorics.SimpleGraph.Subgraph

/-!
# Matchings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A *matching* for a simple graph is a set of disjoint pairs of adjacent vertices, and the set of all
the vertices in a matching is called its *support* (and sometimes the vertices in the support are
said to be *saturated* by the matching). A *perfect matching* is a matching whose support contains
every vertex of the graph.

In this module, we represent a matching as a subgraph whose vertices are each incident to at most
one edge, and the edges of the subgraph represent the paired vertices.

## Main definitions

* `simple_graph.subgraph.is_matching`: `M.is_matching` means that `M` is a matching of its
  underlying graph.
  denoted `M.is_matching`.

* `simple_graph.subgraph.is_perfect_matching` defines when a subgraph `M` of a simple graph is a
  perfect matching, denoted `M.is_perfect_matching`.

## TODO

* Define an `other` function and prove useful results about it (https://leanprover.zulipchat.com/#narrow/stream/252551-graph-theory/topic/matchings/near/266205863)

* Provide a bicoloring for matchings (https://leanprover.zulipchat.com/#narrow/stream/252551-graph-theory/topic/matchings/near/265495120)

* Tutte's Theorem

* Hall's Marriage Theorem (see combinatorics.hall)
-/


universe u

namespace SimpleGraph

variable {V : Type u} {G : SimpleGraph V} (M : Subgraph G)

namespace Subgraph

#print SimpleGraph.Subgraph.IsMatching /-
/--
The subgraph `M` of `G` is a matching if every vertex of `M` is incident to exactly one edge in `M`.
We say that the vertices in `M.support` are *matched* or *saturated*.
-/
def IsMatching : Prop :=
  ∀ ⦃v⦄, v ∈ M.verts → ∃! w, M.Adj v w
#align simple_graph.subgraph.is_matching SimpleGraph.Subgraph.IsMatching
-/

#print SimpleGraph.Subgraph.IsMatching.toEdge /-
/-- Given a vertex, returns the unique edge of the matching it is incident to. -/
noncomputable def IsMatching.toEdge {M : Subgraph G} (h : M.IsMatching) (v : M.verts) :
    M.edgeSetEmbedding :=
  ⟨⟦(v, (h v.property).some)⟧, (h v.property).choose_spec.1⟩
#align simple_graph.subgraph.is_matching.to_edge SimpleGraph.Subgraph.IsMatching.toEdge
-/

#print SimpleGraph.Subgraph.IsMatching.toEdge_eq_of_adj /-
theorem IsMatching.toEdge_eq_of_adj {M : Subgraph G} (h : M.IsMatching) {v w : V} (hv : v ∈ M.verts)
    (hvw : M.Adj v w) : h.toEdge ⟨v, hv⟩ = ⟨⟦(v, w)⟧, hvw⟩ :=
  by
  simp only [is_matching.to_edge, Subtype.mk_eq_mk]
  congr
  exact ((h (M.edge_vert hvw)).choose_spec.2 w hvw).symm
#align simple_graph.subgraph.is_matching.to_edge_eq_of_adj SimpleGraph.Subgraph.IsMatching.toEdge_eq_of_adj
-/

#print SimpleGraph.Subgraph.IsMatching.toEdge.surjective /-
theorem IsMatching.toEdge.surjective {M : Subgraph G} (h : M.IsMatching) :
    Function.Surjective h.toEdge := by
  rintro ⟨e, he⟩
  refine' Sym2.ind (fun x y he => _) e he
  exact ⟨⟨x, M.edge_vert he⟩, h.to_edge_eq_of_adj _ he⟩
#align simple_graph.subgraph.is_matching.to_edge.surjective SimpleGraph.Subgraph.IsMatching.toEdge.surjective
-/

#print SimpleGraph.Subgraph.IsMatching.toEdge_eq_toEdge_of_adj /-
theorem IsMatching.toEdge_eq_toEdge_of_adj {M : Subgraph G} {v w : V} (h : M.IsMatching)
    (hv : v ∈ M.verts) (hw : w ∈ M.verts) (ha : M.Adj v w) : h.toEdge ⟨v, hv⟩ = h.toEdge ⟨w, hw⟩ :=
  by
  rw [h.to_edge_eq_of_adj hv ha, h.to_edge_eq_of_adj hw (M.symm ha), Subtype.mk_eq_mk, Sym2.eq_swap]
#align simple_graph.subgraph.is_matching.to_edge_eq_to_edge_of_adj SimpleGraph.Subgraph.IsMatching.toEdge_eq_toEdge_of_adj
-/

#print SimpleGraph.Subgraph.IsPerfectMatching /-
/-- The subgraph `M` of `G` is a perfect matching on `G` if it's a matching and every vertex `G` is
matched.
-/
def IsPerfectMatching : Prop :=
  M.IsMatching ∧ M.IsSpanning
#align simple_graph.subgraph.is_perfect_matching SimpleGraph.Subgraph.IsPerfectMatching
-/

#print SimpleGraph.Subgraph.IsMatching.support_eq_verts /-
theorem IsMatching.support_eq_verts {M : Subgraph G} (h : M.IsMatching) : M.support = M.verts :=
  by
  refine' M.support_subset_verts.antisymm fun v hv => _
  obtain ⟨w, hvw, -⟩ := h hv
  exact ⟨_, hvw⟩
#align simple_graph.subgraph.is_matching.support_eq_verts SimpleGraph.Subgraph.IsMatching.support_eq_verts
-/

#print SimpleGraph.Subgraph.isMatching_iff_forall_degree /-
theorem isMatching_iff_forall_degree {M : Subgraph G} [∀ v : V, Fintype (M.neighborSet v)] :
    M.IsMatching ↔ ∀ v : V, v ∈ M.verts → M.degree v = 1 := by simpa [degree_eq_one_iff_unique_adj]
#align simple_graph.subgraph.is_matching_iff_forall_degree SimpleGraph.Subgraph.isMatching_iff_forall_degree
-/

#print SimpleGraph.Subgraph.IsMatching.even_card /-
theorem IsMatching.even_card {M : Subgraph G} [Fintype M.verts] (h : M.IsMatching) :
    Even M.verts.toFinset.card := by
  classical
  rw [is_matching_iff_forall_degree] at h 
  use M.coe.edge_finset.card
  rw [← two_mul, ← M.coe.sum_degrees_eq_twice_card_edges]
  simp [h, Finset.card_univ]
#align simple_graph.subgraph.is_matching.even_card SimpleGraph.Subgraph.IsMatching.even_card
-/

#print SimpleGraph.Subgraph.isPerfectMatching_iff /-
theorem isPerfectMatching_iff : M.IsPerfectMatching ↔ ∀ v, ∃! w, M.Adj v w :=
  by
  refine' ⟨_, fun hm => ⟨fun v hv => hm v, fun v => _⟩⟩
  · rintro ⟨hm, hs⟩ v
    exact hm (hs v)
  · obtain ⟨w, hw, -⟩ := hm v
    exact M.edge_vert hw
#align simple_graph.subgraph.is_perfect_matching_iff SimpleGraph.Subgraph.isPerfectMatching_iff
-/

#print SimpleGraph.Subgraph.isPerfectMatching_iff_forall_degree /-
theorem isPerfectMatching_iff_forall_degree {M : Subgraph G} [∀ v, Fintype (M.neighborSet v)] :
    M.IsPerfectMatching ↔ ∀ v, M.degree v = 1 := by
  simp [degree_eq_one_iff_unique_adj, is_perfect_matching_iff]
#align simple_graph.subgraph.is_perfect_matching_iff_forall_degree SimpleGraph.Subgraph.isPerfectMatching_iff_forall_degree
-/

#print SimpleGraph.Subgraph.IsPerfectMatching.even_card /-
theorem IsPerfectMatching.even_card {M : Subgraph G} [Fintype V] (h : M.IsPerfectMatching) :
    Even (Fintype.card V) := by classical simpa [h.2.card_verts] using is_matching.even_card h.1
#align simple_graph.subgraph.is_perfect_matching.even_card SimpleGraph.Subgraph.IsPerfectMatching.even_card
-/

end Subgraph

end SimpleGraph

