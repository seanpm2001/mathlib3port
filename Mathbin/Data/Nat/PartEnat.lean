/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes

! This file was ported from Lean 3 source module data.nat.part_enat
! leanprover-community/mathlib commit 3ff3f2d6a3118b8711063de7111a0d77a53219a8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.Equiv.Basic
import Mathbin.Data.Part
import Mathbin.Data.Enat.Lattice
import Mathbin.Tactic.NormNum

/-!
# Natural numbers with infinity

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The natural numbers and an extra `top` element `⊤`. This implementation uses `part ℕ` as an
implementation. Use `ℕ∞` instead unless you care about computability.

## Main definitions

The following instances are defined:

* `ordered_add_comm_monoid part_enat`
* `canonically_ordered_add_monoid part_enat`
* `complete_linear_order part_enat`

There is no additive analogue of `monoid_with_zero`; if there were then `part_enat` could
be an `add_monoid_with_top`.

* `to_with_top` : the map from `part_enat` to `ℕ∞`, with theorems that it plays well
with `+` and `≤`.

* `with_top_add_equiv : part_enat ≃+ ℕ∞`
* `with_top_order_iso : part_enat ≃o ℕ∞`

## Implementation details

`part_enat` is defined to be `part ℕ`.

`+` and `≤` are defined on `part_enat`, but there is an issue with `*` because it's not
clear what `0 * ⊤` should be. `mul` is hence left undefined. Similarly `⊤ - ⊤` is ambiguous
so there is no `-` defined on `part_enat`.

Before the `open_locale classical` line, various proofs are made with decidability assumptions.
This can cause issues -- see for example the non-simp lemma `to_with_top_zero` proved by `rfl`,
followed by `@[simp] lemma to_with_top_zero'` whose proof uses `convert`.


## Tags

part_enat, ℕ∞
-/


open Part hiding some

#print PartENat /-
/-- Type of natural numbers with infinity (`⊤`) -/
def PartENat : Type :=
  Part ℕ
#align part_enat PartENat
-/

namespace PartENat

#print PartENat.some /-
/-- The computable embedding `ℕ → part_enat`.

This coincides with the coercion `coe : ℕ → part_enat`, see `part_enat.some_eq_coe`.
However, `coe` is noncomputable so `some` is preferable when computability is a concern. -/
def some : ℕ → PartENat :=
  Part.some
#align part_enat.some PartENat.some
-/

instance : Zero PartENat :=
  ⟨some 0⟩

instance : Inhabited PartENat :=
  ⟨0⟩

instance : One PartENat :=
  ⟨some 1⟩

instance : Add PartENat :=
  ⟨fun x y => ⟨x.Dom ∧ y.Dom, fun h => get x h.1 + get y h.2⟩⟩

instance (n : ℕ) : Decidable (some n).Dom :=
  isTrue trivial

#print PartENat.dom_some /-
@[simp]
theorem dom_some (x : ℕ) : (some x).Dom :=
  trivial
#align part_enat.dom_some PartENat.dom_some
-/

instance : AddCommMonoid PartENat where
  add := (· + ·)
  zero := 0
  add_comm x y := Part.ext' and_comm fun _ _ => add_comm _ _
  zero_add x := Part.ext' (true_and_iff _) fun _ _ => zero_add _
  add_zero x := Part.ext' (and_true_iff _) fun _ _ => add_zero _
  add_assoc x y z := Part.ext' and_assoc fun _ _ => add_assoc _ _ _

instance : AddCommMonoidWithOne PartENat :=
  { PartENat.addCommMonoid with
    one := 1
    natCast := some
    natCast_zero := rfl
    natCast_succ := fun _ => Part.ext' (true_and_iff _).symm fun _ _ => rfl }

#print PartENat.some_eq_natCast /-
theorem some_eq_natCast (n : ℕ) : some n = n :=
  rfl
#align part_enat.some_eq_coe PartENat.some_eq_natCast
-/

#print PartENat.natCast_inj /-
@[simp, norm_cast]
theorem natCast_inj {x y : ℕ} : (x : PartENat) = y ↔ x = y :=
  Part.some_inj
#align part_enat.coe_inj PartENat.natCast_inj
-/

#print PartENat.dom_natCast /-
@[simp]
theorem dom_natCast (x : ℕ) : (x : PartENat).Dom :=
  trivial
#align part_enat.dom_coe PartENat.dom_natCast
-/

instance : CanLift PartENat ℕ coe Dom :=
  ⟨fun n hn => ⟨n.get hn, Part.some_get _⟩⟩

instance : LE PartENat :=
  ⟨fun x y => ∃ h : y.Dom → x.Dom, ∀ hy : y.Dom, x.get (h hy) ≤ y.get hy⟩

instance : Top PartENat :=
  ⟨none⟩

instance : Bot PartENat :=
  ⟨0⟩

instance : Sup PartENat :=
  ⟨fun x y => ⟨x.Dom ∧ y.Dom, fun h => x.get h.1 ⊔ y.get h.2⟩⟩

#print PartENat.le_def /-
theorem le_def (x y : PartENat) :
    x ≤ y ↔ ∃ h : y.Dom → x.Dom, ∀ hy : y.Dom, x.get (h hy) ≤ y.get hy :=
  Iff.rfl
#align part_enat.le_def PartENat.le_def
-/

#print PartENat.casesOn' /-
@[elab_as_elim]
protected theorem casesOn' {P : PartENat → Prop} :
    ∀ a : PartENat, P ⊤ → (∀ n : ℕ, P (some n)) → P a :=
  Part.induction_on
#align part_enat.cases_on' PartENat.casesOn'
-/

#print PartENat.casesOn /-
@[elab_as_elim]
protected theorem casesOn {P : PartENat → Prop} : ∀ a : PartENat, P ⊤ → (∀ n : ℕ, P n) → P a := by
  simp only [← some_eq_coe]; exact PartENat.casesOn'
#align part_enat.cases_on PartENat.casesOn
-/

#print PartENat.top_add /-
@[simp]
theorem top_add (x : PartENat) : ⊤ + x = ⊤ :=
  Part.ext' (false_and_iff _) fun h => h.left.elim
#align part_enat.top_add PartENat.top_add
-/

#print PartENat.add_top /-
@[simp]
theorem add_top (x : PartENat) : x + ⊤ = ⊤ := by rw [add_comm, top_add]
#align part_enat.add_top PartENat.add_top
-/

#print PartENat.natCast_get /-
@[simp]
theorem natCast_get {x : PartENat} (h : x.Dom) : (x.get h : PartENat) = x := by rw [← some_eq_coe];
  exact Part.ext' (iff_of_true trivial h) fun _ _ => rfl
#align part_enat.coe_get PartENat.natCast_get
-/

#print PartENat.get_natCast' /-
@[simp, norm_cast]
theorem get_natCast' (x : ℕ) (h : (x : PartENat).Dom) : get (x : PartENat) h = x := by
  rw [← coe_inj, coe_get]
#align part_enat.get_coe' PartENat.get_natCast'
-/

#print PartENat.get_natCast /-
theorem get_natCast {x : ℕ} : get (x : PartENat) (dom_natCast x) = x :=
  get_natCast' _ _
#align part_enat.get_coe PartENat.get_natCast
-/

#print PartENat.coe_add_get /-
theorem coe_add_get {x : ℕ} {y : PartENat} (h : ((x : PartENat) + y).Dom) :
    get ((x : PartENat) + y) h = x + get y h.2 := by simp only [← some_eq_coe] at h ⊢; rfl
#align part_enat.coe_add_get PartENat.coe_add_get
-/

#print PartENat.get_add /-
@[simp]
theorem get_add {x y : PartENat} (h : (x + y).Dom) : get (x + y) h = x.get h.1 + y.get h.2 :=
  rfl
#align part_enat.get_add PartENat.get_add
-/

#print PartENat.get_zero /-
@[simp]
theorem get_zero (h : (0 : PartENat).Dom) : (0 : PartENat).get h = 0 :=
  rfl
#align part_enat.get_zero PartENat.get_zero
-/

#print PartENat.get_one /-
@[simp]
theorem get_one (h : (1 : PartENat).Dom) : (1 : PartENat).get h = 1 :=
  rfl
#align part_enat.get_one PartENat.get_one
-/

#print PartENat.get_eq_iff_eq_some /-
theorem get_eq_iff_eq_some {a : PartENat} {ha : a.Dom} {b : ℕ} : a.get ha = b ↔ a = some b :=
  get_eq_iff_eq_some
#align part_enat.get_eq_iff_eq_some PartENat.get_eq_iff_eq_some
-/

#print PartENat.get_eq_iff_eq_coe /-
theorem get_eq_iff_eq_coe {a : PartENat} {ha : a.Dom} {b : ℕ} : a.get ha = b ↔ a = b := by
  rw [get_eq_iff_eq_some, some_eq_coe]
#align part_enat.get_eq_iff_eq_coe PartENat.get_eq_iff_eq_coe
-/

#print PartENat.dom_of_le_of_dom /-
theorem dom_of_le_of_dom {x y : PartENat} : x ≤ y → y.Dom → x.Dom := fun ⟨h, _⟩ => h
#align part_enat.dom_of_le_of_dom PartENat.dom_of_le_of_dom
-/

#print PartENat.dom_of_le_some /-
theorem dom_of_le_some {x : PartENat} {y : ℕ} (h : x ≤ some y) : x.Dom :=
  dom_of_le_of_dom h trivial
#align part_enat.dom_of_le_some PartENat.dom_of_le_some
-/

#print PartENat.dom_of_le_natCast /-
theorem dom_of_le_natCast {x : PartENat} {y : ℕ} (h : x ≤ y) : x.Dom := by rw [← some_eq_coe] at h ;
  exact dom_of_le_some h
#align part_enat.dom_of_le_coe PartENat.dom_of_le_natCast
-/

#print PartENat.decidableLe /-
instance decidableLe (x y : PartENat) [Decidable x.Dom] [Decidable y.Dom] : Decidable (x ≤ y) :=
  if hx : x.Dom then
    decidable_of_decidable_of_iff
        (show Decidable (∀ hy : (y : PartENat).Dom, x.get hx ≤ (y : PartENat).get hy) from
          forallPropDecidable _) <|
      by dsimp [(· ≤ ·)]; simp only [hx, exists_prop_of_true, forall_true_iff]
  else
    if hy : y.Dom then isFalse fun h => hx <| dom_of_le_of_dom h hy
    else isTrue ⟨fun h => (hy h).elim, fun h => (hy h).elim⟩
#align part_enat.decidable_le PartENat.decidableLe
-/

#print PartENat.natCast_AddMonoidHom /-
/-- The coercion `ℕ → part_enat` preserves `0` and addition. -/
def natCast_AddMonoidHom : ℕ →+ PartENat :=
  ⟨coe, Nat.cast_zero, Nat.cast_add⟩
#align part_enat.coe_hom PartENat.natCast_AddMonoidHom
-/

#print PartENat.coe_coeHom /-
@[simp]
theorem coe_coeHom : ⇑natCast_AddMonoidHom = coe :=
  rfl
#align part_enat.coe_coe_hom PartENat.coe_coeHom
-/

instance : PartialOrder PartENat where
  le := (· ≤ ·)
  le_refl x := ⟨id, fun _ => le_rfl⟩
  le_trans := fun x y z ⟨hxy₁, hxy₂⟩ ⟨hyz₁, hyz₂⟩ =>
    ⟨hxy₁ ∘ hyz₁, fun _ => le_trans (hxy₂ _) (hyz₂ _)⟩
  le_antisymm := fun x y ⟨hxy₁, hxy₂⟩ ⟨hyx₁, hyx₂⟩ =>
    Part.ext' ⟨hyx₁, hxy₁⟩ fun _ _ => le_antisymm (hxy₂ _) (hyx₂ _)

#print PartENat.lt_def /-
theorem lt_def (x y : PartENat) : x < y ↔ ∃ hx : x.Dom, ∀ hy : y.Dom, x.get hx < y.get hy :=
  by
  rw [lt_iff_le_not_le, le_def, le_def, not_exists]
  constructor
  · rintro ⟨⟨hyx, H⟩, h⟩
    by_cases hx : x.dom
    · use hx; intro hy
      specialize H hy; specialize h fun _ => hy
      rw [not_forall] at h ; cases' h with hx' h
      rw [not_le] at h ; exact h
    · specialize h fun hx' => (hx hx').elim
      rw [not_forall] at h ; cases' h with hx' h
      exact (hx hx').elim
  · rintro ⟨hx, H⟩;
    exact ⟨⟨fun _ => hx, fun hy => (H hy).le⟩, fun hxy h => not_lt_of_le (h _) (H _)⟩
#align part_enat.lt_def PartENat.lt_def
-/

#print PartENat.coe_le_coe /-
@[simp, norm_cast]
theorem coe_le_coe {x y : ℕ} : (x : PartENat) ≤ y ↔ x ≤ y := by rw [← some_eq_coe, ← some_eq_coe];
  exact ⟨fun ⟨_, h⟩ => h trivial, fun h => ⟨fun _ => trivial, fun _ => h⟩⟩
#align part_enat.coe_le_coe PartENat.coe_le_coe
-/

#print PartENat.coe_lt_coe /-
@[simp, norm_cast]
theorem coe_lt_coe {x y : ℕ} : (x : PartENat) < y ↔ x < y := by
  rw [lt_iff_le_not_le, lt_iff_le_not_le, coe_le_coe, coe_le_coe]
#align part_enat.coe_lt_coe PartENat.coe_lt_coe
-/

#print PartENat.get_le_get /-
@[simp]
theorem get_le_get {x y : PartENat} {hx : x.Dom} {hy : y.Dom} : x.get hx ≤ y.get hy ↔ x ≤ y := by
  conv =>
    lhs
    rw [← coe_le_coe, coe_get, coe_get]
#align part_enat.get_le_get PartENat.get_le_get
-/

#print PartENat.le_coe_iff /-
theorem le_coe_iff (x : PartENat) (n : ℕ) : x ≤ n ↔ ∃ h : x.Dom, x.get h ≤ n :=
  by
  rw [← some_eq_coe]
  show (∃ h : True → x.dom, _) ↔ ∃ h : x.dom, x.get h ≤ n
  simp only [forall_prop_of_true, some_eq_coe, dom_coe, get_coe']
#align part_enat.le_coe_iff PartENat.le_coe_iff
-/

#print PartENat.lt_coe_iff /-
theorem lt_coe_iff (x : PartENat) (n : ℕ) : x < n ↔ ∃ h : x.Dom, x.get h < n := by
  simp only [lt_def, forall_prop_of_true, get_coe', dom_coe]
#align part_enat.lt_coe_iff PartENat.lt_coe_iff
-/

#print PartENat.coe_le_iff /-
theorem coe_le_iff (n : ℕ) (x : PartENat) : (n : PartENat) ≤ x ↔ ∀ h : x.Dom, n ≤ x.get h :=
  by
  rw [← some_eq_coe]
  simp only [le_def, exists_prop_of_true, dom_some, forall_true_iff]
  rfl
#align part_enat.coe_le_iff PartENat.coe_le_iff
-/

#print PartENat.coe_lt_iff /-
theorem coe_lt_iff (n : ℕ) (x : PartENat) : (n : PartENat) < x ↔ ∀ h : x.Dom, n < x.get h :=
  by
  rw [← some_eq_coe]
  simp only [lt_def, exists_prop_of_true, dom_some, forall_true_iff]
  rfl
#align part_enat.coe_lt_iff PartENat.coe_lt_iff
-/

#print PartENat.NeZero.one /-
instance NeZero.one : NeZero (1 : PartENat) :=
  ⟨natCast_inj.Not.mpr (by decide)⟩
#align part_enat.ne_zero.one PartENat.NeZero.one
-/

#print PartENat.semilatticeSup /-
instance semilatticeSup : SemilatticeSup PartENat :=
  { PartENat.partialOrder with
    sup := (· ⊔ ·)
    le_sup_left := fun _ _ => ⟨And.left, fun _ => le_sup_left⟩
    le_sup_right := fun _ _ => ⟨And.right, fun _ => le_sup_right⟩
    sup_le := fun x y z ⟨hx₁, hx₂⟩ ⟨hy₁, hy₂⟩ =>
      ⟨fun hz => ⟨hx₁ hz, hy₁ hz⟩, fun _ => sup_le (hx₂ _) (hy₂ _)⟩ }
#align part_enat.semilattice_sup PartENat.semilatticeSup
-/

#print PartENat.orderBot /-
instance orderBot : OrderBot PartENat where
  bot := ⊥
  bot_le _ := ⟨fun _ => trivial, fun _ => Nat.zero_le _⟩
#align part_enat.order_bot PartENat.orderBot
-/

#print PartENat.orderTop /-
instance orderTop : OrderTop PartENat where
  top := ⊤
  le_top x := ⟨fun h => False.elim h, fun hy => False.elim hy⟩
#align part_enat.order_top PartENat.orderTop
-/

#print PartENat.eq_zero_iff /-
theorem eq_zero_iff {x : PartENat} : x = 0 ↔ x ≤ 0 :=
  eq_bot_iff
#align part_enat.eq_zero_iff PartENat.eq_zero_iff
-/

#print PartENat.ne_zero_iff /-
theorem ne_zero_iff {x : PartENat} : x ≠ 0 ↔ ⊥ < x :=
  bot_lt_iff_ne_bot.symm
#align part_enat.ne_zero_iff PartENat.ne_zero_iff
-/

#print PartENat.dom_of_lt /-
theorem dom_of_lt {x y : PartENat} : x < y → x.Dom :=
  PartENat.casesOn x not_top_lt fun _ _ => dom_natCast _
#align part_enat.dom_of_lt PartENat.dom_of_lt
-/

#print PartENat.top_eq_none /-
theorem top_eq_none : (⊤ : PartENat) = none :=
  rfl
#align part_enat.top_eq_none PartENat.top_eq_none
-/

#print PartENat.natCast_lt_top /-
@[simp]
theorem natCast_lt_top (x : ℕ) : (x : PartENat) < ⊤ :=
  Ne.lt_top fun h => absurd (congr_arg Dom h) <| by simpa only [dom_coe] using true_ne_false
#align part_enat.coe_lt_top PartENat.natCast_lt_top
-/

#print PartENat.natCast_ne_top /-
@[simp]
theorem natCast_ne_top (x : ℕ) : (x : PartENat) ≠ ⊤ :=
  ne_of_lt (natCast_lt_top x)
#align part_enat.coe_ne_top PartENat.natCast_ne_top
-/

#print PartENat.not_isMax_natCast /-
theorem not_isMax_natCast (x : ℕ) : ¬IsMax (x : PartENat) :=
  not_isMax_of_lt (natCast_lt_top x)
#align part_enat.not_is_max_coe PartENat.not_isMax_natCast
-/

#print PartENat.ne_top_iff /-
theorem ne_top_iff {x : PartENat} : x ≠ ⊤ ↔ ∃ n : ℕ, x = n := by
  simpa only [← some_eq_coe] using Part.ne_none_iff
#align part_enat.ne_top_iff PartENat.ne_top_iff
-/

#print PartENat.ne_top_iff_dom /-
theorem ne_top_iff_dom {x : PartENat} : x ≠ ⊤ ↔ x.Dom := by
  classical exact not_iff_comm.1 part.eq_none_iff'.symm
#align part_enat.ne_top_iff_dom PartENat.ne_top_iff_dom
-/

#print PartENat.not_dom_iff_eq_top /-
theorem not_dom_iff_eq_top {x : PartENat} : ¬x.Dom ↔ x = ⊤ :=
  Iff.not_left ne_top_iff_dom.symm
#align part_enat.not_dom_iff_eq_top PartENat.not_dom_iff_eq_top
-/

#print PartENat.ne_top_of_lt /-
theorem ne_top_of_lt {x y : PartENat} (h : x < y) : x ≠ ⊤ :=
  ne_of_lt <| lt_of_lt_of_le h le_top
#align part_enat.ne_top_of_lt PartENat.ne_top_of_lt
-/

#print PartENat.eq_top_iff_forall_lt /-
theorem eq_top_iff_forall_lt (x : PartENat) : x = ⊤ ↔ ∀ n : ℕ, (n : PartENat) < x :=
  by
  constructor
  · rintro rfl n; exact coe_lt_top _
  · contrapose!; rw [ne_top_iff]; rintro ⟨n, rfl⟩; exact ⟨n, irrefl _⟩
#align part_enat.eq_top_iff_forall_lt PartENat.eq_top_iff_forall_lt
-/

#print PartENat.eq_top_iff_forall_le /-
theorem eq_top_iff_forall_le (x : PartENat) : x = ⊤ ↔ ∀ n : ℕ, (n : PartENat) ≤ x :=
  (eq_top_iff_forall_lt x).trans
    ⟨fun h n => (h n).le, fun h n => lt_of_lt_of_le (coe_lt_coe.mpr n.lt_succ_self) (h (n + 1))⟩
#align part_enat.eq_top_iff_forall_le PartENat.eq_top_iff_forall_le
-/

#print PartENat.pos_iff_one_le /-
theorem pos_iff_one_le {x : PartENat} : 0 < x ↔ 1 ≤ x :=
  PartENat.casesOn x (by simp only [iff_true_iff, le_top, coe_lt_top, ← @Nat.cast_zero PartENat])
    fun n => by rw [← Nat.cast_zero, ← Nat.cast_one, PartENat.coe_lt_coe, PartENat.coe_le_coe]; rfl
#align part_enat.pos_iff_one_le PartENat.pos_iff_one_le
-/

instance : IsTotal PartENat (· ≤ ·)
    where Total x y :=
    PartENat.casesOn x (Or.inr le_top)
      (PartENat.casesOn y (fun _ => Or.inl le_top) fun x y =>
        (le_total x y).elim (Or.inr ∘ coe_le_coe.2) (Or.inl ∘ coe_le_coe.2))

noncomputable instance : LinearOrder PartENat :=
  { PartENat.partialOrder with
    le_total := IsTotal.total
    decidableLe := Classical.decRel _
    max := (· ⊔ ·)
    max_def := @sup_eq_maxDefault _ _ (id _) _ }

instance : BoundedOrder PartENat :=
  { PartENat.orderTop, PartENat.orderBot with }

noncomputable instance : Lattice PartENat :=
  { PartENat.semilatticeSup with
    inf := min
    inf_le_left := min_le_left
    inf_le_right := min_le_right
    le_inf := fun _ _ _ => le_min }

instance : OrderedAddCommMonoid PartENat :=
  { PartENat.linearOrder, PartENat.addCommMonoid with
    add_le_add_left := fun a b ⟨h₁, h₂⟩ c =>
      PartENat.casesOn c (by simp) fun c =>
        ⟨fun h => And.intro (dom_natCast _) (h₁ h.2), fun h => by
          simpa only [coe_add_get] using add_le_add_left (h₂ _) c⟩ }

instance : CanonicallyOrderedAddMonoid PartENat :=
  { PartENat.semilatticeSup, PartENat.orderBot,
    PartENat.orderedAddCommMonoid with
    le_self_add := fun a b =>
      PartENat.casesOn b (le_top.trans_eq (add_top _).symm) fun b =>
        PartENat.casesOn a (top_add _).ge fun a =>
          (coe_le_coe.2 le_self_add).trans_eq (Nat.cast_add _ _)
    exists_add_of_le := fun a b =>
      PartENat.casesOn b (fun _ => ⟨⊤, (add_top _).symm⟩) fun b =>
        PartENat.casesOn a (fun h => ((natCast_lt_top _).not_le h).elim) fun a h =>
          ⟨(b - a : ℕ), by
            rw [← Nat.cast_add, coe_inj, add_comm, tsub_add_cancel_of_le (coe_le_coe.1 h)]⟩ }

#print PartENat.eq_natCast_sub_of_add_eq_natCast /-
theorem eq_natCast_sub_of_add_eq_natCast {x y : PartENat} {n : ℕ} (h : x + y = n) :
    x = ↑(n - y.get (dom_of_le_natCast ((le_add_left le_rfl).trans_eq h))) :=
  by
  lift x to ℕ using dom_of_le_coe ((le_add_right le_rfl).trans_eq h)
  lift y to ℕ using dom_of_le_coe ((le_add_left le_rfl).trans_eq h)
  rw [← Nat.cast_add, coe_inj] at h 
  rw [get_coe, coe_inj, eq_tsub_of_add_eq h]
#align part_enat.eq_coe_sub_of_add_eq_coe PartENat.eq_natCast_sub_of_add_eq_natCast
-/

#print PartENat.add_lt_add_right /-
protected theorem add_lt_add_right {x y z : PartENat} (h : x < y) (hz : z ≠ ⊤) : x + z < y + z :=
  by
  rcases ne_top_iff.mp (ne_top_of_lt h) with ⟨m, rfl⟩
  rcases ne_top_iff.mp hz with ⟨k, rfl⟩
  induction' y using PartENat.casesOn with n
  · rw [top_add]; apply_mod_cast coe_lt_top
  norm_cast at h ; apply_mod_cast add_lt_add_right h
#align part_enat.add_lt_add_right PartENat.add_lt_add_right
-/

#print PartENat.add_lt_add_iff_right /-
protected theorem add_lt_add_iff_right {x y z : PartENat} (hz : z ≠ ⊤) : x + z < y + z ↔ x < y :=
  ⟨lt_of_add_lt_add_right, fun h => PartENat.add_lt_add_right h hz⟩
#align part_enat.add_lt_add_iff_right PartENat.add_lt_add_iff_right
-/

#print PartENat.add_lt_add_iff_left /-
protected theorem add_lt_add_iff_left {x y z : PartENat} (hz : z ≠ ⊤) : z + x < z + y ↔ x < y := by
  rw [add_comm z, add_comm z, PartENat.add_lt_add_iff_right hz]
#align part_enat.add_lt_add_iff_left PartENat.add_lt_add_iff_left
-/

#print PartENat.lt_add_iff_pos_right /-
protected theorem lt_add_iff_pos_right {x y : PartENat} (hx : x ≠ ⊤) : x < x + y ↔ 0 < y := by
  conv_rhs => rw [← PartENat.add_lt_add_iff_left hx]; rw [add_zero]
#align part_enat.lt_add_iff_pos_right PartENat.lt_add_iff_pos_right
-/

#print PartENat.lt_add_one /-
theorem lt_add_one {x : PartENat} (hx : x ≠ ⊤) : x < x + 1 := by
  rw [PartENat.lt_add_iff_pos_right hx]; norm_cast; norm_num
#align part_enat.lt_add_one PartENat.lt_add_one
-/

#print PartENat.le_of_lt_add_one /-
theorem le_of_lt_add_one {x y : PartENat} (h : x < y + 1) : x ≤ y :=
  by
  induction' y using PartENat.casesOn with n; apply le_top
  rcases ne_top_iff.mp (ne_top_of_lt h) with ⟨m, rfl⟩
  apply_mod_cast Nat.le_of_lt_succ; apply_mod_cast h
#align part_enat.le_of_lt_add_one PartENat.le_of_lt_add_one
-/

#print PartENat.add_one_le_of_lt /-
theorem add_one_le_of_lt {x y : PartENat} (h : x < y) : x + 1 ≤ y :=
  by
  induction' y using PartENat.casesOn with n; apply le_top
  rcases ne_top_iff.mp (ne_top_of_lt h) with ⟨m, rfl⟩
  apply_mod_cast Nat.succ_le_of_lt; apply_mod_cast h
#align part_enat.add_one_le_of_lt PartENat.add_one_le_of_lt
-/

#print PartENat.add_one_le_iff_lt /-
theorem add_one_le_iff_lt {x y : PartENat} (hx : x ≠ ⊤) : x + 1 ≤ y ↔ x < y :=
  by
  constructor; swap; exact add_one_le_of_lt
  intro h; rcases ne_top_iff.mp hx with ⟨m, rfl⟩
  induction' y using PartENat.casesOn with n; apply coe_lt_top
  apply_mod_cast Nat.lt_of_succ_le; apply_mod_cast h
#align part_enat.add_one_le_iff_lt PartENat.add_one_le_iff_lt
-/

/- warning: part_enat.coe_succ_le_iff clashes with part_enat.coe_succ_le_succ_iff -> PartENat.coe_succ_le_iff
Case conversion may be inaccurate. Consider using '#align part_enat.coe_succ_le_iff PartENat.coe_succ_le_iffₓ'. -/
#print PartENat.coe_succ_le_iff /-
theorem coe_succ_le_iff {n : ℕ} {e : PartENat} : ↑n.succ ≤ e ↔ ↑n < e := by
  rw [Nat.succ_eq_add_one n, Nat.cast_add, Nat.cast_one, add_one_le_iff_lt (coe_ne_top n)]
#align part_enat.coe_succ_le_iff PartENat.coe_succ_le_iff
-/

#print PartENat.lt_add_one_iff_lt /-
theorem lt_add_one_iff_lt {x y : PartENat} (hx : x ≠ ⊤) : x < y + 1 ↔ x ≤ y :=
  by
  constructor; exact le_of_lt_add_one
  intro h; rcases ne_top_iff.mp hx with ⟨m, rfl⟩
  induction' y using PartENat.casesOn with n; · rw [top_add]; apply coe_lt_top
  apply_mod_cast Nat.lt_succ_of_le; apply_mod_cast h
#align part_enat.lt_add_one_iff_lt PartENat.lt_add_one_iff_lt
-/

#print PartENat.lt_coe_succ_iff_le /-
theorem lt_coe_succ_iff_le {x : PartENat} {n : ℕ} (hx : x ≠ ⊤) : x < n.succ ↔ x ≤ n := by
  rw [Nat.succ_eq_add_one n, Nat.cast_add, Nat.cast_one, lt_add_one_iff_lt hx]
#align part_enat.lt_coe_succ_iff_le PartENat.lt_coe_succ_iff_le
-/

#print PartENat.add_eq_top_iff /-
theorem add_eq_top_iff {a b : PartENat} : a + b = ⊤ ↔ a = ⊤ ∨ b = ⊤ := by
  apply PartENat.casesOn a <;> apply PartENat.casesOn b <;> simp <;>
      simp only [(Nat.cast_add _ _).symm, PartENat.natCast_ne_top] <;>
    simp
#align part_enat.add_eq_top_iff PartENat.add_eq_top_iff
-/

#print PartENat.add_right_cancel_iff /-
protected theorem add_right_cancel_iff {a b c : PartENat} (hc : c ≠ ⊤) : a + c = b + c ↔ a = b :=
  by
  rcases ne_top_iff.1 hc with ⟨c, rfl⟩
  apply PartENat.casesOn a <;> apply PartENat.casesOn b <;>
        simp [add_eq_top_iff, coe_ne_top, @eq_comm _ (⊤ : PartENat)] <;>
      simp only [(Nat.cast_add _ _).symm, add_left_cancel_iff, PartENat.natCast_inj, add_comm] <;>
    tauto
#align part_enat.add_right_cancel_iff PartENat.add_right_cancel_iff
-/

#print PartENat.add_left_cancel_iff /-
protected theorem add_left_cancel_iff {a b c : PartENat} (ha : a ≠ ⊤) : a + b = a + c ↔ b = c := by
  rw [add_comm a, add_comm a, PartENat.add_right_cancel_iff ha]
#align part_enat.add_left_cancel_iff PartENat.add_left_cancel_iff
-/

section WithTop

#print PartENat.toWithTop /-
/-- Computably converts an `part_enat` to a `ℕ∞`. -/
def toWithTop (x : PartENat) [Decidable x.Dom] : ℕ∞ :=
  x.toOption
#align part_enat.to_with_top PartENat.toWithTop
-/

#print PartENat.toWithTop_top /-
theorem toWithTop_top : toWithTop ⊤ = ⊤ :=
  rfl
#align part_enat.to_with_top_top PartENat.toWithTop_top
-/

#print PartENat.toWithTop_top' /-
@[simp]
theorem toWithTop_top' {h : Decidable (⊤ : PartENat).Dom} : toWithTop ⊤ = ⊤ := by
  convert to_with_top_top
#align part_enat.to_with_top_top' PartENat.toWithTop_top'
-/

#print PartENat.toWithTop_zero /-
theorem toWithTop_zero : toWithTop 0 = 0 :=
  rfl
#align part_enat.to_with_top_zero PartENat.toWithTop_zero
-/

#print PartENat.toWithTop_zero' /-
@[simp]
theorem toWithTop_zero' {h : Decidable (0 : PartENat).Dom} : toWithTop 0 = 0 := by
  convert to_with_top_zero
#align part_enat.to_with_top_zero' PartENat.toWithTop_zero'
-/

#print PartENat.toWithTop_some /-
theorem toWithTop_some (n : ℕ) : toWithTop (some n) = n :=
  rfl
#align part_enat.to_with_top_some PartENat.toWithTop_some
-/

#print PartENat.toWithTop_natCast /-
theorem toWithTop_natCast (n : ℕ) {_ : Decidable (n : PartENat).Dom} : toWithTop n = n := by
  simp only [← some_eq_coe, ← to_with_top_some]
#align part_enat.to_with_top_coe PartENat.toWithTop_natCast
-/

#print PartENat.toWithTop_natCast' /-
@[simp]
theorem toWithTop_natCast' (n : ℕ) {h : Decidable (n : PartENat).Dom} :
    toWithTop (n : PartENat) = n := by convert to_with_top_coe n
#align part_enat.to_with_top_coe' PartENat.toWithTop_natCast'
-/

#print PartENat.toWithTop_le /-
@[simp]
theorem toWithTop_le {x y : PartENat} :
    ∀ [Decidable x.Dom] [Decidable y.Dom], to_with_top x ≤ to_with_top y ↔ x ≤ y :=
  PartENat.casesOn y (by simp) (PartENat.casesOn x (by simp) (by intros <;> simp))
#align part_enat.to_with_top_le PartENat.toWithTop_le
-/

#print PartENat.toWithTop_lt /-
@[simp]
theorem toWithTop_lt {x y : PartENat} [Decidable x.Dom] [Decidable y.Dom] :
    toWithTop x < toWithTop y ↔ x < y :=
  lt_iff_lt_of_le_iff_le toWithTop_le
#align part_enat.to_with_top_lt PartENat.toWithTop_lt
-/

end WithTop

section WithTopEquiv

open scoped Classical

#print PartENat.toWithTop_add /-
@[simp]
theorem toWithTop_add {x y : PartENat} : toWithTop (x + y) = toWithTop x + toWithTop y := by
  apply PartENat.casesOn y <;> apply PartENat.casesOn x <;> simp [← Nat.cast_add, ← ENat.coe_add]
#align part_enat.to_with_top_add PartENat.toWithTop_add
-/

#print PartENat.withTopEquiv /-
/-- `equiv` between `part_enat` and `ℕ∞` (for the order isomorphism see
`with_top_order_iso`). -/
noncomputable def withTopEquiv : PartENat ≃ ℕ∞
    where
  toFun x := toWithTop x
  invFun x :=
    match x with
    | Option.some n => coe n
    | none => ⊤
  left_inv x := by apply PartENat.casesOn x <;> intros <;> simp <;> rfl
  right_inv x := by cases x <;> simp [with_top_equiv._match_1] <;> rfl
#align part_enat.with_top_equiv PartENat.withTopEquiv
-/

#print PartENat.withTopEquiv_top /-
@[simp]
theorem withTopEquiv_top : withTopEquiv ⊤ = ⊤ :=
  toWithTop_top'
#align part_enat.with_top_equiv_top PartENat.withTopEquiv_top
-/

#print PartENat.withTopEquiv_natCast /-
@[simp]
theorem withTopEquiv_natCast (n : Nat) : withTopEquiv n = n :=
  toWithTop_natCast' _
#align part_enat.with_top_equiv_coe PartENat.withTopEquiv_natCast
-/

#print PartENat.withTopEquiv_zero /-
@[simp]
theorem withTopEquiv_zero : withTopEquiv 0 = 0 := by
  simpa only [Nat.cast_zero] using with_top_equiv_coe 0
#align part_enat.with_top_equiv_zero PartENat.withTopEquiv_zero
-/

#print PartENat.withTopEquiv_le /-
@[simp]
theorem withTopEquiv_le {x y : PartENat} : withTopEquiv x ≤ withTopEquiv y ↔ x ≤ y :=
  toWithTop_le
#align part_enat.with_top_equiv_le PartENat.withTopEquiv_le
-/

#print PartENat.withTopEquiv_lt /-
@[simp]
theorem withTopEquiv_lt {x y : PartENat} : withTopEquiv x < withTopEquiv y ↔ x < y :=
  toWithTop_lt
#align part_enat.with_top_equiv_lt PartENat.withTopEquiv_lt
-/

#print PartENat.withTopOrderIso /-
/-- `to_with_top` induces an order isomorphism between `part_enat` and `ℕ∞`. -/
noncomputable def withTopOrderIso : PartENat ≃o ℕ∞ :=
  { withTopEquiv with map_rel_iff' := fun _ _ => withTopEquiv_le }
#align part_enat.with_top_order_iso PartENat.withTopOrderIso
-/

#print PartENat.withTopEquiv_symm_top /-
@[simp]
theorem withTopEquiv_symm_top : withTopEquiv.symm ⊤ = ⊤ :=
  rfl
#align part_enat.with_top_equiv_symm_top PartENat.withTopEquiv_symm_top
-/

#print PartENat.withTopEquiv_symm_coe /-
@[simp]
theorem withTopEquiv_symm_coe (n : Nat) : withTopEquiv.symm n = n :=
  rfl
#align part_enat.with_top_equiv_symm_coe PartENat.withTopEquiv_symm_coe
-/

#print PartENat.withTopEquiv_symm_zero /-
@[simp]
theorem withTopEquiv_symm_zero : withTopEquiv.symm 0 = 0 :=
  rfl
#align part_enat.with_top_equiv_symm_zero PartENat.withTopEquiv_symm_zero
-/

#print PartENat.withTopEquiv_symm_le /-
@[simp]
theorem withTopEquiv_symm_le {x y : ℕ∞} : withTopEquiv.symm x ≤ withTopEquiv.symm y ↔ x ≤ y := by
  rw [← with_top_equiv_le] <;> simp
#align part_enat.with_top_equiv_symm_le PartENat.withTopEquiv_symm_le
-/

#print PartENat.withTopEquiv_symm_lt /-
@[simp]
theorem withTopEquiv_symm_lt {x y : ℕ∞} : withTopEquiv.symm x < withTopEquiv.symm y ↔ x < y := by
  rw [← with_top_equiv_lt] <;> simp
#align part_enat.with_top_equiv_symm_lt PartENat.withTopEquiv_symm_lt
-/

#print PartENat.withTopAddEquiv /-
/-- `to_with_top` induces an additive monoid isomorphism between `part_enat` and `ℕ∞`. -/
noncomputable def withTopAddEquiv : PartENat ≃+ ℕ∞ :=
  { withTopEquiv with
    map_add' := fun x y => by simp only [with_top_equiv] <;> convert to_with_top_add }
#align part_enat.with_top_add_equiv PartENat.withTopAddEquiv
-/

end WithTopEquiv

#print PartENat.lt_wf /-
theorem lt_wf : @WellFounded PartENat (· < ·) := by
  classical
  change WellFounded fun a b : PartENat => a < b
  simp_rw [← to_with_top_lt]
  exact InvImage.wf _ (WithTop.wellFounded_lt Nat.lt_wfRel)
#align part_enat.lt_wf PartENat.lt_wf
-/

instance : WellFoundedLT PartENat :=
  ⟨lt_wf⟩

instance : IsWellOrder PartENat (· < ·) where

instance : WellFoundedRelation PartENat :=
  ⟨(· < ·), lt_wf⟩

section Find

variable (P : ℕ → Prop) [DecidablePred P]

#print PartENat.find /-
/-- The smallest `part_enat` satisfying a (decidable) predicate `P : ℕ → Prop` -/
def find : PartENat :=
  ⟨∃ n, P n, Nat.find⟩
#align part_enat.find PartENat.find
-/

#print PartENat.find_get /-
@[simp]
theorem find_get (h : (find P).Dom) : (find P).get h = Nat.find h :=
  rfl
#align part_enat.find_get PartENat.find_get
-/

#print PartENat.find_dom /-
theorem find_dom (h : ∃ n, P n) : (find P).Dom :=
  h
#align part_enat.find_dom PartENat.find_dom
-/

#print PartENat.lt_find /-
theorem lt_find (n : ℕ) (h : ∀ m ≤ n, ¬P m) : (n : PartENat) < find P :=
  by
  rw [coe_lt_iff]; intro h'; rw [find_get]
  have := @Nat.find_spec P _ h'
  contrapose! this
  exact h _ this
#align part_enat.lt_find PartENat.lt_find
-/

#print PartENat.lt_find_iff /-
theorem lt_find_iff (n : ℕ) : (n : PartENat) < find P ↔ ∀ m ≤ n, ¬P m :=
  by
  refine' ⟨_, lt_find P n⟩
  intro h m hm
  by_cases H : (find P).Dom
  · apply Nat.find_min H; rw [coe_lt_iff] at h ; specialize h H; exact lt_of_le_of_lt hm h
  · exact not_exists.mp H m
#align part_enat.lt_find_iff PartENat.lt_find_iff
-/

#print PartENat.find_le /-
theorem find_le (n : ℕ) (h : P n) : find P ≤ n := by rw [le_coe_iff];
  refine' ⟨⟨_, h⟩, @Nat.find_min' P _ _ _ h⟩
#align part_enat.find_le PartENat.find_le
-/

#print PartENat.find_eq_top_iff /-
theorem find_eq_top_iff : find P = ⊤ ↔ ∀ n, ¬P n :=
  (eq_top_iff_forall_lt _).trans
    ⟨fun h n => (lt_find_iff P n).mp (h n) _ le_rfl, fun h n => lt_find P n fun _ _ => h _⟩
#align part_enat.find_eq_top_iff PartENat.find_eq_top_iff
-/

end Find

noncomputable instance : LinearOrderedAddCommMonoidWithTop PartENat :=
  { PartENat.linearOrder, PartENat.orderedAddCommMonoid, PartENat.orderTop with
    top_add' := top_add }

noncomputable instance : CompleteLinearOrder PartENat :=
  { PartENat.lattice, withTopOrderIso.symm.toGaloisInsertion.liftCompleteLattice,
    PartENat.linearOrder with
    inf := (· ⊓ ·)
    sup := (· ⊔ ·)
    top := ⊤
    bot := ⊥
    le := (· ≤ ·)
    lt := (· < ·) }

end PartENat

