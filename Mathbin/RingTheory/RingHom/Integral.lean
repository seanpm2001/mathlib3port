/-
Copyright (c) 2021 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang

! This file was ported from Lean 3 source module ring_theory.ring_hom.integral
! leanprover-community/mathlib commit d07a9c875ed7139abfde6a333b2be205c5bd404e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.RingHomProperties
import Mathbin.RingTheory.IntegralClosure

/-!

# The meta properties of integral ring homomorphisms.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


namespace RingHom

open scoped TensorProduct

open TensorProduct Algebra.TensorProduct

#print RingHom.isIntegral_stableUnderComposition /-
theorem isIntegral_stableUnderComposition : StableUnderComposition fun R S _ _ f => f.is_integral :=
  by introv R hf hg; exact RingHom.isIntegral_trans _ _ hf hg
#align ring_hom.is_integral_stable_under_composition RingHom.isIntegral_stableUnderComposition
-/

#print RingHom.isIntegral_respectsIso /-
theorem isIntegral_respectsIso : RespectsIso fun R S _ _ f => f.is_integral :=
  by
  apply is_integral_stable_under_composition.respects_iso
  introv x
  skip
  rw [← e.apply_symm_apply x]
  apply RingHom.is_integral_map
#align ring_hom.is_integral_respects_iso RingHom.isIntegral_respectsIso
-/

#print RingHom.isIntegral_stableUnderBaseChange /-
theorem isIntegral_stableUnderBaseChange : StableUnderBaseChange fun R S _ _ f => f.is_integral :=
  by
  refine' stable_under_base_change.mk _ is_integral_respects_iso _
  introv h x
  skip
  apply TensorProduct.induction_on x
  · apply isIntegral_zero
  · intro x y; exact IsIntegral.tmul x (h y)
  · intro x y hx hy; exact isIntegral_add _ hx hy
#align ring_hom.is_integral_stable_under_base_change RingHom.isIntegral_stableUnderBaseChange
-/

end RingHom

