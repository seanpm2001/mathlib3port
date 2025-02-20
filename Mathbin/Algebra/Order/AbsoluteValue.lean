/-
Copyright (c) 2021 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Anne Baanen

! This file was ported from Lean 3 source module algebra.order.absolute_value
! leanprover-community/mathlib commit 0013240bce820e3096cebb7ccf6d17e3f35f77ca
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GroupWithZero.Units.Lemmas
import Mathbin.Algebra.Order.Field.Defs
import Mathbin.Algebra.Order.Hom.Basic
import Mathbin.Algebra.Ring.Regular

/-!
# Absolute values

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines a bundled type of absolute values `absolute_value R S`.

## Main definitions

 * `absolute_value R S` is the type of absolute values on `R` mapping to `S`.
 * `absolute_value.abs` is the "standard" absolute value on `S`, mapping negative `x` to `-x`.
 * `absolute_value.to_monoid_with_zero_hom`: absolute values mapping to a
   linear ordered field preserve `0`, `*` and `1`
 * `is_absolute_value`: a type class stating that `f : β → α` satisfies the axioms of an abs val
-/


#print AbsoluteValue /-
/-- `absolute_value R S` is the type of absolute values on `R` mapping to `S`:
the maps that preserve `*`, are nonnegative, positive definite and satisfy the triangle equality. -/
structure AbsoluteValue (R S : Type _) [Semiring R] [OrderedSemiring S] extends R →ₙ* S where
  nonneg' : ∀ x, 0 ≤ to_fun x
  eq_zero' : ∀ x, to_fun x = 0 ↔ x = 0
  add_le' : ∀ x y, to_fun (x + y) ≤ to_fun x + to_fun y
#align absolute_value AbsoluteValue
-/

namespace AbsoluteValue

attribute [nolint doc_blame] AbsoluteValue.toMulHom

section OrderedSemiring

section Semiring

variable {R S : Type _} [Semiring R] [OrderedSemiring S] (abv : AbsoluteValue R S)

#print AbsoluteValue.zeroHomClass /-
instance zeroHomClass : ZeroHomClass (AbsoluteValue R S) R S
    where
  coe f := f.toFun
  coe_injective' f g h := by obtain ⟨⟨_, _⟩, _⟩ := f; obtain ⟨⟨_, _⟩, _⟩ := g; congr
  map_zero f := (f.eq_zero' _).2 rfl
#align absolute_value.zero_hom_class AbsoluteValue.zeroHomClass
-/

#print AbsoluteValue.mulHomClass /-
instance mulHomClass : MulHomClass (AbsoluteValue R S) R S :=
  { AbsoluteValue.zeroHomClass with map_mul := fun f => f.map_mul' }
#align absolute_value.mul_hom_class AbsoluteValue.mulHomClass
-/

#print AbsoluteValue.nonnegHomClass /-
instance nonnegHomClass : NonnegHomClass (AbsoluteValue R S) R S :=
  { AbsoluteValue.zeroHomClass with map_nonneg := fun f => f.nonneg' }
#align absolute_value.nonneg_hom_class AbsoluteValue.nonnegHomClass
-/

#print AbsoluteValue.subadditiveHomClass /-
instance subadditiveHomClass : SubadditiveHomClass (AbsoluteValue R S) R S :=
  { AbsoluteValue.zeroHomClass with map_add_le_add := fun f => f.add_le' }
#align absolute_value.subadditive_hom_class AbsoluteValue.subadditiveHomClass
-/

#print AbsoluteValue.coe_mk /-
@[simp]
theorem coe_mk (f : R →ₙ* S) {h₁ h₂ h₃} : (AbsoluteValue.mk f h₁ h₂ h₃ : R → S) = f :=
  rfl
#align absolute_value.coe_mk AbsoluteValue.coe_mk
-/

#print AbsoluteValue.ext /-
@[ext]
theorem ext ⦃f g : AbsoluteValue R S⦄ : (∀ x, f x = g x) → f = g :=
  FunLike.ext _ _
#align absolute_value.ext AbsoluteValue.ext
-/

#print AbsoluteValue.Simps.apply /-
/-- See Note [custom simps projection]. -/
def Simps.apply (f : AbsoluteValue R S) : R → S :=
  f
#align absolute_value.simps.apply AbsoluteValue.Simps.apply
-/

initialize_simps_projections AbsoluteValue (to_mul_hom_to_fun → apply)

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (AbsoluteValue R S) fun f => R → S :=
  FunLike.hasCoeToFun

#print AbsoluteValue.coe_toMulHom /-
@[simp]
theorem coe_toMulHom : ⇑abv.toMulHom = abv :=
  rfl
#align absolute_value.coe_to_mul_hom AbsoluteValue.coe_toMulHom
-/

#print AbsoluteValue.nonneg /-
protected theorem nonneg (x : R) : 0 ≤ abv x :=
  abv.nonneg' x
#align absolute_value.nonneg AbsoluteValue.nonneg
-/

#print AbsoluteValue.eq_zero /-
@[simp]
protected theorem eq_zero {x : R} : abv x = 0 ↔ x = 0 :=
  abv.eq_zero' x
#align absolute_value.eq_zero AbsoluteValue.eq_zero
-/

#print AbsoluteValue.add_le /-
protected theorem add_le (x y : R) : abv (x + y) ≤ abv x + abv y :=
  abv.add_le' x y
#align absolute_value.add_le AbsoluteValue.add_le
-/

#print AbsoluteValue.map_mul /-
@[simp]
protected theorem map_mul (x y : R) : abv (x * y) = abv x * abv y :=
  abv.map_mul' x y
#align absolute_value.map_mul AbsoluteValue.map_mul
-/

#print AbsoluteValue.ne_zero_iff /-
protected theorem ne_zero_iff {x : R} : abv x ≠ 0 ↔ x ≠ 0 :=
  abv.eq_zero.Not
#align absolute_value.ne_zero_iff AbsoluteValue.ne_zero_iff
-/

#print AbsoluteValue.pos /-
protected theorem pos {x : R} (hx : x ≠ 0) : 0 < abv x :=
  lt_of_le_of_ne (abv.NonNeg x) (Ne.symm <| mt abv.eq_zero.mp hx)
#align absolute_value.pos AbsoluteValue.pos
-/

#print AbsoluteValue.pos_iff /-
@[simp]
protected theorem pos_iff {x : R} : 0 < abv x ↔ x ≠ 0 :=
  ⟨fun h₁ => mt abv.eq_zero.mpr h₁.ne', abv.Pos⟩
#align absolute_value.pos_iff AbsoluteValue.pos_iff
-/

#print AbsoluteValue.ne_zero /-
protected theorem ne_zero {x : R} (hx : x ≠ 0) : abv x ≠ 0 :=
  (abv.Pos hx).ne'
#align absolute_value.ne_zero AbsoluteValue.ne_zero
-/

#print AbsoluteValue.map_one_of_isLeftRegular /-
theorem map_one_of_isLeftRegular (h : IsLeftRegular (abv 1)) : abv 1 = 1 :=
  h <| by simp [← abv.map_mul]
#align absolute_value.map_one_of_is_regular AbsoluteValue.map_one_of_isLeftRegular
-/

#print AbsoluteValue.map_zero /-
@[simp]
protected theorem map_zero : abv 0 = 0 :=
  abv.eq_zero.2 rfl
#align absolute_value.map_zero AbsoluteValue.map_zero
-/

end Semiring

section Ring

variable {R S : Type _} [Ring R] [OrderedSemiring S] (abv : AbsoluteValue R S)

#print AbsoluteValue.sub_le /-
protected theorem sub_le (a b c : R) : abv (a - c) ≤ abv (a - b) + abv (b - c) := by
  simpa [sub_eq_add_neg, add_assoc] using abv.add_le (a - b) (b - c)
#align absolute_value.sub_le AbsoluteValue.sub_le
-/

#print AbsoluteValue.map_sub_eq_zero_iff /-
@[simp]
theorem map_sub_eq_zero_iff (a b : R) : abv (a - b) = 0 ↔ a = b :=
  abv.eq_zero.trans sub_eq_zero
#align absolute_value.map_sub_eq_zero_iff AbsoluteValue.map_sub_eq_zero_iff
-/

end Ring

end OrderedSemiring

section OrderedRing

section Semiring

section IsDomain

-- all of these are true for `no_zero_divisors S`; but it doesn't work smoothly with the
-- `is_domain`/`cancel_monoid_with_zero` API
variable {R S : Type _} [Semiring R] [OrderedRing S] (abv : AbsoluteValue R S)

variable [IsDomain S] [Nontrivial R]

#print AbsoluteValue.map_one /-
@[simp]
protected theorem map_one : abv 1 = 1 :=
  abv.map_one_of_isLeftRegular (isRegular_of_ne_zero <| abv.NeZero one_ne_zero).left
#align absolute_value.map_one AbsoluteValue.map_one
-/

instance : MonoidWithZeroHomClass (AbsoluteValue R S) R S :=
  { AbsoluteValue.mulHomClass with
    map_zero := fun f => f.map_zero
    map_one := fun f => f.map_one }

#print AbsoluteValue.toMonoidWithZeroHom /-
/-- Absolute values from a nontrivial `R` to a linear ordered ring preserve `*`, `0` and `1`. -/
def toMonoidWithZeroHom : R →*₀ S :=
  abv
#align absolute_value.to_monoid_with_zero_hom AbsoluteValue.toMonoidWithZeroHom
-/

#print AbsoluteValue.coe_toMonoidWithZeroHom /-
@[simp]
theorem coe_toMonoidWithZeroHom : ⇑abv.toMonoidWithZeroHom = abv :=
  rfl
#align absolute_value.coe_to_monoid_with_zero_hom AbsoluteValue.coe_toMonoidWithZeroHom
-/

#print AbsoluteValue.toMonoidHom /-
/-- Absolute values from a nontrivial `R` to a linear ordered ring preserve `*` and `1`. -/
def toMonoidHom : R →* S :=
  abv
#align absolute_value.to_monoid_hom AbsoluteValue.toMonoidHom
-/

#print AbsoluteValue.coe_toMonoidHom /-
@[simp]
theorem coe_toMonoidHom : ⇑abv.toMonoidHom = abv :=
  rfl
#align absolute_value.coe_to_monoid_hom AbsoluteValue.coe_toMonoidHom
-/

#print AbsoluteValue.map_pow /-
@[simp]
protected theorem map_pow (a : R) (n : ℕ) : abv (a ^ n) = abv a ^ n :=
  abv.toMonoidHom.map_pow a n
#align absolute_value.map_pow AbsoluteValue.map_pow
-/

end IsDomain

end Semiring

section Ring

variable {R S : Type _} [Ring R] [OrderedRing S] (abv : AbsoluteValue R S)

#print AbsoluteValue.le_sub /-
protected theorem le_sub (a b : R) : abv a - abv b ≤ abv (a - b) :=
  sub_le_iff_le_add.2 <| by simpa using abv.add_le (a - b) b
#align absolute_value.le_sub AbsoluteValue.le_sub
-/

end Ring

end OrderedRing

section OrderedCommRing

variable {R S : Type _} [Ring R] [OrderedCommRing S] (abv : AbsoluteValue R S)

variable [NoZeroDivisors S]

#print AbsoluteValue.map_neg /-
@[simp]
protected theorem map_neg (a : R) : abv (-a) = abv a :=
  by
  by_cases ha : a = 0; · simp [ha]
  refine'
    (mul_self_eq_mul_self_iff.mp (by rw [← abv.map_mul, neg_mul_neg, abv.map_mul])).resolve_right _
  exact ((neg_lt_zero.mpr (abv.pos ha)).trans (abv.pos (neg_ne_zero.mpr ha))).ne'
#align absolute_value.map_neg AbsoluteValue.map_neg
-/

#print AbsoluteValue.map_sub /-
protected theorem map_sub (a b : R) : abv (a - b) = abv (b - a) := by rw [← neg_sub, abv.map_neg]
#align absolute_value.map_sub AbsoluteValue.map_sub
-/

end OrderedCommRing

instance {R S : Type _} [Ring R] [OrderedCommRing S] [Nontrivial R] [IsDomain S] :
    MulRingNormClass (AbsoluteValue R S) R S :=
  { AbsoluteValue.subadditiveHomClass,
    AbsoluteValue.monoidWithZeroHomClass with
    map_neg_eq_map := fun f => f.map_neg
    eq_zero_of_map_eq_zero := fun f a => f.eq_zero.1 }

section LinearOrderedRing

variable {R S : Type _} [Semiring R] [LinearOrderedRing S] (abv : AbsoluteValue R S)

#print AbsoluteValue.abs /-
/-- `absolute_value.abs` is `abs` as a bundled `absolute_value`. -/
@[simps]
protected def abs : AbsoluteValue S S where
  toFun := abs
  nonneg' := abs_nonneg
  eq_zero' _ := abs_eq_zero
  add_le' := abs_add
  map_mul' := abs_mul
#align absolute_value.abs AbsoluteValue.abs
-/

instance : Inhabited (AbsoluteValue S S) :=
  ⟨AbsoluteValue.abs⟩

end LinearOrderedRing

section LinearOrderedCommRing

variable {R S : Type _} [Ring R] [LinearOrderedCommRing S] (abv : AbsoluteValue R S)

#print AbsoluteValue.abs_abv_sub_le_abv_sub /-
theorem abs_abv_sub_le_abv_sub (a b : R) : abs (abv a - abv b) ≤ abv (a - b) :=
  abs_sub_le_iff.2 ⟨abv.le_sub _ _, by rw [abv.map_sub] <;> apply abv.le_sub⟩
#align absolute_value.abs_abv_sub_le_abv_sub AbsoluteValue.abs_abv_sub_le_abv_sub
-/

end LinearOrderedCommRing

end AbsoluteValue

#print IsAbsoluteValue /-
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`abv_nonneg] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`abv_eq_zero] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`abv_add] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`abv_mul] [] -/
/-- A function `f` is an absolute value if it is nonnegative, zero only at 0, additive, and
multiplicative.

See also the type `absolute_value` which represents a bundled version of absolute values.
-/
class IsAbsoluteValue {S} [OrderedSemiring S] {R} [Semiring R] (f : R → S) : Prop where
  abv_nonneg : ∀ x, 0 ≤ f x
  abv_eq_zero : ∀ {x}, f x = 0 ↔ x = 0
  abv_add : ∀ x y, f (x + y) ≤ f x + f y
  abv_mul : ∀ x y, f (x * y) = f x * f y
#align is_absolute_value IsAbsoluteValue
-/

namespace IsAbsoluteValue

section OrderedSemiring

variable {S : Type _} [OrderedSemiring S]

variable {R : Type _} [Semiring R] (abv : R → S) [IsAbsoluteValue abv]

#print AbsoluteValue.isAbsoluteValue /-
/-- A bundled absolute value is an absolute value. -/
instance AbsoluteValue.isAbsoluteValue (abv : AbsoluteValue R S) : IsAbsoluteValue abv
    where
  abv_nonneg := abv.NonNeg
  abv_eq_zero _ := abv.eq_zero
  abv_add := abv.add_le
  abv_mul := abv.map_mul
#align absolute_value.is_absolute_value AbsoluteValue.isAbsoluteValue
-/

#print IsAbsoluteValue.toAbsoluteValue /-
/-- Convert an unbundled `is_absolute_value` to a bundled `absolute_value`. -/
@[simps]
def toAbsoluteValue : AbsoluteValue R S where
  toFun := abv
  add_le' := abv_add abv
  eq_zero' _ := abv_eq_zero abv
  nonneg' := abv_nonneg abv
  map_mul' := abv_mul abv
#align is_absolute_value.to_absolute_value IsAbsoluteValue.toAbsoluteValue
-/

#print IsAbsoluteValue.abv_zero /-
theorem abv_zero : abv 0 = 0 :=
  (toAbsoluteValue abv).map_zero
#align is_absolute_value.abv_zero IsAbsoluteValue.abv_zero
-/

#print IsAbsoluteValue.abv_pos /-
theorem abv_pos {a : R} : 0 < abv a ↔ a ≠ 0 :=
  (toAbsoluteValue abv).pos_iff
#align is_absolute_value.abv_pos IsAbsoluteValue.abv_pos
-/

end OrderedSemiring

section LinearOrderedRing

variable {S : Type _} [LinearOrderedRing S]

#print IsAbsoluteValue.abs_isAbsoluteValue /-
instance abs_isAbsoluteValue : IsAbsoluteValue (abs : S → S) :=
  AbsoluteValue.abs.IsAbsoluteValue
#align is_absolute_value.abs_is_absolute_value IsAbsoluteValue.abs_isAbsoluteValue
-/

end LinearOrderedRing

section OrderedRing

variable {S : Type _} [OrderedRing S]

section Semiring

variable {R : Type _} [Semiring R] (abv : R → S) [IsAbsoluteValue abv]

variable [IsDomain S]

#print IsAbsoluteValue.abv_one /-
theorem abv_one [Nontrivial R] : abv 1 = 1 :=
  (toAbsoluteValue abv).map_one
#align is_absolute_value.abv_one IsAbsoluteValue.abv_one
-/

#print IsAbsoluteValue.abvHom /-
/-- `abv` as a `monoid_with_zero_hom`. -/
def abvHom [Nontrivial R] : R →*₀ S :=
  (toAbsoluteValue abv).toMonoidWithZeroHom
#align is_absolute_value.abv_hom IsAbsoluteValue.abvHom
-/

#print IsAbsoluteValue.abv_pow /-
theorem abv_pow [Nontrivial R] (abv : R → S) [IsAbsoluteValue abv] (a : R) (n : ℕ) :
    abv (a ^ n) = abv a ^ n :=
  (toAbsoluteValue abv).map_pow a n
#align is_absolute_value.abv_pow IsAbsoluteValue.abv_pow
-/

end Semiring

section Ring

variable {R : Type _} [Ring R] (abv : R → S) [IsAbsoluteValue abv]

#print IsAbsoluteValue.abv_sub_le /-
theorem abv_sub_le (a b c : R) : abv (a - c) ≤ abv (a - b) + abv (b - c) := by
  simpa [sub_eq_add_neg, add_assoc] using abv_add abv (a - b) (b - c)
#align is_absolute_value.abv_sub_le IsAbsoluteValue.abv_sub_le
-/

#print IsAbsoluteValue.sub_abv_le_abv_sub /-
theorem sub_abv_le_abv_sub (a b : R) : abv a - abv b ≤ abv (a - b) :=
  (toAbsoluteValue abv).le_sub a b
#align is_absolute_value.sub_abv_le_abv_sub IsAbsoluteValue.sub_abv_le_abv_sub
-/

end Ring

end OrderedRing

section OrderedCommRing

variable {S : Type _} [OrderedCommRing S]

section Ring

variable {R : Type _} [Ring R] (abv : R → S) [IsAbsoluteValue abv]

variable [NoZeroDivisors S]

#print IsAbsoluteValue.abv_neg /-
theorem abv_neg (a : R) : abv (-a) = abv a :=
  (toAbsoluteValue abv).map_neg a
#align is_absolute_value.abv_neg IsAbsoluteValue.abv_neg
-/

#print IsAbsoluteValue.abv_sub /-
theorem abv_sub (a b : R) : abv (a - b) = abv (b - a) :=
  (toAbsoluteValue abv).map_sub a b
#align is_absolute_value.abv_sub IsAbsoluteValue.abv_sub
-/

end Ring

end OrderedCommRing

section LinearOrderedCommRing

variable {S : Type _} [LinearOrderedCommRing S]

section Ring

variable {R : Type _} [Ring R] (abv : R → S) [IsAbsoluteValue abv]

#print IsAbsoluteValue.abs_abv_sub_le_abv_sub /-
theorem abs_abv_sub_le_abv_sub (a b : R) : abs (abv a - abv b) ≤ abv (a - b) :=
  (toAbsoluteValue abv).abs_abv_sub_le_abv_sub a b
#align is_absolute_value.abs_abv_sub_le_abv_sub IsAbsoluteValue.abs_abv_sub_le_abv_sub
-/

end Ring

end LinearOrderedCommRing

section LinearOrderedField

variable {S : Type _} [LinearOrderedSemifield S]

section Semiring

variable {R : Type _} [Semiring R] [Nontrivial R] (abv : R → S) [IsAbsoluteValue abv]

#print IsAbsoluteValue.abv_one' /-
theorem abv_one' : abv 1 = 1 :=
  (toAbsoluteValue abv).map_one_of_isLeftRegular <|
    (isRegular_of_ne_zero <| (toAbsoluteValue abv).NeZero one_ne_zero).left
#align is_absolute_value.abv_one' IsAbsoluteValue.abv_one'
-/

#print IsAbsoluteValue.abvHom' /-
/-- An absolute value as a monoid with zero homomorphism, assuming the target is a semifield. -/
def abvHom' : R →*₀ S :=
  ⟨abv, abv_zero abv, abv_one' abv, abv_mul abv⟩
#align is_absolute_value.abv_hom' IsAbsoluteValue.abvHom'
-/

end Semiring

section DivisionSemiring

variable {R : Type _} [DivisionSemiring R] (abv : R → S) [IsAbsoluteValue abv]

#print IsAbsoluteValue.abv_inv /-
theorem abv_inv (a : R) : abv a⁻¹ = (abv a)⁻¹ :=
  map_inv₀ (abvHom' abv) a
#align is_absolute_value.abv_inv IsAbsoluteValue.abv_inv
-/

#print IsAbsoluteValue.abv_div /-
theorem abv_div (a b : R) : abv (a / b) = abv a / abv b :=
  map_div₀ (abvHom' abv) a b
#align is_absolute_value.abv_div IsAbsoluteValue.abv_div
-/

end DivisionSemiring

end LinearOrderedField

end IsAbsoluteValue

