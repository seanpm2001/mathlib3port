/-
Copyright (c) 2022 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Patrick Massot, Sébastien Gouëzel, Zhouhang Zhou, Reid Barton,
Anatole Dedecker

! This file was ported from Lean 3 source module topology.uniform_space.equiv
! leanprover-community/mathlib commit 34ee86e6a59d911a8e4f89b68793ee7577ae79c7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Homeomorph
import Mathbin.Topology.UniformSpace.UniformEmbedding
import Mathbin.Topology.UniformSpace.Pi

/-!
# Uniform isomorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines uniform isomorphisms between two uniform spaces. They are bijections with both
directions uniformly continuous. We denote uniform isomorphisms with the notation `≃ᵤ`.

# Main definitions

* `uniform_equiv α β`: The type of uniform isomorphisms from `α` to `β`.
  This type can be denoted using the following notation: `α ≃ᵤ β`.

-/


open Set Filter

universe u v

variable {α : Type u} {β : Type _} {γ : Type _} {δ : Type _}

#print UniformEquiv /-
-- not all spaces are homeomorphic to each other
/-- Uniform isomorphism between `α` and `β` -/
@[nolint has_nonempty_instance]
structure UniformEquiv (α : Type _) (β : Type _) [UniformSpace α] [UniformSpace β] extends
    α ≃ β where
  uniformContinuous_toFun : UniformContinuous to_fun
  uniformContinuous_invFun : UniformContinuous inv_fun
#align uniform_equiv UniformEquiv
-/

infixl:25 " ≃ᵤ " => UniformEquiv

namespace UniformEquiv

variable [UniformSpace α] [UniformSpace β] [UniformSpace γ] [UniformSpace δ]

instance : CoeFun (α ≃ᵤ β) fun _ => α → β :=
  ⟨fun e => e.toEquiv⟩

#print UniformEquiv.uniformEquiv_mk_coe /-
@[simp]
theorem uniformEquiv_mk_coe (a : Equiv α β) (b c) : (UniformEquiv.mk a b c : α → β) = a :=
  rfl
#align uniform_equiv.uniform_equiv_mk_coe UniformEquiv.uniformEquiv_mk_coe
-/

#print UniformEquiv.symm /-
/-- Inverse of a uniform isomorphism. -/
protected def symm (h : α ≃ᵤ β) : β ≃ᵤ α
    where
  uniformContinuous_toFun := h.uniformContinuous_invFun
  uniformContinuous_invFun := h.uniformContinuous_toFun
  toEquiv := h.toEquiv.symm
#align uniform_equiv.symm UniformEquiv.symm
-/

#print UniformEquiv.Simps.apply /-
/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def Simps.apply (h : α ≃ᵤ β) : α → β :=
  h
#align uniform_equiv.simps.apply UniformEquiv.Simps.apply
-/

#print UniformEquiv.Simps.symm_apply /-
/-- See Note [custom simps projection] -/
def Simps.symm_apply (h : α ≃ᵤ β) : β → α :=
  h.symm
#align uniform_equiv.simps.symm_apply UniformEquiv.Simps.symm_apply
-/

initialize_simps_projections UniformEquiv (to_equiv_to_fun → apply, to_equiv_inv_fun → symm_apply,
  -toEquiv)

#print UniformEquiv.coe_toEquiv /-
@[simp]
theorem coe_toEquiv (h : α ≃ᵤ β) : ⇑h.toEquiv = h :=
  rfl
#align uniform_equiv.coe_to_equiv UniformEquiv.coe_toEquiv
-/

#print UniformEquiv.coe_symm_toEquiv /-
@[simp]
theorem coe_symm_toEquiv (h : α ≃ᵤ β) : ⇑h.toEquiv.symm = h.symm :=
  rfl
#align uniform_equiv.coe_symm_to_equiv UniformEquiv.coe_symm_toEquiv
-/

#print UniformEquiv.toEquiv_injective /-
theorem toEquiv_injective : Function.Injective (toEquiv : α ≃ᵤ β → α ≃ β)
  | ⟨e, h₁, h₂⟩, ⟨e', h₁', h₂'⟩, rfl => rfl
#align uniform_equiv.to_equiv_injective UniformEquiv.toEquiv_injective
-/

#print UniformEquiv.ext /-
@[ext]
theorem ext {h h' : α ≃ᵤ β} (H : ∀ x, h x = h' x) : h = h' :=
  toEquiv_injective <| Equiv.ext H
#align uniform_equiv.ext UniformEquiv.ext
-/

#print UniformEquiv.refl /-
/-- Identity map as a uniform isomorphism. -/
@[simps (config := { fullyApplied := false }) apply]
protected def refl (α : Type _) [UniformSpace α] : α ≃ᵤ α
    where
  uniformContinuous_toFun := uniformContinuous_id
  uniformContinuous_invFun := uniformContinuous_id
  toEquiv := Equiv.refl α
#align uniform_equiv.refl UniformEquiv.refl
-/

#print UniformEquiv.trans /-
/-- Composition of two uniform isomorphisms. -/
protected def trans (h₁ : α ≃ᵤ β) (h₂ : β ≃ᵤ γ) : α ≃ᵤ γ
    where
  uniformContinuous_toFun := h₂.uniformContinuous_toFun.comp h₁.uniformContinuous_toFun
  uniformContinuous_invFun := h₁.uniformContinuous_invFun.comp h₂.uniformContinuous_invFun
  toEquiv := Equiv.trans h₁.toEquiv h₂.toEquiv
#align uniform_equiv.trans UniformEquiv.trans
-/

#print UniformEquiv.trans_apply /-
@[simp]
theorem trans_apply (h₁ : α ≃ᵤ β) (h₂ : β ≃ᵤ γ) (a : α) : h₁.trans h₂ a = h₂ (h₁ a) :=
  rfl
#align uniform_equiv.trans_apply UniformEquiv.trans_apply
-/

#print UniformEquiv.uniformEquiv_mk_coe_symm /-
@[simp]
theorem uniformEquiv_mk_coe_symm (a : Equiv α β) (b c) :
    ((UniformEquiv.mk a b c).symm : β → α) = a.symm :=
  rfl
#align uniform_equiv.uniform_equiv_mk_coe_symm UniformEquiv.uniformEquiv_mk_coe_symm
-/

#print UniformEquiv.refl_symm /-
@[simp]
theorem refl_symm : (UniformEquiv.refl α).symm = UniformEquiv.refl α :=
  rfl
#align uniform_equiv.refl_symm UniformEquiv.refl_symm
-/

#print UniformEquiv.uniformContinuous /-
protected theorem uniformContinuous (h : α ≃ᵤ β) : UniformContinuous h :=
  h.uniformContinuous_toFun
#align uniform_equiv.uniform_continuous UniformEquiv.uniformContinuous
-/

#print UniformEquiv.continuous /-
@[continuity]
protected theorem continuous (h : α ≃ᵤ β) : Continuous h :=
  h.UniformContinuous.Continuous
#align uniform_equiv.continuous UniformEquiv.continuous
-/

#print UniformEquiv.uniformContinuous_symm /-
protected theorem uniformContinuous_symm (h : α ≃ᵤ β) : UniformContinuous h.symm :=
  h.uniformContinuous_invFun
#align uniform_equiv.uniform_continuous_symm UniformEquiv.uniformContinuous_symm
-/

#print UniformEquiv.continuous_symm /-
-- otherwise `by continuity` can't prove continuity of `h.to_equiv.symm`
@[continuity]
protected theorem continuous_symm (h : α ≃ᵤ β) : Continuous h.symm :=
  h.uniformContinuous_symm.Continuous
#align uniform_equiv.continuous_symm UniformEquiv.continuous_symm
-/

#print UniformEquiv.toHomeomorph /-
/-- A uniform isomorphism as a homeomorphism. -/
@[simps]
protected def toHomeomorph (e : α ≃ᵤ β) : α ≃ₜ β :=
  { e.toEquiv with
    continuous_toFun := e.Continuous
    continuous_invFun := e.continuous_symm }
#align uniform_equiv.to_homeomorph UniformEquiv.toHomeomorph
-/

#print UniformEquiv.apply_symm_apply /-
@[simp]
theorem apply_symm_apply (h : α ≃ᵤ β) (x : β) : h (h.symm x) = x :=
  h.toEquiv.apply_symm_apply x
#align uniform_equiv.apply_symm_apply UniformEquiv.apply_symm_apply
-/

#print UniformEquiv.symm_apply_apply /-
@[simp]
theorem symm_apply_apply (h : α ≃ᵤ β) (x : α) : h.symm (h x) = x :=
  h.toEquiv.symm_apply_apply x
#align uniform_equiv.symm_apply_apply UniformEquiv.symm_apply_apply
-/

#print UniformEquiv.bijective /-
protected theorem bijective (h : α ≃ᵤ β) : Function.Bijective h :=
  h.toEquiv.Bijective
#align uniform_equiv.bijective UniformEquiv.bijective
-/

#print UniformEquiv.injective /-
protected theorem injective (h : α ≃ᵤ β) : Function.Injective h :=
  h.toEquiv.Injective
#align uniform_equiv.injective UniformEquiv.injective
-/

#print UniformEquiv.surjective /-
protected theorem surjective (h : α ≃ᵤ β) : Function.Surjective h :=
  h.toEquiv.Surjective
#align uniform_equiv.surjective UniformEquiv.surjective
-/

#print UniformEquiv.changeInv /-
/-- Change the uniform equiv `f` to make the inverse function definitionally equal to `g`. -/
def changeInv (f : α ≃ᵤ β) (g : β → α) (hg : Function.RightInverse g f) : α ≃ᵤ β :=
  have : g = f.symm :=
    funext fun x =>
      calc
        g x = f.symm (f (g x)) := (f.left_inv (g x)).symm
        _ = f.symm x := by rw [hg x]
  { toFun := f
    invFun := g
    left_inv := by convert f.left_inv
    right_inv := by convert f.right_inv
    uniformContinuous_toFun := f.UniformContinuous
    uniformContinuous_invFun := by convert f.symm.uniform_continuous }
#align uniform_equiv.change_inv UniformEquiv.changeInv
-/

#print UniformEquiv.symm_comp_self /-
@[simp]
theorem symm_comp_self (h : α ≃ᵤ β) : ⇑h.symm ∘ ⇑h = id :=
  funext h.symm_apply_apply
#align uniform_equiv.symm_comp_self UniformEquiv.symm_comp_self
-/

#print UniformEquiv.self_comp_symm /-
@[simp]
theorem self_comp_symm (h : α ≃ᵤ β) : ⇑h ∘ ⇑h.symm = id :=
  funext h.apply_symm_apply
#align uniform_equiv.self_comp_symm UniformEquiv.self_comp_symm
-/

#print UniformEquiv.range_coe /-
@[simp]
theorem range_coe (h : α ≃ᵤ β) : range h = univ :=
  h.Surjective.range_eq
#align uniform_equiv.range_coe UniformEquiv.range_coe
-/

#print UniformEquiv.image_symm /-
theorem image_symm (h : α ≃ᵤ β) : image h.symm = preimage h :=
  funext h.symm.toEquiv.image_eq_preimage
#align uniform_equiv.image_symm UniformEquiv.image_symm
-/

#print UniformEquiv.preimage_symm /-
theorem preimage_symm (h : α ≃ᵤ β) : preimage h.symm = image h :=
  (funext h.toEquiv.image_eq_preimage).symm
#align uniform_equiv.preimage_symm UniformEquiv.preimage_symm
-/

#print UniformEquiv.image_preimage /-
@[simp]
theorem image_preimage (h : α ≃ᵤ β) (s : Set β) : h '' (h ⁻¹' s) = s :=
  h.toEquiv.image_preimage s
#align uniform_equiv.image_preimage UniformEquiv.image_preimage
-/

#print UniformEquiv.preimage_image /-
@[simp]
theorem preimage_image (h : α ≃ᵤ β) (s : Set α) : h ⁻¹' (h '' s) = s :=
  h.toEquiv.preimage_image s
#align uniform_equiv.preimage_image UniformEquiv.preimage_image
-/

#print UniformEquiv.uniformInducing /-
protected theorem uniformInducing (h : α ≃ᵤ β) : UniformInducing h :=
  uniformInducing_of_compose h.UniformContinuous h.symm.UniformContinuous <| by
    simp only [symm_comp_self, uniformInducing_id]
#align uniform_equiv.uniform_inducing UniformEquiv.uniformInducing
-/

#print UniformEquiv.comap_eq /-
theorem comap_eq (h : α ≃ᵤ β) : UniformSpace.comap h ‹_› = ‹_› := by
  ext : 1 <;> exact h.uniform_inducing.comap_uniformity
#align uniform_equiv.comap_eq UniformEquiv.comap_eq
-/

#print UniformEquiv.uniformEmbedding /-
protected theorem uniformEmbedding (h : α ≃ᵤ β) : UniformEmbedding h :=
  ⟨h.UniformInducing, h.Injective⟩
#align uniform_equiv.uniform_embedding UniformEquiv.uniformEmbedding
-/

#print UniformEquiv.ofUniformEmbedding /-
/-- Uniform equiv given a uniform embedding. -/
noncomputable def ofUniformEmbedding (f : α → β) (hf : UniformEmbedding f) : α ≃ᵤ Set.range f
    where
  uniformContinuous_toFun := hf.to_uniformInducing.UniformContinuous.subtype_mk _
  uniformContinuous_invFun := by
    simp [hf.to_uniform_inducing.uniform_continuous_iff, uniformContinuous_subtype_val]
  toEquiv := Equiv.ofInjective f hf.inj
#align uniform_equiv.of_uniform_embedding UniformEquiv.ofUniformEmbedding
-/

#print UniformEquiv.setCongr /-
/-- If two sets are equal, then they are uniformly equivalent. -/
def setCongr {s t : Set α} (h : s = t) : s ≃ᵤ t
    where
  uniformContinuous_toFun := uniformContinuous_subtype_val.subtype_mk _
  uniformContinuous_invFun := uniformContinuous_subtype_val.subtype_mk _
  toEquiv := Equiv.setCongr h
#align uniform_equiv.set_congr UniformEquiv.setCongr
-/

#print UniformEquiv.prodCongr /-
/-- Product of two uniform isomorphisms. -/
def prodCongr (h₁ : α ≃ᵤ β) (h₂ : γ ≃ᵤ δ) : α × γ ≃ᵤ β × δ
    where
  uniformContinuous_toFun :=
    (h₁.UniformContinuous.comp uniformContinuous_fst).prod_mk
      (h₂.UniformContinuous.comp uniformContinuous_snd)
  uniformContinuous_invFun :=
    (h₁.symm.UniformContinuous.comp uniformContinuous_fst).prod_mk
      (h₂.symm.UniformContinuous.comp uniformContinuous_snd)
  toEquiv := h₁.toEquiv.prodCongr h₂.toEquiv
#align uniform_equiv.prod_congr UniformEquiv.prodCongr
-/

#print UniformEquiv.prodCongr_symm /-
@[simp]
theorem prodCongr_symm (h₁ : α ≃ᵤ β) (h₂ : γ ≃ᵤ δ) :
    (h₁.prodCongr h₂).symm = h₁.symm.prodCongr h₂.symm :=
  rfl
#align uniform_equiv.prod_congr_symm UniformEquiv.prodCongr_symm
-/

#print UniformEquiv.coe_prodCongr /-
@[simp]
theorem coe_prodCongr (h₁ : α ≃ᵤ β) (h₂ : γ ≃ᵤ δ) : ⇑(h₁.prodCongr h₂) = Prod.map h₁ h₂ :=
  rfl
#align uniform_equiv.coe_prod_congr UniformEquiv.coe_prodCongr
-/

section

variable (α β γ)

#print UniformEquiv.prodComm /-
/-- `α × β` is uniformly isomorphic to `β × α`. -/
def prodComm : α × β ≃ᵤ β × α
    where
  uniformContinuous_toFun := uniformContinuous_snd.prod_mk uniformContinuous_fst
  uniformContinuous_invFun := uniformContinuous_snd.prod_mk uniformContinuous_fst
  toEquiv := Equiv.prodComm α β
#align uniform_equiv.prod_comm UniformEquiv.prodComm
-/

#print UniformEquiv.prodComm_symm /-
@[simp]
theorem prodComm_symm : (prodComm α β).symm = prodComm β α :=
  rfl
#align uniform_equiv.prod_comm_symm UniformEquiv.prodComm_symm
-/

#print UniformEquiv.coe_prodComm /-
@[simp]
theorem coe_prodComm : ⇑(prodComm α β) = Prod.swap :=
  rfl
#align uniform_equiv.coe_prod_comm UniformEquiv.coe_prodComm
-/

#print UniformEquiv.prodAssoc /-
/-- `(α × β) × γ` is uniformly isomorphic to `α × (β × γ)`. -/
def prodAssoc : (α × β) × γ ≃ᵤ α × β × γ
    where
  uniformContinuous_toFun :=
    (uniformContinuous_fst.comp uniformContinuous_fst).prod_mk
      ((uniformContinuous_snd.comp uniformContinuous_fst).prod_mk uniformContinuous_snd)
  uniformContinuous_invFun :=
    (uniformContinuous_fst.prod_mk (uniformContinuous_fst.comp uniformContinuous_snd)).prod_mk
      (uniformContinuous_snd.comp uniformContinuous_snd)
  toEquiv := Equiv.prodAssoc α β γ
#align uniform_equiv.prod_assoc UniformEquiv.prodAssoc
-/

#print UniformEquiv.prodPunit /-
/-- `α × {*}` is uniformly isomorphic to `α`. -/
@[simps (config := { fullyApplied := false }) apply]
def prodPunit : α × PUnit ≃ᵤ α where
  toEquiv := Equiv.prodPUnit α
  uniformContinuous_toFun := uniformContinuous_fst
  uniformContinuous_invFun := uniformContinuous_id.prod_mk uniformContinuous_const
#align uniform_equiv.prod_punit UniformEquiv.prodPunit
-/

#print UniformEquiv.punitProd /-
/-- `{*} × α` is uniformly isomorphic to `α`. -/
def punitProd : PUnit × α ≃ᵤ α :=
  (prodComm _ _).trans (prodPunit _)
#align uniform_equiv.punit_prod UniformEquiv.punitProd
-/

#print UniformEquiv.coe_punitProd /-
@[simp]
theorem coe_punitProd : ⇑(punitProd α) = Prod.snd :=
  rfl
#align uniform_equiv.coe_punit_prod UniformEquiv.coe_punitProd
-/

#print UniformEquiv.ulift /-
/-- Uniform equivalence between `ulift α` and `α`. -/
def ulift : ULift.{v, u} α ≃ᵤ α :=
  { Equiv.ulift with
    uniformContinuous_toFun := uniformContinuous_comap
    uniformContinuous_invFun :=
      by
      have hf : UniformInducing (@Equiv.ulift.{v, u} α).toFun := ⟨rfl⟩
      simp_rw [hf.uniform_continuous_iff]
      exact uniformContinuous_id }
#align uniform_equiv.ulift UniformEquiv.ulift
-/

end

#print UniformEquiv.funUnique /-
/-- If `ι` has a unique element, then `ι → α` is homeomorphic to `α`. -/
@[simps (config := { fullyApplied := false })]
def funUnique (ι α : Type _) [Unique ι] [UniformSpace α] : (ι → α) ≃ᵤ α
    where
  toEquiv := Equiv.funUnique ι α
  uniformContinuous_toFun := Pi.uniformContinuous_proj _ _
  uniformContinuous_invFun := uniformContinuous_pi.mpr fun _ => uniformContinuous_id
#align uniform_equiv.fun_unique UniformEquiv.funUnique
-/

#print UniformEquiv.piFinTwo /-
/-- Uniform isomorphism between dependent functions `Π i : fin 2, α i` and `α 0 × α 1`. -/
@[simps (config := { fullyApplied := false })]
def piFinTwo (α : Fin 2 → Type u) [∀ i, UniformSpace (α i)] : (∀ i, α i) ≃ᵤ α 0 × α 1
    where
  toEquiv := piFinTwoEquiv α
  uniformContinuous_toFun := (Pi.uniformContinuous_proj _ 0).prod_mk (Pi.uniformContinuous_proj _ 1)
  uniformContinuous_invFun :=
    uniformContinuous_pi.mpr <| Fin.forall_fin_two.2 ⟨uniformContinuous_fst, uniformContinuous_snd⟩
#align uniform_equiv.pi_fin_two UniformEquiv.piFinTwo
-/

#print UniformEquiv.finTwoArrow /-
/-- Uniform isomorphism between `α² = fin 2 → α` and `α × α`. -/
@[simps (config := { fullyApplied := false })]
def finTwoArrow : (Fin 2 → α) ≃ᵤ α × α :=
  { piFinTwo fun _ => α with toEquiv := finTwoArrowEquiv α }
#align uniform_equiv.fin_two_arrow UniformEquiv.finTwoArrow
-/

#print UniformEquiv.image /-
/-- A subset of a uniform space is uniformly isomorphic to its image under a uniform isomorphism.
-/
def image (e : α ≃ᵤ β) (s : Set α) : s ≃ᵤ e '' s
    where
  uniformContinuous_toFun := (e.UniformContinuous.comp uniformContinuous_subtype_val).subtype_mk _
  uniformContinuous_invFun :=
    (e.symm.UniformContinuous.comp uniformContinuous_subtype_val).subtype_mk _
  toEquiv := e.toEquiv.image s
#align uniform_equiv.image UniformEquiv.image
-/

end UniformEquiv

#print Equiv.toUniformEquivOfUniformInducing /-
/-- A uniform inducing equiv between uniform spaces is a uniform isomorphism. -/
@[simps]
def Equiv.toUniformEquivOfUniformInducing [UniformSpace α] [UniformSpace β] (f : α ≃ β)
    (hf : UniformInducing f) : α ≃ᵤ β :=
  { f with
    uniformContinuous_toFun := hf.UniformContinuous
    uniformContinuous_invFun := hf.uniformContinuous_iff.2 <| by simpa using uniformContinuous_id }
#align equiv.to_uniform_equiv_of_uniform_inducing Equiv.toUniformEquivOfUniformInducing
-/

