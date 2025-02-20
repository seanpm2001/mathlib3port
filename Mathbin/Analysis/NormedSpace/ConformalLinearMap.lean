/-
Copyright (c) 2021 Yourong Zang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yourong Zang

! This file was ported from Lean 3 source module analysis.normed_space.conformal_linear_map
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Basic
import Mathbin.Analysis.NormedSpace.LinearIsometry

/-!
# Conformal Linear Maps

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A continuous linear map between `R`-normed spaces `X` and `Y` `is_conformal_map` if it is
a nonzero multiple of a linear isometry.

## Main definitions

* `is_conformal_map`: the main definition of conformal linear maps

## Main results

* The conformality of the composition of two conformal linear maps, the identity map
  and multiplications by nonzero constants as continuous linear maps
* `is_conformal_map_of_subsingleton`: all continuous linear maps on singleton spaces are conformal
* `is_conformal_map.preserves_angle`: if a continuous linear map is conformal, then it
                                      preserves all angles in the normed space

See `analysis.normed_space.conformal_linear_map.inner_product` for
* `is_conformal_map_iff`: a map between inner product spaces is conformal
  iff it preserves inner products up to a fixed scalar factor.


## Tags

conformal

## Warning

The definition of conformality in this file does NOT require the maps to be orientation-preserving.
-/


noncomputable section

open Function LinearIsometry ContinuousLinearMap

#print IsConformalMap /-
/-- A continuous linear map `f'` is said to be conformal if it's
    a nonzero multiple of a linear isometry. -/
def IsConformalMap {R : Type _} {X Y : Type _} [NormedField R] [SeminormedAddCommGroup X]
    [SeminormedAddCommGroup Y] [NormedSpace R X] [NormedSpace R Y] (f' : X →L[R] Y) :=
  ∃ (c : R) (hc : c ≠ 0) (li : X →ₗᵢ[R] Y), f' = c • li.toContinuousLinearMap
#align is_conformal_map IsConformalMap
-/

variable {R M N G M' : Type _} [NormedField R] [SeminormedAddCommGroup M] [SeminormedAddCommGroup N]
  [SeminormedAddCommGroup G] [NormedSpace R M] [NormedSpace R N] [NormedSpace R G]
  [NormedAddCommGroup M'] [NormedSpace R M'] {f : M →L[R] N} {g : N →L[R] G} {c : R}

#print isConformalMap_id /-
theorem isConformalMap_id : IsConformalMap (id R M) :=
  ⟨1, one_ne_zero, id, by simp⟩
#align is_conformal_map_id isConformalMap_id
-/

#print IsConformalMap.smul /-
theorem IsConformalMap.smul (hf : IsConformalMap f) {c : R} (hc : c ≠ 0) : IsConformalMap (c • f) :=
  by
  rcases hf with ⟨c', hc', li, rfl⟩
  exact ⟨c * c', mul_ne_zero hc hc', li, smul_smul _ _ _⟩
#align is_conformal_map.smul IsConformalMap.smul
-/

#print isConformalMap_const_smul /-
theorem isConformalMap_const_smul (hc : c ≠ 0) : IsConformalMap (c • id R M) :=
  isConformalMap_id.smul hc
#align is_conformal_map_const_smul isConformalMap_const_smul
-/

#print LinearIsometry.isConformalMap /-
protected theorem LinearIsometry.isConformalMap (f' : M →ₗᵢ[R] N) :
    IsConformalMap f'.toContinuousLinearMap :=
  ⟨1, one_ne_zero, f', (one_smul _ _).symm⟩
#align linear_isometry.is_conformal_map LinearIsometry.isConformalMap
-/

#print isConformalMap_of_subsingleton /-
@[nontriviality]
theorem isConformalMap_of_subsingleton [Subsingleton M] (f' : M →L[R] N) : IsConformalMap f' :=
  ⟨1, one_ne_zero, ⟨0, fun x => by simp [Subsingleton.elim x 0]⟩, Subsingleton.elim _ _⟩
#align is_conformal_map_of_subsingleton isConformalMap_of_subsingleton
-/

namespace IsConformalMap

#print IsConformalMap.comp /-
theorem comp (hg : IsConformalMap g) (hf : IsConformalMap f) : IsConformalMap (g.comp f) :=
  by
  rcases hf with ⟨cf, hcf, lif, rfl⟩
  rcases hg with ⟨cg, hcg, lig, rfl⟩
  refine' ⟨cg * cf, mul_ne_zero hcg hcf, lig.comp lif, _⟩
  rw [smul_comp, comp_smul, mul_smul]
  rfl
#align is_conformal_map.comp IsConformalMap.comp
-/

#print IsConformalMap.injective /-
protected theorem injective {f : M' →L[R] N} (h : IsConformalMap f) : Function.Injective f := by
  rcases h with ⟨c, hc, li, rfl⟩; exact (smul_right_injective _ hc).comp li.injective
#align is_conformal_map.injective IsConformalMap.injective
-/

#print IsConformalMap.ne_zero /-
theorem ne_zero [Nontrivial M'] {f' : M' →L[R] N} (hf' : IsConformalMap f') : f' ≠ 0 :=
  by
  rintro rfl
  rcases exists_ne (0 : M') with ⟨a, ha⟩
  exact ha (hf'.injective rfl)
#align is_conformal_map.ne_zero IsConformalMap.ne_zero
-/

end IsConformalMap

