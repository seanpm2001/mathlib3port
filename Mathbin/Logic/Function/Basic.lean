/-
Copyright (c) 2016 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

! This file was ported from Lean 3 source module logic.function.basic
! leanprover-community/mathlib commit 29cb56a7b35f72758b05a30490e1f10bd62c35c1
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Option.Defs
import Mathbin.Logic.Nonempty
import Mathbin.Tactic.Cache

/-!
# Miscellaneous function constructions and lemmas

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


universe u v w

namespace Function

section

variable {α β γ : Sort _} {f : α → β}

#print Function.eval /-
/-- Evaluate a function at an argument. Useful if you want to talk about the partially applied
  `function.eval x : (Π x, β x) → β x`. -/
@[reducible]
def eval {β : α → Sort _} (x : α) (f : ∀ x, β x) : β x :=
  f x
#align function.eval Function.eval
-/

#print Function.eval_apply /-
@[simp]
theorem eval_apply {β : α → Sort _} (x : α) (f : ∀ x, β x) : eval x f = f x :=
  rfl
#align function.eval_apply Function.eval_apply
-/

/- warning: function.comp_apply clashes with function.comp_app -> Function.comp_apply
Case conversion may be inaccurate. Consider using '#align function.comp_apply Function.comp_applyₓ'. -/
#print Function.comp_apply /-
theorem comp_apply {α : Sort u} {β : Sort v} {φ : Sort w} (f : β → φ) (g : α → β) (a : α) :
    (f ∘ g) a = f (g a) :=
  rfl
#align function.comp_apply Function.comp_apply
-/

#print Function.const_def /-
theorem const_def {y : β} : (fun x : α => y) = const α y :=
  rfl
#align function.const_def Function.const_def
-/

#print Function.const_apply /-
@[simp]
theorem const_apply {y : β} {x : α} : const α y x = y :=
  rfl
#align function.const_apply Function.const_apply
-/

#print Function.const_comp /-
@[simp]
theorem const_comp {f : α → β} {c : γ} : const β c ∘ f = const α c :=
  rfl
#align function.const_comp Function.const_comp
-/

#print Function.comp_const /-
@[simp]
theorem comp_const {f : β → γ} {b : β} : f ∘ const α b = const α (f b) :=
  rfl
#align function.comp_const Function.comp_const
-/

#print Function.const_injective /-
theorem const_injective [Nonempty α] : Injective (const α : β → α → β) := fun y₁ y₂ h =>
  let ⟨x⟩ := ‹Nonempty α›
  congr_fun h x
#align function.const_injective Function.const_injective
-/

#print Function.const_inj /-
@[simp]
theorem const_inj [Nonempty α] {y₁ y₂ : β} : const α y₁ = const α y₂ ↔ y₁ = y₂ :=
  ⟨fun h => const_injective h, fun h => h ▸ rfl⟩
#align function.const_inj Function.const_inj
-/

#print Function.id_def /-
theorem id_def : @id α = fun x => x :=
  rfl
#align function.id_def Function.id_def
-/

#print Function.onFun_apply /-
@[simp]
theorem onFun_apply (f : β → β → γ) (g : α → β) (a b : α) : onFun f g a b = f (g a) (g b) :=
  rfl
#align function.on_fun_apply Function.onFun_apply
-/

#print Function.hfunext /-
theorem hfunext {α α' : Sort u} {β : α → Sort v} {β' : α' → Sort v} {f : ∀ a, β a} {f' : ∀ a, β' a}
    (hα : α = α') (h : ∀ a a', HEq a a' → HEq (f a) (f' a')) : HEq f f' :=
  by
  subst hα
  have : ∀ a, HEq (f a) (f' a) := by intro a; exact h a a (HEq.refl a)
  have : β = β' := by funext a; exact type_eq_of_hEq (this a)
  subst this
  apply hEq_of_eq
  funext a
  exact eq_of_hEq (this a)
#align function.hfunext Function.hfunext
-/

#print Function.funext_iff /-
theorem funext_iff {β : α → Sort _} {f₁ f₂ : ∀ x : α, β x} : f₁ = f₂ ↔ ∀ a, f₁ a = f₂ a :=
  Iff.intro (fun h a => h ▸ rfl) funext
#align function.funext_iff Function.funext_iff
-/

#print Function.ne_iff /-
theorem ne_iff {β : α → Sort _} {f₁ f₂ : ∀ a, β a} : f₁ ≠ f₂ ↔ ∃ a, f₁ a ≠ f₂ a :=
  funext_iff.Not.trans not_forall
#align function.ne_iff Function.ne_iff
-/

#print Function.Bijective.injective /-
protected theorem Bijective.injective {f : α → β} (hf : Bijective f) : Injective f :=
  hf.1
#align function.bijective.injective Function.Bijective.injective
-/

#print Function.Bijective.surjective /-
protected theorem Bijective.surjective {f : α → β} (hf : Bijective f) : Surjective f :=
  hf.2
#align function.bijective.surjective Function.Bijective.surjective
-/

#print Function.Injective.eq_iff /-
theorem Injective.eq_iff (I : Injective f) {a b : α} : f a = f b ↔ a = b :=
  ⟨@I _ _, congr_arg f⟩
#align function.injective.eq_iff Function.Injective.eq_iff
-/

#print Function.Injective.eq_iff' /-
theorem Injective.eq_iff' (I : Injective f) {a b : α} {c : β} (h : f b = c) : f a = c ↔ a = b :=
  h ▸ I.eq_iff
#align function.injective.eq_iff' Function.Injective.eq_iff'
-/

#print Function.Injective.ne /-
theorem Injective.ne (hf : Injective f) {a₁ a₂ : α} : a₁ ≠ a₂ → f a₁ ≠ f a₂ :=
  mt fun h => hf h
#align function.injective.ne Function.Injective.ne
-/

#print Function.Injective.ne_iff /-
theorem Injective.ne_iff (hf : Injective f) {x y : α} : f x ≠ f y ↔ x ≠ y :=
  ⟨mt <| congr_arg f, hf.Ne⟩
#align function.injective.ne_iff Function.Injective.ne_iff
-/

#print Function.Injective.ne_iff' /-
theorem Injective.ne_iff' (hf : Injective f) {x y : α} {z : β} (h : f y = z) : f x ≠ z ↔ x ≠ y :=
  h ▸ hf.ne_iff
#align function.injective.ne_iff' Function.Injective.ne_iff'
-/

#print Function.Injective.decidableEq /-
/-- If the co-domain `β` of an injective function `f : α → β` has decidable equality, then
the domain `α` also has decidable equality. -/
protected def Injective.decidableEq [DecidableEq β] (I : Injective f) : DecidableEq α := fun a b =>
  decidable_of_iff _ I.eq_iff
#align function.injective.decidable_eq Function.Injective.decidableEq
-/

#print Function.Injective.of_comp /-
theorem Injective.of_comp {g : γ → α} (I : Injective (f ∘ g)) : Injective g := fun x y h =>
  I <| show f (g x) = f (g y) from congr_arg f h
#align function.injective.of_comp Function.Injective.of_comp
-/

#print Function.Injective.of_comp_iff /-
theorem Injective.of_comp_iff {f : α → β} (hf : Injective f) (g : γ → α) :
    Injective (f ∘ g) ↔ Injective g :=
  ⟨Injective.of_comp, hf.comp⟩
#align function.injective.of_comp_iff Function.Injective.of_comp_iff
-/

#print Function.Injective.of_comp_iff' /-
theorem Injective.of_comp_iff' (f : α → β) {g : γ → α} (hg : Bijective g) :
    Injective (f ∘ g) ↔ Injective f :=
  ⟨fun h x y =>
    let ⟨x', hx⟩ := hg.Surjective x
    let ⟨y', hy⟩ := hg.Surjective y
    hx ▸ hy ▸ fun hf => h hf ▸ rfl,
    fun h => h.comp hg.Injective⟩
#align function.injective.of_comp_iff' Function.Injective.of_comp_iff'
-/

#print Function.Injective.comp_left /-
/-- Composition by an injective function on the left is itself injective. -/
theorem Injective.comp_left {g : β → γ} (hg : Function.Injective g) :
    Function.Injective ((· ∘ ·) g : (α → β) → α → γ) := fun f₁ f₂ hgf =>
  funext fun i => hg <| (congr_fun hgf i : _)
#align function.injective.comp_left Function.Injective.comp_left
-/

#print Function.injective_of_subsingleton /-
theorem injective_of_subsingleton [Subsingleton α] (f : α → β) : Injective f := fun a b ab =>
  Subsingleton.elim _ _
#align function.injective_of_subsingleton Function.injective_of_subsingleton
-/

#print Function.Injective.dite /-
theorem Injective.dite (p : α → Prop) [DecidablePred p] {f : { a : α // p a } → β}
    {f' : { a : α // ¬p a } → β} (hf : Injective f) (hf' : Injective f')
    (im_disj : ∀ {x x' : α} {hx : p x} {hx' : ¬p x'}, f ⟨x, hx⟩ ≠ f' ⟨x', hx'⟩) :
    Function.Injective fun x => if h : p x then f ⟨x, h⟩ else f' ⟨x, h⟩ := fun x₁ x₂ h =>
  by
  dsimp only at h 
  by_cases h₁ : p x₁ <;> by_cases h₂ : p x₂
  · rw [dif_pos h₁, dif_pos h₂] at h ; injection hf h
  · rw [dif_pos h₁, dif_neg h₂] at h ; exact (im_disj h).elim
  · rw [dif_neg h₁, dif_pos h₂] at h ; exact (im_disj h.symm).elim
  · rw [dif_neg h₁, dif_neg h₂] at h ; injection hf' h
#align function.injective.dite Function.Injective.dite
-/

#print Function.Surjective.of_comp /-
theorem Surjective.of_comp {g : γ → α} (S : Surjective (f ∘ g)) : Surjective f := fun y =>
  let ⟨x, h⟩ := S y
  ⟨g x, h⟩
#align function.surjective.of_comp Function.Surjective.of_comp
-/

#print Function.Surjective.of_comp_iff /-
theorem Surjective.of_comp_iff (f : α → β) {g : γ → α} (hg : Surjective g) :
    Surjective (f ∘ g) ↔ Surjective f :=
  ⟨Surjective.of_comp, fun h => h.comp hg⟩
#align function.surjective.of_comp_iff Function.Surjective.of_comp_iff
-/

#print Function.Surjective.of_comp_iff' /-
theorem Surjective.of_comp_iff' (hf : Bijective f) (g : γ → α) :
    Surjective (f ∘ g) ↔ Surjective g :=
  ⟨fun h x =>
    let ⟨x', hx'⟩ := h (f x)
    ⟨x', hf.Injective hx'⟩,
    hf.Surjective.comp⟩
#align function.surjective.of_comp_iff' Function.Surjective.of_comp_iff'
-/

#print Function.decidableEqPfun /-
instance decidableEqPfun (p : Prop) [Decidable p] (α : p → Type _) [∀ hp, DecidableEq (α hp)] :
    DecidableEq (∀ hp, α hp)
  | f, g => decidable_of_iff (∀ hp, f hp = g hp) funext_iff.symm
#align function.decidable_eq_pfun Function.decidableEqPfun
-/

#print Function.Surjective.forall /-
protected theorem Surjective.forall (hf : Surjective f) {p : β → Prop} :
    (∀ y, p y) ↔ ∀ x, p (f x) :=
  ⟨fun h x => h (f x), fun h y =>
    let ⟨x, hx⟩ := hf y
    hx ▸ h x⟩
#align function.surjective.forall Function.Surjective.forall
-/

#print Function.Surjective.forall₂ /-
protected theorem Surjective.forall₂ (hf : Surjective f) {p : β → β → Prop} :
    (∀ y₁ y₂, p y₁ y₂) ↔ ∀ x₁ x₂, p (f x₁) (f x₂) :=
  hf.forall.trans <| forall_congr' fun x => hf.forall
#align function.surjective.forall₂ Function.Surjective.forall₂
-/

#print Function.Surjective.forall₃ /-
protected theorem Surjective.forall₃ (hf : Surjective f) {p : β → β → β → Prop} :
    (∀ y₁ y₂ y₃, p y₁ y₂ y₃) ↔ ∀ x₁ x₂ x₃, p (f x₁) (f x₂) (f x₃) :=
  hf.forall.trans <| forall_congr' fun x => hf.forall₂
#align function.surjective.forall₃ Function.Surjective.forall₃
-/

#print Function.Surjective.exists /-
protected theorem Surjective.exists (hf : Surjective f) {p : β → Prop} :
    (∃ y, p y) ↔ ∃ x, p (f x) :=
  ⟨fun ⟨y, hy⟩ =>
    let ⟨x, hx⟩ := hf y
    ⟨x, hx.symm ▸ hy⟩,
    fun ⟨x, hx⟩ => ⟨f x, hx⟩⟩
#align function.surjective.exists Function.Surjective.exists
-/

#print Function.Surjective.exists₂ /-
protected theorem Surjective.exists₂ (hf : Surjective f) {p : β → β → Prop} :
    (∃ y₁ y₂, p y₁ y₂) ↔ ∃ x₁ x₂, p (f x₁) (f x₂) :=
  hf.exists.trans <| exists_congr fun x => hf.exists
#align function.surjective.exists₂ Function.Surjective.exists₂
-/

#print Function.Surjective.exists₃ /-
protected theorem Surjective.exists₃ (hf : Surjective f) {p : β → β → β → Prop} :
    (∃ y₁ y₂ y₃, p y₁ y₂ y₃) ↔ ∃ x₁ x₂ x₃, p (f x₁) (f x₂) (f x₃) :=
  hf.exists.trans <| exists_congr fun x => hf.exists₂
#align function.surjective.exists₃ Function.Surjective.exists₃
-/

#print Function.Surjective.injective_comp_right /-
theorem Surjective.injective_comp_right (hf : Surjective f) : Injective fun g : β → γ => g ∘ f :=
  fun g₁ g₂ h => funext <| hf.forall.2 <| congr_fun h
#align function.surjective.injective_comp_right Function.Surjective.injective_comp_right
-/

#print Function.Surjective.right_cancellable /-
protected theorem Surjective.right_cancellable (hf : Surjective f) {g₁ g₂ : β → γ} :
    g₁ ∘ f = g₂ ∘ f ↔ g₁ = g₂ :=
  hf.injective_comp_right.eq_iff
#align function.surjective.right_cancellable Function.Surjective.right_cancellable
-/

#print Function.surjective_of_right_cancellable_Prop /-
theorem surjective_of_right_cancellable_Prop (h : ∀ g₁ g₂ : β → Prop, g₁ ∘ f = g₂ ∘ f → g₁ = g₂) :
    Surjective f :=
  by
  specialize h (fun _ => True) (fun y => ∃ x, f x = y) (funext fun x => _)
  · simp only [(· ∘ ·), exists_apply_eq_apply]
  · intro y
    have : True = ∃ x, f x = y := congr_fun h y
    rw [← this]; exact trivial
#align function.surjective_of_right_cancellable_Prop Function.surjective_of_right_cancellable_Prop
-/

#print Function.bijective_iff_existsUnique /-
theorem bijective_iff_existsUnique (f : α → β) : Bijective f ↔ ∀ b : β, ∃! a : α, f a = b :=
  ⟨fun hf b =>
    let ⟨a, ha⟩ := hf.Surjective b
    ⟨a, ha, fun a' ha' => hf.Injective (ha'.trans ha.symm)⟩,
    fun he =>
    ⟨fun a a' h => ExistsUnique.unique (he (f a')) h rfl, fun b => ExistsUnique.exists (he b)⟩⟩
#align function.bijective_iff_exists_unique Function.bijective_iff_existsUnique
-/

#print Function.Bijective.existsUnique /-
/-- Shorthand for using projection notation with `function.bijective_iff_exists_unique`. -/
protected theorem Bijective.existsUnique {f : α → β} (hf : Bijective f) (b : β) :
    ∃! a : α, f a = b :=
  (bijective_iff_existsUnique f).mp hf b
#align function.bijective.exists_unique Function.Bijective.existsUnique
-/

#print Function.Bijective.existsUnique_iff /-
theorem Bijective.existsUnique_iff {f : α → β} (hf : Bijective f) {p : β → Prop} :
    (∃! y, p y) ↔ ∃! x, p (f x) :=
  ⟨fun ⟨y, hpy, hy⟩ =>
    let ⟨x, hx⟩ := hf.Surjective y
    ⟨x, by rwa [hx], fun z (hz : p (f z)) => hf.Injective <| hx.symm ▸ hy _ hz⟩,
    fun ⟨x, hpx, hx⟩ =>
    ⟨f x, hpx, fun y hy =>
      let ⟨z, hz⟩ := hf.Surjective y
      hz ▸ congr_arg f <| hx _ <| by rwa [hz]⟩⟩
#align function.bijective.exists_unique_iff Function.Bijective.existsUnique_iff
-/

#print Function.Bijective.of_comp_iff /-
theorem Bijective.of_comp_iff (f : α → β) {g : γ → α} (hg : Bijective g) :
    Bijective (f ∘ g) ↔ Bijective f :=
  and_congr (Injective.of_comp_iff' _ hg) (Surjective.of_comp_iff _ hg.Surjective)
#align function.bijective.of_comp_iff Function.Bijective.of_comp_iff
-/

#print Function.Bijective.of_comp_iff' /-
theorem Bijective.of_comp_iff' {f : α → β} (hf : Bijective f) (g : γ → α) :
    Function.Bijective (f ∘ g) ↔ Function.Bijective g :=
  and_congr (Injective.of_comp_iff hf.Injective _) (Surjective.of_comp_iff' hf _)
#align function.bijective.of_comp_iff' Function.Bijective.of_comp_iff'
-/

#print Function.cantor_surjective /-
/-- **Cantor's diagonal argument** implies that there are no surjective functions from `α`
to `set α`. -/
theorem cantor_surjective {α} (f : α → Set α) : ¬Function.Surjective f
  | h =>
    let ⟨D, e⟩ := h {a | ¬a ∈ f a}
    (iff_not_self (D ∈ f D)).1 <| iff_of_eq (congr_arg ((· ∈ ·) D) e)
#align function.cantor_surjective Function.cantor_surjective
-/

#print Function.cantor_injective /-
/-- **Cantor's diagonal argument** implies that there are no injective functions from `set α`
to `α`. -/
theorem cantor_injective {α : Type _} (f : Set α → α) : ¬Function.Injective f
  | i =>
    (cantor_surjective fun a => {b | ∀ U, a = f U → b ∈ U}) <|
      RightInverse.surjective fun U =>
        funext fun a => propext ⟨fun h => h U rfl, fun h' U' e => i e ▸ h'⟩
#align function.cantor_injective Function.cantor_injective
-/

#print Function.not_surjective_Type /-
/-- There is no surjection from `α : Type u` into `Type u`. This theorem
  demonstrates why `Type : Type` would be inconsistent in Lean. -/
theorem not_surjective_Type {α : Type u} (f : α → Type max u v) : ¬Surjective f :=
  by
  intro hf
  let T : Type max u v := Sigma f
  cases' hf (Set T) with U hU
  let g : Set T → T := fun s => ⟨U, cast hU.symm s⟩
  have hg : injective g := by
    intro s t h
    suffices cast hU (g s).2 = cast hU (g t).2 by simp only [cast_cast, cast_eq] at this ;
      assumption
    · congr; assumption
  exact cantor_injective g hg
#align function.not_surjective_Type Function.not_surjective_Type
-/

#print Function.IsPartialInv /-
/-- `g` is a partial inverse to `f` (an injective but not necessarily
  surjective function) if `g y = some x` implies `f x = y`, and `g y = none`
  implies that `y` is not in the range of `f`. -/
def IsPartialInv {α β} (f : α → β) (g : β → Option α) : Prop :=
  ∀ x y, g y = some x ↔ f x = y
#align function.is_partial_inv Function.IsPartialInv
-/

#print Function.isPartialInv_left /-
theorem isPartialInv_left {α β} {f : α → β} {g} (H : IsPartialInv f g) (x) : g (f x) = some x :=
  (H _ _).2 rfl
#align function.is_partial_inv_left Function.isPartialInv_left
-/

#print Function.injective_of_isPartialInv /-
theorem injective_of_isPartialInv {α β} {f : α → β} {g} (H : IsPartialInv f g) : Injective f :=
  fun a b h => Option.some.inj <| ((H _ _).2 h).symm.trans ((H _ _).2 rfl)
#align function.injective_of_partial_inv Function.injective_of_isPartialInv
-/

#print Function.injective_of_isPartialInv_right /-
theorem injective_of_isPartialInv_right {α β} {f : α → β} {g} (H : IsPartialInv f g) (x y b)
    (h₁ : b ∈ g x) (h₂ : b ∈ g y) : x = y :=
  ((H _ _).1 h₁).symm.trans ((H _ _).1 h₂)
#align function.injective_of_partial_inv_right Function.injective_of_isPartialInv_right
-/

#print Function.LeftInverse.comp_eq_id /-
theorem LeftInverse.comp_eq_id {f : α → β} {g : β → α} (h : LeftInverse f g) : f ∘ g = id :=
  funext h
#align function.left_inverse.comp_eq_id Function.LeftInverse.comp_eq_id
-/

#print Function.leftInverse_iff_comp /-
theorem leftInverse_iff_comp {f : α → β} {g : β → α} : LeftInverse f g ↔ f ∘ g = id :=
  ⟨LeftInverse.comp_eq_id, congr_fun⟩
#align function.left_inverse_iff_comp Function.leftInverse_iff_comp
-/

#print Function.RightInverse.comp_eq_id /-
theorem RightInverse.comp_eq_id {f : α → β} {g : β → α} (h : RightInverse f g) : g ∘ f = id :=
  funext h
#align function.right_inverse.comp_eq_id Function.RightInverse.comp_eq_id
-/

#print Function.rightInverse_iff_comp /-
theorem rightInverse_iff_comp {f : α → β} {g : β → α} : RightInverse f g ↔ g ∘ f = id :=
  ⟨RightInverse.comp_eq_id, congr_fun⟩
#align function.right_inverse_iff_comp Function.rightInverse_iff_comp
-/

#print Function.LeftInverse.comp /-
theorem LeftInverse.comp {f : α → β} {g : β → α} {h : β → γ} {i : γ → β} (hf : LeftInverse f g)
    (hh : LeftInverse h i) : LeftInverse (h ∘ f) (g ∘ i) := fun a =>
  show h (f (g (i a))) = a by rw [hf (i a), hh a]
#align function.left_inverse.comp Function.LeftInverse.comp
-/

#print Function.RightInverse.comp /-
theorem RightInverse.comp {f : α → β} {g : β → α} {h : β → γ} {i : γ → β} (hf : RightInverse f g)
    (hh : RightInverse h i) : RightInverse (h ∘ f) (g ∘ i) :=
  LeftInverse.comp hh hf
#align function.right_inverse.comp Function.RightInverse.comp
-/

#print Function.LeftInverse.rightInverse /-
theorem LeftInverse.rightInverse {f : α → β} {g : β → α} (h : LeftInverse g f) : RightInverse f g :=
  h
#align function.left_inverse.right_inverse Function.LeftInverse.rightInverse
-/

#print Function.RightInverse.leftInverse /-
theorem RightInverse.leftInverse {f : α → β} {g : β → α} (h : RightInverse g f) : LeftInverse f g :=
  h
#align function.right_inverse.left_inverse Function.RightInverse.leftInverse
-/

#print Function.LeftInverse.surjective /-
theorem LeftInverse.surjective {f : α → β} {g : β → α} (h : LeftInverse f g) : Surjective f :=
  h.RightInverse.Surjective
#align function.left_inverse.surjective Function.LeftInverse.surjective
-/

#print Function.RightInverse.injective /-
theorem RightInverse.injective {f : α → β} {g : β → α} (h : RightInverse f g) : Injective f :=
  h.LeftInverse.Injective
#align function.right_inverse.injective Function.RightInverse.injective
-/

#print Function.LeftInverse.rightInverse_of_injective /-
theorem LeftInverse.rightInverse_of_injective {f : α → β} {g : β → α} (h : LeftInverse f g)
    (hf : Injective f) : RightInverse f g := fun x => hf <| h (f x)
#align function.left_inverse.right_inverse_of_injective Function.LeftInverse.rightInverse_of_injective
-/

#print Function.LeftInverse.rightInverse_of_surjective /-
theorem LeftInverse.rightInverse_of_surjective {f : α → β} {g : β → α} (h : LeftInverse f g)
    (hg : Surjective g) : RightInverse f g := fun x =>
  let ⟨y, hy⟩ := hg x
  hy ▸ congr_arg g (h y)
#align function.left_inverse.right_inverse_of_surjective Function.LeftInverse.rightInverse_of_surjective
-/

#print Function.RightInverse.leftInverse_of_surjective /-
theorem RightInverse.leftInverse_of_surjective {f : α → β} {g : β → α} :
    RightInverse f g → Surjective f → LeftInverse f g :=
  LeftInverse.rightInverse_of_surjective
#align function.right_inverse.left_inverse_of_surjective Function.RightInverse.leftInverse_of_surjective
-/

#print Function.RightInverse.leftInverse_of_injective /-
theorem RightInverse.leftInverse_of_injective {f : α → β} {g : β → α} :
    RightInverse f g → Injective g → LeftInverse f g :=
  LeftInverse.rightInverse_of_injective
#align function.right_inverse.left_inverse_of_injective Function.RightInverse.leftInverse_of_injective
-/

#print Function.LeftInverse.eq_rightInverse /-
theorem LeftInverse.eq_rightInverse {f : α → β} {g₁ g₂ : β → α} (h₁ : LeftInverse g₁ f)
    (h₂ : RightInverse g₂ f) : g₁ = g₂ :=
  calc
    g₁ = g₁ ∘ f ∘ g₂ := by rw [h₂.comp_eq_id, comp.right_id]
    _ = g₂ := by rw [← comp.assoc, h₁.comp_eq_id, comp.left_id]
#align function.left_inverse.eq_right_inverse Function.LeftInverse.eq_rightInverse
-/

attribute [local instance 10] Classical.propDecidable

#print Function.partialInv /-
/-- We can use choice to construct explicitly a partial inverse for
  a given injective function `f`. -/
noncomputable def partialInv {α β} (f : α → β) (b : β) : Option α :=
  if h : ∃ a, f a = b then some (Classical.choose h) else none
#align function.partial_inv Function.partialInv
-/

#print Function.partialInv_of_injective /-
theorem partialInv_of_injective {α β} {f : α → β} (I : Injective f) : IsPartialInv f (partialInv f)
  | a, b =>
    ⟨fun h =>
      if h' : ∃ a, f a = b then by
        rw [partial_inv, dif_pos h'] at h 
        injection h with h; subst h
        apply Classical.choose_spec h'
      else by rw [partial_inv, dif_neg h'] at h  <;> contradiction,
      fun e =>
      e ▸
        have h : ∃ a', f a' = f a := ⟨_, rfl⟩
        (dif_pos h).trans (congr_arg _ (I <| Classical.choose_spec h))⟩
#align function.partial_inv_of_injective Function.partialInv_of_injective
-/

#print Function.partialInv_left /-
theorem partialInv_left {α β} {f : α → β} (I : Injective f) : ∀ x, partialInv f (f x) = some x :=
  isPartialInv_left (partialInv_of_injective I)
#align function.partial_inv_left Function.partialInv_left
-/

end

section InvFun

variable {α β : Sort _} [Nonempty α] {f : α → β} {a : α} {b : β}

attribute [local instance 10] Classical.propDecidable

#print Function.invFun /-
/-- The inverse of a function (which is a left inverse if `f` is injective
  and a right inverse if `f` is surjective). -/
noncomputable def invFun (f : α → β) : β → α := fun y =>
  if h : ∃ x, f x = y then h.some else Classical.arbitrary α
#align function.inv_fun Function.invFun
-/

#print Function.invFun_eq /-
theorem invFun_eq (h : ∃ a, f a = b) : f (invFun f b) = b := by
  simp only [inv_fun, dif_pos h, h.some_spec]
#align function.inv_fun_eq Function.invFun_eq
-/

#print Function.invFun_neg /-
theorem invFun_neg (h : ¬∃ a, f a = b) : invFun f b = Classical.choice ‹_› :=
  dif_neg h
#align function.inv_fun_neg Function.invFun_neg
-/

#print Function.invFun_eq_of_injective_of_rightInverse /-
theorem invFun_eq_of_injective_of_rightInverse {g : β → α} (hf : Injective f)
    (hg : RightInverse g f) : invFun f = g :=
  funext fun b => hf (by rw [hg b]; exact inv_fun_eq ⟨g b, hg b⟩)
#align function.inv_fun_eq_of_injective_of_right_inverse Function.invFun_eq_of_injective_of_rightInverse
-/

#print Function.rightInverse_invFun /-
theorem rightInverse_invFun (hf : Surjective f) : RightInverse (invFun f) f := fun b =>
  invFun_eq <| hf b
#align function.right_inverse_inv_fun Function.rightInverse_invFun
-/

#print Function.leftInverse_invFun /-
theorem leftInverse_invFun (hf : Injective f) : LeftInverse (invFun f) f := fun b =>
  hf <| invFun_eq ⟨b, rfl⟩
#align function.left_inverse_inv_fun Function.leftInverse_invFun
-/

#print Function.invFun_surjective /-
theorem invFun_surjective (hf : Injective f) : Surjective (invFun f) :=
  (leftInverse_invFun hf).Surjective
#align function.inv_fun_surjective Function.invFun_surjective
-/

#print Function.invFun_comp /-
theorem invFun_comp (hf : Injective f) : invFun f ∘ f = id :=
  funext <| leftInverse_invFun hf
#align function.inv_fun_comp Function.invFun_comp
-/

#print Function.Injective.hasLeftInverse /-
theorem Injective.hasLeftInverse (hf : Injective f) : HasLeftInverse f :=
  ⟨invFun f, leftInverse_invFun hf⟩
#align function.injective.has_left_inverse Function.Injective.hasLeftInverse
-/

#print Function.injective_iff_hasLeftInverse /-
theorem injective_iff_hasLeftInverse : Injective f ↔ HasLeftInverse f :=
  ⟨Injective.hasLeftInverse, HasLeftInverse.injective⟩
#align function.injective_iff_has_left_inverse Function.injective_iff_hasLeftInverse
-/

end InvFun

section SurjInv

variable {α : Sort u} {β : Sort v} {γ : Sort w} {f : α → β}

#print Function.surjInv /-
/-- The inverse of a surjective function. (Unlike `inv_fun`, this does not require
  `α` to be inhabited.) -/
noncomputable def surjInv {f : α → β} (h : Surjective f) (b : β) : α :=
  Classical.choose (h b)
#align function.surj_inv Function.surjInv
-/

#print Function.surjInv_eq /-
theorem surjInv_eq (h : Surjective f) (b) : f (surjInv h b) = b :=
  Classical.choose_spec (h b)
#align function.surj_inv_eq Function.surjInv_eq
-/

#print Function.rightInverse_surjInv /-
theorem rightInverse_surjInv (hf : Surjective f) : RightInverse (surjInv hf) f :=
  surjInv_eq hf
#align function.right_inverse_surj_inv Function.rightInverse_surjInv
-/

#print Function.leftInverse_surjInv /-
theorem leftInverse_surjInv (hf : Bijective f) : LeftInverse (surjInv hf.2) f :=
  rightInverse_of_injective_of_leftInverse hf.1 (rightInverse_surjInv hf.2)
#align function.left_inverse_surj_inv Function.leftInverse_surjInv
-/

#print Function.Surjective.hasRightInverse /-
theorem Surjective.hasRightInverse (hf : Surjective f) : HasRightInverse f :=
  ⟨_, rightInverse_surjInv hf⟩
#align function.surjective.has_right_inverse Function.Surjective.hasRightInverse
-/

#print Function.surjective_iff_hasRightInverse /-
theorem surjective_iff_hasRightInverse : Surjective f ↔ HasRightInverse f :=
  ⟨Surjective.hasRightInverse, HasRightInverse.surjective⟩
#align function.surjective_iff_has_right_inverse Function.surjective_iff_hasRightInverse
-/

#print Function.bijective_iff_has_inverse /-
theorem bijective_iff_has_inverse : Bijective f ↔ ∃ g, LeftInverse g f ∧ RightInverse g f :=
  ⟨fun hf => ⟨_, leftInverse_surjInv hf, rightInverse_surjInv hf.2⟩, fun ⟨g, gl, gr⟩ =>
    ⟨gl.Injective, gr.Surjective⟩⟩
#align function.bijective_iff_has_inverse Function.bijective_iff_has_inverse
-/

#print Function.injective_surjInv /-
theorem injective_surjInv (h : Surjective f) : Injective (surjInv h) :=
  (rightInverse_surjInv h).Injective
#align function.injective_surj_inv Function.injective_surjInv
-/

#print Function.surjective_to_subsingleton /-
theorem surjective_to_subsingleton [na : Nonempty α] [Subsingleton β] (f : α → β) : Surjective f :=
  fun y =>
  let ⟨a⟩ := na
  ⟨a, Subsingleton.elim _ _⟩
#align function.surjective_to_subsingleton Function.surjective_to_subsingleton
-/

#print Function.Surjective.comp_left /-
/-- Composition by an surjective function on the left is itself surjective. -/
theorem Surjective.comp_left {g : β → γ} (hg : Surjective g) :
    Surjective ((· ∘ ·) g : (α → β) → α → γ) := fun f =>
  ⟨surjInv hg ∘ f, funext fun x => rightInverse_surjInv _ _⟩
#align function.surjective.comp_left Function.Surjective.comp_left
-/

#print Function.Bijective.comp_left /-
/-- Composition by an bijective function on the left is itself bijective. -/
theorem Bijective.comp_left {g : β → γ} (hg : Bijective g) :
    Bijective ((· ∘ ·) g : (α → β) → α → γ) :=
  ⟨hg.Injective.compLeft, hg.Surjective.compLeft⟩
#align function.bijective.comp_left Function.Bijective.comp_left
-/

end SurjInv

section Update

variable {α : Sort u} {β : α → Sort v} {α' : Sort w} [DecidableEq α] [DecidableEq α']
  {f g : ∀ a, β a} {a : α} {b : β a}

#print Function.update /-
/-- Replacing the value of a function at a given point by a given value. -/
def update (f : ∀ a, β a) (a' : α) (v : β a') (a : α) : β a :=
  if h : a = a' then Eq.ndrec v h.symm else f a
#align function.update Function.update
-/

#print Function.update_apply /-
/-- On non-dependent functions, `function.update` can be expressed as an `ite` -/
theorem update_apply {β : Sort _} (f : α → β) (a' : α) (b : β) (a : α) :
    update f a' b a = if a = a' then b else f a :=
  by
  dsimp only [update]
  congr
  funext
  rw [eq_rec_constant]
#align function.update_apply Function.update_apply
-/

#print Function.update_same /-
@[simp]
theorem update_same (a : α) (v : β a) (f : ∀ a, β a) : update f a v a = v :=
  dif_pos rfl
#align function.update_same Function.update_same
-/

#print Function.surjective_eval /-
theorem surjective_eval {α : Sort u} {β : α → Sort v} [h : ∀ a, Nonempty (β a)] (a : α) :
    Surjective (eval a : (∀ a, β a) → β a) := fun b =>
  ⟨@update _ _ (Classical.decEq α) (fun a => (h a).some) a b,
    @update_same _ _ (Classical.decEq α) _ _ _⟩
#align function.surjective_eval Function.surjective_eval
-/

#print Function.update_injective /-
theorem update_injective (f : ∀ a, β a) (a' : α) : Injective (update f a') := fun v v' h =>
  by
  have := congr_fun h a'
  rwa [update_same, update_same] at this 
#align function.update_injective Function.update_injective
-/

#print Function.update_noteq /-
@[simp]
theorem update_noteq {a a' : α} (h : a ≠ a') (v : β a') (f : ∀ a, β a) : update f a' v a = f a :=
  dif_neg h
#align function.update_noteq Function.update_noteq
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x «expr ≠ » a) -/
#print Function.forall_update_iff /-
theorem forall_update_iff (f : ∀ a, β a) {a : α} {b : β a} (p : ∀ a, β a → Prop) :
    (∀ x, p x (update f a b x)) ↔ p a b ∧ ∀ (x) (_ : x ≠ a), p x (f x) := by
  rw [← and_forall_ne a, update_same]; simp (config := { contextual := true })
#align function.forall_update_iff Function.forall_update_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x «expr ≠ » a) -/
#print Function.exists_update_iff /-
theorem exists_update_iff (f : ∀ a, β a) {a : α} {b : β a} (p : ∀ a, β a → Prop) :
    (∃ x, p x (update f a b x)) ↔ p a b ∨ ∃ (x : _) (_ : x ≠ a), p x (f x) := by
  rw [← not_forall_not, forall_update_iff f fun a b => ¬p a b]; simp [not_and_or]
#align function.exists_update_iff Function.exists_update_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x «expr ≠ » a) -/
#print Function.update_eq_iff /-
theorem update_eq_iff {a : α} {b : β a} {f g : ∀ a, β a} :
    update f a b = g ↔ b = g a ∧ ∀ (x) (_ : x ≠ a), f x = g x :=
  funext_iff.trans <| forall_update_iff _ fun x y => y = g x
#align function.update_eq_iff Function.update_eq_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x «expr ≠ » a) -/
#print Function.eq_update_iff /-
theorem eq_update_iff {a : α} {b : β a} {f g : ∀ a, β a} :
    g = update f a b ↔ g a = b ∧ ∀ (x) (_ : x ≠ a), g x = f x :=
  funext_iff.trans <| forall_update_iff _ fun x y => g x = y
#align function.eq_update_iff Function.eq_update_iff
-/

#print Function.update_eq_self_iff /-
@[simp]
theorem update_eq_self_iff : update f a b = f ↔ b = f a := by simp [update_eq_iff]
#align function.update_eq_self_iff Function.update_eq_self_iff
-/

#print Function.eq_update_self_iff /-
@[simp]
theorem eq_update_self_iff : f = update f a b ↔ f a = b := by simp [eq_update_iff]
#align function.eq_update_self_iff Function.eq_update_self_iff
-/

#print Function.ne_update_self_iff /-
theorem ne_update_self_iff : f ≠ update f a b ↔ f a ≠ b :=
  eq_update_self_iff.Not
#align function.ne_update_self_iff Function.ne_update_self_iff
-/

#print Function.update_ne_self_iff /-
theorem update_ne_self_iff : update f a b ≠ f ↔ b ≠ f a :=
  update_eq_self_iff.Not
#align function.update_ne_self_iff Function.update_ne_self_iff
-/

#print Function.update_eq_self /-
@[simp]
theorem update_eq_self (a : α) (f : ∀ a, β a) : update f a (f a) = f :=
  update_eq_iff.2 ⟨rfl, fun _ _ => rfl⟩
#align function.update_eq_self Function.update_eq_self
-/

#print Function.update_comp_eq_of_forall_ne' /-
theorem update_comp_eq_of_forall_ne' {α'} (g : ∀ a, β a) {f : α' → α} {i : α} (a : β i)
    (h : ∀ x, f x ≠ i) : (fun j => (update g i a) (f j)) = fun j => g (f j) :=
  funext fun x => update_noteq (h _) _ _
#align function.update_comp_eq_of_forall_ne' Function.update_comp_eq_of_forall_ne'
-/

#print Function.update_comp_eq_of_forall_ne /-
/-- Non-dependent version of `function.update_comp_eq_of_forall_ne'` -/
theorem update_comp_eq_of_forall_ne {α β : Sort _} (g : α' → β) {f : α → α'} {i : α'} (a : β)
    (h : ∀ x, f x ≠ i) : update g i a ∘ f = g ∘ f :=
  update_comp_eq_of_forall_ne' g a h
#align function.update_comp_eq_of_forall_ne Function.update_comp_eq_of_forall_ne
-/

#print Function.update_comp_eq_of_injective' /-
theorem update_comp_eq_of_injective' (g : ∀ a, β a) {f : α' → α} (hf : Function.Injective f)
    (i : α') (a : β (f i)) : (fun j => update g (f i) a (f j)) = update (fun i => g (f i)) i a :=
  eq_update_iff.2 ⟨update_same _ _ _, fun j hj => update_noteq (hf.Ne hj) _ _⟩
#align function.update_comp_eq_of_injective' Function.update_comp_eq_of_injective'
-/

#print Function.update_comp_eq_of_injective /-
/-- Non-dependent version of `function.update_comp_eq_of_injective'` -/
theorem update_comp_eq_of_injective {β : Sort _} (g : α' → β) {f : α → α'}
    (hf : Function.Injective f) (i : α) (a : β) :
    Function.update g (f i) a ∘ f = Function.update (g ∘ f) i a :=
  update_comp_eq_of_injective' g hf i a
#align function.update_comp_eq_of_injective Function.update_comp_eq_of_injective
-/

#print Function.apply_update /-
theorem apply_update {ι : Sort _} [DecidableEq ι] {α β : ι → Sort _} (f : ∀ i, α i → β i)
    (g : ∀ i, α i) (i : ι) (v : α i) (j : ι) :
    f j (update g i v j) = update (fun k => f k (g k)) i (f i v) j :=
  by
  by_cases h : j = i
  · subst j; simp
  · simp [h]
#align function.apply_update Function.apply_update
-/

#print Function.apply_update₂ /-
theorem apply_update₂ {ι : Sort _} [DecidableEq ι] {α β γ : ι → Sort _} (f : ∀ i, α i → β i → γ i)
    (g : ∀ i, α i) (h : ∀ i, β i) (i : ι) (v : α i) (w : β i) (j : ι) :
    f j (update g i v j) (update h i w j) = update (fun k => f k (g k) (h k)) i (f i v w) j :=
  by
  by_cases h : j = i
  · subst j; simp
  · simp [h]
#align function.apply_update₂ Function.apply_update₂
-/

#print Function.comp_update /-
theorem comp_update {α' : Sort _} {β : Sort _} (f : α' → β) (g : α → α') (i : α) (v : α') :
    f ∘ update g i v = update (f ∘ g) i (f v) :=
  funext <| apply_update _ _ _ _
#align function.comp_update Function.comp_update
-/

#print Function.update_comm /-
theorem update_comm {α} [DecidableEq α] {β : α → Sort _} {a b : α} (h : a ≠ b) (v : β a) (w : β b)
    (f : ∀ a, β a) : update (update f a v) b w = update (update f b w) a v :=
  by
  funext c; simp only [update]
  by_cases h₁ : c = b <;> by_cases h₂ : c = a <;> try simp [h₁, h₂]
  cases h (h₂.symm.trans h₁)
#align function.update_comm Function.update_comm
-/

#print Function.update_idem /-
@[simp]
theorem update_idem {α} [DecidableEq α] {β : α → Sort _} {a : α} (v w : β a) (f : ∀ a, β a) :
    update (update f a v) a w = update f a w := by funext b; by_cases b = a <;> simp [update, h]
#align function.update_idem Function.update_idem
-/

end Update

section Extend

noncomputable section

attribute [local instance 10] Classical.propDecidable

variable {α β γ : Sort _} {f : α → β}

#print Function.extend /-
/-- `extend f g e'` extends a function `g : α → γ`
along a function `f : α → β` to a function `β → γ`,
by using the values of `g` on the range of `f`
and the values of an auxiliary function `e' : β → γ` elsewhere.

Mostly useful when `f` is injective, more generally when `g.factors_through f`. -/
def extend (f : α → β) (g : α → γ) (e' : β → γ) : β → γ := fun b =>
  if h : ∃ a, f a = b then g (Classical.choose h) else e' b
#align function.extend Function.extend
-/

#print Function.FactorsThrough /-
/-- g factors through f : `f a = f b → g a = g b` -/
def FactorsThrough (g : α → γ) (f : α → β) : Prop :=
  ∀ ⦃a b⦄, f a = f b → g a = g b
#align function.factors_through Function.FactorsThrough
-/

#print Function.Injective.FactorsThrough /-
theorem Injective.FactorsThrough (hf : Injective f) (g : α → γ) : g.FactorsThrough f := fun a b h =>
  congr_arg g (hf h)
#align function.injective.factors_through Function.Injective.FactorsThrough
-/

#print Function.extend_def /-
theorem extend_def (f : α → β) (g : α → γ) (e' : β → γ) (b : β) [Decidable (∃ a, f a = b)] :
    extend f g e' b = if h : ∃ a, f a = b then g (Classical.choose h) else e' b := by unfold extend;
  congr
#align function.extend_def Function.extend_def
-/

#print Function.FactorsThrough.extend_apply /-
theorem FactorsThrough.extend_apply {g : α → γ} (hf : g.FactorsThrough f) (e' : β → γ) (a : α) :
    extend f g e' (f a) = g a :=
  by
  simp only [extend_def, dif_pos, exists_apply_eq_apply]
  exact hf (Classical.choose_spec (exists_apply_eq_apply f a))
#align function.factors_through.extend_apply Function.FactorsThrough.extend_apply
-/

#print Function.Injective.extend_apply /-
@[simp]
theorem Injective.extend_apply (hf : f.Injective) (g : α → γ) (e' : β → γ) (a : α) :
    extend f g e' (f a) = g a :=
  (hf.FactorsThrough g).extend_apply e' a
#align function.injective.extend_apply Function.Injective.extend_apply
-/

#print Function.extend_apply' /-
@[simp]
theorem extend_apply' (g : α → γ) (e' : β → γ) (b : β) (hb : ¬∃ a, f a = b) :
    extend f g e' b = e' b := by simp [Function.extend_def, hb]
#align function.extend_apply' Function.extend_apply'
-/

#print Function.factorsThrough_iff /-
theorem factorsThrough_iff (g : α → γ) [Nonempty γ] : g.FactorsThrough f ↔ ∃ e : β → γ, g = e ∘ f :=
  ⟨fun hf =>
    ⟨extend f g (const β (Classical.arbitrary γ)),
      funext fun x => by simp only [comp_app, hf.extend_apply]⟩,
    fun h a b hf => by rw [Classical.choose_spec h, comp_apply, hf]⟩
#align function.factors_through_iff Function.factorsThrough_iff
-/

#print Function.FactorsThrough.apply_extend /-
theorem FactorsThrough.apply_extend {δ} {g : α → γ} (hf : FactorsThrough g f) (F : γ → δ)
    (e' : β → γ) (b : β) : F (extend f g e' b) = extend f (F ∘ g) (F ∘ e') b :=
  by
  by_cases hb : ∃ a, f a = b
  · cases' hb with a ha; subst b
    rw [factors_through.extend_apply, factors_through.extend_apply]
    · intro a b h; simp only [comp_apply]; apply congr_arg; exact hf h
    · exact hf
  · rw [extend_apply' _ _ _ hb, extend_apply' _ _ _ hb]
#align function.factors_through.apply_extend Function.FactorsThrough.apply_extend
-/

#print Function.Injective.apply_extend /-
theorem Injective.apply_extend {δ} (hf : Injective f) (F : γ → δ) (g : α → γ) (e' : β → γ) (b : β) :
    F (extend f g e' b) = extend f (F ∘ g) (F ∘ e') b :=
  (hf.FactorsThrough g).apply_extend F e' b
#align function.injective.apply_extend Function.Injective.apply_extend
-/

#print Function.extend_injective /-
theorem extend_injective (hf : Injective f) (e' : β → γ) : Injective fun g => extend f g e' :=
  by
  intro g₁ g₂ hg
  refine' funext fun x => _
  have H := congr_fun hg (f x)
  simp only [hf.extend_apply] at H 
  exact H
#align function.extend_injective Function.extend_injective
-/

#print Function.FactorsThrough.extend_comp /-
theorem FactorsThrough.extend_comp {g : α → γ} (e' : β → γ) (hf : FactorsThrough g f) :
    extend f g e' ∘ f = g :=
  funext fun a => by simp only [comp_app, hf.extend_apply e']
#align function.factors_through.extend_comp Function.FactorsThrough.extend_comp
-/

#print Function.extend_comp /-
@[simp]
theorem extend_comp (hf : Injective f) (g : α → γ) (e' : β → γ) : extend f g e' ∘ f = g :=
  (hf.FactorsThrough g).extend_comp e'
#align function.extend_comp Function.extend_comp
-/

#print Function.Injective.surjective_comp_right' /-
theorem Injective.surjective_comp_right' (hf : Injective f) (g₀ : β → γ) :
    Surjective fun g : β → γ => g ∘ f := fun g => ⟨extend f g g₀, extend_comp hf _ _⟩
#align function.injective.surjective_comp_right' Function.Injective.surjective_comp_right'
-/

#print Function.Injective.surjective_comp_right /-
theorem Injective.surjective_comp_right [Nonempty γ] (hf : Injective f) :
    Surjective fun g : β → γ => g ∘ f :=
  hf.surjective_comp_right' fun _ => Classical.choice ‹_›
#align function.injective.surjective_comp_right Function.Injective.surjective_comp_right
-/

#print Function.Bijective.comp_right /-
theorem Bijective.comp_right (hf : Bijective f) : Bijective fun g : β → γ => g ∘ f :=
  ⟨hf.Surjective.injective_comp_right, fun g =>
    ⟨g ∘ surjInv hf.Surjective, by
      simp only [comp.assoc g _ f, (left_inverse_surj_inv hf).comp_eq_id, comp.right_id]⟩⟩
#align function.bijective.comp_right Function.Bijective.comp_right
-/

end Extend

#print Function.uncurry_def /-
theorem uncurry_def {α β γ} (f : α → β → γ) : uncurry f = fun p => f p.1 p.2 :=
  rfl
#align function.uncurry_def Function.uncurry_def
-/

#print Function.uncurry_apply_pair /-
@[simp]
theorem uncurry_apply_pair {α β γ} (f : α → β → γ) (x : α) (y : β) : uncurry f (x, y) = f x y :=
  rfl
#align function.uncurry_apply_pair Function.uncurry_apply_pair
-/

#print Function.curry_apply /-
@[simp]
theorem curry_apply {α β γ} (f : α × β → γ) (x : α) (y : β) : curry f x y = f (x, y) :=
  rfl
#align function.curry_apply Function.curry_apply
-/

section Bicomp

variable {α β γ δ ε : Type _}

#print Function.bicompl /-
/-- Compose a binary function `f` with a pair of unary functions `g` and `h`.
If both arguments of `f` have the same type and `g = h`, then `bicompl f g g = f on g`. -/
def bicompl (f : γ → δ → ε) (g : α → γ) (h : β → δ) (a b) :=
  f (g a) (h b)
#align function.bicompl Function.bicompl
-/

#print Function.bicompr /-
/-- Compose an unary function `f` with a binary function `g`. -/
def bicompr (f : γ → δ) (g : α → β → γ) (a b) :=
  f (g a b)
#align function.bicompr Function.bicompr
-/

-- Suggested local notation:
local notation f " ∘₂ " g => bicompr f g

#print Function.uncurry_bicompr /-
theorem uncurry_bicompr (f : α → β → γ) (g : γ → δ) : uncurry (g ∘₂ f) = g ∘ uncurry f :=
  rfl
#align function.uncurry_bicompr Function.uncurry_bicompr
-/

#print Function.uncurry_bicompl /-
theorem uncurry_bicompl (f : γ → δ → ε) (g : α → γ) (h : β → δ) :
    uncurry (bicompl f g h) = uncurry f ∘ Prod.map g h :=
  rfl
#align function.uncurry_bicompl Function.uncurry_bicompl
-/

end Bicomp

section Uncurry

variable {α β γ δ : Type _}

#print Function.HasUncurry /-
/-- Records a way to turn an element of `α` into a function from `β` to `γ`. The most generic use
is to recursively uncurry. For instance `f : α → β → γ → δ` will be turned into
`↿f : α × β × γ → δ`. One can also add instances for bundled maps. -/
class HasUncurry (α : Type _) (β : outParam (Type _)) (γ : outParam (Type _)) where
  uncurry : α → β → γ
#align function.has_uncurry Function.HasUncurry
-/

/-- Uncurrying operator. The most generic use is to recursively uncurry. For instance
`f : α → β → γ → δ` will be turned into `↿f : α × β × γ → δ`. One can also add instances
for bundled maps.-/
add_decl_doc has_uncurry.uncurry

notation:arg "↿" x:arg => HasUncurry.uncurry x

#print Function.hasUncurryBase /-
instance hasUncurryBase : HasUncurry (α → β) α β :=
  ⟨id⟩
#align function.has_uncurry_base Function.hasUncurryBase
-/

#print Function.hasUncurryInduction /-
instance hasUncurryInduction [HasUncurry β γ δ] : HasUncurry (α → β) (α × γ) δ :=
  ⟨fun f p => (↿(f p.1)) p.2⟩
#align function.has_uncurry_induction Function.hasUncurryInduction
-/

end Uncurry

#print Function.Involutive /-
/-- A function is involutive, if `f ∘ f = id`. -/
def Involutive {α} (f : α → α) : Prop :=
  ∀ x, f (f x) = x
#align function.involutive Function.Involutive
-/

#print Function.involutive_iff_iter_2_eq_id /-
theorem involutive_iff_iter_2_eq_id {α} {f : α → α} : Involutive f ↔ f^[2] = id :=
  funext_iff.symm
#align function.involutive_iff_iter_2_eq_id Function.involutive_iff_iter_2_eq_id
-/

#print Bool.involutive_not /-
theorem Bool.involutive_not : Involutive not :=
  Bool.not_not
#align bool.involutive_bnot Bool.involutive_not
-/

namespace Involutive

variable {α : Sort u} {f : α → α} (h : Involutive f)

#print Function.Involutive.comp_self /-
@[simp]
theorem comp_self : f ∘ f = id :=
  funext h
#align function.involutive.comp_self Function.Involutive.comp_self
-/

#print Function.Involutive.leftInverse /-
protected theorem leftInverse : LeftInverse f f :=
  h
#align function.involutive.left_inverse Function.Involutive.leftInverse
-/

#print Function.Involutive.rightInverse /-
protected theorem rightInverse : RightInverse f f :=
  h
#align function.involutive.right_inverse Function.Involutive.rightInverse
-/

#print Function.Involutive.injective /-
protected theorem injective : Injective f :=
  h.LeftInverse.Injective
#align function.involutive.injective Function.Involutive.injective
-/

#print Function.Involutive.surjective /-
protected theorem surjective : Surjective f := fun x => ⟨f x, h x⟩
#align function.involutive.surjective Function.Involutive.surjective
-/

#print Function.Involutive.bijective /-
protected theorem bijective : Bijective f :=
  ⟨h.Injective, h.Surjective⟩
#align function.involutive.bijective Function.Involutive.bijective
-/

#print Function.Involutive.ite_not /-
/-- Involuting an `ite` of an involuted value `x : α` negates the `Prop` condition in the `ite`. -/
protected theorem ite_not (P : Prop) [Decidable P] (x : α) : f (ite P x (f x)) = ite (¬P) x (f x) :=
  by rw [apply_ite f, h, ite_not]
#align function.involutive.ite_not Function.Involutive.ite_not
-/

#print Function.Involutive.eq_iff /-
/-- An involution commutes across an equality. Compare to `function.injective.eq_iff`. -/
protected theorem eq_iff {x y : α} : f x = y ↔ x = f y :=
  h.Injective.eq_iff' (h y)
#align function.involutive.eq_iff Function.Involutive.eq_iff
-/

end Involutive

#print Function.Injective2 /-
/-- The property of a binary function `f : α → β → γ` being injective.
Mathematically this should be thought of as the corresponding function `α × β → γ` being injective.
-/
def Injective2 {α β γ} (f : α → β → γ) : Prop :=
  ∀ ⦃a₁ a₂ b₁ b₂⦄, f a₁ b₁ = f a₂ b₂ → a₁ = a₂ ∧ b₁ = b₂
#align function.injective2 Function.Injective2
-/

namespace Injective2

variable {α β γ : Sort _} {f : α → β → γ}

#print Function.Injective2.left /-
/-- A binary injective function is injective when only the left argument varies. -/
protected theorem left (hf : Injective2 f) (b : β) : Function.Injective fun a => f a b :=
  fun a₁ a₂ h => (hf h).left
#align function.injective2.left Function.Injective2.left
-/

#print Function.Injective2.right /-
/-- A binary injective function is injective when only the right argument varies. -/
protected theorem right (hf : Injective2 f) (a : α) : Function.Injective (f a) := fun a₁ a₂ h =>
  (hf h).right
#align function.injective2.right Function.Injective2.right
-/

#print Function.Injective2.uncurry /-
protected theorem uncurry {α β γ : Type _} {f : α → β → γ} (hf : Injective2 f) :
    Function.Injective (uncurry f) := fun ⟨a₁, b₁⟩ ⟨a₂, b₂⟩ h => And.elim (hf h) (congr_arg₂ _)
#align function.injective2.uncurry Function.Injective2.uncurry
-/

#print Function.Injective2.left' /-
/-- As a map from the left argument to a unary function, `f` is injective. -/
theorem left' (hf : Injective2 f) [Nonempty β] : Function.Injective f := fun a₁ a₂ h =>
  let ⟨b⟩ := ‹Nonempty β›
  hf.left b <| (congr_fun h b : _)
#align function.injective2.left' Function.Injective2.left'
-/

#print Function.Injective2.right' /-
/-- As a map from the right argument to a unary function, `f` is injective. -/
theorem right' (hf : Injective2 f) [Nonempty α] : Function.Injective fun b a => f a b :=
  fun b₁ b₂ h =>
  let ⟨a⟩ := ‹Nonempty α›
  hf.right a <| (congr_fun h a : _)
#align function.injective2.right' Function.Injective2.right'
-/

#print Function.Injective2.eq_iff /-
theorem eq_iff (hf : Injective2 f) {a₁ a₂ b₁ b₂} : f a₁ b₁ = f a₂ b₂ ↔ a₁ = a₂ ∧ b₁ = b₂ :=
  ⟨fun h => hf h, And.ndrec <| congr_arg₂ f⟩
#align function.injective2.eq_iff Function.Injective2.eq_iff
-/

end Injective2

section Sometimes

attribute [local instance 10] Classical.propDecidable

#print Function.sometimes /-
/-- `sometimes f` evaluates to some value of `f`, if it exists. This function is especially
interesting in the case where `α` is a proposition, in which case `f` is necessarily a
constant function, so that `sometimes f = f a` for all `a`. -/
noncomputable def sometimes {α β} [Nonempty β] (f : α → β) : β :=
  if h : Nonempty α then f (Classical.choice h) else Classical.choice ‹_›
#align function.sometimes Function.sometimes
-/

#print Function.sometimes_eq /-
theorem sometimes_eq {p : Prop} {α} [Nonempty α] (f : p → α) (a : p) : sometimes f = f a :=
  dif_pos ⟨a⟩
#align function.sometimes_eq Function.sometimes_eq
-/

#print Function.sometimes_spec /-
theorem sometimes_spec {p : Prop} {α} [Nonempty α] (P : α → Prop) (f : p → α) (a : p)
    (h : P (f a)) : P (sometimes f) := by rwa [sometimes_eq]
#align function.sometimes_spec Function.sometimes_spec
-/

end Sometimes

end Function

#print Set.piecewise /-
/-- `s.piecewise f g` is the function equal to `f` on the set `s`, and to `g` on its complement. -/
def Set.piecewise {α : Type u} {β : α → Sort v} (s : Set α) (f g : ∀ i, β i)
    [∀ j, Decidable (j ∈ s)] : ∀ i, β i := fun i => if i ∈ s then f i else g i
#align set.piecewise Set.piecewise
-/

/-! ### Bijectivity of `eq.rec`, `eq.mp`, `eq.mpr`, and `cast` -/


#print eq_rec_on_bijective /-
theorem eq_rec_on_bijective {α : Sort _} {C : α → Sort _} :
    ∀ {a a' : α} (h : a = a'), Function.Bijective (@Eq.recOn _ _ C _ h)
  | _, _, rfl => ⟨fun x y => id, fun x => ⟨x, rfl⟩⟩
#align eq_rec_on_bijective eq_rec_on_bijective
-/

#print eq_mp_bijective /-
theorem eq_mp_bijective {α β : Sort _} (h : α = β) : Function.Bijective (Eq.mp h) :=
  eq_rec_on_bijective h
#align eq_mp_bijective eq_mp_bijective
-/

#print eq_mpr_bijective /-
theorem eq_mpr_bijective {α β : Sort _} (h : α = β) : Function.Bijective (Eq.mpr h) :=
  eq_rec_on_bijective h.symm
#align eq_mpr_bijective eq_mpr_bijective
-/

#print cast_bijective /-
theorem cast_bijective {α β : Sort _} (h : α = β) : Function.Bijective (cast h) :=
  eq_rec_on_bijective h
#align cast_bijective cast_bijective
-/

/-! Note these lemmas apply to `Type*` not `Sort*`, as the latter interferes with `simp`, and
is trivial anyway.-/


#print eq_rec_inj /-
@[simp]
theorem eq_rec_inj {α : Sort _} {a a' : α} (h : a = a') {C : α → Type _} (x y : C a) :
    (Eq.ndrec x h : C a') = Eq.ndrec y h ↔ x = y :=
  (eq_rec_on_bijective h).Injective.eq_iff
#align eq_rec_inj eq_rec_inj
-/

#print cast_inj /-
@[simp]
theorem cast_inj {α β : Type _} (h : α = β) {x y : α} : cast h x = cast h y ↔ x = y :=
  (cast_bijective h).Injective.eq_iff
#align cast_inj cast_inj
-/

#print Function.LeftInverse.eq_rec_eq /-
theorem Function.LeftInverse.eq_rec_eq {α β : Sort _} {γ : β → Sort v} {f : α → β} {g : β → α}
    (h : Function.LeftInverse g f) (C : ∀ a : α, γ (f a)) (a : α) :
    (congr_arg f (h a)).rec (C (g (f a))) = C a :=
  eq_of_hEq <| (eq_rec_hEq _ _).trans <| by rw [h]
#align function.left_inverse.eq_rec_eq Function.LeftInverse.eq_rec_eq
-/

#print Function.LeftInverse.eq_rec_on_eq /-
theorem Function.LeftInverse.eq_rec_on_eq {α β : Sort _} {γ : β → Sort v} {f : α → β} {g : β → α}
    (h : Function.LeftInverse g f) (C : ∀ a : α, γ (f a)) (a : α) :
    (congr_arg f (h a)).recOn (C (g (f a))) = C a :=
  h.eq_rec_eq _ _
#align function.left_inverse.eq_rec_on_eq Function.LeftInverse.eq_rec_on_eq
-/

#print Function.LeftInverse.cast_eq /-
theorem Function.LeftInverse.cast_eq {α β : Sort _} {γ : β → Sort v} {f : α → β} {g : β → α}
    (h : Function.LeftInverse g f) (C : ∀ a : α, γ (f a)) (a : α) :
    cast (congr_arg (fun a => γ (f a)) (h a)) (C (g (f a))) = C a :=
  eq_of_hEq <| (eq_rec_hEq _ _).trans <| by rw [h]
#align function.left_inverse.cast_eq Function.LeftInverse.cast_eq
-/

#print Set.SeparatesPoints /-
/-- A set of functions "separates points"
if for each pair of distinct points there is a function taking different values on them. -/
def Set.SeparatesPoints {α β : Type _} (A : Set (α → β)) : Prop :=
  ∀ ⦃x y : α⦄, x ≠ y → ∃ f ∈ A, (f x : β) ≠ f y
#align set.separates_points Set.SeparatesPoints
-/

#print IsSymmOp.flip_eq /-
theorem IsSymmOp.flip_eq {α β} (op) [IsSymmOp α β op] : flip op = op :=
  funext fun a => funext fun b => (IsSymmOp.symm_op a b).symm
#align is_symm_op.flip_eq IsSymmOp.flip_eq
-/

#print InvImage.equivalence /-
theorem InvImage.equivalence {α : Sort u} {β : Sort v} (r : β → β → Prop) (f : α → β)
    (h : Equivalence r) : Equivalence (InvImage r f) :=
  ⟨fun _ => h.1 _, fun _ _ x => h.2.1 x, InvImage.trans r f h.2.2⟩
#align inv_image.equivalence InvImage.equivalence
-/

