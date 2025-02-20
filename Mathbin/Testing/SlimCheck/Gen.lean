/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module testing.slim_check.gen
! leanprover-community/mathlib commit 9240e8be927a0955b9a82c6c85ef499ee3a626b8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Random
import Mathbin.Control.Uliftable
import Mathbin.Data.List.BigOperators.Lemmas
import Mathbin.Data.List.Perm

/-!
# `gen` Monad

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This monad is used to formulate randomized computations with a parameter
to specify the desired size of the result.

This is a port of the Haskell QuickCheck library.

## Main definitions
  * `gen` monad

## Local notation

 * `i .. j` : `Icc i j`, the set of values between `i` and `j` inclusively;

## Tags

random testing

## References

  * https://hackage.haskell.org/package/QuickCheck

-/


universe u v

namespace SlimCheck

#print SlimCheck.Gen /-
/-- Monad to generate random examples to test properties with.
It has a `nat` parameter so that the caller can decide on the
size of the examples. -/
@[reducible]
def Gen (α : Type u) :=
  ReaderT (ULift ℕ) Rand α
deriving Monad, LawfulMonad
#align slim_check.gen SlimCheck.Gen
-/

variable (α : Type u)

local infixl:41 " .. " => Set.Icc

/-- Execute a `gen` inside the `io` monad using `i` as the example
size and with a fresh random number generator. -/
def Io.runGen {α} (x : Gen α) (i : ℕ) : Io α :=
  Io.runRand (x.run ⟨i⟩)
#align slim_check.io.run_gen SlimCheck.Io.runGen

namespace Gen

section Rand

#print SlimCheck.Gen.chooseAny /-
/-- Lift `random.random` to the `gen` monad. -/
def chooseAny [Random α] : Gen α :=
  ⟨fun _ => Rand.random α⟩
#align slim_check.gen.choose_any SlimCheck.Gen.chooseAny
-/

variable {α} [Preorder α]

#print SlimCheck.Gen.choose /-
/-- Lift `random.random_r` to the `gen` monad. -/
def choose [BoundedRandom α] (x y : α) (p : x ≤ y) : Gen (x .. y) :=
  ⟨fun _ => Rand.randomR x y p⟩
#align slim_check.gen.choose SlimCheck.Gen.choose
-/

end Rand

open Nat

/-- Generate a `nat` example between `x` and `y`. -/
def chooseNat (x y : ℕ) (p : x ≤ y) : Gen (x .. y) :=
  choose x y p
#align slim_check.gen.choose_nat SlimCheck.Gen.chooseNat

/-- Generate a `nat` example between `x` and `y`. -/
def chooseNat' (x y : ℕ) (p : x < y) : Gen (Set.Ico x y) :=
  have : ∀ i, x < i → i ≤ y → i.pred < y := fun i h₀ h₁ =>
    show i.pred.succ ≤ y by rwa [succ_pred_eq_of_pos] <;> apply lt_of_le_of_lt (Nat.zero_le _) h₀
  (Subtype.map pred fun i (h : x + 1 ≤ i ∧ i ≤ y) => ⟨le_pred_of_lt h.1, this _ h.1 h.2⟩) <$>
    choose (x + 1) y p
#align slim_check.gen.choose_nat' SlimCheck.Gen.chooseNat'

open Nat

instance : ULiftable Gen.{u} Gen.{v} :=
  ReaderT.uliftable' (Equiv.ulift.trans Equiv.ulift.symm)

instance : HasOrelse Gen.{u} :=
  ⟨fun α x y => do
    let b ← ULiftable.up <| chooseAny Bool
    if b then x else y⟩

variable {α}

/-- Get access to the size parameter of the `gen` monad. For
reasons of universe polymorphism, it is specified in
continuation passing style. -/
def sized (cmd : ℕ → Gen α) : Gen α :=
  ⟨fun ⟨sz⟩ => ReaderT.run (cmd sz) ⟨sz⟩⟩
#align slim_check.gen.sized SlimCheck.Gen.sized

#print SlimCheck.Gen.resize /-
/-- Apply a function to the size parameter. -/
def resize (f : ℕ → ℕ) (cmd : Gen α) : Gen α :=
  ⟨fun ⟨sz⟩ => ReaderT.run cmd ⟨f sz⟩⟩
#align slim_check.gen.resize SlimCheck.Gen.resize
-/

/-- Create `n` examples using `cmd`. -/
def vectorOf : ∀ (n : ℕ) (cmd : Gen α), Gen (Vector α n)
  | 0, _ => return Vector.nil
  | succ n, cmd => Vector.cons <$> cmd <*> vector_of n cmd
#align slim_check.gen.vector_of SlimCheck.Gen.vectorOf

#print SlimCheck.Gen.listOf /-
/-- Create a list of examples using `cmd`. The size is controlled
by the size parameter of `gen`. -/
def listOf (cmd : Gen α) : Gen (List α) :=
  sized fun sz => do
    do
      let ⟨n⟩ ← ULiftable.up <| choose_nat 0 (sz + 1) (by decide)
      let v ← vector_of n cmd
      return v
#align slim_check.gen.list_of SlimCheck.Gen.listOf
-/

open ULift

#print SlimCheck.Gen.oneOf /-
/-- Given a list of example generators, choose one to create an example. -/
def oneOf (xs : List (Gen α)) (pos : 0 < xs.length) : Gen α := do
  let ⟨⟨n, h, h'⟩⟩ ← ULiftable.up <| chooseNat' 0 xs.length Pos
  List.nthLe xs n h'
#align slim_check.gen.one_of SlimCheck.Gen.oneOf
-/

#print SlimCheck.Gen.elements /-
/-- Given a list of example generators, choose one to create an example. -/
def elements (xs : List α) (pos : 0 < xs.length) : Gen α := do
  let ⟨⟨n, h₀, h₁⟩⟩ ← ULiftable.up <| chooseNat' 0 xs.length Pos
  pure <| List.nthLe xs n h₁
#align slim_check.gen.elements SlimCheck.Gen.elements
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- `freq_aux xs i _` takes a weighted list of generator and a number meant to select one of the
generators.

If we consider `freq_aux [(1, gena), (3, genb), (5, genc)] 4 _`, we choose a generator by splitting
the interval 1-9 into 1-1, 2-4, 5-9 so that the width of each interval corresponds to one of the
number in the list of generators. Then, we check which interval 4 falls into: it selects `genb`.
-/
def freqAux : ∀ (xs : List (ℕ+ × Gen α)) (i), i < (xs.map (Subtype.val ∘ Prod.fst)).Sum → Gen α
  | [], i, h => False.elim (Nat.not_lt_zero _ h)
  | (i, x)::xs, j, h =>
    if h' : j < i then x
    else
      freq_aux xs (j - i)
        (by
          rw [tsub_lt_iff_right (le_of_not_gt h')]
          simpa [List.sum_cons, add_comm] using h)
#align slim_check.gen.freq_aux SlimCheck.Gen.freqAux

/-- `freq [(1, gena), (3, genb), (5, genc)] _` will choose one of `gena`, `genb`, `genc` with
probabilities proportional to the number accompanying them. In this example, the sum of
those numbers is 9, `gena` will be chosen with probability ~1/9, `genb` with ~3/9 (i.e. 1/3)
and `genc` with probability 5/9.
-/
def freq (xs : List (ℕ+ × Gen α)) (pos : 0 < xs.length) : Gen α :=
  let s := (xs.map (Subtype.val ∘ Prod.fst)).Sum
  have ha : 1 ≤ s :=
    le_trans Pos <|
      List.length_map (Subtype.val ∘ Prod.fst) xs ▸
        List.length_le_sum_of_one_le _ fun i => by simp; intros; assumption
  have : 0 ≤ s - 1 := le_tsub_of_add_le_right ha
  ULiftable.adaptUp Gen.{0} Gen.{u} (chooseNat 0 (s - 1) this) fun i =>
    freqAux xs i.1 (by rcases i with ⟨i, h₀, h₁⟩ <;> rwa [le_tsub_iff_right] at h₁  <;> exact ha)
#align slim_check.gen.freq SlimCheck.Gen.freq

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print SlimCheck.Gen.permutationOf /-
/-- Generate a random permutation of a given list. -/
def permutationOf {α : Type u} : ∀ xs : List α, Gen (Subtype <| List.Perm xs)
  | [] => pure ⟨[], List.Perm.nil⟩
  | x::xs => do
    let ⟨xs', h⟩ ← permutation_of xs
    let ⟨⟨n, _, h'⟩⟩ ← ULiftable.up <| chooseNat 0 xs'.length (by decide)
    pure
        ⟨List.insertNth n x xs',
          List.Perm.trans (List.Perm.cons _ h) (List.perm_insertNth _ _ h').symm⟩
#align slim_check.gen.permutation_of SlimCheck.Gen.permutationOf
-/

end Gen

end SlimCheck

