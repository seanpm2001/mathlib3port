/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Patrick Massot

! This file was ported from Lean 3 source module algebra.big_operators.pi
! leanprover-community/mathlib commit fa2309577c7009ea243cffdf990cd6c84f0ad497
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Card
import Mathbin.Algebra.Group.Prod
import Mathbin.Algebra.BigOperators.Basic
import Mathbin.Algebra.Ring.Pi

/-!
# Big operators for Pi Types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains theorems relevant to big operators in binary and arbitrary product
of monoids and groups
-/


open scoped BigOperators

namespace Pi

#print Pi.list_prod_apply /-
@[to_additive]
theorem list_prod_apply {α : Type _} {β : α → Type _} [∀ a, Monoid (β a)] (a : α)
    (l : List (∀ a, β a)) : l.Prod a = (l.map fun f : ∀ a, β a => f a).Prod :=
  (evalMonoidHom β a).map_list_prod _
#align pi.list_prod_apply Pi.list_prod_apply
#align pi.list_sum_apply Pi.list_sum_apply
-/

#print Pi.multiset_prod_apply /-
@[to_additive]
theorem multiset_prod_apply {α : Type _} {β : α → Type _} [∀ a, CommMonoid (β a)] (a : α)
    (s : Multiset (∀ a, β a)) : s.Prod a = (s.map fun f : ∀ a, β a => f a).Prod :=
  (evalMonoidHom β a).map_multiset_prod _
#align pi.multiset_prod_apply Pi.multiset_prod_apply
#align pi.multiset_sum_apply Pi.multiset_sum_apply
-/

end Pi

#print Finset.prod_apply /-
@[simp, to_additive]
theorem Finset.prod_apply {α : Type _} {β : α → Type _} {γ} [∀ a, CommMonoid (β a)] (a : α)
    (s : Finset γ) (g : γ → ∀ a, β a) : (∏ c in s, g c) a = ∏ c in s, g c a :=
  (Pi.evalMonoidHom β a).map_prod _ _
#align finset.prod_apply Finset.prod_apply
#align finset.sum_apply Finset.sum_apply
-/

#print Finset.prod_fn /-
/-- An 'unapplied' analogue of `finset.prod_apply`. -/
@[to_additive "An 'unapplied' analogue of `finset.sum_apply`."]
theorem Finset.prod_fn {α : Type _} {β : α → Type _} {γ} [∀ a, CommMonoid (β a)] (s : Finset γ)
    (g : γ → ∀ a, β a) : ∏ c in s, g c = fun a => ∏ c in s, g c a :=
  funext fun a => Finset.prod_apply _ _ _
#align finset.prod_fn Finset.prod_fn
#align finset.sum_fn Finset.sum_fn
-/

#print Fintype.prod_apply /-
@[simp, to_additive]
theorem Fintype.prod_apply {α : Type _} {β : α → Type _} {γ : Type _} [Fintype γ]
    [∀ a, CommMonoid (β a)] (a : α) (g : γ → ∀ a, β a) : (∏ c, g c) a = ∏ c, g c a :=
  Finset.prod_apply a Finset.univ g
#align fintype.prod_apply Fintype.prod_apply
#align fintype.sum_apply Fintype.sum_apply
-/

#print prod_mk_prod /-
@[to_additive prod_mk_sum]
theorem prod_mk_prod {α β γ : Type _} [CommMonoid α] [CommMonoid β] (s : Finset γ) (f : γ → α)
    (g : γ → β) : (∏ x in s, f x, ∏ x in s, g x) = ∏ x in s, (f x, g x) :=
  haveI := Classical.decEq γ
  Finset.induction_on s rfl (by simp (config := { contextual := true }) [Prod.ext_iff])
#align prod_mk_prod prod_mk_prod
#align prod_mk_sum prod_mk_sum
-/

section MulSingle

variable {I : Type _} [DecidableEq I] {Z : I → Type _}

variable [∀ i, CommMonoid (Z i)]

#print Finset.univ_prod_mulSingle /-
@[to_additive]
theorem Finset.univ_prod_mulSingle [Fintype I] (f : ∀ i, Z i) : ∏ i, Pi.mulSingle i (f i) = f := by
  ext a; simp
#align finset.univ_prod_mul_single Finset.univ_prod_mulSingle
#align finset.univ_sum_single Finset.univ_sum_single
-/

#print MonoidHom.functions_ext /-
@[to_additive]
theorem MonoidHom.functions_ext [Finite I] (G : Type _) [CommMonoid G] (g h : (∀ i, Z i) →* G)
    (H : ∀ i x, g (Pi.mulSingle i x) = h (Pi.mulSingle i x)) : g = h :=
  by
  cases nonempty_fintype I
  ext k
  rw [← Finset.univ_prod_mulSingle k, g.map_prod, h.map_prod]
  simp only [H]
#align monoid_hom.functions_ext MonoidHom.functions_ext
#align add_monoid_hom.functions_ext AddMonoidHom.functions_ext
-/

#print MonoidHom.functions_ext' /-
/-- This is used as the ext lemma instead of `monoid_hom.functions_ext` for reasons explained in
note [partially-applied ext lemmas]. -/
@[ext,
  to_additive
      "\nThis is used as the ext lemma instead of `add_monoid_hom.functions_ext` for reasons explained in\nnote [partially-applied ext lemmas]."]
theorem MonoidHom.functions_ext' [Finite I] (M : Type _) [CommMonoid M] (g h : (∀ i, Z i) →* M)
    (H : ∀ i, g.comp (MonoidHom.single Z i) = h.comp (MonoidHom.single Z i)) : g = h :=
  g.functions_ext M h fun i => MonoidHom.congr_fun (H i)
#align monoid_hom.functions_ext' MonoidHom.functions_ext'
#align add_monoid_hom.functions_ext' AddMonoidHom.functions_ext'
-/

end MulSingle

section RingHom

open Pi

variable {I : Type _} [DecidableEq I] {f : I → Type _}

variable [∀ i, NonAssocSemiring (f i)]

#print RingHom.functions_ext /-
@[ext]
theorem RingHom.functions_ext [Finite I] (G : Type _) [NonAssocSemiring G] (g h : (∀ i, f i) →+* G)
    (H : ∀ (i : I) (x : f i), g (single i x) = h (single i x)) : g = h :=
  RingHom.coe_addMonoidHom_injective <|
    @AddMonoidHom.functions_ext I _ f _ _ G _ (g : (∀ i, f i) →+ G) h H
#align ring_hom.functions_ext RingHom.functions_ext
-/

end RingHom

namespace Prod

variable {α β γ : Type _} [CommMonoid α] [CommMonoid β] {s : Finset γ} {f : γ → α × β}

#print Prod.fst_prod /-
@[to_additive]
theorem fst_prod : (∏ c in s, f c).1 = ∏ c in s, (f c).1 :=
  (MonoidHom.fst α β).map_prod f s
#align prod.fst_prod Prod.fst_prod
#align prod.fst_sum Prod.fst_sum
-/

#print Prod.snd_prod /-
@[to_additive]
theorem snd_prod : (∏ c in s, f c).2 = ∏ c in s, (f c).2 :=
  (MonoidHom.snd α β).map_prod f s
#align prod.snd_prod Prod.snd_prod
#align prod.snd_sum Prod.snd_sum
-/

end Prod

