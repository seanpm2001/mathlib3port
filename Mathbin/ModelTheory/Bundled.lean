/-
Copyright (c) 2022 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module model_theory.bundled
! leanprover-community/mathlib commit dbdf71cee7bb20367cb7e37279c08b0c218cf967
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.ModelTheory.ElementaryMaps
import Mathbin.CategoryTheory.ConcreteCategory.Bundled

/-!
# Bundled First-Order Structures

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
This file bundles types together with their first-order structure.

## Main Definitions
* `first_order.language.Theory.Model` is the type of nonempty models of a particular theory.
* `first_order.language.equiv_setoid` is the isomorphism equivalence relation on bundled structures.

## TODO
* Define category structures on bundled structures and models.

-/


universe u v w w'

variable {L : FirstOrder.Language.{u, v}}

#print CategoryTheory.Bundled.structure /-
@[protected]
instance CategoryTheory.Bundled.structure {L : FirstOrder.Language.{u, v}}
    (M : CategoryTheory.Bundled.{w} L.Structure) : L.Structure M :=
  M.str
#align category_theory.bundled.Structure CategoryTheory.Bundled.structure
-/

open scoped FirstOrder Cardinal

namespace Equiv

variable (L) {M : Type w} [L.Structure M] {N : Type w'} (g : M ≃ N)

#print Equiv.bundledInduced /-
/-- A type bundled with the structure induced by an equivalence. -/
@[simps]
def bundledInduced : CategoryTheory.Bundled.{w'} L.Structure :=
  ⟨N, g.inducedStructure⟩
#align equiv.bundled_induced Equiv.bundledInduced
-/

#print Equiv.bundledInducedEquiv /-
/-- An equivalence of types as a first-order equivalence to the bundled structure on the codomain.
-/
@[simp]
def bundledInducedEquiv : M ≃[L] g.bundledInduced L :=
  g.inducedStructureEquiv
#align equiv.bundled_induced_equiv Equiv.bundledInducedEquiv
-/

end Equiv

namespace FirstOrder

namespace Language

#print FirstOrder.Language.equivSetoid /-
/-- The equivalence relation on bundled `L.Structure`s indicating that they are isomorphic. -/
instance equivSetoid : Setoid (CategoryTheory.Bundled L.Structure)
    where
  R M N := Nonempty (M ≃[L] N)
  iseqv :=
    ⟨fun M => ⟨Equiv.refl L M⟩, fun M N => Nonempty.map Equiv.symm, fun M N P =>
      Nonempty.map2 fun MN NP => NP.comp MN⟩
#align first_order.language.equiv_setoid FirstOrder.Language.equivSetoid
-/

variable (T : L.Theory)

namespace Theory

#print FirstOrder.Language.Theory.ModelType /-
/-- The type of nonempty models of a first-order theory. -/
structure ModelType where
  carrier : Type w
  [struc : L.Structure carrier]
  [is_model : T.Model carrier]
  [nonempty' : Nonempty carrier]
#align first_order.language.Theory.Model FirstOrder.Language.Theory.ModelType
-/

attribute [instance] Model.struc Model.is_model Model.nonempty'

namespace Model

instance : CoeSort T.ModelType (Type w) :=
  ⟨ModelType.Carrier⟩

@[simp]
theorem carrier_eq_coe (M : T.ModelType) : M.carrier = M :=
  rfl
#align first_order.language.Theory.Model.carrier_eq_coe FirstOrder.Language.Theory.ModelType.carrier_eq_coe

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print FirstOrder.Language.Theory.ModelType.of /-
/-- The object in the category of R-algebras associated to a type equipped with the appropriate
typeclasses. -/
def of (M : Type w) [L.Structure M] [M ⊨ T] [Nonempty M] : T.ModelType :=
  ⟨M⟩
#align first_order.language.Theory.Model.of FirstOrder.Language.Theory.ModelType.of
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print FirstOrder.Language.Theory.ModelType.coe_of /-
@[simp]
theorem coe_of (M : Type w) [L.Structure M] [M ⊨ T] [Nonempty M] : (of T M : Type w) = M :=
  rfl
#align first_order.language.Theory.Model.coe_of FirstOrder.Language.Theory.ModelType.coe_of
-/

instance (M : T.ModelType) : Nonempty M :=
  inferInstance

section Inhabited

attribute [local instance] inhabited.trivial_structure

instance : Inhabited (ModelType.{u, v, w} (∅ : L.Theory)) :=
  ⟨ModelType.of _ PUnit⟩

end Inhabited

variable {T}

#print FirstOrder.Language.Theory.ModelType.equivInduced /-
/-- Maps a bundled model along a bijection. -/
def equivInduced {M : ModelType.{u, v, w} T} {N : Type w'} (e : M ≃ N) : ModelType.{u, v, w'} T
    where
  carrier := N
  struc := e.inducedStructure
  is_model := @Equiv.theory_model L M N _ e.inducedStructure T e.inducedStructureEquiv _
  nonempty' := e.symm.Nonempty
#align first_order.language.Theory.Model.equiv_induced FirstOrder.Language.Theory.ModelType.equivInduced
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print FirstOrder.Language.Theory.ModelType.of_small /-
instance of_small (M : Type w) [Nonempty M] [L.Structure M] [M ⊨ T] [h : Small.{w'} M] :
    Small.{w'} (ModelType.of T M) :=
  h
#align first_order.language.Theory.Model.of_small FirstOrder.Language.Theory.ModelType.of_small
-/

#print FirstOrder.Language.Theory.ModelType.shrink /-
/-- Shrinks a small model to a particular universe. -/
noncomputable def shrink (M : ModelType.{u, v, w} T) [Small.{w'} M] : ModelType.{u, v, w'} T :=
  equivInduced (equivShrink M)
#align first_order.language.Theory.Model.shrink FirstOrder.Language.Theory.ModelType.shrink
-/

#print FirstOrder.Language.Theory.ModelType.ulift /-
/-- Lifts a model to a particular universe. -/
def ulift (M : ModelType.{u, v, w} T) : ModelType.{u, v, max w w'} T :=
  equivInduced (Equiv.ulift.symm : M ≃ _)
#align first_order.language.Theory.Model.ulift FirstOrder.Language.Theory.ModelType.ulift
-/

#print FirstOrder.Language.Theory.ModelType.reduct /-
/-- The reduct of any model of `φ.on_Theory T` is a model of `T`. -/
@[simps]
def reduct {L' : Language} (φ : L →ᴸ L') (M : (φ.onTheory T).ModelType) : T.ModelType
    where
  carrier := M
  struc := φ.reduct M
  nonempty' := M.nonempty'
  is_model := (@LHom.onTheory_model L L' M (φ.reduct M) _ φ _ T).1 M.is_model
#align first_order.language.Theory.Model.reduct FirstOrder.Language.Theory.ModelType.reduct
-/

#print FirstOrder.Language.Theory.ModelType.defaultExpansion /-
/-- When `φ` is injective, `default_expansion` expands a model of `T` to a model of `φ.on_Theory T`
  arbitrarily. -/
@[simps]
noncomputable def defaultExpansion {L' : Language} {φ : L →ᴸ L'} (h : φ.Injective)
    [∀ (n) (f : L'.Functions n), Decidable (f ∈ Set.range fun f : L.Functions n => φ.onFunction f)]
    [∀ (n) (r : L'.Relations n), Decidable (r ∈ Set.range fun r : L.Relations n => φ.onRelation r)]
    (M : T.ModelType) [Inhabited M] : (φ.onTheory T).ModelType
    where
  carrier := M
  struc := φ.defaultExpansion M
  nonempty' := M.nonempty'
  is_model :=
    (@LHom.onTheory_model L L' M _ (φ.defaultExpansion M) φ (h.isExpansionOn_default M) T).2
      M.is_model
#align first_order.language.Theory.Model.default_expansion FirstOrder.Language.Theory.ModelType.defaultExpansion
-/

#print FirstOrder.Language.Theory.ModelType.leftStructure /-
instance leftStructure {L' : Language} {T : (L.Sum L').Theory} (M : T.ModelType) : L.Structure M :=
  (LHom.sumInl : L →ᴸ L.Sum L').reduct M
#align first_order.language.Theory.Model.left_Structure FirstOrder.Language.Theory.ModelType.leftStructure
-/

#print FirstOrder.Language.Theory.ModelType.rightStructure /-
instance rightStructure {L' : Language} {T : (L.Sum L').Theory} (M : T.ModelType) :
    L'.Structure M :=
  (LHom.sumInr : L' →ᴸ L.Sum L').reduct M
#align first_order.language.Theory.Model.right_Structure FirstOrder.Language.Theory.ModelType.rightStructure
-/

#print FirstOrder.Language.Theory.ModelType.subtheoryModel /-
/-- A model of a theory is also a model of any subtheory. -/
@[simps]
def subtheoryModel (M : T.ModelType) {T' : L.Theory} (h : T' ⊆ T) : T'.ModelType
    where
  carrier := M
  is_model := ⟨fun φ hφ => realize_sentence_of_mem T (h hφ)⟩
#align first_order.language.Theory.Model.subtheory_Model FirstOrder.Language.Theory.ModelType.subtheoryModel
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print FirstOrder.Language.Theory.ModelType.subtheoryModel_models /-
instance subtheoryModel_models (M : T.ModelType) {T' : L.Theory} (h : T' ⊆ T) :
    M.subtheoryModel h ⊨ T :=
  M.is_model
#align first_order.language.Theory.Model.subtheory_Model_models FirstOrder.Language.Theory.ModelType.subtheoryModel_models
-/

end Model

variable {T}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print FirstOrder.Language.Theory.Model.bundled /-
/-- Bundles `M ⊨ T` as a `T.Model`. -/
def Model.bundled {M : Type w} [LM : L.Structure M] [ne : Nonempty M] (h : M ⊨ T) : T.ModelType :=
  @ModelType.of L T M LM h Ne
#align first_order.language.Theory.model.bundled FirstOrder.Language.Theory.Model.bundled
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print FirstOrder.Language.Theory.coe_of /-
@[simp]
theorem coe_of {M : Type w} [L.Structure M] [Nonempty M] (h : M ⊨ T) : (h.Bundled : Type w) = M :=
  rfl
#align first_order.language.Theory.coe_of FirstOrder.Language.Theory.coe_of
-/

end Theory

#print FirstOrder.Language.ElementarilyEquivalent.toModel /-
/-- A structure that is elementarily equivalent to a model, bundled as a model. -/
def ElementarilyEquivalent.toModel {M : T.ModelType} {N : Type _} [LN : L.Structure N]
    (h : M ≅[L] N) : T.ModelType where
  carrier := N
  struc := LN
  nonempty' := h.Nonempty
  is_model := h.theory_model
#align first_order.language.elementarily_equivalent.to_Model FirstOrder.Language.ElementarilyEquivalent.toModel
-/

#print FirstOrder.Language.ElementarySubstructure.toModel /-
/-- An elementary substructure of a bundled model as a bundled model. -/
def ElementarySubstructure.toModel {M : T.ModelType} (S : L.ElementarySubstructure M) :
    T.ModelType :=
  S.ElementarilyEquivalent.symm.toModel T
#align first_order.language.elementary_substructure.to_Model FirstOrder.Language.ElementarySubstructure.toModel
-/

instance {M : T.ModelType} (S : L.ElementarySubstructure M) [h : Small S] : Small (S.toModel T) :=
  h

end Language

end FirstOrder

