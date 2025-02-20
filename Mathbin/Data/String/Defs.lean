/-
Copyright (c) 2019 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Keeley Hoek, Floris van Doorn

! This file was ported from Lean 3 source module data.string.defs
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.Defs

/-!
# Definitions for `string`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines a bunch of functions for the `string` datatype.
-/


namespace String

#print String.splitOn /-
/-- `s.split_on c` tokenizes `s : string` on `c : char`. -/
def splitOn (s : String) (c : Char) : List String :=
  split (· = c) s
#align string.split_on String.splitOn
-/

#print String.mapTokens /-
/-- `string.map_tokens c f s` tokenizes `s : string` on `c : char`, maps `f` over each token, and
then reassembles the string by intercalating the separator token `c` over the mapped tokens. -/
def mapTokens (c : Char) (f : String → String) : String → String :=
  intercalate (singleton c) ∘ List.map f ∘ split (· = c)
#align string.map_tokens String.mapTokens
-/

#print String.isPrefixOf /-
/-- Tests whether the first string is a prefix of the second string. -/
def isPrefixOf (x y : String) : Bool :=
  x.toList.isPrefixOfₓ y.toList
#align string.is_prefix_of String.isPrefixOf
-/

#print String.isSuffixOf /-
/-- Tests whether the first string is a suffix of the second string. -/
def isSuffixOf (x y : String) : Bool :=
  x.toList.isSuffixOfₓ y.toList
#align string.is_suffix_of String.isSuffixOf
-/

#print String.startsWith /-
/-- `x.starts_with y` is true if `y` is a prefix of `x`, and is false otherwise. -/
abbrev startsWith (x y : String) : Bool :=
  y.isPrefixOfₓ x
#align string.starts_with String.startsWith
-/

#print String.endsWith /-
/-- `x.ends_with y` is true if `y` is a suffix of `x`, and is false otherwise. -/
abbrev endsWith (x y : String) : Bool :=
  y.isSuffixOfₓ x
#align string.ends_with String.endsWith
-/

#print String.getRest /-
/-- `get_rest s t` returns `some r` if `s = t ++ r`.
  If `t` is not a prefix of `s`, returns `none` -/
def getRest (s t : String) : Option String :=
  List.asString <$> s.toList.getRest t.toList
#align string.get_rest String.getRest
-/

#print String.drop /-
/-- Removes the first `n` elements from the string `s` -/
def drop (s : String) (n : Nat) : String :=
  (s.mkIterator.nextn n).nextToString
#align string.popn String.drop
-/

#print String.isNat /-
/-- `is_nat s` is true iff `s` is a nonempty sequence of digits. -/
def isNat (s : String) : Bool :=
  ¬s.isEmpty ∧ s.toList.all fun c => decide c.IsDigit
#align string.is_nat String.isNat
-/

#print String.head /-
/-- Produce the head character from the string `s`, if `s` is not empty, otherwise 'A'. -/
def head (s : String) : Char :=
  s.mkIterator.curr
#align string.head String.head
-/

end String

