/-
Copyright (c) 2020 Devon Tuma. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Devon Tuma

! This file was ported from Lean 3 source module probability.probability_mass_function.monad
! leanprover-community/mathlib commit bd15ff41b70f5e2cc210f26f25a8d5c53b20d3de
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.ProbabilityMassFunction.Basic

/-!
# Monad Operations for Probability Mass Functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file constructs two operations on `pmf` that give it a monad structure.
`pure a` is the distribution where a single value `a` has probability `1`.
`bind pa pb : pmf β` is the distribution given by sampling `a : α` from `pa : pmf α`,
and then sampling from `pb a : pmf β` to get a final result `b : β`.

`bind_on_support` generalizes `bind` to allow binding to a partial function,
so that the second argument only needs to be defined on the support of the first argument.

-/


noncomputable section

variable {α β γ : Type _}

open scoped Classical BigOperators NNReal ENNReal

open MeasureTheory

namespace Pmf

section Pure

#print Pmf.pure /-
/-- The pure `pmf` is the `pmf` where all the mass lies in one point.
  The value of `pure a` is `1` at `a` and `0` elsewhere. -/
def pure (a : α) : Pmf α :=
  ⟨fun a' => if a' = a then 1 else 0, hasSum_ite_eq _ _⟩
#align pmf.pure Pmf.pure
-/

variable (a a' : α)

#print Pmf.pure_apply /-
@[simp]
theorem pure_apply : pure a a' = if a' = a then 1 else 0 :=
  rfl
#align pmf.pure_apply Pmf.pure_apply
-/

#print Pmf.support_pure /-
@[simp]
theorem support_pure : (pure a).support = {a} :=
  Set.ext fun a' => by simp [mem_support_iff]
#align pmf.support_pure Pmf.support_pure
-/

#print Pmf.mem_support_pure_iff /-
theorem mem_support_pure_iff : a' ∈ (pure a).support ↔ a' = a := by simp
#align pmf.mem_support_pure_iff Pmf.mem_support_pure_iff
-/

#print Pmf.pure_apply_self /-
@[simp]
theorem pure_apply_self : pure a a = 1 :=
  if_pos rfl
#align pmf.pure_apply_self Pmf.pure_apply_self
-/

#print Pmf.pure_apply_of_ne /-
theorem pure_apply_of_ne (h : a' ≠ a) : pure a a' = 0 :=
  if_neg h
#align pmf.pure_apply_of_ne Pmf.pure_apply_of_ne
-/

instance [Inhabited α] : Inhabited (Pmf α) :=
  ⟨pure default⟩

section Measure

variable (s : Set α)

#print Pmf.toOuterMeasure_pure_apply /-
@[simp]
theorem toOuterMeasure_pure_apply : (pure a).toOuterMeasure s = if a ∈ s then 1 else 0 :=
  by
  refine' (to_outer_measure_apply (pure a) s).trans _
  split_ifs with ha ha
  · refine' (tsum_congr fun b => _).trans (tsum_ite_eq a 1)
    exact ite_eq_left_iff.2 fun hb => symm (ite_eq_right_iff.2 fun h => (hb <| h.symm ▸ ha).elim)
  · refine' (tsum_congr fun b => _).trans tsum_zero
    exact ite_eq_right_iff.2 fun hb => ite_eq_right_iff.2 fun h => (ha <| h ▸ hb).elim
#align pmf.to_outer_measure_pure_apply Pmf.toOuterMeasure_pure_apply
-/

variable [MeasurableSpace α]

#print Pmf.toMeasure_pure_apply /-
/-- The measure of a set under `pure a` is `1` for sets containing `a` and `0` otherwise -/
@[simp]
theorem toMeasure_pure_apply (hs : MeasurableSet s) :
    (pure a).toMeasure s = if a ∈ s then 1 else 0 :=
  (toMeasure_apply_eq_toOuterMeasure_apply (pure a) s hs).trans (toOuterMeasure_pure_apply a s)
#align pmf.to_measure_pure_apply Pmf.toMeasure_pure_apply
-/

#print Pmf.toMeasure_pure /-
theorem toMeasure_pure : (pure a).toMeasure = Measure.dirac a :=
  Measure.ext fun s hs => by simpa only [to_measure_pure_apply a s hs, measure.dirac_apply' a hs]
#align pmf.to_measure_pure Pmf.toMeasure_pure
-/

#print Pmf.toPmf_dirac /-
@[simp]
theorem toPmf_dirac [Countable α] [h : MeasurableSingletonClass α] :
    (Measure.dirac a).toPmf = pure a := by rw [to_pmf_eq_iff_to_measure_eq, to_measure_pure]
#align pmf.to_pmf_dirac Pmf.toPmf_dirac
-/

end Measure

end Pure

section Bind

#print Pmf.bind /-
/-- The monadic bind operation for `pmf`. -/
def bind (p : Pmf α) (f : α → Pmf β) : Pmf β :=
  ⟨fun b => ∑' a, p a * f a b,
    ENNReal.summable.hasSum_iff.2
      (ENNReal.tsum_comm.trans <| by simp only [ENNReal.tsum_mul_left, tsum_coe, mul_one])⟩
#align pmf.bind Pmf.bind
-/

variable (p : Pmf α) (f : α → Pmf β) (g : β → Pmf γ)

#print Pmf.bind_apply /-
@[simp]
theorem bind_apply (b : β) : p.bind f b = ∑' a, p a * f a b :=
  rfl
#align pmf.bind_apply Pmf.bind_apply
-/

#print Pmf.support_bind /-
@[simp]
theorem support_bind : (p.bind f).support = ⋃ a ∈ p.support, (f a).support :=
  Set.ext fun b => by simp [mem_support_iff, ENNReal.tsum_eq_zero, not_or]
#align pmf.support_bind Pmf.support_bind
-/

#print Pmf.mem_support_bind_iff /-
theorem mem_support_bind_iff (b : β) :
    b ∈ (p.bind f).support ↔ ∃ a ∈ p.support, b ∈ (f a).support := by
  simp only [support_bind, Set.mem_iUnion, Set.mem_setOf_eq]
#align pmf.mem_support_bind_iff Pmf.mem_support_bind_iff
-/

#print Pmf.pure_bind /-
@[simp]
theorem pure_bind (a : α) (f : α → Pmf β) : (pure a).bind f = f a :=
  by
  have : ∀ b a', ite (a' = a) 1 0 * f a' b = ite (a' = a) (f a b) 0 := fun b a' => by
    split_ifs <;> simp <;> subst h <;> simp
  ext b <;> simp [this]
#align pmf.pure_bind Pmf.pure_bind
-/

#print Pmf.bind_pure /-
@[simp]
theorem bind_pure : p.bind pure = p :=
  Pmf.ext fun x =>
    (bind_apply _ _ _).trans
      (trans
          (tsum_eq_single x fun y hy => by
            rw [pure_apply_of_ne _ _ hy.symm, MulZeroClass.mul_zero]) <|
        by rw [pure_apply_self, mul_one])
#align pmf.bind_pure Pmf.bind_pure
-/

#print Pmf.bind_const /-
@[simp]
theorem bind_const (p : Pmf α) (q : Pmf β) : (p.bind fun _ => q) = q :=
  Pmf.ext fun x => by rw [bind_apply, ENNReal.tsum_mul_right, tsum_coe, one_mul]
#align pmf.bind_const Pmf.bind_const
-/

#print Pmf.bind_bind /-
@[simp]
theorem bind_bind : (p.bind f).bind g = p.bind fun a => (f a).bind g :=
  Pmf.ext fun b => by
    simpa only [ennreal.coe_eq_coe.symm, bind_apply, ennreal.tsum_mul_left.symm,
      ennreal.tsum_mul_right.symm, mul_assoc, mul_left_comm, mul_comm] using ENNReal.tsum_comm
#align pmf.bind_bind Pmf.bind_bind
-/

#print Pmf.bind_comm /-
theorem bind_comm (p : Pmf α) (q : Pmf β) (f : α → β → Pmf γ) :
    (p.bind fun a => q.bind (f a)) = q.bind fun b => p.bind fun a => f a b :=
  Pmf.ext fun b => by
    simpa only [ennreal.coe_eq_coe.symm, bind_apply, ennreal.tsum_mul_left.symm,
      ennreal.tsum_mul_right.symm, mul_assoc, mul_left_comm, mul_comm] using ENNReal.tsum_comm
#align pmf.bind_comm Pmf.bind_comm
-/

section Measure

variable (s : Set β)

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (b a) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b) -/
#print Pmf.toOuterMeasure_bind_apply /-
@[simp]
theorem toOuterMeasure_bind_apply :
    (p.bind f).toOuterMeasure s = ∑' a, p a * (f a).toOuterMeasure s :=
  calc
    (p.bind f).toOuterMeasure s = ∑' b, if b ∈ s then ∑' a, p a * f a b else 0 := by
      simp [to_outer_measure_apply, Set.indicator_apply]
    _ = ∑' (b) (a), p a * if b ∈ s then f a b else 0 := (tsum_congr fun b => by split_ifs <;> simp)
    _ = ∑' (a) (b), p a * if b ∈ s then f a b else 0 :=
      (tsum_comm' ENNReal.summable (fun _ => ENNReal.summable) fun _ => ENNReal.summable)
    _ = ∑' a, p a * ∑' b, if b ∈ s then f a b else 0 := (tsum_congr fun a => ENNReal.tsum_mul_left)
    _ = ∑' a, p a * ∑' b, if b ∈ s then f a b else 0 :=
      (tsum_congr fun a => (congr_arg fun x => p a * x) <| tsum_congr fun b => by split_ifs <;> rfl)
    _ = ∑' a, p a * (f a).toOuterMeasure s :=
      tsum_congr fun a => by simp only [to_outer_measure_apply, Set.indicator_apply]
#align pmf.to_outer_measure_bind_apply Pmf.toOuterMeasure_bind_apply
-/

#print Pmf.toMeasure_bind_apply /-
/-- The measure of a set under `p.bind f` is the sum over `a : α`
  of the probability of `a` under `p` times the measure of the set under `f a` -/
@[simp]
theorem toMeasure_bind_apply [MeasurableSpace β] (hs : MeasurableSet s) :
    (p.bind f).toMeasure s = ∑' a, p a * (f a).toMeasure s :=
  (toMeasure_apply_eq_toOuterMeasure_apply (p.bind f) s hs).trans
    ((toOuterMeasure_bind_apply p f s).trans
      (tsum_congr fun a =>
        congr_arg (fun x => p a * x) (toMeasure_apply_eq_toOuterMeasure_apply (f a) s hs).symm))
#align pmf.to_measure_bind_apply Pmf.toMeasure_bind_apply
-/

end Measure

end Bind

instance : Monad Pmf where
  pure A a := pure a
  bind A B pa pb := pa.bind pb

section BindOnSupport

#print Pmf.bindOnSupport /-
/-- Generalized version of `bind` allowing `f` to only be defined on the support of `p`.
  `p.bind f` is equivalent to `p.bind_on_support (λ a _, f a)`, see `bind_on_support_eq_bind` -/
def bindOnSupport (p : Pmf α) (f : ∀ a ∈ p.support, Pmf β) : Pmf β :=
  ⟨fun b => ∑' a, p a * if h : p a = 0 then 0 else f a h b,
    ENNReal.summable.hasSum_iff.2
      (by
        refine' ennreal.tsum_comm.trans (trans (tsum_congr fun a => _) p.tsum_coe)
        simp_rw [ENNReal.tsum_mul_left]
        split_ifs with h
        · simp only [h, MulZeroClass.zero_mul]
        · rw [(f a h).tsum_coe, mul_one])⟩
#align pmf.bind_on_support Pmf.bindOnSupport
-/

variable {p : Pmf α} (f : ∀ a ∈ p.support, Pmf β)

#print Pmf.bindOnSupport_apply /-
@[simp]
theorem bindOnSupport_apply (b : β) :
    p.bindOnSupport f b = ∑' a, p a * if h : p a = 0 then 0 else f a h b :=
  rfl
#align pmf.bind_on_support_apply Pmf.bindOnSupport_apply
-/

#print Pmf.support_bindOnSupport /-
@[simp]
theorem support_bindOnSupport :
    (p.bindOnSupport f).support = ⋃ (a : α) (h : a ∈ p.support), (f a h).support :=
  by
  refine' Set.ext fun b => _
  simp only [ENNReal.tsum_eq_zero, not_or, mem_support_iff, bind_on_support_apply, Ne.def,
    not_forall, mul_eq_zero, Set.mem_iUnion]
  exact
    ⟨fun hb =>
      let ⟨a, ⟨ha, ha'⟩⟩ := hb
      ⟨a, ha, by simpa [ha] using ha'⟩,
      fun hb =>
      let ⟨a, ha, ha'⟩ := hb
      ⟨a, ⟨ha, by simpa [(mem_support_iff _ a).1 ha] using ha'⟩⟩⟩
#align pmf.support_bind_on_support Pmf.support_bindOnSupport
-/

#print Pmf.mem_support_bindOnSupport_iff /-
theorem mem_support_bindOnSupport_iff (b : β) :
    b ∈ (p.bindOnSupport f).support ↔ ∃ (a : α) (h : a ∈ p.support), b ∈ (f a h).support := by
  simp only [support_bind_on_support, Set.mem_setOf_eq, Set.mem_iUnion]
#align pmf.mem_support_bind_on_support_iff Pmf.mem_support_bindOnSupport_iff
-/

#print Pmf.bindOnSupport_eq_bind /-
/-- `bind_on_support` reduces to `bind` if `f` doesn't depend on the additional hypothesis -/
@[simp]
theorem bindOnSupport_eq_bind (p : Pmf α) (f : α → Pmf β) :
    (p.bindOnSupport fun a _ => f a) = p.bind f :=
  by
  ext b x
  have : ∀ a, ite (p a = 0) 0 (p a * f a b) = p a * f a b := fun a =>
    ite_eq_right_iff.2 fun h => h.symm ▸ symm (MulZeroClass.zero_mul <| f a b)
  simp only [bind_on_support_apply fun a _ => f a, p.bind_apply f, dite_eq_ite, mul_ite,
    MulZeroClass.mul_zero, this]
#align pmf.bind_on_support_eq_bind Pmf.bindOnSupport_eq_bind
-/

#print Pmf.bindOnSupport_eq_zero_iff /-
theorem bindOnSupport_eq_zero_iff (b : β) :
    p.bindOnSupport f b = 0 ↔ ∀ (a) (ha : p a ≠ 0), f a ha b = 0 :=
  by
  simp only [bind_on_support_apply, ENNReal.tsum_eq_zero, mul_eq_zero, or_iff_not_imp_left]
  exact ⟨fun h a ha => trans (dif_neg ha).symm (h a ha), fun h a ha => trans (dif_neg ha) (h a ha)⟩
#align pmf.bind_on_support_eq_zero_iff Pmf.bindOnSupport_eq_zero_iff
-/

#print Pmf.pure_bindOnSupport /-
@[simp]
theorem pure_bindOnSupport (a : α) (f : ∀ (a' : α) (ha : a' ∈ (pure a).support), Pmf β) :
    (pure a).bindOnSupport f = f a ((mem_support_pure_iff a a).mpr rfl) :=
  by
  refine' Pmf.ext fun b => _
  simp only [bind_on_support_apply, pure_apply]
  refine' trans (tsum_congr fun a' => _) (tsum_ite_eq a _)
  by_cases h : a' = a <;> simp [h]
#align pmf.pure_bind_on_support Pmf.pure_bindOnSupport
-/

#print Pmf.bindOnSupport_pure /-
theorem bindOnSupport_pure (p : Pmf α) : (p.bindOnSupport fun a _ => pure a) = p := by
  simp only [Pmf.bind_pure, Pmf.bindOnSupport_eq_bind]
#align pmf.bind_on_support_pure Pmf.bindOnSupport_pure
-/

#print Pmf.bindOnSupport_bindOnSupport /-
@[simp]
theorem bindOnSupport_bindOnSupport (p : Pmf α) (f : ∀ a ∈ p.support, Pmf β)
    (g : ∀ b ∈ (p.bindOnSupport f).support, Pmf γ) :
    (p.bindOnSupport f).bindOnSupport g =
      p.bindOnSupport fun a ha =>
        (f a ha).bindOnSupport fun b hb =>
          g b ((mem_support_bindOnSupport_iff f b).mpr ⟨a, ha, hb⟩) :=
  by
  refine' Pmf.ext fun a => _
  simp only [ennreal.coe_eq_coe.symm, bind_on_support_apply, ← tsum_dite_right,
    ennreal.tsum_mul_left.symm, ennreal.tsum_mul_right.symm]
  simp only [ENNReal.tsum_eq_zero, ENNReal.coe_eq_coe, ENNReal.coe_eq_zero, ENNReal.coe_zero,
    dite_eq_left_iff, mul_eq_zero]
  refine' ennreal.tsum_comm.trans (tsum_congr fun a' => tsum_congr fun b => _)
  split_ifs
  any_goals ring1
  · have := h_1 a'; simp [h] at this ; contradiction
  · simp [h_2]
#align pmf.bind_on_support_bind_on_support Pmf.bindOnSupport_bindOnSupport
-/

#print Pmf.bindOnSupport_comm /-
theorem bindOnSupport_comm (p : Pmf α) (q : Pmf β) (f : ∀ a ∈ p.support, ∀ b ∈ q.support, Pmf γ) :
    (p.bindOnSupport fun a ha => q.bindOnSupport (f a ha)) =
      q.bindOnSupport fun b hb => p.bindOnSupport fun a ha => f a ha b hb :=
  by
  apply Pmf.ext; rintro c
  simp only [ennreal.coe_eq_coe.symm, bind_on_support_apply, ← tsum_dite_right,
    ennreal.tsum_mul_left.symm, ennreal.tsum_mul_right.symm]
  refine' trans ENNReal.tsum_comm (tsum_congr fun b => tsum_congr fun a => _)
  split_ifs with h1 h2 h2 <;> ring
#align pmf.bind_on_support_comm Pmf.bindOnSupport_comm
-/

section Measure

variable (s : Set β)

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (b a) -/
#print Pmf.toOuterMeasure_bindOnSupport_apply /-
@[simp]
theorem toOuterMeasure_bindOnSupport_apply :
    (p.bindOnSupport f).toOuterMeasure s =
      ∑' a, p a * if h : p a = 0 then 0 else (f a h).toOuterMeasure s :=
  by
  simp only [to_outer_measure_apply, Set.indicator_apply, bind_on_support_apply]
  calc
    ∑' b, ite (b ∈ s) (∑' a, p a * dite (p a = 0) (fun h => 0) fun h => f a h b) 0 =
        ∑' (b) (a), ite (b ∈ s) (p a * dite (p a = 0) (fun h => 0) fun h => f a h b) 0 :=
      tsum_congr fun b => by split_ifs with hbs <;> simp only [eq_self_iff_true, tsum_zero]
    _ = ∑' (a) (b), ite (b ∈ s) (p a * dite (p a = 0) (fun h => 0) fun h => f a h b) 0 :=
      ENNReal.tsum_comm
    _ = ∑' a, p a * ∑' b, ite (b ∈ s) (dite (p a = 0) (fun h => 0) fun h => f a h b) 0 :=
      (tsum_congr fun a => by simp only [← ENNReal.tsum_mul_left, mul_ite, MulZeroClass.mul_zero])
    _ = ∑' a, p a * dite (p a = 0) (fun h => 0) fun h => ∑' b, ite (b ∈ s) (f a h b) 0 :=
      tsum_congr fun a => by split_ifs with ha <;> simp only [if_t_t, tsum_zero, eq_self_iff_true]
#align pmf.to_outer_measure_bind_on_support_apply Pmf.toOuterMeasure_bindOnSupport_apply
-/

#print Pmf.toMeasure_bindOnSupport_apply /-
/-- The measure of a set under `p.bind_on_support f` is the sum over `a : α`
  of the probability of `a` under `p` times the measure of the set under `f a _`.
  The additional if statement is needed since `f` is only a partial function -/
@[simp]
theorem toMeasure_bindOnSupport_apply [MeasurableSpace β] (hs : MeasurableSet s) :
    (p.bindOnSupport f).toMeasure s = ∑' a, p a * if h : p a = 0 then 0 else (f a h).toMeasure s :=
  by
  simp only [to_measure_apply_eq_to_outer_measure_apply _ _ hs,
    to_outer_measure_bind_on_support_apply]
#align pmf.to_measure_bind_on_support_apply Pmf.toMeasure_bindOnSupport_apply
-/

end Measure

end BindOnSupport

end Pmf

