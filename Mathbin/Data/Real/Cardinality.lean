/-
Copyright (c) 2019 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn

! This file was ported from Lean 3 source module data.real.cardinality
! leanprover-community/mathlib commit 8eb9c42d4d34c77f6ee84ea766ae4070233a973c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecificLimits.Basic
import Mathbin.Data.Rat.Denumerable
import Mathbin.Data.Set.Pointwise.Interval
import Mathbin.SetTheory.Cardinal.Continuum

/-!
# The cardinality of the reals

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file shows that the real numbers have cardinality continuum, i.e. `#ℝ = 𝔠`.

We show that `#ℝ ≤ 𝔠` by noting that every real number is determined by a Cauchy-sequence of the
form `ℕ → ℚ`, which has cardinality `𝔠`. To show that `#ℝ ≥ 𝔠` we define an injection from
`{0, 1} ^ ℕ` to `ℝ` with `f ↦ Σ n, f n * (1 / 3) ^ n`.

We conclude that all intervals with distinct endpoints have cardinality continuum.

## Main definitions

* `cardinal.cantor_function` is the function that sends `f` in `{0, 1} ^ ℕ` to `ℝ` by
  `f ↦ Σ' n, f n * (1 / 3) ^ n`

## Main statements

* `cardinal.mk_real : #ℝ = 𝔠`: the reals have cardinality continuum.
* `cardinal.not_countable_real`: the universal set of real numbers is not countable.
  We can use this same proof to show that all the other sets in this file are not countable.
* 8 lemmas of the form `mk_Ixy_real` for `x,y ∈ {i,o,c}` state that intervals on the reals
  have cardinality continuum.

## Notation

* `𝔠` : notation for `cardinal.continuum` in locale `cardinal`, defined in `set_theory.continuum`.

## Tags
continuum, cardinality, reals, cardinality of the reals
-/


open Nat Set

open scoped Cardinal

noncomputable section

namespace Cardinal

variable {c : ℝ} {f g : ℕ → Bool} {n : ℕ}

#print Cardinal.cantorFunctionAux /-
/-- The body of the sum in `cantor_function`.
`cantor_function_aux c f n = c ^ n` if `f n = tt`;
`cantor_function_aux c f n = 0` if `f n = ff`. -/
def cantorFunctionAux (c : ℝ) (f : ℕ → Bool) (n : ℕ) : ℝ :=
  cond (f n) (c ^ n) 0
#align cardinal.cantor_function_aux Cardinal.cantorFunctionAux
-/

#print Cardinal.cantorFunctionAux_true /-
@[simp]
theorem cantorFunctionAux_true (h : f n = true) : cantorFunctionAux c f n = c ^ n := by
  simp [cantor_function_aux, h]
#align cardinal.cantor_function_aux_tt Cardinal.cantorFunctionAux_true
-/

#print Cardinal.cantorFunctionAux_false /-
@[simp]
theorem cantorFunctionAux_false (h : f n = false) : cantorFunctionAux c f n = 0 := by
  simp [cantor_function_aux, h]
#align cardinal.cantor_function_aux_ff Cardinal.cantorFunctionAux_false
-/

#print Cardinal.cantorFunctionAux_nonneg /-
theorem cantorFunctionAux_nonneg (h : 0 ≤ c) : 0 ≤ cantorFunctionAux c f n := by
  cases h' : f n <;> simp [h']; apply pow_nonneg h
#align cardinal.cantor_function_aux_nonneg Cardinal.cantorFunctionAux_nonneg
-/

#print Cardinal.cantorFunctionAux_eq /-
theorem cantorFunctionAux_eq (h : f n = g n) : cantorFunctionAux c f n = cantorFunctionAux c g n :=
  by simp [cantor_function_aux, h]
#align cardinal.cantor_function_aux_eq Cardinal.cantorFunctionAux_eq
-/

#print Cardinal.cantorFunctionAux_zero /-
theorem cantorFunctionAux_zero (f : ℕ → Bool) : cantorFunctionAux c f 0 = cond (f 0) 1 0 := by
  cases h : f 0 <;> simp [h]
#align cardinal.cantor_function_aux_zero Cardinal.cantorFunctionAux_zero
-/

#print Cardinal.cantorFunctionAux_succ /-
theorem cantorFunctionAux_succ (f : ℕ → Bool) :
    (fun n => cantorFunctionAux c f (n + 1)) = fun n =>
      c * cantorFunctionAux c (fun n => f (n + 1)) n :=
  by ext n; cases h : f (n + 1) <;> simp [h, pow_succ]
#align cardinal.cantor_function_aux_succ Cardinal.cantorFunctionAux_succ
-/

#print Cardinal.summable_cantor_function /-
theorem summable_cantor_function (f : ℕ → Bool) (h1 : 0 ≤ c) (h2 : c < 1) :
    Summable (cantorFunctionAux c f) :=
  by
  apply (summable_geometric_of_lt_1 h1 h2).summable_of_eq_zero_or_self
  intro n; cases h : f n <;> simp [h]
#align cardinal.summable_cantor_function Cardinal.summable_cantor_function
-/

#print Cardinal.cantorFunction /-
/-- `cantor_function c (f : ℕ → bool)` is `Σ n, f n * c ^ n`, where `tt` is interpreted as `1` and
`ff` is interpreted as `0`. It is implemented using `cantor_function_aux`. -/
def cantorFunction (c : ℝ) (f : ℕ → Bool) : ℝ :=
  ∑' n, cantorFunctionAux c f n
#align cardinal.cantor_function Cardinal.cantorFunction
-/

#print Cardinal.cantorFunction_le /-
theorem cantorFunction_le (h1 : 0 ≤ c) (h2 : c < 1) (h3 : ∀ n, f n → g n) :
    cantorFunction c f ≤ cantorFunction c g :=
  by
  apply tsum_le_tsum _ (summable_cantor_function f h1 h2) (summable_cantor_function g h1 h2)
  intro n; cases h : f n; simp [h, cantor_function_aux_nonneg h1]
  replace h3 : g n = tt := h3 n h; simp [h, h3]
#align cardinal.cantor_function_le Cardinal.cantorFunction_le
-/

#print Cardinal.cantorFunction_succ /-
theorem cantorFunction_succ (f : ℕ → Bool) (h1 : 0 ≤ c) (h2 : c < 1) :
    cantorFunction c f = cond (f 0) 1 0 + c * cantorFunction c fun n => f (n + 1) :=
  by
  rw [cantor_function, tsum_eq_zero_add (summable_cantor_function f h1 h2)]
  rw [cantor_function_aux_succ, tsum_mul_left, cantor_function_aux, pow_zero]
  rfl
#align cardinal.cantor_function_succ Cardinal.cantorFunction_succ
-/

#print Cardinal.increasing_cantorFunction /-
/-- `cantor_function c` is strictly increasing with if `0 < c < 1/2`, if we endow `ℕ → bool` with a
lexicographic order. The lexicographic order doesn't exist for these infinitary products, so we
explicitly write out what it means. -/
theorem increasing_cantorFunction (h1 : 0 < c) (h2 : c < 1 / 2) {n : ℕ} {f g : ℕ → Bool}
    (hn : ∀ k < n, f k = g k) (fn : f n = false) (gn : g n = true) :
    cantorFunction c f < cantorFunction c g :=
  by
  have h3 : c < 1 := by apply h2.trans; norm_num
  induction' n with n ih generalizing f g
  · let f_max : ℕ → Bool := fun n => Nat.rec ff (fun _ _ => tt) n
    have hf_max : ∀ n, f n → f_max n := by intro n hn; cases n; rw [fn] at hn ; contradiction;
      apply rfl
    let g_min : ℕ → Bool := fun n => Nat.rec tt (fun _ _ => ff) n
    have hg_min : ∀ n, g_min n → g n := by intro n hn; cases n; rw [gn]; apply rfl; contradiction
    apply (cantor_function_le (le_of_lt h1) h3 hf_max).trans_lt
    refine' lt_of_lt_of_le _ (cantor_function_le (le_of_lt h1) h3 hg_min)
    have : c / (1 - c) < 1 := by
      rw [div_lt_one, lt_sub_iff_add_lt]
      · convert add_lt_add h2 h2; norm_num
      rwa [sub_pos]
    convert this
    · rw [cantor_function_succ _ (le_of_lt h1) h3, div_eq_mul_inv, ←
        tsum_geometric_of_lt_1 (le_of_lt h1) h3]
      apply zero_add
    · refine' (tsum_eq_single 0 _).trans _
      · intro n hn; cases n; contradiction; rfl
      · exact cantor_function_aux_zero _
  rw [cantor_function_succ f (le_of_lt h1) h3, cantor_function_succ g (le_of_lt h1) h3]
  rw [hn 0 <| zero_lt_succ n]
  apply add_lt_add_left; rw [mul_lt_mul_left h1];
  exact ih (fun k hk => hn _ <| Nat.succ_lt_succ hk) fn gn
#align cardinal.increasing_cantor_function Cardinal.increasing_cantorFunction
-/

#print Cardinal.cantorFunction_injective /-
/-- `cantor_function c` is injective if `0 < c < 1/2`. -/
theorem cantorFunction_injective (h1 : 0 < c) (h2 : c < 1 / 2) :
    Function.Injective (cantorFunction c) :=
  by
  intro f g hfg
  classical
  by_contra h
  revert hfg
  have : ∃ n, f n ≠ g n := by rw [← not_forall]; intro h'; apply h; ext; apply h'
  let n := Nat.find this
  have hn : ∀ k : ℕ, k < n → f k = g k := by intro k hk; apply of_not_not;
    exact Nat.find_min this hk
  cases fn : f n
  · apply ne_of_lt; refine' increasing_cantor_function h1 h2 hn fn _
    apply Bool.eq_true_of_not_eq_false; rw [← fn]; apply Ne.symm; exact Nat.find_spec this
  · apply ne_of_gt; refine' increasing_cantor_function h1 h2 (fun k hk => (hn k hk).symm) _ fn
    apply Bool.eq_false_of_not_eq_true; rw [← fn]; apply Ne.symm; exact Nat.find_spec this
#align cardinal.cantor_function_injective Cardinal.cantorFunction_injective
-/

#print Cardinal.mk_real /-
/-- The cardinality of the reals, as a type. -/
theorem mk_real : (#ℝ) = 𝔠 := by
  apply le_antisymm
  · rw [real.equiv_Cauchy.cardinal_eq]
    apply mk_quotient_le.trans; apply (mk_subtype_le _).trans_eq
    rw [← power_def, mk_nat, mk_rat, aleph_0_power_aleph_0]
  · convert mk_le_of_injective (cantor_function_injective _ _)
    rw [← power_def, mk_bool, mk_nat, two_power_aleph_0]; exact 1 / 3; norm_num; norm_num
#align cardinal.mk_real Cardinal.mk_real
-/

#print Cardinal.mk_univ_real /-
/-- The cardinality of the reals, as a set. -/
theorem mk_univ_real : (#(Set.univ : Set ℝ)) = 𝔠 := by rw [mk_univ, mk_real]
#align cardinal.mk_univ_real Cardinal.mk_univ_real
-/

#print Cardinal.not_countable_real /-
/-- **Non-Denumerability of the Continuum**: The reals are not countable. -/
theorem not_countable_real : ¬(Set.univ : Set ℝ).Countable := by
  rw [← le_aleph_0_iff_set_countable, not_le, mk_univ_real]; apply cantor
#align cardinal.not_countable_real Cardinal.not_countable_real
-/

#print Cardinal.mk_Ioi_real /-
/-- The cardinality of the interval (a, ∞). -/
theorem mk_Ioi_real (a : ℝ) : (#Ioi a) = 𝔠 :=
  by
  refine' le_antisymm (mk_real ▸ mk_set_le _) _
  rw [← not_lt]; intro h
  refine' ne_of_lt _ mk_univ_real
  have hu : Iio a ∪ {a} ∪ Ioi a = Set.univ := by convert Iic_union_Ioi; exact Iio_union_right
  rw [← hu]
  refine' lt_of_le_of_lt (mk_union_le _ _) _
  refine' lt_of_le_of_lt (add_le_add_right (mk_union_le _ _) _) _
  have h2 : (fun x => a + a - x) '' Ioi a = Iio a := by convert image_const_sub_Ioi _ _; simp
  rw [← h2]
  refine' add_lt_of_lt (cantor _).le _ h
  refine' add_lt_of_lt (cantor _).le (mk_image_le.trans_lt h) _
  rw [mk_singleton]
  exact one_lt_aleph_0.trans (cantor _)
#align cardinal.mk_Ioi_real Cardinal.mk_Ioi_real
-/

#print Cardinal.mk_Ici_real /-
/-- The cardinality of the interval [a, ∞). -/
theorem mk_Ici_real (a : ℝ) : (#Ici a) = 𝔠 :=
  le_antisymm (mk_real ▸ mk_set_le _) (mk_Ioi_real a ▸ mk_le_mk_of_subset Ioi_subset_Ici_self)
#align cardinal.mk_Ici_real Cardinal.mk_Ici_real
-/

#print Cardinal.mk_Iio_real /-
/-- The cardinality of the interval (-∞, a). -/
theorem mk_Iio_real (a : ℝ) : (#Iio a) = 𝔠 :=
  by
  refine' le_antisymm (mk_real ▸ mk_set_le _) _
  have h2 : (fun x => a + a - x) '' Iio a = Ioi a := by convert image_const_sub_Iio _ _; simp
  exact mk_Ioi_real a ▸ h2 ▸ mk_image_le
#align cardinal.mk_Iio_real Cardinal.mk_Iio_real
-/

#print Cardinal.mk_Iic_real /-
/-- The cardinality of the interval (-∞, a]. -/
theorem mk_Iic_real (a : ℝ) : (#Iic a) = 𝔠 :=
  le_antisymm (mk_real ▸ mk_set_le _) (mk_Iio_real a ▸ mk_le_mk_of_subset Iio_subset_Iic_self)
#align cardinal.mk_Iic_real Cardinal.mk_Iic_real
-/

#print Cardinal.mk_Ioo_real /-
/-- The cardinality of the interval (a, b). -/
theorem mk_Ioo_real {a b : ℝ} (h : a < b) : (#Ioo a b) = 𝔠 :=
  by
  refine' le_antisymm (mk_real ▸ mk_set_le _) _
  have h1 : (#(fun x => x - a) '' Ioo a b) ≤ (#Ioo a b) := mk_image_le
  refine' le_trans _ h1
  rw [image_sub_const_Ioo, sub_self]
  replace h := sub_pos_of_lt h
  have h2 : (#Inv.inv '' Ioo 0 (b - a)) ≤ (#Ioo 0 (b - a)) := mk_image_le
  refine' le_trans _ h2
  rw [image_inv, inv_Ioo_0_left h, mk_Ioi_real]
#align cardinal.mk_Ioo_real Cardinal.mk_Ioo_real
-/

#print Cardinal.mk_Ico_real /-
/-- The cardinality of the interval [a, b). -/
theorem mk_Ico_real {a b : ℝ} (h : a < b) : (#Ico a b) = 𝔠 :=
  le_antisymm (mk_real ▸ mk_set_le _) (mk_Ioo_real h ▸ mk_le_mk_of_subset Ioo_subset_Ico_self)
#align cardinal.mk_Ico_real Cardinal.mk_Ico_real
-/

#print Cardinal.mk_Icc_real /-
/-- The cardinality of the interval [a, b]. -/
theorem mk_Icc_real {a b : ℝ} (h : a < b) : (#Icc a b) = 𝔠 :=
  le_antisymm (mk_real ▸ mk_set_le _) (mk_Ioo_real h ▸ mk_le_mk_of_subset Ioo_subset_Icc_self)
#align cardinal.mk_Icc_real Cardinal.mk_Icc_real
-/

#print Cardinal.mk_Ioc_real /-
/-- The cardinality of the interval (a, b]. -/
theorem mk_Ioc_real {a b : ℝ} (h : a < b) : (#Ioc a b) = 𝔠 :=
  le_antisymm (mk_real ▸ mk_set_le _) (mk_Ioo_real h ▸ mk_le_mk_of_subset Ioo_subset_Ioc_self)
#align cardinal.mk_Ioc_real Cardinal.mk_Ioc_real
-/

end Cardinal

