/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Patrick Massot, Eric Wieser

! This file was ported from Lean 3 source module algebra.module.prod
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Basic
import Mathbin.GroupTheory.GroupAction.Prod

/-!
# Prod instances for module and multiplicative actions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines instances for binary product of modules
-/


variable {R : Type _} {S : Type _} {M : Type _} {N : Type _}

namespace Prod

#print Prod.smulWithZero /-
instance smulWithZero [Zero R] [Zero M] [Zero N] [SMulWithZero R M] [SMulWithZero R N] :
    SMulWithZero R (M × N) :=
  { Prod.smul with
    smul_zero := fun r => Prod.ext (smul_zero _) (smul_zero _)
    zero_smul := fun ⟨m, n⟩ => Prod.ext (zero_smul _ _) (zero_smul _ _) }
#align prod.smul_with_zero Prod.smulWithZero
-/

#print Prod.mulActionWithZero /-
instance mulActionWithZero [MonoidWithZero R] [Zero M] [Zero N] [MulActionWithZero R M]
    [MulActionWithZero R N] : MulActionWithZero R (M × N) :=
  { Prod.mulAction with
    smul_zero := fun r => Prod.ext (smul_zero _) (smul_zero _)
    zero_smul := fun ⟨m, n⟩ => Prod.ext (zero_smul _ _) (zero_smul _ _) }
#align prod.mul_action_with_zero Prod.mulActionWithZero
-/

instance {r : Semiring R} [AddCommMonoid M] [AddCommMonoid N] [Module R M] [Module R N] :
    Module R (M × N) :=
  {
    Prod.distribMulAction with
    add_smul := fun a p₁ p₂ => mk.inj_iff.mpr ⟨add_smul _ _ _, add_smul _ _ _⟩
    zero_smul := fun ⟨b, c⟩ => mk.inj_iff.mpr ⟨zero_smul _ _, zero_smul _ _⟩ }

instance {r : Semiring R} [AddCommMonoid M] [AddCommMonoid N] [Module R M] [Module R N]
    [NoZeroSMulDivisors R M] [NoZeroSMulDivisors R N] : NoZeroSMulDivisors R (M × N) :=
  ⟨fun c ⟨x, y⟩ h =>
    or_iff_not_imp_left.mpr fun hc =>
      mk.inj_iff.mpr
        ⟨(smul_eq_zero.mp (congr_arg fst h)).resolve_left hc,
          (smul_eq_zero.mp (congr_arg snd h)).resolve_left hc⟩⟩

end Prod

