/-
Copyright (c) 2018 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module tactic.fin_cases
! leanprover-community/mathlib commit 82a53736b96112a948cb35faa4ab72aa705d56f8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Basic
import Mathbin.Tactic.NormNum

/-!
# Case bash

This file provides the tactic `fin_cases`. `fin_cases x` performs case analysis on `x`, that is
creates one goal for each possible value of `x`, where either:
* `x : α`, where `[fintype α]`
* `x ∈ A`, where `A : finset α`, `A : multiset α` or `A : list α`.
-/


namespace Tactic

open Expr

open Conv.Interactive

/-- Checks that the expression looks like `x ∈ A` for `A : finset α`, `multiset α` or `A : list α`,
    and returns the type α. -/
unsafe def guard_mem_fin (e : expr) : tactic expr := do
  let t ← infer_type e
  let α ← mk_mvar
  to_expr ``(_ ∈ (_ : Finset $(α))) tt ff >>= unify t <|>
      to_expr ``(_ ∈ (_ : Multiset $(α))) tt ff >>= unify t <|>
        to_expr ``(_ ∈ (_ : List $(α))) tt ff >>= unify t
  instantiate_mvars α
#align tactic.guard_mem_fin tactic.guard_mem_fin

/-- `expr_list_to_list_expr` converts an `expr` of type `list α`
to a list of `expr`s each with type `α`.

TODO: this should be moved, and possibly duplicates an existing definition.
-/
unsafe def expr_list_to_list_expr : ∀ e : expr, tactic (List expr)
  | q(List.cons $(h) $(t)) => List.cons h <$> expr_list_to_list_expr t
  | q([]) => return []
  | _ => failed
#align tactic.expr_list_to_list_expr tactic.expr_list_to_list_expr

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
private unsafe def fin_cases_at_aux : ∀ (with_list : List expr) (e : expr), tactic Unit
  | with_list, e => do
    let result ← cases_core e
    match result with
      |-- We have a goal with an equation `s`, and a second goal with a smaller `e : x ∈ _`.
        [(_, [s], _), (_, [e], _)] =>
        do
        let sn := local_pp_name s
        let ng ← num_goals
        -- tidy up the new value
          match with_list 0 with
          |-- If an explicit value was specified via the `with` keyword, use that.
              some
              h =>
            tactic.interactive.conv (some sn) none (to_rhs >> conv.interactive.change (to_pexpr h))
          |-- Otherwise, call `norm_num`. We let `norm_num` unfold `max` and `min`
            -- because it's helpful for the `interval_cases` tactic.
            _ =>
            try <|
              tactic.interactive.conv (some sn) none <|
                to_rhs >>
                  conv.interactive.norm_num
                    [simp_arg_type.expr ``(max_def'), simp_arg_type.expr ``(min_def)]
        let s ← get_local sn
        try sorry
        let ng' ← num_goals
        when (ng = ng') (rotate_left 1)
        fin_cases_at_aux with_list e
      |-- No cases; we're done.
        [] =>
        skip
      | _ => failed

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      `fin_cases_at with_list e` performs case analysis on `e : α`, where `α` is a fintype.
      The optional list of expressions `with_list` provides descriptions for the cases of `e`,
      for example, to display nats as `n.succ` instead of `n+1`.
      These should be defeq to and in the same order as the terms in the enumeration of `α`.
      -/
    unsafe
  def
    fin_cases_at
    ( nm : Option Name ) : ∀ ( with_list : Option pexpr ) ( e : expr ) , tactic Unit
    |
      with_list , e
      =>
      focus1
        do
          let ty ← try_core <| guard_mem_fin e
            match
              ty
              with
              |
                  none
                  =>
                  do
                    let ty ← infer_type e
                      let
                        i
                          ←
                          to_expr ` `( Fintype $ ( ty ) ) >>= mk_instance
                            <|>
                            fail "Failed to find `fintype` instance."
                      let t ← to_expr ` `( $ ( e ) ∈ @ Fintype.elems $ ( ty ) $ ( i ) )
                      let v ← to_expr ` `( @ Fintype.complete $ ( ty ) $ ( i ) $ ( e ) )
                      let h ← assertv ( nm `this ) t v
                      fin_cases_at with_list h
                |
                  some ty
                  =>
                  do
                    let
                        with_list
                          ←
                          match
                            with_list
                            with
                            |
                                some e
                                =>
                                do
                                  let e ← to_expr ` `( ( $ ( e ) : List $ ( ty ) ) )
                                    expr_list_to_list_expr e
                              | none => return [ ]
                      fin_cases_at_aux with_list e
#align tactic.fin_cases_at tactic.fin_cases_at

namespace Interactive

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
private unsafe def hyp :=
  tk "*" *> return none <|> some <$> ident

/-- `fin_cases h` performs case analysis on a hypothesis of the form
`h : A`, where `[fintype A]` is available, or
`h : a ∈ A`, where `A : finset X`, `A : multiset X` or `A : list X`.

`fin_cases *` performs case analysis on all suitable hypotheses.

As an example, in
```
example (f : ℕ → Prop) (p : fin 3) (h0 : f 0) (h1 : f 1) (h2 : f 2) : f p.val :=
begin
  fin_cases *; simp,
  all_goals { assumption }
end
```
after `fin_cases p; simp`, there are three goals, `f 0`, `f 1`, and `f 2`.

`fin_cases h with l` takes a list of descriptions for the cases of `h`.
These should be definitionally equal to and in the same order as the
default enumeration of the cases.

For example,
```
example (x y : ℕ) (h : x ∈ [1, 2]) : x = y :=
begin
  fin_cases h with [1, 1+1],
end
```
produces two cases: `1 = y` and `1 + 1 = y`.

When using `fin_cases a` on data `a` defined with `let`,
the tactic will not be able to clear the variable `a`,
and will instead produce hypotheses `this : a = ...`.
These hypotheses can be given a name using `fin_cases a using ha`.

For example,
```
example (f : ℕ → fin 3) : true :=
begin
  let a := f 3,
  fin_cases a using ha,
end
```
produces three goals with hypotheses
`ha : a = 0`, `ha : a = 1`, and `ha : a = 2`.
-/
unsafe def fin_cases :
    parse hyp → parse (tk "with" *> texpr)? → parse (tk "using" *> ident)? → tactic Unit
  | none, none, nm => do
    let ctx ← local_context
    ctx (fin_cases_at nm none) <|>
        fail
          ("No hypothesis of the forms `x ∈ A`, where " ++
            "`A : finset X`, `A : list X`, or `A : multiset X`, or `x : A`, with `[fintype A]`.")
  | none, some _, _ => fail "Specify a single hypothesis when using a `with` argument."
  | some n, with_list, nm => do
    let h ← get_local n
    fin_cases_at nm with_list h
#align tactic.interactive.fin_cases tactic.interactive.fin_cases

end Interactive

add_tactic_doc
  { Name := "fin_cases"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.fin_cases]
    tags := ["case bashing"] }

end Tactic

