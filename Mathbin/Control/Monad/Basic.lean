/-
Copyright (c) 2019 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module control.monad.basic
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Equiv.Defs
import Mathbin.Tactic.Basic

/-!
# Monad

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Attributes

 * ext
 * functor_norm
 * monad_norm

## Implementation Details

Set of rewrite rules and automation for monads in general and
`reader_t`, `state_t`, `except_t` and `option_t` in particular.

The rewrite rules for monads are carefully chosen so that `simp with
functor_norm` will not introduce monadic vocabulary in a context where
applicatives would do just fine but will handle monadic notation
already present in an expression.

In a context where monadic reasoning is desired `simp with monad_norm`
will translate functor and applicative notation into monad notation
and use regular `functor_norm` rules as well.

## Tags

functor, applicative, monad, simp

-/


/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:61:9: unsupported: weird string -/
-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr'
/-- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:61:9: unsupported: weird string -/
  register_simp_attr
  monad_norm

/- [mathport] port note: move this to another file, it won't work here -/
attribute [monad_norm] functor_norm

attribute [ext] ReaderT.ext StateT.ext ExceptT.ext OptionT.ext

attribute [functor_norm] bind_assoc pure_bind bind_pure

attribute [monad_norm] seq_eq_bind_map

universe u v

#print map_eq_bind_pure_comp /-
@[monad_norm]
theorem map_eq_bind_pure_comp (m : Type u → Type v) [Monad m] [LawfulMonad m] {α β : Type u}
    (f : α → β) (x : m α) : f <$> x = x >>= pure ∘ f := by rw [bind_pure_comp_eq_map]
#align map_eq_bind_pure_comp map_eq_bind_pure_comp
-/

#print StateT.eval /-
/-- run a `state_t` program and discard the final state -/
def StateT.eval {m : Type u → Type v} [Functor m] {σ α} (cmd : StateT σ m α) (s : σ) : m α :=
  Prod.fst <$> cmd.run s
#align state_t.eval StateT.eval
-/

universe u₀ u₁ v₀ v₁

#print StateT.equiv /-
/-- reduce the equivalence between two state monads to the equivalence between
their respective function spaces -/
def StateT.equiv {m₁ : Type u₀ → Type v₀} {m₂ : Type u₁ → Type v₁} {α₁ σ₁ : Type u₀}
    {α₂ σ₂ : Type u₁} (F : (σ₁ → m₁ (α₁ × σ₁)) ≃ (σ₂ → m₂ (α₂ × σ₂))) :
    StateT σ₁ m₁ α₁ ≃ StateT σ₂ m₂ α₂
    where
  toFun := fun ⟨f⟩ => ⟨F f⟩
  invFun := fun ⟨f⟩ => ⟨F.symm f⟩
  left_inv := fun ⟨f⟩ => congr_arg StateT.mk <| F.left_inv _
  right_inv := fun ⟨f⟩ => congr_arg StateT.mk <| F.right_inv _
#align state_t.equiv StateT.equiv
-/

#print ReaderT.equiv /-
/-- reduce the equivalence between two reader monads to the equivalence between
their respective function spaces -/
def ReaderT.equiv {m₁ : Type u₀ → Type v₀} {m₂ : Type u₁ → Type v₁} {α₁ ρ₁ : Type u₀}
    {α₂ ρ₂ : Type u₁} (F : (ρ₁ → m₁ α₁) ≃ (ρ₂ → m₂ α₂)) : ReaderT ρ₁ m₁ α₁ ≃ ReaderT ρ₂ m₂ α₂
    where
  toFun := fun ⟨f⟩ => ⟨F f⟩
  invFun := fun ⟨f⟩ => ⟨F.symm f⟩
  left_inv := fun ⟨f⟩ => congr_arg ReaderT.mk <| F.left_inv _
  right_inv := fun ⟨f⟩ => congr_arg ReaderT.mk <| F.right_inv _
#align reader_t.equiv ReaderT.equiv
-/

