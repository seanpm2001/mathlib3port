/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Joey van Langen, Casper Putz

! This file was ported from Lean 3 source module field_theory.finite.basic
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.FieldTheory.Separable
import Mathbin.FieldTheory.SplittingField
import Mathbin.RingTheory.IntegralDomain
import Mathbin.Tactic.ApplyFun

/-!
# Finite fields

This file contains basic results about finite fields.
Throughout most of this file, `K` denotes a finite field
and `q` is notation for the cardinality of `K`.

See `ring_theory.integral_domain` for the fact that the unit group of a finite field is a
cyclic group, as well as the fact that every finite integral domain is a field
(`fintype.field_of_domain`).

## Main results

1. `fintype.card_units`: The unit group of a finite field is has cardinality `q - 1`.
2. `sum_pow_units`: The sum of `x^i`, where `x` ranges over the units of `K`, is
   - `q-1` if `q-1 ∣ i`
   - `0`   otherwise
3. `finite_field.card`: The cardinality `q` is a power of the characteristic of `K`.
   See `card'` for a variant.

## Notation

Throughout most of this file, `K` denotes a finite field
and `q` is notation for the cardinality of `K`.

## Implementation notes

While `fintype Kˣ` can be inferred from `fintype K` in the presence of `decidable_eq K`,
in this file we take the `fintype Kˣ` argument directly to reduce the chance of typeclass
diamonds, as `fintype` carries data.

-/


variable {K : Type _} {R : Type _}

-- mathport name: exprq
local notation "q" => Fintype.card K

open Finset Function

open BigOperators Polynomial

namespace FiniteField

section Polynomial

variable [CommRing R] [IsDomain R]

open Polynomial

/-- The cardinality of a field is at most `n` times the cardinality of the image of a degree `n`
  polynomial -/
theorem card_image_polynomial_eval [DecidableEq R] [Fintype R] {p : R[X]} (hp : 0 < p.degree) :
    Fintype.card R ≤ natDegree p * (univ.image fun x => eval x p).card :=
  Finset.card_le_mul_card_image _ _ fun a _ =>
    calc
      _ = (p - c a).roots.toFinset.card :=
        congr_arg card (by simp [Finset.ext_iff, mem_roots_sub_C hp])
      _ ≤ (p - c a).roots.card := Multiset.to_finset_card_le _
      _ ≤ _ := card_roots_sub_C' hp
      
#align finite_field.card_image_polynomial_eval FiniteField.card_image_polynomial_eval

/-- If `f` and `g` are quadratic polynomials, then the `f.eval a + g.eval b = 0` has a solution. -/
theorem exists_root_sum_quadratic [Fintype R] {f g : R[X]} (hf2 : degree f = 2) (hg2 : degree g = 2)
    (hR : Fintype.card R % 2 = 1) : ∃ a b, f.eval a + g.eval b = 0 :=
  letI := Classical.decEq R
  suffices ¬Disjoint (univ.image fun x : R => eval x f) (univ.image fun x : R => eval x (-g))
    by
    simp only [disjoint_left, mem_image] at this
    push_neg  at this
    rcases this with ⟨x, ⟨a, _, ha⟩, ⟨b, _, hb⟩⟩
    exact ⟨a, b, by rw [ha, ← hb, eval_neg, neg_add_self]⟩
  fun hd : Disjoint _ _ =>
  lt_irrefl (2 * ((univ.image fun x : R => eval x f) ∪ univ.image fun x : R => eval x (-g)).card) <|
    calc
      2 * ((univ.image fun x : R => eval x f) ∪ univ.image fun x : R => eval x (-g)).card ≤
          2 * Fintype.card R :=
        Nat.mul_le_mul_left _ (Finset.card_le_univ _)
      _ = Fintype.card R + Fintype.card R := two_mul _
      _ <
          nat_degree f * (univ.image fun x : R => eval x f).card +
            nat_degree (-g) * (univ.image fun x : R => eval x (-g)).card :=
        add_lt_add_of_lt_of_le
          (lt_of_le_of_ne (card_image_polynomial_eval (by rw [hf2] <;> exact by decide))
            (mt (congr_arg (· % 2)) (by simp [nat_degree_eq_of_degree_eq_some hf2, hR])))
          (card_image_polynomial_eval (by rw [degree_neg, hg2] <;> exact by decide))
      _ = 2 * ((univ.image fun x : R => eval x f) ∪ univ.image fun x : R => eval x (-g)).card := by
        rw [card_disjoint_union hd] <;>
          simp [nat_degree_eq_of_degree_eq_some hf2, nat_degree_eq_of_degree_eq_some hg2, bit0,
            mul_add]
      
#align finite_field.exists_root_sum_quadratic FiniteField.exists_root_sum_quadratic

end Polynomial

theorem prod_univ_units_id_eq_neg_one [CommRing K] [IsDomain K] [Fintype Kˣ] :
    (∏ x : Kˣ, x) = (-1 : Kˣ) := by
  classical
    have : (∏ x in (@univ Kˣ _).erase (-1), x) = 1 :=
      prod_involution (fun x _ => x⁻¹) (by simp)
        (fun a => by simp (config := { contextual := true }) [Units.inv_eq_self_iff])
        (fun a => by simp [@inv_eq_iff_inv_eq _ _ a, eq_comm]) (by simp)
    rw [← insert_erase (mem_univ (-1 : Kˣ)), prod_insert (not_mem_erase _ _), this, mul_one]
#align finite_field.prod_univ_units_id_eq_neg_one FiniteField.prod_univ_units_id_eq_neg_one

section

variable [GroupWithZero K] [Fintype K]

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `pow_card_sub_one_eq_one [])
      (Command.declSig
       [(Term.explicitBinder "(" [`a] [":" `K] [] ")")
        (Term.explicitBinder "(" [`ha] [":" («term_≠_» `a "≠" (num "0"))] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         («term_^_» `a "^" («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")))
         "="
         (num "1"))))
      (Command.declValSimple
       ":="
       (calc
        "calc"
        (calcStep
         («term_=_»
          («term_^_» `a "^" («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1")))
          "="
          (Term.typeAscription
           "("
           («term_^_»
            (Term.app `Units.mk0 [`a `ha])
            "^"
            («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1")))
           ":"
           [(Algebra.Group.Units.«term_ˣ» `K "ˣ")]
           ")"))
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Tactic.rwSeq
              "rw"
              []
              (Tactic.rwRuleSeq
               "["
               [(Tactic.rwRule [] `Units.val_pow_eq_pow_val) "," (Tactic.rwRule [] `Units.val_mk0)]
               "]")
              [])]))))
        [(calcStep
          («term_=_» (Term.hole "_") "=" (num "1"))
          ":="
          (Term.byTactic
           "by"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Mathlib.Tactic.tacticClassical_
               "classical"
               (Tactic.tacticSeq
                (Tactic.tacticSeq1Indented
                 [(Tactic.rwSeq
                   "rw"
                   []
                   (Tactic.rwRuleSeq
                    "["
                    [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Fintype.card_units)
                     ","
                     (Tactic.rwRule [] `pow_card_eq_one)]
                    "]")
                   [])
                  []
                  (Tactic.tacticRfl "rfl")])))]))))])
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (calc
       "calc"
       (calcStep
        («term_=_»
         («term_^_» `a "^" («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1")))
         "="
         (Term.typeAscription
          "("
          («term_^_»
           (Term.app `Units.mk0 [`a `ha])
           "^"
           («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1")))
          ":"
          [(Algebra.Group.Units.«term_ˣ» `K "ˣ")]
          ")"))
        ":="
        (Term.byTactic
         "by"
         (Tactic.tacticSeq
          (Tactic.tacticSeq1Indented
           [(Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] `Units.val_pow_eq_pow_val) "," (Tactic.rwRule [] `Units.val_mk0)]
              "]")
             [])]))))
       [(calcStep
         («term_=_» (Term.hole "_") "=" (num "1"))
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Mathlib.Tactic.tacticClassical_
              "classical"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Tactic.rwSeq
                  "rw"
                  []
                  (Tactic.rwRuleSeq
                   "["
                   [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Fintype.card_units)
                    ","
                    (Tactic.rwRule [] `pow_card_eq_one)]
                   "]")
                  [])
                 []
                 (Tactic.tacticRfl "rfl")])))]))))])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Mathlib.Tactic.tacticClassical_
           "classical"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Tactic.rwSeq
               "rw"
               []
               (Tactic.rwRuleSeq
                "["
                [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Fintype.card_units)
                 ","
                 (Tactic.rwRule [] `pow_card_eq_one)]
                "]")
               [])
              []
              (Tactic.tacticRfl "rfl")])))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Mathlib.Tactic.tacticClassical_
       "classical"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Fintype.card_units)
             ","
             (Tactic.rwRule [] `pow_card_eq_one)]
            "]")
           [])
          []
          (Tactic.tacticRfl "rfl")])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticRfl "rfl")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Fintype.card_units)
         ","
         (Tactic.rwRule [] `pow_card_eq_one)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_card_eq_one
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Fintype.card_units
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_» (Term.hole "_") "=" (num "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "1")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none, [anonymous]) <=? (some 50, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 51, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, term))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] `Units.val_pow_eq_pow_val) "," (Tactic.rwRule [] `Units.val_mk0)]
            "]")
           [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] `Units.val_pow_eq_pow_val) "," (Tactic.rwRule [] `Units.val_mk0)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Units.val_mk0
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Units.val_pow_eq_pow_val
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_»
       («term_^_» `a "^" («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1")))
       "="
       (Term.typeAscription
        "("
        («term_^_»
         (Term.app `Units.mk0 [`a `ha])
         "^"
         («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1")))
        ":"
        [(Algebra.Group.Units.«term_ˣ» `K "ˣ")]
        ")"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.typeAscription
       "("
       («term_^_»
        (Term.app `Units.mk0 [`a `ha])
        "^"
        («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1")))
       ":"
       [(Algebra.Group.Units.«term_ˣ» `K "ˣ")]
       ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Algebra.Group.Units.«term_ˣ» `K "ˣ")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_^_»
       (Term.app `Units.mk0 [`a `ha])
       "^"
       («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "1")
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      (Term.app `Fintype.card [`K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Fintype.card
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 65 >? 1022, (some 1023, term) <=? (some 65, term)
[PrettyPrinter.parenthesize] ...precedences are 80 >? 65, (some 66, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1"))
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      (Term.app `Units.mk0 [`a `ha])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ha
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `a
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Units.mk0
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 81 >? 1022, (some 1023, term) <=? (some 80, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 80, (some 80, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      («term_^_» `a "^" («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "1")
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      (Term.app `Fintype.card [`K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Fintype.card
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 65 >? 1022, (some 1023, term) <=? (some 65, term)
[PrettyPrinter.parenthesize] ...precedences are 80 >? 65, (some 66, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     («term_-_» (Term.app `Fintype.card [`K]) "-" (num "1"))
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      `a
[PrettyPrinter.parenthesize] ...precedences are 81 >? 1024, (none, [anonymous]) <=? (some 80, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 80, (some 80, term) <=? (some 50, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 51, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_»
       («term_^_» `a "^" («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")))
       "="
       (num "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "1")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      («term_^_» `a "^" («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "1")
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  pow_card_sub_one_eq_one
  ( a : K ) ( ha : a ≠ 0 ) : a ^ q - 1 = 1
  :=
    calc
      a ^ Fintype.card K - 1 = ( Units.mk0 a ha ^ Fintype.card K - 1 : K ˣ )
        :=
        by rw [ Units.val_pow_eq_pow_val , Units.val_mk0 ]
      _ = 1 := by classical rw [ ← Fintype.card_units , pow_card_eq_one ] rfl
#align finite_field.pow_card_sub_one_eq_one FiniteField.pow_card_sub_one_eq_one

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `pow_card [])
      (Command.declSig
       [(Term.explicitBinder "(" [`a] [":" `K] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_» («term_^_» `a "^" (FieldTheory.Finite.Basic.termq "q")) "=" `a)))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.tacticHave_
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              [`hp []]
              [(Term.typeSpec ":" («term_<_» (num "0") "<" (Term.app `Fintype.card [`K])))]
              ":="
              (Term.app `lt_trans [`zero_lt_one `Fintype.one_lt_card]))))
           []
           (Classical.«tacticBy_cases_:_» "by_cases" [`h ":"] («term_=_» `a "=" (num "0")))
           ";"
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.rwSeq "rw" [] (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h)] "]") [])
             []
             (Tactic.apply "apply" (Term.app `zero_pow [`hp]))])
           []
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule
               [(patternIgnore (token.«← » "←"))]
               (Term.app `Nat.succ_pred_eq_of_pos [`hp]))
              ","
              (Tactic.rwRule [] `pow_succ)
              ","
              (Tactic.rwRule [] `Nat.pred_eq_sub_one)
              ","
              (Tactic.rwRule [] (Term.app `pow_card_sub_one_eq_one [`a `h]))
              ","
              (Tactic.rwRule [] `mul_one)]
             "]")
            [])])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.tacticHave_
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             [`hp []]
             [(Term.typeSpec ":" («term_<_» (num "0") "<" (Term.app `Fintype.card [`K])))]
             ":="
             (Term.app `lt_trans [`zero_lt_one `Fintype.one_lt_card]))))
          []
          (Classical.«tacticBy_cases_:_» "by_cases" [`h ":"] («term_=_» `a "=" (num "0")))
          ";"
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.rwSeq "rw" [] (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h)] "]") [])
            []
            (Tactic.apply "apply" (Term.app `zero_pow [`hp]))])
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule
              [(patternIgnore (token.«← » "←"))]
              (Term.app `Nat.succ_pred_eq_of_pos [`hp]))
             ","
             (Tactic.rwRule [] `pow_succ)
             ","
             (Tactic.rwRule [] `Nat.pred_eq_sub_one)
             ","
             (Tactic.rwRule [] (Term.app `pow_card_sub_one_eq_one [`a `h]))
             ","
             (Tactic.rwRule [] `mul_one)]
            "]")
           [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule
          [(patternIgnore (token.«← » "←"))]
          (Term.app `Nat.succ_pred_eq_of_pos [`hp]))
         ","
         (Tactic.rwRule [] `pow_succ)
         ","
         (Tactic.rwRule [] `Nat.pred_eq_sub_one)
         ","
         (Tactic.rwRule [] (Term.app `pow_card_sub_one_eq_one [`a `h]))
         ","
         (Tactic.rwRule [] `mul_one)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mul_one
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `pow_card_sub_one_eq_one [`a `h])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `a
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `pow_card_sub_one_eq_one
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Nat.pred_eq_sub_one
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_succ
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Nat.succ_pred_eq_of_pos [`hp])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hp
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Nat.succ_pred_eq_of_pos
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__
       (cdotTk (patternIgnore (token.«· » "·")))
       [(Tactic.rwSeq "rw" [] (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h)] "]") [])
        []
        (Tactic.apply "apply" (Term.app `zero_pow [`hp]))])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.apply "apply" (Term.app `zero_pow [`hp]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `zero_pow [`hp])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hp
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `zero_pow
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq "rw" [] (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h)] "]") [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Classical.«tacticBy_cases_:_» "by_cases" [`h ":"] («term_=_» `a "=" (num "0")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_» `a "=" (num "0"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "0")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      `a
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none, [anonymous]) <=? (some 50, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 51, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticHave_
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         [`hp []]
         [(Term.typeSpec ":" («term_<_» (num "0") "<" (Term.app `Fintype.card [`K])))]
         ":="
         (Term.app `lt_trans [`zero_lt_one `Fintype.one_lt_card]))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `lt_trans [`zero_lt_one `Fintype.one_lt_card])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Fintype.one_lt_card
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `zero_lt_one
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `lt_trans
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_<_» (num "0") "<" (Term.app `Fintype.card [`K]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Fintype.card [`K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Fintype.card
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (num "0")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none, [anonymous]) <=? (some 50, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 51, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_» («term_^_» `a "^" (FieldTheory.Finite.Basic.termq "q")) "=" `a)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `a
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      («term_^_» `a "^" (FieldTheory.Finite.Basic.termq "q"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  pow_card
  ( a : K ) : a ^ q = a
  :=
    by
      have hp : 0 < Fintype.card K := lt_trans zero_lt_one Fintype.one_lt_card
        by_cases h : a = 0
        ;
        · rw [ h ] apply zero_pow hp
        rw
          [
            ← Nat.succ_pred_eq_of_pos hp
              ,
              pow_succ
              ,
              Nat.pred_eq_sub_one
              ,
              pow_card_sub_one_eq_one a h
              ,
              mul_one
            ]
#align finite_field.pow_card FiniteField.pow_card

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `pow_card_pow [])
      (Command.declSig
       [(Term.explicitBinder "(" [`n] [":" (termℕ "ℕ")] [] ")")
        (Term.explicitBinder "(" [`a] [":" `K] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         («term_^_» `a "^" («term_^_» (FieldTheory.Finite.Basic.termq "q") "^" `n))
         "="
         `a)))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.induction'
            "induction'"
            [(Tactic.casesTarget [] `n)]
            []
            ["with" [(Lean.binderIdent `n) (Lean.binderIdent `ih)]]
            [])
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.simp "simp" [] [] [] [] [])])
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.simp
              "simp"
              []
              []
              []
              ["["
               [(Tactic.simpLemma [] [] `pow_succ)
                ","
                (Tactic.simpLemma [] [] `pow_mul)
                ","
                (Tactic.simpLemma [] [] `ih)
                ","
                (Tactic.simpLemma [] [] `pow_card)]
               "]"]
              [])])])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.induction'
           "induction'"
           [(Tactic.casesTarget [] `n)]
           []
           ["with" [(Lean.binderIdent `n) (Lean.binderIdent `ih)]]
           [])
          []
          (tactic__ (cdotTk (patternIgnore (token.«· » "·"))) [(Tactic.simp "simp" [] [] [] [] [])])
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.simp
             "simp"
             []
             []
             []
             ["["
              [(Tactic.simpLemma [] [] `pow_succ)
               ","
               (Tactic.simpLemma [] [] `pow_mul)
               ","
               (Tactic.simpLemma [] [] `ih)
               ","
               (Tactic.simpLemma [] [] `pow_card)]
              "]"]
             [])])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__
       (cdotTk (patternIgnore (token.«· » "·")))
       [(Tactic.simp
         "simp"
         []
         []
         []
         ["["
          [(Tactic.simpLemma [] [] `pow_succ)
           ","
           (Tactic.simpLemma [] [] `pow_mul)
           ","
           (Tactic.simpLemma [] [] `ih)
           ","
           (Tactic.simpLemma [] [] `pow_card)]
          "]"]
         [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.simp
       "simp"
       []
       []
       []
       ["["
        [(Tactic.simpLemma [] [] `pow_succ)
         ","
         (Tactic.simpLemma [] [] `pow_mul)
         ","
         (Tactic.simpLemma [] [] `ih)
         ","
         (Tactic.simpLemma [] [] `pow_card)]
        "]"]
       [])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_card
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ih
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_mul
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_succ
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__ (cdotTk (patternIgnore (token.«· » "·"))) [(Tactic.simp "simp" [] [] [] [] [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.simp "simp" [] [] [] [] [])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.induction'
       "induction'"
       [(Tactic.casesTarget [] `n)]
       []
       ["with" [(Lean.binderIdent `n) (Lean.binderIdent `ih)]]
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_» («term_^_» `a "^" («term_^_» (FieldTheory.Finite.Basic.termq "q") "^" `n)) "=" `a)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `a
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      («term_^_» `a "^" («term_^_» (FieldTheory.Finite.Basic.termq "q") "^" `n))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_^_» (FieldTheory.Finite.Basic.termq "q") "^" `n)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 80 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  pow_card_pow
  ( n : ℕ ) ( a : K ) : a ^ q ^ n = a
  := by induction' n with n ih · simp · simp [ pow_succ , pow_mul , ih , pow_card ]
#align finite_field.pow_card_pow FiniteField.pow_card_pow

end

variable (K) [Field K] [Fintype K]

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `card [])
      (Command.declSig
       [(Term.explicitBinder "(" [`p] [":" (termℕ "ℕ")] [] ")")
        (Term.instBinder "[" [] (Term.app `CharP [`K `p]) "]")]
       (Term.typeSpec
        ":"
        («term∃_,_»
         "∃"
         (Lean.explicitBinders
          (Lean.unbracketedExplicitBinders
           [(Lean.binderIdent `n)]
           [":" (Data.Pnat.Defs.«termℕ+» "ℕ+")]))
         ","
         («term_∧_»
          (Term.app `Nat.Prime [`p])
          "∧"
          («term_=_»
           (FieldTheory.Finite.Basic.termq "q")
           "="
           («term_^_» `p "^" (Term.typeAscription "(" `n ":" [(termℕ "ℕ")] ")")))))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Std.Tactic.tacticHaveI_
            "haveI"
            (Term.haveDecl
             (Term.haveIdDecl
              [`hp []]
              [(Term.typeSpec ":" (Term.app `Fact [`p.prime]))]
              ":="
              (Term.anonymousCtor "⟨" [(Term.app `CharP.char_is_prime [`K `p])] "⟩"))))
           []
           (Std.Tactic.tacticLetI_
            "letI"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec ":" (Term.app `Module [(Term.app `Zmod [`p]) `K]))]
              ":="
              (Term.structInst
               "{"
               [[(Term.proj
                  (Term.typeAscription
                   "("
                   (Term.app `Zmod.castHom [`dvd_rfl `K])
                   ":"
                   [(Algebra.Hom.Ring.«term_→+*_» (Term.app `Zmod [`p]) " →+* " (Term.hole "_"))]
                   ")")
                  "."
                  `toModule)]
                "with"]
               []
               (Term.optEllipsis [])
               []
               "}"))))
           []
           (Std.Tactic.obtain
            "obtain"
            [(Std.Tactic.RCases.rcasesPatMed
              [(Std.Tactic.RCases.rcasesPat.tuple
                "⟨"
                [(Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `n)])
                  [])
                 ","
                 (Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `h)])
                  [])]
                "⟩")])]
            []
            [":=" [(Term.app `VectorSpace.card_fintype [(Term.app `Zmod [`p]) `K])]])
           []
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `Zmod.card)] "]")
            [(Tactic.location "at" (Tactic.locationHyp [`h] []))])
           []
           (Tactic.refine'
            "refine'"
            (Term.anonymousCtor
             "⟨"
             [(Term.anonymousCtor "⟨" [`n "," (Term.hole "_")] "⟩")
              ","
              (Term.proj `hp "." (fieldIdx "1"))
              ","
              `h]
             "⟩"))
           []
           (Tactic.apply "apply" (Term.app `Or.resolve_left [(Term.app `Nat.eq_zero_or_pos [`n])]))
           []
           (Std.Tactic.rintro
            "rintro"
            [(Std.Tactic.RCases.rintroPat.one (Std.Tactic.RCases.rcasesPat.one `rfl))]
            [])
           []
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `pow_zero)] "]")
            [(Tactic.location "at" (Tactic.locationHyp [`h] []))])
           []
           (Tactic.tacticHave_
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec
                ":"
                («term_=_» (Term.typeAscription "(" (num "0") ":" [`K] ")") "=" (num "1")))]
              ":="
              (Term.byTactic
               "by"
               (Tactic.tacticSeq
                (Tactic.tacticSeq1Indented
                 [(Tactic.apply
                   "apply"
                   (Term.app `fintype.card_le_one_iff.mp [(Term.app `le_of_eq [`h])]))]))))))
           []
           (Tactic.exact "exact" (Term.app `absurd [`this `zero_ne_one]))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Std.Tactic.tacticHaveI_
           "haveI"
           (Term.haveDecl
            (Term.haveIdDecl
             [`hp []]
             [(Term.typeSpec ":" (Term.app `Fact [`p.prime]))]
             ":="
             (Term.anonymousCtor "⟨" [(Term.app `CharP.char_is_prime [`K `p])] "⟩"))))
          []
          (Std.Tactic.tacticLetI_
           "letI"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec ":" (Term.app `Module [(Term.app `Zmod [`p]) `K]))]
             ":="
             (Term.structInst
              "{"
              [[(Term.proj
                 (Term.typeAscription
                  "("
                  (Term.app `Zmod.castHom [`dvd_rfl `K])
                  ":"
                  [(Algebra.Hom.Ring.«term_→+*_» (Term.app `Zmod [`p]) " →+* " (Term.hole "_"))]
                  ")")
                 "."
                 `toModule)]
               "with"]
              []
              (Term.optEllipsis [])
              []
              "}"))))
          []
          (Std.Tactic.obtain
           "obtain"
           [(Std.Tactic.RCases.rcasesPatMed
             [(Std.Tactic.RCases.rcasesPat.tuple
               "⟨"
               [(Std.Tactic.RCases.rcasesPatLo
                 (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `n)])
                 [])
                ","
                (Std.Tactic.RCases.rcasesPatLo
                 (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `h)])
                 [])]
               "⟩")])]
           []
           [":=" [(Term.app `VectorSpace.card_fintype [(Term.app `Zmod [`p]) `K])]])
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `Zmod.card)] "]")
           [(Tactic.location "at" (Tactic.locationHyp [`h] []))])
          []
          (Tactic.refine'
           "refine'"
           (Term.anonymousCtor
            "⟨"
            [(Term.anonymousCtor "⟨" [`n "," (Term.hole "_")] "⟩")
             ","
             (Term.proj `hp "." (fieldIdx "1"))
             ","
             `h]
            "⟩"))
          []
          (Tactic.apply "apply" (Term.app `Or.resolve_left [(Term.app `Nat.eq_zero_or_pos [`n])]))
          []
          (Std.Tactic.rintro
           "rintro"
           [(Std.Tactic.RCases.rintroPat.one (Std.Tactic.RCases.rcasesPat.one `rfl))]
           [])
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `pow_zero)] "]")
           [(Tactic.location "at" (Tactic.locationHyp [`h] []))])
          []
          (Tactic.tacticHave_
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec
               ":"
               («term_=_» (Term.typeAscription "(" (num "0") ":" [`K] ")") "=" (num "1")))]
             ":="
             (Term.byTactic
              "by"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Tactic.apply
                  "apply"
                  (Term.app `fintype.card_le_one_iff.mp [(Term.app `le_of_eq [`h])]))]))))))
          []
          (Tactic.exact "exact" (Term.app `absurd [`this `zero_ne_one]))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact "exact" (Term.app `absurd [`this `zero_ne_one]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `absurd [`this `zero_ne_one])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `zero_ne_one
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `this
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `absurd
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticHave_
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec
           ":"
           («term_=_» (Term.typeAscription "(" (num "0") ":" [`K] ")") "=" (num "1")))]
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Tactic.apply
              "apply"
              (Term.app `fintype.card_le_one_iff.mp [(Term.app `le_of_eq [`h])]))]))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.apply
           "apply"
           (Term.app `fintype.card_le_one_iff.mp [(Term.app `le_of_eq [`h])]))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.apply "apply" (Term.app `fintype.card_le_one_iff.mp [(Term.app `le_of_eq [`h])]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `fintype.card_le_one_iff.mp [(Term.app `le_of_eq [`h])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `le_of_eq [`h])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `le_of_eq
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `le_of_eq [`h]) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `fintype.card_le_one_iff.mp
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_» (Term.typeAscription "(" (num "0") ":" [`K] ")") "=" (num "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "1")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Term.typeAscription "(" (num "0") ":" [`K] ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "0")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none, [anonymous]) <=? (some 50, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 51, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `pow_zero)] "]")
       [(Tactic.location "at" (Tactic.locationHyp [`h] []))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.locationHyp', expected 'Lean.Parser.Tactic.locationWildcard'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_zero
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.rintro
       "rintro"
       [(Std.Tactic.RCases.rintroPat.one (Std.Tactic.RCases.rcasesPat.one `rfl))]
       [])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.apply "apply" (Term.app `Or.resolve_left [(Term.app `Nat.eq_zero_or_pos [`n])]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Or.resolve_left [(Term.app `Nat.eq_zero_or_pos [`n])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Nat.eq_zero_or_pos [`n])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Nat.eq_zero_or_pos
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `Nat.eq_zero_or_pos [`n]) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Or.resolve_left
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.refine'
       "refine'"
       (Term.anonymousCtor
        "⟨"
        [(Term.anonymousCtor "⟨" [`n "," (Term.hole "_")] "⟩")
         ","
         (Term.proj `hp "." (fieldIdx "1"))
         ","
         `h]
        "⟩"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor
       "⟨"
       [(Term.anonymousCtor "⟨" [`n "," (Term.hole "_")] "⟩")
        ","
        (Term.proj `hp "." (fieldIdx "1"))
        ","
        `h]
       "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj `hp "." (fieldIdx "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `hp
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [`n "," (Term.hole "_")] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `Zmod.card)] "]")
       [(Tactic.location "at" (Tactic.locationHyp [`h] []))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.locationHyp', expected 'Lean.Parser.Tactic.locationWildcard'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Zmod.card
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.obtain
       "obtain"
       [(Std.Tactic.RCases.rcasesPatMed
         [(Std.Tactic.RCases.rcasesPat.tuple
           "⟨"
           [(Std.Tactic.RCases.rcasesPatLo
             (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `n)])
             [])
            ","
            (Std.Tactic.RCases.rcasesPatLo
             (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `h)])
             [])]
           "⟩")])]
       []
       [":=" [(Term.app `VectorSpace.card_fintype [(Term.app `Zmod [`p]) `K])]])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `VectorSpace.card_fintype [(Term.app `Zmod [`p]) `K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `Zmod [`p])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Zmod
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `Zmod [`p]) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `VectorSpace.card_fintype
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.tacticLetI_
       "letI"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec ":" (Term.app `Module [(Term.app `Zmod [`p]) `K]))]
         ":="
         (Term.structInst
          "{"
          [[(Term.proj
             (Term.typeAscription
              "("
              (Term.app `Zmod.castHom [`dvd_rfl `K])
              ":"
              [(Algebra.Hom.Ring.«term_→+*_» (Term.app `Zmod [`p]) " →+* " (Term.hole "_"))]
              ")")
             "."
             `toModule)]
           "with"]
          []
          (Term.optEllipsis [])
          []
          "}"))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.structInst
       "{"
       [[(Term.proj
          (Term.typeAscription
           "("
           (Term.app `Zmod.castHom [`dvd_rfl `K])
           ":"
           [(Algebra.Hom.Ring.«term_→+*_» (Term.app `Zmod [`p]) " →+* " (Term.hole "_"))]
           ")")
          "."
          `toModule)]
        "with"]
       []
       (Term.optEllipsis [])
       []
       "}")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj
       (Term.typeAscription
        "("
        (Term.app `Zmod.castHom [`dvd_rfl `K])
        ":"
        [(Algebra.Hom.Ring.«term_→+*_» (Term.app `Zmod [`p]) " →+* " (Term.hole "_"))]
        ")")
       "."
       `toModule)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.typeAscription
       "("
       (Term.app `Zmod.castHom [`dvd_rfl `K])
       ":"
       [(Algebra.Hom.Ring.«term_→+*_» (Term.app `Zmod [`p]) " →+* " (Term.hole "_"))]
       ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Algebra.Hom.Ring.«term_→+*_» (Term.app `Zmod [`p]) " →+* " (Term.hole "_"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 25 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 25, term))
      (Term.app `Zmod [`p])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Zmod
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 26 >? 1022, (some 1023, term) <=? (some 25, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 25, (some 25, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Zmod.castHom [`dvd_rfl `K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `dvd_rfl
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Zmod.castHom
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Module [(Term.app `Zmod [`p]) `K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `Zmod [`p])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Zmod
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `Zmod [`p]) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Module
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.tacticHaveI_
       "haveI"
       (Term.haveDecl
        (Term.haveIdDecl
         [`hp []]
         [(Term.typeSpec ":" (Term.app `Fact [`p.prime]))]
         ":="
         (Term.anonymousCtor "⟨" [(Term.app `CharP.char_is_prime [`K `p])] "⟩"))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [(Term.app `CharP.char_is_prime [`K `p])] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `CharP.char_is_prime [`K `p])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `CharP.char_is_prime
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Fact [`p.prime])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p.prime
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Fact
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term∃_,_»
       "∃"
       (Lean.explicitBinders
        (Lean.unbracketedExplicitBinders
         [(Lean.binderIdent `n)]
         [":" (Data.Pnat.Defs.«termℕ+» "ℕ+")]))
       ","
       («term_∧_»
        (Term.app `Nat.Prime [`p])
        "∧"
        («term_=_»
         (FieldTheory.Finite.Basic.termq "q")
         "="
         («term_^_» `p "^" (Term.typeAscription "(" `n ":" [(termℕ "ℕ")] ")")))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_∧_»
       (Term.app `Nat.Prime [`p])
       "∧"
       («term_=_»
        (FieldTheory.Finite.Basic.termq "q")
        "="
        («term_^_» `p "^" (Term.typeAscription "(" `n ":" [(termℕ "ℕ")] ")"))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_»
       (FieldTheory.Finite.Basic.termq "q")
       "="
       («term_^_» `p "^" (Term.typeAscription "(" `n ":" [(termℕ "ℕ")] ")")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_^_» `p "^" (Term.typeAscription "(" `n ":" [(termℕ "ℕ")] ")"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.typeAscription "(" `n ":" [(termℕ "ℕ")] ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (termℕ "ℕ")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 80 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      `p
[PrettyPrinter.parenthesize] ...precedences are 81 >? 1024, (none, [anonymous]) <=? (some 80, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 80, (some 80, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  card
  ( p : ℕ ) [ CharP K p ] : ∃ n : ℕ+ , Nat.Prime p ∧ q = p ^ ( n : ℕ )
  :=
    by
      haveI hp : Fact p.prime := ⟨ CharP.char_is_prime K p ⟩
        letI : Module Zmod p K := { ( Zmod.castHom dvd_rfl K : Zmod p →+* _ ) . toModule with }
        obtain ⟨ n , h ⟩ := VectorSpace.card_fintype Zmod p K
        rw [ Zmod.card ] at h
        refine' ⟨ ⟨ n , _ ⟩ , hp . 1 , h ⟩
        apply Or.resolve_left Nat.eq_zero_or_pos n
        rintro rfl
        rw [ pow_zero ] at h
        have : ( 0 : K ) = 1 := by apply fintype.card_le_one_iff.mp le_of_eq h
        exact absurd this zero_ne_one
#align finite_field.card FiniteField.card

-- this statement doesn't use `q` because we want `K` to be an explicit parameter
theorem card' : ∃ (p : ℕ)(n : ℕ+), Nat.Prime p ∧ Fintype.card K = p ^ (n : ℕ) :=
  let ⟨p, hc⟩ := CharP.exists K
  ⟨p, @FiniteField.card K _ _ p hc⟩
#align finite_field.card' FiniteField.card'

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      []
      [(Term.attributes "@[" [(Term.attrInstance (Term.attrKind []) (Attr.simp "simp" [] []))] "]")]
      []
      []
      []
      [])
     (Command.theorem
      "theorem"
      (Command.declId `cast_card_eq_zero [])
      (Command.declSig
       []
       (Term.typeSpec
        ":"
        («term_=_»
         (Term.typeAscription "(" (FieldTheory.Finite.Basic.termq "q") ":" [`K] ")")
         "="
         (num "0"))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Std.Tactic.rcases
            "rcases"
            [(Tactic.casesTarget [] (Term.app `CharP.exists [`K]))]
            ["with"
             (Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed
               [(Std.Tactic.RCases.rcasesPat.tuple
                 "⟨"
                 [(Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `p)])
                   [])
                  ","
                  (Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `_char_p)])
                   [])]
                 "⟩")])
              [])])
           ";"
           (Tactic.skip "skip")
           []
           (Std.Tactic.rcases
            "rcases"
            [(Tactic.casesTarget [] (Term.app `card [`K `p]))]
            ["with"
             (Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed
               [(Std.Tactic.RCases.rcasesPat.tuple
                 "⟨"
                 [(Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `n)])
                   [])
                  ","
                  (Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hp)])
                   [])
                  ","
                  (Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hn)])
                   [])]
                 "⟩")])
              [])])
           []
           (Tactic.simp
            "simp"
            []
            []
            ["only"]
            ["["
             [(Tactic.simpLemma [] [] (Term.app `CharP.cast_eq_zero_iff [`K `p]))
              ","
              (Tactic.simpLemma [] [] `hn)]
             "]"]
            [])
           []
           (Tactic.Conv.conv
            "conv"
            []
            []
            "=>"
            (Tactic.Conv.convSeq
             (Tactic.Conv.convSeq1Indented
              [(Tactic.Conv.congr "congr")
               []
               (Tactic.Conv.convRw__
                "rw"
                []
                (Tactic.rwRuleSeq
                 "["
                 [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `pow_one [`p]))]
                 "]"))])))
           []
           (Tactic.exact
            "exact"
            (Term.app `pow_dvd_pow [(Term.hole "_") (Term.proj `n "." (fieldIdx "2"))]))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Std.Tactic.rcases
           "rcases"
           [(Tactic.casesTarget [] (Term.app `CharP.exists [`K]))]
           ["with"
            (Std.Tactic.RCases.rcasesPatLo
             (Std.Tactic.RCases.rcasesPatMed
              [(Std.Tactic.RCases.rcasesPat.tuple
                "⟨"
                [(Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `p)])
                  [])
                 ","
                 (Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `_char_p)])
                  [])]
                "⟩")])
             [])])
          ";"
          (Tactic.skip "skip")
          []
          (Std.Tactic.rcases
           "rcases"
           [(Tactic.casesTarget [] (Term.app `card [`K `p]))]
           ["with"
            (Std.Tactic.RCases.rcasesPatLo
             (Std.Tactic.RCases.rcasesPatMed
              [(Std.Tactic.RCases.rcasesPat.tuple
                "⟨"
                [(Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `n)])
                  [])
                 ","
                 (Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hp)])
                  [])
                 ","
                 (Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hn)])
                  [])]
                "⟩")])
             [])])
          []
          (Tactic.simp
           "simp"
           []
           []
           ["only"]
           ["["
            [(Tactic.simpLemma [] [] (Term.app `CharP.cast_eq_zero_iff [`K `p]))
             ","
             (Tactic.simpLemma [] [] `hn)]
            "]"]
           [])
          []
          (Tactic.Conv.conv
           "conv"
           []
           []
           "=>"
           (Tactic.Conv.convSeq
            (Tactic.Conv.convSeq1Indented
             [(Tactic.Conv.congr "congr")
              []
              (Tactic.Conv.convRw__
               "rw"
               []
               (Tactic.rwRuleSeq
                "["
                [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `pow_one [`p]))]
                "]"))])))
          []
          (Tactic.exact
           "exact"
           (Term.app `pow_dvd_pow [(Term.hole "_") (Term.proj `n "." (fieldIdx "2"))]))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.app `pow_dvd_pow [(Term.hole "_") (Term.proj `n "." (fieldIdx "2"))]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `pow_dvd_pow [(Term.hole "_") (Term.proj `n "." (fieldIdx "2"))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.proj', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.proj', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj `n "." (fieldIdx "2"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `n
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `pow_dvd_pow
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.Conv.conv
       "conv"
       []
       []
       "=>"
       (Tactic.Conv.convSeq
        (Tactic.Conv.convSeq1Indented
         [(Tactic.Conv.congr "congr")
          []
          (Tactic.Conv.convRw__
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `pow_one [`p]))]
            "]"))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.Conv.convSeq1Indented', expected 'Lean.Parser.Tactic.Conv.convSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `pow_one [`p])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `pow_one
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.simp
       "simp"
       []
       []
       ["only"]
       ["["
        [(Tactic.simpLemma [] [] (Term.app `CharP.cast_eq_zero_iff [`K `p]))
         ","
         (Tactic.simpLemma [] [] `hn)]
        "]"]
       [])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hn
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `CharP.cast_eq_zero_iff [`K `p])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `CharP.cast_eq_zero_iff
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.rcases
       "rcases"
       [(Tactic.casesTarget [] (Term.app `card [`K `p]))]
       ["with"
        (Std.Tactic.RCases.rcasesPatLo
         (Std.Tactic.RCases.rcasesPatMed
          [(Std.Tactic.RCases.rcasesPat.tuple
            "⟨"
            [(Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `n)])
              [])
             ","
             (Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hp)])
              [])
             ","
             (Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hn)])
              [])]
            "⟩")])
         [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `card [`K `p])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `card
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.skip "skip")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.rcases
       "rcases"
       [(Tactic.casesTarget [] (Term.app `CharP.exists [`K]))]
       ["with"
        (Std.Tactic.RCases.rcasesPatLo
         (Std.Tactic.RCases.rcasesPatMed
          [(Std.Tactic.RCases.rcasesPat.tuple
            "⟨"
            [(Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `p)])
              [])
             ","
             (Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `_char_p)])
              [])]
            "⟩")])
         [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `CharP.exists [`K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `CharP.exists
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_»
       (Term.typeAscription "(" (FieldTheory.Finite.Basic.termq "q") ":" [`K] ")")
       "="
       (num "0"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "0")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Term.typeAscription "(" (FieldTheory.Finite.Basic.termq "q") ":" [`K] ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
@[ simp ]
  theorem
    cast_card_eq_zero
    : ( q : K ) = 0
    :=
      by
        rcases CharP.exists K with ⟨ p , _char_p ⟩
          ;
          skip
          rcases card K p with ⟨ n , hp , hn ⟩
          simp only [ CharP.cast_eq_zero_iff K p , hn ]
          conv => congr rw [ ← pow_one p ]
          exact pow_dvd_pow _ n . 2
#align finite_field.cast_card_eq_zero FiniteField.cast_card_eq_zero

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `forall_pow_eq_one_iff [])
      (Command.declSig
       [(Term.explicitBinder "(" [`i] [":" (termℕ "ℕ")] [] ")")]
       (Term.typeSpec
        ":"
        («term_↔_»
         (Term.forall
          "∀"
          [`x]
          [(Term.typeSpec ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]
          ","
          («term_=_» («term_^_» `x "^" `i) "=" (num "1")))
         "↔"
         («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Mathlib.Tactic.tacticClassical_
            "classical"
            (Tactic.tacticSeq
             (Tactic.tacticSeq1Indented
              [(Std.Tactic.obtain
                "obtain"
                [(Std.Tactic.RCases.rcasesPatMed
                  [(Std.Tactic.RCases.rcasesPat.tuple
                    "⟨"
                    [(Std.Tactic.RCases.rcasesPatLo
                      (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `x)])
                      [])
                     ","
                     (Std.Tactic.RCases.rcasesPatLo
                      (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hx)])
                      [])]
                    "⟩")])]
                []
                [":="
                 [(Term.app `IsCyclic.exists_generator [(Algebra.Group.Units.«term_ˣ» `K "ˣ")])]])
               []
               (Tactic.rwSeq
                "rw"
                []
                (Tactic.rwRuleSeq
                 "["
                 [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Fintype.card_units)
                  ","
                  (Tactic.rwRule
                   [(patternIgnore (token.«← » "←"))]
                   (Term.app `order_of_eq_card_of_forall_mem_zpowers [`hx]))
                  ","
                  (Tactic.rwRule [] `order_of_dvd_iff_pow_eq_one)]
                 "]")
                [])
               []
               (Tactic.constructor "constructor")
               []
               (tactic__
                (cdotTk (patternIgnore (token.«· » "·")))
                [(Tactic.intro "intro" [`h]) [] (Tactic.apply "apply" `h)])
               []
               (tactic__
                (cdotTk (patternIgnore (token.«· » "·")))
                [(Tactic.intro "intro" [`h `y])
                 []
                 (Mathlib.Tactic.tacticSimp_rw__
                  "simp_rw"
                  (Tactic.rwRuleSeq
                   "["
                   [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `mem_powers_iff_mem_zpowers)]
                   "]")
                  [(Tactic.location "at" (Tactic.locationHyp [`hx] []))])
                 []
                 (Std.Tactic.rcases
                  "rcases"
                  [(Tactic.casesTarget [] (Term.app `hx [`y]))]
                  ["with"
                   (Std.Tactic.RCases.rcasesPatLo
                    (Std.Tactic.RCases.rcasesPatMed
                     [(Std.Tactic.RCases.rcasesPat.tuple
                       "⟨"
                       [(Std.Tactic.RCases.rcasesPatLo
                         (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `j)])
                         [])
                        ","
                        (Std.Tactic.RCases.rcasesPatLo
                         (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `rfl)])
                         [])]
                       "⟩")])
                    [])])
                 []
                 (Tactic.rwSeq
                  "rw"
                  []
                  (Tactic.rwRuleSeq
                   "["
                   [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `pow_mul)
                    ","
                    (Tactic.rwRule [] `mul_comm)
                    ","
                    (Tactic.rwRule [] `pow_mul)
                    ","
                    (Tactic.rwRule [] `h)
                    ","
                    (Tactic.rwRule [] `one_pow)]
                   "]")
                  [])])])))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Mathlib.Tactic.tacticClassical_
           "classical"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Std.Tactic.obtain
               "obtain"
               [(Std.Tactic.RCases.rcasesPatMed
                 [(Std.Tactic.RCases.rcasesPat.tuple
                   "⟨"
                   [(Std.Tactic.RCases.rcasesPatLo
                     (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `x)])
                     [])
                    ","
                    (Std.Tactic.RCases.rcasesPatLo
                     (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hx)])
                     [])]
                   "⟩")])]
               []
               [":="
                [(Term.app `IsCyclic.exists_generator [(Algebra.Group.Units.«term_ˣ» `K "ˣ")])]])
              []
              (Tactic.rwSeq
               "rw"
               []
               (Tactic.rwRuleSeq
                "["
                [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Fintype.card_units)
                 ","
                 (Tactic.rwRule
                  [(patternIgnore (token.«← » "←"))]
                  (Term.app `order_of_eq_card_of_forall_mem_zpowers [`hx]))
                 ","
                 (Tactic.rwRule [] `order_of_dvd_iff_pow_eq_one)]
                "]")
               [])
              []
              (Tactic.constructor "constructor")
              []
              (tactic__
               (cdotTk (patternIgnore (token.«· » "·")))
               [(Tactic.intro "intro" [`h]) [] (Tactic.apply "apply" `h)])
              []
              (tactic__
               (cdotTk (patternIgnore (token.«· » "·")))
               [(Tactic.intro "intro" [`h `y])
                []
                (Mathlib.Tactic.tacticSimp_rw__
                 "simp_rw"
                 (Tactic.rwRuleSeq
                  "["
                  [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `mem_powers_iff_mem_zpowers)]
                  "]")
                 [(Tactic.location "at" (Tactic.locationHyp [`hx] []))])
                []
                (Std.Tactic.rcases
                 "rcases"
                 [(Tactic.casesTarget [] (Term.app `hx [`y]))]
                 ["with"
                  (Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed
                    [(Std.Tactic.RCases.rcasesPat.tuple
                      "⟨"
                      [(Std.Tactic.RCases.rcasesPatLo
                        (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `j)])
                        [])
                       ","
                       (Std.Tactic.RCases.rcasesPatLo
                        (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `rfl)])
                        [])]
                      "⟩")])
                   [])])
                []
                (Tactic.rwSeq
                 "rw"
                 []
                 (Tactic.rwRuleSeq
                  "["
                  [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `pow_mul)
                   ","
                   (Tactic.rwRule [] `mul_comm)
                   ","
                   (Tactic.rwRule [] `pow_mul)
                   ","
                   (Tactic.rwRule [] `h)
                   ","
                   (Tactic.rwRule [] `one_pow)]
                  "]")
                 [])])])))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Mathlib.Tactic.tacticClassical_
       "classical"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Std.Tactic.obtain
           "obtain"
           [(Std.Tactic.RCases.rcasesPatMed
             [(Std.Tactic.RCases.rcasesPat.tuple
               "⟨"
               [(Std.Tactic.RCases.rcasesPatLo
                 (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `x)])
                 [])
                ","
                (Std.Tactic.RCases.rcasesPatLo
                 (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hx)])
                 [])]
               "⟩")])]
           []
           [":=" [(Term.app `IsCyclic.exists_generator [(Algebra.Group.Units.«term_ˣ» `K "ˣ")])]])
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Fintype.card_units)
             ","
             (Tactic.rwRule
              [(patternIgnore (token.«← » "←"))]
              (Term.app `order_of_eq_card_of_forall_mem_zpowers [`hx]))
             ","
             (Tactic.rwRule [] `order_of_dvd_iff_pow_eq_one)]
            "]")
           [])
          []
          (Tactic.constructor "constructor")
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.intro "intro" [`h]) [] (Tactic.apply "apply" `h)])
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.intro "intro" [`h `y])
            []
            (Mathlib.Tactic.tacticSimp_rw__
             "simp_rw"
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `mem_powers_iff_mem_zpowers)]
              "]")
             [(Tactic.location "at" (Tactic.locationHyp [`hx] []))])
            []
            (Std.Tactic.rcases
             "rcases"
             [(Tactic.casesTarget [] (Term.app `hx [`y]))]
             ["with"
              (Std.Tactic.RCases.rcasesPatLo
               (Std.Tactic.RCases.rcasesPatMed
                [(Std.Tactic.RCases.rcasesPat.tuple
                  "⟨"
                  [(Std.Tactic.RCases.rcasesPatLo
                    (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `j)])
                    [])
                   ","
                   (Std.Tactic.RCases.rcasesPatLo
                    (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `rfl)])
                    [])]
                  "⟩")])
               [])])
            []
            (Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `pow_mul)
               ","
               (Tactic.rwRule [] `mul_comm)
               ","
               (Tactic.rwRule [] `pow_mul)
               ","
               (Tactic.rwRule [] `h)
               ","
               (Tactic.rwRule [] `one_pow)]
              "]")
             [])])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__
       (cdotTk (patternIgnore (token.«· » "·")))
       [(Tactic.intro "intro" [`h `y])
        []
        (Mathlib.Tactic.tacticSimp_rw__
         "simp_rw"
         (Tactic.rwRuleSeq
          "["
          [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `mem_powers_iff_mem_zpowers)]
          "]")
         [(Tactic.location "at" (Tactic.locationHyp [`hx] []))])
        []
        (Std.Tactic.rcases
         "rcases"
         [(Tactic.casesTarget [] (Term.app `hx [`y]))]
         ["with"
          (Std.Tactic.RCases.rcasesPatLo
           (Std.Tactic.RCases.rcasesPatMed
            [(Std.Tactic.RCases.rcasesPat.tuple
              "⟨"
              [(Std.Tactic.RCases.rcasesPatLo
                (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `j)])
                [])
               ","
               (Std.Tactic.RCases.rcasesPatLo
                (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `rfl)])
                [])]
              "⟩")])
           [])])
        []
        (Tactic.rwSeq
         "rw"
         []
         (Tactic.rwRuleSeq
          "["
          [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `pow_mul)
           ","
           (Tactic.rwRule [] `mul_comm)
           ","
           (Tactic.rwRule [] `pow_mul)
           ","
           (Tactic.rwRule [] `h)
           ","
           (Tactic.rwRule [] `one_pow)]
          "]")
         [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `pow_mul)
         ","
         (Tactic.rwRule [] `mul_comm)
         ","
         (Tactic.rwRule [] `pow_mul)
         ","
         (Tactic.rwRule [] `h)
         ","
         (Tactic.rwRule [] `one_pow)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `one_pow
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_mul
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mul_comm
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_mul
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.rcases
       "rcases"
       [(Tactic.casesTarget [] (Term.app `hx [`y]))]
       ["with"
        (Std.Tactic.RCases.rcasesPatLo
         (Std.Tactic.RCases.rcasesPatMed
          [(Std.Tactic.RCases.rcasesPat.tuple
            "⟨"
            [(Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `j)])
              [])
             ","
             (Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `rfl)])
              [])]
            "⟩")])
         [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `hx [`y])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `y
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `hx
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Mathlib.Tactic.tacticSimp_rw__
       "simp_rw"
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `mem_powers_iff_mem_zpowers)]
        "]")
       [(Tactic.location "at" (Tactic.locationHyp [`hx] []))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.locationHyp', expected 'Lean.Parser.Tactic.locationWildcard'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hx
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mem_powers_iff_mem_zpowers
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.intro "intro" [`h `y])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `y
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__
       (cdotTk (patternIgnore (token.«· » "·")))
       [(Tactic.intro "intro" [`h]) [] (Tactic.apply "apply" `h)])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.apply "apply" `h)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.intro "intro" [`h])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.constructor "constructor")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Fintype.card_units)
         ","
         (Tactic.rwRule
          [(patternIgnore (token.«← » "←"))]
          (Term.app `order_of_eq_card_of_forall_mem_zpowers [`hx]))
         ","
         (Tactic.rwRule [] `order_of_dvd_iff_pow_eq_one)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `order_of_dvd_iff_pow_eq_one
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `order_of_eq_card_of_forall_mem_zpowers [`hx])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hx
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `order_of_eq_card_of_forall_mem_zpowers
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Fintype.card_units
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.obtain
       "obtain"
       [(Std.Tactic.RCases.rcasesPatMed
         [(Std.Tactic.RCases.rcasesPat.tuple
           "⟨"
           [(Std.Tactic.RCases.rcasesPatLo
             (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `x)])
             [])
            ","
            (Std.Tactic.RCases.rcasesPatLo
             (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hx)])
             [])]
           "⟩")])]
       []
       [":=" [(Term.app `IsCyclic.exists_generator [(Algebra.Group.Units.«term_ˣ» `K "ˣ")])]])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `IsCyclic.exists_generator [(Algebra.Group.Units.«term_ˣ» `K "ˣ")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Algebra.Group.Units.«term_ˣ»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Algebra.Group.Units.«term_ˣ»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Algebra.Group.Units.«term_ˣ» `K "ˣ")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `IsCyclic.exists_generator
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_↔_»
       (Term.forall
        "∀"
        [`x]
        [(Term.typeSpec ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]
        ","
        («term_=_» («term_^_» `x "^" `i) "=" (num "1")))
       "↔"
       («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "1")
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  forall_pow_eq_one_iff
  ( i : ℕ ) : ∀ x : K ˣ , x ^ i = 1 ↔ q - 1 ∣ i
  :=
    by
      classical
        obtain ⟨ x , hx ⟩ := IsCyclic.exists_generator K ˣ
          rw
            [
              ← Fintype.card_units
                ,
                ← order_of_eq_card_of_forall_mem_zpowers hx
                ,
                order_of_dvd_iff_pow_eq_one
              ]
          constructor
          · intro h apply h
          ·
            intro h y
              simp_rw [ ← mem_powers_iff_mem_zpowers ] at hx
              rcases hx y with ⟨ j , rfl ⟩
              rw [ ← pow_mul , mul_comm , pow_mul , h , one_pow ]
#align finite_field.forall_pow_eq_one_iff FiniteField.forall_pow_eq_one_iff

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment
        "/--"
        "The sum of `x ^ i` as `x` ranges over the units of a finite field of cardinality `q`\nis equal to `0` unless `(q - 1) ∣ i`, in which case the sum is `q - 1`. -/")]
      []
      []
      []
      []
      [])
     (Command.theorem
      "theorem"
      (Command.declId `sum_pow_units [])
      (Command.declSig
       [(Term.instBinder "[" [] (Term.app `Fintype [(Algebra.Group.Units.«term_ˣ» `K "ˣ")]) "]")
        (Term.explicitBinder "(" [`i] [":" (termℕ "ℕ")] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
          "∑"
          (Std.ExtendedBinder.extBinders
           (Std.ExtendedBinder.extBinder
            (Lean.binderIdent `x)
            [(group ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]))
          ", "
          (Term.typeAscription "(" («term_^_» `x "^" `i) ":" [`K] ")"))
         "="
         (termIfThenElse
          "if"
          («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)
          "then"
          («term-_» "-" (num "1"))
          "else"
          (num "0")))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.tacticLet_
            "let"
            (Term.letDecl
             (Term.letIdDecl
              `φ
              []
              [(Term.typeSpec
                ":"
                (Algebra.Hom.Group.«term_→*_» (Algebra.Group.Units.«term_ˣ» `K "ˣ") " →* " `K))]
              ":="
              (Term.structInst
               "{"
               []
               [(Term.structInstField
                 (Term.structInstLVal `toFun [])
                 ":="
                 (Term.fun "fun" (Term.basicFun [`x] [] "=>" («term_^_» `x "^" `i))))
                []
                (Term.structInstField
                 (Term.structInstLVal `map_one' [])
                 ":="
                 (Term.byTactic
                  "by"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Tactic.rwSeq
                      "rw"
                      []
                      (Tactic.rwRuleSeq
                       "["
                       [(Tactic.rwRule [] `Units.val_one) "," (Tactic.rwRule [] `one_pow)]
                       "]")
                      [])]))))
                []
                (Term.structInstField
                 (Term.structInstLVal `map_mul' [])
                 ":="
                 (Term.byTactic
                  "by"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Tactic.intros "intros" [])
                     []
                     (Tactic.rwSeq
                      "rw"
                      []
                      (Tactic.rwRuleSeq
                       "["
                       [(Tactic.rwRule [] `Units.val_mul) "," (Tactic.rwRule [] `mul_pow)]
                       "]")
                      [])]))))]
               (Term.optEllipsis [])
               []
               "}"))))
           []
           (Tactic.tacticHave_
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec ":" (Term.app `Decidable [(«term_=_» `φ "=" (num "1"))]))]
              ":="
              (Term.byTactic
               "by"
               (Tactic.tacticSeq
                (Tactic.tacticSeq1Indented
                 [(Mathlib.Tactic.tacticClassical_
                   "classical"
                   (Tactic.tacticSeq
                    (Tactic.tacticSeq1Indented
                     [(Tactic.tacticInfer_instance "infer_instance")])))]))))))
           []
           (calcTactic
            "calc"
            (calcStep
             («term_=_»
              (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
               "∑"
               (Std.ExtendedBinder.extBinders
                (Std.ExtendedBinder.extBinder
                 (Lean.binderIdent `x)
                 [(group ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]))
               ", "
               (Term.app `φ [`x]))
              "="
              (termIfThenElse
               "if"
               («term_=_» `φ "=" (num "1"))
               "then"
               (Term.app `Fintype.card [(Algebra.Group.Units.«term_ˣ» `K "ˣ")])
               "else"
               (num "0")))
             ":="
             (Term.app `sum_hom_units [`φ]))
            [(calcStep
              («term_=_»
               (Term.hole "_")
               "="
               (termIfThenElse
                "if"
                («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)
                "then"
                («term-_» "-" (num "1"))
                "else"
                (num "0")))
              ":="
              (Term.hole "_"))])
           []
           (Tactic.tacticSuffices_
            "suffices"
            (Term.sufficesDecl
             []
             («term_↔_»
              («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)
              "↔"
              («term_=_» `φ "=" (num "1")))
             (Term.byTactic'
              "by"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Tactic.simp "simp" [] [] ["only"] ["[" [(Tactic.simpLemma [] [] `this)] "]"] [])
                 []
                 (Mathlib.Tactic.splitIfs
                  "split_ifs"
                  []
                  ["with" [(Lean.binderIdent `h) (Lean.binderIdent `h)]])
                 []
                 (Mathlib.Tactic.tacticSwap "swap")
                 []
                 (Tactic.tacticRfl "rfl")
                 []
                 (Tactic.rwSeq
                  "rw"
                  []
                  (Tactic.rwRuleSeq
                   "["
                   [(Tactic.rwRule [] `Fintype.card_units)
                    ","
                    (Tactic.rwRule [] `Nat.cast_sub)
                    ","
                    (Tactic.rwRule [] `cast_card_eq_zero)
                    ","
                    (Tactic.rwRule [] `Nat.cast_one)
                    ","
                    (Tactic.rwRule [] `zero_sub)]
                   "]")
                  [])
                 []
                 (Tactic.tacticShow_
                  "show"
                  («term_≤_» (num "1") "≤" (FieldTheory.Finite.Basic.termq "q")))
                 []
                 (Tactic.exact
                  "exact"
                  (Term.app
                   `fintype.card_pos_iff.mpr
                   [(Term.anonymousCtor "⟨" [(num "0")] "⟩")]))])))))
           []
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `forall_pow_eq_one_iff)
              ","
              (Tactic.rwRule [] `MonoidHom.ext_iff)]
             "]")
            [])
           []
           (Tactic.apply "apply" `forall_congr')
           []
           (Tactic.intro "intro" [`x])
           []
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule [] `Units.ext_iff)
              ","
              (Tactic.rwRule [] `Units.val_pow_eq_pow_val)
              ","
              (Tactic.rwRule [] `Units.val_one)
              ","
              (Tactic.rwRule [] `MonoidHom.one_apply)]
             "]")
            [])
           []
           (Tactic.tacticRfl "rfl")])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.tacticLet_
           "let"
           (Term.letDecl
            (Term.letIdDecl
             `φ
             []
             [(Term.typeSpec
               ":"
               (Algebra.Hom.Group.«term_→*_» (Algebra.Group.Units.«term_ˣ» `K "ˣ") " →* " `K))]
             ":="
             (Term.structInst
              "{"
              []
              [(Term.structInstField
                (Term.structInstLVal `toFun [])
                ":="
                (Term.fun "fun" (Term.basicFun [`x] [] "=>" («term_^_» `x "^" `i))))
               []
               (Term.structInstField
                (Term.structInstLVal `map_one' [])
                ":="
                (Term.byTactic
                 "by"
                 (Tactic.tacticSeq
                  (Tactic.tacticSeq1Indented
                   [(Tactic.rwSeq
                     "rw"
                     []
                     (Tactic.rwRuleSeq
                      "["
                      [(Tactic.rwRule [] `Units.val_one) "," (Tactic.rwRule [] `one_pow)]
                      "]")
                     [])]))))
               []
               (Term.structInstField
                (Term.structInstLVal `map_mul' [])
                ":="
                (Term.byTactic
                 "by"
                 (Tactic.tacticSeq
                  (Tactic.tacticSeq1Indented
                   [(Tactic.intros "intros" [])
                    []
                    (Tactic.rwSeq
                     "rw"
                     []
                     (Tactic.rwRuleSeq
                      "["
                      [(Tactic.rwRule [] `Units.val_mul) "," (Tactic.rwRule [] `mul_pow)]
                      "]")
                     [])]))))]
              (Term.optEllipsis [])
              []
              "}"))))
          []
          (Tactic.tacticHave_
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec ":" (Term.app `Decidable [(«term_=_» `φ "=" (num "1"))]))]
             ":="
             (Term.byTactic
              "by"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Mathlib.Tactic.tacticClassical_
                  "classical"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Tactic.tacticInfer_instance "infer_instance")])))]))))))
          []
          (calcTactic
           "calc"
           (calcStep
            («term_=_»
             (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
              "∑"
              (Std.ExtendedBinder.extBinders
               (Std.ExtendedBinder.extBinder
                (Lean.binderIdent `x)
                [(group ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]))
              ", "
              (Term.app `φ [`x]))
             "="
             (termIfThenElse
              "if"
              («term_=_» `φ "=" (num "1"))
              "then"
              (Term.app `Fintype.card [(Algebra.Group.Units.«term_ˣ» `K "ˣ")])
              "else"
              (num "0")))
            ":="
            (Term.app `sum_hom_units [`φ]))
           [(calcStep
             («term_=_»
              (Term.hole "_")
              "="
              (termIfThenElse
               "if"
               («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)
               "then"
               («term-_» "-" (num "1"))
               "else"
               (num "0")))
             ":="
             (Term.hole "_"))])
          []
          (Tactic.tacticSuffices_
           "suffices"
           (Term.sufficesDecl
            []
            («term_↔_»
             («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)
             "↔"
             («term_=_» `φ "=" (num "1")))
            (Term.byTactic'
             "by"
             (Tactic.tacticSeq
              (Tactic.tacticSeq1Indented
               [(Tactic.simp "simp" [] [] ["only"] ["[" [(Tactic.simpLemma [] [] `this)] "]"] [])
                []
                (Mathlib.Tactic.splitIfs
                 "split_ifs"
                 []
                 ["with" [(Lean.binderIdent `h) (Lean.binderIdent `h)]])
                []
                (Mathlib.Tactic.tacticSwap "swap")
                []
                (Tactic.tacticRfl "rfl")
                []
                (Tactic.rwSeq
                 "rw"
                 []
                 (Tactic.rwRuleSeq
                  "["
                  [(Tactic.rwRule [] `Fintype.card_units)
                   ","
                   (Tactic.rwRule [] `Nat.cast_sub)
                   ","
                   (Tactic.rwRule [] `cast_card_eq_zero)
                   ","
                   (Tactic.rwRule [] `Nat.cast_one)
                   ","
                   (Tactic.rwRule [] `zero_sub)]
                  "]")
                 [])
                []
                (Tactic.tacticShow_
                 "show"
                 («term_≤_» (num "1") "≤" (FieldTheory.Finite.Basic.termq "q")))
                []
                (Tactic.exact
                 "exact"
                 (Term.app
                  `fintype.card_pos_iff.mpr
                  [(Term.anonymousCtor "⟨" [(num "0")] "⟩")]))])))))
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `forall_pow_eq_one_iff)
             ","
             (Tactic.rwRule [] `MonoidHom.ext_iff)]
            "]")
           [])
          []
          (Tactic.apply "apply" `forall_congr')
          []
          (Tactic.intro "intro" [`x])
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] `Units.ext_iff)
             ","
             (Tactic.rwRule [] `Units.val_pow_eq_pow_val)
             ","
             (Tactic.rwRule [] `Units.val_one)
             ","
             (Tactic.rwRule [] `MonoidHom.one_apply)]
            "]")
           [])
          []
          (Tactic.tacticRfl "rfl")])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticRfl "rfl")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] `Units.ext_iff)
         ","
         (Tactic.rwRule [] `Units.val_pow_eq_pow_val)
         ","
         (Tactic.rwRule [] `Units.val_one)
         ","
         (Tactic.rwRule [] `MonoidHom.one_apply)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `MonoidHom.one_apply
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Units.val_one
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Units.val_pow_eq_pow_val
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Units.ext_iff
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.intro "intro" [`x])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `x
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.apply "apply" `forall_congr')
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `forall_congr'
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `forall_pow_eq_one_iff)
         ","
         (Tactic.rwRule [] `MonoidHom.ext_iff)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `MonoidHom.ext_iff
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `forall_pow_eq_one_iff
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticSuffices_
       "suffices"
       (Term.sufficesDecl
        []
        («term_↔_»
         («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)
         "↔"
         («term_=_» `φ "=" (num "1")))
        (Term.byTactic'
         "by"
         (Tactic.tacticSeq
          (Tactic.tacticSeq1Indented
           [(Tactic.simp "simp" [] [] ["only"] ["[" [(Tactic.simpLemma [] [] `this)] "]"] [])
            []
            (Mathlib.Tactic.splitIfs
             "split_ifs"
             []
             ["with" [(Lean.binderIdent `h) (Lean.binderIdent `h)]])
            []
            (Mathlib.Tactic.tacticSwap "swap")
            []
            (Tactic.tacticRfl "rfl")
            []
            (Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] `Fintype.card_units)
               ","
               (Tactic.rwRule [] `Nat.cast_sub)
               ","
               (Tactic.rwRule [] `cast_card_eq_zero)
               ","
               (Tactic.rwRule [] `Nat.cast_one)
               ","
               (Tactic.rwRule [] `zero_sub)]
              "]")
             [])
            []
            (Tactic.tacticShow_
             "show"
             («term_≤_» (num "1") "≤" (FieldTheory.Finite.Basic.termq "q")))
            []
            (Tactic.exact
             "exact"
             (Term.app `fintype.card_pos_iff.mpr [(Term.anonymousCtor "⟨" [(num "0")] "⟩")]))])))))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.byTactic'', expected 'Lean.Parser.Term.fromTerm'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.app `fintype.card_pos_iff.mpr [(Term.anonymousCtor "⟨" [(num "0")] "⟩")]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `fintype.card_pos_iff.mpr [(Term.anonymousCtor "⟨" [(num "0")] "⟩")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.anonymousCtor', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.anonymousCtor', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [(num "0")] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "0")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `fintype.card_pos_iff.mpr
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticShow_ "show" («term_≤_» (num "1") "≤" (FieldTheory.Finite.Basic.termq "q")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_≤_» (num "1") "≤" (FieldTheory.Finite.Basic.termq "q"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
/--
    The sum of `x ^ i` as `x` ranges over the units of a finite field of cardinality `q`
    is equal to `0` unless `(q - 1) ∣ i`, in which case the sum is `q - 1`. -/
  theorem
    sum_pow_units
    [ Fintype K ˣ ] ( i : ℕ ) : ∑ x : K ˣ , ( x ^ i : K ) = if q - 1 ∣ i then - 1 else 0
    :=
      by
        let
            φ
              : K ˣ →* K
              :=
              {
                toFun := fun x => x ^ i
                  map_one' := by rw [ Units.val_one , one_pow ]
                  map_mul' := by intros rw [ Units.val_mul , mul_pow ]
                }
          have : Decidable φ = 1 := by classical infer_instance
          calc
            ∑ x : K ˣ , φ x = if φ = 1 then Fintype.card K ˣ else 0 := sum_hom_units φ
            _ = if q - 1 ∣ i then - 1 else 0 := _
          suffices
            q - 1 ∣ i ↔ φ = 1
              by
                simp only [ this ]
                  split_ifs with h h
                  swap
                  rfl
                  rw
                    [
                      Fintype.card_units
                        ,
                        Nat.cast_sub
                        ,
                        cast_card_eq_zero
                        ,
                        Nat.cast_one
                        ,
                        zero_sub
                      ]
                  show 1 ≤ q
                  exact fintype.card_pos_iff.mpr ⟨ 0 ⟩
          rw [ ← forall_pow_eq_one_iff , MonoidHom.ext_iff ]
          apply forall_congr'
          intro x
          rw [ Units.ext_iff , Units.val_pow_eq_pow_val , Units.val_one , MonoidHom.one_apply ]
          rfl
#align finite_field.sum_pow_units FiniteField.sum_pow_units

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment
        "/--"
        "The sum of `x ^ i` as `x` ranges over a finite field of cardinality `q`\nis equal to `0` if `i < q - 1`. -/")]
      []
      []
      []
      []
      [])
     (Command.theorem
      "theorem"
      (Command.declId `sum_pow_lt_card_sub_one [])
      (Command.declSig
       [(Term.explicitBinder "(" [`i] [":" (termℕ "ℕ")] [] ")")
        (Term.explicitBinder
         "("
         [`h]
         [":" («term_<_» `i "<" («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")))]
         []
         ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
          "∑"
          (Std.ExtendedBinder.extBinders
           (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) [(group ":" `K)]))
          ", "
          («term_^_» `x "^" `i))
         "="
         (num "0"))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Classical.«tacticBy_cases_:_» "by_cases" [`hi ":"] («term_=_» `i "=" (num "0")))
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.simp
              "simp"
              []
              []
              ["only"]
              ["["
               [(Tactic.simpLemma [] [] `hi)
                ","
                (Tactic.simpLemma [] [] `nsmul_one)
                ","
                (Tactic.simpLemma [] [] `sum_const)
                ","
                (Tactic.simpLemma [] [] `pow_zero)
                ","
                (Tactic.simpLemma [] [] `card_univ)
                ","
                (Tactic.simpLemma [] [] `cast_card_eq_zero)]
               "]"]
              [])])
           []
           (Mathlib.Tactic.tacticClassical_
            "classical"
            (Tactic.tacticSeq
             (Tactic.tacticSeq1Indented
              [(Tactic.tacticHave_
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  [`hiq []]
                  [(Term.typeSpec
                    ":"
                    («term¬_»
                     "¬"
                     («term_∣_»
                      («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1"))
                      "∣"
                      `i)))]
                  ":="
                  (Term.byTactic
                   "by"
                   (Tactic.tacticSeq
                    (Tactic.tacticSeq1Indented
                     [(Mathlib.Tactic.Contrapose.contrapose! "contrapose!" [`h []])
                      []
                      (Tactic.exact
                       "exact"
                       (Term.app `Nat.le_of_dvd [(Term.app `Nat.pos_of_ne_zero [`hi]) `h]))]))))))
               []
               (Tactic.tacticLet_
                "let"
                (Term.letDecl
                 (Term.letIdDecl
                  `φ
                  []
                  [(Term.typeSpec
                    ":"
                    (Function.Logic.Embedding.Basic.«term_↪_»
                     (Algebra.Group.Units.«term_ˣ» `K "ˣ")
                     " ↪ "
                     `K))]
                  ":="
                  (Term.anonymousCtor "⟨" [`coe "," `Units.ext] "⟩"))))
               []
               (Tactic.tacticHave_
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  []
                  [(Term.typeSpec
                    ":"
                    («term_=_»
                     (Term.app `univ.map [`φ])
                     "="
                     («term_\_» `univ "\\" («term{_}» "{" [(num "0")] "}"))))]
                  ":="
                  (Term.byTactic
                   "by"
                   (Tactic.tacticSeq
                    (Tactic.tacticSeq1Indented
                     [(Std.Tactic.Ext.«tacticExt___:_»
                       "ext"
                       [(Std.Tactic.RCases.rintroPat.one (Std.Tactic.RCases.rcasesPat.one `x))]
                       [])
                      []
                      (Tactic.simp
                       "simp"
                       []
                       []
                       ["only"]
                       ["["
                        [(Tactic.simpLemma [] [] `true_and_iff)
                         ","
                         (Tactic.simpLemma [] [] `embedding.coe_fn_mk)
                         ","
                         (Tactic.simpLemma [] [] `mem_sdiff)
                         ","
                         (Tactic.simpLemma [] [] `Units.exists_iff_ne_zero)
                         ","
                         (Tactic.simpLemma [] [] `mem_univ)
                         ","
                         (Tactic.simpLemma [] [] `mem_map)
                         ","
                         (Tactic.simpLemma [] [] `exists_prop_of_true)
                         ","
                         (Tactic.simpLemma [] [] `mem_singleton)]
                        "]"]
                       [])]))))))
               []
               (calcTactic
                "calc"
                (calcStep
                 («term_=_»
                  (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
                   "∑"
                   (Std.ExtendedBinder.extBinders
                    (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) [(group ":" `K)]))
                   ", "
                   («term_^_» `x "^" `i))
                  "="
                  (BigOperators.Algebra.BigOperators.Basic.finset.sum
                   "∑"
                   (Std.ExtendedBinder.extBinders
                    (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) []))
                   " in "
                   («term_\_»
                    `univ
                    "\\"
                    («term{_}» "{" [(Term.typeAscription "(" (num "0") ":" [`K] ")")] "}"))
                   ", "
                   («term_^_» `x "^" `i)))
                 ":="
                 (Term.byTactic
                  "by"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Tactic.rwSeq
                      "rw"
                      []
                      (Tactic.rwRuleSeq
                       "["
                       [(Tactic.rwRule
                         [(patternIgnore (token.«← » "←"))]
                         (Term.app
                          `sum_sdiff
                          [(Term.proj
                            (Term.typeAscription
                             "("
                             («term{_}» "{" [(num "0")] "}")
                             ":"
                             [(Term.app `Finset [`K])]
                             ")")
                            "."
                            `subset_univ)]))
                        ","
                        (Tactic.rwRule [] `sum_singleton)
                        ","
                        (Tactic.rwRule
                         []
                         (Term.app `zero_pow [(Term.app `Nat.pos_of_ne_zero [`hi])]))
                        ","
                        (Tactic.rwRule [] `add_zero)]
                       "]")
                      [])]))))
                [(calcStep
                  («term_=_»
                   (Term.hole "_")
                   "="
                   (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
                    "∑"
                    (Std.ExtendedBinder.extBinders
                     (Std.ExtendedBinder.extBinder
                      (Lean.binderIdent `x)
                      [(group ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]))
                    ", "
                    («term_^_» `x "^" `i)))
                  ":="
                  (Term.byTactic
                   "by"
                   (Tactic.tacticSeq
                    (Tactic.tacticSeq1Indented
                     [(Tactic.rwSeq
                       "rw"
                       []
                       (Tactic.rwRuleSeq
                        "["
                        [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
                         ","
                         (Tactic.rwRule [] (Term.app `univ.sum_map [`φ]))]
                        "]")
                       [])
                      []
                      (Tactic.tacticRfl "rfl")]))))
                 (calcStep
                  («term_=_» (Term.hole "_") "=" (num "0"))
                  ":="
                  (Term.byTactic
                   "by"
                   (Tactic.tacticSeq
                    (Tactic.tacticSeq1Indented
                     [(Tactic.rwSeq
                       "rw"
                       []
                       (Tactic.rwRuleSeq
                        "["
                        [(Tactic.rwRule [] (Term.app `sum_pow_units [`K `i]))
                         ","
                         (Tactic.rwRule [] `if_neg)]
                        "]")
                       [])
                      []
                      (Tactic.exact "exact" `hiq)]))))])])))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Classical.«tacticBy_cases_:_» "by_cases" [`hi ":"] («term_=_» `i "=" (num "0")))
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.simp
             "simp"
             []
             []
             ["only"]
             ["["
              [(Tactic.simpLemma [] [] `hi)
               ","
               (Tactic.simpLemma [] [] `nsmul_one)
               ","
               (Tactic.simpLemma [] [] `sum_const)
               ","
               (Tactic.simpLemma [] [] `pow_zero)
               ","
               (Tactic.simpLemma [] [] `card_univ)
               ","
               (Tactic.simpLemma [] [] `cast_card_eq_zero)]
              "]"]
             [])])
          []
          (Mathlib.Tactic.tacticClassical_
           "classical"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Tactic.tacticHave_
               "have"
               (Term.haveDecl
                (Term.haveIdDecl
                 [`hiq []]
                 [(Term.typeSpec
                   ":"
                   («term¬_»
                    "¬"
                    («term_∣_»
                     («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1"))
                     "∣"
                     `i)))]
                 ":="
                 (Term.byTactic
                  "by"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Mathlib.Tactic.Contrapose.contrapose! "contrapose!" [`h []])
                     []
                     (Tactic.exact
                      "exact"
                      (Term.app `Nat.le_of_dvd [(Term.app `Nat.pos_of_ne_zero [`hi]) `h]))]))))))
              []
              (Tactic.tacticLet_
               "let"
               (Term.letDecl
                (Term.letIdDecl
                 `φ
                 []
                 [(Term.typeSpec
                   ":"
                   (Function.Logic.Embedding.Basic.«term_↪_»
                    (Algebra.Group.Units.«term_ˣ» `K "ˣ")
                    " ↪ "
                    `K))]
                 ":="
                 (Term.anonymousCtor "⟨" [`coe "," `Units.ext] "⟩"))))
              []
              (Tactic.tacticHave_
               "have"
               (Term.haveDecl
                (Term.haveIdDecl
                 []
                 [(Term.typeSpec
                   ":"
                   («term_=_»
                    (Term.app `univ.map [`φ])
                    "="
                    («term_\_» `univ "\\" («term{_}» "{" [(num "0")] "}"))))]
                 ":="
                 (Term.byTactic
                  "by"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Std.Tactic.Ext.«tacticExt___:_»
                      "ext"
                      [(Std.Tactic.RCases.rintroPat.one (Std.Tactic.RCases.rcasesPat.one `x))]
                      [])
                     []
                     (Tactic.simp
                      "simp"
                      []
                      []
                      ["only"]
                      ["["
                       [(Tactic.simpLemma [] [] `true_and_iff)
                        ","
                        (Tactic.simpLemma [] [] `embedding.coe_fn_mk)
                        ","
                        (Tactic.simpLemma [] [] `mem_sdiff)
                        ","
                        (Tactic.simpLemma [] [] `Units.exists_iff_ne_zero)
                        ","
                        (Tactic.simpLemma [] [] `mem_univ)
                        ","
                        (Tactic.simpLemma [] [] `mem_map)
                        ","
                        (Tactic.simpLemma [] [] `exists_prop_of_true)
                        ","
                        (Tactic.simpLemma [] [] `mem_singleton)]
                       "]"]
                      [])]))))))
              []
              (calcTactic
               "calc"
               (calcStep
                («term_=_»
                 (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
                  "∑"
                  (Std.ExtendedBinder.extBinders
                   (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) [(group ":" `K)]))
                  ", "
                  («term_^_» `x "^" `i))
                 "="
                 (BigOperators.Algebra.BigOperators.Basic.finset.sum
                  "∑"
                  (Std.ExtendedBinder.extBinders
                   (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) []))
                  " in "
                  («term_\_»
                   `univ
                   "\\"
                   («term{_}» "{" [(Term.typeAscription "(" (num "0") ":" [`K] ")")] "}"))
                  ", "
                  («term_^_» `x "^" `i)))
                ":="
                (Term.byTactic
                 "by"
                 (Tactic.tacticSeq
                  (Tactic.tacticSeq1Indented
                   [(Tactic.rwSeq
                     "rw"
                     []
                     (Tactic.rwRuleSeq
                      "["
                      [(Tactic.rwRule
                        [(patternIgnore (token.«← » "←"))]
                        (Term.app
                         `sum_sdiff
                         [(Term.proj
                           (Term.typeAscription
                            "("
                            («term{_}» "{" [(num "0")] "}")
                            ":"
                            [(Term.app `Finset [`K])]
                            ")")
                           "."
                           `subset_univ)]))
                       ","
                       (Tactic.rwRule [] `sum_singleton)
                       ","
                       (Tactic.rwRule
                        []
                        (Term.app `zero_pow [(Term.app `Nat.pos_of_ne_zero [`hi])]))
                       ","
                       (Tactic.rwRule [] `add_zero)]
                      "]")
                     [])]))))
               [(calcStep
                 («term_=_»
                  (Term.hole "_")
                  "="
                  (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
                   "∑"
                   (Std.ExtendedBinder.extBinders
                    (Std.ExtendedBinder.extBinder
                     (Lean.binderIdent `x)
                     [(group ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]))
                   ", "
                   («term_^_» `x "^" `i)))
                 ":="
                 (Term.byTactic
                  "by"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Tactic.rwSeq
                      "rw"
                      []
                      (Tactic.rwRuleSeq
                       "["
                       [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
                        ","
                        (Tactic.rwRule [] (Term.app `univ.sum_map [`φ]))]
                       "]")
                      [])
                     []
                     (Tactic.tacticRfl "rfl")]))))
                (calcStep
                 («term_=_» (Term.hole "_") "=" (num "0"))
                 ":="
                 (Term.byTactic
                  "by"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Tactic.rwSeq
                      "rw"
                      []
                      (Tactic.rwRuleSeq
                       "["
                       [(Tactic.rwRule [] (Term.app `sum_pow_units [`K `i]))
                        ","
                        (Tactic.rwRule [] `if_neg)]
                       "]")
                      [])
                     []
                     (Tactic.exact "exact" `hiq)]))))])])))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Mathlib.Tactic.tacticClassical_
       "classical"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.tacticHave_
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             [`hiq []]
             [(Term.typeSpec
               ":"
               («term¬_»
                "¬"
                («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)))]
             ":="
             (Term.byTactic
              "by"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Mathlib.Tactic.Contrapose.contrapose! "contrapose!" [`h []])
                 []
                 (Tactic.exact
                  "exact"
                  (Term.app `Nat.le_of_dvd [(Term.app `Nat.pos_of_ne_zero [`hi]) `h]))]))))))
          []
          (Tactic.tacticLet_
           "let"
           (Term.letDecl
            (Term.letIdDecl
             `φ
             []
             [(Term.typeSpec
               ":"
               (Function.Logic.Embedding.Basic.«term_↪_»
                (Algebra.Group.Units.«term_ˣ» `K "ˣ")
                " ↪ "
                `K))]
             ":="
             (Term.anonymousCtor "⟨" [`coe "," `Units.ext] "⟩"))))
          []
          (Tactic.tacticHave_
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec
               ":"
               («term_=_»
                (Term.app `univ.map [`φ])
                "="
                («term_\_» `univ "\\" («term{_}» "{" [(num "0")] "}"))))]
             ":="
             (Term.byTactic
              "by"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Std.Tactic.Ext.«tacticExt___:_»
                  "ext"
                  [(Std.Tactic.RCases.rintroPat.one (Std.Tactic.RCases.rcasesPat.one `x))]
                  [])
                 []
                 (Tactic.simp
                  "simp"
                  []
                  []
                  ["only"]
                  ["["
                   [(Tactic.simpLemma [] [] `true_and_iff)
                    ","
                    (Tactic.simpLemma [] [] `embedding.coe_fn_mk)
                    ","
                    (Tactic.simpLemma [] [] `mem_sdiff)
                    ","
                    (Tactic.simpLemma [] [] `Units.exists_iff_ne_zero)
                    ","
                    (Tactic.simpLemma [] [] `mem_univ)
                    ","
                    (Tactic.simpLemma [] [] `mem_map)
                    ","
                    (Tactic.simpLemma [] [] `exists_prop_of_true)
                    ","
                    (Tactic.simpLemma [] [] `mem_singleton)]
                   "]"]
                  [])]))))))
          []
          (calcTactic
           "calc"
           (calcStep
            («term_=_»
             (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
              "∑"
              (Std.ExtendedBinder.extBinders
               (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) [(group ":" `K)]))
              ", "
              («term_^_» `x "^" `i))
             "="
             (BigOperators.Algebra.BigOperators.Basic.finset.sum
              "∑"
              (Std.ExtendedBinder.extBinders
               (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) []))
              " in "
              («term_\_»
               `univ
               "\\"
               («term{_}» "{" [(Term.typeAscription "(" (num "0") ":" [`K] ")")] "}"))
              ", "
              («term_^_» `x "^" `i)))
            ":="
            (Term.byTactic
             "by"
             (Tactic.tacticSeq
              (Tactic.tacticSeq1Indented
               [(Tactic.rwSeq
                 "rw"
                 []
                 (Tactic.rwRuleSeq
                  "["
                  [(Tactic.rwRule
                    [(patternIgnore (token.«← » "←"))]
                    (Term.app
                     `sum_sdiff
                     [(Term.proj
                       (Term.typeAscription
                        "("
                        («term{_}» "{" [(num "0")] "}")
                        ":"
                        [(Term.app `Finset [`K])]
                        ")")
                       "."
                       `subset_univ)]))
                   ","
                   (Tactic.rwRule [] `sum_singleton)
                   ","
                   (Tactic.rwRule [] (Term.app `zero_pow [(Term.app `Nat.pos_of_ne_zero [`hi])]))
                   ","
                   (Tactic.rwRule [] `add_zero)]
                  "]")
                 [])]))))
           [(calcStep
             («term_=_»
              (Term.hole "_")
              "="
              (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
               "∑"
               (Std.ExtendedBinder.extBinders
                (Std.ExtendedBinder.extBinder
                 (Lean.binderIdent `x)
                 [(group ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]))
               ", "
               («term_^_» `x "^" `i)))
             ":="
             (Term.byTactic
              "by"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Tactic.rwSeq
                  "rw"
                  []
                  (Tactic.rwRuleSeq
                   "["
                   [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
                    ","
                    (Tactic.rwRule [] (Term.app `univ.sum_map [`φ]))]
                   "]")
                  [])
                 []
                 (Tactic.tacticRfl "rfl")]))))
            (calcStep
             («term_=_» (Term.hole "_") "=" (num "0"))
             ":="
             (Term.byTactic
              "by"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Tactic.rwSeq
                  "rw"
                  []
                  (Tactic.rwRuleSeq
                   "["
                   [(Tactic.rwRule [] (Term.app `sum_pow_units [`K `i]))
                    ","
                    (Tactic.rwRule [] `if_neg)]
                   "]")
                  [])
                 []
                 (Tactic.exact "exact" `hiq)]))))])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (calcTactic
       "calc"
       (calcStep
        («term_=_»
         (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
          "∑"
          (Std.ExtendedBinder.extBinders
           (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) [(group ":" `K)]))
          ", "
          («term_^_» `x "^" `i))
         "="
         (BigOperators.Algebra.BigOperators.Basic.finset.sum
          "∑"
          (Std.ExtendedBinder.extBinders (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) []))
          " in "
          («term_\_»
           `univ
           "\\"
           («term{_}» "{" [(Term.typeAscription "(" (num "0") ":" [`K] ")")] "}"))
          ", "
          («term_^_» `x "^" `i)))
        ":="
        (Term.byTactic
         "by"
         (Tactic.tacticSeq
          (Tactic.tacticSeq1Indented
           [(Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule
                [(patternIgnore (token.«← » "←"))]
                (Term.app
                 `sum_sdiff
                 [(Term.proj
                   (Term.typeAscription
                    "("
                    («term{_}» "{" [(num "0")] "}")
                    ":"
                    [(Term.app `Finset [`K])]
                    ")")
                   "."
                   `subset_univ)]))
               ","
               (Tactic.rwRule [] `sum_singleton)
               ","
               (Tactic.rwRule [] (Term.app `zero_pow [(Term.app `Nat.pos_of_ne_zero [`hi])]))
               ","
               (Tactic.rwRule [] `add_zero)]
              "]")
             [])]))))
       [(calcStep
         («term_=_»
          (Term.hole "_")
          "="
          (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
           "∑"
           (Std.ExtendedBinder.extBinders
            (Std.ExtendedBinder.extBinder
             (Lean.binderIdent `x)
             [(group ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]))
           ", "
           («term_^_» `x "^" `i)))
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Tactic.rwSeq
              "rw"
              []
              (Tactic.rwRuleSeq
               "["
               [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
                ","
                (Tactic.rwRule [] (Term.app `univ.sum_map [`φ]))]
               "]")
              [])
             []
             (Tactic.tacticRfl "rfl")]))))
        (calcStep
         («term_=_» (Term.hole "_") "=" (num "0"))
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Tactic.rwSeq
              "rw"
              []
              (Tactic.rwRuleSeq
               "["
               [(Tactic.rwRule [] (Term.app `sum_pow_units [`K `i])) "," (Tactic.rwRule [] `if_neg)]
               "]")
              [])
             []
             (Tactic.exact "exact" `hiq)]))))])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] (Term.app `sum_pow_units [`K `i])) "," (Tactic.rwRule [] `if_neg)]
            "]")
           [])
          []
          (Tactic.exact "exact" `hiq)])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact "exact" `hiq)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hiq
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] (Term.app `sum_pow_units [`K `i])) "," (Tactic.rwRule [] `if_neg)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `if_neg
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `sum_pow_units [`K `i])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `sum_pow_units
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_» (Term.hole "_") "=" (num "0"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "0")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none, [anonymous]) <=? (some 50, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 51, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, term))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
             ","
             (Tactic.rwRule [] (Term.app `univ.sum_map [`φ]))]
            "]")
           [])
          []
          (Tactic.tacticRfl "rfl")])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticRfl "rfl")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
         ","
         (Tactic.rwRule [] (Term.app `univ.sum_map [`φ]))]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `univ.sum_map [`φ])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `φ
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `univ.sum_map
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `this
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_»
       (Term.hole "_")
       "="
       (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
        "∑"
        (Std.ExtendedBinder.extBinders
         (Std.ExtendedBinder.extBinder
          (Lean.binderIdent `x)
          [(group ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]))
        ", "
        («term_^_» `x "^" `i)))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
       "∑"
       (Std.ExtendedBinder.extBinders
        (Std.ExtendedBinder.extBinder
         (Lean.binderIdent `x)
         [(group ":" (Algebra.Group.Units.«term_ˣ» `K "ˣ"))]))
       ", "
       («term_^_» `x "^" `i))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_^_» `x "^" `i)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 80 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      `x
[PrettyPrinter.parenthesize] ...precedences are 81 >? 1024, (none, [anonymous]) <=? (some 80, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 80, (some 80, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Algebra.Group.Units.«term_ˣ» `K "ˣ")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none, [anonymous]) <=? (some 50, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, term))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule
              [(patternIgnore (token.«← » "←"))]
              (Term.app
               `sum_sdiff
               [(Term.proj
                 (Term.typeAscription
                  "("
                  («term{_}» "{" [(num "0")] "}")
                  ":"
                  [(Term.app `Finset [`K])]
                  ")")
                 "."
                 `subset_univ)]))
             ","
             (Tactic.rwRule [] `sum_singleton)
             ","
             (Tactic.rwRule [] (Term.app `zero_pow [(Term.app `Nat.pos_of_ne_zero [`hi])]))
             ","
             (Tactic.rwRule [] `add_zero)]
            "]")
           [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule
          [(patternIgnore (token.«← » "←"))]
          (Term.app
           `sum_sdiff
           [(Term.proj
             (Term.typeAscription
              "("
              («term{_}» "{" [(num "0")] "}")
              ":"
              [(Term.app `Finset [`K])]
              ")")
             "."
             `subset_univ)]))
         ","
         (Tactic.rwRule [] `sum_singleton)
         ","
         (Tactic.rwRule [] (Term.app `zero_pow [(Term.app `Nat.pos_of_ne_zero [`hi])]))
         ","
         (Tactic.rwRule [] `add_zero)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `add_zero
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `zero_pow [(Term.app `Nat.pos_of_ne_zero [`hi])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Nat.pos_of_ne_zero [`hi])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hi
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Nat.pos_of_ne_zero
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `Nat.pos_of_ne_zero [`hi])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `zero_pow
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `sum_singleton
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `sum_sdiff
       [(Term.proj
         (Term.typeAscription "(" («term{_}» "{" [(num "0")] "}") ":" [(Term.app `Finset [`K])] ")")
         "."
         `subset_univ)])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.proj', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.proj', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj
       (Term.typeAscription "(" («term{_}» "{" [(num "0")] "}") ":" [(Term.app `Finset [`K])] ")")
       "."
       `subset_univ)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.typeAscription "(" («term{_}» "{" [(num "0")] "}") ":" [(Term.app `Finset [`K])] ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Finset [`K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Finset
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term{_}» "{" [(num "0")] "}")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "0")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `sum_sdiff
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_»
       (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
        "∑"
        (Std.ExtendedBinder.extBinders
         (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) [(group ":" `K)]))
        ", "
        («term_^_» `x "^" `i))
       "="
       (BigOperators.Algebra.BigOperators.Basic.finset.sum
        "∑"
        (Std.ExtendedBinder.extBinders (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) []))
        " in "
        («term_\_»
         `univ
         "\\"
         («term{_}» "{" [(Term.typeAscription "(" (num "0") ":" [`K] ")")] "}"))
        ", "
        («term_^_» `x "^" `i)))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (BigOperators.Algebra.BigOperators.Basic.finset.sum
       "∑"
       (Std.ExtendedBinder.extBinders (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) []))
       " in "
       («term_\_» `univ "\\" («term{_}» "{" [(Term.typeAscription "(" (num "0") ":" [`K] ")")] "}"))
       ", "
       («term_^_» `x "^" `i))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_^_» `x "^" `i)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 80 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      `x
[PrettyPrinter.parenthesize] ...precedences are 81 >? 1024, (none, [anonymous]) <=? (some 80, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 80, (some 80, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_\_» `univ "\\" («term{_}» "{" [(Term.typeAscription "(" (num "0") ":" [`K] ")")] "}"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term{_}» "{" [(Term.typeAscription "(" (num "0") ":" [`K] ")")] "}")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.typeAscription "(" (num "0") ":" [`K] ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "0")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 71 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 70, term))
      `univ
[PrettyPrinter.parenthesize] ...precedences are 71 >? 1024, (none, [anonymous]) <=? (some 70, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 70, (some 71, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
       "∑"
       (Std.ExtendedBinder.extBinders
        (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) [(group ":" `K)]))
       ", "
       («term_^_» `x "^" `i))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_^_» `x "^" `i)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 80 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      `x
[PrettyPrinter.parenthesize] ...precedences are 81 >? 1024, (none, [anonymous]) <=? (some 80, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 80, (some 80, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1022, (some 0, term) <=? (some 50, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (BigOperators.Algebra.BigOperators.Basic.finset.sum_univ
      "∑"
      (Std.ExtendedBinder.extBinders
       (Std.ExtendedBinder.extBinder (Lean.binderIdent `x) [(group ":" `K)]))
      ", "
      («term_^_» `x "^" `i))
     ")")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticHave_
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec
           ":"
           («term_=_»
            (Term.app `univ.map [`φ])
            "="
            («term_\_» `univ "\\" («term{_}» "{" [(num "0")] "}"))))]
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Std.Tactic.Ext.«tacticExt___:_»
              "ext"
              [(Std.Tactic.RCases.rintroPat.one (Std.Tactic.RCases.rcasesPat.one `x))]
              [])
             []
             (Tactic.simp
              "simp"
              []
              []
              ["only"]
              ["["
               [(Tactic.simpLemma [] [] `true_and_iff)
                ","
                (Tactic.simpLemma [] [] `embedding.coe_fn_mk)
                ","
                (Tactic.simpLemma [] [] `mem_sdiff)
                ","
                (Tactic.simpLemma [] [] `Units.exists_iff_ne_zero)
                ","
                (Tactic.simpLemma [] [] `mem_univ)
                ","
                (Tactic.simpLemma [] [] `mem_map)
                ","
                (Tactic.simpLemma [] [] `exists_prop_of_true)
                ","
                (Tactic.simpLemma [] [] `mem_singleton)]
               "]"]
              [])]))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Std.Tactic.Ext.«tacticExt___:_»
           "ext"
           [(Std.Tactic.RCases.rintroPat.one (Std.Tactic.RCases.rcasesPat.one `x))]
           [])
          []
          (Tactic.simp
           "simp"
           []
           []
           ["only"]
           ["["
            [(Tactic.simpLemma [] [] `true_and_iff)
             ","
             (Tactic.simpLemma [] [] `embedding.coe_fn_mk)
             ","
             (Tactic.simpLemma [] [] `mem_sdiff)
             ","
             (Tactic.simpLemma [] [] `Units.exists_iff_ne_zero)
             ","
             (Tactic.simpLemma [] [] `mem_univ)
             ","
             (Tactic.simpLemma [] [] `mem_map)
             ","
             (Tactic.simpLemma [] [] `exists_prop_of_true)
             ","
             (Tactic.simpLemma [] [] `mem_singleton)]
            "]"]
           [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.simp
       "simp"
       []
       []
       ["only"]
       ["["
        [(Tactic.simpLemma [] [] `true_and_iff)
         ","
         (Tactic.simpLemma [] [] `embedding.coe_fn_mk)
         ","
         (Tactic.simpLemma [] [] `mem_sdiff)
         ","
         (Tactic.simpLemma [] [] `Units.exists_iff_ne_zero)
         ","
         (Tactic.simpLemma [] [] `mem_univ)
         ","
         (Tactic.simpLemma [] [] `mem_map)
         ","
         (Tactic.simpLemma [] [] `exists_prop_of_true)
         ","
         (Tactic.simpLemma [] [] `mem_singleton)]
        "]"]
       [])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mem_singleton
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `exists_prop_of_true
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mem_map
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mem_univ
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Units.exists_iff_ne_zero
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mem_sdiff
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `embedding.coe_fn_mk
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `true_and_iff
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.Ext.«tacticExt___:_»
       "ext"
       [(Std.Tactic.RCases.rintroPat.one (Std.Tactic.RCases.rcasesPat.one `x))]
       [])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_»
       (Term.app `univ.map [`φ])
       "="
       («term_\_» `univ "\\" («term{_}» "{" [(num "0")] "}")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_\_» `univ "\\" («term{_}» "{" [(num "0")] "}"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term{_}» "{" [(num "0")] "}")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "0")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 71 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 70, term))
      `univ
[PrettyPrinter.parenthesize] ...precedences are 71 >? 1024, (none, [anonymous]) <=? (some 70, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 70, (some 71, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Term.app `univ.map [`φ])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `φ
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `univ.map
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1022, (some 1023, term) <=? (some 50, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 51, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticLet_
       "let"
       (Term.letDecl
        (Term.letIdDecl
         `φ
         []
         [(Term.typeSpec
           ":"
           (Function.Logic.Embedding.Basic.«term_↪_»
            (Algebra.Group.Units.«term_ˣ» `K "ˣ")
            " ↪ "
            `K))]
         ":="
         (Term.anonymousCtor "⟨" [`coe "," `Units.ext] "⟩"))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [`coe "," `Units.ext] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Units.ext
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `coe
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Function.Logic.Embedding.Basic.«term_↪_» (Algebra.Group.Units.«term_ˣ» `K "ˣ") " ↪ " `K)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 25 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 25, term))
      (Algebra.Group.Units.«term_ˣ» `K "ˣ")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 26 >? 1024, (none, [anonymous]) <=? (some 25, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 25, (some 25, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticHave_
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         [`hiq []]
         [(Term.typeSpec
           ":"
           («term¬_»
            "¬"
            («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)))]
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Mathlib.Tactic.Contrapose.contrapose! "contrapose!" [`h []])
             []
             (Tactic.exact
              "exact"
              (Term.app `Nat.le_of_dvd [(Term.app `Nat.pos_of_ne_zero [`hi]) `h]))]))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Mathlib.Tactic.Contrapose.contrapose! "contrapose!" [`h []])
          []
          (Tactic.exact
           "exact"
           (Term.app `Nat.le_of_dvd [(Term.app `Nat.pos_of_ne_zero [`hi]) `h]))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact "exact" (Term.app `Nat.le_of_dvd [(Term.app `Nat.pos_of_ne_zero [`hi]) `h]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Nat.le_of_dvd [(Term.app `Nat.pos_of_ne_zero [`hi]) `h])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `Nat.pos_of_ne_zero [`hi])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hi
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Nat.pos_of_ne_zero
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `Nat.pos_of_ne_zero [`hi])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Nat.le_of_dvd
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Mathlib.Tactic.Contrapose.contrapose! "contrapose!" [`h []])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term¬_»
       "¬"
       («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_∣_» («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1")) "∣" `i)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      («term_-_» (FieldTheory.Finite.Basic.termq "q") "-" (num "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "1")
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.haveIdDecl', expected 'Lean.Parser.Term.letPatDecl'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.haveIdDecl', expected 'Lean.Parser.Term.haveEqnsDecl'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
/--
    The sum of `x ^ i` as `x` ranges over a finite field of cardinality `q`
    is equal to `0` if `i < q - 1`. -/
  theorem
    sum_pow_lt_card_sub_one
    ( i : ℕ ) ( h : i < q - 1 ) : ∑ x : K , x ^ i = 0
    :=
      by
        by_cases hi : i = 0
          · simp only [ hi , nsmul_one , sum_const , pow_zero , card_univ , cast_card_eq_zero ]
          classical
            have hiq : ¬ q - 1 ∣ i := by contrapose! h exact Nat.le_of_dvd Nat.pos_of_ne_zero hi h
              let φ : K ˣ ↪ K := ⟨ coe , Units.ext ⟩
              have
                : univ.map φ = univ \ { 0 }
                  :=
                  by
                    ext x
                      simp
                        only
                        [
                          true_and_iff
                            ,
                            embedding.coe_fn_mk
                            ,
                            mem_sdiff
                            ,
                            Units.exists_iff_ne_zero
                            ,
                            mem_univ
                            ,
                            mem_map
                            ,
                            exists_prop_of_true
                            ,
                            mem_singleton
                          ]
              calc
                ∑ x : K , x ^ i = ∑ x in univ \ { ( 0 : K ) } , x ^ i
                  :=
                  by
                    rw
                      [
                        ← sum_sdiff ( { 0 } : Finset K ) . subset_univ
                          ,
                          sum_singleton
                          ,
                          zero_pow Nat.pos_of_ne_zero hi
                          ,
                          add_zero
                        ]
                _ = ∑ x : K ˣ , x ^ i := by rw [ ← this , univ.sum_map φ ] rfl
                  _ = 0 := by rw [ sum_pow_units K i , if_neg ] exact hiq
#align finite_field.sum_pow_lt_card_sub_one FiniteField.sum_pow_lt_card_sub_one

section IsSplittingField

open Polynomial

section

variable (K' : Type _) [Field K'] {p n : ℕ}

theorem X_pow_card_sub_X_nat_degree_eq (hp : 1 < p) : (X ^ p - X : K'[X]).natDegree = p :=
  by
  have h1 : (X : K'[X]).degree < (X ^ p : K'[X]).degree :=
    by
    rw [degree_X_pow, degree_X]
    exact_mod_cast hp
  rw [nat_degree_eq_of_degree_eq (degree_sub_eq_left_of_degree_lt h1), nat_degree_X_pow]
#align finite_field.X_pow_card_sub_X_nat_degree_eq FiniteField.X_pow_card_sub_X_nat_degree_eq

theorem X_pow_card_pow_sub_X_nat_degree_eq (hn : n ≠ 0) (hp : 1 < p) :
    (X ^ p ^ n - X : K'[X]).natDegree = p ^ n :=
  X_pow_card_sub_X_nat_degree_eq K' <| Nat.one_lt_pow _ _ (Nat.pos_of_ne_zero hn) hp
#align
  finite_field.X_pow_card_pow_sub_X_nat_degree_eq FiniteField.X_pow_card_pow_sub_X_nat_degree_eq

theorem X_pow_card_sub_X_ne_zero (hp : 1 < p) : (X ^ p - X : K'[X]) ≠ 0 :=
  ne_zero_of_nat_degree_gt <|
    calc
      1 < _ := hp
      _ = _ := (X_pow_card_sub_X_nat_degree_eq K' hp).symm
      
#align finite_field.X_pow_card_sub_X_ne_zero FiniteField.X_pow_card_sub_X_ne_zero

theorem X_pow_card_pow_sub_X_ne_zero (hn : n ≠ 0) (hp : 1 < p) : (X ^ p ^ n - X : K'[X]) ≠ 0 :=
  X_pow_card_sub_X_ne_zero K' <| Nat.one_lt_pow _ _ (Nat.pos_of_ne_zero hn) hp
#align finite_field.X_pow_card_pow_sub_X_ne_zero FiniteField.X_pow_card_pow_sub_X_ne_zero

end

variable (p : ℕ) [Fact p.Prime] [Algebra (Zmod p) K]

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `roots_X_pow_card_sub_X [])
      (Command.declSig
       []
       (Term.typeSpec
        ":"
        («term_=_»
         (Term.app
          `roots
          [(Term.typeAscription
            "("
            («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
            ":"
            [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
            ")")])
         "="
         (Term.proj `Finset.univ "." `val))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Mathlib.Tactic.tacticClassical_
            "classical"
            (Tactic.tacticSeq
             (Tactic.tacticSeq1Indented
              [(Tactic.tacticHave_
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  [`aux []]
                  [(Term.typeSpec
                    ":"
                    («term_≠_»
                     (Term.typeAscription
                      "("
                      («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                      ":"
                      [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                      ")")
                     "≠"
                     (num "0")))]
                  ":="
                  (Term.app `X_pow_card_sub_X_ne_zero [`K `Fintype.one_lt_card]))))
               []
               (Tactic.tacticHave_
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  []
                  [(Term.typeSpec
                    ":"
                    («term_=_»
                     (Term.proj
                      (Term.app
                       `roots
                       [(Term.typeAscription
                         "("
                         («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                         ":"
                         [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                         ")")])
                      "."
                      `toFinset)
                     "="
                     `Finset.univ))]
                  ":="
                  (Term.byTactic
                   "by"
                   (Tactic.tacticSeq
                    (Tactic.tacticSeq1Indented
                     [(Tactic.rwSeq
                       "rw"
                       []
                       (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `eq_univ_iff_forall)] "]")
                       [])
                      []
                      (Tactic.intro "intro" [`x])
                      []
                      (Tactic.rwSeq
                       "rw"
                       []
                       (Tactic.rwRuleSeq
                        "["
                        [(Tactic.rwRule [] `Multiset.mem_to_finset)
                         ","
                         (Tactic.rwRule [] (Term.app `mem_roots [`aux]))
                         ","
                         (Tactic.rwRule [] `is_root.def)
                         ","
                         (Tactic.rwRule [] `eval_sub)
                         ","
                         (Tactic.rwRule [] `eval_pow)
                         ","
                         (Tactic.rwRule [] `eval_X)
                         ","
                         (Tactic.rwRule [] `sub_eq_zero)
                         ","
                         (Tactic.rwRule [] `pow_card)]
                        "]")
                       [])]))))))
               []
               (Tactic.rwSeq
                "rw"
                []
                (Tactic.rwRuleSeq
                 "["
                 [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
                  ","
                  (Tactic.rwRule [] `Multiset.to_finset_val)
                  ","
                  (Tactic.rwRule [] `eq_comm)
                  ","
                  (Tactic.rwRule [] `Multiset.dedup_eq_self)]
                 "]")
                [])
               []
               (Tactic.apply "apply" `nodup_roots)
               []
               (Tactic.rwSeq
                "rw"
                []
                (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `separable_def)] "]")
                [])
               []
               (convert "convert" [] `is_coprime_one_right.neg_right ["using" (num "1")])
               []
               (tactic__
                (cdotTk (patternIgnore (token.«· » "·")))
                [(Tactic.rwSeq
                  "rw"
                  []
                  (Tactic.rwRuleSeq
                   "["
                   [(Tactic.rwRule [] `derivative_sub)
                    ","
                    (Tactic.rwRule [] `derivative_X)
                    ","
                    (Tactic.rwRule [] `derivative_X_pow)
                    ","
                    (Tactic.rwRule [] (Term.app `CharP.cast_card_eq_zero [`K]))
                    ","
                    (Tactic.rwRule [] `C_0)
                    ","
                    (Tactic.rwRule [] `zero_mul)
                    ","
                    (Tactic.rwRule [] `zero_sub)]
                   "]")
                  [])])])))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Mathlib.Tactic.tacticClassical_
           "classical"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Tactic.tacticHave_
               "have"
               (Term.haveDecl
                (Term.haveIdDecl
                 [`aux []]
                 [(Term.typeSpec
                   ":"
                   («term_≠_»
                    (Term.typeAscription
                     "("
                     («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                     ":"
                     [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                     ")")
                    "≠"
                    (num "0")))]
                 ":="
                 (Term.app `X_pow_card_sub_X_ne_zero [`K `Fintype.one_lt_card]))))
              []
              (Tactic.tacticHave_
               "have"
               (Term.haveDecl
                (Term.haveIdDecl
                 []
                 [(Term.typeSpec
                   ":"
                   («term_=_»
                    (Term.proj
                     (Term.app
                      `roots
                      [(Term.typeAscription
                        "("
                        («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                        ":"
                        [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                        ")")])
                     "."
                     `toFinset)
                    "="
                    `Finset.univ))]
                 ":="
                 (Term.byTactic
                  "by"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Tactic.rwSeq
                      "rw"
                      []
                      (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `eq_univ_iff_forall)] "]")
                      [])
                     []
                     (Tactic.intro "intro" [`x])
                     []
                     (Tactic.rwSeq
                      "rw"
                      []
                      (Tactic.rwRuleSeq
                       "["
                       [(Tactic.rwRule [] `Multiset.mem_to_finset)
                        ","
                        (Tactic.rwRule [] (Term.app `mem_roots [`aux]))
                        ","
                        (Tactic.rwRule [] `is_root.def)
                        ","
                        (Tactic.rwRule [] `eval_sub)
                        ","
                        (Tactic.rwRule [] `eval_pow)
                        ","
                        (Tactic.rwRule [] `eval_X)
                        ","
                        (Tactic.rwRule [] `sub_eq_zero)
                        ","
                        (Tactic.rwRule [] `pow_card)]
                       "]")
                      [])]))))))
              []
              (Tactic.rwSeq
               "rw"
               []
               (Tactic.rwRuleSeq
                "["
                [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
                 ","
                 (Tactic.rwRule [] `Multiset.to_finset_val)
                 ","
                 (Tactic.rwRule [] `eq_comm)
                 ","
                 (Tactic.rwRule [] `Multiset.dedup_eq_self)]
                "]")
               [])
              []
              (Tactic.apply "apply" `nodup_roots)
              []
              (Tactic.rwSeq
               "rw"
               []
               (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `separable_def)] "]")
               [])
              []
              (convert "convert" [] `is_coprime_one_right.neg_right ["using" (num "1")])
              []
              (tactic__
               (cdotTk (patternIgnore (token.«· » "·")))
               [(Tactic.rwSeq
                 "rw"
                 []
                 (Tactic.rwRuleSeq
                  "["
                  [(Tactic.rwRule [] `derivative_sub)
                   ","
                   (Tactic.rwRule [] `derivative_X)
                   ","
                   (Tactic.rwRule [] `derivative_X_pow)
                   ","
                   (Tactic.rwRule [] (Term.app `CharP.cast_card_eq_zero [`K]))
                   ","
                   (Tactic.rwRule [] `C_0)
                   ","
                   (Tactic.rwRule [] `zero_mul)
                   ","
                   (Tactic.rwRule [] `zero_sub)]
                  "]")
                 [])])])))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Mathlib.Tactic.tacticClassical_
       "classical"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.tacticHave_
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             [`aux []]
             [(Term.typeSpec
               ":"
               («term_≠_»
                (Term.typeAscription
                 "("
                 («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                 ":"
                 [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                 ")")
                "≠"
                (num "0")))]
             ":="
             (Term.app `X_pow_card_sub_X_ne_zero [`K `Fintype.one_lt_card]))))
          []
          (Tactic.tacticHave_
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec
               ":"
               («term_=_»
                (Term.proj
                 (Term.app
                  `roots
                  [(Term.typeAscription
                    "("
                    («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                    ":"
                    [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                    ")")])
                 "."
                 `toFinset)
                "="
                `Finset.univ))]
             ":="
             (Term.byTactic
              "by"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Tactic.rwSeq
                  "rw"
                  []
                  (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `eq_univ_iff_forall)] "]")
                  [])
                 []
                 (Tactic.intro "intro" [`x])
                 []
                 (Tactic.rwSeq
                  "rw"
                  []
                  (Tactic.rwRuleSeq
                   "["
                   [(Tactic.rwRule [] `Multiset.mem_to_finset)
                    ","
                    (Tactic.rwRule [] (Term.app `mem_roots [`aux]))
                    ","
                    (Tactic.rwRule [] `is_root.def)
                    ","
                    (Tactic.rwRule [] `eval_sub)
                    ","
                    (Tactic.rwRule [] `eval_pow)
                    ","
                    (Tactic.rwRule [] `eval_X)
                    ","
                    (Tactic.rwRule [] `sub_eq_zero)
                    ","
                    (Tactic.rwRule [] `pow_card)]
                   "]")
                  [])]))))))
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
             ","
             (Tactic.rwRule [] `Multiset.to_finset_val)
             ","
             (Tactic.rwRule [] `eq_comm)
             ","
             (Tactic.rwRule [] `Multiset.dedup_eq_self)]
            "]")
           [])
          []
          (Tactic.apply "apply" `nodup_roots)
          []
          (Tactic.rwSeq "rw" [] (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `separable_def)] "]") [])
          []
          (convert "convert" [] `is_coprime_one_right.neg_right ["using" (num "1")])
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] `derivative_sub)
               ","
               (Tactic.rwRule [] `derivative_X)
               ","
               (Tactic.rwRule [] `derivative_X_pow)
               ","
               (Tactic.rwRule [] (Term.app `CharP.cast_card_eq_zero [`K]))
               ","
               (Tactic.rwRule [] `C_0)
               ","
               (Tactic.rwRule [] `zero_mul)
               ","
               (Tactic.rwRule [] `zero_sub)]
              "]")
             [])])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__
       (cdotTk (patternIgnore (token.«· » "·")))
       [(Tactic.rwSeq
         "rw"
         []
         (Tactic.rwRuleSeq
          "["
          [(Tactic.rwRule [] `derivative_sub)
           ","
           (Tactic.rwRule [] `derivative_X)
           ","
           (Tactic.rwRule [] `derivative_X_pow)
           ","
           (Tactic.rwRule [] (Term.app `CharP.cast_card_eq_zero [`K]))
           ","
           (Tactic.rwRule [] `C_0)
           ","
           (Tactic.rwRule [] `zero_mul)
           ","
           (Tactic.rwRule [] `zero_sub)]
          "]")
         [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] `derivative_sub)
         ","
         (Tactic.rwRule [] `derivative_X)
         ","
         (Tactic.rwRule [] `derivative_X_pow)
         ","
         (Tactic.rwRule [] (Term.app `CharP.cast_card_eq_zero [`K]))
         ","
         (Tactic.rwRule [] `C_0)
         ","
         (Tactic.rwRule [] `zero_mul)
         ","
         (Tactic.rwRule [] `zero_sub)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `zero_sub
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `zero_mul
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `C_0
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `CharP.cast_card_eq_zero [`K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `CharP.cast_card_eq_zero
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `derivative_X_pow
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `derivative_X
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `derivative_sub
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (convert "convert" [] `is_coprime_one_right.neg_right ["using" (num "1")])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `is_coprime_one_right.neg_right
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq "rw" [] (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `separable_def)] "]") [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `separable_def
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.apply "apply" `nodup_roots)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `nodup_roots
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `this)
         ","
         (Tactic.rwRule [] `Multiset.to_finset_val)
         ","
         (Tactic.rwRule [] `eq_comm)
         ","
         (Tactic.rwRule [] `Multiset.dedup_eq_self)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Multiset.dedup_eq_self
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `eq_comm
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Multiset.to_finset_val
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `this
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticHave_
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec
           ":"
           («term_=_»
            (Term.proj
             (Term.app
              `roots
              [(Term.typeAscription
                "("
                («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                ":"
                [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                ")")])
             "."
             `toFinset)
            "="
            `Finset.univ))]
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Tactic.rwSeq
              "rw"
              []
              (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `eq_univ_iff_forall)] "]")
              [])
             []
             (Tactic.intro "intro" [`x])
             []
             (Tactic.rwSeq
              "rw"
              []
              (Tactic.rwRuleSeq
               "["
               [(Tactic.rwRule [] `Multiset.mem_to_finset)
                ","
                (Tactic.rwRule [] (Term.app `mem_roots [`aux]))
                ","
                (Tactic.rwRule [] `is_root.def)
                ","
                (Tactic.rwRule [] `eval_sub)
                ","
                (Tactic.rwRule [] `eval_pow)
                ","
                (Tactic.rwRule [] `eval_X)
                ","
                (Tactic.rwRule [] `sub_eq_zero)
                ","
                (Tactic.rwRule [] `pow_card)]
               "]")
              [])]))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `eq_univ_iff_forall)] "]")
           [])
          []
          (Tactic.intro "intro" [`x])
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] `Multiset.mem_to_finset)
             ","
             (Tactic.rwRule [] (Term.app `mem_roots [`aux]))
             ","
             (Tactic.rwRule [] `is_root.def)
             ","
             (Tactic.rwRule [] `eval_sub)
             ","
             (Tactic.rwRule [] `eval_pow)
             ","
             (Tactic.rwRule [] `eval_X)
             ","
             (Tactic.rwRule [] `sub_eq_zero)
             ","
             (Tactic.rwRule [] `pow_card)]
            "]")
           [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] `Multiset.mem_to_finset)
         ","
         (Tactic.rwRule [] (Term.app `mem_roots [`aux]))
         ","
         (Tactic.rwRule [] `is_root.def)
         ","
         (Tactic.rwRule [] `eval_sub)
         ","
         (Tactic.rwRule [] `eval_pow)
         ","
         (Tactic.rwRule [] `eval_X)
         ","
         (Tactic.rwRule [] `sub_eq_zero)
         ","
         (Tactic.rwRule [] `pow_card)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_card
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `sub_eq_zero
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `eval_X
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `eval_pow
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `eval_sub
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `is_root.def
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `mem_roots [`aux])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `aux
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `mem_roots
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Multiset.mem_to_finset
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.intro "intro" [`x])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `x
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq "rw" [] (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `eq_univ_iff_forall)] "]") [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `eq_univ_iff_forall
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_»
       (Term.proj
        (Term.app
         `roots
         [(Term.typeAscription
           "("
           («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
           ":"
           [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
           ")")])
        "."
        `toFinset)
       "="
       `Finset.univ)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Finset.univ
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Term.proj
       (Term.app
        `roots
        [(Term.typeAscription
          "("
          («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
          ":"
          [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
          ")")])
       "."
       `toFinset)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app
       `roots
       [(Term.typeAscription
         "("
         («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
         ":"
         [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
         ")")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.typeAscription', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.typeAscription', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.typeAscription
       "("
       («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
       ":"
       [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
       ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 9000, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 9000, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 9000, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `X
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.haveIdDecl', expected 'Lean.Parser.Term.letPatDecl'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.haveIdDecl', expected 'Lean.Parser.Term.haveEqnsDecl'
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
  roots_X_pow_card_sub_X
  : roots ( X ^ q - X : K [X] ) = Finset.univ . val
  :=
    by
      classical
        have aux : ( X ^ q - X : K [X] ) ≠ 0 := X_pow_card_sub_X_ne_zero K Fintype.one_lt_card
          have
            : roots ( X ^ q - X : K [X] ) . toFinset = Finset.univ
              :=
              by
                rw [ eq_univ_iff_forall ]
                  intro x
                  rw
                    [
                      Multiset.mem_to_finset
                        ,
                        mem_roots aux
                        ,
                        is_root.def
                        ,
                        eval_sub
                        ,
                        eval_pow
                        ,
                        eval_X
                        ,
                        sub_eq_zero
                        ,
                        pow_card
                      ]
          rw [ ← this , Multiset.to_finset_val , eq_comm , Multiset.dedup_eq_self ]
          apply nodup_roots
          rw [ separable_def ]
          convert is_coprime_one_right.neg_right using 1
          ·
            rw
              [
                derivative_sub
                  ,
                  derivative_X
                  ,
                  derivative_X_pow
                  ,
                  CharP.cast_card_eq_zero K
                  ,
                  C_0
                  ,
                  zero_mul
                  ,
                  zero_sub
                ]
#align finite_field.roots_X_pow_card_sub_X FiniteField.roots_X_pow_card_sub_X

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.instance
      (Term.attrKind [])
      "instance"
      []
      []
      (Command.declSig
       [(Term.explicitBinder "(" [`F] [":" (Term.type "Type" [(Level.hole "_")])] [] ")")
        (Term.instBinder "[" [] (Term.app `Field [`F]) "]")
        (Term.instBinder "[" [] (Term.app `Algebra [`F `K]) "]")]
       (Term.typeSpec
        ":"
        (Term.app
         `IsSplittingField
         [`F `K («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)])))
      (Command.whereStructInst
       "where"
       [(Command.whereStructField
         (Term.letDecl
          (Term.letIdDecl
           `Splits
           []
           []
           ":="
           (Term.byTactic
            "by"
            (Tactic.tacticSeq
             (Tactic.tacticSeq1Indented
              [(Tactic.tacticHave_
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  [`h []]
                  [(Term.typeSpec
                    ":"
                    («term_=_»
                     (Term.proj
                      (Term.typeAscription
                       "("
                       («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                       ":"
                       [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                       ")")
                      "."
                      `natDegree)
                     "="
                     (FieldTheory.Finite.Basic.termq "q")))]
                  ":="
                  (Term.app `X_pow_card_sub_X_nat_degree_eq [`K `Fintype.one_lt_card]))))
               []
               (Tactic.rwSeq
                "rw"
                []
                (Tactic.rwRuleSeq
                 "["
                 [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `splits_id_iff_splits)
                  ","
                  (Tactic.rwRule [] `splits_iff_card_roots)
                  ","
                  (Tactic.rwRule [] `Polynomial.map_sub)
                  ","
                  (Tactic.rwRule [] `Polynomial.map_pow)
                  ","
                  (Tactic.rwRule [] `map_X)
                  ","
                  (Tactic.rwRule [] `h)
                  ","
                  (Tactic.rwRule [] (Term.app `roots_X_pow_card_sub_X [`K]))
                  ","
                  (Tactic.rwRule [(patternIgnore (token.«← » "←"))] `Finset.card_def)
                  ","
                  (Tactic.rwRule [] `Finset.card_univ)]
                 "]")
                [])]))))))
        []
        (Command.whereStructField
         (Term.letDecl
          (Term.letIdDecl
           `adjoin_roots
           []
           []
           ":="
           (Term.byTactic
            "by"
            (Tactic.tacticSeq
             (Tactic.tacticSeq1Indented
              [(Mathlib.Tactic.tacticClassical_
                "classical"
                (Tactic.tacticSeq
                 (Tactic.tacticSeq1Indented
                  [(Mathlib.Tactic.tacticTrans___
                    "trans"
                    [(Term.app
                      `Algebra.adjoin
                      [`F
                       (Term.typeAscription
                        "("
                        (Term.proj
                         (Term.app
                          `roots
                          [(Term.typeAscription
                            "("
                            («term_-_»
                             («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q"))
                             "-"
                             `X)
                            ":"
                            [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                            ")")])
                         "."
                         `toFinset)
                        ":"
                        [(Term.app `Set [`K])]
                        ")")])])
                   []
                   (tactic__
                    (cdotTk (patternIgnore (token.«· » "·")))
                    [(Tactic.simp
                      "simp"
                      []
                      []
                      ["only"]
                      ["["
                       [(Tactic.simpLemma [] [] `Polynomial.map_pow)
                        ","
                        (Tactic.simpLemma [] [] `map_X)
                        ","
                        (Tactic.simpLemma [] [] `Polynomial.map_sub)]
                       "]"]
                      [])])
                   []
                   (tactic__
                    (cdotTk (patternIgnore (token.«· » "·")))
                    [(Tactic.rwSeq
                      "rw"
                      []
                      (Tactic.rwRuleSeq
                       "["
                       [(Tactic.rwRule [] `roots_X_pow_card_sub_X)
                        ","
                        (Tactic.rwRule [] `val_to_finset)
                        ","
                        (Tactic.rwRule [] `coe_univ)
                        ","
                        (Tactic.rwRule [] `Algebra.adjoin_univ)]
                       "]")
                      [])])])))]))))))]
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.theorem'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.whereStructInst', expected 'Lean.Parser.Command.declValSimple'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.whereStructInst', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Mathlib.Tactic.tacticClassical_
           "classical"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Mathlib.Tactic.tacticTrans___
               "trans"
               [(Term.app
                 `Algebra.adjoin
                 [`F
                  (Term.typeAscription
                   "("
                   (Term.proj
                    (Term.app
                     `roots
                     [(Term.typeAscription
                       "("
                       («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                       ":"
                       [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                       ")")])
                    "."
                    `toFinset)
                   ":"
                   [(Term.app `Set [`K])]
                   ")")])])
              []
              (tactic__
               (cdotTk (patternIgnore (token.«· » "·")))
               [(Tactic.simp
                 "simp"
                 []
                 []
                 ["only"]
                 ["["
                  [(Tactic.simpLemma [] [] `Polynomial.map_pow)
                   ","
                   (Tactic.simpLemma [] [] `map_X)
                   ","
                   (Tactic.simpLemma [] [] `Polynomial.map_sub)]
                  "]"]
                 [])])
              []
              (tactic__
               (cdotTk (patternIgnore (token.«· » "·")))
               [(Tactic.rwSeq
                 "rw"
                 []
                 (Tactic.rwRuleSeq
                  "["
                  [(Tactic.rwRule [] `roots_X_pow_card_sub_X)
                   ","
                   (Tactic.rwRule [] `val_to_finset)
                   ","
                   (Tactic.rwRule [] `coe_univ)
                   ","
                   (Tactic.rwRule [] `Algebra.adjoin_univ)]
                  "]")
                 [])])])))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Mathlib.Tactic.tacticClassical_
       "classical"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Mathlib.Tactic.tacticTrans___
           "trans"
           [(Term.app
             `Algebra.adjoin
             [`F
              (Term.typeAscription
               "("
               (Term.proj
                (Term.app
                 `roots
                 [(Term.typeAscription
                   "("
                   («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
                   ":"
                   [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
                   ")")])
                "."
                `toFinset)
               ":"
               [(Term.app `Set [`K])]
               ")")])])
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.simp
             "simp"
             []
             []
             ["only"]
             ["["
              [(Tactic.simpLemma [] [] `Polynomial.map_pow)
               ","
               (Tactic.simpLemma [] [] `map_X)
               ","
               (Tactic.simpLemma [] [] `Polynomial.map_sub)]
              "]"]
             [])])
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] `roots_X_pow_card_sub_X)
               ","
               (Tactic.rwRule [] `val_to_finset)
               ","
               (Tactic.rwRule [] `coe_univ)
               ","
               (Tactic.rwRule [] `Algebra.adjoin_univ)]
              "]")
             [])])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__
       (cdotTk (patternIgnore (token.«· » "·")))
       [(Tactic.rwSeq
         "rw"
         []
         (Tactic.rwRuleSeq
          "["
          [(Tactic.rwRule [] `roots_X_pow_card_sub_X)
           ","
           (Tactic.rwRule [] `val_to_finset)
           ","
           (Tactic.rwRule [] `coe_univ)
           ","
           (Tactic.rwRule [] `Algebra.adjoin_univ)]
          "]")
         [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] `roots_X_pow_card_sub_X)
         ","
         (Tactic.rwRule [] `val_to_finset)
         ","
         (Tactic.rwRule [] `coe_univ)
         ","
         (Tactic.rwRule [] `Algebra.adjoin_univ)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Algebra.adjoin_univ
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `coe_univ
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `val_to_finset
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `roots_X_pow_card_sub_X
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__
       (cdotTk (patternIgnore (token.«· » "·")))
       [(Tactic.simp
         "simp"
         []
         []
         ["only"]
         ["["
          [(Tactic.simpLemma [] [] `Polynomial.map_pow)
           ","
           (Tactic.simpLemma [] [] `map_X)
           ","
           (Tactic.simpLemma [] [] `Polynomial.map_sub)]
          "]"]
         [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.simp
       "simp"
       []
       []
       ["only"]
       ["["
        [(Tactic.simpLemma [] [] `Polynomial.map_pow)
         ","
         (Tactic.simpLemma [] [] `map_X)
         ","
         (Tactic.simpLemma [] [] `Polynomial.map_sub)]
        "]"]
       [])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Polynomial.map_sub
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `map_X
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Polynomial.map_pow
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Mathlib.Tactic.tacticTrans___
       "trans"
       [(Term.app
         `Algebra.adjoin
         [`F
          (Term.typeAscription
           "("
           (Term.proj
            (Term.app
             `roots
             [(Term.typeAscription
               "("
               («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
               ":"
               [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
               ")")])
            "."
            `toFinset)
           ":"
           [(Term.app `Set [`K])]
           ")")])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `Algebra.adjoin
       [`F
        (Term.typeAscription
         "("
         (Term.proj
          (Term.app
           `roots
           [(Term.typeAscription
             "("
             («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
             ":"
             [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
             ")")])
          "."
          `toFinset)
         ":"
         [(Term.app `Set [`K])]
         ")")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.typeAscription', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.typeAscription', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.typeAscription
       "("
       (Term.proj
        (Term.app
         `roots
         [(Term.typeAscription
           "("
           («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
           ":"
           [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
           ")")])
        "."
        `toFinset)
       ":"
       [(Term.app `Set [`K])]
       ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Set [`K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Set
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj
       (Term.app
        `roots
        [(Term.typeAscription
          "("
          («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
          ":"
          [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
          ")")])
       "."
       `toFinset)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app
       `roots
       [(Term.typeAscription
         "("
         («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
         ":"
         [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
         ")")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.typeAscription', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.typeAscription', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.typeAscription
       "("
       («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
       ":"
       [(Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
       ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 9000, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 9000, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 9000, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_-_» («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q")) "-" `X)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `X
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      («term_^_» `X "^" (FieldTheory.Finite.Basic.termq "q"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.letIdDecl', expected 'Lean.Parser.Term.letPatDecl'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.letIdDecl', expected 'Lean.Parser.Term.letEqnsDecl'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
instance
  ( F : Type _ ) [ Field F ] [ Algebra F K ] : IsSplittingField F K X ^ q - X
  where
    Splits
        :=
        by
          have
              h
                : ( X ^ q - X : K [X] ) . natDegree = q
                :=
                X_pow_card_sub_X_nat_degree_eq K Fintype.one_lt_card
            rw
              [
                ← splits_id_iff_splits
                  ,
                  splits_iff_card_roots
                  ,
                  Polynomial.map_sub
                  ,
                  Polynomial.map_pow
                  ,
                  map_X
                  ,
                  h
                  ,
                  roots_X_pow_card_sub_X K
                  ,
                  ← Finset.card_def
                  ,
                  Finset.card_univ
                ]
      adjoin_roots
        :=
        by
          classical
            trans Algebra.adjoin F ( roots ( X ^ q - X : K [X] ) . toFinset : Set K )
              · simp only [ Polynomial.map_pow , map_X , Polynomial.map_sub ]
              · rw [ roots_X_pow_card_sub_X , val_to_finset , coe_univ , Algebra.adjoin_univ ]

end IsSplittingField

variable {K}

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `frobenius_pow [])
      (Command.declSig
       [(Term.implicitBinder "{" [`p] [":" (termℕ "ℕ")] "}")
        (Term.instBinder "[" [] (Term.app `Fact [(Term.proj `p "." `Prime)]) "]")
        (Term.instBinder "[" [] (Term.app `CharP [`K `p]) "]")
        (Term.implicitBinder "{" [`n] [":" (termℕ "ℕ")] "}")
        (Term.explicitBinder
         "("
         [`hcard]
         [":" («term_=_» (FieldTheory.Finite.Basic.termq "q") "=" («term_^_» `p "^" `n))]
         []
         ")")]
       (Term.typeSpec
        ":"
        («term_=_» («term_^_» (Term.app `frobenius [`K `p]) "^" `n) "=" (num "1"))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Std.Tactic.Ext.«tacticExt___:_» "ext" [] [])
           ";"
           (Mathlib.Tactic.Conv.convRHS
            "conv_rhs"
            []
            []
            "=>"
            (Tactic.Conv.convSeq
             (Tactic.Conv.convSeq1Indented
              [(Tactic.Conv.convRw__
                "rw"
                []
                (Tactic.rwRuleSeq
                 "["
                 [(Tactic.rwRule [] `RingHom.one_def)
                  ","
                  (Tactic.rwRule [] `RingHom.id_apply)
                  ","
                  (Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `pow_card [`x]))
                  ","
                  (Tactic.rwRule [] `hcard)]
                 "]"))])))
           ";"
           (Tactic.clear "clear" [`hcard])
           []
           (Tactic.induction "induction" [`n] [] [] [])
           ";"
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.simp "simp" [] [] [] [] [])])
           []
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule [] `pow_succ)
              ","
              (Tactic.rwRule [] `pow_succ')
              ","
              (Tactic.rwRule [] `pow_mul)
              ","
              (Tactic.rwRule [] `RingHom.mul_def)
              ","
              (Tactic.rwRule [] `RingHom.comp_apply)
              ","
              (Tactic.rwRule [] `frobenius_def)
              ","
              (Tactic.rwRule [] `n_ih)]
             "]")
            [])])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Std.Tactic.Ext.«tacticExt___:_» "ext" [] [])
          ";"
          (Mathlib.Tactic.Conv.convRHS
           "conv_rhs"
           []
           []
           "=>"
           (Tactic.Conv.convSeq
            (Tactic.Conv.convSeq1Indented
             [(Tactic.Conv.convRw__
               "rw"
               []
               (Tactic.rwRuleSeq
                "["
                [(Tactic.rwRule [] `RingHom.one_def)
                 ","
                 (Tactic.rwRule [] `RingHom.id_apply)
                 ","
                 (Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `pow_card [`x]))
                 ","
                 (Tactic.rwRule [] `hcard)]
                "]"))])))
          ";"
          (Tactic.clear "clear" [`hcard])
          []
          (Tactic.induction "induction" [`n] [] [] [])
          ";"
          (tactic__ (cdotTk (patternIgnore (token.«· » "·"))) [(Tactic.simp "simp" [] [] [] [] [])])
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] `pow_succ)
             ","
             (Tactic.rwRule [] `pow_succ')
             ","
             (Tactic.rwRule [] `pow_mul)
             ","
             (Tactic.rwRule [] `RingHom.mul_def)
             ","
             (Tactic.rwRule [] `RingHom.comp_apply)
             ","
             (Tactic.rwRule [] `frobenius_def)
             ","
             (Tactic.rwRule [] `n_ih)]
            "]")
           [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] `pow_succ)
         ","
         (Tactic.rwRule [] `pow_succ')
         ","
         (Tactic.rwRule [] `pow_mul)
         ","
         (Tactic.rwRule [] `RingHom.mul_def)
         ","
         (Tactic.rwRule [] `RingHom.comp_apply)
         ","
         (Tactic.rwRule [] `frobenius_def)
         ","
         (Tactic.rwRule [] `n_ih)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n_ih
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `frobenius_def
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `RingHom.comp_apply
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `RingHom.mul_def
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_mul
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_succ'
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `pow_succ
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__ (cdotTk (patternIgnore (token.«· » "·"))) [(Tactic.simp "simp" [] [] [] [] [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.simp "simp" [] [] [] [] [])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.induction "induction" [`n] [] [] [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.clear "clear" [`hcard])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hcard
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Mathlib.Tactic.Conv.convRHS
       "conv_rhs"
       []
       []
       "=>"
       (Tactic.Conv.convSeq
        (Tactic.Conv.convSeq1Indented
         [(Tactic.Conv.convRw__
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] `RingHom.one_def)
             ","
             (Tactic.rwRule [] `RingHom.id_apply)
             ","
             (Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `pow_card [`x]))
             ","
             (Tactic.rwRule [] `hcard)]
            "]"))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.Conv.convSeq1Indented', expected 'Lean.Parser.Tactic.Conv.convSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hcard
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `pow_card [`x])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `x
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `pow_card
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `RingHom.id_apply
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `RingHom.one_def
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.Ext.«tacticExt___:_» "ext" [] [])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_» («term_^_» (Term.app `frobenius [`K `p]) "^" `n) "=" (num "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (num "1")
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      («term_^_» (Term.app `frobenius [`K `p]) "^" `n)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 80 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      (Term.app `frobenius [`K `p])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `frobenius
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 81 >? 1022, (some 1023, term) <=? (some 80, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 80, (some 80, term) <=? (some 50, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 50, (some 51,
     term) <=? (some 1023, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.explicitBinder', expected 'ident'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.explicitBinder', expected 'Lean.Parser.Term.hole'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_=_» (FieldTheory.Finite.Basic.termq "q") "=" («term_^_» `p "^" `n))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_^_» `p "^" `n)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 80 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      `p
[PrettyPrinter.parenthesize] ...precedences are 81 >? 1024, (none, [anonymous]) <=? (some 80, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 80, (some 80, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.explicitBinder', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.explicitBinder', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.explicitBinder', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  frobenius_pow
  { p : ℕ } [ Fact p . Prime ] [ CharP K p ] { n : ℕ } ( hcard : q = p ^ n ) : frobenius K p ^ n = 1
  :=
    by
      ext
        ;
        conv_rhs => rw [ RingHom.one_def , RingHom.id_apply , ← pow_card x , hcard ]
        ;
        clear hcard
        induction n
        ;
        · simp
        rw
          [
            pow_succ
              ,
              pow_succ'
              ,
              pow_mul
              ,
              RingHom.mul_def
              ,
              RingHom.comp_apply
              ,
              frobenius_def
              ,
              n_ih
            ]
#align finite_field.frobenius_pow FiniteField.frobenius_pow

open Polynomial

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `expand_card [])
      (Command.declSig
       [(Term.explicitBinder
         "("
         [`f]
         [":" (Polynomial.Data.Polynomial.Basic.polynomial `K "[X]")]
         []
         ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         (Term.app `expand [`K (FieldTheory.Finite.Basic.termq "q") `f])
         "="
         («term_^_» `f "^" (FieldTheory.Finite.Basic.termq "q")))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.cases'
            "cases'"
            [(Tactic.casesTarget [] (Term.app `CharP.exists [`K]))]
            []
            ["with" [(Lean.binderIdent `p) (Lean.binderIdent `hp)]])
           []
           (Std.Tactic.tacticLetI_ "letI" (Term.haveDecl (Term.haveIdDecl [] [] ":=" `hp)))
           []
           (Std.Tactic.rcases
            "rcases"
            [(Tactic.casesTarget [] (Term.app `FiniteField.card [`K `p]))]
            ["with"
             (Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed
               [(Std.Tactic.RCases.rcasesPat.tuple
                 "⟨"
                 [(Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed
                    [(Std.Tactic.RCases.rcasesPat.tuple
                      "⟨"
                      [(Std.Tactic.RCases.rcasesPatLo
                        (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `n)])
                        [])
                       ","
                       (Std.Tactic.RCases.rcasesPatLo
                        (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `npos)])
                        [])]
                      "⟩")])
                   [])
                  ","
                  (Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed
                    [(Std.Tactic.RCases.rcasesPat.tuple
                      "⟨"
                      [(Std.Tactic.RCases.rcasesPatLo
                        (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hp)])
                        [])
                       ","
                       (Std.Tactic.RCases.rcasesPatLo
                        (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hn)])
                        [])]
                      "⟩")])
                   [])]
                 "⟩")])
              [])])
           []
           (Std.Tactic.tacticHaveI_
            "haveI"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec ":" (Term.app `Fact [`p.prime]))]
              ":="
              (Term.anonymousCtor "⟨" [`hp] "⟩"))))
           []
           (Tactic.dsimp "dsimp" [] [] [] [] [(Tactic.location "at" (Tactic.locationHyp [`hn] []))])
           []
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule [] `hn)
              ","
              (Tactic.rwRule [(patternIgnore (token.«← » "←"))] `map_expand_pow_char)
              ","
              (Tactic.rwRule [] (Term.app `frobenius_pow [`hn]))
              ","
              (Tactic.rwRule [] `RingHom.one_def)
              ","
              (Tactic.rwRule [] `map_id)]
             "]")
            [])])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.cases'
           "cases'"
           [(Tactic.casesTarget [] (Term.app `CharP.exists [`K]))]
           []
           ["with" [(Lean.binderIdent `p) (Lean.binderIdent `hp)]])
          []
          (Std.Tactic.tacticLetI_ "letI" (Term.haveDecl (Term.haveIdDecl [] [] ":=" `hp)))
          []
          (Std.Tactic.rcases
           "rcases"
           [(Tactic.casesTarget [] (Term.app `FiniteField.card [`K `p]))]
           ["with"
            (Std.Tactic.RCases.rcasesPatLo
             (Std.Tactic.RCases.rcasesPatMed
              [(Std.Tactic.RCases.rcasesPat.tuple
                "⟨"
                [(Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed
                   [(Std.Tactic.RCases.rcasesPat.tuple
                     "⟨"
                     [(Std.Tactic.RCases.rcasesPatLo
                       (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `n)])
                       [])
                      ","
                      (Std.Tactic.RCases.rcasesPatLo
                       (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `npos)])
                       [])]
                     "⟩")])
                  [])
                 ","
                 (Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed
                   [(Std.Tactic.RCases.rcasesPat.tuple
                     "⟨"
                     [(Std.Tactic.RCases.rcasesPatLo
                       (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hp)])
                       [])
                      ","
                      (Std.Tactic.RCases.rcasesPatLo
                       (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hn)])
                       [])]
                     "⟩")])
                  [])]
                "⟩")])
             [])])
          []
          (Std.Tactic.tacticHaveI_
           "haveI"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec ":" (Term.app `Fact [`p.prime]))]
             ":="
             (Term.anonymousCtor "⟨" [`hp] "⟩"))))
          []
          (Tactic.dsimp "dsimp" [] [] [] [] [(Tactic.location "at" (Tactic.locationHyp [`hn] []))])
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] `hn)
             ","
             (Tactic.rwRule [(patternIgnore (token.«← » "←"))] `map_expand_pow_char)
             ","
             (Tactic.rwRule [] (Term.app `frobenius_pow [`hn]))
             ","
             (Tactic.rwRule [] `RingHom.one_def)
             ","
             (Tactic.rwRule [] `map_id)]
            "]")
           [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] `hn)
         ","
         (Tactic.rwRule [(patternIgnore (token.«← » "←"))] `map_expand_pow_char)
         ","
         (Tactic.rwRule [] (Term.app `frobenius_pow [`hn]))
         ","
         (Tactic.rwRule [] `RingHom.one_def)
         ","
         (Tactic.rwRule [] `map_id)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `map_id
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `RingHom.one_def
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `frobenius_pow [`hn])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hn
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `frobenius_pow
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `map_expand_pow_char
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hn
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.dsimp "dsimp" [] [] [] [] [(Tactic.location "at" (Tactic.locationHyp [`hn] []))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.locationHyp', expected 'Lean.Parser.Tactic.locationWildcard'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hn
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.tacticHaveI_
       "haveI"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec ":" (Term.app `Fact [`p.prime]))]
         ":="
         (Term.anonymousCtor "⟨" [`hp] "⟩"))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [`hp] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hp
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Fact [`p.prime])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p.prime
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Fact
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.rcases
       "rcases"
       [(Tactic.casesTarget [] (Term.app `FiniteField.card [`K `p]))]
       ["with"
        (Std.Tactic.RCases.rcasesPatLo
         (Std.Tactic.RCases.rcasesPatMed
          [(Std.Tactic.RCases.rcasesPat.tuple
            "⟨"
            [(Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed
               [(Std.Tactic.RCases.rcasesPat.tuple
                 "⟨"
                 [(Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `n)])
                   [])
                  ","
                  (Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `npos)])
                   [])]
                 "⟩")])
              [])
             ","
             (Std.Tactic.RCases.rcasesPatLo
              (Std.Tactic.RCases.rcasesPatMed
               [(Std.Tactic.RCases.rcasesPat.tuple
                 "⟨"
                 [(Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hp)])
                   [])
                  ","
                  (Std.Tactic.RCases.rcasesPatLo
                   (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `hn)])
                   [])]
                 "⟩")])
              [])]
            "⟩")])
         [])])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `FiniteField.card [`K `p])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `p
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `FiniteField.card
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.tacticLetI_ "letI" (Term.haveDecl (Term.haveIdDecl [] [] ":=" `hp)))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hp
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.cases'
       "cases'"
       [(Tactic.casesTarget [] (Term.app `CharP.exists [`K]))]
       []
       ["with" [(Lean.binderIdent `p) (Lean.binderIdent `hp)]])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `CharP.exists [`K])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `CharP.exists
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_»
       (Term.app `expand [`K (FieldTheory.Finite.Basic.termq "q") `f])
       "="
       («term_^_» `f "^" (FieldTheory.Finite.Basic.termq "q")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_^_» `f "^" (FieldTheory.Finite.Basic.termq "q"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  expand_card
  ( f : K [X] ) : expand K q f = f ^ q
  :=
    by
      cases' CharP.exists K with p hp
        letI := hp
        rcases FiniteField.card K p with ⟨ ⟨ n , npos ⟩ , ⟨ hp , hn ⟩ ⟩
        haveI : Fact p.prime := ⟨ hp ⟩
        dsimp at hn
        rw [ hn , ← map_expand_pow_char , frobenius_pow hn , RingHom.one_def , map_id ]
#align finite_field.expand_card FiniteField.expand_card

end FiniteField

namespace Zmod

open FiniteField Polynomial

theorem sq_add_sq (p : ℕ) [hp : Fact p.Prime] (x : Zmod p) : ∃ a b : Zmod p, a ^ 2 + b ^ 2 = x :=
  by
  cases' hp.1.eq_two_or_odd with hp2 hp_odd
  · subst p
    change Fin 2 at x
    fin_cases x
    · use 0
      simp
    · use 0, 1
      simp
  let f : (Zmod p)[X] := X ^ 2
  let g : (Zmod p)[X] := X ^ 2 - C x
  obtain ⟨a, b, hab⟩ : ∃ a b, f.eval a + g.eval b = 0 :=
    @exists_root_sum_quadratic _ _ _ _ f g (degree_X_pow 2) (degree_X_pow_sub_C (by decide) _)
      (by rw [Zmod.card, hp_odd])
  refine' ⟨a, b, _⟩
  rw [← sub_eq_zero]
  simpa only [eval_C, eval_X, eval_pow, eval_sub, ← add_sub_assoc] using hab
#align zmod.sq_add_sq Zmod.sq_add_sq

end Zmod

namespace CharP

theorem sq_add_sq (R : Type _) [CommRing R] [IsDomain R] (p : ℕ) [NeZero p] [CharP R p] (x : ℤ) :
    ∃ a b : ℕ, (a ^ 2 + b ^ 2 : R) = x :=
  by
  haveI := char_is_prime_of_pos R p
  obtain ⟨a, b, hab⟩ := Zmod.sq_add_sq p x
  refine' ⟨a.val, b.val, _⟩
  simpa using congr_arg (Zmod.castHom dvd_rfl R) hab
#align char_p.sq_add_sq CharP.sq_add_sq

end CharP

open Nat

open Zmod

/-- The **Fermat-Euler totient theorem**. `nat.modeq.pow_totient` is an alternative statement
  of the same theorem. -/
@[simp]
theorem Zmod.pow_totient {n : ℕ} (x : (Zmod n)ˣ) : x ^ φ n = 1 :=
  by
  cases n
  · rw [Nat.totient_zero, pow_zero]
  · rw [← card_units_eq_totient, pow_card_eq_one]
#align zmod.pow_totient Zmod.pow_totient

/-- The **Fermat-Euler totient theorem**. `zmod.pow_totient` is an alternative statement
  of the same theorem. -/
theorem Nat.ModEq.pow_totient {x n : ℕ} (h : Nat.Coprime x n) : x ^ φ n ≡ 1 [MOD n] :=
  by
  rw [← Zmod.eq_iff_modeq_nat]
  let x' : Units (Zmod n) := Zmod.unitOfCoprime _ h
  have := Zmod.pow_totient x'
  apply_fun (coe : Units (Zmod n) → Zmod n)  at this
  simpa only [-Zmod.pow_totient, Nat.succ_eq_add_one, Nat.cast_pow, Units.val_one, Nat.cast_one,
    coe_unit_of_coprime, Units.val_pow_eq_pow_val]
#align nat.modeq.pow_totient Nat.ModEq.pow_totient

section

variable {V : Type _} [Fintype K] [DivisionRing K] [AddCommGroup V] [Module K V]

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `card_eq_pow_finrank [])
      (Command.declSig
       [(Term.instBinder "[" [] (Term.app `Fintype [`V]) "]")]
       (Term.typeSpec
        ":"
        («term_=_»
         (Term.app `Fintype.card [`V])
         "="
         («term_^_»
          (FieldTheory.Finite.Basic.termq "q")
          "^"
          (Term.app `FiniteDimensional.finrank [`K `V])))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.tacticLet_
            "let"
            (Term.letDecl
             (Term.letIdDecl `b [] [] ":=" (Term.app `IsNoetherian.finsetBasis [`K `V]))))
           []
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule [] (Term.app `Module.card_fintype [`b]))
              ","
              (Tactic.rwRule
               [(patternIgnore (token.«← » "←"))]
               (Term.app `FiniteDimensional.finrank_eq_card_basis [`b]))]
             "]")
            [])])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.tacticLet_
           "let"
           (Term.letDecl
            (Term.letIdDecl `b [] [] ":=" (Term.app `IsNoetherian.finsetBasis [`K `V]))))
          []
          (Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] (Term.app `Module.card_fintype [`b]))
             ","
             (Tactic.rwRule
              [(patternIgnore (token.«← » "←"))]
              (Term.app `FiniteDimensional.finrank_eq_card_basis [`b]))]
            "]")
           [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] (Term.app `Module.card_fintype [`b]))
         ","
         (Tactic.rwRule
          [(patternIgnore (token.«← » "←"))]
          (Term.app `FiniteDimensional.finrank_eq_card_basis [`b]))]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `FiniteDimensional.finrank_eq_card_basis [`b])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `b
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `FiniteDimensional.finrank_eq_card_basis
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Module.card_fintype [`b])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `b
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Module.card_fintype
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticLet_
       "let"
       (Term.letDecl (Term.letIdDecl `b [] [] ":=" (Term.app `IsNoetherian.finsetBasis [`K `V]))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `IsNoetherian.finsetBasis [`K `V])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `V
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `IsNoetherian.finsetBasis
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_»
       (Term.app `Fintype.card [`V])
       "="
       («term_^_»
        (FieldTheory.Finite.Basic.termq "q")
        "^"
        (Term.app `FiniteDimensional.finrank [`K `V])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_^_»
       (FieldTheory.Finite.Basic.termq "q")
       "^"
       (Term.app `FiniteDimensional.finrank [`K `V]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `FiniteDimensional.finrank [`K `V])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `V
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `K
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `FiniteDimensional.finrank
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 80 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 80, term))
      (FieldTheory.Finite.Basic.termq "q")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'FieldTheory.Finite.Basic.termq', expected 'FieldTheory.Finite.Basic.termq._@.FieldTheory.Finite.Basic._hyg.5'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  card_eq_pow_finrank
  [ Fintype V ] : Fintype.card V = q ^ FiniteDimensional.finrank K V
  :=
    by
      let b := IsNoetherian.finsetBasis K V
        rw [ Module.card_fintype b , ← FiniteDimensional.finrank_eq_card_basis b ]
#align card_eq_pow_finrank card_eq_pow_finrank

end

open FiniteField

namespace Zmod

/-- A variation on Fermat's little theorem. See `zmod.pow_card_sub_one_eq_one` -/
@[simp]
theorem pow_card {p : ℕ} [Fact p.Prime] (x : Zmod p) : x ^ p = x :=
  by
  have h := FiniteField.pow_card x
  rwa [Zmod.card p] at h
#align zmod.pow_card Zmod.pow_card

@[simp]
theorem pow_card_pow {n p : ℕ} [Fact p.Prime] (x : Zmod p) : x ^ p ^ n = x :=
  by
  induction' n with n ih
  · simp
  · simp [pow_succ, pow_mul, ih, pow_card]
#align zmod.pow_card_pow Zmod.pow_card_pow

@[simp]
theorem frobenius_zmod (p : ℕ) [Fact p.Prime] : frobenius (Zmod p) p = RingHom.id _ :=
  by
  ext a
  rw [frobenius_def, Zmod.pow_card, RingHom.id_apply]
#align zmod.frobenius_zmod Zmod.frobenius_zmod

@[simp]
theorem card_units (p : ℕ) [Fact p.Prime] : Fintype.card (Zmod p)ˣ = p - 1 := by
  rw [Fintype.card_units, card]
#align zmod.card_units Zmod.card_units

/-- **Fermat's Little Theorem**: for every unit `a` of `zmod p`, we have `a ^ (p - 1) = 1`. -/
theorem units_pow_card_sub_one_eq_one (p : ℕ) [Fact p.Prime] (a : (Zmod p)ˣ) : a ^ (p - 1) = 1 := by
  rw [← card_units p, pow_card_eq_one]
#align zmod.units_pow_card_sub_one_eq_one Zmod.units_pow_card_sub_one_eq_one

/-- **Fermat's Little Theorem**: for all nonzero `a : zmod p`, we have `a ^ (p - 1) = 1`. -/
theorem pow_card_sub_one_eq_one {p : ℕ} [Fact p.Prime] {a : Zmod p} (ha : a ≠ 0) :
    a ^ (p - 1) = 1 := by
  have h := pow_card_sub_one_eq_one a ha
  rwa [Zmod.card p] at h
#align zmod.pow_card_sub_one_eq_one Zmod.pow_card_sub_one_eq_one

open Polynomial

theorem expand_card {p : ℕ} [Fact p.Prime] (f : Polynomial (Zmod p)) :
    expand (Zmod p) p f = f ^ p :=
  by
  have h := FiniteField.expand_card f
  rwa [Zmod.card p] at h
#align zmod.expand_card Zmod.expand_card

end Zmod

/-- **Fermat's Little Theorem**: for all `a : ℤ` coprime to `p`, we have
`a ^ (p - 1) ≡ 1 [ZMOD p]`. -/
theorem Int.ModEq.pow_card_sub_one_eq_one {p : ℕ} (hp : Nat.Prime p) {n : ℤ} (hpn : IsCoprime n p) :
    n ^ (p - 1) ≡ 1 [ZMOD p] := by
  haveI : Fact p.prime := ⟨hp⟩
  have : ¬(n : Zmod p) = 0 :=
    by
    rw [CharP.int_cast_eq_zero_iff _ p, ← (nat.prime_iff_prime_int.mp hp).coprime_iff_not_dvd]
    · exact hpn.symm
    exact Zmod.char_p p
  simpa [← Zmod.int_coe_eq_int_coe_iff] using Zmod.pow_card_sub_one_eq_one this
#align int.modeq.pow_card_sub_one_eq_one Int.ModEq.pow_card_sub_one_eq_one

section

namespace FiniteField

variable {F : Type _} [Field F]

section Finite

variable [Finite F]

/-- In a finite field of characteristic `2`, all elements are squares. -/
theorem is_square_of_char_two (hF : ringChar F = 2) (a : F) : IsSquare a :=
  haveI hF' : CharP F 2 := ringChar.of_eq hF
  is_square_of_char_two' a
#align finite_field.is_square_of_char_two FiniteField.is_square_of_char_two

/-- In a finite field of odd characteristic, not every element is a square. -/
theorem exists_nonsquare (hF : ringChar F ≠ 2) : ∃ a : F, ¬IsSquare a :=
  by
  -- Idea: the squaring map on `F` is not injective, hence not surjective
  let sq : F → F := fun x => x ^ 2
  have h : ¬injective sq :=
    by
    simp only [injective, not_forall, exists_prop]
    refine' ⟨-1, 1, _, Ring.neg_one_ne_one_of_char_ne_two hF⟩
    simp only [sq, one_pow, neg_one_sq]
  rw [Finite.injective_iff_surjective] at h
  -- sq not surjective
  simp_rw [IsSquare, ← pow_two, @eq_comm _ _ (_ ^ 2)]
  push_neg  at h⊢
  exact h
#align finite_field.exists_nonsquare FiniteField.exists_nonsquare

end Finite

variable [Fintype F]

/-- The finite field `F` has even cardinality iff it has characteristic `2`. -/
theorem even_card_iff_char_two : ringChar F = 2 ↔ Fintype.card F % 2 = 0 :=
  by
  rcases FiniteField.card F (ringChar F) with ⟨n, hp, h⟩
  rw [h, Nat.pow_mod]
  constructor
  · intro hF
    rw [hF]
    simp only [Nat.bit0_mod_two, zero_pow', Ne.def, PNat.ne_zero, not_false_iff, Nat.zero_mod]
  · rw [← Nat.even_iff, Nat.even_pow]
    rintro ⟨hev, hnz⟩
    rw [Nat.even_iff, Nat.mod_mod] at hev
    exact (Nat.Prime.eq_two_or_odd hp).resolve_right (ne_of_eq_of_ne hev zero_ne_one)
#align finite_field.even_card_iff_char_two FiniteField.even_card_iff_char_two

theorem even_card_of_char_two (hF : ringChar F = 2) : Fintype.card F % 2 = 0 :=
  even_card_iff_char_two.mp hF
#align finite_field.even_card_of_char_two FiniteField.even_card_of_char_two

theorem odd_card_of_char_ne_two (hF : ringChar F ≠ 2) : Fintype.card F % 2 = 1 :=
  Nat.mod_two_ne_zero.mp (mt even_card_iff_char_two.mpr hF)
#align finite_field.odd_card_of_char_ne_two FiniteField.odd_card_of_char_ne_two

/-- If `F` has odd characteristic, then for nonzero `a : F`, we have that `a ^ (#F / 2) = ±1`. -/
theorem pow_dichotomy (hF : ringChar F ≠ 2) {a : F} (ha : a ≠ 0) :
    a ^ (Fintype.card F / 2) = 1 ∨ a ^ (Fintype.card F / 2) = -1 :=
  by
  have h₁ := FiniteField.pow_card_sub_one_eq_one a ha
  rw [← Nat.two_mul_odd_div_two (FiniteField.odd_card_of_char_ne_two hF), mul_comm, pow_mul,
    pow_two] at h₁
  exact mul_self_eq_one_iff.mp h₁
#align finite_field.pow_dichotomy FiniteField.pow_dichotomy

/-- A unit `a` of a finite field `F` of odd characteristic is a square
if and only if `a ^ (#F / 2) = 1`. -/
theorem unit_is_square_iff (hF : ringChar F ≠ 2) (a : Fˣ) :
    IsSquare a ↔ a ^ (Fintype.card F / 2) = 1 := by
  classical
    obtain ⟨g, hg⟩ := IsCyclic.exists_generator Fˣ
    obtain ⟨n, hn⟩ : a ∈ Submonoid.powers g :=
      by
      rw [mem_powers_iff_mem_zpowers]
      apply hg
    have hodd := Nat.two_mul_odd_div_two (FiniteField.odd_card_of_char_ne_two hF)
    constructor
    · rintro ⟨y, rfl⟩
      rw [← pow_two, ← pow_mul, hodd]
      apply_fun @coe Fˣ F _ using Units.ext
      · push_cast
        exact FiniteField.pow_card_sub_one_eq_one (y : F) (Units.ne_zero y)
    · subst a
      intro h
      have key : 2 * (Fintype.card F / 2) ∣ n * (Fintype.card F / 2) :=
        by
        rw [← pow_mul] at h
        rw [hodd, ← Fintype.card_units, ← order_of_eq_card_of_forall_mem_zpowers hg]
        apply order_of_dvd_of_pow_eq_one h
      have : 0 < Fintype.card F / 2 := Nat.div_pos Fintype.one_lt_card (by norm_num)
      obtain ⟨m, rfl⟩ := Nat.dvd_of_mul_dvd_mul_right this key
      refine' ⟨g ^ m, _⟩
      rw [mul_comm, pow_mul, pow_two]
#align finite_field.unit_is_square_iff FiniteField.unit_is_square_iff

/-- A non-zero `a : F` is a square if and only if `a ^ (#F / 2) = 1`. -/
theorem is_square_iff (hF : ringChar F ≠ 2) {a : F} (ha : a ≠ 0) :
    IsSquare a ↔ a ^ (Fintype.card F / 2) = 1 :=
  by
  apply
    (iff_congr _ (by simp [Units.ext_iff])).mp (FiniteField.unit_is_square_iff hF (Units.mk0 a ha))
  simp only [IsSquare, Units.ext_iff, Units.val_mk0, Units.val_mul]
  constructor
  · rintro ⟨y, hy⟩
    exact ⟨y, hy⟩
  · rintro ⟨y, rfl⟩
    have hy : y ≠ 0 := by
      rintro rfl
      simpa [zero_pow] using ha
    refine' ⟨Units.mk0 y hy, _⟩
    simp
#align finite_field.is_square_iff FiniteField.is_square_iff

end FiniteField

end

