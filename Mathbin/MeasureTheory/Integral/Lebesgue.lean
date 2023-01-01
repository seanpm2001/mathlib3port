/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module measure_theory.integral.lebesgue
! leanprover-community/mathlib commit 9aba7801eeecebb61f58a5763c2b6dd1b47dc6ef
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.MutuallySingular
import Mathbin.MeasureTheory.Constructions.BorelSpace
import Mathbin.Algebra.IndicatorFunction
import Mathbin.Algebra.Support
import Mathbin.Dynamics.Ergodic.MeasurePreserving

/-!
# Lebesgue integral for `ℝ≥0∞`-valued functions

We define simple functions and show that each Borel measurable function on `ℝ≥0∞` can be
approximated by a sequence of simple functions.

To prove something for an arbitrary measurable function into `ℝ≥0∞`, the theorem
`measurable.ennreal_induction` shows that is it sufficient to show that the property holds for
(multiples of) characteristic functions and is closed under addition and supremum of increasing
sequences of functions.

## Notation

We introduce the following notation for the lower Lebesgue integral of a function `f : α → ℝ≥0∞`.

* `∫⁻ x, f x ∂μ`: integral of a function `f : α → ℝ≥0∞` with respect to a measure `μ`;
* `∫⁻ x, f x`: integral of a function `f : α → ℝ≥0∞` with respect to the canonical measure
  `volume` on `α`;
* `∫⁻ x in s, f x ∂μ`: integral of a function `f : α → ℝ≥0∞` over a set `s` with respect
  to a measure `μ`, defined as `∫⁻ x, f x ∂(μ.restrict s)`;
* `∫⁻ x in s, f x`: integral of a function `f : α → ℝ≥0∞` over a set `s` with respect
  to the canonical measure `volume`, defined as `∫⁻ x, f x ∂(volume.restrict s)`.

-/


noncomputable section

open Set hiding restrict restrict_apply

open Filter Ennreal

open Function (support)

open Classical TopologicalSpace BigOperators Nnreal Ennreal MeasureTheory

namespace MeasureTheory

variable {α β γ δ : Type _}

/-- A function `f` from a measurable space to any type is called *simple*,
if every preimage `f ⁻¹' {x}` is measurable, and the range is finite. This structure bundles
a function with these properties. -/
structure SimpleFunc.{u, v} (α : Type u) [MeasurableSpace α] (β : Type v) where
  toFun : α → β
  measurable_set_fiber' : ∀ x, MeasurableSet (to_fun ⁻¹' {x})
  finite_range' : (Set.range to_fun).Finite
#align measure_theory.simple_func MeasureTheory.SimpleFunc

-- mathport name: «expr →ₛ »
local infixr:25 " →ₛ " => SimpleFunc

namespace SimpleFunc

section Measurable

variable [MeasurableSpace α]

instance hasCoeToFun : CoeFun (α →ₛ β) fun _ => α → β :=
  ⟨toFun⟩
#align measure_theory.simple_func.has_coe_to_fun MeasureTheory.SimpleFunc.hasCoeToFun

theorem coe_injective ⦃f g : α →ₛ β⦄ (H : (f : α → β) = g) : f = g := by
  cases f <;> cases g <;> congr <;> exact H
#align measure_theory.simple_func.coe_injective MeasureTheory.SimpleFunc.coe_injective

@[ext]
theorem ext {f g : α →ₛ β} (H : ∀ a, f a = g a) : f = g :=
  coe_injective <| funext H
#align measure_theory.simple_func.ext MeasureTheory.SimpleFunc.ext

theorem finite_range (f : α →ₛ β) : (Set.range f).Finite :=
  f.finite_range'
#align measure_theory.simple_func.finite_range MeasureTheory.SimpleFunc.finite_range

theorem measurable_set_fiber (f : α →ₛ β) (x : β) : MeasurableSet (f ⁻¹' {x}) :=
  f.measurable_set_fiber' x
#align measure_theory.simple_func.measurable_set_fiber MeasureTheory.SimpleFunc.measurable_set_fiber

@[simp]
theorem apply_mk (f : α → β) (h h') (x : α) : SimpleFunc.mk f h h' x = f x :=
  rfl
#align measure_theory.simple_func.apply_mk MeasureTheory.SimpleFunc.apply_mk

/-- Simple function defined on the empty type. -/
def ofIsEmpty [IsEmpty α] : α →ₛ β where
  toFun := isEmptyElim
  measurable_set_fiber' x := Subsingleton.measurable_set
  finite_range' := by simp [range_eq_empty]
#align measure_theory.simple_func.of_is_empty MeasureTheory.SimpleFunc.ofIsEmpty

/-- Range of a simple function `α →ₛ β` as a `finset β`. -/
protected def range (f : α →ₛ β) : Finset β :=
  f.finite_range.toFinset
#align measure_theory.simple_func.range MeasureTheory.SimpleFunc.range

@[simp]
theorem mem_range {f : α →ₛ β} {b} : b ∈ f.range ↔ b ∈ range f :=
  Finite.mem_to_finset _
#align measure_theory.simple_func.mem_range MeasureTheory.SimpleFunc.mem_range

theorem mem_range_self (f : α →ₛ β) (x : α) : f x ∈ f.range :=
  mem_range.2 ⟨x, rfl⟩
#align measure_theory.simple_func.mem_range_self MeasureTheory.SimpleFunc.mem_range_self

@[simp]
theorem coe_range (f : α →ₛ β) : (↑f.range : Set β) = Set.range f :=
  f.finite_range.coe_to_finset
#align measure_theory.simple_func.coe_range MeasureTheory.SimpleFunc.coe_range

theorem mem_range_of_measure_ne_zero {f : α →ₛ β} {x : β} {μ : Measure α} (H : μ (f ⁻¹' {x}) ≠ 0) :
    x ∈ f.range :=
  let ⟨a, ha⟩ := nonempty_of_measure_ne_zero H
  mem_range.2 ⟨a, ha⟩
#align
  measure_theory.simple_func.mem_range_of_measure_ne_zero MeasureTheory.SimpleFunc.mem_range_of_measure_ne_zero

theorem forall_range_iff {f : α →ₛ β} {p : β → Prop} : (∀ y ∈ f.range, p y) ↔ ∀ x, p (f x) := by
  simp only [mem_range, Set.forall_range_iff]
#align measure_theory.simple_func.forall_range_iff MeasureTheory.SimpleFunc.forall_range_iff

theorem exists_range_iff {f : α →ₛ β} {p : β → Prop} : (∃ y ∈ f.range, p y) ↔ ∃ x, p (f x) := by
  simpa only [mem_range, exists_prop] using Set.exists_range_iff
#align measure_theory.simple_func.exists_range_iff MeasureTheory.SimpleFunc.exists_range_iff

theorem preimage_eq_empty_iff (f : α →ₛ β) (b : β) : f ⁻¹' {b} = ∅ ↔ b ∉ f.range :=
  preimage_singleton_eq_empty.trans <| not_congr mem_range.symm
#align
  measure_theory.simple_func.preimage_eq_empty_iff MeasureTheory.SimpleFunc.preimage_eq_empty_iff

theorem exists_forall_le [Nonempty β] [Preorder β] [IsDirected β (· ≤ ·)] (f : α →ₛ β) :
    ∃ C, ∀ x, f x ≤ C :=
  f.range.exists_le.imp fun C => forall_range_iff.1
#align measure_theory.simple_func.exists_forall_le MeasureTheory.SimpleFunc.exists_forall_le

/-- Constant function as a `simple_func`. -/
def const (α) {β} [MeasurableSpace α] (b : β) : α →ₛ β :=
  ⟨fun a => b, fun x => MeasurableSet.const _, finite_range_const⟩
#align measure_theory.simple_func.const MeasureTheory.SimpleFunc.const

instance [Inhabited β] : Inhabited (α →ₛ β) :=
  ⟨const _ default⟩

theorem const_apply (a : α) (b : β) : (const α b) a = b :=
  rfl
#align measure_theory.simple_func.const_apply MeasureTheory.SimpleFunc.const_apply

@[simp]
theorem coe_const (b : β) : ⇑(const α b) = Function.const α b :=
  rfl
#align measure_theory.simple_func.coe_const MeasureTheory.SimpleFunc.coe_const

@[simp]
theorem range_const (α) [MeasurableSpace α] [Nonempty α] (b : β) : (const α b).range = {b} :=
  Finset.coe_injective <| by simp
#align measure_theory.simple_func.range_const MeasureTheory.SimpleFunc.range_const

theorem range_const_subset (α) [MeasurableSpace α] (b : β) : (const α b).range ⊆ {b} :=
  Finset.coe_subset.1 <| by simp
#align measure_theory.simple_func.range_const_subset MeasureTheory.SimpleFunc.range_const_subset

theorem simple_func_bot {α} (f : @SimpleFunc α ⊥ β) [Nonempty β] : ∃ c, ∀ x, f x = c :=
  by
  have hf_meas := @simple_func.measurable_set_fiber α _ ⊥ f
  simp_rw [MeasurableSpace.measurable_set_bot_iff] at hf_meas
  cases isEmpty_or_nonempty α
  · simp only [IsEmpty.forall_iff, exists_const]
  · specialize hf_meas (f h.some)
    cases hf_meas
    · exfalso
      refine' Set.not_mem_empty h.some _
      rw [← hf_meas, Set.mem_preimage]
      exact Set.mem_singleton _
    · refine' ⟨f h.some, fun x => _⟩
      have : x ∈ f ⁻¹' {f h.some} := by
        rw [hf_meas]
        exact Set.mem_univ x
      rwa [Set.mem_preimage, Set.mem_singleton_iff] at this
#align measure_theory.simple_func.simple_func_bot MeasureTheory.SimpleFunc.simple_func_bot

theorem simple_func_bot' {α} [Nonempty β] (f : @SimpleFunc α ⊥ β) :
    ∃ c, f = @SimpleFunc.const α _ ⊥ c :=
  by
  obtain ⟨c, h_eq⟩ := simple_func_bot f
  refine' ⟨c, _⟩
  ext1 x
  rw [h_eq x, simple_func.coe_const]
#align measure_theory.simple_func.simple_func_bot' MeasureTheory.SimpleFunc.simple_func_bot'

theorem measurable_set_cut (r : α → β → Prop) (f : α →ₛ β) (h : ∀ b, MeasurableSet { a | r a b }) :
    MeasurableSet { a | r a (f a) } :=
  by
  have : { a | r a (f a) } = ⋃ b ∈ range f, { a | r a b } ∩ f ⁻¹' {b} :=
    by
    ext a
    suffices r a (f a) ↔ ∃ i, r a (f i) ∧ f a = f i by simpa
    exact ⟨fun h => ⟨a, ⟨h, rfl⟩⟩, fun ⟨a', ⟨h', e⟩⟩ => e.symm ▸ h'⟩
  rw [this]
  exact
    MeasurableSet.bUnion f.finite_range.countable fun b _ =>
      MeasurableSet.inter (h b) (f.measurable_set_fiber _)
#align measure_theory.simple_func.measurable_set_cut MeasureTheory.SimpleFunc.measurable_set_cut

@[measurability]
theorem measurable_set_preimage (f : α →ₛ β) (s) : MeasurableSet (f ⁻¹' s) :=
  measurable_set_cut (fun _ b => b ∈ s) f fun b => MeasurableSet.const (b ∈ s)
#align
  measure_theory.simple_func.measurable_set_preimage MeasureTheory.SimpleFunc.measurable_set_preimage

/-- A simple function is measurable -/
@[measurability]
protected theorem measurable [MeasurableSpace β] (f : α →ₛ β) : Measurable f := fun s _ =>
  measurable_set_preimage f s
#align measure_theory.simple_func.measurable MeasureTheory.SimpleFunc.measurable

@[measurability]
protected theorem aeMeasurable [MeasurableSpace β] {μ : Measure α} (f : α →ₛ β) :
    AeMeasurable f μ :=
  f.Measurable.AeMeasurable
#align measure_theory.simple_func.ae_measurable MeasureTheory.SimpleFunc.aeMeasurable

protected theorem sum_measure_preimage_singleton (f : α →ₛ β) {μ : Measure α} (s : Finset β) :
    (∑ y in s, μ (f ⁻¹' {y})) = μ (f ⁻¹' ↑s) :=
  sum_measure_preimage_singleton _ fun _ _ => f.measurable_set_fiber _
#align
  measure_theory.simple_func.sum_measure_preimage_singleton MeasureTheory.SimpleFunc.sum_measure_preimage_singleton

theorem sum_range_measure_preimage_singleton (f : α →ₛ β) (μ : Measure α) :
    (∑ y in f.range, μ (f ⁻¹' {y})) = μ univ := by
  rw [f.sum_measure_preimage_singleton, coe_range, preimage_range]
#align
  measure_theory.simple_func.sum_range_measure_preimage_singleton MeasureTheory.SimpleFunc.sum_range_measure_preimage_singleton

/-- If-then-else as a `simple_func`. -/
def piecewise (s : Set α) (hs : MeasurableSet s) (f g : α →ₛ β) : α →ₛ β :=
  ⟨s.piecewise f g, fun x =>
    letI : MeasurableSpace β := ⊤
    f.measurable.piecewise hs g.measurable trivial,
    (f.finite_range.union g.finite_range).Subset range_ite_subset⟩
#align measure_theory.simple_func.piecewise MeasureTheory.SimpleFunc.piecewise

@[simp]
theorem coe_piecewise {s : Set α} (hs : MeasurableSet s) (f g : α →ₛ β) :
    ⇑(piecewise s hs f g) = s.piecewise f g :=
  rfl
#align measure_theory.simple_func.coe_piecewise MeasureTheory.SimpleFunc.coe_piecewise

theorem piecewise_apply {s : Set α} (hs : MeasurableSet s) (f g : α →ₛ β) (a) :
    piecewise s hs f g a = if a ∈ s then f a else g a :=
  rfl
#align measure_theory.simple_func.piecewise_apply MeasureTheory.SimpleFunc.piecewise_apply

@[simp]
theorem piecewise_compl {s : Set α} (hs : MeasurableSet (sᶜ)) (f g : α →ₛ β) :
    piecewise (sᶜ) hs f g = piecewise s hs.ofCompl g f :=
  coe_injective <| by simp [hs]
#align measure_theory.simple_func.piecewise_compl MeasureTheory.SimpleFunc.piecewise_compl

@[simp]
theorem piecewise_univ (f g : α →ₛ β) : piecewise univ MeasurableSet.univ f g = f :=
  coe_injective <| by simp
#align measure_theory.simple_func.piecewise_univ MeasureTheory.SimpleFunc.piecewise_univ

@[simp]
theorem piecewise_empty (f g : α →ₛ β) : piecewise ∅ MeasurableSet.empty f g = g :=
  coe_injective <| by simp
#align measure_theory.simple_func.piecewise_empty MeasureTheory.SimpleFunc.piecewise_empty

theorem support_indicator [Zero β] {s : Set α} (hs : MeasurableSet s) (f : α →ₛ β) :
    Function.support (f.piecewise s hs (SimpleFunc.const α 0)) = s ∩ Function.support f :=
  Set.support_indicator
#align measure_theory.simple_func.support_indicator MeasureTheory.SimpleFunc.support_indicator

theorem range_indicator {s : Set α} (hs : MeasurableSet s) (hs_nonempty : s.Nonempty)
    (hs_ne_univ : s ≠ univ) (x y : β) : (piecewise s hs (const α x) (const α y)).range = {x, y} :=
  by
  simp only [← Finset.coe_inj, coe_range, coe_piecewise, range_piecewise, coe_const,
    Finset.coe_insert, Finset.coe_singleton, hs_nonempty.image_const,
    (nonempty_compl.2 hs_ne_univ).image_const, singleton_union]
#align measure_theory.simple_func.range_indicator MeasureTheory.SimpleFunc.range_indicator

theorem measurable_bind [MeasurableSpace γ] (f : α →ₛ β) (g : β → α → γ)
    (hg : ∀ b, Measurable (g b)) : Measurable fun a => g (f a) a := fun s hs =>
  (f.measurable_set_cut fun a b => g b a ∈ s) fun b => hg b hs
#align measure_theory.simple_func.measurable_bind MeasureTheory.SimpleFunc.measurable_bind

/-- If `f : α →ₛ β` is a simple function and `g : β → α →ₛ γ` is a family of simple functions,
then `f.bind g` binds the first argument of `g` to `f`. In other words, `f.bind g a = g (f a) a`. -/
def bind (f : α →ₛ β) (g : β → α →ₛ γ) : α →ₛ γ :=
  ⟨fun a => g (f a) a, fun c =>
    (f.measurable_set_cut fun a b => g b a = c) fun b => (g b).measurable_set_preimage {c},
    (f.finite_range.bUnion fun b _ => (g b).finite_range).Subset <| by
      rintro _ ⟨a, rfl⟩ <;> simp <;> exact ⟨a, a, rfl⟩⟩
#align measure_theory.simple_func.bind MeasureTheory.SimpleFunc.bind

@[simp]
theorem bind_apply (f : α →ₛ β) (g : β → α →ₛ γ) (a) : f.bind g a = g (f a) a :=
  rfl
#align measure_theory.simple_func.bind_apply MeasureTheory.SimpleFunc.bind_apply

/-- Given a function `g : β → γ` and a simple function `f : α →ₛ β`, `f.map g` return the simple
    function `g ∘ f : α →ₛ γ` -/
def map (g : β → γ) (f : α →ₛ β) : α →ₛ γ :=
  bind f (const α ∘ g)
#align measure_theory.simple_func.map MeasureTheory.SimpleFunc.map

theorem map_apply (g : β → γ) (f : α →ₛ β) (a) : f.map g a = g (f a) :=
  rfl
#align measure_theory.simple_func.map_apply MeasureTheory.SimpleFunc.map_apply

theorem map_map (g : β → γ) (h : γ → δ) (f : α →ₛ β) : (f.map g).map h = f.map (h ∘ g) :=
  rfl
#align measure_theory.simple_func.map_map MeasureTheory.SimpleFunc.map_map

@[simp]
theorem coe_map (g : β → γ) (f : α →ₛ β) : (f.map g : α → γ) = g ∘ f :=
  rfl
#align measure_theory.simple_func.coe_map MeasureTheory.SimpleFunc.coe_map

@[simp]
theorem range_map [DecidableEq γ] (g : β → γ) (f : α →ₛ β) : (f.map g).range = f.range.image g :=
  Finset.coe_injective <| by simp only [coe_range, coe_map, Finset.coe_image, range_comp]
#align measure_theory.simple_func.range_map MeasureTheory.SimpleFunc.range_map

@[simp]
theorem map_const (g : β → γ) (b : β) : (const α b).map g = const α (g b) :=
  rfl
#align measure_theory.simple_func.map_const MeasureTheory.SimpleFunc.map_const

theorem map_preimage (f : α →ₛ β) (g : β → γ) (s : Set γ) :
    f.map g ⁻¹' s = f ⁻¹' ↑(f.range.filter fun b => g b ∈ s) :=
  by
  simp only [coe_range, sep_mem_eq, Set.mem_range, Function.comp_apply, coe_map, Finset.coe_filter,
    ← mem_preimage, inter_comm, preimage_inter_range]
  apply preimage_comp
#align measure_theory.simple_func.map_preimage MeasureTheory.SimpleFunc.map_preimage

theorem map_preimage_singleton (f : α →ₛ β) (g : β → γ) (c : γ) :
    f.map g ⁻¹' {c} = f ⁻¹' ↑(f.range.filter fun b => g b = c) :=
  map_preimage _ _ _
#align
  measure_theory.simple_func.map_preimage_singleton MeasureTheory.SimpleFunc.map_preimage_singleton

/-- Composition of a `simple_fun` and a measurable function is a `simple_func`. -/
def comp [MeasurableSpace β] (f : β →ₛ γ) (g : α → β) (hgm : Measurable g) : α →ₛ γ
    where
  toFun := f ∘ g
  finite_range' := f.finite_range.Subset <| Set.range_comp_subset_range _ _
  measurable_set_fiber' z := hgm (f.measurable_set_fiber z)
#align measure_theory.simple_func.comp MeasureTheory.SimpleFunc.comp

@[simp]
theorem coe_comp [MeasurableSpace β] (f : β →ₛ γ) {g : α → β} (hgm : Measurable g) :
    ⇑(f.comp g hgm) = f ∘ g :=
  rfl
#align measure_theory.simple_func.coe_comp MeasureTheory.SimpleFunc.coe_comp

theorem range_comp_subset_range [MeasurableSpace β] (f : β →ₛ γ) {g : α → β} (hgm : Measurable g) :
    (f.comp g hgm).range ⊆ f.range :=
  Finset.coe_subset.1 <| by simp only [coe_range, coe_comp, Set.range_comp_subset_range]
#align
  measure_theory.simple_func.range_comp_subset_range MeasureTheory.SimpleFunc.range_comp_subset_range

/-- Extend a `simple_func` along a measurable embedding: `f₁.extend g hg f₂` is the function
`F : β →ₛ γ` such that `F ∘ g = f₁` and `F y = f₂ y` whenever `y ∉ range g`. -/
def extend [MeasurableSpace β] (f₁ : α →ₛ γ) (g : α → β) (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) : β →ₛ γ where
  toFun := Function.extend g f₁ f₂
  finite_range' :=
    (f₁.finite_range.union <| f₂.finite_range.Subset (image_subset_range _ _)).Subset
      (range_extend_subset _ _ _)
  measurable_set_fiber' := by
    letI : MeasurableSpace γ := ⊤; haveI : MeasurableSingletonClass γ := ⟨fun _ => trivial⟩
    exact fun x => hg.measurable_extend f₁.measurable f₂.measurable (measurable_set_singleton _)
#align measure_theory.simple_func.extend MeasureTheory.SimpleFunc.extend

@[simp]
theorem extend_apply [MeasurableSpace β] (f₁ : α →ₛ γ) {g : α → β} (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) (x : α) : (f₁.extend g hg f₂) (g x) = f₁ x :=
  hg.Injective.extend_apply _ _ _
#align measure_theory.simple_func.extend_apply MeasureTheory.SimpleFunc.extend_apply

@[simp]
theorem extend_apply' [MeasurableSpace β] (f₁ : α →ₛ γ) {g : α → β} (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) {y : β} (h : ¬∃ x, g x = y) : (f₁.extend g hg f₂) y = f₂ y :=
  Function.extend_apply' _ _ _ h
#align measure_theory.simple_func.extend_apply' MeasureTheory.SimpleFunc.extend_apply'

@[simp]
theorem extend_comp_eq' [MeasurableSpace β] (f₁ : α →ₛ γ) {g : α → β} (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) : f₁.extend g hg f₂ ∘ g = f₁ :=
  funext fun x => extend_apply _ _ _ _
#align measure_theory.simple_func.extend_comp_eq' MeasureTheory.SimpleFunc.extend_comp_eq'

@[simp]
theorem extend_comp_eq [MeasurableSpace β] (f₁ : α →ₛ γ) {g : α → β} (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) : (f₁.extend g hg f₂).comp g hg.Measurable = f₁ :=
  coe_injective <| extend_comp_eq' _ _ _
#align measure_theory.simple_func.extend_comp_eq MeasureTheory.SimpleFunc.extend_comp_eq

/-- If `f` is a simple function taking values in `β → γ` and `g` is another simple function
with the same domain and codomain `β`, then `f.seq g = f a (g a)`. -/
def seq (f : α →ₛ β → γ) (g : α →ₛ β) : α →ₛ γ :=
  f.bind fun f => g.map f
#align measure_theory.simple_func.seq MeasureTheory.SimpleFunc.seq

@[simp]
theorem seq_apply (f : α →ₛ β → γ) (g : α →ₛ β) (a : α) : f.seq g a = f a (g a) :=
  rfl
#align measure_theory.simple_func.seq_apply MeasureTheory.SimpleFunc.seq_apply

/-- Combine two simple functions `f : α →ₛ β` and `g : α →ₛ β`
into `λ a, (f a, g a)`. -/
def pair (f : α →ₛ β) (g : α →ₛ γ) : α →ₛ β × γ :=
  (f.map Prod.mk).seq g
#align measure_theory.simple_func.pair MeasureTheory.SimpleFunc.pair

@[simp]
theorem pair_apply (f : α →ₛ β) (g : α →ₛ γ) (a) : pair f g a = (f a, g a) :=
  rfl
#align measure_theory.simple_func.pair_apply MeasureTheory.SimpleFunc.pair_apply

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem pair_preimage (f : α →ₛ β) (g : α →ₛ γ) (s : Set β) (t : Set γ) :
    pair f g ⁻¹' s ×ˢ t = f ⁻¹' s ∩ g ⁻¹' t :=
  rfl
#align measure_theory.simple_func.pair_preimage MeasureTheory.SimpleFunc.pair_preimage

-- A special form of `pair_preimage`
theorem pair_preimage_singleton (f : α →ₛ β) (g : α →ₛ γ) (b : β) (c : γ) :
    pair f g ⁻¹' {(b, c)} = f ⁻¹' {b} ∩ g ⁻¹' {c} :=
  by
  rw [← singleton_prod_singleton]
  exact pair_preimage _ _ _ _
#align
  measure_theory.simple_func.pair_preimage_singleton MeasureTheory.SimpleFunc.pair_preimage_singleton

theorem bind_const (f : α →ₛ β) : f.bind (const α) = f := by ext <;> simp
#align measure_theory.simple_func.bind_const MeasureTheory.SimpleFunc.bind_const

@[to_additive]
instance [One β] : One (α →ₛ β) :=
  ⟨const α 1⟩

@[to_additive]
instance [Mul β] : Mul (α →ₛ β) :=
  ⟨fun f g => (f.map (· * ·)).seq g⟩

@[to_additive]
instance [Div β] : Div (α →ₛ β) :=
  ⟨fun f g => (f.map (· / ·)).seq g⟩

@[to_additive]
instance [Inv β] : Inv (α →ₛ β) :=
  ⟨fun f => f.map Inv.inv⟩

instance [HasSup β] : HasSup (α →ₛ β) :=
  ⟨fun f g => (f.map (· ⊔ ·)).seq g⟩

instance [HasInf β] : HasInf (α →ₛ β) :=
  ⟨fun f g => (f.map (· ⊓ ·)).seq g⟩

instance [LE β] : LE (α →ₛ β) :=
  ⟨fun f g => ∀ a, f a ≤ g a⟩

@[simp, to_additive]
theorem const_one [One β] : const α (1 : β) = 1 :=
  rfl
#align measure_theory.simple_func.const_one MeasureTheory.SimpleFunc.const_one

@[simp, norm_cast, to_additive]
theorem coe_one [One β] : ⇑(1 : α →ₛ β) = 1 :=
  rfl
#align measure_theory.simple_func.coe_one MeasureTheory.SimpleFunc.coe_one

@[simp, norm_cast, to_additive]
theorem coe_mul [Mul β] (f g : α →ₛ β) : ⇑(f * g) = f * g :=
  rfl
#align measure_theory.simple_func.coe_mul MeasureTheory.SimpleFunc.coe_mul

@[simp, norm_cast, to_additive]
theorem coe_inv [Inv β] (f : α →ₛ β) : ⇑f⁻¹ = f⁻¹ :=
  rfl
#align measure_theory.simple_func.coe_inv MeasureTheory.SimpleFunc.coe_inv

@[simp, norm_cast, to_additive]
theorem coe_div [Div β] (f g : α →ₛ β) : ⇑(f / g) = f / g :=
  rfl
#align measure_theory.simple_func.coe_div MeasureTheory.SimpleFunc.coe_div

@[simp, norm_cast]
theorem coe_le [Preorder β] {f g : α →ₛ β} : (f : α → β) ≤ g ↔ f ≤ g :=
  Iff.rfl
#align measure_theory.simple_func.coe_le MeasureTheory.SimpleFunc.coe_le

@[simp, norm_cast]
theorem coe_sup [HasSup β] (f g : α →ₛ β) : ⇑(f ⊔ g) = f ⊔ g :=
  rfl
#align measure_theory.simple_func.coe_sup MeasureTheory.SimpleFunc.coe_sup

@[simp, norm_cast]
theorem coe_inf [HasInf β] (f g : α →ₛ β) : ⇑(f ⊓ g) = f ⊓ g :=
  rfl
#align measure_theory.simple_func.coe_inf MeasureTheory.SimpleFunc.coe_inf

@[to_additive]
theorem mul_apply [Mul β] (f g : α →ₛ β) (a : α) : (f * g) a = f a * g a :=
  rfl
#align measure_theory.simple_func.mul_apply MeasureTheory.SimpleFunc.mul_apply

@[to_additive]
theorem div_apply [Div β] (f g : α →ₛ β) (x : α) : (f / g) x = f x / g x :=
  rfl
#align measure_theory.simple_func.div_apply MeasureTheory.SimpleFunc.div_apply

@[to_additive]
theorem inv_apply [Inv β] (f : α →ₛ β) (x : α) : f⁻¹ x = (f x)⁻¹ :=
  rfl
#align measure_theory.simple_func.inv_apply MeasureTheory.SimpleFunc.inv_apply

theorem sup_apply [HasSup β] (f g : α →ₛ β) (a : α) : (f ⊔ g) a = f a ⊔ g a :=
  rfl
#align measure_theory.simple_func.sup_apply MeasureTheory.SimpleFunc.sup_apply

theorem inf_apply [HasInf β] (f g : α →ₛ β) (a : α) : (f ⊓ g) a = f a ⊓ g a :=
  rfl
#align measure_theory.simple_func.inf_apply MeasureTheory.SimpleFunc.inf_apply

@[simp, to_additive]
theorem range_one [Nonempty α] [One β] : (1 : α →ₛ β).range = {1} :=
  Finset.ext fun x => by simp [eq_comm]
#align measure_theory.simple_func.range_one MeasureTheory.SimpleFunc.range_one

@[simp]
theorem range_eq_empty_of_is_empty {β} [hα : IsEmpty α] (f : α →ₛ β) : f.range = ∅ :=
  by
  rw [← Finset.not_nonempty_iff_eq_empty]
  by_contra
  obtain ⟨y, hy_mem⟩ := h
  rw [simple_func.mem_range, Set.mem_range] at hy_mem
  obtain ⟨x, hxy⟩ := hy_mem
  rw [isEmpty_iff] at hα
  exact hα x
#align
  measure_theory.simple_func.range_eq_empty_of_is_empty MeasureTheory.SimpleFunc.range_eq_empty_of_is_empty

theorem eq_zero_of_mem_range_zero [Zero β] : ∀ {y : β}, y ∈ (0 : α →ₛ β).range → y = 0 :=
  forall_range_iff.2 fun x => rfl
#align
  measure_theory.simple_func.eq_zero_of_mem_range_zero MeasureTheory.SimpleFunc.eq_zero_of_mem_range_zero

@[to_additive]
theorem mul_eq_map₂ [Mul β] (f g : α →ₛ β) : f * g = (pair f g).map fun p : β × β => p.1 * p.2 :=
  rfl
#align measure_theory.simple_func.mul_eq_map₂ MeasureTheory.SimpleFunc.mul_eq_map₂

theorem sup_eq_map₂ [HasSup β] (f g : α →ₛ β) : f ⊔ g = (pair f g).map fun p : β × β => p.1 ⊔ p.2 :=
  rfl
#align measure_theory.simple_func.sup_eq_map₂ MeasureTheory.SimpleFunc.sup_eq_map₂

@[to_additive]
theorem const_mul_eq_map [Mul β] (f : α →ₛ β) (b : β) : const α b * f = f.map fun a => b * a :=
  rfl
#align measure_theory.simple_func.const_mul_eq_map MeasureTheory.SimpleFunc.const_mul_eq_map

@[to_additive]
theorem map_mul [Mul β] [Mul γ] {g : β → γ} (hg : ∀ x y, g (x * y) = g x * g y) (f₁ f₂ : α →ₛ β) :
    (f₁ * f₂).map g = f₁.map g * f₂.map g :=
  ext fun x => hg _ _
#align measure_theory.simple_func.map_mul MeasureTheory.SimpleFunc.map_mul

variable {K : Type _}

instance [HasSmul K β] : HasSmul K (α →ₛ β) :=
  ⟨fun k f => f.map ((· • ·) k)⟩

@[simp]
theorem coe_smul [HasSmul K β] (c : K) (f : α →ₛ β) : ⇑(c • f) = c • f :=
  rfl
#align measure_theory.simple_func.coe_smul MeasureTheory.SimpleFunc.coe_smul

theorem smul_apply [HasSmul K β] (k : K) (f : α →ₛ β) (a : α) : (k • f) a = k • f a :=
  rfl
#align measure_theory.simple_func.smul_apply MeasureTheory.SimpleFunc.smul_apply

instance hasNatPow [Monoid β] : Pow (α →ₛ β) ℕ :=
  ⟨fun f n => f.map (· ^ n)⟩
#align measure_theory.simple_func.has_nat_pow MeasureTheory.SimpleFunc.hasNatPow

@[simp]
theorem coe_pow [Monoid β] (f : α →ₛ β) (n : ℕ) : ⇑(f ^ n) = f ^ n :=
  rfl
#align measure_theory.simple_func.coe_pow MeasureTheory.SimpleFunc.coe_pow

theorem pow_apply [Monoid β] (n : ℕ) (f : α →ₛ β) (a : α) : (f ^ n) a = f a ^ n :=
  rfl
#align measure_theory.simple_func.pow_apply MeasureTheory.SimpleFunc.pow_apply

instance hasIntPow [DivInvMonoid β] : Pow (α →ₛ β) ℤ :=
  ⟨fun f n => f.map (· ^ n)⟩
#align measure_theory.simple_func.has_int_pow MeasureTheory.SimpleFunc.hasIntPow

@[simp]
theorem coe_zpow [DivInvMonoid β] (f : α →ₛ β) (z : ℤ) : ⇑(f ^ z) = f ^ z :=
  rfl
#align measure_theory.simple_func.coe_zpow MeasureTheory.SimpleFunc.coe_zpow

theorem zpow_apply [DivInvMonoid β] (z : ℤ) (f : α →ₛ β) (a : α) : (f ^ z) a = f a ^ z :=
  rfl
#align measure_theory.simple_func.zpow_apply MeasureTheory.SimpleFunc.zpow_apply

-- TODO: work out how to generate these instances with `to_additive`, which gets confused by the
-- argument order swap between `coe_smul` and `coe_pow`.
section Additive

instance [AddMonoid β] : AddMonoid (α →ₛ β) :=
  Function.Injective.addMonoid (fun f => show α → β from f) coe_injective coe_zero coe_add
    fun _ _ => coe_smul _ _

instance [AddCommMonoid β] : AddCommMonoid (α →ₛ β) :=
  Function.Injective.addCommMonoid (fun f => show α → β from f) coe_injective coe_zero coe_add
    fun _ _ => coe_smul _ _

instance [AddGroup β] : AddGroup (α →ₛ β) :=
  Function.Injective.addGroup (fun f => show α → β from f) coe_injective coe_zero coe_add coe_neg
    coe_sub (fun _ _ => coe_smul _ _) fun _ _ => coe_smul _ _

instance [AddCommGroup β] : AddCommGroup (α →ₛ β) :=
  Function.Injective.addCommGroup (fun f => show α → β from f) coe_injective coe_zero coe_add
    coe_neg coe_sub (fun _ _ => coe_smul _ _) fun _ _ => coe_smul _ _

end Additive

@[to_additive]
instance [Monoid β] : Monoid (α →ₛ β) :=
  Function.Injective.monoid (fun f => show α → β from f) coe_injective coe_one coe_mul coe_pow

@[to_additive]
instance [CommMonoid β] : CommMonoid (α →ₛ β) :=
  Function.Injective.commMonoid (fun f => show α → β from f) coe_injective coe_one coe_mul coe_pow

@[to_additive]
instance [Group β] : Group (α →ₛ β) :=
  Function.Injective.group (fun f => show α → β from f) coe_injective coe_one coe_mul coe_inv
    coe_div coe_pow coe_zpow

@[to_additive]
instance [CommGroup β] : CommGroup (α →ₛ β) :=
  Function.Injective.commGroup (fun f => show α → β from f) coe_injective coe_one coe_mul coe_inv
    coe_div coe_pow coe_zpow

instance [Semiring K] [AddCommMonoid β] [Module K β] : Module K (α →ₛ β) :=
  Function.Injective.module K ⟨fun f => show α → β from f, coe_zero, coe_add⟩ coe_injective coe_smul

theorem smul_eq_map [HasSmul K β] (k : K) (f : α →ₛ β) : k • f = f.map ((· • ·) k) :=
  rfl
#align measure_theory.simple_func.smul_eq_map MeasureTheory.SimpleFunc.smul_eq_map

instance [Preorder β] : Preorder (α →ₛ β) :=
  { SimpleFunc.hasLe with
    le_refl := fun f a => le_rfl
    le_trans := fun f g h hfg hgh a => le_trans (hfg _) (hgh a) }

instance [PartialOrder β] : PartialOrder (α →ₛ β) :=
  { SimpleFunc.preorder with
    le_antisymm := fun f g hfg hgf => ext fun a => le_antisymm (hfg a) (hgf a) }

instance [LE β] [OrderBot β] : OrderBot (α →ₛ β)
    where
  bot := const α ⊥
  bot_le f a := bot_le

instance [LE β] [OrderTop β] : OrderTop (α →ₛ β)
    where
  top := const α ⊤
  le_top f a := le_top

instance [SemilatticeInf β] : SemilatticeInf (α →ₛ β) :=
  { SimpleFunc.partialOrder with
    inf := (· ⊓ ·)
    inf_le_left := fun f g a => inf_le_left
    inf_le_right := fun f g a => inf_le_right
    le_inf := fun f g h hfh hgh a => le_inf (hfh a) (hgh a) }

instance [SemilatticeSup β] : SemilatticeSup (α →ₛ β) :=
  { SimpleFunc.partialOrder with
    sup := (· ⊔ ·)
    le_sup_left := fun f g a => le_sup_left
    le_sup_right := fun f g a => le_sup_right
    sup_le := fun f g h hfh hgh a => sup_le (hfh a) (hgh a) }

instance [Lattice β] : Lattice (α →ₛ β) :=
  { SimpleFunc.semilatticeSup, SimpleFunc.semilatticeInf with }

instance [LE β] [BoundedOrder β] : BoundedOrder (α →ₛ β) :=
  { SimpleFunc.orderBot, SimpleFunc.orderTop with }

theorem finset_sup_apply [SemilatticeSup β] [OrderBot β] {f : γ → α →ₛ β} (s : Finset γ) (a : α) :
    s.sup f a = s.sup fun c => f c a :=
  by
  refine' Finset.induction_on s rfl _
  intro a s hs ih
  rw [Finset.sup_insert, Finset.sup_insert, sup_apply, ih]
#align measure_theory.simple_func.finset_sup_apply MeasureTheory.SimpleFunc.finset_sup_apply

section Restrict

variable [Zero β]

/-- Restrict a simple function `f : α →ₛ β` to a set `s`. If `s` is measurable,
then `f.restrict s a = if a ∈ s then f a else 0`, otherwise `f.restrict s = const α 0`. -/
def restrict (f : α →ₛ β) (s : Set α) : α →ₛ β :=
  if hs : MeasurableSet s then piecewise s hs f 0 else 0
#align measure_theory.simple_func.restrict MeasureTheory.SimpleFunc.restrict

theorem restrict_of_not_measurable {f : α →ₛ β} {s : Set α} (hs : ¬MeasurableSet s) :
    restrict f s = 0 :=
  dif_neg hs
#align
  measure_theory.simple_func.restrict_of_not_measurable MeasureTheory.SimpleFunc.restrict_of_not_measurable

@[simp]
theorem coe_restrict (f : α →ₛ β) {s : Set α} (hs : MeasurableSet s) :
    ⇑(restrict f s) = indicator s f :=
  by
  rw [restrict, dif_pos hs]
  rfl
#align measure_theory.simple_func.coe_restrict MeasureTheory.SimpleFunc.coe_restrict

@[simp]
theorem restrict_univ (f : α →ₛ β) : restrict f univ = f := by simp [restrict]
#align measure_theory.simple_func.restrict_univ MeasureTheory.SimpleFunc.restrict_univ

@[simp]
theorem restrict_empty (f : α →ₛ β) : restrict f ∅ = 0 := by simp [restrict]
#align measure_theory.simple_func.restrict_empty MeasureTheory.SimpleFunc.restrict_empty

theorem map_restrict_of_zero [Zero γ] {g : β → γ} (hg : g 0 = 0) (f : α →ₛ β) (s : Set α) :
    (f.restrict s).map g = (f.map g).restrict s :=
  ext fun x =>
    if hs : MeasurableSet s then by simp [hs, Set.indicator_comp_of_zero hg]
    else by simp [restrict_of_not_measurable hs, hg]
#align measure_theory.simple_func.map_restrict_of_zero MeasureTheory.SimpleFunc.map_restrict_of_zero

theorem map_coe_ennreal_restrict (f : α →ₛ ℝ≥0) (s : Set α) :
    (f.restrict s).map (coe : ℝ≥0 → ℝ≥0∞) = (f.map coe).restrict s :=
  map_restrict_of_zero Ennreal.coe_zero _ _
#align
  measure_theory.simple_func.map_coe_ennreal_restrict MeasureTheory.SimpleFunc.map_coe_ennreal_restrict

theorem map_coe_nnreal_restrict (f : α →ₛ ℝ≥0) (s : Set α) :
    (f.restrict s).map (coe : ℝ≥0 → ℝ) = (f.map coe).restrict s :=
  map_restrict_of_zero Nnreal.coe_zero _ _
#align
  measure_theory.simple_func.map_coe_nnreal_restrict MeasureTheory.SimpleFunc.map_coe_nnreal_restrict

theorem restrict_apply (f : α →ₛ β) {s : Set α} (hs : MeasurableSet s) (a) :
    restrict f s a = indicator s f a := by simp only [f.coe_restrict hs]
#align measure_theory.simple_func.restrict_apply MeasureTheory.SimpleFunc.restrict_apply

theorem restrict_preimage (f : α →ₛ β) {s : Set α} (hs : MeasurableSet s) {t : Set β}
    (ht : (0 : β) ∉ t) : restrict f s ⁻¹' t = s ∩ f ⁻¹' t := by
  simp [hs, indicator_preimage_of_not_mem _ _ ht, inter_comm]
#align measure_theory.simple_func.restrict_preimage MeasureTheory.SimpleFunc.restrict_preimage

theorem restrict_preimage_singleton (f : α →ₛ β) {s : Set α} (hs : MeasurableSet s) {r : β}
    (hr : r ≠ 0) : restrict f s ⁻¹' {r} = s ∩ f ⁻¹' {r} :=
  f.restrictPreimage hs hr.symm
#align
  measure_theory.simple_func.restrict_preimage_singleton MeasureTheory.SimpleFunc.restrict_preimage_singleton

theorem mem_restrict_range {r : β} {s : Set α} {f : α →ₛ β} (hs : MeasurableSet s) :
    r ∈ (restrict f s).range ↔ r = 0 ∧ s ≠ univ ∨ r ∈ f '' s := by
  rw [← Finset.mem_coe, coe_range, coe_restrict _ hs, mem_range_indicator]
#align measure_theory.simple_func.mem_restrict_range MeasureTheory.SimpleFunc.mem_restrict_range

theorem mem_image_of_mem_range_restrict {r : β} {s : Set α} {f : α →ₛ β}
    (hr : r ∈ (restrict f s).range) (h0 : r ≠ 0) : r ∈ f '' s :=
  if hs : MeasurableSet s then by simpa [mem_restrict_range hs, h0] using hr
  else by
    rw [restrict_of_not_measurable hs] at hr
    exact (h0 <| eq_zero_of_mem_range_zero hr).elim
#align
  measure_theory.simple_func.mem_image_of_mem_range_restrict MeasureTheory.SimpleFunc.mem_image_of_mem_range_restrict

@[mono]
theorem restrict_mono [Preorder β] (s : Set α) {f g : α →ₛ β} (H : f ≤ g) :
    f.restrict s ≤ g.restrict s :=
  if hs : MeasurableSet s then fun x => by
    simp only [coe_restrict _ hs, indicator_le_indicator (H x)]
  else by simp only [restrict_of_not_measurable hs, le_refl]
#align measure_theory.simple_func.restrict_mono MeasureTheory.SimpleFunc.restrict_mono

end Restrict

section Approx

section

variable [SemilatticeSup β] [OrderBot β] [Zero β]

/-- Fix a sequence `i : ℕ → β`. Given a function `α → β`, its `n`-th approximation
by simple functions is defined so that in case `β = ℝ≥0∞` it sends each `a` to the supremum
of the set `{i k | k ≤ n ∧ i k ≤ f a}`, see `approx_apply` and `supr_approx_apply` for details. -/
def approx (i : ℕ → β) (f : α → β) (n : ℕ) : α →ₛ β :=
  (Finset.range n).sup fun k => restrict (const α (i k)) { a : α | i k ≤ f a }
#align measure_theory.simple_func.approx MeasureTheory.SimpleFunc.approx

theorem approx_apply [TopologicalSpace β] [OrderClosedTopology β] [MeasurableSpace β]
    [OpensMeasurableSpace β] {i : ℕ → β} {f : α → β} {n : ℕ} (a : α) (hf : Measurable f) :
    (approx i f n : α →ₛ β) a = (Finset.range n).sup fun k => if i k ≤ f a then i k else 0 :=
  by
  dsimp only [approx]
  rw [finset_sup_apply]
  congr
  funext k
  rw [restrict_apply]
  rfl
  exact hf measurable_set_Ici
#align measure_theory.simple_func.approx_apply MeasureTheory.SimpleFunc.approx_apply

theorem monotone_approx (i : ℕ → β) (f : α → β) : Monotone (approx i f) := fun n m h =>
  Finset.sup_mono <| Finset.range_subset.2 h
#align measure_theory.simple_func.monotone_approx MeasureTheory.SimpleFunc.monotone_approx

theorem approx_comp [TopologicalSpace β] [OrderClosedTopology β] [MeasurableSpace β]
    [OpensMeasurableSpace β] [MeasurableSpace γ] {i : ℕ → β} {f : γ → β} {g : α → γ} {n : ℕ} (a : α)
    (hf : Measurable f) (hg : Measurable g) :
    (approx i (f ∘ g) n : α →ₛ β) a = (approx i f n : γ →ₛ β) (g a) := by
  rw [approx_apply _ hf, approx_apply _ (hf.comp hg)]
#align measure_theory.simple_func.approx_comp MeasureTheory.SimpleFunc.approx_comp

end

theorem supr_approx_apply [TopologicalSpace β] [CompleteLattice β] [OrderClosedTopology β] [Zero β]
    [MeasurableSpace β] [OpensMeasurableSpace β] (i : ℕ → β) (f : α → β) (a : α) (hf : Measurable f)
    (h_zero : (0 : β) = ⊥) : (⨆ n, (approx i f n : α →ₛ β) a) = ⨆ (k) (h : i k ≤ f a), i k :=
  by
  refine' le_antisymm (supᵢ_le fun n => _) (supᵢ_le fun k => supᵢ_le fun hk => _)
  · rw [approx_apply a hf, h_zero]
    refine' Finset.sup_le fun k hk => _
    split_ifs
    exact le_supᵢ_of_le k (le_supᵢ _ h)
    exact bot_le
  · refine' le_supᵢ_of_le (k + 1) _
    rw [approx_apply a hf]
    have : k ∈ Finset.range (k + 1) := Finset.mem_range.2 (Nat.lt_succ_self _)
    refine' le_trans (le_of_eq _) (Finset.le_sup this)
    rw [if_pos hk]
#align measure_theory.simple_func.supr_approx_apply MeasureTheory.SimpleFunc.supr_approx_apply

end Approx

section Eapprox

/-- A sequence of `ℝ≥0∞`s such that its range is the set of non-negative rational numbers. -/
def ennrealRatEmbed (n : ℕ) : ℝ≥0∞ :=
  Ennreal.ofReal ((Encodable.decode ℚ n).getOrElse (0 : ℚ))
#align measure_theory.simple_func.ennreal_rat_embed MeasureTheory.SimpleFunc.ennrealRatEmbed

theorem ennreal_rat_embed_encode (q : ℚ) : ennrealRatEmbed (Encodable.encode q) = Real.toNnreal q :=
  by rw [ennreal_rat_embed, Encodable.encodek] <;> rfl
#align
  measure_theory.simple_func.ennreal_rat_embed_encode MeasureTheory.SimpleFunc.ennreal_rat_embed_encode

/-- Approximate a function `α → ℝ≥0∞` by a sequence of simple functions. -/
def eapprox : (α → ℝ≥0∞) → ℕ → α →ₛ ℝ≥0∞ :=
  approx ennrealRatEmbed
#align measure_theory.simple_func.eapprox MeasureTheory.SimpleFunc.eapprox

theorem eapprox_lt_top (f : α → ℝ≥0∞) (n : ℕ) (a : α) : eapprox f n a < ∞ :=
  by
  simp only [eapprox, approx, finset_sup_apply, Finset.sup_lt_iff, WithTop.zero_lt_top,
    Finset.mem_range, Ennreal.bot_eq_zero, restrict]
  intro b hb
  split_ifs
  · simp only [coe_zero, coe_piecewise, piecewise_eq_indicator, coe_const]
    calc
      { a : α | ennreal_rat_embed b ≤ f a }.indicator (fun x => ennreal_rat_embed b) a ≤
          ennreal_rat_embed b :=
        indicator_le_self _ _ a
      _ < ⊤ := Ennreal.coe_lt_top
      
  · exact WithTop.zero_lt_top
#align measure_theory.simple_func.eapprox_lt_top MeasureTheory.SimpleFunc.eapprox_lt_top

@[mono]
theorem monotone_eapprox (f : α → ℝ≥0∞) : Monotone (eapprox f) :=
  monotone_approx _ f
#align measure_theory.simple_func.monotone_eapprox MeasureTheory.SimpleFunc.monotone_eapprox

theorem supr_eapprox_apply (f : α → ℝ≥0∞) (hf : Measurable f) (a : α) :
    (⨆ n, (eapprox f n : α →ₛ ℝ≥0∞) a) = f a :=
  by
  rw [eapprox, supr_approx_apply ennreal_rat_embed f a hf rfl]
  refine' le_antisymm (supᵢ_le fun i => supᵢ_le fun hi => hi) (le_of_not_gt _)
  intro h
  rcases Ennreal.lt_iff_exists_rat_btwn.1 h with ⟨q, hq, lt_q, q_lt⟩
  have :
    (Real.toNnreal q : ℝ≥0∞) ≤ ⨆ (k : ℕ) (h : ennreal_rat_embed k ≤ f a), ennreal_rat_embed k :=
    by
    refine' le_supᵢ_of_le (Encodable.encode q) _
    rw [ennreal_rat_embed_encode q]
    refine' le_supᵢ_of_le (le_of_lt q_lt) _
    exact le_rfl
  exact lt_irrefl _ (lt_of_le_of_lt this lt_q)
#align measure_theory.simple_func.supr_eapprox_apply MeasureTheory.SimpleFunc.supr_eapprox_apply

theorem eapprox_comp [MeasurableSpace γ] {f : γ → ℝ≥0∞} {g : α → γ} {n : ℕ} (hf : Measurable f)
    (hg : Measurable g) : (eapprox (f ∘ g) n : α → ℝ≥0∞) = (eapprox f n : γ →ₛ ℝ≥0∞) ∘ g :=
  funext fun a => approx_comp a hf hg
#align measure_theory.simple_func.eapprox_comp MeasureTheory.SimpleFunc.eapprox_comp

/-- Approximate a function `α → ℝ≥0∞` by a series of simple functions taking their values
in `ℝ≥0`. -/
def eapproxDiff (f : α → ℝ≥0∞) : ∀ n : ℕ, α →ₛ ℝ≥0
  | 0 => (eapprox f 0).map Ennreal.toNnreal
  | n + 1 => (eapprox f (n + 1) - eapprox f n).map Ennreal.toNnreal
#align measure_theory.simple_func.eapprox_diff MeasureTheory.SimpleFunc.eapproxDiff

theorem sum_eapprox_diff (f : α → ℝ≥0∞) (n : ℕ) (a : α) :
    (∑ k in Finset.range (n + 1), (eapproxDiff f k a : ℝ≥0∞)) = eapprox f n a :=
  by
  induction' n with n IH
  · simp only [Nat.zero_eq, Finset.sum_singleton, Finset.range_one]
    rfl
  · rw [Finset.sum_range_succ, Nat.succ_eq_add_one, IH, eapprox_diff, coe_map, Function.comp_apply,
      coe_sub, Pi.sub_apply, Ennreal.coe_to_nnreal,
      add_tsub_cancel_of_le (monotone_eapprox f (Nat.le_succ _) _)]
    apply (lt_of_le_of_lt _ (eapprox_lt_top f (n + 1) a)).Ne
    rw [tsub_le_iff_right]
    exact le_self_add
#align measure_theory.simple_func.sum_eapprox_diff MeasureTheory.SimpleFunc.sum_eapprox_diff

theorem tsum_eapprox_diff (f : α → ℝ≥0∞) (hf : Measurable f) (a : α) :
    (∑' n, (eapproxDiff f n a : ℝ≥0∞)) = f a := by
  simp_rw [Ennreal.tsum_eq_supr_nat' (tendsto_add_at_top_nat 1), sum_eapprox_diff,
    supr_eapprox_apply f hf a]
#align measure_theory.simple_func.tsum_eapprox_diff MeasureTheory.SimpleFunc.tsum_eapprox_diff

end Eapprox

end Measurable

section Measure

variable {m : MeasurableSpace α} {μ ν : Measure α}

/-- Integral of a simple function whose codomain is `ℝ≥0∞`. -/
def lintegral {m : MeasurableSpace α} (f : α →ₛ ℝ≥0∞) (μ : Measure α) : ℝ≥0∞ :=
  ∑ x in f.range, x * μ (f ⁻¹' {x})
#align measure_theory.simple_func.lintegral MeasureTheory.SimpleFunc.lintegral

theorem lintegral_eq_of_subset (f : α →ₛ ℝ≥0∞) {s : Finset ℝ≥0∞}
    (hs : ∀ x, f x ≠ 0 → μ (f ⁻¹' {f x}) ≠ 0 → f x ∈ s) :
    f.lintegral μ = ∑ x in s, x * μ (f ⁻¹' {x}) :=
  by
  refine' Finset.sum_bij_ne_zero (fun r _ _ => r) _ _ _ _
  · simpa only [forall_range_iff, mul_ne_zero_iff, and_imp]
  · intros
    assumption
  · intro b _ hb
    refine' ⟨b, _, hb, rfl⟩
    rw [mem_range, ← preimage_singleton_nonempty]
    exact nonempty_of_measure_ne_zero (mul_ne_zero_iff.1 hb).2
  · intros
    rfl
#align
  measure_theory.simple_func.lintegral_eq_of_subset MeasureTheory.SimpleFunc.lintegral_eq_of_subset

theorem lintegral_eq_of_subset' (f : α →ₛ ℝ≥0∞) {s : Finset ℝ≥0∞} (hs : f.range \ {0} ⊆ s) :
    f.lintegral μ = ∑ x in s, x * μ (f ⁻¹' {x}) :=
  f.lintegral_eq_of_subset fun x hfx _ =>
    hs <| Finset.mem_sdiff.2 ⟨f.mem_range_self x, mt Finset.mem_singleton.1 hfx⟩
#align
  measure_theory.simple_func.lintegral_eq_of_subset' MeasureTheory.SimpleFunc.lintegral_eq_of_subset'

/-- Calculate the integral of `(g ∘ f)`, where `g : β → ℝ≥0∞` and `f : α →ₛ β`.  -/
theorem map_lintegral (g : β → ℝ≥0∞) (f : α →ₛ β) :
    (f.map g).lintegral μ = ∑ x in f.range, g x * μ (f ⁻¹' {x}) :=
  by
  simp only [lintegral, range_map]
  refine' Finset.sum_image' _ fun b hb => _
  rcases mem_range.1 hb with ⟨a, rfl⟩
  rw [map_preimage_singleton, ← f.sum_measure_preimage_singleton, Finset.mul_sum]
  refine' Finset.sum_congr _ _
  · congr
  · intro x
    simp only [Finset.mem_filter]
    rintro ⟨_, h⟩
    rw [h]
#align measure_theory.simple_func.map_lintegral MeasureTheory.SimpleFunc.map_lintegral

theorem add_lintegral (f g : α →ₛ ℝ≥0∞) : (f + g).lintegral μ = f.lintegral μ + g.lintegral μ :=
  calc
    (f + g).lintegral μ =
        ∑ x in (pair f g).range, x.1 * μ (pair f g ⁻¹' {x}) + x.2 * μ (pair f g ⁻¹' {x}) :=
      by rw [add_eq_map₂, map_lintegral] <;> exact Finset.sum_congr rfl fun a ha => add_mul _ _ _
    _ =
        (∑ x in (pair f g).range, x.1 * μ (pair f g ⁻¹' {x})) +
          ∑ x in (pair f g).range, x.2 * μ (pair f g ⁻¹' {x}) :=
      by rw [Finset.sum_add_distrib]
    _ = ((pair f g).map Prod.fst).lintegral μ + ((pair f g).map Prod.snd).lintegral μ := by
      rw [map_lintegral, map_lintegral]
    _ = lintegral f μ + lintegral g μ := rfl
    
#align measure_theory.simple_func.add_lintegral MeasureTheory.SimpleFunc.add_lintegral

theorem const_mul_lintegral (f : α →ₛ ℝ≥0∞) (x : ℝ≥0∞) :
    (const α x * f).lintegral μ = x * f.lintegral μ :=
  calc
    (f.map fun a => x * a).lintegral μ = ∑ r in f.range, x * r * μ (f ⁻¹' {r}) := map_lintegral _ _
    _ = ∑ r in f.range, x * (r * μ (f ⁻¹' {r})) := Finset.sum_congr rfl fun a ha => mul_assoc _ _ _
    _ = x * f.lintegral μ := Finset.mul_sum.symm
    
#align measure_theory.simple_func.const_mul_lintegral MeasureTheory.SimpleFunc.const_mul_lintegral

/-- Integral of a simple function `α →ₛ ℝ≥0∞` as a bilinear map. -/
def lintegralₗ {m : MeasurableSpace α} : (α →ₛ ℝ≥0∞) →ₗ[ℝ≥0∞] Measure α →ₗ[ℝ≥0∞] ℝ≥0∞
    where
  toFun f :=
    { toFun := lintegral f
      map_add' := by simp [lintegral, mul_add, Finset.sum_add_distrib]
      map_smul' := fun c μ => by simp [lintegral, mul_left_comm _ c, Finset.mul_sum] }
  map_add' f g := LinearMap.ext fun μ => add_lintegral f g
  map_smul' c f := LinearMap.ext fun μ => const_mul_lintegral f c
#align measure_theory.simple_func.lintegralₗ MeasureTheory.SimpleFunc.lintegralₗ

@[simp]
theorem zero_lintegral : (0 : α →ₛ ℝ≥0∞).lintegral μ = 0 :=
  LinearMap.ext_iff.1 lintegralₗ.map_zero μ
#align measure_theory.simple_func.zero_lintegral MeasureTheory.SimpleFunc.zero_lintegral

theorem lintegral_add {ν} (f : α →ₛ ℝ≥0∞) : f.lintegral (μ + ν) = f.lintegral μ + f.lintegral ν :=
  (lintegralₗ f).map_add μ ν
#align measure_theory.simple_func.lintegral_add MeasureTheory.SimpleFunc.lintegral_add

theorem lintegral_smul (f : α →ₛ ℝ≥0∞) (c : ℝ≥0∞) : f.lintegral (c • μ) = c • f.lintegral μ :=
  (lintegralₗ f).map_smul c μ
#align measure_theory.simple_func.lintegral_smul MeasureTheory.SimpleFunc.lintegral_smul

@[simp]
theorem lintegral_zero [MeasurableSpace α] (f : α →ₛ ℝ≥0∞) : f.lintegral 0 = 0 :=
  (lintegralₗ f).map_zero
#align measure_theory.simple_func.lintegral_zero MeasureTheory.SimpleFunc.lintegral_zero

theorem lintegral_sum {m : MeasurableSpace α} {ι} (f : α →ₛ ℝ≥0∞) (μ : ι → Measure α) :
    f.lintegral (Measure.sum μ) = ∑' i, f.lintegral (μ i) :=
  by
  simp only [lintegral, measure.sum_apply, f.measurable_set_preimage, ← Finset.tsum_subtype, ←
    Ennreal.tsum_mul_left]
  apply Ennreal.tsum_comm
#align measure_theory.simple_func.lintegral_sum MeasureTheory.SimpleFunc.lintegral_sum

theorem restrict_lintegral (f : α →ₛ ℝ≥0∞) {s : Set α} (hs : MeasurableSet s) :
    (restrict f s).lintegral μ = ∑ r in f.range, r * μ (f ⁻¹' {r} ∩ s) :=
  calc
    (restrict f s).lintegral μ = ∑ r in f.range, r * μ (restrict f s ⁻¹' {r}) :=
      (lintegral_eq_of_subset _) fun x hx =>
        if hxs : x ∈ s then fun _ => by
          simp only [f.restrict_apply hs, indicator_of_mem hxs, mem_range_self]
        else False.elim <| hx <| by simp [*]
    _ = ∑ r in f.range, r * μ (f ⁻¹' {r} ∩ s) :=
      Finset.sum_congr rfl <|
        forall_range_iff.2 fun b =>
          if hb : f b = 0 then by simp only [hb, zero_mul]
          else by rw [restrict_preimage_singleton _ hs hb, inter_comm]
    
#align measure_theory.simple_func.restrict_lintegral MeasureTheory.SimpleFunc.restrict_lintegral

theorem lintegral_restrict {m : MeasurableSpace α} (f : α →ₛ ℝ≥0∞) (s : Set α) (μ : Measure α) :
    f.lintegral (μ.restrict s) = ∑ y in f.range, y * μ (f ⁻¹' {y} ∩ s) := by
  simp only [lintegral, measure.restrict_apply, f.measurable_set_preimage]
#align measure_theory.simple_func.lintegral_restrict MeasureTheory.SimpleFunc.lintegral_restrict

theorem restrict_lintegral_eq_lintegral_restrict (f : α →ₛ ℝ≥0∞) {s : Set α}
    (hs : MeasurableSet s) : (restrict f s).lintegral μ = f.lintegral (μ.restrict s) := by
  rw [f.restrict_lintegral hs, lintegral_restrict]
#align
  measure_theory.simple_func.restrict_lintegral_eq_lintegral_restrict MeasureTheory.SimpleFunc.restrict_lintegral_eq_lintegral_restrict

theorem const_lintegral (c : ℝ≥0∞) : (const α c).lintegral μ = c * μ univ :=
  by
  rw [lintegral]
  cases isEmpty_or_nonempty α
  · simp [μ.eq_zero_of_is_empty]
  · simp [preimage_const_of_mem]
#align measure_theory.simple_func.const_lintegral MeasureTheory.SimpleFunc.const_lintegral

theorem const_lintegral_restrict (c : ℝ≥0∞) (s : Set α) :
    (const α c).lintegral (μ.restrict s) = c * μ s := by
  rw [const_lintegral, measure.restrict_apply MeasurableSet.univ, univ_inter]
#align
  measure_theory.simple_func.const_lintegral_restrict MeasureTheory.SimpleFunc.const_lintegral_restrict

theorem restrict_const_lintegral (c : ℝ≥0∞) {s : Set α} (hs : MeasurableSet s) :
    ((const α c).restrict s).lintegral μ = c * μ s := by
  rw [restrict_lintegral_eq_lintegral_restrict _ hs, const_lintegral_restrict]
#align
  measure_theory.simple_func.restrict_const_lintegral MeasureTheory.SimpleFunc.restrict_const_lintegral

theorem le_sup_lintegral (f g : α →ₛ ℝ≥0∞) : f.lintegral μ ⊔ g.lintegral μ ≤ (f ⊔ g).lintegral μ :=
  calc
    f.lintegral μ ⊔ g.lintegral μ =
        ((pair f g).map Prod.fst).lintegral μ ⊔ ((pair f g).map Prod.snd).lintegral μ :=
      rfl
    _ ≤ ∑ x in (pair f g).range, (x.1 ⊔ x.2) * μ (pair f g ⁻¹' {x}) :=
      by
      rw [map_lintegral, map_lintegral]
      refine' sup_le _ _ <;> refine' Finset.sum_le_sum fun a _ => mul_le_mul_right' _ _
      exact le_sup_left
      exact le_sup_right
    _ = (f ⊔ g).lintegral μ := by rw [sup_eq_map₂, map_lintegral]
    
#align measure_theory.simple_func.le_sup_lintegral MeasureTheory.SimpleFunc.le_sup_lintegral

/-- `simple_func.lintegral` is monotone both in function and in measure. -/
@[mono]
theorem lintegral_mono {f g : α →ₛ ℝ≥0∞} (hfg : f ≤ g) (hμν : μ ≤ ν) :
    f.lintegral μ ≤ g.lintegral ν :=
  calc
    f.lintegral μ ≤ f.lintegral μ ⊔ g.lintegral μ := le_sup_left
    _ ≤ (f ⊔ g).lintegral μ := le_sup_lintegral _ _
    _ = g.lintegral μ := by rw [sup_of_le_right hfg]
    _ ≤ g.lintegral ν :=
      Finset.sum_le_sum fun y hy => Ennreal.mul_left_mono <| hμν _ (g.measurable_set_preimage _)
    
#align measure_theory.simple_func.lintegral_mono MeasureTheory.SimpleFunc.lintegral_mono

/-- `simple_func.lintegral` depends only on the measures of `f ⁻¹' {y}`. -/
theorem lintegral_eq_of_measure_preimage [MeasurableSpace β] {f : α →ₛ ℝ≥0∞} {g : β →ₛ ℝ≥0∞}
    {ν : Measure β} (H : ∀ y, μ (f ⁻¹' {y}) = ν (g ⁻¹' {y})) : f.lintegral μ = g.lintegral ν :=
  by
  simp only [lintegral, ← H]
  apply lintegral_eq_of_subset
  simp only [H]
  intros
  exact mem_range_of_measure_ne_zero ‹_›
#align
  measure_theory.simple_func.lintegral_eq_of_measure_preimage MeasureTheory.SimpleFunc.lintegral_eq_of_measure_preimage

/-- If two simple functions are equal a.e., then their `lintegral`s are equal. -/
theorem lintegral_congr {f g : α →ₛ ℝ≥0∞} (h : f =ᵐ[μ] g) : f.lintegral μ = g.lintegral μ :=
  lintegral_eq_of_measure_preimage fun y =>
    measure_congr <| eventually.set_eq <| h.mono fun x hx => by simp [hx]
#align measure_theory.simple_func.lintegral_congr MeasureTheory.SimpleFunc.lintegral_congr

theorem lintegral_map' {β} [MeasurableSpace β] {μ' : Measure β} (f : α →ₛ ℝ≥0∞) (g : β →ₛ ℝ≥0∞)
    (m' : α → β) (eq : ∀ a, f a = g (m' a)) (h : ∀ s, MeasurableSet s → μ' s = μ (m' ⁻¹' s)) :
    f.lintegral μ = g.lintegral μ' :=
  lintegral_eq_of_measure_preimage fun y =>
    by
    simp only [preimage, Eq]
    exact (h (g ⁻¹' {y}) (g.measurable_set_preimage _)).symm
#align measure_theory.simple_func.lintegral_map' MeasureTheory.SimpleFunc.lintegral_map'

theorem lintegral_map {β} [MeasurableSpace β] (g : β →ₛ ℝ≥0∞) {f : α → β} (hf : Measurable f) :
    g.lintegral (Measure.map f μ) = (g.comp f hf).lintegral μ :=
  Eq.symm <| lintegral_map' _ _ f (fun a => rfl) fun s hs => Measure.map_apply hf hs
#align measure_theory.simple_func.lintegral_map MeasureTheory.SimpleFunc.lintegral_map

end Measure

section FinMeasSupp

open Finset Function

theorem support_eq [MeasurableSpace α] [Zero β] (f : α →ₛ β) :
    support f = ⋃ y ∈ f.range.filter fun y => y ≠ 0, f ⁻¹' {y} :=
  Set.ext fun x => by
    simp only [mem_support, Set.mem_preimage, mem_filter, mem_range_self, true_and_iff, exists_prop,
      mem_Union, Set.mem_range, mem_singleton_iff, exists_eq_right']
#align measure_theory.simple_func.support_eq MeasureTheory.SimpleFunc.support_eq

variable {m : MeasurableSpace α} [Zero β] [Zero γ] {μ : Measure α} {f : α →ₛ β}

theorem measurable_set_support [MeasurableSpace α] (f : α →ₛ β) : MeasurableSet (support f) :=
  by
  rw [f.support_eq]
  exact Finset.measurable_set_bUnion _ fun y hy => measurable_set_fiber _ _
#align
  measure_theory.simple_func.measurable_set_support MeasureTheory.SimpleFunc.measurable_set_support

/-- A `simple_func` has finite measure support if it is equal to `0` outside of a set of finite
measure. -/
protected def FinMeasSupp {m : MeasurableSpace α} (f : α →ₛ β) (μ : Measure α) : Prop :=
  f =ᶠ[μ.cofinite] 0
#align measure_theory.simple_func.fin_meas_supp MeasureTheory.SimpleFunc.FinMeasSupp

theorem fin_meas_supp_iff_support : f.FinMeasSupp μ ↔ μ (support f) < ∞ :=
  Iff.rfl
#align
  measure_theory.simple_func.fin_meas_supp_iff_support MeasureTheory.SimpleFunc.fin_meas_supp_iff_support

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (y «expr ≠ » 0) -/
theorem fin_meas_supp_iff : f.FinMeasSupp μ ↔ ∀ (y) (_ : y ≠ 0), μ (f ⁻¹' {y}) < ∞ :=
  by
  constructor
  · refine' fun h y hy => lt_of_le_of_lt (measure_mono _) h
    exact fun x hx (H : f x = 0) => hy <| H ▸ Eq.symm hx
  · intro H
    rw [fin_meas_supp_iff_support, support_eq]
    refine' lt_of_le_of_lt (measure_bUnion_finset_le _ _) (sum_lt_top _)
    exact fun y hy => (H y (Finset.mem_filter.1 hy).2).Ne
#align measure_theory.simple_func.fin_meas_supp_iff MeasureTheory.SimpleFunc.fin_meas_supp_iff

namespace FinMeasSupp

theorem meas_preimage_singleton_ne_zero (h : f.FinMeasSupp μ) {y : β} (hy : y ≠ 0) :
    μ (f ⁻¹' {y}) < ∞ :=
  fin_meas_supp_iff.1 h y hy
#align
  measure_theory.simple_func.fin_meas_supp.meas_preimage_singleton_ne_zero MeasureTheory.SimpleFunc.FinMeasSupp.meas_preimage_singleton_ne_zero

protected theorem map {g : β → γ} (hf : f.FinMeasSupp μ) (hg : g 0 = 0) : (f.map g).FinMeasSupp μ :=
  flip lt_of_le_of_lt hf (measure_mono <| support_comp_subset hg f)
#align measure_theory.simple_func.fin_meas_supp.map MeasureTheory.SimpleFunc.FinMeasSupp.map

theorem ofMap {g : β → γ} (h : (f.map g).FinMeasSupp μ) (hg : ∀ b, g b = 0 → b = 0) :
    f.FinMeasSupp μ :=
  flip lt_of_le_of_lt h <| measure_mono <| support_subset_comp hg _
#align measure_theory.simple_func.fin_meas_supp.of_map MeasureTheory.SimpleFunc.FinMeasSupp.ofMap

theorem map_iff {g : β → γ} (hg : ∀ {b}, g b = 0 ↔ b = 0) :
    (f.map g).FinMeasSupp μ ↔ f.FinMeasSupp μ :=
  ⟨fun h => h.of_map fun b => hg.1, fun h => h.map <| hg.2 rfl⟩
#align measure_theory.simple_func.fin_meas_supp.map_iff MeasureTheory.SimpleFunc.FinMeasSupp.map_iff

protected theorem pair {g : α →ₛ γ} (hf : f.FinMeasSupp μ) (hg : g.FinMeasSupp μ) :
    (pair f g).FinMeasSupp μ :=
  calc
    μ (support <| pair f g) = μ (support f ∪ support g) := congr_arg μ <| support_prod_mk f g
    _ ≤ μ (support f) + μ (support g) := measure_union_le _ _
    _ < _ := add_lt_top.2 ⟨hf, hg⟩
    
#align measure_theory.simple_func.fin_meas_supp.pair MeasureTheory.SimpleFunc.FinMeasSupp.pair

protected theorem map₂ [Zero δ] (hf : f.FinMeasSupp μ) {g : α →ₛ γ} (hg : g.FinMeasSupp μ)
    {op : β → γ → δ} (H : op 0 0 = 0) : ((pair f g).map (Function.uncurry op)).FinMeasSupp μ :=
  (hf.pair hg).map H
#align measure_theory.simple_func.fin_meas_supp.map₂ MeasureTheory.SimpleFunc.FinMeasSupp.map₂

protected theorem add {β} [AddMonoid β] {f g : α →ₛ β} (hf : f.FinMeasSupp μ)
    (hg : g.FinMeasSupp μ) : (f + g).FinMeasSupp μ :=
  by
  rw [add_eq_map₂]
  exact hf.map₂ hg (zero_add 0)
#align measure_theory.simple_func.fin_meas_supp.add MeasureTheory.SimpleFunc.FinMeasSupp.add

protected theorem mul {β} [MonoidWithZero β] {f g : α →ₛ β} (hf : f.FinMeasSupp μ)
    (hg : g.FinMeasSupp μ) : (f * g).FinMeasSupp μ :=
  by
  rw [mul_eq_map₂]
  exact hf.map₂ hg (zero_mul 0)
#align measure_theory.simple_func.fin_meas_supp.mul MeasureTheory.SimpleFunc.FinMeasSupp.mul

theorem lintegral_lt_top {f : α →ₛ ℝ≥0∞} (hm : f.FinMeasSupp μ) (hf : ∀ᵐ a ∂μ, f a ≠ ∞) :
    f.lintegral μ < ∞ := by
  refine' sum_lt_top fun a ha => _
  rcases eq_or_ne a ∞ with (rfl | ha)
  · simp only [ae_iff, Ne.def, not_not] at hf
    simp [Set.preimage, hf]
  · by_cases ha0 : a = 0
    · subst a
      rwa [zero_mul]
    · exact mul_ne_top ha (fin_meas_supp_iff.1 hm _ ha0).Ne
#align
  measure_theory.simple_func.fin_meas_supp.lintegral_lt_top MeasureTheory.SimpleFunc.FinMeasSupp.lintegral_lt_top

theorem ofLintegralNeTop {f : α →ₛ ℝ≥0∞} (h : f.lintegral μ ≠ ∞) : f.FinMeasSupp μ :=
  by
  refine' fin_meas_supp_iff.2 fun b hb => _
  rw [f.lintegral_eq_of_subset' (Finset.subset_insert b _)] at h
  refine' Ennreal.lt_top_of_mul_ne_top_right _ hb
  exact (lt_top_of_sum_ne_top h (Finset.mem_insert_self _ _)).Ne
#align
  measure_theory.simple_func.fin_meas_supp.of_lintegral_ne_top MeasureTheory.SimpleFunc.FinMeasSupp.ofLintegralNeTop

theorem iff_lintegral_lt_top {f : α →ₛ ℝ≥0∞} (hf : ∀ᵐ a ∂μ, f a ≠ ∞) :
    f.FinMeasSupp μ ↔ f.lintegral μ < ∞ :=
  ⟨fun h => h.lintegral_lt_top hf, fun h => ofLintegralNeTop h.Ne⟩
#align
  measure_theory.simple_func.fin_meas_supp.iff_lintegral_lt_top MeasureTheory.SimpleFunc.FinMeasSupp.iff_lintegral_lt_top

end FinMeasSupp

end FinMeasSupp

/-- To prove something for an arbitrary simple function, it suffices to show
that the property holds for (multiples of) characteristic functions and is closed under
addition (of functions with disjoint support).

It is possible to make the hypotheses in `h_add` a bit stronger, and such conditions can be added
once we need them (for example it is only necessary to consider the case where `g` is a multiple
of a characteristic function, and that this multiple doesn't appear in the image of `f`) -/
@[elab_as_elim]
protected theorem induction {α γ} [MeasurableSpace α] [AddMonoid γ] {P : SimpleFunc α γ → Prop}
    (h_ind :
      ∀ (c) {s} (hs : MeasurableSet s),
        P (SimpleFunc.piecewise s hs (SimpleFunc.const _ c) (SimpleFunc.const _ 0)))
    (h_add : ∀ ⦃f g : SimpleFunc α γ⦄, Disjoint (support f) (support g) → P f → P g → P (f + g))
    (f : SimpleFunc α γ) : P f :=
  by
  generalize h : f.range \ {0} = s
  rw [← Finset.coe_inj, Finset.coe_sdiff, Finset.coe_singleton, simple_func.coe_range] at h
  revert s f h; refine' Finset.induction _ _
  · intro f hf
    rw [Finset.coe_empty, diff_eq_empty, range_subset_singleton] at hf
    convert h_ind 0 MeasurableSet.univ
    ext x
    simp [hf]
  · intro x s hxs ih f hf
    have mx := f.measurable_set_preimage {x}
    let g := simple_func.piecewise (f ⁻¹' {x}) mx 0 f
    have Pg : P g := by
      apply ih
      simp only [g, simple_func.coe_piecewise, range_piecewise]
      rw [image_compl_preimage, union_diff_distrib, diff_diff_comm, hf, Finset.coe_insert,
        insert_diff_self_of_not_mem, diff_eq_empty.mpr, Set.empty_union]
      · rw [Set.image_subset_iff]
        convert Set.subset_univ _
        exact preimage_const_of_mem (mem_singleton _)
      · rwa [Finset.mem_coe]
    convert h_add _ Pg (h_ind x mx)
    · ext1 y
      by_cases hy : y ∈ f ⁻¹' {x} <;> [simpa [hy] , simp [hy]]
    rw [disjoint_iff_inf_le]
    rintro y
    by_cases hy : y ∈ f ⁻¹' {x} <;> simp [hy]
#align measure_theory.simple_func.induction MeasureTheory.SimpleFunc.induction

end SimpleFunc

section Lintegral

open SimpleFunc

variable {m : MeasurableSpace α} {μ ν : Measure α}

/-- The **lower Lebesgue integral** of a function `f` with respect to a measure `μ`. -/
irreducible_def lintegral {m : MeasurableSpace α} (μ : Measure α) (f : α → ℝ≥0∞) : ℝ≥0∞ :=
  ⨆ (g : α →ₛ ℝ≥0∞) (hf : ⇑g ≤ f), g.lintegral μ
#align measure_theory.lintegral MeasureTheory.lintegral

/-! In the notation for integrals, an expression like `∫⁻ x, g ‖x‖ ∂μ` will not be parsed correctly,
  and needs parentheses. We do not set the binding power of `r` to `0`, because then
  `∫⁻ x, f x = 0` will be parsed incorrectly. -/


-- mathport name: «expr∫⁻ , ∂ »
notation3"∫⁻ "(...)", "r:(scoped f => f)" ∂"μ => lintegral μ r

-- mathport name: «expr∫⁻ , »
notation3"∫⁻ "(...)", "r:(scoped f => lintegral volume f) => r

-- mathport name: «expr∫⁻ in , ∂ »
notation3"∫⁻ "(...)" in "s", "r:(scoped f => f)" ∂"μ => lintegral (Measure.restrict μ s) r

-- mathport name: «expr∫⁻ in , »
notation3"∫⁻ "(...)" in "s", "r:(scoped f => lintegral Measure.restrict volume s f) => r

theorem SimpleFunc.lintegral_eq_lintegral {m : MeasurableSpace α} (f : α →ₛ ℝ≥0∞) (μ : Measure α) :
    (∫⁻ a, f a ∂μ) = f.lintegral μ := by
  rw [lintegral]
  exact
    le_antisymm (supᵢ₂_le fun g hg => lintegral_mono hg <| le_rfl) (le_supᵢ₂_of_le f le_rfl le_rfl)
#align
  measure_theory.simple_func.lintegral_eq_lintegral MeasureTheory.SimpleFunc.lintegral_eq_lintegral

@[mono]
theorem lintegral_mono' {m : MeasurableSpace α} ⦃μ ν : Measure α⦄ (hμν : μ ≤ ν) ⦃f g : α → ℝ≥0∞⦄
    (hfg : f ≤ g) : (∫⁻ a, f a ∂μ) ≤ ∫⁻ a, g a ∂ν :=
  by
  rw [lintegral, lintegral]
  exact supᵢ_mono fun φ => supᵢ_mono' fun hφ => ⟨le_trans hφ hfg, lintegral_mono (le_refl φ) hμν⟩
#align measure_theory.lintegral_mono' MeasureTheory.lintegral_mono'

theorem lintegral_mono ⦃f g : α → ℝ≥0∞⦄ (hfg : f ≤ g) : (∫⁻ a, f a ∂μ) ≤ ∫⁻ a, g a ∂μ :=
  lintegral_mono' (le_refl μ) hfg
#align measure_theory.lintegral_mono MeasureTheory.lintegral_mono

theorem lintegral_mono_nnreal {f g : α → ℝ≥0} (h : f ≤ g) : (∫⁻ a, f a ∂μ) ≤ ∫⁻ a, g a ∂μ :=
  lintegral_mono fun a => Ennreal.coe_le_coe.2 (h a)
#align measure_theory.lintegral_mono_nnreal MeasureTheory.lintegral_mono_nnreal

theorem supr_lintegral_measurable_le_eq_lintegral (f : α → ℝ≥0∞) :
    (⨆ (g : α → ℝ≥0∞) (g_meas : Measurable g) (hg : g ≤ f), ∫⁻ a, g a ∂μ) = ∫⁻ a, f a ∂μ :=
  by
  apply le_antisymm
  · exact supᵢ_le fun i => supᵢ_le fun hi => supᵢ_le fun h'i => lintegral_mono h'i
  · rw [lintegral]
    refine' supᵢ₂_le fun i hi => le_supᵢ₂_of_le i i.Measurable <| le_supᵢ_of_le hi _
    exact le_of_eq (i.lintegral_eq_lintegral _).symm
#align
  measure_theory.supr_lintegral_measurable_le_eq_lintegral MeasureTheory.supr_lintegral_measurable_le_eq_lintegral

theorem lintegral_mono_set {m : MeasurableSpace α} ⦃μ : Measure α⦄ {s t : Set α} {f : α → ℝ≥0∞}
    (hst : s ⊆ t) : (∫⁻ x in s, f x ∂μ) ≤ ∫⁻ x in t, f x ∂μ :=
  lintegral_mono' (Measure.restrict_mono hst (le_refl μ)) (le_refl f)
#align measure_theory.lintegral_mono_set MeasureTheory.lintegral_mono_set

theorem lintegral_mono_set' {m : MeasurableSpace α} ⦃μ : Measure α⦄ {s t : Set α} {f : α → ℝ≥0∞}
    (hst : s ≤ᵐ[μ] t) : (∫⁻ x in s, f x ∂μ) ≤ ∫⁻ x in t, f x ∂μ :=
  lintegral_mono' (Measure.restrict_mono' hst (le_refl μ)) (le_refl f)
#align measure_theory.lintegral_mono_set' MeasureTheory.lintegral_mono_set'

theorem monotone_lintegral {m : MeasurableSpace α} (μ : Measure α) : Monotone (lintegral μ) :=
  lintegral_mono
#align measure_theory.monotone_lintegral MeasureTheory.monotone_lintegral

@[simp]
theorem lintegral_const (c : ℝ≥0∞) : (∫⁻ a, c ∂μ) = c * μ univ := by
  rw [← simple_func.const_lintegral, ← simple_func.lintegral_eq_lintegral, simple_func.coe_const]
#align measure_theory.lintegral_const MeasureTheory.lintegral_const

theorem lintegral_zero : (∫⁻ a : α, 0 ∂μ) = 0 := by simp
#align measure_theory.lintegral_zero MeasureTheory.lintegral_zero

theorem lintegral_zero_fun : lintegral μ (0 : α → ℝ≥0∞) = 0 :=
  lintegral_zero
#align measure_theory.lintegral_zero_fun MeasureTheory.lintegral_zero_fun

@[simp]
theorem lintegral_one : (∫⁻ a, (1 : ℝ≥0∞) ∂μ) = μ univ := by rw [lintegral_const, one_mul]
#align measure_theory.lintegral_one MeasureTheory.lintegral_one

theorem set_lintegral_const (s : Set α) (c : ℝ≥0∞) : (∫⁻ a in s, c ∂μ) = c * μ s := by
  rw [lintegral_const, measure.restrict_apply_univ]
#align measure_theory.set_lintegral_const MeasureTheory.set_lintegral_const

theorem set_lintegral_one (s) : (∫⁻ a in s, 1 ∂μ) = μ s := by rw [set_lintegral_const, one_mul]
#align measure_theory.set_lintegral_one MeasureTheory.set_lintegral_one

theorem set_lintegral_const_lt_top [IsFiniteMeasure μ] (s : Set α) {c : ℝ≥0∞} (hc : c ≠ ∞) :
    (∫⁻ a in s, c ∂μ) < ∞ := by
  rw [lintegral_const]
  exact Ennreal.mul_lt_top hc (measure_ne_top (μ.restrict s) univ)
#align measure_theory.set_lintegral_const_lt_top MeasureTheory.set_lintegral_const_lt_top

theorem lintegral_const_lt_top [IsFiniteMeasure μ] {c : ℝ≥0∞} (hc : c ≠ ∞) : (∫⁻ a, c ∂μ) < ∞ := by
  simpa only [measure.restrict_univ] using set_lintegral_const_lt_top univ hc
#align measure_theory.lintegral_const_lt_top MeasureTheory.lintegral_const_lt_top

section

variable (μ)

/-- For any function `f : α → ℝ≥0∞`, there exists a measurable function `g ≤ f` with the same
integral. -/
theorem exists_measurable_le_lintegral_eq (f : α → ℝ≥0∞) :
    ∃ g : α → ℝ≥0∞, Measurable g ∧ g ≤ f ∧ (∫⁻ a, f a ∂μ) = ∫⁻ a, g a ∂μ :=
  by
  cases' eq_or_ne (∫⁻ a, f a ∂μ) 0 with h₀ h₀
  · exact ⟨0, measurable_zero, zero_le f, h₀.trans lintegral_zero.symm⟩
  rcases exists_seq_strict_mono_tendsto' h₀.bot_lt with ⟨L, hL_mono, hLf, hL_tendsto⟩
  have : ∀ n, ∃ g : α → ℝ≥0∞, Measurable g ∧ g ≤ f ∧ L n < ∫⁻ a, g a ∂μ :=
    by
    intro n
    simpa only [← supr_lintegral_measurable_le_eq_lintegral f, lt_supᵢ_iff, exists_prop] using
      (hLf n).2
  choose g hgm hgf hLg
  refine'
    ⟨fun x => ⨆ n, g n x, measurable_supr hgm, fun x => supᵢ_le fun n => hgf n x, le_antisymm _ _⟩
  · refine' le_of_tendsto' hL_tendsto fun n => (hLg n).le.trans <| lintegral_mono fun x => _
    exact le_supᵢ (fun n => g n x) n
  · exact lintegral_mono fun x => supᵢ_le fun n => hgf n x
#align
  measure_theory.exists_measurable_le_lintegral_eq MeasureTheory.exists_measurable_le_lintegral_eq

end

/-- `∫⁻ a in s, f a ∂μ` is defined as the supremum of integrals of simple functions
`φ : α →ₛ ℝ≥0∞` such that `φ ≤ f`. This lemma says that it suffices to take
functions `φ : α →ₛ ℝ≥0`. -/
theorem lintegral_eq_nnreal {m : MeasurableSpace α} (f : α → ℝ≥0∞) (μ : Measure α) :
    (∫⁻ a, f a ∂μ) =
      ⨆ (φ : α →ₛ ℝ≥0) (hf : ∀ x, ↑(φ x) ≤ f x), (φ.map (coe : ℝ≥0 → ℝ≥0∞)).lintegral μ :=
  by
  rw [lintegral]
  refine'
    le_antisymm (supᵢ₂_le fun φ hφ => _) (supᵢ_mono' fun φ => ⟨φ.map (coe : ℝ≥0 → ℝ≥0∞), le_rfl⟩)
  by_cases h : ∀ᵐ a ∂μ, φ a ≠ ∞
  · let ψ := φ.map Ennreal.toNnreal
    replace h : ψ.map (coe : ℝ≥0 → ℝ≥0∞) =ᵐ[μ] φ := h.mono fun a => Ennreal.coe_to_nnreal
    have : ∀ x, ↑(ψ x) ≤ f x := fun x => le_trans Ennreal.coe_to_nnreal_le_self (hφ x)
    exact
      le_supᵢ_of_le (φ.map Ennreal.toNnreal) (le_supᵢ_of_le this (ge_of_eq <| lintegral_congr h))
  · have h_meas : μ (φ ⁻¹' {∞}) ≠ 0 := mt measure_zero_iff_ae_nmem.1 h
    refine' le_trans le_top (ge_of_eq <| (supᵢ_eq_top _).2 fun b hb => _)
    obtain ⟨n, hn⟩ : ∃ n : ℕ, b < n * μ (φ ⁻¹' {∞})
    exact exists_nat_mul_gt h_meas (ne_of_lt hb)
    use (const α (n : ℝ≥0)).restrict (φ ⁻¹' {∞})
    simp only [lt_supᵢ_iff, exists_prop, coe_restrict, φ.measurable_set_preimage, coe_const,
      Ennreal.coe_indicator, map_coe_ennreal_restrict, simple_func.map_const, Ennreal.coe_nat,
      restrict_const_lintegral]
    refine' ⟨indicator_le fun x hx => le_trans _ (hφ _), hn⟩
    simp only [mem_preimage, mem_singleton_iff] at hx
    simp only [hx, le_top]
#align measure_theory.lintegral_eq_nnreal MeasureTheory.lintegral_eq_nnreal

theorem exists_simple_func_forall_lintegral_sub_lt_of_pos {f : α → ℝ≥0∞} (h : (∫⁻ x, f x ∂μ) ≠ ∞)
    {ε : ℝ≥0∞} (hε : ε ≠ 0) :
    ∃ φ : α →ₛ ℝ≥0,
      (∀ x, ↑(φ x) ≤ f x) ∧
        ∀ ψ : α →ₛ ℝ≥0, (∀ x, ↑(ψ x) ≤ f x) → (map coe (ψ - φ)).lintegral μ < ε :=
  by
  rw [lintegral_eq_nnreal] at h
  have := Ennreal.lt_add_right h hε
  erw [Ennreal.bsupr_add] at this <;> [skip, exact ⟨0, fun x => zero_le _⟩]
  simp_rw [lt_supᵢ_iff, supᵢ_lt_iff, supᵢ_le_iff] at this
  rcases this with ⟨φ, hle : ∀ x, ↑(φ x) ≤ f x, b, hbφ, hb⟩
  refine' ⟨φ, hle, fun ψ hψ => _⟩
  have : (map coe φ).lintegral μ ≠ ∞ := ne_top_of_le_ne_top h (le_supᵢ₂ φ hle)
  rw [← Ennreal.add_lt_add_iff_left this, ← add_lintegral, ← map_add @Ennreal.coe_add]
  refine' (hb _ fun x => le_trans _ (max_le (hle x) (hψ x))).trans_lt hbφ
  norm_cast
  simp only [add_apply, sub_apply, add_tsub_eq_max]
#align
  measure_theory.exists_simple_func_forall_lintegral_sub_lt_of_pos MeasureTheory.exists_simple_func_forall_lintegral_sub_lt_of_pos

theorem supr_lintegral_le {ι : Sort _} (f : ι → α → ℝ≥0∞) :
    (⨆ i, ∫⁻ a, f i a ∂μ) ≤ ∫⁻ a, ⨆ i, f i a ∂μ :=
  by
  simp only [← supᵢ_apply]
  exact (monotone_lintegral μ).le_map_supr
#align measure_theory.supr_lintegral_le MeasureTheory.supr_lintegral_le

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
theorem supr₂_lintegral_le {ι : Sort _} {ι' : ι → Sort _} (f : ∀ i, ι' i → α → ℝ≥0∞) :
    (⨆ (i) (j), ∫⁻ a, f i j a ∂μ) ≤ ∫⁻ a, ⨆ (i) (j), f i j a ∂μ :=
  by
  convert (monotone_lintegral μ).le_map_supr₂ f
  ext1 a
  simp only [supᵢ_apply]
#align measure_theory.supr₂_lintegral_le MeasureTheory.supr₂_lintegral_le

theorem le_infi_lintegral {ι : Sort _} (f : ι → α → ℝ≥0∞) :
    (∫⁻ a, ⨅ i, f i a ∂μ) ≤ ⨅ i, ∫⁻ a, f i a ∂μ :=
  by
  simp only [← infᵢ_apply]
  exact (monotone_lintegral μ).map_infi_le
#align measure_theory.le_infi_lintegral MeasureTheory.le_infi_lintegral

theorem le_infi₂_lintegral {ι : Sort _} {ι' : ι → Sort _} (f : ∀ i, ι' i → α → ℝ≥0∞) :
    (∫⁻ a, ⨅ (i) (h : ι' i), f i h a ∂μ) ≤ ⨅ (i) (h : ι' i), ∫⁻ a, f i h a ∂μ :=
  by
  convert (monotone_lintegral μ).map_infi₂_le f
  ext1 a
  simp only [infᵢ_apply]
#align measure_theory.le_infi₂_lintegral MeasureTheory.le_infi₂_lintegral

theorem lintegral_mono_ae {f g : α → ℝ≥0∞} (h : ∀ᵐ a ∂μ, f a ≤ g a) :
    (∫⁻ a, f a ∂μ) ≤ ∫⁻ a, g a ∂μ :=
  by
  rcases exists_measurable_superset_of_null h with ⟨t, hts, ht, ht0⟩
  have : ∀ᵐ x ∂μ, x ∉ t := measure_zero_iff_ae_nmem.1 ht0
  rw [lintegral, lintegral]
  refine' supᵢ_le fun s => supᵢ_le fun hfs => le_supᵢ_of_le (s.restrict (tᶜ)) <| le_supᵢ_of_le _ _
  · intro a
    by_cases a ∈ t <;> simp [h, restrict_apply, ht.compl]
    exact le_trans (hfs a) (by_contradiction fun hnfg => h (hts hnfg))
  · refine' le_of_eq (simple_func.lintegral_congr <| this.mono fun a hnt => _)
    by_cases hat : a ∈ t <;> simp [hat, ht.compl]
    exact (hnt hat).elim
#align measure_theory.lintegral_mono_ae MeasureTheory.lintegral_mono_ae

theorem set_lintegral_mono_ae {s : Set α} {f g : α → ℝ≥0∞} (hf : Measurable f) (hg : Measurable g)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → f x ≤ g x) : (∫⁻ x in s, f x ∂μ) ≤ ∫⁻ x in s, g x ∂μ :=
  lintegral_mono_ae <| (ae_restrict_iff <| measurable_set_le hf hg).2 hfg
#align measure_theory.set_lintegral_mono_ae MeasureTheory.set_lintegral_mono_ae

theorem set_lintegral_mono {s : Set α} {f g : α → ℝ≥0∞} (hf : Measurable f) (hg : Measurable g)
    (hfg : ∀ x ∈ s, f x ≤ g x) : (∫⁻ x in s, f x ∂μ) ≤ ∫⁻ x in s, g x ∂μ :=
  set_lintegral_mono_ae hf hg (ae_of_all _ hfg)
#align measure_theory.set_lintegral_mono MeasureTheory.set_lintegral_mono

theorem lintegral_congr_ae {f g : α → ℝ≥0∞} (h : f =ᵐ[μ] g) : (∫⁻ a, f a ∂μ) = ∫⁻ a, g a ∂μ :=
  le_antisymm (lintegral_mono_ae <| h.le) (lintegral_mono_ae <| h.symm.le)
#align measure_theory.lintegral_congr_ae MeasureTheory.lintegral_congr_ae

theorem lintegral_congr {f g : α → ℝ≥0∞} (h : ∀ a, f a = g a) : (∫⁻ a, f a ∂μ) = ∫⁻ a, g a ∂μ := by
  simp only [h]
#align measure_theory.lintegral_congr MeasureTheory.lintegral_congr

theorem set_lintegral_congr {f : α → ℝ≥0∞} {s t : Set α} (h : s =ᵐ[μ] t) :
    (∫⁻ x in s, f x ∂μ) = ∫⁻ x in t, f x ∂μ := by rw [measure.restrict_congr_set h]
#align measure_theory.set_lintegral_congr MeasureTheory.set_lintegral_congr

theorem set_lintegral_congr_fun {f g : α → ℝ≥0∞} {s : Set α} (hs : MeasurableSet s)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → f x = g x) : (∫⁻ x in s, f x ∂μ) = ∫⁻ x in s, g x ∂μ :=
  by
  rw [lintegral_congr_ae]
  rw [eventually_eq]
  rwa [ae_restrict_iff' hs]
#align measure_theory.set_lintegral_congr_fun MeasureTheory.set_lintegral_congr_fun

theorem lintegral_of_real_le_lintegral_nnnorm (f : α → ℝ) :
    (∫⁻ x, Ennreal.ofReal (f x) ∂μ) ≤ ∫⁻ x, ‖f x‖₊ ∂μ :=
  by
  simp_rw [← of_real_norm_eq_coe_nnnorm]
  refine' lintegral_mono fun x => Ennreal.of_real_le_of_real _
  rw [Real.norm_eq_abs]
  exact le_abs_self (f x)
#align
  measure_theory.lintegral_of_real_le_lintegral_nnnorm MeasureTheory.lintegral_of_real_le_lintegral_nnnorm

theorem lintegral_nnnorm_eq_of_ae_nonneg {f : α → ℝ} (h_nonneg : 0 ≤ᵐ[μ] f) :
    (∫⁻ x, ‖f x‖₊ ∂μ) = ∫⁻ x, Ennreal.ofReal (f x) ∂μ :=
  by
  apply lintegral_congr_ae
  filter_upwards [h_nonneg] with x hx
  rw [Real.nnnorm_of_nonneg hx, Ennreal.of_real_eq_coe_nnreal hx]
#align
  measure_theory.lintegral_nnnorm_eq_of_ae_nonneg MeasureTheory.lintegral_nnnorm_eq_of_ae_nonneg

theorem lintegral_nnnorm_eq_of_nonneg {f : α → ℝ} (h_nonneg : 0 ≤ f) :
    (∫⁻ x, ‖f x‖₊ ∂μ) = ∫⁻ x, Ennreal.ofReal (f x) ∂μ :=
  lintegral_nnnorm_eq_of_ae_nonneg (Filter.eventually_of_forall h_nonneg)
#align measure_theory.lintegral_nnnorm_eq_of_nonneg MeasureTheory.lintegral_nnnorm_eq_of_nonneg

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:132:4: warning: unsupported: rw with cfg: { occs := occurrences.pos[occurrences.pos] «expr[ ,]»([1]) } -/
/-- Monotone convergence theorem -- sometimes called Beppo-Levi convergence.

See `lintegral_supr_directed` for a more general form. -/
theorem lintegral_supr {f : ℕ → α → ℝ≥0∞} (hf : ∀ n, Measurable (f n)) (h_mono : Monotone f) :
    (∫⁻ a, ⨆ n, f n a ∂μ) = ⨆ n, ∫⁻ a, f n a ∂μ :=
  by
  set c : ℝ≥0 → ℝ≥0∞ := coe
  set F := fun a : α => ⨆ n, f n a
  have hF : Measurable F := measurable_supr hf
  refine' le_antisymm _ (supr_lintegral_le _)
  rw [lintegral_eq_nnreal]
  refine' supᵢ_le fun s => supᵢ_le fun hsf => _
  refine' Ennreal.le_of_forall_lt_one_mul_le fun a ha => _
  rcases Ennreal.lt_iff_exists_coe.1 ha with ⟨r, rfl, ha⟩
  have ha : r < 1 := Ennreal.coe_lt_coe.1 ha
  let rs := s.map fun a => r * a
  have eq_rs : (const α r : α →ₛ ℝ≥0∞) * map c s = rs.map c :=
    by
    ext1 a
    exact ennreal.coe_mul.symm
  have eq : ∀ p, rs.map c ⁻¹' {p} = ⋃ n, rs.map c ⁻¹' {p} ∩ { a | p ≤ f n a } :=
    by
    intro p
    rw [← inter_Union, ← inter_univ (map c rs ⁻¹' {p})]
    refine' Set.ext fun x => and_congr_right fun hx => (true_iff_iff _).2 _
    by_cases p_eq : p = 0
    · simp [p_eq]
    simp at hx
    subst hx
    have : r * s x ≠ 0 := by rwa [(· ≠ ·), ← Ennreal.coe_eq_zero]
    have : s x ≠ 0 := by
      refine' mt _ this
      intro h
      rw [h, mul_zero]
    have : (rs.map c) x < ⨆ n : ℕ, f n x :=
      by
      refine' lt_of_lt_of_le (Ennreal.coe_lt_coe.2 _) (hsf x)
      suffices : r * s x < 1 * s x
      simpa [rs]
      exact mul_lt_mul_of_pos_right ha (pos_iff_ne_zero.2 this)
    rcases lt_supᵢ_iff.1 this with ⟨i, hi⟩
    exact mem_Union.2 ⟨i, le_of_lt hi⟩
  have mono : ∀ r : ℝ≥0∞, Monotone fun n => rs.map c ⁻¹' {r} ∩ { a | r ≤ f n a } :=
    by
    intro r i j h
    refine' inter_subset_inter (subset.refl _) _
    intro x hx
    exact le_trans hx (h_mono h x)
  have h_meas : ∀ n, MeasurableSet { a : α | (⇑(map c rs)) a ≤ f n a } := fun n =>
    measurable_set_le (simple_func.measurable _) (hf n)
  calc
    (r : ℝ≥0∞) * (s.map c).lintegral μ = ∑ r in (rs.map c).range, r * μ (rs.map c ⁻¹' {r}) := by
      rw [← const_mul_lintegral, eq_rs, simple_func.lintegral]
    _ = ∑ r in (rs.map c).range, r * μ (⋃ n, rs.map c ⁻¹' {r} ∩ { a | r ≤ f n a }) := by
      simp only [(Eq _).symm]
    _ = ∑ r in (rs.map c).range, ⨆ n, r * μ (rs.map c ⁻¹' {r} ∩ { a | r ≤ f n a }) :=
      (Finset.sum_congr rfl) fun x hx => by
        rw [measure_Union_eq_supr (directed_of_sup <| mono x), Ennreal.mul_supr]
    _ = ⨆ n, ∑ r in (rs.map c).range, r * μ (rs.map c ⁻¹' {r} ∩ { a | r ≤ f n a }) :=
      by
      rw [Ennreal.finset_sum_supr_nat]
      intro p i j h
      exact mul_le_mul_left' (measure_mono <| mono p h) _
    _ ≤ ⨆ n : ℕ, ((rs.map c).restrict { a | (rs.map c) a ≤ f n a }).lintegral μ :=
      by
      refine' supᵢ_mono fun n => _
      rw [restrict_lintegral _ (h_meas n)]
      · refine' le_of_eq ((Finset.sum_congr rfl) fun r hr => _)
        congr 2 with a
        refine' and_congr_right _
        simp (config := { contextual := true })
    _ ≤ ⨆ n, ∫⁻ a, f n a ∂μ := by
      refine' supᵢ_mono fun n => _
      rw [← simple_func.lintegral_eq_lintegral]
      refine' lintegral_mono fun a => _
      simp only [map_apply] at h_meas
      simp only [coe_map, restrict_apply _ (h_meas _), (· ∘ ·)]
      exact indicator_apply_le id
    
#align measure_theory.lintegral_supr MeasureTheory.lintegral_supr

/-- Monotone convergence theorem -- sometimes called Beppo-Levi convergence. Version with
ae_measurable functions. -/
theorem lintegral_supr' {f : ℕ → α → ℝ≥0∞} (hf : ∀ n, AeMeasurable (f n) μ)
    (h_mono : ∀ᵐ x ∂μ, Monotone fun n => f n x) : (∫⁻ a, ⨆ n, f n a ∂μ) = ⨆ n, ∫⁻ a, f n a ∂μ :=
  by
  simp_rw [← supᵢ_apply]
  let p : α → (ℕ → ℝ≥0∞) → Prop := fun x f' => Monotone f'
  have hp : ∀ᵐ x ∂μ, p x fun i => f i x := h_mono
  have h_ae_seq_mono : Monotone (aeSeq hf p) :=
    by
    intro n m hnm x
    by_cases hx : x ∈ aeSeqSet hf p
    · exact aeSeq.propOfMemAeSeqSet hf hx hnm
    · simp only [aeSeq, hx, if_false]
      exact le_rfl
  rw [lintegral_congr_ae (aeSeq.supr hf hp).symm]
  simp_rw [supᵢ_apply]
  rw [@lintegral_supr _ _ μ _ (aeSeq.measurable hf p) h_ae_seq_mono]
  congr
  exact funext fun n => lintegral_congr_ae (aeSeq.ae_seq_n_eq_fun_n_ae hf hp n)
#align measure_theory.lintegral_supr' MeasureTheory.lintegral_supr'

/-- Monotone convergence theorem expressed with limits -/
theorem lintegral_tendsto_of_tendsto_of_monotone {f : ℕ → α → ℝ≥0∞} {F : α → ℝ≥0∞}
    (hf : ∀ n, AeMeasurable (f n) μ) (h_mono : ∀ᵐ x ∂μ, Monotone fun n => f n x)
    (h_tendsto : ∀ᵐ x ∂μ, Tendsto (fun n => f n x) atTop (𝓝 <| F x)) :
    Tendsto (fun n => ∫⁻ x, f n x ∂μ) atTop (𝓝 <| ∫⁻ x, F x ∂μ) :=
  by
  have : Monotone fun n => ∫⁻ x, f n x ∂μ := fun i j hij =>
    lintegral_mono_ae (h_mono.mono fun x hx => hx hij)
  suffices key : (∫⁻ x, F x ∂μ) = ⨆ n, ∫⁻ x, f n x ∂μ
  · rw [key]
    exact tendsto_at_top_supr this
  rw [← lintegral_supr' hf h_mono]
  refine' lintegral_congr_ae _
  filter_upwards [h_mono,
    h_tendsto] with _ hx_mono hx_tendsto using tendsto_nhds_unique hx_tendsto
      (tendsto_at_top_supr hx_mono)
#align
  measure_theory.lintegral_tendsto_of_tendsto_of_monotone MeasureTheory.lintegral_tendsto_of_tendsto_of_monotone

theorem lintegral_eq_supr_eapprox_lintegral {f : α → ℝ≥0∞} (hf : Measurable f) :
    (∫⁻ a, f a ∂μ) = ⨆ n, (eapprox f n).lintegral μ :=
  calc
    (∫⁻ a, f a ∂μ) = ∫⁻ a, ⨆ n, (eapprox f n : α → ℝ≥0∞) a ∂μ := by
      congr <;> ext a <;> rw [supr_eapprox_apply f hf]
    _ = ⨆ n, ∫⁻ a, (eapprox f n : α → ℝ≥0∞) a ∂μ :=
      by
      rw [lintegral_supr]
      · measurability
      · intro i j h
        exact monotone_eapprox f h
    _ = ⨆ n, (eapprox f n).lintegral μ := by
      congr <;> ext n <;> rw [(eapprox f n).lintegral_eq_lintegral]
    
#align
  measure_theory.lintegral_eq_supr_eapprox_lintegral MeasureTheory.lintegral_eq_supr_eapprox_lintegral

/-- If `f` has finite integral, then `∫⁻ x in s, f x ∂μ` is absolutely continuous in `s`: it tends
to zero as `μ s` tends to zero. This lemma states states this fact in terms of `ε` and `δ`. -/
theorem exists_pos_set_lintegral_lt_of_measure_lt {f : α → ℝ≥0∞} (h : (∫⁻ x, f x ∂μ) ≠ ∞) {ε : ℝ≥0∞}
    (hε : ε ≠ 0) : ∃ δ > 0, ∀ s, μ s < δ → (∫⁻ x in s, f x ∂μ) < ε :=
  by
  rcases exists_between hε.bot_lt with ⟨ε₂, hε₂0 : 0 < ε₂, hε₂ε⟩
  rcases exists_between hε₂0 with ⟨ε₁, hε₁0, hε₁₂⟩
  rcases exists_simple_func_forall_lintegral_sub_lt_of_pos h hε₁0.ne' with ⟨φ, hle, hφ⟩
  rcases φ.exists_forall_le with ⟨C, hC⟩
  use (ε₂ - ε₁) / C, Ennreal.div_pos_iff.2 ⟨(tsub_pos_iff_lt.2 hε₁₂).ne', Ennreal.coe_ne_top⟩
  refine' fun s hs => lt_of_le_of_lt _ hε₂ε
  simp only [lintegral_eq_nnreal, supᵢ_le_iff]
  intro ψ hψ
  calc
    (map coe ψ).lintegral (μ.restrict s) ≤
        (map coe φ).lintegral (μ.restrict s) + (map coe (ψ - φ)).lintegral (μ.restrict s) :=
      by
      rw [← simple_func.add_lintegral, ← simple_func.map_add @Ennreal.coe_add]
      refine' simple_func.lintegral_mono (fun x => _) le_rfl
      simp only [add_tsub_eq_max, le_max_right, coe_map, Function.comp_apply, simple_func.coe_add,
        simple_func.coe_sub, Pi.add_apply, Pi.sub_apply, WithTop.coe_max]
    _ ≤ (map coe φ).lintegral (μ.restrict s) + ε₁ :=
      by
      refine' add_le_add le_rfl (le_trans _ (hφ _ hψ).le)
      exact simple_func.lintegral_mono le_rfl measure.restrict_le_self
    _ ≤ (simple_func.const α (C : ℝ≥0∞)).lintegral (μ.restrict s) + ε₁ :=
      add_le_add (simple_func.lintegral_mono (fun x => coe_le_coe.2 (hC x)) le_rfl) le_rfl
    _ = C * μ s + ε₁ := by
      simp only [← simple_func.lintegral_eq_lintegral, coe_const, lintegral_const,
        measure.restrict_apply, MeasurableSet.univ, univ_inter]
    _ ≤ C * ((ε₂ - ε₁) / C) + ε₁ := add_le_add_right (Ennreal.mul_le_mul le_rfl hs.le) _
    _ ≤ ε₂ - ε₁ + ε₁ := add_le_add mul_div_le le_rfl
    _ = ε₂ := tsub_add_cancel_of_le hε₁₂.le
    
#align
  measure_theory.exists_pos_set_lintegral_lt_of_measure_lt MeasureTheory.exists_pos_set_lintegral_lt_of_measure_lt

/-- If `f` has finite integral, then `∫⁻ x in s, f x ∂μ` is absolutely continuous in `s`: it tends
to zero as `μ s` tends to zero. -/
theorem tendsto_set_lintegral_zero {ι} {f : α → ℝ≥0∞} (h : (∫⁻ x, f x ∂μ) ≠ ∞) {l : Filter ι}
    {s : ι → Set α} (hl : Tendsto (μ ∘ s) l (𝓝 0)) :
    Tendsto (fun i => ∫⁻ x in s i, f x ∂μ) l (𝓝 0) :=
  by
  simp only [Ennreal.nhds_zero, tendsto_infi, tendsto_principal, mem_Iio, ← pos_iff_ne_zero] at hl⊢
  intro ε ε0
  rcases exists_pos_set_lintegral_lt_of_measure_lt h ε0.ne' with ⟨δ, δ0, hδ⟩
  exact (hl δ δ0).mono fun i => hδ _
#align measure_theory.tendsto_set_lintegral_zero MeasureTheory.tendsto_set_lintegral_zero

/-- The sum of the lower Lebesgue integrals of two functions is less than or equal to the integral
of their sum. The other inequality needs one of these functions to be (a.e.-)measurable. -/
theorem le_lintegral_add (f g : α → ℝ≥0∞) : ((∫⁻ a, f a ∂μ) + ∫⁻ a, g a ∂μ) ≤ ∫⁻ a, f a + g a ∂μ :=
  by
  dsimp only [lintegral]
  refine' Ennreal.bsupr_add_bsupr_le' ⟨0, zero_le f⟩ ⟨0, zero_le g⟩ fun f' hf' g' hg' => _
  exact le_supᵢ₂_of_le (f' + g') (add_le_add hf' hg') (add_lintegral _ _).ge
#align measure_theory.le_lintegral_add MeasureTheory.le_lintegral_add

-- Use stronger lemmas `lintegral_add_left`/`lintegral_add_right` instead
theorem lintegral_add_aux {f g : α → ℝ≥0∞} (hf : Measurable f) (hg : Measurable g) :
    (∫⁻ a, f a + g a ∂μ) = (∫⁻ a, f a ∂μ) + ∫⁻ a, g a ∂μ :=
  calc
    (∫⁻ a, f a + g a ∂μ) =
        ∫⁻ a, (⨆ n, (eapprox f n : α → ℝ≥0∞) a) + ⨆ n, (eapprox g n : α → ℝ≥0∞) a ∂μ :=
      by simp only [supr_eapprox_apply, hf, hg]
    _ = ∫⁻ a, ⨆ n, (eapprox f n + eapprox g n : α → ℝ≥0∞) a ∂μ :=
      by
      congr ; funext a
      rw [Ennreal.supr_add_supr_of_monotone]; · rfl
      · intro i j h
        exact monotone_eapprox _ h a
      · intro i j h
        exact monotone_eapprox _ h a
    _ = ⨆ n, (eapprox f n).lintegral μ + (eapprox g n).lintegral μ :=
      by
      rw [lintegral_supr]
      · congr
        funext n
        rw [← simple_func.add_lintegral, ← simple_func.lintegral_eq_lintegral]
        rfl
      · measurability
      · intro i j h a
        exact add_le_add (monotone_eapprox _ h _) (monotone_eapprox _ h _)
    _ = (⨆ n, (eapprox f n).lintegral μ) + ⨆ n, (eapprox g n).lintegral μ := by
      refine' (Ennreal.supr_add_supr_of_monotone _ _).symm <;>
        · intro i j h
          exact simple_func.lintegral_mono (monotone_eapprox _ h) (le_refl μ)
    _ = (∫⁻ a, f a ∂μ) + ∫⁻ a, g a ∂μ := by
      rw [lintegral_eq_supr_eapprox_lintegral hf, lintegral_eq_supr_eapprox_lintegral hg]
    
#align measure_theory.lintegral_add_aux MeasureTheory.lintegral_add_aux

/-- If `f g : α → ℝ≥0∞` are two functions and one of them is (a.e.) measurable, then the Lebesgue
integral of `f + g` equals the sum of integrals. This lemma assumes that `f` is integrable, see also
`measure_theory.lintegral_add_right` and primed versions of these lemmas. -/
@[simp]
theorem lintegral_add_left {f : α → ℝ≥0∞} (hf : Measurable f) (g : α → ℝ≥0∞) :
    (∫⁻ a, f a + g a ∂μ) = (∫⁻ a, f a ∂μ) + ∫⁻ a, g a ∂μ :=
  by
  refine' le_antisymm _ (le_lintegral_add _ _)
  rcases exists_measurable_le_lintegral_eq μ fun a => f a + g a with ⟨φ, hφm, hφ_le, hφ_eq⟩
  calc
    (∫⁻ a, f a + g a ∂μ) = ∫⁻ a, φ a ∂μ := hφ_eq
    _ ≤ ∫⁻ a, f a + (φ a - f a) ∂μ := lintegral_mono fun a => le_add_tsub
    _ = (∫⁻ a, f a ∂μ) + ∫⁻ a, φ a - f a ∂μ := lintegral_add_aux hf (hφm.sub hf)
    _ ≤ (∫⁻ a, f a ∂μ) + ∫⁻ a, g a ∂μ :=
      add_le_add_left (lintegral_mono fun a => tsub_le_iff_left.2 <| hφ_le a) _
    
#align measure_theory.lintegral_add_left MeasureTheory.lintegral_add_left

theorem lintegral_add_left' {f : α → ℝ≥0∞} (hf : AeMeasurable f μ) (g : α → ℝ≥0∞) :
    (∫⁻ a, f a + g a ∂μ) = (∫⁻ a, f a ∂μ) + ∫⁻ a, g a ∂μ := by
  rw [lintegral_congr_ae hf.ae_eq_mk, ← lintegral_add_left hf.measurable_mk,
    lintegral_congr_ae (hf.ae_eq_mk.add (ae_eq_refl g))]
#align measure_theory.lintegral_add_left' MeasureTheory.lintegral_add_left'

theorem lintegral_add_right' (f : α → ℝ≥0∞) {g : α → ℝ≥0∞} (hg : AeMeasurable g μ) :
    (∫⁻ a, f a + g a ∂μ) = (∫⁻ a, f a ∂μ) + ∫⁻ a, g a ∂μ := by
  simpa only [add_comm] using lintegral_add_left' hg f
#align measure_theory.lintegral_add_right' MeasureTheory.lintegral_add_right'

/-- If `f g : α → ℝ≥0∞` are two functions and one of them is (a.e.) measurable, then the Lebesgue
integral of `f + g` equals the sum of integrals. This lemma assumes that `g` is integrable, see also
`measure_theory.lintegral_add_left` and primed versions of these lemmas. -/
@[simp]
theorem lintegral_add_right (f : α → ℝ≥0∞) {g : α → ℝ≥0∞} (hg : Measurable g) :
    (∫⁻ a, f a + g a ∂μ) = (∫⁻ a, f a ∂μ) + ∫⁻ a, g a ∂μ :=
  lintegral_add_right' f hg.AeMeasurable
#align measure_theory.lintegral_add_right MeasureTheory.lintegral_add_right

@[simp]
theorem lintegral_smul_measure (c : ℝ≥0∞) (f : α → ℝ≥0∞) : (∫⁻ a, f a ∂c • μ) = c * ∫⁻ a, f a ∂μ :=
  by simp only [lintegral, supᵢ_subtype', simple_func.lintegral_smul, Ennreal.mul_supr, smul_eq_mul]
#align measure_theory.lintegral_smul_measure MeasureTheory.lintegral_smul_measure

@[simp]
theorem lintegral_sum_measure {m : MeasurableSpace α} {ι} (f : α → ℝ≥0∞) (μ : ι → Measure α) :
    (∫⁻ a, f a ∂Measure.sum μ) = ∑' i, ∫⁻ a, f a ∂μ i :=
  by
  simp only [lintegral, supᵢ_subtype', simple_func.lintegral_sum, Ennreal.tsum_eq_supr_sum]
  rw [supᵢ_comm]
  congr ; funext s
  induction' s using Finset.induction_on with i s hi hs;
  · apply bot_unique
    simp
  simp only [Finset.sum_insert hi, ← hs]
  refine' (Ennreal.supr_add_supr _).symm
  intro φ ψ
  exact
    ⟨⟨φ ⊔ ψ, fun x => sup_le (φ.2 x) (ψ.2 x)⟩,
      add_le_add (simple_func.lintegral_mono le_sup_left le_rfl)
        (Finset.sum_le_sum fun j hj => simple_func.lintegral_mono le_sup_right le_rfl)⟩
#align measure_theory.lintegral_sum_measure MeasureTheory.lintegral_sum_measure

theorem has_sum_lintegral_measure {ι} {m : MeasurableSpace α} (f : α → ℝ≥0∞) (μ : ι → Measure α) :
    HasSum (fun i => ∫⁻ a, f a ∂μ i) (∫⁻ a, f a ∂Measure.sum μ) :=
  (lintegral_sum_measure f μ).symm ▸ Ennreal.summable.HasSum
#align measure_theory.has_sum_lintegral_measure MeasureTheory.has_sum_lintegral_measure

@[simp]
theorem lintegral_add_measure {m : MeasurableSpace α} (f : α → ℝ≥0∞) (μ ν : Measure α) :
    (∫⁻ a, f a ∂μ + ν) = (∫⁻ a, f a ∂μ) + ∫⁻ a, f a ∂ν := by
  simpa [tsum_fintype] using lintegral_sum_measure f fun b => cond b μ ν
#align measure_theory.lintegral_add_measure MeasureTheory.lintegral_add_measure

@[simp]
theorem lintegral_finset_sum_measure {ι} {m : MeasurableSpace α} (s : Finset ι) (f : α → ℝ≥0∞)
    (μ : ι → Measure α) : (∫⁻ a, f a ∂∑ i in s, μ i) = ∑ i in s, ∫⁻ a, f a ∂μ i :=
  by
  rw [← measure.sum_coe_finset, lintegral_sum_measure, ← Finset.tsum_subtype']
  rfl
#align measure_theory.lintegral_finset_sum_measure MeasureTheory.lintegral_finset_sum_measure

@[simp]
theorem lintegral_zero_measure {m : MeasurableSpace α} (f : α → ℝ≥0∞) :
    (∫⁻ a, f a ∂(0 : Measure α)) = 0 :=
  bot_unique <| by simp [lintegral]
#align measure_theory.lintegral_zero_measure MeasureTheory.lintegral_zero_measure

theorem set_lintegral_empty (f : α → ℝ≥0∞) : (∫⁻ x in ∅, f x ∂μ) = 0 := by
  rw [measure.restrict_empty, lintegral_zero_measure]
#align measure_theory.set_lintegral_empty MeasureTheory.set_lintegral_empty

theorem set_lintegral_univ (f : α → ℝ≥0∞) : (∫⁻ x in univ, f x ∂μ) = ∫⁻ x, f x ∂μ := by
  rw [measure.restrict_univ]
#align measure_theory.set_lintegral_univ MeasureTheory.set_lintegral_univ

theorem set_lintegral_measure_zero (s : Set α) (f : α → ℝ≥0∞) (hs' : μ s = 0) :
    (∫⁻ x in s, f x ∂μ) = 0 := by
  convert lintegral_zero_measure _
  exact measure.restrict_eq_zero.2 hs'
#align measure_theory.set_lintegral_measure_zero MeasureTheory.set_lintegral_measure_zero

theorem lintegral_finset_sum' (s : Finset β) {f : β → α → ℝ≥0∞}
    (hf : ∀ b ∈ s, AeMeasurable (f b) μ) : (∫⁻ a, ∑ b in s, f b a ∂μ) = ∑ b in s, ∫⁻ a, f b a ∂μ :=
  by
  induction' s using Finset.induction_on with a s has ih
  · simp
  · simp only [Finset.sum_insert has]
    rw [Finset.forall_mem_insert] at hf
    rw [lintegral_add_left' hf.1, ih hf.2]
#align measure_theory.lintegral_finset_sum' MeasureTheory.lintegral_finset_sum'

theorem lintegral_finset_sum (s : Finset β) {f : β → α → ℝ≥0∞} (hf : ∀ b ∈ s, Measurable (f b)) :
    (∫⁻ a, ∑ b in s, f b a ∂μ) = ∑ b in s, ∫⁻ a, f b a ∂μ :=
  lintegral_finset_sum' s fun b hb => (hf b hb).AeMeasurable
#align measure_theory.lintegral_finset_sum MeasureTheory.lintegral_finset_sum

@[simp]
theorem lintegral_const_mul (r : ℝ≥0∞) {f : α → ℝ≥0∞} (hf : Measurable f) :
    (∫⁻ a, r * f a ∂μ) = r * ∫⁻ a, f a ∂μ :=
  calc
    (∫⁻ a, r * f a ∂μ) = ∫⁻ a, ⨆ n, (const α r * eapprox f n) a ∂μ :=
      by
      congr
      funext a
      rw [← supr_eapprox_apply f hf, Ennreal.mul_supr]
      rfl
    _ = ⨆ n, r * (eapprox f n).lintegral μ :=
      by
      rw [lintegral_supr]
      · congr
        funext n
        rw [← simple_func.const_mul_lintegral, ← simple_func.lintegral_eq_lintegral]
      · intro n
        exact simple_func.measurable _
      · intro i j h a
        exact mul_le_mul_left' (monotone_eapprox _ h _) _
    _ = r * ∫⁻ a, f a ∂μ := by rw [← Ennreal.mul_supr, lintegral_eq_supr_eapprox_lintegral hf]
    
#align measure_theory.lintegral_const_mul MeasureTheory.lintegral_const_mul

theorem lintegral_const_mul'' (r : ℝ≥0∞) {f : α → ℝ≥0∞} (hf : AeMeasurable f μ) :
    (∫⁻ a, r * f a ∂μ) = r * ∫⁻ a, f a ∂μ :=
  by
  have A : (∫⁻ a, f a ∂μ) = ∫⁻ a, hf.mk f a ∂μ := lintegral_congr_ae hf.ae_eq_mk
  have B : (∫⁻ a, r * f a ∂μ) = ∫⁻ a, r * hf.mk f a ∂μ :=
    lintegral_congr_ae (eventually_eq.fun_comp hf.ae_eq_mk _)
  rw [A, B, lintegral_const_mul _ hf.measurable_mk]
#align measure_theory.lintegral_const_mul'' MeasureTheory.lintegral_const_mul''

theorem lintegral_const_mul_le (r : ℝ≥0∞) (f : α → ℝ≥0∞) : (r * ∫⁻ a, f a ∂μ) ≤ ∫⁻ a, r * f a ∂μ :=
  by
  rw [lintegral, Ennreal.mul_supr]
  refine' supᵢ_le fun s => _
  rw [Ennreal.mul_supr]
  simp only [supᵢ_le_iff]
  intro hs
  rw [← simple_func.const_mul_lintegral, lintegral]
  refine' le_supᵢ_of_le (const α r * s) (le_supᵢ_of_le (fun x => _) le_rfl)
  exact mul_le_mul_left' (hs x) _
#align measure_theory.lintegral_const_mul_le MeasureTheory.lintegral_const_mul_le

theorem lintegral_const_mul' (r : ℝ≥0∞) (f : α → ℝ≥0∞) (hr : r ≠ ∞) :
    (∫⁻ a, r * f a ∂μ) = r * ∫⁻ a, f a ∂μ :=
  by
  by_cases h : r = 0
  · simp [h]
  apply le_antisymm _ (lintegral_const_mul_le r f)
  have rinv : r * r⁻¹ = 1 := Ennreal.mul_inv_cancel h hr
  have rinv' : r⁻¹ * r = 1 := by
    rw [mul_comm]
    exact rinv
  have := lintegral_const_mul_le r⁻¹ fun x => r * f x
  simp [(mul_assoc _ _ _).symm, rinv'] at this
  simpa [(mul_assoc _ _ _).symm, rinv] using mul_le_mul_left' this r
#align measure_theory.lintegral_const_mul' MeasureTheory.lintegral_const_mul'

theorem lintegral_mul_const (r : ℝ≥0∞) {f : α → ℝ≥0∞} (hf : Measurable f) :
    (∫⁻ a, f a * r ∂μ) = (∫⁻ a, f a ∂μ) * r := by simp_rw [mul_comm, lintegral_const_mul r hf]
#align measure_theory.lintegral_mul_const MeasureTheory.lintegral_mul_const

theorem lintegral_mul_const'' (r : ℝ≥0∞) {f : α → ℝ≥0∞} (hf : AeMeasurable f μ) :
    (∫⁻ a, f a * r ∂μ) = (∫⁻ a, f a ∂μ) * r := by simp_rw [mul_comm, lintegral_const_mul'' r hf]
#align measure_theory.lintegral_mul_const'' MeasureTheory.lintegral_mul_const''

theorem lintegral_mul_const_le (r : ℝ≥0∞) (f : α → ℝ≥0∞) : (∫⁻ a, f a ∂μ) * r ≤ ∫⁻ a, f a * r ∂μ :=
  by simp_rw [mul_comm, lintegral_const_mul_le r f]
#align measure_theory.lintegral_mul_const_le MeasureTheory.lintegral_mul_const_le

theorem lintegral_mul_const' (r : ℝ≥0∞) (f : α → ℝ≥0∞) (hr : r ≠ ∞) :
    (∫⁻ a, f a * r ∂μ) = (∫⁻ a, f a ∂μ) * r := by simp_rw [mul_comm, lintegral_const_mul' r f hr]
#align measure_theory.lintegral_mul_const' MeasureTheory.lintegral_mul_const'

/- A double integral of a product where each factor contains only one variable
  is a product of integrals -/
theorem lintegral_lintegral_mul {β} [MeasurableSpace β] {ν : Measure β} {f : α → ℝ≥0∞}
    {g : β → ℝ≥0∞} (hf : AeMeasurable f μ) (hg : AeMeasurable g ν) :
    (∫⁻ x, ∫⁻ y, f x * g y ∂ν ∂μ) = (∫⁻ x, f x ∂μ) * ∫⁻ y, g y ∂ν := by
  simp [lintegral_const_mul'' _ hg, lintegral_mul_const'' _ hf]
#align measure_theory.lintegral_lintegral_mul MeasureTheory.lintegral_lintegral_mul

-- TODO: Need a better way of rewriting inside of a integral
theorem lintegral_rw₁ {f f' : α → β} (h : f =ᵐ[μ] f') (g : β → ℝ≥0∞) :
    (∫⁻ a, g (f a) ∂μ) = ∫⁻ a, g (f' a) ∂μ :=
  lintegral_congr_ae <| h.mono fun a h => by rw [h]
#align measure_theory.lintegral_rw₁ MeasureTheory.lintegral_rw₁

-- TODO: Need a better way of rewriting inside of a integral
theorem lintegral_rw₂ {f₁ f₁' : α → β} {f₂ f₂' : α → γ} (h₁ : f₁ =ᵐ[μ] f₁') (h₂ : f₂ =ᵐ[μ] f₂')
    (g : β → γ → ℝ≥0∞) : (∫⁻ a, g (f₁ a) (f₂ a) ∂μ) = ∫⁻ a, g (f₁' a) (f₂' a) ∂μ :=
  lintegral_congr_ae <| h₁.mp <| h₂.mono fun _ h₂ h₁ => by rw [h₁, h₂]
#align measure_theory.lintegral_rw₂ MeasureTheory.lintegral_rw₂

@[simp]
theorem lintegral_indicator (f : α → ℝ≥0∞) {s : Set α} (hs : MeasurableSet s) :
    (∫⁻ a, s.indicator f a ∂μ) = ∫⁻ a in s, f a ∂μ :=
  by
  simp only [lintegral, ← restrict_lintegral_eq_lintegral_restrict _ hs, supᵢ_subtype']
  apply le_antisymm <;> refine' supᵢ_mono' (Subtype.forall.2 fun φ hφ => _)
  · refine' ⟨⟨φ, le_trans hφ (indicator_le_self _ _)⟩, _⟩
    refine' simple_func.lintegral_mono (fun x => _) le_rfl
    by_cases hx : x ∈ s
    · simp [hx, hs, le_refl]
    · apply le_trans (hφ x)
      simp [hx, hs, le_refl]
  · refine' ⟨⟨φ.restrict s, fun x => _⟩, le_rfl⟩
    simp [hφ x, hs, indicator_le_indicator]
#align measure_theory.lintegral_indicator MeasureTheory.lintegral_indicator

theorem lintegral_indicator₀ (f : α → ℝ≥0∞) {s : Set α} (hs : NullMeasurableSet s μ) :
    (∫⁻ a, s.indicator f a ∂μ) = ∫⁻ a in s, f a ∂μ := by
  rw [← lintegral_congr_ae (indicator_ae_eq_of_ae_eq_set hs.to_measurable_ae_eq),
    lintegral_indicator _ (measurable_set_to_measurable _ _),
    measure.restrict_congr_set hs.to_measurable_ae_eq]
#align measure_theory.lintegral_indicator₀ MeasureTheory.lintegral_indicator₀

theorem lintegral_indicator_const {s : Set α} (hs : MeasurableSet s) (c : ℝ≥0∞) :
    (∫⁻ a, s.indicator (fun _ => c) a ∂μ) = c * μ s := by
  rw [lintegral_indicator _ hs, set_lintegral_const]
#align measure_theory.lintegral_indicator_const MeasureTheory.lintegral_indicator_const

theorem set_lintegral_eq_const {f : α → ℝ≥0∞} (hf : Measurable f) (r : ℝ≥0∞) :
    (∫⁻ x in { x | f x = r }, f x ∂μ) = r * μ { x | f x = r } :=
  by
  have : ∀ᵐ x ∂μ, x ∈ { x | f x = r } → f x = r := ae_of_all μ fun _ hx => hx
  rw [set_lintegral_congr_fun _ this]
  dsimp
  rw [lintegral_const, measure.restrict_apply MeasurableSet.univ, Set.univ_inter]
  exact hf (measurable_set_singleton r)
#align measure_theory.set_lintegral_eq_const MeasureTheory.set_lintegral_eq_const

/-- A version of **Markov's inequality** for two functions. It doesn't follow from the standard
Markov's inequality because we only assume measurability of `g`, not `f`. -/
theorem lintegral_add_mul_meas_add_le_le_lintegral {f g : α → ℝ≥0∞} (hle : f ≤ᵐ[μ] g)
    (hg : AeMeasurable g μ) (ε : ℝ≥0∞) :
    (∫⁻ a, f a ∂μ) + ε * μ { x | f x + ε ≤ g x } ≤ ∫⁻ a, g a ∂μ :=
  by
  rcases exists_measurable_le_lintegral_eq μ f with ⟨φ, hφm, hφ_le, hφ_eq⟩
  calc
    (∫⁻ x, f x ∂μ) + ε * μ { x | f x + ε ≤ g x } = (∫⁻ x, φ x ∂μ) + ε * μ { x | f x + ε ≤ g x } :=
      by rw [hφ_eq]
    _ ≤ (∫⁻ x, φ x ∂μ) + ε * μ { x | φ x + ε ≤ g x } :=
      add_le_add_left
        (mul_le_mul_left' (measure_mono fun x => (add_le_add_right (hφ_le _) _).trans) _) _
    _ = ∫⁻ x, φ x + indicator { x | φ x + ε ≤ g x } (fun _ => ε) x ∂μ :=
      by
      rw [lintegral_add_left hφm, lintegral_indicator₀, set_lintegral_const]
      exact measurable_set_le (hφm.null_measurable.measurable'.add_const _) hg.null_measurable
    _ ≤ ∫⁻ x, g x ∂μ := lintegral_mono_ae (hle.mono fun x hx₁ => _)
    
  simp only [indicator_apply]; split_ifs with hx₂
  exacts[hx₂, (add_zero _).trans_le <| (hφ_le x).trans hx₁]
#align
  measure_theory.lintegral_add_mul_meas_add_le_le_lintegral MeasureTheory.lintegral_add_mul_meas_add_le_le_lintegral

/-- **Markov's inequality** also known as **Chebyshev's first inequality**. -/
theorem mul_meas_ge_le_lintegral₀ {f : α → ℝ≥0∞} (hf : AeMeasurable f μ) (ε : ℝ≥0∞) :
    ε * μ { x | ε ≤ f x } ≤ ∫⁻ a, f a ∂μ := by
  simpa only [lintegral_zero, zero_add] using
    lintegral_add_mul_meas_add_le_le_lintegral ((ae_of_all _) fun x => zero_le (f x)) hf ε
#align measure_theory.mul_meas_ge_le_lintegral₀ MeasureTheory.mul_meas_ge_le_lintegral₀

/-- **Markov's inequality** also known as **Chebyshev's first inequality**. For a version assuming
`ae_measurable`, see `mul_meas_ge_le_lintegral₀`. -/
theorem mul_meas_ge_le_lintegral {f : α → ℝ≥0∞} (hf : Measurable f) (ε : ℝ≥0∞) :
    ε * μ { x | ε ≤ f x } ≤ ∫⁻ a, f a ∂μ :=
  mul_meas_ge_le_lintegral₀ hf.AeMeasurable ε
#align measure_theory.mul_meas_ge_le_lintegral MeasureTheory.mul_meas_ge_le_lintegral

theorem lintegral_eq_top_of_measure_eq_top_pos {f : α → ℝ≥0∞} (hf : AeMeasurable f μ)
    (hμf : 0 < μ { x | f x = ∞ }) : (∫⁻ x, f x ∂μ) = ∞ :=
  eq_top_iff.mpr <|
    calc
      ∞ = ∞ * μ { x | ∞ ≤ f x } := by simp [mul_eq_top, hμf.ne.symm]
      _ ≤ ∫⁻ x, f x ∂μ := mul_meas_ge_le_lintegral₀ hf ∞
      
#align
  measure_theory.lintegral_eq_top_of_measure_eq_top_pos MeasureTheory.lintegral_eq_top_of_measure_eq_top_pos

/-- **Markov's inequality** also known as **Chebyshev's first inequality**. -/
theorem meas_ge_le_lintegral_div {f : α → ℝ≥0∞} (hf : AeMeasurable f μ) {ε : ℝ≥0∞} (hε : ε ≠ 0)
    (hε' : ε ≠ ∞) : μ { x | ε ≤ f x } ≤ (∫⁻ a, f a ∂μ) / ε :=
  (Ennreal.le_div_iff_mul_le (Or.inl hε) (Or.inl hε')).2 <|
    by
    rw [mul_comm]
    exact mul_meas_ge_le_lintegral₀ hf ε
#align measure_theory.meas_ge_le_lintegral_div MeasureTheory.meas_ge_le_lintegral_div

theorem ae_eq_of_ae_le_of_lintegral_le {f g : α → ℝ≥0∞} (hfg : f ≤ᵐ[μ] g) (hf : (∫⁻ x, f x ∂μ) ≠ ∞)
    (hg : AeMeasurable g μ) (hgf : (∫⁻ x, g x ∂μ) ≤ ∫⁻ x, f x ∂μ) : f =ᵐ[μ] g :=
  by
  have : ∀ n : ℕ, ∀ᵐ x ∂μ, g x < f x + n⁻¹ := by
    intro n
    simp only [ae_iff, not_lt]
    have : (∫⁻ x, f x ∂μ) + (↑n)⁻¹ * μ { x : α | f x + n⁻¹ ≤ g x } ≤ ∫⁻ x, f x ∂μ :=
      (lintegral_add_mul_meas_add_le_le_lintegral hfg hg n⁻¹).trans hgf
    rw [(Ennreal.cancel_of_ne hf).add_le_iff_nonpos_right, nonpos_iff_eq_zero, mul_eq_zero] at this
    exact this.resolve_left (Ennreal.inv_ne_zero.2 (Ennreal.nat_ne_top _))
  refine' hfg.mp ((ae_all_iff.2 this).mono fun x hlt hle => hle.antisymm _)
  suffices : tendsto (fun n : ℕ => f x + n⁻¹) at_top (𝓝 (f x))
  exact ge_of_tendsto' this fun i => (hlt i).le
  simpa only [inv_top, add_zero] using
    tendsto_const_nhds.add (Ennreal.tendsto_inv_iff.2 Ennreal.tendsto_nat_nhds_top)
#align measure_theory.ae_eq_of_ae_le_of_lintegral_le MeasureTheory.ae_eq_of_ae_le_of_lintegral_le

@[simp]
theorem lintegral_eq_zero_iff' {f : α → ℝ≥0∞} (hf : AeMeasurable f μ) :
    (∫⁻ a, f a ∂μ) = 0 ↔ f =ᵐ[μ] 0 :=
  have : (∫⁻ a : α, 0 ∂μ) ≠ ∞ := by simpa only [lintegral_zero] using zero_ne_top
  ⟨fun h =>
    (ae_eq_of_ae_le_of_lintegral_le (ae_of_all _ <| zero_le f) this hf
        (h.trans lintegral_zero.symm).le).symm,
    fun h => (lintegral_congr_ae h).trans lintegral_zero⟩
#align measure_theory.lintegral_eq_zero_iff' MeasureTheory.lintegral_eq_zero_iff'

@[simp]
theorem lintegral_eq_zero_iff {f : α → ℝ≥0∞} (hf : Measurable f) : (∫⁻ a, f a ∂μ) = 0 ↔ f =ᵐ[μ] 0 :=
  lintegral_eq_zero_iff' hf.AeMeasurable
#align measure_theory.lintegral_eq_zero_iff MeasureTheory.lintegral_eq_zero_iff

theorem lintegral_pos_iff_support {f : α → ℝ≥0∞} (hf : Measurable f) :
    (0 < ∫⁻ a, f a ∂μ) ↔ 0 < μ (Function.support f) := by
  simp [pos_iff_ne_zero, hf, Filter.EventuallyEq, ae_iff, Function.support]
#align measure_theory.lintegral_pos_iff_support MeasureTheory.lintegral_pos_iff_support

/-- Weaker version of the monotone convergence theorem-/
theorem lintegral_supr_ae {f : ℕ → α → ℝ≥0∞} (hf : ∀ n, Measurable (f n))
    (h_mono : ∀ n, ∀ᵐ a ∂μ, f n a ≤ f n.succ a) : (∫⁻ a, ⨆ n, f n a ∂μ) = ⨆ n, ∫⁻ a, f n a ∂μ :=
  let ⟨s, hs⟩ := exists_measurable_superset_of_null (ae_iff.1 (ae_all_iff.2 h_mono))
  let g n a := if a ∈ s then 0 else f n a
  have g_eq_f : ∀ᵐ a ∂μ, ∀ n, g n a = f n a :=
    (measure_zero_iff_ae_nmem.1 hs.2.2).mono fun a ha n => if_neg ha
  calc
    (∫⁻ a, ⨆ n, f n a ∂μ) = ∫⁻ a, ⨆ n, g n a ∂μ :=
      lintegral_congr_ae <| g_eq_f.mono fun a ha => by simp only [ha]
    _ = ⨆ n, ∫⁻ a, g n a ∂μ :=
      lintegral_supr (fun n => measurable_const.piecewise hs.2.1 (hf n))
        (monotone_nat_of_le_succ fun n a =>
          by_cases (fun h : a ∈ s => by simp [g, if_pos h]) fun h : a ∉ s =>
            by
            simp only [g, if_neg h]; have := hs.1; rw [subset_def] at this; have := mt (this a) h
            simp only [not_not, mem_set_of_eq] at this; exact this n)
    _ = ⨆ n, ∫⁻ a, f n a ∂μ := by simp only [lintegral_congr_ae (g_eq_f.mono fun a ha => ha _)]
    
#align measure_theory.lintegral_supr_ae MeasureTheory.lintegral_supr_ae

theorem lintegral_sub {f g : α → ℝ≥0∞} (hg : Measurable g) (hg_fin : (∫⁻ a, g a ∂μ) ≠ ∞)
    (h_le : g ≤ᵐ[μ] f) : (∫⁻ a, f a - g a ∂μ) = (∫⁻ a, f a ∂μ) - ∫⁻ a, g a ∂μ :=
  by
  refine' Ennreal.eq_sub_of_add_eq hg_fin _
  rw [← lintegral_add_right _ hg]
  exact lintegral_congr_ae (h_le.mono fun x hx => tsub_add_cancel_of_le hx)
#align measure_theory.lintegral_sub MeasureTheory.lintegral_sub

theorem lintegral_sub_le (f g : α → ℝ≥0∞) (hf : Measurable f) :
    ((∫⁻ x, g x ∂μ) - ∫⁻ x, f x ∂μ) ≤ ∫⁻ x, g x - f x ∂μ :=
  by
  rw [tsub_le_iff_right]
  by_cases hfi : (∫⁻ x, f x ∂μ) = ∞
  · rw [hfi, Ennreal.add_top]
    exact le_top
  · rw [← lintegral_add_right _ hf]
    exact lintegral_mono fun x => le_tsub_add
#align measure_theory.lintegral_sub_le MeasureTheory.lintegral_sub_le

theorem lintegral_strict_mono_of_ae_le_of_frequently_ae_lt {f g : α → ℝ≥0∞} (hg : AeMeasurable g μ)
    (hfi : (∫⁻ x, f x ∂μ) ≠ ∞) (h_le : f ≤ᵐ[μ] g) (h : ∃ᵐ x ∂μ, f x ≠ g x) :
    (∫⁻ x, f x ∂μ) < ∫⁻ x, g x ∂μ := by
  contrapose! h
  simp only [not_frequently, Ne.def, not_not]
  exact ae_eq_of_ae_le_of_lintegral_le h_le hfi hg h
#align
  measure_theory.lintegral_strict_mono_of_ae_le_of_frequently_ae_lt MeasureTheory.lintegral_strict_mono_of_ae_le_of_frequently_ae_lt

theorem lintegral_strict_mono_of_ae_le_of_ae_lt_on {f g : α → ℝ≥0∞} (hg : AeMeasurable g μ)
    (hfi : (∫⁻ x, f x ∂μ) ≠ ∞) (h_le : f ≤ᵐ[μ] g) {s : Set α} (hμs : μ s ≠ 0)
    (h : ∀ᵐ x ∂μ, x ∈ s → f x < g x) : (∫⁻ x, f x ∂μ) < ∫⁻ x, g x ∂μ :=
  lintegral_strict_mono_of_ae_le_of_frequently_ae_lt hg hfi h_le <|
    ((frequently_ae_mem_iff.2 hμs).and_eventually h).mono fun x hx => (hx.2 hx.1).Ne
#align
  measure_theory.lintegral_strict_mono_of_ae_le_of_ae_lt_on MeasureTheory.lintegral_strict_mono_of_ae_le_of_ae_lt_on

theorem lintegral_strict_mono {f g : α → ℝ≥0∞} (hμ : μ ≠ 0) (hg : AeMeasurable g μ)
    (hfi : (∫⁻ x, f x ∂μ) ≠ ∞) (h : ∀ᵐ x ∂μ, f x < g x) : (∫⁻ x, f x ∂μ) < ∫⁻ x, g x ∂μ :=
  by
  rw [Ne.def, ← measure.measure_univ_eq_zero] at hμ
  refine' lintegral_strict_mono_of_ae_le_of_ae_lt_on hg hfi (ae_le_of_ae_lt h) hμ _
  simpa using h
#align measure_theory.lintegral_strict_mono MeasureTheory.lintegral_strict_mono

theorem set_lintegral_strict_mono {f g : α → ℝ≥0∞} {s : Set α} (hsm : MeasurableSet s)
    (hs : μ s ≠ 0) (hg : Measurable g) (hfi : (∫⁻ x in s, f x ∂μ) ≠ ∞)
    (h : ∀ᵐ x ∂μ, x ∈ s → f x < g x) : (∫⁻ x in s, f x ∂μ) < ∫⁻ x in s, g x ∂μ :=
  lintegral_strict_mono (by simp [hs]) hg.AeMeasurable hfi ((ae_restrict_iff' hsm).mpr h)
#align measure_theory.set_lintegral_strict_mono MeasureTheory.set_lintegral_strict_mono

/-- Monotone convergence theorem for nonincreasing sequences of functions -/
theorem lintegral_infi_ae {f : ℕ → α → ℝ≥0∞} (h_meas : ∀ n, Measurable (f n))
    (h_mono : ∀ n : ℕ, f n.succ ≤ᵐ[μ] f n) (h_fin : (∫⁻ a, f 0 a ∂μ) ≠ ∞) :
    (∫⁻ a, ⨅ n, f n a ∂μ) = ⨅ n, ∫⁻ a, f n a ∂μ :=
  have fn_le_f0 : (∫⁻ a, ⨅ n, f n a ∂μ) ≤ ∫⁻ a, f 0 a ∂μ :=
    lintegral_mono fun a => infᵢ_le_of_le 0 le_rfl
  have fn_le_f0' : (⨅ n, ∫⁻ a, f n a ∂μ) ≤ ∫⁻ a, f 0 a ∂μ := infᵢ_le_of_le 0 le_rfl
  (Ennreal.sub_right_inj h_fin fn_le_f0 fn_le_f0').1 <|
    show ((∫⁻ a, f 0 a ∂μ) - ∫⁻ a, ⨅ n, f n a ∂μ) = (∫⁻ a, f 0 a ∂μ) - ⨅ n, ∫⁻ a, f n a ∂μ from
      calc
        ((∫⁻ a, f 0 a ∂μ) - ∫⁻ a, ⨅ n, f n a ∂μ) = ∫⁻ a, f 0 a - ⨅ n, f n a ∂μ :=
          (lintegral_sub (measurable_infi h_meas)
              (ne_top_of_le_ne_top h_fin <| lintegral_mono fun a => infᵢ_le _ _)
              ((ae_of_all _) fun a => infᵢ_le _ _)).symm
        _ = ∫⁻ a, ⨆ n, f 0 a - f n a ∂μ := congr rfl (funext fun a => Ennreal.sub_infi)
        _ = ⨆ n, ∫⁻ a, f 0 a - f n a ∂μ :=
          lintegral_supr_ae (fun n => (h_meas 0).sub (h_meas n)) fun n =>
            (h_mono n).mono fun a ha => tsub_le_tsub le_rfl ha
        _ = ⨆ n, (∫⁻ a, f 0 a ∂μ) - ∫⁻ a, f n a ∂μ :=
          have h_mono : ∀ᵐ a ∂μ, ∀ n : ℕ, f n.succ a ≤ f n a := ae_all_iff.2 h_mono
          have h_mono : ∀ n, ∀ᵐ a ∂μ, f n a ≤ f 0 a := fun n =>
            h_mono.mono fun a h => by
              induction' n with n ih
              · exact le_rfl; · exact le_trans (h n) ih
          congr_arg supᵢ <|
            funext fun n =>
              lintegral_sub (h_meas _) (ne_top_of_le_ne_top h_fin <| lintegral_mono_ae <| h_mono n)
                (h_mono n)
        _ = (∫⁻ a, f 0 a ∂μ) - ⨅ n, ∫⁻ a, f n a ∂μ := Ennreal.sub_infi.symm
        
#align measure_theory.lintegral_infi_ae MeasureTheory.lintegral_infi_ae

/-- Monotone convergence theorem for nonincreasing sequences of functions -/
theorem lintegral_infi {f : ℕ → α → ℝ≥0∞} (h_meas : ∀ n, Measurable (f n)) (h_anti : Antitone f)
    (h_fin : (∫⁻ a, f 0 a ∂μ) ≠ ∞) : (∫⁻ a, ⨅ n, f n a ∂μ) = ⨅ n, ∫⁻ a, f n a ∂μ :=
  lintegral_infi_ae h_meas (fun n => ae_of_all _ <| h_anti n.le_succ) h_fin
#align measure_theory.lintegral_infi MeasureTheory.lintegral_infi

/-- Known as Fatou's lemma, version with `ae_measurable` functions -/
theorem lintegral_liminf_le' {f : ℕ → α → ℝ≥0∞} (h_meas : ∀ n, AeMeasurable (f n) μ) :
    (∫⁻ a, liminf (fun n => f n a) atTop ∂μ) ≤ liminf (fun n => ∫⁻ a, f n a ∂μ) atTop :=
  calc
    (∫⁻ a, liminf (fun n => f n a) atTop ∂μ) = ∫⁻ a, ⨆ n : ℕ, ⨅ i ≥ n, f i a ∂μ := by
      simp only [liminf_eq_supr_infi_of_nat]
    _ = ⨆ n : ℕ, ∫⁻ a, ⨅ i ≥ n, f i a ∂μ :=
      lintegral_supr' (fun n => aeMeasurableBinfi _ (to_countable _) h_meas)
        (ae_of_all μ fun a n m hnm => infᵢ_le_infᵢ_of_subset fun i hi => le_trans hnm hi)
    _ ≤ ⨆ n : ℕ, ⨅ i ≥ n, ∫⁻ a, f i a ∂μ := supᵢ_mono fun n => le_infi₂_lintegral _
    _ = atTop.liminf fun n => ∫⁻ a, f n a ∂μ := Filter.liminf_eq_supr_infi_of_nat.symm
    
#align measure_theory.lintegral_liminf_le' MeasureTheory.lintegral_liminf_le'

/-- Known as Fatou's lemma -/
theorem lintegral_liminf_le {f : ℕ → α → ℝ≥0∞} (h_meas : ∀ n, Measurable (f n)) :
    (∫⁻ a, liminf (fun n => f n a) atTop ∂μ) ≤ liminf (fun n => ∫⁻ a, f n a ∂μ) atTop :=
  lintegral_liminf_le' fun n => (h_meas n).AeMeasurable
#align measure_theory.lintegral_liminf_le MeasureTheory.lintegral_liminf_le

theorem limsup_lintegral_le {f : ℕ → α → ℝ≥0∞} {g : α → ℝ≥0∞} (hf_meas : ∀ n, Measurable (f n))
    (h_bound : ∀ n, f n ≤ᵐ[μ] g) (h_fin : (∫⁻ a, g a ∂μ) ≠ ∞) :
    limsup (fun n => ∫⁻ a, f n a ∂μ) atTop ≤ ∫⁻ a, limsup (fun n => f n a) atTop ∂μ :=
  calc
    limsup (fun n => ∫⁻ a, f n a ∂μ) atTop = ⨅ n : ℕ, ⨆ i ≥ n, ∫⁻ a, f i a ∂μ :=
      limsup_eq_infi_supr_of_nat
    _ ≤ ⨅ n : ℕ, ∫⁻ a, ⨆ i ≥ n, f i a ∂μ := infᵢ_mono fun n => supr₂_lintegral_le _
    _ = ∫⁻ a, ⨅ n : ℕ, ⨆ i ≥ n, f i a ∂μ :=
      by
      refine' (lintegral_infi _ _ _).symm
      · intro n
        exact measurable_bsupr _ (to_countable _) hf_meas
      · intro n m hnm a
        exact supᵢ_le_supᵢ_of_subset fun i hi => le_trans hnm hi
      · refine' ne_top_of_le_ne_top h_fin (lintegral_mono_ae _)
        refine' (ae_all_iff.2 h_bound).mono fun n hn => _
        exact supᵢ_le fun i => supᵢ_le fun hi => hn i
    _ = ∫⁻ a, limsup (fun n => f n a) atTop ∂μ := by simp only [limsup_eq_infi_supr_of_nat]
    
#align measure_theory.limsup_lintegral_le MeasureTheory.limsup_lintegral_le

/-- Dominated convergence theorem for nonnegative functions -/
theorem tendsto_lintegral_of_dominated_convergence {F : ℕ → α → ℝ≥0∞} {f : α → ℝ≥0∞}
    (bound : α → ℝ≥0∞) (hF_meas : ∀ n, Measurable (F n)) (h_bound : ∀ n, F n ≤ᵐ[μ] bound)
    (h_fin : (∫⁻ a, bound a ∂μ) ≠ ∞) (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop (𝓝 (f a))) :
    Tendsto (fun n => ∫⁻ a, F n a ∂μ) atTop (𝓝 (∫⁻ a, f a ∂μ)) :=
  tendsto_of_le_liminf_of_limsup_le
    (calc
      (∫⁻ a, f a ∂μ) = ∫⁻ a, liminf (fun n : ℕ => F n a) atTop ∂μ :=
        lintegral_congr_ae <| h_lim.mono fun a h => h.liminf_eq.symm
      _ ≤ liminf (fun n => ∫⁻ a, F n a ∂μ) atTop := lintegral_liminf_le hF_meas
      )
    (calc
      limsup (fun n : ℕ => ∫⁻ a, F n a ∂μ) atTop ≤ ∫⁻ a, limsup (fun n => F n a) atTop ∂μ :=
        limsup_lintegral_le hF_meas h_bound h_fin
      _ = ∫⁻ a, f a ∂μ := lintegral_congr_ae <| h_lim.mono fun a h => h.limsup_eq
      )
#align
  measure_theory.tendsto_lintegral_of_dominated_convergence MeasureTheory.tendsto_lintegral_of_dominated_convergence

/-- Dominated convergence theorem for nonnegative functions which are just almost everywhere
measurable. -/
theorem tendsto_lintegral_of_dominated_convergence' {F : ℕ → α → ℝ≥0∞} {f : α → ℝ≥0∞}
    (bound : α → ℝ≥0∞) (hF_meas : ∀ n, AeMeasurable (F n) μ) (h_bound : ∀ n, F n ≤ᵐ[μ] bound)
    (h_fin : (∫⁻ a, bound a ∂μ) ≠ ∞) (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop (𝓝 (f a))) :
    Tendsto (fun n => ∫⁻ a, F n a ∂μ) atTop (𝓝 (∫⁻ a, f a ∂μ)) :=
  by
  have : ∀ n, (∫⁻ a, F n a ∂μ) = ∫⁻ a, (hF_meas n).mk (F n) a ∂μ := fun n =>
    lintegral_congr_ae (hF_meas n).ae_eq_mk
  simp_rw [this]
  apply
    tendsto_lintegral_of_dominated_convergence bound (fun n => (hF_meas n).measurable_mk) _ h_fin
  · have : ∀ n, ∀ᵐ a ∂μ, (hF_meas n).mk (F n) a = F n a := fun n => (hF_meas n).ae_eq_mk.symm
    have : ∀ᵐ a ∂μ, ∀ n, (hF_meas n).mk (F n) a = F n a := ae_all_iff.mpr this
    filter_upwards [this, h_lim] with a H H'
    simp_rw [H]
    exact H'
  · intro n
    filter_upwards [h_bound n, (hF_meas n).ae_eq_mk] with a H H'
    rwa [H'] at H
#align
  measure_theory.tendsto_lintegral_of_dominated_convergence' MeasureTheory.tendsto_lintegral_of_dominated_convergence'

/-- Dominated convergence theorem for filters with a countable basis -/
theorem tendsto_lintegral_filter_of_dominated_convergence {ι} {l : Filter ι}
    [l.IsCountablyGenerated] {F : ι → α → ℝ≥0∞} {f : α → ℝ≥0∞} (bound : α → ℝ≥0∞)
    (hF_meas : ∀ᶠ n in l, Measurable (F n)) (h_bound : ∀ᶠ n in l, ∀ᵐ a ∂μ, F n a ≤ bound a)
    (h_fin : (∫⁻ a, bound a ∂μ) ≠ ∞) (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) l (𝓝 (f a))) :
    Tendsto (fun n => ∫⁻ a, F n a ∂μ) l (𝓝 <| ∫⁻ a, f a ∂μ) :=
  by
  rw [tendsto_iff_seq_tendsto]
  intro x xl
  have hxl := by
    rw [tendsto_at_top'] at xl
    exact xl
  have h := inter_mem hF_meas h_bound
  replace h := hxl _ h
  rcases h with ⟨k, h⟩
  rw [← tendsto_add_at_top_iff_nat k]
  refine' tendsto_lintegral_of_dominated_convergence _ _ _ _ _
  · exact bound
  · intro
    refine' (h _ _).1
    exact Nat.le_add_left _ _
  · intro
    refine' (h _ _).2
    exact Nat.le_add_left _ _
  · assumption
  · refine' h_lim.mono fun a h_lim => _
    apply @tendsto.comp _ _ _ (fun n => x (n + k)) fun n => F n a
    · assumption
    rw [tendsto_add_at_top_iff_nat]
    assumption
#align
  measure_theory.tendsto_lintegral_filter_of_dominated_convergence MeasureTheory.tendsto_lintegral_filter_of_dominated_convergence

section

open Encodable

/-- Monotone convergence for a supremum over a directed family and indexed by a countable type -/
theorem lintegral_supr_directed_of_measurable [Countable β] {f : β → α → ℝ≥0∞}
    (hf : ∀ b, Measurable (f b)) (h_directed : Directed (· ≤ ·) f) :
    (∫⁻ a, ⨆ b, f b a ∂μ) = ⨆ b, ∫⁻ a, f b a ∂μ :=
  by
  cases nonempty_encodable β
  cases isEmpty_or_nonempty β
  · simp [supᵢ_of_empty]
  inhabit β
  have : ∀ a, (⨆ b, f b a) = ⨆ n, f (h_directed.sequence f n) a :=
    by
    intro a
    refine' le_antisymm (supᵢ_le fun b => _) (supᵢ_le fun n => le_supᵢ (fun n => f n a) _)
    exact le_supᵢ_of_le (encode b + 1) (h_directed.le_sequence b a)
  calc
    (∫⁻ a, ⨆ b, f b a ∂μ) = ∫⁻ a, ⨆ n, f (h_directed.sequence f n) a ∂μ := by simp only [this]
    _ = ⨆ n, ∫⁻ a, f (h_directed.sequence f n) a ∂μ :=
      lintegral_supr (fun n => hf _) h_directed.sequence_mono
    _ = ⨆ b, ∫⁻ a, f b a ∂μ :=
      by
      refine' le_antisymm (supᵢ_le fun n => _) (supᵢ_le fun b => _)
      · exact le_supᵢ (fun b => ∫⁻ a, f b a ∂μ) _
      · exact le_supᵢ_of_le (encode b + 1) (lintegral_mono <| h_directed.le_sequence b)
    
#align
  measure_theory.lintegral_supr_directed_of_measurable MeasureTheory.lintegral_supr_directed_of_measurable

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:75:38: in filter_upwards #[[], ["with", ident x, ident i, ident j], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:75:38: in apply_rules #[["[", expr hz₁, ",", expr hz₂, "]"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error -/
/-- Monotone convergence for a supremum over a directed family and indexed by a countable type. -/
theorem lintegral_supr_directed [Countable β] {f : β → α → ℝ≥0∞} (hf : ∀ b, AeMeasurable (f b) μ)
    (h_directed : Directed (· ≤ ·) f) : (∫⁻ a, ⨆ b, f b a ∂μ) = ⨆ b, ∫⁻ a, f b a ∂μ :=
  by
  simp_rw [← supᵢ_apply]
  let p : α → (β → Ennreal) → Prop := fun x f' => Directed LE.le f'
  have hp : ∀ᵐ x ∂μ, p x fun i => f i x :=
    by
    trace
      "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:75:38: in filter_upwards #[[], [\"with\", ident x, ident i, ident j], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error"
    obtain ⟨z, hz₁, hz₂⟩ := h_directed i j
    exact ⟨z, hz₁ x, hz₂ x⟩
  have h_ae_seq_directed : Directed LE.le (aeSeq hf p) :=
    by
    intro b₁ b₂
    obtain ⟨z, hz₁, hz₂⟩ := h_directed b₁ b₂
    refine' ⟨z, _, _⟩ <;>
      · intro x
        by_cases hx : x ∈ aeSeqSet hf p
        · repeat' rw [aeSeq.ae_seq_eq_fun_of_mem_ae_seq_set hf hx]
          trace
            "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:75:38: in apply_rules #[[\"[\", expr hz₁, \",\", expr hz₂, \"]\"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error"
        · simp only [aeSeq, hx, if_false]
          exact le_rfl
  convert lintegral_supr_directed_of_measurable (aeSeq.measurable hf p) h_ae_seq_directed using 1
  · simp_rw [← supᵢ_apply]
    rw [lintegral_congr_ae (aeSeq.supr hf hp).symm]
  · congr 1
    ext1 b
    rw [lintegral_congr_ae]
    symm
    refine' aeSeq.ae_seq_n_eq_fun_n_ae hf hp _
#align measure_theory.lintegral_supr_directed MeasureTheory.lintegral_supr_directed

end

theorem lintegral_tsum [Countable β] {f : β → α → ℝ≥0∞} (hf : ∀ i, AeMeasurable (f i) μ) :
    (∫⁻ a, ∑' i, f i a ∂μ) = ∑' i, ∫⁻ a, f i a ∂μ :=
  by
  simp only [Ennreal.tsum_eq_supr_sum]
  rw [lintegral_supr_directed]
  · simp [lintegral_finset_sum' _ fun i _ => hf i]
  · intro b
    exact Finset.aeMeasurableSum _ fun i _ => hf i
  · intro s t
    use s ∪ t
    constructor
    · exact fun a => Finset.sum_le_sum_of_subset (Finset.subset_union_left _ _)
    · exact fun a => Finset.sum_le_sum_of_subset (Finset.subset_union_right _ _)
#align measure_theory.lintegral_tsum MeasureTheory.lintegral_tsum

open Measure

theorem lintegral_Union₀ [Countable β] {s : β → Set α} (hm : ∀ i, NullMeasurableSet (s i) μ)
    (hd : Pairwise (AeDisjoint μ on s)) (f : α → ℝ≥0∞) :
    (∫⁻ a in ⋃ i, s i, f a ∂μ) = ∑' i, ∫⁻ a in s i, f a ∂μ := by
  simp only [measure.restrict_Union_ae hd hm, lintegral_sum_measure]
#align measure_theory.lintegral_Union₀ MeasureTheory.lintegral_Union₀

theorem lintegral_Union [Countable β] {s : β → Set α} (hm : ∀ i, MeasurableSet (s i))
    (hd : Pairwise (Disjoint on s)) (f : α → ℝ≥0∞) :
    (∫⁻ a in ⋃ i, s i, f a ∂μ) = ∑' i, ∫⁻ a in s i, f a ∂μ :=
  lintegral_Union₀ (fun i => (hm i).NullMeasurableSet) hd.AeDisjoint f
#align measure_theory.lintegral_Union MeasureTheory.lintegral_Union

theorem lintegral_bUnion₀ {t : Set β} {s : β → Set α} (ht : t.Countable)
    (hm : ∀ i ∈ t, NullMeasurableSet (s i) μ) (hd : t.Pairwise (AeDisjoint μ on s)) (f : α → ℝ≥0∞) :
    (∫⁻ a in ⋃ i ∈ t, s i, f a ∂μ) = ∑' i : t, ∫⁻ a in s i, f a ∂μ :=
  by
  haveI := ht.to_encodable
  rw [bUnion_eq_Union, lintegral_Union₀ (SetCoe.forall'.1 hm) (hd.subtype _ _)]
#align measure_theory.lintegral_bUnion₀ MeasureTheory.lintegral_bUnion₀

theorem lintegral_bUnion {t : Set β} {s : β → Set α} (ht : t.Countable)
    (hm : ∀ i ∈ t, MeasurableSet (s i)) (hd : t.PairwiseDisjoint s) (f : α → ℝ≥0∞) :
    (∫⁻ a in ⋃ i ∈ t, s i, f a ∂μ) = ∑' i : t, ∫⁻ a in s i, f a ∂μ :=
  lintegral_bUnion₀ ht (fun i hi => (hm i hi).NullMeasurableSet) hd.AeDisjoint f
#align measure_theory.lintegral_bUnion MeasureTheory.lintegral_bUnion

theorem lintegral_bUnion_finset₀ {s : Finset β} {t : β → Set α}
    (hd : Set.Pairwise (↑s) (AeDisjoint μ on t)) (hm : ∀ b ∈ s, NullMeasurableSet (t b) μ)
    (f : α → ℝ≥0∞) : (∫⁻ a in ⋃ b ∈ s, t b, f a ∂μ) = ∑ b in s, ∫⁻ a in t b, f a ∂μ := by
  simp only [← Finset.mem_coe, lintegral_bUnion₀ s.countable_to_set hm hd, ← s.tsum_subtype']
#align measure_theory.lintegral_bUnion_finset₀ MeasureTheory.lintegral_bUnion_finset₀

theorem lintegral_bUnion_finset {s : Finset β} {t : β → Set α} (hd : Set.PairwiseDisjoint (↑s) t)
    (hm : ∀ b ∈ s, MeasurableSet (t b)) (f : α → ℝ≥0∞) :
    (∫⁻ a in ⋃ b ∈ s, t b, f a ∂μ) = ∑ b in s, ∫⁻ a in t b, f a ∂μ :=
  lintegral_bUnion_finset₀ hd.AeDisjoint (fun b hb => (hm b hb).NullMeasurableSet) f
#align measure_theory.lintegral_bUnion_finset MeasureTheory.lintegral_bUnion_finset

theorem lintegral_Union_le [Countable β] (s : β → Set α) (f : α → ℝ≥0∞) :
    (∫⁻ a in ⋃ i, s i, f a ∂μ) ≤ ∑' i, ∫⁻ a in s i, f a ∂μ :=
  by
  rw [← lintegral_sum_measure]
  exact lintegral_mono' restrict_Union_le le_rfl
#align measure_theory.lintegral_Union_le MeasureTheory.lintegral_Union_le

theorem lintegral_union {f : α → ℝ≥0∞} {A B : Set α} (hB : MeasurableSet B) (hAB : Disjoint A B) :
    (∫⁻ a in A ∪ B, f a ∂μ) = (∫⁻ a in A, f a ∂μ) + ∫⁻ a in B, f a ∂μ := by
  rw [restrict_union hAB hB, lintegral_add_measure]
#align measure_theory.lintegral_union MeasureTheory.lintegral_union

theorem lintegral_inter_add_diff {B : Set α} (f : α → ℝ≥0∞) (A : Set α) (hB : MeasurableSet B) :
    ((∫⁻ x in A ∩ B, f x ∂μ) + ∫⁻ x in A \ B, f x ∂μ) = ∫⁻ x in A, f x ∂μ := by
  rw [← lintegral_add_measure, restrict_inter_add_diff _ hB]
#align measure_theory.lintegral_inter_add_diff MeasureTheory.lintegral_inter_add_diff

theorem lintegral_add_compl (f : α → ℝ≥0∞) {A : Set α} (hA : MeasurableSet A) :
    ((∫⁻ x in A, f x ∂μ) + ∫⁻ x in Aᶜ, f x ∂μ) = ∫⁻ x, f x ∂μ := by
  rw [← lintegral_add_measure, measure.restrict_add_restrict_compl hA]
#align measure_theory.lintegral_add_compl MeasureTheory.lintegral_add_compl

theorem lintegral_max {f g : α → ℝ≥0∞} (hf : Measurable f) (hg : Measurable g) :
    (∫⁻ x, max (f x) (g x) ∂μ) =
      (∫⁻ x in { x | f x ≤ g x }, g x ∂μ) + ∫⁻ x in { x | g x < f x }, f x ∂μ :=
  by
  have hm : MeasurableSet { x | f x ≤ g x } := measurable_set_le hf hg
  rw [← lintegral_add_compl (fun x => max (f x) (g x)) hm]
  simp only [← compl_set_of, ← not_le]
  refine' congr_arg₂ (· + ·) (set_lintegral_congr_fun hm _) (set_lintegral_congr_fun hm.compl _)
  exacts[ae_of_all _ fun x => max_eq_right, ae_of_all _ fun x hx => max_eq_left (not_le.1 hx).le]
#align measure_theory.lintegral_max MeasureTheory.lintegral_max

theorem set_lintegral_max {f g : α → ℝ≥0∞} (hf : Measurable f) (hg : Measurable g) (s : Set α) :
    (∫⁻ x in s, max (f x) (g x) ∂μ) =
      (∫⁻ x in s ∩ { x | f x ≤ g x }, g x ∂μ) + ∫⁻ x in s ∩ { x | g x < f x }, f x ∂μ :=
  by
  rw [lintegral_max hf hg, restrict_restrict, restrict_restrict, inter_comm s, inter_comm s]
  exacts[measurable_set_lt hg hf, measurable_set_le hf hg]
#align measure_theory.set_lintegral_max MeasureTheory.set_lintegral_max

theorem lintegral_map {mβ : MeasurableSpace β} {f : β → ℝ≥0∞} {g : α → β} (hf : Measurable f)
    (hg : Measurable g) : (∫⁻ a, f a ∂map g μ) = ∫⁻ a, f (g a) ∂μ :=
  by
  simp only [lintegral_eq_supr_eapprox_lintegral, hf, hf.comp hg]
  congr with n : 1
  convert simple_func.lintegral_map _ hg
  ext1 x; simp only [eapprox_comp hf hg, coe_comp]
#align measure_theory.lintegral_map MeasureTheory.lintegral_map

theorem lintegral_map' {mβ : MeasurableSpace β} {f : β → ℝ≥0∞} {g : α → β}
    (hf : AeMeasurable f (Measure.map g μ)) (hg : AeMeasurable g μ) :
    (∫⁻ a, f a ∂Measure.map g μ) = ∫⁻ a, f (g a) ∂μ :=
  calc
    (∫⁻ a, f a ∂Measure.map g μ) = ∫⁻ a, hf.mk f a ∂Measure.map g μ :=
      lintegral_congr_ae hf.ae_eq_mk
    _ = ∫⁻ a, hf.mk f a ∂Measure.map (hg.mk g) μ :=
      by
      congr 1
      exact measure.map_congr hg.ae_eq_mk
    _ = ∫⁻ a, hf.mk f (hg.mk g a) ∂μ := lintegral_map hf.measurable_mk hg.measurable_mk
    _ = ∫⁻ a, hf.mk f (g a) ∂μ := lintegral_congr_ae <| hg.ae_eq_mk.symm.fun_comp _
    _ = ∫⁻ a, f (g a) ∂μ := lintegral_congr_ae (ae_eq_comp hg hf.ae_eq_mk.symm)
    
#align measure_theory.lintegral_map' MeasureTheory.lintegral_map'

theorem lintegral_map_le {mβ : MeasurableSpace β} (f : β → ℝ≥0∞) {g : α → β} (hg : Measurable g) :
    (∫⁻ a, f a ∂Measure.map g μ) ≤ ∫⁻ a, f (g a) ∂μ :=
  by
  rw [← supr_lintegral_measurable_le_eq_lintegral, ← supr_lintegral_measurable_le_eq_lintegral]
  refine' supᵢ₂_le fun i hi => supᵢ_le fun h'i => _
  refine' le_supᵢ₂_of_le (i ∘ g) (hi.comp hg) _
  exact le_supᵢ_of_le (fun x => h'i (g x)) (le_of_eq (lintegral_map hi hg))
#align measure_theory.lintegral_map_le MeasureTheory.lintegral_map_le

theorem lintegral_comp [MeasurableSpace β] {f : β → ℝ≥0∞} {g : α → β} (hf : Measurable f)
    (hg : Measurable g) : lintegral μ (f ∘ g) = ∫⁻ a, f a ∂map g μ :=
  (lintegral_map hf hg).symm
#align measure_theory.lintegral_comp MeasureTheory.lintegral_comp

theorem set_lintegral_map [MeasurableSpace β] {f : β → ℝ≥0∞} {g : α → β} {s : Set β}
    (hs : MeasurableSet s) (hf : Measurable f) (hg : Measurable g) :
    (∫⁻ y in s, f y ∂map g μ) = ∫⁻ x in g ⁻¹' s, f (g x) ∂μ := by
  rw [restrict_map hg hs, lintegral_map hf hg]
#align measure_theory.set_lintegral_map MeasureTheory.set_lintegral_map

theorem lintegral_indicator_const_comp {mβ : MeasurableSpace β} {f : α → β} {s : Set β}
    (hf : Measurable f) (hs : MeasurableSet s) (c : ℝ≥0∞) :
    (∫⁻ a, s.indicator (fun _ => c) (f a) ∂μ) = c * μ (f ⁻¹' s) := by
  rw [lintegral_comp (measurable_const.indicator hs) hf, lintegral_indicator_const hs,
    measure.map_apply hf hs]
#align measure_theory.lintegral_indicator_const_comp MeasureTheory.lintegral_indicator_const_comp

/-- If `g : α → β` is a measurable embedding and `f : β → ℝ≥0∞` is any function (not necessarily
measurable), then `∫⁻ a, f a ∂(map g μ) = ∫⁻ a, f (g a) ∂μ`. Compare with `lintegral_map` wich
applies to any measurable `g : α → β` but requires that `f` is measurable as well. -/
theorem MeasurableEmbedding.lintegral_map [MeasurableSpace β] {g : α → β}
    (hg : MeasurableEmbedding g) (f : β → ℝ≥0∞) : (∫⁻ a, f a ∂map g μ) = ∫⁻ a, f (g a) ∂μ :=
  by
  rw [lintegral, lintegral]
  refine' le_antisymm (supᵢ₂_le fun f₀ hf₀ => _) (supᵢ₂_le fun f₀ hf₀ => _)
  · rw [simple_func.lintegral_map _ hg.measurable]
    have : (f₀.comp g hg.measurable : α → ℝ≥0∞) ≤ f ∘ g := fun x => hf₀ (g x)
    exact le_supᵢ_of_le (comp f₀ g hg.measurable) (le_supᵢ _ this)
  · rw [← f₀.extend_comp_eq hg (const _ 0), ← simple_func.lintegral_map, ←
      simple_func.lintegral_eq_lintegral, ← lintegral]
    refine' lintegral_mono_ae (hg.ae_map_iff.2 <| eventually_of_forall fun x => _)
    exact (extend_apply _ _ _ _).trans_le (hf₀ _)
#align measurable_embedding.lintegral_map MeasurableEmbedding.lintegral_map

/-- The `lintegral` transforms appropriately under a measurable equivalence `g : α ≃ᵐ β`.
(Compare `lintegral_map`, which applies to a wider class of functions `g : α → β`, but requires
measurability of the function being integrated.) -/
theorem lintegral_map_equiv [MeasurableSpace β] (f : β → ℝ≥0∞) (g : α ≃ᵐ β) :
    (∫⁻ a, f a ∂map g μ) = ∫⁻ a, f (g a) ∂μ :=
  g.MeasurableEmbedding.lintegral_map f
#align measure_theory.lintegral_map_equiv MeasureTheory.lintegral_map_equiv

theorem MeasurePreserving.lintegral_comp {mb : MeasurableSpace β} {ν : Measure β} {g : α → β}
    (hg : MeasurePreserving g μ ν) {f : β → ℝ≥0∞} (hf : Measurable f) :
    (∫⁻ a, f (g a) ∂μ) = ∫⁻ b, f b ∂ν := by rw [← hg.map_eq, lintegral_map hf hg.measurable]
#align
  measure_theory.measure_preserving.lintegral_comp MeasureTheory.MeasurePreserving.lintegral_comp

theorem MeasurePreserving.lintegral_comp_emb {mb : MeasurableSpace β} {ν : Measure β} {g : α → β}
    (hg : MeasurePreserving g μ ν) (hge : MeasurableEmbedding g) (f : β → ℝ≥0∞) :
    (∫⁻ a, f (g a) ∂μ) = ∫⁻ b, f b ∂ν := by rw [← hg.map_eq, hge.lintegral_map]
#align
  measure_theory.measure_preserving.lintegral_comp_emb MeasureTheory.MeasurePreserving.lintegral_comp_emb

theorem MeasurePreserving.set_lintegral_comp_preimage {mb : MeasurableSpace β} {ν : Measure β}
    {g : α → β} (hg : MeasurePreserving g μ ν) {s : Set β} (hs : MeasurableSet s) {f : β → ℝ≥0∞}
    (hf : Measurable f) : (∫⁻ a in g ⁻¹' s, f (g a) ∂μ) = ∫⁻ b in s, f b ∂ν := by
  rw [← hg.map_eq, set_lintegral_map hs hf hg.measurable]
#align
  measure_theory.measure_preserving.set_lintegral_comp_preimage MeasureTheory.MeasurePreserving.set_lintegral_comp_preimage

theorem MeasurePreserving.set_lintegral_comp_preimage_emb {mb : MeasurableSpace β} {ν : Measure β}
    {g : α → β} (hg : MeasurePreserving g μ ν) (hge : MeasurableEmbedding g) (f : β → ℝ≥0∞)
    (s : Set β) : (∫⁻ a in g ⁻¹' s, f (g a) ∂μ) = ∫⁻ b in s, f b ∂ν := by
  rw [← hg.map_eq, hge.restrict_map, hge.lintegral_map]
#align
  measure_theory.measure_preserving.set_lintegral_comp_preimage_emb MeasureTheory.MeasurePreserving.set_lintegral_comp_preimage_emb

theorem MeasurePreserving.set_lintegral_comp_emb {mb : MeasurableSpace β} {ν : Measure β}
    {g : α → β} (hg : MeasurePreserving g μ ν) (hge : MeasurableEmbedding g) (f : β → ℝ≥0∞)
    (s : Set α) : (∫⁻ a in s, f (g a) ∂μ) = ∫⁻ b in g '' s, f b ∂ν := by
  rw [← hg.set_lintegral_comp_preimage_emb hge, preimage_image_eq _ hge.injective]
#align
  measure_theory.measure_preserving.set_lintegral_comp_emb MeasureTheory.MeasurePreserving.set_lintegral_comp_emb

section DiracAndCount

instance (priority := 10) MeasurableSpace.Top.measurable_singleton_class {α : Type _} :
    @MeasurableSingletonClass α (⊤ : MeasurableSpace α)
    where measurable_set_singleton i := MeasurableSpace.measurable_set_top
#align
  measurable_space.top.measurable_singleton_class MeasurableSpace.Top.measurable_singleton_class

variable [MeasurableSpace α]

theorem lintegral_dirac' (a : α) {f : α → ℝ≥0∞} (hf : Measurable f) : (∫⁻ a, f a ∂dirac a) = f a :=
  by simp [lintegral_congr_ae (ae_eq_dirac' hf)]
#align measure_theory.lintegral_dirac' MeasureTheory.lintegral_dirac'

theorem lintegral_dirac [MeasurableSingletonClass α] (a : α) (f : α → ℝ≥0∞) :
    (∫⁻ a, f a ∂dirac a) = f a := by simp [lintegral_congr_ae (ae_eq_dirac f)]
#align measure_theory.lintegral_dirac MeasureTheory.lintegral_dirac

theorem lintegral_count' {f : α → ℝ≥0∞} (hf : Measurable f) : (∫⁻ a, f a ∂count) = ∑' a, f a :=
  by
  rw [count, lintegral_sum_measure]
  congr
  exact funext fun a => lintegral_dirac' a hf
#align measure_theory.lintegral_count' MeasureTheory.lintegral_count'

theorem lintegral_count [MeasurableSingletonClass α] (f : α → ℝ≥0∞) :
    (∫⁻ a, f a ∂count) = ∑' a, f a :=
  by
  rw [count, lintegral_sum_measure]
  congr
  exact funext fun a => lintegral_dirac a f
#align measure_theory.lintegral_count MeasureTheory.lintegral_count

theorem Ennreal.tsum_const_eq [MeasurableSingletonClass α] (c : ℝ≥0∞) :
    (∑' i : α, c) = c * Measure.count (univ : Set α) := by rw [← lintegral_count, lintegral_const]
#align ennreal.tsum_const_eq Ennreal.tsum_const_eq

/-- Markov's inequality for the counting measure with hypothesis using `tsum` in `ℝ≥0∞`. -/
theorem Ennreal.count_const_le_le_of_tsum_le [MeasurableSingletonClass α] {a : α → ℝ≥0∞}
    (a_mble : Measurable a) {c : ℝ≥0∞} (tsum_le_c : (∑' i, a i) ≤ c) {ε : ℝ≥0∞} (ε_ne_zero : ε ≠ 0)
    (ε_ne_top : ε ≠ ∞) : Measure.count { i : α | ε ≤ a i } ≤ c / ε :=
  by
  rw [← lintegral_count] at tsum_le_c
  apply (MeasureTheory.meas_ge_le_lintegral_div a_mble.ae_measurable ε_ne_zero ε_ne_top).trans
  exact Ennreal.div_le_div tsum_le_c rfl.le
#align ennreal.count_const_le_le_of_tsum_le Ennreal.count_const_le_le_of_tsum_le

/-- Markov's inequality for counting measure with hypothesis using `tsum` in `ℝ≥0`. -/
theorem Nnreal.count_const_le_le_of_tsum_le [MeasurableSingletonClass α] {a : α → ℝ≥0}
    (a_mble : Measurable a) (a_summable : Summable a) {c : ℝ≥0} (tsum_le_c : (∑' i, a i) ≤ c)
    {ε : ℝ≥0} (ε_ne_zero : ε ≠ 0) : Measure.count { i : α | ε ≤ a i } ≤ c / ε :=
  by
  rw [show (fun i => ε ≤ a i) = fun i => (ε : ℝ≥0∞) ≤ (coe ∘ a) i
      by
      funext i
      simp only [Ennreal.coe_le_coe]]
  apply
    Ennreal.count_const_le_le_of_tsum_le (measurable_coe_nnreal_ennreal.comp a_mble) _
      (by exact_mod_cast ε_ne_zero) (@Ennreal.coe_ne_top ε)
  convert ennreal.coe_le_coe.mpr tsum_le_c
  rw [Ennreal.tsum_coe_eq a_summable.has_sum]
#align nnreal.count_const_le_le_of_tsum_le Nnreal.count_const_le_le_of_tsum_le

end DiracAndCount

section Countable

/-!
### Lebesgue integral over finite and countable types and sets
-/


theorem lintegral_countable' [Countable α] [MeasurableSingletonClass α] (f : α → ℝ≥0∞) :
    (∫⁻ a, f a ∂μ) = ∑' a, f a * μ {a} :=
  by
  conv_lhs => rw [← sum_smul_dirac μ, lintegral_sum_measure]
  congr 1 with a : 1
  rw [lintegral_smul_measure, lintegral_dirac, mul_comm]
#align measure_theory.lintegral_countable' MeasureTheory.lintegral_countable'

theorem lintegral_singleton' {f : α → ℝ≥0∞} (hf : Measurable f) (a : α) :
    (∫⁻ x in {a}, f x ∂μ) = f a * μ {a} := by
  simp only [restrict_singleton, lintegral_smul_measure, lintegral_dirac' _ hf, mul_comm]
#align measure_theory.lintegral_singleton' MeasureTheory.lintegral_singleton'

theorem lintegral_singleton [MeasurableSingletonClass α] (f : α → ℝ≥0∞) (a : α) :
    (∫⁻ x in {a}, f x ∂μ) = f a * μ {a} := by
  simp only [restrict_singleton, lintegral_smul_measure, lintegral_dirac, mul_comm]
#align measure_theory.lintegral_singleton MeasureTheory.lintegral_singleton

theorem lintegral_countable [MeasurableSingletonClass α] (f : α → ℝ≥0∞) {s : Set α}
    (hs : s.Countable) : (∫⁻ a in s, f a ∂μ) = ∑' a : s, f a * μ {(a : α)} :=
  calc
    (∫⁻ a in s, f a ∂μ) = ∫⁻ a in ⋃ x ∈ s, {x}, f a ∂μ := by rw [bUnion_of_singleton]
    _ = ∑' a : s, ∫⁻ x in {a}, f x ∂μ :=
      lintegral_bUnion hs (fun _ _ => measurable_set_singleton _) (pairwise_disjoint_fiber id s) _
    _ = ∑' a : s, f a * μ {(a : α)} := by simp only [lintegral_singleton]
    
#align measure_theory.lintegral_countable MeasureTheory.lintegral_countable

theorem lintegral_insert [MeasurableSingletonClass α] {a : α} {s : Set α} (h : a ∉ s)
    (f : α → ℝ≥0∞) : (∫⁻ x in insert a s, f x ∂μ) = f a * μ {a} + ∫⁻ x in s, f x ∂μ :=
  by
  rw [← union_singleton, lintegral_union (measurable_set_singleton a), lintegral_singleton,
    add_comm]
  rwa [disjoint_singleton_right]
#align measure_theory.lintegral_insert MeasureTheory.lintegral_insert

theorem lintegral_finset [MeasurableSingletonClass α] (s : Finset α) (f : α → ℝ≥0∞) :
    (∫⁻ x in s, f x ∂μ) = ∑ x in s, f x * μ {x} := by
  simp only [lintegral_countable _ s.countable_to_set, ← s.tsum_subtype']
#align measure_theory.lintegral_finset MeasureTheory.lintegral_finset

theorem lintegral_fintype [MeasurableSingletonClass α] [Fintype α] (f : α → ℝ≥0∞) :
    (∫⁻ x, f x ∂μ) = ∑ x, f x * μ {x} := by
  rw [← lintegral_finset, Finset.coe_univ, measure.restrict_univ]
#align measure_theory.lintegral_fintype MeasureTheory.lintegral_fintype

theorem lintegral_unique [Unique α] (f : α → ℝ≥0∞) : (∫⁻ x, f x ∂μ) = f default * μ univ :=
  calc
    (∫⁻ x, f x ∂μ) = ∫⁻ x, f default ∂μ := lintegral_congr <| Unique.forall_iff.2 rfl
    _ = f default * μ univ := lintegral_const _
    
#align measure_theory.lintegral_unique MeasureTheory.lintegral_unique

end Countable

theorem ae_lt_top {f : α → ℝ≥0∞} (hf : Measurable f) (h2f : (∫⁻ x, f x ∂μ) ≠ ∞) :
    ∀ᵐ x ∂μ, f x < ∞ := by
  simp_rw [ae_iff, Ennreal.not_lt_top]
  by_contra h
  apply h2f.lt_top.not_le
  have : (f ⁻¹' {∞}).indicator ⊤ ≤ f := by
    intro x
    by_cases hx : x ∈ f ⁻¹' {∞} <;> [simpa [hx] , simp [hx]]
  convert lintegral_mono this
  rw [lintegral_indicator _ (hf (measurable_set_singleton ∞))]
  simp [Ennreal.top_mul, preimage, h]
#align measure_theory.ae_lt_top MeasureTheory.ae_lt_top

theorem ae_lt_top' {f : α → ℝ≥0∞} (hf : AeMeasurable f μ) (h2f : (∫⁻ x, f x ∂μ) ≠ ∞) :
    ∀ᵐ x ∂μ, f x < ∞ :=
  haveI h2f_meas : (∫⁻ x, hf.mk f x ∂μ) ≠ ∞ := by rwa [← lintegral_congr_ae hf.ae_eq_mk]
  (ae_lt_top hf.measurable_mk h2f_meas).mp (hf.ae_eq_mk.mono fun x hx h => by rwa [hx])
#align measure_theory.ae_lt_top' MeasureTheory.ae_lt_top'

theorem set_lintegral_lt_top_of_bdd_above {s : Set α} (hs : μ s ≠ ∞) {f : α → ℝ≥0}
    (hf : Measurable f) (hbdd : BddAbove (f '' s)) : (∫⁻ x in s, f x ∂μ) < ∞ :=
  by
  obtain ⟨M, hM⟩ := hbdd
  rw [mem_upperBounds] at hM
  refine'
    lt_of_le_of_lt (set_lintegral_mono hf.coe_nnreal_ennreal (@measurable_const _ _ _ _ ↑M) _) _
  · simpa using hM
  · rw [lintegral_const]
    refine' Ennreal.mul_lt_top ennreal.coe_lt_top.ne _
    simp [hs]
#align
  measure_theory.set_lintegral_lt_top_of_bdd_above MeasureTheory.set_lintegral_lt_top_of_bdd_above

theorem set_lintegral_lt_top_of_is_compact [TopologicalSpace α] [OpensMeasurableSpace α] {s : Set α}
    (hs : μ s ≠ ∞) (hsc : IsCompact s) {f : α → ℝ≥0} (hf : Continuous f) :
    (∫⁻ x in s, f x ∂μ) < ∞ :=
  set_lintegral_lt_top_of_bdd_above hs hf.Measurable (hsc.image hf).BddAbove
#align
  measure_theory.set_lintegral_lt_top_of_is_compact MeasureTheory.set_lintegral_lt_top_of_is_compact

theorem IsFiniteMeasure.lintegral_lt_top_of_bounded_to_ennreal {α : Type _} [MeasurableSpace α]
    (μ : Measure α) [μ_fin : IsFiniteMeasure μ] {f : α → ℝ≥0∞} (f_bdd : ∃ c : ℝ≥0, ∀ x, f x ≤ c) :
    (∫⁻ x, f x ∂μ) < ∞ := by
  cases' f_bdd with c hc
  apply lt_of_le_of_lt (@lintegral_mono _ _ μ _ _ hc)
  rw [lintegral_const]
  exact Ennreal.mul_lt_top ennreal.coe_lt_top.ne μ_fin.measure_univ_lt_top.ne
#align
  is_finite_measure.lintegral_lt_top_of_bounded_to_ennreal IsFiniteMeasure.lintegral_lt_top_of_bounded_to_ennreal

/-- Given a measure `μ : measure α` and a function `f : α → ℝ≥0∞`, `μ.with_density f` is the
measure such that for a measurable set `s` we have `μ.with_density f s = ∫⁻ a in s, f a ∂μ`. -/
def Measure.withDensity {m : MeasurableSpace α} (μ : Measure α) (f : α → ℝ≥0∞) : Measure α :=
  Measure.ofMeasurable (fun s hs => ∫⁻ a in s, f a ∂μ) (by simp) fun s hs hd =>
    lintegral_Union hs hd _
#align measure_theory.measure.with_density MeasureTheory.Measure.withDensity

@[simp]
theorem with_density_apply (f : α → ℝ≥0∞) {s : Set α} (hs : MeasurableSet s) :
    μ.withDensity f s = ∫⁻ a in s, f a ∂μ :=
  Measure.of_measurable_apply s hs
#align measure_theory.with_density_apply MeasureTheory.with_density_apply

theorem with_density_congr_ae {f g : α → ℝ≥0∞} (h : f =ᵐ[μ] g) :
    μ.withDensity f = μ.withDensity g :=
  by
  apply measure.ext fun s hs => _
  rw [with_density_apply _ hs, with_density_apply _ hs]
  exact lintegral_congr_ae (ae_restrict_of_ae h)
#align measure_theory.with_density_congr_ae MeasureTheory.with_density_congr_ae

theorem with_density_add_left {f : α → ℝ≥0∞} (hf : Measurable f) (g : α → ℝ≥0∞) :
    μ.withDensity (f + g) = μ.withDensity f + μ.withDensity g :=
  by
  refine' measure.ext fun s hs => _
  rw [with_density_apply _ hs, measure.add_apply, with_density_apply _ hs, with_density_apply _ hs,
    ← lintegral_add_left hf]
  rfl
#align measure_theory.with_density_add_left MeasureTheory.with_density_add_left

theorem with_density_add_right (f : α → ℝ≥0∞) {g : α → ℝ≥0∞} (hg : Measurable g) :
    μ.withDensity (f + g) = μ.withDensity f + μ.withDensity g := by
  simpa only [add_comm] using with_density_add_left hg f
#align measure_theory.with_density_add_right MeasureTheory.with_density_add_right

theorem with_density_smul (r : ℝ≥0∞) {f : α → ℝ≥0∞} (hf : Measurable f) :
    μ.withDensity (r • f) = r • μ.withDensity f :=
  by
  refine' measure.ext fun s hs => _
  rw [with_density_apply _ hs, measure.coe_smul, Pi.smul_apply, with_density_apply _ hs,
    smul_eq_mul, ← lintegral_const_mul r hf]
  rfl
#align measure_theory.with_density_smul MeasureTheory.with_density_smul

theorem with_density_smul' (r : ℝ≥0∞) (f : α → ℝ≥0∞) (hr : r ≠ ∞) :
    μ.withDensity (r • f) = r • μ.withDensity f :=
  by
  refine' measure.ext fun s hs => _
  rw [with_density_apply _ hs, measure.coe_smul, Pi.smul_apply, with_density_apply _ hs,
    smul_eq_mul, ← lintegral_const_mul' r f hr]
  rfl
#align measure_theory.with_density_smul' MeasureTheory.with_density_smul'

theorem isFiniteMeasureWithDensity {f : α → ℝ≥0∞} (hf : (∫⁻ a, f a ∂μ) ≠ ∞) :
    IsFiniteMeasure (μ.withDensity f) :=
  {
    measure_univ_lt_top := by
      rwa [with_density_apply _ MeasurableSet.univ, measure.restrict_univ, lt_top_iff_ne_top] }
#align measure_theory.is_finite_measure_with_density MeasureTheory.isFiniteMeasureWithDensity

theorem withDensityAbsolutelyContinuous {m : MeasurableSpace α} (μ : Measure α) (f : α → ℝ≥0∞) :
    μ.withDensity f ≪ μ :=
  by
  refine' absolutely_continuous.mk fun s hs₁ hs₂ => _
  rw [with_density_apply _ hs₁]
  exact set_lintegral_measure_zero _ _ hs₂
#align
  measure_theory.with_density_absolutely_continuous MeasureTheory.withDensityAbsolutelyContinuous

@[simp]
theorem with_density_zero : μ.withDensity 0 = 0 :=
  by
  ext1 s hs
  simp [with_density_apply _ hs]
#align measure_theory.with_density_zero MeasureTheory.with_density_zero

@[simp]
theorem with_density_one : μ.withDensity 1 = μ :=
  by
  ext1 s hs
  simp [with_density_apply _ hs]
#align measure_theory.with_density_one MeasureTheory.with_density_one

theorem with_density_tsum {f : ℕ → α → ℝ≥0∞} (h : ∀ i, Measurable (f i)) :
    μ.withDensity (∑' n, f n) = Sum fun n => μ.withDensity (f n) :=
  by
  ext1 s hs
  simp_rw [sum_apply _ hs, with_density_apply _ hs]
  change (∫⁻ x in s, (∑' n, f n) x ∂μ) = ∑' i : ℕ, ∫⁻ x, f i x ∂μ.restrict s
  rw [← lintegral_tsum fun i => (h i).AeMeasurable]
  refine' lintegral_congr fun x => tsum_apply (Pi.summable.2 fun _ => Ennreal.summable)
#align measure_theory.with_density_tsum MeasureTheory.with_density_tsum

theorem with_density_indicator {s : Set α} (hs : MeasurableSet s) (f : α → ℝ≥0∞) :
    μ.withDensity (s.indicator f) = (μ.restrict s).withDensity f :=
  by
  ext1 t ht
  rw [with_density_apply _ ht, lintegral_indicator _ hs, restrict_comm hs, ←
    with_density_apply _ ht]
#align measure_theory.with_density_indicator MeasureTheory.with_density_indicator

theorem with_density_indicator_one {s : Set α} (hs : MeasurableSet s) :
    μ.withDensity (s.indicator 1) = μ.restrict s := by
  rw [with_density_indicator hs, with_density_one]
#align measure_theory.with_density_indicator_one MeasureTheory.with_density_indicator_one

theorem withDensityOfRealMutuallySingular {f : α → ℝ} (hf : Measurable f) :
    (μ.withDensity fun x => Ennreal.ofReal <| f x) ⊥ₘ
      μ.withDensity fun x => Ennreal.ofReal <| -f x :=
  by
  set S : Set α := { x | f x < 0 } with hSdef
  have hS : MeasurableSet S := measurable_set_lt hf measurable_const
  refine' ⟨S, hS, _, _⟩
  · rw [with_density_apply _ hS, lintegral_eq_zero_iff hf.ennreal_of_real, eventually_eq]
    exact (ae_restrict_mem hS).mono fun x hx => Ennreal.of_real_eq_zero.2 (le_of_lt hx)
  · rw [with_density_apply _ hS.compl, lintegral_eq_zero_iff hf.neg.ennreal_of_real, eventually_eq]
    exact
      (ae_restrict_mem hS.compl).mono fun x hx =>
        Ennreal.of_real_eq_zero.2 (not_lt.1 <| mt neg_pos.1 hx)
#align
  measure_theory.with_density_of_real_mutually_singular MeasureTheory.withDensityOfRealMutuallySingular

theorem restrict_with_density {s : Set α} (hs : MeasurableSet s) (f : α → ℝ≥0∞) :
    (μ.withDensity f).restrict s = (μ.restrict s).withDensity f :=
  by
  ext1 t ht
  rw [restrict_apply ht, with_density_apply _ ht, with_density_apply _ (ht.inter hs),
    restrict_restrict ht]
#align measure_theory.restrict_with_density MeasureTheory.restrict_with_density

theorem with_density_eq_zero {f : α → ℝ≥0∞} (hf : AeMeasurable f μ) (h : μ.withDensity f = 0) :
    f =ᵐ[μ] 0 := by
  rw [← lintegral_eq_zero_iff' hf, ← set_lintegral_univ, ← with_density_apply _ MeasurableSet.univ,
    h, measure.coe_zero, Pi.zero_apply]
#align measure_theory.with_density_eq_zero MeasureTheory.with_density_eq_zero

theorem with_density_apply_eq_zero {f : α → ℝ≥0∞} {s : Set α} (hf : Measurable f) :
    μ.withDensity f s = 0 ↔ μ ({ x | f x ≠ 0 } ∩ s) = 0 :=
  by
  constructor
  · intro hs
    let t := to_measurable (μ.with_density f) s
    apply measure_mono_null (inter_subset_inter_right _ (subset_to_measurable (μ.with_density f) s))
    have A : μ.with_density f t = 0 := by rw [measure_to_measurable, hs]
    rw [with_density_apply f (measurable_set_to_measurable _ s), lintegral_eq_zero_iff hf,
      eventually_eq, ae_restrict_iff, ae_iff] at A
    swap
    · exact hf (measurable_set_singleton 0)
    simp only [Pi.zero_apply, mem_set_of_eq, Filter.mem_mk] at A
    convert A
    ext x
    simp only [and_comm', exists_prop, mem_inter_iff, iff_self_iff, mem_set_of_eq, mem_compl_iff,
      not_forall]
  · intro hs
    let t := to_measurable μ ({ x | f x ≠ 0 } ∩ s)
    have A : s ⊆ t ∪ { x | f x = 0 } := by
      intro x hx
      rcases eq_or_ne (f x) 0 with (fx | fx)
      · simp only [fx, mem_union, mem_set_of_eq, eq_self_iff_true, or_true_iff]
      · left
        apply subset_to_measurable _ _
        exact ⟨fx, hx⟩
    apply measure_mono_null A (measure_union_null _ _)
    · apply with_density_absolutely_continuous
      rwa [measure_to_measurable]
    · have M : MeasurableSet { x : α | f x = 0 } := hf (measurable_set_singleton _)
      rw [with_density_apply _ M, lintegral_eq_zero_iff hf]
      filter_upwards [ae_restrict_mem M]
      simp only [imp_self, Pi.zero_apply, imp_true_iff]
#align measure_theory.with_density_apply_eq_zero MeasureTheory.with_density_apply_eq_zero

theorem ae_with_density_iff {p : α → Prop} {f : α → ℝ≥0∞} (hf : Measurable f) :
    (∀ᵐ x ∂μ.withDensity f, p x) ↔ ∀ᵐ x ∂μ, f x ≠ 0 → p x :=
  by
  rw [ae_iff, ae_iff, with_density_apply_eq_zero hf]
  congr
  ext x
  simp only [exists_prop, mem_inter_iff, iff_self_iff, mem_set_of_eq, not_forall]
#align measure_theory.ae_with_density_iff MeasureTheory.ae_with_density_iff

theorem ae_with_density_iff_ae_restrict {p : α → Prop} {f : α → ℝ≥0∞} (hf : Measurable f) :
    (∀ᵐ x ∂μ.withDensity f, p x) ↔ ∀ᵐ x ∂μ.restrict { x | f x ≠ 0 }, p x :=
  by
  rw [ae_with_density_iff hf, ae_restrict_iff']
  · rfl
  · exact hf (measurable_set_singleton 0).compl
#align measure_theory.ae_with_density_iff_ae_restrict MeasureTheory.ae_with_density_iff_ae_restrict

theorem ae_measurable_with_density_iff {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [TopologicalSpace.SecondCountableTopology E] [MeasurableSpace E] [BorelSpace E] {f : α → ℝ≥0}
    (hf : Measurable f) {g : α → E} :
    AeMeasurable g (μ.withDensity fun x => (f x : ℝ≥0∞)) ↔
      AeMeasurable (fun x => (f x : ℝ) • g x) μ :=
  by
  constructor
  · rintro ⟨g', g'meas, hg'⟩
    have A : MeasurableSet { x : α | f x ≠ 0 } := (hf (measurable_set_singleton 0)).compl
    refine' ⟨fun x => (f x : ℝ) • g' x, hf.coe_nnreal_real.smul g'meas, _⟩
    apply @ae_of_ae_restrict_of_ae_restrict_compl _ _ _ { x | f x ≠ 0 }
    · rw [eventually_eq, ae_with_density_iff hf.coe_nnreal_ennreal] at hg'
      rw [ae_restrict_iff' A]
      filter_upwards [hg']
      intro a ha h'a
      have : (f a : ℝ≥0∞) ≠ 0 := by simpa only [Ne.def, coe_eq_zero] using h'a
      rw [ha this]
    · filter_upwards [ae_restrict_mem A.compl]
      intro x hx
      simp only [not_not, mem_set_of_eq, mem_compl_iff] at hx
      simp [hx]
  · rintro ⟨g', g'meas, hg'⟩
    refine' ⟨fun x => (f x : ℝ)⁻¹ • g' x, hf.coe_nnreal_real.inv.smul g'meas, _⟩
    rw [eventually_eq, ae_with_density_iff hf.coe_nnreal_ennreal]
    filter_upwards [hg']
    intro x hx h'x
    rw [← hx, smul_smul, _root_.inv_mul_cancel, one_smul]
    simp only [Ne.def, coe_eq_zero] at h'x
    simpa only [Nnreal.coe_eq_zero, Ne.def] using h'x
#align measure_theory.ae_measurable_with_density_iff MeasureTheory.ae_measurable_with_density_iff

theorem ae_measurable_with_density_ennreal_iff {f : α → ℝ≥0} (hf : Measurable f) {g : α → ℝ≥0∞} :
    AeMeasurable g (μ.withDensity fun x => (f x : ℝ≥0∞)) ↔
      AeMeasurable (fun x => (f x : ℝ≥0∞) * g x) μ :=
  by
  constructor
  · rintro ⟨g', g'meas, hg'⟩
    have A : MeasurableSet { x : α | f x ≠ 0 } := (hf (measurable_set_singleton 0)).compl
    refine' ⟨fun x => f x * g' x, hf.coe_nnreal_ennreal.smul g'meas, _⟩
    apply ae_of_ae_restrict_of_ae_restrict_compl { x | f x ≠ 0 }
    · rw [eventually_eq, ae_with_density_iff hf.coe_nnreal_ennreal] at hg'
      rw [ae_restrict_iff' A]
      filter_upwards [hg']
      intro a ha h'a
      have : (f a : ℝ≥0∞) ≠ 0 := by simpa only [Ne.def, coe_eq_zero] using h'a
      rw [ha this]
    · filter_upwards [ae_restrict_mem A.compl]
      intro x hx
      simp only [not_not, mem_set_of_eq, mem_compl_iff] at hx
      simp [hx]
  · rintro ⟨g', g'meas, hg'⟩
    refine' ⟨fun x => (f x)⁻¹ * g' x, hf.coe_nnreal_ennreal.inv.smul g'meas, _⟩
    rw [eventually_eq, ae_with_density_iff hf.coe_nnreal_ennreal]
    filter_upwards [hg']
    intro x hx h'x
    rw [← hx, ← mul_assoc, Ennreal.inv_mul_cancel h'x Ennreal.coe_ne_top, one_mul]
#align
  measure_theory.ae_measurable_with_density_ennreal_iff MeasureTheory.ae_measurable_with_density_ennreal_iff

end Lintegral

end MeasureTheory

open MeasureTheory MeasureTheory.SimpleFunc

/-- To prove something for an arbitrary measurable function into `ℝ≥0∞`, it suffices to show
that the property holds for (multiples of) characteristic functions and is closed under addition
and supremum of increasing sequences of functions.

It is possible to make the hypotheses in the induction steps a bit stronger, and such conditions
can be added once we need them (for example in `h_add` it is only necessary to consider the sum of
a simple function with a multiple of a characteristic function and that the intersection
of their images is a subset of `{0}`. -/
@[elab_as_elim]
theorem Measurable.ennreal_induction {α} [MeasurableSpace α] {P : (α → ℝ≥0∞) → Prop}
    (h_ind : ∀ (c : ℝ≥0∞) ⦃s⦄, MeasurableSet s → P (indicator s fun _ => c))
    (h_add :
      ∀ ⦃f g : α → ℝ≥0∞⦄,
        Disjoint (support f) (support g) → Measurable f → Measurable g → P f → P g → P (f + g))
    (h_supr :
      ∀ ⦃f : ℕ → α → ℝ≥0∞⦄ (hf : ∀ n, Measurable (f n)) (h_mono : Monotone f) (hP : ∀ n, P (f n)),
        P fun x => ⨆ n, f n x)
    ⦃f : α → ℝ≥0∞⦄ (hf : Measurable f) : P f :=
  by
  convert h_supr (fun n => (eapprox f n).Measurable) (monotone_eapprox f) _
  · ext1 x
    rw [supr_eapprox_apply f hf]
  ·
    exact fun n =>
      simple_func.induction (fun c s hs => h_ind c hs)
        (fun f g hfg hf hg => h_add hfg f.Measurable g.Measurable hf hg) (eapprox f n)
#align measurable.ennreal_induction Measurable.ennreal_induction

namespace MeasureTheory

variable {α : Type _} {m m0 : MeasurableSpace α}

include m

/-- This is Exercise 1.2.1 from [tao2010]. It allows you to express integration of a measurable
function with respect to `(μ.with_density f)` as an integral with respect to `μ`, called the base
measure. `μ` is often the Lebesgue measure, and in this circumstance `f` is the probability density
function, and `(μ.with_density f)` represents any continuous random variable as a
probability measure, such as the uniform distribution between 0 and 1, the Gaussian distribution,
the exponential distribution, the Beta distribution, or the Cauchy distribution (see Section 2.4
of [wasserman2004]). Thus, this method shows how to one can calculate expectations, variances,
and other moments as a function of the probability density function.
 -/
theorem lintegral_with_density_eq_lintegral_mul (μ : Measure α) {f : α → ℝ≥0∞}
    (h_mf : Measurable f) :
    ∀ {g : α → ℝ≥0∞}, Measurable g → (∫⁻ a, g a ∂μ.withDensity f) = ∫⁻ a, (f * g) a ∂μ :=
  by
  apply Measurable.ennreal_induction
  · intro c s h_ms
    simp [*, mul_comm _ c, ← indicator_mul_right]
  · intro g h h_univ h_mea_g h_mea_h h_ind_g h_ind_h
    simp [mul_add, *, Measurable.mul]
  · intro g h_mea_g h_mono_g h_ind
    have : Monotone fun n a => f a * g n a := fun m n hmn x =>
      Ennreal.mul_le_mul le_rfl (h_mono_g hmn x)
    simp [lintegral_supr, Ennreal.mul_supr, h_mf.mul (h_mea_g _), *]
#align
  measure_theory.lintegral_with_density_eq_lintegral_mul MeasureTheory.lintegral_with_density_eq_lintegral_mul

theorem set_lintegral_with_density_eq_set_lintegral_mul (μ : Measure α) {f g : α → ℝ≥0∞}
    (hf : Measurable f) (hg : Measurable g) {s : Set α} (hs : MeasurableSet s) :
    (∫⁻ x in s, g x ∂μ.withDensity f) = ∫⁻ x in s, (f * g) x ∂μ := by
  rw [restrict_with_density hs, lintegral_with_density_eq_lintegral_mul _ hf hg]
#align
  measure_theory.set_lintegral_with_density_eq_set_lintegral_mul MeasureTheory.set_lintegral_with_density_eq_set_lintegral_mul

/-- The Lebesgue integral of `g` with respect to the measure `μ.with_density f` coincides with
the integral of `f * g`. This version assumes that `g` is almost everywhere measurable. For a
version without conditions on `g` but requiring that `f` is almost everywhere finite, see
`lintegral_with_density_eq_lintegral_mul_non_measurable` -/
theorem lintegral_with_density_eq_lintegral_mul₀' {μ : Measure α} {f : α → ℝ≥0∞}
    (hf : AeMeasurable f μ) {g : α → ℝ≥0∞} (hg : AeMeasurable g (μ.withDensity f)) :
    (∫⁻ a, g a ∂μ.withDensity f) = ∫⁻ a, (f * g) a ∂μ :=
  by
  let f' := hf.mk f
  have : μ.with_density f = μ.with_density f' := with_density_congr_ae hf.ae_eq_mk
  rw [this] at hg⊢
  let g' := hg.mk g
  calc
    (∫⁻ a, g a ∂μ.with_density f') = ∫⁻ a, g' a ∂μ.with_density f' := lintegral_congr_ae hg.ae_eq_mk
    _ = ∫⁻ a, (f' * g') a ∂μ :=
      lintegral_with_density_eq_lintegral_mul _ hf.measurable_mk hg.measurable_mk
    _ = ∫⁻ a, (f' * g) a ∂μ := by
      apply lintegral_congr_ae
      apply ae_of_ae_restrict_of_ae_restrict_compl { x | f' x ≠ 0 }
      · have Z := hg.ae_eq_mk
        rw [eventually_eq, ae_with_density_iff_ae_restrict hf.measurable_mk] at Z
        filter_upwards [Z]
        intro x hx
        simp only [hx, Pi.mul_apply]
      · have M : MeasurableSet ({ x : α | f' x ≠ 0 }ᶜ) :=
          (hf.measurable_mk (measurable_set_singleton 0).compl).compl
        filter_upwards [ae_restrict_mem M]
        intro x hx
        simp only [not_not, mem_set_of_eq, mem_compl_iff] at hx
        simp only [hx, zero_mul, Pi.mul_apply]
    _ = ∫⁻ a : α, (f * g) a ∂μ := by
      apply lintegral_congr_ae
      filter_upwards [hf.ae_eq_mk]
      intro x hx
      simp only [hx, Pi.mul_apply]
    
#align
  measure_theory.lintegral_with_density_eq_lintegral_mul₀' MeasureTheory.lintegral_with_density_eq_lintegral_mul₀'

theorem lintegral_with_density_eq_lintegral_mul₀ {μ : Measure α} {f : α → ℝ≥0∞}
    (hf : AeMeasurable f μ) {g : α → ℝ≥0∞} (hg : AeMeasurable g μ) :
    (∫⁻ a, g a ∂μ.withDensity f) = ∫⁻ a, (f * g) a ∂μ :=
  lintegral_with_density_eq_lintegral_mul₀' hf (hg.mono' (withDensityAbsolutelyContinuous μ f))
#align
  measure_theory.lintegral_with_density_eq_lintegral_mul₀ MeasureTheory.lintegral_with_density_eq_lintegral_mul₀

theorem lintegral_with_density_le_lintegral_mul (μ : Measure α) {f : α → ℝ≥0∞}
    (f_meas : Measurable f) (g : α → ℝ≥0∞) : (∫⁻ a, g a ∂μ.withDensity f) ≤ ∫⁻ a, (f * g) a ∂μ :=
  by
  rw [← supr_lintegral_measurable_le_eq_lintegral, ← supr_lintegral_measurable_le_eq_lintegral]
  refine' supᵢ₂_le fun i i_meas => supᵢ_le fun hi => _
  have A : f * i ≤ f * g := fun x => Ennreal.mul_le_mul le_rfl (hi x)
  refine' le_supᵢ₂_of_le (f * i) (f_meas.mul i_meas) _
  exact le_supᵢ_of_le A (le_of_eq (lintegral_with_density_eq_lintegral_mul _ f_meas i_meas))
#align
  measure_theory.lintegral_with_density_le_lintegral_mul MeasureTheory.lintegral_with_density_le_lintegral_mul

theorem lintegral_with_density_eq_lintegral_mul_non_measurable (μ : Measure α) {f : α → ℝ≥0∞}
    (f_meas : Measurable f) (hf : ∀ᵐ x ∂μ, f x < ∞) (g : α → ℝ≥0∞) :
    (∫⁻ a, g a ∂μ.withDensity f) = ∫⁻ a, (f * g) a ∂μ :=
  by
  refine' le_antisymm (lintegral_with_density_le_lintegral_mul μ f_meas g) _
  rw [← supr_lintegral_measurable_le_eq_lintegral, ← supr_lintegral_measurable_le_eq_lintegral]
  refine' supᵢ₂_le fun i i_meas => supᵢ_le fun hi => _
  have A : (fun x => (f x)⁻¹ * i x) ≤ g := by
    intro x
    dsimp
    rw [mul_comm, ← div_eq_mul_inv]
    exact div_le_of_le_mul' (hi x)
  refine' le_supᵢ_of_le (fun x => (f x)⁻¹ * i x) (le_supᵢ_of_le (f_meas.inv.mul i_meas) _)
  refine' le_supᵢ_of_le A _
  rw [lintegral_with_density_eq_lintegral_mul _ f_meas (f_meas.inv.mul i_meas)]
  apply lintegral_mono_ae
  filter_upwards [hf]
  intro x h'x
  rcases eq_or_ne (f x) 0 with (hx | hx)
  · have := hi x
    simp only [hx, zero_mul, Pi.mul_apply, nonpos_iff_eq_zero] at this
    simp [this]
  · apply le_of_eq _
    dsimp
    rw [← mul_assoc, Ennreal.mul_inv_cancel hx h'x.ne, one_mul]
#align
  measure_theory.lintegral_with_density_eq_lintegral_mul_non_measurable MeasureTheory.lintegral_with_density_eq_lintegral_mul_non_measurable

theorem set_lintegral_with_density_eq_set_lintegral_mul_non_measurable (μ : Measure α)
    {f : α → ℝ≥0∞} (f_meas : Measurable f) (g : α → ℝ≥0∞) {s : Set α} (hs : MeasurableSet s)
    (hf : ∀ᵐ x ∂μ.restrict s, f x < ∞) :
    (∫⁻ a in s, g a ∂μ.withDensity f) = ∫⁻ a in s, (f * g) a ∂μ := by
  rw [restrict_with_density hs, lintegral_with_density_eq_lintegral_mul_non_measurable _ f_meas hf]
#align
  measure_theory.set_lintegral_with_density_eq_set_lintegral_mul_non_measurable MeasureTheory.set_lintegral_with_density_eq_set_lintegral_mul_non_measurable

theorem lintegral_with_density_eq_lintegral_mul_non_measurable₀ (μ : Measure α) {f : α → ℝ≥0∞}
    (hf : AeMeasurable f μ) (h'f : ∀ᵐ x ∂μ, f x < ∞) (g : α → ℝ≥0∞) :
    (∫⁻ a, g a ∂μ.withDensity f) = ∫⁻ a, (f * g) a ∂μ :=
  by
  let f' := hf.mk f
  calc
    (∫⁻ a, g a ∂μ.with_density f) = ∫⁻ a, g a ∂μ.with_density f' := by
      rw [with_density_congr_ae hf.ae_eq_mk]
    _ = ∫⁻ a, (f' * g) a ∂μ :=
      by
      apply lintegral_with_density_eq_lintegral_mul_non_measurable _ hf.measurable_mk
      filter_upwards [h'f, hf.ae_eq_mk]
      intro x hx h'x
      rwa [← h'x]
    _ = ∫⁻ a, (f * g) a ∂μ := by
      apply lintegral_congr_ae
      filter_upwards [hf.ae_eq_mk]
      intro x hx
      simp only [hx, Pi.mul_apply]
    
#align
  measure_theory.lintegral_with_density_eq_lintegral_mul_non_measurable₀ MeasureTheory.lintegral_with_density_eq_lintegral_mul_non_measurable₀

theorem set_lintegral_with_density_eq_set_lintegral_mul_non_measurable₀ (μ : Measure α)
    {f : α → ℝ≥0∞} {s : Set α} (hf : AeMeasurable f (μ.restrict s)) (g : α → ℝ≥0∞)
    (hs : MeasurableSet s) (h'f : ∀ᵐ x ∂μ.restrict s, f x < ∞) :
    (∫⁻ a in s, g a ∂μ.withDensity f) = ∫⁻ a in s, (f * g) a ∂μ := by
  rw [restrict_with_density hs, lintegral_with_density_eq_lintegral_mul_non_measurable₀ _ hf h'f]
#align
  measure_theory.set_lintegral_with_density_eq_set_lintegral_mul_non_measurable₀ MeasureTheory.set_lintegral_with_density_eq_set_lintegral_mul_non_measurable₀

theorem with_density_mul (μ : Measure α) {f g : α → ℝ≥0∞} (hf : Measurable f) (hg : Measurable g) :
    μ.withDensity (f * g) = (μ.withDensity f).withDensity g :=
  by
  ext1 s hs
  simp [with_density_apply _ hs, restrict_with_density hs,
    lintegral_with_density_eq_lintegral_mul _ hf hg]
#align measure_theory.with_density_mul MeasureTheory.with_density_mul

/-- In a sigma-finite measure space, there exists an integrable function which is
positive everywhere (and with an arbitrarily small integral). -/
theorem exists_pos_lintegral_lt_of_sigma_finite (μ : Measure α) [SigmaFinite μ] {ε : ℝ≥0∞}
    (ε0 : ε ≠ 0) : ∃ g : α → ℝ≥0, (∀ x, 0 < g x) ∧ Measurable g ∧ (∫⁻ x, g x ∂μ) < ε :=
  by
  /- Let `s` be a covering of `α` by pairwise disjoint measurable sets of finite measure. Let
    `δ : ℕ → ℝ≥0` be a positive function such that `∑' i, μ (s i) * δ i < ε`. Then the function that
     is equal to `δ n` on `s n` is a positive function with integral less than `ε`. -/
  set s : ℕ → Set α := disjointed (spanning_sets μ)
  have : ∀ n, μ (s n) < ∞ := fun n =>
    (measure_mono <| disjointed_subset _ _).trans_lt (measure_spanning_sets_lt_top μ n)
  obtain ⟨δ, δpos, δsum⟩ : ∃ δ : ℕ → ℝ≥0, (∀ i, 0 < δ i) ∧ (∑' i, μ (s i) * δ i) < ε
  exact Ennreal.exists_pos_tsum_mul_lt_of_countable ε0 _ fun n => (this n).Ne
  set N : α → ℕ := spanning_sets_index μ
  have hN_meas : Measurable N := measurable_spanning_sets_index μ
  have hNs : ∀ n, N ⁻¹' {n} = s n := preimage_spanning_sets_index_singleton μ
  refine' ⟨δ ∘ N, fun x => δpos _, measurable_from_nat.comp hN_meas, _⟩
  simpa [lintegral_comp measurable_from_nat.coe_nnreal_ennreal hN_meas, hNs, lintegral_countable',
    measurable_spanning_sets_index, mul_comm] using δsum
#align
  measure_theory.exists_pos_lintegral_lt_of_sigma_finite MeasureTheory.exists_pos_lintegral_lt_of_sigma_finite

theorem lintegral_trim {μ : Measure α} (hm : m ≤ m0) {f : α → ℝ≥0∞} (hf : measurable[m] f) :
    (∫⁻ a, f a ∂μ.trim hm) = ∫⁻ a, f a ∂μ :=
  by
  refine'
    @Measurable.ennreal_induction α m (fun f => (∫⁻ a, f a ∂μ.trim hm) = ∫⁻ a, f a ∂μ) _ _ _ f hf
  · intro c s hs
    rw [lintegral_indicator _ hs, lintegral_indicator _ (hm s hs), set_lintegral_const,
      set_lintegral_const]
    suffices h_trim_s : μ.trim hm s = μ s
    · rw [h_trim_s]
    exact trim_measurable_set_eq hm hs
  · intro f g hfg hf hg hf_prop hg_prop
    have h_m := lintegral_add_left hf g
    have h_m0 := lintegral_add_left (Measurable.mono hf hm le_rfl) g
    rwa [hf_prop, hg_prop, ← h_m0] at h_m
  · intro f hf hf_mono hf_prop
    rw [lintegral_supr hf hf_mono]
    rw [lintegral_supr (fun n => Measurable.mono (hf n) hm le_rfl) hf_mono]
    congr
    exact funext fun n => hf_prop n
#align measure_theory.lintegral_trim MeasureTheory.lintegral_trim

theorem lintegral_trim_ae {μ : Measure α} (hm : m ≤ m0) {f : α → ℝ≥0∞}
    (hf : AeMeasurable f (μ.trim hm)) : (∫⁻ a, f a ∂μ.trim hm) = ∫⁻ a, f a ∂μ := by
  rw [lintegral_congr_ae (ae_eq_of_ae_eq_trim hf.ae_eq_mk), lintegral_congr_ae hf.ae_eq_mk,
    lintegral_trim hm hf.measurable_mk]
#align measure_theory.lintegral_trim_ae MeasureTheory.lintegral_trim_ae

section SigmaFinite

variable {E : Type _} [NormedAddCommGroup E] [MeasurableSpace E] [OpensMeasurableSpace E]

theorem univ_le_of_forall_fin_meas_le {μ : Measure α} (hm : m ≤ m0) [SigmaFinite (μ.trim hm)]
    (C : ℝ≥0∞) {f : Set α → ℝ≥0∞} (hf : ∀ s, measurable_set[m] s → μ s ≠ ∞ → f s ≤ C)
    (h_F_lim :
      ∀ S : ℕ → Set α, (∀ n, measurable_set[m] (S n)) → Monotone S → f (⋃ n, S n) ≤ ⨆ n, f (S n)) :
    f univ ≤ C := by
  let S := @spanning_sets _ m (μ.trim hm) _
  have hS_mono : Monotone S := @monotone_spanning_sets _ m (μ.trim hm) _
  have hS_meas : ∀ n, measurable_set[m] (S n) := @measurable_spanning_sets _ m (μ.trim hm) _
  rw [← @Union_spanning_sets _ m (μ.trim hm)]
  refine' (h_F_lim S hS_meas hS_mono).trans _
  refine' supᵢ_le fun n => hf (S n) (hS_meas n) _
  exact ((le_trim hm).trans_lt (@measure_spanning_sets_lt_top _ m (μ.trim hm) _ n)).Ne
#align measure_theory.univ_le_of_forall_fin_meas_le MeasureTheory.univ_le_of_forall_fin_meas_le

/-- If the Lebesgue integral of a function is bounded by some constant on all sets with finite
measure in a sub-σ-algebra and the measure is σ-finite on that sub-σ-algebra, then the integral
over the whole space is bounded by that same constant. Version for a measurable function.
See `lintegral_le_of_forall_fin_meas_le'` for the more general `ae_measurable` version. -/
theorem lintegral_le_of_forall_fin_meas_le_of_measurable {μ : Measure α} (hm : m ≤ m0)
    [SigmaFinite (μ.trim hm)] (C : ℝ≥0∞) {f : α → ℝ≥0∞} (hf_meas : Measurable f)
    (hf : ∀ s, measurable_set[m] s → μ s ≠ ∞ → (∫⁻ x in s, f x ∂μ) ≤ C) : (∫⁻ x, f x ∂μ) ≤ C :=
  by
  have : (∫⁻ x in univ, f x ∂μ) = ∫⁻ x, f x ∂μ := by simp only [measure.restrict_univ]
  rw [← this]
  refine' univ_le_of_forall_fin_meas_le hm C hf fun S hS_meas hS_mono => _
  rw [← lintegral_indicator]
  swap
  · exact hm (⋃ n, S n) (@MeasurableSet.Union _ _ m _ _ hS_meas)
  have h_integral_indicator : (⨆ n, ∫⁻ x in S n, f x ∂μ) = ⨆ n, ∫⁻ x, (S n).indicator f x ∂μ :=
    by
    congr
    ext1 n
    rw [lintegral_indicator _ (hm _ (hS_meas n))]
  rw [h_integral_indicator, ← lintegral_supr]
  · refine' le_of_eq (lintegral_congr fun x => _)
    simp_rw [indicator_apply]
    by_cases hx_mem : x ∈ Union S
    · simp only [hx_mem, if_true]
      obtain ⟨n, hxn⟩ := mem_Union.mp hx_mem
      refine' le_antisymm (trans _ (le_supᵢ _ n)) (supᵢ_le fun i => _)
      · simp only [hxn, le_refl, if_true]
      · by_cases hxi : x ∈ S i <;> simp [hxi]
    · simp only [hx_mem, if_false]
      rw [mem_Union] at hx_mem
      push_neg  at hx_mem
      refine' le_antisymm (zero_le _) (supᵢ_le fun n => _)
      simp only [hx_mem n, if_false, nonpos_iff_eq_zero]
  · exact fun n => hf_meas.indicator (hm _ (hS_meas n))
  · intro n₁ n₂ hn₁₂ a
    simp_rw [indicator_apply]
    split_ifs
    · exact le_rfl
    · exact absurd (mem_of_mem_of_subset h (hS_mono hn₁₂)) h_1
    · exact zero_le _
    · exact le_rfl
#align
  measure_theory.lintegral_le_of_forall_fin_meas_le_of_measurable MeasureTheory.lintegral_le_of_forall_fin_meas_le_of_measurable

/-- If the Lebesgue integral of a function is bounded by some constant on all sets with finite
measure in a sub-σ-algebra and the measure is σ-finite on that sub-σ-algebra, then the integral
over the whole space is bounded by that same constant. -/
theorem lintegral_le_of_forall_fin_meas_le' {μ : Measure α} (hm : m ≤ m0) [SigmaFinite (μ.trim hm)]
    (C : ℝ≥0∞) {f : _ → ℝ≥0∞} (hf_meas : AeMeasurable f μ)
    (hf : ∀ s, measurable_set[m] s → μ s ≠ ∞ → (∫⁻ x in s, f x ∂μ) ≤ C) : (∫⁻ x, f x ∂μ) ≤ C :=
  by
  let f' := hf_meas.mk f
  have hf' : ∀ s, measurable_set[m] s → μ s ≠ ∞ → (∫⁻ x in s, f' x ∂μ) ≤ C :=
    by
    refine' fun s hs hμs => (le_of_eq _).trans (hf s hs hμs)
    refine' lintegral_congr_ae (ae_restrict_of_ae (hf_meas.ae_eq_mk.mono fun x hx => _))
    rw [hx]
  rw [lintegral_congr_ae hf_meas.ae_eq_mk]
  exact lintegral_le_of_forall_fin_meas_le_of_measurable hm C hf_meas.measurable_mk hf'
#align
  measure_theory.lintegral_le_of_forall_fin_meas_le' MeasureTheory.lintegral_le_of_forall_fin_meas_le'

omit m

/-- If the Lebesgue integral of a function is bounded by some constant on all sets with finite
measure and the measure is σ-finite, then the integral over the whole space is bounded by that same
constant. -/
theorem lintegral_le_of_forall_fin_meas_le [MeasurableSpace α] {μ : Measure α} [SigmaFinite μ]
    (C : ℝ≥0∞) {f : α → ℝ≥0∞} (hf_meas : AeMeasurable f μ)
    (hf : ∀ s, MeasurableSet s → μ s ≠ ∞ → (∫⁻ x in s, f x ∂μ) ≤ C) : (∫⁻ x, f x ∂μ) ≤ C :=
  @lintegral_le_of_forall_fin_meas_le' _ _ _ _ _ (by rwa [trim_eq_self]) C _ hf_meas hf
#align
  measure_theory.lintegral_le_of_forall_fin_meas_le MeasureTheory.lintegral_le_of_forall_fin_meas_le

-- mathport name: «expr →ₛ »
local infixr:25 " →ₛ " => SimpleFunc

theorem SimpleFunc.exists_lt_lintegral_simple_func_of_lt_lintegral {m : MeasurableSpace α}
    {μ : Measure α} [SigmaFinite μ] {f : α →ₛ ℝ≥0} {L : ℝ≥0∞} (hL : L < ∫⁻ x, f x ∂μ) :
    ∃ g : α →ₛ ℝ≥0, (∀ x, g x ≤ f x) ∧ (∫⁻ x, g x ∂μ) < ∞ ∧ L < ∫⁻ x, g x ∂μ :=
  by
  induction' f using MeasureTheory.SimpleFunc.induction with c s hs f₁ f₂ H h₁ h₂ generalizing L
  · simp only [hs, const_zero, coe_piecewise, coe_const, simple_func.coe_zero, univ_inter,
      piecewise_eq_indicator, lintegral_indicator, lintegral_const, measure.restrict_apply',
      coe_indicator, Function.const_apply] at hL
    have c_ne_zero : c ≠ 0 := by
      intro hc
      simpa only [hc, Ennreal.coe_zero, zero_mul, not_lt_zero] using hL
    have : L / c < μ s := by
      rwa [Ennreal.div_lt_iff, mul_comm]
      · simp only [c_ne_zero, Ne.def, coe_eq_zero, not_false_iff, true_or_iff]
      · simp only [Ne.def, coe_ne_top, not_false_iff, true_or_iff]
    obtain ⟨t, ht, ts, mut, t_top⟩ :
      ∃ t : Set α, MeasurableSet t ∧ t ⊆ s ∧ L / ↑c < μ t ∧ μ t < ∞ :=
      measure.exists_subset_measure_lt_top hs this
    refine' ⟨piecewise t ht (const α c) (const α 0), fun x => _, _, _⟩
    · apply indicator_le_indicator_of_subset ts fun x => _
      exact zero_le _
    ·
      simp only [ht, const_zero, coe_piecewise, coe_const, simple_func.coe_zero, univ_inter,
        piecewise_eq_indicator, coe_indicator, Function.const_apply, lintegral_indicator,
        lintegral_const, measure.restrict_apply', Ennreal.mul_lt_top Ennreal.coe_ne_top t_top.ne]
    · simp only [ht, const_zero, coe_piecewise, coe_const, simple_func.coe_zero,
        piecewise_eq_indicator, coe_indicator, Function.const_apply, lintegral_indicator,
        lintegral_const, measure.restrict_apply', univ_inter]
      rwa [mul_comm, ← Ennreal.div_lt_iff]
      · simp only [c_ne_zero, Ne.def, coe_eq_zero, not_false_iff, true_or_iff]
      · simp only [Ne.def, coe_ne_top, not_false_iff, true_or_iff]
  · replace hL : L < (∫⁻ x, f₁ x ∂μ) + ∫⁻ x, f₂ x ∂μ
    · rwa [← lintegral_add_left f₁.measurable.coe_nnreal_ennreal]
    by_cases hf₁ : (∫⁻ x, f₁ x ∂μ) = 0
    · simp only [hf₁, zero_add] at hL
      rcases h₂ hL with ⟨g, g_le, g_top, gL⟩
      refine' ⟨g, fun x => (g_le x).trans _, g_top, gL⟩
      simp only [simple_func.coe_add, Pi.add_apply, le_add_iff_nonneg_left, zero_le']
    by_cases hf₂ : (∫⁻ x, f₂ x ∂μ) = 0
    · simp only [hf₂, add_zero] at hL
      rcases h₁ hL with ⟨g, g_le, g_top, gL⟩
      refine' ⟨g, fun x => (g_le x).trans _, g_top, gL⟩
      simp only [simple_func.coe_add, Pi.add_apply, le_add_iff_nonneg_right, zero_le']
    obtain ⟨L₁, L₂, hL₁, hL₂, hL⟩ :
      ∃ L₁ L₂ : ℝ≥0∞, (L₁ < ∫⁻ x, f₁ x ∂μ) ∧ (L₂ < ∫⁻ x, f₂ x ∂μ) ∧ L < L₁ + L₂ :=
      Ennreal.exists_lt_add_of_lt_add hL hf₁ hf₂
    rcases h₁ hL₁ with ⟨g₁, g₁_le, g₁_top, hg₁⟩
    rcases h₂ hL₂ with ⟨g₂, g₂_le, g₂_top, hg₂⟩
    refine' ⟨g₁ + g₂, fun x => add_le_add (g₁_le x) (g₂_le x), _, _⟩
    · apply lt_of_le_of_lt _ (add_lt_top.2 ⟨g₁_top, g₂_top⟩)
      rw [← lintegral_add_left g₁.measurable.coe_nnreal_ennreal]
      exact le_rfl
    · apply hL.trans ((Ennreal.add_lt_add hg₁ hg₂).trans_le _)
      rw [← lintegral_add_left g₁.measurable.coe_nnreal_ennreal]
      exact le_rfl
#align
  measure_theory.simple_func.exists_lt_lintegral_simple_func_of_lt_lintegral MeasureTheory.SimpleFunc.exists_lt_lintegral_simple_func_of_lt_lintegral

theorem exists_lt_lintegral_simple_func_of_lt_lintegral {m : MeasurableSpace α} {μ : Measure α}
    [SigmaFinite μ] {f : α → ℝ≥0} {L : ℝ≥0∞} (hL : L < ∫⁻ x, f x ∂μ) :
    ∃ g : α →ₛ ℝ≥0, (∀ x, g x ≤ f x) ∧ (∫⁻ x, g x ∂μ) < ∞ ∧ L < ∫⁻ x, g x ∂μ :=
  by
  simp_rw [lintegral_eq_nnreal, lt_supᵢ_iff] at hL
  rcases hL with ⟨g₀, hg₀, g₀L⟩
  have h'L : L < ∫⁻ x, g₀ x ∂μ := by
    convert g₀L
    rw [← simple_func.lintegral_eq_lintegral]
    rfl
  rcases simple_func.exists_lt_lintegral_simple_func_of_lt_lintegral h'L with ⟨g, hg, gL, gtop⟩
  exact ⟨g, fun x => (hg x).trans (coe_le_coe.1 (hg₀ x)), gL, gtop⟩
#align
  measure_theory.exists_lt_lintegral_simple_func_of_lt_lintegral MeasureTheory.exists_lt_lintegral_simple_func_of_lt_lintegral

/-- A sigma-finite measure is absolutely continuous with respect to some finite measure. -/
theorem exists_absolutely_continuous_is_finite_measure {m : MeasurableSpace α} (μ : Measure α)
    [SigmaFinite μ] : ∃ ν : Measure α, IsFiniteMeasure ν ∧ μ ≪ ν :=
  by
  obtain ⟨g, gpos, gmeas, hg⟩ :
    ∃ g : α → ℝ≥0, (∀ x : α, 0 < g x) ∧ Measurable g ∧ (∫⁻ x : α, ↑(g x) ∂μ) < 1 :=
    exists_pos_lintegral_lt_of_sigma_finite μ Ennreal.zero_lt_one.ne'
  refine' ⟨μ.with_density fun x => g x, is_finite_measure_with_density hg.ne_top, _⟩
  have : μ = (μ.with_density fun x => g x).withDensity fun x => (g x)⁻¹ :=
    by
    have A : ((fun x : α => (g x : ℝ≥0∞)) * fun x : α => (↑(g x))⁻¹) = 1 :=
      by
      ext1 x
      exact Ennreal.mul_inv_cancel (Ennreal.coe_ne_zero.2 (gpos x).ne') Ennreal.coe_ne_top
    rw [← with_density_mul _ gmeas.coe_nnreal_ennreal gmeas.coe_nnreal_ennreal.inv, A,
      with_density_one]
  conv_lhs => rw [this]
  exact with_density_absolutely_continuous _ _
#align
  measure_theory.exists_absolutely_continuous_is_finite_measure MeasureTheory.exists_absolutely_continuous_is_finite_measure

end SigmaFinite

end MeasureTheory

