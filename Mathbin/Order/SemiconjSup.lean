/-
Copyright (c) 2020 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module order.semiconj_Sup
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Function.Conjugate
import Mathbin.Order.Bounds.OrderIso
import Mathbin.Order.ConditionallyCompleteLattice.Basic
import Mathbin.Order.RelIso.Group
import Mathbin.Order.OrdContinuous
import Mathbin.Algebra.Hom.Equiv.Units.Basic

/-!
# Semiconjugate by `Sup`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove two facts about semiconjugate (families of) functions.

First, if an order isomorphism `fa : α → α` is semiconjugate to an order embedding `fb : β → β` by
`g : α → β`, then `fb` is semiconjugate to `fa` by `y ↦ Sup {x | g x ≤ y}`, see
`semiconj.symm_adjoint`.

Second, consider two actions `f₁ f₂ : G → α → α` of a group on a complete lattice by order
isomorphisms. Then the map `x ↦ ⨆ g : G, (f₁ g)⁻¹ (f₂ g x)` semiconjugates each `f₁ g'` to `f₂ g'`,
see `function.Sup_div_semiconj`.  In the case of a conditionally complete lattice, a similar
statement holds true under an additional assumption that each set `{(f₁ g)⁻¹ (f₂ g x) | g : G}` is
bounded above, see `function.cSup_div_semiconj`.

The lemmas come from [Étienne Ghys, Groupes d'homeomorphismes du cercle et cohomologie
bornee][ghys87:groupes], Proposition 2.1 and 5.4 respectively. In the paper they are formulated for
homeomorphisms of the circle, so in order to apply results from this file one has to lift these
homeomorphisms to the real line first.
-/


variable {α β γ : Type _}

open Set

#print IsOrderRightAdjoint /-
/-- We say that `g : β → α` is an order right adjoint function for `f : α → β` if it sends each `y`
to a least upper bound for `{x | f x ≤ y}`. If `α` is a partial order, and `f : α → β` has
a right adjoint, then this right adjoint is unique. -/
def IsOrderRightAdjoint [Preorder α] [Preorder β] (f : α → β) (g : β → α) :=
  ∀ y, IsLUB {x | f x ≤ y} (g y)
#align is_order_right_adjoint IsOrderRightAdjoint
-/

#print isOrderRightAdjoint_sSup /-
theorem isOrderRightAdjoint_sSup [CompleteLattice α] [Preorder β] (f : α → β) :
    IsOrderRightAdjoint f fun y => sSup {x | f x ≤ y} := fun y => isLUB_sSup _
#align is_order_right_adjoint_Sup isOrderRightAdjoint_sSup
-/

#print isOrderRightAdjoint_csSup /-
theorem isOrderRightAdjoint_csSup [ConditionallyCompleteLattice α] [Preorder β] (f : α → β)
    (hne : ∀ y, ∃ x, f x ≤ y) (hbdd : ∀ y, BddAbove {x | f x ≤ y}) :
    IsOrderRightAdjoint f fun y => sSup {x | f x ≤ y} := fun y => isLUB_csSup (hne y) (hbdd y)
#align is_order_right_adjoint_cSup isOrderRightAdjoint_csSup
-/

namespace IsOrderRightAdjoint

#print IsOrderRightAdjoint.unique /-
protected theorem unique [PartialOrder α] [Preorder β] {f : α → β} {g₁ g₂ : β → α}
    (h₁ : IsOrderRightAdjoint f g₁) (h₂ : IsOrderRightAdjoint f g₂) : g₁ = g₂ :=
  funext fun y => (h₁ y).unique (h₂ y)
#align is_order_right_adjoint.unique IsOrderRightAdjoint.unique
-/

#print IsOrderRightAdjoint.right_mono /-
theorem right_mono [Preorder α] [Preorder β] {f : α → β} {g : β → α} (h : IsOrderRightAdjoint f g) :
    Monotone g := fun y₁ y₂ hy => (h y₁).mono (h y₂) fun x hx => le_trans hx hy
#align is_order_right_adjoint.right_mono IsOrderRightAdjoint.right_mono
-/

#print IsOrderRightAdjoint.orderIso_comp /-
theorem orderIso_comp [Preorder α] [Preorder β] [Preorder γ] {f : α → β} {g : β → α}
    (h : IsOrderRightAdjoint f g) (e : β ≃o γ) : IsOrderRightAdjoint (e ∘ f) (g ∘ e.symm) :=
  fun y => by simpa [e.le_symm_apply] using h (e.symm y)
#align is_order_right_adjoint.order_iso_comp IsOrderRightAdjoint.orderIso_comp
-/

#print IsOrderRightAdjoint.comp_orderIso /-
theorem comp_orderIso [Preorder α] [Preorder β] [Preorder γ] {f : α → β} {g : β → α}
    (h : IsOrderRightAdjoint f g) (e : γ ≃o α) : IsOrderRightAdjoint (f ∘ e) (e.symm ∘ g) :=
  by
  intro y
  change IsLUB (e ⁻¹' {x | f x ≤ y}) (e.symm (g y))
  rw [e.is_lub_preimage, e.apply_symm_apply]
  exact h y
#align is_order_right_adjoint.comp_order_iso IsOrderRightAdjoint.comp_orderIso
-/

end IsOrderRightAdjoint

namespace Function

#print Function.Semiconj.symm_adjoint /-
/-- If an order automorphism `fa` is semiconjugate to an order embedding `fb` by a function `g`
and `g'` is an order right adjoint of `g` (i.e. `g' y = Sup {x | f x ≤ y}`), then `fb` is
semiconjugate to `fa` by `g'`.

This is a version of Proposition 2.1 from [Étienne Ghys, Groupes d'homeomorphismes du cercle et
cohomologie bornee][ghys87:groupes]. -/
theorem Semiconj.symm_adjoint [PartialOrder α] [Preorder β] {fa : α ≃o α} {fb : β ↪o β} {g : α → β}
    (h : Function.Semiconj g fa fb) {g' : β → α} (hg' : IsOrderRightAdjoint g g') :
    Function.Semiconj g' fb fa :=
  by
  refine' fun y => (hg' _).unique _
  rw [← fa.surjective.image_preimage {x | g x ≤ fb y}, preimage_set_of_eq]
  simp only [h.eq, fb.le_iff_le, fa.left_ord_continuous (hg' _)]
#align function.semiconj.symm_adjoint Function.Semiconj.symm_adjoint
-/

variable {G : Type _}

#print Function.semiconj_of_isLUB /-
theorem semiconj_of_isLUB [PartialOrder α] [Group G] (f₁ f₂ : G →* α ≃o α) {h : α → α}
    (H : ∀ x, IsLUB (range fun g' => (f₁ g')⁻¹ (f₂ g' x)) (h x)) (g : G) :
    Function.Semiconj h (f₂ g) (f₁ g) :=
  by
  refine' fun y => (H _).unique _
  have := (f₁ g).LeftOrdContinuous (H y)
  rw [← range_comp, ← (Equiv.mulRight g).Surjective.range_comp _] at this 
  simpa [(· ∘ ·)] using this
#align function.semiconj_of_is_lub Function.semiconj_of_isLUB
-/

#print Function.sSup_div_semiconj /-
/-- Consider two actions `f₁ f₂ : G → α → α` of a group on a complete lattice by order
isomorphisms. Then the map `x ↦ ⨆ g : G, (f₁ g)⁻¹ (f₂ g x)` semiconjugates each `f₁ g'` to `f₂ g'`.

This is a version of Proposition 5.4 from [Étienne Ghys, Groupes d'homeomorphismes du cercle et
cohomologie bornee][ghys87:groupes]. -/
theorem sSup_div_semiconj [CompleteLattice α] [Group G] (f₁ f₂ : G →* α ≃o α) (g : G) :
    Function.Semiconj (fun x => ⨆ g' : G, (f₁ g')⁻¹ (f₂ g' x)) (f₂ g) (f₁ g) :=
  semiconj_of_isLUB f₁ f₂ (fun x => isLUB_iSup) _
#align function.Sup_div_semiconj Function.sSup_div_semiconj
-/

#print Function.csSup_div_semiconj /-
/-- Consider two actions `f₁ f₂ : G → α → α` of a group on a conditionally complete lattice by order
isomorphisms. Suppose that each set $s(x)=\{f_1(g)^{-1} (f_2(g)(x)) | g \in G\}$ is bounded above.
Then the map `x ↦ Sup s(x)` semiconjugates each `f₁ g'` to `f₂ g'`.

This is a version of Proposition 5.4 from [Étienne Ghys, Groupes d'homeomorphismes du cercle et
cohomologie bornee][ghys87:groupes]. -/
theorem csSup_div_semiconj [ConditionallyCompleteLattice α] [Group G] (f₁ f₂ : G →* α ≃o α)
    (hbdd : ∀ x, BddAbove (range fun g => (f₁ g)⁻¹ (f₂ g x))) (g : G) :
    Function.Semiconj (fun x => ⨆ g' : G, (f₁ g')⁻¹ (f₂ g' x)) (f₂ g) (f₁ g) :=
  semiconj_of_isLUB f₁ f₂ (fun x => isLUB_csSup (range_nonempty _) (hbdd x)) _
#align function.cSup_div_semiconj Function.csSup_div_semiconj
-/

end Function

-- Guard against import creep
assert_not_exists Finset

