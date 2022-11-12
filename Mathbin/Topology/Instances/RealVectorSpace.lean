/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov
-/
import Mathbin.Topology.Algebra.Module.Basic
import Mathbin.Topology.Instances.Real
import Mathbin.Topology.Instances.Rat

/-!
# Continuous additive maps are `ℝ`-linear

In this file we prove that a continuous map `f : E →+ F` between two topological vector spaces
over `ℝ` is `ℝ`-linear
-/


variable {E : Type _} [AddCommGroup E] [Module ℝ E] [TopologicalSpace E] [HasContinuousSmul ℝ E] {F : Type _}
  [AddCommGroup F] [Module ℝ F] [TopologicalSpace F] [HasContinuousSmul ℝ F] [T2Space F]

/-- A continuous additive map between two vector spaces over `ℝ` is `ℝ`-linear. -/
theorem map_real_smul {G} [AddMonoidHomClass G E F] (f : G) (hf : Continuous f) (c : ℝ) (x : E) : f (c • x) = c • f x :=
  suffices (fun c : ℝ => f (c • x)) = fun c : ℝ => c • f x from congr_fun this c
  Rat.dense_embedding_coe_real.dense.equalizer (hf.comp <| continuous_id.smul continuous_const)
    (continuous_id.smul continuous_const) (funext fun r => map_rat_cast_smul f ℝ ℝ r x)
#align map_real_smul map_real_smul

namespace AddMonoidHom

/-- Reinterpret a continuous additive homomorphism between two real vector spaces
as a continuous real-linear map. -/
def toRealLinearMap (f : E →+ F) (hf : Continuous f) : E →L[ℝ] F :=
  ⟨{ toFun := f, map_add' := f.map_add, map_smul' := map_real_smul f hf }, hf⟩
#align add_monoid_hom.to_real_linear_map AddMonoidHom.toRealLinearMap

@[simp]
theorem coe_to_real_linear_map (f : E →+ F) (hf : Continuous f) : ⇑(f.toRealLinearMap hf) = f :=
  rfl
#align add_monoid_hom.coe_to_real_linear_map AddMonoidHom.coe_to_real_linear_map

end AddMonoidHom

/-- Reinterpret a continuous additive equivalence between two real vector spaces
as a continuous real-linear map. -/
def AddEquiv.toRealLinearEquiv (e : E ≃+ F) (h₁ : Continuous e) (h₂ : Continuous e.symm) : E ≃L[ℝ] F :=
  { e, e.toAddMonoidHom.toRealLinearMap h₁ with }
#align add_equiv.to_real_linear_equiv AddEquiv.toRealLinearEquiv

/-- A topological group carries at most one structure of a topological `ℝ`-module, so for any
topological `ℝ`-algebra `A` (e.g. `A = ℂ`) and any topological group that is both a topological
`ℝ`-module and a topological `A`-module, these structures agree. -/
instance (priority := 900) Real.is_scalar_tower [T2Space E] {A : Type _} [TopologicalSpace A] [Ring A] [Algebra ℝ A]
    [Module A E] [HasContinuousSmul ℝ A] [HasContinuousSmul A E] : IsScalarTower ℝ A E :=
  ⟨fun r x y => map_real_smul ((smulAddHom A E).flip y) (continuous_id.smul continuous_const) r x⟩
#align real.is_scalar_tower Real.is_scalar_tower

