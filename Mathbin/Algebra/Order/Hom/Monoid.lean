/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module algebra.order.hom.monoid
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Pi.Algebra
import Mathbin.Algebra.Hom.Group
import Mathbin.Algebra.Order.Group.Instances
import Mathbin.Algebra.Order.Monoid.WithZero.Defs
import Mathbin.Order.Hom.Basic

/-!
# Ordered monoid and group homomorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines morphisms between (additive) ordered monoids.

## Types of morphisms

* `order_add_monoid_hom`: Ordered additive monoid homomorphisms.
* `order_monoid_hom`: Ordered monoid homomorphisms.
* `order_monoid_with_zero_hom`: Ordered monoid with zero homomorphisms.

## Typeclasses

* `order_add_monoid_hom_class`
* `order_monoid_hom_class`
* `order_monoid_with_zero_hom_class`

## Notation

* `→+o`: Bundled ordered additive monoid homs. Also use for additive groups homs.
* `→*o`: Bundled ordered monoid homs. Also use for groups homs.
* `→*₀o`: Bundled ordered monoid with zero homs. Also use for groups with zero homs.

## Implementation notes

There's a coercion from bundled homs to fun, and the canonical notation is to use the bundled hom as
a function via this coercion.

There is no `order_group_hom` -- the idea is that `order_monoid_hom` is used.
The constructor for `order_monoid_hom` needs a proof of `map_one` as well as `map_mul`; a separate
constructor `order_monoid_hom.mk'` will construct ordered group homs (i.e. ordered monoid homs
between ordered groups) given only a proof that multiplication is preserved,

Implicit `{}` brackets are often used instead of type class `[]` brackets. This is done when the
instances can be inferred because they are implicit arguments to the type `order_monoid_hom`. When
they can be inferred from the type it is faster to use this method than to use type class inference.

## Tags

ordered monoid, ordered group, monoid with zero
-/


open Function

variable {F α β γ δ : Type _}

section AddMonoid

#print OrderAddMonoidHom /-
/-- `α →+o β` is the type of monotone functions `α → β` that preserve the `ordered_add_comm_monoid`
structure.

`order_add_monoid_hom` is also used for ordered group homomorphisms.

When possible, instead of parametrizing results over `(f : α →+o β)`,
you should parametrize over `(F : Type*) [order_add_monoid_hom_class F α β] (f : F)`.

When you extend this structure, make sure to extend `order_add_monoid_hom_class`. -/
structure OrderAddMonoidHom (α β : Type _) [Preorder α] [Preorder β] [AddZeroClass α]
    [AddZeroClass β] extends α →+ β where
  monotone' : Monotone to_fun
#align order_add_monoid_hom OrderAddMonoidHom
-/

infixr:25 " →+o " => OrderAddMonoidHom

section

#print OrderAddMonoidHomClass /-
/-- `order_add_monoid_hom_class F α β` states that `F` is a type of ordered monoid homomorphisms.

You should also extend this typeclass when you extend `order_add_monoid_hom`. -/
class OrderAddMonoidHomClass (F : Type _) (α β : outParam <| Type _) [Preorder α] [Preorder β]
    [AddZeroClass α] [AddZeroClass β] extends AddMonoidHomClass F α β where
  Monotone (f : F) : Monotone f
#align order_add_monoid_hom_class OrderAddMonoidHomClass
-/

end

-- Instances and lemmas are defined below through `@[to_additive]`.
end AddMonoid

section Monoid

variable [Preorder α] [Preorder β] [MulOneClass α] [MulOneClass β]

#print OrderMonoidHom /-
/-- `α →*o β` is the type of functions `α → β` that preserve the `ordered_comm_monoid` structure.

`order_monoid_hom` is also used for ordered group homomorphisms.

When possible, instead of parametrizing results over `(f : α →*o β)`,
you should parametrize over `(F : Type*) [order_monoid_hom_class F α β] (f : F)`.

When you extend this structure, make sure to extend `order_monoid_hom_class`. -/
@[to_additive]
structure OrderMonoidHom (α β : Type _) [Preorder α] [Preorder β] [MulOneClass α]
    [MulOneClass β] extends α →* β where
  monotone' : Monotone to_fun
#align order_monoid_hom OrderMonoidHom
#align order_add_monoid_hom OrderAddMonoidHom
-/

infixr:25 " →*o " => OrderMonoidHom

section

#print OrderMonoidHomClass /-
/-- `order_monoid_hom_class F α β` states that `F` is a type of ordered monoid homomorphisms.

You should also extend this typeclass when you extend `order_monoid_hom`. -/
@[to_additive]
class OrderMonoidHomClass (F : Type _) (α β : outParam <| Type _) [Preorder α] [Preorder β]
    [MulOneClass α] [MulOneClass β] extends MonoidHomClass F α β where
  Monotone (f : F) : Monotone f
#align order_monoid_hom_class OrderMonoidHomClass
#align order_add_monoid_hom_class OrderAddMonoidHomClass
-/

end

#print OrderMonoidHomClass.toOrderHomClass /-
-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) OrderMonoidHomClass.toOrderHomClass [OrderMonoidHomClass F α β] :
    OrderHomClass F α β :=
  { ‹OrderMonoidHomClass F α β› with map_rel := OrderMonoidHomClass.monotone }
#align order_monoid_hom_class.to_order_hom_class OrderMonoidHomClass.toOrderHomClass
#align order_add_monoid_hom_class.to_order_hom_class OrderAddMonoidHomClass.toOrderHomClass
-/

@[to_additive]
instance [OrderMonoidHomClass F α β] : CoeTC F (α →*o β) :=
  ⟨fun f =>
    { toFun := f
      map_one' := map_one f
      map_mul' := map_mul f
      monotone' := OrderMonoidHomClass.monotone _ }⟩

end Monoid

section MonoidWithZero

variable [Preorder α] [Preorder β] [MulZeroOneClass α] [MulZeroOneClass β]

#print OrderMonoidWithZeroHom /-
/-- `order_monoid_with_zero_hom α β` is the type of functions `α → β` that preserve
the `monoid_with_zero` structure.

`order_monoid_with_zero_hom` is also used for group homomorphisms.

When possible, instead of parametrizing results over `(f : α →+ β)`,
you should parametrize over `(F : Type*) [order_monoid_with_zero_hom_class F α β] (f : F)`.

When you extend this structure, make sure to extend `order_monoid_with_zero_hom_class`. -/
structure OrderMonoidWithZeroHom (α β : Type _) [Preorder α] [Preorder β] [MulZeroOneClass α]
    [MulZeroOneClass β] extends α →*₀ β where
  monotone' : Monotone to_fun
#align order_monoid_with_zero_hom OrderMonoidWithZeroHom
-/

infixr:25 " →*₀o " => OrderMonoidWithZeroHom

section

#print OrderMonoidWithZeroHomClass /-
/-- `order_monoid_with_zero_hom_class F α β` states that `F` is a type of
ordered monoid with zero homomorphisms.

You should also extend this typeclass when you extend `order_monoid_with_zero_hom`. -/
class OrderMonoidWithZeroHomClass (F : Type _) (α β : outParam <| Type _) [Preorder α] [Preorder β]
    [MulZeroOneClass α] [MulZeroOneClass β] extends MonoidWithZeroHomClass F α β where
  Monotone (f : F) : Monotone f
#align order_monoid_with_zero_hom_class OrderMonoidWithZeroHomClass
-/

end

#print OrderMonoidWithZeroHomClass.toOrderMonoidHomClass /-
-- See note [lower instance priority]
instance (priority := 100) OrderMonoidWithZeroHomClass.toOrderMonoidHomClass
    [OrderMonoidWithZeroHomClass F α β] : OrderMonoidHomClass F α β :=
  { ‹OrderMonoidWithZeroHomClass F α β› with }
#align order_monoid_with_zero_hom_class.to_order_monoid_hom_class OrderMonoidWithZeroHomClass.toOrderMonoidHomClass
-/

instance [OrderMonoidWithZeroHomClass F α β] : CoeTC F (α →*₀o β) :=
  ⟨fun f =>
    { toFun := f
      map_one' := map_one f
      map_zero' := map_zero f
      map_mul' := map_mul f
      monotone' := OrderMonoidWithZeroHomClass.monotone _ }⟩

end MonoidWithZero

section OrderedAddCommMonoid

variable [OrderedAddCommMonoid α] [OrderedAddCommMonoid β] [OrderAddMonoidHomClass F α β] (f : F)
  {a : α}

#print map_nonneg /-
theorem map_nonneg (ha : 0 ≤ a) : 0 ≤ f a := by rw [← map_zero f]; exact OrderHomClass.mono _ ha
#align map_nonneg map_nonneg
-/

#print map_nonpos /-
theorem map_nonpos (ha : a ≤ 0) : f a ≤ 0 := by rw [← map_zero f]; exact OrderHomClass.mono _ ha
#align map_nonpos map_nonpos
-/

end OrderedAddCommMonoid

section OrderedAddCommGroup

variable [OrderedAddCommGroup α] [OrderedAddCommMonoid β] [AddMonoidHomClass F α β] (f : F)

#print monotone_iff_map_nonneg /-
theorem monotone_iff_map_nonneg : Monotone (f : α → β) ↔ ∀ a, 0 ≤ a → 0 ≤ f a :=
  ⟨fun h a => by rw [← map_zero f]; apply h, fun h a b hl => by
    rw [← sub_add_cancel b a, map_add f]; exact le_add_of_nonneg_left (h _ <| sub_nonneg.2 hl)⟩
#align monotone_iff_map_nonneg monotone_iff_map_nonneg
-/

#print antitone_iff_map_nonpos /-
theorem antitone_iff_map_nonpos : Antitone (f : α → β) ↔ ∀ a, 0 ≤ a → f a ≤ 0 :=
  monotone_toDual_comp_iff.symm.trans <| monotone_iff_map_nonneg _
#align antitone_iff_map_nonpos antitone_iff_map_nonpos
-/

#print monotone_iff_map_nonpos /-
theorem monotone_iff_map_nonpos : Monotone (f : α → β) ↔ ∀ a ≤ 0, f a ≤ 0 :=
  antitone_comp_ofDual_iff.symm.trans <| antitone_iff_map_nonpos _
#align monotone_iff_map_nonpos monotone_iff_map_nonpos
-/

#print antitone_iff_map_nonneg /-
theorem antitone_iff_map_nonneg : Antitone (f : α → β) ↔ ∀ a ≤ 0, 0 ≤ f a :=
  monotone_comp_ofDual_iff.symm.trans <| monotone_iff_map_nonneg _
#align antitone_iff_map_nonneg antitone_iff_map_nonneg
-/

variable [CovariantClass β β (· + ·) (· < ·)]

#print strictMono_iff_map_pos /-
theorem strictMono_iff_map_pos : StrictMono (f : α → β) ↔ ∀ a, 0 < a → 0 < f a :=
  ⟨fun h a => by rw [← map_zero f]; apply h, fun h a b hl => by
    rw [← sub_add_cancel b a, map_add f]; exact lt_add_of_pos_left _ (h _ <| sub_pos.2 hl)⟩
#align strict_mono_iff_map_pos strictMono_iff_map_pos
-/

#print strictAnti_iff_map_neg /-
theorem strictAnti_iff_map_neg : StrictAnti (f : α → β) ↔ ∀ a, 0 < a → f a < 0 :=
  strictMono_toDual_comp_iff.symm.trans <| strictMono_iff_map_pos _
#align strict_anti_iff_map_neg strictAnti_iff_map_neg
-/

#print strictMono_iff_map_neg /-
theorem strictMono_iff_map_neg : StrictMono (f : α → β) ↔ ∀ a < 0, f a < 0 :=
  strictAnti_comp_ofDual_iff.symm.trans <| strictAnti_iff_map_neg _
#align strict_mono_iff_map_neg strictMono_iff_map_neg
-/

#print strictAnti_iff_map_pos /-
theorem strictAnti_iff_map_pos : StrictAnti (f : α → β) ↔ ∀ a < 0, 0 < f a :=
  strictMono_comp_ofDual_iff.symm.trans <| strictMono_iff_map_pos _
#align strict_anti_iff_map_pos strictAnti_iff_map_pos
-/

end OrderedAddCommGroup

namespace OrderMonoidHom

section Preorder

variable [Preorder α] [Preorder β] [Preorder γ] [Preorder δ] [MulOneClass α] [MulOneClass β]
  [MulOneClass γ] [MulOneClass δ] {f g : α →*o β}

@[to_additive]
instance : OrderMonoidHomClass (α →*o β) α β
    where
  coe f := f.toFun
  coe_injective' f g h := by obtain ⟨⟨_, _⟩, _⟩ := f; obtain ⟨⟨_, _⟩, _⟩ := g; congr
  map_mul f := f.map_mul'
  map_one f := f.map_one'
  Monotone f := f.monotone'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
@[to_additive
      "Helper instance for when there's too many metavariables to apply\n`fun_like.has_coe_to_fun` directly."]
instance : CoeFun (α →*o β) fun _ => α → β :=
  FunLike.hasCoeToFun

#print OrderMonoidHom.ext /-
-- Other lemmas should be accessed through the `fun_like` API
@[ext, to_additive]
theorem ext (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align order_monoid_hom.ext OrderMonoidHom.ext
#align order_add_monoid_hom.ext OrderAddMonoidHom.ext
-/

#print OrderMonoidHom.toFun_eq_coe /-
@[to_additive]
theorem toFun_eq_coe (f : α →*o β) : f.toFun = (f : α → β) :=
  rfl
#align order_monoid_hom.to_fun_eq_coe OrderMonoidHom.toFun_eq_coe
#align order_add_monoid_hom.to_fun_eq_coe OrderAddMonoidHom.toFun_eq_coe
-/

#print OrderMonoidHom.coe_mk /-
@[simp, to_additive]
theorem coe_mk (f : α →* β) (h) : (OrderMonoidHom.mk f h : α → β) = f :=
  rfl
#align order_monoid_hom.coe_mk OrderMonoidHom.coe_mk
#align order_add_monoid_hom.coe_mk OrderAddMonoidHom.coe_mk
-/

#print OrderMonoidHom.mk_coe /-
@[simp, to_additive]
theorem mk_coe (f : α →*o β) (h) : OrderMonoidHom.mk (f : α →* β) h = f := by ext; rfl
#align order_monoid_hom.mk_coe OrderMonoidHom.mk_coe
#align order_add_monoid_hom.mk_coe OrderAddMonoidHom.mk_coe
-/

#print OrderMonoidHom.toOrderHom /-
/-- Reinterpret an ordered monoid homomorphism as an order homomorphism. -/
@[to_additive "Reinterpret an ordered additive monoid homomorphism as an order homomorphism."]
def toOrderHom (f : α →*o β) : α →o β :=
  { f with }
#align order_monoid_hom.to_order_hom OrderMonoidHom.toOrderHom
#align order_add_monoid_hom.to_order_hom OrderAddMonoidHom.toOrderHom
-/

#print OrderMonoidHom.coe_monoidHom /-
@[simp, to_additive]
theorem coe_monoidHom (f : α →*o β) : ((f : α →* β) : α → β) = f :=
  rfl
#align order_monoid_hom.coe_monoid_hom OrderMonoidHom.coe_monoidHom
#align order_add_monoid_hom.coe_add_monoid_hom OrderAddMonoidHom.coe_addMonoidHom
-/

#print OrderMonoidHom.coe_orderHom /-
@[simp, to_additive]
theorem coe_orderHom (f : α →*o β) : ((f : α →o β) : α → β) = f :=
  rfl
#align order_monoid_hom.coe_order_hom OrderMonoidHom.coe_orderHom
#align order_add_monoid_hom.coe_order_hom OrderAddMonoidHom.coe_orderHom
-/

#print OrderMonoidHom.toMonoidHom_injective /-
@[to_additive]
theorem toMonoidHom_injective : Injective (toMonoidHom : _ → α →* β) := fun f g h =>
  ext <| by convert FunLike.ext_iff.1 h
#align order_monoid_hom.to_monoid_hom_injective OrderMonoidHom.toMonoidHom_injective
#align order_add_monoid_hom.to_add_monoid_hom_injective OrderAddMonoidHom.toAddMonoidHom_injective
-/

#print OrderMonoidHom.toOrderHom_injective /-
@[to_additive]
theorem toOrderHom_injective : Injective (toOrderHom : _ → α →o β) := fun f g h =>
  ext <| by convert FunLike.ext_iff.1 h
#align order_monoid_hom.to_order_hom_injective OrderMonoidHom.toOrderHom_injective
#align order_add_monoid_hom.to_order_hom_injective OrderAddMonoidHom.toOrderHom_injective
-/

#print OrderMonoidHom.copy /-
/-- Copy of an `order_monoid_hom` with a new `to_fun` equal to the old one. Useful to fix
definitional equalities. -/
@[to_additive
      "Copy of an `order_monoid_hom` with a new `to_fun` equal to the old one. Useful to fix\ndefinitional equalities."]
protected def copy (f : α →*o β) (f' : α → β) (h : f' = f) : α →*o β :=
  { f.toMonoidHom.copy f' h with
    toFun := f'
    monotone' := h.symm.subst f.monotone' }
#align order_monoid_hom.copy OrderMonoidHom.copy
#align order_add_monoid_hom.copy OrderAddMonoidHom.copy
-/

#print OrderMonoidHom.coe_copy /-
@[simp, to_additive]
theorem coe_copy (f : α →*o β) (f' : α → β) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align order_monoid_hom.coe_copy OrderMonoidHom.coe_copy
#align order_add_monoid_hom.coe_copy OrderAddMonoidHom.coe_copy
-/

#print OrderMonoidHom.copy_eq /-
@[to_additive]
theorem copy_eq (f : α →*o β) (f' : α → β) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align order_monoid_hom.copy_eq OrderMonoidHom.copy_eq
#align order_add_monoid_hom.copy_eq OrderAddMonoidHom.copy_eq
-/

variable (α)

#print OrderMonoidHom.id /-
/-- The identity map as an ordered monoid homomorphism. -/
@[to_additive "The identity map as an ordered additive monoid homomorphism."]
protected def id : α →*o α :=
  { MonoidHom.id α, OrderHom.id with }
#align order_monoid_hom.id OrderMonoidHom.id
#align order_add_monoid_hom.id OrderAddMonoidHom.id
-/

#print OrderMonoidHom.coe_id /-
@[simp, to_additive]
theorem coe_id : ⇑(OrderMonoidHom.id α) = id :=
  rfl
#align order_monoid_hom.coe_id OrderMonoidHom.coe_id
#align order_add_monoid_hom.coe_id OrderAddMonoidHom.coe_id
-/

@[to_additive]
instance : Inhabited (α →*o α) :=
  ⟨OrderMonoidHom.id α⟩

variable {α}

#print OrderMonoidHom.comp /-
/-- Composition of `order_monoid_hom`s as an `order_monoid_hom`. -/
@[to_additive "Composition of `order_add_monoid_hom`s as an `order_add_monoid_hom`"]
def comp (f : β →*o γ) (g : α →*o β) : α →*o γ :=
  { f.toMonoidHom.comp (g : α →* β), f.toOrderHom.comp (g : α →o β) with }
#align order_monoid_hom.comp OrderMonoidHom.comp
#align order_add_monoid_hom.comp OrderAddMonoidHom.comp
-/

#print OrderMonoidHom.coe_comp /-
@[simp, to_additive]
theorem coe_comp (f : β →*o γ) (g : α →*o β) : (f.comp g : α → γ) = f ∘ g :=
  rfl
#align order_monoid_hom.coe_comp OrderMonoidHom.coe_comp
#align order_add_monoid_hom.coe_comp OrderAddMonoidHom.coe_comp
-/

#print OrderMonoidHom.comp_apply /-
@[simp, to_additive]
theorem comp_apply (f : β →*o γ) (g : α →*o β) (a : α) : (f.comp g) a = f (g a) :=
  rfl
#align order_monoid_hom.comp_apply OrderMonoidHom.comp_apply
#align order_add_monoid_hom.comp_apply OrderAddMonoidHom.comp_apply
-/

#print OrderMonoidHom.coe_comp_monoidHom /-
@[simp, to_additive]
theorem coe_comp_monoidHom (f : β →*o γ) (g : α →*o β) :
    (f.comp g : α →* γ) = (f : β →* γ).comp g :=
  rfl
#align order_monoid_hom.coe_comp_monoid_hom OrderMonoidHom.coe_comp_monoidHom
#align order_add_monoid_hom.coe_comp_add_monoid_hom OrderAddMonoidHom.coe_comp_addMonoidHom
-/

#print OrderMonoidHom.coe_comp_orderHom /-
@[simp, to_additive]
theorem coe_comp_orderHom (f : β →*o γ) (g : α →*o β) : (f.comp g : α →o γ) = (f : β →o γ).comp g :=
  rfl
#align order_monoid_hom.coe_comp_order_hom OrderMonoidHom.coe_comp_orderHom
#align order_add_monoid_hom.coe_comp_order_hom OrderAddMonoidHom.coe_comp_orderHom
-/

#print OrderMonoidHom.comp_assoc /-
@[simp, to_additive]
theorem comp_assoc (f : γ →*o δ) (g : β →*o γ) (h : α →*o β) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align order_monoid_hom.comp_assoc OrderMonoidHom.comp_assoc
#align order_add_monoid_hom.comp_assoc OrderAddMonoidHom.comp_assoc
-/

#print OrderMonoidHom.comp_id /-
@[simp, to_additive]
theorem comp_id (f : α →*o β) : f.comp (OrderMonoidHom.id α) = f :=
  ext fun a => rfl
#align order_monoid_hom.comp_id OrderMonoidHom.comp_id
#align order_add_monoid_hom.comp_id OrderAddMonoidHom.comp_id
-/

#print OrderMonoidHom.id_comp /-
@[simp, to_additive]
theorem id_comp (f : α →*o β) : (OrderMonoidHom.id β).comp f = f :=
  ext fun a => rfl
#align order_monoid_hom.id_comp OrderMonoidHom.id_comp
#align order_add_monoid_hom.id_comp OrderAddMonoidHom.id_comp
-/

#print OrderMonoidHom.cancel_right /-
@[to_additive]
theorem cancel_right {g₁ g₂ : β →*o γ} {f : α →*o β} (hf : Function.Surjective f) :
    g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => ext <| hf.forall.2 <| FunLike.ext_iff.1 h, congr_arg _⟩
#align order_monoid_hom.cancel_right OrderMonoidHom.cancel_right
#align order_add_monoid_hom.cancel_right OrderAddMonoidHom.cancel_right
-/

#print OrderMonoidHom.cancel_left /-
@[to_additive]
theorem cancel_left {g : β →*o γ} {f₁ f₂ : α →*o β} (hg : Function.Injective g) :
    g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => ext fun a => hg <| by rw [← comp_apply, h, comp_apply], congr_arg _⟩
#align order_monoid_hom.cancel_left OrderMonoidHom.cancel_left
#align order_add_monoid_hom.cancel_left OrderAddMonoidHom.cancel_left
-/

/-- `1` is the homomorphism sending all elements to `1`. -/
@[to_additive "`1` is the homomorphism sending all elements to `1`."]
instance : One (α →*o β) :=
  ⟨{ (1 : α →* β) with monotone' := monotone_const }⟩

#print OrderMonoidHom.coe_one /-
@[simp, to_additive]
theorem coe_one : ⇑(1 : α →*o β) = 1 :=
  rfl
#align order_monoid_hom.coe_one OrderMonoidHom.coe_one
#align order_add_monoid_hom.coe_zero OrderAddMonoidHom.coe_zero
-/

#print OrderMonoidHom.one_apply /-
@[simp, to_additive]
theorem one_apply (a : α) : (1 : α →*o β) a = 1 :=
  rfl
#align order_monoid_hom.one_apply OrderMonoidHom.one_apply
#align order_add_monoid_hom.zero_apply OrderAddMonoidHom.zero_apply
-/

#print OrderMonoidHom.one_comp /-
@[simp, to_additive]
theorem one_comp (f : α →*o β) : (1 : β →*o γ).comp f = 1 :=
  rfl
#align order_monoid_hom.one_comp OrderMonoidHom.one_comp
#align order_add_monoid_hom.zero_comp OrderAddMonoidHom.zero_comp
-/

#print OrderMonoidHom.comp_one /-
@[simp, to_additive]
theorem comp_one (f : β →*o γ) : f.comp (1 : α →*o β) = 1 := by ext; exact map_one f
#align order_monoid_hom.comp_one OrderMonoidHom.comp_one
#align order_add_monoid_hom.comp_zero OrderAddMonoidHom.comp_zero
-/

end Preorder

section Mul

variable [OrderedCommMonoid α] [OrderedCommMonoid β] [OrderedCommMonoid γ]

/-- For two ordered monoid morphisms `f` and `g`, their product is the ordered monoid morphism
sending `a` to `f a * g a`. -/
@[to_additive
      "For two ordered additive monoid morphisms `f` and `g`, their product is the ordered\nadditive monoid morphism sending `a` to `f a + g a`."]
instance : Mul (α →*o β) :=
  ⟨fun f g => { (f * g : α →* β) with monotone' := f.monotone'.mul' g.monotone' }⟩

#print OrderMonoidHom.coe_mul /-
@[simp, to_additive]
theorem coe_mul (f g : α →*o β) : ⇑(f * g) = f * g :=
  rfl
#align order_monoid_hom.coe_mul OrderMonoidHom.coe_mul
#align order_add_monoid_hom.coe_add OrderAddMonoidHom.coe_add
-/

#print OrderMonoidHom.mul_apply /-
@[simp, to_additive]
theorem mul_apply (f g : α →*o β) (a : α) : (f * g) a = f a * g a :=
  rfl
#align order_monoid_hom.mul_apply OrderMonoidHom.mul_apply
#align order_add_monoid_hom.add_apply OrderAddMonoidHom.add_apply
-/

#print OrderMonoidHom.mul_comp /-
@[to_additive]
theorem mul_comp (g₁ g₂ : β →*o γ) (f : α →*o β) : (g₁ * g₂).comp f = g₁.comp f * g₂.comp f :=
  rfl
#align order_monoid_hom.mul_comp OrderMonoidHom.mul_comp
#align order_add_monoid_hom.add_comp OrderAddMonoidHom.add_comp
-/

#print OrderMonoidHom.comp_mul /-
@[to_additive]
theorem comp_mul (g : β →*o γ) (f₁ f₂ : α →*o β) : g.comp (f₁ * f₂) = g.comp f₁ * g.comp f₂ := by
  ext; exact map_mul g _ _
#align order_monoid_hom.comp_mul OrderMonoidHom.comp_mul
#align order_add_monoid_hom.comp_add OrderAddMonoidHom.comp_add
-/

end Mul

section OrderedCommMonoid

variable {hα : OrderedCommMonoid α} {hβ : OrderedCommMonoid β}

#print OrderMonoidHom.toMonoidHom_eq_coe /-
@[simp, to_additive]
theorem toMonoidHom_eq_coe (f : α →*o β) : f.toMonoidHom = f := by ext; rfl
#align order_monoid_hom.to_monoid_hom_eq_coe OrderMonoidHom.toMonoidHom_eq_coe
#align order_add_monoid_hom.to_add_monoid_hom_eq_coe OrderAddMonoidHom.toAddMonoidHom_eq_coe
-/

#print OrderMonoidHom.toOrderHom_eq_coe /-
@[simp, to_additive]
theorem toOrderHom_eq_coe (f : α →*o β) : f.toOrderHom = f :=
  rfl
#align order_monoid_hom.to_order_hom_eq_coe OrderMonoidHom.toOrderHom_eq_coe
#align order_add_monoid_hom.to_order_hom_eq_coe OrderAddMonoidHom.toOrderHom_eq_coe
-/

end OrderedCommMonoid

section OrderedCommGroup

variable {hα : OrderedCommGroup α} {hβ : OrderedCommGroup β}

#print OrderMonoidHom.mk' /-
/-- Makes an ordered group homomorphism from a proof that the map preserves multiplication. -/
@[to_additive
      "Makes an ordered additive group homomorphism from a proof that the map preserves\naddition.",
  simps (config := { fullyApplied := false })]
def mk' (f : α → β) (hf : Monotone f) (map_mul : ∀ a b : α, f (a * b) = f a * f b) : α →*o β :=
  { MonoidHom.mk' f map_mul with monotone' := hf }
#align order_monoid_hom.mk' OrderMonoidHom.mk'
#align order_add_monoid_hom.mk' OrderAddMonoidHom.mk'
-/

end OrderedCommGroup

end OrderMonoidHom

namespace OrderMonoidWithZeroHom

section Preorder

variable [Preorder α] [Preorder β] [Preorder γ] [Preorder δ] [MulZeroOneClass α] [MulZeroOneClass β]
  [MulZeroOneClass γ] [MulZeroOneClass δ] {f g : α →*₀o β}

instance : OrderMonoidWithZeroHomClass (α →*₀o β) α β
    where
  coe f := f.toFun
  coe_injective' f g h := by obtain ⟨⟨_, _⟩, _⟩ := f; obtain ⟨⟨_, _⟩, _⟩ := g; congr
  map_mul f := f.map_mul'
  map_one f := f.map_one'
  map_zero f := f.map_zero'
  Monotone f := f.monotone'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (α →*₀o β) fun _ => α → β :=
  FunLike.hasCoeToFun

#print OrderMonoidWithZeroHom.ext /-
-- Other lemmas should be accessed through the `fun_like` API
@[ext]
theorem ext (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align order_monoid_with_zero_hom.ext OrderMonoidWithZeroHom.ext
-/

#print OrderMonoidWithZeroHom.toFun_eq_coe /-
theorem toFun_eq_coe (f : α →*₀o β) : f.toFun = (f : α → β) :=
  rfl
#align order_monoid_with_zero_hom.to_fun_eq_coe OrderMonoidWithZeroHom.toFun_eq_coe
-/

#print OrderMonoidWithZeroHom.coe_mk /-
@[simp]
theorem coe_mk (f : α →*₀ β) (h) : (OrderMonoidWithZeroHom.mk f h : α → β) = f :=
  rfl
#align order_monoid_with_zero_hom.coe_mk OrderMonoidWithZeroHom.coe_mk
-/

#print OrderMonoidWithZeroHom.mk_coe /-
@[simp]
theorem mk_coe (f : α →*₀o β) (h) : OrderMonoidWithZeroHom.mk (f : α →*₀ β) h = f := by ext; rfl
#align order_monoid_with_zero_hom.mk_coe OrderMonoidWithZeroHom.mk_coe
-/

#print OrderMonoidWithZeroHom.toOrderMonoidHom /-
/-- Reinterpret an ordered monoid with zero homomorphism as an order monoid homomorphism. -/
def toOrderMonoidHom (f : α →*₀o β) : α →*o β :=
  { f with }
#align order_monoid_with_zero_hom.to_order_monoid_hom OrderMonoidWithZeroHom.toOrderMonoidHom
-/

#print OrderMonoidWithZeroHom.coe_monoidWithZeroHom /-
@[simp]
theorem coe_monoidWithZeroHom (f : α →*₀o β) : ⇑(f : α →*₀ β) = f :=
  rfl
#align order_monoid_with_zero_hom.coe_monoid_with_zero_hom OrderMonoidWithZeroHom.coe_monoidWithZeroHom
-/

#print OrderMonoidWithZeroHom.coe_orderMonoidHom /-
@[simp]
theorem coe_orderMonoidHom (f : α →*₀o β) : ⇑(f : α →*o β) = f :=
  rfl
#align order_monoid_with_zero_hom.coe_order_monoid_hom OrderMonoidWithZeroHom.coe_orderMonoidHom
-/

#print OrderMonoidWithZeroHom.toOrderMonoidHom_injective /-
theorem toOrderMonoidHom_injective : Injective (toOrderMonoidHom : _ → α →*o β) := fun f g h =>
  ext <| by convert FunLike.ext_iff.1 h
#align order_monoid_with_zero_hom.to_order_monoid_hom_injective OrderMonoidWithZeroHom.toOrderMonoidHom_injective
-/

#print OrderMonoidWithZeroHom.toMonoidWithZeroHom_injective /-
theorem toMonoidWithZeroHom_injective : Injective (toMonoidWithZeroHom : _ → α →*₀ β) :=
  fun f g h => ext <| by convert FunLike.ext_iff.1 h
#align order_monoid_with_zero_hom.to_monoid_with_zero_hom_injective OrderMonoidWithZeroHom.toMonoidWithZeroHom_injective
-/

#print OrderMonoidWithZeroHom.copy /-
/-- Copy of an `order_monoid_with_zero_hom` with a new `to_fun` equal to the old one. Useful to fix
definitional equalities. -/
protected def copy (f : α →*₀o β) (f' : α → β) (h : f' = f) : α →*o β :=
  { f.toOrderMonoidHom.copy f' h, f.toMonoidWithZeroHom.copy f' h with toFun := f' }
#align order_monoid_with_zero_hom.copy OrderMonoidWithZeroHom.copy
-/

#print OrderMonoidWithZeroHom.coe_copy /-
@[simp]
theorem coe_copy (f : α →*₀o β) (f' : α → β) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align order_monoid_with_zero_hom.coe_copy OrderMonoidWithZeroHom.coe_copy
-/

#print OrderMonoidWithZeroHom.copy_eq /-
theorem copy_eq (f : α →*₀o β) (f' : α → β) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align order_monoid_with_zero_hom.copy_eq OrderMonoidWithZeroHom.copy_eq
-/

variable (α)

#print OrderMonoidWithZeroHom.id /-
/-- The identity map as an ordered monoid with zero homomorphism. -/
protected def id : α →*₀o α :=
  { MonoidWithZeroHom.id α, OrderHom.id with }
#align order_monoid_with_zero_hom.id OrderMonoidWithZeroHom.id
-/

#print OrderMonoidWithZeroHom.coe_id /-
@[simp]
theorem coe_id : ⇑(OrderMonoidWithZeroHom.id α) = id :=
  rfl
#align order_monoid_with_zero_hom.coe_id OrderMonoidWithZeroHom.coe_id
-/

instance : Inhabited (α →*₀o α) :=
  ⟨OrderMonoidWithZeroHom.id α⟩

variable {α}

#print OrderMonoidWithZeroHom.comp /-
/-- Composition of `order_monoid_with_zero_hom`s as an `order_monoid_with_zero_hom`. -/
def comp (f : β →*₀o γ) (g : α →*₀o β) : α →*₀o γ :=
  { f.toMonoidWithZeroHom.comp (g : α →*₀ β), f.toOrderMonoidHom.comp (g : α →*o β) with }
#align order_monoid_with_zero_hom.comp OrderMonoidWithZeroHom.comp
-/

#print OrderMonoidWithZeroHom.coe_comp /-
@[simp]
theorem coe_comp (f : β →*₀o γ) (g : α →*₀o β) : (f.comp g : α → γ) = f ∘ g :=
  rfl
#align order_monoid_with_zero_hom.coe_comp OrderMonoidWithZeroHom.coe_comp
-/

#print OrderMonoidWithZeroHom.comp_apply /-
@[simp]
theorem comp_apply (f : β →*₀o γ) (g : α →*₀o β) (a : α) : (f.comp g) a = f (g a) :=
  rfl
#align order_monoid_with_zero_hom.comp_apply OrderMonoidWithZeroHom.comp_apply
-/

#print OrderMonoidWithZeroHom.coe_comp_monoidWithZeroHom /-
@[simp]
theorem coe_comp_monoidWithZeroHom (f : β →*₀o γ) (g : α →*₀o β) :
    (f.comp g : α →*₀ γ) = (f : β →*₀ γ).comp g :=
  rfl
#align order_monoid_with_zero_hom.coe_comp_monoid_with_zero_hom OrderMonoidWithZeroHom.coe_comp_monoidWithZeroHom
-/

#print OrderMonoidWithZeroHom.coe_comp_orderMonoidHom /-
@[simp]
theorem coe_comp_orderMonoidHom (f : β →*₀o γ) (g : α →*₀o β) :
    (f.comp g : α →*o γ) = (f : β →*o γ).comp g :=
  rfl
#align order_monoid_with_zero_hom.coe_comp_order_monoid_hom OrderMonoidWithZeroHom.coe_comp_orderMonoidHom
-/

#print OrderMonoidWithZeroHom.comp_assoc /-
@[simp]
theorem comp_assoc (f : γ →*₀o δ) (g : β →*₀o γ) (h : α →*₀o β) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align order_monoid_with_zero_hom.comp_assoc OrderMonoidWithZeroHom.comp_assoc
-/

#print OrderMonoidWithZeroHom.comp_id /-
@[simp]
theorem comp_id (f : α →*₀o β) : f.comp (OrderMonoidWithZeroHom.id α) = f :=
  ext fun a => rfl
#align order_monoid_with_zero_hom.comp_id OrderMonoidWithZeroHom.comp_id
-/

#print OrderMonoidWithZeroHom.id_comp /-
@[simp]
theorem id_comp (f : α →*₀o β) : (OrderMonoidWithZeroHom.id β).comp f = f :=
  ext fun a => rfl
#align order_monoid_with_zero_hom.id_comp OrderMonoidWithZeroHom.id_comp
-/

#print OrderMonoidWithZeroHom.cancel_right /-
theorem cancel_right {g₁ g₂ : β →*₀o γ} {f : α →*₀o β} (hf : Function.Surjective f) :
    g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => ext <| hf.forall.2 <| FunLike.ext_iff.1 h, congr_arg _⟩
#align order_monoid_with_zero_hom.cancel_right OrderMonoidWithZeroHom.cancel_right
-/

#print OrderMonoidWithZeroHom.cancel_left /-
theorem cancel_left {g : β →*₀o γ} {f₁ f₂ : α →*₀o β} (hg : Function.Injective g) :
    g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => ext fun a => hg <| by rw [← comp_apply, h, comp_apply], congr_arg _⟩
#align order_monoid_with_zero_hom.cancel_left OrderMonoidWithZeroHom.cancel_left
-/

end Preorder

section Mul

variable [LinearOrderedCommMonoidWithZero α] [LinearOrderedCommMonoidWithZero β]
  [LinearOrderedCommMonoidWithZero γ]

/-- For two ordered monoid morphisms `f` and `g`, their product is the ordered monoid morphism
sending `a` to `f a * g a`. -/
instance : Mul (α →*₀o β) :=
  ⟨fun f g => { (f * g : α →*₀ β) with monotone' := f.monotone'.mul' g.monotone' }⟩

#print OrderMonoidWithZeroHom.coe_mul /-
@[simp]
theorem coe_mul (f g : α →*₀o β) : ⇑(f * g) = f * g :=
  rfl
#align order_monoid_with_zero_hom.coe_mul OrderMonoidWithZeroHom.coe_mul
-/

#print OrderMonoidWithZeroHom.mul_apply /-
@[simp]
theorem mul_apply (f g : α →*₀o β) (a : α) : (f * g) a = f a * g a :=
  rfl
#align order_monoid_with_zero_hom.mul_apply OrderMonoidWithZeroHom.mul_apply
-/

#print OrderMonoidWithZeroHom.mul_comp /-
theorem mul_comp (g₁ g₂ : β →*₀o γ) (f : α →*₀o β) : (g₁ * g₂).comp f = g₁.comp f * g₂.comp f :=
  rfl
#align order_monoid_with_zero_hom.mul_comp OrderMonoidWithZeroHom.mul_comp
-/

#print OrderMonoidWithZeroHom.comp_mul /-
theorem comp_mul (g : β →*₀o γ) (f₁ f₂ : α →*₀o β) : g.comp (f₁ * f₂) = g.comp f₁ * g.comp f₂ :=
  ext fun _ => map_mul g _ _
#align order_monoid_with_zero_hom.comp_mul OrderMonoidWithZeroHom.comp_mul
-/

end Mul

section LinearOrderedCommMonoidWithZero

variable {hα : Preorder α} {hα' : MulZeroOneClass α} {hβ : Preorder β} {hβ' : MulZeroOneClass β}

#print OrderMonoidWithZeroHom.toMonoidWithZeroHom_eq_coe /-
@[simp]
theorem toMonoidWithZeroHom_eq_coe (f : α →*₀o β) : f.toMonoidWithZeroHom = f := by ext; rfl
#align order_monoid_with_zero_hom.to_monoid_with_zero_hom_eq_coe OrderMonoidWithZeroHom.toMonoidWithZeroHom_eq_coe
-/

#print OrderMonoidWithZeroHom.toOrderMonoidHom_eq_coe /-
@[simp]
theorem toOrderMonoidHom_eq_coe (f : α →*₀o β) : f.toOrderMonoidHom = f :=
  rfl
#align order_monoid_with_zero_hom.to_order_monoid_hom_eq_coe OrderMonoidWithZeroHom.toOrderMonoidHom_eq_coe
-/

end LinearOrderedCommMonoidWithZero

end OrderMonoidWithZeroHom

