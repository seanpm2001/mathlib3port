/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.fintype.big_operators
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Option
import Mathbin.Data.Fintype.Powerset
import Mathbin.Data.Fintype.Sigma
import Mathbin.Data.Fintype.Sum
import Mathbin.Data.Fintype.Vector
import Mathbin.Algebra.BigOperators.Ring
import Mathbin.Algebra.BigOperators.Option

/-!
Results about "big operations" over a `fintype`, and consequent
results about cardinalities of certain types.

## Implementation note

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
This content had previously been in `data.fintype.basic`, but was moved here to avoid
requiring `algebra.big_operators` (and hence many other imports) as a
dependency of `fintype`.

However many of the results here really belong in `algebra.big_operators.basic`
and should be moved at some point.
-/


universe u v

variable {α : Type _} {β : Type _} {γ : Type _}

open scoped BigOperators

namespace Fintype

#print Fintype.prod_bool /-
@[to_additive]
theorem prod_bool [CommMonoid α] (f : Bool → α) : ∏ b, f b = f true * f false := by simp
#align fintype.prod_bool Fintype.prod_bool
#align fintype.sum_bool Fintype.sum_bool
-/

#print Fintype.card_eq_sum_ones /-
theorem card_eq_sum_ones {α} [Fintype α] : Fintype.card α = ∑ a : α, 1 :=
  Finset.card_eq_sum_ones _
#align fintype.card_eq_sum_ones Fintype.card_eq_sum_ones
-/

section

open Finset

variable {ι : Type _} [DecidableEq ι] [Fintype ι]

#print Fintype.prod_extend_by_one /-
@[to_additive]
theorem prod_extend_by_one [CommMonoid α] (s : Finset ι) (f : ι → α) :
    (∏ i, if i ∈ s then f i else 1) = ∏ i in s, f i := by
  rw [← prod_filter, filter_mem_eq_inter, univ_inter]
#align fintype.prod_extend_by_one Fintype.prod_extend_by_one
#align fintype.sum_extend_by_zero Fintype.sum_extend_by_zero
-/

end

section

variable {M : Type _} [Fintype α] [CommMonoid M]

#print Fintype.prod_eq_one /-
@[to_additive]
theorem prod_eq_one (f : α → M) (h : ∀ a, f a = 1) : ∏ a, f a = 1 :=
  Finset.prod_eq_one fun a ha => h a
#align fintype.prod_eq_one Fintype.prod_eq_one
#align fintype.sum_eq_zero Fintype.sum_eq_zero
-/

#print Fintype.prod_congr /-
@[to_additive]
theorem prod_congr (f g : α → M) (h : ∀ a, f a = g a) : ∏ a, f a = ∏ a, g a :=
  Finset.prod_congr rfl fun a ha => h a
#align fintype.prod_congr Fintype.prod_congr
#align fintype.sum_congr Fintype.sum_congr
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x «expr ≠ » a) -/
#print Fintype.prod_eq_single /-
@[to_additive]
theorem prod_eq_single {f : α → M} (a : α) (h : ∀ (x) (_ : x ≠ a), f x = 1) : ∏ x, f x = f a :=
  Finset.prod_eq_single a (fun x _ hx => h x hx) fun ha => (ha (Finset.mem_univ a)).elim
#align fintype.prod_eq_single Fintype.prod_eq_single
#align fintype.sum_eq_single Fintype.sum_eq_single
-/

#print Fintype.prod_eq_mul /-
@[to_additive]
theorem prod_eq_mul {f : α → M} (a b : α) (h₁ : a ≠ b) (h₂ : ∀ x, x ≠ a ∧ x ≠ b → f x = 1) :
    ∏ x, f x = f a * f b := by
  apply Finset.prod_eq_mul a b h₁ fun x _ hx => h₂ x hx <;>
    exact fun hc => (hc (Finset.mem_univ _)).elim
#align fintype.prod_eq_mul Fintype.prod_eq_mul
#align fintype.sum_eq_add Fintype.sum_eq_add
-/

#print Fintype.eq_of_subsingleton_of_prod_eq /-
/-- If a product of a `finset` of a subsingleton type has a given
value, so do the terms in that product. -/
@[to_additive
      "If a sum of a `finset` of a subsingleton type has a given\nvalue, so do the terms in that sum."]
theorem eq_of_subsingleton_of_prod_eq {ι : Type _} [Subsingleton ι] {s : Finset ι} {f : ι → M}
    {b : M} (h : ∏ i in s, f i = b) : ∀ i ∈ s, f i = b :=
  Finset.eq_of_card_le_one_of_prod_eq (Finset.card_le_one_of_subsingleton s) h
#align fintype.eq_of_subsingleton_of_prod_eq Fintype.eq_of_subsingleton_of_prod_eq
#align fintype.eq_of_subsingleton_of_sum_eq Fintype.eq_of_subsingleton_of_sum_eq
-/

end

end Fintype

open Finset

section

variable {M : Type _} [Fintype α] [CommMonoid M]

#print Fintype.prod_option /-
@[simp, to_additive]
theorem Fintype.prod_option (f : Option α → M) : ∏ i, f i = f none * ∏ i, f (some i) :=
  Finset.prod_insertNone f univ
#align fintype.prod_option Fintype.prod_option
#align fintype.sum_option Fintype.sum_option
-/

end

open Finset

#print Fintype.card_sigma /-
@[simp]
theorem Fintype.card_sigma {α : Type _} (β : α → Type _) [Fintype α] [∀ a, Fintype (β a)] :
    Fintype.card (Sigma β) = ∑ a, Fintype.card (β a) :=
  card_sigma _ _
#align fintype.card_sigma Fintype.card_sigma
-/

#print Finset.card_pi /-
@[simp]
theorem Finset.card_pi [DecidableEq α] {δ : α → Type _} (s : Finset α) (t : ∀ a, Finset (δ a)) :
    (s.pi t).card = ∏ a in s, card (t a) :=
  Multiset.card_pi _ _
#align finset.card_pi Finset.card_pi
-/

#print Fintype.card_piFinset /-
@[simp]
theorem Fintype.card_piFinset [DecidableEq α] [Fintype α] {δ : α → Type _} (t : ∀ a, Finset (δ a)) :
    (Fintype.piFinset t).card = ∏ a, card (t a) := by simp [Fintype.piFinset, card_map]
#align fintype.card_pi_finset Fintype.card_piFinset
-/

#print Fintype.card_pi /-
@[simp]
theorem Fintype.card_pi {β : α → Type _} [DecidableEq α] [Fintype α] [f : ∀ a, Fintype (β a)] :
    Fintype.card (∀ a, β a) = ∏ a, Fintype.card (β a) :=
  Fintype.card_piFinset _
#align fintype.card_pi Fintype.card_pi
-/

#print Fintype.card_fun /-
-- FIXME ouch, this should be in the main file.
@[simp]
theorem Fintype.card_fun [DecidableEq α] [Fintype α] [Fintype β] :
    Fintype.card (α → β) = Fintype.card β ^ Fintype.card α := by
  rw [Fintype.card_pi, Finset.prod_const] <;> rfl
#align fintype.card_fun Fintype.card_fun
-/

#print card_vector /-
@[simp]
theorem card_vector [Fintype α] (n : ℕ) : Fintype.card (Vector α n) = Fintype.card α ^ n := by
  rw [Fintype.ofEquiv_card] <;> simp
#align card_vector card_vector
-/

#print Finset.prod_attach_univ /-
@[simp, to_additive]
theorem Finset.prod_attach_univ [Fintype α] [CommMonoid β] (f : { a : α // a ∈ @univ α _ } → β) :
    ∏ x in univ.attach, f x = ∏ x, f ⟨x, mem_univ _⟩ :=
  Fintype.prod_equiv (Equiv.subtypeUnivEquiv fun x => mem_univ _) _ _ fun x => by simp
#align finset.prod_attach_univ Finset.prod_attach_univ
#align finset.sum_attach_univ Finset.sum_attach_univ
-/

#print Finset.prod_univ_pi /-
/-- Taking a product over `univ.pi t` is the same as taking the product over `fintype.pi_finset t`.
  `univ.pi t` and `fintype.pi_finset t` are essentially the same `finset`, but differ
  in the type of their element, `univ.pi t` is a `finset (Π a ∈ univ, t a)` and
  `fintype.pi_finset t` is a `finset (Π a, t a)`. -/
@[to_additive
      "Taking a sum over `univ.pi t` is the same as taking the sum over\n  `fintype.pi_finset t`. `univ.pi t` and `fintype.pi_finset t` are essentially the same `finset`,\n  but differ in the type of their element, `univ.pi t` is a `finset (Π a ∈ univ, t a)` and\n  `fintype.pi_finset t` is a `finset (Π a, t a)`."]
theorem Finset.prod_univ_pi [DecidableEq α] [Fintype α] [CommMonoid β] {δ : α → Type _}
    {t : ∀ a : α, Finset (δ a)} (f : (∀ a : α, a ∈ (univ : Finset α) → δ a) → β) :
    ∏ x in univ.pi t, f x = ∏ x in Fintype.piFinset t, f fun a _ => x a :=
  prod_bij (fun x _ a => x a (mem_univ _)) (by simp) (by simp)
    (by simp (config := { contextual := true }) [Function.funext_iff]) fun x hx =>
    ⟨fun a _ => x a, by simp_all⟩
#align finset.prod_univ_pi Finset.prod_univ_pi
#align finset.sum_univ_pi Finset.sum_univ_pi
-/

#print Finset.prod_univ_sum /-
/-- The product over `univ` of a sum can be written as a sum over the product of sets,
  `fintype.pi_finset`. `finset.prod_sum` is an alternative statement when the product is not
  over `univ` -/
theorem Finset.prod_univ_sum [DecidableEq α] [Fintype α] [CommSemiring β] {δ : α → Type u_1}
    [∀ a : α, DecidableEq (δ a)] {t : ∀ a : α, Finset (δ a)} {f : ∀ a : α, δ a → β} :
    ∏ a, ∑ b in t a, f a b = ∑ p in Fintype.piFinset t, ∏ x, f x (p x) := by
  simp only [Finset.prod_attach_univ, prod_sum, Finset.sum_univ_pi]
#align finset.prod_univ_sum Finset.prod_univ_sum
-/

#print Fintype.sum_pow_mul_eq_add_pow /-
/-- Summing `a^s.card * b^(n-s.card)` over all finite subsets `s` of a fintype of cardinality `n`
gives `(a + b)^n`. The "good" proof involves expanding along all coordinates using the fact that
`x^n` is multilinear, but multilinear maps are only available now over rings, so we give instead
a proof reducing to the usual binomial theorem to have a result over semirings. -/
theorem Fintype.sum_pow_mul_eq_add_pow (α : Type _) [Fintype α] {R : Type _} [CommSemiring R]
    (a b : R) :
    ∑ s : Finset α, a ^ s.card * b ^ (Fintype.card α - s.card) = (a + b) ^ Fintype.card α :=
  Finset.sum_pow_mul_eq_add_pow _ _ _
#align fintype.sum_pow_mul_eq_add_pow Fintype.sum_pow_mul_eq_add_pow
-/

#print Function.Bijective.prod_comp /-
@[to_additive]
theorem Function.Bijective.prod_comp [Fintype α] [Fintype β] [CommMonoid γ] {f : α → β}
    (hf : Function.Bijective f) (g : β → γ) : ∏ i, g (f i) = ∏ i, g i :=
  Fintype.prod_bijective f hf _ _ fun x => rfl
#align function.bijective.prod_comp Function.Bijective.prod_comp
#align function.bijective.sum_comp Function.Bijective.sum_comp
-/

#print Equiv.prod_comp /-
@[to_additive]
theorem Equiv.prod_comp [Fintype α] [Fintype β] [CommMonoid γ] (e : α ≃ β) (f : β → γ) :
    ∏ i, f (e i) = ∏ i, f i :=
  e.Bijective.prod_comp f
#align equiv.prod_comp Equiv.prod_comp
#align equiv.sum_comp Equiv.sum_comp
-/

#print Equiv.prod_comp' /-
@[to_additive]
theorem Equiv.prod_comp' [Fintype α] [Fintype β] [CommMonoid γ] (e : α ≃ β) (f : α → γ) (g : β → γ)
    (h : ∀ i, f i = g (e i)) : ∏ i, f i = ∏ i, g i :=
  (show f = g ∘ e from funext h).symm ▸ e.prod_comp _
#align equiv.prod_comp' Equiv.prod_comp'
#align equiv.sum_comp' Equiv.sum_comp'
-/

#print Fin.prod_univ_eq_prod_range /-
/-- It is equivalent to compute the product of a function over `fin n` or `finset.range n`. -/
@[to_additive "It is equivalent to sum a function over `fin n` or `finset.range n`."]
theorem Fin.prod_univ_eq_prod_range [CommMonoid α] (f : ℕ → α) (n : ℕ) :
    ∏ i : Fin n, f i = ∏ i in range n, f i :=
  calc
    ∏ i : Fin n, f i = ∏ i : { x // x ∈ range n }, f i :=
      (Fin.equivSubtype.trans (Equiv.subtypeEquivRight (by simp))).prod_comp' _ _ (by simp)
    _ = ∏ i in range n, f i := by rw [← attach_eq_univ, prod_attach]
#align fin.prod_univ_eq_prod_range Fin.prod_univ_eq_prod_range
#align fin.sum_univ_eq_sum_range Fin.sum_univ_eq_sum_range
-/

#print Finset.prod_fin_eq_prod_range /-
@[to_additive]
theorem Finset.prod_fin_eq_prod_range [CommMonoid β] {n : ℕ} (c : Fin n → β) :
    ∏ i, c i = ∏ i in Finset.range n, if h : i < n then c ⟨i, h⟩ else 1 :=
  by
  rw [← Fin.prod_univ_eq_prod_range, Finset.prod_congr rfl]
  rintro ⟨i, hi⟩ _
  simp only [Fin.coe_eq_val, hi, dif_pos]
#align finset.prod_fin_eq_prod_range Finset.prod_fin_eq_prod_range
#align finset.sum_fin_eq_sum_range Finset.sum_fin_eq_sum_range
-/

#print Finset.prod_toFinset_eq_subtype /-
@[to_additive]
theorem Finset.prod_toFinset_eq_subtype {M : Type _} [CommMonoid M] [Fintype α] (p : α → Prop)
    [DecidablePred p] (f : α → M) : ∏ a in {x | p x}.toFinset, f a = ∏ a : Subtype p, f a := by
  rw [← Finset.prod_subtype]; simp
#align finset.prod_to_finset_eq_subtype Finset.prod_toFinset_eq_subtype
#align finset.sum_to_finset_eq_subtype Finset.sum_toFinset_eq_subtype
-/

#print Finset.prod_fiberwise /-
@[to_additive]
theorem Finset.prod_fiberwise [DecidableEq β] [Fintype β] [CommMonoid γ] (s : Finset α) (f : α → β)
    (g : α → γ) : ∏ b : β, ∏ a in s.filterₓ fun a => f a = b, g a = ∏ a in s, g a :=
  Finset.prod_fiberwise_of_maps_to (fun x _ => mem_univ _) _
#align finset.prod_fiberwise Finset.prod_fiberwise
#align finset.sum_fiberwise Finset.sum_fiberwise
-/

#print Fintype.prod_fiberwise /-
@[to_additive]
theorem Fintype.prod_fiberwise [Fintype α] [DecidableEq β] [Fintype β] [CommMonoid γ] (f : α → β)
    (g : α → γ) : ∏ b : β, ∏ a : { a // f a = b }, g (a : α) = ∏ a, g a :=
  by
  rw [← (Equiv.sigmaFiberEquiv f).prod_comp, ← univ_sigma_univ, prod_sigma]
  rfl
#align fintype.prod_fiberwise Fintype.prod_fiberwise
#align fintype.sum_fiberwise Fintype.sum_fiberwise
-/

#print Fintype.prod_dite /-
theorem Fintype.prod_dite [Fintype α] {p : α → Prop} [DecidablePred p] [CommMonoid β]
    (f : ∀ (a : α) (ha : p a), β) (g : ∀ (a : α) (ha : ¬p a), β) :
    ∏ a, dite (p a) (f a) (g a) = (∏ a : { a // p a }, f a a.2) * ∏ a : { a // ¬p a }, g a a.2 :=
  by
  simp only [prod_dite, attach_eq_univ]
  congr 1
  · convert (Equiv.subtypeEquivRight _).prod_comp fun x : { x // p x } => f x x.2
    simp
  · convert (Equiv.subtypeEquivRight _).prod_comp fun x : { x // ¬p x } => g x x.2
    simp
#align fintype.prod_dite Fintype.prod_dite
-/

section

open Finset

variable {α₁ : Type _} {α₂ : Type _} {M : Type _} [Fintype α₁] [Fintype α₂] [CommMonoid M]

#print Fintype.prod_sum_elim /-
@[to_additive]
theorem Fintype.prod_sum_elim (f : α₁ → M) (g : α₂ → M) :
    ∏ x, Sum.elim f g x = (∏ a₁, f a₁) * ∏ a₂, g a₂ :=
  prod_disj_sum _ _ _
#align fintype.prod_sum_elim Fintype.prod_sum_elim
#align fintype.sum_sum_elim Fintype.sum_sum_elim
-/

#print Fintype.prod_sum_type /-
@[simp, to_additive]
theorem Fintype.prod_sum_type (f : Sum α₁ α₂ → M) :
    ∏ x, f x = (∏ a₁, f (Sum.inl a₁)) * ∏ a₂, f (Sum.inr a₂) :=
  prod_disj_sum _ _ _
#align fintype.prod_sum_type Fintype.prod_sum_type
#align fintype.sum_sum_type Fintype.sum_sum_type
-/

end

