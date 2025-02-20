/-
Copyright (c) 2022 Arthur Paulino, Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Arthur Paulino, Damiano Testa

! This file was ported from Lean 3 source module tactic.move_add
! leanprover-community/mathlib commit 205a628e1fdc9220cb86832d66a50d1381abc103
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Core
import Mathbin.Algebra.Group.Basic

/-!
# `move_add`: a tactic for moving summands

Calling `move_add [a, ← b, c]`, recursively looks inside the goal for expressions involving a sum.
Whenever it finds one, it moves the summands that unify to `a, b, c`, removing all parentheses.

See the doc-string for `tactic.interactive.move_add` for more information.

##  Implementation notes

This file defines a general `move_op` tactic, intended for reordering terms in an expression
obtained by repeated applications of a given associative, commutative binary operation.  The
user decides the final reordering.  Applying `move_op` without specifying the order will simply
remove all parentheses from the expression.
The main user-facing tactics are `move_add` and `move_mul`, dealing with addition and
multiplication, respectively.

In what is below, we talk about `move_add` for definiteness, but everything applies
to `move_mul` and to the more general `move_op`.

The implementation of `move_add` only moves the terms specified by the user (and rearranges
parentheses).

Note that the tactic `abel` already implements a very solid heuristic for normalizing terms in an
additive commutative semigroup and produces expressions in more or less standard form.
The scope of `move_add` is different: it is designed to make it easy to move individual terms
around a sum.

##  Future work

* Add support for `neg/div/inv` in additive/multiplicative groups?
* Currently the tactic has special support for `+` and `*`.  Every other operation is outsourced
  to `ac_refl` (see the proof of `reorder_hyp`).  Should there be the desire for specialized support
  of other operations (e.g. `∪, ∩, ⊓, ⊔, ...`), that is the definition to modify, at least in the
  first instance.
* Add functionality for moving terms across the two sides of an in/dis/equality.
  E.g. it might be desirable to have `to_lhs [a]` converting `b + c = a + d` to `- a + b + c = d`.
* Add a non-recursive version for use in `conv` mode.
* Revise tests?
-/


namespace Tactic

namespace MoveOp

/-!
Throughout this file, `op : pexpr` denotes an arbitrary (binary) operation.  We do not use,
but implicitly imagine, that this operation is associative, since we extract iterations of
such operations, with complete disregard of the order in which these iterations arise.
-/


/-- Given a list `un` of `α`s and a list `bo` of `bool`s, return the sublist of `un`
consisting of the entries of `un` whose corresponding entry in `bo` is `tt`.

Used for error management: `un` is the list of user inputs, `bo` is the list encoding which input
is unused (`tt`) and which input is used (`ff`).
`return_unused` returns the unused user inputs.

If `bo` is shorter than `un`, `return_unused` will include the remainder of `un`.
-/
def returnUnused {α : Type _} : List α → List Bool → List α
  | un, [] => un
  | [], bo => []
  | u :: us, b :: bs => if b then u :: return_unused us bs else return_unused us bs
#align tactic.move_op.return_unused Tactic.MoveOp.returnUnused

/-- Given a list `lp` of `bool × pexpr` and a list `l_un` of `expr`, scan the elements of `lp` one
at a time and produce 3 sublists of `l_un`.

If `(tf,pe)` is the first element of `lp`, we look for the first element of `l_un` that unifies with
`pe.to_expr`.  If no such element exists, then we discard `(tf,pe)` and move along.
If `eu ∈ l_un` is the first element of `l_un` that unifies with `pe.to_expr`, then we add `eu` as
the next element of either the first or the second list, depending on the boolean `tf` and we remove
`eu` from the list `l_un`.  In this case, we continue our scanning with the next element of `lp`,
replacing `l_un` by `l_un.erase eu`.

Once we exhaust the elements of `lp`, we return the four lists:
* `l_tt`: the list of elements of `l_un` that came from an element of `lp` whose boolean was `tt`,
* `l_ff`: the list of elements of `l_un` that came from an element of `lp` whose boolean was `ff`,
* `l_un`: the un-unified elements of `l_un`,
* `l_m`: a "mask" list of booleans corresponding to the elements of `lp` that were placed in `l_un`.

The ununified elements of `l_un` get used for error management: they keep track of which user inputs
are superfluous. -/
unsafe def move_left_or_right :
    List (Bool × expr) →
      List expr → List Bool → tactic (List expr × List expr × List expr × List Bool)
  | [], l_un, l_m => return ([], [], l_un, l_m)
  | be :: l, l_un, l_m => do
    let ex :: _ ← l_un.filterM fun e' => succeeds <| unify be.2 e' |
      move_left_or_right l l_un (l_m.append [true])
    let (l_tt, l_ff, l_un, l_m) ← move_left_or_right l (l_un.eraseₓ ex) (l_m.append [false])
    if be.1 then return (ex :: l_tt, l_ff, l_un, l_m) else return (l_tt, ex :: l_ff, l_un, l_m)
#align tactic.move_op.move_left_or_right tactic.move_op.move_left_or_right

/-- We adapt `move_left_or_right` to our goal:
1. we convert a list of pairs `bool × pexpr` to a list of pairs `bool × expr`,
2. we use the extra input `sl : list expr` to perform the unification and sorting step
   `move_left_or_right`,
3. we jam the third factor inside the first two.
-/
unsafe def final_sort (lp : List (Bool × pexpr)) (sl : List expr) :
    tactic (List expr × List Bool) := do
  let lp_exp : List (Bool × expr) ←
    lp.mapM fun x => do
        let e ← to_expr x.2 true false
        return (x.1, e)
  let (l1, l2, l3, is_unused) ← move_left_or_right lp_exp sl []
  return (l1 ++ l3 ++ l2, is_unused)
#align tactic.move_op.final_sort tactic.move_op.final_sort

/-- `as_given_op op e` unifies the head term of `e`, which is a ≥2-argument function application,
with the binary operation `op`, failing if it cannot. -/
unsafe def as_given_op (op : pexpr) : expr → tactic expr
  | expr.app (expr.app F a) b => do
    to_expr op tt ff >>= unify F
    return F
  | _ => failed
#align tactic.move_op.as_given_op tactic.move_op.as_given_op

/-- `(e, unused) ← reorder_oper op lp e` converts an expression `e` to a similar looking one.
The tactic scans the expression `e` looking for subexpressions that begin with the given binary
operation `op`.  As soon as `reorder_oper` finds one such subexpression,
* it extracts the "`op`-summands" in the subexpression,
* it rearranges them according to the rules determined by `lp`,
* it recurses into each `op`-summand.

The `unused` output is a list of booleans.  It is keeping track of which of the inputs provided
by `lp` is actually used to perform the rearrangements.  It is useful to report unused inputs.

Here are two examples:
```lean
#eval trace $ reorder_oper ``((=)) [(ff,``(2)), (tt,``(7))] `(∀ x y : ℕ, 2 = 0)
--  (ℕ → ℕ → 0 = 2, [ff, tt])
-- the input `[(ff,``(2)), (tt,``(7))]` instructs Lean to move `2` to the right and `7`
-- to the left.  Lean reports that `2` is not unused and `7` is unused as `[ff, tt]`.

#eval trace $ reorder_oper ``((+)) [(ff,``(2)), (tt,``(5))]
  `(λ (e : ℕ), ∀ (x : ℕ), ∃ (y : ℕ),
      2 + x * (y + (e + 5)) + y = x + 2 + e → 2 + x = x + 5 + (2 + y))
/-  `2` moves to the right, `5` moves to the left.  Lean reports that `2, 5` are not unused
    as `[ff,ff]`
   (λ (e : ℕ), ∀ (x : ℕ), ∃ (y : ℕ),
      x * (5 + y + e) + y + 2   = x + e + 2 → x + 2 = 5 + x + y + 2, [ff, ff]) -/
```

TODO: use `ext_simplify_core` instead of traversing the expression manually
-/
unsafe def reorder_oper (op : pexpr) (lp : List (Bool × pexpr)) : expr → tactic (expr × List Bool)
  | F'@(expr.app F b) => do
    let is_op ← try_core (as_given_op op F')
    match is_op with
      | some op => do
        let (sort_list, is_unused) ← list_binary_operands op F' >>= final_sort lp
        let sort_all ←
          sort_list fun e => do
              let (e, lu) ← reorder_oper e
              pure (e, [lu, is_unused].transpose.map List.and)
        let (recs, list_unused) := sort_all
        let recs_0 :: recs_rest ← pure recs |
          throwError"internal error: cannot have 0 operands"
        let summed := recs_rest (fun e f => op [e, f]) recs_0
        return (summed, list_unused List.and)
      | none => do
        let [(Fn, unused_F), (bn, unused_b)] ← [F, b].mapM <| reorder_oper
        return <| (expr.app Fn bn, [unused_F, unused_b].transpose.map List.and)
  | expr.pi na bi e f => do
    let [en, fn] ← [e, f].mapM <| reorder_oper
    return (expr.pi na bi en.1 fn.1, [en.2, fn.2].transpose.map List.and)
  | expr.lam na bi e f => do
    let [en, fn] ← [e, f].mapM <| reorder_oper
    return (expr.lam na bi en.1 fn.1, [en.2, fn.2].transpose.map List.and)
  | expr.mvar na pp e => do
    let en
      ←-- is it really needed to recurse here?
          reorder_oper
          e
    return (expr.mvar na pp en.1, [en.2].transpose.map List.and)
  | expr.local_const na pp bi e => do
    let en
      ←-- is it really needed to recurse here?
          reorder_oper
          e
    return (expr.local_const na pp bi en.1, [en.2].transpose.map List.and)
  | expr.elet na e f g => do
    let [en, fn, gn] ← [e, f, g].mapM <| reorder_oper
    return (expr.elet na en.1 fn.1 gn.1, [en.2, fn.2, gn.2].transpose.map List.and)
  | expr.macro ma le => do
    let len
      ←-- is it really needed to recurse here?
            le.mapM <|
          reorder_oper
    let (lee, lb) := len.unzip
    return (expr.macro ma lee, lb List.and)
  | e => pure (e, lp.map fun _ => true)
#align tactic.move_op.reorder_oper tactic.move_op.reorder_oper

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/-- Passes the user input `na` to `reorder_oper` at a single location, that could either be
`none` (referring to the goal) or `some name` (referring to hypothesis `name`).  Replaces the
given hypothesis/goal with the rearranged one that `reorder_hyp` receives from `reorder_oper`.
Returns a pair consisting of a boolean and a further list of booleans.
The single boolean is `tt` iff the tactic did *not* change the goal on which it was acting.
The list of booleans records which variable in `ll` has been unified in the application:
`tt` means that the corresponding variable has *not* been unified.

This definition is useful to streamline error catching. -/
unsafe def reorder_hyp (op : pexpr) (lp : List (Bool × pexpr)) (na : Option Name) :
    tactic (Bool × List Bool) := do
  let (thyp, hyploc) ←
    match na with
      | none => do
        let t ← target
        return (t, none)
      | some na => do
        let hl ← get_local na
        let th ← infer_type hl
        return (th, some hl)
  let (reordered, is_unused) ← reorder_oper op lp thyp
  unify reordered thyp >> return (tt, is_unused) <|> do
      let neq
        ←-- the current `do` block takes place where the reordered expression is not equal to the original
            mk_app
            `eq [thyp, reordered]
      let nop ← to_expr op tt ff
      let pre ← pp reordered
      let (_, prf) ←
        solve_aux neq <|
            match nop with
            | q(Add.add) => sorry
            | q(Mul.mul) => sorry
            | _ =>
              ac_refl <|>
                fail
                  f! "the associative/commutative lemmas used do not suffice to prove that the initial goal equals:
                    
                    {pre}
                    Hint: try adding `is_associative` or `is_commutative` instances.
                    "
      match hyploc with
        | none => replace_target reordered prf
        | some hyploc => replace_hyp hyploc reordered prf >> skip
      return (ff, is_unused)
#align tactic.move_op.reorder_hyp tactic.move_op.reorder_hyp

section ParsingArgumentsForMoveOp

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- `move_op_arg` is a single elementary argument that `move_op` takes for the
variables to be moved.  It is either a `pexpr`, or a `pexpr` preceded by a `←`. -/
unsafe def move_op_arg (prec : Nat) : parser (Bool × pexpr) :=
  Prod.mk <$> Option.isSome <$> (tk "<-")? <*> parser.pexpr prec
#align tactic.move_op.move_op_arg tactic.move_op.move_op_arg

/-- `move_pexpr_list_or_texpr` is either a list of `move_op_arg`, possibly empty, or a single
`move_op_arg`. -/
unsafe def move_pexpr_list_or_texpr : parser (List (Bool × pexpr)) :=
  list_of (move_op_arg 0) <|> List.ret <$> move_op_arg tac_rbp <|> return []
#align tactic.move_op.move_pexpr_list_or_texpr tactic.move_op.move_pexpr_list_or_texpr

end ParsingArgumentsForMoveOp

end MoveOp

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
open MoveOp

/-- `move_op args locat op` is the non-interactive version of the main tactics `move_add` and
`move_mul` of this file.  Given as input `args` (a list of terms of a sequence of operands),
`locat` (hypotheses or goal where the tactic should act) and `op` (the operation to use),
`move_op` attempts to perform the rearrangement of the terms determined by `args`.

Currently, the tactic uses only `add/mul_comm, add/mul_assoc, add/mul_left_comm`, so other
operations will not actually work.
-/
unsafe def move_op (args : parse move_pexpr_list_or_texpr) (locat : parse location) (op : pexpr) :
    tactic Unit := do
  let locas ← locat.get_locals
  let tg ← target
  let locas_with_tg := if locat.include_goal then locas ++ [tg] else locas
  let ner ←
    locas_with_tg.mapM fun e => reorder_hyp op args e.local_pp_name <|> reorder_hyp op args none
  let (unch_tgts, unus_vars) := ner.unzip
  let str_unva ←
    match
        (returnUnused args (unus_vars.transpose.map List.and)).map fun e : Bool × pexpr => e.2 with
      | [] => pure []
      | [pe] => do
        let nm ← to_expr pe true false >>= fun ex => pp ex.replace_mvars
        return [f! "'{nm}' is an unused variable"]
      | pes => do
        let nms ←
          (pes.mapM fun e => to_expr e true false) >>= fun exs =>
              (exs.map expr.replace_mvars).mapM pp
        return [f! "'{nms}' are unused variables"]
  let str_tgts :=
    match locat with
    | loc.wildcard => if unch_tgts.and then [f!"nothing changed"] else []
    | loc.ns names =>
      let linames := returnUnused locas unch_tgts
      (if none ∈ returnUnused names unch_tgts then [f!"Goal did not change"] else []) ++
        if linames ≠ [] then [f! "'{linames.reverse}' did not change"] else []
  let [] ← pure (str_tgts ++ str_unva) |
    fail (format.intercalate "\n" (str_tgts ++ str_unva))
  assumption <|> try (tactic.reflexivity reducible)
#align tactic.move_op tactic.move_op

namespace Interactive

/--
Calling `move_add [a, ← b, c]`, recursively looks inside the goal for expressions involving a sum.
Whenever it finds one, it moves the summands that unify to `a, b, c`, removing all parentheses.
Repetitions are allowed, and are processed following the user-specified ordering.
The terms preceded by a `←` get placed to the left, the ones without the arrow get placed to the
right.  Unnamed terms stay in place.  Due to re-parenthesizing, doing `move_add` with no argument
may change the goal. Also, the *order* in which the terms are provided matters: the tactic reads
them from left to right.  This is especially important if there are multiple matches for the typed
terms in the given expressions.

A single call of `move_add` moves terms across different sums in the same expression.
Here is an example.

```lean
import tactic.move_add

example {a b c d : ℕ} (h : c = d) : c + b + a = b + a + d :=
begin
  move_add [← a, b],  -- Goal: `a + c + b = a + d + b`  -- both sides changed
  congr,
  exact h
end

example {a b c d : ℕ} (h : c = d) : c + b * c + a * c = a * d + d + b * d :=
begin
  move_add [_ * c, ← _ * c], -- Goal: `a * c + c + b * c = a * d + d + b * d`
  -- the first `_ * c` unifies with `b * c` and moves to the right
  -- the second `_ * c` unifies with `a * c` and moves to the left
  congr;
  assumption
end
```

The list of expressions that `move_add` takes is optional and a single expression can be passed
without brackets.  Thus `move_add ← f` and `move_add [← f]` mean the same.

Finally, `move_add` can also target one or more hypotheses.  If `hp₁, hp₂` are in the
local context, then `move_add [f, ← g] at hp₁ hp₂` performs the rearranging at `hp₁` and `hp₂`.
As usual, passing `⊢` refers to acting on the goal.

##  Reporting sub-optimal usage

The tactic could fail to prove the reordering.  One potential cause is when there are multiple
matches for the rearrangements and an earlier rewrite makes a subsequent one fail.  Another
possibility is that the rearranged expression changes the *Type* of some expression and the
tactic gets stumped.  Please, report bugs and failures in the Zulip chat!

There are three kinds of unwanted use for `move_add` that result in errors, where the tactic fails
and flags the unwanted use.
1. `move_add [vars]? at *` reports globally unused variables and whether *all* goals
   are unchanged, not *each unchanged goal*.
2. If a target of `move_add [vars]? at targets` is left unchanged by the tactic, then this will be
   flagged (unless we are using `at *`).
3. If a user-provided expression never unifies, then the variable is flagged.

In these cases, the tactic produces an error, reporting unused inputs and unchanged targets as
appropriate.

For instance, `move_add ← _` always fails reporting an unchanged goal, but never an unused variable.

##  Comparison with existing tactics

* `tactic.interactive.abel`
  performs a "reduction to normal form" that allows it to close goals involving sums with higher
  success rate than `move_add`.  If the goal is an equality of two sums that are simply obtained by
  reparenthesizing and permuting summands, then `move_add [appropriate terms]` can close the goal.
  Compared to `abel`, `move_add` has the advantage of allowing the user to specify the beginning and
  the end of the final sum, so that from there the user can continue with the proof.

* `tactic.interactive.ac_change`
  supports a wide variety of operations.  At the moment, `move_add` works with addition, `move_mul`
  works with multiplication.  There is the possibility of supporting other operations, using the
  non-interactive tactic `tactic.move_op`.
  Still, on several experiments, `move_add` had a much quicker performance than `ac_change`.
  Also, for `move_add` the user need only specify a few terms: the tactic itself takes care of
  producing the full rearrangement and proving it "behind the scenes".

###  Remark:
It is still possible that the same output of `move_add [exprs]` can be achieved by a proper sublist
of `[exprs]`, even if the tactic does not flag anything.  For instance, giving the full re-ordering
of the expressions in the target that we want to achieve will not complain that there are unused
variables, since all the user-provided variables have been matched.  Of course, specifying the order
of all-but-the-last variable suffices to determine the permutation.  E.g., with a goal of
`a + b = 0`, applying either one of `move_add [b,a]`, or `move_add a`, or `move_add ← b` has the
same effect and changes the goal to `b + a = 0`.  These are all valid uses of `move_add`.
-/
unsafe def move_add (args : parse move_pexpr_list_or_texpr) (locat : parse location) :
    tactic Unit :=
  move_op args locat ``((· + ·))
#align tactic.interactive.move_add tactic.interactive.move_add

/-- See the doc-string for `tactic.interactive.move_add` and mentally
replace addition with multiplication throughout. ;-) -/
unsafe def move_mul (args : parse move_pexpr_list_or_texpr) (locat : parse location) :
    tactic Unit :=
  move_op args locat ``(Mul.mul)
#align tactic.interactive.move_mul tactic.interactive.move_mul

/-- `move_oper` behaves like `move_add` except that it also takes an associative, commutative,
binary operation as input.  The operation must be passed as a list consisting of a single element.
For instance
```lean
example (a b : ℕ) : max a b = max b a :=
by move_oper [max] [← a, b] at *
```
solves the goal.  For more details, see the `move_add` doc-string, replacing `add` with your
intended operation.
-/
unsafe def move_oper (op : parse pexpr_list) (args : parse move_pexpr_list_or_texpr)
    (locat : parse location) : tactic Unit := do
  let [op] ← pure op |
    fail "only one operation is allowed"
  move_op args locat op
#align tactic.interactive.move_oper tactic.interactive.move_oper

add_tactic_doc
  { Name := "move_add"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.move_add]
    tags := ["arithmetic"] }

add_tactic_doc
  { Name := "move_mul"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.move_mul]
    tags := ["arithmetic"] }

end Interactive

end Tactic

