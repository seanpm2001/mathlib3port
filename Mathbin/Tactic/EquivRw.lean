/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module tactic.equiv_rw
! leanprover-community/mathlib commit 9407b03373c8cd201df99d6bc5514fc2db44054f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Equiv.Defs
import Mathbin.Tactic.Clear
import Mathbin.Tactic.SimpResult
import Mathbin.Tactic.Apply
import Mathbin.Control.EquivFunctor.Instances
import Mathbin.Logic.Equiv.Functor

/-!
# The `equiv_rw` tactic transports goals or hypotheses along equivalences.

The basic syntax is `equiv_rw e`, where `e : α ≃ β` is an equivalence.
This will try to replace occurrences of `α` in the goal with `β`, for example
transforming
* `⊢ α` to `⊢ β`,
* `⊢ option α` to `⊢ option β`
* `⊢ {a // P}` to `{b // P (⇑(equiv.symm e) b)}`

The tactic can also be used to rewrite hypotheses, using the syntax `equiv_rw e at h`.

## Implementation details

The main internal function is `equiv_rw_type e t`,
which attempts to turn an expression `e : α ≃ β` into a new equivalence with left hand side `t`.
As an example, with `t = option α`, it will generate `functor.map_equiv option e`.

This is achieved by generating a new synthetic goal `%%t ≃ _`,
and calling `solve_by_elim` with an appropriate set of congruence lemmas.
To avoid having to specify the relevant congruence lemmas by hand,
we mostly rely on `equiv_functor.map_equiv` and `bifunctor.map_equiv`
along with some structural congruence lemmas such as
* `equiv.arrow_congr'`,
* `equiv.subtype_equiv_of_subtype'`,
* `equiv.sigma_congr_left'`, and
* `equiv.Pi_congr_left'`.

The main `equiv_rw` function, when operating on the goal, simply generates a new equivalence `e'`
with left hand side matching the target, and calls `apply e'.inv_fun`.

When operating on a hypothesis `x : α`, we introduce a new fact `h : x = e.symm (e x)`, revert this,
and then attempt to `generalize`, replacing all occurrences of `e x` with a new constant `y`, before
`intro`ing and `subst`ing `h`, and renaming `y` back to `x`.

## Future improvements
In a future PR I anticipate that `derive equiv_functor` should work on many examples,
(internally using `transport`, which is in turn based on `equiv_rw`)
and we can incrementally bootstrap the strength of `equiv_rw`.

An ambitious project might be to add `equiv_rw!`,
a tactic which, when failing to find appropriate `equiv_functor` instances,
attempts to `derive` them on the spot.

For now `equiv_rw` is entirely based on `equiv`,
but the framework can readily be generalised to also work with other types of equivalences,
for example specific notations such as ring equivalence (`≃+*`),
or general categorical isomorphisms (`≅`).

This will allow us to transport across more general types of equivalences,
but this will wait for another subsequent PR.
-/


-- these make equiv_rw more powerful!
-- these make equiv_rw more powerful!
-- so do these!
-- so do these!
namespace Tactic

-- Although this looks 'hard-coded', in fact the lemma `equiv_functor.map_equiv`
-- allows us to extend `equiv_rw` simply by constructing new instance so `equiv_functor`.
-- TODO: We should also use `category_theory.functorial` and `category_theory.hygienic` instances.
-- (example goal: we could rewrite along an isomorphism of rings (either as `R ≅ S` or `R ≃+* S`)
-- and turn an `x : mv_polynomial σ R` into an `x : mv_polynomial σ S`.).
/-- A list of lemmas used for constructing congruence equivalences. -/
unsafe def equiv_congr_lemmas : List (tactic expr) :=
  [`equiv.of_iff,-- TODO decide what to do with this; it's an equiv_bifunctor?
        `equiv.equiv_congr,-- The function arrow is technically a bifunctor `Typeᵒᵖ → Type → Type`,
        -- but the pattern matcher will never see this.
        `equiv.arrow_congr',-- Allow rewriting in subtypes:
        `equiv.subtype_equiv_of_subtype',-- Allow rewriting in the first component of a sigma-type:
        `equiv.sigma_congr_left',-- Allow rewriting ∀s:
        -- (You might think that repeated application of `equiv.forall_congr'
        -- would handle the higher arity cases, but unfortunately unification is not clever enough.)
        `equiv.forall₃_congr',
        `equiv.forall₂_congr',
        `equiv.forall_congr',-- Allow rewriting in argument of Pi types:
        `equiv.Pi_congr_left',-- Handles `sum` and `prod`, and many others:
        `bifunctor.map_equiv,-- Handles `list`, `option`, `unique`, and many others:
        `equiv_functor.map_equiv,-- We have to filter results to ensure we don't cheat and use exclusively
        -- `equiv.refl` and `iff.refl`!
        `equiv.refl,
        `iff.refl].map
    fun n => mk_const n
#align tactic.equiv_congr_lemmas tactic.equiv_congr_lemmas

initialize
  registerTraceClass.1 `equiv_rw_type

/-- Configuration structure for `equiv_rw`.

* `max_depth` bounds the search depth for equivalences to rewrite along.
  The default value is 10.
  (e.g., if you're rewriting along `e : α ≃ β`, and `max_depth := 2`,
  you can rewrite `option (option α))` but not `option (option (option α))`.
-/
unsafe structure equiv_rw_cfg where
  max_depth : ℕ := 10
#align tactic.equiv_rw_cfg tactic.equiv_rw_cfg

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/-- Implementation of `equiv_rw_type`, using `solve_by_elim`.
Expects a goal of the form `t ≃ _`,
and tries to solve it using `eq : α ≃ β` and congruence lemmas.
-/
unsafe def equiv_rw_type_core (eq : expr) (cfg : equiv_rw_cfg) : tactic Unit := do
  /-
          We now call `solve_by_elim` to try to generate the requested equivalence.
          There are a few subtleties!
          * We make sure that `eq` is the first lemma, so it is applied whenever possible.
          * In `equiv_congr_lemmas`, we put `equiv.refl` last so it is only used when it is not possible
            to descend further.
          * Since some congruence lemmas generate subgoals with `∀` statements,
            we use the `pre_apply` subtactic of `solve_by_elim` to preprocess each new goal with `intros`.
        -/
      solve_by_elim
      { use_symmetry := False
        use_exfalso := False
        lemma_thunks := some (pure Eq :: equiv_congr_lemmas)
        ctx_thunk := pure []
        max_depth := cfg
        -- Subgoals may contain function types,
        -- and we want to continue trying to construct equivalences after the binders.
        pre_apply := tactic.intros >> skip
        backtrack_all_goals := tt
        -- If solve_by_elim gets stuck, make sure it isn't because there's a later `≃` or `↔` goal
        -- that we should still attempt.
        discharger :=
          (sorry >> sorry) >> (sorry <|> sorry) <|>
            trace_if_enabled `equiv_rw_type "Failed, no congruence lemma applied!" >> failed
        -- We use the `accept` tactic in `solve_by_elim` to provide tracing.
        accept := fun goals =>
          lock_tactic_state do
            when_tracing `equiv_rw_type do
                goals pp >>= fun goals => trace f! "So far, we've built: {goals}"
            done <|>
                when_tracing `equiv_rw_type do
                  let gs ← get_goals
                  let gs ← gs fun g => infer_type g >>= pp
                  trace f! "Attempting to adapt to {gs}" }
#align tactic.equiv_rw_type_core tactic.equiv_rw_type_core

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      `equiv_rw_type e t` rewrites the type `t` using the equivalence `e : α ≃ β`,
      returning a new equivalence `t ≃ t'`.
      -/
    unsafe
  def
    equiv_rw_type
    ( eqv : expr ) ( ty : expr ) ( cfg : equiv_rw_cfg ) : tactic expr
    :=
      do
        when_tracing
            `equiv_rw_type
              do
                let ty_pp ← pp ty
                  let eqv_pp ← pp eqv
                  let eqv_ty_pp ← infer_type eqv >>= pp
                  trace
                    f!
                      "Attempting to rewrite the type `{
                        ty_pp
                        }` using `{
                        eqv_pp
                        } : {
                        eqv_ty_pp
                        }`."
          let q( _ ≃ _ ) ← infer_type eqv | fail f! "{ eqv } must be an `equiv`"
          let equiv_ty ← to_expr ` `( $ ( ty ) ≃ _ )
          let new_eqv ← Prod.snd <$> ( solve_aux equiv_ty <| equiv_rw_type_core eqv cfg )
          let new_eqv ← instantiate_mvars new_eqv
          kdepends_on new_eqv eqv >>= guardb
            <|>
            do
              let eqv_pp ← pp eqv
                let ty_pp ← pp ty
                fail
                  f! "Could not construct an equivalence from { eqv_pp } of the form: { ty_pp } ≃ _"
          Prod.fst <$> new_eqv { failIfUnchanged := ff }
#align tactic.equiv_rw_type tactic.equiv_rw_type

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr'
/--
    The simpset `equiv_rw_simp` is used by the tactic `equiv_rw` to
    simplify applications of equivalences and their inverses. -/
  register_simp_attr
  equiv_rw_simp

attribute [equiv_rw_simp] Equiv.symm_symm Equiv.apply_symm_apply Equiv.symm_apply_apply

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      Attempt to replace the hypothesis with name `x`
      by transporting it along the equivalence in `e : α ≃ β`.
      -/
    unsafe
  def
    equiv_rw_hyp
    ( x : Name ) ( e : expr ) ( cfg : equiv_rw_cfg := { } ) : tactic Unit
    :=
      dsimp_result
        (
            do
              let x' ← get_local x
                let x_ty ← infer_type x'
                let e ← equiv_rw_type e x_ty cfg
                let
                  eq ← to_expr ` `( $ ( x' ) = Equiv.symm $ ( e ) ( Equiv.toFun $ ( e ) $ ( x' ) ) )
                let prf ← to_expr ` `( ( Equiv.symm_apply_apply $ ( e ) $ ( x' ) ) . symm )
                let h ← note_anon Eq prf
                revert h
                let ex ← to_expr ` `( Equiv.toFun $ ( e ) $ ( x' ) )
                generalize ex ( by infer_param ) transparency.none
                intro x
                let h ← intro1
                let b ← target >>= is_prop
                if
                  b
                  then
                  do subst h sorry
                  else
                  unfreezing_hyp x' ( clear' tt [ x' ] )
                    <|>
                    fail
                      f!
                        "equiv_rw expected to be able to clear the original hypothesis {
                          x
                          }, but couldn't."
                skip
            )
          { failIfUnchanged := false }
          true
#align tactic.equiv_rw_hyp tactic.equiv_rw_hyp

-- call `dsimp_result` with `no_defaults := tt`.
/-- Rewrite the goal using an equiv `e`. -/
unsafe def equiv_rw_target (e : expr) (cfg : equiv_rw_cfg := { }) : tactic Unit := do
  let t ← target
  let e ← equiv_rw_type e t cfg
  let s ← to_expr ``(Equiv.invFun $(e))
  tactic.eapply s
  skip
#align tactic.equiv_rw_target tactic.equiv_rw_target

end Tactic

namespace Tactic.Interactive

open Tactic

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- Auxiliary function to call `equiv_rw_hyp` on a `list pexpr` recursively. -/
unsafe def equiv_rw_hyp_aux (hyp : Name) (cfg : equiv_rw_cfg) (permissive : Bool := false) :
    List expr → itactic
  | [] => skip
  | e :: t => do
    if permissive then equiv_rw_hyp hyp e cfg <|> skip else equiv_rw_hyp hyp e cfg
    equiv_rw_hyp_aux t
#align tactic.interactive.equiv_rw_hyp_aux tactic.interactive.equiv_rw_hyp_aux

/-- Auxiliary function to call `equiv_rw_target` on a `list pexpr` recursively. -/
unsafe def equiv_rw_target_aux (cfg : equiv_rw_cfg) (permissive : Bool) : List expr → itactic
  | [] => skip
  | e :: t => do
    if permissive then equiv_rw_target e cfg <|> skip else equiv_rw_target e cfg
    equiv_rw_target_aux t
#align tactic.interactive.equiv_rw_target_aux tactic.interactive.equiv_rw_target_aux

/-- `equiv_rw e at h₁ h₂ ⋯`, where each `hᵢ : α` is a hypothesis, and `e : α ≃ β`,
will attempt to transport each `hᵢ` along `e`, producing a new hypothesis `hᵢ : β`,
with all occurrences of `hᵢ` in other hypotheses and the goal replaced with `e.symm hᵢ`.

`equiv_rw e` will attempt to transport the goal along an equivalence `e : α ≃ β`.
In its minimal form it replaces the goal `⊢ α` with `⊢ β` by calling `apply e.inv_fun`.

`equiv_rw [e₁, e₂, ⋯] at h₁ h₂ ⋯` is equivalent to
`{ equiv_rw [e₁, e₂, ⋯] at h₁, equiv_rw [e₁, e₂, ⋯] at h₂, ⋯ }`.

`equiv_rw [e₁, e₂, ⋯] at *` will attempt to apply `equiv_rw [e₁, e₂, ⋯]` on the goal
and on each expression available in the local context (except on the `eᵢ`s themselves),
failing silently when it can't. Failing on a rewrite for a certain `eᵢ` at a certain
hypothesis `h` doesn't stop `equiv_rw` from trying the other equivalences on the list
at `h`. This only happens for the wildcard location.

`equiv_rw` will also try rewriting under (equiv_)functors, so it can turn
a hypothesis `h : list α` into `h : list β` or
a goal `⊢ unique α` into `⊢ unique β`.

The maximum search depth for rewriting in subexpressions is controlled by
`equiv_rw e {max_depth := n}`.
-/
unsafe def equiv_rw (l : parse pexpr_list_or_texpr) (locat : parse location)
    (cfg : equiv_rw_cfg := { }) : itactic := do
  let es ← l.mapM fun e => to_expr e
  match locat with
    | loc.wildcard => do
      equiv_rw_target_aux cfg tt es
      let ctx ← local_context
      ctx fun e => if e ∈ es then skip else equiv_rw_hyp_aux e cfg tt es
      skip
    | loc.ns names => do
      names fun hyp' =>
          match hyp' with
          | some hyp => equiv_rw_hyp_aux hyp cfg ff es
          | none => equiv_rw_target_aux cfg ff es
      skip
#align tactic.interactive.equiv_rw tactic.interactive.equiv_rw

add_tactic_doc
  { Name := "equiv_rw"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.equiv_rw]
    tags := ["rewriting", "equiv", "transport"] }

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      Solve a goal of the form `t ≃ _`,
      by constructing an equivalence from `e : α ≃ β`.
      This is the same equivalence that `equiv_rw` would use to rewrite a term of type `t`.
      
      A typical usage might be:
      ```
      have e' : option α ≃ option β := by equiv_rw_type e
      ```
      -/
    unsafe
  def
    equiv_rw_type
    ( e : parse texpr ) ( cfg : equiv_rw_cfg := { } ) : itactic
    :=
      do
        let q( $ ( t ) ≃ _ ) ← target | fail "`equiv_rw_type` solves goals of the form `t ≃ _`."
          let e ← to_expr e
          tactic.equiv_rw_type e t cfg >>= tactic.exact
#align tactic.interactive.equiv_rw_type tactic.interactive.equiv_rw_type

add_tactic_doc
  { Name := "equiv_rw_type"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.equiv_rw_type]
    tags := ["rewriting", "equiv", "transport"] }

end Tactic.Interactive

