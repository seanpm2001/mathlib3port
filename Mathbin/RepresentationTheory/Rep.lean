/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module representation_theory.Rep
! leanprover-community/mathlib commit 1b089e3bdc3ce6b39cd472543474a0a137128c6c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RepresentationTheory.Basic
import Mathbin.RepresentationTheory.Action
import Mathbin.Algebra.Category.Module.Abelian
import Mathbin.Algebra.Category.Module.Colimits
import Mathbin.Algebra.Category.Module.Monoidal.Closed
import Mathbin.Algebra.Category.Module.Adjunctions
import Mathbin.CategoryTheory.Closed.FunctorCategory

/-!
# `Rep k G` is the category of `k`-linear representations of `G`.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

If `V : Rep k G`, there is a coercion that allows you to treat `V` as a type,
and this type comes equipped with a `module k V` instance.
Also `V.ρ` gives the homomorphism `G →* (V →ₗ[k] V)`.

Conversely, given a homomorphism `ρ : G →* (V →ₗ[k] V)`,
you can construct the bundled representation as `Rep.of ρ`.

We construct the categorical equivalence `Rep k G ≌ Module (monoid_algebra k G)`.
We verify that `Rep k G` is a `k`-linear abelian symmetric monoidal category with all (co)limits.
-/


universe u

open CategoryTheory

open CategoryTheory.Limits

/- ./././Mathport/Syntax/Translate/Command.lean:328:31: unsupported: @[derive] abbrev -/
#print Rep /-
/-- The category of `k`-linear representations of a monoid `G`. -/
abbrev Rep (k G : Type u) [Ring k] [Monoid G] :=
  Action (ModuleCat.{u} k) (MonCat.of G)
#align Rep Rep
-/

instance (k G : Type u) [CommRing k] [Monoid G] : Linear k (Rep k G) := by infer_instance

namespace Rep

variable {k G : Type u} [CommRing k]

section

variable [Monoid G]

instance : CoeSort (Rep k G) (Type u) :=
  ConcreteCategory.hasCoeToSort _

instance (V : Rep k G) : AddCommGroup V := by
  change AddCommGroup ((forget₂ (Rep k G) (ModuleCat k)).obj V); infer_instance

instance (V : Rep k G) : Module k V := by change Module k ((forget₂ (Rep k G) (ModuleCat k)).obj V);
  infer_instance

#print Rep.ρ /-
/-- Specialize the existing `Action.ρ`, changing the type to `representation k G V`.
-/
def ρ (V : Rep k G) : Representation k G V :=
  V.ρ
#align Rep.ρ Rep.ρ
-/

#print Rep.of /-
/-- Lift an unbundled representation to `Rep`. -/
def of {V : Type u} [AddCommGroup V] [Module k V] (ρ : G →* V →ₗ[k] V) : Rep k G :=
  ⟨ModuleCat.of k V, ρ⟩
#align Rep.of Rep.of
-/

#print Rep.coe_of /-
@[simp]
theorem coe_of {V : Type u} [AddCommGroup V] [Module k V] (ρ : G →* V →ₗ[k] V) :
    (of ρ : Type u) = V :=
  rfl
#align Rep.coe_of Rep.coe_of
-/

#print Rep.of_ρ /-
@[simp]
theorem of_ρ {V : Type u} [AddCommGroup V] [Module k V] (ρ : G →* V →ₗ[k] V) : (of ρ).ρ = ρ :=
  rfl
#align Rep.of_ρ Rep.of_ρ
-/

#print Rep.Action_ρ_eq_ρ /-
theorem Action_ρ_eq_ρ {A : Rep k G} : Action.ρ A = A.ρ :=
  rfl
#align Rep.Action_ρ_eq_ρ Rep.Action_ρ_eq_ρ
-/

#print Rep.of_ρ_apply /-
/-- Allows us to apply lemmas about the underlying `ρ`, which would take an element `g : G` rather
than `g : Mon.of G` as an argument. -/
theorem of_ρ_apply {V : Type u} [AddCommGroup V] [Module k V] (ρ : Representation k G V)
    (g : MonCat.of G) : (Rep.of ρ).ρ g = ρ (g : G) :=
  rfl
#align Rep.of_ρ_apply Rep.of_ρ_apply
-/

#print Rep.ρ_inv_self_apply /-
@[simp]
theorem ρ_inv_self_apply {G : Type u} [Group G] (A : Rep k G) (g : G) (x : A) :
    A.ρ g⁻¹ (A.ρ g x) = x :=
  show (A.ρ g⁻¹ * A.ρ g) x = x by rw [← map_mul, inv_mul_self, map_one, LinearMap.one_apply]
#align Rep.ρ_inv_self_apply Rep.ρ_inv_self_apply
-/

#print Rep.ρ_self_inv_apply /-
@[simp]
theorem ρ_self_inv_apply {G : Type u} [Group G] {A : Rep k G} (g : G) (x : A) :
    A.ρ g (A.ρ g⁻¹ x) = x :=
  show (A.ρ g * A.ρ g⁻¹) x = x by rw [← map_mul, mul_inv_self, map_one, LinearMap.one_apply]
#align Rep.ρ_self_inv_apply Rep.ρ_self_inv_apply
-/

#print Rep.hom_comm_apply /-
theorem hom_comm_apply {A B : Rep k G} (f : A ⟶ B) (g : G) (x : A) :
    f.hom (A.ρ g x) = B.ρ g (f.hom x) :=
  LinearMap.ext_iff.1 (f.comm g) x
#align Rep.hom_comm_apply Rep.hom_comm_apply
-/

variable (k G)

#print Rep.trivial /-
/-- The trivial `k`-linear `G`-representation on a `k`-module `V.` -/
def trivial (V : Type u) [AddCommGroup V] [Module k V] : Rep k G :=
  Rep.of (@Representation.trivial k G V _ _ _ _)
#align Rep.trivial Rep.trivial
-/

variable {k G}

#print Rep.trivial_def /-
theorem trivial_def {V : Type u} [AddCommGroup V] [Module k V] (g : G) (v : V) :
    (trivial k G V).ρ g v = v :=
  rfl
#align Rep.trivial_def Rep.trivial_def
-/

-- Verify that limits are calculated correctly.
noncomputable example : PreservesLimits (forget₂ (Rep k G) (ModuleCat.{u} k)) := by infer_instance

noncomputable example : PreservesColimits (forget₂ (Rep k G) (ModuleCat.{u} k)) := by infer_instance

#print Rep.MonoidalCategory.braiding_hom_apply /-
@[simp]
theorem MonoidalCategory.braiding_hom_apply {A B : Rep k G} (x : A) (y : B) :
    Action.Hom.hom (β_ A B).hom (TensorProduct.tmul k x y) = TensorProduct.tmul k y x :=
  rfl
#align Rep.monoidal_category.braiding_hom_apply Rep.MonoidalCategory.braiding_hom_apply
-/

#print Rep.MonoidalCategory.braiding_inv_apply /-
@[simp]
theorem MonoidalCategory.braiding_inv_apply {A B : Rep k G} (x : A) (y : B) :
    Action.Hom.hom (β_ A B).inv (TensorProduct.tmul k y x) = TensorProduct.tmul k x y :=
  rfl
#align Rep.monoidal_category.braiding_inv_apply Rep.MonoidalCategory.braiding_inv_apply
-/

section Linearization

variable (k G)

#print Rep.linearization /-
/-- The monoidal functor sending a type `H` with a `G`-action to the induced `k`-linear
`G`-representation on `k[H].` -/
noncomputable def linearization : MonoidalFunctor (Action (Type u) (MonCat.of G)) (Rep k G) :=
  (ModuleCat.monoidalFree k).mapAction (MonCat.of G)
#align Rep.linearization Rep.linearization
-/

variable {k G}

#print Rep.linearization_obj_ρ /-
@[simp]
theorem linearization_obj_ρ (X : Action (Type u) (MonCat.of G)) (g : G) (x : X.V →₀ k) :
    ((linearization k G).obj X).ρ g x = Finsupp.lmapDomain k k (X.ρ g) x :=
  rfl
#align Rep.linearization_obj_ρ Rep.linearization_obj_ρ
-/

#print Rep.linearization_of /-
@[simp]
theorem linearization_of (X : Action (Type u) (MonCat.of G)) (g : G) (x : X.V) :
    ((linearization k G).obj X).ρ g (Finsupp.single x (1 : k)) = Finsupp.single (X.ρ g x) (1 : k) :=
  by rw [linearization_obj_ρ, Finsupp.lmapDomain_apply, Finsupp.mapDomain_single]
#align Rep.linearization_of Rep.linearization_of
-/

variable {X Y : Action (Type u) (MonCat.of G)} (f : X ⟶ Y)

#print Rep.linearization_map_hom /-
@[simp]
theorem linearization_map_hom : ((linearization k G).map f).hom = Finsupp.lmapDomain k k f.hom :=
  rfl
#align Rep.linearization_map_hom Rep.linearization_map_hom
-/

#print Rep.linearization_map_hom_single /-
theorem linearization_map_hom_single (x : X.V) (r : k) :
    ((linearization k G).map f).hom (Finsupp.single x r) = Finsupp.single (f.hom x) r := by
  rw [linearization_map_hom, Finsupp.lmapDomain_apply, Finsupp.mapDomain_single]
#align Rep.linearization_map_hom_single Rep.linearization_map_hom_single
-/

#print Rep.linearization_μ_hom /-
@[simp]
theorem linearization_μ_hom (X Y : Action (Type u) (MonCat.of G)) :
    ((linearization k G).μ X Y).hom = (finsuppTensorFinsupp' k X.V Y.V).toLinearMap :=
  rfl
#align Rep.linearization_μ_hom Rep.linearization_μ_hom
-/

#print Rep.linearization_μ_inv_hom /-
@[simp]
theorem linearization_μ_inv_hom (X Y : Action (Type u) (MonCat.of G)) :
    (inv ((linearization k G).μ X Y)).hom = (finsuppTensorFinsupp' k X.V Y.V).symm.toLinearMap :=
  by
  simp_rw [← Action.forget_map, functor.map_inv, Action.forget_map, linearization_μ_hom]
  apply is_iso.inv_eq_of_hom_inv_id _
  exact LinearMap.ext fun x => LinearEquiv.symm_apply_apply _ _
#align Rep.linearization_μ_inv_hom Rep.linearization_μ_inv_hom
-/

#print Rep.linearization_ε_hom /-
@[simp]
theorem linearization_ε_hom : (linearization k G).ε.hom = Finsupp.lsingle PUnit.unit :=
  rfl
#align Rep.linearization_ε_hom Rep.linearization_ε_hom
-/

#print Rep.linearization_ε_inv_hom_apply /-
@[simp]
theorem linearization_ε_inv_hom_apply (r : k) :
    (inv (linearization k G).ε).hom (Finsupp.single PUnit.unit r) = r :=
  by
  simp_rw [← Action.forget_map, functor.map_inv, Action.forget_map]
  rw [← Finsupp.lsingle_apply PUnit.unit r]
  apply is_iso.hom_inv_id_apply _ _
#align Rep.linearization_ε_inv_hom_apply Rep.linearization_ε_inv_hom_apply
-/

variable (k G)

#print Rep.linearizationTrivialIso /-
/-- The linearization of a type `X` on which `G` acts trivially is the trivial `G`-representation
on `k[X]`. -/
@[simps]
noncomputable def linearizationTrivialIso (X : Type u) :
    (linearization k G).obj (Action.mk X 1) ≅ trivial k G (X →₀ k) :=
  Action.mkIso (Iso.refl _) fun g => by ext1; ext1; exact linearization_of _ _ _
#align Rep.linearization_trivial_iso Rep.linearizationTrivialIso
-/

variable (k G)

#print Rep.ofMulAction /-
/-- Given a `G`-action on `H`, this is `k[H]` bundled with the natural representation
`G →* End(k[H])` as a term of type `Rep k G`. -/
noncomputable abbrev ofMulAction (H : Type u) [MulAction G H] : Rep k G :=
  of <| Representation.ofMulAction k G H
#align Rep.of_mul_action Rep.ofMulAction
-/

#print Rep.leftRegular /-
/-- The `k`-linear `G`-representation on `k[G]`, induced by left multiplication. -/
noncomputable def leftRegular : Rep k G :=
  ofMulAction k G G
#align Rep.left_regular Rep.leftRegular
-/

#print Rep.diagonal /-
/-- The `k`-linear `G`-representation on `k[Gⁿ]`, induced by left multiplication. -/
noncomputable def diagonal (n : ℕ) : Rep k G :=
  ofMulAction k G (Fin n → G)
#align Rep.diagonal Rep.diagonal
-/

#print Rep.linearizationOfMulActionIso /-
/-- The linearization of a type `H` with a `G`-action is definitionally isomorphic to the
`k`-linear `G`-representation on `k[H]` induced by the `G`-action on `H`. -/
noncomputable def linearizationOfMulActionIso (H : Type u) [MulAction G H] :
    (linearization k G).obj (Action.ofMulAction G H) ≅ ofMulAction k G H :=
  Iso.refl _
#align Rep.linearization_of_mul_action_iso Rep.linearizationOfMulActionIso
-/

variable {k G}

#print Rep.leftRegularHom /-
/-- Given an element `x : A`, there is a natural morphism of representations `k[G] ⟶ A` sending
`g ↦ A.ρ(g)(x).` -/
@[simps]
noncomputable def leftRegularHom (A : Rep k G) (x : A) : Rep.ofMulAction k G G ⟶ A
    where
  hom := Finsupp.lift _ _ _ fun g => A.ρ g x
  comm' g := by
    refine' Finsupp.lhom_ext' fun y => LinearMap.ext_ring _
    simpa only [LinearMap.comp_apply, ModuleCat.comp_def, Finsupp.lsingle_apply, Finsupp.lift_apply,
      Action_ρ_eq_ρ, of_ρ_apply, Representation.ofMulAction_single, Finsupp.sum_single_index,
      zero_smul, one_smul, smul_eq_mul, A.ρ.map_mul]
#align Rep.left_regular_hom Rep.leftRegularHom
-/

#print Rep.leftRegularHom_apply /-
theorem leftRegularHom_apply {A : Rep k G} (x : A) :
    (leftRegularHom A x).hom (Finsupp.single 1 1) = x := by
  simpa only [left_regular_hom_hom, Finsupp.lift_apply, Finsupp.sum_single_index, one_smul,
    A.ρ.map_one, zero_smul]
#align Rep.left_regular_hom_apply Rep.leftRegularHom_apply
-/

#print Rep.leftRegularHomEquiv /-
/-- Given a `k`-linear `G`-representation `A`, there is a `k`-linear isomorphism between
representation morphisms `Hom(k[G], A)` and `A`. -/
@[simps]
noncomputable def leftRegularHomEquiv (A : Rep k G) : (Rep.ofMulAction k G G ⟶ A) ≃ₗ[k] A
    where
  toFun f := f.hom (Finsupp.single 1 1)
  map_add' x y := rfl
  map_smul' r x := rfl
  invFun x := leftRegularHom A x
  left_inv f :=
    by
    refine' Action.Hom.ext _ _ (Finsupp.lhom_ext' fun x : G => LinearMap.ext_ring _)
    have :
      f.hom ((of_mul_action k G G).ρ x (Finsupp.single (1 : G) (1 : k))) =
        A.ρ x (f.hom (Finsupp.single (1 : G) (1 : k))) :=
      LinearMap.ext_iff.1 (f.comm x) (Finsupp.single 1 1)
    simp only [LinearMap.comp_apply, Finsupp.lsingle_apply, left_regular_hom_hom,
      Finsupp.lift_apply, Finsupp.sum_single_index, one_smul, ← this, zero_smul, of_ρ_apply,
      Representation.ofMulAction_single x (1 : G) (1 : k), smul_eq_mul, mul_one]
  right_inv x := leftRegularHom_apply x
#align Rep.left_regular_hom_equiv Rep.leftRegularHomEquiv
-/

#print Rep.leftRegularHomEquiv_symm_single /-
theorem leftRegularHomEquiv_symm_single {A : Rep k G} (x : A) (g : G) :
    ((leftRegularHomEquiv A).symm x).hom (Finsupp.single g 1) = A.ρ g x := by
  simp only [left_regular_hom_equiv_symm_apply, left_regular_hom_hom, Finsupp.lift_apply,
    Finsupp.sum_single_index, zero_smul, one_smul]
#align Rep.left_regular_hom_equiv_symm_single Rep.leftRegularHomEquiv_symm_single
-/

end Linearization

end

section MonoidalClosed

open Action

variable [Group G] (A B C : Rep k G)

#print Rep.ihom /-
/-- Given a `k`-linear `G`-representation `(A, ρ₁)`, this is the 'internal Hom' functor sending
`(B, ρ₂)` to the representation `Homₖ(A, B)` that maps `g : G` and `f : A →ₗ[k] B` to
`(ρ₂ g) ∘ₗ f ∘ₗ (ρ₁ g⁻¹)`. -/
@[simps]
protected def ihom (A : Rep k G) : Rep k G ⥤ Rep k G
    where
  obj B := Rep.of (Representation.linHom A.ρ B.ρ)
  map X Y f :=
    { hom := ModuleCat.ofHom (LinearMap.llcomp k _ _ _ f.hom)
      comm' := fun g =>
        LinearMap.ext fun x =>
          LinearMap.ext fun y => show f.hom (X.ρ g _) = _ by simpa only [hom_comm_apply] }
  map_id' B := by ext <;> rfl
  map_comp' B C D f g := by ext <;> rfl
#align Rep.ihom Rep.ihom
-/

#print Rep.ihom_obj_ρ_apply /-
@[simp]
protected theorem ihom_obj_ρ_apply {A B : Rep k G} (g : G) (x : A →ₗ[k] B) :
    ((Rep.ihom A).obj B).ρ g x = B.ρ g ∘ₗ x ∘ₗ A.ρ g⁻¹ :=
  rfl
#align Rep.ihom_obj_ρ_apply Rep.ihom_obj_ρ_apply
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Rep.homEquiv /-
/-- Given a `k`-linear `G`-representation `A`, this is the Hom-set bijection in the adjunction
`A ⊗ - ⊣ ihom(A, -)`. It sends `f : A ⊗ B ⟶ C` to a `Rep k G` morphism defined by currying the
`k`-linear map underlying `f`, giving a map `A →ₗ[k] B →ₗ[k] C`, then flipping the arguments. -/
@[simps]
protected def homEquiv (A B C : Rep k G) : (A ⊗ B ⟶ C) ≃ (B ⟶ (Rep.ihom A).obj C)
    where
  toFun f :=
    { hom := (TensorProduct.curry f.hom).flip
      comm' := fun g => by
        refine' LinearMap.ext fun x => LinearMap.ext fun y => _
        change f.hom (_ ⊗ₜ[k] _) = C.ρ g (f.hom (_ ⊗ₜ[k] _))
        rw [← hom_comm_apply]
        change _ = f.hom ((A.ρ g * A.ρ g⁻¹) y ⊗ₜ[k] _)
        simpa only [← map_mul, mul_inv_self, map_one] }
  invFun f :=
    { hom := TensorProduct.uncurry k _ _ _ f.hom.flip
      comm' := fun g =>
        TensorProduct.ext' fun x y =>
          by
          dsimp only [monoidal_category.tensor_left_obj, ModuleCat.comp_def, LinearMap.comp_apply,
            tensor_rho, ModuleCat.MonoidalCategory.hom_apply, TensorProduct.map_tmul]
          simp only [TensorProduct.uncurry_apply f.hom.flip, LinearMap.flip_apply, Action_ρ_eq_ρ,
            hom_comm_apply f g y, Rep.ihom_obj_ρ_apply, LinearMap.comp_apply, ρ_inv_self_apply] }
  left_inv f := Action.Hom.ext _ _ (TensorProduct.ext' fun x y => rfl)
  right_inv f := by ext <;> rfl
#align Rep.hom_equiv Rep.homEquiv
-/

instance : MonoidalClosed (Rep k G)
    where closed' A :=
    {
      isAdj :=
        { right := Rep.ihom A
          adj :=
            Adjunction.mkOfHomEquiv
              { homEquiv := Rep.homEquiv A
                homEquiv_naturality_left_symm := fun X Y Z f g => by ext <;> rfl
                homEquiv_naturality_right := fun X Y Z f g => by ext <;> rfl } } }

#print Rep.ihom_obj_ρ_def /-
@[simp]
theorem ihom_obj_ρ_def (A B : Rep k G) : ((ihom A).obj B).ρ = ((Rep.ihom A).obj B).ρ :=
  rfl
#align Rep.ihom_obj_ρ_def Rep.ihom_obj_ρ_def
-/

#print Rep.homEquiv_def /-
@[simp]
theorem homEquiv_def (A B C : Rep k G) : (ihom.adjunction A).homEquiv B C = Rep.homEquiv A B C :=
  rfl
#align Rep.hom_equiv_def Rep.homEquiv_def
-/

#print Rep.ihom_ev_app_hom /-
@[simp]
theorem ihom_ev_app_hom (A B : Rep k G) :
    Action.Hom.hom ((ihom.ev A).app B) = TensorProduct.uncurry _ _ _ _ LinearMap.id.flip := by
  ext <;> rfl
#align Rep.ihom_ev_app_hom Rep.ihom_ev_app_hom
-/

#print Rep.ihom_coev_app_hom /-
@[simp]
theorem ihom_coev_app_hom (A B : Rep k G) :
    Action.Hom.hom ((ihom.coev A).app B) = (TensorProduct.mk _ _ _).flip := by ext <;> rfl
#align Rep.ihom_coev_app_hom Rep.ihom_coev_app_hom
-/

variable (A B C)

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Rep.MonoidalClosed.linearHomEquiv /-
/-- There is a `k`-linear isomorphism between the sets of representation morphisms`Hom(A ⊗ B, C)`
and `Hom(B, Homₖ(A, C))`. -/
def MonoidalClosed.linearHomEquiv : (A ⊗ B ⟶ C) ≃ₗ[k] B ⟶ A ⟶[Rep k G] C :=
  {
    (ihom.adjunction A).homEquiv _
      _ with
    map_add' := fun f g => rfl
    map_smul' := fun r f => rfl }
#align Rep.monoidal_closed.linear_hom_equiv Rep.MonoidalClosed.linearHomEquiv
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Rep.MonoidalClosed.linearHomEquivComm /-
/-- There is a `k`-linear isomorphism between the sets of representation morphisms`Hom(A ⊗ B, C)`
and `Hom(A, Homₖ(B, C))`. -/
def MonoidalClosed.linearHomEquivComm : (A ⊗ B ⟶ C) ≃ₗ[k] A ⟶ B ⟶[Rep k G] C :=
  Linear.homCongr k (β_ A B) (Iso.refl _) ≪≫ₗ MonoidalClosed.linearHomEquiv _ _ _
#align Rep.monoidal_closed.linear_hom_equiv_comm Rep.MonoidalClosed.linearHomEquivComm
-/

variable {A B C}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Rep.MonoidalClosed.linearHomEquiv_hom /-
@[simp]
theorem MonoidalClosed.linearHomEquiv_hom (f : A ⊗ B ⟶ C) :
    (MonoidalClosed.linearHomEquiv A B C f).hom = (TensorProduct.curry f.hom).flip :=
  rfl
#align Rep.monoidal_closed.linear_hom_equiv_hom Rep.MonoidalClosed.linearHomEquiv_hom
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Rep.MonoidalClosed.linearHomEquivComm_hom /-
@[simp]
theorem MonoidalClosed.linearHomEquivComm_hom (f : A ⊗ B ⟶ C) :
    (MonoidalClosed.linearHomEquivComm A B C f).hom = TensorProduct.curry f.hom :=
  rfl
#align Rep.monoidal_closed.linear_hom_equiv_comm_hom Rep.MonoidalClosed.linearHomEquivComm_hom
-/

#print Rep.MonoidalClosed.linearHomEquiv_symm_hom /-
@[simp]
theorem MonoidalClosed.linearHomEquiv_symm_hom (f : B ⟶ A ⟶[Rep k G] C) :
    ((MonoidalClosed.linearHomEquiv A B C).symm f).hom = TensorProduct.uncurry k A B C f.hom.flip :=
  rfl
#align Rep.monoidal_closed.linear_hom_equiv_symm_hom Rep.MonoidalClosed.linearHomEquiv_symm_hom
-/

#print Rep.MonoidalClosed.linearHomEquivComm_symm_hom /-
@[simp]
theorem MonoidalClosed.linearHomEquivComm_symm_hom (f : A ⟶ B ⟶[Rep k G] C) :
    ((MonoidalClosed.linearHomEquivComm A B C).symm f).hom = TensorProduct.uncurry k A B C f.hom :=
  by ext <;> rfl
#align Rep.monoidal_closed.linear_hom_equiv_comm_symm_hom Rep.MonoidalClosed.linearHomEquivComm_symm_hom
-/

end MonoidalClosed

end Rep

namespace Representation

variable {k G : Type u} [CommRing k] [Monoid G] {V W : Type u} [AddCommGroup V] [AddCommGroup W]
  [Module k V] [Module k W] (ρ : Representation k G V) (τ : Representation k G W)

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Representation.repOfTprodIso /-
/-- Tautological isomorphism to help Lean in typechecking. -/
def repOfTprodIso : Rep.of (ρ.tprod τ) ≅ Rep.of ρ ⊗ Rep.of τ :=
  Iso.refl _
#align representation.Rep_of_tprod_iso Representation.repOfTprodIso
-/

#print Representation.repOfTprodIso_apply /-
theorem repOfTprodIso_apply (x : TensorProduct k V W) : (repOfTprodIso ρ τ).hom.hom x = x :=
  rfl
#align representation.Rep_of_tprod_iso_apply Representation.repOfTprodIso_apply
-/

#print Representation.repOfTprodIso_inv_apply /-
theorem repOfTprodIso_inv_apply (x : TensorProduct k V W) : (repOfTprodIso ρ τ).inv.hom x = x :=
  rfl
#align representation.Rep_of_tprod_iso_inv_apply Representation.repOfTprodIso_inv_apply
-/

end Representation

/-!
# The categorical equivalence `Rep k G ≌ Module.{u} (monoid_algebra k G)`.
-/


namespace Rep

variable {k G : Type u} [CommRing k] [Monoid G]

-- Verify that the symmetric monoidal structure is available.
example : SymmetricCategory (Rep k G) := by infer_instance

example : MonoidalPreadditive (Rep k G) := by infer_instance

example : MonoidalLinear k (Rep k G) := by infer_instance

noncomputable section

#print Rep.to_Module_monoidAlgebra_map_aux /-
/-- Auxilliary lemma for `to_Module_monoid_algebra`. -/
theorem to_Module_monoidAlgebra_map_aux {k G : Type _} [CommRing k] [Monoid G] (V W : Type _)
    [AddCommGroup V] [AddCommGroup W] [Module k V] [Module k W] (ρ : G →* V →ₗ[k] V)
    (σ : G →* W →ₗ[k] W) (f : V →ₗ[k] W) (w : ∀ g : G, f.comp (ρ g) = (σ g).comp f)
    (r : MonoidAlgebra k G) (x : V) :
    f ((((MonoidAlgebra.lift k G (V →ₗ[k] V)) ρ) r) x) =
      (((MonoidAlgebra.lift k G (W →ₗ[k] W)) σ) r) (f x) :=
  by
  apply MonoidAlgebra.induction_on r
  · intro g
    simp only [one_smul, MonoidAlgebra.lift_single, MonoidAlgebra.of_apply]
    exact LinearMap.congr_fun (w g) x
  · intro g h gw hw; simp only [map_add, add_left_inj, LinearMap.add_apply, hw, gw]
  · intro r g w
    simp only [AlgHom.map_smul, w, RingHom.id_apply, LinearMap.smul_apply, LinearMap.map_smulₛₗ]
#align Rep.to_Module_monoid_algebra_map_aux Rep.to_Module_monoidAlgebra_map_aux
-/

#print Rep.toModuleMonoidAlgebraMap /-
/-- Auxilliary definition for `to_Module_monoid_algebra`. -/
def toModuleMonoidAlgebraMap {V W : Rep k G} (f : V ⟶ W) :
    ModuleCat.of (MonoidAlgebra k G) V.ρ.asModule ⟶ ModuleCat.of (MonoidAlgebra k G) W.ρ.asModule :=
  { f.hom with
    map_smul' := fun r x => to_Module_monoidAlgebra_map_aux V.V W.V V.ρ W.ρ f.hom f.comm r x }
#align Rep.to_Module_monoid_algebra_map Rep.toModuleMonoidAlgebraMap
-/

#print Rep.toModuleMonoidAlgebra /-
/-- Functorially convert a representation of `G` into a module over `monoid_algebra k G`. -/
def toModuleMonoidAlgebra : Rep k G ⥤ ModuleCat.{u} (MonoidAlgebra k G)
    where
  obj V := ModuleCat.of _ V.ρ.asModule
  map V W f := toModuleMonoidAlgebraMap f
#align Rep.to_Module_monoid_algebra Rep.toModuleMonoidAlgebra
-/

#print Rep.ofModuleMonoidAlgebra /-
/-- Functorially convert a module over `monoid_algebra k G` into a representation of `G`. -/
def ofModuleMonoidAlgebra : ModuleCat.{u} (MonoidAlgebra k G) ⥤ Rep k G
    where
  obj M := Rep.of (Representation.ofModule k G M)
  map M N f :=
    { hom := { f with map_smul' := fun r x => f.map_smul (algebraMap k _ r) x }
      comm' := fun g => by ext; apply f.map_smul }
#align Rep.of_Module_monoid_algebra Rep.ofModuleMonoidAlgebra
-/

#print Rep.ofModuleMonoidAlgebra_obj_coe /-
theorem ofModuleMonoidAlgebra_obj_coe (M : ModuleCat.{u} (MonoidAlgebra k G)) :
    (ofModuleMonoidAlgebra.obj M : Type u) = RestrictScalars k (MonoidAlgebra k G) M :=
  rfl
#align Rep.of_Module_monoid_algebra_obj_coe Rep.ofModuleMonoidAlgebra_obj_coe
-/

#print Rep.ofModuleMonoidAlgebra_obj_ρ /-
theorem ofModuleMonoidAlgebra_obj_ρ (M : ModuleCat.{u} (MonoidAlgebra k G)) :
    (ofModuleMonoidAlgebra.obj M).ρ = Representation.ofModule k G M :=
  rfl
#align Rep.of_Module_monoid_algebra_obj_ρ Rep.ofModuleMonoidAlgebra_obj_ρ
-/

#print Rep.counitIsoAddEquiv /-
/-- Auxilliary definition for `equivalence_Module_monoid_algebra`. -/
def counitIsoAddEquiv {M : ModuleCat.{u} (MonoidAlgebra k G)} :
    (ofModuleMonoidAlgebra ⋙ toModuleMonoidAlgebra).obj M ≃+ M :=
  by
  dsimp [of_Module_monoid_algebra, to_Module_monoid_algebra]
  refine' (Representation.ofModule k G ↥M).asModuleEquiv.trans (RestrictScalars.addEquiv _ _ _)
#align Rep.counit_iso_add_equiv Rep.counitIsoAddEquiv
-/

#print Rep.unitIsoAddEquiv /-
/-- Auxilliary definition for `equivalence_Module_monoid_algebra`. -/
def unitIsoAddEquiv {V : Rep k G} : V ≃+ (toModuleMonoidAlgebra ⋙ ofModuleMonoidAlgebra).obj V :=
  by
  dsimp [of_Module_monoid_algebra, to_Module_monoid_algebra]
  refine' V.ρ.as_module_equiv.symm.trans _
  exact (RestrictScalars.addEquiv _ _ _).symm
#align Rep.unit_iso_add_equiv Rep.unitIsoAddEquiv
-/

#print Rep.counitIso /-
/-- Auxilliary definition for `equivalence_Module_monoid_algebra`. -/
def counitIso (M : ModuleCat.{u} (MonoidAlgebra k G)) :
    (ofModuleMonoidAlgebra ⋙ toModuleMonoidAlgebra).obj M ≅ M :=
  LinearEquiv.toModuleIso'
    { counitIsoAddEquiv with
      map_smul' := fun r x => by
        dsimp [counit_iso_add_equiv]
        simp }
#align Rep.counit_iso Rep.counitIso
-/

#print Rep.unit_iso_comm /-
theorem unit_iso_comm (V : Rep k G) (g : G) (x : V) :
    unitIsoAddEquiv ((V.ρ g).toFun x) =
      ((ofModuleMonoidAlgebra.obj (toModuleMonoidAlgebra.obj V)).ρ g).toFun (unitIsoAddEquiv x) :=
  by
  dsimp [unit_iso_add_equiv, of_Module_monoid_algebra, to_Module_monoid_algebra]
  simp only [AddEquiv.apply_eq_iff_eq, AddEquiv.apply_symm_apply,
    Representation.asModuleEquiv_symm_map_rho, Representation.ofModule_asModule_act]
#align Rep.unit_iso_comm Rep.unit_iso_comm
-/

#print Rep.unitIso /-
/-- Auxilliary definition for `equivalence_Module_monoid_algebra`. -/
def unitIso (V : Rep k G) : V ≅ (toModuleMonoidAlgebra ⋙ ofModuleMonoidAlgebra).obj V :=
  Action.mkIso
    (LinearEquiv.toModuleIso'
      { unitIsoAddEquiv with
        map_smul' := fun r x => by
          dsimp [unit_iso_add_equiv]
          simp only [Representation.asModuleEquiv_symm_map_smul,
            RestrictScalars.addEquiv_symm_map_algebraMap_smul] })
    fun g => by ext; apply unit_iso_comm
#align Rep.unit_iso Rep.unitIso
-/

#print Rep.equivalenceModuleMonoidAlgebra /-
/-- The categorical equivalence `Rep k G ≌ Module (monoid_algebra k G)`. -/
def equivalenceModuleMonoidAlgebra : Rep k G ≌ ModuleCat.{u} (MonoidAlgebra k G)
    where
  Functor := toModuleMonoidAlgebra
  inverse := ofModuleMonoidAlgebra
  unitIso := NatIso.ofComponents (fun V => unitIso V) (by tidy)
  counitIso := NatIso.ofComponents (fun M => counitIso M) (by tidy)
#align Rep.equivalence_Module_monoid_algebra Rep.equivalenceModuleMonoidAlgebra
-/

-- TODO Verify that the equivalence with `Module (monoid_algebra k G)` is a monoidal functor.
end Rep

