/-
Copyright (c) 2015, 2017 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Robert Y. Lewis, Johannes Hölzl, Mario Carneiro, Sébastien Gouëzel

! This file was ported from Lean 3 source module topology.metric_space.emetric_space
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Interval
import Mathbin.Data.Real.Ennreal
import Mathbin.Topology.UniformSpace.Pi
import Mathbin.Topology.UniformSpace.UniformConvergence
import Mathbin.Topology.UniformSpace.UniformEmbedding

/-!
# Extended metric spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file is devoted to the definition and study of `emetric_spaces`, i.e., metric
spaces in which the distance is allowed to take the value ∞. This extended distance is
called `edist`, and takes values in `ℝ≥0∞`.

Many definitions and theorems expected on emetric spaces are already introduced on uniform spaces
and topological spaces. For example: open and closed sets, compactness, completeness, continuity and
uniform continuity.

The class `emetric_space` therefore extends `uniform_space` (and `topological_space`).

Since a lot of elementary properties don't require `eq_of_edist_eq_zero` we start setting up the
theory of `pseudo_emetric_space`, where we don't require `edist x y = 0 → x = y` and we specialize
to `emetric_space` at the end.
-/


open Set Filter Classical

open scoped uniformity Topology BigOperators Filter NNReal ENNReal

universe u v w

variable {α : Type u} {β : Type v} {X : Type _}

#print uniformity_dist_of_mem_uniformity /-
/-- Characterizing uniformities associated to a (generalized) distance function `D`
in terms of the elements of the uniformity. -/
theorem uniformity_dist_of_mem_uniformity [LinearOrder β] {U : Filter (α × α)} (z : β)
    (D : α → α → β) (H : ∀ s, s ∈ U ↔ ∃ ε > z, ∀ {a b : α}, D a b < ε → (a, b) ∈ s) :
    U = ⨅ ε > z, 𝓟 {p : α × α | D p.1 p.2 < ε} :=
  HasBasis.eq_biInf ⟨fun s => by simp only [H, subset_def, Prod.forall, mem_set_of]⟩
#align uniformity_dist_of_mem_uniformity uniformity_dist_of_mem_uniformity
-/

#print EDist /-
/-- `has_edist α` means that `α` is equipped with an extended distance. -/
class EDist (α : Type _) where
  edist : α → α → ℝ≥0∞
#align has_edist EDist
-/

export EDist (edist)

#print uniformSpaceOfEDist /-
/-- Creating a uniform space from an extended distance. -/
noncomputable def uniformSpaceOfEDist (edist : α → α → ℝ≥0∞) (edist_self : ∀ x : α, edist x x = 0)
    (edist_comm : ∀ x y : α, edist x y = edist y x)
    (edist_triangle : ∀ x y z : α, edist x z ≤ edist x y + edist y z) : UniformSpace α :=
  UniformSpace.ofFun edist edist_self edist_comm edist_triangle fun ε ε0 =>
    ⟨ε / 2, ENNReal.half_pos ε0.lt.ne', fun _ h₁ _ h₂ =>
      (ENNReal.add_lt_add h₁ h₂).trans_eq (ENNReal.add_halves _)⟩
#align uniform_space_of_edist uniformSpaceOfEDist
-/

#print PseudoEMetricSpace /-
-- the uniform structure is embedded in the emetric space structure
-- to avoid instance diamond issues. See Note [forgetful inheritance].
/-- Extended (pseudo) metric spaces, with an extended distance `edist` possibly taking the
value ∞

Each pseudo_emetric space induces a canonical `uniform_space` and hence a canonical
`topological_space`.
This is enforced in the type class definition, by extending the `uniform_space` structure. When
instantiating a `pseudo_emetric_space` structure, the uniformity fields are not necessary, they
will be filled in by default. There is a default value for the uniformity, that can be substituted
in cases of interest, for instance when instantiating a `pseudo_emetric_space` structure
on a product.

Continuity of `edist` is proved in `topology.instances.ennreal`
-/
class PseudoEMetricSpace (α : Type u) extends EDist α : Type u where
  edist_self : ∀ x : α, edist x x = 0
  edist_comm : ∀ x y : α, edist x y = edist y x
  edist_triangle : ∀ x y z : α, edist x z ≤ edist x y + edist y z
  toUniformSpace : UniformSpace α := uniformSpaceOfEDist edist edist_self edist_comm edist_triangle
  uniformity_edist : 𝓤 α = ⨅ ε > 0, 𝓟 {p : α × α | edist p.1 p.2 < ε} := by intros; rfl
#align pseudo_emetric_space PseudoEMetricSpace
-/

attribute [instance] PseudoEMetricSpace.toUniformSpace

/- Pseudoemetric spaces are less common than metric spaces. Therefore, we work in a dedicated
namespace, while notions associated to metric spaces are mostly in the root namespace. -/
variable [PseudoEMetricSpace α]

export PseudoEMetricSpace (edist_self edist_comm edist_triangle)

attribute [simp] edist_self

#print edist_triangle_left /-
/-- Triangle inequality for the extended distance -/
theorem edist_triangle_left (x y z : α) : edist x y ≤ edist z x + edist z y := by
  rw [edist_comm z] <;> apply edist_triangle
#align edist_triangle_left edist_triangle_left
-/

#print edist_triangle_right /-
theorem edist_triangle_right (x y z : α) : edist x y ≤ edist x z + edist y z := by
  rw [edist_comm y] <;> apply edist_triangle
#align edist_triangle_right edist_triangle_right
-/

#print edist_congr_right /-
theorem edist_congr_right {x y z : α} (h : edist x y = 0) : edist x z = edist y z :=
  by
  apply le_antisymm
  · rw [← zero_add (edist y z), ← h]
    apply edist_triangle
  · rw [edist_comm] at h 
    rw [← zero_add (edist x z), ← h]
    apply edist_triangle
#align edist_congr_right edist_congr_right
-/

#print edist_congr_left /-
theorem edist_congr_left {x y z : α} (h : edist x y = 0) : edist z x = edist z y := by
  rw [edist_comm z x, edist_comm z y]; apply edist_congr_right h
#align edist_congr_left edist_congr_left
-/

#print edist_triangle4 /-
theorem edist_triangle4 (x y z t : α) : edist x t ≤ edist x y + edist y z + edist z t :=
  calc
    edist x t ≤ edist x z + edist z t := edist_triangle x z t
    _ ≤ edist x y + edist y z + edist z t := add_le_add_right (edist_triangle x y z) _
#align edist_triangle4 edist_triangle4
-/

#print edist_le_Ico_sum_edist /-
/-- The triangle (polygon) inequality for sequences of points; `finset.Ico` version. -/
theorem edist_le_Ico_sum_edist (f : ℕ → α) {m n} (h : m ≤ n) :
    edist (f m) (f n) ≤ ∑ i in Finset.Ico m n, edist (f i) (f (i + 1)) :=
  by
  revert n
  refine' Nat.le_induction _ _
  · simp only [Finset.sum_empty, Finset.Ico_self, edist_self]
    -- TODO: Why doesn't Lean close this goal automatically? `exact le_rfl` fails too.
    exact le_refl (0 : ℝ≥0∞)
  · intro n hn hrec
    calc
      edist (f m) (f (n + 1)) ≤ edist (f m) (f n) + edist (f n) (f (n + 1)) := edist_triangle _ _ _
      _ ≤ ∑ i in Finset.Ico m n, _ + _ := (add_le_add hrec le_rfl)
      _ = ∑ i in Finset.Ico m (n + 1), _ := by
        rw [Nat.Ico_succ_right_eq_insert_Ico hn, Finset.sum_insert, add_comm] <;> simp
#align edist_le_Ico_sum_edist edist_le_Ico_sum_edist
-/

#print edist_le_range_sum_edist /-
/-- The triangle (polygon) inequality for sequences of points; `finset.range` version. -/
theorem edist_le_range_sum_edist (f : ℕ → α) (n : ℕ) :
    edist (f 0) (f n) ≤ ∑ i in Finset.range n, edist (f i) (f (i + 1)) :=
  Nat.Ico_zero_eq_range ▸ edist_le_Ico_sum_edist f (Nat.zero_le n)
#align edist_le_range_sum_edist edist_le_range_sum_edist
-/

#print edist_le_Ico_sum_of_edist_le /-
/-- A version of `edist_le_Ico_sum_edist` with each intermediate distance replaced
with an upper estimate. -/
theorem edist_le_Ico_sum_of_edist_le {f : ℕ → α} {m n} (hmn : m ≤ n) {d : ℕ → ℝ≥0∞}
    (hd : ∀ {k}, m ≤ k → k < n → edist (f k) (f (k + 1)) ≤ d k) :
    edist (f m) (f n) ≤ ∑ i in Finset.Ico m n, d i :=
  le_trans (edist_le_Ico_sum_edist f hmn) <|
    Finset.sum_le_sum fun k hk => hd (Finset.mem_Ico.1 hk).1 (Finset.mem_Ico.1 hk).2
#align edist_le_Ico_sum_of_edist_le edist_le_Ico_sum_of_edist_le
-/

#print edist_le_range_sum_of_edist_le /-
/-- A version of `edist_le_range_sum_edist` with each intermediate distance replaced
with an upper estimate. -/
theorem edist_le_range_sum_of_edist_le {f : ℕ → α} (n : ℕ) {d : ℕ → ℝ≥0∞}
    (hd : ∀ {k}, k < n → edist (f k) (f (k + 1)) ≤ d k) :
    edist (f 0) (f n) ≤ ∑ i in Finset.range n, d i :=
  Nat.Ico_zero_eq_range ▸ edist_le_Ico_sum_of_edist_le (zero_le n) fun _ _ => hd
#align edist_le_range_sum_of_edist_le edist_le_range_sum_of_edist_le
-/

#print uniformity_pseudoedist /-
/-- Reformulation of the uniform structure in terms of the extended distance -/
theorem uniformity_pseudoedist : 𝓤 α = ⨅ ε > 0, 𝓟 {p : α × α | edist p.1 p.2 < ε} :=
  PseudoEMetricSpace.uniformity_edist
#align uniformity_pseudoedist uniformity_pseudoedist
-/

#print uniformSpace_edist /-
theorem uniformSpace_edist :
    ‹PseudoEMetricSpace α›.toUniformSpace =
      uniformSpaceOfEDist edist edist_self edist_comm edist_triangle :=
  uniformSpace_eq uniformity_pseudoedist
#align uniform_space_edist uniformSpace_edist
-/

#print uniformity_basis_edist /-
theorem uniformity_basis_edist :
    (𝓤 α).HasBasis (fun ε : ℝ≥0∞ => 0 < ε) fun ε => {p : α × α | edist p.1 p.2 < ε} :=
  (@uniformSpace_edist α _).symm ▸ UniformSpace.hasBasis_ofFun ⟨1, one_pos⟩ _ _ _ _ _
#align uniformity_basis_edist uniformity_basis_edist
-/

#print mem_uniformity_edist /-
/-- Characterization of the elements of the uniformity in terms of the extended distance -/
theorem mem_uniformity_edist {s : Set (α × α)} :
    s ∈ 𝓤 α ↔ ∃ ε > 0, ∀ {a b : α}, edist a b < ε → (a, b) ∈ s :=
  uniformity_basis_edist.mem_uniformity_iff
#align mem_uniformity_edist mem_uniformity_edist
-/

#print EMetric.mk_uniformity_basis /-
/-- Given `f : β → ℝ≥0∞`, if `f` sends `{i | p i}` to a set of positive numbers
accumulating to zero, then `f i`-neighborhoods of the diagonal form a basis of `𝓤 α`.

For specific bases see `uniformity_basis_edist`, `uniformity_basis_edist'`,
`uniformity_basis_edist_nnreal`, and `uniformity_basis_edist_inv_nat`. -/
protected theorem EMetric.mk_uniformity_basis {β : Type _} {p : β → Prop} {f : β → ℝ≥0∞}
    (hf₀ : ∀ x, p x → 0 < f x) (hf : ∀ ε, 0 < ε → ∃ (x : _) (hx : p x), f x ≤ ε) :
    (𝓤 α).HasBasis p fun x => {p : α × α | edist p.1 p.2 < f x} :=
  by
  refine' ⟨fun s => uniformity_basis_edist.mem_iff.trans _⟩
  constructor
  · rintro ⟨ε, ε₀, hε⟩
    rcases hf ε ε₀ with ⟨i, hi, H⟩
    exact ⟨i, hi, fun x hx => hε <| lt_of_lt_of_le hx H⟩
  · exact fun ⟨i, hi, H⟩ => ⟨f i, hf₀ i hi, H⟩
#align emetric.mk_uniformity_basis EMetric.mk_uniformity_basis
-/

#print EMetric.mk_uniformity_basis_le /-
/-- Given `f : β → ℝ≥0∞`, if `f` sends `{i | p i}` to a set of positive numbers
accumulating to zero, then closed `f i`-neighborhoods of the diagonal form a basis of `𝓤 α`.

For specific bases see `uniformity_basis_edist_le` and `uniformity_basis_edist_le'`. -/
protected theorem EMetric.mk_uniformity_basis_le {β : Type _} {p : β → Prop} {f : β → ℝ≥0∞}
    (hf₀ : ∀ x, p x → 0 < f x) (hf : ∀ ε, 0 < ε → ∃ (x : _) (hx : p x), f x ≤ ε) :
    (𝓤 α).HasBasis p fun x => {p : α × α | edist p.1 p.2 ≤ f x} :=
  by
  refine' ⟨fun s => uniformity_basis_edist.mem_iff.trans _⟩
  constructor
  · rintro ⟨ε, ε₀, hε⟩
    rcases exists_between ε₀ with ⟨ε', hε'⟩
    rcases hf ε' hε'.1 with ⟨i, hi, H⟩
    exact ⟨i, hi, fun x hx => hε <| lt_of_le_of_lt (le_trans hx H) hε'.2⟩
  · exact fun ⟨i, hi, H⟩ => ⟨f i, hf₀ i hi, fun x hx => H (le_of_lt hx)⟩
#align emetric.mk_uniformity_basis_le EMetric.mk_uniformity_basis_le
-/

#print uniformity_basis_edist_le /-
theorem uniformity_basis_edist_le :
    (𝓤 α).HasBasis (fun ε : ℝ≥0∞ => 0 < ε) fun ε => {p : α × α | edist p.1 p.2 ≤ ε} :=
  EMetric.mk_uniformity_basis_le (fun _ => id) fun ε ε₀ => ⟨ε, ε₀, le_refl ε⟩
#align uniformity_basis_edist_le uniformity_basis_edist_le
-/

#print uniformity_basis_edist' /-
theorem uniformity_basis_edist' (ε' : ℝ≥0∞) (hε' : 0 < ε') :
    (𝓤 α).HasBasis (fun ε : ℝ≥0∞ => ε ∈ Ioo 0 ε') fun ε => {p : α × α | edist p.1 p.2 < ε} :=
  EMetric.mk_uniformity_basis (fun _ => And.left) fun ε ε₀ =>
    let ⟨δ, hδ⟩ := exists_between hε'
    ⟨min ε δ, ⟨lt_min ε₀ hδ.1, lt_of_le_of_lt (min_le_right _ _) hδ.2⟩, min_le_left _ _⟩
#align uniformity_basis_edist' uniformity_basis_edist'
-/

#print uniformity_basis_edist_le' /-
theorem uniformity_basis_edist_le' (ε' : ℝ≥0∞) (hε' : 0 < ε') :
    (𝓤 α).HasBasis (fun ε : ℝ≥0∞ => ε ∈ Ioo 0 ε') fun ε => {p : α × α | edist p.1 p.2 ≤ ε} :=
  EMetric.mk_uniformity_basis_le (fun _ => And.left) fun ε ε₀ =>
    let ⟨δ, hδ⟩ := exists_between hε'
    ⟨min ε δ, ⟨lt_min ε₀ hδ.1, lt_of_le_of_lt (min_le_right _ _) hδ.2⟩, min_le_left _ _⟩
#align uniformity_basis_edist_le' uniformity_basis_edist_le'
-/

#print uniformity_basis_edist_nnreal /-
theorem uniformity_basis_edist_nnreal :
    (𝓤 α).HasBasis (fun ε : ℝ≥0 => 0 < ε) fun ε => {p : α × α | edist p.1 p.2 < ε} :=
  EMetric.mk_uniformity_basis (fun _ => ENNReal.coe_pos.2) fun ε ε₀ =>
    let ⟨δ, hδ⟩ := ENNReal.lt_iff_exists_nnreal_btwn.1 ε₀
    ⟨δ, ENNReal.coe_pos.1 hδ.1, le_of_lt hδ.2⟩
#align uniformity_basis_edist_nnreal uniformity_basis_edist_nnreal
-/

#print uniformity_basis_edist_nnreal_le /-
theorem uniformity_basis_edist_nnreal_le :
    (𝓤 α).HasBasis (fun ε : ℝ≥0 => 0 < ε) fun ε => {p : α × α | edist p.1 p.2 ≤ ε} :=
  EMetric.mk_uniformity_basis_le (fun _ => ENNReal.coe_pos.2) fun ε ε₀ =>
    let ⟨δ, hδ⟩ := ENNReal.lt_iff_exists_nnreal_btwn.1 ε₀
    ⟨δ, ENNReal.coe_pos.1 hδ.1, le_of_lt hδ.2⟩
#align uniformity_basis_edist_nnreal_le uniformity_basis_edist_nnreal_le
-/

#print uniformity_basis_edist_inv_nat /-
theorem uniformity_basis_edist_inv_nat :
    (𝓤 α).HasBasis (fun _ => True) fun n : ℕ => {p : α × α | edist p.1 p.2 < (↑n)⁻¹} :=
  EMetric.mk_uniformity_basis (fun n _ => ENNReal.inv_pos.2 <| ENNReal.nat_ne_top n) fun ε ε₀ =>
    let ⟨n, hn⟩ := ENNReal.exists_inv_nat_lt (ne_of_gt ε₀)
    ⟨n, trivial, le_of_lt hn⟩
#align uniformity_basis_edist_inv_nat uniformity_basis_edist_inv_nat
-/

#print uniformity_basis_edist_inv_two_pow /-
theorem uniformity_basis_edist_inv_two_pow :
    (𝓤 α).HasBasis (fun _ => True) fun n : ℕ => {p : α × α | edist p.1 p.2 < 2⁻¹ ^ n} :=
  EMetric.mk_uniformity_basis (fun n _ => ENNReal.pow_pos (ENNReal.inv_pos.2 ENNReal.two_ne_top) _)
    fun ε ε₀ =>
    let ⟨n, hn⟩ := ENNReal.exists_inv_two_pow_lt (ne_of_gt ε₀)
    ⟨n, trivial, le_of_lt hn⟩
#align uniformity_basis_edist_inv_two_pow uniformity_basis_edist_inv_two_pow
-/

#print edist_mem_uniformity /-
/-- Fixed size neighborhoods of the diagonal belong to the uniform structure -/
theorem edist_mem_uniformity {ε : ℝ≥0∞} (ε0 : 0 < ε) : {p : α × α | edist p.1 p.2 < ε} ∈ 𝓤 α :=
  mem_uniformity_edist.2 ⟨ε, ε0, fun a b => id⟩
#align edist_mem_uniformity edist_mem_uniformity
-/

namespace Emetric

instance (priority := 900) : IsCountablyGenerated (𝓤 α) :=
  isCountablyGenerated_of_seq ⟨_, uniformity_basis_edist_inv_nat.eq_iInf⟩

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection {a b «expr ∈ » s} -/
#print EMetric.uniformContinuousOn_iff /-
/-- ε-δ characterization of uniform continuity on a set for pseudoemetric spaces -/
theorem uniformContinuousOn_iff [PseudoEMetricSpace β] {f : α → β} {s : Set α} :
    UniformContinuousOn f s ↔
      ∀ ε > 0, ∃ δ > 0, ∀ {a} {_ : a ∈ s} {b} {_ : b ∈ s}, edist a b < δ → edist (f a) (f b) < ε :=
  uniformity_basis_edist.uniformContinuousOn_iff uniformity_basis_edist
#align emetric.uniform_continuous_on_iff EMetric.uniformContinuousOn_iff
-/

#print EMetric.uniformContinuous_iff /-
/-- ε-δ characterization of uniform continuity on pseudoemetric spaces -/
theorem uniformContinuous_iff [PseudoEMetricSpace β] {f : α → β} :
    UniformContinuous f ↔ ∀ ε > 0, ∃ δ > 0, ∀ {a b : α}, edist a b < δ → edist (f a) (f b) < ε :=
  uniformity_basis_edist.uniformContinuous_iff uniformity_basis_edist
#align emetric.uniform_continuous_iff EMetric.uniformContinuous_iff
-/

#print EMetric.uniformEmbedding_iff /-
/-- ε-δ characterization of uniform embeddings on pseudoemetric spaces -/
theorem uniformEmbedding_iff [PseudoEMetricSpace β] {f : α → β} :
    UniformEmbedding f ↔
      Function.Injective f ∧
        UniformContinuous f ∧
          ∀ δ > 0, ∃ ε > 0, ∀ {a b : α}, edist (f a) (f b) < ε → edist a b < δ :=
  by
  simp only [uniformity_basis_edist.uniform_embedding_iff uniformity_basis_edist, exists_prop]
  rfl
#align emetric.uniform_embedding_iff EMetric.uniformEmbedding_iff
-/

#print EMetric.controlled_of_uniformEmbedding /-
/-- If a map between pseudoemetric spaces is a uniform embedding then the edistance between `f x`
and `f y` is controlled in terms of the distance between `x` and `y`. -/
theorem controlled_of_uniformEmbedding [PseudoEMetricSpace β] {f : α → β} :
    UniformEmbedding f →
      (∀ ε > 0, ∃ δ > 0, ∀ {a b : α}, edist a b < δ → edist (f a) (f b) < ε) ∧
        ∀ δ > 0, ∃ ε > 0, ∀ {a b : α}, edist (f a) (f b) < ε → edist a b < δ :=
  fun h => ⟨uniformContinuous_iff.1 (uniformEmbedding_iff.1 h).2.1, (uniformEmbedding_iff.1 h).2.2⟩
#align emetric.controlled_of_uniform_embedding EMetric.controlled_of_uniformEmbedding
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x y «expr ∈ » t) -/
#print EMetric.cauchy_iff /-
/-- ε-δ characterization of Cauchy sequences on pseudoemetric spaces -/
protected theorem cauchy_iff {f : Filter α} :
    Cauchy f ↔ f ≠ ⊥ ∧ ∀ ε > 0, ∃ t ∈ f, ∀ (x) (_ : x ∈ t) (y) (_ : y ∈ t), edist x y < ε := by
  rw [← ne_bot_iff] <;> exact uniformity_basis_edist.cauchy_iff
#align emetric.cauchy_iff EMetric.cauchy_iff
-/

#print EMetric.complete_of_convergent_controlled_sequences /-
/-- A very useful criterion to show that a space is complete is to show that all sequences
which satisfy a bound of the form `edist (u n) (u m) < B N` for all `n m ≥ N` are
converging. This is often applied for `B N = 2^{-N}`, i.e., with a very fast convergence to
`0`, which makes it possible to use arguments of converging series, while this is impossible
to do in general for arbitrary Cauchy sequences. -/
theorem complete_of_convergent_controlled_sequences (B : ℕ → ℝ≥0∞) (hB : ∀ n, 0 < B n)
    (H :
      ∀ u : ℕ → α,
        (∀ N n m : ℕ, N ≤ n → N ≤ m → edist (u n) (u m) < B N) → ∃ x, Tendsto u atTop (𝓝 x)) :
    CompleteSpace α :=
  UniformSpace.complete_of_convergent_controlled_sequences
    (fun n => {p : α × α | edist p.1 p.2 < B n}) (fun n => edist_mem_uniformity <| hB n) H
#align emetric.complete_of_convergent_controlled_sequences EMetric.complete_of_convergent_controlled_sequences
-/

#print EMetric.complete_of_cauchySeq_tendsto /-
/-- A sequentially complete pseudoemetric space is complete. -/
theorem complete_of_cauchySeq_tendsto :
    (∀ u : ℕ → α, CauchySeq u → ∃ a, Tendsto u atTop (𝓝 a)) → CompleteSpace α :=
  UniformSpace.complete_of_cauchySeq_tendsto
#align emetric.complete_of_cauchy_seq_tendsto EMetric.complete_of_cauchySeq_tendsto
-/

#print EMetric.tendstoLocallyUniformlyOn_iff /-
/-- Expressing locally uniform convergence on a set using `edist`. -/
theorem tendstoLocallyUniformlyOn_iff {ι : Type _} [TopologicalSpace β] {F : ι → β → α} {f : β → α}
    {p : Filter ι} {s : Set β} :
    TendstoLocallyUniformlyOn F f p s ↔
      ∀ ε > 0, ∀ x ∈ s, ∃ t ∈ 𝓝[s] x, ∀ᶠ n in p, ∀ y ∈ t, edist (f y) (F n y) < ε :=
  by
  refine' ⟨fun H ε hε => H _ (edist_mem_uniformity hε), fun H u hu x hx => _⟩
  rcases mem_uniformity_edist.1 hu with ⟨ε, εpos, hε⟩
  rcases H ε εpos x hx with ⟨t, ht, Ht⟩
  exact ⟨t, ht, Ht.mono fun n hs x hx => hε (hs x hx)⟩
#align emetric.tendsto_locally_uniformly_on_iff EMetric.tendstoLocallyUniformlyOn_iff
-/

#print EMetric.tendstoUniformlyOn_iff /-
/-- Expressing uniform convergence on a set using `edist`. -/
theorem tendstoUniformlyOn_iff {ι : Type _} {F : ι → β → α} {f : β → α} {p : Filter ι} {s : Set β} :
    TendstoUniformlyOn F f p s ↔ ∀ ε > 0, ∀ᶠ n in p, ∀ x ∈ s, edist (f x) (F n x) < ε :=
  by
  refine' ⟨fun H ε hε => H _ (edist_mem_uniformity hε), fun H u hu => _⟩
  rcases mem_uniformity_edist.1 hu with ⟨ε, εpos, hε⟩
  exact (H ε εpos).mono fun n hs x hx => hε (hs x hx)
#align emetric.tendsto_uniformly_on_iff EMetric.tendstoUniformlyOn_iff
-/

#print EMetric.tendstoLocallyUniformly_iff /-
/-- Expressing locally uniform convergence using `edist`. -/
theorem tendstoLocallyUniformly_iff {ι : Type _} [TopologicalSpace β] {F : ι → β → α} {f : β → α}
    {p : Filter ι} :
    TendstoLocallyUniformly F f p ↔
      ∀ ε > 0, ∀ x : β, ∃ t ∈ 𝓝 x, ∀ᶠ n in p, ∀ y ∈ t, edist (f y) (F n y) < ε :=
  by
  simp only [← tendstoLocallyUniformlyOn_univ, tendsto_locally_uniformly_on_iff, mem_univ,
    forall_const, exists_prop, nhdsWithin_univ]
#align emetric.tendsto_locally_uniformly_iff EMetric.tendstoLocallyUniformly_iff
-/

#print EMetric.tendstoUniformly_iff /-
/-- Expressing uniform convergence using `edist`. -/
theorem tendstoUniformly_iff {ι : Type _} {F : ι → β → α} {f : β → α} {p : Filter ι} :
    TendstoUniformly F f p ↔ ∀ ε > 0, ∀ᶠ n in p, ∀ x, edist (f x) (F n x) < ε := by
  simp only [← tendstoUniformlyOn_univ, tendsto_uniformly_on_iff, mem_univ, forall_const]
#align emetric.tendsto_uniformly_iff EMetric.tendstoUniformly_iff
-/

end Emetric

open Emetric

#print PseudoEMetricSpace.replaceUniformity /-
/-- Auxiliary function to replace the uniformity on a pseudoemetric space with
a uniformity which is equal to the original one, but maybe not defeq.
This is useful if one wants to construct a pseudoemetric space with a
specified uniformity. See Note [forgetful inheritance] explaining why having definitionally
the right uniformity is often important.
-/
def PseudoEMetricSpace.replaceUniformity {α} [U : UniformSpace α] (m : PseudoEMetricSpace α)
    (H : 𝓤[U] = 𝓤[PseudoEMetricSpace.toUniformSpace]) : PseudoEMetricSpace α
    where
  edist := @edist _ m.toHasEdist
  edist_self := edist_self
  edist_comm := edist_comm
  edist_triangle := edist_triangle
  toUniformSpace := U
  uniformity_edist := H.trans (@PseudoEMetricSpace.uniformity_edist α _)
#align pseudo_emetric_space.replace_uniformity PseudoEMetricSpace.replaceUniformity
-/

#print PseudoEMetricSpace.induced /-
/-- The extended pseudometric induced by a function taking values in a pseudoemetric space. -/
def PseudoEMetricSpace.induced {α β} (f : α → β) (m : PseudoEMetricSpace β) : PseudoEMetricSpace α
    where
  edist x y := edist (f x) (f y)
  edist_self x := edist_self _
  edist_comm x y := edist_comm _ _
  edist_triangle x y z := edist_triangle _ _ _
  toUniformSpace := UniformSpace.comap f m.toUniformSpace
  uniformity_edist := (uniformity_basis_edist.comap _).eq_biInf
#align pseudo_emetric_space.induced PseudoEMetricSpace.induced
-/

/-- Pseudoemetric space instance on subsets of pseudoemetric spaces -/
instance {α : Type _} {p : α → Prop} [PseudoEMetricSpace α] : PseudoEMetricSpace (Subtype p) :=
  PseudoEMetricSpace.induced coe ‹_›

#print Subtype.edist_eq /-
/-- The extended psuedodistance on a subset of a pseudoemetric space is the restriction of
the original pseudodistance, by definition -/
theorem Subtype.edist_eq {p : α → Prop} (x y : Subtype p) : edist x y = edist (x : α) y :=
  rfl
#align subtype.edist_eq Subtype.edist_eq
-/

namespace MulOpposite

/-- Pseudoemetric space instance on the multiplicative opposite of a pseudoemetric space. -/
@[to_additive "Pseudoemetric space instance on the additive opposite of a pseudoemetric space."]
instance {α : Type _} [PseudoEMetricSpace α] : PseudoEMetricSpace αᵐᵒᵖ :=
  PseudoEMetricSpace.induced unop ‹_›

#print MulOpposite.edist_unop /-
@[to_additive]
theorem edist_unop (x y : αᵐᵒᵖ) : edist (unop x) (unop y) = edist x y :=
  rfl
#align mul_opposite.edist_unop MulOpposite.edist_unop
#align add_opposite.edist_unop AddOpposite.edist_unop
-/

#print MulOpposite.edist_op /-
@[to_additive]
theorem edist_op (x y : α) : edist (op x) (op y) = edist x y :=
  rfl
#align mul_opposite.edist_op MulOpposite.edist_op
#align add_opposite.edist_op AddOpposite.edist_op
-/

end MulOpposite

section ULift

instance : PseudoEMetricSpace (ULift α) :=
  PseudoEMetricSpace.induced ULift.down ‹_›

#print ULift.edist_eq /-
theorem ULift.edist_eq (x y : ULift α) : edist x y = edist x.down y.down :=
  rfl
#align ulift.edist_eq ULift.edist_eq
-/

#print ULift.edist_up_up /-
@[simp]
theorem ULift.edist_up_up (x y : α) : edist (ULift.up x) (ULift.up y) = edist x y :=
  rfl
#align ulift.edist_up_up ULift.edist_up_up
-/

end ULift

#print Prod.pseudoEMetricSpaceMax /-
/-- The product of two pseudoemetric spaces, with the max distance, is an extended
pseudometric spaces. We make sure that the uniform structure thus constructed is the one
corresponding to the product of uniform spaces, to avoid diamond problems. -/
instance Prod.pseudoEMetricSpaceMax [PseudoEMetricSpace β] : PseudoEMetricSpace (α × β)
    where
  edist x y := edist x.1 y.1 ⊔ edist x.2 y.2
  edist_self x := by simp
  edist_comm x y := by simp [edist_comm]
  edist_triangle x y z :=
    max_le (le_trans (edist_triangle _ _ _) (add_le_add (le_max_left _ _) (le_max_left _ _)))
      (le_trans (edist_triangle _ _ _) (add_le_add (le_max_right _ _) (le_max_right _ _)))
  uniformity_edist := by
    refine' uniformity_prod.trans _
    simp only [PseudoEMetricSpace.uniformity_edist, comap_infi]
    rw [← iInf_inf_eq]; congr; funext
    rw [← iInf_inf_eq]; congr; funext
    simp [inf_principal, ext_iff, max_lt_iff]
  toUniformSpace := Prod.uniformSpace
#align prod.pseudo_emetric_space_max Prod.pseudoEMetricSpaceMax
-/

#print Prod.edist_eq /-
theorem Prod.edist_eq [PseudoEMetricSpace β] (x y : α × β) :
    edist x y = max (edist x.1 y.1) (edist x.2 y.2) :=
  rfl
#align prod.edist_eq Prod.edist_eq
-/

section Pi

open Finset

variable {π : β → Type _} [Fintype β]

#print pseudoEMetricSpacePi /-
/-- The product of a finite number of pseudoemetric spaces, with the max distance, is still
a pseudoemetric space.
This construction would also work for infinite products, but it would not give rise
to the product topology. Hence, we only formalize it in the good situation of finitely many
spaces. -/
instance pseudoEMetricSpacePi [∀ b, PseudoEMetricSpace (π b)] : PseudoEMetricSpace (∀ b, π b)
    where
  edist f g := Finset.sup univ fun b => edist (f b) (g b)
  edist_self f := bot_unique <| Finset.sup_le <| by simp
  edist_comm f g := by unfold edist <;> congr <;> funext a <;> exact edist_comm _ _
  edist_triangle f g h := by
    simp only [Finset.sup_le_iff]
    intro b hb
    exact le_trans (edist_triangle _ (g b) _) (add_le_add (le_sup hb) (le_sup hb))
  toUniformSpace := Pi.uniformSpace _
  uniformity_edist :=
    by
    simp only [Pi.uniformity, PseudoEMetricSpace.uniformity_edist, comap_infi, gt_iff_lt,
      preimage_set_of_eq, comap_principal]
    rw [iInf_comm]; congr; funext ε
    rw [iInf_comm]; congr; funext εpos
    change 0 < ε at εpos 
    simp [Set.ext_iff, εpos]
#align pseudo_emetric_space_pi pseudoEMetricSpacePi
-/

#print edist_pi_def /-
theorem edist_pi_def [∀ b, PseudoEMetricSpace (π b)] (f g : ∀ b, π b) :
    edist f g = Finset.sup univ fun b => edist (f b) (g b) :=
  rfl
#align edist_pi_def edist_pi_def
-/

#print edist_le_pi_edist /-
theorem edist_le_pi_edist [∀ b, PseudoEMetricSpace (π b)] (f g : ∀ b, π b) (b : β) :
    edist (f b) (g b) ≤ edist f g :=
  Finset.le_sup (Finset.mem_univ b)
#align edist_le_pi_edist edist_le_pi_edist
-/

#print edist_pi_le_iff /-
theorem edist_pi_le_iff [∀ b, PseudoEMetricSpace (π b)] {f g : ∀ b, π b} {d : ℝ≥0∞} :
    edist f g ≤ d ↔ ∀ b, edist (f b) (g b) ≤ d :=
  Finset.sup_le_iff.trans <| by simp only [Finset.mem_univ, forall_const]
#align edist_pi_le_iff edist_pi_le_iff
-/

#print edist_pi_const_le /-
theorem edist_pi_const_le (a b : α) : (edist (fun _ : β => a) fun _ => b) ≤ edist a b :=
  edist_pi_le_iff.2 fun _ => le_rfl
#align edist_pi_const_le edist_pi_const_le
-/

#print edist_pi_const /-
@[simp]
theorem edist_pi_const [Nonempty β] (a b : α) : (edist (fun x : β => a) fun _ => b) = edist a b :=
  Finset.sup_const univ_nonempty (edist a b)
#align edist_pi_const edist_pi_const
-/

end Pi

namespace Emetric

variable {x y z : α} {ε ε₁ ε₂ : ℝ≥0∞} {s t : Set α}

#print EMetric.ball /-
/-- `emetric.ball x ε` is the set of all points `y` with `edist y x < ε` -/
def ball (x : α) (ε : ℝ≥0∞) : Set α :=
  {y | edist y x < ε}
#align emetric.ball EMetric.ball
-/

#print EMetric.mem_ball /-
@[simp]
theorem mem_ball : y ∈ ball x ε ↔ edist y x < ε :=
  Iff.rfl
#align emetric.mem_ball EMetric.mem_ball
-/

#print EMetric.mem_ball' /-
theorem mem_ball' : y ∈ ball x ε ↔ edist x y < ε := by rw [edist_comm, mem_ball]
#align emetric.mem_ball' EMetric.mem_ball'
-/

#print EMetric.closedBall /-
/-- `emetric.closed_ball x ε` is the set of all points `y` with `edist y x ≤ ε` -/
def closedBall (x : α) (ε : ℝ≥0∞) :=
  {y | edist y x ≤ ε}
#align emetric.closed_ball EMetric.closedBall
-/

#print EMetric.mem_closedBall /-
@[simp]
theorem mem_closedBall : y ∈ closedBall x ε ↔ edist y x ≤ ε :=
  Iff.rfl
#align emetric.mem_closed_ball EMetric.mem_closedBall
-/

#print EMetric.mem_closedBall' /-
theorem mem_closedBall' : y ∈ closedBall x ε ↔ edist x y ≤ ε := by rw [edist_comm, mem_closed_ball]
#align emetric.mem_closed_ball' EMetric.mem_closedBall'
-/

#print EMetric.closedBall_top /-
@[simp]
theorem closedBall_top (x : α) : closedBall x ∞ = univ :=
  eq_univ_of_forall fun y => le_top
#align emetric.closed_ball_top EMetric.closedBall_top
-/

#print EMetric.ball_subset_closedBall /-
theorem ball_subset_closedBall : ball x ε ⊆ closedBall x ε := fun y hy => le_of_lt hy
#align emetric.ball_subset_closed_ball EMetric.ball_subset_closedBall
-/

#print EMetric.pos_of_mem_ball /-
theorem pos_of_mem_ball (hy : y ∈ ball x ε) : 0 < ε :=
  lt_of_le_of_lt (zero_le _) hy
#align emetric.pos_of_mem_ball EMetric.pos_of_mem_ball
-/

#print EMetric.mem_ball_self /-
theorem mem_ball_self (h : 0 < ε) : x ∈ ball x ε :=
  show edist x x < ε by rw [edist_self] <;> assumption
#align emetric.mem_ball_self EMetric.mem_ball_self
-/

#print EMetric.mem_closedBall_self /-
theorem mem_closedBall_self : x ∈ closedBall x ε :=
  show edist x x ≤ ε by rw [edist_self] <;> exact bot_le
#align emetric.mem_closed_ball_self EMetric.mem_closedBall_self
-/

#print EMetric.mem_ball_comm /-
theorem mem_ball_comm : x ∈ ball y ε ↔ y ∈ ball x ε := by rw [mem_ball', mem_ball]
#align emetric.mem_ball_comm EMetric.mem_ball_comm
-/

#print EMetric.mem_closedBall_comm /-
theorem mem_closedBall_comm : x ∈ closedBall y ε ↔ y ∈ closedBall x ε := by
  rw [mem_closed_ball', mem_closed_ball]
#align emetric.mem_closed_ball_comm EMetric.mem_closedBall_comm
-/

#print EMetric.ball_subset_ball /-
theorem ball_subset_ball (h : ε₁ ≤ ε₂) : ball x ε₁ ⊆ ball x ε₂ := fun y (yx : _ < ε₁) =>
  lt_of_lt_of_le yx h
#align emetric.ball_subset_ball EMetric.ball_subset_ball
-/

#print EMetric.closedBall_subset_closedBall /-
theorem closedBall_subset_closedBall (h : ε₁ ≤ ε₂) : closedBall x ε₁ ⊆ closedBall x ε₂ :=
  fun y (yx : _ ≤ ε₁) => le_trans yx h
#align emetric.closed_ball_subset_closed_ball EMetric.closedBall_subset_closedBall
-/

#print EMetric.ball_disjoint /-
theorem ball_disjoint (h : ε₁ + ε₂ ≤ edist x y) : Disjoint (ball x ε₁) (ball y ε₂) :=
  Set.disjoint_left.mpr fun z h₁ h₂ =>
    (edist_triangle_left x y z).not_lt <| (ENNReal.add_lt_add h₁ h₂).trans_le h
#align emetric.ball_disjoint EMetric.ball_disjoint
-/

#print EMetric.ball_subset /-
theorem ball_subset (h : edist x y + ε₁ ≤ ε₂) (h' : edist x y ≠ ∞) : ball x ε₁ ⊆ ball y ε₂ :=
  fun z zx =>
  calc
    edist z y ≤ edist z x + edist x y := edist_triangle _ _ _
    _ = edist x y + edist z x := (add_comm _ _)
    _ < edist x y + ε₁ := (ENNReal.add_lt_add_left h' zx)
    _ ≤ ε₂ := h
#align emetric.ball_subset EMetric.ball_subset
-/

#print EMetric.exists_ball_subset_ball /-
theorem exists_ball_subset_ball (h : y ∈ ball x ε) : ∃ ε' > 0, ball y ε' ⊆ ball x ε :=
  by
  have : 0 < ε - edist y x := by simpa using h
  refine' ⟨ε - edist y x, this, ball_subset _ (ne_top_of_lt h)⟩
  exact (add_tsub_cancel_of_le (mem_ball.mp h).le).le
#align emetric.exists_ball_subset_ball EMetric.exists_ball_subset_ball
-/

#print EMetric.ball_eq_empty_iff /-
theorem ball_eq_empty_iff : ball x ε = ∅ ↔ ε = 0 :=
  eq_empty_iff_forall_not_mem.trans
    ⟨fun h => le_bot_iff.1 (le_of_not_gt fun ε0 => h _ (mem_ball_self ε0)), fun ε0 y h =>
      not_lt_of_le (le_of_eq ε0) (pos_of_mem_ball h)⟩
#align emetric.ball_eq_empty_iff EMetric.ball_eq_empty_iff
-/

#print EMetric.ordConnected_setOf_closedBall_subset /-
theorem ordConnected_setOf_closedBall_subset (x : α) (s : Set α) :
    OrdConnected {r | closedBall x r ⊆ s} :=
  ⟨fun r₁ hr₁ r₂ hr₂ r hr => (closedBall_subset_closedBall hr.2).trans hr₂⟩
#align emetric.ord_connected_set_of_closed_ball_subset EMetric.ordConnected_setOf_closedBall_subset
-/

#print EMetric.ordConnected_setOf_ball_subset /-
theorem ordConnected_setOf_ball_subset (x : α) (s : Set α) : OrdConnected {r | ball x r ⊆ s} :=
  ⟨fun r₁ hr₁ r₂ hr₂ r hr => (ball_subset_ball hr.2).trans hr₂⟩
#align emetric.ord_connected_set_of_ball_subset EMetric.ordConnected_setOf_ball_subset
-/

#print EMetric.edistLtTopSetoid /-
/-- Relation “two points are at a finite edistance” is an equivalence relation. -/
def edistLtTopSetoid : Setoid α where
  R x y := edist x y < ⊤
  iseqv :=
    ⟨fun x => by rw [edist_self]; exact ENNReal.coe_lt_top, fun x y h => by rwa [edist_comm],
      fun x y z hxy hyz => lt_of_le_of_lt (edist_triangle x y z) (ENNReal.add_lt_top.2 ⟨hxy, hyz⟩)⟩
#align emetric.edist_lt_top_setoid EMetric.edistLtTopSetoid
-/

#print EMetric.ball_zero /-
@[simp]
theorem ball_zero : ball x 0 = ∅ := by rw [EMetric.ball_eq_empty_iff]
#align emetric.ball_zero EMetric.ball_zero
-/

#print EMetric.nhds_basis_eball /-
theorem nhds_basis_eball : (𝓝 x).HasBasis (fun ε : ℝ≥0∞ => 0 < ε) (ball x) :=
  nhds_basis_uniformity uniformity_basis_edist
#align emetric.nhds_basis_eball EMetric.nhds_basis_eball
-/

#print EMetric.nhdsWithin_basis_eball /-
theorem nhdsWithin_basis_eball : (𝓝[s] x).HasBasis (fun ε : ℝ≥0∞ => 0 < ε) fun ε => ball x ε ∩ s :=
  nhdsWithin_hasBasis nhds_basis_eball s
#align emetric.nhds_within_basis_eball EMetric.nhdsWithin_basis_eball
-/

#print EMetric.nhds_basis_closed_eball /-
theorem nhds_basis_closed_eball : (𝓝 x).HasBasis (fun ε : ℝ≥0∞ => 0 < ε) (closedBall x) :=
  nhds_basis_uniformity uniformity_basis_edist_le
#align emetric.nhds_basis_closed_eball EMetric.nhds_basis_closed_eball
-/

#print EMetric.nhdsWithin_basis_closed_eball /-
theorem nhdsWithin_basis_closed_eball :
    (𝓝[s] x).HasBasis (fun ε : ℝ≥0∞ => 0 < ε) fun ε => closedBall x ε ∩ s :=
  nhdsWithin_hasBasis nhds_basis_closed_eball s
#align emetric.nhds_within_basis_closed_eball EMetric.nhdsWithin_basis_closed_eball
-/

#print EMetric.nhds_eq /-
theorem nhds_eq : 𝓝 x = ⨅ ε > 0, 𝓟 (ball x ε) :=
  nhds_basis_eball.eq_biInf
#align emetric.nhds_eq EMetric.nhds_eq
-/

#print EMetric.mem_nhds_iff /-
theorem mem_nhds_iff : s ∈ 𝓝 x ↔ ∃ ε > 0, ball x ε ⊆ s :=
  nhds_basis_eball.mem_iff
#align emetric.mem_nhds_iff EMetric.mem_nhds_iff
-/

#print EMetric.mem_nhdsWithin_iff /-
theorem mem_nhdsWithin_iff : s ∈ 𝓝[t] x ↔ ∃ ε > 0, ball x ε ∩ t ⊆ s :=
  nhdsWithin_basis_eball.mem_iff
#align emetric.mem_nhds_within_iff EMetric.mem_nhdsWithin_iff
-/

section

variable [PseudoEMetricSpace β] {f : α → β}

#print EMetric.tendsto_nhdsWithin_nhdsWithin /-
theorem tendsto_nhdsWithin_nhdsWithin {t : Set β} {a b} :
    Tendsto f (𝓝[s] a) (𝓝[t] b) ↔
      ∀ ε > 0, ∃ δ > 0, ∀ ⦃x⦄, x ∈ s → edist x a < δ → f x ∈ t ∧ edist (f x) b < ε :=
  (nhdsWithin_basis_eball.tendsto_iffₓ nhdsWithin_basis_eball).trans <|
    forall₂_congr fun ε hε => exists₂_congr fun δ hδ => forall_congr' fun x => by simp <;> itauto
#align emetric.tendsto_nhds_within_nhds_within EMetric.tendsto_nhdsWithin_nhdsWithin
-/

#print EMetric.tendsto_nhdsWithin_nhds /-
theorem tendsto_nhdsWithin_nhds {a b} :
    Tendsto f (𝓝[s] a) (𝓝 b) ↔
      ∀ ε > 0, ∃ δ > 0, ∀ {x : α}, x ∈ s → edist x a < δ → edist (f x) b < ε :=
  by rw [← nhdsWithin_univ b, tendsto_nhds_within_nhds_within]; simp only [mem_univ, true_and_iff]
#align emetric.tendsto_nhds_within_nhds EMetric.tendsto_nhdsWithin_nhds
-/

#print EMetric.tendsto_nhds_nhds /-
theorem tendsto_nhds_nhds {a b} :
    Tendsto f (𝓝 a) (𝓝 b) ↔ ∀ ε > 0, ∃ δ > 0, ∀ ⦃x⦄, edist x a < δ → edist (f x) b < ε :=
  nhds_basis_eball.tendsto_iffₓ nhds_basis_eball
#align emetric.tendsto_nhds_nhds EMetric.tendsto_nhds_nhds
-/

end

#print EMetric.isOpen_iff /-
theorem isOpen_iff : IsOpen s ↔ ∀ x ∈ s, ∃ ε > 0, ball x ε ⊆ s := by
  simp [isOpen_iff_nhds, mem_nhds_iff]
#align emetric.is_open_iff EMetric.isOpen_iff
-/

#print EMetric.isOpen_ball /-
theorem isOpen_ball : IsOpen (ball x ε) :=
  isOpen_iff.2 fun y => exists_ball_subset_ball
#align emetric.is_open_ball EMetric.isOpen_ball
-/

#print EMetric.isClosed_ball_top /-
theorem isClosed_ball_top : IsClosed (ball x ⊤) :=
  isOpen_compl_iff.1 <|
    isOpen_iff.2 fun y hy =>
      ⟨⊤, ENNReal.coe_lt_top,
        (ball_disjoint <| by rw [top_add]; exact le_of_not_lt hy).subset_compl_right⟩
#align emetric.is_closed_ball_top EMetric.isClosed_ball_top
-/

#print EMetric.ball_mem_nhds /-
theorem ball_mem_nhds (x : α) {ε : ℝ≥0∞} (ε0 : 0 < ε) : ball x ε ∈ 𝓝 x :=
  isOpen_ball.mem_nhds (mem_ball_self ε0)
#align emetric.ball_mem_nhds EMetric.ball_mem_nhds
-/

#print EMetric.closedBall_mem_nhds /-
theorem closedBall_mem_nhds (x : α) {ε : ℝ≥0∞} (ε0 : 0 < ε) : closedBall x ε ∈ 𝓝 x :=
  mem_of_superset (ball_mem_nhds x ε0) ball_subset_closedBall
#align emetric.closed_ball_mem_nhds EMetric.closedBall_mem_nhds
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print EMetric.ball_prod_same /-
theorem ball_prod_same [PseudoEMetricSpace β] (x : α) (y : β) (r : ℝ≥0∞) :
    ball x r ×ˢ ball y r = ball (x, y) r :=
  ext fun z => max_lt_iff.symm
#align emetric.ball_prod_same EMetric.ball_prod_same
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print EMetric.closedBall_prod_same /-
theorem closedBall_prod_same [PseudoEMetricSpace β] (x : α) (y : β) (r : ℝ≥0∞) :
    closedBall x r ×ˢ closedBall y r = closedBall (x, y) r :=
  ext fun z => max_le_iff.symm
#align emetric.closed_ball_prod_same EMetric.closedBall_prod_same
-/

#print EMetric.mem_closure_iff /-
/-- ε-characterization of the closure in pseudoemetric spaces -/
theorem mem_closure_iff : x ∈ closure s ↔ ∀ ε > 0, ∃ y ∈ s, edist x y < ε :=
  (mem_closure_iff_nhds_basis nhds_basis_eball).trans <| by simp only [mem_ball, edist_comm x]
#align emetric.mem_closure_iff EMetric.mem_closure_iff
-/

#print EMetric.tendsto_nhds /-
theorem tendsto_nhds {f : Filter β} {u : β → α} {a : α} :
    Tendsto u f (𝓝 a) ↔ ∀ ε > 0, ∀ᶠ x in f, edist (u x) a < ε :=
  nhds_basis_eball.tendsto_right_iff
#align emetric.tendsto_nhds EMetric.tendsto_nhds
-/

#print EMetric.tendsto_atTop /-
theorem tendsto_atTop [Nonempty β] [SemilatticeSup β] {u : β → α} {a : α} :
    Tendsto u atTop (𝓝 a) ↔ ∀ ε > 0, ∃ N, ∀ n ≥ N, edist (u n) a < ε :=
  (atTop_basis.tendsto_iffₓ nhds_basis_eball).trans <| by
    simp only [exists_prop, true_and_iff, mem_Ici, mem_ball]
#align emetric.tendsto_at_top EMetric.tendsto_atTop
-/

#print EMetric.inseparable_iff /-
theorem inseparable_iff : Inseparable x y ↔ edist x y = 0 := by
  simp [inseparable_iff_mem_closure, mem_closure_iff, edist_comm, forall_lt_iff_le']
#align emetric.inseparable_iff EMetric.inseparable_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (m n «expr ≥ » N) -/
#print EMetric.cauchySeq_iff /-
-- see Note [nolint_ge]
/-- In a pseudoemetric space, Cauchy sequences are characterized by the fact that, eventually,
the pseudoedistance between its elements is arbitrarily small -/
@[nolint ge_or_gt]
theorem cauchySeq_iff [Nonempty β] [SemilatticeSup β] {u : β → α} :
    CauchySeq u ↔ ∀ ε > 0, ∃ N, ∀ (m) (_ : m ≥ N) (n) (_ : n ≥ N), edist (u m) (u n) < ε :=
  uniformity_basis_edist.cauchySeq_iff
#align emetric.cauchy_seq_iff EMetric.cauchySeq_iff
-/

#print EMetric.cauchySeq_iff' /-
/-- A variation around the emetric characterization of Cauchy sequences -/
theorem cauchySeq_iff' [Nonempty β] [SemilatticeSup β] {u : β → α} :
    CauchySeq u ↔ ∀ ε > (0 : ℝ≥0∞), ∃ N, ∀ n ≥ N, edist (u n) (u N) < ε :=
  uniformity_basis_edist.cauchySeq_iff'
#align emetric.cauchy_seq_iff' EMetric.cauchySeq_iff'
-/

#print EMetric.cauchySeq_iff_NNReal /-
/-- A variation of the emetric characterization of Cauchy sequences that deals with
`ℝ≥0` upper bounds. -/
theorem cauchySeq_iff_NNReal [Nonempty β] [SemilatticeSup β] {u : β → α} :
    CauchySeq u ↔ ∀ ε : ℝ≥0, 0 < ε → ∃ N, ∀ n, N ≤ n → edist (u n) (u N) < ε :=
  uniformity_basis_edist_nnreal.cauchySeq_iff'
#align emetric.cauchy_seq_iff_nnreal EMetric.cauchySeq_iff_NNReal
-/

#print EMetric.totallyBounded_iff /-
theorem totallyBounded_iff {s : Set α} :
    TotallyBounded s ↔ ∀ ε > 0, ∃ t : Set α, t.Finite ∧ s ⊆ ⋃ y ∈ t, ball y ε :=
  ⟨fun H ε ε0 => H _ (edist_mem_uniformity ε0), fun H r ru =>
    let ⟨ε, ε0, hε⟩ := mem_uniformity_edist.1 ru
    let ⟨t, ft, h⟩ := H ε ε0
    ⟨t, ft, h.trans <| iUnion₂_mono fun y yt z => hε⟩⟩
#align emetric.totally_bounded_iff EMetric.totallyBounded_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (t «expr ⊆ » s) -/
#print EMetric.totallyBounded_iff' /-
theorem totallyBounded_iff' {s : Set α} :
    TotallyBounded s ↔ ∀ ε > 0, ∃ (t : _) (_ : t ⊆ s), Set.Finite t ∧ s ⊆ ⋃ y ∈ t, ball y ε :=
  ⟨fun H ε ε0 => (totallyBounded_iff_subset.1 H) _ (edist_mem_uniformity ε0), fun H r ru =>
    let ⟨ε, ε0, hε⟩ := mem_uniformity_edist.1 ru
    let ⟨t, _, ft, h⟩ := H ε ε0
    ⟨t, ft, h.trans <| iUnion₂_mono fun y yt z => hε⟩⟩
#align emetric.totally_bounded_iff' EMetric.totallyBounded_iff'
-/

section Compact

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (t «expr ⊆ » s) -/
#print EMetric.subset_countable_closure_of_almost_dense_set /-
/-- For a set `s` in a pseudo emetric space, if for every `ε > 0` there exists a countable
set that is `ε`-dense in `s`, then there exists a countable subset `t ⊆ s` that is dense in `s`. -/
theorem subset_countable_closure_of_almost_dense_set (s : Set α)
    (hs : ∀ ε > 0, ∃ t : Set α, t.Countable ∧ s ⊆ ⋃ x ∈ t, closedBall x ε) :
    ∃ (t : _) (_ : t ⊆ s), t.Countable ∧ s ⊆ closure t :=
  by
  rcases s.eq_empty_or_nonempty with (rfl | ⟨x₀, hx₀⟩)
  · exact ⟨∅, empty_subset _, countable_empty, empty_subset _⟩
  choose! T hTc hsT using fun n : ℕ => hs n⁻¹ (by simp)
  have : ∀ r x, ∃ y ∈ s, closed_ball x r ∩ s ⊆ closed_ball y (r * 2) :=
    by
    intro r x
    rcases(closed_ball x r ∩ s).eq_empty_or_nonempty with (he | ⟨y, hxy, hys⟩)
    · refine' ⟨x₀, hx₀, _⟩; rw [he]; exact empty_subset _
    · refine' ⟨y, hys, fun z hz => _⟩
      calc
        edist z y ≤ edist z x + edist y x := edist_triangle_right _ _ _
        _ ≤ r + r := (add_le_add hz.1 hxy)
        _ = r * 2 := (mul_two r).symm
  choose f hfs hf
  refine'
    ⟨⋃ n : ℕ, f n⁻¹ '' T n, Union_subset fun n => image_subset_iff.2 fun z hz => hfs _ _,
      countable_Union fun n => (hTc n).image _, _⟩
  refine' fun x hx => mem_closure_iff.2 fun ε ε0 => _
  rcases ENNReal.exists_inv_nat_lt (ENNReal.half_pos ε0.lt.ne').ne' with ⟨n, hn⟩
  rcases mem_Union₂.1 (hsT n hx) with ⟨y, hyn, hyx⟩
  refine' ⟨f n⁻¹ y, mem_Union.2 ⟨n, mem_image_of_mem _ hyn⟩, _⟩
  calc
    edist x (f n⁻¹ y) ≤ n⁻¹ * 2 := hf _ _ ⟨hyx, hx⟩
    _ < ε := ENNReal.mul_lt_of_lt_div hn
#align emetric.subset_countable_closure_of_almost_dense_set EMetric.subset_countable_closure_of_almost_dense_set
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (t «expr ⊆ » s) -/
#print EMetric.subset_countable_closure_of_compact /-
/-- A compact set in a pseudo emetric space is separable, i.e., it is a subset of the closure of a
countable set.  -/
theorem subset_countable_closure_of_compact {s : Set α} (hs : IsCompact s) :
    ∃ (t : _) (_ : t ⊆ s), t.Countable ∧ s ⊆ closure t :=
  by
  refine' subset_countable_closure_of_almost_dense_set s fun ε hε => _
  rcases totally_bounded_iff'.1 hs.totally_bounded ε hε with ⟨t, hts, htf, hst⟩
  exact ⟨t, htf.countable, subset.trans hst <| Union₂_mono fun _ _ => ball_subset_closed_ball⟩
#align emetric.subset_countable_closure_of_compact EMetric.subset_countable_closure_of_compact
-/

end Compact

section SecondCountable

open _Root_.TopologicalSpace

variable (α)

#print EMetric.secondCountable_of_sigmaCompact /-
/-- A sigma compact pseudo emetric space has second countable topology. This is not an instance
to avoid a loop with `sigma_compact_space_of_locally_compact_second_countable`.  -/
theorem secondCountable_of_sigmaCompact [SigmaCompactSpace α] : SecondCountableTopology α :=
  by
  suffices separable_space α by exact UniformSpace.secondCountable_of_separable α
  choose T hTsub hTc hsubT using fun n =>
    subset_countable_closure_of_compact (isCompact_compactCovering α n)
  refine' ⟨⟨⋃ n, T n, countable_Union hTc, fun x => _⟩⟩
  rcases Union_eq_univ_iff.1 (iUnion_compactCovering α) x with ⟨n, hn⟩
  exact closure_mono (subset_Union _ n) (hsubT _ hn)
#align emetric.second_countable_of_sigma_compact EMetric.secondCountable_of_sigmaCompact
-/

variable {α}

#print EMetric.secondCountable_of_almost_dense_set /-
theorem secondCountable_of_almost_dense_set
    (hs : ∀ ε > 0, ∃ t : Set α, t.Countable ∧ (⋃ x ∈ t, closedBall x ε) = univ) :
    SecondCountableTopology α :=
  by
  suffices separable_space α by exact UniformSpace.secondCountable_of_separable α
  rcases subset_countable_closure_of_almost_dense_set (univ : Set α) fun ε ε0 => _ with
    ⟨t, -, htc, ht⟩
  · exact ⟨⟨t, htc, fun x => ht (mem_univ x)⟩⟩
  · rcases hs ε ε0 with ⟨t, htc, ht⟩
    exact ⟨t, htc, univ_subset_iff.2 ht⟩
#align emetric.second_countable_of_almost_dense_set EMetric.secondCountable_of_almost_dense_set
-/

end SecondCountable

section Diam

#print EMetric.diam /-
/-- The diameter of a set in a pseudoemetric space, named `emetric.diam` -/
noncomputable def diam (s : Set α) :=
  ⨆ (x ∈ s) (y ∈ s), edist x y
#align emetric.diam EMetric.diam
-/

#print EMetric.diam_le_iff /-
theorem diam_le_iff {d : ℝ≥0∞} : diam s ≤ d ↔ ∀ x ∈ s, ∀ y ∈ s, edist x y ≤ d := by
  simp only [diam, iSup_le_iff]
#align emetric.diam_le_iff EMetric.diam_le_iff
-/

#print EMetric.diam_image_le_iff /-
theorem diam_image_le_iff {d : ℝ≥0∞} {f : β → α} {s : Set β} :
    diam (f '' s) ≤ d ↔ ∀ x ∈ s, ∀ y ∈ s, edist (f x) (f y) ≤ d := by
  simp only [diam_le_iff, ball_image_iff]
#align emetric.diam_image_le_iff EMetric.diam_image_le_iff
-/

#print EMetric.edist_le_of_diam_le /-
theorem edist_le_of_diam_le {d} (hx : x ∈ s) (hy : y ∈ s) (hd : diam s ≤ d) : edist x y ≤ d :=
  diam_le_iff.1 hd x hx y hy
#align emetric.edist_le_of_diam_le EMetric.edist_le_of_diam_le
-/

#print EMetric.edist_le_diam_of_mem /-
/-- If two points belong to some set, their edistance is bounded by the diameter of the set -/
theorem edist_le_diam_of_mem (hx : x ∈ s) (hy : y ∈ s) : edist x y ≤ diam s :=
  edist_le_of_diam_le hx hy le_rfl
#align emetric.edist_le_diam_of_mem EMetric.edist_le_diam_of_mem
-/

#print EMetric.diam_le /-
/-- If the distance between any two points in a set is bounded by some constant, this constant
bounds the diameter. -/
theorem diam_le {d : ℝ≥0∞} (h : ∀ x ∈ s, ∀ y ∈ s, edist x y ≤ d) : diam s ≤ d :=
  diam_le_iff.2 h
#align emetric.diam_le EMetric.diam_le
-/

#print EMetric.diam_subsingleton /-
/-- The diameter of a subsingleton vanishes. -/
theorem diam_subsingleton (hs : s.Subsingleton) : diam s = 0 :=
  nonpos_iff_eq_zero.1 <| diam_le fun x hx y hy => (hs hx hy).symm ▸ edist_self y ▸ le_rfl
#align emetric.diam_subsingleton EMetric.diam_subsingleton
-/

#print EMetric.diam_empty /-
/-- The diameter of the empty set vanishes -/
@[simp]
theorem diam_empty : diam (∅ : Set α) = 0 :=
  diam_subsingleton subsingleton_empty
#align emetric.diam_empty EMetric.diam_empty
-/

#print EMetric.diam_singleton /-
/-- The diameter of a singleton vanishes -/
@[simp]
theorem diam_singleton : diam ({x} : Set α) = 0 :=
  diam_subsingleton subsingleton_singleton
#align emetric.diam_singleton EMetric.diam_singleton
-/

#print EMetric.diam_iUnion_mem_option /-
theorem diam_iUnion_mem_option {ι : Type _} (o : Option ι) (s : ι → Set α) :
    diam (⋃ i ∈ o, s i) = ⨆ i ∈ o, diam (s i) := by cases o <;> simp
#align emetric.diam_Union_mem_option EMetric.diam_iUnion_mem_option
-/

#print EMetric.diam_insert /-
theorem diam_insert : diam (insert x s) = max (⨆ y ∈ s, edist x y) (diam s) :=
  eq_of_forall_ge_iff fun d => by
    simp only [diam_le_iff, ball_insert_iff, edist_self, edist_comm x, max_le_iff, iSup_le_iff,
      zero_le, true_and_iff, forall_and, and_self_iff, ← and_assoc']
#align emetric.diam_insert EMetric.diam_insert
-/

#print EMetric.diam_pair /-
theorem diam_pair : diam ({x, y} : Set α) = edist x y := by
  simp only [iSup_singleton, diam_insert, diam_singleton, ENNReal.max_zero_right]
#align emetric.diam_pair EMetric.diam_pair
-/

#print EMetric.diam_triple /-
theorem diam_triple : diam ({x, y, z} : Set α) = max (max (edist x y) (edist x z)) (edist y z) := by
  simp only [diam_insert, iSup_insert, iSup_singleton, diam_singleton, ENNReal.max_zero_right,
    ENNReal.sup_eq_max]
#align emetric.diam_triple EMetric.diam_triple
-/

#print EMetric.diam_mono /-
/-- The diameter is monotonous with respect to inclusion -/
theorem diam_mono {s t : Set α} (h : s ⊆ t) : diam s ≤ diam t :=
  diam_le fun x hx y hy => edist_le_diam_of_mem (h hx) (h hy)
#align emetric.diam_mono EMetric.diam_mono
-/

#print EMetric.diam_union /-
/-- The diameter of a union is controlled by the diameter of the sets, and the edistance
between two points in the sets. -/
theorem diam_union {t : Set α} (xs : x ∈ s) (yt : y ∈ t) :
    diam (s ∪ t) ≤ diam s + edist x y + diam t :=
  by
  have A : ∀ a ∈ s, ∀ b ∈ t, edist a b ≤ diam s + edist x y + diam t := fun a ha b hb =>
    calc
      edist a b ≤ edist a x + edist x y + edist y b := edist_triangle4 _ _ _ _
      _ ≤ diam s + edist x y + diam t :=
        add_le_add (add_le_add (edist_le_diam_of_mem ha xs) le_rfl) (edist_le_diam_of_mem yt hb)
  refine' diam_le fun a ha b hb => _
  cases' (mem_union _ _ _).1 ha with h'a h'a <;> cases' (mem_union _ _ _).1 hb with h'b h'b
  ·
    calc
      edist a b ≤ diam s := edist_le_diam_of_mem h'a h'b
      _ ≤ diam s + (edist x y + diam t) := le_self_add
      _ = diam s + edist x y + diam t := (add_assoc _ _ _).symm
  · exact A a h'a b h'b
  · have Z := A b h'b a h'a; rwa [edist_comm] at Z 
  ·
    calc
      edist a b ≤ diam t := edist_le_diam_of_mem h'a h'b
      _ ≤ diam s + edist x y + diam t := le_add_self
#align emetric.diam_union EMetric.diam_union
-/

#print EMetric.diam_union' /-
theorem diam_union' {t : Set α} (h : (s ∩ t).Nonempty) : diam (s ∪ t) ≤ diam s + diam t :=
  by
  let ⟨x, ⟨xs, xt⟩⟩ := h
  simpa using diam_union xs xt
#align emetric.diam_union' EMetric.diam_union'
-/

#print EMetric.diam_closedBall /-
theorem diam_closedBall {r : ℝ≥0∞} : diam (closedBall x r) ≤ 2 * r :=
  diam_le fun a ha b hb =>
    calc
      edist a b ≤ edist a x + edist b x := edist_triangle_right _ _ _
      _ ≤ r + r := (add_le_add ha hb)
      _ = 2 * r := (two_mul r).symm
#align emetric.diam_closed_ball EMetric.diam_closedBall
-/

#print EMetric.diam_ball /-
theorem diam_ball {r : ℝ≥0∞} : diam (ball x r) ≤ 2 * r :=
  le_trans (diam_mono ball_subset_closedBall) diam_closedBall
#align emetric.diam_ball EMetric.diam_ball
-/

#print EMetric.diam_pi_le_of_le /-
theorem diam_pi_le_of_le {π : β → Type _} [Fintype β] [∀ b, PseudoEMetricSpace (π b)]
    {s : ∀ b : β, Set (π b)} {c : ℝ≥0∞} (h : ∀ b, diam (s b) ≤ c) : diam (Set.pi univ s) ≤ c :=
  by
  apply diam_le fun x hx y hy => edist_pi_le_iff.mpr _
  rw [mem_univ_pi] at hx hy 
  exact fun b => diam_le_iff.1 (h b) (x b) (hx b) (y b) (hy b)
#align emetric.diam_pi_le_of_le EMetric.diam_pi_le_of_le
-/

end Diam

end Emetric

#print EMetricSpace /-
--namespace
/-- We now define `emetric_space`, extending `pseudo_emetric_space`. -/
class EMetricSpace (α : Type u) extends PseudoEMetricSpace α : Type u where
  eq_of_edist_eq_zero : ∀ {x y : α}, edist x y = 0 → x = y
#align emetric_space EMetricSpace
-/

variable {γ : Type w} [EMetricSpace γ]

export EMetricSpace (eq_of_edist_eq_zero)

#print edist_eq_zero /-
/-- Characterize the equality of points by the vanishing of their extended distance -/
@[simp]
theorem edist_eq_zero {x y : γ} : edist x y = 0 ↔ x = y :=
  Iff.intro eq_of_edist_eq_zero fun this : x = y => this ▸ edist_self _
#align edist_eq_zero edist_eq_zero
-/

#print zero_eq_edist /-
@[simp]
theorem zero_eq_edist {x y : γ} : 0 = edist x y ↔ x = y :=
  Iff.intro (fun h => eq_of_edist_eq_zero h.symm) fun this : x = y => this ▸ (edist_self _).symm
#align zero_eq_edist zero_eq_edist
-/

#print edist_le_zero /-
theorem edist_le_zero {x y : γ} : edist x y ≤ 0 ↔ x = y :=
  nonpos_iff_eq_zero.trans edist_eq_zero
#align edist_le_zero edist_le_zero
-/

#print edist_pos /-
@[simp]
theorem edist_pos {x y : γ} : 0 < edist x y ↔ x ≠ y := by simp [← not_le]
#align edist_pos edist_pos
-/

#print eq_of_forall_edist_le /-
/-- Two points coincide if their distance is `< ε` for all positive ε -/
theorem eq_of_forall_edist_le {x y : γ} (h : ∀ ε > 0, edist x y ≤ ε) : x = y :=
  eq_of_edist_eq_zero (eq_of_le_of_forall_le_of_dense bot_le h)
#align eq_of_forall_edist_le eq_of_forall_edist_le
-/

#print to_separated /-
-- see Note [lower instance priority]
/-- An emetric space is separated -/
instance (priority := 100) to_separated : SeparatedSpace γ :=
  separated_def.2 fun x y h =>
    eq_of_forall_edist_le fun ε ε0 => le_of_lt (h _ (edist_mem_uniformity ε0))
#align to_separated to_separated
-/

#print EMetric.uniformEmbedding_iff' /-
/-- A map between emetric spaces is a uniform embedding if and only if the edistance between `f x`
and `f y` is controlled in terms of the distance between `x` and `y` and conversely. -/
theorem EMetric.uniformEmbedding_iff' [EMetricSpace β] {f : γ → β} :
    UniformEmbedding f ↔
      (∀ ε > 0, ∃ δ > 0, ∀ {a b : γ}, edist a b < δ → edist (f a) (f b) < ε) ∧
        ∀ δ > 0, ∃ ε > 0, ∀ {a b : γ}, edist (f a) (f b) < ε → edist a b < δ :=
  by
  simp only [uniformEmbedding_iff_uniformInducing,
    uniformity_basis_edist.uniform_inducing_iff uniformity_basis_edist, exists_prop]
  rfl
#align emetric.uniform_embedding_iff' EMetric.uniformEmbedding_iff'
-/

#print EMetricSpace.ofT0PseudoEMetricSpace /-
/-- If a `pseudo_emetric_space` is a T₀ space, then it is an `emetric_space`. -/
def EMetricSpace.ofT0PseudoEMetricSpace (α : Type _) [PseudoEMetricSpace α] [T0Space α] :
    EMetricSpace α :=
  { ‹PseudoEMetricSpace α› with
    eq_of_edist_eq_zero := fun x y hdist => (EMetric.inseparable_iff.2 hdist).Eq }
#align emetric_space.of_t0_pseudo_emetric_space EMetricSpace.ofT0PseudoEMetricSpace
-/

#print EMetricSpace.replaceUniformity /-
/-- Auxiliary function to replace the uniformity on an emetric space with
a uniformity which is equal to the original one, but maybe not defeq.
This is useful if one wants to construct an emetric space with a
specified uniformity. See Note [forgetful inheritance] explaining why having definitionally
the right uniformity is often important.
-/
def EMetricSpace.replaceUniformity {γ} [U : UniformSpace γ] (m : EMetricSpace γ)
    (H : 𝓤[U] = 𝓤[PseudoEMetricSpace.toUniformSpace]) : EMetricSpace γ
    where
  edist := @edist _ m.toHasEdist
  edist_self := edist_self
  eq_of_edist_eq_zero := @eq_of_edist_eq_zero _ _
  edist_comm := edist_comm
  edist_triangle := edist_triangle
  toUniformSpace := U
  uniformity_edist := H.trans (@PseudoEMetricSpace.uniformity_edist γ _)
#align emetric_space.replace_uniformity EMetricSpace.replaceUniformity
-/

#print EMetricSpace.induced /-
/-- The extended metric induced by an injective function taking values in a emetric space. -/
def EMetricSpace.induced {γ β} (f : γ → β) (hf : Function.Injective f) (m : EMetricSpace β) :
    EMetricSpace γ where
  edist x y := edist (f x) (f y)
  edist_self x := edist_self _
  eq_of_edist_eq_zero x y h := hf (edist_eq_zero.1 h)
  edist_comm x y := edist_comm _ _
  edist_triangle x y z := edist_triangle _ _ _
  toUniformSpace := UniformSpace.comap f m.toUniformSpace
  uniformity_edist := (uniformity_basis_edist.comap _).eq_biInf
#align emetric_space.induced EMetricSpace.induced
-/

/-- Emetric space instance on subsets of emetric spaces -/
instance {α : Type _} {p : α → Prop} [EMetricSpace α] : EMetricSpace (Subtype p) :=
  EMetricSpace.induced coe Subtype.coe_injective ‹_›

/-- Emetric space instance on the multiplicative opposite of an emetric space. -/
@[to_additive "Emetric space instance on the additive opposite of an emetric space."]
instance {α : Type _} [EMetricSpace α] : EMetricSpace αᵐᵒᵖ :=
  EMetricSpace.induced MulOpposite.unop MulOpposite.unop_injective ‹_›

instance {α : Type _} [EMetricSpace α] : EMetricSpace (ULift α) :=
  EMetricSpace.induced ULift.down ULift.down_injective ‹_›

#print Prod.emetricSpaceMax /-
/-- The product of two emetric spaces, with the max distance, is an extended
metric spaces. We make sure that the uniform structure thus constructed is the one
corresponding to the product of uniform spaces, to avoid diamond problems. -/
instance Prod.emetricSpaceMax [EMetricSpace β] : EMetricSpace (γ × β) :=
  { Prod.pseudoEMetricSpaceMax with
    eq_of_edist_eq_zero := fun x y h =>
      by
      cases' max_le_iff.1 (le_of_eq h) with h₁ h₂
      have A : x.fst = y.fst := edist_le_zero.1 h₁
      have B : x.snd = y.snd := edist_le_zero.1 h₂
      exact Prod.ext_iff.2 ⟨A, B⟩ }
#align prod.emetric_space_max Prod.emetricSpaceMax
-/

#print uniformity_edist /-
/-- Reformulation of the uniform structure in terms of the extended distance -/
theorem uniformity_edist : 𝓤 γ = ⨅ ε > 0, 𝓟 {p : γ × γ | edist p.1 p.2 < ε} :=
  PseudoEMetricSpace.uniformity_edist
#align uniformity_edist uniformity_edist
-/

section Pi

open Finset

variable {π : β → Type _} [Fintype β]

#print emetricSpacePi /-
/-- The product of a finite number of emetric spaces, with the max distance, is still
an emetric space.
This construction would also work for infinite products, but it would not give rise
to the product topology. Hence, we only formalize it in the good situation of finitely many
spaces. -/
instance emetricSpacePi [∀ b, EMetricSpace (π b)] : EMetricSpace (∀ b, π b) :=
  { pseudoEMetricSpacePi with
    eq_of_edist_eq_zero := fun f g eq0 =>
      by
      have eq1 : (sup univ fun b : β => edist (f b) (g b)) ≤ 0 := le_of_eq eq0
      simp only [Finset.sup_le_iff] at eq1 
      exact funext fun b => edist_le_zero.1 <| eq1 b <| mem_univ b }
#align emetric_space_pi emetricSpacePi
-/

end Pi

namespace Emetric

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (t «expr ⊆ » s) -/
#print EMetric.countable_closure_of_compact /-
/-- A compact set in an emetric space is separable, i.e., it is the closure of a countable set. -/
theorem countable_closure_of_compact {s : Set γ} (hs : IsCompact s) :
    ∃ (t : _) (_ : t ⊆ s), t.Countable ∧ s = closure t :=
  by
  rcases subset_countable_closure_of_compact hs with ⟨t, hts, htc, hsub⟩
  exact ⟨t, hts, htc, subset.antisymm hsub (closure_minimal hts hs.is_closed)⟩
#align emetric.countable_closure_of_compact EMetric.countable_closure_of_compact
-/

section Diam

variable {s : Set γ}

#print EMetric.diam_eq_zero_iff /-
theorem diam_eq_zero_iff : diam s = 0 ↔ s.Subsingleton :=
  ⟨fun h x hx y hy => edist_le_zero.1 <| h ▸ edist_le_diam_of_mem hx hy, diam_subsingleton⟩
#align emetric.diam_eq_zero_iff EMetric.diam_eq_zero_iff
-/

#print EMetric.diam_pos_iff' /-
theorem diam_pos_iff' : 0 < diam s ↔ ∃ x ∈ s, ∃ y ∈ s, x ≠ y := by
  simp only [pos_iff_ne_zero, Ne.def, diam_eq_zero_iff, Set.Subsingleton, not_forall]
#align emetric.diam_pos_iff EMetric.diam_pos_iff'
-/

end Diam

end Emetric

/-!
### Separation quotient
-/


instance [PseudoEMetricSpace X] : EDist (UniformSpace.SeparationQuotient X) :=
  ⟨fun x y =>
    Quotient.liftOn₂' x y edist fun x y x' y' hx hy =>
      calc
        edist x y = edist x' y :=
          edist_congr_right <| EMetric.inseparable_iff.1 <| separationRel_iff_inseparable.1 hx
        _ = edist x' y' :=
          edist_congr_left <| EMetric.inseparable_iff.1 <| separationRel_iff_inseparable.1 hy⟩

#print UniformSpace.SeparationQuotient.edist_mk /-
@[simp]
theorem UniformSpace.SeparationQuotient.edist_mk [PseudoEMetricSpace X] (x y : X) :
    @edist (UniformSpace.SeparationQuotient X) _ (Quot.mk _ x) (Quot.mk _ y) = edist x y :=
  rfl
#align uniform_space.separation_quotient.edist_mk UniformSpace.SeparationQuotient.edist_mk
-/

instance [PseudoEMetricSpace X] : EMetricSpace (UniformSpace.SeparationQuotient X) :=
  @EMetricSpace.ofT0PseudoEMetricSpace (UniformSpace.SeparationQuotient X)
    { edist_self := fun x => Quotient.inductionOn' x edist_self
      edist_comm := fun x y => Quotient.inductionOn₂' x y edist_comm
      edist_triangle := fun x y z => Quotient.inductionOn₃' x y z edist_triangle
      toUniformSpace := inferInstance
      uniformity_edist :=
        (uniformity_basis_edist.map _).eq_biInf.trans <|
          iInf_congr fun ε =>
            iInf_congr fun hε =>
              congr_arg 𝓟
                (by
                  ext ⟨⟨x⟩, ⟨y⟩⟩
                  refine' ⟨_, fun h => ⟨(x, y), h, rfl⟩⟩
                  rintro ⟨⟨x', y'⟩, h', h⟩
                  simp only [Prod.ext_iff] at h 
                  rwa [← h.1, ← h.2]) }
    _

/-!
### `additive`, `multiplicative`

The distance on those type synonyms is inherited without change.
-/


open Additive Multiplicative

section

variable [EDist X]

instance : EDist (Additive X) :=
  ‹EDist X›

instance : EDist (Multiplicative X) :=
  ‹EDist X›

#print edist_ofMul /-
@[simp]
theorem edist_ofMul (a b : X) : edist (ofMul a) (ofMul b) = edist a b :=
  rfl
#align edist_of_mul edist_ofMul
-/

#print edist_ofAdd /-
@[simp]
theorem edist_ofAdd (a b : X) : edist (ofAdd a) (ofAdd b) = edist a b :=
  rfl
#align edist_of_add edist_ofAdd
-/

#print edist_toMul /-
@[simp]
theorem edist_toMul (a b : Additive X) : edist (toMul a) (toMul b) = edist a b :=
  rfl
#align edist_to_mul edist_toMul
-/

#print edist_toAdd /-
@[simp]
theorem edist_toAdd (a b : Multiplicative X) : edist (toAdd a) (toAdd b) = edist a b :=
  rfl
#align edist_to_add edist_toAdd
-/

end

instance [PseudoEMetricSpace X] : PseudoEMetricSpace (Additive X) :=
  ‹PseudoEMetricSpace X›

instance [PseudoEMetricSpace X] : PseudoEMetricSpace (Multiplicative X) :=
  ‹PseudoEMetricSpace X›

instance [EMetricSpace X] : EMetricSpace (Additive X) :=
  ‹EMetricSpace X›

instance [EMetricSpace X] : EMetricSpace (Multiplicative X) :=
  ‹EMetricSpace X›

/-!
### Order dual

The distance on this type synonym is inherited without change.
-/


open OrderDual

section

variable [EDist X]

instance : EDist Xᵒᵈ :=
  ‹EDist X›

#print edist_toDual /-
@[simp]
theorem edist_toDual (a b : X) : edist (toDual a) (toDual b) = edist a b :=
  rfl
#align edist_to_dual edist_toDual
-/

#print edist_ofDual /-
@[simp]
theorem edist_ofDual (a b : Xᵒᵈ) : edist (ofDual a) (ofDual b) = edist a b :=
  rfl
#align edist_of_dual edist_ofDual
-/

end

instance [PseudoEMetricSpace X] : PseudoEMetricSpace Xᵒᵈ :=
  ‹PseudoEMetricSpace X›

instance [EMetricSpace X] : EMetricSpace Xᵒᵈ :=
  ‹EMetricSpace X›

