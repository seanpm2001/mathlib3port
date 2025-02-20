/-
Copyright (c) 2018 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Jens Wagemaker, Anne Baanen

! This file was ported from Lean 3 source module data.list.prime
! leanprover-community/mathlib commit f2f413b9d4be3a02840d0663dace76e8fe3da053
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Associated
import Mathbin.Data.List.BigOperators.Lemmas
import Mathbin.Data.List.Perm

/-!
# Products of lists of prime elements.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains some theorems relating `prime` and products of `list`s.

-/


open List

section CommMonoidWithZero

variable {M : Type _} [CommMonoidWithZero M]

#print Prime.dvd_prod_iff /-
/-- Prime `p` divides the product of a list `L` iff it divides some `a ∈ L` -/
theorem Prime.dvd_prod_iff {p : M} {L : List M} (pp : Prime p) : p ∣ L.Prod ↔ ∃ a ∈ L, p ∣ a :=
  by
  constructor
  · intro h
    induction' L with L_hd L_tl L_ih
    · rw [prod_nil] at h ; exact absurd h pp.not_dvd_one
    · rw [prod_cons] at h 
      cases' pp.dvd_or_dvd h with hd hd
      · exact ⟨L_hd, mem_cons_self L_hd L_tl, hd⟩
      · obtain ⟨x, hx1, hx2⟩ := L_ih hd
        exact ⟨x, mem_cons_of_mem L_hd hx1, hx2⟩
  · exact fun ⟨a, ha1, ha2⟩ => dvd_trans ha2 (dvd_prod ha1)
#align prime.dvd_prod_iff Prime.dvd_prod_iff
-/

#print Prime.not_dvd_prod /-
theorem Prime.not_dvd_prod {p : M} {L : List M} (pp : Prime p) (hL : ∀ a ∈ L, ¬p ∣ a) :
    ¬p ∣ L.Prod :=
  mt (Prime.dvd_prod_iff pp).mp <| not_bex.mpr hL
#align prime.not_dvd_prod Prime.not_dvd_prod
-/

end CommMonoidWithZero

section CancelCommMonoidWithZero

variable {M : Type _} [CancelCommMonoidWithZero M] [Unique (Units M)]

#print mem_list_primes_of_dvd_prod /-
theorem mem_list_primes_of_dvd_prod {p : M} (hp : Prime p) {L : List M} (hL : ∀ q ∈ L, Prime q)
    (hpL : p ∣ L.Prod) : p ∈ L :=
  by
  obtain ⟨x, hx1, hx2⟩ := hp.dvd_prod_iff.mp hpL
  rwa [(prime_dvd_prime_iff_eq hp (hL x hx1)).mp hx2]
#align mem_list_primes_of_dvd_prod mem_list_primes_of_dvd_prod
-/

#print perm_of_prod_eq_prod /-
theorem perm_of_prod_eq_prod :
    ∀ {l₁ l₂ : List M}, l₁.Prod = l₂.Prod → (∀ p ∈ l₁, Prime p) → (∀ p ∈ l₂, Prime p) → Perm l₁ l₂
  | [], [], _, _, _ => Perm.nil
  | [], a :: l, h₁, h₂, h₃ =>
    have ha : a ∣ 1 := @prod_nil M _ ▸ h₁.symm ▸ (@prod_cons _ _ l a).symm ▸ dvd_mul_right _ _
    absurd ha (Prime.not_dvd_one (h₃ a (mem_cons_self _ _)))
  | a :: l, [], h₁, h₂, h₃ =>
    have ha : a ∣ 1 := @prod_nil M _ ▸ h₁ ▸ (@prod_cons _ _ l a).symm ▸ dvd_mul_right _ _
    absurd ha (Prime.not_dvd_one (h₂ a (mem_cons_self _ _)))
  | a :: l₁, b :: l₂, h, hl₁, hl₂ => by
    classical
    have hl₁' : ∀ p ∈ l₁, Prime p := fun p hp => hl₁ p (mem_cons_of_mem _ hp)
    have hl₂' : ∀ p ∈ (b :: l₂).eraseₓ a, Prime p := fun p hp => hl₂ p (mem_of_mem_erase hp)
    have ha : a ∈ b :: l₂ :=
      mem_list_primes_of_dvd_prod (hl₁ a (mem_cons_self _ _)) hl₂
        (h ▸ by rw [prod_cons] <;> exact dvd_mul_right _ _)
    have hb : b :: l₂ ~ a :: (b :: l₂).eraseₓ a := perm_cons_erase ha
    have hl : Prod l₁ = Prod ((b :: l₂).eraseₓ a) :=
      (mul_right_inj' (hl₁ a (mem_cons_self _ _)).NeZero).1 <| by
        rwa [← prod_cons, ← prod_cons, ← hb.prod_eq]
    exact perm.trans ((perm_of_prod_eq_prod hl hl₁' hl₂').cons _) hb.symm
#align perm_of_prod_eq_prod perm_of_prod_eq_prod
-/

end CancelCommMonoidWithZero

