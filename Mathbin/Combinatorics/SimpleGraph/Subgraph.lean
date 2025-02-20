/-
Copyright (c) 2021 Hunter Monroe. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Hunter Monroe, Kyle Miller, Alena Gusakov

! This file was ported from Lean 3 source module combinatorics.simple_graph.subgraph
! leanprover-community/mathlib commit c6ef6387ede9983aee397d442974e61f89dfd87b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Combinatorics.SimpleGraph.Basic

/-!
# Subgraphs of a simple graph

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A subgraph of a simple graph consists of subsets of the graph's vertices and edges such that the
endpoints of each edge are present in the vertex subset. The edge subset is formalized as a
sub-relation of the adjacency relation of the simple graph.

## Main definitions

* `subgraph G` is the type of subgraphs of a `G : simple_graph`

* `subgraph.neighbor_set`, `subgraph.incidence_set`, and `subgraph.degree` are like their
  `simple_graph` counterparts, but they refer to vertices from `G` to avoid subtype coercions.

* `subgraph.coe` is the coercion from a `G' : subgraph G` to a `simple_graph G'.verts`.
  (This cannot be a `has_coe` instance since the destination type depends on `G'`.)

* `subgraph.is_spanning` for whether a subgraph is a spanning subgraph and
  `subgraph.is_induced` for whether a subgraph is an induced subgraph.

* Instances for `lattice (subgraph G)` and `bounded_order (subgraph G)`.

* `simple_graph.to_subgraph`: If a `simple_graph` is a subgraph of another, then you can turn it
  into a member of the larger graph's `simple_graph.subgraph` type.

* Graph homomorphisms from a subgraph to a graph (`subgraph.map_top`) and between subgraphs
  (`subgraph.map`).

## Implementation notes

* Recall that subgraphs are not determined by their vertex sets, so `set_like` does not apply to
  this kind of subobject.

## Todo

* Images of graph homomorphisms as subgraphs.

-/


universe u v

namespace SimpleGraph

#print SimpleGraph.Subgraph /-
/-- A subgraph of a `simple_graph` is a subset of vertices along with a restriction of the adjacency
relation that is symmetric and is supported by the vertex subset.  They also form a bounded lattice.

Thinking of `V → V → Prop` as `set (V × V)`, a set of darts (i.e., half-edges), then
`subgraph.adj_sub` is that the darts of a subgraph are a subset of the darts of `G`. -/
@[ext]
structure Subgraph {V : Type u} (G : SimpleGraph V) where
  verts : Set V
  Adj : V → V → Prop
  adj_sub : ∀ {v w : V}, adj v w → G.Adj v w
  edge_vert : ∀ {v w : V}, adj v w → v ∈ verts
  symm : Symmetric adj := by obviously
#align simple_graph.subgraph SimpleGraph.Subgraph
-/

variable {ι : Sort _} {V : Type u} {W : Type v}

#print SimpleGraph.singletonSubgraph /-
/-- The one-vertex subgraph. -/
@[simps]
protected def singletonSubgraph (G : SimpleGraph V) (v : V) : G.Subgraph
    where
  verts := {v}
  Adj := ⊥
  adj_sub := by simp [-Set.bot_eq_empty]
  edge_vert := by simp [-Set.bot_eq_empty]
#align simple_graph.singleton_subgraph SimpleGraph.singletonSubgraph
-/

#print SimpleGraph.subgraphOfAdj /-
/-- The one-edge subgraph. -/
@[simps]
def subgraphOfAdj (G : SimpleGraph V) {v w : V} (hvw : G.Adj v w) : G.Subgraph
    where
  verts := {v, w}
  Adj a b := ⟦(v, w)⟧ = ⟦(a, b)⟧
  adj_sub a b h := by rw [← G.mem_edge_set, ← h]; exact hvw
  edge_vert a b h := by apply_fun fun e => a ∈ e at h ; simpa using h
#align simple_graph.subgraph_of_adj SimpleGraph.subgraphOfAdj
-/

namespace Subgraph

variable {G : SimpleGraph V} {G₁ G₂ : G.Subgraph} {a b : V}

#print SimpleGraph.Subgraph.loopless /-
protected theorem loopless (G' : Subgraph G) : Irreflexive G'.Adj := fun v h =>
  G.loopless v (G'.adj_sub h)
#align simple_graph.subgraph.loopless SimpleGraph.Subgraph.loopless
-/

#print SimpleGraph.Subgraph.adj_comm /-
theorem adj_comm (G' : Subgraph G) (v w : V) : G'.Adj v w ↔ G'.Adj w v :=
  ⟨fun x => G'.symm x, fun x => G'.symm x⟩
#align simple_graph.subgraph.adj_comm SimpleGraph.Subgraph.adj_comm
-/

#print SimpleGraph.Subgraph.adj_symm /-
@[symm]
theorem adj_symm (G' : Subgraph G) {u v : V} (h : G'.Adj u v) : G'.Adj v u :=
  G'.symm h
#align simple_graph.subgraph.adj_symm SimpleGraph.Subgraph.adj_symm
-/

#print SimpleGraph.Subgraph.Adj.symm /-
protected theorem Adj.symm {G' : Subgraph G} {u v : V} (h : G'.Adj u v) : G'.Adj v u :=
  G'.symm h
#align simple_graph.subgraph.adj.symm SimpleGraph.Subgraph.Adj.symm
-/

#print SimpleGraph.Subgraph.Adj.adj_sub /-
protected theorem Adj.adj_sub {H : G.Subgraph} {u v : V} (h : H.Adj u v) : G.Adj u v :=
  H.adj_sub h
#align simple_graph.subgraph.adj.adj_sub SimpleGraph.Subgraph.Adj.adj_sub
-/

#print SimpleGraph.Subgraph.Adj.fst_mem /-
protected theorem Adj.fst_mem {H : G.Subgraph} {u v : V} (h : H.Adj u v) : u ∈ H.verts :=
  H.edge_vert h
#align simple_graph.subgraph.adj.fst_mem SimpleGraph.Subgraph.Adj.fst_mem
-/

#print SimpleGraph.Subgraph.Adj.snd_mem /-
protected theorem Adj.snd_mem {H : G.Subgraph} {u v : V} (h : H.Adj u v) : v ∈ H.verts :=
  h.symm.fst_mem
#align simple_graph.subgraph.adj.snd_mem SimpleGraph.Subgraph.Adj.snd_mem
-/

#print SimpleGraph.Subgraph.Adj.ne /-
protected theorem Adj.ne {H : G.Subgraph} {u v : V} (h : H.Adj u v) : u ≠ v :=
  h.adj_sub.Ne
#align simple_graph.subgraph.adj.ne SimpleGraph.Subgraph.Adj.ne
-/

#print SimpleGraph.Subgraph.coe /-
/-- Coercion from `G' : subgraph G` to a `simple_graph ↥G'.verts`. -/
@[simps]
protected def coe (G' : Subgraph G) : SimpleGraph G'.verts
    where
  Adj v w := G'.Adj v w
  symm v w h := G'.symm h
  loopless v h := loopless G v (G'.adj_sub h)
#align simple_graph.subgraph.coe SimpleGraph.Subgraph.coe
-/

#print SimpleGraph.Subgraph.coe_adj_sub /-
@[simp]
theorem coe_adj_sub (G' : Subgraph G) (u v : G'.verts) (h : G'.coe.Adj u v) : G.Adj u v :=
  G'.adj_sub h
#align simple_graph.subgraph.coe_adj_sub SimpleGraph.Subgraph.coe_adj_sub
-/

#print SimpleGraph.Subgraph.Adj.coe /-
-- Given `h : H.adj u v`, then `h.coe : H.coe.adj ⟨u, _⟩ ⟨v, _⟩`.
protected theorem Adj.coe {H : G.Subgraph} {u v : V} (h : H.Adj u v) :
    H.coe.Adj ⟨u, H.edge_vert h⟩ ⟨v, H.edge_vert h.symm⟩ :=
  h
#align simple_graph.subgraph.adj.coe SimpleGraph.Subgraph.Adj.coe
-/

#print SimpleGraph.Subgraph.IsSpanning /-
/-- A subgraph is called a *spanning subgraph* if it contains all the vertices of `G`. -/
def IsSpanning (G' : Subgraph G) : Prop :=
  ∀ v : V, v ∈ G'.verts
#align simple_graph.subgraph.is_spanning SimpleGraph.Subgraph.IsSpanning
-/

#print SimpleGraph.Subgraph.isSpanning_iff /-
theorem isSpanning_iff {G' : Subgraph G} : G'.IsSpanning ↔ G'.verts = Set.univ :=
  Set.eq_univ_iff_forall.symm
#align simple_graph.subgraph.is_spanning_iff SimpleGraph.Subgraph.isSpanning_iff
-/

#print SimpleGraph.Subgraph.spanningCoe /-
/-- Coercion from `subgraph G` to `simple_graph V`.  If `G'` is a spanning
subgraph, then `G'.spanning_coe` yields an isomorphic graph.
In general, this adds in all vertices from `V` as isolated vertices. -/
@[simps]
protected def spanningCoe (G' : Subgraph G) : SimpleGraph V
    where
  Adj := G'.Adj
  symm := G'.symm
  loopless v hv := G.loopless v (G'.adj_sub hv)
#align simple_graph.subgraph.spanning_coe SimpleGraph.Subgraph.spanningCoe
-/

#print SimpleGraph.Subgraph.Adj.of_spanningCoe /-
@[simp]
theorem Adj.of_spanningCoe {G' : Subgraph G} {u v : G'.verts} (h : G'.spanningCoe.Adj u v) :
    G.Adj u v :=
  G'.adj_sub h
#align simple_graph.subgraph.adj.of_spanning_coe SimpleGraph.Subgraph.Adj.of_spanningCoe
-/

#print SimpleGraph.Subgraph.spanningCoe_inj /-
@[simp]
theorem spanningCoe_inj : G₁.spanningCoe = G₂.spanningCoe ↔ G₁.Adj = G₂.Adj := by
  simp [subgraph.spanning_coe]
#align simple_graph.subgraph.spanning_coe_inj SimpleGraph.Subgraph.spanningCoe_inj
-/

#print SimpleGraph.Subgraph.spanningCoeEquivCoeOfSpanning /-
/-- `spanning_coe` is equivalent to `coe` for a subgraph that `is_spanning`.  -/
@[simps]
def spanningCoeEquivCoeOfSpanning (G' : Subgraph G) (h : G'.IsSpanning) : G'.spanningCoe ≃g G'.coe
    where
  toFun v := ⟨v, h v⟩
  invFun v := v
  left_inv v := rfl
  right_inv := fun ⟨v, hv⟩ => rfl
  map_rel_iff' v w := Iff.rfl
#align simple_graph.subgraph.spanning_coe_equiv_coe_of_spanning SimpleGraph.Subgraph.spanningCoeEquivCoeOfSpanning
-/

#print SimpleGraph.Subgraph.IsInduced /-
/-- A subgraph is called an *induced subgraph* if vertices of `G'` are adjacent if
they are adjacent in `G`. -/
def IsInduced (G' : Subgraph G) : Prop :=
  ∀ {v w : V}, v ∈ G'.verts → w ∈ G'.verts → G.Adj v w → G'.Adj v w
#align simple_graph.subgraph.is_induced SimpleGraph.Subgraph.IsInduced
-/

#print SimpleGraph.Subgraph.support /-
/-- `H.support` is the set of vertices that form edges in the subgraph `H`. -/
def support (H : Subgraph G) : Set V :=
  Rel.dom H.Adj
#align simple_graph.subgraph.support SimpleGraph.Subgraph.support
-/

#print SimpleGraph.Subgraph.mem_support /-
theorem mem_support (H : Subgraph G) {v : V} : v ∈ H.support ↔ ∃ w, H.Adj v w :=
  Iff.rfl
#align simple_graph.subgraph.mem_support SimpleGraph.Subgraph.mem_support
-/

#print SimpleGraph.Subgraph.support_subset_verts /-
theorem support_subset_verts (H : Subgraph G) : H.support ⊆ H.verts := fun v ⟨w, h⟩ => H.edge_vert h
#align simple_graph.subgraph.support_subset_verts SimpleGraph.Subgraph.support_subset_verts
-/

#print SimpleGraph.Subgraph.neighborSet /-
/-- `G'.neighbor_set v` is the set of vertices adjacent to `v` in `G'`. -/
def neighborSet (G' : Subgraph G) (v : V) : Set V :=
  setOf (G'.Adj v)
#align simple_graph.subgraph.neighbor_set SimpleGraph.Subgraph.neighborSet
-/

#print SimpleGraph.Subgraph.neighborSet_subset /-
theorem neighborSet_subset (G' : Subgraph G) (v : V) : G'.neighborSet v ⊆ G.neighborSet v :=
  fun w h => G'.adj_sub h
#align simple_graph.subgraph.neighbor_set_subset SimpleGraph.Subgraph.neighborSet_subset
-/

#print SimpleGraph.Subgraph.neighborSet_subset_verts /-
theorem neighborSet_subset_verts (G' : Subgraph G) (v : V) : G'.neighborSet v ⊆ G'.verts :=
  fun _ h => G'.edge_vert (adj_symm G' h)
#align simple_graph.subgraph.neighbor_set_subset_verts SimpleGraph.Subgraph.neighborSet_subset_verts
-/

#print SimpleGraph.Subgraph.mem_neighborSet /-
@[simp]
theorem mem_neighborSet (G' : Subgraph G) (v w : V) : w ∈ G'.neighborSet v ↔ G'.Adj v w :=
  Iff.rfl
#align simple_graph.subgraph.mem_neighbor_set SimpleGraph.Subgraph.mem_neighborSet
-/

#print SimpleGraph.Subgraph.coeNeighborSetEquiv /-
/-- A subgraph as a graph has equivalent neighbor sets. -/
def coeNeighborSetEquiv {G' : Subgraph G} (v : G'.verts) : G'.coe.neighborSet v ≃ G'.neighborSet v
    where
  toFun w := ⟨w, by obtain ⟨w', hw'⟩ := w; simpa using hw'⟩
  invFun w := ⟨⟨w, G'.edge_vert (G'.adj_symm w.2)⟩, by simpa using w.2⟩
  left_inv w := by simp
  right_inv w := by simp
#align simple_graph.subgraph.coe_neighbor_set_equiv SimpleGraph.Subgraph.coeNeighborSetEquiv
-/

#print SimpleGraph.Subgraph.edgeSet /-
/-- The edge set of `G'` consists of a subset of edges of `G`. -/
def edgeSet (G' : Subgraph G) : Set (Sym2 V) :=
  Sym2.fromRel G'.symm
#align simple_graph.subgraph.edge_set SimpleGraph.Subgraph.edgeSet
-/

#print SimpleGraph.Subgraph.edgeSet_subset /-
theorem edgeSet_subset (G' : Subgraph G) : G'.edgeSetEmbedding ⊆ G.edgeSetEmbedding := fun e =>
  Quotient.ind (fun e h => G'.adj_sub h) e
#align simple_graph.subgraph.edge_set_subset SimpleGraph.Subgraph.edgeSet_subset
-/

#print SimpleGraph.Subgraph.mem_edgeSet /-
@[simp]
theorem mem_edgeSet {G' : Subgraph G} {v w : V} : ⟦(v, w)⟧ ∈ G'.edgeSetEmbedding ↔ G'.Adj v w :=
  Iff.rfl
#align simple_graph.subgraph.mem_edge_set SimpleGraph.Subgraph.mem_edgeSet
-/

#print SimpleGraph.Subgraph.mem_verts_if_mem_edge /-
theorem mem_verts_if_mem_edge {G' : Subgraph G} {e : Sym2 V} {v : V} (he : e ∈ G'.edgeSetEmbedding)
    (hv : v ∈ e) : v ∈ G'.verts :=
  by
  refine' Quotient.ind (fun e he hv => _) e he hv
  cases' e with v w
  simp only [mem_edge_set] at he 
  cases' sym2.mem_iff.mp hv with h h <;> subst h
  · exact G'.edge_vert he
  · exact G'.edge_vert (G'.symm he)
#align simple_graph.subgraph.mem_verts_if_mem_edge SimpleGraph.Subgraph.mem_verts_if_mem_edge
-/

#print SimpleGraph.Subgraph.incidenceSet /-
/-- The `incidence_set` is the set of edges incident to a given vertex. -/
def incidenceSet (G' : Subgraph G) (v : V) : Set (Sym2 V) :=
  {e ∈ G'.edgeSetEmbedding | v ∈ e}
#align simple_graph.subgraph.incidence_set SimpleGraph.Subgraph.incidenceSet
-/

#print SimpleGraph.Subgraph.incidenceSet_subset_incidenceSet /-
theorem incidenceSet_subset_incidenceSet (G' : Subgraph G) (v : V) :
    G'.incidenceSet v ⊆ G.incidenceSet v := fun e h => ⟨G'.edgeSet_subset h.1, h.2⟩
#align simple_graph.subgraph.incidence_set_subset_incidence_set SimpleGraph.Subgraph.incidenceSet_subset_incidenceSet
-/

#print SimpleGraph.Subgraph.incidenceSet_subset /-
theorem incidenceSet_subset (G' : Subgraph G) (v : V) : G'.incidenceSet v ⊆ G'.edgeSetEmbedding :=
  fun _ h => h.1
#align simple_graph.subgraph.incidence_set_subset SimpleGraph.Subgraph.incidenceSet_subset
-/

#print SimpleGraph.Subgraph.vert /-
/-- Give a vertex as an element of the subgraph's vertex type. -/
@[reducible]
def vert (G' : Subgraph G) (v : V) (h : v ∈ G'.verts) : G'.verts :=
  ⟨v, h⟩
#align simple_graph.subgraph.vert SimpleGraph.Subgraph.vert
-/

#print SimpleGraph.Subgraph.copy /-
/--
Create an equal copy of a subgraph (see `copy_eq`) with possibly different definitional equalities.
See Note [range copy pattern].
-/
def copy (G' : Subgraph G) (V'' : Set V) (hV : V'' = G'.verts) (adj' : V → V → Prop)
    (hadj : adj' = G'.Adj) : Subgraph G where
  verts := V''
  Adj := adj'
  adj_sub _ _ := hadj.symm ▸ G'.adj_sub
  edge_vert _ _ := hV.symm ▸ hadj.symm ▸ G'.edge_vert
  symm := hadj.symm ▸ G'.symm
#align simple_graph.subgraph.copy SimpleGraph.Subgraph.copy
-/

#print SimpleGraph.Subgraph.copy_eq /-
theorem copy_eq (G' : Subgraph G) (V'' : Set V) (hV : V'' = G'.verts) (adj' : V → V → Prop)
    (hadj : adj' = G'.Adj) : G'.copy V'' hV adj' hadj = G' :=
  Subgraph.ext _ _ hV hadj
#align simple_graph.subgraph.copy_eq SimpleGraph.Subgraph.copy_eq
-/

/-- The union of two subgraphs. -/
instance : Sup G.Subgraph :=
  ⟨fun G₁ G₂ =>
    { verts := G₁.verts ∪ G₂.verts
      Adj := G₁.Adj ⊔ G₂.Adj
      adj_sub := fun a b hab => Or.elim hab (fun h => G₁.adj_sub h) fun h => G₂.adj_sub h
      edge_vert := fun a b => Or.imp (fun h => G₁.edge_vert h) fun h => G₂.edge_vert h
      symm := fun a b => Or.imp G₁.adj_symm G₂.adj_symm }⟩

/-- The intersection of two subgraphs. -/
instance : Inf G.Subgraph :=
  ⟨fun G₁ G₂ =>
    { verts := G₁.verts ∩ G₂.verts
      Adj := G₁.Adj ⊓ G₂.Adj
      adj_sub := fun a b hab => G₁.adj_sub hab.1
      edge_vert := fun a b => And.imp (fun h => G₁.edge_vert h) fun h => G₂.edge_vert h
      symm := fun a b => And.imp G₁.adj_symm G₂.adj_symm }⟩

/-- The `top` subgraph is `G` as a subgraph of itself. -/
instance : Top G.Subgraph :=
  ⟨{  verts := Set.univ
      Adj := G.Adj
      adj_sub := fun v w h => h
      edge_vert := fun v w h => Set.mem_univ v
      symm := G.symm }⟩

/-- The `bot` subgraph is the subgraph with no vertices or edges. -/
instance : Bot G.Subgraph :=
  ⟨{  verts := ∅
      Adj := ⊥
      adj_sub := fun v w h => False.ndrec _ h
      edge_vert := fun v w h => False.ndrec _ h
      symm := fun u v h => h }⟩

instance : SupSet G.Subgraph :=
  ⟨fun s =>
    { verts := ⋃ G' ∈ s, verts G'
      Adj := fun a b => ∃ G' ∈ s, Adj G' a b
      adj_sub := by rintro a b ⟨G', -, hab⟩; exact G'.adj_sub hab
      edge_vert := by rintro a b ⟨G', hG', hab⟩; exact Set.mem_iUnion₂_of_mem hG' (G'.edge_vert hab)
      symm := fun a b => Exists₂.imp fun _ _ => Adj.symm }⟩

instance : InfSet G.Subgraph :=
  ⟨fun s =>
    { verts := ⋂ G' ∈ s, verts G'
      Adj := fun a b => (∀ ⦃G'⦄, G' ∈ s → Adj G' a b) ∧ G.Adj a b
      adj_sub := fun a b => And.right
      edge_vert := fun a b hab => Set.mem_iInter₂_of_mem fun G' hG' => G'.edge_vert <| hab.1 hG'
      symm := fun _ _ => And.imp (forall₂_imp fun _ _ => Adj.symm) G.adj_symm }⟩

#print SimpleGraph.Subgraph.sup_adj /-
@[simp]
theorem sup_adj : (G₁ ⊔ G₂).Adj a b ↔ G₁.Adj a b ∨ G₂.Adj a b :=
  Iff.rfl
#align simple_graph.subgraph.sup_adj SimpleGraph.Subgraph.sup_adj
-/

#print SimpleGraph.Subgraph.inf_adj /-
@[simp]
theorem inf_adj : (G₁ ⊓ G₂).Adj a b ↔ G₁.Adj a b ∧ G₂.Adj a b :=
  Iff.rfl
#align simple_graph.subgraph.inf_adj SimpleGraph.Subgraph.inf_adj
-/

#print SimpleGraph.Subgraph.top_adj /-
@[simp]
theorem top_adj : (⊤ : Subgraph G).Adj a b ↔ G.Adj a b :=
  Iff.rfl
#align simple_graph.subgraph.top_adj SimpleGraph.Subgraph.top_adj
-/

#print SimpleGraph.Subgraph.not_bot_adj /-
@[simp]
theorem not_bot_adj : ¬(⊥ : Subgraph G).Adj a b :=
  not_false
#align simple_graph.subgraph.not_bot_adj SimpleGraph.Subgraph.not_bot_adj
-/

#print SimpleGraph.Subgraph.verts_sup /-
@[simp]
theorem verts_sup (G₁ G₂ : G.Subgraph) : (G₁ ⊔ G₂).verts = G₁.verts ∪ G₂.verts :=
  rfl
#align simple_graph.subgraph.verts_sup SimpleGraph.Subgraph.verts_sup
-/

#print SimpleGraph.Subgraph.verts_inf /-
@[simp]
theorem verts_inf (G₁ G₂ : G.Subgraph) : (G₁ ⊓ G₂).verts = G₁.verts ∩ G₂.verts :=
  rfl
#align simple_graph.subgraph.verts_inf SimpleGraph.Subgraph.verts_inf
-/

#print SimpleGraph.Subgraph.verts_top /-
@[simp]
theorem verts_top : (⊤ : G.Subgraph).verts = Set.univ :=
  rfl
#align simple_graph.subgraph.verts_top SimpleGraph.Subgraph.verts_top
-/

#print SimpleGraph.Subgraph.verts_bot /-
@[simp]
theorem verts_bot : (⊥ : G.Subgraph).verts = ∅ :=
  rfl
#align simple_graph.subgraph.verts_bot SimpleGraph.Subgraph.verts_bot
-/

#print SimpleGraph.Subgraph.sSup_adj /-
@[simp]
theorem sSup_adj {s : Set G.Subgraph} : (sSup s).Adj a b ↔ ∃ G ∈ s, Adj G a b :=
  Iff.rfl
#align simple_graph.subgraph.Sup_adj SimpleGraph.Subgraph.sSup_adj
-/

#print SimpleGraph.Subgraph.sInf_adj /-
@[simp]
theorem sInf_adj {s : Set G.Subgraph} : (sInf s).Adj a b ↔ (∀ G' ∈ s, Adj G' a b) ∧ G.Adj a b :=
  Iff.rfl
#align simple_graph.subgraph.Inf_adj SimpleGraph.Subgraph.sInf_adj
-/

#print SimpleGraph.Subgraph.iSup_adj /-
@[simp]
theorem iSup_adj {f : ι → G.Subgraph} : (⨆ i, f i).Adj a b ↔ ∃ i, (f i).Adj a b := by simp [iSup]
#align simple_graph.subgraph.supr_adj SimpleGraph.Subgraph.iSup_adj
-/

#print SimpleGraph.Subgraph.iInf_adj /-
@[simp]
theorem iInf_adj {f : ι → G.Subgraph} : (⨅ i, f i).Adj a b ↔ (∀ i, (f i).Adj a b) ∧ G.Adj a b := by
  simp [iInf]
#align simple_graph.subgraph.infi_adj SimpleGraph.Subgraph.iInf_adj
-/

#print SimpleGraph.Subgraph.sInf_adj_of_nonempty /-
theorem sInf_adj_of_nonempty {s : Set G.Subgraph} (hs : s.Nonempty) :
    (sInf s).Adj a b ↔ ∀ G' ∈ s, Adj G' a b :=
  sInf_adj.trans <|
    and_iff_left_of_imp <| by obtain ⟨G', hG'⟩ := hs; exact fun h => G'.adj_sub (h _ hG')
#align simple_graph.subgraph.Inf_adj_of_nonempty SimpleGraph.Subgraph.sInf_adj_of_nonempty
-/

#print SimpleGraph.Subgraph.iInf_adj_of_nonempty /-
theorem iInf_adj_of_nonempty [Nonempty ι] {f : ι → G.Subgraph} :
    (⨅ i, f i).Adj a b ↔ ∀ i, (f i).Adj a b := by
  simp [iInf, Inf_adj_of_nonempty (Set.range_nonempty _)]
#align simple_graph.subgraph.infi_adj_of_nonempty SimpleGraph.Subgraph.iInf_adj_of_nonempty
-/

#print SimpleGraph.Subgraph.verts_sSup /-
@[simp]
theorem verts_sSup (s : Set G.Subgraph) : (sSup s).verts = ⋃ G' ∈ s, verts G' :=
  rfl
#align simple_graph.subgraph.verts_Sup SimpleGraph.Subgraph.verts_sSup
-/

#print SimpleGraph.Subgraph.verts_sInf /-
@[simp]
theorem verts_sInf (s : Set G.Subgraph) : (sInf s).verts = ⋂ G' ∈ s, verts G' :=
  rfl
#align simple_graph.subgraph.verts_Inf SimpleGraph.Subgraph.verts_sInf
-/

#print SimpleGraph.Subgraph.verts_iSup /-
@[simp]
theorem verts_iSup {f : ι → G.Subgraph} : (⨆ i, f i).verts = ⋃ i, (f i).verts := by simp [iSup]
#align simple_graph.subgraph.verts_supr SimpleGraph.Subgraph.verts_iSup
-/

#print SimpleGraph.Subgraph.verts_iInf /-
@[simp]
theorem verts_iInf {f : ι → G.Subgraph} : (⨅ i, f i).verts = ⋂ i, (f i).verts := by simp [iInf]
#align simple_graph.subgraph.verts_infi SimpleGraph.Subgraph.verts_iInf
-/

/-- For subgraphs `G₁`, `G₂`, `G₁ ≤ G₂` iff `G₁.verts ⊆ G₂.verts` and
`∀ a b, G₁.adj a b → G₂.adj a b`. -/
instance : DistribLattice G.Subgraph :=
  {
    show DistribLattice G.Subgraph from
      Function.Injective.distribLattice (fun G' => (G'.verts, G'.spanningCoe))
        (fun G₁ G₂ h => by rw [Prod.ext_iff] at h ; exact ext _ _ h.1 (spanning_coe_inj.1 h.2))
        (fun _ _ => rfl) fun _ _ => rfl with
    le := fun x y => x.verts ⊆ y.verts ∧ ∀ ⦃v w : V⦄, x.Adj v w → y.Adj v w }

instance : BoundedOrder (Subgraph G) where
  top := ⊤
  bot := ⊥
  le_top x := ⟨Set.subset_univ _, fun v w h => x.adj_sub h⟩
  bot_le x := ⟨Set.empty_subset _, fun v w h => False.ndrec _ h⟩

-- Note that subgraphs do not form a Boolean algebra, because of `verts`.
instance : CompleteDistribLattice G.Subgraph :=
  { Subgraph.distribLattice with
    le := (· ≤ ·)
    sup := (· ⊔ ·)
    inf := (· ⊓ ·)
    top := ⊤
    bot := ⊥
    le_top := fun G' => ⟨Set.subset_univ _, fun a b => G'.adj_sub⟩
    bot_le := fun G' => ⟨Set.empty_subset _, fun a b => False.elim⟩
    sSup := sSup
    le_sup := fun s G' hG' => ⟨Set.subset_iUnion₂ G' hG', fun a b hab => ⟨G', hG', hab⟩⟩
    sup_le := fun s G' hG' =>
      ⟨Set.iUnion₂_subset fun H hH => (hG' _ hH).1, by rintro a b ⟨H, hH, hab⟩;
        exact (hG' _ hH).2 hab⟩
    sInf := sInf
    inf_le := fun s G' hG' => ⟨Set.iInter₂_subset G' hG', fun a b hab => hab.1 hG'⟩
    le_inf := fun s G' hG' =>
      ⟨Set.subset_iInter₂ fun H hH => (hG' _ hH).1, fun a b hab =>
        ⟨fun H hH => (hG' _ hH).2 hab, G'.adj_sub hab⟩⟩
    inf_sup_le_iSup_inf := fun G' s =>
      by
      refine' ⟨_, fun a b hab => _⟩
      · simp only [verts_inf, verts_Sup, verts_supr, Set.le_eq_subset]
        exact (Set.inter_iUnion₂ _ _).Subset
      ·
        simpa only [spanning_coe_adj, exists_prop, Sup_adj, and_imp, forall_exists_index, supr_adj,
          inf_adj, ← exists_and_right, exists_and_left, and_assoc', and_self_right] using hab
    iInf_sup_le_sup_inf := fun G' s =>
      by
      refine' ⟨_, fun a b hab => _⟩
      · simp only [Set.le_eq_subset, verts_infi, verts_sup, verts_Inf]
        exact (Set.union_iInter₂ _ _).Superset
      simp only [spanning_coe_adj, sup_adj, Inf_adj, sup_adj, Inf_adj, infi_adj] at hab ⊢
      have : (∀ G'' ∈ s, adj G' a b ∨ adj G'' a b) ∧ G.adj a b :=
        (and_congr_left fun h => forall_congr' fun H => _).1 hab
      simpa [forall_or_left, or_and_right, and_iff_left_of_imp G'.adj_sub] using this
      exact and_iff_left h }

#print SimpleGraph.Subgraph.subgraphInhabited /-
@[simps]
instance subgraphInhabited : Inhabited (Subgraph G) :=
  ⟨⊥⟩
#align simple_graph.subgraph.subgraph_inhabited SimpleGraph.Subgraph.subgraphInhabited
-/

#print SimpleGraph.Subgraph.neighborSet_sup /-
@[simp]
theorem neighborSet_sup {H H' : G.Subgraph} (v : V) :
    (H ⊔ H').neighborSet v = H.neighborSet v ∪ H'.neighborSet v :=
  rfl
#align simple_graph.subgraph.neighbor_set_sup SimpleGraph.Subgraph.neighborSet_sup
-/

#print SimpleGraph.Subgraph.neighborSet_inf /-
@[simp]
theorem neighborSet_inf {H H' : G.Subgraph} (v : V) :
    (H ⊓ H').neighborSet v = H.neighborSet v ∩ H'.neighborSet v :=
  rfl
#align simple_graph.subgraph.neighbor_set_inf SimpleGraph.Subgraph.neighborSet_inf
-/

#print SimpleGraph.Subgraph.neighborSet_top /-
@[simp]
theorem neighborSet_top (v : V) : (⊤ : G.Subgraph).neighborSet v = G.neighborSet v :=
  rfl
#align simple_graph.subgraph.neighbor_set_top SimpleGraph.Subgraph.neighborSet_top
-/

#print SimpleGraph.Subgraph.neighborSet_bot /-
@[simp]
theorem neighborSet_bot (v : V) : (⊥ : G.Subgraph).neighborSet v = ∅ :=
  rfl
#align simple_graph.subgraph.neighbor_set_bot SimpleGraph.Subgraph.neighborSet_bot
-/

#print SimpleGraph.Subgraph.neighborSet_sSup /-
@[simp]
theorem neighborSet_sSup (s : Set G.Subgraph) (v : V) :
    (sSup s).neighborSet v = ⋃ G' ∈ s, neighborSet G' v := by ext; simp
#align simple_graph.subgraph.neighbor_set_Sup SimpleGraph.Subgraph.neighborSet_sSup
-/

#print SimpleGraph.Subgraph.neighborSet_sInf /-
@[simp]
theorem neighborSet_sInf (s : Set G.Subgraph) (v : V) :
    (sInf s).neighborSet v = (⋂ G' ∈ s, neighborSet G' v) ∩ G.neighborSet v := by ext; simp
#align simple_graph.subgraph.neighbor_set_Inf SimpleGraph.Subgraph.neighborSet_sInf
-/

#print SimpleGraph.Subgraph.neighborSet_iSup /-
@[simp]
theorem neighborSet_iSup (f : ι → G.Subgraph) (v : V) :
    (⨆ i, f i).neighborSet v = ⋃ i, (f i).neighborSet v := by simp [iSup]
#align simple_graph.subgraph.neighbor_set_supr SimpleGraph.Subgraph.neighborSet_iSup
-/

#print SimpleGraph.Subgraph.neighborSet_iInf /-
@[simp]
theorem neighborSet_iInf (f : ι → G.Subgraph) (v : V) :
    (⨅ i, f i).neighborSet v = (⋂ i, (f i).neighborSet v) ∩ G.neighborSet v := by simp [iInf]
#align simple_graph.subgraph.neighbor_set_infi SimpleGraph.Subgraph.neighborSet_iInf
-/

#print SimpleGraph.Subgraph.edgeSet_top /-
@[simp]
theorem edgeSet_top : (⊤ : Subgraph G).edgeSetEmbedding = G.edgeSetEmbedding :=
  rfl
#align simple_graph.subgraph.edge_set_top SimpleGraph.Subgraph.edgeSet_top
-/

#print SimpleGraph.Subgraph.edgeSet_bot /-
@[simp]
theorem edgeSet_bot : (⊥ : Subgraph G).edgeSetEmbedding = ∅ :=
  Set.ext <| Sym2.ind (by simp)
#align simple_graph.subgraph.edge_set_bot SimpleGraph.Subgraph.edgeSet_bot
-/

#print SimpleGraph.Subgraph.edgeSet_inf /-
@[simp]
theorem edgeSet_inf {H₁ H₂ : Subgraph G} :
    (H₁ ⊓ H₂).edgeSetEmbedding = H₁.edgeSetEmbedding ∩ H₂.edgeSetEmbedding :=
  Set.ext <| Sym2.ind (by simp)
#align simple_graph.subgraph.edge_set_inf SimpleGraph.Subgraph.edgeSet_inf
-/

#print SimpleGraph.Subgraph.edgeSet_sup /-
@[simp]
theorem edgeSet_sup {H₁ H₂ : Subgraph G} :
    (H₁ ⊔ H₂).edgeSetEmbedding = H₁.edgeSetEmbedding ∪ H₂.edgeSetEmbedding :=
  Set.ext <| Sym2.ind (by simp)
#align simple_graph.subgraph.edge_set_sup SimpleGraph.Subgraph.edgeSet_sup
-/

#print SimpleGraph.Subgraph.edgeSet_sSup /-
@[simp]
theorem edgeSet_sSup (s : Set G.Subgraph) : (sSup s).edgeSetEmbedding = ⋃ G' ∈ s, edgeSet G' := by
  ext e; induction e using Sym2.ind; simp
#align simple_graph.subgraph.edge_set_Sup SimpleGraph.Subgraph.edgeSet_sSup
-/

#print SimpleGraph.Subgraph.edgeSet_sInf /-
@[simp]
theorem edgeSet_sInf (s : Set G.Subgraph) :
    (sInf s).edgeSetEmbedding = (⋂ G' ∈ s, edgeSet G') ∩ G.edgeSetEmbedding := by ext e;
  induction e using Sym2.ind; simp
#align simple_graph.subgraph.edge_set_Inf SimpleGraph.Subgraph.edgeSet_sInf
-/

#print SimpleGraph.Subgraph.edgeSet_iSup /-
@[simp]
theorem edgeSet_iSup (f : ι → G.Subgraph) :
    (⨆ i, f i).edgeSetEmbedding = ⋃ i, (f i).edgeSetEmbedding := by simp [iSup]
#align simple_graph.subgraph.edge_set_supr SimpleGraph.Subgraph.edgeSet_iSup
-/

#print SimpleGraph.Subgraph.edgeSet_iInf /-
@[simp]
theorem edgeSet_iInf (f : ι → G.Subgraph) :
    (⨅ i, f i).edgeSetEmbedding = (⋂ i, (f i).edgeSetEmbedding) ∩ G.edgeSetEmbedding := by
  simp [iInf]
#align simple_graph.subgraph.edge_set_infi SimpleGraph.Subgraph.edgeSet_iInf
-/

#print SimpleGraph.Subgraph.spanningCoe_top /-
@[simp]
theorem spanningCoe_top : (⊤ : Subgraph G).spanningCoe = G := by ext; rfl
#align simple_graph.subgraph.spanning_coe_top SimpleGraph.Subgraph.spanningCoe_top
-/

#print SimpleGraph.Subgraph.spanningCoe_bot /-
@[simp]
theorem spanningCoe_bot : (⊥ : Subgraph G).spanningCoe = ⊥ :=
  rfl
#align simple_graph.subgraph.spanning_coe_bot SimpleGraph.Subgraph.spanningCoe_bot
-/

#print SimpleGraph.toSubgraph /-
/-- Turn a subgraph of a `simple_graph` into a member of its subgraph type. -/
@[simps]
def SimpleGraph.toSubgraph (H : SimpleGraph V) (h : H ≤ G) : G.Subgraph
    where
  verts := Set.univ
  Adj := H.Adj
  adj_sub := h
  edge_vert v w h := Set.mem_univ v
  symm := H.symm
#align simple_graph.to_subgraph SimpleGraph.toSubgraph
-/

#print SimpleGraph.Subgraph.support_mono /-
theorem support_mono {H H' : Subgraph G} (h : H ≤ H') : H.support ⊆ H'.support :=
  Rel.dom_mono h.2
#align simple_graph.subgraph.support_mono SimpleGraph.Subgraph.support_mono
-/

#print SimpleGraph.toSubgraph.isSpanning /-
theorem SimpleGraph.toSubgraph.isSpanning (H : SimpleGraph V) (h : H ≤ G) :
    (H.toSubgraph h).IsSpanning :=
  Set.mem_univ
#align simple_graph.to_subgraph.is_spanning SimpleGraph.toSubgraph.isSpanning
-/

#print SimpleGraph.Subgraph.spanningCoe_le_of_le /-
theorem spanningCoe_le_of_le {H H' : Subgraph G} (h : H ≤ H') : H.spanningCoe ≤ H'.spanningCoe :=
  h.2
#align simple_graph.subgraph.spanning_coe_le_of_le SimpleGraph.Subgraph.spanningCoe_le_of_le
-/

#print SimpleGraph.Subgraph.topEquiv /-
/-- The top of the `subgraph G` lattice is equivalent to the graph itself. -/
def topEquiv : (⊤ : Subgraph G).coe ≃g G
    where
  toFun v := ↑v
  invFun v := ⟨v, trivial⟩
  left_inv := fun ⟨v, _⟩ => rfl
  right_inv v := rfl
  map_rel_iff' a b := Iff.rfl
#align simple_graph.subgraph.top_equiv SimpleGraph.Subgraph.topEquiv
-/

#print SimpleGraph.Subgraph.botEquiv /-
/-- The bottom of the `subgraph G` lattice is equivalent to the empty graph on the empty
vertex type. -/
def botEquiv : (⊥ : Subgraph G).coe ≃g (⊥ : SimpleGraph Empty)
    where
  toFun v := v.property.elim
  invFun v := v.elim
  left_inv := fun ⟨_, h⟩ => h.elim
  right_inv v := v.elim
  map_rel_iff' a b := Iff.rfl
#align simple_graph.subgraph.bot_equiv SimpleGraph.Subgraph.botEquiv
-/

#print SimpleGraph.Subgraph.edgeSet_mono /-
theorem edgeSet_mono {H₁ H₂ : Subgraph G} (h : H₁ ≤ H₂) :
    H₁.edgeSetEmbedding ≤ H₂.edgeSetEmbedding := fun e => Sym2.ind h.2 e
#align simple_graph.subgraph.edge_set_mono SimpleGraph.Subgraph.edgeSet_mono
-/

#print Disjoint.edgeSet /-
theorem Disjoint.edgeSet {H₁ H₂ : Subgraph G} (h : Disjoint H₁ H₂) :
    Disjoint H₁.edgeSetEmbedding H₂.edgeSetEmbedding :=
  disjoint_iff_inf_le.mpr <| by simpa using edge_set_mono h.le_bot
#align disjoint.edge_set Disjoint.edgeSet
-/

#print SimpleGraph.Subgraph.map /-
/-- Graph homomorphisms induce a covariant function on subgraphs. -/
@[simps]
protected def map {G' : SimpleGraph W} (f : G →g G') (H : G.Subgraph) : G'.Subgraph
    where
  verts := f '' H.verts
  Adj := Relation.Map H.Adj f f
  adj_sub := by rintro _ _ ⟨u, v, h, rfl, rfl⟩; exact f.map_rel (H.adj_sub h)
  edge_vert := by rintro _ _ ⟨u, v, h, rfl, rfl⟩; exact Set.mem_image_of_mem _ (H.edge_vert h)
  symm := by rintro _ _ ⟨u, v, h, rfl, rfl⟩; exact ⟨v, u, H.symm h, rfl, rfl⟩
#align simple_graph.subgraph.map SimpleGraph.Subgraph.map
-/

#print SimpleGraph.Subgraph.map_monotone /-
theorem map_monotone {G' : SimpleGraph W} (f : G →g G') : Monotone (Subgraph.map f) :=
  by
  intro H H' h
  constructor
  · intro
    simp only [map_verts, Set.mem_image, forall_exists_index, and_imp]
    rintro v hv rfl
    exact ⟨_, h.1 hv, rfl⟩
  · rintro _ _ ⟨u, v, ha, rfl, rfl⟩
    exact ⟨_, _, h.2 ha, rfl, rfl⟩
#align simple_graph.subgraph.map_monotone SimpleGraph.Subgraph.map_monotone
-/

#print SimpleGraph.Subgraph.map_sup /-
theorem map_sup {G : SimpleGraph V} {G' : SimpleGraph W} (f : G →g G') {H H' : G.Subgraph} :
    (H ⊔ H').map f = H.map f ⊔ H'.map f := by
  ext1
  · simp only [Set.image_union, map_verts, verts_sup]
  · ext
    simp only [Relation.Map, map_adj, sup_adj]
    constructor
    · rintro ⟨a, b, h | h, rfl, rfl⟩
      · exact Or.inl ⟨_, _, h, rfl, rfl⟩
      · exact Or.inr ⟨_, _, h, rfl, rfl⟩
    · rintro (⟨a, b, h, rfl, rfl⟩ | ⟨a, b, h, rfl, rfl⟩)
      · exact ⟨_, _, Or.inl h, rfl, rfl⟩
      · exact ⟨_, _, Or.inr h, rfl, rfl⟩
#align simple_graph.subgraph.map_sup SimpleGraph.Subgraph.map_sup
-/

#print SimpleGraph.Subgraph.comap /-
/-- Graph homomorphisms induce a contravariant function on subgraphs. -/
@[simps]
protected def comap {G' : SimpleGraph W} (f : G →g G') (H : G'.Subgraph) : G.Subgraph
    where
  verts := f ⁻¹' H.verts
  Adj u v := G.Adj u v ∧ H.Adj (f u) (f v)
  adj_sub := by rintro v w ⟨ga, ha⟩; exact ga
  edge_vert := by rintro v w ⟨ga, ha⟩; simp [H.edge_vert ha]
#align simple_graph.subgraph.comap SimpleGraph.Subgraph.comap
-/

#print SimpleGraph.Subgraph.comap_monotone /-
theorem comap_monotone {G' : SimpleGraph W} (f : G →g G') : Monotone (Subgraph.comap f) :=
  by
  intro H H' h
  constructor
  · intro
    simp only [comap_verts, Set.mem_preimage]
    apply h.1
  · intro v w
    simp (config := { contextual := true }) only [comap_adj, and_imp, true_and_iff]
    intro
    apply h.2
#align simple_graph.subgraph.comap_monotone SimpleGraph.Subgraph.comap_monotone
-/

#print SimpleGraph.Subgraph.map_le_iff_le_comap /-
theorem map_le_iff_le_comap {G' : SimpleGraph W} (f : G →g G') (H : G.Subgraph) (H' : G'.Subgraph) :
    H.map f ≤ H' ↔ H ≤ H'.comap f :=
  by
  refine' ⟨fun h => ⟨fun v hv => _, fun v w hvw => _⟩, fun h => ⟨fun v => _, fun v w => _⟩⟩
  · simp only [comap_verts, Set.mem_preimage]
    exact h.1 ⟨v, hv, rfl⟩
  · simp only [H.adj_sub hvw, comap_adj, true_and_iff]
    exact h.2 ⟨v, w, hvw, rfl, rfl⟩
  · simp only [map_verts, Set.mem_image, forall_exists_index, and_imp]
    rintro w hw rfl
    exact h.1 hw
  · simp only [Relation.Map, map_adj, forall_exists_index, and_imp]
    rintro u u' hu rfl rfl
    have := h.2 hu
    simp only [comap_adj] at this 
    exact this.2
#align simple_graph.subgraph.map_le_iff_le_comap SimpleGraph.Subgraph.map_le_iff_le_comap
-/

#print SimpleGraph.Subgraph.inclusion /-
/-- Given two subgraphs, one a subgraph of the other, there is an induced injective homomorphism of
the subgraphs as graphs. -/
@[simps]
def inclusion {x y : Subgraph G} (h : x ≤ y) : x.coe →g y.coe
    where
  toFun v := ⟨↑v, And.left h v.property⟩
  map_rel' v w hvw := h.2 hvw
#align simple_graph.subgraph.inclusion SimpleGraph.Subgraph.inclusion
-/

#print SimpleGraph.Subgraph.inclusion.injective /-
theorem inclusion.injective {x y : Subgraph G} (h : x ≤ y) : Function.Injective (inclusion h) :=
  fun v w h => by simp only [inclusion, RelHom.coeFn_mk, Subtype.mk_eq_mk] at h ;
  exact Subtype.ext h
#align simple_graph.subgraph.inclusion.injective SimpleGraph.Subgraph.inclusion.injective
-/

#print SimpleGraph.Subgraph.hom /-
/-- There is an induced injective homomorphism of a subgraph of `G` into `G`. -/
@[simps]
protected def hom (x : Subgraph G) : x.coe →g G
    where
  toFun v := v
  map_rel' v w hvw := x.adj_sub hvw
#align simple_graph.subgraph.hom SimpleGraph.Subgraph.hom
-/

#print SimpleGraph.Subgraph.hom.injective /-
theorem hom.injective {x : Subgraph G} : Function.Injective x.hom := fun v w h => Subtype.ext h
#align simple_graph.subgraph.hom.injective SimpleGraph.Subgraph.hom.injective
-/

#print SimpleGraph.Subgraph.spanningHom /-
/-- There is an induced injective homomorphism of a subgraph of `G` as
a spanning subgraph into `G`. -/
@[simps]
def spanningHom (x : Subgraph G) : x.spanningCoe →g G
    where
  toFun := id
  map_rel' v w hvw := x.adj_sub hvw
#align simple_graph.subgraph.spanning_hom SimpleGraph.Subgraph.spanningHom
-/

#print SimpleGraph.Subgraph.spanningHom.injective /-
theorem spanningHom.injective {x : Subgraph G} : Function.Injective x.spanningHom := fun v w h => h
#align simple_graph.subgraph.spanning_hom.injective SimpleGraph.Subgraph.spanningHom.injective
-/

#print SimpleGraph.Subgraph.neighborSet_subset_of_subgraph /-
theorem neighborSet_subset_of_subgraph {x y : Subgraph G} (h : x ≤ y) (v : V) :
    x.neighborSet v ⊆ y.neighborSet v := fun w h' => h.2 h'
#align simple_graph.subgraph.neighbor_set_subset_of_subgraph SimpleGraph.Subgraph.neighborSet_subset_of_subgraph
-/

#print SimpleGraph.Subgraph.neighborSet.decidablePred /-
instance neighborSet.decidablePred (G' : Subgraph G) [h : DecidableRel G'.Adj] (v : V) :
    DecidablePred (· ∈ G'.neighborSet v) :=
  h v
#align simple_graph.subgraph.neighbor_set.decidable_pred SimpleGraph.Subgraph.neighborSet.decidablePred
-/

#print SimpleGraph.Subgraph.finiteAt /-
/-- If a graph is locally finite at a vertex, then so is a subgraph of that graph. -/
instance finiteAt {G' : Subgraph G} (v : G'.verts) [DecidableRel G'.Adj]
    [Fintype (G.neighborSet v)] : Fintype (G'.neighborSet v) :=
  Set.fintypeSubset (G.neighborSet v) (G'.neighborSet_subset v)
#align simple_graph.subgraph.finite_at SimpleGraph.Subgraph.finiteAt
-/

#print SimpleGraph.Subgraph.finiteAtOfSubgraph /-
/-- If a subgraph is locally finite at a vertex, then so are subgraphs of that subgraph.

This is not an instance because `G''` cannot be inferred. -/
def finiteAtOfSubgraph {G' G'' : Subgraph G} [DecidableRel G'.Adj] (h : G' ≤ G'') (v : G'.verts)
    [hf : Fintype (G''.neighborSet v)] : Fintype (G'.neighborSet v) :=
  Set.fintypeSubset (G''.neighborSet v) (neighborSet_subset_of_subgraph h v)
#align simple_graph.subgraph.finite_at_of_subgraph SimpleGraph.Subgraph.finiteAtOfSubgraph
-/

instance (G' : Subgraph G) [Fintype G'.verts] (v : V) [DecidablePred (· ∈ G'.neighborSet v)] :
    Fintype (G'.neighborSet v) :=
  Set.fintypeSubset G'.verts (neighborSet_subset_verts G' v)

#print SimpleGraph.Subgraph.coeFiniteAt /-
instance coeFiniteAt {G' : Subgraph G} (v : G'.verts) [Fintype (G'.neighborSet v)] :
    Fintype (G'.coe.neighborSet v) :=
  Fintype.ofEquiv _ (coeNeighborSetEquiv v).symm
#align simple_graph.subgraph.coe_finite_at SimpleGraph.Subgraph.coeFiniteAt
-/

#print SimpleGraph.Subgraph.IsSpanning.card_verts /-
theorem IsSpanning.card_verts [Fintype V] {G' : Subgraph G} [Fintype G'.verts] (h : G'.IsSpanning) :
    G'.verts.toFinset.card = Fintype.card V := by rw [is_spanning_iff] at h ; simpa [h]
#align simple_graph.subgraph.is_spanning.card_verts SimpleGraph.Subgraph.IsSpanning.card_verts
-/

#print SimpleGraph.Subgraph.degree /-
/-- The degree of a vertex in a subgraph. It's zero for vertices outside the subgraph. -/
def degree (G' : Subgraph G) (v : V) [Fintype (G'.neighborSet v)] : ℕ :=
  Fintype.card (G'.neighborSet v)
#align simple_graph.subgraph.degree SimpleGraph.Subgraph.degree
-/

#print SimpleGraph.Subgraph.finset_card_neighborSet_eq_degree /-
theorem finset_card_neighborSet_eq_degree {G' : Subgraph G} {v : V} [Fintype (G'.neighborSet v)] :
    (G'.neighborSet v).toFinset.card = G'.degree v := by rw [degree, Set.toFinset_card]
#align simple_graph.subgraph.finset_card_neighbor_set_eq_degree SimpleGraph.Subgraph.finset_card_neighborSet_eq_degree
-/

#print SimpleGraph.Subgraph.degree_le /-
theorem degree_le (G' : Subgraph G) (v : V) [Fintype (G'.neighborSet v)]
    [Fintype (G.neighborSet v)] : G'.degree v ≤ G.degree v :=
  by
  rw [← card_neighbor_set_eq_degree]
  exact Set.card_le_of_subset (G'.neighbor_set_subset v)
#align simple_graph.subgraph.degree_le SimpleGraph.Subgraph.degree_le
-/

#print SimpleGraph.Subgraph.degree_le' /-
theorem degree_le' (G' G'' : Subgraph G) (h : G' ≤ G'') (v : V) [Fintype (G'.neighborSet v)]
    [Fintype (G''.neighborSet v)] : G'.degree v ≤ G''.degree v :=
  Set.card_le_of_subset (neighborSet_subset_of_subgraph h v)
#align simple_graph.subgraph.degree_le' SimpleGraph.Subgraph.degree_le'
-/

#print SimpleGraph.Subgraph.coe_degree /-
@[simp]
theorem coe_degree (G' : Subgraph G) (v : G'.verts) [Fintype (G'.coe.neighborSet v)]
    [Fintype (G'.neighborSet v)] : G'.coe.degree v = G'.degree v :=
  by
  rw [← card_neighbor_set_eq_degree]
  exact Fintype.card_congr (coe_neighbor_set_equiv v)
#align simple_graph.subgraph.coe_degree SimpleGraph.Subgraph.coe_degree
-/

#print SimpleGraph.Subgraph.degree_spanningCoe /-
@[simp]
theorem degree_spanningCoe {G' : G.Subgraph} (v : V) [Fintype (G'.neighborSet v)]
    [Fintype (G'.spanningCoe.neighborSet v)] : G'.spanningCoe.degree v = G'.degree v := by
  rw [← card_neighbor_set_eq_degree, subgraph.degree]; congr
#align simple_graph.subgraph.degree_spanning_coe SimpleGraph.Subgraph.degree_spanningCoe
-/

#print SimpleGraph.Subgraph.degree_eq_one_iff_unique_adj /-
theorem degree_eq_one_iff_unique_adj {G' : Subgraph G} {v : V} [Fintype (G'.neighborSet v)] :
    G'.degree v = 1 ↔ ∃! w : V, G'.Adj v w :=
  by
  rw [← finset_card_neighbor_set_eq_degree, Finset.card_eq_one, Finset.singleton_iff_unique_mem]
  simp only [Set.mem_toFinset, mem_neighbor_set]
#align simple_graph.subgraph.degree_eq_one_iff_unique_adj SimpleGraph.Subgraph.degree_eq_one_iff_unique_adj
-/

end Subgraph

section MkProperties

/-! ### Properties of `singleton_subgraph` and `subgraph_of_adj` -/


variable {G : SimpleGraph V} {G' : SimpleGraph W}

#print SimpleGraph.nonempty_singletonSubgraph_verts /-
instance nonempty_singletonSubgraph_verts (v : V) : Nonempty (G.singletonSubgraph v).verts :=
  ⟨⟨v, Set.mem_singleton v⟩⟩
#align simple_graph.nonempty_singleton_subgraph_verts SimpleGraph.nonempty_singletonSubgraph_verts
-/

#print SimpleGraph.singletonSubgraph_le_iff /-
@[simp]
theorem singletonSubgraph_le_iff (v : V) (H : G.Subgraph) :
    G.singletonSubgraph v ≤ H ↔ v ∈ H.verts :=
  by
  refine' ⟨fun h => h.1 (Set.mem_singleton v), _⟩
  intro h
  constructor
  · simp [h]
  · simp [-Set.bot_eq_empty]
#align simple_graph.singleton_subgraph_le_iff SimpleGraph.singletonSubgraph_le_iff
-/

#print SimpleGraph.map_singletonSubgraph /-
@[simp]
theorem map_singletonSubgraph (f : G →g G') {v : V} :
    Subgraph.map f (G.singletonSubgraph v) = G'.singletonSubgraph (f v) := by
  ext <;>
    simp only [Relation.Map, subgraph.map_adj, singleton_subgraph_adj, Pi.bot_apply,
      exists_and_left, and_iff_left_iff_imp, IsEmpty.forall_iff, subgraph.map_verts,
      singleton_subgraph_verts, Set.image_singleton]
#align simple_graph.map_singleton_subgraph SimpleGraph.map_singletonSubgraph
-/

#print SimpleGraph.neighborSet_singletonSubgraph /-
@[simp]
theorem neighborSet_singletonSubgraph (v w : V) : (G.singletonSubgraph v).neighborSet w = ∅ := by
  ext u; rfl
#align simple_graph.neighbor_set_singleton_subgraph SimpleGraph.neighborSet_singletonSubgraph
-/

#print SimpleGraph.edgeSet_singletonSubgraph /-
@[simp]
theorem edgeSet_singletonSubgraph (v : V) : (G.singletonSubgraph v).edgeSetEmbedding = ∅ :=
  Sym2.fromRel_bot
#align simple_graph.edge_set_singleton_subgraph SimpleGraph.edgeSet_singletonSubgraph
-/

#print SimpleGraph.eq_singletonSubgraph_iff_verts_eq /-
theorem eq_singletonSubgraph_iff_verts_eq (H : G.Subgraph) {v : V} :
    H = G.singletonSubgraph v ↔ H.verts = {v} :=
  by
  refine' ⟨fun h => by simp [h], fun h => _⟩
  ext
  · rw [h, singleton_subgraph_verts]
  · simp only [Prop.bot_eq_false, singleton_subgraph_adj, Pi.bot_apply, iff_false_iff]
    intro ha
    have ha1 := ha.fst_mem
    have ha2 := ha.snd_mem
    rw [h, Set.mem_singleton_iff] at ha1 ha2 
    subst_vars
    exact ha.ne rfl
#align simple_graph.eq_singleton_subgraph_iff_verts_eq SimpleGraph.eq_singletonSubgraph_iff_verts_eq
-/

#print SimpleGraph.nonempty_subgraphOfAdj_verts /-
instance nonempty_subgraphOfAdj_verts {v w : V} (hvw : G.Adj v w) :
    Nonempty (G.subgraphOfAdj hvw).verts :=
  ⟨⟨v, by simp⟩⟩
#align simple_graph.nonempty_subgraph_of_adj_verts SimpleGraph.nonempty_subgraphOfAdj_verts
-/

#print SimpleGraph.edgeSet_subgraphOfAdj /-
@[simp]
theorem edgeSet_subgraphOfAdj {v w : V} (hvw : G.Adj v w) :
    (G.subgraphOfAdj hvw).edgeSetEmbedding = {⟦(v, w)⟧} :=
  by
  ext e
  refine' e.ind _
  simp only [eq_comm, Set.mem_singleton_iff, subgraph.mem_edge_set, subgraph_of_adj_adj,
    iff_self_iff, forall₂_true_iff]
#align simple_graph.edge_set_subgraph_of_adj SimpleGraph.edgeSet_subgraphOfAdj
-/

#print SimpleGraph.subgraphOfAdj_symm /-
theorem subgraphOfAdj_symm {v w : V} (hvw : G.Adj v w) :
    G.subgraphOfAdj hvw.symm = G.subgraphOfAdj hvw := by ext <;> simp [or_comm', and_comm']
#align simple_graph.subgraph_of_adj_symm SimpleGraph.subgraphOfAdj_symm
-/

#print SimpleGraph.map_subgraphOfAdj /-
@[simp]
theorem map_subgraphOfAdj (f : G →g G') {v w : V} (hvw : G.Adj v w) :
    Subgraph.map f (G.subgraphOfAdj hvw) = G'.subgraphOfAdj (f.map_adj hvw) :=
  by
  ext
  · simp only [subgraph.map_verts, subgraph_of_adj_verts, Set.mem_image, Set.mem_insert_iff,
      Set.mem_singleton_iff]
    constructor
    · rintro ⟨u, rfl | rfl, rfl⟩ <;> simp
    · rintro (rfl | rfl)
      · use v; simp
      · use w; simp
  · simp only [Relation.Map, subgraph.map_adj, subgraph_of_adj_adj, Quotient.eq', Sym2.rel_iff]
    constructor
    · rintro ⟨a, b, ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩, rfl, rfl⟩ <;> simp
    · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
      · use v, w; simp
      · use w, v; simp
#align simple_graph.map_subgraph_of_adj SimpleGraph.map_subgraphOfAdj
-/

#print SimpleGraph.neighborSet_subgraphOfAdj_subset /-
theorem neighborSet_subgraphOfAdj_subset {u v w : V} (hvw : G.Adj v w) :
    (G.subgraphOfAdj hvw).neighborSet u ⊆ {v, w} :=
  (G.subgraphOfAdj hvw).neighborSet_subset_verts _
#align simple_graph.neighbor_set_subgraph_of_adj_subset SimpleGraph.neighborSet_subgraphOfAdj_subset
-/

#print SimpleGraph.neighborSet_fst_subgraphOfAdj /-
@[simp]
theorem neighborSet_fst_subgraphOfAdj {v w : V} (hvw : G.Adj v w) :
    (G.subgraphOfAdj hvw).neighborSet v = {w} :=
  by
  ext u
  suffices w = u ↔ u = w by simpa [hvw.ne.symm] using this
  rw [eq_comm]
#align simple_graph.neighbor_set_fst_subgraph_of_adj SimpleGraph.neighborSet_fst_subgraphOfAdj
-/

#print SimpleGraph.neighborSet_snd_subgraphOfAdj /-
@[simp]
theorem neighborSet_snd_subgraphOfAdj {v w : V} (hvw : G.Adj v w) :
    (G.subgraphOfAdj hvw).neighborSet w = {v} :=
  by
  rw [subgraph_of_adj_symm hvw.symm]
  exact neighbor_set_fst_subgraph_of_adj hvw.symm
#align simple_graph.neighbor_set_snd_subgraph_of_adj SimpleGraph.neighborSet_snd_subgraphOfAdj
-/

#print SimpleGraph.neighborSet_subgraphOfAdj_of_ne_of_ne /-
@[simp]
theorem neighborSet_subgraphOfAdj_of_ne_of_ne {u v w : V} (hvw : G.Adj v w) (hv : u ≠ v)
    (hw : u ≠ w) : (G.subgraphOfAdj hvw).neighborSet u = ∅ := by ext; simp [hv.symm, hw.symm]
#align simple_graph.neighbor_set_subgraph_of_adj_of_ne_of_ne SimpleGraph.neighborSet_subgraphOfAdj_of_ne_of_ne
-/

#print SimpleGraph.neighborSet_subgraphOfAdj /-
theorem neighborSet_subgraphOfAdj [DecidableEq V] {u v w : V} (hvw : G.Adj v w) :
    (G.subgraphOfAdj hvw).neighborSet u = (if u = v then {w} else ∅) ∪ if u = w then {v} else ∅ :=
  by split_ifs <;> subst_vars <;> simp [*]
#align simple_graph.neighbor_set_subgraph_of_adj SimpleGraph.neighborSet_subgraphOfAdj
-/

#print SimpleGraph.singletonSubgraph_fst_le_subgraphOfAdj /-
theorem singletonSubgraph_fst_le_subgraphOfAdj {u v : V} {h : G.Adj u v} :
    G.singletonSubgraph u ≤ G.subgraphOfAdj h := by constructor <;> simp [-Set.bot_eq_empty]
#align simple_graph.singleton_subgraph_fst_le_subgraph_of_adj SimpleGraph.singletonSubgraph_fst_le_subgraphOfAdj
-/

#print SimpleGraph.singletonSubgraph_snd_le_subgraphOfAdj /-
theorem singletonSubgraph_snd_le_subgraphOfAdj {u v : V} {h : G.Adj u v} :
    G.singletonSubgraph v ≤ G.subgraphOfAdj h := by constructor <;> simp [-Set.bot_eq_empty]
#align simple_graph.singleton_subgraph_snd_le_subgraph_of_adj SimpleGraph.singletonSubgraph_snd_le_subgraphOfAdj
-/

end MkProperties

namespace Subgraph

variable {G : SimpleGraph V}

/-! ### Subgraphs of subgraphs -/


#print SimpleGraph.Subgraph.coeSubgraph /-
/-- Given a subgraph of a subgraph of `G`, construct a subgraph of `G`. -/
@[reducible]
protected def coeSubgraph {G' : G.Subgraph} : G'.coe.Subgraph → G.Subgraph :=
  Subgraph.map G'.hom
#align simple_graph.subgraph.coe_subgraph SimpleGraph.Subgraph.coeSubgraph
-/

#print SimpleGraph.Subgraph.restrict /-
/-- Given a subgraph of `G`, restrict it to being a subgraph of another subgraph `G'` by
taking the portion of `G` that intersects `G'`. -/
@[reducible]
protected def restrict {G' : G.Subgraph} : G.Subgraph → G'.coe.Subgraph :=
  Subgraph.comap G'.hom
#align simple_graph.subgraph.restrict SimpleGraph.Subgraph.restrict
-/

#print SimpleGraph.Subgraph.restrict_coeSubgraph /-
theorem restrict_coeSubgraph {G' : G.Subgraph} (G'' : G'.coe.Subgraph) :
    G''.coeSubgraph.restrict = G'' := by
  ext
  · simp
  · simp only [Relation.Map, comap_adj, coe_adj, Subtype.coe_prop, hom_apply, map_adj,
      SetCoe.exists, Subtype.coe_mk, exists_and_right, exists_eq_right_right, Subtype.coe_eta,
      exists_true_left, exists_eq_right, and_iff_right_iff_imp]
    apply G''.adj_sub
#align simple_graph.subgraph.restrict_coe_subgraph SimpleGraph.Subgraph.restrict_coeSubgraph
-/

#print SimpleGraph.Subgraph.coeSubgraph_injective /-
theorem coeSubgraph_injective (G' : G.Subgraph) :
    Function.Injective (Subgraph.coeSubgraph : G'.coe.Subgraph → G.Subgraph) :=
  Function.LeftInverse.injective restrict_coeSubgraph
#align simple_graph.subgraph.coe_subgraph_injective SimpleGraph.Subgraph.coeSubgraph_injective
-/

/-! ### Edge deletion -/


#print SimpleGraph.Subgraph.deleteEdges /-
/-- Given a subgraph `G'` and a set of vertex pairs, remove all of the corresponding edges
from its edge set, if present.

See also: `simple_graph.delete_edges`. -/
def deleteEdges (G' : G.Subgraph) (s : Set (Sym2 V)) : G.Subgraph
    where
  verts := G'.verts
  Adj := G'.Adj \ Sym2.ToRel s
  adj_sub a b h' := G'.adj_sub h'.1
  edge_vert a b h' := G'.edge_vert h'.1
  symm a b := by simp [G'.adj_comm, Sym2.eq_swap]
#align simple_graph.subgraph.delete_edges SimpleGraph.Subgraph.deleteEdges
-/

section DeleteEdges

variable {G' : G.Subgraph} (s : Set (Sym2 V))

#print SimpleGraph.Subgraph.deleteEdges_verts /-
@[simp]
theorem deleteEdges_verts : (G'.deleteEdges s).verts = G'.verts :=
  rfl
#align simple_graph.subgraph.delete_edges_verts SimpleGraph.Subgraph.deleteEdges_verts
-/

#print SimpleGraph.Subgraph.deleteEdges_adj /-
@[simp]
theorem deleteEdges_adj (v w : V) : (G'.deleteEdges s).Adj v w ↔ G'.Adj v w ∧ ¬⟦(v, w)⟧ ∈ s :=
  Iff.rfl
#align simple_graph.subgraph.delete_edges_adj SimpleGraph.Subgraph.deleteEdges_adj
-/

#print SimpleGraph.Subgraph.deleteEdges_deleteEdges /-
@[simp]
theorem deleteEdges_deleteEdges (s s' : Set (Sym2 V)) :
    (G'.deleteEdges s).deleteEdges s' = G'.deleteEdges (s ∪ s') := by
  ext <;> simp [and_assoc', not_or]
#align simple_graph.subgraph.delete_edges_delete_edges SimpleGraph.Subgraph.deleteEdges_deleteEdges
-/

#print SimpleGraph.Subgraph.deleteEdges_empty_eq /-
@[simp]
theorem deleteEdges_empty_eq : G'.deleteEdges ∅ = G' := by ext <;> simp
#align simple_graph.subgraph.delete_edges_empty_eq SimpleGraph.Subgraph.deleteEdges_empty_eq
-/

#print SimpleGraph.Subgraph.deleteEdges_spanningCoe_eq /-
@[simp]
theorem deleteEdges_spanningCoe_eq :
    G'.spanningCoe.deleteEdges s = (G'.deleteEdges s).spanningCoe := by ext; simp
#align simple_graph.subgraph.delete_edges_spanning_coe_eq SimpleGraph.Subgraph.deleteEdges_spanningCoe_eq
-/

#print SimpleGraph.Subgraph.deleteEdges_coe_eq /-
theorem deleteEdges_coe_eq (s : Set (Sym2 G'.verts)) :
    G'.coe.deleteEdges s = (G'.deleteEdges (Sym2.map coe '' s)).coe :=
  by
  ext ⟨v, hv⟩ ⟨w, hw⟩
  simp only [SimpleGraph.deleteEdges_adj, coe_adj, Subtype.coe_mk, delete_edges_adj, Set.mem_image,
    not_exists, not_and, and_congr_right_iff]
  intro h
  constructor
  · intro hs
    refine' Sym2.ind _
    rintro ⟨v', hv'⟩ ⟨w', hw'⟩
    simp only [Sym2.map_pair_eq, Subtype.coe_mk, Quotient.eq']
    contrapose!
    rintro (_ | _) <;> simpa [Sym2.eq_swap]
  · intro h' hs
    exact h' _ hs rfl
#align simple_graph.subgraph.delete_edges_coe_eq SimpleGraph.Subgraph.deleteEdges_coe_eq
-/

#print SimpleGraph.Subgraph.coe_deleteEdges_eq /-
theorem coe_deleteEdges_eq (s : Set (Sym2 V)) :
    (G'.deleteEdges s).coe = G'.coe.deleteEdges (Sym2.map coe ⁻¹' s) := by ext ⟨v, hv⟩ ⟨w, hw⟩; simp
#align simple_graph.subgraph.coe_delete_edges_eq SimpleGraph.Subgraph.coe_deleteEdges_eq
-/

#print SimpleGraph.Subgraph.deleteEdges_le /-
theorem deleteEdges_le : G'.deleteEdges s ≤ G' := by
  constructor <;> simp (config := { contextual := true })
#align simple_graph.subgraph.delete_edges_le SimpleGraph.Subgraph.deleteEdges_le
-/

#print SimpleGraph.Subgraph.deleteEdges_le_of_le /-
theorem deleteEdges_le_of_le {s s' : Set (Sym2 V)} (h : s ⊆ s') :
    G'.deleteEdges s' ≤ G'.deleteEdges s :=
  by
  constructor <;>
    simp (config := { contextual := true }) only [delete_edges_verts, delete_edges_adj,
      true_and_iff, and_imp]
  exact fun v w hvw hs' hs => hs' (h hs)
#align simple_graph.subgraph.delete_edges_le_of_le SimpleGraph.Subgraph.deleteEdges_le_of_le
-/

#print SimpleGraph.Subgraph.deleteEdges_inter_edgeSet_left_eq /-
@[simp]
theorem deleteEdges_inter_edgeSet_left_eq :
    G'.deleteEdges (G'.edgeSetEmbedding ∩ s) = G'.deleteEdges s := by
  ext <;> simp (config := { contextual := true }) [imp_false]
#align simple_graph.subgraph.delete_edges_inter_edge_set_left_eq SimpleGraph.Subgraph.deleteEdges_inter_edgeSet_left_eq
-/

#print SimpleGraph.Subgraph.deleteEdges_inter_edgeSet_right_eq /-
@[simp]
theorem deleteEdges_inter_edgeSet_right_eq :
    G'.deleteEdges (s ∩ G'.edgeSetEmbedding) = G'.deleteEdges s := by
  ext <;> simp (config := { contextual := true }) [imp_false]
#align simple_graph.subgraph.delete_edges_inter_edge_set_right_eq SimpleGraph.Subgraph.deleteEdges_inter_edgeSet_right_eq
-/

#print SimpleGraph.Subgraph.coe_deleteEdges_le /-
theorem coe_deleteEdges_le : (G'.deleteEdges s).coe ≤ (G'.coe : SimpleGraph G'.verts) := fun v w =>
  by simp (config := { contextual := true })
#align simple_graph.subgraph.coe_delete_edges_le SimpleGraph.Subgraph.coe_deleteEdges_le
-/

#print SimpleGraph.Subgraph.spanningCoe_deleteEdges_le /-
theorem spanningCoe_deleteEdges_le (G' : G.Subgraph) (s : Set (Sym2 V)) :
    (G'.deleteEdges s).spanningCoe ≤ G'.spanningCoe :=
  spanningCoe_le_of_le (deleteEdges_le s)
#align simple_graph.subgraph.spanning_coe_delete_edges_le SimpleGraph.Subgraph.spanningCoe_deleteEdges_le
-/

end DeleteEdges

/-! ### Induced subgraphs -/


#print SimpleGraph.Subgraph.induce /-
/- Given a subgraph, we can change its vertex set while removing any invalid edges, which
gives induced subgraphs. See also `simple_graph.induce` for the `simple_graph` version, which,
unlike for subgraphs, results in a graph with a different vertex type. -/
/-- The induced subgraph of a subgraph. The expectation is that `s ⊆ G'.verts` for the usual
notion of an induced subgraph, but, in general, `s` is taken to be the new vertex set and edges
are induced from the subgraph `G'`. -/
@[simps]
def induce (G' : G.Subgraph) (s : Set V) : G.Subgraph
    where
  verts := s
  Adj u v := u ∈ s ∧ v ∈ s ∧ G'.Adj u v
  adj_sub u v := by rintro ⟨-, -, ha⟩; exact G'.adj_sub ha
  edge_vert u v := by rintro ⟨h, -, -⟩; exact h
#align simple_graph.subgraph.induce SimpleGraph.Subgraph.induce
-/

#print SimpleGraph.induce_eq_coe_induce_top /-
theorem SimpleGraph.induce_eq_coe_induce_top (s : Set V) :
    G.induce s = ((⊤ : G.Subgraph).induce s).coe := by ext v w; simp
#align simple_graph.induce_eq_coe_induce_top SimpleGraph.induce_eq_coe_induce_top
-/

section Induce

variable {G' G'' : G.Subgraph} {s s' : Set V}

#print SimpleGraph.Subgraph.induce_mono /-
theorem induce_mono (hg : G' ≤ G'') (hs : s ⊆ s') : G'.induce s ≤ G''.induce s' :=
  by
  constructor
  · simp [hs]
  · simp (config := { contextual := true }) only [induce_adj, true_and_iff, and_imp]
    intro v w hv hw ha
    exact ⟨hs hv, hs hw, hg.2 ha⟩
#align simple_graph.subgraph.induce_mono SimpleGraph.Subgraph.induce_mono
-/

#print SimpleGraph.Subgraph.induce_mono_left /-
@[mono]
theorem induce_mono_left (hg : G' ≤ G'') : G'.induce s ≤ G''.induce s :=
  induce_mono hg (by rfl)
#align simple_graph.subgraph.induce_mono_left SimpleGraph.Subgraph.induce_mono_left
-/

#print SimpleGraph.Subgraph.induce_mono_right /-
@[mono]
theorem induce_mono_right (hs : s ⊆ s') : G'.induce s ≤ G'.induce s' :=
  induce_mono (by rfl) hs
#align simple_graph.subgraph.induce_mono_right SimpleGraph.Subgraph.induce_mono_right
-/

#print SimpleGraph.Subgraph.induce_empty /-
@[simp]
theorem induce_empty : G'.induce ∅ = ⊥ := by ext <;> simp
#align simple_graph.subgraph.induce_empty SimpleGraph.Subgraph.induce_empty
-/

#print SimpleGraph.Subgraph.induce_self_verts /-
@[simp]
theorem induce_self_verts : G'.induce G'.verts = G' :=
  by
  ext
  · simp
  · constructor <;>
      simp (config := { contextual := true }) only [induce_adj, imp_true_iff, and_true_iff]
    exact fun ha => ⟨G'.edge_vert ha, G'.edge_vert ha.symm⟩
#align simple_graph.subgraph.induce_self_verts SimpleGraph.Subgraph.induce_self_verts
-/

#print SimpleGraph.Subgraph.singletonSubgraph_eq_induce /-
theorem singletonSubgraph_eq_induce {v : V} : G.singletonSubgraph v = (⊤ : G.Subgraph).induce {v} :=
  by ext <;> simp (config := { contextual := true }) [-Set.bot_eq_empty, Prop.bot_eq_false]
#align simple_graph.subgraph.singleton_subgraph_eq_induce SimpleGraph.Subgraph.singletonSubgraph_eq_induce
-/

#print SimpleGraph.Subgraph.subgraphOfAdj_eq_induce /-
theorem subgraphOfAdj_eq_induce {v w : V} (hvw : G.Adj v w) :
    G.subgraphOfAdj hvw = (⊤ : G.Subgraph).induce {v, w} :=
  by
  ext
  · simp
  · constructor
    · intro h
      simp only [subgraph_of_adj_adj, Quotient.eq', Sym2.rel_iff] at h 
      obtain ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ := h <;> simp [hvw, hvw.symm]
    · intro h
      simp only [induce_adj, Set.mem_insert_iff, Set.mem_singleton_iff, top_adj] at h 
      obtain ⟨rfl | rfl, rfl | rfl, ha⟩ := h <;>
        first
        | exact (ha.ne rfl).elim
        | simp
#align simple_graph.subgraph.subgraph_of_adj_eq_induce SimpleGraph.Subgraph.subgraphOfAdj_eq_induce
-/

end Induce

#print SimpleGraph.Subgraph.deleteVerts /-
/-- Given a subgraph and a set of vertices, delete all the vertices from the subgraph,
if present. Any edges indicent to the deleted vertices are deleted as well. -/
@[reducible]
def deleteVerts (G' : G.Subgraph) (s : Set V) : G.Subgraph :=
  G'.induce (G'.verts \ s)
#align simple_graph.subgraph.delete_verts SimpleGraph.Subgraph.deleteVerts
-/

section DeleteVerts

variable {G' : G.Subgraph} {s : Set V}

#print SimpleGraph.Subgraph.deleteVerts_verts /-
theorem deleteVerts_verts : (G'.deleteVerts s).verts = G'.verts \ s :=
  rfl
#align simple_graph.subgraph.delete_verts_verts SimpleGraph.Subgraph.deleteVerts_verts
-/

#print SimpleGraph.Subgraph.deleteVerts_adj /-
theorem deleteVerts_adj {u v : V} :
    (G'.deleteVerts s).Adj u v ↔ u ∈ G'.verts ∧ ¬u ∈ s ∧ v ∈ G'.verts ∧ ¬v ∈ s ∧ G'.Adj u v := by
  simp [and_assoc']
#align simple_graph.subgraph.delete_verts_adj SimpleGraph.Subgraph.deleteVerts_adj
-/

#print SimpleGraph.Subgraph.deleteVerts_deleteVerts /-
@[simp]
theorem deleteVerts_deleteVerts (s s' : Set V) :
    (G'.deleteVerts s).deleteVerts s' = G'.deleteVerts (s ∪ s') := by
  ext <;> simp (config := { contextual := true }) [not_or, and_assoc']
#align simple_graph.subgraph.delete_verts_delete_verts SimpleGraph.Subgraph.deleteVerts_deleteVerts
-/

#print SimpleGraph.Subgraph.deleteVerts_empty /-
@[simp]
theorem deleteVerts_empty : G'.deleteVerts ∅ = G' := by simp [delete_verts]
#align simple_graph.subgraph.delete_verts_empty SimpleGraph.Subgraph.deleteVerts_empty
-/

#print SimpleGraph.Subgraph.deleteVerts_le /-
theorem deleteVerts_le : G'.deleteVerts s ≤ G' := by constructor <;> simp [Set.diff_subset]
#align simple_graph.subgraph.delete_verts_le SimpleGraph.Subgraph.deleteVerts_le
-/

#print SimpleGraph.Subgraph.deleteVerts_mono /-
@[mono]
theorem deleteVerts_mono {G' G'' : G.Subgraph} (h : G' ≤ G'') :
    G'.deleteVerts s ≤ G''.deleteVerts s :=
  induce_mono h (Set.diff_subset_diff_left h.1)
#align simple_graph.subgraph.delete_verts_mono SimpleGraph.Subgraph.deleteVerts_mono
-/

#print SimpleGraph.Subgraph.deleteVerts_anti /-
@[mono]
theorem deleteVerts_anti {s s' : Set V} (h : s ⊆ s') : G'.deleteVerts s' ≤ G'.deleteVerts s :=
  induce_mono (le_refl _) (Set.diff_subset_diff_right h)
#align simple_graph.subgraph.delete_verts_anti SimpleGraph.Subgraph.deleteVerts_anti
-/

#print SimpleGraph.Subgraph.deleteVerts_inter_verts_left_eq /-
@[simp]
theorem deleteVerts_inter_verts_left_eq : G'.deleteVerts (G'.verts ∩ s) = G'.deleteVerts s := by
  ext <;> simp (config := { contextual := true }) [imp_false]
#align simple_graph.subgraph.delete_verts_inter_verts_left_eq SimpleGraph.Subgraph.deleteVerts_inter_verts_left_eq
-/

#print SimpleGraph.Subgraph.deleteVerts_inter_verts_set_right_eq /-
@[simp]
theorem deleteVerts_inter_verts_set_right_eq : G'.deleteVerts (s ∩ G'.verts) = G'.deleteVerts s :=
  by ext <;> simp (config := { contextual := true }) [imp_false]
#align simple_graph.subgraph.delete_verts_inter_verts_set_right_eq SimpleGraph.Subgraph.deleteVerts_inter_verts_set_right_eq
-/

end DeleteVerts

end Subgraph

end SimpleGraph

