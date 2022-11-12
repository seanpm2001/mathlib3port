/-
Copyright (c) 2022 Junyan Xu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Junyan Xu
-/
import Mathbin.Data.Dfinsupp.Lex
import Mathbin.Order.GameAdd
import Mathbin.Order.Antisymmetrization
import Mathbin.SetTheory.Ordinal.Basic

/-!
# Well-foundedness of the lexicographic and product orders on `dfinsupp` and `pi`

The primary results are `dfinsupp.lex.well_founded` and the two variants that follow it,
which essentially say that if `(>)` is a well order on `ι`, `(<)` is well-founded on each
`α i`, and `0` is a bottom element in `α i`, then the lexicographic `(<)` is well-founded
on `Π₀ i, α i`. The proof is modelled on the proof of `well_founded.cut_expand`.

The results are used to prove `pi.lex.well_founded` and two variants, which say that if
`ι` is finite and equipped with a linear order and `(<)` is well-founded on each `α i`,
then the lexicographic `(<)` is well-founded on `Π i, α i`, and the same is true for
`Π₀ i, α i` (`dfinsupp.lex.well_founded_of_finite`), because `dfinsupp` is order-isomorphic
to `pi` when `ι` is finite.

Finally, we deduce `dfinsupp.well_founded_lt`, `pi.well_founded_lt`,
`dfinsupp.well_founded_lt_of_finite` and variants, which concern the product order
rather than the lexicographic one. An order on `ι` is not required in these results,
but we deduce them from the well-foundedness of the lexicographic order by choosing
a well order on `ι` so that the product order `(<)` becomes a subrelation
of the lexicographic `(<)`.

All results are provided in two forms whenever possible: a general form where the relations
can be arbitrary (not the `(<)` of a preorder, or not even transitive, etc.) and a specialized
form provided as `well_founded_lt` instances where the `(d)finsupp/pi` type (or their `lex`
type synonyms) carries a natural `(<)`.

Notice that the definition of `dfinsupp.lex` says that `x < y` according to `dfinsupp.lex r s`
iff there exists a coordinate `i : ι` such that `x i < y i` according to `s i`, and at all
`r`-smaller coordinates `j` (i.e. satisfying `r j i`), `x` remains unchanged relative to `y`;
in other words, coordinates `j` such that `¬ r j i` and `j ≠ i` are exactly where changes
can happen arbitrarily. This explains the appearance of `rᶜ ⊓ (≠)` in
`dfinsupp.acc_single` and `dfinsupp.well_founded`. When `r` is trichotomous (e.g. the `(<)`
of a linear order), `¬ r j i ∧ j ≠ i` implies `r i j`, so it suffices to require `r.swap`
to be well-founded.
-/


variable {ι : Type _} {α : ι → Type _}

namespace Dfinsupp

variable [hz : ∀ i, Zero (α i)] (r : ι → ι → Prop) (s : ∀ i, α i → α i → Prop)

include hz

open Relation Prod

/-- This key lemma says that if a finitely supported dependent function `x₀` is obtained by merging
  two such functions `x₁` and `x₂`, and if we evolve `x₀` down the `dfinsupp.lex` relation one
  step and get `x`, we can always evolve one of `x₁` and `x₂` down the `dfinsupp.lex` relation
  one step while keeping the other unchanged, and merge them back (possibly in a different way)
  to get back `x`. In other words, the two parts evolve essentially independently under
  `dfinsupp.lex`. This is used to show that a function `x` is accessible if
  `dfinsupp.single i (x i)` is accessible for each `i` in the (finite) support of `x`
  (`dfinsupp.lex.acc_of_single`). -/
theorem lex_fibration [∀ (i) (s : Set ι), Decidable (i ∈ s)] :
    Fibration (InvImage (GameAdd (Dfinsupp.Lex r s) (Dfinsupp.Lex r s)) snd) (Dfinsupp.Lex r s) fun x =>
      piecewise x.2.1 x.2.2 x.1 :=
  by
  rintro ⟨p, x₁, x₂⟩ x ⟨i, hr, hs⟩
  simp_rw [piecewise_apply] at hs hr
  split_ifs  at hs
  classical on_goal 1 => refine' ⟨⟨{ j | r j i → j ∈ p }, piecewise x₁ x { j | r j i }, x₂⟩, game_add.fst ⟨i, _⟩, _⟩
    pick_goal 3
    all_goals
    ext j
    simp_rw [piecewise_apply]
    split_ifs with h₁ h₂
    · rfl
      
    · rw [hr j h₁.1, if_pos h₁.2]
      
    · rfl
      
#align dfinsupp.lex_fibration Dfinsupp.lex_fibration

variable {r s}

theorem Lex.acc_of_single_erase [DecidableEq ι] {x : Π₀ i, α i} (i : ι) (hs : Acc (Dfinsupp.Lex r s) <| single i (x i))
    (hu : Acc (Dfinsupp.Lex r s) <| x.erase i) : Acc (Dfinsupp.Lex r s) x := by
  classical convert ←
      @Acc.of_fibration _ _ _ _ _ (lex_fibration r s) ⟨{i}, _⟩ (InvImage.accessible snd <| hs.prod_game_add hu)
#align dfinsupp.lex.acc_of_single_erase Dfinsupp.Lex.acc_of_single_erase

variable (hbot : ∀ ⦃i a⦄, ¬s i a 0)

include hbot

theorem Lex.acc_zero : Acc (Dfinsupp.Lex r s) 0 :=
  (Acc.intro 0) fun x ⟨_, _, h⟩ => (hbot h).elim
#align dfinsupp.lex.acc_zero Dfinsupp.Lex.acc_zero

theorem Lex.acc_of_single [DecidableEq ι] [∀ (i) (x : α i), Decidable (x ≠ 0)] (x : Π₀ i, α i) :
    (∀ i ∈ x.support, Acc (Dfinsupp.Lex r s) <| single i (x i)) → Acc (Dfinsupp.Lex r s) x := by
  generalize ht : x.support = t
  revert x
  classical induction' t using Finset.induction with b t hb ih
    refine' fun x ht h => lex.acc_of_single_erase b (h b <| t.mem_insert_self b) _
    rw [erase_ne (ha.ne_of_not_mem hb)]
#align dfinsupp.lex.acc_of_single Dfinsupp.Lex.acc_of_single

variable (hs : ∀ i, WellFounded (s i))

include hs

theorem Lex.acc_single [DecidableEq ι] {i : ι} (hi : Acc (rᶜ ⊓ (· ≠ ·)) i) : ∀ a, Acc (Dfinsupp.Lex r s) (single i a) :=
  by
  induction' hi with i hi ih
  refine' fun a => (hs i).induction a fun a ha => _
  refine' Acc.intro _ fun x => _
  rintro ⟨k, hr, hs⟩
  classical rw [single_apply] at hs
    swap
    subst hik
    obtain rfl | hij := eq_or_ne i j
    by_cases r j i
    · exact ih _ ⟨h, hij.symm⟩ _
      
#align dfinsupp.lex.acc_single Dfinsupp.Lex.acc_single

theorem Lex.acc [DecidableEq ι] [∀ (i) (x : α i), Decidable (x ≠ 0)] (x : Π₀ i, α i)
    (h : ∀ i ∈ x.support, Acc (rᶜ ⊓ (· ≠ ·)) i) : Acc (Dfinsupp.Lex r s) x :=
  (Lex.acc_of_single hbot x) fun i hi => Lex.acc_single hbot hs (h i hi) _
#align dfinsupp.lex.acc Dfinsupp.Lex.acc

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `Lex.well_founded [])
      (Command.declSig
       [(Term.explicitBinder
         "("
         [`hr]
         [":"
          («term_<|_»
           `WellFounded
           "<|"
           (Order.Basic.«term_⊓_»
            (Order.Basic.«term_ᶜ» `r "ᶜ")
            " ⊓ "
            (Term.paren "(" [(«term_≠_» (Term.cdot "·") "≠" (Term.cdot "·")) []] ")")))]
         []
         ")")]
       (Term.typeSpec ":" (Term.app `WellFounded [(Term.app `Dfinsupp.Lex [`r `s])])))
      (Command.declValSimple
       ":="
       (Term.anonymousCtor
        "⟨"
        [(Term.fun
          "fun"
          (Term.basicFun
           [`x]
           []
           "=>"
           (Term.byTactic
            "by"
            (Tactic.tacticSeq
             (Tactic.tacticSeq1Indented
              [(Tactic.«tactic_<;>_»
                (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
                "<;>"
                (Tactic.exact
                 "exact"
                 (Term.app
                  `lex.acc
                  [`hbot
                   `hs
                   `x
                   (Term.fun "fun" (Term.basicFun [`i (Term.hole "_")] [] "=>" (Term.app `hr.apply [`i])))])))])))))]
        "⟩")
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor
       "⟨"
       [(Term.fun
         "fun"
         (Term.basicFun
          [`x]
          []
          "=>"
          (Term.byTactic
           "by"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Tactic.«tactic_<;>_»
               (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
               "<;>"
               (Tactic.exact
                "exact"
                (Term.app
                 `lex.acc
                 [`hbot
                  `hs
                  `x
                  (Term.fun "fun" (Term.basicFun [`i (Term.hole "_")] [] "=>" (Term.app `hr.apply [`i])))])))])))))]
       "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`x]
        []
        "=>"
        (Term.byTactic
         "by"
         (Tactic.tacticSeq
          (Tactic.tacticSeq1Indented
           [(Tactic.«tactic_<;>_»
             (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
             "<;>"
             (Tactic.exact
              "exact"
              (Term.app
               `lex.acc
               [`hbot
                `hs
                `x
                (Term.fun "fun" (Term.basicFun [`i (Term.hole "_")] [] "=>" (Term.app `hr.apply [`i])))])))])))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.«tactic_<;>_»
           (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
           "<;>"
           (Tactic.exact
            "exact"
            (Term.app
             `lex.acc
             [`hbot
              `hs
              `x
              (Term.fun "fun" (Term.basicFun [`i (Term.hole "_")] [] "=>" (Term.app `hr.apply [`i])))])))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.«tactic_<;>_»
       (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
       "<;>"
       (Tactic.exact
        "exact"
        (Term.app
         `lex.acc
         [`hbot `hs `x (Term.fun "fun" (Term.basicFun [`i (Term.hole "_")] [] "=>" (Term.app `hr.apply [`i])))])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.app
        `lex.acc
        [`hbot `hs `x (Term.fun "fun" (Term.basicFun [`i (Term.hole "_")] [] "=>" (Term.app `hr.apply [`i])))]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `lex.acc
       [`hbot `hs `x (Term.fun "fun" (Term.basicFun [`i (Term.hole "_")] [] "=>" (Term.app `hr.apply [`i])))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun "fun" (Term.basicFun [`i (Term.hole "_")] [] "=>" (Term.app `hr.apply [`i])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `hr.apply [`i])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `hr.apply
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      `x
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `hs
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `hbot
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `lex.acc
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1, tactic))
      (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.skip', expected 'Lean.Parser.Tactic.tacticSeq'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.basicFun', expected 'Lean.Parser.Term.matchAlts'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  Lex.well_founded
  ( hr : WellFounded <| r ᶜ ⊓ ( · ≠ · ) ) : WellFounded Dfinsupp.Lex r s
  := ⟨ fun x => by skip <;> exact lex.acc hbot hs x fun i _ => hr.apply i ⟩
#align dfinsupp.lex.well_founded Dfinsupp.Lex.well_founded

theorem Lex.well_founded' [IsTrichotomous ι r] (hr : WellFounded r.swap) : WellFounded (Dfinsupp.Lex r s) :=
  Lex.well_founded hbot hs <|
    Subrelation.wf (fun i j h => ((@IsTrichotomous.trichotomous ι r _ i j).resolve_left h.1).resolve_left h.2) hr
#align dfinsupp.lex.well_founded' Dfinsupp.Lex.well_founded'

omit hz hbot hs

instance Lex.well_founded_lt [LT ι] [IsTrichotomous ι (· < ·)] [hι : WellFoundedGt ι]
    [∀ i, CanonicallyOrderedAddMonoid (α i)] [hα : ∀ i, WellFoundedLt (α i)] : WellFoundedLt (Lex (Π₀ i, α i)) :=
  ⟨Lex.well_founded' (fun i a => (zero_le a).not_lt) (fun i => (hα i).wf) hι.wf⟩
#align dfinsupp.lex.well_founded_lt Dfinsupp.Lex.well_founded_lt

end Dfinsupp

open Dfinsupp

variable (r : ι → ι → Prop) {s : ∀ i, α i → α i → Prop}

theorem Pi.Lex.well_founded [IsStrictTotalOrder ι r] [Finite ι] (hs : ∀ i, WellFounded (s i)) :
    WellFounded (Pi.Lex r s) := by
  obtain h | ⟨⟨x⟩⟩ := isEmpty_or_nonempty (∀ i, α i)
  · convert empty_wf
    ext1 x
    exact (h.1 x).elim
    
  letI : ∀ i, Zero (α i) := fun i => ⟨(hs i).min ⊤ ⟨x i, trivial⟩⟩
  haveI := IsTrans.swap r
  haveI := IsIrrefl.swap r
  haveI := Fintype.ofFinite ι
  refine' InvImage.wf equiv_fun_on_fintype.symm (lex.well_founded' (fun i a => _) hs _)
  exacts[(hs i).not_lt_min ⊤ _ trivial, Finite.well_founded_of_trans_of_irrefl r.swap]
#align pi.lex.well_founded Pi.Lex.well_founded

instance Pi.Lex.well_founded_lt [LinearOrder ι] [Finite ι] [∀ i, LT (α i)] [hwf : ∀ i, WellFoundedLt (α i)] :
    WellFoundedLt (Lex (∀ i, α i)) :=
  ⟨Pi.Lex.well_founded (· < ·) fun i => (hwf i).1⟩
#align pi.lex.well_founded_lt Pi.Lex.well_founded_lt

instance Function.Lex.well_founded_lt {α} [LinearOrder ι] [Finite ι] [LT α] [WellFoundedLt α] :
    WellFoundedLt (Lex (ι → α)) :=
  Pi.Lex.well_founded_lt
#align function.lex.well_founded_lt Function.Lex.well_founded_lt

theorem Dfinsupp.Lex.well_founded_of_finite [IsStrictTotalOrder ι r] [Finite ι] [∀ i, Zero (α i)]
    (hs : ∀ i, WellFounded (s i)) : WellFounded (Dfinsupp.Lex r s) :=
  have := Fintype.ofFinite ι
  InvImage.wf equiv_fun_on_fintype (Pi.Lex.well_founded r hs)
#align dfinsupp.lex.well_founded_of_finite Dfinsupp.Lex.well_founded_of_finite

instance Dfinsupp.Lex.well_founded_lt_of_finite [LinearOrder ι] [Finite ι] [∀ i, Zero (α i)] [∀ i, LT (α i)]
    [hwf : ∀ i, WellFoundedLt (α i)] : WellFoundedLt (Lex (Π₀ i, α i)) :=
  ⟨(Dfinsupp.Lex.well_founded_of_finite (· < ·)) fun i => (hwf i).1⟩
#align dfinsupp.lex.well_founded_lt_of_finite Dfinsupp.Lex.well_founded_lt_of_finite

protected theorem Dfinsupp.well_founded_lt [∀ i, Zero (α i)] [∀ i, Preorder (α i)] [∀ i, WellFoundedLt (α i)]
    (hbot : ∀ ⦃i⦄ ⦃a : α i⦄, ¬a < 0) : WellFoundedLt (Π₀ i, α i) :=
  ⟨by
    letI : ∀ i, Zero (Antisymmetrization (α i) (· ≤ ·)) := fun i => ⟨toAntisymmetrization (· ≤ ·) 0⟩
    let f := map_range (fun i => @toAntisymmetrization (α i) (· ≤ ·) _) fun i => rfl
    refine' Subrelation.wf (fun x y h => _) (InvImage.wf f <| lex.well_founded' _ (fun i => _) _)
    · exact well_ordering_rel.swap
      
    · exact fun i => (· < ·)
      
    · haveI := IsStrictOrder.swap (@WellOrderingRel ι)
      obtain ⟨i, he, hl⟩ := lex_lt_of_lt_of_preorder well_ordering_rel.swap h
      exact ⟨i, fun j hj => Quot.sound (he j hj), hl⟩
      
    · rintro i ⟨a⟩
      apply hbot
      
    exacts[IsWellFounded.wf, IsTrichotomous.swap _, IsWellFounded.wf]⟩
#align dfinsupp.well_founded_lt Dfinsupp.well_founded_lt

instance Dfinsupp.well_founded_lt' [∀ i, CanonicallyOrderedAddMonoid (α i)] [∀ i, WellFoundedLt (α i)] :
    WellFoundedLt (Π₀ i, α i) :=
  Dfinsupp.well_founded_lt fun i a => (zero_le a).not_lt
#align dfinsupp.well_founded_lt' Dfinsupp.well_founded_lt'

instance Pi.well_founded_lt [Finite ι] [∀ i, Preorder (α i)] [hw : ∀ i, WellFoundedLt (α i)] :
    WellFoundedLt (∀ i, α i) :=
  ⟨by
    obtain h | ⟨⟨x⟩⟩ := isEmpty_or_nonempty (∀ i, α i)
    · convert empty_wf
      ext1 x
      exact (h.1 x).elim
      
    letI : ∀ i, Zero (α i) := fun i => ⟨(hw i).wf.min ⊤ ⟨x i, trivial⟩⟩
    haveI := Fintype.ofFinite ι
    refine' InvImage.wf equiv_fun_on_fintype.symm (Dfinsupp.well_founded_lt fun i a => _).wf
    exact (hw i).wf.not_lt_min ⊤ _ trivial⟩
#align pi.well_founded_lt Pi.well_founded_lt

instance Function.well_founded_lt {α} [Finite ι] [Preorder α] [WellFoundedLt α] : WellFoundedLt (ι → α) :=
  Pi.well_founded_lt
#align function.well_founded_lt Function.well_founded_lt

instance Dfinsupp.well_founded_lt_of_finite [Finite ι] [∀ i, Zero (α i)] [∀ i, Preorder (α i)]
    [∀ i, WellFoundedLt (α i)] : WellFoundedLt (Π₀ i, α i) :=
  have := Fintype.ofFinite ι
  ⟨InvImage.wf equiv_fun_on_fintype pi.well_founded_lt.wf⟩
#align dfinsupp.well_founded_lt_of_finite Dfinsupp.well_founded_lt_of_finite

