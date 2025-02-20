/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module control.uliftable
! leanprover-community/mathlib commit 1b089e3bdc3ce6b39cd472543474a0a137128c6c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Monad.Basic
import Mathbin.Control.Monad.Cont
import Mathbin.Control.Monad.Writer
import Mathbin.Logic.Equiv.Basic
import Mathbin.Tactic.Interactive

/-!
# Universe lifting for type families

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Some functors such as `option` and `list` are universe polymorphic. Unlike
type polymorphism where `option α` is a function application and reasoning and
generalizations that apply to functions can be used, `option.{u}` and `option.{v}`
are not one function applied to two universe names but one polymorphic definition
instantiated twice. This means that whatever works on `option.{u}` is hard
to transport over to `option.{v}`. `uliftable` is an attempt at improving the situation.

`uliftable option.{u} option.{v}` gives us a generic and composable way to use
`option.{u}` in a context that requires `option.{v}`. It is often used in tandem with
`ulift` but the two are purposefully decoupled.


## Main definitions
  * `uliftable` class

## Tags

universe polymorphism functor

-/


universe u₀ u₁ v₀ v₁ v₂ w w₀ w₁

variable {s : Type u₀} {s' : Type u₁} {r r' w w' : Type _}

#print ULiftable /-
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`congr] [] -/
/-- Given a universe polymorphic type family `M.{u} : Type u₁ → Type
u₂`, this class convert between instantiations, from
`M.{u} : Type u₁ → Type u₂` to `M.{v} : Type v₁ → Type v₂` and back -/
class ULiftable (f : Type u₀ → Type u₁) (g : Type v₀ → Type v₁) where
  congr {α β} : α ≃ β → f α ≃ g β
#align uliftable ULiftable
-/

namespace ULiftable

#print ULiftable.up /-
/-- The most common practical use `uliftable` (together with `up`), this function takes
`x : M.{u} α` and lifts it to M.{max u v} (ulift.{v} α) -/
@[reducible]
def up {f : Type u₀ → Type u₁} {g : Type max u₀ v₀ → Type v₁} [ULiftable f g] {α} :
    f α → g (ULift α) :=
  (ULiftable.congr f g Equiv.ulift.symm).toFun
#align uliftable.up ULiftable.up
-/

#print ULiftable.down /-
/-- The most common practical use of `uliftable` (together with `up`), this function takes
`x : M.{max u v} (ulift.{v} α)` and lowers it to `M.{u} α` -/
@[reducible]
def down {f : Type u₀ → Type u₁} {g : Type max u₀ v₀ → Type v₁} [ULiftable f g] {α} :
    g (ULift α) → f α :=
  (ULiftable.congr f g Equiv.ulift.symm).invFun
#align uliftable.down ULiftable.down
-/

#print ULiftable.adaptUp /-
/-- convenient shortcut to avoid manipulating `ulift` -/
def adaptUp (F : Type v₀ → Type v₁) (G : Type max v₀ u₀ → Type u₁) [ULiftable F G] [Monad G] {α β}
    (x : F α) (f : α → G β) : G β :=
  up x >>= f ∘ ULift.down
#align uliftable.adapt_up ULiftable.adaptUp
-/

#print ULiftable.adaptDown /-
/-- convenient shortcut to avoid manipulating `ulift` -/
def adaptDown {F : Type max u₀ v₀ → Type u₁} {G : Type v₀ → Type v₁} [L : ULiftable G F] [Monad F]
    {α β} (x : F α) (f : α → G β) : G β :=
  @down.{v₀, v₁, max u₀ v₀} G F L β <| x >>= @up.{v₀, v₁, max u₀ v₀} G F L β ∘ f
#align uliftable.adapt_down ULiftable.adaptDown
-/

#print ULiftable.upMap /-
/-- map function that moves up universes -/
def upMap {F : Type u₀ → Type u₁} {G : Type max u₀ v₀ → Type v₁} [inst : ULiftable F G] [Functor G]
    {α β} (f : α → β) (x : F α) : G β :=
  Functor.map (f ∘ ULift.down) (up x)
#align uliftable.up_map ULiftable.upMap
-/

#print ULiftable.downMap /-
/-- map function that moves down universes -/
def downMap {F : Type max u₀ v₀ → Type u₁} {G : Type u₀ → Type v₁} [inst : ULiftable G F]
    [Functor F] {α β} (f : α → β) (x : F α) : G β :=
  down (Functor.map (ULift.up ∘ f) x : F (ULift β))
#align uliftable.down_map ULiftable.downMap
-/

#print ULiftable.up_down /-
@[simp]
theorem up_down {f : Type u₀ → Type u₁} {g : Type max u₀ v₀ → Type v₁} [ULiftable f g] {α}
    (x : g (ULift α)) : up (down x : f α) = x :=
  (ULiftable.congr f g Equiv.ulift.symm).right_inv _
#align uliftable.up_down ULiftable.up_down
-/

#print ULiftable.down_up /-
@[simp]
theorem down_up {f : Type u₀ → Type u₁} {g : Type max u₀ v₀ → Type v₁} [ULiftable f g] {α}
    (x : f α) : down (up x : g _) = x :=
  (ULiftable.congr f g Equiv.ulift.symm).left_inv _
#align uliftable.down_up ULiftable.down_up
-/

end ULiftable

open ULift

instance : ULiftable id id where congr α β F := F

/-- for specific state types, this function helps to create a uliftable instance -/
def StateT.uliftable' {m : Type u₀ → Type v₀} {m' : Type u₁ → Type v₁} [ULiftable m m']
    (F : s ≃ s') : ULiftable (StateT s m) (StateT s' m')
    where congr α β G :=
    StateT.equiv <| Equiv.piCongr F fun _ => ULiftable.congr _ _ <| Equiv.prodCongr G F
#align state_t.uliftable' StateTₓ.uliftable'

instance {m m'} [ULiftable m m'] : ULiftable (StateT s m) (StateT (ULift s) m') :=
  StateT.uliftable' Equiv.ulift.symm

/-- for specific reader monads, this function helps to create a uliftable instance -/
def ReaderT.uliftable' {m m'} [ULiftable m m'] (F : s ≃ s') :
    ULiftable (ReaderT s m) (ReaderT s' m')
    where congr α β G := ReaderT.equiv <| Equiv.piCongr F fun _ => ULiftable.congr _ _ G
#align reader_t.uliftable' ReaderTₓ.uliftable'

instance {m m'} [ULiftable m m'] : ULiftable (ReaderT s m) (ReaderT (ULift s) m') :=
  ReaderT.uliftable' Equiv.ulift.symm

#print ContT.uliftable' /-
/-- for specific continuation passing monads, this function helps to create a uliftable instance -/
def ContT.uliftable' {m m'} [ULiftable m m'] (F : r ≃ r') : ULiftable (ContT r m) (ContT r' m')
    where congr α β := ContT.equiv (ULiftable.congr _ _ F)
#align cont_t.uliftable' ContT.uliftable'
-/

instance {s m m'} [ULiftable m m'] : ULiftable (ContT s m) (ContT (ULift s) m') :=
  ContT.uliftable' Equiv.ulift.symm

/-- for specific writer monads, this function helps to create a uliftable instance -/
def WriterT.uliftable' {m m'} [ULiftable m m'] (F : w ≃ w') :
    ULiftable (WriterT w m) (WriterT w' m')
    where congr α β G := WriterT.equiv <| ULiftable.congr _ _ <| Equiv.prodCongr G F
#align writer_t.uliftable' WriterTₓ.uliftable'

instance {m m'} [ULiftable m m'] : ULiftable (WriterT s m) (WriterT (ULift s) m') :=
  WriterT.uliftable' Equiv.ulift.symm

