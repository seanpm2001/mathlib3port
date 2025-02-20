/-
Copyright (c) 2020 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Johan Commelin

! This file was ported from Lean 3 source module analysis.analytic.composition
! leanprover-community/mathlib commit d07a9c875ed7139abfde6a333b2be205c5bd404e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Analytic.Basic
import Mathbin.Combinatorics.Composition

/-!
# Composition of analytic functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that the composition of analytic functions is analytic.

The argument is the following. Assume `g z = ∑' qₙ (z, ..., z)` and `f y = ∑' pₖ (y, ..., y)`. Then

`g (f y) = ∑' qₙ (∑' pₖ (y, ..., y), ..., ∑' pₖ (y, ..., y))
= ∑' qₙ (p_{i₁} (y, ..., y), ..., p_{iₙ} (y, ..., y))`.

For each `n` and `i₁, ..., iₙ`, define a `i₁ + ... + iₙ` multilinear function mapping
`(y₀, ..., y_{i₁ + ... + iₙ - 1})` to
`qₙ (p_{i₁} (y₀, ..., y_{i₁-1}), p_{i₂} (y_{i₁}, ..., y_{i₁ + i₂ - 1}), ..., p_{iₙ} (....)))`.
Then `g ∘ f` is obtained by summing all these multilinear functions.

To formalize this, we use compositions of an integer `N`, i.e., its decompositions into
a sum `i₁ + ... + iₙ` of positive integers. Given such a composition `c` and two formal
multilinear series `q` and `p`, let `q.comp_along_composition p c` be the above multilinear
function. Then the `N`-th coefficient in the power series expansion of `g ∘ f` is the sum of these
terms over all `c : composition N`.

To complete the proof, we need to show that this power series has a positive radius of convergence.
This follows from the fact that `composition N` has cardinality `2^(N-1)` and estimates on
the norm of `qₙ` and `pₖ`, which give summability. We also need to show that it indeed converges to
`g ∘ f`. For this, we note that the composition of partial sums converges to `g ∘ f`, and that it
corresponds to a part of the whole sum, on a subset that increases to the whole space. By
summability of the norms, this implies the overall convergence.

## Main results

* `q.comp p` is the formal composition of the formal multilinear series `q` and `p`.
* `has_fpower_series_at.comp` states that if two functions `g` and `f` admit power series expansions
  `q` and `p`, then `g ∘ f` admits a power series expansion given by `q.comp p`.
* `analytic_at.comp` states that the composition of analytic functions is analytic.
* `formal_multilinear_series.comp_assoc` states that composition is associative on formal
  multilinear series.

## Implementation details

The main technical difficulty is to write down things. In particular, we need to define precisely
`q.comp_along_composition p c` and to show that it is indeed a continuous multilinear
function. This requires a whole interface built on the class `composition`. Once this is set,
the main difficulty is to reorder the sums, writing the composition of the partial sums as a sum
over some subset of `Σ n, composition n`. We need to check that the reordering is a bijection,
running over difficulties due to the dependent nature of the types under consideration, that are
controlled thanks to the interface for `composition`.

The associativity of composition on formal multilinear series is a nontrivial result: it does not
follow from the associativity of composition of analytic functions, as there is no uniqueness for
the formal multilinear series representing a function (and also, it holds even when the radius of
convergence of the series is `0`). Instead, we give a direct proof, which amounts to reordering
double sums in a careful way. The change of variables is a canonical (combinatorial) bijection
`composition.sigma_equiv_sigma_pi` between `(Σ (a : composition n), composition a.length)` and
`(Σ (c : composition n), Π (i : fin c.length), composition (c.blocks_fun i))`, and is described
in more details below in the paragraph on associativity.
-/


noncomputable section

variable {𝕜 : Type _} {E F G H : Type _}

open Filter List

open scoped Topology BigOperators Classical NNReal ENNReal

section Topological

variable [CommRing 𝕜] [AddCommGroup E] [AddCommGroup F] [AddCommGroup G]

variable [Module 𝕜 E] [Module 𝕜 F] [Module 𝕜 G]

variable [TopologicalSpace E] [TopologicalSpace F] [TopologicalSpace G]

/-! ### Composing formal multilinear series -/


namespace FormalMultilinearSeries

variable [TopologicalAddGroup E] [ContinuousConstSMul 𝕜 E]

variable [TopologicalAddGroup F] [ContinuousConstSMul 𝕜 F]

variable [TopologicalAddGroup G] [ContinuousConstSMul 𝕜 G]

/-!
In this paragraph, we define the composition of formal multilinear series, by summing over all
possible compositions of `n`.
-/


#print FormalMultilinearSeries.applyComposition /-
/-- Given a formal multilinear series `p`, a composition `c` of `n` and the index `i` of a
block of `c`, we may define a function on `fin n → E` by picking the variables in the `i`-th block
of `n`, and applying the corresponding coefficient of `p` to these variables. This function is
called `p.apply_composition c v i` for `v : fin n → E` and `i : fin c.length`. -/
def applyComposition (p : FormalMultilinearSeries 𝕜 E F) {n : ℕ} (c : Composition n) :
    (Fin n → E) → Fin c.length → F := fun v i => p (c.blocksFun i) (v ∘ c.Embedding i)
#align formal_multilinear_series.apply_composition FormalMultilinearSeries.applyComposition
-/

#print FormalMultilinearSeries.applyComposition_ones /-
theorem applyComposition_ones (p : FormalMultilinearSeries 𝕜 E F) (n : ℕ) :
    p.applyComposition (Composition.ones n) = fun v i =>
      p 1 fun _ => v (Fin.castLE (Composition.length_le _) i) :=
  by
  funext v i
  apply p.congr (Composition.ones_blocksFun _ _)
  intro j hjn hj1
  obtain rfl : j = 0 := by linarith
  refine' congr_arg v _
  rw [Fin.ext_iff, Fin.coe_castLE, Composition.ones_embedding, Fin.val_mk]
#align formal_multilinear_series.apply_composition_ones FormalMultilinearSeries.applyComposition_ones
-/

#print FormalMultilinearSeries.applyComposition_single /-
theorem applyComposition_single (p : FormalMultilinearSeries 𝕜 E F) {n : ℕ} (hn : 0 < n)
    (v : Fin n → E) : p.applyComposition (Composition.single n hn) v = fun j => p n v :=
  by
  ext j
  refine' p.congr (by simp) fun i hi1 hi2 => _
  dsimp
  congr 1
  convert Composition.single_embedding hn ⟨i, hi2⟩
  cases j
  have : j_val = 0 := le_bot_iff.1 (Nat.lt_succ_iff.1 j_property)
  unfold_coes
  congr <;>
    try
      first
      | assumption
      | simp
#align formal_multilinear_series.apply_composition_single FormalMultilinearSeries.applyComposition_single
-/

#print FormalMultilinearSeries.removeZero_applyComposition /-
@[simp]
theorem removeZero_applyComposition (p : FormalMultilinearSeries 𝕜 E F) {n : ℕ}
    (c : Composition n) : p.removeZero.applyComposition c = p.applyComposition c :=
  by
  ext v i
  simp [apply_composition, zero_lt_one.trans_le (c.one_le_blocks_fun i), remove_zero_of_pos]
#align formal_multilinear_series.remove_zero_apply_composition FormalMultilinearSeries.removeZero_applyComposition
-/

#print FormalMultilinearSeries.applyComposition_update /-
/-- Technical lemma stating how `p.apply_composition` commutes with updating variables. This
will be the key point to show that functions constructed from `apply_composition` retain
multilinearity. -/
theorem applyComposition_update (p : FormalMultilinearSeries 𝕜 E F) {n : ℕ} (c : Composition n)
    (j : Fin n) (v : Fin n → E) (z : E) :
    p.applyComposition c (Function.update v j z) =
      Function.update (p.applyComposition c v) (c.index j)
        (p (c.blocksFun (c.index j))
          (Function.update (v ∘ c.Embedding (c.index j)) (c.invEmbedding j) z)) :=
  by
  ext k
  by_cases h : k = c.index j
  · rw [h]
    let r : Fin (c.blocks_fun (c.index j)) → Fin n := c.embedding (c.index j)
    simp only [Function.update_same]
    change p (c.blocks_fun (c.index j)) (Function.update v j z ∘ r) = _
    let j' := c.inv_embedding j
    suffices B : Function.update v j z ∘ r = Function.update (v ∘ r) j' z
    · rw [B]
    suffices C : Function.update v (r j') z ∘ r = Function.update (v ∘ r) j' z
    · convert C; exact (c.embedding_comp_inv j).symm
    exact Function.update_comp_eq_of_injective _ (c.embedding _).Injective _ _
  · simp only [h, Function.update_eq_self, Function.update_noteq, Ne.def, not_false_iff]
    let r : Fin (c.blocks_fun k) → Fin n := c.embedding k
    change p (c.blocks_fun k) (Function.update v j z ∘ r) = p (c.blocks_fun k) (v ∘ r)
    suffices B : Function.update v j z ∘ r = v ∘ r; · rw [B]
    apply Function.update_comp_eq_of_not_mem_range
    rwa [c.mem_range_embedding_iff']
#align formal_multilinear_series.apply_composition_update FormalMultilinearSeries.applyComposition_update
-/

#print FormalMultilinearSeries.compContinuousLinearMap_applyComposition /-
@[simp]
theorem compContinuousLinearMap_applyComposition {n : ℕ} (p : FormalMultilinearSeries 𝕜 F G)
    (f : E →L[𝕜] F) (c : Composition n) (v : Fin n → E) :
    (p.compContinuousLinearMap f).applyComposition c v = p.applyComposition c (f ∘ v) := by
  simp [apply_composition]
#align formal_multilinear_series.comp_continuous_linear_map_apply_composition FormalMultilinearSeries.compContinuousLinearMap_applyComposition
-/

end FormalMultilinearSeries

namespace ContinuousMultilinearMap

open FormalMultilinearSeries

variable [TopologicalAddGroup E] [ContinuousConstSMul 𝕜 E]

variable [TopologicalAddGroup F] [ContinuousConstSMul 𝕜 F]

#print ContinuousMultilinearMap.compAlongComposition /-
/-- Given a formal multilinear series `p`, a composition `c` of `n` and a continuous multilinear
map `f` in `c.length` variables, one may form a continuous multilinear map in `n` variables by
applying the right coefficient of `p` to each block of the composition, and then applying `f` to
the resulting vector. It is called `f.comp_along_composition p c`. -/
def compAlongComposition {n : ℕ} (p : FormalMultilinearSeries 𝕜 E F) (c : Composition n)
    (f : ContinuousMultilinearMap 𝕜 (fun i : Fin c.length => F) G) :
    ContinuousMultilinearMap 𝕜 (fun i : Fin n => E) G
    where
  toFun v := f (p.applyComposition c v)
  map_add' _ v i x y := by
    cases Subsingleton.elim ‹_› (Fin.decidableEq _)
    simp only [apply_composition_update, ContinuousMultilinearMap.map_add]
  map_smul' _ v i c x := by
    cases Subsingleton.elim ‹_› (Fin.decidableEq _)
    simp only [apply_composition_update, ContinuousMultilinearMap.map_smul]
  cont :=
    f.cont.comp <|
      continuous_pi fun i => (coe_continuous _).comp <| continuous_pi fun j => continuous_apply _
#align continuous_multilinear_map.comp_along_composition ContinuousMultilinearMap.compAlongComposition
-/

#print ContinuousMultilinearMap.compAlongComposition_apply /-
@[simp]
theorem compAlongComposition_apply {n : ℕ} (p : FormalMultilinearSeries 𝕜 E F) (c : Composition n)
    (f : ContinuousMultilinearMap 𝕜 (fun i : Fin c.length => F) G) (v : Fin n → E) :
    (f.compAlongComposition p c) v = f (p.applyComposition c v) :=
  rfl
#align continuous_multilinear_map.comp_along_composition_apply ContinuousMultilinearMap.compAlongComposition_apply
-/

end ContinuousMultilinearMap

namespace FormalMultilinearSeries

variable [TopologicalAddGroup E] [ContinuousConstSMul 𝕜 E]

variable [TopologicalAddGroup F] [ContinuousConstSMul 𝕜 F]

variable [TopologicalAddGroup G] [ContinuousConstSMul 𝕜 G]

#print FormalMultilinearSeries.compAlongComposition /-
/-- Given two formal multilinear series `q` and `p` and a composition `c` of `n`, one may
form a continuous multilinear map in `n` variables by applying the right coefficient of `p` to each
block of the composition, and then applying `q c.length` to the resulting vector. It is
called `q.comp_along_composition p c`. -/
def compAlongComposition {n : ℕ} (q : FormalMultilinearSeries 𝕜 F G)
    (p : FormalMultilinearSeries 𝕜 E F) (c : Composition n) :
    ContinuousMultilinearMap 𝕜 (fun i : Fin n => E) G :=
  (q c.length).compAlongComposition p c
#align formal_multilinear_series.comp_along_composition FormalMultilinearSeries.compAlongComposition
-/

#print FormalMultilinearSeries.compAlongComposition_apply /-
@[simp]
theorem compAlongComposition_apply {n : ℕ} (q : FormalMultilinearSeries 𝕜 F G)
    (p : FormalMultilinearSeries 𝕜 E F) (c : Composition n) (v : Fin n → E) :
    (q.compAlongComposition p c) v = q c.length (p.applyComposition c v) :=
  rfl
#align formal_multilinear_series.comp_along_composition_apply FormalMultilinearSeries.compAlongComposition_apply
-/

#print FormalMultilinearSeries.comp /-
/-- Formal composition of two formal multilinear series. The `n`-th coefficient in the composition
is defined to be the sum of `q.comp_along_composition p c` over all compositions of
`n`. In other words, this term (as a multilinear function applied to `v_0, ..., v_{n-1}`) is
`∑'_{k} ∑'_{i₁ + ... + iₖ = n} qₖ (p_{i_1} (...), ..., p_{i_k} (...))`, where one puts all variables
`v_0, ..., v_{n-1}` in increasing order in the dots.

In general, the composition `q ∘ p` only makes sense when the constant coefficient of `p` vanishes.
We give a general formula but which ignores the value of `p 0` instead.
-/
protected def comp (q : FormalMultilinearSeries 𝕜 F G) (p : FormalMultilinearSeries 𝕜 E F) :
    FormalMultilinearSeries 𝕜 E G := fun n => ∑ c : Composition n, q.compAlongComposition p c
#align formal_multilinear_series.comp FormalMultilinearSeries.comp
-/

#print FormalMultilinearSeries.comp_coeff_zero /-
/-- The `0`-th coefficient of `q.comp p` is `q 0`. Since these maps are multilinear maps in zero
variables, but on different spaces, we can not state this directly, so we state it when applied to
arbitrary vectors (which have to be the zero vector). -/
theorem comp_coeff_zero (q : FormalMultilinearSeries 𝕜 F G) (p : FormalMultilinearSeries 𝕜 E F)
    (v : Fin 0 → E) (v' : Fin 0 → F) : (q.comp p) 0 v = q 0 v' :=
  by
  let c : Composition 0 := Composition.ones 0
  dsimp [FormalMultilinearSeries.comp]
  have : {c} = (Finset.univ : Finset (Composition 0)) := by
    apply Finset.eq_of_subset_of_card_le <;> simp [Finset.card_univ, composition_card 0]
  rw [← this, Finset.sum_singleton, comp_along_composition_apply]
  symm; congr
#align formal_multilinear_series.comp_coeff_zero FormalMultilinearSeries.comp_coeff_zero
-/

#print FormalMultilinearSeries.comp_coeff_zero' /-
@[simp]
theorem comp_coeff_zero' (q : FormalMultilinearSeries 𝕜 F G) (p : FormalMultilinearSeries 𝕜 E F)
    (v : Fin 0 → E) : (q.comp p) 0 v = q 0 fun i => 0 :=
  q.comp_coeff_zero p v _
#align formal_multilinear_series.comp_coeff_zero' FormalMultilinearSeries.comp_coeff_zero'
-/

#print FormalMultilinearSeries.comp_coeff_zero'' /-
/-- The `0`-th coefficient of `q.comp p` is `q 0`. When `p` goes from `E` to `E`, this can be
expressed as a direct equality -/
theorem comp_coeff_zero'' (q : FormalMultilinearSeries 𝕜 E F) (p : FormalMultilinearSeries 𝕜 E E) :
    (q.comp p) 0 = q 0 := by ext v; exact q.comp_coeff_zero p _ _
#align formal_multilinear_series.comp_coeff_zero'' FormalMultilinearSeries.comp_coeff_zero''
-/

#print FormalMultilinearSeries.comp_coeff_one /-
/-- The first coefficient of a composition of formal multilinear series is the composition of the
first coefficients seen as continuous linear maps. -/
theorem comp_coeff_one (q : FormalMultilinearSeries 𝕜 F G) (p : FormalMultilinearSeries 𝕜 E F)
    (v : Fin 1 → E) : (q.comp p) 1 v = q 1 fun i => p 1 v :=
  by
  have : {Composition.ones 1} = (Finset.univ : Finset (Composition 1)) :=
    Finset.eq_univ_of_card _ (by simp [composition_card])
  simp only [FormalMultilinearSeries.comp, comp_along_composition_apply, ← this,
    Finset.sum_singleton]
  refine' q.congr (by simp) fun i hi1 hi2 => _
  simp only [apply_composition_ones]
  exact p.congr rfl fun j hj1 hj2 => by congr
#align formal_multilinear_series.comp_coeff_one FormalMultilinearSeries.comp_coeff_one
-/

#print FormalMultilinearSeries.removeZero_comp_of_pos /-
/-- Only `0`-th coefficient of `q.comp p` depends on `q 0`. -/
theorem removeZero_comp_of_pos (q : FormalMultilinearSeries 𝕜 F G)
    (p : FormalMultilinearSeries 𝕜 E F) {n : ℕ} (hn : 0 < n) : q.removeZero.comp p n = q.comp p n :=
  by
  ext v
  simp only [FormalMultilinearSeries.comp, comp_along_composition,
    ContinuousMultilinearMap.compAlongComposition_apply, ContinuousMultilinearMap.sum_apply]
  apply Finset.sum_congr rfl fun c hc => _
  rw [remove_zero_of_pos _ (c.length_pos_of_pos hn)]
#align formal_multilinear_series.remove_zero_comp_of_pos FormalMultilinearSeries.removeZero_comp_of_pos
-/

#print FormalMultilinearSeries.comp_removeZero /-
@[simp]
theorem comp_removeZero (q : FormalMultilinearSeries 𝕜 F G) (p : FormalMultilinearSeries 𝕜 E F) :
    q.comp p.removeZero = q.comp p := by ext n; simp [FormalMultilinearSeries.comp]
#align formal_multilinear_series.comp_remove_zero FormalMultilinearSeries.comp_removeZero
-/

end FormalMultilinearSeries

end Topological

variable [NontriviallyNormedField 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E] [NormedAddCommGroup F]
  [NormedSpace 𝕜 F] [NormedAddCommGroup G] [NormedSpace 𝕜 G] [NormedAddCommGroup H]
  [NormedSpace 𝕜 H]

namespace FormalMultilinearSeries

#print FormalMultilinearSeries.compAlongComposition_bound /-
/-- The norm of `f.comp_along_composition p c` is controlled by the product of
the norms of the relevant bits of `f` and `p`. -/
theorem compAlongComposition_bound {n : ℕ} (p : FormalMultilinearSeries 𝕜 E F) (c : Composition n)
    (f : ContinuousMultilinearMap 𝕜 (fun i : Fin c.length => F) G) (v : Fin n → E) :
    ‖f.compAlongComposition p c v‖ ≤ (‖f‖ * ∏ i, ‖p (c.blocksFun i)‖) * ∏ i : Fin n, ‖v i‖ :=
  calc
    ‖f.compAlongComposition p c v‖ = ‖f (p.applyComposition c v)‖ := rfl
    _ ≤ ‖f‖ * ∏ i, ‖p.applyComposition c v i‖ := (ContinuousMultilinearMap.le_op_norm _ _)
    _ ≤ ‖f‖ * ∏ i, ‖p (c.blocksFun i)‖ * ∏ j : Fin (c.blocksFun i), ‖(v ∘ c.Embedding i) j‖ :=
      by
      apply mul_le_mul_of_nonneg_left _ (norm_nonneg _)
      refine' Finset.prod_le_prod (fun i hi => norm_nonneg _) fun i hi => _
      apply ContinuousMultilinearMap.le_op_norm
    _ =
        (‖f‖ * ∏ i, ‖p (c.blocksFun i)‖) *
          ∏ (i) (j : Fin (c.blocksFun i)), ‖(v ∘ c.Embedding i) j‖ :=
      by rw [Finset.prod_mul_distrib, mul_assoc]
    _ = (‖f‖ * ∏ i, ‖p (c.blocksFun i)‖) * ∏ i : Fin n, ‖v i‖ :=
      by
      rw [← c.blocks_fin_equiv.prod_comp, ← Finset.univ_sigma_univ, Finset.prod_sigma]
      congr
#align formal_multilinear_series.comp_along_composition_bound FormalMultilinearSeries.compAlongComposition_bound
-/

#print FormalMultilinearSeries.compAlongComposition_norm /-
/-- The norm of `q.comp_along_composition p c` is controlled by the product of
the norms of the relevant bits of `q` and `p`. -/
theorem compAlongComposition_norm {n : ℕ} (q : FormalMultilinearSeries 𝕜 F G)
    (p : FormalMultilinearSeries 𝕜 E F) (c : Composition n) :
    ‖q.compAlongComposition p c‖ ≤ ‖q c.length‖ * ∏ i, ‖p (c.blocksFun i)‖ :=
  ContinuousMultilinearMap.op_norm_le_bound _
    (mul_nonneg (norm_nonneg _) (Finset.prod_nonneg fun i hi => norm_nonneg _))
    (compAlongComposition_bound _ _ _)
#align formal_multilinear_series.comp_along_composition_norm FormalMultilinearSeries.compAlongComposition_norm
-/

#print FormalMultilinearSeries.compAlongComposition_nnnorm /-
theorem compAlongComposition_nnnorm {n : ℕ} (q : FormalMultilinearSeries 𝕜 F G)
    (p : FormalMultilinearSeries 𝕜 E F) (c : Composition n) :
    ‖q.compAlongComposition p c‖₊ ≤ ‖q c.length‖₊ * ∏ i, ‖p (c.blocksFun i)‖₊ := by
  rw [← NNReal.coe_le_coe]; push_cast ; exact q.comp_along_composition_norm p c
#align formal_multilinear_series.comp_along_composition_nnnorm FormalMultilinearSeries.compAlongComposition_nnnorm
-/

/-!
### The identity formal power series

We will now define the identity power series, and show that it is a neutral element for left and
right composition.
-/


section

variable (𝕜 E)

#print FormalMultilinearSeries.id /-
/-- The identity formal multilinear series, with all coefficients equal to `0` except for `n = 1`
where it is (the continuous multilinear version of) the identity. -/
def id : FormalMultilinearSeries 𝕜 E E
  | 0 => 0
  | 1 => (continuousMultilinearCurryFin1 𝕜 E E).symm (ContinuousLinearMap.id 𝕜 E)
  | _ => 0
#align formal_multilinear_series.id FormalMultilinearSeries.id
-/

#print FormalMultilinearSeries.id_apply_one /-
/-- The first coefficient of `id 𝕜 E` is the identity. -/
@[simp]
theorem id_apply_one (v : Fin 1 → E) : (FormalMultilinearSeries.id 𝕜 E) 1 v = v 0 :=
  rfl
#align formal_multilinear_series.id_apply_one FormalMultilinearSeries.id_apply_one
-/

#print FormalMultilinearSeries.id_apply_one' /-
/-- The `n`th coefficient of `id 𝕜 E` is the identity when `n = 1`. We state this in a dependent
way, as it will often appear in this form. -/
theorem id_apply_one' {n : ℕ} (h : n = 1) (v : Fin n → E) :
    (id 𝕜 E) n v = v ⟨0, h.symm ▸ zero_lt_one⟩ :=
  by
  subst n
  apply id_apply_one
#align formal_multilinear_series.id_apply_one' FormalMultilinearSeries.id_apply_one'
-/

#print FormalMultilinearSeries.id_apply_ne_one /-
/-- For `n ≠ 1`, the `n`-th coefficient of `id 𝕜 E` is zero, by definition. -/
@[simp]
theorem id_apply_ne_one {n : ℕ} (h : n ≠ 1) : (FormalMultilinearSeries.id 𝕜 E) n = 0 := by cases n;
  · rfl; cases n; · contradiction; rfl
#align formal_multilinear_series.id_apply_ne_one FormalMultilinearSeries.id_apply_ne_one
-/

end

#print FormalMultilinearSeries.comp_id /-
@[simp]
theorem comp_id (p : FormalMultilinearSeries 𝕜 E F) : p.comp (id 𝕜 E) = p :=
  by
  ext1 n
  dsimp [FormalMultilinearSeries.comp]
  rw [Finset.sum_eq_single (Composition.ones n)]
  show comp_along_composition p (id 𝕜 E) (Composition.ones n) = p n
  · ext v
    rw [comp_along_composition_apply]
    apply p.congr (Composition.ones_length n)
    intros
    rw [apply_composition_ones]
    refine' congr_arg v _
    rw [Fin.ext_iff, Fin.coe_castLE, Fin.val_mk, Fin.val_mk]
  show
    ∀ b : Composition n,
      b ∈ Finset.univ → b ≠ Composition.ones n → comp_along_composition p (id 𝕜 E) b = 0
  · intro b _ hb
    obtain ⟨k, hk, lt_k⟩ : ∃ (k : ℕ) (H : k ∈ Composition.blocks b), 1 < k :=
      Composition.ne_ones_iff.1 hb
    obtain ⟨i, i_lt, hi⟩ : ∃ (i : ℕ) (h : i < b.blocks.length), b.blocks.nth_le i h = k :=
      nth_le_of_mem hk
    let j : Fin b.length := ⟨i, b.blocks_length ▸ i_lt⟩
    have A : 1 < b.blocks_fun j := by convert lt_k
    ext v
    rw [comp_along_composition_apply, ContinuousMultilinearMap.zero_apply]
    apply ContinuousMultilinearMap.map_coord_zero _ j
    dsimp [apply_composition]
    rw [id_apply_ne_one _ _ (ne_of_gt A)]
    rfl
  · simp
#align formal_multilinear_series.comp_id FormalMultilinearSeries.comp_id
-/

#print FormalMultilinearSeries.id_comp /-
@[simp]
theorem id_comp (p : FormalMultilinearSeries 𝕜 E F) (h : p 0 = 0) : (id 𝕜 F).comp p = p :=
  by
  ext1 n
  by_cases hn : n = 0
  · rw [hn, h]
    ext v
    rw [comp_coeff_zero', id_apply_ne_one _ _ zero_ne_one]
    rfl
  · dsimp [FormalMultilinearSeries.comp]
    have n_pos : 0 < n := bot_lt_iff_ne_bot.mpr hn
    rw [Finset.sum_eq_single (Composition.single n n_pos)]
    show comp_along_composition (id 𝕜 F) p (Composition.single n n_pos) = p n
    · ext v
      rw [comp_along_composition_apply, id_apply_one' _ _ (Composition.single_length n_pos)]
      dsimp [apply_composition]
      refine' p.congr rfl fun i him hin => congr_arg v <| _
      ext; simp
    show
      ∀ b : Composition n,
        b ∈ Finset.univ → b ≠ Composition.single n n_pos → comp_along_composition (id 𝕜 F) p b = 0
    · intro b _ hb
      have A : b.length ≠ 1 := by simpa [Composition.eq_single_iff_length] using hb
      ext v
      rw [comp_along_composition_apply, id_apply_ne_one _ _ A]
      rfl
    · simp
#align formal_multilinear_series.id_comp FormalMultilinearSeries.id_comp
-/

/-! ### Summability properties of the composition of formal power series-/


section

#print FormalMultilinearSeries.comp_summable_nnreal /-
/-- If two formal multilinear series have positive radius of convergence, then the terms appearing
in the definition of their composition are also summable (when multiplied by a suitable positive
geometric term). -/
theorem comp_summable_nnreal (q : FormalMultilinearSeries 𝕜 F G) (p : FormalMultilinearSeries 𝕜 E F)
    (hq : 0 < q.radius) (hp : 0 < p.radius) :
    ∃ r > (0 : ℝ≥0),
      Summable fun i : Σ n, Composition n => ‖q.compAlongComposition p i.2‖₊ * r ^ i.1 :=
  by
  /- This follows from the fact that the growth rate of `‖qₙ‖` and `‖pₙ‖` is at most geometric,
    giving a geometric bound on each `‖q.comp_along_composition p op‖`, together with the
    fact that there are `2^(n-1)` compositions of `n`, giving at most a geometric loss. -/
  rcases ENNReal.lt_iff_exists_nnreal_btwn.1 (lt_min zero_lt_one hq) with ⟨rq, rq_pos, hrq⟩
  rcases ENNReal.lt_iff_exists_nnreal_btwn.1 (lt_min zero_lt_one hp) with ⟨rp, rp_pos, hrp⟩
  simp only [lt_min_iff, ENNReal.coe_lt_one_iff, ENNReal.coe_pos] at hrp hrq rp_pos rq_pos 
  obtain ⟨Cq, hCq0, hCq⟩ : ∃ Cq > 0, ∀ n, ‖q n‖₊ * rq ^ n ≤ Cq :=
    q.nnnorm_mul_pow_le_of_lt_radius hrq.2
  obtain ⟨Cp, hCp1, hCp⟩ : ∃ Cp ≥ 1, ∀ n, ‖p n‖₊ * rp ^ n ≤ Cp :=
    by
    rcases p.nnnorm_mul_pow_le_of_lt_radius hrp.2 with ⟨Cp, -, hCp⟩
    exact ⟨max Cp 1, le_max_right _ _, fun n => (hCp n).trans (le_max_left _ _)⟩
  let r0 : ℝ≥0 := (4 * Cp)⁻¹
  have r0_pos : 0 < r0 := inv_pos.2 (mul_pos zero_lt_four (zero_lt_one.trans_le hCp1))
  set r : ℝ≥0 := rp * rq * r0
  have r_pos : 0 < r := mul_pos (mul_pos rp_pos rq_pos) r0_pos
  have I :
    ∀ i : Σ n : ℕ, Composition n, ‖q.comp_along_composition p i.2‖₊ * r ^ i.1 ≤ Cq / 4 ^ i.1 :=
    by
    rintro ⟨n, c⟩
    have A
    calc
      ‖q c.length‖₊ * rq ^ n ≤ ‖q c.length‖₊ * rq ^ c.length :=
        mul_le_mul' le_rfl (pow_le_pow_of_le_one rq.2 hrq.1.le c.length_le)
      _ ≤ Cq := hCq _
    have B
    calc
      (∏ i, ‖p (c.blocks_fun i)‖₊) * rp ^ n = ∏ i, ‖p (c.blocks_fun i)‖₊ * rp ^ c.blocks_fun i := by
        simp only [Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum, c.sum_blocks_fun]
      _ ≤ ∏ i : Fin c.length, Cp := (Finset.prod_le_prod' fun i _ => hCp _)
      _ = Cp ^ c.length := by simp
      _ ≤ Cp ^ n := pow_le_pow hCp1 c.length_le
    calc
      ‖q.comp_along_composition p c‖₊ * r ^ n ≤
          (‖q c.length‖₊ * ∏ i, ‖p (c.blocks_fun i)‖₊) * r ^ n :=
        mul_le_mul' (q.comp_along_composition_nnnorm p c) le_rfl
      _ = ‖q c.length‖₊ * rq ^ n * ((∏ i, ‖p (c.blocks_fun i)‖₊) * rp ^ n) * r0 ^ n := by
        simp only [r, mul_pow]; ring
      _ ≤ Cq * Cp ^ n * r0 ^ n := (mul_le_mul' (mul_le_mul' A B) le_rfl)
      _ = Cq / 4 ^ n := by
        simp only [r0]
        field_simp [mul_pow, (zero_lt_one.trans_le hCp1).ne']
        ring
  refine' ⟨r, r_pos, NNReal.summable_of_le I _⟩
  simp_rw [div_eq_mul_inv]
  refine' Summable.mul_left _ _
  have : ∀ n : ℕ, HasSum (fun c : Composition n => (4 ^ n : ℝ≥0)⁻¹) (2 ^ (n - 1) / 4 ^ n) :=
    by
    intro n
    convert hasSum_fintype fun c : Composition n => (4 ^ n : ℝ≥0)⁻¹
    simp [Finset.card_univ, composition_card, div_eq_mul_inv]
  refine' NNReal.summable_sigma.2 ⟨fun n => (this n).Summable, (NNReal.summable_nat_add_iff 1).1 _⟩
  convert (NNReal.summable_geometric (NNReal.div_lt_one_of_lt one_lt_two)).mul_left (1 / 4)
  ext1 n
  rw [(this _).tsum_eq, add_tsub_cancel_right]
  field_simp [← mul_assoc, pow_succ', mul_pow, show (4 : ℝ≥0) = 2 * 2 from (two_mul 2).symm,
    mul_right_comm]
#align formal_multilinear_series.comp_summable_nnreal FormalMultilinearSeries.comp_summable_nnreal
-/

end

#print FormalMultilinearSeries.le_comp_radius_of_summable /-
/-- Bounding below the radius of the composition of two formal multilinear series assuming
summability over all compositions. -/
theorem le_comp_radius_of_summable (q : FormalMultilinearSeries 𝕜 F G)
    (p : FormalMultilinearSeries 𝕜 E F) (r : ℝ≥0)
    (hr : Summable fun i : Σ n, Composition n => ‖q.compAlongComposition p i.2‖₊ * r ^ i.1) :
    (r : ℝ≥0∞) ≤ (q.comp p).radius :=
  by
  refine'
    le_radius_of_bound_nnreal _
      (∑' i : Σ n, Composition n, ‖comp_along_composition q p i.snd‖₊ * r ^ i.fst) fun n => _
  calc
    ‖FormalMultilinearSeries.comp q p n‖₊ * r ^ n ≤
        ∑' c : Composition n, ‖comp_along_composition q p c‖₊ * r ^ n :=
      by
      rw [tsum_fintype, ← Finset.sum_mul]
      exact mul_le_mul' (nnnorm_sum_le _ _) le_rfl
    _ ≤ ∑' i : Σ n : ℕ, Composition n, ‖comp_along_composition q p i.snd‖₊ * r ^ i.fst :=
      NNReal.tsum_comp_le_tsum_of_inj hr sigma_mk_injective
#align formal_multilinear_series.le_comp_radius_of_summable FormalMultilinearSeries.le_comp_radius_of_summable
-/

/-!
### Composing analytic functions

Now, we will prove that the composition of the partial sums of `q` and `p` up to order `N` is
given by a sum over some large subset of `Σ n, composition n` of `q.comp_along_composition p`, to
deduce that the series for `q.comp p` indeed converges to `g ∘ f` when `q` is a power series for
`g` and `p` is a power series for `f`.

This proof is a big reindexing argument of a sum. Since it is a bit involved, we define first
the source of the change of variables (`comp_partial_source`), its target
(`comp_partial_target`) and the change of variables itself (`comp_change_of_variables`) before
giving the main statement in `comp_partial_sum`. -/


#print FormalMultilinearSeries.compPartialSumSource /-
/-- Source set in the change of variables to compute the composition of partial sums of formal
power series.
See also `comp_partial_sum`. -/
def compPartialSumSource (m M N : ℕ) : Finset (Σ n, Fin n → ℕ) :=
  Finset.sigma (Finset.Ico m M) (fun n : ℕ => Fintype.piFinset fun i : Fin n => Finset.Ico 1 N : _)
#align formal_multilinear_series.comp_partial_sum_source FormalMultilinearSeries.compPartialSumSource
-/

#print FormalMultilinearSeries.mem_compPartialSumSource_iff /-
@[simp]
theorem mem_compPartialSumSource_iff (m M N : ℕ) (i : Σ n, Fin n → ℕ) :
    i ∈ compPartialSumSource m M N ↔ (m ≤ i.1 ∧ i.1 < M) ∧ ∀ a : Fin i.1, 1 ≤ i.2 a ∧ i.2 a < N :=
  by
  simp only [comp_partial_sum_source, Finset.mem_Ico, Fintype.mem_piFinset, Finset.mem_sigma,
    iff_self_iff]
#align formal_multilinear_series.mem_comp_partial_sum_source_iff FormalMultilinearSeries.mem_compPartialSumSource_iff
-/

#print FormalMultilinearSeries.compChangeOfVariables /-
/-- Change of variables appearing to compute the composition of partial sums of formal
power series -/
def compChangeOfVariables (m M N : ℕ) (i : Σ n, Fin n → ℕ) (hi : i ∈ compPartialSumSource m M N) :
    Σ n, Composition n := by
  rcases i with ⟨n, f⟩
  rw [mem_comp_partial_sum_source_iff] at hi 
  refine' ⟨∑ j, f j, of_fn fun a => f a, fun i hi' => _, by simp [sum_of_fn]⟩
  obtain ⟨j, rfl⟩ : ∃ j : Fin n, f j = i := by rwa [mem_of_fn, Set.mem_range] at hi' 
  exact (hi.2 j).1
#align formal_multilinear_series.comp_change_of_variables FormalMultilinearSeries.compChangeOfVariables
-/

#print FormalMultilinearSeries.compChangeOfVariables_length /-
@[simp]
theorem compChangeOfVariables_length (m M N : ℕ) {i : Σ n, Fin n → ℕ}
    (hi : i ∈ compPartialSumSource m M N) :
    Composition.length (compChangeOfVariables m M N i hi).2 = i.1 :=
  by
  rcases i with ⟨k, blocks_fun⟩
  dsimp [comp_change_of_variables]
  simp only [Composition.length, map_of_fn, length_of_fn]
#align formal_multilinear_series.comp_change_of_variables_length FormalMultilinearSeries.compChangeOfVariables_length
-/

#print FormalMultilinearSeries.compChangeOfVariables_blocksFun /-
theorem compChangeOfVariables_blocksFun (m M N : ℕ) {i : Σ n, Fin n → ℕ}
    (hi : i ∈ compPartialSumSource m M N) (j : Fin i.1) :
    (compChangeOfVariables m M N i hi).2.blocksFun
        ⟨j, (compChangeOfVariables_length m M N hi).symm ▸ j.2⟩ =
      i.2 j :=
  by
  rcases i with ⟨n, f⟩
  dsimp [Composition.blocksFun, Composition.blocks, comp_change_of_variables]
  simp only [map_of_fn, nth_le_of_fn', Function.comp_apply]
  apply congr_arg
  exact Fin.eta _ _
#align formal_multilinear_series.comp_change_of_variables_blocks_fun FormalMultilinearSeries.compChangeOfVariables_blocksFun
-/

#print FormalMultilinearSeries.compPartialSumTargetSet /-
/-- Target set in the change of variables to compute the composition of partial sums of formal
power series, here given a a set. -/
def compPartialSumTargetSet (m M N : ℕ) : Set (Σ n, Composition n) :=
  {i | m ≤ i.2.length ∧ i.2.length < M ∧ ∀ j : Fin i.2.length, i.2.blocksFun j < N}
#align formal_multilinear_series.comp_partial_sum_target_set FormalMultilinearSeries.compPartialSumTargetSet
-/

#print FormalMultilinearSeries.compPartialSumTargetSet_image_compPartialSumSource /-
theorem compPartialSumTargetSet_image_compPartialSumSource (m M N : ℕ) (i : Σ n, Composition n)
    (hi : i ∈ compPartialSumTargetSet m M N) :
    ∃ (j : _) (hj : j ∈ compPartialSumSource m M N), i = compChangeOfVariables m M N j hj :=
  by
  rcases i with ⟨n, c⟩
  refine' ⟨⟨c.length, c.blocks_fun⟩, _, _⟩
  · simp only [comp_partial_sum_target_set, Set.mem_setOf_eq] at hi 
    simp only [mem_comp_partial_sum_source_iff, hi.left, hi.right, true_and_iff, and_true_iff]
    exact fun a => c.one_le_blocks' _
  · dsimp [comp_change_of_variables]
    rw [Composition.sigma_eq_iff_blocks_eq]
    simp only [Composition.blocksFun, Composition.blocks, Subtype.coe_eta, nth_le_map']
    conv_lhs => rw [← of_fn_nth_le c.blocks]
#align formal_multilinear_series.comp_partial_sum_target_subset_image_comp_partial_sum_source FormalMultilinearSeries.compPartialSumTargetSet_image_compPartialSumSource
-/

#print FormalMultilinearSeries.compPartialSumTarget /-
/-- Target set in the change of variables to compute the composition of partial sums of formal
power series, here given a a finset.
See also `comp_partial_sum`. -/
def compPartialSumTarget (m M N : ℕ) : Finset (Σ n, Composition n) :=
  Set.Finite.toFinset <|
    ((Finset.finite_toSet _).dependent_image _).Subset <|
      compPartialSumTargetSet_image_compPartialSumSource m M N
#align formal_multilinear_series.comp_partial_sum_target FormalMultilinearSeries.compPartialSumTarget
-/

#print FormalMultilinearSeries.mem_compPartialSumTarget_iff /-
@[simp]
theorem mem_compPartialSumTarget_iff {m M N : ℕ} {a : Σ n, Composition n} :
    a ∈ compPartialSumTarget m M N ↔
      m ≤ a.2.length ∧ a.2.length < M ∧ ∀ j : Fin a.2.length, a.2.blocksFun j < N :=
  by simp [comp_partial_sum_target, comp_partial_sum_target_set]
#align formal_multilinear_series.mem_comp_partial_sum_target_iff FormalMultilinearSeries.mem_compPartialSumTarget_iff
-/

#print FormalMultilinearSeries.compChangeOfVariables_sum /-
/-- `comp_change_of_variables m M N` is a bijection between `comp_partial_sum_source m M N`
and `comp_partial_sum_target m M N`, yielding equal sums for functions that correspond to each
other under the bijection. As `comp_change_of_variables m M N` is a dependent function, stating
that it is a bijection is not directly possible, but the consequence on sums can be stated
more easily. -/
theorem compChangeOfVariables_sum {α : Type _} [AddCommMonoid α] (m M N : ℕ)
    (f : (Σ n : ℕ, Fin n → ℕ) → α) (g : (Σ n, Composition n) → α)
    (h : ∀ (e) (he : e ∈ compPartialSumSource m M N), f e = g (compChangeOfVariables m M N e he)) :
    ∑ e in compPartialSumSource m M N, f e = ∑ e in compPartialSumTarget m M N, g e :=
  by
  apply Finset.sum_bij (comp_change_of_variables m M N)
  -- We should show that the correspondance we have set up is indeed a bijection
  -- between the index sets of the two sums.
  -- 1 - show that the image belongs to `comp_partial_sum_target m N N`
  · rintro ⟨k, blocks_fun⟩ H
    rw [mem_comp_partial_sum_source_iff] at H 
    simp only [mem_comp_partial_sum_target_iff, Composition.length, Composition.blocks, H.left,
      map_of_fn, length_of_fn, true_and_iff, comp_change_of_variables]
    intro j
    simp only [Composition.blocksFun, (H.right _).right, nth_le_of_fn']
  -- 2 - show that the composition gives the `comp_along_composition` application
  · rintro ⟨k, blocks_fun⟩ H
    rw [h]
  -- 3 - show that the map is injective
  · rintro ⟨k, blocks_fun⟩ ⟨k', blocks_fun'⟩ H H' heq
    obtain rfl : k = k' :=
      by
      have := (comp_change_of_variables_length m M N H).symm
      rwa [HEq, comp_change_of_variables_length] at this 
    congr
    funext i
    calc
      blocks_fun i = (comp_change_of_variables m M N _ H).2.blocksFun _ :=
        (comp_change_of_variables_blocks_fun m M N H i).symm
      _ = (comp_change_of_variables m M N _ H').2.blocksFun _ :=
        by
        apply Composition.blocksFun_congr <;> try rw [HEq]
        rfl
      _ = blocks_fun' i := comp_change_of_variables_blocks_fun m M N H' i
  -- 4 - show that the map is surjective
  · intro i hi
    apply comp_partial_sum_target_subset_image_comp_partial_sum_source m M N i
    simpa [comp_partial_sum_target] using hi
#align formal_multilinear_series.comp_change_of_variables_sum FormalMultilinearSeries.compChangeOfVariables_sum
-/

#print FormalMultilinearSeries.compPartialSumTarget_tendsto_atTop /-
/-- The auxiliary set corresponding to the composition of partial sums asymptotically contains
all possible compositions. -/
theorem compPartialSumTarget_tendsto_atTop :
    Tendsto (fun N => compPartialSumTarget 0 N N) atTop atTop :=
  by
  apply Monotone.tendsto_atTop_finset
  · intro m n hmn a ha
    have : ∀ i, i < m → i < n := fun i hi => lt_of_lt_of_le hi hmn
    tidy
  · rintro ⟨n, c⟩
    simp only [mem_comp_partial_sum_target_iff]
    obtain ⟨n, hn⟩ : BddAbove ↑(finset.univ.image fun i : Fin c.length => c.blocks_fun i) :=
      Finset.bddAbove _
    refine'
      ⟨max n c.length + 1, bot_le, lt_of_le_of_lt (le_max_right n c.length) (lt_add_one _), fun j =>
        lt_of_le_of_lt (le_trans _ (le_max_left _ _)) (lt_add_one _)⟩
    apply hn
    simp only [Finset.mem_image_of_mem, Finset.mem_coe, Finset.mem_univ]
#align formal_multilinear_series.comp_partial_sum_target_tendsto_at_top FormalMultilinearSeries.compPartialSumTarget_tendsto_atTop
-/

#print FormalMultilinearSeries.comp_partialSum /-
/-- Composing the partial sums of two multilinear series coincides with the sum over all
compositions in `comp_partial_sum_target 0 N N`. This is precisely the motivation for the
definition of `comp_partial_sum_target`. -/
theorem comp_partialSum (q : FormalMultilinearSeries 𝕜 F G) (p : FormalMultilinearSeries 𝕜 E F)
    (N : ℕ) (z : E) :
    q.partialSum N (∑ i in Finset.Ico 1 N, p i fun j => z) =
      ∑ i in compPartialSumTarget 0 N N, q.compAlongComposition p i.2 fun j => z :=
  by
  -- we expand the composition, using the multilinearity of `q` to expand along each coordinate.
  suffices H :
    (∑ n in Finset.range N,
        ∑ r in Fintype.piFinset fun i : Fin n => Finset.Ico 1 N,
          q n fun i : Fin n => p (r i) fun j => z) =
      ∑ i in comp_partial_sum_target 0 N N, q.comp_along_composition p i.2 fun j => z
  · simpa only [FormalMultilinearSeries.partialSum, ContinuousMultilinearMap.map_sum_finset] using H
  -- rewrite the first sum as a big sum over a sigma type, in the finset
  -- `comp_partial_sum_target 0 N N`
  rw [Finset.range_eq_Ico, Finset.sum_sigma']
  -- use `comp_change_of_variables_sum`, saying that this change of variables respects sums
  apply comp_change_of_variables_sum 0 N N
  rintro ⟨k, blocks_fun⟩ H
  apply congr _ (comp_change_of_variables_length 0 N N H).symm
  intros
  rw [← comp_change_of_variables_blocks_fun 0 N N H]
  rfl
#align formal_multilinear_series.comp_partial_sum FormalMultilinearSeries.comp_partialSum
-/

end FormalMultilinearSeries

open FormalMultilinearSeries

#print HasFPowerSeriesAt.comp /-
/-- If two functions `g` and `f` have power series `q` and `p` respectively at `f x` and `x`, then
`g ∘ f` admits the power series `q.comp p` at `x`. -/
theorem HasFPowerSeriesAt.comp {g : F → G} {f : E → F} {q : FormalMultilinearSeries 𝕜 F G}
    {p : FormalMultilinearSeries 𝕜 E F} {x : E} (hg : HasFPowerSeriesAt g q (f x))
    (hf : HasFPowerSeriesAt f p x) : HasFPowerSeriesAt (g ∘ f) (q.comp p) x :=
  by
  /- Consider `rf` and `rg` such that `f` and `g` have power series expansion on the disks
    of radius `rf` and `rg`. -/
  rcases hg with ⟨rg, Hg⟩
  rcases hf with ⟨rf, Hf⟩
  -- The terms defining `q.comp p` are geometrically summable in a disk of some radius `r`.
  rcases q.comp_summable_nnreal p Hg.radius_pos Hf.radius_pos with ⟨r, r_pos : 0 < r, hr⟩
  /- We will consider `y` which is smaller than `r` and `rf`, and also small enough that
    `f (x + y)` is close enough to `f x` to be in the disk where `g` is well behaved. Let
    `min (r, rf, δ)` be this new radius.-/
  have : ContinuousAt f x := Hf.analytic_at.continuous_at
  obtain ⟨δ, δpos, hδ⟩ :
    ∃ (δ : ℝ≥0∞) (H : 0 < δ), ∀ {z : E}, z ∈ EMetric.ball x δ → f z ∈ EMetric.ball (f x) rg :=
    by
    have : EMetric.ball (f x) rg ∈ 𝓝 (f x) := EMetric.ball_mem_nhds _ Hg.r_pos
    rcases EMetric.mem_nhds_iff.1 (Hf.analytic_at.continuous_at this) with ⟨δ, δpos, Hδ⟩
    exact ⟨δ, δpos, fun z hz => Hδ hz⟩
  let rf' := min rf δ
  have min_pos : 0 < min rf' r := by
    simp only [r_pos, Hf.r_pos, δpos, lt_min_iff, ENNReal.coe_pos, and_self_iff]
  /- We will show that `g ∘ f` admits the power series `q.comp p` in the disk of
    radius `min (r, rf', δ)`. -/
  refine' ⟨min rf' r, _⟩
  refine'
    ⟨le_trans (min_le_right rf' r) (FormalMultilinearSeries.le_comp_radius_of_summable q p r hr),
      min_pos, fun y hy => _⟩
  /- Let `y` satisfy `‖y‖ < min (r, rf', δ)`. We want to show that `g (f (x + y))` is the sum of
    `q.comp p` applied to `y`. -/
  -- First, check that `y` is small enough so that estimates for `f` and `g` apply.
  have y_mem : y ∈ EMetric.ball (0 : E) rf :=
    (EMetric.ball_subset_ball (le_trans (min_le_left _ _) (min_le_left _ _))) hy
  have fy_mem : f (x + y) ∈ EMetric.ball (f x) rg :=
    by
    apply hδ
    have : y ∈ EMetric.ball (0 : E) δ :=
      (EMetric.ball_subset_ball (le_trans (min_le_left _ _) (min_le_right _ _))) hy
    simpa [edist_eq_coe_nnnorm_sub, edist_eq_coe_nnnorm]
  /- Now the proof starts. To show that the sum of `q.comp p` at `y` is `g (f (x + y))`, we will
    write `q.comp p` applied to `y` as a big sum over all compositions. Since the sum is
    summable, to get its convergence it suffices to get the convergence along some increasing sequence
    of sets. We will use the sequence of sets `comp_partial_sum_target 0 n n`, along which the sum is
    exactly the composition of the partial sums of `q` and `p`, by design. To show that it converges
    to `g (f (x + y))`, pointwise convergence would not be enough, but we have uniform convergence
    to save the day. -/
  -- First step: the partial sum of `p` converges to `f (x + y)`.
  have A : tendsto (fun n => ∑ a in Finset.Ico 1 n, p a fun b => y) at_top (𝓝 (f (x + y) - f x)) :=
    by
    have L :
      ∀ᶠ n in at_top,
        (∑ a in Finset.range n, p a fun b => y) - f x = ∑ a in Finset.Ico 1 n, p a fun b => y :=
      by
      rw [eventually_at_top]
      refine' ⟨1, fun n hn => _⟩
      symm
      rw [eq_sub_iff_add_eq', Finset.range_eq_Ico, ← Hf.coeff_zero fun i => y,
        Finset.sum_eq_sum_Ico_succ_bot hn]
    have :
      tendsto (fun n => (∑ a in Finset.range n, p a fun b => y) - f x) at_top
        (𝓝 (f (x + y) - f x)) :=
      (Hf.has_sum y_mem).tendsto_sum_nat.sub tendsto_const_nhds
    exact tendsto.congr' L this
  -- Second step: the composition of the partial sums of `q` and `p` converges to `g (f (x + y))`.
  have B :
    tendsto (fun n => q.partial_sum n (∑ a in Finset.Ico 1 n, p a fun b => y)) at_top
      (𝓝 (g (f (x + y)))) :=
    by
    -- we use the fact that the partial sums of `q` converge locally uniformly to `g`, and that
    -- composition passes to the limit under locally uniform convergence.
    have B₁ : ContinuousAt (fun z : F => g (f x + z)) (f (x + y) - f x) :=
      by
      refine' ContinuousAt.comp _ (continuous_const.add continuous_id).ContinuousAt
      simp only [add_sub_cancel'_right, id.def]
      exact Hg.continuous_on.continuous_at (IsOpen.mem_nhds EMetric.isOpen_ball fy_mem)
    have B₂ : f (x + y) - f x ∈ EMetric.ball (0 : F) rg := by
      simpa [edist_eq_coe_nnnorm, edist_eq_coe_nnnorm_sub] using fy_mem
    rw [← emetric.is_open_ball.nhds_within_eq B₂] at A 
    convert Hg.tendsto_locally_uniformly_on.tendsto_comp B₁.continuous_within_at B₂ A
    simp only [add_sub_cancel'_right]
  -- Third step: the sum over all compositions in `comp_partial_sum_target 0 n n` converges to
  -- `g (f (x + y))`. As this sum is exactly the composition of the partial sum, this is a direct
  -- consequence of the second step
  have C :
    tendsto
      (fun n => ∑ i in comp_partial_sum_target 0 n n, q.comp_along_composition p i.2 fun j => y)
      at_top (𝓝 (g (f (x + y)))) :=
    by simpa [comp_partial_sum] using B
  -- Fourth step: the sum over all compositions is `g (f (x + y))`. This follows from the
  -- convergence along a subsequence proved in the third step, and the fact that the sum is Cauchy
  -- thanks to the summability properties.
  have D :
    HasSum (fun i : Σ n, Composition n => q.comp_along_composition p i.2 fun j => y)
      (g (f (x + y))) :=
    haveI cau :
      CauchySeq fun s : Finset (Σ n, Composition n) =>
        ∑ i in s, q.comp_along_composition p i.2 fun j => y :=
      by
      apply cauchySeq_finset_of_norm_bounded _ (NNReal.summable_coe.2 hr) _
      simp only [coe_nnnorm, NNReal.coe_mul, NNReal.coe_pow]
      rintro ⟨n, c⟩
      calc
        ‖(comp_along_composition q p c) fun j : Fin n => y‖ ≤
            ‖comp_along_composition q p c‖ * ∏ j : Fin n, ‖y‖ :=
          by apply ContinuousMultilinearMap.le_op_norm
        _ ≤ ‖comp_along_composition q p c‖ * (r : ℝ) ^ n :=
          by
          apply mul_le_mul_of_nonneg_left _ (norm_nonneg _)
          rw [Finset.prod_const, Finset.card_fin]
          apply pow_le_pow_of_le_left (norm_nonneg _)
          rw [EMetric.mem_ball, edist_eq_coe_nnnorm] at hy 
          have := le_trans (le_of_lt hy) (min_le_right _ _)
          rwa [ENNReal.coe_le_coe, ← NNReal.coe_le_coe, coe_nnnorm] at this 
    tendsto_nhds_of_cauchySeq_of_subseq cau comp_partial_sum_target_tendsto_at_top C
  -- Fifth step: the sum over `n` of `q.comp p n` can be expressed as a particular resummation of
  -- the sum over all compositions, by grouping together the compositions of the same
  -- integer `n`. The convergence of the whole sum therefore implies the converence of the sum
  -- of `q.comp p n`
  have E : HasSum (fun n => (q.comp p) n fun j => y) (g (f (x + y))) :=
    by
    apply D.sigma
    intro n
    dsimp [FormalMultilinearSeries.comp]
    convert hasSum_fintype _
    simp only [ContinuousMultilinearMap.sum_apply]
    rfl
  exact E
#align has_fpower_series_at.comp HasFPowerSeriesAt.comp
-/

#print AnalyticAt.comp /-
/-- If two functions `g` and `f` are analytic respectively at `f x` and `x`, then `g ∘ f` is
analytic at `x`. -/
theorem AnalyticAt.comp {g : F → G} {f : E → F} {x : E} (hg : AnalyticAt 𝕜 g (f x))
    (hf : AnalyticAt 𝕜 f x) : AnalyticAt 𝕜 (g ∘ f) x :=
  let ⟨q, hq⟩ := hg
  let ⟨p, hp⟩ := hf
  (hq.comp hp).AnalyticAt
#align analytic_at.comp AnalyticAt.comp
-/

/-!
### Associativity of the composition of formal multilinear series

In this paragraph, we prove the associativity of the composition of formal power series.
By definition,
```
(r.comp q).comp p n v
= ∑_{i₁ + ... + iₖ = n} (r.comp q)ₖ (p_{i₁} (v₀, ..., v_{i₁ -1}), p_{i₂} (...), ..., p_{iₖ}(...))
= ∑_{a : composition n} (r.comp q) a.length (apply_composition p a v)
```
decomposing `r.comp q` in the same way, we get
```
(r.comp q).comp p n v
= ∑_{a : composition n} ∑_{b : composition a.length}
  r b.length (apply_composition q b (apply_composition p a v))
```
On the other hand,
```
r.comp (q.comp p) n v = ∑_{c : composition n} r c.length (apply_composition (q.comp p) c v)
```
Here, `apply_composition (q.comp p) c v` is a vector of length `c.length`, whose `i`-th term is
given by `(q.comp p) (c.blocks_fun i) (v_l, v_{l+1}, ..., v_{m-1})` where `{l, ..., m-1}` is the
`i`-th block in the composition `c`, of length `c.blocks_fun i` by definition. To compute this term,
we expand it as `∑_{dᵢ : composition (c.blocks_fun i)} q dᵢ.length (apply_composition p dᵢ v')`,
where `v' = (v_l, v_{l+1}, ..., v_{m-1})`. Therefore, we get
```
r.comp (q.comp p) n v =
∑_{c : composition n} ∑_{d₀ : composition (c.blocks_fun 0),
  ..., d_{c.length - 1} : composition (c.blocks_fun (c.length - 1))}
  r c.length (λ i, q dᵢ.length (apply_composition p dᵢ v'ᵢ))
```
To show that these terms coincide, we need to explain how to reindex the sums to put them in
bijection (and then the terms we are summing will correspond to each other). Suppose we have a
composition `a` of `n`, and a composition `b` of `a.length`. Then `b` indicates how to group
together some blocks of `a`, giving altogether `b.length` blocks of blocks. These blocks of blocks
can be called `d₀, ..., d_{a.length - 1}`, and one obtains a composition `c` of `n` by saying that
each `dᵢ` is one single block. Conversely, if one starts from `c` and the `dᵢ`s, one can concatenate
the `dᵢ`s to obtain a composition `a` of `n`, and register the lengths of the `dᵢ`s in a composition
`b` of `a.length`.

An example might be enlightening. Suppose `a = [2, 2, 3, 4, 2]`. It is a composition of
length 5 of 13. The content of the blocks may be represented as `0011222333344`.
Now take `b = [2, 3]` as a composition of `a.length = 5`. It says that the first 2 blocks of `a`
should be merged, and the last 3 blocks of `a` should be merged, giving a new composition of `13`
made of two blocks of length `4` and `9`, i.e., `c = [4, 9]`. But one can also remember that
the new first block was initially made of two blocks of size `2`, so `d₀ = [2, 2]`, and the new
second block was initially made of three blocks of size `3`, `4` and `2`, so `d₁ = [3, 4, 2]`.

This equivalence is called `composition.sigma_equiv_sigma_pi n` below.

We start with preliminary results on compositions, of a very specialized nature, then define the
equivalence `composition.sigma_equiv_sigma_pi n`, and we deduce finally the associativity of
composition of formal multilinear series in `formal_multilinear_series.comp_assoc`.
-/


namespace Composition

variable {n : ℕ}

#print Composition.sigma_composition_eq_iff /-
/-- Rewriting equality in the dependent type `Σ (a : composition n), composition a.length)` in
non-dependent terms with lists, requiring that the blocks coincide. -/
theorem sigma_composition_eq_iff (i j : Σ a : Composition n, Composition a.length) :
    i = j ↔ i.1.blocks = j.1.blocks ∧ i.2.blocks = j.2.blocks :=
  by
  refine' ⟨by rintro rfl <;> exact ⟨rfl, rfl⟩, _⟩
  rcases i with ⟨a, b⟩
  rcases j with ⟨a', b'⟩
  rintro ⟨h, h'⟩
  have H : a = a' := by ext1; exact h
  induction H; congr; ext1; exact h'
#align composition.sigma_composition_eq_iff Composition.sigma_composition_eq_iff
-/

#print Composition.sigma_pi_composition_eq_iff /-
/-- Rewriting equality in the dependent type
`Σ (c : composition n), Π (i : fin c.length), composition (c.blocks_fun i)` in
non-dependent terms with lists, requiring that the lists of blocks coincide. -/
theorem sigma_pi_composition_eq_iff
    (u v : Σ c : Composition n, ∀ i : Fin c.length, Composition (c.blocksFun i)) :
    u = v ↔ (ofFn fun i => (u.2 i).blocks) = ofFn fun i => (v.2 i).blocks :=
  by
  refine' ⟨fun H => by rw [H], fun H => _⟩
  rcases u with ⟨a, b⟩
  rcases v with ⟨a', b'⟩
  dsimp at H 
  have h : a = a' := by
    ext1
    have :
      map List.sum (of_fn fun i : Fin (Composition.length a) => (b i).blocks) =
        map List.sum (of_fn fun i : Fin (Composition.length a') => (b' i).blocks) :=
      by rw [H]
    simp only [map_of_fn] at this 
    change
      (of_fn fun i : Fin (Composition.length a) => (b i).blocks.Sum) =
        of_fn fun i : Fin (Composition.length a') => (b' i).blocks.Sum at
      this 
    simpa [Composition.blocks_sum, Composition.ofFn_blocksFun] using this
  induction h
  simp only [true_and_iff, eq_self_iff_true, heq_iff_eq]
  ext i : 2
  have :
    nth_le (of_fn fun i : Fin (Composition.length a) => (b i).blocks) i (by simp [i.is_lt]) =
      nth_le (of_fn fun i : Fin (Composition.length a) => (b' i).blocks) i (by simp [i.is_lt]) :=
    nth_le_of_eq H _
  rwa [nth_le_of_fn, nth_le_of_fn] at this 
#align composition.sigma_pi_composition_eq_iff Composition.sigma_pi_composition_eq_iff
-/

#print Composition.gather /-
/-- When `a` is a composition of `n` and `b` is a composition of `a.length`, `a.gather b` is the
composition of `n` obtained by gathering all the blocks of `a` corresponding to a block of `b`.
For instance, if `a = [6, 5, 3, 5, 2]` and `b = [2, 3]`, one should gather together
the first two blocks of `a` and its last three blocks, giving `a.gather b = [11, 10]`. -/
def gather (a : Composition n) (b : Composition a.length) : Composition n
    where
  blocks := (a.blocks.splitWrtComposition b).map Sum
  blocks_pos := by
    rw [forall_mem_map_iff]
    intro j hj
    suffices H : ∀ i ∈ j, 1 ≤ i;
    exact
      calc
        0 < j.length := length_pos_of_mem_split_wrt_composition hj
        _ ≤ j.sum := length_le_sum_of_one_le _ H
    intro i hi
    apply a.one_le_blocks
    rw [← a.blocks.join_split_wrt_composition b]
    exact mem_join_of_mem hj hi
  blocks_sum := by rw [← sum_join, join_split_wrt_composition, a.blocks_sum]
#align composition.gather Composition.gather
-/

#print Composition.length_gather /-
theorem length_gather (a : Composition n) (b : Composition a.length) :
    length (a.gather b) = b.length :=
  show (map List.sum (a.blocks.splitWrtComposition b)).length = b.blocks.length by
    rw [length_map, length_split_wrt_composition]
#align composition.length_gather Composition.length_gather
-/

#print Composition.sigmaCompositionAux /-
/-- An auxiliary function used in the definition of `sigma_equiv_sigma_pi` below, associating to
two compositions `a` of `n` and `b` of `a.length`, and an index `i` bounded by the length of
`a.gather b`, the subcomposition of `a` made of those blocks belonging to the `i`-th block of
`a.gather b`. -/
def sigmaCompositionAux (a : Composition n) (b : Composition a.length)
    (i : Fin (a.gather b).length) : Composition ((a.gather b).blocksFun i)
    where
  blocks :=
    nthLe (a.blocks.splitWrtComposition b) i
      (by rw [length_split_wrt_composition, ← length_gather]; exact i.2)
  blocks_pos i hi :=
    a.blocks_pos
      (by
        rw [← a.blocks.join_split_wrt_composition b]
        exact mem_join_of_mem (nth_le_mem _ _ _) hi)
  blocks_sum := by simp only [Composition.blocksFun, nth_le_map', Composition.gather]
#align composition.sigma_composition_aux Composition.sigmaCompositionAux
-/

#print Composition.length_sigmaCompositionAux /-
theorem length_sigmaCompositionAux (a : Composition n) (b : Composition a.length)
    (i : Fin b.length) :
    Composition.length (Composition.sigmaCompositionAux a b ⟨i, (length_gather a b).symm ▸ i.2⟩) =
      Composition.blocksFun b i :=
  show List.length (nthLe (splitWrtComposition a.blocks b) i _) = blocksFun b i by
    rw [nth_le_map_rev List.length, nth_le_of_eq (map_length_split_wrt_composition _ _)]; rfl
#align composition.length_sigma_composition_aux Composition.length_sigmaCompositionAux
-/

#print Composition.blocksFun_sigmaCompositionAux /-
theorem blocksFun_sigmaCompositionAux (a : Composition n) (b : Composition a.length)
    (i : Fin b.length) (j : Fin (blocksFun b i)) :
    blocksFun (sigmaCompositionAux a b ⟨i, (length_gather a b).symm ▸ i.2⟩)
        ⟨j, (length_sigmaCompositionAux a b i).symm ▸ j.2⟩ =
      blocksFun a (embedding b i j) :=
  show nthLe (nthLe _ _ _) _ _ = nthLe a.blocks _ _ by
    rw [nth_le_of_eq (nth_le_split_wrt_composition _ _ _), nth_le_drop', nth_le_take']; rfl
#align composition.blocks_fun_sigma_composition_aux Composition.blocksFun_sigmaCompositionAux
-/

#print Composition.sizeUpTo_sizeUpTo_add /-
/-- Auxiliary lemma to prove that the composition of formal multilinear series is associative.

Consider a composition `a` of `n` and a composition `b` of `a.length`. Grouping together some
blocks of `a` according to `b` as in `a.gather b`, one can compute the total size of the blocks
of `a` up to an index `size_up_to b i + j` (where the `j` corresponds to a set of blocks of `a`
that do not fill a whole block of `a.gather b`). The first part corresponds to a sum of blocks
in `a.gather b`, and the second one to a sum of blocks in the next block of
`sigma_composition_aux a b`. This is the content of this lemma. -/
theorem sizeUpTo_sizeUpTo_add (a : Composition n) (b : Composition a.length) {i j : ℕ}
    (hi : i < b.length) (hj : j < blocksFun b ⟨i, hi⟩) :
    sizeUpTo a (sizeUpTo b i + j) =
      sizeUpTo (a.gather b) i +
        sizeUpTo (sigmaCompositionAux a b ⟨i, (length_gather a b).symm ▸ hi⟩) j :=
  by
  induction' j with j IHj
  · show
      Sum (take (b.blocks.take i).Sum a.blocks) =
        Sum (take i (map Sum (split_wrt_composition a.blocks b)))
    induction' i with i IH
    · rfl
    · have A : i < b.length := Nat.lt_of_succ_lt hi
      have B : i < List.length (map List.sum (split_wrt_composition a.blocks b)) := by simp [A]
      have C : 0 < blocks_fun b ⟨i, A⟩ := Composition.blocks_pos' _ _ _
      rw [sum_take_succ _ _ B, ← IH A C]
      have :
        take (Sum (take i b.blocks)) a.blocks =
          take (Sum (take i b.blocks)) (take (Sum (take (i + 1) b.blocks)) a.blocks) :=
        by
        rw [take_take, min_eq_left]
        apply monotone_sum_take _ (Nat.le_succ _)
      rw [this, nth_le_map', nth_le_split_wrt_composition, ←
        take_append_drop (Sum (take i b.blocks)) (take (Sum (take (Nat.succ i) b.blocks)) a.blocks),
        sum_append]
      congr
      rw [take_append_drop]
  · have A : j < blocks_fun b ⟨i, hi⟩ := lt_trans (lt_add_one j) hj
    have B : j < length (sigma_composition_aux a b ⟨i, (length_gather a b).symm ▸ hi⟩) := by
      convert A; rw [← length_sigma_composition_aux]; rfl
    have C : size_up_to b i + j < size_up_to b (i + 1) :=
      by
      simp only [size_up_to_succ b hi, add_lt_add_iff_left]
      exact A
    have D : size_up_to b i + j < length a := lt_of_lt_of_le C (b.size_up_to_le _)
    have : size_up_to b i + Nat.succ j = (size_up_to b i + j).succ := rfl
    rw [this, size_up_to_succ _ D, IHj A, size_up_to_succ _ B]
    simp only [sigma_composition_aux, add_assoc, add_left_inj, Fin.val_mk]
    rw [nth_le_of_eq (nth_le_split_wrt_composition _ _ _), nth_le_drop', nth_le_take _ _ C]
#align composition.size_up_to_size_up_to_add Composition.sizeUpTo_sizeUpTo_add
-/

#print Composition.sigmaEquivSigmaPi /-
/-- Natural equivalence between `(Σ (a : composition n), composition a.length)` and
`(Σ (c : composition n), Π (i : fin c.length), composition (c.blocks_fun i))`, that shows up as a
change of variables in the proof that composition of formal multilinear series is associative.

Consider a composition `a` of `n` and a composition `b` of `a.length`. Then `b` indicates how to
group together some blocks of `a`, giving altogether `b.length` blocks of blocks. These blocks of
blocks can be called `d₀, ..., d_{a.length - 1}`, and one obtains a composition `c` of `n` by
saying that each `dᵢ` is one single block. The map `⟨a, b⟩ → ⟨c, (d₀, ..., d_{a.length - 1})⟩` is
the direct map in the equiv.

Conversely, if one starts from `c` and the `dᵢ`s, one can join the `dᵢ`s to obtain a composition
`a` of `n`, and register the lengths of the `dᵢ`s in a composition `b` of `a.length`. This is the
inverse map of the equiv.
-/
def sigmaEquivSigmaPi (n : ℕ) :
    (Σ a : Composition n, Composition a.length) ≃
      Σ c : Composition n, ∀ i : Fin c.length, Composition (c.blocksFun i)
    where
  toFun i := ⟨i.1.gather i.2, i.1.sigmaCompositionAux i.2⟩
  invFun i :=
    ⟨{  blocks := (ofFn fun j => (i.2 j).blocks).join
        blocks_pos :=
          by
          simp only [and_imp, List.mem_join, exists_imp, forall_mem_of_fn_iff]
          exact fun i j hj => Composition.blocks_pos _ hj
        blocks_sum := by simp [sum_of_fn, Composition.blocks_sum, Composition.sum_blocksFun] },
      { blocks := ofFn fun j => (i.2 j).length
        blocks_pos :=
          forall_mem_ofFn_iff.2 fun j =>
            Composition.length_pos_of_pos _ (Composition.blocks_pos' _ _ _)
        blocks_sum := by dsimp only [Composition.length]; simp [sum_of_fn] }⟩
  left_inv :=
    by
    -- the fact that we have a left inverse is essentially `join_split_wrt_composition`,
    -- but we need to massage it to take care of the dependent setting.
    rintro ⟨a, b⟩
    rw [sigma_composition_eq_iff]
    dsimp
    constructor
    · have A := length_map List.sum (split_wrt_composition a.blocks b)
      conv_rhs =>
        rw [← join_split_wrt_composition a.blocks b, ←
          of_fn_nth_le (split_wrt_composition a.blocks b)]
      congr
      · exact A
      · exact (Fin.heq_fun_iff A).2 fun i => rfl
    · have B : Composition.length (Composition.gather a b) = List.length b.blocks :=
        Composition.length_gather _ _
      conv_rhs => rw [← of_fn_nth_le b.blocks]
      congr 1
      apply (Fin.heq_fun_iff B).2 fun i => _
      rw [sigma_composition_aux, Composition.length, nth_le_map_rev List.length,
        nth_le_of_eq (map_length_split_wrt_composition _ _)]
      rfl
  right_inv :=
    by
    -- the fact that we have a right inverse is essentially `split_wrt_composition_join`,
    -- but we need to massage it to take care of the dependent setting.
    rintro ⟨c, d⟩
    have : map List.sum (of_fn fun i : Fin (Composition.length c) => (d i).blocks) = c.blocks := by
      simp [map_of_fn, (· ∘ ·), Composition.blocks_sum, Composition.ofFn_blocksFun]
    rw [sigma_pi_composition_eq_iff]
    dsimp
    congr
    · ext1
      dsimp [Composition.gather]
      rwa [split_wrt_composition_join]
      simp only [map_of_fn]
    · rw [Fin.heq_fun_iff]
      · intro i
        dsimp [Composition.sigmaCompositionAux]
        rw [nth_le_of_eq (split_wrt_composition_join _ _ _)]
        · simp only [nth_le_of_fn']
        · simp only [map_of_fn]
      · congr
        ext1
        dsimp [Composition.gather]
        rwa [split_wrt_composition_join]
        simp only [map_of_fn]
#align composition.sigma_equiv_sigma_pi Composition.sigmaEquivSigmaPi
-/

end Composition

namespace FormalMultilinearSeries

open Composition

#print FormalMultilinearSeries.comp_assoc /-
theorem comp_assoc (r : FormalMultilinearSeries 𝕜 G H) (q : FormalMultilinearSeries 𝕜 F G)
    (p : FormalMultilinearSeries 𝕜 E F) : (r.comp q).comp p = r.comp (q.comp p) :=
  by
  ext n v
  /- First, rewrite the two compositions appearing in the theorem as two sums over complicated
    sigma types, as in the description of the proof above. -/
  let f : (Σ a : Composition n, Composition a.length) → H := fun c =>
    r c.2.length (apply_composition q c.2 (apply_composition p c.1 v))
  let g : (Σ c : Composition n, ∀ i : Fin c.length, Composition (c.blocksFun i)) → H := fun c =>
    r c.1.length fun i : Fin c.1.length =>
      q (c.2 i).length (apply_composition p (c.2 i) (v ∘ c.1.Embedding i))
  suffices ∑ c, f c = ∑ c, g c by
    simpa only [FormalMultilinearSeries.comp, ContinuousMultilinearMap.sum_apply,
      comp_along_composition_apply, ContinuousMultilinearMap.map_sum, Finset.sum_sigma',
      apply_composition]
  /- Now, we use `composition.sigma_equiv_sigma_pi n` to change
    variables in the second sum, and check that we get exactly the same sums. -/
  rw [← (sigma_equiv_sigma_pi n).sum_comp]
  /- To check that we have the same terms, we should check that we apply the same component of
    `r`, and the same component of `q`, and the same component of `p`, to the same coordinate of
    `v`. This is true by definition, but at each step one needs to convince Lean that the types
    one considers are the same, using a suitable congruence lemma to avoid dependent type issues.
    This dance has to be done three times, one for `r`, one for `q` and one for `p`.-/
  apply Finset.sum_congr rfl
  rintro ⟨a, b⟩ _
  dsimp [f, g, sigma_equiv_sigma_pi]
  -- check that the `r` components are the same. Based on `composition.length_gather`
  apply r.congr (Composition.length_gather a b).symm
  intro i hi1 hi2
  -- check that the `q` components are the same. Based on `length_sigma_composition_aux`
  apply q.congr (length_sigma_composition_aux a b _).symm
  intro j hj1 hj2
  -- check that the `p` components are the same. Based on `blocks_fun_sigma_composition_aux`
  apply p.congr (blocks_fun_sigma_composition_aux a b _ _).symm
  intro k hk1 hk2
  -- finally, check that the coordinates of `v` one is using are the same. Based on
  -- `size_up_to_size_up_to_add`.
  refine' congr_arg v (Fin.eq_of_veq _)
  dsimp [Composition.embedding]
  rw [size_up_to_size_up_to_add _ _ hi1 hj1, add_assoc]
#align formal_multilinear_series.comp_assoc FormalMultilinearSeries.comp_assoc
-/

end FormalMultilinearSeries

