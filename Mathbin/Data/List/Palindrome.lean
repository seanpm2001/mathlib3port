/-
Copyright (c) 2020 Google LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Wong

! This file was ported from Lean 3 source module data.list.palindrome
! leanprover-community/mathlib commit 00f4ab49e7d5139216e0b3daad15fffa504897ab
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.Basic

/-!
# Palindromes

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This module defines *palindromes*, lists which are equal to their reverse.

The main result is the `palindrome` inductive type, and its associated `palindrome.rec_on` induction
principle. Also provided are conversions to and from other equivalent definitions.

## References

* [Pierre Castéran, *On palindromes*][casteran]

[casteran]: https://www.labri.fr/perso/casteran/CoqArt/inductive-prop-chap/palindrome.html

## Tags

palindrome, reverse, induction
-/


variable {α β : Type _}

namespace List

#print List.Palindrome /-
/-- `palindrome l` asserts that `l` is a palindrome. This is defined inductively:

* The empty list is a palindrome;
* A list with one element is a palindrome;
* Adding the same element to both ends of a palindrome results in a bigger palindrome.
-/
inductive Palindrome : List α → Prop
  | nil : palindrome []
  | singleton : ∀ x, palindrome [x]
  | cons_concat : ∀ (x) {l}, palindrome l → palindrome (x :: (l ++ [x]))
#align list.palindrome List.Palindrome
-/

namespace Palindrome

variable {l : List α}

#print List.Palindrome.reverse_eq /-
theorem reverse_eq {l : List α} (p : Palindrome l) : reverse l = l :=
  Palindrome.rec_on p rfl (fun _ => rfl) fun x l p h => by simp [h]
#align list.palindrome.reverse_eq List.Palindrome.reverse_eq
-/

#print List.Palindrome.of_reverse_eq /-
theorem of_reverse_eq {l : List α} : reverse l = l → Palindrome l :=
  by
  refine' bidirectional_rec_on l (fun _ => palindrome.nil) (fun a _ => palindrome.singleton a) _
  intro x l y hp hr
  rw [reverse_cons, reverse_append] at hr 
  rw [head_eq_of_cons_eq hr]
  have : palindrome l := hp (append_inj_left' (tail_eq_of_cons_eq hr) rfl)
  exact palindrome.cons_concat x this
#align list.palindrome.of_reverse_eq List.Palindrome.of_reverse_eq
-/

#print List.Palindrome.iff_reverse_eq /-
theorem iff_reverse_eq {l : List α} : Palindrome l ↔ reverse l = l :=
  Iff.intro reverse_eq of_reverse_eq
#align list.palindrome.iff_reverse_eq List.Palindrome.iff_reverse_eq
-/

#print List.Palindrome.append_reverse /-
theorem append_reverse (l : List α) : Palindrome (l ++ reverse l) := by apply of_reverse_eq;
  rw [reverse_append, reverse_reverse]
#align list.palindrome.append_reverse List.Palindrome.append_reverse
-/

#print List.Palindrome.map /-
protected theorem map (f : α → β) (p : Palindrome l) : Palindrome (map f l) :=
  of_reverse_eq <| by rw [← map_reverse, p.reverse_eq]
#align list.palindrome.map List.Palindrome.map
-/

instance [DecidableEq α] (l : List α) : Decidable (Palindrome l) :=
  decidable_of_iff' _ iff_reverse_eq

end Palindrome

end List

