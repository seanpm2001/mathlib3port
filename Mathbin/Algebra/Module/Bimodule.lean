/-
Copyright (c) 2022 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.module.bimodule
! leanprover-community/mathlib commit 9aba7801eeecebb61f58a5763c2b6dd1b47dc6ef
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.TensorProduct

/-!
# Bimodules

One frequently encounters situations in which several sets of scalars act on a single space, subject
to compatibility condition(s). A distinguished instance of this is the theory of bimodules: one has
two rings `R`, `S` acting on an additive group `M`, with `R` acting covariantly ("on the left")
and `S` acting contravariantly ("on the right"). The compatibility condition is just:
`(r • m) • s = r • (m • s)` for all `r : R`, `s : S`, `m : M`.

This situation can be set up in Mathlib as:
```lean
variables (R S M : Type*) [ring R] [ring S]
variables [add_comm_group M] [module R M] [module Sᵐᵒᵖ M] [smul_comm_class R Sᵐᵒᵖ M]
```
The key fact is:
```lean
example : module (R ⊗[ℕ] Sᵐᵒᵖ) M := tensor_product.algebra.module
```
Note that the corresponding result holds for the canonically isomorphic ring `R ⊗[ℤ] Sᵐᵒᵖ` but it is
preferable to use the `R ⊗[ℕ] Sᵐᵒᵖ` instance since it works without additive inverses.

Bimodules are thus just a special case of `module`s and most of their properties follow from the
theory of `module`s`. In particular a two-sided submodule of a bimodule is simply a term of type
`submodule (R ⊗[ℕ] Sᵐᵒᵖ) M`.

This file is a place to collect results which are specific to bimodules.

## Main definitions

 * `subbimodule.mk`
 * `subbimodule.smul_mem`
 * `subbimodule.smul_mem'`
 * `subbimodule.to_submodule`
 * `subbimodule.to_submodule'`

## Implementation details

For many definitions and lemmas it is preferable to set things up without opposites, i.e., as:
`[module S M] [smul_comm_class R S M]` rather than `[module Sᵐᵒᵖ M] [smul_comm_class R Sᵐᵒᵖ M]`.
The corresponding results for opposites then follow automatically and do not require taking
advantage of the fact that `(Sᵐᵒᵖ)ᵐᵒᵖ` is defeq to `S`.

## TODO

Develop the theory of two-sided ideals, which have type `submodule (R ⊗[ℕ] Rᵐᵒᵖ) R`.

-/


open TensorProduct

attribute [local instance] TensorProduct.Algebra.module

namespace Subbimodule

section Algebra

variable {R A B M : Type _}

variable [CommSemiring R] [AddCommMonoid M] [Module R M]

variable [Semiring A] [Semiring B] [Module A M] [Module B M]

variable [Algebra R A] [Algebra R B]

variable [IsScalarTower R A M] [IsScalarTower R B M]

variable [SMulCommClass A B M]

/-- A constructor for a subbimodule which demands closure under the two sets of scalars
individually, rather than jointly via their tensor product.

Note that `R` plays no role but it is convenient to make this generalisation to support the cases
`R = ℕ` and `R = ℤ` which both show up naturally. See also `base_change`. -/
@[simps]
def mk (p : AddSubmonoid M) (hA : ∀ (a : A) {m : M}, m ∈ p → a • m ∈ p)
    (hB : ∀ (b : B) {m : M}, m ∈ p → b • m ∈ p) : Submodule (A ⊗[R] B) M :=
  { p with
    carrier := p
    smul_mem' := fun ab m =>
      TensorProduct.induction_on ab (fun hm => by simpa only [zero_smul] using p.zero_mem)
        (fun a b hm => by simpa only [TensorProduct.Algebra.smul_def] using hA a (hB b hm))
        fun z w hz hw hm => by simpa only [add_smul] using p.add_mem (hz hm) (hw hm) }
#align subbimodule.mk Subbimodule.mk

theorem smul_mem (p : Submodule (A ⊗[R] B) M) (a : A) {m : M} (hm : m ∈ p) : a • m ∈ p :=
  by
  suffices a • m = a ⊗ₜ[R] (1 : B) • m by exact this.symm ▸ p.smul_mem _ hm
  simp [TensorProduct.Algebra.smul_def]
#align subbimodule.smul_mem Subbimodule.smul_mem

theorem smul_mem' (p : Submodule (A ⊗[R] B) M) (b : B) {m : M} (hm : m ∈ p) : b • m ∈ p :=
  by
  suffices b • m = (1 : A) ⊗ₜ[R] b • m by exact this.symm ▸ p.smul_mem _ hm
  simp [TensorProduct.Algebra.smul_def]
#align subbimodule.smul_mem' Subbimodule.smul_mem'

/-- If `A` and `B` are also `algebra`s over yet another set of scalars `S` then we may "base change"
from `R` to `S`. -/
@[simps]
def baseChange (S : Type _) [CommSemiring S] [Module S M] [Algebra S A] [Algebra S B]
    [IsScalarTower S A M] [IsScalarTower S B M] (p : Submodule (A ⊗[R] B) M) :
    Submodule (A ⊗[S] B) M :=
  mk p.toAddSubmonoid (smul_mem p) (smul_mem' p)
#align subbimodule.base_change Subbimodule.baseChange

/-- Forgetting the `B` action, a `submodule` over `A ⊗[R] B` is just a `submodule` over `A`. -/
@[simps]
def toSubmodule (p : Submodule (A ⊗[R] B) M) : Submodule A M :=
  { p with
    carrier := p
    smul_mem' := smul_mem p }
#align subbimodule.to_submodule Subbimodule.toSubmodule

/-- Forgetting the `A` action, a `submodule` over `A ⊗[R] B` is just a `submodule` over `B`. -/
@[simps]
def toSubmodule' (p : Submodule (A ⊗[R] B) M) : Submodule B M :=
  { p with
    carrier := p
    smul_mem' := smul_mem' p }
#align subbimodule.to_submodule' Subbimodule.toSubmodule'

end Algebra

section Ring

variable (R S M : Type _) [Ring R] [Ring S]

variable [AddCommGroup M] [Module R M] [Module S M] [SMulCommClass R S M]

/-- A `submodule` over `R ⊗[ℕ] S` is naturally also a `submodule` over the canonically-isomorphic
ring `R ⊗[ℤ] S`. -/
@[simps]
def toSubbimoduleInt (p : Submodule (R ⊗[ℕ] S) M) : Submodule (R ⊗[ℤ] S) M :=
  baseChange ℤ p
#align subbimodule.to_subbimodule_int Subbimodule.toSubbimoduleInt

/-- A `submodule` over `R ⊗[ℤ] S` is naturally also a `submodule` over the canonically-isomorphic
ring `R ⊗[ℕ] S`. -/
@[simps]
def toSubbimoduleNat (p : Submodule (R ⊗[ℤ] S) M) : Submodule (R ⊗[ℕ] S) M :=
  baseChange ℕ p
#align subbimodule.to_subbimodule_nat Subbimodule.toSubbimoduleNat

end Ring

end Subbimodule

