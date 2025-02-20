/-
Copyright (c) 2022 Moritz Doll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll

! This file was ported from Lean 3 source module analysis.schwartz_space
! leanprover-community/mathlib commit f2ad3645af9effcdb587637dc28a6074edc813f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.ContDiff
import Mathbin.Analysis.Calculus.IteratedDeriv
import Mathbin.Analysis.LocallyConvex.WithSeminorms
import Mathbin.Topology.Algebra.UniformFilterBasis
import Mathbin.Topology.ContinuousFunction.Bounded
import Mathbin.Tactic.Positivity
import Mathbin.Analysis.SpecialFunctions.Pow.Real

/-!
# Schwartz space

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the Schwartz space. Usually, the Schwartz space is defined as the set of smooth
functions $f : ℝ^n → ℂ$ such that there exists $C_{αβ} > 0$ with $$|x^α ∂^β f(x)| < C_{αβ}$$ for
all $x ∈ ℝ^n$ and for all multiindices $α, β$.
In mathlib, we use a slightly different approach and define define the Schwartz space as all
smooth functions `f : E → F`, where `E` and `F` are real normed vector spaces such that for all
natural numbers `k` and `n` we have uniform bounds `‖x‖^k * ‖iterated_fderiv ℝ n f x‖ < C`.
This approach completely avoids using partial derivatives as well as polynomials.
We construct the topology on the Schwartz space by a family of seminorms, which are the best
constants in the above estimates. The abstract theory of topological vector spaces developed in
`seminorm_family.module_filter_basis` and `with_seminorms.to_locally_convex_space` turns the
Schwartz space into a locally convex topological vector space.

## Main definitions

* `schwartz_map`: The Schwartz space is the space of smooth functions such that all derivatives
decay faster than any power of `‖x‖`.
* `schwartz_map.seminorm`: The family of seminorms as described above
* `schwartz_map.fderiv_clm`: The differential as a continuous linear map
`𝓢(E, F) →L[𝕜] 𝓢(E, E →L[ℝ] F)`
* `schwartz_map.deriv_clm`: The one-dimensional derivative as a continuous linear map
`𝓢(ℝ, F) →L[𝕜] 𝓢(ℝ, F)`

## Main statements

* `schwartz_map.uniform_add_group` and `schwartz_map.locally_convex`: The Schwartz space is a
locally convex topological vector space.
* `schwartz_map.one_add_le_sup_seminorm_apply`: For a Schwartz function `f` there is a uniform bound
on `(1 + ‖x‖) ^ k * ‖iterated_fderiv ℝ n f x‖`.

## Implementation details

The implementation of the seminorms is taken almost literally from `continuous_linear_map.op_norm`.

## Notation

* `𝓢(E, F)`: The Schwartz space `schwartz_map E F` localized in `schwartz_space`

## Tags

Schwartz space, tempered distributions
-/


noncomputable section

open scoped BigOperators Nat

variable {𝕜 𝕜' D E F G : Type _}

variable [NormedAddCommGroup E] [NormedSpace ℝ E]

variable [NormedAddCommGroup F] [NormedSpace ℝ F]

variable (E F)

#print SchwartzMap /-
/-- A function is a Schwartz function if it is smooth and all derivatives decay faster than
  any power of `‖x‖`. -/
structure SchwartzMap where
  toFun : E → F
  smooth' : ContDiff ℝ ⊤ to_fun
  decay' : ∀ k n : ℕ, ∃ C : ℝ, ∀ x, ‖x‖ ^ k * ‖iteratedFDeriv ℝ n to_fun x‖ ≤ C
#align schwartz_map SchwartzMap
-/

scoped[SchwartzSpace] notation "𝓢(" E ", " F ")" => SchwartzMap E F

variable {E F}

namespace SchwartzMap

instance : Coe 𝓢(E, F) (E → F) :=
  ⟨toFun⟩

#print SchwartzMap.instFunLike /-
instance instFunLike : FunLike 𝓢(E, F) E fun _ => F
    where
  coe f := f.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
#align schwartz_map.fun_like SchwartzMap.instFunLike
-/

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`. -/
instance : CoeFun 𝓢(E, F) fun _ => E → F :=
  ⟨fun p => p.toFun⟩

#print SchwartzMap.decay /-
/-- All derivatives of a Schwartz function are rapidly decaying. -/
theorem decay (f : 𝓢(E, F)) (k n : ℕ) :
    ∃ (C : ℝ) (hC : 0 < C), ∀ x, ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ ≤ C :=
  by
  rcases f.decay' k n with ⟨C, hC⟩
  exact ⟨max C 1, by positivity, fun x => (hC x).trans (le_max_left _ _)⟩
#align schwartz_map.decay SchwartzMap.decay
-/

#print SchwartzMap.smooth /-
/-- Every Schwartz function is smooth. -/
theorem smooth (f : 𝓢(E, F)) (n : ℕ∞) : ContDiff ℝ n f :=
  f.smooth'.of_le le_top
#align schwartz_map.smooth SchwartzMap.smooth
-/

#print SchwartzMap.continuous /-
/-- Every Schwartz function is continuous. -/
@[continuity, protected]
theorem continuous (f : 𝓢(E, F)) : Continuous f :=
  (f.smooth 0).Continuous
#align schwartz_map.continuous SchwartzMap.continuous
-/

#print SchwartzMap.differentiable /-
/-- Every Schwartz function is differentiable. -/
@[protected]
theorem differentiable (f : 𝓢(E, F)) : Differentiable ℝ f :=
  (f.smooth 1).Differentiable rfl.le
#align schwartz_map.differentiable SchwartzMap.differentiable
-/

#print SchwartzMap.differentiableAt /-
/-- Every Schwartz function is differentiable at any point. -/
@[protected]
theorem differentiableAt (f : 𝓢(E, F)) {x : E} : DifferentiableAt ℝ f x :=
  f.Differentiable.DifferentiableAt
#align schwartz_map.differentiable_at SchwartzMap.differentiableAt
-/

#print SchwartzMap.ext /-
@[ext]
theorem ext {f g : 𝓢(E, F)} (h : ∀ x, (f : E → F) x = g x) : f = g :=
  FunLike.ext f g h
#align schwartz_map.ext SchwartzMap.ext
-/

section IsO

variable (f : 𝓢(E, F))

#print SchwartzMap.isBigO_cocompact_zpow_neg_nat /-
/-- Auxiliary lemma, used in proving the more general result `is_O_cocompact_zpow`. -/
theorem isBigO_cocompact_zpow_neg_nat (k : ℕ) :
    Asymptotics.IsBigO (Filter.cocompact E) f fun x => ‖x‖ ^ (-k : ℤ) :=
  by
  obtain ⟨d, hd, hd'⟩ := f.decay k 0
  simp_rw [norm_iteratedFDeriv_zero] at hd' 
  simp_rw [Asymptotics.IsBigO, Asymptotics.IsBigOWith]
  refine' ⟨d, Filter.Eventually.filter_mono Filter.cocompact_le_cofinite _⟩
  refine' (Filter.eventually_cofinite_ne 0).mp (Filter.eventually_of_forall fun x hx => _)
  rwa [Real.norm_of_nonneg (zpow_nonneg (norm_nonneg _) _), zpow_neg, ← div_eq_mul_inv, le_div_iff']
  exacts [hd' x, zpow_pos_of_pos (norm_pos_iff.mpr hx) _]
#align schwartz_map.is_O_cocompact_zpow_neg_nat SchwartzMap.isBigO_cocompact_zpow_neg_nat
-/

#print SchwartzMap.isBigO_cocompact_rpow /-
theorem isBigO_cocompact_rpow [ProperSpace E] (s : ℝ) :
    Asymptotics.IsBigO (Filter.cocompact E) f fun x => ‖x‖ ^ s :=
  by
  let k := ⌈-s⌉₊
  have hk : -(k : ℝ) ≤ s := neg_le.mp (Nat.le_ceil (-s))
  refine' (is_O_cocompact_zpow_neg_nat f k).trans _
  refine'
    (_ :
          Asymptotics.IsBigO Filter.atTop (fun x : ℝ => x ^ (-k : ℤ)) fun x : ℝ =>
            x ^ s).comp_tendsto
      tendsto_norm_cocompact_atTop
  simp_rw [Asymptotics.IsBigO, Asymptotics.IsBigOWith]
  refine' ⟨1, Filter.eventually_of_mem (Filter.eventually_ge_atTop 1) fun x hx => _⟩
  rw [one_mul, Real.norm_of_nonneg (Real.rpow_nonneg_of_nonneg (zero_le_one.trans hx) _),
    Real.norm_of_nonneg (zpow_nonneg (zero_le_one.trans hx) _), ← Real.rpow_int_cast, Int.cast_neg,
    Int.cast_ofNat]
  exact Real.rpow_le_rpow_of_exponent_le hx hk
#align schwartz_map.is_O_cocompact_rpow SchwartzMap.isBigO_cocompact_rpow
-/

#print SchwartzMap.isBigO_cocompact_zpow /-
theorem isBigO_cocompact_zpow [ProperSpace E] (k : ℤ) :
    Asymptotics.IsBigO (Filter.cocompact E) f fun x => ‖x‖ ^ k := by
  simpa only [Real.rpow_int_cast] using is_O_cocompact_rpow f k
#align schwartz_map.is_O_cocompact_zpow SchwartzMap.isBigO_cocompact_zpow
-/

end IsO

section Aux

#print SchwartzMap.bounds_nonempty /-
theorem bounds_nonempty (k n : ℕ) (f : 𝓢(E, F)) :
    ∃ c : ℝ, c ∈ {c : ℝ | 0 ≤ c ∧ ∀ x : E, ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ ≤ c} :=
  let ⟨M, hMp, hMb⟩ := f.decay k n
  ⟨M, le_of_lt hMp, hMb⟩
#align schwartz_map.bounds_nonempty SchwartzMap.bounds_nonempty
-/

#print SchwartzMap.bounds_bddBelow /-
theorem bounds_bddBelow (k n : ℕ) (f : 𝓢(E, F)) :
    BddBelow {c | 0 ≤ c ∧ ∀ x, ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ ≤ c} :=
  ⟨0, fun _ ⟨hn, _⟩ => hn⟩
#align schwartz_map.bounds_bdd_below SchwartzMap.bounds_bddBelow
-/

#print SchwartzMap.decay_add_le_aux /-
theorem decay_add_le_aux (k n : ℕ) (f g : 𝓢(E, F)) (x : E) :
    ‖x‖ ^ k * ‖iteratedFDeriv ℝ n (f + g) x‖ ≤
      ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ + ‖x‖ ^ k * ‖iteratedFDeriv ℝ n g x‖ :=
  by
  rw [← mul_add]
  refine' mul_le_mul_of_nonneg_left _ (by positivity)
  convert norm_add_le _ _
  exact iteratedFDeriv_add_apply (f.smooth _) (g.smooth _)
#align schwartz_map.decay_add_le_aux SchwartzMap.decay_add_le_aux
-/

#print SchwartzMap.decay_neg_aux /-
theorem decay_neg_aux (k n : ℕ) (f : 𝓢(E, F)) (x : E) :
    ‖x‖ ^ k * ‖iteratedFDeriv ℝ n (-f) x‖ = ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ :=
  by
  nth_rw 4 [← norm_neg]
  congr
  exact iteratedFDeriv_neg_apply
#align schwartz_map.decay_neg_aux SchwartzMap.decay_neg_aux
-/

variable [NormedField 𝕜] [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F]

#print SchwartzMap.decay_smul_aux /-
theorem decay_smul_aux (k n : ℕ) (f : 𝓢(E, F)) (c : 𝕜) (x : E) :
    ‖x‖ ^ k * ‖iteratedFDeriv ℝ n (c • f) x‖ = ‖c‖ * ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ := by
  rw [mul_comm ‖c‖, mul_assoc, iteratedFDeriv_const_smul_apply (f.smooth _), norm_smul]
#align schwartz_map.decay_smul_aux SchwartzMap.decay_smul_aux
-/

end Aux

section SeminormAux

#print SchwartzMap.seminormAux /-
/-- Helper definition for the seminorms of the Schwartz space. -/
@[protected]
def seminormAux (k n : ℕ) (f : 𝓢(E, F)) : ℝ :=
  sInf {c | 0 ≤ c ∧ ∀ x, ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ ≤ c}
#align schwartz_map.seminorm_aux SchwartzMap.seminormAux
-/

#print SchwartzMap.seminormAux_nonneg /-
theorem seminormAux_nonneg (k n : ℕ) (f : 𝓢(E, F)) : 0 ≤ f.seminormAux k n :=
  le_csInf (bounds_nonempty k n f) fun _ ⟨hx, _⟩ => hx
#align schwartz_map.seminorm_aux_nonneg SchwartzMap.seminormAux_nonneg
-/

#print SchwartzMap.le_seminormAux /-
theorem le_seminormAux (k n : ℕ) (f : 𝓢(E, F)) (x : E) :
    ‖x‖ ^ k * ‖iteratedFDeriv ℝ n (⇑f) x‖ ≤ f.seminormAux k n :=
  le_csInf (bounds_nonempty k n f) fun y ⟨_, h⟩ => h x
#align schwartz_map.le_seminorm_aux SchwartzMap.le_seminormAux
-/

#print SchwartzMap.seminormAux_le_bound /-
/-- If one controls the norm of every `A x`, then one controls the norm of `A`. -/
theorem seminormAux_le_bound (k n : ℕ) (f : 𝓢(E, F)) {M : ℝ} (hMp : 0 ≤ M)
    (hM : ∀ x, ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ ≤ M) : f.seminormAux k n ≤ M :=
  csInf_le (bounds_bddBelow k n f) ⟨hMp, hM⟩
#align schwartz_map.seminorm_aux_le_bound SchwartzMap.seminormAux_le_bound
-/

end SeminormAux

/-! ### Algebraic properties -/


section Smul

variable [NormedField 𝕜] [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F] [NormedField 𝕜'] [NormedSpace 𝕜' F]
  [SMulCommClass ℝ 𝕜' F]

instance : SMul 𝕜 𝓢(E, F) :=
  ⟨fun c f =>
    { toFun := c • f
      smooth' := (f.smooth _).const_smul c
      decay' := fun k n =>
        by
        refine' ⟨f.seminorm_aux k n * (‖c‖ + 1), fun x => _⟩
        have hc : 0 ≤ ‖c‖ := by positivity
        refine' le_trans _ ((mul_le_mul_of_nonneg_right (f.le_seminorm_aux k n x) hc).trans _)
        · apply Eq.le
          rw [mul_comm _ ‖c‖, ← mul_assoc]
          exact decay_smul_aux k n f c x
        · apply mul_le_mul_of_nonneg_left _ (f.seminorm_aux_nonneg k n)
          linarith }⟩

#print SchwartzMap.smul_apply /-
@[simp]
theorem smul_apply {f : 𝓢(E, F)} {c : 𝕜} {x : E} : (c • f) x = c • f x :=
  rfl
#align schwartz_map.smul_apply SchwartzMap.smul_apply
-/

instance [SMul 𝕜 𝕜'] [IsScalarTower 𝕜 𝕜' F] : IsScalarTower 𝕜 𝕜' 𝓢(E, F) :=
  ⟨fun a b f => ext fun x => smul_assoc a b (f x)⟩

instance [SMulCommClass 𝕜 𝕜' F] : SMulCommClass 𝕜 𝕜' 𝓢(E, F) :=
  ⟨fun a b f => ext fun x => smul_comm a b (f x)⟩

#print SchwartzMap.seminormAux_smul_le /-
theorem seminormAux_smul_le (k n : ℕ) (c : 𝕜) (f : 𝓢(E, F)) :
    (c • f).seminormAux k n ≤ ‖c‖ * f.seminormAux k n :=
  by
  refine'
    (c • f).seminormAux_le_bound k n (mul_nonneg (norm_nonneg _) (seminorm_aux_nonneg _ _ _))
      fun x => (decay_smul_aux k n f c x).le.trans _
  rw [mul_assoc]
  exact mul_le_mul_of_nonneg_left (f.le_seminorm_aux k n x) (norm_nonneg _)
#align schwartz_map.seminorm_aux_smul_le SchwartzMap.seminormAux_smul_le
-/

#print SchwartzMap.instNSMul /-
instance instNSMul : SMul ℕ 𝓢(E, F) :=
  ⟨fun c f =>
    { toFun := c • f
      smooth' := (f.smooth _).const_smul c
      decay' :=
        by
        have : c • (f : E → F) = (c : ℝ) • f := by ext x;
          simp only [Pi.smul_apply, ← nsmul_eq_smul_cast]
        simp only [this]
        exact ((c : ℝ) • f).decay' }⟩
#align schwartz_map.has_nsmul SchwartzMap.instNSMul
-/

#print SchwartzMap.instZSMul /-
instance instZSMul : SMul ℤ 𝓢(E, F) :=
  ⟨fun c f =>
    { toFun := c • f
      smooth' := (f.smooth _).const_smul c
      decay' :=
        by
        have : c • (f : E → F) = (c : ℝ) • f := by ext x;
          simp only [Pi.smul_apply, ← zsmul_eq_smul_cast]
        simp only [this]
        exact ((c : ℝ) • f).decay' }⟩
#align schwartz_map.has_zsmul SchwartzMap.instZSMul
-/

end Smul

section Zero

instance : Zero 𝓢(E, F) :=
  ⟨{  toFun := fun _ => 0
      smooth' := contDiff_const
      decay' := fun _ _ => ⟨1, fun _ => by simp⟩ }⟩

instance : Inhabited 𝓢(E, F) :=
  ⟨0⟩

#print SchwartzMap.coe_zero /-
theorem coe_zero : ↑(0 : 𝓢(E, F)) = (0 : E → F) :=
  rfl
#align schwartz_map.coe_zero SchwartzMap.coe_zero
-/

#print SchwartzMap.coeFn_zero /-
@[simp]
theorem coeFn_zero : coeFn (0 : 𝓢(E, F)) = (0 : E → F) :=
  rfl
#align schwartz_map.coe_fn_zero SchwartzMap.coeFn_zero
-/

#print SchwartzMap.zero_apply /-
@[simp]
theorem zero_apply {x : E} : (0 : 𝓢(E, F)) x = 0 :=
  rfl
#align schwartz_map.zero_apply SchwartzMap.zero_apply
-/

#print SchwartzMap.seminormAux_zero /-
theorem seminormAux_zero (k n : ℕ) : (0 : 𝓢(E, F)).seminormAux k n = 0 :=
  le_antisymm (seminormAux_le_bound k n _ rfl.le fun _ => by simp [Pi.zero_def])
    (seminormAux_nonneg _ _ _)
#align schwartz_map.seminorm_aux_zero SchwartzMap.seminormAux_zero
-/

end Zero

section Neg

instance : Neg 𝓢(E, F) :=
  ⟨fun f =>
    ⟨-f, (f.smooth _).neg, fun k n =>
      ⟨f.seminormAux k n, fun x => (decay_neg_aux k n f x).le.trans (f.le_seminormAux k n x)⟩⟩⟩

end Neg

section Add

instance : Add 𝓢(E, F) :=
  ⟨fun f g =>
    ⟨f + g, (f.smooth _).add (g.smooth _), fun k n =>
      ⟨f.seminormAux k n + g.seminormAux k n, fun x =>
        (decay_add_le_aux k n f g x).trans
          (add_le_add (f.le_seminormAux k n x) (g.le_seminormAux k n x))⟩⟩⟩

#print SchwartzMap.add_apply /-
@[simp]
theorem add_apply {f g : 𝓢(E, F)} {x : E} : (f + g) x = f x + g x :=
  rfl
#align schwartz_map.add_apply SchwartzMap.add_apply
-/

#print SchwartzMap.seminormAux_add_le /-
theorem seminormAux_add_le (k n : ℕ) (f g : 𝓢(E, F)) :
    (f + g).seminormAux k n ≤ f.seminormAux k n + g.seminormAux k n :=
  (f + g).seminormAux_le_bound k n
    (add_nonneg (seminormAux_nonneg _ _ _) (seminormAux_nonneg _ _ _)) fun x =>
    (decay_add_le_aux k n f g x).trans <|
      add_le_add (f.le_seminormAux k n x) (g.le_seminormAux k n x)
#align schwartz_map.seminorm_aux_add_le SchwartzMap.seminormAux_add_le
-/

end Add

section Sub

instance : Sub 𝓢(E, F) :=
  ⟨fun f g =>
    ⟨f - g, (f.smooth _).sub (g.smooth _), by
      intro k n
      refine' ⟨f.seminorm_aux k n + g.seminorm_aux k n, fun x => _⟩
      refine' le_trans _ (add_le_add (f.le_seminorm_aux k n x) (g.le_seminorm_aux k n x))
      rw [sub_eq_add_neg]
      rw [← decay_neg_aux k n g x]
      convert decay_add_le_aux k n f (-g) x⟩⟩

#print SchwartzMap.sub_apply /-
-- exact fails with deterministic timeout
@[simp]
theorem sub_apply {f g : 𝓢(E, F)} {x : E} : (f - g) x = f x - g x :=
  rfl
#align schwartz_map.sub_apply SchwartzMap.sub_apply
-/

end Sub

section AddCommGroup

instance : AddCommGroup 𝓢(E, F) :=
  FunLike.coe_injective.AddCommGroup _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl

variable (E F)

#print SchwartzMap.coeHom /-
/-- Coercion as an additive homomorphism. -/
def coeHom : 𝓢(E, F) →+ E → F where
  toFun f := f
  map_zero' := coe_zero
  map_add' _ _ := rfl
#align schwartz_map.coe_hom SchwartzMap.coeHom
-/

variable {E F}

#print SchwartzMap.coe_coeHom /-
theorem coe_coeHom : (coeHom E F : 𝓢(E, F) → E → F) = coeFn :=
  rfl
#align schwartz_map.coe_coe_hom SchwartzMap.coe_coeHom
-/

#print SchwartzMap.coeHom_injective /-
theorem coeHom_injective : Function.Injective (coeHom E F) := by rw [coe_coe_hom];
  exact FunLike.coe_injective
#align schwartz_map.coe_hom_injective SchwartzMap.coeHom_injective
-/

end AddCommGroup

section Module

variable [NormedField 𝕜] [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F]

instance : Module 𝕜 𝓢(E, F) :=
  coeHom_injective.Module 𝕜 (coeHom E F) fun _ _ => rfl

end Module

section Seminorms

/-! ### Seminorms on Schwartz space-/


variable [NormedField 𝕜] [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F]

variable (𝕜)

#print SchwartzMap.seminorm /-
/-- The seminorms of the Schwartz space given by the best constants in the definition of
`𝓢(E, F)`. -/
@[protected]
def seminorm (k n : ℕ) : Seminorm 𝕜 𝓢(E, F) :=
  Seminorm.ofSMulLE (seminormAux k n) (seminormAux_zero k n) (seminormAux_add_le k n)
    (seminormAux_smul_le k n)
#align schwartz_map.seminorm SchwartzMap.seminorm
-/

#print SchwartzMap.seminorm_le_bound /-
/-- If one controls the seminorm for every `x`, then one controls the seminorm. -/
theorem seminorm_le_bound (k n : ℕ) (f : 𝓢(E, F)) {M : ℝ} (hMp : 0 ≤ M)
    (hM : ∀ x, ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ ≤ M) : Seminorm 𝕜 k n f ≤ M :=
  f.seminormAux_le_bound k n hMp hM
#align schwartz_map.seminorm_le_bound SchwartzMap.seminorm_le_bound
-/

#print SchwartzMap.seminorm_le_bound' /-
/-- If one controls the seminorm for every `x`, then one controls the seminorm.

Variant for functions `𝓢(ℝ, F)`. -/
theorem seminorm_le_bound' (k n : ℕ) (f : 𝓢(ℝ, F)) {M : ℝ} (hMp : 0 ≤ M)
    (hM : ∀ x, |x| ^ k * ‖iteratedDeriv n f x‖ ≤ M) : Seminorm 𝕜 k n f ≤ M :=
  by
  refine' seminorm_le_bound 𝕜 k n f hMp _
  simpa only [Real.norm_eq_abs, norm_iteratedFDeriv_eq_norm_iteratedDeriv]
#align schwartz_map.seminorm_le_bound' SchwartzMap.seminorm_le_bound'
-/

#print SchwartzMap.le_seminorm /-
/-- The seminorm controls the Schwartz estimate for any fixed `x`. -/
theorem le_seminorm (k n : ℕ) (f : 𝓢(E, F)) (x : E) :
    ‖x‖ ^ k * ‖iteratedFDeriv ℝ n f x‖ ≤ Seminorm 𝕜 k n f :=
  f.le_seminormAux k n x
#align schwartz_map.le_seminorm SchwartzMap.le_seminorm
-/

#print SchwartzMap.le_seminorm' /-
/-- The seminorm controls the Schwartz estimate for any fixed `x`.

Variant for functions `𝓢(ℝ, F)`. -/
theorem le_seminorm' (k n : ℕ) (f : 𝓢(ℝ, F)) (x : ℝ) :
    |x| ^ k * ‖iteratedDeriv n f x‖ ≤ Seminorm 𝕜 k n f :=
  by
  have := le_seminorm 𝕜 k n f x
  rwa [← Real.norm_eq_abs, ← norm_iteratedFDeriv_eq_norm_iteratedDeriv]
#align schwartz_map.le_seminorm' SchwartzMap.le_seminorm'
-/

#print SchwartzMap.norm_iteratedFDeriv_le_seminorm /-
theorem norm_iteratedFDeriv_le_seminorm (f : 𝓢(E, F)) (n : ℕ) (x₀ : E) :
    ‖iteratedFDeriv ℝ n f x₀‖ ≤ (SchwartzMap.seminorm 𝕜 0 n) f :=
  by
  have := SchwartzMap.le_seminorm 𝕜 0 n f x₀
  rwa [pow_zero, one_mul] at this 
#align schwartz_map.norm_iterated_fderiv_le_seminorm SchwartzMap.norm_iteratedFDeriv_le_seminorm
-/

#print SchwartzMap.norm_pow_mul_le_seminorm /-
theorem norm_pow_mul_le_seminorm (f : 𝓢(E, F)) (k : ℕ) (x₀ : E) :
    ‖x₀‖ ^ k * ‖f x₀‖ ≤ (SchwartzMap.seminorm 𝕜 k 0) f :=
  by
  have := SchwartzMap.le_seminorm 𝕜 k 0 f x₀
  rwa [norm_iteratedFDeriv_zero] at this 
#align schwartz_map.norm_pow_mul_le_seminorm SchwartzMap.norm_pow_mul_le_seminorm
-/

#print SchwartzMap.norm_le_seminorm /-
theorem norm_le_seminorm (f : 𝓢(E, F)) (x₀ : E) : ‖f x₀‖ ≤ (SchwartzMap.seminorm 𝕜 0 0) f :=
  by
  have := norm_pow_mul_le_seminorm 𝕜 f 0 x₀
  rwa [pow_zero, one_mul] at this 
#align schwartz_map.norm_le_seminorm SchwartzMap.norm_le_seminorm
-/

variable (𝕜 E F)

#print schwartzSeminormFamily /-
/-- The family of Schwartz seminorms. -/
def schwartzSeminormFamily : SeminormFamily 𝕜 𝓢(E, F) (ℕ × ℕ) := fun m => Seminorm 𝕜 m.1 m.2
#align schwartz_seminorm_family schwartzSeminormFamily
-/

#print SchwartzMap.schwartzSeminormFamily_apply /-
@[simp]
theorem schwartzSeminormFamily_apply (n k : ℕ) :
    schwartzSeminormFamily 𝕜 E F (n, k) = SchwartzMap.seminorm 𝕜 n k :=
  rfl
#align schwartz_map.schwartz_seminorm_family_apply SchwartzMap.schwartzSeminormFamily_apply
-/

#print SchwartzMap.schwartzSeminormFamily_apply_zero /-
@[simp]
theorem schwartzSeminormFamily_apply_zero :
    schwartzSeminormFamily 𝕜 E F 0 = SchwartzMap.seminorm 𝕜 0 0 :=
  rfl
#align schwartz_map.schwartz_seminorm_family_apply_zero SchwartzMap.schwartzSeminormFamily_apply_zero
-/

variable {𝕜 E F}

#print SchwartzMap.one_add_le_sup_seminorm_apply /-
/-- A more convenient version of `le_sup_seminorm_apply`.

The set `finset.Iic m` is the set of all pairs `(k', n')` with `k' ≤ m.1` and `n' ≤ m.2`.
Note that the constant is far from optimal. -/
theorem one_add_le_sup_seminorm_apply {m : ℕ × ℕ} {k n : ℕ} (hk : k ≤ m.1) (hn : n ≤ m.2)
    (f : 𝓢(E, F)) (x : E) :
    (1 + ‖x‖) ^ k * ‖iteratedFDeriv ℝ n f x‖ ≤
      2 ^ m.1 * (Finset.Iic m).sup (fun m => Seminorm 𝕜 m.1 m.2) f :=
  by
  rw [add_comm, add_pow]
  simp only [one_pow, mul_one, Finset.sum_congr, Finset.sum_mul]
  norm_cast
  rw [← Nat.sum_range_choose m.1]
  push_cast
  rw [Finset.sum_mul]
  have hk' : Finset.range (k + 1) ⊆ Finset.range (m.1 + 1) := by
    rwa [Finset.range_subset, add_le_add_iff_right]
  refine' le_trans (Finset.sum_le_sum_of_subset_of_nonneg hk' fun _ _ _ => by positivity) _
  refine' Finset.sum_le_sum fun i hi => _
  rw [mul_comm (‖x‖ ^ i), mul_assoc]
  refine' mul_le_mul _ _ (by positivity) (by positivity)
  · norm_cast
    exact i.choose_le_choose hk
  exact
    (le_seminorm 𝕜 i n f x).trans
      (Seminorm.le_def.1
        (Finset.le_sup_of_le
          (Finset.mem_Iic.2 <| Prod.mk_le_mk.2 ⟨finset.mem_range_succ_iff.mp hi, hn⟩) le_rfl)
        _)
#align schwartz_map.one_add_le_sup_seminorm_apply SchwartzMap.one_add_le_sup_seminorm_apply
-/

end Seminorms

section Topology

/-! ### The topology on the Schwartz space-/


variable [NormedField 𝕜] [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F]

variable (𝕜 E F)

instance : TopologicalSpace 𝓢(E, F) :=
  (schwartzSeminormFamily ℝ E F).ModuleFilterBasis.topology'

#print schwartz_withSeminorms /-
theorem schwartz_withSeminorms : WithSeminorms (schwartzSeminormFamily 𝕜 E F) :=
  by
  have A : WithSeminorms (schwartzSeminormFamily ℝ E F) := ⟨rfl⟩
  rw [SeminormFamily.withSeminorms_iff_nhds_eq_iInf] at A ⊢
  rw [A]
  rfl
#align schwartz_with_seminorms schwartz_withSeminorms
-/

variable {𝕜 E F}

instance : ContinuousSMul 𝕜 𝓢(E, F) :=
  by
  rw [(schwartz_withSeminorms 𝕜 E F).withSeminorms_eq]
  exact (schwartzSeminormFamily 𝕜 E F).ModuleFilterBasis.ContinuousSMul

instance : TopologicalAddGroup 𝓢(E, F) :=
  (schwartzSeminormFamily ℝ E F).AddGroupFilterBasis.isTopologicalAddGroup

instance : UniformSpace 𝓢(E, F) :=
  (schwartzSeminormFamily ℝ E F).AddGroupFilterBasis.UniformSpace

instance : UniformAddGroup 𝓢(E, F) :=
  (schwartzSeminormFamily ℝ E F).AddGroupFilterBasis.UniformAddGroup

instance : LocallyConvexSpace ℝ 𝓢(E, F) :=
  (schwartz_withSeminorms ℝ E F).toLocallyConvexSpace

instance : TopologicalSpace.FirstCountableTopology 𝓢(E, F) :=
  (schwartz_withSeminorms ℝ E F).first_countable

end Topology

section TemperateGrowth

/-! ### Functions of temperate growth -/


#print Function.HasTemperateGrowth /-
/-- A function is called of temperate growth if it is smooth and all iterated derivatives are
polynomially bounded. -/
def Function.HasTemperateGrowth (f : E → F) : Prop :=
  ContDiff ℝ ⊤ f ∧ ∀ n : ℕ, ∃ (k : ℕ) (C : ℝ), ∀ x, ‖iteratedFDeriv ℝ n f x‖ ≤ C * (1 + ‖x‖) ^ k
#align function.has_temperate_growth Function.HasTemperateGrowth
-/

#print Function.HasTemperateGrowth.norm_iteratedFDeriv_le_uniform_aux /-
theorem Function.HasTemperateGrowth.norm_iteratedFDeriv_le_uniform_aux {f : E → F}
    (hf_temperate : f.HasTemperateGrowth) (n : ℕ) :
    ∃ (k : ℕ) (C : ℝ) (hC : 0 ≤ C),
      ∀ (N : ℕ) (hN : N ≤ n) (x : E), ‖iteratedFDeriv ℝ N f x‖ ≤ C * (1 + ‖x‖) ^ k :=
  by
  choose k C f using hf_temperate.2
  use (Finset.range (n + 1)).sup k
  let C' := max (0 : ℝ) ((Finset.range (n + 1)).sup' (by simp) C)
  have hC' : 0 ≤ C' := by simp only [le_refl, Finset.le_sup'_iff, true_or_iff, le_max_iff]
  use C', hC'
  intro N hN x
  rw [← Finset.mem_range_succ_iff] at hN 
  refine' le_trans (f N x) (mul_le_mul _ _ (by positivity) hC')
  · simp only [Finset.le_sup'_iff, le_max_iff]
    right
    exact ⟨N, hN, rfl.le⟩
  refine' pow_le_pow (by simp only [le_add_iff_nonneg_right, norm_nonneg]) _
  exact Finset.le_sup hN
#align function.has_temperate_growth.norm_iterated_fderiv_le_uniform_aux Function.HasTemperateGrowth.norm_iteratedFDeriv_le_uniform_aux
-/

end TemperateGrowth

section Clm

/-! ### Construction of continuous linear maps between Schwartz spaces -/


variable [NormedField 𝕜] [NormedField 𝕜']

variable [NormedAddCommGroup D] [NormedSpace ℝ D]

variable [NormedSpace 𝕜 E] [SMulCommClass ℝ 𝕜 E]

variable [NormedAddCommGroup G] [NormedSpace ℝ G] [NormedSpace 𝕜' G] [SMulCommClass ℝ 𝕜' G]

variable {σ : 𝕜 →+* 𝕜'}

#print SchwartzMap.mkLM /-
/-- Create a semilinear map between Schwartz spaces.

Note: This is a helper definition for `mk_clm`. -/
def mkLM (A : (D → E) → F → G) (hadd : ∀ (f g : 𝓢(D, E)) (x), A (f + g) x = A f x + A g x)
    (hsmul : ∀ (a : 𝕜) (f : 𝓢(D, E)) (x), A (a • f) x = σ a • A f x)
    (hsmooth : ∀ f : 𝓢(D, E), ContDiff ℝ ⊤ (A f))
    (hbound :
      ∀ n : ℕ × ℕ,
        ∃ (s : Finset (ℕ × ℕ)) (C : ℝ) (hC : 0 ≤ C),
          ∀ (f : 𝓢(D, E)) (x : F),
            ‖x‖ ^ n.fst * ‖iteratedFDeriv ℝ n.snd (A f) x‖ ≤
              C * s.sup (schwartzSeminormFamily 𝕜 D E) f) :
    𝓢(D, E) →ₛₗ[σ] 𝓢(F, G)
    where
  toFun f :=
    { toFun := A f
      smooth' := hsmooth f
      decay' := by
        intro k n
        rcases hbound ⟨k, n⟩ with ⟨s, C, hC, h⟩
        exact ⟨C * (s.sup (schwartzSeminormFamily 𝕜 D E)) f, h f⟩ }
  map_add' f g := ext (hadd f g)
  map_smul' a f := ext (hsmul a f)
#align schwartz_map.mk_lm SchwartzMap.mkLM
-/

#print SchwartzMap.mkCLM /-
/-- Create a continuous semilinear map between Schwartz spaces.

For an example of using this definition, see `fderiv_clm`. -/
def mkCLM [RingHomIsometric σ] (A : (D → E) → F → G)
    (hadd : ∀ (f g : 𝓢(D, E)) (x), A (f + g) x = A f x + A g x)
    (hsmul : ∀ (a : 𝕜) (f : 𝓢(D, E)) (x), A (a • f) x = σ a • A f x)
    (hsmooth : ∀ f : 𝓢(D, E), ContDiff ℝ ⊤ (A f))
    (hbound :
      ∀ n : ℕ × ℕ,
        ∃ (s : Finset (ℕ × ℕ)) (C : ℝ) (hC : 0 ≤ C),
          ∀ (f : 𝓢(D, E)) (x : F),
            ‖x‖ ^ n.fst * ‖iteratedFDeriv ℝ n.snd (A f) x‖ ≤
              C * s.sup (schwartzSeminormFamily 𝕜 D E) f) :
    𝓢(D, E) →SL[σ] 𝓢(F, G)
    where
  cont := by
    change Continuous (mk_lm A hadd hsmul hsmooth hbound : 𝓢(D, E) →ₛₗ[σ] 𝓢(F, G))
    refine'
      Seminorm.continuous_from_bounded (schwartz_withSeminorms 𝕜 D E)
        (schwartz_withSeminorms 𝕜' F G) _ fun n => _
    rcases hbound n with ⟨s, C, hC, h⟩
    refine' ⟨s, ⟨C, hC⟩, fun f => _⟩
    simp only [Seminorm.comp_apply, Seminorm.smul_apply, NNReal.smul_def, Algebra.id.smul_eq_mul,
      Subtype.coe_mk]
    exact (mk_lm A hadd hsmul hsmooth hbound f).seminorm_le_bound 𝕜' n.1 n.2 (by positivity) (h f)
  toLinearMap := mkLM A hadd hsmul hsmooth hbound
#align schwartz_map.mk_clm SchwartzMap.mkCLM
-/

end Clm

section EvalClm

variable [NormedField 𝕜] [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F]

#print SchwartzMap.evalCLM /-
/-- The map applying a vector to Hom-valued Schwartz function as a continuous linear map. -/
@[protected]
def evalCLM (m : E) : 𝓢(E, E →L[ℝ] F) →L[𝕜] 𝓢(E, F) :=
  mkCLM (fun f x => f x m) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
    (fun f => ContDiff.clm_apply f.2 contDiff_const)
    (by
      rintro ⟨k, n⟩
      use {(k, n)}, ‖m‖, norm_nonneg _
      intro f x
      refine'
        le_trans
          (mul_le_mul_of_nonneg_left (norm_iteratedFDeriv_clm_apply_const f.2 le_top)
            (by positivity))
          _
      rw [← mul_assoc, ← mul_comm ‖m‖, mul_assoc]
      refine' mul_le_mul_of_nonneg_left _ (norm_nonneg _)
      simp only [Finset.sup_singleton, schwartz_seminorm_family_apply, le_seminorm])
#align schwartz_map.eval_clm SchwartzMap.evalCLM
-/

end EvalClm

section Multiplication

variable [NormedAddCommGroup D] [NormedSpace ℝ D]

variable [NormedAddCommGroup G] [NormedSpace ℝ G]

#print SchwartzMap.bilinLeftCLM /-
/-- The map `f ↦ (x ↦ B (f x) (g x))` as a continuous `𝕜`-linear map on Schwartz space,
where `B` is a continuous `𝕜`-linear map and `g` is a function of temperate growth. -/
def bilinLeftCLM (B : E →L[ℝ] F →L[ℝ] G) {g : D → F} (hg : g.HasTemperateGrowth) :
    𝓢(D, E) →L[ℝ] 𝓢(D, G) :=
  -- Todo (after port): generalize to `B : E →L[𝕜] F →L[𝕜] G` and `𝕜`-linear
    mkCLM
    (fun f x => B (f x) (g x))
    (fun _ _ _ => by
      simp only [map_add, add_left_inj, Pi.add_apply, eq_self_iff_true,
        ContinuousLinearMap.add_apply])
    (fun _ _ _ => by
      simp only [Pi.smul_apply, ContinuousLinearMap.coe_smul', ContinuousLinearMap.map_smul,
        RingHom.id_apply])
    (fun f => (B.IsBoundedBilinearMap.ContDiff.restrictScalars ℝ).comp (f.smooth'.Prod hg.1))
    (by
      -- Porting note: rewrite this proof with `rel_congr`
      rintro ⟨k, n⟩
      rcases hg.norm_iterated_fderiv_le_uniform_aux n with ⟨l, C, hC, hgrowth⟩
      use Finset.Iic (l + k, n), ‖B‖ * (n + 1) * n.choose (n / 2) * (C * 2 ^ (l + k)), by positivity
      intro f x
      have hxk : 0 ≤ ‖x‖ ^ k := by positivity
      have hnorm_mul :=
        ContinuousLinearMap.norm_iteratedFDeriv_le_of_bilinear B f.smooth' hg.1 x le_top
      refine' le_trans (mul_le_mul_of_nonneg_left hnorm_mul hxk) _
      rw [← mul_assoc (‖x‖ ^ k), mul_comm (‖x‖ ^ k)]
      simp_rw [mul_assoc ‖B‖]
      refine' mul_le_mul_of_nonneg_left _ (by positivity)
      rw [Finset.mul_sum]
      have : ∑ x_1 : ℕ in Finset.range (n + 1), (1 : ℝ) = n + 1 := by simp
      repeat' rw [mul_assoc ((n : ℝ) + 1)]
      rw [← this, Finset.sum_mul]
      refine' Finset.sum_le_sum fun i hi => _
      simp only [one_mul]
      rw [← mul_assoc, mul_comm (‖x‖ ^ k), mul_assoc, mul_assoc, mul_assoc]
      refine' mul_le_mul _ _ (by positivity) (by positivity)
      · norm_cast
        exact i.choose_le_middle n
      specialize hgrowth (n - i) (by simp only [tsub_le_self]) x
      rw [← mul_assoc]
      refine' le_trans (mul_le_mul_of_nonneg_left hgrowth (by positivity)) _
      rw [mul_comm _ (C * _), mul_assoc, mul_assoc C]
      refine' mul_le_mul_of_nonneg_left _ hC
      nth_rw 2 [mul_comm]
      rw [← mul_assoc]
      rw [Finset.mem_range_succ_iff] at hi 
      change i ≤ (l + k, n).snd at hi 
      refine' le_trans _ (one_add_le_sup_seminorm_apply le_rfl hi f x)
      refine' mul_le_mul_of_nonneg_right _ (norm_nonneg _)
      rw [pow_add]
      refine' mul_le_mul_of_nonneg_left _ (by positivity)
      refine' pow_le_pow_of_le_left (norm_nonneg _) _ _
      simp only [zero_le_one, le_add_iff_nonneg_left])
#align schwartz_map.bilin_left_clm SchwartzMap.bilinLeftCLM
-/

end Multiplication

section Comp

variable (𝕜)

variable [IsROrC 𝕜]

variable [NormedAddCommGroup D] [NormedSpace ℝ D]

variable [NormedAddCommGroup G] [NormedSpace ℝ G]

variable [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F]

variable [NormedSpace 𝕜 G] [SMulCommClass ℝ 𝕜 G]

#print SchwartzMap.compCLM /-
/-- Composition with a function on the right is a continuous linear map on Schwartz space
provided that the function is temperate and growths polynomially near infinity. -/
def compCLM {g : D → E} (hg : g.HasTemperateGrowth)
    (hg_upper : ∃ (k : ℕ) (C : ℝ), ∀ x, ‖x‖ ≤ C * (1 + ‖g x‖) ^ k) : 𝓢(E, F) →L[𝕜] 𝓢(D, F) :=
  mkCLM (fun f x => f (g x))
    (fun _ _ _ => by simp only [add_left_inj, Pi.add_apply, eq_self_iff_true]) (fun _ _ _ => rfl)
    (fun f => f.smooth'.comp hg.1)
    (by
      rintro ⟨k, n⟩
      rcases hg.norm_iterated_fderiv_le_uniform_aux n with ⟨l, C, hC, hgrowth⟩
      rcases hg_upper with ⟨kg, Cg, hg_upper'⟩
      have hCg : 1 ≤ 1 + Cg := by
        refine' le_add_of_nonneg_right _
        specialize hg_upper' 0
        rw [norm_zero] at hg_upper' 
        refine' nonneg_of_mul_nonneg_left hg_upper' (by positivity)
      let k' := kg * (k + l * n)
      use Finset.Iic (k', n), (1 + Cg) ^ (k + l * n) * ((C + 1) ^ n * n ! * 2 ^ k'), by positivity
      intro f x
      let seminorm_f := ((Finset.Iic (k', n)).sup (schwartzSeminormFamily 𝕜 _ _)) f
      have hg_upper'' : (1 + ‖x‖) ^ (k + l * n) ≤ (1 + Cg) ^ (k + l * n) * (1 + ‖g x‖) ^ k' :=
        by
        rw [pow_mul, ← mul_pow]
        refine' pow_le_pow_of_le_left (by positivity) _ _
        rw [add_mul]
        refine' add_le_add _ (hg_upper' x)
        nth_rw 1 [← one_mul (1 : ℝ)]
        refine' mul_le_mul (le_refl _) (one_le_pow_of_one_le _ _) zero_le_one zero_le_one
        simp only [le_add_iff_nonneg_right, norm_nonneg]
      have hbound :
        ∀ i, i ≤ n → ‖iteratedFDeriv ℝ i f (g x)‖ ≤ 2 ^ k' * seminorm_f / (1 + ‖g x‖) ^ k' :=
        by
        intro i hi
        have hpos : 0 < (1 + ‖g x‖) ^ k' := by positivity
        rw [le_div_iff' hpos]
        change i ≤ (k', n).snd at hi 
        exact one_add_le_sup_seminorm_apply le_rfl hi _ _
      have hgrowth' :
        ∀ (N : ℕ) (hN₁ : 1 ≤ N) (hN₂ : N ≤ n),
          ‖iteratedFDeriv ℝ N g x‖ ≤ ((C + 1) * (1 + ‖x‖) ^ l) ^ N :=
        by
        intro N hN₁ hN₂
        refine' (hgrowth N hN₂ x).trans _
        rw [mul_pow]
        have hN₁' := (lt_of_lt_of_le zero_lt_one hN₁).Ne.symm
        refine' mul_le_mul _ _ (by positivity) (by positivity)
        · exact le_trans (by simp [hC]) (le_self_pow (by simp [hC]) hN₁')
        · refine' le_self_pow (one_le_pow_of_one_le _ l) hN₁'
          simp only [le_add_iff_nonneg_right, norm_nonneg]
      have := norm_iteratedFDeriv_comp_le f.smooth' hg.1 le_top x hbound hgrowth'
      have hxk : ‖x‖ ^ k ≤ (1 + ‖x‖) ^ k :=
        pow_le_pow_of_le_left (norm_nonneg _) (by simp only [zero_le_one, le_add_iff_nonneg_left]) _
      refine' le_trans (mul_le_mul hxk this (by positivity) (by positivity)) _
      have rearrange :
        (1 + ‖x‖) ^ k *
            (n ! * (2 ^ k' * seminorm_f / (1 + ‖g x‖) ^ k') * ((C + 1) * (1 + ‖x‖) ^ l) ^ n) =
          (1 + ‖x‖) ^ (k + l * n) / (1 + ‖g x‖) ^ k' * ((C + 1) ^ n * n ! * 2 ^ k' * seminorm_f) :=
        by
        rw [mul_pow, pow_add, ← pow_mul]
        ring
      rw [rearrange]
      have hgxk' : 0 < (1 + ‖g x‖) ^ k' := by positivity
      rw [← div_le_iff hgxk'] at hg_upper'' 
      have hpos : 0 ≤ (C + 1) ^ n * n ! * 2 ^ k' * seminorm_f :=
        by
        have : 0 ≤ seminorm_f := map_nonneg _ _
        positivity
      refine' le_trans (mul_le_mul_of_nonneg_right hg_upper'' hpos) _
      rw [← mul_assoc])
#align schwartz_map.comp_clm SchwartzMap.compCLM
-/

end Comp

section Derivatives

/-! ### Derivatives of Schwartz functions -/


variable (𝕜)

variable [IsROrC 𝕜] [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F]

#print SchwartzMap.fderivCLM /-
/-- The Fréchet derivative on Schwartz space as a continuous `𝕜`-linear map. -/
def fderivCLM : 𝓢(E, F) →L[𝕜] 𝓢(E, E →L[ℝ] F) :=
  mkCLM (fderiv ℝ) (fun f g _ => fderiv_add f.DifferentiableAt g.DifferentiableAt)
    (fun a f _ => fderiv_const_smul f.DifferentiableAt a)
    (fun f => (contDiff_top_iff_fderiv.mp f.smooth').2) fun ⟨k, n⟩ =>
    ⟨{⟨k, n + 1⟩}, 1, zero_le_one, fun f x => by
      simpa only [schwartz_seminorm_family_apply, Seminorm.comp_apply, Finset.sup_singleton,
        one_smul, norm_iteratedFDeriv_fderiv, one_mul] using f.le_seminorm 𝕜 k (n + 1) x⟩
#align schwartz_map.fderiv_clm SchwartzMap.fderivCLM
-/

#print SchwartzMap.fderivCLM_apply /-
@[simp]
theorem fderivCLM_apply (f : 𝓢(E, F)) (x : E) : fderivCLM 𝕜 f x = fderiv ℝ f x :=
  rfl
#align schwartz_map.fderiv_clm_apply SchwartzMap.fderivCLM_apply
-/

#print SchwartzMap.derivCLM /-
/-- The 1-dimensional derivative on Schwartz space as a continuous `𝕜`-linear map. -/
def derivCLM : 𝓢(ℝ, F) →L[𝕜] 𝓢(ℝ, F) :=
  mkCLM (fun f => deriv f) (fun f g _ => deriv_add f.DifferentiableAt g.DifferentiableAt)
    (fun a f _ => deriv_const_smul a f.DifferentiableAt)
    (fun f => (contDiff_top_iff_deriv.mp f.smooth').2) fun ⟨k, n⟩ =>
    ⟨{⟨k, n + 1⟩}, 1, zero_le_one, fun f x => by
      simpa only [Real.norm_eq_abs, Finset.sup_singleton, schwartz_seminorm_family_apply, one_mul,
        norm_iteratedFDeriv_eq_norm_iteratedDeriv, ← iteratedDeriv_succ'] using
        f.le_seminorm' 𝕜 k (n + 1) x⟩
#align schwartz_map.deriv_clm SchwartzMap.derivCLM
-/

#print SchwartzMap.derivCLM_apply /-
@[simp]
theorem derivCLM_apply (f : 𝓢(ℝ, F)) (x : ℝ) : derivCLM 𝕜 f x = deriv f x :=
  rfl
#align schwartz_map.deriv_clm_apply SchwartzMap.derivCLM_apply
-/

#print SchwartzMap.pderivCLM /-
/-- The partial derivative (or directional derivative) in the direction `m : E` as a
continuous linear map on Schwartz space. -/
def pderivCLM (m : E) : 𝓢(E, F) →L[𝕜] 𝓢(E, F) :=
  (evalCLM m).comp (fderivCLM 𝕜)
#align schwartz_map.pderiv_clm SchwartzMap.pderivCLM
-/

#print SchwartzMap.pderivCLM_apply /-
@[simp]
theorem pderivCLM_apply (m : E) (f : 𝓢(E, F)) (x : E) : pderivCLM 𝕜 m f x = fderiv ℝ f x m :=
  rfl
#align schwartz_map.pderiv_clm_apply SchwartzMap.pderivCLM_apply
-/

#print SchwartzMap.iteratedPDeriv /-
/-- The iterated partial derivative (or directional derivative) as a continuous linear map on
Schwartz space. -/
def iteratedPDeriv {n : ℕ} : (Fin n → E) → 𝓢(E, F) →L[𝕜] 𝓢(E, F) :=
  Nat.recOn n (fun x => ContinuousLinearMap.id 𝕜 _) fun n rec x =>
    (pderivCLM 𝕜 (x 0)).comp (rec (Fin.tail x))
#align schwartz_map.iterated_pderiv SchwartzMap.iteratedPDeriv
-/

#print SchwartzMap.iteratedPDeriv_zero /-
@[simp]
theorem iteratedPDeriv_zero (m : Fin 0 → E) (f : 𝓢(E, F)) : iteratedPDeriv 𝕜 m f = f :=
  rfl
#align schwartz_map.iterated_pderiv_zero SchwartzMap.iteratedPDeriv_zero
-/

#print SchwartzMap.iteratedPDeriv_one /-
@[simp]
theorem iteratedPDeriv_one (m : Fin 1 → E) (f : 𝓢(E, F)) :
    iteratedPDeriv 𝕜 m f = pderivCLM 𝕜 (m 0) f :=
  rfl
#align schwartz_map.iterated_pderiv_one SchwartzMap.iteratedPDeriv_one
-/

#print SchwartzMap.iteratedPDeriv_succ_left /-
theorem iteratedPDeriv_succ_left {n : ℕ} (m : Fin (n + 1) → E) (f : 𝓢(E, F)) :
    iteratedPDeriv 𝕜 m f = pderivCLM 𝕜 (m 0) (iteratedPDeriv 𝕜 (Fin.tail m) f) :=
  rfl
#align schwartz_map.iterated_pderiv_succ_left SchwartzMap.iteratedPDeriv_succ_left
-/

#print SchwartzMap.iteratedPDeriv_succ_right /-
theorem iteratedPDeriv_succ_right {n : ℕ} (m : Fin (n + 1) → E) (f : 𝓢(E, F)) :
    iteratedPDeriv 𝕜 m f = iteratedPDeriv 𝕜 (Fin.init m) (pderivCLM 𝕜 (m (Fin.last n)) f) :=
  by
  induction' n with n IH
  · rw [iterated_pderiv_zero, iterated_pderiv_one]
    rfl
  -- The proof is `∂^{n + 2} = ∂ ∂^{n + 1} = ∂ ∂^n ∂ = ∂^{n+1} ∂`
  have hmzero : Fin.init m 0 = m 0 := by simp only [Fin.init_def, Fin.castSucc_zero]
  have hmtail : Fin.tail m (Fin.last n) = m (Fin.last n.succ) := by
    simp only [Fin.tail_def, Fin.succ_last]
  simp only [iterated_pderiv_succ_left, IH (Fin.tail m), hmzero, hmtail, Fin.tail_init_eq_init_tail]
#align schwartz_map.iterated_pderiv_succ_right SchwartzMap.iteratedPDeriv_succ_right
-/

-- Todo: `iterated_pderiv 𝕜 m f x = iterated_fderiv ℝ f x m`
end Derivatives

section BoundedContinuousFunction

/-! ### Inclusion into the space of bounded continuous functions -/


open scoped BoundedContinuousFunction

#print SchwartzMap.toBoundedContinuousFunction /-
/-- Schwartz functions as bounded continuous functions -/
def toBoundedContinuousFunction (f : 𝓢(E, F)) : E →ᵇ F :=
  BoundedContinuousFunction.ofNormedAddCommGroup f (SchwartzMap.continuous f)
    (SchwartzMap.seminorm ℝ 0 0 f) (norm_le_seminorm ℝ f)
#align schwartz_map.to_bounded_continuous_function SchwartzMap.toBoundedContinuousFunction
-/

#print SchwartzMap.toBoundedContinuousFunction_apply /-
@[simp]
theorem toBoundedContinuousFunction_apply (f : 𝓢(E, F)) (x : E) :
    f.toBoundedContinuousFunction x = f x :=
  rfl
#align schwartz_map.to_bounded_continuous_function_apply SchwartzMap.toBoundedContinuousFunction_apply
-/

#print SchwartzMap.toContinuousMap /-
/-- Schwartz functions as continuous functions -/
def toContinuousMap (f : 𝓢(E, F)) : C(E, F) :=
  f.toBoundedContinuousFunction.toContinuousMap
#align schwartz_map.to_continuous_map SchwartzMap.toContinuousMap
-/

variable (𝕜 E F)

variable [IsROrC 𝕜] [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F]

#print SchwartzMap.toBoundedContinuousFunctionLM /-
/-- The inclusion map from Schwartz functions to bounded continuous functions as a linear map. -/
def toBoundedContinuousFunctionLM : 𝓢(E, F) →ₗ[𝕜] E →ᵇ F
    where
  toFun f := f.toBoundedContinuousFunction
  map_add' f g := by ext; exact add_apply
  map_smul' a f := by ext; exact smul_apply
#align schwartz_map.to_bounded_continuous_function_lm SchwartzMap.toBoundedContinuousFunctionLM
-/

#print SchwartzMap.toBoundedContinuousFunctionLM_apply /-
@[simp]
theorem toBoundedContinuousFunctionLM_apply (f : 𝓢(E, F)) (x : E) :
    toBoundedContinuousFunctionLM 𝕜 E F f x = f x :=
  rfl
#align schwartz_map.to_bounded_continuous_function_lm_apply SchwartzMap.toBoundedContinuousFunctionLM_apply
-/

#print SchwartzMap.toBoundedContinuousFunctionCLM /-
/-- The inclusion map from Schwartz functions to bounded continuous functions as a continuous linear
map. -/
def toBoundedContinuousFunctionCLM : 𝓢(E, F) →L[𝕜] E →ᵇ F :=
  { toBoundedContinuousFunctionLM 𝕜 E F with
    cont := by
      change Continuous (to_bounded_continuous_function_lm 𝕜 E F)
      refine'
        Seminorm.continuous_from_bounded (schwartz_withSeminorms 𝕜 E F)
          (norm_withSeminorms 𝕜 (E →ᵇ F)) _ fun i => ⟨{0}, 1, fun f => _⟩
      rw [Finset.sup_singleton, one_smul, Seminorm.comp_apply, coe_normSeminorm,
        schwartz_seminorm_family_apply_zero, BoundedContinuousFunction.norm_le (map_nonneg _ _)]
      intro x
      exact norm_le_seminorm 𝕜 _ _ }
#align schwartz_map.to_bounded_continuous_function_clm SchwartzMap.toBoundedContinuousFunctionCLM
-/

#print SchwartzMap.toBoundedContinuousFunctionCLM_apply /-
@[simp]
theorem toBoundedContinuousFunctionCLM_apply (f : 𝓢(E, F)) (x : E) :
    toBoundedContinuousFunctionCLM 𝕜 E F f x = f x :=
  rfl
#align schwartz_map.to_bounded_continuous_function_clm_apply SchwartzMap.toBoundedContinuousFunctionCLM_apply
-/

variable {E}

#print SchwartzMap.delta /-
/-- The Dirac delta distribution -/
def delta (x : E) : 𝓢(E, F) →L[𝕜] F :=
  (BoundedContinuousFunction.evalClm 𝕜 x).comp (toBoundedContinuousFunctionCLM 𝕜 E F)
#align schwartz_map.delta SchwartzMap.delta
-/

#print SchwartzMap.delta_apply /-
@[simp]
theorem delta_apply (x₀ : E) (f : 𝓢(E, F)) : delta 𝕜 F x₀ f = f x₀ :=
  rfl
#align schwartz_map.delta_apply SchwartzMap.delta_apply
-/

end BoundedContinuousFunction

end SchwartzMap

