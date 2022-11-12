/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner, Simon Hudon, Scott Morrison
-/
import Mathbin.Tactic.EquivRw

/-!
## The `transport` tactic

`transport` attempts to move an `s : S α` expression across an equivalence `e : α ≃ β` to solve
a goal of the form `S β`, by building the new object field by field, taking each field of `s`
and rewriting it along `e` using the `equiv_rw` tactic.

We try to ensure good definitional properties, so that, for example, when we transport a `monoid α`
to a `monoid β`, the new multiplication is definitionally `λ x y, e (e.symm a * e.symm b)`.
-/


namespace Tactic

open Tactic.Interactive

/- failed to parenthesize: unknown constant 'Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr'
[PrettyPrinter.parenthesize.input] (Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr
     [(Command.docComment
       "/--"
       "The simpset `transport_simps` is used by the tactic `transport`\nto simplify certain expressions involving application of equivalences,\nand trivial `eq.rec` or `ep.mpr` conversions.\nIt's probably best not to adjust it without understanding the algorithm used by `transport`. -/")]
     "register_simp_attr"
     `transport_simps)-/-- failed to format: unknown constant 'Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr'
/--
    The simpset `transport_simps` is used by the tactic `transport`
    to simplify certain expressions involving application of equivalences,
    and trivial `eq.rec` or `ep.mpr` conversions.
    It's probably best not to adjust it without understanding the algorithm used by `transport`. -/
  register_simp_attr
  transport_simps

attribute [transport_simps]
  eq_rec_constant eq_mp_eq_cast cast_eq Equiv.to_fun_as_coe Equiv.arrow_congr'_apply Equiv.symm_apply_apply Equiv.apply_eq_iff_eq_symm_apply

/- ./././Mathport/Syntax/Translate/Expr.lean:332:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:332:4: warning: unsupported (TODO): `[tacs] -/
-- we use `apply_eq_iff_eq_symm_apply` rather than `apply_eq_iff_eq`,
-- as many axioms have a constant on the right-hand-side
-- At present we don't actually use `s`; it's inferred in the `mk_app` call.
/-- Given `s : S α` for some structure `S` depending on a type `α`,
and an equivalence `e : α ≃ β`,
try to produce an `S β`,
by transporting data and axioms across `e` using `equiv_rw`.
-/
@[nolint unused_arguments]
unsafe def transport (s e : expr) : tactic Unit := do
  let (_, α, β) ←
    infer_type e >>= relation_lhs_rhs <|> fail f!"second argument to `transport` was not an equivalence-type relation"
  -- We explode the goal into individual fields using `refine_struct`.
      -- Later we'll want to also consider falling back to `fconstructor`,
      -- but for now this suffices.
      seq'
      sorry
      (-- We now deal with each field sequentially.
        -- Since we may pass goals through to the user if the heuristics here fail,
        -- we wrap everything in `propagate_tags`.
        propagate_tags
        (try do
          let f
            ←-- Look up the name of the current field being processed
              get_current_field
          -- Note the value in the original structure.
                -- (This `mk_mapp` call with second argument inferred only works for typeclasses!)
                mk_mapp
                f [α, none] >>=
              note f none
          let b
            ←-- We now run different algorithms,
                -- depending on whether we're transporting data or a proposition.
                target >>=
                is_prop
          -- In order to achieve good definitional properties,
              -- we use `simp_result` to intercept the synthesized term and simplify it,
              -- in particular simplifying along `eq_rec_constant`.
              if ¬b then
              simp_result do
                -- For data fields, simply rewrite them using `equiv_rw`.
                    equiv_rw_hyp
                    f e
                get_local f >>= exact
            else
              try do
                -- The goal probably has messy expressions produced by `equiv_rw` acting on early data fields,
                    -- so we clean up a little.
                    try
                    unfold_projs_target
                sorry
                -- If the field is an equation in `β`, try to use injectivity of the equivalence
                    -- to turn it into an equation in `α`.
                    -- (If the left hand side of the equation involved an operation we've already transported,
                    -- this step has already been achieved by the `transport_simps`, so we `try` this step.)
                    try <|
                    under_binders <| to_expr (pquote.1 (%%ₓe).symm.Injective) >>= apply
                -- Finally, rewrite the original field value using the equivalence `e`, and try to close
                    -- the goal using
                    equiv_rw_hyp
                    f e
                get_local f >>= exact))
#align tactic.transport tactic.transport

namespace Interactive

setup_tactic_parser

/-- Given a goal `⊢ S β` for some type class `S`, and an equivalence `e : α ≃ β`.
`transport using e` will look for a hypothesis `s : S α`,
and attempt to close the goal by transporting `s` across the equivalence `e`.

```lean
example {α : Type} [ring α] {β : Type} (e : α ≃ β) : ring β :=
by transport using e.
```

You can specify the object to transport using `transport s using e`.

`transport` works by attempting to copy each of the operations and axiom fields of `s`,
rewriting them using `equiv_rw e` and defining a new structure using these rewritten fields.

If it fails to fill in all the new fields, `transport` will produce new subgoals.
It's probably best to think about which missing `simp` lemmas would have allowed `transport`
to finish, rather than solving these goals by hand.
(This may require looking at the implementation of `tranport` to understand its algorithm;
there are several examples of "transport-by-hand" at the end of `test/equiv_rw.lean`,
which `transport` is an abstraction of.)
-/
unsafe def transport (s : parse texpr ?) (e : parse <| tk "using" *> texpr) : itactic := do
  let s ←
    match s with
      | some s => to_expr s
      | none =>
        (do
            let t ← target
            let n := t.get_app_fn.const_name
            let ctx ← local_context
            ctx fun e => do
                let t ← infer_type e
                guard (t = n)
                return e) <|>
          fail "`transport` could not find an appropriate source object. Try `transport s using e`."
  let e ← to_expr e
  tactic.transport s e
#align tactic.interactive.transport tactic.interactive.transport

add_tactic_doc
  { Name := "transport", category := DocCategory.tactic, declNames := [`tactic.interactive.transport],
    tags := ["rewriting", "equiv", "transport"] }

end Interactive

end Tactic

