import Mathbin.Algebra.Algebra.Operations
import Mathbin.Algebra.DirectSum.Algebra

/-!
# Internally graded rings and algebras

This module provides `gsemiring` and `gcomm_semiring` instances for a collection of subobjects `A`
when a `set_like.graded_monoid` instance is available:

* on `add_submonoid R`s: `add_submonoid.gsemiring`, `add_submonoid.gcomm_semiring`.
* on `add_subgroup R`s: `add_subgroup.gsemiring`, `add_subgroup.gcomm_semiring`.
* on `submodule S R`s: `submodule.gsemiring`, `submodule.gcomm_semiring`.

With these instances in place, it provides the bundled canonical maps out of a direct sum of
subobjects into their carrier type:

* `direct_sum.add_submonoid_coe_ring_hom` (a `ring_hom` version of `direct_sum.add_submonoid_coe`)
* `direct_sum.add_subgroup_coe_ring_hom` (a `ring_hom` version of `direct_sum.add_subgroup_coe`)
* `direct_sum.submodule_coe_alg_hom` (an `alg_hom` version of `direct_sum.submodule_coe`)

Strictly the definitions in this file are not sufficient to fully define an "internal" direct sum;
to represent this case, `(h : direct_sum.submodule_is_internal A) [set_like.graded_monoid A]` is
needed. In the future there will likely be a data-carrying, constructive, typeclass version of
`direct_sum.submodule_is_internal` for providing an explicit decomposition function.

When `complete_lattice.independent (set.range A)` (a weaker condition than
`direct_sum.submodule_is_internal A`), these provide a grading of `⨆ i, A i`, and the
mapping `⨁ i, A i →+ ⨆ i, A i` can be obtained as
`direct_sum.to_monoid (λ i, add_submonoid.inclusion $ le_supr A i)`.

## tags

internally graded ring
-/


open_locale DirectSum BigOperators

variable {ι : Type _} {S R : Type _}

section DirectSum

variable [DecidableEq ι]

/-! #### From `add_submonoid`s -/


namespace AddSubmonoid

/-- Build a `gsemiring` instance for a collection of `add_submonoid`s. -/
instance gsemiring [AddMonoidₓ ι] [Semiringₓ R] (A : ι → AddSubmonoid R) [SetLike.GradedMonoid A] :
    DirectSum.Gsemiring fun i => A i :=
  { SetLike.gmonoid A with mul_zero := fun i j _ => Subtype.ext (mul_zero _),
    zero_mul := fun i j _ => Subtype.ext (zero_mul _), mul_add := fun i j _ _ _ => Subtype.ext (mul_addₓ _ _ _),
    add_mul := fun i j _ _ _ => Subtype.ext (add_mulₓ _ _ _) }

/-- Build a `gcomm_semiring` instance for a collection of `add_submonoid`s. -/
instance gcomm_semiring [AddCommMonoidₓ ι] [CommSemiringₓ R] (A : ι → AddSubmonoid R) [SetLike.GradedMonoid A] :
    DirectSum.GcommSemiring fun i => A i :=
  { SetLike.gcommMonoid A, AddSubmonoid.gsemiring A with }

end AddSubmonoid

/-- The canonical ring isomorphism between `⨁ i, A i` and `R`-/
def DirectSum.submonoidCoeRingHom [AddMonoidₓ ι] [Semiringₓ R] (A : ι → AddSubmonoid R) [h : SetLike.GradedMonoid A] :
    (⨁ i, A i) →+* R :=
  DirectSum.toSemiring (fun i => (A i).Subtype) rfl fun _ _ _ _ => rfl

/-- The canonical ring isomorphism between `⨁ i, A i` and `R`-/
@[simp]
theorem DirectSum.submonoid_coe_ring_hom_of [AddMonoidₓ ι] [Semiringₓ R] (A : ι → AddSubmonoid R)
    [h : SetLike.GradedMonoid A] (i : ι) (x : A i) :
    DirectSum.submonoidCoeRingHom A (DirectSum.of (fun i => A i) i x) = x :=
  DirectSum.to_semiring_of _ _ _ _ _

theorem DirectSum.coe_mul_apply_add_submonoid [AddMonoidₓ ι] [Semiringₓ R] (A : ι → AddSubmonoid R)
    [SetLike.GradedMonoid A] [∀ i : ι x : A i, Decidable (x ≠ 0)] (r r' : ⨁ i, A i) (i : ι) :
    ((r * r') i : R) =
      ∑ ij in Finset.filter (fun ij : ι × ι => ij.1 + ij.2 = i) (r.support.product r'.support), r ij.1 * r' ij.2 :=
  by
  rw [DirectSum.mul_eq_sum_support_ghas_mul, Dfinsupp.finset_sum_apply, AddSubmonoid.coe_finset_sum]
  simp_rw [DirectSum.coe_of_add_submonoid_apply, ← Finset.sum_filter, SetLike.coe_ghas_mul]

/-! #### From `add_subgroup`s -/


namespace AddSubgroup

/-- Build a `gsemiring` instance for a collection of `add_subgroup`s. -/
instance gsemiring [AddMonoidₓ ι] [Ringₓ R] (A : ι → AddSubgroup R) [h : SetLike.GradedMonoid A] :
    DirectSum.Gsemiring fun i => A i :=
  have i' : SetLike.GradedMonoid fun i => (A i).toAddSubmonoid := { h with }
  AddSubmonoid.gsemiring fun i => (A i).toAddSubmonoid

/-- Build a `gcomm_semiring` instance for a collection of `add_subgroup`s. -/
instance gcomm_semiring [AddCommGroupₓ ι] [CommRingₓ R] (A : ι → AddSubgroup R) [h : SetLike.GradedMonoid A] :
    DirectSum.Gsemiring fun i => A i :=
  have i' : SetLike.GradedMonoid fun i => (A i).toAddSubmonoid := { h with }
  AddSubmonoid.gsemiring fun i => (A i).toAddSubmonoid

end AddSubgroup

/-- The canonical ring isomorphism between `⨁ i, A i` and `R`. -/
def DirectSum.subgroupCoeRingHom [AddMonoidₓ ι] [Ringₓ R] (A : ι → AddSubgroup R) [SetLike.GradedMonoid A] :
    (⨁ i, A i) →+* R :=
  DirectSum.toSemiring (fun i => (A i).Subtype) rfl fun _ _ _ _ => rfl

@[simp]
theorem DirectSum.subgroup_coe_ring_hom_of [AddMonoidₓ ι] [Ringₓ R] (A : ι → AddSubgroup R) [SetLike.GradedMonoid A]
    (i : ι) (x : A i) : DirectSum.subgroupCoeRingHom A (DirectSum.of (fun i => A i) i x) = x :=
  DirectSum.to_semiring_of _ _ _ _ _

theorem DirectSum.coe_mul_apply_add_subgroup [AddMonoidₓ ι] [Ringₓ R] (A : ι → AddSubgroup R) [SetLike.GradedMonoid A]
    [∀ i : ι x : A i, Decidable (x ≠ 0)] (r r' : ⨁ i, A i) (i : ι) :
    ((r * r') i : R) =
      ∑ ij in Finset.filter (fun ij : ι × ι => ij.1 + ij.2 = i) (r.support.product r'.support), r ij.1 * r' ij.2 :=
  by
  rw [DirectSum.mul_eq_sum_support_ghas_mul, Dfinsupp.finset_sum_apply, AddSubgroup.coe_finset_sum]
  simp_rw [DirectSum.coe_of_add_subgroup_apply, ← Finset.sum_filter, SetLike.coe_ghas_mul]

/-! #### From `submodules`s -/


namespace Submodule

/-- Build a `gsemiring` instance for a collection of `submodule`s. -/
instance gsemiring [AddMonoidₓ ι] [CommSemiringₓ S] [Semiringₓ R] [Algebra S R] (A : ι → Submodule S R)
    [h : SetLike.GradedMonoid A] : DirectSum.Gsemiring fun i => A i :=
  have i' : SetLike.GradedMonoid fun i => (A i).toAddSubmonoid := { h with }
  AddSubmonoid.gsemiring fun i => (A i).toAddSubmonoid

/-- Build a `gsemiring` instance for a collection of `submodule`s. -/
instance gcomm_semiring [AddCommMonoidₓ ι] [CommSemiringₓ S] [CommSemiringₓ R] [Algebra S R] (A : ι → Submodule S R)
    [h : SetLike.GradedMonoid A] : DirectSum.GcommSemiring fun i => A i :=
  have i' : SetLike.GradedMonoid fun i => (A i).toAddSubmonoid := { h with }
  AddSubmonoid.gcommSemiring fun i => (A i).toAddSubmonoid

/-- Build a `galgebra` instance for a collection of `submodule`s. -/
instance galgebra [AddMonoidₓ ι] [CommSemiringₓ S] [Semiringₓ R] [Algebra S R] (A : ι → Submodule S R)
    [h : SetLike.GradedMonoid A] : DirectSum.Galgebra S fun i => A i where
  toFun := by
    refine' ((Algebra.linearMap S R).codRestrict (A 0) $ fun r => _).toAddMonoidHom
    exact submodule.one_le.mpr SetLike.HasGradedOne.one_mem (Submodule.algebra_map_mem _)
  map_one := Subtype.ext $ (algebraMap S R).map_one
  map_mul := fun x y => Sigma.subtype_ext (add_zeroₓ 0).symm $ (algebraMap S R).map_mul _ _
  commutes := fun r ⟨i, xi⟩ => Sigma.subtype_ext ((zero_addₓ i).trans (add_zeroₓ i).symm) $ Algebra.commutes _ _
  smul_def := fun r ⟨i, xi⟩ => Sigma.subtype_ext (zero_addₓ i).symm $ Algebra.smul_def _ _

@[simp]
theorem set_like.coe_galgebra_to_fun [AddMonoidₓ ι] [CommSemiringₓ S] [Semiringₓ R] [Algebra S R]
    (A : ι → Submodule S R) [h : SetLike.GradedMonoid A] (s : S) :
    ↑@DirectSum.Galgebra.toFun _ S (fun i => A i) _ _ _ _ _ _ _ s = (algebraMap S R s : R) :=
  rfl

/-- A direct sum of powers of a submodule of an algebra has a multiplicative structure. -/
instance nat_power_graded_monoid [CommSemiringₓ S] [Semiringₓ R] [Algebra S R] (p : Submodule S R) :
    SetLike.GradedMonoid fun i : ℕ => p ^ i where
  one_mem := by
    rw [← one_le, pow_zeroₓ]
    exact le_rfl
  mul_mem := fun i j p q hp hq => by
    rw [pow_addₓ]
    exact Submodule.mul_mem_mul hp hq

end Submodule

/-- The canonical algebra isomorphism between `⨁ i, A i` and `R`. -/
def DirectSum.submoduleCoeAlgHom [AddMonoidₓ ι] [CommSemiringₓ S] [Semiringₓ R] [Algebra S R] (A : ι → Submodule S R)
    [h : SetLike.GradedMonoid A] : (⨁ i, A i) →ₐ[S] R :=
  DirectSum.toAlgebra S _ (fun i => (A i).Subtype) rfl (fun _ _ _ _ => rfl) fun _ => rfl

@[simp]
theorem DirectSum.submodule_coe_alg_hom_of [AddMonoidₓ ι] [CommSemiringₓ S] [Semiringₓ R] [Algebra S R]
    (A : ι → Submodule S R) [h : SetLike.GradedMonoid A] (i : ι) (x : A i) :
    DirectSum.submoduleCoeAlgHom A (DirectSum.of (fun i => A i) i x) = x :=
  DirectSum.to_semiring_of _ rfl (fun _ _ _ _ => rfl) _ _

theorem DirectSum.coe_mul_apply_submodule [AddMonoidₓ ι] [CommSemiringₓ S] [Semiringₓ R] [Algebra S R]
    (A : ι → Submodule S R) [∀ i : ι x : A i, Decidable (x ≠ 0)] [SetLike.GradedMonoid A] (r r' : ⨁ i, A i) (i : ι) :
    ((r * r') i : R) =
      ∑ ij in Finset.filter (fun ij : ι × ι => ij.1 + ij.2 = i) (r.support.product r'.support), r ij.1 * r' ij.2 :=
  by
  rw [DirectSum.mul_eq_sum_support_ghas_mul, Dfinsupp.finset_sum_apply, Submodule.coe_sum]
  simp_rw [DirectSum.coe_of_submodule_apply, ← Finset.sum_filter, SetLike.coe_ghas_mul]

end DirectSum

section HomogeneousElement

theorem SetLike.is_homogeneous_zero_submodule [Zero ι] [Semiringₓ S] [AddCommMonoidₓ R] [Module S R]
    (A : ι → Submodule S R) : SetLike.IsHomogeneous A (0 : R) :=
  ⟨0, Submodule.zero_mem _⟩

theorem SetLike.IsHomogeneous.smul [CommSemiringₓ S] [Semiringₓ R] [Algebra S R] {A : ι → Submodule S R} {s : S} {r : R}
    (hr : SetLike.IsHomogeneous A r) : SetLike.IsHomogeneous A (s • r) :=
  let ⟨i, hi⟩ := hr
  ⟨i, Submodule.smul_mem _ _ hi⟩

end HomogeneousElement

