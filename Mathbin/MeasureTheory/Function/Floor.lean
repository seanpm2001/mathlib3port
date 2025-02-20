/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module measure_theory.function.floor
! leanprover-community/mathlib commit 4280f5f32e16755ec7985ce11e189b6cd6ff6735
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Constructions.BorelSpace.Basic

/-!
# Measurability of `⌊x⌋` etc

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that `int.floor`, `int.ceil`, `int.fract`, `nat.floor`, and `nat.ceil` are
measurable under some assumptions on the (semi)ring.
-/


open Set

section FloorRing

variable {α R : Type _} [MeasurableSpace α] [LinearOrderedRing R] [FloorRing R] [TopologicalSpace R]
  [OrderTopology R] [MeasurableSpace R]

#print Int.measurable_floor /-
theorem Int.measurable_floor [OpensMeasurableSpace R] : Measurable (Int.floor : R → ℤ) :=
  measurable_to_countable fun x => by
    simpa only [Int.preimage_floor_singleton] using measurableSet_Ico
#align int.measurable_floor Int.measurable_floor
-/

#print Measurable.floor /-
@[measurability]
theorem Measurable.floor [OpensMeasurableSpace R] {f : α → R} (hf : Measurable f) :
    Measurable fun x => ⌊f x⌋ :=
  Int.measurable_floor.comp hf
#align measurable.floor Measurable.floor
-/

#print Int.measurable_ceil /-
theorem Int.measurable_ceil [OpensMeasurableSpace R] : Measurable (Int.ceil : R → ℤ) :=
  measurable_to_countable fun x => by
    simpa only [Int.preimage_ceil_singleton] using measurableSet_Ioc
#align int.measurable_ceil Int.measurable_ceil
-/

#print Measurable.ceil /-
@[measurability]
theorem Measurable.ceil [OpensMeasurableSpace R] {f : α → R} (hf : Measurable f) :
    Measurable fun x => ⌈f x⌉ :=
  Int.measurable_ceil.comp hf
#align measurable.ceil Measurable.ceil
-/

#print measurable_fract /-
theorem measurable_fract [BorelSpace R] : Measurable (Int.fract : R → R) :=
  by
  intro s hs
  rw [Int.preimage_fract]
  exact MeasurableSet.iUnion fun z => measurable_id.sub_const _ (hs.inter measurableSet_Ico)
#align measurable_fract measurable_fract
-/

#print Measurable.fract /-
@[measurability]
theorem Measurable.fract [BorelSpace R] {f : α → R} (hf : Measurable f) :
    Measurable fun x => Int.fract (f x) :=
  measurable_fract.comp hf
#align measurable.fract Measurable.fract
-/

#print MeasurableSet.image_fract /-
theorem MeasurableSet.image_fract [BorelSpace R] {s : Set R} (hs : MeasurableSet s) :
    MeasurableSet (Int.fract '' s) :=
  by
  simp only [Int.image_fract, sub_eq_add_neg, image_add_right']
  exact MeasurableSet.iUnion fun m => (measurable_add_const _ hs).inter measurableSet_Ico
#align measurable_set.image_fract MeasurableSet.image_fract
-/

end FloorRing

section FloorSemiring

variable {α R : Type _} [MeasurableSpace α] [LinearOrderedSemiring R] [FloorSemiring R]
  [TopologicalSpace R] [OrderTopology R] [MeasurableSpace R] [OpensMeasurableSpace R] {f : α → R}

#print Nat.measurable_floor /-
theorem Nat.measurable_floor : Measurable (Nat.floor : R → ℕ) :=
  measurable_to_countable fun n => by
    cases eq_or_ne ⌊n⌋₊ 0 <;> simp [*, Nat.preimage_floor_of_ne_zero]
#align nat.measurable_floor Nat.measurable_floor
-/

#print Measurable.nat_floor /-
@[measurability]
theorem Measurable.nat_floor (hf : Measurable f) : Measurable fun x => ⌊f x⌋₊ :=
  Nat.measurable_floor.comp hf
#align measurable.nat_floor Measurable.nat_floor
-/

#print Nat.measurable_ceil /-
theorem Nat.measurable_ceil : Measurable (Nat.ceil : R → ℕ) :=
  measurable_to_countable fun n => by
    cases eq_or_ne ⌈n⌉₊ 0 <;> simp [*, Nat.preimage_ceil_of_ne_zero]
#align nat.measurable_ceil Nat.measurable_ceil
-/

#print Measurable.nat_ceil /-
@[measurability]
theorem Measurable.nat_ceil (hf : Measurable f) : Measurable fun x => ⌈f x⌉₊ :=
  Nat.measurable_ceil.comp hf
#align measurable.nat_ceil Measurable.nat_ceil
-/

end FloorSemiring

