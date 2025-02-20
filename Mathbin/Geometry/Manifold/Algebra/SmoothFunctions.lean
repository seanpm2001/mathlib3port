/-
Copyright © 2020 Nicolò Cavalleri. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nicolò Cavalleri

! This file was ported from Lean 3 source module geometry.manifold.algebra.smooth_functions
! leanprover-community/mathlib commit e5ab837fc252451f3eb9124ae6e7b6f57455e7b9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Geometry.Manifold.Algebra.Structures

/-!
# Algebraic structures over smooth functions

In this file, we define instances of algebraic structures over smooth functions.
-/


noncomputable section

open scoped Manifold

open TopologicalSpace

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {E : Type _} [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] {E' : Type _} [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {H : Type _}
  [TopologicalSpace H] {I : ModelWithCorners 𝕜 E H} {H' : Type _} [TopologicalSpace H']
  {I' : ModelWithCorners 𝕜 E' H'} {N : Type _} [TopologicalSpace N] [ChartedSpace H N]
  {E'' : Type _} [NormedAddCommGroup E''] [NormedSpace 𝕜 E''] {H'' : Type _} [TopologicalSpace H'']
  {I'' : ModelWithCorners 𝕜 E'' H''} {N' : Type _} [TopologicalSpace N'] [ChartedSpace H'' N']

namespace SmoothMap

@[to_additive]
instance hasMul {G : Type _} [Mul G] [TopologicalSpace G] [ChartedSpace H' G] [SmoothMul I' G] :
    Mul C^∞⟮I, N; I', G⟯ :=
  ⟨fun f g => ⟨f * g, f.Smooth.mul g.Smooth⟩⟩
#align smooth_map.has_mul SmoothMap.hasMul
#align smooth_map.has_add SmoothMap.hasAdd

@[simp, to_additive]
theorem coe_mul {G : Type _} [Mul G] [TopologicalSpace G] [ChartedSpace H' G] [SmoothMul I' G]
    (f g : C^∞⟮I, N; I', G⟯) : ⇑(f * g) = f * g :=
  rfl
#align smooth_map.coe_mul SmoothMap.coe_mul
#align smooth_map.coe_add SmoothMap.coe_add

@[simp, to_additive]
theorem mul_comp {G : Type _} [Mul G] [TopologicalSpace G] [ChartedSpace H' G] [SmoothMul I' G]
    (f g : C^∞⟮I'', N'; I', G⟯) (h : C^∞⟮I, N; I'', N'⟯) : (f * g).comp h = f.comp h * g.comp h :=
  by ext <;> simp only [ContMDiffMap.comp_apply, coe_mul, Pi.mul_apply]
#align smooth_map.mul_comp SmoothMap.mul_comp
#align smooth_map.add_comp SmoothMap.add_comp

@[to_additive]
instance hasOne {G : Type _} [Monoid G] [TopologicalSpace G] [ChartedSpace H' G] :
    One C^∞⟮I, N; I', G⟯ :=
  ⟨ContMDiffMap.const (1 : G)⟩
#align smooth_map.has_one SmoothMap.hasOne
#align smooth_map.has_zero SmoothMap.hasZero

@[simp, to_additive]
theorem coe_one {G : Type _} [Monoid G] [TopologicalSpace G] [ChartedSpace H' G] :
    ⇑(1 : C^∞⟮I, N; I', G⟯) = 1 :=
  rfl
#align smooth_map.coe_one SmoothMap.coe_one
#align smooth_map.coe_zero SmoothMap.coe_zero

section GroupStructure

/-!
### Group structure

In this section we show that smooth functions valued in a Lie group inherit a group structure
under pointwise multiplication.
-/


@[to_additive]
instance semigroup {G : Type _} [Semigroup G] [TopologicalSpace G] [ChartedSpace H' G]
    [SmoothMul I' G] : Semigroup C^∞⟮I, N; I', G⟯ :=
  { SmoothMap.hasMul with mul_assoc := fun a b c => by ext <;> exact mul_assoc _ _ _ }
#align smooth_map.semigroup SmoothMap.semigroup
#align smooth_map.add_semigroup SmoothMap.addSemigroup

@[to_additive]
instance monoid {G : Type _} [Monoid G] [TopologicalSpace G] [ChartedSpace H' G] [SmoothMul I' G] :
    Monoid C^∞⟮I, N; I', G⟯ :=
  { SmoothMap.semigroup,
    SmoothMap.hasOne with
    one_mul := fun a => by ext <;> exact one_mul _
    mul_one := fun a => by ext <;> exact mul_one _ }
#align smooth_map.monoid SmoothMap.monoid
#align smooth_map.add_monoid SmoothMap.addMonoid

/-- Coercion to a function as an `monoid_hom`. Similar to `monoid_hom.coe_fn`. -/
@[to_additive "Coercion to a function as an `add_monoid_hom`. Similar to `add_monoid_hom.coe_fn`.",
  simps]
def coeFnMonoidHom {G : Type _} [Monoid G] [TopologicalSpace G] [ChartedSpace H' G]
    [SmoothMul I' G] : C^∞⟮I, N; I', G⟯ →* N → G
    where
  toFun := coeFn
  map_one' := coe_one
  map_mul' := coe_mul
#align smooth_map.coe_fn_monoid_hom SmoothMap.coeFnMonoidHom
#align smooth_map.coe_fn_add_monoid_hom SmoothMap.coeFnAddMonoidHom

variable (I N)

/-- For a manifold `N` and a smooth homomorphism `φ` between Lie groups `G'`, `G''`, the
'left-composition-by-`φ`' group homomorphism from `C^∞⟮I, N; I', G'⟯` to `C^∞⟮I, N; I'', G''⟯`. -/
@[to_additive
      "For a manifold `N` and a smooth homomorphism `φ` between additive Lie groups `G'`,\n`G''`, the 'left-composition-by-`φ`' group homomorphism from `C^∞⟮I, N; I', G'⟯` to\n`C^∞⟮I, N; I'', G''⟯`."]
def compLeftMonoidHom {G' : Type _} [Monoid G'] [TopologicalSpace G'] [ChartedSpace H' G']
    [SmoothMul I' G'] {G'' : Type _} [Monoid G''] [TopologicalSpace G''] [ChartedSpace H'' G'']
    [SmoothMul I'' G''] (φ : G' →* G'') (hφ : Smooth I' I'' φ) :
    C^∞⟮I, N; I', G'⟯ →* C^∞⟮I, N; I'', G''⟯
    where
  toFun f := ⟨φ ∘ f, fun x => (hφ.Smooth _).comp x (f.ContMDiff x)⟩
  map_one' := by ext x <;> show φ 1 = 1 <;> simp
  map_mul' f g := by ext x <;> show φ (f x * g x) = φ (f x) * φ (g x) <;> simp
#align smooth_map.comp_left_monoid_hom SmoothMap.compLeftMonoidHom
#align smooth_map.comp_left_add_monoid_hom SmoothMap.compLeftAddMonoidHom

variable (I') {N}

/-- For a Lie group `G` and open sets `U ⊆ V` in `N`, the 'restriction' group homomorphism from
`C^∞⟮I, V; I', G⟯` to `C^∞⟮I, U; I', G⟯`. -/
@[to_additive
      "For an additive Lie group `G` and open sets `U ⊆ V` in `N`, the 'restriction' group\nhomomorphism from `C^∞⟮I, V; I', G⟯` to `C^∞⟮I, U; I', G⟯`."]
def restrictMonoidHom (G : Type _) [Monoid G] [TopologicalSpace G] [ChartedSpace H' G]
    [SmoothMul I' G] {U V : Opens N} (h : U ≤ V) : C^∞⟮I, V; I', G⟯ →* C^∞⟮I, U; I', G⟯
    where
  toFun f := ⟨f ∘ Set.inclusion h, f.Smooth.comp (smooth_inclusion h)⟩
  map_one' := rfl
  map_mul' f g := rfl
#align smooth_map.restrict_monoid_hom SmoothMap.restrictMonoidHom
#align smooth_map.restrict_add_monoid_hom SmoothMap.restrictAddMonoidHom

variable {I N I' N'}

@[to_additive]
instance commMonoid {G : Type _} [CommMonoid G] [TopologicalSpace G] [ChartedSpace H' G]
    [SmoothMul I' G] : CommMonoid C^∞⟮I, N; I', G⟯ :=
  { SmoothMap.monoid, SmoothMap.hasOne with mul_comm := fun a b => by ext <;> exact mul_comm _ _ }
#align smooth_map.comm_monoid SmoothMap.commMonoid
#align smooth_map.add_comm_monoid SmoothMap.addCommMonoid

@[to_additive]
instance group {G : Type _} [Group G] [TopologicalSpace G] [ChartedSpace H' G] [LieGroup I' G] :
    Group C^∞⟮I, N; I', G⟯ :=
  { SmoothMap.monoid with
    inv := fun f => ⟨fun x => (f x)⁻¹, f.Smooth.inv⟩
    mul_left_inv := fun a => by ext <;> exact mul_left_inv _
    div := fun f g => ⟨f / g, f.Smooth.div g.Smooth⟩
    div_eq_mul_inv := fun f g => by ext <;> exact div_eq_mul_inv _ _ }
#align smooth_map.group SmoothMap.group
#align smooth_map.add_group SmoothMap.addGroup

@[simp, to_additive]
theorem coe_inv {G : Type _} [Group G] [TopologicalSpace G] [ChartedSpace H' G] [LieGroup I' G]
    (f : C^∞⟮I, N; I', G⟯) : ⇑f⁻¹ = f⁻¹ :=
  rfl
#align smooth_map.coe_inv SmoothMap.coe_inv
#align smooth_map.coe_neg SmoothMap.coe_neg

@[simp, to_additive]
theorem coe_div {G : Type _} [Group G] [TopologicalSpace G] [ChartedSpace H' G] [LieGroup I' G]
    (f g : C^∞⟮I, N; I', G⟯) : ⇑(f / g) = f / g :=
  rfl
#align smooth_map.coe_div SmoothMap.coe_div
#align smooth_map.coe_sub SmoothMap.coe_sub

@[to_additive]
instance commGroup {G : Type _} [CommGroup G] [TopologicalSpace G] [ChartedSpace H' G]
    [LieGroup I' G] : CommGroup C^∞⟮I, N; I', G⟯ :=
  { SmoothMap.group, SmoothMap.commMonoid with }
#align smooth_map.comm_group SmoothMap.commGroup
#align smooth_map.add_comm_group SmoothMap.addCommGroup

end GroupStructure

section RingStructure

/-!
### Ring stucture

In this section we show that smooth functions valued in a smooth ring `R` inherit a ring structure
under pointwise multiplication.
-/


instance semiring {R : Type _} [Semiring R] [TopologicalSpace R] [ChartedSpace H' R]
    [SmoothRing I' R] : Semiring C^∞⟮I, N; I', R⟯ :=
  { SmoothMap.addCommMonoid,
    SmoothMap.monoid with
    left_distrib := fun a b c => by ext <;> exact left_distrib _ _ _
    right_distrib := fun a b c => by ext <;> exact right_distrib _ _ _
    zero_mul := fun a => by ext <;> exact MulZeroClass.zero_mul _
    mul_zero := fun a => by ext <;> exact MulZeroClass.mul_zero _ }
#align smooth_map.semiring SmoothMap.semiring

instance ring {R : Type _} [Ring R] [TopologicalSpace R] [ChartedSpace H' R] [SmoothRing I' R] :
    Ring C^∞⟮I, N; I', R⟯ :=
  { SmoothMap.semiring, SmoothMap.addCommGroup with }
#align smooth_map.ring SmoothMap.ring

instance commRing {R : Type _} [CommRing R] [TopologicalSpace R] [ChartedSpace H' R]
    [SmoothRing I' R] : CommRing C^∞⟮I, N; I', R⟯ :=
  { SmoothMap.semiring, SmoothMap.addCommGroup, SmoothMap.commMonoid with }
#align smooth_map.comm_ring SmoothMap.commRing

variable (I N)

/-- For a manifold `N` and a smooth homomorphism `φ` between smooth rings `R'`, `R''`, the
'left-composition-by-`φ`' ring homomorphism from `C^∞⟮I, N; I', R'⟯` to `C^∞⟮I, N; I'', R''⟯`. -/
def compLeftRingHom {R' : Type _} [Ring R'] [TopologicalSpace R'] [ChartedSpace H' R']
    [SmoothRing I' R'] {R'' : Type _} [Ring R''] [TopologicalSpace R''] [ChartedSpace H'' R'']
    [SmoothRing I'' R''] (φ : R' →+* R'') (hφ : Smooth I' I'' φ) :
    C^∞⟮I, N; I', R'⟯ →+* C^∞⟮I, N; I'', R''⟯ :=
  { SmoothMap.compLeftMonoidHom I N φ.toMonoidHom hφ,
    SmoothMap.compLeftAddMonoidHom I N φ.toAddMonoidHom hφ with
    toFun := fun f => ⟨φ ∘ f, fun x => (hφ.Smooth _).comp x (f.ContMDiff x)⟩ }
#align smooth_map.comp_left_ring_hom SmoothMap.compLeftRingHom

variable (I') {N}

/-- For a "smooth ring" `R` and open sets `U ⊆ V` in `N`, the "restriction" ring homomorphism from
`C^∞⟮I, V; I', R⟯` to `C^∞⟮I, U; I', R⟯`. -/
def restrictRingHom (R : Type _) [Ring R] [TopologicalSpace R] [ChartedSpace H' R] [SmoothRing I' R]
    {U V : Opens N} (h : U ≤ V) : C^∞⟮I, V; I', R⟯ →+* C^∞⟮I, U; I', R⟯ :=
  { SmoothMap.restrictMonoidHom I I' R h, SmoothMap.restrictAddMonoidHom I I' R h with
    toFun := fun f => ⟨f ∘ Set.inclusion h, f.Smooth.comp (smooth_inclusion h)⟩ }
#align smooth_map.restrict_ring_hom SmoothMap.restrictRingHom

variable {I N I' N'}

/-- Coercion to a function as a `ring_hom`. -/
@[simps]
def coeFnRingHom {R : Type _} [CommRing R] [TopologicalSpace R] [ChartedSpace H' R]
    [SmoothRing I' R] : C^∞⟮I, N; I', R⟯ →+* N → R :=
  { (coeFnMonoidHom : C^∞⟮I, N; I', R⟯ →* _), (coeFnAddMonoidHom : C^∞⟮I, N; I', R⟯ →+ _) with
    toFun := coeFn }
#align smooth_map.coe_fn_ring_hom SmoothMap.coeFnRingHom

/-- `function.eval` as a `ring_hom` on the ring of smooth functions. -/
def evalRingHom {R : Type _} [CommRing R] [TopologicalSpace R] [ChartedSpace H' R] [SmoothRing I' R]
    (n : N) : C^∞⟮I, N; I', R⟯ →+* R :=
  (Pi.evalRingHom _ n : (N → R) →+* R).comp SmoothMap.coeFnRingHom
#align smooth_map.eval_ring_hom SmoothMap.evalRingHom

end RingStructure

section ModuleStructure

/-!
### Semiodule stucture

In this section we show that smooth functions valued in a vector space `M` over a normed
field `𝕜` inherit a vector space structure.
-/


instance hasSmul {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V] :
    SMul 𝕜 C^∞⟮I, N; 𝓘(𝕜, V), V⟯ :=
  ⟨fun r f => ⟨r • f, smooth_const.smul f.Smooth⟩⟩
#align smooth_map.has_smul SmoothMap.hasSmul

@[simp]
theorem coe_smul {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V] (r : 𝕜)
    (f : C^∞⟮I, N; 𝓘(𝕜, V), V⟯) : ⇑(r • f) = r • f :=
  rfl
#align smooth_map.coe_smul SmoothMap.coe_smul

@[simp]
theorem smul_comp {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V] (r : 𝕜)
    (g : C^∞⟮I'', N'; 𝓘(𝕜, V), V⟯) (h : C^∞⟮I, N; I'', N'⟯) : (r • g).comp h = r • g.comp h :=
  rfl
#align smooth_map.smul_comp SmoothMap.smul_comp

instance module {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V] :
    Module 𝕜 C^∞⟮I, N; 𝓘(𝕜, V), V⟯ :=
  Function.Injective.module 𝕜 coeFnAddMonoidHom ContMDiffMap.coe_injective coe_smul
#align smooth_map.module SmoothMap.module

/-- Coercion to a function as a `linear_map`. -/
@[simps]
def coeFnLinearMap {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V] :
    C^∞⟮I, N; 𝓘(𝕜, V), V⟯ →ₗ[𝕜] N → V :=
  {
    (coeFnAddMonoidHom : C^∞⟮I, N; 𝓘(𝕜, V), V⟯ →+
        _) with
    toFun := coeFn
    map_smul' := coe_smul }
#align smooth_map.coe_fn_linear_map SmoothMap.coeFnLinearMap

end ModuleStructure

section AlgebraStructure

/-!
### Algebra structure

In this section we show that smooth functions valued in a normed algebra `A` over a normed field `𝕜`
inherit an algebra structure.
-/


variable {A : Type _} [NormedRing A] [NormedAlgebra 𝕜 A] [SmoothRing 𝓘(𝕜, A) A]

/-- Smooth constant functions as a `ring_hom`. -/
def c : 𝕜 →+* C^∞⟮I, N; 𝓘(𝕜, A), A⟯
    where
  toFun := fun c : 𝕜 => ⟨fun x => (algebraMap 𝕜 A) c, smooth_const⟩
  map_one' := by ext x <;> exact (algebraMap 𝕜 A).map_one
  map_mul' c₁ c₂ := by ext x <;> exact (algebraMap 𝕜 A).map_mul _ _
  map_zero' := by ext x <;> exact (algebraMap 𝕜 A).map_zero
  map_add' c₁ c₂ := by ext x <;> exact (algebraMap 𝕜 A).map_add _ _
#align smooth_map.C SmoothMap.c

instance algebra : Algebra 𝕜 C^∞⟮I, N; 𝓘(𝕜, A), A⟯ :=
  {
    SmoothMap.semiring with
    smul := fun r f => ⟨r • f, smooth_const.smul f.Smooth⟩
    toRingHom := SmoothMap.c
    commutes' := fun c f => by ext x <;> exact Algebra.commutes' _ _
    smul_def' := fun c f => by ext x <;> exact Algebra.smul_def' _ _ }
#align smooth_map.algebra SmoothMap.algebra

/-- Coercion to a function as an `alg_hom`. -/
@[simps]
def coeFnAlgHom : C^∞⟮I, N; 𝓘(𝕜, A), A⟯ →ₐ[𝕜] N → A
    where
  toFun := coeFn
  commutes' r := rfl
  -- `..(smooth_map.coe_fn_ring_hom : C^∞⟮I, N; 𝓘(𝕜, A), A⟯ →+* _)` times out for some reason
  map_zero' := SmoothMap.coe_zero
  map_one' := SmoothMap.coe_one
  map_add' := SmoothMap.coe_add
  map_mul' := SmoothMap.coe_mul
#align smooth_map.coe_fn_alg_hom SmoothMap.coeFnAlgHom

end AlgebraStructure

section ModuleOverContinuousFunctions

/-!
### Structure as module over scalar functions

If `V` is a module over `𝕜`, then we show that the space of smooth functions from `N` to `V`
is naturally a vector space over the ring of smooth functions from `N` to `𝕜`. -/


instance hasSmul' {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V] :
    SMul C^∞⟮I, N; 𝕜⟯ C^∞⟮I, N; 𝓘(𝕜, V), V⟯ :=
  ⟨fun f g => ⟨fun x => f x • g x, Smooth.smul f.2 g.2⟩⟩
#align smooth_map.has_smul' SmoothMap.hasSmul'

@[simp]
theorem smul_comp' {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V] (f : C^∞⟮I'', N'; 𝕜⟯)
    (g : C^∞⟮I'', N'; 𝓘(𝕜, V), V⟯) (h : C^∞⟮I, N; I'', N'⟯) :
    (f • g).comp h = f.comp h • g.comp h :=
  rfl
#align smooth_map.smul_comp' SmoothMap.smul_comp'

instance module' {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V] :
    Module C^∞⟮I, N; 𝓘(𝕜), 𝕜⟯ C^∞⟮I, N; 𝓘(𝕜, V), V⟯
    where
  smul := (· • ·)
  smul_add c f g := by ext x <;> exact smul_add (c x) (f x) (g x)
  add_smul c₁ c₂ f := by ext x <;> exact add_smul (c₁ x) (c₂ x) (f x)
  mul_smul c₁ c₂ f := by ext x <;> exact mul_smul (c₁ x) (c₂ x) (f x)
  one_smul f := by ext x <;> exact one_smul 𝕜 (f x)
  zero_smul f := by ext x <;> exact zero_smul _ _
  smul_zero r := by ext x <;> exact smul_zero _
#align smooth_map.module' SmoothMap.module'

end ModuleOverContinuousFunctions

end SmoothMap

