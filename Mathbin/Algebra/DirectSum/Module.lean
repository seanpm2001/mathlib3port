/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module algebra.direct_sum.module
! leanprover-community/mathlib commit 932872382355f00112641d305ba0619305dc8642
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.DirectSum.Basic
import Mathbin.LinearAlgebra.Dfinsupp

/-!
# Direct sum of modules

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The first part of the file provides constructors for direct sums of modules. It provides a
construction of the direct sum using the universal property and proves its uniqueness
(`direct_sum.to_module.unique`).

The second part of the file covers the special case of direct sums of submodules of a fixed module
`M`.  There is a canonical linear map from this direct sum to `M` (`direct_sum.coe_linear_map`), and
the construction is of particular importance when this linear map is an equivalence; that is, when
the submodules provide an internal decomposition of `M`.  The property is defined more generally
elsewhere as `direct_sum.is_internal`, but its basic consequences on `submodule`s are established
in this file.

-/


universe u v w u₁

namespace DirectSum

open scoped DirectSum

section General

variable {R : Type u} [Semiring R]

variable {ι : Type v} [dec_ι : DecidableEq ι]

variable {M : ι → Type w} [∀ i, AddCommMonoid (M i)] [∀ i, Module R (M i)]

instance : Module R (⨁ i, M i) :=
  Dfinsupp.module

instance {S : Type _} [Semiring S] [∀ i, Module S (M i)] [∀ i, SMulCommClass R S (M i)] :
    SMulCommClass R S (⨁ i, M i) :=
  Dfinsupp.sMulCommClass

instance {S : Type _} [Semiring S] [SMul R S] [∀ i, Module S (M i)] [∀ i, IsScalarTower R S (M i)] :
    IsScalarTower R S (⨁ i, M i) :=
  Dfinsupp.isScalarTower

instance [∀ i, Module Rᵐᵒᵖ (M i)] [∀ i, IsCentralScalar R (M i)] : IsCentralScalar R (⨁ i, M i) :=
  Dfinsupp.isCentralScalar

#print DirectSum.smul_apply /-
theorem smul_apply (b : R) (v : ⨁ i, M i) (i : ι) : (b • v) i = b • v i :=
  Dfinsupp.smul_apply _ _ _
#align direct_sum.smul_apply DirectSum.smul_apply
-/

variable (R ι M)

#print DirectSum.lmk /-
/-- Create the direct sum given a family `M` of `R` modules indexed over `ι`. -/
def lmk : ∀ s : Finset ι, (∀ i : (↑s : Set ι), M i.val) →ₗ[R] ⨁ i, M i :=
  Dfinsupp.lmk
#align direct_sum.lmk DirectSum.lmk
-/

#print DirectSum.lof /-
/-- Inclusion of each component into the direct sum. -/
def lof : ∀ i : ι, M i →ₗ[R] ⨁ i, M i :=
  Dfinsupp.lsingle
#align direct_sum.lof DirectSum.lof
-/

#print DirectSum.lof_eq_of /-
theorem lof_eq_of (i : ι) (b : M i) : lof R ι M i b = of M i b :=
  rfl
#align direct_sum.lof_eq_of DirectSum.lof_eq_of
-/

variable {ι M}

#print DirectSum.single_eq_lof /-
theorem single_eq_lof (i : ι) (b : M i) : Dfinsupp.single i b = lof R ι M i b :=
  rfl
#align direct_sum.single_eq_lof DirectSum.single_eq_lof
-/

#print DirectSum.mk_smul /-
/-- Scalar multiplication commutes with direct sums. -/
theorem mk_smul (s : Finset ι) (c : R) (x) : mk M s (c • x) = c • mk M s x :=
  (lmk R ι M s).map_smul c x
#align direct_sum.mk_smul DirectSum.mk_smul
-/

#print DirectSum.of_smul /-
/-- Scalar multiplication commutes with the inclusion of each component into the direct sum. -/
theorem of_smul (i : ι) (c : R) (x) : of M i (c • x) = c • of M i x :=
  (lof R ι M i).map_smul c x
#align direct_sum.of_smul DirectSum.of_smul
-/

variable {R}

#print DirectSum.support_smul /-
theorem support_smul [∀ (i : ι) (x : M i), Decidable (x ≠ 0)] (c : R) (v : ⨁ i, M i) :
    (c • v).support ⊆ v.support :=
  Dfinsupp.support_smul _ _
#align direct_sum.support_smul DirectSum.support_smul
-/

variable {N : Type u₁} [AddCommMonoid N] [Module R N]

variable (φ : ∀ i, M i →ₗ[R] N)

variable (R ι N φ)

#print DirectSum.toModule /-
/-- The linear map constructed using the universal property of the coproduct. -/
def toModule : (⨁ i, M i) →ₗ[R] N :=
  Dfinsupp.lsum ℕ φ
#align direct_sum.to_module DirectSum.toModule
-/

#print DirectSum.coe_toModule_eq_coe_toAddMonoid /-
/-- Coproducts in the categories of modules and additive monoids commute with the forgetful functor
from modules to additive monoids. -/
theorem coe_toModule_eq_coe_toAddMonoid :
    (toModule R ι N φ : (⨁ i, M i) → N) = toAddMonoid fun i => (φ i).toAddMonoidHom :=
  rfl
#align direct_sum.coe_to_module_eq_coe_to_add_monoid DirectSum.coe_toModule_eq_coe_toAddMonoid
-/

variable {ι N φ}

#print DirectSum.toModule_lof /-
/-- The map constructed using the universal property gives back the original maps when
restricted to each component. -/
@[simp]
theorem toModule_lof (i) (x : M i) : toModule R ι N φ (lof R ι M i x) = φ i x :=
  toAddMonoid_of (fun i => (φ i).toAddMonoidHom) i x
#align direct_sum.to_module_lof DirectSum.toModule_lof
-/

variable (ψ : (⨁ i, M i) →ₗ[R] N)

#print DirectSum.toModule.unique /-
/-- Every linear map from a direct sum agrees with the one obtained by applying
the universal property to each of its components. -/
theorem toModule.unique (f : ⨁ i, M i) : ψ f = toModule R ι N (fun i => ψ.comp <| lof R ι M i) f :=
  toAddMonoid.unique ψ.toAddMonoidHom f
#align direct_sum.to_module.unique DirectSum.toModule.unique
-/

variable {ψ} {ψ' : (⨁ i, M i) →ₗ[R] N}

#print DirectSum.linearMap_ext /-
/-- Two `linear_map`s out of a direct sum are equal if they agree on the generators.

See note [partially-applied ext lemmas]. -/
@[ext]
theorem linearMap_ext ⦃ψ ψ' : (⨁ i, M i) →ₗ[R] N⦄
    (H : ∀ i, ψ.comp (lof R ι M i) = ψ'.comp (lof R ι M i)) : ψ = ψ' :=
  Dfinsupp.lhom_ext' H
#align direct_sum.linear_map_ext DirectSum.linearMap_ext
-/

#print DirectSum.lsetToSet /-
/-- The inclusion of a subset of the direct summands
into a larger subset of the direct summands, as a linear map.
-/
def lsetToSet (S T : Set ι) (H : S ⊆ T) : (⨁ i : S, M i) →ₗ[R] ⨁ i : T, M i :=
  toModule R _ _ fun i => lof R T (fun i : Subtype T => M i) ⟨i, H i.Prop⟩
#align direct_sum.lset_to_set DirectSum.lsetToSet
-/

variable (ι M)

#print DirectSum.linearEquivFunOnFintype /-
/-- Given `fintype α`, `linear_equiv_fun_on_fintype R` is the natural `R`-linear equivalence
between `⨁ i, M i` and `Π i, M i`. -/
@[simps apply]
def linearEquivFunOnFintype [Fintype ι] : (⨁ i, M i) ≃ₗ[R] ∀ i, M i :=
  { Dfinsupp.equivFunOnFintype with
    toFun := coeFn
    map_add' := fun f g => by ext; simp only [add_apply, Pi.add_apply]
    map_smul' := fun c f => by ext; simp only [Dfinsupp.coe_smul, RingHom.id_apply] }
#align direct_sum.linear_equiv_fun_on_fintype DirectSum.linearEquivFunOnFintype
-/

variable {ι M}

#print DirectSum.linearEquivFunOnFintype_lof /-
@[simp]
theorem linearEquivFunOnFintype_lof [Fintype ι] [DecidableEq ι] (i : ι) (m : M i) :
    (linearEquivFunOnFintype R ι M) (lof R ι M i m) = Pi.single i m :=
  by
  ext a
  change (Dfinsupp.equivFunOnFintype (lof R ι M i m)) a = _
  convert _root_.congr_fun (Dfinsupp.equivFunOnFintype_single i m) a
#align direct_sum.linear_equiv_fun_on_fintype_lof DirectSum.linearEquivFunOnFintype_lof
-/

#print DirectSum.linearEquivFunOnFintype_symm_single /-
@[simp]
theorem linearEquivFunOnFintype_symm_single [Fintype ι] [DecidableEq ι] (i : ι) (m : M i) :
    (linearEquivFunOnFintype R ι M).symm (Pi.single i m) = lof R ι M i m :=
  by
  ext a
  change (dfinsupp.equiv_fun_on_fintype.symm (Pi.single i m)) a = _
  rw [Dfinsupp.equivFunOnFintype_symm_single i m]
  rfl
#align direct_sum.linear_equiv_fun_on_fintype_symm_single DirectSum.linearEquivFunOnFintype_symm_single
-/

#print DirectSum.linearEquivFunOnFintype_symm_coe /-
@[simp]
theorem linearEquivFunOnFintype_symm_coe [Fintype ι] (f : ⨁ i, M i) :
    (linearEquivFunOnFintype R ι M).symm f = f := by ext; simp [linear_equiv_fun_on_fintype]
#align direct_sum.linear_equiv_fun_on_fintype_symm_coe DirectSum.linearEquivFunOnFintype_symm_coe
-/

#print DirectSum.lid /-
/-- The natural linear equivalence between `⨁ _ : ι, M` and `M` when `unique ι`. -/
protected def lid (M : Type v) (ι : Type _ := PUnit) [AddCommMonoid M] [Module R M] [Unique ι] :
    (⨁ _ : ι, M) ≃ₗ[R] M :=
  { DirectSum.id M ι, toModule R ι M fun i => LinearMap.id with }
#align direct_sum.lid DirectSum.lid
-/

variable (ι M)

#print DirectSum.component /-
/-- The projection map onto one component, as a linear map. -/
def component (i : ι) : (⨁ i, M i) →ₗ[R] M i :=
  Dfinsupp.lapply i
#align direct_sum.component DirectSum.component
-/

variable {ι M}

#print DirectSum.apply_eq_component /-
theorem apply_eq_component (f : ⨁ i, M i) (i : ι) : f i = component R ι M i f :=
  rfl
#align direct_sum.apply_eq_component DirectSum.apply_eq_component
-/

#print DirectSum.ext /-
@[ext]
theorem ext {f g : ⨁ i, M i} (h : ∀ i, component R ι M i f = component R ι M i g) : f = g :=
  Dfinsupp.ext h
#align direct_sum.ext DirectSum.ext
-/

#print DirectSum.ext_iff /-
theorem ext_iff {f g : ⨁ i, M i} : f = g ↔ ∀ i, component R ι M i f = component R ι M i g :=
  ⟨fun h _ => by rw [h], ext R⟩
#align direct_sum.ext_iff DirectSum.ext_iff
-/

#print DirectSum.lof_apply /-
@[simp]
theorem lof_apply (i : ι) (b : M i) : ((lof R ι M i) b) i = b :=
  Dfinsupp.single_eq_same
#align direct_sum.lof_apply DirectSum.lof_apply
-/

#print DirectSum.component.lof_self /-
@[simp]
theorem component.lof_self (i : ι) (b : M i) : component R ι M i ((lof R ι M i) b) = b :=
  lof_apply R i b
#align direct_sum.component.lof_self DirectSum.component.lof_self
-/

#print DirectSum.component.of /-
theorem component.of (i j : ι) (b : M j) :
    component R ι M i ((lof R ι M j) b) = if h : j = i then Eq.recOn h b else 0 :=
  Dfinsupp.single_apply
#align direct_sum.component.of DirectSum.component.of
-/

section CongrLeft

variable {κ : Type _}

#print DirectSum.lequivCongrLeft /-
/-- Reindexing terms of a direct sum is linear.-/
def lequivCongrLeft (h : ι ≃ κ) : (⨁ i, M i) ≃ₗ[R] ⨁ k, M (h.symm k) :=
  { equivCongrLeft h with map_smul' := Dfinsupp.comapDomain'_smul _ _ }
#align direct_sum.lequiv_congr_left DirectSum.lequivCongrLeft
-/

#print DirectSum.lequivCongrLeft_apply /-
@[simp]
theorem lequivCongrLeft_apply (h : ι ≃ κ) (f : ⨁ i, M i) (k : κ) :
    lequivCongrLeft R h f k = f (h.symm k) :=
  equivCongrLeft_apply _ _ _
#align direct_sum.lequiv_congr_left_apply DirectSum.lequivCongrLeft_apply
-/

end CongrLeft

section Sigma

variable {α : ι → Type _} {δ : ∀ i, α i → Type w}

variable [∀ i j, AddCommMonoid (δ i j)] [∀ i j, Module R (δ i j)]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print DirectSum.sigmaLcurry /-
/-- `curry` as a linear map.-/
noncomputable def sigmaLcurry : (⨁ i : Σ i, _, δ i.1 i.2) →ₗ[R] ⨁ (i) (j), δ i j :=
  { sigmaCurry with map_smul' := fun r => by convert @Dfinsupp.sigmaCurry_smul _ _ _ δ _ _ _ r }
#align direct_sum.sigma_lcurry DirectSum.sigmaLcurry
-/

#print DirectSum.sigmaLcurry_apply /-
@[simp]
theorem sigmaLcurry_apply (f : ⨁ i : Σ i, _, δ i.1 i.2) (i : ι) (j : α i) :
    sigmaLcurry R f i j = f ⟨i, j⟩ :=
  sigmaCurry_apply f i j
#align direct_sum.sigma_lcurry_apply DirectSum.sigmaLcurry_apply
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print DirectSum.sigmaLuncurry /-
/-- `uncurry` as a linear map.-/
def sigmaLuncurry [∀ i, DecidableEq (α i)] [∀ i j, DecidableEq (δ i j)] :
    (⨁ (i) (j), δ i j) →ₗ[R] ⨁ i : Σ i, _, δ i.1 i.2 :=
  { sigmaUncurry with map_smul' := Dfinsupp.sigmaUncurry_smul }
#align direct_sum.sigma_luncurry DirectSum.sigmaLuncurry
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print DirectSum.sigmaLuncurry_apply /-
@[simp]
theorem sigmaLuncurry_apply [∀ i, DecidableEq (α i)] [∀ i j, DecidableEq (δ i j)]
    (f : ⨁ (i) (j), δ i j) (i : ι) (j : α i) : sigmaLuncurry R f ⟨i, j⟩ = f i j :=
  sigmaUncurry_apply f i j
#align direct_sum.sigma_luncurry_apply DirectSum.sigmaLuncurry_apply
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print DirectSum.sigmaLcurryEquiv /-
/-- `curry_equiv` as a linear equiv.-/
noncomputable def sigmaLcurryEquiv [∀ i, DecidableEq (α i)] [∀ i j, DecidableEq (δ i j)] :
    (⨁ i : Σ i, _, δ i.1 i.2) ≃ₗ[R] ⨁ (i) (j), δ i j :=
  { sigmaCurryEquiv, sigmaLcurry R with }
#align direct_sum.sigma_lcurry_equiv DirectSum.sigmaLcurryEquiv
-/

end Sigma

section Option

variable {α : Option ι → Type w} [∀ i, AddCommMonoid (α i)] [∀ i, Module R (α i)]

#print DirectSum.lequivProdDirectSum /-
/-- Linear isomorphism obtained by separating the term of index `none` of a direct sum over
`option ι`.-/
@[simps]
noncomputable def lequivProdDirectSum : (⨁ i, α i) ≃ₗ[R] α none × ⨁ i, α (some i) :=
  { addEquivProdDirectSum with map_smul' := Dfinsupp.equivProdDfinsupp_smul }
#align direct_sum.lequiv_prod_direct_sum DirectSum.lequivProdDirectSum
-/

end Option

end General

section Submodule

section Semiring

variable {R : Type u} [Semiring R]

variable {ι : Type v} [dec_ι : DecidableEq ι]

variable {M : Type _} [AddCommMonoid M] [Module R M]

variable (A : ι → Submodule R M)

#print DirectSum.coeLinearMap /-
/-- The canonical embedding from `⨁ i, A i` to `M`  where `A` is a collection of `submodule R M`
indexed by `ι`. This is `direct_sum.coe_add_monoid_hom` as a `linear_map`. -/
def coeLinearMap : (⨁ i, A i) →ₗ[R] M :=
  toModule R ι M fun i => (A i).Subtype
#align direct_sum.coe_linear_map DirectSum.coeLinearMap
-/

#print DirectSum.coeLinearMap_of /-
@[simp]
theorem coeLinearMap_of (i : ι) (x : A i) : DirectSum.coeLinearMap A (of (fun i => A i) i x) = x :=
  toAddMonoid_of _ _ _
#align direct_sum.coe_linear_map_of DirectSum.coeLinearMap_of
-/

variable {A}

#print DirectSum.IsInternal.submodule_iSup_eq_top /-
/-- If a direct sum of submodules is internal then the submodules span the module. -/
theorem IsInternal.submodule_iSup_eq_top (h : IsInternal A) : iSup A = ⊤ :=
  by
  rw [Submodule.iSup_eq_range_dfinsupp_lsum, LinearMap.range_eq_top]
  exact Function.Bijective.surjective h
#align direct_sum.is_internal.submodule_supr_eq_top DirectSum.IsInternal.submodule_iSup_eq_top
-/

#print DirectSum.IsInternal.submodule_independent /-
/-- If a direct sum of submodules is internal then the submodules are independent. -/
theorem IsInternal.submodule_independent (h : IsInternal A) : CompleteLattice.Independent A :=
  CompleteLattice.independent_of_dfinsupp_lsum_injective _ h.Injective
#align direct_sum.is_internal.submodule_independent DirectSum.IsInternal.submodule_independent
-/

#print DirectSum.IsInternal.collectedBasis /-
/-- Given an internal direct sum decomposition of a module `M`, and a basis for each of the
components of the direct sum, the disjoint union of these bases is a basis for `M`. -/
noncomputable def IsInternal.collectedBasis (h : IsInternal A) {α : ι → Type _}
    (v : ∀ i, Basis (α i) R (A i)) : Basis (Σ i, α i) R M
    where repr :=
    ((LinearEquiv.ofBijective (DirectSum.coeLinearMap A) h).symm ≪≫ₗ
        Dfinsupp.mapRange.linearEquiv fun i => (v i).repr) ≪≫ₗ
      (sigmaFinsuppLequivDfinsupp R).symm
#align direct_sum.is_internal.collected_basis DirectSum.IsInternal.collectedBasis
-/

#print DirectSum.IsInternal.collectedBasis_coe /-
@[simp]
theorem IsInternal.collectedBasis_coe (h : IsInternal A) {α : ι → Type _}
    (v : ∀ i, Basis (α i) R (A i)) : ⇑(h.collectedBasis v) = fun a : Σ i, α i => ↑(v a.1 a.2) :=
  by
  funext a
  simp only [is_internal.collected_basis, to_module, coe_linear_map, AddEquiv.toFun_eq_coe,
    Basis.coe_ofRepr, Basis.repr_symm_apply, Dfinsupp.lsum_apply_apply,
    Dfinsupp.mapRange.linearEquiv_apply, Dfinsupp.mapRange.linearEquiv_symm,
    Dfinsupp.mapRange_single, Finsupp.total_single, LinearEquiv.ofBijective_apply,
    LinearEquiv.symm_symm, LinearEquiv.symm_trans_apply, one_smul,
    sigmaFinsuppAddEquivDfinsupp_apply, sigmaFinsuppEquivDfinsupp_single,
    sigmaFinsuppLequivDfinsupp_apply]
  convert Dfinsupp.sumAddHom_single (fun i => (A i).Subtype.toAddMonoidHom) a.1 (v a.1 a.2)
#align direct_sum.is_internal.collected_basis_coe DirectSum.IsInternal.collectedBasis_coe
-/

#print DirectSum.IsInternal.collectedBasis_mem /-
theorem IsInternal.collectedBasis_mem (h : IsInternal A) {α : ι → Type _}
    (v : ∀ i, Basis (α i) R (A i)) (a : Σ i, α i) : h.collectedBasis v a ∈ A a.1 := by simp
#align direct_sum.is_internal.collected_basis_mem DirectSum.IsInternal.collectedBasis_mem
-/

#print DirectSum.IsInternal.isCompl /-
/-- When indexed by only two distinct elements, `direct_sum.is_internal` implies
the two submodules are complementary. Over a `ring R`, this is true as an iff, as
`direct_sum.is_internal_iff_is_compl`. -/
theorem IsInternal.isCompl {A : ι → Submodule R M} {i j : ι} (hij : i ≠ j)
    (h : (Set.univ : Set ι) = {i, j}) (hi : IsInternal A) : IsCompl (A i) (A j) :=
  ⟨hi.submodule_independent.PairwiseDisjoint hij,
    codisjoint_iff.mpr <|
      Eq.symm <|
        hi.submodule_iSup_eq_top.symm.trans <| by
          rw [← sSup_pair, iSup, ← Set.image_univ, h, Set.image_insert_eq, Set.image_singleton]⟩
#align direct_sum.is_internal.is_compl DirectSum.IsInternal.isCompl
-/

end Semiring

section Ring

variable {R : Type u} [Ring R]

variable {ι : Type v} [dec_ι : DecidableEq ι]

variable {M : Type _} [AddCommGroup M] [Module R M]

#print DirectSum.isInternal_submodule_of_independent_of_iSup_eq_top /-
/-- Note that this is not generally true for `[semiring R]`; see
`complete_lattice.independent.dfinsupp_lsum_injective` for details. -/
theorem isInternal_submodule_of_independent_of_iSup_eq_top {A : ι → Submodule R M}
    (hi : CompleteLattice.Independent A) (hs : iSup A = ⊤) : IsInternal A :=
  ⟨hi.dfinsupp_lsum_injective,
    LinearMap.range_eq_top.1 <| (Submodule.iSup_eq_range_dfinsupp_lsum _).symm.trans hs⟩
#align direct_sum.is_internal_submodule_of_independent_of_supr_eq_top DirectSum.isInternal_submodule_of_independent_of_iSup_eq_top
-/

#print DirectSum.isInternal_submodule_iff_independent_and_iSup_eq_top /-
/-- `iff` version of `direct_sum.is_internal_submodule_of_independent_of_supr_eq_top`,
`direct_sum.is_internal.independent`, and `direct_sum.is_internal.supr_eq_top`.
-/
theorem isInternal_submodule_iff_independent_and_iSup_eq_top (A : ι → Submodule R M) :
    IsInternal A ↔ CompleteLattice.Independent A ∧ iSup A = ⊤ :=
  ⟨fun i => ⟨i.submodule_independent, i.submodule_iSup_eq_top⟩,
    And.ndrec isInternal_submodule_of_independent_of_iSup_eq_top⟩
#align direct_sum.is_internal_submodule_iff_independent_and_supr_eq_top DirectSum.isInternal_submodule_iff_independent_and_iSup_eq_top
-/

#print DirectSum.isInternal_submodule_iff_isCompl /-
/-- If a collection of submodules has just two indices, `i` and `j`, then
`direct_sum.is_internal` is equivalent to `is_compl`. -/
theorem isInternal_submodule_iff_isCompl (A : ι → Submodule R M) {i j : ι} (hij : i ≠ j)
    (h : (Set.univ : Set ι) = {i, j}) : IsInternal A ↔ IsCompl (A i) (A j) :=
  by
  have : ∀ k, k = i ∨ k = j := fun k => by simpa using set.ext_iff.mp h k
  rw [is_internal_submodule_iff_independent_and_supr_eq_top, iSup, ← Set.image_univ, h,
    Set.image_insert_eq, Set.image_singleton, sSup_pair, CompleteLattice.independent_pair hij this]
  exact ⟨fun ⟨hd, ht⟩ => ⟨hd, codisjoint_iff.mpr ht⟩, fun ⟨hd, ht⟩ => ⟨hd, ht.eq_top⟩⟩
#align direct_sum.is_internal_submodule_iff_is_compl DirectSum.isInternal_submodule_iff_isCompl
-/

/-! Now copy the lemmas for subgroup and submonoids. -/


#print DirectSum.IsInternal.addSubmonoid_independent /-
theorem IsInternal.addSubmonoid_independent {M : Type _} [AddCommMonoid M] {A : ι → AddSubmonoid M}
    (h : IsInternal A) : CompleteLattice.Independent A :=
  CompleteLattice.independent_of_dfinsupp_sumAddHom_injective _ h.Injective
#align direct_sum.is_internal.add_submonoid_independent DirectSum.IsInternal.addSubmonoid_independent
-/

#print DirectSum.IsInternal.addSubgroup_independent /-
theorem IsInternal.addSubgroup_independent {M : Type _} [AddCommGroup M] {A : ι → AddSubgroup M}
    (h : IsInternal A) : CompleteLattice.Independent A :=
  CompleteLattice.independent_of_dfinsupp_sumAddHom_injective' _ h.Injective
#align direct_sum.is_internal.add_subgroup_independent DirectSum.IsInternal.addSubgroup_independent
-/

end Ring

end Submodule

end DirectSum

