/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module field_theory.separable
! leanprover-community/mathlib commit 61db041ab8e4aaf8cb5c7dc10a7d4ff261997536
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Squarefree
import Mathbin.Data.Polynomial.Expand
import Mathbin.Data.Polynomial.Splits
import Mathbin.FieldTheory.Minpoly.Field
import Mathbin.RingTheory.PowerBasis

/-!

# Separable polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define a polynomial to be separable if it is coprime with its derivative. We prove basic
properties about separable polynomials here.

## Main definitions

* `polynomial.separable f`: a polynomial `f` is separable iff it is coprime with its derivative.

-/


universe u v w

open scoped Classical BigOperators Polynomial

open Finset

namespace Polynomial

section CommSemiring

variable {R : Type u} [CommSemiring R] {S : Type v} [CommSemiring S]

#print Polynomial.Separable /-
/-- A polynomial is separable iff it is coprime with its derivative. -/
def Separable (f : R[X]) : Prop :=
  IsCoprime f f.derivative
#align polynomial.separable Polynomial.Separable
-/

#print Polynomial.separable_def /-
theorem separable_def (f : R[X]) : f.Separable ↔ IsCoprime f f.derivative :=
  Iff.rfl
#align polynomial.separable_def Polynomial.separable_def
-/

#print Polynomial.separable_def' /-
theorem separable_def' (f : R[X]) : f.Separable ↔ ∃ a b : R[X], a * f + b * f.derivative = 1 :=
  Iff.rfl
#align polynomial.separable_def' Polynomial.separable_def'
-/

#print Polynomial.not_separable_zero /-
theorem not_separable_zero [Nontrivial R] : ¬Separable (0 : R[X]) :=
  by
  rintro ⟨x, y, h⟩
  simpa only [derivative_zero, MulZeroClass.mul_zero, add_zero, zero_ne_one] using h
#align polynomial.not_separable_zero Polynomial.not_separable_zero
-/

#print Polynomial.separable_one /-
theorem separable_one : (1 : R[X]).Separable :=
  isCoprime_one_left
#align polynomial.separable_one Polynomial.separable_one
-/

#print Polynomial.separable_of_subsingleton /-
@[nontriviality]
theorem separable_of_subsingleton [Subsingleton R] (f : R[X]) : f.Separable := by simp [separable]
#align polynomial.separable_of_subsingleton Polynomial.separable_of_subsingleton
-/

#print Polynomial.separable_X_add_C /-
theorem separable_X_add_C (a : R) : (X + C a).Separable :=
  by
  rw [separable_def, derivative_add, derivative_X, derivative_C, add_zero]
  exact isCoprime_one_right
#align polynomial.separable_X_add_C Polynomial.separable_X_add_C
-/

#print Polynomial.separable_X /-
theorem separable_X : (X : R[X]).Separable := by rw [separable_def, derivative_X];
  exact isCoprime_one_right
#align polynomial.separable_X Polynomial.separable_X
-/

#print Polynomial.separable_C /-
theorem separable_C (r : R) : (C r).Separable ↔ IsUnit r := by
  rw [separable_def, derivative_C, isCoprime_zero_right, is_unit_C]
#align polynomial.separable_C Polynomial.separable_C
-/

#print Polynomial.Separable.of_mul_left /-
theorem Separable.of_mul_left {f g : R[X]} (h : (f * g).Separable) : f.Separable :=
  by
  have := h.of_mul_left_left; rw [derivative_mul] at this 
  exact IsCoprime.of_mul_right_left (IsCoprime.of_add_mul_left_right this)
#align polynomial.separable.of_mul_left Polynomial.Separable.of_mul_left
-/

#print Polynomial.Separable.of_mul_right /-
theorem Separable.of_mul_right {f g : R[X]} (h : (f * g).Separable) : g.Separable := by
  rw [mul_comm] at h ; exact h.of_mul_left
#align polynomial.separable.of_mul_right Polynomial.Separable.of_mul_right
-/

#print Polynomial.Separable.of_dvd /-
theorem Separable.of_dvd {f g : R[X]} (hf : f.Separable) (hfg : g ∣ f) : g.Separable := by
  rcases hfg with ⟨f', rfl⟩; exact separable.of_mul_left hf
#align polynomial.separable.of_dvd Polynomial.Separable.of_dvd
-/

#print Polynomial.separable_gcd_left /-
theorem separable_gcd_left {F : Type _} [Field F] {f : F[X]} (hf : f.Separable) (g : F[X]) :
    (EuclideanDomain.gcd f g).Separable :=
  Separable.of_dvd hf (EuclideanDomain.gcd_dvd_left f g)
#align polynomial.separable_gcd_left Polynomial.separable_gcd_left
-/

#print Polynomial.separable_gcd_right /-
theorem separable_gcd_right {F : Type _} [Field F] {g : F[X]} (f : F[X]) (hg : g.Separable) :
    (EuclideanDomain.gcd f g).Separable :=
  Separable.of_dvd hg (EuclideanDomain.gcd_dvd_right f g)
#align polynomial.separable_gcd_right Polynomial.separable_gcd_right
-/

#print Polynomial.Separable.isCoprime /-
theorem Separable.isCoprime {f g : R[X]} (h : (f * g).Separable) : IsCoprime f g :=
  by
  have := h.of_mul_left_left; rw [derivative_mul] at this 
  exact IsCoprime.of_mul_right_right (IsCoprime.of_add_mul_left_right this)
#align polynomial.separable.is_coprime Polynomial.Separable.isCoprime
-/

#print Polynomial.Separable.of_pow' /-
theorem Separable.of_pow' {f : R[X]} :
    ∀ {n : ℕ} (h : (f ^ n).Separable), IsUnit f ∨ f.Separable ∧ n = 1 ∨ n = 0
  | 0 => fun h => Or.inr <| Or.inr rfl
  | 1 => fun h => Or.inr <| Or.inl ⟨pow_one f ▸ h, rfl⟩
  | n + 2 => fun h => by
    rw [pow_succ, pow_succ] at h 
    exact Or.inl (isCoprime_self.1 h.is_coprime.of_mul_right_left)
#align polynomial.separable.of_pow' Polynomial.Separable.of_pow'
-/

#print Polynomial.Separable.of_pow /-
theorem Separable.of_pow {f : R[X]} (hf : ¬IsUnit f) {n : ℕ} (hn : n ≠ 0)
    (hfs : (f ^ n).Separable) : f.Separable ∧ n = 1 :=
  (hfs.of_pow'.resolve_left hf).resolve_right hn
#align polynomial.separable.of_pow Polynomial.Separable.of_pow
-/

#print Polynomial.Separable.map /-
theorem Separable.map {p : R[X]} (h : p.Separable) {f : R →+* S} : (p.map f).Separable :=
  let ⟨a, b, H⟩ := h
  ⟨a.map f, b.map f, by
    rw [derivative_map, ← Polynomial.map_mul, ← Polynomial.map_mul, ← Polynomial.map_add, H,
      Polynomial.map_one]⟩
#align polynomial.separable.map Polynomial.Separable.map
-/

variable (p q : ℕ)

#print Polynomial.isUnit_of_self_mul_dvd_separable /-
theorem isUnit_of_self_mul_dvd_separable {p q : R[X]} (hp : p.Separable) (hq : q * q ∣ p) :
    IsUnit q := by
  obtain ⟨p, rfl⟩ := hq
  apply is_coprime_self.mp
  have : IsCoprime (q * (q * p)) (q * (q.derivative * p + q.derivative * p + q * p.derivative)) :=
    by
    simp only [← mul_assoc, mul_add]
    convert hp
    rw [derivative_mul, derivative_mul]
    ring
  exact IsCoprime.of_mul_right_left (IsCoprime.of_mul_left_left this)
#align polynomial.is_unit_of_self_mul_dvd_separable Polynomial.isUnit_of_self_mul_dvd_separable
-/

#print Polynomial.multiplicity_le_one_of_separable /-
theorem multiplicity_le_one_of_separable {p q : R[X]} (hq : ¬IsUnit q) (hsep : Separable p) :
    multiplicity q p ≤ 1 := by
  contrapose! hq
  apply is_unit_of_self_mul_dvd_separable hsep
  rw [← sq]
  apply multiplicity.pow_dvd_of_le_multiplicity
  simpa only [Nat.cast_one, Nat.cast_bit0] using PartENat.add_one_le_of_lt hq
#align polynomial.multiplicity_le_one_of_separable Polynomial.multiplicity_le_one_of_separable
-/

#print Polynomial.Separable.squarefree /-
theorem Separable.squarefree {p : R[X]} (hsep : Separable p) : Squarefree p :=
  by
  rw [multiplicity.squarefree_iff_multiplicity_le_one p]
  intro f
  by_cases hunit : IsUnit f
  · exact Or.inr hunit
  exact Or.inl (multiplicity_le_one_of_separable hunit hsep)
#align polynomial.separable.squarefree Polynomial.Separable.squarefree
-/

end CommSemiring

section CommRing

variable {R : Type u} [CommRing R]

#print Polynomial.separable_X_sub_C /-
theorem separable_X_sub_C {x : R} : Separable (X - C x) := by
  simpa only [sub_eq_add_neg, C_neg] using separable_X_add_C (-x)
#align polynomial.separable_X_sub_C Polynomial.separable_X_sub_C
-/

#print Polynomial.Separable.mul /-
theorem Separable.mul {f g : R[X]} (hf : f.Separable) (hg : g.Separable) (h : IsCoprime f g) :
    (f * g).Separable := by rw [separable_def, derivative_mul];
  exact
    ((hf.mul_right h).add_mul_left_right _).mul_left ((h.symm.mul_right hg).mul_add_right_right _)
#align polynomial.separable.mul Polynomial.Separable.mul
-/

#print Polynomial.separable_prod' /-
theorem separable_prod' {ι : Sort _} {f : ι → R[X]} {s : Finset ι} :
    (∀ x ∈ s, ∀ y ∈ s, x ≠ y → IsCoprime (f x) (f y)) →
      (∀ x ∈ s, (f x).Separable) → (∏ x in s, f x).Separable :=
  Finset.induction_on s (fun _ _ => separable_one) fun a s has ih h1 h2 =>
    by
    simp_rw [Finset.forall_mem_insert, forall_and] at h1 h2 ; rw [prod_insert has]
    exact
      h2.1.mul (ih h1.2.2 h2.2)
        (IsCoprime.prod_right fun i his => h1.1.2 i his <| Ne.symm <| ne_of_mem_of_not_mem his has)
#align polynomial.separable_prod' Polynomial.separable_prod'
-/

#print Polynomial.separable_prod /-
theorem separable_prod {ι : Sort _} [Fintype ι] {f : ι → R[X]} (h1 : Pairwise (IsCoprime on f))
    (h2 : ∀ x, (f x).Separable) : (∏ x, f x).Separable :=
  separable_prod' (fun x hx y hy hxy => h1 hxy) fun x hx => h2 x
#align polynomial.separable_prod Polynomial.separable_prod
-/

#print Polynomial.Separable.inj_of_prod_X_sub_C /-
theorem Separable.inj_of_prod_X_sub_C [Nontrivial R] {ι : Sort _} {f : ι → R} {s : Finset ι}
    (hfs : (∏ i in s, (X - C (f i))).Separable) {x y : ι} (hx : x ∈ s) (hy : y ∈ s)
    (hfxy : f x = f y) : x = y := by
  by_contra hxy
  rw [← insert_erase hx, prod_insert (not_mem_erase _ _), ←
    insert_erase (mem_erase_of_ne_of_mem (Ne.symm hxy) hy), prod_insert (not_mem_erase _ _), ←
    mul_assoc, hfxy, ← sq] at hfs 
  cases (hfs.of_mul_left.of_pow (not_is_unit_X_sub_C _) two_ne_zero).2
#align polynomial.separable.inj_of_prod_X_sub_C Polynomial.Separable.inj_of_prod_X_sub_C
-/

#print Polynomial.Separable.injective_of_prod_X_sub_C /-
theorem Separable.injective_of_prod_X_sub_C [Nontrivial R] {ι : Sort _} [Fintype ι] {f : ι → R}
    (hfs : (∏ i, (X - C (f i))).Separable) : Function.Injective f := fun x y hfxy =>
  hfs.inj_of_prod_X_sub_C (mem_univ _) (mem_univ _) hfxy
#align polynomial.separable.injective_of_prod_X_sub_C Polynomial.Separable.injective_of_prod_X_sub_C
-/

#print Polynomial.nodup_of_separable_prod /-
theorem nodup_of_separable_prod [Nontrivial R] {s : Multiset R}
    (hs : Separable (Multiset.map (fun a => X - C a) s).Prod) : s.Nodup :=
  by
  rw [Multiset.nodup_iff_ne_cons_cons]
  rintro a t rfl
  refine' not_is_unit_X_sub_C a (is_unit_of_self_mul_dvd_separable hs _)
  simpa only [Multiset.map_cons, Multiset.prod_cons] using mul_dvd_mul_left _ (dvd_mul_right _ _)
#align polynomial.nodup_of_separable_prod Polynomial.nodup_of_separable_prod
-/

#print Polynomial.separable_X_pow_sub_C_unit /-
/-- If `is_unit n` in a `comm_ring R`, then `X ^ n - u` is separable for any unit `u`. -/
theorem separable_X_pow_sub_C_unit {n : ℕ} (u : Rˣ) (hn : IsUnit (n : R)) :
    Separable (X ^ n - C (u : R)) := by
  nontriviality R
  rcases n.eq_zero_or_pos with (rfl | hpos)
  · simpa using hn
  apply (separable_def' (X ^ n - C (u : R))).2
  obtain ⟨n', hn'⟩ := hn.exists_left_inv
  refine' ⟨-C ↑u⁻¹, C ↑u⁻¹ * C n' * X, _⟩
  rw [derivative_sub, derivative_C, sub_zero, derivative_pow X n, derivative_X, mul_one]
  calc
    -C ↑u⁻¹ * (X ^ n - C ↑u) + C ↑u⁻¹ * C n' * X * (↑n * X ^ (n - 1)) =
        C (↑u⁻¹ * ↑u) - C ↑u⁻¹ * X ^ n + C ↑u⁻¹ * C (n' * ↑n) * (X * X ^ (n - 1)) :=
      by simp only [C.map_mul, C_eq_nat_cast]; ring
    _ = 1 := by
      simp only [Units.inv_mul, hn', C.map_one, mul_one, ← pow_succ,
        Nat.sub_add_cancel (show 1 ≤ n from hpos), sub_add_cancel]
#align polynomial.separable_X_pow_sub_C_unit Polynomial.separable_X_pow_sub_C_unit
-/

#print Polynomial.rootMultiplicity_le_one_of_separable /-
theorem rootMultiplicity_le_one_of_separable [Nontrivial R] {p : R[X]} (hsep : Separable p)
    (x : R) : rootMultiplicity x p ≤ 1 :=
  by
  by_cases hp : p = 0
  · simp [hp]
  rw [root_multiplicity_eq_multiplicity, dif_neg hp, ← PartENat.coe_le_coe, PartENat.natCast_get,
    Nat.cast_one]
  exact multiplicity_le_one_of_separable (not_is_unit_X_sub_C _) hsep
#align polynomial.root_multiplicity_le_one_of_separable Polynomial.rootMultiplicity_le_one_of_separable
-/

end CommRing

section IsDomain

variable {R : Type u} [CommRing R] [IsDomain R]

#print Polynomial.count_roots_le_one /-
theorem count_roots_le_one {p : R[X]} (hsep : Separable p) (x : R) : p.roots.count x ≤ 1 :=
  by
  rw [count_roots p]
  exact root_multiplicity_le_one_of_separable hsep x
#align polynomial.count_roots_le_one Polynomial.count_roots_le_one
-/

#print Polynomial.nodup_roots /-
theorem nodup_roots {p : R[X]} (hsep : Separable p) : p.roots.Nodup :=
  Multiset.nodup_iff_count_le_one.mpr (count_roots_le_one hsep)
#align polynomial.nodup_roots Polynomial.nodup_roots
-/

end IsDomain

section Field

variable {F : Type u} [Field F] {K : Type v} [Field K]

#print Polynomial.separable_iff_derivative_ne_zero /-
theorem separable_iff_derivative_ne_zero {f : F[X]} (hf : Irreducible f) :
    f.Separable ↔ f.derivative ≠ 0 :=
  ⟨fun h1 h2 => hf.not_unit <| isCoprime_zero_right.1 <| h2 ▸ h1, fun h =>
    EuclideanDomain.isCoprime_of_dvd (mt And.right h) fun g hg1 hg2 ⟨p, hg3⟩ hg4 =>
      let ⟨u, hu⟩ := (hf.isUnit_or_isUnit hg3).resolve_left hg1
      have : f ∣ f.derivative := by conv_lhs => rw [hg3, ← hu]; rwa [Units.mul_right_dvd]
      not_lt_of_le (natDegree_le_of_dvd this h) <|
        natDegree_derivative_lt <| mt derivative_of_natDegree_zero h⟩
#align polynomial.separable_iff_derivative_ne_zero Polynomial.separable_iff_derivative_ne_zero
-/

#print Polynomial.separable_map /-
theorem separable_map (f : F →+* K) {p : F[X]} : (p.map f).Separable ↔ p.Separable := by
  simp_rw [separable_def, derivative_map, is_coprime_map]
#align polynomial.separable_map Polynomial.separable_map
-/

#print Polynomial.separable_prod_X_sub_C_iff' /-
theorem separable_prod_X_sub_C_iff' {ι : Sort _} {f : ι → F} {s : Finset ι} :
    (∏ i in s, (X - C (f i))).Separable ↔ ∀ x ∈ s, ∀ y ∈ s, f x = f y → x = y :=
  ⟨fun hfs x hx y hy hfxy => hfs.inj_of_prod_X_sub_C hx hy hfxy, fun H => by rw [← prod_attach];
    exact
      separable_prod'
        (fun x hx y hy hxy =>
          @pairwise_coprime_X_sub_C _ _ { x // x ∈ s } (fun x => f x)
            (fun x y hxy => Subtype.eq <| H x.1 x.2 y.1 y.2 hxy) _ _ hxy)
        fun _ _ => separable_X_sub_C⟩
#align polynomial.separable_prod_X_sub_C_iff' Polynomial.separable_prod_X_sub_C_iff'
-/

#print Polynomial.separable_prod_X_sub_C_iff /-
theorem separable_prod_X_sub_C_iff {ι : Sort _} [Fintype ι] {f : ι → F} :
    (∏ i, (X - C (f i))).Separable ↔ Function.Injective f :=
  separable_prod_X_sub_C_iff'.trans <| by simp_rw [mem_univ, true_imp_iff, Function.Injective]
#align polynomial.separable_prod_X_sub_C_iff Polynomial.separable_prod_X_sub_C_iff
-/

section CharP

variable (p : ℕ) [HF : CharP F p]

#print Polynomial.separable_or /-
theorem separable_or {f : F[X]} (hf : Irreducible f) :
    f.Separable ∨ ¬f.Separable ∧ ∃ g : F[X], Irreducible g ∧ expand F p g = f :=
  if H : f.derivative = 0 then by
    rcases p.eq_zero_or_pos with (rfl | hp)
    · haveI := CharP.charP_to_charZero F
      have := nat_degree_eq_zero_of_derivative_eq_zero H
      have := (nat_degree_pos_iff_degree_pos.mpr <| degree_pos_of_irreducible hf).ne'
      contradiction
    haveI := is_local_ring_hom_expand F hp
    exact
      Or.inr
        ⟨by rw [separable_iff_derivative_ne_zero hf, Classical.not_not, H], contract p f,
          of_irreducible_map (↑(expand F p)) (by rwa [← expand_contract p H hp.ne'] at hf ),
          expand_contract p H hp.ne'⟩
  else Or.inl <| (separable_iff_derivative_ne_zero hf).2 H
#align polynomial.separable_or Polynomial.separable_or
-/

#print Polynomial.exists_separable_of_irreducible /-
theorem exists_separable_of_irreducible {f : F[X]} (hf : Irreducible f) (hp : p ≠ 0) :
    ∃ (n : ℕ) (g : F[X]), g.Separable ∧ expand F (p ^ n) g = f :=
  by
  replace hp : p.prime := (CharP.char_is_prime_or_zero F p).resolve_right hp
  induction' hn : f.nat_degree using Nat.strong_induction_on with N ih generalizing f
  rcases separable_or p hf with (h | ⟨h1, g, hg, hgf⟩)
  · refine' ⟨0, f, h, _⟩; rw [pow_zero, expand_one]
  · cases' N with N
    · rw [nat_degree_eq_zero_iff_degree_le_zero, degree_le_zero_iff] at hn 
      rw [hn, separable_C, isUnit_iff_ne_zero, Classical.not_not] at h1 
      have hf0 : f ≠ 0 := hf.ne_zero
      rw [h1, C_0] at hn ; exact absurd hn hf0
    have hg1 : g.nat_degree * p = N.succ := by rwa [← nat_degree_expand, hgf]
    have hg2 : g.nat_degree ≠ 0 := by intro this; rw [this, MulZeroClass.zero_mul] at hg1 ;
      cases hg1
    have hg3 : g.nat_degree < N.succ :=
      by
      rw [← mul_one g.nat_degree, ← hg1]
      exact Nat.mul_lt_mul_of_pos_left hp.one_lt hg2.bot_lt
    rcases ih _ hg3 hg rfl with ⟨n, g, hg4, rfl⟩; refine' ⟨n + 1, g, hg4, _⟩
    rw [← hgf, expand_expand, pow_succ]
#align polynomial.exists_separable_of_irreducible Polynomial.exists_separable_of_irreducible
-/

#print Polynomial.isUnit_or_eq_zero_of_separable_expand /-
theorem isUnit_or_eq_zero_of_separable_expand {f : F[X]} (n : ℕ) (hp : 0 < p)
    (hf : (expand F (p ^ n) f).Separable) : IsUnit f ∨ n = 0 :=
  by
  rw [or_iff_not_imp_right]
  rintro hn : n ≠ 0
  have hf2 : (expand F (p ^ n) f).derivative = 0 := by
    rw [derivative_expand, Nat.cast_pow, CharP.cast_eq_zero, zero_pow hn.bot_lt,
      MulZeroClass.zero_mul, MulZeroClass.mul_zero]
  rw [separable_def, hf2, isCoprime_zero_right, is_unit_iff] at hf 
  rcases hf with ⟨r, hr, hrf⟩
  rw [eq_comm, expand_eq_C (pow_pos hp _)] at hrf 
  rwa [hrf, is_unit_C]
#align polynomial.is_unit_or_eq_zero_of_separable_expand Polynomial.isUnit_or_eq_zero_of_separable_expand
-/

#print Polynomial.unique_separable_of_irreducible /-
theorem unique_separable_of_irreducible {f : F[X]} (hf : Irreducible f) (hp : 0 < p) (n₁ : ℕ)
    (g₁ : F[X]) (hg₁ : g₁.Separable) (hgf₁ : expand F (p ^ n₁) g₁ = f) (n₂ : ℕ) (g₂ : F[X])
    (hg₂ : g₂.Separable) (hgf₂ : expand F (p ^ n₂) g₂ = f) : n₁ = n₂ ∧ g₁ = g₂ :=
  by
  revert g₁ g₂
  wlog hn : n₁ ≤ n₂
  · intro g₁ g₂ hg₁ Hg₁ hg₂ Hg₂
    simpa only [eq_comm] using this hf hp n₂ n₁ (le_of_not_le hn) g₂ g₁ hg₂ Hg₂ hg₁ Hg₁
  have hf0 : f ≠ 0 := hf.ne_zero
  intros; rw [le_iff_exists_add] at hn ; rcases hn with ⟨k, rfl⟩
  rw [← hgf₁, pow_add, expand_mul, expand_inj (pow_pos hp n₁)] at hgf₂ ; subst hgf₂
  subst hgf₁
  rcases is_unit_or_eq_zero_of_separable_expand p k hp hg₁ with (h | rfl)
  · rw [is_unit_iff] at h ; rcases h with ⟨r, hr, rfl⟩
    simp_rw [expand_C] at hf ; exact absurd (is_unit_C.2 hr) hf.1
  · rw [add_zero, pow_zero, expand_one]; constructor <;> rfl
#align polynomial.unique_separable_of_irreducible Polynomial.unique_separable_of_irreducible
-/

end CharP

#print Polynomial.separable_X_pow_sub_C /-
/-- If `n ≠ 0` in `F`, then ` X ^ n - a` is separable for any `a ≠ 0`. -/
theorem separable_X_pow_sub_C {n : ℕ} (a : F) (hn : (n : F) ≠ 0) (ha : a ≠ 0) :
    Separable (X ^ n - C a) :=
  separable_X_pow_sub_C_unit (Units.mk0 a ha) (IsUnit.mk0 n hn)
#align polynomial.separable_X_pow_sub_C Polynomial.separable_X_pow_sub_C
-/

#print Polynomial.X_pow_sub_one_separable_iff /-
-- this can possibly be strengthened to making `separable_X_pow_sub_C_unit` a
-- bi-implication, but it is nontrivial!
/-- In a field `F`, `X ^ n - 1` is separable iff `↑n ≠ 0`. -/
theorem X_pow_sub_one_separable_iff {n : ℕ} : (X ^ n - 1 : F[X]).Separable ↔ (n : F) ≠ 0 :=
  by
  refine' ⟨_, fun h => separable_X_pow_sub_C_unit 1 (IsUnit.mk0 (↑n) h)⟩
  rw [separable_def', derivative_sub, derivative_X_pow, derivative_one, sub_zero]
  -- Suppose `(n : F) = 0`, then the derivative is `0`, so `X ^ n - 1` is a unit, contradiction.
  rintro (h : IsCoprime _ _) hn'
  rw [hn', C_0, MulZeroClass.zero_mul, isCoprime_zero_right] at h 
  exact not_is_unit_X_pow_sub_one F n h
#align polynomial.X_pow_sub_one_separable_iff Polynomial.X_pow_sub_one_separable_iff
-/

section Splits

#print Polynomial.card_rootSet_eq_natDegree /-
theorem card_rootSet_eq_natDegree [Algebra F K] {p : F[X]} (hsep : p.Separable)
    (hsplit : Splits (algebraMap F K) p) : Fintype.card (p.rootSet K) = p.natDegree :=
  by
  simp_rw [root_set_def, Finset.coe_sort_coe, Fintype.card_coe]
  rw [Multiset.toFinset_card_of_nodup, ← nat_degree_eq_card_roots hsplit]
  exact nodup_roots hsep.map
#align polynomial.card_root_set_eq_nat_degree Polynomial.card_rootSet_eq_natDegree
-/

variable {i : F →+* K}

#print Polynomial.eq_X_sub_C_of_separable_of_root_eq /-
theorem eq_X_sub_C_of_separable_of_root_eq {x : F} {h : F[X]} (h_sep : h.Separable)
    (h_root : h.eval x = 0) (h_splits : Splits i h) (h_roots : ∀ y ∈ (h.map i).roots, y = i x) :
    h = C (leadingCoeff h) * (X - C x) :=
  by
  have h_ne_zero : h ≠ 0 := by rintro rfl; exact not_separable_zero h_sep
  apply Polynomial.eq_X_sub_C_of_splits_of_single_root i h_splits
  apply Finset.mk.inj
  · change _ = {i x}
    rw [Finset.eq_singleton_iff_unique_mem]
    constructor
    · apply finset.mem_mk.mpr
      rw [mem_roots (show h.map i ≠ 0 from map_ne_zero h_ne_zero)]
      rw [is_root.def, ← eval₂_eq_eval_map, eval₂_hom, h_root]
      exact RingHom.map_zero i
    · exact h_roots
  · exact nodup_roots (separable.map h_sep)
#align polynomial.eq_X_sub_C_of_separable_of_root_eq Polynomial.eq_X_sub_C_of_separable_of_root_eq
-/

#print Polynomial.exists_finset_of_splits /-
theorem exists_finset_of_splits (i : F →+* K) {f : F[X]} (sep : Separable f) (sp : Splits i f) :
    ∃ s : Finset K, f.map i = C (i f.leadingCoeff) * s.Prod fun a : K => X - C a :=
  by
  obtain ⟨s, h⟩ := (splits_iff_exists_multiset _).1 sp
  use s.to_finset
  rw [h, Finset.prod_eq_multiset_prod, ← Multiset.toFinset_eq]
  apply nodup_of_separable_prod
  apply separable.of_mul_right
  rw [← h]
  exact sep.map
#align polynomial.exists_finset_of_splits Polynomial.exists_finset_of_splits
-/

end Splits

#print Irreducible.separable /-
theorem Irreducible.separable [CharZero F] {f : F[X]} (hf : Irreducible f) : f.Separable :=
  by
  rw [separable_iff_derivative_ne_zero hf, Ne, ← degree_eq_bot, degree_derivative_eq]
  · rintro ⟨⟩
  rw [pos_iff_ne_zero, Ne, nat_degree_eq_zero_iff_degree_le_zero, degree_le_zero_iff]
  refine' fun hf1 => hf.not_unit _
  rw [hf1, is_unit_C, isUnit_iff_ne_zero]
  intro hf2
  rw [hf2, C_0] at hf1 
  exact absurd hf1 hf.ne_zero
#align irreducible.separable Irreducible.separable
-/

end Field

end Polynomial

open Polynomial

section CommRing

variable (F K : Type _) [CommRing F] [Ring K] [Algebra F K]

#print IsSeparable /-
-- TODO: refactor to allow transcendental extensions?
-- See: https://en.wikipedia.org/wiki/Separable_extension#Separability_of_transcendental_extensions
-- Note that right now a Galois extension (class `is_galois`) is defined to be an extension which
-- is separable and normal, so if the definition of separable changes here at some point
-- to allow non-algebraic extensions, then the definition of `is_galois` must also be changed.
/-- Typeclass for separable field extension: `K` is a separable field extension of `F` iff
the minimal polynomial of every `x : K` is separable.

We define this for general (commutative) rings and only assume `F` and `K` are fields if this
is needed for a proof.
-/
class IsSeparable : Prop where
  is_integral' (x : K) : IsIntegral F x
  separable' (x : K) : (minpoly F x).Separable
#align is_separable IsSeparable
-/

variable (F) {K}

#print IsSeparable.isIntegral /-
theorem IsSeparable.isIntegral [IsSeparable F K] : ∀ x : K, IsIntegral F x :=
  IsSeparable.is_integral'
#align is_separable.is_integral IsSeparable.isIntegral
-/

#print IsSeparable.separable /-
theorem IsSeparable.separable [IsSeparable F K] : ∀ x : K, (minpoly F x).Separable :=
  IsSeparable.separable'
#align is_separable.separable IsSeparable.separable
-/

variable {F K}

#print isSeparable_iff /-
theorem isSeparable_iff : IsSeparable F K ↔ ∀ x : K, IsIntegral F x ∧ (minpoly F x).Separable :=
  ⟨fun h x => ⟨@IsSeparable.isIntegral F _ _ _ h x, @IsSeparable.separable F _ _ _ h x⟩, fun h =>
    ⟨fun x => (h x).1, fun x => (h x).2⟩⟩
#align is_separable_iff isSeparable_iff
-/

end CommRing

#print isSeparable_self /-
instance isSeparable_self (F : Type _) [Field F] : IsSeparable F F :=
  ⟨fun x => isIntegral_algebraMap, fun x => by rw [minpoly.eq_X_sub_C']; exact separable_X_sub_C⟩
#align is_separable_self isSeparable_self
-/

#print IsSeparable.of_finite /-
-- See note [lower instance priority]
/-- A finite field extension in characteristic 0 is separable. -/
instance (priority := 100) IsSeparable.of_finite (F K : Type _) [Field F] [Field K] [Algebra F K]
    [FiniteDimensional F K] [CharZero F] : IsSeparable F K :=
  have : ∀ x : K, IsIntegral F x := fun x => Algebra.isIntegral_of_finite _ _ _
  ⟨this, fun x => (minpoly.irreducible (this x)).Separable⟩
#align is_separable.of_finite IsSeparable.of_finite
-/

section IsSeparableTower

variable (F K E : Type _) [Field F] [Field K] [Field E] [Algebra F K] [Algebra F E] [Algebra K E]
  [IsScalarTower F K E]

#print isSeparable_tower_top_of_isSeparable /-
theorem isSeparable_tower_top_of_isSeparable [IsSeparable F E] : IsSeparable K E :=
  ⟨fun x => isIntegral_of_isScalarTower (IsSeparable.isIntegral F x), fun x =>
    (IsSeparable.separable F x).map.of_dvd (minpoly.dvd_map_of_isScalarTower _ _ _)⟩
#align is_separable_tower_top_of_is_separable isSeparable_tower_top_of_isSeparable
-/

#print isSeparable_tower_bot_of_isSeparable /-
theorem isSeparable_tower_bot_of_isSeparable [h : IsSeparable F E] : IsSeparable F K :=
  isSeparable_iff.2 fun x =>
    by
    refine'
      (isSeparable_iff.1 h (algebraMap K E x)).imp isIntegral_tower_bot_of_isIntegral_field
        fun hs => _
    obtain ⟨q, hq⟩ :=
      minpoly.dvd F x
        ((aeval_algebra_map_eq_zero_iff _ _ _).mp (minpoly.aeval F ((algebraMap K E) x)))
    rw [hq] at hs 
    exact hs.of_mul_left
#align is_separable_tower_bot_of_is_separable isSeparable_tower_bot_of_isSeparable
-/

variable {E}

#print IsSeparable.of_algHom /-
theorem IsSeparable.of_algHom (E' : Type _) [Field E'] [Algebra F E'] (f : E →ₐ[F] E')
    [IsSeparable F E'] : IsSeparable F E :=
  by
  letI : Algebra E E' := RingHom.toAlgebra f.to_ring_hom
  haveI : IsScalarTower F E E' := IsScalarTower.of_algebraMap_eq fun x => (f.commutes x).symm
  exact isSeparable_tower_bot_of_isSeparable F E E'
#align is_separable.of_alg_hom IsSeparable.of_algHom
-/

end IsSeparableTower

section CardAlgHom

variable {R S T : Type _} [CommRing S]

variable {K L F : Type _} [Field K] [Field L] [Field F]

variable [Algebra K S] [Algebra K L]

#print AlgHom.card_of_powerBasis /-
theorem AlgHom.card_of_powerBasis (pb : PowerBasis K S) (h_sep : (minpoly K pb.gen).Separable)
    (h_splits : (minpoly K pb.gen).Splits (algebraMap K L)) :
    @Fintype.card (S →ₐ[K] L) (PowerBasis.AlgHom.fintype pb) = pb.dim :=
  by
  let s := ((minpoly K pb.gen).map (algebraMap K L)).roots.toFinset
  have H := fun x => Multiset.mem_toFinset
  rw [Fintype.card_congr pb.lift_equiv', Fintype.card_of_subtype s H, ← pb.nat_degree_minpoly,
    nat_degree_eq_card_roots h_splits, Multiset.toFinset_card_of_nodup]
  exact nodup_roots ((separable_map (algebraMap K L)).mpr h_sep)
#align alg_hom.card_of_power_basis AlgHom.card_of_powerBasis
-/

end CardAlgHom

