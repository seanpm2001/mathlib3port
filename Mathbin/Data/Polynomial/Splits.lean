/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes

! This file was ported from Lean 3 source module data.polynomial.splits
! leanprover-community/mathlib commit 31ca6f9cf5f90a6206092cd7f84b359dcb6d52e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.Prime
import Mathbin.Data.Polynomial.FieldDivision
import Mathbin.Data.Polynomial.Lifts

/-!
# Split polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A polynomial `f : K[X]` splits over a field extension `L` of `K` if it is zero or all of its
irreducible factors over `L` have degree `1`.

## Main definitions

* `polynomial.splits i f`: A predicate on a homomorphism `i : K →+* L` from a commutative ring to a
  field and a polynomial `f` saying that `f.map i` is zero or all of its irreducible factors over
  `L` have degree `1`.

## Main statements

* `lift_of_splits`: If `K` and `L` are field extensions of a field `F` and for some finite subset
  `S` of `K`, the minimal polynomial of every `x ∈ K` splits as a polynomial with coefficients in
  `L`, then `algebra.adjoin F S` embeds into `L`.

-/


noncomputable section

open scoped Classical BigOperators Polynomial

universe u v w

variable {F : Type u} {K : Type v} {L : Type w}

namespace Polynomial

open Polynomial

section Splits

section CommRing

variable [CommRing K] [Field L] [Field F]

variable (i : K →+* L)

#print Polynomial.Splits /-
/-- A polynomial `splits` iff it is zero or all of its irreducible factors have `degree` 1. -/
def Splits (f : K[X]) : Prop :=
  f.map i = 0 ∨ ∀ {g : L[X]}, Irreducible g → g ∣ f.map i → degree g = 1
#align polynomial.splits Polynomial.Splits
-/

#print Polynomial.splits_zero /-
@[simp]
theorem splits_zero : Splits i (0 : K[X]) :=
  Or.inl (Polynomial.map_zero i)
#align polynomial.splits_zero Polynomial.splits_zero
-/

#print Polynomial.splits_of_map_eq_C /-
theorem splits_of_map_eq_C {f : K[X]} {a : L} (h : f.map i = C a) : Splits i f :=
  if ha : a = 0 then Or.inl (h.trans (ha.symm ▸ C_0))
  else
    Or.inr fun g hg ⟨p, hp⟩ =>
      absurd hg.1 <|
        Classical.not_not.2 <|
          isUnit_iff_degree_eq_zero.2 <| by
            have := congr_arg degree hp
            rw [h, degree_C ha, degree_mul, @eq_comm (WithBot ℕ) 0, Nat.WithBot.add_eq_zero_iff] at
              this 
            exact this.1
#align polynomial.splits_of_map_eq_C Polynomial.splits_of_map_eq_C
-/

#print Polynomial.splits_C /-
@[simp]
theorem splits_C (a : K) : Splits i (C a) :=
  splits_of_map_eq_C i (map_C i)
#align polynomial.splits_C Polynomial.splits_C
-/

#print Polynomial.splits_of_map_degree_eq_one /-
theorem splits_of_map_degree_eq_one {f : K[X]} (hf : degree (f.map i) = 1) : Splits i f :=
  Or.inr fun g hg ⟨p, hp⟩ => by
    have := congr_arg degree hp <;>
          simp [Nat.WithBot.add_eq_one_iff, hf, @eq_comm (WithBot ℕ) 1,
            mt is_unit_iff_degree_eq_zero.2 hg.1] at this  <;>
        clear _fun_match <;>
      tauto
#align polynomial.splits_of_map_degree_eq_one Polynomial.splits_of_map_degree_eq_one
-/

#print Polynomial.splits_of_degree_le_one /-
theorem splits_of_degree_le_one {f : K[X]} (hf : degree f ≤ 1) : Splits i f :=
  if hif : degree (f.map i) ≤ 0 then splits_of_map_eq_C i (degree_le_zero_iff.mp hif)
  else by
    push_neg at hif 
    rw [← Order.succ_le_iff, ← WithBot.coe_zero, WithBot.succ_coe, Nat.succ_eq_succ] at hif 
    exact splits_of_map_degree_eq_one i (le_antisymm ((degree_map_le i _).trans hf) hif)
#align polynomial.splits_of_degree_le_one Polynomial.splits_of_degree_le_one
-/

#print Polynomial.splits_of_degree_eq_one /-
theorem splits_of_degree_eq_one {f : K[X]} (hf : degree f = 1) : Splits i f :=
  splits_of_degree_le_one i hf.le
#align polynomial.splits_of_degree_eq_one Polynomial.splits_of_degree_eq_one
-/

#print Polynomial.splits_of_natDegree_le_one /-
theorem splits_of_natDegree_le_one {f : K[X]} (hf : natDegree f ≤ 1) : Splits i f :=
  splits_of_degree_le_one i (degree_le_of_natDegree_le hf)
#align polynomial.splits_of_nat_degree_le_one Polynomial.splits_of_natDegree_le_one
-/

#print Polynomial.splits_of_natDegree_eq_one /-
theorem splits_of_natDegree_eq_one {f : K[X]} (hf : natDegree f = 1) : Splits i f :=
  splits_of_natDegree_le_one i (le_of_eq hf)
#align polynomial.splits_of_nat_degree_eq_one Polynomial.splits_of_natDegree_eq_one
-/

#print Polynomial.splits_mul /-
theorem splits_mul {f g : K[X]} (hf : Splits i f) (hg : Splits i g) : Splits i (f * g) :=
  if h : (f * g).map i = 0 then Or.inl h
  else
    Or.inr fun p hp hpf =>
      ((PrincipalIdealRing.irreducible_iff_prime.1 hp).2.2 _ _
            (show p ∣ map i f * map i g by convert hpf <;> rw [Polynomial.map_mul])).elim
        (hf.resolve_left (fun hf => by simpa [hf] using h) hp)
        (hg.resolve_left (fun hg => by simpa [hg] using h) hp)
#align polynomial.splits_mul Polynomial.splits_mul
-/

#print Polynomial.splits_of_splits_mul' /-
theorem splits_of_splits_mul' {f g : K[X]} (hfg : (f * g).map i ≠ 0) (h : Splits i (f * g)) :
    Splits i f ∧ Splits i g :=
  ⟨Or.inr fun g hgi hg =>
      Or.resolve_left h hfg hgi (by rw [Polynomial.map_mul] <;> exact hg.trans (dvd_mul_right _ _)),
    Or.inr fun g hgi hg =>
      Or.resolve_left h hfg hgi (by rw [Polynomial.map_mul] <;> exact hg.trans (dvd_mul_left _ _))⟩
#align polynomial.splits_of_splits_mul' Polynomial.splits_of_splits_mul'
-/

#print Polynomial.splits_map_iff /-
theorem splits_map_iff (j : L →+* F) {f : K[X]} : Splits j (f.map i) ↔ Splits (j.comp i) f := by
  simp [splits, Polynomial.map_map]
#align polynomial.splits_map_iff Polynomial.splits_map_iff
-/

#print Polynomial.splits_one /-
theorem splits_one : Splits i 1 :=
  splits_C i 1
#align polynomial.splits_one Polynomial.splits_one
-/

#print Polynomial.splits_of_isUnit /-
theorem splits_of_isUnit [IsDomain K] {u : K[X]} (hu : IsUnit u) : u.Splits i :=
  (isUnit_iff.mp hu).choose_spec.2 ▸ splits_C _ _
#align polynomial.splits_of_is_unit Polynomial.splits_of_isUnit
-/

#print Polynomial.splits_X_sub_C /-
theorem splits_X_sub_C {x : K} : (X - C x).Splits i :=
  splits_of_degree_le_one _ <| degree_X_sub_C_le _
#align polynomial.splits_X_sub_C Polynomial.splits_X_sub_C
-/

#print Polynomial.splits_X /-
theorem splits_X : X.Splits i :=
  splits_of_degree_le_one _ degree_X_le
#align polynomial.splits_X Polynomial.splits_X
-/

#print Polynomial.splits_prod /-
theorem splits_prod {ι : Type u} {s : ι → K[X]} {t : Finset ι} :
    (∀ j ∈ t, (s j).Splits i) → (∏ x in t, s x).Splits i :=
  by
  refine' Finset.induction_on t (fun _ => splits_one i) fun a t hat ih ht => _
  rw [Finset.forall_mem_insert] at ht ; rw [Finset.prod_insert hat]
  exact splits_mul i ht.1 (ih ht.2)
#align polynomial.splits_prod Polynomial.splits_prod
-/

#print Polynomial.splits_pow /-
theorem splits_pow {f : K[X]} (hf : f.Splits i) (n : ℕ) : (f ^ n).Splits i :=
  by
  rw [← Finset.card_range n, ← Finset.prod_const]
  exact splits_prod i fun j hj => hf
#align polynomial.splits_pow Polynomial.splits_pow
-/

#print Polynomial.splits_X_pow /-
theorem splits_X_pow (n : ℕ) : (X ^ n).Splits i :=
  splits_pow i (splits_X i) n
#align polynomial.splits_X_pow Polynomial.splits_X_pow
-/

#print Polynomial.splits_id_iff_splits /-
theorem splits_id_iff_splits {f : K[X]} : (f.map i).Splits (RingHom.id L) ↔ f.Splits i := by
  rw [splits_map_iff, RingHom.id_comp]
#align polynomial.splits_id_iff_splits Polynomial.splits_id_iff_splits
-/

#print Polynomial.exists_root_of_splits' /-
theorem exists_root_of_splits' {f : K[X]} (hs : Splits i f) (hf0 : degree (f.map i) ≠ 0) :
    ∃ x, eval₂ i x f = 0 :=
  if hf0' : f.map i = 0 then by simp [eval₂_eq_eval_map, hf0']
  else
    let ⟨g, hg⟩ :=
      WfDvdMonoid.exists_irreducible_factor
        (show ¬IsUnit (f.map i) from mt isUnit_iff_degree_eq_zero.1 hf0) hf0'
    let ⟨x, hx⟩ := exists_root_of_degree_eq_one (hs.resolve_left hf0' hg.1 hg.2)
    let ⟨i, hi⟩ := hg.2
    ⟨x, by rw [← eval_map, hi, eval_mul, show _ = _ from hx, MulZeroClass.zero_mul]⟩
#align polynomial.exists_root_of_splits' Polynomial.exists_root_of_splits'
-/

#print Polynomial.roots_ne_zero_of_splits' /-
theorem roots_ne_zero_of_splits' {f : K[X]} (hs : Splits i f) (hf0 : natDegree (f.map i) ≠ 0) :
    (f.map i).roots ≠ 0 :=
  let ⟨x, hx⟩ := exists_root_of_splits' i hs fun h => hf0 <| natDegree_eq_of_degree_eq_some h
  fun h => by
  rw [← eval_map] at hx 
  cases h.subst ((mem_roots _).2 hx); exact ne_zero_of_nat_degree_gt (Nat.pos_of_ne_zero hf0)
#align polynomial.roots_ne_zero_of_splits' Polynomial.roots_ne_zero_of_splits'
-/

#print Polynomial.rootOfSplits' /-
/-- Pick a root of a polynomial that splits. See `root_of_splits` for polynomials over a field
which has simpler assumptions. -/
def rootOfSplits' {f : K[X]} (hf : f.Splits i) (hfd : (f.map i).degree ≠ 0) : L :=
  Classical.choose <| exists_root_of_splits' i hf hfd
#align polynomial.root_of_splits' Polynomial.rootOfSplits'
-/

#print Polynomial.map_rootOfSplits' /-
theorem map_rootOfSplits' {f : K[X]} (hf : f.Splits i) (hfd) :
    f.eval₂ i (rootOfSplits' i hf hfd) = 0 :=
  Classical.choose_spec <| exists_root_of_splits' i hf hfd
#align polynomial.map_root_of_splits' Polynomial.map_rootOfSplits'
-/

#print Polynomial.natDegree_eq_card_roots' /-
theorem natDegree_eq_card_roots' {p : K[X]} {i : K →+* L} (hsplit : Splits i p) :
    (p.map i).natDegree = (p.map i).roots.card :=
  by
  by_cases hp : p.map i = 0
  · rw [hp, nat_degree_zero, roots_zero, Multiset.card_zero]
  obtain ⟨q, he, hd, hr⟩ := exists_prod_multiset_X_sub_C_mul (p.map i)
  rw [← splits_id_iff_splits, ← he] at hsplit 
  rw [← he] at hp 
  have hq : q ≠ 0 := fun h => hp (by rw [h, MulZeroClass.mul_zero])
  rw [← hd, add_right_eq_self]
  by_contra
  have h' : (map (RingHom.id L) q).natDegree ≠ 0 := by simp [h]
  have := roots_ne_zero_of_splits' (RingHom.id L) (splits_of_splits_mul' _ _ hsplit).2 h'
  · rw [map_id] at this ; exact this hr
  · rw [map_id]; exact mul_ne_zero monic_prod_multiset_X_sub_C.ne_zero hq
#align polynomial.nat_degree_eq_card_roots' Polynomial.natDegree_eq_card_roots'
-/

#print Polynomial.degree_eq_card_roots' /-
theorem degree_eq_card_roots' {p : K[X]} {i : K →+* L} (p_ne_zero : p.map i ≠ 0)
    (hsplit : Splits i p) : (p.map i).degree = (p.map i).roots.card := by
  rw [degree_eq_nat_degree p_ne_zero, nat_degree_eq_card_roots' hsplit]
#align polynomial.degree_eq_card_roots' Polynomial.degree_eq_card_roots'
-/

end CommRing

variable [Field K] [Field L] [Field F]

variable (i : K →+* L)

#print Polynomial.splits_iff /-
/-- This lemma is for polynomials over a field. -/
theorem splits_iff (f : K[X]) :
    Splits i f ↔ f = 0 ∨ ∀ {g : L[X]}, Irreducible g → g ∣ f.map i → degree g = 1 := by
  rw [splits, map_eq_zero]
#align polynomial.splits_iff Polynomial.splits_iff
-/

#print Polynomial.Splits.def /-
/-- This lemma is for polynomials over a field. -/
theorem Splits.def {i : K →+* L} {f : K[X]} (h : Splits i f) :
    f = 0 ∨ ∀ {g : L[X]}, Irreducible g → g ∣ f.map i → degree g = 1 :=
  (splits_iff i f).mp h
#align polynomial.splits.def Polynomial.Splits.def
-/

#print Polynomial.splits_of_splits_mul /-
theorem splits_of_splits_mul {f g : K[X]} (hfg : f * g ≠ 0) (h : Splits i (f * g)) :
    Splits i f ∧ Splits i g :=
  splits_of_splits_mul' i (map_ne_zero hfg) h
#align polynomial.splits_of_splits_mul Polynomial.splits_of_splits_mul
-/

#print Polynomial.splits_of_splits_of_dvd /-
theorem splits_of_splits_of_dvd {f g : K[X]} (hf0 : f ≠ 0) (hf : Splits i f) (hgf : g ∣ f) :
    Splits i g := by obtain ⟨f, rfl⟩ := hgf; exact (splits_of_splits_mul i hf0 hf).1
#align polynomial.splits_of_splits_of_dvd Polynomial.splits_of_splits_of_dvd
-/

#print Polynomial.splits_of_splits_gcd_left /-
theorem splits_of_splits_gcd_left {f g : K[X]} (hf0 : f ≠ 0) (hf : Splits i f) :
    Splits i (EuclideanDomain.gcd f g) :=
  Polynomial.splits_of_splits_of_dvd i hf0 hf (EuclideanDomain.gcd_dvd_left f g)
#align polynomial.splits_of_splits_gcd_left Polynomial.splits_of_splits_gcd_left
-/

#print Polynomial.splits_of_splits_gcd_right /-
theorem splits_of_splits_gcd_right {f g : K[X]} (hg0 : g ≠ 0) (hg : Splits i g) :
    Splits i (EuclideanDomain.gcd f g) :=
  Polynomial.splits_of_splits_of_dvd i hg0 hg (EuclideanDomain.gcd_dvd_right f g)
#align polynomial.splits_of_splits_gcd_right Polynomial.splits_of_splits_gcd_right
-/

#print Polynomial.splits_mul_iff /-
theorem splits_mul_iff {f g : K[X]} (hf : f ≠ 0) (hg : g ≠ 0) :
    (f * g).Splits i ↔ f.Splits i ∧ g.Splits i :=
  ⟨splits_of_splits_mul i (mul_ne_zero hf hg), fun ⟨hfs, hgs⟩ => splits_mul i hfs hgs⟩
#align polynomial.splits_mul_iff Polynomial.splits_mul_iff
-/

#print Polynomial.splits_prod_iff /-
theorem splits_prod_iff {ι : Type u} {s : ι → K[X]} {t : Finset ι} :
    (∀ j ∈ t, s j ≠ 0) → ((∏ x in t, s x).Splits i ↔ ∀ j ∈ t, (s j).Splits i) :=
  by
  refine'
    Finset.induction_on t (fun _ => ⟨fun _ _ h => h.elim, fun _ => splits_one i⟩)
      fun a t hat ih ht => _
  rw [Finset.forall_mem_insert] at ht ⊢
  rw [Finset.prod_insert hat, splits_mul_iff i ht.1 (Finset.prod_ne_zero_iff.2 ht.2), ih ht.2]
#align polynomial.splits_prod_iff Polynomial.splits_prod_iff
-/

#print Polynomial.degree_eq_one_of_irreducible_of_splits /-
theorem degree_eq_one_of_irreducible_of_splits {p : K[X]} (hp : Irreducible p)
    (hp_splits : Splits (RingHom.id K) p) : p.degree = 1 :=
  by
  rcases hp_splits with ⟨⟩
  · exfalso; simp_all
  · apply hp_splits hp; simp
#align polynomial.degree_eq_one_of_irreducible_of_splits Polynomial.degree_eq_one_of_irreducible_of_splits
-/

#print Polynomial.exists_root_of_splits /-
theorem exists_root_of_splits {f : K[X]} (hs : Splits i f) (hf0 : degree f ≠ 0) :
    ∃ x, eval₂ i x f = 0 :=
  exists_root_of_splits' i hs ((f.degree_map i).symm ▸ hf0)
#align polynomial.exists_root_of_splits Polynomial.exists_root_of_splits
-/

#print Polynomial.roots_ne_zero_of_splits /-
theorem roots_ne_zero_of_splits {f : K[X]} (hs : Splits i f) (hf0 : natDegree f ≠ 0) :
    (f.map i).roots ≠ 0 :=
  roots_ne_zero_of_splits' i hs (ne_of_eq_of_ne (natDegree_map i) hf0)
#align polynomial.roots_ne_zero_of_splits Polynomial.roots_ne_zero_of_splits
-/

#print Polynomial.rootOfSplits /-
/-- Pick a root of a polynomial that splits. This version is for polynomials over a field and has
simpler assumptions. -/
def rootOfSplits {f : K[X]} (hf : f.Splits i) (hfd : f.degree ≠ 0) : L :=
  rootOfSplits' i hf ((f.degree_map i).symm ▸ hfd)
#align polynomial.root_of_splits Polynomial.rootOfSplits
-/

#print Polynomial.rootOfSplits'_eq_rootOfSplits /-
/-- `root_of_splits'` is definitionally equal to `root_of_splits`. -/
theorem rootOfSplits'_eq_rootOfSplits {f : K[X]} (hf : f.Splits i) (hfd) :
    rootOfSplits' i hf hfd = rootOfSplits i hf (f.degree_map i ▸ hfd) :=
  rfl
#align polynomial.root_of_splits'_eq_root_of_splits Polynomial.rootOfSplits'_eq_rootOfSplits
-/

#print Polynomial.map_rootOfSplits /-
theorem map_rootOfSplits {f : K[X]} (hf : f.Splits i) (hfd) :
    f.eval₂ i (rootOfSplits i hf hfd) = 0 :=
  map_rootOfSplits' i hf (ne_of_eq_of_ne (degree_map f i) hfd)
#align polynomial.map_root_of_splits Polynomial.map_rootOfSplits
-/

#print Polynomial.natDegree_eq_card_roots /-
theorem natDegree_eq_card_roots {p : K[X]} {i : K →+* L} (hsplit : Splits i p) :
    p.natDegree = (p.map i).roots.card :=
  (natDegree_map i).symm.trans <| natDegree_eq_card_roots' hsplit
#align polynomial.nat_degree_eq_card_roots Polynomial.natDegree_eq_card_roots
-/

#print Polynomial.degree_eq_card_roots /-
theorem degree_eq_card_roots {p : K[X]} {i : K →+* L} (p_ne_zero : p ≠ 0) (hsplit : Splits i p) :
    p.degree = (p.map i).roots.card := by
  rw [degree_eq_nat_degree p_ne_zero, nat_degree_eq_card_roots hsplit]
#align polynomial.degree_eq_card_roots Polynomial.degree_eq_card_roots
-/

#print Polynomial.roots_map /-
theorem roots_map {f : K[X]} (hf : f.Splits <| RingHom.id K) : (f.map i).roots = f.roots.map i :=
  (roots_map_of_injective_of_card_eq_natDegree i.Injective <| by
      convert (nat_degree_eq_card_roots hf).symm; rw [map_id]).symm
#align polynomial.roots_map Polynomial.roots_map
-/

#print Polynomial.image_rootSet /-
theorem image_rootSet [Algebra F K] [Algebra F L] {p : F[X]} (h : p.Splits (algebraMap F K))
    (f : K →ₐ[F] L) : f '' p.rootSet K = p.rootSet L := by
  classical rw [root_set, ← Finset.coe_image, ← Multiset.toFinset_map, ← f.coe_to_ring_hom, ←
    roots_map (↑f) ((splits_id_iff_splits (algebraMap F K)).mpr h), map_map, f.comp_algebra_map, ←
    root_set]
#align polynomial.image_root_set Polynomial.image_rootSet
-/

#print Polynomial.adjoin_rootSet_eq_range /-
theorem adjoin_rootSet_eq_range [Algebra F K] [Algebra F L] {p : F[X]}
    (h : p.Splits (algebraMap F K)) (f : K →ₐ[F] L) :
    Algebra.adjoin F (p.rootSet L) = f.range ↔ Algebra.adjoin F (p.rootSet K) = ⊤ :=
  by
  rw [← image_root_set h f, Algebra.adjoin_image, ← Algebra.map_top]
  exact (Subalgebra.map_injective f.to_ring_hom.injective).eq_iff
#align polynomial.adjoin_root_set_eq_range Polynomial.adjoin_rootSet_eq_range
-/

#print Polynomial.eq_prod_roots_of_splits /-
theorem eq_prod_roots_of_splits {p : K[X]} {i : K →+* L} (hsplit : Splits i p) :
    p.map i = C (i p.leadingCoeff) * ((p.map i).roots.map fun a => X - C a).Prod :=
  by
  rw [← leading_coeff_map]; symm
  apply C_leading_coeff_mul_prod_multiset_X_sub_C
  rw [nat_degree_map]; exact (nat_degree_eq_card_roots hsplit).symm
#align polynomial.eq_prod_roots_of_splits Polynomial.eq_prod_roots_of_splits
-/

#print Polynomial.eq_prod_roots_of_splits_id /-
theorem eq_prod_roots_of_splits_id {p : K[X]} (hsplit : Splits (RingHom.id K) p) :
    p = C p.leadingCoeff * (p.roots.map fun a => X - C a).Prod := by
  simpa using eq_prod_roots_of_splits hsplit
#align polynomial.eq_prod_roots_of_splits_id Polynomial.eq_prod_roots_of_splits_id
-/

#print Polynomial.eq_prod_roots_of_monic_of_splits_id /-
theorem eq_prod_roots_of_monic_of_splits_id {p : K[X]} (m : Monic p)
    (hsplit : Splits (RingHom.id K) p) : p = (p.roots.map fun a => X - C a).Prod :=
  by
  convert eq_prod_roots_of_splits_id hsplit
  simp [m]
#align polynomial.eq_prod_roots_of_monic_of_splits_id Polynomial.eq_prod_roots_of_monic_of_splits_id
-/

#print Polynomial.eq_X_sub_C_of_splits_of_single_root /-
theorem eq_X_sub_C_of_splits_of_single_root {x : K} {h : K[X]} (h_splits : Splits i h)
    (h_roots : (h.map i).roots = {i x}) : h = C h.leadingCoeff * (X - C x) :=
  by
  apply Polynomial.map_injective _ i.injective
  rw [eq_prod_roots_of_splits h_splits, h_roots]
  simp
#align polynomial.eq_X_sub_C_of_splits_of_single_root Polynomial.eq_X_sub_C_of_splits_of_single_root
-/

#print Polynomial.mem_lift_of_splits_of_roots_mem_range /-
theorem mem_lift_of_splits_of_roots_mem_range (R : Type _) [CommRing R] [Algebra R K] {f : K[X]}
    (hs : f.Splits (RingHom.id K)) (hm : f.Monic) (hr : ∀ a ∈ f.roots, a ∈ (algebraMap R K).range) :
    f ∈ Polynomial.lifts (algebraMap R K) :=
  by
  rw [eq_prod_roots_of_monic_of_splits_id hm hs, lifts_iff_lifts_ring]
  refine' Subring.multiset_prod_mem _ _ fun P hP => _
  obtain ⟨b, hb, rfl⟩ := Multiset.mem_map.1 hP
  exact Subring.sub_mem _ (X_mem_lifts _) (C'_mem_lifts (hr _ hb))
#align polynomial.mem_lift_of_splits_of_roots_mem_range Polynomial.mem_lift_of_splits_of_roots_mem_range
-/

section UFD

attribute [local instance 10] PrincipalIdealRing.to_uniqueFactorizationMonoid

local infixl:50 " ~ᵤ " => Associated

open UniqueFactorizationMonoid Associates

#print Polynomial.splits_of_exists_multiset /-
theorem splits_of_exists_multiset {f : K[X]} {s : Multiset L}
    (hs : f.map i = C (i f.leadingCoeff) * (s.map fun a : L => X - C a).Prod) : Splits i f :=
  if hf0 : f = 0 then hf0.symm ▸ splits_zero i
  else
    Or.inr fun p hp hdp => by
      rw [irreducible_iff_prime] at hp 
      rw [hs, ← Multiset.prod_toList] at hdp 
      obtain hd | hd := hp.2.2 _ _ hdp
      · refine' (hp.2.1 <| isUnit_of_dvd_unit hd _).elim
        exact is_unit_C.2 ((leading_coeff_ne_zero.2 hf0).IsUnit.map i)
      · obtain ⟨q, hq, hd⟩ := hp.dvd_prod_iff.1 hd
        obtain ⟨a, ha, rfl⟩ := Multiset.mem_map.1 (Multiset.mem_toList.1 hq)
        rw [degree_eq_degree_of_associated ((hp.dvd_prime_iff_associated <| prime_X_sub_C a).1 hd)]
        exact degree_X_sub_C a
#align polynomial.splits_of_exists_multiset Polynomial.splits_of_exists_multiset
-/

#print Polynomial.splits_of_splits_id /-
theorem splits_of_splits_id {f : K[X]} : Splits (RingHom.id K) f → Splits i f :=
  UniqueFactorizationMonoid.induction_on_prime f (fun _ => splits_zero _)
    (fun _ hu _ => splits_of_degree_le_one _ ((isUnit_iff_degree_eq_zero.1 hu).symm ▸ by decide))
    fun a p ha0 hp ih hfi =>
    splits_mul _
      (splits_of_degree_eq_one _
        ((splits_of_splits_mul _ (mul_ne_zero hp.1 ha0) hfi).1.def.resolve_left hp.1 hp.Irreducible
          (by rw [map_id])))
      (ih (splits_of_splits_mul _ (mul_ne_zero hp.1 ha0) hfi).2)
#align polynomial.splits_of_splits_id Polynomial.splits_of_splits_id
-/

end UFD

#print Polynomial.splits_iff_exists_multiset /-
theorem splits_iff_exists_multiset {f : K[X]} :
    Splits i f ↔
      ∃ s : Multiset L, f.map i = C (i f.leadingCoeff) * (s.map fun a : L => X - C a).Prod :=
  ⟨fun hf => ⟨(f.map i).roots, eq_prod_roots_of_splits hf⟩, fun ⟨s, hs⟩ =>
    splits_of_exists_multiset i hs⟩
#align polynomial.splits_iff_exists_multiset Polynomial.splits_iff_exists_multiset
-/

#print Polynomial.splits_comp_of_splits /-
theorem splits_comp_of_splits (j : L →+* F) {f : K[X]} (h : Splits i f) : Splits (j.comp i) f :=
  by
  change i with (RingHom.id _).comp i at h 
  rw [← splits_map_iff]
  rw [← splits_map_iff i] at h 
  exact splits_of_splits_id _ h
#align polynomial.splits_comp_of_splits Polynomial.splits_comp_of_splits
-/

#print Polynomial.splits_iff_card_roots /-
/-- A polynomial splits if and only if it has as many roots as its degree. -/
theorem splits_iff_card_roots {p : K[X]} : Splits (RingHom.id K) p ↔ p.roots.card = p.natDegree :=
  by
  constructor
  · intro H; rw [nat_degree_eq_card_roots H, map_id]
  · intro hroots
    rw [splits_iff_exists_multiset (RingHom.id K)]
    use p.roots
    simp only [RingHom.id_apply, map_id]
    exact (C_leading_coeff_mul_prod_multiset_X_sub_C hroots).symm
#align polynomial.splits_iff_card_roots Polynomial.splits_iff_card_roots
-/

#print Polynomial.aeval_root_derivative_of_splits /-
theorem aeval_root_derivative_of_splits [Algebra K L] {P : K[X]} (hmo : P.Monic)
    (hP : P.Splits (algebraMap K L)) {r : L} (hr : r ∈ (P.map (algebraMap K L)).roots) :
    aeval r P.derivative = (((P.map <| algebraMap K L).roots.eraseₓ r).map fun a => r - a).Prod :=
  by
  replace hmo := hmo.map (algebraMap K L)
  replace hP := (splits_id_iff_splits (algebraMap K L)).2 hP
  rw [aeval_def, ← eval_map, ← derivative_map]
  nth_rw 1 [eq_prod_roots_of_monic_of_splits_id hmo hP]
  rw [eval_multiset_prod_X_sub_C_derivative hr]
#align polynomial.aeval_root_derivative_of_splits Polynomial.aeval_root_derivative_of_splits
-/

#print Polynomial.prod_roots_eq_coeff_zero_of_monic_of_split /-
/-- If `P` is a monic polynomial that splits, then `coeff P 0` equals the product of the roots. -/
theorem prod_roots_eq_coeff_zero_of_monic_of_split {P : K[X]} (hmo : P.Monic)
    (hP : P.Splits (RingHom.id K)) : coeff P 0 = (-1) ^ P.natDegree * P.roots.Prod :=
  by
  nth_rw 1 [eq_prod_roots_of_monic_of_splits_id hmo hP]
  rw [coeff_zero_eq_eval_zero, eval_multiset_prod, Multiset.map_map]
  simp_rw [Function.comp_apply, eval_sub, eval_X, zero_sub, eval_C]
  conv_lhs =>
    congr
    congr
    ext
    rw [neg_eq_neg_one_mul]
  rw [Multiset.prod_map_mul, Multiset.map_const, Multiset.prod_replicate, Multiset.map_id',
    splits_iff_card_roots.1 hP]
#align polynomial.prod_roots_eq_coeff_zero_of_monic_of_split Polynomial.prod_roots_eq_coeff_zero_of_monic_of_split
-/

#print Polynomial.sum_roots_eq_nextCoeff_of_monic_of_split /-
/-- If `P` is a monic polynomial that splits, then `P.next_coeff` equals the sum of the roots. -/
theorem sum_roots_eq_nextCoeff_of_monic_of_split {P : K[X]} (hmo : P.Monic)
    (hP : P.Splits (RingHom.id K)) : P.nextCoeff = -P.roots.Sum :=
  by
  nth_rw 1 [eq_prod_roots_of_monic_of_splits_id hmo hP]
  rw [monic.next_coeff_multiset_prod _ _ fun a ha => _]
  · simp_rw [next_coeff_X_sub_C, Multiset.sum_map_neg']
  · exact monic_X_sub_C a
#align polynomial.sum_roots_eq_next_coeff_of_monic_of_split Polynomial.sum_roots_eq_nextCoeff_of_monic_of_split
-/

end Splits

end Polynomial

