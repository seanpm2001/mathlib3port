/-
Copyright (c) 2019 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes

! This file was ported from Lean 3 source module number_theory.zsqrtd.gaussian_int
! leanprover-community/mathlib commit 5d0c76894ada7940957143163d7b921345474cbc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.NumberTheory.Zsqrtd.Basic
import Mathbin.Data.Complex.Basic
import Mathbin.RingTheory.PrincipalIdealDomain

/-!
# Gaussian integers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The Gaussian integers are complex integer, complex numbers whose real and imaginary parts are both
integers.

## Main definitions

The Euclidean domain structure on `ℤ[i]` is defined in this file.

The homomorphism `to_complex` into the complex numbers is also defined in this file.

## See also

See `number_theory.zsqrtd.gaussian_int` for:
* `prime_iff_mod_four_eq_three_of_nat_prime`:
  A prime natural number is prime in `ℤ[i]` if and only if it is `3` mod `4`

## Notations

This file uses the local notation `ℤ[i]` for `gaussian_int`

## Implementation notes

Gaussian integers are implemented using the more general definition `zsqrtd`, the type of integers
adjoined a square root of `d`, in this case `-1`. The definition is reducible, so that properties
and definitions about `zsqrtd` can easily be used.
-/


open Zsqrtd Complex

open scoped ComplexConjugate

#print GaussianInt /-
/-- The Gaussian integers, defined as `ℤ√(-1)`. -/
@[reducible]
def GaussianInt : Type :=
  Zsqrtd (-1)
#align gaussian_int GaussianInt
-/

local notation "ℤ[i]" => GaussianInt

namespace GaussianInt

instance : Repr ℤ[i] :=
  ⟨fun x => "⟨" ++ repr x.re ++ ", " ++ repr x.im ++ "⟩"⟩

instance : CommRing ℤ[i] :=
  Zsqrtd.commRing

section

attribute [-instance] Complex.instField

#print GaussianInt.toComplex /-
-- Avoid making things noncomputable unnecessarily.
/-- The embedding of the Gaussian integers into the complex numbers, as a ring homomorphism. -/
def toComplex : ℤ[i] →+* ℂ :=
  Zsqrtd.lift ⟨I, by simp⟩
#align gaussian_int.to_complex GaussianInt.toComplex
-/

end

instance : Coe ℤ[i] ℂ :=
  ⟨toComplex⟩

#print GaussianInt.toComplex_def /-
theorem toComplex_def (x : ℤ[i]) : (x : ℂ) = x.re + x.im * I :=
  rfl
#align gaussian_int.to_complex_def GaussianInt.toComplex_def
-/

#print GaussianInt.toComplex_def' /-
theorem toComplex_def' (x y : ℤ) : ((⟨x, y⟩ : ℤ[i]) : ℂ) = x + y * I := by simp [to_complex_def]
#align gaussian_int.to_complex_def' GaussianInt.toComplex_def'
-/

#print GaussianInt.toComplex_def₂ /-
theorem toComplex_def₂ (x : ℤ[i]) : (x : ℂ) = ⟨x.re, x.im⟩ := by
  apply Complex.ext <;> simp [to_complex_def]
#align gaussian_int.to_complex_def₂ GaussianInt.toComplex_def₂
-/

#print GaussianInt.to_real_re /-
@[simp]
theorem to_real_re (x : ℤ[i]) : ((x.re : ℤ) : ℝ) = (x : ℂ).re := by simp [to_complex_def]
#align gaussian_int.to_real_re GaussianInt.to_real_re
-/

#print GaussianInt.to_real_im /-
@[simp]
theorem to_real_im (x : ℤ[i]) : ((x.im : ℤ) : ℝ) = (x : ℂ).im := by simp [to_complex_def]
#align gaussian_int.to_real_im GaussianInt.to_real_im
-/

#print GaussianInt.toComplex_re /-
@[simp]
theorem toComplex_re (x y : ℤ) : ((⟨x, y⟩ : ℤ[i]) : ℂ).re = x := by simp [to_complex_def]
#align gaussian_int.to_complex_re GaussianInt.toComplex_re
-/

#print GaussianInt.toComplex_im /-
@[simp]
theorem toComplex_im (x y : ℤ) : ((⟨x, y⟩ : ℤ[i]) : ℂ).im = y := by simp [to_complex_def]
#align gaussian_int.to_complex_im GaussianInt.toComplex_im
-/

#print GaussianInt.toComplex_add /-
@[simp]
theorem toComplex_add (x y : ℤ[i]) : ((x + y : ℤ[i]) : ℂ) = x + y :=
  toComplex.map_add _ _
#align gaussian_int.to_complex_add GaussianInt.toComplex_add
-/

#print GaussianInt.toComplex_mul /-
@[simp]
theorem toComplex_mul (x y : ℤ[i]) : ((x * y : ℤ[i]) : ℂ) = x * y :=
  toComplex.map_mul _ _
#align gaussian_int.to_complex_mul GaussianInt.toComplex_mul
-/

#print GaussianInt.toComplex_one /-
@[simp]
theorem toComplex_one : ((1 : ℤ[i]) : ℂ) = 1 :=
  toComplex.map_one
#align gaussian_int.to_complex_one GaussianInt.toComplex_one
-/

#print GaussianInt.toComplex_zero /-
@[simp]
theorem toComplex_zero : ((0 : ℤ[i]) : ℂ) = 0 :=
  toComplex.map_zero
#align gaussian_int.to_complex_zero GaussianInt.toComplex_zero
-/

#print GaussianInt.toComplex_neg /-
@[simp]
theorem toComplex_neg (x : ℤ[i]) : ((-x : ℤ[i]) : ℂ) = -x :=
  toComplex.map_neg _
#align gaussian_int.to_complex_neg GaussianInt.toComplex_neg
-/

#print GaussianInt.toComplex_sub /-
@[simp]
theorem toComplex_sub (x y : ℤ[i]) : ((x - y : ℤ[i]) : ℂ) = x - y :=
  toComplex.map_sub _ _
#align gaussian_int.to_complex_sub GaussianInt.toComplex_sub
-/

#print GaussianInt.toComplex_star /-
@[simp]
theorem toComplex_star (x : ℤ[i]) : ((star x : ℤ[i]) : ℂ) = conj (x : ℂ) :=
  by
  rw [to_complex_def₂, to_complex_def₂]
  exact congr_arg₂ _ rfl (Int.cast_neg _)
#align gaussian_int.to_complex_star GaussianInt.toComplex_star
-/

#print GaussianInt.toComplex_inj /-
@[simp]
theorem toComplex_inj {x y : ℤ[i]} : (x : ℂ) = y ↔ x = y := by
  cases x <;> cases y <;> simp [to_complex_def₂]
#align gaussian_int.to_complex_inj GaussianInt.toComplex_inj
-/

#print GaussianInt.toComplex_eq_zero /-
@[simp]
theorem toComplex_eq_zero {x : ℤ[i]} : (x : ℂ) = 0 ↔ x = 0 := by
  rw [← to_complex_zero, to_complex_inj]
#align gaussian_int.to_complex_eq_zero GaussianInt.toComplex_eq_zero
-/

#print GaussianInt.int_cast_real_norm /-
@[simp]
theorem int_cast_real_norm (x : ℤ[i]) : (x.norm : ℝ) = (x : ℂ).normSq := by
  rw [Zsqrtd.norm, norm_sq] <;> simp
#align gaussian_int.nat_cast_real_norm GaussianInt.int_cast_real_norm
-/

#print GaussianInt.int_cast_complex_norm /-
@[simp]
theorem int_cast_complex_norm (x : ℤ[i]) : (x.norm : ℂ) = (x : ℂ).normSq := by
  cases x <;> rw [Zsqrtd.norm, norm_sq] <;> simp
#align gaussian_int.nat_cast_complex_norm GaussianInt.int_cast_complex_norm
-/

#print GaussianInt.norm_nonneg /-
theorem norm_nonneg (x : ℤ[i]) : 0 ≤ norm x :=
  norm_nonneg (by norm_num) _
#align gaussian_int.norm_nonneg GaussianInt.norm_nonneg
-/

#print GaussianInt.norm_eq_zero /-
@[simp]
theorem norm_eq_zero {x : ℤ[i]} : norm x = 0 ↔ x = 0 := by rw [← @Int.cast_inj ℝ _ _ _] <;> simp
#align gaussian_int.norm_eq_zero GaussianInt.norm_eq_zero
-/

#print GaussianInt.norm_pos /-
theorem norm_pos {x : ℤ[i]} : 0 < norm x ↔ x ≠ 0 := by
  rw [lt_iff_le_and_ne, Ne.def, eq_comm, norm_eq_zero] <;> simp [norm_nonneg]
#align gaussian_int.norm_pos GaussianInt.norm_pos
-/

#print GaussianInt.abs_coe_nat_norm /-
theorem abs_coe_nat_norm (x : ℤ[i]) : (x.norm.natAbs : ℤ) = x.norm :=
  Int.natAbs_of_nonneg (norm_nonneg _)
#align gaussian_int.abs_coe_nat_norm GaussianInt.abs_coe_nat_norm
-/

#print GaussianInt.nat_cast_natAbs_norm /-
@[simp]
theorem nat_cast_natAbs_norm {α : Type _} [Ring α] (x : ℤ[i]) : (x.norm.natAbs : α) = x.norm := by
  rw [← Int.cast_ofNat, abs_coe_nat_norm]
#align gaussian_int.nat_cast_nat_abs_norm GaussianInt.nat_cast_natAbs_norm
-/

#print GaussianInt.natAbs_norm_eq /-
theorem natAbs_norm_eq (x : ℤ[i]) :
    x.norm.natAbs = x.re.natAbs * x.re.natAbs + x.im.natAbs * x.im.natAbs :=
  Int.ofNat.inj <| by simp; simp [Zsqrtd.norm]
#align gaussian_int.nat_abs_norm_eq GaussianInt.natAbs_norm_eq
-/

instance : Div ℤ[i] :=
  ⟨fun x y =>
    let n := (norm y : ℚ)⁻¹
    let c := star y
    ⟨round ((x * c).re * n : ℚ), round ((x * c).im * n : ℚ)⟩⟩

#print GaussianInt.div_def /-
theorem div_def (x y : ℤ[i]) :
    x / y = ⟨round ((x * star y).re / norm y : ℚ), round ((x * star y).im / norm y : ℚ)⟩ :=
  show Zsqrtd.mk _ _ = _ by simp [div_eq_mul_inv]
#align gaussian_int.div_def GaussianInt.div_def
-/

#print GaussianInt.toComplex_div_re /-
theorem toComplex_div_re (x y : ℤ[i]) : ((x / y : ℤ[i]) : ℂ).re = round (x / y : ℂ).re := by
  rw [div_def, ← @Rat.round_cast ℝ _ _] <;>
    simp [-Rat.round_cast, mul_assoc, div_eq_mul_inv, mul_add, add_mul]
#align gaussian_int.to_complex_div_re GaussianInt.toComplex_div_re
-/

#print GaussianInt.toComplex_div_im /-
theorem toComplex_div_im (x y : ℤ[i]) : ((x / y : ℤ[i]) : ℂ).im = round (x / y : ℂ).im := by
  rw [div_def, ← @Rat.round_cast ℝ _ _, ← @Rat.round_cast ℝ _ _] <;>
    simp [-Rat.round_cast, mul_assoc, div_eq_mul_inv, mul_add, add_mul]
#align gaussian_int.to_complex_div_im GaussianInt.toComplex_div_im
-/

#print GaussianInt.normSq_le_normSq_of_re_le_of_im_le /-
theorem normSq_le_normSq_of_re_le_of_im_le {x y : ℂ} (hre : |x.re| ≤ |y.re|)
    (him : |x.im| ≤ |y.im|) : x.normSq ≤ y.normSq := by
  rw [norm_sq_apply, norm_sq_apply, ← _root_.abs_mul_self, _root_.abs_mul, ←
      _root_.abs_mul_self y.re, _root_.abs_mul y.re, ← _root_.abs_mul_self x.im,
      _root_.abs_mul x.im, ← _root_.abs_mul_self y.im, _root_.abs_mul y.im] <;>
    exact
      add_le_add (mul_self_le_mul_self (abs_nonneg _) hre) (mul_self_le_mul_self (abs_nonneg _) him)
#align gaussian_int.norm_sq_le_norm_sq_of_re_le_of_im_le GaussianInt.normSq_le_normSq_of_re_le_of_im_le
-/

#print GaussianInt.normSq_div_sub_div_lt_one /-
theorem normSq_div_sub_div_lt_one (x y : ℤ[i]) : ((x / y : ℂ) - ((x / y : ℤ[i]) : ℂ)).normSq < 1 :=
  calc
    ((x / y : ℂ) - ((x / y : ℤ[i]) : ℂ)).normSq =
        ((x / y : ℂ).re - ((x / y : ℤ[i]) : ℂ).re + ((x / y : ℂ).im - ((x / y : ℤ[i]) : ℂ).im) * I :
            ℂ).normSq :=
      congr_arg _ <| by apply Complex.ext <;> simp
    _ ≤ (1 / 2 + 1 / 2 * I).normSq :=
      (have : |(2⁻¹ : ℝ)| = 2⁻¹ := abs_of_nonneg (by norm_num)
      normSq_le_normSq_of_re_le_of_im_le
        (by
          rw [to_complex_div_re] <;> simp [norm_sq, this] <;>
            simpa using abs_sub_round (x / y : ℂ).re)
        (by
          rw [to_complex_div_im] <;> simp [norm_sq, this] <;>
            simpa using abs_sub_round (x / y : ℂ).im))
    _ < 1 := by simp [norm_sq] <;> norm_num
#align gaussian_int.norm_sq_div_sub_div_lt_one GaussianInt.normSq_div_sub_div_lt_one
-/

instance : Mod ℤ[i] :=
  ⟨fun x y => x - y * (x / y)⟩

#print GaussianInt.mod_def /-
theorem mod_def (x y : ℤ[i]) : x % y = x - y * (x / y) :=
  rfl
#align gaussian_int.mod_def GaussianInt.mod_def
-/

#print GaussianInt.norm_mod_lt /-
theorem norm_mod_lt (x : ℤ[i]) {y : ℤ[i]} (hy : y ≠ 0) : (x % y).norm < y.norm :=
  have : (y : ℂ) ≠ 0 := by rwa [Ne.def, ← to_complex_zero, to_complex_inj]
  (@Int.cast_lt ℝ _ _ _ _).1 <|
    calc
      ↑(Zsqrtd.norm (x % y)) = (x - y * (x / y : ℤ[i]) : ℂ).normSq := by simp [mod_def]
      _ = (y : ℂ).normSq * (x / y - (x / y : ℤ[i]) : ℂ).normSq := by
        rw [← norm_sq_mul, mul_sub, mul_div_cancel' _ this]
      _ < (y : ℂ).normSq * 1 :=
        (mul_lt_mul_of_pos_left (normSq_div_sub_div_lt_one _ _) (normSq_pos.2 this))
      _ = Zsqrtd.norm y := by simp
#align gaussian_int.norm_mod_lt GaussianInt.norm_mod_lt
-/

#print GaussianInt.natAbs_norm_mod_lt /-
theorem natAbs_norm_mod_lt (x : ℤ[i]) {y : ℤ[i]} (hy : y ≠ 0) :
    (x % y).norm.natAbs < y.norm.natAbs :=
  Int.ofNat_lt.1 (by simp [-Int.ofNat_lt, norm_mod_lt x hy])
#align gaussian_int.nat_abs_norm_mod_lt GaussianInt.natAbs_norm_mod_lt
-/

#print GaussianInt.norm_le_norm_mul_left /-
theorem norm_le_norm_mul_left (x : ℤ[i]) {y : ℤ[i]} (hy : y ≠ 0) :
    (norm x).natAbs ≤ (norm (x * y)).natAbs := by
  rw [Zsqrtd.norm_mul, Int.natAbs_mul] <;>
    exact
      le_mul_of_one_le_right (Nat.zero_le _)
        (Int.ofNat_le.1 (by rw [abs_coe_nat_norm] <;> exact Int.add_one_le_of_lt (norm_pos.2 hy)))
#align gaussian_int.norm_le_norm_mul_left GaussianInt.norm_le_norm_mul_left
-/

instance : Nontrivial ℤ[i] :=
  ⟨⟨0, 1, by decide⟩⟩

instance : EuclideanDomain ℤ[i] :=
  { GaussianInt.instCommRing,
    GaussianInt.instNontrivial with
    Quotient := (· / ·)
    remainder := (· % ·)
    quotient_zero := by simp [div_def]; rfl
    quotient_mul_add_remainder_eq := fun _ _ => by simp [mod_def]
    R := _
    r_wellFounded := measure_wf (Int.natAbs ∘ norm)
    remainder_lt := natAbs_norm_mod_lt
    mul_left_not_lt := fun a b hb0 => not_lt_of_ge <| norm_le_norm_mul_left a hb0 }

open PrincipalIdealRing

#print GaussianInt.sq_add_sq_of_nat_prime_of_not_irreducible /-
theorem sq_add_sq_of_nat_prime_of_not_irreducible (p : ℕ) [hp : Fact p.Prime]
    (hpi : ¬Irreducible (p : ℤ[i])) : ∃ a b, a ^ 2 + b ^ 2 = p :=
  have hpu : ¬IsUnit (p : ℤ[i]) :=
    mt norm_eq_one_iff.2 <| by
      rw [norm_nat_cast, Int.natAbs_mul, mul_eq_one] <;>
        exact fun h => (ne_of_lt hp.1.one_lt).symm h.1
  have hab : ∃ a b, (p : ℤ[i]) = a * b ∧ ¬IsUnit a ∧ ¬IsUnit b := by
    simpa [irreducible_iff, hpu, not_forall, not_or] using hpi
  let ⟨a, b, hpab, hau, hbu⟩ := hab
  have hnap : (norm a).natAbs = p :=
    ((hp.1.mul_eq_prime_sq_iff (mt norm_eq_one_iff.1 hau) (mt norm_eq_one_iff.1 hbu)).1 <| by
        rw [← Int.coe_nat_inj', Int.coe_nat_pow, sq, ← @norm_nat_cast (-1), hpab] <;> simp).1
  ⟨a.re.natAbs, a.im.natAbs, by simpa [nat_abs_norm_eq, sq] using hnap⟩
#align gaussian_int.sq_add_sq_of_nat_prime_of_not_irreducible GaussianInt.sq_add_sq_of_nat_prime_of_not_irreducible
-/

end GaussianInt

