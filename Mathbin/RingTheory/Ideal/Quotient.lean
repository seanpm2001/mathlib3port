/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Chris Hughes, Mario Carneiro, Anne Baanen
-/
import Mathbin.Algebra.Ring.Fin
import Mathbin.LinearAlgebra.Quotient
import Mathbin.RingTheory.Ideal.Basic
import Mathbin.Tactic.FinCases

/-!
# Ideal quotients

This file defines ideal quotients as a special case of submodule quotients and proves some basic
results about these quotients.

See `algebra.ring_quot` for quotients of non-commutative rings.

## Main definitions

 - `ideal.quotient`: the quotient of a commutative ring `R` by an ideal `I : ideal R`

## Main results

 - `ideal.quotient_inf_ring_equiv_pi_quotient`: the **Chinese Remainder Theorem**
-/


universe u v w

namespace Ideal

open Set

open BigOperators

variable {R : Type u} [CommRing R] (I : Ideal R) {a b : R}

variable {S : Type v}

-- Note that at present `ideal` means a left-ideal,
-- so this quotient is only useful in a commutative ring.
-- We should develop quotients by two-sided ideals as well.
/-- The quotient `R/I` of a ring `R` by an ideal `I`.

The ideal quotient of `I` is defined to equal the quotient of `I` as an `R`-submodule of `R`.
This definition is marked `reducible` so that typeclass instances can be shared between
`ideal.quotient I` and `submodule.quotient I`.
-/
@[reducible]
instance : HasQuotient R (Ideal R) :=
  Submodule.hasQuotient

namespace Quotient

variable {I} {x y : R}

instance hasOne (I : Ideal R) : One (R ⧸ I) :=
  ⟨Submodule.Quotient.mk 1⟩
#align ideal.quotient.has_one Ideal.Quotient.hasOne

instance hasMul (I : Ideal R) : Mul (R ⧸ I) :=
  ⟨fun a b =>
    (Quotient.liftOn₂' a b fun a b => Submodule.Quotient.mk (a * b)) fun a₁ a₂ b₁ b₂ h₁ h₂ =>
      Quot.sound <| by
        rw [Submodule.quotient_rel_r_def] at h₁ h₂⊢
        have F := I.add_mem (I.mul_mem_left a₂ h₁) (I.mul_mem_right b₁ h₂)
        have : a₁ * a₂ - b₁ * b₂ = a₂ * (a₁ - b₁) + (a₂ - b₂) * b₁ := by
          rw [mul_sub, sub_mul, sub_add_sub_cancel, mul_comm, mul_comm b₁]
        rw [← this] at F
        change _ ∈ _
        convert F⟩
#align ideal.quotient.has_mul Ideal.Quotient.hasMul

instance commRing (I : Ideal R) : CommRing (R ⧸ I) :=
  { Submodule.Quotient.addCommGroup I with mul := (· * ·), one := 1, natCast := fun n => Submodule.Quotient.mk n,
    nat_cast_zero := by simp [Nat.cast], nat_cast_succ := by simp [Nat.cast] <;> rfl,
    mul_assoc := fun a b c =>
      (Quotient.inductionOn₃' a b c) fun a b c => congr_arg Submodule.Quotient.mk (mul_assoc a b c),
    mul_comm := fun a b => (Quotient.inductionOn₂' a b) fun a b => congr_arg Submodule.Quotient.mk (mul_comm a b),
    one_mul := fun a => (Quotient.inductionOn' a) fun a => congr_arg Submodule.Quotient.mk (one_mul a),
    mul_one := fun a => (Quotient.inductionOn' a) fun a => congr_arg Submodule.Quotient.mk (mul_one a),
    left_distrib := fun a b c =>
      (Quotient.inductionOn₃' a b c) fun a b c => congr_arg Submodule.Quotient.mk (left_distrib a b c),
    right_distrib := fun a b c =>
      (Quotient.inductionOn₃' a b c) fun a b c => congr_arg Submodule.Quotient.mk (right_distrib a b c) }
#align ideal.quotient.comm_ring Ideal.Quotient.commRing

/-- The ring homomorphism from a ring `R` to a quotient ring `R/I`. -/
def mk (I : Ideal R) : R →+* R ⧸ I :=
  ⟨fun a => Submodule.Quotient.mk a, rfl, fun _ _ => rfl, rfl, fun _ _ => rfl⟩
#align ideal.quotient.mk Ideal.Quotient.mk

/- Two `ring_homs`s from the quotient by an ideal are equal if their
compositions with `ideal.quotient.mk'` are equal.

See note [partially-applied ext lemmas]. -/
@[ext.1]
theorem ring_hom_ext [NonAssocSemiring S] ⦃f g : R ⧸ I →+* S⦄ (h : f.comp (mk I) = g.comp (mk I)) : f = g :=
  RingHom.ext fun x => Quotient.inductionOn' x <| (RingHom.congr_fun h : _)
#align ideal.quotient.ring_hom_ext Ideal.Quotient.ring_hom_ext

instance inhabited : Inhabited (R ⧸ I) :=
  ⟨mk I 37⟩
#align ideal.quotient.inhabited Ideal.Quotient.inhabited

protected theorem eq : mk I x = mk I y ↔ x - y ∈ I :=
  Submodule.Quotient.eq I
#align ideal.quotient.eq Ideal.Quotient.eq

@[simp]
theorem mk_eq_mk (x : R) : (Submodule.Quotient.mk x : R ⧸ I) = mk I x :=
  rfl
#align ideal.quotient.mk_eq_mk Ideal.Quotient.mk_eq_mk

theorem eq_zero_iff_mem {I : Ideal R} : mk I a = 0 ↔ a ∈ I :=
  Submodule.Quotient.mk_eq_zero _
#align ideal.quotient.eq_zero_iff_mem Ideal.Quotient.eq_zero_iff_mem

theorem zero_eq_one_iff {I : Ideal R} : (0 : R ⧸ I) = 1 ↔ I = ⊤ :=
  eq_comm.trans <| eq_zero_iff_mem.trans (eq_top_iff_one _).symm
#align ideal.quotient.zero_eq_one_iff Ideal.Quotient.zero_eq_one_iff

theorem zero_ne_one_iff {I : Ideal R} : (0 : R ⧸ I) ≠ 1 ↔ I ≠ ⊤ :=
  not_congr zero_eq_one_iff
#align ideal.quotient.zero_ne_one_iff Ideal.Quotient.zero_ne_one_iff

protected theorem nontrivial {I : Ideal R} (hI : I ≠ ⊤) : Nontrivial (R ⧸ I) :=
  ⟨⟨0, 1, zero_ne_one_iff.2 hI⟩⟩
#align ideal.quotient.nontrivial Ideal.Quotient.nontrivial

theorem subsingleton_iff {I : Ideal R} : Subsingleton (R ⧸ I) ↔ I = ⊤ := by
  rw [eq_top_iff_one, ← subsingleton_iff_zero_eq_one, eq_comm, ← I, quotient.eq_zero_iff_mem]
#align ideal.quotient.subsingleton_iff Ideal.Quotient.subsingleton_iff

instance : Unique (R ⧸ (⊤ : Ideal R)) :=
  ⟨⟨0⟩, by rintro ⟨x⟩ <;> exact quotient.eq_zero_iff_mem.mpr Submodule.mem_top⟩

theorem mk_surjective : Function.Surjective (mk I) := fun y => Quotient.inductionOn' y fun x => Exists.intro x rfl
#align ideal.quotient.mk_surjective Ideal.Quotient.mk_surjective

instance : RingHomSurjective (mk I) :=
  ⟨mk_surjective⟩

/-- If `I` is an ideal of a commutative ring `R`, if `q : R → R/I` is the quotient map, and if
`s ⊆ R` is a subset, then `q⁻¹(q(s)) = ⋃ᵢ(i + s)`, the union running over all `i ∈ I`. -/
theorem quotient_ring_saturate (I : Ideal R) (s : Set R) : mk I ⁻¹' (mk I '' s) = ⋃ x : I, (fun y => x.1 + y) '' s := by
  ext x
  simp only [mem_preimage, mem_image, mem_Union, Ideal.Quotient.eq]
  exact
    ⟨fun ⟨a, a_in, h⟩ => ⟨⟨_, I.neg_mem h⟩, a, a_in, by simp⟩, fun ⟨⟨i, hi⟩, a, ha, Eq⟩ =>
      ⟨a, ha, by rw [← Eq, sub_add_eq_sub_sub_swap, sub_self, zero_sub] <;> exact I.neg_mem hi⟩⟩
#align ideal.quotient.quotient_ring_saturate Ideal.Quotient.quotient_ring_saturate

instance isDomain (I : Ideal R) [hI : I.IsPrime] : IsDomain (R ⧸ I) :=
  { Quotient.nontrivial hI.1 with
    eq_zero_or_eq_zero_of_mul_eq_zero := fun a b =>
      (Quotient.inductionOn₂' a b) fun a b hab =>
        (hI.mem_or_mem (eq_zero_iff_mem.1 hab)).elim (Or.inl ∘ eq_zero_iff_mem.2) (Or.inr ∘ eq_zero_iff_mem.2) }
#align ideal.quotient.is_domain Ideal.Quotient.isDomain

theorem is_domain_iff_prime (I : Ideal R) : IsDomain (R ⧸ I) ↔ I.IsPrime :=
  ⟨fun ⟨h1, h2⟩ =>
    haveI : Nontrivial _ := ⟨h2⟩
    ⟨zero_ne_one_iff.1 zero_ne_one, fun x y h => by
      simp only [← eq_zero_iff_mem, (mk I).map_mul] at h⊢
      exact h1 h⟩,
    fun h => by
    skip
    infer_instance⟩
#align ideal.quotient.is_domain_iff_prime Ideal.Quotient.is_domain_iff_prime

theorem exists_inv {I : Ideal R} [hI : I.IsMaximal] : ∀ {a : R ⧸ I}, a ≠ 0 → ∃ b : R ⧸ I, a * b = 1 := by
  rintro ⟨a⟩ h
  rcases hI.exists_inv (mt eq_zero_iff_mem.2 h) with ⟨b, c, hc, abc⟩
  rw [mul_comm] at abc
  refine' ⟨mk _ b, Quot.sound _⟩
  --quot.sound hb
  rw [← eq_sub_iff_add_eq'] at abc
  rw [abc, ← neg_mem_iff, neg_sub] at hc
  rw [Submodule.quotient_rel_r_def]
  convert hc
#align ideal.quotient.exists_inv Ideal.Quotient.exists_inv

open Classical

/-- quotient by maximal ideal is a field. def rather than instance, since users will have
computable inverses in some applications.
See note [reducible non-instances]. -/
@[reducible]
protected noncomputable def field (I : Ideal R) [hI : I.IsMaximal] : Field (R ⧸ I) :=
  { Quotient.commRing I, Quotient.isDomain I with
    inv := fun a => if ha : a = 0 then 0 else Classical.choose (exists_inv ha),
    mul_inv_cancel := fun a (ha : a ≠ 0) =>
      show a * dite _ _ _ = _ by rw [dif_neg ha] <;> exact Classical.choose_spec (exists_inv ha),
    inv_zero := dif_pos rfl }
#align ideal.quotient.field Ideal.Quotient.field

/-- If the quotient by an ideal is a field, then the ideal is maximal. -/
theorem maximal_of_is_field (I : Ideal R) (hqf : IsField (R ⧸ I)) : I.IsMaximal := by
  apply Ideal.is_maximal_iff.2
  constructor
  · intro h
    rcases hqf.exists_pair_ne with ⟨⟨x⟩, ⟨y⟩, hxy⟩
    exact hxy (Ideal.Quotient.eq.2 (mul_one (x - y) ▸ I.mul_mem_left _ h))
    
  · intro J x hIJ hxnI hxJ
    rcases hqf.mul_inv_cancel (mt Ideal.Quotient.eq_zero_iff_mem.1 hxnI) with ⟨⟨y⟩, hy⟩
    rw [← zero_add (1 : R), ← sub_self (x * y), sub_add]
    refine' J.sub_mem (J.mul_mem_right _ hxJ) (hIJ (Ideal.Quotient.eq.1 hy))
    
#align ideal.quotient.maximal_of_is_field Ideal.Quotient.maximal_of_is_field

/-- The quotient of a ring by an ideal is a field iff the ideal is maximal. -/
theorem maximal_ideal_iff_is_field_quotient (I : Ideal R) : I.IsMaximal ↔ IsField (R ⧸ I) :=
  ⟨fun h =>
    letI := @quotient.field _ _ I h
    Field.toIsField _,
    maximal_of_is_field _⟩
#align ideal.quotient.maximal_ideal_iff_is_field_quotient Ideal.Quotient.maximal_ideal_iff_is_field_quotient

variable [CommRing S]

/-- Given a ring homomorphism `f : R →+* S` sending all elements of an ideal to zero,
lift it to the quotient by this ideal. -/
def lift (I : Ideal R) (f : R →+* S) (H : ∀ a : R, a ∈ I → f a = 0) : R ⧸ I →+* S :=
  { QuotientAddGroup.lift I.toAddSubgroup f.toAddMonoidHom H with map_one' := f.map_one, map_zero' := f.map_zero,
    map_add' := fun a₁ a₂ => Quotient.inductionOn₂' a₁ a₂ f.map_add,
    map_mul' := fun a₁ a₂ => Quotient.inductionOn₂' a₁ a₂ f.map_mul }
#align ideal.quotient.lift Ideal.Quotient.lift

@[simp]
theorem lift_mk (I : Ideal R) (f : R →+* S) (H : ∀ a : R, a ∈ I → f a = 0) : lift I f H (mk I a) = f a :=
  rfl
#align ideal.quotient.lift_mk Ideal.Quotient.lift_mk

theorem lift_surjective_of_surjective (I : Ideal R) {f : R →+* S} (H : ∀ a : R, a ∈ I → f a = 0)
    (hf : Function.Surjective f) : Function.Surjective (Ideal.Quotient.lift I f H) := by
  intro y
  obtain ⟨x, rfl⟩ := hf y
  use Ideal.Quotient.mk I x
  simp only [Ideal.Quotient.lift_mk]
#align ideal.quotient.lift_surjective_of_surjective Ideal.Quotient.lift_surjective_of_surjective

/-- The ring homomorphism from the quotient by a smaller ideal to the quotient by a larger ideal.

This is the `ideal.quotient` version of `quot.factor` -/
def factor (S T : Ideal R) (H : S ≤ T) : R ⧸ S →+* R ⧸ T :=
  Ideal.Quotient.lift S T fun x hx => eq_zero_iff_mem.2 (H hx)
#align ideal.quotient.factor Ideal.Quotient.factor

@[simp]
theorem factor_mk (S T : Ideal R) (H : S ≤ T) (x : R) : factor S T H (mk S x) = mk T x :=
  rfl
#align ideal.quotient.factor_mk Ideal.Quotient.factor_mk

@[simp]
theorem factor_comp_mk (S T : Ideal R) (H : S ≤ T) : (factor S T H).comp (mk S) = mk T := by
  ext x
  rw [RingHom.comp_apply, factor_mk]
#align ideal.quotient.factor_comp_mk Ideal.Quotient.factor_comp_mk

end Quotient

/-- Quotienting by equal ideals gives equivalent rings.

See also `submodule.quot_equiv_of_eq`.
-/
def quotEquivOfEq {R : Type _} [CommRing R] {I J : Ideal R} (h : I = J) : R ⧸ I ≃+* R ⧸ J :=
  { Submodule.quotEquivOfEq I J h with
    map_mul' := by
      rintro ⟨x⟩ ⟨y⟩
      rfl }
#align ideal.quot_equiv_of_eq Ideal.quotEquivOfEq

@[simp]
theorem quot_equiv_of_eq_mk {R : Type _} [CommRing R] {I J : Ideal R} (h : I = J) (x : R) :
    quotEquivOfEq h (Ideal.Quotient.mk I x) = Ideal.Quotient.mk J x :=
  rfl
#align ideal.quot_equiv_of_eq_mk Ideal.quot_equiv_of_eq_mk

@[simp]
theorem quot_equiv_of_eq_symm {R : Type _} [CommRing R] {I J : Ideal R} (h : I = J) :
    (Ideal.quotEquivOfEq h).symm = Ideal.quotEquivOfEq h.symm := by ext <;> rfl
#align ideal.quot_equiv_of_eq_symm Ideal.quot_equiv_of_eq_symm

section Pi

variable (ι : Type v)

/-- `R^n/I^n` is a `R/I`-module. -/
instance modulePi : Module (R ⧸ I) ((ι → R) ⧸ I.pi ι) where
  smul c m :=
    Quotient.liftOn₂' c m (fun r m => Submodule.Quotient.mk <| r • m)
      (by
        intro c₁ m₁ c₂ m₂ hc hm
        apply Ideal.Quotient.eq.2
        rw [Submodule.quotient_rel_r_def] at hc hm
        intro i
        exact I.mul_sub_mul_mem hc (hm i))
  one_smul := by
    rintro ⟨a⟩
    convert_to Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _
    congr with i
    exact one_mul (a i)
  mul_smul := by
    rintro ⟨a⟩ ⟨b⟩ ⟨c⟩
    convert_to Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _
    simp only [(· • ·)]
    congr with i
    exact mul_assoc a b (c i)
  smul_add := by
    rintro ⟨a⟩ ⟨b⟩ ⟨c⟩
    convert_to Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _
    congr with i
    exact mul_add a (b i) (c i)
  smul_zero := by
    rintro ⟨a⟩
    convert_to Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _
    congr with i
    exact mul_zero a
  add_smul := by
    rintro ⟨a⟩ ⟨b⟩ ⟨c⟩
    convert_to Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _
    congr with i
    exact add_mul a b (c i)
  zero_smul := by
    rintro ⟨a⟩
    convert_to Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _
    congr with i
    exact zero_mul (a i)
#align ideal.module_pi Ideal.modulePi

/-- `R^n/I^n` is isomorphic to `(R/I)^n` as an `R/I`-module. -/
noncomputable def piQuotEquiv : ((ι → R) ⧸ I.pi ι) ≃ₗ[R ⧸ I] ι → R ⧸ I where
  toFun x :=
    (Quotient.liftOn' x fun f i => Ideal.Quotient.mk I (f i)) fun a b hab =>
      funext fun i => (Submodule.Quotient.eq' _).2 (QuotientAddGroup.left_rel_apply.mp hab i)
  map_add' := by
    rintro ⟨_⟩ ⟨_⟩
    rfl
  map_smul' := by
    rintro ⟨_⟩ ⟨_⟩
    rfl
  invFun x := (Ideal.Quotient.mk (I.pi ι)) fun i => Quotient.out' (x i)
  left_inv := by
    rintro ⟨x⟩
    exact Ideal.Quotient.eq.2 fun i => Ideal.Quotient.eq.1 (Quotient.out_eq' _)
  right_inv := by
    intro x
    ext i
    obtain ⟨r, hr⟩ := @Quot.exists_rep _ _ (x i)
    simp_rw [← hr]
    convert Quotient.out_eq' _
#align ideal.pi_quot_equiv Ideal.piQuotEquiv

/-- If `f : R^n → R^m` is an `R`-linear map and `I ⊆ R` is an ideal, then the image of `I^n` is
    contained in `I^m`. -/
theorem map_pi {ι : Type _} [Finite ι] {ι' : Type w} (x : ι → R) (hi : ∀ i, x i ∈ I) (f : (ι → R) →ₗ[R] ι' → R)
    (i : ι') : f x i ∈ I := by classical
  cases nonempty_fintype ι
  rw [pi_eq_sum_univ x]
  simp only [Finset.sum_apply, smul_eq_mul, LinearMap.map_sum, Pi.smul_apply, LinearMap.map_smul]
  exact I.sum_mem fun j hj => I.mul_mem_right _ (hi j)
#align ideal.map_pi Ideal.map_pi

end Pi

section ChineseRemainder

variable {ι : Type v}

theorem exists_sub_one_mem_and_mem (s : Finset ι) {f : ι → Ideal R} (hf : ∀ i ∈ s, ∀ j ∈ s, i ≠ j → f i ⊔ f j = ⊤)
    (i : ι) (his : i ∈ s) : ∃ r : R, r - 1 ∈ f i ∧ ∀ j ∈ s, j ≠ i → r ∈ f j := by
  have : ∀ j ∈ s, j ≠ i → ∃ r : R, ∃ H : r - 1 ∈ f i, r ∈ f j := by
    intro j hjs hji
    specialize hf i his j hjs hji.symm
    rw [eq_top_iff_one, Submodule.mem_sup] at hf
    rcases hf with ⟨r, hri, s, hsj, hrs⟩
    refine' ⟨1 - r, _, _⟩
    · rw [sub_right_comm, sub_self, zero_sub]
      exact (f i).neg_mem hri
      
    · rw [← hrs, add_sub_cancel']
      exact hsj
      
  classical
  have : ∃ g : ι → R, (∀ j, g j - 1 ∈ f i) ∧ ∀ j ∈ s, j ≠ i → g j ∈ f j := by
    choose g hg1 hg2
    refine' ⟨fun j => if H : j ∈ s ∧ j ≠ i then g j H.1 H.2 else 1, fun j => _, fun j => _⟩
    · split_ifs with h
      · apply hg1
        
      rw [sub_self]
      exact (f i).zero_mem
      
    · intro hjs hji
      rw [dif_pos]
      · apply hg2
        
      exact ⟨hjs, hji⟩
      
  rcases this with ⟨g, hgi, hgj⟩
  use ∏ x in s.erase i, g x
  constructor
  · rw [← Quotient.eq, RingHom.map_one, RingHom.map_prod]
    apply Finset.prod_eq_one
    intros
    rw [← RingHom.map_one, Quotient.eq]
    apply hgi
    
  intro j hjs hji
  rw [← quotient.eq_zero_iff_mem, RingHom.map_prod]
  refine' Finset.prod_eq_zero (Finset.mem_erase_of_ne_of_mem hji hjs) _
  rw [quotient.eq_zero_iff_mem]
  exact hgj j hjs hji
#align ideal.exists_sub_one_mem_and_mem Ideal.exists_sub_one_mem_and_mem

theorem exists_sub_mem [Finite ι] {f : ι → Ideal R} (hf : ∀ i j, i ≠ j → f i ⊔ f j = ⊤) (g : ι → R) :
    ∃ r : R, ∀ i, r - g i ∈ f i := by
  cases nonempty_fintype ι
  have : ∃ φ : ι → R, (∀ i, φ i - 1 ∈ f i) ∧ ∀ i j, i ≠ j → φ i ∈ f j := by
    have := exists_sub_one_mem_and_mem (Finset.univ : Finset ι) fun i _ j _ hij => hf i j hij
    choose φ hφ
    exists fun i => φ i (Finset.mem_univ i)
    exact ⟨fun i => (hφ i _).1, fun i j hij => (hφ i _).2 j (Finset.mem_univ j) hij.symm⟩
  rcases this with ⟨φ, hφ1, hφ2⟩
  use ∑ i, g i * φ i
  intro i
  rw [← Quotient.eq, RingHom.map_sum]
  refine' Eq.trans (Finset.sum_eq_single i _ _) _
  · intro j _ hji
    rw [quotient.eq_zero_iff_mem]
    exact (f i).mul_mem_left _ (hφ2 j i hji)
    
  · intro hi
    exact (hi <| Finset.mem_univ i).elim
    
  specialize hφ1 i
  rw [← Quotient.eq, RingHom.map_one] at hφ1
  rw [RingHom.map_mul, hφ1, mul_one]
#align ideal.exists_sub_mem Ideal.exists_sub_mem

/-- The homomorphism from `R/(⋂ i, f i)` to `∏ i, (R / f i)` featured in the Chinese
  Remainder Theorem. It is bijective if the ideals `f i` are comaximal. -/
def quotientInfToPiQuotient (f : ι → Ideal R) : (R ⧸ ⨅ i, f i) →+* ∀ i, R ⧸ f i :=
  (Quotient.lift (⨅ i, f i) (Pi.ringHom fun i : ι => (Quotient.mk (f i) : _))) fun r hr => by
    rw [Submodule.mem_infi] at hr
    ext i
    exact quotient.eq_zero_iff_mem.2 (hr i)
#align ideal.quotient_inf_to_pi_quotient Ideal.quotientInfToPiQuotient

theorem quotient_inf_to_pi_quotient_bijective [Finite ι] {f : ι → Ideal R} (hf : ∀ i j, i ≠ j → f i ⊔ f j = ⊤) :
    Function.Bijective (quotientInfToPiQuotient f) :=
  ⟨fun x y =>
    (Quotient.inductionOn₂' x y) fun r s hrs =>
      Quotient.eq.2 <|
        (Submodule.mem_infi _).2 fun i =>
          Quotient.eq.1 <| show quotientInfToPiQuotient f (Quotient.mk' r) i = _ by rw [hrs] <;> rfl,
    fun g =>
    let ⟨r, hr⟩ := exists_sub_mem hf fun i => Quotient.out' (g i)
    ⟨Quotient.mk _ r, funext fun i => Quotient.out_eq' (g i) ▸ Quotient.eq.2 (hr i)⟩⟩
#align ideal.quotient_inf_to_pi_quotient_bijective Ideal.quotient_inf_to_pi_quotient_bijective

/-- Chinese Remainder Theorem. Eisenbud Ex.2.6. Similar to Atiyah-Macdonald 1.10 and Stacks 00DT -/
noncomputable def quotientInfRingEquivPiQuotient [Finite ι] (f : ι → Ideal R) (hf : ∀ i j, i ≠ j → f i ⊔ f j = ⊤) :
    (R ⧸ ⨅ i, f i) ≃+* ∀ i, R ⧸ f i :=
  { Equiv.ofBijective _ (quotient_inf_to_pi_quotient_bijective hf), quotientInfToPiQuotient f with }
#align ideal.quotient_inf_ring_equiv_pi_quotient Ideal.quotientInfRingEquivPiQuotient

end ChineseRemainder

/-- **Chinese remainder theorem**, specialized to two ideals. -/
noncomputable def quotientInfEquivQuotientProd (I J : Ideal R) (coprime : I ⊔ J = ⊤) : R ⧸ I ⊓ J ≃+* (R ⧸ I) × R ⧸ J :=
  let f : Fin 2 → Ideal R := ![I, J]
  have hf : ∀ i j : Fin 2, i ≠ j → f i ⊔ f j = ⊤ := by
    intro i j h
    fin_cases i <;> fin_cases j <;> try contradiction <;> simpa [f, sup_comm] using coprime
  (Ideal.quotEquivOfEq (by simp [infi, inf_comm])).trans <|
    (Ideal.quotientInfRingEquivPiQuotient f hf).trans <| RingEquiv.piFinTwo fun i => R ⧸ f i
#align ideal.quotient_inf_equiv_quotient_prod Ideal.quotientInfEquivQuotientProd

@[simp]
theorem quotient_inf_equiv_quotient_prod_fst (I J : Ideal R) (coprime : I ⊔ J = ⊤) (x : R ⧸ I ⊓ J) :
    (quotientInfEquivQuotientProd I J coprime x).fst = Ideal.Quotient.factor (I ⊓ J) I inf_le_left x :=
  Quot.induction_on x fun x => rfl
#align ideal.quotient_inf_equiv_quotient_prod_fst Ideal.quotient_inf_equiv_quotient_prod_fst

@[simp]
theorem quotient_inf_equiv_quotient_prod_snd (I J : Ideal R) (coprime : I ⊔ J = ⊤) (x : R ⧸ I ⊓ J) :
    (quotientInfEquivQuotientProd I J coprime x).snd = Ideal.Quotient.factor (I ⊓ J) J inf_le_right x :=
  Quot.induction_on x fun x => rfl
#align ideal.quotient_inf_equiv_quotient_prod_snd Ideal.quotient_inf_equiv_quotient_prod_snd

@[simp]
theorem fst_comp_quotient_inf_equiv_quotient_prod (I J : Ideal R) (coprime : I ⊔ J = ⊤) :
    (RingHom.fst _ _).comp (quotientInfEquivQuotientProd I J coprime : R ⧸ I ⊓ J →+* (R ⧸ I) × R ⧸ J) =
      Ideal.Quotient.factor (I ⊓ J) I inf_le_left :=
  by ext <;> rfl
#align ideal.fst_comp_quotient_inf_equiv_quotient_prod Ideal.fst_comp_quotient_inf_equiv_quotient_prod

@[simp]
theorem snd_comp_quotient_inf_equiv_quotient_prod (I J : Ideal R) (coprime : I ⊔ J = ⊤) :
    (RingHom.snd _ _).comp (quotientInfEquivQuotientProd I J coprime : R ⧸ I ⊓ J →+* (R ⧸ I) × R ⧸ J) =
      Ideal.Quotient.factor (I ⊓ J) J inf_le_right :=
  by ext <;> rfl
#align ideal.snd_comp_quotient_inf_equiv_quotient_prod Ideal.snd_comp_quotient_inf_equiv_quotient_prod

end Ideal

