/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.of_associative
! leanprover-community/mathlib commit 5c1efce12ba86d4901463f61019832f6a4b1a0d0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Lie.Basic
import Mathbin.Algebra.Lie.Subalgebra
import Mathbin.Algebra.Lie.Submodule
import Mathbin.Algebra.Algebra.Subalgebra.Basic

/-!
# Lie algebras of associative algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the Lie algebra structure that arises on an associative algebra via the ring
commutator.

Since the linear endomorphisms of a Lie algebra form an associative algebra, one can define the
adjoint action as a morphism of Lie algebras from a Lie algebra to its linear endomorphisms. We
make such a definition in this file.

## Main definitions

 * `lie_algebra.of_associative_algebra`
 * `lie_algebra.of_associative_algebra_hom`
 * `lie_module.to_endomorphism`
 * `lie_algebra.ad`
 * `linear_equiv.lie_conj`
 * `alg_equiv.to_lie_equiv`

## Tags

lie algebra, ring commutator, adjoint action
-/


universe u v w w₁ w₂

section OfAssociative

variable {A : Type v} [Ring A]

namespace Ring

/-- The bracket operation for rings is the ring commutator, which captures the extent to which a
ring is commutative. It is identically zero exactly when the ring is commutative. -/
instance (priority := 100) : Bracket A A :=
  ⟨fun x y => x * y - y * x⟩

#print Ring.lie_def /-
theorem lie_def (x y : A) : ⁅x, y⁆ = x * y - y * x :=
  rfl
#align ring.lie_def Ring.lie_def
-/

end Ring

#print commute_iff_lie_eq /-
theorem commute_iff_lie_eq {x y : A} : Commute x y ↔ ⁅x, y⁆ = 0 :=
  sub_eq_zero.symm
#align commute_iff_lie_eq commute_iff_lie_eq
-/

#print Commute.lie_eq /-
theorem Commute.lie_eq {x y : A} (h : Commute x y) : ⁅x, y⁆ = 0 :=
  sub_eq_zero_of_eq h
#align commute.lie_eq Commute.lie_eq
-/

namespace LieRing

#print LieRing.ofAssociativeRing /-
/-- An associative ring gives rise to a Lie ring by taking the bracket to be the ring commutator. -/
instance (priority := 100) ofAssociativeRing : LieRing A
    where
  add_lie := by
    simp only [Ring.lie_def, right_distrib, left_distrib, sub_eq_add_neg, add_comm, add_left_comm,
      forall_const, eq_self_iff_true, neg_add_rev]
  lie_add := by
    simp only [Ring.lie_def, right_distrib, left_distrib, sub_eq_add_neg, add_comm, add_left_comm,
      forall_const, eq_self_iff_true, neg_add_rev]
  lie_self := by simp only [Ring.lie_def, forall_const, sub_self]
  leibniz_lie x y z := by repeat' rw [Ring.lie_def]; noncomm_ring
#align lie_ring.of_associative_ring LieRing.ofAssociativeRing
-/

#print LieRing.of_associative_ring_bracket /-
theorem of_associative_ring_bracket (x y : A) : ⁅x, y⁆ = x * y - y * x :=
  rfl
#align lie_ring.of_associative_ring_bracket LieRing.of_associative_ring_bracket
-/

#print LieRing.lie_apply /-
@[simp]
theorem lie_apply {α : Type _} (f g : α → A) (a : α) : ⁅f, g⁆ a = ⁅f a, g a⁆ :=
  rfl
#align lie_ring.lie_apply LieRing.lie_apply
-/

end LieRing

section AssociativeModule

variable {M : Type w} [AddCommGroup M] [Module A M]

#print LieRingModule.ofAssociativeModule /-
/-- We can regard a module over an associative ring `A` as a Lie ring module over `A` with Lie
bracket equal to its ring commutator.

Note that this cannot be a global instance because it would create a diamond when `M = A`,
specifically we can build two mathematically-different `has_bracket A A`s:
 1. `@ring.has_bracket A _` which says `⁅a, b⁆ = a * b - b * a`
 2. `(@lie_ring_module.of_associative_module A _ A _ _).to_has_bracket` which says `⁅a, b⁆ = a • b`
    (and thus `⁅a, b⁆ = a * b`)

See note [reducible non-instances] -/
@[reducible]
def LieRingModule.ofAssociativeModule : LieRingModule A M
    where
  bracket := (· • ·)
  add_lie := add_smul
  lie_add := smul_add
  leibniz_lie := by simp [LieRing.of_associative_ring_bracket, sub_smul, mul_smul, sub_add_cancel]
#align lie_ring_module.of_associative_module LieRingModule.ofAssociativeModule
-/

attribute [local instance] LieRingModule.ofAssociativeModule

#print lie_eq_smul /-
theorem lie_eq_smul (a : A) (m : M) : ⁅a, m⁆ = a • m :=
  rfl
#align lie_eq_smul lie_eq_smul
-/

end AssociativeModule

section LieAlgebra

variable {R : Type u} [CommRing R] [Algebra R A]

#print LieAlgebra.ofAssociativeAlgebra /-
/-- An associative algebra gives rise to a Lie algebra by taking the bracket to be the ring
commutator. -/
instance (priority := 100) LieAlgebra.ofAssociativeAlgebra : LieAlgebra R A
    where lie_smul t x y := by
    rw [LieRing.of_associative_ring_bracket, LieRing.of_associative_ring_bracket,
      Algebra.mul_smul_comm, Algebra.smul_mul_assoc, smul_sub]
#align lie_algebra.of_associative_algebra LieAlgebra.ofAssociativeAlgebra
-/

attribute [local instance] LieRingModule.ofAssociativeModule

section AssociativeRepresentation

variable {M : Type w} [AddCommGroup M] [Module R M] [Module A M] [IsScalarTower R A M]

#print LieModule.ofAssociativeModule /-
/-- A representation of an associative algebra `A` is also a representation of `A`, regarded as a
Lie algebra via the ring commutator.

See the comment at `lie_ring_module.of_associative_module` for why the possibility `M = A` means
this cannot be a global instance. -/
def LieModule.ofAssociativeModule : LieModule R A M
    where
  smul_lie := smul_assoc
  lie_smul := smul_algebra_smul_comm
#align lie_module.of_associative_module LieModule.ofAssociativeModule
-/

#print Module.End.lieRingModule /-
instance Module.End.lieRingModule : LieRingModule (Module.End R M) M :=
  LieRingModule.ofAssociativeModule
#align module.End.lie_ring_module Module.End.lieRingModule
-/

#print Module.End.lieModule /-
instance Module.End.lieModule : LieModule R (Module.End R M) M :=
  LieModule.ofAssociativeModule
#align module.End.lie_module Module.End.lieModule
-/

end AssociativeRepresentation

namespace AlgHom

variable {B : Type w} {C : Type w₁} [Ring B] [Ring C] [Algebra R B] [Algebra R C]

variable (f : A →ₐ[R] B) (g : B →ₐ[R] C)

#print AlgHom.toLieHom /-
/-- The map `of_associative_algebra` associating a Lie algebra to an associative algebra is
functorial. -/
def toLieHom : A →ₗ⁅R⁆ B :=
  { f.toLinearMap with
    map_lie' := fun x y =>
      show f ⁅x, y⁆ = ⁅f x, f y⁆ by
        simp only [LieRing.of_associative_ring_bracket, AlgHom.map_sub, AlgHom.map_mul] }
#align alg_hom.to_lie_hom AlgHom.toLieHom
-/

instance : Coe (A →ₐ[R] B) (A →ₗ⁅R⁆ B) :=
  ⟨toLieHom⟩

@[simp]
theorem toLieHom_coe : f.toLieHom = ↑f :=
  rfl
#align alg_hom.to_lie_hom_coe AlgHom.toLieHom_coe

#print AlgHom.coe_toLieHom /-
@[simp]
theorem coe_toLieHom : ((f : A →ₗ⁅R⁆ B) : A → B) = f :=
  rfl
#align alg_hom.coe_to_lie_hom AlgHom.coe_toLieHom
-/

#print AlgHom.toLieHom_apply /-
theorem toLieHom_apply (x : A) : f.toLieHom x = f x :=
  rfl
#align alg_hom.to_lie_hom_apply AlgHom.toLieHom_apply
-/

#print AlgHom.toLieHom_id /-
@[simp]
theorem toLieHom_id : (AlgHom.id R A : A →ₗ⁅R⁆ A) = LieHom.id :=
  rfl
#align alg_hom.to_lie_hom_id AlgHom.toLieHom_id
-/

#print AlgHom.toLieHom_comp /-
@[simp]
theorem toLieHom_comp : (g.comp f : A →ₗ⁅R⁆ C) = (g : B →ₗ⁅R⁆ C).comp (f : A →ₗ⁅R⁆ B) :=
  rfl
#align alg_hom.to_lie_hom_comp AlgHom.toLieHom_comp
-/

#print AlgHom.toLieHom_injective /-
theorem toLieHom_injective {f g : A →ₐ[R] B} (h : (f : A →ₗ⁅R⁆ B) = (g : A →ₗ⁅R⁆ B)) : f = g := by
  ext a; exact LieHom.congr_fun h a
#align alg_hom.to_lie_hom_injective AlgHom.toLieHom_injective
-/

end AlgHom

end LieAlgebra

end OfAssociative

section AdjointAction

variable (R : Type u) (L : Type v) (M : Type w)

variable [CommRing R] [LieRing L] [LieAlgebra R L] [AddCommGroup M] [Module R M]

variable [LieRingModule L M] [LieModule R L M]

#print LieModule.toEndomorphism /-
/-- A Lie module yields a Lie algebra morphism into the linear endomorphisms of the module.

See also `lie_module.to_module_hom`. -/
@[simps]
def LieModule.toEndomorphism : L →ₗ⁅R⁆ Module.End R M
    where
  toFun x :=
    { toFun := fun m => ⁅x, m⁆
      map_add' := lie_add x
      map_smul' := fun t => lie_smul t x }
  map_add' x y := by ext m; apply add_lie
  map_smul' t x := by ext m; apply smul_lie
  map_lie' x y := by ext m; apply lie_lie
#align lie_module.to_endomorphism LieModule.toEndomorphism
-/

#print LieAlgebra.ad /-
/-- The adjoint action of a Lie algebra on itself. -/
def LieAlgebra.ad : L →ₗ⁅R⁆ Module.End R L :=
  LieModule.toEndomorphism R L L
#align lie_algebra.ad LieAlgebra.ad
-/

#print LieAlgebra.ad_apply /-
@[simp]
theorem LieAlgebra.ad_apply (x y : L) : LieAlgebra.ad R L x y = ⁅x, y⁆ :=
  rfl
#align lie_algebra.ad_apply LieAlgebra.ad_apply
-/

#print LieModule.toEndomorphism_module_end /-
@[simp]
theorem LieModule.toEndomorphism_module_end :
    LieModule.toEndomorphism R (Module.End R M) M = LieHom.id := by ext g m; simp [lie_eq_smul]
#align lie_module.to_endomorphism_module_End LieModule.toEndomorphism_module_end
-/

#print LieSubalgebra.toEndomorphism_eq /-
theorem LieSubalgebra.toEndomorphism_eq (K : LieSubalgebra R L) {x : K} :
    LieModule.toEndomorphism R K M x = LieModule.toEndomorphism R L M x :=
  rfl
#align lie_subalgebra.to_endomorphism_eq LieSubalgebra.toEndomorphism_eq
-/

#print LieSubalgebra.toEndomorphism_mk /-
@[simp]
theorem LieSubalgebra.toEndomorphism_mk (K : LieSubalgebra R L) {x : L} (hx : x ∈ K) :
    LieModule.toEndomorphism R K M ⟨x, hx⟩ = LieModule.toEndomorphism R L M x :=
  rfl
#align lie_subalgebra.to_endomorphism_mk LieSubalgebra.toEndomorphism_mk
-/

variable {R L M}

namespace LieSubmodule

open LieModule

variable {N : LieSubmodule R L M} {x : L}

#print LieSubmodule.coe_map_toEndomorphism_le /-
theorem coe_map_toEndomorphism_le :
    (N : Submodule R M).map (LieModule.toEndomorphism R L M x) ≤ N :=
  by
  rintro n ⟨m, hm, rfl⟩
  exact N.lie_mem hm
#align lie_submodule.coe_map_to_endomorphism_le LieSubmodule.coe_map_toEndomorphism_le
-/

variable (N x)

#print LieSubmodule.toEndomorphism_comp_subtype_mem /-
theorem toEndomorphism_comp_subtype_mem (m : M) (hm : m ∈ (N : Submodule R M)) :
    (toEndomorphism R L M x).comp (N : Submodule R M).Subtype ⟨m, hm⟩ ∈ (N : Submodule R M) := by
  simpa using N.lie_mem hm
#align lie_submodule.to_endomorphism_comp_subtype_mem LieSubmodule.toEndomorphism_comp_subtype_mem
-/

#print LieSubmodule.toEndomorphism_restrict_eq_toEndomorphism /-
@[simp]
theorem toEndomorphism_restrict_eq_toEndomorphism (h := N.toEndomorphism_comp_subtype_mem x) :
    (toEndomorphism R L M x).restrict h = toEndomorphism R L N x := by ext;
  simp [LinearMap.restrict_apply]
#align lie_submodule.to_endomorphism_restrict_eq_to_endomorphism LieSubmodule.toEndomorphism_restrict_eq_toEndomorphism
-/

end LieSubmodule

open LieAlgebra

#print LieAlgebra.ad_eq_lmul_left_sub_lmul_right /-
theorem LieAlgebra.ad_eq_lmul_left_sub_lmul_right (A : Type v) [Ring A] [Algebra R A] :
    (ad R A : A → Module.End R A) = LinearMap.mulLeft R - LinearMap.mulRight R := by ext a b;
  simp [LieRing.of_associative_ring_bracket]
#align lie_algebra.ad_eq_lmul_left_sub_lmul_right LieAlgebra.ad_eq_lmul_left_sub_lmul_right
-/

#print LieSubalgebra.ad_comp_incl_eq /-
theorem LieSubalgebra.ad_comp_incl_eq (K : LieSubalgebra R L) (x : K) :
    (ad R L ↑x).comp (K.incl : K →ₗ[R] L) = (K.incl : K →ₗ[R] L).comp (ad R K x) :=
  by
  ext y
  simp only [ad_apply, LieHom.coe_toLinearMap, LieSubalgebra.coe_incl, LinearMap.coe_comp,
    LieSubalgebra.coe_bracket, Function.comp_apply]
#align lie_subalgebra.ad_comp_incl_eq LieSubalgebra.ad_comp_incl_eq
-/

end AdjointAction

#print lieSubalgebraOfSubalgebra /-
/-- A subalgebra of an associative algebra is a Lie subalgebra of the associated Lie algebra. -/
def lieSubalgebraOfSubalgebra (R : Type u) [CommRing R] (A : Type v) [Ring A] [Algebra R A]
    (A' : Subalgebra R A) : LieSubalgebra R A :=
  { A'.toSubmodule with
    lie_mem' := fun x y hx hy => by
      change ⁅x, y⁆ ∈ A'; change x ∈ A' at hx ; change y ∈ A' at hy 
      rw [LieRing.of_associative_ring_bracket]
      have hxy := A'.mul_mem hx hy
      have hyx := A'.mul_mem hy hx
      exact Submodule.sub_mem A'.to_submodule hxy hyx }
#align lie_subalgebra_of_subalgebra lieSubalgebraOfSubalgebra
-/

namespace LinearEquiv

variable {R : Type u} {M₁ : Type v} {M₂ : Type w}

variable [CommRing R] [AddCommGroup M₁] [Module R M₁] [AddCommGroup M₂] [Module R M₂]

variable (e : M₁ ≃ₗ[R] M₂)

#print LinearEquiv.lieConj /-
/-- A linear equivalence of two modules induces a Lie algebra equivalence of their endomorphisms. -/
def lieConj : Module.End R M₁ ≃ₗ⁅R⁆ Module.End R M₂ :=
  { e.conj with
    map_lie' := fun f g =>
      show e.conj ⁅f, g⁆ = ⁅e.conj f, e.conj g⁆ by
        simp only [LieRing.of_associative_ring_bracket, LinearMap.mul_eq_comp, e.conj_comp,
          LinearEquiv.map_sub] }
#align linear_equiv.lie_conj LinearEquiv.lieConj
-/

#print LinearEquiv.lieConj_apply /-
@[simp]
theorem lieConj_apply (f : Module.End R M₁) : e.lieConj f = e.conj f :=
  rfl
#align linear_equiv.lie_conj_apply LinearEquiv.lieConj_apply
-/

#print LinearEquiv.lieConj_symm /-
@[simp]
theorem lieConj_symm : e.lieConj.symm = e.symm.lieConj :=
  rfl
#align linear_equiv.lie_conj_symm LinearEquiv.lieConj_symm
-/

end LinearEquiv

namespace AlgEquiv

variable {R : Type u} {A₁ : Type v} {A₂ : Type w}

variable [CommRing R] [Ring A₁] [Ring A₂] [Algebra R A₁] [Algebra R A₂]

variable (e : A₁ ≃ₐ[R] A₂)

#print AlgEquiv.toLieEquiv /-
/-- An equivalence of associative algebras is an equivalence of associated Lie algebras. -/
def toLieEquiv : A₁ ≃ₗ⁅R⁆ A₂ :=
  { e.toLinearEquiv with
    toFun := e.toFun
    map_lie' := fun x y => by simp [LieRing.of_associative_ring_bracket] }
#align alg_equiv.to_lie_equiv AlgEquiv.toLieEquiv
-/

#print AlgEquiv.toLieEquiv_apply /-
@[simp]
theorem toLieEquiv_apply (x : A₁) : e.toLieEquiv x = e x :=
  rfl
#align alg_equiv.to_lie_equiv_apply AlgEquiv.toLieEquiv_apply
-/

#print AlgEquiv.toLieEquiv_symm_apply /-
@[simp]
theorem toLieEquiv_symm_apply (x : A₂) : e.toLieEquiv.symm x = e.symm x :=
  rfl
#align alg_equiv.to_lie_equiv_symm_apply AlgEquiv.toLieEquiv_symm_apply
-/

end AlgEquiv

