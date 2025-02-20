/-
Copyright (c) 2023 Amelia Livingston. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Amelia Livingston

! This file was ported from Lean 3 source module representation_theory.group_cohomology.basic
! leanprover-community/mathlib commit cc5dd6244981976cc9da7afc4eee5682b037a013
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Homology.Opposite
import Mathbin.RepresentationTheory.GroupCohomology.Resolution

/-!
# The group cohomology of a `k`-linear `G`-representation

Let `k` be a commutative ring and `G` a group. This file defines the group cohomology of
`A : Rep k G` to be the cohomology of the complex
$$0 \to \mathrm{Fun}(G^0, A) \to \mathrm{Fun}(G^1, A) \to \mathrm{Fun}(G^2, A) \to \dots$$
with differential $d^n$ sending $f: G^n \to A$ to the function mapping $(g_0, \dots, g_n)$ to
$$\rho(g_0)(f(g_1, \dots, g_n))
+ \sum_{i = 0}^{n - 1} (-1)^{i + 1}\cdot f(g_0, \dots, g_ig_{i + 1}, \dots, g_n)$$
$$+ (-1)^{n + 1}\cdot f(g_0, \dots, g_{n - 1})$$ (where `ρ` is the representation attached to `A`).

We have a `k`-linear isomorphism $\mathrm{Fun}(G^n, A) \cong \mathrm{Hom}(k[G^{n + 1}], A)$, where
the righthand side is morphisms in `Rep k G`, and the representation on $k[G^{n + 1}]$
is induced by the diagonal action of `G`. If we conjugate the $n$th differential in
$\mathrm{Hom}(P, A)$ by this isomorphism, where `P` is the standard resolution of `k` as a trivial
`k`-linear `G`-representation, then the resulting map agrees with the differential $d^n$ defined
above, a fact we prove.

This gives us for free a proof that our $d^n$ squares to zero. It also gives us an isomorphism
$\mathrm{H}^n(G, A) \cong \mathrm{Ext}^n(k, A),$ where $\mathrm{Ext}$ is taken in the category
`Rep k G`.

## Main definitions

* `group_cohomology.linear_yoneda_obj_resolution A`: a complex whose objects are the representation
morphisms $\mathrm{Hom}(k[G^{n + 1}], A)$ and whose cohomology is the group cohomology
$\mathrm{H}^n(G, A)$.
* `group_cohomology.inhomogeneous_cochains A`: a complex whose objects are
$\mathrm{Fun}(G^n, A)$ and whose cohomology is the group cohomology $\mathrm{H}^n(G, A).$
* `group_cohomology.inhomogeneous_cochains_iso A`: an isomorphism between the above two complexes.
* `group_cohomology A n`: this is $\mathrm{H}^n(G, A),$ defined as the $n$th cohomology of the
second complex, `inhomogeneous_cochains A`.
* `group_cohomology_iso_Ext A n`: an isomorphism $\mathrm{H}^n(G, A) \cong \mathrm{Ext}^n(k, A)$
(where $\mathrm{Ext}$ is taken in the category `Rep k G`) induced by `inhomogeneous_cochains_iso A`.

## Implementation notes

Group cohomology is typically stated for `G`-modules, or equivalently modules over the group ring
`ℤ[G].` However, `ℤ` can be generalized to any commutative ring `k`, which is what we use.
Moreover, we express `k[G]`-module structures on a module `k`-module `A` using the `Rep`
definition. We avoid using instances `module (monoid_algebra k G) A` so that we do not run into
possible scalar action diamonds.

## TODO

* API for cohomology in low degree: $\mathrm{H}^0, \mathrm{H}^1$ and $\mathrm{H}^2.$ For example,
the inflation-restriction exact sequence.
* The long exact sequence in cohomology attached to a short exact sequence of representations.
* Upgrading `group_cohomology_iso_Ext` to an isomorphism of derived functors.
* Profinite cohomology.

Longer term:
* The Hochschild-Serre spectral sequence (this is perhaps a good toy example for the theory of
spectral sequences in general).
-/


noncomputable section

universe u

variable {k G : Type u} [CommRing k] {n : ℕ}

open CategoryTheory

namespace groupCohomology

variable [Monoid G]

/-- The complex `Hom(P, A)`, where `P` is the standard resolution of `k` as a trivial `k`-linear
`G`-representation. -/
abbrev linearYonedaObjResolution (A : Rep k G) : CochainComplex (ModuleCat.{u} k) ℕ :=
  HomologicalComplex.unop
    ((((linearYoneda k (Rep k G)).obj A).rightOp.mapHomologicalComplex _).obj (resolution k G))
#align group_cohomology.linear_yoneda_obj_resolution GroupCohomology.linearYonedaObjResolution

theorem linearYonedaObjResolution_d_apply {A : Rep k G} (i j : ℕ) (x : (resolution k G).pt i ⟶ A) :
    (linearYonedaObjResolution A).d i j x = (resolution k G).d j i ≫ x :=
  rfl
#align group_cohomology.linear_yoneda_obj_resolution_d_apply GroupCohomology.linearYonedaObjResolution_d_apply

end groupCohomology

namespace InhomogeneousCochains

open Rep groupCohomology

/-- The differential in the complex of inhomogeneous cochains used to
calculate group cohomology. -/
@[simps]
def d [Monoid G] (n : ℕ) (A : Rep k G) : ((Fin n → G) → A) →ₗ[k] (Fin (n + 1) → G) → A
    where
  toFun f g :=
    A.ρ (g 0) (f fun i => g i.succ) +
      Finset.univ.Sum fun j : Fin (n + 1) =>
        (-1 : k) ^ ((j : ℕ) + 1) • f (Fin.contractNth j (· * ·) g)
  map_add' f g := by
    ext x
    simp only [Pi.add_apply, map_add, smul_add, Finset.sum_add_distrib, add_add_add_comm]
  map_smul' r f := by
    ext x
    simp only [Pi.smul_apply, RingHom.id_apply, map_smul, smul_add, Finset.smul_sum, ← smul_assoc,
      smul_eq_mul, mul_comm r]
#align inhomogeneous_cochains.d InhomogeneousCochains.d

variable [Group G] (n) (A : Rep k G)

/-- The theorem that our isomorphism `Fun(Gⁿ, A) ≅ Hom(k[Gⁿ⁺¹], A)` (where the righthand side is
morphisms in `Rep k G`) commutes with the differentials in the complex of inhomogeneous cochains
and the homogeneous `linear_yoneda_obj_resolution`. -/
theorem d_eq :
    d n A =
      (diagonalHomEquiv n A).toModuleIso.inv ≫
        (linearYonedaObjResolution A).d n (n + 1) ≫ (diagonalHomEquiv (n + 1) A).toModuleIso.Hom :=
  by
  ext f g
  simp only [ModuleCat.coe_comp, LinearEquiv.coe_coe, Function.comp_apply,
    LinearEquiv.toModuleIso_inv, linear_yoneda_obj_resolution_d_apply, LinearEquiv.toModuleIso_hom,
    diagonal_hom_equiv_apply, Action.comp_hom, resolution.d_eq k G n,
    resolution.d_of (Fin.partialProd g), LinearMap.map_sum, ←
    Finsupp.smul_single_one _ ((-1 : k) ^ _), map_smul, d_apply]
  simp only [@Fin.sum_univ_succ _ _ (n + 1), Fin.val_zero, pow_zero, one_smul, Fin.succAbove_zero,
    diagonal_hom_equiv_symm_apply f (Fin.partialProd g ∘ @Fin.succ (n + 1)), Function.comp_apply,
    Fin.partialProd_succ, Fin.castSucc_zero, Fin.partialProd_zero, one_mul]
  congr 1
  · congr
    ext
    have := Fin.partialProd_right_inv g (Fin.castSucc x)
    simp only [mul_inv_rev, Fin.castSucc_fin_succ] at *
    rw [mul_assoc, ← mul_assoc _ _ (g x.succ), this, inv_mul_cancel_left]
  ·
    exact
      Finset.sum_congr rfl fun j hj => by
        rw [diagonal_hom_equiv_symm_partial_prod_succ, Fin.val_succ]
#align inhomogeneous_cochains.d_eq InhomogeneousCochains.d_eq

end InhomogeneousCochains

namespace groupCohomology

variable [Group G] (n) (A : Rep k G)

open InhomogeneousCochains

/-- Given a `k`-linear `G`-representation `A`, this is the complex of inhomogeneous cochains
$$0 \to \mathrm{Fun}(G^0, A) \to \mathrm{Fun}(G^1, A) \to \mathrm{Fun}(G^2, A) \to \dots$$
which calculates the group cohomology of `A`. -/
noncomputable abbrev inhomogeneousCochains : CochainComplex (ModuleCat k) ℕ :=
  CochainComplex.of (fun n => ModuleCat.of k ((Fin n → G) → A))
    (fun n => InhomogeneousCochains.d n A) fun n =>
    by
    ext x y
    have := LinearMap.ext_iff.1 ((linear_yoneda_obj_resolution A).d_comp_d n (n + 1) (n + 2))
    simp only [ModuleCat.coe_comp, Function.comp_apply] at this 
    simp only [ModuleCat.coe_comp, Function.comp_apply, d_eq, LinearEquiv.toModuleIso_hom,
      LinearEquiv.toModuleIso_inv, LinearEquiv.coe_coe, LinearEquiv.symm_apply_apply, this,
      LinearMap.zero_apply, map_zero, Pi.zero_apply]
#align group_cohomology.inhomogeneous_cochains GroupCohomology.inhomogeneousCochains

/-- Given a `k`-linear `G`-representation `A`, the complex of inhomogeneous cochains is isomorphic
to `Hom(P, A)`, where `P` is the standard resolution of `k` as a trivial `G`-representation. -/
def inhomogeneousCochainsIso : inhomogeneousCochains A ≅ linearYonedaObjResolution A :=
  (HomologicalComplex.Hom.isoOfComponents fun i => (Rep.diagonalHomEquiv i A).toModuleIso.symm) <|
    by
    rintro i j (h : i + 1 = j)
    subst h
    simp only [CochainComplex.of_d, d_eq, category.assoc, iso.symm_hom, iso.hom_inv_id,
      category.comp_id]
#align group_cohomology.inhomogeneous_cochains_iso GroupCohomology.inhomogeneousCochainsIso

end groupCohomology

open groupCohomology

/-- The group cohomology of a `k`-linear `G`-representation `A`, as the cohomology of its complex
of inhomogeneous cochains. -/
def groupCohomology [Group G] (A : Rep k G) (n : ℕ) : ModuleCat k :=
  (inhomogeneousCochains A).homology n
#align group_cohomology groupCohomology

/-- The `n`th group cohomology of a `k`-linear `G`-representation `A` is isomorphic to
`Extⁿ(k, A)` (taken in `Rep k G`), where `k` is a trivial `k`-linear `G`-representation. -/
def groupCohomologyIsoExt [Group G] (A : Rep k G) (n : ℕ) :
    groupCohomology A n ≅ ((Ext k (Rep k G) n).obj (Opposite.op <| Rep.trivial k G k)).obj A :=
  homologyObjIsoOfHomotopyEquiv (HomotopyEquiv.ofIso (inhomogeneousCochainsIso _)) _ ≪≫
    HomologicalComplex.homologyUnop _ _ ≪≫ (extIso k G A n).symm
#align group_cohomology_iso_Ext groupCohomologyIsoExt

