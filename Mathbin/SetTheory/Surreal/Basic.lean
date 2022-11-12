/-
Copyright (c) 2019 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Scott Morrison
-/
import Mathbin.Algebra.Order.Hom.Monoid
import Mathbin.SetTheory.Game.Ordinal

/-!
# Surreal numbers

The basic theory of surreal numbers, built on top of the theory of combinatorial (pre-)games.

A pregame is `numeric` if all the Left options are strictly smaller than all the Right options, and
all those options are themselves numeric. In terms of combinatorial games, the numeric games have
"frozen"; you can only make your position worse by playing, and Left is some definite "number" of
moves ahead (or behind) Right.

A surreal number is an equivalence class of numeric pregames.

In fact, the surreals form a complete ordered field, containing a copy of the reals (and much else
besides!) but we do not yet have a complete development.

## Order properties

Surreal numbers inherit the relations `≤` and `<` from games (`surreal.has_le` and
`surreal.has_lt`), and these relations satisfy the axioms of a partial order.

## Algebraic operations

We show that the surreals form a linear ordered commutative group.

One can also map all the ordinals into the surreals!

### Multiplication of surreal numbers

The proof that multiplication lifts to surreal numbers is surprisingly difficult and is currently
missing in the library. A sample proof can be found in Theorem 3.8 in the second reference below.
The difficulty lies in the length of the proof and the number of theorems that need to proven
simultaneously. This will make for a fun and challenging project.

The branch `surreal_mul` contains some progress on this proof.

### Todo

- Define the field structure on the surreals.

## References

* [Conway, *On numbers and games*][conway2001]
* [Schleicher, Stoll, *An introduction to Conway's games and numbers*][schleicher_stoll]
-/


universe u

open Pgame

namespace Pgame

/-- A pre-game is numeric if everything in the L set is less than everything in the R set,
and all the elements of L and R are also numeric. -/
def Numeric : Pgame → Prop
  | ⟨l, r, L, R⟩ => (∀ i j, L i < R j) ∧ (∀ i, numeric (L i)) ∧ ∀ j, numeric (R j)
#align pgame.numeric Pgame.Numeric

theorem numeric_def {x : Pgame} :
    Numeric x ↔ (∀ i j, x.moveLeft i < x.moveRight j) ∧ (∀ i, Numeric (x.moveLeft i)) ∧ ∀ j, Numeric (x.moveRight j) :=
  by
  cases x
  rfl
#align pgame.numeric_def Pgame.numeric_def

namespace Numeric

theorem mk {x : Pgame} (h₁ : ∀ i j, x.moveLeft i < x.moveRight j) (h₂ : ∀ i, Numeric (x.moveLeft i))
    (h₃ : ∀ j, Numeric (x.moveRight j)) : Numeric x :=
  numeric_def.2 ⟨h₁, h₂, h₃⟩
#align pgame.numeric.mk Pgame.Numeric.mk

theorem left_lt_right {x : Pgame} (o : Numeric x) (i : x.LeftMoves) (j : x.RightMoves) : x.moveLeft i < x.moveRight j :=
  by
  cases x
  exact o.1 i j
#align pgame.numeric.left_lt_right Pgame.Numeric.left_lt_right

theorem move_left {x : Pgame} (o : Numeric x) (i : x.LeftMoves) : Numeric (x.moveLeft i) := by
  cases x
  exact o.2.1 i
#align pgame.numeric.move_left Pgame.Numeric.move_left

theorem move_right {x : Pgame} (o : Numeric x) (j : x.RightMoves) : Numeric (x.moveRight j) := by
  cases x
  exact o.2.2 j
#align pgame.numeric.move_right Pgame.Numeric.move_right

end Numeric

@[elab_as_elim]
theorem numeric_rec {C : Pgame → Prop}
    (H :
      ∀ (l r) (L : l → Pgame) (R : r → Pgame),
        (∀ i j, L i < R j) →
          (∀ i, Numeric (L i)) → (∀ i, Numeric (R i)) → (∀ i, C (L i)) → (∀ i, C (R i)) → C ⟨l, r, L, R⟩) :
    ∀ x, Numeric x → C x
  | ⟨l, r, L, R⟩, ⟨h, hl, hr⟩ => H _ _ _ _ h hl hr (fun i => numeric_rec _ (hl i)) fun i => numeric_rec _ (hr i)
#align pgame.numeric_rec Pgame.numeric_rec

theorem Relabelling.numeric_imp {x y : Pgame} (r : x ≡r y) (ox : Numeric x) : Numeric y := by
  induction' x using Pgame.moveRecOn with x IHl IHr generalizing y
  apply numeric.mk (fun i j => _) (fun i => _) fun j => _
  · rw [← lt_congr (r.move_left_symm i).Equiv (r.move_right_symm j).Equiv]
    apply ox.left_lt_right
    
  · exact IHl _ (ox.move_left _) (r.move_left_symm i)
    
  · exact IHr _ (ox.move_right _) (r.move_right_symm j)
    
#align pgame.relabelling.numeric_imp Pgame.Relabelling.numeric_imp

/-- Relabellings preserve being numeric. -/
theorem Relabelling.numeric_congr {x y : Pgame} (r : x ≡r y) : Numeric x ↔ Numeric y :=
  ⟨r.numeric_imp, r.symm.numeric_imp⟩
#align pgame.relabelling.numeric_congr Pgame.Relabelling.numeric_congr

theorem lf_asymm {x y : Pgame} (ox : Numeric x) (oy : Numeric y) : x ⧏ y → ¬y ⧏ x := by
  refine' numeric_rec (fun xl xr xL xR hx oxl oxr IHxl IHxr => _) x ox y oy
  refine' numeric_rec fun yl yr yL yR hy oyl oyr IHyl IHyr => _
  rw [mk_lf_mk, mk_lf_mk]
  rintro (⟨i, h₁⟩ | ⟨j, h₁⟩) (⟨i, h₂⟩ | ⟨j, h₂⟩)
  · exact IHxl _ _ (oyl _) (h₁.move_left_lf _) (h₂.move_left_lf _)
    
  · exact (le_trans h₂ h₁).not_gf (lf_of_lt (hy _ _))
    
  · exact (le_trans h₁ h₂).not_gf (lf_of_lt (hx _ _))
    
  · exact IHxr _ _ (oyr _) (h₁.lf_move_right _) (h₂.lf_move_right _)
    
#align pgame.lf_asymm Pgame.lf_asymm

theorem le_of_lf {x y : Pgame} (h : x ⧏ y) (ox : Numeric x) (oy : Numeric y) : x ≤ y :=
  not_lf.1 (lf_asymm ox oy h)
#align pgame.le_of_lf Pgame.le_of_lf

alias le_of_lf ← lf.le

theorem lt_of_lf {x y : Pgame} (h : x ⧏ y) (ox : Numeric x) (oy : Numeric y) : x < y :=
  (lt_or_fuzzy_of_lf h).resolve_right (not_fuzzy_of_le (h.le ox oy))
#align pgame.lt_of_lf Pgame.lt_of_lf

alias lt_of_lf ← lf.lt

theorem lf_iff_lt {x y : Pgame} (ox : Numeric x) (oy : Numeric y) : x ⧏ y ↔ x < y :=
  ⟨fun h => h.lt ox oy, lf_of_lt⟩
#align pgame.lf_iff_lt Pgame.lf_iff_lt

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in apply_rules #[["[", expr numeric.move_left, ",", expr numeric.move_right, "]"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error -/
/-- Definition of `x ≤ y` on numeric pre-games, in terms of `<` -/
theorem le_iff_forall_lt {x y : Pgame} (ox : x.Numeric) (oy : y.Numeric) :
    x ≤ y ↔ (∀ i, x.moveLeft i < y) ∧ ∀ j, x < y.moveRight j := by
  refine' le_iff_forall_lf.trans (and_congr _ _) <;>
    refine' forall_congr' fun i => lf_iff_lt _ _ <;>
      trace
        "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in apply_rules #[[\"[\", expr numeric.move_left, \",\", expr numeric.move_right, \"]\"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error"
#align pgame.le_iff_forall_lt Pgame.le_iff_forall_lt

/-- Definition of `x < y` on numeric pre-games, in terms of `≤` -/
theorem lt_iff_exists_le {x y : Pgame} (ox : x.Numeric) (oy : y.Numeric) :
    x < y ↔ (∃ i, x ≤ y.moveLeft i) ∨ ∃ j, x.moveRight j ≤ y := by rw [← lf_iff_lt ox oy, lf_iff_exists_le]
#align pgame.lt_iff_exists_le Pgame.lt_iff_exists_le

theorem lt_of_exists_le {x y : Pgame} (ox : x.Numeric) (oy : y.Numeric) :
    ((∃ i, x ≤ y.moveLeft i) ∨ ∃ j, x.moveRight j ≤ y) → x < y :=
  (lt_iff_exists_le ox oy).2
#align pgame.lt_of_exists_le Pgame.lt_of_exists_le

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in apply_rules #[["[", expr numeric.move_left, ",", expr numeric.move_right, "]"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error -/
/-- The definition of `x < y` on numeric pre-games, in terms of `<` two moves later. -/
theorem lt_def {x y : Pgame} (ox : x.Numeric) (oy : y.Numeric) :
    x < y ↔
      (∃ i, (∀ i', x.moveLeft i' < y.moveLeft i) ∧ ∀ j, x < (y.moveLeft i).moveRight j) ∨
        ∃ j, (∀ i, (x.moveRight j).moveLeft i < y) ∧ ∀ j', x.moveRight j < y.moveRight j' :=
  by
  rw [← lf_iff_lt ox oy, lf_def]
  refine' or_congr _ _ <;>
    refine' exists_congr fun x_1 => _ <;>
      refine' and_congr _ _ <;>
        refine' forall_congr' fun i => lf_iff_lt _ _ <;>
          trace
            "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in apply_rules #[[\"[\", expr numeric.move_left, \",\", expr numeric.move_right, \"]\"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error"
#align pgame.lt_def Pgame.lt_def

theorem not_fuzzy {x y : Pgame} (ox : Numeric x) (oy : Numeric y) : ¬Fuzzy x y := fun h =>
  not_lf.2 ((lf_of_fuzzy h).le ox oy) h.2
#align pgame.not_fuzzy Pgame.not_fuzzy

theorem lt_or_equiv_or_gt {x y : Pgame} (ox : Numeric x) (oy : Numeric y) : x < y ∨ (x ≈ y) ∨ y < x :=
  ((lf_or_equiv_or_gf x y).imp fun h => h.lt ox oy) <| Or.imp_right fun h => h.lt oy ox
#align pgame.lt_or_equiv_or_gt Pgame.lt_or_equiv_or_gt

theorem numeric_of_is_empty (x : Pgame) [IsEmpty x.LeftMoves] [IsEmpty x.RightMoves] : Numeric x :=
  Numeric.mk isEmptyElim isEmptyElim isEmptyElim
#align pgame.numeric_of_is_empty Pgame.numeric_of_is_empty

theorem numeric_of_is_empty_left_moves (x : Pgame) [IsEmpty x.LeftMoves] : (∀ j, Numeric (x.moveRight j)) → Numeric x :=
  Numeric.mk isEmptyElim isEmptyElim
#align pgame.numeric_of_is_empty_left_moves Pgame.numeric_of_is_empty_left_moves

theorem numeric_of_is_empty_right_moves (x : Pgame) [IsEmpty x.RightMoves] (H : ∀ i, Numeric (x.moveLeft i)) :
    Numeric x :=
  Numeric.mk (fun _ => isEmptyElim) H isEmptyElim
#align pgame.numeric_of_is_empty_right_moves Pgame.numeric_of_is_empty_right_moves

theorem numeric_zero : Numeric 0 :=
  numeric_of_is_empty 0
#align pgame.numeric_zero Pgame.numeric_zero

theorem numeric_one : Numeric 1 :=
  (numeric_of_is_empty_right_moves 1) fun _ => numeric_zero
#align pgame.numeric_one Pgame.numeric_one

theorem Numeric.neg : ∀ {x : Pgame} (o : Numeric x), Numeric (-x)
  | ⟨l, r, L, R⟩, o => ⟨fun j i => neg_lt_neg_iff.2 (o.1 i j), fun j => (o.2.2 j).neg, fun i => (o.2.1 i).neg⟩
#align pgame.numeric.neg Pgame.Numeric.neg

namespace Numeric

theorem move_left_lt {x : Pgame} (o : Numeric x) (i) : x.moveLeft i < x :=
  (move_left_lf i).lt (o.moveLeft i) o
#align pgame.numeric.move_left_lt Pgame.Numeric.move_left_lt

theorem move_left_le {x : Pgame} (o : Numeric x) (i) : x.moveLeft i ≤ x :=
  (o.move_left_lt i).le
#align pgame.numeric.move_left_le Pgame.Numeric.move_left_le

theorem lt_move_right {x : Pgame} (o : Numeric x) (j) : x < x.moveRight j :=
  (lf_move_right j).lt o (o.moveRight j)
#align pgame.numeric.lt_move_right Pgame.Numeric.lt_move_right

theorem le_move_right {x : Pgame} (o : Numeric x) (j) : x ≤ x.moveRight j :=
  (o.lt_move_right j).le
#align pgame.numeric.le_move_right Pgame.Numeric.le_move_right

theorem add : ∀ {x y : Pgame} (ox : Numeric x) (oy : Numeric y), Numeric (x + y)
  | ⟨xl, xr, xL, xR⟩, ⟨yl, yr, yL, yR⟩, ox, oy =>
    ⟨by
      rintro (ix | iy) (jx | jy)
      · exact add_lt_add_right (ox.1 ix jx) _
        
      · exact
          (add_lf_add_of_lf_of_le (lf_mk _ _ ix) (oy.le_move_right jy)).lt ((ox.move_left ix).add oy)
            (ox.add (oy.move_right jy))
        
      · exact
          (add_lf_add_of_lf_of_le (mk_lf _ _ jx) (oy.move_left_le iy)).lt (ox.add (oy.move_left iy))
            ((ox.move_right jx).add oy)
        
      · exact add_lt_add_left (oy.1 iy jy) ⟨xl, xr, xL, xR⟩
        ,
      by
      constructor
      · rintro (ix | iy)
        · exact (ox.move_left ix).add oy
          
        · exact ox.add (oy.move_left iy)
          
        
      · rintro (jx | jy)
        · apply (ox.move_right jx).add oy
          
        · apply ox.add (oy.move_right jy)
          
        ⟩
#align pgame.numeric.add Pgame.Numeric.add

theorem sub {x y : Pgame} (ox : Numeric x) (oy : Numeric y) : Numeric (x - y) :=
  ox.add oy.neg
#align pgame.numeric.sub Pgame.Numeric.sub

end Numeric

/-- Pre-games defined by natural numbers are numeric. -/
theorem numeric_nat : ∀ n : ℕ, Numeric n
  | 0 => numeric_zero
  | n + 1 => (numeric_nat n).add numeric_one
#align pgame.numeric_nat Pgame.numeric_nat

/-- Ordinal games are numeric. -/
theorem numeric_to_pgame (o : Ordinal) : o.toPgame.Numeric := by
  induction' o using Ordinal.induction with o IH
  apply numeric_of_is_empty_right_moves
  simpa using fun i => IH _ (Ordinal.to_left_moves_to_pgame_symm_lt i)
#align pgame.numeric_to_pgame Pgame.numeric_to_pgame

end Pgame

open Pgame

/-- The type of surreal numbers. These are the numeric pre-games quotiented
by the equivalence relation `x ≈ y ↔ x ≤ y ∧ y ≤ x`. In the quotient,
the order becomes a total order. -/
def Surreal :=
  Quotient (Subtype.setoid Numeric)
#align surreal Surreal

namespace Surreal

/-- Construct a surreal number from a numeric pre-game. -/
def mk (x : Pgame) (h : x.Numeric) : Surreal :=
  ⟦⟨x, h⟩⟧
#align surreal.mk Surreal.mk

instance : Zero Surreal :=
  ⟨mk 0 numeric_zero⟩

instance : One Surreal :=
  ⟨mk 1 numeric_one⟩

instance : Inhabited Surreal :=
  ⟨0⟩

/-- Lift an equivalence-respecting function on pre-games to surreals. -/
def lift {α} (f : ∀ x, Numeric x → α) (H : ∀ {x y} (hx : Numeric x) (hy : Numeric y), x.Equiv y → f x hx = f y hy) :
    Surreal → α :=
  Quotient.lift (fun x : { x // Numeric x } => f x.1 x.2) fun x y => H x.2 y.2
#align surreal.lift Surreal.lift

/-- Lift a binary equivalence-respecting function on pre-games to surreals. -/
def lift₂ {α} (f : ∀ x y, Numeric x → Numeric y → α)
    (H :
      ∀ {x₁ y₁ x₂ y₂} (ox₁ : Numeric x₁) (oy₁ : Numeric y₁) (ox₂ : Numeric x₂) (oy₂ : Numeric y₂),
        x₁.Equiv x₂ → y₁.Equiv y₂ → f x₁ y₁ ox₁ oy₁ = f x₂ y₂ ox₂ oy₂) :
    Surreal → Surreal → α :=
  lift (fun x ox => lift (fun y oy => f x y ox oy) fun y₁ y₂ oy₁ oy₂ => H _ _ _ _ equiv_rfl) fun x₁ x₂ ox₁ ox₂ h =>
    funext <| Quotient.ind fun ⟨y, oy⟩ => H _ _ _ _ h equiv_rfl
#align surreal.lift₂ Surreal.lift₂

instance : LE Surreal :=
  ⟨lift₂ (fun x y _ _ => x ≤ y) fun x₁ y₁ x₂ y₂ _ _ _ _ hx hy => propext (le_congr hx hy)⟩

instance : LT Surreal :=
  ⟨lift₂ (fun x y _ _ => x < y) fun x₁ y₁ x₂ y₂ _ _ _ _ hx hy => propext (lt_congr hx hy)⟩

/-- Addition on surreals is inherited from pre-game addition:
the sum of `x = {xL | xR}` and `y = {yL | yR}` is `{xL + y, x + yL | xR + y, x + yR}`. -/
instance : Add Surreal :=
  ⟨Surreal.lift₂ (fun (x y : Pgame) ox oy => ⟦⟨x + y, ox.add oy⟩⟧) fun x₁ y₁ x₂ y₂ _ _ _ _ hx hy =>
      Quotient.sound (add_congr hx hy)⟩

/-- Negation for surreal numbers is inherited from pre-game negation:
the negation of `{L | R}` is `{-R | -L}`. -/
instance : Neg Surreal :=
  ⟨Surreal.lift (fun x ox => ⟦⟨-x, ox.neg⟩⟧) fun _ _ _ _ a => Quotient.sound (neg_equiv_neg_iff.2 a)⟩

instance : OrderedAddCommGroup Surreal where
  add := (· + ·)
  add_assoc := by
    rintro ⟨_⟩ ⟨_⟩ ⟨_⟩
    exact Quotient.sound add_assoc_equiv
  zero := 0
  zero_add := by
    rintro ⟨_⟩
    exact Quotient.sound (zero_add_equiv a)
  add_zero := by
    rintro ⟨_⟩
    exact Quotient.sound (add_zero_equiv a)
  neg := Neg.neg
  add_left_neg := by
    rintro ⟨_⟩
    exact Quotient.sound (add_left_neg_equiv a)
  add_comm := by
    rintro ⟨_⟩ ⟨_⟩
    exact Quotient.sound add_comm_equiv
  le := (· ≤ ·)
  lt := (· < ·)
  le_refl := by
    rintro ⟨_⟩
    apply @le_rfl Pgame
  le_trans := by
    rintro ⟨_⟩ ⟨_⟩ ⟨_⟩
    apply @le_trans Pgame
  lt_iff_le_not_le := by
    rintro ⟨_, ox⟩ ⟨_, oy⟩
    apply @lt_iff_le_not_le Pgame
  le_antisymm := by
    rintro ⟨_⟩ ⟨_⟩ h₁ h₂
    exact Quotient.sound ⟨h₁, h₂⟩
  add_le_add_left := by
    rintro ⟨_⟩ ⟨_⟩ hx ⟨_⟩
    exact @add_le_add_left Pgame _ _ _ _ _ hx _

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [(Command.noncomputable "noncomputable")] [] [])
     (Command.instance
      (Term.attrKind [])
      "instance"
      []
      []
      (Command.declSig [] (Term.typeSpec ":" (Term.app `LinearOrderedAddCommGroup [`Surreal])))
      (Command.declValSimple
       ":="
       (Term.structInst
        "{"
        [[`Surreal.orderedAddCommGroup] "with"]
        [(Term.structInstField
          (Term.structInstLVal `le_total [])
          ":="
          (Term.byTactic
           "by"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Tactic.«tactic_<;>_»
               (Std.Tactic.rintro
                "rintro"
                [(Std.Tactic.RCases.rintroPat.one
                  (Std.Tactic.RCases.rcasesPat.tuple
                   "⟨"
                   [(Std.Tactic.RCases.rcasesPatLo
                     (Std.Tactic.RCases.rcasesPatMed
                      [(Std.Tactic.RCases.rcasesPat.tuple
                        "⟨"
                        [(Std.Tactic.RCases.rcasesPatLo
                          (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `x)])
                          [])
                         ","
                         (Std.Tactic.RCases.rcasesPatLo
                          (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `ox)])
                          [])]
                        "⟩")])
                     [])]
                   "⟩"))
                 (Std.Tactic.RCases.rintroPat.one
                  (Std.Tactic.RCases.rcasesPat.tuple
                   "⟨"
                   [(Std.Tactic.RCases.rcasesPatLo
                     (Std.Tactic.RCases.rcasesPatMed
                      [(Std.Tactic.RCases.rcasesPat.tuple
                        "⟨"
                        [(Std.Tactic.RCases.rcasesPatLo
                          (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `y)])
                          [])
                         ","
                         (Std.Tactic.RCases.rcasesPatLo
                          (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `oy)])
                          [])]
                        "⟩")])
                     [])]
                   "⟩"))]
                [])
               "<;>"
               (Tactic.«tactic_<;>_»
                (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
                "<;>"
                (Tactic.exact
                 "exact"
                 (Term.app
                  (Term.proj `or_iff_not_imp_left "." (fieldIdx "2"))
                  [(Term.fun
                    "fun"
                    (Term.basicFun
                     [`h]
                     []
                     "=>"
                     (Term.app
                      (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le)
                      [`oy `ox])))]))))]))))
         ","
         (Term.structInstField
          (Term.structInstLVal `decidableLe [])
          ":="
          (Term.app `Classical.decRel [(Term.hole "_")]))]
        (Term.optEllipsis [])
        []
        "}")
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.theorem'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.structInst
       "{"
       [[`Surreal.orderedAddCommGroup] "with"]
       [(Term.structInstField
         (Term.structInstLVal `le_total [])
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Tactic.«tactic_<;>_»
              (Std.Tactic.rintro
               "rintro"
               [(Std.Tactic.RCases.rintroPat.one
                 (Std.Tactic.RCases.rcasesPat.tuple
                  "⟨"
                  [(Std.Tactic.RCases.rcasesPatLo
                    (Std.Tactic.RCases.rcasesPatMed
                     [(Std.Tactic.RCases.rcasesPat.tuple
                       "⟨"
                       [(Std.Tactic.RCases.rcasesPatLo
                         (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `x)])
                         [])
                        ","
                        (Std.Tactic.RCases.rcasesPatLo
                         (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `ox)])
                         [])]
                       "⟩")])
                    [])]
                  "⟩"))
                (Std.Tactic.RCases.rintroPat.one
                 (Std.Tactic.RCases.rcasesPat.tuple
                  "⟨"
                  [(Std.Tactic.RCases.rcasesPatLo
                    (Std.Tactic.RCases.rcasesPatMed
                     [(Std.Tactic.RCases.rcasesPat.tuple
                       "⟨"
                       [(Std.Tactic.RCases.rcasesPatLo
                         (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `y)])
                         [])
                        ","
                        (Std.Tactic.RCases.rcasesPatLo
                         (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `oy)])
                         [])]
                       "⟩")])
                    [])]
                  "⟩"))]
               [])
              "<;>"
              (Tactic.«tactic_<;>_»
               (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
               "<;>"
               (Tactic.exact
                "exact"
                (Term.app
                 (Term.proj `or_iff_not_imp_left "." (fieldIdx "2"))
                 [(Term.fun
                   "fun"
                   (Term.basicFun
                    [`h]
                    []
                    "=>"
                    (Term.app
                     (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le)
                     [`oy `ox])))]))))]))))
        ","
        (Term.structInstField
         (Term.structInstLVal `decidableLe [])
         ":="
         (Term.app `Classical.decRel [(Term.hole "_")]))]
       (Term.optEllipsis [])
       []
       "}")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.structInstField', expected 'Lean.Parser.Term.structInstFieldAbbrev'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Classical.decRel [(Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Classical.decRel
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.structInstField', expected 'Lean.Parser.Term.structInstFieldAbbrev'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.«tactic_<;>_»
           (Std.Tactic.rintro
            "rintro"
            [(Std.Tactic.RCases.rintroPat.one
              (Std.Tactic.RCases.rcasesPat.tuple
               "⟨"
               [(Std.Tactic.RCases.rcasesPatLo
                 (Std.Tactic.RCases.rcasesPatMed
                  [(Std.Tactic.RCases.rcasesPat.tuple
                    "⟨"
                    [(Std.Tactic.RCases.rcasesPatLo
                      (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `x)])
                      [])
                     ","
                     (Std.Tactic.RCases.rcasesPatLo
                      (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `ox)])
                      [])]
                    "⟩")])
                 [])]
               "⟩"))
             (Std.Tactic.RCases.rintroPat.one
              (Std.Tactic.RCases.rcasesPat.tuple
               "⟨"
               [(Std.Tactic.RCases.rcasesPatLo
                 (Std.Tactic.RCases.rcasesPatMed
                  [(Std.Tactic.RCases.rcasesPat.tuple
                    "⟨"
                    [(Std.Tactic.RCases.rcasesPatLo
                      (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `y)])
                      [])
                     ","
                     (Std.Tactic.RCases.rcasesPatLo
                      (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `oy)])
                      [])]
                    "⟩")])
                 [])]
               "⟩"))]
            [])
           "<;>"
           (Tactic.«tactic_<;>_»
            (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
            "<;>"
            (Tactic.exact
             "exact"
             (Term.app
              (Term.proj `or_iff_not_imp_left "." (fieldIdx "2"))
              [(Term.fun
                "fun"
                (Term.basicFun
                 [`h]
                 []
                 "=>"
                 (Term.app
                  (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le)
                  [`oy `ox])))]))))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.«tactic_<;>_»
       (Std.Tactic.rintro
        "rintro"
        [(Std.Tactic.RCases.rintroPat.one
          (Std.Tactic.RCases.rcasesPat.tuple
           "⟨"
           [(Std.Tactic.RCases.rcasesPatLo
             (Std.Tactic.RCases.rcasesPatMed
              [(Std.Tactic.RCases.rcasesPat.tuple
                "⟨"
                [(Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `x)])
                  [])
                 ","
                 (Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `ox)])
                  [])]
                "⟩")])
             [])]
           "⟩"))
         (Std.Tactic.RCases.rintroPat.one
          (Std.Tactic.RCases.rcasesPat.tuple
           "⟨"
           [(Std.Tactic.RCases.rcasesPatLo
             (Std.Tactic.RCases.rcasesPatMed
              [(Std.Tactic.RCases.rcasesPat.tuple
                "⟨"
                [(Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `y)])
                  [])
                 ","
                 (Std.Tactic.RCases.rcasesPatLo
                  (Std.Tactic.RCases.rcasesPatMed [(Std.Tactic.RCases.rcasesPat.one `oy)])
                  [])]
                "⟩")])
             [])]
           "⟩"))]
        [])
       "<;>"
       (Tactic.«tactic_<;>_»
        (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
        "<;>"
        (Tactic.exact
         "exact"
         (Term.app
          (Term.proj `or_iff_not_imp_left "." (fieldIdx "2"))
          [(Term.fun
            "fun"
            (Term.basicFun
             [`h]
             []
             "=>"
             (Term.app
              (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le)
              [`oy `ox])))]))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.«tactic_<;>_»
       (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
       "<;>"
       (Tactic.exact
        "exact"
        (Term.app
         (Term.proj `or_iff_not_imp_left "." (fieldIdx "2"))
         [(Term.fun
           "fun"
           (Term.basicFun
            [`h]
            []
            "=>"
            (Term.app (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le) [`oy `ox])))])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.app
        (Term.proj `or_iff_not_imp_left "." (fieldIdx "2"))
        [(Term.fun
          "fun"
          (Term.basicFun
           [`h]
           []
           "=>"
           (Term.app (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le) [`oy `ox])))]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       (Term.proj `or_iff_not_imp_left "." (fieldIdx "2"))
       [(Term.fun
         "fun"
         (Term.basicFun
          [`h]
          []
          "=>"
          (Term.app (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le) [`oy `ox])))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`h]
        []
        "=>"
        (Term.app (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le) [`oy `ox])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le) [`oy `ox])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ox
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `oy
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) "." `le)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `Pgame.not_le "." (fieldIdx "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `Pgame.not_le
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     [(Term.app (Term.proj `Pgame.not_le "." (fieldIdx "1")) [`h]) []]
     ")")
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `or_iff_not_imp_left "." (fieldIdx "2"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `or_iff_not_imp_left
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1, tactic))
      (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.skip', expected 'Lean.Parser.Tactic.tacticSeq'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.instance', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
noncomputable
  instance
    : LinearOrderedAddCommGroup Surreal
    :=
      {
        Surreal.orderedAddCommGroup with
        le_total
            :=
            by
              rintro ⟨ ⟨ x , ox ⟩ ⟩ ⟨ ⟨ y , oy ⟩ ⟩
                <;>
                skip <;> exact or_iff_not_imp_left . 2 fun h => Pgame.not_le . 1 h . le oy ox
          ,
          decidableLe := Classical.decRel _
        }

instance : AddMonoidWithOne Surreal :=
  AddMonoidWithOne.unary

/-- Casts a `surreal` number into a `game`. -/
def toGame : Surreal →+o Game where
  toFun := lift (fun x _ => ⟦x⟧) fun x y ox oy => Quot.sound
  map_zero' := rfl
  map_add' := by
    rintro ⟨_, _⟩ ⟨_, _⟩
    rfl
  monotone' := by
    rintro ⟨_, _⟩ ⟨_, _⟩
    exact id
#align surreal.to_game Surreal.toGame

theorem zero_to_game : toGame 0 = 0 :=
  rfl
#align surreal.zero_to_game Surreal.zero_to_game

@[simp]
theorem one_to_game : toGame 1 = 1 :=
  rfl
#align surreal.one_to_game Surreal.one_to_game

@[simp]
theorem nat_to_game : ∀ n : ℕ, toGame n = n :=
  map_nat_cast' _ one_to_game
#align surreal.nat_to_game Surreal.nat_to_game

end Surreal

open Surreal

namespace Ordinal

/-- Converts an ordinal into the corresponding surreal. -/
noncomputable def toSurreal : Ordinal ↪o Surreal where
  toFun o := mk _ (numeric_to_pgame o)
  inj' a b h := to_pgame_equiv_iff.1 (Quotient.exact h)
  map_rel_iff' := @to_pgame_le_iff
#align ordinal.to_surreal Ordinal.toSurreal

end Ordinal

