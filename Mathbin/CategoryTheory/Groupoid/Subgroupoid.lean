/-
Copyright (c) 2022 Rémi Bottinelli. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémi Bottinelli, Junyan Xu

! This file was ported from Lean 3 source module category_theory.groupoid.subgroupoid
! leanprover-community/mathlib commit 44e2ae8cffc713925494e4975ee31ec1d06929b3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Groupoid.VertexGroup
import Mathbin.CategoryTheory.Groupoid.Basic
import Mathbin.CategoryTheory.Groupoid
import Mathbin.Algebra.Group.Defs
import Mathbin.Data.Set.Lattice
import Mathbin.GroupTheory.Subgroup.Basic
import Mathbin.Order.GaloisConnection

/-!
# Subgroupoid

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines subgroupoids as `structure`s containing the subsets of arrows and their
stability under composition and inversion.
Also defined are:

* containment of subgroupoids is a complete lattice;
* images and preimages of subgroupoids under a functor;
* the notion of normality of subgroupoids and its stability under intersection and preimage;
* compatibility of the above with `groupoid.vertex_group`.


## Main definitions

Given a type `C` with associated `groupoid C` instance.

* `subgroupoid C` is the type of subgroupoids of `C`
* `subgroupoid.is_normal` is the property that the subgroupoid is stable under conjugation
  by arbitrary arrows, _and_ that all identity arrows are contained in the subgroupoid.
* `subgroupoid.comap` is the "preimage" map of subgroupoids along a functor.
* `subgroupoid.map` is the "image" map of subgroupoids along a functor _injective on objects_.
* `subgroupoid.vertex_subgroup` is the subgroup of the `vertex group` at a given vertex `v`,
  assuming `v` is contained in the `subgroupoid` (meaning, by definition, that the arrow `𝟙 v`
  is contained in the subgroupoid).

## Implementation details

The structure of this file is copied from/inspired by `group_theory.subgroup.basic`
and `combinatorics.simple_graph.subgraph`.

## TODO

* Equivalent inductive characterization of generated (normal) subgroupoids.
* Characterization of normal subgroupoids as kernels.
* Prove that `full` and `disconnect` preserve intersections (and `disconnect` also unions)

## Tags

subgroupoid

-/


namespace CategoryTheory

open Set Groupoid

attribute [local protected] CategoryTheory.inv

universe u v

variable {C : Type u} [Groupoid C]

#print CategoryTheory.Subgroupoid /-
/-- A sugroupoid of `C` consists of a choice of arrows for each pair of vertices, closed
under composition and inverses.
-/
@[ext]
structure Subgroupoid (C : Type u) [Groupoid C] where
  arrows : ∀ c d : C, Set (c ⟶ d)
  inv : ∀ {c d} {p : c ⟶ d} (hp : p ∈ arrows c d), inv p ∈ arrows d c
  mul : ∀ {c d e} {p} (hp : p ∈ arrows c d) {q} (hq : q ∈ arrows d e), p ≫ q ∈ arrows c e
#align category_theory.subgroupoid CategoryTheory.Subgroupoid
-/

attribute [protected] subgroupoid.inv subgroupoid.mul

namespace Subgroupoid

variable (S : Subgroupoid C)

#print CategoryTheory.Subgroupoid.inv_mem_iff /-
theorem inv_mem_iff {c d : C} (f : c ⟶ d) : inv f ∈ S.arrows d c ↔ f ∈ S.arrows c d :=
  by
  constructor
  · rintro h
    suffices inv (inv f) ∈ S.arrows c d by simpa only [inv_eq_inv, is_iso.inv_inv] using this
    · apply S.inv h
  · apply S.inv
#align category_theory.subgroupoid.inv_mem_iff CategoryTheory.Subgroupoid.inv_mem_iff
-/

#print CategoryTheory.Subgroupoid.mul_mem_cancel_left /-
theorem mul_mem_cancel_left {c d e : C} {f : c ⟶ d} {g : d ⟶ e} (hf : f ∈ S.arrows c d) :
    f ≫ g ∈ S.arrows c e ↔ g ∈ S.arrows d e :=
  by
  constructor
  · rintro h
    suffices inv f ≫ f ≫ g ∈ S.arrows d e by
      simpa only [inv_eq_inv, is_iso.inv_hom_id_assoc] using this
    · apply S.mul (S.inv hf) h
  · apply S.mul hf
#align category_theory.subgroupoid.mul_mem_cancel_left CategoryTheory.Subgroupoid.mul_mem_cancel_left
-/

#print CategoryTheory.Subgroupoid.mul_mem_cancel_right /-
theorem mul_mem_cancel_right {c d e : C} {f : c ⟶ d} {g : d ⟶ e} (hg : g ∈ S.arrows d e) :
    f ≫ g ∈ S.arrows c e ↔ f ∈ S.arrows c d :=
  by
  constructor
  · rintro h
    suffices (f ≫ g) ≫ inv g ∈ S.arrows c d by
      simpa only [inv_eq_inv, is_iso.hom_inv_id, category.comp_id, category.assoc] using this
    · apply S.mul h (S.inv hg)
  · exact fun hf => S.mul hf hg
#align category_theory.subgroupoid.mul_mem_cancel_right CategoryTheory.Subgroupoid.mul_mem_cancel_right
-/

#print CategoryTheory.Subgroupoid.objs /-
/-- The vertices of `C` on which `S` has non-trivial isotropy -/
def objs : Set C :=
  {c : C | (S.arrows c c).Nonempty}
#align category_theory.subgroupoid.objs CategoryTheory.Subgroupoid.objs
-/

#print CategoryTheory.Subgroupoid.mem_objs_of_src /-
theorem mem_objs_of_src {c d : C} {f : c ⟶ d} (h : f ∈ S.arrows c d) : c ∈ S.objs :=
  ⟨f ≫ inv f, S.mul h (S.inv h)⟩
#align category_theory.subgroupoid.mem_objs_of_src CategoryTheory.Subgroupoid.mem_objs_of_src
-/

#print CategoryTheory.Subgroupoid.mem_objs_of_tgt /-
theorem mem_objs_of_tgt {c d : C} {f : c ⟶ d} (h : f ∈ S.arrows c d) : d ∈ S.objs :=
  ⟨inv f ≫ f, S.mul (S.inv h) h⟩
#align category_theory.subgroupoid.mem_objs_of_tgt CategoryTheory.Subgroupoid.mem_objs_of_tgt
-/

#print CategoryTheory.Subgroupoid.id_mem_of_nonempty_isotropy /-
theorem id_mem_of_nonempty_isotropy (c : C) : c ∈ objs S → 𝟙 c ∈ S.arrows c c :=
  by
  rintro ⟨γ, hγ⟩
  convert S.mul hγ (S.inv hγ)
  simp only [inv_eq_inv, is_iso.hom_inv_id]
#align category_theory.subgroupoid.id_mem_of_nonempty_isotropy CategoryTheory.Subgroupoid.id_mem_of_nonempty_isotropy
-/

#print CategoryTheory.Subgroupoid.id_mem_of_src /-
theorem id_mem_of_src {c d : C} {f : c ⟶ d} (h : f ∈ S.arrows c d) : 𝟙 c ∈ S.arrows c c :=
  id_mem_of_nonempty_isotropy S c (mem_objs_of_src S h)
#align category_theory.subgroupoid.id_mem_of_src CategoryTheory.Subgroupoid.id_mem_of_src
-/

#print CategoryTheory.Subgroupoid.id_mem_of_tgt /-
theorem id_mem_of_tgt {c d : C} {f : c ⟶ d} (h : f ∈ S.arrows c d) : 𝟙 d ∈ S.arrows d d :=
  id_mem_of_nonempty_isotropy S d (mem_objs_of_tgt S h)
#align category_theory.subgroupoid.id_mem_of_tgt CategoryTheory.Subgroupoid.id_mem_of_tgt
-/

#print CategoryTheory.Subgroupoid.asWideQuiver /-
/-- A subgroupoid seen as a quiver on vertex set `C` -/
def asWideQuiver : Quiver C :=
  ⟨fun c d => Subtype <| S.arrows c d⟩
#align category_theory.subgroupoid.as_wide_quiver CategoryTheory.Subgroupoid.asWideQuiver
-/

#print CategoryTheory.Subgroupoid.coe /-
/-- The coercion of a subgroupoid as a groupoid -/
@[simps to_category_comp_coe, simps (config := lemmasOnly) inv_coe]
instance coe : Groupoid S.objs where
  Hom a b := S.arrows a.val b.val
  id a := ⟨𝟙 a.val, id_mem_of_nonempty_isotropy S a.val a.Prop⟩
  comp a b c p q := ⟨p.val ≫ q.val, S.mul p.Prop q.Prop⟩
  id_comp' := fun a b ⟨p, hp⟩ => by simp only [category.id_comp]
  comp_id' := fun a b ⟨p, hp⟩ => by simp only [category.comp_id]
  assoc' := fun a b c d ⟨p, hp⟩ ⟨q, hq⟩ ⟨r, hr⟩ => by simp only [category.assoc]
  inv a b p := ⟨inv p.val, S.inv p.Prop⟩
  inv_comp' := fun a b ⟨p, hp⟩ => by simp only [inv_comp]
  comp_inv' := fun a b ⟨p, hp⟩ => by simp only [comp_inv]
#align category_theory.subgroupoid.coe CategoryTheory.Subgroupoid.coe
-/

#print CategoryTheory.Subgroupoid.coe_inv_coe' /-
@[simp]
theorem coe_inv_coe' {c d : S.objs} (p : c ⟶ d) :
    (CategoryTheory.inv p).val = CategoryTheory.inv p.val := by
  simp only [Subtype.val_eq_coe, ← inv_eq_inv, coe_inv_coe]
#align category_theory.subgroupoid.coe_inv_coe' CategoryTheory.Subgroupoid.coe_inv_coe'
-/

#print CategoryTheory.Subgroupoid.hom /-
/-- The embedding of the coerced subgroupoid to its parent-/
def hom : S.objs ⥤ C where
  obj c := c.val
  map c d f := f.val
  map_id' c := rfl
  map_comp' c d e f g := rfl
#align category_theory.subgroupoid.hom CategoryTheory.Subgroupoid.hom
-/

#print CategoryTheory.Subgroupoid.hom.inj_on_objects /-
theorem hom.inj_on_objects : Function.Injective (hom S).obj := by rintro ⟨c, hc⟩ ⟨d, hd⟩ hcd;
  simp only [Subtype.mk_eq_mk]; exact hcd
#align category_theory.subgroupoid.hom.inj_on_objects CategoryTheory.Subgroupoid.hom.inj_on_objects
-/

#print CategoryTheory.Subgroupoid.hom.faithful /-
theorem hom.faithful : ∀ c d, Function.Injective fun f : c ⟶ d => (hom S).map f := by
  rintro ⟨c, hc⟩ ⟨d, hd⟩ ⟨f, hf⟩ ⟨g, hg⟩ hfg; simp only [Subtype.mk_eq_mk]; exact hfg
#align category_theory.subgroupoid.hom.faithful CategoryTheory.Subgroupoid.hom.faithful
-/

#print CategoryTheory.Subgroupoid.vertexSubgroup /-
/-- The subgroup of the vertex group at `c` given by the subgroupoid -/
def vertexSubgroup {c : C} (hc : c ∈ S.objs) : Subgroup (c ⟶ c)
    where
  carrier := S.arrows c c
  mul_mem' f g hf hg := S.mul hf hg
  one_mem' := id_mem_of_nonempty_isotropy _ _ hc
  inv_mem' f hf := S.inv hf
#align category_theory.subgroupoid.vertex_subgroup CategoryTheory.Subgroupoid.vertexSubgroup
-/

instance : SetLike (Subgroupoid C) (Σ c d : C, c ⟶ d)
    where
  coe S := {F | F.2.2 ∈ S.arrows F.1 F.2.1}
  coe_injective' := fun ⟨S, _, _⟩ ⟨T, _, _⟩ h => by ext c d f; apply Set.ext_iff.1 h ⟨c, d, f⟩

#print CategoryTheory.Subgroupoid.mem_iff /-
theorem mem_iff (S : Subgroupoid C) (F : Σ c d, c ⟶ d) : F ∈ S ↔ F.2.2 ∈ S.arrows F.1 F.2.1 :=
  Iff.rfl
#align category_theory.subgroupoid.mem_iff CategoryTheory.Subgroupoid.mem_iff
-/

#print CategoryTheory.Subgroupoid.le_iff /-
theorem le_iff (S T : Subgroupoid C) : S ≤ T ↔ ∀ {c d}, S.arrows c d ⊆ T.arrows c d := by
  rw [SetLike.le_def, Sigma.forall]; exact forall_congr' fun c => Sigma.forall
#align category_theory.subgroupoid.le_iff CategoryTheory.Subgroupoid.le_iff
-/

instance : Top (Subgroupoid C) :=
  ⟨{  arrows := fun _ _ => Set.univ
      mul := by rintro; trivial
      inv := by rintro; trivial }⟩

#print CategoryTheory.Subgroupoid.mem_top /-
theorem mem_top {c d : C} (f : c ⟶ d) : f ∈ (⊤ : Subgroupoid C).arrows c d :=
  trivial
#align category_theory.subgroupoid.mem_top CategoryTheory.Subgroupoid.mem_top
-/

#print CategoryTheory.Subgroupoid.mem_top_objs /-
theorem mem_top_objs (c : C) : c ∈ (⊤ : Subgroupoid C).objs := by dsimp [Top.top, objs];
  simp only [univ_nonempty]
#align category_theory.subgroupoid.mem_top_objs CategoryTheory.Subgroupoid.mem_top_objs
-/

instance : Bot (Subgroupoid C) :=
  ⟨{  arrows := fun _ _ => ∅
      mul := fun _ _ _ _ => False.elim
      inv := fun _ _ _ => False.elim }⟩

instance : Inhabited (Subgroupoid C) :=
  ⟨⊤⟩

instance : Inf (Subgroupoid C) :=
  ⟨fun S T =>
    { arrows := fun c d => S.arrows c d ∩ T.arrows c d
      inv := by rintro; exact ⟨S.inv hp.1, T.inv hp.2⟩
      mul := by rintro; exact ⟨S.mul hp.1 hq.1, T.mul hp.2 hq.2⟩ }⟩

instance : InfSet (Subgroupoid C) :=
  ⟨fun s =>
    { arrows := fun c d => ⋂ S ∈ s, Subgroupoid.arrows S c d
      inv := by intros; rw [mem_Inter₂] at hp ⊢; exact fun S hS => S.inv (hp S hS)
      mul := by intros; rw [mem_Inter₂] at hp hq ⊢; exact fun S hS => S.mul (hp S hS) (hq S hS) }⟩

instance : CompleteLattice (Subgroupoid C) :=
  {
    completeLatticeOfInf (Subgroupoid C)
      (by
        refine' fun s => ⟨fun S Ss F => _, fun T Tl F fT => _⟩ <;>
          simp only [Inf, mem_iff, mem_Inter]
        exacts [fun hp => hp S Ss, fun S Ss =>
          Tl Ss fT]) with
    bot := ⊥
    bot_le := fun S => empty_subset _
    top := ⊤
    le_top := fun S => subset_univ _
    inf := (· ⊓ ·)
    le_inf := fun R S T RS RT _ pR => ⟨RS pR, RT pR⟩
    inf_le_left := fun R S _ => And.left
    inf_le_right := fun R S _ => And.right }

#print CategoryTheory.Subgroupoid.le_objs /-
theorem le_objs {S T : Subgroupoid C} (h : S ≤ T) : S.objs ⊆ T.objs := fun s ⟨γ, hγ⟩ =>
  ⟨γ, @h ⟨s, s, γ⟩ hγ⟩
#align category_theory.subgroupoid.le_objs CategoryTheory.Subgroupoid.le_objs
-/

#print CategoryTheory.Subgroupoid.inclusion /-
/-- The functor associated to the embedding of subgroupoids -/
def inclusion {S T : Subgroupoid C} (h : S ≤ T) : S.objs ⥤ T.objs
    where
  obj s := ⟨s.val, le_objs h s.Prop⟩
  map s t f := ⟨f.val, @h ⟨s, t, f.val⟩ f.Prop⟩
  map_id' _ := rfl
  map_comp' _ _ _ _ _ := rfl
#align category_theory.subgroupoid.inclusion CategoryTheory.Subgroupoid.inclusion
-/

#print CategoryTheory.Subgroupoid.inclusion_inj_on_objects /-
theorem inclusion_inj_on_objects {S T : Subgroupoid C} (h : S ≤ T) :
    Function.Injective (inclusion h).obj := fun ⟨s, hs⟩ ⟨t, ht⟩ => by
  simpa only [inclusion, Subtype.mk_eq_mk] using id
#align category_theory.subgroupoid.inclusion_inj_on_objects CategoryTheory.Subgroupoid.inclusion_inj_on_objects
-/

#print CategoryTheory.Subgroupoid.inclusion_faithful /-
theorem inclusion_faithful {S T : Subgroupoid C} (h : S ≤ T) (s t : S.objs) :
    Function.Injective fun f : s ⟶ t => (inclusion h).map f := fun ⟨f, hf⟩ ⟨g, hg⟩ => by
  dsimp only [inclusion]; simpa only [Subtype.mk_eq_mk] using id
#align category_theory.subgroupoid.inclusion_faithful CategoryTheory.Subgroupoid.inclusion_faithful
-/

#print CategoryTheory.Subgroupoid.inclusion_refl /-
theorem inclusion_refl {S : Subgroupoid C} : inclusion (le_refl S) = 𝟭 S.objs :=
  Functor.hext (fun ⟨s, hs⟩ => rfl) fun ⟨s, hs⟩ ⟨t, ht⟩ ⟨f, hf⟩ => hEq_of_eq rfl
#align category_theory.subgroupoid.inclusion_refl CategoryTheory.Subgroupoid.inclusion_refl
-/

#print CategoryTheory.Subgroupoid.inclusion_trans /-
theorem inclusion_trans {R S T : Subgroupoid C} (k : R ≤ S) (h : S ≤ T) :
    inclusion (k.trans h) = inclusion k ⋙ inclusion h :=
  rfl
#align category_theory.subgroupoid.inclusion_trans CategoryTheory.Subgroupoid.inclusion_trans
-/

#print CategoryTheory.Subgroupoid.inclusion_comp_embedding /-
theorem inclusion_comp_embedding {S T : Subgroupoid C} (h : S ≤ T) : inclusion h ⋙ T.Hom = S.Hom :=
  rfl
#align category_theory.subgroupoid.inclusion_comp_embedding CategoryTheory.Subgroupoid.inclusion_comp_embedding
-/

#print CategoryTheory.Subgroupoid.Discrete.Arrows /-
/-- The family of arrows of the discrete groupoid -/
inductive Discrete.Arrows : ∀ c d : C, (c ⟶ d) → Prop
  | id (c : C) : discrete.arrows c c (𝟙 c)
#align category_theory.subgroupoid.discrete.arrows CategoryTheory.Subgroupoid.Discrete.Arrows
-/

#print CategoryTheory.Subgroupoid.discrete /-
/-- The only arrows of the discrete groupoid are the identity arrows. -/
def discrete : Subgroupoid C where
  arrows := Discrete.Arrows
  inv := by rintro _ _ _ ⟨⟩; simp only [inv_eq_inv, is_iso.inv_id]; constructor
  mul := by rintro _ _ _ _ ⟨⟩ _ ⟨⟩; rw [category.comp_id]; constructor
#align category_theory.subgroupoid.discrete CategoryTheory.Subgroupoid.discrete
-/

#print CategoryTheory.Subgroupoid.mem_discrete_iff /-
theorem mem_discrete_iff {c d : C} (f : c ⟶ d) :
    f ∈ discrete.arrows c d ↔ ∃ h : c = d, f = eqToHom h :=
  ⟨by rintro ⟨⟩; exact ⟨rfl, rfl⟩, by rintro ⟨rfl, rfl⟩; constructor⟩
#align category_theory.subgroupoid.mem_discrete_iff CategoryTheory.Subgroupoid.mem_discrete_iff
-/

#print CategoryTheory.Subgroupoid.IsWide /-
/-- A subgroupoid is wide if its carrier set is all of `C`-/
structure IsWide : Prop where
  wide : ∀ c, 𝟙 c ∈ S.arrows c c
#align category_theory.subgroupoid.is_wide CategoryTheory.Subgroupoid.IsWide
-/

#print CategoryTheory.Subgroupoid.isWide_iff_objs_eq_univ /-
theorem isWide_iff_objs_eq_univ : S.IsWide ↔ S.objs = Set.univ :=
  by
  constructor
  · rintro h
    ext; constructor <;> simp only [top_eq_univ, mem_univ, imp_true_iff, forall_true_left]
    apply mem_objs_of_src S (h.wide x)
  · rintro h
    refine' ⟨fun c => _⟩
    obtain ⟨γ, γS⟩ := (le_of_eq h.symm : ⊤ ⊆ S.objs) (Set.mem_univ c)
    exact id_mem_of_src S γS
#align category_theory.subgroupoid.is_wide_iff_objs_eq_univ CategoryTheory.Subgroupoid.isWide_iff_objs_eq_univ
-/

#print CategoryTheory.Subgroupoid.IsWide.id_mem /-
theorem IsWide.id_mem {S : Subgroupoid C} (Sw : S.IsWide) (c : C) : 𝟙 c ∈ S.arrows c c :=
  Sw.wide c
#align category_theory.subgroupoid.is_wide.id_mem CategoryTheory.Subgroupoid.IsWide.id_mem
-/

#print CategoryTheory.Subgroupoid.IsWide.eqToHom_mem /-
theorem IsWide.eqToHom_mem {S : Subgroupoid C} (Sw : S.IsWide) {c d : C} (h : c = d) :
    eqToHom h ∈ S.arrows c d := by cases h; simp only [eq_to_hom_refl]; apply Sw.id_mem c
#align category_theory.subgroupoid.is_wide.eq_to_hom_mem CategoryTheory.Subgroupoid.IsWide.eqToHom_mem
-/

#print CategoryTheory.Subgroupoid.IsNormal /-
/-- A subgroupoid is normal if it is wide and satisfies the expected stability under conjugacy. -/
structure IsNormal extends IsWide S : Prop where
  conj : ∀ {c d} (p : c ⟶ d) {γ : c ⟶ c} (hs : γ ∈ S.arrows c c), inv p ≫ γ ≫ p ∈ S.arrows d d
#align category_theory.subgroupoid.is_normal CategoryTheory.Subgroupoid.IsNormal
-/

#print CategoryTheory.Subgroupoid.IsNormal.conj' /-
theorem IsNormal.conj' {S : Subgroupoid C} (Sn : IsNormal S) :
    ∀ {c d} (p : d ⟶ c) {γ : c ⟶ c} (hs : γ ∈ S.arrows c c), p ≫ γ ≫ inv p ∈ S.arrows d d :=
  fun c d p γ hs => by convert Sn.conj (inv p) hs; simp
#align category_theory.subgroupoid.is_normal.conj' CategoryTheory.Subgroupoid.IsNormal.conj'
-/

#print CategoryTheory.Subgroupoid.IsNormal.conjugation_bij /-
theorem IsNormal.conjugation_bij (Sn : IsNormal S) {c d} (p : c ⟶ d) :
    Set.BijOn (fun γ : c ⟶ c => inv p ≫ γ ≫ p) (S.arrows c c) (S.arrows d d) :=
  by
  refine'
    ⟨fun γ γS => Sn.conj p γS, fun γ₁ γ₁S γ₂ γ₂S h => _, fun δ δS =>
      ⟨p ≫ δ ≫ inv p, Sn.conj' p δS, _⟩⟩
  ·
    simpa only [inv_eq_inv, category.assoc, is_iso.hom_inv_id, category.comp_id,
      is_iso.hom_inv_id_assoc] using p ≫= h =≫ inv p
  ·
    simp only [inv_eq_inv, category.assoc, is_iso.inv_hom_id, category.comp_id,
      is_iso.inv_hom_id_assoc]
#align category_theory.subgroupoid.is_normal.conjugation_bij CategoryTheory.Subgroupoid.IsNormal.conjugation_bij
-/

#print CategoryTheory.Subgroupoid.top_isNormal /-
theorem top_isNormal : IsNormal (⊤ : Subgroupoid C) :=
  { wide := fun c => trivial
    conj := fun a b c d e => trivial }
#align category_theory.subgroupoid.top_is_normal CategoryTheory.Subgroupoid.top_isNormal
-/

#print CategoryTheory.Subgroupoid.sInf_isNormal /-
theorem sInf_isNormal (s : Set <| Subgroupoid C) (sn : ∀ S ∈ s, IsNormal S) : IsNormal (sInf s) :=
  { wide := by simp_rw [Inf, mem_Inter₂]; exact fun c S Ss => (sn S Ss).wide c
    conj := by simp_rw [Inf, mem_Inter₂]; exact fun c d p γ hγ S Ss => (sn S Ss).conj p (hγ S Ss) }
#align category_theory.subgroupoid.Inf_is_normal CategoryTheory.Subgroupoid.sInf_isNormal
-/

#print CategoryTheory.Subgroupoid.discrete_isNormal /-
theorem discrete_isNormal : (@discrete C _).IsNormal :=
  { wide := fun c => by constructor
    conj := fun c d f γ hγ => by cases hγ;
      simp only [inv_eq_inv, category.id_comp, is_iso.inv_hom_id]; constructor }
#align category_theory.subgroupoid.discrete_is_normal CategoryTheory.Subgroupoid.discrete_isNormal
-/

#print CategoryTheory.Subgroupoid.IsNormal.vertexSubgroup /-
theorem IsNormal.vertexSubgroup (Sn : IsNormal S) (c : C) (cS : c ∈ S.objs) :
    (S.vertexSubgroup cS).Normal :=
  { conj_mem := fun x hx y => by rw [mul_assoc]; exact Sn.conj' y hx }
#align category_theory.subgroupoid.is_normal.vertex_subgroup CategoryTheory.Subgroupoid.IsNormal.vertexSubgroup
-/

section GeneratedSubgroupoid

-- TODO: proof that generated is just "words in X" and generated_normal is similarly
variable (X : ∀ c d : C, Set (c ⟶ d))

#print CategoryTheory.Subgroupoid.generated /-
/-- The subgropoid generated by the set of arrows `X` -/
def generated : Subgroupoid C :=
  sInf {S : Subgroupoid C | ∀ c d, X c d ⊆ S.arrows c d}
#align category_theory.subgroupoid.generated CategoryTheory.Subgroupoid.generated
-/

#print CategoryTheory.Subgroupoid.subset_generated /-
theorem subset_generated (c d : C) : X c d ⊆ (generated X).arrows c d :=
  by
  dsimp only [generated, Inf]
  simp only [subset_Inter₂_iff]
  exact fun S hS f fS => hS _ _ fS
#align category_theory.subgroupoid.subset_generated CategoryTheory.Subgroupoid.subset_generated
-/

#print CategoryTheory.Subgroupoid.generatedNormal /-
/-- The normal sugroupoid generated by the set of arrows `X` -/
def generatedNormal : Subgroupoid C :=
  sInf {S : Subgroupoid C | (∀ c d, X c d ⊆ S.arrows c d) ∧ S.IsNormal}
#align category_theory.subgroupoid.generated_normal CategoryTheory.Subgroupoid.generatedNormal
-/

#print CategoryTheory.Subgroupoid.generated_le_generatedNormal /-
theorem generated_le_generatedNormal : generated X ≤ generatedNormal X :=
  by
  apply @sInf_le_sInf (subgroupoid C) _
  exact fun S ⟨h, _⟩ => h
#align category_theory.subgroupoid.generated_le_generated_normal CategoryTheory.Subgroupoid.generated_le_generatedNormal
-/

#print CategoryTheory.Subgroupoid.generatedNormal_isNormal /-
theorem generatedNormal_isNormal : (generatedNormal X).IsNormal :=
  sInf_isNormal _ fun S h => h.right
#align category_theory.subgroupoid.generated_normal_is_normal CategoryTheory.Subgroupoid.generatedNormal_isNormal
-/

#print CategoryTheory.Subgroupoid.IsNormal.generatedNormal_le /-
theorem IsNormal.generatedNormal_le {S : Subgroupoid C} (Sn : S.IsNormal) :
    generatedNormal X ≤ S ↔ ∀ c d, X c d ⊆ S.arrows c d :=
  by
  constructor
  · rintro h c d
    let h' := generated_le_generated_normal X
    rw [le_iff] at h h' 
    exact ((subset_generated X c d).trans (@h' c d)).trans (@h c d)
  · rintro h
    apply @sInf_le (subgroupoid C) _
    exact ⟨h, Sn⟩
#align category_theory.subgroupoid.is_normal.generated_normal_le CategoryTheory.Subgroupoid.IsNormal.generatedNormal_le
-/

end GeneratedSubgroupoid

section Hom

variable {D : Type _} [Groupoid D] (φ : C ⥤ D)

#print CategoryTheory.Subgroupoid.comap /-
/-- A functor between groupoid defines a map of subgroupoids in the reverse direction
by taking preimages.
 -/
def comap (S : Subgroupoid D) : Subgroupoid C
    where
  arrows c d := {f : c ⟶ d | φ.map f ∈ S.arrows (φ.obj c) (φ.obj d)}
  inv c d p hp := by rw [mem_set_of, inv_eq_inv, φ.map_inv p, ← inv_eq_inv]; exact S.inv hp
  mul := by
    rintro
    simp only [mem_set_of, functor.map_comp]
    apply S.mul <;> assumption
#align category_theory.subgroupoid.comap CategoryTheory.Subgroupoid.comap
-/

#print CategoryTheory.Subgroupoid.comap_mono /-
theorem comap_mono (S T : Subgroupoid D) : S ≤ T → comap φ S ≤ comap φ T := fun ST ⟨c, d, p⟩ =>
  @ST ⟨_, _, _⟩
#align category_theory.subgroupoid.comap_mono CategoryTheory.Subgroupoid.comap_mono
-/

#print CategoryTheory.Subgroupoid.isNormal_comap /-
theorem isNormal_comap {S : Subgroupoid D} (Sn : IsNormal S) : IsNormal (comap φ S) :=
  { wide := fun c => by rw [comap, mem_set_of, Functor.map_id]; apply Sn.wide
    conj := fun c d f γ hγ =>
      by
      simp_rw [inv_eq_inv f, comap, mem_set_of, functor.map_comp, functor.map_inv, ← inv_eq_inv]
      exact Sn.conj _ hγ }
#align category_theory.subgroupoid.is_normal_comap CategoryTheory.Subgroupoid.isNormal_comap
-/

#print CategoryTheory.Subgroupoid.comap_comp /-
@[simp]
theorem comap_comp {E : Type _} [Groupoid E] (ψ : D ⥤ E) : comap (φ ⋙ ψ) = comap φ ∘ comap ψ :=
  rfl
#align category_theory.subgroupoid.comap_comp CategoryTheory.Subgroupoid.comap_comp
-/

#print CategoryTheory.Subgroupoid.ker /-
/-- The kernel of a functor between subgroupoid is the preimage. -/
def ker : Subgroupoid C :=
  comap φ discrete
#align category_theory.subgroupoid.ker CategoryTheory.Subgroupoid.ker
-/

#print CategoryTheory.Subgroupoid.mem_ker_iff /-
theorem mem_ker_iff {c d : C} (f : c ⟶ d) :
    f ∈ (ker φ).arrows c d ↔ ∃ h : φ.obj c = φ.obj d, φ.map f = eqToHom h :=
  mem_discrete_iff (φ.map f)
#align category_theory.subgroupoid.mem_ker_iff CategoryTheory.Subgroupoid.mem_ker_iff
-/

#print CategoryTheory.Subgroupoid.ker_isNormal /-
theorem ker_isNormal : (ker φ).IsNormal :=
  isNormal_comap φ discrete_isNormal
#align category_theory.subgroupoid.ker_is_normal CategoryTheory.Subgroupoid.ker_isNormal
-/

#print CategoryTheory.Subgroupoid.ker_comp /-
@[simp]
theorem ker_comp {E : Type _} [Groupoid E] (ψ : D ⥤ E) : ker (φ ⋙ ψ) = comap φ (ker ψ) :=
  rfl
#align category_theory.subgroupoid.ker_comp CategoryTheory.Subgroupoid.ker_comp
-/

#print CategoryTheory.Subgroupoid.Map.Arrows /-
/-- The family of arrows of the image of a subgroupoid under a functor injective on objects -/
inductive Map.Arrows (hφ : Function.Injective φ.obj) (S : Subgroupoid C) : ∀ c d : D, (c ⟶ d) → Prop
  | im {c d : C} (f : c ⟶ d) (hf : f ∈ S.arrows c d) : map.arrows (φ.obj c) (φ.obj d) (φ.map f)
#align category_theory.subgroupoid.map.arrows CategoryTheory.Subgroupoid.Map.Arrows
-/

#print CategoryTheory.Subgroupoid.Map.arrows_iff /-
theorem Map.arrows_iff (hφ : Function.Injective φ.obj) (S : Subgroupoid C) {c d : D} (f : c ⟶ d) :
    Map.Arrows φ hφ S c d f ↔
      ∃ (a b : C) (g : a ⟶ b) (ha : φ.obj a = c) (hb : φ.obj b = d) (hg : g ∈ S.arrows a b),
        f = eqToHom ha.symm ≫ φ.map g ≫ eqToHom hb :=
  by
  constructor
  · rintro ⟨g, hg⟩; exact ⟨_, _, g, rfl, rfl, hg, eq_conj_eq_to_hom _⟩
  · rintro ⟨a, b, g, rfl, rfl, hg, rfl⟩; rw [← eq_conj_eq_to_hom]; constructor; exact hg
#align category_theory.subgroupoid.map.arrows_iff CategoryTheory.Subgroupoid.Map.arrows_iff
-/

#print CategoryTheory.Subgroupoid.map /-
/-- The "forward" image of a subgroupoid under a functor injective on objects -/
def map (hφ : Function.Injective φ.obj) (S : Subgroupoid C) : Subgroupoid D
    where
  arrows := Map.Arrows φ hφ S
  inv := by
    rintro _ _ _ ⟨⟩
    rw [inv_eq_inv, ← functor.map_inv, ← inv_eq_inv]
    constructor; apply S.inv; assumption
  mul := by
    rintro _ _ _ _ ⟨f, hf⟩ q hq
    obtain ⟨c₃, c₄, g, he, rfl, hg, gq⟩ := (map.arrows_iff φ hφ S q).mp hq
    cases hφ he; rw [gq, ← eq_conj_eq_to_hom, ← φ.map_comp]
    constructor; exact S.mul hf hg
#align category_theory.subgroupoid.map CategoryTheory.Subgroupoid.map
-/

#print CategoryTheory.Subgroupoid.mem_map_iff /-
theorem mem_map_iff (hφ : Function.Injective φ.obj) (S : Subgroupoid C) {c d : D} (f : c ⟶ d) :
    f ∈ (map φ hφ S).arrows c d ↔
      ∃ (a b : C) (g : a ⟶ b) (ha : φ.obj a = c) (hb : φ.obj b = d) (hg : g ∈ S.arrows a b),
        f = eqToHom ha.symm ≫ φ.map g ≫ eqToHom hb :=
  Map.arrows_iff φ hφ S f
#align category_theory.subgroupoid.mem_map_iff CategoryTheory.Subgroupoid.mem_map_iff
-/

#print CategoryTheory.Subgroupoid.galoisConnection_map_comap /-
theorem galoisConnection_map_comap (hφ : Function.Injective φ.obj) :
    GaloisConnection (map φ hφ) (comap φ) :=
  by
  rintro S T; simp_rw [le_iff]; constructor
  · exact fun h c d f fS => h (map.arrows.im f fS)
  · rintro h _ _ g ⟨a, gφS⟩
    exact h gφS
#align category_theory.subgroupoid.galois_connection_map_comap CategoryTheory.Subgroupoid.galoisConnection_map_comap
-/

#print CategoryTheory.Subgroupoid.map_mono /-
theorem map_mono (hφ : Function.Injective φ.obj) (S T : Subgroupoid C) :
    S ≤ T → map φ hφ S ≤ map φ hφ T := fun h => (galoisConnection_map_comap φ hφ).monotone_l h
#align category_theory.subgroupoid.map_mono CategoryTheory.Subgroupoid.map_mono
-/

#print CategoryTheory.Subgroupoid.le_comap_map /-
theorem le_comap_map (hφ : Function.Injective φ.obj) (S : Subgroupoid C) :
    S ≤ comap φ (map φ hφ S) :=
  (galoisConnection_map_comap φ hφ).le_u_l S
#align category_theory.subgroupoid.le_comap_map CategoryTheory.Subgroupoid.le_comap_map
-/

#print CategoryTheory.Subgroupoid.map_comap_le /-
theorem map_comap_le (hφ : Function.Injective φ.obj) (T : Subgroupoid D) :
    map φ hφ (comap φ T) ≤ T :=
  (galoisConnection_map_comap φ hφ).l_u_le T
#align category_theory.subgroupoid.map_comap_le CategoryTheory.Subgroupoid.map_comap_le
-/

#print CategoryTheory.Subgroupoid.map_le_iff_le_comap /-
theorem map_le_iff_le_comap (hφ : Function.Injective φ.obj) (S : Subgroupoid C)
    (T : Subgroupoid D) : map φ hφ S ≤ T ↔ S ≤ comap φ T :=
  (galoisConnection_map_comap φ hφ).le_iff_le
#align category_theory.subgroupoid.map_le_iff_le_comap CategoryTheory.Subgroupoid.map_le_iff_le_comap
-/

#print CategoryTheory.Subgroupoid.mem_map_objs_iff /-
theorem mem_map_objs_iff (hφ : Function.Injective φ.obj) (d : D) :
    d ∈ (map φ hφ S).objs ↔ ∃ c ∈ S.objs, φ.obj c = d :=
  by
  dsimp [objs, map]
  constructor
  · rintro ⟨f, hf⟩
    change map.arrows φ hφ S d d f at hf ; rw [map.arrows_iff] at hf 
    obtain ⟨c, d, g, ec, ed, eg, gS, eg⟩ := hf
    exact ⟨c, ⟨mem_objs_of_src S eg, ec⟩⟩
  · rintro ⟨c, ⟨γ, γS⟩, rfl⟩
    exact ⟨φ.map γ, ⟨γ, γS⟩⟩
#align category_theory.subgroupoid.mem_map_objs_iff CategoryTheory.Subgroupoid.mem_map_objs_iff
-/

#print CategoryTheory.Subgroupoid.map_objs_eq /-
@[simp]
theorem map_objs_eq (hφ : Function.Injective φ.obj) : (map φ hφ S).objs = φ.obj '' S.objs := by ext;
  convert mem_map_objs_iff S φ hφ x; simp only [mem_image, exists_prop]
#align category_theory.subgroupoid.map_objs_eq CategoryTheory.Subgroupoid.map_objs_eq
-/

#print CategoryTheory.Subgroupoid.im /-
/-- The image of a functor injective on objects -/
def im (hφ : Function.Injective φ.obj) :=
  map φ hφ ⊤
#align category_theory.subgroupoid.im CategoryTheory.Subgroupoid.im
-/

#print CategoryTheory.Subgroupoid.mem_im_iff /-
theorem mem_im_iff (hφ : Function.Injective φ.obj) {c d : D} (f : c ⟶ d) :
    f ∈ (im φ hφ).arrows c d ↔
      ∃ (a b : C) (g : a ⟶ b) (ha : φ.obj a = c) (hb : φ.obj b = d),
        f = eqToHom ha.symm ≫ φ.map g ≫ eqToHom hb :=
  by convert map.arrows_iff φ hφ ⊤ f; simp only [Top.top, mem_univ, exists_true_left]
#align category_theory.subgroupoid.mem_im_iff CategoryTheory.Subgroupoid.mem_im_iff
-/

#print CategoryTheory.Subgroupoid.mem_im_objs_iff /-
theorem mem_im_objs_iff (hφ : Function.Injective φ.obj) (d : D) :
    d ∈ (im φ hφ).objs ↔ ∃ c : C, φ.obj c = d := by
  simp only [im, mem_map_objs_iff, mem_top_objs, exists_true_left]
#align category_theory.subgroupoid.mem_im_objs_iff CategoryTheory.Subgroupoid.mem_im_objs_iff
-/

#print CategoryTheory.Subgroupoid.obj_surjective_of_im_eq_top /-
theorem obj_surjective_of_im_eq_top (hφ : Function.Injective φ.obj) (hφ' : im φ hφ = ⊤) :
    Function.Surjective φ.obj := by
  rintro d
  rw [← mem_im_objs_iff, hφ']
  apply mem_top_objs
#align category_theory.subgroupoid.obj_surjective_of_im_eq_top CategoryTheory.Subgroupoid.obj_surjective_of_im_eq_top
-/

#print CategoryTheory.Subgroupoid.isNormal_map /-
theorem isNormal_map (hφ : Function.Injective φ.obj) (hφ' : im φ hφ = ⊤) (Sn : S.IsNormal) :
    (map φ hφ S).IsNormal :=
  { wide := fun d => by
      obtain ⟨c, rfl⟩ := obj_surjective_of_im_eq_top φ hφ hφ' d
      change map.arrows φ hφ S _ _ (𝟙 _); rw [← Functor.map_id]
      constructor; exact Sn.wide c
    conj := fun d d' g δ hδ => by
      rw [mem_map_iff] at hδ 
      obtain ⟨c, c', γ, cd, cd', γS, hγ⟩ := hδ; subst_vars; cases hφ cd'
      have : d' ∈ (im φ hφ).objs := by rw [hφ']; apply mem_top_objs
      rw [mem_im_objs_iff] at this 
      obtain ⟨c', rfl⟩ := this
      have : g ∈ (im φ hφ).arrows (φ.obj c) (φ.obj c') := by rw [hφ']; trivial
      rw [mem_im_iff] at this 
      obtain ⟨b, b', f, hb, hb', _, hf⟩ := this; subst_vars; cases hφ hb; cases hφ hb'
      change map.arrows φ hφ S (φ.obj c') (φ.obj c') _
      simp only [eq_to_hom_refl, category.comp_id, category.id_comp, inv_eq_inv]
      suffices map.arrows φ hφ S (φ.obj c') (φ.obj c') (φ.map <| inv f ≫ γ ≫ f) by
        simp only [inv_eq_inv, functor.map_comp, functor.map_inv] at this ; exact this
      · constructor; apply Sn.conj f γS }
#align category_theory.subgroupoid.is_normal_map CategoryTheory.Subgroupoid.isNormal_map
-/

end Hom

section Thin

#print CategoryTheory.Subgroupoid.IsThin /-
/-- A subgroupoid `is_thin` if it has at most one arrow between any two vertices. -/
abbrev IsThin :=
  Quiver.IsThin S.objs
#align category_theory.subgroupoid.is_thin CategoryTheory.Subgroupoid.IsThin
-/

#print CategoryTheory.Subgroupoid.isThin_iff /-
theorem isThin_iff : S.IsThin ↔ ∀ c : S.objs, Subsingleton (S.arrows c c) := by apply is_thin_iff
#align category_theory.subgroupoid.is_thin_iff CategoryTheory.Subgroupoid.isThin_iff
-/

end Thin

section Disconnected

#print CategoryTheory.Subgroupoid.IsTotallyDisconnected /-
/-- A subgroupoid `is_totally_disconnected` if it has only isotropy arrows. -/
abbrev IsTotallyDisconnected :=
  IsTotallyDisconnected S.objs
#align category_theory.subgroupoid.is_totally_disconnected CategoryTheory.Subgroupoid.IsTotallyDisconnected
-/

#print CategoryTheory.Subgroupoid.isTotallyDisconnected_iff /-
theorem isTotallyDisconnected_iff :
    S.IsTotallyDisconnected ↔ ∀ c d, (S.arrows c d).Nonempty → c = d :=
  by
  constructor
  · rintro h c d ⟨f, fS⟩
    rw [← @Subtype.mk_eq_mk _ _ c (mem_objs_of_src S fS) d (mem_objs_of_tgt S fS)]
    exact h ⟨c, mem_objs_of_src S fS⟩ ⟨d, mem_objs_of_tgt S fS⟩ ⟨f, fS⟩
  · rintro h ⟨c, hc⟩ ⟨d, hd⟩ ⟨f, fS⟩
    simp only [Subtype.mk_eq_mk]
    exact h c d ⟨f, fS⟩
#align category_theory.subgroupoid.is_totally_disconnected_iff CategoryTheory.Subgroupoid.isTotallyDisconnected_iff
-/

#print CategoryTheory.Subgroupoid.disconnect /-
/-- The isotropy subgroupoid of `S` -/
def disconnect : Subgroupoid C
    where
  arrows c d f := c = d ∧ f ∈ S.arrows c d
  inv := by rintro _ _ _ ⟨rfl, h⟩; exact ⟨rfl, S.inv h⟩
  mul := by rintro _ _ _ _ ⟨rfl, h⟩ _ ⟨rfl, h'⟩; exact ⟨rfl, S.mul h h'⟩
#align category_theory.subgroupoid.disconnect CategoryTheory.Subgroupoid.disconnect
-/

#print CategoryTheory.Subgroupoid.disconnect_le /-
theorem disconnect_le : S.disconnect ≤ S := by rw [le_iff]; rintro _ _ _ ⟨⟩; assumption
#align category_theory.subgroupoid.disconnect_le CategoryTheory.Subgroupoid.disconnect_le
-/

#print CategoryTheory.Subgroupoid.disconnect_normal /-
theorem disconnect_normal (Sn : S.IsNormal) : S.disconnect.IsNormal :=
  { wide := fun c => ⟨rfl, Sn.wide c⟩
    conj := fun c d p γ ⟨_, h'⟩ => ⟨rfl, Sn.conj _ h'⟩ }
#align category_theory.subgroupoid.disconnect_normal CategoryTheory.Subgroupoid.disconnect_normal
-/

#print CategoryTheory.Subgroupoid.mem_disconnect_objs_iff /-
@[simp]
theorem mem_disconnect_objs_iff {c : C} : c ∈ S.disconnect.objs ↔ c ∈ S.objs :=
  ⟨fun ⟨γ, h, γS⟩ => ⟨γ, γS⟩, fun ⟨γ, γS⟩ => ⟨γ, rfl, γS⟩⟩
#align category_theory.subgroupoid.mem_disconnect_objs_iff CategoryTheory.Subgroupoid.mem_disconnect_objs_iff
-/

#print CategoryTheory.Subgroupoid.disconnect_objs /-
theorem disconnect_objs : S.disconnect.objs = S.objs := by apply Set.ext;
  apply mem_disconnect_objs_iff
#align category_theory.subgroupoid.disconnect_objs CategoryTheory.Subgroupoid.disconnect_objs
-/

#print CategoryTheory.Subgroupoid.disconnect_isTotallyDisconnected /-
theorem disconnect_isTotallyDisconnected : S.disconnect.IsTotallyDisconnected := by
  rw [is_totally_disconnected_iff]; exact fun c d ⟨f, h, fS⟩ => h
#align category_theory.subgroupoid.disconnect_is_totally_disconnected CategoryTheory.Subgroupoid.disconnect_isTotallyDisconnected
-/

end Disconnected

section Full

variable (D : Set C)

#print CategoryTheory.Subgroupoid.full /-
/-- The full subgroupoid on a set `D : set C` -/
def full : Subgroupoid C where
  arrows c d _ := c ∈ D ∧ d ∈ D
  inv := by rintro _ _ _ ⟨⟩; constructor <;> assumption
  mul := by rintro _ _ _ _ ⟨⟩ _ ⟨⟩; constructor <;> assumption
#align category_theory.subgroupoid.full CategoryTheory.Subgroupoid.full
-/

#print CategoryTheory.Subgroupoid.full_objs /-
theorem full_objs : (full D).objs = D :=
  Set.ext fun _ => ⟨fun ⟨f, h, _⟩ => h, fun h => ⟨𝟙 _, h, h⟩⟩
#align category_theory.subgroupoid.full_objs CategoryTheory.Subgroupoid.full_objs
-/

#print CategoryTheory.Subgroupoid.mem_full_iff /-
@[simp]
theorem mem_full_iff {c d : C} {f : c ⟶ d} : f ∈ (full D).arrows c d ↔ c ∈ D ∧ d ∈ D :=
  Iff.rfl
#align category_theory.subgroupoid.mem_full_iff CategoryTheory.Subgroupoid.mem_full_iff
-/

#print CategoryTheory.Subgroupoid.mem_full_objs_iff /-
@[simp]
theorem mem_full_objs_iff {c : C} : c ∈ (full D).objs ↔ c ∈ D := by rw [full_objs]
#align category_theory.subgroupoid.mem_full_objs_iff CategoryTheory.Subgroupoid.mem_full_objs_iff
-/

#print CategoryTheory.Subgroupoid.full_empty /-
@[simp]
theorem full_empty : full ∅ = (⊥ : Subgroupoid C) := by ext;
  simp only [Bot.bot, mem_full_iff, mem_empty_iff_false, and_self_iff]
#align category_theory.subgroupoid.full_empty CategoryTheory.Subgroupoid.full_empty
-/

#print CategoryTheory.Subgroupoid.full_univ /-
@[simp]
theorem full_univ : full Set.univ = (⊤ : Subgroupoid C) := by ext;
  simp only [mem_full_iff, mem_univ, and_self_iff, true_iff_iff]
#align category_theory.subgroupoid.full_univ CategoryTheory.Subgroupoid.full_univ
-/

#print CategoryTheory.Subgroupoid.full_mono /-
theorem full_mono {D E : Set C} (h : D ≤ E) : full D ≤ full E :=
  by
  rw [le_iff]
  rintro c d f
  simp only [mem_full_iff]
  exact fun ⟨hc, hd⟩ => ⟨h hc, h hd⟩
#align category_theory.subgroupoid.full_mono CategoryTheory.Subgroupoid.full_mono
-/

#print CategoryTheory.Subgroupoid.full_arrow_eq_iff /-
theorem full_arrow_eq_iff {c d : (full D).objs} {f g : c ⟶ d} : f = g ↔ (↑f : c.val ⟶ d.val) = ↑g :=
  by apply Subtype.ext_iff
#align category_theory.subgroupoid.full_arrow_eq_iff CategoryTheory.Subgroupoid.full_arrow_eq_iff
-/

end Full

end Subgroupoid

end CategoryTheory

