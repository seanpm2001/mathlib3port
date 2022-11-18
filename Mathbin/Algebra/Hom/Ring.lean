/-
Copyright (c) 2019 Amelia Livingston. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Amelia Livingston, Jireh Loreaux
-/
import Mathbin.Algebra.GroupWithZero.InjSurj
import Mathbin.Algebra.Ring.Basic
import Mathbin.Algebra.Divisibility.Basic
import Mathbin.Data.Pi.Algebra
import Mathbin.Algebra.Hom.Units
import Mathbin.Data.Set.Basic

/-!
# Homomorphisms of semirings and rings

This file defines bundled homomorphisms of (non-unital) semirings and rings. As with monoid and
groups, we use the same structure `ring_hom a β`, a.k.a. `α →+* β`, for both types of homomorphisms.

The unbundled homomorphisms are defined in `deprecated.ring`. They are deprecated and the plan is to
slowly remove them from mathlib.

## Main definitions

* `non_unital_ring_hom`: Non-unital (semi)ring homomorphisms. Additive monoid homomorphism which
  preserve multiplication.
* `ring_hom`: (Semi)ring homomorphisms. Monoid homomorphisms which are also additive monoid
  homomorphism.

## Notations

* `→ₙ+*`: Non-unital (semi)ring homs
* `→+*`: (Semi)ring homs

## Implementation notes

* There's a coercion from bundled homs to fun, and the canonical notation is to
  use the bundled hom as a function via this coercion.

* There is no `semiring_hom` -- the idea is that `ring_hom` is used.
  The constructor for a `ring_hom` between semirings needs a proof of `map_zero`,
  `map_one` and `map_add` as well as `map_mul`; a separate constructor
  `ring_hom.mk'` will construct ring homs between rings from monoid homs given
  only a proof that addition is preserved.

## Tags

`ring_hom`, `semiring_hom`
-/


open Function

variable {F α β γ : Type _}

/-- Bundled non-unital semiring homomorphisms `α →ₙ+* β`; use this for bundled non-unital ring
homomorphisms too.

When possible, instead of parametrizing results over `(f : α →ₙ+* β)`,
you should parametrize over `(F : Type*) [non_unital_ring_hom_class F α β] (f : F)`.

When you extend this structure, make sure to extend `non_unital_ring_hom_class`. -/
structure NonUnitalRingHom (α β : Type _) [NonUnitalNonAssocSemiring α] [NonUnitalNonAssocSemiring β] extends α →ₙ* β,
  α →+ β
#align non_unital_ring_hom NonUnitalRingHom

-- mathport name: «expr →ₙ+* »
infixr:25 " →ₙ+* " => NonUnitalRingHom

/-- Reinterpret a non-unital ring homomorphism `f : α →ₙ+* β` as a semigroup
homomorphism `α →ₙ* β`. The `simp`-normal form is `(f : α →ₙ* β)`. -/
add_decl_doc NonUnitalRingHom.toMulHom

/-- Reinterpret a non-unital ring homomorphism `f : α →ₙ+* β` as an additive
monoid homomorphism `α →+ β`. The `simp`-normal form is `(f : α →+ β)`. -/
add_decl_doc NonUnitalRingHom.toAddMonoidHom

section NonUnitalRingHomClass

/-- `non_unital_ring_hom_class F α β` states that `F` is a type of non-unital (semi)ring
homomorphisms. You should extend this class when you extend `non_unital_ring_hom`. -/
class NonUnitalRingHomClass (F : Type _) (α β : outParam (Type _)) [NonUnitalNonAssocSemiring α]
  [NonUnitalNonAssocSemiring β] extends MulHomClass F α β, AddMonoidHomClass F α β
#align non_unital_ring_hom_class NonUnitalRingHomClass

variable [NonUnitalNonAssocSemiring α] [NonUnitalNonAssocSemiring β] [NonUnitalRingHomClass F α β]

instance : CoeTC F (α →ₙ+* β) :=
  ⟨fun f => { toFun := f, map_zero' := map_zero f, map_mul' := map_mul f, map_add' := map_add f }⟩

end NonUnitalRingHomClass

namespace NonUnitalRingHom

section coe

/-!
Throughout this section, some `semiring` arguments are specified with `{}` instead of `[]`.
See note [implicit instance arguments].
-/


variable {rα : NonUnitalNonAssocSemiring α} {rβ : NonUnitalNonAssocSemiring β}

include rα rβ

instance : NonUnitalRingHomClass (α →ₙ+* β) α β where
  coe := NonUnitalRingHom.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_add := NonUnitalRingHom.map_add'
  map_zero := NonUnitalRingHom.map_zero'
  map_mul := NonUnitalRingHom.map_mul'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (α →ₙ+* β) fun _ => α → β :=
  ⟨NonUnitalRingHom.toFun⟩

@[simp]
theorem to_fun_eq_coe (f : α →ₙ+* β) : f.toFun = f :=
  rfl
#align non_unital_ring_hom.to_fun_eq_coe NonUnitalRingHom.to_fun_eq_coe

@[simp]
theorem coe_mk (f : α → β) (h₁ h₂ h₃) : ⇑(⟨f, h₁, h₂, h₃⟩ : α →ₙ+* β) = f :=
  rfl
#align non_unital_ring_hom.coe_mk NonUnitalRingHom.coe_mk

@[simp]
theorem coe_coe [NonUnitalRingHomClass F α β] (f : F) : ((f : α →ₙ+* β) : α → β) = f :=
  rfl
#align non_unital_ring_hom.coe_coe NonUnitalRingHom.coe_coe

@[simp]
theorem coe_to_mul_hom (f : α →ₙ+* β) : ⇑f.toMulHom = f :=
  rfl
#align non_unital_ring_hom.coe_to_mul_hom NonUnitalRingHom.coe_to_mul_hom

@[simp]
theorem coe_mul_hom_mk (f : α → β) (h₁ h₂ h₃) : ((⟨f, h₁, h₂, h₃⟩ : α →ₙ+* β) : α →ₙ* β) = ⟨f, h₁⟩ :=
  rfl
#align non_unital_ring_hom.coe_mul_hom_mk NonUnitalRingHom.coe_mul_hom_mk

@[simp]
theorem coe_to_add_monoid_hom (f : α →ₙ+* β) : ⇑f.toAddMonoidHom = f :=
  rfl
#align non_unital_ring_hom.coe_to_add_monoid_hom NonUnitalRingHom.coe_to_add_monoid_hom

@[simp]
theorem coe_add_monoid_hom_mk (f : α → β) (h₁ h₂ h₃) : ((⟨f, h₁, h₂, h₃⟩ : α →ₙ+* β) : α →+ β) = ⟨f, h₂, h₃⟩ :=
  rfl
#align non_unital_ring_hom.coe_add_monoid_hom_mk NonUnitalRingHom.coe_add_monoid_hom_mk

/-- Copy of a `ring_hom` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (f : α →ₙ+* β) (f' : α → β) (h : f' = f) : α →ₙ+* β :=
  { f.toMulHom.copy f' h, f.toAddMonoidHom.copy f' h with }
#align non_unital_ring_hom.copy NonUnitalRingHom.copy

end coe

variable [rα : NonUnitalNonAssocSemiring α] [rβ : NonUnitalNonAssocSemiring β]

section

include rα rβ

variable (f : α →ₙ+* β) {x y : α} {rα rβ}

@[ext.1]
theorem ext ⦃f g : α →ₙ+* β⦄ : (∀ x, f x = g x) → f = g :=
  FunLike.ext _ _
#align non_unital_ring_hom.ext NonUnitalRingHom.ext

theorem ext_iff {f g : α →ₙ+* β} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align non_unital_ring_hom.ext_iff NonUnitalRingHom.ext_iff

@[simp]
theorem mk_coe (f : α →ₙ+* β) (h₁ h₂ h₃) : NonUnitalRingHom.mk f h₁ h₂ h₃ = f :=
  ext fun _ => rfl
#align non_unital_ring_hom.mk_coe NonUnitalRingHom.mk_coe

theorem coe_add_monoid_hom_injective : Injective (coe : (α →ₙ+* β) → α →+ β) := fun f g h =>
  ext <| AddMonoidHom.congr_fun h
#align non_unital_ring_hom.coe_add_monoid_hom_injective NonUnitalRingHom.coe_add_monoid_hom_injective

theorem coe_mul_hom_injective : Injective (coe : (α →ₙ+* β) → α →ₙ* β) := fun f g h => ext <| MulHom.congr_fun h
#align non_unital_ring_hom.coe_mul_hom_injective NonUnitalRingHom.coe_mul_hom_injective

end

/-- The identity non-unital ring homomorphism from a non-unital semiring to itself. -/
protected def id (α : Type _) [NonUnitalNonAssocSemiring α] : α →ₙ+* α := by
  refine' { toFun := id.. } <;> intros <;> rfl
#align non_unital_ring_hom.id NonUnitalRingHom.id

include rα rβ

instance : Zero (α →ₙ+* β) :=
  ⟨{ toFun := 0, map_mul' := fun x y => (mul_zero (0 : β)).symm, map_zero' := rfl,
      map_add' := fun x y => (add_zero (0 : β)).symm }⟩

instance : Inhabited (α →ₙ+* β) :=
  ⟨0⟩

@[simp]
theorem coe_zero : ⇑(0 : α →ₙ+* β) = 0 :=
  rfl
#align non_unital_ring_hom.coe_zero NonUnitalRingHom.coe_zero

@[simp]
theorem zero_apply (x : α) : (0 : α →ₙ+* β) x = 0 :=
  rfl
#align non_unital_ring_hom.zero_apply NonUnitalRingHom.zero_apply

omit rβ

@[simp]
theorem id_apply (x : α) : NonUnitalRingHom.id α x = x :=
  rfl
#align non_unital_ring_hom.id_apply NonUnitalRingHom.id_apply

@[simp]
theorem coe_add_monoid_hom_id : (NonUnitalRingHom.id α : α →+ α) = AddMonoidHom.id α :=
  rfl
#align non_unital_ring_hom.coe_add_monoid_hom_id NonUnitalRingHom.coe_add_monoid_hom_id

@[simp]
theorem coe_mul_hom_id : (NonUnitalRingHom.id α : α →ₙ* α) = MulHom.id α :=
  rfl
#align non_unital_ring_hom.coe_mul_hom_id NonUnitalRingHom.coe_mul_hom_id

variable {rγ : NonUnitalNonAssocSemiring γ}

include rβ rγ

/-- Composition of non-unital ring homomorphisms is a non-unital ring homomorphism. -/
def comp (g : β →ₙ+* γ) (f : α →ₙ+* β) : α →ₙ+* γ :=
  { g.toMulHom.comp f.toMulHom, g.toAddMonoidHom.comp f.toAddMonoidHom with }
#align non_unital_ring_hom.comp NonUnitalRingHom.comp

/-- Composition of non-unital ring homomorphisms is associative. -/
theorem comp_assoc {δ} {rδ : NonUnitalNonAssocSemiring δ} (f : α →ₙ+* β) (g : β →ₙ+* γ) (h : γ →ₙ+* δ) :
    (h.comp g).comp f = h.comp (g.comp f) :=
  rfl
#align non_unital_ring_hom.comp_assoc NonUnitalRingHom.comp_assoc

@[simp]
theorem coe_comp (g : β →ₙ+* γ) (f : α →ₙ+* β) : ⇑(g.comp f) = g ∘ f :=
  rfl
#align non_unital_ring_hom.coe_comp NonUnitalRingHom.coe_comp

@[simp]
theorem comp_apply (g : β →ₙ+* γ) (f : α →ₙ+* β) (x : α) : g.comp f x = g (f x) :=
  rfl
#align non_unital_ring_hom.comp_apply NonUnitalRingHom.comp_apply

@[simp]
theorem coe_comp_add_monoid_hom (g : β →ₙ+* γ) (f : α →ₙ+* β) : (g.comp f : α →+ γ) = (g : β →+ γ).comp f :=
  rfl
#align non_unital_ring_hom.coe_comp_add_monoid_hom NonUnitalRingHom.coe_comp_add_monoid_hom

@[simp]
theorem coe_comp_mul_hom (g : β →ₙ+* γ) (f : α →ₙ+* β) : (g.comp f : α →ₙ* γ) = (g : β →ₙ* γ).comp f :=
  rfl
#align non_unital_ring_hom.coe_comp_mul_hom NonUnitalRingHom.coe_comp_mul_hom

@[simp]
theorem comp_zero (g : β →ₙ+* γ) : g.comp (0 : α →ₙ+* β) = 0 := by
  ext
  simp
#align non_unital_ring_hom.comp_zero NonUnitalRingHom.comp_zero

@[simp]
theorem zero_comp (f : α →ₙ+* β) : (0 : β →ₙ+* γ).comp f = 0 := by
  ext
  rfl
#align non_unital_ring_hom.zero_comp NonUnitalRingHom.zero_comp

omit rγ

@[simp]
theorem comp_id (f : α →ₙ+* β) : f.comp (NonUnitalRingHom.id α) = f :=
  ext fun x => rfl
#align non_unital_ring_hom.comp_id NonUnitalRingHom.comp_id

@[simp]
theorem id_comp (f : α →ₙ+* β) : (NonUnitalRingHom.id β).comp f = f :=
  ext fun x => rfl
#align non_unital_ring_hom.id_comp NonUnitalRingHom.id_comp

omit rβ

instance : MonoidWithZero (α →ₙ+* α) where
  one := NonUnitalRingHom.id α
  mul := comp
  mul_one := comp_id
  one_mul := id_comp
  mul_assoc f g h := comp_assoc _ _ _
  zero := 0
  mul_zero := comp_zero
  zero_mul := zero_comp

theorem one_def : (1 : α →ₙ+* α) = NonUnitalRingHom.id α :=
  rfl
#align non_unital_ring_hom.one_def NonUnitalRingHom.one_def

@[simp]
theorem coe_one : ⇑(1 : α →ₙ+* α) = id :=
  rfl
#align non_unital_ring_hom.coe_one NonUnitalRingHom.coe_one

theorem mul_def (f g : α →ₙ+* α) : f * g = f.comp g :=
  rfl
#align non_unital_ring_hom.mul_def NonUnitalRingHom.mul_def

@[simp]
theorem coe_mul (f g : α →ₙ+* α) : ⇑(f * g) = f ∘ g :=
  rfl
#align non_unital_ring_hom.coe_mul NonUnitalRingHom.coe_mul

include rβ rγ

theorem cancel_right {g₁ g₂ : β →ₙ+* γ} {f : α →ₙ+* β} (hf : Surjective f) : g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => ext <| hf.forall.2 (ext_iff.1 h), fun h => h ▸ rfl⟩
#align non_unital_ring_hom.cancel_right NonUnitalRingHom.cancel_right

theorem cancel_left {g : β →ₙ+* γ} {f₁ f₂ : α →ₙ+* β} (hg : Injective g) : g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => ext fun x => hg <| by rw [← comp_apply, h, comp_apply], fun h => h ▸ rfl⟩
#align non_unital_ring_hom.cancel_left NonUnitalRingHom.cancel_left

omit rα rβ rγ

end NonUnitalRingHom

/-- Bundled semiring homomorphisms; use this for bundled ring homomorphisms too.

This extends from both `monoid_hom` and `monoid_with_zero_hom` in order to put the fields in a
sensible order, even though `monoid_with_zero_hom` already extends `monoid_hom`. -/
structure RingHom (α : Type _) (β : Type _) [NonAssocSemiring α] [NonAssocSemiring β] extends α →* β, α →+ β, α →ₙ+* β,
  α →*₀ β
#align ring_hom RingHom

-- mathport name: «expr →+* »
infixr:25 " →+* " => RingHom

/-- Reinterpret a ring homomorphism `f : α →+* β` as a monoid with zero homomorphism `α →*₀ β`.
The `simp`-normal form is `(f : α →*₀ β)`. -/
add_decl_doc RingHom.toMonoidWithZeroHom

/-- Reinterpret a ring homomorphism `f : α →+* β` as a monoid homomorphism `α →* β`.
The `simp`-normal form is `(f : α →* β)`. -/
add_decl_doc RingHom.toMonoidHom

/-- Reinterpret a ring homomorphism `f : α →+* β` as an additive monoid homomorphism `α →+ β`.
The `simp`-normal form is `(f : α →+ β)`. -/
add_decl_doc RingHom.toAddMonoidHom

/-- Reinterpret a ring homomorphism `f : α →+* β` as a non-unital ring homomorphism `α →ₙ+* β`. The
`simp`-normal form is `(f : α →ₙ+* β)`. -/
add_decl_doc RingHom.toNonUnitalRingHom

section RingHomClass

/-- `ring_hom_class F α β` states that `F` is a type of (semi)ring homomorphisms.
You should extend this class when you extend `ring_hom`.

This extends from both `monoid_hom_class` and `monoid_with_zero_hom_class` in
order to put the fields in a sensible order, even though
`monoid_with_zero_hom_class` already extends `monoid_hom_class`. -/
class RingHomClass (F : Type _) (α β : outParam (Type _)) [NonAssocSemiring α] [NonAssocSemiring β] extends
  MonoidHomClass F α β, AddMonoidHomClass F α β, MonoidWithZeroHomClass F α β
#align ring_hom_class RingHomClass

variable [NonAssocSemiring α] [NonAssocSemiring β] [RingHomClass F α β]

/-- Ring homomorphisms preserve `bit1`. -/
@[simp]
theorem map_bit1 (f : F) (a : α) : (f (bit1 a) : β) = bit1 (f a) := by simp [bit1]
#align map_bit1 map_bit1

instance : CoeTC F (α →+* β) :=
  ⟨fun f =>
    { toFun := f, map_zero' := map_zero f, map_one' := map_one f, map_mul' := map_mul f, map_add' := map_add f }⟩

instance (priority := 100) RingHomClass.toNonUnitalRingHomClass : NonUnitalRingHomClass F α β :=
  { ‹RingHomClass F α β› with }
#align ring_hom_class.to_non_unital_ring_hom_class RingHomClass.toNonUnitalRingHomClass

end RingHomClass

namespace RingHom

section coe

/-!
Throughout this section, some `semiring` arguments are specified with `{}` instead of `[]`.
See note [implicit instance arguments].
-/


variable {rα : NonAssocSemiring α} {rβ : NonAssocSemiring β}

include rα rβ

instance : RingHomClass (α →+* β) α β where
  coe := RingHom.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_add := RingHom.map_add'
  map_zero := RingHom.map_zero'
  map_mul := RingHom.map_mul'
  map_one := RingHom.map_one'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly.
-/
instance : CoeFun (α →+* β) fun _ => α → β :=
  ⟨RingHom.toFun⟩

initialize_simps_projections RingHom (toFun → apply)

@[simp]
theorem to_fun_eq_coe (f : α →+* β) : f.toFun = f :=
  rfl
#align ring_hom.to_fun_eq_coe RingHom.to_fun_eq_coe

@[simp]
theorem coe_mk (f : α → β) (h₁ h₂ h₃ h₄) : ⇑(⟨f, h₁, h₂, h₃, h₄⟩ : α →+* β) = f :=
  rfl
#align ring_hom.coe_mk RingHom.coe_mk

@[simp]
theorem coe_coe {F : Type _} [RingHomClass F α β] (f : F) : ((f : α →+* β) : α → β) = f :=
  rfl
#align ring_hom.coe_coe RingHom.coe_coe

instance hasCoeMonoidHom : Coe (α →+* β) (α →* β) :=
  ⟨RingHom.toMonoidHom⟩
#align ring_hom.has_coe_monoid_hom RingHom.hasCoeMonoidHom

@[simp, norm_cast]
theorem coe_monoid_hom (f : α →+* β) : ⇑(f : α →* β) = f :=
  rfl
#align ring_hom.coe_monoid_hom RingHom.coe_monoid_hom

@[simp]
theorem to_monoid_hom_eq_coe (f : α →+* β) : f.toMonoidHom = f :=
  rfl
#align ring_hom.to_monoid_hom_eq_coe RingHom.to_monoid_hom_eq_coe

@[simp]
theorem to_monoid_with_zero_hom_eq_coe (f : α →+* β) : (f.toMonoidWithZeroHom : α → β) = f :=
  rfl
#align ring_hom.to_monoid_with_zero_hom_eq_coe RingHom.to_monoid_with_zero_hom_eq_coe

@[simp]
theorem coe_monoid_hom_mk (f : α → β) (h₁ h₂ h₃ h₄) : ((⟨f, h₁, h₂, h₃, h₄⟩ : α →+* β) : α →* β) = ⟨f, h₁, h₂⟩ :=
  rfl
#align ring_hom.coe_monoid_hom_mk RingHom.coe_monoid_hom_mk

@[simp, norm_cast]
theorem coe_add_monoid_hom (f : α →+* β) : ⇑(f : α →+ β) = f :=
  rfl
#align ring_hom.coe_add_monoid_hom RingHom.coe_add_monoid_hom

@[simp]
theorem to_add_monoid_hom_eq_coe (f : α →+* β) : f.toAddMonoidHom = f :=
  rfl
#align ring_hom.to_add_monoid_hom_eq_coe RingHom.to_add_monoid_hom_eq_coe

@[simp]
theorem coe_add_monoid_hom_mk (f : α → β) (h₁ h₂ h₃ h₄) : ((⟨f, h₁, h₂, h₃, h₄⟩ : α →+* β) : α →+ β) = ⟨f, h₃, h₄⟩ :=
  rfl
#align ring_hom.coe_add_monoid_hom_mk RingHom.coe_add_monoid_hom_mk

/-- Copy of a `ring_hom` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
def copy (f : α →+* β) (f' : α → β) (h : f' = f) : α →+* β :=
  { f.toMonoidWithZeroHom.copy f' h, f.toAddMonoidHom.copy f' h with }
#align ring_hom.copy RingHom.copy

end coe

variable [rα : NonAssocSemiring α] [rβ : NonAssocSemiring β]

section

include rα rβ

variable (f : α →+* β) {x y : α} {rα rβ}

theorem congr_fun {f g : α →+* β} (h : f = g) (x : α) : f x = g x :=
  FunLike.congr_fun h x
#align ring_hom.congr_fun RingHom.congr_fun

theorem congr_arg (f : α →+* β) {x y : α} (h : x = y) : f x = f y :=
  FunLike.congr_arg f h
#align ring_hom.congr_arg RingHom.congr_arg

theorem coe_inj ⦃f g : α →+* β⦄ (h : (f : α → β) = g) : f = g :=
  FunLike.coe_injective h
#align ring_hom.coe_inj RingHom.coe_inj

@[ext.1]
theorem ext ⦃f g : α →+* β⦄ : (∀ x, f x = g x) → f = g :=
  FunLike.ext _ _
#align ring_hom.ext RingHom.ext

theorem ext_iff {f g : α →+* β} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align ring_hom.ext_iff RingHom.ext_iff

@[simp]
theorem mk_coe (f : α →+* β) (h₁ h₂ h₃ h₄) : RingHom.mk f h₁ h₂ h₃ h₄ = f :=
  ext fun _ => rfl
#align ring_hom.mk_coe RingHom.mk_coe

theorem coe_add_monoid_hom_injective : Injective (coe : (α →+* β) → α →+ β) := fun f g h =>
  ext <| AddMonoidHom.congr_fun h
#align ring_hom.coe_add_monoid_hom_injective RingHom.coe_add_monoid_hom_injective

theorem coe_monoid_hom_injective : Injective (coe : (α →+* β) → α →* β) := fun f g h => ext <| MonoidHom.congr_fun h
#align ring_hom.coe_monoid_hom_injective RingHom.coe_monoid_hom_injective

/-- Ring homomorphisms map zero to zero. -/
protected theorem map_zero (f : α →+* β) : f 0 = 0 :=
  map_zero f
#align ring_hom.map_zero RingHom.map_zero

/-- Ring homomorphisms map one to one. -/
protected theorem map_one (f : α →+* β) : f 1 = 1 :=
  map_one f
#align ring_hom.map_one RingHom.map_one

/-- Ring homomorphisms preserve addition. -/
protected theorem map_add (f : α →+* β) : ∀ a b, f (a + b) = f a + f b :=
  map_add f
#align ring_hom.map_add RingHom.map_add

/-- Ring homomorphisms preserve multiplication. -/
protected theorem map_mul (f : α →+* β) : ∀ a b, f (a * b) = f a * f b :=
  map_mul f
#align ring_hom.map_mul RingHom.map_mul

/-- Ring homomorphisms preserve `bit0`. -/
protected theorem map_bit0 (f : α →+* β) : ∀ a, f (bit0 a) = bit0 (f a) :=
  map_bit0 f
#align ring_hom.map_bit0 RingHom.map_bit0

/-- Ring homomorphisms preserve `bit1`. -/
protected theorem map_bit1 (f : α →+* β) : ∀ a, f (bit1 a) = bit1 (f a) :=
  map_bit1 f
#align ring_hom.map_bit1 RingHom.map_bit1

@[simp]
theorem map_ite_zero_one {F : Type _} [RingHomClass F α β] (f : F) (p : Prop) [Decidable p] :
    f (ite p 0 1) = ite p 0 1 := by split_ifs <;> simp [h]
#align ring_hom.map_ite_zero_one RingHom.map_ite_zero_one

@[simp]
theorem map_ite_one_zero {F : Type _} [RingHomClass F α β] (f : F) (p : Prop) [Decidable p] :
    f (ite p 1 0) = ite p 1 0 := by split_ifs <;> simp [h]
#align ring_hom.map_ite_one_zero RingHom.map_ite_one_zero

/-- `f : α →+* β` has a trivial codomain iff `f 1 = 0`. -/
theorem codomain_trivial_iff_map_one_eq_zero : (0 : β) = 1 ↔ f 1 = 0 := by rw [map_one, eq_comm]
#align ring_hom.codomain_trivial_iff_map_one_eq_zero RingHom.codomain_trivial_iff_map_one_eq_zero

/-- `f : α →+* β` has a trivial codomain iff it has a trivial range. -/
theorem codomain_trivial_iff_range_trivial : (0 : β) = 1 ↔ ∀ x, f x = 0 :=
  f.codomain_trivial_iff_map_one_eq_zero.trans ⟨fun h x => by rw [← mul_one x, map_mul, h, mul_zero], fun h => h 1⟩
#align ring_hom.codomain_trivial_iff_range_trivial RingHom.codomain_trivial_iff_range_trivial

/-- `f : α →+* β` has a trivial codomain iff its range is `{0}`. -/
theorem codomain_trivial_iff_range_eq_singleton_zero : (0 : β) = 1 ↔ Set.range f = {0} :=
  f.codomain_trivial_iff_range_trivial.trans
    ⟨fun h => Set.ext fun y => ⟨fun ⟨x, hx⟩ => by simp [← hx, h x], fun hy => ⟨0, by simpa using hy.symm⟩⟩, fun h x =>
      Set.mem_singleton_iff.mp (h ▸ Set.mem_range_self x)⟩
#align ring_hom.codomain_trivial_iff_range_eq_singleton_zero RingHom.codomain_trivial_iff_range_eq_singleton_zero

/-- `f : α →+* β` doesn't map `1` to `0` if `β` is nontrivial -/
theorem map_one_ne_zero [Nontrivial β] : f 1 ≠ 0 :=
  mt f.codomain_trivial_iff_map_one_eq_zero.mpr zero_ne_one
#align ring_hom.map_one_ne_zero RingHom.map_one_ne_zero

/-- If there is a homomorphism `f : α →+* β` and `β` is nontrivial, then `α` is nontrivial. -/
theorem domain_nontrivial [Nontrivial β] : Nontrivial α :=
  ⟨⟨1, 0, mt (fun h => show f 1 = 0 by rw [h, map_zero]) f.map_one_ne_zero⟩⟩
#align ring_hom.domain_nontrivial RingHom.domain_nontrivial

theorem codomain_trivial (f : α →+* β) [h : Subsingleton α] : Subsingleton β :=
  (subsingleton_or_nontrivial β).resolve_right fun _ => not_nontrivial_iff_subsingleton.mpr h f.domain_nontrivial
#align ring_hom.codomain_trivial RingHom.codomain_trivial

end

/-- Ring homomorphisms preserve additive inverse. -/
protected theorem map_neg [NonAssocRing α] [NonAssocRing β] (f : α →+* β) (x : α) : f (-x) = -f x :=
  map_neg f x
#align ring_hom.map_neg RingHom.map_neg

/-- Ring homomorphisms preserve subtraction. -/
protected theorem map_sub [NonAssocRing α] [NonAssocRing β] (f : α →+* β) (x y : α) : f (x - y) = f x - f y :=
  map_sub f x y
#align ring_hom.map_sub RingHom.map_sub

/-- Makes a ring homomorphism from a monoid homomorphism of rings which preserves addition. -/
def mk' [NonAssocSemiring α] [NonAssocRing β] (f : α →* β) (map_add : ∀ a b, f (a + b) = f a + f b) : α →+* β :=
  { AddMonoidHom.mk' f map_add, f with }
#align ring_hom.mk' RingHom.mk'

section Semiring

variable [Semiring α] [Semiring β]

theorem is_unit_map (f : α →+* β) {a : α} : IsUnit a → IsUnit (f a) :=
  IsUnit.map f
#align ring_hom.is_unit_map RingHom.is_unit_map

protected theorem map_dvd (f : α →+* β) {a b : α} : a ∣ b → f a ∣ f b :=
  map_dvd f
#align ring_hom.map_dvd RingHom.map_dvd

end Semiring

/-- The identity ring homomorphism from a semiring to itself. -/
def id (α : Type _) [NonAssocSemiring α] : α →+* α := by refine' { toFun := id.. } <;> intros <;> rfl
#align ring_hom.id RingHom.id

include rα

instance : Inhabited (α →+* α) :=
  ⟨id α⟩

@[simp]
theorem id_apply (x : α) : RingHom.id α x = x :=
  rfl
#align ring_hom.id_apply RingHom.id_apply

@[simp]
theorem coe_add_monoid_hom_id : (id α : α →+ α) = AddMonoidHom.id α :=
  rfl
#align ring_hom.coe_add_monoid_hom_id RingHom.coe_add_monoid_hom_id

@[simp]
theorem coe_monoid_hom_id : (id α : α →* α) = MonoidHom.id α :=
  rfl
#align ring_hom.coe_monoid_hom_id RingHom.coe_monoid_hom_id

variable {rγ : NonAssocSemiring γ}

include rβ rγ

/-- Composition of ring homomorphisms is a ring homomorphism. -/
def comp (g : β →+* γ) (f : α →+* β) : α →+* γ :=
  { g.toNonUnitalRingHom.comp f.toNonUnitalRingHom with toFun := g ∘ f, map_one' := by simp }
#align ring_hom.comp RingHom.comp

/-- Composition of semiring homomorphisms is associative. -/
theorem comp_assoc {δ} {rδ : NonAssocSemiring δ} (f : α →+* β) (g : β →+* γ) (h : γ →+* δ) :
    (h.comp g).comp f = h.comp (g.comp f) :=
  rfl
#align ring_hom.comp_assoc RingHom.comp_assoc

@[simp]
theorem coe_comp (hnp : β →+* γ) (hmn : α →+* β) : (hnp.comp hmn : α → γ) = hnp ∘ hmn :=
  rfl
#align ring_hom.coe_comp RingHom.coe_comp

theorem comp_apply (hnp : β →+* γ) (hmn : α →+* β) (x : α) : (hnp.comp hmn : α → γ) x = hnp (hmn x) :=
  rfl
#align ring_hom.comp_apply RingHom.comp_apply

omit rγ

@[simp]
theorem comp_id (f : α →+* β) : f.comp (id α) = f :=
  ext fun x => rfl
#align ring_hom.comp_id RingHom.comp_id

@[simp]
theorem id_comp (f : α →+* β) : (id β).comp f = f :=
  ext fun x => rfl
#align ring_hom.id_comp RingHom.id_comp

omit rβ

instance : Monoid (α →+* α) where
  one := id α
  mul := comp
  mul_one := comp_id
  one_mul := id_comp
  mul_assoc f g h := comp_assoc _ _ _

theorem one_def : (1 : α →+* α) = id α :=
  rfl
#align ring_hom.one_def RingHom.one_def

theorem mul_def (f g : α →+* α) : f * g = f.comp g :=
  rfl
#align ring_hom.mul_def RingHom.mul_def

@[simp]
theorem coe_one : ⇑(1 : α →+* α) = _root_.id :=
  rfl
#align ring_hom.coe_one RingHom.coe_one

@[simp]
theorem coe_mul (f g : α →+* α) : ⇑(f * g) = f ∘ g :=
  rfl
#align ring_hom.coe_mul RingHom.coe_mul

include rβ rγ

theorem cancel_right {g₁ g₂ : β →+* γ} {f : α →+* β} (hf : Surjective f) : g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => RingHom.ext <| hf.forall.2 (ext_iff.1 h), fun h => h ▸ rfl⟩
#align ring_hom.cancel_right RingHom.cancel_right

theorem cancel_left {g : β →+* γ} {f₁ f₂ : α →+* β} (hg : Injective g) : g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => RingHom.ext fun x => hg <| by rw [← comp_apply, h, comp_apply], fun h => h ▸ rfl⟩
#align ring_hom.cancel_left RingHom.cancel_left

end RingHom

/-- Pullback `is_domain` instance along an injective function. -/
protected theorem Function.Injective.isDomain [Ring α] [IsDomain α] [Ring β] (f : β →+* α) (hf : Injective f) :
    IsDomain β :=
  { pullback_nonzero f f.map_zero f.map_one, hf.NoZeroDivisors f f.map_zero f.map_mul with }
#align function.injective.is_domain Function.Injective.isDomain

namespace AddMonoidHom

variable [CommRing α] [IsDomain α] [CommRing β] (f : β →+ α)

/-- Make a ring homomorphism from an additive group homomorphism from a commutative ring to an
integral domain that commutes with self multiplication, assumes that two is nonzero and `1` is sent
to `1`. -/
def mkRingHomOfMulSelfOfTwoNeZero (h : ∀ x, f (x * x) = f x * f x) (h_two : (2 : α) ≠ 0) (h_one : f 1 = 1) : β →+* α :=
  { f with map_one' := h_one,
    map_mul' := fun x y => by
      have hxy := h (x + y)
      rw [mul_add, add_mul, add_mul, f.map_add, f.map_add, f.map_add, f.map_add, h x, h y, add_mul, mul_add, mul_add, ←
        sub_eq_zero, add_comm, ← sub_sub, ← sub_sub, ← sub_sub, mul_comm y x, mul_comm (f y) (f x)] at hxy
      simp only [add_assoc, add_sub_assoc, add_sub_cancel'_right] at hxy
      rw [sub_sub, ← two_mul, ← add_sub_assoc, ← two_mul, ← mul_sub, mul_eq_zero, sub_eq_zero, or_iff_not_imp_left] at
        hxy
      exact hxy h_two }
#align add_monoid_hom.mk_ring_hom_of_mul_self_of_two_ne_zero AddMonoidHom.mkRingHomOfMulSelfOfTwoNeZero

@[simp]
theorem coe_fn_mk_ring_hom_of_mul_self_of_two_ne_zero (h h_two h_one) :
    (f.mkRingHomOfMulSelfOfTwoNeZero h h_two h_one : β → α) = f :=
  rfl
#align
  add_monoid_hom.coe_fn_mk_ring_hom_of_mul_self_of_two_ne_zero AddMonoidHom.coe_fn_mk_ring_hom_of_mul_self_of_two_ne_zero

@[simp]
theorem coe_add_monoid_hom_mk_ring_hom_of_mul_self_of_two_ne_zero (h h_two h_one) :
    (f.mkRingHomOfMulSelfOfTwoNeZero h h_two h_one : β →+ α) = f := by
  ext
  rfl
#align
  add_monoid_hom.coe_add_monoid_hom_mk_ring_hom_of_mul_self_of_two_ne_zero AddMonoidHom.coe_add_monoid_hom_mk_ring_hom_of_mul_self_of_two_ne_zero

end AddMonoidHom

section coe

variable (R S : Type _) [HasLiftT R S]

/-- `coe_is_non_unital_ring_hom R S` is a class stating that the coercion map `↑ : R → S`
(a.k.a. `coe`) is a non-unital ring homomorphism.
-/
class CoeIsNonUnitalRingHom [NonUnitalNonAssocSemiring R] [NonUnitalNonAssocSemiring S] extends CoeIsMulHom R S,
  CoeIsAddMonoidHom R S
#align coe_is_non_unital_ring_hom CoeIsNonUnitalRingHom

/-- `non_unital_ring_hom.coe M N` is the map `↑ : M → N` (a.k.a. `coe`),
bundled as a non-unital ring homomorphism. -/
@[simps (config := { fullyApplied := false })]
protected def NonUnitalRingHom.coe [NonUnitalNonAssocSemiring R] [NonUnitalNonAssocSemiring S]
    [CoeIsNonUnitalRingHom R S] : R →ₙ+* S :=
  { MulHom.coe R S, AddMonoidHom.coe R S with toFun := coe }
#align non_unital_ring_hom.coe NonUnitalRingHom.coe

/-- `coe_is_ring_hom R S` is a class stating that the coercion map `↑ : R → S` (a.k.a. `coe`)
is a ring homomorphism.
-/
class CoeIsRingHom [NonAssocSemiring R] [NonAssocSemiring S] extends CoeIsMonoidHom R S, CoeIsAddMonoidHom R S
#align coe_is_ring_hom CoeIsRingHom

-- See note [lower instance priority]
instance (priority := 100) CoeIsRingHom.toCoeIsNonUnitalRingHom [NonAssocSemiring R] [NonAssocSemiring S]
    [inst : CoeIsRingHom R S] : CoeIsNonUnitalRingHom R S :=
  { inst with }
#align coe_is_ring_hom.to_coe_is_non_unital_ring_hom CoeIsRingHom.toCoeIsNonUnitalRingHom

-- See note [lower instance priority]
instance (priority := 100) CoeIsRingHom.toCoeIsMonoidWithZeroHom [Semiring R] [Semiring S] [inst : CoeIsRingHom R S] :
    CoeIsMonoidWithZeroHom R S :=
  { inst with }
#align coe_is_ring_hom.to_coe_is_monoid_with_zero_hom CoeIsRingHom.toCoeIsMonoidWithZeroHom

/-- `ring_hom.coe M N` is the map `↑ : M → N` (a.k.a. `coe`),
bundled as a ring homomorphism. -/
@[simps (config := { fullyApplied := false })]
protected def RingHom.coe [NonAssocSemiring R] [NonAssocSemiring S] [CoeIsRingHom R S] : R →+* S :=
  { MonoidHom.coe R S, AddMonoidHom.coe R S with toFun := coe }
#align ring_hom.coe RingHom.coe

end coe

