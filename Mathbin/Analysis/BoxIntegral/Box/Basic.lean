/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov
-/
import Mathbin.Data.Set.Intervals.Monotone
import Mathbin.Topology.Algebra.Order.MonotoneConvergence
import Mathbin.Topology.MetricSpace.Basic

/-!
# Rectangular boxes in `ℝⁿ`

In this file we define rectangular boxes in `ℝⁿ`. As usual, we represent `ℝⁿ` as the type of
functions `ι → ℝ` (usually `ι = fin n` for some `n`). When we need to interpret a box `[l, u]` as a
set, we use the product `{x | ∀ i, l i < x i ∧ x i ≤ u i}` of half-open intervals `(l i, u i]`. We
exclude `l i` because this way boxes of a partition are disjoint as sets in `ℝⁿ`.

Currently, the only use cases for these constructions are the definitions of Riemann-style integrals
(Riemann, Henstock-Kurzweil, McShane).

## Main definitions

We use the same structure `box_integral.box` both for ambient boxes and for elements of a partition.
Each box is stored as two points `lower upper : ι → ℝ` and a proof of `∀ i, lower i < upper i`. We
define instances `has_mem (ι → ℝ) (box ι)` and `has_coe_t (box ι) (set $ ι → ℝ)` so that each box is
interpreted as the set `{x | ∀ i, x i ∈ set.Ioc (I.lower i) (I.upper i)}`. This way boxes of a
partition are pairwise disjoint and their union is exactly the original box.

We require boxes to be nonempty, because this way coercion to sets is injective. The empty box can
be represented as `⊥ : with_bot (box_integral.box ι)`.

We define the following operations on boxes:

* coercion to `set (ι → ℝ)` and `has_mem (ι → ℝ) (box_integral.box ι)` as described above;
* `partial_order` and `semilattice_sup` instances such that `I ≤ J` is equivalent to
  `(I : set (ι → ℝ)) ⊆ J`;
* `lattice` instances on `with_bot (box_integral.box ι)`;
* `box_integral.box.Icc`: the closed box `set.Icc I.lower I.upper`; defined as a bundled monotone
  map from `box ι` to `set (ι → ℝ)`;
* `box_integral.box.face I i : box (fin n)`: a hyperface of `I : box_integral.box (fin (n + 1))`;
* `box_integral.box.distortion`: the maximal ratio of two lengths of edges of a box; defined as the
  supremum of `nndist I.lower I.upper / nndist (I.lower i) (I.upper i)`.

We also provide a convenience constructor `box_integral.box.mk' (l u : ι → ℝ) : with_bot (box ι)`
that returns the box `⟨l, u, _⟩` if it is nonempty and `⊥` otherwise.

## Tags

rectangular box
-/


open Set Function Metric Filter

noncomputable section

open Nnreal Classical TopologicalSpace

namespace BoxIntegral

variable {ι : Type _}

/-!
### Rectangular box: definition and partial order
-/


/-- A nontrivial rectangular box in `ι → ℝ` with corners `lower` and `upper`. Repesents the product
of half-open intervals `(lower i, upper i]`. -/
structure Box (ι : Type _) where
  (lower upper : ι → ℝ)
  lower_lt_upper : ∀ i, lower i < upper i
#align box_integral.box BoxIntegral.Box

attribute [simp] box.lower_lt_upper

namespace Box

variable (I J : Box ι) {x y : ι → ℝ}

instance : Inhabited (Box ι) :=
  ⟨⟨0, 1, fun i => zero_lt_one⟩⟩

theorem lower_le_upper : I.lower ≤ I.upper := fun i => (I.lower_lt_upper i).le
#align box_integral.box.lower_le_upper BoxIntegral.Box.lower_le_upper

theorem lower_ne_upper (i) : I.lower i ≠ I.upper i :=
  (I.lower_lt_upper i).Ne
#align box_integral.box.lower_ne_upper BoxIntegral.Box.lower_ne_upper

instance : Membership (ι → ℝ) (Box ι) :=
  ⟨fun x I => ∀ i, x i ∈ ioc (I.lower i) (I.upper i)⟩

instance : CoeTC (Box ι) (Set <| ι → ℝ) :=
  ⟨fun I => { x | x ∈ I }⟩

@[simp]
theorem mem_mk {l u x : ι → ℝ} {H} : x ∈ mk l u H ↔ ∀ i, x i ∈ ioc (l i) (u i) :=
  Iff.rfl
#align box_integral.box.mem_mk BoxIntegral.Box.mem_mk

@[simp, norm_cast]
theorem mem_coe : x ∈ (I : Set (ι → ℝ)) ↔ x ∈ I :=
  Iff.rfl
#align box_integral.box.mem_coe BoxIntegral.Box.mem_coe

theorem mem_def : x ∈ I ↔ ∀ i, x i ∈ ioc (I.lower i) (I.upper i) :=
  Iff.rfl
#align box_integral.box.mem_def BoxIntegral.Box.mem_def

theorem mem_univ_Ioc {I : Box ι} : (x ∈ pi univ fun i => ioc (I.lower i) (I.upper i)) ↔ x ∈ I :=
  mem_univ_pi
#align box_integral.box.mem_univ_Ioc BoxIntegral.Box.mem_univ_Ioc

theorem coe_eq_pi : (I : Set (ι → ℝ)) = pi univ fun i => ioc (I.lower i) (I.upper i) :=
  Set.ext fun x => mem_univ_Ioc.symm
#align box_integral.box.coe_eq_pi BoxIntegral.Box.coe_eq_pi

@[simp]
theorem upper_mem : I.upper ∈ I := fun i => right_mem_Ioc.2 <| I.lower_lt_upper i
#align box_integral.box.upper_mem BoxIntegral.Box.upper_mem

theorem exists_mem : ∃ x, x ∈ I :=
  ⟨_, I.upper_mem⟩
#align box_integral.box.exists_mem BoxIntegral.Box.exists_mem

theorem nonempty_coe : Set.Nonempty (I : Set (ι → ℝ)) :=
  I.exists_mem
#align box_integral.box.nonempty_coe BoxIntegral.Box.nonempty_coe

@[simp]
theorem coe_ne_empty : (I : Set (ι → ℝ)) ≠ ∅ :=
  I.nonempty_coe.ne_empty
#align box_integral.box.coe_ne_empty BoxIntegral.Box.coe_ne_empty

@[simp]
theorem empty_ne_coe : ∅ ≠ (I : Set (ι → ℝ)) :=
  I.coe_ne_empty.symm
#align box_integral.box.empty_ne_coe BoxIntegral.Box.empty_ne_coe

instance : LE (Box ι) :=
  ⟨fun I J => ∀ ⦃x⦄, x ∈ I → x ∈ J⟩

theorem le_def : I ≤ J ↔ ∀ x ∈ I, x ∈ J :=
  Iff.rfl
#align box_integral.box.le_def BoxIntegral.Box.le_def

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `le_tfae [])
      (Command.declSig
       []
       (Term.typeSpec
        ":"
        (Term.app
         `Tfae
         [(«term[_]»
           "["
           [(«term_≤_» `I "≤" `J)
            ","
            («term_⊆_»
             (Term.typeAscription "(" `I ":" [(Term.app `Set [(Term.arrow `ι "→" (Data.Real.Basic.termℝ "ℝ"))])] ")")
             "⊆"
             `J)
            ","
            («term_⊆_»
             (Term.app `icc [(Term.proj `I "." `lower) (Term.proj `I "." `upper)])
             "⊆"
             (Term.app `icc [(Term.proj `J "." `lower) (Term.proj `J "." `upper)]))
            ","
            («term_∧_»
             («term_≤_» (Term.proj `J "." `lower) "≤" (Term.proj `I "." `lower))
             "∧"
             («term_≤_» (Term.proj `I "." `upper) "≤" (Term.proj `J "." `upper)))]
           "]")])))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.tfaeHave "tfae_have" [] (num "1") "↔" (num "2"))
           []
           (Tactic.exact "exact" `Iff.rfl)
           []
           (Tactic.tfaeHave "tfae_have" [] (num "2") "→" (num "3"))
           []
           («tactic___;_»
            (cdotTk (patternIgnore (token.«·» "·")))
            [(group (Tactic.intro "intro" [`h]) [])
             (group
              (Std.Tactic.simpa
               "simpa"
               []
               []
               (Std.Tactic.simpaArgsRest
                []
                []
                []
                [(Tactic.simpArgs
                  "["
                  [(Tactic.simpLemma [] [] `coe_eq_pi)
                   ","
                   (Tactic.simpLemma [] [] `closure_pi_set)
                   ","
                   (Tactic.simpLemma [] [] `lower_ne_upper)]
                  "]")]
                ["using" (Term.app `closure_mono [`h])]))
              [])])
           []
           (Tactic.tfaeHave "tfae_have" [] (num "3") "↔" (num "4"))
           []
           (Tactic.exact "exact" (Term.app `Icc_subset_Icc_iff [`I.lower_le_upper]))
           []
           (Tactic.tfaeHave "tfae_have" [] (num "4") "→" (num "2"))
           []
           (Tactic.exact
            "exact"
            (Term.fun
             "fun"
             (Term.basicFun
              [`h `x `hx `i]
              []
              "=>"
              (Term.app
               `Ioc_subset_Ioc
               [(Term.app (Term.proj `h "." (fieldIdx "1")) [`i])
                (Term.app (Term.proj `h "." (fieldIdx "2")) [`i])
                (Term.app `hx [`i])]))))
           []
           (Tactic.tfaeFinish "tfae_finish")])))
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
         [(Tactic.tfaeHave "tfae_have" [] (num "1") "↔" (num "2"))
          []
          (Tactic.exact "exact" `Iff.rfl)
          []
          (Tactic.tfaeHave "tfae_have" [] (num "2") "→" (num "3"))
          []
          («tactic___;_»
           (cdotTk (patternIgnore (token.«·» "·")))
           [(group (Tactic.intro "intro" [`h]) [])
            (group
             (Std.Tactic.simpa
              "simpa"
              []
              []
              (Std.Tactic.simpaArgsRest
               []
               []
               []
               [(Tactic.simpArgs
                 "["
                 [(Tactic.simpLemma [] [] `coe_eq_pi)
                  ","
                  (Tactic.simpLemma [] [] `closure_pi_set)
                  ","
                  (Tactic.simpLemma [] [] `lower_ne_upper)]
                 "]")]
               ["using" (Term.app `closure_mono [`h])]))
             [])])
          []
          (Tactic.tfaeHave "tfae_have" [] (num "3") "↔" (num "4"))
          []
          (Tactic.exact "exact" (Term.app `Icc_subset_Icc_iff [`I.lower_le_upper]))
          []
          (Tactic.tfaeHave "tfae_have" [] (num "4") "→" (num "2"))
          []
          (Tactic.exact
           "exact"
           (Term.fun
            "fun"
            (Term.basicFun
             [`h `x `hx `i]
             []
             "=>"
             (Term.app
              `Ioc_subset_Ioc
              [(Term.app (Term.proj `h "." (fieldIdx "1")) [`i])
               (Term.app (Term.proj `h "." (fieldIdx "2")) [`i])
               (Term.app `hx [`i])]))))
          []
          (Tactic.tfaeFinish "tfae_finish")])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tfaeFinish "tfae_finish")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.fun
        "fun"
        (Term.basicFun
         [`h `x `hx `i]
         []
         "=>"
         (Term.app
          `Ioc_subset_Ioc
          [(Term.app (Term.proj `h "." (fieldIdx "1")) [`i])
           (Term.app (Term.proj `h "." (fieldIdx "2")) [`i])
           (Term.app `hx [`i])]))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`h `x `hx `i]
        []
        "=>"
        (Term.app
         `Ioc_subset_Ioc
         [(Term.app (Term.proj `h "." (fieldIdx "1")) [`i])
          (Term.app (Term.proj `h "." (fieldIdx "2")) [`i])
          (Term.app `hx [`i])])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `Ioc_subset_Ioc
       [(Term.app (Term.proj `h "." (fieldIdx "1")) [`i])
        (Term.app (Term.proj `h "." (fieldIdx "2")) [`i])
        (Term.app `hx [`i])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `hx [`i])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `hx
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `hx [`i]) ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app (Term.proj `h "." (fieldIdx "2")) [`i])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `h "." (fieldIdx "2"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app (Term.proj `h "." (fieldIdx "2")) [`i]) ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app (Term.proj `h "." (fieldIdx "1")) [`i])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `h "." (fieldIdx "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app (Term.proj `h "." (fieldIdx "1")) [`i]) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Ioc_subset_Ioc
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `hx
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `x
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tfaeHave "tfae_have" [] (num "4") "→" (num "2"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«→»', expected 'token.« → »'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«→»', expected 'token.« ↔ »'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«→»', expected 'token.« ← »'
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
  le_tfae
  :
    Tfae
      [
        I ≤ J
          ,
          ( I : Set ι → ℝ ) ⊆ J
          ,
          icc I . lower I . upper ⊆ icc J . lower J . upper
          ,
          J . lower ≤ I . lower ∧ I . upper ≤ J . upper
        ]
  :=
    by
      tfae_have 1 ↔ 2
        exact Iff.rfl
        tfae_have 2 → 3
        · intro h simpa [ coe_eq_pi , closure_pi_set , lower_ne_upper ] using closure_mono h
        tfae_have 3 ↔ 4
        exact Icc_subset_Icc_iff I.lower_le_upper
        tfae_have 4 → 2
        exact fun h x hx i => Ioc_subset_Ioc h . 1 i h . 2 i hx i
        tfae_finish
#align box_integral.box.le_tfae BoxIntegral.Box.le_tfae

variable {I J}

@[simp, norm_cast]
theorem coe_subset_coe : (I : Set (ι → ℝ)) ⊆ J ↔ I ≤ J :=
  Iff.rfl
#align box_integral.box.coe_subset_coe BoxIntegral.Box.coe_subset_coe

theorem le_iff_bounds : I ≤ J ↔ J.lower ≤ I.lower ∧ I.upper ≤ J.upper :=
  (le_tfae I J).out 0 3
#align box_integral.box.le_iff_bounds BoxIntegral.Box.le_iff_bounds

theorem injective_coe : Injective (coe : Box ι → Set (ι → ℝ)) := by
  rintro ⟨l₁, u₁, h₁⟩ ⟨l₂, u₂, h₂⟩ h
  simp only [subset.antisymm_iff, coe_subset_coe, le_iff_bounds] at h
  congr
  exacts[le_antisymm h.2.1 h.1.1, le_antisymm h.1.2 h.2.2]
#align box_integral.box.injective_coe BoxIntegral.Box.injective_coe

@[simp, norm_cast]
theorem coe_inj : (I : Set (ι → ℝ)) = J ↔ I = J :=
  injective_coe.eq_iff
#align box_integral.box.coe_inj BoxIntegral.Box.coe_inj

@[ext.1]
theorem ext (H : ∀ x, x ∈ I ↔ x ∈ J) : I = J :=
  injective_coe <| Set.ext H
#align box_integral.box.ext BoxIntegral.Box.ext

theorem ne_of_disjoint_coe (h : Disjoint (I : Set (ι → ℝ)) J) : I ≠ J :=
  mt coe_inj.2 <| h.Ne I.coe_ne_empty
#align box_integral.box.ne_of_disjoint_coe BoxIntegral.Box.ne_of_disjoint_coe

instance : PartialOrder (Box ι) :=
  { PartialOrder.lift (coe : Box ι → Set (ι → ℝ)) injective_coe with le := (· ≤ ·) }

/-- Closed box corresponding to `I : box_integral.box ι`. -/
protected def icc : Box ι ↪o Set (ι → ℝ) :=
  OrderEmbedding.ofMapLeIff (fun I : Box ι => icc I.lower I.upper) fun I J => (le_tfae I J).out 2 0
#align box_integral.box.Icc BoxIntegral.Box.icc

theorem Icc_def : I.icc = icc I.lower I.upper :=
  rfl
#align box_integral.box.Icc_def BoxIntegral.Box.Icc_def

@[simp]
theorem upper_mem_Icc (I : Box ι) : I.upper ∈ I.icc :=
  right_mem_Icc.2 I.lower_le_upper
#align box_integral.box.upper_mem_Icc BoxIntegral.Box.upper_mem_Icc

@[simp]
theorem lower_mem_Icc (I : Box ι) : I.lower ∈ I.icc :=
  left_mem_Icc.2 I.lower_le_upper
#align box_integral.box.lower_mem_Icc BoxIntegral.Box.lower_mem_Icc

protected theorem is_compact_Icc (I : Box ι) : IsCompact I.icc :=
  is_compact_Icc
#align box_integral.box.is_compact_Icc BoxIntegral.Box.is_compact_Icc

theorem Icc_eq_pi : I.icc = pi univ fun i => icc (I.lower i) (I.upper i) :=
  (pi_univ_Icc _ _).symm
#align box_integral.box.Icc_eq_pi BoxIntegral.Box.Icc_eq_pi

theorem le_iff_Icc : I ≤ J ↔ I.icc ⊆ J.icc :=
  (le_tfae I J).out 0 2
#align box_integral.box.le_iff_Icc BoxIntegral.Box.le_iff_Icc

theorem antitone_lower : Antitone fun I : Box ι => I.lower := fun I J H => (le_iff_bounds.1 H).1
#align box_integral.box.antitone_lower BoxIntegral.Box.antitone_lower

theorem monotone_upper : Monotone fun I : Box ι => I.upper := fun I J H => (le_iff_bounds.1 H).2
#align box_integral.box.monotone_upper BoxIntegral.Box.monotone_upper

theorem coe_subset_Icc : ↑I ⊆ I.icc := fun x hx => ⟨fun i => (hx i).1.le, fun i => (hx i).2⟩
#align box_integral.box.coe_subset_Icc BoxIntegral.Box.coe_subset_Icc

/-!
### Supremum of two boxes
-/


/-- `I ⊔ J` is the least box that includes both `I` and `J`. Since `↑I ∪ ↑J` is usually not a box,
`↑(I ⊔ J)` is larger than `↑I ∪ ↑J`. -/
instance : HasSup (Box ι) :=
  ⟨fun I J =>
    ⟨I.lower ⊓ J.lower, I.upper ⊔ J.upper, fun i =>
      (min_le_left _ _).trans_lt <| (I.lower_lt_upper i).trans_le (le_max_left _ _)⟩⟩

instance : SemilatticeSup (Box ι) :=
  { Box.partialOrder, Box.hasSup with le_sup_left := fun I J => le_iff_bounds.2 ⟨inf_le_left, le_sup_left⟩,
    le_sup_right := fun I J => le_iff_bounds.2 ⟨inf_le_right, le_sup_right⟩,
    sup_le := fun I₁ I₂ J h₁ h₂ =>
      le_iff_bounds.2 ⟨le_inf (antitone_lower h₁) (antitone_lower h₂), sup_le (monotone_upper h₁) (monotone_upper h₂)⟩ }

/-!
### `with_bot (box ι)`

In this section we define coercion from `with_bot (box ι)` to `set (ι → ℝ)` by sending `⊥` to `∅`.
-/


instance withBotCoe : CoeTC (WithBot (Box ι)) (Set (ι → ℝ)) :=
  ⟨fun o => o.elim ∅ coe⟩
#align box_integral.box.with_bot_coe BoxIntegral.Box.withBotCoe

@[simp, norm_cast]
theorem coe_bot : ((⊥ : WithBot (Box ι)) : Set (ι → ℝ)) = ∅ :=
  rfl
#align box_integral.box.coe_bot BoxIntegral.Box.coe_bot

@[simp, norm_cast]
theorem coe_coe : ((I : WithBot (Box ι)) : Set (ι → ℝ)) = I :=
  rfl
#align box_integral.box.coe_coe BoxIntegral.Box.coe_coe

theorem is_some_iff : ∀ {I : WithBot (Box ι)}, I.isSome ↔ (I : Set (ι → ℝ)).Nonempty
  | ⊥ => by
    erw [Option.isSome]
    simp
  | (I : box ι) => by
    erw [Option.isSome]
    simp [I.nonempty_coe]
#align box_integral.box.is_some_iff BoxIntegral.Box.is_some_iff

theorem bUnion_coe_eq_coe (I : WithBot (Box ι)) : (⋃ (J : Box ι) (hJ : ↑J = I), (J : Set (ι → ℝ))) = I := by
  induction I using WithBot.recBotCoe <;> simp [WithBot.coe_eq_coe]
#align box_integral.box.bUnion_coe_eq_coe BoxIntegral.Box.bUnion_coe_eq_coe

@[simp, norm_cast]
theorem with_bot_coe_subset_iff {I J : WithBot (Box ι)} : (I : Set (ι → ℝ)) ⊆ J ↔ I ≤ J := by
  induction I using WithBot.recBotCoe
  · simp
    
  induction J using WithBot.recBotCoe
  · simp [subset_empty_iff]
    
  simp
#align box_integral.box.with_bot_coe_subset_iff BoxIntegral.Box.with_bot_coe_subset_iff

@[simp, norm_cast]
theorem with_bot_coe_inj {I J : WithBot (Box ι)} : (I : Set (ι → ℝ)) = J ↔ I = J := by
  simp only [subset.antisymm_iff, ← le_antisymm_iff, with_bot_coe_subset_iff]
#align box_integral.box.with_bot_coe_inj BoxIntegral.Box.with_bot_coe_inj

/-- Make a `with_bot (box ι)` from a pair of corners `l u : ι → ℝ`. If `l i < u i` for all `i`,
then the result is `⟨l, u, _⟩ : box ι`, otherwise it is `⊥`. In any case, the result interpreted
as a set in `ι → ℝ` is the set `{x : ι → ℝ | ∀ i, x i ∈ Ioc (l i) (u i)}`.  -/
def mk' (l u : ι → ℝ) : WithBot (Box ι) :=
  if h : ∀ i, l i < u i then ↑(⟨l, u, h⟩ : Box ι) else ⊥
#align box_integral.box.mk' BoxIntegral.Box.mk'

@[simp]
theorem mk'_eq_bot {l u : ι → ℝ} : mk' l u = ⊥ ↔ ∃ i, u i ≤ l i := by
  rw [mk']
  split_ifs <;> simpa using h
#align box_integral.box.mk'_eq_bot BoxIntegral.Box.mk'_eq_bot

@[simp]
theorem mk'_eq_coe {l u : ι → ℝ} : mk' l u = I ↔ l = I.lower ∧ u = I.upper := by
  cases' I with lI uI hI
  rw [mk']
  split_ifs
  · simp [WithBot.coe_eq_coe]
    
  · suffices l = lI → u ≠ uI by simpa
    rintro rfl rfl
    exact h hI
    
#align box_integral.box.mk'_eq_coe BoxIntegral.Box.mk'_eq_coe

@[simp]
theorem coe_mk' (l u : ι → ℝ) : (mk' l u : Set (ι → ℝ)) = pi univ fun i => ioc (l i) (u i) := by
  rw [mk']
  split_ifs
  · exact coe_eq_pi _
    
  · rcases not_forall.mp h with ⟨i, hi⟩
    rw [coe_bot, univ_pi_eq_empty]
    exact Ioc_eq_empty hi
    
#align box_integral.box.coe_mk' BoxIntegral.Box.coe_mk'

instance : HasInf (WithBot (Box ι)) :=
  ⟨fun I =>
    WithBot.recBotCoe (fun J => ⊥)
      (fun I J => WithBot.recBotCoe ⊥ (fun J => mk' (I.lower ⊔ J.lower) (I.upper ⊓ J.upper)) J) I⟩

@[simp]
theorem coe_inf (I J : WithBot (Box ι)) : (↑(I ⊓ J) : Set (ι → ℝ)) = I ∩ J := by
  induction I using WithBot.recBotCoe
  · change ∅ = _
    simp
    
  induction J using WithBot.recBotCoe
  · change ∅ = _
    simp
    
  change ↑(mk' _ _) = _
  simp only [coe_eq_pi, ← pi_inter_distrib, Ioc_inter_Ioc, Pi.sup_apply, Pi.inf_apply, coe_mk', coe_coe]
#align box_integral.box.coe_inf BoxIntegral.Box.coe_inf

instance : Lattice (WithBot (Box ι)) :=
  { WithBot.semilatticeSup, Box.WithBot.hasInf with
    inf_le_left := fun I J => by
      rw [← with_bot_coe_subset_iff, coe_inf]
      exact inter_subset_left _ _,
    inf_le_right := fun I J => by
      rw [← with_bot_coe_subset_iff, coe_inf]
      exact inter_subset_right _ _,
    le_inf := fun I J₁ J₂ h₁ h₂ => by
      simp only [← with_bot_coe_subset_iff, coe_inf] at *
      exact subset_inter h₁ h₂ }

@[simp, norm_cast]
theorem disjoint_with_bot_coe {I J : WithBot (Box ι)} : Disjoint (I : Set (ι → ℝ)) J ↔ Disjoint I J := by
  simp only [disjoint_iff_inf_le, ← with_bot_coe_subset_iff, coe_inf]
  rfl
#align box_integral.box.disjoint_with_bot_coe BoxIntegral.Box.disjoint_with_bot_coe

theorem disjoint_coe : Disjoint (I : WithBot (Box ι)) J ↔ Disjoint (I : Set (ι → ℝ)) J :=
  disjoint_with_bot_coe.symm
#align box_integral.box.disjoint_coe BoxIntegral.Box.disjoint_coe

theorem not_disjoint_coe_iff_nonempty_inter : ¬Disjoint (I : WithBot (Box ι)) J ↔ (I ∩ J : Set (ι → ℝ)).Nonempty := by
  rw [disjoint_coe, Set.not_disjoint_iff_nonempty_inter]
#align box_integral.box.not_disjoint_coe_iff_nonempty_inter BoxIntegral.Box.not_disjoint_coe_iff_nonempty_inter

/-!
### Hyperface of a box in `ℝⁿ⁺¹ = fin (n + 1) → ℝ`
-/


/-- Face of a box in `ℝⁿ⁺¹ = fin (n + 1) → ℝ`: the box in `ℝⁿ = fin n → ℝ` with corners at
`I.lower ∘ fin.succ_above i` and `I.upper ∘ fin.succ_above i`. -/
@[simps (config := { simpRhs := true })]
def face {n} (I : Box (Fin (n + 1))) (i : Fin (n + 1)) : Box (Fin n) :=
  ⟨I.lower ∘ Fin.succAbove i, I.upper ∘ Fin.succAbove i, fun j => I.lower_lt_upper _⟩
#align box_integral.box.face BoxIntegral.Box.face

@[simp]
theorem face_mk {n} (l u : Fin (n + 1) → ℝ) (h : ∀ i, l i < u i) (i : Fin (n + 1)) :
    face ⟨l, u, h⟩ i = ⟨l ∘ Fin.succAbove i, u ∘ Fin.succAbove i, fun j => h _⟩ :=
  rfl
#align box_integral.box.face_mk BoxIntegral.Box.face_mk

@[mono]
theorem face_mono {n} {I J : Box (Fin (n + 1))} (h : I ≤ J) (i : Fin (n + 1)) : face I i ≤ face J i := fun x hx i =>
  Ioc_subset_Ioc ((le_iff_bounds.1 h).1 _) ((le_iff_bounds.1 h).2 _) (hx _)
#align box_integral.box.face_mono BoxIntegral.Box.face_mono

theorem monotone_face {n} (i : Fin (n + 1)) : Monotone fun I => face I i := fun I J h => face_mono h i
#align box_integral.box.monotone_face BoxIntegral.Box.monotone_face

theorem maps_to_insert_nth_face_Icc {n} (I : Box (Fin (n + 1))) {i : Fin (n + 1)} {x : ℝ}
    (hx : x ∈ icc (I.lower i) (I.upper i)) : MapsTo (i.insertNth x) (I.face i).icc I.icc := fun y hy =>
  Fin.insert_nth_mem_Icc.2 ⟨hx, hy⟩
#align box_integral.box.maps_to_insert_nth_face_Icc BoxIntegral.Box.maps_to_insert_nth_face_Icc

theorem maps_to_insert_nth_face {n} (I : Box (Fin (n + 1))) {i : Fin (n + 1)} {x : ℝ}
    (hx : x ∈ ioc (I.lower i) (I.upper i)) : MapsTo (i.insertNth x) (I.face i) I := fun y hy => by
  simpa only [mem_coe, mem_def, i.forall_iff_succ_above, hx, Fin.insert_nth_apply_same, Fin.insert_nth_apply_succ_above,
    true_and_iff]
#align box_integral.box.maps_to_insert_nth_face BoxIntegral.Box.maps_to_insert_nth_face

theorem continuous_on_face_Icc {X} [TopologicalSpace X] {n} {f : (Fin (n + 1) → ℝ) → X} {I : Box (Fin (n + 1))}
    (h : ContinuousOn f I.icc) {i : Fin (n + 1)} {x : ℝ} (hx : x ∈ icc (I.lower i) (I.upper i)) :
    ContinuousOn (f ∘ i.insertNth x) (I.face i).icc :=
  h.comp (continuous_on_const.fin_insert_nth i continuous_on_id) (I.maps_to_insert_nth_face_Icc hx)
#align box_integral.box.continuous_on_face_Icc BoxIntegral.Box.continuous_on_face_Icc

/-!
### Covering of the interior of a box by a monotone sequence of smaller boxes
-/


/-- The interior of a box. -/
protected def ioo : Box ι →o Set (ι → ℝ) where
  toFun I := pi univ fun i => ioo (I.lower i) (I.upper i)
  monotone' I J h := pi_mono fun i hi => Ioo_subset_Ioo ((le_iff_bounds.1 h).1 i) ((le_iff_bounds.1 h).2 i)
#align box_integral.box.Ioo BoxIntegral.Box.ioo

theorem Ioo_subset_coe (I : Box ι) : I.ioo ⊆ I := fun x hx i => Ioo_subset_Ioc_self (hx i trivial)
#align box_integral.box.Ioo_subset_coe BoxIntegral.Box.Ioo_subset_coe

protected theorem Ioo_subset_Icc (I : Box ι) : I.ioo ⊆ I.icc :=
  I.Ioo_subset_coe.trans coe_subset_Icc
#align box_integral.box.Ioo_subset_Icc BoxIntegral.Box.Ioo_subset_Icc

theorem Union_Ioo_of_tendsto [Finite ι] {I : Box ι} {J : ℕ → Box ι} (hJ : Monotone J)
    (hl : Tendsto (lower ∘ J) atTop (𝓝 I.lower)) (hu : Tendsto (upper ∘ J) atTop (𝓝 I.upper)) :
    (⋃ n, (J n).ioo) = I.ioo :=
  have hl' : ∀ i, Antitone fun n => (J n).lower i := fun i =>
    (monotone_eval i).comp_antitone (antitone_lower.comp_monotone hJ)
  have hu' : ∀ i, Monotone fun n => (J n).upper i := fun i => (monotone_eval i).comp (monotone_upper.comp hJ)
  calc
    (⋃ n, (J n).ioo) = pi univ fun i => ⋃ n, ioo ((J n).lower i) ((J n).upper i) :=
      Union_univ_pi_of_monotone fun i => (hl' i).ioo (hu' i)
    _ = I.ioo :=
      pi_congr rfl fun i hi =>
        Union_Ioo_of_mono_of_is_glb_of_is_lub (hl' i) (hu' i)
          (is_glb_of_tendsto_at_top (hl' i) (tendsto_pi_nhds.1 hl _))
          (is_lub_of_tendsto_at_top (hu' i) (tendsto_pi_nhds.1 hu _))
    
#align box_integral.box.Union_Ioo_of_tendsto BoxIntegral.Box.Union_Ioo_of_tendsto

theorem exists_seq_mono_tendsto (I : Box ι) :
    ∃ J : ℕ →o Box ι,
      (∀ n, (J n).icc ⊆ I.ioo) ∧ Tendsto (lower ∘ J) atTop (𝓝 I.lower) ∧ Tendsto (upper ∘ J) atTop (𝓝 I.upper) :=
  by
  choose a b ha_anti hb_mono ha_mem hb_mem hab ha_tendsto hb_tendsto using fun i =>
    exists_seq_strict_anti_strict_mono_tendsto (I.lower_lt_upper i)
  exact
    ⟨⟨fun k => ⟨flip a k, flip b k, fun i => hab _ _ _⟩, fun k l hkl =>
        le_iff_bounds.2 ⟨fun i => (ha_anti i).Antitone hkl, fun i => (hb_mono i).Monotone hkl⟩⟩,
      fun n x hx i hi => ⟨(ha_mem _ _).1.trans_le (hx.1 _), (hx.2 _).trans_lt (hb_mem _ _).2⟩,
      tendsto_pi_nhds.2 ha_tendsto, tendsto_pi_nhds.2 hb_tendsto⟩
#align box_integral.box.exists_seq_mono_tendsto BoxIntegral.Box.exists_seq_mono_tendsto

section Distortion

variable [Fintype ι]

/-- The distortion of a box `I` is the maximum of the ratios of the lengths of its edges.
It is defined as the maximum of the ratios
`nndist I.lower I.upper / nndist (I.lower i) (I.upper i)`. -/
def distortion (I : Box ι) : ℝ≥0 :=
  Finset.univ.sup fun i : ι => nndist I.lower I.upper / nndist (I.lower i) (I.upper i)
#align box_integral.box.distortion BoxIntegral.Box.distortion

theorem distortion_eq_of_sub_eq_div {I J : Box ι} {r : ℝ}
    (h : ∀ i, I.upper i - I.lower i = (J.upper i - J.lower i) / r) : distortion I = distortion J := by
  simp only [distortion, nndist_pi_def, Real.nndist_eq', h, map_div₀]
  congr 1 with i
  have : 0 < r := by
    by_contra hr
    have := div_nonpos_of_nonneg_of_nonpos (sub_nonneg.2 <| J.lower_le_upper i) (not_lt.1 hr)
    rw [← h] at this
    exact this.not_lt (sub_pos.2 <| I.lower_lt_upper i)
  simp_rw [Nnreal.finset_sup_div, div_div_div_cancel_right _ ((map_ne_zero Real.nnabs).2 this.ne')]
#align box_integral.box.distortion_eq_of_sub_eq_div BoxIntegral.Box.distortion_eq_of_sub_eq_div

theorem nndist_le_distortion_mul (I : Box ι) (i : ι) :
    nndist I.lower I.upper ≤ I.distortion * nndist (I.lower i) (I.upper i) :=
  calc
    nndist I.lower I.upper = nndist I.lower I.upper / nndist (I.lower i) (I.upper i) * nndist (I.lower i) (I.upper i) :=
      (div_mul_cancel _ <| mt nndist_eq_zero.1 (I.lower_lt_upper i).Ne).symm
    _ ≤ I.distortion * nndist (I.lower i) (I.upper i) := mul_le_mul_right' (Finset.le_sup <| Finset.mem_univ i) _
    
#align box_integral.box.nndist_le_distortion_mul BoxIntegral.Box.nndist_le_distortion_mul

theorem dist_le_distortion_mul (I : Box ι) (i : ι) : dist I.lower I.upper ≤ I.distortion * (I.upper i - I.lower i) := by
  have A : I.lower i - I.upper i < 0 := sub_neg.2 (I.lower_lt_upper i)
  simpa only [← Nnreal.coe_le_coe, ← dist_nndist, Nnreal.coe_mul, Real.dist_eq, abs_of_neg A, neg_sub] using
    I.nndist_le_distortion_mul i
#align box_integral.box.dist_le_distortion_mul BoxIntegral.Box.dist_le_distortion_mul

theorem diam_Icc_le_of_distortion_le (I : Box ι) (i : ι) {c : ℝ≥0} (h : I.distortion ≤ c) :
    diam I.icc ≤ c * (I.upper i - I.lower i) :=
  have : (0 : ℝ) ≤ c * (I.upper i - I.lower i) := mul_nonneg c.coe_nonneg (sub_nonneg.2 <| I.lower_le_upper _)
  (diam_le_of_forall_dist_le this) fun x hx y hy =>
    calc
      dist x y ≤ dist I.lower I.upper := Real.dist_le_of_mem_pi_Icc hx hy
      _ ≤ I.distortion * (I.upper i - I.lower i) := I.dist_le_distortion_mul i
      _ ≤ c * (I.upper i - I.lower i) := mul_le_mul_of_nonneg_right h (sub_nonneg.2 (I.lower_le_upper i))
      
#align box_integral.box.diam_Icc_le_of_distortion_le BoxIntegral.Box.diam_Icc_le_of_distortion_le

end Distortion

end Box

end BoxIntegral

