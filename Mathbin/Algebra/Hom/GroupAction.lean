/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module algebra.hom.group_action
! leanprover-community/mathlib commit e04043d6bf7264a3c84bc69711dc354958ca4516
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GroupRingAction.Basic
import Mathbin.Algebra.Module.Basic

/-!
# Equivariant homomorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `mul_action_hom M X Y`, the type of equivariant functions from `X` to `Y`, where `M` is a monoid
  that acts on the types `X` and `Y`.
* `distrib_mul_action_hom M A B`, the type of equivariant additive monoid homomorphisms
  from `A` to `B`, where `M` is a monoid that acts on the additive monoids `A` and `B`.
* `mul_semiring_action_hom M R S`, the type of equivariant ring homomorphisms
  from `R` to `S`, where `M` is a monoid that acts on the rings `R` and `S`.

The above types have corresponding classes:
* `smul_hom_class F M X Y` states that `F` is a type of bundled `X → Y` homs
  preserving scalar multiplication by `M`
* `distrib_mul_action_hom_class F M A B` states that `F` is a type of bundled `A → B` homs
  preserving the additive monoid structure and scalar multiplication by `M`
* `mul_semiring_action_hom_class F M R S` states that `F` is a type of bundled `R → S` homs
  preserving the ring structure and scalar multiplication by `M`

## Notations

* `X →[M] Y` is `mul_action_hom M X Y`.
* `A →+[M] B` is `distrib_mul_action_hom M A B`.
* `R →+*[M] S` is `mul_semiring_action_hom M R S`.

-/


assert_not_exists Submonoid

variable (M' : Type _)

variable (X : Type _) [SMul M' X]

variable (Y : Type _) [SMul M' Y]

variable (Z : Type _) [SMul M' Z]

variable (M : Type _) [Monoid M]

variable (A : Type _) [AddMonoid A] [DistribMulAction M A]

variable (A' : Type _) [AddGroup A'] [DistribMulAction M A']

variable (B : Type _) [AddMonoid B] [DistribMulAction M B]

variable (B' : Type _) [AddGroup B'] [DistribMulAction M B']

variable (C : Type _) [AddMonoid C] [DistribMulAction M C]

variable (R : Type _) [Semiring R] [MulSemiringAction M R]

variable (R' : Type _) [Ring R'] [MulSemiringAction M R']

variable (S : Type _) [Semiring S] [MulSemiringAction M S]

variable (S' : Type _) [Ring S'] [MulSemiringAction M S']

variable (T : Type _) [Semiring T] [MulSemiringAction M T]

#print MulActionHom /-
/-- Equivariant functions. -/
@[nolint has_nonempty_instance]
structure MulActionHom where
  toFun : X → Y
  map_smul' : ∀ (m : M') (x : X), to_fun (m • x) = m • to_fun x
#align mul_action_hom MulActionHom
-/

notation:25 X " →[" M:25 "] " Y:0 => MulActionHom M X Y

#print SMulHomClass /-
/-- `smul_hom_class F M X Y` states that `F` is a type of morphisms preserving
scalar multiplication by `M`.

You should extend this class when you extend `mul_action_hom`. -/
class SMulHomClass (F : Type _) (M X Y : outParam <| Type _) [SMul M X] [SMul M Y] extends
    FunLike F X fun _ => Y where
  map_smul : ∀ (f : F) (c : M) (x : X), f (c • x) = c • f x
#align smul_hom_class SMulHomClass
-/

-- `M` becomes a metavariable but it's an `out_param` so it's not a problem.
attribute [nolint dangerous_instance] SMulHomClass.toFunLike

export SMulHomClass (map_smul)

attribute [simp] map_smul

namespace MulActionHom

instance : CoeFun (X →[M'] Y) fun _ => X → Y :=
  ⟨MulActionHom.toFun⟩

instance : SMulHomClass (X →[M'] Y) M' X Y
    where
  coe := MulActionHom.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_smul := MulActionHom.map_smul'

variable {M M' X Y}

#print MulActionHom.map_smul /-
protected theorem map_smul (f : X →[M'] Y) (m : M') (x : X) : f (m • x) = m • f x :=
  map_smul _ _ _
#align mul_action_hom.map_smul MulActionHom.map_smul
-/

#print MulActionHom.ext /-
@[ext]
theorem ext : ∀ {f g : X →[M'] Y}, (∀ x, f x = g x) → f = g :=
  FunLike.ext
#align mul_action_hom.ext MulActionHom.ext
-/

#print MulActionHom.ext_iff /-
theorem ext_iff {f g : X →[M'] Y} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align mul_action_hom.ext_iff MulActionHom.ext_iff
-/

#print MulActionHom.congr_fun /-
protected theorem congr_fun {f g : X →[M'] Y} (h : f = g) (x : X) : f x = g x :=
  FunLike.congr_fun h _
#align mul_action_hom.congr_fun MulActionHom.congr_fun
-/

variable (M M') {X}

#print MulActionHom.id /-
/-- The identity map as an equivariant map. -/
protected def id : X →[M'] X :=
  ⟨id, fun _ _ => rfl⟩
#align mul_action_hom.id MulActionHom.id
-/

#print MulActionHom.id_apply /-
@[simp]
theorem id_apply (x : X) : MulActionHom.id M' x = x :=
  rfl
#align mul_action_hom.id_apply MulActionHom.id_apply
-/

variable {M M' X Y Z}

#print MulActionHom.comp /-
/-- Composition of two equivariant maps. -/
def comp (g : Y →[M'] Z) (f : X →[M'] Y) : X →[M'] Z :=
  ⟨g ∘ f, fun m x =>
    calc
      g (f (m • x)) = g (m • f x) := by rw [f.map_smul]
      _ = m • g (f x) := g.map_smul _ _⟩
#align mul_action_hom.comp MulActionHom.comp
-/

#print MulActionHom.comp_apply /-
@[simp]
theorem comp_apply (g : Y →[M'] Z) (f : X →[M'] Y) (x : X) : g.comp f x = g (f x) :=
  rfl
#align mul_action_hom.comp_apply MulActionHom.comp_apply
-/

#print MulActionHom.id_comp /-
@[simp]
theorem id_comp (f : X →[M'] Y) : (MulActionHom.id M').comp f = f :=
  ext fun x => by rw [comp_apply, id_apply]
#align mul_action_hom.id_comp MulActionHom.id_comp
-/

#print MulActionHom.comp_id /-
@[simp]
theorem comp_id (f : X →[M'] Y) : f.comp (MulActionHom.id M') = f :=
  ext fun x => by rw [comp_apply, id_apply]
#align mul_action_hom.comp_id MulActionHom.comp_id
-/

variable {A B}

#print MulActionHom.inverse /-
/-- The inverse of a bijective equivariant map is equivariant. -/
@[simps]
def inverse (f : A →[M] B) (g : B → A) (h₁ : Function.LeftInverse g f)
    (h₂ : Function.RightInverse g f) : B →[M] A
    where
  toFun := g
  map_smul' m x :=
    calc
      g (m • x) = g (m • f (g x)) := by rw [h₂]
      _ = g (f (m • g x)) := by rw [f.map_smul]
      _ = m • g x := by rw [h₁]
#align mul_action_hom.inverse MulActionHom.inverse
-/

end MulActionHom

#print DistribMulActionHom /-
/-- Equivariant additive monoid homomorphisms. -/
structure DistribMulActionHom extends A →[M] B, A →+ B
#align distrib_mul_action_hom DistribMulActionHom
-/

/-- Reinterpret an equivariant additive monoid homomorphism as an additive monoid homomorphism. -/
add_decl_doc DistribMulActionHom.toAddMonoidHom

/-- Reinterpret an equivariant additive monoid homomorphism as an equivariant function. -/
add_decl_doc DistribMulActionHom.toMulActionHom

notation:25 A " →+[" M:25 "] " B:0 => DistribMulActionHom M A B

#print DistribMulActionHomClass /-
/-- `distrib_mul_action_hom_class F M A B` states that `F` is a type of morphisms preserving
the additive monoid structure and scalar multiplication by `M`.

You should extend this class when you extend `distrib_mul_action_hom`. -/
class DistribMulActionHomClass (F : Type _) (M A B : outParam <| Type _) [Monoid M] [AddMonoid A]
    [AddMonoid B] [DistribMulAction M A] [DistribMulAction M B] extends SMulHomClass F M A B,
    AddMonoidHomClass F A B
#align distrib_mul_action_hom_class DistribMulActionHomClass
-/

-- `M` becomes a metavariable but it's an `out_param` so it's not a problem.
attribute [nolint dangerous_instance] DistribMulActionHomClass.toAddMonoidHomClass

namespace DistribMulActionHom

instance hasCoe : Coe (A →+[M] B) (A →+ B) :=
  ⟨toAddMonoidHom⟩
#align distrib_mul_action_hom.has_coe DistribMulActionHom.hasCoe

instance hasCoe' : Coe (A →+[M] B) (A →[M] B) :=
  ⟨toMulActionHom⟩
#align distrib_mul_action_hom.has_coe' DistribMulActionHom.hasCoe'

instance : CoeFun (A →+[M] B) fun _ => A → B :=
  ⟨toFun⟩

instance : DistribMulActionHomClass (A →+[M] B) M A B
    where
  coe := DistribMulActionHom.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_smul := DistribMulActionHom.map_smul'
  map_zero := DistribMulActionHom.map_zero'
  map_add := DistribMulActionHom.map_add'

variable {M A B}

#print DistribMulActionHom.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe (f : A →+[M] B) : f.toFun = ⇑f :=
  rfl
#align distrib_mul_action_hom.to_fun_eq_coe DistribMulActionHom.toFun_eq_coe
-/

#print DistribMulActionHom.coe_fn_coe /-
@[norm_cast]
theorem coe_fn_coe (f : A →+[M] B) : ((f : A →+ B) : A → B) = f :=
  rfl
#align distrib_mul_action_hom.coe_fn_coe DistribMulActionHom.coe_fn_coe
-/

#print DistribMulActionHom.coe_fn_coe' /-
@[norm_cast]
theorem coe_fn_coe' (f : A →+[M] B) : ((f : A →[M] B) : A → B) = f :=
  rfl
#align distrib_mul_action_hom.coe_fn_coe' DistribMulActionHom.coe_fn_coe'
-/

#print DistribMulActionHom.ext /-
@[ext]
theorem ext : ∀ {f g : A →+[M] B}, (∀ x, f x = g x) → f = g :=
  FunLike.ext
#align distrib_mul_action_hom.ext DistribMulActionHom.ext
-/

#print DistribMulActionHom.ext_iff /-
theorem ext_iff {f g : A →+[M] B} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align distrib_mul_action_hom.ext_iff DistribMulActionHom.ext_iff
-/

#print DistribMulActionHom.congr_fun /-
protected theorem congr_fun {f g : A →+[M] B} (h : f = g) (x : A) : f x = g x :=
  FunLike.congr_fun h _
#align distrib_mul_action_hom.congr_fun DistribMulActionHom.congr_fun
-/

#print DistribMulActionHom.toMulActionHom_injective /-
theorem toMulActionHom_injective {f g : A →+[M] B} (h : (f : A →[M] B) = (g : A →[M] B)) : f = g :=
  by ext a; exact MulActionHom.congr_fun h a
#align distrib_mul_action_hom.to_mul_action_hom_injective DistribMulActionHom.toMulActionHom_injective
-/

#print DistribMulActionHom.toAddMonoidHom_injective /-
theorem toAddMonoidHom_injective {f g : A →+[M] B} (h : (f : A →+ B) = (g : A →+ B)) : f = g := by
  ext a; exact AddMonoidHom.congr_fun h a
#align distrib_mul_action_hom.to_add_monoid_hom_injective DistribMulActionHom.toAddMonoidHom_injective
-/

#print DistribMulActionHom.map_zero /-
protected theorem map_zero (f : A →+[M] B) : f 0 = 0 :=
  map_zero _
#align distrib_mul_action_hom.map_zero DistribMulActionHom.map_zero
-/

#print DistribMulActionHom.map_add /-
protected theorem map_add (f : A →+[M] B) (x y : A) : f (x + y) = f x + f y :=
  map_add _ _ _
#align distrib_mul_action_hom.map_add DistribMulActionHom.map_add
-/

#print DistribMulActionHom.map_neg /-
protected theorem map_neg (f : A' →+[M] B') (x : A') : f (-x) = -f x :=
  map_neg _ _
#align distrib_mul_action_hom.map_neg DistribMulActionHom.map_neg
-/

#print DistribMulActionHom.map_sub /-
protected theorem map_sub (f : A' →+[M] B') (x y : A') : f (x - y) = f x - f y :=
  map_sub _ _ _
#align distrib_mul_action_hom.map_sub DistribMulActionHom.map_sub
-/

#print DistribMulActionHom.map_smul /-
protected theorem map_smul (f : A →+[M] B) (m : M) (x : A) : f (m • x) = m • f x :=
  map_smul _ _ _
#align distrib_mul_action_hom.map_smul DistribMulActionHom.map_smul
-/

variable (M) {A}

#print DistribMulActionHom.id /-
/-- The identity map as an equivariant additive monoid homomorphism. -/
protected def id : A →+[M] A :=
  ⟨id, fun _ _ => rfl, rfl, fun _ _ => rfl⟩
#align distrib_mul_action_hom.id DistribMulActionHom.id
-/

#print DistribMulActionHom.id_apply /-
@[simp]
theorem id_apply (x : A) : DistribMulActionHom.id M x = x :=
  rfl
#align distrib_mul_action_hom.id_apply DistribMulActionHom.id_apply
-/

variable {M A B C}

instance : Zero (A →+[M] B) :=
  ⟨{ (0 : A →+ B) with map_smul' := by simp }⟩

instance : One (A →+[M] A) :=
  ⟨DistribMulActionHom.id M⟩

#print DistribMulActionHom.coe_zero /-
@[simp]
theorem coe_zero : ((0 : A →+[M] B) : A → B) = 0 :=
  rfl
#align distrib_mul_action_hom.coe_zero DistribMulActionHom.coe_zero
-/

#print DistribMulActionHom.coe_one /-
@[simp]
theorem coe_one : ((1 : A →+[M] A) : A → A) = id :=
  rfl
#align distrib_mul_action_hom.coe_one DistribMulActionHom.coe_one
-/

#print DistribMulActionHom.zero_apply /-
theorem zero_apply (a : A) : (0 : A →+[M] B) a = 0 :=
  rfl
#align distrib_mul_action_hom.zero_apply DistribMulActionHom.zero_apply
-/

#print DistribMulActionHom.one_apply /-
theorem one_apply (a : A) : (1 : A →+[M] A) a = a :=
  rfl
#align distrib_mul_action_hom.one_apply DistribMulActionHom.one_apply
-/

instance : Inhabited (A →+[M] B) :=
  ⟨0⟩

#print DistribMulActionHom.comp /-
/-- Composition of two equivariant additive monoid homomorphisms. -/
def comp (g : B →+[M] C) (f : A →+[M] B) : A →+[M] C :=
  { MulActionHom.comp (g : B →[M] C) (f : A →[M] B),
    AddMonoidHom.comp (g : B →+ C) (f : A →+ B) with }
#align distrib_mul_action_hom.comp DistribMulActionHom.comp
-/

#print DistribMulActionHom.comp_apply /-
@[simp]
theorem comp_apply (g : B →+[M] C) (f : A →+[M] B) (x : A) : g.comp f x = g (f x) :=
  rfl
#align distrib_mul_action_hom.comp_apply DistribMulActionHom.comp_apply
-/

#print DistribMulActionHom.id_comp /-
@[simp]
theorem id_comp (f : A →+[M] B) : (DistribMulActionHom.id M).comp f = f :=
  ext fun x => by rw [comp_apply, id_apply]
#align distrib_mul_action_hom.id_comp DistribMulActionHom.id_comp
-/

#print DistribMulActionHom.comp_id /-
@[simp]
theorem comp_id (f : A →+[M] B) : f.comp (DistribMulActionHom.id M) = f :=
  ext fun x => by rw [comp_apply, id_apply]
#align distrib_mul_action_hom.comp_id DistribMulActionHom.comp_id
-/

#print DistribMulActionHom.inverse /-
/-- The inverse of a bijective `distrib_mul_action_hom` is a `distrib_mul_action_hom`. -/
@[simps]
def inverse (f : A →+[M] B) (g : B → A) (h₁ : Function.LeftInverse g f)
    (h₂ : Function.RightInverse g f) : B →+[M] A :=
  { (f : A →+ B).inverse g h₁ h₂, (f : A →[M] B).inverse g h₁ h₂ with toFun := g }
#align distrib_mul_action_hom.inverse DistribMulActionHom.inverse
-/

section Semiring

variable {R M'} [AddMonoid M'] [DistribMulAction R M']

#print DistribMulActionHom.ext_ring /-
@[ext]
theorem ext_ring {f g : R →+[R] M'} (h : f 1 = g 1) : f = g := by ext x;
  rw [← mul_one x, ← smul_eq_mul R, f.map_smul, g.map_smul, h]
#align distrib_mul_action_hom.ext_ring DistribMulActionHom.ext_ring
-/

#print DistribMulActionHom.ext_ring_iff /-
theorem ext_ring_iff {f g : R →+[R] M'} : f = g ↔ f 1 = g 1 :=
  ⟨fun h => h ▸ rfl, ext_ring⟩
#align distrib_mul_action_hom.ext_ring_iff DistribMulActionHom.ext_ring_iff
-/

end Semiring

end DistribMulActionHom

#print MulSemiringActionHom /-
/-- Equivariant ring homomorphisms. -/
@[nolint has_nonempty_instance]
structure MulSemiringActionHom extends R →+[M] S, R →+* S
#align mul_semiring_action_hom MulSemiringActionHom
-/

/-- Reinterpret an equivariant ring homomorphism as a ring homomorphism. -/
add_decl_doc MulSemiringActionHom.toRingHom

/-- Reinterpret an equivariant ring homomorphism as an equivariant additive monoid homomorphism. -/
add_decl_doc MulSemiringActionHom.toDistribMulActionHom

notation:25 R " →+*[" M:25 "] " S:0 => MulSemiringActionHom M R S

#print MulSemiringActionHomClass /-
/-- `mul_semiring_action_hom_class F M R S` states that `F` is a type of morphisms preserving
the ring structure and scalar multiplication by `M`.

You should extend this class when you extend `mul_semiring_action_hom`. -/
class MulSemiringActionHomClass (F : Type _) (M R S : outParam <| Type _) [Monoid M] [Semiring R]
    [Semiring S] [DistribMulAction M R] [DistribMulAction M S] extends
    DistribMulActionHomClass F M R S, RingHomClass F R S
#align mul_semiring_action_hom_class MulSemiringActionHomClass
-/

-- `M` becomes a metavariable but it's an `out_param` so it's not a problem.
attribute [nolint dangerous_instance] MulSemiringActionHomClass.toRingHomClass

namespace MulSemiringActionHom

instance hasCoe : Coe (R →+*[M] S) (R →+* S) :=
  ⟨toRingHom⟩
#align mul_semiring_action_hom.has_coe MulSemiringActionHom.hasCoe

instance hasCoe' : Coe (R →+*[M] S) (R →+[M] S) :=
  ⟨toDistribMulActionHom⟩
#align mul_semiring_action_hom.has_coe' MulSemiringActionHom.hasCoe'

instance : CoeFun (R →+*[M] S) fun _ => R → S :=
  ⟨fun c => c.toFun⟩

instance : MulSemiringActionHomClass (R →+*[M] S) M R S
    where
  coe := MulSemiringActionHom.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_smul := MulSemiringActionHom.map_smul'
  map_zero := MulSemiringActionHom.map_zero'
  map_add := MulSemiringActionHom.map_add'
  map_one := MulSemiringActionHom.map_one'
  map_mul := MulSemiringActionHom.map_mul'

variable {M R S}

#print MulSemiringActionHom.coe_fn_coe /-
@[norm_cast]
theorem coe_fn_coe (f : R →+*[M] S) : ((f : R →+* S) : R → S) = f :=
  rfl
#align mul_semiring_action_hom.coe_fn_coe MulSemiringActionHom.coe_fn_coe
-/

#print MulSemiringActionHom.coe_fn_coe' /-
@[norm_cast]
theorem coe_fn_coe' (f : R →+*[M] S) : ((f : R →+[M] S) : R → S) = f :=
  rfl
#align mul_semiring_action_hom.coe_fn_coe' MulSemiringActionHom.coe_fn_coe'
-/

#print MulSemiringActionHom.ext /-
@[ext]
theorem ext : ∀ {f g : R →+*[M] S}, (∀ x, f x = g x) → f = g :=
  FunLike.ext
#align mul_semiring_action_hom.ext MulSemiringActionHom.ext
-/

#print MulSemiringActionHom.ext_iff /-
theorem ext_iff {f g : R →+*[M] S} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align mul_semiring_action_hom.ext_iff MulSemiringActionHom.ext_iff
-/

#print MulSemiringActionHom.map_zero /-
protected theorem map_zero (f : R →+*[M] S) : f 0 = 0 :=
  map_zero _
#align mul_semiring_action_hom.map_zero MulSemiringActionHom.map_zero
-/

#print MulSemiringActionHom.map_add /-
protected theorem map_add (f : R →+*[M] S) (x y : R) : f (x + y) = f x + f y :=
  map_add _ _ _
#align mul_semiring_action_hom.map_add MulSemiringActionHom.map_add
-/

#print MulSemiringActionHom.map_neg /-
protected theorem map_neg (f : R' →+*[M] S') (x : R') : f (-x) = -f x :=
  map_neg _ _
#align mul_semiring_action_hom.map_neg MulSemiringActionHom.map_neg
-/

#print MulSemiringActionHom.map_sub /-
protected theorem map_sub (f : R' →+*[M] S') (x y : R') : f (x - y) = f x - f y :=
  map_sub _ _ _
#align mul_semiring_action_hom.map_sub MulSemiringActionHom.map_sub
-/

#print MulSemiringActionHom.map_one /-
protected theorem map_one (f : R →+*[M] S) : f 1 = 1 :=
  map_one _
#align mul_semiring_action_hom.map_one MulSemiringActionHom.map_one
-/

#print MulSemiringActionHom.map_mul /-
protected theorem map_mul (f : R →+*[M] S) (x y : R) : f (x * y) = f x * f y :=
  map_mul _ _ _
#align mul_semiring_action_hom.map_mul MulSemiringActionHom.map_mul
-/

#print MulSemiringActionHom.map_smul /-
protected theorem map_smul (f : R →+*[M] S) (m : M) (x : R) : f (m • x) = m • f x :=
  map_smul _ _ _
#align mul_semiring_action_hom.map_smul MulSemiringActionHom.map_smul
-/

variable (M) {R}

#print MulSemiringActionHom.id /-
/-- The identity map as an equivariant ring homomorphism. -/
protected def id : R →+*[M] R :=
  ⟨id, fun _ _ => rfl, rfl, fun _ _ => rfl, rfl, fun _ _ => rfl⟩
#align mul_semiring_action_hom.id MulSemiringActionHom.id
-/

#print MulSemiringActionHom.id_apply /-
@[simp]
theorem id_apply (x : R) : MulSemiringActionHom.id M x = x :=
  rfl
#align mul_semiring_action_hom.id_apply MulSemiringActionHom.id_apply
-/

variable {M R S T}

#print MulSemiringActionHom.comp /-
/-- Composition of two equivariant additive monoid homomorphisms. -/
def comp (g : S →+*[M] T) (f : R →+*[M] S) : R →+*[M] T :=
  { DistribMulActionHom.comp (g : S →+[M] T) (f : R →+[M] S),
    RingHom.comp (g : S →+* T) (f : R →+* S) with }
#align mul_semiring_action_hom.comp MulSemiringActionHom.comp
-/

#print MulSemiringActionHom.comp_apply /-
@[simp]
theorem comp_apply (g : S →+*[M] T) (f : R →+*[M] S) (x : R) : g.comp f x = g (f x) :=
  rfl
#align mul_semiring_action_hom.comp_apply MulSemiringActionHom.comp_apply
-/

#print MulSemiringActionHom.id_comp /-
@[simp]
theorem id_comp (f : R →+*[M] S) : (MulSemiringActionHom.id M).comp f = f :=
  ext fun x => by rw [comp_apply, id_apply]
#align mul_semiring_action_hom.id_comp MulSemiringActionHom.id_comp
-/

#print MulSemiringActionHom.comp_id /-
@[simp]
theorem comp_id (f : R →+*[M] S) : f.comp (MulSemiringActionHom.id M) = f :=
  ext fun x => by rw [comp_apply, id_apply]
#align mul_semiring_action_hom.comp_id MulSemiringActionHom.comp_id
-/

end MulSemiringActionHom

