/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux

! This file was ported from Lean 3 source module algebra.star.star_alg_hom
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.NonUnitalAlg
import Mathbin.Algebra.Star.Prod
import Mathbin.Algebra.Algebra.Prod

/-!
# Morphisms of star algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines morphisms between `R`-algebras (unital or non-unital) `A` and `B` where both
`A` and `B` are equipped with a `star` operation. These morphisms, namely `star_alg_hom` and
`non_unital_star_alg_hom` are direct extensions of their non-`star`red counterparts with a field
`map_star` which guarantees they preserve the star operation. We keep the type classes as generic
as possible, in keeping with the definition of `non_unital_alg_hom` in the non-unital case. In this
file, we only assume `has_star` unless we want to talk about the zero map as a
`non_unital_star_alg_hom`, in which case we need `star_add_monoid`. Note that the scalar ring `R`
is not required to have a star operation, nor do we need `star_ring` or `star_module` structures on
`A` and `B`.

As with `non_unital_alg_hom`, in the non-unital case the multiplications are not assumed to be
associative or unital, or even to be compatible with the scalar actions. In a typical application,
the operations will satisfy compatibility conditions making them into algebras (albeit possibly
non-associative and/or non-unital) but such conditions are not required here for the definitions.

The primary impetus for defining these types is that they constitute the morphisms in the categories
of unital C⋆-algebras (with `star_alg_hom`s) and of C⋆-algebras (with `non_unital_star_alg_hom`s).

TODO: add `star_alg_equiv`.

## Main definitions

  * `non_unital_alg_hom`
  * `star_alg_hom`

## Tags

non-unital, algebra, morphism, star
-/


/-! ### Non-unital star algebra homomorphisms -/


#print NonUnitalStarAlgHom /-
/-- A *non-unital ⋆-algebra homomorphism* is a non-unital algebra homomorphism between
non-unital `R`-algebras `A` and `B` equipped with a `star` operation, and this homomorphism is
also `star`-preserving. -/
structure NonUnitalStarAlgHom (R A B : Type _) [Monoid R] [NonUnitalNonAssocSemiring A]
    [DistribMulAction R A] [Star A] [NonUnitalNonAssocSemiring B] [DistribMulAction R B]
    [Star B] extends A →ₙₐ[R] B where
  map_star' : ∀ a : A, to_fun (star a) = star (to_fun a)
#align non_unital_star_alg_hom NonUnitalStarAlgHom
-/

infixr:25 " →⋆ₙₐ " => NonUnitalStarAlgHom _

notation:25 A " →⋆ₙₐ[" R "] " B => NonUnitalStarAlgHom R A B

/-- Reinterpret a non-unital star algebra homomorphism as a non-unital algebra homomorphism
by forgetting the interaction with the star operation. -/
add_decl_doc NonUnitalStarAlgHom.toNonUnitalAlgHom

#print NonUnitalStarAlgHomClass /-
/-- `non_unital_star_alg_hom_class F R A B` asserts `F` is a type of bundled non-unital ⋆-algebra
homomorphisms from `A` to `B`. -/
class NonUnitalStarAlgHomClass (F : Type _) (R : outParam (Type _)) (A : outParam (Type _))
    (B : outParam (Type _)) [Monoid R] [Star A] [Star B] [NonUnitalNonAssocSemiring A]
    [NonUnitalNonAssocSemiring B] [DistribMulAction R A] [DistribMulAction R B] extends
    NonUnitalAlgHomClass F R A B, StarHomClass F A B
#align non_unital_star_alg_hom_class NonUnitalStarAlgHomClass
-/

-- `R` becomes a metavariable but that's fine because it's an `out_param`
attribute [nolint dangerous_instance] NonUnitalStarAlgHomClass.toStarHomClass

namespace NonUnitalStarAlgHomClass

variable {F R A B : Type _} [Monoid R]

variable [NonUnitalNonAssocSemiring A] [DistribMulAction R A] [Star A]

variable [NonUnitalNonAssocSemiring B] [DistribMulAction R B] [Star B]

instance [NonUnitalStarAlgHomClass F R A B] : CoeTC F (A →⋆ₙₐ[R] B)
    where coe f :=
    { (f : A →ₙₐ[R] B) with
      toFun := f
      map_star' := map_star f }

end NonUnitalStarAlgHomClass

namespace NonUnitalStarAlgHom

section Basic

variable {R A B C D : Type _} [Monoid R]

variable [NonUnitalNonAssocSemiring A] [DistribMulAction R A] [Star A]

variable [NonUnitalNonAssocSemiring B] [DistribMulAction R B] [Star B]

variable [NonUnitalNonAssocSemiring C] [DistribMulAction R C] [Star C]

variable [NonUnitalNonAssocSemiring D] [DistribMulAction R D] [Star D]

instance : NonUnitalStarAlgHomClass (A →⋆ₙₐ[R] B) R A B
    where
  coe := toFun
  coe_injective' := by rintro ⟨f, _⟩ ⟨g, _⟩ ⟨h⟩ <;> congr
  map_smul f := f.map_smul'
  map_add f := f.map_add'
  map_zero f := f.map_zero'
  map_mul f := f.map_mul'
  map_star f := f.map_star'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (A →⋆ₙₐ[R] B) fun _ => A → B :=
  FunLike.hasCoeToFun

initialize_simps_projections NonUnitalStarAlgHom (toFun → apply)

#print NonUnitalStarAlgHom.coe_coe /-
@[simp, protected]
theorem coe_coe {F : Type _} [NonUnitalStarAlgHomClass F R A B] (f : F) : ⇑(f : A →⋆ₙₐ[R] B) = f :=
  rfl
#align non_unital_star_alg_hom.coe_coe NonUnitalStarAlgHom.coe_coe
-/

#print NonUnitalStarAlgHom.coe_toNonUnitalAlgHom /-
@[simp]
theorem coe_toNonUnitalAlgHom {f : A →⋆ₙₐ[R] B} : (f.toNonUnitalAlgHom : A → B) = f :=
  rfl
#align non_unital_star_alg_hom.coe_to_non_unital_alg_hom NonUnitalStarAlgHom.coe_toNonUnitalAlgHom
-/

#print NonUnitalStarAlgHom.ext /-
@[ext]
theorem ext {f g : A →⋆ₙₐ[R] B} (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext _ _ h
#align non_unital_star_alg_hom.ext NonUnitalStarAlgHom.ext
-/

#print NonUnitalStarAlgHom.copy /-
/-- Copy of a `non_unital_star_alg_hom` with a new `to_fun` equal to the old one. Useful
to fix definitional equalities. -/
protected def copy (f : A →⋆ₙₐ[R] B) (f' : A → B) (h : f' = f) : A →⋆ₙₐ[R] B
    where
  toFun := f'
  map_smul' := h.symm ▸ map_smul f
  map_zero' := h.symm ▸ map_zero f
  map_add' := h.symm ▸ map_add f
  map_mul' := h.symm ▸ map_mul f
  map_star' := h.symm ▸ map_star f
#align non_unital_star_alg_hom.copy NonUnitalStarAlgHom.copy
-/

#print NonUnitalStarAlgHom.coe_copy /-
@[simp]
theorem coe_copy (f : A →⋆ₙₐ[R] B) (f' : A → B) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align non_unital_star_alg_hom.coe_copy NonUnitalStarAlgHom.coe_copy
-/

#print NonUnitalStarAlgHom.copy_eq /-
theorem copy_eq (f : A →⋆ₙₐ[R] B) (f' : A → B) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align non_unital_star_alg_hom.copy_eq NonUnitalStarAlgHom.copy_eq
-/

@[simp]
theorem coe_mk (f : A → B) (h₁ h₂ h₃ h₄ h₅) :
    ((⟨f, h₁, h₂, h₃, h₄, h₅⟩ : A →⋆ₙₐ[R] B) : A → B) = f :=
  rfl
#align non_unital_star_alg_hom.coe_mk NonUnitalStarAlgHom.coe_mkₓ

@[simp]
theorem mk_coe (f : A →⋆ₙₐ[R] B) (h₁ h₂ h₃ h₄ h₅) : (⟨f, h₁, h₂, h₃, h₄, h₅⟩ : A →⋆ₙₐ[R] B) = f :=
  by ext; rfl
#align non_unital_star_alg_hom.mk_coe NonUnitalStarAlgHom.mk_coeₓ

section

variable (R A)

#print NonUnitalStarAlgHom.id /-
/-- The identity as a non-unital ⋆-algebra homomorphism. -/
protected def id : A →⋆ₙₐ[R] A :=
  { (1 : A →ₙₐ[R] A) with map_star' := fun x => rfl }
#align non_unital_star_alg_hom.id NonUnitalStarAlgHom.id
-/

#print NonUnitalStarAlgHom.coe_id /-
@[simp]
theorem coe_id : ⇑(NonUnitalStarAlgHom.id R A) = id :=
  rfl
#align non_unital_star_alg_hom.coe_id NonUnitalStarAlgHom.coe_id
-/

end

#print NonUnitalStarAlgHom.comp /-
/-- The composition of non-unital ⋆-algebra homomorphisms, as a non-unital ⋆-algebra
homomorphism. -/
def comp (f : B →⋆ₙₐ[R] C) (g : A →⋆ₙₐ[R] B) : A →⋆ₙₐ[R] C :=
  { f.toNonUnitalAlgHom.comp g.toNonUnitalAlgHom with
    map_star' := by
      simp only [map_star, NonUnitalAlgHom.toFun_eq_coe, eq_self_iff_true, NonUnitalAlgHom.coe_comp,
        coe_to_non_unital_alg_hom, Function.comp_apply, forall_const] }
#align non_unital_star_alg_hom.comp NonUnitalStarAlgHom.comp
-/

#print NonUnitalStarAlgHom.coe_comp /-
@[simp]
theorem coe_comp (f : B →⋆ₙₐ[R] C) (g : A →⋆ₙₐ[R] B) : ⇑(comp f g) = f ∘ g :=
  rfl
#align non_unital_star_alg_hom.coe_comp NonUnitalStarAlgHom.coe_comp
-/

#print NonUnitalStarAlgHom.comp_apply /-
@[simp]
theorem comp_apply (f : B →⋆ₙₐ[R] C) (g : A →⋆ₙₐ[R] B) (a : A) : comp f g a = f (g a) :=
  rfl
#align non_unital_star_alg_hom.comp_apply NonUnitalStarAlgHom.comp_apply
-/

#print NonUnitalStarAlgHom.comp_assoc /-
@[simp]
theorem comp_assoc (f : C →⋆ₙₐ[R] D) (g : B →⋆ₙₐ[R] C) (h : A →⋆ₙₐ[R] B) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align non_unital_star_alg_hom.comp_assoc NonUnitalStarAlgHom.comp_assoc
-/

#print NonUnitalStarAlgHom.id_comp /-
@[simp]
theorem id_comp (f : A →⋆ₙₐ[R] B) : (NonUnitalStarAlgHom.id _ _).comp f = f :=
  ext fun _ => rfl
#align non_unital_star_alg_hom.id_comp NonUnitalStarAlgHom.id_comp
-/

#print NonUnitalStarAlgHom.comp_id /-
@[simp]
theorem comp_id (f : A →⋆ₙₐ[R] B) : f.comp (NonUnitalStarAlgHom.id _ _) = f :=
  ext fun _ => rfl
#align non_unital_star_alg_hom.comp_id NonUnitalStarAlgHom.comp_id
-/

instance : Monoid (A →⋆ₙₐ[R] A) where
  mul := comp
  mul_assoc := comp_assoc
  one := NonUnitalStarAlgHom.id R A
  one_mul := id_comp
  mul_one := comp_id

#print NonUnitalStarAlgHom.coe_one /-
@[simp]
theorem coe_one : ((1 : A →⋆ₙₐ[R] A) : A → A) = id :=
  rfl
#align non_unital_star_alg_hom.coe_one NonUnitalStarAlgHom.coe_one
-/

#print NonUnitalStarAlgHom.one_apply /-
theorem one_apply (a : A) : (1 : A →⋆ₙₐ[R] A) a = a :=
  rfl
#align non_unital_star_alg_hom.one_apply NonUnitalStarAlgHom.one_apply
-/

end Basic

section Zero

-- the `zero` requires extra type class assumptions because we need `star_zero`
variable {R A B C D : Type _} [Monoid R]

variable [NonUnitalNonAssocSemiring A] [DistribMulAction R A] [StarAddMonoid A]

variable [NonUnitalNonAssocSemiring B] [DistribMulAction R B] [StarAddMonoid B]

instance : Zero (A →⋆ₙₐ[R] B) :=
  ⟨{ (0 : NonUnitalAlgHom R A B) with map_star' := by simp }⟩

instance : Inhabited (A →⋆ₙₐ[R] B) :=
  ⟨0⟩

instance : MonoidWithZero (A →⋆ₙₐ[R] A) :=
  { NonUnitalStarAlgHom.monoid,
    NonUnitalStarAlgHom.hasZero with
    zero_mul := fun f => ext fun x => rfl
    mul_zero := fun f => ext fun x => map_zero f }

#print NonUnitalStarAlgHom.coe_zero /-
@[simp]
theorem coe_zero : ((0 : A →⋆ₙₐ[R] B) : A → B) = 0 :=
  rfl
#align non_unital_star_alg_hom.coe_zero NonUnitalStarAlgHom.coe_zero
-/

#print NonUnitalStarAlgHom.zero_apply /-
theorem zero_apply (a : A) : (0 : A →⋆ₙₐ[R] B) a = 0 :=
  rfl
#align non_unital_star_alg_hom.zero_apply NonUnitalStarAlgHom.zero_apply
-/

end Zero

end NonUnitalStarAlgHom

/-! ### Unital star algebra homomorphisms -/


section Unital

#print StarAlgHom /-
/-- A *⋆-algebra homomorphism* is an algebra homomorphism between `R`-algebras `A` and `B`
equipped with a `star` operation, and this homomorphism is also `star`-preserving. -/
structure StarAlgHom (R A B : Type _) [CommSemiring R] [Semiring A] [Algebra R A] [Star A]
    [Semiring B] [Algebra R B] [Star B] extends AlgHom R A B where
  map_star' : ∀ x : A, to_fun (star x) = star (to_fun x)
#align star_alg_hom StarAlgHom
-/

infixr:25 " →⋆ₐ " => StarAlgHom _

notation:25 A " →⋆ₐ[" R "] " B => StarAlgHom R A B

/-- Reinterpret a unital star algebra homomorphism as a unital algebra homomorphism
by forgetting the interaction with the star operation. -/
add_decl_doc StarAlgHom.toAlgHom

#print StarAlgHomClass /-
/-- `star_alg_hom_class F R A B` states that `F` is a type of ⋆-algebra homomorphisms.

You should also extend this typeclass when you extend `star_alg_hom`. -/
class StarAlgHomClass (F : Type _) (R : outParam (Type _)) (A : outParam (Type _))
    (B : outParam (Type _)) [CommSemiring R] [Semiring A] [Algebra R A] [Star A] [Semiring B]
    [Algebra R B] [Star B] extends AlgHomClass F R A B, StarHomClass F A B
#align star_alg_hom_class StarAlgHomClass
-/

-- `R` becomes a metavariable but that's fine because it's an `out_param`
attribute [nolint dangerous_instance] StarAlgHomClass.toStarHomClass

namespace StarAlgHomClass

variable (F R A B : Type _) [CommSemiring R] [Semiring A] [Algebra R A] [Star A]

variable [Semiring B] [Algebra R B] [Star B] [hF : StarAlgHomClass F R A B]

#print StarAlgHomClass.toNonUnitalStarAlgHomClass /-
-- See note [lower instance priority]
instance (priority := 100) toNonUnitalStarAlgHomClass : NonUnitalStarAlgHomClass F R A B :=
  { StarAlgHomClass.toAlgHomClass F R A B, StarAlgHomClass.toStarHomClass F R A B with
    map_smul := map_smul }
#align star_alg_hom_class.to_non_unital_star_alg_hom_class StarAlgHomClass.toNonUnitalStarAlgHomClass
-/

instance : CoeTC F (A →⋆ₐ[R] B)
    where coe f :=
    { (f : A →ₐ[R] B) with
      toFun := f
      map_star' := map_star f }

end StarAlgHomClass

namespace StarAlgHom

variable {F R A B C D : Type _} [CommSemiring R] [Semiring A] [Algebra R A] [Star A] [Semiring B]
  [Algebra R B] [Star B] [Semiring C] [Algebra R C] [Star C] [Semiring D] [Algebra R D] [Star D]

instance : StarAlgHomClass (A →⋆ₐ[R] B) R A B
    where
  coe f := f.toFun
  coe_injective' f g h := by
    obtain ⟨_, _, _, _, _, _, _⟩ := f <;> obtain ⟨_, _, _, _, _, _, _⟩ := g <;> congr
  map_mul := map_mul'
  map_one := map_one'
  map_add := map_add'
  map_zero := map_zero'
  commutes := commutes'
  map_star := map_star'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (A →⋆ₐ[R] B) fun _ => A → B :=
  FunLike.hasCoeToFun

#print StarAlgHom.coe_coe /-
@[simp, protected]
theorem coe_coe {F : Type _} [StarAlgHomClass F R A B] (f : F) : ⇑(f : A →⋆ₐ[R] B) = f :=
  rfl
#align star_alg_hom.coe_coe StarAlgHom.coe_coe
-/

initialize_simps_projections StarAlgHom (toFun → apply)

#print StarAlgHom.coe_toAlgHom /-
@[simp]
theorem coe_toAlgHom {f : A →⋆ₐ[R] B} : (f.toAlgHom : A → B) = f :=
  rfl
#align star_alg_hom.coe_to_alg_hom StarAlgHom.coe_toAlgHom
-/

#print StarAlgHom.ext /-
@[ext]
theorem ext {f g : A →⋆ₐ[R] B} (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext _ _ h
#align star_alg_hom.ext StarAlgHom.ext
-/

#print StarAlgHom.copy /-
/-- Copy of a `star_alg_hom` with a new `to_fun` equal to the old one. Useful
to fix definitional equalities. -/
protected def copy (f : A →⋆ₐ[R] B) (f' : A → B) (h : f' = f) : A →⋆ₐ[R] B
    where
  toFun := f'
  map_one' := h.symm ▸ map_one f
  map_mul' := h.symm ▸ map_mul f
  map_zero' := h.symm ▸ map_zero f
  map_add' := h.symm ▸ map_add f
  commutes' := h.symm ▸ AlgHomClass.commutes f
  map_star' := h.symm ▸ map_star f
#align star_alg_hom.copy StarAlgHom.copy
-/

#print StarAlgHom.coe_copy /-
@[simp]
theorem coe_copy (f : A →⋆ₐ[R] B) (f' : A → B) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align star_alg_hom.coe_copy StarAlgHom.coe_copy
-/

#print StarAlgHom.copy_eq /-
theorem copy_eq (f : A →⋆ₐ[R] B) (f' : A → B) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align star_alg_hom.copy_eq StarAlgHom.copy_eq
-/

@[simp]
theorem coe_mk (f : A → B) (h₁ h₂ h₃ h₄ h₅ h₆) :
    ((⟨f, h₁, h₂, h₃, h₄, h₅, h₆⟩ : A →⋆ₐ[R] B) : A → B) = f :=
  rfl
#align star_alg_hom.coe_mk StarAlgHom.coe_mkₓ

@[simp]
theorem mk_coe (f : A →⋆ₐ[R] B) (h₁ h₂ h₃ h₄ h₅ h₆) :
    (⟨f, h₁, h₂, h₃, h₄, h₅, h₆⟩ : A →⋆ₐ[R] B) = f := by ext; rfl
#align star_alg_hom.mk_coe StarAlgHom.mk_coeₓ

section

variable (R A)

#print StarAlgHom.id /-
/-- The identity as a `star_alg_hom`. -/
protected def id : A →⋆ₐ[R] A :=
  { AlgHom.id _ _ with map_star' := fun x => rfl }
#align star_alg_hom.id StarAlgHom.id
-/

#print StarAlgHom.coe_id /-
@[simp]
theorem coe_id : ⇑(StarAlgHom.id R A) = id :=
  rfl
#align star_alg_hom.coe_id StarAlgHom.coe_id
-/

end

instance : Inhabited (A →⋆ₐ[R] A) :=
  ⟨StarAlgHom.id R A⟩

#print StarAlgHom.comp /-
/-- The composition of ⋆-algebra homomorphisms, as a ⋆-algebra homomorphism. -/
def comp (f : B →⋆ₐ[R] C) (g : A →⋆ₐ[R] B) : A →⋆ₐ[R] C :=
  { f.toAlgHom.comp g.toAlgHom with
    map_star' := by
      simp only [map_star, AlgHom.toFun_eq_coe, AlgHom.coe_comp, coe_to_alg_hom,
        Function.comp_apply, eq_self_iff_true, forall_const] }
#align star_alg_hom.comp StarAlgHom.comp
-/

#print StarAlgHom.coe_comp /-
@[simp]
theorem coe_comp (f : B →⋆ₐ[R] C) (g : A →⋆ₐ[R] B) : ⇑(comp f g) = f ∘ g :=
  rfl
#align star_alg_hom.coe_comp StarAlgHom.coe_comp
-/

#print StarAlgHom.comp_apply /-
@[simp]
theorem comp_apply (f : B →⋆ₐ[R] C) (g : A →⋆ₐ[R] B) (a : A) : comp f g a = f (g a) :=
  rfl
#align star_alg_hom.comp_apply StarAlgHom.comp_apply
-/

#print StarAlgHom.comp_assoc /-
@[simp]
theorem comp_assoc (f : C →⋆ₐ[R] D) (g : B →⋆ₐ[R] C) (h : A →⋆ₐ[R] B) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align star_alg_hom.comp_assoc StarAlgHom.comp_assoc
-/

#print StarAlgHom.id_comp /-
@[simp]
theorem id_comp (f : A →⋆ₐ[R] B) : (StarAlgHom.id _ _).comp f = f :=
  ext fun _ => rfl
#align star_alg_hom.id_comp StarAlgHom.id_comp
-/

#print StarAlgHom.comp_id /-
@[simp]
theorem comp_id (f : A →⋆ₐ[R] B) : f.comp (StarAlgHom.id _ _) = f :=
  ext fun _ => rfl
#align star_alg_hom.comp_id StarAlgHom.comp_id
-/

instance : Monoid (A →⋆ₐ[R] A) where
  mul := comp
  mul_assoc := comp_assoc
  one := StarAlgHom.id R A
  one_mul := id_comp
  mul_one := comp_id

#print StarAlgHom.toNonUnitalStarAlgHom /-
/-- A unital morphism of ⋆-algebras is a `non_unital_star_alg_hom`. -/
def toNonUnitalStarAlgHom (f : A →⋆ₐ[R] B) : A →⋆ₙₐ[R] B :=
  { f with map_smul' := map_smul f }
#align star_alg_hom.to_non_unital_star_alg_hom StarAlgHom.toNonUnitalStarAlgHom
-/

#print StarAlgHom.coe_toNonUnitalStarAlgHom /-
@[simp]
theorem coe_toNonUnitalStarAlgHom (f : A →⋆ₐ[R] B) : (f.toNonUnitalStarAlgHom : A → B) = f :=
  rfl
#align star_alg_hom.coe_to_non_unital_star_alg_hom StarAlgHom.coe_toNonUnitalStarAlgHom
-/

end StarAlgHom

end Unital

/-! ### Operations on the product type

Note that this is copied from [`algebra/hom/non_unital_alg`](non_unital_alg). -/


namespace NonUnitalStarAlgHom

section Prod

variable (R A B C : Type _) [Monoid R] [NonUnitalNonAssocSemiring A] [DistribMulAction R A] [Star A]
  [NonUnitalNonAssocSemiring B] [DistribMulAction R B] [Star B] [NonUnitalNonAssocSemiring C]
  [DistribMulAction R C] [Star C]

#print NonUnitalStarAlgHom.fst /-
/-- The first projection of a product is a non-unital ⋆-algebra homomoprhism. -/
@[simps]
def fst : A × B →⋆ₙₐ[R] A :=
  { NonUnitalAlgHom.fst R A B with map_star' := fun x => rfl }
#align non_unital_star_alg_hom.fst NonUnitalStarAlgHom.fst
-/

#print NonUnitalStarAlgHom.snd /-
/-- The second projection of a product is a non-unital ⋆-algebra homomorphism. -/
@[simps]
def snd : A × B →⋆ₙₐ[R] B :=
  { NonUnitalAlgHom.snd R A B with map_star' := fun x => rfl }
#align non_unital_star_alg_hom.snd NonUnitalStarAlgHom.snd
-/

variable {R A B C}

#print NonUnitalStarAlgHom.prod /-
/-- The `pi.prod` of two morphisms is a morphism. -/
@[simps]
def prod (f : A →⋆ₙₐ[R] B) (g : A →⋆ₙₐ[R] C) : A →⋆ₙₐ[R] B × C :=
  { f.toNonUnitalAlgHom.Prod g.toNonUnitalAlgHom with
    map_star' := fun x => by simp [map_star, Prod.star_def] }
#align non_unital_star_alg_hom.prod NonUnitalStarAlgHom.prod
-/

#print NonUnitalStarAlgHom.coe_prod /-
theorem coe_prod (f : A →⋆ₙₐ[R] B) (g : A →⋆ₙₐ[R] C) : ⇑(f.Prod g) = Pi.prod f g :=
  rfl
#align non_unital_star_alg_hom.coe_prod NonUnitalStarAlgHom.coe_prod
-/

#print NonUnitalStarAlgHom.fst_prod /-
@[simp]
theorem fst_prod (f : A →⋆ₙₐ[R] B) (g : A →⋆ₙₐ[R] C) : (fst R B C).comp (prod f g) = f := by
  ext <;> rfl
#align non_unital_star_alg_hom.fst_prod NonUnitalStarAlgHom.fst_prod
-/

#print NonUnitalStarAlgHom.snd_prod /-
@[simp]
theorem snd_prod (f : A →⋆ₙₐ[R] B) (g : A →⋆ₙₐ[R] C) : (snd R B C).comp (prod f g) = g := by
  ext <;> rfl
#align non_unital_star_alg_hom.snd_prod NonUnitalStarAlgHom.snd_prod
-/

#print NonUnitalStarAlgHom.prod_fst_snd /-
@[simp]
theorem prod_fst_snd : prod (fst R A B) (snd R A B) = 1 :=
  FunLike.coe_injective Pi.prod_fst_snd
#align non_unital_star_alg_hom.prod_fst_snd NonUnitalStarAlgHom.prod_fst_snd
-/

#print NonUnitalStarAlgHom.prodEquiv /-
/-- Taking the product of two maps with the same domain is equivalent to taking the product of
their codomains. -/
@[simps]
def prodEquiv : (A →⋆ₙₐ[R] B) × (A →⋆ₙₐ[R] C) ≃ (A →⋆ₙₐ[R] B × C)
    where
  toFun f := f.1.Prod f.2
  invFun f := ((fst _ _ _).comp f, (snd _ _ _).comp f)
  left_inv f := by ext <;> rfl
  right_inv f := by ext <;> rfl
#align non_unital_star_alg_hom.prod_equiv NonUnitalStarAlgHom.prodEquiv
-/

end Prod

section InlInr

variable (R A B C : Type _) [Monoid R] [NonUnitalNonAssocSemiring A] [DistribMulAction R A]
  [StarAddMonoid A] [NonUnitalNonAssocSemiring B] [DistribMulAction R B] [StarAddMonoid B]
  [NonUnitalNonAssocSemiring C] [DistribMulAction R C] [StarAddMonoid C]

#print NonUnitalStarAlgHom.inl /-
/-- The left injection into a product is a non-unital algebra homomorphism. -/
def inl : A →⋆ₙₐ[R] A × B :=
  prod 1 0
#align non_unital_star_alg_hom.inl NonUnitalStarAlgHom.inl
-/

#print NonUnitalStarAlgHom.inr /-
/-- The right injection into a product is a non-unital algebra homomorphism. -/
def inr : B →⋆ₙₐ[R] A × B :=
  prod 0 1
#align non_unital_star_alg_hom.inr NonUnitalStarAlgHom.inr
-/

variable {R A B}

#print NonUnitalStarAlgHom.coe_inl /-
@[simp]
theorem coe_inl : (inl R A B : A → A × B) = fun x => (x, 0) :=
  rfl
#align non_unital_star_alg_hom.coe_inl NonUnitalStarAlgHom.coe_inl
-/

#print NonUnitalStarAlgHom.inl_apply /-
theorem inl_apply (x : A) : inl R A B x = (x, 0) :=
  rfl
#align non_unital_star_alg_hom.inl_apply NonUnitalStarAlgHom.inl_apply
-/

#print NonUnitalStarAlgHom.coe_inr /-
@[simp]
theorem coe_inr : (inr R A B : B → A × B) = Prod.mk 0 :=
  rfl
#align non_unital_star_alg_hom.coe_inr NonUnitalStarAlgHom.coe_inr
-/

#print NonUnitalStarAlgHom.inr_apply /-
theorem inr_apply (x : B) : inr R A B x = (0, x) :=
  rfl
#align non_unital_star_alg_hom.inr_apply NonUnitalStarAlgHom.inr_apply
-/

end InlInr

end NonUnitalStarAlgHom

namespace StarAlgHom

variable (R A B C : Type _) [CommSemiring R] [Semiring A] [Algebra R A] [Star A] [Semiring B]
  [Algebra R B] [Star B] [Semiring C] [Algebra R C] [Star C]

#print StarAlgHom.fst /-
/-- The first projection of a product is a ⋆-algebra homomoprhism. -/
@[simps]
def fst : A × B →⋆ₐ[R] A :=
  { AlgHom.fst R A B with map_star' := fun x => rfl }
#align star_alg_hom.fst StarAlgHom.fst
-/

#print StarAlgHom.snd /-
/-- The second projection of a product is a ⋆-algebra homomorphism. -/
@[simps]
def snd : A × B →⋆ₐ[R] B :=
  { AlgHom.snd R A B with map_star' := fun x => rfl }
#align star_alg_hom.snd StarAlgHom.snd
-/

variable {R A B C}

#print StarAlgHom.prod /-
/-- The `pi.prod` of two morphisms is a morphism. -/
@[simps]
def prod (f : A →⋆ₐ[R] B) (g : A →⋆ₐ[R] C) : A →⋆ₐ[R] B × C :=
  { f.toAlgHom.Prod g.toAlgHom with map_star' := fun x => by simp [Prod.star_def, map_star] }
#align star_alg_hom.prod StarAlgHom.prod
-/

#print StarAlgHom.coe_prod /-
theorem coe_prod (f : A →⋆ₐ[R] B) (g : A →⋆ₐ[R] C) : ⇑(f.Prod g) = Pi.prod f g :=
  rfl
#align star_alg_hom.coe_prod StarAlgHom.coe_prod
-/

#print StarAlgHom.fst_prod /-
@[simp]
theorem fst_prod (f : A →⋆ₐ[R] B) (g : A →⋆ₐ[R] C) : (fst R B C).comp (prod f g) = f := by
  ext <;> rfl
#align star_alg_hom.fst_prod StarAlgHom.fst_prod
-/

#print StarAlgHom.snd_prod /-
@[simp]
theorem snd_prod (f : A →⋆ₐ[R] B) (g : A →⋆ₐ[R] C) : (snd R B C).comp (prod f g) = g := by
  ext <;> rfl
#align star_alg_hom.snd_prod StarAlgHom.snd_prod
-/

#print StarAlgHom.prod_fst_snd /-
@[simp]
theorem prod_fst_snd : prod (fst R A B) (snd R A B) = 1 :=
  FunLike.coe_injective Pi.prod_fst_snd
#align star_alg_hom.prod_fst_snd StarAlgHom.prod_fst_snd
-/

#print StarAlgHom.prodEquiv /-
/-- Taking the product of two maps with the same domain is equivalent to taking the product of
their codomains. -/
@[simps]
def prodEquiv : (A →⋆ₐ[R] B) × (A →⋆ₐ[R] C) ≃ (A →⋆ₐ[R] B × C)
    where
  toFun f := f.1.Prod f.2
  invFun f := ((fst _ _ _).comp f, (snd _ _ _).comp f)
  left_inv f := by ext <;> rfl
  right_inv f := by ext <;> rfl
#align star_alg_hom.prod_equiv StarAlgHom.prodEquiv
-/

end StarAlgHom

/-! ### Star algebra equivalences -/


#print StarAlgEquiv /-
/-- A *⋆-algebra* equivalence is an equivalence preserving addition, multiplication, scalar
multiplication and the star operation, which allows for considering both unital and non-unital
equivalences with a single structure. Currently, `alg_equiv` requires unital algebras, which is
why this structure does not extend it. -/
structure StarAlgEquiv (R A B : Type _) [Add A] [Mul A] [SMul R A] [Star A] [Add B] [Mul B]
    [SMul R B] [Star B] extends A ≃+* B where
  map_star' : ∀ a : A, to_fun (star a) = star (to_fun a)
  map_smul' : ∀ (r : R) (a : A), to_fun (r • a) = r • to_fun a
#align star_alg_equiv StarAlgEquiv
-/

infixr:25 " ≃⋆ₐ " => StarAlgEquiv _

notation:25 A " ≃⋆ₐ[" R "] " B => StarAlgEquiv R A B

/-- Reinterpret a star algebra equivalence as a `ring_equiv` by forgetting the interaction with
the star operation and scalar multiplication. -/
add_decl_doc StarAlgEquiv.toRingEquiv

#print StarAlgEquivClass /-
/-- `star_alg_equiv_class F R A B` asserts `F` is a type of bundled ⋆-algebra equivalences between
`A` and `B`.

You should also extend this typeclass when you extend `star_alg_equiv`. -/
class StarAlgEquivClass (F : Type _) (R : outParam (Type _)) (A : outParam (Type _))
    (B : outParam (Type _)) [Add A] [Mul A] [SMul R A] [Star A] [Add B] [Mul B] [SMul R B]
    [Star B] extends RingEquivClass F A B where
  map_star : ∀ (f : F) (a : A), f (star a) = star (f a)
  map_smul : ∀ (f : F) (r : R) (a : A), f (r • a) = r • f a
#align star_alg_equiv_class StarAlgEquivClass
-/

-- `R` becomes a metavariable but that's fine because it's an `out_param`
attribute [nolint dangerous_instance] StarAlgEquivClass.toRingEquivClass

namespace StarAlgEquivClass

-- See note [lower instance priority]
instance (priority := 50) {F R A B : Type _} [Add A] [Mul A] [SMul R A] [Star A] [Add B] [Mul B]
    [SMul R B] [Star B] [hF : StarAlgEquivClass F R A B] : StarHomClass F A B :=
  { hF with
    coe := fun f => f
    coe_injective' := FunLike.coe_injective }

-- `R` becomes a metavariable but that's fine because it's an `out_param`
attribute [nolint dangerous_instance] StarAlgEquivClass.starHomClass

-- See note [lower instance priority]
instance (priority := 50) {F R A B : Type _} [Add A] [Mul A] [Star A] [SMul R A] [Add B] [Mul B]
    [SMul R B] [Star B] [hF : StarAlgEquivClass F R A B] : SMulHomClass F R A B :=
  { hF with
    coe := fun f => f
    coe_injective' := FunLike.coe_injective }

-- `R` becomes a metavariable but that's fine because it's an `out_param`
attribute [nolint dangerous_instance] StarAlgEquivClass.smulHomClass

-- See note [lower instance priority]
instance (priority := 100) {F R A B : Type _} [Monoid R] [NonUnitalNonAssocSemiring A]
    [DistribMulAction R A] [Star A] [NonUnitalNonAssocSemiring B] [DistribMulAction R B] [Star B]
    [hF : StarAlgEquivClass F R A B] : NonUnitalStarAlgHomClass F R A B :=
  { hF with
    coe := fun f => f
    coe_injective' := FunLike.coe_injective
    map_zero := map_zero }

-- See note [lower instance priority]
instance (priority := 100) (F R A B : Type _) [CommSemiring R] [Semiring A] [Algebra R A] [Star A]
    [Semiring B] [Algebra R B] [Star B] [hF : StarAlgEquivClass F R A B] :
    StarAlgHomClass F R A B :=
  { hF with
    coe := fun f => f
    coe_injective' := FunLike.coe_injective
    map_one := map_one
    map_zero := map_zero
    commutes := fun f r => by simp only [Algebra.algebraMap_eq_smul_one, map_smul, map_one] }

end StarAlgEquivClass

namespace StarAlgEquiv

section Basic

variable {F R A B C : Type _} [Add A] [Mul A] [SMul R A] [Star A] [Add B] [Mul B] [SMul R B]
  [Star B] [Add C] [Mul C] [SMul R C] [Star C]

instance : StarAlgEquivClass (A ≃⋆ₐ[R] B) R A B
    where
  coe := toFun
  inv := invFun
  left_inv := left_inv
  right_inv := right_inv
  coe_injective' f g h₁ h₂ := by cases f; cases g; congr
  map_mul := map_mul'
  map_add := map_add'
  map_star := map_star'
  map_smul := map_smul'

/-- Helper instance for when there's too many metavariables to apply
`fun_like.has_coe_to_fun` directly. -/
instance : CoeFun (A ≃⋆ₐ[R] B) fun _ => A → B :=
  ⟨StarAlgEquiv.toFun⟩

#print StarAlgEquiv.ext /-
@[ext]
theorem ext {f g : A ≃⋆ₐ[R] B} (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align star_alg_equiv.ext StarAlgEquiv.ext
-/

#print StarAlgEquiv.ext_iff /-
theorem ext_iff {f g : A ≃⋆ₐ[R] B} : f = g ↔ ∀ a, f a = g a :=
  FunLike.ext_iff
#align star_alg_equiv.ext_iff StarAlgEquiv.ext_iff
-/

#print StarAlgEquiv.refl /-
/-- Star algebra equivalences are reflexive. -/
@[refl]
def refl : A ≃⋆ₐ[R] A :=
  { RingEquiv.refl A with
    map_smul' := fun r a => rfl
    map_star' := fun a => rfl }
#align star_alg_equiv.refl StarAlgEquiv.refl
-/

instance : Inhabited (A ≃⋆ₐ[R] A) :=
  ⟨refl⟩

#print StarAlgEquiv.coe_refl /-
@[simp]
theorem coe_refl : ⇑(refl : A ≃⋆ₐ[R] A) = id :=
  rfl
#align star_alg_equiv.coe_refl StarAlgEquiv.coe_refl
-/

#print StarAlgEquiv.symm /-
/-- Star algebra equivalences are symmetric. -/
@[symm]
def symm (e : A ≃⋆ₐ[R] B) : B ≃⋆ₐ[R] A :=
  {
    e.toRingEquiv.symm with
    map_star' := fun b => by
      simpa only [e.left_inv (star (e.inv_fun b)), e.right_inv b] using
        congr_arg e.inv_fun (e.map_star' (e.inv_fun b)).symm
    map_smul' := fun r b => by
      simpa only [e.left_inv (r • e.inv_fun b), e.right_inv b] using
        congr_arg e.inv_fun (e.map_smul' r (e.inv_fun b)).symm }
#align star_alg_equiv.symm StarAlgEquiv.symm
-/

#print StarAlgEquiv.Simps.symm_apply /-
/-- See Note [custom simps projection] -/
def Simps.symm_apply (e : A ≃⋆ₐ[R] B) : B → A :=
  e.symm
#align star_alg_equiv.simps.symm_apply StarAlgEquiv.Simps.symm_apply
-/

initialize_simps_projections StarAlgEquiv (toFun → apply, invFun → simps.symm_apply)

#print StarAlgEquiv.invFun_eq_symm /-
@[simp]
theorem invFun_eq_symm {e : A ≃⋆ₐ[R] B} : e.invFun = e.symm :=
  rfl
#align star_alg_equiv.inv_fun_eq_symm StarAlgEquiv.invFun_eq_symm
-/

#print StarAlgEquiv.symm_symm /-
@[simp]
theorem symm_symm (e : A ≃⋆ₐ[R] B) : e.symm.symm = e := by ext; rfl
#align star_alg_equiv.symm_symm StarAlgEquiv.symm_symm
-/

#print StarAlgEquiv.symm_bijective /-
theorem symm_bijective : Function.Bijective (symm : (A ≃⋆ₐ[R] B) → B ≃⋆ₐ[R] A) :=
  Equiv.bijective ⟨symm, symm, symm_symm, symm_symm⟩
#align star_alg_equiv.symm_bijective StarAlgEquiv.symm_bijective
-/

@[simp]
theorem mk_coe' (e : A ≃⋆ₐ[R] B) (f h₁ h₂ h₃ h₄ h₅ h₆) :
    (⟨f, e, h₁, h₂, h₃, h₄, h₅, h₆⟩ : B ≃⋆ₐ[R] A) = e.symm :=
  symm_bijective.Injective <| ext fun x => rfl
#align star_alg_equiv.mk_coe' StarAlgEquiv.mk_coe'ₓ

@[simp]
theorem symm_mk (f f') (h₁ h₂ h₃ h₄ h₅ h₆) :
    (⟨f, f', h₁, h₂, h₃, h₄, h₅, h₆⟩ : A ≃⋆ₐ[R] B).symm =
      {
        (⟨f, f', h₁, h₂, h₃, h₄, h₅, h₆⟩ :
            A ≃⋆ₐ[R] B).symm with
        toFun := f'
        invFun := f } :=
  rfl
#align star_alg_equiv.symm_mk StarAlgEquiv.symm_mkₓ

#print StarAlgEquiv.refl_symm /-
@[simp]
theorem refl_symm : (StarAlgEquiv.refl : A ≃⋆ₐ[R] A).symm = StarAlgEquiv.refl :=
  rfl
#align star_alg_equiv.refl_symm StarAlgEquiv.refl_symm
-/

#print StarAlgEquiv.to_ringEquiv_symm /-
-- should be a `simp` lemma, but causes a linter timeout
theorem to_ringEquiv_symm (f : A ≃⋆ₐ[R] B) : (f : A ≃+* B).symm = f.symm :=
  rfl
#align star_alg_equiv.to_ring_equiv_symm StarAlgEquiv.to_ringEquiv_symm
-/

#print StarAlgEquiv.symm_to_ringEquiv /-
@[simp]
theorem symm_to_ringEquiv (e : A ≃⋆ₐ[R] B) : (e.symm : B ≃+* A) = (e : A ≃+* B).symm :=
  rfl
#align star_alg_equiv.symm_to_ring_equiv StarAlgEquiv.symm_to_ringEquiv
-/

#print StarAlgEquiv.trans /-
/-- Star algebra equivalences are transitive. -/
@[trans]
def trans (e₁ : A ≃⋆ₐ[R] B) (e₂ : B ≃⋆ₐ[R] C) : A ≃⋆ₐ[R] C :=
  {
    e₁.toRingEquiv.trans
      e₂.toRingEquiv with
    map_smul' := fun r a =>
      show e₂.toFun (e₁.toFun (r • a)) = r • e₂.toFun (e₁.toFun a) by
        rw [e₁.map_smul', e₂.map_smul']
    map_star' := fun a =>
      show e₂.toFun (e₁.toFun (star a)) = star (e₂.toFun (e₁.toFun a)) by
        rw [e₁.map_star', e₂.map_star'] }
#align star_alg_equiv.trans StarAlgEquiv.trans
-/

#print StarAlgEquiv.apply_symm_apply /-
@[simp]
theorem apply_symm_apply (e : A ≃⋆ₐ[R] B) : ∀ x, e (e.symm x) = x :=
  e.toRingEquiv.apply_symm_apply
#align star_alg_equiv.apply_symm_apply StarAlgEquiv.apply_symm_apply
-/

#print StarAlgEquiv.symm_apply_apply /-
@[simp]
theorem symm_apply_apply (e : A ≃⋆ₐ[R] B) : ∀ x, e.symm (e x) = x :=
  e.toRingEquiv.symm_apply_apply
#align star_alg_equiv.symm_apply_apply StarAlgEquiv.symm_apply_apply
-/

#print StarAlgEquiv.symm_trans_apply /-
@[simp]
theorem symm_trans_apply (e₁ : A ≃⋆ₐ[R] B) (e₂ : B ≃⋆ₐ[R] C) (x : C) :
    (e₁.trans e₂).symm x = e₁.symm (e₂.symm x) :=
  rfl
#align star_alg_equiv.symm_trans_apply StarAlgEquiv.symm_trans_apply
-/

#print StarAlgEquiv.coe_trans /-
@[simp]
theorem coe_trans (e₁ : A ≃⋆ₐ[R] B) (e₂ : B ≃⋆ₐ[R] C) : ⇑(e₁.trans e₂) = e₂ ∘ e₁ :=
  rfl
#align star_alg_equiv.coe_trans StarAlgEquiv.coe_trans
-/

#print StarAlgEquiv.trans_apply /-
@[simp]
theorem trans_apply (e₁ : A ≃⋆ₐ[R] B) (e₂ : B ≃⋆ₐ[R] C) (x : A) : (e₁.trans e₂) x = e₂ (e₁ x) :=
  rfl
#align star_alg_equiv.trans_apply StarAlgEquiv.trans_apply
-/

#print StarAlgEquiv.leftInverse_symm /-
theorem leftInverse_symm (e : A ≃⋆ₐ[R] B) : Function.LeftInverse e.symm e :=
  e.left_inv
#align star_alg_equiv.left_inverse_symm StarAlgEquiv.leftInverse_symm
-/

#print StarAlgEquiv.rightInverse_symm /-
theorem rightInverse_symm (e : A ≃⋆ₐ[R] B) : Function.RightInverse e.symm e :=
  e.right_inv
#align star_alg_equiv.right_inverse_symm StarAlgEquiv.rightInverse_symm
-/

end Basic

section Bijective

variable {F G R A B : Type _} [Monoid R]

variable [NonUnitalNonAssocSemiring A] [DistribMulAction R A] [Star A]

variable [NonUnitalNonAssocSemiring B] [DistribMulAction R B] [Star B]

variable [hF : NonUnitalStarAlgHomClass F R A B] [NonUnitalStarAlgHomClass G R B A]

#print StarAlgEquiv.ofStarAlgHom /-
/-- If a (unital or non-unital) star algebra morphism has an inverse, it is an isomorphism of
star algebras. -/
@[simps]
def ofStarAlgHom (f : F) (g : G) (h₁ : ∀ x, g (f x) = x) (h₂ : ∀ x, f (g x) = x) : A ≃⋆ₐ[R] B
    where
  toFun := f
  invFun := g
  left_inv := h₁
  right_inv := h₂
  map_add' := map_add f
  map_mul' := map_mul f
  map_smul' := map_smul f
  map_star' := map_star f
#align star_alg_equiv.of_star_alg_hom StarAlgEquiv.ofStarAlgHom
-/

#print StarAlgEquiv.ofBijective /-
/-- Promote a bijective star algebra homomorphism to a star algebra equivalence. -/
noncomputable def ofBijective (f : F) (hf : Function.Bijective f) : A ≃⋆ₐ[R] B :=
  {
    RingEquiv.ofBijective f
      (hf : Function.Bijective (f : A → B)) with
    toFun := f
    map_star' := map_star f
    map_smul' := map_smul f }
#align star_alg_equiv.of_bijective StarAlgEquiv.ofBijective
-/

#print StarAlgEquiv.coe_ofBijective /-
@[simp]
theorem coe_ofBijective {f : F} (hf : Function.Bijective f) :
    (StarAlgEquiv.ofBijective f hf : A → B) = f :=
  rfl
#align star_alg_equiv.coe_of_bijective StarAlgEquiv.coe_ofBijective
-/

#print StarAlgEquiv.ofBijective_apply /-
theorem ofBijective_apply {f : F} (hf : Function.Bijective f) (a : A) :
    (StarAlgEquiv.ofBijective f hf) a = f a :=
  rfl
#align star_alg_equiv.of_bijective_apply StarAlgEquiv.ofBijective_apply
-/

end Bijective

end StarAlgEquiv

