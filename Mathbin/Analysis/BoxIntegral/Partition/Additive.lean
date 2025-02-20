/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.box_integral.partition.additive
! leanprover-community/mathlib commit 61db041ab8e4aaf8cb5c7dc10a7d4ff261997536
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.BoxIntegral.Partition.Split
import Mathbin.Analysis.NormedSpace.OperatorNorm

/-!
# Box additive functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We say that a function `f : box ι → M` from boxes in `ℝⁿ` to a commutative additive monoid `M` is
*box additive* on subboxes of `I₀ : with_top (box ι)` if for any box `J`, `↑J ≤ I₀`, and a partition
`π` of `J`, `f J = ∑ J' in π.boxes, f J'`. We use `I₀ : with_top (box ι)` instead of `I₀ : box ι` to
use the same definition for functions box additive on subboxes of a box and for functions box
additive on all boxes.

Examples of box-additive functions include the measure of a box and the integral of a fixed
integrable function over a box.

In this file we define box-additive functions and prove that a function such that
`f J = f (J ∩ {x | x i < y}) + f (J ∩ {x | y ≤ x i})` is box-additive.

### Tags

rectangular box, additive function
-/


noncomputable section

open scoped Classical BigOperators

open Function Set

namespace BoxIntegral

variable {ι M : Type _} {n : ℕ}

#print BoxIntegral.BoxAdditiveMap /-
/-- A function on `box ι` is called box additive if for every box `J` and a partition `π` of `J`
we have `f J = ∑ Ji in π.boxes, f Ji`. A function is called box additive on subboxes of `I : box ι`
if the same property holds for `J ≤ I`. We formalize these two notions in the same definition
using `I : with_bot (box ι)`: the value `I = ⊤` corresponds to functions box additive on the whole
space.  -/
structure BoxAdditiveMap (ι M : Type _) [AddCommMonoid M] (I : WithTop (Box ι)) where
  toFun : Box ι → M
  sum_partition_boxes' :
    ∀ J : Box ι,
      ↑J ≤ I → ∀ π : Prepartition J, π.IsPartition → ∑ Ji in π.boxes, to_fun Ji = to_fun J
#align box_integral.box_additive_map BoxIntegral.BoxAdditiveMap
-/

scoped notation:25 ι " →ᵇᵃ " M => BoxIntegral.BoxAdditiveMap ι M ⊤

scoped notation:25 ι " →ᵇᵃ[" I "] " M => BoxIntegral.BoxAdditiveMap ι M I

namespace BoxAdditiveMap

open Box Prepartition Finset

variable {N : Type _} [AddCommMonoid M] [AddCommMonoid N] {I₀ : WithTop (Box ι)} {I J : Box ι}
  {i : ι}

instance : CoeFun (ι →ᵇᵃ[I₀] M) fun _ => Box ι → M :=
  ⟨toFun⟩

initialize_simps_projections box_integral.box_additive_map (toFun → apply)

@[simp]
theorem toFun_eq_coe (f : ι →ᵇᵃ[I₀] M) : f.toFun = f :=
  rfl
#align box_integral.box_additive_map.to_fun_eq_coe BoxIntegral.BoxAdditiveMap.toFun_eq_coe

#print BoxIntegral.BoxAdditiveMap.coe_mk /-
@[simp]
theorem coe_mk (f h) : ⇑(mk f h : ι →ᵇᵃ[I₀] M) = f :=
  rfl
#align box_integral.box_additive_map.coe_mk BoxIntegral.BoxAdditiveMap.coe_mk
-/

#print BoxIntegral.BoxAdditiveMap.coe_injective /-
theorem coe_injective : Injective fun (f : ι →ᵇᵃ[I₀] M) x => f x := by
  rintro ⟨f, hf⟩ ⟨g, hg⟩ (rfl : f = g); rfl
#align box_integral.box_additive_map.coe_injective BoxIntegral.BoxAdditiveMap.coe_injective
-/

#print BoxIntegral.BoxAdditiveMap.coe_inj /-
@[simp]
theorem coe_inj {f g : ι →ᵇᵃ[I₀] M} : (f : Box ι → M) = g ↔ f = g :=
  coe_injective.eq_iff
#align box_integral.box_additive_map.coe_inj BoxIntegral.BoxAdditiveMap.coe_inj
-/

#print BoxIntegral.BoxAdditiveMap.sum_partition_boxes /-
theorem sum_partition_boxes (f : ι →ᵇᵃ[I₀] M) (hI : ↑I ≤ I₀) {π : Prepartition I}
    (h : π.IsPartition) : ∑ J in π.boxes, f J = f I :=
  f.sum_partition_boxes' I hI π h
#align box_integral.box_additive_map.sum_partition_boxes BoxIntegral.BoxAdditiveMap.sum_partition_boxes
-/

@[simps (config := { fullyApplied := false })]
instance : Zero (ι →ᵇᵃ[I₀] M) :=
  ⟨⟨0, fun I hI π hπ => sum_const_zero⟩⟩

instance : Inhabited (ι →ᵇᵃ[I₀] M) :=
  ⟨0⟩

instance : Add (ι →ᵇᵃ[I₀] M) :=
  ⟨fun f g =>
    ⟨f + g, fun I hI π hπ => by
      simp only [Pi.add_apply, sum_add_distrib, sum_partition_boxes _ hI hπ]⟩⟩

instance {R} [Monoid R] [DistribMulAction R M] : SMul R (ι →ᵇᵃ[I₀] M) :=
  ⟨fun r f =>
    ⟨r • f, fun I hI π hπ => by simp only [Pi.smul_apply, ← smul_sum, sum_partition_boxes _ hI hπ]⟩⟩

instance : AddCommMonoid (ι →ᵇᵃ[I₀] M) :=
  Function.Injective.addCommMonoid _ coe_injective rfl (fun _ _ => rfl) fun _ _ => rfl

#print BoxIntegral.BoxAdditiveMap.map_split_add /-
@[simp]
theorem map_split_add (f : ι →ᵇᵃ[I₀] M) (hI : ↑I ≤ I₀) (i : ι) (x : ℝ) :
    (I.splitLower i x).elim 0 f + (I.splitUpper i x).elim 0 f = f I := by
  rw [← f.sum_partition_boxes hI (is_partition_split I i x), sum_split_boxes]
#align box_integral.box_additive_map.map_split_add BoxIntegral.BoxAdditiveMap.map_split_add
-/

#print BoxIntegral.BoxAdditiveMap.restrict /-
/-- If `f` is box-additive on subboxes of `I₀`, then it is box-additive on subboxes of any
`I ≤ I₀`. -/
@[simps]
def restrict (f : ι →ᵇᵃ[I₀] M) (I : WithTop (Box ι)) (hI : I ≤ I₀) : ι →ᵇᵃ[I] M :=
  ⟨f, fun J hJ => f.2 J (hJ.trans hI)⟩
#align box_integral.box_additive_map.restrict BoxIntegral.BoxAdditiveMap.restrict
-/

#print BoxIntegral.BoxAdditiveMap.ofMapSplitAdd /-
/-- If `f : box ι → M` is box additive on partitions of the form `split I i x`, then it is box
additive. -/
def ofMapSplitAdd [Fintype ι] (f : Box ι → M) (I₀ : WithTop (Box ι))
    (hf :
      ∀ I : Box ι,
        ↑I ≤ I₀ →
          ∀ {i x},
            x ∈ Ioo (I.lower i) (I.upper i) →
              (I.splitLower i x).elim 0 f + (I.splitUpper i x).elim 0 f = f I) :
    ι →ᵇᵃ[I₀] M := by
  refine' ⟨f, _⟩
  replace hf : ∀ I : box ι, ↑I ≤ I₀ → ∀ s, ∑ J in (split_many I s).boxes, f J = f I
  · intro I hI s
    induction' s using Finset.induction_on with a s ha ihs; · simp
    rw [split_many_insert, inf_split, ← ihs, bUnion_boxes, sum_bUnion_boxes]
    refine' Finset.sum_congr rfl fun J' hJ' => _
    by_cases h : a.2 ∈ Ioo (J'.lower a.1) (J'.upper a.1)
    · rw [sum_split_boxes]
      exact hf _ ((WithTop.coe_le_coe.2 <| le_of_mem _ hJ').trans hI) h
    · rw [split_of_not_mem_Ioo h, top_boxes, Finset.sum_singleton]
  intro I hI π hπ
  have Hle : ∀ J ∈ π, ↑J ≤ I₀ := fun J hJ => (WithTop.coe_le_coe.2 <| π.le_of_mem hJ).trans hI
  rcases hπ.exists_split_many_le with ⟨s, hs⟩
  rw [← hf _ hI, ← inf_of_le_right hs, inf_split_many, bUnion_boxes, sum_bUnion_boxes]
  exact Finset.sum_congr rfl fun J hJ => (hf _ (Hle _ hJ) _).symm
#align box_integral.box_additive_map.of_map_split_add BoxIntegral.BoxAdditiveMap.ofMapSplitAdd
-/

#print BoxIntegral.BoxAdditiveMap.map /-
/-- If `g : M → N` is an additive map and `f` is a box additive map, then `g ∘ f` is a box additive
map. -/
@[simps (config := { fullyApplied := false })]
def map (f : ι →ᵇᵃ[I₀] M) (g : M →+ N) : ι →ᵇᵃ[I₀] N
    where
  toFun := g ∘ f
  sum_partition_boxes' I hI π hπ := by rw [← g.map_sum, f.sum_partition_boxes hI hπ]
#align box_integral.box_additive_map.map BoxIntegral.BoxAdditiveMap.map
-/

#print BoxIntegral.BoxAdditiveMap.sum_boxes_congr /-
/-- If `f` is a box additive function on subboxes of `I` and `π₁`, `π₂` are two prepartitions of
`I` that cover the same part of `I`, then `∑ J in π₁.boxes, f J = ∑ J in π₂.boxes, f J`. -/
theorem sum_boxes_congr [Finite ι] (f : ι →ᵇᵃ[I₀] M) (hI : ↑I ≤ I₀) {π₁ π₂ : Prepartition I}
    (h : π₁.iUnion = π₂.iUnion) : ∑ J in π₁.boxes, f J = ∑ J in π₂.boxes, f J :=
  by
  rcases exists_split_many_inf_eq_filter_of_finite {π₁, π₂} ((finite_singleton _).insert _) with
    ⟨s, hs⟩
  simp only [inf_split_many] at hs 
  rcases hs _ (Or.inl rfl), hs _ (Or.inr rfl) with ⟨h₁, h₂⟩; clear hs
  rw [h] at h₁ 
  calc
    ∑ J in π₁.boxes, f J = ∑ J in π₁.boxes, ∑ J' in (split_many J s).boxes, f J' :=
      Finset.sum_congr rfl fun J hJ => (f.sum_partition_boxes _ (is_partition_split_many _ _)).symm
    _ = ∑ J in (π₁.bUnion fun J => split_many J s).boxes, f J := (sum_bUnion_boxes _ _ _).symm
    _ = ∑ J in (π₂.bUnion fun J => split_many J s).boxes, f J := by rw [h₁, h₂]
    _ = ∑ J in π₂.boxes, ∑ J' in (split_many J s).boxes, f J' := (sum_bUnion_boxes _ _ _)
    _ = ∑ J in π₂.boxes, f J :=
      Finset.sum_congr rfl fun J hJ => f.sum_partition_boxes _ (is_partition_split_many _ _)
  exacts [(WithTop.coe_le_coe.2 <| π₁.le_of_mem hJ).trans hI,
    (WithTop.coe_le_coe.2 <| π₂.le_of_mem hJ).trans hI]
#align box_integral.box_additive_map.sum_boxes_congr BoxIntegral.BoxAdditiveMap.sum_boxes_congr
-/

section ToSmul

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]

#print BoxIntegral.BoxAdditiveMap.toSMul /-
/-- If `f` is a box-additive map, then so is the map sending `I` to the scalar multiplication
by `f I` as a continuous linear map from `E` to itself. -/
def toSMul (f : ι →ᵇᵃ[I₀] ℝ) : ι →ᵇᵃ[I₀] E →L[ℝ] E :=
  f.map (ContinuousLinearMap.lsmul ℝ ℝ).toLinearMap.toAddMonoidHom
#align box_integral.box_additive_map.to_smul BoxIntegral.BoxAdditiveMap.toSMul
-/

#print BoxIntegral.BoxAdditiveMap.toSMul_apply /-
@[simp]
theorem toSMul_apply (f : ι →ᵇᵃ[I₀] ℝ) (I : Box ι) (x : E) : f.toSMul I x = f I • x :=
  rfl
#align box_integral.box_additive_map.to_smul_apply BoxIntegral.BoxAdditiveMap.toSMul_apply
-/

end ToSmul

#print BoxIntegral.BoxAdditiveMap.upperSubLower /-
/-- Given a box `I₀` in `ℝⁿ⁺¹`, `f x : box (fin n) → G` is a family of functions indexed by a real
`x` and for `x ∈ [I₀.lower i, I₀.upper i]`, `f x` is box-additive on subboxes of the `i`-th face of
`I₀`, then `λ J, f (J.upper i) (J.face i) - f (J.lower i) (J.face i)` is box-additive on subboxes of
`I₀`. -/
@[simps]
def upperSubLower.{u} {G : Type u} [AddCommGroup G] (I₀ : Box (Fin (n + 1))) (i : Fin (n + 1))
    (f : ℝ → Box (Fin n) → G) (fb : Icc (I₀.lower i) (I₀.upper i) → Fin n →ᵇᵃ[I₀.face i] G)
    (hf : ∀ (x) (hx : x ∈ Icc (I₀.lower i) (I₀.upper i)) (J), f x J = fb ⟨x, hx⟩ J) :
    Fin (n + 1) →ᵇᵃ[I₀] G :=
  ofMapSplitAdd (fun J : Box (Fin (n + 1)) => f (J.upper i) (J.face i) - f (J.lower i) (J.face i))
    I₀
    (by
      intro J hJ j
      rw [WithTop.coe_le_coe] at hJ 
      refine' i.succ_above_cases _ _ j
      · intro x hx
        simp only [box.split_lower_def hx, box.split_upper_def hx, update_same, ←
          WithBot.some_eq_coe, Option.elim', box.face, (· ∘ ·), update_noteq (Fin.succAbove_ne _ _)]
        abel
      · clear j; intro j x hx
        have : (J.face i : WithTop (box (Fin n))) ≤ I₀.face i :=
          WithTop.coe_le_coe.2 (face_mono hJ i)
        rw [le_iff_Icc, @box.Icc_eq_pi _ I₀] at hJ 
        rw [hf _ (hJ J.upper_mem_Icc _ trivial), hf _ (hJ J.lower_mem_Icc _ trivial), ←
          (fb _).map_split_add this j x, ← (fb _).map_split_add this j x]
        have hx' : x ∈ Ioo ((J.face i).lower j) ((J.face i).upper j) := hx
        simp only [box.split_lower_def hx, box.split_upper_def hx, box.split_lower_def hx',
          box.split_upper_def hx', ← WithBot.some_eq_coe, Option.elim', box.face_mk,
          update_noteq (Fin.succAbove_ne _ _).symm, sub_add_sub_comm,
          update_comp_eq_of_injective _ i.succ_above.injective j x, ← hf]
        simp only [box.face])
#align box_integral.box_additive_map.upper_sub_lower BoxIntegral.BoxAdditiveMap.upperSubLower
-/

end BoxAdditiveMap

end BoxIntegral

