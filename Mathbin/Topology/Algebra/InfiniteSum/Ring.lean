/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module topology.algebra.infinite_sum.ring
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.NatAntidiagonal
import Mathbin.Topology.Algebra.InfiniteSum.Basic
import Mathbin.Topology.Algebra.Ring.Basic

/-!
# Infinite sum in a ring

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides lemmas about the interaction between infinite sums and multiplication.

## Main results

* `tsum_mul_tsum_eq_tsum_sum_antidiagonal`: Cauchy product formula
-/


open Filter Finset Function

open scoped BigOperators Classical

variable {ι κ R α : Type _}

section NonUnitalNonAssocSemiring

variable [NonUnitalNonAssocSemiring α] [TopologicalSpace α] [TopologicalSemiring α] {f g : ι → α}
  {a a₁ a₂ : α}

#print HasSum.mul_left /-
theorem HasSum.mul_left (a₂) (h : HasSum f a₁) : HasSum (fun i => a₂ * f i) (a₂ * a₁) := by
  simpa only using h.map (AddMonoidHom.mulLeft a₂) (continuous_const.mul continuous_id)
#align has_sum.mul_left HasSum.mul_left
-/

#print HasSum.mul_right /-
theorem HasSum.mul_right (a₂) (hf : HasSum f a₁) : HasSum (fun i => f i * a₂) (a₁ * a₂) := by
  simpa only using hf.map (AddMonoidHom.mulRight a₂) (continuous_id.mul continuous_const)
#align has_sum.mul_right HasSum.mul_right
-/

#print Summable.mul_left /-
theorem Summable.mul_left (a) (hf : Summable f) : Summable fun i => a * f i :=
  (hf.HasSum.mulLeft _).Summable
#align summable.mul_left Summable.mul_left
-/

#print Summable.mul_right /-
theorem Summable.mul_right (a) (hf : Summable f) : Summable fun i => f i * a :=
  (hf.HasSum.mulRight _).Summable
#align summable.mul_right Summable.mul_right
-/

section tsum

variable [T2Space α]

#print Summable.tsum_mul_left /-
theorem Summable.tsum_mul_left (a) (hf : Summable f) : ∑' i, a * f i = a * ∑' i, f i :=
  (hf.HasSum.mulLeft _).tsum_eq
#align summable.tsum_mul_left Summable.tsum_mul_left
-/

#print Summable.tsum_mul_right /-
theorem Summable.tsum_mul_right (a) (hf : Summable f) : ∑' i, f i * a = (∑' i, f i) * a :=
  (hf.HasSum.mulRight _).tsum_eq
#align summable.tsum_mul_right Summable.tsum_mul_right
-/

#print Commute.tsum_right /-
theorem Commute.tsum_right (a) (h : ∀ i, Commute a (f i)) : Commute a (∑' i, f i) :=
  if hf : Summable f then
    (hf.tsum_mul_left a).symm.trans ((congr_arg _ <| funext h).trans (hf.tsum_mul_right a))
  else (tsum_eq_zero_of_not_summable hf).symm ▸ Commute.zero_right _
#align commute.tsum_right Commute.tsum_right
-/

#print Commute.tsum_left /-
theorem Commute.tsum_left (a) (h : ∀ i, Commute (f i) a) : Commute (∑' i, f i) a :=
  (Commute.tsum_right _ fun i => (h i).symm).symm
#align commute.tsum_left Commute.tsum_left
-/

end tsum

end NonUnitalNonAssocSemiring

section DivisionSemiring

variable [DivisionSemiring α] [TopologicalSpace α] [TopologicalSemiring α] {f g : ι → α}
  {a a₁ a₂ : α}

#print HasSum.div_const /-
theorem HasSum.div_const (h : HasSum f a) (b : α) : HasSum (fun i => f i / b) (a / b) := by
  simp only [div_eq_mul_inv, h.mul_right b⁻¹]
#align has_sum.div_const HasSum.div_const
-/

#print Summable.div_const /-
theorem Summable.div_const (h : Summable f) (b : α) : Summable fun i => f i / b :=
  (h.HasSum.div_const _).Summable
#align summable.div_const Summable.div_const
-/

#print hasSum_mul_left_iff /-
theorem hasSum_mul_left_iff (h : a₂ ≠ 0) : HasSum (fun i => a₂ * f i) (a₂ * a₁) ↔ HasSum f a₁ :=
  ⟨fun H => by simpa only [inv_mul_cancel_left₀ h] using H.mul_left a₂⁻¹, HasSum.mul_left _⟩
#align has_sum_mul_left_iff hasSum_mul_left_iff
-/

#print hasSum_mul_right_iff /-
theorem hasSum_mul_right_iff (h : a₂ ≠ 0) : HasSum (fun i => f i * a₂) (a₁ * a₂) ↔ HasSum f a₁ :=
  ⟨fun H => by simpa only [mul_inv_cancel_right₀ h] using H.mul_right a₂⁻¹, HasSum.mul_right _⟩
#align has_sum_mul_right_iff hasSum_mul_right_iff
-/

#print hasSum_div_const_iff /-
theorem hasSum_div_const_iff (h : a₂ ≠ 0) : HasSum (fun i => f i / a₂) (a₁ / a₂) ↔ HasSum f a₁ := by
  simpa only [div_eq_mul_inv] using hasSum_mul_right_iff (inv_ne_zero h)
#align has_sum_div_const_iff hasSum_div_const_iff
-/

#print summable_mul_left_iff /-
theorem summable_mul_left_iff (h : a ≠ 0) : (Summable fun i => a * f i) ↔ Summable f :=
  ⟨fun H => by simpa only [inv_mul_cancel_left₀ h] using H.mul_left a⁻¹, fun H => H.mulLeft _⟩
#align summable_mul_left_iff summable_mul_left_iff
-/

#print summable_mul_right_iff /-
theorem summable_mul_right_iff (h : a ≠ 0) : (Summable fun i => f i * a) ↔ Summable f :=
  ⟨fun H => by simpa only [mul_inv_cancel_right₀ h] using H.mul_right a⁻¹, fun H => H.mulRight _⟩
#align summable_mul_right_iff summable_mul_right_iff
-/

#print summable_div_const_iff /-
theorem summable_div_const_iff (h : a ≠ 0) : (Summable fun i => f i / a) ↔ Summable f := by
  simpa only [div_eq_mul_inv] using summable_mul_right_iff (inv_ne_zero h)
#align summable_div_const_iff summable_div_const_iff
-/

#print tsum_mul_left /-
theorem tsum_mul_left [T2Space α] : ∑' x, a * f x = a * ∑' x, f x :=
  if hf : Summable f then hf.tsum_mul_left a
  else
    if ha : a = 0 then by simp [ha]
    else by
      rw [tsum_eq_zero_of_not_summable hf,
        tsum_eq_zero_of_not_summable (mt (summable_mul_left_iff ha).mp hf), MulZeroClass.mul_zero]
#align tsum_mul_left tsum_mul_left
-/

#print tsum_mul_right /-
theorem tsum_mul_right [T2Space α] : ∑' x, f x * a = (∑' x, f x) * a :=
  if hf : Summable f then hf.tsum_mul_right a
  else
    if ha : a = 0 then by simp [ha]
    else by
      rw [tsum_eq_zero_of_not_summable hf,
        tsum_eq_zero_of_not_summable (mt (summable_mul_right_iff ha).mp hf), MulZeroClass.zero_mul]
#align tsum_mul_right tsum_mul_right
-/

#print tsum_div_const /-
theorem tsum_div_const [T2Space α] : ∑' x, f x / a = (∑' x, f x) / a := by
  simpa only [div_eq_mul_inv] using tsum_mul_right
#align tsum_div_const tsum_div_const
-/

end DivisionSemiring

/-!
### Multipliying two infinite sums

In this section, we prove various results about `(∑' x : ι, f x) * (∑' y : κ, g y)`. Note that we
always assume that the family `λ x : ι × κ, f x.1 * g x.2` is summable, since there is no way to
deduce this from the summmabilities of `f` and `g` in general, but if you are working in a normed
space, you may want to use the analogous lemmas in `analysis/normed_space/basic`
(e.g `tsum_mul_tsum_of_summable_norm`).

We first establish results about arbitrary index types, `ι` and `κ`, and then we specialize to
`ι = κ = ℕ` to prove the Cauchy product formula (see `tsum_mul_tsum_eq_tsum_sum_antidiagonal`).

#### Arbitrary index types
-/


section tsum_mul_tsum

variable [TopologicalSpace α] [T3Space α] [NonUnitalNonAssocSemiring α] [TopologicalSemiring α]
  {f : ι → α} {g : κ → α} {s t u : α}

#print HasSum.mul_eq /-
theorem HasSum.mul_eq (hf : HasSum f s) (hg : HasSum g t)
    (hfg : HasSum (fun x : ι × κ => f x.1 * g x.2) u) : s * t = u :=
  have key₁ : HasSum (fun i => f i * t) (s * t) := hf.mulRight t
  have this : ∀ i : ι, HasSum (fun c : κ => f i * g c) (f i * t) := fun i => hg.mulLeft (f i)
  have key₂ : HasSum (fun i => f i * t) u := HasSum.prod_fiberwise hfg this
  key₁.unique key₂
#align has_sum.mul_eq HasSum.mul_eq
-/

#print HasSum.mul /-
theorem HasSum.mul (hf : HasSum f s) (hg : HasSum g t)
    (hfg : Summable fun x : ι × κ => f x.1 * g x.2) :
    HasSum (fun x : ι × κ => f x.1 * g x.2) (s * t) :=
  let ⟨u, hu⟩ := hfg
  (hf.mul_eq hg hu).symm ▸ hu
#align has_sum.mul HasSum.mul
-/

#print tsum_mul_tsum /-
/-- Product of two infinites sums indexed by arbitrary types.
    See also `tsum_mul_tsum_of_summable_norm` if `f` and `g` are abolutely summable. -/
theorem tsum_mul_tsum (hf : Summable f) (hg : Summable g)
    (hfg : Summable fun x : ι × κ => f x.1 * g x.2) :
    (∑' x, f x) * ∑' y, g y = ∑' z : ι × κ, f z.1 * g z.2 :=
  hf.HasSum.mul_eq hg.HasSum hfg.HasSum
#align tsum_mul_tsum tsum_mul_tsum
-/

end tsum_mul_tsum

/-!
#### `ℕ`-indexed families (Cauchy product)

We prove two versions of the Cauchy product formula. The first one is
`tsum_mul_tsum_eq_tsum_sum_range`, where the `n`-th term is a sum over `finset.range (n+1)`
involving `nat` subtraction.
In order to avoid `nat` subtraction, we also provide `tsum_mul_tsum_eq_tsum_sum_antidiagonal`,
where the `n`-th term is a sum over all pairs `(k, l)` such that `k+l=n`, which corresponds to the
`finset` `finset.nat.antidiagonal n`
-/


section cauchy_product

variable [TopologicalSpace α] [NonUnitalNonAssocSemiring α] {f g : ℕ → α}

#print summable_mul_prod_iff_summable_mul_sigma_antidiagonal /-
/- The family `(k, l) : ℕ × ℕ ↦ f k * g l` is summable if and only if the family
`(n, k, l) : Σ (n : ℕ), nat.antidiagonal n ↦ f k * g l` is summable. -/
theorem summable_mul_prod_iff_summable_mul_sigma_antidiagonal :
    (Summable fun x : ℕ × ℕ => f x.1 * g x.2) ↔
      Summable fun x : Σ n : ℕ, Nat.antidiagonal n => f (x.2 : ℕ × ℕ).1 * g (x.2 : ℕ × ℕ).2 :=
  Nat.sigmaAntidiagonalEquivProd.summable_iff.symm
#align summable_mul_prod_iff_summable_mul_sigma_antidiagonal summable_mul_prod_iff_summable_mul_sigma_antidiagonal
-/

variable [T3Space α] [TopologicalSemiring α]

#print summable_sum_mul_antidiagonal_of_summable_mul /-
theorem summable_sum_mul_antidiagonal_of_summable_mul
    (h : Summable fun x : ℕ × ℕ => f x.1 * g x.2) :
    Summable fun n => ∑ kl in Nat.antidiagonal n, f kl.1 * g kl.2 :=
  by
  rw [summable_mul_prod_iff_summable_mul_sigma_antidiagonal] at h 
  conv =>
    congr
    ext
    rw [← Finset.sum_finset_coe, ← tsum_fintype]
  exact h.sigma' fun n => (hasSum_fintype _).Summable
#align summable_sum_mul_antidiagonal_of_summable_mul summable_sum_mul_antidiagonal_of_summable_mul
-/

#print tsum_mul_tsum_eq_tsum_sum_antidiagonal /-
/-- The **Cauchy product formula** for the product of two infinites sums indexed by `ℕ`, expressed
by summing on `finset.nat.antidiagonal`.

See also `tsum_mul_tsum_eq_tsum_sum_antidiagonal_of_summable_norm` if `f` and `g` are absolutely
summable. -/
theorem tsum_mul_tsum_eq_tsum_sum_antidiagonal (hf : Summable f) (hg : Summable g)
    (hfg : Summable fun x : ℕ × ℕ => f x.1 * g x.2) :
    (∑' n, f n) * ∑' n, g n = ∑' n, ∑ kl in Nat.antidiagonal n, f kl.1 * g kl.2 :=
  by
  conv_rhs =>
    congr
    ext
    rw [← Finset.sum_finset_coe, ← tsum_fintype]
  rw [tsum_mul_tsum hf hg hfg, ← nat.sigma_antidiagonal_equiv_prod.tsum_eq (_ : ℕ × ℕ → α)]
  exact
    tsum_sigma' (fun n => (hasSum_fintype _).Summable)
      (summable_mul_prod_iff_summable_mul_sigma_antidiagonal.mp hfg)
#align tsum_mul_tsum_eq_tsum_sum_antidiagonal tsum_mul_tsum_eq_tsum_sum_antidiagonal
-/

#print summable_sum_mul_range_of_summable_mul /-
theorem summable_sum_mul_range_of_summable_mul (h : Summable fun x : ℕ × ℕ => f x.1 * g x.2) :
    Summable fun n => ∑ k in range (n + 1), f k * g (n - k) :=
  by
  simp_rw [← nat.sum_antidiagonal_eq_sum_range_succ fun k l => f k * g l]
  exact summable_sum_mul_antidiagonal_of_summable_mul h
#align summable_sum_mul_range_of_summable_mul summable_sum_mul_range_of_summable_mul
-/

#print tsum_mul_tsum_eq_tsum_sum_range /-
/-- The **Cauchy product formula** for the product of two infinites sums indexed by `ℕ`, expressed
by summing on `finset.range`.

See also `tsum_mul_tsum_eq_tsum_sum_range_of_summable_norm` if `f` and `g` are absolutely summable.
-/
theorem tsum_mul_tsum_eq_tsum_sum_range (hf : Summable f) (hg : Summable g)
    (hfg : Summable fun x : ℕ × ℕ => f x.1 * g x.2) :
    (∑' n, f n) * ∑' n, g n = ∑' n, ∑ k in range (n + 1), f k * g (n - k) :=
  by
  simp_rw [← nat.sum_antidiagonal_eq_sum_range_succ fun k l => f k * g l]
  exact tsum_mul_tsum_eq_tsum_sum_antidiagonal hf hg hfg
#align tsum_mul_tsum_eq_tsum_sum_range tsum_mul_tsum_eq_tsum_sum_range
-/

end cauchy_product

