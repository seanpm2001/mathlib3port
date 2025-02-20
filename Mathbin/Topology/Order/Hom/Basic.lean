/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module topology.order.hom.basic
! leanprover-community/mathlib commit b6da1a0b3e7cd83b1f744c49ce48ef8c6307d2f6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Hom.Basic
import Mathbin.Topology.ContinuousFunction.Basic

/-!
# Continuous order homomorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines continuous order homomorphisms, that is maps which are both continuous and
monotone. They are also called Priestley homomorphisms because they are the morphisms of the
category of Priestley spaces.

We use the `fun_like` design, so each type of morphisms has a companion typeclass which is meant to
be satisfied by itself and all stricter types.

## Types of morphisms

* `continuous_order_hom`: Continuous monotone functions, aka Priestley homomorphisms.

## Typeclasses

* `continuous_order_hom_class`
-/


open Function

variable {F α β γ δ : Type _}

#print ContinuousOrderHom /-
/-- The type of continuous monotone maps from `α` to `β`, aka Priestley homomorphisms. -/
structure ContinuousOrderHom (α β : Type _) [Preorder α] [Preorder β] [TopologicalSpace α]
    [TopologicalSpace β] extends OrderHom α β where
  continuous_toFun : Continuous to_fun
#align continuous_order_hom ContinuousOrderHom
-/

infixr:25 " →Co " => ContinuousOrderHom

section

#print ContinuousOrderHomClass /-
/-- `continuous_order_hom_class F α β` states that `F` is a type of continuous monotone maps.

You should extend this class when you extend `continuous_order_hom`. -/
class ContinuousOrderHomClass (F : Type _) (α β : outParam <| Type _) [Preorder α] [Preorder β]
    [TopologicalSpace α] [TopologicalSpace β] extends
    RelHomClass F ((· ≤ ·) : α → α → Prop) ((· ≤ ·) : β → β → Prop) where
  map_continuous (f : F) : Continuous f
#align continuous_order_hom_class ContinuousOrderHomClass
-/

end

#print ContinuousOrderHomClass.toContinuousMapClass /-
-- See note [lower instance priority]
instance (priority := 100) ContinuousOrderHomClass.toContinuousMapClass [Preorder α] [Preorder β]
    [TopologicalSpace α] [TopologicalSpace β] [ContinuousOrderHomClass F α β] :
    ContinuousMapClass F α β :=
  { ‹ContinuousOrderHomClass F α β› with }
#align continuous_order_hom_class.to_continuous_map_class ContinuousOrderHomClass.toContinuousMapClass
-/

instance [Preorder α] [Preorder β] [TopologicalSpace α] [TopologicalSpace β]
    [ContinuousOrderHomClass F α β] : CoeTC F (α →Co β) :=
  ⟨fun f =>
    { toFun := f
      monotone' := OrderHomClass.mono f
      continuous_toFun := map_continuous f }⟩

/-! ### Top homomorphisms -/


namespace ContinuousOrderHom

variable [TopologicalSpace α] [Preorder α] [TopologicalSpace β]

section Preorder

variable [Preorder β] [TopologicalSpace γ] [Preorder γ] [TopologicalSpace δ] [Preorder δ]

#print ContinuousOrderHom.toContinuousMap /-
/-- Reinterpret a `continuous_order_hom` as a `continuous_map`. -/
def toContinuousMap (f : α →Co β) : C(α, β) :=
  { f with }
#align continuous_order_hom.to_continuous_map ContinuousOrderHom.toContinuousMap
-/

instance : ContinuousOrderHomClass (α →Co β) α β
    where
  coe f := f.toFun
  coe_injective' f g h := by obtain ⟨⟨_, _⟩, _⟩ := f; obtain ⟨⟨_, _⟩, _⟩ := g; congr
  map_rel f := f.monotone'
  map_continuous f := f.continuous_toFun

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (α →Co β) fun _ => α → β :=
  FunLike.hasCoeToFun

#print ContinuousOrderHom.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe {f : α →Co β} : f.toFun = (f : α → β) :=
  rfl
#align continuous_order_hom.to_fun_eq_coe ContinuousOrderHom.toFun_eq_coe
-/

#print ContinuousOrderHom.ext /-
@[ext]
theorem ext {f g : α →Co β} (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align continuous_order_hom.ext ContinuousOrderHom.ext
-/

#print ContinuousOrderHom.copy /-
/-- Copy of a `continuous_order_hom` with a new `continuous_map` equal to the old one. Useful to fix
definitional equalities. -/
protected def copy (f : α →Co β) (f' : α → β) (h : f' = f) : α →Co β :=
  ⟨f.toOrderHom.copy f' <| h, h.symm.subst f.continuous_toFun⟩
#align continuous_order_hom.copy ContinuousOrderHom.copy
-/

#print ContinuousOrderHom.coe_copy /-
@[simp]
theorem coe_copy (f : α →Co β) (f' : α → β) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align continuous_order_hom.coe_copy ContinuousOrderHom.coe_copy
-/

#print ContinuousOrderHom.copy_eq /-
theorem copy_eq (f : α →Co β) (f' : α → β) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align continuous_order_hom.copy_eq ContinuousOrderHom.copy_eq
-/

variable (α)

#print ContinuousOrderHom.id /-
/-- `id` as a `continuous_order_hom`. -/
protected def id : α →Co α :=
  ⟨OrderHom.id, continuous_id⟩
#align continuous_order_hom.id ContinuousOrderHom.id
-/

instance : Inhabited (α →Co α) :=
  ⟨ContinuousOrderHom.id _⟩

#print ContinuousOrderHom.coe_id /-
@[simp]
theorem coe_id : ⇑(ContinuousOrderHom.id α) = id :=
  rfl
#align continuous_order_hom.coe_id ContinuousOrderHom.coe_id
-/

variable {α}

#print ContinuousOrderHom.id_apply /-
@[simp]
theorem id_apply (a : α) : ContinuousOrderHom.id α a = a :=
  rfl
#align continuous_order_hom.id_apply ContinuousOrderHom.id_apply
-/

#print ContinuousOrderHom.comp /-
/-- Composition of `continuous_order_hom`s as a `continuous_order_hom`. -/
def comp (f : β →Co γ) (g : α →Co β) : ContinuousOrderHom α γ :=
  ⟨f.toOrderHom.comp g.toOrderHom, f.continuous_toFun.comp g.continuous_toFun⟩
#align continuous_order_hom.comp ContinuousOrderHom.comp
-/

#print ContinuousOrderHom.coe_comp /-
@[simp]
theorem coe_comp (f : β →Co γ) (g : α →Co β) : (f.comp g : α → γ) = f ∘ g :=
  rfl
#align continuous_order_hom.coe_comp ContinuousOrderHom.coe_comp
-/

#print ContinuousOrderHom.comp_apply /-
@[simp]
theorem comp_apply (f : β →Co γ) (g : α →Co β) (a : α) : (f.comp g) a = f (g a) :=
  rfl
#align continuous_order_hom.comp_apply ContinuousOrderHom.comp_apply
-/

#print ContinuousOrderHom.comp_assoc /-
@[simp]
theorem comp_assoc (f : γ →Co δ) (g : β →Co γ) (h : α →Co β) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align continuous_order_hom.comp_assoc ContinuousOrderHom.comp_assoc
-/

#print ContinuousOrderHom.comp_id /-
@[simp]
theorem comp_id (f : α →Co β) : f.comp (ContinuousOrderHom.id α) = f :=
  ext fun a => rfl
#align continuous_order_hom.comp_id ContinuousOrderHom.comp_id
-/

#print ContinuousOrderHom.id_comp /-
@[simp]
theorem id_comp (f : α →Co β) : (ContinuousOrderHom.id β).comp f = f :=
  ext fun a => rfl
#align continuous_order_hom.id_comp ContinuousOrderHom.id_comp
-/

#print ContinuousOrderHom.cancel_right /-
theorem cancel_right {g₁ g₂ : β →Co γ} {f : α →Co β} (hf : Surjective f) :
    g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => ext <| hf.forall.2 <| FunLike.ext_iff.1 h, congr_arg _⟩
#align continuous_order_hom.cancel_right ContinuousOrderHom.cancel_right
-/

#print ContinuousOrderHom.cancel_left /-
theorem cancel_left {g : β →Co γ} {f₁ f₂ : α →Co β} (hg : Injective g) :
    g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => ext fun a => hg <| by rw [← comp_apply, h, comp_apply], congr_arg _⟩
#align continuous_order_hom.cancel_left ContinuousOrderHom.cancel_left
-/

instance : Preorder (α →Co β) :=
  Preorder.lift (coeFn : (α →Co β) → α → β)

end Preorder

instance [PartialOrder β] : PartialOrder (α →Co β) :=
  PartialOrder.lift _ FunLike.coe_injective

end ContinuousOrderHom

