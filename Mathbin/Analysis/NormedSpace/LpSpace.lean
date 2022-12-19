/-
Copyright (c) 2021 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth

! This file was ported from Lean 3 source module analysis.normed_space.lp_space
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.MeanInequalities
import Mathbin.Analysis.MeanInequalitiesPow
import Mathbin.Topology.Algebra.Order.LiminfLimsup

/-!
# ℓp space

This file describes properties of elements `f` of a pi-type `Π i, E i` with finite "norm",
defined for `p:ℝ≥0∞` as the size of the support of `f` if `p=0`, `(∑' a, ‖f a‖^p) ^ (1/p)` for
`0 < p < ∞` and `⨆ a, ‖f a‖` for `p=∞`.

The Prop-valued `mem_ℓp f p` states that a function `f : Π i, E i` has finite norm according
to the above definition; that is, `f` has finite support if `p = 0`, `summable (λ a, ‖f a‖^p)` if
`0 < p < ∞`, and `bdd_above (norm '' (set.range f))` if `p = ∞`.

The space `lp E p` is the subtype of elements of `Π i : α, E i` which satisfy `mem_ℓp f p`. For
`1 ≤ p`, the "norm" is genuinely a norm and `lp` is a complete metric space.

## Main definitions

* `mem_ℓp f p` : property that the function `f` satisfies, as appropriate, `f` finitely supported
  if `p = 0`, `summable (λ a, ‖f a‖^p)` if `0 < p < ∞`, and `bdd_above (norm '' (set.range f))` if
  `p = ∞`.
* `lp E p` : elements of `Π i : α, E i` such that `mem_ℓp f p`. Defined as an `add_subgroup` of
  a type synonym `pre_lp` for `Π i : α, E i`, and equipped with a `normed_add_comm_group` structure.
  Under appropriate conditions, this is also equipped with the instances `lp.normed_space`,
  `lp.complete_space`. For `p=∞`, there is also `lp.infty_normed_ring`,
  `lp.infty_normed_algebra`, `lp.infty_star_ring` and `lp.infty_cstar_ring`.

## Main results

* `mem_ℓp.of_exponent_ge`: For `q ≤ p`, a function which is `mem_ℓp` for `q` is also `mem_ℓp` for
  `p`
* `lp.mem_ℓp_of_tendsto`, `lp.norm_le_of_tendsto`: A pointwise limit of functions in `lp`, all with
  `lp` norm `≤ C`, is itself in `lp` and has `lp` norm `≤ C`.
* `lp.tsum_mul_le_mul_norm`: basic form of Hölder's inequality

## Implementation

Since `lp` is defined as an `add_subgroup`, dot notation does not work. Use `lp.norm_neg f` to
say that `‖-f‖ = ‖f‖`, instead of the non-working `f.norm_neg`.

## TODO

* More versions of Hölder's inequality (for example: the case `p = 1`, `q = ∞`; a version for normed
  rings which has `‖∑' i, f i * g i‖` rather than `∑' i, ‖f i‖ * g i‖` on the RHS; a version for
  three exponents satisfying `1 / r = 1 / p + 1 / q`)

-/


noncomputable section

open Nnreal Ennreal BigOperators

variable {α : Type _} {E : α → Type _} {p q : ℝ≥0∞} [∀ i, NormedAddCommGroup (E i)]

/-!
### `mem_ℓp` predicate

-/


/-- The property that `f : Π i : α, E i`
* is finitely supported, if `p = 0`, or
* admits an upper bound for `set.range (λ i, ‖f i‖)`, if `p = ∞`, or
* has the series `∑' i, ‖f i‖ ^ p` be summable, if `0 < p < ∞`. -/
def Memℓp (f : ∀ i, E i) (p : ℝ≥0∞) : Prop :=
  if p = 0 then Set.Finite { i | f i ≠ 0 }
  else if p = ∞ then BddAbove (Set.range fun i => ‖f i‖) else Summable fun i => ‖f i‖ ^ p.toReal
#align mem_ℓp Memℓp

theorem mem_ℓp_zero_iff {f : ∀ i, E i} : Memℓp f 0 ↔ Set.Finite { i | f i ≠ 0 } := by
  dsimp [Memℓp] <;> rw [if_pos rfl]
#align mem_ℓp_zero_iff mem_ℓp_zero_iff

theorem memℓpZero {f : ∀ i, E i} (hf : Set.Finite { i | f i ≠ 0 }) : Memℓp f 0 :=
  mem_ℓp_zero_iff.2 hf
#align mem_ℓp_zero memℓpZero

theorem mem_ℓp_infty_iff {f : ∀ i, E i} : Memℓp f ∞ ↔ BddAbove (Set.range fun i => ‖f i‖) := by
  dsimp [Memℓp] <;> rw [if_neg Ennreal.top_ne_zero, if_pos rfl]
#align mem_ℓp_infty_iff mem_ℓp_infty_iff

theorem memℓpInfty {f : ∀ i, E i} (hf : BddAbove (Set.range fun i => ‖f i‖)) : Memℓp f ∞ :=
  mem_ℓp_infty_iff.2 hf
#align mem_ℓp_infty memℓpInfty

theorem mem_ℓp_gen_iff (hp : 0 < p.toReal) {f : ∀ i, E i} :
    Memℓp f p ↔ Summable fun i => ‖f i‖ ^ p.toReal := by
  rw [Ennreal.to_real_pos_iff] at hp
  dsimp [Memℓp]
  rw [if_neg hp.1.ne', if_neg hp.2.Ne]
#align mem_ℓp_gen_iff mem_ℓp_gen_iff

theorem memℓpGen {f : ∀ i, E i} (hf : Summable fun i => ‖f i‖ ^ p.toReal) : Memℓp f p := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · apply memℓpZero
    have H : Summable fun i : α => (1 : ℝ) := by simpa using hf
    exact (finite_of_summable_const (by norm_num) H).Subset (Set.subset_univ _)
  · apply memℓpInfty
    have H : Summable fun i : α => (1 : ℝ) := by simpa using hf
    simpa using ((finite_of_summable_const (by norm_num) H).image fun i => ‖f i‖).BddAbove
  exact (mem_ℓp_gen_iff hp).2 hf
#align mem_ℓp_gen memℓpGen

theorem memℓpGen' {C : ℝ} {f : ∀ i, E i} (hf : ∀ s : Finset α, (∑ i in s, ‖f i‖ ^ p.toReal) ≤ C) :
    Memℓp f p := by 
  apply memℓpGen
  use ⨆ s : Finset α, ∑ i in s, ‖f i‖ ^ p.to_real
  apply has_sum_of_is_lub_of_nonneg
  · intro b
    exact Real.rpow_nonneg_of_nonneg (norm_nonneg _) _
  apply is_lub_csupr
  use C
  rintro - ⟨s, rfl⟩
  exact hf s
#align mem_ℓp_gen' memℓpGen'

theorem zeroMemℓp : Memℓp (0 : ∀ i, E i) p := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · apply memℓpZero
    simp
  · apply memℓpInfty
    simp only [norm_zero, Pi.zero_apply]
    exact bdd_above_singleton.mono Set.range_const_subset
  · apply memℓpGen
    simp [Real.zero_rpow hp.ne', summable_zero]
#align zero_mem_ℓp zeroMemℓp

theorem zeroMemℓp' : Memℓp (fun i : α => (0 : E i)) p :=
  zeroMemℓp
#align zero_mem_ℓp' zeroMemℓp'

namespace Memℓp

theorem finite_dsupport {f : ∀ i, E i} (hf : Memℓp f 0) : Set.Finite { i | f i ≠ 0 } :=
  mem_ℓp_zero_iff.1 hf
#align mem_ℓp.finite_dsupport Memℓp.finite_dsupport

theorem bdd_above {f : ∀ i, E i} (hf : Memℓp f ∞) : BddAbove (Set.range fun i => ‖f i‖) :=
  mem_ℓp_infty_iff.1 hf
#align mem_ℓp.bdd_above Memℓp.bdd_above

theorem summable (hp : 0 < p.toReal) {f : ∀ i, E i} (hf : Memℓp f p) :
    Summable fun i => ‖f i‖ ^ p.toReal :=
  (mem_ℓp_gen_iff hp).1 hf
#align mem_ℓp.summable Memℓp.summable

theorem neg {f : ∀ i, E i} (hf : Memℓp f p) : Memℓp (-f) p := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · apply memℓpZero
    simp [hf.finite_dsupport]
  · apply memℓpInfty
    simpa using hf.bdd_above
  · apply memℓpGen
    simpa using hf.summable hp
#align mem_ℓp.neg Memℓp.neg

@[simp]
theorem neg_iff {f : ∀ i, E i} : Memℓp (-f) p ↔ Memℓp f p :=
  ⟨fun h => neg_neg f ▸ h.neg, Memℓp.neg⟩
#align mem_ℓp.neg_iff Memℓp.neg_iff

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (i «expr ∉ » hfq.finite_dsupport.to_finset) -/
theorem ofExponentGe {p q : ℝ≥0∞} {f : ∀ i, E i} (hfq : Memℓp f q) (hpq : q ≤ p) : Memℓp f p := by
  rcases Ennreal.trichotomy₂ hpq with
    (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, hp⟩ | ⟨rfl, rfl⟩ | ⟨hq, rfl⟩ | ⟨hq, hp, hpq'⟩)
  · exact hfq
  · apply memℓpInfty
    obtain ⟨C, hC⟩ := (hfq.finite_dsupport.image fun i => ‖f i‖).BddAbove
    use max 0 C
    rintro x ⟨i, rfl⟩
    by_cases hi : f i = 0
    · simp [hi]
    · exact (hC ⟨i, hi, rfl⟩).trans (le_max_right _ _)
  · apply memℓpGen
    have : ∀ (i) (_ : i ∉ hfq.finite_dsupport.to_finset), ‖f i‖ ^ p.to_real = 0 := by
      intro i hi
      have : f i = 0 := by simpa using hi
      simp [this, Real.zero_rpow hp.ne']
    exact summable_of_ne_finset_zero this
  · exact hfq
  · apply memℓpInfty
    obtain ⟨A, hA⟩ := (hfq.summable hq).tendsto_cofinite_zero.bdd_above_range_of_cofinite
    use A ^ q.to_real⁻¹
    rintro x ⟨i, rfl⟩
    have : 0 ≤ ‖f i‖ ^ q.to_real := Real.rpow_nonneg_of_nonneg (norm_nonneg _) _
    simpa [← Real.rpow_mul, mul_inv_cancel hq.ne'] using
      Real.rpow_le_rpow this (hA ⟨i, rfl⟩) (inv_nonneg.mpr hq.le)
  · apply memℓpGen
    have hf' := hfq.summable hq
    refine' summable_of_norm_bounded_eventually _ hf' (@Set.Finite.subset _ { i | 1 ≤ ‖f i‖ } _ _ _)
    · have H : { x : α | 1 ≤ ‖f x‖ ^ q.to_real }.Finite := by
        simpa using
          eventually_lt_of_tendsto_lt (by norm_num : (0 : ℝ) < 1) hf'.tendsto_cofinite_zero
      exact H.subset fun i hi => Real.one_le_rpow hi hq.le
    · show ∀ i, ¬|‖f i‖ ^ p.to_real| ≤ ‖f i‖ ^ q.to_real → 1 ≤ ‖f i‖
      intro i hi
      have : 0 ≤ ‖f i‖ ^ p.to_real := Real.rpow_nonneg_of_nonneg (norm_nonneg _) p.to_real
      simp only [abs_of_nonneg, this] at hi
      contrapose! hi
      exact Real.rpow_le_rpow_of_exponent_ge' (norm_nonneg _) hi.le hq.le hpq'
#align mem_ℓp.of_exponent_ge Memℓp.ofExponentGe

theorem add {f g : ∀ i, E i} (hf : Memℓp f p) (hg : Memℓp g p) : Memℓp (f + g) p := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · apply memℓpZero
    refine' (hf.finite_dsupport.union hg.finite_dsupport).Subset fun i => _
    simp only [Pi.add_apply, Ne.def, Set.mem_union, Set.mem_setOf_eq]
    contrapose!
    rintro ⟨hf', hg'⟩
    simp [hf', hg']
  · apply memℓpInfty
    obtain ⟨A, hA⟩ := hf.bdd_above
    obtain ⟨B, hB⟩ := hg.bdd_above
    refine' ⟨A + B, _⟩
    rintro a ⟨i, rfl⟩
    exact le_trans (norm_add_le _ _) (add_le_add (hA ⟨i, rfl⟩) (hB ⟨i, rfl⟩))
  apply memℓpGen
  let C : ℝ := if p.to_real < 1 then 1 else 2 ^ (p.to_real - 1)
  refine'
    summable_of_nonneg_of_le _ (fun i => _) (((hf.summable hp).add (hg.summable hp)).mul_left C)
  · exact fun b => Real.rpow_nonneg_of_nonneg (norm_nonneg (f b + g b)) p.to_real
  · refine' (Real.rpow_le_rpow (norm_nonneg _) (norm_add_le _ _) hp.le).trans _
    dsimp [C]
    split_ifs with h h
    · simpa using Nnreal.coe_le_coe.2 (Nnreal.rpow_add_le_add_rpow ‖f i‖₊ ‖g i‖₊ hp.le h.le)
    · let F : Fin 2 → ℝ≥0 := ![‖f i‖₊, ‖g i‖₊]
      have : ∀ i, (0 : ℝ) ≤ F i := fun i => (F i).coe_nonneg
      simp only [not_lt] at h
      simpa [F, Fin.sum_univ_succ] using
        Real.rpow_sum_le_const_mul_sum_rpow_of_nonneg (Finset.univ : Finset (Fin 2)) h fun i _ =>
          (F i).coe_nonneg
#align mem_ℓp.add Memℓp.add

theorem sub {f g : ∀ i, E i} (hf : Memℓp f p) (hg : Memℓp g p) : Memℓp (f - g) p := by
  rw [sub_eq_add_neg]
  exact hf.add hg.neg
#align mem_ℓp.sub Memℓp.sub

theorem finsetSum {ι} (s : Finset ι) {f : ι → ∀ i, E i} (hf : ∀ i ∈ s, Memℓp (f i) p) :
    Memℓp (fun a => ∑ i in s, f i a) p := by
  haveI : DecidableEq ι := Classical.decEq _
  revert hf
  refine' Finset.induction_on s _ _
  · simp only [zeroMemℓp', Finset.sum_empty, imp_true_iff]
  · intro i s his ih hf
    simp only [his, Finset.sum_insert, not_false_iff]
    exact (hf i (s.mem_insert_self i)).add (ih fun j hj => hf j (Finset.mem_insert_of_mem hj))
#align mem_ℓp.finset_sum Memℓp.finsetSum

section NormedSpace

variable {𝕜 : Type _} [NormedField 𝕜] [∀ i, NormedSpace 𝕜 (E i)]

theorem constSmul {f : ∀ i, E i} (hf : Memℓp f p) (c : 𝕜) : Memℓp (c • f) p := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · apply memℓpZero
    refine' hf.finite_dsupport.subset fun i => (_ : ¬c • f i = 0 → ¬f i = 0)
    exact not_imp_not.mpr fun hf' => hf'.symm ▸ smul_zero c
  · obtain ⟨A, hA⟩ := hf.bdd_above
    refine' memℓpInfty ⟨‖c‖ * A, _⟩
    rintro a ⟨i, rfl⟩
    simpa [norm_smul] using mul_le_mul_of_nonneg_left (hA ⟨i, rfl⟩) (norm_nonneg c)
  · apply memℓpGen
    convert (hf.summable hp).mul_left (‖c‖ ^ p.to_real)
    ext i
    simp [norm_smul, Real.mul_rpow (norm_nonneg c) (norm_nonneg (f i))]
#align mem_ℓp.const_smul Memℓp.constSmul

theorem constMul {f : α → 𝕜} (hf : Memℓp f p) (c : 𝕜) : Memℓp (fun x => c * f x) p :=
  @Memℓp.constSmul α (fun i => 𝕜) _ _ 𝕜 _ _ _ hf c
#align mem_ℓp.const_mul Memℓp.constMul

end NormedSpace

end Memℓp

/-!
### lp space

The space of elements of `Π i, E i` satisfying the predicate `mem_ℓp`.
-/


/-- We define `pre_lp E` to be a type synonym for `Π i, E i` which, importantly, does not inherit
the `pi` topology on `Π i, E i` (otherwise this topology would descend to `lp E p` and conflict
with the normed group topology we will later equip it with.)

We choose to deal with this issue by making a type synonym for `Π i, E i` rather than for the `lp`
subgroup itself, because this allows all the spaces `lp E p` (for varying `p`) to be subgroups of
the same ambient group, which permits lemma statements like `lp.monotone` (below). -/
@[nolint unused_arguments]
def PreLp (E : α → Type _) [∀ i, NormedAddCommGroup (E i)] : Type _ :=
  ∀ i, E i deriving AddCommGroup
#align pre_lp PreLp

instance PreLp.unique [IsEmpty α] : Unique (PreLp E) :=
  Pi.uniqueOfIsEmpty E
#align pre_lp.unique PreLp.unique

/-- lp space -/
def lp (E : α → Type _) [∀ i, NormedAddCommGroup (E i)] (p : ℝ≥0∞) :
    AddSubgroup (PreLp E) where 
  carrier := { f | Memℓp f p }
  zero_mem' := zeroMemℓp
  add_mem' f g := Memℓp.add
  neg_mem' f := Memℓp.neg
#align lp lp

namespace lp

instance : Coe (lp E p) (∀ i, E i) :=
  coeSubtype

instance : CoeFun (lp E p) fun _ => ∀ i, E i :=
  ⟨fun f => ((f : ∀ i, E i) : ∀ i, E i)⟩

@[ext]
theorem ext {f g : lp E p} (h : (f : ∀ i, E i) = g) : f = g :=
  Subtype.ext h
#align lp.ext lp.ext

protected theorem ext_iff {f g : lp E p} : f = g ↔ (f : ∀ i, E i) = g :=
  Subtype.ext_iff
#align lp.ext_iff lp.ext_iff

theorem eq_zero' [IsEmpty α] (f : lp E p) : f = 0 :=
  Subsingleton.elim f 0
#align lp.eq_zero' lp.eq_zero'

protected theorem monotone {p q : ℝ≥0∞} (hpq : q ≤ p) : lp E q ≤ lp E p := fun f hf =>
  Memℓp.ofExponentGe hf hpq
#align lp.monotone lp.monotone

protected theorem memℓp (f : lp E p) : Memℓp f p :=
  f.Prop
#align lp.mem_ℓp lp.memℓp

variable (E p)

@[simp]
theorem coe_fn_zero : ⇑(0 : lp E p) = 0 :=
  rfl
#align lp.coe_fn_zero lp.coe_fn_zero

variable {E p}

@[simp]
theorem coe_fn_neg (f : lp E p) : ⇑(-f) = -f :=
  rfl
#align lp.coe_fn_neg lp.coe_fn_neg

@[simp]
theorem coe_fn_add (f g : lp E p) : ⇑(f + g) = f + g :=
  rfl
#align lp.coe_fn_add lp.coe_fn_add

@[simp]
theorem coe_fn_sum {ι : Type _} (f : ι → lp E p) (s : Finset ι) :
    ⇑(∑ i in s, f i) = ∑ i in s, ⇑(f i) := by
  classical 
    refine' Finset.induction _ _ s
    · simp
    intro i s his
    simp [Finset.sum_insert his]
#align lp.coe_fn_sum lp.coe_fn_sum

@[simp]
theorem coe_fn_sub (f g : lp E p) : ⇑(f - g) = f - g :=
  rfl
#align lp.coe_fn_sub lp.coe_fn_sub

instance :
    HasNorm
      (lp E
        p) where norm f :=
    if hp : p = 0 then by subst hp <;> exact (lp.memℓp f).finite_dsupport.toFinset.card
    else if p = ∞ then ⨆ i, ‖f i‖ else (∑' i, ‖f i‖ ^ p.toReal) ^ (1 / p.toReal)

theorem norm_eq_card_dsupport (f : lp E 0) : ‖f‖ = (lp.memℓp f).finite_dsupport.toFinset.card :=
  dif_pos rfl
#align lp.norm_eq_card_dsupport lp.norm_eq_card_dsupport

theorem norm_eq_csupr (f : lp E ∞) : ‖f‖ = ⨆ i, ‖f i‖ := by
  dsimp [norm]
  rw [dif_neg Ennreal.top_ne_zero, if_pos rfl]
#align lp.norm_eq_csupr lp.norm_eq_csupr

theorem is_lub_norm [Nonempty α] (f : lp E ∞) : IsLub (Set.range fun i => ‖f i‖) ‖f‖ := by
  rw [lp.norm_eq_csupr]
  exact is_lub_csupr (lp.memℓp f)
#align lp.is_lub_norm lp.is_lub_norm

theorem norm_eq_tsum_rpow (hp : 0 < p.toReal) (f : lp E p) :
    ‖f‖ = (∑' i, ‖f i‖ ^ p.toReal) ^ (1 / p.toReal) := by
  dsimp [norm]
  rw [Ennreal.to_real_pos_iff] at hp
  rw [dif_neg hp.1.ne', if_neg hp.2.Ne]
#align lp.norm_eq_tsum_rpow lp.norm_eq_tsum_rpow

theorem norm_rpow_eq_tsum (hp : 0 < p.toReal) (f : lp E p) :
    ‖f‖ ^ p.toReal = ∑' i, ‖f i‖ ^ p.toReal := by
  rw [norm_eq_tsum_rpow hp, ← Real.rpow_mul]
  · field_simp [hp.ne']
  apply tsum_nonneg
  intro i
  calc
    (0 : ℝ) = 0 ^ p.to_real := by rw [Real.zero_rpow hp.ne']
    _ ≤ _ := Real.rpow_le_rpow rfl.le (norm_nonneg (f i)) hp.le
    
#align lp.norm_rpow_eq_tsum lp.norm_rpow_eq_tsum

theorem has_sum_norm (hp : 0 < p.toReal) (f : lp E p) :
    HasSum (fun i => ‖f i‖ ^ p.toReal) (‖f‖ ^ p.toReal) := by
  rw [norm_rpow_eq_tsum hp]
  exact ((lp.memℓp f).Summable hp).HasSum
#align lp.has_sum_norm lp.has_sum_norm

theorem norm_nonneg' (f : lp E p) : 0 ≤ ‖f‖ := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · simp [lp.norm_eq_card_dsupport f]
  · cases' isEmpty_or_nonempty α with _i _i <;> skip
    · rw [lp.norm_eq_csupr]
      simp [Real.csupr_empty]
    inhabit α
    exact (norm_nonneg (f default)).trans ((lp.is_lub_norm f).1 ⟨default, rfl⟩)
  · rw [lp.norm_eq_tsum_rpow hp f]
    refine' Real.rpow_nonneg_of_nonneg (tsum_nonneg _) _
    exact fun i => Real.rpow_nonneg_of_nonneg (norm_nonneg _) _
#align lp.norm_nonneg' lp.norm_nonneg'

@[simp]
theorem norm_zero : ‖(0 : lp E p)‖ = 0 := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · simp [lp.norm_eq_card_dsupport]
  · simp [lp.norm_eq_csupr]
  · rw [lp.norm_eq_tsum_rpow hp]
    have hp' : 1 / p.to_real ≠ 0 := one_div_ne_zero hp.ne'
    simpa [Real.zero_rpow hp.ne'] using Real.zero_rpow hp'
#align lp.norm_zero lp.norm_zero

theorem norm_eq_zero_iff {f : lp E p} : ‖f‖ = 0 ↔ f = 0 := by
  classical 
    refine'
      ⟨fun h => _, by 
        rintro rfl
        exact norm_zero⟩
    rcases p.trichotomy with (rfl | rfl | hp)
    · ext i
      have : { i : α | ¬f i = 0 } = ∅ := by simpa [lp.norm_eq_card_dsupport f] using h
      have : (¬f i = 0) = False := congr_fun this i
      tauto
    · cases' isEmpty_or_nonempty α with _i _i <;> skip
      · simp
      have H : IsLub (Set.range fun i => ‖f i‖) 0 := by simpa [h] using lp.is_lub_norm f
      ext i
      have : ‖f i‖ = 0 := le_antisymm (H.1 ⟨i, rfl⟩) (norm_nonneg _)
      simpa using this
    · have hf : HasSum (fun i : α => ‖f i‖ ^ p.to_real) 0 := by
        have := lp.has_sum_norm hp f
        rwa [h, Real.zero_rpow hp.ne'] at this
      have : ∀ i, 0 ≤ ‖f i‖ ^ p.to_real := fun i => Real.rpow_nonneg_of_nonneg (norm_nonneg _) _
      rw [has_sum_zero_iff_of_nonneg this] at hf
      ext i
      have : f i = 0 ∧ p.to_real ≠ 0 := by
        simpa [Real.rpow_eq_zero_iff_of_nonneg (norm_nonneg (f i))] using congr_fun hf i
      exact this.1
#align lp.norm_eq_zero_iff lp.norm_eq_zero_iff

theorem eq_zero_iff_coe_fn_eq_zero {f : lp E p} : f = 0 ↔ ⇑f = 0 := by rw [lp.ext_iff, coe_fn_zero]
#align lp.eq_zero_iff_coe_fn_eq_zero lp.eq_zero_iff_coe_fn_eq_zero

@[simp]
theorem norm_neg ⦃f : lp E p⦄ : ‖-f‖ = ‖f‖ := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · simp [lp.norm_eq_card_dsupport]
  · cases isEmpty_or_nonempty α <;> skip
    · simp [lp.eq_zero' f]
    apply (lp.is_lub_norm (-f)).unique
    simpa using lp.is_lub_norm f
  · suffices ‖-f‖ ^ p.to_real = ‖f‖ ^ p.to_real by
      exact Real.rpow_left_inj_on hp.ne' (norm_nonneg' _) (norm_nonneg' _) this
    apply (lp.has_sum_norm hp (-f)).unique
    simpa using lp.has_sum_norm hp f
#align lp.norm_neg lp.norm_neg

instance [hp : Fact (1 ≤ p)] : NormedAddCommGroup (lp E p) :=
  AddGroupNorm.toNormedAddCommGroup
    { toFun := norm
      map_zero' := norm_zero
      neg' := norm_neg
      add_le' := fun f g => by 
        rcases p.dichotomy with (rfl | hp')
        · cases isEmpty_or_nonempty α
          · simp [lp.eq_zero' f]
          refine' (lp.is_lub_norm (f + g)).2 _
          rintro x ⟨i, rfl⟩
          refine'
            le_trans _
              (add_mem_upper_bounds_add (lp.is_lub_norm f).1 (lp.is_lub_norm g).1
                ⟨_, _, ⟨i, rfl⟩, ⟨i, rfl⟩, rfl⟩)
          exact norm_add_le (f i) (g i)
        · have hp'' : 0 < p.to_real := zero_lt_one.trans_le hp'
          have hf₁ : ∀ i, 0 ≤ ‖f i‖ := fun i => norm_nonneg _
          have hg₁ : ∀ i, 0 ≤ ‖g i‖ := fun i => norm_nonneg _
          have hf₂ := lp.has_sum_norm hp'' f
          have hg₂ := lp.has_sum_norm hp'' g
          -- apply Minkowski's inequality
          obtain ⟨C, hC₁, hC₂, hCfg⟩ :=
            Real.Lp_add_le_has_sum_of_nonneg hp' hf₁ hg₁ (norm_nonneg' _) (norm_nonneg' _) hf₂ hg₂
          refine' le_trans _ hC₂
          rw [← Real.rpow_le_rpow_iff (norm_nonneg' (f + g)) hC₁ hp'']
          refine' has_sum_le _ (lp.has_sum_norm hp'' (f + g)) hCfg
          intro i
          exact Real.rpow_le_rpow (norm_nonneg _) (norm_add_le _ _) hp''.le
      eq_zero_of_map_eq_zero' := fun f => norm_eq_zero_iff.1 }

-- TODO: define an `ennreal` version of `is_conjugate_exponent`, and then express this inequality
-- in a better version which also covers the case `p = 1, q = ∞`.
/-- Hölder inequality -/
protected theorem tsum_mul_le_mul_norm {p q : ℝ≥0∞} (hpq : p.toReal.IsConjugateExponent q.toReal)
    (f : lp E p) (g : lp E q) :
    (Summable fun i => ‖f i‖ * ‖g i‖) ∧ (∑' i, ‖f i‖ * ‖g i‖) ≤ ‖f‖ * ‖g‖ := by
  have hf₁ : ∀ i, 0 ≤ ‖f i‖ := fun i => norm_nonneg _
  have hg₁ : ∀ i, 0 ≤ ‖g i‖ := fun i => norm_nonneg _
  have hf₂ := lp.has_sum_norm hpq.pos f
  have hg₂ := lp.has_sum_norm hpq.symm.pos g
  obtain ⟨C, -, hC', hC⟩ :=
    Real.inner_le_Lp_mul_Lq_has_sum_of_nonneg hpq (norm_nonneg' _) (norm_nonneg' _) hf₁ hg₁ hf₂ hg₂
  rw [← hC.tsum_eq] at hC'
  exact ⟨hC.summable, hC'⟩
#align lp.tsum_mul_le_mul_norm lp.tsum_mul_le_mul_norm

protected theorem summable_mul {p q : ℝ≥0∞} (hpq : p.toReal.IsConjugateExponent q.toReal)
    (f : lp E p) (g : lp E q) : Summable fun i => ‖f i‖ * ‖g i‖ :=
  (lp.tsum_mul_le_mul_norm hpq f g).1
#align lp.summable_mul lp.summable_mul

protected theorem tsum_mul_le_mul_norm' {p q : ℝ≥0∞} (hpq : p.toReal.IsConjugateExponent q.toReal)
    (f : lp E p) (g : lp E q) : (∑' i, ‖f i‖ * ‖g i‖) ≤ ‖f‖ * ‖g‖ :=
  (lp.tsum_mul_le_mul_norm hpq f g).2
#align lp.tsum_mul_le_mul_norm' lp.tsum_mul_le_mul_norm'

section ComparePointwise

theorem norm_apply_le_norm (hp : p ≠ 0) (f : lp E p) (i : α) : ‖f i‖ ≤ ‖f‖ := by
  rcases eq_or_ne p ∞ with (rfl | hp')
  · haveI : Nonempty α := ⟨i⟩
    exact (is_lub_norm f).1 ⟨i, rfl⟩
  have hp'' : 0 < p.to_real := Ennreal.to_real_pos hp hp'
  have : ∀ i, 0 ≤ ‖f i‖ ^ p.to_real := fun i => Real.rpow_nonneg_of_nonneg (norm_nonneg _) _
  rw [← Real.rpow_le_rpow_iff (norm_nonneg _) (norm_nonneg' _) hp'']
  convert le_has_sum (has_sum_norm hp'' f) i fun i hi => this i
#align lp.norm_apply_le_norm lp.norm_apply_le_norm

theorem sum_rpow_le_norm_rpow (hp : 0 < p.toReal) (f : lp E p) (s : Finset α) :
    (∑ i in s, ‖f i‖ ^ p.toReal) ≤ ‖f‖ ^ p.toReal := by
  rw [lp.norm_rpow_eq_tsum hp f]
  have : ∀ i, 0 ≤ ‖f i‖ ^ p.to_real := fun i => Real.rpow_nonneg_of_nonneg (norm_nonneg _) _
  refine' sum_le_tsum _ (fun i hi => this i) _
  exact (lp.memℓp f).Summable hp
#align lp.sum_rpow_le_norm_rpow lp.sum_rpow_le_norm_rpow

theorem norm_le_of_forall_le' [Nonempty α] {f : lp E ∞} (C : ℝ) (hCf : ∀ i, ‖f i‖ ≤ C) : ‖f‖ ≤ C :=
  by 
  refine' (is_lub_norm f).2 _
  rintro - ⟨i, rfl⟩
  exact hCf i
#align lp.norm_le_of_forall_le' lp.norm_le_of_forall_le'

theorem norm_le_of_forall_le {f : lp E ∞} {C : ℝ} (hC : 0 ≤ C) (hCf : ∀ i, ‖f i‖ ≤ C) : ‖f‖ ≤ C :=
  by 
  cases isEmpty_or_nonempty α
  · simpa [eq_zero' f] using hC
  · exact norm_le_of_forall_le' C hCf
#align lp.norm_le_of_forall_le lp.norm_le_of_forall_le

theorem norm_le_of_tsum_le (hp : 0 < p.toReal) {C : ℝ} (hC : 0 ≤ C) {f : lp E p}
    (hf : (∑' i, ‖f i‖ ^ p.toReal) ≤ C ^ p.toReal) : ‖f‖ ≤ C := by
  rw [← Real.rpow_le_rpow_iff (norm_nonneg' _) hC hp, norm_rpow_eq_tsum hp]
  exact hf
#align lp.norm_le_of_tsum_le lp.norm_le_of_tsum_le

theorem norm_le_of_forall_sum_le (hp : 0 < p.toReal) {C : ℝ} (hC : 0 ≤ C) {f : lp E p}
    (hf : ∀ s : Finset α, (∑ i in s, ‖f i‖ ^ p.toReal) ≤ C ^ p.toReal) : ‖f‖ ≤ C :=
  norm_le_of_tsum_le hp hC (tsum_le_of_sum_le ((lp.memℓp f).Summable hp) hf)
#align lp.norm_le_of_forall_sum_le lp.norm_le_of_forall_sum_le

end ComparePointwise

section NormedSpace

variable {𝕜 : Type _} [NormedField 𝕜] [∀ i, NormedSpace 𝕜 (E i)]

instance : Module 𝕜 (PreLp E) :=
  Pi.module α E 𝕜

theorem mem_lp_const_smul (c : 𝕜) (f : lp E p) : c • (f : PreLp E) ∈ lp E p :=
  (lp.memℓp f).const_smul c
#align lp.mem_lp_const_smul lp.mem_lp_const_smul

variable (E p 𝕜)

/-- The `𝕜`-submodule of elements of `Π i : α, E i` whose `lp` norm is finite.  This is `lp E p`,
with extra structure. -/
def lpSubmodule : Submodule 𝕜 (PreLp E) :=
  { lp E p with smul_mem' := fun c f hf => by simpa using mem_lp_const_smul c ⟨f, hf⟩ }
#align lp_submodule lpSubmodule

variable {E p 𝕜}

theorem coe_lp_submodule : (lpSubmodule E p 𝕜).toAddSubgroup = lp E p :=
  rfl
#align lp.coe_lp_submodule lp.coe_lp_submodule

instance : Module 𝕜 (lp E p) :=
  { (lpSubmodule E p 𝕜).Module with }

@[simp]
theorem coe_fn_smul (c : 𝕜) (f : lp E p) : ⇑(c • f) = c • f :=
  rfl
#align lp.coe_fn_smul lp.coe_fn_smul

theorem norm_const_smul (hp : p ≠ 0) {c : 𝕜} (f : lp E p) : ‖c • f‖ = ‖c‖ * ‖f‖ := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · exact absurd rfl hp
  · cases isEmpty_or_nonempty α <;> skip
    · simp [lp.eq_zero' f]
    apply (lp.is_lub_norm (c • f)).unique
    convert (lp.is_lub_norm f).mul_left (norm_nonneg c)
    ext a
    simp [coe_fn_smul, norm_smul]
  · suffices ‖c • f‖ ^ p.to_real = (‖c‖ * ‖f‖) ^ p.to_real by
      refine' Real.rpow_left_inj_on hp.ne' _ _ this
      · exact norm_nonneg' _
      · exact mul_nonneg (norm_nonneg _) (norm_nonneg' _)
    apply (lp.has_sum_norm hp (c • f)).unique
    convert (lp.has_sum_norm hp f).mul_left (‖c‖ ^ p.to_real)
    · simp [coe_fn_smul, norm_smul, Real.mul_rpow (norm_nonneg c) (norm_nonneg _)]
    have hf : 0 ≤ ‖f‖ := lp.norm_nonneg' f
    simp [coe_fn_smul, norm_smul, Real.mul_rpow (norm_nonneg c) hf]
#align lp.norm_const_smul lp.norm_const_smul

instance [Fact (1 ≤ p)] :
    NormedSpace 𝕜
      (lp E
        p) where norm_smul_le c f := by
    have hp : 0 < p := ennreal.zero_lt_one.trans_le (Fact.out _)
    simp [norm_const_smul hp.ne']

variable {𝕜' : Type _} [NormedField 𝕜']

instance [∀ i, NormedSpace 𝕜' (E i)] [HasSmul 𝕜' 𝕜] [∀ i, IsScalarTower 𝕜' 𝕜 (E i)] :
    IsScalarTower 𝕜' 𝕜 (lp E p) := by 
  refine' ⟨fun r c f => _⟩
  ext1
  exact (lp.coe_fn_smul _ _).trans (smul_assoc _ _ _)

end NormedSpace

section NormedStarGroup

variable [∀ i, StarAddMonoid (E i)] [∀ i, NormedStarGroup (E i)]

theorem Memℓp.starMem {f : ∀ i, E i} (hf : Memℓp f p) : Memℓp (star f) p := by
  rcases p.trichotomy with (rfl | rfl | hp)
  · apply memℓpZero
    simp [hf.finite_dsupport]
  · apply memℓpInfty
    simpa using hf.bdd_above
  · apply memℓpGen
    simpa using hf.summable hp
#align mem_ℓp.star_mem Memℓp.starMem

@[simp]
theorem Memℓp.star_iff {f : ∀ i, E i} : Memℓp (star f) p ↔ Memℓp f p :=
  ⟨fun h => star_star f ▸ Memℓp.starMem h, Memℓp.starMem⟩
#align mem_ℓp.star_iff Memℓp.star_iff

instance : HasStar (lp E p) where star f := ⟨(star f : ∀ i, E i), f.property.star_mem⟩

@[simp]
theorem coe_fn_star (f : lp E p) : ⇑(star f) = star f :=
  rfl
#align lp.coe_fn_star lp.coe_fn_star

@[simp]
protected theorem star_apply (f : lp E p) (i : α) : star f i = star (f i) :=
  rfl
#align lp.star_apply lp.star_apply

instance :
    HasInvolutiveStar
      (lp E p) where star_involutive x := by 
    ext
    simp

instance : StarAddMonoid (lp E p) where star_add f g := ext <| star_add _ _

instance [hp : Fact (1 ≤ p)] :
    NormedStarGroup
      (lp E
        p) where norm_star f := by
    rcases p.trichotomy with (rfl | rfl | h)
    · exfalso
      have := Ennreal.to_real_mono Ennreal.zero_ne_top hp.elim
      norm_num at this
    · simp only [lp.norm_eq_csupr, lp.star_apply, norm_star]
    · simp only [lp.norm_eq_tsum_rpow h, lp.star_apply, norm_star]

variable {𝕜 : Type _} [HasStar 𝕜] [NormedField 𝕜]

variable [∀ i, NormedSpace 𝕜 (E i)] [∀ i, StarModule 𝕜 (E i)]

instance : StarModule 𝕜 (lp E p) where star_smul r f := ext <| star_smul _ _

end NormedStarGroup

section NonUnitalNormedRing

variable {I : Type _} {B : I → Type _} [∀ i, NonUnitalNormedRing (B i)]

theorem Memℓp.inftyMul {f g : ∀ i, B i} (hf : Memℓp f ∞) (hg : Memℓp g ∞) : Memℓp (f * g) ∞ := by
  rw [mem_ℓp_infty_iff]
  obtain ⟨⟨Cf, hCf⟩, ⟨Cg, hCg⟩⟩ := hf.bdd_above, hg.bdd_above
  refine' ⟨Cf * Cg, _⟩
  rintro _ ⟨i, rfl⟩
  calc
    ‖(f * g) i‖ ≤ ‖f i‖ * ‖g i‖ := norm_mul_le (f i) (g i)
    _ ≤ Cf * Cg :=
      mul_le_mul (hCf ⟨i, rfl⟩) (hCg ⟨i, rfl⟩) (norm_nonneg _)
        ((norm_nonneg _).trans (hCf ⟨i, rfl⟩))
    
#align mem_ℓp.infty_mul Memℓp.inftyMul

instance : Mul (lp B ∞) where mul f g := ⟨(f * g : ∀ i, B i), f.property.inftyMul g.property⟩

@[simp]
theorem infty_coe_fn_mul (f g : lp B ∞) : ⇑(f * g) = f * g :=
  rfl
#align lp.infty_coe_fn_mul lp.infty_coe_fn_mul

instance : NonUnitalRing (lp B ∞) :=
  Function.Injective.nonUnitalRing lp.hasCoeToFun.coe Subtype.coe_injective (lp.coe_fn_zero B ∞)
    lp.coe_fn_add infty_coe_fn_mul lp.coe_fn_neg lp.coe_fn_sub (fun _ _ => rfl) fun _ _ => rfl

instance : NonUnitalNormedRing (lp B ∞) :=
  { lp.normedAddCommGroup with
    norm_mul := fun f g =>
      lp.norm_le_of_forall_le (mul_nonneg (norm_nonneg f) (norm_nonneg g)) fun i =>
        calc
          ‖(f * g) i‖ ≤ ‖f i‖ * ‖g i‖ := norm_mul_le _ _
          _ ≤ ‖f‖ * ‖g‖ :=
            mul_le_mul (lp.norm_apply_le_norm Ennreal.top_ne_zero f i)
              (lp.norm_apply_le_norm Ennreal.top_ne_zero g i) (norm_nonneg _) (norm_nonneg _)
           }

-- we also want a `non_unital_normed_comm_ring` instance, but this has to wait for #13719
instance infty_is_scalar_tower {𝕜} [NormedField 𝕜] [∀ i, NormedSpace 𝕜 (B i)]
    [∀ i, IsScalarTower 𝕜 (B i) (B i)] : IsScalarTower 𝕜 (lp B ∞) (lp B ∞) :=
  ⟨fun r f g => lp.ext <| smul_assoc r (⇑f) ⇑g⟩
#align lp.infty_is_scalar_tower lp.infty_is_scalar_tower

instance infty_smul_comm_class {𝕜} [NormedField 𝕜] [∀ i, NormedSpace 𝕜 (B i)]
    [∀ i, SMulCommClass 𝕜 (B i) (B i)] : SMulCommClass 𝕜 (lp B ∞) (lp B ∞) :=
  ⟨fun r f g => lp.ext <| smul_comm r (⇑f) ⇑g⟩
#align lp.infty_smul_comm_class lp.infty_smul_comm_class

section StarRing

variable [∀ i, StarRing (B i)] [∀ i, NormedStarGroup (B i)]

instance inftyStarRing : StarRing (lp B ∞) :=
  { show StarAddMonoid (lp B ∞) by
      letI : ∀ i, StarAddMonoid (B i) := fun i => inferInstance
      infer_instance with
    star_mul := fun f g => ext <| star_mul (_ : ∀ i, B i) _ }
#align lp.infty_star_ring lp.inftyStarRing

instance inftyCstarRing [∀ i, CstarRing (B i)] :
    CstarRing
      (lp B
        ∞) where norm_star_mul_self f := by 
    apply le_antisymm
    · rw [← sq]
      refine' lp.norm_le_of_forall_le (sq_nonneg ‖f‖) fun i => _
      simp only [lp.star_apply, CstarRing.norm_star_mul_self, ← sq, infty_coe_fn_mul, Pi.mul_apply]
      refine' sq_le_sq' _ (lp.norm_apply_le_norm Ennreal.top_ne_zero _ _)
      linarith [norm_nonneg (f i), norm_nonneg f]
    · rw [← sq, ← Real.le_sqrt (norm_nonneg _) (norm_nonneg _)]
      refine' lp.norm_le_of_forall_le ‖star f * f‖.sqrt_nonneg fun i => _
      rw [Real.le_sqrt (norm_nonneg _) (norm_nonneg _), sq, ← CstarRing.norm_star_mul_self]
      exact lp.norm_apply_le_norm Ennreal.top_ne_zero (star f * f) i
#align lp.infty_cstar_ring lp.inftyCstarRing

end StarRing

end NonUnitalNormedRing

section NormedRing

variable {I : Type _} {B : I → Type _} [∀ i, NormedRing (B i)]

instance PreLp.ring : Ring (PreLp B) :=
  Pi.ring
#align pre_lp.ring PreLp.ring

variable [∀ i, NormOneClass (B i)]

theorem oneMemℓpInfty : Memℓp (1 : ∀ i, B i) ∞ :=
  ⟨1, by 
    rintro i ⟨i, rfl⟩
    exact norm_one.le⟩
#align one_mem_ℓp_infty oneMemℓpInfty

variable (B)

/-- The `𝕜`-subring of elements of `Π i : α, B i` whose `lp` norm is finite. This is `lp E ∞`,
with extra structure. -/
def lpInftySubring : Subring (PreLp B) :=
  { lp B ∞ with 
    carrier := { f | Memℓp f ∞ }
    one_mem' := oneMemℓpInfty
    mul_mem' := fun f g hf hg => hf.inftyMul hg }
#align lp_infty_subring lpInftySubring

variable {B}

instance inftyRing : Ring (lp B ∞) :=
  (lpInftySubring B).toRing
#align lp.infty_ring lp.inftyRing

theorem Memℓp.inftyPow {f : ∀ i, B i} (hf : Memℓp f ∞) (n : ℕ) : Memℓp (f ^ n) ∞ :=
  (lpInftySubring B).pow_mem hf n
#align mem_ℓp.infty_pow Memℓp.inftyPow

theorem natCastMemℓpInfty (n : ℕ) : Memℓp (n : ∀ i, B i) ∞ :=
  nat_cast_mem (lpInftySubring B) n
#align nat_cast_mem_ℓp_infty natCastMemℓpInfty

theorem intCastMemℓpInfty (z : ℤ) : Memℓp (z : ∀ i, B i) ∞ :=
  coe_int_mem (lpInftySubring B) z
#align int_cast_mem_ℓp_infty intCastMemℓpInfty

@[simp]
theorem infty_coe_fn_one : ⇑(1 : lp B ∞) = 1 :=
  rfl
#align lp.infty_coe_fn_one lp.infty_coe_fn_one

@[simp]
theorem infty_coe_fn_pow (f : lp B ∞) (n : ℕ) : ⇑(f ^ n) = f ^ n :=
  rfl
#align lp.infty_coe_fn_pow lp.infty_coe_fn_pow

@[simp]
theorem infty_coe_fn_nat_cast (n : ℕ) : ⇑(n : lp B ∞) = n :=
  rfl
#align lp.infty_coe_fn_nat_cast lp.infty_coe_fn_nat_cast

@[simp]
theorem infty_coe_fn_int_cast (z : ℤ) : ⇑(z : lp B ∞) = z :=
  rfl
#align lp.infty_coe_fn_int_cast lp.infty_coe_fn_int_cast

instance [Nonempty I] :
    NormOneClass
      (lp B
        ∞) where norm_one := by
    simp_rw [lp.norm_eq_csupr, infty_coe_fn_one, Pi.one_apply, norm_one, csupr_const]

instance inftyNormedRing : NormedRing (lp B ∞) :=
  { lp.inftyRing, lp.nonUnitalNormedRing with }
#align lp.infty_normed_ring lp.inftyNormedRing

end NormedRing

section NormedCommRing

variable {I : Type _} {B : I → Type _} [∀ i, NormedCommRing (B i)] [∀ i, NormOneClass (B i)]

instance inftyCommRing : CommRing (lp B ∞) :=
  { lp.inftyRing with
    mul_comm := fun f g => by 
      ext
      simp only [lp.infty_coe_fn_mul, Pi.mul_apply, mul_comm] }
#align lp.infty_comm_ring lp.inftyCommRing

instance inftyNormedCommRing : NormedCommRing (lp B ∞) :=
  { lp.inftyCommRing, lp.inftyNormedRing with }
#align lp.infty_normed_comm_ring lp.inftyNormedCommRing

end NormedCommRing

section Algebra

variable {I : Type _} {𝕜 : Type _} {B : I → Type _}

variable [NormedField 𝕜] [∀ i, NormedRing (B i)] [∀ i, NormedAlgebra 𝕜 (B i)]

/-- A variant of `pi.algebra` that lean can't find otherwise. -/
instance Pi.algebraOfNormedAlgebra : Algebra 𝕜 (∀ i, B i) :=
  (@Pi.algebra I 𝕜 B _ _) fun i => NormedAlgebra.toAlgebra
#align pi.algebra_of_normed_algebra Pi.algebraOfNormedAlgebra

instance PreLp.algebra : Algebra 𝕜 (PreLp B) :=
  _root_.pi.algebra_of_normed_algebra
#align pre_lp.algebra PreLp.algebra

variable [∀ i, NormOneClass (B i)]

theorem algebraMapMemℓpInfty (k : 𝕜) : Memℓp (algebraMap 𝕜 (∀ i, B i) k) ∞ := by
  rw [Algebra.algebra_map_eq_smul_one]
  exact (one_mem_ℓp_infty.const_smul k : Memℓp (k • 1 : ∀ i, B i) ∞)
#align algebra_map_mem_ℓp_infty algebraMapMemℓpInfty

variable (𝕜 B)

/-- The `𝕜`-subalgebra of elements of `Π i : α, B i` whose `lp` norm is finite. This is `lp E ∞`,
with extra structure. -/
def lpInftySubalgebra : Subalgebra 𝕜 (PreLp B) :=
  { lpInftySubring B with 
    carrier := { f | Memℓp f ∞ }
    algebra_map_mem' := algebraMapMemℓpInfty }
#align lp_infty_subalgebra lpInftySubalgebra

variable {𝕜 B}

instance inftyNormedAlgebra : NormedAlgebra 𝕜 (lp B ∞) :=
  { (lpInftySubalgebra 𝕜 B).Algebra, (lp.normedSpace : NormedSpace 𝕜 (lp B ∞)) with }
#align lp.infty_normed_algebra lp.inftyNormedAlgebra

end Algebra

section Single

variable {𝕜 : Type _} [NormedField 𝕜] [∀ i, NormedSpace 𝕜 (E i)]

variable [DecidableEq α]

/-- The element of `lp E p` which is `a : E i` at the index `i`, and zero elsewhere. -/
protected def single (p) (i : α) (a : E i) : lp E p :=
  ⟨fun j => if h : j = i then Eq.ndrec a h.symm else 0, by
    refine' (memℓpZero _).ofExponentGe (zero_le p)
    refine' (Set.finite_singleton i).Subset _
    intro j
    simp only [forall_exists_index, Set.mem_singleton_iff, Ne.def, dite_eq_right_iff,
      Set.mem_setOf_eq, not_forall]
    rintro rfl
    simp⟩
#align lp.single lp.single

protected theorem single_apply (p) (i : α) (a : E i) (j : α) :
    lp.single p i a j = if h : j = i then Eq.ndrec a h.symm else 0 :=
  rfl
#align lp.single_apply lp.single_apply

protected theorem single_apply_self (p) (i : α) (a : E i) : lp.single p i a i = a := by
  rw [lp.single_apply, dif_pos rfl]
#align lp.single_apply_self lp.single_apply_self

protected theorem single_apply_ne (p) (i : α) (a : E i) {j : α} (hij : j ≠ i) :
    lp.single p i a j = 0 := by rw [lp.single_apply, dif_neg hij]
#align lp.single_apply_ne lp.single_apply_ne

@[simp]
protected theorem single_neg (p) (i : α) (a : E i) : lp.single p i (-a) = -lp.single p i a := by
  ext j
  by_cases hi : j = i
  · subst hi
    simp [lp.single_apply_self]
  · simp [lp.single_apply_ne p i _ hi]
#align lp.single_neg lp.single_neg

@[simp]
protected theorem single_smul (p) (i : α) (a : E i) (c : 𝕜) :
    lp.single p i (c • a) = c • lp.single p i a := by
  ext j
  by_cases hi : j = i
  · subst hi
    simp [lp.single_apply_self]
  · simp [lp.single_apply_ne p i _ hi]
#align lp.single_smul lp.single_smul

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (i «expr ∉ » s) -/
protected theorem norm_sum_single (hp : 0 < p.toReal) (f : ∀ i, E i) (s : Finset α) :
    ‖∑ i in s, lp.single p i (f i)‖ ^ p.toReal = ∑ i in s, ‖f i‖ ^ p.toReal := by
  refine' (has_sum_norm hp (∑ i in s, lp.single p i (f i))).unique _
  simp only [lp.single_apply, coe_fn_sum, Finset.sum_apply, Finset.sum_dite_eq]
  have h : ∀ (i) (_ : i ∉ s), ‖ite (i ∈ s) (f i) 0‖ ^ p.to_real = 0 := by
    intro i hi
    simp [if_neg hi, Real.zero_rpow hp.ne']
  have h' : ∀ i ∈ s, ‖f i‖ ^ p.to_real = ‖ite (i ∈ s) (f i) 0‖ ^ p.to_real := by
    intro i hi
    rw [if_pos hi]
  simpa [Finset.sum_congr rfl h'] using has_sum_sum_of_ne_finset_zero h
#align lp.norm_sum_single lp.norm_sum_single

protected theorem norm_single (hp : 0 < p.toReal) (f : ∀ i, E i) (i : α) :
    ‖lp.single p i (f i)‖ = ‖f i‖ := by
  refine' Real.rpow_left_inj_on hp.ne' (norm_nonneg' _) (norm_nonneg _) _
  simpa using lp.norm_sum_single hp f {i}
#align lp.norm_single lp.norm_single

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (i «expr ∉ » s) -/
protected theorem norm_sub_norm_compl_sub_single (hp : 0 < p.toReal) (f : lp E p) (s : Finset α) :
    ‖f‖ ^ p.toReal - ‖f - ∑ i in s, lp.single p i (f i)‖ ^ p.toReal = ∑ i in s, ‖f i‖ ^ p.toReal :=
  by
  refine' ((has_sum_norm hp f).sub (has_sum_norm hp (f - ∑ i in s, lp.single p i (f i)))).unique _
  let F : α → ℝ := fun i => ‖f i‖ ^ p.to_real - ‖(f - ∑ i in s, lp.single p i (f i)) i‖ ^ p.to_real
  have hF : ∀ (i) (_ : i ∉ s), F i = 0 := by 
    intro i hi
    suffices ‖f i‖ ^ p.to_real - ‖f i - ite (i ∈ s) (f i) 0‖ ^ p.to_real = 0 by
      simpa only [F, coe_fn_sum, lp.single_apply, coe_fn_sub, Pi.sub_apply, Finset.sum_apply,
        Finset.sum_dite_eq] using this
    simp only [if_neg hi, sub_zero, sub_self]
  have hF' : ∀ i ∈ s, F i = ‖f i‖ ^ p.to_real := by
    intro i hi
    simp only [F, coe_fn_sum, lp.single_apply, if_pos hi, sub_self, eq_self_iff_true, coe_fn_sub,
      Pi.sub_apply, Finset.sum_apply, Finset.sum_dite_eq, sub_eq_self]
    simp [Real.zero_rpow hp.ne']
  have : HasSum F (∑ i in s, F i) := has_sum_sum_of_ne_finset_zero hF
  rwa [Finset.sum_congr rfl hF'] at this
#align lp.norm_sub_norm_compl_sub_single lp.norm_sub_norm_compl_sub_single

protected theorem norm_compl_sum_single (hp : 0 < p.toReal) (f : lp E p) (s : Finset α) :
    ‖f - ∑ i in s, lp.single p i (f i)‖ ^ p.toReal = ‖f‖ ^ p.toReal - ∑ i in s, ‖f i‖ ^ p.toReal :=
  by linarith [lp.norm_sub_norm_compl_sub_single hp f s]
#align lp.norm_compl_sum_single lp.norm_compl_sum_single

/-- The canonical finitely-supported approximations to an element `f` of `lp` converge to it, in the
`lp` topology. -/
protected theorem has_sum_single [Fact (1 ≤ p)] (hp : p ≠ ⊤) (f : lp E p) :
    HasSum (fun i : α => lp.single p i (f i : E i)) f := by
  have hp₀ : 0 < p := ennreal.zero_lt_one.trans_le (Fact.out _)
  have hp' : 0 < p.to_real := Ennreal.to_real_pos hp₀.ne' hp
  have := lp.has_sum_norm hp' f
  rw [HasSum, Metric.tendsto_nhds] at this⊢
  intro ε hε
  refine' (this _ (Real.rpow_pos_of_pos hε p.to_real)).mono _
  intro s hs
  rw [← Real.rpow_lt_rpow_iff dist_nonneg (le_of_lt hε) hp']
  rw [dist_comm] at hs
  simp only [dist_eq_norm, Real.norm_eq_abs] at hs⊢
  have H :
    ‖(∑ i in s, lp.single p i (f i : E i)) - f‖ ^ p.to_real =
      ‖f‖ ^ p.to_real - ∑ i in s, ‖f i‖ ^ p.to_real :=
    by
    simpa only [coe_fn_neg, Pi.neg_apply, lp.single_neg, Finset.sum_neg_distrib, neg_sub_neg,
      norm_neg, _root_.norm_neg] using lp.norm_compl_sum_single hp' (-f) s
  rw [← H] at hs
  have :
    |‖(∑ i in s, lp.single p i (f i : E i)) - f‖ ^ p.to_real| =
      ‖(∑ i in s, lp.single p i (f i : E i)) - f‖ ^ p.to_real :=
    by simp only [Real.abs_rpow_of_nonneg (norm_nonneg _), abs_norm_eq_norm]
  linarith
#align lp.has_sum_single lp.has_sum_single

end Single

section Topology

open Filter

open TopologicalSpace uniformity

/-- The coercion from `lp E p` to `Π i, E i` is uniformly continuous. -/
theorem uniform_continuous_coe [_i : Fact (1 ≤ p)] : UniformContinuous (coe : lp E p → ∀ i, E i) :=
  by 
  have hp : p ≠ 0 := (ennreal.zero_lt_one.trans_le _i.elim).ne'
  rw [uniform_continuous_pi]
  intro i
  rw [normed_add_comm_group.uniformity_basis_dist.uniform_continuous_iff
      NormedAddCommGroup.uniformity_basis_dist]
  intro ε hε
  refine' ⟨ε, hε, _⟩
  rintro f g (hfg : ‖f - g‖ < ε)
  have : ‖f i - g i‖ ≤ ‖f - g‖ := norm_apply_le_norm hp (f - g) i
  exact this.trans_lt hfg
#align lp.uniform_continuous_coe lp.uniform_continuous_coe

variable {ι : Type _} {l : Filter ι} [Filter.NeBot l]

theorem norm_apply_le_of_tendsto {C : ℝ} {F : ι → lp E ∞} (hCF : ∀ᶠ k in l, ‖F k‖ ≤ C)
    {f : ∀ a, E a} (hf : Tendsto (id fun i => F i : ι → ∀ a, E a) l (𝓝 f)) (a : α) : ‖f a‖ ≤ C := by
  have : tendsto (fun k => ‖F k a‖) l (𝓝 ‖f a‖) :=
    (tendsto.comp (continuous_apply a).ContinuousAt hf).norm
  refine' le_of_tendsto this (hCF.mono _)
  intro k hCFk
  exact (norm_apply_le_norm Ennreal.top_ne_zero (F k) a).trans hCFk
#align lp.norm_apply_le_of_tendsto lp.norm_apply_le_of_tendsto

variable [_i : Fact (1 ≤ p)]

include _i

theorem sum_rpow_le_of_tendsto (hp : p ≠ ∞) {C : ℝ} {F : ι → lp E p} (hCF : ∀ᶠ k in l, ‖F k‖ ≤ C)
    {f : ∀ a, E a} (hf : Tendsto (id fun i => F i : ι → ∀ a, E a) l (𝓝 f)) (s : Finset α) :
    (∑ i : α in s, ‖f i‖ ^ p.toReal) ≤ C ^ p.toReal := by
  have hp' : p ≠ 0 := (ennreal.zero_lt_one.trans_le _i.elim).ne'
  have hp'' : 0 < p.to_real := Ennreal.to_real_pos hp' hp
  let G : (∀ a, E a) → ℝ := fun f => ∑ a in s, ‖f a‖ ^ p.to_real
  have hG : Continuous G := by 
    refine' continuous_finset_sum s _
    intro a ha
    have : Continuous fun f : ∀ a, E a => f a := continuous_apply a
    exact this.norm.rpow_const fun _ => Or.inr hp''.le
  refine' le_of_tendsto (hG.continuous_at.tendsto.comp hf) _
  refine' hCF.mono _
  intro k hCFk
  refine' (lp.sum_rpow_le_norm_rpow hp'' (F k) s).trans _
  exact Real.rpow_le_rpow (norm_nonneg _) hCFk hp''.le
#align lp.sum_rpow_le_of_tendsto lp.sum_rpow_le_of_tendsto

/-- "Semicontinuity of the `lp` norm": If all sufficiently large elements of a sequence in `lp E p`
 have `lp` norm `≤ C`, then the pointwise limit, if it exists, also has `lp` norm `≤ C`. -/
theorem norm_le_of_tendsto {C : ℝ} {F : ι → lp E p} (hCF : ∀ᶠ k in l, ‖F k‖ ≤ C) {f : lp E p}
    (hf : Tendsto (id fun i => F i : ι → ∀ a, E a) l (𝓝 f)) : ‖f‖ ≤ C := by
  obtain ⟨i, hi⟩ := hCF.exists
  have hC : 0 ≤ C := (norm_nonneg _).trans hi
  rcases eq_top_or_lt_top p with (rfl | hp)
  · apply norm_le_of_forall_le hC
    exact norm_apply_le_of_tendsto hCF hf
  · have : 0 < p := ennreal.zero_lt_one.trans_le _i.elim
    have hp' : 0 < p.to_real := Ennreal.to_real_pos this.ne' hp.ne
    apply norm_le_of_forall_sum_le hp' hC
    exact sum_rpow_le_of_tendsto hp.ne hCF hf
#align lp.norm_le_of_tendsto lp.norm_le_of_tendsto

/-- If `f` is the pointwise limit of a bounded sequence in `lp E p`, then `f` is in `lp E p`. -/
theorem memℓpOfTendsto {F : ι → lp E p} (hF : Metric.Bounded (Set.range F)) {f : ∀ a, E a}
    (hf : Tendsto (id fun i => F i : ι → ∀ a, E a) l (𝓝 f)) : Memℓp f p := by
  obtain ⟨C, hC, hCF'⟩ := hF.exists_pos_norm_le
  have hCF : ∀ k, ‖F k‖ ≤ C := fun k => hCF' _ ⟨k, rfl⟩
  rcases eq_top_or_lt_top p with (rfl | hp)
  · apply memℓpInfty
    use C
    rintro _ ⟨a, rfl⟩
    refine' norm_apply_le_of_tendsto (eventually_of_forall hCF) hf a
  · apply memℓpGen'
    exact sum_rpow_le_of_tendsto hp.ne (eventually_of_forall hCF) hf
#align lp.mem_ℓp_of_tendsto lp.memℓpOfTendsto

/-- If a sequence is Cauchy in the `lp E p` topology and pointwise convergent to a element `f` of
`lp E p`, then it converges to `f` in the `lp E p` topology. -/
theorem tendsto_lp_of_tendsto_pi {F : ℕ → lp E p} (hF : CauchySeq F) {f : lp E p}
    (hf : Tendsto (id fun i => F i : ℕ → ∀ a, E a) atTop (𝓝 f)) : Tendsto F atTop (𝓝 f) := by
  rw [metric.nhds_basis_closed_ball.tendsto_right_iff]
  intro ε hε
  have hε' : { p : lp E p × lp E p | ‖p.1 - p.2‖ < ε } ∈ 𝓤 (lp E p) :=
    normed_add_comm_group.uniformity_basis_dist.mem_of_mem hε
  refine' (hF.eventually_eventually hε').mono _
  rintro n (hn : ∀ᶠ l in at_top, ‖(fun f => F n - f) (F l)‖ < ε)
  refine' norm_le_of_tendsto (hn.mono fun k hk => hk.le) _
  rw [tendsto_pi_nhds]
  intro a
  exact (hf.apply a).const_sub (F n a)
#align lp.tendsto_lp_of_tendsto_pi lp.tendsto_lp_of_tendsto_pi

variable [∀ a, CompleteSpace (E a)]

instance : CompleteSpace (lp E p) :=
  Metric.complete_of_cauchy_seq_tendsto
    (by 
      intro F hF
      -- A Cauchy sequence in `lp E p` is pointwise convergent; let `f` be the pointwise limit.
      obtain ⟨f, hf⟩ := cauchy_seq_tendsto_of_complete (uniform_continuous_coe.comp_cauchy_seq hF)
      -- Since the Cauchy sequence is bounded, its pointwise limit `f` is in `lp E p`.
      have hf' : Memℓp f p := mem_ℓp_of_tendsto hF.bounded_range hf
      -- And therefore `f` is its limit in the `lp E p` topology as well as pointwise.
      exact ⟨⟨f, hf'⟩, tendsto_lp_of_tendsto_pi hF hf⟩)

end Topology

end lp

