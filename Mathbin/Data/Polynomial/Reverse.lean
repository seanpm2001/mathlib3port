/-
Copyright (c) 2020 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa

! This file was ported from Lean 3 source module data.polynomial.reverse
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.Degree.TrailingDegree
import Mathbin.Data.Polynomial.EraseLead
import Mathbin.Data.Polynomial.Eval

/-!
# Reverse of a univariate polynomial

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The main definition is `reverse`.  Applying `reverse` to a polynomial `f : R[X]` produces
the polynomial with a reversed list of coefficients, equivalent to `X^f.nat_degree * f(1/X)`.

The main result is that `reverse (f * g) = reverse f * reverse g`, provided the leading
coefficients of `f` and `g` do not multiply to zero.
-/


namespace Polynomial

open Polynomial Finsupp Finset

open scoped Classical Polynomial

section Semiring

variable {R : Type _} [Semiring R] {f : R[X]}

#print Polynomial.revAtFun /-
/-- If `i ≤ N`, then `rev_at_fun N i` returns `N - i`, otherwise it returns `i`.
This is the map used by the embedding `rev_at`.
-/
def revAtFun (N i : ℕ) : ℕ :=
  ite (i ≤ N) (N - i) i
#align polynomial.rev_at_fun Polynomial.revAtFun
-/

#print Polynomial.revAtFun_invol /-
theorem revAtFun_invol {N i : ℕ} : revAtFun N (revAtFun N i) = i :=
  by
  unfold rev_at_fun
  split_ifs with h j
  · exact tsub_tsub_cancel_of_le h
  · exfalso
    apply j
    exact Nat.sub_le N i
  · rfl
#align polynomial.rev_at_fun_invol Polynomial.revAtFun_invol
-/

#print Polynomial.revAtFun_inj /-
theorem revAtFun_inj {N : ℕ} : Function.Injective (revAtFun N) :=
  by
  intro a b hab
  rw [← @rev_at_fun_invol N a, hab, rev_at_fun_invol]
#align polynomial.rev_at_fun_inj Polynomial.revAtFun_inj
-/

#print Polynomial.revAt /-
/-- If `i ≤ N`, then `rev_at N i` returns `N - i`, otherwise it returns `i`.
Essentially, this embedding is only used for `i ≤ N`.
The advantage of `rev_at N i` over `N - i` is that `rev_at` is an involution.
-/
def revAt (N : ℕ) : Function.Embedding ℕ ℕ
    where
  toFun i := ite (i ≤ N) (N - i) i
  inj' := revAtFun_inj
#align polynomial.rev_at Polynomial.revAt
-/

#print Polynomial.revAtFun_eq /-
/-- We prefer to use the bundled `rev_at` over unbundled `rev_at_fun`. -/
@[simp]
theorem revAtFun_eq (N i : ℕ) : revAtFun N i = revAt N i :=
  rfl
#align polynomial.rev_at_fun_eq Polynomial.revAtFun_eq
-/

#print Polynomial.revAt_invol /-
@[simp]
theorem revAt_invol {N i : ℕ} : (revAt N) (revAt N i) = i :=
  revAtFun_invol
#align polynomial.rev_at_invol Polynomial.revAt_invol
-/

#print Polynomial.revAt_le /-
@[simp]
theorem revAt_le {N i : ℕ} (H : i ≤ N) : revAt N i = N - i :=
  if_pos H
#align polynomial.rev_at_le Polynomial.revAt_le
-/

#print Polynomial.revAt_add /-
theorem revAt_add {N O n o : ℕ} (hn : n ≤ N) (ho : o ≤ O) :
    revAt (N + O) (n + o) = revAt N n + revAt O o :=
  by
  rcases Nat.le.dest hn with ⟨n', rfl⟩
  rcases Nat.le.dest ho with ⟨o', rfl⟩
  repeat' rw [rev_at_le (le_add_right rfl.le)]
  rw [add_assoc, add_left_comm n' o, ← add_assoc, rev_at_le (le_add_right rfl.le)]
  repeat' rw [add_tsub_cancel_left]
#align polynomial.rev_at_add Polynomial.revAt_add
-/

#print Polynomial.revAt_zero /-
@[simp]
theorem revAt_zero (N : ℕ) : revAt N 0 = N := by simp [rev_at]
#align polynomial.rev_at_zero Polynomial.revAt_zero
-/

#print Polynomial.reflect /-
/-- `reflect N f` is the polynomial such that `(reflect N f).coeff i = f.coeff (rev_at N i)`.
In other words, the terms with exponent `[0, ..., N]` now have exponent `[N, ..., 0]`.

In practice, `reflect` is only used when `N` is at least as large as the degree of `f`.

Eventually, it will be used with `N` exactly equal to the degree of `f`.  -/
noncomputable def reflect (N : ℕ) : R[X] → R[X]
  | ⟨f⟩ => ⟨Finsupp.embDomain (revAt N) f⟩
#align polynomial.reflect Polynomial.reflect
-/

#print Polynomial.reflect_support /-
theorem reflect_support (N : ℕ) (f : R[X]) :
    (reflect N f).support = Finset.image (revAt N) f.support :=
  by
  rcases f with ⟨⟩
  ext1
  simp only [reflect, support_of_finsupp, support_emb_domain, Finset.mem_map, Finset.mem_image]
#align polynomial.reflect_support Polynomial.reflect_support
-/

#print Polynomial.coeff_reflect /-
@[simp]
theorem coeff_reflect (N : ℕ) (f : R[X]) (i : ℕ) : coeff (reflect N f) i = f.coeff (revAt N i) :=
  by
  rcases f with ⟨⟩
  simp only [reflect, coeff]
  calc
    Finsupp.embDomain (rev_at N) f i = Finsupp.embDomain (rev_at N) f (rev_at N (rev_at N i)) := by
      rw [rev_at_invol]
    _ = f (rev_at N i) := Finsupp.embDomain_apply _ _ _
#align polynomial.coeff_reflect Polynomial.coeff_reflect
-/

#print Polynomial.reflect_zero /-
@[simp]
theorem reflect_zero {N : ℕ} : reflect N (0 : R[X]) = 0 :=
  rfl
#align polynomial.reflect_zero Polynomial.reflect_zero
-/

#print Polynomial.reflect_eq_zero_iff /-
@[simp]
theorem reflect_eq_zero_iff {N : ℕ} {f : R[X]} : reflect N (f : R[X]) = 0 ↔ f = 0 := by
  rcases f with ⟨⟩; simp [reflect]
#align polynomial.reflect_eq_zero_iff Polynomial.reflect_eq_zero_iff
-/

#print Polynomial.reflect_add /-
@[simp]
theorem reflect_add (f g : R[X]) (N : ℕ) : reflect N (f + g) = reflect N f + reflect N g := by ext;
  simp only [coeff_add, coeff_reflect]
#align polynomial.reflect_add Polynomial.reflect_add
-/

#print Polynomial.reflect_C_mul /-
@[simp]
theorem reflect_C_mul (f : R[X]) (r : R) (N : ℕ) : reflect N (C r * f) = C r * reflect N f := by
  ext; simp only [coeff_reflect, coeff_C_mul]
#align polynomial.reflect_C_mul Polynomial.reflect_C_mul
-/

#print Polynomial.reflect_C_mul_X_pow /-
@[simp]
theorem reflect_C_mul_X_pow (N n : ℕ) {c : R} : reflect N (C c * X ^ n) = C c * X ^ revAt N n :=
  by
  ext
  rw [reflect_C_mul, coeff_C_mul, coeff_C_mul, coeff_X_pow, coeff_reflect]
  split_ifs with h j
  · rw [h, rev_at_invol, coeff_X_pow_self]
  · rw [not_mem_support_iff.mp]
    intro a
    rw [← one_mul (X ^ n), ← C_1] at a 
    apply h
    rw [← mem_support_C_mul_X_pow a, rev_at_invol]
#align polynomial.reflect_C_mul_X_pow Polynomial.reflect_C_mul_X_pow
-/

#print Polynomial.reflect_C /-
@[simp]
theorem reflect_C (r : R) (N : ℕ) : reflect N (C r) = C r * X ^ N := by
  conv_lhs => rw [← mul_one (C r), ← pow_zero X, reflect_C_mul_X_pow, rev_at_zero]
#align polynomial.reflect_C Polynomial.reflect_C
-/

#print Polynomial.reflect_monomial /-
@[simp]
theorem reflect_monomial (N n : ℕ) : reflect N ((X : R[X]) ^ n) = X ^ revAt N n := by
  rw [← one_mul (X ^ n), ← one_mul (X ^ rev_at N n), ← C_1, reflect_C_mul_X_pow]
#align polynomial.reflect_monomial Polynomial.reflect_monomial
-/

#print Polynomial.reflect_mul_induction /-
theorem reflect_mul_induction (cf cg : ℕ) :
    ∀ N O : ℕ,
      ∀ f g : R[X],
        f.support.card ≤ cf.succ →
          g.support.card ≤ cg.succ →
            f.natDegree ≤ N →
              g.natDegree ≤ O → reflect (N + O) (f * g) = reflect N f * reflect O g :=
  by
  induction' cf with cf hcf
  --first induction (left): base case
  · induction' cg with cg hcg
    -- second induction (right): base case
    · intro N O f g Cf Cg Nf Og
      rw [← C_mul_X_pow_eq_self Cf, ← C_mul_X_pow_eq_self Cg]
      simp_rw [mul_assoc, X_pow_mul, mul_assoc, ← pow_add (X : R[X]), reflect_C_mul,
        reflect_monomial, add_comm, rev_at_add Nf Og, mul_assoc, X_pow_mul, mul_assoc, ←
        pow_add (X : R[X]), add_comm]
    -- second induction (right): induction step
    · intro N O f g Cf Cg Nf Og
      by_cases g0 : g = 0
      · rw [g0, reflect_zero, MulZeroClass.mul_zero, MulZeroClass.mul_zero, reflect_zero]
      rw [← erase_lead_add_C_mul_X_pow g, mul_add, reflect_add, reflect_add, mul_add, hcg, hcg] <;>
        try assumption
      · exact le_add_left card_support_C_mul_X_pow_le_one
      · exact le_trans (nat_degree_C_mul_X_pow_le g.leading_coeff g.nat_degree) Og
      · exact nat.lt_succ_iff.mp (gt_of_ge_of_gt Cg (erase_lead_support_card_lt g0))
      · exact le_trans erase_lead_nat_degree_le_aux Og
  --first induction (left): induction step
  · intro N O f g Cf Cg Nf Og
    by_cases f0 : f = 0
    · rw [f0, reflect_zero, MulZeroClass.zero_mul, MulZeroClass.zero_mul, reflect_zero]
    rw [← erase_lead_add_C_mul_X_pow f, add_mul, reflect_add, reflect_add, add_mul, hcf, hcf] <;>
      try assumption
    · exact le_add_left card_support_C_mul_X_pow_le_one
    · exact le_trans (nat_degree_C_mul_X_pow_le f.leading_coeff f.nat_degree) Nf
    · exact nat.lt_succ_iff.mp (gt_of_ge_of_gt Cf (erase_lead_support_card_lt f0))
    · exact le_trans erase_lead_nat_degree_le_aux Nf
#align polynomial.reflect_mul_induction Polynomial.reflect_mul_induction
-/

#print Polynomial.reflect_mul /-
@[simp]
theorem reflect_mul (f g : R[X]) {F G : ℕ} (Ff : f.natDegree ≤ F) (Gg : g.natDegree ≤ G) :
    reflect (F + G) (f * g) = reflect F f * reflect G g :=
  reflect_mul_induction _ _ F G f g f.support.card.le_succ g.support.card.le_succ Ff Gg
#align polynomial.reflect_mul Polynomial.reflect_mul
-/

section Eval₂

variable {S : Type _} [CommSemiring S]

#print Polynomial.eval₂_reflect_mul_pow /-
theorem eval₂_reflect_mul_pow (i : R →+* S) (x : S) [Invertible x] (N : ℕ) (f : R[X])
    (hf : f.natDegree ≤ N) : eval₂ i (⅟ x) (reflect N f) * x ^ N = eval₂ i x f :=
  by
  refine'
    induction_with_nat_degree_le (fun f => eval₂ i (⅟ x) (reflect N f) * x ^ N = eval₂ i x f) _ _ _
      _ f hf
  · simp
  · intro n r hr0 hnN
    simp only [rev_at_le hnN, reflect_C_mul_X_pow, eval₂_X_pow, eval₂_C, eval₂_mul]
    conv in x ^ N => rw [← Nat.sub_add_cancel hnN]
    rw [pow_add, ← mul_assoc, mul_assoc (i r), ← mul_pow, invOf_mul_self, one_pow, mul_one]
  · intros
    simp [*, add_mul]
#align polynomial.eval₂_reflect_mul_pow Polynomial.eval₂_reflect_mul_pow
-/

#print Polynomial.eval₂_reflect_eq_zero_iff /-
theorem eval₂_reflect_eq_zero_iff (i : R →+* S) (x : S) [Invertible x] (N : ℕ) (f : R[X])
    (hf : f.natDegree ≤ N) : eval₂ i (⅟ x) (reflect N f) = 0 ↔ eval₂ i x f = 0 :=
  by
  conv_rhs => rw [← eval₂_reflect_mul_pow i x N f hf]
  constructor
  · intro h; rw [h, MulZeroClass.zero_mul]
  · intro h;
    rw [← mul_one (eval₂ i (⅟ x) _), ← one_pow N, ← mul_invOf_self x, mul_pow, ← mul_assoc, h,
      MulZeroClass.zero_mul]
#align polynomial.eval₂_reflect_eq_zero_iff Polynomial.eval₂_reflect_eq_zero_iff
-/

end Eval₂

#print Polynomial.reverse /-
/-- The reverse of a polynomial f is the polynomial obtained by "reading f backwards".
Even though this is not the actual definition, reverse f = f (1/X) * X ^ f.nat_degree. -/
noncomputable def reverse (f : R[X]) : R[X] :=
  reflect f.natDegree f
#align polynomial.reverse Polynomial.reverse
-/

#print Polynomial.coeff_reverse /-
theorem coeff_reverse (f : R[X]) (n : ℕ) : f.reverse.coeff n = f.coeff (revAt f.natDegree n) := by
  rw [reverse, coeff_reflect]
#align polynomial.coeff_reverse Polynomial.coeff_reverse
-/

#print Polynomial.coeff_zero_reverse /-
@[simp]
theorem coeff_zero_reverse (f : R[X]) : coeff (reverse f) 0 = leadingCoeff f := by
  rw [coeff_reverse, rev_at_le (zero_le f.nat_degree), tsub_zero, leading_coeff]
#align polynomial.coeff_zero_reverse Polynomial.coeff_zero_reverse
-/

#print Polynomial.reverse_zero /-
@[simp]
theorem reverse_zero : reverse (0 : R[X]) = 0 :=
  rfl
#align polynomial.reverse_zero Polynomial.reverse_zero
-/

#print Polynomial.reverse_eq_zero /-
@[simp]
theorem reverse_eq_zero : f.reverse = 0 ↔ f = 0 := by simp [reverse]
#align polynomial.reverse_eq_zero Polynomial.reverse_eq_zero
-/

#print Polynomial.reverse_natDegree_le /-
theorem reverse_natDegree_le (f : R[X]) : f.reverse.natDegree ≤ f.natDegree :=
  by
  rw [nat_degree_le_iff_degree_le, degree_le_iff_coeff_zero]
  intro n hn
  rw [WithBot.coe_lt_coe] at hn 
  rw [coeff_reverse, rev_at, Function.Embedding.coeFn_mk, if_neg (not_le_of_gt hn),
    coeff_eq_zero_of_nat_degree_lt hn]
#align polynomial.reverse_nat_degree_le Polynomial.reverse_natDegree_le
-/

#print Polynomial.natDegree_eq_reverse_natDegree_add_natTrailingDegree /-
theorem natDegree_eq_reverse_natDegree_add_natTrailingDegree (f : R[X]) :
    f.natDegree = f.reverse.natDegree + f.natTrailingDegree :=
  by
  by_cases hf : f = 0
  · rw [hf, reverse_zero, nat_degree_zero, nat_trailing_degree_zero]
  apply le_antisymm
  · refine' tsub_le_iff_right.mp _
    apply le_nat_degree_of_ne_zero
    rw [reverse, coeff_reflect, ← rev_at_le f.nat_trailing_degree_le_nat_degree, rev_at_invol]
    exact trailing_coeff_nonzero_iff_nonzero.mpr hf
  · rw [← le_tsub_iff_left f.reverse_nat_degree_le]
    apply nat_trailing_degree_le_of_ne_zero
    have key := mt leading_coeff_eq_zero.mp (mt reverse_eq_zero.mp hf)
    rwa [leading_coeff, coeff_reverse, rev_at_le f.reverse_nat_degree_le] at key 
#align polynomial.nat_degree_eq_reverse_nat_degree_add_nat_trailing_degree Polynomial.natDegree_eq_reverse_natDegree_add_natTrailingDegree
-/

#print Polynomial.reverse_natDegree /-
theorem reverse_natDegree (f : R[X]) : f.reverse.natDegree = f.natDegree - f.natTrailingDegree := by
  rw [f.nat_degree_eq_reverse_nat_degree_add_nat_trailing_degree, add_tsub_cancel_right]
#align polynomial.reverse_nat_degree Polynomial.reverse_natDegree
-/

#print Polynomial.reverse_leadingCoeff /-
theorem reverse_leadingCoeff (f : R[X]) : f.reverse.leadingCoeff = f.trailingCoeff := by
  rw [leading_coeff, reverse_nat_degree, ← rev_at_le f.nat_trailing_degree_le_nat_degree,
    coeff_reverse, rev_at_invol, trailing_coeff]
#align polynomial.reverse_leading_coeff Polynomial.reverse_leadingCoeff
-/

#print Polynomial.reverse_natTrailingDegree /-
theorem reverse_natTrailingDegree (f : R[X]) : f.reverse.natTrailingDegree = 0 :=
  by
  by_cases hf : f = 0
  · rw [hf, reverse_zero, nat_trailing_degree_zero]
  · rw [← le_zero_iff]
    apply nat_trailing_degree_le_of_ne_zero
    rw [coeff_zero_reverse]
    exact mt leading_coeff_eq_zero.mp hf
#align polynomial.reverse_nat_trailing_degree Polynomial.reverse_natTrailingDegree
-/

#print Polynomial.reverse_trailingCoeff /-
theorem reverse_trailingCoeff (f : R[X]) : f.reverse.trailingCoeff = f.leadingCoeff := by
  rw [trailing_coeff, reverse_nat_trailing_degree, coeff_zero_reverse]
#align polynomial.reverse_trailing_coeff Polynomial.reverse_trailingCoeff
-/

#print Polynomial.reverse_mul /-
theorem reverse_mul {f g : R[X]} (fg : f.leadingCoeff * g.leadingCoeff ≠ 0) :
    reverse (f * g) = reverse f * reverse g :=
  by
  unfold reverse
  rw [nat_degree_mul' fg, reflect_mul f g rfl.le rfl.le]
#align polynomial.reverse_mul Polynomial.reverse_mul
-/

#print Polynomial.reverse_mul_of_domain /-
@[simp]
theorem reverse_mul_of_domain {R : Type _} [Ring R] [NoZeroDivisors R] (f g : R[X]) :
    reverse (f * g) = reverse f * reverse g :=
  by
  by_cases f0 : f = 0
  · simp only [f0, MulZeroClass.zero_mul, reverse_zero]
  by_cases g0 : g = 0
  · rw [g0, MulZeroClass.mul_zero, reverse_zero, MulZeroClass.mul_zero]
  simp [reverse_mul, *]
#align polynomial.reverse_mul_of_domain Polynomial.reverse_mul_of_domain
-/

#print Polynomial.trailingCoeff_mul /-
theorem trailingCoeff_mul {R : Type _} [Ring R] [NoZeroDivisors R] (p q : R[X]) :
    (p * q).trailingCoeff = p.trailingCoeff * q.trailingCoeff := by
  rw [← reverse_leading_coeff, reverse_mul_of_domain, leading_coeff_mul, reverse_leading_coeff,
    reverse_leading_coeff]
#align polynomial.trailing_coeff_mul Polynomial.trailingCoeff_mul
-/

#print Polynomial.coeff_one_reverse /-
@[simp]
theorem coeff_one_reverse (f : R[X]) : coeff (reverse f) 1 = nextCoeff f :=
  by
  rw [coeff_reverse, next_coeff]
  split_ifs with hf
  · have : coeff f 1 = 0 := coeff_eq_zero_of_nat_degree_lt (by simp only [hf, zero_lt_one])
    simp [*, rev_at]
  · rw [rev_at_le]
    exact Nat.succ_le_iff.2 (pos_iff_ne_zero.2 hf)
#align polynomial.coeff_one_reverse Polynomial.coeff_one_reverse
-/

section Eval₂

variable {S : Type _} [CommSemiring S]

#print Polynomial.eval₂_reverse_mul_pow /-
theorem eval₂_reverse_mul_pow (i : R →+* S) (x : S) [Invertible x] (f : R[X]) :
    eval₂ i (⅟ x) (reverse f) * x ^ f.natDegree = eval₂ i x f :=
  eval₂_reflect_mul_pow i _ _ f le_rfl
#align polynomial.eval₂_reverse_mul_pow Polynomial.eval₂_reverse_mul_pow
-/

#print Polynomial.eval₂_reverse_eq_zero_iff /-
@[simp]
theorem eval₂_reverse_eq_zero_iff (i : R →+* S) (x : S) [Invertible x] (f : R[X]) :
    eval₂ i (⅟ x) (reverse f) = 0 ↔ eval₂ i x f = 0 :=
  eval₂_reflect_eq_zero_iff i x _ _ le_rfl
#align polynomial.eval₂_reverse_eq_zero_iff Polynomial.eval₂_reverse_eq_zero_iff
-/

end Eval₂

end Semiring

section Ring

variable {R : Type _} [Ring R]

#print Polynomial.reflect_neg /-
@[simp]
theorem reflect_neg (f : R[X]) (N : ℕ) : reflect N (-f) = -reflect N f := by
  rw [neg_eq_neg_one_mul, ← C_1, ← C_neg, reflect_C_mul, C_neg, C_1, ← neg_eq_neg_one_mul]
#align polynomial.reflect_neg Polynomial.reflect_neg
-/

#print Polynomial.reflect_sub /-
@[simp]
theorem reflect_sub (f g : R[X]) (N : ℕ) : reflect N (f - g) = reflect N f - reflect N g := by
  rw [sub_eq_add_neg, sub_eq_add_neg, reflect_add, reflect_neg]
#align polynomial.reflect_sub Polynomial.reflect_sub
-/

#print Polynomial.reverse_neg /-
@[simp]
theorem reverse_neg (f : R[X]) : reverse (-f) = -reverse f := by
  rw [reverse, reverse, reflect_neg, nat_degree_neg]
#align polynomial.reverse_neg Polynomial.reverse_neg
-/

end Ring

end Polynomial

