/-
Copyright (c) 2020 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth, Yury Kudryashov, Frédéric Dupuis

! This file was ported from Lean 3 source module topology.algebra.infinite_sum.module
! leanprover-community/mathlib commit 75be6b616681ab6ca66d798ead117e75cd64f125
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.InfiniteSum.Basic
import Mathbin.Topology.Algebra.Module.Basic

/-! # Infinite sums in topological vector spaces 

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.-/


variable {ι R R₂ M M₂ : Type _}

section SmulConst

variable [Semiring R] [TopologicalSpace R] [TopologicalSpace M] [AddCommMonoid M] [Module R M]
  [ContinuousSMul R M] {f : ι → R}

#print HasSum.smul_const /-
theorem HasSum.smul_const {r : R} (hf : HasSum f r) (a : M) : HasSum (fun z => f z • a) (r • a) :=
  hf.map ((smulAddHom R M).flip a) (continuous_id.smul continuous_const)
#align has_sum.smul_const HasSum.smul_const
-/

#print Summable.smul_const /-
theorem Summable.smul_const (hf : Summable f) (a : M) : Summable fun z => f z • a :=
  (hf.HasSum.smul_const _).Summable
#align summable.smul_const Summable.smul_const
-/

#print tsum_smul_const /-
theorem tsum_smul_const [T2Space M] (hf : Summable f) (a : M) : ∑' z, f z • a = (∑' z, f z) • a :=
  (hf.HasSum.smul_const _).tsum_eq
#align tsum_smul_const tsum_smul_const
-/

end SmulConst

section HasSum

-- Results in this section hold for continuous additive monoid homomorphisms or equivalences but we
-- don't have bundled continuous additive homomorphisms.
variable [Semiring R] [Semiring R₂] [AddCommMonoid M] [Module R M] [AddCommMonoid M₂] [Module R₂ M₂]
  [TopologicalSpace M] [TopologicalSpace M₂] {σ : R →+* R₂} {σ' : R₂ →+* R} [RingHomInvPair σ σ']
  [RingHomInvPair σ' σ]

#print ContinuousLinearMap.hasSum /-
/-- Applying a continuous linear map commutes with taking an (infinite) sum. -/
protected theorem ContinuousLinearMap.hasSum {f : ι → M} (φ : M →SL[σ] M₂) {x : M}
    (hf : HasSum f x) : HasSum (fun b : ι => φ (f b)) (φ x) := by
  simpa only using hf.map φ.to_linear_map.to_add_monoid_hom φ.continuous
#align continuous_linear_map.has_sum ContinuousLinearMap.hasSum
-/

alias ContinuousLinearMap.hasSum ← HasSum.mapL
#align has_sum.mapL HasSum.mapL

#print ContinuousLinearMap.summable /-
protected theorem ContinuousLinearMap.summable {f : ι → M} (φ : M →SL[σ] M₂) (hf : Summable f) :
    Summable fun b : ι => φ (f b) :=
  (hf.HasSum.mapL φ).Summable
#align continuous_linear_map.summable ContinuousLinearMap.summable
-/

alias ContinuousLinearMap.summable ← Summable.mapL
#align summable.mapL Summable.mapL

#print ContinuousLinearMap.map_tsum /-
protected theorem ContinuousLinearMap.map_tsum [T2Space M₂] {f : ι → M} (φ : M →SL[σ] M₂)
    (hf : Summable f) : φ (∑' z, f z) = ∑' z, φ (f z) :=
  (hf.HasSum.mapL φ).tsum_eq.symm
#align continuous_linear_map.map_tsum ContinuousLinearMap.map_tsum
-/

#print ContinuousLinearEquiv.hasSum /-
/-- Applying a continuous linear map commutes with taking an (infinite) sum. -/
protected theorem ContinuousLinearEquiv.hasSum {f : ι → M} (e : M ≃SL[σ] M₂) {y : M₂} :
    HasSum (fun b : ι => e (f b)) y ↔ HasSum f (e.symm y) :=
  ⟨fun h => by simpa only [e.symm.coe_coe, e.symm_apply_apply] using h.mapL (e.symm : M₂ →SL[σ'] M),
    fun h => by simpa only [e.coe_coe, e.apply_symm_apply] using (e : M →SL[σ] M₂).HasSum h⟩
#align continuous_linear_equiv.has_sum ContinuousLinearEquiv.hasSum
-/

#print ContinuousLinearEquiv.hasSum' /-
/-- Applying a continuous linear map commutes with taking an (infinite) sum. -/
protected theorem ContinuousLinearEquiv.hasSum' {f : ι → M} (e : M ≃SL[σ] M₂) {x : M} :
    HasSum (fun b : ι => e (f b)) (e x) ↔ HasSum f x := by
  rw [e.has_sum, ContinuousLinearEquiv.symm_apply_apply]
#align continuous_linear_equiv.has_sum' ContinuousLinearEquiv.hasSum'
-/

#print ContinuousLinearEquiv.summable /-
protected theorem ContinuousLinearEquiv.summable {f : ι → M} (e : M ≃SL[σ] M₂) :
    (Summable fun b : ι => e (f b)) ↔ Summable f :=
  ⟨fun hf => (e.HasSum.1 hf.HasSum).Summable, (e : M →SL[σ] M₂).Summable⟩
#align continuous_linear_equiv.summable ContinuousLinearEquiv.summable
-/

#print ContinuousLinearEquiv.tsum_eq_iff /-
theorem ContinuousLinearEquiv.tsum_eq_iff [T2Space M] [T2Space M₂] {f : ι → M} (e : M ≃SL[σ] M₂)
    {y : M₂} : ∑' z, e (f z) = y ↔ ∑' z, f z = e.symm y :=
  by
  by_cases hf : Summable f
  ·
    exact
      ⟨fun h => (e.has_sum.mp ((e.summable.mpr hf).hasSum_iff.mpr h)).tsum_eq, fun h =>
        (e.has_sum.mpr (hf.has_sum_iff.mpr h)).tsum_eq⟩
  · have hf' : ¬Summable fun z => e (f z) := fun h => hf (e.summable.mp h)
    rw [tsum_eq_zero_of_not_summable hf, tsum_eq_zero_of_not_summable hf']
    exact ⟨by rintro rfl; simp, fun H => by simpa using congr_arg (fun z => e z) H⟩
#align continuous_linear_equiv.tsum_eq_iff ContinuousLinearEquiv.tsum_eq_iff
-/

#print ContinuousLinearEquiv.map_tsum /-
protected theorem ContinuousLinearEquiv.map_tsum [T2Space M] [T2Space M₂] {f : ι → M}
    (e : M ≃SL[σ] M₂) : e (∑' z, f z) = ∑' z, e (f z) := by refine' symm (e.tsum_eq_iff.mpr _);
  rw [e.symm_apply_apply _]
#align continuous_linear_equiv.map_tsum ContinuousLinearEquiv.map_tsum
-/

end HasSum

