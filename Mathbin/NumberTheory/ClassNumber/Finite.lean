/-
Copyright (c) 2021 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen

! This file was ported from Lean 3 source module number_theory.class_number.finite
! leanprover-community/mathlib commit 30faa0c3618ce1472bf6305ae0e3fa56affa3f95
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Pow.Real
import Mathbin.LinearAlgebra.FreeModule.Pid
import Mathbin.LinearAlgebra.Matrix.AbsoluteValue
import Mathbin.NumberTheory.ClassNumber.AdmissibleAbsoluteValue
import Mathbin.RingTheory.ClassGroup
import Mathbin.RingTheory.DedekindDomain.IntegralClosure
import Mathbin.RingTheory.Norm

/-!
# Class numbers of global fields

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
In this file, we use the notion of "admissible absolute value" to prove
finiteness of the class group for number fields and function fields,
and define `class_number` as the order of this group.
## Main definitions
 - `class_group.fintype_of_admissible`: if `R` has an admissible absolute value,
   its integral closure has a finite class group
-/


open scoped BigOperators

open scoped nonZeroDivisors

namespace ClassGroup

open Ring

open scoped BigOperators

section EuclideanDomain

variable (R S K L : Type _) [EuclideanDomain R] [CommRing S] [IsDomain S]

variable [Field K] [Field L]

variable [Algebra R K] [IsFractionRing R K]

variable [Algebra K L] [FiniteDimensional K L] [IsSeparable K L]

variable [algRL : Algebra R L] [IsScalarTower R K L]

variable [Algebra R S] [Algebra S L]

variable [ist : IsScalarTower R S L] [iic : IsIntegralClosure S R L]

variable {R S} (abv : AbsoluteValue R ℤ)

variable {ι : Type _} [DecidableEq ι] [Fintype ι] (bS : Basis ι R S)

#print ClassGroup.normBound /-
/-- If `b` is an `R`-basis of `S` of cardinality `n`, then `norm_bound abv b` is an integer
such that for every `R`-integral element `a : S` with coordinates `≤ y`,
we have algebra.norm a ≤ norm_bound abv b * y ^ n`. (See also `norm_le` and `norm_lt`). -/
noncomputable def normBound : ℤ :=
  let n := Fintype.card ι
  let i : ι := Nonempty.some bS.index_nonempty
  let m : ℤ :=
    Finset.max'
      (Finset.univ.image fun ijk : ι × ι × ι =>
        abv (Algebra.leftMulMatrix bS (bS ijk.1) ijk.2.1 ijk.2.2))
      ⟨_, Finset.mem_image.mpr ⟨⟨i, i, i⟩, Finset.mem_univ _, rfl⟩⟩
  Nat.factorial n • (n • m) ^ n
#align class_group.norm_bound ClassGroup.normBound
-/

#print ClassGroup.normBound_pos /-
theorem normBound_pos : 0 < normBound abv bS :=
  by
  obtain ⟨i, j, k, hijk⟩ : ∃ i j k, Algebra.leftMulMatrix bS (bS i) j k ≠ 0 :=
    by
    by_contra' h
    obtain ⟨i⟩ := bS.index_nonempty
    apply bS.ne_zero i
    apply
      (injective_iff_map_eq_zero (Algebra.leftMulMatrix bS)).mp (Algebra.leftMulMatrix_injective bS)
    ext j k
    simp [h, DMatrix.zero_apply]
  simp only [norm_bound, Algebra.smul_def, eq_natCast]
  refine' mul_pos (int.coe_nat_pos.mpr (Nat.factorial_pos _)) _
  refine' pow_pos (mul_pos (int.coe_nat_pos.mpr (fintype.card_pos_iff.mpr ⟨i⟩)) _) _
  refine' lt_of_lt_of_le (abv.pos hijk) (Finset.le_max' _ _ _)
  exact finset.mem_image.mpr ⟨⟨i, j, k⟩, Finset.mem_univ _, rfl⟩
#align class_group.norm_bound_pos ClassGroup.normBound_pos
-/

#print ClassGroup.norm_le /-
/-- If the `R`-integral element `a : S` has coordinates `≤ y` with respect to some basis `b`,
its norm is less than `norm_bound abv b * y ^ dim S`. -/
theorem norm_le (a : S) {y : ℤ} (hy : ∀ k, abv (bS.repr a k) ≤ y) :
    abv (Algebra.norm R a) ≤ normBound abv bS * y ^ Fintype.card ι :=
  by
  conv_lhs => rw [← bS.sum_repr a]
  rw [Algebra.norm_apply, ← LinearMap.det_toMatrix bS]
  simp only [Algebra.norm_apply, AlgHom.map_sum, AlgHom.map_smul, LinearEquiv.map_sum,
    LinearEquiv.map_smul, Algebra.toMatrix_lmul_eq, norm_bound, smul_mul_assoc, ← mul_pow]
  convert Matrix.det_sum_smul_le Finset.univ _ hy using 3
  · rw [Finset.card_univ, smul_mul_assoc, mul_comm]
  · intro i j k
    apply Finset.le_max'
    exact finset.mem_image.mpr ⟨⟨i, j, k⟩, Finset.mem_univ _, rfl⟩
#align class_group.norm_le ClassGroup.norm_le
-/

#print ClassGroup.norm_lt /-
/-- If the `R`-integral element `a : S` has coordinates `< y` with respect to some basis `b`,
its norm is strictly less than `norm_bound abv b * y ^ dim S`. -/
theorem norm_lt {T : Type _} [LinearOrderedRing T] (a : S) {y : T}
    (hy : ∀ k, (abv (bS.repr a k) : T) < y) :
    (abv (Algebra.norm R a) : T) < normBound abv bS * y ^ Fintype.card ι :=
  by
  obtain ⟨i⟩ := bS.index_nonempty
  have him : (finset.univ.image fun k => abv (bS.repr a k)).Nonempty :=
    ⟨_, finset.mem_image.mpr ⟨i, Finset.mem_univ _, rfl⟩⟩
  set y' : ℤ := Finset.max' _ him with y'_def
  have hy' : ∀ k, abv (bS.repr a k) ≤ y' := by
    intro k
    exact Finset.le_max' _ _ (finset.mem_image.mpr ⟨k, Finset.mem_univ _, rfl⟩)
  have : (y' : T) < y :=
    by
    rw [y'_def, ←
      Finset.max'_image (show Monotone (coe : ℤ → T) from fun x y h => int.cast_le.mpr h)]
    apply (Finset.max'_lt_iff _ (him.image _)).mpr
    simp only [Finset.mem_image, exists_prop]
    rintro _ ⟨x, ⟨k, -, rfl⟩, rfl⟩
    exact hy k
  have y'_nonneg : 0 ≤ y' := le_trans (abv.nonneg _) (hy' i)
  apply (int.cast_le.mpr (norm_le abv bS a hy')).trans_lt
  simp only [Int.cast_mul, Int.cast_pow]
  apply mul_lt_mul' le_rfl
  · exact pow_lt_pow_of_lt_left this (int.cast_nonneg.mpr y'_nonneg) (fintype.card_pos_iff.mpr ⟨i⟩)
  · exact pow_nonneg (int.cast_nonneg.mpr y'_nonneg) _
  · exact int.cast_pos.mpr (norm_bound_pos abv bS)
  · infer_instance
#align class_group.norm_lt ClassGroup.norm_lt
-/

#print ClassGroup.exists_min /-
/-- A nonzero ideal has an element of minimal norm. -/
theorem exists_min (I : (Ideal S)⁰) :
    ∃ b ∈ (I : Ideal S),
      b ≠ 0 ∧ ∀ c ∈ (I : Ideal S), abv (Algebra.norm R c) < abv (Algebra.norm R b) → c = (0 : S) :=
  by
  obtain ⟨_, ⟨b, b_mem, b_ne_zero, rfl⟩, min⟩ :=
    @Int.exists_least_of_bdd
      (fun a => ∃ b ∈ (I : Ideal S), b ≠ (0 : S) ∧ abv (Algebra.norm R b) = a) _ _
  · refine' ⟨b, b_mem, b_ne_zero, _⟩
    intro c hc lt
    contrapose! lt with c_ne_zero
    exact min _ ⟨c, hc, c_ne_zero, rfl⟩
  · use 0
    rintro _ ⟨b, b_mem, b_ne_zero, rfl⟩
    apply abv.nonneg
  · obtain ⟨b, b_mem, b_ne_zero⟩ := (I : Ideal S).ne_bot_iff.mp (nonZeroDivisors.coe_ne_zero I)
    exact ⟨_, ⟨b, b_mem, b_ne_zero, rfl⟩⟩
#align class_group.exists_min ClassGroup.exists_min
-/

section IsAdmissible

variable (L) {abv} (adm : abv.IsAdmissible)

#print ClassGroup.cardM /-
/-- If we have a large enough set of elements in `R^ι`, then there will be a pair
whose remainders are close together. We'll show that all sets of cardinality
at least `cardM bS adm` elements satisfy this condition.

The value of `cardM` is not at all optimal: for specific choices of `R`,
the minimum cardinality can be exponentially smaller.
-/
noncomputable def cardM : ℕ :=
  adm.card (normBound abv bS ^ (-1 / Fintype.card ι : ℝ)) ^ Fintype.card ι
#align class_group.cardM ClassGroup.cardM
-/

variable [Infinite R]

#print ClassGroup.distinctElems /-
/-- In the following results, we need a large set of distinct elements of `R`. -/
noncomputable def distinctElems : Fin (cardM bS adm).succ ↪ R :=
  Fin.valEmbedding.trans (Infinite.natEmbedding R)
#align class_group.distinct_elems ClassGroup.distinctElems
-/

variable [DecidableEq R]

#print ClassGroup.finsetApprox /-
/-- `finset_approx` is a finite set such that each fractional ideal in the integral closure
contains an element close to `finset_approx`. -/
noncomputable def finsetApprox : Finset R :=
  (Finset.univ.image fun xy : _ × _ => distinctElems bS adm xy.1 - distinctElems bS adm xy.2).eraseₓ
    0
#align class_group.finset_approx ClassGroup.finsetApprox
-/

#print ClassGroup.finsetApprox.zero_not_mem /-
theorem finsetApprox.zero_not_mem : (0 : R) ∉ finsetApprox bS adm :=
  Finset.not_mem_erase _ _
#align class_group.finset_approx.zero_not_mem ClassGroup.finsetApprox.zero_not_mem
-/

#print ClassGroup.mem_finsetApprox /-
@[simp]
theorem mem_finsetApprox {x : R} :
    x ∈ finsetApprox bS adm ↔ ∃ i j, i ≠ j ∧ distinctElems bS adm i - distinctElems bS adm j = x :=
  by
  simp only [finset_approx, Finset.mem_erase, Finset.mem_image]
  constructor
  · rintro ⟨hx, ⟨i, j⟩, _, rfl⟩
    refine' ⟨i, j, _, rfl⟩
    rintro rfl
    simpa using hx
  · rintro ⟨i, j, hij, rfl⟩
    refine' ⟨_, ⟨i, j⟩, Finset.mem_univ _, rfl⟩
    rw [Ne.def, sub_eq_zero]
    exact fun h => hij ((distinct_elems bS adm).Injective h)
#align class_group.mem_finset_approx ClassGroup.mem_finsetApprox
-/

section Real

open Real

attribute [-instance] Real.decidableEq

#print ClassGroup.exists_mem_finsetApprox /-
/-- We can approximate `a / b : L` with `q / r`, where `r` has finitely many options for `L`. -/
theorem exists_mem_finsetApprox (a : S) {b} (hb : b ≠ (0 : R)) :
    ∃ q : S,
      ∃ r ∈ finsetApprox bS adm,
        abv (Algebra.norm R (r • a - b • q)) < abv (Algebra.norm R (algebraMap R S b)) :=
  by
  have dim_pos := fintype.card_pos_iff.mpr bS.index_nonempty
  set ε : ℝ := norm_bound abv bS ^ (-1 / Fintype.card ι : ℝ) with ε_eq
  have hε : 0 < ε := Real.rpow_pos_of_pos (int.cast_pos.mpr (norm_bound_pos abv bS)) _
  have ε_le : (norm_bound abv bS : ℝ) * (abv b • ε) ^ Fintype.card ι ≤ abv b ^ Fintype.card ι :=
    by
    have := norm_bound_pos abv bS
    have := abv.nonneg b
    rw [ε_eq, Algebra.smul_def, eq_intCast, ← rpow_nat_cast, mul_rpow, ← rpow_mul, div_mul_cancel,
        rpow_neg_one, mul_left_comm, mul_inv_cancel, mul_one, rpow_nat_cast] <;>
      try norm_cast; linarith
    · apply rpow_nonneg_of_nonneg
      norm_cast
      linarith
  let μ : Fin (cardM bS adm).succ ↪ R := distinct_elems bS adm
  set s := bS.repr a
  have s_eq : ∀ i, s i = bS.repr a i := fun i => rfl
  set qs := fun j i => μ j * s i / b
  have q_eq : ∀ j i, qs j i = μ j * s i / b := fun i j => rfl
  set rs := fun j i => μ j * s i % b with r_eq
  have r_eq : ∀ j i, rs j i = μ j * s i % b := fun i j => rfl
  have μ_eq : ∀ i j, μ j * s i = b * qs j i + rs j i :=
    by
    intro i j
    rw [q_eq, r_eq, EuclideanDomain.div_add_mod]
  have μ_mul_a_eq : ∀ j, μ j • a = b • ∑ i, qs j i • bS i + ∑ i, rs j i • bS i :=
    by
    intro j
    rw [← bS.sum_repr a]
    simp only [Finset.smul_sum, ← Finset.sum_add_distrib]
    refine' Finset.sum_congr rfl fun i _ => _
    rw [← s_eq, ← mul_smul, μ_eq, add_smul, mul_smul]
  obtain ⟨j, k, j_ne_k, hjk⟩ := adm.exists_approx hε hb fun j i => μ j * s i
  have hjk' : ∀ i, (abv (rs k i - rs j i) : ℝ) < abv b • ε := by simpa only [r_eq] using hjk
  set q := ∑ i, (qs k i - qs j i) • bS i with q_eq
  set r := μ k - μ j with r_eq
  refine' ⟨q, r, (mem_finset_approx bS adm).mpr _, _⟩
  · exact ⟨k, j, j_ne_k.symm, rfl⟩
  have : r • a - b • q = ∑ x : ι, (rs k x • bS x - rs j x • bS x) :=
    by
    simp only [r_eq, sub_smul, μ_mul_a_eq, q_eq, Finset.smul_sum, ← Finset.sum_add_distrib, ←
      Finset.sum_sub_distrib, smul_sub]
    refine' Finset.sum_congr rfl fun x _ => _
    ring
  rw [this, Algebra.norm_algebraMap_of_basis bS, abv.map_pow]
  refine' int.cast_lt.mp ((norm_lt abv bS _ fun i => lt_of_le_of_lt _ (hjk' i)).trans_le _)
  · apply le_of_eq
    congr
    simp_rw [LinearEquiv.map_sum, LinearEquiv.map_sub, LinearEquiv.map_smul, Finset.sum_apply',
      Finsupp.sub_apply, Finsupp.smul_apply, Finset.sum_sub_distrib, Basis.repr_self_apply,
      smul_eq_mul, mul_boole, Finset.sum_ite_eq', Finset.mem_univ, if_true]
  · exact_mod_cast ε_le
#align class_group.exists_mem_finset_approx ClassGroup.exists_mem_finsetApprox
-/

#print ClassGroup.exists_mem_finset_approx' /-
/-- We can approximate `a / b : L` with `q / r`, where `r` has finitely many options for `L`. -/
theorem exists_mem_finset_approx' (h : Algebra.IsAlgebraic R L) (a : S) {b : S} (hb : b ≠ 0) :
    ∃ q : S,
      ∃ r ∈ finsetApprox bS adm, abv (Algebra.norm R (r • a - q * b)) < abv (Algebra.norm R b) :=
  by
  have inj : Function.Injective (algebraMap R L) :=
    by
    rw [IsScalarTower.algebraMap_eq R S L]
    exact (IsIntegralClosure.algebraMap_injective S R L).comp bS.algebra_map_injective
  obtain ⟨a', b', hb', h⟩ := IsIntegralClosure.exists_smul_eq_mul h inj a hb
  obtain ⟨q, r, hr, hqr⟩ := exists_mem_finset_approx bS adm a' hb'
  refine' ⟨q, r, hr, _⟩
  refine'
    lt_of_mul_lt_mul_left _ (show 0 ≤ abv (Algebra.norm R (algebraMap R S b')) from abv.nonneg _)
  refine'
    lt_of_le_of_lt (le_of_eq _)
      (mul_lt_mul hqr le_rfl (abv.pos ((Algebra.norm_ne_zero_iff_of_basis bS).mpr hb))
        (abv.nonneg _))
  rw [← abv.map_mul, ← MonoidHom.map_mul, ← abv.map_mul, ← MonoidHom.map_mul, ← Algebra.smul_def,
    smul_sub b', sub_mul, smul_comm, h, mul_comm b a', Algebra.smul_mul_assoc r a' b,
    Algebra.smul_mul_assoc b' q b]
#align class_group.exists_mem_finset_approx' ClassGroup.exists_mem_finset_approx'
-/

end Real

#print ClassGroup.prod_finsetApprox_ne_zero /-
theorem prod_finsetApprox_ne_zero : algebraMap R S (∏ m in finsetApprox bS adm, m) ≠ 0 :=
  by
  refine' mt ((injective_iff_map_eq_zero _).mp bS.algebra_map_injective _) _
  simp only [Finset.prod_eq_zero_iff, not_exists]
  rintro x hx rfl
  exact finset_approx.zero_not_mem bS adm hx
#align class_group.prod_finset_approx_ne_zero ClassGroup.prod_finsetApprox_ne_zero
-/

#print ClassGroup.ne_bot_of_prod_finsetApprox_mem /-
theorem ne_bot_of_prod_finsetApprox_mem (J : Ideal S)
    (h : algebraMap _ _ (∏ m in finsetApprox bS adm, m) ∈ J) : J ≠ ⊥ :=
  (Submodule.ne_bot_iff _).mpr ⟨_, h, prod_finsetApprox_ne_zero _ _⟩
#align class_group.ne_bot_of_prod_finset_approx_mem ClassGroup.ne_bot_of_prod_finsetApprox_mem
-/

#print ClassGroup.exists_mk0_eq_mk0 /-
/-- Each class in the class group contains an ideal `J`
such that `M := Π m ∈ finset_approx` is in `J`. -/
theorem exists_mk0_eq_mk0 [IsDedekindDomain S] (h : Algebra.IsAlgebraic R L) (I : (Ideal S)⁰) :
    ∃ J : (Ideal S)⁰,
      ClassGroup.mk0 I = ClassGroup.mk0 J ∧
        algebraMap _ _ (∏ m in finsetApprox bS adm, m) ∈ (J : Ideal S) :=
  by
  set M := ∏ m in finset_approx bS adm, m with M_eq
  have hM : algebraMap R S M ≠ 0 := prod_finset_approx_ne_zero bS adm
  obtain ⟨b, b_mem, b_ne_zero, b_min⟩ := exists_min abv I
  suffices Ideal.span {b} ∣ Ideal.span {algebraMap _ _ M} * I.1
    by
    obtain ⟨J, hJ⟩ := this
    refine' ⟨⟨J, _⟩, _, _⟩
    · rw [mem_nonZeroDivisors_iff_ne_zero]
      rintro rfl
      rw [Ideal.zero_eq_bot, Ideal.mul_bot] at hJ 
      exact hM (ideal.span_singleton_eq_bot.mp (I.2 _ hJ))
    · rw [ClassGroup.mk0_eq_mk0_iff]
      exact ⟨algebraMap _ _ M, b, hM, b_ne_zero, hJ⟩
    rw [← SetLike.mem_coe, ← Set.singleton_subset_iff, ← Ideal.span_le, ← Ideal.dvd_iff_le]
    refine' (mul_dvd_mul_iff_left _).mp _
    swap; · exact mt ideal.span_singleton_eq_bot.mp b_ne_zero
    rw [Subtype.coe_mk, Ideal.dvd_iff_le, ← hJ, mul_comm]
    apply Ideal.mul_mono le_rfl
    rw [Ideal.span_le, Set.singleton_subset_iff]
    exact b_mem
  rw [Ideal.dvd_iff_le, Ideal.mul_le]
  intro r' hr' a ha
  rw [Ideal.mem_span_singleton] at hr' ⊢
  obtain ⟨q, r, r_mem, lt⟩ := exists_mem_finset_approx' L bS adm h a b_ne_zero
  apply @dvd_of_mul_left_dvd _ _ q
  simp only [Algebra.smul_def] at lt 
  rw [←
    sub_eq_zero.mp (b_min _ (I.1.sub_mem (I.1.mul_mem_left _ ha) (I.1.mul_mem_left _ b_mem)) lt)]
  refine' mul_dvd_mul_right (dvd_trans (RingHom.map_dvd _ _) hr') _
  exact Multiset.dvd_prod (multiset.mem_map.mpr ⟨_, r_mem, rfl⟩)
#align class_group.exists_mk0_eq_mk0 ClassGroup.exists_mk0_eq_mk0
-/

#print ClassGroup.mkMMem /-
/-- `class_group.mk_M_mem` is a specialization of `class_group.mk0` to (the finite set of)
ideals that contain `M := ∏ m in finset_approx L f abs, m`.
By showing this function is surjective, we prove that the class group is finite. -/
noncomputable def mkMMem [IsDedekindDomain S]
    (J : { J : Ideal S // algebraMap _ _ (∏ m in finsetApprox bS adm, m) ∈ J }) : ClassGroup S :=
  ClassGroup.mk0
    ⟨J.1, mem_nonZeroDivisors_iff_ne_zero.mpr (ne_bot_of_prod_finsetApprox_mem bS adm J.1 J.2)⟩
#align class_group.mk_M_mem ClassGroup.mkMMem
-/

#print ClassGroup.mkMMem_surjective /-
theorem mkMMem_surjective [IsDedekindDomain S] (h : Algebra.IsAlgebraic R L) :
    Function.Surjective (ClassGroup.mkMMem bS adm) :=
  by
  intro I'
  obtain ⟨⟨I, hI⟩, rfl⟩ := ClassGroup.mk0_surjective I'
  obtain ⟨J, mk0_eq_mk0, J_dvd⟩ := exists_mk0_eq_mk0 L bS adm h ⟨I, hI⟩
  exact ⟨⟨J, J_dvd⟩, mk0_eq_mk0.symm⟩
#align class_group.mk_M_mem_surjective ClassGroup.mkMMem_surjective
-/

open scoped Classical

#print ClassGroup.fintypeOfAdmissibleOfAlgebraic /-
/-- The main theorem: the class group of an integral closure `S` of `R` in an
algebraic extension `L` is finite if there is an admissible absolute value.

See also `class_group.fintype_of_admissible_of_finite` where `L` is a finite
extension of `K = Frac(R)`, supplying most of the required assumptions automatically.
-/
noncomputable def fintypeOfAdmissibleOfAlgebraic [IsDedekindDomain S]
    (h : Algebra.IsAlgebraic R L) : Fintype (ClassGroup S) :=
  @Fintype.ofSurjective _ _ _
    (@Fintype.ofEquiv _
      { J // J ∣ Ideal.span ({algebraMap R S (∏ m : R in finsetApprox bS adm, m)} : Set S) }
      (UniqueFactorizationMonoid.fintypeSubtypeDvd _
        (by
          rw [Ne.def, Ideal.zero_eq_bot, Ideal.span_singleton_eq_bot]
          exact prod_finset_approx_ne_zero bS adm))
      ((Equiv.refl _).subtypeEquiv fun I =>
        Ideal.dvd_iff_le.trans (by rw [Equiv.refl_apply, Ideal.span_le, Set.singleton_subset_iff])))
    (ClassGroup.mkMMem bS adm) (ClassGroup.mkMMem_surjective L bS adm h)
#align class_group.fintype_of_admissible_of_algebraic ClassGroup.fintypeOfAdmissibleOfAlgebraic
-/

#print ClassGroup.fintypeOfAdmissibleOfFinite /-
/-- The main theorem: the class group of an integral closure `S` of `R` in a
finite extension `L` of `K = Frac(R)` is finite if there is an admissible
absolute value.

See also `class_group.fintype_of_admissible_of_algebraic` where `L` is an
algebraic extension of `R`, that includes some extra assumptions.
-/
noncomputable def fintypeOfAdmissibleOfFinite : Fintype (ClassGroup S) :=
  by
  letI := Classical.decEq L
  letI := IsIntegralClosure.isFractionRing_of_finite_extension R K L S
  letI := IsIntegralClosure.isDedekindDomain R K L S
  choose s b hb_int using FiniteDimensional.exists_is_basis_integral R K L
  obtain ⟨n, b⟩ :=
    Submodule.basisOfPidOfLESpan _ (IsIntegralClosure.range_le_span_dualBasis S b hb_int)
  let bS := b.map ((LinearMap.quotKerEquivRange _).symm ≪≫ₗ _)
  refine'
    fintype_of_admissible_of_algebraic L bS adm fun x =>
      (IsFractionRing.isAlgebraic_iff R K L).mpr (Algebra.isAlgebraic_of_finite _ _ x)
  · rw [linear_map.ker_eq_bot.mpr]
    · exact Submodule.quotEquivOfEqBot _ rfl
    · exact IsIntegralClosure.algebraMap_injective _ R _
  · refine' (Basis.linearIndependent _).restrictScalars _
    simp only [Algebra.smul_def, mul_one]
    apply IsFractionRing.injective
#align class_group.fintype_of_admissible_of_finite ClassGroup.fintypeOfAdmissibleOfFinite
-/

end IsAdmissible

end EuclideanDomain

end ClassGroup

