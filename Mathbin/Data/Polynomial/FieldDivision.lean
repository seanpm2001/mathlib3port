/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Johannes Hölzl, Scott Morrison, Jens Wagemaker

! This file was ported from Lean 3 source module data.polynomial.field_division
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.Derivative
import Mathbin.Data.Polynomial.RingDivision
import Mathbin.RingTheory.EuclideanDomain

/-!
# Theory of univariate polynomials

This file starts looking like the ring theory of $ R[X] $

-/


noncomputable section

open Classical BigOperators Polynomial

namespace Polynomial

universe u v w y z

variable {R : Type u} {S : Type v} {k : Type y} {A : Type z} {a b : R} {n : ℕ}

section IsDomain

variable [CommRing R] [IsDomain R]

theorem derivative_root_multiplicity_of_root [CharZero R] {p : R[X]} {t : R} (hpt : p.IsRoot t) :
    p.derivative.rootMultiplicity t = p.rootMultiplicity t - 1 :=
  by
  rcases eq_or_ne p 0 with (rfl | hp)
  · simp
  nth_rw 1 [← p.div_by_monic_mul_pow_root_multiplicity_eq t]
  simp only [derivative_pow, derivative_mul, derivative_sub, derivative_X, derivative_C, sub_zero,
    mul_one]
  set n := p.root_multiplicity t - 1
  have hn : n + 1 = _ := tsub_add_cancel_of_le ((root_multiplicity_pos hp).mpr hpt)
  rw [← hn]
  set q := p /ₘ (X - C t) ^ (n + 1) with hq
  convert_to root_multiplicity t ((X - C t) ^ n * (derivative q * (X - C t) + q * C ↑(n + 1))) = n
  · congr
    rw [mul_add, mul_left_comm <| (X - C t) ^ n, ← pow_succ']
    congr 1
    rw [mul_left_comm <| (X - C t) ^ n, mul_comm <| (X - C t) ^ n]
  have h : (derivative q * (X - C t) + q * C ↑(n + 1)).eval t ≠ 0 :=
    by
    suffices eval t q * ↑(n + 1) ≠ 0 by simpa
    refine' mul_ne_zero _ (nat.cast_ne_zero.mpr n.succ_ne_zero)
    convert eval_div_by_monic_pow_root_multiplicity_ne_zero t hp
    exact hn ▸ hq
  rw [root_multiplicity_mul, root_multiplicity_X_sub_C_pow, root_multiplicity_eq_zero h, add_zero]
  refine' mul_ne_zero (pow_ne_zero n <| X_sub_C_ne_zero t) _
  contrapose! h
  rw [h, eval_zero]
#align
  polynomial.derivative_root_multiplicity_of_root Polynomial.derivative_root_multiplicity_of_root

theorem root_multiplicity_sub_one_le_derivative_root_multiplicity [CharZero R] (p : R[X]) (t : R) :
    p.rootMultiplicity t - 1 ≤ p.derivative.rootMultiplicity t :=
  by
  by_cases p.is_root t
  · exact (derivative_root_multiplicity_of_root h).symm.le
  · rw [root_multiplicity_eq_zero h, zero_tsub]
    exact zero_le _
#align
  polynomial.root_multiplicity_sub_one_le_derivative_root_multiplicity Polynomial.root_multiplicity_sub_one_le_derivative_root_multiplicity

section NormalizationMonoid

variable [NormalizationMonoid R]

instance : NormalizationMonoid R[X]
    where
  normUnit p :=
    ⟨c ↑(normUnit p.leadingCoeff), c ↑(normUnit p.leadingCoeff)⁻¹, by
      rw [← RingHom.map_mul, Units.mul_inv, C_1], by rw [← RingHom.map_mul, Units.inv_mul, C_1]⟩
  norm_unit_zero := Units.ext (by simp)
  norm_unit_mul p q hp0 hq0 :=
    Units.ext
      (by
        dsimp
        rw [Ne.def, ← leading_coeff_eq_zero] at *
        rw [leading_coeff_mul, norm_unit_mul hp0 hq0, Units.val_mul, C_mul])
  norm_unit_coe_units u :=
    Units.ext
      (by
        rw [← mul_one u⁻¹, Units.val_mul, Units.eq_inv_mul_iff_mul_eq]
        dsimp
        rcases Polynomial.is_unit_iff.1 ⟨u, rfl⟩ with ⟨_, ⟨w, rfl⟩, h2⟩
        rw [← h2, leading_coeff_C, norm_unit_coe_units, ← C_mul, Units.mul_inv, C_1])

@[simp]
theorem coe_norm_unit {p : R[X]} : (normUnit p : R[X]) = c ↑(normUnit p.leadingCoeff) := by
  simp [norm_unit]
#align polynomial.coe_norm_unit Polynomial.coe_norm_unit

theorem leading_coeff_normalize (p : R[X]) :
    leadingCoeff (normalize p) = normalize (leadingCoeff p) := by simp
#align polynomial.leading_coeff_normalize Polynomial.leading_coeff_normalize

theorem Monic.normalize_eq_self {p : R[X]} (hp : p.Monic) : normalize p = p := by
  simp only [Polynomial.coe_norm_unit, normalize_apply, hp.leading_coeff, normUnit_one,
    Units.val_one, polynomial.C.map_one, mul_one]
#align polynomial.monic.normalize_eq_self Polynomial.Monic.normalize_eq_self

theorem roots_normalize {p : R[X]} : (normalize p).roots = p.roots := by
  rw [normalize_apply, mul_comm, coe_norm_unit, roots_C_mul _ (norm_unit (leading_coeff p)).NeZero]
#align polynomial.roots_normalize Polynomial.roots_normalize

end NormalizationMonoid

end IsDomain

section DivisionRing

variable [DivisionRing R] {p q : R[X]}

theorem degree_pos_of_ne_zero_of_nonunit (hp0 : p ≠ 0) (hp : ¬IsUnit p) : 0 < degree p :=
  lt_of_not_ge fun h => by
    rw [eq_C_of_degree_le_zero h] at hp0 hp
    exact hp (IsUnit.map C (IsUnit.mk0 (coeff p 0) (mt C_inj.2 (by simpa using hp0))))
#align polynomial.degree_pos_of_ne_zero_of_nonunit Polynomial.degree_pos_of_ne_zero_of_nonunit

theorem monic_mul_leading_coeff_inv (h : p ≠ 0) : Monic (p * c (leadingCoeff p)⁻¹) := by
  rw [monic, leading_coeff_mul, leading_coeff_C,
    mul_inv_cancel (show leading_coeff p ≠ 0 from mt leading_coeff_eq_zero.1 h)]
#align polynomial.monic_mul_leading_coeff_inv Polynomial.monic_mul_leading_coeff_inv

theorem degree_mul_leading_coeff_inv (p : R[X]) (h : q ≠ 0) :
    degree (p * c (leadingCoeff q)⁻¹) = degree p :=
  by
  have h₁ : (leadingCoeff q)⁻¹ ≠ 0 := inv_ne_zero (mt leading_coeff_eq_zero.1 h)
  rw [degree_mul, degree_C h₁, add_zero]
#align polynomial.degree_mul_leading_coeff_inv Polynomial.degree_mul_leading_coeff_inv

@[simp]
theorem map_eq_zero [Semiring S] [Nontrivial S] (f : R →+* S) : p.map f = 0 ↔ p = 0 := by
  simp only [Polynomial.ext_iff, map_eq_zero, coeff_map, coeff_zero]
#align polynomial.map_eq_zero Polynomial.map_eq_zero

theorem map_ne_zero [Semiring S] [Nontrivial S] {f : R →+* S} (hp : p ≠ 0) : p.map f ≠ 0 :=
  mt (map_eq_zero f).1 hp
#align polynomial.map_ne_zero Polynomial.map_ne_zero

end DivisionRing

section Field

variable [Field R] {p q : R[X]}

theorem is_unit_iff_degree_eq_zero : IsUnit p ↔ degree p = 0 :=
  ⟨degree_eq_zero_of_is_unit, fun h =>
    have : degree p ≤ 0 := by simp [*, le_refl]
    have hc : coeff p 0 ≠ 0 := fun hc => by
      rw [eq_C_of_degree_le_zero this, hc] at h <;> simpa using h
    isUnit_iff_dvd_one.2
      ⟨c (coeff p 0)⁻¹, by
        conv in p => rw [eq_C_of_degree_le_zero this]
        rw [← C_mul, _root_.mul_inv_cancel hc, C_1]⟩⟩
#align polynomial.is_unit_iff_degree_eq_zero Polynomial.is_unit_iff_degree_eq_zero

/-- Division of polynomials. See `polynomial.div_by_monic` for more details.-/
def div (p q : R[X]) :=
  c (leadingCoeff q)⁻¹ * (p /ₘ (q * c (leadingCoeff q)⁻¹))
#align polynomial.div Polynomial.div

/-- Remainder of polynomial division. See `polynomial.mod_by_monic` for more details. -/
def mod (p q : R[X]) :=
  p %ₘ (q * c (leadingCoeff q)⁻¹)
#align polynomial.mod Polynomial.mod

private theorem quotient_mul_add_remainder_eq_aux (p q : R[X]) : q * div p q + mod p q = p :=
  if h : q = 0 then by simp only [h, zero_mul, mod, mod_by_monic_zero, zero_add]
  else
    by
    conv =>
      rhs
      rw [← mod_by_monic_add_div p (monic_mul_leading_coeff_inv h)]
    rw [div, mod, add_comm, mul_assoc]
#align polynomial.quotient_mul_add_remainder_eq_aux polynomial.quotient_mul_add_remainder_eq_aux

private theorem remainder_lt_aux (p : R[X]) (hq : q ≠ 0) : degree (mod p q) < degree q := by
  rw [← degree_mul_leading_coeff_inv q hq] <;>
    exact degree_mod_by_monic_lt p (monic_mul_leading_coeff_inv hq)
#align polynomial.remainder_lt_aux polynomial.remainder_lt_aux

instance : Div R[X] :=
  ⟨div⟩

instance : Mod R[X] :=
  ⟨mod⟩

theorem div_def : p / q = c (leadingCoeff q)⁻¹ * (p /ₘ (q * c (leadingCoeff q)⁻¹)) :=
  rfl
#align polynomial.div_def Polynomial.div_def

theorem mod_def : p % q = p %ₘ (q * c (leadingCoeff q)⁻¹) :=
  rfl
#align polynomial.mod_def Polynomial.mod_def

theorem mod_by_monic_eq_mod (p : R[X]) (hq : Monic q) : p %ₘ q = p % q :=
  show p %ₘ q = p %ₘ (q * c (leadingCoeff q)⁻¹) by simp only [monic.def.1 hq, inv_one, mul_one, C_1]
#align polynomial.mod_by_monic_eq_mod Polynomial.mod_by_monic_eq_mod

theorem div_by_monic_eq_div (p : R[X]) (hq : Monic q) : p /ₘ q = p / q :=
  show p /ₘ q = c (leadingCoeff q)⁻¹ * (p /ₘ (q * c (leadingCoeff q)⁻¹)) by
    simp only [monic.def.1 hq, inv_one, C_1, one_mul, mul_one]
#align polynomial.div_by_monic_eq_div Polynomial.div_by_monic_eq_div

theorem mod_X_sub_C_eq_C_eval (p : R[X]) (a : R) : p % (X - c a) = c (p.eval a) :=
  mod_by_monic_eq_mod p (monic_X_sub_C a) ▸ mod_by_monic_X_sub_C_eq_C_eval _ _
#align polynomial.mod_X_sub_C_eq_C_eval Polynomial.mod_X_sub_C_eq_C_eval

theorem mul_div_eq_iff_is_root : (X - c a) * (p / (X - c a)) = p ↔ IsRoot p a :=
  div_by_monic_eq_div p (monic_X_sub_C a) ▸ mul_div_by_monic_eq_iff_is_root
#align polynomial.mul_div_eq_iff_is_root Polynomial.mul_div_eq_iff_is_root

instance : EuclideanDomain R[X] :=
  { Polynomial.commRing,
    Polynomial.nontrivial with
    Quotient := (· / ·)
    quotient_zero := by simp [div_def]
    remainder := (· % ·)
    R := _
    r_well_founded := degree_lt_wf
    quotient_mul_add_remainder_eq := quotient_mul_add_remainder_eq_aux
    remainder_lt := fun p q hq => remainder_lt_aux _ hq
    mul_left_not_lt := fun p q hq => not_lt_of_ge (degree_le_mul_left _ hq) }

theorem mod_eq_self_iff (hq0 : q ≠ 0) : p % q = p ↔ degree p < degree q :=
  ⟨fun h => h ▸ EuclideanDomain.mod_lt _ hq0, fun h =>
    by
    have : ¬degree (q * c (leadingCoeff q)⁻¹) ≤ degree p :=
      not_le_of_gt <| by rwa [degree_mul_leading_coeff_inv q hq0]
    rw [mod_def, mod_by_monic, dif_pos (monic_mul_leading_coeff_inv hq0)]
    unfold div_mod_by_monic_aux
    simp only [this, false_and_iff, if_false]⟩
#align polynomial.mod_eq_self_iff Polynomial.mod_eq_self_iff

theorem div_eq_zero_iff (hq0 : q ≠ 0) : p / q = 0 ↔ degree p < degree q :=
  ⟨fun h => by
    have := EuclideanDomain.div_add_mod p q <;>
      rwa [h, mul_zero, zero_add, mod_eq_self_iff hq0] at this,
    fun h =>
    by
    have hlt : degree p < degree (q * c (leadingCoeff q)⁻¹) := by
      rwa [degree_mul_leading_coeff_inv q hq0]
    have hm : Monic (q * c (leadingCoeff q)⁻¹) := monic_mul_leading_coeff_inv hq0
    rw [div_def, (div_by_monic_eq_zero_iff hm).2 hlt, mul_zero]⟩
#align polynomial.div_eq_zero_iff Polynomial.div_eq_zero_iff

theorem degree_add_div (hq0 : q ≠ 0) (hpq : degree q ≤ degree p) :
    degree q + degree (p / q) = degree p :=
  by
  have : degree (p % q) < degree (q * (p / q)) :=
    calc
      degree (p % q) < degree q := EuclideanDomain.mod_lt _ hq0
      _ ≤ _ := degree_le_mul_left _ (mt (div_eq_zero_iff hq0).1 (not_lt_of_ge hpq))
      
  conv_rhs =>
    rw [← EuclideanDomain.div_add_mod p q, degree_add_eq_left_of_degree_lt this, degree_mul]
#align polynomial.degree_add_div Polynomial.degree_add_div

theorem degree_div_le (p q : R[X]) : degree (p / q) ≤ degree p :=
  if hq : q = 0 then by simp [hq]
  else by
    rw [div_def, mul_comm, degree_mul_leading_coeff_inv _ hq] <;> exact degree_div_by_monic_le _ _
#align polynomial.degree_div_le Polynomial.degree_div_le

theorem degree_div_lt (hp : p ≠ 0) (hq : 0 < degree q) : degree (p / q) < degree p :=
  by
  have hq0 : q ≠ 0 := fun hq0 => by simpa [hq0] using hq
  rw [div_def, mul_comm, degree_mul_leading_coeff_inv _ hq0] <;>
    exact
      degree_div_by_monic_lt _ (monic_mul_leading_coeff_inv hq0) hp
        (by rw [degree_mul_leading_coeff_inv _ hq0] <;> exact hq)
#align polynomial.degree_div_lt Polynomial.degree_div_lt

@[simp]
theorem degree_map [DivisionRing k] (p : R[X]) (f : R →+* k) : degree (p.map f) = degree p :=
  p.degree_map_eq_of_injective f.Injective
#align polynomial.degree_map Polynomial.degree_map

@[simp]
theorem nat_degree_map [DivisionRing k] (f : R →+* k) : natDegree (p.map f) = natDegree p :=
  nat_degree_eq_of_degree_eq (degree_map _ f)
#align polynomial.nat_degree_map Polynomial.nat_degree_map

@[simp]
theorem leading_coeff_map [DivisionRing k] (f : R →+* k) :
    leadingCoeff (p.map f) = f (leadingCoeff p) := by
  simp only [← coeff_nat_degree, coeff_map f, nat_degree_map]
#align polynomial.leading_coeff_map Polynomial.leading_coeff_map

theorem monic_map_iff [DivisionRing k] {f : R →+* k} {p : R[X]} : (p.map f).Monic ↔ p.Monic := by
  rw [monic, leading_coeff_map, ← f.map_one, Function.Injective.eq_iff f.injective, monic]
#align polynomial.monic_map_iff Polynomial.monic_map_iff

theorem is_unit_map [Field k] (f : R →+* k) : IsUnit (p.map f) ↔ IsUnit p := by
  simp_rw [is_unit_iff_degree_eq_zero, degree_map]
#align polynomial.is_unit_map Polynomial.is_unit_map

theorem map_div [Field k] (f : R →+* k) : (p / q).map f = p.map f / q.map f :=
  if hq0 : q = 0 then by simp [hq0]
  else by
    rw [div_def, div_def, Polynomial.map_mul,
        map_div_by_monic f (monic_mul_leading_coeff_inv hq0)] <;>
      simp [coeff_map f]
#align polynomial.map_div Polynomial.map_div

theorem map_mod [Field k] (f : R →+* k) : (p % q).map f = p.map f % q.map f :=
  if hq0 : q = 0 then by simp [hq0]
  else by
    rw [mod_def, mod_def, leading_coeff_map f, ← map_inv₀ f, ← map_C f, ← Polynomial.map_mul f,
      map_mod_by_monic f (monic_mul_leading_coeff_inv hq0)]
#align polynomial.map_mod Polynomial.map_mod

section

open EuclideanDomain

theorem gcd_map [Field k] (f : R →+* k) : gcd (p.map f) (q.map f) = (gcd p q).map f :=
  (GCD.induction p q fun x => by simp_rw [Polynomial.map_zero, EuclideanDomain.gcd_zero_left])
    fun x y hx ih => by rw [gcd_val, ← map_mod, ih, ← gcd_val]
#align polynomial.gcd_map Polynomial.gcd_map

end

theorem eval₂_gcd_eq_zero [CommSemiring k] {ϕ : R →+* k} {f g : R[X]} {α : k} (hf : f.eval₂ ϕ α = 0)
    (hg : g.eval₂ ϕ α = 0) : (EuclideanDomain.gcd f g).eval₂ ϕ α = 0 := by
  rw [EuclideanDomain.gcd_eq_gcd_ab f g, Polynomial.eval₂_add, Polynomial.eval₂_mul,
    Polynomial.eval₂_mul, hf, hg, zero_mul, zero_mul, zero_add]
#align polynomial.eval₂_gcd_eq_zero Polynomial.eval₂_gcd_eq_zero

theorem eval_gcd_eq_zero {f g : R[X]} {α : R} (hf : f.eval α = 0) (hg : g.eval α = 0) :
    (EuclideanDomain.gcd f g).eval α = 0 :=
  eval₂_gcd_eq_zero hf hg
#align polynomial.eval_gcd_eq_zero Polynomial.eval_gcd_eq_zero

theorem root_left_of_root_gcd [CommSemiring k] {ϕ : R →+* k} {f g : R[X]} {α : k}
    (hα : (EuclideanDomain.gcd f g).eval₂ ϕ α = 0) : f.eval₂ ϕ α = 0 :=
  by
  cases' EuclideanDomain.gcd_dvd_left f g with p hp
  rw [hp, Polynomial.eval₂_mul, hα, zero_mul]
#align polynomial.root_left_of_root_gcd Polynomial.root_left_of_root_gcd

theorem root_right_of_root_gcd [CommSemiring k] {ϕ : R →+* k} {f g : R[X]} {α : k}
    (hα : (EuclideanDomain.gcd f g).eval₂ ϕ α = 0) : g.eval₂ ϕ α = 0 :=
  by
  cases' EuclideanDomain.gcd_dvd_right f g with p hp
  rw [hp, Polynomial.eval₂_mul, hα, zero_mul]
#align polynomial.root_right_of_root_gcd Polynomial.root_right_of_root_gcd

theorem root_gcd_iff_root_left_right [CommSemiring k] {ϕ : R →+* k} {f g : R[X]} {α : k} :
    (EuclideanDomain.gcd f g).eval₂ ϕ α = 0 ↔ f.eval₂ ϕ α = 0 ∧ g.eval₂ ϕ α = 0 :=
  ⟨fun h => ⟨root_left_of_root_gcd h, root_right_of_root_gcd h⟩, fun h => eval₂_gcd_eq_zero h.1 h.2⟩
#align polynomial.root_gcd_iff_root_left_right Polynomial.root_gcd_iff_root_left_right

theorem is_root_gcd_iff_is_root_left_right {f g : R[X]} {α : R} :
    (EuclideanDomain.gcd f g).IsRoot α ↔ f.IsRoot α ∧ g.IsRoot α :=
  root_gcd_iff_root_left_right
#align polynomial.is_root_gcd_iff_is_root_left_right Polynomial.is_root_gcd_iff_is_root_left_right

theorem is_coprime_map [Field k] (f : R →+* k) : IsCoprime (p.map f) (q.map f) ↔ IsCoprime p q := by
  rw [← EuclideanDomain.gcd_is_unit_iff, ← EuclideanDomain.gcd_is_unit_iff, gcd_map, is_unit_map]
#align polynomial.is_coprime_map Polynomial.is_coprime_map

theorem mem_roots_map [CommRing k] [IsDomain k] {f : R →+* k} {x : k} (hp : p ≠ 0) :
    x ∈ (p.map f).roots ↔ p.eval₂ f x = 0 := by
  rw [mem_roots (map_ne_zero hp), is_root, Polynomial.eval_map] <;> infer_instance
#align polynomial.mem_roots_map Polynomial.mem_roots_map

theorem root_set_monomial [CommRing S] [IsDomain S] [Algebra R S] {n : ℕ} (hn : n ≠ 0) {a : R}
    (ha : a ≠ 0) : (monomial n a).rootSet S = {0} := by
  rw [root_set, map_monomial, roots_monomial ((_root_.map_ne_zero (algebraMap R S)).2 ha),
    Multiset.to_finset_nsmul _ _ hn, Multiset.to_finset_singleton, Finset.coe_singleton]
#align polynomial.root_set_monomial Polynomial.root_set_monomial

theorem root_set_C_mul_X_pow [CommRing S] [IsDomain S] [Algebra R S] {n : ℕ} (hn : n ≠ 0) {a : R}
    (ha : a ≠ 0) : (c a * X ^ n).rootSet S = {0} := by
  rw [C_mul_X_pow_eq_monomial, root_set_monomial hn ha]
#align polynomial.root_set_C_mul_X_pow Polynomial.root_set_C_mul_X_pow

theorem root_set_X_pow [CommRing S] [IsDomain S] [Algebra R S] {n : ℕ} (hn : n ≠ 0) :
    (X ^ n : R[X]).rootSet S = {0} :=
  by
  rw [← one_mul (X ^ n : R[X]), ← C_1, root_set_C_mul_X_pow hn]
  exact one_ne_zero
#align polynomial.root_set_X_pow Polynomial.root_set_X_pow

theorem root_set_prod [CommRing S] [IsDomain S] [Algebra R S] {ι : Type _} (f : ι → R[X])
    (s : Finset ι) (h : s.Prod f ≠ 0) : (s.Prod f).rootSet S = ⋃ i ∈ s, (f i).rootSet S :=
  by
  simp only [root_set, ← Finset.mem_coe]
  rw [Polynomial.map_prod, roots_prod, Finset.bind_to_finset, s.val_to_finset, Finset.coe_bUnion]
  rwa [← Polynomial.map_prod, Ne, map_eq_zero]
#align polynomial.root_set_prod Polynomial.root_set_prod

theorem exists_root_of_degree_eq_one (h : degree p = 1) : ∃ x, IsRoot p x :=
  ⟨-(p.coeff 0 / p.coeff 1),
    by
    have : p.coeff 1 ≠ 0 := by
      rw [← nat_degree_eq_of_degree_eq_some h] <;>
        exact mt leading_coeff_eq_zero.1 fun h0 => by simpa [h0] using h
    conv in p => rw [eq_X_add_C_of_degree_le_one (show degree p ≤ 1 by rw [h] <;> exact le_rfl)] <;>
      simp [is_root, mul_div_cancel' _ this]⟩
#align polynomial.exists_root_of_degree_eq_one Polynomial.exists_root_of_degree_eq_one

theorem coeff_inv_units (u : R[X]ˣ) (n : ℕ) : ((↑u : R[X]).coeff n)⁻¹ = (↑u⁻¹ : R[X]).coeff n :=
  by
  rw [eq_C_of_degree_eq_zero (degree_coe_units u), eq_C_of_degree_eq_zero (degree_coe_units u⁻¹),
    coeff_C, coeff_C, inv_eq_one_div]
  split_ifs
  ·
    rw [div_eq_iff_mul_eq (coeff_coe_units_zero_ne_zero u), coeff_zero_eq_eval_zero,
        coeff_zero_eq_eval_zero, ← eval_mul, ← Units.val_mul, inv_mul_self] <;>
      simp
  · simp
#align polynomial.coeff_inv_units Polynomial.coeff_inv_units

theorem monic_normalize (hp0 : p ≠ 0) : Monic (normalize p) :=
  by
  rw [Ne.def, ← leading_coeff_eq_zero, ← Ne.def, ← isUnit_iff_ne_zero] at hp0
  rw [monic, leading_coeff_normalize, normalize_eq_one]
  apply hp0
#align polynomial.monic_normalize Polynomial.monic_normalize

theorem leading_coeff_div (hpq : q.degree ≤ p.degree) :
    (p / q).leadingCoeff = p.leadingCoeff / q.leadingCoeff :=
  by
  by_cases hq : q = 0; · simp [hq]
  rw [div_def, leading_coeff_mul, leading_coeff_C,
    leading_coeff_div_by_monic_of_monic (monic_mul_leading_coeff_inv hq) _, mul_comm,
    div_eq_mul_inv]
  rwa [degree_mul_leading_coeff_inv q hq]
#align polynomial.leading_coeff_div Polynomial.leading_coeff_div

theorem div_C_mul : p / (c a * q) = c a⁻¹ * (p / q) :=
  by
  by_cases ha : a = 0
  · simp [ha]
  simp only [div_def, leading_coeff_mul, mul_inv, leading_coeff_C, C.map_mul, mul_assoc]
  congr 3
  rw [mul_left_comm q, ← mul_assoc, ← C.map_mul, mul_inv_cancel ha, C.map_one, one_mul]
#align polynomial.div_C_mul Polynomial.div_C_mul

theorem C_mul_dvd (ha : a ≠ 0) : c a * p ∣ q ↔ p ∣ q :=
  ⟨fun h => dvd_trans (dvd_mul_left _ _) h, fun ⟨r, hr⟩ =>
    ⟨c a⁻¹ * r, by
      rw [mul_assoc, mul_left_comm p, ← mul_assoc, ← C.map_mul, _root_.mul_inv_cancel ha, C.map_one,
        one_mul, hr]⟩⟩
#align polynomial.C_mul_dvd Polynomial.C_mul_dvd

theorem dvd_C_mul (ha : a ≠ 0) : p ∣ Polynomial.c a * q ↔ p ∣ q :=
  ⟨fun ⟨r, hr⟩ =>
    ⟨c a⁻¹ * r, by
      rw [mul_left_comm p, ← hr, ← mul_assoc, ← C.map_mul, _root_.inv_mul_cancel ha, C.map_one,
        one_mul]⟩,
    fun h => dvd_trans h (dvd_mul_left _ _)⟩
#align polynomial.dvd_C_mul Polynomial.dvd_C_mul

theorem coe_norm_unit_of_ne_zero (hp : p ≠ 0) : (normUnit p : R[X]) = c p.leadingCoeff⁻¹ :=
  by
  have : p.leadingCoeff ≠ 0 := mt leading_coeff_eq_zero.mp hp
  simp [CommGroupWithZero.coe_normUnit _ this]
#align polynomial.coe_norm_unit_of_ne_zero Polynomial.coe_norm_unit_of_ne_zero

theorem normalize_monic (h : Monic p) : normalize p = p := by simp [h]
#align polynomial.normalize_monic Polynomial.normalize_monic

theorem map_dvd_map' [Field k] (f : R →+* k) {x y : R[X]} : x.map f ∣ y.map f ↔ x ∣ y :=
  if H : x = 0 then by rw [H, Polynomial.map_zero, zero_dvd_iff, zero_dvd_iff, map_eq_zero]
  else by
    rw [← normalize_dvd_iff, ← @normalize_dvd_iff R[X], normalize_apply, normalize_apply,
      coe_norm_unit_of_ne_zero H, coe_norm_unit_of_ne_zero (mt (map_eq_zero f).1 H),
      leading_coeff_map, ← map_inv₀ f, ← map_C, ← Polynomial.map_mul,
      map_dvd_map _ f.injective (monic_mul_leading_coeff_inv H)]
#align polynomial.map_dvd_map' Polynomial.map_dvd_map'

theorem degree_normalize : degree (normalize p) = degree p := by simp
#align polynomial.degree_normalize Polynomial.degree_normalize

theorem prime_of_degree_eq_one (hp1 : degree p = 1) : Prime p :=
  have : Prime (normalize p) :=
    Monic.prime_of_degree_eq_one (hp1 ▸ degree_normalize)
      (monic_normalize fun hp0 => absurd hp1 (hp0.symm ▸ by simp <;> exact by decide))
  (normalize_associated _).Prime this
#align polynomial.prime_of_degree_eq_one Polynomial.prime_of_degree_eq_one

theorem irreducible_of_degree_eq_one (hp1 : degree p = 1) : Irreducible p :=
  (prime_of_degree_eq_one hp1).Irreducible
#align polynomial.irreducible_of_degree_eq_one Polynomial.irreducible_of_degree_eq_one

theorem not_irreducible_C (x : R) : ¬Irreducible (c x) :=
  if H : x = 0 then by
    rw [H, C_0]
    exact not_irreducible_zero
  else fun hx => Irreducible.not_unit hx <| is_unit_C.2 <| isUnit_iff_ne_zero.2 H
#align polynomial.not_irreducible_C Polynomial.not_irreducible_C

theorem degree_pos_of_irreducible (hp : Irreducible p) : 0 < p.degree :=
  lt_of_not_ge fun hp0 =>
    have := eq_C_of_degree_le_zero hp0
    not_irreducible_C (p.coeff 0) <| this ▸ hp
#align polynomial.degree_pos_of_irreducible Polynomial.degree_pos_of_irreducible

/-- If `f` is a polynomial over a field, and `a : K` satisfies `f' a ≠ 0`,
then `f / (X - a)` is coprime with `X - a`.
Note that we do not assume `f a = 0`, because `f / (X - a) = (f - f a) / (X - a)`. -/
theorem is_coprime_of_is_root_of_eval_derivative_ne_zero {K : Type _} [Field K] (f : K[X]) (a : K)
    (hf' : f.derivative.eval a ≠ 0) : IsCoprime (X - c a : K[X]) (f /ₘ (X - c a)) :=
  by
  refine'
    Or.resolve_left
      (EuclideanDomain.dvd_or_coprime (X - C a) (f /ₘ (X - C a))
        (irreducible_of_degree_eq_one (Polynomial.degree_X_sub_C a)))
      _
  contrapose! hf' with h
  have key : (X - C a) * (f /ₘ (X - C a)) = f - f %ₘ (X - C a) :=
    by
    rw [eq_sub_iff_add_eq, ← eq_sub_iff_add_eq', mod_by_monic_eq_sub_mul_div]
    exact monic_X_sub_C a
  replace key := congr_arg derivative key
  simp only [derivative_X, derivative_mul, one_mul, sub_zero, derivative_sub,
    mod_by_monic_X_sub_C_eq_C_eval, derivative_C] at key
  have : X - C a ∣ derivative f := key ▸ dvd_add h (dvd_mul_right _ _)
  rw [← dvd_iff_mod_by_monic_eq_zero (monic_X_sub_C _), mod_by_monic_X_sub_C_eq_C_eval] at this
  rw [← C_inj, this, C_0]
#align
  polynomial.is_coprime_of_is_root_of_eval_derivative_ne_zero Polynomial.is_coprime_of_is_root_of_eval_derivative_ne_zero

end Field

end Polynomial

