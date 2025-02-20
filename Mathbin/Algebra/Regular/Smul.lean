/-
Copyright (c) 2021 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa

! This file was ported from Lean 3 source module algebra.regular.smul
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.SmulWithZero
import Mathbin.Algebra.Regular.Basic

/-!
# Action of regular elements on a module

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We introduce `M`-regular elements, in the context of an `R`-module `M`.  The corresponding
predicate is called `is_smul_regular`.

There are very limited typeclass assumptions on `R` and `M`, but the "mathematical" case of interest
is a commutative ring `R` acting an a module `M`. Since the properties are "multiplicative", there
is no actual requirement of having an addition, but there is a zero in both `R` and `M`.
Smultiplications involving `0` are, of course, all trivial.

The defining property is that an element `a ∈ R` is `M`-regular if the smultiplication map
`M → M`, defined by `m ↦ a • m`, is injective.

This property is the direct generalization to modules of the property `is_left_regular` defined in
`algebra/regular`.  Lemma `is_smul_regular.is_left_regular_iff` shows that indeed the two notions
coincide.
-/


variable {R S : Type _} (M : Type _) {a b : R} {s : S}

#print IsSMulRegular /-
/-- An `M`-regular element is an element `c` such that multiplication on the left by `c` is an
injective map `M → M`. -/
def IsSMulRegular [SMul R M] (c : R) :=
  Function.Injective ((· • ·) c : M → M)
#align is_smul_regular IsSMulRegular
-/

#print IsLeftRegular.isSMulRegular /-
theorem IsLeftRegular.isSMulRegular [Mul R] {c : R} (h : IsLeftRegular c) : IsSMulRegular R c :=
  h
#align is_left_regular.is_smul_regular IsLeftRegular.isSMulRegular
-/

#print isLeftRegular_iff /-
/-- Left-regular multiplication on `R` is equivalent to `R`-regularity of `R` itself. -/
theorem isLeftRegular_iff [Mul R] {a : R} : IsLeftRegular a ↔ IsSMulRegular R a :=
  Iff.rfl
#align is_left_regular_iff isLeftRegular_iff
-/

#print IsRightRegular.isSMulRegular /-
theorem IsRightRegular.isSMulRegular [Mul R] {c : R} (h : IsRightRegular c) :
    IsSMulRegular R (MulOpposite.op c) :=
  h
#align is_right_regular.is_smul_regular IsRightRegular.isSMulRegular
-/

#print isRightRegular_iff /-
/-- Right-regular multiplication on `R` is equivalent to `Rᵐᵒᵖ`-regularity of `R` itself. -/
theorem isRightRegular_iff [Mul R] {a : R} :
    IsRightRegular a ↔ IsSMulRegular R (MulOpposite.op a) :=
  Iff.rfl
#align is_right_regular_iff isRightRegular_iff
-/

namespace IsSMulRegular

variable {M}

section SMul

variable [SMul R M] [SMul R S] [SMul S M] [IsScalarTower R S M]

#print IsSMulRegular.smul /-
/-- The product of `M`-regular elements is `M`-regular. -/
theorem smul (ra : IsSMulRegular M a) (rs : IsSMulRegular M s) : IsSMulRegular M (a • s) :=
  fun a b ab => rs (ra ((smul_assoc _ _ _).symm.trans (ab.trans (smul_assoc _ _ _))))
#align is_smul_regular.smul IsSMulRegular.smul
-/

#print IsSMulRegular.of_smul /-
/-- If an element `b` becomes `M`-regular after multiplying it on the left by an `M`-regular
element, then `b` is `M`-regular. -/
theorem of_smul (a : R) (ab : IsSMulRegular M (a • s)) : IsSMulRegular M s :=
  @Function.Injective.of_comp _ _ _ (fun m : M => a • m) _ fun c d cd =>
    ab (by rwa [smul_assoc, smul_assoc])
#align is_smul_regular.of_smul IsSMulRegular.of_smul
-/

#print IsSMulRegular.smul_iff /-
/-- An element is `M`-regular if and only if multiplying it on the left by an `M`-regular element
is `M`-regular. -/
@[simp]
theorem smul_iff (b : S) (ha : IsSMulRegular M a) : IsSMulRegular M (a • b) ↔ IsSMulRegular M b :=
  ⟨of_smul _, ha.smul⟩
#align is_smul_regular.smul_iff IsSMulRegular.smul_iff
-/

#print IsSMulRegular.isLeftRegular /-
theorem isLeftRegular [Mul R] {a : R} (h : IsSMulRegular R a) : IsLeftRegular a :=
  h
#align is_smul_regular.is_left_regular IsSMulRegular.isLeftRegular
-/

#print IsSMulRegular.isRightRegular /-
theorem isRightRegular [Mul R] {a : R} (h : IsSMulRegular R (MulOpposite.op a)) :
    IsRightRegular a :=
  h
#align is_smul_regular.is_right_regular IsSMulRegular.isRightRegular
-/

#print IsSMulRegular.mul /-
theorem mul [Mul R] [IsScalarTower R R M] (ra : IsSMulRegular M a) (rb : IsSMulRegular M b) :
    IsSMulRegular M (a * b) :=
  ra.smul rb
#align is_smul_regular.mul IsSMulRegular.mul
-/

#print IsSMulRegular.of_mul /-
theorem of_mul [Mul R] [IsScalarTower R R M] (ab : IsSMulRegular M (a * b)) : IsSMulRegular M b :=
  by rw [← smul_eq_mul] at ab ; exact ab.of_smul _
#align is_smul_regular.of_mul IsSMulRegular.of_mul
-/

#print IsSMulRegular.mul_iff_right /-
@[simp]
theorem mul_iff_right [Mul R] [IsScalarTower R R M] (ha : IsSMulRegular M a) :
    IsSMulRegular M (a * b) ↔ IsSMulRegular M b :=
  ⟨of_mul, ha.mul⟩
#align is_smul_regular.mul_iff_right IsSMulRegular.mul_iff_right
-/

#print IsSMulRegular.mul_and_mul_iff /-
/-- Two elements `a` and `b` are `M`-regular if and only if both products `a * b` and `b * a`
are `M`-regular. -/
theorem mul_and_mul_iff [Mul R] [IsScalarTower R R M] :
    IsSMulRegular M (a * b) ∧ IsSMulRegular M (b * a) ↔ IsSMulRegular M a ∧ IsSMulRegular M b :=
  by
  refine' ⟨_, _⟩
  · rintro ⟨ab, ba⟩
    refine' ⟨ba.of_mul, ab.of_mul⟩
  · rintro ⟨ha, hb⟩
    exact ⟨ha.mul hb, hb.mul ha⟩
#align is_smul_regular.mul_and_mul_iff IsSMulRegular.mul_and_mul_iff
-/

end SMul

section Monoid

variable [Monoid R] [MulAction R M]

variable (M)

#print IsSMulRegular.one /-
/-- One is `M`-regular always. -/
@[simp]
theorem one : IsSMulRegular M (1 : R) := fun a b ab => by rwa [one_smul, one_smul] at ab 
#align is_smul_regular.one IsSMulRegular.one
-/

variable {M}

#print IsSMulRegular.of_mul_eq_one /-
/-- An element of `R` admitting a left inverse is `M`-regular. -/
theorem of_mul_eq_one (h : a * b = 1) : IsSMulRegular M b :=
  of_mul (by rw [h]; exact one M)
#align is_smul_regular.of_mul_eq_one IsSMulRegular.of_mul_eq_one
-/

#print IsSMulRegular.pow /-
/-- Any power of an `M`-regular element is `M`-regular. -/
theorem pow (n : ℕ) (ra : IsSMulRegular M a) : IsSMulRegular M (a ^ n) :=
  by
  induction' n with n hn
  · simp only [one, pow_zero]
  · rw [pow_succ]; exact (ra.smul_iff (a ^ n)).mpr hn
#align is_smul_regular.pow IsSMulRegular.pow
-/

#print IsSMulRegular.pow_iff /-
/-- An element `a` is `M`-regular if and only if a positive power of `a` is `M`-regular. -/
theorem pow_iff {n : ℕ} (n0 : 0 < n) : IsSMulRegular M (a ^ n) ↔ IsSMulRegular M a :=
  by
  refine' ⟨_, pow n⟩
  rw [← Nat.succ_pred_eq_of_pos n0, pow_succ', ← smul_eq_mul]
  exact of_smul _
#align is_smul_regular.pow_iff IsSMulRegular.pow_iff
-/

end Monoid

section MonoidSmul

variable [Monoid S] [SMul R M] [SMul R S] [MulAction S M] [IsScalarTower R S M]

#print IsSMulRegular.of_smul_eq_one /-
/-- An element of `S` admitting a left inverse in `R` is `M`-regular. -/
theorem of_smul_eq_one (h : a • s = 1) : IsSMulRegular M s :=
  of_smul a (by rw [h]; exact one M)
#align is_smul_regular.of_smul_eq_one IsSMulRegular.of_smul_eq_one
-/

end MonoidSmul

section MonoidWithZero

variable [MonoidWithZero R] [MonoidWithZero S] [Zero M] [MulActionWithZero R M]
  [MulActionWithZero R S] [MulActionWithZero S M] [IsScalarTower R S M]

#print IsSMulRegular.subsingleton /-
/-- The element `0` is `M`-regular if and only if `M` is trivial. -/
protected theorem subsingleton (h : IsSMulRegular M (0 : R)) : Subsingleton M :=
  ⟨fun a b => h (by repeat' rw [MulActionWithZero.zero_smul])⟩
#align is_smul_regular.subsingleton IsSMulRegular.subsingleton
-/

#print IsSMulRegular.zero_iff_subsingleton /-
/-- The element `0` is `M`-regular if and only if `M` is trivial. -/
theorem zero_iff_subsingleton : IsSMulRegular M (0 : R) ↔ Subsingleton M :=
  ⟨fun h => h.Subsingleton, fun H a b h => @Subsingleton.elim _ H a b⟩
#align is_smul_regular.zero_iff_subsingleton IsSMulRegular.zero_iff_subsingleton
-/

#print IsSMulRegular.not_zero_iff /-
/-- The `0` element is not `M`-regular, on a non-trivial module. -/
theorem not_zero_iff : ¬IsSMulRegular M (0 : R) ↔ Nontrivial M :=
  by
  rw [nontrivial_iff, not_iff_comm, zero_iff_subsingleton, subsingleton_iff]
  push_neg
  exact Iff.rfl
#align is_smul_regular.not_zero_iff IsSMulRegular.not_zero_iff
-/

#print IsSMulRegular.zero /-
/-- The element `0` is `M`-regular when `M` is trivial. -/
theorem zero [sM : Subsingleton M] : IsSMulRegular M (0 : R) :=
  zero_iff_subsingleton.mpr sM
#align is_smul_regular.zero IsSMulRegular.zero
-/

#print IsSMulRegular.not_zero /-
/-- The `0` element is not `M`-regular, on a non-trivial module. -/
theorem not_zero [nM : Nontrivial M] : ¬IsSMulRegular M (0 : R) :=
  not_zero_iff.mpr nM
#align is_smul_regular.not_zero IsSMulRegular.not_zero
-/

end MonoidWithZero

section CommSemigroup

variable [CommSemigroup R] [SMul R M] [IsScalarTower R R M]

#print IsSMulRegular.mul_iff /-
/-- A product is `M`-regular if and only if the factors are. -/
theorem mul_iff : IsSMulRegular M (a * b) ↔ IsSMulRegular M a ∧ IsSMulRegular M b :=
  by
  rw [← mul_and_mul_iff]
  exact ⟨fun ab => ⟨ab, by rwa [mul_comm]⟩, fun rab => rab.1⟩
#align is_smul_regular.mul_iff IsSMulRegular.mul_iff
-/

end CommSemigroup

end IsSMulRegular

section Group

variable {G : Type _} [Group G]

#print isSMulRegular_of_group /-
/-- An element of a group acting on a Type is regular. This relies on the availability
of the inverse given by groups, since there is no `left_cancel_smul` typeclass. -/
theorem isSMulRegular_of_group [MulAction G R] (g : G) : IsSMulRegular R g :=
  by
  intro x y h
  convert congr_arg ((· • ·) g⁻¹) h using 1 <;> simp [← smul_assoc]
#align is_smul_regular_of_group isSMulRegular_of_group
-/

end Group

section Units

variable [Monoid R] [MulAction R M]

#print Units.isSMulRegular /-
/-- Any element in `Rˣ` is `M`-regular. -/
theorem Units.isSMulRegular (a : Rˣ) : IsSMulRegular M (a : R) :=
  IsSMulRegular.of_mul_eq_one a.inv_val
#align units.is_smul_regular Units.isSMulRegular
-/

#print IsUnit.isSMulRegular /-
/-- A unit is `M`-regular. -/
theorem IsUnit.isSMulRegular (ua : IsUnit a) : IsSMulRegular M a :=
  by
  rcases ua with ⟨a, rfl⟩
  exact a.is_smul_regular M
#align is_unit.is_smul_regular IsUnit.isSMulRegular
-/

end Units

