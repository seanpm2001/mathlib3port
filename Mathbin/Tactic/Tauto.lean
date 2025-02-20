/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module tactic.tauto
! leanprover-community/mathlib commit 3d7987cda72abc473c7cdbbb075170e9ac620042
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Hint

namespace Tactic

open Expr

open Tactic.Interactive (casesm constructor_matching)

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      find all assumptions of the shape `¬ (p ∧ q)` or `¬ (p ∨ q)` and
        replace them using de Morgan's law.
      -/
    unsafe
  def
    distrib_not
    : tactic Unit
    :=
      do
        let hs ← local_context
          hs
            fun
              h
                =>
                all_goals'
                  <|
                  iterate_at_most'
                    3
                      do
                        let h ← get_local h
                          let e ← infer_type h
                          match
                            e
                            with
                            | q( ¬ _ = _ ) => replace h ` `( mt Iff.to_eq $ ( h ) )
                              | q( _ ≠ _ ) => replace h ` `( mt Iff.to_eq $ ( h ) )
                              | q( _ = _ ) => replace h ` `( Eq.to_iff $ ( h ) )
                              |
                                q( ¬ ( _ ∧ _ ) )
                                =>
                                replace h ` `( Decidable.not_and' . mp $ ( h ) )
                                  <|>
                                  replace h ` `( Decidable.not_and . mp $ ( h ) )
                              | q( ¬ ( _ ∨ _ ) ) => replace h ` `( not_or . mp $ ( h ) )
                              | q( ¬ _ ≠ _ ) => replace h ` `( Decidable.of_not_not $ ( h ) )
                              | q( ¬ ¬ _ ) => replace h ` `( Decidable.of_not_not $ ( h ) )
                              |
                                q( ¬ ( _ → ( _ : Prop ) ) )
                                =>
                                replace h ` `( Decidable.not_imp . mp $ ( h ) )
                              | q( ¬ ( _ ↔ _ ) ) => replace h ` `( Decidable.not_iff . mp $ ( h ) )
                              |
                                q( _ ↔ _ )
                                =>
                                replace h ` `( Decidable.iff_iff_and_or_not_and_not . mp $ ( h ) )
                                  <|>
                                  replace
                                      h
                                        `
                                          `(
                                            Decidable.iff_iff_and_or_not_and_not . mp $ ( h ) . symm
                                            )
                                    <|>
                                    ( ) <$ tactic.cases h
                              | q( _ → _ ) => replace h ` `( Decidable.not_or_of_imp $ ( h ) )
                              | _ => failed
#align tactic.distrib_not tactic.distrib_not

/-!
  The following definitions maintain a path compression datastructure, i.e. a forest such that:
    - every node is the type of a hypothesis
    - there is a edge between two nodes only if they are provably equivalent
    - every edge is labelled with a proof of equivalence for its vertices
    - edges are added when normalizing propositions.
-/


unsafe def tauto_state :=
  ref <| expr_map (Option (expr × expr))
#align tactic.tauto_state tactic.tauto_state

unsafe def modify_ref {α : Type} (r : ref α) (f : α → α) :=
  read_ref r >>= write_ref r ∘ f
#align tactic.modify_ref tactic.modify_ref

unsafe def add_refl (r : tauto_state) (e : expr) : tactic (expr × expr) := do
  let m ← read_ref r
  let p ← mk_mapp `rfl [none, e]
  write_ref r <| m e none
  return (e, p)
#align tactic.add_refl tactic.add_refl

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      If there exists a symmetry lemma that can be applied to the hypothesis `e`,
        store it.
      -/
    unsafe
  def
    add_symm_proof
    ( r : tauto_state ) ( e : expr ) : tactic ( expr × expr )
    :=
      do
        let env ← get_env
          let rel := e . get_app_fn . const_name
          let some symm ← pure <| environment.symm_for env Rel | add_refl r e
          (
              do
                let e' ← mk_meta_var q( Prop )
                  let iff_t ← to_expr ` `( $ ( e ) = $ ( e' ) )
                  let
                    ( _ , p )
                      ←
                      solve_aux
                        iff_t
                          (
                            andthen
                              ( andthen ( applyc `iff.to_eq ) ( ( ) <$ split ) ) ( applyc symm )
                            )
                  let e' ← instantiate_mvars e'
                  let m ← read_ref r
                  write_ref r <| ( m e ( e' , p ) ) . insert e' none
                  return ( e' , p )
              )
            <|>
            add_refl r e
#align tactic.add_symm_proof tactic.add_symm_proof

unsafe def add_edge (r : tauto_state) (x y p : expr) : tactic Unit :=
  modify_ref r fun m => m.insert x (y, p)
#align tactic.add_edge tactic.add_edge

/-- Retrieve the root of the hypothesis `e` from the proof forest.
  If `e` has not been internalized, add it to the proof forest.
-/
unsafe def root (r : tauto_state) : expr → tactic (expr × expr)
  | e => do
    let m ← read_ref r
    let record_e : tactic (expr × expr) :=
      match e with
      | v@(expr.mvar _ _ _) =>
        (do
            let (e, p) ← get_assignment v >>= root
            add_edge r v e p
            return (e, p)) <|>
          add_refl r e
      | _ => add_refl r e
    let some e' ← pure <| m.find e |
      record_e
    match e' with
      | some (e', p') => do
        let (e'', p'') ← root e'
        let p'' ← mk_app `eq.trans [p', p'']
        add_edge r e e'' p''
        pure (e'', p'')
      | none => Prod.mk e <$> mk_mapp `rfl [none, some e]
#align tactic.root tactic.root

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      Given hypotheses `a` and `b`, build a proof that `a` is equivalent to `b`,
        applying congruence and recursing into arguments if `a` and `b`
        are applications of function symbols.
      -/
    unsafe
  def
    symm_eq
    ( r : tauto_state ) : expr → expr → tactic expr
    |
      a , b
      =>
      do
        let m ← read_ref r
          let ( a' , pa ) ← root r a
          let ( b' , pb ) ← root r b
          unify a' b' >> add_refl r a' *> mk_mapp `rfl [ none , a ]
            <|>
            do
              let
                  p
                    ←
                    match
                      ( a' , b' )
                      with
                      |
                          ( q( ¬ $ ( a₀ ) ) , q( ¬ $ ( b₀ ) ) )
                          =>
                          do
                            let p ← symm_eq a₀ b₀
                              let p' ← mk_app `congr_arg [ q( Not ) , p ]
                              add_edge r a' b' p'
                              return p'
                        |
                          ( q( $ ( a₀ ) ∧ $ ( a₁ ) ) , q( $ ( b₀ ) ∧ $ ( b₁ ) ) )
                          =>
                          do
                            let p₀ ← symm_eq a₀ b₀
                              let p₁ ← symm_eq a₁ b₁
                              let p' ← to_expr ` `( congr ( congr_arg And $ ( p₀ ) ) $ ( p₁ ) )
                              add_edge r a' b' p'
                              return p'
                        |
                          ( q( $ ( a₀ ) ∨ $ ( a₁ ) ) , q( $ ( b₀ ) ∨ $ ( b₁ ) ) )
                          =>
                          do
                            let p₀ ← symm_eq a₀ b₀
                              let p₁ ← symm_eq a₁ b₁
                              let p' ← to_expr ` `( congr ( congr_arg Or $ ( p₀ ) ) $ ( p₁ ) )
                              add_edge r a' b' p'
                              return p'
                        |
                          ( q( $ ( a₀ ) ↔ $ ( a₁ ) ) , q( $ ( b₀ ) ↔ $ ( b₁ ) ) )
                          =>
                          (
                              do
                                let p₀ ← symm_eq a₀ b₀
                                  let p₁ ← symm_eq a₁ b₁
                                  let p' ← to_expr ` `( congr ( congr_arg Iff $ ( p₀ ) ) $ ( p₁ ) )
                                  add_edge r a' b' p'
                                  return p'
                              )
                            <|>
                            do
                              let p₀ ← symm_eq a₀ b₁
                                let p₁ ← symm_eq a₁ b₀
                                let
                                  p'
                                    ←
                                    to_expr
                                      `
                                        `(
                                          Eq.trans
                                            ( congr ( congr_arg Iff $ ( p₀ ) ) $ ( p₁ ) )
                                              ( Iff.to_eq Iff.comm )
                                          )
                                add_edge r a' b' p'
                                return p'
                        |
                          ( q( $ ( a₀ ) → $ ( a₁ ) ) , q( $ ( b₀ ) → $ ( b₁ ) ) )
                          =>
                          if
                            ¬ a₁ ∧ ¬ b₁
                            then
                            do
                              let p₀ ← symm_eq a₀ b₀
                                let p₁ ← symm_eq a₁ b₁
                                let p' ← mk_app `congr_arg [ q( Implies ) , p₀ , p₁ ]
                                add_edge r a' b' p'
                                return p'
                            else
                            unify a' b' >> add_refl r a' *> mk_mapp `rfl [ none , a ]
                        |
                          ( _ , _ )
                          =>
                          do
                            guard <| a' ∧ a' = b'
                              let ( a'' , pa' ) ← add_symm_proof r a'
                              guard <| a'' == b'
                              pure pa'
                let p' ← mk_eq_trans pa p
                add_edge r a' b' p'
                mk_eq_symm pb >>= mk_eq_trans p'
#align tactic.symm_eq tactic.symm_eq

unsafe def find_eq_type (r : tauto_state) : expr → List expr → tactic (expr × expr)
  | e, [] => failed
  | e, H :: Hs => do
    let t ← infer_type H
    Prod.mk H <$> symm_eq r e t <|> find_eq_type e Hs
#align tactic.find_eq_type tactic.find_eq_type

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
private unsafe
  def
    contra_p_not_p
    ( r : tauto_state ) : List expr → List expr → tactic Unit
    | [ ] , Hs => failed
      |
        H1 :: Rs , Hs
        =>
        do
          let t ← extract_opt_auto_param <$> infer_type H1 >>= whnf
            (
                do
                  let a ← match_not t
                    let ( H2 , p ) ← find_eq_type r a Hs
                    let H2 ← to_expr ` `( $ ( p ) . mpr $ ( H2 ) )
                    let tgt ← target
                    let pr ← mk_app `absurd [ tgt , H2 , H1 ]
                    tactic.exact pr
                )
              <|>
              contra_p_not_p Rs Hs

unsafe def contradiction_with (r : tauto_state) : tactic Unit :=
  contradiction <|> do
    tactic.try intro1
    let ctx ← local_context
    contra_p_not_p r ctx ctx
#align tactic.contradiction_with tactic.contradiction_with

unsafe def contradiction_symm :=
  using_new_ref (native.rb_map.mk _ _) contradiction_with
#align tactic.contradiction_symm tactic.contradiction_symm

unsafe def assumption_with (r : tauto_state) : tactic Unit :=
  (do
      let ctx ← local_context
      let t ← target
      let (H, p) ← find_eq_type r t ctx
      mk_eq_mpr p H >>= tactic.exact) <|>
    fail "assumption tactic failed"
#align tactic.assumption_with tactic.assumption_with

unsafe def assumption_symm :=
  using_new_ref (native.rb_map.mk _ _) assumption_with
#align tactic.assumption_symm tactic.assumption_symm

/-- Configuration options for `tauto`.
  If `classical` is `tt`, runs `classical` before the rest of `tauto`.
  `closer` is run on any remaining subgoals left by `tauto_core; basic_tauto_tacs`.
-/
unsafe structure tauto_cfg where
  classical : Bool := false
  closer : tactic Unit := pure ()
#align tactic.tauto_cfg tactic.tauto_cfg

unsafe def tautology (cfg : tauto_cfg := { }) : tactic Unit :=
  focus1 <|
    let basic_tauto_tacs : List (tactic Unit) :=
      [reflexivity, solve_by_elim,
        constructor_matching none [``(_ ∧ _), ``(_ ↔ _), ``(Exists _), ``(True)]]
    let tauto_core (r : tauto_state) : tactic Unit := do
      andthen (andthen (try (contradiction_with r)) (try (assumption_with r)))
          (repeat do
            let gs ← get_goals
            andthen
                (andthen
                  (andthen
                    (andthen
                      (andthen
                        (andthen
                          (andthen (andthen (repeat (() <$ tactic.intro1)) distrib_not)
                            (casesm (some ()) [``(_ ∧ _), ``(_ ∨ _), ``(Exists _), ``(False)]))
                          (try (contradiction_with r)))
                        (try ((target >>= match_or) >> refine ``(or_iff_not_imp_left.mpr _))))
                      (try ((target >>= match_or) >> refine ``(or_iff_not_imp_right.mpr _))))
                    (repeat (() <$ tactic.intro1)))
                  (constructor_matching (some ()) [``(_ ∧ _), ``(_ ↔ _), ``(True)]))
                (try (assumption_with r))
            let gs' ← get_goals
            guard (gs ≠ gs'))
    do
    when cfg (classical tt)
    andthen (andthen (using_new_ref (expr_map.mk _) tauto_core) (repeat (first basic_tauto_tacs)))
        cfg
    done
#align tactic.tautology tactic.tautology

namespace Interactive

local postfix:1024 "?" => optional

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- `tautology` breaks down assumptions of the form `_ ∧ _`, `_ ∨ _`, `_ ↔ _` and `∃ _, _`
and splits a goal of the form `_ ∧ _`, `_ ↔ _` or `∃ _, _` until it can be discharged
using `reflexivity` or `solve_by_elim`.
This is a finishing tactic: it either closes the goal or raises an error.
The variant `tautology!` uses the law of excluded middle.

`tautology {closer := tac}` will use `tac` on any subgoals created by `tautology`
that it is unable to solve before failing.
-/
unsafe def tautology (c : parse <| (tk "!")?) (cfg : tactic.tauto_cfg := { }) :=
  tactic.tautology <| { cfg with classical := c.isSome }
#align tactic.interactive.tautology tactic.interactive.tautology

-- Now define a shorter name for the tactic `tautology`.
/-- `tauto` breaks down assumptions of the form `_ ∧ _`, `_ ∨ _`, `_ ↔ _` and `∃ _, _`
and splits a goal of the form `_ ∧ _`, `_ ↔ _` or `∃ _, _` until it can be discharged
using `reflexivity` or `solve_by_elim`.
This is a finishing tactic: it either closes the goal or raises an error.
The variant `tauto!` uses the law of excluded middle.

`tauto {closer := tac}` will use `tac` on any subgoals created by `tauto`
that it is unable to solve before failing.
-/
unsafe def tauto (c : parse <| (tk "!")?) (cfg : tactic.tauto_cfg := { }) : tactic Unit :=
  tautology c cfg
#align tactic.interactive.tauto tactic.interactive.tauto

add_hint_tactic tauto

/-- This tactic (with shorthand `tauto`) breaks down assumptions of the form
`_ ∧ _`, `_ ∨ _`, `_ ↔ _` and `∃ _, _`
and splits a goal of the form `_ ∧ _`, `_ ↔ _` or `∃ _, _` until it can be discharged
using `reflexivity` or `solve_by_elim`. This is a finishing tactic: it
either closes the goal or raises an error.

The variants `tautology!` and `tauto!` use the law of excluded middle.

For instance, one can write:
```lean
example (p q r : Prop) [decidable p] [decidable r] : p ∨ (q ∧ r) ↔ (p ∨ q) ∧ (r ∨ p ∨ r) := by tauto
```
and the decidability assumptions can be dropped if `tauto!` is used
instead of `tauto`.

`tauto {closer := tac}` will use `tac` on any subgoals created by `tauto`
that it is unable to solve before failing.
-/
add_tactic_doc
  { Name := "tautology"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.tautology, `tactic.interactive.tauto]
    tags := ["logic", "decision procedure"] }

end Interactive

end Tactic

