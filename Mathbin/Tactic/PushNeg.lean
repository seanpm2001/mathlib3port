/-
Copyright (c) 2019 Patrick Massot All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Simon Hudon

! This file was ported from Lean 3 source module tactic.push_neg
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Core
import Mathbin.Logic.Basic

/-!
# A tactic pushing negations into an expression
-/


open Tactic Expr

/- Enable the option `trace.push_neg.use_distrib` in order to have `¬ (p ∧ q)` normalized to
`¬ p ∨ ¬ q`, rather than the default `p → ¬ q`. -/
initialize
  registerTraceClass.1 `push_neg.use_distrib

namespace PushNeg

section

universe u

variable {α : Sort u}

variable (p q : Prop)

variable (s : α → Prop)

attribute [local instance] Classical.propDecidable

theorem not_not_eq : (¬¬p) = p :=
  propext not_not
#align push_neg.not_not_eq PushNeg.not_not_eq

theorem not_and_eq : (¬(p ∧ q)) = (p → ¬q) :=
  propext not_and
#align push_neg.not_and_eq PushNeg.not_and_eq

theorem not_and_distrib_eq : (¬(p ∧ q)) = (¬p ∨ ¬q) :=
  propext not_and_or
#align push_neg.not_and_distrib_eq PushNeg.not_and_distrib_eq

theorem not_or_eq : (¬(p ∨ q)) = (¬p ∧ ¬q) :=
  propext not_or
#align push_neg.not_or_eq PushNeg.not_or_eq

theorem not_forall_eq : (¬∀ x, s x) = ∃ x, ¬s x :=
  propext not_forall
#align push_neg.not_forall_eq PushNeg.not_forall_eq

theorem not_exists_eq : (¬∃ x, s x) = ∀ x, ¬s x :=
  propext not_exists
#align push_neg.not_exists_eq PushNeg.not_exists_eq

theorem not_implies_eq : (¬(p → q)) = (p ∧ ¬q) :=
  propext not_imp
#align push_neg.not_implies_eq PushNeg.not_implies_eq

theorem Classical.implies_iff_not_or : p → q ↔ ¬p ∨ q :=
  imp_iff_not_or
#align push_neg.classical.implies_iff_not_or PushNeg.Classical.implies_iff_not_or

theorem not_eq (a b : α) : ¬a = b ↔ a ≠ b :=
  Iff.rfl
#align push_neg.not_eq PushNeg.not_eq

variable {β : Type u}

variable [LinearOrder β]

theorem not_le_eq (a b : β) : (¬a ≤ b) = (b < a) :=
  propext not_le
#align push_neg.not_le_eq PushNeg.not_le_eq

theorem not_lt_eq (a b : β) : (¬a < b) = (b ≤ a) :=
  propext not_lt
#align push_neg.not_lt_eq PushNeg.not_lt_eq

end

unsafe def whnf_reducible (e : expr) : tactic expr :=
  whnf e reducible
#align push_neg.whnf_reducible push_neg.whnf_reducible

-- failed to format: unknown constant 'term.pseudo.antiquot'
private unsafe
  def
    transform_negation_step
    ( e : expr ) : tactic ( Option ( expr × expr ) )
    :=
      do
        let e ← whnf_reducible e
          match
            e
            with
            |
                q( ¬ $ ( Ne ) )
                =>
                do
                  let ne ← whnf_reducible Ne
                    match
                      Ne
                      with
                      |
                          q( ¬ $ ( a ) )
                          =>
                          do let pr ← mk_app ` ` not_not_eq [ a ] return ( some ( a , pr ) )
                        |
                          q( $ ( a ) ∧ $ ( b ) )
                          =>
                          do
                            let distrib ← get_bool_option `trace.push_neg.use_distrib ff
                              if
                                Distrib
                                then
                                do
                                  let pr ← mk_app ` ` not_and_distrib_eq [ a , b ]
                                    return ( some ( q( ¬ ( $ ( a ) : Prop ) ∨ ¬ $ ( b ) ) , pr ) )
                                else
                                do
                                  let pr ← mk_app ` ` not_and_eq [ a , b ]
                                    return ( some ( q( ( $ ( a ) : Prop ) → ¬ $ ( b ) ) , pr ) )
                        |
                          q( $ ( a ) ∨ $ ( b ) )
                          =>
                          do
                            let pr ← mk_app ` ` not_or_eq [ a , b ]
                              return ( some ( q( ¬ $ ( a ) ∧ ¬ $ ( b ) ) , pr ) )
                        |
                          q( $ ( a ) ≤ $ ( b ) )
                          =>
                          do
                            let e ← to_expr ` `( $ ( b ) < $ ( a ) )
                              let pr ← mk_app ` ` not_le_eq [ a , b ]
                              return ( some ( e , pr ) )
                        |
                          q( $ ( a ) < $ ( b ) )
                          =>
                          do
                            let e ← to_expr ` `( $ ( b ) ≤ $ ( a ) )
                              let pr ← mk_app ` ` not_lt_eq [ a , b ]
                              return ( some ( e , pr ) )
                        |
                          q( Exists $ ( p ) )
                          =>
                          do
                            let pr ← mk_app ` ` not_exists_eq [ p ]
                              let
                                e
                                  ←
                                  match
                                    p
                                    with
                                    |
                                        lam n bi typ bo
                                        =>
                                        do
                                          let body ← mk_app ` ` Not [ bo ]
                                            return ( pi n bi typ body )
                                      | _ => tactic.fail "Unexpected failure negating ∃"
                              return ( some ( e , pr ) )
                        |
                          pi n bi d p
                          =>
                          if
                            p
                            then
                            do
                              let pr ← mk_app ` ` not_forall_eq [ lam n bi d p ]
                                let body ← mk_app ` ` Not [ p ]
                                let e ← mk_app ` ` Exists [ lam n bi d body ]
                                return ( some ( e , pr ) )
                            else
                            do
                              let pr ← mk_app ` ` not_implies_eq [ d , p ]
                                let q( $ ( _ ) = $ ( e' ) ) ← infer_type pr
                                return ( some ( e' , pr ) )
                        | _ => return none
              | _ => return none
#align push_neg.transform_negation_step push_neg.transform_negation_step

private unsafe def transform_negation : expr → tactic (Option (expr × expr))
  | e => do
    let some (e', pr) ← transform_negation_step e |
      return none
    let some (e'', pr') ← transform_negation e' |
      return (some (e', pr))
    let pr'' ← mk_eq_trans pr pr'
    return (some (e'', pr''))
#align push_neg.transform_negation push_neg.transform_negation

unsafe def normalize_negations (t : expr) : tactic (expr × expr) := do
  let (_, e, pr) ←
    simplify_top_down ()
        (fun _ => fun e => do
          let oepr ← transform_negation e
          match oepr with
            | some (e', pr) => return ((), e', pr)
            | none => do
              let pr ← mk_eq_refl e
              return ((), e, pr))
        t { eta := false }
  return (e, pr)
#align push_neg.normalize_negations push_neg.normalize_negations

unsafe def push_neg_at_hyp (h : Name) : tactic Unit := do
  let H ← get_local h
  let t ← infer_type H
  let (e, pr) ← normalize_negations t
  replace_hyp H e pr
  skip
#align push_neg.push_neg_at_hyp push_neg.push_neg_at_hyp

unsafe def push_neg_at_goal : tactic Unit := do
  let H ← target
  let (e, pr) ← normalize_negations H
  replace_target e pr
#align push_neg.push_neg_at_goal push_neg.push_neg_at_goal

end PushNeg

open Interactive (parse loc.ns loc.wildcard)

open Interactive.Types (location texpr)

open Lean.Parser (tk ident many)

open Interactive.Loc

-- mathport name: parser.optional
local postfix:1024 "?" => optional

-- mathport name: parser.many
local postfix:1024 "*" => many

open PushNeg

/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/-- Push negations in the goal of some assumption.

For instance, a hypothesis `h : ¬ ∀ x, ∃ y, x ≤ y` will be transformed by `push_neg at h` into
`h : ∃ x, ∀ y, y < x`. Variables names are conserved.

This tactic pushes negations inside expressions. For instance, given an assumption
```lean
h : ¬ ∀ ε > 0, ∃ δ > 0, ∀ x, |x - x₀| ≤ δ → |f x - y₀| ≤ ε)
```
writing `push_neg at h` will turn `h` into
```lean
h : ∃ ε, ε > 0 ∧ ∀ δ, δ > 0 → (∃ x, |x - x₀| ≤ δ ∧ ε < |f x - y₀|),
```

(the pretty printer does *not* use the abreviations `∀ δ > 0` and `∃ ε > 0` but this issue
has nothing to do with `push_neg`).
Note that names are conserved by this tactic, contrary to what would happen with `simp`
using the relevant lemmas. One can also use this tactic at the goal using `push_neg`,
at every assumption and the goal using `push_neg at *` or at selected assumptions and the goal
using say `push_neg at h h' ⊢` as usual.
-/
unsafe def tactic.interactive.push_neg : parse location → tactic Unit
  | loc.ns loc_l =>
    loc_l.mmap' fun l =>
      match l with
      | some h => do
        push_neg_at_hyp h
        try <|
            interactive.simp_core { eta := ff } failed tt [simp_arg_type.expr ``(PushNeg.not_eq)] []
              (Interactive.Loc.ns [some h])
      | none => do
        push_neg_at_goal
        try sorry
  | loc.wildcard => do
    push_neg_at_goal
    local_context >>= mmap' fun h => push_neg_at_hyp (local_pp_name h)
    try sorry
#align tactic.interactive.push_neg tactic.interactive.push_neg

add_tactic_doc
  { Name := "push_neg"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.push_neg]
    tags := ["logic"] }

theorem imp_of_not_imp_not (P Q : Prop) : (¬Q → ¬P) → P → Q := fun h hP =>
  by_contradiction fun h' => h h' hP
#align imp_of_not_imp_not imp_of_not_imp_not

/-- Matches either an identifier "h" or a pair of identifiers "h with k" -/
unsafe def name_with_opt : lean.parser (Name × Option Name) :=
  Prod.mk <$> ident <*> (some <$> (tk "with" *> ident) <|> return none)
#align name_with_opt name_with_opt

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment
        "/--"
        "Transforms the goal into its contrapositive.\n\n* `contrapose`     turns a goal `P → Q` into `¬ Q → ¬ P`\n* `contrapose!`    turns a goal `P → Q` into `¬ Q → ¬ P` and pushes negations inside `P` and `Q`\n  using `push_neg`\n* `contrapose h`   first reverts the local assumption `h`, and then uses `contrapose` and `intro h`\n* `contrapose! h`  first reverts the local assumption `h`, and then uses `contrapose!` and `intro h`\n* `contrapose h with new_h` uses the name `new_h` for the introduced hypothesis\n-/")]
      []
      []
      []
      [(Command.unsafe "unsafe")]
      [])
     (Command.def
      "def"
      (Command.declId `tactic.interactive.contrapose [])
      (Command.optDeclSig
       [(Term.explicitBinder
         "("
         [`push]
         [":"
          (Term.app `parse [(Tactic.PushNeg.parser.optional (Term.app `tk [(str "\"!\"")]) "?")])]
         []
         ")")]
       [(Term.typeSpec
         ":"
         (Term.arrow
          (Term.app `parse [(Tactic.PushNeg.parser.optional `name_with_opt "?")])
          "→"
          (Term.app `tactic [`Unit])))])
      (Command.declValEqns
       (Term.matchAltsWhereDecls
        (Term.matchAlts
         [(Term.matchAlt
           "|"
           [[(Term.app `some [(Term.tuple "(" [`h "," [`h']] ")")])]]
           "=>"
           («term_>>_»
            («term_>>_»
             («term_>>_»
              («term_>>=_» (Term.app `get_local [`h]) ">>=" `revert)
              ">>"
              (Term.app `tactic.interactive.contrapose [`none]))
             ">>"
             (Term.app `intro [(Term.app (Term.proj `h' "." `getOrElse) [`h])]))
            ">>"
            `skip))
          (Term.matchAlt
           "|"
           [[`none]]
           "=>"
           (Term.do
            "do"
            (Term.doSeqIndent
             [(Term.doSeqItem
               (Term.doLetArrow
                "let"
                []
                (Term.doPatDecl
                 (Qq.«termQ(__)»
                  "q("
                  (Term.arrow
                   (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `P ")") [])
                   "→"
                   (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `Q ")") []))
                  []
                  ")")
                 "←"
                 (Term.doExpr `target)
                 ["|"
                  (Term.doSeqIndent
                   [(Term.doSeqItem
                     (Term.doExpr
                      (Term.app
                       `fail
                       [(str
                         "\"The goal is not an implication, and you didn't specify an assumption\"")]))
                     [])])]))
               [])
              (Term.doSeqItem
               (Term.doLetArrow
                "let"
                []
                (Term.doIdDecl
                 `cp
                 []
                 "←"
                 (Term.doExpr
                  («term_<|>_»
                   (Term.app
                    `mk_mapp
                    [(Term.doubleQuotedName "`" "`" `imp_of_not_imp_not)
                     («term[_]» "[" [`P "," `Q] "]")])
                   "<|>"
                   (Term.app
                    `fail
                    [(str "\"contrapose only applies to nondependent arrows between props\"")])))))
               [])
              (Term.doSeqItem (Term.doExpr (Term.app `apply [`cp])) [])
              (Term.doSeqItem
               (Term.doExpr
                («term_<|_»
                 (Term.app `when [`push])
                 "<|"
                 (Term.app
                  `try
                  [(Term.app
                    `tactic.interactive.push_neg
                    [(Term.app `loc.ns [(«term[_]» "[" [`none] "]")])])])))
               [])])))])
        []))
      []
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValEqns', expected 'Lean.Parser.Command.declValSimple'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.do
       "do"
       (Term.doSeqIndent
        [(Term.doSeqItem
          (Term.doLetArrow
           "let"
           []
           (Term.doPatDecl
            (Qq.«termQ(__)»
             "q("
             (Term.arrow
              (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `P ")") [])
              "→"
              (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `Q ")") []))
             []
             ")")
            "←"
            (Term.doExpr `target)
            ["|"
             (Term.doSeqIndent
              [(Term.doSeqItem
                (Term.doExpr
                 (Term.app
                  `fail
                  [(str
                    "\"The goal is not an implication, and you didn't specify an assumption\"")]))
                [])])]))
          [])
         (Term.doSeqItem
          (Term.doLetArrow
           "let"
           []
           (Term.doIdDecl
            `cp
            []
            "←"
            (Term.doExpr
             («term_<|>_»
              (Term.app
               `mk_mapp
               [(Term.doubleQuotedName "`" "`" `imp_of_not_imp_not)
                («term[_]» "[" [`P "," `Q] "]")])
              "<|>"
              (Term.app
               `fail
               [(str "\"contrapose only applies to nondependent arrows between props\"")])))))
          [])
         (Term.doSeqItem (Term.doExpr (Term.app `apply [`cp])) [])
         (Term.doSeqItem
          (Term.doExpr
           («term_<|_»
            (Term.app `when [`push])
            "<|"
            (Term.app
             `try
             [(Term.app
               `tactic.interactive.push_neg
               [(Term.app `loc.ns [(«term[_]» "[" [`none] "]")])])])))
          [])]))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.doSeqIndent', expected 'Lean.Parser.Term.doSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_<|_»
       (Term.app `when [`push])
       "<|"
       (Term.app
        `try
        [(Term.app
          `tactic.interactive.push_neg
          [(Term.app `loc.ns [(«term[_]» "[" [`none] "]")])])]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `try
       [(Term.app `tactic.interactive.push_neg [(Term.app `loc.ns [(«term[_]» "[" [`none] "]")])])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `tactic.interactive.push_neg [(Term.app `loc.ns [(«term[_]» "[" [`none] "]")])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `loc.ns [(«term[_]» "[" [`none] "]")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term[_]»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term[_]»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term[_]» "[" [`none] "]")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `none
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `loc.ns
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `loc.ns [(«term[_]» "[" [`none] "]")])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `tactic.interactive.push_neg
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app
      `tactic.interactive.push_neg
      [(Term.paren "(" (Term.app `loc.ns [(«term[_]» "[" [`none] "]")]) ")")])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `try
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 10 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 10, term))
      (Term.app `when [`push])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `push
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `when
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 10, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 10, (some 10, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, doElem))
      (Term.app `apply [`cp])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `cp
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `apply
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1023, doElem)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, doElem))
      («term_<|>_»
       (Term.app
        `mk_mapp
        [(Term.doubleQuotedName "`" "`" `imp_of_not_imp_not) («term[_]» "[" [`P "," `Q] "]")])
       "<|>"
       (Term.app `fail [(str "\"contrapose only applies to nondependent arrows between props\"")]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `fail [(str "\"contrapose only applies to nondependent arrows between props\"")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'str', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'str', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (str "\"contrapose only applies to nondependent arrows between props\"")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `fail
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 20 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 20, term))
      (Term.app
       `mk_mapp
       [(Term.doubleQuotedName "`" "`" `imp_of_not_imp_not) («term[_]» "[" [`P "," `Q] "]")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term[_]»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term[_]»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term[_]» "[" [`P "," `Q] "]")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Q
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `P
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.doubleQuotedName', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.doubleQuotedName', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      (Term.doubleQuotedName "`" "`" `imp_of_not_imp_not)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `mk_mapp
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 21 >? 1022, (some 1023, term) <=? (some 20, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 20, (some 20, term) <=? (none, doElem)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.doPatDecl', expected 'Lean.Parser.Term.doIdDecl'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.doSeqIndent', expected 'Lean.Parser.Term.doSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, doElem))
      (Term.app
       `fail
       [(str "\"The goal is not an implication, and you didn't specify an assumption\"")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'str', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'str', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (str "\"The goal is not an implication, and you didn't specify an assumption\"")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `fail
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, doElem)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `target
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Qq.«termQ(__)»
       "q("
       (Term.arrow
        (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `P ")") [])
        "→"
        (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `Q ")") []))
       []
       ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.arrow
       (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `P ")") [])
       "→"
       (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `Q ")") []))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `Q ")") [])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'null', expected 'antiquotName'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'antiquotNestedExpr', expected 'ident'
[PrettyPrinter.parenthesize] ...precedences are 25 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 25, term))
      (term.pseudo.antiquot "$" [] (antiquotNestedExpr "(" `P ")") [])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'null', expected 'antiquotName'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'antiquotNestedExpr', expected 'ident'
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 25, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 25, (some 25, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1023, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `none
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_>>_»
       («term_>>_»
        («term_>>_»
         («term_>>=_» (Term.app `get_local [`h]) ">>=" `revert)
         ">>"
         (Term.app `tactic.interactive.contrapose [`none]))
        ">>"
        (Term.app `intro [(Term.app (Term.proj `h' "." `getOrElse) [`h])]))
       ">>"
       `skip)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `skip
[PrettyPrinter.parenthesize] ...precedences are 60 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 60, term))
      («term_>>_»
       («term_>>_»
        («term_>>=_» (Term.app `get_local [`h]) ">>=" `revert)
        ">>"
        (Term.app `tactic.interactive.contrapose [`none]))
       ">>"
       (Term.app `intro [(Term.app (Term.proj `h' "." `getOrElse) [`h])]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `intro [(Term.app (Term.proj `h' "." `getOrElse) [`h])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app (Term.proj `h' "." `getOrElse) [`h])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `h' "." `getOrElse)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h'
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app (Term.proj `h' "." `getOrElse) [`h])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `intro
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 60 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 60, term))
      («term_>>_»
       («term_>>=_» (Term.app `get_local [`h]) ">>=" `revert)
       ">>"
       (Term.app `tactic.interactive.contrapose [`none]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `tactic.interactive.contrapose [`none])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `none
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `tactic.interactive.contrapose
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 60 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 60, term))
      («term_>>=_» (Term.app `get_local [`h]) ">>=" `revert)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `revert
[PrettyPrinter.parenthesize] ...precedences are 56 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 55, term))
      (Term.app `get_local [`h])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `get_local
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 55 >? 1022, (some 1023, term) <=? (some 55, term)
[PrettyPrinter.parenthesize] ...precedences are 61 >? 55, (some 56, term) <=? (some 60, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     («term_>>=_» (Term.app `get_local [`h]) ">>=" `revert)
     ")")
[PrettyPrinter.parenthesize] ...precedences are 61 >? 60, (some 60, term) <=? (some 60, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     («term_>>_»
      (Term.paren "(" («term_>>=_» (Term.app `get_local [`h]) ">>=" `revert) ")")
      ">>"
      (Term.app `tactic.interactive.contrapose [`none]))
     ")")
[PrettyPrinter.parenthesize] ...precedences are 61 >? 60, (some 60, term) <=? (some 60, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     («term_>>_»
      (Term.paren
       "("
       («term_>>_»
        (Term.paren "(" («term_>>=_» (Term.app `get_local [`h]) ">>=" `revert) ")")
        ">>"
        (Term.app `tactic.interactive.contrapose [`none]))
       ")")
      ">>"
      (Term.app `intro [(Term.paren "(" (Term.app (Term.proj `h' "." `getOrElse) [`h]) ")")]))
     ")")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 60, (some 60,
     term) <=? (some 1023, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `some [(Term.tuple "(" [`h "," [`h']] ")")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.tuple', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.tuple', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.tuple "(" [`h "," [`h']] ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h'
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `some
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      (Term.arrow
       (Term.app `parse [(Tactic.PushNeg.parser.optional `name_with_opt "?")])
       "→"
       (Term.app `tactic [`Unit]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `tactic [`Unit])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Unit
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `tactic
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 25 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 25, term))
      (Term.app `parse [(Tactic.PushNeg.parser.optional `name_with_opt "?")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Tactic.PushNeg.parser.optional', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Tactic.PushNeg.parser.optional', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.PushNeg.parser.optional `name_with_opt "?")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Tactic.PushNeg.parser.optional', expected 'Tactic.PushNeg.parser.optional._@.Tactic.PushNeg._hyg.16'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.theorem'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.structure'-/-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      Transforms the goal into its contrapositive.
      
      * `contrapose`     turns a goal `P → Q` into `¬ Q → ¬ P`
      * `contrapose!`    turns a goal `P → Q` into `¬ Q → ¬ P` and pushes negations inside `P` and `Q`
        using `push_neg`
      * `contrapose h`   first reverts the local assumption `h`, and then uses `contrapose` and `intro h`
      * `contrapose! h`  first reverts the local assumption `h`, and then uses `contrapose!` and `intro h`
      * `contrapose h with new_h` uses the name `new_h` for the introduced hypothesis
      -/
    unsafe
  def
    tactic.interactive.contrapose
    ( push : parse tk "!" ? ) : parse name_with_opt ? → tactic Unit
    |
        some ( h , h' )
        =>
        get_local h >>= revert >> tactic.interactive.contrapose none >> intro h' . getOrElse h
          >>
          skip
      |
        none
        =>
        do
          let
              q( $ ( P ) → $ ( Q ) )
                ←
                target
                | fail "The goal is not an implication, and you didn't specify an assumption"
            let
              cp
                ←
                mk_mapp ` ` imp_of_not_imp_not [ P , Q ]
                  <|>
                  fail "contrapose only applies to nondependent arrows between props"
            apply cp
            when push <| try tactic.interactive.push_neg loc.ns [ none ]
#align tactic.interactive.contrapose tactic.interactive.contrapose

add_tactic_doc
  { Name := "contrapose"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.contrapose]
    tags := ["logic"] }

/-!
## `#push_neg` command
A user command to run `push_neg`. Mostly copied from the `#norm_num` and `#simp` commands.
-/


namespace Tactic

open Lean.Parser

open Interactive.Types

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- The syntax is `#push_neg e`, where `e` is an expression,
which will print the `push_neg` form of `e`.

`#push_neg` understands local variables, so you can use them to
introduce parameters.
-/
@[user_command]
unsafe def push_neg_cmd (_ : parse <| tk "#push_neg") : lean.parser Unit := do
  let e ← texpr
  let/- Synthesize a `tactic_state` including local variables as hypotheses under which
         `normalize_negations` may be safely called with expected behaviour given the `variables` in the
         environment. -/
    (ts, _)
    ← synthesize_tactic_state_with_variables_as_hyps [e]
  let result
    ←-- Enter the `tactic` monad, *critically* using the synthesized tactic state `ts`.
        lean.parser.of_tactic
        fun _ =>
        (/- Resolve the local variables added by the parser to `e` (when it was parsed) against the local
                 hypotheses added to the `ts : tactic_state` which we are using. -/
          do
            let e ← to_expr e
            let-- Run `push_neg` on the expression.
              (e_neg, _)
              ← normalize_negations e
            /- Run a `simp` to change any `¬ a = b` to `a ≠ b`; report the result, or, if the `simp` fails
                      (because no `¬ a = b` appear in the expression), return what `push_neg` gave. -/
                  Prod.fst <$>
                  e_neg { eta := ff } failed tt [] [simp_arg_type.expr ``(PushNeg.not_eq)] <|>
                pure e_neg)
          ts
  -- Trace the result.
      trace
      result
#align tactic.push_neg_cmd tactic.push_neg_cmd

add_tactic_doc
  { Name := "#push_neg"
    category := DocCategory.cmd
    declNames := [`tactic.push_neg_cmd]
    tags := ["logic"] }

end Tactic

