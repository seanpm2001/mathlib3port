/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Yury Kudryashov

! This file was ported from Lean 3 source module order.monotone.extension
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.ConditionallyCompleteLattice.Basic

/-!
# Extension of a monotone function from a set to the whole space

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that if a function is monotone and is bounded on a set `s`, then it admits a
monotone extension to the whole space.
-/


open Set

variable {α β : Type _} [LinearOrder α] [ConditionallyCompleteLinearOrder β] {f : α → β} {s : Set α}
  {a b : α}

#print MonotoneOn.exists_monotone_extension /-
/-- If a function is monotone and is bounded on a set `s`, then it admits a monotone extension to
the whole space. -/
theorem MonotoneOn.exists_monotone_extension (h : MonotoneOn f s) (hl : BddBelow (f '' s))
    (hu : BddAbove (f '' s)) : ∃ g : α → β, Monotone g ∧ EqOn f g s := by
  classical
  /- The extension is defined by `f x = f a` for `x ≤ a`, and `f x` is the supremum of the values
    of `f`  to the left of `x` for `x ≥ a`. -/
  rcases hl with ⟨a, ha⟩
  have hu' : ∀ x, BddAbove (f '' (Iic x ∩ s)) := fun x =>
    hu.mono (image_subset _ (inter_subset_right _ _))
  set g : α → β := fun x => if Disjoint (Iic x) s then a else Sup (f '' (Iic x ∩ s))
  have hgs : eq_on f g s := by
    intro x hx
    simp only [g]
    have : IsGreatest (Iic x ∩ s) x := ⟨⟨right_mem_Iic, hx⟩, fun y hy => hy.1⟩
    rw [if_neg this.nonempty.not_disjoint,
      ((h.mono <| inter_subset_right _ _).map_isGreatest this).csSup_eq]
  refine' ⟨g, fun x y hxy => _, hgs⟩
  by_cases hx : Disjoint (Iic x) s <;> by_cases hy : Disjoint (Iic y) s <;>
    simp only [g, if_pos, if_neg, not_false_iff, *]
  · rcases not_disjoint_iff_nonempty_inter.1 hy with ⟨z, hz⟩
    exact le_csSup_of_le (hu' _) (mem_image_of_mem _ hz) (ha <| mem_image_of_mem _ hz.2)
  · exact (hx <| hy.mono_left <| Iic_subset_Iic.2 hxy).elim
  · rw [not_disjoint_iff_nonempty_inter] at hx hy 
    refine' csSup_le_csSup (hu' _) (hx.image _) (image_subset _ _)
    exact inter_subset_inter_left _ (Iic_subset_Iic.2 hxy)
#align monotone_on.exists_monotone_extension MonotoneOn.exists_monotone_extension
-/

#print AntitoneOn.exists_antitone_extension /-
/-- If a function is antitone and is bounded on a set `s`, then it admits an antitone extension to
the whole space. -/
theorem AntitoneOn.exists_antitone_extension (h : AntitoneOn f s) (hl : BddBelow (f '' s))
    (hu : BddAbove (f '' s)) : ∃ g : α → β, Antitone g ∧ EqOn f g s :=
  h.dual_right.exists_monotone_extension hu hl
#align antitone_on.exists_antitone_extension AntitoneOn.exists_antitone_extension
-/

