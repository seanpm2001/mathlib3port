/-
Copyright (c) 2020 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module linear_algebra.multilinear.tensor_product
! leanprover-community/mathlib commit 19cb3751e5e9b3d97adb51023949c50c13b5fdfd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Multilinear.Basic
import Mathbin.LinearAlgebra.TensorProduct

/-!
# Constructions relating multilinear maps and tensor products.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


namespace MultilinearMap

section DomCoprod

open scoped TensorProduct

variable {R ι₁ ι₂ ι₃ ι₄ : Type _}

variable [CommSemiring R]

variable {N₁ : Type _} [AddCommMonoid N₁] [Module R N₁]

variable {N₂ : Type _} [AddCommMonoid N₂] [Module R N₂]

variable {N : Type _} [AddCommMonoid N] [Module R N]

#print MultilinearMap.domCoprod /-
/-- Given two multilinear maps `(ι₁ → N) → N₁` and `(ι₂ → N) → N₂`, this produces the map
`(ι₁ ⊕ ι₂ → N) → N₁ ⊗ N₂` by taking the coproduct of the domain and the tensor product
of the codomain.

This can be thought of as combining `equiv.sum_arrow_equiv_prod_arrow.symm` with
`tensor_product.map`, noting that the two operations can't be separated as the intermediate result
is not a `multilinear_map`.

While this can be generalized to work for dependent `Π i : ι₁, N'₁ i` instead of `ι₁ → N`, doing so
introduces `sum.elim N'₁ N'₂` types in the result which are difficult to work with and not defeq
to the simple case defined here. See [this zulip thread](
https://leanprover.zulipchat.com/#narrow/stream/217875-Is-there.20code.20for.20X.3F/topic/Instances.20on.20.60sum.2Eelim.20A.20B.20i.60/near/218484619).
-/
@[simps apply]
def domCoprod (a : MultilinearMap R (fun _ : ι₁ => N) N₁)
    (b : MultilinearMap R (fun _ : ι₂ => N) N₂) :
    MultilinearMap R (fun _ : Sum ι₁ ι₂ => N) (N₁ ⊗[R] N₂)
    where
  toFun v := (a fun i => v (Sum.inl i)) ⊗ₜ b fun i => v (Sum.inr i)
  map_add' _ v i p q := by
    skip
    letI := (@Sum.inl_injective ι₁ ι₂).DecidableEq
    letI := (@Sum.inr_injective ι₁ ι₂).DecidableEq
    cases i <;> simp [TensorProduct.add_tmul, TensorProduct.tmul_add]
  map_smul' _ v i c p := by
    skip
    letI := (@Sum.inl_injective ι₁ ι₂).DecidableEq
    letI := (@Sum.inr_injective ι₁ ι₂).DecidableEq
    cases i <;> simp [TensorProduct.smul_tmul', TensorProduct.tmul_smul]
#align multilinear_map.dom_coprod MultilinearMap.domCoprod
-/

#print MultilinearMap.domCoprod' /-
/-- A more bundled version of `multilinear_map.dom_coprod` that maps
`((ι₁ → N) → N₁) ⊗ ((ι₂ → N) → N₂)` to `(ι₁ ⊕ ι₂ → N) → N₁ ⊗ N₂`. -/
def domCoprod' :
    MultilinearMap R (fun _ : ι₁ => N) N₁ ⊗[R] MultilinearMap R (fun _ : ι₂ => N) N₂ →ₗ[R]
      MultilinearMap R (fun _ : Sum ι₁ ι₂ => N) (N₁ ⊗[R] N₂) :=
  TensorProduct.lift <|
    LinearMap.mk₂ R domCoprod
      (fun m₁ m₂ n => by ext; simp only [dom_coprod_apply, TensorProduct.add_tmul, add_apply])
      (fun c m n => by ext; simp only [dom_coprod_apply, TensorProduct.smul_tmul', smul_apply])
      (fun m n₁ n₂ => by ext; simp only [dom_coprod_apply, TensorProduct.tmul_add, add_apply])
      fun c m n => by ext; simp only [dom_coprod_apply, TensorProduct.tmul_smul, smul_apply]
#align multilinear_map.dom_coprod' MultilinearMap.domCoprod'
-/

#print MultilinearMap.domCoprod'_apply /-
@[simp]
theorem domCoprod'_apply (a : MultilinearMap R (fun _ : ι₁ => N) N₁)
    (b : MultilinearMap R (fun _ : ι₂ => N) N₂) : domCoprod' (a ⊗ₜ[R] b) = domCoprod a b :=
  rfl
#align multilinear_map.dom_coprod'_apply MultilinearMap.domCoprod'_apply
-/

#print MultilinearMap.domCoprod_domDomCongr_sumCongr /-
/-- When passed an `equiv.sum_congr`, `multilinear_map.dom_dom_congr` distributes over
`multilinear_map.dom_coprod`. -/
theorem domCoprod_domDomCongr_sumCongr (a : MultilinearMap R (fun _ : ι₁ => N) N₁)
    (b : MultilinearMap R (fun _ : ι₂ => N) N₂) (σa : ι₁ ≃ ι₃) (σb : ι₂ ≃ ι₄) :
    (a.domCoprod b).domDomCongr (σa.sumCongr σb) =
      (a.domDomCongr σa).domCoprod (b.domDomCongr σb) :=
  rfl
#align multilinear_map.dom_coprod_dom_dom_congr_sum_congr MultilinearMap.domCoprod_domDomCongr_sumCongr
-/

end DomCoprod

end MultilinearMap

