/-
Copyright (c) 2022 Anand Rao, Rémi Bottinelli. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anand Rao, Rémi Bottinelli

! This file was ported from Lean 3 source module combinatorics.simple_graph.ends.defs
! leanprover-community/mathlib commit 2ed2c6310e6f1c5562bdf6bfbda55ebbf6891abe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.CofilteredSystem
import Mathbin.Combinatorics.SimpleGraph.Connectivity
import Mathbin.Data.SetLike.Basic

/-!
# Ends

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains a definition of the ends of a simple graph, as sections of the inverse system
assigning, to each finite set of vertices, the connected components of its complement.
-/


universe u

variable {V : Type u} (G : SimpleGraph V) (K L L' M : Set V)

namespace SimpleGraph

#print SimpleGraph.ComponentCompl /-
/-- The components outside a given set of vertices `K` -/
@[reducible]
def ComponentCompl :=
  (G.induce (Kᶜ)).connectedComponent
#align simple_graph.component_compl SimpleGraph.ComponentCompl
-/

variable {G} {K L M}

#print SimpleGraph.componentComplMk /-
/-- The connected component of `v` in `G.induce Kᶜ`. -/
@[reducible]
def componentComplMk (G : SimpleGraph V) {v : V} (vK : v ∉ K) : G.ComponentCompl K :=
  connectedComponentMk (G.induce (Kᶜ)) ⟨v, vK⟩
#align simple_graph.component_compl_mk SimpleGraph.componentComplMk
-/

#print SimpleGraph.ComponentCompl.supp /-
/-- The set of vertices of `G` making up the connected component `C` -/
def ComponentCompl.supp (C : G.ComponentCompl K) : Set V :=
  {v : V | ∃ h : v ∉ K, G.componentComplMk h = C}
#align simple_graph.component_compl.supp SimpleGraph.ComponentCompl.supp
-/

#print SimpleGraph.ComponentCompl.supp_injective /-
@[ext]
theorem ComponentCompl.supp_injective :
    Function.Injective (ComponentCompl.supp : G.ComponentCompl K → Set V) :=
  by
  refine' connected_component.ind₂ _
  rintro ⟨v, hv⟩ ⟨w, hw⟩ h
  simp only [Set.ext_iff, connected_component.eq, Set.mem_setOf_eq, component_compl.supp] at h ⊢
  exact ((h v).mp ⟨hv, reachable.refl _⟩).choose_spec
#align simple_graph.component_compl.supp_injective SimpleGraph.ComponentCompl.supp_injective
-/

#print SimpleGraph.ComponentCompl.supp_inj /-
theorem ComponentCompl.supp_inj {C D : G.ComponentCompl K} : C.supp = D.supp ↔ C = D :=
  ComponentCompl.supp_injective.eq_iff
#align simple_graph.component_compl.supp_inj SimpleGraph.ComponentCompl.supp_inj
-/

#print SimpleGraph.ComponentCompl.setLike /-
instance ComponentCompl.setLike : SetLike (G.ComponentCompl K) V
    where
  coe := ComponentCompl.supp
  coe_injective' C D := ComponentCompl.supp_inj.mp
#align simple_graph.component_compl.set_like SimpleGraph.ComponentCompl.setLike
-/

#print SimpleGraph.ComponentCompl.mem_supp_iff /-
@[simp]
theorem ComponentCompl.mem_supp_iff {v : V} {C : ComponentCompl G K} :
    v ∈ C ↔ ∃ vK : v ∉ K, G.componentComplMk vK = C :=
  Iff.rfl
#align simple_graph.component_compl.mem_supp_iff SimpleGraph.ComponentCompl.mem_supp_iff
-/

#print SimpleGraph.componentComplMk_mem /-
theorem componentComplMk_mem (G : SimpleGraph V) {v : V} (vK : v ∉ K) : v ∈ G.componentComplMk vK :=
  ⟨vK, rfl⟩
#align simple_graph.component_compl_mk_mem SimpleGraph.componentComplMk_mem
-/

#print SimpleGraph.componentComplMk_eq_of_adj /-
theorem componentComplMk_eq_of_adj (G : SimpleGraph V) {v w : V} (vK : v ∉ K) (wK : w ∉ K)
    (a : G.adj v w) : G.componentComplMk vK = G.componentComplMk wK := by
  rw [connected_component.eq]; apply adj.reachable; exact a
#align simple_graph.component_compl_mk_eq_of_adj SimpleGraph.componentComplMk_eq_of_adj
-/

namespace ComponentCompl

#print SimpleGraph.ComponentCompl.lift /-
/-- A `component_compl` specialization of `quot.lift`, where soundness has to be proved only
for adjacent vertices.
-/
protected def lift {β : Sort _} (f : ∀ ⦃v⦄ (hv : v ∉ K), β)
    (h : ∀ ⦃v w⦄ (hv : v ∉ K) (hw : w ∉ K) (a : G.adj v w), f hv = f hw) : G.ComponentCompl K → β :=
  ConnectedComponent.lift (fun vv => f vv.Prop) fun v w p =>
    by
    induction' p with _ u v w a q ih
    · rintro _; rfl
    · rintro h'; exact (h u.prop v.prop a).trans (ih h'.of_cons)
#align simple_graph.component_compl.lift SimpleGraph.ComponentCompl.lift
-/

#print SimpleGraph.ComponentCompl.ind /-
protected theorem ind {β : G.ComponentCompl K → Prop}
    (f : ∀ ⦃v⦄ (hv : v ∉ K), β (G.componentComplMk hv)) : ∀ C : G.ComponentCompl K, β C := by
  apply connected_component.ind; exact fun ⟨v, vnK⟩ => f vnK
#align simple_graph.component_compl.ind SimpleGraph.ComponentCompl.ind
-/

#print SimpleGraph.ComponentCompl.coeGraph /-
/-- The induced graph on the vertices `C`. -/
@[reducible]
protected def coeGraph (C : ComponentCompl G K) : SimpleGraph C :=
  G.induce (C : Set V)
#align simple_graph.component_compl.coe_graph SimpleGraph.ComponentCompl.coeGraph
-/

#print SimpleGraph.ComponentCompl.coe_inj /-
theorem coe_inj {C D : G.ComponentCompl K} : (C : Set V) = (D : Set V) ↔ C = D :=
  SetLike.coe_set_eq
#align simple_graph.component_compl.coe_inj SimpleGraph.ComponentCompl.coe_inj
-/

#print SimpleGraph.ComponentCompl.nonempty /-
@[simp]
protected theorem nonempty (C : G.ComponentCompl K) : (C : Set V).Nonempty :=
  C.ind fun v vnK => ⟨v, vnK, rfl⟩
#align simple_graph.component_compl.nonempty SimpleGraph.ComponentCompl.nonempty
-/

#print SimpleGraph.ComponentCompl.exists_eq_mk /-
protected theorem exists_eq_mk (C : G.ComponentCompl K) :
    ∃ (v : _) (h : v ∉ K), G.componentComplMk h = C :=
  C.Nonempty
#align simple_graph.component_compl.exists_eq_mk SimpleGraph.ComponentCompl.exists_eq_mk
-/

#print SimpleGraph.ComponentCompl.disjoint_right /-
protected theorem disjoint_right (C : G.ComponentCompl K) : Disjoint K C :=
  by
  rw [Set.disjoint_iff]
  exact fun v ⟨vK, vC⟩ => vC.some vK
#align simple_graph.component_compl.disjoint_right SimpleGraph.ComponentCompl.disjoint_right
-/

#print SimpleGraph.ComponentCompl.not_mem_of_mem /-
theorem not_mem_of_mem {C : G.ComponentCompl K} {c : V} (cC : c ∈ C) : c ∉ K := fun cK =>
  Set.disjoint_iff.mp C.disjoint_right ⟨cK, cC⟩
#align simple_graph.component_compl.not_mem_of_mem SimpleGraph.ComponentCompl.not_mem_of_mem
-/

#print SimpleGraph.ComponentCompl.pairwise_disjoint /-
protected theorem pairwise_disjoint :
    Pairwise fun C D : G.ComponentCompl K => Disjoint (C : Set V) (D : Set V) :=
  by
  rintro C D ne
  rw [Set.disjoint_iff]
  exact fun u ⟨uC, uD⟩ => Ne (uC.some_spec.symm.trans uD.choose_spec)
#align simple_graph.component_compl.pairwise_disjoint SimpleGraph.ComponentCompl.pairwise_disjoint
-/

#print SimpleGraph.ComponentCompl.mem_of_adj /-
/-- Any vertex adjacent to a vertex of `C` and not lying in `K` must lie in `C`.
-/
theorem mem_of_adj : ∀ {C : G.ComponentCompl K} (c d : V), c ∈ C → d ∉ K → G.adj c d → d ∈ C :=
  fun C c d ⟨cnK, h⟩ dnK cd =>
  ⟨dnK, by rw [← h, connected_component.eq]; exact adj.reachable cd.symm⟩
#align simple_graph.component_compl.mem_of_adj SimpleGraph.ComponentCompl.mem_of_adj
-/

#print SimpleGraph.ComponentCompl.exists_adj_boundary_pair /-
/--
Assuming `G` is preconnected and `K` not empty, given any connected component `C` outside of `K`,
there exists a vertex `k ∈ K` adjacent to a vertex `v ∈ C`.
-/
theorem exists_adj_boundary_pair (Gc : G.Preconnected) (hK : K.Nonempty) :
    ∀ C : G.ComponentCompl K, ∃ ck : V × V, ck.1 ∈ C ∧ ck.2 ∈ K ∧ G.adj ck.1 ck.2 :=
  by
  refine' component_compl.ind fun v vnK => _
  let C : G.component_compl K := G.component_compl_mk vnK
  let dis := set.disjoint_iff.mp C.disjoint_right
  by_contra' h
  suffices Set.univ = (C : Set V) by exact dis ⟨hK.some_spec, this ▸ Set.mem_univ hK.some⟩
  symm
  rw [Set.eq_univ_iff_forall]
  rintro u
  by_contra unC
  obtain ⟨p⟩ := Gc v u
  obtain ⟨⟨⟨x, y⟩, xy⟩, d, xC, ynC⟩ :=
    p.exists_boundary_dart (C : Set V) (G.component_compl_mk_mem vnK) unC
  exact ynC (mem_of_adj x y xC (fun yK : y ∈ K => h ⟨x, y⟩ xC yK xy) xy)
#align simple_graph.component_compl.exists_adj_boundary_pair SimpleGraph.ComponentCompl.exists_adj_boundary_pair
-/

#print SimpleGraph.ComponentCompl.hom /-
/--
If `K ⊆ L`, the components outside of `L` are all contained in a single component outside of `K`.
-/
@[reducible]
def hom (h : K ⊆ L) (C : G.ComponentCompl L) : G.ComponentCompl K :=
  C.map <| InduceHom Hom.id <| Set.compl_subset_compl.2 h
#align simple_graph.component_compl.hom SimpleGraph.ComponentCompl.hom
-/

#print SimpleGraph.ComponentCompl.subset_hom /-
theorem subset_hom (C : G.ComponentCompl L) (h : K ⊆ L) : (C : Set V) ⊆ (C.hom h : Set V) := by
  rintro c ⟨cL, rfl⟩; exact ⟨fun h' => cL (h h'), rfl⟩
#align simple_graph.component_compl.subset_hom SimpleGraph.ComponentCompl.subset_hom
-/

#print SimpleGraph.componentComplMk_mem_hom /-
theorem SimpleGraph.componentComplMk_mem_hom (G : SimpleGraph V) {v : V} (vK : v ∉ K) (h : L ⊆ K) :
    v ∈ (G.componentComplMk vK).hom h :=
  subset_hom (G.componentComplMk vK) h (G.componentComplMk_mem vK)
#align simple_graph.component_compl_mk_mem_hom SimpleGraph.componentComplMk_mem_hom
-/

#print SimpleGraph.ComponentCompl.hom_eq_iff_le /-
theorem hom_eq_iff_le (C : G.ComponentCompl L) (h : K ⊆ L) (D : G.ComponentCompl K) :
    C.hom h = D ↔ (C : Set V) ⊆ (D : Set V) :=
  ⟨fun h' => h' ▸ C.subset_hom h, C.ind fun v vnL vD => (vD ⟨vnL, rfl⟩).choose_spec⟩
#align simple_graph.component_compl.hom_eq_iff_le SimpleGraph.ComponentCompl.hom_eq_iff_le
-/

#print SimpleGraph.ComponentCompl.hom_eq_iff_not_disjoint /-
theorem hom_eq_iff_not_disjoint (C : G.ComponentCompl L) (h : K ⊆ L) (D : G.ComponentCompl K) :
    C.hom h = D ↔ ¬Disjoint (C : Set V) (D : Set V) :=
  by
  rw [Set.not_disjoint_iff]
  constructor
  · rintro rfl
    apply C.ind fun x xnL => _
    exact ⟨x, ⟨xnL, rfl⟩, ⟨fun xK => xnL (h xK), rfl⟩⟩
  · apply C.ind fun x xnL => _
    rintro ⟨x, ⟨_, e₁⟩, _, rfl⟩
    rw [← e₁]; rfl
#align simple_graph.component_compl.hom_eq_iff_not_disjoint SimpleGraph.ComponentCompl.hom_eq_iff_not_disjoint
-/

#print SimpleGraph.ComponentCompl.hom_refl /-
theorem hom_refl (C : G.ComponentCompl L) : C.hom (subset_refl L) = C := by change C.map _ = C;
  erw [induce_hom_id G (Lᶜ), connected_component.map_id]
#align simple_graph.component_compl.hom_refl SimpleGraph.ComponentCompl.hom_refl
-/

#print SimpleGraph.ComponentCompl.hom_trans /-
theorem hom_trans (C : G.ComponentCompl L) (h : K ⊆ L) (h' : M ⊆ K) :
    C.hom (h'.trans h) = (C.hom h).hom h' := by change C.map _ = (C.map _).map _;
  erw [connected_component.map_comp, induce_hom_comp]; rfl
#align simple_graph.component_compl.hom_trans SimpleGraph.ComponentCompl.hom_trans
-/

#print SimpleGraph.ComponentCompl.hom_mk /-
theorem hom_mk {v : V} (vnL : v ∉ L) (h : K ⊆ L) :
    (G.componentComplMk vnL).hom h = G.componentComplMk (Set.not_mem_subset h vnL) :=
  rfl
#align simple_graph.component_compl.hom_mk SimpleGraph.ComponentCompl.hom_mk
-/

#print SimpleGraph.ComponentCompl.hom_infinite /-
theorem hom_infinite (C : G.ComponentCompl L) (h : K ⊆ L) (Cinf : (C : Set V).Infinite) :
    (C.hom h : Set V).Infinite :=
  Set.Infinite.mono (C.subset_hom h) Cinf
#align simple_graph.component_compl.hom_infinite SimpleGraph.ComponentCompl.hom_infinite
-/

#print SimpleGraph.ComponentCompl.infinite_iff_in_all_ranges /-
theorem infinite_iff_in_all_ranges {K : Finset V} (C : G.ComponentCompl K) :
    C.supp.Infinite ↔ ∀ (L) (h : K ⊆ L), ∃ D : G.ComponentCompl L, D.hom h = C := by
  classical
  constructor
  · rintro Cinf L h
    obtain ⟨v, ⟨vK, rfl⟩, vL⟩ := Set.Infinite.nonempty (Set.Infinite.diff Cinf L.finite_to_set)
    exact ⟨component_compl_mk _ vL, rfl⟩
  · rintro h Cfin
    obtain ⟨D, e⟩ := h (K ∪ Cfin.to_finset) (Finset.subset_union_left K Cfin.to_finset)
    obtain ⟨v, vD⟩ := D.nonempty
    let Ddis := D.disjoint_right
    simp_rw [Finset.coe_union, Set.Finite.coe_toFinset, Set.disjoint_union_left,
      Set.disjoint_iff] at Ddis 
    exact Ddis.right ⟨(component_compl.hom_eq_iff_le _ _ _).mp e vD, vD⟩
#align simple_graph.component_compl.infinite_iff_in_all_ranges SimpleGraph.ComponentCompl.infinite_iff_in_all_ranges
-/

end ComponentCompl

section Ends

variable (G)

open CategoryTheory

#print SimpleGraph.componentComplFunctor /-
/--
The functor assigning, to a finite set in `V`, the set of connected components in its complement.
-/
@[simps]
def componentComplFunctor : (Finset V)ᵒᵖ ⥤ Type u
    where
  obj K := G.ComponentCompl K.unop
  map _ _ f := ComponentCompl.hom (le_of_op_hom f)
  map_id' K := funext fun C => C.hom_refl
  map_comp' K L M h h' := funext fun C => C.hom_trans (le_of_op_hom h) (le_of_op_hom h')
#align simple_graph.component_compl_functor SimpleGraph.componentComplFunctor
-/

#print SimpleGraph.end /-
/-- The end of a graph, defined as the sections of the functor `component_compl_functor` . -/
@[protected]
def end :=
  (componentComplFunctor G).sections
#align simple_graph.end SimpleGraph.end
-/

#print SimpleGraph.end_hom_mk_of_mk /-
theorem end_hom_mk_of_mk {s} (sec : s ∈ G.end) {K L : (Finset V)ᵒᵖ} (h : L ⟶ K) {v : V}
    (vnL : v ∉ L.unop) (hs : s L = G.componentComplMk vnL) :
    s K = G.componentComplMk (Set.not_mem_subset (le_of_op_hom h) vnL) :=
  by
  rw [← sec h, hs]
  apply component_compl.hom_mk
#align simple_graph.end_hom_mk_of_mk SimpleGraph.end_hom_mk_of_mk
-/

#print SimpleGraph.infinite_iff_in_eventualRange /-
theorem infinite_iff_in_eventualRange {K : (Finset V)ᵒᵖ} (C : G.componentComplFunctor.obj K) :
    C.supp.Infinite ↔ C ∈ G.componentComplFunctor.eventualRange K :=
  by
  simp only [C.infinite_iff_in_all_ranges, CategoryTheory.Functor.eventualRange, Set.mem_iInter,
    Set.mem_range, component_compl_functor_map]
  exact
    ⟨fun h Lop KL => h Lop.unop (le_of_op_hom KL), fun h L KL =>
      h (Opposite.op L) (op_hom_of_le KL)⟩
#align simple_graph.infinite_iff_in_eventual_range SimpleGraph.infinite_iff_in_eventualRange
-/

end Ends

end SimpleGraph

