/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Buzzard, Johan Commelin, Patrick Massot

! This file was ported from Lean 3 source module ring_theory.valuation.quotient
! leanprover-community/mathlib commit 19cb3751e5e9b3d97adb51023949c50c13b5fdfd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Valuation.Basic
import Mathbin.RingTheory.Ideal.QuotientOperations

/-!
# The valuation on a quotient ring

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The support of a valuation `v : valuation R Γ₀` is `supp v`. If `J` is an ideal of `R`
with `h : J ⊆ supp v` then the induced valuation
on R / J = `ideal.quotient J` is `on_quot v h`.

-/


namespace Valuation

variable {R Γ₀ : Type _} [CommRing R] [LinearOrderedCommMonoidWithZero Γ₀]

variable (v : Valuation R Γ₀)

#print Valuation.onQuotVal /-
/-- If `hJ : J ⊆ supp v` then `on_quot_val hJ` is the induced function on R/J as a function.
Note: it's just the function; the valuation is `on_quot hJ`. -/
def onQuotVal {J : Ideal R} (hJ : J ≤ supp v) : R ⧸ J → Γ₀ := fun q =>
  Quotient.liftOn' q v fun a b h =>
    calc
      v a = v (b + -(-a + b)) := by simp
      _ = v b :=
        v.map_add_supp b <| (Ideal.neg_mem_iff _).2 <| hJ <| QuotientAddGroup.leftRel_apply.mp h
#align valuation.on_quot_val Valuation.onQuotVal
-/

#print Valuation.onQuot /-
/-- The extension of valuation v on R to valuation on R/J if J ⊆ supp v -/
def onQuot {J : Ideal R} (hJ : J ≤ supp v) : Valuation (R ⧸ J) Γ₀
    where
  toFun := v.onQuotVal hJ
  map_zero' := v.map_zero
  map_one' := v.map_one
  map_mul' xbar ybar := Quotient.ind₂' v.map_mul xbar ybar
  map_add_le_max' xbar ybar := Quotient.ind₂' v.map_add xbar ybar
#align valuation.on_quot Valuation.onQuot
-/

#print Valuation.onQuot_comap_eq /-
@[simp]
theorem onQuot_comap_eq {J : Ideal R} (hJ : J ≤ supp v) :
    (v.onQuot hJ).comap (Ideal.Quotient.mk J) = v :=
  ext fun r => rfl
#align valuation.on_quot_comap_eq Valuation.onQuot_comap_eq
-/

#print Valuation.self_le_supp_comap /-
theorem self_le_supp_comap (J : Ideal R) (v : Valuation (R ⧸ J) Γ₀) :
    J ≤ (v.comap (Ideal.Quotient.mk J)).supp := by rw [comap_supp, ← Ideal.map_le_iff_le_comap];
  simp
#align valuation.self_le_supp_comap Valuation.self_le_supp_comap
-/

#print Valuation.comap_onQuot_eq /-
@[simp]
theorem comap_onQuot_eq (J : Ideal R) (v : Valuation (R ⧸ J) Γ₀) :
    (v.comap (Ideal.Quotient.mk J)).onQuot (v.self_le_supp_comap J) = v :=
  ext <| by rintro ⟨x⟩; rfl
#align valuation.comap_on_quot_eq Valuation.comap_onQuot_eq
-/

#print Valuation.supp_quot /-
/-- The quotient valuation on R/J has support supp(v)/J if J ⊆ supp v. -/
theorem supp_quot {J : Ideal R} (hJ : J ≤ supp v) :
    supp (v.onQuot hJ) = (supp v).map (Ideal.Quotient.mk J) :=
  by
  apply le_antisymm
  · rintro ⟨x⟩ hx
    apply Ideal.subset_span
    exact ⟨x, hx, rfl⟩
  · rw [Ideal.map_le_iff_le_comap]
    intro x hx; exact hx
#align valuation.supp_quot Valuation.supp_quot
-/

#print Valuation.supp_quot_supp /-
theorem supp_quot_supp : supp (v.onQuot le_rfl) = 0 := by rw [supp_quot];
  exact Ideal.map_quotient_self _
#align valuation.supp_quot_supp Valuation.supp_quot_supp
-/

end Valuation

namespace AddValuation

variable {R Γ₀ : Type _}

variable [CommRing R] [LinearOrderedAddCommMonoidWithTop Γ₀]

variable (v : AddValuation R Γ₀)

attribute [local reducible] AddValuation

#print AddValuation.onQuotVal /-
/-- If `hJ : J ⊆ supp v` then `on_quot_val hJ` is the induced function on R/J as a function.
Note: it's just the function; the valuation is `on_quot hJ`. -/
def onQuotVal {J : Ideal R} (hJ : J ≤ supp v) : R ⧸ J → Γ₀ :=
  v.onQuotVal hJ
#align add_valuation.on_quot_val AddValuation.onQuotVal
-/

#print AddValuation.onQuot /-
/-- The extension of valuation v on R to valuation on R/J if J ⊆ supp v -/
def onQuot {J : Ideal R} (hJ : J ≤ supp v) : AddValuation (R ⧸ J) Γ₀ :=
  v.onQuot hJ
#align add_valuation.on_quot AddValuation.onQuot
-/

#print AddValuation.onQuot_comap_eq /-
@[simp]
theorem onQuot_comap_eq {J : Ideal R} (hJ : J ≤ supp v) :
    (v.onQuot hJ).comap (Ideal.Quotient.mk J) = v :=
  v.onQuot_comap_eq hJ
#align add_valuation.on_quot_comap_eq AddValuation.onQuot_comap_eq
-/

#print AddValuation.comap_supp /-
theorem comap_supp {S : Type _} [CommRing S] (f : S →+* R) :
    supp (v.comap f) = Ideal.comap f v.supp :=
  v.comap_supp f
#align add_valuation.comap_supp AddValuation.comap_supp
-/

#print AddValuation.self_le_supp_comap /-
theorem self_le_supp_comap (J : Ideal R) (v : AddValuation (R ⧸ J) Γ₀) :
    J ≤ (v.comap (Ideal.Quotient.mk J)).supp :=
  v.self_le_supp_comap J
#align add_valuation.self_le_supp_comap AddValuation.self_le_supp_comap
-/

#print AddValuation.comap_onQuot_eq /-
@[simp]
theorem comap_onQuot_eq (J : Ideal R) (v : AddValuation (R ⧸ J) Γ₀) :
    (v.comap (Ideal.Quotient.mk J)).onQuot (v.self_le_supp_comap J) = v :=
  v.comap_onQuot_eq J
#align add_valuation.comap_on_quot_eq AddValuation.comap_onQuot_eq
-/

#print AddValuation.supp_quot /-
/-- The quotient valuation on R/J has support supp(v)/J if J ⊆ supp v. -/
theorem supp_quot {J : Ideal R} (hJ : J ≤ supp v) :
    supp (v.onQuot hJ) = (supp v).map (Ideal.Quotient.mk J) :=
  v.supp_quot hJ
#align add_valuation.supp_quot AddValuation.supp_quot
-/

#print AddValuation.supp_quot_supp /-
theorem supp_quot_supp : supp (v.onQuot le_rfl) = 0 :=
  v.supp_quot_supp
#align add_valuation.supp_quot_supp AddValuation.supp_quot_supp
-/

end AddValuation

