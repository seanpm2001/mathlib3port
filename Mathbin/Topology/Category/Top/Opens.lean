/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module topology.category.Top.opens
! leanprover-community/mathlib commit f2b757fc5c341d88741b9c4630b1e8ba973c5726
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Category.Preorder
import Mathbin.CategoryTheory.EqToHom
import Mathbin.Topology.Category.Top.EpiMono
import Mathbin.Topology.Sets.Opens

/-!
# The category of open sets in a topological space.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define `to_Top : opens X ⥤ Top` and
`map (f : X ⟶ Y) : opens Y ⥤ opens X`, given by taking preimages of open sets.

Unfortunately `opens` isn't (usefully) a functor `Top ⥤ Cat`.
(One can in fact define such a functor,
but using it results in unresolvable `eq.rec` terms in goals.)

Really it's a 2-functor from (spaces, continuous functions, equalities)
to (categories, functors, natural isomorphisms).
We don't attempt to set up the full theory here, but do provide the natural isomorphisms
`map_id : map (𝟙 X) ≅ 𝟭 (opens X)` and
`map_comp : map (f ≫ g) ≅ map g ⋙ map f`.

Beyond that, there's a collection of simp lemmas for working with these constructions.
-/


open CategoryTheory

open TopologicalSpace

open Opposite

universe u

namespace TopologicalSpace.Opens

variable {X Y Z : TopCat.{u}}

/-!
Since `opens X` has a partial order, it automatically receives a `category` instance.
Unfortunately, because we do not allow morphisms in `Prop`,
the morphisms `U ⟶ V` are not just proofs `U ≤ V`, but rather
`ulift (plift (U ≤ V))`.
-/


#print TopologicalSpace.Opens.opensHomHasCoeToFun /-
instance opensHomHasCoeToFun {U V : Opens X} : CoeFun (U ⟶ V) fun f => U → V :=
  ⟨fun f x => ⟨x, f.le x.2⟩⟩
#align topological_space.opens.opens_hom_has_coe_to_fun TopologicalSpace.Opens.opensHomHasCoeToFun
-/

/-!
We now construct as morphisms various inclusions of open sets.
-/


#print TopologicalSpace.Opens.infLELeft /-
-- This is tedious, but necessary because we decided not to allow Prop as morphisms in a category...
/-- The inclusion `U ⊓ V ⟶ U` as a morphism in the category of open sets.
-/
def infLELeft (U V : Opens X) : U ⊓ V ⟶ U :=
  inf_le_left.Hom
#align topological_space.opens.inf_le_left TopologicalSpace.Opens.infLELeft
-/

#print TopologicalSpace.Opens.infLERight /-
/-- The inclusion `U ⊓ V ⟶ V` as a morphism in the category of open sets.
-/
def infLERight (U V : Opens X) : U ⊓ V ⟶ V :=
  inf_le_right.Hom
#align topological_space.opens.inf_le_right TopologicalSpace.Opens.infLERight
-/

#print TopologicalSpace.Opens.leSupr /-
/-- The inclusion `U i ⟶ supr U` as a morphism in the category of open sets.
-/
def leSupr {ι : Type _} (U : ι → Opens X) (i : ι) : U i ⟶ iSup U :=
  (le_iSup U i).Hom
#align topological_space.opens.le_supr TopologicalSpace.Opens.leSupr
-/

#print TopologicalSpace.Opens.botLE /-
/-- The inclusion `⊥ ⟶ U` as a morphism in the category of open sets.
-/
def botLE (U : Opens X) : ⊥ ⟶ U :=
  bot_le.Hom
#align topological_space.opens.bot_le TopologicalSpace.Opens.botLE
-/

#print TopologicalSpace.Opens.leTop /-
/-- The inclusion `U ⟶ ⊤` as a morphism in the category of open sets.
-/
def leTop (U : Opens X) : U ⟶ ⊤ :=
  le_top.Hom
#align topological_space.opens.le_top TopologicalSpace.Opens.leTop
-/

#print TopologicalSpace.Opens.infLELeft_apply /-
-- We do not mark this as a simp lemma because it breaks open `x`.
-- Nevertheless, it is useful in `sheaf_of_functions`.
theorem infLELeft_apply (U V : Opens X) (x) :
    (infLELeft U V) x = ⟨x.1, (@inf_le_left _ _ U V : _ ≤ _) x.2⟩ :=
  rfl
#align topological_space.opens.inf_le_left_apply TopologicalSpace.Opens.infLELeft_apply
-/

#print TopologicalSpace.Opens.infLELeft_apply_mk /-
@[simp]
theorem infLELeft_apply_mk (U V : Opens X) (x) (m) :
    (infLELeft U V) ⟨x, m⟩ = ⟨x, (@inf_le_left _ _ U V : _ ≤ _) m⟩ :=
  rfl
#align topological_space.opens.inf_le_left_apply_mk TopologicalSpace.Opens.infLELeft_apply_mk
-/

#print TopologicalSpace.Opens.leSupr_apply_mk /-
@[simp]
theorem leSupr_apply_mk {ι : Type _} (U : ι → Opens X) (i : ι) (x) (m) :
    (leSupr U i) ⟨x, m⟩ = ⟨x, (le_iSup U i : _) m⟩ :=
  rfl
#align topological_space.opens.le_supr_apply_mk TopologicalSpace.Opens.leSupr_apply_mk
-/

#print TopologicalSpace.Opens.toTopCat /-
/-- The functor from open sets in `X` to `Top`,
realising each open set as a topological space itself.
-/
def toTopCat (X : TopCat.{u}) : Opens X ⥤ TopCat
    where
  obj U := ⟨U, inferInstance⟩
  map U V i :=
    ⟨fun x => ⟨x.1, i.le x.2⟩,
      (Embedding.continuous_iff embedding_subtype_val).2 continuous_induced_dom⟩
#align topological_space.opens.to_Top TopologicalSpace.Opens.toTopCat
-/

#print TopologicalSpace.Opens.toTopCat_map /-
@[simp]
theorem toTopCat_map (X : TopCat.{u}) {U V : Opens X} {f : U ⟶ V} {x} {h} :
    ((toTopCat X).map f) ⟨x, h⟩ = ⟨x, f.le h⟩ :=
  rfl
#align topological_space.opens.to_Top_map TopologicalSpace.Opens.toTopCat_map
-/

#print TopologicalSpace.Opens.inclusion /-
/-- The inclusion map from an open subset to the whole space, as a morphism in `Top`.
-/
@[simps (config := { fullyApplied := false })]
def inclusion {X : TopCat.{u}} (U : Opens X) : (toTopCat X).obj U ⟶ X
    where
  toFun := _
  continuous_toFun := continuous_subtype_val
#align topological_space.opens.inclusion TopologicalSpace.Opens.inclusion
-/

#print TopologicalSpace.Opens.openEmbedding /-
theorem openEmbedding {X : TopCat.{u}} (U : Opens X) : OpenEmbedding (inclusion U) :=
  IsOpen.openEmbedding_subtype_val U.2
#align topological_space.opens.open_embedding TopologicalSpace.Opens.openEmbedding
-/

#print TopologicalSpace.Opens.inclusionTopIso /-
/-- The inclusion of the top open subset (i.e. the whole space) is an isomorphism.
-/
def inclusionTopIso (X : TopCat.{u}) : (toTopCat X).obj ⊤ ≅ X
    where
  Hom := inclusion ⊤
  inv := ⟨fun x => ⟨x, trivial⟩, continuous_def.2 fun U ⟨S, hS, hSU⟩ => hSU ▸ hS⟩
#align topological_space.opens.inclusion_top_iso TopologicalSpace.Opens.inclusionTopIso
-/

#print TopologicalSpace.Opens.map /-
/-- `opens.map f` gives the functor from open sets in Y to open set in X,
    given by taking preimages under f. -/
def map (f : X ⟶ Y) : Opens Y ⥤ Opens X
    where
  obj U := ⟨f ⁻¹' U, U.IsOpen.preimage f.Continuous⟩
  map U V i := ⟨⟨fun x h => i.le h⟩⟩
#align topological_space.opens.map TopologicalSpace.Opens.map
-/

#print TopologicalSpace.Opens.map_coe /-
theorem map_coe (f : X ⟶ Y) (U : Opens Y) : ↑((map f).obj U) = f ⁻¹' U :=
  rfl
#align topological_space.opens.map_coe TopologicalSpace.Opens.map_coe
-/

#print TopologicalSpace.Opens.map_obj /-
@[simp]
theorem map_obj (f : X ⟶ Y) (U) (p) : (map f).obj ⟨U, p⟩ = ⟨f ⁻¹' U, p.preimage f.Continuous⟩ :=
  rfl
#align topological_space.opens.map_obj TopologicalSpace.Opens.map_obj
-/

#print TopologicalSpace.Opens.map_id_obj /-
@[simp]
theorem map_id_obj (U : Opens X) : (map (𝟙 X)).obj U = U :=
  let ⟨_, _⟩ := U
  rfl
#align topological_space.opens.map_id_obj TopologicalSpace.Opens.map_id_obj
-/

#print TopologicalSpace.Opens.map_id_obj' /-
@[simp]
theorem map_id_obj' (U) (p) : (map (𝟙 X)).obj ⟨U, p⟩ = ⟨U, p⟩ :=
  rfl
#align topological_space.opens.map_id_obj' TopologicalSpace.Opens.map_id_obj'
-/

#print TopologicalSpace.Opens.map_id_obj_unop /-
@[simp]
theorem map_id_obj_unop (U : (Opens X)ᵒᵖ) : (map (𝟙 X)).obj (unop U) = unop U :=
  let ⟨_, _⟩ := U.unop
  rfl
#align topological_space.opens.map_id_obj_unop TopologicalSpace.Opens.map_id_obj_unop
-/

#print TopologicalSpace.Opens.op_map_id_obj /-
@[simp]
theorem op_map_id_obj (U : (Opens X)ᵒᵖ) : (map (𝟙 X)).op.obj U = U := by simp
#align topological_space.opens.op_map_id_obj TopologicalSpace.Opens.op_map_id_obj
-/

#print TopologicalSpace.Opens.leMapTop /-
/-- The inclusion `U ⟶ (map f).obj ⊤` as a morphism in the category of open sets.
-/
def leMapTop (f : X ⟶ Y) (U : Opens X) : U ⟶ (map f).obj ⊤ :=
  leTop U
#align topological_space.opens.le_map_top TopologicalSpace.Opens.leMapTop
-/

#print TopologicalSpace.Opens.map_comp_obj /-
@[simp]
theorem map_comp_obj (f : X ⟶ Y) (g : Y ⟶ Z) (U) :
    (map (f ≫ g)).obj U = (map f).obj ((map g).obj U) :=
  rfl
#align topological_space.opens.map_comp_obj TopologicalSpace.Opens.map_comp_obj
-/

#print TopologicalSpace.Opens.map_comp_obj' /-
@[simp]
theorem map_comp_obj' (f : X ⟶ Y) (g : Y ⟶ Z) (U) (p) :
    (map (f ≫ g)).obj ⟨U, p⟩ = (map f).obj ((map g).obj ⟨U, p⟩) :=
  rfl
#align topological_space.opens.map_comp_obj' TopologicalSpace.Opens.map_comp_obj'
-/

#print TopologicalSpace.Opens.map_comp_map /-
@[simp]
theorem map_comp_map (f : X ⟶ Y) (g : Y ⟶ Z) {U V} (i : U ⟶ V) :
    (map (f ≫ g)).map i = (map f).map ((map g).map i) :=
  rfl
#align topological_space.opens.map_comp_map TopologicalSpace.Opens.map_comp_map
-/

#print TopologicalSpace.Opens.map_comp_obj_unop /-
@[simp]
theorem map_comp_obj_unop (f : X ⟶ Y) (g : Y ⟶ Z) (U) :
    (map (f ≫ g)).obj (unop U) = (map f).obj ((map g).obj (unop U)) :=
  rfl
#align topological_space.opens.map_comp_obj_unop TopologicalSpace.Opens.map_comp_obj_unop
-/

#print TopologicalSpace.Opens.op_map_comp_obj /-
@[simp]
theorem op_map_comp_obj (f : X ⟶ Y) (g : Y ⟶ Z) (U) :
    (map (f ≫ g)).op.obj U = (map f).op.obj ((map g).op.obj U) :=
  rfl
#align topological_space.opens.op_map_comp_obj TopologicalSpace.Opens.op_map_comp_obj
-/

#print TopologicalSpace.Opens.map_iSup /-
theorem map_iSup (f : X ⟶ Y) {ι : Type _} (U : ι → Opens Y) :
    (map f).obj (iSup U) = iSup ((map f).obj ∘ U) :=
  by
  ext1; rw [supr_def, supr_def, map_obj]
  dsimp; rw [Set.preimage_iUnion]; rfl
#align topological_space.opens.map_supr TopologicalSpace.Opens.map_iSup
-/

section

variable (X)

#print TopologicalSpace.Opens.mapId /-
/-- The functor `opens X ⥤ opens X` given by taking preimages under the identity function
is naturally isomorphic to the identity functor.
-/
@[simps]
def mapId : map (𝟙 X) ≅ 𝟭 (Opens X)
    where
  Hom := { app := fun U => eqToHom (map_id_obj U) }
  inv := { app := fun U => eqToHom (map_id_obj U).symm }
#align topological_space.opens.map_id TopologicalSpace.Opens.mapId
-/

#print TopologicalSpace.Opens.map_id_eq /-
theorem map_id_eq : map (𝟙 X) = 𝟭 (Opens X) := by unfold map; congr; ext; rfl; ext
#align topological_space.opens.map_id_eq TopologicalSpace.Opens.map_id_eq
-/

end

#print TopologicalSpace.Opens.mapComp /-
/-- The natural isomorphism between taking preimages under `f ≫ g`, and the composite
of taking preimages under `g`, then preimages under `f`.
-/
@[simps]
def mapComp (f : X ⟶ Y) (g : Y ⟶ Z) : map (f ≫ g) ≅ map g ⋙ map f
    where
  Hom := { app := fun U => eqToHom (map_comp_obj f g U) }
  inv := { app := fun U => eqToHom (map_comp_obj f g U).symm }
#align topological_space.opens.map_comp TopologicalSpace.Opens.mapComp
-/

#print TopologicalSpace.Opens.map_comp_eq /-
theorem map_comp_eq (f : X ⟶ Y) (g : Y ⟶ Z) : map (f ≫ g) = map g ⋙ map f :=
  rfl
#align topological_space.opens.map_comp_eq TopologicalSpace.Opens.map_comp_eq
-/

#print TopologicalSpace.Opens.mapIso /-
-- We could make `f g` implicit here, but it's nice to be able to see when
-- they are the identity (often!)
/-- If two continuous maps `f g : X ⟶ Y` are equal,
then the functors `opens Y ⥤ opens X` they induce are isomorphic.
-/
def mapIso (f g : X ⟶ Y) (h : f = g) : map f ≅ map g :=
  NatIso.ofComponents (fun U => eqToIso (congr_fun (congr_arg Functor.obj (congr_arg map h)) U))
    (by obviously)
#align topological_space.opens.map_iso TopologicalSpace.Opens.mapIso
-/

#print TopologicalSpace.Opens.map_eq /-
theorem map_eq (f g : X ⟶ Y) (h : f = g) : map f = map g := by unfold map; congr; ext; rw [h];
  rw [h]; assumption'
#align topological_space.opens.map_eq TopologicalSpace.Opens.map_eq
-/

#print TopologicalSpace.Opens.mapIso_refl /-
@[simp]
theorem mapIso_refl (f : X ⟶ Y) (h) : mapIso f f h = Iso.refl (map _) :=
  rfl
#align topological_space.opens.map_iso_refl TopologicalSpace.Opens.mapIso_refl
-/

#print TopologicalSpace.Opens.mapIso_hom_app /-
@[simp]
theorem mapIso_hom_app (f g : X ⟶ Y) (h : f = g) (U : Opens Y) :
    (mapIso f g h).Hom.app U = eqToHom (congr_fun (congr_arg Functor.obj (congr_arg map h)) U) :=
  rfl
#align topological_space.opens.map_iso_hom_app TopologicalSpace.Opens.mapIso_hom_app
-/

#print TopologicalSpace.Opens.mapIso_inv_app /-
@[simp]
theorem mapIso_inv_app (f g : X ⟶ Y) (h : f = g) (U : Opens Y) :
    (mapIso f g h).inv.app U =
      eqToHom (congr_fun (congr_arg Functor.obj (congr_arg map h.symm)) U) :=
  rfl
#align topological_space.opens.map_iso_inv_app TopologicalSpace.Opens.mapIso_inv_app
-/

#print TopologicalSpace.Opens.mapMapIso /-
/-- A homeomorphism of spaces gives an equivalence of categories of open sets.

TODO: define `order_iso.equivalence`, use it.
-/
@[simps]
def mapMapIso {X Y : TopCat.{u}} (H : X ≅ Y) : Opens Y ≌ Opens X
    where
  Functor := map H.Hom
  inverse := map H.inv
  unitIso :=
    NatIso.ofComponents (fun U => eqToIso (by simp [map, Set.preimage_preimage]))
      (by intro _ _ _; simp)
  counitIso :=
    NatIso.ofComponents (fun U => eqToIso (by simp [map, Set.preimage_preimage]))
      (by intro _ _ _; simp)
#align topological_space.opens.map_map_iso TopologicalSpace.Opens.mapMapIso
-/

end TopologicalSpace.Opens

#print IsOpenMap.functor /-
/-- An open map `f : X ⟶ Y` induces a functor `opens X ⥤ opens Y`.
-/
@[simps]
def IsOpenMap.functor {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) : Opens X ⥤ Opens Y
    where
  obj U := ⟨f '' U, hf U U.2⟩
  map U V h := ⟨⟨Set.image_subset _ h.down.down⟩⟩
#align is_open_map.functor IsOpenMap.functor
-/

#print IsOpenMap.adjunction /-
/-- An open map `f : X ⟶ Y` induces an adjunction between `opens X` and `opens Y`.
-/
def IsOpenMap.adjunction {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) :
    Adjunction hf.Functor (TopologicalSpace.Opens.map f) :=
  Adjunction.mkOfUnitCounit
    { Unit := { app := fun U => homOfLE fun x hxU => ⟨x, hxU, rfl⟩ }
      counit := { app := fun V => homOfLE fun y ⟨x, hfxV, hxy⟩ => hxy ▸ hfxV } }
#align is_open_map.adjunction IsOpenMap.adjunction
-/

#print IsOpenMap.functorFullOfMono /-
instance IsOpenMap.functorFullOfMono {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) [H : Mono f] :
    Full hf.Functor
    where preimage U V i :=
    homOfLE fun x hx => by obtain ⟨y, hy, eq⟩ := i.le ⟨x, hx, rfl⟩;
      exact (TopCat.mono_iff_injective f).mp H Eq ▸ hy
#align is_open_map.functor_full_of_mono IsOpenMap.functorFullOfMono
-/

#print IsOpenMap.functor_faithful /-
instance IsOpenMap.functor_faithful {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) :
    Faithful hf.Functor where
#align is_open_map.functor_faithful IsOpenMap.functor_faithful
-/

namespace TopologicalSpace.Opens

open TopologicalSpace

#print TopologicalSpace.Opens.openEmbedding_obj_top /-
@[simp]
theorem openEmbedding_obj_top {X : TopCat} (U : Opens X) :
    U.OpenEmbedding.IsOpenMap.Functor.obj ⊤ = U := by ext1;
  exact set.image_univ.trans Subtype.range_coe
#align topological_space.opens.open_embedding_obj_top TopologicalSpace.Opens.openEmbedding_obj_top
-/

#print TopologicalSpace.Opens.inclusion_map_eq_top /-
@[simp]
theorem inclusion_map_eq_top {X : TopCat} (U : Opens X) : (Opens.map U.inclusion).obj U = ⊤ := by
  ext1; exact Subtype.coe_preimage_self _
#align topological_space.opens.inclusion_map_eq_top TopologicalSpace.Opens.inclusion_map_eq_top
-/

#print TopologicalSpace.Opens.adjunction_counit_app_self /-
@[simp]
theorem adjunction_counit_app_self {X : TopCat} (U : Opens X) :
    U.OpenEmbedding.IsOpenMap.Adjunction.counit.app U = eqToHom (by simp) := by ext
#align topological_space.opens.adjunction_counit_app_self TopologicalSpace.Opens.adjunction_counit_app_self
-/

#print TopologicalSpace.Opens.inclusion_top_functor /-
theorem inclusion_top_functor (X : TopCat) :
    (@Opens.openEmbedding X ⊤).IsOpenMap.Functor = map (inclusionTopIso X).inv :=
  by
  apply functor.hext; intro;
  abstract obj_eq 
    ext
    exact ⟨fun ⟨⟨_, _⟩, h, rfl⟩ => h, fun h => ⟨⟨x, trivial⟩, h, rfl⟩⟩
  intros; apply Subsingleton.helim; congr 1
  iterate 2 apply inclusion_top_functor.obj_eq
#align topological_space.opens.inclusion_top_functor TopologicalSpace.Opens.inclusion_top_functor
-/

#print TopologicalSpace.Opens.functor_obj_map_obj /-
theorem functor_obj_map_obj {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) (U : Opens Y) :
    hf.Functor.obj ((Opens.map f).obj U) = hf.Functor.obj ⊤ ⊓ U :=
  by
  ext; constructor
  · rintro ⟨x, hx, rfl⟩; exact ⟨⟨x, trivial, rfl⟩, hx⟩
  · rintro ⟨⟨x, -, rfl⟩, hx⟩; exact ⟨x, hx, rfl⟩
#align topological_space.opens.functor_obj_map_obj TopologicalSpace.Opens.functor_obj_map_obj
-/

#print TopologicalSpace.Opens.functor_map_eq_inf /-
@[simp]
theorem functor_map_eq_inf {X : TopCat} (U V : Opens X) :
    U.OpenEmbedding.IsOpenMap.Functor.obj ((Opens.map U.inclusion).obj V) = V ⊓ U := by ext1;
  refine' set.image_preimage_eq_inter_range.trans _; simpa
#align topological_space.opens.functor_map_eq_inf TopologicalSpace.Opens.functor_map_eq_inf
-/

#print TopologicalSpace.Opens.map_functor_eq' /-
theorem map_functor_eq' {X U : TopCat} (f : U ⟶ X) (hf : OpenEmbedding f) (V) :
    ((Opens.map f).obj <| hf.IsOpenMap.Functor.obj V) = V :=
  Opens.ext <| Set.preimage_image_eq _ hf.inj
#align topological_space.opens.map_functor_eq' TopologicalSpace.Opens.map_functor_eq'
-/

#print TopologicalSpace.Opens.map_functor_eq /-
@[simp]
theorem map_functor_eq {X : TopCat} {U : Opens X} (V : Opens U) :
    ((Opens.map U.inclusion).obj <| U.OpenEmbedding.IsOpenMap.Functor.obj V) = V :=
  TopologicalSpace.Opens.map_functor_eq' _ U.OpenEmbedding V
#align topological_space.opens.map_functor_eq TopologicalSpace.Opens.map_functor_eq
-/

#print TopologicalSpace.Opens.adjunction_counit_map_functor /-
@[simp]
theorem adjunction_counit_map_functor {X : TopCat} {U : Opens X} (V : Opens U) :
    U.OpenEmbedding.IsOpenMap.Adjunction.counit.app (U.OpenEmbedding.IsOpenMap.Functor.obj V) =
      eqToHom (by conv_rhs => rw [← V.map_functor_eq]; rfl) :=
  by ext
#align topological_space.opens.adjunction_counit_map_functor TopologicalSpace.Opens.adjunction_counit_map_functor
-/

end TopologicalSpace.Opens

