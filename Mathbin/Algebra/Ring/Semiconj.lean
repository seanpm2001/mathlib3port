/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Floris van Doorn, Yury Kudryashov, Neil Strickland

! This file was ported from Lean 3 source module algebra.ring.semiconj
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.Semiconj
import Mathbin.Algebra.Ring.Defs

/-!
# Semirings and rings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file gives lemmas about semirings, rings and domains.
This is analogous to `algebra.group.basic`,
the difference being that the former is about `+` and `*` separately, while
the present file is about their interaction.

For the definitions of semirings and rings see `algebra.ring.defs`.

-/


universe u v w x

variable {α : Type u} {β : Type v} {γ : Type w} {R : Type x}

open Function

namespace SemiconjBy

#print SemiconjBy.add_right /-
@[simp]
theorem add_right [Distrib R] {a x y x' y' : R} (h : SemiconjBy a x y) (h' : SemiconjBy a x' y') :
    SemiconjBy a (x + x') (y + y') := by
  simp only [SemiconjBy, left_distrib, right_distrib, h.eq, h'.eq]
#align semiconj_by.add_right SemiconjBy.add_right
-/

#print SemiconjBy.add_left /-
@[simp]
theorem add_left [Distrib R] {a b x y : R} (ha : SemiconjBy a x y) (hb : SemiconjBy b x y) :
    SemiconjBy (a + b) x y := by simp only [SemiconjBy, left_distrib, right_distrib, ha.eq, hb.eq]
#align semiconj_by.add_left SemiconjBy.add_left
-/

section

variable [Mul R] [HasDistribNeg R] {a x y : R}

#print SemiconjBy.neg_right /-
theorem neg_right (h : SemiconjBy a x y) : SemiconjBy a (-x) (-y) := by
  simp only [SemiconjBy, h.eq, neg_mul, mul_neg]
#align semiconj_by.neg_right SemiconjBy.neg_right
-/

#print SemiconjBy.neg_right_iff /-
@[simp]
theorem neg_right_iff : SemiconjBy a (-x) (-y) ↔ SemiconjBy a x y :=
  ⟨fun h => neg_neg x ▸ neg_neg y ▸ h.neg_right, SemiconjBy.neg_right⟩
#align semiconj_by.neg_right_iff SemiconjBy.neg_right_iff
-/

#print SemiconjBy.neg_left /-
theorem neg_left (h : SemiconjBy a x y) : SemiconjBy (-a) x y := by
  simp only [SemiconjBy, h.eq, neg_mul, mul_neg]
#align semiconj_by.neg_left SemiconjBy.neg_left
-/

#print SemiconjBy.neg_left_iff /-
@[simp]
theorem neg_left_iff : SemiconjBy (-a) x y ↔ SemiconjBy a x y :=
  ⟨fun h => neg_neg a ▸ h.neg_left, SemiconjBy.neg_left⟩
#align semiconj_by.neg_left_iff SemiconjBy.neg_left_iff
-/

end

section

variable [MulOneClass R] [HasDistribNeg R] {a x y : R}

#print SemiconjBy.neg_one_right /-
@[simp]
theorem neg_one_right (a : R) : SemiconjBy a (-1) (-1) :=
  (one_right a).neg_right
#align semiconj_by.neg_one_right SemiconjBy.neg_one_right
-/

#print SemiconjBy.neg_one_left /-
@[simp]
theorem neg_one_left (x : R) : SemiconjBy (-1) x x :=
  (SemiconjBy.one_left x).neg_left
#align semiconj_by.neg_one_left SemiconjBy.neg_one_left
-/

end

section

variable [NonUnitalNonAssocRing R] {a b x y x' y' : R}

#print SemiconjBy.sub_right /-
@[simp]
theorem sub_right (h : SemiconjBy a x y) (h' : SemiconjBy a x' y') :
    SemiconjBy a (x - x') (y - y') := by simpa only [sub_eq_add_neg] using h.add_right h'.neg_right
#align semiconj_by.sub_right SemiconjBy.sub_right
-/

#print SemiconjBy.sub_left /-
@[simp]
theorem sub_left (ha : SemiconjBy a x y) (hb : SemiconjBy b x y) : SemiconjBy (a - b) x y := by
  simpa only [sub_eq_add_neg] using ha.add_left hb.neg_left
#align semiconj_by.sub_left SemiconjBy.sub_left
-/

end

end SemiconjBy

