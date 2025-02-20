/-
Copyright (c) 2023 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module data.set.list
! leanprover-community/mathlib commit 31ca6f9cf5f90a6206092cd7f84b359dcb6d52e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Image
import Mathbin.Data.List.Basic
import Mathbin.Data.Fin.Basic

/-!
# Lemmas about `list`s and `set.range`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove lemmas about range of some operations on lists.
-/


open List

variable {α β : Type _} (l : List α)

namespace Set

#print Set.range_list_map /-
theorem range_list_map (f : α → β) : range (map f) = {l | ∀ x ∈ l, x ∈ range f} :=
  by
  refine'
    subset.antisymm (range_subset_iff.2 fun l => forall_mem_map_iff.2 fun y _ => mem_range_self _)
      fun l hl => _
  induction' l with a l ihl; · exact ⟨[], rfl⟩
  rcases ihl fun x hx => hl x <| subset_cons _ _ hx with ⟨l, rfl⟩
  rcases hl a (mem_cons_self _ _) with ⟨a, rfl⟩
  exact ⟨a :: l, map_cons _ _ _⟩
#align set.range_list_map Set.range_list_map
-/

#print Set.range_list_map_coe /-
theorem range_list_map_coe (s : Set α) : range (map (coe : s → α)) = {l | ∀ x ∈ l, x ∈ s} := by
  rw [range_list_map, Subtype.range_coe]
#align set.range_list_map_coe Set.range_list_map_coe
-/

#print Set.range_list_nthLe /-
@[simp]
theorem range_list_nthLe : (range fun k : Fin l.length => l.nthLe k k.2) = {x | x ∈ l} :=
  by
  ext x
  rw [mem_set_of_eq, mem_iff_nth_le]
  exact ⟨fun ⟨⟨n, h₁⟩, h₂⟩ => ⟨n, h₁, h₂⟩, fun ⟨n, h₁, h₂⟩ => ⟨⟨n, h₁⟩, h₂⟩⟩
#align set.range_list_nth_le Set.range_list_nthLe
-/

#print Set.range_list_get? /-
theorem range_list_get? : range l.get? = insert none (some '' {x | x ∈ l}) :=
  by
  rw [← range_list_nth_le, ← range_comp]
  refine' (range_subset_iff.2 fun n => _).antisymm (insert_subset.2 ⟨_, _⟩)
  exacts [(le_or_lt l.length n).imp nth_eq_none_iff.2 fun hlt => ⟨⟨_, _⟩, (nth_le_nth hlt).symm⟩,
    ⟨_, nth_eq_none_iff.2 le_rfl⟩, range_subset_iff.2 fun k => ⟨_, nth_le_nth _⟩]
#align set.range_list_nth Set.range_list_get?
-/

#print Set.range_list_getD /-
@[simp]
theorem range_list_getD (d : α) : (range fun n => l.getD n d) = insert d {x | x ∈ l} :=
  calc
    (range fun n => l.getD n d) = (fun o : Option α => o.getD d) '' range l.get? := by
      simp only [← range_comp, (· ∘ ·), nthd_eq_get_or_else_nth]
    _ = insert d {x | x ∈ l} := by
      simp only [range_list_nth, image_insert_eq, Option.getD, image_image, image_id']
#align set.range_list_nthd Set.range_list_getD
-/

#print Set.range_list_getI /-
@[simp]
theorem range_list_getI [Inhabited α] (l : List α) : range l.getI = insert default {x | x ∈ l} :=
  range_list_getD l default
#align set.range_list_inth Set.range_list_getI
-/

end Set

#print List.canLift /-
/-- If each element of a list can be lifted to some type, then the whole list can be lifted to this
type. -/
instance List.canLift (c) (p) [CanLift α β c p] :
    CanLift (List α) (List β) (List.map c) fun l => ∀ x ∈ l, p x
    where prf l H := by
    rw [← Set.mem_range, Set.range_list_map]
    exact fun a ha => CanLift.prf a (H a ha)
#align list.can_lift List.canLift
-/

