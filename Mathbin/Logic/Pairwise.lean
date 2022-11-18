/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl
-/
import Mathbin.Logic.Function.Basic
import Mathbin.Tactic.Basic

/-!
# Relations holding pairwise

This file defines pairwise relations.

## Main declarations

* `pairwise`: `pairwise r` states that `r i j` for all `i ≠ j`.
* `set.pairwise`: `s.pairwise r` states that `r i j` for all `i ≠ j` with `i, j ∈ s`.
-/


open Set Function

variable {α β γ ι ι' : Type _} {r p q : α → α → Prop}

section Pairwise

variable {f g : ι → α} {s t u : Set α} {a b : α}

#print Pairwise /-
/-- A relation `r` holds pairwise if `r i j` for all `i ≠ j`. -/
def Pairwise (r : α → α → Prop) :=
  ∀ ⦃i j⦄, i ≠ j → r i j
#align pairwise Pairwise
-/

#print Pairwise.mono /-
theorem Pairwise.mono (hr : Pairwise r) (h : ∀ ⦃i j⦄, r i j → p i j) : Pairwise p := fun i j hij => h <| hr hij
#align pairwise.mono Pairwise.mono
-/

#print Pairwise.eq /-
protected theorem Pairwise.eq (h : Pairwise r) : ¬r a b → a = b :=
  not_imp_comm.1 <| @h _ _
#align pairwise.eq Pairwise.eq
-/

#print Function.injective_iff_pairwise_ne /-
theorem Function.injective_iff_pairwise_ne : Injective f ↔ Pairwise ((· ≠ ·) on f) :=
  forall₂_congr fun i j => not_imp_not.symm
#align function.injective_iff_pairwise_ne Function.injective_iff_pairwise_ne
-/

alias Function.injective_iff_pairwise_ne ↔ Function.Injective.pairwise_ne _

namespace Set

#print Set.Pairwise /-
/-- The relation `r` holds pairwise on the set `s` if `r x y` for all *distinct* `x y ∈ s`. -/
protected def Pairwise (s : Set α) (r : α → α → Prop) :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → x ≠ y → r x y
#align set.pairwise Set.Pairwise
-/

#print Set.pairwise_of_forall /-
theorem pairwise_of_forall (s : Set α) (r : α → α → Prop) (h : ∀ a b, r a b) : s.Pairwise r := fun a _ b _ _ => h a b
#align set.pairwise_of_forall Set.pairwise_of_forall
-/

#print Set.Pairwise.imp_on /-
theorem Pairwise.imp_on (h : s.Pairwise r) (hrp : s.Pairwise fun ⦃a b : α⦄ => r a b → p a b) : s.Pairwise p :=
  fun a ha b hb hab => hrp ha hb hab <| h ha hb hab
#align set.pairwise.imp_on Set.Pairwise.imp_on
-/

#print Set.Pairwise.imp /-
theorem Pairwise.imp (h : s.Pairwise r) (hpq : ∀ ⦃a b : α⦄, r a b → p a b) : s.Pairwise p :=
  h.imp_on <| pairwise_of_forall s _ hpq
#align set.pairwise.imp Set.Pairwise.imp
-/

#print Set.Pairwise.eq /-
protected theorem Pairwise.eq (hs : s.Pairwise r) (ha : a ∈ s) (hb : b ∈ s) (h : ¬r a b) : a = b :=
  of_not_not fun hab => h <| hs ha hb hab
#align set.pairwise.eq Set.Pairwise.eq
-/

theorem _root_.reflexive.set_pairwise_iff (hr : Reflexive r) : s.Pairwise r ↔ ∀ ⦃a⦄, a ∈ s → ∀ ⦃b⦄, b ∈ s → r a b :=
  forall₄_congr fun a _ b _ => or_iff_not_imp_left.symm.trans <| or_iff_right_of_imp <| Eq.ndrec <| hr a
#align set._root_.reflexive.set_pairwise_iff set._root_.reflexive.set_pairwise_iff

/- warning: set.pairwise.on_injective -> Set.Pairwise.on_injective is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} {ι : Type.{u_4}} {r : α -> α -> Prop} {f : ι -> α} {s : Set.{u_1} α}, (Set.Pairwise.{u_1} α s r) -> (Function.Injective.{succ u_4 succ u_1} ι α f) -> (forall (x : ι), Membership.Mem.{u_1 u_1} α (Set.{u_1} α) (Set.hasMem.{u_1} α) (f x) s) -> (Pairwise.{u_4} ι (Function.onFun.{succ u_4 succ u_1 1} ι α Prop r f))
but is expected to have type
  forall {α : Type.{u_1}} {ι : Type.{u_2}} {r : α -> α -> Prop} {f : ι -> α} {s : Set.{u_1} α}, (Set.Pairwise.{u_1} α s r) -> (Function.Injective.{succ u_2 succ u_1} ι α f) -> (forall (x : ι), Membership.mem.{u_1 u_1} α (Set.{u_1} α) (Set.instMembershipSet.{u_1} α) (f x) s) -> (Pairwise.{u_2} ι (Function.onFun.{succ u_2 succ u_1 1} ι α Prop r f))
Case conversion may be inaccurate. Consider using '#align set.pairwise.on_injective Set.Pairwise.on_injectiveₓ'. -/
theorem Pairwise.on_injective (hs : s.Pairwise r) (hf : Function.Injective f) (hfs : ∀ x, f x ∈ s) :
    Pairwise (r on f) := fun i j hij => hs (hfs i) (hfs j) (hf.Ne hij)
#align set.pairwise.on_injective Set.Pairwise.on_injective

end Set

#print Pairwise.set_pairwise /-
theorem Pairwise.set_pairwise (h : Pairwise r) (s : Set α) : s.Pairwise r := fun x hx y hy w => h w
#align pairwise.set_pairwise Pairwise.set_pairwise
-/

end Pairwise

