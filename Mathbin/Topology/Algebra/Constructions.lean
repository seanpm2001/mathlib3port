/-
Copyright (c) 2021 Nicolò Cavalleri. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nicolò Cavalleri

! This file was ported from Lean 3 source module topology.algebra.constructions
! leanprover-community/mathlib commit c10e724be91096453ee3db13862b9fb9a992fef2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Homeomorph

/-!
# Topological space structure on the opposite monoid and on the units group

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `topological_space` structure on `Mᵐᵒᵖ`, `Mᵃᵒᵖ`, `Mˣ`, and `add_units M`.
This file does not import definitions of a topological monoid and/or a continuous multiplicative
action, so we postpone the proofs of `has_continuous_mul Mᵐᵒᵖ` etc till we have these definitions.

## Tags

topological space, opposite monoid, units
-/


variable {M X : Type _}

open Filter

open scoped Topology

namespace MulOpposite

/-- Put the same topological space structure on the opposite monoid as on the original space. -/
@[to_additive
      "Put the same topological space structure on the opposite monoid as on the original\nspace."]
instance [TopologicalSpace M] : TopologicalSpace Mᵐᵒᵖ :=
  TopologicalSpace.induced (unop : Mᵐᵒᵖ → M) ‹_›

variable [TopologicalSpace M]

#print MulOpposite.continuous_unop /-
@[continuity, to_additive]
theorem continuous_unop : Continuous (unop : Mᵐᵒᵖ → M) :=
  continuous_induced_dom
#align mul_opposite.continuous_unop MulOpposite.continuous_unop
#align add_opposite.continuous_unop AddOpposite.continuous_unop
-/

#print MulOpposite.continuous_op /-
@[continuity, to_additive]
theorem continuous_op : Continuous (op : M → Mᵐᵒᵖ) :=
  continuous_induced_rng.2 continuous_id
#align mul_opposite.continuous_op MulOpposite.continuous_op
#align add_opposite.continuous_op AddOpposite.continuous_op
-/

#print MulOpposite.opHomeomorph /-
/-- `mul_opposite.op` as a homeomorphism. -/
@[to_additive "`add_opposite.op` as a homeomorphism.", simps]
def opHomeomorph : M ≃ₜ Mᵐᵒᵖ where
  toEquiv := opEquiv
  continuous_toFun := continuous_op
  continuous_invFun := continuous_unop
#align mul_opposite.op_homeomorph MulOpposite.opHomeomorph
#align add_opposite.op_homeomorph AddOpposite.opHomeomorph
-/

@[to_additive]
instance [T2Space M] : T2Space Mᵐᵒᵖ :=
  opHomeomorph.symm.Embedding.T2Space

#print MulOpposite.map_op_nhds /-
@[simp, to_additive]
theorem map_op_nhds (x : M) : map (op : M → Mᵐᵒᵖ) (𝓝 x) = 𝓝 (op x) :=
  opHomeomorph.map_nhds_eq x
#align mul_opposite.map_op_nhds MulOpposite.map_op_nhds
#align add_opposite.map_op_nhds AddOpposite.map_op_nhds
-/

#print MulOpposite.map_unop_nhds /-
@[simp, to_additive]
theorem map_unop_nhds (x : Mᵐᵒᵖ) : map (unop : Mᵐᵒᵖ → M) (𝓝 x) = 𝓝 (unop x) :=
  opHomeomorph.symm.map_nhds_eq x
#align mul_opposite.map_unop_nhds MulOpposite.map_unop_nhds
#align add_opposite.map_unop_nhds AddOpposite.map_unop_nhds
-/

#print MulOpposite.comap_op_nhds /-
@[simp, to_additive]
theorem comap_op_nhds (x : Mᵐᵒᵖ) : comap (op : M → Mᵐᵒᵖ) (𝓝 x) = 𝓝 (unop x) :=
  opHomeomorph.comap_nhds_eq x
#align mul_opposite.comap_op_nhds MulOpposite.comap_op_nhds
#align add_opposite.comap_op_nhds AddOpposite.comap_op_nhds
-/

#print MulOpposite.comap_unop_nhds /-
@[simp, to_additive]
theorem comap_unop_nhds (x : M) : comap (unop : Mᵐᵒᵖ → M) (𝓝 x) = 𝓝 (op x) :=
  opHomeomorph.symm.comap_nhds_eq x
#align mul_opposite.comap_unop_nhds MulOpposite.comap_unop_nhds
#align add_opposite.comap_unop_nhds AddOpposite.comap_unop_nhds
-/

end MulOpposite

namespace Units

open MulOpposite

variable [TopologicalSpace M] [Monoid M] [TopologicalSpace X]

/-- The units of a monoid are equipped with a topology, via the embedding into `M × M`. -/
@[to_additive
      "The additive units of a monoid are equipped with a topology, via the embedding into\n`M × M`."]
instance : TopologicalSpace Mˣ :=
  Prod.topologicalSpace.induced (embedProduct M)

#print Units.inducing_embedProduct /-
@[to_additive]
theorem inducing_embedProduct : Inducing (embedProduct M) :=
  ⟨rfl⟩
#align units.inducing_embed_product Units.inducing_embedProduct
#align add_units.inducing_embed_product AddUnits.inducing_embedProduct
-/

#print Units.embedding_embedProduct /-
@[to_additive]
theorem embedding_embedProduct : Embedding (embedProduct M) :=
  ⟨inducing_embedProduct, embedProduct_injective M⟩
#align units.embedding_embed_product Units.embedding_embedProduct
#align add_units.embedding_embed_product AddUnits.embedding_embedProduct
-/

#print Units.topology_eq_inf /-
@[to_additive]
theorem topology_eq_inf :
    Units.topologicalSpace =
      TopologicalSpace.induced (coe : Mˣ → M) ‹_› ⊓
        TopologicalSpace.induced (fun u => ↑u⁻¹ : Mˣ → M) ‹_› :=
  by
  simp only [inducing_embed_product.1, Prod.topologicalSpace, induced_inf,
      MulOpposite.topologicalSpace, induced_compose] <;>
    rfl
#align units.topology_eq_inf Units.topology_eq_inf
#align add_units.topology_eq_inf AddUnits.topology_eq_inf
-/

#print Units.embedding_val_mk /-
/-- An auxiliary lemma that can be used to prove that coercion `Mˣ → M` is a topological embedding.
Use `units.coe_embedding₀`, `units.coe_embedding`, or `to_units_homeomorph` instead. -/
@[to_additive
      "An auxiliary lemma that can be used to prove that coercion `add_units M → M` is a\ntopological embedding. Use `add_units.coe_embedding` or `to_add_units_homeomorph` instead."]
theorem embedding_val_mk {M : Type _} [DivisionMonoid M] [TopologicalSpace M]
    (h : ContinuousOn Inv.inv {x : M | IsUnit x}) : Embedding (coe : Mˣ → M) :=
  by
  refine' ⟨⟨_⟩, ext⟩
  rw [topology_eq_inf, inf_eq_left, ← continuous_iff_le_induced, continuous_iff_continuousAt]
  intro u s hs
  simp only [coe_inv, nhds_induced, Filter.mem_map] at hs ⊢
  exact ⟨_, mem_inf_principal.1 (h u u.is_unit hs), fun u' hu' => hu' u'.IsUnit⟩
#align units.embedding_coe_mk Units.embedding_val_mk
#align add_units.embedding_coe_mk AddUnits.embedding_val_mk
-/

#print Units.continuous_embedProduct /-
@[to_additive]
theorem continuous_embedProduct : Continuous (embedProduct M) :=
  continuous_induced_dom
#align units.continuous_embed_product Units.continuous_embedProduct
#align add_units.continuous_embed_product AddUnits.continuous_embedProduct
-/

#print Units.continuous_val /-
@[to_additive]
theorem continuous_val : Continuous (coe : Mˣ → M) :=
  (@continuous_embedProduct M _ _).fst
#align units.continuous_coe Units.continuous_val
#align add_units.continuous_coe AddUnits.continuous_val
-/

#print Units.continuous_iff /-
@[to_additive]
protected theorem continuous_iff {f : X → Mˣ} :
    Continuous f ↔ Continuous (coe ∘ f : X → M) ∧ Continuous (fun x => ↑(f x)⁻¹ : X → M) := by
  simp only [inducing_embed_product.continuous_iff, embed_product_apply, (· ∘ ·),
    continuous_prod_mk, op_homeomorph.symm.inducing.continuous_iff, op_homeomorph_symm_apply,
    unop_op]
#align units.continuous_iff Units.continuous_iff
#align add_units.continuous_iff AddUnits.continuous_iff
-/

#print Units.continuous_coe_inv /-
@[to_additive]
theorem continuous_coe_inv : Continuous (fun u => ↑u⁻¹ : Mˣ → M) :=
  (Units.continuous_iff.1 continuous_id).2
#align units.continuous_coe_inv Units.continuous_coe_inv
#align add_units.continuous_coe_neg AddUnits.continuous_coe_neg
-/

end Units

