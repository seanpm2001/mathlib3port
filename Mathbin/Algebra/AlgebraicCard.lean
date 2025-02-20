/-
Copyright (c) 2022 Violeta Hernández Palacios. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Violeta Hernández Palacios

! This file was ported from Lean 3 source module algebra.algebraic_card
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.Cardinal
import Mathbin.RingTheory.Algebraic

/-!
### Cardinality of algebraic numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we prove variants of the following result: the cardinality of algebraic numbers under
an R-algebra is at most `# R[X] * ℵ₀`.

Although this can be used to prove that real or complex transcendental numbers exist, a more direct
proof is given by `liouville.is_transcendental`.
-/


universe u v

open Cardinal Polynomial Set

open scoped Cardinal Polynomial

namespace Algebraic

#print Algebraic.infinite_of_charZero /-
theorem infinite_of_charZero (R A : Type _) [CommRing R] [IsDomain R] [Ring A] [Algebra R A]
    [CharZero A] : {x : A | IsAlgebraic R x}.Infinite :=
  infinite_of_injective_forall_mem Nat.cast_injective isAlgebraic_nat
#align algebraic.infinite_of_char_zero Algebraic.infinite_of_charZero
-/

#print Algebraic.aleph0_le_cardinal_mk_of_charZero /-
theorem aleph0_le_cardinal_mk_of_charZero (R A : Type _) [CommRing R] [IsDomain R] [Ring A]
    [Algebra R A] [CharZero A] : ℵ₀ ≤ (#{ x : A // IsAlgebraic R x }) :=
  infinite_iff.1 (Set.infinite_coe_iff.2 <| infinite_of_charZero R A)
#align algebraic.aleph_0_le_cardinal_mk_of_char_zero Algebraic.aleph0_le_cardinal_mk_of_charZero
-/

section lift

variable (R : Type u) (A : Type v) [CommRing R] [CommRing A] [IsDomain A] [Algebra R A]
  [NoZeroSMulDivisors R A]

#print Algebraic.cardinal_mk_lift_le_mul /-
theorem cardinal_mk_lift_le_mul :
    Cardinal.lift.{u} (#{ x : A // IsAlgebraic R x }) ≤ Cardinal.lift.{v} (#R[X]) * ℵ₀ :=
  by
  rw [← mk_ulift, ← mk_ulift]
  choose g hg₁ hg₂ using fun x : {x : A | IsAlgebraic R x} => x.coe_prop
  refine' lift_mk_le_lift_mk_mul_of_lift_mk_preimage_le g fun f => _
  rw [lift_le_aleph_0, le_aleph_0_iff_set_countable]
  suffices : maps_to coe (g ⁻¹' {f}) (f.root_set A)
  exact this.countable_of_inj_on (subtype.coe_injective.inj_on _) (f.root_set_finite A).Countable
  rintro x (rfl : g x = f)
  exact mem_root_set.2 ⟨hg₁ x, hg₂ x⟩
#align algebraic.cardinal_mk_lift_le_mul Algebraic.cardinal_mk_lift_le_mul
-/

#print Algebraic.cardinal_mk_lift_le_max /-
theorem cardinal_mk_lift_le_max :
    Cardinal.lift.{u} (#{ x : A // IsAlgebraic R x }) ≤ max (Cardinal.lift.{v} (#R)) ℵ₀ :=
  (cardinal_mk_lift_le_mul R A).trans <|
    (mul_le_mul_right' (lift_le.2 cardinal_mk_le_max) _).trans <| by simp
#align algebraic.cardinal_mk_lift_le_max Algebraic.cardinal_mk_lift_le_max
-/

#print Algebraic.cardinal_mk_lift_of_infinite /-
@[simp]
theorem cardinal_mk_lift_of_infinite [Infinite R] :
    Cardinal.lift.{u} (#{ x : A // IsAlgebraic R x }) = Cardinal.lift.{v} (#R) :=
  ((cardinal_mk_lift_le_max R A).trans_eq (max_eq_left <| aleph0_le_mk _)).antisymm <|
    lift_mk_le'.2
      ⟨⟨fun x => ⟨algebraMap R A x, isAlgebraic_algebraMap _⟩, fun x y h =>
          NoZeroSMulDivisors.algebraMap_injective R A (Subtype.ext_iff.1 h)⟩⟩
#align algebraic.cardinal_mk_lift_of_infinite Algebraic.cardinal_mk_lift_of_infinite
-/

variable [Countable R]

#print Algebraic.countable /-
@[simp]
protected theorem countable : Set.Countable {x : A | IsAlgebraic R x} :=
  by
  rw [← le_aleph_0_iff_set_countable, ← lift_le]
  apply (cardinal_mk_lift_le_max R A).trans
  simp
#align algebraic.countable Algebraic.countable
-/

#print Algebraic.cardinal_mk_of_countable_of_charZero /-
@[simp]
theorem cardinal_mk_of_countable_of_charZero [CharZero A] [IsDomain R] :
    (#{ x : A // IsAlgebraic R x }) = ℵ₀ :=
  (Algebraic.countable R A).le_aleph0.antisymm (aleph0_le_cardinal_mk_of_charZero R A)
#align algebraic.cardinal_mk_of_countble_of_char_zero Algebraic.cardinal_mk_of_countable_of_charZero
-/

end lift

section NonLift

variable (R A : Type u) [CommRing R] [CommRing A] [IsDomain A] [Algebra R A]
  [NoZeroSMulDivisors R A]

#print Algebraic.cardinal_mk_le_mul /-
theorem cardinal_mk_le_mul : (#{ x : A // IsAlgebraic R x }) ≤ (#R[X]) * ℵ₀ := by
  rw [← lift_id (#_), ← lift_id (#R[X])]; exact cardinal_mk_lift_le_mul R A
#align algebraic.cardinal_mk_le_mul Algebraic.cardinal_mk_le_mul
-/

#print Algebraic.cardinal_mk_le_max /-
theorem cardinal_mk_le_max : (#{ x : A // IsAlgebraic R x }) ≤ max (#R) ℵ₀ := by
  rw [← lift_id (#_), ← lift_id (#R)]; exact cardinal_mk_lift_le_max R A
#align algebraic.cardinal_mk_le_max Algebraic.cardinal_mk_le_max
-/

#print Algebraic.cardinal_mk_of_infinite /-
@[simp]
theorem cardinal_mk_of_infinite [Infinite R] : (#{ x : A // IsAlgebraic R x }) = (#R) :=
  lift_inj.1 <| cardinal_mk_lift_of_infinite R A
#align algebraic.cardinal_mk_of_infinite Algebraic.cardinal_mk_of_infinite
-/

end NonLift

end Algebraic

