/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module linear_algebra.finsupp_vector_space
! leanprover-community/mathlib commit 19cb3751e5e9b3d97adb51023949c50c13b5fdfd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.StdBasis

/-!
# Linear structures on function with finite support `ι →₀ M`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains results on the `R`-module structure on functions of finite support from a type
`ι` to an `R`-module `M`, in particular in the case that `R` is a field.

-/


noncomputable section

attribute [local instance 100] Classical.propDecidable

open Set LinearMap Submodule

open scoped Cardinal

universe u v w

namespace Finsupp

section Ring

variable {R : Type _} {M : Type _} {ι : Type _}

variable [Ring R] [AddCommGroup M] [Module R M]

#print Finsupp.linearIndependent_single /-
theorem linearIndependent_single {φ : ι → Type _} {f : ∀ ι, φ ι → M}
    (hf : ∀ i, LinearIndependent R (f i)) :
    LinearIndependent R fun ix : Σ i, φ i => single ix.1 (f ix.1 ix.2) :=
  by
  apply @linearIndependent_iUnion_finite R _ _ _ _ ι φ fun i x => single i (f i x)
  · intro i
    have h_disjoint : Disjoint (span R (range (f i))) (ker (lsingle i)) :=
      by
      rw [ker_lsingle]
      exact disjoint_bot_right
    apply (hf i).map h_disjoint
  · intro i t ht hit
    refine' (disjoint_lsingle_lsingle {i} t (disjoint_singleton_left.2 hit)).mono _ _
    · rw [span_le]
      simp only [iSup_singleton]
      rw [range_coe]
      apply range_comp_subset_range
    · refine' iSup₂_mono fun i hi => _
      rw [span_le, range_coe]
      apply range_comp_subset_range
#align finsupp.linear_independent_single Finsupp.linearIndependent_single
-/

end Ring

section Semiring

variable {R : Type _} {M : Type _} {ι : Type _}

variable [Semiring R] [AddCommMonoid M] [Module R M]

open LinearMap Submodule

#print Finsupp.basis /-
/-- The basis on `ι →₀ M` with basis vectors `λ ⟨i, x⟩, single i (b i x)`. -/
protected def basis {φ : ι → Type _} (b : ∀ i, Basis (φ i) R M) : Basis (Σ i, φ i) R (ι →₀ M) :=
  Basis.ofRepr
    { toFun := fun g =>
        { toFun := fun ix => (b ix.1).repr (g ix.1) ix.2
          support := g.support.Sigma fun i => ((b i).repr (g i)).support
          mem_support_toFun := fun ix =>
            by
            simp only [Finset.mem_sigma, mem_support_iff, and_iff_right_iff_imp, Ne.def]
            intro b hg
            simpa [hg] using b }
      invFun := fun g =>
        { toFun := fun i =>
            (b i).repr.symm (g.comapDomain _ (Set.injOn_of_injective sigma_mk_injective _))
          support := g.support.image Sigma.fst
          mem_support_toFun := fun i =>
            by
            rw [Ne.def, ← (b i).repr.Injective.eq_iff, (b i).repr.apply_symm_apply, ext_iff]
            simp only [exists_prop, LinearEquiv.map_zero, comap_domain_apply, zero_apply,
              exists_and_right, mem_support_iff, exists_eq_right, Sigma.exists, Finset.mem_image,
              not_forall] }
      left_inv := fun g => by
        ext i; rw [← (b i).repr.Injective.eq_iff]; ext x
        simp only [coe_mk, LinearEquiv.apply_symm_apply, comap_domain_apply]
      right_inv := fun g => by
        ext ⟨i, x⟩
        simp only [coe_mk, LinearEquiv.apply_symm_apply, comap_domain_apply]
      map_add' := fun g h => by ext ⟨i, x⟩; simp only [coe_mk, add_apply, LinearEquiv.map_add]
      map_smul' := fun c h => by ext ⟨i, x⟩;
        simp only [coe_mk, smul_apply, LinearEquiv.map_smul, RingHom.id_apply] }
#align finsupp.basis Finsupp.basis
-/

#print Finsupp.basis_repr /-
@[simp]
theorem basis_repr {φ : ι → Type _} (b : ∀ i, Basis (φ i) R M) (g : ι →₀ M) (ix) :
    (Finsupp.basis b).repr g ix = (b ix.1).repr (g ix.1) ix.2 :=
  rfl
#align finsupp.basis_repr Finsupp.basis_repr
-/

#print Finsupp.coe_basis /-
@[simp]
theorem coe_basis {φ : ι → Type _} (b : ∀ i, Basis (φ i) R M) :
    ⇑(Finsupp.basis b) = fun ix : Σ i, φ i => single ix.1 (b ix.1 ix.2) :=
  funext fun ⟨i, x⟩ =>
    Basis.apply_eq_iff.mpr <| by
      ext ⟨j, y⟩
      by_cases h : i = j
      · cases h
        simp only [basis_repr, single_eq_same, Basis.repr_self,
          Finsupp.single_apply_left sigma_mk_injective]
      simp only [basis_repr, single_apply, h, false_and_iff, if_false, LinearEquiv.map_zero,
        zero_apply]
#align finsupp.coe_basis Finsupp.coe_basis
-/

#print Finsupp.basisSingleOne /-
/-- The basis on `ι →₀ M` with basis vectors `λ i, single i 1`. -/
@[simps]
protected def basisSingleOne : Basis ι R (ι →₀ R) :=
  Basis.ofRepr (LinearEquiv.refl _ _)
#align finsupp.basis_single_one Finsupp.basisSingleOne
-/

#print Finsupp.coe_basisSingleOne /-
@[simp]
theorem coe_basisSingleOne : (Finsupp.basisSingleOne : ι → ι →₀ R) = fun i => Finsupp.single i 1 :=
  funext fun i => Basis.apply_eq_iff.mpr rfl
#align finsupp.coe_basis_single_one Finsupp.coe_basisSingleOne
-/

end Semiring

end Finsupp

/-! TODO: move this section to an earlier file. -/


namespace Basis

variable {R M n : Type _}

variable [DecidableEq n] [Fintype n]

variable [Semiring R] [AddCommMonoid M] [Module R M]

#print Finset.sum_single_ite /-
theorem Finset.sum_single_ite (a : R) (i : n) :
    (Finset.univ.Sum fun x : n => Finsupp.single x (ite (i = x) a 0)) = Finsupp.single i a :=
  by
  rw [Finset.sum_congr_set {i} (fun x : n => Finsupp.single x (ite (i = x) a 0)) fun _ =>
      Finsupp.single i a]
  · simp
  · intro x hx
    rw [Set.mem_singleton_iff] at hx 
    simp [hx]
  intro x hx
  have hx' : ¬i = x := by
    refine' ne_comm.mp _
    rwa [mem_singleton_iff] at hx 
  simp [hx']
#align finset.sum_single_ite Finset.sum_single_ite
-/

#print Basis.equivFun_symm_stdBasis /-
@[simp]
theorem equivFun_symm_stdBasis (b : Basis n R M) (i : n) :
    b.equivFun.symm (LinearMap.stdBasis R (fun _ => R) i 1) = b i :=
  by
  have := EquivLike.injective b.repr
  apply_fun b.repr
  simp only [equiv_fun_symm_apply, std_basis_apply', LinearEquiv.map_sum, LinearEquiv.map_smulₛₗ,
    RingHom.id_apply, repr_self, Finsupp.smul_single', boole_mul]
  exact Finset.sum_single_ite 1 i
#align basis.equiv_fun_symm_std_basis Basis.equivFun_symm_stdBasis
-/

end Basis

