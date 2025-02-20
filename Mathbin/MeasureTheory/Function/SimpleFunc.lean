/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module measure_theory.function.simple_func
! leanprover-community/mathlib commit 4280f5f32e16755ec7985ce11e189b6cd6ff6735
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Constructions.BorelSpace.Basic
import Mathbin.Algebra.IndicatorFunction
import Mathbin.Algebra.Support

/-!
# Simple functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A function `f` from a measurable space to any type is called *simple*, if every preimage `f ⁻¹' {x}`
is measurable, and the range is finite. In this file, we define simple functions and establish their
basic properties; and we construct a sequence of simple functions approximating an arbitrary Borel
measurable function `f : α → ℝ≥0∞`.

The theorem `measurable.ennreal_induction` shows that in order to prove something for an arbitrary
measurable function into `ℝ≥0∞`, it is sufficient to show that the property holds for (multiples of)
characteristic functions and is closed under addition and supremum of increasing sequences of
functions.
-/


noncomputable section

open Set hiding restrict restrict_apply

open Filter ENNReal

open Function (support)

open scoped Classical Topology BigOperators NNReal ENNReal MeasureTheory

namespace MeasureTheory

variable {α β γ δ : Type _}

#print MeasureTheory.SimpleFunc /-
/-- A function `f` from a measurable space to any type is called *simple*,
if every preimage `f ⁻¹' {x}` is measurable, and the range is finite. This structure bundles
a function with these properties. -/
structure SimpleFunc.{u, v} (α : Type u) [MeasurableSpace α] (β : Type v) where
  toFun : α → β
  measurableSet_fiber' : ∀ x, MeasurableSet (to_fun ⁻¹' {x})
  finite_range' : (Set.range to_fun).Finite
#align measure_theory.simple_func MeasureTheory.SimpleFunc
-/

local infixr:25 " →ₛ " => SimpleFunc

namespace SimpleFunc

section Measurable

variable [MeasurableSpace α]

#print MeasureTheory.SimpleFunc.instCoeFun /-
instance instCoeFun : CoeFun (α →ₛ β) fun _ => α → β :=
  ⟨toFun⟩
#align measure_theory.simple_func.has_coe_to_fun MeasureTheory.SimpleFunc.instCoeFun
-/

#print MeasureTheory.SimpleFunc.coe_injective /-
theorem coe_injective ⦃f g : α →ₛ β⦄ (H : (f : α → β) = g) : f = g := by
  cases f <;> cases g <;> congr <;> exact H
#align measure_theory.simple_func.coe_injective MeasureTheory.SimpleFunc.coe_injective
-/

#print MeasureTheory.SimpleFunc.ext /-
@[ext]
theorem ext {f g : α →ₛ β} (H : ∀ a, f a = g a) : f = g :=
  coe_injective <| funext H
#align measure_theory.simple_func.ext MeasureTheory.SimpleFunc.ext
-/

#print MeasureTheory.SimpleFunc.finite_range /-
theorem finite_range (f : α →ₛ β) : (Set.range f).Finite :=
  f.finite_range'
#align measure_theory.simple_func.finite_range MeasureTheory.SimpleFunc.finite_range
-/

#print MeasureTheory.SimpleFunc.measurableSet_fiber /-
theorem measurableSet_fiber (f : α →ₛ β) (x : β) : MeasurableSet (f ⁻¹' {x}) :=
  f.measurableSet_fiber' x
#align measure_theory.simple_func.measurable_set_fiber MeasureTheory.SimpleFunc.measurableSet_fiber
-/

#print MeasureTheory.SimpleFunc.apply_mk /-
@[simp]
theorem apply_mk (f : α → β) (h h') (x : α) : SimpleFunc.mk f h h' x = f x :=
  rfl
#align measure_theory.simple_func.apply_mk MeasureTheory.SimpleFunc.apply_mk
-/

#print MeasureTheory.SimpleFunc.ofIsEmpty /-
/-- Simple function defined on the empty type. -/
def ofIsEmpty [IsEmpty α] : α →ₛ β where
  toFun := isEmptyElim
  measurableSet_fiber' x := Subsingleton.measurableSet
  finite_range' := by simp [range_eq_empty]
#align measure_theory.simple_func.of_is_empty MeasureTheory.SimpleFunc.ofIsEmpty
-/

#print MeasureTheory.SimpleFunc.range /-
/-- Range of a simple function `α →ₛ β` as a `finset β`. -/
protected def range (f : α →ₛ β) : Finset β :=
  f.finite_range.toFinset
#align measure_theory.simple_func.range MeasureTheory.SimpleFunc.range
-/

#print MeasureTheory.SimpleFunc.mem_range /-
@[simp]
theorem mem_range {f : α →ₛ β} {b} : b ∈ f.range ↔ b ∈ range f :=
  Finite.mem_toFinset _
#align measure_theory.simple_func.mem_range MeasureTheory.SimpleFunc.mem_range
-/

#print MeasureTheory.SimpleFunc.mem_range_self /-
theorem mem_range_self (f : α →ₛ β) (x : α) : f x ∈ f.range :=
  mem_range.2 ⟨x, rfl⟩
#align measure_theory.simple_func.mem_range_self MeasureTheory.SimpleFunc.mem_range_self
-/

#print MeasureTheory.SimpleFunc.coe_range /-
@[simp]
theorem coe_range (f : α →ₛ β) : (↑f.range : Set β) = Set.range f :=
  f.finite_range.coe_toFinset
#align measure_theory.simple_func.coe_range MeasureTheory.SimpleFunc.coe_range
-/

#print MeasureTheory.SimpleFunc.mem_range_of_measure_ne_zero /-
theorem mem_range_of_measure_ne_zero {f : α →ₛ β} {x : β} {μ : Measure α} (H : μ (f ⁻¹' {x}) ≠ 0) :
    x ∈ f.range :=
  let ⟨a, ha⟩ := nonempty_of_measure_ne_zero H
  mem_range.2 ⟨a, ha⟩
#align measure_theory.simple_func.mem_range_of_measure_ne_zero MeasureTheory.SimpleFunc.mem_range_of_measure_ne_zero
-/

#print MeasureTheory.SimpleFunc.forall_range_iff /-
theorem forall_range_iff {f : α →ₛ β} {p : β → Prop} : (∀ y ∈ f.range, p y) ↔ ∀ x, p (f x) := by
  simp only [mem_range, Set.forall_range_iff]
#align measure_theory.simple_func.forall_range_iff MeasureTheory.SimpleFunc.forall_range_iff
-/

#print MeasureTheory.SimpleFunc.exists_range_iff /-
theorem exists_range_iff {f : α →ₛ β} {p : β → Prop} : (∃ y ∈ f.range, p y) ↔ ∃ x, p (f x) := by
  simpa only [mem_range, exists_prop] using Set.exists_range_iff
#align measure_theory.simple_func.exists_range_iff MeasureTheory.SimpleFunc.exists_range_iff
-/

#print MeasureTheory.SimpleFunc.preimage_eq_empty_iff /-
theorem preimage_eq_empty_iff (f : α →ₛ β) (b : β) : f ⁻¹' {b} = ∅ ↔ b ∉ f.range :=
  preimage_singleton_eq_empty.trans <| not_congr mem_range.symm
#align measure_theory.simple_func.preimage_eq_empty_iff MeasureTheory.SimpleFunc.preimage_eq_empty_iff
-/

#print MeasureTheory.SimpleFunc.exists_forall_le /-
theorem exists_forall_le [Nonempty β] [Preorder β] [IsDirected β (· ≤ ·)] (f : α →ₛ β) :
    ∃ C, ∀ x, f x ≤ C :=
  f.range.exists_le.imp fun C => forall_range_iff.1
#align measure_theory.simple_func.exists_forall_le MeasureTheory.SimpleFunc.exists_forall_le
-/

#print MeasureTheory.SimpleFunc.const /-
/-- Constant function as a `simple_func`. -/
def const (α) {β} [MeasurableSpace α] (b : β) : α →ₛ β :=
  ⟨fun a => b, fun x => MeasurableSet.const _, finite_range_const⟩
#align measure_theory.simple_func.const MeasureTheory.SimpleFunc.const
-/

instance [Inhabited β] : Inhabited (α →ₛ β) :=
  ⟨const _ default⟩

#print MeasureTheory.SimpleFunc.const_apply /-
theorem const_apply (a : α) (b : β) : (const α b) a = b :=
  rfl
#align measure_theory.simple_func.const_apply MeasureTheory.SimpleFunc.const_apply
-/

#print MeasureTheory.SimpleFunc.coe_const /-
@[simp]
theorem coe_const (b : β) : ⇑(const α b) = Function.const α b :=
  rfl
#align measure_theory.simple_func.coe_const MeasureTheory.SimpleFunc.coe_const
-/

#print MeasureTheory.SimpleFunc.range_const /-
@[simp]
theorem range_const (α) [MeasurableSpace α] [Nonempty α] (b : β) : (const α b).range = {b} :=
  Finset.coe_injective <| by simp
#align measure_theory.simple_func.range_const MeasureTheory.SimpleFunc.range_const
-/

#print MeasureTheory.SimpleFunc.range_const_subset /-
theorem range_const_subset (α) [MeasurableSpace α] (b : β) : (const α b).range ⊆ {b} :=
  Finset.coe_subset.1 <| by simp
#align measure_theory.simple_func.range_const_subset MeasureTheory.SimpleFunc.range_const_subset
-/

#print MeasureTheory.SimpleFunc.simpleFunc_bot /-
theorem simpleFunc_bot {α} (f : @SimpleFunc α ⊥ β) [Nonempty β] : ∃ c, ∀ x, f x = c :=
  by
  have hf_meas := @simple_func.measurable_set_fiber α _ ⊥ f
  simp_rw [MeasurableSpace.measurableSet_bot_iff] at hf_meas 
  cases isEmpty_or_nonempty α
  · simp only [IsEmpty.forall_iff, exists_const]
  · specialize hf_meas (f h.some)
    cases hf_meas
    · exfalso
      refine' Set.not_mem_empty h.some _
      rw [← hf_meas, Set.mem_preimage]
      exact Set.mem_singleton _
    · refine' ⟨f h.some, fun x => _⟩
      have : x ∈ f ⁻¹' {f h.some} := by rw [hf_meas]; exact Set.mem_univ x
      rwa [Set.mem_preimage, Set.mem_singleton_iff] at this 
#align measure_theory.simple_func.simple_func_bot MeasureTheory.SimpleFunc.simpleFunc_bot
-/

#print MeasureTheory.SimpleFunc.simpleFunc_bot' /-
theorem simpleFunc_bot' {α} [Nonempty β] (f : @SimpleFunc α ⊥ β) :
    ∃ c, f = @SimpleFunc.const α _ ⊥ c :=
  by
  obtain ⟨c, h_eq⟩ := simple_func_bot f
  refine' ⟨c, _⟩
  ext1 x
  rw [h_eq x, simple_func.coe_const]
#align measure_theory.simple_func.simple_func_bot' MeasureTheory.SimpleFunc.simpleFunc_bot'
-/

#print MeasureTheory.SimpleFunc.measurableSet_cut /-
theorem measurableSet_cut (r : α → β → Prop) (f : α →ₛ β) (h : ∀ b, MeasurableSet {a | r a b}) :
    MeasurableSet {a | r a (f a)} :=
  by
  have : {a | r a (f a)} = ⋃ b ∈ range f, {a | r a b} ∩ f ⁻¹' {b} :=
    by
    ext a
    suffices r a (f a) ↔ ∃ i, r a (f i) ∧ f a = f i by simpa
    exact ⟨fun h => ⟨a, ⟨h, rfl⟩⟩, fun ⟨a', ⟨h', e⟩⟩ => e.symm ▸ h'⟩
  rw [this]
  exact
    MeasurableSet.biUnion f.finite_range.countable fun b _ =>
      MeasurableSet.inter (h b) (f.measurable_set_fiber _)
#align measure_theory.simple_func.measurable_set_cut MeasureTheory.SimpleFunc.measurableSet_cut
-/

#print MeasureTheory.SimpleFunc.measurableSet_preimage /-
@[measurability]
theorem measurableSet_preimage (f : α →ₛ β) (s) : MeasurableSet (f ⁻¹' s) :=
  measurableSet_cut (fun _ b => b ∈ s) f fun b => MeasurableSet.const (b ∈ s)
#align measure_theory.simple_func.measurable_set_preimage MeasureTheory.SimpleFunc.measurableSet_preimage
-/

#print MeasureTheory.SimpleFunc.measurable /-
/-- A simple function is measurable -/
@[measurability]
protected theorem measurable [MeasurableSpace β] (f : α →ₛ β) : Measurable f := fun s _ =>
  measurableSet_preimage f s
#align measure_theory.simple_func.measurable MeasureTheory.SimpleFunc.measurable
-/

#print MeasureTheory.SimpleFunc.aemeasurable /-
@[measurability]
protected theorem aemeasurable [MeasurableSpace β] {μ : Measure α} (f : α →ₛ β) :
    AEMeasurable f μ :=
  f.Measurable.AEMeasurable
#align measure_theory.simple_func.ae_measurable MeasureTheory.SimpleFunc.aemeasurable
-/

#print MeasureTheory.SimpleFunc.sum_measure_preimage_singleton /-
protected theorem sum_measure_preimage_singleton (f : α →ₛ β) {μ : Measure α} (s : Finset β) :
    ∑ y in s, μ (f ⁻¹' {y}) = μ (f ⁻¹' ↑s) :=
  sum_measure_preimage_singleton _ fun _ _ => f.measurableSet_fiber _
#align measure_theory.simple_func.sum_measure_preimage_singleton MeasureTheory.SimpleFunc.sum_measure_preimage_singleton
-/

#print MeasureTheory.SimpleFunc.sum_range_measure_preimage_singleton /-
theorem sum_range_measure_preimage_singleton (f : α →ₛ β) (μ : Measure α) :
    ∑ y in f.range, μ (f ⁻¹' {y}) = μ univ := by
  rw [f.sum_measure_preimage_singleton, coe_range, preimage_range]
#align measure_theory.simple_func.sum_range_measure_preimage_singleton MeasureTheory.SimpleFunc.sum_range_measure_preimage_singleton
-/

#print MeasureTheory.SimpleFunc.piecewise /-
/-- If-then-else as a `simple_func`. -/
def piecewise (s : Set α) (hs : MeasurableSet s) (f g : α →ₛ β) : α →ₛ β :=
  ⟨s.piecewise f g, fun x =>
    letI : MeasurableSpace β := ⊤
    f.measurable.piecewise hs g.measurable trivial,
    (f.finite_range.union g.finite_range).Subset range_ite_subset⟩
#align measure_theory.simple_func.piecewise MeasureTheory.SimpleFunc.piecewise
-/

#print MeasureTheory.SimpleFunc.coe_piecewise /-
@[simp]
theorem coe_piecewise {s : Set α} (hs : MeasurableSet s) (f g : α →ₛ β) :
    ⇑(piecewise s hs f g) = s.piecewise f g :=
  rfl
#align measure_theory.simple_func.coe_piecewise MeasureTheory.SimpleFunc.coe_piecewise
-/

#print MeasureTheory.SimpleFunc.piecewise_apply /-
theorem piecewise_apply {s : Set α} (hs : MeasurableSet s) (f g : α →ₛ β) (a) :
    piecewise s hs f g a = if a ∈ s then f a else g a :=
  rfl
#align measure_theory.simple_func.piecewise_apply MeasureTheory.SimpleFunc.piecewise_apply
-/

#print MeasureTheory.SimpleFunc.piecewise_compl /-
@[simp]
theorem piecewise_compl {s : Set α} (hs : MeasurableSet (sᶜ)) (f g : α →ₛ β) :
    piecewise (sᶜ) hs f g = piecewise s hs.ofCompl g f :=
  coe_injective <| by simp [hs]
#align measure_theory.simple_func.piecewise_compl MeasureTheory.SimpleFunc.piecewise_compl
-/

#print MeasureTheory.SimpleFunc.piecewise_univ /-
@[simp]
theorem piecewise_univ (f g : α →ₛ β) : piecewise univ MeasurableSet.univ f g = f :=
  coe_injective <| by simp
#align measure_theory.simple_func.piecewise_univ MeasureTheory.SimpleFunc.piecewise_univ
-/

#print MeasureTheory.SimpleFunc.piecewise_empty /-
@[simp]
theorem piecewise_empty (f g : α →ₛ β) : piecewise ∅ MeasurableSet.empty f g = g :=
  coe_injective <| by simp
#align measure_theory.simple_func.piecewise_empty MeasureTheory.SimpleFunc.piecewise_empty
-/

#print MeasureTheory.SimpleFunc.support_indicator /-
theorem support_indicator [Zero β] {s : Set α} (hs : MeasurableSet s) (f : α →ₛ β) :
    Function.support (f.piecewise s hs (SimpleFunc.const α 0)) = s ∩ Function.support f :=
  Set.support_indicator
#align measure_theory.simple_func.support_indicator MeasureTheory.SimpleFunc.support_indicator
-/

#print MeasureTheory.SimpleFunc.range_indicator /-
theorem range_indicator {s : Set α} (hs : MeasurableSet s) (hs_nonempty : s.Nonempty)
    (hs_ne_univ : s ≠ univ) (x y : β) : (piecewise s hs (const α x) (const α y)).range = {x, y} :=
  by
  simp only [← Finset.coe_inj, coe_range, coe_piecewise, range_piecewise, coe_const,
    Finset.coe_insert, Finset.coe_singleton, hs_nonempty.image_const,
    (nonempty_compl.2 hs_ne_univ).image_const, singleton_union]
#align measure_theory.simple_func.range_indicator MeasureTheory.SimpleFunc.range_indicator
-/

#print MeasureTheory.SimpleFunc.measurable_bind /-
theorem measurable_bind [MeasurableSpace γ] (f : α →ₛ β) (g : β → α → γ)
    (hg : ∀ b, Measurable (g b)) : Measurable fun a => g (f a) a := fun s hs =>
  f.measurableSet_cut (fun a b => g b a ∈ s) fun b => hg b hs
#align measure_theory.simple_func.measurable_bind MeasureTheory.SimpleFunc.measurable_bind
-/

#print MeasureTheory.SimpleFunc.bind /-
/-- If `f : α →ₛ β` is a simple function and `g : β → α →ₛ γ` is a family of simple functions,
then `f.bind g` binds the first argument of `g` to `f`. In other words, `f.bind g a = g (f a) a`. -/
def bind (f : α →ₛ β) (g : β → α →ₛ γ) : α →ₛ γ :=
  ⟨fun a => g (f a) a, fun c =>
    f.measurableSet_cut (fun a b => g b a = c) fun b => (g b).measurableSet_preimage {c},
    (f.finite_range.biUnion fun b _ => (g b).finite_range).Subset <| by
      rintro _ ⟨a, rfl⟩ <;> simp <;> exact ⟨a, a, rfl⟩⟩
#align measure_theory.simple_func.bind MeasureTheory.SimpleFunc.bind
-/

#print MeasureTheory.SimpleFunc.bind_apply /-
@[simp]
theorem bind_apply (f : α →ₛ β) (g : β → α →ₛ γ) (a) : f.bind g a = g (f a) a :=
  rfl
#align measure_theory.simple_func.bind_apply MeasureTheory.SimpleFunc.bind_apply
-/

#print MeasureTheory.SimpleFunc.map /-
/-- Given a function `g : β → γ` and a simple function `f : α →ₛ β`, `f.map g` return the simple
    function `g ∘ f : α →ₛ γ` -/
def map (g : β → γ) (f : α →ₛ β) : α →ₛ γ :=
  bind f (const α ∘ g)
#align measure_theory.simple_func.map MeasureTheory.SimpleFunc.map
-/

#print MeasureTheory.SimpleFunc.map_apply /-
theorem map_apply (g : β → γ) (f : α →ₛ β) (a) : f.map g a = g (f a) :=
  rfl
#align measure_theory.simple_func.map_apply MeasureTheory.SimpleFunc.map_apply
-/

#print MeasureTheory.SimpleFunc.map_map /-
theorem map_map (g : β → γ) (h : γ → δ) (f : α →ₛ β) : (f.map g).map h = f.map (h ∘ g) :=
  rfl
#align measure_theory.simple_func.map_map MeasureTheory.SimpleFunc.map_map
-/

#print MeasureTheory.SimpleFunc.coe_map /-
@[simp]
theorem coe_map (g : β → γ) (f : α →ₛ β) : (f.map g : α → γ) = g ∘ f :=
  rfl
#align measure_theory.simple_func.coe_map MeasureTheory.SimpleFunc.coe_map
-/

#print MeasureTheory.SimpleFunc.range_map /-
@[simp]
theorem range_map [DecidableEq γ] (g : β → γ) (f : α →ₛ β) : (f.map g).range = f.range.image g :=
  Finset.coe_injective <| by simp only [coe_range, coe_map, Finset.coe_image, range_comp]
#align measure_theory.simple_func.range_map MeasureTheory.SimpleFunc.range_map
-/

#print MeasureTheory.SimpleFunc.map_const /-
@[simp]
theorem map_const (g : β → γ) (b : β) : (const α b).map g = const α (g b) :=
  rfl
#align measure_theory.simple_func.map_const MeasureTheory.SimpleFunc.map_const
-/

#print MeasureTheory.SimpleFunc.map_preimage /-
theorem map_preimage (f : α →ₛ β) (g : β → γ) (s : Set γ) :
    f.map g ⁻¹' s = f ⁻¹' ↑(f.range.filterₓ fun b => g b ∈ s) :=
  by
  simp only [coe_range, sep_mem_eq, Set.mem_range, Function.comp_apply, coe_map, Finset.coe_filter,
    ← mem_preimage, inter_comm, preimage_inter_range]
  apply preimage_comp
#align measure_theory.simple_func.map_preimage MeasureTheory.SimpleFunc.map_preimage
-/

#print MeasureTheory.SimpleFunc.map_preimage_singleton /-
theorem map_preimage_singleton (f : α →ₛ β) (g : β → γ) (c : γ) :
    f.map g ⁻¹' {c} = f ⁻¹' ↑(f.range.filterₓ fun b => g b = c) :=
  map_preimage _ _ _
#align measure_theory.simple_func.map_preimage_singleton MeasureTheory.SimpleFunc.map_preimage_singleton
-/

#print MeasureTheory.SimpleFunc.comp /-
/-- Composition of a `simple_fun` and a measurable function is a `simple_func`. -/
def comp [MeasurableSpace β] (f : β →ₛ γ) (g : α → β) (hgm : Measurable g) : α →ₛ γ
    where
  toFun := f ∘ g
  finite_range' := f.finite_range.Subset <| Set.range_comp_subset_range _ _
  measurableSet_fiber' z := hgm (f.measurableSet_fiber z)
#align measure_theory.simple_func.comp MeasureTheory.SimpleFunc.comp
-/

#print MeasureTheory.SimpleFunc.coe_comp /-
@[simp]
theorem coe_comp [MeasurableSpace β] (f : β →ₛ γ) {g : α → β} (hgm : Measurable g) :
    ⇑(f.comp g hgm) = f ∘ g :=
  rfl
#align measure_theory.simple_func.coe_comp MeasureTheory.SimpleFunc.coe_comp
-/

#print MeasureTheory.SimpleFunc.range_comp_subset_range /-
theorem range_comp_subset_range [MeasurableSpace β] (f : β →ₛ γ) {g : α → β} (hgm : Measurable g) :
    (f.comp g hgm).range ⊆ f.range :=
  Finset.coe_subset.1 <| by simp only [coe_range, coe_comp, Set.range_comp_subset_range]
#align measure_theory.simple_func.range_comp_subset_range MeasureTheory.SimpleFunc.range_comp_subset_range
-/

#print MeasureTheory.SimpleFunc.extend /-
/-- Extend a `simple_func` along a measurable embedding: `f₁.extend g hg f₂` is the function
`F : β →ₛ γ` such that `F ∘ g = f₁` and `F y = f₂ y` whenever `y ∉ range g`. -/
def extend [MeasurableSpace β] (f₁ : α →ₛ γ) (g : α → β) (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) : β →ₛ γ where
  toFun := Function.extend g f₁ f₂
  finite_range' :=
    (f₁.finite_range.union <| f₂.finite_range.Subset (image_subset_range _ _)).Subset
      (range_extend_subset _ _ _)
  measurableSet_fiber' := by
    letI : MeasurableSpace γ := ⊤; haveI : MeasurableSingletonClass γ := ⟨fun _ => trivial⟩
    exact fun x => hg.measurable_extend f₁.measurable f₂.measurable (measurable_set_singleton _)
#align measure_theory.simple_func.extend MeasureTheory.SimpleFunc.extend
-/

#print MeasureTheory.SimpleFunc.extend_apply /-
@[simp]
theorem extend_apply [MeasurableSpace β] (f₁ : α →ₛ γ) {g : α → β} (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) (x : α) : (f₁.extend g hg f₂) (g x) = f₁ x :=
  hg.Injective.extend_apply _ _ _
#align measure_theory.simple_func.extend_apply MeasureTheory.SimpleFunc.extend_apply
-/

#print MeasureTheory.SimpleFunc.extend_apply' /-
@[simp]
theorem extend_apply' [MeasurableSpace β] (f₁ : α →ₛ γ) {g : α → β} (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) {y : β} (h : ¬∃ x, g x = y) : (f₁.extend g hg f₂) y = f₂ y :=
  Function.extend_apply' _ _ _ h
#align measure_theory.simple_func.extend_apply' MeasureTheory.SimpleFunc.extend_apply'
-/

#print MeasureTheory.SimpleFunc.extend_comp_eq' /-
@[simp]
theorem extend_comp_eq' [MeasurableSpace β] (f₁ : α →ₛ γ) {g : α → β} (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) : f₁.extend g hg f₂ ∘ g = f₁ :=
  funext fun x => extend_apply _ _ _ _
#align measure_theory.simple_func.extend_comp_eq' MeasureTheory.SimpleFunc.extend_comp_eq'
-/

#print MeasureTheory.SimpleFunc.extend_comp_eq /-
@[simp]
theorem extend_comp_eq [MeasurableSpace β] (f₁ : α →ₛ γ) {g : α → β} (hg : MeasurableEmbedding g)
    (f₂ : β →ₛ γ) : (f₁.extend g hg f₂).comp g hg.Measurable = f₁ :=
  coe_injective <| extend_comp_eq' _ _ _
#align measure_theory.simple_func.extend_comp_eq MeasureTheory.SimpleFunc.extend_comp_eq
-/

#print MeasureTheory.SimpleFunc.seq /-
/-- If `f` is a simple function taking values in `β → γ` and `g` is another simple function
with the same domain and codomain `β`, then `f.seq g = f a (g a)`. -/
def seq (f : α →ₛ β → γ) (g : α →ₛ β) : α →ₛ γ :=
  f.bind fun f => g.map f
#align measure_theory.simple_func.seq MeasureTheory.SimpleFunc.seq
-/

#print MeasureTheory.SimpleFunc.seq_apply /-
@[simp]
theorem seq_apply (f : α →ₛ β → γ) (g : α →ₛ β) (a : α) : f.seq g a = f a (g a) :=
  rfl
#align measure_theory.simple_func.seq_apply MeasureTheory.SimpleFunc.seq_apply
-/

#print MeasureTheory.SimpleFunc.pair /-
/-- Combine two simple functions `f : α →ₛ β` and `g : α →ₛ β`
into `λ a, (f a, g a)`. -/
def pair (f : α →ₛ β) (g : α →ₛ γ) : α →ₛ β × γ :=
  (f.map Prod.mk).seq g
#align measure_theory.simple_func.pair MeasureTheory.SimpleFunc.pair
-/

#print MeasureTheory.SimpleFunc.pair_apply /-
@[simp]
theorem pair_apply (f : α →ₛ β) (g : α →ₛ γ) (a) : pair f g a = (f a, g a) :=
  rfl
#align measure_theory.simple_func.pair_apply MeasureTheory.SimpleFunc.pair_apply
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print MeasureTheory.SimpleFunc.pair_preimage /-
theorem pair_preimage (f : α →ₛ β) (g : α →ₛ γ) (s : Set β) (t : Set γ) :
    pair f g ⁻¹' s ×ˢ t = f ⁻¹' s ∩ g ⁻¹' t :=
  rfl
#align measure_theory.simple_func.pair_preimage MeasureTheory.SimpleFunc.pair_preimage
-/

#print MeasureTheory.SimpleFunc.pair_preimage_singleton /-
-- A special form of `pair_preimage`
theorem pair_preimage_singleton (f : α →ₛ β) (g : α →ₛ γ) (b : β) (c : γ) :
    pair f g ⁻¹' {(b, c)} = f ⁻¹' {b} ∩ g ⁻¹' {c} := by rw [← singleton_prod_singleton];
  exact pair_preimage _ _ _ _
#align measure_theory.simple_func.pair_preimage_singleton MeasureTheory.SimpleFunc.pair_preimage_singleton
-/

#print MeasureTheory.SimpleFunc.bind_const /-
theorem bind_const (f : α →ₛ β) : f.bind (const α) = f := by ext <;> simp
#align measure_theory.simple_func.bind_const MeasureTheory.SimpleFunc.bind_const
-/

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

instance [Sup β] : Sup (α →ₛ β) :=
  ⟨fun f g => (f.map (· ⊔ ·)).seq g⟩

instance [Inf β] : Inf (α →ₛ β) :=
  ⟨fun f g => (f.map (· ⊓ ·)).seq g⟩

instance [LE β] : LE (α →ₛ β) :=
  ⟨fun f g => ∀ a, f a ≤ g a⟩

#print MeasureTheory.SimpleFunc.const_one /-
@[simp, to_additive]
theorem const_one [One β] : const α (1 : β) = 1 :=
  rfl
#align measure_theory.simple_func.const_one MeasureTheory.SimpleFunc.const_one
#align measure_theory.simple_func.const_zero MeasureTheory.SimpleFunc.const_zero
-/

#print MeasureTheory.SimpleFunc.coe_one /-
@[simp, norm_cast, to_additive]
theorem coe_one [One β] : ⇑(1 : α →ₛ β) = 1 :=
  rfl
#align measure_theory.simple_func.coe_one MeasureTheory.SimpleFunc.coe_one
#align measure_theory.simple_func.coe_zero MeasureTheory.SimpleFunc.coe_zero
-/

#print MeasureTheory.SimpleFunc.coe_mul /-
@[simp, norm_cast, to_additive]
theorem coe_mul [Mul β] (f g : α →ₛ β) : ⇑(f * g) = f * g :=
  rfl
#align measure_theory.simple_func.coe_mul MeasureTheory.SimpleFunc.coe_mul
#align measure_theory.simple_func.coe_add MeasureTheory.SimpleFunc.coe_add
-/

#print MeasureTheory.SimpleFunc.coe_inv /-
@[simp, norm_cast, to_additive]
theorem coe_inv [Inv β] (f : α →ₛ β) : ⇑f⁻¹ = f⁻¹ :=
  rfl
#align measure_theory.simple_func.coe_inv MeasureTheory.SimpleFunc.coe_inv
#align measure_theory.simple_func.coe_neg MeasureTheory.SimpleFunc.coe_neg
-/

#print MeasureTheory.SimpleFunc.coe_div /-
@[simp, norm_cast, to_additive]
theorem coe_div [Div β] (f g : α →ₛ β) : ⇑(f / g) = f / g :=
  rfl
#align measure_theory.simple_func.coe_div MeasureTheory.SimpleFunc.coe_div
#align measure_theory.simple_func.coe_sub MeasureTheory.SimpleFunc.coe_sub
-/

#print MeasureTheory.SimpleFunc.coe_le /-
@[simp, norm_cast]
theorem coe_le [Preorder β] {f g : α →ₛ β} : (f : α → β) ≤ g ↔ f ≤ g :=
  Iff.rfl
#align measure_theory.simple_func.coe_le MeasureTheory.SimpleFunc.coe_le
-/

#print MeasureTheory.SimpleFunc.coe_sup /-
@[simp, norm_cast]
theorem coe_sup [Sup β] (f g : α →ₛ β) : ⇑(f ⊔ g) = f ⊔ g :=
  rfl
#align measure_theory.simple_func.coe_sup MeasureTheory.SimpleFunc.coe_sup
-/

#print MeasureTheory.SimpleFunc.coe_inf /-
@[simp, norm_cast]
theorem coe_inf [Inf β] (f g : α →ₛ β) : ⇑(f ⊓ g) = f ⊓ g :=
  rfl
#align measure_theory.simple_func.coe_inf MeasureTheory.SimpleFunc.coe_inf
-/

#print MeasureTheory.SimpleFunc.mul_apply /-
@[to_additive]
theorem mul_apply [Mul β] (f g : α →ₛ β) (a : α) : (f * g) a = f a * g a :=
  rfl
#align measure_theory.simple_func.mul_apply MeasureTheory.SimpleFunc.mul_apply
#align measure_theory.simple_func.add_apply MeasureTheory.SimpleFunc.add_apply
-/

#print MeasureTheory.SimpleFunc.div_apply /-
@[to_additive]
theorem div_apply [Div β] (f g : α →ₛ β) (x : α) : (f / g) x = f x / g x :=
  rfl
#align measure_theory.simple_func.div_apply MeasureTheory.SimpleFunc.div_apply
#align measure_theory.simple_func.sub_apply MeasureTheory.SimpleFunc.sub_apply
-/

#print MeasureTheory.SimpleFunc.inv_apply /-
@[to_additive]
theorem inv_apply [Inv β] (f : α →ₛ β) (x : α) : f⁻¹ x = (f x)⁻¹ :=
  rfl
#align measure_theory.simple_func.inv_apply MeasureTheory.SimpleFunc.inv_apply
#align measure_theory.simple_func.neg_apply MeasureTheory.SimpleFunc.neg_apply
-/

#print MeasureTheory.SimpleFunc.sup_apply /-
theorem sup_apply [Sup β] (f g : α →ₛ β) (a : α) : (f ⊔ g) a = f a ⊔ g a :=
  rfl
#align measure_theory.simple_func.sup_apply MeasureTheory.SimpleFunc.sup_apply
-/

#print MeasureTheory.SimpleFunc.inf_apply /-
theorem inf_apply [Inf β] (f g : α →ₛ β) (a : α) : (f ⊓ g) a = f a ⊓ g a :=
  rfl
#align measure_theory.simple_func.inf_apply MeasureTheory.SimpleFunc.inf_apply
-/

#print MeasureTheory.SimpleFunc.range_one /-
@[simp, to_additive]
theorem range_one [Nonempty α] [One β] : (1 : α →ₛ β).range = {1} :=
  Finset.ext fun x => by simp [eq_comm]
#align measure_theory.simple_func.range_one MeasureTheory.SimpleFunc.range_one
#align measure_theory.simple_func.range_zero MeasureTheory.SimpleFunc.range_zero
-/

#print MeasureTheory.SimpleFunc.range_eq_empty_of_isEmpty /-
@[simp]
theorem range_eq_empty_of_isEmpty {β} [hα : IsEmpty α] (f : α →ₛ β) : f.range = ∅ :=
  by
  rw [← Finset.not_nonempty_iff_eq_empty]
  by_contra
  obtain ⟨y, hy_mem⟩ := h
  rw [simple_func.mem_range, Set.mem_range] at hy_mem 
  obtain ⟨x, hxy⟩ := hy_mem
  rw [isEmpty_iff] at hα 
  exact hα x
#align measure_theory.simple_func.range_eq_empty_of_is_empty MeasureTheory.SimpleFunc.range_eq_empty_of_isEmpty
-/

#print MeasureTheory.SimpleFunc.eq_zero_of_mem_range_zero /-
theorem eq_zero_of_mem_range_zero [Zero β] : ∀ {y : β}, y ∈ (0 : α →ₛ β).range → y = 0 :=
  forall_range_iff.2 fun x => rfl
#align measure_theory.simple_func.eq_zero_of_mem_range_zero MeasureTheory.SimpleFunc.eq_zero_of_mem_range_zero
-/

#print MeasureTheory.SimpleFunc.mul_eq_map₂ /-
@[to_additive]
theorem mul_eq_map₂ [Mul β] (f g : α →ₛ β) : f * g = (pair f g).map fun p : β × β => p.1 * p.2 :=
  rfl
#align measure_theory.simple_func.mul_eq_map₂ MeasureTheory.SimpleFunc.mul_eq_map₂
#align measure_theory.simple_func.add_eq_map₂ MeasureTheory.SimpleFunc.add_eq_map₂
-/

#print MeasureTheory.SimpleFunc.sup_eq_map₂ /-
theorem sup_eq_map₂ [Sup β] (f g : α →ₛ β) : f ⊔ g = (pair f g).map fun p : β × β => p.1 ⊔ p.2 :=
  rfl
#align measure_theory.simple_func.sup_eq_map₂ MeasureTheory.SimpleFunc.sup_eq_map₂
-/

#print MeasureTheory.SimpleFunc.const_mul_eq_map /-
@[to_additive]
theorem const_mul_eq_map [Mul β] (f : α →ₛ β) (b : β) : const α b * f = f.map fun a => b * a :=
  rfl
#align measure_theory.simple_func.const_mul_eq_map MeasureTheory.SimpleFunc.const_mul_eq_map
#align measure_theory.simple_func.const_add_eq_map MeasureTheory.SimpleFunc.const_add_eq_map
-/

#print MeasureTheory.SimpleFunc.map_mul /-
@[to_additive]
theorem map_mul [Mul β] [Mul γ] {g : β → γ} (hg : ∀ x y, g (x * y) = g x * g y) (f₁ f₂ : α →ₛ β) :
    (f₁ * f₂).map g = f₁.map g * f₂.map g :=
  ext fun x => hg _ _
#align measure_theory.simple_func.map_mul MeasureTheory.SimpleFunc.map_mul
#align measure_theory.simple_func.map_add MeasureTheory.SimpleFunc.map_add
-/

variable {K : Type _}

instance [SMul K β] : SMul K (α →ₛ β) :=
  ⟨fun k f => f.map ((· • ·) k)⟩

#print MeasureTheory.SimpleFunc.coe_smul /-
@[simp]
theorem coe_smul [SMul K β] (c : K) (f : α →ₛ β) : ⇑(c • f) = c • f :=
  rfl
#align measure_theory.simple_func.coe_smul MeasureTheory.SimpleFunc.coe_smul
-/

#print MeasureTheory.SimpleFunc.smul_apply /-
theorem smul_apply [SMul K β] (k : K) (f : α →ₛ β) (a : α) : (k • f) a = k • f a :=
  rfl
#align measure_theory.simple_func.smul_apply MeasureTheory.SimpleFunc.smul_apply
-/

#print MeasureTheory.SimpleFunc.hasNatPow /-
instance hasNatPow [Monoid β] : Pow (α →ₛ β) ℕ :=
  ⟨fun f n => f.map (· ^ n)⟩
#align measure_theory.simple_func.has_nat_pow MeasureTheory.SimpleFunc.hasNatPow
-/

#print MeasureTheory.SimpleFunc.coe_pow /-
@[simp]
theorem coe_pow [Monoid β] (f : α →ₛ β) (n : ℕ) : ⇑(f ^ n) = f ^ n :=
  rfl
#align measure_theory.simple_func.coe_pow MeasureTheory.SimpleFunc.coe_pow
-/

#print MeasureTheory.SimpleFunc.pow_apply /-
theorem pow_apply [Monoid β] (n : ℕ) (f : α →ₛ β) (a : α) : (f ^ n) a = f a ^ n :=
  rfl
#align measure_theory.simple_func.pow_apply MeasureTheory.SimpleFunc.pow_apply
-/

#print MeasureTheory.SimpleFunc.hasIntPow /-
instance hasIntPow [DivInvMonoid β] : Pow (α →ₛ β) ℤ :=
  ⟨fun f n => f.map (· ^ n)⟩
#align measure_theory.simple_func.has_int_pow MeasureTheory.SimpleFunc.hasIntPow
-/

#print MeasureTheory.SimpleFunc.coe_zpow /-
@[simp]
theorem coe_zpow [DivInvMonoid β] (f : α →ₛ β) (z : ℤ) : ⇑(f ^ z) = f ^ z :=
  rfl
#align measure_theory.simple_func.coe_zpow MeasureTheory.SimpleFunc.coe_zpow
-/

#print MeasureTheory.SimpleFunc.zpow_apply /-
theorem zpow_apply [DivInvMonoid β] (z : ℤ) (f : α →ₛ β) (a : α) : (f ^ z) a = f a ^ z :=
  rfl
#align measure_theory.simple_func.zpow_apply MeasureTheory.SimpleFunc.zpow_apply
-/

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

#print MeasureTheory.SimpleFunc.smul_eq_map /-
theorem smul_eq_map [SMul K β] (k : K) (f : α →ₛ β) : k • f = f.map ((· • ·) k) :=
  rfl
#align measure_theory.simple_func.smul_eq_map MeasureTheory.SimpleFunc.smul_eq_map
-/

instance [Preorder β] : Preorder (α →ₛ β) :=
  { SimpleFunc.instLE with
    le_refl := fun f a => le_rfl
    le_trans := fun f g h hfg hgh a => le_trans (hfg _) (hgh a) }

instance [PartialOrder β] : PartialOrder (α →ₛ β) :=
  { SimpleFunc.instPreorder with
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
  { SimpleFunc.instPartialOrder with
    inf := (· ⊓ ·)
    inf_le_left := fun f g a => inf_le_left
    inf_le_right := fun f g a => inf_le_right
    le_inf := fun f g h hfh hgh a => le_inf (hfh a) (hgh a) }

instance [SemilatticeSup β] : SemilatticeSup (α →ₛ β) :=
  { SimpleFunc.instPartialOrder with
    sup := (· ⊔ ·)
    le_sup_left := fun f g a => le_sup_left
    le_sup_right := fun f g a => le_sup_right
    sup_le := fun f g h hfh hgh a => sup_le (hfh a) (hgh a) }

instance [Lattice β] : Lattice (α →ₛ β) :=
  { SimpleFunc.instSemilatticeSup, SimpleFunc.instSemilatticeInf with }

instance [LE β] [BoundedOrder β] : BoundedOrder (α →ₛ β) :=
  { SimpleFunc.instOrderBot, SimpleFunc.instOrderTop with }

#print MeasureTheory.SimpleFunc.finset_sup_apply /-
theorem finset_sup_apply [SemilatticeSup β] [OrderBot β] {f : γ → α →ₛ β} (s : Finset γ) (a : α) :
    s.sup f a = s.sup fun c => f c a :=
  by
  refine' Finset.induction_on s rfl _
  intro a s hs ih
  rw [Finset.sup_insert, Finset.sup_insert, sup_apply, ih]
#align measure_theory.simple_func.finset_sup_apply MeasureTheory.SimpleFunc.finset_sup_apply
-/

section Restrict

variable [Zero β]

#print MeasureTheory.SimpleFunc.restrict /-
/-- Restrict a simple function `f : α →ₛ β` to a set `s`. If `s` is measurable,
then `f.restrict s a = if a ∈ s then f a else 0`, otherwise `f.restrict s = const α 0`. -/
def restrict (f : α →ₛ β) (s : Set α) : α →ₛ β :=
  if hs : MeasurableSet s then piecewise s hs f 0 else 0
#align measure_theory.simple_func.restrict MeasureTheory.SimpleFunc.restrict
-/

#print MeasureTheory.SimpleFunc.restrict_of_not_measurable /-
theorem restrict_of_not_measurable {f : α →ₛ β} {s : Set α} (hs : ¬MeasurableSet s) :
    restrict f s = 0 :=
  dif_neg hs
#align measure_theory.simple_func.restrict_of_not_measurable MeasureTheory.SimpleFunc.restrict_of_not_measurable
-/

#print MeasureTheory.SimpleFunc.coe_restrict /-
@[simp]
theorem coe_restrict (f : α →ₛ β) {s : Set α} (hs : MeasurableSet s) :
    ⇑(restrict f s) = indicator s f := by rw [restrict, dif_pos hs]; rfl
#align measure_theory.simple_func.coe_restrict MeasureTheory.SimpleFunc.coe_restrict
-/

#print MeasureTheory.SimpleFunc.restrict_univ /-
@[simp]
theorem restrict_univ (f : α →ₛ β) : restrict f univ = f := by simp [restrict]
#align measure_theory.simple_func.restrict_univ MeasureTheory.SimpleFunc.restrict_univ
-/

#print MeasureTheory.SimpleFunc.restrict_empty /-
@[simp]
theorem restrict_empty (f : α →ₛ β) : restrict f ∅ = 0 := by simp [restrict]
#align measure_theory.simple_func.restrict_empty MeasureTheory.SimpleFunc.restrict_empty
-/

#print MeasureTheory.SimpleFunc.map_restrict_of_zero /-
theorem map_restrict_of_zero [Zero γ] {g : β → γ} (hg : g 0 = 0) (f : α →ₛ β) (s : Set α) :
    (f.restrict s).map g = (f.map g).restrict s :=
  ext fun x =>
    if hs : MeasurableSet s then by simp [hs, Set.indicator_comp_of_zero hg]
    else by simp [restrict_of_not_measurable hs, hg]
#align measure_theory.simple_func.map_restrict_of_zero MeasureTheory.SimpleFunc.map_restrict_of_zero
-/

#print MeasureTheory.SimpleFunc.map_coe_ennreal_restrict /-
theorem map_coe_ennreal_restrict (f : α →ₛ ℝ≥0) (s : Set α) :
    (f.restrict s).map (coe : ℝ≥0 → ℝ≥0∞) = (f.map coe).restrict s :=
  map_restrict_of_zero ENNReal.coe_zero _ _
#align measure_theory.simple_func.map_coe_ennreal_restrict MeasureTheory.SimpleFunc.map_coe_ennreal_restrict
-/

#print MeasureTheory.SimpleFunc.map_coe_nnreal_restrict /-
theorem map_coe_nnreal_restrict (f : α →ₛ ℝ≥0) (s : Set α) :
    (f.restrict s).map (coe : ℝ≥0 → ℝ) = (f.map coe).restrict s :=
  map_restrict_of_zero NNReal.coe_zero _ _
#align measure_theory.simple_func.map_coe_nnreal_restrict MeasureTheory.SimpleFunc.map_coe_nnreal_restrict
-/

#print MeasureTheory.SimpleFunc.restrict_apply /-
theorem restrict_apply (f : α →ₛ β) {s : Set α} (hs : MeasurableSet s) (a) :
    restrict f s a = indicator s f a := by simp only [f.coe_restrict hs]
#align measure_theory.simple_func.restrict_apply MeasureTheory.SimpleFunc.restrict_apply
-/

#print MeasureTheory.SimpleFunc.restrict_preimage /-
theorem restrict_preimage (f : α →ₛ β) {s : Set α} (hs : MeasurableSet s) {t : Set β}
    (ht : (0 : β) ∉ t) : restrict f s ⁻¹' t = s ∩ f ⁻¹' t := by
  simp [hs, indicator_preimage_of_not_mem _ _ ht, inter_comm]
#align measure_theory.simple_func.restrict_preimage MeasureTheory.SimpleFunc.restrict_preimage
-/

#print MeasureTheory.SimpleFunc.restrict_preimage_singleton /-
theorem restrict_preimage_singleton (f : α →ₛ β) {s : Set α} (hs : MeasurableSet s) {r : β}
    (hr : r ≠ 0) : restrict f s ⁻¹' {r} = s ∩ f ⁻¹' {r} :=
  f.restrictPreimage hs hr.symm
#align measure_theory.simple_func.restrict_preimage_singleton MeasureTheory.SimpleFunc.restrict_preimage_singleton
-/

#print MeasureTheory.SimpleFunc.mem_restrict_range /-
theorem mem_restrict_range {r : β} {s : Set α} {f : α →ₛ β} (hs : MeasurableSet s) :
    r ∈ (restrict f s).range ↔ r = 0 ∧ s ≠ univ ∨ r ∈ f '' s := by
  rw [← Finset.mem_coe, coe_range, coe_restrict _ hs, mem_range_indicator]
#align measure_theory.simple_func.mem_restrict_range MeasureTheory.SimpleFunc.mem_restrict_range
-/

#print MeasureTheory.SimpleFunc.mem_image_of_mem_range_restrict /-
theorem mem_image_of_mem_range_restrict {r : β} {s : Set α} {f : α →ₛ β}
    (hr : r ∈ (restrict f s).range) (h0 : r ≠ 0) : r ∈ f '' s :=
  if hs : MeasurableSet s then by simpa [mem_restrict_range hs, h0] using hr
  else by
    rw [restrict_of_not_measurable hs] at hr 
    exact (h0 <| eq_zero_of_mem_range_zero hr).elim
#align measure_theory.simple_func.mem_image_of_mem_range_restrict MeasureTheory.SimpleFunc.mem_image_of_mem_range_restrict
-/

#print MeasureTheory.SimpleFunc.restrict_mono /-
@[mono]
theorem restrict_mono [Preorder β] (s : Set α) {f g : α →ₛ β} (H : f ≤ g) :
    f.restrict s ≤ g.restrict s :=
  if hs : MeasurableSet s then fun x => by
    simp only [coe_restrict _ hs, indicator_le_indicator (H x)]
  else by simp only [restrict_of_not_measurable hs, le_refl]
#align measure_theory.simple_func.restrict_mono MeasureTheory.SimpleFunc.restrict_mono
-/

end Restrict

section Approx

section

variable [SemilatticeSup β] [OrderBot β] [Zero β]

#print MeasureTheory.SimpleFunc.approx /-
/-- Fix a sequence `i : ℕ → β`. Given a function `α → β`, its `n`-th approximation
by simple functions is defined so that in case `β = ℝ≥0∞` it sends each `a` to the supremum
of the set `{i k | k ≤ n ∧ i k ≤ f a}`, see `approx_apply` and `supr_approx_apply` for details. -/
def approx (i : ℕ → β) (f : α → β) (n : ℕ) : α →ₛ β :=
  (Finset.range n).sup fun k => restrict (const α (i k)) {a : α | i k ≤ f a}
#align measure_theory.simple_func.approx MeasureTheory.SimpleFunc.approx
-/

#print MeasureTheory.SimpleFunc.approx_apply /-
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
  exact hf measurableSet_Ici
#align measure_theory.simple_func.approx_apply MeasureTheory.SimpleFunc.approx_apply
-/

#print MeasureTheory.SimpleFunc.monotone_approx /-
theorem monotone_approx (i : ℕ → β) (f : α → β) : Monotone (approx i f) := fun n m h =>
  Finset.sup_mono <| Finset.range_subset.2 h
#align measure_theory.simple_func.monotone_approx MeasureTheory.SimpleFunc.monotone_approx
-/

#print MeasureTheory.SimpleFunc.approx_comp /-
theorem approx_comp [TopologicalSpace β] [OrderClosedTopology β] [MeasurableSpace β]
    [OpensMeasurableSpace β] [MeasurableSpace γ] {i : ℕ → β} {f : γ → β} {g : α → γ} {n : ℕ} (a : α)
    (hf : Measurable f) (hg : Measurable g) :
    (approx i (f ∘ g) n : α →ₛ β) a = (approx i f n : γ →ₛ β) (g a) := by
  rw [approx_apply _ hf, approx_apply _ (hf.comp hg)]
#align measure_theory.simple_func.approx_comp MeasureTheory.SimpleFunc.approx_comp
-/

end

#print MeasureTheory.SimpleFunc.iSup_approx_apply /-
theorem iSup_approx_apply [TopologicalSpace β] [CompleteLattice β] [OrderClosedTopology β] [Zero β]
    [MeasurableSpace β] [OpensMeasurableSpace β] (i : ℕ → β) (f : α → β) (a : α) (hf : Measurable f)
    (h_zero : (0 : β) = ⊥) : (⨆ n, (approx i f n : α →ₛ β) a) = ⨆ (k) (h : i k ≤ f a), i k :=
  by
  refine' le_antisymm (iSup_le fun n => _) (iSup_le fun k => iSup_le fun hk => _)
  · rw [approx_apply a hf, h_zero]
    refine' Finset.sup_le fun k hk => _
    split_ifs
    exact le_iSup_of_le k (le_iSup _ h)
    exact bot_le
  · refine' le_iSup_of_le (k + 1) _
    rw [approx_apply a hf]
    have : k ∈ Finset.range (k + 1) := Finset.mem_range.2 (Nat.lt_succ_self _)
    refine' le_trans (le_of_eq _) (Finset.le_sup this)
    rw [if_pos hk]
#align measure_theory.simple_func.supr_approx_apply MeasureTheory.SimpleFunc.iSup_approx_apply
-/

end Approx

section Eapprox

#print MeasureTheory.SimpleFunc.ennrealRatEmbed /-
/-- A sequence of `ℝ≥0∞`s such that its range is the set of non-negative rational numbers. -/
def ennrealRatEmbed (n : ℕ) : ℝ≥0∞ :=
  ENNReal.ofReal ((Encodable.decode ℚ n).getD (0 : ℚ))
#align measure_theory.simple_func.ennreal_rat_embed MeasureTheory.SimpleFunc.ennrealRatEmbed
-/

#print MeasureTheory.SimpleFunc.ennrealRatEmbed_encode /-
theorem ennrealRatEmbed_encode (q : ℚ) : ennrealRatEmbed (Encodable.encode q) = Real.toNNReal q :=
  by rw [ennreal_rat_embed, Encodable.encodek] <;> rfl
#align measure_theory.simple_func.ennreal_rat_embed_encode MeasureTheory.SimpleFunc.ennrealRatEmbed_encode
-/

#print MeasureTheory.SimpleFunc.eapprox /-
/-- Approximate a function `α → ℝ≥0∞` by a sequence of simple functions. -/
def eapprox : (α → ℝ≥0∞) → ℕ → α →ₛ ℝ≥0∞ :=
  approx ennrealRatEmbed
#align measure_theory.simple_func.eapprox MeasureTheory.SimpleFunc.eapprox
-/

#print MeasureTheory.SimpleFunc.eapprox_lt_top /-
theorem eapprox_lt_top (f : α → ℝ≥0∞) (n : ℕ) (a : α) : eapprox f n a < ∞ :=
  by
  simp only [eapprox, approx, finset_sup_apply, Finset.sup_lt_iff, WithTop.zero_lt_top,
    Finset.mem_range, ENNReal.bot_eq_zero, restrict]
  intro b hb
  split_ifs
  · simp only [coe_zero, coe_piecewise, piecewise_eq_indicator, coe_const]
    calc
      {a : α | ennreal_rat_embed b ≤ f a}.indicator (fun x => ennreal_rat_embed b) a ≤
          ennreal_rat_embed b :=
        indicator_le_self _ _ a
      _ < ⊤ := ENNReal.coe_lt_top
  · exact WithTop.zero_lt_top
#align measure_theory.simple_func.eapprox_lt_top MeasureTheory.SimpleFunc.eapprox_lt_top
-/

#print MeasureTheory.SimpleFunc.monotone_eapprox /-
@[mono]
theorem monotone_eapprox (f : α → ℝ≥0∞) : Monotone (eapprox f) :=
  monotone_approx _ f
#align measure_theory.simple_func.monotone_eapprox MeasureTheory.SimpleFunc.monotone_eapprox
-/

#print MeasureTheory.SimpleFunc.iSup_eapprox_apply /-
theorem iSup_eapprox_apply (f : α → ℝ≥0∞) (hf : Measurable f) (a : α) :
    (⨆ n, (eapprox f n : α →ₛ ℝ≥0∞) a) = f a :=
  by
  rw [eapprox, supr_approx_apply ennreal_rat_embed f a hf rfl]
  refine' le_antisymm (iSup_le fun i => iSup_le fun hi => hi) (le_of_not_gt _)
  intro h
  rcases ENNReal.lt_iff_exists_rat_btwn.1 h with ⟨q, hq, lt_q, q_lt⟩
  have :
    (Real.toNNReal q : ℝ≥0∞) ≤ ⨆ (k : ℕ) (h : ennreal_rat_embed k ≤ f a), ennreal_rat_embed k :=
    by
    refine' le_iSup_of_le (Encodable.encode q) _
    rw [ennreal_rat_embed_encode q]
    refine' le_iSup_of_le (le_of_lt q_lt) _
    exact le_rfl
  exact lt_irrefl _ (lt_of_le_of_lt this lt_q)
#align measure_theory.simple_func.supr_eapprox_apply MeasureTheory.SimpleFunc.iSup_eapprox_apply
-/

#print MeasureTheory.SimpleFunc.eapprox_comp /-
theorem eapprox_comp [MeasurableSpace γ] {f : γ → ℝ≥0∞} {g : α → γ} {n : ℕ} (hf : Measurable f)
    (hg : Measurable g) : (eapprox (f ∘ g) n : α → ℝ≥0∞) = (eapprox f n : γ →ₛ ℝ≥0∞) ∘ g :=
  funext fun a => approx_comp a hf hg
#align measure_theory.simple_func.eapprox_comp MeasureTheory.SimpleFunc.eapprox_comp
-/

#print MeasureTheory.SimpleFunc.eapproxDiff /-
/-- Approximate a function `α → ℝ≥0∞` by a series of simple functions taking their values
in `ℝ≥0`. -/
def eapproxDiff (f : α → ℝ≥0∞) : ∀ n : ℕ, α →ₛ ℝ≥0
  | 0 => (eapprox f 0).map ENNReal.toNNReal
  | n + 1 => (eapprox f (n + 1) - eapprox f n).map ENNReal.toNNReal
#align measure_theory.simple_func.eapprox_diff MeasureTheory.SimpleFunc.eapproxDiff
-/

#print MeasureTheory.SimpleFunc.sum_eapproxDiff /-
theorem sum_eapproxDiff (f : α → ℝ≥0∞) (n : ℕ) (a : α) :
    ∑ k in Finset.range (n + 1), (eapproxDiff f k a : ℝ≥0∞) = eapprox f n a :=
  by
  induction' n with n IH
  · simp only [Nat.zero_eq, Finset.sum_singleton, Finset.range_one]; rfl
  · rw [Finset.sum_range_succ, Nat.succ_eq_add_one, IH, eapprox_diff, coe_map, Function.comp_apply,
      coe_sub, Pi.sub_apply, ENNReal.coe_toNNReal,
      add_tsub_cancel_of_le (monotone_eapprox f (Nat.le_succ _) _)]
    apply (lt_of_le_of_lt _ (eapprox_lt_top f (n + 1) a)).Ne
    rw [tsub_le_iff_right]
    exact le_self_add
#align measure_theory.simple_func.sum_eapprox_diff MeasureTheory.SimpleFunc.sum_eapproxDiff
-/

#print MeasureTheory.SimpleFunc.tsum_eapproxDiff /-
theorem tsum_eapproxDiff (f : α → ℝ≥0∞) (hf : Measurable f) (a : α) :
    ∑' n, (eapproxDiff f n a : ℝ≥0∞) = f a := by
  simp_rw [ENNReal.tsum_eq_iSup_nat' (tendsto_add_at_top_nat 1), sum_eapprox_diff,
    supr_eapprox_apply f hf a]
#align measure_theory.simple_func.tsum_eapprox_diff MeasureTheory.SimpleFunc.tsum_eapproxDiff
-/

end Eapprox

end Measurable

section Measure

variable {m : MeasurableSpace α} {μ ν : Measure α}

#print MeasureTheory.SimpleFunc.lintegral /-
/-- Integral of a simple function whose codomain is `ℝ≥0∞`. -/
def lintegral {m : MeasurableSpace α} (f : α →ₛ ℝ≥0∞) (μ : Measure α) : ℝ≥0∞ :=
  ∑ x in f.range, x * μ (f ⁻¹' {x})
#align measure_theory.simple_func.lintegral MeasureTheory.SimpleFunc.lintegral
-/

#print MeasureTheory.SimpleFunc.lintegral_eq_of_subset /-
theorem lintegral_eq_of_subset (f : α →ₛ ℝ≥0∞) {s : Finset ℝ≥0∞}
    (hs : ∀ x, f x ≠ 0 → μ (f ⁻¹' {f x}) ≠ 0 → f x ∈ s) :
    f.lintegral μ = ∑ x in s, x * μ (f ⁻¹' {x}) :=
  by
  refine' Finset.sum_bij_ne_zero (fun r _ _ => r) _ _ _ _
  · simpa only [forall_range_iff, mul_ne_zero_iff, and_imp]
  · intros; assumption
  · intro b _ hb
    refine' ⟨b, _, hb, rfl⟩
    rw [mem_range, ← preimage_singleton_nonempty]
    exact nonempty_of_measure_ne_zero (mul_ne_zero_iff.1 hb).2
  · intros; rfl
#align measure_theory.simple_func.lintegral_eq_of_subset MeasureTheory.SimpleFunc.lintegral_eq_of_subset
-/

#print MeasureTheory.SimpleFunc.lintegral_eq_of_subset' /-
theorem lintegral_eq_of_subset' (f : α →ₛ ℝ≥0∞) {s : Finset ℝ≥0∞} (hs : f.range \ {0} ⊆ s) :
    f.lintegral μ = ∑ x in s, x * μ (f ⁻¹' {x}) :=
  f.lintegral_eq_of_subset fun x hfx _ =>
    hs <| Finset.mem_sdiff.2 ⟨f.mem_range_self x, mt Finset.mem_singleton.1 hfx⟩
#align measure_theory.simple_func.lintegral_eq_of_subset' MeasureTheory.SimpleFunc.lintegral_eq_of_subset'
-/

#print MeasureTheory.SimpleFunc.map_lintegral /-
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
  · intro x; simp only [Finset.mem_filter]; rintro ⟨_, h⟩; rw [h]
#align measure_theory.simple_func.map_lintegral MeasureTheory.SimpleFunc.map_lintegral
-/

#print MeasureTheory.SimpleFunc.add_lintegral /-
theorem add_lintegral (f g : α →ₛ ℝ≥0∞) : (f + g).lintegral μ = f.lintegral μ + g.lintegral μ :=
  calc
    (f + g).lintegral μ =
        ∑ x in (pair f g).range, (x.1 * μ (pair f g ⁻¹' {x}) + x.2 * μ (pair f g ⁻¹' {x})) :=
      by rw [add_eq_map₂, map_lintegral] <;> exact Finset.sum_congr rfl fun a ha => add_mul _ _ _
    _ =
        ∑ x in (pair f g).range, x.1 * μ (pair f g ⁻¹' {x}) +
          ∑ x in (pair f g).range, x.2 * μ (pair f g ⁻¹' {x}) :=
      by rw [Finset.sum_add_distrib]
    _ = ((pair f g).map Prod.fst).lintegral μ + ((pair f g).map Prod.snd).lintegral μ := by
      rw [map_lintegral, map_lintegral]
    _ = lintegral f μ + lintegral g μ := rfl
#align measure_theory.simple_func.add_lintegral MeasureTheory.SimpleFunc.add_lintegral
-/

#print MeasureTheory.SimpleFunc.const_mul_lintegral /-
theorem const_mul_lintegral (f : α →ₛ ℝ≥0∞) (x : ℝ≥0∞) :
    (const α x * f).lintegral μ = x * f.lintegral μ :=
  calc
    (f.map fun a => x * a).lintegral μ = ∑ r in f.range, x * r * μ (f ⁻¹' {r}) := map_lintegral _ _
    _ = ∑ r in f.range, x * (r * μ (f ⁻¹' {r})) :=
      (Finset.sum_congr rfl fun a ha => mul_assoc _ _ _)
    _ = x * f.lintegral μ := Finset.mul_sum.symm
#align measure_theory.simple_func.const_mul_lintegral MeasureTheory.SimpleFunc.const_mul_lintegral
-/

#print MeasureTheory.SimpleFunc.lintegralₗ /-
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
-/

#print MeasureTheory.SimpleFunc.zero_lintegral /-
@[simp]
theorem zero_lintegral : (0 : α →ₛ ℝ≥0∞).lintegral μ = 0 :=
  LinearMap.ext_iff.1 lintegralₗ.map_zero μ
#align measure_theory.simple_func.zero_lintegral MeasureTheory.SimpleFunc.zero_lintegral
-/

#print MeasureTheory.SimpleFunc.lintegral_add /-
theorem lintegral_add {ν} (f : α →ₛ ℝ≥0∞) : f.lintegral (μ + ν) = f.lintegral μ + f.lintegral ν :=
  (lintegralₗ f).map_add μ ν
#align measure_theory.simple_func.lintegral_add MeasureTheory.SimpleFunc.lintegral_add
-/

#print MeasureTheory.SimpleFunc.lintegral_smul /-
theorem lintegral_smul (f : α →ₛ ℝ≥0∞) (c : ℝ≥0∞) : f.lintegral (c • μ) = c • f.lintegral μ :=
  (lintegralₗ f).map_smul c μ
#align measure_theory.simple_func.lintegral_smul MeasureTheory.SimpleFunc.lintegral_smul
-/

#print MeasureTheory.SimpleFunc.lintegral_zero /-
@[simp]
theorem lintegral_zero [MeasurableSpace α] (f : α →ₛ ℝ≥0∞) : f.lintegral 0 = 0 :=
  (lintegralₗ f).map_zero
#align measure_theory.simple_func.lintegral_zero MeasureTheory.SimpleFunc.lintegral_zero
-/

#print MeasureTheory.SimpleFunc.lintegral_sum /-
theorem lintegral_sum {m : MeasurableSpace α} {ι} (f : α →ₛ ℝ≥0∞) (μ : ι → Measure α) :
    f.lintegral (Measure.sum μ) = ∑' i, f.lintegral (μ i) :=
  by
  simp only [lintegral, measure.sum_apply, f.measurable_set_preimage, ← Finset.tsum_subtype, ←
    ENNReal.tsum_mul_left]
  apply ENNReal.tsum_comm
#align measure_theory.simple_func.lintegral_sum MeasureTheory.SimpleFunc.lintegral_sum
-/

#print MeasureTheory.SimpleFunc.restrict_lintegral /-
theorem restrict_lintegral (f : α →ₛ ℝ≥0∞) {s : Set α} (hs : MeasurableSet s) :
    (restrict f s).lintegral μ = ∑ r in f.range, r * μ (f ⁻¹' {r} ∩ s) :=
  calc
    (restrict f s).lintegral μ = ∑ r in f.range, r * μ (restrict f s ⁻¹' {r}) :=
      lintegral_eq_of_subset _ fun x hx =>
        if hxs : x ∈ s then fun _ => by
          simp only [f.restrict_apply hs, indicator_of_mem hxs, mem_range_self]
        else False.elim <| hx <| by simp [*]
    _ = ∑ r in f.range, r * μ (f ⁻¹' {r} ∩ s) :=
      Finset.sum_congr rfl <|
        forall_range_iff.2 fun b =>
          if hb : f b = 0 then by simp only [hb, MulZeroClass.zero_mul]
          else by rw [restrict_preimage_singleton _ hs hb, inter_comm]
#align measure_theory.simple_func.restrict_lintegral MeasureTheory.SimpleFunc.restrict_lintegral
-/

#print MeasureTheory.SimpleFunc.lintegral_restrict /-
theorem lintegral_restrict {m : MeasurableSpace α} (f : α →ₛ ℝ≥0∞) (s : Set α) (μ : Measure α) :
    f.lintegral (μ.restrict s) = ∑ y in f.range, y * μ (f ⁻¹' {y} ∩ s) := by
  simp only [lintegral, measure.restrict_apply, f.measurable_set_preimage]
#align measure_theory.simple_func.lintegral_restrict MeasureTheory.SimpleFunc.lintegral_restrict
-/

#print MeasureTheory.SimpleFunc.restrict_lintegral_eq_lintegral_restrict /-
theorem restrict_lintegral_eq_lintegral_restrict (f : α →ₛ ℝ≥0∞) {s : Set α}
    (hs : MeasurableSet s) : (restrict f s).lintegral μ = f.lintegral (μ.restrict s) := by
  rw [f.restrict_lintegral hs, lintegral_restrict]
#align measure_theory.simple_func.restrict_lintegral_eq_lintegral_restrict MeasureTheory.SimpleFunc.restrict_lintegral_eq_lintegral_restrict
-/

#print MeasureTheory.SimpleFunc.const_lintegral /-
theorem const_lintegral (c : ℝ≥0∞) : (const α c).lintegral μ = c * μ univ :=
  by
  rw [lintegral]
  cases isEmpty_or_nonempty α
  · simp [μ.eq_zero_of_is_empty]
  · simp [preimage_const_of_mem]
#align measure_theory.simple_func.const_lintegral MeasureTheory.SimpleFunc.const_lintegral
-/

#print MeasureTheory.SimpleFunc.const_lintegral_restrict /-
theorem const_lintegral_restrict (c : ℝ≥0∞) (s : Set α) :
    (const α c).lintegral (μ.restrict s) = c * μ s := by
  rw [const_lintegral, measure.restrict_apply MeasurableSet.univ, univ_inter]
#align measure_theory.simple_func.const_lintegral_restrict MeasureTheory.SimpleFunc.const_lintegral_restrict
-/

#print MeasureTheory.SimpleFunc.restrict_const_lintegral /-
theorem restrict_const_lintegral (c : ℝ≥0∞) {s : Set α} (hs : MeasurableSet s) :
    ((const α c).restrict s).lintegral μ = c * μ s := by
  rw [restrict_lintegral_eq_lintegral_restrict _ hs, const_lintegral_restrict]
#align measure_theory.simple_func.restrict_const_lintegral MeasureTheory.SimpleFunc.restrict_const_lintegral
-/

#print MeasureTheory.SimpleFunc.le_sup_lintegral /-
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
-/

#print MeasureTheory.SimpleFunc.lintegral_mono /-
/-- `simple_func.lintegral` is monotone both in function and in measure. -/
@[mono]
theorem lintegral_mono {f g : α →ₛ ℝ≥0∞} (hfg : f ≤ g) (hμν : μ ≤ ν) :
    f.lintegral μ ≤ g.lintegral ν :=
  calc
    f.lintegral μ ≤ f.lintegral μ ⊔ g.lintegral μ := le_sup_left
    _ ≤ (f ⊔ g).lintegral μ := (le_sup_lintegral _ _)
    _ = g.lintegral μ := by rw [sup_of_le_right hfg]
    _ ≤ g.lintegral ν :=
      Finset.sum_le_sum fun y hy => ENNReal.mul_left_mono <| hμν _ (g.measurableSet_preimage _)
#align measure_theory.simple_func.lintegral_mono MeasureTheory.SimpleFunc.lintegral_mono
-/

#print MeasureTheory.SimpleFunc.lintegral_eq_of_measure_preimage /-
/-- `simple_func.lintegral` depends only on the measures of `f ⁻¹' {y}`. -/
theorem lintegral_eq_of_measure_preimage [MeasurableSpace β] {f : α →ₛ ℝ≥0∞} {g : β →ₛ ℝ≥0∞}
    {ν : Measure β} (H : ∀ y, μ (f ⁻¹' {y}) = ν (g ⁻¹' {y})) : f.lintegral μ = g.lintegral ν :=
  by
  simp only [lintegral, ← H]
  apply lintegral_eq_of_subset
  simp only [H]
  intros
  exact mem_range_of_measure_ne_zero ‹_›
#align measure_theory.simple_func.lintegral_eq_of_measure_preimage MeasureTheory.SimpleFunc.lintegral_eq_of_measure_preimage
-/

#print MeasureTheory.SimpleFunc.lintegral_congr /-
/-- If two simple functions are equal a.e., then their `lintegral`s are equal. -/
theorem lintegral_congr {f g : α →ₛ ℝ≥0∞} (h : f =ᵐ[μ] g) : f.lintegral μ = g.lintegral μ :=
  lintegral_eq_of_measure_preimage fun y =>
    measure_congr <| Eventually.set_eq <| h.mono fun x hx => by simp [hx]
#align measure_theory.simple_func.lintegral_congr MeasureTheory.SimpleFunc.lintegral_congr
-/

#print MeasureTheory.SimpleFunc.lintegral_map' /-
theorem lintegral_map' {β} [MeasurableSpace β] {μ' : Measure β} (f : α →ₛ ℝ≥0∞) (g : β →ₛ ℝ≥0∞)
    (m' : α → β) (eq : ∀ a, f a = g (m' a)) (h : ∀ s, MeasurableSet s → μ' s = μ (m' ⁻¹' s)) :
    f.lintegral μ = g.lintegral μ' :=
  lintegral_eq_of_measure_preimage fun y => by simp only [preimage, Eq];
    exact (h (g ⁻¹' {y}) (g.measurable_set_preimage _)).symm
#align measure_theory.simple_func.lintegral_map' MeasureTheory.SimpleFunc.lintegral_map'
-/

#print MeasureTheory.SimpleFunc.lintegral_map /-
theorem lintegral_map {β} [MeasurableSpace β] (g : β →ₛ ℝ≥0∞) {f : α → β} (hf : Measurable f) :
    g.lintegral (Measure.map f μ) = (g.comp f hf).lintegral μ :=
  Eq.symm <| lintegral_map' _ _ f (fun a => rfl) fun s hs => Measure.map_apply hf hs
#align measure_theory.simple_func.lintegral_map MeasureTheory.SimpleFunc.lintegral_map
-/

end Measure

section FinMeasSupp

open Finset Function

#print MeasureTheory.SimpleFunc.support_eq /-
theorem support_eq [MeasurableSpace α] [Zero β] (f : α →ₛ β) :
    support f = ⋃ y ∈ f.range.filterₓ fun y => y ≠ 0, f ⁻¹' {y} :=
  Set.ext fun x => by
    simp only [mem_support, Set.mem_preimage, mem_filter, mem_range_self, true_and_iff, exists_prop,
      mem_Union, Set.mem_range, mem_singleton_iff, exists_eq_right']
#align measure_theory.simple_func.support_eq MeasureTheory.SimpleFunc.support_eq
-/

variable {m : MeasurableSpace α} [Zero β] [Zero γ] {μ : Measure α} {f : α →ₛ β}

#print MeasureTheory.SimpleFunc.measurableSet_support /-
theorem measurableSet_support [MeasurableSpace α] (f : α →ₛ β) : MeasurableSet (support f) := by
  rw [f.support_eq]; exact Finset.measurableSet_biUnion _ fun y hy => measurable_set_fiber _ _
#align measure_theory.simple_func.measurable_set_support MeasureTheory.SimpleFunc.measurableSet_support
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp /-
/-- A `simple_func` has finite measure support if it is equal to `0` outside of a set of finite
measure. -/
protected def FinMeasSupp {m : MeasurableSpace α} (f : α →ₛ β) (μ : Measure α) : Prop :=
  f =ᶠ[μ.cofinite] 0
#align measure_theory.simple_func.fin_meas_supp MeasureTheory.SimpleFunc.FinMeasSupp
-/

#print MeasureTheory.SimpleFunc.finMeasSupp_iff_support /-
theorem finMeasSupp_iff_support : f.FinMeasSupp μ ↔ μ (support f) < ∞ :=
  Iff.rfl
#align measure_theory.simple_func.fin_meas_supp_iff_support MeasureTheory.SimpleFunc.finMeasSupp_iff_support
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (y «expr ≠ » 0) -/
#print MeasureTheory.SimpleFunc.finMeasSupp_iff /-
theorem finMeasSupp_iff : f.FinMeasSupp μ ↔ ∀ (y) (_ : y ≠ 0), μ (f ⁻¹' {y}) < ∞ :=
  by
  constructor
  · refine' fun h y hy => lt_of_le_of_lt (measure_mono _) h
    exact fun x hx (H : f x = 0) => hy <| H ▸ Eq.symm hx
  · intro H
    rw [fin_meas_supp_iff_support, support_eq]
    refine' lt_of_le_of_lt (measure_bUnion_finset_le _ _) (sum_lt_top _)
    exact fun y hy => (H y (Finset.mem_filter.1 hy).2).Ne
#align measure_theory.simple_func.fin_meas_supp_iff MeasureTheory.SimpleFunc.finMeasSupp_iff
-/

namespace FinMeasSupp

#print MeasureTheory.SimpleFunc.FinMeasSupp.meas_preimage_singleton_ne_zero /-
theorem meas_preimage_singleton_ne_zero (h : f.FinMeasSupp μ) {y : β} (hy : y ≠ 0) :
    μ (f ⁻¹' {y}) < ∞ :=
  finMeasSupp_iff.1 h y hy
#align measure_theory.simple_func.fin_meas_supp.meas_preimage_singleton_ne_zero MeasureTheory.SimpleFunc.FinMeasSupp.meas_preimage_singleton_ne_zero
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.map /-
protected theorem map {g : β → γ} (hf : f.FinMeasSupp μ) (hg : g 0 = 0) : (f.map g).FinMeasSupp μ :=
  flip lt_of_le_of_lt hf (measure_mono <| support_comp_subset hg f)
#align measure_theory.simple_func.fin_meas_supp.map MeasureTheory.SimpleFunc.FinMeasSupp.map
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.of_map /-
theorem of_map {g : β → γ} (h : (f.map g).FinMeasSupp μ) (hg : ∀ b, g b = 0 → b = 0) :
    f.FinMeasSupp μ :=
  flip lt_of_le_of_lt h <| measure_mono <| support_subset_comp hg _
#align measure_theory.simple_func.fin_meas_supp.of_map MeasureTheory.SimpleFunc.FinMeasSupp.of_map
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.map_iff /-
theorem map_iff {g : β → γ} (hg : ∀ {b}, g b = 0 ↔ b = 0) :
    (f.map g).FinMeasSupp μ ↔ f.FinMeasSupp μ :=
  ⟨fun h => h.of_map fun b => hg.1, fun h => h.map <| hg.2 rfl⟩
#align measure_theory.simple_func.fin_meas_supp.map_iff MeasureTheory.SimpleFunc.FinMeasSupp.map_iff
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.pair /-
protected theorem pair {g : α →ₛ γ} (hf : f.FinMeasSupp μ) (hg : g.FinMeasSupp μ) :
    (pair f g).FinMeasSupp μ :=
  calc
    μ (support <| pair f g) = μ (support f ∪ support g) := congr_arg μ <| support_prod_mk f g
    _ ≤ μ (support f) + μ (support g) := (measure_union_le _ _)
    _ < _ := add_lt_top.2 ⟨hf, hg⟩
#align measure_theory.simple_func.fin_meas_supp.pair MeasureTheory.SimpleFunc.FinMeasSupp.pair
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.map₂ /-
protected theorem map₂ [Zero δ] (hf : f.FinMeasSupp μ) {g : α →ₛ γ} (hg : g.FinMeasSupp μ)
    {op : β → γ → δ} (H : op 0 0 = 0) : ((pair f g).map (Function.uncurry op)).FinMeasSupp μ :=
  (hf.pair hg).map H
#align measure_theory.simple_func.fin_meas_supp.map₂ MeasureTheory.SimpleFunc.FinMeasSupp.map₂
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.add /-
protected theorem add {β} [AddMonoid β] {f g : α →ₛ β} (hf : f.FinMeasSupp μ)
    (hg : g.FinMeasSupp μ) : (f + g).FinMeasSupp μ := by rw [add_eq_map₂];
  exact hf.map₂ hg (zero_add 0)
#align measure_theory.simple_func.fin_meas_supp.add MeasureTheory.SimpleFunc.FinMeasSupp.add
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.mul /-
protected theorem mul {β} [MonoidWithZero β] {f g : α →ₛ β} (hf : f.FinMeasSupp μ)
    (hg : g.FinMeasSupp μ) : (f * g).FinMeasSupp μ := by rw [mul_eq_map₂];
  exact hf.map₂ hg (MulZeroClass.zero_mul 0)
#align measure_theory.simple_func.fin_meas_supp.mul MeasureTheory.SimpleFunc.FinMeasSupp.mul
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.lintegral_lt_top /-
theorem lintegral_lt_top {f : α →ₛ ℝ≥0∞} (hm : f.FinMeasSupp μ) (hf : ∀ᵐ a ∂μ, f a ≠ ∞) :
    f.lintegral μ < ∞ := by
  refine' sum_lt_top fun a ha => _
  rcases eq_or_ne a ∞ with (rfl | ha)
  · simp only [ae_iff, Ne.def, Classical.not_not] at hf 
    simp [Set.preimage, hf]
  · by_cases ha0 : a = 0
    · subst a; rwa [MulZeroClass.zero_mul]
    · exact mul_ne_top ha (fin_meas_supp_iff.1 hm _ ha0).Ne
#align measure_theory.simple_func.fin_meas_supp.lintegral_lt_top MeasureTheory.SimpleFunc.FinMeasSupp.lintegral_lt_top
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.of_lintegral_ne_top /-
theorem of_lintegral_ne_top {f : α →ₛ ℝ≥0∞} (h : f.lintegral μ ≠ ∞) : f.FinMeasSupp μ :=
  by
  refine' fin_meas_supp_iff.2 fun b hb => _
  rw [f.lintegral_eq_of_subset' (Finset.subset_insert b _)] at h 
  refine' ENNReal.lt_top_of_mul_ne_top_right _ hb
  exact (lt_top_of_sum_ne_top h (Finset.mem_insert_self _ _)).Ne
#align measure_theory.simple_func.fin_meas_supp.of_lintegral_ne_top MeasureTheory.SimpleFunc.FinMeasSupp.of_lintegral_ne_top
-/

#print MeasureTheory.SimpleFunc.FinMeasSupp.iff_lintegral_lt_top /-
theorem iff_lintegral_lt_top {f : α →ₛ ℝ≥0∞} (hf : ∀ᵐ a ∂μ, f a ≠ ∞) :
    f.FinMeasSupp μ ↔ f.lintegral μ < ∞ :=
  ⟨fun h => h.lintegral_lt_top hf, fun h => of_lintegral_ne_top h.Ne⟩
#align measure_theory.simple_func.fin_meas_supp.iff_lintegral_lt_top MeasureTheory.SimpleFunc.FinMeasSupp.iff_lintegral_lt_top
-/

end FinMeasSupp

end FinMeasSupp

#print MeasureTheory.SimpleFunc.induction /-
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
  · intro f hf; rw [Finset.coe_empty, diff_eq_empty, range_subset_singleton] at hf 
    convert h_ind 0 MeasurableSet.univ; ext x; simp [hf]
  · intro x s hxs ih f hf
    have mx := f.measurable_set_preimage {x}
    let g := simple_func.piecewise (f ⁻¹' {x}) mx 0 f
    have Pg : P g := by
      apply ih; simp only [g, simple_func.coe_piecewise, range_piecewise]
      rw [image_compl_preimage, union_diff_distrib, diff_diff_comm, hf, Finset.coe_insert,
        insert_diff_self_of_not_mem, diff_eq_empty.mpr, Set.empty_union]
      · rw [Set.image_subset_iff]; convert Set.subset_univ _
        exact preimage_const_of_mem (mem_singleton _)
      · rwa [Finset.mem_coe]
    convert h_add _ Pg (h_ind x mx)
    · ext1 y; by_cases hy : y ∈ f ⁻¹' {x} <;> [simpa [hy]; simp [hy]]
    rw [disjoint_iff_inf_le]
    rintro y; by_cases hy : y ∈ f ⁻¹' {x} <;> simp [hy]
#align measure_theory.simple_func.induction MeasureTheory.SimpleFunc.induction
-/

end SimpleFunc

end MeasureTheory

open MeasureTheory MeasureTheory.SimpleFunc

#print Measurable.ennreal_induction /-
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
  · ext1 x; rw [supr_eapprox_apply f hf]
  ·
    exact fun n =>
      simple_func.induction (fun c s hs => h_ind c hs)
        (fun f g hfg hf hg => h_add hfg f.Measurable g.Measurable hf hg) (eapprox f n)
#align measurable.ennreal_induction Measurable.ennreal_induction
-/

