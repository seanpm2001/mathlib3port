/-
Copyright © 2020 Nicolò Cavalleri. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nicolò Cavalleri, Andrew Yang

! This file was ported from Lean 3 source module ring_theory.derivation.basic
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Adjoin.Basic

/-!
# Derivations

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines derivation. A derivation `D` from the `R`-algebra `A` to the `A`-module `M` is an
`R`-linear map that satisfy the Leibniz rule `D (a * b) = a * D b + D a * b`.

## Main results

- `derivation`: The type of `R`-derivations from `A` to `M`. This has an `A`-module structure.
- `derivation.llcomp`: We may compose linear maps and derivations to obtain a derivation,
  and the composition is bilinear.

See `ring_theory.derivation.lie` for
- `derivation.lie_algebra`: The `R`-derivations from `A` to `A` form an lie algebra over `R`.

and `ring_theory.derivation.to_square_zero` for
- `derivation_to_square_zero_equiv_lift`: The `R`-derivations from `A` into a square-zero ideal `I`
  of `B` corresponds to the lifts `A →ₐ[R] B` of the map `A →ₐ[R] B ⧸ I`.

## Future project

- Generalize derivations into bimodules.

-/


open Algebra

open scoped BigOperators

#print Derivation /-
/-- `D : derivation R A M` is an `R`-linear map from `A` to `M` that satisfies the `leibniz`
equality. We also require that `D 1 = 0`. See `derivation.mk'` for a constructor that deduces this
assumption from the Leibniz rule when `M` is cancellative.

TODO: update this when bimodules are defined. -/
@[protect_proj]
structure Derivation (R : Type _) (A : Type _) [CommSemiring R] [CommSemiring A] [Algebra R A]
    (M : Type _) [AddCommMonoid M] [Module A M] [Module R M] extends A →ₗ[R] M where
  map_one_eq_zero' : to_linear_map 1 = 0
  leibniz' (a b : A) : to_linear_map (a * b) = a • to_linear_map b + b • to_linear_map a
#align derivation Derivation
-/

/-- The `linear_map` underlying a `derivation`. -/
add_decl_doc Derivation.toLinearMap

namespace Derivation

section

variable {R : Type _} [CommSemiring R]

variable {A : Type _} [CommSemiring A] [Algebra R A]

variable {M : Type _} [AddCommMonoid M] [Module A M] [Module R M]

variable (D : Derivation R A M) {D1 D2 : Derivation R A M} (r : R) (a b : A)

instance : AddMonoidHomClass (Derivation R A M) A M
    where
  coe D := D.toFun
  coe_injective' D1 D2 h := by cases D1; cases D2; congr; exact FunLike.coe_injective h
  map_add D := D.toLinearMap.map_add'
  map_zero D := D.toLinearMap.map_zero

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (Derivation R A M) fun _ => A → M :=
  ⟨fun D => D.toLinearMap.toFun⟩

#print Derivation.toFun_eq_coe /-
-- Not a simp lemma because it can be proved via `coe_fn_coe` + `to_linear_map_eq_coe`
theorem toFun_eq_coe : D.toFun = ⇑D :=
  rfl
#align derivation.to_fun_eq_coe Derivation.toFun_eq_coe
-/

#print Derivation.hasCoeToLinearMap /-
instance hasCoeToLinearMap : Coe (Derivation R A M) (A →ₗ[R] M) :=
  ⟨fun D => D.toLinearMap⟩
#align derivation.has_coe_to_linear_map Derivation.hasCoeToLinearMap
-/

@[simp]
theorem toLinearMap_eq_coe : D.toLinearMap = D :=
  rfl
#align derivation.to_linear_map_eq_coe Derivation.toLinearMap_eq_coe

#print Derivation.mk_coe /-
@[simp]
theorem mk_coe (f : A →ₗ[R] M) (h₁ h₂) : ((⟨f, h₁, h₂⟩ : Derivation R A M) : A → M) = f :=
  rfl
#align derivation.mk_coe Derivation.mk_coe
-/

#print Derivation.coeFn_coe /-
@[simp, norm_cast]
theorem coeFn_coe (f : Derivation R A M) : ⇑(f : A →ₗ[R] M) = f :=
  rfl
#align derivation.coe_fn_coe Derivation.coeFn_coe
-/

#print Derivation.coe_injective /-
theorem coe_injective : @Function.Injective (Derivation R A M) (A → M) coeFn :=
  FunLike.coe_injective
#align derivation.coe_injective Derivation.coe_injective
-/

#print Derivation.ext /-
@[ext]
theorem ext (H : ∀ a, D1 a = D2 a) : D1 = D2 :=
  FunLike.ext _ _ H
#align derivation.ext Derivation.ext
-/

#print Derivation.congr_fun /-
theorem congr_fun (h : D1 = D2) (a : A) : D1 a = D2 a :=
  FunLike.congr_fun h a
#align derivation.congr_fun Derivation.congr_fun
-/

#print Derivation.map_add /-
protected theorem map_add : D (a + b) = D a + D b :=
  map_add D a b
#align derivation.map_add Derivation.map_add
-/

#print Derivation.map_zero /-
protected theorem map_zero : D 0 = 0 :=
  map_zero D
#align derivation.map_zero Derivation.map_zero
-/

#print Derivation.map_smul /-
@[simp]
theorem map_smul : D (r • a) = r • D a :=
  D.toLinearMap.map_smul r a
#align derivation.map_smul Derivation.map_smul
-/

#print Derivation.leibniz /-
@[simp]
theorem leibniz : D (a * b) = a • D b + b • D a :=
  D.leibniz' _ _
#align derivation.leibniz Derivation.leibniz
-/

#print Derivation.map_sum /-
theorem map_sum {ι : Type _} (s : Finset ι) (f : ι → A) : D (∑ i in s, f i) = ∑ i in s, D (f i) :=
  D.toLinearMap.map_sum
#align derivation.map_sum Derivation.map_sum
-/

#print Derivation.map_smul_of_tower /-
@[simp]
theorem map_smul_of_tower {S : Type _} [SMul S A] [SMul S M] [LinearMap.CompatibleSMul A M S R]
    (D : Derivation R A M) (r : S) (a : A) : D (r • a) = r • D a :=
  D.toLinearMap.map_smul_of_tower r a
#align derivation.map_smul_of_tower Derivation.map_smul_of_tower
-/

#print Derivation.map_one_eq_zero /-
@[simp]
theorem map_one_eq_zero : D 1 = 0 :=
  D.map_one_eq_zero'
#align derivation.map_one_eq_zero Derivation.map_one_eq_zero
-/

#print Derivation.map_algebraMap /-
@[simp]
theorem map_algebraMap : D (algebraMap R A r) = 0 := by
  rw [← mul_one r, RingHom.map_mul, RingHom.map_one, ← smul_def, map_smul, map_one_eq_zero,
    smul_zero]
#align derivation.map_algebra_map Derivation.map_algebraMap
-/

#print Derivation.map_coe_nat /-
@[simp]
theorem map_coe_nat (n : ℕ) : D (n : A) = 0 := by
  rw [← nsmul_one, D.map_smul_of_tower n, map_one_eq_zero, smul_zero]
#align derivation.map_coe_nat Derivation.map_coe_nat
-/

#print Derivation.leibniz_pow /-
@[simp]
theorem leibniz_pow (n : ℕ) : D (a ^ n) = n • a ^ (n - 1) • D a :=
  by
  induction' n with n ihn
  · rw [pow_zero, map_one_eq_zero, zero_smul]
  · rcases(zero_le n).eq_or_lt with (rfl | hpos)
    · rw [pow_one, one_smul, pow_zero, one_smul]
    · have : a * a ^ (n - 1) = a ^ n := by rw [← pow_succ, Nat.sub_add_cancel hpos]
      simp only [pow_succ, leibniz, ihn, smul_comm a n, smul_smul a, add_smul, this,
        Nat.succ_eq_add_one, Nat.add_succ_sub_one, add_zero, one_nsmul]
#align derivation.leibniz_pow Derivation.leibniz_pow
-/

#print Derivation.eqOn_adjoin /-
theorem eqOn_adjoin {s : Set A} (h : Set.EqOn D1 D2 s) : Set.EqOn D1 D2 (adjoin R s) := fun x hx =>
  Algebra.adjoin_induction hx h (fun r => (D1.map_algebraMap r).trans (D2.map_algebraMap r).symm)
    (fun x y hx hy => by simp only [map_add, *]) fun x y hx hy => by simp only [leibniz, *]
#align derivation.eq_on_adjoin Derivation.eqOn_adjoin
-/

#print Derivation.ext_of_adjoin_eq_top /-
/-- If adjoin of a set is the whole algebra, then any two derivations equal on this set are equal
on the whole algebra. -/
theorem ext_of_adjoin_eq_top (s : Set A) (hs : adjoin R s = ⊤) (h : Set.EqOn D1 D2 s) : D1 = D2 :=
  ext fun a => eqOn_adjoin h <| hs.symm ▸ trivial
#align derivation.ext_of_adjoin_eq_top Derivation.ext_of_adjoin_eq_top
-/

-- Data typeclasses
instance : Zero (Derivation R A M) :=
  ⟨{  toLinearMap := 0
      map_one_eq_zero' := rfl
      leibniz' := fun a b => by simp only [add_zero, LinearMap.zero_apply, smul_zero] }⟩

#print Derivation.coe_zero /-
@[simp]
theorem coe_zero : ⇑(0 : Derivation R A M) = 0 :=
  rfl
#align derivation.coe_zero Derivation.coe_zero
-/

#print Derivation.coe_zero_linearMap /-
@[simp]
theorem coe_zero_linearMap : ↑(0 : Derivation R A M) = (0 : A →ₗ[R] M) :=
  rfl
#align derivation.coe_zero_linear_map Derivation.coe_zero_linearMap
-/

#print Derivation.zero_apply /-
theorem zero_apply (a : A) : (0 : Derivation R A M) a = 0 :=
  rfl
#align derivation.zero_apply Derivation.zero_apply
-/

instance : Add (Derivation R A M) :=
  ⟨fun D1 D2 =>
    { toLinearMap := D1 + D2
      map_one_eq_zero' := by simp
      leibniz' := fun a b => by
        simp only [leibniz, LinearMap.add_apply, coe_fn_coe, smul_add, add_add_add_comm] }⟩

#print Derivation.coe_add /-
@[simp]
theorem coe_add (D1 D2 : Derivation R A M) : ⇑(D1 + D2) = D1 + D2 :=
  rfl
#align derivation.coe_add Derivation.coe_add
-/

#print Derivation.coe_add_linearMap /-
@[simp]
theorem coe_add_linearMap (D1 D2 : Derivation R A M) : ↑(D1 + D2) = (D1 + D2 : A →ₗ[R] M) :=
  rfl
#align derivation.coe_add_linear_map Derivation.coe_add_linearMap
-/

#print Derivation.add_apply /-
theorem add_apply : (D1 + D2) a = D1 a + D2 a :=
  rfl
#align derivation.add_apply Derivation.add_apply
-/

instance : Inhabited (Derivation R A M) :=
  ⟨0⟩

section Scalar

variable {S T : Type _}

variable [Monoid S] [DistribMulAction S M] [SMulCommClass R S M] [SMulCommClass S A M]

variable [Monoid T] [DistribMulAction T M] [SMulCommClass R T M] [SMulCommClass T A M]

instance (priority := 100) : SMul S (Derivation R A M) :=
  ⟨fun r D =>
    { toLinearMap := r • D
      map_one_eq_zero' := by rw [LinearMap.smul_apply, coe_fn_coe, D.map_one_eq_zero, smul_zero]
      leibniz' := fun a b => by
        simp only [LinearMap.smul_apply, coe_fn_coe, leibniz, smul_add, smul_comm r] }⟩

#print Derivation.coe_smul /-
@[simp]
theorem coe_smul (r : S) (D : Derivation R A M) : ⇑(r • D) = r • D :=
  rfl
#align derivation.coe_smul Derivation.coe_smul
-/

#print Derivation.coe_smul_linearMap /-
@[simp]
theorem coe_smul_linearMap (r : S) (D : Derivation R A M) : ↑(r • D) = (r • D : A →ₗ[R] M) :=
  rfl
#align derivation.coe_smul_linear_map Derivation.coe_smul_linearMap
-/

#print Derivation.smul_apply /-
theorem smul_apply (r : S) (D : Derivation R A M) : (r • D) a = r • D a :=
  rfl
#align derivation.smul_apply Derivation.smul_apply
-/

instance : AddCommMonoid (Derivation R A M) :=
  coe_injective.AddCommMonoid _ coe_zero coe_add fun _ _ => rfl

#print Derivation.coeFnAddMonoidHom /-
/-- `coe_fn` as an `add_monoid_hom`. -/
def coeFnAddMonoidHom : Derivation R A M →+ A → M
    where
  toFun := coeFn
  map_zero' := coe_zero
  map_add' := coe_add
#align derivation.coe_fn_add_monoid_hom Derivation.coeFnAddMonoidHom
-/

instance (priority := 100) : DistribMulAction S (Derivation R A M) :=
  Function.Injective.distribMulAction coeFnAddMonoidHom coe_injective coe_smul

instance [DistribMulAction Sᵐᵒᵖ M] [IsCentralScalar S M] : IsCentralScalar S (Derivation R A M)
    where op_smul_eq_smul _ _ := ext fun _ => op_smul_eq_smul _ _

instance [SMul S T] [IsScalarTower S T M] : IsScalarTower S T (Derivation R A M) :=
  ⟨fun x y z => ext fun a => smul_assoc _ _ _⟩

instance [SMulCommClass S T M] : SMulCommClass S T (Derivation R A M) :=
  ⟨fun x y z => ext fun a => smul_comm _ _ _⟩

end Scalar

instance (priority := 100) {S : Type _} [Semiring S] [Module S M] [SMulCommClass R S M]
    [SMulCommClass S A M] : Module S (Derivation R A M) :=
  Function.Injective.module S coeFnAddMonoidHom coe_injective coe_smul

section PushForward

variable {N : Type _} [AddCommMonoid N] [Module A N] [Module R N] [IsScalarTower R A M]
  [IsScalarTower R A N]

variable (f : M →ₗ[A] N) (e : M ≃ₗ[A] N)

#print LinearMap.compDer /-
/-- We can push forward derivations using linear maps, i.e., the composition of a derivation with a
linear map is a derivation. Furthermore, this operation is linear on the spaces of derivations. -/
def LinearMap.compDer : Derivation R A M →ₗ[R] Derivation R A N
    where
  toFun D :=
    { toLinearMap := (f : M →ₗ[R] N).comp (D : A →ₗ[R] M)
      map_one_eq_zero' := by simp only [LinearMap.comp_apply, coe_fn_coe, map_one_eq_zero, map_zero]
      leibniz' := fun a b => by
        simp only [coe_fn_coe, LinearMap.comp_apply, LinearMap.map_add, leibniz,
          LinearMap.coe_restrictScalars, LinearMap.map_smul] }
  map_add' D₁ D₂ := by ext; exact LinearMap.map_add _ _ _
  map_smul' r D := by ext; exact LinearMap.map_smul _ _ _
#align linear_map.comp_der LinearMap.compDer
-/

#print Derivation.coe_to_linearMap_comp /-
@[simp]
theorem coe_to_linearMap_comp : (f.compDer D : A →ₗ[R] N) = (f : M →ₗ[R] N).comp (D : A →ₗ[R] M) :=
  rfl
#align derivation.coe_to_linear_map_comp Derivation.coe_to_linearMap_comp
-/

#print Derivation.coe_comp /-
@[simp]
theorem coe_comp : (f.compDer D : A → N) = (f : M →ₗ[R] N).comp (D : A →ₗ[R] M) :=
  rfl
#align derivation.coe_comp Derivation.coe_comp
-/

#print Derivation.llcomp /-
/-- The composition of a derivation with a linear map as a bilinear map -/
@[simps]
def llcomp : (M →ₗ[A] N) →ₗ[A] Derivation R A M →ₗ[R] Derivation R A N
    where
  toFun f := f.compDer
  map_add' f₁ f₂ := by ext; rfl
  map_smul' r D := by ext; rfl
#align derivation.llcomp Derivation.llcomp
-/

#print LinearEquiv.compDer /-
/-- Pushing a derivation foward through a linear equivalence is an equivalence. -/
def LinearEquiv.compDer : Derivation R A M ≃ₗ[R] Derivation R A N :=
  { e.toLinearMap.compDer with
    invFun := e.symm.toLinearMap.compDer
    left_inv := fun D => by ext a; exact e.symm_apply_apply (D a)
    right_inv := fun D => by ext a; exact e.apply_symm_apply (D a) }
#align linear_equiv.comp_der LinearEquiv.compDer
-/

end PushForward

section RestrictScalars

variable {S : Type _} [CommSemiring S]

variable [Algebra S A] [Module S M] [LinearMap.CompatibleSMul A M R S]

variable (R)

#print Derivation.restrictScalars /-
/-- If `A` is both an `R`-algebra and an `S`-algebra; `M` is both an `R`-module and an `S`-module,
then an `S`-derivation `A → M` is also an `R`-derivation if it is also `R`-linear. -/
protected def restrictScalars (d : Derivation S A M) : Derivation R A M
    where
  map_one_eq_zero' := d.map_one_eq_zero
  leibniz' := d.leibniz
  toLinearMap := d.toLinearMap.restrictScalars R
#align derivation.restrict_scalars Derivation.restrictScalars
-/

end RestrictScalars

end

section Cancel

variable {R : Type _} [CommSemiring R] {A : Type _} [CommSemiring A] [Algebra R A] {M : Type _}
  [AddCancelCommMonoid M] [Module R M] [Module A M]

#print Derivation.mk' /-
/-- Define `derivation R A M` from a linear map when `M` is cancellative by verifying the Leibniz
rule. -/
def mk' (D : A →ₗ[R] M) (h : ∀ a b, D (a * b) = a • D b + b • D a) : Derivation R A M
    where
  toLinearMap := D
  map_one_eq_zero' := add_right_eq_self.1 <| by simpa only [one_smul, one_mul] using (h 1 1).symm
  leibniz' := h
#align derivation.mk' Derivation.mk'
-/

#print Derivation.coe_mk' /-
@[simp]
theorem coe_mk' (D : A →ₗ[R] M) (h) : ⇑(mk' D h) = D :=
  rfl
#align derivation.coe_mk' Derivation.coe_mk'
-/

#print Derivation.coe_mk'_linearMap /-
@[simp]
theorem coe_mk'_linearMap (D : A →ₗ[R] M) (h) : (mk' D h : A →ₗ[R] M) = D :=
  rfl
#align derivation.coe_mk'_linear_map Derivation.coe_mk'_linearMap
-/

end Cancel

section

variable {R : Type _} [CommRing R]

variable {A : Type _} [CommRing A] [Algebra R A]

section

variable {M : Type _} [AddCommGroup M] [Module A M] [Module R M]

variable (D : Derivation R A M) {D1 D2 : Derivation R A M} (r : R) (a b : A)

#print Derivation.map_neg /-
protected theorem map_neg : D (-a) = -D a :=
  map_neg D a
#align derivation.map_neg Derivation.map_neg
-/

#print Derivation.map_sub /-
protected theorem map_sub : D (a - b) = D a - D b :=
  map_sub D a b
#align derivation.map_sub Derivation.map_sub
-/

#print Derivation.map_coe_int /-
@[simp]
theorem map_coe_int (n : ℤ) : D (n : A) = 0 := by
  rw [← zsmul_one, D.map_smul_of_tower n, map_one_eq_zero, smul_zero]
#align derivation.map_coe_int Derivation.map_coe_int
-/

#print Derivation.leibniz_of_mul_eq_one /-
theorem leibniz_of_mul_eq_one {a b : A} (h : a * b = 1) : D a = -a ^ 2 • D b :=
  by
  rw [neg_smul]
  refine' eq_neg_of_add_eq_zero_left _
  calc
    D a + a ^ 2 • D b = a • b • D a + a • a • D b := by simp only [smul_smul, h, one_smul, sq]
    _ = a • D (a * b) := by rw [leibniz, smul_add, add_comm]
    _ = 0 := by rw [h, map_one_eq_zero, smul_zero]
#align derivation.leibniz_of_mul_eq_one Derivation.leibniz_of_mul_eq_one
-/

#print Derivation.leibniz_invOf /-
theorem leibniz_invOf [Invertible a] : D (⅟ a) = -⅟ a ^ 2 • D a :=
  D.leibniz_of_mul_eq_one <| invOf_mul_self a
#align derivation.leibniz_inv_of Derivation.leibniz_invOf
-/

#print Derivation.leibniz_inv /-
theorem leibniz_inv {K : Type _} [Field K] [Module K M] [Algebra R K] (D : Derivation R K M)
    (a : K) : D a⁻¹ = -a⁻¹ ^ 2 • D a :=
  by
  rcases eq_or_ne a 0 with (rfl | ha)
  · simp
  · exact D.leibniz_of_mul_eq_one (inv_mul_cancel ha)
#align derivation.leibniz_inv Derivation.leibniz_inv
-/

instance : Neg (Derivation R A M) :=
  ⟨fun D =>
    mk' (-D) fun a b => by
      simp only [LinearMap.neg_apply, smul_neg, neg_add_rev, leibniz, coe_fn_coe, add_comm]⟩

#print Derivation.coe_neg /-
@[simp]
theorem coe_neg (D : Derivation R A M) : ⇑(-D) = -D :=
  rfl
#align derivation.coe_neg Derivation.coe_neg
-/

#print Derivation.coe_neg_linearMap /-
@[simp]
theorem coe_neg_linearMap (D : Derivation R A M) : ↑(-D) = (-D : A →ₗ[R] M) :=
  rfl
#align derivation.coe_neg_linear_map Derivation.coe_neg_linearMap
-/

#print Derivation.neg_apply /-
theorem neg_apply : (-D) a = -D a :=
  rfl
#align derivation.neg_apply Derivation.neg_apply
-/

instance : Sub (Derivation R A M) :=
  ⟨fun D1 D2 =>
    mk' (D1 - D2 : A →ₗ[R] M) fun a b => by
      simp only [LinearMap.sub_apply, leibniz, coe_fn_coe, smul_sub, add_sub_add_comm]⟩

#print Derivation.coe_sub /-
@[simp]
theorem coe_sub (D1 D2 : Derivation R A M) : ⇑(D1 - D2) = D1 - D2 :=
  rfl
#align derivation.coe_sub Derivation.coe_sub
-/

#print Derivation.coe_sub_linearMap /-
@[simp]
theorem coe_sub_linearMap (D1 D2 : Derivation R A M) : ↑(D1 - D2) = (D1 - D2 : A →ₗ[R] M) :=
  rfl
#align derivation.coe_sub_linear_map Derivation.coe_sub_linearMap
-/

#print Derivation.sub_apply /-
theorem sub_apply : (D1 - D2) a = D1 a - D2 a :=
  rfl
#align derivation.sub_apply Derivation.sub_apply
-/

instance : AddCommGroup (Derivation R A M) :=
  coe_injective.AddCommGroup _ coe_zero coe_add coe_neg coe_sub (fun _ _ => rfl) fun _ _ => rfl

end

end

end Derivation

