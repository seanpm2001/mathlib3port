/-
Copyright (c) 2020 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser, Utensil Song

! This file was ported from Lean 3 source module linear_algebra.clifford_algebra.basic
! leanprover-community/mathlib commit 5d0c76894ada7940957143163d7b921345474cbc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.RingQuot
import Mathbin.LinearAlgebra.TensorAlgebra.Basic
import Mathbin.LinearAlgebra.QuadraticForm.Isometry

/-!
# Clifford Algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We construct the Clifford algebra of a module `M` over a commutative ring `R`, equipped with
a quadratic_form `Q`.

## Notation

The Clifford algebra of the `R`-module `M` equipped with a quadratic_form `Q` is
an `R`-algebra denoted `clifford_algebra Q`.

Given a linear morphism `f : M → A` from a module `M` to another `R`-algebra `A`, such that
`cond : ∀ m, f m * f m = algebra_map _ _ (Q m)`, there is a (unique) lift of `f` to an `R`-algebra
morphism from `clifford_algebra Q` to `A`, which is denoted `clifford_algebra.lift Q f cond`.

The canonical linear map `M → clifford_algebra Q` is denoted `clifford_algebra.ι Q`.

## Theorems

The main theorems proved ensure that `clifford_algebra Q` satisfies the universal property
of the Clifford algebra.
1. `ι_comp_lift` is the fact that the composition of `ι Q` with `lift Q f cond` agrees with `f`.
2. `lift_unique` ensures the uniqueness of `lift Q f cond` with respect to 1.

Additionally, when `Q = 0` an `alg_equiv` to the `exterior_algebra` is provided as `as_exterior`.

## Implementation details

The Clifford algebra of `M` is constructed as a quotient of the tensor algebra, as follows.
1. We define a relation `clifford_algebra.rel Q` on `tensor_algebra R M`.
   This is the smallest relation which identifies squares of elements of `M` with `Q m`.
2. The Clifford algebra is the quotient of the tensor algebra by this relation.

This file is almost identical to `linear_algebra/exterior_algebra.lean`.
-/


variable {R : Type _} [CommRing R]

variable {M : Type _} [AddCommGroup M] [Module R M]

variable (Q : QuadraticForm R M)

variable {n : ℕ}

namespace CliffordAlgebra

open TensorAlgebra

#print CliffordAlgebra.Rel /-
/-- `rel` relates each `ι m * ι m`, for `m : M`, with `Q m`.

The Clifford algebra of `M` is defined as the quotient modulo this relation.
-/
inductive Rel : TensorAlgebra R M → TensorAlgebra R M → Prop
  | of (m : M) : Rel (ι R m * ι R m) (algebraMap R _ (Q m))
#align clifford_algebra.rel CliffordAlgebra.Rel
-/

end CliffordAlgebra

/- ./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler algebra[algebra] R -/
#print CliffordAlgebra /-
/-- The Clifford algebra of an `R`-module `M` equipped with a quadratic_form `Q`.
-/
def CliffordAlgebra :=
  RingQuot (CliffordAlgebra.Rel Q)
deriving Inhabited, Ring,
  «./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler algebra[algebra] R»
#align clifford_algebra CliffordAlgebra
-/

namespace CliffordAlgebra

#print CliffordAlgebra.ι /-
/-- The canonical linear map `M →ₗ[R] clifford_algebra Q`.
-/
def ι : M →ₗ[R] CliffordAlgebra Q :=
  (RingQuot.mkAlgHom R _).toLinearMap.comp (TensorAlgebra.ι R)
#align clifford_algebra.ι CliffordAlgebra.ι
-/

#print CliffordAlgebra.ι_sq_scalar /-
/-- As well as being linear, `ι Q` squares to the quadratic form -/
@[simp]
theorem ι_sq_scalar (m : M) : ι Q m * ι Q m = algebraMap R _ (Q m) :=
  by
  erw [← AlgHom.map_mul, RingQuot.mkAlgHom_rel R (rel.of m), AlgHom.commutes]
  rfl
#align clifford_algebra.ι_sq_scalar CliffordAlgebra.ι_sq_scalar
-/

variable {Q} {A : Type _} [Semiring A] [Algebra R A]

#print CliffordAlgebra.comp_ι_sq_scalar /-
@[simp]
theorem comp_ι_sq_scalar (g : CliffordAlgebra Q →ₐ[R] A) (m : M) :
    g (ι Q m) * g (ι Q m) = algebraMap _ _ (Q m) := by
  rw [← AlgHom.map_mul, ι_sq_scalar, AlgHom.commutes]
#align clifford_algebra.comp_ι_sq_scalar CliffordAlgebra.comp_ι_sq_scalar
-/

variable (Q)

#print CliffordAlgebra.lift /-
/-- Given a linear map `f : M →ₗ[R] A` into an `R`-algebra `A`, which satisfies the condition:
`cond : ∀ m : M, f m * f m = Q(m)`, this is the canonical lift of `f` to a morphism of `R`-algebras
from `clifford_algebra Q` to `A`.
-/
@[simps symm_apply]
def lift : { f : M →ₗ[R] A // ∀ m, f m * f m = algebraMap _ _ (Q m) } ≃ (CliffordAlgebra Q →ₐ[R] A)
    where
  toFun f :=
    RingQuot.liftAlgHom R
      ⟨TensorAlgebra.lift R (f : M →ₗ[R] A), fun x y (h : Rel Q x y) =>
        by
        induction h
        rw [AlgHom.commutes, AlgHom.map_mul, TensorAlgebra.lift_ι_apply, f.prop]⟩
  invFun F :=
    ⟨F.toLinearMap.comp (ι Q), fun m => by
      rw [LinearMap.comp_apply, AlgHom.toLinearMap_apply, comp_ι_sq_scalar]⟩
  left_inv f := by
    ext
    simp only [ι, AlgHom.toLinearMap_apply, Function.comp_apply, LinearMap.coe_comp, Subtype.coe_mk,
      RingQuot.liftAlgHom_mkAlgHom_apply, TensorAlgebra.lift_ι_apply]
  right_inv F := by
    ext
    simp only [ι, AlgHom.comp_toLinearMap, AlgHom.toLinearMap_apply, Function.comp_apply,
      LinearMap.coe_comp, Subtype.coe_mk, RingQuot.liftAlgHom_mkAlgHom_apply,
      TensorAlgebra.lift_ι_apply]
#align clifford_algebra.lift CliffordAlgebra.lift
-/

variable {Q}

#print CliffordAlgebra.ι_comp_lift /-
@[simp]
theorem ι_comp_lift (f : M →ₗ[R] A) (cond : ∀ m, f m * f m = algebraMap _ _ (Q m)) :
    (lift Q ⟨f, cond⟩).toLinearMap.comp (ι Q) = f :=
  Subtype.mk_eq_mk.mp <| (lift Q).symm_apply_apply ⟨f, cond⟩
#align clifford_algebra.ι_comp_lift CliffordAlgebra.ι_comp_lift
-/

#print CliffordAlgebra.lift_ι_apply /-
@[simp]
theorem lift_ι_apply (f : M →ₗ[R] A) (cond : ∀ m, f m * f m = algebraMap _ _ (Q m)) (x) :
    lift Q ⟨f, cond⟩ (ι Q x) = f x :=
  (LinearMap.ext_iff.mp <| ι_comp_lift f cond) x
#align clifford_algebra.lift_ι_apply CliffordAlgebra.lift_ι_apply
-/

#print CliffordAlgebra.lift_unique /-
@[simp]
theorem lift_unique (f : M →ₗ[R] A) (cond : ∀ m : M, f m * f m = algebraMap _ _ (Q m))
    (g : CliffordAlgebra Q →ₐ[R] A) : g.toLinearMap.comp (ι Q) = f ↔ g = lift Q ⟨f, cond⟩ :=
  by
  convert (lift Q).symm_apply_eq
  rw [lift_symm_apply]
  simp only
#align clifford_algebra.lift_unique CliffordAlgebra.lift_unique
-/

#print CliffordAlgebra.lift_comp_ι /-
@[simp]
theorem lift_comp_ι (g : CliffordAlgebra Q →ₐ[R] A) :
    lift Q ⟨g.toLinearMap.comp (ι Q), comp_ι_sq_scalar _⟩ = g :=
  by
  convert (lift Q).apply_symm_apply g
  rw [lift_symm_apply]
  rfl
#align clifford_algebra.lift_comp_ι CliffordAlgebra.lift_comp_ι
-/

#print CliffordAlgebra.hom_ext /-
/-- See note [partially-applied ext lemmas]. -/
@[ext]
theorem hom_ext {A : Type _} [Semiring A] [Algebra R A] {f g : CliffordAlgebra Q →ₐ[R] A} :
    f.toLinearMap.comp (ι Q) = g.toLinearMap.comp (ι Q) → f = g :=
  by
  intro h
  apply (lift Q).symm.Injective
  rw [lift_symm_apply, lift_symm_apply]
  simp only [h]
#align clifford_algebra.hom_ext CliffordAlgebra.hom_ext
-/

#print CliffordAlgebra.induction /-
-- This proof closely follows `tensor_algebra.induction`
/-- If `C` holds for the `algebra_map` of `r : R` into `clifford_algebra Q`, the `ι` of `x : M`,
and is preserved under addition and muliplication, then it holds for all of `clifford_algebra Q`.

See also the stronger `clifford_algebra.left_induction` and `clifford_algebra.right_induction`.
-/
@[elab_as_elim]
theorem induction {C : CliffordAlgebra Q → Prop}
    (h_grade0 : ∀ r, C (algebraMap R (CliffordAlgebra Q) r)) (h_grade1 : ∀ x, C (ι Q x))
    (h_mul : ∀ a b, C a → C b → C (a * b)) (h_add : ∀ a b, C a → C b → C (a + b))
    (a : CliffordAlgebra Q) : C a :=
  by
  -- the arguments are enough to construct a subalgebra, and a mapping into it from M
  let s : Subalgebra R (CliffordAlgebra Q) :=
    { carrier := C
      mul_mem' := h_mul
      add_mem' := h_add
      algebraMap_mem' := h_grade0 }
  let of : { f : M →ₗ[R] s // ∀ m, f m * f m = algebraMap _ _ (Q m) } :=
    ⟨(ι Q).codRestrict s.to_submodule h_grade1, fun m => Subtype.eq <| ι_sq_scalar Q m⟩
  -- the mapping through the subalgebra is the identity
  have of_id : AlgHom.id R (CliffordAlgebra Q) = s.val.comp (lift Q of) :=
    by
    ext
    simp [of]
  -- finding a proof is finding an element of the subalgebra
  convert Subtype.prop (lift Q of a)
  exact AlgHom.congr_fun of_id a
#align clifford_algebra.induction CliffordAlgebra.induction
-/

#print CliffordAlgebra.ι_mul_ι_add_swap /-
/-- The symmetric product of vectors is a scalar -/
theorem ι_mul_ι_add_swap (a b : M) :
    ι Q a * ι Q b + ι Q b * ι Q a = algebraMap R _ (QuadraticForm.polar Q a b) :=
  calc
    ι Q a * ι Q b + ι Q b * ι Q a = ι Q (a + b) * ι Q (a + b) - ι Q a * ι Q a - ι Q b * ι Q b := by
      rw [(ι Q).map_add, mul_add, add_mul, add_mul]; abel
    _ = algebraMap R _ (Q (a + b)) - algebraMap R _ (Q a) - algebraMap R _ (Q b) := by
      rw [ι_sq_scalar, ι_sq_scalar, ι_sq_scalar]
    _ = algebraMap R _ (Q (a + b) - Q a - Q b) := by rw [← RingHom.map_sub, ← RingHom.map_sub]
    _ = algebraMap R _ (QuadraticForm.polar Q a b) := rfl
#align clifford_algebra.ι_mul_ι_add_swap CliffordAlgebra.ι_mul_ι_add_swap
-/

#print CliffordAlgebra.ι_mul_comm /-
theorem ι_mul_comm (a b : M) :
    ι Q a * ι Q b = algebraMap R _ (QuadraticForm.polar Q a b) - ι Q b * ι Q a :=
  eq_sub_of_add_eq (ι_mul_ι_add_swap a b)
#align clifford_algebra.ι_mul_comm CliffordAlgebra.ι_mul_comm
-/

#print CliffordAlgebra.ι_mul_ι_mul_ι /-
/-- $aba$ is a vector. -/
theorem ι_mul_ι_mul_ι (a b : M) :
    ι Q a * ι Q b * ι Q a = ι Q (QuadraticForm.polar Q a b • a - Q a • b) := by
  rw [ι_mul_comm, sub_mul, mul_assoc, ι_sq_scalar, ← Algebra.smul_def, ← Algebra.commutes, ←
    Algebra.smul_def, ← map_smul, ← map_smul, ← map_sub]
#align clifford_algebra.ι_mul_ι_mul_ι CliffordAlgebra.ι_mul_ι_mul_ι
-/

#print CliffordAlgebra.ι_range_map_lift /-
@[simp]
theorem ι_range_map_lift (f : M →ₗ[R] A) (cond : ∀ m, f m * f m = algebraMap _ _ (Q m)) :
    (ι Q).range.map (lift Q ⟨f, cond⟩).toLinearMap = f.range := by
  rw [← LinearMap.range_comp, ι_comp_lift]
#align clifford_algebra.ι_range_map_lift CliffordAlgebra.ι_range_map_lift
-/

section Map

variable {M₁ M₂ M₃ : Type _}

variable [AddCommGroup M₁] [AddCommGroup M₂] [AddCommGroup M₃]

variable [Module R M₁] [Module R M₂] [Module R M₃]

variable (Q₁ : QuadraticForm R M₁) (Q₂ : QuadraticForm R M₂) (Q₃ : QuadraticForm R M₃)

#print CliffordAlgebra.map /-
/-- Any linear map that preserves the quadratic form lifts to an `alg_hom` between algebras.

See `clifford_algebra.equiv_of_isometry` for the case when `f` is a `quadratic_form.isometry`. -/
def map (f : M₁ →ₗ[R] M₂) (hf : ∀ m, Q₂ (f m) = Q₁ m) :
    CliffordAlgebra Q₁ →ₐ[R] CliffordAlgebra Q₂ :=
  CliffordAlgebra.lift Q₁
    ⟨(CliffordAlgebra.ι Q₂).comp f, fun m => (ι_sq_scalar _ _).trans <| RingHom.congr_arg _ <| hf m⟩
#align clifford_algebra.map CliffordAlgebra.map
-/

#print CliffordAlgebra.map_comp_ι /-
@[simp]
theorem map_comp_ι (f : M₁ →ₗ[R] M₂) (hf) :
    (map Q₁ Q₂ f hf).toLinearMap.comp (ι Q₁) = (ι Q₂).comp f :=
  ι_comp_lift _ _
#align clifford_algebra.map_comp_ι CliffordAlgebra.map_comp_ι
-/

#print CliffordAlgebra.map_apply_ι /-
@[simp]
theorem map_apply_ι (f : M₁ →ₗ[R] M₂) (hf) (m : M₁) : map Q₁ Q₂ f hf (ι Q₁ m) = ι Q₂ (f m) :=
  lift_ι_apply _ _ m
#align clifford_algebra.map_apply_ι CliffordAlgebra.map_apply_ι
-/

#print CliffordAlgebra.map_id /-
@[simp]
theorem map_id :
    (map Q₁ Q₁ (LinearMap.id : M₁ →ₗ[R] M₁) fun m => rfl) = AlgHom.id R (CliffordAlgebra Q₁) := by
  ext m; exact map_apply_ι _ _ _ _ m
#align clifford_algebra.map_id CliffordAlgebra.map_id
-/

#print CliffordAlgebra.map_comp_map /-
@[simp]
theorem map_comp_map (f : M₂ →ₗ[R] M₃) (hf) (g : M₁ →ₗ[R] M₂) (hg) :
    (map Q₂ Q₃ f hf).comp (map Q₁ Q₂ g hg) = map Q₁ Q₃ (f.comp g) fun m => (hf _).trans <| hg m :=
  by
  ext m
  dsimp only [LinearMap.comp_apply, AlgHom.comp_apply, AlgHom.toLinearMap_apply, AlgHom.id_apply]
  rw [map_apply_ι, map_apply_ι, map_apply_ι, LinearMap.comp_apply]
#align clifford_algebra.map_comp_map CliffordAlgebra.map_comp_map
-/

#print CliffordAlgebra.ι_range_map_map /-
@[simp]
theorem ι_range_map_map (f : M₁ →ₗ[R] M₂) (hf : ∀ m, Q₂ (f m) = Q₁ m) :
    (ι Q₁).range.map (map Q₁ Q₂ f hf).toLinearMap = f.range.map (ι Q₂) :=
  (ι_range_map_lift _ _).trans (LinearMap.range_comp _ _)
#align clifford_algebra.ι_range_map_map CliffordAlgebra.ι_range_map_map
-/

variable {Q₁ Q₂ Q₃}

#print CliffordAlgebra.equivOfIsometry /-
/-- Two `clifford_algebra`s are equivalent as algebras if their quadratic forms are
equivalent. -/
@[simps apply]
def equivOfIsometry (e : Q₁.Isometry Q₂) : CliffordAlgebra Q₁ ≃ₐ[R] CliffordAlgebra Q₂ :=
  AlgEquiv.ofAlgHom (map Q₁ Q₂ e e.map_app) (map Q₂ Q₁ e.symm e.symm.map_app)
    ((map_comp_map _ _ _ _ _ _ _).trans <|
      by
      convert map_id _ using 2
      ext m
      exact e.to_linear_equiv.apply_symm_apply m)
    ((map_comp_map _ _ _ _ _ _ _).trans <|
      by
      convert map_id _ using 2
      ext m
      exact e.to_linear_equiv.symm_apply_apply m)
#align clifford_algebra.equiv_of_isometry CliffordAlgebra.equivOfIsometry
-/

#print CliffordAlgebra.equivOfIsometry_symm /-
@[simp]
theorem equivOfIsometry_symm (e : Q₁.Isometry Q₂) :
    (equivOfIsometry e).symm = equivOfIsometry e.symm :=
  rfl
#align clifford_algebra.equiv_of_isometry_symm CliffordAlgebra.equivOfIsometry_symm
-/

#print CliffordAlgebra.equivOfIsometry_trans /-
@[simp]
theorem equivOfIsometry_trans (e₁₂ : Q₁.Isometry Q₂) (e₂₃ : Q₂.Isometry Q₃) :
    (equivOfIsometry e₁₂).trans (equivOfIsometry e₂₃) = equivOfIsometry (e₁₂.trans e₂₃) := by ext x;
  exact AlgHom.congr_fun (map_comp_map Q₁ Q₂ Q₃ _ _ _ _) x
#align clifford_algebra.equiv_of_isometry_trans CliffordAlgebra.equivOfIsometry_trans
-/

#print CliffordAlgebra.equivOfIsometry_refl /-
@[simp]
theorem equivOfIsometry_refl :
    (equivOfIsometry <| QuadraticForm.Isometry.refl Q₁) = AlgEquiv.refl := by ext x;
  exact AlgHom.congr_fun (map_id Q₁) x
#align clifford_algebra.equiv_of_isometry_refl CliffordAlgebra.equivOfIsometry_refl
-/

end Map

variable (Q)

#print CliffordAlgebra.invertibleιOfInvertible /-
/-- If the quadratic form of a vector is invertible, then so is that vector. -/
def invertibleιOfInvertible (m : M) [Invertible (Q m)] : Invertible (ι Q m)
    where
  invOf := ι Q (⅟ (Q m) • m)
  invOf_mul_self := by
    rw [map_smul, smul_mul_assoc, ι_sq_scalar, Algebra.smul_def, ← map_mul, invOf_mul_self, map_one]
  mul_invOf_self := by
    rw [map_smul, mul_smul_comm, ι_sq_scalar, Algebra.smul_def, ← map_mul, invOf_mul_self, map_one]
#align clifford_algebra.invertible_ι_of_invertible CliffordAlgebra.invertibleιOfInvertible
-/

#print CliffordAlgebra.invOf_ι /-
/-- For a vector with invertible quadratic form, $v^{-1} = \frac{v}{Q(v)}$ -/
theorem invOf_ι (m : M) [Invertible (Q m)] [Invertible (ι Q m)] : ⅟ (ι Q m) = ι Q (⅟ (Q m) • m) :=
  by
  letI := invertible_ι_of_invertible Q m
  convert (rfl : ⅟ (ι Q m) = _)
#align clifford_algebra.inv_of_ι CliffordAlgebra.invOf_ι
-/

#print CliffordAlgebra.isUnit_ι_of_isUnit /-
theorem isUnit_ι_of_isUnit {m : M} (h : IsUnit (Q m)) : IsUnit (ι Q m) :=
  by
  cases h.nonempty_invertible
  letI := invertible_ι_of_invertible Q m
  exact isUnit_of_invertible (ι Q m)
#align clifford_algebra.is_unit_ι_of_is_unit CliffordAlgebra.isUnit_ι_of_isUnit
-/

#print CliffordAlgebra.ι_mul_ι_mul_invOf_ι /-
/-- $aba^{-1}$ is a vector. -/
theorem ι_mul_ι_mul_invOf_ι (a b : M) [Invertible (ι Q a)] [Invertible (Q a)] :
    ι Q a * ι Q b * ⅟ (ι Q a) = ι Q ((⅟ (Q a) * QuadraticForm.polar Q a b) • a - b) := by
  rw [inv_of_ι, map_smul, mul_smul_comm, ι_mul_ι_mul_ι, ← map_smul, smul_sub, smul_smul, smul_smul,
    invOf_mul_self, one_smul]
#align clifford_algebra.ι_mul_ι_mul_inv_of_ι CliffordAlgebra.ι_mul_ι_mul_invOf_ι
-/

#print CliffordAlgebra.invOf_ι_mul_ι_mul_ι /-
/-- $a^{-1}ba$ is a vector. -/
theorem invOf_ι_mul_ι_mul_ι (a b : M) [Invertible (ι Q a)] [Invertible (Q a)] :
    ⅟ (ι Q a) * ι Q b * ι Q a = ι Q ((⅟ (Q a) * QuadraticForm.polar Q a b) • a - b) := by
  rw [inv_of_ι, map_smul, smul_mul_assoc, smul_mul_assoc, ι_mul_ι_mul_ι, ← map_smul, smul_sub,
    smul_smul, smul_smul, invOf_mul_self, one_smul]
#align clifford_algebra.inv_of_ι_mul_ι_mul_ι CliffordAlgebra.invOf_ι_mul_ι_mul_ι
-/

end CliffordAlgebra

namespace TensorAlgebra

variable {Q}

#print TensorAlgebra.toClifford /-
/-- The canonical image of the `tensor_algebra` in the `clifford_algebra`, which maps
`tensor_algebra.ι R x` to `clifford_algebra.ι Q x`. -/
def toClifford : TensorAlgebra R M →ₐ[R] CliffordAlgebra Q :=
  TensorAlgebra.lift R (CliffordAlgebra.ι Q)
#align tensor_algebra.to_clifford TensorAlgebra.toClifford
-/

#print TensorAlgebra.toClifford_ι /-
@[simp]
theorem toClifford_ι (m : M) : (TensorAlgebra.ι R m).toClifford = CliffordAlgebra.ι Q m := by
  simp [to_clifford]
#align tensor_algebra.to_clifford_ι TensorAlgebra.toClifford_ι
-/

end TensorAlgebra

