/-
Copyright (c) 2022 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module category_theory.generator
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Balanced
import Mathbin.CategoryTheory.Limits.EssentiallySmall
import Mathbin.CategoryTheory.Limits.Opposites
import Mathbin.CategoryTheory.Limits.Shapes.ZeroMorphisms
import Mathbin.CategoryTheory.Subobject.Lattice
import Mathbin.CategoryTheory.Subobject.WellPowered
import Mathbin.Data.Set.Opposite

/-!
# Separating and detecting sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

There are several non-equivalent notions of a generator of a category. Here, we consider two of
them:

* We say that `𝒢` is a separating set if the functors `C(G, -)` for `G ∈ 𝒢` are collectively
    faithful, i.e., if `h ≫ f = h ≫ g` for all `h` with domain in `𝒢` implies `f = g`.
* We say that `𝒢` is a detecting set if the functors `C(G, -)` collectively reflect isomorphisms,
    i.e., if any `h` with domain in `𝒢` uniquely factors through `f`, then `f` is an isomorphism.

There are, of course, also the dual notions of coseparating and codetecting sets.

## Main results

We
* define predicates `is_separating`, `is_coseparating`, `is_detecting` and `is_codetecting` on
  sets of objects;
* show that separating and coseparating are dual notions;
* show that detecting and codetecting are dual notions;
* show that if `C` has equalizers, then detecting implies separating;
* show that if `C` has coequalizers, then codetecting implies separating;
* show that if `C` is balanced, then separating implies detecting and coseparating implies
  codetecting;
* show that `∅` is separating if and only if `∅` is coseparating if and only if `C` is thin;
* show that `∅` is detecting if and only if `∅` is codetecting if and only if `C` is a groupoid;
* define predicates `is_separator`, `is_coseparator`, `is_detector` and `is_codetector` as the
  singleton counterparts to the definitions for sets above and restate the above results in this
  situation;
* show that `G` is a separator if and only if `coyoneda.obj (op G)` is faithful (and the dual);
* show that `G` is a detector if and only if `coyoneda.obj (op G)` reflects isomorphisms (and the
  dual).

## Future work

* We currently don't have any examples yet.
* We will want typeclasses `has_separator C` and similar.

-/


universe w v₁ v₂ u₁ u₂

open CategoryTheory.Limits Opposite

namespace CategoryTheory

variable {C : Type u₁} [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D]

#print CategoryTheory.IsSeparating /-
/-- We say that `𝒢` is a separating set if the functors `C(G, -)` for `G ∈ 𝒢` are collectively
    faithful, i.e., if `h ≫ f = h ≫ g` for all `h` with domain in `𝒢` implies `f = g`. -/
def IsSeparating (𝒢 : Set C) : Prop :=
  ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ G ∈ 𝒢, ∀ (h : G ⟶ X), h ≫ f = h ≫ g) → f = g
#align category_theory.is_separating CategoryTheory.IsSeparating
-/

#print CategoryTheory.IsCoseparating /-
/-- We say that `𝒢` is a coseparating set if the functors `C(-, G)` for `G ∈ 𝒢` are collectively
    faithful, i.e., if `f ≫ h = g ≫ h` for all `h` with codomain in `𝒢` implies `f = g`. -/
def IsCoseparating (𝒢 : Set C) : Prop :=
  ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ G ∈ 𝒢, ∀ (h : Y ⟶ G), f ≫ h = g ≫ h) → f = g
#align category_theory.is_coseparating CategoryTheory.IsCoseparating
-/

#print CategoryTheory.IsDetecting /-
/-- We say that `𝒢` is a detecting set if the functors `C(G, -)` collectively reflect isomorphisms,
    i.e., if any `h` with domain in `𝒢` uniquely factors through `f`, then `f` is an isomorphism. -/
def IsDetecting (𝒢 : Set C) : Prop :=
  ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ G ∈ 𝒢, ∀ (h : G ⟶ Y), ∃! h' : G ⟶ X, h' ≫ f = h) → IsIso f
#align category_theory.is_detecting CategoryTheory.IsDetecting
-/

#print CategoryTheory.IsCodetecting /-
/-- We say that `𝒢` is a codetecting set if the functors `C(-, G)` collectively reflect
    isomorphisms, i.e., if any `h` with codomain in `G` uniquely factors through `f`, then `f` is
    an isomorphism. -/
def IsCodetecting (𝒢 : Set C) : Prop :=
  ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ G ∈ 𝒢, ∀ (h : X ⟶ G), ∃! h' : Y ⟶ G, f ≫ h' = h) → IsIso f
#align category_theory.is_codetecting CategoryTheory.IsCodetecting
-/

section Dual

#print CategoryTheory.isSeparating_op_iff /-
theorem isSeparating_op_iff (𝒢 : Set C) : IsSeparating 𝒢.op ↔ IsCoseparating 𝒢 :=
  by
  refine' ⟨fun h𝒢 X Y f g hfg => _, fun h𝒢 X Y f g hfg => _⟩
  · refine' Quiver.Hom.op_inj (h𝒢 _ _ fun G hG h => Quiver.Hom.unop_inj _)
    simpa only [unop_comp, Quiver.Hom.unop_op] using hfg _ (Set.mem_op.1 hG) _
  · refine' Quiver.Hom.unop_inj (h𝒢 _ _ fun G hG h => Quiver.Hom.op_inj _)
    simpa only [op_comp, Quiver.Hom.op_unop] using hfg _ (Set.op_mem_op.2 hG) _
#align category_theory.is_separating_op_iff CategoryTheory.isSeparating_op_iff
-/

#print CategoryTheory.isCoseparating_op_iff /-
theorem isCoseparating_op_iff (𝒢 : Set C) : IsCoseparating 𝒢.op ↔ IsSeparating 𝒢 :=
  by
  refine' ⟨fun h𝒢 X Y f g hfg => _, fun h𝒢 X Y f g hfg => _⟩
  · refine' Quiver.Hom.op_inj (h𝒢 _ _ fun G hG h => Quiver.Hom.unop_inj _)
    simpa only [unop_comp, Quiver.Hom.unop_op] using hfg _ (Set.mem_op.1 hG) _
  · refine' Quiver.Hom.unop_inj (h𝒢 _ _ fun G hG h => Quiver.Hom.op_inj _)
    simpa only [op_comp, Quiver.Hom.op_unop] using hfg _ (Set.op_mem_op.2 hG) _
#align category_theory.is_coseparating_op_iff CategoryTheory.isCoseparating_op_iff
-/

#print CategoryTheory.isCoseparating_unop_iff /-
theorem isCoseparating_unop_iff (𝒢 : Set Cᵒᵖ) : IsCoseparating 𝒢.unop ↔ IsSeparating 𝒢 := by
  rw [← is_separating_op_iff, Set.unop_op]
#align category_theory.is_coseparating_unop_iff CategoryTheory.isCoseparating_unop_iff
-/

#print CategoryTheory.isSeparating_unop_iff /-
theorem isSeparating_unop_iff (𝒢 : Set Cᵒᵖ) : IsSeparating 𝒢.unop ↔ IsCoseparating 𝒢 := by
  rw [← is_coseparating_op_iff, Set.unop_op]
#align category_theory.is_separating_unop_iff CategoryTheory.isSeparating_unop_iff
-/

#print CategoryTheory.isDetecting_op_iff /-
theorem isDetecting_op_iff (𝒢 : Set C) : IsDetecting 𝒢.op ↔ IsCodetecting 𝒢 :=
  by
  refine' ⟨fun h𝒢 X Y f hf => _, fun h𝒢 X Y f hf => _⟩
  · refine' (is_iso_op_iff _).1 (h𝒢 _ fun G hG h => _)
    obtain ⟨t, ht, ht'⟩ := hf (unop G) (Set.mem_op.1 hG) h.unop
    exact
      ⟨t.op, Quiver.Hom.unop_inj ht, fun y hy => Quiver.Hom.unop_inj (ht' _ (Quiver.Hom.op_inj hy))⟩
  · refine' (is_iso_unop_iff _).1 (h𝒢 _ fun G hG h => _)
    obtain ⟨t, ht, ht'⟩ := hf (op G) (Set.op_mem_op.2 hG) h.op
    refine' ⟨t.unop, Quiver.Hom.op_inj ht, fun y hy => Quiver.Hom.op_inj (ht' _ _)⟩
    exact Quiver.Hom.unop_inj (by simpa only using hy)
#align category_theory.is_detecting_op_iff CategoryTheory.isDetecting_op_iff
-/

#print CategoryTheory.isCodetecting_op_iff /-
theorem isCodetecting_op_iff (𝒢 : Set C) : IsCodetecting 𝒢.op ↔ IsDetecting 𝒢 :=
  by
  refine' ⟨fun h𝒢 X Y f hf => _, fun h𝒢 X Y f hf => _⟩
  · refine' (is_iso_op_iff _).1 (h𝒢 _ fun G hG h => _)
    obtain ⟨t, ht, ht'⟩ := hf (unop G) (Set.mem_op.1 hG) h.unop
    exact
      ⟨t.op, Quiver.Hom.unop_inj ht, fun y hy => Quiver.Hom.unop_inj (ht' _ (Quiver.Hom.op_inj hy))⟩
  · refine' (is_iso_unop_iff _).1 (h𝒢 _ fun G hG h => _)
    obtain ⟨t, ht, ht'⟩ := hf (op G) (Set.op_mem_op.2 hG) h.op
    refine' ⟨t.unop, Quiver.Hom.op_inj ht, fun y hy => Quiver.Hom.op_inj (ht' _ _)⟩
    exact Quiver.Hom.unop_inj (by simpa only using hy)
#align category_theory.is_codetecting_op_iff CategoryTheory.isCodetecting_op_iff
-/

#print CategoryTheory.isDetecting_unop_iff /-
theorem isDetecting_unop_iff (𝒢 : Set Cᵒᵖ) : IsDetecting 𝒢.unop ↔ IsCodetecting 𝒢 := by
  rw [← is_codetecting_op_iff, Set.unop_op]
#align category_theory.is_detecting_unop_iff CategoryTheory.isDetecting_unop_iff
-/

#print CategoryTheory.isCodetecting_unop_iff /-
theorem isCodetecting_unop_iff {𝒢 : Set Cᵒᵖ} : IsCodetecting 𝒢.unop ↔ IsDetecting 𝒢 := by
  rw [← is_detecting_op_iff, Set.unop_op]
#align category_theory.is_codetecting_unop_iff CategoryTheory.isCodetecting_unop_iff
-/

end Dual

#print CategoryTheory.IsDetecting.isSeparating /-
theorem IsDetecting.isSeparating [HasEqualizers C] {𝒢 : Set C} (h𝒢 : IsDetecting 𝒢) :
    IsSeparating 𝒢 := fun X Y f g hfg =>
  have : IsIso (equalizer.ι f g) := h𝒢 _ fun G hG h => equalizer.existsUnique _ (hfg _ hG _)
  eq_of_epi_equalizer
#align category_theory.is_detecting.is_separating CategoryTheory.IsDetecting.isSeparating
-/

section

#print CategoryTheory.IsCodetecting.isCoseparating /-
theorem IsCodetecting.isCoseparating [HasCoequalizers C] {𝒢 : Set C} :
    IsCodetecting 𝒢 → IsCoseparating 𝒢 := by
  simpa only [← is_separating_op_iff, ← is_detecting_op_iff] using is_detecting.is_separating
#align category_theory.is_codetecting.is_coseparating CategoryTheory.IsCodetecting.isCoseparating
-/

end

#print CategoryTheory.IsSeparating.isDetecting /-
theorem IsSeparating.isDetecting [Balanced C] {𝒢 : Set C} (h𝒢 : IsSeparating 𝒢) : IsDetecting 𝒢 :=
  by
  intro X Y f hf
  refine'
    (is_iso_iff_mono_and_epi _).2 ⟨⟨fun Z g h hgh => h𝒢 _ _ fun G hG i => _⟩, ⟨fun Z g h hgh => _⟩⟩
  · obtain ⟨t, -, ht⟩ := hf G hG (i ≫ g ≫ f)
    rw [ht (i ≫ g) (category.assoc _ _ _), ht (i ≫ h) (hgh.symm ▸ category.assoc _ _ _)]
  · refine' h𝒢 _ _ fun G hG i => _
    obtain ⟨t, rfl, -⟩ := hf G hG i
    rw [category.assoc, hgh, category.assoc]
#align category_theory.is_separating.is_detecting CategoryTheory.IsSeparating.isDetecting
-/

section

attribute [local instance] balanced_opposite

#print CategoryTheory.IsCoseparating.isCodetecting /-
theorem IsCoseparating.isCodetecting [Balanced C] {𝒢 : Set C} :
    IsCoseparating 𝒢 → IsCodetecting 𝒢 := by
  simpa only [← is_detecting_op_iff, ← is_separating_op_iff] using is_separating.is_detecting
#align category_theory.is_coseparating.is_codetecting CategoryTheory.IsCoseparating.isCodetecting
-/

end

#print CategoryTheory.isDetecting_iff_isSeparating /-
theorem isDetecting_iff_isSeparating [HasEqualizers C] [Balanced C] (𝒢 : Set C) :
    IsDetecting 𝒢 ↔ IsSeparating 𝒢 :=
  ⟨IsDetecting.isSeparating, IsSeparating.isDetecting⟩
#align category_theory.is_detecting_iff_is_separating CategoryTheory.isDetecting_iff_isSeparating
-/

#print CategoryTheory.isCodetecting_iff_isCoseparating /-
theorem isCodetecting_iff_isCoseparating [HasCoequalizers C] [Balanced C] {𝒢 : Set C} :
    IsCodetecting 𝒢 ↔ IsCoseparating 𝒢 :=
  ⟨IsCodetecting.isCoseparating, IsCoseparating.isCodetecting⟩
#align category_theory.is_codetecting_iff_is_coseparating CategoryTheory.isCodetecting_iff_isCoseparating
-/

section Mono

#print CategoryTheory.IsSeparating.mono /-
theorem IsSeparating.mono {𝒢 : Set C} (h𝒢 : IsSeparating 𝒢) {ℋ : Set C} (h𝒢ℋ : 𝒢 ⊆ ℋ) :
    IsSeparating ℋ := fun X Y f g hfg => h𝒢 _ _ fun G hG h => hfg _ (h𝒢ℋ hG) _
#align category_theory.is_separating.mono CategoryTheory.IsSeparating.mono
-/

#print CategoryTheory.IsCoseparating.mono /-
theorem IsCoseparating.mono {𝒢 : Set C} (h𝒢 : IsCoseparating 𝒢) {ℋ : Set C} (h𝒢ℋ : 𝒢 ⊆ ℋ) :
    IsCoseparating ℋ := fun X Y f g hfg => h𝒢 _ _ fun G hG h => hfg _ (h𝒢ℋ hG) _
#align category_theory.is_coseparating.mono CategoryTheory.IsCoseparating.mono
-/

#print CategoryTheory.IsDetecting.mono /-
theorem IsDetecting.mono {𝒢 : Set C} (h𝒢 : IsDetecting 𝒢) {ℋ : Set C} (h𝒢ℋ : 𝒢 ⊆ ℋ) :
    IsDetecting ℋ := fun X Y f hf => h𝒢 _ fun G hG h => hf _ (h𝒢ℋ hG) _
#align category_theory.is_detecting.mono CategoryTheory.IsDetecting.mono
-/

#print CategoryTheory.IsCodetecting.mono /-
theorem IsCodetecting.mono {𝒢 : Set C} (h𝒢 : IsCodetecting 𝒢) {ℋ : Set C} (h𝒢ℋ : 𝒢 ⊆ ℋ) :
    IsCodetecting ℋ := fun X Y f hf => h𝒢 _ fun G hG h => hf _ (h𝒢ℋ hG) _
#align category_theory.is_codetecting.mono CategoryTheory.IsCodetecting.mono
-/

end Mono

section Empty

#print CategoryTheory.thin_of_isSeparating_empty /-
theorem thin_of_isSeparating_empty (h : IsSeparating (∅ : Set C)) : Quiver.IsThin C := fun _ _ =>
  ⟨fun f g => h _ _ fun G => False.elim⟩
#align category_theory.thin_of_is_separating_empty CategoryTheory.thin_of_isSeparating_empty
-/

#print CategoryTheory.isSeparating_empty_of_thin /-
theorem isSeparating_empty_of_thin [Quiver.IsThin C] : IsSeparating (∅ : Set C) :=
  fun X Y f g hfg => Subsingleton.elim _ _
#align category_theory.is_separating_empty_of_thin CategoryTheory.isSeparating_empty_of_thin
-/

#print CategoryTheory.thin_of_isCoseparating_empty /-
theorem thin_of_isCoseparating_empty (h : IsCoseparating (∅ : Set C)) : Quiver.IsThin C :=
  fun _ _ => ⟨fun f g => h _ _ fun G => False.elim⟩
#align category_theory.thin_of_is_coseparating_empty CategoryTheory.thin_of_isCoseparating_empty
-/

#print CategoryTheory.isCoseparating_empty_of_thin /-
theorem isCoseparating_empty_of_thin [Quiver.IsThin C] : IsCoseparating (∅ : Set C) :=
  fun X Y f g hfg => Subsingleton.elim _ _
#align category_theory.is_coseparating_empty_of_thin CategoryTheory.isCoseparating_empty_of_thin
-/

#print CategoryTheory.groupoid_of_isDetecting_empty /-
theorem groupoid_of_isDetecting_empty (h : IsDetecting (∅ : Set C)) {X Y : C} (f : X ⟶ Y) :
    IsIso f :=
  h _ fun G => False.elim
#align category_theory.groupoid_of_is_detecting_empty CategoryTheory.groupoid_of_isDetecting_empty
-/

#print CategoryTheory.isDetecting_empty_of_groupoid /-
theorem isDetecting_empty_of_groupoid [∀ {X Y : C} (f : X ⟶ Y), IsIso f] :
    IsDetecting (∅ : Set C) := fun X Y f hf => inferInstance
#align category_theory.is_detecting_empty_of_groupoid CategoryTheory.isDetecting_empty_of_groupoid
-/

#print CategoryTheory.groupoid_of_isCodetecting_empty /-
theorem groupoid_of_isCodetecting_empty (h : IsCodetecting (∅ : Set C)) {X Y : C} (f : X ⟶ Y) :
    IsIso f :=
  h _ fun G => False.elim
#align category_theory.groupoid_of_is_codetecting_empty CategoryTheory.groupoid_of_isCodetecting_empty
-/

#print CategoryTheory.isCodetecting_empty_of_groupoid /-
theorem isCodetecting_empty_of_groupoid [∀ {X Y : C} (f : X ⟶ Y), IsIso f] :
    IsCodetecting (∅ : Set C) := fun X Y f hf => inferInstance
#align category_theory.is_codetecting_empty_of_groupoid CategoryTheory.isCodetecting_empty_of_groupoid
-/

end Empty

#print CategoryTheory.isSeparating_iff_epi /-
theorem isSeparating_iff_epi (𝒢 : Set C)
    [∀ A : C, HasCoproduct fun f : Σ G : 𝒢, (G : C) ⟶ A => (f.1 : C)] :
    IsSeparating 𝒢 ↔ ∀ A : C, Epi (Sigma.desc (@Sigma.snd 𝒢 fun G => (G : C) ⟶ A)) :=
  by
  refine' ⟨fun h A => ⟨fun Z u v huv => h _ _ fun G hG f => _⟩, fun h X Y f g hh => _⟩
  · simpa using sigma.ι (fun f : Σ G : 𝒢, (G : C) ⟶ A => (f.1 : C)) ⟨⟨G, hG⟩, f⟩ ≫= huv
  · haveI := h X
    refine'
      (cancel_epi (sigma.desc (@Sigma.snd 𝒢 fun G => (G : C) ⟶ X))).1 (colimit.hom_ext fun j => _)
    simpa using hh j.as.1.1 j.as.1.2 j.as.2
#align category_theory.is_separating_iff_epi CategoryTheory.isSeparating_iff_epi
-/

#print CategoryTheory.isCoseparating_iff_mono /-
theorem isCoseparating_iff_mono (𝒢 : Set C)
    [∀ A : C, HasProduct fun f : Σ G : 𝒢, A ⟶ (G : C) => (f.1 : C)] :
    IsCoseparating 𝒢 ↔ ∀ A : C, Mono (Pi.lift (@Sigma.snd 𝒢 fun G => A ⟶ (G : C))) :=
  by
  refine' ⟨fun h A => ⟨fun Z u v huv => h _ _ fun G hG f => _⟩, fun h X Y f g hh => _⟩
  · simpa using huv =≫ pi.π (fun f : Σ G : 𝒢, A ⟶ (G : C) => (f.1 : C)) ⟨⟨G, hG⟩, f⟩
  · haveI := h Y
    refine' (cancel_mono (pi.lift (@Sigma.snd 𝒢 fun G => Y ⟶ (G : C)))).1 (limit.hom_ext fun j => _)
    simpa using hh j.as.1.1 j.as.1.2 j.as.2
#align category_theory.is_coseparating_iff_mono CategoryTheory.isCoseparating_iff_mono
-/

#print CategoryTheory.hasInitial_of_isCoseparating /-
/-- An ingredient of the proof of the Special Adjoint Functor Theorem: a complete well-powered
    category with a small coseparating set has an initial object.

    In fact, it follows from the Special Adjoint Functor Theorem that `C` is already cocomplete,
    see `has_colimits_of_has_limits_of_is_coseparating`. -/
theorem hasInitial_of_isCoseparating [WellPowered C] [HasLimits C] {𝒢 : Set C} [Small.{v₁} 𝒢]
    (h𝒢 : IsCoseparating 𝒢) : HasInitial C :=
  by
  haveI := has_products_of_shape_of_small C 𝒢
  haveI := fun A => hasProductsOfShape_of_small.{v₁} C (Σ G : 𝒢, A ⟶ (G : C))
  letI := completeLatticeOfCompleteSemilatticeInf (subobject (pi_obj (coe : 𝒢 → C)))
  suffices ∀ A : C, Unique (((⊥ : subobject (pi_obj (coe : 𝒢 → C))) : C) ⟶ A) by
    exact has_initial_of_unique ((⊥ : subobject (pi_obj (coe : 𝒢 → C))) : C)
  refine' fun A => ⟨⟨_⟩, fun f => _⟩
  · let s := pi.lift fun f : Σ G : 𝒢, A ⟶ (G : C) => id (pi.π (coe : 𝒢 → C)) f.1
    let t := pi.lift (@Sigma.snd 𝒢 fun G => A ⟶ (G : C))
    haveI : mono t := (is_coseparating_iff_mono 𝒢).1 h𝒢 A
    exact subobject.of_le_mk _ (pullback.fst : pullback s t ⟶ _) bot_le ≫ pullback.snd
  · generalize default = g
    suffices is_split_epi (equalizer.ι f g) by exact eq_of_epi_equalizer
    exact
      is_split_epi.mk'
        ⟨subobject.of_le_mk _ (equalizer.ι f g ≫ subobject.arrow _) bot_le, by ext; simp⟩
#align category_theory.has_initial_of_is_coseparating CategoryTheory.hasInitial_of_isCoseparating
-/

#print CategoryTheory.hasTerminal_of_isSeparating /-
/-- An ingredient of the proof of the Special Adjoint Functor Theorem: a cocomplete well-copowered
    category with a small separating set has a terminal object.

    In fact, it follows from the Special Adjoint Functor Theorem that `C` is already complete, see
    `has_limits_of_has_colimits_of_is_separating`. -/
theorem hasTerminal_of_isSeparating [WellPowered Cᵒᵖ] [HasColimits C] {𝒢 : Set C} [Small.{v₁} 𝒢]
    (h𝒢 : IsSeparating 𝒢) : HasTerminal C :=
  by
  haveI : Small.{v₁} 𝒢.op := small_of_injective (Set.opEquiv_self 𝒢).Injective
  haveI : has_initial Cᵒᵖ := has_initial_of_is_coseparating ((is_coseparating_op_iff _).2 h𝒢)
  exact has_terminal_of_has_initial_op
#align category_theory.has_terminal_of_is_separating CategoryTheory.hasTerminal_of_isSeparating
-/

section WellPowered

namespace Subobject

#print CategoryTheory.Subobject.eq_of_le_of_isDetecting /-
theorem eq_of_le_of_isDetecting {𝒢 : Set C} (h𝒢 : IsDetecting 𝒢) {X : C} (P Q : Subobject X)
    (h₁ : P ≤ Q) (h₂ : ∀ G ∈ 𝒢, ∀ {f : G ⟶ X}, Q.Factors f → P.Factors f) : P = Q :=
  by
  suffices is_iso (of_le _ _ h₁) by exact le_antisymm h₁ (le_of_comm (inv (of_le _ _ h₁)) (by simp))
  refine' h𝒢 _ fun G hG f => _
  have : P.factors (f ≫ Q.arrow) := h₂ _ hG ((factors_iff _ _).2 ⟨_, rfl⟩)
  refine' ⟨factor_thru _ _ this, _, fun g (hg : g ≫ _ = f) => _⟩
  · simp only [← cancel_mono Q.arrow, category.assoc, of_le_arrow, factor_thru_arrow]
  ·
    simp only [← cancel_mono (subobject.of_le _ _ h₁), ← cancel_mono Q.arrow, hg, category.assoc,
      of_le_arrow, factor_thru_arrow]
#align category_theory.subobject.eq_of_le_of_is_detecting CategoryTheory.Subobject.eq_of_le_of_isDetecting
-/

#print CategoryTheory.Subobject.inf_eq_of_isDetecting /-
theorem inf_eq_of_isDetecting [HasPullbacks C] {𝒢 : Set C} (h𝒢 : IsDetecting 𝒢) {X : C}
    (P Q : Subobject X) (h : ∀ G ∈ 𝒢, ∀ {f : G ⟶ X}, P.Factors f → Q.Factors f) : P ⊓ Q = P :=
  eq_of_le_of_isDetecting h𝒢 _ _ inf_le_left fun G hG f hf => (inf_factors _).2 ⟨hf, h _ hG hf⟩
#align category_theory.subobject.inf_eq_of_is_detecting CategoryTheory.Subobject.inf_eq_of_isDetecting
-/

#print CategoryTheory.Subobject.eq_of_isDetecting /-
theorem eq_of_isDetecting [HasPullbacks C] {𝒢 : Set C} (h𝒢 : IsDetecting 𝒢) {X : C}
    (P Q : Subobject X) (h : ∀ G ∈ 𝒢, ∀ {f : G ⟶ X}, P.Factors f ↔ Q.Factors f) : P = Q :=
  calc
    P = P ⊓ Q := Eq.symm <| inf_eq_of_isDetecting h𝒢 _ _ fun G hG f hf => (h G hG).1 hf
    _ = Q ⊓ P := inf_comm
    _ = Q := inf_eq_of_isDetecting h𝒢 _ _ fun G hG f hf => (h G hG).2 hf
#align category_theory.subobject.eq_of_is_detecting CategoryTheory.Subobject.eq_of_isDetecting
-/

end Subobject

#print CategoryTheory.wellPowered_of_isDetecting /-
/-- A category with pullbacks and a small detecting set is well-powered. -/
theorem wellPowered_of_isDetecting [HasPullbacks C] {𝒢 : Set C} [Small.{v₁} 𝒢]
    (h𝒢 : IsDetecting 𝒢) : WellPowered C :=
  ⟨fun X =>
    @small_of_injective _ _ _ (fun P : Subobject X => {f : Σ G : 𝒢, G.1 ⟶ X | P.Factors f.2})
      fun P Q h => Subobject.eq_of_isDetecting h𝒢 _ _ (by simpa [Set.ext_iff] using h)⟩
#align category_theory.well_powered_of_is_detecting CategoryTheory.wellPowered_of_isDetecting
-/

end WellPowered

namespace StructuredArrow

variable (S : D) (T : C ⥤ D)

#print CategoryTheory.StructuredArrow.isCoseparating_proj_preimage /-
theorem isCoseparating_proj_preimage {𝒢 : Set C} (h𝒢 : IsCoseparating 𝒢) :
    IsCoseparating ((proj S T).obj ⁻¹' 𝒢) :=
  by
  refine' fun X Y f g hfg => ext _ _ (h𝒢 _ _ fun G hG h => _)
  exact congr_arg comma_morphism.right (hfg (mk (Y.hom ≫ T.map h)) hG (hom_mk h rfl))
#align category_theory.structured_arrow.is_coseparating_proj_preimage CategoryTheory.StructuredArrow.isCoseparating_proj_preimage
-/

end StructuredArrow

namespace CostructuredArrow

variable (S : C ⥤ D) (T : D)

#print CategoryTheory.CostructuredArrow.isSeparating_proj_preimage /-
theorem isSeparating_proj_preimage {𝒢 : Set C} (h𝒢 : IsSeparating 𝒢) :
    IsSeparating ((proj S T).obj ⁻¹' 𝒢) :=
  by
  refine' fun X Y f g hfg => ext _ _ (h𝒢 _ _ fun G hG h => _)
  convert congr_arg comma_morphism.left (hfg (mk (S.map h ≫ X.hom)) hG (hom_mk h rfl))
#align category_theory.costructured_arrow.is_separating_proj_preimage CategoryTheory.CostructuredArrow.isSeparating_proj_preimage
-/

end CostructuredArrow

#print CategoryTheory.IsSeparator /-
/-- We say that `G` is a separator if the functor `C(G, -)` is faithful. -/
def IsSeparator (G : C) : Prop :=
  IsSeparating ({G} : Set C)
#align category_theory.is_separator CategoryTheory.IsSeparator
-/

#print CategoryTheory.IsCoseparator /-
/-- We say that `G` is a coseparator if the functor `C(-, G)` is faithful. -/
def IsCoseparator (G : C) : Prop :=
  IsCoseparating ({G} : Set C)
#align category_theory.is_coseparator CategoryTheory.IsCoseparator
-/

#print CategoryTheory.IsDetector /-
/-- We say that `G` is a detector if the functor `C(G, -)` reflects isomorphisms. -/
def IsDetector (G : C) : Prop :=
  IsDetecting ({G} : Set C)
#align category_theory.is_detector CategoryTheory.IsDetector
-/

#print CategoryTheory.IsCodetector /-
/-- We say that `G` is a codetector if the functor `C(-, G)` reflects isomorphisms. -/
def IsCodetector (G : C) : Prop :=
  IsCodetecting ({G} : Set C)
#align category_theory.is_codetector CategoryTheory.IsCodetector
-/

section Dual

#print CategoryTheory.isSeparator_op_iff /-
theorem isSeparator_op_iff (G : C) : IsSeparator (op G) ↔ IsCoseparator G := by
  rw [is_separator, is_coseparator, ← is_separating_op_iff, Set.singleton_op]
#align category_theory.is_separator_op_iff CategoryTheory.isSeparator_op_iff
-/

#print CategoryTheory.isCoseparator_op_iff /-
theorem isCoseparator_op_iff (G : C) : IsCoseparator (op G) ↔ IsSeparator G := by
  rw [is_separator, is_coseparator, ← is_coseparating_op_iff, Set.singleton_op]
#align category_theory.is_coseparator_op_iff CategoryTheory.isCoseparator_op_iff
-/

#print CategoryTheory.isCoseparator_unop_iff /-
theorem isCoseparator_unop_iff (G : Cᵒᵖ) : IsCoseparator (unop G) ↔ IsSeparator G := by
  rw [is_separator, is_coseparator, ← is_coseparating_unop_iff, Set.singleton_unop]
#align category_theory.is_coseparator_unop_iff CategoryTheory.isCoseparator_unop_iff
-/

#print CategoryTheory.isSeparator_unop_iff /-
theorem isSeparator_unop_iff (G : Cᵒᵖ) : IsSeparator (unop G) ↔ IsCoseparator G := by
  rw [is_separator, is_coseparator, ← is_separating_unop_iff, Set.singleton_unop]
#align category_theory.is_separator_unop_iff CategoryTheory.isSeparator_unop_iff
-/

#print CategoryTheory.isDetector_op_iff /-
theorem isDetector_op_iff (G : C) : IsDetector (op G) ↔ IsCodetector G := by
  rw [is_detector, is_codetector, ← is_detecting_op_iff, Set.singleton_op]
#align category_theory.is_detector_op_iff CategoryTheory.isDetector_op_iff
-/

#print CategoryTheory.isCodetector_op_iff /-
theorem isCodetector_op_iff (G : C) : IsCodetector (op G) ↔ IsDetector G := by
  rw [is_detector, is_codetector, ← is_codetecting_op_iff, Set.singleton_op]
#align category_theory.is_codetector_op_iff CategoryTheory.isCodetector_op_iff
-/

#print CategoryTheory.isCodetector_unop_iff /-
theorem isCodetector_unop_iff (G : Cᵒᵖ) : IsCodetector (unop G) ↔ IsDetector G := by
  rw [is_detector, is_codetector, ← is_codetecting_unop_iff, Set.singleton_unop]
#align category_theory.is_codetector_unop_iff CategoryTheory.isCodetector_unop_iff
-/

#print CategoryTheory.isDetector_unop_iff /-
theorem isDetector_unop_iff (G : Cᵒᵖ) : IsDetector (unop G) ↔ IsCodetector G := by
  rw [is_detector, is_codetector, ← is_detecting_unop_iff, Set.singleton_unop]
#align category_theory.is_detector_unop_iff CategoryTheory.isDetector_unop_iff
-/

end Dual

#print CategoryTheory.IsDetector.isSeparator /-
theorem IsDetector.isSeparator [HasEqualizers C] {G : C} : IsDetector G → IsSeparator G :=
  IsDetecting.isSeparating
#align category_theory.is_detector.is_separator CategoryTheory.IsDetector.isSeparator
-/

#print CategoryTheory.IsCodetector.isCoseparator /-
theorem IsCodetector.isCoseparator [HasCoequalizers C] {G : C} : IsCodetector G → IsCoseparator G :=
  IsCodetecting.isCoseparating
#align category_theory.is_codetector.is_coseparator CategoryTheory.IsCodetector.isCoseparator
-/

#print CategoryTheory.IsSeparator.isDetector /-
theorem IsSeparator.isDetector [Balanced C] {G : C} : IsSeparator G → IsDetector G :=
  IsSeparating.isDetecting
#align category_theory.is_separator.is_detector CategoryTheory.IsSeparator.isDetector
-/

#print CategoryTheory.IsCospearator.isCodetector /-
theorem IsCospearator.isCodetector [Balanced C] {G : C} : IsCoseparator G → IsCodetector G :=
  IsCoseparating.isCodetecting
#align category_theory.is_cospearator.is_codetector CategoryTheory.IsCospearator.isCodetector
-/

#print CategoryTheory.isSeparator_def /-
theorem isSeparator_def (G : C) :
    IsSeparator G ↔ ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ h : G ⟶ X, h ≫ f = h ≫ g) → f = g :=
  ⟨fun hG X Y f g hfg =>
    hG _ _ fun H hH h => by obtain rfl := Set.mem_singleton_iff.1 hH; exact hfg h,
    fun hG X Y f g hfg => hG _ _ fun h => hfg _ (Set.mem_singleton _) _⟩
#align category_theory.is_separator_def CategoryTheory.isSeparator_def
-/

#print CategoryTheory.IsSeparator.def /-
theorem IsSeparator.def {G : C} :
    IsSeparator G → ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ h : G ⟶ X, h ≫ f = h ≫ g) → f = g :=
  (isSeparator_def _).1
#align category_theory.is_separator.def CategoryTheory.IsSeparator.def
-/

#print CategoryTheory.isCoseparator_def /-
theorem isCoseparator_def (G : C) :
    IsCoseparator G ↔ ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ h : Y ⟶ G, f ≫ h = g ≫ h) → f = g :=
  ⟨fun hG X Y f g hfg =>
    hG _ _ fun H hH h => by obtain rfl := Set.mem_singleton_iff.1 hH; exact hfg h,
    fun hG X Y f g hfg => hG _ _ fun h => hfg _ (Set.mem_singleton _) _⟩
#align category_theory.is_coseparator_def CategoryTheory.isCoseparator_def
-/

#print CategoryTheory.IsCoseparator.def /-
theorem IsCoseparator.def {G : C} :
    IsCoseparator G → ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ h : Y ⟶ G, f ≫ h = g ≫ h) → f = g :=
  (isCoseparator_def _).1
#align category_theory.is_coseparator.def CategoryTheory.IsCoseparator.def
-/

#print CategoryTheory.isDetector_def /-
theorem isDetector_def (G : C) :
    IsDetector G ↔ ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ h : G ⟶ Y, ∃! h', h' ≫ f = h) → IsIso f :=
  ⟨fun hG X Y f hf => hG _ fun H hH h => by obtain rfl := Set.mem_singleton_iff.1 hH; exact hf h,
    fun hG X Y f hf => hG _ fun h => hf _ (Set.mem_singleton _) _⟩
#align category_theory.is_detector_def CategoryTheory.isDetector_def
-/

#print CategoryTheory.IsDetector.def /-
theorem IsDetector.def {G : C} :
    IsDetector G → ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ h : G ⟶ Y, ∃! h', h' ≫ f = h) → IsIso f :=
  (isDetector_def _).1
#align category_theory.is_detector.def CategoryTheory.IsDetector.def
-/

#print CategoryTheory.isCodetector_def /-
theorem isCodetector_def (G : C) :
    IsCodetector G ↔ ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ h : X ⟶ G, ∃! h', f ≫ h' = h) → IsIso f :=
  ⟨fun hG X Y f hf => hG _ fun H hH h => by obtain rfl := Set.mem_singleton_iff.1 hH; exact hf h,
    fun hG X Y f hf => hG _ fun h => hf _ (Set.mem_singleton _) _⟩
#align category_theory.is_codetector_def CategoryTheory.isCodetector_def
-/

#print CategoryTheory.IsCodetector.def /-
theorem IsCodetector.def {G : C} :
    IsCodetector G → ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ h : X ⟶ G, ∃! h', f ≫ h' = h) → IsIso f :=
  (isCodetector_def _).1
#align category_theory.is_codetector.def CategoryTheory.IsCodetector.def
-/

#print CategoryTheory.isSeparator_iff_faithful_coyoneda_obj /-
theorem isSeparator_iff_faithful_coyoneda_obj (G : C) :
    IsSeparator G ↔ Faithful (coyoneda.obj (op G)) :=
  ⟨fun hG => ⟨fun X Y f g hfg => hG.def _ _ (congr_fun hfg)⟩, fun h =>
    (isSeparator_def _).2 fun X Y f g hfg => (coyoneda.obj (op G)).map_injective (funext hfg)⟩
#align category_theory.is_separator_iff_faithful_coyoneda_obj CategoryTheory.isSeparator_iff_faithful_coyoneda_obj
-/

#print CategoryTheory.isCoseparator_iff_faithful_yoneda_obj /-
theorem isCoseparator_iff_faithful_yoneda_obj (G : C) : IsCoseparator G ↔ Faithful (yoneda.obj G) :=
  ⟨fun hG => ⟨fun X Y f g hfg => Quiver.Hom.unop_inj (hG.def _ _ (congr_fun hfg))⟩, fun h =>
    (isCoseparator_def _).2 fun X Y f g hfg =>
      Quiver.Hom.op_inj <| (yoneda.obj G).map_injective (funext hfg)⟩
#align category_theory.is_coseparator_iff_faithful_yoneda_obj CategoryTheory.isCoseparator_iff_faithful_yoneda_obj
-/

#print CategoryTheory.isSeparator_iff_epi /-
theorem isSeparator_iff_epi (G : C) [∀ A : C, HasCoproduct fun f : G ⟶ A => G] :
    IsSeparator G ↔ ∀ A : C, Epi (Sigma.desc fun f : G ⟶ A => f) :=
  by
  rw [is_separator_def]
  refine' ⟨fun h A => ⟨fun Z u v huv => h _ _ fun i => _⟩, fun h X Y f g hh => _⟩
  · simpa using sigma.ι _ i ≫= huv
  · haveI := h X
    refine' (cancel_epi (sigma.desc fun f : G ⟶ X => f)).1 (colimit.hom_ext fun j => _)
    simpa using hh j.as
#align category_theory.is_separator_iff_epi CategoryTheory.isSeparator_iff_epi
-/

#print CategoryTheory.isCoseparator_iff_mono /-
theorem isCoseparator_iff_mono (G : C) [∀ A : C, HasProduct fun f : A ⟶ G => G] :
    IsCoseparator G ↔ ∀ A : C, Mono (Pi.lift fun f : A ⟶ G => f) :=
  by
  rw [is_coseparator_def]
  refine' ⟨fun h A => ⟨fun Z u v huv => h _ _ fun i => _⟩, fun h X Y f g hh => _⟩
  · simpa using huv =≫ pi.π _ i
  · haveI := h Y
    refine' (cancel_mono (pi.lift fun f : Y ⟶ G => f)).1 (limit.hom_ext fun j => _)
    simpa using hh j.as
#align category_theory.is_coseparator_iff_mono CategoryTheory.isCoseparator_iff_mono
-/

section ZeroMorphisms

variable [HasZeroMorphisms C]

#print CategoryTheory.isSeparator_coprod /-
theorem isSeparator_coprod (G H : C) [HasBinaryCoproduct G H] :
    IsSeparator (G ⨿ H) ↔ IsSeparating ({G, H} : Set C) :=
  by
  refine'
    ⟨fun h X Y u v huv => _, fun h =>
      (is_separator_def _).2 fun X Y u v huv => h _ _ fun Z hZ g => _⟩
  · refine' h.def _ _ fun g => coprod.hom_ext _ _
    · simpa using huv G (by simp) (coprod.inl ≫ g)
    · simpa using huv H (by simp) (coprod.inr ≫ g)
  · simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hZ 
    rcases hZ with (rfl | rfl)
    · simpa using coprod.inl ≫= huv (coprod.desc g 0)
    · simpa using coprod.inr ≫= huv (coprod.desc 0 g)
#align category_theory.is_separator_coprod CategoryTheory.isSeparator_coprod
-/

#print CategoryTheory.isSeparator_coprod_of_isSeparator_left /-
theorem isSeparator_coprod_of_isSeparator_left (G H : C) [HasBinaryCoproduct G H]
    (hG : IsSeparator G) : IsSeparator (G ⨿ H) :=
  (isSeparator_coprod _ _).2 <| IsSeparating.mono hG <| by simp
#align category_theory.is_separator_coprod_of_is_separator_left CategoryTheory.isSeparator_coprod_of_isSeparator_left
-/

#print CategoryTheory.isSeparator_coprod_of_isSeparator_right /-
theorem isSeparator_coprod_of_isSeparator_right (G H : C) [HasBinaryCoproduct G H]
    (hH : IsSeparator H) : IsSeparator (G ⨿ H) :=
  (isSeparator_coprod _ _).2 <| IsSeparating.mono hH <| by simp
#align category_theory.is_separator_coprod_of_is_separator_right CategoryTheory.isSeparator_coprod_of_isSeparator_right
-/

#print CategoryTheory.isSeparator_sigma /-
theorem isSeparator_sigma {β : Type w} (f : β → C) [HasCoproduct f] :
    IsSeparator (∐ f) ↔ IsSeparating (Set.range f) :=
  by
  refine'
    ⟨fun h X Y u v huv => _, fun h =>
      (is_separator_def _).2 fun X Y u v huv => h _ _ fun Z hZ g => _⟩
  · refine' h.def _ _ fun g => colimit.hom_ext fun b => _
    simpa using huv (f b.as) (by simp) (colimit.ι (discrete.functor f) _ ≫ g)
  · obtain ⟨b, rfl⟩ := Set.mem_range.1 hZ
    classical simpa using sigma.ι f b ≫= huv (sigma.desc (Pi.single b g))
#align category_theory.is_separator_sigma CategoryTheory.isSeparator_sigma
-/

#print CategoryTheory.isSeparator_sigma_of_isSeparator /-
theorem isSeparator_sigma_of_isSeparator {β : Type w} (f : β → C) [HasCoproduct f] (b : β)
    (hb : IsSeparator (f b)) : IsSeparator (∐ f) :=
  (isSeparator_sigma _).2 <| IsSeparating.mono hb <| by simp
#align category_theory.is_separator_sigma_of_is_separator CategoryTheory.isSeparator_sigma_of_isSeparator
-/

#print CategoryTheory.isCoseparator_prod /-
theorem isCoseparator_prod (G H : C) [HasBinaryProduct G H] :
    IsCoseparator (G ⨯ H) ↔ IsCoseparating ({G, H} : Set C) :=
  by
  refine'
    ⟨fun h X Y u v huv => _, fun h =>
      (is_coseparator_def _).2 fun X Y u v huv => h _ _ fun Z hZ g => _⟩
  · refine' h.def _ _ fun g => prod.hom_ext _ _
    · simpa using huv G (by simp) (g ≫ limits.prod.fst)
    · simpa using huv H (by simp) (g ≫ limits.prod.snd)
  · simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hZ 
    rcases hZ with (rfl | rfl)
    · simpa using huv (prod.lift g 0) =≫ limits.prod.fst
    · simpa using huv (prod.lift 0 g) =≫ limits.prod.snd
#align category_theory.is_coseparator_prod CategoryTheory.isCoseparator_prod
-/

#print CategoryTheory.isCoseparator_prod_of_isCoseparator_left /-
theorem isCoseparator_prod_of_isCoseparator_left (G H : C) [HasBinaryProduct G H]
    (hG : IsCoseparator G) : IsCoseparator (G ⨯ H) :=
  (isCoseparator_prod _ _).2 <| IsCoseparating.mono hG <| by simp
#align category_theory.is_coseparator_prod_of_is_coseparator_left CategoryTheory.isCoseparator_prod_of_isCoseparator_left
-/

#print CategoryTheory.isCoseparator_prod_of_isCoseparator_right /-
theorem isCoseparator_prod_of_isCoseparator_right (G H : C) [HasBinaryProduct G H]
    (hH : IsCoseparator H) : IsCoseparator (G ⨯ H) :=
  (isCoseparator_prod _ _).2 <| IsCoseparating.mono hH <| by simp
#align category_theory.is_coseparator_prod_of_is_coseparator_right CategoryTheory.isCoseparator_prod_of_isCoseparator_right
-/

#print CategoryTheory.isCoseparator_pi /-
theorem isCoseparator_pi {β : Type w} (f : β → C) [HasProduct f] :
    IsCoseparator (∏ f) ↔ IsCoseparating (Set.range f) :=
  by
  refine'
    ⟨fun h X Y u v huv => _, fun h =>
      (is_coseparator_def _).2 fun X Y u v huv => h _ _ fun Z hZ g => _⟩
  · refine' h.def _ _ fun g => limit.hom_ext fun b => _
    simpa using huv (f b.as) (by simp) (g ≫ limit.π (discrete.functor f) _)
  · obtain ⟨b, rfl⟩ := Set.mem_range.1 hZ
    classical simpa using huv (pi.lift (Pi.single b g)) =≫ pi.π f b
#align category_theory.is_coseparator_pi CategoryTheory.isCoseparator_pi
-/

#print CategoryTheory.isCoseparator_pi_of_isCoseparator /-
theorem isCoseparator_pi_of_isCoseparator {β : Type w} (f : β → C) [HasProduct f] (b : β)
    (hb : IsCoseparator (f b)) : IsCoseparator (∏ f) :=
  (isCoseparator_pi _).2 <| IsCoseparating.mono hb <| by simp
#align category_theory.is_coseparator_pi_of_is_coseparator CategoryTheory.isCoseparator_pi_of_isCoseparator
-/

end ZeroMorphisms

#print CategoryTheory.isDetector_iff_reflectsIsomorphisms_coyoneda_obj /-
theorem isDetector_iff_reflectsIsomorphisms_coyoneda_obj (G : C) :
    IsDetector G ↔ ReflectsIsomorphisms (coyoneda.obj (op G)) :=
  by
  refine'
    ⟨fun hG => ⟨fun X Y f hf => hG.def _ fun h => _⟩, fun h =>
      (is_detector_def _).2 fun X Y f hf => _⟩
  · rw [is_iso_iff_bijective, Function.bijective_iff_existsUnique] at hf 
    exact hf h
  · suffices is_iso ((coyoneda.obj (op G)).map f) by
      exact @is_iso_of_reflects_iso _ _ _ _ _ _ _ (coyoneda.obj (op G)) _ h
    rwa [is_iso_iff_bijective, Function.bijective_iff_existsUnique]
#align category_theory.is_detector_iff_reflects_isomorphisms_coyoneda_obj CategoryTheory.isDetector_iff_reflectsIsomorphisms_coyoneda_obj
-/

#print CategoryTheory.isCodetector_iff_reflectsIsomorphisms_yoneda_obj /-
theorem isCodetector_iff_reflectsIsomorphisms_yoneda_obj (G : C) :
    IsCodetector G ↔ ReflectsIsomorphisms (yoneda.obj G) :=
  by
  refine' ⟨fun hG => ⟨fun X Y f hf => _⟩, fun h => (is_codetector_def _).2 fun X Y f hf => _⟩
  · refine' (is_iso_unop_iff _).1 (hG.def _ _)
    rwa [is_iso_iff_bijective, Function.bijective_iff_existsUnique] at hf 
  · rw [← is_iso_op_iff]
    suffices is_iso ((yoneda.obj G).map f.op) by
      exact @is_iso_of_reflects_iso _ _ _ _ _ _ _ (yoneda.obj G) _ h
    rwa [is_iso_iff_bijective, Function.bijective_iff_existsUnique]
#align category_theory.is_codetector_iff_reflects_isomorphisms_yoneda_obj CategoryTheory.isCodetector_iff_reflectsIsomorphisms_yoneda_obj
-/

#print CategoryTheory.wellPowered_of_isDetector /-
theorem wellPowered_of_isDetector [HasPullbacks C] (G : C) (hG : IsDetector G) : WellPowered C :=
  wellPowered_of_isDetecting hG
#align category_theory.well_powered_of_is_detector CategoryTheory.wellPowered_of_isDetector
-/

end CategoryTheory

