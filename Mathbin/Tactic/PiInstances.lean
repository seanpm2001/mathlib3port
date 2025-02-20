/-
Copyright (c) 2018 Simon Hudon All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module tactic.pi_instances
! leanprover-community/mathlib commit f36c98e877dd86af12606abbba5275513baa8a26
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Basic

/-!
# `pi_instance`

Automation for creating instances of mathematical structures for pi types
-/


namespace Tactic

open Tactic.Interactive

/-- Attempt to clear a goal obtained by refining a `pi_instance` goal. -/
unsafe def pi_instance_derive_field : tactic Unit := do
  let b ← target >>= is_prop
  let field ← get_current_field
  if b then do
      let vs ← introv [] <|> pure []
      let hs ← intros <|> pure []
      reset_instance_cache
      let xn ← get_unused_name
      try (() <$ ext1 [rcases_patt.one xn] <|> () <$ intro xn)
      let xv ← Option.iget <$> try_core (get_local xn)
      applyc Field
      hs fun h =>
          try <|
            () <$ (to_expr ``(congr_fun $(h) $(xv)) >>= apply) <|>
              () <$ apply (h xv) <|>
                () <$ (to_expr ``(Set.mem_image_of_mem _ $(h)) >>= apply) <|> () <$ solve_by_elim
      return ()
    else
      focus1 do
        let expl_arity ← mk_const Field >>= get_expl_arity
        let xs ← (List.iota expl_arity).mapM fun _ => intro1
        let x ← intro1
        applyc Field
        (xs fun h =>
              try <| () <$ (apply (h x) <|> apply h) <|> refine ``(Set.image (· <| $(x)) $(h))) <|>
            fail "args"
        return ()
#align tactic.pi_instance_derive_field tactic.pi_instance_derive_field

/-- `pi_instance` constructs an instance of `my_class (Π i : I, f i)`
where we know `Π i, my_class (f i)`. If an order relation is required,
it defaults to `pi.partial_order`. Any field of the instance that
`pi_instance` cannot construct is left untouched and generated as a new goal.
-/
unsafe def pi_instance : tactic Unit :=
  andthen (refine_struct ``({ Pi.partialOrder with .. }))
    (propagate_tags (try <| pi_instance_derive_field >> done))
#align tactic.pi_instance tactic.pi_instance

run_cmd
  add_interactive [`pi_instance]

add_tactic_doc
  { Name := "pi_instance"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.pi_instance]
    tags := ["type class"] }

end Tactic

