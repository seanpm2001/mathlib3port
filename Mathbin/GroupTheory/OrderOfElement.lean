/-
Copyright (c) 2018 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Julian Kuelshammer

! This file was ported from Lean 3 source module group_theory.order_of_element
! leanprover-community/mathlib commit 3dadefa3f544b1db6214777fe47910739b54c66a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.Iterate
import Mathbin.Data.Nat.Modeq
import Mathbin.Data.Set.Pointwise.Basic
import Mathbin.Data.Set.Intervals.Infinite
import Mathbin.Dynamics.PeriodicPts
import Mathbin.GroupTheory.Index

/-!
# Order of an element

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the order of an element of a finite group. For a finite group `G` the order of
`x ∈ G` is the minimal `n ≥ 1` such that `x ^ n = 1`.

## Main definitions

* `is_of_fin_order` is a predicate on an element `x` of a monoid `G` saying that `x` is of finite
  order.
* `is_of_fin_add_order` is the additive analogue of `is_of_fin_order`.
* `order_of x` defines the order of an element `x` of a monoid `G`, by convention its value is `0`
  if `x` has infinite order.
* `add_order_of` is the additive analogue of `order_of`.

## Tags
order of an element
-/


open Function Nat

open scoped Pointwise

universe u v

variable {G : Type u} {A : Type v}

variable {x y : G} {a b : A} {n m : ℕ}

section MonoidAddMonoid

variable [Monoid G] [AddMonoid A]

section IsOfFinOrder

#print isPeriodicPt_mul_iff_pow_eq_one /-
@[to_additive]
theorem isPeriodicPt_mul_iff_pow_eq_one (x : G) : IsPeriodicPt ((· * ·) x) n 1 ↔ x ^ n = 1 := by
  rw [is_periodic_pt, is_fixed_pt, mul_left_iterate, mul_one]
#align is_periodic_pt_mul_iff_pow_eq_one isPeriodicPt_mul_iff_pow_eq_one
#align is_periodic_pt_add_iff_nsmul_eq_zero isPeriodicPt_add_iff_nsmul_eq_zero
-/

#print IsOfFinAddOrder /-
/-- `is_of_fin_add_order` is a predicate on an element `a` of an additive monoid to be of finite
order, i.e. there exists `n ≥ 1` such that `n • a = 0`.-/
def IsOfFinAddOrder (a : A) : Prop :=
  (0 : A) ∈ periodicPts ((· + ·) a)
#align is_of_fin_add_order IsOfFinAddOrder
-/

#print IsOfFinOrder /-
/-- `is_of_fin_order` is a predicate on an element `x` of a monoid to be of finite order, i.e. there
exists `n ≥ 1` such that `x ^ n = 1`.-/
@[to_additive IsOfFinAddOrder]
def IsOfFinOrder (x : G) : Prop :=
  (1 : G) ∈ periodicPts ((· * ·) x)
#align is_of_fin_order IsOfFinOrder
#align is_of_fin_add_order IsOfFinAddOrder
-/

#print isOfFinAddOrder_ofMul_iff /-
theorem isOfFinAddOrder_ofMul_iff : IsOfFinAddOrder (Additive.ofMul x) ↔ IsOfFinOrder x :=
  Iff.rfl
#align is_of_fin_add_order_of_mul_iff isOfFinAddOrder_ofMul_iff
-/

#print isOfFinOrder_ofAdd_iff /-
theorem isOfFinOrder_ofAdd_iff : IsOfFinOrder (Multiplicative.ofAdd a) ↔ IsOfFinAddOrder a :=
  Iff.rfl
#align is_of_fin_order_of_add_iff isOfFinOrder_ofAdd_iff
-/

#print isOfFinOrder_iff_pow_eq_one /-
@[to_additive isOfFinAddOrder_iff_nsmul_eq_zero]
theorem isOfFinOrder_iff_pow_eq_one (x : G) : IsOfFinOrder x ↔ ∃ n, 0 < n ∧ x ^ n = 1 := by
  convert Iff.rfl; simp [isPeriodicPt_mul_iff_pow_eq_one]
#align is_of_fin_order_iff_pow_eq_one isOfFinOrder_iff_pow_eq_one
#align is_of_fin_add_order_iff_nsmul_eq_zero isOfFinAddOrder_iff_nsmul_eq_zero
-/

#print not_isOfFinOrder_of_injective_pow /-
/-- See also `injective_pow_iff_not_is_of_fin_order`. -/
@[to_additive not_isOfFinAddOrder_of_injective_nsmul
      "See also\n`injective_nsmul_iff_not_is_of_fin_add_order`."]
theorem not_isOfFinOrder_of_injective_pow {x : G} (h : Injective fun n : ℕ => x ^ n) :
    ¬IsOfFinOrder x :=
  by
  simp_rw [isOfFinOrder_iff_pow_eq_one, not_exists, not_and]
  intro n hn_pos hnx
  rw [← pow_zero x] at hnx 
  rw [h hnx] at hn_pos 
  exact irrefl 0 hn_pos
#align not_is_of_fin_order_of_injective_pow not_isOfFinOrder_of_injective_pow
#align not_is_of_fin_add_order_of_injective_nsmul not_isOfFinAddOrder_of_injective_nsmul
-/

#print isOfFinOrder_iff_coe /-
/-- Elements of finite order are of finite order in submonoids.-/
@[to_additive isOfFinAddOrder_iff_coe
      "Elements of finite order are of finite order in\nsubmonoids."]
theorem isOfFinOrder_iff_coe (H : Submonoid G) (x : H) : IsOfFinOrder x ↔ IsOfFinOrder (x : G) := by
  rw [isOfFinOrder_iff_pow_eq_one, isOfFinOrder_iff_pow_eq_one]; norm_cast
#align is_of_fin_order_iff_coe isOfFinOrder_iff_coe
#align is_of_fin_add_order_iff_coe isOfFinAddOrder_iff_coe
-/

#print MonoidHom.isOfFinOrder /-
/-- The image of an element of finite order has finite order. -/
@[to_additive AddMonoidHom.isOfFinAddOrder
      "The image of an element of finite additive order has finite additive order."]
theorem MonoidHom.isOfFinOrder {H : Type v} [Monoid H] (f : G →* H) {x : G} (h : IsOfFinOrder x) :
    IsOfFinOrder <| f x :=
  (isOfFinOrder_iff_pow_eq_one _).mpr <|
    by
    rcases(isOfFinOrder_iff_pow_eq_one _).mp h with ⟨n, npos, hn⟩
    exact ⟨n, npos, by rw [← f.map_pow, hn, f.map_one]⟩
#align monoid_hom.is_of_fin_order MonoidHom.isOfFinOrder
#align add_monoid_hom.is_of_fin_order AddMonoidHom.isOfFinAddOrder
-/

#print IsOfFinOrder.apply /-
/-- If a direct product has finite order then so does each component. -/
@[to_additive "If a direct product has finite additive order then so does each component."]
theorem IsOfFinOrder.apply {η : Type _} {Gs : η → Type _} [∀ i, Monoid (Gs i)] {x : ∀ i, Gs i}
    (h : IsOfFinOrder x) : ∀ i, IsOfFinOrder (x i) :=
  by
  rcases(isOfFinOrder_iff_pow_eq_one _).mp h with ⟨n, npos, hn⟩
  exact fun _ => (isOfFinOrder_iff_pow_eq_one _).mpr ⟨n, npos, (congr_fun hn.symm _).symm⟩
#align is_of_fin_order.apply IsOfFinOrder.apply
#align is_of_fin_add_order.apply IsOfFinAddOrder.apply
-/

#print isOfFinOrder_one /-
/-- 1 is of finite order in any monoid. -/
@[to_additive "0 is of finite order in any additive monoid."]
theorem isOfFinOrder_one : IsOfFinOrder (1 : G) :=
  (isOfFinOrder_iff_pow_eq_one 1).mpr ⟨1, one_pos, one_pow 1⟩
#align is_of_fin_order_one isOfFinOrder_one
#align is_of_fin_order_zero isOfFinAddOrder_zero
-/

end IsOfFinOrder

#print orderOf /-
/-- `order_of x` is the order of the element `x`, i.e. the `n ≥ 1`, s.t. `x ^ n = 1` if it exists.
Otherwise, i.e. if `x` is of infinite order, then `order_of x` is `0` by convention.-/
@[to_additive addOrderOf
      "`add_order_of a` is the order of the element `a`, i.e. the `n ≥ 1`, s.t. `n • a = 0` if it\nexists. Otherwise, i.e. if `a` is of infinite order, then `add_order_of a` is `0` by convention."]
noncomputable def orderOf (x : G) : ℕ :=
  minimalPeriod ((· * ·) x) 1
#align order_of orderOf
#align add_order_of addOrderOf
-/

#print addOrderOf_ofMul_eq_orderOf /-
@[simp]
theorem addOrderOf_ofMul_eq_orderOf (x : G) : addOrderOf (Additive.ofMul x) = orderOf x :=
  rfl
#align add_order_of_of_mul_eq_order_of addOrderOf_ofMul_eq_orderOf
-/

#print orderOf_ofAdd_eq_addOrderOf /-
@[simp]
theorem orderOf_ofAdd_eq_addOrderOf (a : A) : orderOf (Multiplicative.ofAdd a) = addOrderOf a :=
  rfl
#align order_of_of_add_eq_add_order_of orderOf_ofAdd_eq_addOrderOf
-/

#print orderOf_pos' /-
@[to_additive addOrderOf_pos']
theorem orderOf_pos' (h : IsOfFinOrder x) : 0 < orderOf x :=
  minimalPeriod_pos_of_mem_periodicPts h
#align order_of_pos' orderOf_pos'
#align add_order_of_pos' addOrderOf_pos'
-/

#print pow_orderOf_eq_one /-
@[to_additive addOrderOf_nsmul_eq_zero]
theorem pow_orderOf_eq_one (x : G) : x ^ orderOf x = 1 :=
  by
  convert is_periodic_pt_minimal_period ((· * ·) x) _
  rw [orderOf, mul_left_iterate, mul_one]
#align pow_order_of_eq_one pow_orderOf_eq_one
#align add_order_of_nsmul_eq_zero addOrderOf_nsmul_eq_zero
-/

#print orderOf_eq_zero /-
@[to_additive addOrderOf_eq_zero]
theorem orderOf_eq_zero (h : ¬IsOfFinOrder x) : orderOf x = 0 := by
  rwa [orderOf, minimal_period, dif_neg]
#align order_of_eq_zero orderOf_eq_zero
#align add_order_of_eq_zero addOrderOf_eq_zero
-/

#print orderOf_eq_zero_iff /-
@[to_additive addOrderOf_eq_zero_iff]
theorem orderOf_eq_zero_iff : orderOf x = 0 ↔ ¬IsOfFinOrder x :=
  ⟨fun h H => (orderOf_pos' H).ne' h, orderOf_eq_zero⟩
#align order_of_eq_zero_iff orderOf_eq_zero_iff
#align add_order_of_eq_zero_iff addOrderOf_eq_zero_iff
-/

#print orderOf_eq_zero_iff' /-
@[to_additive addOrderOf_eq_zero_iff']
theorem orderOf_eq_zero_iff' : orderOf x = 0 ↔ ∀ n : ℕ, 0 < n → x ^ n ≠ 1 := by
  simp_rw [orderOf_eq_zero_iff, isOfFinOrder_iff_pow_eq_one, not_exists, not_and]
#align order_of_eq_zero_iff' orderOf_eq_zero_iff'
#align add_order_of_eq_zero_iff' addOrderOf_eq_zero_iff'
-/

#print orderOf_eq_iff /-
@[to_additive addOrderOf_eq_iff]
theorem orderOf_eq_iff {n} (h : 0 < n) :
    orderOf x = n ↔ x ^ n = 1 ∧ ∀ m, m < n → 0 < m → x ^ m ≠ 1 :=
  by
  simp_rw [Ne, ← isPeriodicPt_mul_iff_pow_eq_one, orderOf, minimal_period]
  split_ifs with h1
  · rw [find_eq_iff, exists_prop_of_true h]; push_neg; rfl
  · rw [iff_false_left h.ne]; rintro ⟨h', -⟩; exact h1 ⟨n, h, h'⟩
#align order_of_eq_iff orderOf_eq_iff
#align add_order_of_eq_iff addOrderOf_eq_iff
-/

#print orderOf_pos_iff /-
/-- A group element has finite order iff its order is positive. -/
@[to_additive addOrderOf_pos_iff
      "A group element has finite additive order iff its order is positive."]
theorem orderOf_pos_iff : 0 < orderOf x ↔ IsOfFinOrder x := by
  rwa [iff_not_comm.mp orderOf_eq_zero_iff, pos_iff_ne_zero]
#align order_of_pos_iff orderOf_pos_iff
#align add_order_of_pos_iff addOrderOf_pos_iff
-/

#print pow_ne_one_of_lt_orderOf' /-
@[to_additive nsmul_ne_zero_of_lt_addOrderOf']
theorem pow_ne_one_of_lt_orderOf' (n0 : n ≠ 0) (h : n < orderOf x) : x ^ n ≠ 1 := fun j =>
  not_isPeriodicPt_of_pos_of_lt_minimalPeriod n0 h ((isPeriodicPt_mul_iff_pow_eq_one x).mpr j)
#align pow_ne_one_of_lt_order_of' pow_ne_one_of_lt_orderOf'
#align nsmul_ne_zero_of_lt_add_order_of' nsmul_ne_zero_of_lt_addOrderOf'
-/

#print orderOf_le_of_pow_eq_one /-
@[to_additive addOrderOf_le_of_nsmul_eq_zero]
theorem orderOf_le_of_pow_eq_one (hn : 0 < n) (h : x ^ n = 1) : orderOf x ≤ n :=
  IsPeriodicPt.minimalPeriod_le hn (by rwa [isPeriodicPt_mul_iff_pow_eq_one])
#align order_of_le_of_pow_eq_one orderOf_le_of_pow_eq_one
#align add_order_of_le_of_nsmul_eq_zero addOrderOf_le_of_nsmul_eq_zero
-/

#print orderOf_one /-
@[simp, to_additive]
theorem orderOf_one : orderOf (1 : G) = 1 := by rw [orderOf, one_mul_eq_id, minimal_period_id]
#align order_of_one orderOf_one
#align order_of_zero addOrderOf_zero
-/

#print orderOf_eq_one_iff /-
@[simp, to_additive AddMonoid.addOrderOf_eq_one_iff]
theorem orderOf_eq_one_iff : orderOf x = 1 ↔ x = 1 := by
  rw [orderOf, is_fixed_point_iff_minimal_period_eq_one, is_fixed_pt, mul_one]
#align order_of_eq_one_iff orderOf_eq_one_iff
#align add_monoid.order_of_eq_one_iff AddMonoid.addOrderOf_eq_one_iff
-/

#print pow_eq_mod_orderOf /-
@[to_additive nsmul_eq_mod_addOrderOf]
theorem pow_eq_mod_orderOf {n : ℕ} : x ^ n = x ^ (n % orderOf x) :=
  calc
    x ^ n = x ^ (n % orderOf x + orderOf x * (n / orderOf x)) := by rw [Nat.mod_add_div]
    _ = x ^ (n % orderOf x) := by simp [pow_add, pow_mul, pow_orderOf_eq_one]
#align pow_eq_mod_order_of pow_eq_mod_orderOf
#align nsmul_eq_mod_add_order_of nsmul_eq_mod_addOrderOf
-/

#print orderOf_dvd_of_pow_eq_one /-
@[to_additive addOrderOf_dvd_of_nsmul_eq_zero]
theorem orderOf_dvd_of_pow_eq_one (h : x ^ n = 1) : orderOf x ∣ n :=
  IsPeriodicPt.minimalPeriod_dvd ((isPeriodicPt_mul_iff_pow_eq_one _).mpr h)
#align order_of_dvd_of_pow_eq_one orderOf_dvd_of_pow_eq_one
#align add_order_of_dvd_of_nsmul_eq_zero addOrderOf_dvd_of_nsmul_eq_zero
-/

#print orderOf_dvd_iff_pow_eq_one /-
@[to_additive addOrderOf_dvd_iff_nsmul_eq_zero]
theorem orderOf_dvd_iff_pow_eq_one {n : ℕ} : orderOf x ∣ n ↔ x ^ n = 1 :=
  ⟨fun h => by rw [pow_eq_mod_orderOf, Nat.mod_eq_zero_of_dvd h, pow_zero],
    orderOf_dvd_of_pow_eq_one⟩
#align order_of_dvd_iff_pow_eq_one orderOf_dvd_iff_pow_eq_one
#align add_order_of_dvd_iff_nsmul_eq_zero addOrderOf_dvd_iff_nsmul_eq_zero
-/

#print orderOf_pow_dvd /-
@[to_additive addOrderOf_smul_dvd]
theorem orderOf_pow_dvd (n : ℕ) : orderOf (x ^ n) ∣ orderOf x := by
  rw [orderOf_dvd_iff_pow_eq_one, pow_right_comm, pow_orderOf_eq_one, one_pow]
#align order_of_pow_dvd orderOf_pow_dvd
#align add_order_of_smul_dvd addOrderOf_smul_dvd
-/

#print orderOf_map_dvd /-
@[to_additive addOrderOf_map_dvd]
theorem orderOf_map_dvd {H : Type _} [Monoid H] (ψ : G →* H) (x : G) : orderOf (ψ x) ∣ orderOf x :=
  by apply orderOf_dvd_of_pow_eq_one; rw [← map_pow, pow_orderOf_eq_one]; apply map_one
#align order_of_map_dvd orderOf_map_dvd
#align add_order_of_map_dvd addOrderOf_map_dvd
-/

#print exists_pow_eq_self_of_coprime /-
@[to_additive]
theorem exists_pow_eq_self_of_coprime (h : n.coprime (orderOf x)) : ∃ m : ℕ, (x ^ n) ^ m = x :=
  by
  by_cases h0 : orderOf x = 0
  · rw [h0, coprime_zero_right] at h 
    exact ⟨1, by rw [h, pow_one, pow_one]⟩
  by_cases h1 : orderOf x = 1
  · exact ⟨0, by rw [order_of_eq_one_iff.mp h1, one_pow, one_pow]⟩
  obtain ⟨m, hm⟩ := exists_mul_mod_eq_one_of_coprime h (one_lt_iff_ne_zero_and_ne_one.mpr ⟨h0, h1⟩)
  exact ⟨m, by rw [← pow_mul, pow_eq_mod_orderOf, hm, pow_one]⟩
#align exists_pow_eq_self_of_coprime exists_pow_eq_self_of_coprime
#align exists_nsmul_eq_self_of_coprime exists_nsmul_eq_self_of_coprime
-/

#print orderOf_eq_of_pow_and_pow_div_prime /-
/-- If `x^n = 1`, but `x^(n/p) ≠ 1` for all prime factors `p` of `n`, then `x` has order `n` in `G`.
-/
@[to_additive addOrderOf_eq_of_nsmul_and_div_prime_nsmul
      "If `n * x = 0`, but `n/p * x ≠ 0` for\nall prime factors `p` of `n`, then `x` has order `n` in `G`."]
theorem orderOf_eq_of_pow_and_pow_div_prime (hn : 0 < n) (hx : x ^ n = 1)
    (hd : ∀ p : ℕ, p.Prime → p ∣ n → x ^ (n / p) ≠ 1) : orderOf x = n :=
  by
  -- Let `a` be `n/(order_of x)`, and show `a = 1`
  cases' exists_eq_mul_right_of_dvd (orderOf_dvd_of_pow_eq_one hx) with a ha
  suffices a = 1 by simp [this, ha]
  -- Assume `a` is not one...
  by_contra
  have a_min_fac_dvd_p_sub_one : a.min_fac ∣ n :=
    by
    obtain ⟨b, hb⟩ : ∃ b : ℕ, a = b * a.min_fac := exists_eq_mul_left_of_dvd a.min_fac_dvd
    rw [hb, ← mul_assoc] at ha 
    exact Dvd.intro_left (orderOf x * b) ha.symm
  -- Use the minimum prime factor of `a` as `p`.
  refine' hd a.min_fac (Nat.minFac_prime h) a_min_fac_dvd_p_sub_one _
  rw [← orderOf_dvd_iff_pow_eq_one, Nat.dvd_div_iff a_min_fac_dvd_p_sub_one, ha, mul_comm,
    Nat.mul_dvd_mul_iff_left (orderOf_pos' _)]
  · exact Nat.minFac_dvd a
  · rw [isOfFinOrder_iff_pow_eq_one]
    exact Exists.intro n (id ⟨hn, hx⟩)
#align order_of_eq_of_pow_and_pow_div_prime orderOf_eq_of_pow_and_pow_div_prime
#align add_order_of_eq_of_nsmul_and_div_prime_nsmul addOrderOf_eq_of_nsmul_and_div_prime_nsmul
-/

#print orderOf_eq_orderOf_iff /-
@[to_additive addOrderOf_eq_addOrderOf_iff]
theorem orderOf_eq_orderOf_iff {H : Type _} [Monoid H] {y : H} :
    orderOf x = orderOf y ↔ ∀ n : ℕ, x ^ n = 1 ↔ y ^ n = 1 := by
  simp_rw [← isPeriodicPt_mul_iff_pow_eq_one, ← minimal_period_eq_minimal_period_iff, orderOf]
#align order_of_eq_order_of_iff orderOf_eq_orderOf_iff
#align add_order_of_eq_add_order_of_iff addOrderOf_eq_addOrderOf_iff
-/

#print orderOf_injective /-
@[to_additive addOrderOf_injective]
theorem orderOf_injective {H : Type _} [Monoid H] (f : G →* H) (hf : Function.Injective f) (x : G) :
    orderOf (f x) = orderOf x := by
  simp_rw [orderOf_eq_orderOf_iff, ← f.map_pow, ← f.map_one, hf.eq_iff, iff_self_iff, forall_const]
#align order_of_injective orderOf_injective
#align add_order_of_injective addOrderOf_injective
-/

#print orderOf_submonoid /-
@[simp, norm_cast, to_additive]
theorem orderOf_submonoid {H : Submonoid G} (y : H) : orderOf (y : G) = orderOf y :=
  orderOf_injective H.Subtype Subtype.coe_injective y
#align order_of_submonoid orderOf_submonoid
#align order_of_add_submonoid addOrderOf_addSubmonoid
-/

#print orderOf_units /-
@[to_additive]
theorem orderOf_units {y : Gˣ} : orderOf (y : G) = orderOf y :=
  orderOf_injective (Units.coeHom G) Units.ext y
#align order_of_units orderOf_units
#align order_of_add_units addOrderOf_addUnits
-/

variable (x)

#print orderOf_pow' /-
@[to_additive addOrderOf_nsmul']
theorem orderOf_pow' (h : n ≠ 0) : orderOf (x ^ n) = orderOf x / gcd (orderOf x) n :=
  by
  convert minimal_period_iterate_eq_div_gcd h
  simp only [orderOf, mul_left_iterate]
#align order_of_pow' orderOf_pow'
#align add_order_of_nsmul' addOrderOf_nsmul'
-/

variable (a) (n)

#print orderOf_pow'' /-
@[to_additive addOrderOf_nsmul'']
theorem orderOf_pow'' (h : IsOfFinOrder x) : orderOf (x ^ n) = orderOf x / gcd (orderOf x) n :=
  by
  convert minimal_period_iterate_eq_div_gcd' h
  simp only [orderOf, mul_left_iterate]
#align order_of_pow'' orderOf_pow''
#align add_order_of_nsmul'' addOrderOf_nsmul''
-/

#print orderOf_pow_coprime /-
@[to_additive addOrderOf_nsmul_coprime]
theorem orderOf_pow_coprime (h : (orderOf y).coprime m) : orderOf (y ^ m) = orderOf y :=
  by
  by_cases hg : orderOf y = 0
  · rw [m.coprime_zero_left.mp (hg ▸ h), pow_one]
  · rw [orderOf_pow'' y m (hg.imp_symm orderOf_eq_zero), h.gcd_eq_one, Nat.div_one]
#align order_of_pow_coprime orderOf_pow_coprime
#align add_order_of_nsmul_coprime addOrderOf_nsmul_coprime
-/

namespace Commute

variable {x y} (h : Commute x y)

#print Commute.orderOf_mul_dvd_lcm /-
@[to_additive]
theorem orderOf_mul_dvd_lcm : orderOf (x * y) ∣ Nat.lcm (orderOf x) (orderOf y) :=
  by
  convert Function.Commute.minimalPeriod_of_comp_dvd_lcm h.function_commute_mul_left
  rw [orderOf, comp_mul_left]
#align commute.order_of_mul_dvd_lcm Commute.orderOf_mul_dvd_lcm
#align add_commute.order_of_add_dvd_lcm AddCommute.addOrderOf_add_dvd_lcm
-/

#print Commute.orderOf_dvd_lcm_mul /-
@[to_additive]
theorem orderOf_dvd_lcm_mul : orderOf y ∣ Nat.lcm (orderOf x) (orderOf (x * y)) :=
  by
  by_cases h0 : orderOf x = 0
  · rw [h0, lcm_zero_left]; apply dvd_zero
  conv_lhs =>
    rw [← one_mul y, ← pow_orderOf_eq_one x, ← succ_pred_eq_of_pos (Nat.pos_of_ne_zero h0),
      pow_succ', mul_assoc]
  exact
    (((Commute.refl x).mul_right h).pow_leftₓ _).orderOf_mul_dvd_lcm.trans
      (lcm_dvd_iff.2 ⟨trans (orderOf_pow_dvd _) (dvd_lcm_left _ _), dvd_lcm_right _ _⟩)
#align commute.order_of_dvd_lcm_mul Commute.orderOf_dvd_lcm_mul
#align add_commute.order_of_dvd_lcm_add AddCommute.addOrderOf_dvd_lcm_add
-/

#print Commute.orderOf_mul_dvd_mul_orderOf /-
@[to_additive add_order_of_add_dvd_mul_add_order_of]
theorem orderOf_mul_dvd_mul_orderOf : orderOf (x * y) ∣ orderOf x * orderOf y :=
  dvd_trans h.orderOf_mul_dvd_lcm (lcm_dvd_mul _ _)
#align commute.order_of_mul_dvd_mul_order_of Commute.orderOf_mul_dvd_mul_orderOf
#align add_commute.add_order_of_add_dvd_mul_add_order_of AddCommute.addOrderOf_add_dvd_mul_addOrderOf
-/

#print Commute.orderOf_mul_eq_mul_orderOf_of_coprime /-
@[to_additive add_order_of_add_eq_mul_add_order_of_of_coprime]
theorem orderOf_mul_eq_mul_orderOf_of_coprime (hco : (orderOf x).coprime (orderOf y)) :
    orderOf (x * y) = orderOf x * orderOf y :=
  by
  convert h.function_commute_mul_left.minimal_period_of_comp_eq_mul_of_coprime hco
  simp only [orderOf, comp_mul_left]
#align commute.order_of_mul_eq_mul_order_of_of_coprime Commute.orderOf_mul_eq_mul_orderOf_of_coprime
#align add_commute.add_order_of_add_eq_mul_add_order_of_of_coprime AddCommute.addOrderOf_add_eq_mul_addOrderOf_of_coprime
-/

#print Commute.isOfFinOrder_mul /-
/-- Commuting elements of finite order are closed under multiplication. -/
@[to_additive "Commuting elements of finite additive order are closed under addition."]
theorem isOfFinOrder_mul (hx : IsOfFinOrder x) (hy : IsOfFinOrder y) : IsOfFinOrder (x * y) :=
  orderOf_pos_iff.mp <|
    pos_of_dvd_of_pos h.orderOf_mul_dvd_mul_orderOf <| mul_pos (orderOf_pos' hx) (orderOf_pos' hy)
#align commute.is_of_fin_order_mul Commute.isOfFinOrder_mul
#align add_commute.is_of_fin_order_add AddCommute.isOfFinAddOrder_add
-/

#print Commute.orderOf_mul_eq_right_of_forall_prime_mul_dvd /-
/-- If each prime factor of `order_of x` has higher multiplicity in `order_of y`, and `x` commutes
  with `y`, then `x * y` has the same order as `y`. -/
@[to_additive add_order_of_add_eq_right_of_forall_prime_mul_dvd
      "If each prime factor of\n  `add_order_of x` has higher multiplicity in `add_order_of y`, and `x` commutes with `y`,\n  then `x + y` has the same order as `y`."]
theorem orderOf_mul_eq_right_of_forall_prime_mul_dvd (hy : IsOfFinOrder y)
    (hdvd : ∀ p : ℕ, p.Prime → p ∣ orderOf x → p * orderOf x ∣ orderOf y) :
    orderOf (x * y) = orderOf y := by
  have hoy := orderOf_pos' hy
  have hxy := dvd_of_forall_prime_mul_dvd hdvd
  apply orderOf_eq_of_pow_and_pow_div_prime hoy <;> simp only [Ne, ← orderOf_dvd_iff_pow_eq_one]
  · exact trans h.order_of_mul_dvd_lcm (lcm_dvd hxy dvd_rfl)
  refine' fun p hp hpy hd => hp.ne_one _
  rw [← Nat.dvd_one, ← mul_dvd_mul_iff_right hoy.ne', one_mul, ← dvd_div_iff hpy]
  refine' trans (order_of_dvd_lcm_mul h) (lcm_dvd ((dvd_div_iff hpy).2 _) hd)
  by_cases p ∣ orderOf x
  exacts [hdvd p hp h, (hp.coprime_iff_not_dvd.2 h).mul_dvd_of_dvd_of_dvd hpy hxy]
#align commute.order_of_mul_eq_right_of_forall_prime_mul_dvd Commute.orderOf_mul_eq_right_of_forall_prime_mul_dvd
#align add_commute.add_order_of_add_eq_right_of_forall_prime_mul_dvd AddCommute.addOrderOf_add_eq_right_of_forall_prime_mul_dvd
-/

end Commute

section PPrime

variable {a x n} {p : ℕ} [hp : Fact p.Prime]

#print orderOf_eq_prime /-
@[to_additive addOrderOf_eq_prime]
theorem orderOf_eq_prime (hg : x ^ p = 1) (hg1 : x ≠ 1) : orderOf x = p :=
  minimalPeriod_eq_prime ((isPeriodicPt_mul_iff_pow_eq_one _).mpr hg)
    (by rwa [is_fixed_pt, mul_one])
#align order_of_eq_prime orderOf_eq_prime
#align add_order_of_eq_prime addOrderOf_eq_prime
-/

#print orderOf_eq_prime_pow /-
@[to_additive addOrderOf_eq_prime_pow]
theorem orderOf_eq_prime_pow (hnot : ¬x ^ p ^ n = 1) (hfin : x ^ p ^ (n + 1) = 1) :
    orderOf x = p ^ (n + 1) := by
  apply minimal_period_eq_prime_pow <;> rwa [isPeriodicPt_mul_iff_pow_eq_one]
#align order_of_eq_prime_pow orderOf_eq_prime_pow
#align add_order_of_eq_prime_pow addOrderOf_eq_prime_pow
-/

#print exists_orderOf_eq_prime_pow_iff /-
@[to_additive exists_addOrderOf_eq_prime_pow_iff]
theorem exists_orderOf_eq_prime_pow_iff :
    (∃ k : ℕ, orderOf x = p ^ k) ↔ ∃ m : ℕ, x ^ (p : ℕ) ^ m = 1 :=
  ⟨fun ⟨k, hk⟩ => ⟨k, by rw [← hk, pow_orderOf_eq_one]⟩, fun ⟨_, hm⟩ =>
    by
    obtain ⟨k, _, hk⟩ := (Nat.dvd_prime_pow hp.elim).mp (orderOf_dvd_of_pow_eq_one hm)
    exact ⟨k, hk⟩⟩
#align exists_order_of_eq_prime_pow_iff exists_orderOf_eq_prime_pow_iff
#align exists_add_order_of_eq_prime_pow_iff exists_addOrderOf_eq_prime_pow_iff
-/

end PPrime

end MonoidAddMonoid

section CancelMonoid

variable [LeftCancelMonoid G] (x y)

#print pow_injective_of_lt_orderOf /-
@[to_additive nsmul_injective_of_lt_addOrderOf]
theorem pow_injective_of_lt_orderOf (hn : n < orderOf x) (hm : m < orderOf x) (eq : x ^ n = x ^ m) :
    n = m :=
  eq_of_lt_minimalPeriod_of_iterate_eq hn hm (by simpa only [mul_left_iterate, mul_one])
#align pow_injective_of_lt_order_of pow_injective_of_lt_orderOf
#align nsmul_injective_of_lt_add_order_of nsmul_injective_of_lt_addOrderOf
-/

#print mem_powers_iff_mem_range_order_of' /-
@[to_additive mem_multiples_iff_mem_range_addOrderOf']
theorem mem_powers_iff_mem_range_order_of' [DecidableEq G] (hx : 0 < orderOf x) :
    y ∈ Submonoid.powers x ↔ y ∈ (Finset.range (orderOf x)).image ((· ^ ·) x : ℕ → G) :=
  Finset.mem_range_iff_mem_finset_range_of_mod_eq' hx fun i => pow_eq_mod_orderOf.symm
#align mem_powers_iff_mem_range_order_of' mem_powers_iff_mem_range_order_of'
#align mem_multiples_iff_mem_range_add_order_of' mem_multiples_iff_mem_range_addOrderOf'
-/

#print pow_eq_one_iff_modEq /-
@[to_additive]
theorem pow_eq_one_iff_modEq : x ^ n = 1 ↔ n ≡ 0 [MOD orderOf x] := by
  rw [modeq_zero_iff_dvd, orderOf_dvd_iff_pow_eq_one]
#align pow_eq_one_iff_modeq pow_eq_one_iff_modEq
#align nsmul_eq_zero_iff_modeq nsmul_eq_zero_iff_modEq
-/

#print pow_eq_pow_iff_modEq /-
@[to_additive]
theorem pow_eq_pow_iff_modEq : x ^ n = x ^ m ↔ n ≡ m [MOD orderOf x] :=
  by
  wlog hmn : m ≤ n generalizing m n
  · rw [eq_comm, modeq.comm, this (le_of_not_le hmn)]
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hmn
  rw [← mul_one (x ^ m), pow_add, mul_left_cancel_iff, pow_eq_one_iff_modEq]
  exact ⟨fun h => Nat.ModEq.add_left _ h, fun h => Nat.ModEq.add_left_cancel' _ h⟩
#align pow_eq_pow_iff_modeq pow_eq_pow_iff_modEq
#align nsmul_eq_nsmul_iff_modeq nsmul_eq_nsmul_iff_modEq
-/

#print injective_pow_iff_not_isOfFinOrder /-
@[simp, to_additive injective_nsmul_iff_not_isOfFinAddOrder]
theorem injective_pow_iff_not_isOfFinOrder {x : G} :
    (Injective fun n : ℕ => x ^ n) ↔ ¬IsOfFinOrder x :=
  by
  refine' ⟨fun h => not_isOfFinOrder_of_injective_pow h, fun h n m hnm => _⟩
  rwa [pow_eq_pow_iff_modEq, order_of_eq_zero_iff.mpr h, modeq_zero_iff] at hnm 
#align injective_pow_iff_not_is_of_fin_order injective_pow_iff_not_isOfFinOrder
#align injective_nsmul_iff_not_is_of_fin_add_order injective_nsmul_iff_not_isOfFinAddOrder
-/

#print infinite_not_isOfFinOrder /-
@[to_additive infinite_not_isOfFinAddOrder]
theorem infinite_not_isOfFinOrder {x : G} (h : ¬IsOfFinOrder x) :
    {y : G | ¬IsOfFinOrder y}.Infinite :=
  by
  let s := {n | 0 < n}.image fun n : ℕ => x ^ n
  have hs : s ⊆ {y : G | ¬IsOfFinOrder y} :=
    by
    rintro - ⟨n, hn : 0 < n, rfl⟩ (contra : IsOfFinOrder (x ^ n))
    apply h
    rw [isOfFinOrder_iff_pow_eq_one] at contra ⊢
    obtain ⟨m, hm, hm'⟩ := contra
    exact ⟨n * m, mul_pos hn hm, by rwa [pow_mul]⟩
  suffices s.infinite by exact this.mono hs
  contrapose! h
  have : ¬injective fun n : ℕ => x ^ n :=
    by
    have := Set.not_injOn_infinite_finite_image (Set.Ioi_infinite 0) (set.not_infinite.mp h)
    contrapose! this
    exact Set.injOn_of_injective this _
  rwa [injective_pow_iff_not_isOfFinOrder, Classical.not_not] at this 
#align infinite_not_is_of_fin_order infinite_not_isOfFinOrder
#align infinite_not_is_of_fin_add_order infinite_not_isOfFinAddOrder
-/

end CancelMonoid

section Group

variable [Group G] [AddGroup A] {x a} {i : ℤ}

#print IsOfFinOrder.inv /-
/-- Inverses of elements of finite order have finite order. -/
@[to_additive "Inverses of elements of finite additive order have finite additive order."]
theorem IsOfFinOrder.inv {x : G} (hx : IsOfFinOrder x) : IsOfFinOrder x⁻¹ :=
  (isOfFinOrder_iff_pow_eq_one _).mpr <|
    by
    rcases(isOfFinOrder_iff_pow_eq_one x).mp hx with ⟨n, npos, hn⟩
    refine' ⟨n, npos, by simp_rw [inv_pow, hn, inv_one]⟩
#align is_of_fin_order.inv IsOfFinOrder.inv
#align is_of_fin_add_order.neg IsOfFinAddOrder.neg
-/

#print isOfFinOrder_inv_iff /-
/-- Inverses of elements of finite order have finite order. -/
@[simp, to_additive "Inverses of elements of finite additive order have finite additive order."]
theorem isOfFinOrder_inv_iff {x : G} : IsOfFinOrder x⁻¹ ↔ IsOfFinOrder x :=
  ⟨fun h => inv_inv x ▸ h.inv, IsOfFinOrder.inv⟩
#align is_of_fin_order_inv_iff isOfFinOrder_inv_iff
#align is_of_fin_order_neg_iff isOfFinAddOrder_neg_iff
-/

#print orderOf_dvd_iff_zpow_eq_one /-
@[to_additive addOrderOf_dvd_iff_zsmul_eq_zero]
theorem orderOf_dvd_iff_zpow_eq_one : (orderOf x : ℤ) ∣ i ↔ x ^ i = 1 :=
  by
  rcases Int.eq_nat_or_neg i with ⟨i, rfl | rfl⟩
  · rw [Int.coe_nat_dvd, orderOf_dvd_iff_pow_eq_one, zpow_ofNat]
  · rw [dvd_neg, Int.coe_nat_dvd, zpow_neg, inv_eq_one, zpow_ofNat, orderOf_dvd_iff_pow_eq_one]
#align order_of_dvd_iff_zpow_eq_one orderOf_dvd_iff_zpow_eq_one
#align add_order_of_dvd_iff_zsmul_eq_zero addOrderOf_dvd_iff_zsmul_eq_zero
-/

#print orderOf_inv /-
@[simp, to_additive]
theorem orderOf_inv (x : G) : orderOf x⁻¹ = orderOf x := by simp [orderOf_eq_orderOf_iff]
#align order_of_inv orderOf_inv
#align order_of_neg addOrderOf_neg
-/

#print orderOf_subgroup /-
@[simp, norm_cast, to_additive]
theorem orderOf_subgroup {H : Subgroup G} (y : H) : orderOf (y : G) = orderOf y :=
  orderOf_injective H.Subtype Subtype.coe_injective y
#align order_of_subgroup orderOf_subgroup
#align order_of_add_subgroup addOrderOf_addSubgroup
-/

#print zpow_eq_mod_orderOf /-
@[to_additive zsmul_eq_mod_addOrderOf]
theorem zpow_eq_mod_orderOf : x ^ i = x ^ (i % orderOf x) :=
  calc
    x ^ i = x ^ (i % orderOf x + orderOf x * (i / orderOf x)) := by rw [Int.emod_add_ediv]
    _ = x ^ (i % orderOf x) := by simp [zpow_add, zpow_mul, pow_orderOf_eq_one]
#align zpow_eq_mod_order_of zpow_eq_mod_orderOf
#align zsmul_eq_mod_add_order_of zsmul_eq_mod_addOrderOf
-/

#print pow_inj_iff_of_orderOf_eq_zero /-
@[to_additive nsmul_inj_iff_of_addOrderOf_eq_zero]
theorem pow_inj_iff_of_orderOf_eq_zero (h : orderOf x = 0) {n m : ℕ} : x ^ n = x ^ m ↔ n = m :=
  by
  rw [orderOf_eq_zero_iff, isOfFinOrder_iff_pow_eq_one] at h 
  push_neg at h 
  induction' n with n IH generalizing m
  · cases m
    · simp
    · simpa [eq_comm] using h m.succ m.zero_lt_succ
  · cases m
    · simpa using h n.succ n.zero_lt_succ
    · simp [pow_succ, IH]
#align pow_inj_iff_of_order_of_eq_zero pow_inj_iff_of_orderOf_eq_zero
#align nsmul_inj_iff_of_add_order_of_eq_zero nsmul_inj_iff_of_addOrderOf_eq_zero
-/

#print pow_inj_mod /-
@[to_additive]
theorem pow_inj_mod {n m : ℕ} : x ^ n = x ^ m ↔ n % orderOf x = m % orderOf x :=
  by
  cases' (orderOf x).zero_le.eq_or_lt with hx hx
  · simp [pow_inj_iff_of_orderOf_eq_zero, hx.symm]
  rw [pow_eq_mod_orderOf, @pow_eq_mod_orderOf _ _ _ m]
  exact ⟨pow_injective_of_lt_orderOf _ (Nat.mod_lt _ hx) (Nat.mod_lt _ hx), fun h => congr_arg _ h⟩
#align pow_inj_mod pow_inj_mod
#align nsmul_inj_mod nsmul_inj_mod
-/

#print zpow_pow_orderOf /-
@[simp, to_additive zsmul_smul_addOrderOf]
theorem zpow_pow_orderOf : (x ^ i) ^ orderOf x = 1 :=
  by
  by_cases h : IsOfFinOrder x
  · rw [← zpow_ofNat, ← zpow_mul, mul_comm, zpow_mul, zpow_ofNat, pow_orderOf_eq_one, one_zpow]
  · rw [orderOf_eq_zero h, pow_zero]
#align zpow_pow_order_of zpow_pow_orderOf
#align zsmul_smul_order_of zsmul_smul_addOrderOf
-/

#print IsOfFinOrder.zpow /-
@[to_additive IsOfFinAddOrder.zsmul]
theorem IsOfFinOrder.zpow (h : IsOfFinOrder x) {i : ℤ} : IsOfFinOrder (x ^ i) :=
  (isOfFinOrder_iff_pow_eq_one _).mpr ⟨orderOf x, orderOf_pos' h, zpow_pow_orderOf⟩
#align is_of_fin_order.zpow IsOfFinOrder.zpow
#align is_of_fin_add_order.zsmul IsOfFinAddOrder.zsmul
-/

#print IsOfFinOrder.of_mem_zpowers /-
@[to_additive IsOfFinAddOrder.of_mem_zmultiples]
theorem IsOfFinOrder.of_mem_zpowers (h : IsOfFinOrder x) (h' : y ∈ Subgroup.zpowers x) :
    IsOfFinOrder y := by obtain ⟨k, rfl⟩ := subgroup.mem_zpowers_iff.mp h'; exact h.zpow
#align is_of_fin_order.of_mem_zpowers IsOfFinOrder.of_mem_zpowers
#align is_of_fin_add_order.of_mem_zmultiples IsOfFinAddOrder.of_mem_zmultiples
-/

#print orderOf_dvd_of_mem_zpowers /-
@[to_additive addOrderOf_dvd_of_mem_zmultiples]
theorem orderOf_dvd_of_mem_zpowers (h : y ∈ Subgroup.zpowers x) : orderOf y ∣ orderOf x :=
  by
  obtain ⟨k, rfl⟩ := subgroup.mem_zpowers_iff.mp h
  rw [orderOf_dvd_iff_pow_eq_one]
  exact zpow_pow_orderOf
#align order_of_dvd_of_mem_zpowers orderOf_dvd_of_mem_zpowers
#align add_order_of_dvd_of_mem_zmultiples addOrderOf_dvd_of_mem_zmultiples
-/

#print smul_eq_self_of_mem_zpowers /-
theorem smul_eq_self_of_mem_zpowers {α : Type _} [MulAction G α] (hx : x ∈ Subgroup.zpowers y)
    {a : α} (hs : y • a = a) : x • a = a :=
  by
  obtain ⟨k, rfl⟩ := subgroup.mem_zpowers_iff.mp hx
  rw [← MulAction.toPerm_apply, ← MulAction.toPermHom_apply, MonoidHom.map_zpow _ y k,
    MulAction.toPermHom_apply]
  exact Function.IsFixedPt.perm_zpow hs k
#align smul_eq_self_of_mem_zpowers smul_eq_self_of_mem_zpowers
-/

#print vadd_eq_self_of_mem_zmultiples /-
theorem vadd_eq_self_of_mem_zmultiples {α G : Type _} [AddGroup G] [AddAction G α] {x y : G}
    (hx : x ∈ AddSubgroup.zmultiples y) {a : α} (hs : y +ᵥ a = a) : x +ᵥ a = a :=
  @smul_eq_self_of_mem_zpowers (Multiplicative G) _ _ _ α _ hx a hs
#align vadd_eq_self_of_mem_zmultiples vadd_eq_self_of_mem_zmultiples
-/

attribute [to_additive vadd_eq_self_of_mem_zmultiples] smul_eq_self_of_mem_zpowers

end Group

section CommMonoid

variable [CommMonoid G]

#print IsOfFinOrder.mul /-
/-- Elements of finite order are closed under multiplication. -/
@[to_additive "Elements of finite additive order are closed under addition."]
theorem IsOfFinOrder.mul (hx : IsOfFinOrder x) (hy : IsOfFinOrder y) : IsOfFinOrder (x * y) :=
  (Commute.all x y).isOfFinOrder_mul hx hy
#align is_of_fin_order.mul IsOfFinOrder.mul
#align is_of_fin_add_order.add IsOfFinAddOrder.add
-/

end CommMonoid

section FiniteMonoid

variable [Monoid G]

open scoped BigOperators

#print sum_card_orderOf_eq_card_pow_eq_one /-
@[to_additive sum_card_addOrderOf_eq_card_nsmul_eq_zero]
theorem sum_card_orderOf_eq_card_pow_eq_one [Fintype G] [DecidableEq G] (hn : n ≠ 0) :
    ∑ m in (Finset.range n.succ).filterₓ (· ∣ n),
        (Finset.univ.filterₓ fun x : G => orderOf x = m).card =
      (Finset.univ.filterₓ fun x : G => x ^ n = 1).card :=
  calc
    ∑ m in (Finset.range n.succ).filterₓ (· ∣ n),
          (Finset.univ.filterₓ fun x : G => orderOf x = m).card =
        _ :=
      (Finset.card_biUnion (by intros; apply Finset.disjoint_filter.2; cc)).symm
    _ = _ :=
      congr_arg Finset.card
        (Finset.ext
          (by
            intro x
            suffices orderOf x ≤ n ∧ orderOf x ∣ n ↔ x ^ n = 1 by simpa [Nat.lt_succ_iff]
            exact
              ⟨fun h => by
                let ⟨m, hm⟩ := h.2
                rw [hm, pow_mul, pow_orderOf_eq_one, one_pow], fun h =>
                ⟨orderOf_le_of_pow_eq_one hn.bot_lt h, orderOf_dvd_of_pow_eq_one h⟩⟩))
#align sum_card_order_of_eq_card_pow_eq_one sum_card_orderOf_eq_card_pow_eq_one
#align sum_card_add_order_of_eq_card_nsmul_eq_zero sum_card_addOrderOf_eq_card_nsmul_eq_zero
-/

end FiniteMonoid

section FiniteCancelMonoid

-- TODO: Of course everything also works for right_cancel_monoids.
variable [LeftCancelMonoid G] [AddLeftCancelMonoid A]

#print exists_pow_eq_one /-
-- TODO: Use this to show that a finite left cancellative monoid is a group.
@[to_additive]
theorem exists_pow_eq_one [Finite G] (x : G) : IsOfFinOrder x :=
  by
  have : (Set.univ : Set G).Finite := set.univ.to_finite
  contrapose! this
  exact Set.Infinite.mono (Set.subset_univ _) (infinite_not_isOfFinOrder this)
#align exists_pow_eq_one exists_pow_eq_one
#align exists_nsmul_eq_zero exists_nsmul_eq_zero
-/

#print orderOf_le_card_univ /-
@[to_additive addOrderOf_le_card_univ]
theorem orderOf_le_card_univ [Fintype G] : orderOf x ≤ Fintype.card G :=
  Finset.le_card_of_inj_on_range ((· ^ ·) x) (fun n _ => Finset.mem_univ _) fun i hi j hj =>
    pow_injective_of_lt_orderOf x hi hj
#align order_of_le_card_univ orderOf_le_card_univ
#align add_order_of_le_card_univ addOrderOf_le_card_univ
-/

#print orderOf_pos /-
/-- This is the same as `order_of_pos' but with one fewer explicit assumption since this is
  automatic in case of a finite cancellative monoid.-/
@[to_additive addOrderOf_pos
      "This is the same as `add_order_of_pos' but with one fewer explicit assumption since this is\n  automatic in case of a finite cancellative additive monoid."]
theorem orderOf_pos [Finite G] (x : G) : 0 < orderOf x :=
  orderOf_pos' (exists_pow_eq_one x)
#align order_of_pos orderOf_pos
#align add_order_of_pos addOrderOf_pos
-/

open Nat

#print orderOf_pow /-
/-- This is the same as `order_of_pow'` and `order_of_pow''` but with one assumption less which is
automatic in the case of a finite cancellative monoid.-/
@[to_additive addOrderOf_nsmul
      "This is the same as `add_order_of_nsmul'` and `add_order_of_nsmul` but with one assumption less\nwhich is automatic in the case of a finite cancellative additive monoid."]
theorem orderOf_pow [Finite G] (x : G) : orderOf (x ^ n) = orderOf x / gcd (orderOf x) n :=
  orderOf_pow'' _ _ (exists_pow_eq_one _)
#align order_of_pow orderOf_pow
#align add_order_of_nsmul addOrderOf_nsmul
-/

#print mem_powers_iff_mem_range_orderOf /-
@[to_additive mem_multiples_iff_mem_range_addOrderOf]
theorem mem_powers_iff_mem_range_orderOf [Finite G] [DecidableEq G] :
    y ∈ Submonoid.powers x ↔ y ∈ (Finset.range (orderOf x)).image ((· ^ ·) x : ℕ → G) :=
  Finset.mem_range_iff_mem_finset_range_of_mod_eq' (orderOf_pos x) fun i => pow_eq_mod_orderOf.symm
#align mem_powers_iff_mem_range_order_of mem_powers_iff_mem_range_orderOf
#align mem_multiples_iff_mem_range_add_order_of mem_multiples_iff_mem_range_addOrderOf
-/

#print decidablePowers /-
@[to_additive decidableMultiples]
noncomputable instance decidablePowers : DecidablePred (· ∈ Submonoid.powers x) :=
  Classical.decPred _
#align decidable_powers decidablePowers
#align decidable_multiples decidableMultiples
-/

#print finEquivPowers /-
/-- The equivalence between `fin (order_of x)` and `submonoid.powers x`, sending `i` to `x ^ i`."-/
@[to_additive finEquivMultiples
      "The equivalence between `fin (add_order_of a)` and\n`add_submonoid.multiples a`, sending `i` to `i • a`."]
noncomputable def finEquivPowers [Finite G] (x : G) :
    Fin (orderOf x) ≃ (Submonoid.powers x : Set G) :=
  Equiv.ofBijective (fun n => ⟨x ^ ↑n, ⟨n, rfl⟩⟩)
    ⟨fun ⟨i, hi⟩ ⟨j, hj⟩ ij =>
      Fin.ext (pow_injective_of_lt_orderOf x hi hj (Subtype.mk_eq_mk.1 ij)), fun ⟨_, i, rfl⟩ =>
      ⟨⟨i % orderOf x, mod_lt i (orderOf_pos x)⟩, Subtype.eq pow_eq_mod_orderOf.symm⟩⟩
#align fin_equiv_powers finEquivPowers
#align fin_equiv_multiples finEquivMultiples
-/

#print finEquivPowers_apply /-
@[simp, to_additive finEquivMultiples_apply]
theorem finEquivPowers_apply [Finite G] {x : G} {n : Fin (orderOf x)} :
    finEquivPowers x n = ⟨x ^ ↑n, n, rfl⟩ :=
  rfl
#align fin_equiv_powers_apply finEquivPowers_apply
#align fin_equiv_multiples_apply finEquivMultiples_apply
-/

#print finEquivPowers_symm_apply /-
@[simp, to_additive finEquivMultiples_symm_apply]
theorem finEquivPowers_symm_apply [Finite G] (x : G) (n : ℕ) {hn : ∃ m : ℕ, x ^ m = x ^ n} :
    (finEquivPowers x).symm ⟨x ^ n, hn⟩ = ⟨n % orderOf x, Nat.mod_lt _ (orderOf_pos x)⟩ := by
  rw [Equiv.symm_apply_eq, finEquivPowers_apply, Subtype.mk_eq_mk, pow_eq_mod_orderOf, Fin.val_mk]
#align fin_equiv_powers_symm_apply finEquivPowers_symm_apply
#align fin_equiv_multiples_symm_apply finEquivMultiples_symm_apply
-/

#print powersEquivPowers /-
/-- The equivalence between `submonoid.powers` of two elements `x, y` of the same order, mapping
  `x ^ i` to `y ^ i`. -/
@[to_additive multiplesEquivMultiples
      "The equivalence between `submonoid.multiples` of two elements `a, b` of the same additive order,\n  mapping `i • a` to `i • b`."]
noncomputable def powersEquivPowers [Finite G] (h : orderOf x = orderOf y) :
    (Submonoid.powers x : Set G) ≃ (Submonoid.powers y : Set G) :=
  (finEquivPowers x).symm.trans ((Fin.cast h).toEquiv.trans (finEquivPowers y))
#align powers_equiv_powers powersEquivPowers
#align multiples_equiv_multiples multiplesEquivMultiples
-/

#print powersEquivPowers_apply /-
@[simp, to_additive multiplesEquivMultiples_apply]
theorem powersEquivPowers_apply [Finite G] (h : orderOf x = orderOf y) (n : ℕ) :
    powersEquivPowers h ⟨x ^ n, n, rfl⟩ = ⟨y ^ n, n, rfl⟩ :=
  by
  rw [powersEquivPowers, Equiv.trans_apply, Equiv.trans_apply, finEquivPowers_symm_apply, ←
    Equiv.eq_symm_apply, finEquivPowers_symm_apply]
  simp [h]
#align powers_equiv_powers_apply powersEquivPowers_apply
#align multiples_equiv_multiples_apply multiplesEquivMultiples_apply
-/

#print orderOf_eq_card_powers /-
@[to_additive addOrderOf_eq_card_multiples]
theorem orderOf_eq_card_powers [Fintype G] :
    orderOf x = Fintype.card (Submonoid.powers x : Set G) :=
  (Fintype.card_fin (orderOf x)).symm.trans (Fintype.card_eq.2 ⟨finEquivPowers x⟩)
#align order_eq_card_powers orderOf_eq_card_powers
#align add_order_of_eq_card_multiples addOrderOf_eq_card_multiples
-/

end FiniteCancelMonoid

section FiniteGroup

variable [Group G] [AddGroup A]

#print exists_zpow_eq_one /-
@[to_additive]
theorem exists_zpow_eq_one [Finite G] (x : G) : ∃ (i : ℤ) (H : i ≠ 0), x ^ (i : ℤ) = 1 :=
  by
  rcases exists_pow_eq_one x with ⟨w, hw1, hw2⟩
  refine' ⟨w, int.coe_nat_ne_zero.mpr (ne_of_gt hw1), _⟩
  rw [zpow_ofNat]
  exact (isPeriodicPt_mul_iff_pow_eq_one _).mp hw2
#align exists_zpow_eq_one exists_zpow_eq_one
#align exists_zsmul_eq_zero exists_zsmul_eq_zero
-/

open Subgroup

#print mem_powers_iff_mem_zpowers /-
@[to_additive mem_multiples_iff_mem_zmultiples]
theorem mem_powers_iff_mem_zpowers [Finite G] : y ∈ Submonoid.powers x ↔ y ∈ zpowers x :=
  ⟨fun ⟨n, hn⟩ => ⟨n, by simp_all⟩, fun ⟨i, hi⟩ =>
    ⟨(i % orderOf x).natAbs, by
      rwa [← zpow_ofNat,
        Int.natAbs_of_nonneg (Int.emod_nonneg _ (Int.coe_nat_ne_zero_iff_pos.2 (orderOf_pos x))), ←
        zpow_eq_mod_orderOf]⟩⟩
#align mem_powers_iff_mem_zpowers mem_powers_iff_mem_zpowers
#align mem_multiples_iff_mem_zmultiples mem_multiples_iff_mem_zmultiples
-/

#print powers_eq_zpowers /-
@[to_additive multiples_eq_zmultiples]
theorem powers_eq_zpowers [Finite G] (x : G) : (Submonoid.powers x : Set G) = zpowers x :=
  Set.ext fun x => mem_powers_iff_mem_zpowers
#align powers_eq_zpowers powers_eq_zpowers
#align multiples_eq_zmultiples multiples_eq_zmultiples
-/

#print mem_zpowers_iff_mem_range_orderOf /-
@[to_additive mem_zmultiples_iff_mem_range_addOrderOf]
theorem mem_zpowers_iff_mem_range_orderOf [Finite G] [DecidableEq G] :
    y ∈ Subgroup.zpowers x ↔ y ∈ (Finset.range (orderOf x)).image ((· ^ ·) x : ℕ → G) := by
  rw [← mem_powers_iff_mem_zpowers, mem_powers_iff_mem_range_orderOf]
#align mem_zpowers_iff_mem_range_order_of mem_zpowers_iff_mem_range_orderOf
#align mem_zmultiples_iff_mem_range_add_order_of mem_zmultiples_iff_mem_range_addOrderOf
-/

#print decidableZpowers /-
@[to_additive decidableZmultiples]
noncomputable instance decidableZpowers : DecidablePred (· ∈ Subgroup.zpowers x) :=
  Classical.decPred _
#align decidable_zpowers decidableZpowers
#align decidable_zmultiples decidableZmultiples
-/

#print finEquivZpowers /-
/-- The equivalence between `fin (order_of x)` and `subgroup.zpowers x`, sending `i` to `x ^ i`. -/
@[to_additive finEquivZmultiples
      "The equivalence between `fin (add_order_of a)` and `subgroup.zmultiples a`, sending `i`\nto `i • a`."]
noncomputable def finEquivZpowers [Finite G] (x : G) :
    Fin (orderOf x) ≃ (Subgroup.zpowers x : Set G) :=
  (finEquivPowers x).trans (Equiv.Set.ofEq (powers_eq_zpowers x))
#align fin_equiv_zpowers finEquivZpowers
#align fin_equiv_zmultiples finEquivZmultiples
-/

#print finEquivZpowers_apply /-
@[simp, to_additive finEquivZmultiples_apply]
theorem finEquivZpowers_apply [Finite G] {n : Fin (orderOf x)} :
    finEquivZpowers x n = ⟨x ^ (n : ℕ), n, zpow_ofNat x n⟩ :=
  rfl
#align fin_equiv_zpowers_apply finEquivZpowers_apply
#align fin_equiv_zmultiples_apply finEquivZmultiples_apply
-/

#print finEquivZpowers_symm_apply /-
@[simp, to_additive finEquivZmultiples_symm_apply]
theorem finEquivZpowers_symm_apply [Finite G] (x : G) (n : ℕ) {hn : ∃ m : ℤ, x ^ m = x ^ n} :
    (finEquivZpowers x).symm ⟨x ^ n, hn⟩ = ⟨n % orderOf x, Nat.mod_lt _ (orderOf_pos x)⟩ :=
  by
  rw [finEquivZpowers, Equiv.symm_trans_apply, Equiv.Set.ofEq_symm_apply]
  exact finEquivPowers_symm_apply x n
#align fin_equiv_zpowers_symm_apply finEquivZpowers_symm_apply
#align fin_equiv_zmultiples_symm_apply finEquivZmultiples_symm_apply
-/

#print zpowersEquivZpowers /-
/-- The equivalence between `subgroup.zpowers` of two elements `x, y` of the same order, mapping
  `x ^ i` to `y ^ i`. -/
@[to_additive zmultiplesEquivZmultiples
      "The equivalence between `subgroup.zmultiples` of two elements `a, b` of the same additive order,\n  mapping `i • a` to `i • b`."]
noncomputable def zpowersEquivZpowers [Finite G] (h : orderOf x = orderOf y) :
    (Subgroup.zpowers x : Set G) ≃ (Subgroup.zpowers y : Set G) :=
  (finEquivZpowers x).symm.trans ((Fin.cast h).toEquiv.trans (finEquivZpowers y))
#align zpowers_equiv_zpowers zpowersEquivZpowers
#align zmultiples_equiv_zmultiples zmultiplesEquivZmultiples
-/

#print zpowersEquivZpowers_apply /-
@[simp, to_additive zmultiples_equiv_zmultiples_apply]
theorem zpowersEquivZpowers_apply [Finite G] (h : orderOf x = orderOf y) (n : ℕ) :
    zpowersEquivZpowers h ⟨x ^ n, n, zpow_ofNat x n⟩ = ⟨y ^ n, n, zpow_ofNat y n⟩ :=
  by
  rw [zpowersEquivZpowers, Equiv.trans_apply, Equiv.trans_apply, finEquivZpowers_symm_apply, ←
    Equiv.eq_symm_apply, finEquivZpowers_symm_apply]
  simp [h]
#align zpowers_equiv_zpowers_apply zpowersEquivZpowers_apply
#align zmultiples_equiv_zmultiples_apply zmultiples_equiv_zmultiples_apply
-/

variable [Fintype G]

#print orderOf_eq_card_zpowers /-
/-- See also `order_eq_card_zpowers'`. -/
@[to_additive addOrderOf_eq_card_zmultiples "See also `add_order_eq_card_zmultiples'`."]
theorem orderOf_eq_card_zpowers : orderOf x = Fintype.card (zpowers x) :=
  (Fintype.card_fin (orderOf x)).symm.trans (Fintype.card_eq.2 ⟨finEquivZpowers x⟩)
#align order_eq_card_zpowers orderOf_eq_card_zpowers
#align add_order_eq_card_zmultiples addOrderOf_eq_card_zmultiples
-/

open QuotientGroup

#print orderOf_dvd_card_univ /-
@[to_additive addOrderOf_dvd_card_univ]
theorem orderOf_dvd_card_univ : orderOf x ∣ Fintype.card G := by
  classical
  have ft_prod : Fintype ((G ⧸ zpowers x) × zpowers x) :=
    Fintype.ofEquiv G group_equiv_quotient_times_subgroup
  have ft_s : Fintype (zpowers x) := @Fintype.prodRight _ _ _ ft_prod _
  have ft_cosets : Fintype (G ⧸ zpowers x) :=
    @Fintype.prodLeft _ _ _ ft_prod ⟨⟨1, (zpowers x).one_mem⟩⟩
  have eq₁ : Fintype.card G = @Fintype.card _ ft_cosets * @Fintype.card _ ft_s :=
    calc
      Fintype.card G = @Fintype.card _ ft_prod :=
        @Fintype.card_congr _ _ _ ft_prod group_equiv_quotient_times_subgroup
      _ = @Fintype.card _ (@Prod.fintype _ _ ft_cosets ft_s) :=
        (congr_arg (@Fintype.card _) <| Subsingleton.elim _ _)
      _ = @Fintype.card _ ft_cosets * @Fintype.card _ ft_s := @Fintype.card_prod _ _ ft_cosets ft_s
  have eq₂ : orderOf x = @Fintype.card _ ft_s :=
    calc
      orderOf x = _ := orderOf_eq_card_zpowers
      _ = _ := congr_arg (@Fintype.card _) <| Subsingleton.elim _ _
  exact Dvd.intro (@Fintype.card (G ⧸ Subgroup.zpowers x) ft_cosets) (by rw [eq₁, eq₂, mul_comm])
#align order_of_dvd_card_univ orderOf_dvd_card_univ
#align add_order_of_dvd_card_univ addOrderOf_dvd_card_univ
-/

#print orderOf_dvd_nat_card /-
@[to_additive addOrderOf_dvd_nat_card]
theorem orderOf_dvd_nat_card {G : Type _} [Group G] {x : G} : orderOf x ∣ Nat.card G :=
  by
  cases' fintypeOrInfinite G with h h
  · simp only [Nat.card_eq_fintype_card, orderOf_dvd_card_univ]
  · simp only [card_eq_zero_of_infinite, dvd_zero]
#align order_of_dvd_nat_card orderOf_dvd_nat_card
#align add_order_of_dvd_nat_card addOrderOf_dvd_nat_card
-/

#print pow_card_eq_one' /-
@[simp, to_additive card_nsmul_eq_zero']
theorem pow_card_eq_one' {G : Type _} [Group G] {x : G} : x ^ Nat.card G = 1 :=
  orderOf_dvd_iff_pow_eq_one.mp orderOf_dvd_nat_card
#align pow_card_eq_one' pow_card_eq_one'
#align card_nsmul_eq_zero' card_nsmul_eq_zero'
-/

#print pow_card_eq_one /-
@[simp, to_additive card_nsmul_eq_zero]
theorem pow_card_eq_one : x ^ Fintype.card G = 1 := by
  rw [← Nat.card_eq_fintype_card, pow_card_eq_one']
#align pow_card_eq_one pow_card_eq_one
#align card_nsmul_eq_zero card_nsmul_eq_zero
-/

#print Subgroup.pow_index_mem /-
@[to_additive]
theorem Subgroup.pow_index_mem {G : Type _} [Group G] (H : Subgroup G) [Normal H] (g : G) :
    g ^ index H ∈ H := by rw [← eq_one_iff, QuotientGroup.mk_pow H, index, pow_card_eq_one']
#align subgroup.pow_index_mem Subgroup.pow_index_mem
#align add_subgroup.nsmul_index_mem AddSubgroup.nsmul_index_mem
-/

#print pow_eq_mod_card /-
@[to_additive]
theorem pow_eq_mod_card (n : ℕ) : x ^ n = x ^ (n % Fintype.card G) := by
  rw [pow_eq_mod_orderOf, ← Nat.mod_mod_of_dvd n orderOf_dvd_card_univ, ← pow_eq_mod_orderOf]
#align pow_eq_mod_card pow_eq_mod_card
#align nsmul_eq_mod_card nsmul_eq_mod_card
-/

#print zpow_eq_mod_card /-
@[to_additive]
theorem zpow_eq_mod_card (n : ℤ) : x ^ n = x ^ (n % Fintype.card G) := by
  rw [zpow_eq_mod_orderOf, ← Int.emod_emod_of_dvd n (Int.coe_nat_dvd.2 orderOf_dvd_card_univ), ←
    zpow_eq_mod_orderOf]
#align zpow_eq_mod_card zpow_eq_mod_card
#align zsmul_eq_mod_card zsmul_eq_mod_card
-/

#print powCoprime /-
/-- If `gcd(|G|,n)=1` then the `n`th power map is a bijection -/
@[to_additive "If `gcd(|G|,n)=1` then the smul by `n` is a bijection", simps]
noncomputable def powCoprime {G : Type _} [Group G] (h : (Nat.card G).coprime n) : G ≃ G
    where
  toFun g := g ^ n
  invFun g := g ^ (Nat.card G).gcdB n
  left_inv g := by
    have key := congr_arg ((· ^ ·) g) ((Nat.card G).gcd_eq_gcd_ab n)
    rwa [zpow_add, zpow_mul, zpow_mul, zpow_ofNat, zpow_ofNat, zpow_ofNat, h.gcd_eq_one, pow_one,
      pow_card_eq_one', one_zpow, one_mul, eq_comm] at key 
  right_inv g := by
    have key := congr_arg ((· ^ ·) g) ((Nat.card G).gcd_eq_gcd_ab n)
    rwa [zpow_add, zpow_mul, zpow_mul', zpow_ofNat, zpow_ofNat, zpow_ofNat, h.gcd_eq_one, pow_one,
      pow_card_eq_one', one_zpow, one_mul, eq_comm] at key 
#align pow_coprime powCoprime
#align nsmul_coprime nsmulCoprime
-/

#print powCoprime_one /-
@[simp, to_additive]
theorem powCoprime_one {G : Type _} [Group G] (h : (Nat.card G).coprime n) : powCoprime h 1 = 1 :=
  one_pow n
#align pow_coprime_one powCoprime_one
#align nsmul_coprime_zero nsmulCoprime_zero
-/

#print powCoprime_inv /-
@[simp, to_additive]
theorem powCoprime_inv {G : Type _} [Group G] (h : (Nat.card G).coprime n) {g : G} :
    powCoprime h g⁻¹ = (powCoprime h g)⁻¹ :=
  inv_pow g n
#align pow_coprime_inv powCoprime_inv
#align nsmul_coprime_neg nsmulCoprime_neg
-/

#print inf_eq_bot_of_coprime /-
@[to_additive add_inf_eq_bot_of_coprime]
theorem inf_eq_bot_of_coprime {G : Type _} [Group G] {H K : Subgroup G} [Fintype H] [Fintype K]
    (h : Nat.coprime (Fintype.card H) (Fintype.card K)) : H ⊓ K = ⊥ :=
  by
  refine' (H ⊓ K).eq_bot_iff_forall.mpr fun x hx => _
  rw [← orderOf_eq_one_iff, ← Nat.dvd_one, ← h.gcd_eq_one, Nat.dvd_gcd_iff]
  exact
    ⟨(congr_arg (· ∣ Fintype.card H) (orderOf_subgroup ⟨x, hx.1⟩)).mpr orderOf_dvd_card_univ,
      (congr_arg (· ∣ Fintype.card K) (orderOf_subgroup ⟨x, hx.2⟩)).mpr orderOf_dvd_card_univ⟩
#align inf_eq_bot_of_coprime inf_eq_bot_of_coprime
#align add_inf_eq_bot_of_coprime add_inf_eq_bot_of_coprime
-/

variable (a)

#print image_range_orderOf /-
/-- TODO: Generalise to `submonoid.powers`.-/
@[to_additive image_range_addOrderOf, nolint to_additive_doc]
theorem image_range_orderOf [DecidableEq G] :
    Finset.image (fun i => x ^ i) (Finset.range (orderOf x)) = (zpowers x : Set G).toFinset := by
  ext x; rw [Set.mem_toFinset, SetLike.mem_coe, mem_zpowers_iff_mem_range_orderOf]
#align image_range_order_of image_range_orderOf
#align image_range_add_order_of image_range_addOrderOf
-/

#print pow_gcd_card_eq_one_iff /-
/-- TODO: Generalise to `finite` + `cancel_monoid`. -/
@[to_additive gcd_nsmul_card_eq_zero_iff "TODO: Generalise to `finite` + `cancel_add_monoid`"]
theorem pow_gcd_card_eq_one_iff : x ^ n = 1 ↔ x ^ gcd n (Fintype.card G) = 1 :=
  ⟨fun h => pow_gcd_eq_one _ h <| pow_card_eq_one, fun h =>
    by
    let ⟨m, hm⟩ := gcd_dvd_left n (Fintype.card G)
    rw [hm, pow_mul, h, one_pow]⟩
#align pow_gcd_card_eq_one_iff pow_gcd_card_eq_one_iff
#align gcd_nsmul_card_eq_zero_iff gcd_nsmul_card_eq_zero_iff
-/

end FiniteGroup

section PowIsSubgroup

#print submonoidOfIdempotent /-
/-- A nonempty idempotent subset of a finite cancellative monoid is a submonoid -/
@[to_additive "A nonempty idempotent subset of a finite cancellative add monoid is a submonoid"]
def submonoidOfIdempotent {M : Type _} [LeftCancelMonoid M] [Fintype M] (S : Set M)
    (hS1 : S.Nonempty) (hS2 : S * S = S) : Submonoid M :=
  have pow_mem : ∀ a : M, a ∈ S → ∀ n : ℕ, a ^ (n + 1) ∈ S := fun a ha =>
    Nat.rec (by rwa [zero_add, pow_one]) fun n ih =>
      (congr_arg₂ (· ∈ ·) (pow_succ a (n + 1)).symm hS2).mp (Set.mul_mem_mul ha ih)
  { carrier := S
    one_mem' := by
      obtain ⟨a, ha⟩ := hS1
      rw [← pow_orderOf_eq_one a, ← tsub_add_cancel_of_le (succ_le_of_lt (orderOf_pos a))]
      exact pow_mem a ha (orderOf a - 1)
    mul_mem' := fun a b ha hb => (congr_arg₂ (· ∈ ·) rfl hS2).mp (Set.mul_mem_mul ha hb) }
#align submonoid_of_idempotent submonoidOfIdempotent
#align add_submonoid_of_idempotent addSubmonoidOfIdempotent
-/

#print subgroupOfIdempotent /-
/-- A nonempty idempotent subset of a finite group is a subgroup -/
@[to_additive "A nonempty idempotent subset of a finite add group is a subgroup"]
def subgroupOfIdempotent {G : Type _} [Group G] [Fintype G] (S : Set G) (hS1 : S.Nonempty)
    (hS2 : S * S = S) : Subgroup G :=
  { submonoidOfIdempotent S hS1 hS2 with
    carrier := S
    inv_mem' := fun a ha =>
      show a⁻¹ ∈ submonoidOfIdempotent S hS1 hS2
        by
        rw [← one_mul a⁻¹, ← pow_one a, ← pow_orderOf_eq_one a, ← pow_sub a (orderOf_pos a)]
        exact pow_mem ha (orderOf a - 1) }
#align subgroup_of_idempotent subgroupOfIdempotent
#align add_subgroup_of_idempotent addSubgroupOfIdempotent
-/

#print powCardSubgroup /-
/-- If `S` is a nonempty subset of a finite group `G`, then `S ^ |G|` is a subgroup -/
@[to_additive smulCardAddSubgroup
      "If `S` is a nonempty subset of a finite add group `G`,\n  then `|G| • S` is a subgroup",
  simps]
def powCardSubgroup {G : Type _} [Group G] [Fintype G] (S : Set G) (hS : S.Nonempty) : Subgroup G :=
  have one_mem : (1 : G) ∈ S ^ Fintype.card G :=
    by
    obtain ⟨a, ha⟩ := hS
    rw [← pow_card_eq_one]
    exact Set.pow_mem_pow ha (Fintype.card G)
  subgroupOfIdempotent (S ^ Fintype.card G) ⟨1, one_mem⟩
    (by
      classical!
      refine' (Set.eq_of_subset_of_card_le (Set.subset_mul_left _ one_mem) (ge_of_eq _)).symm
      simp_rw [← pow_add, Group.card_pow_eq_card_pow_card_univ S (Fintype.card G) le_rfl,
        Group.card_pow_eq_card_pow_card_univ S (Fintype.card G + Fintype.card G) le_add_self])
#align pow_card_subgroup powCardSubgroup
#align smul_card_add_subgroup smulCardAddSubgroup
-/

end PowIsSubgroup

section LinearOrderedRing

variable [LinearOrderedRing G]

#print orderOf_abs_ne_one /-
theorem orderOf_abs_ne_one (h : |x| ≠ 1) : orderOf x = 0 :=
  by
  rw [orderOf_eq_zero_iff']
  intro n hn hx
  replace hx : |x| ^ n = 1 := by simpa only [abs_one, abs_pow] using congr_arg abs hx
  cases' h.lt_or_lt with h h
  · exact ((pow_lt_one (abs_nonneg x) h hn.ne').Ne hx).elim
  · exact ((one_lt_pow h hn.ne').ne' hx).elim
#align order_of_abs_ne_one orderOf_abs_ne_one
-/

#print LinearOrderedRing.orderOf_le_two /-
theorem LinearOrderedRing.orderOf_le_two : orderOf x ≤ 2 :=
  by
  cases' ne_or_eq (|x|) 1 with h h
  · simp [orderOf_abs_ne_one h]
  rcases eq_or_eq_neg_of_abs_eq h with (rfl | rfl)
  · simp
  apply orderOf_le_of_pow_eq_one <;> norm_num
#align linear_ordered_ring.order_of_le_two LinearOrderedRing.orderOf_le_two
-/

end LinearOrderedRing

