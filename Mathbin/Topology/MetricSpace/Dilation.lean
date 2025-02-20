/-
Copyright (c) 2022 Hanting Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Dilations of emetric and metric spaces
Authors: Hanting Zhang

! This file was ported from Lean 3 source module topology.metric_space.dilation
! leanprover-community/mathlib commit 30faa0c3618ce1472bf6305ae0e3fa56affa3f95
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.MetricSpace.Antilipschitz
import Mathbin.Data.FunLike.Basic

/-!
# Dilations

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define dilations, i.e., maps between emetric spaces that satisfy
`edist (f x) (f y) = r * edist x y` for some `r ∉ {0, ∞}`.

The value `r = 0` is not allowed because we want dilations of (e)metric spaces to be automatically
injective. The value `r = ∞` is not allowed because this way we can define `dilation.ratio f : ℝ≥0`,
not `dilation.ratio f : ℝ≥0∞`. Also, we do not often need maps sending distinct points to points at
infinite distance.

## Main defintions

* `dilation.ratio f : ℝ≥0`: the value of `r` in the relation above, defaulting to 1 in the case
  where it is not well-defined.

## Implementation notes

The type of dilations defined in this file are also referred to as "similarities" or "similitudes"
by other authors. The name `dilation` was choosen to match the Wikipedia name.

Since a lot of elementary properties don't require `eq_of_dist_eq_zero` we start setting up the
theory for `pseudo_emetric_space` and we specialize to `pseudo_metric_space` and `metric_space` when
needed.

## TODO

- Introduce dilation equivs.
- Refactor the `isometry` API to match the `*_hom_class` API below.

## References

- https://en.wikipedia.org/wiki/Dilation_(metric_space)
- [Marcel Berger, *Geometry*][berger1987]
-/


noncomputable section

open Function Set

open scoped Topology ENNReal NNReal Classical

section Defs

variable (α : Type _) (β : Type _) [PseudoEMetricSpace α] [PseudoEMetricSpace β]

#print Dilation /-
/-- A dilation is a map that uniformly scales the edistance between any two points.  -/
structure Dilation where
  toFun : α → β
  edist_eq' : ∃ r : ℝ≥0, r ≠ 0 ∧ ∀ x y : α, edist (to_fun x) (to_fun y) = r * edist x y
#align dilation Dilation
-/

#print DilationClass /-
/-- `dilation_class F α β r` states that `F` is a type of `r`-dilations.
You should extend this typeclass when you extend `dilation`.
-/
class DilationClass (F : Type _) (α β : outParam <| Type _) [PseudoEMetricSpace α]
    [PseudoEMetricSpace β] extends FunLike F α fun _ => β where
  edist_eq' : ∀ f : F, ∃ r : ℝ≥0, r ≠ 0 ∧ ∀ x y : α, edist (f x) (f y) = r * edist x y
#align dilation_class DilationClass
-/

end Defs

namespace Dilation

variable {α : Type _} {β : Type _} {γ : Type _} {F : Type _} {G : Type _}

section Setup

variable [PseudoEMetricSpace α] [PseudoEMetricSpace β]

#print Dilation.toDilationClass /-
instance toDilationClass : DilationClass (Dilation α β) α β
    where
  coe := toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  edist_eq' f := edist_eq' f
#align dilation.to_dilation_class Dilation.toDilationClass
-/

instance : CoeFun (Dilation α β) fun _ => α → β :=
  FunLike.hasCoeToFun

#print Dilation.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe {f : Dilation α β} : f.toFun = (f : α → β) :=
  rfl
#align dilation.to_fun_eq_coe Dilation.toFun_eq_coe
-/

#print Dilation.coe_mk /-
@[simp]
theorem coe_mk (f : α → β) (h) : ⇑(⟨f, h⟩ : Dilation α β) = f :=
  rfl
#align dilation.coe_mk Dilation.coe_mk
-/

#print Dilation.congr_fun /-
theorem congr_fun {f g : Dilation α β} (h : f = g) (x : α) : f x = g x :=
  FunLike.congr_fun h x
#align dilation.congr_fun Dilation.congr_fun
-/

#print Dilation.congr_arg /-
theorem congr_arg (f : Dilation α β) {x y : α} (h : x = y) : f x = f y :=
  FunLike.congr_arg f h
#align dilation.congr_arg Dilation.congr_arg
-/

#print Dilation.ext /-
@[ext]
theorem ext {f g : Dilation α β} (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext f g h
#align dilation.ext Dilation.ext
-/

#print Dilation.ext_iff /-
theorem ext_iff {f g : Dilation α β} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align dilation.ext_iff Dilation.ext_iff
-/

#print Dilation.mk_coe /-
@[simp]
theorem mk_coe (f : Dilation α β) (h) : Dilation.mk f h = f :=
  ext fun _ => rfl
#align dilation.mk_coe Dilation.mk_coe
-/

#print Dilation.copy /-
/-- Copy of a `dilation` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
@[simps (config := { fullyApplied := false })]
protected def copy (f : Dilation α β) (f' : α → β) (h : f' = ⇑f) : Dilation α β
    where
  toFun := f'
  edist_eq' := h.symm ▸ f.edist_eq'
#align dilation.copy Dilation.copy
-/

#print Dilation.copy_eq_self /-
theorem copy_eq_self (f : Dilation α β) {f' : α → β} (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align dilation.copy_eq_self Dilation.copy_eq_self
-/

#print Dilation.ratio /-
/-- The ratio of a dilation `f`. If the ratio is undefined (i.e., the distance between any two
points in `α` is either zero or infinity), then we choose one as the ratio. -/
def ratio [DilationClass F α β] (f : F) : ℝ≥0 :=
  if ∀ x y : α, edist x y = 0 ∨ edist x y = ⊤ then 1 else (DilationClass.edist_eq' f).some
#align dilation.ratio Dilation.ratio
-/

#print Dilation.ratio_ne_zero /-
theorem ratio_ne_zero [DilationClass F α β] (f : F) : ratio f ≠ 0 :=
  by
  rw [ratio]; split_ifs
  · exact one_ne_zero
  exact (DilationClass.edist_eq' f).choose_spec.1
#align dilation.ratio_ne_zero Dilation.ratio_ne_zero
-/

#print Dilation.ratio_pos /-
theorem ratio_pos [DilationClass F α β] (f : F) : 0 < ratio f :=
  (ratio_ne_zero f).bot_lt
#align dilation.ratio_pos Dilation.ratio_pos
-/

#print Dilation.edist_eq /-
@[simp]
theorem edist_eq [DilationClass F α β] (f : F) (x y : α) :
    edist (f x) (f y) = ratio f * edist x y :=
  by
  rw [ratio]; split_ifs with key
  · rcases DilationClass.edist_eq' f with ⟨r, hne, hr⟩
    replace hr := hr x y
    cases key x y
    · simp only [hr, h, MulZeroClass.mul_zero]
    · simp [hr, h, hne]
  exact (DilationClass.edist_eq' f).choose_spec.2 x y
#align dilation.edist_eq Dilation.edist_eq
-/

#print Dilation.nndist_eq /-
@[simp]
theorem nndist_eq {α β F : Type _} [PseudoMetricSpace α] [PseudoMetricSpace β] [DilationClass F α β]
    (f : F) (x y : α) : nndist (f x) (f y) = ratio f * nndist x y := by
  simp only [← ENNReal.coe_eq_coe, ← edist_nndist, ENNReal.coe_mul, edist_eq]
#align dilation.nndist_eq Dilation.nndist_eq
-/

#print Dilation.dist_eq /-
@[simp]
theorem dist_eq {α β F : Type _} [PseudoMetricSpace α] [PseudoMetricSpace β] [DilationClass F α β]
    (f : F) (x y : α) : dist (f x) (f y) = ratio f * dist x y := by
  simp only [dist_nndist, nndist_eq, NNReal.coe_mul]
#align dilation.dist_eq Dilation.dist_eq
-/

#print Dilation.ratio_unique /-
/-- The `ratio` is equal to the distance ratio for any two points with nonzero finite distance.
`dist` and `nndist` versions below -/
theorem ratio_unique [DilationClass F α β] {f : F} {x y : α} {r : ℝ≥0} (h₀ : edist x y ≠ 0)
    (htop : edist x y ≠ ⊤) (hr : edist (f x) (f y) = r * edist x y) : r = ratio f := by
  simpa only [hr, ENNReal.mul_eq_mul_right h₀ htop, ENNReal.coe_eq_coe] using edist_eq f x y
#align dilation.ratio_unique Dilation.ratio_unique
-/

#print Dilation.ratio_unique_of_nndist_ne_zero /-
/-- The `ratio` is equal to the distance ratio for any two points
with nonzero finite distance; `nndist` version -/
theorem ratio_unique_of_nndist_ne_zero {α β F : Type _} [PseudoMetricSpace α] [PseudoMetricSpace β]
    [DilationClass F α β] {f : F} {x y : α} {r : ℝ≥0} (hxy : nndist x y ≠ 0)
    (hr : nndist (f x) (f y) = r * nndist x y) : r = ratio f :=
  ratio_unique (by rwa [edist_nndist, ENNReal.coe_ne_zero]) (edist_ne_top x y)
    (by rw [edist_nndist, edist_nndist, hr, ENNReal.coe_mul])
#align dilation.ratio_unique_of_nndist_ne_zero Dilation.ratio_unique_of_nndist_ne_zero
-/

#print Dilation.ratio_unique_of_dist_ne_zero /-
/-- The `ratio` is equal to the distance ratio for any two points
with nonzero finite distance; `dist` version -/
theorem ratio_unique_of_dist_ne_zero {α β} {F : Type _} [PseudoMetricSpace α] [PseudoMetricSpace β]
    [DilationClass F α β] {f : F} {x y : α} {r : ℝ≥0} (hxy : dist x y ≠ 0)
    (hr : dist (f x) (f y) = r * dist x y) : r = ratio f :=
  ratio_unique_of_nndist_ne_zero (NNReal.coe_ne_zero.1 hxy) <|
    NNReal.eq <| by rw [coe_nndist, hr, NNReal.coe_mul, coe_nndist]
#align dilation.ratio_unique_of_dist_ne_zero Dilation.ratio_unique_of_dist_ne_zero
-/

#print Dilation.mkOfNNDistEq /-
/-- Alternative `dilation` constructor when the distance hypothesis is over `nndist` -/
def mkOfNNDistEq {α β} [PseudoMetricSpace α] [PseudoMetricSpace β] (f : α → β)
    (h : ∃ r : ℝ≥0, r ≠ 0 ∧ ∀ x y : α, nndist (f x) (f y) = r * nndist x y) : Dilation α β
    where
  toFun := f
  edist_eq' := by
    rcases h with ⟨r, hne, h⟩
    refine' ⟨r, hne, fun x y => _⟩
    rw [edist_nndist, edist_nndist, ← ENNReal.coe_mul, h x y]
#align dilation.mk_of_nndist_eq Dilation.mkOfNNDistEq
-/

#print Dilation.coe_mkOfNNDistEq /-
@[simp]
theorem coe_mkOfNNDistEq {α β} [PseudoMetricSpace α] [PseudoMetricSpace β] (f : α → β) (h) :
    ⇑(mkOfNNDistEq f h : Dilation α β) = f :=
  rfl
#align dilation.coe_mk_of_nndist_eq Dilation.coe_mkOfNNDistEq
-/

#print Dilation.mk_coe_of_nndist_eq /-
@[simp]
theorem mk_coe_of_nndist_eq {α β} [PseudoMetricSpace α] [PseudoMetricSpace β] (f : Dilation α β)
    (h) : Dilation.mkOfNNDistEq f h = f :=
  ext fun _ => rfl
#align dilation.mk_coe_of_nndist_eq Dilation.mk_coe_of_nndist_eq
-/

#print Dilation.mkOfDistEq /-
/-- Alternative `dilation` constructor when the distance hypothesis is over `dist` -/
def mkOfDistEq {α β} [PseudoMetricSpace α] [PseudoMetricSpace β] (f : α → β)
    (h : ∃ r : ℝ≥0, r ≠ 0 ∧ ∀ x y : α, dist (f x) (f y) = r * dist x y) : Dilation α β :=
  mkOfNNDistEq f <|
    h.imp fun r hr =>
      ⟨hr.1, fun x y => NNReal.eq <| by rw [coe_nndist, hr.2, NNReal.coe_mul, coe_nndist]⟩
#align dilation.mk_of_dist_eq Dilation.mkOfDistEq
-/

#print Dilation.coe_mkOfDistEq /-
@[simp]
theorem coe_mkOfDistEq {α β} [PseudoMetricSpace α] [PseudoMetricSpace β] (f : α → β) (h) :
    ⇑(mkOfDistEq f h : Dilation α β) = f :=
  rfl
#align dilation.coe_mk_of_dist_eq Dilation.coe_mkOfDistEq
-/

#print Dilation.mk_coe_of_dist_eq /-
@[simp]
theorem mk_coe_of_dist_eq {α β} [PseudoMetricSpace α] [PseudoMetricSpace β] (f : Dilation α β) (h) :
    Dilation.mkOfDistEq f h = f :=
  ext fun _ => rfl
#align dilation.mk_coe_of_dist_eq Dilation.mk_coe_of_dist_eq
-/

end Setup

section PseudoEmetricDilation

variable [PseudoEMetricSpace α] [PseudoEMetricSpace β] [PseudoEMetricSpace γ]

variable [DilationClass F α β] [DilationClass G β γ]

variable (f : F) (g : G) {x y z : α} {s : Set α}

#print Dilation.lipschitz /-
theorem lipschitz : LipschitzWith (ratio f) (f : α → β) := fun x y => (edist_eq f x y).le
#align dilation.lipschitz Dilation.lipschitz
-/

#print Dilation.antilipschitz /-
theorem antilipschitz : AntilipschitzWith (ratio f)⁻¹ (f : α → β) := fun x y =>
  by
  have hr : ratio f ≠ 0 := ratio_ne_zero f
  exact_mod_cast
    (ENNReal.mul_le_iff_le_inv (ENNReal.coe_ne_zero.2 hr) ENNReal.coe_ne_top).1 (edist_eq f x y).ge
#align dilation.antilipschitz Dilation.antilipschitz
-/

#print Dilation.injective /-
/-- A dilation from an emetric space is injective -/
protected theorem injective {α : Type _} [EMetricSpace α] [DilationClass F α β] (f : F) :
    Injective f :=
  (antilipschitz f).Injective
#align dilation.injective Dilation.injective
-/

#print Dilation.id /-
/-- The identity is a dilation -/
protected def id (α) [PseudoEMetricSpace α] : Dilation α α
    where
  toFun := id
  edist_eq' := ⟨1, one_ne_zero, fun x y => by simp only [id.def, ENNReal.coe_one, one_mul]⟩
#align dilation.id Dilation.id
-/

instance : Inhabited (Dilation α α) :=
  ⟨Dilation.id α⟩

#print Dilation.coe_id /-
@[simp, protected]
theorem coe_id : ⇑(Dilation.id α) = id :=
  rfl
#align dilation.coe_id Dilation.coe_id
-/

#print Dilation.id_ratio /-
theorem id_ratio : ratio (Dilation.id α) = 1 :=
  by
  by_cases h : ∀ x y : α, edist x y = 0 ∨ edist x y = ∞
  · rw [ratio, if_pos h]
  · push_neg at h 
    rcases h with ⟨x, y, hne⟩
    refine' (ratio_unique hne.1 hne.2 _).symm
    simp
#align dilation.id_ratio Dilation.id_ratio
-/

#print Dilation.comp /-
/-- The composition of dilations is a dilation -/
def comp (g : Dilation β γ) (f : Dilation α β) : Dilation α γ
    where
  toFun := g ∘ f
  edist_eq' :=
    ⟨ratio g * ratio f, mul_ne_zero (ratio_ne_zero g) (ratio_ne_zero f), fun x y => by
      simp only [edist_eq, ENNReal.coe_mul]; ring⟩
#align dilation.comp Dilation.comp
-/

#print Dilation.comp_assoc /-
theorem comp_assoc {δ : Type _} [PseudoEMetricSpace δ] (f : Dilation α β) (g : Dilation β γ)
    (h : Dilation γ δ) : (h.comp g).comp f = h.comp (g.comp f) :=
  rfl
#align dilation.comp_assoc Dilation.comp_assoc
-/

#print Dilation.coe_comp /-
@[simp]
theorem coe_comp (g : Dilation β γ) (f : Dilation α β) : (g.comp f : α → γ) = g ∘ f :=
  rfl
#align dilation.coe_comp Dilation.coe_comp
-/

#print Dilation.comp_apply /-
theorem comp_apply (g : Dilation β γ) (f : Dilation α β) (x : α) : (g.comp f : α → γ) x = g (f x) :=
  rfl
#align dilation.comp_apply Dilation.comp_apply
-/

#print Dilation.comp_ratio /-
/-- Ratio of the composition `g.comp f` of two dilations is the product of their ratios. We assume
that the domain `α` of `f` is nontrivial, otherwise `ratio f = ratio (g.comp f) = 1` but `ratio g`
may have any value. -/
@[simp]
theorem comp_ratio {g : Dilation β γ} {f : Dilation α β}
    (hne : ∃ x y : α, edist x y ≠ 0 ∧ edist x y ≠ ⊤) : ratio (g.comp f) = ratio g * ratio f :=
  by
  rcases hne with ⟨x, y, hα⟩
  have hgf := (edist_eq (g.comp f) x y).symm
  simp only [dist_eq, coe_comp, ← mul_assoc, mul_eq_mul_right_iff] at hgf 
  rw [edist_eq, edist_eq, ← mul_assoc, ENNReal.mul_eq_mul_right hα.1 hα.2] at hgf 
  rwa [← ENNReal.coe_eq_coe, ENNReal.coe_mul]
#align dilation.comp_ratio Dilation.comp_ratio
-/

#print Dilation.comp_id /-
@[simp]
theorem comp_id (f : Dilation α β) : f.comp (Dilation.id α) = f :=
  ext fun x => rfl
#align dilation.comp_id Dilation.comp_id
-/

#print Dilation.id_comp /-
@[simp]
theorem id_comp (f : Dilation α β) : (Dilation.id β).comp f = f :=
  ext fun x => rfl
#align dilation.id_comp Dilation.id_comp
-/

instance : Monoid (Dilation α α) where
  one := Dilation.id α
  mul := comp
  mul_one := comp_id
  one_mul := id_comp
  mul_assoc f g h := comp_assoc _ _ _

#print Dilation.one_def /-
theorem one_def : (1 : Dilation α α) = Dilation.id α :=
  rfl
#align dilation.one_def Dilation.one_def
-/

#print Dilation.mul_def /-
theorem mul_def (f g : Dilation α α) : f * g = f.comp g :=
  rfl
#align dilation.mul_def Dilation.mul_def
-/

#print Dilation.coe_one /-
@[simp]
theorem coe_one : ⇑(1 : Dilation α α) = id :=
  rfl
#align dilation.coe_one Dilation.coe_one
-/

#print Dilation.coe_mul /-
@[simp]
theorem coe_mul (f g : Dilation α α) : ⇑(f * g) = f ∘ g :=
  rfl
#align dilation.coe_mul Dilation.coe_mul
-/

#print Dilation.cancel_right /-
theorem cancel_right {g₁ g₂ : Dilation β γ} {f : Dilation α β} (hf : Surjective f) :
    g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => Dilation.ext <| hf.forall.2 (ext_iff.1 h), fun h => h ▸ rfl⟩
#align dilation.cancel_right Dilation.cancel_right
-/

#print Dilation.cancel_left /-
theorem cancel_left {g : Dilation β γ} {f₁ f₂ : Dilation α β} (hg : Injective g) :
    g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => Dilation.ext fun x => hg <| by rw [← comp_apply, h, comp_apply], fun h => h ▸ rfl⟩
#align dilation.cancel_left Dilation.cancel_left
-/

#print Dilation.uniformInducing /-
/-- A dilation from a metric space is a uniform inducing map -/
protected theorem uniformInducing : UniformInducing (f : α → β) :=
  (antilipschitz f).UniformInducing (lipschitz f).UniformContinuous
#align dilation.uniform_inducing Dilation.uniformInducing
-/

#print Dilation.tendsto_nhds_iff /-
theorem tendsto_nhds_iff {ι : Type _} {g : ι → α} {a : Filter ι} {b : α} :
    Filter.Tendsto g a (𝓝 b) ↔ Filter.Tendsto ((f : α → β) ∘ g) a (𝓝 (f b)) :=
  (Dilation.uniformInducing f).Inducing.tendsto_nhds_iff
#align dilation.tendsto_nhds_iff Dilation.tendsto_nhds_iff
-/

#print Dilation.toContinuous /-
/-- A dilation is continuous. -/
theorem toContinuous : Continuous (f : α → β) :=
  (lipschitz f).Continuous
#align dilation.to_continuous Dilation.toContinuous
-/

#print Dilation.ediam_image /-
/-- Dilations scale the diameter by `ratio f` in pseudoemetric spaces. -/
theorem ediam_image (s : Set α) : EMetric.diam ((f : α → β) '' s) = ratio f * EMetric.diam s :=
  by
  refine' ((lipschitz f).ediam_image_le s).antisymm _
  apply ENNReal.mul_le_of_le_div'
  rw [div_eq_mul_inv, mul_comm, ← ENNReal.coe_inv]
  exacts [(antilipschitz f).le_mul_ediam_image s, ratio_ne_zero f]
#align dilation.ediam_image Dilation.ediam_image
-/

#print Dilation.ediam_range /-
/-- A dilation scales the diameter of the range by `ratio f`. -/
theorem ediam_range : EMetric.diam (range (f : α → β)) = ratio f * EMetric.diam (univ : Set α) := by
  rw [← image_univ]; exact ediam_image f univ
#align dilation.ediam_range Dilation.ediam_range
-/

#print Dilation.mapsTo_emetric_ball /-
/-- A dilation maps balls to balls and scales the radius by `ratio f`. -/
theorem mapsTo_emetric_ball (x : α) (r : ℝ≥0∞) :
    MapsTo (f : α → β) (EMetric.ball x r) (EMetric.ball (f x) (ratio f * r)) := fun y hy =>
  (edist_eq f y x).trans_lt <|
    (ENNReal.mul_lt_mul_left (ENNReal.coe_ne_zero.2 <| ratio_ne_zero f) ENNReal.coe_ne_top).2 hy
#align dilation.maps_to_emetric_ball Dilation.mapsTo_emetric_ball
-/

#print Dilation.mapsTo_emetric_closedBall /-
/-- A dilation maps closed balls to closed balls and scales the radius by `ratio f`. -/
theorem mapsTo_emetric_closedBall (x : α) (r' : ℝ≥0∞) :
    MapsTo (f : α → β) (EMetric.closedBall x r') (EMetric.closedBall (f x) (ratio f * r')) :=
  fun y hy => (edist_eq f y x).trans_le <| mul_le_mul_left' hy _
#align dilation.maps_to_emetric_closed_ball Dilation.mapsTo_emetric_closedBall
-/

#print Dilation.comp_continuousOn_iff /-
theorem comp_continuousOn_iff {γ} [TopologicalSpace γ] {g : γ → α} {s : Set γ} :
    ContinuousOn ((f : α → β) ∘ g) s ↔ ContinuousOn g s :=
  (Dilation.uniformInducing f).Inducing.continuousOn_iff.symm
#align dilation.comp_continuous_on_iff Dilation.comp_continuousOn_iff
-/

#print Dilation.comp_continuous_iff /-
theorem comp_continuous_iff {γ} [TopologicalSpace γ] {g : γ → α} :
    Continuous ((f : α → β) ∘ g) ↔ Continuous g :=
  (Dilation.uniformInducing f).Inducing.continuous_iff.symm
#align dilation.comp_continuous_iff Dilation.comp_continuous_iff
-/

end PseudoEmetricDilation

--section
section EmetricDilation

variable [EMetricSpace α]

#print Dilation.uniformEmbedding /-
/-- A dilation from a metric space is a uniform embedding -/
protected theorem uniformEmbedding [PseudoEMetricSpace β] [DilationClass F α β] (f : F) :
    UniformEmbedding f :=
  (antilipschitz f).UniformEmbedding (lipschitz f).UniformContinuous
#align dilation.uniform_embedding Dilation.uniformEmbedding
-/

#print Dilation.embedding /-
/-- A dilation from a metric space is an embedding -/
protected theorem embedding [PseudoEMetricSpace β] [DilationClass F α β] (f : F) :
    Embedding (f : α → β) :=
  (Dilation.uniformEmbedding f).Embedding
#align dilation.embedding Dilation.embedding
-/

#print Dilation.closedEmbedding /-
/-- A dilation from a complete emetric space is a closed embedding -/
protected theorem closedEmbedding [CompleteSpace α] [EMetricSpace β] [DilationClass F α β] (f : F) :
    ClosedEmbedding f :=
  (antilipschitz f).ClosedEmbedding (lipschitz f).UniformContinuous
#align dilation.closed_embedding Dilation.closedEmbedding
-/

end EmetricDilation

--section
section PseudoMetricDilation

variable [PseudoMetricSpace α] [PseudoMetricSpace β] [DilationClass F α β] (f : F)

#print Dilation.diam_image /-
/-- A dilation scales the diameter by `ratio f` in pseudometric spaces. -/
theorem diam_image (s : Set α) : Metric.diam ((f : α → β) '' s) = ratio f * Metric.diam s := by
  simp [Metric.diam, ediam_image, ENNReal.toReal_mul]
#align dilation.diam_image Dilation.diam_image
-/

#print Dilation.diam_range /-
theorem diam_range : Metric.diam (range (f : α → β)) = ratio f * Metric.diam (univ : Set α) := by
  rw [← image_univ, diam_image]
#align dilation.diam_range Dilation.diam_range
-/

#print Dilation.mapsTo_ball /-
/-- A dilation maps balls to balls and scales the radius by `ratio f`. -/
theorem mapsTo_ball (x : α) (r' : ℝ) :
    MapsTo (f : α → β) (Metric.ball x r') (Metric.ball (f x) (ratio f * r')) := fun y hy =>
  (dist_eq f y x).trans_lt <| (mul_lt_mul_left <| NNReal.coe_pos.2 <| ratio_pos f).2 hy
#align dilation.maps_to_ball Dilation.mapsTo_ball
-/

#print Dilation.mapsTo_sphere /-
/-- A dilation maps spheres to spheres and scales the radius by `ratio f`. -/
theorem mapsTo_sphere (x : α) (r' : ℝ) :
    MapsTo (f : α → β) (Metric.sphere x r') (Metric.sphere (f x) (ratio f * r')) := fun y hy =>
  Metric.mem_sphere.mp hy ▸ dist_eq f y x
#align dilation.maps_to_sphere Dilation.mapsTo_sphere
-/

#print Dilation.mapsTo_closedBall /-
/-- A dilation maps closed balls to closed balls and scales the radius by `ratio f`. -/
theorem mapsTo_closedBall (x : α) (r' : ℝ) :
    MapsTo (f : α → β) (Metric.closedBall x r') (Metric.closedBall (f x) (ratio f * r')) :=
  fun y hy => (dist_eq f y x).trans_le <| mul_le_mul_of_nonneg_left hy (NNReal.coe_nonneg _)
#align dilation.maps_to_closed_ball Dilation.mapsTo_closedBall
-/

end PseudoMetricDilation

-- section
end Dilation

