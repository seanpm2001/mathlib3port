/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module order.heyting.hom
! leanprover-community/mathlib commit 50832daea47b195a48b5b33b1c8b2162c48c3afc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Hom.Lattice

/-!
# Heyting algebra morphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A Heyting homomorphism between two Heyting algebras is a bounded lattice homomorphism that preserves
Heyting implication.

We use the `fun_like` design, so each type of morphisms has a companion typeclass which is meant to
be satisfied by itself and all stricter types.

## Types of morphisms

* `heyting_hom`: Heyting homomorphisms.
* `coheyting_hom`: Co-Heyting homomorphisms.
* `biheyting_hom`: Bi-Heyting homomorphisms.

## Typeclasses

* `heyting_hom_class`
* `coheyting_hom_class`
* `biheyting_hom_class`
-/


open Function

variable {F α β γ δ : Type _}

#print HeytingHom /-
/-- The type of Heyting homomorphisms from `α` to `β`. Bounded lattice homomorphisms that preserve
Heyting implication. -/
@[protect_proj]
structure HeytingHom (α β : Type _) [HeytingAlgebra α] [HeytingAlgebra β] extends
    LatticeHom α β where
  map_bot' : to_fun ⊥ = ⊥
  map_himp' : ∀ a b, to_fun (a ⇨ b) = to_fun a ⇨ to_fun b
#align heyting_hom HeytingHom
-/

#print CoheytingHom /-
/-- The type of co-Heyting homomorphisms from `α` to `β`. Bounded lattice homomorphisms that
preserve difference. -/
@[protect_proj]
structure CoheytingHom (α β : Type _) [CoheytingAlgebra α] [CoheytingAlgebra β] extends
    LatticeHom α β where
  map_top' : to_fun ⊤ = ⊤
  map_sdiff' : ∀ a b, to_fun (a \ b) = to_fun a \ to_fun b
#align coheyting_hom CoheytingHom
-/

#print BiheytingHom /-
/-- The type of bi-Heyting homomorphisms from `α` to `β`. Bounded lattice homomorphisms that
preserve Heyting implication and difference. -/
@[protect_proj]
structure BiheytingHom (α β : Type _) [BiheytingAlgebra α] [BiheytingAlgebra β] extends
    LatticeHom α β where
  map_himp' : ∀ a b, to_fun (a ⇨ b) = to_fun a ⇨ to_fun b
  map_sdiff' : ∀ a b, to_fun (a \ b) = to_fun a \ to_fun b
#align biheyting_hom BiheytingHom
-/

#print HeytingHomClass /-
/-- `heyting_hom_class F α β` states that `F` is a type of Heyting homomorphisms.

You should extend this class when you extend `heyting_hom`. -/
class HeytingHomClass (F : Type _) (α β : outParam <| Type _) [HeytingAlgebra α]
    [HeytingAlgebra β] extends LatticeHomClass F α β where
  map_bot (f : F) : f ⊥ = ⊥
  map_himp (f : F) : ∀ a b, f (a ⇨ b) = f a ⇨ f b
#align heyting_hom_class HeytingHomClass
-/

#print CoheytingHomClass /-
/-- `coheyting_hom_class F α β` states that `F` is a type of co-Heyting homomorphisms.

You should extend this class when you extend `coheyting_hom`. -/
class CoheytingHomClass (F : Type _) (α β : outParam <| Type _) [CoheytingAlgebra α]
    [CoheytingAlgebra β] extends LatticeHomClass F α β where
  map_top (f : F) : f ⊤ = ⊤
  map_sdiff (f : F) : ∀ a b, f (a \ b) = f a \ f b
#align coheyting_hom_class CoheytingHomClass
-/

#print BiheytingHomClass /-
/-- `biheyting_hom_class F α β` states that `F` is a type of bi-Heyting homomorphisms.

You should extend this class when you extend `biheyting_hom`. -/
class BiheytingHomClass (F : Type _) (α β : outParam <| Type _) [BiheytingAlgebra α]
    [BiheytingAlgebra β] extends LatticeHomClass F α β where
  map_himp (f : F) : ∀ a b, f (a ⇨ b) = f a ⇨ f b
  map_sdiff (f : F) : ∀ a b, f (a \ b) = f a \ f b
#align biheyting_hom_class BiheytingHomClass
-/

export HeytingHomClass (map_himp)

export CoheytingHomClass (map_sdiff)

attribute [simp] map_himp map_sdiff

#print HeytingHomClass.toBoundedLatticeHomClass /-
-- See note [lower instance priority]
instance (priority := 100) HeytingHomClass.toBoundedLatticeHomClass [HeytingAlgebra α]
    [HeytingAlgebra β] [HeytingHomClass F α β] : BoundedLatticeHomClass F α β :=
  { ‹HeytingHomClass F α β› with
    map_top := fun f => by rw [← @himp_self α _ ⊥, ← himp_self, map_himp] }
#align heyting_hom_class.to_bounded_lattice_hom_class HeytingHomClass.toBoundedLatticeHomClass
-/

#print CoheytingHomClass.toBoundedLatticeHomClass /-
-- See note [lower instance priority]
instance (priority := 100) CoheytingHomClass.toBoundedLatticeHomClass [CoheytingAlgebra α]
    [CoheytingAlgebra β] [CoheytingHomClass F α β] : BoundedLatticeHomClass F α β :=
  { ‹CoheytingHomClass F α β› with
    map_bot := fun f => by rw [← @sdiff_self α _ ⊤, ← sdiff_self, map_sdiff] }
#align coheyting_hom_class.to_bounded_lattice_hom_class CoheytingHomClass.toBoundedLatticeHomClass
-/

#print BiheytingHomClass.toHeytingHomClass /-
-- See note [lower instance priority]
instance (priority := 100) BiheytingHomClass.toHeytingHomClass [BiheytingAlgebra α]
    [BiheytingAlgebra β] [BiheytingHomClass F α β] : HeytingHomClass F α β :=
  { ‹BiheytingHomClass F α β› with
    map_bot := fun f => by rw [← @sdiff_self α _ ⊤, ← sdiff_self, BiheytingHomClass.map_sdiff] }
#align biheyting_hom_class.to_heyting_hom_class BiheytingHomClass.toHeytingHomClass
-/

#print BiheytingHomClass.toCoheytingHomClass /-
-- See note [lower instance priority]
instance (priority := 100) BiheytingHomClass.toCoheytingHomClass [BiheytingAlgebra α]
    [BiheytingAlgebra β] [BiheytingHomClass F α β] : CoheytingHomClass F α β :=
  { ‹BiheytingHomClass F α β› with
    map_top := fun f => by rw [← @himp_self α _ ⊥, ← himp_self, map_himp] }
#align biheyting_hom_class.to_coheyting_hom_class BiheytingHomClass.toCoheytingHomClass
-/

#print OrderIsoClass.toHeytingHomClass /-
-- See note [lower instance priority]
instance (priority := 100) OrderIsoClass.toHeytingHomClass [HeytingAlgebra α] [HeytingAlgebra β]
    [OrderIsoClass F α β] : HeytingHomClass F α β :=
  { OrderIsoClass.toBoundedLatticeHomClass with
    map_himp := fun f a b =>
      eq_of_forall_le_iff fun c => by simp only [← map_inv_le_iff, le_himp_iff];
        rw [← OrderIsoClass.map_le_map_iff f]; simp }
#align order_iso_class.to_heyting_hom_class OrderIsoClass.toHeytingHomClass
-/

#print OrderIsoClass.toCoheytingHomClass /-
-- See note [lower instance priority]
instance (priority := 100) OrderIsoClass.toCoheytingHomClass [CoheytingAlgebra α]
    [CoheytingAlgebra β] [OrderIsoClass F α β] : CoheytingHomClass F α β :=
  { OrderIsoClass.toBoundedLatticeHomClass with
    map_sdiff := fun f a b =>
      eq_of_forall_ge_iff fun c => by simp only [← le_map_inv_iff, sdiff_le_iff];
        rw [← OrderIsoClass.map_le_map_iff f]; simp }
#align order_iso_class.to_coheyting_hom_class OrderIsoClass.toCoheytingHomClass
-/

#print OrderIsoClass.toBiheytingHomClass /-
-- See note [lower instance priority]
instance (priority := 100) OrderIsoClass.toBiheytingHomClass [BiheytingAlgebra α]
    [BiheytingAlgebra β] [OrderIsoClass F α β] : BiheytingHomClass F α β :=
  {
    OrderIsoClass.toLatticeHomClass with
    map_himp := fun f a b =>
      eq_of_forall_le_iff fun c => by simp only [← map_inv_le_iff, le_himp_iff];
        rw [← OrderIsoClass.map_le_map_iff f]; simp
    map_sdiff := fun f a b =>
      eq_of_forall_ge_iff fun c => by simp only [← le_map_inv_iff, sdiff_le_iff];
        rw [← OrderIsoClass.map_le_map_iff f]; simp }
#align order_iso_class.to_biheyting_hom_class OrderIsoClass.toBiheytingHomClass
-/

#print BoundedLatticeHomClass.toBiheytingHomClass /-
-- See note [reducible non instances]
/-- This can't be an instance because of typeclass loops. -/
@[reducible]
def BoundedLatticeHomClass.toBiheytingHomClass [BooleanAlgebra α] [BooleanAlgebra β]
    [BoundedLatticeHomClass F α β] : BiheytingHomClass F α β :=
  {
    ‹BoundedLatticeHomClass F α
        β› with
    map_himp := fun f a b => by rw [himp_eq, himp_eq, map_sup, (is_compl_compl.map _).compl_eq]
    map_sdiff := fun f a b => by rw [sdiff_eq, sdiff_eq, map_inf, (is_compl_compl.map _).compl_eq] }
#align bounded_lattice_hom_class.to_biheyting_hom_class BoundedLatticeHomClass.toBiheytingHomClass
-/

section HeytingAlgebra

variable [HeytingAlgebra α] [HeytingAlgebra β] [HeytingHomClass F α β] (f : F)

#print map_compl /-
@[simp]
theorem map_compl (a : α) : f (aᶜ) = f aᶜ := by rw [← himp_bot, ← himp_bot, map_himp, map_bot]
#align map_compl map_compl
-/

#print map_bihimp /-
@[simp]
theorem map_bihimp (a b : α) : f (a ⇔ b) = f a ⇔ f b := by simp_rw [bihimp, map_inf, map_himp]
#align map_bihimp map_bihimp
-/

-- TODO: `map_bihimp`
end HeytingAlgebra

section CoheytingAlgebra

variable [CoheytingAlgebra α] [CoheytingAlgebra β] [CoheytingHomClass F α β] (f : F)

#print map_hnot /-
@[simp]
theorem map_hnot (a : α) : f (￢a) = ￢f a := by rw [← top_sdiff', ← top_sdiff', map_sdiff, map_top]
#align map_hnot map_hnot
-/

#print map_symmDiff /-
@[simp]
theorem map_symmDiff (a b : α) : f (a ∆ b) = f a ∆ f b := by simp_rw [symmDiff, map_sup, map_sdiff]
#align map_symm_diff map_symmDiff
-/

end CoheytingAlgebra

instance [HeytingAlgebra α] [HeytingAlgebra β] [HeytingHomClass F α β] : CoeTC F (HeytingHom α β) :=
  ⟨fun f =>
    { toFun := f
      map_sup' := map_sup f
      map_inf' := map_inf f
      map_bot' := map_bot f
      map_himp' := map_himp f }⟩

instance [CoheytingAlgebra α] [CoheytingAlgebra β] [CoheytingHomClass F α β] :
    CoeTC F (CoheytingHom α β) :=
  ⟨fun f =>
    { toFun := f
      map_sup' := map_sup f
      map_inf' := map_inf f
      map_top' := map_top f
      map_sdiff' := map_sdiff f }⟩

instance [BiheytingAlgebra α] [BiheytingAlgebra β] [BiheytingHomClass F α β] :
    CoeTC F (BiheytingHom α β) :=
  ⟨fun f =>
    { toFun := f
      map_sup' := map_sup f
      map_inf' := map_inf f
      map_himp' := map_himp f
      map_sdiff' := map_sdiff f }⟩

namespace HeytingHom

variable [HeytingAlgebra α] [HeytingAlgebra β] [HeytingAlgebra γ] [HeytingAlgebra δ]

instance : HeytingHomClass (HeytingHom α β) α β
    where
  coe f := f.toFun
  coe_injective' f g h := by obtain ⟨⟨⟨_, _⟩, _⟩, _⟩ := f <;> obtain ⟨⟨⟨_, _⟩, _⟩, _⟩ := g <;> congr
  map_sup f := f.map_sup'
  map_inf f := f.map_inf'
  map_bot f := f.map_bot'
  map_himp := HeytingHom.map_himp'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (HeytingHom α β) fun _ => α → β :=
  FunLike.hasCoeToFun

#print HeytingHom.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe {f : HeytingHom α β} : f.toFun = (f : α → β) :=
  rfl
#align heyting_hom.to_fun_eq_coe HeytingHom.toFun_eq_coe
-/

#print HeytingHom.ext /-
@[ext]
theorem ext {f g : HeytingHom α β} (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align heyting_hom.ext HeytingHom.ext
-/

#print HeytingHom.copy /-
/-- Copy of a `heyting_hom` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (f : HeytingHom α β) (f' : α → β) (h : f' = f) : HeytingHom α β
    where
  toFun := f'
  map_sup' := by simpa only [h] using map_sup f
  map_inf' := by simpa only [h] using map_inf f
  map_bot' := by simpa only [h] using map_bot f
  map_himp' := by simpa only [h] using map_himp f
#align heyting_hom.copy HeytingHom.copy
-/

#print HeytingHom.coe_copy /-
@[simp]
theorem coe_copy (f : HeytingHom α β) (f' : α → β) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align heyting_hom.coe_copy HeytingHom.coe_copy
-/

#print HeytingHom.copy_eq /-
theorem copy_eq (f : HeytingHom α β) (f' : α → β) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align heyting_hom.copy_eq HeytingHom.copy_eq
-/

variable (α)

#print HeytingHom.id /-
/-- `id` as a `heyting_hom`. -/
protected def id : HeytingHom α α :=
  { BotHom.id _ with
    toLatticeHom := LatticeHom.id _
    map_himp' := fun a b => rfl }
#align heyting_hom.id HeytingHom.id
-/

#print HeytingHom.coe_id /-
@[simp]
theorem coe_id : ⇑(HeytingHom.id α) = id :=
  rfl
#align heyting_hom.coe_id HeytingHom.coe_id
-/

variable {α}

#print HeytingHom.id_apply /-
@[simp]
theorem id_apply (a : α) : HeytingHom.id α a = a :=
  rfl
#align heyting_hom.id_apply HeytingHom.id_apply
-/

instance : Inhabited (HeytingHom α α) :=
  ⟨HeytingHom.id _⟩

instance : PartialOrder (HeytingHom α β) :=
  PartialOrder.lift _ FunLike.coe_injective

#print HeytingHom.comp /-
/-- Composition of `heyting_hom`s as a `heyting_hom`. -/
def comp (f : HeytingHom β γ) (g : HeytingHom α β) : HeytingHom α γ :=
  { f.toLatticeHom.comp g.toLatticeHom with
    toFun := f ∘ g
    map_bot' := by simp
    map_himp' := fun a b => by simp }
#align heyting_hom.comp HeytingHom.comp
-/

variable {f f₁ f₂ : HeytingHom α β} {g g₁ g₂ : HeytingHom β γ}

#print HeytingHom.coe_comp /-
@[simp]
theorem coe_comp (f : HeytingHom β γ) (g : HeytingHom α β) : ⇑(f.comp g) = f ∘ g :=
  rfl
#align heyting_hom.coe_comp HeytingHom.coe_comp
-/

#print HeytingHom.comp_apply /-
@[simp]
theorem comp_apply (f : HeytingHom β γ) (g : HeytingHom α β) (a : α) : f.comp g a = f (g a) :=
  rfl
#align heyting_hom.comp_apply HeytingHom.comp_apply
-/

#print HeytingHom.comp_assoc /-
@[simp]
theorem comp_assoc (f : HeytingHom γ δ) (g : HeytingHom β γ) (h : HeytingHom α β) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align heyting_hom.comp_assoc HeytingHom.comp_assoc
-/

#print HeytingHom.comp_id /-
@[simp]
theorem comp_id (f : HeytingHom α β) : f.comp (HeytingHom.id α) = f :=
  ext fun a => rfl
#align heyting_hom.comp_id HeytingHom.comp_id
-/

#print HeytingHom.id_comp /-
@[simp]
theorem id_comp (f : HeytingHom α β) : (HeytingHom.id β).comp f = f :=
  ext fun a => rfl
#align heyting_hom.id_comp HeytingHom.id_comp
-/

#print HeytingHom.cancel_right /-
theorem cancel_right (hf : Surjective f) : g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => ext <| hf.forall.2 <| FunLike.ext_iff.1 h, congr_arg _⟩
#align heyting_hom.cancel_right HeytingHom.cancel_right
-/

#print HeytingHom.cancel_left /-
theorem cancel_left (hg : Injective g) : g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => HeytingHom.ext fun a => hg <| by rw [← comp_apply, h, comp_apply], congr_arg _⟩
#align heyting_hom.cancel_left HeytingHom.cancel_left
-/

end HeytingHom

namespace CoheytingHom

variable [CoheytingAlgebra α] [CoheytingAlgebra β] [CoheytingAlgebra γ] [CoheytingAlgebra δ]

instance : CoheytingHomClass (CoheytingHom α β) α β
    where
  coe f := f.toFun
  coe_injective' f g h := by obtain ⟨⟨⟨_, _⟩, _⟩, _⟩ := f <;> obtain ⟨⟨⟨_, _⟩, _⟩, _⟩ := g <;> congr
  map_sup f := f.map_sup'
  map_inf f := f.map_inf'
  map_top f := f.map_top'
  map_sdiff := CoheytingHom.map_sdiff'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (CoheytingHom α β) fun _ => α → β :=
  FunLike.hasCoeToFun

#print CoheytingHom.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe {f : CoheytingHom α β} : f.toFun = (f : α → β) :=
  rfl
#align coheyting_hom.to_fun_eq_coe CoheytingHom.toFun_eq_coe
-/

#print CoheytingHom.ext /-
@[ext]
theorem ext {f g : CoheytingHom α β} (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align coheyting_hom.ext CoheytingHom.ext
-/

#print CoheytingHom.copy /-
/-- Copy of a `coheyting_hom` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (f : CoheytingHom α β) (f' : α → β) (h : f' = f) : CoheytingHom α β
    where
  toFun := f'
  map_sup' := by simpa only [h] using map_sup f
  map_inf' := by simpa only [h] using map_inf f
  map_top' := by simpa only [h] using map_top f
  map_sdiff' := by simpa only [h] using map_sdiff f
#align coheyting_hom.copy CoheytingHom.copy
-/

#print CoheytingHom.coe_copy /-
@[simp]
theorem coe_copy (f : CoheytingHom α β) (f' : α → β) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align coheyting_hom.coe_copy CoheytingHom.coe_copy
-/

#print CoheytingHom.copy_eq /-
theorem copy_eq (f : CoheytingHom α β) (f' : α → β) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align coheyting_hom.copy_eq CoheytingHom.copy_eq
-/

variable (α)

#print CoheytingHom.id /-
/-- `id` as a `coheyting_hom`. -/
protected def id : CoheytingHom α α :=
  { TopHom.id _ with
    toLatticeHom := LatticeHom.id _
    map_sdiff' := fun a b => rfl }
#align coheyting_hom.id CoheytingHom.id
-/

#print CoheytingHom.coe_id /-
@[simp]
theorem coe_id : ⇑(CoheytingHom.id α) = id :=
  rfl
#align coheyting_hom.coe_id CoheytingHom.coe_id
-/

variable {α}

#print CoheytingHom.id_apply /-
@[simp]
theorem id_apply (a : α) : CoheytingHom.id α a = a :=
  rfl
#align coheyting_hom.id_apply CoheytingHom.id_apply
-/

instance : Inhabited (CoheytingHom α α) :=
  ⟨CoheytingHom.id _⟩

instance : PartialOrder (CoheytingHom α β) :=
  PartialOrder.lift _ FunLike.coe_injective

#print CoheytingHom.comp /-
/-- Composition of `coheyting_hom`s as a `coheyting_hom`. -/
def comp (f : CoheytingHom β γ) (g : CoheytingHom α β) : CoheytingHom α γ :=
  { f.toLatticeHom.comp g.toLatticeHom with
    toFun := f ∘ g
    map_top' := by simp
    map_sdiff' := fun a b => by simp }
#align coheyting_hom.comp CoheytingHom.comp
-/

variable {f f₁ f₂ : CoheytingHom α β} {g g₁ g₂ : CoheytingHom β γ}

#print CoheytingHom.coe_comp /-
@[simp]
theorem coe_comp (f : CoheytingHom β γ) (g : CoheytingHom α β) : ⇑(f.comp g) = f ∘ g :=
  rfl
#align coheyting_hom.coe_comp CoheytingHom.coe_comp
-/

#print CoheytingHom.comp_apply /-
@[simp]
theorem comp_apply (f : CoheytingHom β γ) (g : CoheytingHom α β) (a : α) : f.comp g a = f (g a) :=
  rfl
#align coheyting_hom.comp_apply CoheytingHom.comp_apply
-/

#print CoheytingHom.comp_assoc /-
@[simp]
theorem comp_assoc (f : CoheytingHom γ δ) (g : CoheytingHom β γ) (h : CoheytingHom α β) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align coheyting_hom.comp_assoc CoheytingHom.comp_assoc
-/

#print CoheytingHom.comp_id /-
@[simp]
theorem comp_id (f : CoheytingHom α β) : f.comp (CoheytingHom.id α) = f :=
  ext fun a => rfl
#align coheyting_hom.comp_id CoheytingHom.comp_id
-/

#print CoheytingHom.id_comp /-
@[simp]
theorem id_comp (f : CoheytingHom α β) : (CoheytingHom.id β).comp f = f :=
  ext fun a => rfl
#align coheyting_hom.id_comp CoheytingHom.id_comp
-/

#print CoheytingHom.cancel_right /-
theorem cancel_right (hf : Surjective f) : g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => ext <| hf.forall.2 <| FunLike.ext_iff.1 h, congr_arg _⟩
#align coheyting_hom.cancel_right CoheytingHom.cancel_right
-/

#print CoheytingHom.cancel_left /-
theorem cancel_left (hg : Injective g) : g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => CoheytingHom.ext fun a => hg <| by rw [← comp_apply, h, comp_apply], congr_arg _⟩
#align coheyting_hom.cancel_left CoheytingHom.cancel_left
-/

end CoheytingHom

namespace BiheytingHom

variable [BiheytingAlgebra α] [BiheytingAlgebra β] [BiheytingAlgebra γ] [BiheytingAlgebra δ]

instance : BiheytingHomClass (BiheytingHom α β) α β
    where
  coe f := f.toFun
  coe_injective' f g h := by obtain ⟨⟨⟨_, _⟩, _⟩, _⟩ := f <;> obtain ⟨⟨⟨_, _⟩, _⟩, _⟩ := g <;> congr
  map_sup f := f.map_sup'
  map_inf f := f.map_inf'
  map_himp f := f.map_himp'
  map_sdiff f := f.map_sdiff'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (BiheytingHom α β) fun _ => α → β :=
  FunLike.hasCoeToFun

#print BiheytingHom.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe {f : BiheytingHom α β} : f.toFun = (f : α → β) :=
  rfl
#align biheyting_hom.to_fun_eq_coe BiheytingHom.toFun_eq_coe
-/

#print BiheytingHom.ext /-
@[ext]
theorem ext {f g : BiheytingHom α β} (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align biheyting_hom.ext BiheytingHom.ext
-/

#print BiheytingHom.copy /-
/-- Copy of a `biheyting_hom` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (f : BiheytingHom α β) (f' : α → β) (h : f' = f) : BiheytingHom α β
    where
  toFun := f'
  map_sup' := by simpa only [h] using map_sup f
  map_inf' := by simpa only [h] using map_inf f
  map_himp' := by simpa only [h] using map_himp f
  map_sdiff' := by simpa only [h] using map_sdiff f
#align biheyting_hom.copy BiheytingHom.copy
-/

#print BiheytingHom.coe_copy /-
@[simp]
theorem coe_copy (f : BiheytingHom α β) (f' : α → β) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align biheyting_hom.coe_copy BiheytingHom.coe_copy
-/

#print BiheytingHom.copy_eq /-
theorem copy_eq (f : BiheytingHom α β) (f' : α → β) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align biheyting_hom.copy_eq BiheytingHom.copy_eq
-/

variable (α)

#print BiheytingHom.id /-
/-- `id` as a `biheyting_hom`. -/
protected def id : BiheytingHom α α :=
  { HeytingHom.id _, CoheytingHom.id _ with toLatticeHom := LatticeHom.id _ }
#align biheyting_hom.id BiheytingHom.id
-/

#print BiheytingHom.coe_id /-
@[simp]
theorem coe_id : ⇑(BiheytingHom.id α) = id :=
  rfl
#align biheyting_hom.coe_id BiheytingHom.coe_id
-/

variable {α}

#print BiheytingHom.id_apply /-
@[simp]
theorem id_apply (a : α) : BiheytingHom.id α a = a :=
  rfl
#align biheyting_hom.id_apply BiheytingHom.id_apply
-/

instance : Inhabited (BiheytingHom α α) :=
  ⟨BiheytingHom.id _⟩

instance : PartialOrder (BiheytingHom α β) :=
  PartialOrder.lift _ FunLike.coe_injective

#print BiheytingHom.comp /-
/-- Composition of `biheyting_hom`s as a `biheyting_hom`. -/
def comp (f : BiheytingHom β γ) (g : BiheytingHom α β) : BiheytingHom α γ :=
  { f.toLatticeHom.comp g.toLatticeHom with
    toFun := f ∘ g
    map_himp' := fun a b => by simp
    map_sdiff' := fun a b => by simp }
#align biheyting_hom.comp BiheytingHom.comp
-/

variable {f f₁ f₂ : BiheytingHom α β} {g g₁ g₂ : BiheytingHom β γ}

#print BiheytingHom.coe_comp /-
@[simp]
theorem coe_comp (f : BiheytingHom β γ) (g : BiheytingHom α β) : ⇑(f.comp g) = f ∘ g :=
  rfl
#align biheyting_hom.coe_comp BiheytingHom.coe_comp
-/

#print BiheytingHom.comp_apply /-
@[simp]
theorem comp_apply (f : BiheytingHom β γ) (g : BiheytingHom α β) (a : α) : f.comp g a = f (g a) :=
  rfl
#align biheyting_hom.comp_apply BiheytingHom.comp_apply
-/

#print BiheytingHom.comp_assoc /-
@[simp]
theorem comp_assoc (f : BiheytingHom γ δ) (g : BiheytingHom β γ) (h : BiheytingHom α β) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align biheyting_hom.comp_assoc BiheytingHom.comp_assoc
-/

#print BiheytingHom.comp_id /-
@[simp]
theorem comp_id (f : BiheytingHom α β) : f.comp (BiheytingHom.id α) = f :=
  ext fun a => rfl
#align biheyting_hom.comp_id BiheytingHom.comp_id
-/

#print BiheytingHom.id_comp /-
@[simp]
theorem id_comp (f : BiheytingHom α β) : (BiheytingHom.id β).comp f = f :=
  ext fun a => rfl
#align biheyting_hom.id_comp BiheytingHom.id_comp
-/

#print BiheytingHom.cancel_right /-
theorem cancel_right (hf : Surjective f) : g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => ext <| hf.forall.2 <| FunLike.ext_iff.1 h, congr_arg _⟩
#align biheyting_hom.cancel_right BiheytingHom.cancel_right
-/

#print BiheytingHom.cancel_left /-
theorem cancel_left (hg : Injective g) : g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => BiheytingHom.ext fun a => hg <| by rw [← comp_apply, h, comp_apply], congr_arg _⟩
#align biheyting_hom.cancel_left BiheytingHom.cancel_left
-/

end BiheytingHom

