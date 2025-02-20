/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module linear_algebra.projection
! leanprover-community/mathlib commit 3dadefa3f544b1db6214777fe47910739b54c66a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Quotient
import Mathbin.LinearAlgebra.Prod

/-!
# Projection to a subspace

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define
* `linear_proj_of_is_compl (p q : submodule R E) (h : is_compl p q)`: the projection of a module `E`
  to a submodule `p` along its complement `q`; it is the unique linear map `f : E → p` such that
  `f x = x` for `x ∈ p` and `f x = 0` for `x ∈ q`.
* `is_compl_equiv_proj p`: equivalence between submodules `q` such that `is_compl p q` and
  projections `f : E → p`, `∀ x ∈ p, f x = x`.

We also provide some lemmas justifying correctness of our definitions.

## Tags

projection, complement subspace
-/


section Ring

variable {R : Type _} [Ring R] {E : Type _} [AddCommGroup E] [Module R E] {F : Type _}
  [AddCommGroup F] [Module R F] {G : Type _} [AddCommGroup G] [Module R G] (p q : Submodule R E)

variable {S : Type _} [Semiring S] {M : Type _} [AddCommMonoid M] [Module S M] (m : Submodule S M)

noncomputable section

namespace LinearMap

variable {p}

open Submodule

#print LinearMap.ker_id_sub_eq_of_proj /-
theorem ker_id_sub_eq_of_proj {f : E →ₗ[R] p} (hf : ∀ x : p, f x = x) :
    ker (id - p.Subtype.comp f) = p := by
  ext x
  simp only [comp_apply, mem_ker, subtype_apply, sub_apply, id_apply, sub_eq_zero]
  exact ⟨fun h => h.symm ▸ Submodule.coe_mem _, fun hx => by erw [hf ⟨x, hx⟩, Subtype.coe_mk]⟩
#align linear_map.ker_id_sub_eq_of_proj LinearMap.ker_id_sub_eq_of_proj
-/

#print LinearMap.range_eq_of_proj /-
theorem range_eq_of_proj {f : E →ₗ[R] p} (hf : ∀ x : p, f x = x) : range f = ⊤ :=
  range_eq_top.2 fun x => ⟨x, hf x⟩
#align linear_map.range_eq_of_proj LinearMap.range_eq_of_proj
-/

#print LinearMap.isCompl_of_proj /-
theorem isCompl_of_proj {f : E →ₗ[R] p} (hf : ∀ x : p, f x = x) : IsCompl p f.ker :=
  by
  constructor
  · rw [disjoint_iff_inf_le]
    rintro x ⟨hpx, hfx⟩
    erw [SetLike.mem_coe, mem_ker, hf ⟨x, hpx⟩, mk_eq_zero] at hfx 
    simp only [hfx, SetLike.mem_coe, zero_mem]
  · rw [codisjoint_iff_le_sup]
    intro x hx
    rw [mem_sup']
    refine' ⟨f x, ⟨x - f x, _⟩, add_sub_cancel'_right _ _⟩
    rw [mem_ker, LinearMap.map_sub, hf, sub_self]
#align linear_map.is_compl_of_proj LinearMap.isCompl_of_proj
-/

end LinearMap

namespace Submodule

open LinearMap

#print Submodule.quotientEquivOfIsCompl /-
/-- If `q` is a complement of `p`, then `M/p ≃ q`. -/
def quotientEquivOfIsCompl (h : IsCompl p q) : (E ⧸ p) ≃ₗ[R] q :=
  LinearEquiv.symm <|
    LinearEquiv.ofBijective (p.mkQ.comp q.Subtype)
      ⟨by rw [← ker_eq_bot, ker_comp, ker_mkq, disjoint_iff_comap_eq_bot.1 h.symm.disjoint], by
        rw [← range_eq_top, range_comp, range_subtype, map_mkq_eq_top, h.sup_eq_top]⟩
#align submodule.quotient_equiv_of_is_compl Submodule.quotientEquivOfIsCompl
-/

#print Submodule.quotientEquivOfIsCompl_symm_apply /-
@[simp]
theorem quotientEquivOfIsCompl_symm_apply (h : IsCompl p q) (x : q) :
    (quotientEquivOfIsCompl p q h).symm x = Quotient.mk x :=
  rfl
#align submodule.quotient_equiv_of_is_compl_symm_apply Submodule.quotientEquivOfIsCompl_symm_apply
-/

#print Submodule.quotientEquivOfIsCompl_apply_mk_coe /-
@[simp]
theorem quotientEquivOfIsCompl_apply_mk_coe (h : IsCompl p q) (x : q) :
    quotientEquivOfIsCompl p q h (Quotient.mk x) = x :=
  (quotientEquivOfIsCompl p q h).apply_symm_apply x
#align submodule.quotient_equiv_of_is_compl_apply_mk_coe Submodule.quotientEquivOfIsCompl_apply_mk_coe
-/

#print Submodule.mk_quotientEquivOfIsCompl_apply /-
@[simp]
theorem mk_quotientEquivOfIsCompl_apply (h : IsCompl p q) (x : E ⧸ p) :
    (Quotient.mk (quotientEquivOfIsCompl p q h x) : E ⧸ p) = x :=
  (quotientEquivOfIsCompl p q h).symm_apply_apply x
#align submodule.mk_quotient_equiv_of_is_compl_apply Submodule.mk_quotientEquivOfIsCompl_apply
-/

#print Submodule.prodEquivOfIsCompl /-
/-- If `q` is a complement of `p`, then `p × q` is isomorphic to `E`. It is the unique
linear map `f : E → p` such that `f x = x` for `x ∈ p` and `f x = 0` for `x ∈ q`. -/
def prodEquivOfIsCompl (h : IsCompl p q) : (p × q) ≃ₗ[R] E :=
  by
  apply LinearEquiv.ofBijective (p.subtype.coprod q.subtype)
  constructor
  · rw [← ker_eq_bot, ker_coprod_of_disjoint_range, ker_subtype, ker_subtype, prod_bot]
    rw [range_subtype, range_subtype]
    exact h.1
  · rw [← range_eq_top, ← sup_eq_range, h.sup_eq_top]
#align submodule.prod_equiv_of_is_compl Submodule.prodEquivOfIsCompl
-/

#print Submodule.coe_prodEquivOfIsCompl /-
@[simp]
theorem coe_prodEquivOfIsCompl (h : IsCompl p q) :
    (prodEquivOfIsCompl p q h : p × q →ₗ[R] E) = p.Subtype.coprod q.Subtype :=
  rfl
#align submodule.coe_prod_equiv_of_is_compl Submodule.coe_prodEquivOfIsCompl
-/

#print Submodule.coe_prodEquivOfIsCompl' /-
@[simp]
theorem coe_prodEquivOfIsCompl' (h : IsCompl p q) (x : p × q) :
    prodEquivOfIsCompl p q h x = x.1 + x.2 :=
  rfl
#align submodule.coe_prod_equiv_of_is_compl' Submodule.coe_prodEquivOfIsCompl'
-/

#print Submodule.prodEquivOfIsCompl_symm_apply_left /-
@[simp]
theorem prodEquivOfIsCompl_symm_apply_left (h : IsCompl p q) (x : p) :
    (prodEquivOfIsCompl p q h).symm x = (x, 0) :=
  (prodEquivOfIsCompl p q h).symm_apply_eq.2 <| by simp
#align submodule.prod_equiv_of_is_compl_symm_apply_left Submodule.prodEquivOfIsCompl_symm_apply_left
-/

#print Submodule.prodEquivOfIsCompl_symm_apply_right /-
@[simp]
theorem prodEquivOfIsCompl_symm_apply_right (h : IsCompl p q) (x : q) :
    (prodEquivOfIsCompl p q h).symm x = (0, x) :=
  (prodEquivOfIsCompl p q h).symm_apply_eq.2 <| by simp
#align submodule.prod_equiv_of_is_compl_symm_apply_right Submodule.prodEquivOfIsCompl_symm_apply_right
-/

#print Submodule.prodEquivOfIsCompl_symm_apply_fst_eq_zero /-
@[simp]
theorem prodEquivOfIsCompl_symm_apply_fst_eq_zero (h : IsCompl p q) {x : E} :
    ((prodEquivOfIsCompl p q h).symm x).1 = 0 ↔ x ∈ q :=
  by
  conv_rhs => rw [← (prod_equiv_of_is_compl p q h).apply_symm_apply x]
  rw [coe_prod_equiv_of_is_compl', Submodule.add_mem_iff_left _ (Submodule.coe_mem _),
    mem_right_iff_eq_zero_of_disjoint h.disjoint]
#align submodule.prod_equiv_of_is_compl_symm_apply_fst_eq_zero Submodule.prodEquivOfIsCompl_symm_apply_fst_eq_zero
-/

#print Submodule.prodEquivOfIsCompl_symm_apply_snd_eq_zero /-
@[simp]
theorem prodEquivOfIsCompl_symm_apply_snd_eq_zero (h : IsCompl p q) {x : E} :
    ((prodEquivOfIsCompl p q h).symm x).2 = 0 ↔ x ∈ p :=
  by
  conv_rhs => rw [← (prod_equiv_of_is_compl p q h).apply_symm_apply x]
  rw [coe_prod_equiv_of_is_compl', Submodule.add_mem_iff_right _ (Submodule.coe_mem _),
    mem_left_iff_eq_zero_of_disjoint h.disjoint]
#align submodule.prod_equiv_of_is_compl_symm_apply_snd_eq_zero Submodule.prodEquivOfIsCompl_symm_apply_snd_eq_zero
-/

#print Submodule.prodComm_trans_prodEquivOfIsCompl /-
@[simp]
theorem prodComm_trans_prodEquivOfIsCompl (h : IsCompl p q) :
    LinearEquiv.prodComm R q p ≪≫ₗ prodEquivOfIsCompl p q h = prodEquivOfIsCompl q p h.symm :=
  LinearEquiv.ext fun _ => add_comm _ _
#align submodule.prod_comm_trans_prod_equiv_of_is_compl Submodule.prodComm_trans_prodEquivOfIsCompl
-/

#print Submodule.linearProjOfIsCompl /-
/-- Projection to a submodule along its complement. -/
def linearProjOfIsCompl (h : IsCompl p q) : E →ₗ[R] p :=
  LinearMap.fst R p q ∘ₗ ↑(prodEquivOfIsCompl p q h).symm
#align submodule.linear_proj_of_is_compl Submodule.linearProjOfIsCompl
-/

variable {p q}

#print Submodule.linearProjOfIsCompl_apply_left /-
@[simp]
theorem linearProjOfIsCompl_apply_left (h : IsCompl p q) (x : p) :
    linearProjOfIsCompl p q h x = x := by simp [linear_proj_of_is_compl]
#align submodule.linear_proj_of_is_compl_apply_left Submodule.linearProjOfIsCompl_apply_left
-/

#print Submodule.linearProjOfIsCompl_range /-
@[simp]
theorem linearProjOfIsCompl_range (h : IsCompl p q) : (linearProjOfIsCompl p q h).range = ⊤ :=
  range_eq_of_proj (linearProjOfIsCompl_apply_left h)
#align submodule.linear_proj_of_is_compl_range Submodule.linearProjOfIsCompl_range
-/

#print Submodule.linearProjOfIsCompl_apply_eq_zero_iff /-
@[simp]
theorem linearProjOfIsCompl_apply_eq_zero_iff (h : IsCompl p q) {x : E} :
    linearProjOfIsCompl p q h x = 0 ↔ x ∈ q := by simp [linear_proj_of_is_compl]
#align submodule.linear_proj_of_is_compl_apply_eq_zero_iff Submodule.linearProjOfIsCompl_apply_eq_zero_iff
-/

#print Submodule.linearProjOfIsCompl_apply_right' /-
theorem linearProjOfIsCompl_apply_right' (h : IsCompl p q) (x : E) (hx : x ∈ q) :
    linearProjOfIsCompl p q h x = 0 :=
  (linearProjOfIsCompl_apply_eq_zero_iff h).2 hx
#align submodule.linear_proj_of_is_compl_apply_right' Submodule.linearProjOfIsCompl_apply_right'
-/

#print Submodule.linearProjOfIsCompl_apply_right /-
@[simp]
theorem linearProjOfIsCompl_apply_right (h : IsCompl p q) (x : q) :
    linearProjOfIsCompl p q h x = 0 :=
  linearProjOfIsCompl_apply_right' h x x.2
#align submodule.linear_proj_of_is_compl_apply_right Submodule.linearProjOfIsCompl_apply_right
-/

#print Submodule.linearProjOfIsCompl_ker /-
@[simp]
theorem linearProjOfIsCompl_ker (h : IsCompl p q) : (linearProjOfIsCompl p q h).ker = q :=
  ext fun x => mem_ker.trans (linearProjOfIsCompl_apply_eq_zero_iff h)
#align submodule.linear_proj_of_is_compl_ker Submodule.linearProjOfIsCompl_ker
-/

#print Submodule.linearProjOfIsCompl_comp_subtype /-
theorem linearProjOfIsCompl_comp_subtype (h : IsCompl p q) :
    (linearProjOfIsCompl p q h).comp p.Subtype = id :=
  LinearMap.ext <| linearProjOfIsCompl_apply_left h
#align submodule.linear_proj_of_is_compl_comp_subtype Submodule.linearProjOfIsCompl_comp_subtype
-/

#print Submodule.linearProjOfIsCompl_idempotent /-
theorem linearProjOfIsCompl_idempotent (h : IsCompl p q) (x : E) :
    linearProjOfIsCompl p q h (linearProjOfIsCompl p q h x) = linearProjOfIsCompl p q h x :=
  linearProjOfIsCompl_apply_left h _
#align submodule.linear_proj_of_is_compl_idempotent Submodule.linearProjOfIsCompl_idempotent
-/

#print Submodule.existsUnique_add_of_isCompl_prod /-
theorem existsUnique_add_of_isCompl_prod (hc : IsCompl p q) (x : E) :
    ∃! u : p × q, (u.fst : E) + u.snd = x :=
  (prodEquivOfIsCompl _ _ hc).toEquiv.Bijective.ExistsUnique _
#align submodule.exists_unique_add_of_is_compl_prod Submodule.existsUnique_add_of_isCompl_prod
-/

#print Submodule.existsUnique_add_of_isCompl /-
theorem existsUnique_add_of_isCompl (hc : IsCompl p q) (x : E) :
    ∃ (u : p) (v : q), (u : E) + v = x ∧ ∀ (r : p) (s : q), (r : E) + s = x → r = u ∧ s = v :=
  let ⟨u, hu₁, hu₂⟩ := existsUnique_add_of_isCompl_prod hc x
  ⟨u.1, u.2, hu₁, fun r s hrs => Prod.eq_iff_fst_eq_snd_eq.1 (hu₂ ⟨r, s⟩ hrs)⟩
#align submodule.exists_unique_add_of_is_compl Submodule.existsUnique_add_of_isCompl
-/

#print Submodule.linear_proj_add_linearProjOfIsCompl_eq_self /-
theorem linear_proj_add_linearProjOfIsCompl_eq_self (hpq : IsCompl p q) (x : E) :
    (p.linearProjOfIsCompl q hpq x + q.linearProjOfIsCompl p hpq.symm x : E) = x :=
  by
  dsimp only [linear_proj_of_is_compl]
  rw [← prod_comm_trans_prod_equiv_of_is_compl _ _ hpq]
  exact (prod_equiv_of_is_compl _ _ hpq).apply_symm_apply x
#align submodule.linear_proj_add_linear_proj_of_is_compl_eq_self Submodule.linear_proj_add_linearProjOfIsCompl_eq_self
-/

end Submodule

namespace LinearMap

open Submodule

#print LinearMap.ofIsCompl /-
/-- Given linear maps `φ` and `ψ` from complement submodules, `of_is_compl` is
the induced linear map over the entire module. -/
def ofIsCompl {p q : Submodule R E} (h : IsCompl p q) (φ : p →ₗ[R] F) (ψ : q →ₗ[R] F) : E →ₗ[R] F :=
  LinearMap.coprod φ ψ ∘ₗ ↑(Submodule.prodEquivOfIsCompl _ _ h).symm
#align linear_map.of_is_compl LinearMap.ofIsCompl
-/

variable {p q}

#print LinearMap.ofIsCompl_left_apply /-
@[simp]
theorem ofIsCompl_left_apply (h : IsCompl p q) {φ : p →ₗ[R] F} {ψ : q →ₗ[R] F} (u : p) :
    ofIsCompl h φ ψ (u : E) = φ u := by simp [of_is_compl]
#align linear_map.of_is_compl_left_apply LinearMap.ofIsCompl_left_apply
-/

#print LinearMap.ofIsCompl_right_apply /-
@[simp]
theorem ofIsCompl_right_apply (h : IsCompl p q) {φ : p →ₗ[R] F} {ψ : q →ₗ[R] F} (v : q) :
    ofIsCompl h φ ψ (v : E) = ψ v := by simp [of_is_compl]
#align linear_map.of_is_compl_right_apply LinearMap.ofIsCompl_right_apply
-/

#print LinearMap.ofIsCompl_eq /-
theorem ofIsCompl_eq (h : IsCompl p q) {φ : p →ₗ[R] F} {ψ : q →ₗ[R] F} {χ : E →ₗ[R] F}
    (hφ : ∀ u, φ u = χ u) (hψ : ∀ u, ψ u = χ u) : ofIsCompl h φ ψ = χ :=
  by
  ext x
  obtain ⟨_, _, rfl, _⟩ := exists_unique_add_of_is_compl h x
  simp [of_is_compl, hφ, hψ]
#align linear_map.of_is_compl_eq LinearMap.ofIsCompl_eq
-/

#print LinearMap.ofIsCompl_eq' /-
theorem ofIsCompl_eq' (h : IsCompl p q) {φ : p →ₗ[R] F} {ψ : q →ₗ[R] F} {χ : E →ₗ[R] F}
    (hφ : φ = χ.comp p.Subtype) (hψ : ψ = χ.comp q.Subtype) : ofIsCompl h φ ψ = χ :=
  ofIsCompl_eq h (fun _ => hφ.symm ▸ rfl) fun _ => hψ.symm ▸ rfl
#align linear_map.of_is_compl_eq' LinearMap.ofIsCompl_eq'
-/

#print LinearMap.ofIsCompl_zero /-
@[simp]
theorem ofIsCompl_zero (h : IsCompl p q) : (ofIsCompl h 0 0 : E →ₗ[R] F) = 0 :=
  ofIsCompl_eq _ (fun _ => rfl) fun _ => rfl
#align linear_map.of_is_compl_zero LinearMap.ofIsCompl_zero
-/

#print LinearMap.ofIsCompl_add /-
@[simp]
theorem ofIsCompl_add (h : IsCompl p q) {φ₁ φ₂ : p →ₗ[R] F} {ψ₁ ψ₂ : q →ₗ[R] F} :
    ofIsCompl h (φ₁ + φ₂) (ψ₁ + ψ₂) = ofIsCompl h φ₁ ψ₁ + ofIsCompl h φ₂ ψ₂ :=
  ofIsCompl_eq _ (by simp) (by simp)
#align linear_map.of_is_compl_add LinearMap.ofIsCompl_add
-/

#print LinearMap.ofIsCompl_smul /-
@[simp]
theorem ofIsCompl_smul {R : Type _} [CommRing R] {E : Type _} [AddCommGroup E] [Module R E]
    {F : Type _} [AddCommGroup F] [Module R F] {p q : Submodule R E} (h : IsCompl p q)
    {φ : p →ₗ[R] F} {ψ : q →ₗ[R] F} (c : R) : ofIsCompl h (c • φ) (c • ψ) = c • ofIsCompl h φ ψ :=
  ofIsCompl_eq _ (by simp) (by simp)
#align linear_map.of_is_compl_smul LinearMap.ofIsCompl_smul
-/

section

variable {R₁ : Type _} [CommRing R₁] [Module R₁ E] [Module R₁ F]

#print LinearMap.ofIsComplProd /-
/-- The linear map from `(p →ₗ[R₁] F) × (q →ₗ[R₁] F)` to `E →ₗ[R₁] F`. -/
def ofIsComplProd {p q : Submodule R₁ E} (h : IsCompl p q) :
    (p →ₗ[R₁] F) × (q →ₗ[R₁] F) →ₗ[R₁] E →ₗ[R₁] F
    where
  toFun φ := ofIsCompl h φ.1 φ.2
  map_add' := by intro φ ψ; rw [Prod.snd_add, Prod.fst_add, of_is_compl_add]
  map_smul' := by intro c φ; simp [Prod.smul_snd, Prod.smul_fst, of_is_compl_smul]
#align linear_map.of_is_compl_prod LinearMap.ofIsComplProd
-/

#print LinearMap.ofIsComplProd_apply /-
@[simp]
theorem ofIsComplProd_apply {p q : Submodule R₁ E} (h : IsCompl p q)
    (φ : (p →ₗ[R₁] F) × (q →ₗ[R₁] F)) : ofIsComplProd h φ = ofIsCompl h φ.1 φ.2 :=
  rfl
#align linear_map.of_is_compl_prod_apply LinearMap.ofIsComplProd_apply
-/

#print LinearMap.ofIsComplProdEquiv /-
/-- The natural linear equivalence between `(p →ₗ[R₁] F) × (q →ₗ[R₁] F)` and `E →ₗ[R₁] F`. -/
def ofIsComplProdEquiv {p q : Submodule R₁ E} (h : IsCompl p q) :
    ((p →ₗ[R₁] F) × (q →ₗ[R₁] F)) ≃ₗ[R₁] E →ₗ[R₁] F :=
  { ofIsComplProd h with
    invFun := fun φ => ⟨φ.domRestrict p, φ.domRestrict q⟩
    left_inv := by
      intro φ; ext
      · exact of_is_compl_left_apply h x
      · exact of_is_compl_right_apply h x
    right_inv := by
      intro φ; ext
      obtain ⟨a, b, hab, _⟩ := exists_unique_add_of_is_compl h x
      rw [← hab]; simp }
#align linear_map.of_is_compl_prod_equiv LinearMap.ofIsComplProdEquiv
-/

end

#print LinearMap.linearProjOfIsCompl_of_proj /-
@[simp]
theorem linearProjOfIsCompl_of_proj (f : E →ₗ[R] p) (hf : ∀ x : p, f x = x) :
    p.linearProjOfIsCompl f.ker (isCompl_of_proj hf) = f :=
  by
  ext x
  have : x ∈ p ⊔ f.ker := by simp only [(is_compl_of_proj hf).sup_eq_top, mem_top]
  rcases mem_sup'.1 this with ⟨x, y, rfl⟩
  simp [hf]
#align linear_map.linear_proj_of_is_compl_of_proj LinearMap.linearProjOfIsCompl_of_proj
-/

#print LinearMap.equivProdOfSurjectiveOfIsCompl /-
/-- If `f : E →ₗ[R] F` and `g : E →ₗ[R] G` are two surjective linear maps and
their kernels are complement of each other, then `x ↦ (f x, g x)` defines
a linear equivalence `E ≃ₗ[R] F × G`. -/
def equivProdOfSurjectiveOfIsCompl (f : E →ₗ[R] F) (g : E →ₗ[R] G) (hf : f.range = ⊤)
    (hg : g.range = ⊤) (hfg : IsCompl f.ker g.ker) : E ≃ₗ[R] F × G :=
  LinearEquiv.ofBijective (f.Prod g)
    ⟨by simp [← ker_eq_bot, hfg.inf_eq_bot], by rw [← range_eq_top];
      simp [range_prod_eq hfg.sup_eq_top, *]⟩
#align linear_map.equiv_prod_of_surjective_of_is_compl LinearMap.equivProdOfSurjectiveOfIsCompl
-/

#print LinearMap.coe_equivProdOfSurjectiveOfIsCompl /-
@[simp]
theorem coe_equivProdOfSurjectiveOfIsCompl {f : E →ₗ[R] F} {g : E →ₗ[R] G} (hf : f.range = ⊤)
    (hg : g.range = ⊤) (hfg : IsCompl f.ker g.ker) :
    (equivProdOfSurjectiveOfIsCompl f g hf hg hfg : E →ₗ[R] F × G) = f.Prod g :=
  rfl
#align linear_map.coe_equiv_prod_of_surjective_of_is_compl LinearMap.coe_equivProdOfSurjectiveOfIsCompl
-/

#print LinearMap.equivProdOfSurjectiveOfIsCompl_apply /-
@[simp]
theorem equivProdOfSurjectiveOfIsCompl_apply {f : E →ₗ[R] F} {g : E →ₗ[R] G} (hf : f.range = ⊤)
    (hg : g.range = ⊤) (hfg : IsCompl f.ker g.ker) (x : E) :
    equivProdOfSurjectiveOfIsCompl f g hf hg hfg x = (f x, g x) :=
  rfl
#align linear_map.equiv_prod_of_surjective_of_is_compl_apply LinearMap.equivProdOfSurjectiveOfIsCompl_apply
-/

end LinearMap

namespace Submodule

open LinearMap

#print Submodule.isComplEquivProj /-
/-- Equivalence between submodules `q` such that `is_compl p q` and linear maps `f : E →ₗ[R] p`
such that `∀ x : p, f x = x`. -/
def isComplEquivProj : { q // IsCompl p q } ≃ { f : E →ₗ[R] p // ∀ x : p, f x = x }
    where
  toFun q := ⟨linearProjOfIsCompl p q q.2, linearProjOfIsCompl_apply_left q.2⟩
  invFun f := ⟨(f : E →ₗ[R] p).ker, isCompl_of_proj f.2⟩
  left_inv := fun ⟨q, hq⟩ => by simp only [linear_proj_of_is_compl_ker, Subtype.coe_mk]
  right_inv := fun ⟨f, hf⟩ => Subtype.eq <| f.linearProjOfIsCompl_of_proj hf
#align submodule.is_compl_equiv_proj Submodule.isComplEquivProj
-/

#print Submodule.coe_isComplEquivProj_apply /-
@[simp]
theorem coe_isComplEquivProj_apply (q : { q // IsCompl p q }) :
    (p.isComplEquivProj q : E →ₗ[R] p) = linearProjOfIsCompl p q q.2 :=
  rfl
#align submodule.coe_is_compl_equiv_proj_apply Submodule.coe_isComplEquivProj_apply
-/

#print Submodule.coe_isComplEquivProj_symm_apply /-
@[simp]
theorem coe_isComplEquivProj_symm_apply (f : { f : E →ₗ[R] p // ∀ x : p, f x = x }) :
    (p.isComplEquivProj.symm f : Submodule R E) = (f : E →ₗ[R] p).ker :=
  rfl
#align submodule.coe_is_compl_equiv_proj_symm_apply Submodule.coe_isComplEquivProj_symm_apply
-/

end Submodule

namespace LinearMap

open Submodule

#print LinearMap.IsProj /-
/--
A linear endomorphism of a module `E` is a projection onto a submodule `p` if it sends every element
of `E` to `p` and fixes every element of `p`.
The definition allow more generally any `fun_like` type and not just linear maps, so that it can be
used for example with `continuous_linear_map` or `matrix`.
-/
structure IsProj {F : Type _} [FunLike F M fun _ => M] (f : F) : Prop where
  map_mem : ∀ x, f x ∈ m
  map_id : ∀ x ∈ m, f x = x
#align linear_map.is_proj LinearMap.IsProj
-/

#print LinearMap.isProj_iff_idempotent /-
theorem isProj_iff_idempotent (f : M →ₗ[S] M) : (∃ p : Submodule S M, IsProj p f) ↔ f ∘ₗ f = f :=
  by
  constructor
  · intro h; obtain ⟨p, hp⟩ := h; ext; rw [comp_apply]; exact hp.map_id (f x) (hp.map_mem x)
  · intro h; use f.range; constructor
    · intro x; exact mem_range_self f x
    · intro x hx; obtain ⟨y, hy⟩ := mem_range.1 hx; rw [← hy, ← comp_apply, h]
#align linear_map.is_proj_iff_idempotent LinearMap.isProj_iff_idempotent
-/

namespace IsProj

variable {p m}

#print LinearMap.IsProj.codRestrict /-
/-- Restriction of the codomain of a projection of onto a subspace `p` to `p` instead of the whole
space.
-/
def codRestrict {f : M →ₗ[S] M} (h : IsProj m f) : M →ₗ[S] m :=
  f.codRestrict m h.map_mem
#align linear_map.is_proj.cod_restrict LinearMap.IsProj.codRestrict
-/

#print LinearMap.IsProj.codRestrict_apply /-
@[simp]
theorem codRestrict_apply {f : M →ₗ[S] M} (h : IsProj m f) (x : M) : ↑(h.codRestrict x) = f x :=
  f.codRestrict_apply m x
#align linear_map.is_proj.cod_restrict_apply LinearMap.IsProj.codRestrict_apply
-/

#print LinearMap.IsProj.codRestrict_apply_cod /-
@[simp]
theorem codRestrict_apply_cod {f : M →ₗ[S] M} (h : IsProj m f) (x : m) : h.codRestrict x = x := by
  ext; rw [cod_restrict_apply]; exact h.map_id x x.2
#align linear_map.is_proj.cod_restrict_apply_cod LinearMap.IsProj.codRestrict_apply_cod
-/

#print LinearMap.IsProj.codRestrict_ker /-
theorem codRestrict_ker {f : M →ₗ[S] M} (h : IsProj m f) : h.codRestrict.ker = f.ker :=
  f.ker_codRestrict m _
#align linear_map.is_proj.cod_restrict_ker LinearMap.IsProj.codRestrict_ker
-/

#print LinearMap.IsProj.isCompl /-
theorem isCompl {f : E →ₗ[R] E} (h : IsProj p f) : IsCompl p f.ker := by rw [← cod_restrict_ker];
  exact is_compl_of_proj h.cod_restrict_apply_cod
#align linear_map.is_proj.is_compl LinearMap.IsProj.isCompl
-/

#print LinearMap.IsProj.eq_conj_prod_map' /-
theorem eq_conj_prod_map' {f : E →ₗ[R] E} (h : IsProj p f) :
    f =
      (p.prodEquivOfIsCompl f.ker h.IsCompl).toLinearMap ∘ₗ
        prodMap id 0 ∘ₗ (p.prodEquivOfIsCompl f.ker h.IsCompl).symm.toLinearMap :=
  by
  refine' (LinearMap.cancel_right (p.prod_equiv_of_is_compl f.ker h.is_compl).Surjective).1 _
  ext
  ·
    simp only [coe_comp, LinearEquiv.coe_toLinearMap, coe_inl, Function.comp_apply,
      LinearEquiv.ofTop_apply, LinearEquiv.ofInjective_apply, coprod_apply, Submodule.coeSubtype,
      coe_zero, add_zero, prod_equiv_of_is_compl_symm_apply_left, prod_map_apply, id_coe, id.def,
      zero_apply, coe_prod_equiv_of_is_compl', h.map_id x x.2]
  ·
    simp only [coe_comp, LinearEquiv.coe_toLinearMap, coe_inr, Function.comp_apply,
      LinearEquiv.ofTop_apply, LinearEquiv.ofInjective_apply, coprod_apply, Submodule.coeSubtype,
      coe_zero, zero_add, map_coe_ker, prod_equiv_of_is_compl_symm_apply_right, prod_map_apply,
      id_coe, id.def, zero_apply, coe_prod_equiv_of_is_compl']
#align linear_map.is_proj.eq_conj_prod_map' LinearMap.IsProj.eq_conj_prod_map'
-/

end IsProj

end LinearMap

end Ring

section CommRing

namespace LinearMap

variable {R : Type _} [CommRing R] {E : Type _} [AddCommGroup E] [Module R E] {p : Submodule R E}

#print LinearMap.IsProj.eq_conj_prodMap /-
theorem IsProj.eq_conj_prodMap {f : E →ₗ[R] E} (h : IsProj p f) :
    f = (p.prodEquivOfIsCompl f.ker h.IsCompl).conj (prodMap id 0) := by
  rw [LinearEquiv.conj_apply]; exact h.eq_conj_prod_map'
#align linear_map.is_proj.eq_conj_prod_map LinearMap.IsProj.eq_conj_prodMap
-/

end LinearMap

end CommRing

