/-
Copyright (c) 2021 Frédéric Dupuis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Frédéric Dupuis

! This file was ported from Lean 3 source module algebra.star.self_adjoint
! leanprover-community/mathlib commit a6ece35404f60597c651689c1b46ead86de5ac1b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Star.Basic
import Mathbin.GroupTheory.Subgroup.Basic

/-!
# Self-adjoint, skew-adjoint and normal elements of a star additive group

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines `self_adjoint R` (resp. `skew_adjoint R`), where `R` is a star additive group,
as the additive subgroup containing the elements that satisfy `star x = x` (resp. `star x = -x`).
This includes, for instance, (skew-)Hermitian operators on Hilbert spaces.

We also define `is_star_normal R`, a `Prop` that states that an element `x` satisfies
`star x * x = x * star x`.

## Implementation notes

* When `R` is a `star_module R₂ R`, then `self_adjoint R` has a natural
  `module (self_adjoint R₂) (self_adjoint R)` structure. However, doing this literally would be
  undesirable since in the main case of interest (`R₂ = ℂ`) we want `module ℝ (self_adjoint R)`
  and not `module (self_adjoint ℂ) (self_adjoint R)`. We solve this issue by adding the typeclass
  `[has_trivial_star R₃]`, of which `ℝ` is an instance (registered in `data/real/basic`), and then
  add a `[module R₃ (self_adjoint R)]` instance whenever we have
  `[module R₃ R] [has_trivial_star R₃]`. (Another approach would have been to define
  `[star_invariant_scalars R₃ R]` to express the fact that `star (x • v) = x • star v`, but
  this typeclass would have the disadvantage of taking two type arguments.)

## TODO

* Define `is_skew_adjoint` to match `is_self_adjoint`.
* Define `λ z x, z * x * star z` (i.e. conjugation by `z`) as a monoid action of `R` on `R`
  (similar to the existing `conj_act` for groups), and then state the fact that `self_adjoint R` is
  invariant under it.

-/


variable {R A : Type _}

#print IsSelfAdjoint /-
/-- An element is self-adjoint if it is equal to its star. -/
def IsSelfAdjoint [Star R] (x : R) : Prop :=
  star x = x
#align is_self_adjoint IsSelfAdjoint
-/

#print IsStarNormal /-
/-- An element of a star monoid is normal if it commutes with its adjoint. -/
class IsStarNormal [Mul R] [Star R] (x : R) : Prop where
  star_comm_self : Commute (star x) x
#align is_star_normal IsStarNormal
-/

export IsStarNormal (star_comm_self)

#print star_comm_self' /-
theorem star_comm_self' [Mul R] [Star R] (x : R) [IsStarNormal x] : star x * x = x * star x :=
  IsStarNormal.star_comm_self
#align star_comm_self' star_comm_self'
-/

namespace IsSelfAdjoint

#print IsSelfAdjoint.all /-
-- named to match `commute.all`
/-- All elements are self-adjoint when `star` is trivial. -/
theorem all [Star R] [TrivialStar R] (r : R) : IsSelfAdjoint r :=
  star_trivial _
#align is_self_adjoint.all IsSelfAdjoint.all
-/

#print IsSelfAdjoint.star_eq /-
theorem star_eq [Star R] {x : R} (hx : IsSelfAdjoint x) : star x = x :=
  hx
#align is_self_adjoint.star_eq IsSelfAdjoint.star_eq
-/

#print isSelfAdjoint_iff /-
theorem isSelfAdjoint_iff [Star R] {x : R} : IsSelfAdjoint x ↔ star x = x :=
  Iff.rfl
#align is_self_adjoint_iff isSelfAdjoint_iff
-/

#print IsSelfAdjoint.star_iff /-
@[simp]
theorem star_iff [InvolutiveStar R] {x : R} : IsSelfAdjoint (star x) ↔ IsSelfAdjoint x := by
  simpa only [IsSelfAdjoint, star_star] using eq_comm
#align is_self_adjoint.star_iff IsSelfAdjoint.star_iff
-/

#print IsSelfAdjoint.star_mul_self /-
@[simp]
theorem star_mul_self [Semigroup R] [StarSemigroup R] (x : R) : IsSelfAdjoint (star x * x) := by
  simp only [IsSelfAdjoint, star_mul, star_star]
#align is_self_adjoint.star_mul_self IsSelfAdjoint.star_mul_self
-/

#print IsSelfAdjoint.mul_star_self /-
@[simp]
theorem mul_star_self [Semigroup R] [StarSemigroup R] (x : R) : IsSelfAdjoint (x * star x) := by
  simpa only [star_star] using star_mul_self (star x)
#align is_self_adjoint.mul_star_self IsSelfAdjoint.mul_star_self
-/

#print IsSelfAdjoint.starHom_apply /-
/-- Functions in a `star_hom_class` preserve self-adjoint elements. -/
theorem starHom_apply {F R S : Type _} [Star R] [Star S] [StarHomClass F R S] {x : R}
    (hx : IsSelfAdjoint x) (f : F) : IsSelfAdjoint (f x) :=
  show star (f x) = f x from map_star f x ▸ congr_arg f hx
#align is_self_adjoint.star_hom_apply IsSelfAdjoint.starHom_apply
-/

section AddMonoid

variable [AddMonoid R] [StarAddMonoid R]

variable (R)

#print isSelfAdjoint_zero /-
theorem isSelfAdjoint_zero : IsSelfAdjoint (0 : R) :=
  star_zero R
#align is_self_adjoint_zero isSelfAdjoint_zero
-/

variable {R}

#print IsSelfAdjoint.add /-
theorem add {x y : R} (hx : IsSelfAdjoint x) (hy : IsSelfAdjoint y) : IsSelfAdjoint (x + y) := by
  simp only [isSelfAdjoint_iff, star_add, hx.star_eq, hy.star_eq]
#align is_self_adjoint.add IsSelfAdjoint.add
-/

#print IsSelfAdjoint.bit0 /-
theorem bit0 {x : R} (hx : IsSelfAdjoint x) : IsSelfAdjoint (bit0 x) := by
  simp only [isSelfAdjoint_iff, star_bit0, hx.star_eq]
#align is_self_adjoint.bit0 IsSelfAdjoint.bit0
-/

end AddMonoid

section AddGroup

variable [AddGroup R] [StarAddMonoid R]

#print IsSelfAdjoint.neg /-
theorem neg {x : R} (hx : IsSelfAdjoint x) : IsSelfAdjoint (-x) := by
  simp only [isSelfAdjoint_iff, star_neg, hx.star_eq]
#align is_self_adjoint.neg IsSelfAdjoint.neg
-/

#print IsSelfAdjoint.sub /-
theorem sub {x y : R} (hx : IsSelfAdjoint x) (hy : IsSelfAdjoint y) : IsSelfAdjoint (x - y) := by
  simp only [isSelfAdjoint_iff, star_sub, hx.star_eq, hy.star_eq]
#align is_self_adjoint.sub IsSelfAdjoint.sub
-/

end AddGroup

section AddCommMonoid

variable [AddCommMonoid R] [StarAddMonoid R]

#print isSelfAdjoint_add_star_self /-
theorem isSelfAdjoint_add_star_self (x : R) : IsSelfAdjoint (x + star x) := by
  simp only [isSelfAdjoint_iff, add_comm, star_add, star_star]
#align is_self_adjoint_add_star_self isSelfAdjoint_add_star_self
-/

#print isSelfAdjoint_star_add_self /-
theorem isSelfAdjoint_star_add_self (x : R) : IsSelfAdjoint (star x + x) := by
  simp only [isSelfAdjoint_iff, add_comm, star_add, star_star]
#align is_self_adjoint_star_add_self isSelfAdjoint_star_add_self
-/

end AddCommMonoid

section Semigroup

variable [Semigroup R] [StarSemigroup R]

#print IsSelfAdjoint.conjugate /-
theorem conjugate {x : R} (hx : IsSelfAdjoint x) (z : R) : IsSelfAdjoint (z * x * star z) := by
  simp only [isSelfAdjoint_iff, star_mul, star_star, mul_assoc, hx.star_eq]
#align is_self_adjoint.conjugate IsSelfAdjoint.conjugate
-/

#print IsSelfAdjoint.conjugate' /-
theorem conjugate' {x : R} (hx : IsSelfAdjoint x) (z : R) : IsSelfAdjoint (star z * x * z) := by
  simp only [isSelfAdjoint_iff, star_mul, star_star, mul_assoc, hx.star_eq]
#align is_self_adjoint.conjugate' IsSelfAdjoint.conjugate'
-/

#print IsSelfAdjoint.isStarNormal /-
theorem isStarNormal {x : R} (hx : IsSelfAdjoint x) : IsStarNormal x :=
  ⟨by simp only [hx.star_eq]⟩
#align is_self_adjoint.is_star_normal IsSelfAdjoint.isStarNormal
-/

end Semigroup

section Monoid

variable [Monoid R] [StarSemigroup R]

variable (R)

#print isSelfAdjoint_one /-
theorem isSelfAdjoint_one : IsSelfAdjoint (1 : R) :=
  star_one R
#align is_self_adjoint_one isSelfAdjoint_one
-/

variable {R}

#print IsSelfAdjoint.pow /-
theorem pow {x : R} (hx : IsSelfAdjoint x) (n : ℕ) : IsSelfAdjoint (x ^ n) := by
  simp only [isSelfAdjoint_iff, star_pow, hx.star_eq]
#align is_self_adjoint.pow IsSelfAdjoint.pow
-/

end Monoid

section Semiring

variable [Semiring R] [StarRing R]

#print IsSelfAdjoint.bit1 /-
theorem bit1 {x : R} (hx : IsSelfAdjoint x) : IsSelfAdjoint (bit1 x) := by
  simp only [isSelfAdjoint_iff, star_bit1, hx.star_eq]
#align is_self_adjoint.bit1 IsSelfAdjoint.bit1
-/

#print isSelfAdjoint_natCast /-
@[simp]
theorem isSelfAdjoint_natCast (n : ℕ) : IsSelfAdjoint (n : R) :=
  star_natCast _
#align is_self_adjoint_nat_cast isSelfAdjoint_natCast
-/

end Semiring

section CommSemigroup

variable [CommSemigroup R] [StarSemigroup R]

#print IsSelfAdjoint.mul /-
theorem mul {x y : R} (hx : IsSelfAdjoint x) (hy : IsSelfAdjoint y) : IsSelfAdjoint (x * y) := by
  simp only [isSelfAdjoint_iff, star_mul', hx.star_eq, hy.star_eq]
#align is_self_adjoint.mul IsSelfAdjoint.mul
-/

end CommSemigroup

section Ring

variable [Ring R] [StarRing R]

#print isSelfAdjoint_intCast /-
@[simp]
theorem isSelfAdjoint_intCast (z : ℤ) : IsSelfAdjoint (z : R) :=
  star_intCast _
#align is_self_adjoint_int_cast isSelfAdjoint_intCast
-/

end Ring

section DivisionSemiring

variable [DivisionSemiring R] [StarRing R]

#print IsSelfAdjoint.inv /-
theorem inv {x : R} (hx : IsSelfAdjoint x) : IsSelfAdjoint x⁻¹ := by
  simp only [isSelfAdjoint_iff, star_inv', hx.star_eq]
#align is_self_adjoint.inv IsSelfAdjoint.inv
-/

#print IsSelfAdjoint.zpow /-
theorem zpow {x : R} (hx : IsSelfAdjoint x) (n : ℤ) : IsSelfAdjoint (x ^ n) := by
  simp only [isSelfAdjoint_iff, star_zpow₀, hx.star_eq]
#align is_self_adjoint.zpow IsSelfAdjoint.zpow
-/

end DivisionSemiring

section DivisionRing

variable [DivisionRing R] [StarRing R]

#print isSelfAdjoint_ratCast /-
theorem isSelfAdjoint_ratCast (x : ℚ) : IsSelfAdjoint (x : R) :=
  star_ratCast _
#align is_self_adjoint_rat_cast isSelfAdjoint_ratCast
-/

end DivisionRing

section Semifield

variable [Semifield R] [StarRing R]

#print IsSelfAdjoint.div /-
theorem div {x y : R} (hx : IsSelfAdjoint x) (hy : IsSelfAdjoint y) : IsSelfAdjoint (x / y) := by
  simp only [isSelfAdjoint_iff, star_div', hx.star_eq, hy.star_eq]
#align is_self_adjoint.div IsSelfAdjoint.div
-/

end Semifield

section SMul

variable [Star R] [AddMonoid A] [StarAddMonoid A] [SMul R A] [StarModule R A]

#print IsSelfAdjoint.smul /-
theorem smul {r : R} (hr : IsSelfAdjoint r) {x : A} (hx : IsSelfAdjoint x) :
    IsSelfAdjoint (r • x) := by simp only [isSelfAdjoint_iff, star_smul, hr.star_eq, hx.star_eq]
#align is_self_adjoint.smul IsSelfAdjoint.smul
-/

end SMul

end IsSelfAdjoint

variable (R)

#print selfAdjoint /-
/-- The self-adjoint elements of a star additive group, as an additive subgroup. -/
def selfAdjoint [AddGroup R] [StarAddMonoid R] : AddSubgroup R
    where
  carrier := {x | IsSelfAdjoint x}
  zero_mem' := star_zero R
  add_mem' _ _ hx := hx.add
  neg_mem' _ hx := hx.neg
#align self_adjoint selfAdjoint
-/

#print skewAdjoint /-
/-- The skew-adjoint elements of a star additive group, as an additive subgroup. -/
def skewAdjoint [AddCommGroup R] [StarAddMonoid R] : AddSubgroup R
    where
  carrier := {x | star x = -x}
  zero_mem' := show star (0 : R) = -0 by simp only [star_zero, neg_zero]
  add_mem' x y (hx : star x = -x) (hy : star y = -y) :=
    show star (x + y) = -(x + y) by rw [star_add x y, hx, hy, neg_add]
  neg_mem' x (hx : star x = -x) := show star (-x) = - -x by simp only [hx, star_neg]
#align skew_adjoint skewAdjoint
-/

variable {R}

namespace selfAdjoint

section AddGroup

variable [AddGroup R] [StarAddMonoid R]

#print selfAdjoint.mem_iff /-
theorem mem_iff {x : R} : x ∈ selfAdjoint R ↔ star x = x := by rw [← AddSubgroup.mem_carrier];
  exact Iff.rfl
#align self_adjoint.mem_iff selfAdjoint.mem_iff
-/

#print selfAdjoint.star_val_eq /-
@[simp, norm_cast]
theorem star_val_eq {x : selfAdjoint R} : star (x : R) = x :=
  x.Prop
#align self_adjoint.star_coe_eq selfAdjoint.star_val_eq
-/

instance : Inhabited (selfAdjoint R) :=
  ⟨0⟩

end AddGroup

section Ring

variable [Ring R] [StarRing R]

instance : One (selfAdjoint R) :=
  ⟨⟨1, isSelfAdjoint_one R⟩⟩

#print selfAdjoint.val_one /-
@[simp, norm_cast]
theorem val_one : ↑(1 : selfAdjoint R) = (1 : R) :=
  rfl
#align self_adjoint.coe_one selfAdjoint.val_one
-/

instance [Nontrivial R] : Nontrivial (selfAdjoint R) :=
  ⟨⟨0, 1, Subtype.ne_of_val_ne zero_ne_one⟩⟩

instance : NatCast (selfAdjoint R) :=
  ⟨fun n => ⟨n, isSelfAdjoint_natCast _⟩⟩

instance : IntCast (selfAdjoint R) :=
  ⟨fun n => ⟨n, isSelfAdjoint_intCast _⟩⟩

instance : Pow (selfAdjoint R) ℕ :=
  ⟨fun x n => ⟨(x : R) ^ n, x.Prop.pow n⟩⟩

#print selfAdjoint.val_pow /-
@[simp, norm_cast]
theorem val_pow (x : selfAdjoint R) (n : ℕ) : ↑(x ^ n) = (x : R) ^ n :=
  rfl
#align self_adjoint.coe_pow selfAdjoint.val_pow
-/

end Ring

section NonUnitalCommRing

variable [NonUnitalCommRing R] [StarRing R]

instance : Mul (selfAdjoint R) :=
  ⟨fun x y => ⟨(x : R) * y, x.Prop.mul y.Prop⟩⟩

#print selfAdjoint.val_mul /-
@[simp, norm_cast]
theorem val_mul (x y : selfAdjoint R) : ↑(x * y) = (x : R) * y :=
  rfl
#align self_adjoint.coe_mul selfAdjoint.val_mul
-/

end NonUnitalCommRing

section CommRing

variable [CommRing R] [StarRing R]

instance : CommRing (selfAdjoint R) :=
  Function.Injective.commRing _ Subtype.coe_injective (selfAdjoint R).val_zero val_one
    (selfAdjoint R).val_add val_mul (selfAdjoint R).coeNeg (selfAdjoint R).val_neg_eq_neg_val
    (selfAdjoint R).val_nsmul_eq_nsmul_val (selfAdjoint R).val_zsmul_eq_zsmul_val val_pow
    (fun _ => rfl) fun _ => rfl

end CommRing

section Field

variable [Field R] [StarRing R]

instance : Inv (selfAdjoint R) where inv x := ⟨x.val⁻¹, x.Prop.inv⟩

#print selfAdjoint.val_inv /-
@[simp, norm_cast]
theorem val_inv (x : selfAdjoint R) : ↑x⁻¹ = (x : R)⁻¹ :=
  rfl
#align self_adjoint.coe_inv selfAdjoint.val_inv
-/

instance : Div (selfAdjoint R) where div x y := ⟨x / y, x.Prop.div y.Prop⟩

#print selfAdjoint.val_div /-
@[simp, norm_cast]
theorem val_div (x y : selfAdjoint R) : ↑(x / y) = (x / y : R) :=
  rfl
#align self_adjoint.coe_div selfAdjoint.val_div
-/

instance : Pow (selfAdjoint R) ℤ where pow x z := ⟨x ^ z, x.Prop.zpow z⟩

#print selfAdjoint.val_zpow /-
@[simp, norm_cast]
theorem val_zpow (x : selfAdjoint R) (z : ℤ) : ↑(x ^ z) = (x : R) ^ z :=
  rfl
#align self_adjoint.coe_zpow selfAdjoint.val_zpow
-/

instance : HasRatCast (selfAdjoint R) :=
  ⟨fun n => ⟨n, isSelfAdjoint_ratCast n⟩⟩

#print selfAdjoint.val_ratCast /-
@[simp, norm_cast]
theorem val_ratCast (x : ℚ) : ↑(x : selfAdjoint R) = (x : R) :=
  rfl
#align self_adjoint.coe_rat_cast selfAdjoint.val_ratCast
-/

#print selfAdjoint.instQSMul /-
instance instQSMul : SMul ℚ (selfAdjoint R) :=
  ⟨fun a x =>
    ⟨a • x, by rw [Rat.smul_def] <;> exact IsSelfAdjoint.mul (isSelfAdjoint_ratCast a) x.prop⟩⟩
#align self_adjoint.has_qsmul selfAdjoint.instQSMul
-/

#print selfAdjoint.val_rat_smul /-
@[simp, norm_cast]
theorem val_rat_smul (x : selfAdjoint R) (a : ℚ) : ↑(a • x) = a • (x : R) :=
  rfl
#align self_adjoint.coe_rat_smul selfAdjoint.val_rat_smul
-/

instance : Field (selfAdjoint R) :=
  Function.Injective.field _ Subtype.coe_injective (selfAdjoint R).val_zero val_one
    (selfAdjoint R).val_add val_mul (selfAdjoint R).coeNeg (selfAdjoint R).val_neg_eq_neg_val
    val_inv val_div (selfAdjoint R).val_nsmul_eq_nsmul_val (selfAdjoint R).val_zsmul_eq_zsmul_val
    val_rat_smul val_pow val_zpow (fun _ => rfl) (fun _ => rfl) val_ratCast

end Field

section SMul

variable [Star R] [TrivialStar R] [AddGroup A] [StarAddMonoid A]

instance [SMul R A] [StarModule R A] : SMul R (selfAdjoint A) :=
  ⟨fun r x => ⟨r • x, (IsSelfAdjoint.all _).smul x.Prop⟩⟩

#print selfAdjoint.val_smul /-
@[simp, norm_cast]
theorem val_smul [SMul R A] [StarModule R A] (r : R) (x : selfAdjoint A) : ↑(r • x) = r • (x : A) :=
  rfl
#align self_adjoint.coe_smul selfAdjoint.val_smul
-/

instance [Monoid R] [MulAction R A] [StarModule R A] : MulAction R (selfAdjoint A) :=
  Function.Injective.mulAction coe Subtype.coe_injective val_smul

instance [Monoid R] [DistribMulAction R A] [StarModule R A] : DistribMulAction R (selfAdjoint A) :=
  Function.Injective.distribMulAction (selfAdjoint A).Subtype Subtype.coe_injective val_smul

end SMul

section Module

variable [Star R] [TrivialStar R] [AddCommGroup A] [StarAddMonoid A]

instance [Semiring R] [Module R A] [StarModule R A] : Module R (selfAdjoint A) :=
  Function.Injective.module R (selfAdjoint A).Subtype Subtype.coe_injective val_smul

end Module

end selfAdjoint

namespace skewAdjoint

section AddGroup

variable [AddCommGroup R] [StarAddMonoid R]

#print skewAdjoint.mem_iff /-
theorem mem_iff {x : R} : x ∈ skewAdjoint R ↔ star x = -x := by rw [← AddSubgroup.mem_carrier];
  exact Iff.rfl
#align skew_adjoint.mem_iff skewAdjoint.mem_iff
-/

#print skewAdjoint.star_val_eq /-
@[simp, norm_cast]
theorem star_val_eq {x : skewAdjoint R} : star (x : R) = -x :=
  x.Prop
#align skew_adjoint.star_coe_eq skewAdjoint.star_val_eq
-/

instance : Inhabited (skewAdjoint R) :=
  ⟨0⟩

#print skewAdjoint.bit0_mem /-
theorem bit0_mem {x : R} (hx : x ∈ skewAdjoint R) : bit0 x ∈ skewAdjoint R := by
  rw [mem_iff, star_bit0, mem_iff.mp hx, bit0, bit0, neg_add]
#align skew_adjoint.bit0_mem skewAdjoint.bit0_mem
-/

end AddGroup

section Ring

variable [Ring R] [StarRing R]

#print skewAdjoint.conjugate /-
theorem conjugate {x : R} (hx : x ∈ skewAdjoint R) (z : R) : z * x * star z ∈ skewAdjoint R := by
  simp only [mem_iff, star_mul, star_star, mem_iff.mp hx, neg_mul, mul_neg, mul_assoc]
#align skew_adjoint.conjugate skewAdjoint.conjugate
-/

#print skewAdjoint.conjugate' /-
theorem conjugate' {x : R} (hx : x ∈ skewAdjoint R) (z : R) : star z * x * z ∈ skewAdjoint R := by
  simp only [mem_iff, star_mul, star_star, mem_iff.mp hx, neg_mul, mul_neg, mul_assoc]
#align skew_adjoint.conjugate' skewAdjoint.conjugate'
-/

#print skewAdjoint.isStarNormal_of_mem /-
theorem isStarNormal_of_mem {x : R} (hx : x ∈ skewAdjoint R) : IsStarNormal x :=
  ⟨by simp only [mem_iff] at hx ; simp only [hx, Commute.neg_left]⟩
#align skew_adjoint.is_star_normal_of_mem skewAdjoint.isStarNormal_of_mem
-/

instance (x : skewAdjoint R) : IsStarNormal (x : R) :=
  isStarNormal_of_mem (SetLike.coe_mem _)

end Ring

section SMul

variable [Star R] [TrivialStar R] [AddCommGroup A] [StarAddMonoid A]

#print skewAdjoint.smul_mem /-
theorem smul_mem [Monoid R] [DistribMulAction R A] [StarModule R A] (r : R) {x : A}
    (h : x ∈ skewAdjoint A) : r • x ∈ skewAdjoint A := by
  rw [mem_iff, star_smul, star_trivial, mem_iff.mp h, smul_neg r]
#align skew_adjoint.smul_mem skewAdjoint.smul_mem
-/

instance [Monoid R] [DistribMulAction R A] [StarModule R A] : SMul R (skewAdjoint A) :=
  ⟨fun r x => ⟨r • x, smul_mem r x.Prop⟩⟩

#print skewAdjoint.val_smul /-
@[simp, norm_cast]
theorem val_smul [Monoid R] [DistribMulAction R A] [StarModule R A] (r : R) (x : skewAdjoint A) :
    ↑(r • x) = r • (x : A) :=
  rfl
#align skew_adjoint.coe_smul skewAdjoint.val_smul
-/

instance [Monoid R] [DistribMulAction R A] [StarModule R A] : DistribMulAction R (skewAdjoint A) :=
  Function.Injective.distribMulAction (skewAdjoint A).Subtype Subtype.coe_injective val_smul

instance [Semiring R] [Module R A] [StarModule R A] : Module R (skewAdjoint A) :=
  Function.Injective.module R (skewAdjoint A).Subtype Subtype.coe_injective val_smul

end SMul

end skewAdjoint

#print IsSelfAdjoint.smul_mem_skewAdjoint /-
/-- Scalar multiplication of a self-adjoint element by a skew-adjoint element produces a
skew-adjoint element. -/
theorem IsSelfAdjoint.smul_mem_skewAdjoint [Ring R] [AddCommGroup A] [Module R A] [StarAddMonoid R]
    [StarAddMonoid A] [StarModule R A] {r : R} (hr : r ∈ skewAdjoint R) {a : A}
    (ha : IsSelfAdjoint a) : r • a ∈ skewAdjoint A :=
  (star_smul _ _).trans <| (congr_arg₂ _ hr ha).trans <| neg_smul _ _
#align is_self_adjoint.smul_mem_skew_adjoint IsSelfAdjoint.smul_mem_skewAdjoint
-/

#print isSelfAdjoint_smul_of_mem_skewAdjoint /-
/-- Scalar multiplication of a skew-adjoint element by a skew-adjoint element produces a
self-adjoint element. -/
theorem isSelfAdjoint_smul_of_mem_skewAdjoint [Ring R] [AddCommGroup A] [Module R A]
    [StarAddMonoid R] [StarAddMonoid A] [StarModule R A] {r : R} (hr : r ∈ skewAdjoint R) {a : A}
    (ha : a ∈ skewAdjoint A) : IsSelfAdjoint (r • a) :=
  (star_smul _ _).trans <| (congr_arg₂ _ hr ha).trans <| neg_smul_neg _ _
#align is_self_adjoint_smul_of_mem_skew_adjoint isSelfAdjoint_smul_of_mem_skewAdjoint
-/

#print isStarNormal_zero /-
instance isStarNormal_zero [Semiring R] [StarRing R] : IsStarNormal (0 : R) :=
  ⟨by simp only [star_comm_self, star_zero]⟩
#align is_star_normal_zero isStarNormal_zero
-/

#print isStarNormal_one /-
instance isStarNormal_one [Monoid R] [StarSemigroup R] : IsStarNormal (1 : R) :=
  ⟨by simp only [star_comm_self, star_one]⟩
#align is_star_normal_one isStarNormal_one
-/

#print isStarNormal_star_self /-
instance isStarNormal_star_self [Monoid R] [StarSemigroup R] {x : R} [IsStarNormal x] :
    IsStarNormal (star x) :=
  ⟨show star (star x) * star x = star x * star (star x) by rw [star_star, star_comm_self']⟩
#align is_star_normal_star_self isStarNormal_star_self
-/

#print TrivialStar.isStarNormal /-
-- see Note [lower instance priority]
instance (priority := 100) TrivialStar.isStarNormal [Monoid R] [StarSemigroup R] [TrivialStar R]
    {x : R} : IsStarNormal x :=
  ⟨by rw [star_trivial]⟩
#align has_trivial_star.is_star_normal TrivialStar.isStarNormal
-/

#print CommMonoid.isStarNormal /-
-- see Note [lower instance priority]
instance (priority := 100) CommMonoid.isStarNormal [CommMonoid R] [StarSemigroup R] {x : R} :
    IsStarNormal x :=
  ⟨mul_comm _ _⟩
#align comm_monoid.is_star_normal CommMonoid.isStarNormal
-/

