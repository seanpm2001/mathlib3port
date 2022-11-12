/-
Copyright (c) 2021 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Yury Kudryashov, Sébastien Gouëzel
-/
import Mathbin.MeasureTheory.Constructions.BorelSpace
import Mathbin.Topology.Algebra.Order.LeftRightLim

/-!
# Stieltjes measures on the real line

Consider a function `f : ℝ → ℝ` which is monotone and right-continuous. Then one can define a
corrresponding measure, giving mass `f b - f a` to the interval `(a, b]`.

## Main definitions

* `stieltjes_function` is a structure containing a function from `ℝ → ℝ`, together with the
assertions that it is monotone and right-continuous. To `f : stieltjes_function`, one associates
a Borel measure `f.measure`.
* `f.measure_Ioc` asserts that `f.measure (Ioc a b) = of_real (f b - f a)`
* `f.measure_Ioo` asserts that `f.measure (Ioo a b) = of_real (left_lim f b - f a)`.
* `f.measure_Icc` and `f.measure_Ico` are analogous.
-/


noncomputable section

open Classical Set Filter Function

open Ennreal (ofReal)

open BigOperators Ennreal Nnreal TopologicalSpace MeasureTheory

/-! ### Basic properties of Stieltjes functions -/


/-- Bundled monotone right-continuous real functions, used to construct Stieltjes measures. -/
structure StieltjesFunction where
  toFun : ℝ → ℝ
  mono' : Monotone to_fun
  right_continuous' : ∀ x, ContinuousWithinAt to_fun (IciCat x) x
#align stieltjes_function StieltjesFunction

namespace StieltjesFunction

instance : CoeFun StieltjesFunction fun _ => ℝ → ℝ :=
  ⟨toFun⟩

initialize_simps_projections StieltjesFunction (toFun → apply)

variable (f : StieltjesFunction)

theorem mono : Monotone f :=
  f.mono'
#align stieltjes_function.mono StieltjesFunction.mono

theorem right_continuous (x : ℝ) : ContinuousWithinAt f (IciCat x) x :=
  f.right_continuous' x
#align stieltjes_function.right_continuous StieltjesFunction.right_continuous

/-- The identity of `ℝ` as a Stieltjes function, used to construct Lebesgue measure. -/
@[simps]
protected def id : StieltjesFunction where
  toFun := id
  mono' x y := id
  right_continuous' x := continuous_within_at_id
#align stieltjes_function.id StieltjesFunction.id

@[simp]
theorem id_left_lim (x : ℝ) : leftLim StieltjesFunction.id x = x :=
  tendsto_nhds_unique (StieltjesFunction.id.mono.tendsto_left_lim x) <|
    continuous_at_id.Tendsto.mono_left nhds_within_le_nhds
#align stieltjes_function.id_left_lim StieltjesFunction.id_left_lim

instance : Inhabited StieltjesFunction :=
  ⟨StieltjesFunction.id⟩

/-- If a function `f : ℝ → ℝ` is monotone, then the function mapping `x` to the right limit of `f`
at `x` is a Stieltjes function, i.e., it is monotone and right-continuous. -/
noncomputable def _root_.monotone.stieltjes_function {f : ℝ → ℝ} (hf : Monotone f) : StieltjesFunction where
  toFun := rightLim f
  mono' x y hxy := hf.rightLim hxy
  right_continuous' := by
    intro x s hs
    obtain ⟨l, u, hlu, lus⟩ : ∃ l u : ℝ, right_lim f x ∈ Ioo l u ∧ Ioo l u ⊆ s := mem_nhds_iff_exists_Ioo_subset.1 hs
    obtain ⟨y, xy, h'y⟩ : ∃ (y : ℝ)(H : x < y), Ioc x y ⊆ f ⁻¹' Ioo l u :=
      mem_nhds_within_Ioi_iff_exists_Ioc_subset.1 (hf.tendsto_right_lim x (Ioo_mem_nhds hlu.1 hlu.2))
    change ∀ᶠ y in 𝓝[≥] x, right_lim f y ∈ s
    filter_upwards [Ico_mem_nhds_within_Ici ⟨le_refl x, xy⟩] with z hz
    apply lus
    refine' ⟨hlu.1.trans_le (hf.right_lim hz.1), _⟩
    obtain ⟨a, za, ay⟩ : ∃ a : ℝ, z < a ∧ a < y := exists_between hz.2
    calc
      right_lim f z ≤ f a := hf.right_lim_le za
      _ < u := (h'y ⟨hz.1.trans_lt za, ay.le⟩).2
      
#align stieltjes_function._root_.monotone.stieltjes_function stieltjes_function._root_.monotone.stieltjes_function

theorem _root_.monotone.stieltjes_function_eq {f : ℝ → ℝ} (hf : Monotone f) (x : ℝ) :
    hf.StieltjesFunction x = rightLim f x :=
  rfl
#align stieltjes_function._root_.monotone.stieltjes_function_eq stieltjes_function._root_.monotone.stieltjes_function_eq

theorem countable_left_lim_ne (f : StieltjesFunction) : Set.Countable { x | leftLim f x ≠ f x } := by
  apply countable.mono _ f.mono.countable_not_continuous_at
  intro x hx h'x
  apply hx
  exact tendsto_nhds_unique (f.mono.tendsto_left_lim x) (h'x.tendsto.mono_left nhds_within_le_nhds)
#align stieltjes_function.countable_left_lim_ne StieltjesFunction.countable_left_lim_ne

/-! ### The outer measure associated to a Stieltjes function -/


/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b) -/
/-- Length of an interval. This is the largest monotone function which correctly measures all
intervals. -/
def length (s : Set ℝ) : ℝ≥0∞ :=
  ⨅ (a) (b) (h : s ⊆ IocCat a b), ofReal (f b - f a)
#align stieltjes_function.length StieltjesFunction.length

@[simp]
theorem length_empty : f.length ∅ = 0 :=
  nonpos_iff_eq_zero.1 <| infi_le_of_le 0 <| infi_le_of_le 0 <| by simp
#align stieltjes_function.length_empty StieltjesFunction.length_empty

@[simp]
theorem length_Ioc (a b : ℝ) : f.length (IocCat a b) = ofReal (f b - f a) := by
  refine'
    le_antisymm (infi_le_of_le a <| infi₂_le b subset.rfl)
      (le_infi fun a' => le_infi fun b' => le_infi fun h => Ennreal.coe_le_coe.2 _)
  cases' le_or_lt b a with ab ab
  · rw [Real.to_nnreal_of_nonpos (sub_nonpos.2 (f.mono ab))]
    apply zero_le
    
  cases' (Ioc_subset_Ioc_iff ab).1 h with h₁ h₂
  exact Real.to_nnreal_le_to_nnreal (sub_le_sub (f.mono h₁) (f.mono h₂))
#align stieltjes_function.length_Ioc StieltjesFunction.length_Ioc

theorem length_mono {s₁ s₂ : Set ℝ} (h : s₁ ⊆ s₂) : f.length s₁ ≤ f.length s₂ :=
  infi_mono fun a => binfi_mono fun b => h.trans
#align stieltjes_function.length_mono StieltjesFunction.length_mono

open MeasureTheory

/-- The Stieltjes outer measure associated to a Stieltjes function. -/
protected def outer : OuterMeasure ℝ :=
  OuterMeasure.ofFunction f.length f.length_empty
#align stieltjes_function.outer StieltjesFunction.outer

theorem outer_le_length (s : Set ℝ) : f.outer s ≤ f.length s :=
  OuterMeasure.of_function_le _
#align stieltjes_function.outer_le_length StieltjesFunction.outer_le_length

/-- If a compact interval `[a, b]` is covered by a union of open interval `(c i, d i)`, then
`f b - f a ≤ ∑ f (d i) - f (c i)`. This is an auxiliary technical statement to prove the same
statement for half-open intervals, the point of the current statement being that one can use
compactness to reduce it to a finite sum, and argue by induction on the size of the covering set. -/
theorem length_subadditive_Icc_Ioo {a b : ℝ} {c d : ℕ → ℝ} (ss : IccCat a b ⊆ ⋃ i, IooCat (c i) (d i)) :
    ofReal (f b - f a) ≤ ∑' i, ofReal (f (d i) - f (c i)) := by
  suffices
    ∀ (s : Finset ℕ) (b) (cv : Icc a b ⊆ ⋃ i ∈ (↑s : Set ℕ), Ioo (c i) (d i)),
      (of_real (f b - f a) : ℝ≥0∞) ≤ ∑ i in s, of_real (f (d i) - f (c i))
    by
    rcases is_compact_Icc.elim_finite_subcover_image (fun (i : ℕ) (_ : i ∈ univ) => @is_open_Ioo _ _ _ _ (c i) (d i))
        (by simpa using ss) with
      ⟨s, su, hf, hs⟩
    have e : (⋃ i ∈ (↑hf.to_finset : Set ℕ), Ioo (c i) (d i)) = ⋃ i ∈ s, Ioo (c i) (d i) := by
      simp only [ext_iff, exists_prop, Finset.set_bUnion_coe, mem_Union, forall_const, iff_self_iff,
        finite.mem_to_finset]
    rw [Ennreal.tsum_eq_supr_sum]
    refine' le_trans _ (le_supr _ hf.to_finset)
    exact this hf.to_finset _ (by simpa only [e] )
  clear ss b
  refine' fun s => Finset.strongInductionOn s fun s IH b cv => _
  cases' le_total b a with ab ab
  · rw [Ennreal.of_real_eq_zero.2 (sub_nonpos.2 (f.mono ab))]
    exact zero_le _
    
  have := cv ⟨ab, le_rfl⟩
  simp at this
  rcases this with ⟨i, is, cb, bd⟩
  rw [← Finset.insert_erase is] at cv⊢
  rw [Finset.coe_insert, bUnion_insert] at cv
  rw [Finset.sum_insert (Finset.not_mem_erase _ _)]
  refine' le_trans _ (add_le_add_left (IH _ (Finset.erase_ssubset is) (c i) _) _)
  · refine' le_trans (Ennreal.of_real_le_of_real _) Ennreal.of_real_add_le
    rw [sub_add_sub_cancel]
    exact sub_le_sub_right (f.mono bd.le) _
    
  · rintro x ⟨h₁, h₂⟩
    refine' (cv ⟨h₁, le_trans h₂ (le_of_lt cb)⟩).resolve_left (mt And.left (not_lt_of_le h₂))
    
#align stieltjes_function.length_subadditive_Icc_Ioo StieltjesFunction.length_subadditive_Icc_Ioo

@[simp]
theorem outer_Ioc (a b : ℝ) : f.outer (IocCat a b) = ofReal (f b - f a) := by
  /- It suffices to show that, if `(a, b]` is covered by sets `s i`, then `f b - f a` is bounded
    by `∑ f.length (s i) + ε`. The difficulty is that `f.length` is expressed in terms of half-open
    intervals, while we would like to have a compact interval covered by open intervals to use
    compactness and finite sums, as provided by `length_subadditive_Icc_Ioo`. The trick is to use the
    right-continuity of `f`. If `a'` is close enough to `a` on its right, then `[a', b]` is still
    covered by the sets `s i` and moreover `f b - f a'` is very close to `f b - f a` (up to `ε/2`).
    Also, by definition one can cover `s i` by a half-closed interval `(p i, q i]` with `f`-length
    very close to  that of `s i` (within a suitably small `ε' i`, say). If one moves `q i` very
    slightly to the right, then the `f`-length will change very little by right continuity, and we
    will get an open interval `(p i, q' i)` covering `s i` with `f (q' i) - f (p i)` within `ε' i`
    of the `f`-length of `s i`. -/
  refine'
    le_antisymm
      (by
        rw [← f.length_Ioc]
        apply outer_le_length)
      (le_infi₂ fun s hs => Ennreal.le_of_forall_pos_le_add fun ε εpos h => _)
  let δ := ε / 2
  have δpos : 0 < (δ : ℝ≥0∞) := by simpa using εpos.ne'
  rcases Ennreal.exists_pos_sum_of_countable δpos.ne' ℕ with ⟨ε', ε'0, hε⟩
  obtain ⟨a', ha', aa'⟩ : ∃ a', f a' - f a < δ ∧ a < a' := by
    have A : ContinuousWithinAt (fun r => f r - f a) (Ioi a) a := by
      refine' ContinuousWithinAt.sub _ continuous_within_at_const
      exact (f.right_continuous a).mono Ioi_subset_Ici_self
    have B : f a - f a < δ := by rwa [sub_self, Nnreal.coe_pos, ← Ennreal.coe_pos]
    exact (((tendsto_order.1 A).2 _ B).And self_mem_nhds_within).exists
  have : ∀ i, ∃ p : ℝ × ℝ, s i ⊆ Ioo p.1 p.2 ∧ (of_real (f p.2 - f p.1) : ℝ≥0∞) < f.length (s i) + ε' i := by
    intro i
    have := Ennreal.lt_add_right ((Ennreal.le_tsum i).trans_lt h).Ne (Ennreal.coe_ne_zero.2 (ε'0 i).ne')
    conv at this =>
    lhs
    rw [length]
    simp only [infi_lt_iff, exists_prop] at this
    rcases this with ⟨p, q', spq, hq'⟩
    have : ContinuousWithinAt (fun r => of_real (f r - f p)) (Ioi q') q' := by
      apply ennreal.continuous_of_real.continuous_at.comp_continuous_within_at
      refine' ContinuousWithinAt.sub _ continuous_within_at_const
      exact (f.right_continuous q').mono Ioi_subset_Ici_self
    rcases(((tendsto_order.1 this).2 _ hq').And self_mem_nhds_within).exists with ⟨q, hq, q'q⟩
    exact ⟨⟨p, q⟩, spq.trans (Ioc_subset_Ioo_right q'q), hq⟩
  choose g hg using this
  have I_subset : Icc a' b ⊆ ⋃ i, Ioo (g i).1 (g i).2 :=
    calc
      Icc a' b ⊆ Ioc a b := fun x hx => ⟨aa'.trans_le hx.1, hx.2⟩
      _ ⊆ ⋃ i, s i := hs
      _ ⊆ ⋃ i, Ioo (g i).1 (g i).2 := Union_mono fun i => (hg i).1
      
  calc
    of_real (f b - f a) = of_real (f b - f a' + (f a' - f a)) := by rw [sub_add_sub_cancel]
    _ ≤ of_real (f b - f a') + of_real (f a' - f a) := Ennreal.of_real_add_le
    _ ≤ (∑' i, of_real (f (g i).2 - f (g i).1)) + of_real δ :=
      add_le_add (f.length_subadditive_Icc_Ioo I_subset) (Ennreal.of_real_le_of_real ha'.le)
    _ ≤ (∑' i, f.length (s i) + ε' i) + δ :=
      add_le_add (Ennreal.tsum_le_tsum fun i => (hg i).2.le) (by simp only [Ennreal.of_real_coe_nnreal, le_rfl])
    _ = ((∑' i, f.length (s i)) + ∑' i, ε' i) + δ := by rw [Ennreal.tsum_add]
    _ ≤ (∑' i, f.length (s i)) + δ + δ := add_le_add (add_le_add le_rfl hε.le) le_rfl
    _ = (∑' i : ℕ, f.length (s i)) + ε := by simp [add_assoc, Ennreal.add_halves]
    
#align stieltjes_function.outer_Ioc StieltjesFunction.outer_Ioc

theorem measurableSetIoi {c : ℝ} : measurable_set[f.outer.caratheodory] (IoiCat c) := by
  apply outer_measure.of_function_caratheodory fun t => _
  refine' le_infi fun a => le_infi fun b => le_infi fun h => _
  refine'
    le_trans (add_le_add (f.length_mono <| inter_subset_inter_left _ h) (f.length_mono <| diff_subset_diff_left h)) _
  cases' le_total a c with hac hac <;> cases' le_total b c with hbc hbc
  · simp only [Ioc_inter_Ioi, f.length_Ioc, hac, sup_eq_max, hbc, le_refl, Ioc_eq_empty, max_eq_right, min_eq_left,
      Ioc_diff_Ioi, f.length_empty, zero_add, not_lt]
    
  · simp only [hac, hbc, Ioc_inter_Ioi, Ioc_diff_Ioi, f.length_Ioc, min_eq_right, sup_eq_max, ← Ennreal.of_real_add,
      f.mono hac, f.mono hbc, sub_nonneg, sub_add_sub_cancel, le_refl, max_eq_right]
    
  · simp only [hbc, le_refl, Ioc_eq_empty, Ioc_inter_Ioi, min_eq_left, Ioc_diff_Ioi, f.length_empty, zero_add,
      or_true_iff, le_sup_iff, f.length_Ioc, not_lt]
    
  · simp only [hac, hbc, Ioc_inter_Ioi, Ioc_diff_Ioi, f.length_Ioc, min_eq_right, sup_eq_max, le_refl, Ioc_eq_empty,
      add_zero, max_eq_left, f.length_empty, not_lt]
    
#align stieltjes_function.measurable_set_Ioi StieltjesFunction.measurableSetIoi

theorem outer_trim : f.outer.trim = f.outer := by
  refine' le_antisymm (fun s => _) (outer_measure.le_trim _)
  rw [outer_measure.trim_eq_infi]
  refine' le_infi fun t => le_infi fun ht => Ennreal.le_of_forall_pos_le_add fun ε ε0 h => _
  rcases Ennreal.exists_pos_sum_of_countable (Ennreal.coe_pos.2 ε0).ne' ℕ with ⟨ε', ε'0, hε⟩
  refine' le_trans _ (add_le_add_left (le_of_lt hε) _)
  rw [← Ennreal.tsum_add]
  choose g hg using
    show ∀ i, ∃ s, t i ⊆ s ∧ MeasurableSet s ∧ f.outer s ≤ f.length (t i) + of_real (ε' i) by
      intro i
      have := Ennreal.lt_add_right ((Ennreal.le_tsum i).trans_lt h).Ne (Ennreal.coe_pos.2 (ε'0 i)).ne'
      conv at this =>
      lhs
      rw [length]
      simp only [infi_lt_iff] at this
      rcases this with ⟨a, b, h₁, h₂⟩
      rw [← f.outer_Ioc] at h₂
      exact ⟨_, h₁, measurableSetIoc, le_of_lt <| by simpa using h₂⟩
  simp at hg
  apply infi_le_of_le (Union g) _
  apply infi_le_of_le (ht.trans <| Union_mono fun i => (hg i).1) _
  apply infi_le_of_le (MeasurableSet.union fun i => (hg i).2.1) _
  exact le_trans (f.outer.Union _) (Ennreal.tsum_le_tsum fun i => (hg i).2.2)
#align stieltjes_function.outer_trim StieltjesFunction.outer_trim

theorem borel_le_measurable : borel ℝ ≤ f.outer.caratheodory := by
  rw [borel_eq_generate_from_Ioi]
  refine' MeasurableSpace.generate_from_le _
  simp (config := { contextual := true }) [f.measurable_set_Ioi]
#align stieltjes_function.borel_le_measurable StieltjesFunction.borel_le_measurable

/-! ### The measure associated to a Stieltjes function -/


/-- The measure associated to a Stieltjes function, giving mass `f b - f a` to the
interval `(a, b]`. -/
protected irreducible_def measure : Measure ℝ :=
  { toOuterMeasure := f.outer,
    m_Union := fun s hs => f.outer.Union_eq_of_caratheodory fun i => f.borel_le_measurable _ (hs i),
    trimmed := f.outer_trim }
#align stieltjes_function.measure StieltjesFunction.measure

@[simp]
theorem measure_Ioc (a b : ℝ) : f.Measure (IocCat a b) = ofReal (f b - f a) := by
  rw [StieltjesFunction.measure]
  exact f.outer_Ioc a b
#align stieltjes_function.measure_Ioc StieltjesFunction.measure_Ioc

@[simp]
theorem measure_singleton (a : ℝ) : f.Measure {a} = ofReal (f a - leftLim f a) := by
  obtain ⟨u, u_mono, u_lt_a, u_lim⟩ : ∃ u : ℕ → ℝ, StrictMono u ∧ (∀ n : ℕ, u n < a) ∧ tendsto u at_top (𝓝 a) :=
    exists_seq_strict_mono_tendsto a
  have A : {a} = ⋂ n, Ioc (u n) a := by
    refine' subset.antisymm (fun x hx => by simp [mem_singleton_iff.1 hx, u_lt_a]) fun x hx => _
    simp at hx
    have : a ≤ x := le_of_tendsto' u_lim fun n => (hx n).1.le
    simp [le_antisymm this (hx 0).2]
  have L1 : tendsto (fun n => f.measure (Ioc (u n) a)) at_top (𝓝 (f.measure {a})) := by
    rw [A]
    refine' tendsto_measure_Inter (fun n => measurableSetIoc) (fun m n hmn => _) _
    · exact Ioc_subset_Ioc (u_mono.monotone hmn) le_rfl
      
    · exact ⟨0, by simpa only [measure_Ioc] using Ennreal.of_real_ne_top⟩
      
  have L2 : tendsto (fun n => f.measure (Ioc (u n) a)) at_top (𝓝 (of_real (f a - left_lim f a))) := by
    simp only [measure_Ioc]
    have : tendsto (fun n => f (u n)) at_top (𝓝 (left_lim f a)) := by
      apply (f.mono.tendsto_left_lim a).comp
      exact tendsto_nhds_within_of_tendsto_nhds_of_eventually_within _ u_lim (eventually_of_forall fun n => u_lt_a n)
    exact ennreal.continuous_of_real.continuous_at.tendsto.comp (tendsto_const_nhds.sub this)
  exact tendsto_nhds_unique L1 L2
#align stieltjes_function.measure_singleton StieltjesFunction.measure_singleton

@[simp]
theorem measure_Icc (a b : ℝ) : f.Measure (IccCat a b) = ofReal (f b - leftLim f a) := by
  rcases le_or_lt a b with (hab | hab)
  · have A : Disjoint {a} (Ioc a b) := by simp
    simp [← Icc_union_Ioc_eq_Icc le_rfl hab, -singleton_union, ← Ennreal.of_real_add, f.mono.left_lim_le,
      measure_union A measurableSetIoc, f.mono hab]
    
  · simp only [hab, measure_empty, Icc_eq_empty, not_le]
    symm
    simp [Ennreal.of_real_eq_zero, f.mono.le_left_lim hab]
    
#align stieltjes_function.measure_Icc StieltjesFunction.measure_Icc

@[simp]
theorem measure_Ioo {a b : ℝ} : f.Measure (IooCat a b) = ofReal (leftLim f b - f a) := by
  rcases le_or_lt b a with (hab | hab)
  · simp only [hab, measure_empty, Ioo_eq_empty, not_lt]
    symm
    simp [Ennreal.of_real_eq_zero, f.mono.left_lim_le hab]
    
  · have A : Disjoint (Ioo a b) {b} := by simp
    have D : f b - f a = f b - left_lim f b + (left_lim f b - f a) := by abel
    have := f.measure_Ioc a b
    simp only [← Ioo_union_Icc_eq_Ioc hab le_rfl, measure_singleton, measure_union A (measurable_set_singleton b),
      Icc_self] at this
    rw [D, Ennreal.of_real_add, add_comm] at this
    · simpa only [Ennreal.add_right_inj Ennreal.of_real_ne_top]
      
    · simp only [f.mono.left_lim_le, sub_nonneg]
      
    · simp only [f.mono.le_left_lim hab, sub_nonneg]
      
    
#align stieltjes_function.measure_Ioo StieltjesFunction.measure_Ioo

@[simp]
theorem measure_Ico (a b : ℝ) : f.Measure (IcoCat a b) = ofReal (leftLim f b - leftLim f a) := by
  rcases le_or_lt b a with (hab | hab)
  · simp only [hab, measure_empty, Ico_eq_empty, not_lt]
    symm
    simp [Ennreal.of_real_eq_zero, f.mono.left_lim hab]
    
  · have A : Disjoint {a} (Ioo a b) := by simp
    simp [← Icc_union_Ioo_eq_Ico le_rfl hab, -singleton_union, hab.ne, f.mono.left_lim_le,
      measure_union A measurableSetIoo, f.mono.le_left_lim hab, ← Ennreal.of_real_add]
    
#align stieltjes_function.measure_Ico StieltjesFunction.measure_Ico

instance : IsLocallyFiniteMeasure f.Measure :=
  ⟨fun x => ⟨IooCat (x - 1) (x + 1), Ioo_mem_nhds (by linarith) (by linarith), by simp⟩⟩

end StieltjesFunction

