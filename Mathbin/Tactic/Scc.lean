/-
Copyright (c) 2018 Simon Hudon All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module tactic.scc
! leanprover-community/mathlib commit d6814c584384ddf2825ff038e868451a7c956f31
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Tauto

/-!
# Strongly Connected Components

This file defines tactics to construct proofs of equivalences between a set of mutually equivalent
propositions. The tactics use implications transitively to find sets of equivalent propositions.

## Implementation notes

The tactics use a strongly connected components algorithm on a graph where propositions are
vertices and edges are proofs that the source implies the target. The strongly connected components
are therefore sets of propositions that are pairwise equivalent to each other.

The resulting strongly connected components are encoded in a disjoint set data structure to
facilitate the construction of equivalence proofs between two arbitrary members of an equivalence
class.

## Possible generalizations

Instead of reasoning about implications and equivalence, we could generalize the machinery to
reason about arbitrary partial orders.

## References

 * Tarjan, R. E. (1972), "Depth-first search and linear graph algorithms",
   SIAM Journal on Computing, 1 (2): 146–160, doi:10.1137/0201010
 * Dijkstra, Edsger (1976), A Discipline of Programming, NJ: Prentice Hall, Ch. 25.
 * <https://en.wikipedia.org/wiki/Disjoint-set_data_structure>

## Tags

graphs, tactic, strongly connected components, disjoint sets
-/


namespace Tactic

/-- `closure` implements a disjoint set data structure using path compression
optimization. For the sake of the scc algorithm, it also stores the preorder
numbering of the equivalence graph of the local assumptions.

The `expr_map` encodes a directed forest by storing for every non-root
node, a reference to its parent and a proof of equivalence between
that node's expression and its parent's expression. Given that data
structure, checking that two nodes belong to the same tree is easy and
fast by repeatedly following the parent references until a root is reached.
If both nodes have the same root, they belong to the same tree, i.e. their
expressions are equivalent. The proof of equivalence can be formed by
composing the proofs along the edges of the paths to the root.

More concretely, if we ignore preorder numbering, the set
`{ {e₀,e₁,e₂,e₃}, {e₄,e₅} }` is represented as:

```
e₀ → ⊥      -- no parent, i.e. e₀ is a root
e₁ → e₀, p₁ -- with p₁ : e₁ ↔ e₀
e₂ → e₁, p₂ -- with p₂ : e₂ ↔ e₁
e₃ → e₀, p₃ -- with p₃ : e₃ ↔ e₀
e₄ → ⊥      -- no parent, i.e. e₄ is a root
e₅ → e₄, p₅ -- with p₅ : e₅ ↔ e₄
```

We can check that `e₂` and `e₃` are equivalent by seeking the root of
the tree of each. The parent of `e₂` is `e₁`, the parent of `e₁` is
`e₀` and `e₀` does not have a parent, and thus, this is the root of its tree.
The parent of `e₃` is `e₀` and it's also the root, the same as for `e₂` and
they are therefore equivalent. We can build a proof of that equivalence by using
transitivity on `p₂`, `p₁` and `p₃.symm` in that order.

Similarly, we can discover that `e₂` and `e₅` aren't equivalent.

A description of the path compression optimization can be found at:
<https://en.wikipedia.org/wiki/Disjoint-set_data_structure#Path_compression>

-/
unsafe def closure :=
  ref (expr_map (Sum ℕ (expr × expr)))
#align tactic.closure tactic.closure

namespace closure

/-- `with_new_closure f` creates an empty `closure` `c`, executes `f` on `c`, and then deletes `c`,
returning the output of `f`. -/
unsafe def with_new_closure {α} : (closure → tactic α) → tactic α :=
  using_new_ref (expr_map.mk _)
#align tactic.closure.with_new_closure tactic.closure.with_new_closure

/-- `to_tactic_format cl` pretty-prints the `closure` `cl` as a list. Assuming `cl` was built by
`dfs_at`, each element corresponds to a node `pᵢ : expr` and is one of the folllowing:
- if `pᵢ` is a root: `"pᵢ ⇐ i"`, where `i` is the preorder number of `pᵢ`,
- otherwise: `"(pᵢ, pⱼ) : P"`, where `P` is `pᵢ ↔ pⱼ`.
Useful for debugging. -/
unsafe def to_tactic_format (cl : closure) : tactic format := do
  let m ← read_ref cl
  let l := m.toList
  let fmt ←
    l.mapM fun ⟨x, y⟩ =>
        match y with
        | Sum.inl y => f!"{(← x)} ⇐ {← y}"
        | Sum.inr ⟨y, p⟩ => f!"({(← x)}, {(← y)}) : {← infer_type p}"
  pure <| to_fmt fmt
#align tactic.closure.to_tactic_format tactic.closure.to_tactic_format

unsafe instance : has_to_tactic_format closure :=
  ⟨to_tactic_format⟩

/-- `(n,r,p) ← root cl e` returns `r` the root of the tree that `e` is a part of (which might be
itself) along with `p` a proof of `e ↔ r` and `n`, the preorder numbering of the root. -/
unsafe def root (cl : closure) : expr → tactic (ℕ × expr × expr)
  | e => do
    let m ← read_ref cl
    match m e with
      | none => do
        let p ← mk_app `` Iff.refl [e]
        pure (0, e, p)
      | some (Sum.inl n) => do
        let p ← mk_app `` Iff.refl [e]
        pure (n, e, p)
      | some (Sum.inr (e₀, p₀)) => do
        let (n, e₁, p₁) ← root e₀
        let p ← mk_app `` Iff.trans [p₀, p₁]
        modify_ref cl fun m => m e (Sum.inr (e₁, p))
        pure (n, e₁, p)
#align tactic.closure.root tactic.closure.root

/-- (Implementation of `merge`.) -/
unsafe def merge_intl (cl : closure) (p e₀ p₀ e₁ p₁ : expr) : tactic Unit := do
  let p₂ ← mk_app `` Iff.symm [p₀]
  let p ← mk_app `` Iff.trans [p₂, p]
  let p ← mk_app `` Iff.trans [p, p₁]
  modify_ref cl fun m => m e₀ <| Sum.inr (e₁, p)
#align tactic.closure.merge_intl tactic.closure.merge_intl

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      `merge cl p`, with `p` a proof of `e₀ ↔ e₁` for some `e₀` and `e₁`,
      merges the trees of `e₀` and `e₁` and keeps the root with the smallest preorder
      number as the root. This ensures that, in the depth-first traversal of the graph,
      when encountering an edge going into a vertex whose equivalence class includes
      a vertex that originated the current search, that vertex will be the root of
      the corresponding tree. -/
    unsafe
  def
    merge
    ( cl : closure ) ( p : expr ) : tactic Unit
    :=
      do
        let q( $ ( e₀ ) ↔ $ ( e₁ ) ) ← infer_type p >>= instantiate_mvars
          let ( n₂ , e₂ , p₂ ) ← root cl e₀
          let ( n₃ , e₃ , p₃ ) ← root cl e₁
          if
            e₂ ≠ e₃
            then
            do
              if
                n₂ < n₃
                then
                do let p ← mk_app ` ` Iff.symm [ p ] cl p e₃ p₃ e₂ p₂
                else
                cl p e₂ p₂ e₃ p₃
            else
            pure ( )
#align tactic.closure.merge tactic.closure.merge

/-- Sequentially assign numbers to the nodes of the graph as they are being visited. -/
unsafe def assign_preorder (cl : closure) (e : expr) : tactic Unit :=
  modify_ref cl fun m => m.insert e (Sum.inl m.size)
#align tactic.closure.assign_preorder tactic.closure.assign_preorder

/-- `prove_eqv cl e₀ e₁` constructs a proof of equivalence of `e₀` and `e₁` if
they are equivalent. -/
unsafe def prove_eqv (cl : closure) (e₀ e₁ : expr) : tactic expr := do
  let (_, r, p₀) ← root cl e₀
  let (_, r', p₁) ← root cl e₁
  guard (r = r') <|> throwError "{(← e₀)} and {← e₁} are not equivalent"
  let p₁ ← mk_app `` Iff.symm [p₁]
  mk_app `` Iff.trans [p₀, p₁]
#align tactic.closure.prove_eqv tactic.closure.prove_eqv

/-- `prove_impl cl e₀ e₁` constructs a proof of `e₀ -> e₁` if they are equivalent. -/
unsafe def prove_impl (cl : closure) (e₀ e₁ : expr) : tactic expr :=
  cl.prove_eqv e₀ e₁ >>= iff_mp
#align tactic.closure.prove_impl tactic.closure.prove_impl

/-- `is_eqv cl e₀ e₁` checks whether `e₀` and `e₁` are equivalent without building a proof. -/
unsafe def is_eqv (cl : closure) (e₀ e₁ : expr) : tactic Bool := do
  let (_, r, p₀) ← root cl e₀
  let (_, r', p₁) ← root cl e₁
  return <| r = r'
#align tactic.closure.is_eqv tactic.closure.is_eqv

end closure

/-- mutable graphs between local propositions that imply each other with the proof of implication -/
@[reducible]
unsafe def impl_graph :=
  ref (expr_map (List <| expr × expr))
#align tactic.impl_graph tactic.impl_graph

/-- `with_impl_graph f` creates an empty `impl_graph` `g`, executes `f` on `g`, and then deletes
`g`, returning the output of `f`. -/
unsafe def with_impl_graph {α} : (impl_graph → tactic α) → tactic α :=
  using_new_ref (expr_map.mk (List <| expr × expr))
#align tactic.with_impl_graph tactic.with_impl_graph

namespace ImplGraph

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      `add_edge g p`, with `p` a proof of `v₀ → v₁` or `v₀ ↔ v₁`, adds an edge to the implication
      graph `g`. -/
    unsafe
  def
    add_edge
    ( g : impl_graph ) : expr → tactic Unit
    |
      p
      =>
      do
        let t ← infer_type p
          match
            t
            with
            |
                q( $ ( v₀ ) → $ ( v₁ ) )
                =>
                do
                  is_prop v₀ >>= guardb
                    is_prop v₁ >>= guardb
                    let m ← read_ref g
                    let xs := ( m v₀ ) . getD [ ]
                    let xs' := ( m v₁ ) . getD [ ]
                    modify_ref g fun m => ( m v₀ ( ( v₁ , p ) :: xs ) ) . insert v₁ xs'
              |
                q( $ ( v₀ ) ↔ $ ( v₁ ) )
                =>
                do
                  let p₀ ← mk_mapp ` ` Iff.mp [ none , none , p ]
                    let p₁ ← mk_mapp ` ` Iff.mpr [ none , none , p ]
                    add_edge p₀
                    add_edge p₁
              | _ => failed
#align tactic.impl_graph.add_edge tactic.impl_graph.add_edge

section Scc

open List

parameter (g : expr_map (List <| expr × expr))

parameter (visit : ref <| expr_map Bool)

parameter (cl : closure)

/-- `merge_path path e`, where `path` and `e` forms a cycle with proofs of implication between
consecutive vertices. The proofs are compiled into proofs of equivalences and added to the closure
structure. `e` and the first vertex of `path` do not have to be the same but they have to be
in the same equivalence class. -/
unsafe def merge_path (path : List (expr × expr)) (e : expr) : tactic Unit := do
  let p₁ ← cl.prove_impl e Path.headI.fst
  let p₂ ← mk_mapp `` id [e]
  let path := (e, p₁) :: Path
  let (_, ls) ←
    Path.mapAccumLM
        (fun p p' => Prod.mk <$> mk_mapp `` Implies.trans [none, p'.1, none, p, p'.2] <*> pure p) p₂
  let (_, rs) ←
    Path.mapAccumRM
        (fun p p' => Prod.mk <$> mk_mapp `` Implies.trans [none, none, none, p.2, p'] <*> pure p')
        p₂
  let ps ← zipWithM (fun p₀ p₁ => mk_app `` Iff.intro [p₀, p₁]) ls.tail rs.dropLast
  ps cl
#align tactic.impl_graph.merge_path tactic.impl_graph.merge_path

/-- (implementation of `collapse`) -/
unsafe def collapse' : List (expr × expr) → List (expr × expr) → expr → tactic Unit
  | Acc, [], v => merge_path Acc v
  | Acc, (x, pr) :: xs, v => do
    let b ← cl.is_eqv x v
    let acc' := (x, pr) :: Acc
    if b then merge_path acc' v else collapse' acc' xs v
#align tactic.impl_graph.collapse' tactic.impl_graph.collapse'

/-- `collapse path v`, where `v` is a vertex that originated the current search
(or a vertex in the same equivalence class as the one that originated the current search).
It or its equivalent should be found in `path`. Since the vertices following `v` in the path
form a cycle with `v`, they can all be added to an equivalence class. -/
unsafe def collapse : List (expr × expr) → expr → tactic Unit :=
  collapse' []
#align tactic.impl_graph.collapse tactic.impl_graph.collapse

/-- Strongly connected component algorithm inspired by Tarjan's and
Dijkstra's scc algorithm. Whereas they return strongly connected
components by enumerating them, this algorithm returns a disjoint set
data structure using path compression. This is a compact
representation that allows us, after the fact, to construct a proof of
equivalence between any two members of an equivalence class.

 * Tarjan, R. E. (1972), "Depth-first search and linear graph algorithms",
   SIAM Journal on Computing, 1 (2): 146–160, doi:10.1137/0201010
 * Dijkstra, Edsger (1976), A Discipline of Programming, NJ: Prentice Hall, Ch. 25.
-/
unsafe def dfs_at : List (expr × expr) → expr → tactic Unit
  | vs, v => do
    let m ← read_ref visit
    let (_, v', _) ← cl.root v
    match m v' with
      | some tt => pure ()
      | some ff => collapse vs v
      | none => do
        cl v
        modify_ref visit fun m => m v ff
        let ns ← g v
        ns fun ⟨w, e⟩ => dfs_at ((v, e) :: vs) w
        modify_ref visit fun m => m v tt
        pure ()
#align tactic.impl_graph.dfs_at tactic.impl_graph.dfs_at

end Scc

/-- Use the local assumptions to create a set of equivalence classes. -/
unsafe def mk_scc (cl : closure) : tactic (expr_map (List (expr × expr))) :=
  with_impl_graph fun g =>
    using_new_ref (expr_map.mk Bool) fun visit => do
      let ls ← local_context
      ls fun l => try (g l)
      let m ← read_ref g
      m fun ⟨v, _⟩ => impl_graph.dfs_at m visit cl [] v
      pure m
#align tactic.impl_graph.mk_scc tactic.impl_graph.mk_scc

end ImplGraph

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
unsafe
  def
    prove_eqv_target
    ( cl : closure ) : tactic Unit
    := do let q( $ ( p ) ↔ $ ( q ) ) ← target >>= whnf cl p q >>= exact
#align tactic.prove_eqv_target tactic.prove_eqv_target

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      `scc` uses the available equivalences and implications to prove
      a goal of the form `p ↔ q`.
      
      ```lean
      example (p q r : Prop) (hpq : p → q) (hqr : q ↔ r) (hrp : r → p) : p ↔ r :=
      by scc
      ```
      -/
    unsafe
  def
    interactive.scc
    : tactic Unit
    :=
      closure.with_new_closure
        fun cl => do impl_graph.mk_scc cl let q( $ ( p ) ↔ $ ( q ) ) ← target cl p q >>= exact
#align tactic.interactive.scc tactic.interactive.scc

/-- Collect all the available equivalences and implications and
add assumptions for every equivalence that can be proven using the
strongly connected components technique. Mostly useful for testing. -/
unsafe def interactive.scc' : tactic Unit :=
  closure.with_new_closure fun cl => do
    let m ← impl_graph.mk_scc cl
    let ls := m.toList.map Prod.fst
    let ls' := Prod.mk <$> ls <*> ls
    ls' fun x => do
        let h ← get_unused_name `h
        try <| closure.prove_eqv cl x.1 x.2 >>= note h none
#align tactic.interactive.scc' tactic.interactive.scc'

/-- `scc` uses the available equivalences and implications to prove
a goal of the form `p ↔ q`.

```lean
example (p q r : Prop) (hpq : p → q) (hqr : q ↔ r) (hrp : r → p) : p ↔ r :=
by scc
```

The variant `scc'` populates the local context with all equivalences that `scc` is able to prove.
This is mostly useful for testing purposes.
-/
add_tactic_doc
  { Name := "scc"
    category := DocCategory.tactic
    declNames := [`` interactive.scc, `` interactive.scc']
    tags := ["logic"] }

end Tactic

