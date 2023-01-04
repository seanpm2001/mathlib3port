/-
Copyright (c) 2019 Reid Barton. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Patrick Massot, Sébastien Gouëzel, Zhouhang Zhou, Reid Barton

! This file was ported from Lean 3 source module topology.homeomorph
! leanprover-community/mathlib commit 44b58b42794e5abe2bf86397c38e26b587e07e59
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Equiv.Fin
import Mathbin.Topology.DenseEmbedding
import Mathbin.Topology.Support

/-!
# Homeomorphisms

This file defines homeomorphisms between two topological spaces. They are bijections with both
directions continuous. We denote homeomorphisms with the notation `≃ₜ`.

# Main definitions

* `homeomorph α β`: The type of homeomorphisms from `α` to `β`.
  This type can be denoted using the following notation: `α ≃ₜ β`.

# Main results

* Pretty much every topological property is preserved under homeomorphisms.
* `homeomorph.homeomorph_of_continuous_open`: A continuous bijection that is
  an open map is a homeomorphism.

-/


open Set Filter

open TopologicalSpace

variable {α : Type _} {β : Type _} {γ : Type _} {δ : Type _}

-- not all spaces are homeomorphic to each other
/-- Homeomorphism between `α` and `β`, also called topological isomorphism -/
@[nolint has_nonempty_instance]
structure Homeomorph (α : Type _) (β : Type _) [TopologicalSpace α] [TopologicalSpace β] extends
  α ≃ β where
  continuous_to_fun : Continuous to_fun := by continuity
  continuous_inv_fun : Continuous inv_fun := by continuity
#align homeomorph Homeomorph

-- mathport name: «expr ≃ₜ »
infixl:25 " ≃ₜ " => Homeomorph

namespace Homeomorph

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ] [TopologicalSpace δ]

instance : CoeFun (α ≃ₜ β) fun _ => α → β :=
  ⟨fun e => e.toEquiv⟩

@[simp]
theorem homeomorph_mk_coe (a : Equiv α β) (b c) : (Homeomorph.mk a b c : α → β) = a :=
  rfl
#align homeomorph.homeomorph_mk_coe Homeomorph.homeomorph_mk_coe

/-- Inverse of a homeomorphism. -/
protected def symm (h : α ≃ₜ β) : β ≃ₜ α
    where
  continuous_to_fun := h.continuous_inv_fun
  continuous_inv_fun := h.continuous_to_fun
  toEquiv := h.toEquiv.symm
#align homeomorph.symm Homeomorph.symm

/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def Simps.apply (h : α ≃ₜ β) : α → β :=
  h
#align homeomorph.simps.apply Homeomorph.Simps.apply

/-- See Note [custom simps projection] -/
def Simps.symmApply (h : α ≃ₜ β) : β → α :=
  h.symm
#align homeomorph.simps.symm_apply Homeomorph.Simps.symmApply

initialize_simps_projections Homeomorph (to_equiv_to_fun → apply, to_equiv_inv_fun → symmApply,
  -toEquiv)

@[simp]
theorem coe_to_equiv (h : α ≃ₜ β) : ⇑h.toEquiv = h :=
  rfl
#align homeomorph.coe_to_equiv Homeomorph.coe_to_equiv

@[simp]
theorem coe_symm_to_equiv (h : α ≃ₜ β) : ⇑h.toEquiv.symm = h.symm :=
  rfl
#align homeomorph.coe_symm_to_equiv Homeomorph.coe_symm_to_equiv

theorem to_equiv_injective : Function.Injective (toEquiv : α ≃ₜ β → α ≃ β)
  | ⟨e, h₁, h₂⟩, ⟨e', h₁', h₂'⟩, rfl => rfl
#align homeomorph.to_equiv_injective Homeomorph.to_equiv_injective

@[ext]
theorem ext {h h' : α ≃ₜ β} (H : ∀ x, h x = h' x) : h = h' :=
  to_equiv_injective <| Equiv.ext H
#align homeomorph.ext Homeomorph.ext

/-- Identity map as a homeomorphism. -/
@[simps (config := { fullyApplied := false }) apply]
protected def refl (α : Type _) [TopologicalSpace α] : α ≃ₜ α
    where
  continuous_to_fun := continuous_id
  continuous_inv_fun := continuous_id
  toEquiv := Equiv.refl α
#align homeomorph.refl Homeomorph.refl

/-- Composition of two homeomorphisms. -/
protected def trans (h₁ : α ≃ₜ β) (h₂ : β ≃ₜ γ) : α ≃ₜ γ
    where
  continuous_to_fun := h₂.continuous_to_fun.comp h₁.continuous_to_fun
  continuous_inv_fun := h₁.continuous_inv_fun.comp h₂.continuous_inv_fun
  toEquiv := Equiv.trans h₁.toEquiv h₂.toEquiv
#align homeomorph.trans Homeomorph.trans

@[simp]
theorem trans_apply (h₁ : α ≃ₜ β) (h₂ : β ≃ₜ γ) (a : α) : h₁.trans h₂ a = h₂ (h₁ a) :=
  rfl
#align homeomorph.trans_apply Homeomorph.trans_apply

@[simp]
theorem homeomorph_mk_coe_symm (a : Equiv α β) (b c) :
    ((Homeomorph.mk a b c).symm : β → α) = a.symm :=
  rfl
#align homeomorph.homeomorph_mk_coe_symm Homeomorph.homeomorph_mk_coe_symm

@[simp]
theorem refl_symm : (Homeomorph.refl α).symm = Homeomorph.refl α :=
  rfl
#align homeomorph.refl_symm Homeomorph.refl_symm

@[continuity]
protected theorem continuous (h : α ≃ₜ β) : Continuous h :=
  h.continuous_to_fun
#align homeomorph.continuous Homeomorph.continuous

-- otherwise `by continuity` can't prove continuity of `h.to_equiv.symm`
@[continuity]
protected theorem continuous_symm (h : α ≃ₜ β) : Continuous h.symm :=
  h.continuous_inv_fun
#align homeomorph.continuous_symm Homeomorph.continuous_symm

@[simp]
theorem apply_symm_apply (h : α ≃ₜ β) (x : β) : h (h.symm x) = x :=
  h.toEquiv.apply_symm_apply x
#align homeomorph.apply_symm_apply Homeomorph.apply_symm_apply

@[simp]
theorem symm_apply_apply (h : α ≃ₜ β) (x : α) : h.symm (h x) = x :=
  h.toEquiv.symm_apply_apply x
#align homeomorph.symm_apply_apply Homeomorph.symm_apply_apply

@[simp]
theorem self_trans_symm (h : α ≃ₜ β) : h.trans h.symm = Homeomorph.refl α :=
  by
  ext
  apply symm_apply_apply
#align homeomorph.self_trans_symm Homeomorph.self_trans_symm

@[simp]
theorem symm_trans_self (h : α ≃ₜ β) : h.symm.trans h = Homeomorph.refl β :=
  by
  ext
  apply apply_symm_apply
#align homeomorph.symm_trans_self Homeomorph.symm_trans_self

protected theorem bijective (h : α ≃ₜ β) : Function.Bijective h :=
  h.toEquiv.Bijective
#align homeomorph.bijective Homeomorph.bijective

protected theorem injective (h : α ≃ₜ β) : Function.Injective h :=
  h.toEquiv.Injective
#align homeomorph.injective Homeomorph.injective

protected theorem surjective (h : α ≃ₜ β) : Function.Surjective h :=
  h.toEquiv.Surjective
#align homeomorph.surjective Homeomorph.surjective

/-- Change the homeomorphism `f` to make the inverse function definitionally equal to `g`. -/
def changeInv (f : α ≃ₜ β) (g : β → α) (hg : Function.RightInverse g f) : α ≃ₜ β :=
  have : g = f.symm :=
    funext fun x =>
      calc
        g x = f.symm (f (g x)) := (f.left_inv (g x)).symm
        _ = f.symm x := by rw [hg x]
        
  { toFun := f
    invFun := g
    left_inv := by convert f.left_inv
    right_inv := by convert f.right_inv
    continuous_to_fun := f.Continuous
    continuous_inv_fun := by convert f.symm.continuous }
#align homeomorph.change_inv Homeomorph.changeInv

@[simp]
theorem symm_comp_self (h : α ≃ₜ β) : ⇑h.symm ∘ ⇑h = id :=
  funext h.symm_apply_apply
#align homeomorph.symm_comp_self Homeomorph.symm_comp_self

@[simp]
theorem self_comp_symm (h : α ≃ₜ β) : ⇑h ∘ ⇑h.symm = id :=
  funext h.apply_symm_apply
#align homeomorph.self_comp_symm Homeomorph.self_comp_symm

@[simp]
theorem range_coe (h : α ≃ₜ β) : range h = univ :=
  h.Surjective.range_eq
#align homeomorph.range_coe Homeomorph.range_coe

theorem image_symm (h : α ≃ₜ β) : image h.symm = preimage h :=
  funext h.symm.toEquiv.image_eq_preimage
#align homeomorph.image_symm Homeomorph.image_symm

theorem preimage_symm (h : α ≃ₜ β) : preimage h.symm = image h :=
  (funext h.toEquiv.image_eq_preimage).symm
#align homeomorph.preimage_symm Homeomorph.preimage_symm

@[simp]
theorem image_preimage (h : α ≃ₜ β) (s : Set β) : h '' (h ⁻¹' s) = s :=
  h.toEquiv.image_preimage s
#align homeomorph.image_preimage Homeomorph.image_preimage

@[simp]
theorem preimage_image (h : α ≃ₜ β) (s : Set α) : h ⁻¹' (h '' s) = s :=
  h.toEquiv.preimage_image s
#align homeomorph.preimage_image Homeomorph.preimage_image

protected theorem inducing (h : α ≃ₜ β) : Inducing h :=
  inducing_of_inducing_compose h.Continuous h.symm.Continuous <| by
    simp only [symm_comp_self, inducing_id]
#align homeomorph.inducing Homeomorph.inducing

theorem induced_eq (h : α ≃ₜ β) : TopologicalSpace.induced h ‹_› = ‹_› :=
  h.Inducing.1.symm
#align homeomorph.induced_eq Homeomorph.induced_eq

protected theorem quotient_map (h : α ≃ₜ β) : QuotientMap h :=
  QuotientMap.of_quotient_map_compose h.symm.Continuous h.Continuous <| by
    simp only [self_comp_symm, QuotientMap.id]
#align homeomorph.quotient_map Homeomorph.quotient_map

theorem coinduced_eq (h : α ≃ₜ β) : TopologicalSpace.coinduced h ‹_› = ‹_› :=
  h.QuotientMap.2.symm
#align homeomorph.coinduced_eq Homeomorph.coinduced_eq

protected theorem embedding (h : α ≃ₜ β) : Embedding h :=
  ⟨h.Inducing, h.Injective⟩
#align homeomorph.embedding Homeomorph.embedding

/-- Homeomorphism given an embedding. -/
noncomputable def ofEmbedding (f : α → β) (hf : Embedding f) : α ≃ₜ Set.range f
    where
  continuous_to_fun := hf.Continuous.subtype_mk _
  continuous_inv_fun := by simp [hf.continuous_iff, continuous_subtype_coe]
  toEquiv := Equiv.ofInjective f hf.inj
#align homeomorph.of_embedding Homeomorph.ofEmbedding

protected theorem second_countable_topology [TopologicalSpace.SecondCountableTopology β]
    (h : α ≃ₜ β) : TopologicalSpace.SecondCountableTopology α :=
  h.Inducing.SecondCountableTopology
#align homeomorph.second_countable_topology Homeomorph.second_countable_topology

theorem is_compact_image {s : Set α} (h : α ≃ₜ β) : IsCompact (h '' s) ↔ IsCompact s :=
  h.Embedding.is_compact_iff_is_compact_image.symm
#align homeomorph.is_compact_image Homeomorph.is_compact_image

theorem is_compact_preimage {s : Set β} (h : α ≃ₜ β) : IsCompact (h ⁻¹' s) ↔ IsCompact s := by
  rw [← image_symm] <;> exact h.symm.is_compact_image
#align homeomorph.is_compact_preimage Homeomorph.is_compact_preimage

@[simp]
theorem comap_cocompact (h : α ≃ₜ β) : comap h (cocompact β) = cocompact α :=
  (comap_cocompact_le h.Continuous).antisymm <|
    (has_basis_cocompact.le_basis_iff (has_basis_cocompact.comap h)).2 fun K hK =>
      ⟨h ⁻¹' K, h.is_compact_preimage.2 hK, Subset.rfl⟩
#align homeomorph.comap_cocompact Homeomorph.comap_cocompact

@[simp]
theorem map_cocompact (h : α ≃ₜ β) : map h (cocompact α) = cocompact β := by
  rw [← h.comap_cocompact, map_comap_of_surjective h.surjective]
#align homeomorph.map_cocompact Homeomorph.map_cocompact

protected theorem compact_space [CompactSpace α] (h : α ≃ₜ β) : CompactSpace β :=
  {
    is_compact_univ :=
      by
      rw [← image_univ_of_surjective h.surjective, h.is_compact_image]
      apply CompactSpace.is_compact_univ }
#align homeomorph.compact_space Homeomorph.compact_space

protected theorem t0_space [T0Space α] (h : α ≃ₜ β) : T0Space β :=
  h.symm.Embedding.T0Space
#align homeomorph.t0_space Homeomorph.t0_space

protected theorem t1_space [T1Space α] (h : α ≃ₜ β) : T1Space β :=
  h.symm.Embedding.T1Space
#align homeomorph.t1_space Homeomorph.t1_space

protected theorem t2Space [T2Space α] (h : α ≃ₜ β) : T2Space β :=
  h.symm.Embedding.T2Space
#align homeomorph.t2_space Homeomorph.t2Space

protected theorem t3Space [T3Space α] (h : α ≃ₜ β) : T3Space β :=
  h.symm.Embedding.T3Space
#align homeomorph.t3_space Homeomorph.t3Space

protected theorem dense_embedding (h : α ≃ₜ β) : DenseEmbedding h :=
  { h.Embedding with dense := h.Surjective.DenseRange }
#align homeomorph.dense_embedding Homeomorph.dense_embedding

@[simp]
theorem is_open_preimage (h : α ≃ₜ β) {s : Set β} : IsOpen (h ⁻¹' s) ↔ IsOpen s :=
  h.QuotientMap.is_open_preimage
#align homeomorph.is_open_preimage Homeomorph.is_open_preimage

@[simp]
theorem is_open_image (h : α ≃ₜ β) {s : Set α} : IsOpen (h '' s) ↔ IsOpen s := by
  rw [← preimage_symm, is_open_preimage]
#align homeomorph.is_open_image Homeomorph.is_open_image

protected theorem is_open_map (h : α ≃ₜ β) : IsOpenMap h := fun s => h.is_open_image.2
#align homeomorph.is_open_map Homeomorph.is_open_map

@[simp]
theorem is_closed_preimage (h : α ≃ₜ β) {s : Set β} : IsClosed (h ⁻¹' s) ↔ IsClosed s := by
  simp only [← is_open_compl_iff, ← preimage_compl, is_open_preimage]
#align homeomorph.is_closed_preimage Homeomorph.is_closed_preimage

@[simp]
theorem is_closed_image (h : α ≃ₜ β) {s : Set α} : IsClosed (h '' s) ↔ IsClosed s := by
  rw [← preimage_symm, is_closed_preimage]
#align homeomorph.is_closed_image Homeomorph.is_closed_image

protected theorem is_closed_map (h : α ≃ₜ β) : IsClosedMap h := fun s => h.is_closed_image.2
#align homeomorph.is_closed_map Homeomorph.is_closed_map

protected theorem open_embedding (h : α ≃ₜ β) : OpenEmbedding h :=
  open_embedding_of_embedding_open h.Embedding h.IsOpenMap
#align homeomorph.open_embedding Homeomorph.open_embedding

protected theorem closed_embedding (h : α ≃ₜ β) : ClosedEmbedding h :=
  closed_embedding_of_embedding_closed h.Embedding h.IsClosedMap
#align homeomorph.closed_embedding Homeomorph.closed_embedding

protected theorem normalSpace [NormalSpace α] (h : α ≃ₜ β) : NormalSpace β :=
  h.symm.ClosedEmbedding.NormalSpace
#align homeomorph.normal_space Homeomorph.normalSpace

theorem preimage_closure (h : α ≃ₜ β) (s : Set β) : h ⁻¹' closure s = closure (h ⁻¹' s) :=
  h.IsOpenMap.preimage_closure_eq_closure_preimage h.Continuous _
#align homeomorph.preimage_closure Homeomorph.preimage_closure

theorem image_closure (h : α ≃ₜ β) (s : Set α) : h '' closure s = closure (h '' s) := by
  rw [← preimage_symm, preimage_closure]
#align homeomorph.image_closure Homeomorph.image_closure

theorem preimage_interior (h : α ≃ₜ β) (s : Set β) : h ⁻¹' interior s = interior (h ⁻¹' s) :=
  h.IsOpenMap.preimage_interior_eq_interior_preimage h.Continuous _
#align homeomorph.preimage_interior Homeomorph.preimage_interior

theorem image_interior (h : α ≃ₜ β) (s : Set α) : h '' interior s = interior (h '' s) := by
  rw [← preimage_symm, preimage_interior]
#align homeomorph.image_interior Homeomorph.image_interior

theorem preimage_frontier (h : α ≃ₜ β) (s : Set β) : h ⁻¹' frontier s = frontier (h ⁻¹' s) :=
  h.IsOpenMap.preimage_frontier_eq_frontier_preimage h.Continuous _
#align homeomorph.preimage_frontier Homeomorph.preimage_frontier

@[to_additive]
theorem HasCompactMulSupport.comp_homeomorph {M} [One M] {f : β → M} (hf : HasCompactMulSupport f)
    (φ : α ≃ₜ β) : HasCompactMulSupport (f ∘ φ) :=
  hf.comp_closed_embedding φ.ClosedEmbedding
#align has_compact_mul_support.comp_homeomorph HasCompactMulSupport.comp_homeomorph

@[simp]
theorem map_nhds_eq (h : α ≃ₜ β) (x : α) : map h (𝓝 x) = 𝓝 (h x) :=
  h.Embedding.map_nhds_of_mem _ (by simp)
#align homeomorph.map_nhds_eq Homeomorph.map_nhds_eq

theorem symm_map_nhds_eq (h : α ≃ₜ β) (x : α) : map h.symm (𝓝 (h x)) = 𝓝 x := by
  rw [h.symm.map_nhds_eq, h.symm_apply_apply]
#align homeomorph.symm_map_nhds_eq Homeomorph.symm_map_nhds_eq

theorem nhds_eq_comap (h : α ≃ₜ β) (x : α) : 𝓝 x = comap h (𝓝 (h x)) :=
  h.Embedding.to_inducing.nhds_eq_comap x
#align homeomorph.nhds_eq_comap Homeomorph.nhds_eq_comap

@[simp]
theorem comap_nhds_eq (h : α ≃ₜ β) (y : β) : comap h (𝓝 y) = 𝓝 (h.symm y) := by
  rw [h.nhds_eq_comap, h.apply_symm_apply]
#align homeomorph.comap_nhds_eq Homeomorph.comap_nhds_eq

/-- If an bijective map `e : α ≃ β` is continuous and open, then it is a homeomorphism. -/
def homeomorphOfContinuousOpen (e : α ≃ β) (h₁ : Continuous e) (h₂ : IsOpenMap e) : α ≃ₜ β
    where
  continuous_to_fun := h₁
  continuous_inv_fun := by
    rw [continuous_def]
    intro s hs
    convert ← h₂ s hs using 1
    apply e.image_eq_preimage
  toEquiv := e
#align homeomorph.homeomorph_of_continuous_open Homeomorph.homeomorphOfContinuousOpen

@[simp]
theorem comp_continuous_on_iff (h : α ≃ₜ β) (f : γ → α) (s : Set γ) :
    ContinuousOn (h ∘ f) s ↔ ContinuousOn f s :=
  h.Inducing.continuous_on_iff.symm
#align homeomorph.comp_continuous_on_iff Homeomorph.comp_continuous_on_iff

@[simp]
theorem comp_continuous_iff (h : α ≃ₜ β) {f : γ → α} : Continuous (h ∘ f) ↔ Continuous f :=
  h.Inducing.continuous_iff.symm
#align homeomorph.comp_continuous_iff Homeomorph.comp_continuous_iff

@[simp]
theorem comp_continuous_iff' (h : α ≃ₜ β) {f : β → γ} : Continuous (f ∘ h) ↔ Continuous f :=
  h.QuotientMap.continuous_iff.symm
#align homeomorph.comp_continuous_iff' Homeomorph.comp_continuous_iff'

theorem comp_continuous_at_iff (h : α ≃ₜ β) (f : γ → α) (x : γ) :
    ContinuousAt (h ∘ f) x ↔ ContinuousAt f x :=
  h.Inducing.continuous_at_iff.symm
#align homeomorph.comp_continuous_at_iff Homeomorph.comp_continuous_at_iff

theorem comp_continuous_at_iff' (h : α ≃ₜ β) (f : β → γ) (x : α) :
    ContinuousAt (f ∘ h) x ↔ ContinuousAt f (h x) :=
  h.Inducing.continuous_at_iff' (by simp)
#align homeomorph.comp_continuous_at_iff' Homeomorph.comp_continuous_at_iff'

theorem comp_continuous_within_at_iff (h : α ≃ₜ β) (f : γ → α) (s : Set γ) (x : γ) :
    ContinuousWithinAt f s x ↔ ContinuousWithinAt (h ∘ f) s x :=
  h.Inducing.continuous_within_at_iff
#align homeomorph.comp_continuous_within_at_iff Homeomorph.comp_continuous_within_at_iff

@[simp]
theorem comp_is_open_map_iff (h : α ≃ₜ β) {f : γ → α} : IsOpenMap (h ∘ f) ↔ IsOpenMap f :=
  by
  refine' ⟨_, fun hf => h.is_open_map.comp hf⟩
  intro hf
  rw [← Function.comp.left_id f, ← h.symm_comp_self, Function.comp.assoc]
  exact h.symm.is_open_map.comp hf
#align homeomorph.comp_is_open_map_iff Homeomorph.comp_is_open_map_iff

@[simp]
theorem comp_is_open_map_iff' (h : α ≃ₜ β) {f : β → γ} : IsOpenMap (f ∘ h) ↔ IsOpenMap f :=
  by
  refine' ⟨_, fun hf => hf.comp h.is_open_map⟩
  intro hf
  rw [← Function.comp.right_id f, ← h.self_comp_symm, ← Function.comp.assoc]
  exact hf.comp h.symm.is_open_map
#align homeomorph.comp_is_open_map_iff' Homeomorph.comp_is_open_map_iff'

/-- If two sets are equal, then they are homeomorphic. -/
def setCongr {s t : Set α} (h : s = t) : s ≃ₜ t
    where
  continuous_to_fun := continuous_inclusion h.Subset
  continuous_inv_fun := continuous_inclusion h.symm.Subset
  toEquiv := Equiv.setCongr h
#align homeomorph.set_congr Homeomorph.setCongr

/-- Sum of two homeomorphisms. -/
def sumCongr (h₁ : α ≃ₜ β) (h₂ : γ ≃ₜ δ) : Sum α γ ≃ₜ Sum β δ
    where
  continuous_to_fun := h₁.Continuous.sum_map h₂.Continuous
  continuous_inv_fun := h₁.symm.Continuous.sum_map h₂.symm.Continuous
  toEquiv := h₁.toEquiv.sumCongr h₂.toEquiv
#align homeomorph.sum_congr Homeomorph.sumCongr

/-- Product of two homeomorphisms. -/
def prodCongr (h₁ : α ≃ₜ β) (h₂ : γ ≃ₜ δ) : α × γ ≃ₜ β × δ
    where
  continuous_to_fun :=
    (h₁.Continuous.comp continuous_fst).prod_mk (h₂.Continuous.comp continuous_snd)
  continuous_inv_fun :=
    (h₁.symm.Continuous.comp continuous_fst).prod_mk (h₂.symm.Continuous.comp continuous_snd)
  toEquiv := h₁.toEquiv.prodCongr h₂.toEquiv
#align homeomorph.prod_congr Homeomorph.prodCongr

@[simp]
theorem prod_congr_symm (h₁ : α ≃ₜ β) (h₂ : γ ≃ₜ δ) :
    (h₁.prodCongr h₂).symm = h₁.symm.prodCongr h₂.symm :=
  rfl
#align homeomorph.prod_congr_symm Homeomorph.prod_congr_symm

@[simp]
theorem coe_prod_congr (h₁ : α ≃ₜ β) (h₂ : γ ≃ₜ δ) : ⇑(h₁.prodCongr h₂) = Prod.map h₁ h₂ :=
  rfl
#align homeomorph.coe_prod_congr Homeomorph.coe_prod_congr

section

variable (α β γ)

/-- `α × β` is homeomorphic to `β × α`. -/
def prodComm : α × β ≃ₜ β × α
    where
  continuous_to_fun := continuous_snd.prod_mk continuous_fst
  continuous_inv_fun := continuous_snd.prod_mk continuous_fst
  toEquiv := Equiv.prodComm α β
#align homeomorph.prod_comm Homeomorph.prodComm

@[simp]
theorem prod_comm_symm : (prodComm α β).symm = prodComm β α :=
  rfl
#align homeomorph.prod_comm_symm Homeomorph.prod_comm_symm

@[simp]
theorem coe_prod_comm : ⇑(prodComm α β) = Prod.swap :=
  rfl
#align homeomorph.coe_prod_comm Homeomorph.coe_prod_comm

/-- `(α × β) × γ` is homeomorphic to `α × (β × γ)`. -/
def prodAssoc : (α × β) × γ ≃ₜ α × β × γ
    where
  continuous_to_fun :=
    (continuous_fst.comp continuous_fst).prod_mk
      ((continuous_snd.comp continuous_fst).prod_mk continuous_snd)
  continuous_inv_fun :=
    (continuous_fst.prod_mk (continuous_fst.comp continuous_snd)).prod_mk
      (continuous_snd.comp continuous_snd)
  toEquiv := Equiv.prodAssoc α β γ
#align homeomorph.prod_assoc Homeomorph.prodAssoc

/-- `α × {*}` is homeomorphic to `α`. -/
@[simps (config := { fullyApplied := false }) apply]
def prodPunit : α × PUnit ≃ₜ α where
  toEquiv := Equiv.prodPUnit α
  continuous_to_fun := continuous_fst
  continuous_inv_fun := continuous_id.prod_mk continuous_const
#align homeomorph.prod_punit Homeomorph.prodPunit

/-- `{*} × α` is homeomorphic to `α`. -/
def punitProd : PUnit × α ≃ₜ α :=
  (prodComm _ _).trans (prodPunit _)
#align homeomorph.punit_prod Homeomorph.punitProd

@[simp]
theorem coe_punit_prod : ⇑(punitProd α) = Prod.snd :=
  rfl
#align homeomorph.coe_punit_prod Homeomorph.coe_punit_prod

/-- If both `α` and `β` have a unique element, then `α ≃ₜ β`. -/
@[simps]
def Homeomorph.homeomorphOfUnique [Unique α] [Unique β] : α ≃ₜ β :=
  {
    Equiv.equivOfUnique α
      β with
    continuous_to_fun := @continuous_const α β _ _ default
    continuous_inv_fun := @continuous_const β α _ _ default }
#align homeomorph.homeomorph_of_unique Homeomorph.homeomorphOfUnique

end

/-- If each `β₁ i` is homeomorphic to `β₂ i`, then `Π i, β₁ i` is homeomorphic to `Π i, β₂ i`. -/
@[simps apply toEquiv]
def piCongrRight {ι : Type _} {β₁ β₂ : ι → Type _} [∀ i, TopologicalSpace (β₁ i)]
    [∀ i, TopologicalSpace (β₂ i)] (F : ∀ i, β₁ i ≃ₜ β₂ i) : (∀ i, β₁ i) ≃ₜ ∀ i, β₂ i
    where
  continuous_to_fun := continuous_pi fun i => (F i).Continuous.comp <| continuous_apply i
  continuous_inv_fun := continuous_pi fun i => (F i).symm.Continuous.comp <| continuous_apply i
  toEquiv := Equiv.piCongrRight fun i => (F i).toEquiv
#align homeomorph.Pi_congr_right Homeomorph.piCongrRight

@[simp]
theorem Pi_congr_right_symm {ι : Type _} {β₁ β₂ : ι → Type _} [∀ i, TopologicalSpace (β₁ i)]
    [∀ i, TopologicalSpace (β₂ i)] (F : ∀ i, β₁ i ≃ₜ β₂ i) :
    (piCongrRight F).symm = piCongrRight fun i => (F i).symm :=
  rfl
#align homeomorph.Pi_congr_right_symm Homeomorph.Pi_congr_right_symm

/-- `ulift α` is homeomorphic to `α`. -/
def ulift.{u, v} {α : Type u} [TopologicalSpace α] : ULift.{v, u} α ≃ₜ α
    where
  continuous_to_fun := continuous_ulift_down
  continuous_inv_fun := continuous_ulift_up
  toEquiv := Equiv.ulift
#align homeomorph.ulift Homeomorph.ulift

section Distrib

/-- `(α ⊕ β) × γ` is homeomorphic to `α × γ ⊕ β × γ`. -/
def sumProdDistrib : Sum α β × γ ≃ₜ Sum (α × γ) (β × γ) :=
  Homeomorph.symm <|
    homeomorphOfContinuousOpen (Equiv.sumProdDistrib α β γ).symm
        ((continuous_inl.prod_map continuous_id).sum_elim
          (continuous_inr.prod_map continuous_id)) <|
      (is_open_map_inl.Prod IsOpenMap.id).sum_elim (is_open_map_inr.Prod IsOpenMap.id)
#align homeomorph.sum_prod_distrib Homeomorph.sumProdDistrib

/-- `α × (β ⊕ γ)` is homeomorphic to `α × β ⊕ α × γ`. -/
def prodSumDistrib : α × Sum β γ ≃ₜ Sum (α × β) (α × γ) :=
  (prodComm _ _).trans <| sumProdDistrib.trans <| sumCongr (prodComm _ _) (prodComm _ _)
#align homeomorph.prod_sum_distrib Homeomorph.prodSumDistrib

variable {ι : Type _} {σ : ι → Type _} [∀ i, TopologicalSpace (σ i)]

/-- `(Σ i, σ i) × β` is homeomorphic to `Σ i, (σ i × β)`. -/
def sigmaProdDistrib : (Σi, σ i) × β ≃ₜ Σi, σ i × β :=
  Homeomorph.symm <|
    homeomorphOfContinuousOpen (Equiv.sigmaProdDistrib σ β).symm
      (continuous_sigma fun i => continuous_sigma_mk.fst'.prod_mk continuous_snd)
      (is_open_map_sigma.2 fun i => is_open_map_sigma_mk.Prod IsOpenMap.id)
#align homeomorph.sigma_prod_distrib Homeomorph.sigmaProdDistrib

end Distrib

/-- If `ι` has a unique element, then `ι → α` is homeomorphic to `α`. -/
@[simps (config := { fullyApplied := false })]
def funUnique (ι α : Type _) [Unique ι] [TopologicalSpace α] : (ι → α) ≃ₜ α
    where
  toEquiv := Equiv.funUnique ι α
  continuous_to_fun := continuous_apply _
  continuous_inv_fun := continuous_pi fun _ => continuous_id
#align homeomorph.fun_unique Homeomorph.funUnique

/-- Homeomorphism between dependent functions `Π i : fin 2, α i` and `α 0 × α 1`. -/
@[simps (config := { fullyApplied := false })]
def piFinTwo.{u} (α : Fin 2 → Type u) [∀ i, TopologicalSpace (α i)] : (∀ i, α i) ≃ₜ α 0 × α 1
    where
  toEquiv := piFinTwoEquiv α
  continuous_to_fun := (continuous_apply 0).prod_mk (continuous_apply 1)
  continuous_inv_fun := continuous_pi <| Fin.forall_fin_two.2 ⟨continuous_fst, continuous_snd⟩
#align homeomorph.pi_fin_two Homeomorph.piFinTwo

/-- Homeomorphism between `α² = fin 2 → α` and `α × α`. -/
@[simps (config := { fullyApplied := false })]
def finTwoArrow : (Fin 2 → α) ≃ₜ α × α :=
  { piFinTwo fun _ => α with toEquiv := finTwoArrowEquiv α }
#align homeomorph.fin_two_arrow Homeomorph.finTwoArrow

/-- A subset of a topological space is homeomorphic to its image under a homeomorphism.
-/
@[simps]
def image (e : α ≃ₜ β) (s : Set α) : s ≃ₜ e '' s
    where
  continuous_to_fun := by continuity!
  continuous_inv_fun := by continuity!
  toEquiv := e.toEquiv.image s
#align homeomorph.image Homeomorph.image

/-- `set.univ α` is homeomorphic to `α`. -/
@[simps (config := { fullyApplied := false })]
def Set.univ (α : Type _) [TopologicalSpace α] : (univ : Set α) ≃ₜ α
    where
  toEquiv := Equiv.Set.univ α
  continuous_to_fun := continuous_subtype_coe
  continuous_inv_fun := continuous_id.subtype_mk _
#align homeomorph.set.univ Homeomorph.Set.univ

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- `s ×ˢ t` is homeomorphic to `s × t`. -/
@[simps]
def Set.prod (s : Set α) (t : Set β) : ↥(s ×ˢ t) ≃ₜ s × t
    where
  toEquiv := Equiv.Set.prod s t
  continuous_to_fun :=
    (continuous_subtype_coe.fst.subtype_mk _).prod_mk (continuous_subtype_coe.snd.subtype_mk _)
  continuous_inv_fun :=
    (continuous_subtype_coe.fst'.prod_mk continuous_subtype_coe.snd').subtype_mk _
#align homeomorph.set.prod Homeomorph.Set.prod

section

variable {ι : Type _}

/-- The topological space `Π i, β i` can be split as a product by separating the indices in ι
  depending on whether they satisfy a predicate p or not.-/
@[simps]
def piEquivPiSubtypeProd (p : ι → Prop) (β : ι → Type _) [∀ i, TopologicalSpace (β i)]
    [DecidablePred p] : (∀ i, β i) ≃ₜ (∀ i : { x // p x }, β i) × ∀ i : { x // ¬p x }, β i
    where
  toEquiv := Equiv.piEquivPiSubtypeProd p β
  continuous_to_fun := by
    apply Continuous.prod_mk <;> exact continuous_pi fun j => continuous_apply j
  continuous_inv_fun :=
    continuous_pi fun j => by
      dsimp only [Equiv.piEquivPiSubtypeProd]; split_ifs
      exacts[(continuous_apply _).comp continuous_fst, (continuous_apply _).comp continuous_snd]
#align homeomorph.pi_equiv_pi_subtype_prod Homeomorph.piEquivPiSubtypeProd

variable [DecidableEq ι] (i : ι)

/-- A product of topological spaces can be split as the binary product of one of the spaces and
  the product of all the remaining spaces. -/
@[simps]
def piSplitAt (β : ι → Type _) [∀ j, TopologicalSpace (β j)] :
    (∀ j, β j) ≃ₜ β i × ∀ j : { j // j ≠ i }, β j
    where
  toEquiv := Equiv.piSplitAt i β
  continuous_to_fun := (continuous_apply i).prod_mk (continuous_pi fun j => continuous_apply j)
  continuous_inv_fun :=
    continuous_pi fun j => by
      dsimp only [Equiv.piSplitAt]
      split_ifs
      subst h
      exacts[continuous_fst, (continuous_apply _).comp continuous_snd]
#align homeomorph.pi_split_at Homeomorph.piSplitAt

/-- A product of copies of a topological space can be split as the binary product of one copy and
  the product of all the remaining copies. -/
@[simps]
def funSplitAt : (ι → β) ≃ₜ β × ({ j // j ≠ i } → β) :=
  piSplitAt i _
#align homeomorph.fun_split_at Homeomorph.funSplitAt

end

end Homeomorph

/-- An inducing equiv between topological spaces is a homeomorphism. -/
@[simps]
def Equiv.toHomeomorphOfInducing [TopologicalSpace α] [TopologicalSpace β] (f : α ≃ β)
    (hf : Inducing f) : α ≃ₜ β :=
  { f with
    continuous_to_fun := hf.Continuous
    continuous_inv_fun := hf.continuous_iff.2 <| by simpa using continuous_id }
#align equiv.to_homeomorph_of_inducing Equiv.toHomeomorphOfInducing

namespace Continuous

variable [TopologicalSpace α] [TopologicalSpace β]

theorem continuous_symm_of_equiv_compact_to_t2 [CompactSpace α] [T2Space β] {f : α ≃ β}
    (hf : Continuous f) : Continuous f.symm :=
  by
  rw [continuous_iff_is_closed]
  intro C hC
  have hC' : IsClosed (f '' C) := (hC.is_compact.image hf).IsClosed
  rwa [Equiv.image_eq_preimage] at hC'
#align
  continuous.continuous_symm_of_equiv_compact_to_t2 Continuous.continuous_symm_of_equiv_compact_to_t2

/-- Continuous equivalences from a compact space to a T2 space are homeomorphisms.

This is not true when T2 is weakened to T1
(see `continuous.homeo_of_equiv_compact_to_t2.t1_counterexample`). -/
@[simps]
def homeoOfEquivCompactToT2 [CompactSpace α] [T2Space β] {f : α ≃ β} (hf : Continuous f) : α ≃ₜ β :=
  { f with
    continuous_to_fun := hf
    continuous_inv_fun := hf.continuous_symm_of_equiv_compact_to_t2 }
#align continuous.homeo_of_equiv_compact_to_t2 Continuous.homeoOfEquivCompactToT2

end Continuous

