/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module testing.slim_check.sampleable
! leanprover-community/mathlib commit 9240e8be927a0955b9a82c6c85ef499ee3a626b8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.LazyList.Basic
import Mathbin.Data.Tree
import Mathbin.Data.Pnat.Basic
import Mathbin.Control.Bifunctor
import Mathbin.Control.Ulift
import Mathbin.Testing.SlimCheck.Gen
import Mathbin.Tactic.Linarith.Default

/-!
# `sampleable` Class

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This class permits the creation samples of a given type
controlling the size of those values using the `gen` monad`. It also
helps minimize examples by creating smaller versions of given values.

When testing a proposition like `∀ n : ℕ, prime n → n ≤ 100`,
`slim_check` requires that `ℕ` have an instance of `sampleable` and for
`prime n` to be decidable.  `slim_check` will then use the instance of
`sampleable` to generate small examples of ℕ and progressively increase
in size. For each example `n`, `prime n` is tested. If it is false,
the example will be rejected (not a test success nor a failure) and
`slim_check` will move on to other examples. If `prime n` is true, `n
≤ 100` will be tested. If it is false, `n` is a counter-example of `∀
n : ℕ, prime n → n ≤ 100` and the test fails. If `n ≤ 100` is true,
the test passes and `slim_check` moves on to trying more examples.

This is a port of the Haskell QuickCheck library.

## Main definitions
  * `sampleable` class
  * `sampleable_functor` and `sampleable_bifunctor` class
  * `sampleable_ext` class

### `sampleable`

`sampleable α` provides ways of creating examples of type `α`,
and given such an example `x : α`, gives us a way to shrink it
and find simpler examples.

### `sampleable_ext`

`sampleable_ext` generalizes the behavior of `sampleable`
and makes it possible to express instances for types that
do not lend themselves to introspection, such as `ℕ → ℕ`.
If we test a quantification over functions the
counter-examples cannot be shrunken or printed meaningfully.

For that purpose, `sampleable_ext` provides a proxy representation
`proxy_repr` that can be printed and shrunken as well
as interpreted (using `interp`) as an object of the right type.

### `sampleable_functor` and `sampleable_bifunctor`

`sampleable_functor F` and `sampleable_bifunctor F` makes it possible
to create samples of and shrink `F α` given a sampling function and a
shrinking function for arbitrary `α`.

This allows us to separate the logic for generating the shape of a
collection from the logic for generating its contents. Specifically,
the contents could be generated using either `sampleable` or
`sampleable_ext` instance and the `sampleable_(bi)functor` does not
need to use that information

## Shrinking

Shrinking happens when `slim_check` find a counter-example to a
property.  It is likely that the example will be more complicated than
necessary so `slim_check` proceeds to shrink it as much as
possible. Although equally valid, a smaller counter-example is easier
for a user to understand and use.

The `sampleable` class, beside having the `sample` function, has a
`shrink` function so that we can use specialized knowledge while
shrinking a value. It is not responsible for the whole shrinking process
however. It only has to take one step in the shrinking process.
`slim_check` will repeatedly call `shrink` until no more steps can
be taken. Because `shrink` guarantees that the size of the candidates
it produces is strictly smaller than the argument, we know that
`slim_check` is guaranteed to terminate.

## Tags

random testing

## References

  * https://hackage.haskell.org/package/QuickCheck

-/


universe u v w

namespace SlimCheck

variable (α : Type u)

local infixl:50 " ≺ " => WellFoundedRelation.R

/-- `sizeof_lt x y` compares the sizes of `x` and `y`. -/
def SizeofLt {α} [SizeOf α] (x y : α) :=
  SizeOf.sizeOf x < SizeOf.sizeOf y
#align slim_check.sizeof_lt SlimCheck.SizeofLt

/-- `shrink_fn α` is the type of functions that shrink an
argument of type `α` -/
@[reducible]
def ShrinkFn (α : Type _) [SizeOf α] :=
  ∀ x : α, LazyList { y : α // SizeofLt y x }
#align slim_check.shrink_fn SlimCheck.ShrinkFn

/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`sample] [] -/
/-- `sampleable α` provides ways of creating examples of type `α`,
and given such an example `x : α`, gives us a way to shrink it
and find simpler examples.  -/
class Sampleable where
  [wf : SizeOf α]
  sample : Gen α
  shrink : ∀ x : α, LazyList { y : α // @SizeOf.sizeOf _ wf y < @SizeOf.sizeOf _ wf x } := fun _ =>
    LazyList.nil
#align slim_check.sampleable SlimCheck.Sampleable

attribute [instance 100] hasWellFoundedOfHasSizeof defaultHasSizeof

attribute [instance 200] sampleable.wf

/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`sample] [] -/
/-- `sampleable_functor F` makes it possible to create samples of and
shrink `F α` given a sampling function and a shrinking function for
arbitrary `α` -/
class SampleableFunctor (F : Type u → Type v) [Functor F] where
  [wf : ∀ (α) [SizeOf α], SizeOf (F α)]
  sample : ∀ {α}, Gen α → Gen (F α)
  shrink : ∀ (α) [SizeOf α], ShrinkFn α → ShrinkFn (F α)
  pRepr : ∀ α, Repr α → Repr (F α)
#align slim_check.sampleable_functor SlimCheck.SampleableFunctor

/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`sample] [] -/
/-- `sampleable_bifunctor F` makes it possible to create samples of
and shrink `F α β` given a sampling function and a shrinking function
for arbitrary `α` and `β` -/
class SampleableBifunctor (F : Type u → Type v → Type w) [Bifunctor F] where
  [wf : ∀ (α β) [SizeOf α] [SizeOf β], SizeOf (F α β)]
  sample : ∀ {α β}, Gen α → Gen β → Gen (F α β)
  shrink : ∀ (α β) [SizeOf α] [SizeOf β], ShrinkFn α → ShrinkFn β → ShrinkFn (F α β)
  pRepr : ∀ α β, Repr α → Repr β → Repr (F α β)
#align slim_check.sampleable_bifunctor SlimCheck.SampleableBifunctor

export Sampleable (sample shrink)

/-- This function helps infer the proxy representation and
interpretation in `sampleable_ext` instances. -/
unsafe def sampleable.mk_trivial_interp : tactic Unit :=
  tactic.refine ``(id)
#align slim_check.sampleable.mk_trivial_interp slim_check.sampleable.mk_trivial_interp

#print SlimCheck.SampleableExt /-
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`interp] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`sample] [] -/
/-- `sampleable_ext` generalizes the behavior of `sampleable`
and makes it possible to express instances for types that
do not lend themselves to introspection, such as `ℕ → ℕ`.
If we test a quantification over functions the
counter-examples cannot be shrunken or printed meaningfully.

For that purpose, `sampleable_ext` provides a proxy representation
`proxy_repr` that can be printed and shrunken as well
as interpreted (using `interp`) as an object of the right type. -/
class SampleableExt (α : Sort u) where
  ProxyRepr : Type v
  [wf : SizeOf proxy_repr]
  interp : proxy_repr → α := by refine id.1
  [pRepr : Repr proxy_repr]
  sample : Gen proxy_repr
  shrink : ShrinkFn proxy_repr
#align slim_check.sampleable_ext SlimCheck.SampleableExt
-/

attribute [instance 100] sampleable_ext.p_repr sampleable_ext.wf

open Nat LazyList

section Prio

open SampleableExt

/- ./././Mathport/Syntax/Translate/Basic.lean:334:40: warning: unsupported option default_priority -/
set_option default_priority 50

instance SampleableExt.ofSampleable {α} [Sampleable α] [Repr α] : SampleableExt α
    where
  ProxyRepr := α
  sample := Sampleable.sample α
  shrink := shrink
#align slim_check.sampleable_ext.of_sampleable SlimCheck.SampleableExt.ofSampleable

instance Sampleable.functor {α} {F} [Functor F] [SampleableFunctor F] [Sampleable α] :
    Sampleable (F α) where
  wf := _
  sample := SampleableFunctor.sample F (Sampleable.sample α)
  shrink := SampleableFunctor.shrink α Sampleable.shrink
#align slim_check.sampleable.functor SlimCheck.Sampleable.functor

instance Sampleable.bifunctor {α β} {F} [Bifunctor F] [SampleableBifunctor F] [Sampleable α]
    [Sampleable β] : Sampleable (F α β) where
  wf := _
  sample := SampleableBifunctor.sample F (Sampleable.sample α) (Sampleable.sample β)
  shrink := SampleableBifunctor.shrink α β Sampleable.shrink Sampleable.shrink
#align slim_check.sampleable.bifunctor SlimCheck.Sampleable.bifunctor

/- ./././Mathport/Syntax/Translate/Basic.lean:334:40: warning: unsupported option default_priority -/
set_option default_priority 100

instance SampleableExt.functor {α} {F} [Functor F] [SampleableFunctor F] [SampleableExt α] :
    SampleableExt (F α) where
  wf := _
  ProxyRepr := F (ProxyRepr α)
  interp := Functor.map (interp _)
  sample := SampleableFunctor.sample F (SampleableExt.sample α)
  shrink := SampleableFunctor.shrink _ SampleableExt.shrink
  pRepr := SampleableFunctor.pRepr _ SampleableExt.pRepr
#align slim_check.sampleable_ext.functor SlimCheck.SampleableExt.functor

instance SampleableExt.bifunctor {α β} {F} [Bifunctor F] [SampleableBifunctor F] [SampleableExt α]
    [SampleableExt β] : SampleableExt (F α β)
    where
  wf := _
  ProxyRepr := F (ProxyRepr α) (ProxyRepr β)
  interp := Bifunctor.bimap (interp _) (interp _)
  sample := SampleableBifunctor.sample F (SampleableExt.sample α) (SampleableExt.sample β)
  shrink := SampleableBifunctor.shrink _ _ SampleableExt.shrink SampleableExt.shrink
  pRepr := SampleableBifunctor.pRepr _ _ SampleableExt.pRepr SampleableExt.pRepr
#align slim_check.sampleable_ext.bifunctor SlimCheck.SampleableExt.bifunctor

end Prio

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- `nat.shrink' k n` creates a list of smaller natural numbers by
successively dividing `n` by 2 and subtracting the difference from
`k`. For example, `nat.shrink 100 = [50, 75, 88, 94, 97, 99]`. -/
def Nat.shrink' (k : ℕ) :
    ∀ n : ℕ,
      n ≤ k →
        List { m : ℕ // WellFoundedRelation.R m k } → List { m : ℕ // WellFoundedRelation.R m k }
  | n, hn, ls =>
    if h : n ≤ 1 then ls.reverse
    else
      have h₂ : 0 < n := by linarith
      have : 1 * n / 2 < n := Nat.div_lt_of_lt_mul (Nat.mul_lt_mul_of_pos_right (by norm_num) h₂)
      have : n / 2 < n := by simpa
      let m := n / 2
      have h₀ : m ≤ k := le_trans (le_of_lt this) hn
      have h₃ : 0 < m := by
        simp only [m, lt_iff_add_one_le, zero_add] <;> rw [Nat.le_div_iff_mul_le] <;> linarith
      have h₁ : k - m < k := Nat.sub_lt (lt_of_lt_of_le h₂ hn) h₃
      nat.shrink' m h₀ (⟨k - m, h₁⟩::ls)
#align slim_check.nat.shrink' SlimCheck.Nat.shrink'

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print SlimCheck.Nat.shrink /-
/-- `nat.shrink n` creates a list of smaller natural numbers by
successively dividing by 2 and subtracting the difference from
`n`. For example, `nat.shrink 100 = [50, 75, 88, 94, 97, 99]`. -/
def Nat.shrink (n : ℕ) : List { m : ℕ // WellFoundedRelation.R m n } :=
  if h : n > 0 then
    have : ∀ k, 1 < k → n / k < n := fun k hk =>
      Nat.div_lt_of_lt_mul
        (suffices 1 * n < k * n by simpa
        Nat.mul_lt_mul_of_pos_right hk h)
    ⟨n / 11, this _ (by norm_num)⟩::⟨n / 3, this _ (by norm_num)⟩::Nat.shrink' n n le_rfl []
  else []
#align slim_check.nat.shrink SlimCheck.Nat.shrink
-/

open Gen

/-- Transport a `sampleable` instance from a type `α` to a type `β` using
functions between the two, going in both directions.

Function `g` is used to define the well-founded order that
`shrink` is expected to follow.
-/
def Sampleable.lift (α : Type u) {β : Type u} [Sampleable α] (f : α → β) (g : β → α)
    (h : ∀ a : α, SizeOf.sizeOf (g (f a)) ≤ SizeOf.sizeOf a) : Sampleable β
    where
  wf := ⟨SizeOf.sizeOf ∘ g⟩
  sample := f <$> sample α
  shrink x :=
    have :
      ∀ a, SizeOf.sizeOf a < SizeOf.sizeOf (g x) → SizeOf.sizeOf (g (f a)) < SizeOf.sizeOf (g x) :=
      by introv h' <;> solve_by_elim [lt_of_le_of_lt]
    Subtype.map f this <$> shrink (g x)
#align slim_check.sampleable.lift SlimCheck.Sampleable.lift

instance Nat.sampleable : Sampleable ℕ
    where
  sample :=
    sized fun sz =>
      freq [(1, coe <$> chooseAny (Fin <| succ (sz ^ 3))), (3, coe <$> chooseAny (Fin <| succ sz))]
        (by decide)
  shrink x := LazyList.ofList <| Nat.shrink x
#align slim_check.nat.sampleable SlimCheck.Nat.sampleable

/-- `iterate_shrink p x` takes a decidable predicate `p` and a
value `x` of some sampleable type and recursively shrinks `x`.
It first calls `shrink x` to get a list of candidate sample,
finds the first that satisfies `p` and recursively tries
to shrink that one. -/
def iterateShrink {α} [ToString α] [Sampleable α] (p : α → Prop) [DecidablePred p] : α → Option α :=
  WellFounded.fix WellFoundedRelation.wf fun x f_rec => do
    (trace s! "{x} : {(Shrink x).toList}") <| pure ()
    let y ← (shrink x).find fun a => p a
    f_rec y y <|> some y
#align slim_check.iterate_shrink SlimCheck.iterateShrink

instance Fin.sampleable {n : ℕ} [NeZero n] : Sampleable (Fin n) :=
  Sampleable.lift ℕ Fin.ofNat'' Fin.val fun i => (mod_le _ _ : i % n ≤ i)
#align slim_check.fin.sampleable SlimCheck.Fin.sampleable

instance (priority := 100) Fin.sampleable' {n} : Sampleable (Fin (succ n)) :=
  Sampleable.lift ℕ Fin.ofNat Fin.val fun i => (mod_le _ _ : i % succ n ≤ i)
#align slim_check.fin.sampleable' SlimCheck.Fin.sampleable'

instance Pnat.sampleable : Sampleable ℕ+ :=
  Sampleable.lift ℕ Nat.succPNat PNat.natPred fun a => by
    unfold_wf <;> simp only [PNat.natPred, succ_pnat, PNat.mk_coe, tsub_zero, succ_sub_succ_eq_sub]
#align slim_check.pnat.sampleable SlimCheck.Pnat.sampleable

/-- Redefine `sizeof` for `int` to make it easier to use with `nat` -/
def Int.hasSizeof : SizeOf ℤ :=
  ⟨Int.natAbs⟩
#align slim_check.int.has_sizeof SlimCheck.Int.hasSizeof

attribute [local instance 2000] int.has_sizeof

instance Int.sampleable : Sampleable ℤ where
  wf := _
  sample :=
    sized fun sz =>
      freq
        [(1, Subtype.val <$> choose (-(sz ^ 3 + 1) : ℤ) (sz ^ 3 + 1) (neg_le_self (by decide))),
          (3, Subtype.val <$> choose (-(sz + 1)) (sz + 1) (neg_le_self (by decide)))]
        (by decide)
  shrink x :=
    LazyList.ofList <|
      (Nat.shrink <| Int.natAbs x).bind fun ⟨y, h⟩ =>
        [⟨y, h⟩, ⟨-y, by dsimp [SizeOf.sizeOf, SizeOf.sizeOf] <;> rw [Int.natAbs_neg] <;> exact h⟩]
#align slim_check.int.sampleable SlimCheck.Int.sampleable

instance Bool.sampleable : Sampleable Bool
    where
  wf := ⟨fun b => if b then 1 else 0⟩
  sample := do
    let x ← chooseAny Bool
    return x
  shrink b := if h : b then LazyList.singleton ⟨false, by cases h <;> unfold_wf⟩ else LazyList.nil
#align slim_check.bool.sampleable SlimCheck.Bool.sampleable

/-- Provided two shrinking functions `prod.shrink` shrinks a pair `(x, y)` by
first shrinking `x` and pairing the results with `y` and then shrinking
`y` and pairing the results with `x`.

All pairs either contain `x` untouched or `y` untouched. We rely on
shrinking being repeated for `x` to get maximally shrunken and then
for `y` to get shrunken too.
-/
def Prod.shrink {α β} [SizeOf α] [SizeOf β] (shr_a : ShrinkFn α) (shr_b : ShrinkFn β) :
    ShrinkFn (α × β)
  | ⟨x₀, x₁⟩ =>
    let xs₀ : LazyList { y : α × β // SizeofLt y (x₀, x₁) } :=
      (shr_a x₀).map <|
        Subtype.map (fun a => (a, x₁)) fun x h => by dsimp [sizeof_lt] <;> unfold_wf <;> apply h
    let xs₁ : LazyList { y : α × β // SizeofLt y (x₀, x₁) } :=
      (shr_b x₁).map <|
        Subtype.map (fun a => (x₀, a)) fun x h => by dsimp [sizeof_lt] <;> unfold_wf <;> apply h
    xs₀.append xs₁
#align slim_check.prod.shrink SlimCheck.Prod.shrink

instance Prod.sampleable : SampleableBifunctor.{u, v} Prod
    where
  wf := _
  sample α β sama samb := do
    let ⟨x⟩ ← (ULiftable.up <| sama : Gen (ULift.{max u v} α))
    let ⟨y⟩ ← (ULiftable.up <| samb : Gen (ULift.{max u v} β))
    pure (x, y)
  shrink := @Prod.shrink
  pRepr := @Prod.hasRepr
#align slim_check.prod.sampleable SlimCheck.Prod.sampleable

instance Sigma.sampleable {α β} [Sampleable α] [Sampleable β] : Sampleable (Σ _ : α, β) :=
  Sampleable.lift (α × β) (fun ⟨x, y⟩ => ⟨x, y⟩) (fun ⟨x, y⟩ => ⟨x, y⟩) fun ⟨x, y⟩ => le_rfl
#align slim_check.sigma.sampleable SlimCheck.Sigma.sampleable

/-- shrinking function for sum types -/
def Sum.shrink {α β} [SizeOf α] [SizeOf β] (shrink_α : ShrinkFn α) (shrink_β : ShrinkFn β) :
    ShrinkFn (Sum α β)
  | Sum.inr x =>
    (shrink_β x).map <|
      Subtype.map Sum.inr fun a => by dsimp [sizeof_lt] <;> unfold_wf <;> solve_by_elim
  | Sum.inl x =>
    (shrink_α x).map <|
      Subtype.map Sum.inl fun a => by dsimp [sizeof_lt] <;> unfold_wf <;> solve_by_elim
#align slim_check.sum.shrink SlimCheck.Sum.shrink

instance Sum.sampleable : SampleableBifunctor.{u, v} Sum
    where
  wf := _
  sample (α : Type u) (β : Type v) sam_α sam_β :=
    @ULiftable.upMap Gen.{u} Gen.{max u v} _ _ _ _ (@Sum.inl α β) sam_α <|>
      @ULiftable.upMap Gen.{v} Gen.{max v u} _ _ _ _ (@Sum.inr α β) sam_β
  shrink α β Iα Iβ shr_α shr_β := @Sum.shrink _ _ Iα Iβ shr_α shr_β
  pRepr := @Sum.hasRepr
#align slim_check.sum.sampleable SlimCheck.Sum.sampleable

instance Rat.sampleable : Sampleable ℚ :=
  (Sampleable.lift (ℤ × ℕ+) (fun x => Prod.casesOn x Rat.mkPnat) fun r =>
      (r.Num, ⟨r.den, r.Pos⟩)) <|
    by
    intro i
    rcases i with ⟨x, ⟨y, hy⟩⟩ <;> unfold_wf <;> dsimp [Rat.mkPnat]
    mono*
    · rw [← Int.ofNat_le, Int.coe_natAbs, Int.coe_natAbs]
      apply Int.abs_ediv_le_abs
    · change _ - 1 ≤ y - 1
      apply tsub_le_tsub_right
      apply Nat.div_le_of_le_mul
      suffices 1 * y ≤ x.nat_abs.gcd y * y by simpa
      apply Nat.mul_le_mul_right
      apply gcd_pos_of_pos_right _ hy
#align slim_check.rat.sampleable SlimCheck.Rat.sampleable

/-- `sampleable_char` can be specialized into customized `sampleable char` instances.

The resulting instance has `1 / length` chances of making an unrestricted choice of characters
and it otherwise chooses a character from `characters` with uniform probabilities.  -/
def sampleableChar (length : Nat) (characters : String) : Sampleable Char
    where
  sample := do
    let x ← chooseNat 0 length (by decide)
    if x = 0 then do
        let n ← sample ℕ
        pure <| Char.ofNat n
      else do
        let i ← choose_nat 0 (characters - 1) (by decide)
        pure (characters i).curr
  shrink _ := LazyList.nil
#align slim_check.sampleable_char SlimCheck.sampleableChar

#print SlimCheck.Char.sampleable /-
instance Char.sampleable : Sampleable Char :=
  sampleableChar 3 " 0123abcABC:,;`\\/"
#align slim_check.char.sampleable SlimCheck.Char.sampleable
-/

variable {α}

section ListShrink

variable [SizeOf α] (shr : ∀ x : α, LazyList { y : α // SizeofLt y x })

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem List.sizeOf_drop_lt_sizeOf_of_lt_length {xs : List α} {k} (hk : 0 < k)
    (hk' : k < xs.length) : SizeOf.sizeOf (List.drop k xs) < SizeOf.sizeOf xs :=
  by
  induction' xs with x xs generalizing k
  · cases hk'
  cases k
  · cases hk
  have : SizeOf.sizeOf xs < SizeOf.sizeOf (x::xs) := by unfold_wf
  cases k
  · simp only [this, List.drop]
  · simp only [List.drop]
    trans
    · solve_by_elim [xs_ih, lt_of_succ_lt_succ hk', zero_lt_succ]
    · assumption
#align slim_check.list.sizeof_drop_lt_sizeof_of_lt_length SlimCheck.List.sizeOf_drop_lt_sizeOf_of_lt_length

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem List.sizeOf_cons_lt_right (a b : α) {xs : List α} (h : SizeOf.sizeOf a < SizeOf.sizeOf b) :
    SizeOf.sizeOf (a::xs) < SizeOf.sizeOf (b::xs) := by unfold_wf <;> assumption
#align slim_check.list.sizeof_cons_lt_right SlimCheck.List.sizeOf_cons_lt_right

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem List.sizeOf_cons_lt_left (x : α) {xs xs' : List α}
    (h : SizeOf.sizeOf xs < SizeOf.sizeOf xs') : SizeOf.sizeOf (x::xs) < SizeOf.sizeOf (x::xs') :=
  by unfold_wf <;> assumption
#align slim_check.list.sizeof_cons_lt_left SlimCheck.List.sizeOf_cons_lt_left

theorem List.sizeOf_append_lt_left {xs ys ys' : List α} (h : SizeOf.sizeOf ys < SizeOf.sizeOf ys') :
    SizeOf.sizeOf (xs ++ ys) < SizeOf.sizeOf (xs ++ ys') :=
  by
  induction xs
  · apply h
  · unfold_wf
    simp only [List.sizeof, add_lt_add_iff_left]
    exact xs_ih
#align slim_check.list.sizeof_append_lt_left SlimCheck.List.sizeOf_append_lt_left

theorem List.one_le_sizeOf (xs : List α) : 1 ≤ SizeOf.sizeOf xs := by
  cases xs <;> unfold_wf <;> linarith
#align slim_check.list.one_le_sizeof SlimCheck.List.one_le_sizeOf

/-- `list.shrink_removes` shrinks a list by removing chunks of size `k` in
the middle of the list.
-/
def List.shrinkRemoves (k : ℕ) (hk : 0 < k) :
    ∀ (xs : List α) (n), n = xs.length → LazyList { ys : List α // SizeofLt ys xs }
  | xs, n, hn =>
    if hkn : k > n then LazyList.nil
    else
      if hkn' : k = n then
        have : 1 < xs.sizeOf := by
          subst_vars; cases xs; · contradiction
          unfold_wf; apply lt_of_lt_of_le
          show 1 < 1 + SizeOf.sizeOf xs_hd + 1; · linarith
          · mono; apply list.one_le_sizeof
        LazyList.singleton ⟨[], this⟩
      else
        have h₂ : k < xs.length := hn ▸ lt_of_le_of_ne (le_of_not_gt hkn) hkn'
        match (motive := ∀ ys, ys = List.splitAt k xs → _) List.splitAt k xs, rfl with
        | ⟨xs₁, xs₂⟩, h =>
          have h₄ : xs₁ = xs.take k := by
            simp only [List.splitAt_eq_take_drop, Prod.mk.inj_iff] at h  <;> tauto
          have h₃ : xs₂ = xs.drop k := by
            simp only [List.splitAt_eq_take_drop, Prod.mk.inj_iff] at h  <;> tauto
          have : SizeOf.sizeOf xs₂ < SizeOf.sizeOf xs := by
            rw [h₃] <;> solve_by_elim [list.sizeof_drop_lt_sizeof_of_lt_length]
          have h₁ : n - k = xs₂.length := by simp only [h₃, ← hn, List.length_drop]
          have h₅ : ∀ a : List α, SizeofLt a xs₂ → SizeofLt (xs₁ ++ a) xs := by
            intro a h <;> rw [← List.take_append_drop k xs, ← h₃, ← h₄] <;>
              solve_by_elim [list.sizeof_append_lt_left]
          LazyList.cons ⟨xs₂, this⟩ <|
            Subtype.map ((· ++ ·) xs₁) h₅ <$> list.shrink_removes xs₂ (n - k) h₁
#align slim_check.list.shrink_removes SlimCheck.List.shrinkRemoves

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:228:8: unsupported: ambiguous notation -/
/-- `list.shrink_one xs` shrinks list `xs` by shrinking only one item in
the list.
-/
def List.shrinkOne : ShrinkFn (List α)
  | [] => LazyList.nil
  | x::xs =>
    LazyList.append
      ((Subtype.map (fun x' => x'::xs) fun a => List.sizeOf_cons_lt_right _ _) <$> shr x)
      ((Subtype.map ((·::·) x) fun _ => List.sizeOf_cons_lt_left _) <$> list.shrink_one xs)
#align slim_check.list.shrink_one SlimCheck.List.shrinkOne

/-- `list.shrink_with shrink_f xs` shrinks `xs` by first
considering `xs` with chunks removed in the middle (starting with
chunks of size `xs.length` and halving down to `1`) and then
shrinks only one element of the list.

This strategy is taken directly from Haskell's QuickCheck -/
def List.shrinkWith (xs : List α) : LazyList { ys : List α // SizeofLt ys xs } :=
  let n := xs.length
  LazyList.append
    ((LazyList.cons n <| (shrink n).reverse.map Subtype.val).bind fun k =>
      if hk : 0 < k then List.shrinkRemoves k hk xs n rfl else LazyList.nil)
    (List.shrinkOne shr _)
#align slim_check.list.shrink_with SlimCheck.List.shrinkWith

end ListShrink

instance List.sampleable : SampleableFunctor List.{u}
    where
  wf := _
  sample α sam_α := listOf sam_α
  shrink α Iα shr_α := @List.shrinkWith _ Iα shr_α
  pRepr := @List.hasRepr
#align slim_check.list.sampleable SlimCheck.List.sampleable

#print SlimCheck.Prop.sampleableExt /-
instance Prop.sampleableExt : SampleableExt Prop
    where
  ProxyRepr := Bool
  interp := coe
  sample := chooseAny Bool
  shrink _ := LazyList.nil
#align slim_check.Prop.sampleable_ext SlimCheck.Prop.sampleableExt
-/

#print SlimCheck.NoShrink /-
/-- `no_shrink` is a type annotation to signal that
a certain type is not to be shrunk. It can be useful in
combination with other types: e.g. `xs : list (no_shrink ℤ)`
will result in the list being cut down but individual
integers being kept as is. -/
def NoShrink (α : Type _) :=
  α
#align slim_check.no_shrink SlimCheck.NoShrink
-/

#print SlimCheck.NoShrink.inhabited /-
instance NoShrink.inhabited {α} [Inhabited α] : Inhabited (NoShrink α) :=
  ⟨(default : α)⟩
#align slim_check.no_shrink.inhabited SlimCheck.NoShrink.inhabited
-/

#print SlimCheck.NoShrink.mk /-
/-- Introduction of the `no_shrink` type. -/
def NoShrink.mk {α} (x : α) : NoShrink α :=
  x
#align slim_check.no_shrink.mk SlimCheck.NoShrink.mk
-/

#print SlimCheck.NoShrink.get /-
/-- Selector of the `no_shrink` type. -/
def NoShrink.get {α} (x : NoShrink α) : α :=
  x
#align slim_check.no_shrink.get SlimCheck.NoShrink.get
-/

instance NoShrink.sampleable {α} [Sampleable α] : Sampleable (NoShrink α)
    where sample := NoShrink.mk <$> sample α
#align slim_check.no_shrink.sampleable SlimCheck.NoShrink.sampleable

instance String.sampleable : Sampleable String :=
  { Sampleable.lift (List Char) List.asString String.toList fun _ => le_rfl with
    sample := do
      let x ← listOf (sample Char)
      pure x }
#align slim_check.string.sampleable SlimCheck.String.sampleable

/-- implementation of `sampleable (tree α)` -/
def Tree.sample (sample : Gen α) : ℕ → Gen (Tree α)
  | n =>
    if h : n > 0 then
      have : n / 2 < n := div_lt_self h (by norm_num)
      Tree.node <$> sample <*> tree.sample (n / 2) <*> tree.sample (n / 2)
    else pure Tree.nil
#align slim_check.tree.sample SlimCheck.Tree.sample

/-- `rec_shrink x f_rec` takes the recursive call `f_rec` introduced
by `well_founded.fix` and turns it into a shrinking function whose
result is adequate to use in a recursive call. -/
def recShrink {α : Type _} [SizeOf α] (t : α)
    (sh : ∀ x : α, SizeofLt x t → LazyList { y : α // SizeofLt y x }) :
    ShrinkFn { t' : α // SizeofLt t' t }
  | ⟨t', ht'⟩ =>
    (fun t'' : { y : α // SizeofLt y t' } =>
        ⟨⟨t''.val, lt_trans t''.property ht'⟩, t''.property⟩) <$>
      sh t' ht'
#align slim_check.rec_shrink SlimCheck.recShrink

theorem Tree.one_le_sizeOf {α} [SizeOf α] (t : Tree α) : 1 ≤ SizeOf.sizeOf t := by
  cases t <;> unfold_wf <;> linarith
#align slim_check.tree.one_le_sizeof SlimCheck.Tree.one_le_sizeOf

instance : Functor Tree where map := @Tree.map

/-- Recursion principle for shrinking tree-like structures.
-/
def recShrinkWith [SizeOf α]
    (shrink_a :
      ∀ x : α, ShrinkFn { y : α // SizeofLt y x } → List (LazyList { y : α // SizeofLt y x })) :
    ShrinkFn α :=
  WellFounded.fix (sizeofMeasure_wf _) fun t f_rec =>
    LazyList.join (LazyList.ofList <| shrink_a t fun ⟨t', h⟩ => recShrink _ f_rec _)
#align slim_check.rec_shrink_with SlimCheck.recShrinkWith

theorem recShrinkWith_eq [SizeOf α]
    (shrink_a :
      ∀ x : α, ShrinkFn { y : α // SizeofLt y x } → List (LazyList { y : α // SizeofLt y x }))
    (x : α) :
    recShrinkWith shrink_a x =
      LazyList.join
        (LazyList.ofList <|
          shrink_a x fun t' => recShrink _ (fun x h' => recShrinkWith shrink_a x) _) :=
  by
  conv_lhs => rw [rec_shrink_with, WellFounded.fix_eq]
  congr; ext ⟨y, h⟩; rfl
#align slim_check.rec_shrink_with_eq SlimCheck.recShrinkWith_eq

/-- `tree.shrink_with shrink_f t` shrinks `xs` by using the empty tree,
each subtrees, and by shrinking the subtree to recombine them.

This strategy is taken directly from Haskell's QuickCheck -/
def Tree.shrinkWith [SizeOf α] (shrink_a : ShrinkFn α) : ShrinkFn (Tree α) :=
  recShrinkWith fun t =>
    match t with
    | Tree.nil => fun f_rec => []
    | Tree.node x t₀ t₁ => fun f_rec =>
      have h₂ : SizeofLt Tree.nil (Tree.node x t₀ t₁) := by
        clear _match <;> have := tree.one_le_sizeof t₀ <;>
              dsimp [sizeof_lt, SizeOf.sizeOf, SizeOf.sizeOf] at * <;>
            unfold_wf <;>
          linarith
      have h₀ : SizeofLt t₀ (Tree.node x t₀ t₁) := by dsimp [sizeof_lt] <;> unfold_wf <;> linarith
      have h₁ : SizeofLt t₁ (Tree.node x t₀ t₁) := by dsimp [sizeof_lt] <;> unfold_wf <;> linarith
      [LazyList.ofList [⟨Tree.nil, h₂⟩, ⟨t₀, h₀⟩, ⟨t₁, h₁⟩],
        (Prod.shrink shrink_a (Prod.shrink f_rec f_rec) (x, ⟨t₀, h₀⟩, ⟨t₁, h₁⟩)).map
          fun ⟨⟨y, ⟨t'₀, _⟩, ⟨t'₁, _⟩⟩, hy⟩ =>
          ⟨Tree.node y t'₀ t'₁, by
            revert hy <;> dsimp [sizeof_lt] <;> unfold_wf <;> intro <;> linarith⟩]
#align slim_check.tree.shrink_with SlimCheck.Tree.shrinkWith

instance sampleableTree : SampleableFunctor Tree
    where
  wf := _
  sample α sam_α := sized <| Tree.sample sam_α
  shrink α Iα shr_α := @Tree.shrinkWith _ Iα shr_α
  pRepr := @Tree.hasRepr
#align slim_check.sampleable_tree SlimCheck.sampleableTree

/-- Type tag that signals to `slim_check` to use small values for a given type. -/
def Small (α : Type _) :=
  α
#align slim_check.small SlimCheck.Small

/-- Add the `small` type tag -/
def Small.mk {α} (x : α) : Small α :=
  x
#align slim_check.small.mk SlimCheck.Small.mk

/-- Type tag that signals to `slim_check` to use large values for a given type. -/
def Large (α : Type _) :=
  α
#align slim_check.large SlimCheck.Large

/-- Add the `large` type tag -/
def Large.mk {α} (x : α) : Large α :=
  x
#align slim_check.large.mk SlimCheck.Large.mk

instance Small.functor : Functor Small :=
  id.monad.toFunctor
#align slim_check.small.functor SlimCheck.Small.functor

instance Large.functor : Functor Large :=
  id.monad.toFunctor
#align slim_check.large.functor SlimCheck.Large.functor

instance Small.inhabited [Inhabited α] : Inhabited (Small α) :=
  ⟨(default : α)⟩
#align slim_check.small.inhabited SlimCheck.Small.inhabited

instance Large.inhabited [Inhabited α] : Inhabited (Large α) :=
  ⟨(default : α)⟩
#align slim_check.large.inhabited SlimCheck.Large.inhabited

instance Small.sampleableFunctor : SampleableFunctor Small
    where
  wf := _
  sample α samp := Gen.resize (fun n => n / 5 + 5) samp
  shrink α _ := id
  pRepr α := id
#align slim_check.small.sampleable_functor SlimCheck.Small.sampleableFunctor

instance Large.sampleableFunctor : SampleableFunctor Large
    where
  wf := _
  sample α samp := Gen.resize (fun n => n * 5) samp
  shrink α _ := id
  pRepr α := id
#align slim_check.large.sampleable_functor SlimCheck.Large.sampleableFunctor

instance Ulift.sampleableFunctor : SampleableFunctor ULift.{u, v}
    where
  wf α h := ⟨fun ⟨x⟩ => @SizeOf.sizeOf α h x⟩
  sample α samp := ULiftable.upMap ULift.up <| samp
  shrink := fun α _ shr ⟨x⟩ => (shr x).map (Subtype.map ULift.up fun a h => h)
  pRepr α h := ⟨@repr α h ∘ ULift.down⟩
#align slim_check.ulift.sampleable_functor SlimCheck.Ulift.sampleableFunctor

/-!
## Subtype instances

The following instances are meant to improve the testing of properties of the form
`∀ i j, i ≤ j, ...`

The naive way to test them is to choose two numbers `i` and `j` and check that
the proper ordering is satisfied. Instead, the following instances make it
so that `j` will be chosen with considerations to the required ordering
constraints. The benefit is that we will not have to discard any choice
of `j`.
 -/


/-! ### Subtypes of `ℕ` -/


instance NatLe.sampleable {y} : SlimCheck.Sampleable { x : ℕ // x ≤ y }
    where
  sample := do
    let ⟨x, h⟩ ← SlimCheck.Gen.chooseNat 0 y (by decide)
    pure ⟨x, h.2⟩
  shrink := fun ⟨x, h⟩ =>
    (fun a : Subtype _ => Subtype.recOn a fun x' h' => ⟨⟨x', le_trans (le_of_lt h') h⟩, h'⟩) <$>
      shrink x
#align slim_check.nat_le.sampleable SlimCheck.NatLe.sampleable

instance NatGe.sampleable {x} : SlimCheck.Sampleable { y : ℕ // x ≤ y }
    where
  sample := do
    let (y : ℕ) ← SlimCheck.Sampleable.sample ℕ
    pure ⟨x + y, by norm_num⟩
  shrink := fun ⟨y, h⟩ =>
    (fun a : { y' // SizeOf.sizeOf y' < SizeOf.sizeOf (y - x) } =>
        Subtype.recOn a fun δ h' => ⟨⟨x + δ, Nat.le_add_right _ _⟩, lt_tsub_iff_left.mp h'⟩) <$>
      shrink (y - x)
#align slim_check.nat_ge.sampleable SlimCheck.NatGe.sampleable

/- there is no `nat_lt.sampleable` instance because if `y = 0`, there is no valid choice
to satisfy `x < y` -/
instance NatGt.sampleable {x} : SlimCheck.Sampleable { y : ℕ // x < y }
    where
  sample := do
    let (y : ℕ) ← SlimCheck.Sampleable.sample ℕ
    pure ⟨x + y + 1, by linarith⟩
  shrink x := shrink _
#align slim_check.nat_gt.sampleable SlimCheck.NatGt.sampleable

/-! ### Subtypes of any `linear_ordered_add_comm_group` -/


instance Le.sampleable {y : α} [Sampleable α] [LinearOrderedAddCommGroup α] :
    SlimCheck.Sampleable { x : α // x ≤ y }
    where
  sample := do
    let x ← sample α
    pure ⟨y - |x|, sub_le_self _ (abs_nonneg _)⟩
  shrink _ := LazyList.nil
#align slim_check.le.sampleable SlimCheck.Le.sampleable

instance Ge.sampleable {x : α} [Sampleable α] [LinearOrderedAddCommGroup α] :
    SlimCheck.Sampleable { y : α // x ≤ y }
    where
  sample := do
    let y ← sample α
    pure ⟨x + |y|, by norm_num [abs_nonneg]⟩
  shrink _ := LazyList.nil
#align slim_check.ge.sampleable SlimCheck.Ge.sampleable

/-!
### Subtypes of `ℤ`

Specializations of `le.sampleable` and `ge.sampleable` for `ℤ` to help instance search.
-/


instance IntLe.sampleable {y : ℤ} : SlimCheck.Sampleable { x : ℤ // x ≤ y } :=
  Sampleable.lift ℕ (fun n => ⟨y - n, Int.sub_left_le_of_le_add <| by simp⟩)
    (fun ⟨i, h⟩ => (y - i).natAbs) fun n => by
    unfold_wf <;> simp [int_le.sampleable._match_1] <;> ring
#align slim_check.int_le.sampleable SlimCheck.IntLe.sampleable

instance IntGe.sampleable {x : ℤ} : SlimCheck.Sampleable { y : ℤ // x ≤ y } :=
  Sampleable.lift ℕ (fun n => ⟨x + n, by simp⟩) (fun ⟨i, h⟩ => (i - x).natAbs) fun n => by
    unfold_wf <;> simp [int_ge.sampleable._match_1] <;> ring
#align slim_check.int_ge.sampleable SlimCheck.IntGe.sampleable

instance IntLt.sampleable {y} : SlimCheck.Sampleable { x : ℤ // x < y } :=
  Sampleable.lift ℕ
    (fun n => ⟨y - (n + 1), Int.sub_left_lt_of_lt_add <| by linarith [Int.coe_nat_nonneg n]⟩)
    (fun ⟨i, h⟩ => (y - i - 1).natAbs) fun n => by
    unfold_wf <;> simp [int_lt.sampleable._match_1] <;> ring
#align slim_check.int_lt.sampleable SlimCheck.IntLt.sampleable

instance IntGt.sampleable {x} : SlimCheck.Sampleable { y : ℤ // x < y } :=
  Sampleable.lift ℕ (fun n => ⟨x + (n + 1), by linarith⟩) (fun ⟨i, h⟩ => (i - x - 1).natAbs)
    fun n => by unfold_wf <;> simp [int_gt.sampleable._match_1] <;> ring
#align slim_check.int_gt.sampleable SlimCheck.IntGt.sampleable

/-! ### Subtypes of any `list` -/


instance Perm.slimCheck {xs : List α} : SlimCheck.Sampleable { ys : List α // List.Perm xs ys }
    where
  sample := permutationOf xs
  shrink _ := LazyList.nil
#align slim_check.perm.slim_check SlimCheck.Perm.slimCheck

instance Perm'.slimCheck {xs : List α} : SlimCheck.Sampleable { ys : List α // List.Perm ys xs }
    where
  sample := Subtype.map id (@List.Perm.symm α _) <$> permutationOf xs
  shrink _ := LazyList.nil
#align slim_check.perm'.slim_check SlimCheck.Perm'.slimCheck

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
open Tactic

#print SlimCheck.printSamples /-
/-- Print (at most) 10 samples of a given type to stdout for debugging.
-/
def printSamples {t : Type u} [Repr t] (g : Gen t) : Io Unit := do
  let xs ←
    Io.runRand <|
        ULiftable.down do
          let xs ← (List.range 10).mapM <| g.run ∘ ULift.up
          pure ⟨xs repr⟩
  xs Io.putStrLn
#align slim_check.print_samples SlimCheck.printSamples
-/

/-- Create a `gen α` expression from the argument of `#sample` -/
unsafe def mk_generator (e : expr) : tactic (expr × expr) := do
  let t ← infer_type e
  match t with
    | q(Gen $(t)) => do
      let repr_inst ← mk_app `` Repr [t] >>= mk_instance
      pure (repr_inst, e)
    | _ => do
      let samp_inst ← to_expr ``(SampleableExt $(e)) >>= mk_instance
      let repr_inst ← mk_mapp `` sampleable_ext.p_repr [e, samp_inst]
      let gen ← mk_mapp `` sampleable_ext.sample [none, samp_inst]
      pure (repr_inst, gen)
#align slim_check.mk_generator slim_check.mk_generator

/-- `#sample my_type`, where `my_type` has an instance of `sampleable`, prints ten random
values of type `my_type` of using an increasing size parameter.

```lean
#sample nat
-- prints
-- 0
-- 0
-- 2
-- 24
-- 64
-- 76
-- 5
-- 132
-- 8
-- 449
-- or some other sequence of numbers

#sample list int
-- prints
-- []
-- [1, 1]
-- [-7, 9, -6]
-- [36]
-- [-500, 105, 260]
-- [-290]
-- [17, 156]
-- [-2364, -7599, 661, -2411, -3576, 5517, -3823, -968]
-- [-643]
-- [11892, 16329, -15095, -15461]
-- or whatever
```
-/
@[user_command]
unsafe def sample_cmd (_ : parse <| tk "#sample") : lean.parser Unit := do
  let e ← texpr
  of_tactic do
      let e ← i_to_expr e
      let (repr_inst, gen) ← mk_generator e
      let print_samples ← mk_mapp `` print_samples [none, repr_inst, gen]
      let sample ← eval_expr (Io Unit) print_samples
      unsafe_run_io sample
#align slim_check.sample_cmd slim_check.sample_cmd

end SlimCheck

