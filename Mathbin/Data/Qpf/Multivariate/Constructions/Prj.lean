/-
Copyright (c) 2020 Simon Hudon All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module data.qpf.multivariate.constructions.prj
! leanprover-community/mathlib commit 23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Functor.Multivariate
import Mathbin.Data.Qpf.Multivariate.Basic

/-!
> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Projection functors are QPFs. The `n`-ary projection functors on `i` is an `n`-ary
functor `F` such that `F (α₀..αᵢ₋₁, αᵢ, αᵢ₊₁..αₙ₋₁) = αᵢ`
-/


universe u v

namespace MvQPF

open scoped MvFunctor

variable {n : ℕ} (i : Fin2 n)

#print MvQPF.Prj /-
/-- The projection `i` functor -/
def Prj (v : TypeVec.{u} n) : Type u :=
  v i
#align mvqpf.prj MvQPF.Prj
-/

#print MvQPF.Prj.inhabited /-
instance Prj.inhabited {v : TypeVec.{u} n} [Inhabited (v i)] : Inhabited (Prj i v) :=
  ⟨(default : v i)⟩
#align mvqpf.prj.inhabited MvQPF.Prj.inhabited
-/

#print MvQPF.Prj.map /-
/-- `map` on functor `prj i` -/
def Prj.map ⦃α β : TypeVec n⦄ (f : α ⟹ β) : Prj i α → Prj i β :=
  f _
#align mvqpf.prj.map MvQPF.Prj.map
-/

#print MvQPF.Prj.mvfunctor /-
instance Prj.mvfunctor : MvFunctor (Prj i) where map := Prj.map i
#align mvqpf.prj.mvfunctor MvQPF.Prj.mvfunctor
-/

#print MvQPF.Prj.P /-
/-- Polynomial representation of the projection functor -/
def Prj.P : MvPFunctor.{u} n where
  A := PUnit
  B _ j := ULift <| PLift <| i = j
#align mvqpf.prj.P MvQPF.Prj.P
-/

#print MvQPF.Prj.abs /-
/-- Abstraction function of the `qpf` instance -/
def Prj.abs ⦃α : TypeVec n⦄ : (Prj.P i).Obj α → Prj i α
  | ⟨x, f⟩ => f _ ⟨⟨rfl⟩⟩
#align mvqpf.prj.abs MvQPF.Prj.abs
-/

#print MvQPF.Prj.repr /-
/-- Representation function of the `qpf` instance -/
def Prj.repr ⦃α : TypeVec n⦄ : Prj i α → (Prj.P i).Obj α := fun x : α i =>
  ⟨⟨⟩, fun j ⟨⟨h⟩⟩ => (h.rec x : α j)⟩
#align mvqpf.prj.repr MvQPF.Prj.repr
-/

#print MvQPF.Prj.mvqpf /-
instance Prj.mvqpf : MvQPF (Prj i) where
  p := Prj.P i
  abs := Prj.abs i
  repr := Prj.repr i
  abs_repr := by intros <;> rfl
  abs_map := by intros <;> cases p <;> rfl
#align mvqpf.prj.mvqpf MvQPF.Prj.mvqpf
-/

end MvQPF

