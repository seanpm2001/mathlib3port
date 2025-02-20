/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module logic.function.conjugate
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Function.Basic

/-!
# Semiconjugate and commuting maps

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define the following predicates:

* `function.semiconj`: `f : α → β` semiconjugates `ga : α → α` to `gb : β → β` if `f ∘ ga = gb ∘ f`;
* `function.semiconj₂: `f : α → β` semiconjugates a binary operation `ga : α → α → α`
  to `gb : β → β → β` if `f (ga x y) = gb (f x) (f y)`;
* `f : α → α` commutes with `g : α → α` if `f ∘ g = g ∘ f`, or equivalently `semiconj f g g`.

-/


namespace Function

variable {α : Type _} {β : Type _} {γ : Type _}

#print Function.Semiconj /-
/-- We say that `f : α → β` semiconjugates `ga : α → α` to `gb : β → β` if `f ∘ ga = gb ∘ f`.
We use `∀ x, f (ga x) = gb (f x)` as the definition, so given `h : function.semiconj f ga gb` and
`a : α`, we have `h a : f (ga a) = gb (f a)` and `h.comp_eq : f ∘ ga = gb ∘ f`. -/
def Semiconj (f : α → β) (ga : α → α) (gb : β → β) : Prop :=
  ∀ x, f (ga x) = gb (f x)
#align function.semiconj Function.Semiconj
-/

namespace Semiconj

variable {f fab : α → β} {fbc : β → γ} {ga ga' : α → α} {gb gb' : β → β} {gc gc' : γ → γ}

#print Function.Semiconj.comp_eq /-
protected theorem comp_eq (h : Semiconj f ga gb) : f ∘ ga = gb ∘ f :=
  funext h
#align function.semiconj.comp_eq Function.Semiconj.comp_eq
-/

#print Function.Semiconj.eq /-
protected theorem eq (h : Semiconj f ga gb) (x : α) : f (ga x) = gb (f x) :=
  h x
#align function.semiconj.eq Function.Semiconj.eq
-/

#print Function.Semiconj.comp_right /-
theorem comp_right (h : Semiconj f ga gb) (h' : Semiconj f ga' gb') :
    Semiconj f (ga ∘ ga') (gb ∘ gb') := fun x => by rw [comp_app, h.eq, h'.eq]
#align function.semiconj.comp_right Function.Semiconj.comp_right
-/

#print Function.Semiconj.comp_left /-
theorem comp_left (hab : Semiconj fab ga gb) (hbc : Semiconj fbc gb gc) :
    Semiconj (fbc ∘ fab) ga gc := fun x => by simp only [comp_app, hab.eq, hbc.eq]
#align function.semiconj.comp_left Function.Semiconj.comp_left
-/

#print Function.Semiconj.id_right /-
theorem id_right : Semiconj f id id := fun _ => rfl
#align function.semiconj.id_right Function.Semiconj.id_right
-/

#print Function.Semiconj.id_left /-
theorem id_left : Semiconj id ga ga := fun _ => rfl
#align function.semiconj.id_left Function.Semiconj.id_left
-/

#print Function.Semiconj.inverses_right /-
theorem inverses_right (h : Semiconj f ga gb) (ha : RightInverse ga' ga) (hb : LeftInverse gb' gb) :
    Semiconj f ga' gb' := fun x => by rw [← hb (f (ga' x)), ← h.eq, ha x]
#align function.semiconj.inverses_right Function.Semiconj.inverses_right
-/

#print Function.Semiconj.option_map /-
theorem option_map {f : α → β} {ga : α → α} {gb : β → β} (h : Semiconj f ga gb) :
    Semiconj (Option.map f) (Option.map ga) (Option.map gb)
  | none => rfl
  | some a => congr_arg some <| h _
#align function.semiconj.option_map Function.Semiconj.option_map
-/

end Semiconj

#print Function.Commute /-
/-- Two maps `f g : α → α` commute if `f (g x) = g (f x)` for all `x : α`.
Given `h : function.commute f g` and `a : α`, we have `h a : f (g a) = g (f a)` and
`h.comp_eq : f ∘ g = g ∘ f`. -/
def Commute (f g : α → α) : Prop :=
  Semiconj f g g
#align function.commute Function.Commute
-/

#print Function.Semiconj.commute /-
theorem Semiconj.commute {f g : α → α} (h : Semiconj f g g) : Commute f g :=
  h
#align function.semiconj.commute Function.Semiconj.commute
-/

namespace Commute

variable {f f' g g' : α → α}

#print Function.Commute.refl /-
@[refl]
theorem refl (f : α → α) : Commute f f := fun _ => Eq.refl _
#align function.commute.refl Function.Commute.refl
-/

#print Function.Commute.symm /-
@[symm]
theorem symm (h : Commute f g) : Commute g f := fun x => (h x).symm
#align function.commute.symm Function.Commute.symm
-/

#print Function.Commute.comp_right /-
theorem comp_right (h : Commute f g) (h' : Commute f g') : Commute f (g ∘ g') :=
  h.compRight h'
#align function.commute.comp_right Function.Commute.comp_right
-/

#print Function.Commute.comp_left /-
theorem comp_left (h : Commute f g) (h' : Commute f' g) : Commute (f ∘ f') g :=
  (h.symm.compRight h'.symm).symm
#align function.commute.comp_left Function.Commute.comp_left
-/

#print Function.Commute.id_right /-
theorem id_right : Commute f id :=
  Semiconj.id_right
#align function.commute.id_right Function.Commute.id_right
-/

#print Function.Commute.id_left /-
theorem id_left : Commute id f :=
  Semiconj.id_left
#align function.commute.id_left Function.Commute.id_left
-/

#print Function.Commute.option_map /-
theorem option_map {f g : α → α} : Commute f g → Commute (Option.map f) (Option.map g) :=
  Semiconj.option_map
#align function.commute.option_map Function.Commute.option_map
-/

end Commute

#print Function.Semiconj₂ /-
/-- A map `f` semiconjugates a binary operation `ga` to a binary operation `gb` if
for all `x`, `y` we have `f (ga x y) = gb (f x) (f y)`. E.g., a `monoid_hom`
semiconjugates `(*)` to `(*)`. -/
def Semiconj₂ (f : α → β) (ga : α → α → α) (gb : β → β → β) : Prop :=
  ∀ x y, f (ga x y) = gb (f x) (f y)
#align function.semiconj₂ Function.Semiconj₂
-/

namespace Semiconj₂

variable {f : α → β} {ga : α → α → α} {gb : β → β → β}

#print Function.Semiconj₂.eq /-
protected theorem eq (h : Semiconj₂ f ga gb) (x y : α) : f (ga x y) = gb (f x) (f y) :=
  h x y
#align function.semiconj₂.eq Function.Semiconj₂.eq
-/

#print Function.Semiconj₂.comp_eq /-
protected theorem comp_eq (h : Semiconj₂ f ga gb) : bicompr f ga = bicompl gb f f :=
  funext fun x => funext <| h x
#align function.semiconj₂.comp_eq Function.Semiconj₂.comp_eq
-/

#print Function.Semiconj₂.id_left /-
theorem id_left (op : α → α → α) : Semiconj₂ id op op := fun _ _ => rfl
#align function.semiconj₂.id_left Function.Semiconj₂.id_left
-/

#print Function.Semiconj₂.comp /-
theorem comp {f' : β → γ} {gc : γ → γ → γ} (hf' : Semiconj₂ f' gb gc) (hf : Semiconj₂ f ga gb) :
    Semiconj₂ (f' ∘ f) ga gc := fun x y => by simp only [hf'.eq, hf.eq, comp_app]
#align function.semiconj₂.comp Function.Semiconj₂.comp
-/

#print Function.Semiconj₂.isAssociative_right /-
theorem isAssociative_right [IsAssociative α ga] (h : Semiconj₂ f ga gb) (h_surj : Surjective f) :
    IsAssociative β gb :=
  ⟨h_surj.forall₃.2 fun x₁ x₂ x₃ => by simp only [← h.eq, @IsAssociative.assoc _ ga]⟩
#align function.semiconj₂.is_associative_right Function.Semiconj₂.isAssociative_right
-/

#print Function.Semiconj₂.isAssociative_left /-
theorem isAssociative_left [IsAssociative β gb] (h : Semiconj₂ f ga gb) (h_inj : Injective f) :
    IsAssociative α ga :=
  ⟨fun x₁ x₂ x₃ => h_inj <| by simp only [h.eq, @IsAssociative.assoc _ gb]⟩
#align function.semiconj₂.is_associative_left Function.Semiconj₂.isAssociative_left
-/

#print Function.Semiconj₂.isIdempotent_right /-
theorem isIdempotent_right [IsIdempotent α ga] (h : Semiconj₂ f ga gb) (h_surj : Surjective f) :
    IsIdempotent β gb :=
  ⟨h_surj.forall.2 fun x => by simp only [← h.eq, @IsIdempotent.idempotent _ ga]⟩
#align function.semiconj₂.is_idempotent_right Function.Semiconj₂.isIdempotent_right
-/

#print Function.Semiconj₂.isIdempotent_left /-
theorem isIdempotent_left [IsIdempotent β gb] (h : Semiconj₂ f ga gb) (h_inj : Injective f) :
    IsIdempotent α ga :=
  ⟨fun x => h_inj <| by rw [h.eq, @IsIdempotent.idempotent _ gb]⟩
#align function.semiconj₂.is_idempotent_left Function.Semiconj₂.isIdempotent_left
-/

end Semiconj₂

end Function

