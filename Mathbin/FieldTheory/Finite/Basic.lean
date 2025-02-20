/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Joey van Langen, Casper Putz

! This file was ported from Lean 3 source module field_theory.finite.basic
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.FieldTheory.Separable
import Mathbin.RingTheory.IntegralDomain
import Mathbin.Tactic.ApplyFun

/-!
# Finite fields

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains basic results about finite fields.
Throughout most of this file, `K` denotes a finite field
and `q` is notation for the cardinality of `K`.

See `ring_theory.integral_domain` for the fact that the unit group of a finite field is a
cyclic group, as well as the fact that every finite integral domain is a field
(`fintype.field_of_domain`).

## Main results

1. `fintype.card_units`: The unit group of a finite field is has cardinality `q - 1`.
2. `sum_pow_units`: The sum of `x^i`, where `x` ranges over the units of `K`, is
   - `q-1` if `q-1 ∣ i`
   - `0`   otherwise
3. `finite_field.card`: The cardinality `q` is a power of the characteristic of `K`.
   See `card'` for a variant.

## Notation

Throughout most of this file, `K` denotes a finite field
and `q` is notation for the cardinality of `K`.

## Implementation notes

While `fintype Kˣ` can be inferred from `fintype K` in the presence of `decidable_eq K`,
in this file we take the `fintype Kˣ` argument directly to reduce the chance of typeclass
diamonds, as `fintype` carries data.

-/


variable {K : Type _} {R : Type _}

local notation "q" => Fintype.card K

open Finset Function

open scoped BigOperators Polynomial

namespace FiniteField

section Polynomial

variable [CommRing R] [IsDomain R]

open Polynomial

#print FiniteField.card_image_polynomial_eval /-
/-- The cardinality of a field is at most `n` times the cardinality of the image of a degree `n`
  polynomial -/
theorem card_image_polynomial_eval [DecidableEq R] [Fintype R] {p : R[X]} (hp : 0 < p.degree) :
    Fintype.card R ≤ natDegree p * (univ.image fun x => eval x p).card :=
  Finset.card_le_mul_card_image _ _ fun a _ =>
    calc
      _ = (p - C a).roots.toFinset.card :=
        congr_arg card (by simp [Finset.ext_iff, mem_roots_sub_C hp])
      _ ≤ (p - C a).roots.card := (Multiset.toFinset_card_le _)
      _ ≤ _ := card_roots_sub_C' hp
#align finite_field.card_image_polynomial_eval FiniteField.card_image_polynomial_eval
-/

#print FiniteField.exists_root_sum_quadratic /-
/-- If `f` and `g` are quadratic polynomials, then the `f.eval a + g.eval b = 0` has a solution. -/
theorem exists_root_sum_quadratic [Fintype R] {f g : R[X]} (hf2 : degree f = 2) (hg2 : degree g = 2)
    (hR : Fintype.card R % 2 = 1) : ∃ a b, f.eval a + g.eval b = 0 :=
  letI := Classical.decEq R
  suffices ¬Disjoint (univ.image fun x : R => eval x f) (univ.image fun x : R => eval x (-g))
    by
    simp only [disjoint_left, mem_image] at this 
    push_neg at this 
    rcases this with ⟨x, ⟨a, _, ha⟩, ⟨b, _, hb⟩⟩
    exact ⟨a, b, by rw [ha, ← hb, eval_neg, neg_add_self]⟩
  fun hd : Disjoint _ _ =>
  lt_irrefl (2 * ((univ.image fun x : R => eval x f) ∪ univ.image fun x : R => eval x (-g)).card) <|
    calc
      2 * ((univ.image fun x : R => eval x f) ∪ univ.image fun x : R => eval x (-g)).card ≤
          2 * Fintype.card R :=
        Nat.mul_le_mul_left _ (Finset.card_le_univ _)
      _ = Fintype.card R + Fintype.card R := (two_mul _)
      _ <
          nat_degree f * (univ.image fun x : R => eval x f).card +
            nat_degree (-g) * (univ.image fun x : R => eval x (-g)).card :=
        (add_lt_add_of_lt_of_le
          (lt_of_le_of_ne (card_image_polynomial_eval (by rw [hf2] <;> exact by decide))
            (mt (congr_arg (· % 2)) (by simp [nat_degree_eq_of_degree_eq_some hf2, hR])))
          (card_image_polynomial_eval (by rw [degree_neg, hg2] <;> exact by decide)))
      _ = 2 * ((univ.image fun x : R => eval x f) ∪ univ.image fun x : R => eval x (-g)).card := by
        rw [card_disjoint_union hd] <;>
          simp [nat_degree_eq_of_degree_eq_some hf2, nat_degree_eq_of_degree_eq_some hg2, bit0,
            mul_add]
#align finite_field.exists_root_sum_quadratic FiniteField.exists_root_sum_quadratic
-/

end Polynomial

#print FiniteField.prod_univ_units_id_eq_neg_one /-
theorem prod_univ_units_id_eq_neg_one [CommRing K] [IsDomain K] [Fintype Kˣ] :
    ∏ x : Kˣ, x = (-1 : Kˣ) := by
  classical
  have : ∏ x in (@univ Kˣ _).eraseₓ (-1), x = 1 :=
    prod_involution (fun x _ => x⁻¹) (by simp)
      (fun a => by simp (config := { contextual := true }) [Units.inv_eq_self_iff])
      (fun a => by simp [@inv_eq_iff_eq_inv _ _ a]) (by simp)
  rw [← insert_erase (mem_univ (-1 : Kˣ)), prod_insert (not_mem_erase _ _), this, mul_one]
#align finite_field.prod_univ_units_id_eq_neg_one FiniteField.prod_univ_units_id_eq_neg_one
-/

section

variable [GroupWithZero K] [Fintype K]

#print FiniteField.pow_card_sub_one_eq_one /-
theorem pow_card_sub_one_eq_one (a : K) (ha : a ≠ 0) : a ^ (q - 1) = 1 :=
  calc
    a ^ (Fintype.card K - 1) = (Units.mk0 a ha ^ (Fintype.card K - 1) : Kˣ) := by
      rw [Units.val_pow_eq_pow_val, Units.val_mk0]
    _ = 1 := by
      classical
      rw [← Fintype.card_units, pow_card_eq_one]
      rfl
#align finite_field.pow_card_sub_one_eq_one FiniteField.pow_card_sub_one_eq_one
-/

#print FiniteField.pow_card /-
theorem pow_card (a : K) : a ^ q = a :=
  by
  have hp : 0 < Fintype.card K := lt_trans zero_lt_one Fintype.one_lt_card
  by_cases h : a = 0; · rw [h]; apply zero_pow hp
  rw [← Nat.succ_pred_eq_of_pos hp, pow_succ, Nat.pred_eq_sub_one, pow_card_sub_one_eq_one a h,
    mul_one]
#align finite_field.pow_card FiniteField.pow_card
-/

#print FiniteField.pow_card_pow /-
theorem pow_card_pow (n : ℕ) (a : K) : a ^ q ^ n = a :=
  by
  induction' n with n ih
  · simp
  · simp [pow_succ, pow_mul, ih, pow_card]
#align finite_field.pow_card_pow FiniteField.pow_card_pow
-/

end

variable (K) [Field K] [Fintype K]

#print FiniteField.card /-
theorem card (p : ℕ) [CharP K p] : ∃ n : ℕ+, Nat.Prime p ∧ q = p ^ (n : ℕ) :=
  by
  haveI hp : Fact p.prime := ⟨CharP.char_is_prime K p⟩
  letI : Module (ZMod p) K := { (ZMod.castHom dvd_rfl K : ZMod p →+* _).toModule with }
  obtain ⟨n, h⟩ := VectorSpace.card_fintype (ZMod p) K
  rw [ZMod.card] at h 
  refine' ⟨⟨n, _⟩, hp.1, h⟩
  apply Or.resolve_left (Nat.eq_zero_or_pos n)
  rintro rfl
  rw [pow_zero] at h 
  have : (0 : K) = 1 := by apply fintype.card_le_one_iff.mp (le_of_eq h)
  exact absurd this zero_ne_one
#align finite_field.card FiniteField.card
-/

#print FiniteField.card' /-
-- this statement doesn't use `q` because we want `K` to be an explicit parameter
theorem card' : ∃ (p : ℕ) (n : ℕ+), Nat.Prime p ∧ Fintype.card K = p ^ (n : ℕ) :=
  let ⟨p, hc⟩ := CharP.exists K
  ⟨p, @FiniteField.card K _ _ p hc⟩
#align finite_field.card' FiniteField.card'
-/

#print FiniteField.cast_card_eq_zero /-
@[simp]
theorem cast_card_eq_zero : (q : K) = 0 :=
  by
  rcases CharP.exists K with ⟨p, _char_p⟩; skip
  rcases card K p with ⟨n, hp, hn⟩
  simp only [CharP.cast_eq_zero_iff K p, hn]
  conv =>
    congr
    rw [← pow_one p]
  exact pow_dvd_pow _ n.2
#align finite_field.cast_card_eq_zero FiniteField.cast_card_eq_zero
-/

#print FiniteField.forall_pow_eq_one_iff /-
theorem forall_pow_eq_one_iff (i : ℕ) : (∀ x : Kˣ, x ^ i = 1) ↔ q - 1 ∣ i := by
  classical
  obtain ⟨x, hx⟩ := IsCyclic.exists_generator Kˣ
  rw [← Fintype.card_units, ← orderOf_eq_card_of_forall_mem_zpowers hx, orderOf_dvd_iff_pow_eq_one]
  constructor
  · intro h; apply h
  · intro h y
    simp_rw [← mem_powers_iff_mem_zpowers] at hx 
    rcases hx y with ⟨j, rfl⟩
    rw [← pow_mul, mul_comm, pow_mul, h, one_pow]
#align finite_field.forall_pow_eq_one_iff FiniteField.forall_pow_eq_one_iff
-/

#print FiniteField.sum_pow_units /-
/-- The sum of `x ^ i` as `x` ranges over the units of a finite field of cardinality `q`
is equal to `0` unless `(q - 1) ∣ i`, in which case the sum is `q - 1`. -/
theorem sum_pow_units [Fintype Kˣ] (i : ℕ) : ∑ x : Kˣ, (x ^ i : K) = if q - 1 ∣ i then -1 else 0 :=
  by
  let φ : Kˣ →* K :=
    { toFun := fun x => x ^ i
      map_one' := by rw [Units.val_one, one_pow]
      map_mul' := by intros; rw [Units.val_mul, mul_pow] }
  have : Decidable (φ = 1) := by classical infer_instance
  calc
    ∑ x : Kˣ, φ x = if φ = 1 then Fintype.card Kˣ else 0 := sum_hom_units φ
    _ = if q - 1 ∣ i then -1 else 0 := _
  suffices q - 1 ∣ i ↔ φ = 1 by
    simp only [this]
    split_ifs with h h; swap; rfl
    rw [Fintype.card_units, Nat.cast_sub, cast_card_eq_zero, Nat.cast_one, zero_sub]
    show 1 ≤ q; exact fintype.card_pos_iff.mpr ⟨0⟩
  rw [← forall_pow_eq_one_iff, MonoidHom.ext_iff]
  apply forall_congr'; intro x
  rw [Units.ext_iff, Units.val_pow_eq_pow_val, Units.val_one, MonoidHom.one_apply]
  rfl
#align finite_field.sum_pow_units FiniteField.sum_pow_units
-/

#print FiniteField.sum_pow_lt_card_sub_one /-
/-- The sum of `x ^ i` as `x` ranges over a finite field of cardinality `q`
is equal to `0` if `i < q - 1`. -/
theorem sum_pow_lt_card_sub_one (i : ℕ) (h : i < q - 1) : ∑ x : K, x ^ i = 0 :=
  by
  by_cases hi : i = 0
  · simp only [hi, nsmul_one, sum_const, pow_zero, card_univ, cast_card_eq_zero]
  classical
  have hiq : ¬q - 1 ∣ i := by contrapose! h; exact Nat.le_of_dvd (Nat.pos_of_ne_zero hi) h
  let φ : Kˣ ↪ K := ⟨coe, Units.ext⟩
  have : univ.map φ = univ \ {0} := by
    ext x
    simp only [true_and_iff, embedding.coe_fn_mk, mem_sdiff, Units.exists_iff_ne_zero, mem_univ,
      mem_map, exists_prop_of_true, mem_singleton]
  calc
    ∑ x : K, x ^ i = ∑ x in univ \ {(0 : K)}, x ^ i := by
      rw [← sum_sdiff ({0} : Finset K).subset_univ, sum_singleton, zero_pow (Nat.pos_of_ne_zero hi),
        add_zero]
    _ = ∑ x : Kˣ, x ^ i := by rw [← this, univ.sum_map φ]; rfl
    _ = 0 := by rw [sum_pow_units K i, if_neg]; exact hiq
#align finite_field.sum_pow_lt_card_sub_one FiniteField.sum_pow_lt_card_sub_one
-/

open Polynomial

section

variable (K' : Type _) [Field K'] {p n : ℕ}

#print FiniteField.X_pow_card_sub_X_natDegree_eq /-
theorem X_pow_card_sub_X_natDegree_eq (hp : 1 < p) : (X ^ p - X : K'[X]).natDegree = p :=
  by
  have h1 : (X : K'[X]).degree < (X ^ p : K'[X]).degree :=
    by
    rw [degree_X_pow, degree_X]
    exact_mod_cast hp
  rw [nat_degree_eq_of_degree_eq (degree_sub_eq_left_of_degree_lt h1), nat_degree_X_pow]
#align finite_field.X_pow_card_sub_X_nat_degree_eq FiniteField.X_pow_card_sub_X_natDegree_eq
-/

#print FiniteField.X_pow_card_pow_sub_X_natDegree_eq /-
theorem X_pow_card_pow_sub_X_natDegree_eq (hn : n ≠ 0) (hp : 1 < p) :
    (X ^ p ^ n - X : K'[X]).natDegree = p ^ n :=
  X_pow_card_sub_X_natDegree_eq K' <| Nat.one_lt_pow _ _ (Nat.pos_of_ne_zero hn) hp
#align finite_field.X_pow_card_pow_sub_X_nat_degree_eq FiniteField.X_pow_card_pow_sub_X_natDegree_eq
-/

#print FiniteField.X_pow_card_sub_X_ne_zero /-
theorem X_pow_card_sub_X_ne_zero (hp : 1 < p) : (X ^ p - X : K'[X]) ≠ 0 :=
  ne_zero_of_natDegree_gt <|
    calc
      1 < _ := hp
      _ = _ := (X_pow_card_sub_X_natDegree_eq K' hp).symm
#align finite_field.X_pow_card_sub_X_ne_zero FiniteField.X_pow_card_sub_X_ne_zero
-/

#print FiniteField.X_pow_card_pow_sub_X_ne_zero /-
theorem X_pow_card_pow_sub_X_ne_zero (hn : n ≠ 0) (hp : 1 < p) : (X ^ p ^ n - X : K'[X]) ≠ 0 :=
  X_pow_card_sub_X_ne_zero K' <| Nat.one_lt_pow _ _ (Nat.pos_of_ne_zero hn) hp
#align finite_field.X_pow_card_pow_sub_X_ne_zero FiniteField.X_pow_card_pow_sub_X_ne_zero
-/

end

variable (p : ℕ) [Fact p.Prime] [Algebra (ZMod p) K]

#print FiniteField.roots_X_pow_card_sub_X /-
theorem roots_X_pow_card_sub_X : roots (X ^ q - X : K[X]) = Finset.univ.val := by
  classical
  have aux : (X ^ q - X : K[X]) ≠ 0 := X_pow_card_sub_X_ne_zero K Fintype.one_lt_card
  have : (roots (X ^ q - X : K[X])).toFinset = Finset.univ :=
    by
    rw [eq_univ_iff_forall]
    intro x
    rw [Multiset.mem_toFinset, mem_roots aux, is_root.def, eval_sub, eval_pow, eval_X, sub_eq_zero,
      pow_card]
  rw [← this, Multiset.toFinset_val, eq_comm, Multiset.dedup_eq_self]
  apply nodup_roots
  rw [separable_def]
  convert is_coprime_one_right.neg_right using 1
  ·
    rw [derivative_sub, derivative_X, derivative_X_pow, CharP.cast_card_eq_zero K, C_0,
      MulZeroClass.zero_mul, zero_sub]
#align finite_field.roots_X_pow_card_sub_X FiniteField.roots_X_pow_card_sub_X
-/

variable {K}

#print FiniteField.frobenius_pow /-
theorem frobenius_pow {p : ℕ} [Fact p.Prime] [CharP K p] {n : ℕ} (hcard : q = p ^ n) :
    frobenius K p ^ n = 1 := by
  ext; conv_rhs => rw [RingHom.one_def, RingHom.id_apply, ← pow_card x, hcard]; clear hcard
  induction n; · simp
  rw [pow_succ, pow_succ', pow_mul, RingHom.mul_def, RingHom.comp_apply, frobenius_def, n_ih]
#align finite_field.frobenius_pow FiniteField.frobenius_pow
-/

open Polynomial

#print FiniteField.expand_card /-
theorem expand_card (f : K[X]) : expand K q f = f ^ q :=
  by
  cases' CharP.exists K with p hp
  letI := hp
  rcases FiniteField.card K p with ⟨⟨n, npos⟩, ⟨hp, hn⟩⟩
  haveI : Fact p.prime := ⟨hp⟩
  dsimp at hn 
  rw [hn, ← map_expand_pow_char, frobenius_pow hn, RingHom.one_def, map_id]
#align finite_field.expand_card FiniteField.expand_card
-/

end FiniteField

namespace ZMod

open FiniteField Polynomial

#print ZMod.sq_add_sq /-
theorem sq_add_sq (p : ℕ) [hp : Fact p.Prime] (x : ZMod p) : ∃ a b : ZMod p, a ^ 2 + b ^ 2 = x :=
  by
  cases' hp.1.eq_two_or_odd with hp2 hp_odd
  · subst p; change Fin 2 at x ; fin_cases x; · use 0; simp; · use 0, 1; simp
  let f : (ZMod p)[X] := X ^ 2
  let g : (ZMod p)[X] := X ^ 2 - C x
  obtain ⟨a, b, hab⟩ : ∃ a b, f.eval a + g.eval b = 0 :=
    @exists_root_sum_quadratic _ _ _ _ f g (degree_X_pow 2) (degree_X_pow_sub_C (by decide) _)
      (by rw [ZMod.card, hp_odd])
  refine' ⟨a, b, _⟩
  rw [← sub_eq_zero]
  simpa only [eval_C, eval_X, eval_pow, eval_sub, ← add_sub_assoc] using hab
#align zmod.sq_add_sq ZMod.sq_add_sq
-/

end ZMod

namespace CharP

#print CharP.sq_add_sq /-
theorem sq_add_sq (R : Type _) [CommRing R] [IsDomain R] (p : ℕ) [NeZero p] [CharP R p] (x : ℤ) :
    ∃ a b : ℕ, (a ^ 2 + b ^ 2 : R) = x :=
  by
  haveI := char_is_prime_of_pos R p
  obtain ⟨a, b, hab⟩ := ZMod.sq_add_sq p x
  refine' ⟨a.val, b.val, _⟩
  simpa using congr_arg (ZMod.castHom dvd_rfl R) hab
#align char_p.sq_add_sq CharP.sq_add_sq
-/

end CharP

open scoped Nat

open ZMod

#print ZMod.pow_totient /-
/-- The **Fermat-Euler totient theorem**. `nat.modeq.pow_totient` is an alternative statement
  of the same theorem. -/
@[simp]
theorem ZMod.pow_totient {n : ℕ} (x : (ZMod n)ˣ) : x ^ φ n = 1 :=
  by
  cases n
  · rw [Nat.totient_zero, pow_zero]
  · rw [← card_units_eq_totient, pow_card_eq_one]
#align zmod.pow_totient ZMod.pow_totient
-/

#print Nat.ModEq.pow_totient /-
/-- The **Fermat-Euler totient theorem**. `zmod.pow_totient` is an alternative statement
  of the same theorem. -/
theorem Nat.ModEq.pow_totient {x n : ℕ} (h : Nat.coprime x n) : x ^ φ n ≡ 1 [MOD n] :=
  by
  rw [← ZMod.eq_iff_modEq_nat]
  let x' : Units (ZMod n) := ZMod.unitOfCoprime _ h
  have := ZMod.pow_totient x'
  apply_fun (coe : Units (ZMod n) → ZMod n) at this 
  simpa only [-ZMod.pow_totient, Nat.succ_eq_add_one, Nat.cast_pow, Units.val_one, Nat.cast_one,
    coe_unit_of_coprime, Units.val_pow_eq_pow_val]
#align nat.modeq.pow_totient Nat.ModEq.pow_totient
-/

section

variable {V : Type _} [Fintype K] [DivisionRing K] [AddCommGroup V] [Module K V]

#print card_eq_pow_finrank /-
-- should this go in a namespace?
-- finite_dimensional would be natural,
-- but we don't assume it...
theorem card_eq_pow_finrank [Fintype V] : Fintype.card V = q ^ FiniteDimensional.finrank K V :=
  by
  let b := IsNoetherian.finsetBasis K V
  rw [Module.card_fintype b, ← FiniteDimensional.finrank_eq_card_basis b]
#align card_eq_pow_finrank card_eq_pow_finrank
-/

end

open FiniteField

namespace ZMod

#print ZMod.pow_card /-
/-- A variation on Fermat's little theorem. See `zmod.pow_card_sub_one_eq_one` -/
@[simp]
theorem pow_card {p : ℕ} [Fact p.Prime] (x : ZMod p) : x ^ p = x := by
  have h := FiniteField.pow_card x; rwa [ZMod.card p] at h 
#align zmod.pow_card ZMod.pow_card
-/

#print ZMod.pow_card_pow /-
@[simp]
theorem pow_card_pow {n p : ℕ} [Fact p.Prime] (x : ZMod p) : x ^ p ^ n = x :=
  by
  induction' n with n ih
  · simp
  · simp [pow_succ, pow_mul, ih, pow_card]
#align zmod.pow_card_pow ZMod.pow_card_pow
-/

#print ZMod.frobenius_zmod /-
@[simp]
theorem frobenius_zmod (p : ℕ) [Fact p.Prime] : frobenius (ZMod p) p = RingHom.id _ := by ext a;
  rw [frobenius_def, ZMod.pow_card, RingHom.id_apply]
#align zmod.frobenius_zmod ZMod.frobenius_zmod
-/

#print ZMod.card_units /-
@[simp]
theorem card_units (p : ℕ) [Fact p.Prime] : Fintype.card (ZMod p)ˣ = p - 1 := by
  rw [Fintype.card_units, card]
#align zmod.card_units ZMod.card_units
-/

#print ZMod.units_pow_card_sub_one_eq_one /-
/-- **Fermat's Little Theorem**: for every unit `a` of `zmod p`, we have `a ^ (p - 1) = 1`. -/
theorem units_pow_card_sub_one_eq_one (p : ℕ) [Fact p.Prime] (a : (ZMod p)ˣ) : a ^ (p - 1) = 1 := by
  rw [← card_units p, pow_card_eq_one]
#align zmod.units_pow_card_sub_one_eq_one ZMod.units_pow_card_sub_one_eq_one
-/

#print ZMod.pow_card_sub_one_eq_one /-
/-- **Fermat's Little Theorem**: for all nonzero `a : zmod p`, we have `a ^ (p - 1) = 1`. -/
theorem pow_card_sub_one_eq_one {p : ℕ} [Fact p.Prime] {a : ZMod p} (ha : a ≠ 0) :
    a ^ (p - 1) = 1 := by have h := pow_card_sub_one_eq_one a ha; rwa [ZMod.card p] at h 
#align zmod.pow_card_sub_one_eq_one ZMod.pow_card_sub_one_eq_one
-/

#print ZMod.orderOf_units_dvd_card_sub_one /-
theorem orderOf_units_dvd_card_sub_one {p : ℕ} [Fact p.Prime] (u : (ZMod p)ˣ) : orderOf u ∣ p - 1 :=
  orderOf_dvd_of_pow_eq_one <| units_pow_card_sub_one_eq_one _ _
#align zmod.order_of_units_dvd_card_sub_one ZMod.orderOf_units_dvd_card_sub_one
-/

#print ZMod.orderOf_dvd_card_sub_one /-
theorem orderOf_dvd_card_sub_one {p : ℕ} [Fact p.Prime] {a : ZMod p} (ha : a ≠ 0) :
    orderOf a ∣ p - 1 :=
  orderOf_dvd_of_pow_eq_one <| pow_card_sub_one_eq_one ha
#align zmod.order_of_dvd_card_sub_one ZMod.orderOf_dvd_card_sub_one
-/

open Polynomial

#print ZMod.expand_card /-
theorem expand_card {p : ℕ} [Fact p.Prime] (f : Polynomial (ZMod p)) :
    expand (ZMod p) p f = f ^ p := by have h := FiniteField.expand_card f; rwa [ZMod.card p] at h 
#align zmod.expand_card ZMod.expand_card
-/

end ZMod

#print Int.ModEq.pow_card_sub_one_eq_one /-
/-- **Fermat's Little Theorem**: for all `a : ℤ` coprime to `p`, we have
`a ^ (p - 1) ≡ 1 [ZMOD p]`. -/
theorem Int.ModEq.pow_card_sub_one_eq_one {p : ℕ} (hp : Nat.Prime p) {n : ℤ} (hpn : IsCoprime n p) :
    n ^ (p - 1) ≡ 1 [ZMOD p] := by
  haveI : Fact p.prime := ⟨hp⟩
  have : ¬(n : ZMod p) = 0 :=
    by
    rw [CharP.int_cast_eq_zero_iff _ p, ← (nat.prime_iff_prime_int.mp hp).coprime_iff_not_dvd]
    · exact hpn.symm
    exact ZMod.charP p
  simpa [← ZMod.int_cast_eq_int_cast_iff] using ZMod.pow_card_sub_one_eq_one this
#align int.modeq.pow_card_sub_one_eq_one Int.ModEq.pow_card_sub_one_eq_one
-/

section

namespace FiniteField

variable {F : Type _} [Field F]

section Finite

variable [Finite F]

#print FiniteField.isSquare_of_char_two /-
/-- In a finite field of characteristic `2`, all elements are squares. -/
theorem isSquare_of_char_two (hF : ringChar F = 2) (a : F) : IsSquare a :=
  haveI hF' : CharP F 2 := ringChar.of_eq hF
  isSquare_of_charTwo' a
#align finite_field.is_square_of_char_two FiniteField.isSquare_of_char_two
-/

#print FiniteField.exists_nonsquare /-
/-- In a finite field of odd characteristic, not every element is a square. -/
theorem exists_nonsquare (hF : ringChar F ≠ 2) : ∃ a : F, ¬IsSquare a :=
  by
  -- Idea: the squaring map on `F` is not injective, hence not surjective
  let sq : F → F := fun x => x ^ 2
  have h : ¬injective sq :=
    by
    simp only [injective, not_forall, exists_prop]
    refine' ⟨-1, 1, _, Ring.neg_one_ne_one_of_char_ne_two hF⟩
    simp only [sq, one_pow, neg_one_sq]
  rw [Finite.injective_iff_surjective] at h 
  -- sq not surjective
  simp_rw [IsSquare, ← pow_two, @eq_comm _ _ (_ ^ 2)]
  push_neg at h ⊢
  exact h
#align finite_field.exists_nonsquare FiniteField.exists_nonsquare
-/

end Finite

variable [Fintype F]

#print FiniteField.even_card_iff_char_two /-
/-- The finite field `F` has even cardinality iff it has characteristic `2`. -/
theorem even_card_iff_char_two : ringChar F = 2 ↔ Fintype.card F % 2 = 0 :=
  by
  rcases FiniteField.card F (ringChar F) with ⟨n, hp, h⟩
  rw [h, Nat.pow_mod]
  constructor
  · intro hF
    rw [hF]
    simp only [Nat.bit0_mod_two, zero_pow', Ne.def, PNat.ne_zero, not_false_iff, Nat.zero_mod]
  · rw [← Nat.even_iff, Nat.even_pow]
    rintro ⟨hev, hnz⟩
    rw [Nat.even_iff, Nat.mod_mod] at hev 
    exact (Nat.Prime.eq_two_or_odd hp).resolve_right (ne_of_eq_of_ne hev zero_ne_one)
#align finite_field.even_card_iff_char_two FiniteField.even_card_iff_char_two
-/

#print FiniteField.even_card_of_char_two /-
theorem even_card_of_char_two (hF : ringChar F = 2) : Fintype.card F % 2 = 0 :=
  even_card_iff_char_two.mp hF
#align finite_field.even_card_of_char_two FiniteField.even_card_of_char_two
-/

#print FiniteField.odd_card_of_char_ne_two /-
theorem odd_card_of_char_ne_two (hF : ringChar F ≠ 2) : Fintype.card F % 2 = 1 :=
  Nat.mod_two_ne_zero.mp (mt even_card_iff_char_two.mpr hF)
#align finite_field.odd_card_of_char_ne_two FiniteField.odd_card_of_char_ne_two
-/

#print FiniteField.pow_dichotomy /-
/-- If `F` has odd characteristic, then for nonzero `a : F`, we have that `a ^ (#F / 2) = ±1`. -/
theorem pow_dichotomy (hF : ringChar F ≠ 2) {a : F} (ha : a ≠ 0) :
    a ^ (Fintype.card F / 2) = 1 ∨ a ^ (Fintype.card F / 2) = -1 :=
  by
  have h₁ := FiniteField.pow_card_sub_one_eq_one a ha
  rw [← Nat.two_mul_odd_div_two (FiniteField.odd_card_of_char_ne_two hF), mul_comm, pow_mul,
    pow_two] at h₁ 
  exact mul_self_eq_one_iff.mp h₁
#align finite_field.pow_dichotomy FiniteField.pow_dichotomy
-/

#print FiniteField.unit_isSquare_iff /-
/-- A unit `a` of a finite field `F` of odd characteristic is a square
if and only if `a ^ (#F / 2) = 1`. -/
theorem unit_isSquare_iff (hF : ringChar F ≠ 2) (a : Fˣ) :
    IsSquare a ↔ a ^ (Fintype.card F / 2) = 1 := by
  classical
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator Fˣ
  obtain ⟨n, hn⟩ : a ∈ Submonoid.powers g := by rw [mem_powers_iff_mem_zpowers]; apply hg
  have hodd := Nat.two_mul_odd_div_two (FiniteField.odd_card_of_char_ne_two hF)
  constructor
  · rintro ⟨y, rfl⟩
    rw [← pow_two, ← pow_mul, hodd]
    apply_fun @coe Fˣ F _ using Units.ext
    · push_cast
      exact FiniteField.pow_card_sub_one_eq_one (y : F) (Units.ne_zero y)
  · subst a; intro h
    have key : 2 * (Fintype.card F / 2) ∣ n * (Fintype.card F / 2) :=
      by
      rw [← pow_mul] at h 
      rw [hodd, ← Fintype.card_units, ← orderOf_eq_card_of_forall_mem_zpowers hg]
      apply orderOf_dvd_of_pow_eq_one h
    have : 0 < Fintype.card F / 2 := Nat.div_pos Fintype.one_lt_card (by norm_num)
    obtain ⟨m, rfl⟩ := Nat.dvd_of_mul_dvd_mul_right this key
    refine' ⟨g ^ m, _⟩
    rw [mul_comm, pow_mul, pow_two]
#align finite_field.unit_is_square_iff FiniteField.unit_isSquare_iff
-/

#print FiniteField.isSquare_iff /-
/-- A non-zero `a : F` is a square if and only if `a ^ (#F / 2) = 1`. -/
theorem isSquare_iff (hF : ringChar F ≠ 2) {a : F} (ha : a ≠ 0) :
    IsSquare a ↔ a ^ (Fintype.card F / 2) = 1 :=
  by
  apply
    (iff_congr _ (by simp [Units.ext_iff])).mp (FiniteField.unit_isSquare_iff hF (Units.mk0 a ha))
  simp only [IsSquare, Units.ext_iff, Units.val_mk0, Units.val_mul]
  constructor
  · rintro ⟨y, hy⟩; exact ⟨y, hy⟩
  · rintro ⟨y, rfl⟩
    have hy : y ≠ 0 := by rintro rfl; simpa [zero_pow] using ha
    refine' ⟨Units.mk0 y hy, _⟩; simp
#align finite_field.is_square_iff FiniteField.isSquare_iff
-/

end FiniteField

end

