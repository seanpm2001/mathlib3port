/-
Copyright (c) 2018 Keeley Hoek. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Keeley Hoek, Scott Morrison

! This file was ported from Lean 3 source module tactic.nth_rewrite.default
! leanprover-community/mathlib commit dc34b216eb1a1548161e35d328ea1ab798017033
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.NthRewrite.Congr

/-!
# Advanced rewriting tactics

This file provides three interactive tactics
that give the user more control over where to perform a rewrite.

## Main definitions

* `nth_rewrite n rules`: performs only the `n`th possible rewrite using the `rules`.
* `nth_rewrite_lhs`: as above, but only rewrites on the left hand side of an equation or iff.
* `nth_rewrite_rhs`: as above, but only rewrites on the right hand side of an equation or iff.

## Implementation details

There are two alternative backends, provided by `.congr` and `.kabstract`.
The kabstract backend is not currently available through mathlib.

The kabstract backend is faster, but if there are multiple identical occurrences of the
same rewritable subexpression, all are rewritten simultaneously,
and this isn't always what we want.
(In particular, `rewrite_search` is much less capable on the `category_theory` library.)
-/


open Tactic Lean.Parser Interactive Interactive.Types Expr

namespace Tactic

/-- Returns the target of the goal when passed `none`,
otherwise, return the type of `h` in `some h`. -/
unsafe def target_or_hyp_type : Option expr → tactic expr
  | none => target
  | some h => infer_type h
#align tactic.target_or_hyp_type tactic.target_or_hyp_type

/-- Replace the target, or a hypothesis, depending on whether `none` or `some h` is given as the
first argument. -/
unsafe def replace_in_state : Option expr → expr → expr → tactic Unit
  | none => tactic.replace_target
  | some h => fun e p => tactic.replace_hyp h e p >> skip
#align tactic.replace_in_state tactic.replace_in_state

open NthRewrite NthRewrite.Congr NthRewrite.TrackedRewrite

open Tactic.Interactive

/-- Preprocess a rewrite rule for use in `get_nth_rewrite`. -/
private unsafe def unpack_rule (p : rw_rule) : tactic (expr × Bool) := do
  let r ← to_expr p.rule true false
  return (r, p)

/-- Get the `n`th rewrite of rewrite rules `q` in expression `e`,
or fail if there are not enough such rewrites. -/
unsafe def get_nth_rewrite (n : ℕ) (q : rw_rules_t) (e : expr) : tactic tracked_rewrite := do
  let rewrites ← q.rules.mapM fun r => unpack_rule r >>= all_rewrites e
  rewrites n <|> fail "failed: not enough rewrites found"
#align tactic.get_nth_rewrite tactic.get_nth_rewrite

/-- Rewrite the `n`th occurrence of the rewrite rules `q` of (optionally after zooming into) a
hypothesis or target `h` which is an application of a relation. -/
unsafe def get_nth_rewrite_with_zoom (n : ℕ) (q : rw_rules_t) (path : List ExprLens.Dir)
    (h : Option expr) : tactic tracked_rewrite := do
  let e ← target_or_hyp_type h
  let (ln, new_e) ← expr_lens.entire.zoom Path e
  let rw ← get_nth_rewrite n q new_e
  return ⟨ln rw, rw >>= ln, rw fun l => Path ++ l⟩
#align tactic.get_nth_rewrite_with_zoom tactic.get_nth_rewrite_with_zoom

/-- Rewrite the `n`th occurrence of the rewrite rules `q` (optionally on a side)
at all the locations `loc`. -/
unsafe def nth_rewrite_core (path : List ExprLens.Dir) (n : parse small_nat) (q : parse rw_rules)
    (l : parse location) : tactic Unit := do
  let fn h :=
    get_nth_rewrite_with_zoom n q Path h >>= fun rw => rw.proof >>= replace_in_state h rw.exp
  match l with
    | loc.wildcard => l (fn ∘ some) (fn none)
    | _ => l (fn ∘ some) (fn none)
  tactic.try (tactic.reflexivity reducible)
  returnopt q >>= save_info <|> skip
#align tactic.nth_rewrite_core tactic.nth_rewrite_core

namespace Interactive

open ExprLens

/-- `nth_rewrite n rules` performs only the `n`th possible rewrite using the `rules`.
The tactics `nth_rewrite_lhs` and `nth_rewrite_rhs` are variants
that operate on the left and right hand sides of an equation or iff.

Note: `n` is zero-based, so `nth_rewrite 0 h`
will rewrite along `h` at the first possible location.

In more detail, given `rules = [h1, ..., hk]`,
this tactic will search for all possible locations
where one of `h1, ..., hk` can be rewritten,
and perform the `n`th occurrence.

Example: Given a goal of the form `a + x = x + b`, and hypothesis `h : x = y`,
the tactic `nth_rewrite 1 h` will change the goal to `a + x = y + b`.

The core `rewrite` has a `occs` configuration setting intended to achieve a similar
purpose, but this doesn't really work. (If a rule matches twice, but with different
values of arguments, the second match will not be identified.) -/
unsafe def nth_rewrite (n : parse small_nat) (q : parse rw_rules) (l : parse location) :
    tactic Unit :=
  nth_rewrite_core [] n q l
#align tactic.interactive.nth_rewrite tactic.interactive.nth_rewrite

unsafe def nth_rewrite_lhs (n : parse small_nat) (q : parse rw_rules) (l : parse location) :
    tactic Unit :=
  nth_rewrite_core [Dir.F, Dir.A] n q l
#align tactic.interactive.nth_rewrite_lhs tactic.interactive.nth_rewrite_lhs

unsafe def nth_rewrite_rhs (n : parse small_nat) (q : parse rw_rules) (l : parse location) :
    tactic Unit :=
  nth_rewrite_core [Dir.A] n q l
#align tactic.interactive.nth_rewrite_rhs tactic.interactive.nth_rewrite_rhs

attribute [inherit_doc.1 nth_rewrite] nth_rewrite_lhs nth_rewrite_rhs

add_tactic_doc
  { Name := "nth_rewrite / nth_rewrite_lhs / nth_rewrite_rhs"
    category := DocCategory.tactic
    inheritDescriptionFrom := `` nth_rewrite
    declNames := [`` nth_rewrite, `` nth_rewrite_lhs, `` nth_rewrite_rhs]
    tags := ["rewriting"] }

end Interactive

end Tactic

