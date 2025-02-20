/-
Copyright (c) 2019 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module topology.metric_space.gromov_hausdorff
! leanprover-community/mathlib commit 0c1f285a9f6e608ae2bdffa3f993eafb01eba829
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.SetTheory.Cardinal.Basic
import Mathbin.Topology.MetricSpace.Closeds
import Mathbin.Topology.MetricSpace.Completion
import Mathbin.Topology.MetricSpace.GromovHausdorffRealized
import Mathbin.Topology.MetricSpace.Kuratowski

/-!
# Gromov-Hausdorff distance

This file defines the Gromov-Hausdorff distance on the space of nonempty compact metric spaces
up to isometry.

We introduce the space of all nonempty compact metric spaces, up to isometry,
called `GH_space`, and endow it with a metric space structure. The distance,
known as the Gromov-Hausdorff distance, is defined as follows: given two
nonempty compact spaces `X` and `Y`, their distance is the minimum Hausdorff distance
between all possible isometric embeddings of `X` and `Y` in all metric spaces.
To define properly the Gromov-Hausdorff space, we consider the non-empty
compact subsets of `ℓ^∞(ℝ)` up to isometry, which is a well-defined type,
and define the distance as the infimum of the Hausdorff distance over all
embeddings in `ℓ^∞(ℝ)`. We prove that this coincides with the previous description,
as all separable metric spaces embed isometrically into `ℓ^∞(ℝ)`, through an
embedding called the Kuratowski embedding.
To prove that we have a distance, we should show that if spaces can be coupled
to be arbitrarily close, then they are isometric. More generally, the Gromov-Hausdorff
distance is realized, i.e., there is a coupling for which the Hausdorff distance
is exactly the Gromov-Hausdorff distance. This follows from a compactness
argument, essentially following from Arzela-Ascoli.

## Main results

We prove the most important properties of the Gromov-Hausdorff space: it is a polish space,
i.e., it is complete and second countable. We also prove the Gromov compactness criterion.

-/


noncomputable section

open scoped Classical Topology ENNReal

local notation "ℓ_infty_ℝ" => lp (fun n : ℕ => ℝ) ∞

universe u v w

open Classical Set Function TopologicalSpace Filter Metric Quotient

open BoundedContinuousFunction Nat Int kuratowskiEmbedding

open Sum (inl inr)

attribute [local instance] metric_space_sum

namespace GromovHausdorff

section GHSpace

/- In this section, we define the Gromov-Hausdorff space, denoted `GH_space` as the quotient
of nonempty compact subsets of `ℓ^∞(ℝ)` by identifying isometric sets.
Using the Kuratwoski embedding, we get a canonical map `to_GH_space` mapping any nonempty
compact type to `GH_space`. -/
/-- Equivalence relation identifying two nonempty compact sets which are isometric -/
private def isometry_rel : NonemptyCompacts ℓ_infty_ℝ → NonemptyCompacts ℓ_infty_ℝ → Prop :=
  fun x y => Nonempty (x ≃ᵢ y)

/-- This is indeed an equivalence relation -/
private theorem is_equivalence_isometry_rel : Equivalence IsometryRel :=
  ⟨fun x => ⟨IsometryEquiv.refl _⟩, fun x y ⟨e⟩ => ⟨e.symm⟩, fun x y z ⟨e⟩ ⟨f⟩ => ⟨e.trans f⟩⟩

/-- setoid instance identifying two isometric nonempty compact subspaces of ℓ^∞(ℝ) -/
instance IsometryRel.setoid : Setoid (NonemptyCompacts ℓ_infty_ℝ) :=
  Setoid.mk IsometryRel is_equivalence_isometryRel
#align Gromov_Hausdorff.isometry_rel.setoid GromovHausdorff.IsometryRel.setoid

/-- The Gromov-Hausdorff space -/
def GHSpace : Type :=
  Quotient IsometryRel.setoid
#align Gromov_Hausdorff.GH_space GromovHausdorff.GHSpace

/-- Map any nonempty compact type to `GH_space` -/
def toGHSpace (X : Type u) [MetricSpace X] [CompactSpace X] [Nonempty X] : GHSpace :=
  ⟦NonemptyCompacts.kuratowskiEmbedding X⟧
#align Gromov_Hausdorff.to_GH_space GromovHausdorff.toGHSpace

instance : Inhabited GHSpace :=
  ⟨Quot.mk _ ⟨⟨{0}, isCompact_singleton⟩, singleton_nonempty _⟩⟩

/-- A metric space representative of any abstract point in `GH_space` -/
@[nolint has_nonempty_instance]
def GHSpace.Rep (p : GHSpace) : Type :=
  (Quotient.out p : NonemptyCompacts ℓ_infty_ℝ)
#align Gromov_Hausdorff.GH_space.rep GromovHausdorff.GHSpace.Rep

theorem eq_toGHSpace_iff {X : Type u} [MetricSpace X] [CompactSpace X] [Nonempty X]
    {p : NonemptyCompacts ℓ_infty_ℝ} :
    ⟦p⟧ = toGHSpace X ↔ ∃ Ψ : X → ℓ_infty_ℝ, Isometry Ψ ∧ range Ψ = p :=
  by
  simp only [to_GH_space, Quotient.eq']
  refine' ⟨fun h => _, _⟩
  · rcases Setoid.symm h with ⟨e⟩
    have f := (kuratowskiEmbedding.isometry X).isometryEquivOnRange.trans e
    use fun x => f x, isometry_subtype_coe.comp f.isometry
    rw [range_comp, f.range_eq_univ, Set.image_univ, Subtype.range_coe]
    rfl
  · rintro ⟨Ψ, ⟨isomΨ, rangeΨ⟩⟩
    have f :=
      ((kuratowskiEmbedding.isometry X).isometryEquivOnRange.symm.trans
          isomΨ.isometry_equiv_on_range).symm
    have E :
      (range Ψ ≃ᵢ NonemptyCompacts.kuratowskiEmbedding X) = (p ≃ᵢ range (kuratowskiEmbedding X)) :=
      by dsimp only [NonemptyCompacts.kuratowskiEmbedding]; rw [rangeΨ] <;> rfl
    exact ⟨cast E f⟩
#align Gromov_Hausdorff.eq_to_GH_space_iff GromovHausdorff.eq_toGHSpace_iff

theorem eq_toGHSpace {p : NonemptyCompacts ℓ_infty_ℝ} : ⟦p⟧ = toGHSpace p :=
  eq_toGHSpace_iff.2 ⟨fun x => x, isometry_subtype_coe, Subtype.range_coe⟩
#align Gromov_Hausdorff.eq_to_GH_space GromovHausdorff.eq_toGHSpace

section

attribute [local reducible] GH_space.rep

instance repGHSpaceMetricSpace {p : GHSpace} : MetricSpace p.rep := by infer_instance
#align Gromov_Hausdorff.rep_GH_space_metric_space GromovHausdorff.repGHSpaceMetricSpace

instance rep_gHSpace_compactSpace {p : GHSpace} : CompactSpace p.rep := by infer_instance
#align Gromov_Hausdorff.rep_GH_space_compact_space GromovHausdorff.rep_gHSpace_compactSpace

instance rep_gHSpace_nonempty {p : GHSpace} : Nonempty p.rep := by infer_instance
#align Gromov_Hausdorff.rep_GH_space_nonempty GromovHausdorff.rep_gHSpace_nonempty

end

theorem GHSpace.toGHSpace_rep (p : GHSpace) : toGHSpace p.rep = p :=
  by
  change to_GH_space (Quot.out p : nonempty_compacts ℓ_infty_ℝ) = p
  rw [← eq_to_GH_space]
  exact Quot.out_eq p
#align Gromov_Hausdorff.GH_space.to_GH_space_rep GromovHausdorff.GHSpace.toGHSpace_rep

/-- Two nonempty compact spaces have the same image in `GH_space` if and only if they are
isometric. -/
theorem toGHSpace_eq_toGHSpace_iff_isometryEquiv {X : Type u} [MetricSpace X] [CompactSpace X]
    [Nonempty X] {Y : Type v} [MetricSpace Y] [CompactSpace Y] [Nonempty Y] :
    toGHSpace X = toGHSpace Y ↔ Nonempty (X ≃ᵢ Y) :=
  ⟨by
    simp only [to_GH_space, Quotient.eq']
    rintro ⟨e⟩
    have I :
      (NonemptyCompacts.kuratowskiEmbedding X ≃ᵢ NonemptyCompacts.kuratowskiEmbedding Y) =
        (range (kuratowskiEmbedding X) ≃ᵢ range (kuratowskiEmbedding Y)) :=
      by dsimp only [NonemptyCompacts.kuratowskiEmbedding]; rfl
    have f := (kuratowskiEmbedding.isometry X).isometryEquivOnRange
    have g := (kuratowskiEmbedding.isometry Y).isometryEquivOnRange.symm
    exact ⟨f.trans <| (cast I e).trans g⟩, by
    rintro ⟨e⟩
    simp only [to_GH_space, Quotient.eq']
    have f := (kuratowskiEmbedding.isometry X).isometryEquivOnRange.symm
    have g := (kuratowskiEmbedding.isometry Y).isometryEquivOnRange
    have I :
      (range (kuratowskiEmbedding X) ≃ᵢ range (kuratowskiEmbedding Y)) =
        (NonemptyCompacts.kuratowskiEmbedding X ≃ᵢ NonemptyCompacts.kuratowskiEmbedding Y) :=
      by dsimp only [NonemptyCompacts.kuratowskiEmbedding]; rfl
    exact ⟨cast I ((f.trans e).trans g)⟩⟩
#align Gromov_Hausdorff.to_GH_space_eq_to_GH_space_iff_isometry_equiv GromovHausdorff.toGHSpace_eq_toGHSpace_iff_isometryEquiv

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- Distance on `GH_space`: the distance between two nonempty compact spaces is the infimum
Hausdorff distance between isometric copies of the two spaces in a metric space. For the definition,
we only consider embeddings in `ℓ^∞(ℝ)`, but we will prove below that it works for all spaces. -/
instance : Dist GHSpace
    where dist x y :=
    sInf <|
      (fun p : NonemptyCompacts ℓ_infty_ℝ × NonemptyCompacts ℓ_infty_ℝ =>
          hausdorffDist (p.1 : Set ℓ_infty_ℝ) p.2) ''
        {a | ⟦a⟧ = x} ×ˢ {b | ⟦b⟧ = y}

/-- The Gromov-Hausdorff distance between two nonempty compact metric spaces, equal by definition to
the distance of the equivalence classes of these spaces in the Gromov-Hausdorff space. -/
def gHDist (X : Type u) (Y : Type v) [MetricSpace X] [Nonempty X] [CompactSpace X] [MetricSpace Y]
    [Nonempty Y] [CompactSpace Y] : ℝ :=
  dist (toGHSpace X) (toGHSpace Y)
#align Gromov_Hausdorff.GH_dist GromovHausdorff.gHDist

theorem dist_gHDist (p q : GHSpace) : dist p q = gHDist p.rep q.rep := by
  rw [GH_dist, p.to_GH_space_rep, q.to_GH_space_rep]
#align Gromov_Hausdorff.dist_GH_dist GromovHausdorff.dist_gHDist

/-- The Gromov-Hausdorff distance between two spaces is bounded by the Hausdorff distance
of isometric copies of the spaces, in any metric space. -/
theorem gHDist_le_hausdorffDist {X : Type u} [MetricSpace X] [CompactSpace X] [Nonempty X]
    {Y : Type v} [MetricSpace Y] [CompactSpace Y] [Nonempty Y] {γ : Type w} [MetricSpace γ]
    {Φ : X → γ} {Ψ : Y → γ} (ha : Isometry Φ) (hb : Isometry Ψ) :
    gHDist X Y ≤ hausdorffDist (range Φ) (range Ψ) :=
  by
  /- For the proof, we want to embed `γ` in `ℓ^∞(ℝ)`, to say that the Hausdorff distance is realized
    in `ℓ^∞(ℝ)` and therefore bounded below by the Gromov-Hausdorff-distance. However, `γ` is not
    separable in general. We restrict to the union of the images of `X` and `Y` in `γ`, which is
    separable and therefore embeddable in `ℓ^∞(ℝ)`. -/
  rcases exists_mem_of_nonempty X with ⟨xX, _⟩
  let s : Set γ := range Φ ∪ range Ψ
  let Φ' : X → Subtype s := fun y => ⟨Φ y, mem_union_left _ (mem_range_self _)⟩
  let Ψ' : Y → Subtype s := fun y => ⟨Ψ y, mem_union_right _ (mem_range_self _)⟩
  have IΦ' : Isometry Φ' := fun x y => ha x y
  have IΨ' : Isometry Ψ' := fun x y => hb x y
  have : IsCompact s := (isCompact_range ha.continuous).union (isCompact_range hb.continuous)
  letI : MetricSpace (Subtype s) := by infer_instance
  haveI : CompactSpace (Subtype s) := ⟨isCompact_iff_isCompact_univ.1 ‹IsCompact s›⟩
  haveI : Nonempty (Subtype s) := ⟨Φ' xX⟩
  have ΦΦ' : Φ = Subtype.val ∘ Φ' := by funext; rfl
  have ΨΨ' : Ψ = Subtype.val ∘ Ψ' := by funext; rfl
  have : Hausdorff_dist (range Φ) (range Ψ) = Hausdorff_dist (range Φ') (range Ψ') :=
    by
    rw [ΦΦ', ΨΨ', range_comp, range_comp]
    exact Hausdorff_dist_image isometry_subtype_coe
  rw [this]
  -- Embed `s` in `ℓ^∞(ℝ)` through its Kuratowski embedding
  let F := kuratowskiEmbedding (Subtype s)
  have : Hausdorff_dist (F '' range Φ') (F '' range Ψ') = Hausdorff_dist (range Φ') (range Ψ') :=
    Hausdorff_dist_image (kuratowskiEmbedding.isometry _)
  rw [← this]
  -- Let `A` and `B` be the images of `X` and `Y` under this embedding. They are in `ℓ^∞(ℝ)`, and
  -- their Hausdorff distance is the same as in the original space.
  let A : nonempty_compacts ℓ_infty_ℝ :=
    ⟨⟨F '' range Φ',
        (isCompact_range IΦ'.continuous).image (kuratowskiEmbedding.isometry _).Continuous⟩,
      (range_nonempty _).image _⟩
  let B : nonempty_compacts ℓ_infty_ℝ :=
    ⟨⟨F '' range Ψ',
        (isCompact_range IΨ'.continuous).image (kuratowskiEmbedding.isometry _).Continuous⟩,
      (range_nonempty _).image _⟩
  have AX : ⟦A⟧ = to_GH_space X := by
    rw [eq_to_GH_space_iff]
    exact ⟨fun x => F (Φ' x), (kuratowskiEmbedding.isometry _).comp IΦ', range_comp _ _⟩
  have BY : ⟦B⟧ = to_GH_space Y := by
    rw [eq_to_GH_space_iff]
    exact ⟨fun x => F (Ψ' x), (kuratowskiEmbedding.isometry _).comp IΨ', range_comp _ _⟩
  refine' csInf_le ⟨0, _⟩ _
  · simp only [lowerBounds, mem_image, mem_prod, mem_set_of_eq, Prod.exists, and_imp,
      forall_exists_index]
    intro t _ _ _ _ ht
    rw [← ht]
    exact Hausdorff_dist_nonneg
  apply (mem_image _ _ _).2
  exists (⟨A, B⟩ : nonempty_compacts ℓ_infty_ℝ × nonempty_compacts ℓ_infty_ℝ)
  simp [AX, BY]
#align Gromov_Hausdorff.GH_dist_le_Hausdorff_dist GromovHausdorff.gHDist_le_hausdorffDist

/-- The optimal coupling constructed above realizes exactly the Gromov-Hausdorff distance,
essentially by design. -/
theorem hausdorffDist_optimal {X : Type u} [MetricSpace X] [CompactSpace X] [Nonempty X]
    {Y : Type v} [MetricSpace Y] [CompactSpace Y] [Nonempty Y] :
    hausdorffDist (range (optimalGHInjl X Y)) (range (optimalGHInjr X Y)) = gHDist X Y :=
  by
  inhabit X; inhabit Y
  /- we only need to check the inequality `≤`, as the other one follows from the previous lemma.
       As the Gromov-Hausdorff distance is an infimum, we need to check that the Hausdorff distance
       in the optimal coupling is smaller than the Hausdorff distance of any coupling.
       First, we check this for couplings which already have small Hausdorff distance: in this
       case, the induced "distance" on `X ⊕ Y` belongs to the candidates family introduced in the
       definition of the optimal coupling, and the conclusion follows from the optimality
       of the optimal coupling within this family.
    -/
  have A :
    ∀ p q : nonempty_compacts ℓ_infty_ℝ,
      ⟦p⟧ = to_GH_space X →
        ⟦q⟧ = to_GH_space Y →
          Hausdorff_dist (p : Set ℓ_infty_ℝ) q < diam (univ : Set X) + 1 + diam (univ : Set Y) →
            Hausdorff_dist (range (optimal_GH_injl X Y)) (range (optimal_GH_injr X Y)) ≤
              Hausdorff_dist (p : Set ℓ_infty_ℝ) q :=
    by
    intro p q hp hq bound
    rcases eq_to_GH_space_iff.1 hp with ⟨Φ, ⟨Φisom, Φrange⟩⟩
    rcases eq_to_GH_space_iff.1 hq with ⟨Ψ, ⟨Ψisom, Ψrange⟩⟩
    have I : diam (range Φ ∪ range Ψ) ≤ 2 * diam (univ : Set X) + 1 + 2 * diam (univ : Set Y) :=
      by
      rcases exists_mem_of_nonempty X with ⟨xX, _⟩
      have : ∃ y ∈ range Ψ, dist (Φ xX) y < diam (univ : Set X) + 1 + diam (univ : Set Y) :=
        by
        rw [Ψrange]
        have : Φ xX ∈ ↑p := Φrange.subst (mem_range_self _)
        exact
          exists_dist_lt_of_Hausdorff_dist_lt this bound
            (Hausdorff_edist_ne_top_of_nonempty_of_bounded p.nonempty q.nonempty
              p.is_compact.bounded q.is_compact.bounded)
      rcases this with ⟨y, hy, dy⟩
      rcases mem_range.1 hy with ⟨z, hzy⟩
      rw [← hzy] at dy 
      have DΦ : diam (range Φ) = diam (univ : Set X) := Φisom.diam_range
      have DΨ : diam (range Ψ) = diam (univ : Set Y) := Ψisom.diam_range
      calc
        diam (range Φ ∪ range Ψ) ≤ diam (range Φ) + dist (Φ xX) (Ψ z) + diam (range Ψ) :=
          diam_union (mem_range_self _) (mem_range_self _)
        _ ≤
            diam (univ : Set X) + (diam (univ : Set X) + 1 + diam (univ : Set Y)) +
              diam (univ : Set Y) :=
          by rw [DΦ, DΨ]; apply add_le_add (add_le_add le_rfl (le_of_lt dy)) le_rfl
        _ = 2 * diam (univ : Set X) + 1 + 2 * diam (univ : Set Y) := by ring
    let f : Sum X Y → ℓ_infty_ℝ := fun x =>
      match x with
      | inl y => Φ y
      | inr z => Ψ z
    let F : Sum X Y × Sum X Y → ℝ := fun p => dist (f p.1) (f p.2)
    -- check that the induced "distance" is a candidate
    have Fgood : F ∈ candidates X Y :=
      by
      simp only [candidates, forall_const, and_true_iff, add_comm, eq_self_iff_true, dist_eq_zero,
        and_self_iff, Set.mem_setOf_eq]
      repeat' constructor
      ·
        exact fun x y =>
          calc
            F (inl x, inl y) = dist (Φ x) (Φ y) := rfl
            _ = dist x y := Φisom.dist_eq x y
      ·
        exact fun x y =>
          calc
            F (inr x, inr y) = dist (Ψ x) (Ψ y) := rfl
            _ = dist x y := Ψisom.dist_eq x y
      · exact fun x y => dist_comm _ _
      · exact fun x y z => dist_triangle _ _ _
      ·
        exact fun x y =>
          calc
            F (x, y) ≤ diam (range Φ ∪ range Ψ) :=
              by
              have A : ∀ z : Sum X Y, f z ∈ range Φ ∪ range Ψ :=
                by
                intro z
                cases z
                · apply mem_union_left; apply mem_range_self
                · apply mem_union_right; apply mem_range_self
              refine' dist_le_diam_of_mem _ (A _) (A _)
              rw [Φrange, Ψrange]
              exact (p ⊔ q).IsCompact.Bounded
            _ ≤ 2 * diam (univ : Set X) + 1 + 2 * diam (univ : Set Y) := I
    let Fb := candidates_b_of_candidates F Fgood
    have : Hausdorff_dist (range (optimal_GH_injl X Y)) (range (optimal_GH_injr X Y)) ≤ HD Fb :=
      Hausdorff_dist_optimal_le_HD _ _ (candidates_b_of_candidates_mem F Fgood)
    refine' le_trans this (le_of_forall_le_of_dense fun r hr => _)
    have I1 : ∀ x : X, (⨅ y, Fb (inl x, inr y)) ≤ r :=
      by
      intro x
      have : f (inl x) ∈ ↑p := Φrange.subst (mem_range_self _)
      rcases exists_dist_lt_of_Hausdorff_dist_lt this hr
          (Hausdorff_edist_ne_top_of_nonempty_of_bounded p.nonempty q.nonempty p.is_compact.bounded
            q.is_compact.bounded) with
        ⟨z, zq, hz⟩
      have : z ∈ range Ψ := by rwa [← Ψrange] at zq 
      rcases mem_range.1 this with ⟨y, hy⟩
      calc
        (⨅ y, Fb (inl x, inr y)) ≤ Fb (inl x, inr y) :=
          ciInf_le (by simpa only [add_zero] using HD_below_aux1 0) y
        _ = dist (Φ x) (Ψ y) := rfl
        _ = dist (f (inl x)) z := by rw [hy]
        _ ≤ r := le_of_lt hz
    have I2 : ∀ y : Y, (⨅ x, Fb (inl x, inr y)) ≤ r :=
      by
      intro y
      have : f (inr y) ∈ ↑q := Ψrange.subst (mem_range_self _)
      rcases exists_dist_lt_of_Hausdorff_dist_lt' this hr
          (Hausdorff_edist_ne_top_of_nonempty_of_bounded p.nonempty q.nonempty p.is_compact.bounded
            q.is_compact.bounded) with
        ⟨z, zq, hz⟩
      have : z ∈ range Φ := by rwa [← Φrange] at zq 
      rcases mem_range.1 this with ⟨x, hx⟩
      calc
        (⨅ x, Fb (inl x, inr y)) ≤ Fb (inl x, inr y) :=
          ciInf_le (by simpa only [add_zero] using HD_below_aux2 0) x
        _ = dist (Φ x) (Ψ y) := rfl
        _ = dist z (f (inr y)) := by rw [hx]
        _ ≤ r := le_of_lt hz
    simp only [HD, ciSup_le I1, ciSup_le I2, max_le_iff, and_self_iff]
  /- Get the same inequality for any coupling. If the coupling is quite good, the desired
    inequality has been proved above. If it is bad, then the inequality is obvious. -/
  have B :
    ∀ p q : nonempty_compacts ℓ_infty_ℝ,
      ⟦p⟧ = to_GH_space X →
        ⟦q⟧ = to_GH_space Y →
          Hausdorff_dist (range (optimal_GH_injl X Y)) (range (optimal_GH_injr X Y)) ≤
            Hausdorff_dist (p : Set ℓ_infty_ℝ) q :=
    by
    intro p q hp hq
    by_cases h :
      Hausdorff_dist (p : Set ℓ_infty_ℝ) q < diam (univ : Set X) + 1 + diam (univ : Set Y)
    · exact A p q hp hq h
    ·
      calc
        Hausdorff_dist (range (optimal_GH_injl X Y)) (range (optimal_GH_injr X Y)) ≤
            HD (candidates_b_dist X Y) :=
          Hausdorff_dist_optimal_le_HD _ _ candidates_b_dist_mem_candidates_b
        _ ≤ diam (univ : Set X) + 1 + diam (univ : Set Y) := HD_candidates_b_dist_le
        _ ≤ Hausdorff_dist (p : Set ℓ_infty_ℝ) q := not_lt.1 h
  refine' le_antisymm _ _
  · apply le_csInf
    · refine' (Set.Nonempty.prod _ _).image _ <;> exact ⟨_, rfl⟩
    · rintro b ⟨⟨p, q⟩, ⟨hp, hq⟩, rfl⟩
      exact B p q hp hq
  · exact GH_dist_le_Hausdorff_dist (isometry_optimal_GH_injl X Y) (isometry_optimal_GH_injr X Y)
#align Gromov_Hausdorff.Hausdorff_dist_optimal GromovHausdorff.hausdorffDist_optimal

/-- The Gromov-Hausdorff distance can also be realized by a coupling in `ℓ^∞(ℝ)`, by embedding
the optimal coupling through its Kuratowski embedding. -/
theorem gHDist_eq_hausdorffDist (X : Type u) [MetricSpace X] [CompactSpace X] [Nonempty X]
    (Y : Type v) [MetricSpace Y] [CompactSpace Y] [Nonempty Y] :
    ∃ Φ : X → ℓ_infty_ℝ,
      ∃ Ψ : Y → ℓ_infty_ℝ,
        Isometry Φ ∧ Isometry Ψ ∧ gHDist X Y = hausdorffDist (range Φ) (range Ψ) :=
  by
  let F := kuratowskiEmbedding (optimal_GH_coupling X Y)
  let Φ := F ∘ optimal_GH_injl X Y
  let Ψ := F ∘ optimal_GH_injr X Y
  refine' ⟨Φ, Ψ, _, _, _⟩
  · exact (kuratowskiEmbedding.isometry _).comp (isometry_optimal_GH_injl X Y)
  · exact (kuratowskiEmbedding.isometry _).comp (isometry_optimal_GH_injr X Y)
  · rw [← image_univ, ← image_univ, image_comp F, image_univ, image_comp F (optimal_GH_injr X Y),
      image_univ, ← Hausdorff_dist_optimal]
    exact (Hausdorff_dist_image (kuratowskiEmbedding.isometry _)).symm
#align Gromov_Hausdorff.GH_dist_eq_Hausdorff_dist GromovHausdorff.gHDist_eq_hausdorffDist

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The Gromov-Hausdorff distance defines a genuine distance on the Gromov-Hausdorff space. -/
instance : MetricSpace GHSpace where
  dist := dist
  dist_self x := by
    rcases exists_rep x with ⟨y, hy⟩
    refine' le_antisymm _ _
    · apply csInf_le
      · exact ⟨0, by rintro b ⟨⟨u, v⟩, ⟨hu, hv⟩, rfl⟩; exact Hausdorff_dist_nonneg⟩
      · simp only [mem_image, mem_prod, mem_set_of_eq, Prod.exists]
        exists y, y
        simpa only [and_self_iff, Hausdorff_dist_self_zero, eq_self_iff_true, and_true_iff]
    · apply le_csInf
      · exact (nonempty.prod ⟨y, hy⟩ ⟨y, hy⟩).image _
      · rintro b ⟨⟨u, v⟩, ⟨hu, hv⟩, rfl⟩; exact Hausdorff_dist_nonneg
  dist_comm x y :=
    by
    have A :
      (fun p : nonempty_compacts ℓ_infty_ℝ × nonempty_compacts ℓ_infty_ℝ =>
            Hausdorff_dist (p.1 : Set ℓ_infty_ℝ) p.2) ''
          {a | ⟦a⟧ = x} ×ˢ {b | ⟦b⟧ = y} =
        (fun p : nonempty_compacts ℓ_infty_ℝ × nonempty_compacts ℓ_infty_ℝ =>
              Hausdorff_dist (p.1 : Set ℓ_infty_ℝ) p.2) ∘
            Prod.swap ''
          {a | ⟦a⟧ = x} ×ˢ {b | ⟦b⟧ = y} :=
      by congr; funext; simp only [comp_app, Prod.fst_swap, Prod.snd_swap]; rw [Hausdorff_dist_comm]
    simp only [dist, A, image_comp, image_swap_prod]
  eq_of_dist_eq_zero x y hxy :=
    by
    /- To show that two spaces at zero distance are isometric, we argue that the distance
        is realized by some coupling. In this coupling, the two spaces are at zero Hausdorff distance,
        i.e., they coincide. Therefore, the original spaces are isometric. -/
    rcases GH_dist_eq_Hausdorff_dist x.rep y.rep with ⟨Φ, Ψ, Φisom, Ψisom, DΦΨ⟩
    rw [← dist_GH_dist, hxy] at DΦΨ 
    have : range Φ = range Ψ :=
      by
      have hΦ : IsCompact (range Φ) := isCompact_range Φisom.continuous
      have hΨ : IsCompact (range Ψ) := isCompact_range Ψisom.continuous
      apply (IsClosed.hausdorffDist_zero_iff_eq _ _ _).1 DΦΨ.symm
      · exact hΦ.is_closed
      · exact hΨ.is_closed
      ·
        exact
          Hausdorff_edist_ne_top_of_nonempty_of_bounded (range_nonempty _) (range_nonempty _)
            hΦ.bounded hΨ.bounded
    have T : (range Ψ ≃ᵢ y.rep) = (range Φ ≃ᵢ y.rep) := by rw [this]
    have eΨ := cast T Ψisom.isometry_equiv_on_range.symm
    have e := Φisom.isometry_equiv_on_range.trans eΨ
    rw [← x.to_GH_space_rep, ← y.to_GH_space_rep, to_GH_space_eq_to_GH_space_iff_isometry_equiv]
    exact ⟨e⟩
  dist_triangle x y z :=
    by
    /- To show the triangular inequality between `X`, `Y` and `Z`, realize an optimal coupling
        between `X` and `Y` in a space `γ1`, and an optimal coupling between `Y` and `Z` in a space
        `γ2`. Then, glue these metric spaces along `Y`. We get a new space `γ` in which `X` and `Y` are
        optimally coupled, as well as `Y` and `Z`. Apply the triangle inequality for the Hausdorff
        distance in `γ` to conclude. -/
    let X := x.rep
    let Y := y.rep
    let Z := z.rep
    let γ1 := optimal_GH_coupling X Y
    let γ2 := optimal_GH_coupling Y Z
    let Φ : Y → γ1 := optimal_GH_injr X Y
    have hΦ : Isometry Φ := isometry_optimal_GH_injr X Y
    let Ψ : Y → γ2 := optimal_GH_injl Y Z
    have hΨ : Isometry Ψ := isometry_optimal_GH_injl Y Z
    let γ := glue_space hΦ hΨ
    have Comm : to_glue_l hΦ hΨ ∘ optimal_GH_injr X Y = to_glue_r hΦ hΨ ∘ optimal_GH_injl Y Z :=
      to_glue_commute hΦ hΨ
    calc
      dist x z = dist (to_GH_space X) (to_GH_space Z) := by
        rw [x.to_GH_space_rep, z.to_GH_space_rep]
      _ ≤
          Hausdorff_dist (range (to_glue_l hΦ hΨ ∘ optimal_GH_injl X Y))
            (range (to_glue_r hΦ hΨ ∘ optimal_GH_injr Y Z)) :=
        (GH_dist_le_Hausdorff_dist ((to_glue_l_isometry hΦ hΨ).comp (isometry_optimal_GH_injl X Y))
          ((to_glue_r_isometry hΦ hΨ).comp (isometry_optimal_GH_injr Y Z)))
      _ ≤
          Hausdorff_dist (range (to_glue_l hΦ hΨ ∘ optimal_GH_injl X Y))
              (range (to_glue_l hΦ hΨ ∘ optimal_GH_injr X Y)) +
            Hausdorff_dist (range (to_glue_l hΦ hΨ ∘ optimal_GH_injr X Y))
              (range (to_glue_r hΦ hΨ ∘ optimal_GH_injr Y Z)) :=
        by
        refine'
          Hausdorff_dist_triangle
            (Hausdorff_edist_ne_top_of_nonempty_of_bounded (range_nonempty _) (range_nonempty _) _
              _)
        ·
          exact
            (isCompact_range
                (Isometry.continuous
                  ((to_glue_l_isometry hΦ hΨ).comp (isometry_optimal_GH_injl X Y)))).Bounded
        ·
          exact
            (isCompact_range
                (Isometry.continuous
                  ((to_glue_l_isometry hΦ hΨ).comp (isometry_optimal_GH_injr X Y)))).Bounded
      _ =
          Hausdorff_dist (to_glue_l hΦ hΨ '' range (optimal_GH_injl X Y))
              (to_glue_l hΦ hΨ '' range (optimal_GH_injr X Y)) +
            Hausdorff_dist (to_glue_r hΦ hΨ '' range (optimal_GH_injl Y Z))
              (to_glue_r hΦ hΨ '' range (optimal_GH_injr Y Z)) :=
        by simp only [← range_comp, Comm, eq_self_iff_true, add_right_inj]
      _ =
          Hausdorff_dist (range (optimal_GH_injl X Y)) (range (optimal_GH_injr X Y)) +
            Hausdorff_dist (range (optimal_GH_injl Y Z)) (range (optimal_GH_injr Y Z)) :=
        by
        rw [Hausdorff_dist_image (to_glue_l_isometry hΦ hΨ),
          Hausdorff_dist_image (to_glue_r_isometry hΦ hΨ)]
      _ = dist (to_GH_space X) (to_GH_space Y) + dist (to_GH_space Y) (to_GH_space Z) := by
        rw [Hausdorff_dist_optimal, Hausdorff_dist_optimal, GH_dist, GH_dist]
      _ = dist x y + dist y z := by rw [x.to_GH_space_rep, y.to_GH_space_rep, z.to_GH_space_rep]

end GHSpace

--section
end GromovHausdorff

/-- In particular, nonempty compacts of a metric space map to `GH_space`. We register this
in the topological_space namespace to take advantage of the notation `p.to_GH_space`. -/
def TopologicalSpace.NonemptyCompacts.toGHSpace {X : Type u} [MetricSpace X]
    (p : NonemptyCompacts X) : GromovHausdorff.GHSpace :=
  GromovHausdorff.toGHSpace p
#align topological_space.nonempty_compacts.to_GH_space TopologicalSpace.NonemptyCompacts.toGHSpace

open TopologicalSpace

namespace GromovHausdorff

section NonemptyCompacts

variable {X : Type u} [MetricSpace X]

theorem GH_dist_le_nonemptyCompacts_dist (p q : NonemptyCompacts X) :
    dist p.toGHSpace q.toGHSpace ≤ dist p q :=
  by
  have ha : Isometry (coe : p → X) := isometry_subtype_coe
  have hb : Isometry (coe : q → X) := isometry_subtype_coe
  have A : dist p q = Hausdorff_dist (p : Set X) q := rfl
  have I : ↑p = range (coe : p → X) := subtype.range_coe_subtype.symm
  have J : ↑q = range (coe : q → X) := subtype.range_coe_subtype.symm
  rw [A, I, J]
  exact GH_dist_le_Hausdorff_dist ha hb
#align Gromov_Hausdorff.GH_dist_le_nonempty_compacts_dist GromovHausdorff.GH_dist_le_nonemptyCompacts_dist

theorem toGHSpace_lipschitz :
    LipschitzWith 1 (NonemptyCompacts.toGHSpace : NonemptyCompacts X → GHSpace) :=
  LipschitzWith.mk_one GH_dist_le_nonemptyCompacts_dist
#align Gromov_Hausdorff.to_GH_space_lipschitz GromovHausdorff.toGHSpace_lipschitz

theorem toGHSpace_continuous :
    Continuous (NonemptyCompacts.toGHSpace : NonemptyCompacts X → GHSpace) :=
  toGHSpace_lipschitz.Continuous
#align Gromov_Hausdorff.to_GH_space_continuous GromovHausdorff.toGHSpace_continuous

end NonemptyCompacts

section

/- In this section, we show that if two metric spaces are isometric up to `ε₂`, then their
Gromov-Hausdorff distance is bounded by `ε₂ / 2`. More generally, if there are subsets which are
`ε₁`-dense and `ε₃`-dense in two spaces, and isometric up to `ε₂`, then the Gromov-Hausdorff
distance between the spaces is bounded by `ε₁ + ε₂/2 + ε₃`. For this, we construct a suitable
coupling between the two spaces, by gluing them (approximately) along the two matching subsets. -/
variable {X : Type u} [MetricSpace X] [CompactSpace X] [Nonempty X] {Y : Type v} [MetricSpace Y]
  [CompactSpace Y] [Nonempty Y]

-- we want to ignore these instances in the following theorem
attribute [local instance 10] Sum.topologicalSpace Sum.uniformSpace

/-- If there are subsets which are `ε₁`-dense and `ε₃`-dense in two spaces, and
isometric up to `ε₂`, then the Gromov-Hausdorff distance between the spaces is bounded by
`ε₁ + ε₂/2 + ε₃`. -/
theorem gHDist_le_of_approx_subsets {s : Set X} (Φ : s → Y) {ε₁ ε₂ ε₃ : ℝ}
    (hs : ∀ x : X, ∃ y ∈ s, dist x y ≤ ε₁) (hs' : ∀ x : Y, ∃ y : s, dist x (Φ y) ≤ ε₃)
    (H : ∀ x y : s, |dist x y - dist (Φ x) (Φ y)| ≤ ε₂) : gHDist X Y ≤ ε₁ + ε₂ / 2 + ε₃ :=
  by
  refine' le_of_forall_pos_le_add fun δ δ0 => _
  rcases exists_mem_of_nonempty X with ⟨xX, _⟩
  rcases hs xX with ⟨xs, hxs, Dxs⟩
  have sne : s.nonempty := ⟨xs, hxs⟩
  letI : Nonempty s := sne.to_subtype
  have : 0 ≤ ε₂ := le_trans (abs_nonneg _) (H ⟨xs, hxs⟩ ⟨xs, hxs⟩)
  have : ∀ p q : s, |dist p q - dist (Φ p) (Φ q)| ≤ 2 * (ε₂ / 2 + δ) := fun p q =>
    calc
      |dist p q - dist (Φ p) (Φ q)| ≤ ε₂ := H p q
      _ ≤ 2 * (ε₂ / 2 + δ) := by linarith
  -- glue `X` and `Y` along the almost matching subsets
  letI : MetricSpace (Sum X Y) :=
    glue_metric_approx (fun x : s => (x : X)) (fun x => Φ x) (ε₂ / 2 + δ) (by linarith) this
  let Fl := @Sum.inl X Y
  let Fr := @Sum.inr X Y
  have Il : Isometry Fl := Isometry.of_dist_eq fun x y => rfl
  have Ir : Isometry Fr := Isometry.of_dist_eq fun x y => rfl
  /- The proof goes as follows : the `GH_dist` is bounded by the Hausdorff distance of the images
    in the coupling, which is bounded (using the triangular inequality) by the sum of the Hausdorff
    distances of `X` and `s` (in the coupling or, equivalently in the original space), of `s` and
    `Φ s`, and of `Φ s` and `Y` (in the coupling or, equivalently, in the original space). The first
    term is bounded by `ε₁`, by `ε₁`-density. The third one is bounded by `ε₃`. And the middle one is
    bounded by `ε₂/2` as in the coupling the points `x` and `Φ x` are at distance `ε₂/2` by
    construction of the coupling (in fact `ε₂/2 + δ` where `δ` is an arbitrarily small positive
    constant where positivity is used to ensure that the coupling is really a metric space and not a
    premetric space on `X ⊕ Y`). -/
  have : GH_dist X Y ≤ Hausdorff_dist (range Fl) (range Fr) := GH_dist_le_Hausdorff_dist Il Ir
  have :
    Hausdorff_dist (range Fl) (range Fr) ≤
      Hausdorff_dist (range Fl) (Fl '' s) + Hausdorff_dist (Fl '' s) (range Fr) :=
    haveI B : bounded (range Fl) := (isCompact_range Il.continuous).Bounded
    Hausdorff_dist_triangle
      (Hausdorff_edist_ne_top_of_nonempty_of_bounded (range_nonempty _) (sne.image _) B
        (B.mono (image_subset_range _ _)))
  have :
    Hausdorff_dist (Fl '' s) (range Fr) ≤
      Hausdorff_dist (Fl '' s) (Fr '' range Φ) + Hausdorff_dist (Fr '' range Φ) (range Fr) :=
    haveI B : bounded (range Fr) := (isCompact_range Ir.continuous).Bounded
    Hausdorff_dist_triangle'
      (Hausdorff_edist_ne_top_of_nonempty_of_bounded ((range_nonempty _).image _) (range_nonempty _)
        (bounded.mono (image_subset_range _ _) B) B)
  have : Hausdorff_dist (range Fl) (Fl '' s) ≤ ε₁ :=
    by
    rw [← image_univ, Hausdorff_dist_image Il]
    have : 0 ≤ ε₁ := le_trans dist_nonneg Dxs
    refine'
      Hausdorff_dist_le_of_mem_dist this (fun x hx => hs x) fun x hx =>
        ⟨x, mem_univ _, by simpa only [dist_self]⟩
  have : Hausdorff_dist (Fl '' s) (Fr '' range Φ) ≤ ε₂ / 2 + δ :=
    by
    refine' Hausdorff_dist_le_of_mem_dist (by linarith) _ _
    · intro x' hx'
      rcases(Set.mem_image _ _ _).1 hx' with ⟨x, ⟨x_in_s, xx'⟩⟩
      rw [← xx']
      use Fr (Φ ⟨x, x_in_s⟩), mem_image_of_mem Fr (mem_range_self _)
      exact le_of_eq (glue_dist_glued_points (fun x : s => (x : X)) Φ (ε₂ / 2 + δ) ⟨x, x_in_s⟩)
    · intro x' hx'
      rcases(Set.mem_image _ _ _).1 hx' with ⟨y, ⟨y_in_s', yx'⟩⟩
      rcases mem_range.1 y_in_s' with ⟨x, xy⟩
      use Fl x, mem_image_of_mem _ x.2
      rw [← yx', ← xy, dist_comm]
      exact le_of_eq (glue_dist_glued_points (@Subtype.val X s) Φ (ε₂ / 2 + δ) x)
  have : Hausdorff_dist (Fr '' range Φ) (range Fr) ≤ ε₃ :=
    by
    rw [← @image_univ _ _ Fr, Hausdorff_dist_image Ir]
    rcases exists_mem_of_nonempty Y with ⟨xY, _⟩
    rcases hs' xY with ⟨xs', Dxs'⟩
    have : 0 ≤ ε₃ := le_trans dist_nonneg Dxs'
    refine'
      Hausdorff_dist_le_of_mem_dist this (fun x hx => ⟨x, mem_univ _, by simpa only [dist_self]⟩)
        fun x _ => _
    rcases hs' x with ⟨y, Dy⟩
    exact ⟨Φ y, mem_range_self _, Dy⟩
  linarith
#align Gromov_Hausdorff.GH_dist_le_of_approx_subsets GromovHausdorff.gHDist_le_of_approx_subsets

end

--section
/-- The Gromov-Hausdorff space is second countable. -/
instance : SecondCountableTopology GHSpace :=
  by
  refine' second_countable_of_countable_discretization fun δ δpos => _
  let ε := 2 / 5 * δ
  have εpos : 0 < ε := mul_pos (by norm_num) δpos
  have : ∀ p : GH_space, ∃ s : Set p.rep, s.Finite ∧ univ ⊆ ⋃ x ∈ s, ball x ε := fun p => by
    simpa only [subset_univ, exists_true_left] using
      finite_cover_balls_of_compact isCompact_univ εpos
  -- for each `p`, `s p` is a finite `ε`-dense subset of `p` (or rather the metric space
  -- `p.rep` representing `p`)
  choose s hs using this
  have : ∀ p : GH_space, ∀ t : Set p.rep, t.Finite → ∃ n : ℕ, ∃ e : Equiv t (Fin n), True :=
    by
    intro p t ht
    letI : Fintype t := finite.fintype ht
    exact ⟨Fintype.card t, Fintype.equivFin t, trivial⟩
  choose N e hne using this
  -- cardinality of the nice finite subset `s p` of `p.rep`, called `N p`
  let N := fun p : GH_space => N p (s p) (hs p).1
  -- equiv from `s p`, a nice finite subset of `p.rep`, to `fin (N p)`, called `E p`
  let E := fun p : GH_space => e p (s p) (hs p).1
  -- A function `F` associating to `p : GH_space` the data of all distances between points
  -- in the `ε`-dense set `s p`.
  let F : GH_space → Σ n : ℕ, Fin n → Fin n → ℤ := fun p =>
    ⟨N p, fun a b => ⌊ε⁻¹ * dist ((E p).symm a) ((E p).symm b)⌋⟩
  refine' ⟨Σ n, Fin n → Fin n → ℤ, by infer_instance, F, fun p q hpq => _⟩
  /- As the target space of F is countable, it suffices to show that two points
    `p` and `q` with `F p = F q` are at distance `≤ δ`.
    For this, we construct a map `Φ` from `s p ⊆ p.rep` (representing `p`)
    to `q.rep` (representing `q`) which is almost an isometry on `s p`, and
    with image `s q`. For this, we compose the identification of `s p` with `fin (N p)`
    and the inverse of the identification of `s q` with `fin (N q)`. Together with
    the fact that `N p = N q`, this constructs `Ψ` between `s p` and `s q`, and then
    composing with the canonical inclusion we get `Φ`. -/
  have Npq : N p = N q := (Sigma.mk.inj_iff.1 hpq).1
  let Ψ : s p → s q := fun x => (E q).symm (Fin.cast Npq ((E p) x))
  let Φ : s p → q.rep := fun x => Ψ x
  -- Use the almost isometry `Φ` to show that `p.rep` and `q.rep`
  -- are within controlled Gromov-Hausdorff distance.
  have main : GH_dist p.rep q.rep ≤ ε + ε / 2 + ε :=
    by
    refine' GH_dist_le_of_approx_subsets Φ _ _ _
    show ∀ x : p.rep, ∃ (y : p.rep) (H : y ∈ s p), dist x y ≤ ε
    · -- by construction, `s p` is `ε`-dense
      intro x
      have : x ∈ ⋃ y ∈ s p, ball y ε := (hs p).2 (mem_univ _)
      rcases mem_Union₂.1 this with ⟨y, ys, hy⟩
      exact ⟨y, ys, le_of_lt hy⟩
    show ∀ x : q.rep, ∃ z : s p, dist x (Φ z) ≤ ε
    · -- by construction, `s q` is `ε`-dense, and it is the range of `Φ`
      intro x
      have : x ∈ ⋃ y ∈ s q, ball y ε := (hs q).2 (mem_univ _)
      rcases mem_Union₂.1 this with ⟨y, ys, hy⟩
      let i : ℕ := E q ⟨y, ys⟩
      let hi := ((E q) ⟨y, ys⟩).is_lt
      have ihi_eq : (⟨i, hi⟩ : Fin (N q)) = (E q) ⟨y, ys⟩ := by rw [Fin.ext_iff, Fin.val_mk]
      have hiq : i < N q := hi
      have hip : i < N p := by rwa [Npq.symm] at hiq 
      let z := (E p).symm ⟨i, hip⟩
      use z
      have C1 : (E p) z = ⟨i, hip⟩ := (E p).apply_symm_apply ⟨i, hip⟩
      have C2 : Fin.cast Npq ⟨i, hip⟩ = ⟨i, hi⟩ := rfl
      have C3 : (E q).symm ⟨i, hi⟩ = ⟨y, ys⟩ := by rw [ihi_eq]; exact (E q).symm_apply_apply ⟨y, ys⟩
      have : Φ z = y := by simp only [Φ, Ψ]; rw [C1, C2, C3]; rfl
      rw [this]
      exact le_of_lt hy
    show ∀ x y : s p, |dist x y - dist (Φ x) (Φ y)| ≤ ε
    · /- the distance between `x` and `y` is encoded in `F p`, and the distance between
            `Φ x` and `Φ y` (two points of `s q`) is encoded in `F q`, all this up to `ε`.
            As `F p = F q`, the distances are almost equal. -/
      intro x y
      have : dist (Φ x) (Φ y) = dist (Ψ x) (Ψ y) := rfl
      rw [this]
      -- introduce `i`, that codes both `x` and `Φ x` in `fin (N p) = fin (N q)`
      let i : ℕ := E p x
      have hip : i < N p := ((E p) x).2
      have hiq : i < N q := by rwa [Npq] at hip 
      have i' : i = (E q) (Ψ x) := by simp only [Equiv.apply_symm_apply, Fin.coe_cast]
      -- introduce `j`, that codes both `y` and `Φ y` in `fin (N p) = fin (N q)`
      let j : ℕ := E p y
      have hjp : j < N p := ((E p) y).2
      have hjq : j < N q := by rwa [Npq] at hjp 
      have j' : j = ((E q) (Ψ y)).1 := by
        simp only [Equiv.apply_symm_apply, Fin.val_eq_coe, Fin.coe_cast]
      -- Express `dist x y` in terms of `F p`
      have : (F p).2 ((E p) x) ((E p) y) = floor (ε⁻¹ * dist x y) := by
        simp only [F, (E p).symm_apply_apply]
      have Ap : (F p).2 ⟨i, hip⟩ ⟨j, hjp⟩ = floor (ε⁻¹ * dist x y) := by rw [← this];
        congr <;> apply Fin.ext_iff.2 <;> rfl
      -- Express `dist (Φ x) (Φ y)` in terms of `F q`
      have : (F q).2 ((E q) (Ψ x)) ((E q) (Ψ y)) = floor (ε⁻¹ * dist (Ψ x) (Ψ y)) := by
        simp only [F, (E q).symm_apply_apply]
      have Aq : (F q).2 ⟨i, hiq⟩ ⟨j, hjq⟩ = floor (ε⁻¹ * dist (Ψ x) (Ψ y)) := by rw [← this];
        congr <;> apply Fin.ext_iff.2 <;> [exact i'; exact j']
      -- use the equality between `F p` and `F q` to deduce that the distances have equal
      -- integer parts
      have : (F p).2 ⟨i, hip⟩ ⟨j, hjp⟩ = (F q).2 ⟨i, hiq⟩ ⟨j, hjq⟩ :=
        by
        -- we want to `subst hpq` where `hpq : F p = F q`, except that `subst` only works
        -- with a constant, so replace `F q` (and everything that depends on it) by a constant `f`
        -- then `subst`
        revert hiq hjq
        change N q with (F q).1
        generalize F q = f at hpq ⊢
        subst hpq
        intros
        rfl
      rw [Ap, Aq] at this 
      -- deduce that the distances coincide up to `ε`, by a straightforward computation
      -- that should be automated
      have I :=
        calc
          |ε⁻¹| * |dist x y - dist (Ψ x) (Ψ y)| = |ε⁻¹ * (dist x y - dist (Ψ x) (Ψ y))| :=
            (abs_mul _ _).symm
          _ = |ε⁻¹ * dist x y - ε⁻¹ * dist (Ψ x) (Ψ y)| := by congr; ring
          _ ≤ 1 := le_of_lt (abs_sub_lt_one_of_floor_eq_floor this)
      calc
        |dist x y - dist (Ψ x) (Ψ y)| = ε * ε⁻¹ * |dist x y - dist (Ψ x) (Ψ y)| := by
          rw [mul_inv_cancel (ne_of_gt εpos), one_mul]
        _ = ε * (|ε⁻¹| * |dist x y - dist (Ψ x) (Ψ y)|) := by
          rw [abs_of_nonneg (le_of_lt (inv_pos.2 εpos)), mul_assoc]
        _ ≤ ε * 1 := (mul_le_mul_of_nonneg_left I (le_of_lt εpos))
        _ = ε := mul_one _
  calc
    dist p q = GH_dist p.rep q.rep := dist_GH_dist p q
    _ ≤ ε + ε / 2 + ε := main
    _ = δ := by simp only [ε]; ring

/-- Compactness criterion: a closed set of compact metric spaces is compact if the spaces have
a uniformly bounded diameter, and for all `ε` the number of balls of radius `ε` required
to cover the spaces is uniformly bounded. This is an equivalence, but we only prove the
interesting direction that these conditions imply compactness. -/
theorem totallyBounded {t : Set GHSpace} {C : ℝ} {u : ℕ → ℝ} {K : ℕ → ℕ}
    (ulim : Tendsto u atTop (𝓝 0)) (hdiam : ∀ p ∈ t, diam (univ : Set (GHSpace.Rep p)) ≤ C)
    (hcov :
      ∀ p ∈ t,
        ∀ n : ℕ, ∃ s : Set (GHSpace.Rep p), Cardinal.mk s ≤ K n ∧ univ ⊆ ⋃ x ∈ s, ball x (u n)) :
    TotallyBounded t :=
  by
  /- Let `δ>0`, and `ε = δ/5`. For each `p`, we construct a finite subset `s p` of `p`, which
    is `ε`-dense and has cardinality at most `K n`. Encoding the mutual distances of points in `s p`,
    up to `ε`, we will get a map `F` associating to `p` finitely many data, and making it possible to
    reconstruct `p` up to `ε`. This is enough to prove total boundedness. -/
  refine' Metric.totallyBounded_of_finite_discretization fun δ δpos => _
  let ε := 1 / 5 * δ
  have εpos : 0 < ε := mul_pos (by norm_num) δpos
  -- choose `n` for which `u n < ε`
  rcases Metric.tendsto_atTop.1 ulim ε εpos with ⟨n, hn⟩
  have u_le_ε : u n ≤ ε := by
    have := hn n le_rfl
    simp only [Real.dist_eq, add_zero, sub_eq_add_neg, neg_zero] at this 
    exact le_of_lt (lt_of_le_of_lt (le_abs_self _) this)
  -- construct a finite subset `s p` of `p` which is `ε`-dense and has cardinal `≤ K n`
  have :
    ∀ p : GH_space,
      ∃ s : Set p.rep, ∃ N ≤ K n, ∃ E : Equiv s (Fin N), p ∈ t → univ ⊆ ⋃ x ∈ s, ball x (u n) :=
    by
    intro p
    by_cases hp : p ∉ t
    · have : Nonempty (Equiv (∅ : Set p.rep) (Fin 0)) := by rw [← Fintype.card_eq];
        simp only [empty_card', Fintype.card_fin]
      use ∅, 0, bot_le, choice this
    · rcases hcov _ (Set.not_not_mem.1 hp) n with ⟨s, ⟨scard, scover⟩⟩
      rcases Cardinal.lt_aleph0.1 (lt_of_le_of_lt scard (Cardinal.nat_lt_aleph0 _)) with ⟨N, hN⟩
      rw [hN, Cardinal.natCast_le] at scard 
      have : Cardinal.mk s = Cardinal.mk (Fin N) := by rw [hN, Cardinal.mk_fin]
      cases' Quotient.exact this with E
      use s, N, scard, E
      simp only [scover, imp_true_iff]
  choose s N hN E hs using this
  -- Define a function `F` taking values in a finite type and associating to `p` enough data
  -- to reconstruct it up to `ε`, namely the (discretized) distances between elements of `s p`.
  let M := ⌊ε⁻¹ * max C 0⌋₊
  let F : GH_space → Σ k : Fin (K n).succ, Fin k → Fin k → Fin M.succ := fun p =>
    ⟨⟨N p, lt_of_le_of_lt (hN p) (Nat.lt_succ_self _)⟩, fun a b =>
      ⟨min M ⌊ε⁻¹ * dist ((E p).symm a) ((E p).symm b)⌋₊,
        (min_le_left _ _).trans_lt (Nat.lt_succ_self _)⟩⟩
  refine' ⟨_, _, fun p => F p, _⟩; infer_instance
  -- It remains to show that if `F p = F q`, then `p` and `q` are `ε`-close
  rintro ⟨p, pt⟩ ⟨q, qt⟩ hpq
  have Npq : N p = N q := Fin.ext_iff.1 (Sigma.mk.inj_iff.1 hpq).1
  let Ψ : s p → s q := fun x => (E q).symm (Fin.cast Npq ((E p) x))
  let Φ : s p → q.rep := fun x => Ψ x
  have main : GH_dist p.rep q.rep ≤ ε + ε / 2 + ε :=
    by
    -- to prove the main inequality, argue that `s p` is `ε`-dense in `p`, and `s q` is `ε`-dense
    -- in `q`, and `s p` and `s q` are almost isometric. Then closeness follows
    -- from `GH_dist_le_of_approx_subsets`
    refine' GH_dist_le_of_approx_subsets Φ _ _ _
    show ∀ x : p.rep, ∃ (y : p.rep) (H : y ∈ s p), dist x y ≤ ε
    · -- by construction, `s p` is `ε`-dense
      intro x
      have : x ∈ ⋃ y ∈ s p, ball y (u n) := (hs p pt) (mem_univ _)
      rcases mem_Union₂.1 this with ⟨y, ys, hy⟩
      exact ⟨y, ys, le_trans (le_of_lt hy) u_le_ε⟩
    show ∀ x : q.rep, ∃ z : s p, dist x (Φ z) ≤ ε
    · -- by construction, `s q` is `ε`-dense, and it is the range of `Φ`
      intro x
      have : x ∈ ⋃ y ∈ s q, ball y (u n) := (hs q qt) (mem_univ _)
      rcases mem_Union₂.1 this with ⟨y, ys, hy⟩
      let i : ℕ := E q ⟨y, ys⟩
      let hi := ((E q) ⟨y, ys⟩).2
      have ihi_eq : (⟨i, hi⟩ : Fin (N q)) = (E q) ⟨y, ys⟩ := by rw [Fin.ext_iff, Fin.val_mk]
      have hiq : i < N q := hi
      have hip : i < N p := by rwa [Npq.symm] at hiq 
      let z := (E p).symm ⟨i, hip⟩
      use z
      have C1 : (E p) z = ⟨i, hip⟩ := (E p).apply_symm_apply ⟨i, hip⟩
      have C2 : Fin.cast Npq ⟨i, hip⟩ = ⟨i, hi⟩ := rfl
      have C3 : (E q).symm ⟨i, hi⟩ = ⟨y, ys⟩ := by rw [ihi_eq]; exact (E q).symm_apply_apply ⟨y, ys⟩
      have : Φ z = y := by simp only [Φ, Ψ]; rw [C1, C2, C3]; rfl
      rw [this]
      exact le_trans (le_of_lt hy) u_le_ε
    show ∀ x y : s p, |dist x y - dist (Φ x) (Φ y)| ≤ ε
    · /- the distance between `x` and `y` is encoded in `F p`, and the distance between
            `Φ x` and `Φ y` (two points of `s q`) is encoded in `F q`, all this up to `ε`.
            As `F p = F q`, the distances are almost equal. -/
      intro x y
      have : dist (Φ x) (Φ y) = dist (Ψ x) (Ψ y) := rfl
      rw [this]
      -- introduce `i`, that codes both `x` and `Φ x` in `fin (N p) = fin (N q)`
      let i : ℕ := E p x
      have hip : i < N p := ((E p) x).2
      have hiq : i < N q := by rwa [Npq] at hip 
      have i' : i = (E q) (Ψ x) := by simp only [Equiv.apply_symm_apply, Fin.coe_cast]
      -- introduce `j`, that codes both `y` and `Φ y` in `fin (N p) = fin (N q)`
      let j : ℕ := E p y
      have hjp : j < N p := ((E p) y).2
      have hjq : j < N q := by rwa [Npq] at hjp 
      have j' : j = (E q) (Ψ y) := by simp only [Equiv.apply_symm_apply, Fin.coe_cast]
      -- Express `dist x y` in terms of `F p`
      have Ap : ((F p).2 ⟨i, hip⟩ ⟨j, hjp⟩).1 = ⌊ε⁻¹ * dist x y⌋₊ :=
        calc
          ((F p).2 ⟨i, hip⟩ ⟨j, hjp⟩).1 = ((F p).2 ((E p) x) ((E p) y)).1 := by
            congr <;> apply Fin.ext_iff.2 <;> rfl
          _ = min M ⌊ε⁻¹ * dist x y⌋₊ := by simp only [F, (E p).symm_apply_apply]
          _ = ⌊ε⁻¹ * dist x y⌋₊ := by
            refine' min_eq_right (Nat.floor_mono _)
            refine' mul_le_mul_of_nonneg_left (le_trans _ (le_max_left _ _)) (inv_pos.2 εpos).le
            change dist (x : p.rep) y ≤ C
            refine'
              le_trans (dist_le_diam_of_mem is_compact_univ.bounded (mem_univ _) (mem_univ _)) _
            exact hdiam p pt
      -- Express `dist (Φ x) (Φ y)` in terms of `F q`
      have Aq : ((F q).2 ⟨i, hiq⟩ ⟨j, hjq⟩).1 = ⌊ε⁻¹ * dist (Ψ x) (Ψ y)⌋₊ :=
        calc
          ((F q).2 ⟨i, hiq⟩ ⟨j, hjq⟩).1 = ((F q).2 ((E q) (Ψ x)) ((E q) (Ψ y))).1 := by
            congr <;> apply Fin.ext_iff.2 <;> [exact i'; exact j']
          _ = min M ⌊ε⁻¹ * dist (Ψ x) (Ψ y)⌋₊ := by simp only [F, (E q).symm_apply_apply]
          _ = ⌊ε⁻¹ * dist (Ψ x) (Ψ y)⌋₊ :=
            by
            refine' min_eq_right (Nat.floor_mono _)
            refine' mul_le_mul_of_nonneg_left (le_trans _ (le_max_left _ _)) (inv_pos.2 εpos).le
            change dist (Ψ x : q.rep) (Ψ y) ≤ C
            refine'
              le_trans (dist_le_diam_of_mem is_compact_univ.bounded (mem_univ _) (mem_univ _)) _
            exact hdiam q qt
      -- use the equality between `F p` and `F q` to deduce that the distances have equal
      -- integer parts
      have : ((F p).2 ⟨i, hip⟩ ⟨j, hjp⟩).1 = ((F q).2 ⟨i, hiq⟩ ⟨j, hjq⟩).1 :=
        by
        -- we want to `subst hpq` where `hpq : F p = F q`, except that `subst` only works
        -- with a constant, so replace `F q` (and everything that depends on it) by a constant `f`
        -- then `subst`
        revert hiq hjq
        change N q with (F q).1
        generalize F q = f at hpq ⊢
        subst hpq
        intros
        rfl
      have : ⌊ε⁻¹ * dist x y⌋ = ⌊ε⁻¹ * dist (Ψ x) (Ψ y)⌋ :=
        by
        rw [Ap, Aq] at this 
        have D : 0 ≤ ⌊ε⁻¹ * dist x y⌋ :=
          floor_nonneg.2 (mul_nonneg (le_of_lt (inv_pos.2 εpos)) dist_nonneg)
        have D' : 0 ≤ ⌊ε⁻¹ * dist (Ψ x) (Ψ y)⌋ :=
          floor_nonneg.2 (mul_nonneg (le_of_lt (inv_pos.2 εpos)) dist_nonneg)
        rw [← Int.toNat_of_nonneg D, ← Int.toNat_of_nonneg D', Int.floor_toNat, Int.floor_toNat,
          this]
      -- deduce that the distances coincide up to `ε`, by a straightforward computation
      -- that should be automated
      have I :=
        calc
          |ε⁻¹| * |dist x y - dist (Ψ x) (Ψ y)| = |ε⁻¹ * (dist x y - dist (Ψ x) (Ψ y))| :=
            (abs_mul _ _).symm
          _ = |ε⁻¹ * dist x y - ε⁻¹ * dist (Ψ x) (Ψ y)| := by congr; ring
          _ ≤ 1 := le_of_lt (abs_sub_lt_one_of_floor_eq_floor this)
      calc
        |dist x y - dist (Ψ x) (Ψ y)| = ε * ε⁻¹ * |dist x y - dist (Ψ x) (Ψ y)| := by
          rw [mul_inv_cancel (ne_of_gt εpos), one_mul]
        _ = ε * (|ε⁻¹| * |dist x y - dist (Ψ x) (Ψ y)|) := by
          rw [abs_of_nonneg (le_of_lt (inv_pos.2 εpos)), mul_assoc]
        _ ≤ ε * 1 := (mul_le_mul_of_nonneg_left I (le_of_lt εpos))
        _ = ε := mul_one _
  calc
    dist p q = GH_dist p.rep q.rep := dist_GH_dist p q
    _ ≤ ε + ε / 2 + ε := main
    _ = δ / 2 := by simp only [ε, one_div]; ring
    _ < δ := half_lt_self δpos
#align Gromov_Hausdorff.totally_bounded GromovHausdorff.totallyBounded

section Complete

/- We will show that a sequence `u n` of compact metric spaces satisfying
`dist (u n) (u (n+1)) < 1/2^n` converges, which implies completeness of the Gromov-Hausdorff space.
We need to exhibit the limiting compact metric space. For this, start from
a sequence `X n` of representatives of `u n`, and glue in an optimal way `X n` to `X (n+1)`
for all `n`, in a common metric space. Formally, this is done as follows.
Start from `Y 0 = X 0`. Then, glue `X 0` to `X 1` in an optimal way, yielding a space
`Y 1` (with an embedding of `X 1`). Then, consider an optimal gluing of `X 1` and `X 2`, and
glue it to `Y 1` along their common subspace `X 1`. This gives a new space `Y 2`, with an
embedding of `X 2`. Go on, to obtain a sequence of spaces `Y n`. Let `Z0` be the inductive
limit of the `Y n`, and finally let `Z` be the completion of `Z0`.
The images `X2 n` of `X n` in `Z` are at Hausdorff distance `< 1/2^n` by construction, hence they
form a Cauchy sequence for the Hausdorff distance. By completeness (of `Z`, and therefore of its
set of nonempty compact subsets), they converge to a limit `L`. This is the nonempty
compact metric space we are looking for.  -/
variable (X : ℕ → Type) [∀ n, MetricSpace (X n)] [∀ n, CompactSpace (X n)] [∀ n, Nonempty (X n)]

/-- Auxiliary structure used to glue metric spaces below, recording an isometric embedding
of a type `A` in another metric space. -/
structure AuxGluingStruct (A : Type) [MetricSpace A] : Type 1 where
  Space : Type
  metric : MetricSpace space
  embed : A → space
  isom : Isometry embed
#align Gromov_Hausdorff.aux_gluing_struct GromovHausdorff.AuxGluingStruct

attribute [local instance] aux_gluing_struct.metric

instance (A : Type) [MetricSpace A] : Inhabited (AuxGluingStruct A) :=
  ⟨{  Space := A
      metric := by infer_instance
      embed := id
      isom := fun x y => rfl }⟩

/-- Auxiliary sequence of metric spaces, containing copies of `X 0`, ..., `X n`, where each
`X i` is glued to `X (i+1)` in an optimal way. The space at step `n+1` is obtained from the space
at step `n` by adding `X (n+1)`, glued in an optimal way to the `X n` already sitting there. -/
def auxGluing (n : ℕ) : AuxGluingStruct (X n) :=
  Nat.recOn n default fun n Y =>
    { Space := GlueSpace Y.isom (isometry_optimalGHInjl (X n) (X (n + 1)))
      metric := by infer_instance
      embed :=
        toGlueR Y.isom (isometry_optimalGHInjl (X n) (X (n + 1))) ∘ optimalGHInjr (X n) (X (n + 1))
      isom := (toGlueR_isometry _ _).comp (isometry_optimalGHInjr (X n) (X (n + 1))) }
#align Gromov_Hausdorff.aux_gluing GromovHausdorff.auxGluing

/-- The Gromov-Hausdorff space is complete. -/
instance : CompleteSpace GHSpace :=
  by
  have : ∀ n : ℕ, 0 < ((1 : ℝ) / 2) ^ n := by apply pow_pos; norm_num
  -- start from a sequence of nonempty compact metric spaces within distance `1/2^n` of each other
  refine'
    Metric.complete_of_convergent_controlled_sequences (fun n => (1 / 2) ^ n) this fun u hu => _
  -- `X n` is a representative of `u n`
  let X n := (u n).rep
  -- glue them together successively in an optimal way, getting a sequence of metric spaces `Y n`
  let Y := aux_gluing X
  -- this equality is true by definition but Lean unfolds some defs in the wrong order
  have E :
    ∀ n : ℕ,
      glue_space (Y n).isom (isometry_optimal_GH_injl (X n) (X (n + 1))) = (Y (n + 1)).Space :=
    fun n => by dsimp only [Y, aux_gluing]; rfl
  let c n := cast (E n)
  have ic : ∀ n, Isometry (c n) := fun n x y => by dsimp only [Y, aux_gluing]; exact rfl
  -- there is a canonical embedding of `Y n` in `Y (n+1)`, by construction
  let f : ∀ n, (Y n).Space → (Y (n + 1)).Space := fun n =>
    c n ∘ to_glue_l (Y n).isom (isometry_optimal_GH_injl (X n) (X n.succ))
  have I : ∀ n, Isometry (f n) := fun n => (ic n).comp (to_glue_l_isometry _ _)
  -- consider the inductive limit `Z0` of the `Y n`, and then its completion `Z`
  let Z0 := Metric.InductiveLimit I
  let Z := UniformSpace.Completion Z0
  let Φ := to_inductive_limit I
  let coeZ := (coe : Z0 → Z)
  -- let `X2 n` be the image of `X n` in the space `Z`
  let X2 n := range (coeZ ∘ Φ n ∘ (Y n).embed)
  have isom : ∀ n, Isometry (coeZ ∘ Φ n ∘ (Y n).embed) :=
    by
    intro n
    refine' uniform_space.completion.coe_isometry.comp _
    exact (to_inductive_limit_isometry _ _).comp (Y n).isom
  -- The Hausdorff distance of `X2 n` and `X2 (n+1)` is by construction the distance between
  -- `u n` and `u (n+1)`, therefore bounded by `1/2^n`
  have D2 : ∀ n, Hausdorff_dist (X2 n) (X2 n.succ) < (1 / 2) ^ n :=
    by
    intro n
    have X2n :
      X2 n =
        range
          ((coeZ ∘
              Φ n.succ ∘ c n ∘ to_glue_r (Y n).isom (isometry_optimal_GH_injl (X n) (X n.succ))) ∘
            optimal_GH_injl (X n) (X n.succ)) :=
      by
      change
        X2 n =
          range
            (coeZ ∘
              Φ n.succ ∘
                c n ∘
                  to_glue_r (Y n).isom (isometry_optimal_GH_injl (X n) (X n.succ)) ∘
                    optimal_GH_injl (X n) (X n.succ))
      simp only [X2, Φ]
      rw [← to_inductive_limit_commute I]
      simp only [f]
      rw [← to_glue_commute]
    rw [range_comp] at X2n 
    have X2nsucc :
      X2 n.succ =
        range
          ((coeZ ∘
              Φ n.succ ∘ c n ∘ to_glue_r (Y n).isom (isometry_optimal_GH_injl (X n) (X n.succ))) ∘
            optimal_GH_injr (X n) (X n.succ)) :=
      by rfl
    rw [range_comp] at X2nsucc 
    rw [X2n, X2nsucc, Hausdorff_dist_image, Hausdorff_dist_optimal, ← dist_GH_dist]
    · exact hu n n n.succ (le_refl n) (le_succ n)
    · apply uniform_space.completion.coe_isometry.comp _
      exact (to_inductive_limit_isometry _ _).comp ((ic n).comp (to_glue_r_isometry _ _))
  -- consider `X2 n` as a member `X3 n` of the type of nonempty compact subsets of `Z`, which
  -- is a metric space
  let X3 : ℕ → nonempty_compacts Z := fun n =>
    ⟨⟨X2 n, isCompact_range (isom n).Continuous⟩, range_nonempty _⟩
  -- `X3 n` is a Cauchy sequence by construction, as the successive distances are
  -- bounded by `(1/2)^n`
  have : CauchySeq X3 :=
    by
    refine' cauchySeq_of_le_geometric (1 / 2) 1 (by norm_num) fun n => _
    rw [one_mul]
    exact le_of_lt (D2 n)
  -- therefore, it converges to a limit `L`
  rcases cauchySeq_tendsto_of_complete this with ⟨L, hL⟩
  -- the images of `X3 n` in the Gromov-Hausdorff space converge to the image of `L`
  have M : tendsto (fun n => (X3 n).toGHSpace) at_top (𝓝 L.to_GH_space) :=
    tendsto.comp (to_GH_space_continuous.tendsto _) hL
  -- By construction, the image of `X3 n` in the Gromov-Hausdorff space is `u n`.
  have : ∀ n, (X3 n).toGHSpace = u n := by
    intro n
    rw [nonempty_compacts.to_GH_space, ← (u n).toGHSpace_rep,
      to_GH_space_eq_to_GH_space_iff_isometry_equiv]
    constructor
    convert (isom n).isometryEquivOnRange.symm
  -- Finally, we have proved the convergence of `u n`
  exact ⟨L.to_GH_space, by simpa only [this] using M⟩

end Complete

--section
end GromovHausdorff

--namespace
