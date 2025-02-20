/-
Copyright (c) 2019 Kevin Kappelmann. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Kappelmann

! This file was ported from Lean 3 source module algebra.continued_fractions.basic
! leanprover-community/mathlib commit fe8d0ff42c3c24d789f491dc2622b6cac3d61564
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Seq.Seq
import Mathbin.Algebra.Field.Defs

/-!
# Basic Definitions/Theorems for Continued Fractions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Summary

We define generalised, simple, and regular continued fractions and functions to evaluate their
convergents. We follow the naming conventions from Wikipedia and [wall2018analytic], Chapter 1.

## Main definitions

1. Generalised continued fractions (gcfs)
2. Simple continued fractions (scfs)
3. (Regular) continued fractions ((r)cfs)
4. Computation of convergents using the recurrence relation in `convergents`.
5. Computation of convergents by directly evaluating the fraction described by the gcf in
`convergents'`.

## Implementation notes

1. The most commonly used kind of continued fractions in the literature are regular continued
fractions. We hence just call them `continued_fractions` in the library.
2. We use sequences from `data.seq` to encode potentially infinite sequences.

## References

- <https://en.wikipedia.org/wiki/Generalized_continued_fraction>
- [Wall, H.S., *Analytic Theory of Continued Fractions*][wall2018analytic]

## Tags

numerics, number theory, approximations, fractions
-/


-- Fix a carrier `α`.
variable (α : Type _)

/-!### Definitions-/


#print GeneralizedContinuedFraction.Pair /-
/-- We collect a partial numerator `aᵢ` and partial denominator `bᵢ` in a pair `⟨aᵢ,bᵢ⟩`. -/
protected structure GeneralizedContinuedFraction.Pair where
  a : α
  b : α
  deriving Inhabited
#align generalized_continued_fraction.pair GeneralizedContinuedFraction.Pair
-/

open GeneralizedContinuedFraction

/- ./././Mathport/Syntax/Translate/Command.lean:230:11: unsupported: unusual advanced open style -/
/-! Interlude: define some expected coercions and instances. -/


namespace GeneralizedContinuedFraction.Pair

variable {α}

/-- Make a `gcf.pair` printable. -/
instance [Repr α] : Repr (Pair α) :=
  ⟨fun p => "(a : " ++ repr p.a ++ ", b : " ++ repr p.b ++ ")"⟩

#print GeneralizedContinuedFraction.Pair.map /-
/-- Maps a function `f` on both components of a given pair. -/
def map {β : Type _} (f : α → β) (gp : Pair α) : Pair β :=
  ⟨f gp.a, f gp.b⟩
#align generalized_continued_fraction.pair.map GeneralizedContinuedFraction.Pair.map
-/

section coe

-- Fix another type `β` which we will convert to.
variable {β : Type _} [Coe α β]

/-- Coerce a pair by elementwise coercion. -/
instance hasCoeToGeneralizedContinuedFractionPair : Coe (Pair α) (Pair β) :=
  ⟨map coe⟩
#align generalized_continued_fraction.pair.has_coe_to_generalized_continued_fraction_pair GeneralizedContinuedFraction.Pair.hasCoeToGeneralizedContinuedFractionPair

#print GeneralizedContinuedFraction.Pair.coe_toPair /-
@[simp, norm_cast]
theorem coe_toPair {a b : α} : (↑(Pair.mk a b) : Pair β) = Pair.mk (a : β) (b : β) :=
  rfl
#align generalized_continued_fraction.pair.coe_to_generalized_continued_fraction_pair GeneralizedContinuedFraction.Pair.coe_toPair
-/

end coe

end GeneralizedContinuedFraction.Pair

variable (α)

#print GeneralizedContinuedFraction /-
/-- A *generalised continued fraction* (gcf) is a potentially infinite expression of the form
$$
  h + \dfrac{a_0}
            {b_0 + \dfrac{a_1}
                         {b_1 + \dfrac{a_2}
                                      {b_2 + \dfrac{a_3}
                                                   {b_3 + \dots}}}}
$$
where `h` is called the *head term* or *integer part*, the `aᵢ` are called the
*partial numerators* and the `bᵢ` the *partial denominators* of the gcf.
We store the sequence of partial numerators and denominators in a sequence of
generalized_continued_fraction.pairs `s`.
For convenience, one often writes `[h; (a₀, b₀), (a₁, b₁), (a₂, b₂),...]`.
-/
structure GeneralizedContinuedFraction where
  h : α
  s : Seq <| Pair α
#align generalized_continued_fraction GeneralizedContinuedFraction
-/

variable {α}

namespace GeneralizedContinuedFraction

#print GeneralizedContinuedFraction.ofInteger /-
/-- Constructs a generalized continued fraction without fractional part. -/
def ofInteger (a : α) : GeneralizedContinuedFraction α :=
  ⟨a, Seq.nil⟩
#align generalized_continued_fraction.of_integer GeneralizedContinuedFraction.ofInteger
-/

instance [Inhabited α] : Inhabited (GeneralizedContinuedFraction α) :=
  ⟨ofInteger default⟩

#print GeneralizedContinuedFraction.partialNumerators /-
/-- Returns the sequence of partial numerators `aᵢ` of `g`. -/
def partialNumerators (g : GeneralizedContinuedFraction α) : Seq α :=
  g.s.map Pair.a
#align generalized_continued_fraction.partial_numerators GeneralizedContinuedFraction.partialNumerators
-/

#print GeneralizedContinuedFraction.partialDenominators /-
/-- Returns the sequence of partial denominators `bᵢ` of `g`. -/
def partialDenominators (g : GeneralizedContinuedFraction α) : Seq α :=
  g.s.map Pair.b
#align generalized_continued_fraction.partial_denominators GeneralizedContinuedFraction.partialDenominators
-/

#print GeneralizedContinuedFraction.TerminatedAt /-
/-- A gcf terminated at position `n` if its sequence terminates at position `n`. -/
def TerminatedAt (g : GeneralizedContinuedFraction α) (n : ℕ) : Prop :=
  g.s.TerminatedAt n
#align generalized_continued_fraction.terminated_at GeneralizedContinuedFraction.TerminatedAt
-/

#print GeneralizedContinuedFraction.terminatedAtDecidable /-
/-- It is decidable whether a gcf terminated at a given position. -/
instance terminatedAtDecidable (g : GeneralizedContinuedFraction α) (n : ℕ) :
    Decidable (g.TerminatedAt n) := by unfold terminated_at; infer_instance
#align generalized_continued_fraction.terminated_at_decidable GeneralizedContinuedFraction.terminatedAtDecidable
-/

#print GeneralizedContinuedFraction.Terminates /-
/-- A gcf terminates if its sequence terminates. -/
def Terminates (g : GeneralizedContinuedFraction α) : Prop :=
  g.s.Terminates
#align generalized_continued_fraction.terminates GeneralizedContinuedFraction.Terminates
-/

section coe

/-! Interlude: define some expected coercions. -/


-- Fix another type `β` which we will convert to.
variable {β : Type _} [Coe α β]

/-- Coerce a gcf by elementwise coercion. -/
instance hasCoeToGeneralizedContinuedFraction :
    Coe (GeneralizedContinuedFraction α) (GeneralizedContinuedFraction β) :=
  ⟨fun g => ⟨(g.h : β), (g.s.map coe : Seq <| Pair β)⟩⟩
#align generalized_continued_fraction.has_coe_to_generalized_continued_fraction GeneralizedContinuedFraction.hasCoeToGeneralizedContinuedFraction

#print GeneralizedContinuedFraction.coe_toGeneralizedContinuedFraction /-
@[simp, norm_cast]
theorem coe_toGeneralizedContinuedFraction {g : GeneralizedContinuedFraction α} :
    (↑(g : GeneralizedContinuedFraction α) : GeneralizedContinuedFraction β) =
      ⟨(g.h : β), (g.s.map coe : Seq <| Pair β)⟩ :=
  rfl
#align generalized_continued_fraction.coe_to_generalized_continued_fraction GeneralizedContinuedFraction.coe_toGeneralizedContinuedFraction
-/

end coe

end GeneralizedContinuedFraction

#print GeneralizedContinuedFraction.IsSimpleContinuedFraction /-
/-- A generalized continued fraction is a *simple continued fraction* if all partial numerators are
equal to one.
$$
  h + \dfrac{1}
            {b_0 + \dfrac{1}
                         {b_1 + \dfrac{1}
                                      {b_2 + \dfrac{1}
                                                   {b_3 + \dots}}}}
$$
-/
def GeneralizedContinuedFraction.IsSimpleContinuedFraction (g : GeneralizedContinuedFraction α)
    [One α] : Prop :=
  ∀ (n : ℕ) (aₙ : α), g.partialNumerators.get? n = some aₙ → aₙ = 1
#align generalized_continued_fraction.is_simple_continued_fraction GeneralizedContinuedFraction.IsSimpleContinuedFraction
-/

variable (α)

#print SimpleContinuedFraction /-
/-- A *simple continued fraction* (scf) is a generalized continued fraction (gcf) whose partial
numerators are equal to one.
$$
  h + \dfrac{1}
            {b_0 + \dfrac{1}
                         {b_1 + \dfrac{1}
                                      {b_2 + \dfrac{1}
                                                   {b_3 + \dots}}}}
$$
For convenience, one often writes `[h; b₀, b₁, b₂,...]`.
It is encoded as the subtype of gcfs that satisfy
`generalized_continued_fraction.is_simple_continued_fraction`.
 -/
def SimpleContinuedFraction [One α] :=
  { g : GeneralizedContinuedFraction α // g.IsSimpleContinuedFraction }
#align simple_continued_fraction SimpleContinuedFraction
-/

variable {α}

-- Interlude: define some expected coercions.
namespace SimpleContinuedFraction

variable [One α]

#print SimpleContinuedFraction.ofInteger /-
/-- Constructs a simple continued fraction without fractional part. -/
def ofInteger (a : α) : SimpleContinuedFraction α :=
  ⟨GeneralizedContinuedFraction.ofInteger a, fun n aₙ h => by cases h⟩
#align simple_continued_fraction.of_integer SimpleContinuedFraction.ofInteger
-/

instance : Inhabited (SimpleContinuedFraction α) :=
  ⟨ofInteger 1⟩

/-- Lift a scf to a gcf using the inclusion map. -/
instance hasCoeToGeneralizedContinuedFraction :
    Coe (SimpleContinuedFraction α) (GeneralizedContinuedFraction α) := by
  unfold SimpleContinuedFraction; infer_instance
#align simple_continued_fraction.has_coe_to_generalized_continued_fraction SimpleContinuedFraction.hasCoeToGeneralizedContinuedFraction

theorem coe_to_generalizedContinuedFraction {s : SimpleContinuedFraction α} :
    (↑s : GeneralizedContinuedFraction α) = s.val :=
  rfl
#align simple_continued_fraction.coe_to_generalized_continued_fraction SimpleContinuedFraction.coe_to_generalizedContinuedFraction

end SimpleContinuedFraction

#print SimpleContinuedFraction.IsContinuedFraction /-
/--
A simple continued fraction is a *(regular) continued fraction* ((r)cf) if all partial denominators
`bᵢ` are positive, i.e. `0 < bᵢ`.
-/
def SimpleContinuedFraction.IsContinuedFraction [One α] [Zero α] [LT α]
    (s : SimpleContinuedFraction α) : Prop :=
  ∀ (n : ℕ) (bₙ : α),
    (↑s : GeneralizedContinuedFraction α).partialDenominators.get? n = some bₙ → 0 < bₙ
#align simple_continued_fraction.is_continued_fraction SimpleContinuedFraction.IsContinuedFraction
-/

variable (α)

#print ContinuedFraction /-
/-- A *(regular) continued fraction* ((r)cf) is a simple continued fraction (scf) whose partial
denominators are all positive. It is the subtype of scfs that satisfy
`simple_continued_fraction.is_continued_fraction`.
 -/
def ContinuedFraction [One α] [Zero α] [LT α] :=
  { s : SimpleContinuedFraction α // s.IsContinuedFraction }
#align continued_fraction ContinuedFraction
-/

variable {α}

/-! Interlude: define some expected coercions. -/


namespace ContinuedFraction

variable [One α] [Zero α] [LT α]

#print ContinuedFraction.ofInteger /-
/-- Constructs a continued fraction without fractional part. -/
def ofInteger (a : α) : ContinuedFraction α :=
  ⟨SimpleContinuedFraction.ofInteger a, fun n bₙ h => by cases h⟩
#align continued_fraction.of_integer ContinuedFraction.ofInteger
-/

instance : Inhabited (ContinuedFraction α) :=
  ⟨ofInteger 0⟩

/-- Lift a cf to a scf using the inclusion map. -/
instance hasCoeToSimpleContinuedFraction : Coe (ContinuedFraction α) (SimpleContinuedFraction α) :=
  by unfold ContinuedFraction; infer_instance
#align continued_fraction.has_coe_to_simple_continued_fraction ContinuedFraction.hasCoeToSimpleContinuedFraction

theorem coe_to_simpleContinuedFraction {c : ContinuedFraction α} :
    (↑c : SimpleContinuedFraction α) = c.val :=
  rfl
#align continued_fraction.coe_to_simple_continued_fraction ContinuedFraction.coe_to_simpleContinuedFraction

/-- Lift a cf to a scf using the inclusion map. -/
instance hasCoeToGeneralizedContinuedFraction :
    Coe (ContinuedFraction α) (GeneralizedContinuedFraction α) :=
  ⟨fun c => ↑(↑c : SimpleContinuedFraction α)⟩
#align continued_fraction.has_coe_to_generalized_continued_fraction ContinuedFraction.hasCoeToGeneralizedContinuedFraction

theorem coe_to_generalizedContinuedFraction {c : ContinuedFraction α} :
    (↑c : GeneralizedContinuedFraction α) = c.val :=
  rfl
#align continued_fraction.coe_to_generalized_continued_fraction ContinuedFraction.coe_to_generalizedContinuedFraction

end ContinuedFraction

namespace GeneralizedContinuedFraction

/-!
### Computation of Convergents

We now define how to compute the convergents of a gcf. There are two standard ways to do this:
directly evaluating the (infinite) fraction described by the gcf or using a recurrence relation.
For (r)cfs, these computations are equivalent as shown in
`algebra.continued_fractions.convergents_equiv`.
-/


-- Fix a division ring for the computations.
variable {K : Type _} [DivisionRing K]

/-!
We start with the definition of the recurrence relation. Given a gcf `g`, for all `n ≥ 1`, we define
- `A₋₁ = 1,  A₀ = h,  Aₙ = bₙ₋₁ * Aₙ₋₁ + aₙ₋₁ * Aₙ₋₂`, and
- `B₋₁ = 0,  B₀ = 1,  Bₙ = bₙ₋₁ * Bₙ₋₁ + aₙ₋₁ * Bₙ₋₂`.

`Aₙ, `Bₙ` are called the *nth continuants*, Aₙ the *nth numerator*, and `Bₙ` the
*nth denominator* of `g`. The *nth convergent* of `g` is given by `Aₙ / Bₙ`.
-/


#print GeneralizedContinuedFraction.nextNumerator /-
/-- Returns the next numerator `Aₙ = bₙ₋₁ * Aₙ₋₁ + aₙ₋₁ * Aₙ₋₂`, where `predA` is `Aₙ₋₁`,
`ppredA` is `Aₙ₋₂`, `a` is `aₙ₋₁`, and `b` is `bₙ₋₁`.
-/
def nextNumerator (a b ppredA predA : K) : K :=
  b * predA + a * ppredA
#align generalized_continued_fraction.next_numerator GeneralizedContinuedFraction.nextNumerator
-/

#print GeneralizedContinuedFraction.nextDenominator /-
/-- Returns the next denominator `Bₙ = bₙ₋₁ * Bₙ₋₁ + aₙ₋₁ * Bₙ₋₂``, where `predB` is `Bₙ₋₁` and
`ppredB` is `Bₙ₋₂`, `a` is `aₙ₋₁`, and `b` is `bₙ₋₁`.
-/
def nextDenominator (aₙ bₙ ppredB predB : K) : K :=
  bₙ * predB + aₙ * ppredB
#align generalized_continued_fraction.next_denominator GeneralizedContinuedFraction.nextDenominator
-/

#print GeneralizedContinuedFraction.nextContinuants /-
/--
Returns the next continuants `⟨Aₙ, Bₙ⟩` using `next_numerator` and `next_denominator`, where `pred`
is `⟨Aₙ₋₁, Bₙ₋₁⟩`, `ppred` is `⟨Aₙ₋₂, Bₙ₋₂⟩`, `a` is `aₙ₋₁`, and `b` is `bₙ₋₁`.
-/
def nextContinuants (a b : K) (ppred pred : Pair K) : Pair K :=
  ⟨nextNumerator a b ppred.a pred.a, nextDenominator a b ppred.b pred.b⟩
#align generalized_continued_fraction.next_continuants GeneralizedContinuedFraction.nextContinuants
-/

#print GeneralizedContinuedFraction.continuantsAux /-
/-- Returns the continuants `⟨Aₙ₋₁, Bₙ₋₁⟩` of `g`. -/
def continuantsAux (g : GeneralizedContinuedFraction K) : Stream' (Pair K)
  | 0 => ⟨1, 0⟩
  | 1 => ⟨g.h, 1⟩
  | n + 2 =>
    match g.s.get? n with
    | none => continuants_aux (n + 1)
    | some gp => nextContinuants gp.a gp.b (continuants_aux n) (continuants_aux <| n + 1)
#align generalized_continued_fraction.continuants_aux GeneralizedContinuedFraction.continuantsAux
-/

#print GeneralizedContinuedFraction.continuants /-
/-- Returns the continuants `⟨Aₙ, Bₙ⟩` of `g`. -/
def continuants (g : GeneralizedContinuedFraction K) : Stream' (Pair K) :=
  g.continuantsAux.tail
#align generalized_continued_fraction.continuants GeneralizedContinuedFraction.continuants
-/

#print GeneralizedContinuedFraction.numerators /-
/-- Returns the numerators `Aₙ` of `g`. -/
def numerators (g : GeneralizedContinuedFraction K) : Stream' K :=
  g.continuants.map Pair.a
#align generalized_continued_fraction.numerators GeneralizedContinuedFraction.numerators
-/

#print GeneralizedContinuedFraction.denominators /-
/-- Returns the denominators `Bₙ` of `g`. -/
def denominators (g : GeneralizedContinuedFraction K) : Stream' K :=
  g.continuants.map Pair.b
#align generalized_continued_fraction.denominators GeneralizedContinuedFraction.denominators
-/

#print GeneralizedContinuedFraction.convergents /-
/-- Returns the convergents `Aₙ / Bₙ` of `g`, where `Aₙ, Bₙ` are the nth continuants of `g`. -/
def convergents (g : GeneralizedContinuedFraction K) : Stream' K := fun n : ℕ =>
  g.numerators n / g.denominators n
#align generalized_continued_fraction.convergents GeneralizedContinuedFraction.convergents
-/

#print GeneralizedContinuedFraction.convergents'Aux /-
/--
Returns the approximation of the fraction described by the given sequence up to a given position n.
For example, `convergents'_aux [(1, 2), (3, 4), (5, 6)] 2 = 1 / (2 + 3 / 4)` and
`convergents'_aux [(1, 2), (3, 4), (5, 6)] 0 = 0`.
-/
def convergents'Aux : Seq (Pair K) → ℕ → K
  | s, 0 => 0
  | s, n + 1 =>
    match s.headI with
    | none => 0
    | some gp => gp.a / (gp.b + convergents'_aux s.tail n)
#align generalized_continued_fraction.convergents'_aux GeneralizedContinuedFraction.convergents'Aux
-/

#print GeneralizedContinuedFraction.convergents' /-
/-- Returns the convergents of `g` by evaluating the fraction described by `g` up to a given
position `n`. For example, `convergents' [9; (1, 2), (3, 4), (5, 6)] 2 = 9 + 1 / (2 + 3 / 4)` and
`convergents' [9; (1, 2), (3, 4), (5, 6)] 0 = 9`
-/
def convergents' (g : GeneralizedContinuedFraction K) (n : ℕ) : K :=
  g.h + convergents'Aux g.s n
#align generalized_continued_fraction.convergents' GeneralizedContinuedFraction.convergents'
-/

end GeneralizedContinuedFraction

-- Now, some basic, general theorems
namespace GeneralizedContinuedFraction

#print GeneralizedContinuedFraction.ext_iff /-
/-- Two gcfs `g` and `g'` are equal if and only if their components are equal. -/
protected theorem ext_iff {g g' : GeneralizedContinuedFraction α} :
    g = g' ↔ g.h = g'.h ∧ g.s = g'.s := by cases g; cases g'; simp
#align generalized_continued_fraction.ext_iff GeneralizedContinuedFraction.ext_iff
-/

#print GeneralizedContinuedFraction.ext /-
@[ext]
protected theorem ext {g g' : GeneralizedContinuedFraction α} (hyp : g.h = g'.h ∧ g.s = g'.s) :
    g = g' :=
  GeneralizedContinuedFraction.ext_iff.right hyp
#align generalized_continued_fraction.ext GeneralizedContinuedFraction.ext
-/

end GeneralizedContinuedFraction

