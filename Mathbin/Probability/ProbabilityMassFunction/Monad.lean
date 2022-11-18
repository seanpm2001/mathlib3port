/-
Copyright (c) 2020 Devon Tuma. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Devon Tuma
-/
import Mathbin.Probability.ProbabilityMassFunction.Basic

/-!
# Monad Operations for Probability Mass Functions

This file constructs two operations on `pmf` that give it a monad structure.
`pure a` is the distribution where a single value `a` has probability `1`.
`bind pa pb : pmf β` is the distribution given by sampling `a : α` from `pa : pmf α`,
and then sampling from `pb a : pmf β` to get a final result `b : β`.

`bind_on_support` generalizes `bind` to allow binding to a partial function,
so that the second argument only needs to be defined on the support of the first argument.

-/


noncomputable section

variable {α β γ : Type _}

open Classical BigOperators Nnreal Ennreal

namespace Pmf

section Pure

/-- The pure `pmf` is the `pmf` where all the mass lies in one point.
  The value of `pure a` is `1` at `a` and `0` elsewhere. -/
def pure (a : α) : Pmf α :=
  ⟨fun a' => if a' = a then 1 else 0, has_sum_ite_eq _ _⟩
#align pmf.pure Pmf.pure

variable (a a' : α)

@[simp]
theorem pure_apply : pure a a' = if a' = a then 1 else 0 :=
  rfl
#align pmf.pure_apply Pmf.pure_apply

@[simp]
theorem support_pure : (pure a).support = {a} :=
  Set.ext fun a' => by simp [mem_support_iff]
#align pmf.support_pure Pmf.support_pure

theorem mem_support_pure_iff : a' ∈ (pure a).support ↔ a' = a := by simp
#align pmf.mem_support_pure_iff Pmf.mem_support_pure_iff

instance [Inhabited α] : Inhabited (Pmf α) :=
  ⟨pure default⟩

section Measure

variable (s : Set α)

@[simp]
theorem to_outer_measure_pure_apply : (pure a).toOuterMeasure s = if a ∈ s then 1 else 0 := by
  refine' (to_outer_measure_apply' (pure a) s).trans _
  split_ifs with ha ha
  · refine' Ennreal.coe_eq_one.2 ((tsum_congr fun b => _).trans (tsum_ite_eq a 1))
    exact ite_eq_left_iff.2 fun hb => symm (ite_eq_right_iff.2 fun h => (hb <| h.symm ▸ ha).elim)
    
  · refine' Ennreal.coe_eq_zero.2 ((tsum_congr fun b => _).trans tsum_zero)
    exact ite_eq_right_iff.2 fun hb => ite_eq_right_iff.2 fun h => (ha <| h ▸ hb).elim
    
#align pmf.to_outer_measure_pure_apply Pmf.to_outer_measure_pure_apply

/-- The measure of a set under `pure a` is `1` for sets containing `a` and `0` otherwise -/
@[simp]
theorem to_measure_pure_apply [MeasurableSpace α] (hs : MeasurableSet s) :
    (pure a).toMeasure s = if a ∈ s then 1 else 0 :=
  (to_measure_apply_eq_to_outer_measure_apply (pure a) s hs).trans (to_outer_measure_pure_apply a s)
#align pmf.to_measure_pure_apply Pmf.to_measure_pure_apply

end Measure

end Pure

section Bind

protected theorem Bind.summable (p : Pmf α) (f : α → Pmf β) (b : β) : Summable fun a : α => p a * f a b := by
  refine' Nnreal.summable_of_le (fun a => _) p.summable_coe
  suffices p a * f a b ≤ p a * 1 by simpa
  exact mul_le_mul_of_nonneg_left ((f a).coe_le_one _) (p a).2
#align pmf.bind.summable Pmf.Bind.summable

/-- The monadic bind operation for `pmf`. -/
def bind (p : Pmf α) (f : α → Pmf β) : Pmf β :=
  ⟨fun b => ∑' a, p a * f a b, by
    apply Ennreal.has_sum_coe.1
    simp only [Ennreal.coe_tsum (bind.summable p f _)]
    rw [ennreal.summable.has_sum_iff, Ennreal.tsum_comm]
    simp [Ennreal.tsum_mul_left, (Ennreal.coe_tsum (f _).summable_coe).symm, (Ennreal.coe_tsum p.summable_coe).symm]⟩
#align pmf.bind Pmf.bind

variable (p : Pmf α) (f : α → Pmf β) (g : β → Pmf γ)

@[simp]
theorem bind_apply (b : β) : p.bind f b = ∑' a, p a * f a b :=
  rfl
#align pmf.bind_apply Pmf.bind_apply

@[simp]
theorem support_bind : (p.bind f).support = { b | ∃ a ∈ p.support, b ∈ (f a).support } :=
  Set.ext fun b => by simp [mem_support_iff, tsum_eq_zero_iff (bind.summable p f b), not_or]
#align pmf.support_bind Pmf.support_bind

theorem mem_support_bind_iff (b : β) : b ∈ (p.bind f).support ↔ ∃ a ∈ p.support, b ∈ (f a).support := by simp
#align pmf.mem_support_bind_iff Pmf.mem_support_bind_iff

theorem coe_bind_apply (b : β) : (p.bind f b : ℝ≥0∞) = ∑' a, p a * f a b :=
  Eq.trans (Ennreal.coe_tsum <| Bind.summable p f b) <| by simp
#align pmf.coe_bind_apply Pmf.coe_bind_apply

@[simp]
theorem pure_bind (a : α) (f : α → Pmf β) : (pure a).bind f = f a := by
  have : ∀ b a', ite (a' = a) 1 0 * f a' b = ite (a' = a) (f a b) 0 := fun b a' => by
    split_ifs <;> simp <;> subst h <;> simp
  ext b <;> simp [this]
#align pmf.pure_bind Pmf.pure_bind

@[simp]
theorem bind_pure : p.bind pure = p := by
  have : ∀ a a', p a * ite (a' = a) 1 0 = ite (a = a') (p a') 0 := fun a a' => by
    split_ifs <;> try subst a <;> try subst a' <;> simp_all
  ext b <;> simp [this]
#align pmf.bind_pure Pmf.bind_pure

@[simp]
theorem bind_bind : (p.bind f).bind g = p.bind fun a => (f a).bind g := by
  ext1 b
  simp only [ennreal.coe_eq_coe.symm, coe_bind_apply, ennreal.tsum_mul_left.symm, ennreal.tsum_mul_right.symm]
  rw [Ennreal.tsum_comm]
  simp [mul_assoc, mul_left_comm, mul_comm]
#align pmf.bind_bind Pmf.bind_bind

theorem bind_comm (p : Pmf α) (q : Pmf β) (f : α → β → Pmf γ) :
    (p.bind fun a => q.bind (f a)) = q.bind fun b => p.bind fun a => f a b := by
  ext1 b
  simp only [ennreal.coe_eq_coe.symm, coe_bind_apply, ennreal.tsum_mul_left.symm, ennreal.tsum_mul_right.symm]
  rw [Ennreal.tsum_comm]
  simp [mul_assoc, mul_left_comm, mul_comm]
#align pmf.bind_comm Pmf.bind_comm

section Measure

variable (s : Set β)

@[simp]
theorem to_outer_measure_bind_apply : (p.bind f).toOuterMeasure s = ∑' a : α, (p a : ℝ≥0∞) * (f a).toOuterMeasure s :=
  calc
    (p.bind f).toOuterMeasure s = ∑' b : β, if b ∈ s then (↑(∑' a : α, p a * f a b) : ℝ≥0∞) else 0 := by
      simp [to_outer_measure_apply, Set.indicator_apply]
    _ = ∑' b : β, ↑(∑' a : α, p a * if b ∈ s then f a b else 0) := tsum_congr fun b => by split_ifs <;> simp
    _ = ∑' (b : β) (a : α), ↑(p a * if b ∈ s then f a b else 0) :=
      tsum_congr fun b => Ennreal.coe_tsum <| Nnreal.summable_of_le (by split_ifs <;> simp) (Bind.summable p f b)
    _ = ∑' (a : α) (b : β), ↑(p a) * ↑(if b ∈ s then f a b else 0) :=
      Ennreal.tsum_comm.trans (tsum_congr fun a => tsum_congr fun b => Ennreal.coe_mul)
    _ = ∑' a : α, ↑(p a) * ∑' b : β, ↑(if b ∈ s then f a b else 0) := tsum_congr fun a => Ennreal.tsum_mul_left
    _ = ∑' a : α, ↑(p a) * ∑' b : β, if b ∈ s then ↑(f a b) else (0 : ℝ≥0∞) :=
      tsum_congr fun a => (congr_arg fun x => ↑(p a) * x) <| tsum_congr fun b => by split_ifs <;> rfl
    _ = ∑' a : α, ↑(p a) * (f a).toOuterMeasure s :=
      tsum_congr fun a => by simp only [to_outer_measure_apply, Set.indicator_apply]
    
#align pmf.to_outer_measure_bind_apply Pmf.to_outer_measure_bind_apply

/-- The measure of a set under `p.bind f` is the sum over `a : α`
  of the probability of `a` under `p` times the measure of the set under `f a` -/
@[simp]
theorem to_measure_bind_apply [MeasurableSpace β] (hs : MeasurableSet s) :
    (p.bind f).toMeasure s = ∑' a : α, (p a : ℝ≥0∞) * (f a).toMeasure s :=
  (to_measure_apply_eq_to_outer_measure_apply (p.bind f) s hs).trans
    ((to_outer_measure_bind_apply p f s).trans
      (tsum_congr fun a => congr_arg (fun x => p a * x) (to_measure_apply_eq_to_outer_measure_apply (f a) s hs).symm))
#align pmf.to_measure_bind_apply Pmf.to_measure_bind_apply

end Measure

end Bind

instance : Monad Pmf where
  pure A a := pure a
  bind A B pa pb := pa.bind pb

section BindOnSupport

protected theorem BindOnSupport.summable (p : Pmf α) (f : ∀ a ∈ p.support, Pmf β) (b : β) :
    Summable fun a : α => p a * if h : p a = 0 then 0 else f a h b := by
  refine' Nnreal.summable_of_le (fun a => _) p.summable_coe
  split_ifs
  · refine' (mul_zero (p a)).symm ▸ le_of_eq h.symm
    
  · suffices p a * f a h b ≤ p a * 1 by simpa
    exact mul_le_mul_of_nonneg_left ((f a h).coe_le_one _) (p a).2
    
#align pmf.bind_on_support.summable Pmf.BindOnSupport.summable

/-- Generalized version of `bind` allowing `f` to only be defined on the support of `p`.
  `p.bind f` is equivalent to `p.bind_on_support (λ a _, f a)`, see `bind_on_support_eq_bind` -/
def bindOnSupport (p : Pmf α) (f : ∀ a ∈ p.support, Pmf β) : Pmf β :=
  ⟨fun b => ∑' a, p a * if h : p a = 0 then 0 else f a h b,
    Ennreal.has_sum_coe.1
      (by
        simp only [Ennreal.coe_tsum (bind_on_support.summable p f _)]
        rw [ennreal.summable.has_sum_iff, Ennreal.tsum_comm]
        simp only [Ennreal.coe_mul, Ennreal.coe_one, Ennreal.tsum_mul_left]
        have : (∑' a : α, (p a : Ennreal)) = 1 := by
          simp only [← Ennreal.coe_tsum p.summable_coe, Ennreal.coe_one, tsum_coe]
        refine' trans (tsum_congr fun a => _) this
        split_ifs with h
        · simp [h]
          
        · simp [← Ennreal.coe_tsum (f a h).summable_coe, (f a h).tsum_coe]
          )⟩
#align pmf.bind_on_support Pmf.bindOnSupport

variable {p : Pmf α} (f : ∀ a ∈ p.support, Pmf β)

@[simp]
theorem bind_on_support_apply (b : β) : p.bindOnSupport f b = ∑' a, p a * if h : p a = 0 then 0 else f a h b :=
  rfl
#align pmf.bind_on_support_apply Pmf.bind_on_support_apply

@[simp]
theorem support_bind_on_support :
    (p.bindOnSupport f).support = { b | ∃ (a : α)(h : a ∈ p.support), b ∈ (f a h).support } := by
  refine' Set.ext fun b => _
  simp only [tsum_eq_zero_iff (bind_on_support.summable p f b), not_or, mem_support_iff, bind_on_support_apply, Ne.def,
    not_forall, mul_eq_zero]
  exact
    ⟨fun hb =>
      let ⟨a, ⟨ha, ha'⟩⟩ := hb
      ⟨a, ha, by simpa [ha] using ha'⟩,
      fun hb =>
      let ⟨a, ha, ha'⟩ := hb
      ⟨a, ⟨ha, by simpa [(mem_support_iff _ a).1 ha] using ha'⟩⟩⟩
#align pmf.support_bind_on_support Pmf.support_bind_on_support

theorem mem_support_bind_on_support_iff (b : β) :
    b ∈ (p.bindOnSupport f).support ↔ ∃ (a : α)(h : a ∈ p.support), b ∈ (f a h).support := by simp
#align pmf.mem_support_bind_on_support_iff Pmf.mem_support_bind_on_support_iff

/-- `bind_on_support` reduces to `bind` if `f` doesn't depend on the additional hypothesis -/
@[simp]
theorem bind_on_support_eq_bind (p : Pmf α) (f : α → Pmf β) : (p.bindOnSupport fun a _ => f a) = p.bind f := by
  ext b
  simp only [bind_on_support_apply fun a _ => f a, p.bind_apply f, dite_eq_ite, Nnreal.coe_eq, mul_ite, mul_zero]
  refine' congr_arg _ (funext fun a => _)
  split_ifs with h <;> simp [h]
#align pmf.bind_on_support_eq_bind Pmf.bind_on_support_eq_bind

theorem coe_bind_on_support_apply (b : β) :
    (p.bindOnSupport f b : ℝ≥0∞) = ∑' a, p a * if h : p a = 0 then 0 else f a h b := by
  simp only [bind_on_support_apply, Ennreal.coe_tsum (bind_on_support.summable p f b), dite_cast, Ennreal.coe_mul,
    Ennreal.coe_zero]
#align pmf.coe_bind_on_support_apply Pmf.coe_bind_on_support_apply

theorem bind_on_support_eq_zero_iff (b : β) : p.bindOnSupport f b = 0 ↔ ∀ (a) (ha : p a ≠ 0), f a ha b = 0 := by
  simp only [bind_on_support_apply, tsum_eq_zero_iff (bind_on_support.summable p f b), mul_eq_zero, or_iff_not_imp_left]
  exact ⟨fun h a ha => trans (dif_neg ha).symm (h a ha), fun h a ha => trans (dif_neg ha) (h a ha)⟩
#align pmf.bind_on_support_eq_zero_iff Pmf.bind_on_support_eq_zero_iff

@[simp]
theorem pure_bind_on_support (a : α) (f : ∀ (a' : α) (ha : a' ∈ (pure a).support), Pmf β) :
    (pure a).bindOnSupport f = f a ((mem_support_pure_iff a a).mpr rfl) := by
  refine' Pmf.ext fun b => _
  simp only [Nnreal.coe_eq, bind_on_support_apply, pure_apply]
  refine' trans (tsum_congr fun a' => _) (tsum_ite_eq a _)
  by_cases h : a' = a <;> simp [h]
#align pmf.pure_bind_on_support Pmf.pure_bind_on_support

theorem bind_on_support_pure (p : Pmf α) : (p.bindOnSupport fun a _ => pure a) = p := by
  simp only [Pmf.bind_pure, Pmf.bind_on_support_eq_bind]
#align pmf.bind_on_support_pure Pmf.bind_on_support_pure

@[simp]
theorem bind_on_support_bind_on_support (p : Pmf α) (f : ∀ a ∈ p.support, Pmf β)
    (g : ∀ b ∈ (p.bindOnSupport f).support, Pmf γ) :
    (p.bindOnSupport f).bindOnSupport g =
      p.bindOnSupport fun a ha =>
        (f a ha).bindOnSupport fun b hb => g b ((mem_support_bind_on_support_iff f b).mpr ⟨a, ha, hb⟩) :=
  by
  refine' Pmf.ext fun a => _
  simp only [ennreal.coe_eq_coe.symm, coe_bind_on_support_apply, ← tsum_dite_right, ennreal.tsum_mul_left.symm,
    ennreal.tsum_mul_right.symm]
  simp only [Ennreal.tsum_eq_zero, Ennreal.coe_eq_coe, Ennreal.coe_eq_zero, Ennreal.coe_zero, dite_eq_left_iff,
    mul_eq_zero]
  refine' ennreal.tsum_comm.trans (tsum_congr fun a' => tsum_congr fun b => _)
  split_ifs
  any_goals ring1
  · have := h_1 a'
    simp [h] at this
    contradiction
    
  · simp [h_2]
    
#align pmf.bind_on_support_bind_on_support Pmf.bind_on_support_bind_on_support

theorem bind_on_support_comm (p : Pmf α) (q : Pmf β) (f : ∀ a ∈ p.support, ∀ b ∈ q.support, Pmf γ) :
    (p.bindOnSupport fun a ha => q.bindOnSupport (f a ha)) =
      q.bindOnSupport fun b hb => p.bindOnSupport fun a ha => f a ha b hb :=
  by
  apply Pmf.ext
  rintro c
  simp only [ennreal.coe_eq_coe.symm, coe_bind_on_support_apply, ← tsum_dite_right, ennreal.tsum_mul_left.symm,
    ennreal.tsum_mul_right.symm]
  refine' trans Ennreal.tsum_comm (tsum_congr fun b => tsum_congr fun a => _)
  split_ifs with h1 h2 h2 <;> ring
#align pmf.bind_on_support_comm Pmf.bind_on_support_comm

section Measure

variable (s : Set β)

@[simp]
theorem to_outer_measure_bind_on_support_apply :
    (p.bindOnSupport f).toOuterMeasure s =
      ∑' a : α, (p a : ℝ≥0) * if h : p a = 0 then 0 else (f a h).toOuterMeasure s :=
  let g : α → β → ℝ≥0 := fun a b => if h : p a = 0 then 0 else f a h b
  calc
    (p.bindOnSupport f).toOuterMeasure s = ∑' b : β, if b ∈ s then ↑(∑' a : α, p a * g a b) else 0 := by
      simp [to_outer_measure_apply, Set.indicator_apply]
    _ = ∑' b : β, ↑(∑' a : α, p a * if b ∈ s then g a b else 0) := tsum_congr fun b => by split_ifs <;> simp
    _ = ∑' (b : β) (a : α), ↑(p a * if b ∈ s then g a b else 0) :=
      tsum_congr fun b =>
        Ennreal.coe_tsum <| Nnreal.summable_of_le (by split_ifs <;> simp) (BindOnSupport.summable p f b)
    _ = ∑' (a : α) (b : β), ↑(p a) * ↑(if b ∈ s then g a b else 0) :=
      Ennreal.tsum_comm.trans (tsum_congr fun a => tsum_congr fun b => Ennreal.coe_mul)
    _ = ∑' a : α, ↑(p a) * ∑' b : β, ↑(if b ∈ s then g a b else 0) := tsum_congr fun a => Ennreal.tsum_mul_left
    _ = ∑' a : α, ↑(p a) * ∑' b : β, if b ∈ s then ↑(g a b) else (0 : ℝ≥0∞) :=
      tsum_congr fun a => (congr_arg fun x => ↑(p a) * x) <| tsum_congr fun b => by split_ifs <;> rfl
    _ = ∑' a : α, ↑(p a) * if h : p a = 0 then 0 else (f a h).toOuterMeasure s :=
      tsum_congr fun a =>
        congr_arg (Mul.mul ↑(p a))
          (by
            split_ifs with h h
            · refine' ennreal.tsum_eq_zero.mpr fun x => _
              simp only [g, h, dif_pos]
              apply if_t_t
              
            · simp only [to_outer_measure_apply, g, h, Set.indicator_apply, not_false_iff, dif_neg]
              )
    
#align pmf.to_outer_measure_bind_on_support_apply Pmf.to_outer_measure_bind_on_support_apply

/-- The measure of a set under `p.bind_on_support f` is the sum over `a : α`
  of the probability of `a` under `p` times the measure of the set under `f a _`.
  The additional if statement is needed since `f` is only a partial function -/
@[simp]
theorem to_measure_bind_on_support_apply [MeasurableSpace β] (hs : MeasurableSet s) :
    (p.bindOnSupport f).toMeasure s = ∑' a : α, (p a : ℝ≥0∞) * if h : p a = 0 then 0 else (f a h).toMeasure s :=
  (to_measure_apply_eq_to_outer_measure_apply (p.bindOnSupport f) s hs).trans
    ((to_outer_measure_bind_on_support_apply f s).trans
      (tsum_congr fun a =>
        congr_arg (Mul.mul ↑(p a))
          (congr_arg (dite (p a = 0) fun _ => 0) <|
            funext fun h => symm <| to_measure_apply_eq_to_outer_measure_apply (f a h) s hs)))
#align pmf.to_measure_bind_on_support_apply Pmf.to_measure_bind_on_support_apply

end Measure

end BindOnSupport

end Pmf

