/-
Copyright (c) 2018 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Keeley Hoek, Scott Morrison

! This file was ported from Lean 3 source module tactic.rewrite_search.frontend
! leanprover-community/mathlib commit 44b58b42794e5abe2bf86397c38e26b587e07e59
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.RewriteSearch.Explain
import Mathbin.Tactic.RewriteSearch.Discovery
import Mathbin.Tactic.RewriteSearch.Search

/-!
# `rewrite_search`: solving goals by searching for a series of rewrites.

`rewrite_search` is a tactic for solving equalities or iff statements by searching for a
sequence of rewrite tactic applications.

## Algorithm sketch

The fundamental data structure behind the search algorithm is a graph of expressions. Each
vertex represents one expression, and an edge in the graph represents a way to rewrite one
expression into another with a single application of a rewrite tactic. Thus, a path in the
graph represents a way to rewrite one expression into another with multiple applications of
a rewrite tactic.

The graph starts out with two vertices, one for the left hand side of the equality, and one
for the right hand side of the equality. The basic loop of the algorithm is to repeatedly add
edges to the graph by taking vertices in the graph and applying a possible rewrite to them.
Through this process, the graph is made up of two connected components; one component contains
expressions that are equivalent to the left hand side, and one component contains expressions
that are equivalent to the right hand side. The algorithm completes when we discover an
edge that connects the two components, creating a path of rewrites that connects the
left hand side and right hand side of the graph. For more detail, see Keeley's report at
https://hoek.io/res/2018.s2.lean.report.pdf, although note that the edit distance mechanism
described is currently not implemented, only plain breadth-first search.

This algorithm is generally superior to one that only expands nodes starting from a single
side, because it is replacing one tree of depth `2d` with two trees of depth `d`. This is
a quadratic speedup for regular trees; our trees aren't regular but it's still probably
a much better algorithm. We can only use this specific algorithm for rewrite-type tactics,
though, not general sequences of tactics, because it relies on the fact that any rewrite
can be reversed.

## File structure

* `discovery.lean` contains the logic for figuring out which rewrite rules to consider.
* `search.lean` contains the graph algorithms to find a successful sequence of tactics.
* `explain.lean` generates concise Lean code to run a tactic, from the autogenerated sequence
  of tactics.
* `frontend.lean` contains the user-facing interface to the `rewrite_search` tactics.
* `types.lean` contains data structures shared across multiple of these components.
-/


namespace Tactic.Interactive

open Lean.Parser Interactive Interactive.Types Tactic.RewriteSearch

/-- Search for a chain of rewrites to prove an equation or iff statement.

Collects rewrite rules, runs a graph search to find a chain of rewrites to prove the
current target, and generates a string explanation for it.

Takes an optional list of rewrite rules specified in the same way as the `rw` tactic accepts.
-/
unsafe def rewrite_search (explain : parse <| optional (tk "?"))
    (rs : parse <| optional (list_of (rw_rule_p <| lean.parser.pexpr 0))) (cfg : config := { }) :
    tactic Unit := do
  let t ← tactic.target
  if t then tactic.fail "rewrite_search is not suitable for goals containing metavariables"
    else tactic.skip
  let implicit_rules ← collect_rules
  let explicit_rules ←
    (rs.getOrElse []).mmap fun ⟨_, dir, pe⟩ => do
        let e ← to_expr' pe
        return (e, dir)
  let rules := implicit_rules ++ explicit_rules
  let g ← mk_graph cfg rules t
  let (_, proof, steps) ← g.find_proof
  tactic.exact proof
  if explain then explain_search_result cfg rules proof steps else skip
#align tactic.interactive.rewrite_search tactic.interactive.rewrite_search

add_tactic_doc
  { Name := "rewrite_search"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.rewrite_search]
    tags := ["rewriting", "search"] }

end Tactic.Interactive

