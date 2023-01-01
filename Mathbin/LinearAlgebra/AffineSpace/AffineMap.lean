/-
Copyright (c) 2020 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers

! This file was ported from Lean 3 source module linear_algebra.affine_space.affine_map
! leanprover-community/mathlib commit 9aba7801eeecebb61f58a5763c2b6dd1b47dc6ef
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Pointwise.Interval
import Mathbin.LinearAlgebra.AffineSpace.Basic
import Mathbin.LinearAlgebra.BilinearMap
import Mathbin.LinearAlgebra.Pi
import Mathbin.LinearAlgebra.Prod

/-!
# Affine maps

This file defines affine maps.

## Main definitions

* `affine_map` is the type of affine maps between two affine spaces with the same ring `k`.  Various
  basic examples of affine maps are defined, including `const`, `id`, `line_map` and `homothety`.

## Notations

* `P1 →ᵃ[k] P2` is a notation for `affine_map k P1 P2`;
* `affine_space V P`: a localized notation for `add_torsor V P` defined in
  `linear_algebra.affine_space.basic`.

## Implementation notes

`out_param` is used in the definition of `[add_torsor V P]` to make `V` an implicit argument
(deduced from `P`) in most cases; `include V` is needed in many cases for `V`, and type classes
using it, to be added as implicit arguments to individual lemmas.  As for modules, `k` is an
explicit argument rather than implied by `P` or `V`.

This file only provides purely algebraic definitions and results. Those depending on analysis or
topology are defined elsewhere; see `analysis.normed_space.add_torsor` and
`topology.algebra.affine`.

## References

* https://en.wikipedia.org/wiki/Affine_space
* https://en.wikipedia.org/wiki/Principal_homogeneous_space
-/


open Affine

/-- An `affine_map k P1 P2` (notation: `P1 →ᵃ[k] P2`) is a map from `P1` to `P2` that
induces a corresponding linear map from `V1` to `V2`. -/
structure AffineMap (k : Type _) {V1 : Type _} (P1 : Type _) {V2 : Type _} (P2 : Type _) [Ring k]
  [AddCommGroup V1] [Module k V1] [affine_space V1 P1] [AddCommGroup V2] [Module k V2]
  [affine_space V2 P2] where
  toFun : P1 → P2
  linear : V1 →ₗ[k] V2
  map_vadd' : ∀ (p : P1) (v : V1), to_fun (v +ᵥ p) = linear v +ᵥ to_fun p
#align affine_map AffineMap

-- mathport name: «expr →ᵃ[ ] »
notation:25 P1 " →ᵃ[" k:25 "] " P2:0 => AffineMap k P1 P2

instance (k : Type _) {V1 : Type _} (P1 : Type _) {V2 : Type _} (P2 : Type _) [Ring k]
    [AddCommGroup V1] [Module k V1] [affine_space V1 P1] [AddCommGroup V2] [Module k V2]
    [affine_space V2 P2] : CoeFun (P1 →ᵃ[k] P2) fun _ => P1 → P2 :=
  ⟨AffineMap.toFun⟩

namespace LinearMap

variable {k : Type _} {V₁ : Type _} {V₂ : Type _} [Ring k] [AddCommGroup V₁] [Module k V₁]
  [AddCommGroup V₂] [Module k V₂] (f : V₁ →ₗ[k] V₂)

/-- Reinterpret a linear map as an affine map. -/
def toAffineMap : V₁ →ᵃ[k] V₂ where
  toFun := f
  linear := f
  map_vadd' p v := f.map_add v p
#align linear_map.to_affine_map LinearMap.toAffineMap

@[simp]
theorem coe_to_affine_map : ⇑f.toAffineMap = f :=
  rfl
#align linear_map.coe_to_affine_map LinearMap.coe_to_affine_map

@[simp]
theorem to_affine_map_linear : f.toAffineMap.linear = f :=
  rfl
#align linear_map.to_affine_map_linear LinearMap.to_affine_map_linear

end LinearMap

namespace AffineMap

variable {k : Type _} {V1 : Type _} {P1 : Type _} {V2 : Type _} {P2 : Type _} {V3 : Type _}
  {P3 : Type _} {V4 : Type _} {P4 : Type _} [Ring k] [AddCommGroup V1] [Module k V1]
  [affine_space V1 P1] [AddCommGroup V2] [Module k V2] [affine_space V2 P2] [AddCommGroup V3]
  [Module k V3] [affine_space V3 P3] [AddCommGroup V4] [Module k V4] [affine_space V4 P4]

include V1 V2

/-- Constructing an affine map and coercing back to a function
produces the same map. -/
@[simp]
theorem coe_mk (f : P1 → P2) (linear add) : ((mk f linear add : P1 →ᵃ[k] P2) : P1 → P2) = f :=
  rfl
#align affine_map.coe_mk AffineMap.coe_mk

/-- `to_fun` is the same as the result of coercing to a function. -/
@[simp]
theorem to_fun_eq_coe (f : P1 →ᵃ[k] P2) : f.toFun = ⇑f :=
  rfl
#align affine_map.to_fun_eq_coe AffineMap.to_fun_eq_coe

/-- An affine map on the result of adding a vector to a point produces
the same result as the linear map applied to that vector, added to the
affine map applied to that point. -/
@[simp]
theorem map_vadd (f : P1 →ᵃ[k] P2) (p : P1) (v : V1) : f (v +ᵥ p) = f.linear v +ᵥ f p :=
  f.map_vadd' p v
#align affine_map.map_vadd AffineMap.map_vadd

/-- The linear map on the result of subtracting two points is the
result of subtracting the result of the affine map on those two
points. -/
@[simp]
theorem linear_map_vsub (f : P1 →ᵃ[k] P2) (p1 p2 : P1) : f.linear (p1 -ᵥ p2) = f p1 -ᵥ f p2 := by
  conv_rhs => rw [← vsub_vadd p1 p2, map_vadd, vadd_vsub]
#align affine_map.linear_map_vsub AffineMap.linear_map_vsub

/-- Two affine maps are equal if they coerce to the same function. -/
@[ext]
theorem ext {f g : P1 →ᵃ[k] P2} (h : ∀ p, f p = g p) : f = g :=
  by
  rcases f with ⟨f, f_linear, f_add⟩
  rcases g with ⟨g, g_linear, g_add⟩
  obtain rfl : f = g := funext h
  congr with v
  cases' (AddTorsor.nonempty : Nonempty P1) with p
  apply vadd_right_cancel (f p)
  erw [← f_add, ← g_add]
#align affine_map.ext AffineMap.ext

theorem ext_iff {f g : P1 →ᵃ[k] P2} : f = g ↔ ∀ p, f p = g p :=
  ⟨fun h p => h ▸ rfl, ext⟩
#align affine_map.ext_iff AffineMap.ext_iff

theorem coe_fn_injective : @Function.Injective (P1 →ᵃ[k] P2) (P1 → P2) coeFn := fun f g H =>
  ext <| congr_fun H
#align affine_map.coe_fn_injective AffineMap.coe_fn_injective

protected theorem congr_arg (f : P1 →ᵃ[k] P2) {x y : P1} (h : x = y) : f x = f y :=
  congr_arg _ h
#align affine_map.congr_arg AffineMap.congr_arg

protected theorem congr_fun {f g : P1 →ᵃ[k] P2} (h : f = g) (x : P1) : f x = g x :=
  h ▸ rfl
#align affine_map.congr_fun AffineMap.congr_fun

variable (k P1)

/-- Constant function as an `affine_map`. -/
def const (p : P2) : P1 →ᵃ[k] P2
    where
  toFun := Function.const P1 p
  linear := 0
  map_vadd' p v := by simp
#align affine_map.const AffineMap.const

@[simp]
theorem coe_const (p : P2) : ⇑(const k P1 p) = Function.const P1 p :=
  rfl
#align affine_map.coe_const AffineMap.coe_const

@[simp]
theorem const_linear (p : P2) : (const k P1 p).linear = 0 :=
  rfl
#align affine_map.const_linear AffineMap.const_linear

variable {k P1}

theorem linear_eq_zero_iff_exists_const (f : P1 →ᵃ[k] P2) : f.linear = 0 ↔ ∃ q, f = const k P1 q :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · use f (Classical.arbitrary P1)
    ext
    rw [coe_const, Function.const_apply, ← @vsub_eq_zero_iff_eq V2, ← f.linear_map_vsub, h,
      LinearMap.zero_apply]
  · rcases h with ⟨q, rfl⟩
    exact const_linear k P1 q
#align affine_map.linear_eq_zero_iff_exists_const AffineMap.linear_eq_zero_iff_exists_const

instance nonempty : Nonempty (P1 →ᵃ[k] P2) :=
  (AddTorsor.nonempty : Nonempty P2).elim fun p => ⟨const k P1 p⟩
#align affine_map.nonempty AffineMap.nonempty

/-- Construct an affine map by verifying the relation between the map and its linear part at one
base point. Namely, this function takes a map `f : P₁ → P₂`, a linear map `f' : V₁ →ₗ[k] V₂`, and
a point `p` such that for any other point `p'` we have `f p' = f' (p' -ᵥ p) +ᵥ f p`. -/
def mk' (f : P1 → P2) (f' : V1 →ₗ[k] V2) (p : P1) (h : ∀ p' : P1, f p' = f' (p' -ᵥ p) +ᵥ f p) :
    P1 →ᵃ[k] P2 where
  toFun := f
  linear := f'
  map_vadd' p' v := by rw [h, h p', vadd_vsub_assoc, f'.map_add, vadd_vadd]
#align affine_map.mk' AffineMap.mk'

@[simp]
theorem coe_mk' (f : P1 → P2) (f' : V1 →ₗ[k] V2) (p h) : ⇑(mk' f f' p h) = f :=
  rfl
#align affine_map.coe_mk' AffineMap.coe_mk'

@[simp]
theorem mk'_linear (f : P1 → P2) (f' : V1 →ₗ[k] V2) (p h) : (mk' f f' p h).linear = f' :=
  rfl
#align affine_map.mk'_linear AffineMap.mk'_linear

section HasSmul

variable {R : Type _} [Monoid R] [DistribMulAction R V2] [SMulCommClass k R V2]

/-- The space of affine maps to a module inherits an `R`-action from the action on its codomain. -/
instance : MulAction R (P1 →ᵃ[k] V2)
    where
  smul c f := ⟨c • f, c • f.linear, fun p v => by simp [smul_add]⟩
  one_smul f := ext fun p => one_smul _ _
  mul_smul c₁ c₂ f := ext fun p => mul_smul _ _ _

@[simp, norm_cast]
theorem coe_smul (c : R) (f : P1 →ᵃ[k] V2) : ⇑(c • f) = c • f :=
  rfl
#align affine_map.coe_smul AffineMap.coe_smul

@[simp]
theorem smul_linear (t : R) (f : P1 →ᵃ[k] V2) : (t • f).linear = t • f.linear :=
  rfl
#align affine_map.smul_linear AffineMap.smul_linear

instance [DistribMulAction Rᵐᵒᵖ V2] [IsCentralScalar R V2] : IsCentralScalar R (P1 →ᵃ[k] V2)
    where op_smul_eq_smul r x := ext fun _ => op_smul_eq_smul _ _

end HasSmul

instance : Zero (P1 →ᵃ[k] V2) where zero := ⟨0, 0, fun p v => (zero_vadd _ _).symm⟩

instance : Add (P1 →ᵃ[k] V2)
    where add f g := ⟨f + g, f.linear + g.linear, fun p v => by simp [add_add_add_comm]⟩

instance : Sub (P1 →ᵃ[k] V2)
    where sub f g := ⟨f - g, f.linear - g.linear, fun p v => by simp [sub_add_sub_comm]⟩

instance : Neg (P1 →ᵃ[k] V2) where neg f := ⟨-f, -f.linear, fun p v => by simp [add_comm]⟩

@[simp, norm_cast]
theorem coe_zero : ⇑(0 : P1 →ᵃ[k] V2) = 0 :=
  rfl
#align affine_map.coe_zero AffineMap.coe_zero

@[simp, norm_cast]
theorem coe_add (f g : P1 →ᵃ[k] V2) : ⇑(f + g) = f + g :=
  rfl
#align affine_map.coe_add AffineMap.coe_add

@[simp, norm_cast]
theorem coe_neg (f : P1 →ᵃ[k] V2) : ⇑(-f) = -f :=
  rfl
#align affine_map.coe_neg AffineMap.coe_neg

@[simp, norm_cast]
theorem coe_sub (f g : P1 →ᵃ[k] V2) : ⇑(f - g) = f - g :=
  rfl
#align affine_map.coe_sub AffineMap.coe_sub

@[simp]
theorem zero_linear : (0 : P1 →ᵃ[k] V2).linear = 0 :=
  rfl
#align affine_map.zero_linear AffineMap.zero_linear

@[simp]
theorem add_linear (f g : P1 →ᵃ[k] V2) : (f + g).linear = f.linear + g.linear :=
  rfl
#align affine_map.add_linear AffineMap.add_linear

@[simp]
theorem sub_linear (f g : P1 →ᵃ[k] V2) : (f - g).linear = f.linear - g.linear :=
  rfl
#align affine_map.sub_linear AffineMap.sub_linear

@[simp]
theorem neg_linear (f : P1 →ᵃ[k] V2) : (-f).linear = -f.linear :=
  rfl
#align affine_map.neg_linear AffineMap.neg_linear

/-- The set of affine maps to a vector space is an additive commutative group. -/
instance : AddCommGroup (P1 →ᵃ[k] V2) :=
  coe_fn_injective.AddCommGroup _ coe_zero coe_add coe_neg coe_sub (fun _ _ => coe_smul _ _)
    fun _ _ => coe_smul _ _

/-- The space of affine maps from `P1` to `P2` is an affine space over the space of affine maps
from `P1` to the vector space `V2` corresponding to `P2`. -/
instance : affine_space (P1 →ᵃ[k] V2) (P1 →ᵃ[k] P2)
    where
  vadd f g :=
    ⟨fun p => f p +ᵥ g p, f.linear + g.linear, fun p v => by simp [vadd_vadd, add_right_comm]⟩
  zero_vadd f := ext fun p => zero_vadd _ (f p)
  add_vadd f₁ f₂ f₃ := ext fun p => add_vadd (f₁ p) (f₂ p) (f₃ p)
  vsub f g :=
    ⟨fun p => f p -ᵥ g p, f.linear - g.linear, fun p v => by
      simp [vsub_vadd_eq_vsub_sub, vadd_vsub_assoc, add_sub, sub_add_eq_add_sub]⟩
  vsub_vadd' f g := ext fun p => vsub_vadd (f p) (g p)
  vadd_vsub' f g := ext fun p => vadd_vsub (f p) (g p)

@[simp]
theorem vadd_apply (f : P1 →ᵃ[k] V2) (g : P1 →ᵃ[k] P2) (p : P1) : (f +ᵥ g) p = f p +ᵥ g p :=
  rfl
#align affine_map.vadd_apply AffineMap.vadd_apply

@[simp]
theorem vsub_apply (f g : P1 →ᵃ[k] P2) (p : P1) : (f -ᵥ g : P1 →ᵃ[k] V2) p = f p -ᵥ g p :=
  rfl
#align affine_map.vsub_apply AffineMap.vsub_apply

/-- `prod.fst` as an `affine_map`. -/
def fst : P1 × P2 →ᵃ[k] P1 where
  toFun := Prod.fst
  linear := LinearMap.fst k V1 V2
  map_vadd' _ _ := rfl
#align affine_map.fst AffineMap.fst

@[simp]
theorem coe_fst : ⇑(fst : P1 × P2 →ᵃ[k] P1) = Prod.fst :=
  rfl
#align affine_map.coe_fst AffineMap.coe_fst

@[simp]
theorem fst_linear : (fst : P1 × P2 →ᵃ[k] P1).linear = LinearMap.fst k V1 V2 :=
  rfl
#align affine_map.fst_linear AffineMap.fst_linear

/-- `prod.snd` as an `affine_map`. -/
def snd : P1 × P2 →ᵃ[k] P2 where
  toFun := Prod.snd
  linear := LinearMap.snd k V1 V2
  map_vadd' _ _ := rfl
#align affine_map.snd AffineMap.snd

@[simp]
theorem coe_snd : ⇑(snd : P1 × P2 →ᵃ[k] P2) = Prod.snd :=
  rfl
#align affine_map.coe_snd AffineMap.coe_snd

@[simp]
theorem snd_linear : (snd : P1 × P2 →ᵃ[k] P2).linear = LinearMap.snd k V1 V2 :=
  rfl
#align affine_map.snd_linear AffineMap.snd_linear

variable (k P1)

omit V2

/-- Identity map as an affine map. -/
def id : P1 →ᵃ[k] P1 where
  toFun := id
  linear := LinearMap.id
  map_vadd' p v := rfl
#align affine_map.id AffineMap.id

/-- The identity affine map acts as the identity. -/
@[simp]
theorem coe_id : ⇑(id k P1) = _root_.id :=
  rfl
#align affine_map.coe_id AffineMap.coe_id

@[simp]
theorem id_linear : (id k P1).linear = LinearMap.id :=
  rfl
#align affine_map.id_linear AffineMap.id_linear

variable {P1}

/-- The identity affine map acts as the identity. -/
theorem id_apply (p : P1) : id k P1 p = p :=
  rfl
#align affine_map.id_apply AffineMap.id_apply

variable {k P1}

instance : Inhabited (P1 →ᵃ[k] P1) :=
  ⟨id k P1⟩

include V2 V3

/-- Composition of affine maps. -/
def comp (f : P2 →ᵃ[k] P3) (g : P1 →ᵃ[k] P2) : P1 →ᵃ[k] P3
    where
  toFun := f ∘ g
  linear := f.linear.comp g.linear
  map_vadd' := by
    intro p v
    rw [Function.comp_apply, g.map_vadd, f.map_vadd]
    rfl
#align affine_map.comp AffineMap.comp

/-- Composition of affine maps acts as applying the two functions. -/
@[simp]
theorem coe_comp (f : P2 →ᵃ[k] P3) (g : P1 →ᵃ[k] P2) : ⇑(f.comp g) = f ∘ g :=
  rfl
#align affine_map.coe_comp AffineMap.coe_comp

/-- Composition of affine maps acts as applying the two functions. -/
theorem comp_apply (f : P2 →ᵃ[k] P3) (g : P1 →ᵃ[k] P2) (p : P1) : f.comp g p = f (g p) :=
  rfl
#align affine_map.comp_apply AffineMap.comp_apply

omit V3

@[simp]
theorem comp_id (f : P1 →ᵃ[k] P2) : f.comp (id k P1) = f :=
  ext fun p => rfl
#align affine_map.comp_id AffineMap.comp_id

@[simp]
theorem id_comp (f : P1 →ᵃ[k] P2) : (id k P2).comp f = f :=
  ext fun p => rfl
#align affine_map.id_comp AffineMap.id_comp

include V3 V4

theorem comp_assoc (f₃₄ : P3 →ᵃ[k] P4) (f₂₃ : P2 →ᵃ[k] P3) (f₁₂ : P1 →ᵃ[k] P2) :
    (f₃₄.comp f₂₃).comp f₁₂ = f₃₄.comp (f₂₃.comp f₁₂) :=
  rfl
#align affine_map.comp_assoc AffineMap.comp_assoc

omit V2 V3 V4

instance : Monoid (P1 →ᵃ[k] P1) where
  one := id k P1
  mul := comp
  one_mul := id_comp
  mul_one := comp_id
  mul_assoc := comp_assoc

@[simp]
theorem coe_mul (f g : P1 →ᵃ[k] P1) : ⇑(f * g) = f ∘ g :=
  rfl
#align affine_map.coe_mul AffineMap.coe_mul

@[simp]
theorem coe_one : ⇑(1 : P1 →ᵃ[k] P1) = _root_.id :=
  rfl
#align affine_map.coe_one AffineMap.coe_one

/-- `affine_map.linear` on endomorphisms is a `monoid_hom`. -/
@[simps]
def linearHom : (P1 →ᵃ[k] P1) →* V1 →ₗ[k] V1
    where
  toFun := linear
  map_one' := rfl
  map_mul' _ _ := rfl
#align affine_map.linear_hom AffineMap.linearHom

include V2

@[simp]
theorem linear_injective_iff (f : P1 →ᵃ[k] P2) :
    Function.Injective f.linear ↔ Function.Injective f :=
  by
  obtain ⟨p⟩ := (inferInstance : Nonempty P1)
  have h : ⇑f.linear = (Equiv.vaddConst (f p)).symm ∘ f ∘ Equiv.vaddConst p :=
    by
    ext v
    simp [f.map_vadd, vadd_vsub_assoc]
  rw [h, Equiv.comp_injective, Equiv.injective_comp]
#align affine_map.linear_injective_iff AffineMap.linear_injective_iff

@[simp]
theorem linear_surjective_iff (f : P1 →ᵃ[k] P2) :
    Function.Surjective f.linear ↔ Function.Surjective f :=
  by
  obtain ⟨p⟩ := (inferInstance : Nonempty P1)
  have h : ⇑f.linear = (Equiv.vaddConst (f p)).symm ∘ f ∘ Equiv.vaddConst p :=
    by
    ext v
    simp [f.map_vadd, vadd_vsub_assoc]
  rw [h, Equiv.comp_surjective, Equiv.surjective_comp]
#align affine_map.linear_surjective_iff AffineMap.linear_surjective_iff

@[simp]
theorem linear_bijective_iff (f : P1 →ᵃ[k] P2) :
    Function.Bijective f.linear ↔ Function.Bijective f :=
  and_congr f.linear_injective_iff f.linear_surjective_iff
#align affine_map.linear_bijective_iff AffineMap.linear_bijective_iff

theorem image_vsub_image {s t : Set P1} (f : P1 →ᵃ[k] P2) :
    f '' s -ᵥ f '' t = f.linear '' (s -ᵥ t) := by
  ext v
  simp only [Set.mem_vsub, Set.mem_image, exists_exists_and_eq_and, exists_and_left, ←
    f.linear_map_vsub]
  constructor
  · rintro ⟨x, hx, y, hy, hv⟩
    exact ⟨x -ᵥ y, ⟨x, hx, y, hy, rfl⟩, hv⟩
  · rintro ⟨-, ⟨x, hx, y, hy, rfl⟩, rfl⟩
    exact ⟨x, hx, y, hy, rfl⟩
#align affine_map.image_vsub_image AffineMap.image_vsub_image

omit V2

/-! ### Definition of `affine_map.line_map` and lemmas about it -/


/-- The affine map from `k` to `P1` sending `0` to `p₀` and `1` to `p₁`. -/
def lineMap (p₀ p₁ : P1) : k →ᵃ[k] P1 :=
  ((LinearMap.id : k →ₗ[k] k).smul_right (p₁ -ᵥ p₀)).toAffineMap +ᵥ const k k p₀
#align affine_map.line_map AffineMap.lineMap

theorem coe_line_map (p₀ p₁ : P1) : (lineMap p₀ p₁ : k → P1) = fun c => c • (p₁ -ᵥ p₀) +ᵥ p₀ :=
  rfl
#align affine_map.coe_line_map AffineMap.coe_line_map

theorem line_map_apply (p₀ p₁ : P1) (c : k) : lineMap p₀ p₁ c = c • (p₁ -ᵥ p₀) +ᵥ p₀ :=
  rfl
#align affine_map.line_map_apply AffineMap.line_map_apply

theorem line_map_apply_module' (p₀ p₁ : V1) (c : k) : lineMap p₀ p₁ c = c • (p₁ - p₀) + p₀ :=
  rfl
#align affine_map.line_map_apply_module' AffineMap.line_map_apply_module'

theorem line_map_apply_module (p₀ p₁ : V1) (c : k) : lineMap p₀ p₁ c = (1 - c) • p₀ + c • p₁ := by
  simp [line_map_apply_module', smul_sub, sub_smul] <;> abel
#align affine_map.line_map_apply_module AffineMap.line_map_apply_module

omit V1

theorem line_map_apply_ring' (a b c : k) : lineMap a b c = c * (b - a) + a :=
  rfl
#align affine_map.line_map_apply_ring' AffineMap.line_map_apply_ring'

theorem line_map_apply_ring (a b c : k) : lineMap a b c = (1 - c) * a + c * b :=
  line_map_apply_module a b c
#align affine_map.line_map_apply_ring AffineMap.line_map_apply_ring

include V1

theorem line_map_vadd_apply (p : P1) (v : V1) (c : k) : lineMap p (v +ᵥ p) c = c • v +ᵥ p := by
  rw [line_map_apply, vadd_vsub]
#align affine_map.line_map_vadd_apply AffineMap.line_map_vadd_apply

@[simp]
theorem line_map_linear (p₀ p₁ : P1) :
    (lineMap p₀ p₁ : k →ᵃ[k] P1).linear = LinearMap.id.smul_right (p₁ -ᵥ p₀) :=
  add_zero _
#align affine_map.line_map_linear AffineMap.line_map_linear

theorem line_map_same_apply (p : P1) (c : k) : lineMap p p c = p := by simp [line_map_apply]
#align affine_map.line_map_same_apply AffineMap.line_map_same_apply

@[simp]
theorem line_map_same (p : P1) : lineMap p p = const k k p :=
  ext <| line_map_same_apply p
#align affine_map.line_map_same AffineMap.line_map_same

@[simp]
theorem line_map_apply_zero (p₀ p₁ : P1) : lineMap p₀ p₁ (0 : k) = p₀ := by simp [line_map_apply]
#align affine_map.line_map_apply_zero AffineMap.line_map_apply_zero

@[simp]
theorem line_map_apply_one (p₀ p₁ : P1) : lineMap p₀ p₁ (1 : k) = p₁ := by simp [line_map_apply]
#align affine_map.line_map_apply_one AffineMap.line_map_apply_one

@[simp]
theorem line_map_eq_line_map_iff [NoZeroSmulDivisors k V1] {p₀ p₁ : P1} {c₁ c₂ : k} :
    lineMap p₀ p₁ c₁ = lineMap p₀ p₁ c₂ ↔ p₀ = p₁ ∨ c₁ = c₂ := by
  rw [line_map_apply, line_map_apply, ← @vsub_eq_zero_iff_eq V1, vadd_vsub_vadd_cancel_right, ←
    sub_smul, smul_eq_zero, sub_eq_zero, vsub_eq_zero_iff_eq, or_comm', eq_comm]
#align affine_map.line_map_eq_line_map_iff AffineMap.line_map_eq_line_map_iff

@[simp]
theorem line_map_eq_left_iff [NoZeroSmulDivisors k V1] {p₀ p₁ : P1} {c : k} :
    lineMap p₀ p₁ c = p₀ ↔ p₀ = p₁ ∨ c = 0 := by
  rw [← @line_map_eq_line_map_iff k V1, line_map_apply_zero]
#align affine_map.line_map_eq_left_iff AffineMap.line_map_eq_left_iff

@[simp]
theorem line_map_eq_right_iff [NoZeroSmulDivisors k V1] {p₀ p₁ : P1} {c : k} :
    lineMap p₀ p₁ c = p₁ ↔ p₀ = p₁ ∨ c = 1 := by
  rw [← @line_map_eq_line_map_iff k V1, line_map_apply_one]
#align affine_map.line_map_eq_right_iff AffineMap.line_map_eq_right_iff

variable (k)

theorem line_map_injective [NoZeroSmulDivisors k V1] {p₀ p₁ : P1} (h : p₀ ≠ p₁) :
    Function.Injective (lineMap p₀ p₁ : k → P1) := fun c₁ c₂ hc =>
  (line_map_eq_line_map_iff.mp hc).resolve_left h
#align affine_map.line_map_injective AffineMap.line_map_injective

variable {k}

include V2

@[simp]
theorem apply_line_map (f : P1 →ᵃ[k] P2) (p₀ p₁ : P1) (c : k) :
    f (lineMap p₀ p₁ c) = lineMap (f p₀) (f p₁) c := by simp [line_map_apply]
#align affine_map.apply_line_map AffineMap.apply_line_map

@[simp]
theorem comp_line_map (f : P1 →ᵃ[k] P2) (p₀ p₁ : P1) :
    f.comp (lineMap p₀ p₁) = lineMap (f p₀) (f p₁) :=
  ext <| f.apply_line_map p₀ p₁
#align affine_map.comp_line_map AffineMap.comp_line_map

@[simp]
theorem fst_line_map (p₀ p₁ : P1 × P2) (c : k) : (lineMap p₀ p₁ c).1 = lineMap p₀.1 p₁.1 c :=
  fst.apply_line_map p₀ p₁ c
#align affine_map.fst_line_map AffineMap.fst_line_map

@[simp]
theorem snd_line_map (p₀ p₁ : P1 × P2) (c : k) : (lineMap p₀ p₁ c).2 = lineMap p₀.2 p₁.2 c :=
  snd.apply_line_map p₀ p₁ c
#align affine_map.snd_line_map AffineMap.snd_line_map

omit V2

theorem line_map_symm (p₀ p₁ : P1) :
    lineMap p₀ p₁ = (lineMap p₁ p₀).comp (lineMap (1 : k) (0 : k)) :=
  by
  rw [comp_line_map]
  simp
#align affine_map.line_map_symm AffineMap.line_map_symm

theorem line_map_apply_one_sub (p₀ p₁ : P1) (c : k) : lineMap p₀ p₁ (1 - c) = lineMap p₁ p₀ c :=
  by
  rw [line_map_symm p₀, comp_apply]
  congr
  simp [line_map_apply]
#align affine_map.line_map_apply_one_sub AffineMap.line_map_apply_one_sub

@[simp]
theorem line_map_vsub_left (p₀ p₁ : P1) (c : k) : lineMap p₀ p₁ c -ᵥ p₀ = c • (p₁ -ᵥ p₀) :=
  vadd_vsub _ _
#align affine_map.line_map_vsub_left AffineMap.line_map_vsub_left

@[simp]
theorem left_vsub_line_map (p₀ p₁ : P1) (c : k) : p₀ -ᵥ lineMap p₀ p₁ c = c • (p₀ -ᵥ p₁) := by
  rw [← neg_vsub_eq_vsub_rev, line_map_vsub_left, ← smul_neg, neg_vsub_eq_vsub_rev]
#align affine_map.left_vsub_line_map AffineMap.left_vsub_line_map

@[simp]
theorem line_map_vsub_right (p₀ p₁ : P1) (c : k) : lineMap p₀ p₁ c -ᵥ p₁ = (1 - c) • (p₀ -ᵥ p₁) :=
  by rw [← line_map_apply_one_sub, line_map_vsub_left]
#align affine_map.line_map_vsub_right AffineMap.line_map_vsub_right

@[simp]
theorem right_vsub_line_map (p₀ p₁ : P1) (c : k) : p₁ -ᵥ lineMap p₀ p₁ c = (1 - c) • (p₁ -ᵥ p₀) :=
  by rw [← line_map_apply_one_sub, left_vsub_line_map]
#align affine_map.right_vsub_line_map AffineMap.right_vsub_line_map

theorem line_map_vadd_line_map (v₁ v₂ : V1) (p₁ p₂ : P1) (c : k) :
    lineMap v₁ v₂ c +ᵥ lineMap p₁ p₂ c = lineMap (v₁ +ᵥ p₁) (v₂ +ᵥ p₂) c :=
  ((fst : V1 × P1 →ᵃ[k] V1) +ᵥ snd).apply_line_map (v₁, p₁) (v₂, p₂) c
#align affine_map.line_map_vadd_line_map AffineMap.line_map_vadd_line_map

theorem line_map_vsub_line_map (p₁ p₂ p₃ p₄ : P1) (c : k) :
    lineMap p₁ p₂ c -ᵥ lineMap p₃ p₄ c = lineMap (p₁ -ᵥ p₃) (p₂ -ᵥ p₄) c :=
  letI-- Why Lean fails to find this instance without a hint?
   : affine_space (V1 × V1) (P1 × P1) := Prod.addTorsor
  ((fst : P1 × P1 →ᵃ[k] P1) -ᵥ (snd : P1 × P1 →ᵃ[k] P1)).apply_line_map (_, _) (_, _) c
#align affine_map.line_map_vsub_line_map AffineMap.line_map_vsub_line_map

/-- Decomposition of an affine map in the special case when the point space and vector space
are the same. -/
theorem decomp (f : V1 →ᵃ[k] V2) : (f : V1 → V2) = f.linear + fun z => f 0 :=
  by
  ext x
  calc
    f x = f.linear x +ᵥ f 0 := by simp [← f.map_vadd]
    _ = (f.linear.to_fun + fun z : V1 => f 0) x := by simp
    
#align affine_map.decomp AffineMap.decomp

/-- Decomposition of an affine map in the special case when the point space and vector space
are the same. -/
theorem decomp' (f : V1 →ᵃ[k] V2) : (f.linear : V1 → V2) = f - fun z => f 0 := by
  rw [decomp] <;> simp only [LinearMap.map_zero, Pi.add_apply, add_sub_cancel, zero_add]
#align affine_map.decomp' AffineMap.decomp'

omit V1

theorem image_interval {k : Type _} [LinearOrderedField k] (f : k →ᵃ[k] k) (a b : k) :
    f '' Set.interval a b = Set.interval (f a) (f b) :=
  by
  have : ⇑f = (fun x => x + f 0) ∘ fun x => x * (f 1 - f 0) :=
    by
    ext x
    change f x = x • (f 1 -ᵥ f 0) +ᵥ f 0
    rw [← f.linear_map_vsub, ← f.linear.map_smul, ← f.map_vadd]
    simp only [vsub_eq_sub, add_zero, mul_one, vadd_eq_add, sub_zero, smul_eq_mul]
  rw [this, Set.image_comp]
  simp only [Set.image_add_const_interval, Set.image_mul_const_interval]
#align affine_map.image_interval AffineMap.image_interval

section

variable {ι : Type _} {V : ∀ i : ι, Type _} {P : ∀ i : ι, Type _} [∀ i, AddCommGroup (V i)]
  [∀ i, Module k (V i)] [∀ i, AddTorsor (V i) (P i)]

include V

/-- Evaluation at a point as an affine map. -/
def proj (i : ι) : (∀ i : ι, P i) →ᵃ[k] P i
    where
  toFun f := f i
  linear := @LinearMap.proj k ι _ V _ _ i
  map_vadd' p v := rfl
#align affine_map.proj AffineMap.proj

@[simp]
theorem proj_apply (i : ι) (f : ∀ i, P i) : @proj k _ ι V P _ _ _ i f = f i :=
  rfl
#align affine_map.proj_apply AffineMap.proj_apply

@[simp]
theorem proj_linear (i : ι) : (@proj k _ ι V P _ _ _ i).linear = @LinearMap.proj k ι _ V _ _ i :=
  rfl
#align affine_map.proj_linear AffineMap.proj_linear

theorem pi_line_map_apply (f g : ∀ i, P i) (c : k) (i : ι) :
    lineMap f g c i = lineMap (f i) (g i) c :=
  (proj i : (∀ i, P i) →ᵃ[k] P i).apply_line_map f g c
#align affine_map.pi_line_map_apply AffineMap.pi_line_map_apply

end

end AffineMap

namespace AffineMap

variable {R k V1 P1 V2 : Type _}

section Ring

variable [Ring k] [AddCommGroup V1] [affine_space V1 P1] [AddCommGroup V2]

variable [Module k V1] [Module k V2]

include V1

section DistribMulAction

variable [Monoid R] [DistribMulAction R V2] [SMulCommClass k R V2]

/-- The space of affine maps to a module inherits an `R`-action from the action on its codomain. -/
instance : DistribMulAction R (P1 →ᵃ[k] V2)
    where
  smul_add c f g := ext fun p => smul_add _ _ _
  smul_zero c := ext fun p => smul_zero _

end DistribMulAction

section Module

variable [Semiring R] [Module R V2] [SMulCommClass k R V2]

/-- The space of affine maps taking values in an `R`-module is an `R`-module. -/
instance : Module R (P1 →ᵃ[k] V2) :=
  { AffineMap.distribMulAction with
    smul := (· • ·)
    add_smul := fun c₁ c₂ f => ext fun p => add_smul _ _ _
    zero_smul := fun f => ext fun p => zero_smul _ _ }

variable (R)

/-- The space of affine maps between two modules is linearly equivalent to the product of the
domain with the space of linear maps, by taking the value of the affine map at `(0 : V1)` and the
linear part.

See note [bundled maps over different rings]-/
@[simps]
def toConstProdLinearMap : (V1 →ᵃ[k] V2) ≃ₗ[R] V2 × (V1 →ₗ[k] V2)
    where
  toFun f := ⟨f 0, f.linear⟩
  invFun p := p.2.toAffineMap + const k V1 p.1
  left_inv f := by
    ext
    rw [f.decomp]
    simp
  right_inv := by
    rintro ⟨v, f⟩
    ext <;> simp
  map_add' := by simp
  map_smul' := by simp
#align affine_map.to_const_prod_linear_map AffineMap.toConstProdLinearMap

end Module

end Ring

section CommRing

variable [CommRing k] [AddCommGroup V1] [affine_space V1 P1] [AddCommGroup V2]

variable [Module k V1] [Module k V2]

include V1

/-- `homothety c r` is the homothety (also known as dilation) about `c` with scale factor `r`. -/
def homothety (c : P1) (r : k) : P1 →ᵃ[k] P1 :=
  r • (id k P1 -ᵥ const k P1 c) +ᵥ const k P1 c
#align affine_map.homothety AffineMap.homothety

theorem homothety_def (c : P1) (r : k) :
    homothety c r = r • (id k P1 -ᵥ const k P1 c) +ᵥ const k P1 c :=
  rfl
#align affine_map.homothety_def AffineMap.homothety_def

theorem homothety_apply (c : P1) (r : k) (p : P1) : homothety c r p = r • (p -ᵥ c : V1) +ᵥ c :=
  rfl
#align affine_map.homothety_apply AffineMap.homothety_apply

theorem homothety_eq_line_map (c : P1) (r : k) (p : P1) : homothety c r p = lineMap c p r :=
  rfl
#align affine_map.homothety_eq_line_map AffineMap.homothety_eq_line_map

@[simp]
theorem homothety_one (c : P1) : homothety c (1 : k) = id k P1 :=
  by
  ext p
  simp [homothety_apply]
#align affine_map.homothety_one AffineMap.homothety_one

@[simp]
theorem homothety_apply_same (c : P1) (r : k) : homothety c r c = c :=
  line_map_same_apply c r
#align affine_map.homothety_apply_same AffineMap.homothety_apply_same

theorem homothety_mul_apply (c : P1) (r₁ r₂ : k) (p : P1) :
    homothety c (r₁ * r₂) p = homothety c r₁ (homothety c r₂ p) := by
  simp [homothety_apply, mul_smul]
#align affine_map.homothety_mul_apply AffineMap.homothety_mul_apply

theorem homothety_mul (c : P1) (r₁ r₂ : k) :
    homothety c (r₁ * r₂) = (homothety c r₁).comp (homothety c r₂) :=
  ext <| homothety_mul_apply c r₁ r₂
#align affine_map.homothety_mul AffineMap.homothety_mul

@[simp]
theorem homothety_zero (c : P1) : homothety c (0 : k) = const k P1 c :=
  by
  ext p
  simp [homothety_apply]
#align affine_map.homothety_zero AffineMap.homothety_zero

@[simp]
theorem homothety_add (c : P1) (r₁ r₂ : k) :
    homothety c (r₁ + r₂) = r₁ • (id k P1 -ᵥ const k P1 c) +ᵥ homothety c r₂ := by
  simp only [homothety_def, add_smul, vadd_vadd]
#align affine_map.homothety_add AffineMap.homothety_add

/-- `homothety` as a multiplicative monoid homomorphism. -/
def homothetyHom (c : P1) : k →* P1 →ᵃ[k] P1 :=
  ⟨homothety c, homothety_one c, homothety_mul c⟩
#align affine_map.homothety_hom AffineMap.homothetyHom

@[simp]
theorem coe_homothety_hom (c : P1) : ⇑(homothetyHom c : k →* _) = homothety c :=
  rfl
#align affine_map.coe_homothety_hom AffineMap.coe_homothety_hom

/-- `homothety` as an affine map. -/
def homothetyAffine (c : P1) : k →ᵃ[k] P1 →ᵃ[k] P1 :=
  ⟨homothety c, (LinearMap.lsmul k _).flip (id k P1 -ᵥ const k P1 c),
    Function.swap (homothety_add c)⟩
#align affine_map.homothety_affine AffineMap.homothetyAffine

@[simp]
theorem coe_homothety_affine (c : P1) : ⇑(homothetyAffine c : k →ᵃ[k] _) = homothety c :=
  rfl
#align affine_map.coe_homothety_affine AffineMap.coe_homothety_affine

end CommRing

end AffineMap

section

variable {𝕜 E F : Type _} [Ring 𝕜] [AddCommGroup E] [AddCommGroup F] [Module 𝕜 E] [Module 𝕜 F]

/-- Applying an affine map to an affine combination of two points yields an affine combination of
the images. -/
theorem Convex.combo_affine_apply {x y : E} {a b : 𝕜} {f : E →ᵃ[𝕜] F} (h : a + b = 1) :
    f (a • x + b • y) = a • f x + b • f y :=
  by
  simp only [Convex.combo_eq_smul_sub_add h, ← vsub_eq_sub]
  exact f.apply_line_map _ _ _
#align convex.combo_affine_apply Convex.combo_affine_apply

end

