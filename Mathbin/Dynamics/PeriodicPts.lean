/-
Copyright (c) 2020 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module dynamics.periodic_pts
! leanprover-community/mathlib commit fac369018417f980cec5fcdafc766a69f88d8cfe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.Iterate
import Mathbin.Data.List.Cycle
import Mathbin.Data.Pnat.Basic
import Mathbin.Data.Nat.Prime
import Mathbin.Dynamics.FixedPoints.Basic
import Mathbin.GroupTheory.GroupAction.Group

/-!
# Periodic points

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A point `x : α` is a periodic point of `f : α → α` of period `n` if `f^[n] x = x`.

## Main definitions

* `is_periodic_pt f n x` : `x` is a periodic point of `f` of period `n`, i.e. `f^[n] x = x`.
  We do not require `n > 0` in the definition.
* `pts_of_period f n` : the set `{x | is_periodic_pt f n x}`. Note that `n` is not required to
  be the minimal period of `x`.
* `periodic_pts f` : the set of all periodic points of `f`.
* `minimal_period f x` : the minimal period of a point `x` under an endomorphism `f` or zero
  if `x` is not a periodic point of `f`.
* `orbit f x`: the cycle `[x, f x, f (f x), ...]` for a periodic point.

## Main statements

We provide “dot syntax”-style operations on terms of the form `h : is_periodic_pt f n x` including
arithmetic operations on `n` and `h.map (hg : semiconj_by g f f')`. We also prove that `f`
is bijective on each set `pts_of_period f n` and on `periodic_pts f`. Finally, we prove that `x`
is a periodic point of `f` of period `n` if and only if `minimal_period f x | n`.

## References

* https://en.wikipedia.org/wiki/Periodic_point

-/


open Set

namespace Function

variable {α : Type _} {β : Type _} {f fa : α → α} {fb : β → β} {x y : α} {m n : ℕ}

#print Function.IsPeriodicPt /-
/-- A point `x` is a periodic point of `f : α → α` of period `n` if `f^[n] x = x`.
Note that we do not require `0 < n` in this definition. Many theorems about periodic points
need this assumption. -/
def IsPeriodicPt (f : α → α) (n : ℕ) (x : α) :=
  IsFixedPt (f^[n]) x
#align function.is_periodic_pt Function.IsPeriodicPt
-/

#print Function.IsFixedPt.isPeriodicPt /-
/-- A fixed point of `f` is a periodic point of `f` of any prescribed period. -/
theorem IsFixedPt.isPeriodicPt (hf : IsFixedPt f x) (n : ℕ) : IsPeriodicPt f n x :=
  hf.iterate n
#align function.is_fixed_pt.is_periodic_pt Function.IsFixedPt.isPeriodicPt
-/

#print Function.is_periodic_id /-
/-- For the identity map, all points are periodic. -/
theorem is_periodic_id (n : ℕ) (x : α) : IsPeriodicPt id n x :=
  (isFixedPt_id x).IsPeriodicPt n
#align function.is_periodic_id Function.is_periodic_id
-/

#print Function.isPeriodicPt_zero /-
/-- Any point is a periodic point of period `0`. -/
theorem isPeriodicPt_zero (f : α → α) (x : α) : IsPeriodicPt f 0 x :=
  isFixedPt_id x
#align function.is_periodic_pt_zero Function.isPeriodicPt_zero
-/

namespace IsPeriodicPt

instance [DecidableEq α] {f : α → α} {n : ℕ} {x : α} : Decidable (IsPeriodicPt f n x) :=
  IsFixedPt.decidable

#print Function.IsPeriodicPt.isFixedPt /-
protected theorem isFixedPt (hf : IsPeriodicPt f n x) : IsFixedPt (f^[n]) x :=
  hf
#align function.is_periodic_pt.is_fixed_pt Function.IsPeriodicPt.isFixedPt
-/

#print Function.IsPeriodicPt.map /-
protected theorem map (hx : IsPeriodicPt fa n x) {g : α → β} (hg : Semiconj g fa fb) :
    IsPeriodicPt fb n (g x) :=
  hx.map (hg.iterate_right n)
#align function.is_periodic_pt.map Function.IsPeriodicPt.map
-/

#print Function.IsPeriodicPt.apply_iterate /-
theorem apply_iterate (hx : IsPeriodicPt f n x) (m : ℕ) : IsPeriodicPt f n ((f^[m]) x) :=
  hx.map <| Commute.iterate_self f m
#align function.is_periodic_pt.apply_iterate Function.IsPeriodicPt.apply_iterate
-/

#print Function.IsPeriodicPt.apply /-
protected theorem apply (hx : IsPeriodicPt f n x) : IsPeriodicPt f n (f x) :=
  hx.apply_iterate 1
#align function.is_periodic_pt.apply Function.IsPeriodicPt.apply
-/

#print Function.IsPeriodicPt.add /-
protected theorem add (hn : IsPeriodicPt f n x) (hm : IsPeriodicPt f m x) :
    IsPeriodicPt f (n + m) x := by rw [is_periodic_pt, iterate_add]; exact hn.comp hm
#align function.is_periodic_pt.add Function.IsPeriodicPt.add
-/

#print Function.IsPeriodicPt.left_of_add /-
theorem left_of_add (hn : IsPeriodicPt f (n + m) x) (hm : IsPeriodicPt f m x) :
    IsPeriodicPt f n x := by rw [is_periodic_pt, iterate_add] at hn ; exact hn.left_of_comp hm
#align function.is_periodic_pt.left_of_add Function.IsPeriodicPt.left_of_add
-/

#print Function.IsPeriodicPt.right_of_add /-
theorem right_of_add (hn : IsPeriodicPt f (n + m) x) (hm : IsPeriodicPt f n x) :
    IsPeriodicPt f m x := by rw [add_comm] at hn ; exact hn.left_of_add hm
#align function.is_periodic_pt.right_of_add Function.IsPeriodicPt.right_of_add
-/

#print Function.IsPeriodicPt.sub /-
protected theorem sub (hm : IsPeriodicPt f m x) (hn : IsPeriodicPt f n x) :
    IsPeriodicPt f (m - n) x := by
  cases' le_total n m with h h
  · refine' left_of_add _ hn
    rwa [tsub_add_cancel_of_le h]
  · rw [tsub_eq_zero_iff_le.mpr h]
    apply is_periodic_pt_zero
#align function.is_periodic_pt.sub Function.IsPeriodicPt.sub
-/

#print Function.IsPeriodicPt.mul_const /-
protected theorem mul_const (hm : IsPeriodicPt f m x) (n : ℕ) : IsPeriodicPt f (m * n) x := by
  simp only [is_periodic_pt, iterate_mul, hm.is_fixed_pt.iterate n]
#align function.is_periodic_pt.mul_const Function.IsPeriodicPt.mul_const
-/

#print Function.IsPeriodicPt.const_mul /-
protected theorem const_mul (hm : IsPeriodicPt f m x) (n : ℕ) : IsPeriodicPt f (n * m) x := by
  simp only [mul_comm n, hm.mul_const n]
#align function.is_periodic_pt.const_mul Function.IsPeriodicPt.const_mul
-/

#print Function.IsPeriodicPt.trans_dvd /-
theorem trans_dvd (hm : IsPeriodicPt f m x) {n : ℕ} (hn : m ∣ n) : IsPeriodicPt f n x :=
  let ⟨k, hk⟩ := hn
  hk.symm ▸ hm.mul_const k
#align function.is_periodic_pt.trans_dvd Function.IsPeriodicPt.trans_dvd
-/

#print Function.IsPeriodicPt.iterate /-
protected theorem iterate (hf : IsPeriodicPt f n x) (m : ℕ) : IsPeriodicPt (f^[m]) n x :=
  by
  rw [is_periodic_pt, ← iterate_mul, mul_comm, iterate_mul]
  exact hf.is_fixed_pt.iterate m
#align function.is_periodic_pt.iterate Function.IsPeriodicPt.iterate
-/

#print Function.IsPeriodicPt.comp /-
theorem comp {g : α → α} (hco : Commute f g) (hf : IsPeriodicPt f n x) (hg : IsPeriodicPt g n x) :
    IsPeriodicPt (f ∘ g) n x := by rw [is_periodic_pt, hco.comp_iterate]; exact hf.comp hg
#align function.is_periodic_pt.comp Function.IsPeriodicPt.comp
-/

#print Function.IsPeriodicPt.comp_lcm /-
theorem comp_lcm {g : α → α} (hco : Commute f g) (hf : IsPeriodicPt f m x)
    (hg : IsPeriodicPt g n x) : IsPeriodicPt (f ∘ g) (Nat.lcm m n) x :=
  (hf.trans_dvd <| Nat.dvd_lcm_left _ _).comp hco (hg.trans_dvd <| Nat.dvd_lcm_right _ _)
#align function.is_periodic_pt.comp_lcm Function.IsPeriodicPt.comp_lcm
-/

#print Function.IsPeriodicPt.left_of_comp /-
theorem left_of_comp {g : α → α} (hco : Commute f g) (hfg : IsPeriodicPt (f ∘ g) n x)
    (hg : IsPeriodicPt g n x) : IsPeriodicPt f n x :=
  by
  rw [is_periodic_pt, hco.comp_iterate] at hfg 
  exact hfg.left_of_comp hg
#align function.is_periodic_pt.left_of_comp Function.IsPeriodicPt.left_of_comp
-/

#print Function.IsPeriodicPt.iterate_mod_apply /-
theorem iterate_mod_apply (h : IsPeriodicPt f n x) (m : ℕ) : (f^[m % n]) x = (f^[m]) x := by
  conv_rhs => rw [← Nat.mod_add_div m n, iterate_add_apply, (h.mul_const _).Eq]
#align function.is_periodic_pt.iterate_mod_apply Function.IsPeriodicPt.iterate_mod_apply
-/

#print Function.IsPeriodicPt.mod /-
protected theorem mod (hm : IsPeriodicPt f m x) (hn : IsPeriodicPt f n x) :
    IsPeriodicPt f (m % n) x :=
  (hn.iterate_mod_apply m).trans hm
#align function.is_periodic_pt.mod Function.IsPeriodicPt.mod
-/

#print Function.IsPeriodicPt.gcd /-
protected theorem gcd (hm : IsPeriodicPt f m x) (hn : IsPeriodicPt f n x) :
    IsPeriodicPt f (m.gcd n) x := by
  revert hm hn
  refine' Nat.gcd.induction m n (fun n h0 hn => _) fun m n hm ih hm hn => _
  · rwa [Nat.gcd_zero_left]
  · rw [Nat.gcd_rec]
    exact ih (hn.mod hm) hm
#align function.is_periodic_pt.gcd Function.IsPeriodicPt.gcd
-/

#print Function.IsPeriodicPt.eq_of_apply_eq_same /-
/-- If `f` sends two periodic points `x` and `y` of the same positive period to the same point,
then `x = y`. For a similar statement about points of different periods see `eq_of_apply_eq`. -/
theorem eq_of_apply_eq_same (hx : IsPeriodicPt f n x) (hy : IsPeriodicPt f n y) (hn : 0 < n)
    (h : f x = f y) : x = y := by
  rw [← hx.eq, ← hy.eq, ← iterate_pred_comp_of_pos f hn, comp_app, h]
#align function.is_periodic_pt.eq_of_apply_eq_same Function.IsPeriodicPt.eq_of_apply_eq_same
-/

#print Function.IsPeriodicPt.eq_of_apply_eq /-
/-- If `f` sends two periodic points `x` and `y` of positive periods to the same point,
then `x = y`. -/
theorem eq_of_apply_eq (hx : IsPeriodicPt f m x) (hy : IsPeriodicPt f n y) (hm : 0 < m) (hn : 0 < n)
    (h : f x = f y) : x = y :=
  (hx.mul_const n).eq_of_apply_eq_same (hy.const_mul m) (mul_pos hm hn) h
#align function.is_periodic_pt.eq_of_apply_eq Function.IsPeriodicPt.eq_of_apply_eq
-/

end IsPeriodicPt

#print Function.ptsOfPeriod /-
/-- The set of periodic points of a given (possibly non-minimal) period. -/
def ptsOfPeriod (f : α → α) (n : ℕ) : Set α :=
  {x : α | IsPeriodicPt f n x}
#align function.pts_of_period Function.ptsOfPeriod
-/

#print Function.mem_ptsOfPeriod /-
@[simp]
theorem mem_ptsOfPeriod : x ∈ ptsOfPeriod f n ↔ IsPeriodicPt f n x :=
  Iff.rfl
#align function.mem_pts_of_period Function.mem_ptsOfPeriod
-/

#print Function.Semiconj.mapsTo_ptsOfPeriod /-
theorem Semiconj.mapsTo_ptsOfPeriod {g : α → β} (h : Semiconj g fa fb) (n : ℕ) :
    MapsTo g (ptsOfPeriod fa n) (ptsOfPeriod fb n) :=
  (h.iterate_right n).mapsTo_fixedPoints
#align function.semiconj.maps_to_pts_of_period Function.Semiconj.mapsTo_ptsOfPeriod
-/

#print Function.bijOn_ptsOfPeriod /-
theorem bijOn_ptsOfPeriod (f : α → α) {n : ℕ} (hn : 0 < n) :
    BijOn f (ptsOfPeriod f n) (ptsOfPeriod f n) :=
  ⟨(Commute.refl f).mapsTo_ptsOfPeriod n, fun x hx y hy hxy => hx.eq_of_apply_eq_same hy hn hxy,
    fun x hx =>
    ⟨(f^[n.pred]) x, hx.apply_iterate _, by
      rw [← comp_app f, comp_iterate_pred_of_pos f hn, hx.eq]⟩⟩
#align function.bij_on_pts_of_period Function.bijOn_ptsOfPeriod
-/

#print Function.directed_ptsOfPeriod_pNat /-
theorem directed_ptsOfPeriod_pNat (f : α → α) : Directed (· ⊆ ·) fun n : ℕ+ => ptsOfPeriod f n :=
  fun m n => ⟨m * n, fun x hx => hx.mul_const n, fun x hx => hx.const_mul m⟩
#align function.directed_pts_of_period_pnat Function.directed_ptsOfPeriod_pNat
-/

#print Function.periodicPts /-
/-- The set of periodic points of a map `f : α → α`. -/
def periodicPts (f : α → α) : Set α :=
  {x : α | ∃ n > 0, IsPeriodicPt f n x}
#align function.periodic_pts Function.periodicPts
-/

#print Function.mk_mem_periodicPts /-
theorem mk_mem_periodicPts (hn : 0 < n) (hx : IsPeriodicPt f n x) : x ∈ periodicPts f :=
  ⟨n, hn, hx⟩
#align function.mk_mem_periodic_pts Function.mk_mem_periodicPts
-/

#print Function.mem_periodicPts /-
theorem mem_periodicPts : x ∈ periodicPts f ↔ ∃ n > 0, IsPeriodicPt f n x :=
  Iff.rfl
#align function.mem_periodic_pts Function.mem_periodicPts
-/

#print Function.isPeriodicPt_of_mem_periodicPts_of_isPeriodicPt_iterate /-
theorem isPeriodicPt_of_mem_periodicPts_of_isPeriodicPt_iterate (hx : x ∈ periodicPts f)
    (hm : IsPeriodicPt f m ((f^[n]) x)) : IsPeriodicPt f m x :=
  by
  rcases hx with ⟨r, hr, hr'⟩
  convert (hm.apply_iterate ((n / r + 1) * r - n)).Eq
  suffices n ≤ (n / r + 1) * r by
    rw [← iterate_add_apply, Nat.sub_add_cancel this, iterate_mul, (hr'.iterate _).Eq]
  rw [add_mul, one_mul]
  exact (Nat.lt_div_mul_add hr).le
#align function.is_periodic_pt_of_mem_periodic_pts_of_is_periodic_pt_iterate Function.isPeriodicPt_of_mem_periodicPts_of_isPeriodicPt_iterate
-/

variable (f)

#print Function.bUnion_ptsOfPeriod /-
theorem bUnion_ptsOfPeriod : (⋃ n > 0, ptsOfPeriod f n) = periodicPts f :=
  Set.ext fun x => by simp [mem_periodic_pts]
#align function.bUnion_pts_of_period Function.bUnion_ptsOfPeriod
-/

#print Function.iUnion_pNat_ptsOfPeriod /-
theorem iUnion_pNat_ptsOfPeriod : (⋃ n : ℕ+, ptsOfPeriod f n) = periodicPts f :=
  iSup_subtype.trans <| bUnion_ptsOfPeriod f
#align function.Union_pnat_pts_of_period Function.iUnion_pNat_ptsOfPeriod
-/

#print Function.bijOn_periodicPts /-
theorem bijOn_periodicPts : BijOn f (periodicPts f) (periodicPts f) :=
  iUnion_pNat_ptsOfPeriod f ▸
    bijOn_iUnion_of_directed (directed_ptsOfPeriod_pNat f) fun i => bijOn_ptsOfPeriod f i.Pos
#align function.bij_on_periodic_pts Function.bijOn_periodicPts
-/

variable {f}

#print Function.Semiconj.mapsTo_periodicPts /-
theorem Semiconj.mapsTo_periodicPts {g : α → β} (h : Semiconj g fa fb) :
    MapsTo g (periodicPts fa) (periodicPts fb) := fun x ⟨n, hn, hx⟩ => ⟨n, hn, hx.map h⟩
#align function.semiconj.maps_to_periodic_pts Function.Semiconj.mapsTo_periodicPts
-/

open scoped Classical

noncomputable section

#print Function.minimalPeriod /-
/-- Minimal period of a point `x` under an endomorphism `f`. If `x` is not a periodic point of `f`,
then `minimal_period f x = 0`. -/
def minimalPeriod (f : α → α) (x : α) :=
  if h : x ∈ periodicPts f then Nat.find h else 0
#align function.minimal_period Function.minimalPeriod
-/

#print Function.isPeriodicPt_minimalPeriod /-
theorem isPeriodicPt_minimalPeriod (f : α → α) (x : α) : IsPeriodicPt f (minimalPeriod f x) x :=
  by
  delta minimal_period
  split_ifs with hx
  · exact (Nat.find_spec hx).snd
  · exact is_periodic_pt_zero f x
#align function.is_periodic_pt_minimal_period Function.isPeriodicPt_minimalPeriod
-/

#print Function.iterate_minimalPeriod /-
@[simp]
theorem iterate_minimalPeriod : (f^[minimalPeriod f x]) x = x :=
  isPeriodicPt_minimalPeriod f x
#align function.iterate_minimal_period Function.iterate_minimalPeriod
-/

#print Function.iterate_add_minimalPeriod_eq /-
@[simp]
theorem iterate_add_minimalPeriod_eq : (f^[n + minimalPeriod f x]) x = (f^[n]) x := by
  rw [iterate_add_apply]; congr; exact is_periodic_pt_minimal_period f x
#align function.iterate_add_minimal_period_eq Function.iterate_add_minimalPeriod_eq
-/

#print Function.iterate_mod_minimalPeriod_eq /-
@[simp]
theorem iterate_mod_minimalPeriod_eq : (f^[n % minimalPeriod f x]) x = (f^[n]) x :=
  (isPeriodicPt_minimalPeriod f x).iterate_mod_apply n
#align function.iterate_mod_minimal_period_eq Function.iterate_mod_minimalPeriod_eq
-/

#print Function.minimalPeriod_pos_of_mem_periodicPts /-
theorem minimalPeriod_pos_of_mem_periodicPts (hx : x ∈ periodicPts f) : 0 < minimalPeriod f x := by
  simp only [minimal_period, dif_pos hx, (Nat.find_spec hx).fst.lt]
#align function.minimal_period_pos_of_mem_periodic_pts Function.minimalPeriod_pos_of_mem_periodicPts
-/

#print Function.minimalPeriod_eq_zero_of_nmem_periodicPts /-
theorem minimalPeriod_eq_zero_of_nmem_periodicPts (hx : x ∉ periodicPts f) :
    minimalPeriod f x = 0 := by simp only [minimal_period, dif_neg hx]
#align function.minimal_period_eq_zero_of_nmem_periodic_pts Function.minimalPeriod_eq_zero_of_nmem_periodicPts
-/

#print Function.IsPeriodicPt.minimalPeriod_pos /-
theorem IsPeriodicPt.minimalPeriod_pos (hn : 0 < n) (hx : IsPeriodicPt f n x) :
    0 < minimalPeriod f x :=
  minimalPeriod_pos_of_mem_periodicPts <| mk_mem_periodicPts hn hx
#align function.is_periodic_pt.minimal_period_pos Function.IsPeriodicPt.minimalPeriod_pos
-/

#print Function.minimalPeriod_pos_iff_mem_periodicPts /-
theorem minimalPeriod_pos_iff_mem_periodicPts : 0 < minimalPeriod f x ↔ x ∈ periodicPts f :=
  ⟨not_imp_not.1 fun h => by simp only [minimal_period, dif_neg h, lt_irrefl 0, not_false_iff],
    minimalPeriod_pos_of_mem_periodicPts⟩
#align function.minimal_period_pos_iff_mem_periodic_pts Function.minimalPeriod_pos_iff_mem_periodicPts
-/

#print Function.minimalPeriod_eq_zero_iff_nmem_periodicPts /-
theorem minimalPeriod_eq_zero_iff_nmem_periodicPts : minimalPeriod f x = 0 ↔ x ∉ periodicPts f := by
  rw [← minimal_period_pos_iff_mem_periodic_pts, not_lt, nonpos_iff_eq_zero]
#align function.minimal_period_eq_zero_iff_nmem_periodic_pts Function.minimalPeriod_eq_zero_iff_nmem_periodicPts
-/

#print Function.IsPeriodicPt.minimalPeriod_le /-
theorem IsPeriodicPt.minimalPeriod_le (hn : 0 < n) (hx : IsPeriodicPt f n x) :
    minimalPeriod f x ≤ n :=
  by
  rw [minimal_period, dif_pos (mk_mem_periodic_pts hn hx)]
  exact Nat.find_min' (mk_mem_periodic_pts hn hx) ⟨hn, hx⟩
#align function.is_periodic_pt.minimal_period_le Function.IsPeriodicPt.minimalPeriod_le
-/

#print Function.minimalPeriod_apply_iterate /-
theorem minimalPeriod_apply_iterate (hx : x ∈ periodicPts f) (n : ℕ) :
    minimalPeriod f ((f^[n]) x) = minimalPeriod f x :=
  by
  apply
    (is_periodic_pt.minimal_period_le (minimal_period_pos_of_mem_periodic_pts hx) _).antisymm
      ((is_periodic_pt_of_mem_periodic_pts_of_is_periodic_pt_iterate hx
            (is_periodic_pt_minimal_period f _)).minimalPeriod_le
        (minimal_period_pos_of_mem_periodic_pts _))
  · exact (is_periodic_pt_minimal_period f x).apply_iterate n
  · rcases hx with ⟨m, hm, hx⟩
    exact ⟨m, hm, hx.apply_iterate n⟩
#align function.minimal_period_apply_iterate Function.minimalPeriod_apply_iterate
-/

#print Function.minimalPeriod_apply /-
theorem minimalPeriod_apply (hx : x ∈ periodicPts f) : minimalPeriod f (f x) = minimalPeriod f x :=
  minimalPeriod_apply_iterate hx 1
#align function.minimal_period_apply Function.minimalPeriod_apply
-/

#print Function.le_of_lt_minimalPeriod_of_iterate_eq /-
theorem le_of_lt_minimalPeriod_of_iterate_eq {m n : ℕ} (hm : m < minimalPeriod f x)
    (hmn : (f^[m]) x = (f^[n]) x) : m ≤ n :=
  by
  by_contra' hmn'
  rw [← Nat.add_sub_of_le hmn'.le, add_comm, iterate_add_apply] at hmn 
  exact
    ((is_periodic_pt.minimal_period_le (tsub_pos_of_lt hmn')
              (is_periodic_pt_of_mem_periodic_pts_of_is_periodic_pt_iterate
                (minimal_period_pos_iff_mem_periodic_pts.1 ((zero_le m).trans_lt hm)) hmn)).trans
          (Nat.sub_le m n)).not_lt
      hm
#align function.le_of_lt_minimal_period_of_iterate_eq Function.le_of_lt_minimalPeriod_of_iterate_eq
-/

#print Function.eq_of_lt_minimalPeriod_of_iterate_eq /-
theorem eq_of_lt_minimalPeriod_of_iterate_eq {m n : ℕ} (hm : m < minimalPeriod f x)
    (hn : n < minimalPeriod f x) (hmn : (f^[m]) x = (f^[n]) x) : m = n :=
  (le_of_lt_minimalPeriod_of_iterate_eq hm hmn).antisymm
    (le_of_lt_minimalPeriod_of_iterate_eq hn hmn.symm)
#align function.eq_of_lt_minimal_period_of_iterate_eq Function.eq_of_lt_minimalPeriod_of_iterate_eq
-/

#print Function.eq_iff_lt_minimalPeriod_of_iterate_eq /-
theorem eq_iff_lt_minimalPeriod_of_iterate_eq {m n : ℕ} (hm : m < minimalPeriod f x)
    (hn : n < minimalPeriod f x) : (f^[m]) x = (f^[n]) x ↔ m = n :=
  ⟨eq_of_lt_minimalPeriod_of_iterate_eq hm hn, congr_arg _⟩
#align function.eq_iff_lt_minimal_period_of_iterate_eq Function.eq_iff_lt_minimalPeriod_of_iterate_eq
-/

#print Function.minimalPeriod_id /-
theorem minimalPeriod_id : minimalPeriod id x = 1 :=
  ((is_periodic_id _ _).minimalPeriod_le Nat.one_pos).antisymm
    (Nat.succ_le_of_lt ((is_periodic_id _ _).minimalPeriod_pos Nat.one_pos))
#align function.minimal_period_id Function.minimalPeriod_id
-/

#print Function.minimalPeriod_eq_one_iff_isFixedPt /-
theorem minimalPeriod_eq_one_iff_isFixedPt : minimalPeriod f x = 1 ↔ IsFixedPt f x :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · rw [← iterate_one f]
    refine' Function.IsPeriodicPt.isFixedPt _
    rw [← h]
    exact is_periodic_pt_minimal_period f x
  ·
    exact
      ((h.is_periodic_pt 1).minimalPeriod_le Nat.one_pos).antisymm
        (Nat.succ_le_of_lt ((h.is_periodic_pt 1).minimalPeriod_pos Nat.one_pos))
#align function.is_fixed_point_iff_minimal_period_eq_one Function.minimalPeriod_eq_one_iff_isFixedPt
-/

#print Function.IsPeriodicPt.eq_zero_of_lt_minimalPeriod /-
theorem IsPeriodicPt.eq_zero_of_lt_minimalPeriod (hx : IsPeriodicPt f n x)
    (hn : n < minimalPeriod f x) : n = 0 :=
  Eq.symm <|
    (eq_or_lt_of_le <| n.zero_le).resolve_right fun hn0 => not_lt.2 (hx.minimalPeriod_le hn0) hn
#align function.is_periodic_pt.eq_zero_of_lt_minimal_period Function.IsPeriodicPt.eq_zero_of_lt_minimalPeriod
-/

#print Function.not_isPeriodicPt_of_pos_of_lt_minimalPeriod /-
theorem not_isPeriodicPt_of_pos_of_lt_minimalPeriod :
    ∀ {n : ℕ} (n0 : n ≠ 0) (hn : n < minimalPeriod f x), ¬IsPeriodicPt f n x
  | 0, n0, _ => (n0 rfl).elim
  | n + 1, _, hn => fun hp => Nat.succ_ne_zero _ (hp.eq_zero_of_lt_minimalPeriod hn)
#align function.not_is_periodic_pt_of_pos_of_lt_minimal_period Function.not_isPeriodicPt_of_pos_of_lt_minimalPeriod
-/

#print Function.IsPeriodicPt.minimalPeriod_dvd /-
theorem IsPeriodicPt.minimalPeriod_dvd (hx : IsPeriodicPt f n x) : minimalPeriod f x ∣ n :=
  (eq_or_lt_of_le <| n.zero_le).elim (fun hn0 => hn0 ▸ dvd_zero _) fun hn0 =>
    Nat.dvd_iff_mod_eq_zero.2 <|
      (hx.mod <| isPeriodicPt_minimalPeriod f x).eq_zero_of_lt_minimalPeriod <|
        Nat.mod_lt _ <| hx.minimalPeriod_pos hn0
#align function.is_periodic_pt.minimal_period_dvd Function.IsPeriodicPt.minimalPeriod_dvd
-/

#print Function.isPeriodicPt_iff_minimalPeriod_dvd /-
theorem isPeriodicPt_iff_minimalPeriod_dvd : IsPeriodicPt f n x ↔ minimalPeriod f x ∣ n :=
  ⟨IsPeriodicPt.minimalPeriod_dvd, fun h => (isPeriodicPt_minimalPeriod f x).trans_dvd h⟩
#align function.is_periodic_pt_iff_minimal_period_dvd Function.isPeriodicPt_iff_minimalPeriod_dvd
-/

open Nat

#print Function.minimalPeriod_eq_minimalPeriod_iff /-
theorem minimalPeriod_eq_minimalPeriod_iff {g : β → β} {y : β} :
    minimalPeriod f x = minimalPeriod g y ↔ ∀ n, IsPeriodicPt f n x ↔ IsPeriodicPt g n y := by
  simp_rw [is_periodic_pt_iff_minimal_period_dvd, dvd_right_iff_eq]
#align function.minimal_period_eq_minimal_period_iff Function.minimalPeriod_eq_minimalPeriod_iff
-/

#print Function.minimalPeriod_eq_prime /-
theorem minimalPeriod_eq_prime {p : ℕ} [hp : Fact p.Prime] (hper : IsPeriodicPt f p x)
    (hfix : ¬IsFixedPt f x) : minimalPeriod f x = p :=
  (hp.out.eq_one_or_self_of_dvd _ hper.minimalPeriod_dvd).resolve_left
    (mt minimalPeriod_eq_one_iff_isFixedPt.1 hfix)
#align function.minimal_period_eq_prime Function.minimalPeriod_eq_prime
-/

#print Function.minimalPeriod_eq_prime_pow /-
theorem minimalPeriod_eq_prime_pow {p k : ℕ} [hp : Fact p.Prime] (hk : ¬IsPeriodicPt f (p ^ k) x)
    (hk1 : IsPeriodicPt f (p ^ (k + 1)) x) : minimalPeriod f x = p ^ (k + 1) := by
  apply Nat.eq_prime_pow_of_dvd_least_prime_pow hp.out <;>
    rwa [← is_periodic_pt_iff_minimal_period_dvd]
#align function.minimal_period_eq_prime_pow Function.minimalPeriod_eq_prime_pow
-/

#print Function.Commute.minimalPeriod_of_comp_dvd_lcm /-
theorem Commute.minimalPeriod_of_comp_dvd_lcm {g : α → α} (h : Function.Commute f g) :
    minimalPeriod (f ∘ g) x ∣ Nat.lcm (minimalPeriod f x) (minimalPeriod g x) :=
  by
  rw [← is_periodic_pt_iff_minimal_period_dvd]
  exact (is_periodic_pt_minimal_period f x).comp_lcm h (is_periodic_pt_minimal_period g x)
#align function.commute.minimal_period_of_comp_dvd_lcm Function.Commute.minimalPeriod_of_comp_dvd_lcm
-/

#print Function.Commute.minimalPeriod_of_comp_dvd_mul /-
theorem Commute.minimalPeriod_of_comp_dvd_mul {g : α → α} (h : Function.Commute f g) :
    minimalPeriod (f ∘ g) x ∣ minimalPeriod f x * minimalPeriod g x :=
  dvd_trans h.minimalPeriod_of_comp_dvd_lcm (lcm_dvd_mul _ _)
#align function.commute.minimal_period_of_comp_dvd_mul Function.Commute.minimalPeriod_of_comp_dvd_mul
-/

#print Function.Commute.minimalPeriod_of_comp_eq_mul_of_coprime /-
theorem Commute.minimalPeriod_of_comp_eq_mul_of_coprime {g : α → α} (h : Function.Commute f g)
    (hco : coprime (minimalPeriod f x) (minimalPeriod g x)) :
    minimalPeriod (f ∘ g) x = minimalPeriod f x * minimalPeriod g x :=
  by
  apply dvd_antisymm h.minimal_period_of_comp_dvd_mul
  suffices :
    ∀ {f g : α → α},
      Commute f g →
        coprime (minimal_period f x) (minimal_period g x) →
          minimal_period f x ∣ minimal_period (f ∘ g) x
  exact hco.mul_dvd_of_dvd_of_dvd (this h hco) (h.comp_eq.symm ▸ this h.symm hco.symm)
  clear hco h f g
  intro f g h hco
  refine' hco.dvd_of_dvd_mul_left (is_periodic_pt.left_of_comp h _ _).minimalPeriod_dvd
  · exact (is_periodic_pt_minimal_period _ _).const_mul _
  · exact (is_periodic_pt_minimal_period _ _).mul_const _
#align function.commute.minimal_period_of_comp_eq_mul_of_coprime Function.Commute.minimalPeriod_of_comp_eq_mul_of_coprime
-/

private theorem minimal_period_iterate_eq_div_gcd_aux (h : 0 < gcd (minimalPeriod f x) n) :
    minimalPeriod (f^[n]) x = minimalPeriod f x / Nat.gcd (minimalPeriod f x) n :=
  by
  apply Nat.dvd_antisymm
  · apply is_periodic_pt.minimal_period_dvd
    rw [is_periodic_pt, is_fixed_pt, ← iterate_mul, ← Nat.mul_div_assoc _ (gcd_dvd_left _ _),
      mul_comm, Nat.mul_div_assoc _ (gcd_dvd_right _ _), mul_comm, iterate_mul]
    exact (is_periodic_pt_minimal_period f x).iterate _
  · apply coprime.dvd_of_dvd_mul_right (coprime_div_gcd_div_gcd h)
    apply dvd_of_mul_dvd_mul_right h
    rw [Nat.div_mul_cancel (gcd_dvd_left _ _), mul_assoc, Nat.div_mul_cancel (gcd_dvd_right _ _),
      mul_comm]
    apply is_periodic_pt.minimal_period_dvd
    rw [is_periodic_pt, is_fixed_pt, iterate_mul]
    exact is_periodic_pt_minimal_period _ _

#print Function.minimalPeriod_iterate_eq_div_gcd /-
theorem minimalPeriod_iterate_eq_div_gcd (h : n ≠ 0) :
    minimalPeriod (f^[n]) x = minimalPeriod f x / Nat.gcd (minimalPeriod f x) n :=
  minimalPeriod_iterate_eq_div_gcd_aux <| gcd_pos_of_pos_right _ (Nat.pos_of_ne_zero h)
#align function.minimal_period_iterate_eq_div_gcd Function.minimalPeriod_iterate_eq_div_gcd
-/

#print Function.minimalPeriod_iterate_eq_div_gcd' /-
theorem minimalPeriod_iterate_eq_div_gcd' (h : x ∈ periodicPts f) :
    minimalPeriod (f^[n]) x = minimalPeriod f x / Nat.gcd (minimalPeriod f x) n :=
  minimalPeriod_iterate_eq_div_gcd_aux <|
    gcd_pos_of_pos_left n (minimalPeriod_pos_iff_mem_periodicPts.mpr h)
#align function.minimal_period_iterate_eq_div_gcd' Function.minimalPeriod_iterate_eq_div_gcd'
-/

#print Function.periodicOrbit /-
/-- The orbit of a periodic point `x` of `f` is the cycle `[x, f x, f (f x), ...]`. Its length is
the minimal period of `x`.

If `x` is not a periodic point, then this is the empty (aka nil) cycle. -/
def periodicOrbit (f : α → α) (x : α) : Cycle α :=
  (List.range (minimalPeriod f x)).map fun n => (f^[n]) x
#align function.periodic_orbit Function.periodicOrbit
-/

#print Function.periodicOrbit_def /-
/-- The definition of a periodic orbit, in terms of `list.map`. -/
theorem periodicOrbit_def (f : α → α) (x : α) :
    periodicOrbit f x = (List.range (minimalPeriod f x)).map fun n => (f^[n]) x :=
  rfl
#align function.periodic_orbit_def Function.periodicOrbit_def
-/

#print Function.periodicOrbit_eq_cycle_map /-
/-- The definition of a periodic orbit, in terms of `cycle.map`. -/
theorem periodicOrbit_eq_cycle_map (f : α → α) (x : α) :
    periodicOrbit f x = (List.range (minimalPeriod f x) : Cycle ℕ).map fun n => (f^[n]) x :=
  rfl
#align function.periodic_orbit_eq_cycle_map Function.periodicOrbit_eq_cycle_map
-/

#print Function.periodicOrbit_length /-
@[simp]
theorem periodicOrbit_length : (periodicOrbit f x).length = minimalPeriod f x := by
  rw [periodic_orbit, Cycle.length_coe, List.length_map, List.length_range]
#align function.periodic_orbit_length Function.periodicOrbit_length
-/

#print Function.periodicOrbit_eq_nil_iff_not_periodic_pt /-
@[simp]
theorem periodicOrbit_eq_nil_iff_not_periodic_pt :
    periodicOrbit f x = Cycle.nil ↔ x ∉ periodicPts f := by simp [periodic_orbit];
  exact minimal_period_eq_zero_iff_nmem_periodic_pts
#align function.periodic_orbit_eq_nil_iff_not_periodic_pt Function.periodicOrbit_eq_nil_iff_not_periodic_pt
-/

#print Function.periodicOrbit_eq_nil_of_not_periodic_pt /-
theorem periodicOrbit_eq_nil_of_not_periodic_pt (h : x ∉ periodicPts f) :
    periodicOrbit f x = Cycle.nil :=
  periodicOrbit_eq_nil_iff_not_periodic_pt.2 h
#align function.periodic_orbit_eq_nil_of_not_periodic_pt Function.periodicOrbit_eq_nil_of_not_periodic_pt
-/

#print Function.mem_periodicOrbit_iff /-
@[simp]
theorem mem_periodicOrbit_iff (hx : x ∈ periodicPts f) :
    y ∈ periodicOrbit f x ↔ ∃ n, (f^[n]) x = y :=
  by
  simp only [periodic_orbit, Cycle.mem_coe_iff, List.mem_map, List.mem_range]
  use fun ⟨a, ha, ha'⟩ => ⟨a, ha'⟩
  rintro ⟨n, rfl⟩
  use n % minimal_period f x, mod_lt _ (minimal_period_pos_of_mem_periodic_pts hx)
  rw [iterate_mod_minimal_period_eq]
#align function.mem_periodic_orbit_iff Function.mem_periodicOrbit_iff
-/

#print Function.iterate_mem_periodicOrbit /-
@[simp]
theorem iterate_mem_periodicOrbit (hx : x ∈ periodicPts f) (n : ℕ) :
    (f^[n]) x ∈ periodicOrbit f x :=
  (mem_periodicOrbit_iff hx).2 ⟨n, rfl⟩
#align function.iterate_mem_periodic_orbit Function.iterate_mem_periodicOrbit
-/

#print Function.self_mem_periodicOrbit /-
@[simp]
theorem self_mem_periodicOrbit (hx : x ∈ periodicPts f) : x ∈ periodicOrbit f x :=
  iterate_mem_periodicOrbit hx 0
#align function.self_mem_periodic_orbit Function.self_mem_periodicOrbit
-/

#print Function.nodup_periodicOrbit /-
theorem nodup_periodicOrbit : (periodicOrbit f x).Nodup :=
  by
  rw [periodic_orbit, Cycle.nodup_coe_iff, List.nodup_map_iff_inj_on (List.nodup_range _)]
  intro m hm n hn hmn
  rw [List.mem_range] at hm hn 
  rwa [eq_iff_lt_minimal_period_of_iterate_eq hm hn] at hmn 
#align function.nodup_periodic_orbit Function.nodup_periodicOrbit
-/

#print Function.periodicOrbit_apply_iterate_eq /-
theorem periodicOrbit_apply_iterate_eq (hx : x ∈ periodicPts f) (n : ℕ) :
    periodicOrbit f ((f^[n]) x) = periodicOrbit f x :=
  Eq.symm <|
    Cycle.coe_eq_coe.2 <|
      ⟨n, by
        apply List.ext_nthLe _ fun m _ _ => _
        · simp [minimal_period_apply_iterate hx]
        · rw [List.nthLe_rotate _ n m]
          simp [iterate_add_apply]⟩
#align function.periodic_orbit_apply_iterate_eq Function.periodicOrbit_apply_iterate_eq
-/

#print Function.periodicOrbit_apply_eq /-
theorem periodicOrbit_apply_eq (hx : x ∈ periodicPts f) :
    periodicOrbit f (f x) = periodicOrbit f x :=
  periodicOrbit_apply_iterate_eq hx 1
#align function.periodic_orbit_apply_eq Function.periodicOrbit_apply_eq
-/

#print Function.periodicOrbit_chain /-
theorem periodicOrbit_chain (r : α → α → Prop) {f : α → α} {x : α} :
    (periodicOrbit f x).Chain r ↔ ∀ n < minimalPeriod f x, r ((f^[n]) x) ((f^[n + 1]) x) :=
  by
  by_cases hx : x ∈ periodic_pts f
  · have hx' := minimal_period_pos_of_mem_periodic_pts hx
    have hM := Nat.sub_add_cancel (succ_le_iff.2 hx')
    rw [periodic_orbit, ← Cycle.map_coe, Cycle.chain_map, ← hM, Cycle.chain_range_succ]
    refine' ⟨_, fun H => ⟨_, fun m hm => H _ (hm.trans (Nat.lt_succ_self _))⟩⟩
    · rintro ⟨hr, H⟩ n hn
      cases' eq_or_lt_of_le (lt_succ_iff.1 hn) with hM' hM'
      · rwa [hM', hM, iterate_minimal_period]
      · exact H _ hM'
    · rw [iterate_zero_apply]
      nth_rw 3 [← @iterate_minimal_period α f x]
      nth_rw 2 [← hM]
      exact H _ (Nat.lt_succ_self _)
  · rw [periodic_orbit_eq_nil_of_not_periodic_pt hx, minimal_period_eq_zero_of_nmem_periodic_pts hx]
    simp
#align function.periodic_orbit_chain Function.periodicOrbit_chain
-/

#print Function.periodicOrbit_chain' /-
theorem periodicOrbit_chain' (r : α → α → Prop) {f : α → α} {x : α} (hx : x ∈ periodicPts f) :
    (periodicOrbit f x).Chain r ↔ ∀ n, r ((f^[n]) x) ((f^[n + 1]) x) :=
  by
  rw [periodic_orbit_chain r]
  refine' ⟨fun H n => _, fun H n _ => H n⟩
  rw [iterate_succ_apply, ← iterate_mod_minimal_period_eq]
  nth_rw 2 [← iterate_mod_minimal_period_eq]
  rw [← iterate_succ_apply, minimal_period_apply hx]
  exact H _ (mod_lt _ (minimal_period_pos_of_mem_periodic_pts hx))
#align function.periodic_orbit_chain' Function.periodicOrbit_chain'
-/

end Function

namespace MulAction

open Function

variable {α β : Type _} [Group α] [MulAction α β] {a : α} {b : β}

#print MulAction.pow_smul_eq_iff_minimalPeriod_dvd /-
@[to_additive]
theorem pow_smul_eq_iff_minimalPeriod_dvd {n : ℕ} :
    a ^ n • b = b ↔ Function.minimalPeriod ((· • ·) a) b ∣ n := by
  rw [← is_periodic_pt_iff_minimal_period_dvd, is_periodic_pt, is_fixed_pt, smul_iterate]
#align mul_action.pow_smul_eq_iff_minimal_period_dvd MulAction.pow_smul_eq_iff_minimalPeriod_dvd
#align add_action.nsmul_vadd_eq_iff_minimal_period_dvd AddAction.nsmul_vadd_eq_iff_minimalPeriod_dvd
-/

#print MulAction.zpow_smul_eq_iff_minimalPeriod_dvd /-
@[to_additive]
theorem zpow_smul_eq_iff_minimalPeriod_dvd {n : ℤ} :
    a ^ n • b = b ↔ (Function.minimalPeriod ((· • ·) a) b : ℤ) ∣ n :=
  by
  cases n
  · rw [Int.ofNat_eq_coe, zpow_ofNat, Int.coe_nat_dvd, pow_smul_eq_iff_minimal_period_dvd]
  ·
    rw [Int.negSucc_coe, zpow_neg, zpow_ofNat, inv_smul_eq_iff, eq_comm, dvd_neg, Int.coe_nat_dvd,
      pow_smul_eq_iff_minimal_period_dvd]
#align mul_action.zpow_smul_eq_iff_minimal_period_dvd MulAction.zpow_smul_eq_iff_minimalPeriod_dvd
#align add_action.zsmul_vadd_eq_iff_minimal_period_dvd AddAction.zsmul_vadd_eq_iff_minimalPeriod_dvd
-/

variable (a b)

#print MulAction.pow_smul_mod_minimalPeriod /-
@[simp, to_additive]
theorem pow_smul_mod_minimalPeriod (n : ℕ) :
    a ^ (n % Function.minimalPeriod ((· • ·) a) b) • b = a ^ n • b := by
  conv_rhs =>
    rw [← Nat.mod_add_div n (minimal_period ((· • ·) a) b), pow_add, mul_smul,
      pow_smul_eq_iff_minimal_period_dvd.mpr (dvd_mul_right _ _)]
#align mul_action.pow_smul_mod_minimal_period MulAction.pow_smul_mod_minimalPeriod
#align add_action.nsmul_vadd_mod_minimal_period AddAction.nsmul_vadd_mod_minimalPeriod
-/

#print MulAction.zpow_smul_mod_minimalPeriod /-
@[simp, to_additive]
theorem zpow_smul_mod_minimalPeriod (n : ℤ) :
    a ^ (n % (Function.minimalPeriod ((· • ·) a) b : ℤ)) • b = a ^ n • b := by
  conv_rhs =>
    rw [← Int.emod_add_ediv n (minimal_period ((· • ·) a) b), zpow_add, mul_smul,
      zpow_smul_eq_iff_minimal_period_dvd.mpr (dvd_mul_right _ _)]
#align mul_action.zpow_smul_mod_minimal_period MulAction.zpow_smul_mod_minimalPeriod
#align add_action.zsmul_vadd_mod_minimal_period AddAction.zsmul_vadd_mod_minimalPeriod
-/

end MulAction

