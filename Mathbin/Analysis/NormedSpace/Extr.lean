/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.normed_space.extr
! leanprover-community/mathlib commit 4f4a1c875d0baa92ab5d92f3fb1bb258ad9f3e5b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Ray
import Mathbin.Topology.LocalExtr

/-!
# (Local) maximums in a normed space

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove the following lemma, see `is_max_filter.norm_add_same_ray`. If `f : α → E` is
a function such that `norm ∘ f` has a maximum along a filter `l` at a point `c` and `y` is a vector
on the same ray as `f c`, then the function `λ x, ‖f x + y‖` has a maximul along `l` at `c`.

Then we specialize it to the case `y = f c` and to different special cases of `is_max_filter`:
`is_max_on`, `is_local_max_on`, and `is_local_max`.

## Tags

local maximum, normed space
-/


variable {α X E : Type _} [SeminormedAddCommGroup E] [NormedSpace ℝ E] [TopologicalSpace X]

section

variable {f : α → E} {l : Filter α} {s : Set α} {c : α} {y : E}

#print IsMaxFilter.norm_add_sameRay /-
/-- If `f : α → E` is a function such that `norm ∘ f` has a maximum along a filter `l` at a point
`c` and `y` is a vector on the same ray as `f c`, then the function `λ x, ‖f x + y‖` has a maximul
along `l` at `c`. -/
theorem IsMaxFilter.norm_add_sameRay (h : IsMaxFilter (norm ∘ f) l c) (hy : SameRay ℝ (f c) y) :
    IsMaxFilter (fun x => ‖f x + y‖) l c :=
  h.mono fun x hx =>
    calc
      ‖f x + y‖ ≤ ‖f x‖ + ‖y‖ := norm_add_le _ _
      _ ≤ ‖f c‖ + ‖y‖ := (add_le_add_right hx _)
      _ = ‖f c + y‖ := hy.norm_add.symm
#align is_max_filter.norm_add_same_ray IsMaxFilter.norm_add_sameRay
-/

#print IsMaxFilter.norm_add_self /-
/-- If `f : α → E` is a function such that `norm ∘ f` has a maximum along a filter `l` at a point
`c`, then the function `λ x, ‖f x + f c‖` has a maximul along `l` at `c`. -/
theorem IsMaxFilter.norm_add_self (h : IsMaxFilter (norm ∘ f) l c) :
    IsMaxFilter (fun x => ‖f x + f c‖) l c :=
  h.norm_add_sameRay SameRay.rfl
#align is_max_filter.norm_add_self IsMaxFilter.norm_add_self
-/

#print IsMaxOn.norm_add_sameRay /-
/-- If `f : α → E` is a function such that `norm ∘ f` has a maximum on a set `s` at a point `c` and
`y` is a vector on the same ray as `f c`, then the function `λ x, ‖f x + y‖` has a maximul on `s` at
`c`. -/
theorem IsMaxOn.norm_add_sameRay (h : IsMaxOn (norm ∘ f) s c) (hy : SameRay ℝ (f c) y) :
    IsMaxOn (fun x => ‖f x + y‖) s c :=
  h.norm_add_sameRay hy
#align is_max_on.norm_add_same_ray IsMaxOn.norm_add_sameRay
-/

#print IsMaxOn.norm_add_self /-
/-- If `f : α → E` is a function such that `norm ∘ f` has a maximum on a set `s` at a point `c`,
then the function `λ x, ‖f x + f c‖` has a maximul on `s` at `c`. -/
theorem IsMaxOn.norm_add_self (h : IsMaxOn (norm ∘ f) s c) : IsMaxOn (fun x => ‖f x + f c‖) s c :=
  h.norm_add_self
#align is_max_on.norm_add_self IsMaxOn.norm_add_self
-/

end

variable {f : X → E} {s : Set X} {c : X} {y : E}

#print IsLocalMaxOn.norm_add_sameRay /-
/-- If `f : α → E` is a function such that `norm ∘ f` has a local maximum on a set `s` at a point
`c` and `y` is a vector on the same ray as `f c`, then the function `λ x, ‖f x + y‖` has a local
maximul on `s` at `c`. -/
theorem IsLocalMaxOn.norm_add_sameRay (h : IsLocalMaxOn (norm ∘ f) s c) (hy : SameRay ℝ (f c) y) :
    IsLocalMaxOn (fun x => ‖f x + y‖) s c :=
  h.norm_add_sameRay hy
#align is_local_max_on.norm_add_same_ray IsLocalMaxOn.norm_add_sameRay
-/

#print IsLocalMaxOn.norm_add_self /-
/-- If `f : α → E` is a function such that `norm ∘ f` has a local maximum on a set `s` at a point
`c`, then the function `λ x, ‖f x + f c‖` has a local maximul on `s` at `c`. -/
theorem IsLocalMaxOn.norm_add_self (h : IsLocalMaxOn (norm ∘ f) s c) :
    IsLocalMaxOn (fun x => ‖f x + f c‖) s c :=
  h.norm_add_self
#align is_local_max_on.norm_add_self IsLocalMaxOn.norm_add_self
-/

#print IsLocalMax.norm_add_sameRay /-
/-- If `f : α → E` is a function such that `norm ∘ f` has a local maximum at a point `c` and `y` is
a vector on the same ray as `f c`, then the function `λ x, ‖f x + y‖` has a local maximul at `c`. -/
theorem IsLocalMax.norm_add_sameRay (h : IsLocalMax (norm ∘ f) c) (hy : SameRay ℝ (f c) y) :
    IsLocalMax (fun x => ‖f x + y‖) c :=
  h.norm_add_sameRay hy
#align is_local_max.norm_add_same_ray IsLocalMax.norm_add_sameRay
-/

#print IsLocalMax.norm_add_self /-
/-- If `f : α → E` is a function such that `norm ∘ f` has a local maximum at a point `c`, then the
function `λ x, ‖f x + f c‖` has a local maximul at `c`. -/
theorem IsLocalMax.norm_add_self (h : IsLocalMax (norm ∘ f) c) :
    IsLocalMax (fun x => ‖f x + f c‖) c :=
  h.norm_add_self
#align is_local_max.norm_add_self IsLocalMax.norm_add_self
-/

