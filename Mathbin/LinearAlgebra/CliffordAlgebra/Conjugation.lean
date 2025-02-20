/-
Copyright (c) 2020 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module linear_algebra.clifford_algebra.conjugation
! leanprover-community/mathlib commit fdc286cc6967a012f41b87f76dcd2797b53152af
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.CliffordAlgebra.Grading
import Mathbin.Algebra.Module.Opposites

/-!
# Conjugations

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the grade reversal and grade involution functions on multivectors, `reverse` and
`involute`.
Together, these operations compose to form the "Clifford conjugate", hence the name of this file.

https://en.wikipedia.org/wiki/Clifford_algebra#Antiautomorphisms

## Main definitions

* `clifford_algebra.involute`: the grade involution, negating each basis vector
* `clifford_algebra.reverse`: the grade reversion, reversing the order of a product of vectors

## Main statements

* `clifford_algebra.involute_involutive`
* `clifford_algebra.reverse_involutive`
* `clifford_algebra.reverse_involute_commute`
* `clifford_algebra.involute_mem_even_odd_iff`
* `clifford_algebra.reverse_mem_even_odd_iff`

-/


variable {R : Type _} [CommRing R]

variable {M : Type _} [AddCommGroup M] [Module R M]

variable {Q : QuadraticForm R M}

namespace CliffordAlgebra

section Involute

#print CliffordAlgebra.involute /-
/-- Grade involution, inverting the sign of each basis vector. -/
def involute : CliffordAlgebra Q →ₐ[R] CliffordAlgebra Q :=
  CliffordAlgebra.lift Q ⟨-ι Q, fun m => by simp⟩
#align clifford_algebra.involute CliffordAlgebra.involute
-/

#print CliffordAlgebra.involute_ι /-
@[simp]
theorem involute_ι (m : M) : involute (ι Q m) = -ι Q m :=
  lift_ι_apply _ _ m
#align clifford_algebra.involute_ι CliffordAlgebra.involute_ι
-/

#print CliffordAlgebra.involute_comp_involute /-
@[simp]
theorem involute_comp_involute : involute.comp involute = AlgHom.id R (CliffordAlgebra Q) := by ext;
  simp
#align clifford_algebra.involute_comp_involute CliffordAlgebra.involute_comp_involute
-/

#print CliffordAlgebra.involute_involutive /-
theorem involute_involutive : Function.Involutive (involute : _ → CliffordAlgebra Q) :=
  AlgHom.congr_fun involute_comp_involute
#align clifford_algebra.involute_involutive CliffordAlgebra.involute_involutive
-/

#print CliffordAlgebra.involute_involute /-
@[simp]
theorem involute_involute : ∀ a : CliffordAlgebra Q, involute (involute a) = a :=
  involute_involutive
#align clifford_algebra.involute_involute CliffordAlgebra.involute_involute
-/

#print CliffordAlgebra.involuteEquiv /-
/-- `clifford_algebra.involute` as an `alg_equiv`. -/
@[simps]
def involuteEquiv : CliffordAlgebra Q ≃ₐ[R] CliffordAlgebra Q :=
  AlgEquiv.ofAlgHom involute involute (AlgHom.ext <| involute_involute)
    (AlgHom.ext <| involute_involute)
#align clifford_algebra.involute_equiv CliffordAlgebra.involuteEquiv
-/

end Involute

section Reverse

open MulOpposite

#print CliffordAlgebra.reverse /-
/-- Grade reversion, inverting the multiplication order of basis vectors.
Also called *transpose* in some literature. -/
def reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q :=
  (opLinearEquiv R).symm.toLinearMap.comp
    (CliffordAlgebra.lift Q
        ⟨(MulOpposite.opLinearEquiv R).toLinearMap.comp (ι Q), fun m =>
          unop_injective <| by simp⟩).toLinearMap
#align clifford_algebra.reverse CliffordAlgebra.reverse
-/

#print CliffordAlgebra.reverse_ι /-
@[simp]
theorem reverse_ι (m : M) : reverse (ι Q m) = ι Q m := by simp [reverse]
#align clifford_algebra.reverse_ι CliffordAlgebra.reverse_ι
-/

#print CliffordAlgebra.reverse.commutes /-
@[simp]
theorem reverse.commutes (r : R) :
    reverse (algebraMap R (CliffordAlgebra Q) r) = algebraMap R _ r := by simp [reverse]
#align clifford_algebra.reverse.commutes CliffordAlgebra.reverse.commutes
-/

#print CliffordAlgebra.reverse.map_one /-
@[simp]
theorem reverse.map_one : reverse (1 : CliffordAlgebra Q) = 1 := by
  convert reverse.commutes (1 : R) <;> simp
#align clifford_algebra.reverse.map_one CliffordAlgebra.reverse.map_one
-/

#print CliffordAlgebra.reverse.map_mul /-
@[simp]
theorem reverse.map_mul (a b : CliffordAlgebra Q) : reverse (a * b) = reverse b * reverse a := by
  simp [reverse]
#align clifford_algebra.reverse.map_mul CliffordAlgebra.reverse.map_mul
-/

#print CliffordAlgebra.reverse_comp_reverse /-
@[simp]
theorem reverse_comp_reverse : reverse.comp reverse = (LinearMap.id : _ →ₗ[R] CliffordAlgebra Q) :=
  by
  ext m
  simp only [LinearMap.id_apply, LinearMap.comp_apply]
  induction m using CliffordAlgebra.induction
  -- simp can close these goals, but is slow
  case h_grade0 => rw [reverse.commutes, reverse.commutes]
  case h_grade1 => rw [reverse_ι, reverse_ι]
  case h_mul a b ha hb => rw [reverse.map_mul, reverse.map_mul, ha, hb]
  case h_add a b ha hb => rw [reverse.map_add, reverse.map_add, ha, hb]
#align clifford_algebra.reverse_comp_reverse CliffordAlgebra.reverse_comp_reverse
-/

#print CliffordAlgebra.reverse_involutive /-
@[simp]
theorem reverse_involutive : Function.Involutive (reverse : _ → CliffordAlgebra Q) :=
  LinearMap.congr_fun reverse_comp_reverse
#align clifford_algebra.reverse_involutive CliffordAlgebra.reverse_involutive
-/

#print CliffordAlgebra.reverse_reverse /-
@[simp]
theorem reverse_reverse : ∀ a : CliffordAlgebra Q, reverse (reverse a) = a :=
  reverse_involutive
#align clifford_algebra.reverse_reverse CliffordAlgebra.reverse_reverse
-/

#print CliffordAlgebra.reverseEquiv /-
/-- `clifford_algebra.reverse` as a `linear_equiv`. -/
@[simps]
def reverseEquiv : CliffordAlgebra Q ≃ₗ[R] CliffordAlgebra Q :=
  LinearEquiv.ofInvolutive reverse reverse_involutive
#align clifford_algebra.reverse_equiv CliffordAlgebra.reverseEquiv
-/

#print CliffordAlgebra.reverse_comp_involute /-
theorem reverse_comp_involute :
    reverse.comp involute.toLinearMap =
      (involute.toLinearMap.comp reverse : _ →ₗ[R] CliffordAlgebra Q) :=
  by
  ext
  simp only [LinearMap.comp_apply, AlgHom.toLinearMap_apply]
  induction x using CliffordAlgebra.induction
  case h_grade0 => simp
  case h_grade1 => simp
  case h_mul a b ha hb => simp only [ha, hb, reverse.map_mul, AlgHom.map_mul]
  case h_add a b ha hb => simp only [ha, hb, reverse.map_add, AlgHom.map_add]
#align clifford_algebra.reverse_comp_involute CliffordAlgebra.reverse_comp_involute
-/

#print CliffordAlgebra.reverse_involute_commute /-
/-- `clifford_algebra.reverse` and `clifford_algebra.inverse` commute. Note that the composition
is sometimes referred to as the "clifford conjugate". -/
theorem reverse_involute_commute : Function.Commute (reverse : _ → CliffordAlgebra Q) involute :=
  LinearMap.congr_fun reverse_comp_involute
#align clifford_algebra.reverse_involute_commute CliffordAlgebra.reverse_involute_commute
-/

#print CliffordAlgebra.reverse_involute /-
theorem reverse_involute : ∀ a : CliffordAlgebra Q, reverse (involute a) = involute (reverse a) :=
  reverse_involute_commute
#align clifford_algebra.reverse_involute CliffordAlgebra.reverse_involute
-/

end Reverse

/-!
### Statements about conjugations of products of lists
-/


section List

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CliffordAlgebra.reverse_prod_map_ι /-
/-- Taking the reverse of the product a list of $n$ vectors lifted via `ι` is equivalent to
taking the product of the reverse of that list. -/
theorem reverse_prod_map_ι : ∀ l : List M, reverse (l.map <| ι Q).Prod = (l.map <| ι Q).reverse.Prod
  | [] => by simp
  | x::xs => by simp [reverse_prod_map_ι xs]
#align clifford_algebra.reverse_prod_map_ι CliffordAlgebra.reverse_prod_map_ι
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CliffordAlgebra.involute_prod_map_ι /-
/-- Taking the involute of the product a list of $n$ vectors lifted via `ι` is equivalent to
premultiplying by ${-1}^n$. -/
theorem involute_prod_map_ι :
    ∀ l : List M, involute (l.map <| ι Q).Prod = (-1 : R) ^ l.length • (l.map <| ι Q).Prod
  | [] => by simp
  | x::xs => by simp [pow_add, involute_prod_map_ι xs]
#align clifford_algebra.involute_prod_map_ι CliffordAlgebra.involute_prod_map_ι
-/

end List

/-!
### Statements about `submodule.map` and `submodule.comap`
-/


section Submodule

variable (Q)

section Involute

#print CliffordAlgebra.submodule_map_involute_eq_comap /-
theorem submodule_map_involute_eq_comap (p : Submodule R (CliffordAlgebra Q)) :
    p.map (involute : CliffordAlgebra Q →ₐ[R] CliffordAlgebra Q).toLinearMap =
      p.comap (involute : CliffordAlgebra Q →ₐ[R] CliffordAlgebra Q).toLinearMap :=
  Submodule.map_equiv_eq_comap_symm involuteEquiv.toLinearEquiv _
#align clifford_algebra.submodule_map_involute_eq_comap CliffordAlgebra.submodule_map_involute_eq_comap
-/

#print CliffordAlgebra.ι_range_map_involute /-
@[simp]
theorem ι_range_map_involute :
    (ι Q).range.map (involute : CliffordAlgebra Q →ₐ[R] CliffordAlgebra Q).toLinearMap =
      (ι Q).range :=
  (ι_range_map_lift _ _).trans (LinearMap.range_neg _)
#align clifford_algebra.ι_range_map_involute CliffordAlgebra.ι_range_map_involute
-/

#print CliffordAlgebra.ι_range_comap_involute /-
@[simp]
theorem ι_range_comap_involute :
    (ι Q).range.comap (involute : CliffordAlgebra Q →ₐ[R] CliffordAlgebra Q).toLinearMap =
      (ι Q).range :=
  by rw [← submodule_map_involute_eq_comap, ι_range_map_involute]
#align clifford_algebra.ι_range_comap_involute CliffordAlgebra.ι_range_comap_involute
-/

#print CliffordAlgebra.evenOdd_map_involute /-
@[simp]
theorem evenOdd_map_involute (n : ZMod 2) :
    (evenOdd Q n).map (involute : CliffordAlgebra Q →ₐ[R] CliffordAlgebra Q).toLinearMap =
      evenOdd Q n :=
  by simp_rw [even_odd, Submodule.map_iSup, Submodule.map_pow, ι_range_map_involute]
#align clifford_algebra.even_odd_map_involute CliffordAlgebra.evenOdd_map_involute
-/

#print CliffordAlgebra.evenOdd_comap_involute /-
@[simp]
theorem evenOdd_comap_involute (n : ZMod 2) :
    (evenOdd Q n).comap (involute : CliffordAlgebra Q →ₐ[R] CliffordAlgebra Q).toLinearMap =
      evenOdd Q n :=
  by rw [← submodule_map_involute_eq_comap, even_odd_map_involute]
#align clifford_algebra.even_odd_comap_involute CliffordAlgebra.evenOdd_comap_involute
-/

end Involute

section Reverse

#print CliffordAlgebra.submodule_map_reverse_eq_comap /-
theorem submodule_map_reverse_eq_comap (p : Submodule R (CliffordAlgebra Q)) :
    p.map (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) =
      p.comap (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) :=
  Submodule.map_equiv_eq_comap_symm (reverseEquiv : _ ≃ₗ[R] _) _
#align clifford_algebra.submodule_map_reverse_eq_comap CliffordAlgebra.submodule_map_reverse_eq_comap
-/

#print CliffordAlgebra.ι_range_map_reverse /-
@[simp]
theorem ι_range_map_reverse :
    (ι Q).range.map (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) = (ι Q).range :=
  by
  rw [reverse, Submodule.map_comp, ι_range_map_lift, LinearMap.range_comp, ← Submodule.map_comp]
  exact Submodule.map_id _
#align clifford_algebra.ι_range_map_reverse CliffordAlgebra.ι_range_map_reverse
-/

#print CliffordAlgebra.ι_range_comap_reverse /-
@[simp]
theorem ι_range_comap_reverse :
    (ι Q).range.comap (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) = (ι Q).range := by
  rw [← submodule_map_reverse_eq_comap, ι_range_map_reverse]
#align clifford_algebra.ι_range_comap_reverse CliffordAlgebra.ι_range_comap_reverse
-/

#print CliffordAlgebra.submodule_map_mul_reverse /-
/-- Like `submodule.map_mul`, but with the multiplication reversed. -/
theorem submodule_map_mul_reverse (p q : Submodule R (CliffordAlgebra Q)) :
    (p * q).map (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) =
      q.map (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) *
        p.map (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) :=
  by
  simp_rw [reverse, Submodule.map_comp, LinearEquiv.toLinearMap_eq_coe, Submodule.map_mul,
    Submodule.map_unop_mul]
#align clifford_algebra.submodule_map_mul_reverse CliffordAlgebra.submodule_map_mul_reverse
-/

#print CliffordAlgebra.submodule_comap_mul_reverse /-
theorem submodule_comap_mul_reverse (p q : Submodule R (CliffordAlgebra Q)) :
    (p * q).comap (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) =
      q.comap (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) *
        p.comap (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) :=
  by simp_rw [← submodule_map_reverse_eq_comap, submodule_map_mul_reverse]
#align clifford_algebra.submodule_comap_mul_reverse CliffordAlgebra.submodule_comap_mul_reverse
-/

#print CliffordAlgebra.submodule_map_pow_reverse /-
/-- Like `submodule.map_pow` -/
theorem submodule_map_pow_reverse (p : Submodule R (CliffordAlgebra Q)) (n : ℕ) :
    (p ^ n).map (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) =
      p.map (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) ^ n :=
  by
  simp_rw [reverse, Submodule.map_comp, LinearEquiv.toLinearMap_eq_coe, Submodule.map_pow,
    Submodule.map_unop_pow]
#align clifford_algebra.submodule_map_pow_reverse CliffordAlgebra.submodule_map_pow_reverse
-/

#print CliffordAlgebra.submodule_comap_pow_reverse /-
theorem submodule_comap_pow_reverse (p : Submodule R (CliffordAlgebra Q)) (n : ℕ) :
    (p ^ n).comap (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) =
      p.comap (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) ^ n :=
  by simp_rw [← submodule_map_reverse_eq_comap, submodule_map_pow_reverse]
#align clifford_algebra.submodule_comap_pow_reverse CliffordAlgebra.submodule_comap_pow_reverse
-/

#print CliffordAlgebra.evenOdd_map_reverse /-
@[simp]
theorem evenOdd_map_reverse (n : ZMod 2) :
    (evenOdd Q n).map (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) = evenOdd Q n := by
  simp_rw [even_odd, Submodule.map_iSup, submodule_map_pow_reverse, ι_range_map_reverse]
#align clifford_algebra.even_odd_map_reverse CliffordAlgebra.evenOdd_map_reverse
-/

#print CliffordAlgebra.evenOdd_comap_reverse /-
@[simp]
theorem evenOdd_comap_reverse (n : ZMod 2) :
    (evenOdd Q n).comap (reverse : CliffordAlgebra Q →ₗ[R] CliffordAlgebra Q) = evenOdd Q n := by
  rw [← submodule_map_reverse_eq_comap, even_odd_map_reverse]
#align clifford_algebra.even_odd_comap_reverse CliffordAlgebra.evenOdd_comap_reverse
-/

end Reverse

#print CliffordAlgebra.involute_mem_evenOdd_iff /-
@[simp]
theorem involute_mem_evenOdd_iff {x : CliffordAlgebra Q} {n : ZMod 2} :
    involute x ∈ evenOdd Q n ↔ x ∈ evenOdd Q n :=
  SetLike.ext_iff.mp (evenOdd_comap_involute Q n) x
#align clifford_algebra.involute_mem_even_odd_iff CliffordAlgebra.involute_mem_evenOdd_iff
-/

#print CliffordAlgebra.reverse_mem_evenOdd_iff /-
@[simp]
theorem reverse_mem_evenOdd_iff {x : CliffordAlgebra Q} {n : ZMod 2} :
    reverse x ∈ evenOdd Q n ↔ x ∈ evenOdd Q n :=
  SetLike.ext_iff.mp (evenOdd_comap_reverse Q n) x
#align clifford_algebra.reverse_mem_even_odd_iff CliffordAlgebra.reverse_mem_evenOdd_iff
-/

end Submodule

/-!
### Related properties of the even and odd submodules

TODO: show that these are `iff`s when `invertible (2 : R)`.
-/


#print CliffordAlgebra.involute_eq_of_mem_even /-
theorem involute_eq_of_mem_even {x : CliffordAlgebra Q} (h : x ∈ evenOdd Q 0) : involute x = x :=
  by
  refine' even_induction Q (AlgHom.commutes _) _ _ x h
  · rintro x y hx hy ihx ihy
    rw [map_add, ihx, ihy]
  · intro m₁ m₂ x hx ihx
    rw [map_mul, map_mul, involute_ι, involute_ι, ihx, neg_mul_neg]
#align clifford_algebra.involute_eq_of_mem_even CliffordAlgebra.involute_eq_of_mem_even
-/

#print CliffordAlgebra.involute_eq_of_mem_odd /-
theorem involute_eq_of_mem_odd {x : CliffordAlgebra Q} (h : x ∈ evenOdd Q 1) : involute x = -x :=
  by
  refine' odd_induction Q involute_ι _ _ x h
  · rintro x y hx hy ihx ihy
    rw [map_add, ihx, ihy, neg_add]
  · intro m₁ m₂ x hx ihx
    rw [map_mul, map_mul, involute_ι, involute_ι, ihx, neg_mul_neg, mul_neg]
#align clifford_algebra.involute_eq_of_mem_odd CliffordAlgebra.involute_eq_of_mem_odd
-/

end CliffordAlgebra

