/-
Copyright (c) 2022 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module linear_algebra.clifford_algebra.fold
! leanprover-community/mathlib commit 30faa0c3618ce1472bf6305ae0e3fa56affa3f95
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.CliffordAlgebra.Conjugation

/-!
# Recursive computation rules for the Clifford algebra

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides API for a special case `clifford_algebra.foldr` of the universal property
`clifford_algebra.lift` with `A = module.End R N` for some arbitrary module `N`. This specialization
resembles the `list.foldr` operation, allowing a bilinear map to be "folded" along the generators.

For convenience, this file also provides `clifford_algebra.foldl`, implemented via
`clifford_algebra.reverse`

## Main definitions

* `clifford_algebra.foldr`: a computation rule for building linear maps out of the clifford
  algebra starting on the right, analogous to using `list.foldr` on the generators.
* `clifford_algebra.foldl`: a computation rule for building linear maps out of the clifford
  algebra starting on the left, analogous to using `list.foldl` on the generators.

## Main statements

* `clifford_algebra.right_induction`: an induction rule that adds generators from the right.
* `clifford_algebra.left_induction`: an induction rule that adds generators from the left.
-/


universe u1 u2 u3

variable {R M N : Type _}

variable [CommRing R] [AddCommGroup M] [AddCommGroup N]

variable [Module R M] [Module R N]

variable (Q : QuadraticForm R M)

namespace CliffordAlgebra

section Foldr

#print CliffordAlgebra.foldr /-
/-- Fold a bilinear map along the generators of a term of the clifford algebra, with the rule
given by `foldr Q f hf n (ι Q m * x) = f m (foldr Q f hf n x)`.

For example, `foldr f hf n (r • ι R u + ι R v * ι R w) = r • f u n + f v (f w n)`. -/
def foldr (f : M →ₗ[R] N →ₗ[R] N) (hf : ∀ m x, f m (f m x) = Q m • x) :
    N →ₗ[R] CliffordAlgebra Q →ₗ[R] N :=
  (CliffordAlgebra.lift Q ⟨f, fun v => LinearMap.ext <| hf v⟩).toLinearMap.flip
#align clifford_algebra.foldr CliffordAlgebra.foldr
-/

#print CliffordAlgebra.foldr_ι /-
@[simp]
theorem foldr_ι (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) (m : M) : foldr Q f hf n (ι Q m) = f m n :=
  LinearMap.congr_fun (lift_ι_apply _ _ _) n
#align clifford_algebra.foldr_ι CliffordAlgebra.foldr_ι
-/

#print CliffordAlgebra.foldr_algebraMap /-
@[simp]
theorem foldr_algebraMap (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) (r : R) :
    foldr Q f hf n (algebraMap R _ r) = r • n :=
  LinearMap.congr_fun (AlgHom.commutes _ r) n
#align clifford_algebra.foldr_algebra_map CliffordAlgebra.foldr_algebraMap
-/

#print CliffordAlgebra.foldr_one /-
@[simp]
theorem foldr_one (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) : foldr Q f hf n 1 = n :=
  LinearMap.congr_fun (AlgHom.map_one _) n
#align clifford_algebra.foldr_one CliffordAlgebra.foldr_one
-/

#print CliffordAlgebra.foldr_mul /-
@[simp]
theorem foldr_mul (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) (a b : CliffordAlgebra Q) :
    foldr Q f hf n (a * b) = foldr Q f hf (foldr Q f hf n b) a :=
  LinearMap.congr_fun (AlgHom.map_mul _ _ _) n
#align clifford_algebra.foldr_mul CliffordAlgebra.foldr_mul
-/

#print CliffordAlgebra.foldr_prod_map_ι /-
/-- This lemma demonstrates the origin of the `foldr` name. -/
theorem foldr_prod_map_ι (l : List M) (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) :
    foldr Q f hf n (l.map <| ι Q).Prod = List.foldr (fun m n => f m n) n l :=
  by
  induction' l with hd tl ih
  · rw [List.map_nil, List.prod_nil, List.foldr_nil, foldr_one]
  · rw [List.map_cons, List.prod_cons, List.foldr_cons, foldr_mul, foldr_ι, ih]
#align clifford_algebra.foldr_prod_map_ι CliffordAlgebra.foldr_prod_map_ι
-/

end Foldr

section Foldl

#print CliffordAlgebra.foldl /-
/-- Fold a bilinear map along the generators of a term of the clifford algebra, with the rule
given by `foldl Q f hf n (ι Q m * x) = f m (foldl Q f hf n x)`.

For example, `foldl f hf n (r • ι R u + ι R v * ι R w) = r • f u n + f v (f w n)`. -/
def foldl (f : M →ₗ[R] N →ₗ[R] N) (hf : ∀ m x, f m (f m x) = Q m • x) :
    N →ₗ[R] CliffordAlgebra Q →ₗ[R] N :=
  LinearMap.compl₂ (foldr Q f hf) reverse
#align clifford_algebra.foldl CliffordAlgebra.foldl
-/

#print CliffordAlgebra.foldl_reverse /-
@[simp]
theorem foldl_reverse (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) (x : CliffordAlgebra Q) :
    foldl Q f hf n (reverse x) = foldr Q f hf n x :=
  FunLike.congr_arg (foldr Q f hf n) <| reverse_reverse _
#align clifford_algebra.foldl_reverse CliffordAlgebra.foldl_reverse
-/

#print CliffordAlgebra.foldr_reverse /-
@[simp]
theorem foldr_reverse (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) (x : CliffordAlgebra Q) :
    foldr Q f hf n (reverse x) = foldl Q f hf n x :=
  rfl
#align clifford_algebra.foldr_reverse CliffordAlgebra.foldr_reverse
-/

#print CliffordAlgebra.foldl_ι /-
@[simp]
theorem foldl_ι (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) (m : M) : foldl Q f hf n (ι Q m) = f m n := by
  rw [← foldr_reverse, reverse_ι, foldr_ι]
#align clifford_algebra.foldl_ι CliffordAlgebra.foldl_ι
-/

#print CliffordAlgebra.foldl_algebraMap /-
@[simp]
theorem foldl_algebraMap (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) (r : R) :
    foldl Q f hf n (algebraMap R _ r) = r • n := by
  rw [← foldr_reverse, reverse.commutes, foldr_algebra_map]
#align clifford_algebra.foldl_algebra_map CliffordAlgebra.foldl_algebraMap
-/

#print CliffordAlgebra.foldl_one /-
@[simp]
theorem foldl_one (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) : foldl Q f hf n 1 = n := by
  rw [← foldr_reverse, reverse.map_one, foldr_one]
#align clifford_algebra.foldl_one CliffordAlgebra.foldl_one
-/

#print CliffordAlgebra.foldl_mul /-
@[simp]
theorem foldl_mul (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) (a b : CliffordAlgebra Q) :
    foldl Q f hf n (a * b) = foldl Q f hf (foldl Q f hf n a) b := by
  rw [← foldr_reverse, ← foldr_reverse, ← foldr_reverse, reverse.map_mul, foldr_mul]
#align clifford_algebra.foldl_mul CliffordAlgebra.foldl_mul
-/

#print CliffordAlgebra.foldl_prod_map_ι /-
/-- This lemma demonstrates the origin of the `foldl` name. -/
theorem foldl_prod_map_ι (l : List M) (f : M →ₗ[R] N →ₗ[R] N) (hf) (n : N) :
    foldl Q f hf n (l.map <| ι Q).Prod = List.foldl (fun m n => f n m) n l := by
  rw [← foldr_reverse, reverse_prod_map_ι, ← List.map_reverse, foldr_prod_map_ι, List.foldr_reverse]
#align clifford_algebra.foldl_prod_map_ι CliffordAlgebra.foldl_prod_map_ι
-/

end Foldl

#print CliffordAlgebra.right_induction /-
theorem right_induction {P : CliffordAlgebra Q → Prop} (hr : ∀ r : R, P (algebraMap _ _ r))
    (h_add : ∀ x y, P x → P y → P (x + y)) (h_ι_mul : ∀ m x, P x → P (x * ι Q m)) : ∀ x, P x :=
  by
  /- It would be neat if we could prove this via `foldr` like how we prove
    `clifford_algebra.induction`, but going via the grading seems easier. -/
  intro x
  have : x ∈ ⊤ := Submodule.mem_top
  rw [← supr_ι_range_eq_top] at this 
  apply Submodule.iSup_induction _ this (fun i x hx => _) _ h_add
  · refine' Submodule.pow_induction_on_right _ hr h_add (fun x px m => _) hx
    rintro ⟨m, rfl⟩
    exact h_ι_mul _ _ px
  · simpa only [map_zero] using hr 0
#align clifford_algebra.right_induction CliffordAlgebra.right_induction
-/

#print CliffordAlgebra.left_induction /-
theorem left_induction {P : CliffordAlgebra Q → Prop} (hr : ∀ r : R, P (algebraMap _ _ r))
    (h_add : ∀ x y, P x → P y → P (x + y)) (h_mul_ι : ∀ x m, P x → P (ι Q m * x)) : ∀ x, P x :=
  by
  refine' reverse_involutive.surjective.forall.2 _
  intro x
  induction' x using CliffordAlgebra.right_induction with r x y hx hy m x hx
  · simpa only [reverse.commutes] using hr r
  · simpa only [map_add] using h_add _ _ hx hy
  · simpa only [reverse.map_mul, reverse_ι] using h_mul_ι _ _ hx
#align clifford_algebra.left_induction CliffordAlgebra.left_induction
-/

/-! ### Versions with extra state -/


#print CliffordAlgebra.foldr'Aux /-
/-- Auxiliary definition for `clifford_algebra.foldr'` -/
def foldr'Aux (f : M →ₗ[R] CliffordAlgebra Q × N →ₗ[R] N) :
    M →ₗ[R] Module.End R (CliffordAlgebra Q × N) :=
  by
  have v_mul := (Algebra.lmul R (CliffordAlgebra Q)).toLinearMap ∘ₗ ι Q
  have l := v_mul.compl₂ (LinearMap.fst _ _ N)
  exact
    { toFun := fun m => (l m).Prod (f m)
      map_add' := fun v₂ v₂ =>
        LinearMap.ext fun x =>
          Prod.ext (LinearMap.congr_fun (l.map_add _ _) x) (LinearMap.congr_fun (f.map_add _ _) x)
      map_smul' := fun c v =>
        LinearMap.ext fun x =>
          Prod.ext (LinearMap.congr_fun (l.map_smul _ _) x)
            (LinearMap.congr_fun (f.map_smul _ _) x) }
#align clifford_algebra.foldr'_aux CliffordAlgebra.foldr'Aux
-/

#print CliffordAlgebra.foldr'Aux_apply_apply /-
theorem foldr'Aux_apply_apply (f : M →ₗ[R] CliffordAlgebra Q × N →ₗ[R] N) (m : M) (x_fx) :
    foldr'Aux Q f m x_fx = (ι Q m * x_fx.1, f m x_fx) :=
  rfl
#align clifford_algebra.foldr'_aux_apply_apply CliffordAlgebra.foldr'Aux_apply_apply
-/

#print CliffordAlgebra.foldr'Aux_foldr'Aux /-
theorem foldr'Aux_foldr'Aux (f : M →ₗ[R] CliffordAlgebra Q × N →ₗ[R] N)
    (hf : ∀ m x fx, f m (ι Q m * x, f m (x, fx)) = Q m • fx) (v : M) (x_fx) :
    foldr'Aux Q f v (foldr'Aux Q f v x_fx) = Q v • x_fx :=
  by
  cases' x_fx with x fx
  simp only [foldr'_aux_apply_apply]
  rw [← mul_assoc, ι_sq_scalar, ← Algebra.smul_def, hf, Prod.smul_mk]
#align clifford_algebra.foldr'_aux_foldr'_aux CliffordAlgebra.foldr'Aux_foldr'Aux
-/

#print CliffordAlgebra.foldr' /-
/-- Fold a bilinear map along the generators of a term of the clifford algebra, with the rule
given by `foldr' Q f hf n (ι Q m * x) = f m (x, foldr' Q f hf n x)`.
Note this is like `clifford_algebra.foldr`, but with an extra `x` argument.
Implement the recursion scheme `F[n0](m * x) = f(m, (x, F[n0](x)))`. -/
def foldr' (f : M →ₗ[R] CliffordAlgebra Q × N →ₗ[R] N)
    (hf : ∀ m x fx, f m (ι Q m * x, f m (x, fx)) = Q m • fx) (n : N) : CliffordAlgebra Q →ₗ[R] N :=
  LinearMap.snd _ _ _ ∘ₗ foldr Q (foldr'Aux Q f) (foldr'Aux_foldr'Aux Q _ hf) (1, n)
#align clifford_algebra.foldr' CliffordAlgebra.foldr'
-/

#print CliffordAlgebra.foldr'_algebraMap /-
theorem foldr'_algebraMap (f : M →ₗ[R] CliffordAlgebra Q × N →ₗ[R] N)
    (hf : ∀ m x fx, f m (ι Q m * x, f m (x, fx)) = Q m • fx) (n r) :
    foldr' Q f hf n (algebraMap R _ r) = r • n :=
  congr_arg Prod.snd (foldr_algebraMap _ _ _ _ _)
#align clifford_algebra.foldr'_algebra_map CliffordAlgebra.foldr'_algebraMap
-/

#print CliffordAlgebra.foldr'_ι /-
theorem foldr'_ι (f : M →ₗ[R] CliffordAlgebra Q × N →ₗ[R] N)
    (hf : ∀ m x fx, f m (ι Q m * x, f m (x, fx)) = Q m • fx) (n m) :
    foldr' Q f hf n (ι Q m) = f m (1, n) :=
  congr_arg Prod.snd (foldr_ι _ _ _ _ _)
#align clifford_algebra.foldr'_ι CliffordAlgebra.foldr'_ι
-/

#print CliffordAlgebra.foldr'_ι_mul /-
theorem foldr'_ι_mul (f : M →ₗ[R] CliffordAlgebra Q × N →ₗ[R] N)
    (hf : ∀ m x fx, f m (ι Q m * x, f m (x, fx)) = Q m • fx) (n m) (x) :
    foldr' Q f hf n (ι Q m * x) = f m (x, foldr' Q f hf n x) :=
  by
  dsimp [foldr']
  rw [foldr_mul, foldr_ι, foldr'_aux_apply_apply]
  refine' congr_arg (f m) (prod.mk.eta.symm.trans _)
  congr 1
  induction' x using CliffordAlgebra.left_induction with r x y hx hy m x hx
  · simp_rw [foldr_algebra_map, Prod.smul_mk, Algebra.algebraMap_eq_smul_one]
  · rw [map_add, Prod.fst_add, hx, hy]
  · rw [foldr_mul, foldr_ι, foldr'_aux_apply_apply, hx]
#align clifford_algebra.foldr'_ι_mul CliffordAlgebra.foldr'_ι_mul
-/

end CliffordAlgebra

