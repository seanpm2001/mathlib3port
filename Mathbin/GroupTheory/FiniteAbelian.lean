/-
Copyright (c) 2022 Pierre-Alexandre Bazin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Pierre-Alexandre Bazin

! This file was ported from Lean 3 source module group_theory.finite_abelian
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Pid
import Mathbin.Data.Zmod.Quotient

/-!
# Structure of finite(ly generated) abelian groups

* `add_comm_group.equiv_free_prod_direct_sum_zmod` : Any finitely generated abelian group is the
  product of a power of `ℤ` and a direct sum of some `zmod (p i ^ e i)` for some prime powers
  `p i ^ e i`.
* `add_comm_group.equiv_direct_sum_zmod_of_fintype` : Any finite abelian group is a direct sum of
  some `zmod (p i ^ e i)` for some prime powers `p i ^ e i`.

-/


open DirectSum

universe u

namespace Module

variable (M : Type u)

theorem finite_of_fg_torsion [AddCommGroup M] [Module ℤ M] [Module.Finite ℤ M]
    (hM : Module.IsTorsion ℤ M) : Finite M :=
  by
  rcases Module.equiv_direct_sum_of_is_torsion hM with ⟨ι, _, p, h, e, ⟨l⟩⟩
  haveI : ∀ i : ι, NeZero (p i ^ e i).natAbs := fun i =>
    ⟨Int.natAbs_ne_zero_of_ne_zero <| pow_ne_zero (e i) (h i).NeZero⟩
  haveI : ∀ i : ι, _root_.finite <| ℤ ⧸ Submodule.span ℤ {p i ^ e i} := fun i =>
    Finite.of_equiv _ (p i ^ e i).quotientSpanEquivZmod.symm.toEquiv
  haveI : _root_.finite (⨁ i, ℤ ⧸ (Submodule.span ℤ {p i ^ e i} : Submodule ℤ ℤ)) :=
    Finite.of_equiv _ dfinsupp.equiv_fun_on_fintype.symm
  exact Finite.of_equiv _ l.symm.to_equiv
#align module.finite_of_fg_torsion Module.finite_of_fg_torsion

end Module

variable (G : Type u)

namespace AddCommGroup

variable [AddCommGroup G]

/-- **Structure theorem of finitely generated abelian groups** : Any finitely generated abelian
group is the product of a power of `ℤ` and a direct sum of some `zmod (p i ^ e i)` for some
prime powers `p i ^ e i`. -/
theorem equiv_free_prod_direct_sum_zmod [hG : AddGroup.Fg G] :
    ∃ (n : ℕ)(ι : Type)(_ : Fintype ι)(p : ι → ℕ)(_ : ∀ i, Nat.Prime <| p i)(e : ι → ℕ),
      Nonempty <| G ≃+ (Fin n →₀ ℤ) × ⨁ i : ι, Zmod (p i ^ e i) :=
  by
  obtain ⟨n, ι, fι, p, hp, e, ⟨f⟩⟩ :=
    @Module.equiv_free_prod_direct_sum _ _ _ _ _ _ _ (module.finite.iff_add_group_fg.mpr hG)
  refine' ⟨n, ι, fι, fun i => (p i).natAbs, fun i => _, e, ⟨_⟩⟩
  · rw [← Int.prime_iff_nat_abs_prime, ← GCDMonoid.irreducible_iff_prime]
    exact hp i
  exact
    f.to_add_equiv.trans
      ((AddEquiv.refl _).prodCongr <|
        Dfinsupp.mapRange.addEquiv fun i =>
          ((Int.quotientSpanEquivZmod _).trans <|
              Zmod.ringEquivCongr <| (p i).nat_abs_pow _).toAddEquiv)
#align add_comm_group.equiv_free_prod_direct_sum_zmod AddCommGroup.equiv_free_prod_direct_sum_zmod

/-- **Structure theorem of finite abelian groups** : Any finite abelian group is a direct sum of
some `zmod (p i ^ e i)` for some prime powers `p i ^ e i`. -/
theorem equiv_direct_sum_zmod_of_fintype [Finite G] :
    ∃ (ι : Type)(_ : Fintype ι)(p : ι → ℕ)(_ : ∀ i, Nat.Prime <| p i)(e : ι → ℕ),
      Nonempty <| G ≃+ ⨁ i : ι, Zmod (p i ^ e i) :=
  by
  cases nonempty_fintype G
  obtain ⟨n, ι, fι, p, hp, e, ⟨f⟩⟩ := equiv_free_prod_direct_sum_zmod G
  cases n
  · exact ⟨ι, fι, p, hp, e, ⟨f.trans AddEquiv.uniqueProd⟩⟩
  · haveI := @Fintype.prodLeft _ _ _ (Fintype.ofEquiv G f.to_equiv) _
    exact
      ((Fintype.ofSurjective fun f : Fin n.succ →₀ ℤ => f 0) fun a =>
            ⟨Finsupp.single 0 a, Finsupp.single_eq_same⟩).False.elim
#align add_comm_group.equiv_direct_sum_zmod_of_fintype AddCommGroup.equiv_direct_sum_zmod_of_fintype

theorem finite_of_fg_torsion [hG' : AddGroup.Fg G] (hG : AddMonoid.IsTorsion G) : Finite G :=
  @Module.finite_of_fg_torsion _ _ _ (Module.Finite.iff_add_group_fg.mpr hG') <|
    AddMonoid.is_torsion_iff_is_torsion_int.mp hG
#align add_comm_group.finite_of_fg_torsion AddCommGroup.finite_of_fg_torsion

end AddCommGroup

namespace CommGroup

theorem finite_of_fg_torsion [CommGroup G] [Group.Fg G] (hG : Monoid.IsTorsion G) : Finite G :=
  @Finite.of_equiv _ _ (AddCommGroup.finite_of_fg_torsion (Additive G) hG) Multiplicative.ofAdd
#align comm_group.finite_of_fg_torsion CommGroup.finite_of_fg_torsion

end CommGroup

