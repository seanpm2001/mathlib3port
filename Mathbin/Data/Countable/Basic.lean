/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module data.countable.basic
! leanprover-community/mathlib commit 63f84d91dd847f50bae04a01071f3a5491934e36
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Equiv.Nat
import Mathbin.Logic.Equiv.Fin
import Mathbin.Data.Countable.Defs

/-!
# Countable types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we provide basic instances of the `countable` typeclass defined elsewhere.
-/


universe u v w

open Function

instance : Countable ℤ :=
  Countable.of_equiv ℕ Equiv.intEquivNat.symm

/-!
### Definition in terms of `function.embedding`
-/


section Embedding

variable {α : Sort u} {β : Sort v}

#print countable_iff_nonempty_embedding /-
theorem countable_iff_nonempty_embedding : Countable α ↔ Nonempty (α ↪ ℕ) :=
  ⟨fun ⟨⟨f, hf⟩⟩ => ⟨⟨f, hf⟩⟩, fun ⟨f⟩ => ⟨⟨f, f.2⟩⟩⟩
#align countable_iff_nonempty_embedding countable_iff_nonempty_embedding
-/

#print nonempty_embedding_nat /-
theorem nonempty_embedding_nat (α) [Countable α] : Nonempty (α ↪ ℕ) :=
  countable_iff_nonempty_embedding.1 ‹_›
#align nonempty_embedding_nat nonempty_embedding_nat
-/

#print Function.Embedding.countable /-
protected theorem Function.Embedding.countable [Countable β] (f : α ↪ β) : Countable α :=
  f.Injective.Countable
#align function.embedding.countable Function.Embedding.countable
-/

end Embedding

/-!
### Operations on `Type*`s
-/


section Type

variable {α : Type u} {β : Type v} {π : α → Type w}

instance [Countable α] [Countable β] : Countable (Sum α β) :=
  by
  rcases exists_injective_nat α with ⟨f, hf⟩
  rcases exists_injective_nat β with ⟨g, hg⟩
  exact (equiv.nat_sum_nat_equiv_nat.injective.comp <| hf.sum_map hg).Countable

instance [Countable α] : Countable (Option α) :=
  Countable.of_equiv _ (Equiv.optionEquivSumPUnit α).symm

instance [Countable α] [Countable β] : Countable (α × β) :=
  by
  rcases exists_injective_nat α with ⟨f, hf⟩
  rcases exists_injective_nat β with ⟨g, hg⟩
  exact (nat.mkpair_equiv.injective.comp <| hf.prod_map hg).Countable

instance [Countable α] [∀ a, Countable (π a)] : Countable (Sigma π) :=
  by
  rcases exists_injective_nat α with ⟨f, hf⟩
  choose g hg using fun a => exists_injective_nat (π a)
  exact ((Equiv.sigmaEquivProd ℕ ℕ).Injective.comp <| hf.sigma_map hg).Countable

end Type

section Sort

variable {α : Sort u} {β : Sort v} {π : α → Sort w}

/-!
### Operations on and `Sort*`s
-/


#print SetCoe.countable /-
instance (priority := 500) SetCoe.countable {α} [Countable α] (s : Set α) : Countable s :=
  Subtype.countable
#align set_coe.countable SetCoe.countable
-/

instance [Countable α] [Countable β] : Countable (PSum α β) :=
  Countable.of_equiv (Sum (PLift α) (PLift β)) (Equiv.plift.sumPSum Equiv.plift)

instance [Countable α] [Countable β] : Countable (PProd α β) :=
  Countable.of_equiv (PLift α × PLift β) (Equiv.plift.prodPProd Equiv.plift)

instance [Countable α] [∀ a, Countable (π a)] : Countable (PSigma π) :=
  Countable.of_equiv (Σ a : PLift α, PLift (π a.down)) (Equiv.psigmaEquivSigmaPLift π).symm

instance [Finite α] [∀ a, Countable (π a)] : Countable (∀ a, π a) :=
  by
  have : ∀ n, Countable (Fin n → ℕ) := by
    intro n; induction' n with n ihn
    · infer_instance
    · exact Countable.of_equiv _ (Equiv.piFinSucc _ _).symm
  rcases Finite.exists_equiv_fin α with ⟨n, ⟨e⟩⟩
  have f := fun a => (nonempty_embedding_nat (π a)).some
  exact ((embedding.Pi_congr_right f).trans (Equiv.piCongrLeft' _ e).toEmbedding).Countable

end Sort

