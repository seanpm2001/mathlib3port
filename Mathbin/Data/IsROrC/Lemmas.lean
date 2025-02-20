/-
Copyright (c) 2020 Frédéric Dupuis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Frédéric Dupuis

! This file was ported from Lean 3 source module data.is_R_or_C.lemmas
! leanprover-community/mathlib commit 1b0a28e1c93409dbf6d69526863cd9984ef652ce
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.FiniteDimension
import Mathbin.FieldTheory.Tower
import Mathbin.Data.IsROrC.Basic

/-! # Further lemmas about `is_R_or_C` 

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.-/


variable {K E : Type _} [IsROrC K]

namespace Polynomial

open scoped Polynomial

#print Polynomial.ofReal_eval /-
theorem ofReal_eval (p : ℝ[X]) (x : ℝ) : (p.eval x : K) = aeval (↑x) p :=
  (@aeval_algebraMap_apply_eq_algebraMap_eval ℝ K _ _ _ x p).symm
#align polynomial.of_real_eval Polynomial.ofReal_eval
-/

end Polynomial

namespace FiniteDimensional

open scoped Classical

open IsROrC

library_note "is_R_or_C instance"/--
This instance generates a type-class problem with a metavariable `?m` that should satisfy
`is_R_or_C ?m`. Since this can only be satisfied by `ℝ` or `ℂ`, this does not cause problems. -/


#print FiniteDimensional.isROrC_to_real /-
/-- An `is_R_or_C` field is finite-dimensional over `ℝ`, since it is spanned by `{1, I}`. -/
@[nolint dangerous_instance]
instance isROrC_to_real : FiniteDimensional ℝ K :=
  ⟨⟨{1, i}, by
      rw [eq_top_iff]
      intro a _
      rw [Finset.coe_insert, Finset.coe_singleton, Submodule.mem_span_insert]
      refine' ⟨re a, im a • I, _, _⟩
      · rw [Submodule.mem_span_singleton]
        use im a
      simp [re_add_im a, Algebra.smul_def, algebra_map_eq_of_real]⟩⟩
#align finite_dimensional.is_R_or_C_to_real FiniteDimensional.isROrC_to_real
-/

variable (K E) [NormedAddCommGroup E] [NormedSpace K E]

#print FiniteDimensional.proper_isROrC /-
/-- A finite dimensional vector space over an `is_R_or_C` is a proper metric space.

This is not an instance because it would cause a search for `finite_dimensional ?x E` before
`is_R_or_C ?x`. -/
theorem proper_isROrC [FiniteDimensional K E] : ProperSpace E :=
  by
  letI : NormedSpace ℝ E := RestrictScalars.normedSpace ℝ K E
  letI : FiniteDimensional ℝ E := FiniteDimensional.trans ℝ K E
  infer_instance
#align finite_dimensional.proper_is_R_or_C FiniteDimensional.proper_isROrC
-/

variable {E}

#print FiniteDimensional.IsROrC.properSpace_submodule /-
instance IsROrC.properSpace_submodule (S : Submodule K E) [FiniteDimensional K ↥S] :
    ProperSpace S :=
  proper_isROrC K S
#align finite_dimensional.is_R_or_C.proper_space_submodule FiniteDimensional.IsROrC.properSpace_submodule
-/

end FiniteDimensional

namespace IsROrC

#print IsROrC.reClm_norm /-
@[simp, is_R_or_C_simps]
theorem reClm_norm : ‖(reClm : K →L[ℝ] ℝ)‖ = 1 :=
  by
  apply le_antisymm (LinearMap.mkContinuous_norm_le _ zero_le_one _)
  convert ContinuousLinearMap.ratio_le_op_norm _ (1 : K)
  · simp
  · infer_instance
#align is_R_or_C.re_clm_norm IsROrC.reClm_norm
-/

#print IsROrC.conjCle_norm /-
@[simp, is_R_or_C_simps]
theorem conjCle_norm : ‖(@conjCle K _ : K →L[ℝ] K)‖ = 1 :=
  (@conjLie K _).toLinearIsometry.norm_toContinuousLinearMap
#align is_R_or_C.conj_cle_norm IsROrC.conjCle_norm
-/

#print IsROrC.ofRealClm_norm /-
@[simp, is_R_or_C_simps]
theorem ofRealClm_norm : ‖(ofRealClm : ℝ →L[ℝ] K)‖ = 1 :=
  LinearIsometry.norm_toContinuousLinearMap ofRealLi
#align is_R_or_C.of_real_clm_norm IsROrC.ofRealClm_norm
-/

end IsROrC

