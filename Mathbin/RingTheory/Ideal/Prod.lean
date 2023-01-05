/-
Copyright (c) 2020 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module ring_theory.ideal.prod
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Ideal.Operations

/-!
# Ideals in product rings

For commutative rings `R` and `S` and ideals `I ≤ R`, `J ≤ S`, we define `ideal.prod I J` as the
product `I × J`, viewed as an ideal of `R × S`. In `ideal_prod_eq` we show that every ideal of
`R × S` is of this form.  Furthermore, we show that every prime ideal of `R × S` is of the form
`p × S` or `R × p`, where `p` is a prime ideal.
-/


universe u v

variable {R : Type u} {S : Type v} [Ring R] [Ring S] (I I' : Ideal R) (J J' : Ideal S)

namespace Ideal

/-- `I × J` as an ideal of `R × S`. -/
def prod : Ideal (R × S) where
  carrier := { x | x.fst ∈ I ∧ x.snd ∈ J }
  zero_mem' := by simp
  add_mem' := by
    rintro ⟨a₁, a₂⟩ ⟨b₁, b₂⟩ ⟨ha₁, ha₂⟩ ⟨hb₁, hb₂⟩
    exact ⟨I.add_mem ha₁ hb₁, J.add_mem ha₂ hb₂⟩
  smul_mem' := by
    rintro ⟨a₁, a₂⟩ ⟨b₁, b₂⟩ ⟨hb₁, hb₂⟩
    exact ⟨I.mul_mem_left _ hb₁, J.mul_mem_left _ hb₂⟩
#align ideal.prod Ideal.prod

@[simp]
theorem mem_prod {r : R} {s : S} : (⟨r, s⟩ : R × S) ∈ prod I J ↔ r ∈ I ∧ s ∈ J :=
  Iff.rfl
#align ideal.mem_prod Ideal.mem_prod

@[simp]
theorem prod_top_top : prod (⊤ : Ideal R) (⊤ : Ideal S) = ⊤ :=
  Ideal.ext <| by simp
#align ideal.prod_top_top Ideal.prod_top_top

/-- Every ideal of the product ring is of the form `I × J`, where `I` and `J` can be explicitly
    given as the image under the projection maps. -/
theorem ideal_prod_eq (I : Ideal (R × S)) :
    I = Ideal.prod (map (RingHom.fst R S) I) (map (RingHom.snd R S) I) :=
  by
  apply Ideal.ext
  rintro ⟨r, s⟩
  rw [mem_prod, mem_map_iff_of_surjective (RingHom.fst R S) Prod.fst_surjective,
    mem_map_iff_of_surjective (RingHom.snd R S) Prod.snd_surjective]
  refine' ⟨fun h => ⟨⟨_, ⟨h, rfl⟩⟩, ⟨_, ⟨h, rfl⟩⟩⟩, _⟩
  rintro ⟨⟨⟨r, s'⟩, ⟨h₁, rfl⟩⟩, ⟨⟨r', s⟩, ⟨h₂, rfl⟩⟩⟩
  simpa using I.add_mem (I.mul_mem_left (1, 0) h₁) (I.mul_mem_left (0, 1) h₂)
#align ideal.ideal_prod_eq Ideal.ideal_prod_eq

@[simp]
theorem map_fst_prod (I : Ideal R) (J : Ideal S) : map (RingHom.fst R S) (prod I J) = I :=
  by
  ext
  rw [mem_map_iff_of_surjective (RingHom.fst R S) Prod.fst_surjective]
  exact
    ⟨by
      rintro ⟨x, ⟨h, rfl⟩⟩
      exact h.1, fun h => ⟨⟨x, 0⟩, ⟨⟨h, Ideal.zero_mem _⟩, rfl⟩⟩⟩
#align ideal.map_fst_prod Ideal.map_fst_prod

@[simp]
theorem map_snd_prod (I : Ideal R) (J : Ideal S) : map (RingHom.snd R S) (prod I J) = J :=
  by
  ext
  rw [mem_map_iff_of_surjective (RingHom.snd R S) Prod.snd_surjective]
  exact
    ⟨by
      rintro ⟨x, ⟨h, rfl⟩⟩
      exact h.2, fun h => ⟨⟨0, x⟩, ⟨⟨Ideal.zero_mem _, h⟩, rfl⟩⟩⟩
#align ideal.map_snd_prod Ideal.map_snd_prod

@[simp]
theorem map_prod_comm_prod :
    map ((RingEquiv.prodComm : R × S ≃+* S × R) : R × S →+* S × R) (prod I J) = prod J I :=
  by
  refine' trans (ideal_prod_eq _) _
  simp [map_map]
#align ideal.map_prod_comm_prod Ideal.map_prod_comm_prod

/-- Ideals of `R × S` are in one-to-one correspondence with pairs of ideals of `R` and ideals of
    `S`. -/
def idealProdEquiv : Ideal (R × S) ≃ Ideal R × Ideal S
    where
  toFun I := ⟨map (RingHom.fst R S) I, map (RingHom.snd R S) I⟩
  invFun I := prod I.1 I.2
  left_inv I := (ideal_prod_eq I).symm
  right_inv := fun ⟨I, J⟩ => by simp
#align ideal.ideal_prod_equiv Ideal.idealProdEquiv

@[simp]
theorem ideal_prod_equiv_symm_apply (I : Ideal R) (J : Ideal S) :
    idealProdEquiv.symm ⟨I, J⟩ = prod I J :=
  rfl
#align ideal.ideal_prod_equiv_symm_apply Ideal.ideal_prod_equiv_symm_apply

theorem prod.ext_iff {I I' : Ideal R} {J J' : Ideal S} : prod I J = prod I' J' ↔ I = I' ∧ J = J' :=
  by
  simp only [← ideal_prod_equiv_symm_apply, ideal_prod_equiv.symm.injective.eq_iff, Prod.mk.inj_iff]
#align ideal.prod.ext_iff Ideal.prod.ext_iff

theorem isPrimeOfIsPrimeProdTop {I : Ideal R} (h : (Ideal.prod I (⊤ : Ideal S)).IsPrime) :
    I.IsPrime := by
  constructor
  · contrapose! h
    simp [is_prime_iff, h]
  · intro x y hxy
    have : (⟨x, 1⟩ : R × S) * ⟨y, 1⟩ ∈ Prod I ⊤ :=
      by
      rw [Prod.mk_mul_mk, mul_one, mem_prod]
      exact ⟨hxy, trivial⟩
    simpa using h.mem_or_mem this
#align ideal.is_prime_of_is_prime_prod_top Ideal.isPrimeOfIsPrimeProdTop

theorem isPrimeOfIsPrimeProdTop' {I : Ideal S} (h : (Ideal.prod (⊤ : Ideal R) I).IsPrime) :
    I.IsPrime := by
  apply @is_prime_of_is_prime_prod_top _ R
  rw [← map_prod_comm_prod]
  exact map_is_prime_of_equiv _
#align ideal.is_prime_of_is_prime_prod_top' Ideal.isPrimeOfIsPrimeProdTop'

theorem isPrimeIdealProdTop {I : Ideal R} [h : I.IsPrime] : (prod I (⊤ : Ideal S)).IsPrime :=
  by
  constructor
  · rcases h with ⟨h, -⟩
    contrapose! h
    rw [← prod_top_top, Prod.ext_iff] at h
    exact h.1
  rintro ⟨r₁, s₁⟩ ⟨r₂, s₂⟩ ⟨h₁, h₂⟩
  cases' h.mem_or_mem h₁ with h h
  · exact Or.inl ⟨h, trivial⟩
  · exact Or.inr ⟨h, trivial⟩
#align ideal.is_prime_ideal_prod_top Ideal.isPrimeIdealProdTop

theorem isPrimeIdealProdTop' {I : Ideal S} [h : I.IsPrime] : (prod (⊤ : Ideal R) I).IsPrime :=
  by
  rw [← map_prod_comm_prod]
  apply map_is_prime_of_equiv _
  exact is_prime_ideal_prod_top
#align ideal.is_prime_ideal_prod_top' Ideal.isPrimeIdealProdTop'

theorem ideal_prod_prime_aux {I : Ideal R} {J : Ideal S} :
    (Ideal.prod I J).IsPrime → I = ⊤ ∨ J = ⊤ :=
  by
  contrapose!
  simp only [ne_top_iff_one, is_prime_iff, not_and, not_forall, not_or]
  exact fun ⟨hI, hJ⟩ hIJ => ⟨⟨0, 1⟩, ⟨1, 0⟩, by simp, by simp [hJ], by simp [hI]⟩
#align ideal.ideal_prod_prime_aux Ideal.ideal_prod_prime_aux

/-- Classification of prime ideals in product rings: the prime ideals of `R × S` are precisely the
    ideals of the form `p × S` or `R × p`, where `p` is a prime ideal of `R` or `S`. -/
theorem ideal_prod_prime (I : Ideal (R × S)) :
    I.IsPrime ↔
      (∃ p : Ideal R, p.IsPrime ∧ I = Ideal.prod p ⊤) ∨
        ∃ p : Ideal S, p.IsPrime ∧ I = Ideal.prod ⊤ p :=
  by
  constructor
  · rw [ideal_prod_eq I]
    intro hI
    rcases ideal_prod_prime_aux hI with (h | h)
    · right
      rw [h] at hI⊢
      exact ⟨_, ⟨is_prime_of_is_prime_prod_top' hI, rfl⟩⟩
    · left
      rw [h] at hI⊢
      exact ⟨_, ⟨is_prime_of_is_prime_prod_top hI, rfl⟩⟩
  · rintro (⟨p, ⟨h, rfl⟩⟩ | ⟨p, ⟨h, rfl⟩⟩)
    · exact is_prime_ideal_prod_top
    · exact is_prime_ideal_prod_top'
#align ideal.ideal_prod_prime Ideal.ideal_prod_prime

end Ideal

