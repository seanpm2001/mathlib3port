/-
Copyright (c) 2022 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module topology.instances.add_circle
! leanprover-community/mathlib commit 2ed2c6310e6f1c5562bdf6bfbda55ebbf6891abe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Totient
import Mathbin.Algebra.Ring.AddAut
import Mathbin.GroupTheory.Divisible
import Mathbin.GroupTheory.OrderOfElement
import Mathbin.Algebra.Order.Floor
import Mathbin.Algebra.Order.ToIntervalMod
import Mathbin.Topology.Instances.Real

/-!
# The additive circle

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define the additive circle `add_circle p` as the quotient `𝕜 ⧸ (ℤ ∙ p)` for some period `p : 𝕜`.

See also `circle` and `real.angle`.  For the normed group structure on `add_circle`, see
`add_circle.normed_add_comm_group` in a later file.

## Main definitions and results:

 * `add_circle`: the additive circle `𝕜 ⧸ (ℤ ∙ p)` for some period `p : 𝕜`
 * `unit_add_circle`: the special case `ℝ ⧸ ℤ`
 * `add_circle.equiv_add_circle`: the rescaling equivalence `add_circle p ≃+ add_circle q`
 * `add_circle.equiv_Ico`: the natural equivalence `add_circle p ≃ Ico a (a + p)`
 * `add_circle.add_order_of_div_of_gcd_eq_one`: rational points have finite order
 * `add_circle.exists_gcd_eq_one_of_is_of_fin_add_order`: finite-order points are rational
 * `add_circle.homeo_Icc_quot`: the natural topological equivalence between `add_circle p` and
   `Icc a (a + p)` with its endpoints identified.
 * `add_circle.lift_Ico_continuous`: if `f : ℝ → B` is continuous, and `f a = f (a + p)` for
   some `a`, then there is a continuous function `add_circle p → B` which agrees with `f` on
   `Icc a (a + p)`.

## Implementation notes:

Although the most important case is `𝕜 = ℝ` we wish to support other types of scalars, such as
the rational circle `add_circle (1 : ℚ)`, and so we set things up more generally.

## TODO

 * Link with periodicity
 * Lie group structure
 * Exponential equivalence to `circle`

-/


noncomputable section

open AddCommGroup Set Function AddSubgroup TopologicalSpace

open scoped Topology

variable {𝕜 B : Type _}

section Continuity

variable [LinearOrderedAddCommGroup 𝕜] [Archimedean 𝕜] [TopologicalSpace 𝕜] [OrderTopology 𝕜]
  {p : 𝕜} (hp : 0 < p) (a x : 𝕜)

#print continuous_right_toIcoMod /-
theorem continuous_right_toIcoMod : ContinuousWithinAt (toIcoMod hp a) (Ici x) x :=
  by
  intro s h
  rw [Filter.mem_map, mem_nhdsWithin_iff_exists_mem_nhds_inter]
  haveI : Nontrivial 𝕜 := ⟨⟨0, p, hp.ne⟩⟩
  simp_rw [mem_nhds_iff_exists_Ioo_subset] at h ⊢
  obtain ⟨l, u, hxI, hIs⟩ := h
  let d := toIcoDiv hp a x • p
  have hd := toIcoMod_mem_Ico hp a x
  simp_rw [subset_def, mem_inter_iff]
  refine' ⟨_, ⟨l + d, min (a + p) u + d, _, fun x => id⟩, fun y => _⟩ <;>
    simp_rw [← sub_mem_Ioo_iff_left, mem_Ioo, lt_min_iff]
  · exact ⟨hxI.1, hd.2, hxI.2⟩
  · rintro ⟨h, h'⟩; apply hIs
    rw [← toIcoMod_sub_zsmul, (toIcoMod_eq_self _).2]
    exacts [⟨h.1, h.2.2⟩, ⟨hd.1.trans (sub_le_sub_right h' _), h.2.1⟩]
#align continuous_right_to_Ico_mod continuous_right_toIcoMod
-/

#print continuous_left_toIocMod /-
theorem continuous_left_toIocMod : ContinuousWithinAt (toIocMod hp a) (Iic x) x :=
  by
  rw [(funext fun y => Eq.trans (by rw [neg_neg]) <| toIocMod_neg _ _ _ :
      toIocMod hp a = (fun x => p - x) ∘ toIcoMod hp (-a) ∘ Neg.neg)]
  exact
    (continuous_sub_left _).ContinuousAt.comp_continuousWithinAt <|
      (continuous_right_toIcoMod _ _ _).comp continuous_neg.continuous_within_at fun y => neg_le_neg
#align continuous_left_to_Ioc_mod continuous_left_toIocMod
-/

variable {x} (hx : (x : 𝕜 ⧸ zmultiples p) ≠ a)

#print toIcoMod_eventuallyEq_toIocMod /-
theorem toIcoMod_eventuallyEq_toIocMod : toIcoMod hp a =ᶠ[𝓝 x] toIocMod hp a :=
  IsOpen.mem_nhds
      (by rw [Ico_eq_locus_Ioc_eq_iUnion_Ioo]; exact isOpen_iUnion fun i => isOpen_Ioo) <|
    (not_modEq_iff_toIcoMod_eq_toIocMod hp).1 <| not_modEq_iff_ne_mod_zmultiples.2 hx
#align to_Ico_mod_eventually_eq_to_Ioc_mod toIcoMod_eventuallyEq_toIocMod
-/

#print continuousAt_toIcoMod /-
theorem continuousAt_toIcoMod : ContinuousAt (toIcoMod hp a) x :=
  let h := toIcoMod_eventuallyEq_toIocMod hp a hx
  continuousAt_iff_continuous_left_right.2 <|
    ⟨(continuous_left_toIocMod hp a x).congr_of_eventuallyEq (h.filter_mono nhdsWithin_le_nhds)
        h.eq_of_nhds,
      continuous_right_toIcoMod hp a x⟩
#align continuous_at_to_Ico_mod continuousAt_toIcoMod
-/

#print continuousAt_toIocMod /-
theorem continuousAt_toIocMod : ContinuousAt (toIocMod hp a) x :=
  let h := toIcoMod_eventuallyEq_toIocMod hp a hx
  continuousAt_iff_continuous_left_right.2 <|
    ⟨continuous_left_toIocMod hp a x,
      (continuous_right_toIcoMod hp a x).congr_of_eventuallyEq
        (h.symm.filter_mono nhdsWithin_le_nhds) h.symm.eq_of_nhds⟩
#align continuous_at_to_Ioc_mod continuousAt_toIocMod
-/

end Continuity

/- ./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler has_coe_t[has_coe_t] 𝕜 -/
#print AddCircle /-
/-- The "additive circle": `𝕜 ⧸ (ℤ ∙ p)`. See also `circle` and `real.angle`. -/
@[nolint unused_arguments]
def AddCircle [LinearOrderedAddCommGroup 𝕜] [TopologicalSpace 𝕜] [OrderTopology 𝕜] (p : 𝕜) :=
  𝕜 ⧸ zmultiples p
deriving AddCommGroup, TopologicalSpace, TopologicalAddGroup, Inhabited,
  «./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler has_coe_t[has_coe_t] 𝕜»
#align add_circle AddCircle
-/

namespace AddCircle

section LinearOrderedAddCommGroup

variable [LinearOrderedAddCommGroup 𝕜] [TopologicalSpace 𝕜] [OrderTopology 𝕜] (p : 𝕜)

#print AddCircle.coe_nsmul /-
theorem coe_nsmul {n : ℕ} {x : 𝕜} : (↑(n • x) : AddCircle p) = n • (x : AddCircle p) :=
  rfl
#align add_circle.coe_nsmul AddCircle.coe_nsmul
-/

#print AddCircle.coe_zsmul /-
theorem coe_zsmul {n : ℤ} {x : 𝕜} : (↑(n • x) : AddCircle p) = n • (x : AddCircle p) :=
  rfl
#align add_circle.coe_zsmul AddCircle.coe_zsmul
-/

#print AddCircle.coe_add /-
theorem coe_add (x y : 𝕜) : (↑(x + y) : AddCircle p) = (x : AddCircle p) + (y : AddCircle p) :=
  rfl
#align add_circle.coe_add AddCircle.coe_add
-/

#print AddCircle.coe_sub /-
theorem coe_sub (x y : 𝕜) : (↑(x - y) : AddCircle p) = (x : AddCircle p) - (y : AddCircle p) :=
  rfl
#align add_circle.coe_sub AddCircle.coe_sub
-/

#print AddCircle.coe_neg /-
theorem coe_neg {x : 𝕜} : (↑(-x) : AddCircle p) = -(x : AddCircle p) :=
  rfl
#align add_circle.coe_neg AddCircle.coe_neg
-/

#print AddCircle.coe_eq_zero_iff /-
theorem coe_eq_zero_iff {x : 𝕜} : (x : AddCircle p) = 0 ↔ ∃ n : ℤ, n • p = x := by
  simp [AddSubgroup.mem_zmultiples_iff]
#align add_circle.coe_eq_zero_iff AddCircle.coe_eq_zero_iff
-/

#print AddCircle.coe_eq_zero_of_pos_iff /-
theorem coe_eq_zero_of_pos_iff (hp : 0 < p) {x : 𝕜} (hx : 0 < x) :
    (x : AddCircle p) = 0 ↔ ∃ n : ℕ, n • p = x :=
  by
  rw [coe_eq_zero_iff]
  constructor <;> rintro ⟨n, rfl⟩
  · replace hx : 0 < n
    · contrapose! hx
      simpa only [← neg_nonneg, ← zsmul_neg, zsmul_neg'] using zsmul_nonneg hp.le (neg_nonneg.2 hx)
    exact ⟨n.to_nat, by rw [← coe_nat_zsmul, Int.toNat_of_nonneg hx.le]⟩
  · exact ⟨(n : ℤ), by simp⟩
#align add_circle.coe_eq_zero_of_pos_iff AddCircle.coe_eq_zero_of_pos_iff
-/

#print AddCircle.coe_period /-
theorem coe_period : (p : AddCircle p) = 0 :=
  (QuotientAddGroup.eq_zero_iff p).2 <| mem_zmultiples p
#align add_circle.coe_period AddCircle.coe_period
-/

#print AddCircle.coe_add_period /-
@[simp]
theorem coe_add_period (x : 𝕜) : ((x + p : 𝕜) : AddCircle p) = x := by
  rw [coe_add, ← eq_sub_iff_add_eq', sub_self, coe_period]
#align add_circle.coe_add_period AddCircle.coe_add_period
-/

#print AddCircle.continuous_mk' /-
@[continuity, nolint unused_arguments]
protected theorem continuous_mk' :
    Continuous (QuotientAddGroup.mk' (zmultiples p) : 𝕜 → AddCircle p) :=
  continuous_coinduced_rng
#align add_circle.continuous_mk' AddCircle.continuous_mk'
-/

variable [hp : Fact (0 < p)]

variable (a : 𝕜) [Archimedean 𝕜]

instance : CircularOrder (AddCircle p) :=
  QuotientAddGroup.circularOrder

#print AddCircle.equivIco /-
/-- The equivalence between `add_circle p` and the half-open interval `[a, a + p)`, whose inverse
is the natural quotient map. -/
def equivIco : AddCircle p ≃ Ico a (a + p) :=
  QuotientAddGroup.equivIcoMod hp.out a
#align add_circle.equiv_Ico AddCircle.equivIco
-/

#print AddCircle.equivIoc /-
/-- The equivalence between `add_circle p` and the half-open interval `(a, a + p]`, whose inverse
is the natural quotient map. -/
def equivIoc : AddCircle p ≃ Ioc a (a + p) :=
  QuotientAddGroup.equivIocMod hp.out a
#align add_circle.equiv_Ioc AddCircle.equivIoc
-/

#print AddCircle.liftIco /-
/-- Given a function on `𝕜`, return the unique function on `add_circle p` agreeing with `f` on
`[a, a + p)`. -/
def liftIco (f : 𝕜 → B) : AddCircle p → B :=
  restrict _ f ∘ AddCircle.equivIco p a
#align add_circle.lift_Ico AddCircle.liftIco
-/

#print AddCircle.liftIoc /-
/-- Given a function on `𝕜`, return the unique function on `add_circle p` agreeing with `f` on
`(a, a + p]`. -/
def liftIoc (f : 𝕜 → B) : AddCircle p → B :=
  restrict _ f ∘ AddCircle.equivIoc p a
#align add_circle.lift_Ioc AddCircle.liftIoc
-/

variable {p a}

#print AddCircle.coe_eq_coe_iff_of_mem_Ico /-
theorem coe_eq_coe_iff_of_mem_Ico {x y : 𝕜} (hx : x ∈ Ico a (a + p)) (hy : y ∈ Ico a (a + p)) :
    (x : AddCircle p) = y ↔ x = y :=
  by
  refine' ⟨fun h => _, by tauto⟩
  suffices (⟨x, hx⟩ : Ico a (a + p)) = ⟨y, hy⟩ by exact Subtype.mk.inj this
  apply_fun equiv_Ico p a at h 
  rw [← (equiv_Ico p a).right_inv ⟨x, hx⟩, ← (equiv_Ico p a).right_inv ⟨y, hy⟩]
  exact h
#align add_circle.coe_eq_coe_iff_of_mem_Ico AddCircle.coe_eq_coe_iff_of_mem_Ico
-/

#print AddCircle.liftIco_coe_apply /-
theorem liftIco_coe_apply {f : 𝕜 → B} {x : 𝕜} (hx : x ∈ Ico a (a + p)) : liftIco p a f ↑x = f x :=
  by
  have : (equiv_Ico p a) x = ⟨x, hx⟩ :=
    by
    rw [Equiv.apply_eq_iff_eq_symm_apply]
    rfl
  rw [lift_Ico, comp_apply, this]
  rfl
#align add_circle.lift_Ico_coe_apply AddCircle.liftIco_coe_apply
-/

#print AddCircle.liftIoc_coe_apply /-
theorem liftIoc_coe_apply {f : 𝕜 → B} {x : 𝕜} (hx : x ∈ Ioc a (a + p)) : liftIoc p a f ↑x = f x :=
  by
  have : (equiv_Ioc p a) x = ⟨x, hx⟩ :=
    by
    rw [Equiv.apply_eq_iff_eq_symm_apply]
    rfl
  rw [lift_Ioc, comp_apply, this]
  rfl
#align add_circle.lift_Ioc_coe_apply AddCircle.liftIoc_coe_apply
-/

variable (p a)

section Continuity

#print AddCircle.continuous_equivIco_symm /-
@[continuity]
theorem continuous_equivIco_symm : Continuous (equivIco p a).symm :=
  continuous_quotient_mk'.comp continuous_subtype_val
#align add_circle.continuous_equiv_Ico_symm AddCircle.continuous_equivIco_symm
-/

#print AddCircle.continuous_equivIoc_symm /-
@[continuity]
theorem continuous_equivIoc_symm : Continuous (equivIoc p a).symm :=
  continuous_quotient_mk'.comp continuous_subtype_val
#align add_circle.continuous_equiv_Ioc_symm AddCircle.continuous_equivIoc_symm
-/

variable {x : AddCircle p} (hx : x ≠ a)

#print AddCircle.continuousAt_equivIco /-
theorem continuousAt_equivIco : ContinuousAt (equivIco p a) x :=
  by
  induction x using QuotientAddGroup.induction_on'
  rw [ContinuousAt, Filter.Tendsto, QuotientAddGroup.nhds_eq, Filter.map_map]
  exact (continuousAt_toIcoMod hp.out a hx).codRestrict _
#align add_circle.continuous_at_equiv_Ico AddCircle.continuousAt_equivIco
-/

#print AddCircle.continuousAt_equivIoc /-
theorem continuousAt_equivIoc : ContinuousAt (equivIoc p a) x :=
  by
  induction x using QuotientAddGroup.induction_on'
  rw [ContinuousAt, Filter.Tendsto, QuotientAddGroup.nhds_eq, Filter.map_map]
  exact (continuousAt_toIocMod hp.out a hx).codRestrict _
#align add_circle.continuous_at_equiv_Ioc AddCircle.continuousAt_equivIoc
-/

end Continuity

#print AddCircle.coe_image_Ico_eq /-
/-- The image of the closed-open interval `[a, a + p)` under the quotient map `𝕜 → add_circle p` is
the entire space. -/
@[simp]
theorem coe_image_Ico_eq : (coe : 𝕜 → AddCircle p) '' Ico a (a + p) = univ := by
  rw [image_eq_range]; exact (equiv_Ico p a).symm.range_eq_univ
#align add_circle.coe_image_Ico_eq AddCircle.coe_image_Ico_eq
-/

#print AddCircle.coe_image_Ioc_eq /-
/-- The image of the closed-open interval `[a, a + p)` under the quotient map `𝕜 → add_circle p` is
the entire space. -/
@[simp]
theorem coe_image_Ioc_eq : (coe : 𝕜 → AddCircle p) '' Ioc a (a + p) = univ := by
  rw [image_eq_range]; exact (equiv_Ioc p a).symm.range_eq_univ
#align add_circle.coe_image_Ioc_eq AddCircle.coe_image_Ioc_eq
-/

#print AddCircle.coe_image_Icc_eq /-
/-- The image of the closed interval `[0, p]` under the quotient map `𝕜 → add_circle p` is the
entire space. -/
@[simp]
theorem coe_image_Icc_eq : (coe : 𝕜 → AddCircle p) '' Icc a (a + p) = univ :=
  eq_top_mono (image_subset _ Ico_subset_Icc_self) <| coe_image_Ico_eq _ _
#align add_circle.coe_image_Icc_eq AddCircle.coe_image_Icc_eq
-/

end LinearOrderedAddCommGroup

section LinearOrderedField

variable [LinearOrderedField 𝕜] [TopologicalSpace 𝕜] [OrderTopology 𝕜] (p q : 𝕜)

#print AddCircle.equivAddCircle /-
/-- The rescaling equivalence between additive circles with different periods. -/
def equivAddCircle (hp : p ≠ 0) (hq : q ≠ 0) : AddCircle p ≃+ AddCircle q :=
  QuotientAddGroup.congr _ _ (AddAut.mulRight <| (Units.mk0 p hp)⁻¹ * Units.mk0 q hq) <| by
    rw [AddMonoidHom.map_zmultiples, AddMonoidHom.coe_coe, AddAut.mulRight_apply, Units.val_mul,
      Units.val_mk0, Units.val_inv_eq_inv_val, Units.val_mk0, mul_inv_cancel_left₀ hp]
#align add_circle.equiv_add_circle AddCircle.equivAddCircle
-/

#print AddCircle.equivAddCircle_apply_mk /-
@[simp]
theorem equivAddCircle_apply_mk (hp : p ≠ 0) (hq : q ≠ 0) (x : 𝕜) :
    equivAddCircle p q hp hq (x : 𝕜) = (x * (p⁻¹ * q) : 𝕜) :=
  rfl
#align add_circle.equiv_add_circle_apply_mk AddCircle.equivAddCircle_apply_mk
-/

#print AddCircle.equivAddCircle_symm_apply_mk /-
@[simp]
theorem equivAddCircle_symm_apply_mk (hp : p ≠ 0) (hq : q ≠ 0) (x : 𝕜) :
    (equivAddCircle p q hp hq).symm (x : 𝕜) = (x * (q⁻¹ * p) : 𝕜) :=
  rfl
#align add_circle.equiv_add_circle_symm_apply_mk AddCircle.equivAddCircle_symm_apply_mk
-/

variable [hp : Fact (0 < p)]

section FloorRing

variable [FloorRing 𝕜]

#print AddCircle.coe_equivIco_mk_apply /-
@[simp]
theorem coe_equivIco_mk_apply (x : 𝕜) :
    (equivIco p 0 <| QuotientAddGroup.mk x : 𝕜) = Int.fract (x / p) * p :=
  toIcoMod_eq_fract_mul _ x
#align add_circle.coe_equiv_Ico_mk_apply AddCircle.coe_equivIco_mk_apply
-/

instance : DivisibleBy (AddCircle p) ℤ
    where
  div x n := (↑((n : 𝕜)⁻¹ * (equivIco p 0 x : 𝕜)) : AddCircle p)
  div_zero x := by
    simp only [algebraMap.coe_zero, QuotientAddGroup.mk_zero, inv_zero, MulZeroClass.zero_mul]
  div_cancel n x hn := by
    replace hn : (n : 𝕜) ≠ 0; · norm_cast; assumption
    change n • QuotientAddGroup.mk' _ ((n : 𝕜)⁻¹ * ↑(equiv_Ico p 0 x)) = x
    rw [← map_zsmul, ← smul_mul_assoc, zsmul_eq_mul, mul_inv_cancel hn, one_mul]
    exact (equiv_Ico p 0).symm_apply_apply x

end FloorRing

section FiniteOrderPoints

variable {p}

#print AddCircle.addOrderOf_period_div /-
theorem addOrderOf_period_div {n : ℕ} (h : 0 < n) : addOrderOf ((p / n : 𝕜) : AddCircle p) = n :=
  by
  rw [addOrderOf_eq_iff h]
  replace h : 0 < (n : 𝕜) := Nat.cast_pos.2 h
  refine' ⟨_, fun m hn h0 => _⟩ <;> simp only [Ne, ← coe_nsmul, nsmul_eq_mul]
  · rw [mul_div_cancel' _ h.ne', coe_period]
  rw [coe_eq_zero_of_pos_iff p hp.out (mul_pos (Nat.cast_pos.2 h0) <| div_pos hp.out h)]
  rintro ⟨k, hk⟩
  rw [mul_div, eq_div_iff h.ne', nsmul_eq_mul, mul_right_comm, ← Nat.cast_mul,
    (mul_left_injective₀ hp.out.ne').eq_iff, Nat.cast_inj, mul_comm] at hk 
  exact (Nat.le_of_dvd h0 ⟨_, hk.symm⟩).not_lt hn
#align add_circle.add_order_of_period_div AddCircle.addOrderOf_period_div
-/

variable (p)

#print AddCircle.gcd_mul_addOrderOf_div_eq /-
theorem gcd_mul_addOrderOf_div_eq {n : ℕ} (m : ℕ) (hn : 0 < n) :
    m.gcd n * addOrderOf (↑(↑m / ↑n * p) : AddCircle p) = n :=
  by
  rw [mul_comm_div, ← nsmul_eq_mul, coe_nsmul, addOrderOf_nsmul'']
  · rw [add_order_of_period_div hn, Nat.gcd_comm, Nat.mul_div_cancel']
    exacts [n.gcd_dvd_left m, hp]
  · rw [← addOrderOf_pos_iff, add_order_of_period_div hn]; exacts [hn, hp]
#align add_circle.gcd_mul_add_order_of_div_eq AddCircle.gcd_mul_addOrderOf_div_eq
-/

variable {p}

#print AddCircle.addOrderOf_div_of_gcd_eq_one /-
theorem addOrderOf_div_of_gcd_eq_one {m n : ℕ} (hn : 0 < n) (h : m.gcd n = 1) :
    addOrderOf (↑(↑m / ↑n * p) : AddCircle p) = n := by convert gcd_mul_add_order_of_div_eq p m hn;
  rw [h, one_mul]
#align add_circle.add_order_of_div_of_gcd_eq_one AddCircle.addOrderOf_div_of_gcd_eq_one
-/

#print AddCircle.addOrderOf_div_of_gcd_eq_one' /-
theorem addOrderOf_div_of_gcd_eq_one' {m : ℤ} {n : ℕ} (hn : 0 < n) (h : m.natAbs.gcd n = 1) :
    addOrderOf (↑(↑m / ↑n * p) : AddCircle p) = n :=
  by
  induction m
  · simp only [Int.ofNat_eq_coe, Int.cast_ofNat, Int.natAbs_ofNat] at h ⊢
    exact add_order_of_div_of_gcd_eq_one hn h
  · simp only [Int.cast_negSucc, neg_div, neg_mul, coe_neg, addOrderOf_neg]
    exact add_order_of_div_of_gcd_eq_one hn h
#align add_circle.add_order_of_div_of_gcd_eq_one' AddCircle.addOrderOf_div_of_gcd_eq_one'
-/

#print AddCircle.addOrderOf_coe_rat /-
theorem addOrderOf_coe_rat {q : ℚ} : addOrderOf (↑(↑q * p) : AddCircle p) = q.den :=
  by
  have : (↑(q.denom : ℤ) : 𝕜) ≠ 0 := by norm_cast; exact q.pos.ne.symm
  rw [← @Rat.num_den q, Rat.cast_mk_of_ne_zero _ _ this, Int.cast_ofNat, Rat.num_den,
    add_order_of_div_of_gcd_eq_one' q.pos q.cop]
  infer_instance
#align add_circle.add_order_of_coe_rat AddCircle.addOrderOf_coe_rat
-/

#print AddCircle.addOrderOf_eq_pos_iff /-
theorem addOrderOf_eq_pos_iff {u : AddCircle p} {n : ℕ} (h : 0 < n) :
    addOrderOf u = n ↔ ∃ m < n, m.gcd n = 1 ∧ ↑(↑m / ↑n * p) = u :=
  by
  refine' ⟨QuotientAddGroup.induction_on' u fun k hk => _, _⟩; swap
  · rintro ⟨m, h₀, h₁, rfl⟩; exact add_order_of_div_of_gcd_eq_one h h₁
  have h0 := addOrderOf_nsmul_eq_zero (k : AddCircle p)
  rw [hk, ← coe_nsmul, coe_eq_zero_iff] at h0 
  obtain ⟨a, ha⟩ := h0
  have h0 : (_ : 𝕜) ≠ 0 := Nat.cast_ne_zero.2 h.ne'
  rw [nsmul_eq_mul, mul_comm, ← div_eq_iff h0, ← a.div_add_mod' n, add_smul, add_div, zsmul_eq_mul,
    Int.cast_mul, Int.cast_ofNat, mul_assoc, ← mul_div, mul_comm _ p, mul_div_cancel p h0] at ha 
  have han : _ = a % n := Int.toNat_of_nonneg (Int.emod_nonneg _ <| by exact_mod_cast h.ne')
  have he := _; refine' ⟨(a % n).toNat, _, _, he⟩
  · rw [← Int.ofNat_lt, han]
    exact Int.emod_lt_of_pos _ (Int.ofNat_lt.2 h)
  · have := (gcd_mul_add_order_of_div_eq p _ h).trans ((congr_arg addOrderOf he).trans hk).symm
    rw [he, Nat.mul_left_eq_self_iff] at this ; · exact this; · rwa [hk]
  convert congr_arg coe ha using 1
  rw [coe_add, ← Int.cast_ofNat, han, zsmul_eq_mul, mul_div_right_comm, eq_comm, add_left_eq_self, ←
    zsmul_eq_mul, coe_zsmul, coe_period, smul_zero]
#align add_circle.add_order_of_eq_pos_iff AddCircle.addOrderOf_eq_pos_iff
-/

#print AddCircle.exists_gcd_eq_one_of_isOfFinAddOrder /-
theorem exists_gcd_eq_one_of_isOfFinAddOrder {u : AddCircle p} (h : IsOfFinAddOrder u) :
    ∃ m : ℕ, m.gcd (addOrderOf u) = 1 ∧ m < addOrderOf u ∧ ↑((m : 𝕜) / addOrderOf u * p) = u :=
  let ⟨m, hl, hg, he⟩ := (addOrderOf_eq_pos_iff <| addOrderOf_pos' h).1 rfl
  ⟨m, hg, hl, he⟩
#align add_circle.exists_gcd_eq_one_of_is_of_fin_add_order AddCircle.exists_gcd_eq_one_of_isOfFinAddOrder
-/

variable (p)

#print AddCircle.setAddOrderOfEquiv /-
/-- The natural bijection between points of order `n` and natural numbers less than and coprime to
`n`. The inverse of the map sends `m ↦ (m/n * p : add_circle p)` where `m` is coprime to `n` and
satisfies `0 ≤ m < n`. -/
def setAddOrderOfEquiv {n : ℕ} (hn : 0 < n) :
    {u : AddCircle p | addOrderOf u = n} ≃ {m | m < n ∧ m.gcd n = 1} :=
  Equiv.symm <|
    Equiv.ofBijective (fun m => ⟨↑((m : 𝕜) / n * p), addOrderOf_div_of_gcd_eq_one hn m.Prop.2⟩)
      (by
        refine' ⟨fun m₁ m₂ h => Subtype.ext _, fun u => _⟩
        · simp_rw [Subtype.ext_iff, Subtype.coe_mk] at h 
          rw [← sub_eq_zero, ← coe_sub, ← sub_mul, ← sub_div, coe_coe, coe_coe, ← Int.cast_ofNat m₁,
            ← Int.cast_ofNat m₂, ← Int.cast_sub, coe_eq_zero_iff] at h 
          obtain ⟨m, hm⟩ := h
          rw [← mul_div_right_comm, eq_div_iff, mul_comm, ← zsmul_eq_mul, mul_smul_comm, ←
            nsmul_eq_mul, ← coe_nat_zsmul, smul_smul,
            (zsmul_strictMono_left hp.out).Injective.eq_iff, mul_comm] at hm 
          swap; · exact Nat.cast_ne_zero.2 hn.ne'
          rw [← @Nat.cast_inj ℤ, ← sub_eq_zero]
          refine' Int.eq_zero_of_abs_lt_dvd ⟨_, hm.symm⟩ (abs_sub_lt_iff.2 ⟨_, _⟩) <;>
            apply (Int.sub_le_self _ <| Nat.cast_nonneg _).trans_lt (Nat.cast_lt.2 _)
          exacts [m₁.2.1, m₂.2.1]
        obtain ⟨m, hmn, hg, he⟩ := (add_order_of_eq_pos_iff hn).mp u.2
        exact ⟨⟨m, hmn, hg⟩, Subtype.ext he⟩)
#align add_circle.set_add_order_of_equiv AddCircle.setAddOrderOfEquiv
-/

#print AddCircle.card_addOrderOf_eq_totient /-
@[simp]
theorem card_addOrderOf_eq_totient {n : ℕ} :
    Nat.card { u : AddCircle p // addOrderOf u = n } = n.totient :=
  by
  rcases n.eq_zero_or_pos with (rfl | hn)
  · simp only [Nat.totient_zero, addOrderOf_eq_zero_iff]
    rcases em (∃ u : AddCircle p, ¬IsOfFinAddOrder u) with (⟨u, hu⟩ | h)
    · have : Infinite { u : AddCircle p // ¬IsOfFinAddOrder u } :=
        by
        erw [infinite_coe_iff]
        exact infinite_not_isOfFinAddOrder hu
      exact Nat.card_eq_zero_of_infinite
    · have : IsEmpty { u : AddCircle p // ¬IsOfFinAddOrder u } := by simpa using h
      exact Nat.card_of_isEmpty
  · rw [← coe_set_of, Nat.card_congr (set_add_order_of_equiv p hn),
      n.totient_eq_card_lt_and_coprime]
    simp only [Nat.gcd_comm]
#align add_circle.card_add_order_of_eq_totient AddCircle.card_addOrderOf_eq_totient
-/

#print AddCircle.finite_setOf_add_order_eq /-
theorem finite_setOf_add_order_eq {n : ℕ} (hn : 0 < n) :
    {u : AddCircle p | addOrderOf u = n}.Finite :=
  finite_coe_iff.mp <|
    Nat.finite_of_card_ne_zero <| by
      simpa only [coe_set_of, card_add_order_of_eq_totient p] using (Nat.totient_pos hn).ne'
#align add_circle.finite_set_of_add_order_eq AddCircle.finite_setOf_add_order_eq
-/

end FiniteOrderPoints

end LinearOrderedField

variable (p : ℝ)

#print AddCircle.compactSpace /-
/-- The "additive circle" `ℝ ⧸ (ℤ ∙ p)` is compact. -/
instance compactSpace [Fact (0 < p)] : CompactSpace <| AddCircle p :=
  by
  rw [← isCompact_univ_iff, ← coe_image_Icc_eq p 0]
  exact is_compact_Icc.image (AddCircle.continuous_mk' p)
#align add_circle.compact_space AddCircle.compactSpace
-/

/-- The action on `ℝ` by right multiplication of its the subgroup `zmultiples p` (the multiples of
`p:ℝ`) is properly discontinuous. -/
instance : ProperlyDiscontinuousVAdd (zmultiples p).opposite ℝ :=
  (zmultiples p).properlyDiscontinuousVAdd_opposite_of_tendsto_cofinite
    (AddSubgroup.tendsto_zmultiples_subtype_cofinite p)

/-- The "additive circle" `ℝ ⧸ (ℤ ∙ p)` is Hausdorff. -/
instance : T2Space (AddCircle p) :=
  t2Space_of_properlyDiscontinuousVAdd_of_t2Space

/-- The "additive circle" `ℝ ⧸ (ℤ ∙ p)` is normal. -/
instance [Fact (0 < p)] : NormalSpace (AddCircle p) :=
  normalOfCompactT2

/-- The "additive circle" `ℝ ⧸ (ℤ ∙ p)` is second-countable. -/
instance : SecondCountableTopology (AddCircle p) :=
  QuotientAddGroup.secondCountableTopology

end AddCircle

attribute [local instance] Real.fact_zero_lt_one

/- ./././Mathport/Syntax/Translate/Command.lean:328:31: unsupported: @[derive] abbrev -/
#print UnitAddCircle /-
/-- The unit circle `ℝ ⧸ ℤ`. -/
abbrev UnitAddCircle :=
  AddCircle (1 : ℝ)
#align unit_add_circle UnitAddCircle
-/

section IdentifyIccEnds

/-! This section proves that for any `a`, the natural map from `[a, a + p] ⊂ 𝕜` to `add_circle p`
gives an identification of `add_circle p`, as a topological space, with the quotient of `[a, a + p]`
by the equivalence relation identifying the endpoints. -/


namespace AddCircle

variable [LinearOrderedAddCommGroup 𝕜] [TopologicalSpace 𝕜] [OrderTopology 𝕜] (p a : 𝕜)
  [hp : Fact (0 < p)]

local notation "𝕋" => AddCircle p

#print AddCircle.EndpointIdent /-
/-- The relation identifying the endpoints of `Icc a (a + p)`. -/
inductive EndpointIdent : Icc a (a + p) → Icc a (a + p) → Prop
  |
  mk :
    endpoint_ident ⟨a, left_mem_Icc.mpr <| le_add_of_nonneg_right hp.out.le⟩
      ⟨a + p, right_mem_Icc.mpr <| le_add_of_nonneg_right hp.out.le⟩
#align add_circle.endpoint_ident AddCircle.EndpointIdent
-/

variable [Archimedean 𝕜]

#print AddCircle.equivIccQuot /-
/-- The equivalence between `add_circle p` and the quotient of `[a, a + p]` by the relation
identifying the endpoints. -/
def equivIccQuot : 𝕋 ≃ Quot (EndpointIdent p a)
    where
  toFun x := Quot.mk _ <| inclusion Ico_subset_Icc_self (equivIco _ _ x)
  invFun x := Quot.liftOn x coe <| by rintro _ _ ⟨_⟩; exact (coe_add_period p a).symm
  left_inv := (equivIco p a).symm_apply_apply
  right_inv :=
    Quot.ind <| by
      rintro ⟨x, hx⟩
      have := _
      rcases ne_or_eq x (a + p) with (h | rfl)
      · revert x; exact this
      · rw [← Quot.sound endpoint_ident.mk]; exact this _ _ (lt_add_of_pos_right a hp.out).Ne
      intro x hx h
      congr; ext1
      apply congr_arg Subtype.val ((equiv_Ico p a).right_inv ⟨x, hx.1, hx.2.lt_of_ne h⟩)
#align add_circle.equiv_Icc_quot AddCircle.equivIccQuot
-/

#print AddCircle.equivIccQuot_comp_mk_eq_toIcoMod /-
theorem equivIccQuot_comp_mk_eq_toIcoMod :
    equivIccQuot p a ∘ Quotient.mk'' = fun x =>
      Quot.mk _ ⟨toIcoMod hp.out a x, Ico_subset_Icc_self <| toIcoMod_mem_Ico _ _ x⟩ :=
  rfl
#align add_circle.equiv_Icc_quot_comp_mk_eq_to_Ico_mod AddCircle.equivIccQuot_comp_mk_eq_toIcoMod
-/

#print AddCircle.equivIccQuot_comp_mk_eq_toIocMod /-
theorem equivIccQuot_comp_mk_eq_toIocMod :
    equivIccQuot p a ∘ Quotient.mk'' = fun x =>
      Quot.mk _ ⟨toIocMod hp.out a x, Ioc_subset_Icc_self <| toIocMod_mem_Ioc _ _ x⟩ :=
  by
  rw [equiv_Icc_quot_comp_mk_eq_to_Ico_mod]; funext
  by_cases a ≡ x [PMOD p]
  · simp_rw [(modeq_iff_to_Ico_mod_eq_left hp.out).1 h, (modeq_iff_to_Ioc_mod_eq_right hp.out).1 h]
    exact Quot.sound endpoint_ident.mk
  · simp_rw [(not_modeq_iff_to_Ico_mod_eq_to_Ioc_mod hp.out).1 h]
#align add_circle.equiv_Icc_quot_comp_mk_eq_to_Ioc_mod AddCircle.equivIccQuot_comp_mk_eq_toIocMod
-/

#print AddCircle.homeoIccQuot /-
/-- The natural map from `[a, a + p] ⊂ 𝕜` with endpoints identified to `𝕜 / ℤ • p`, as a
homeomorphism of topological spaces. -/
def homeoIccQuot : 𝕋 ≃ₜ Quot (EndpointIdent p a)
    where
  toEquiv := equivIccQuot p a
  continuous_toFun :=
    by
    simp_rw [quotient_map_quotient_mk.continuous_iff, continuous_iff_continuousAt,
      continuousAt_iff_continuous_left_right]
    intro x; constructor
    on_goal 1 => erw [equiv_Icc_quot_comp_mk_eq_to_Ioc_mod]
    on_goal 2 => erw [equiv_Icc_quot_comp_mk_eq_to_Ico_mod]
    all_goals
      apply continuous_quot_mk.continuous_at.comp_continuous_within_at
      rw [inducing_coe.continuous_within_at_iff]
    · apply continuous_left_toIocMod
    · apply continuous_right_toIcoMod
  continuous_invFun :=
    continuous_quot_lift _ ((AddCircle.continuous_mk' p).comp continuous_subtype_val)
#align add_circle.homeo_Icc_quot AddCircle.homeoIccQuot
-/

/-! We now show that a continuous function on `[a, a + p]` satisfying `f a = f (a + p)` is the
pullback of a continuous function on `add_circle p`. -/


variable {p a}

#print AddCircle.liftIco_eq_lift_Icc /-
theorem liftIco_eq_lift_Icc {f : 𝕜 → B} (h : f a = f (a + p)) :
    liftIco p a f =
      Quot.lift (restrict (Icc a <| a + p) f) (by rintro _ _ ⟨_⟩; exact h) ∘ equivIccQuot p a :=
  rfl
#align add_circle.lift_Ico_eq_lift_Icc AddCircle.liftIco_eq_lift_Icc
-/

#print AddCircle.liftIco_continuous /-
theorem liftIco_continuous [TopologicalSpace B] {f : 𝕜 → B} (hf : f a = f (a + p))
    (hc : ContinuousOn f <| Icc a (a + p)) : Continuous (liftIco p a f) :=
  by
  rw [lift_Ico_eq_lift_Icc hf]
  refine' Continuous.comp _ (homeo_Icc_quot p a).continuous_toFun
  exact continuous_coinduced_dom.mpr (continuous_on_iff_continuous_restrict.mp hc)
#align add_circle.lift_Ico_continuous AddCircle.liftIco_continuous
-/

section ZeroBased

#print AddCircle.liftIco_zero_coe_apply /-
theorem liftIco_zero_coe_apply {f : 𝕜 → B} {x : 𝕜} (hx : x ∈ Ico 0 p) : liftIco p 0 f ↑x = f x :=
  liftIco_coe_apply (by rwa [zero_add])
#align add_circle.lift_Ico_zero_coe_apply AddCircle.liftIco_zero_coe_apply
-/

#print AddCircle.liftIco_zero_continuous /-
theorem liftIco_zero_continuous [TopologicalSpace B] {f : 𝕜 → B} (hf : f 0 = f p)
    (hc : ContinuousOn f <| Icc 0 p) : Continuous (liftIco p 0 f) :=
  liftIco_continuous (by rwa [zero_add] : f 0 = f (0 + p)) (by rwa [zero_add])
#align add_circle.lift_Ico_zero_continuous AddCircle.liftIco_zero_continuous
-/

end ZeroBased

end AddCircle

end IdentifyIccEnds

