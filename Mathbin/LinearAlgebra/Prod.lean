/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Kevin Buzzard, Yury Kudryashov, Eric Wieser

! This file was ported from Lean 3 source module linear_algebra.prod
! leanprover-community/mathlib commit 23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Span
import Mathbin.Order.PartialSups
import Mathbin.Algebra.Algebra.Prod

/-! ### Products of modules

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines constructors for linear maps whose domains or codomains are products.

It contains theorems relating these to each other, as well as to `submodule.prod`, `submodule.map`,
`submodule.comap`, `linear_map.range`, and `linear_map.ker`.

## Main definitions

- products in the domain:
  - `linear_map.fst`
  - `linear_map.snd`
  - `linear_map.coprod`
  - `linear_map.prod_ext`
- products in the codomain:
  - `linear_map.inl`
  - `linear_map.inr`
  - `linear_map.prod`
- products in both domain and codomain:
  - `linear_map.prod_map`
  - `linear_equiv.prod_map`
  - `linear_equiv.skew_prod`
-/


universe u v w x y z u' v' w' y'

variable {R : Type u} {K : Type u'} {M : Type v} {V : Type v'} {M₂ : Type w} {V₂ : Type w'}

variable {M₃ : Type y} {V₃ : Type y'} {M₄ : Type z} {ι : Type x}

variable {M₅ M₆ : Type _}

section Prod

namespace LinearMap

variable (S : Type _) [Semiring R] [Semiring S]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommMonoid M₄]

variable [AddCommMonoid M₅] [AddCommMonoid M₆]

variable [Module R M] [Module R M₂] [Module R M₃] [Module R M₄]

variable [Module R M₅] [Module R M₆]

variable (f : M →ₗ[R] M₂)

section

variable (R M M₂)

#print LinearMap.fst /-
/-- The first projection of a product is a linear map. -/
def fst : M × M₂ →ₗ[R] M where
  toFun := Prod.fst
  map_add' x y := rfl
  map_smul' x y := rfl
#align linear_map.fst LinearMap.fst
-/

#print LinearMap.snd /-
/-- The second projection of a product is a linear map. -/
def snd : M × M₂ →ₗ[R] M₂ where
  toFun := Prod.snd
  map_add' x y := rfl
  map_smul' x y := rfl
#align linear_map.snd LinearMap.snd
-/

end

#print LinearMap.fst_apply /-
@[simp]
theorem fst_apply (x : M × M₂) : fst R M M₂ x = x.1 :=
  rfl
#align linear_map.fst_apply LinearMap.fst_apply
-/

#print LinearMap.snd_apply /-
@[simp]
theorem snd_apply (x : M × M₂) : snd R M M₂ x = x.2 :=
  rfl
#align linear_map.snd_apply LinearMap.snd_apply
-/

#print LinearMap.fst_surjective /-
theorem fst_surjective : Function.Surjective (fst R M M₂) := fun x => ⟨(x, 0), rfl⟩
#align linear_map.fst_surjective LinearMap.fst_surjective
-/

#print LinearMap.snd_surjective /-
theorem snd_surjective : Function.Surjective (snd R M M₂) := fun x => ⟨(0, x), rfl⟩
#align linear_map.snd_surjective LinearMap.snd_surjective
-/

#print LinearMap.prod /-
/-- The prod of two linear maps is a linear map. -/
@[simps]
def prod (f : M →ₗ[R] M₂) (g : M →ₗ[R] M₃) : M →ₗ[R] M₂ × M₃
    where
  toFun := Pi.prod f g
  map_add' x y := by simp only [Pi.prod, Prod.mk_add_mk, map_add]
  map_smul' c x := by simp only [Pi.prod, Prod.smul_mk, map_smul, RingHom.id_apply]
#align linear_map.prod LinearMap.prod
-/

#print LinearMap.coe_prod /-
theorem coe_prod (f : M →ₗ[R] M₂) (g : M →ₗ[R] M₃) : ⇑(f.Prod g) = Pi.prod f g :=
  rfl
#align linear_map.coe_prod LinearMap.coe_prod
-/

#print LinearMap.fst_prod /-
@[simp]
theorem fst_prod (f : M →ₗ[R] M₂) (g : M →ₗ[R] M₃) : (fst R M₂ M₃).comp (prod f g) = f := by
  ext <;> rfl
#align linear_map.fst_prod LinearMap.fst_prod
-/

#print LinearMap.snd_prod /-
@[simp]
theorem snd_prod (f : M →ₗ[R] M₂) (g : M →ₗ[R] M₃) : (snd R M₂ M₃).comp (prod f g) = g := by
  ext <;> rfl
#align linear_map.snd_prod LinearMap.snd_prod
-/

#print LinearMap.pair_fst_snd /-
@[simp]
theorem pair_fst_snd : prod (fst R M M₂) (snd R M M₂) = LinearMap.id :=
  FunLike.coe_injective Pi.prod_fst_snd
#align linear_map.pair_fst_snd LinearMap.pair_fst_snd
-/

#print LinearMap.prodEquiv /-
/-- Taking the product of two maps with the same domain is equivalent to taking the product of
their codomains.

See note [bundled maps over different rings] for why separate `R` and `S` semirings are used. -/
@[simps]
def prodEquiv [Module S M₂] [Module S M₃] [SMulCommClass R S M₂] [SMulCommClass R S M₃] :
    ((M →ₗ[R] M₂) × (M →ₗ[R] M₃)) ≃ₗ[S] M →ₗ[R] M₂ × M₃
    where
  toFun f := f.1.Prod f.2
  invFun f := ((fst _ _ _).comp f, (snd _ _ _).comp f)
  left_inv f := by ext <;> rfl
  right_inv f := by ext <;> rfl
  map_add' a b := rfl
  map_smul' r a := rfl
#align linear_map.prod_equiv LinearMap.prodEquiv
-/

section

variable (R M M₂)

#print LinearMap.inl /-
/-- The left injection into a product is a linear map. -/
def inl : M →ₗ[R] M × M₂ :=
  prod LinearMap.id 0
#align linear_map.inl LinearMap.inl
-/

#print LinearMap.inr /-
/-- The right injection into a product is a linear map. -/
def inr : M₂ →ₗ[R] M × M₂ :=
  prod 0 LinearMap.id
#align linear_map.inr LinearMap.inr
-/

#print LinearMap.range_inl /-
theorem range_inl : range (inl R M M₂) = ker (snd R M M₂) :=
  by
  ext x
  simp only [mem_ker, mem_range]
  constructor
  · rintro ⟨y, rfl⟩; rfl
  · intro h; exact ⟨x.fst, Prod.ext rfl h.symm⟩
#align linear_map.range_inl LinearMap.range_inl
-/

#print LinearMap.ker_snd /-
theorem ker_snd : ker (snd R M M₂) = range (inl R M M₂) :=
  Eq.symm <| range_inl R M M₂
#align linear_map.ker_snd LinearMap.ker_snd
-/

#print LinearMap.range_inr /-
theorem range_inr : range (inr R M M₂) = ker (fst R M M₂) :=
  by
  ext x
  simp only [mem_ker, mem_range]
  constructor
  · rintro ⟨y, rfl⟩; rfl
  · intro h; exact ⟨x.snd, Prod.ext h.symm rfl⟩
#align linear_map.range_inr LinearMap.range_inr
-/

#print LinearMap.ker_fst /-
theorem ker_fst : ker (fst R M M₂) = range (inr R M M₂) :=
  Eq.symm <| range_inr R M M₂
#align linear_map.ker_fst LinearMap.ker_fst
-/

end

#print LinearMap.coe_inl /-
@[simp]
theorem coe_inl : (inl R M M₂ : M → M × M₂) = fun x => (x, 0) :=
  rfl
#align linear_map.coe_inl LinearMap.coe_inl
-/

#print LinearMap.inl_apply /-
theorem inl_apply (x : M) : inl R M M₂ x = (x, 0) :=
  rfl
#align linear_map.inl_apply LinearMap.inl_apply
-/

#print LinearMap.coe_inr /-
@[simp]
theorem coe_inr : (inr R M M₂ : M₂ → M × M₂) = Prod.mk 0 :=
  rfl
#align linear_map.coe_inr LinearMap.coe_inr
-/

#print LinearMap.inr_apply /-
theorem inr_apply (x : M₂) : inr R M M₂ x = (0, x) :=
  rfl
#align linear_map.inr_apply LinearMap.inr_apply
-/

#print LinearMap.inl_eq_prod /-
theorem inl_eq_prod : inl R M M₂ = prod LinearMap.id 0 :=
  rfl
#align linear_map.inl_eq_prod LinearMap.inl_eq_prod
-/

#print LinearMap.inr_eq_prod /-
theorem inr_eq_prod : inr R M M₂ = prod 0 LinearMap.id :=
  rfl
#align linear_map.inr_eq_prod LinearMap.inr_eq_prod
-/

#print LinearMap.inl_injective /-
theorem inl_injective : Function.Injective (inl R M M₂) := fun _ => by simp
#align linear_map.inl_injective LinearMap.inl_injective
-/

#print LinearMap.inr_injective /-
theorem inr_injective : Function.Injective (inr R M M₂) := fun _ => by simp
#align linear_map.inr_injective LinearMap.inr_injective
-/

#print LinearMap.coprod /-
/-- The coprod function `λ x : M × M₂, f x.1 + g x.2` is a linear map. -/
def coprod (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₃) : M × M₂ →ₗ[R] M₃ :=
  f.comp (fst _ _ _) + g.comp (snd _ _ _)
#align linear_map.coprod LinearMap.coprod
-/

#print LinearMap.coprod_apply /-
@[simp]
theorem coprod_apply (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₃) (x : M × M₂) :
    coprod f g x = f x.1 + g x.2 :=
  rfl
#align linear_map.coprod_apply LinearMap.coprod_apply
-/

#print LinearMap.coprod_inl /-
@[simp]
theorem coprod_inl (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₃) : (coprod f g).comp (inl R M M₂) = f := by
  ext <;> simp only [map_zero, add_zero, coprod_apply, inl_apply, comp_apply]
#align linear_map.coprod_inl LinearMap.coprod_inl
-/

#print LinearMap.coprod_inr /-
@[simp]
theorem coprod_inr (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₃) : (coprod f g).comp (inr R M M₂) = g := by
  ext <;> simp only [map_zero, coprod_apply, inr_apply, zero_add, comp_apply]
#align linear_map.coprod_inr LinearMap.coprod_inr
-/

#print LinearMap.coprod_inl_inr /-
@[simp]
theorem coprod_inl_inr : coprod (inl R M M₂) (inr R M M₂) = LinearMap.id := by
  ext <;>
    simp only [Prod.mk_add_mk, add_zero, id_apply, coprod_apply, inl_apply, inr_apply, zero_add]
#align linear_map.coprod_inl_inr LinearMap.coprod_inl_inr
-/

#print LinearMap.comp_coprod /-
theorem comp_coprod (f : M₃ →ₗ[R] M₄) (g₁ : M →ₗ[R] M₃) (g₂ : M₂ →ₗ[R] M₃) :
    f.comp (g₁.coprod g₂) = (f.comp g₁).coprod (f.comp g₂) :=
  ext fun x => f.map_add (g₁ x.1) (g₂ x.2)
#align linear_map.comp_coprod LinearMap.comp_coprod
-/

#print LinearMap.fst_eq_coprod /-
theorem fst_eq_coprod : fst R M M₂ = coprod LinearMap.id 0 := by ext <;> simp
#align linear_map.fst_eq_coprod LinearMap.fst_eq_coprod
-/

#print LinearMap.snd_eq_coprod /-
theorem snd_eq_coprod : snd R M M₂ = coprod 0 LinearMap.id := by ext <;> simp
#align linear_map.snd_eq_coprod LinearMap.snd_eq_coprod
-/

#print LinearMap.coprod_comp_prod /-
@[simp]
theorem coprod_comp_prod (f : M₂ →ₗ[R] M₄) (g : M₃ →ₗ[R] M₄) (f' : M →ₗ[R] M₂) (g' : M →ₗ[R] M₃) :
    (f.coprod g).comp (f'.Prod g') = f.comp f' + g.comp g' :=
  rfl
#align linear_map.coprod_comp_prod LinearMap.coprod_comp_prod
-/

#print LinearMap.coprod_map_prod /-
@[simp]
theorem coprod_map_prod (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₃) (S : Submodule R M)
    (S' : Submodule R M₂) : (Submodule.prod S S').map (LinearMap.coprod f g) = S.map f ⊔ S'.map g :=
  SetLike.coe_injective <|
    by
    simp only [LinearMap.coprod_apply, Submodule.coe_sup, Submodule.map_coe]
    rw [← Set.image2_add, Set.image2_image_left, Set.image2_image_right]
    exact Set.image_prod fun m m₂ => f m + g m₂
#align linear_map.coprod_map_prod LinearMap.coprod_map_prod
-/

#print LinearMap.coprodEquiv /-
/-- Taking the product of two maps with the same codomain is equivalent to taking the product of
their domains.

See note [bundled maps over different rings] for why separate `R` and `S` semirings are used. -/
@[simps]
def coprodEquiv [Module S M₃] [SMulCommClass R S M₃] :
    ((M →ₗ[R] M₃) × (M₂ →ₗ[R] M₃)) ≃ₗ[S] M × M₂ →ₗ[R] M₃
    where
  toFun f := f.1.coprod f.2
  invFun f := (f.comp (inl _ _ _), f.comp (inr _ _ _))
  left_inv f := by simp only [Prod.mk.eta, coprod_inl, coprod_inr]
  right_inv f := by simp only [← comp_coprod, comp_id, coprod_inl_inr]
  map_add' a b := by ext;
    simp only [Prod.snd_add, add_apply, coprod_apply, Prod.fst_add, add_add_add_comm]
  map_smul' r a := by dsimp; ext;
    simp only [smul_add, smul_apply, Prod.smul_snd, Prod.smul_fst, coprod_apply]
#align linear_map.coprod_equiv LinearMap.coprodEquiv
-/

#print LinearMap.prod_ext_iff /-
theorem prod_ext_iff {f g : M × M₂ →ₗ[R] M₃} :
    f = g ↔ f.comp (inl _ _ _) = g.comp (inl _ _ _) ∧ f.comp (inr _ _ _) = g.comp (inr _ _ _) :=
  (coprodEquiv ℕ).symm.Injective.eq_iff.symm.trans Prod.ext_iff
#align linear_map.prod_ext_iff LinearMap.prod_ext_iff
-/

#print LinearMap.prod_ext /-
/--
Split equality of linear maps from a product into linear maps over each component, to allow `ext`
to apply lemmas specific to `M →ₗ M₃` and `M₂ →ₗ M₃`.

See note [partially-applied ext lemmas]. -/
@[ext]
theorem prod_ext {f g : M × M₂ →ₗ[R] M₃} (hl : f.comp (inl _ _ _) = g.comp (inl _ _ _))
    (hr : f.comp (inr _ _ _) = g.comp (inr _ _ _)) : f = g :=
  prod_ext_iff.2 ⟨hl, hr⟩
#align linear_map.prod_ext LinearMap.prod_ext
-/

#print LinearMap.prodMap /-
/-- `prod.map` of two linear maps. -/
def prodMap (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₄) : M × M₂ →ₗ[R] M₃ × M₄ :=
  (f.comp (fst R M M₂)).Prod (g.comp (snd R M M₂))
#align linear_map.prod_map LinearMap.prodMap
-/

#print LinearMap.coe_prodMap /-
theorem coe_prodMap (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₄) : ⇑(f.Prod_map g) = Prod.map f g :=
  rfl
#align linear_map.coe_prod_map LinearMap.coe_prodMap
-/

#print LinearMap.prodMap_apply /-
@[simp]
theorem prodMap_apply (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₄) (x) : f.Prod_map g x = (f x.1, g x.2) :=
  rfl
#align linear_map.prod_map_apply LinearMap.prodMap_apply
-/

#print LinearMap.prodMap_comap_prod /-
theorem prodMap_comap_prod (f : M →ₗ[R] M₂) (g : M₃ →ₗ[R] M₄) (S : Submodule R M₂)
    (S' : Submodule R M₄) :
    (Submodule.prod S S').comap (LinearMap.prodMap f g) = (S.comap f).Prod (S'.comap g) :=
  SetLike.coe_injective <| Set.preimage_prod_map_prod f g _ _
#align linear_map.prod_map_comap_prod LinearMap.prodMap_comap_prod
-/

#print LinearMap.ker_prodMap /-
theorem ker_prodMap (f : M →ₗ[R] M₂) (g : M₃ →ₗ[R] M₄) :
    (LinearMap.prodMap f g).ker = Submodule.prod f.ker g.ker :=
  by
  dsimp only [ker]
  rw [← prod_map_comap_prod, Submodule.prod_bot]
#align linear_map.ker_prod_map LinearMap.ker_prodMap
-/

#print LinearMap.prodMap_id /-
@[simp]
theorem prodMap_id : (id : M →ₗ[R] M).Prod_map (id : M₂ →ₗ[R] M₂) = id :=
  LinearMap.ext fun _ => Prod.mk.eta
#align linear_map.prod_map_id LinearMap.prodMap_id
-/

#print LinearMap.prodMap_one /-
@[simp]
theorem prodMap_one : (1 : M →ₗ[R] M).Prod_map (1 : M₂ →ₗ[R] M₂) = 1 :=
  LinearMap.ext fun _ => Prod.mk.eta
#align linear_map.prod_map_one LinearMap.prodMap_one
-/

#print LinearMap.prodMap_comp /-
theorem prodMap_comp (f₁₂ : M →ₗ[R] M₂) (f₂₃ : M₂ →ₗ[R] M₃) (g₁₂ : M₄ →ₗ[R] M₅)
    (g₂₃ : M₅ →ₗ[R] M₆) :
    f₂₃.Prod_map g₂₃ ∘ₗ f₁₂.Prod_map g₁₂ = (f₂₃ ∘ₗ f₁₂).Prod_map (g₂₃ ∘ₗ g₁₂) :=
  rfl
#align linear_map.prod_map_comp LinearMap.prodMap_comp
-/

#print LinearMap.prodMap_mul /-
theorem prodMap_mul (f₁₂ : M →ₗ[R] M) (f₂₃ : M →ₗ[R] M) (g₁₂ : M₂ →ₗ[R] M₂) (g₂₃ : M₂ →ₗ[R] M₂) :
    f₂₃.Prod_map g₂₃ * f₁₂.Prod_map g₁₂ = (f₂₃ * f₁₂).Prod_map (g₂₃ * g₁₂) :=
  rfl
#align linear_map.prod_map_mul LinearMap.prodMap_mul
-/

#print LinearMap.prodMap_add /-
theorem prodMap_add (f₁ : M →ₗ[R] M₃) (f₂ : M →ₗ[R] M₃) (g₁ : M₂ →ₗ[R] M₄) (g₂ : M₂ →ₗ[R] M₄) :
    (f₁ + f₂).Prod_map (g₁ + g₂) = f₁.Prod_map g₁ + f₂.Prod_map g₂ :=
  rfl
#align linear_map.prod_map_add LinearMap.prodMap_add
-/

#print LinearMap.prodMap_zero /-
@[simp]
theorem prodMap_zero : (0 : M →ₗ[R] M₂).Prod_map (0 : M₃ →ₗ[R] M₄) = 0 :=
  rfl
#align linear_map.prod_map_zero LinearMap.prodMap_zero
-/

#print LinearMap.prodMap_smul /-
@[simp]
theorem prodMap_smul [Module S M₃] [Module S M₄] [SMulCommClass R S M₃] [SMulCommClass R S M₄]
    (s : S) (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₄) : prodMap (s • f) (s • g) = s • prodMap f g :=
  rfl
#align linear_map.prod_map_smul LinearMap.prodMap_smul
-/

variable (R M M₂ M₃ M₄)

#print LinearMap.prodMapLinear /-
/-- `linear_map.prod_map` as a `linear_map` -/
@[simps]
def prodMapLinear [Module S M₃] [Module S M₄] [SMulCommClass R S M₃] [SMulCommClass R S M₄] :
    (M →ₗ[R] M₃) × (M₂ →ₗ[R] M₄) →ₗ[S] M × M₂ →ₗ[R] M₃ × M₄
    where
  toFun f := prodMap f.1 f.2
  map_add' _ _ := rfl
  map_smul' _ _ := rfl
#align linear_map.prod_map_linear LinearMap.prodMapLinear
-/

#print LinearMap.prodMapRingHom /-
/-- `linear_map.prod_map` as a `ring_hom` -/
@[simps]
def prodMapRingHom : (M →ₗ[R] M) × (M₂ →ₗ[R] M₂) →+* M × M₂ →ₗ[R] M × M₂
    where
  toFun f := prodMap f.1 f.2
  map_one' := prodMap_one
  map_zero' := rfl
  map_add' _ _ := rfl
  map_mul' _ _ := rfl
#align linear_map.prod_map_ring_hom LinearMap.prodMapRingHom
-/

variable {R M M₂ M₃ M₄}

section map_mul

variable {A : Type _} [NonUnitalNonAssocSemiring A] [Module R A]

variable {B : Type _} [NonUnitalNonAssocSemiring B] [Module R B]

#print LinearMap.inl_map_mul /-
theorem inl_map_mul (a₁ a₂ : A) :
    LinearMap.inl R A B (a₁ * a₂) = LinearMap.inl R A B a₁ * LinearMap.inl R A B a₂ :=
  Prod.ext rfl (by simp)
#align linear_map.inl_map_mul LinearMap.inl_map_mul
-/

#print LinearMap.inr_map_mul /-
theorem inr_map_mul (b₁ b₂ : B) :
    LinearMap.inr R A B (b₁ * b₂) = LinearMap.inr R A B b₁ * LinearMap.inr R A B b₂ :=
  Prod.ext (by simp) rfl
#align linear_map.inr_map_mul LinearMap.inr_map_mul
-/

end map_mul

end LinearMap

end Prod

namespace LinearMap

variable (R M M₂)

variable [CommSemiring R]

variable [AddCommMonoid M] [AddCommMonoid M₂]

variable [Module R M] [Module R M₂]

#print LinearMap.prodMapAlgHom /-
/-- `linear_map.prod_map` as an `algebra_hom` -/
@[simps]
def prodMapAlgHom : Module.End R M × Module.End R M₂ →ₐ[R] Module.End R (M × M₂) :=
  { prodMapRingHom R M M₂ with commutes' := fun _ => rfl }
#align linear_map.prod_map_alg_hom LinearMap.prodMapAlgHom
-/

end LinearMap

namespace LinearMap

open Submodule

variable [Semiring R] [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommMonoid M₄]
  [Module R M] [Module R M₂] [Module R M₃] [Module R M₄]

#print LinearMap.range_coprod /-
theorem range_coprod (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₃) : (f.coprod g).range = f.range ⊔ g.range :=
  Submodule.ext fun x => by simp [mem_sup]
#align linear_map.range_coprod LinearMap.range_coprod
-/

#print LinearMap.isCompl_range_inl_inr /-
theorem isCompl_range_inl_inr : IsCompl (inl R M M₂).range (inr R M M₂).range :=
  by
  constructor
  · rw [disjoint_def]
    rintro ⟨_, _⟩ ⟨x, hx⟩ ⟨y, hy⟩
    simp only [Prod.ext_iff, inl_apply, inr_apply, mem_bot] at hx hy ⊢
    exact ⟨hy.1.symm, hx.2.symm⟩
  · rw [codisjoint_iff_le_sup]
    rintro ⟨x, y⟩ -
    simp only [mem_sup, mem_range, exists_prop]
    refine' ⟨(x, 0), ⟨x, rfl⟩, (0, y), ⟨y, rfl⟩, _⟩
    simp
#align linear_map.is_compl_range_inl_inr LinearMap.isCompl_range_inl_inr
-/

#print LinearMap.sup_range_inl_inr /-
theorem sup_range_inl_inr : (inl R M M₂).range ⊔ (inr R M M₂).range = ⊤ :=
  IsCompl.sup_eq_top isCompl_range_inl_inr
#align linear_map.sup_range_inl_inr LinearMap.sup_range_inl_inr
-/

#print LinearMap.disjoint_inl_inr /-
theorem disjoint_inl_inr : Disjoint (inl R M M₂).range (inr R M M₂).range := by
  simp (config := { contextual := true }) [disjoint_def, @eq_comm M 0, @eq_comm M₂ 0] <;> intros <;>
    rfl
#align linear_map.disjoint_inl_inr LinearMap.disjoint_inl_inr
-/

#print LinearMap.map_coprod_prod /-
theorem map_coprod_prod (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₃) (p : Submodule R M)
    (q : Submodule R M₂) : map (coprod f g) (p.Prod q) = map f p ⊔ map g q :=
  by
  refine' le_antisymm _ (sup_le (map_le_iff_le_comap.2 _) (map_le_iff_le_comap.2 _))
  · rw [SetLike.le_def]; rintro _ ⟨x, ⟨h₁, h₂⟩, rfl⟩
    exact mem_sup.2 ⟨_, ⟨_, h₁, rfl⟩, _, ⟨_, h₂, rfl⟩, rfl⟩
  · exact fun x hx => ⟨(x, 0), by simp [hx]⟩
  · exact fun x hx => ⟨(0, x), by simp [hx]⟩
#align linear_map.map_coprod_prod LinearMap.map_coprod_prod
-/

#print LinearMap.comap_prod_prod /-
theorem comap_prod_prod (f : M →ₗ[R] M₂) (g : M →ₗ[R] M₃) (p : Submodule R M₂)
    (q : Submodule R M₃) : comap (prod f g) (p.Prod q) = comap f p ⊓ comap g q :=
  Submodule.ext fun x => Iff.rfl
#align linear_map.comap_prod_prod LinearMap.comap_prod_prod
-/

#print LinearMap.prod_eq_inf_comap /-
theorem prod_eq_inf_comap (p : Submodule R M) (q : Submodule R M₂) :
    p.Prod q = p.comap (LinearMap.fst R M M₂) ⊓ q.comap (LinearMap.snd R M M₂) :=
  Submodule.ext fun x => Iff.rfl
#align linear_map.prod_eq_inf_comap LinearMap.prod_eq_inf_comap
-/

#print LinearMap.prod_eq_sup_map /-
theorem prod_eq_sup_map (p : Submodule R M) (q : Submodule R M₂) :
    p.Prod q = p.map (LinearMap.inl R M M₂) ⊔ q.map (LinearMap.inr R M M₂) := by
  rw [← map_coprod_prod, coprod_inl_inr, map_id]
#align linear_map.prod_eq_sup_map LinearMap.prod_eq_sup_map
-/

#print LinearMap.span_inl_union_inr /-
theorem span_inl_union_inr {s : Set M} {t : Set M₂} :
    span R (inl R M M₂ '' s ∪ inr R M M₂ '' t) = (span R s).Prod (span R t) := by
  rw [span_union, prod_eq_sup_map, ← span_image, ← span_image]
#align linear_map.span_inl_union_inr LinearMap.span_inl_union_inr
-/

#print LinearMap.ker_prod /-
@[simp]
theorem ker_prod (f : M →ₗ[R] M₂) (g : M →ₗ[R] M₃) : ker (prod f g) = ker f ⊓ ker g := by
  rw [ker, ← prod_bot, comap_prod_prod] <;> rfl
#align linear_map.ker_prod LinearMap.ker_prod
-/

#print LinearMap.range_prod_le /-
theorem range_prod_le (f : M →ₗ[R] M₂) (g : M →ₗ[R] M₃) :
    range (prod f g) ≤ (range f).Prod (range g) :=
  by
  simp only [SetLike.le_def, prod_apply, mem_range, SetLike.mem_coe, mem_prod, exists_imp]
  rintro _ x rfl
  exact ⟨⟨x, rfl⟩, ⟨x, rfl⟩⟩
#align linear_map.range_prod_le LinearMap.range_prod_le
-/

#print LinearMap.ker_prod_ker_le_ker_coprod /-
theorem ker_prod_ker_le_ker_coprod {M₂ : Type _} [AddCommGroup M₂] [Module R M₂] {M₃ : Type _}
    [AddCommGroup M₃] [Module R M₃] (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₃) :
    (ker f).Prod (ker g) ≤ ker (f.coprod g) := by rintro ⟨y, z⟩;
  simp (config := { contextual := true })
#align linear_map.ker_prod_ker_le_ker_coprod LinearMap.ker_prod_ker_le_ker_coprod
-/

#print LinearMap.ker_coprod_of_disjoint_range /-
theorem ker_coprod_of_disjoint_range {M₂ : Type _} [AddCommGroup M₂] [Module R M₂] {M₃ : Type _}
    [AddCommGroup M₃] [Module R M₃] (f : M →ₗ[R] M₃) (g : M₂ →ₗ[R] M₃)
    (hd : Disjoint f.range g.range) : ker (f.coprod g) = (ker f).Prod (ker g) :=
  by
  apply le_antisymm _ (ker_prod_ker_le_ker_coprod f g)
  rintro ⟨y, z⟩ h
  simp only [mem_ker, mem_prod, coprod_apply] at h ⊢
  have : f y ∈ f.range ⊓ g.range :=
    by
    simp only [true_and_iff, mem_range, mem_inf, exists_apply_eq_apply]
    use -z
    rwa [eq_comm, map_neg, ← sub_eq_zero, sub_neg_eq_add]
  rw [hd.eq_bot, mem_bot] at this 
  rw [this] at h 
  simpa [this] using h
#align linear_map.ker_coprod_of_disjoint_range LinearMap.ker_coprod_of_disjoint_range
-/

end LinearMap

namespace Submodule

open LinearMap

variable [Semiring R]

variable [AddCommMonoid M] [AddCommMonoid M₂]

variable [Module R M] [Module R M₂]

#print Submodule.sup_eq_range /-
theorem sup_eq_range (p q : Submodule R M) : p ⊔ q = (p.Subtype.coprod q.Subtype).range :=
  Submodule.ext fun x => by simp [Submodule.mem_sup, SetLike.exists]
#align submodule.sup_eq_range Submodule.sup_eq_range
-/

variable (p : Submodule R M) (q : Submodule R M₂)

#print Submodule.map_inl /-
@[simp]
theorem map_inl : p.map (inl R M M₂) = prod p ⊥ := by ext ⟨x, y⟩;
  simp only [and_left_comm, eq_comm, mem_map, Prod.mk.inj_iff, inl_apply, mem_bot, exists_eq_left',
    mem_prod]
#align submodule.map_inl Submodule.map_inl
-/

#print Submodule.map_inr /-
@[simp]
theorem map_inr : q.map (inr R M M₂) = prod ⊥ q := by ext ⟨x, y⟩ <;> simp [and_left_comm, eq_comm]
#align submodule.map_inr Submodule.map_inr
-/

#print Submodule.comap_fst /-
@[simp]
theorem comap_fst : p.comap (fst R M M₂) = prod p ⊤ := by ext ⟨x, y⟩ <;> simp
#align submodule.comap_fst Submodule.comap_fst
-/

#print Submodule.comap_snd /-
@[simp]
theorem comap_snd : q.comap (snd R M M₂) = prod ⊤ q := by ext ⟨x, y⟩ <;> simp
#align submodule.comap_snd Submodule.comap_snd
-/

#print Submodule.prod_comap_inl /-
@[simp]
theorem prod_comap_inl : (prod p q).comap (inl R M M₂) = p := by ext <;> simp
#align submodule.prod_comap_inl Submodule.prod_comap_inl
-/

#print Submodule.prod_comap_inr /-
@[simp]
theorem prod_comap_inr : (prod p q).comap (inr R M M₂) = q := by ext <;> simp
#align submodule.prod_comap_inr Submodule.prod_comap_inr
-/

#print Submodule.prod_map_fst /-
@[simp]
theorem prod_map_fst : (prod p q).map (fst R M M₂) = p := by
  ext x <;> simp [(⟨0, zero_mem _⟩ : ∃ x, x ∈ q)]
#align submodule.prod_map_fst Submodule.prod_map_fst
-/

#print Submodule.prod_map_snd /-
@[simp]
theorem prod_map_snd : (prod p q).map (snd R M M₂) = q := by
  ext x <;> simp [(⟨0, zero_mem _⟩ : ∃ x, x ∈ p)]
#align submodule.prod_map_snd Submodule.prod_map_snd
-/

#print Submodule.ker_inl /-
@[simp]
theorem ker_inl : (inl R M M₂).ker = ⊥ := by rw [ker, ← prod_bot, prod_comap_inl]
#align submodule.ker_inl Submodule.ker_inl
-/

#print Submodule.ker_inr /-
@[simp]
theorem ker_inr : (inr R M M₂).ker = ⊥ := by rw [ker, ← prod_bot, prod_comap_inr]
#align submodule.ker_inr Submodule.ker_inr
-/

#print Submodule.range_fst /-
@[simp]
theorem range_fst : (fst R M M₂).range = ⊤ := by rw [range_eq_map, ← prod_top, prod_map_fst]
#align submodule.range_fst Submodule.range_fst
-/

#print Submodule.range_snd /-
@[simp]
theorem range_snd : (snd R M M₂).range = ⊤ := by rw [range_eq_map, ← prod_top, prod_map_snd]
#align submodule.range_snd Submodule.range_snd
-/

variable (R M M₂)

#print Submodule.fst /-
/-- `M` as a submodule of `M × N`. -/
def fst : Submodule R (M × M₂) :=
  (⊥ : Submodule R M₂).comap (LinearMap.snd R M M₂)
#align submodule.fst Submodule.fst
-/

#print Submodule.fstEquiv /-
/-- `M` as a submodule of `M × N` is isomorphic to `M`. -/
@[simps]
def fstEquiv : Submodule.fst R M M₂ ≃ₗ[R] M
    where
  toFun x := x.1.1
  invFun m := ⟨⟨m, 0⟩, by tidy⟩
  map_add' := by simp
  map_smul' := by simp
  left_inv := by tidy
  right_inv := by tidy
#align submodule.fst_equiv Submodule.fstEquiv
-/

#print Submodule.fst_map_fst /-
theorem fst_map_fst : (Submodule.fst R M M₂).map (LinearMap.fst R M M₂) = ⊤ := by tidy
#align submodule.fst_map_fst Submodule.fst_map_fst
-/

#print Submodule.fst_map_snd /-
theorem fst_map_snd : (Submodule.fst R M M₂).map (LinearMap.snd R M M₂) = ⊥ := by tidy; exact 0
#align submodule.fst_map_snd Submodule.fst_map_snd
-/

#print Submodule.snd /-
/-- `N` as a submodule of `M × N`. -/
def snd : Submodule R (M × M₂) :=
  (⊥ : Submodule R M).comap (LinearMap.fst R M M₂)
#align submodule.snd Submodule.snd
-/

#print Submodule.sndEquiv /-
/-- `N` as a submodule of `M × N` is isomorphic to `N`. -/
@[simps]
def sndEquiv : Submodule.snd R M M₂ ≃ₗ[R] M₂
    where
  toFun x := x.1.2
  invFun n := ⟨⟨0, n⟩, by tidy⟩
  map_add' := by simp
  map_smul' := by simp
  left_inv := by tidy
  right_inv := by tidy
#align submodule.snd_equiv Submodule.sndEquiv
-/

#print Submodule.snd_map_fst /-
theorem snd_map_fst : (Submodule.snd R M M₂).map (LinearMap.fst R M M₂) = ⊥ := by tidy; exact 0
#align submodule.snd_map_fst Submodule.snd_map_fst
-/

#print Submodule.snd_map_snd /-
theorem snd_map_snd : (Submodule.snd R M M₂).map (LinearMap.snd R M M₂) = ⊤ := by tidy
#align submodule.snd_map_snd Submodule.snd_map_snd
-/

#print Submodule.fst_sup_snd /-
theorem fst_sup_snd : Submodule.fst R M M₂ ⊔ Submodule.snd R M M₂ = ⊤ :=
  by
  rw [eq_top_iff]
  rintro ⟨m, n⟩ -
  rw [show (m, n) = (m, 0) + (0, n) by simp]
  apply Submodule.add_mem (Submodule.fst R M M₂ ⊔ Submodule.snd R M M₂)
  · exact Submodule.mem_sup_left (submodule.mem_comap.mpr (by simp))
  · exact Submodule.mem_sup_right (submodule.mem_comap.mpr (by simp))
#align submodule.fst_sup_snd Submodule.fst_sup_snd
-/

#print Submodule.fst_inf_snd /-
theorem fst_inf_snd : Submodule.fst R M M₂ ⊓ Submodule.snd R M M₂ = ⊥ := by tidy
#align submodule.fst_inf_snd Submodule.fst_inf_snd
-/

#print Submodule.le_prod_iff /-
theorem le_prod_iff {p₁ : Submodule R M} {p₂ : Submodule R M₂} {q : Submodule R (M × M₂)} :
    q ≤ p₁.Prod p₂ ↔ map (LinearMap.fst R M M₂) q ≤ p₁ ∧ map (LinearMap.snd R M M₂) q ≤ p₂ :=
  by
  constructor
  · intro h
    constructor
    · rintro x ⟨⟨y1, y2⟩, ⟨hy1, rfl⟩⟩; exact (h hy1).1
    · rintro x ⟨⟨y1, y2⟩, ⟨hy1, rfl⟩⟩; exact (h hy1).2
  · rintro ⟨hH, hK⟩ ⟨x1, x2⟩ h; exact ⟨hH ⟨_, h, rfl⟩, hK ⟨_, h, rfl⟩⟩
#align submodule.le_prod_iff Submodule.le_prod_iff
-/

#print Submodule.prod_le_iff /-
theorem prod_le_iff {p₁ : Submodule R M} {p₂ : Submodule R M₂} {q : Submodule R (M × M₂)} :
    p₁.Prod p₂ ≤ q ↔ map (LinearMap.inl R M M₂) p₁ ≤ q ∧ map (LinearMap.inr R M M₂) p₂ ≤ q :=
  by
  constructor
  · intro h
    constructor
    · rintro _ ⟨x, hx, rfl⟩; apply h; exact ⟨hx, zero_mem p₂⟩
    · rintro _ ⟨x, hx, rfl⟩; apply h; exact ⟨zero_mem p₁, hx⟩
  · rintro ⟨hH, hK⟩ ⟨x1, x2⟩ ⟨h1, h2⟩
    have h1' : (LinearMap.inl R _ _) x1 ∈ q := by apply hH; simpa using h1
    have h2' : (LinearMap.inr R _ _) x2 ∈ q := by apply hK; simpa using h2
    simpa using add_mem h1' h2'
#align submodule.prod_le_iff Submodule.prod_le_iff
-/

#print Submodule.prod_eq_bot_iff /-
theorem prod_eq_bot_iff {p₁ : Submodule R M} {p₂ : Submodule R M₂} :
    p₁.Prod p₂ = ⊥ ↔ p₁ = ⊥ ∧ p₂ = ⊥ := by
  simp only [eq_bot_iff, prod_le_iff, (gc_map_comap _).le_iff_le, comap_bot, ker_inl, ker_inr]
#align submodule.prod_eq_bot_iff Submodule.prod_eq_bot_iff
-/

#print Submodule.prod_eq_top_iff /-
theorem prod_eq_top_iff {p₁ : Submodule R M} {p₂ : Submodule R M₂} :
    p₁.Prod p₂ = ⊤ ↔ p₁ = ⊤ ∧ p₂ = ⊤ := by
  simp only [eq_top_iff, le_prod_iff, ← (gc_map_comap _).le_iff_le, map_top, range_fst, range_snd]
#align submodule.prod_eq_top_iff Submodule.prod_eq_top_iff
-/

end Submodule

namespace LinearEquiv

#print LinearEquiv.prodComm /-
/-- Product of modules is commutative up to linear isomorphism. -/
@[simps apply]
def prodComm (R M N : Type _) [Semiring R] [AddCommMonoid M] [AddCommMonoid N] [Module R M]
    [Module R N] : (M × N) ≃ₗ[R] N × M :=
  { AddEquiv.prodComm with
    toFun := Prod.swap
    map_smul' := fun r ⟨m, n⟩ => rfl }
#align linear_equiv.prod_comm LinearEquiv.prodComm
-/

section

variable [Semiring R]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommMonoid M₄]

variable {module_M : Module R M} {module_M₂ : Module R M₂}

variable {module_M₃ : Module R M₃} {module_M₄ : Module R M₄}

variable (e₁ : M ≃ₗ[R] M₂) (e₂ : M₃ ≃ₗ[R] M₄)

#print LinearEquiv.prod /-
/-- Product of linear equivalences; the maps come from `equiv.prod_congr`. -/
protected def prod : (M × M₃) ≃ₗ[R] M₂ × M₄ :=
  { e₁.toAddEquiv.prodCongr e₂.toAddEquiv with
    map_smul' := fun c x => Prod.ext (e₁.map_smulₛₗ c _) (e₂.map_smulₛₗ c _) }
#align linear_equiv.prod LinearEquiv.prod
-/

#print LinearEquiv.prod_symm /-
theorem prod_symm : (e₁.Prod e₂).symm = e₁.symm.Prod e₂.symm :=
  rfl
#align linear_equiv.prod_symm LinearEquiv.prod_symm
-/

#print LinearEquiv.prod_apply /-
@[simp]
theorem prod_apply (p) : e₁.Prod e₂ p = (e₁ p.1, e₂ p.2) :=
  rfl
#align linear_equiv.prod_apply LinearEquiv.prod_apply
-/

#print LinearEquiv.coe_prod /-
@[simp, norm_cast]
theorem coe_prod :
    (e₁.Prod e₂ : M × M₃ →ₗ[R] M₂ × M₄) = (e₁ : M →ₗ[R] M₂).Prod_map (e₂ : M₃ →ₗ[R] M₄) :=
  rfl
#align linear_equiv.coe_prod LinearEquiv.coe_prod
-/

end

section

variable [Semiring R]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommGroup M₄]

variable {module_M : Module R M} {module_M₂ : Module R M₂}

variable {module_M₃ : Module R M₃} {module_M₄ : Module R M₄}

variable (e₁ : M ≃ₗ[R] M₂) (e₂ : M₃ ≃ₗ[R] M₄)

#print LinearEquiv.skewProd /-
/-- Equivalence given by a block lower diagonal matrix. `e₁` and `e₂` are diagonal square blocks,
  and `f` is a rectangular block below the diagonal. -/
protected def skewProd (f : M →ₗ[R] M₄) : (M × M₃) ≃ₗ[R] M₂ × M₄ :=
  {
    ((e₁ : M →ₗ[R] M₂).comp (LinearMap.fst R M M₃)).Prod
      ((e₂ : M₃ →ₗ[R] M₄).comp (LinearMap.snd R M M₃) +
        f.comp
          (LinearMap.fst R M
            M₃)) with
    invFun := fun p : M₂ × M₄ => (e₁.symm p.1, e₂.symm (p.2 - f (e₁.symm p.1)))
    left_inv := fun p => by simp
    right_inv := fun p => by simp }
#align linear_equiv.skew_prod LinearEquiv.skewProd
-/

#print LinearEquiv.skewProd_apply /-
@[simp]
theorem skewProd_apply (f : M →ₗ[R] M₄) (x) : e₁.skewProd e₂ f x = (e₁ x.1, e₂ x.2 + f x.1) :=
  rfl
#align linear_equiv.skew_prod_apply LinearEquiv.skewProd_apply
-/

#print LinearEquiv.skewProd_symm_apply /-
@[simp]
theorem skewProd_symm_apply (f : M →ₗ[R] M₄) (x) :
    (e₁.skewProd e₂ f).symm x = (e₁.symm x.1, e₂.symm (x.2 - f (e₁.symm x.1))) :=
  rfl
#align linear_equiv.skew_prod_symm_apply LinearEquiv.skewProd_symm_apply
-/

end

end LinearEquiv

namespace LinearMap

open Submodule

variable [Ring R]

variable [AddCommGroup M] [AddCommGroup M₂] [AddCommGroup M₃]

variable [Module R M] [Module R M₂] [Module R M₃]

#print LinearMap.range_prod_eq /-
/-- If the union of the kernels `ker f` and `ker g` spans the domain, then the range of
`prod f g` is equal to the product of `range f` and `range g`. -/
theorem range_prod_eq {f : M →ₗ[R] M₂} {g : M →ₗ[R] M₃} (h : ker f ⊔ ker g = ⊤) :
    range (prod f g) = (range f).Prod (range g) :=
  by
  refine' le_antisymm (f.range_prod_le g) _
  simp only [SetLike.le_def, prod_apply, mem_range, SetLike.mem_coe, mem_prod, exists_imp, and_imp,
    Prod.forall, Pi.prod]
  rintro _ _ x rfl y rfl
  simp only [Prod.mk.inj_iff, ← sub_mem_ker_iff]
  have : y - x ∈ ker f ⊔ ker g := by simp only [h, mem_top]
  rcases mem_sup.1 this with ⟨x', hx', y', hy', H⟩
  refine' ⟨x' + x, _, _⟩
  · simp only [mem_ker.mp hx', map_add, zero_add]
  · simp [← eq_sub_iff_add_eq.1 H, map_add, add_left_inj, self_eq_add_right, mem_ker.mp hy']
#align linear_map.range_prod_eq LinearMap.range_prod_eq
-/

end LinearMap

namespace LinearMap

/-!
## Tunnels and tailings

Some preliminary work for establishing the strong rank condition for noetherian rings.

Given a morphism `f : M × N →ₗ[R] M` which is `i : injective f`,
we can find an infinite decreasing `tunnel f i n` of copies of `M` inside `M`,
and sitting beside these, an infinite sequence of copies of `N`.

We picturesquely name these as `tailing f i n` for each individual copy of `N`,
and `tailings f i n` for the supremum of the first `n+1` copies:
they are the pieces left behind, sitting inside the tunnel.

By construction, each `tailing f i (n+1)` is disjoint from `tailings f i n`;
later, when we assume `M` is noetherian, this implies that `N` must be trivial,
and establishes the strong rank condition for any left-noetherian ring.
-/


section Tunnel

-- (This doesn't work over a semiring: we need to use that `submodule R M` is a modular lattice,
-- which requires cancellation.)
variable [Ring R]

variable {N : Type _} [AddCommGroup M] [Module R M] [AddCommGroup N] [Module R N]

open Function

#print LinearMap.tunnelAux /-
/-- An auxiliary construction for `tunnel`.
The composition of `f`, followed by the isomorphism back to `K`,
followed by the inclusion of this submodule back into `M`. -/
def tunnelAux (f : M × N →ₗ[R] M) (Kφ : Σ K : Submodule R M, K ≃ₗ[R] M) : M × N →ₗ[R] M :=
  (Kφ.1.Subtype.comp Kφ.2.symm.toLinearMap).comp f
#align linear_map.tunnel_aux LinearMap.tunnelAux
-/

#print LinearMap.tunnelAux_injective /-
theorem tunnelAux_injective (f : M × N →ₗ[R] M) (i : Injective f)
    (Kφ : Σ K : Submodule R M, K ≃ₗ[R] M) : Injective (tunnelAux f Kφ) :=
  (Subtype.val_injective.comp Kφ.2.symm.Injective).comp i
#align linear_map.tunnel_aux_injective LinearMap.tunnelAux_injective
-/

noncomputable section

-- Even though we have `noncomputable theory`,
-- we get an error without another `noncomputable` here.
/-- Auxiliary definition for `tunnel`. -/
noncomputable def tunnel' (f : M × N →ₗ[R] M) (i : Injective f) : ℕ → Σ K : Submodule R M, K ≃ₗ[R] M
  | 0 => ⟨⊤, LinearEquiv.ofTop ⊤ rfl⟩
  | n + 1 =>
    ⟨(Submodule.fst R M N).map (tunnelAux f (tunnel' n)),
      ((Submodule.fst R M N).equivMapOfInjective _ (tunnelAux_injective f i (tunnel' n))).symm.trans
        (Submodule.fstEquiv R M N)⟩
#align linear_map.tunnel' LinearMap.tunnel'ₓ

#print LinearMap.tunnel /-
/-- Give an injective map `f : M × N →ₗ[R] M` we can find a nested sequence of submodules
all isomorphic to `M`.
-/
def tunnel (f : M × N →ₗ[R] M) (i : Injective f) : ℕ →o (Submodule R M)ᵒᵈ :=
  ⟨fun n => OrderDual.toDual (tunnel' f i n).1,
    monotone_nat_of_le_succ fun n => by
      dsimp [tunnel', tunnel_aux]
      rw [Submodule.map_comp, Submodule.map_comp]
      apply Submodule.map_subtype_le⟩
#align linear_map.tunnel LinearMap.tunnel
-/

#print LinearMap.tailing /-
/-- Give an injective map `f : M × N →ₗ[R] M` we can find a sequence of submodules
all isomorphic to `N`.
-/
def tailing (f : M × N →ₗ[R] M) (i : Injective f) (n : ℕ) : Submodule R M :=
  (Submodule.snd R M N).map (tunnelAux f (tunnel' f i n))
#align linear_map.tailing LinearMap.tailing
-/

#print LinearMap.tailingLinearEquiv /-
/-- Each `tailing f i n` is a copy of `N`. -/
def tailingLinearEquiv (f : M × N →ₗ[R] M) (i : Injective f) (n : ℕ) : tailing f i n ≃ₗ[R] N :=
  ((Submodule.snd R M N).equivMapOfInjective _ (tunnelAux_injective f i (tunnel' f i n))).symm.trans
    (Submodule.sndEquiv R M N)
#align linear_map.tailing_linear_equiv LinearMap.tailingLinearEquiv
-/

#print LinearMap.tailing_le_tunnel /-
theorem tailing_le_tunnel (f : M × N →ₗ[R] M) (i : Injective f) (n : ℕ) :
    tailing f i n ≤ (tunnel f i n).ofDual :=
  by
  dsimp [tailing, tunnel_aux]
  rw [Submodule.map_comp, Submodule.map_comp]
  apply Submodule.map_subtype_le
#align linear_map.tailing_le_tunnel LinearMap.tailing_le_tunnel
-/

#print LinearMap.tailing_disjoint_tunnel_succ /-
theorem tailing_disjoint_tunnel_succ (f : M × N →ₗ[R] M) (i : Injective f) (n : ℕ) :
    Disjoint (tailing f i n) (tunnel f i (n + 1)).ofDual :=
  by
  rw [disjoint_iff]
  dsimp [tailing, tunnel, tunnel']
  rw [Submodule.map_inf_eq_map_inf_comap,
    Submodule.comap_map_eq_of_injective (tunnel_aux_injective _ i _), inf_comm,
    Submodule.fst_inf_snd, Submodule.map_bot]
#align linear_map.tailing_disjoint_tunnel_succ LinearMap.tailing_disjoint_tunnel_succ
-/

#print LinearMap.tailing_sup_tunnel_succ_le_tunnel /-
theorem tailing_sup_tunnel_succ_le_tunnel (f : M × N →ₗ[R] M) (i : Injective f) (n : ℕ) :
    tailing f i n ⊔ (tunnel f i (n + 1)).ofDual ≤ (tunnel f i n).ofDual :=
  by
  dsimp [tailing, tunnel, tunnel', tunnel_aux]
  rw [← Submodule.map_sup, sup_comm, Submodule.fst_sup_snd, Submodule.map_comp, Submodule.map_comp]
  apply Submodule.map_subtype_le
#align linear_map.tailing_sup_tunnel_succ_le_tunnel LinearMap.tailing_sup_tunnel_succ_le_tunnel
-/

#print LinearMap.tailings /-
/-- The supremum of all the copies of `N` found inside the tunnel. -/
def tailings (f : M × N →ₗ[R] M) (i : Injective f) : ℕ → Submodule R M :=
  partialSups (tailing f i)
#align linear_map.tailings LinearMap.tailings
-/

#print LinearMap.tailings_zero /-
@[simp]
theorem tailings_zero (f : M × N →ₗ[R] M) (i : Injective f) : tailings f i 0 = tailing f i 0 := by
  simp [tailings]
#align linear_map.tailings_zero LinearMap.tailings_zero
-/

#print LinearMap.tailings_succ /-
@[simp]
theorem tailings_succ (f : M × N →ₗ[R] M) (i : Injective f) (n : ℕ) :
    tailings f i (n + 1) = tailings f i n ⊔ tailing f i (n + 1) := by simp [tailings]
#align linear_map.tailings_succ LinearMap.tailings_succ
-/

#print LinearMap.tailings_disjoint_tunnel /-
theorem tailings_disjoint_tunnel (f : M × N →ₗ[R] M) (i : Injective f) (n : ℕ) :
    Disjoint (tailings f i n) (tunnel f i (n + 1)).ofDual :=
  by
  induction' n with n ih
  · simp only [tailings_zero]
    apply tailing_disjoint_tunnel_succ
  · simp only [tailings_succ]
    refine' Disjoint.disjoint_sup_left_of_disjoint_sup_right _ _
    apply tailing_disjoint_tunnel_succ
    apply Disjoint.mono_right _ ih
    apply tailing_sup_tunnel_succ_le_tunnel
#align linear_map.tailings_disjoint_tunnel LinearMap.tailings_disjoint_tunnel
-/

#print LinearMap.tailings_disjoint_tailing /-
theorem tailings_disjoint_tailing (f : M × N →ₗ[R] M) (i : Injective f) (n : ℕ) :
    Disjoint (tailings f i n) (tailing f i (n + 1)) :=
  Disjoint.mono_right (tailing_le_tunnel f i _) (tailings_disjoint_tunnel f i _)
#align linear_map.tailings_disjoint_tailing LinearMap.tailings_disjoint_tailing
-/

end Tunnel

section Graph

variable [Semiring R] [AddCommMonoid M] [AddCommMonoid M₂] [AddCommGroup M₃] [AddCommGroup M₄]
  [Module R M] [Module R M₂] [Module R M₃] [Module R M₄] (f : M →ₗ[R] M₂) (g : M₃ →ₗ[R] M₄)

#print LinearMap.graph /-
/-- Graph of a linear map. -/
def graph : Submodule R (M × M₂)
    where
  carrier := {p | p.2 = f p.1}
  add_mem' a b (ha : _ = _) (hb : _ = _) :=
    by
    change _ + _ = f (_ + _)
    rw [map_add, ha, hb]
  zero_mem' := Eq.symm (map_zero f)
  smul_mem' c x (hx : _ = _) := by
    change _ • _ = f (_ • _)
    rw [map_smul, hx]
#align linear_map.graph LinearMap.graph
-/

#print LinearMap.mem_graph_iff /-
@[simp]
theorem mem_graph_iff (x : M × M₂) : x ∈ f.graph ↔ x.2 = f x.1 :=
  Iff.rfl
#align linear_map.mem_graph_iff LinearMap.mem_graph_iff
-/

#print LinearMap.graph_eq_ker_coprod /-
theorem graph_eq_ker_coprod : g.graph = ((-g).coprod LinearMap.id).ker :=
  by
  ext x
  change _ = _ ↔ -g x.1 + x.2 = _
  rw [add_comm, add_neg_eq_zero]
#align linear_map.graph_eq_ker_coprod LinearMap.graph_eq_ker_coprod
-/

#print LinearMap.graph_eq_range_prod /-
theorem graph_eq_range_prod : f.graph = (LinearMap.id.Prod f).range :=
  by
  ext x
  exact ⟨fun hx => ⟨x.1, Prod.ext rfl hx.symm⟩, fun ⟨u, hu⟩ => hu ▸ rfl⟩
#align linear_map.graph_eq_range_prod LinearMap.graph_eq_range_prod
-/

end Graph

end LinearMap

