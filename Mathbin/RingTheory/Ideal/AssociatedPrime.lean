/-
Copyright (c) 2022 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang

! This file was ported from Lean 3 source module ring_theory.ideal.associated_prime
! leanprover-community/mathlib commit b5ad141426bb005414324f89719c77c0aa3ec612
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Span
import Mathbin.RingTheory.Ideal.Operations
import Mathbin.RingTheory.Ideal.QuotientOperations
import Mathbin.RingTheory.Noetherian

/-!

# Associated primes of a module

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We provide the definition and related lemmas about associated primes of modules.

## Main definition
- `is_associated_prime`: `is_associated_prime I M` if the prime ideal `I` is the
  annihilator of some `x : M`.
- `associated_primes`: The set of associated primes of a module.

## Main results
- `exists_le_is_associated_prime_of_is_noetherian_ring`: In a noetherian ring, any `ann(x)` is
  contained in an associated prime for `x ≠ 0`.
- `associated_primes.eq_singleton_of_is_primary`: In a noetherian ring, `I.radical` is the only
  associated prime of `R ⧸ I` when `I` is primary.

## Todo

Generalize this to a non-commutative setting once there are annihilator for non-commutative rings.

-/


variable {R : Type _} [CommRing R] (I J : Ideal R) (M : Type _) [AddCommGroup M] [Module R M]

#print IsAssociatedPrime /-
/-- `is_associated_prime I M` if the prime ideal `I` is the annihilator of some `x : M`. -/
def IsAssociatedPrime : Prop :=
  I.IsPrime ∧ ∃ x : M, I = (R ∙ x).annihilator
#align is_associated_prime IsAssociatedPrime
-/

variable (R)

#print associatedPrimes /-
/-- The set of associated primes of a module. -/
def associatedPrimes : Set (Ideal R) :=
  {I | IsAssociatedPrime I M}
#align associated_primes associatedPrimes
-/

variable {I J M R} (h : IsAssociatedPrime I M)

variable {M' : Type _} [AddCommGroup M'] [Module R M'] (f : M →ₗ[R] M')

#print AssociatePrimes.mem_iff /-
theorem AssociatePrimes.mem_iff : I ∈ associatedPrimes R M ↔ IsAssociatedPrime I M :=
  Iff.rfl
#align associate_primes.mem_iff AssociatePrimes.mem_iff
-/

#print IsAssociatedPrime.isPrime /-
theorem IsAssociatedPrime.isPrime : I.IsPrime :=
  h.1
#align is_associated_prime.is_prime IsAssociatedPrime.isPrime
-/

#print IsAssociatedPrime.map_of_injective /-
theorem IsAssociatedPrime.map_of_injective (h : IsAssociatedPrime I M) (hf : Function.Injective f) :
    IsAssociatedPrime I M' := by
  obtain ⟨x, rfl⟩ := h.2
  refine' ⟨h.1, ⟨f x, _⟩⟩
  ext r
  rw [Submodule.mem_annihilator_span_singleton, Submodule.mem_annihilator_span_singleton, ←
    map_smul, ← f.map_zero, hf.eq_iff]
#align is_associated_prime.map_of_injective IsAssociatedPrime.map_of_injective
-/

#print LinearEquiv.isAssociatedPrime_iff /-
theorem LinearEquiv.isAssociatedPrime_iff (l : M ≃ₗ[R] M') :
    IsAssociatedPrime I M ↔ IsAssociatedPrime I M' :=
  ⟨fun h => h.map_of_injective l l.Injective, fun h => h.map_of_injective l.symm l.symm.Injective⟩
#align linear_equiv.is_associated_prime_iff LinearEquiv.isAssociatedPrime_iff
-/

#print not_isAssociatedPrime_of_subsingleton /-
theorem not_isAssociatedPrime_of_subsingleton [Subsingleton M] : ¬IsAssociatedPrime I M :=
  by
  rintro ⟨hI, x, hx⟩
  apply hI.ne_top
  rwa [Subsingleton.elim x 0, submodule.span_singleton_eq_bot.mpr rfl, Submodule.annihilator_bot] at
    hx 
#align not_is_associated_prime_of_subsingleton not_isAssociatedPrime_of_subsingleton
-/

variable (R)

#print exists_le_isAssociatedPrime_of_isNoetherianRing /-
theorem exists_le_isAssociatedPrime_of_isNoetherianRing [H : IsNoetherianRing R] (x : M)
    (hx : x ≠ 0) : ∃ P : Ideal R, IsAssociatedPrime P M ∧ (R ∙ x).annihilator ≤ P :=
  by
  have : (R ∙ x).annihilator ≠ ⊤ := by
    rwa [Ne.def, Ideal.eq_top_iff_one, Submodule.mem_annihilator_span_singleton, one_smul]
  obtain ⟨P, ⟨l, h₁, y, rfl⟩, h₃⟩ :=
    set_has_maximal_iff_noetherian.mpr H
      {P | (R ∙ x).annihilator ≤ P ∧ P ≠ ⊤ ∧ ∃ y : M, P = (R ∙ y).annihilator}
      ⟨(R ∙ x).annihilator, rfl.le, this, x, rfl⟩
  refine' ⟨_, ⟨⟨h₁, _⟩, y, rfl⟩, l⟩
  intro a b hab
  rw [or_iff_not_imp_left]
  intro ha
  rw [Submodule.mem_annihilator_span_singleton] at ha hab 
  have H₁ : (R ∙ y).annihilator ≤ (R ∙ a • y).annihilator :=
    by
    intro c hc
    rw [Submodule.mem_annihilator_span_singleton] at hc ⊢
    rw [smul_comm, hc, smul_zero]
  have H₂ : (Submodule.span R {a • y}).annihilator ≠ ⊤ := by
    rwa [Ne.def, Submodule.annihilator_eq_top_iff, Submodule.span_singleton_eq_bot]
  rwa [H₁.eq_of_not_lt (h₃ (R ∙ a • y).annihilator ⟨l.trans H₁, H₂, _, rfl⟩),
    Submodule.mem_annihilator_span_singleton, smul_comm, smul_smul]
#align exists_le_is_associated_prime_of_is_noetherian_ring exists_le_isAssociatedPrime_of_isNoetherianRing
-/

variable {R}

#print associatedPrimes.subset_of_injective /-
theorem associatedPrimes.subset_of_injective (hf : Function.Injective f) :
    associatedPrimes R M ⊆ associatedPrimes R M' := fun I h => h.map_of_injective f hf
#align associated_primes.subset_of_injective associatedPrimes.subset_of_injective
-/

#print LinearEquiv.AssociatedPrimes.eq /-
theorem LinearEquiv.AssociatedPrimes.eq (l : M ≃ₗ[R] M') :
    associatedPrimes R M = associatedPrimes R M' :=
  le_antisymm (associatedPrimes.subset_of_injective l l.Injective)
    (associatedPrimes.subset_of_injective l.symm l.symm.Injective)
#align linear_equiv.associated_primes.eq LinearEquiv.AssociatedPrimes.eq
-/

#print associatedPrimes.eq_empty_of_subsingleton /-
theorem associatedPrimes.eq_empty_of_subsingleton [Subsingleton M] : associatedPrimes R M = ∅ := by
  ext; simp only [Set.mem_empty_iff_false, iff_false_iff];
  apply not_isAssociatedPrime_of_subsingleton
#align associated_primes.eq_empty_of_subsingleton associatedPrimes.eq_empty_of_subsingleton
-/

variable (R M)

#print associatedPrimes.nonempty /-
theorem associatedPrimes.nonempty [IsNoetherianRing R] [Nontrivial M] :
    (associatedPrimes R M).Nonempty :=
  by
  obtain ⟨x, hx⟩ := exists_ne (0 : M)
  obtain ⟨P, hP, _⟩ := exists_le_isAssociatedPrime_of_isNoetherianRing R x hx
  exact ⟨P, hP⟩
#align associated_primes.nonempty associatedPrimes.nonempty
-/

variable {R M}

#print IsAssociatedPrime.annihilator_le /-
theorem IsAssociatedPrime.annihilator_le (h : IsAssociatedPrime I M) :
    (⊤ : Submodule R M).annihilator ≤ I :=
  by
  obtain ⟨hI, x, rfl⟩ := h
  exact Submodule.annihilator_mono le_top
#align is_associated_prime.annihilator_le IsAssociatedPrime.annihilator_le
-/

#print IsAssociatedPrime.eq_radical /-
theorem IsAssociatedPrime.eq_radical (hI : I.IsPrimary) (h : IsAssociatedPrime J (R ⧸ I)) :
    J = I.radical := by
  obtain ⟨hJ, x, e⟩ := h
  have : x ≠ 0 := by
    rintro rfl; apply hJ.1
    rwa [submodule.span_singleton_eq_bot.mpr rfl, Submodule.annihilator_bot] at e 
  obtain ⟨x, rfl⟩ := Ideal.Quotient.mkₐ_surjective R _ x
  replace e : ∀ {y}, y ∈ J ↔ x * y ∈ I
  · intro y;
    rw [e, Submodule.mem_annihilator_span_singleton, ← map_smul, smul_eq_mul, mul_comm,
      Ideal.Quotient.mkₐ_eq_mk, ← Ideal.Quotient.mk_eq_mk, Submodule.Quotient.mk_eq_zero]
  apply le_antisymm
  · intro y hy
    exact (hI.2 <| e.mp hy).resolve_left ((Submodule.Quotient.mk_eq_zero I).Not.mp this)
  · rw [hJ.radical_le_iff]; intro y hy; exact e.mpr (I.mul_mem_left x hy)
#align is_associated_prime.eq_radical IsAssociatedPrime.eq_radical
-/

#print associatedPrimes.eq_singleton_of_isPrimary /-
theorem associatedPrimes.eq_singleton_of_isPrimary [IsNoetherianRing R] (hI : I.IsPrimary) :
    associatedPrimes R (R ⧸ I) = {I.radical} :=
  by
  ext J
  rw [Set.mem_singleton_iff]
  refine' ⟨IsAssociatedPrime.eq_radical hI, _⟩
  rintro rfl
  haveI : Nontrivial (R ⧸ I) := ⟨⟨(I.Quotient.mk : _) 1, (I.Quotient.mk : _) 0, _⟩⟩
  obtain ⟨a, ha⟩ := associatedPrimes.nonempty R (R ⧸ I)
  exact ha.eq_radical hI ▸ ha
  rw [Ne.def, Ideal.Quotient.eq, sub_zero, ← Ideal.eq_top_iff_one]
  exact hI.1
#align associated_primes.eq_singleton_of_is_primary associatedPrimes.eq_singleton_of_isPrimary
-/

