/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Mario Carneiro

! This file was ported from Lean 3 source module logic.equiv.defs
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.FunLike.Equiv
import Mathbin.Logic.Unique

/-!
# Equivalence between types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define two types:

* `equiv α β` a.k.a. `α ≃ β`: a bijective map `α → β` bundled with its inverse map; we use this (and
  not equality!) to express that various `Type`s or `Sort`s are equivalent.

* `equiv.perm α`: the group of permutations `α ≃ α`. More lemmas about `equiv.perm` can be found in
  `group_theory/perm`.

Then we define

* canonical isomorphisms between various types: e.g.,

  - `equiv.refl α` is the identity map interpreted as `α ≃ α`;

* operations on equivalences: e.g.,

  - `equiv.symm e : β ≃ α` is the inverse of `e : α ≃ β`;

  - `equiv.trans e₁ e₂ : α ≃ γ` is the composition of `e₁ : α ≃ β` and `e₂ : β ≃ γ` (note the order
    of the arguments!);

* definitions that transfer some instances along an equivalence. By convention, we transfer
  instances from right to left.

  - `equiv.inhabited` takes `e : α ≃ β` and `[inhabited β]` and returns `inhabited α`;
  - `equiv.unique` takes `e : α ≃ β` and `[unique β]` and returns `unique α`;
  - `equiv.decidable_eq` takes `e : α ≃ β` and `[decidable_eq β]` and returns `decidable_eq α`.

  More definitions of this kind can be found in other files. E.g., `data/equiv/transfer_instance`
  does it for many algebraic type classes like `group`, `module`, etc.

Many more such isomorphisms and operations are defined in `logic/equiv/basic`.

## Tags

equivalence, congruence, bijective map
-/


open Function

universe u v w z

variable {α : Sort u} {β : Sort v} {γ : Sort w}

#print Equiv /-
/-- `α ≃ β` is the type of functions from `α → β` with a two-sided inverse. -/
structure Equiv (α : Sort _) (β : Sort _) where
  toFun : α → β
  invFun : β → α
  left_inv : LeftInverse inv_fun to_fun
  right_inv : RightInverse inv_fun to_fun
#align equiv Equiv
-/

infixl:25 " ≃ " => Equiv

instance {F} [EquivLike F α β] : CoeTC F (α ≃ β) :=
  ⟨fun f =>
    { toFun := f
      invFun := EquivLike.inv f
      left_inv := EquivLike.left_inv f
      right_inv := EquivLike.right_inv f }⟩

#print Equiv.Perm /-
/-- `perm α` is the type of bijections from `α` to itself. -/
@[reducible]
def Equiv.Perm (α : Sort _) :=
  Equiv α α
#align equiv.perm Equiv.Perm
-/

namespace Equiv

instance : EquivLike (α ≃ β) α β where
  coe := toFun
  inv := invFun
  left_inv := left_inv
  right_inv := right_inv
  coe_injective' e₁ e₂ h₁ h₂ := by cases e₁; cases e₂; congr

instance : CoeFun (α ≃ β) fun _ => α → β :=
  ⟨toFun⟩

#print Equiv.coe_fn_mk /-
@[simp]
theorem coe_fn_mk (f : α → β) (g l r) : (Equiv.mk f g l r : α → β) = f :=
  rfl
#align equiv.coe_fn_mk Equiv.coe_fn_mk
-/

#print Equiv.coe_fn_injective /-
/-- The map `coe_fn : (r ≃ s) → (r → s)` is injective. -/
theorem coe_fn_injective : @Function.Injective (α ≃ β) (α → β) coeFn :=
  FunLike.coe_injective
#align equiv.coe_fn_injective Equiv.coe_fn_injective
-/

#print Equiv.coe_inj /-
protected theorem coe_inj {e₁ e₂ : α ≃ β} : (e₁ : α → β) = e₂ ↔ e₁ = e₂ :=
  FunLike.coe_fn_eq
#align equiv.coe_inj Equiv.coe_inj
-/

#print Equiv.ext /-
@[ext]
theorem ext {f g : Equiv α β} (H : ∀ x, f x = g x) : f = g :=
  FunLike.ext f g H
#align equiv.ext Equiv.ext
-/

#print Equiv.congr_arg /-
protected theorem congr_arg {f : Equiv α β} {x x' : α} : x = x' → f x = f x' :=
  FunLike.congr_arg f
#align equiv.congr_arg Equiv.congr_arg
-/

#print Equiv.congr_fun /-
protected theorem congr_fun {f g : Equiv α β} (h : f = g) (x : α) : f x = g x :=
  FunLike.congr_fun h x
#align equiv.congr_fun Equiv.congr_fun
-/

#print Equiv.ext_iff /-
theorem ext_iff {f g : Equiv α β} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align equiv.ext_iff Equiv.ext_iff
-/

#print Equiv.Perm.ext /-
@[ext]
theorem Perm.ext {σ τ : Equiv.Perm α} (H : ∀ x, σ x = τ x) : σ = τ :=
  Equiv.ext H
#align equiv.perm.ext Equiv.Perm.ext
-/

#print Equiv.Perm.congr_arg /-
protected theorem Perm.congr_arg {f : Equiv.Perm α} {x x' : α} : x = x' → f x = f x' :=
  Equiv.congr_arg
#align equiv.perm.congr_arg Equiv.Perm.congr_arg
-/

#print Equiv.Perm.congr_fun /-
protected theorem Perm.congr_fun {f g : Equiv.Perm α} (h : f = g) (x : α) : f x = g x :=
  Equiv.congr_fun h x
#align equiv.perm.congr_fun Equiv.Perm.congr_fun
-/

#print Equiv.Perm.ext_iff /-
theorem Perm.ext_iff {σ τ : Equiv.Perm α} : σ = τ ↔ ∀ x, σ x = τ x :=
  ext_iff
#align equiv.perm.ext_iff Equiv.Perm.ext_iff
-/

#print Equiv.refl /-
/-- Any type is equivalent to itself. -/
@[refl]
protected def refl (α : Sort _) : α ≃ α :=
  ⟨id, id, fun x => rfl, fun x => rfl⟩
#align equiv.refl Equiv.refl
-/

#print Equiv.inhabited' /-
instance inhabited' : Inhabited (α ≃ α) :=
  ⟨Equiv.refl α⟩
#align equiv.inhabited' Equiv.inhabited'
-/

#print Equiv.symm /-
/-- Inverse of an equivalence `e : α ≃ β`. -/
@[symm]
protected def symm (e : α ≃ β) : β ≃ α :=
  ⟨e.invFun, e.toFun, e.right_inv, e.left_inv⟩
#align equiv.symm Equiv.symm
-/

#print Equiv.Simps.symm_apply /-
/-- See Note [custom simps projection] -/
def Simps.symm_apply (e : α ≃ β) : β → α :=
  e.symm
#align equiv.simps.symm_apply Equiv.Simps.symm_apply
-/

initialize_simps_projections Equiv (toFun → apply, invFun → symm_apply)

#print Equiv.trans /-
/-- Composition of equivalences `e₁ : α ≃ β` and `e₂ : β ≃ γ`. -/
@[trans]
protected def trans (e₁ : α ≃ β) (e₂ : β ≃ γ) : α ≃ γ :=
  ⟨e₂ ∘ e₁, e₁.symm ∘ e₂.symm, e₂.left_inv.comp e₁.left_inv, e₂.right_inv.comp e₁.right_inv⟩
#align equiv.trans Equiv.trans
-/

#print Equiv.toFun_as_coe /-
@[simp]
theorem toFun_as_coe (e : α ≃ β) : e.toFun = e :=
  rfl
#align equiv.to_fun_as_coe Equiv.toFun_as_coe
-/

#print Equiv.invFun_as_coe /-
@[simp]
theorem invFun_as_coe (e : α ≃ β) : e.invFun = e.symm :=
  rfl
#align equiv.inv_fun_as_coe Equiv.invFun_as_coe
-/

#print Equiv.injective /-
protected theorem injective (e : α ≃ β) : Injective e :=
  EquivLike.injective e
#align equiv.injective Equiv.injective
-/

#print Equiv.surjective /-
protected theorem surjective (e : α ≃ β) : Surjective e :=
  EquivLike.surjective e
#align equiv.surjective Equiv.surjective
-/

#print Equiv.bijective /-
protected theorem bijective (e : α ≃ β) : Bijective e :=
  EquivLike.bijective e
#align equiv.bijective Equiv.bijective
-/

#print Equiv.subsingleton /-
protected theorem subsingleton (e : α ≃ β) [Subsingleton β] : Subsingleton α :=
  e.Injective.Subsingleton
#align equiv.subsingleton Equiv.subsingleton
-/

#print Equiv.subsingleton.symm /-
protected theorem subsingleton.symm (e : α ≃ β) [Subsingleton α] : Subsingleton β :=
  e.symm.Injective.Subsingleton
#align equiv.subsingleton.symm Equiv.subsingleton.symm
-/

#print Equiv.subsingleton_congr /-
theorem subsingleton_congr (e : α ≃ β) : Subsingleton α ↔ Subsingleton β :=
  ⟨fun h => e.symm.subsingleton, fun h => e.subsingleton⟩
#align equiv.subsingleton_congr Equiv.subsingleton_congr
-/

#print Equiv.equiv_subsingleton_cod /-
instance equiv_subsingleton_cod [Subsingleton β] : Subsingleton (α ≃ β) :=
  FunLike.subsingleton_cod
#align equiv.equiv_subsingleton_cod Equiv.equiv_subsingleton_cod
-/

#print Equiv.equiv_subsingleton_dom /-
instance equiv_subsingleton_dom [Subsingleton α] : Subsingleton (α ≃ β) :=
  EquivLike.subsingleton_dom
#align equiv.equiv_subsingleton_dom Equiv.equiv_subsingleton_dom
-/

#print Equiv.permUnique /-
instance permUnique [Subsingleton α] : Unique (Perm α) :=
  uniqueOfSubsingleton (Equiv.refl α)
#align equiv.perm_unique Equiv.permUnique
-/

#print Equiv.Perm.subsingleton_eq_refl /-
theorem Perm.subsingleton_eq_refl [Subsingleton α] (e : Perm α) : e = Equiv.refl α :=
  Subsingleton.elim _ _
#align equiv.perm.subsingleton_eq_refl Equiv.Perm.subsingleton_eq_refl
-/

#print Equiv.decidableEq /-
/-- Transfer `decidable_eq` across an equivalence. -/
protected def decidableEq (e : α ≃ β) [DecidableEq β] : DecidableEq α :=
  e.Injective.DecidableEq
#align equiv.decidable_eq Equiv.decidableEq
-/

#print Equiv.nonempty_congr /-
theorem nonempty_congr (e : α ≃ β) : Nonempty α ↔ Nonempty β :=
  Nonempty.congr e e.symm
#align equiv.nonempty_congr Equiv.nonempty_congr
-/

#print Equiv.nonempty /-
protected theorem nonempty (e : α ≃ β) [Nonempty β] : Nonempty α :=
  e.nonempty_congr.mpr ‹_›
#align equiv.nonempty Equiv.nonempty
-/

#print Equiv.inhabited /-
/-- If `α ≃ β` and `β` is inhabited, then so is `α`. -/
protected def inhabited [Inhabited β] (e : α ≃ β) : Inhabited α :=
  ⟨e.symm default⟩
#align equiv.inhabited Equiv.inhabited
-/

#print Equiv.unique /-
/-- If `α ≃ β` and `β` is a singleton type, then so is `α`. -/
protected def unique [Unique β] (e : α ≃ β) : Unique α :=
  e.symm.Surjective.unique
#align equiv.unique Equiv.unique
-/

#print Equiv.cast /-
/-- Equivalence between equal types. -/
protected def cast {α β : Sort _} (h : α = β) : α ≃ β :=
  ⟨cast h, cast h.symm, fun x => by cases h; rfl, fun x => by cases h; rfl⟩
#align equiv.cast Equiv.cast
-/

#print Equiv.coe_fn_symm_mk /-
@[simp]
theorem coe_fn_symm_mk (f : α → β) (g l r) : ((Equiv.mk f g l r).symm : β → α) = g :=
  rfl
#align equiv.coe_fn_symm_mk Equiv.coe_fn_symm_mk
-/

#print Equiv.coe_refl /-
@[simp]
theorem coe_refl : ⇑(Equiv.refl α) = id :=
  rfl
#align equiv.coe_refl Equiv.coe_refl
-/

#print Equiv.Perm.coe_subsingleton /-
/-- This cannot be a `simp` lemmas as it incorrectly matches against `e : α ≃ synonym α`, when
`synonym α` is semireducible. This makes a mess of `multiplicative.of_add` etc. -/
theorem Perm.coe_subsingleton {α : Type _} [Subsingleton α] (e : Perm α) : ⇑e = id := by
  rw [perm.subsingleton_eq_refl e, coe_refl]
#align equiv.perm.coe_subsingleton Equiv.Perm.coe_subsingleton
-/

#print Equiv.refl_apply /-
theorem refl_apply (x : α) : Equiv.refl α x = x :=
  rfl
#align equiv.refl_apply Equiv.refl_apply
-/

#print Equiv.coe_trans /-
@[simp]
theorem coe_trans (f : α ≃ β) (g : β ≃ γ) : ⇑(f.trans g) = g ∘ f :=
  rfl
#align equiv.coe_trans Equiv.coe_trans
-/

#print Equiv.trans_apply /-
theorem trans_apply (f : α ≃ β) (g : β ≃ γ) (a : α) : (f.trans g) a = g (f a) :=
  rfl
#align equiv.trans_apply Equiv.trans_apply
-/

#print Equiv.apply_symm_apply /-
@[simp]
theorem apply_symm_apply (e : α ≃ β) (x : β) : e (e.symm x) = x :=
  e.right_inv x
#align equiv.apply_symm_apply Equiv.apply_symm_apply
-/

#print Equiv.symm_apply_apply /-
@[simp]
theorem symm_apply_apply (e : α ≃ β) (x : α) : e.symm (e x) = x :=
  e.left_inv x
#align equiv.symm_apply_apply Equiv.symm_apply_apply
-/

#print Equiv.symm_comp_self /-
@[simp]
theorem symm_comp_self (e : α ≃ β) : e.symm ∘ e = id :=
  funext e.symm_apply_apply
#align equiv.symm_comp_self Equiv.symm_comp_self
-/

#print Equiv.self_comp_symm /-
@[simp]
theorem self_comp_symm (e : α ≃ β) : e ∘ e.symm = id :=
  funext e.apply_symm_apply
#align equiv.self_comp_symm Equiv.self_comp_symm
-/

#print Equiv.symm_trans_apply /-
@[simp]
theorem symm_trans_apply (f : α ≃ β) (g : β ≃ γ) (a : γ) : (f.trans g).symm a = f.symm (g.symm a) :=
  rfl
#align equiv.symm_trans_apply Equiv.symm_trans_apply
-/

#print Equiv.symm_symm_apply /-
-- The `simp` attribute is needed to make this a `dsimp` lemma.
-- `simp` will always rewrite with `equiv.symm_symm` before this has a chance to fire.
@[simp, nolint simp_nf]
theorem symm_symm_apply (f : α ≃ β) (b : α) : f.symm.symm b = f b :=
  rfl
#align equiv.symm_symm_apply Equiv.symm_symm_apply
-/

#print Equiv.apply_eq_iff_eq /-
theorem apply_eq_iff_eq (f : α ≃ β) {x y : α} : f x = f y ↔ x = y :=
  EquivLike.apply_eq_iff_eq f
#align equiv.apply_eq_iff_eq Equiv.apply_eq_iff_eq
-/

#print Equiv.apply_eq_iff_eq_symm_apply /-
theorem apply_eq_iff_eq_symm_apply {α β : Sort _} (f : α ≃ β) {x : α} {y : β} :
    f x = y ↔ x = f.symm y := by
  conv_lhs => rw [← apply_symm_apply f y]
  rw [apply_eq_iff_eq]
#align equiv.apply_eq_iff_eq_symm_apply Equiv.apply_eq_iff_eq_symm_apply
-/

#print Equiv.cast_apply /-
@[simp]
theorem cast_apply {α β} (h : α = β) (x : α) : Equiv.cast h x = cast h x :=
  rfl
#align equiv.cast_apply Equiv.cast_apply
-/

#print Equiv.cast_symm /-
@[simp]
theorem cast_symm {α β} (h : α = β) : (Equiv.cast h).symm = Equiv.cast h.symm :=
  rfl
#align equiv.cast_symm Equiv.cast_symm
-/

#print Equiv.cast_refl /-
@[simp]
theorem cast_refl {α} (h : α = α := rfl) : Equiv.cast h = Equiv.refl α :=
  rfl
#align equiv.cast_refl Equiv.cast_refl
-/

#print Equiv.cast_trans /-
@[simp]
theorem cast_trans {α β γ} (h : α = β) (h2 : β = γ) :
    (Equiv.cast h).trans (Equiv.cast h2) = Equiv.cast (h.trans h2) :=
  ext fun x => by substs h h2; rfl
#align equiv.cast_trans Equiv.cast_trans
-/

#print Equiv.cast_eq_iff_heq /-
theorem cast_eq_iff_heq {α β} (h : α = β) {a : α} {b : β} : Equiv.cast h a = b ↔ HEq a b := by
  subst h; simp
#align equiv.cast_eq_iff_heq Equiv.cast_eq_iff_heq
-/

#print Equiv.symm_apply_eq /-
theorem symm_apply_eq {α β} (e : α ≃ β) {x y} : e.symm x = y ↔ x = e y :=
  ⟨fun H => by simp [H.symm], fun H => by simp [H]⟩
#align equiv.symm_apply_eq Equiv.symm_apply_eq
-/

#print Equiv.eq_symm_apply /-
theorem eq_symm_apply {α β} (e : α ≃ β) {x y} : y = e.symm x ↔ e y = x :=
  (eq_comm.trans e.symm_apply_eq).trans eq_comm
#align equiv.eq_symm_apply Equiv.eq_symm_apply
-/

#print Equiv.symm_symm /-
@[simp]
theorem symm_symm (e : α ≃ β) : e.symm.symm = e := by cases e; rfl
#align equiv.symm_symm Equiv.symm_symm
-/

#print Equiv.trans_refl /-
@[simp]
theorem trans_refl (e : α ≃ β) : e.trans (Equiv.refl β) = e := by cases e; rfl
#align equiv.trans_refl Equiv.trans_refl
-/

#print Equiv.refl_symm /-
@[simp]
theorem refl_symm : (Equiv.refl α).symm = Equiv.refl α :=
  rfl
#align equiv.refl_symm Equiv.refl_symm
-/

#print Equiv.refl_trans /-
@[simp]
theorem refl_trans (e : α ≃ β) : (Equiv.refl α).trans e = e := by cases e; rfl
#align equiv.refl_trans Equiv.refl_trans
-/

#print Equiv.symm_trans_self /-
@[simp]
theorem symm_trans_self (e : α ≃ β) : e.symm.trans e = Equiv.refl β :=
  ext (by simp)
#align equiv.symm_trans_self Equiv.symm_trans_self
-/

#print Equiv.self_trans_symm /-
@[simp]
theorem self_trans_symm (e : α ≃ β) : e.trans e.symm = Equiv.refl α :=
  ext (by simp)
#align equiv.self_trans_symm Equiv.self_trans_symm
-/

#print Equiv.trans_assoc /-
theorem trans_assoc {δ} (ab : α ≃ β) (bc : β ≃ γ) (cd : γ ≃ δ) :
    (ab.trans bc).trans cd = ab.trans (bc.trans cd) :=
  Equiv.ext fun a => rfl
#align equiv.trans_assoc Equiv.trans_assoc
-/

#print Equiv.leftInverse_symm /-
theorem leftInverse_symm (f : Equiv α β) : LeftInverse f.symm f :=
  f.left_inv
#align equiv.left_inverse_symm Equiv.leftInverse_symm
-/

#print Equiv.rightInverse_symm /-
theorem rightInverse_symm (f : Equiv α β) : Function.RightInverse f.symm f :=
  f.right_inv
#align equiv.right_inverse_symm Equiv.rightInverse_symm
-/

#print Equiv.injective_comp /-
theorem injective_comp (e : α ≃ β) (f : β → γ) : Injective (f ∘ e) ↔ Injective f :=
  EquivLike.injective_comp e f
#align equiv.injective_comp Equiv.injective_comp
-/

#print Equiv.comp_injective /-
theorem comp_injective (f : α → β) (e : β ≃ γ) : Injective (e ∘ f) ↔ Injective f :=
  EquivLike.comp_injective f e
#align equiv.comp_injective Equiv.comp_injective
-/

#print Equiv.surjective_comp /-
theorem surjective_comp (e : α ≃ β) (f : β → γ) : Surjective (f ∘ e) ↔ Surjective f :=
  EquivLike.surjective_comp e f
#align equiv.surjective_comp Equiv.surjective_comp
-/

#print Equiv.comp_surjective /-
theorem comp_surjective (f : α → β) (e : β ≃ γ) : Surjective (e ∘ f) ↔ Surjective f :=
  EquivLike.comp_surjective f e
#align equiv.comp_surjective Equiv.comp_surjective
-/

#print Equiv.bijective_comp /-
theorem bijective_comp (e : α ≃ β) (f : β → γ) : Bijective (f ∘ e) ↔ Bijective f :=
  EquivLike.bijective_comp e f
#align equiv.bijective_comp Equiv.bijective_comp
-/

#print Equiv.comp_bijective /-
theorem comp_bijective (f : α → β) (e : β ≃ γ) : Bijective (e ∘ f) ↔ Bijective f :=
  EquivLike.comp_bijective f e
#align equiv.comp_bijective Equiv.comp_bijective
-/

#print Equiv.equivCongr /-
/-- If `α` is equivalent to `β` and `γ` is equivalent to `δ`, then the type of equivalences `α ≃ γ`
is equivalent to the type of equivalences `β ≃ δ`. -/
def equivCongr {δ} (ab : α ≃ β) (cd : γ ≃ δ) : α ≃ γ ≃ (β ≃ δ) :=
  ⟨fun ac => (ab.symm.trans ac).trans cd, fun bd => ab.trans <| bd.trans <| cd.symm, fun ac => by
    ext x; simp, fun ac => by ext x; simp⟩
#align equiv.equiv_congr Equiv.equivCongr
-/

#print Equiv.equivCongr_refl /-
@[simp]
theorem equivCongr_refl {α β} : (Equiv.refl α).equivCongr (Equiv.refl β) = Equiv.refl (α ≃ β) := by
  ext; rfl
#align equiv.equiv_congr_refl Equiv.equivCongr_refl
-/

#print Equiv.equivCongr_symm /-
@[simp]
theorem equivCongr_symm {δ} (ab : α ≃ β) (cd : γ ≃ δ) :
    (ab.equivCongr cd).symm = ab.symm.equivCongr cd.symm := by ext; rfl
#align equiv.equiv_congr_symm Equiv.equivCongr_symm
-/

#print Equiv.equivCongr_trans /-
@[simp]
theorem equivCongr_trans {δ ε ζ} (ab : α ≃ β) (de : δ ≃ ε) (bc : β ≃ γ) (ef : ε ≃ ζ) :
    (ab.equivCongr de).trans (bc.equivCongr ef) = (ab.trans bc).equivCongr (de.trans ef) := by ext;
  rfl
#align equiv.equiv_congr_trans Equiv.equivCongr_trans
-/

#print Equiv.equivCongr_refl_left /-
@[simp]
theorem equivCongr_refl_left {α β γ} (bg : β ≃ γ) (e : α ≃ β) :
    (Equiv.refl α).equivCongr bg e = e.trans bg :=
  rfl
#align equiv.equiv_congr_refl_left Equiv.equivCongr_refl_left
-/

#print Equiv.equivCongr_refl_right /-
@[simp]
theorem equivCongr_refl_right {α β} (ab e : α ≃ β) :
    ab.equivCongr (Equiv.refl β) e = ab.symm.trans e :=
  rfl
#align equiv.equiv_congr_refl_right Equiv.equivCongr_refl_right
-/

#print Equiv.equivCongr_apply_apply /-
@[simp]
theorem equivCongr_apply_apply {δ} (ab : α ≃ β) (cd : γ ≃ δ) (e : α ≃ γ) (x) :
    ab.equivCongr cd e x = cd (e (ab.symm x)) :=
  rfl
#align equiv.equiv_congr_apply_apply Equiv.equivCongr_apply_apply
-/

section PermCongr

variable {α' β' : Type _} (e : α' ≃ β')

#print Equiv.permCongr /-
/-- If `α` is equivalent to `β`, then `perm α` is equivalent to `perm β`. -/
def permCongr : Perm α' ≃ Perm β' :=
  equivCongr e e
#align equiv.perm_congr Equiv.permCongr
-/

#print Equiv.permCongr_def /-
theorem permCongr_def (p : Equiv.Perm α') : e.permCongr p = (e.symm.trans p).trans e :=
  rfl
#align equiv.perm_congr_def Equiv.permCongr_def
-/

#print Equiv.permCongr_refl /-
@[simp]
theorem permCongr_refl : e.permCongr (Equiv.refl _) = Equiv.refl _ := by simp [perm_congr_def]
#align equiv.perm_congr_refl Equiv.permCongr_refl
-/

#print Equiv.permCongr_symm /-
@[simp]
theorem permCongr_symm : e.permCongr.symm = e.symm.permCongr :=
  rfl
#align equiv.perm_congr_symm Equiv.permCongr_symm
-/

#print Equiv.permCongr_apply /-
@[simp]
theorem permCongr_apply (p : Equiv.Perm α') (x) : e.permCongr p x = e (p (e.symm x)) :=
  rfl
#align equiv.perm_congr_apply Equiv.permCongr_apply
-/

#print Equiv.permCongr_symm_apply /-
theorem permCongr_symm_apply (p : Equiv.Perm β') (x) : e.permCongr.symm p x = e.symm (p (e x)) :=
  rfl
#align equiv.perm_congr_symm_apply Equiv.permCongr_symm_apply
-/

#print Equiv.permCongr_trans /-
theorem permCongr_trans (p p' : Equiv.Perm α') :
    (e.permCongr p).trans (e.permCongr p') = e.permCongr (p.trans p') := by ext; simp
#align equiv.perm_congr_trans Equiv.permCongr_trans
-/

end PermCongr

#print Equiv.equivOfIsEmpty /-
/-- Two empty types are equivalent. -/
def equivOfIsEmpty (α β : Sort _) [IsEmpty α] [IsEmpty β] : α ≃ β :=
  ⟨isEmptyElim, isEmptyElim, isEmptyElim, isEmptyElim⟩
#align equiv.equiv_of_is_empty Equiv.equivOfIsEmpty
-/

#print Equiv.equivEmpty /-
/-- If `α` is an empty type, then it is equivalent to the `empty` type. -/
def equivEmpty (α : Sort u) [IsEmpty α] : α ≃ Empty :=
  equivOfIsEmpty α _
#align equiv.equiv_empty Equiv.equivEmpty
-/

#print Equiv.equivPEmpty /-
/-- If `α` is an empty type, then it is equivalent to the `pempty` type in any universe. -/
def equivPEmpty (α : Sort v) [IsEmpty α] : α ≃ PEmpty.{u} :=
  equivOfIsEmpty α _
#align equiv.equiv_pempty Equiv.equivPEmpty
-/

#print Equiv.equivEmptyEquiv /-
/-- `α` is equivalent to an empty type iff `α` is empty. -/
def equivEmptyEquiv (α : Sort u) : α ≃ Empty ≃ IsEmpty α :=
  ⟨fun e => Function.isEmpty e, @equivEmpty α, fun e => ext fun x => (e x).elim, fun p => rfl⟩
#align equiv.equiv_empty_equiv Equiv.equivEmptyEquiv
-/

#print Equiv.propEquivPEmpty /-
/-- The `Sort` of proofs of a false proposition is equivalent to `pempty`. -/
def propEquivPEmpty {p : Prop} (h : ¬p) : p ≃ PEmpty :=
  @equivPEmpty p <| IsEmpty.prop_iff.2 h
#align equiv.prop_equiv_pempty Equiv.propEquivPEmpty
-/

#print Equiv.equivOfUnique /-
/-- If both `α` and `β` have a unique element, then `α ≃ β`. -/
def equivOfUnique (α β : Sort _) [Unique α] [Unique β] : α ≃ β
    where
  toFun := default
  invFun := default
  left_inv _ := Subsingleton.elim _ _
  right_inv _ := Subsingleton.elim _ _
#align equiv.equiv_of_unique Equiv.equivOfUnique
-/

#print Equiv.equivPUnit /-
/-- If `α` has a unique element, then it is equivalent to any `punit`. -/
def equivPUnit (α : Sort _) [Unique α] : α ≃ PUnit.{v} :=
  equivOfUnique α _
#align equiv.equiv_punit Equiv.equivPUnit
-/

#print Equiv.propEquivPUnit /-
/-- The `Sort` of proofs of a true proposition is equivalent to `punit`. -/
def propEquivPUnit {p : Prop} (h : p) : p ≃ PUnit :=
  @equivPUnit p <| uniqueProp h
#align equiv.prop_equiv_punit Equiv.propEquivPUnit
-/

#print Equiv.ulift /-
/-- `ulift α` is equivalent to `α`. -/
@[simps (config := { fullyApplied := false }) apply symm_apply]
protected def ulift {α : Type v} : ULift.{u} α ≃ α :=
  ⟨ULift.down, ULift.up, ULift.up_down, fun a => rfl⟩
#align equiv.ulift Equiv.ulift
-/

#print Equiv.plift /-
/-- `plift α` is equivalent to `α`. -/
@[simps (config := { fullyApplied := false }) apply symm_apply]
protected def plift : PLift α ≃ α :=
  ⟨PLift.down, PLift.up, PLift.up_down, PLift.down_up⟩
#align equiv.plift Equiv.plift
-/

#print Equiv.ofIff /-
/-- equivalence of propositions is the same as iff -/
def ofIff {P Q : Prop} (h : P ↔ Q) : P ≃ Q
    where
  toFun := h.mp
  invFun := h.mpr
  left_inv x := rfl
  right_inv y := rfl
#align equiv.of_iff Equiv.ofIff
-/

#print Equiv.arrowCongr /-
/-- If `α₁` is equivalent to `α₂` and `β₁` is equivalent to `β₂`, then the type of maps `α₁ → β₁`
is equivalent to the type of maps `α₂ → β₂`. -/
@[congr, simps apply]
def arrowCongr {α₁ β₁ α₂ β₂ : Sort _} (e₁ : α₁ ≃ α₂) (e₂ : β₁ ≃ β₂) : (α₁ → β₁) ≃ (α₂ → β₂)
    where
  toFun f := e₂ ∘ f ∘ e₁.symm
  invFun f := e₂.symm ∘ f ∘ e₁
  left_inv f := funext fun x => by simp
  right_inv f := funext fun x => by simp
#align equiv.arrow_congr Equiv.arrowCongr
-/

#print Equiv.arrowCongr_comp /-
theorem arrowCongr_comp {α₁ β₁ γ₁ α₂ β₂ γ₂ : Sort _} (ea : α₁ ≃ α₂) (eb : β₁ ≃ β₂) (ec : γ₁ ≃ γ₂)
    (f : α₁ → β₁) (g : β₁ → γ₁) :
    arrowCongr ea ec (g ∘ f) = arrowCongr eb ec g ∘ arrowCongr ea eb f := by ext;
  simp only [comp, arrow_congr_apply, eb.symm_apply_apply]
#align equiv.arrow_congr_comp Equiv.arrowCongr_comp
-/

#print Equiv.arrowCongr_refl /-
@[simp]
theorem arrowCongr_refl {α β : Sort _} :
    arrowCongr (Equiv.refl α) (Equiv.refl β) = Equiv.refl (α → β) :=
  rfl
#align equiv.arrow_congr_refl Equiv.arrowCongr_refl
-/

#print Equiv.arrowCongr_trans /-
@[simp]
theorem arrowCongr_trans {α₁ β₁ α₂ β₂ α₃ β₃ : Sort _} (e₁ : α₁ ≃ α₂) (e₁' : β₁ ≃ β₂) (e₂ : α₂ ≃ α₃)
    (e₂' : β₂ ≃ β₃) :
    arrowCongr (e₁.trans e₂) (e₁'.trans e₂') = (arrowCongr e₁ e₁').trans (arrowCongr e₂ e₂') :=
  rfl
#align equiv.arrow_congr_trans Equiv.arrowCongr_trans
-/

#print Equiv.arrowCongr_symm /-
@[simp]
theorem arrowCongr_symm {α₁ β₁ α₂ β₂ : Sort _} (e₁ : α₁ ≃ α₂) (e₂ : β₁ ≃ β₂) :
    (arrowCongr e₁ e₂).symm = arrowCongr e₁.symm e₂.symm :=
  rfl
#align equiv.arrow_congr_symm Equiv.arrowCongr_symm
-/

#print Equiv.arrowCongr' /-
/-- A version of `equiv.arrow_congr` in `Type`, rather than `Sort`.

The `equiv_rw` tactic is not able to use the default `Sort` level `equiv.arrow_congr`,
because Lean's universe rules will not unify `?l_1` with `imax (1 ?m_1)`.
-/
@[congr, simps apply]
def arrowCongr' {α₁ β₁ α₂ β₂ : Type _} (hα : α₁ ≃ α₂) (hβ : β₁ ≃ β₂) : (α₁ → β₁) ≃ (α₂ → β₂) :=
  Equiv.arrowCongr hα hβ
#align equiv.arrow_congr' Equiv.arrowCongr'
-/

#print Equiv.arrowCongr'_refl /-
@[simp]
theorem arrowCongr'_refl {α β : Type _} :
    arrowCongr' (Equiv.refl α) (Equiv.refl β) = Equiv.refl (α → β) :=
  rfl
#align equiv.arrow_congr'_refl Equiv.arrowCongr'_refl
-/

#print Equiv.arrowCongr'_trans /-
@[simp]
theorem arrowCongr'_trans {α₁ β₁ α₂ β₂ α₃ β₃ : Type _} (e₁ : α₁ ≃ α₂) (e₁' : β₁ ≃ β₂) (e₂ : α₂ ≃ α₃)
    (e₂' : β₂ ≃ β₃) :
    arrowCongr' (e₁.trans e₂) (e₁'.trans e₂') = (arrowCongr' e₁ e₁').trans (arrowCongr' e₂ e₂') :=
  rfl
#align equiv.arrow_congr'_trans Equiv.arrowCongr'_trans
-/

#print Equiv.arrowCongr'_symm /-
@[simp]
theorem arrowCongr'_symm {α₁ β₁ α₂ β₂ : Type _} (e₁ : α₁ ≃ α₂) (e₂ : β₁ ≃ β₂) :
    (arrowCongr' e₁ e₂).symm = arrowCongr' e₁.symm e₂.symm :=
  rfl
#align equiv.arrow_congr'_symm Equiv.arrowCongr'_symm
-/

#print Equiv.conj /-
/-- Conjugate a map `f : α → α` by an equivalence `α ≃ β`. -/
@[simps apply]
def conj (e : α ≃ β) : (α → α) ≃ (β → β) :=
  arrowCongr e e
#align equiv.conj Equiv.conj
-/

#print Equiv.conj_refl /-
@[simp]
theorem conj_refl : conj (Equiv.refl α) = Equiv.refl (α → α) :=
  rfl
#align equiv.conj_refl Equiv.conj_refl
-/

#print Equiv.conj_symm /-
@[simp]
theorem conj_symm (e : α ≃ β) : e.conj.symm = e.symm.conj :=
  rfl
#align equiv.conj_symm Equiv.conj_symm
-/

#print Equiv.conj_trans /-
@[simp]
theorem conj_trans (e₁ : α ≃ β) (e₂ : β ≃ γ) : (e₁.trans e₂).conj = e₁.conj.trans e₂.conj :=
  rfl
#align equiv.conj_trans Equiv.conj_trans
-/

#print Equiv.conj_comp /-
-- This should not be a simp lemma as long as `(∘)` is reducible:
-- when `(∘)` is reducible, Lean can unify `f₁ ∘ f₂` with any `g` using
-- `f₁ := g` and `f₂ := λ x, x`.  This causes nontermination.
theorem conj_comp (e : α ≃ β) (f₁ f₂ : α → α) : e.conj (f₁ ∘ f₂) = e.conj f₁ ∘ e.conj f₂ := by
  apply arrow_congr_comp
#align equiv.conj_comp Equiv.conj_comp
-/

#print Equiv.eq_comp_symm /-
theorem eq_comp_symm {α β γ} (e : α ≃ β) (f : β → γ) (g : α → γ) : f = g ∘ e.symm ↔ f ∘ e = g :=
  (e.arrowCongr (Equiv.refl γ)).symm_apply_eq.symm
#align equiv.eq_comp_symm Equiv.eq_comp_symm
-/

#print Equiv.comp_symm_eq /-
theorem comp_symm_eq {α β γ} (e : α ≃ β) (f : β → γ) (g : α → γ) : g ∘ e.symm = f ↔ g = f ∘ e :=
  (e.arrowCongr (Equiv.refl γ)).eq_symm_apply.symm
#align equiv.comp_symm_eq Equiv.comp_symm_eq
-/

#print Equiv.eq_symm_comp /-
theorem eq_symm_comp {α β γ} (e : α ≃ β) (f : γ → α) (g : γ → β) : f = e.symm ∘ g ↔ e ∘ f = g :=
  ((Equiv.refl γ).arrowCongr e).eq_symm_apply
#align equiv.eq_symm_comp Equiv.eq_symm_comp
-/

#print Equiv.symm_comp_eq /-
theorem symm_comp_eq {α β γ} (e : α ≃ β) (f : γ → α) (g : γ → β) : e.symm ∘ g = f ↔ g = e ∘ f :=
  ((Equiv.refl γ).arrowCongr e).symm_apply_eq
#align equiv.symm_comp_eq Equiv.symm_comp_eq
-/

#print Equiv.punitEquivPUnit /-
/-- `punit` sorts in any two universes are equivalent. -/
def punitEquivPUnit : PUnit.{v} ≃ PUnit.{w} :=
  ⟨fun _ => PUnit.unit, fun _ => PUnit.unit, fun u => by cases u; rfl, fun u => by cases u; rfl⟩
#align equiv.punit_equiv_punit Equiv.punitEquivPUnit
-/

#print Equiv.propEquivBool /-
/-- `Prop` is noncomputably equivalent to `bool`. -/
noncomputable def propEquivBool : Prop ≃ Bool :=
  ⟨fun p => @decide p (Classical.propDecidable _), fun b => b, fun p => by simp, fun b => by simp⟩
#align equiv.Prop_equiv_bool Equiv.propEquivBool
-/

section

#print Equiv.arrowPUnitEquivPUnit /-
/-- The sort of maps to `punit.{v}` is equivalent to `punit.{w}`. -/
def arrowPUnitEquivPUnit (α : Sort _) : (α → PUnit.{v}) ≃ PUnit.{w} :=
  ⟨fun f => PUnit.unit, fun u f => PUnit.unit, fun f => by funext x; cases f x; rfl, fun u => by
    cases u; rfl⟩
#align equiv.arrow_punit_equiv_punit Equiv.arrowPUnitEquivPUnit
-/

#print Equiv.piSubsingleton /-
/-- If `α` is `subsingleton` and `a : α`, then the type of dependent functions `Π (i : α), β
i` is equivalent to `β i`. -/
@[simps]
def piSubsingleton {α} (β : α → Sort _) [Subsingleton α] (a : α) : (∀ a', β a') ≃ β a
    where
  toFun := eval a
  invFun x b := cast (congr_arg β <| Subsingleton.elim a b) x
  left_inv f := funext fun b => by rw [Subsingleton.elim b a]; rfl
  right_inv b := rfl
#align equiv.Pi_subsingleton Equiv.piSubsingleton
-/

#print Equiv.funUnique /-
/-- If `α` has a unique term, then the type of function `α → β` is equivalent to `β`. -/
@[simps (config := { fullyApplied := false })]
def funUnique (α β) [Unique α] : (α → β) ≃ β :=
  piSubsingleton _ default
#align equiv.fun_unique Equiv.funUnique
-/

#print Equiv.punitArrowEquiv /-
/-- The sort of maps from `punit` is equivalent to the codomain. -/
def punitArrowEquiv (α : Sort _) : (PUnit.{u} → α) ≃ α :=
  funUnique _ _
#align equiv.punit_arrow_equiv Equiv.punitArrowEquiv
-/

#print Equiv.trueArrowEquiv /-
/-- The sort of maps from `true` is equivalent to the codomain. -/
def trueArrowEquiv (α : Sort _) : (True → α) ≃ α :=
  funUnique _ _
#align equiv.true_arrow_equiv Equiv.trueArrowEquiv
-/

#print Equiv.arrowPUnitOfIsEmpty /-
/-- The sort of maps from a type that `is_empty` is equivalent to `punit`. -/
def arrowPUnitOfIsEmpty (α β : Sort _) [IsEmpty α] : (α → β) ≃ PUnit.{u} :=
  ⟨fun f => PUnit.unit, fun u => isEmptyElim, fun f => funext isEmptyElim, fun u => by cases u; rfl⟩
#align equiv.arrow_punit_of_is_empty Equiv.arrowPUnitOfIsEmpty
-/

#print Equiv.emptyArrowEquivPUnit /-
/-- The sort of maps from `empty` is equivalent to `punit`. -/
def emptyArrowEquivPUnit (α : Sort _) : (Empty → α) ≃ PUnit.{u} :=
  arrowPUnitOfIsEmpty _ _
#align equiv.empty_arrow_equiv_punit Equiv.emptyArrowEquivPUnit
-/

#print Equiv.pemptyArrowEquivPUnit /-
/-- The sort of maps from `pempty` is equivalent to `punit`. -/
def pemptyArrowEquivPUnit (α : Sort _) : (PEmpty → α) ≃ PUnit.{u} :=
  arrowPUnitOfIsEmpty _ _
#align equiv.pempty_arrow_equiv_punit Equiv.pemptyArrowEquivPUnit
-/

#print Equiv.falseArrowEquivPUnit /-
/-- The sort of maps from `false` is equivalent to `punit`. -/
def falseArrowEquivPUnit (α : Sort _) : (False → α) ≃ PUnit.{u} :=
  arrowPUnitOfIsEmpty _ _
#align equiv.false_arrow_equiv_punit Equiv.falseArrowEquivPUnit
-/

end

section

#print Equiv.psigmaEquivSigma /-
/-- A `psigma`-type is equivalent to the corresponding `sigma`-type. -/
@[simps apply symm_apply]
def psigmaEquivSigma {α} (β : α → Type _) : (Σ' i, β i) ≃ Σ i, β i :=
  ⟨fun a => ⟨a.1, a.2⟩, fun a => ⟨a.1, a.2⟩, fun ⟨a, b⟩ => rfl, fun ⟨a, b⟩ => rfl⟩
#align equiv.psigma_equiv_sigma Equiv.psigmaEquivSigma
-/

#print Equiv.psigmaEquivSigmaPLift /-
/-- A `psigma`-type is equivalent to the corresponding `sigma`-type. -/
@[simps apply symm_apply]
def psigmaEquivSigmaPLift {α} (β : α → Sort _) : (Σ' i, β i) ≃ Σ i : PLift α, PLift (β i.down) :=
  ⟨fun a => ⟨PLift.up a.1, PLift.up a.2⟩, fun a => ⟨a.1.down, a.2.down⟩, fun ⟨a, b⟩ => rfl,
    fun ⟨⟨a⟩, ⟨b⟩⟩ => rfl⟩
#align equiv.psigma_equiv_sigma_plift Equiv.psigmaEquivSigmaPLift
-/

#print Equiv.psigmaCongrRight /-
/-- A family of equivalences `Π a, β₁ a ≃ β₂ a` generates an equivalence between `Σ' a, β₁ a` and
`Σ' a, β₂ a`. -/
@[simps apply]
def psigmaCongrRight {α} {β₁ β₂ : α → Sort _} (F : ∀ a, β₁ a ≃ β₂ a) : (Σ' a, β₁ a) ≃ Σ' a, β₂ a :=
  ⟨fun a => ⟨a.1, F a.1 a.2⟩, fun a => ⟨a.1, (F a.1).symm a.2⟩, fun ⟨a, b⟩ =>
    congr_arg (PSigma.mk a) <| symm_apply_apply (F a) b, fun ⟨a, b⟩ =>
    congr_arg (PSigma.mk a) <| apply_symm_apply (F a) b⟩
#align equiv.psigma_congr_right Equiv.psigmaCongrRight
-/

#print Equiv.psigmaCongrRight_trans /-
@[simp]
theorem psigmaCongrRight_trans {α} {β₁ β₂ β₃ : α → Sort _} (F : ∀ a, β₁ a ≃ β₂ a)
    (G : ∀ a, β₂ a ≃ β₃ a) :
    (psigmaCongrRight F).trans (psigmaCongrRight G) = psigmaCongrRight fun a => (F a).trans (G a) :=
  by ext1 x; cases x; rfl
#align equiv.psigma_congr_right_trans Equiv.psigmaCongrRight_trans
-/

#print Equiv.psigmaCongrRight_symm /-
@[simp]
theorem psigmaCongrRight_symm {α} {β₁ β₂ : α → Sort _} (F : ∀ a, β₁ a ≃ β₂ a) :
    (psigmaCongrRight F).symm = psigmaCongrRight fun a => (F a).symm := by ext1 x; cases x; rfl
#align equiv.psigma_congr_right_symm Equiv.psigmaCongrRight_symm
-/

#print Equiv.psigmaCongrRight_refl /-
@[simp]
theorem psigmaCongrRight_refl {α} {β : α → Sort _} :
    (psigmaCongrRight fun a => Equiv.refl (β a)) = Equiv.refl (Σ' a, β a) := by ext1 x; cases x; rfl
#align equiv.psigma_congr_right_refl Equiv.psigmaCongrRight_refl
-/

#print Equiv.sigmaCongrRight /-
/-- A family of equivalences `Π a, β₁ a ≃ β₂ a` generates an equivalence between `Σ a, β₁ a` and
`Σ a, β₂ a`. -/
@[simps apply]
def sigmaCongrRight {α} {β₁ β₂ : α → Type _} (F : ∀ a, β₁ a ≃ β₂ a) : (Σ a, β₁ a) ≃ Σ a, β₂ a :=
  ⟨fun a => ⟨a.1, F a.1 a.2⟩, fun a => ⟨a.1, (F a.1).symm a.2⟩, fun ⟨a, b⟩ =>
    congr_arg (Sigma.mk a) <| symm_apply_apply (F a) b, fun ⟨a, b⟩ =>
    congr_arg (Sigma.mk a) <| apply_symm_apply (F a) b⟩
#align equiv.sigma_congr_right Equiv.sigmaCongrRight
-/

#print Equiv.sigmaCongrRight_trans /-
@[simp]
theorem sigmaCongrRight_trans {α} {β₁ β₂ β₃ : α → Type _} (F : ∀ a, β₁ a ≃ β₂ a)
    (G : ∀ a, β₂ a ≃ β₃ a) :
    (sigmaCongrRight F).trans (sigmaCongrRight G) = sigmaCongrRight fun a => (F a).trans (G a) := by
  ext1 x; cases x; rfl
#align equiv.sigma_congr_right_trans Equiv.sigmaCongrRight_trans
-/

#print Equiv.sigmaCongrRight_symm /-
@[simp]
theorem sigmaCongrRight_symm {α} {β₁ β₂ : α → Type _} (F : ∀ a, β₁ a ≃ β₂ a) :
    (sigmaCongrRight F).symm = sigmaCongrRight fun a => (F a).symm := by ext1 x; cases x; rfl
#align equiv.sigma_congr_right_symm Equiv.sigmaCongrRight_symm
-/

#print Equiv.sigmaCongrRight_refl /-
@[simp]
theorem sigmaCongrRight_refl {α} {β : α → Type _} :
    (sigmaCongrRight fun a => Equiv.refl (β a)) = Equiv.refl (Σ a, β a) := by ext1 x; cases x; rfl
#align equiv.sigma_congr_right_refl Equiv.sigmaCongrRight_refl
-/

#print Equiv.psigmaEquivSubtype /-
/-- A `psigma` with `Prop` fibers is equivalent to the subtype.  -/
def psigmaEquivSubtype {α : Type v} (P : α → Prop) : (Σ' i, P i) ≃ Subtype P
    where
  toFun x := ⟨x.1, x.2⟩
  invFun x := ⟨x.1, x.2⟩
  left_inv x := by cases x; rfl
  right_inv x := by cases x; rfl
#align equiv.psigma_equiv_subtype Equiv.psigmaEquivSubtype
-/

#print Equiv.sigmaPLiftEquivSubtype /-
/-- A `sigma` with `plift` fibers is equivalent to the subtype. -/
def sigmaPLiftEquivSubtype {α : Type v} (P : α → Prop) : (Σ i, PLift (P i)) ≃ Subtype P :=
  ((psigmaEquivSigma _).symm.trans (psigmaCongrRight fun a => Equiv.plift)).trans
    (psigmaEquivSubtype P)
#align equiv.sigma_plift_equiv_subtype Equiv.sigmaPLiftEquivSubtype
-/

#print Equiv.sigmaULiftPLiftEquivSubtype /-
/-- A `sigma` with `λ i, ulift (plift (P i))` fibers is equivalent to `{ x // P x }`.
Variant of `sigma_plift_equiv_subtype`.
-/
def sigmaULiftPLiftEquivSubtype {α : Type v} (P : α → Prop) :
    (Σ i, ULift (PLift (P i))) ≃ Subtype P :=
  (sigmaCongrRight fun a => Equiv.ulift).trans (sigmaPLiftEquivSubtype P)
#align equiv.sigma_ulift_plift_equiv_subtype Equiv.sigmaULiftPLiftEquivSubtype
-/

namespace Perm

#print Equiv.Perm.sigmaCongrRight /-
/-- A family of permutations `Π a, perm (β a)` generates a permuation `perm (Σ a, β₁ a)`. -/
@[reducible]
def sigmaCongrRight {α} {β : α → Sort _} (F : ∀ a, Perm (β a)) : Perm (Σ a, β a) :=
  Equiv.sigmaCongrRight F
#align equiv.perm.sigma_congr_right Equiv.Perm.sigmaCongrRight
-/

#print Equiv.Perm.sigmaCongrRight_trans /-
@[simp]
theorem sigmaCongrRight_trans {α} {β : α → Sort _} (F : ∀ a, Perm (β a)) (G : ∀ a, Perm (β a)) :
    (sigmaCongrRight F).trans (sigmaCongrRight G) = sigmaCongrRight fun a => (F a).trans (G a) :=
  Equiv.sigmaCongrRight_trans F G
#align equiv.perm.sigma_congr_right_trans Equiv.Perm.sigmaCongrRight_trans
-/

#print Equiv.Perm.sigmaCongrRight_symm /-
@[simp]
theorem sigmaCongrRight_symm {α} {β : α → Sort _} (F : ∀ a, Perm (β a)) :
    (sigmaCongrRight F).symm = sigmaCongrRight fun a => (F a).symm :=
  Equiv.sigmaCongrRight_symm F
#align equiv.perm.sigma_congr_right_symm Equiv.Perm.sigmaCongrRight_symm
-/

#print Equiv.Perm.sigmaCongrRight_refl /-
@[simp]
theorem sigmaCongrRight_refl {α} {β : α → Sort _} :
    (sigmaCongrRight fun a => Equiv.refl (β a)) = Equiv.refl (Σ a, β a) :=
  Equiv.sigmaCongrRight_refl
#align equiv.perm.sigma_congr_right_refl Equiv.Perm.sigmaCongrRight_refl
-/

end Perm

#print Equiv.sigmaCongrLeft /-
/-- An equivalence `f : α₁ ≃ α₂` generates an equivalence between `Σ a, β (f a)` and `Σ a, β a`. -/
@[simps apply]
def sigmaCongrLeft {α₁ α₂} {β : α₂ → Sort _} (e : α₁ ≃ α₂) : (Σ a : α₁, β (e a)) ≃ Σ a : α₂, β a :=
  ⟨fun a => ⟨e a.1, a.2⟩, fun a => ⟨e.symm a.1, @Eq.ndrec β a.2 (e.right_inv a.1).symm⟩,
    fun ⟨a, b⟩ =>
    match (motive :=
      ∀ (a') (h : a' = a), @Sigma.mk _ (β ∘ e) _ (@Eq.ndrec β b (congr_arg e h.symm)) = ⟨a, b⟩)
      e.symm (e a), e.left_inv a with
    | _, rfl => rfl,
    fun ⟨a, b⟩ =>
    match (motive := ∀ (a') (h : a' = a), Sigma.mk a' (@Eq.ndrec β b h.symm) = ⟨a, b⟩) e (e.symm a),
      _ with
    | _, rfl => rfl⟩
#align equiv.sigma_congr_left Equiv.sigmaCongrLeft
-/

#print Equiv.sigmaCongrLeft' /-
/-- Transporting a sigma type through an equivalence of the base -/
def sigmaCongrLeft' {α₁ α₂} {β : α₁ → Sort _} (f : α₁ ≃ α₂) :
    (Σ a : α₁, β a) ≃ Σ a : α₂, β (f.symm a) :=
  (sigmaCongrLeft f.symm).symm
#align equiv.sigma_congr_left' Equiv.sigmaCongrLeft'
-/

#print Equiv.sigmaCongr /-
/-- Transporting a sigma type through an equivalence of the base and a family of equivalences
of matching fibers -/
def sigmaCongr {α₁ α₂} {β₁ : α₁ → Sort _} {β₂ : α₂ → Sort _} (f : α₁ ≃ α₂)
    (F : ∀ a, β₁ a ≃ β₂ (f a)) : Sigma β₁ ≃ Sigma β₂ :=
  (sigmaCongrRight F).trans (sigmaCongrLeft f)
#align equiv.sigma_congr Equiv.sigmaCongr
-/

#print Equiv.sigmaEquivProd /-
/-- `sigma` type with a constant fiber is equivalent to the product. -/
@[simps apply symm_apply]
def sigmaEquivProd (α β : Type _) : (Σ _ : α, β) ≃ α × β :=
  ⟨fun a => ⟨a.1, a.2⟩, fun a => ⟨a.1, a.2⟩, fun ⟨a, b⟩ => rfl, fun ⟨a, b⟩ => rfl⟩
#align equiv.sigma_equiv_prod Equiv.sigmaEquivProd
-/

#print Equiv.sigmaEquivProdOfEquiv /-
/-- If each fiber of a `sigma` type is equivalent to a fixed type, then the sigma type
is equivalent to the product. -/
def sigmaEquivProdOfEquiv {α β} {β₁ : α → Sort _} (F : ∀ a, β₁ a ≃ β) : Sigma β₁ ≃ α × β :=
  (sigmaCongrRight F).trans (sigmaEquivProd α β)
#align equiv.sigma_equiv_prod_of_equiv Equiv.sigmaEquivProdOfEquiv
-/

#print Equiv.sigmaAssoc /-
/-- Dependent product of types is associative up to an equivalence. -/
def sigmaAssoc {α : Type _} {β : α → Type _} (γ : ∀ a : α, β a → Type _) :
    (Σ ab : Σ a : α, β a, γ ab.1 ab.2) ≃ Σ a : α, Σ b : β a, γ a b
    where
  toFun x := ⟨x.1.1, ⟨x.1.2, x.2⟩⟩
  invFun x := ⟨⟨x.1, x.2.1⟩, x.2.2⟩
  left_inv := fun ⟨⟨a, b⟩, c⟩ => rfl
  right_inv := fun ⟨a, ⟨b, c⟩⟩ => rfl
#align equiv.sigma_assoc Equiv.sigmaAssoc
-/

end

#print Equiv.exists_unique_congr /-
protected theorem exists_unique_congr {p : α → Prop} {q : β → Prop} (f : α ≃ β)
    (h : ∀ {x}, p x ↔ q (f x)) : (∃! x, p x) ↔ ∃! y, q y :=
  by
  constructor
  · rintro ⟨a, ha₁, ha₂⟩
    exact ⟨f a, h.1 ha₁, fun b hb => f.symm_apply_eq.1 (ha₂ (f.symm b) (h.2 (by simpa using hb)))⟩
  · rintro ⟨b, hb₁, hb₂⟩
    exact ⟨f.symm b, h.2 (by simpa using hb₁), fun y hy => (eq_symm_apply f).2 (hb₂ _ (h.1 hy))⟩
#align equiv.exists_unique_congr Equiv.exists_unique_congr
-/

#print Equiv.exists_unique_congr_left' /-
protected theorem exists_unique_congr_left' {p : α → Prop} (f : α ≃ β) :
    (∃! x, p x) ↔ ∃! y, p (f.symm y) :=
  Equiv.exists_unique_congr f fun x => by simp
#align equiv.exists_unique_congr_left' Equiv.exists_unique_congr_left'
-/

#print Equiv.exists_unique_congr_left /-
protected theorem exists_unique_congr_left {p : β → Prop} (f : α ≃ β) :
    (∃! x, p (f x)) ↔ ∃! y, p y :=
  (Equiv.exists_unique_congr_left' f.symm).symm
#align equiv.exists_unique_congr_left Equiv.exists_unique_congr_left
-/

#print Equiv.forall_congr /-
protected theorem forall_congr {p : α → Prop} {q : β → Prop} (f : α ≃ β)
    (h : ∀ {x}, p x ↔ q (f x)) : (∀ x, p x) ↔ ∀ y, q y :=
  by
  constructor <;> intro h₂ x
  · rw [← f.right_inv x]; apply h.mp; apply h₂
  apply h.mpr; apply h₂
#align equiv.forall_congr Equiv.forall_congr
-/

#print Equiv.forall_congr' /-
protected theorem forall_congr' {p : α → Prop} {q : β → Prop} (f : α ≃ β)
    (h : ∀ {x}, p (f.symm x) ↔ q x) : (∀ x, p x) ↔ ∀ y, q y :=
  (Equiv.forall_congr f.symm fun x => h.symm).symm
#align equiv.forall_congr' Equiv.forall_congr'
-/

-- We next build some higher arity versions of `equiv.forall_congr`.
-- Although they appear to just be repeated applications of `equiv.forall_congr`,
-- unification of metavariables works better with these versions.
-- In particular, they are necessary in `equiv_rw`.
-- (Stopping at ternary functions seems reasonable: at least in 1-categorical mathematics,
-- it's rare to have axioms involving more than 3 elements at once.)
universe ua1 ua2 ub1 ub2 ug1 ug2

variable {α₁ : Sort ua1} {α₂ : Sort ua2} {β₁ : Sort ub1} {β₂ : Sort ub2} {γ₁ : Sort ug1}
  {γ₂ : Sort ug2}

#print Equiv.forall₂_congr /-
protected theorem forall₂_congr {p : α₁ → β₁ → Prop} {q : α₂ → β₂ → Prop} (eα : α₁ ≃ α₂)
    (eβ : β₁ ≃ β₂) (h : ∀ {x y}, p x y ↔ q (eα x) (eβ y)) : (∀ x y, p x y) ↔ ∀ x y, q x y :=
  by
  apply Equiv.forall_congr
  intros
  apply Equiv.forall_congr
  intros
  apply h
#align equiv.forall₂_congr Equiv.forall₂_congr
-/

#print Equiv.forall₂_congr' /-
protected theorem forall₂_congr' {p : α₁ → β₁ → Prop} {q : α₂ → β₂ → Prop} (eα : α₁ ≃ α₂)
    (eβ : β₁ ≃ β₂) (h : ∀ {x y}, p (eα.symm x) (eβ.symm y) ↔ q x y) :
    (∀ x y, p x y) ↔ ∀ x y, q x y :=
  (Equiv.forall₂_congr eα.symm eβ.symm fun x y => h.symm).symm
#align equiv.forall₂_congr' Equiv.forall₂_congr'
-/

#print Equiv.forall₃_congr /-
protected theorem forall₃_congr {p : α₁ → β₁ → γ₁ → Prop} {q : α₂ → β₂ → γ₂ → Prop} (eα : α₁ ≃ α₂)
    (eβ : β₁ ≃ β₂) (eγ : γ₁ ≃ γ₂) (h : ∀ {x y z}, p x y z ↔ q (eα x) (eβ y) (eγ z)) :
    (∀ x y z, p x y z) ↔ ∀ x y z, q x y z :=
  by
  apply Equiv.forall₂_congr
  intros
  apply Equiv.forall_congr
  intros
  apply h
#align equiv.forall₃_congr Equiv.forall₃_congr
-/

#print Equiv.forall₃_congr' /-
protected theorem forall₃_congr' {p : α₁ → β₁ → γ₁ → Prop} {q : α₂ → β₂ → γ₂ → Prop} (eα : α₁ ≃ α₂)
    (eβ : β₁ ≃ β₂) (eγ : γ₁ ≃ γ₂) (h : ∀ {x y z}, p (eα.symm x) (eβ.symm y) (eγ.symm z) ↔ q x y z) :
    (∀ x y z, p x y z) ↔ ∀ x y z, q x y z :=
  (Equiv.forall₃_congr eα.symm eβ.symm eγ.symm fun x y z => h.symm).symm
#align equiv.forall₃_congr' Equiv.forall₃_congr'
-/

#print Equiv.forall_congr_left' /-
protected theorem forall_congr_left' {p : α → Prop} (f : α ≃ β) : (∀ x, p x) ↔ ∀ y, p (f.symm y) :=
  Equiv.forall_congr f fun x => by simp
#align equiv.forall_congr_left' Equiv.forall_congr_left'
-/

#print Equiv.forall_congr_left /-
protected theorem forall_congr_left {p : β → Prop} (f : α ≃ β) : (∀ x, p (f x)) ↔ ∀ y, p y :=
  (Equiv.forall_congr_left' f.symm).symm
#align equiv.forall_congr_left Equiv.forall_congr_left
-/

#print Equiv.exists_congr_left /-
protected theorem exists_congr_left {α β} (f : α ≃ β) {p : α → Prop} :
    (∃ a, p a) ↔ ∃ b, p (f.symm b) :=
  ⟨fun ⟨a, h⟩ => ⟨f a, by simpa using h⟩, fun ⟨b, h⟩ => ⟨_, h⟩⟩
#align equiv.exists_congr_left Equiv.exists_congr_left
-/

end Equiv

namespace Quot

#print Quot.congr /-
/-- An equivalence `e : α ≃ β` generates an equivalence between quotient spaces,
if `ra a₁ a₂ ↔ rb (e a₁) (e a₂). -/
protected def congr {ra : α → α → Prop} {rb : β → β → Prop} (e : α ≃ β)
    (eq : ∀ a₁ a₂, ra a₁ a₂ ↔ rb (e a₁) (e a₂)) : Quot ra ≃ Quot rb
    where
  toFun := Quot.map e fun a₁ a₂ => (Eq a₁ a₂).1
  invFun :=
    Quot.map e.symm fun b₁ b₂ h =>
      (Eq (e.symm b₁) (e.symm b₂)).2
        ((e.apply_symm_apply b₁).symm ▸ (e.apply_symm_apply b₂).symm ▸ h)
  left_inv := by rintro ⟨a⟩; dsimp only [Quot.map]; simp only [Equiv.symm_apply_apply]
  right_inv := by rintro ⟨a⟩; dsimp only [Quot.map]; simp only [Equiv.apply_symm_apply]
#align quot.congr Quot.congr
-/

#print Quot.congr_mk /-
@[simp]
theorem congr_mk {ra : α → α → Prop} {rb : β → β → Prop} (e : α ≃ β)
    (eq : ∀ a₁ a₂ : α, ra a₁ a₂ ↔ rb (e a₁) (e a₂)) (a : α) :
    Quot.congr e Eq (Quot.mk ra a) = Quot.mk rb (e a) :=
  rfl
#align quot.congr_mk Quot.congr_mk
-/

#print Quot.congrRight /-
/-- Quotients are congruent on equivalences under equality of their relation.
An alternative is just to use rewriting with `eq`, but then computational proofs get stuck. -/
protected def congrRight {r r' : α → α → Prop} (eq : ∀ a₁ a₂, r a₁ a₂ ↔ r' a₁ a₂) :
    Quot r ≃ Quot r' :=
  Quot.congr (Equiv.refl α) Eq
#align quot.congr_right Quot.congrRight
-/

#print Quot.congrLeft /-
/-- An equivalence `e : α ≃ β` generates an equivalence between the quotient space of `α`
by a relation `ra` and the quotient space of `β` by the image of this relation under `e`. -/
protected def congrLeft {r : α → α → Prop} (e : α ≃ β) :
    Quot r ≃ Quot fun b b' => r (e.symm b) (e.symm b') :=
  @Quot.congr α β r (fun b b' => r (e.symm b) (e.symm b')) e fun a₁ a₂ => by
    simp only [e.symm_apply_apply]
#align quot.congr_left Quot.congrLeft
-/

end Quot

namespace Quotient

#print Quotient.congr /-
/-- An equivalence `e : α ≃ β` generates an equivalence between quotient spaces,
if `ra a₁ a₂ ↔ rb (e a₁) (e a₂). -/
protected def congr {ra : Setoid α} {rb : Setoid β} (e : α ≃ β)
    (eq : ∀ a₁ a₂, @Setoid.r α ra a₁ a₂ ↔ @Setoid.r β rb (e a₁) (e a₂)) :
    Quotient ra ≃ Quotient rb :=
  Quot.congr e Eq
#align quotient.congr Quotient.congr
-/

#print Quotient.congr_mk /-
@[simp]
theorem congr_mk {ra : Setoid α} {rb : Setoid β} (e : α ≃ β)
    (eq : ∀ a₁ a₂ : α, Setoid.r a₁ a₂ ↔ Setoid.r (e a₁) (e a₂)) (a : α) :
    Quotient.congr e Eq (Quotient.mk' a) = Quotient.mk' (e a) :=
  rfl
#align quotient.congr_mk Quotient.congr_mk
-/

#print Quotient.congrRight /-
/-- Quotients are congruent on equivalences under equality of their relation.
An alternative is just to use rewriting with `eq`, but then computational proofs get stuck. -/
protected def congrRight {r r' : Setoid α}
    (eq : ∀ a₁ a₂, @Setoid.r α r a₁ a₂ ↔ @Setoid.r α r' a₁ a₂) : Quotient r ≃ Quotient r' :=
  Quot.congrRight Eq
#align quotient.congr_right Quotient.congrRight
-/

end Quotient

