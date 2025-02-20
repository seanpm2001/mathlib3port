/-
Copyright (c) 2020 Kevin Kappelmann. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Kappelmann

! This file was ported from Lean 3 source module algebra.continued_fractions.computation.basic
! leanprover-community/mathlib commit b5ad141426bb005414324f89719c77c0aa3ec612
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Floor
import Mathbin.Algebra.ContinuedFractions.Basic

/-!
# Computable Continued Fractions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Summary

We formalise the standard computation of (regular) continued fractions for linear ordered floor
fields. The algorithm is rather simple. Here is an outline of the procedure adapted from Wikipedia:

Take a value `v`. We call `⌊v⌋` the *integer part* of `v` and `v - ⌊v⌋` the *fractional part* of
`v`.  A continued fraction representation of `v` can then be given by `[⌊v⌋; b₀, b₁, b₂,...]`, where
`[b₀; b₁, b₂,...]` recursively is the continued fraction representation of `1 / (v - ⌊v⌋)`.  This
process stops when the fractional part hits 0.

In other words: to calculate a continued fraction representation of a number `v`, write down the
integer part (i.e. the floor) of `v`. Subtract this integer part from `v`. If the difference is 0,
stop; otherwise find the reciprocal of the difference and repeat. The procedure will terminate if
and only if `v` is rational.

For an example, refer to `int_fract_pair.stream`.

## Main definitions

- `generalized_continued_fraction.int_fract_pair.stream`: computes the stream of integer and
  fractional parts of a given value as described in the summary.
- `generalized_continued_fraction.of`: computes the generalised continued fraction of a value `v`.
  In fact, it computes a regular continued fraction that terminates if and only if `v` is rational.

## Implementation Notes

There is an intermediate definition `generalized_continued_fraction.int_fract_pair.seq1` between
`generalized_continued_fraction.int_fract_pair.stream` and `generalized_continued_fraction.of`
to wire up things. User should not (need to) directly interact with it.

The computation of the integer and fractional pairs of a value can elegantly be
captured by a recursive computation of a stream of option pairs. This is done in
`int_fract_pair.stream`. However, the type then does not guarantee the first pair to always be
`some` value, as expected by a continued fraction.

To separate concerns, we first compute a single head term that always exists in
`generalized_continued_fraction.int_fract_pair.seq1` followed by the remaining stream of option
pairs. This sequence with a head term (`seq1`) is then transformed to a generalized continued
fraction in `generalized_continued_fraction.of` by extracting the wanted integer parts of the
head term and the stream.

## References

- https://en.wikipedia.org/wiki/Continued_fraction

## Tags

numerics, number theory, approximations, fractions
-/


namespace GeneralizedContinuedFraction

-- Fix a carrier `K`.
variable (K : Type _)

#print GeneralizedContinuedFraction.IntFractPair /-
/-- We collect an integer part `b = ⌊v⌋` and fractional part `fr = v - ⌊v⌋` of a value `v` in a pair
`⟨b, fr⟩`.
-/
structure IntFractPair where
  b : ℤ
  fr : K
#align generalized_continued_fraction.int_fract_pair GeneralizedContinuedFraction.IntFractPair
-/

variable {K}

/-! Interlude: define some expected coercions and instances. -/


namespace IntFractPair

/-- Make an `int_fract_pair` printable. -/
instance [Repr K] : Repr (IntFractPair K) :=
  ⟨fun p => "(b : " ++ repr p.b ++ ", fract : " ++ repr p.fr ++ ")"⟩

#print GeneralizedContinuedFraction.IntFractPair.inhabited /-
instance inhabited [Inhabited K] : Inhabited (IntFractPair K) :=
  ⟨⟨0, default⟩⟩
#align generalized_continued_fraction.int_fract_pair.inhabited GeneralizedContinuedFraction.IntFractPair.inhabited
-/

#print GeneralizedContinuedFraction.IntFractPair.mapFr /-
/-- Maps a function `f` on the fractional components of a given pair.
-/
def mapFr {β : Type _} (f : K → β) (gp : IntFractPair K) : IntFractPair β :=
  ⟨gp.b, f gp.fr⟩
#align generalized_continued_fraction.int_fract_pair.mapFr GeneralizedContinuedFraction.IntFractPair.mapFr
-/

section coe

/-! Interlude: define some expected coercions. -/


-- Fix another type `β` which we will convert to.
variable {β : Type _} [Coe K β]

#print GeneralizedContinuedFraction.IntFractPair.coe /-
/-- Coerce a pair by coercing the fractional component. -/
instance coe : Coe (IntFractPair K) (IntFractPair β) :=
  ⟨mapFr coe⟩
#align generalized_continued_fraction.int_fract_pair.has_coe_to_int_fract_pair GeneralizedContinuedFraction.IntFractPair.coe
-/

#print GeneralizedContinuedFraction.IntFractPair.coe_to_intFractPair /-
@[simp, norm_cast]
theorem coe_to_intFractPair {b : ℤ} {fr : K} :
    (↑(IntFractPair.mk b fr) : IntFractPair β) = IntFractPair.mk b (↑fr : β) :=
  rfl
#align generalized_continued_fraction.int_fract_pair.coe_to_int_fract_pair GeneralizedContinuedFraction.IntFractPair.coe_to_intFractPair
-/

end coe

-- Note: this could be relaxed to something like `linear_ordered_division_ring` in the
-- future.
-- Fix a discrete linear ordered field with `floor` function.
variable [LinearOrderedField K] [FloorRing K]

#print GeneralizedContinuedFraction.IntFractPair.of /-
/-- Creates the integer and fractional part of a value `v`, i.e. `⟨⌊v⌋, v - ⌊v⌋⟩`. -/
protected def of (v : K) : IntFractPair K :=
  ⟨⌊v⌋, Int.fract v⟩
#align generalized_continued_fraction.int_fract_pair.of GeneralizedContinuedFraction.IntFractPair.of
-/

#print GeneralizedContinuedFraction.IntFractPair.stream /-
/-- Creates the stream of integer and fractional parts of a value `v` needed to obtain the continued
fraction representation of `v` in `generalized_continued_fraction.of`. More precisely, given a value
`v : K`, it recursively computes a stream of option `ℤ × K` pairs as follows:
- `stream v 0 = some ⟨⌊v⌋, v - ⌊v⌋⟩`
- `stream v (n + 1) = some ⟨⌊frₙ⁻¹⌋, frₙ⁻¹ - ⌊frₙ⁻¹⌋⟩`,
    if `stream v n = some ⟨_, frₙ⟩` and `frₙ ≠ 0`
- `stream v (n + 1) = none`, otherwise

For example, let `(v : ℚ) := 3.4`. The process goes as follows:
- `stream v 0 = some ⟨⌊v⌋, v - ⌊v⌋⟩ = some ⟨3, 0.4⟩`
- `stream v 1 = some ⟨⌊0.4⁻¹⌋, 0.4⁻¹ - ⌊0.4⁻¹⌋⟩ = some ⟨⌊2.5⌋, 2.5 - ⌊2.5⌋⟩ = some ⟨2, 0.5⟩`
- `stream v 2 = some ⟨⌊0.5⁻¹⌋, 0.5⁻¹ - ⌊0.5⁻¹⌋⟩ = some ⟨⌊2⌋, 2 - ⌊2⌋⟩ = some ⟨2, 0⟩`
- `stream v n = none`, for `n ≥ 3`
-/
protected def stream (v : K) : Stream' <| Option (IntFractPair K)
  | 0 => some (IntFractPair.of v)
  | n + 1 =>
    (Stream' n).bind fun ap_n => if ap_n.fr = 0 then none else some (IntFractPair.of ap_n.fr⁻¹)
#align generalized_continued_fraction.int_fract_pair.stream GeneralizedContinuedFraction.IntFractPair.stream
-/

#print GeneralizedContinuedFraction.IntFractPair.stream_isSeq /-
/-- Shows that `int_fract_pair.stream` has the sequence property, that is once we return `none` at
position `n`, we also return `none` at `n + 1`.
-/
theorem stream_isSeq (v : K) : (IntFractPair.stream v).IsSeq := by intro _ hyp;
  simp [int_fract_pair.stream, hyp]
#align generalized_continued_fraction.int_fract_pair.stream_is_seq GeneralizedContinuedFraction.IntFractPair.stream_isSeq
-/

#print GeneralizedContinuedFraction.IntFractPair.seq1 /-
/--
Uses `int_fract_pair.stream` to create a sequence with head (i.e. `seq1`) of integer and fractional
parts of a value `v`. The first value of `int_fract_pair.stream` is never `none`, so we can safely
extract it and put the tail of the stream in the sequence part.

This is just an intermediate representation and users should not (need to) directly interact with
it. The setup of rewriting/simplification lemmas that make the definitions easy to use is done in
`algebra.continued_fractions.computation.translations`.
-/
protected def seq1 (v : K) : Stream'.Seq1 <| IntFractPair K :=
  ⟨IntFractPair.of v,--the head
      Stream'.Seq.tail-- take the tail of `int_fract_pair.stream` since the first element is already in
      -- the head
      -- create a sequence from `int_fract_pair.stream`
      ⟨IntFractPair.stream v,-- the underlying stream
          @stream_isSeq
          _ _ _ v⟩⟩
#align generalized_continued_fraction.int_fract_pair.seq1 GeneralizedContinuedFraction.IntFractPair.seq1
-/

-- the proof that the stream is a sequence
end IntFractPair

#print GeneralizedContinuedFraction.of /-
/-- Returns the `generalized_continued_fraction` of a value. In fact, the returned gcf is also
a `continued_fraction` that terminates if and only if `v` is rational (those proofs will be
added in a future commit).

The continued fraction representation of `v` is given by `[⌊v⌋; b₀, b₁, b₂,...]`, where
`[b₀; b₁, b₂,...]` recursively is the continued fraction representation of `1 / (v - ⌊v⌋)`. This
process stops when the fractional part `v - ⌊v⌋` hits 0 at some step.

The implementation uses `int_fract_pair.stream` to obtain the partial denominators of the continued
fraction. Refer to said function for more details about the computation process.
-/
protected def of [LinearOrderedField K] [FloorRing K] (v : K) : GeneralizedContinuedFraction K :=
  let ⟨h, s⟩ := IntFractPair.seq1 v
  -- get the sequence of integer and fractional parts.
  ⟨h.b,-- the head is just the first integer part
        s.map
      fun p => ⟨1, p.b⟩⟩
#align generalized_continued_fraction.of GeneralizedContinuedFraction.of
-/

-- the sequence consists of the remaining integer parts as the partial
-- denominators; all partial numerators are simply 1
end GeneralizedContinuedFraction

