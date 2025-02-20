/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov, Heather Macbeth

! This file was ported from Lean 3 source module analysis.normed.group.ball_sphere
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Normed.Group.Basic

/-!
# Negation on spheres and balls

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `has_involutive_neg` instances for spheres, open balls, and closed balls in a
semi normed group.
-/


open Metric Set

variable {E : Type _} [SeminormedAddCommGroup E] {r : ℝ}

/-- We equip the sphere, in a seminormed group, with a formal operation of negation, namely the
antipodal map. -/
instance : InvolutiveNeg (sphere (0 : E) r)
    where
  neg := Subtype.map Neg.neg fun w => by simp
  neg_neg x := Subtype.ext <| neg_neg x

#print coe_neg_sphere /-
@[simp]
theorem coe_neg_sphere {r : ℝ} (v : sphere (0 : E) r) : ↑(-v) = (-v : E) :=
  rfl
#align coe_neg_sphere coe_neg_sphere
-/

instance : ContinuousNeg (sphere (0 : E) r) :=
  ⟨continuous_neg.subtypeMap _⟩

/-- We equip the ball, in a seminormed group, with a formal operation of negation, namely the
antipodal map. -/
instance {r : ℝ} : InvolutiveNeg (ball (0 : E) r)
    where
  neg := Subtype.map Neg.neg fun w => by simp
  neg_neg x := Subtype.ext <| neg_neg x

#print coe_neg_ball /-
@[simp]
theorem coe_neg_ball {r : ℝ} (v : ball (0 : E) r) : ↑(-v) = (-v : E) :=
  rfl
#align coe_neg_ball coe_neg_ball
-/

instance : ContinuousNeg (ball (0 : E) r) :=
  ⟨continuous_neg.subtypeMap _⟩

/-- We equip the closed ball, in a seminormed group, with a formal operation of negation, namely the
antipodal map. -/
instance {r : ℝ} : InvolutiveNeg (closedBall (0 : E) r)
    where
  neg := Subtype.map Neg.neg fun w => by simp
  neg_neg x := Subtype.ext <| neg_neg x

#print coe_neg_closedBall /-
@[simp]
theorem coe_neg_closedBall {r : ℝ} (v : closedBall (0 : E) r) : ↑(-v) = (-v : E) :=
  rfl
#align coe_neg_closed_ball coe_neg_closedBall
-/

instance : ContinuousNeg (closedBall (0 : E) r) :=
  ⟨continuous_neg.subtypeMap _⟩

