/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson, Jalex Stark, Kyle Miller, Lu-Ming Zhang

! This file was ported from Lean 3 source module combinatorics.simple_graph.adj_matrix
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Combinatorics.SimpleGraph.Basic
import Mathbin.Combinatorics.SimpleGraph.Connectivity
import Mathbin.LinearAlgebra.Matrix.Trace
import Mathbin.LinearAlgebra.Matrix.Symmetric

/-!
# Adjacency Matrices

This module defines the adjacency matrix of a graph, and provides theorems connecting graph
properties to computational properties of the matrix.

## Main definitions

* `matrix.is_adj_matrix`: `A : matrix V V α` is qualified as an "adjacency matrix" if
  (1) every entry of `A` is `0` or `1`,
  (2) `A` is symmetric,
  (3) every diagonal entry of `A` is `0`.

* `matrix.is_adj_matrix.to_graph`: for `A : matrix V V α` and `h : A.is_adj_matrix`,
  `h.to_graph` is the simple graph induced by `A`.

* `matrix.compl`: for `A : matrix V V α`, `A.compl` is supposed to be
  the adjacency matrix of the complement graph of the graph induced by `A`.

* `simple_graph.adj_matrix`: the adjacency matrix of a `simple_graph`.

* `simple_graph.adj_matrix_pow_apply_eq_card_walk`: each entry of the `n`th power of
  a graph's adjacency matrix counts the number of length-`n` walks between the corresponding
  pair of vertices.

-/


open BigOperators Matrix

open Finset Matrix SimpleGraph

variable {V α β : Type _}

namespace Matrix

/-- `A : matrix V V α` is qualified as an "adjacency matrix" if
    (1) every entry of `A` is `0` or `1`,
    (2) `A` is symmetric,
    (3) every diagonal entry of `A` is `0`. -/
structure IsAdjMatrix [Zero α] [One α] (A : Matrix V V α) : Prop where
  zero_or_one : ∀ i j, A i j = 0 ∨ A i j = 1 := by obviously
  symm : A.IsSymm := by obviously
  apply_diag : ∀ i, A i i = 0 := by obviously
#align matrix.is_adj_matrix Matrix.IsAdjMatrix

namespace IsAdjMatrix

variable {A : Matrix V V α}

@[simp]
theorem apply_diag_ne [MulZeroOneClass α] [Nontrivial α] (h : IsAdjMatrix A) (i : V) : ¬A i i = 1 :=
  by simp [h.apply_diag i]
#align matrix.is_adj_matrix.apply_diag_ne Matrix.IsAdjMatrix.apply_diag_ne

@[simp]
theorem apply_ne_one_iff [MulZeroOneClass α] [Nontrivial α] (h : IsAdjMatrix A) (i j : V) :
    ¬A i j = 1 ↔ A i j = 0 := by obtain h | h := h.zero_or_one i j <;> simp [h]
#align matrix.is_adj_matrix.apply_ne_one_iff Matrix.IsAdjMatrix.apply_ne_one_iff

@[simp]
theorem apply_ne_zero_iff [MulZeroOneClass α] [Nontrivial α] (h : IsAdjMatrix A) (i j : V) :
    ¬A i j = 0 ↔ A i j = 1 := by rw [← apply_ne_one_iff h, not_not]
#align matrix.is_adj_matrix.apply_ne_zero_iff Matrix.IsAdjMatrix.apply_ne_zero_iff

/-- For `A : matrix V V α` and `h : is_adj_matrix A`,
    `h.to_graph` is the simple graph whose adjacency matrix is `A`. -/
@[simps]
def toGraph [MulZeroOneClass α] [Nontrivial α] (h : IsAdjMatrix A) :
    SimpleGraph V where 
  Adj i j := A i j = 1
  symm i j hij := by rwa [h.symm.apply i j]
  loopless i := by simp [h]
#align matrix.is_adj_matrix.to_graph Matrix.IsAdjMatrix.toGraph

instance [MulZeroOneClass α] [Nontrivial α] [DecidableEq α] (h : IsAdjMatrix A) :
    DecidableRel h.toGraph.Adj := by 
  simp only [to_graph]
  infer_instance

end IsAdjMatrix

/-- For `A : matrix V V α`, `A.compl` is supposed to be the adjacency matrix of
    the complement graph of the graph induced by `A.adj_matrix`. -/
def compl [Zero α] [One α] [DecidableEq α] [DecidableEq V] (A : Matrix V V α) : Matrix V V α :=
  fun i j => ite (i = j) 0 (ite (A i j = 0) 1 0)
#align matrix.compl Matrix.compl

section Compl

variable [DecidableEq α] [DecidableEq V] (A : Matrix V V α)

@[simp]
theorem compl_apply_diag [Zero α] [One α] (i : V) : A.compl i i = 0 := by simp [compl]
#align matrix.compl_apply_diag Matrix.compl_apply_diag

@[simp]
theorem compl_apply [Zero α] [One α] (i j : V) : A.compl i j = 0 ∨ A.compl i j = 1 := by
  unfold compl
  split_ifs <;> simp
#align matrix.compl_apply Matrix.compl_apply

@[simp]
theorem is_symm_compl [Zero α] [One α] (h : A.IsSymm) : A.compl.IsSymm := by
  ext
  simp [compl, h.apply, eq_comm]
#align matrix.is_symm_compl Matrix.is_symm_compl

@[simp]
theorem is_adj_matrix_compl [Zero α] [One α] (h : A.IsSymm) : IsAdjMatrix A.compl :=
  { symm := by simp [h] }
#align matrix.is_adj_matrix_compl Matrix.is_adj_matrix_compl

namespace IsAdjMatrix

variable {A}

@[simp]
theorem compl [Zero α] [One α] (h : IsAdjMatrix A) : IsAdjMatrix A.compl :=
  is_adj_matrix_compl A h.symm
#align matrix.is_adj_matrix.compl Matrix.IsAdjMatrix.compl

theorem to_graph_compl_eq [MulZeroOneClass α] [Nontrivial α] (h : IsAdjMatrix A) :
    h.compl.toGraph = h.toGraphᶜ := by 
  ext (v w)
  cases' h.zero_or_one v w with h h <;> by_cases hvw : v = w <;> simp [Matrix.compl, h, hvw]
#align matrix.is_adj_matrix.to_graph_compl_eq Matrix.IsAdjMatrix.to_graph_compl_eq

end IsAdjMatrix

end Compl

end Matrix

open Matrix

namespace SimpleGraph

variable (G : SimpleGraph V) [DecidableRel G.Adj]

variable (α)

/-- `adj_matrix G α` is the matrix `A` such that `A i j = (1 : α)` if `i` and `j` are
  adjacent in the simple graph `G`, and otherwise `A i j = 0`. -/
def adjMatrix [Zero α] [One α] : Matrix V V α
  | i, j => if G.Adj i j then 1 else 0
#align simple_graph.adj_matrix SimpleGraph.adjMatrix

variable {α}

@[simp]
theorem adj_matrix_apply (v w : V) [Zero α] [One α] :
    G.adjMatrix α v w = if G.Adj v w then 1 else 0 :=
  rfl
#align simple_graph.adj_matrix_apply SimpleGraph.adj_matrix_apply

@[simp]
theorem transpose_adj_matrix [Zero α] [One α] : (G.adjMatrix α)ᵀ = G.adjMatrix α := by
  ext
  simp [adj_comm]
#align simple_graph.transpose_adj_matrix SimpleGraph.transpose_adj_matrix

@[simp]
theorem is_symm_adj_matrix [Zero α] [One α] : (G.adjMatrix α).IsSymm :=
  transpose_adj_matrix G
#align simple_graph.is_symm_adj_matrix SimpleGraph.is_symm_adj_matrix

variable (α)

/-- The adjacency matrix of `G` is an adjacency matrix. -/
@[simp]
theorem is_adj_matrix_adj_matrix [Zero α] [One α] : (G.adjMatrix α).IsAdjMatrix :=
  { zero_or_one := fun i j => by by_cases G.adj i j <;> simp [h] }
#align simple_graph.is_adj_matrix_adj_matrix SimpleGraph.is_adj_matrix_adj_matrix

/-- The graph induced by the adjacency matrix of `G` is `G` itself. -/
theorem to_graph_adj_matrix_eq [MulZeroOneClass α] [Nontrivial α] :
    (G.is_adj_matrix_adj_matrix α).toGraph = G := by
  ext
  simp only [is_adj_matrix.to_graph_adj, adj_matrix_apply, ite_eq_left_iff, zero_ne_one]
  apply not_not
#align simple_graph.to_graph_adj_matrix_eq SimpleGraph.to_graph_adj_matrix_eq

variable {α} [Fintype V]

@[simp]
theorem adj_matrix_dot_product [NonAssocSemiring α] (v : V) (vec : V → α) :
    dotProduct (G.adjMatrix α v) vec = ∑ u in G.neighborFinset v, vec u := by
  simp [neighbor_finset_eq_filter, dot_product, sum_filter]
#align simple_graph.adj_matrix_dot_product SimpleGraph.adj_matrix_dot_product

@[simp]
theorem dot_product_adj_matrix [NonAssocSemiring α] (v : V) (vec : V → α) :
    dotProduct vec (G.adjMatrix α v) = ∑ u in G.neighborFinset v, vec u := by
  simp [neighbor_finset_eq_filter, dot_product, sum_filter, Finset.sum_apply]
#align simple_graph.dot_product_adj_matrix SimpleGraph.dot_product_adj_matrix

@[simp]
theorem adj_matrix_mul_vec_apply [NonAssocSemiring α] (v : V) (vec : V → α) :
    ((G.adjMatrix α).mulVec vec) v = ∑ u in G.neighborFinset v, vec u := by
  rw [mul_vec, adj_matrix_dot_product]
#align simple_graph.adj_matrix_mul_vec_apply SimpleGraph.adj_matrix_mul_vec_apply

@[simp]
theorem adj_matrix_vec_mul_apply [NonAssocSemiring α] (v : V) (vec : V → α) :
    ((G.adjMatrix α).vecMul vec) v = ∑ u in G.neighborFinset v, vec u := by
  rw [← dot_product_adj_matrix, vec_mul]
  refine' congr rfl _; ext
  rw [← transpose_apply (adj_matrix α G) x v, transpose_adj_matrix]
#align simple_graph.adj_matrix_vec_mul_apply SimpleGraph.adj_matrix_vec_mul_apply

@[simp]
theorem adj_matrix_mul_apply [NonAssocSemiring α] (M : Matrix V V α) (v w : V) :
    (G.adjMatrix α ⬝ M) v w = ∑ u in G.neighborFinset v, M u w := by
  simp [mul_apply, neighbor_finset_eq_filter, sum_filter]
#align simple_graph.adj_matrix_mul_apply SimpleGraph.adj_matrix_mul_apply

@[simp]
theorem mul_adj_matrix_apply [NonAssocSemiring α] (M : Matrix V V α) (v w : V) :
    (M ⬝ G.adjMatrix α) v w = ∑ u in G.neighborFinset w, M v u := by
  simp [mul_apply, neighbor_finset_eq_filter, sum_filter, adj_comm]
#align simple_graph.mul_adj_matrix_apply SimpleGraph.mul_adj_matrix_apply

variable (α)

@[simp]
theorem trace_adj_matrix [AddCommMonoid α] [One α] : Matrix.trace (G.adjMatrix α) = 0 := by
  simp [Matrix.trace]
#align simple_graph.trace_adj_matrix SimpleGraph.trace_adj_matrix

variable {α}

theorem adj_matrix_mul_self_apply_self [NonAssocSemiring α] (i : V) :
    (G.adjMatrix α ⬝ G.adjMatrix α) i i = degree G i := by simp [degree]
#align simple_graph.adj_matrix_mul_self_apply_self SimpleGraph.adj_matrix_mul_self_apply_self

variable {G}

@[simp]
theorem adj_matrix_mul_vec_const_apply [Semiring α] {a : α} {v : V} :
    (G.adjMatrix α).mulVec (Function.const _ a) v = G.degree v * a := by simp [degree]
#align simple_graph.adj_matrix_mul_vec_const_apply SimpleGraph.adj_matrix_mul_vec_const_apply

theorem adj_matrix_mul_vec_const_apply_of_regular [Semiring α] {d : ℕ} {a : α}
    (hd : G.IsRegularOfDegree d) {v : V} : (G.adjMatrix α).mulVec (Function.const _ a) v = d * a :=
  by simp [hd v]
#align
  simple_graph.adj_matrix_mul_vec_const_apply_of_regular SimpleGraph.adj_matrix_mul_vec_const_apply_of_regular

theorem adj_matrix_pow_apply_eq_card_walk [DecidableEq V] [Semiring α] (n : ℕ) (u v : V) :
    (G.adjMatrix α ^ n) u v = Fintype.card { p : G.Walk u v | p.length = n } := by
  rw [card_set_walk_length_eq]
  induction' n with n ih generalizing u v
  · obtain rfl | h := eq_or_ne u v <;> simp [finset_walk_length, *]
  · nth_rw 1 [Nat.succ_eq_one_add]
    simp only [pow_add, pow_one, finset_walk_length, ih, mul_eq_mul, adj_matrix_mul_apply]
    rw [Finset.card_bUnion]
    · norm_cast
      simp only [Nat.cast_sum, card_map, neighbor_finset_def]
      apply Finset.sum_to_finset_eq_subtype
    -- Disjointness for card_bUnion
    · rintro ⟨x, hx⟩ - ⟨y, hy⟩ - hxy
      rw [disjoint_iff_inf_le]
      intro p hp
      simp only [inf_eq_inter, mem_inter, mem_map, Function.Embedding.coeFn_mk, exists_prop] at
          hp <;>
        obtain ⟨⟨px, hpx, rfl⟩, ⟨py, hpy, hp⟩⟩ := hp
      cases hp
      simpa using hxy
#align simple_graph.adj_matrix_pow_apply_eq_card_walk SimpleGraph.adj_matrix_pow_apply_eq_card_walk

end SimpleGraph

namespace Matrix.IsAdjMatrix

variable [MulZeroOneClass α] [Nontrivial α]

variable {A : Matrix V V α} (h : IsAdjMatrix A)

/-- If `A` is qualified as an adjacency matrix,
    then the adjacency matrix of the graph induced by `A` is itself. -/
theorem adj_matrix_to_graph_eq [DecidableEq α] : h.toGraph.adjMatrix α = A := by
  ext (i j)
  obtain h' | h' := h.zero_or_one i j <;> simp [h']
#align matrix.is_adj_matrix.adj_matrix_to_graph_eq Matrix.IsAdjMatrix.adj_matrix_to_graph_eq

end Matrix.IsAdjMatrix

