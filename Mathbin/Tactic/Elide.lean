/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Simon Hudon

! This file was ported from Lean 3 source module tactic.elide
! leanprover-community/mathlib commit 3c11bd771ef17197a9e9fcd4a3fabfa2804d950c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Core

namespace Tactic

namespace Elide

unsafe def replace : ℕ → expr → tactic expr
  | 0, e => do
    let t ← infer_type e
    let expr.sort u ← infer_type t
    return <| (expr.const `` hidden [u]).app t e
  | i + 1, expr.app f x => do
    let f' ← replace (i + 1) f
    let x' ← replace i x
    return (f' x')
  | i + 1, expr.lam n b d e => do
    let d' ← replace i d
    let var ← mk_local' n b d
    let e' ← replace i (expr.instantiate_var e var)
    return (expr.lam n b d' (expr.abstract_local e' var))
  | i + 1, expr.pi n b d e => do
    let d' ← replace i d
    let var ← mk_local' n b d
    let e' ← replace i (expr.instantiate_var e var)
    return (expr.pi n b d' (expr.abstract_local e' var))
  | i + 1, el@(expr.elet n t d e) => do
    let t' ← replace i t
    let d' ← replace i d
    let var ← mk_local_def n t
    let e' ← replace i (expr.instantiate_var e var)
    return (expr.elet n t' d' (expr.abstract_local e' var))
  | i + 1, e => return e
#align tactic.elide.replace tactic.elide.replace

unsafe def unelide (e : expr) : expr :=
  expr.replace e fun e n =>
    match e with
    | expr.app (expr.app (expr.const n _) _) e' => if n = `` hidden then some e' else none
    | expr.app (expr.lam _ _ _ (expr.var 0)) e' => some e'
    | _ => none
#align tactic.elide.unelide tactic.elide.unelide

end Elide

namespace Interactive

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- The `elide n (at ...)` tactic hides all subterms of the target goal or hypotheses
beyond depth `n` by replacing them with `hidden`, which is a variant
on the identity function. (Tactics should still mostly be able to see
through the abbreviation, but if you want to unhide the term you can use
`unelide`.) -/
unsafe def elide (n : parse small_nat) (loc : parse location) : tactic Unit :=
  loc.apply
    (fun h => do
      let t ← infer_type h >>= tactic.elide.replace n
      tactic.change_core t (some h))
    (target >>= tactic.elide.replace n >>= tactic.change)
#align tactic.interactive.elide tactic.interactive.elide

/-- The `unelide (at ...)` tactic removes all `hidden` subterms in the target
types (usually added by `elide`). -/
unsafe def unelide (loc : parse location) : tactic Unit :=
  loc.apply
    (fun h => do
      let t ← infer_type h
      tactic.change_core (elide.unelide t) (some h))
    (target >>= tactic.change ∘ elide.unelide)
#align tactic.interactive.unelide tactic.interactive.unelide

/-- The `elide n (at ...)` tactic hides all subterms of the target goal or hypotheses
beyond depth `n` by replacing them with `hidden`, which is a variant
on the identity function. (Tactics should still mostly be able to see
through the abbreviation, but if you want to unhide the term you can use
`unelide`.)

The `unelide (at ...)` tactic removes all `hidden` subterms in the target
types (usually added by `elide`).
-/
add_tactic_doc
  { Name := "elide / unelide"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.elide, `tactic.interactive.unelide]
    tags := ["goal management", "context management", "rewriting"] }

end Interactive

end Tactic

