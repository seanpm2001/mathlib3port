/-
Copyright (c) 2021 Shing Tak Lam. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shing Tak Lam

! This file was ported from Lean 3 source module topology.homotopy.basic
! leanprover-community/mathlib commit 10bf4f825ad729c5653adc039dafa3622e7f93c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.Order.ProjIcc
import Mathbin.Topology.ContinuousFunction.Ordered
import Mathbin.Topology.CompactOpen
import Mathbin.Topology.UnitInterval

/-!
# Homotopy between functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we define a homotopy between two functions `f₀` and `f₁`. First we define
`continuous_map.homotopy` between the two functions, with no restrictions on the intermediate
maps. Then, as in the formalisation in HOL-Analysis, we define
`continuous_map.homotopy_with f₀ f₁ P`, for homotopies between `f₀` and `f₁`, where the
intermediate maps satisfy the predicate `P`. Finally, we define
`continuous_map.homotopy_rel f₀ f₁ S`, for homotopies between `f₀` and `f₁` which are fixed
on `S`.

## Definitions

* `continuous_map.homotopy f₀ f₁` is the type of homotopies between `f₀` and `f₁`.
* `continuous_map.homotopy_with f₀ f₁ P` is the type of homotopies between `f₀` and `f₁`, where
  the intermediate maps satisfy the predicate `P`.
* `continuous_map.homotopy_rel f₀ f₁ S` is the type of homotopies between `f₀` and `f₁` which
  are fixed on `S`.

For each of the above, we have

* `refl f`, which is the constant homotopy from `f` to `f`.
* `symm F`, which reverses the homotopy `F`. For example, if `F : continuous_map.homotopy f₀ f₁`,
  then `F.symm : continuous_map.homotopy f₁ f₀`.
* `trans F G`, which concatenates the homotopies `F` and `G`. For example, if
  `F : continuous_map.homotopy f₀ f₁` and `G : continuous_map.homotopy f₁ f₂`, then
  `F.trans G : continuous_map.homotopy f₀ f₂`.

We also define the relations

* `continuous_map.homotopic f₀ f₁` is defined to be `nonempty (continuous_map.homotopy f₀ f₁)`
* `continuous_map.homotopic_with f₀ f₁ P` is defined to be
  `nonempty (continuous_map.homotopy_with f₀ f₁ P)`
* `continuous_map.homotopic_rel f₀ f₁ P` is defined to be
  `nonempty (continuous_map.homotopy_rel f₀ f₁ P)`

and for `continuous_map.homotopic` and `continuous_map.homotopic_rel`, we also define the
`setoid` and `quotient` in `C(X, Y)` by these relations.

## References

- [HOL-Analysis formalisation](https://isabelle.in.tum.de/library/HOL/HOL-Analysis/Homotopy.html)
-/


noncomputable section

universe u v w

variable {F : Type _} {X : Type u} {Y : Type v} {Z : Type w}

variable [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z]

open scoped unitInterval

namespace ContinuousMap

#print ContinuousMap.Homotopy /-
/-- `continuous_map.homotopy f₀ f₁` is the type of homotopies from `f₀` to `f₁`.

When possible, instead of parametrizing results over `(f : homotopy f₀ f₁)`,
you should parametrize over `{F : Type*} [homotopy_like F f₀ f₁] (f : F)`.

When you extend this structure, make sure to extend `continuous_map.homotopy_like`. -/
structure Homotopy (f₀ f₁ : C(X, Y)) extends C(I × X, Y) where
  map_zero_left' : ∀ x, to_fun (0, x) = f₀ x
  map_one_left' : ∀ x, to_fun (1, x) = f₁ x
#align continuous_map.homotopy ContinuousMap.Homotopy
-/

section

#print ContinuousMap.HomotopyLike /-
/-- `continuous_map.homotopy_like F f₀ f₁` states that `F` is a type of homotopies between `f₀` and
`f₁`.

You should extend this class when you extend `continuous_map.homotopy`. -/
class HomotopyLike (F : Type _) (f₀ f₁ : outParam <| C(X, Y)) extends
    ContinuousMapClass F (I × X) Y where
  map_zero_left (f : F) : ∀ x, f (0, x) = f₀ x
  map_one_left (f : F) : ∀ x, f (1, x) = f₁ x
#align continuous_map.homotopy_like ContinuousMap.HomotopyLike
-/

end

-- `f₀` and `f₁` are `out_param` so this is not dangerous
attribute [nolint dangerous_instance] homotopy_like.to_continuous_map_class

namespace Homotopy

section

variable {f₀ f₁ : C(X, Y)}

instance : HomotopyLike (Homotopy f₀ f₁) f₀ f₁
    where
  coe f := f.toFun
  coe_injective' f g h := by obtain ⟨⟨_, _⟩, _⟩ := f; obtain ⟨⟨_, _⟩, _⟩ := g; congr
  map_continuous f := f.continuous_toFun
  map_zero_left f := f.map_zero_left'
  map_one_left f := f.map_one_left'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (Homotopy f₀ f₁) fun _ => I × X → Y :=
  FunLike.hasCoeToFun

#print ContinuousMap.Homotopy.ext /-
@[ext]
theorem ext {F G : Homotopy f₀ f₁} (h : ∀ x, F x = G x) : F = G :=
  FunLike.ext _ _ h
#align continuous_map.homotopy.ext ContinuousMap.Homotopy.ext
-/

#print ContinuousMap.Homotopy.Simps.apply /-
/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
because it is a composition of multiple projections. -/
def Simps.apply (F : Homotopy f₀ f₁) : I × X → Y :=
  F
#align continuous_map.homotopy.simps.apply ContinuousMap.Homotopy.Simps.apply
-/

initialize_simps_projections Homotopy (to_continuous_map_to_fun → apply, -toContinuousMap)

#print ContinuousMap.Homotopy.continuous /-
/-- Deprecated. Use `map_continuous` instead. -/
protected theorem continuous (F : Homotopy f₀ f₁) : Continuous F :=
  F.continuous_toFun
#align continuous_map.homotopy.continuous ContinuousMap.Homotopy.continuous
-/

#print ContinuousMap.Homotopy.apply_zero /-
@[simp]
theorem apply_zero (F : Homotopy f₀ f₁) (x : X) : F (0, x) = f₀ x :=
  F.map_zero_left' x
#align continuous_map.homotopy.apply_zero ContinuousMap.Homotopy.apply_zero
-/

#print ContinuousMap.Homotopy.apply_one /-
@[simp]
theorem apply_one (F : Homotopy f₀ f₁) (x : X) : F (1, x) = f₁ x :=
  F.map_one_left' x
#align continuous_map.homotopy.apply_one ContinuousMap.Homotopy.apply_one
-/

#print ContinuousMap.Homotopy.coe_toContinuousMap /-
@[simp]
theorem coe_toContinuousMap (F : Homotopy f₀ f₁) : ⇑F.toContinuousMap = F :=
  rfl
#align continuous_map.homotopy.coe_to_continuous_map ContinuousMap.Homotopy.coe_toContinuousMap
-/

#print ContinuousMap.Homotopy.curry /-
/-- Currying a homotopy to a continuous function fron `I` to `C(X, Y)`.
-/
def curry (F : Homotopy f₀ f₁) : C(I, C(X, Y)) :=
  F.toContinuousMap.curry
#align continuous_map.homotopy.curry ContinuousMap.Homotopy.curry
-/

#print ContinuousMap.Homotopy.curry_apply /-
@[simp]
theorem curry_apply (F : Homotopy f₀ f₁) (t : I) (x : X) : F.curry t x = F (t, x) :=
  rfl
#align continuous_map.homotopy.curry_apply ContinuousMap.Homotopy.curry_apply
-/

#print ContinuousMap.Homotopy.extend /-
/-- Continuously extending a curried homotopy to a function from `ℝ` to `C(X, Y)`.
-/
def extend (F : Homotopy f₀ f₁) : C(ℝ, C(X, Y)) :=
  F.curry.IccExtend zero_le_one
#align continuous_map.homotopy.extend ContinuousMap.Homotopy.extend
-/

#print ContinuousMap.Homotopy.extend_apply_of_le_zero /-
theorem extend_apply_of_le_zero (F : Homotopy f₀ f₁) {t : ℝ} (ht : t ≤ 0) (x : X) :
    F.extend t x = f₀ x := by
  rw [← F.apply_zero]
  exact ContinuousMap.congr_fun (Set.IccExtend_of_le_left (zero_le_one' ℝ) F.curry ht) x
#align continuous_map.homotopy.extend_apply_of_le_zero ContinuousMap.Homotopy.extend_apply_of_le_zero
-/

#print ContinuousMap.Homotopy.extend_apply_of_one_le /-
theorem extend_apply_of_one_le (F : Homotopy f₀ f₁) {t : ℝ} (ht : 1 ≤ t) (x : X) :
    F.extend t x = f₁ x := by
  rw [← F.apply_one]
  exact ContinuousMap.congr_fun (Set.IccExtend_of_right_le (zero_le_one' ℝ) F.curry ht) x
#align continuous_map.homotopy.extend_apply_of_one_le ContinuousMap.Homotopy.extend_apply_of_one_le
-/

#print ContinuousMap.Homotopy.extend_apply_coe /-
@[simp]
theorem extend_apply_coe (F : Homotopy f₀ f₁) (t : I) (x : X) : F.extend t x = F (t, x) :=
  ContinuousMap.congr_fun (Set.IccExtend_val (zero_le_one' ℝ) F.curry t) x
#align continuous_map.homotopy.extend_apply_coe ContinuousMap.Homotopy.extend_apply_coe
-/

#print ContinuousMap.Homotopy.extend_apply_of_mem_I /-
@[simp]
theorem extend_apply_of_mem_I (F : Homotopy f₀ f₁) {t : ℝ} (ht : t ∈ I) (x : X) :
    F.extend t x = F (⟨t, ht⟩, x) :=
  ContinuousMap.congr_fun (Set.IccExtend_of_mem (zero_le_one' ℝ) F.curry ht) x
#align continuous_map.homotopy.extend_apply_of_mem_I ContinuousMap.Homotopy.extend_apply_of_mem_I
-/

#print ContinuousMap.Homotopy.congr_fun /-
theorem congr_fun {F G : Homotopy f₀ f₁} (h : F = G) (x : I × X) : F x = G x :=
  ContinuousMap.congr_fun (congr_arg _ h) x
#align continuous_map.homotopy.congr_fun ContinuousMap.Homotopy.congr_fun
-/

#print ContinuousMap.Homotopy.congr_arg /-
theorem congr_arg (F : Homotopy f₀ f₁) {x y : I × X} (h : x = y) : F x = F y :=
  F.toContinuousMap.congr_arg h
#align continuous_map.homotopy.congr_arg ContinuousMap.Homotopy.congr_arg
-/

end

#print ContinuousMap.Homotopy.refl /-
/-- Given a continuous function `f`, we can define a `homotopy f f` by `F (t, x) = f x`
-/
@[simps]
def refl (f : C(X, Y)) : Homotopy f f where
  toFun x := f x.2
  map_zero_left' _ := rfl
  map_one_left' _ := rfl
#align continuous_map.homotopy.refl ContinuousMap.Homotopy.refl
-/

instance : Inhabited (Homotopy (ContinuousMap.id X) (ContinuousMap.id X)) :=
  ⟨Homotopy.refl _⟩

#print ContinuousMap.Homotopy.symm /-
/-- Given a `homotopy f₀ f₁`, we can define a `homotopy f₁ f₀` by reversing the homotopy.
-/
@[simps]
def symm {f₀ f₁ : C(X, Y)} (F : Homotopy f₀ f₁) : Homotopy f₁ f₀
    where
  toFun x := F (σ x.1, x.2)
  map_zero_left' := by norm_num
  map_one_left' := by norm_num
#align continuous_map.homotopy.symm ContinuousMap.Homotopy.symm
-/

#print ContinuousMap.Homotopy.symm_symm /-
@[simp]
theorem symm_symm {f₀ f₁ : C(X, Y)} (F : Homotopy f₀ f₁) : F.symm.symm = F := by ext; simp
#align continuous_map.homotopy.symm_symm ContinuousMap.Homotopy.symm_symm
-/

#print ContinuousMap.Homotopy.trans /-
/--
Given `homotopy f₀ f₁` and `homotopy f₁ f₂`, we can define a `homotopy f₀ f₂` by putting the first
homotopy on `[0, 1/2]` and the second on `[1/2, 1]`.
-/
def trans {f₀ f₁ f₂ : C(X, Y)} (F : Homotopy f₀ f₁) (G : Homotopy f₁ f₂) : Homotopy f₀ f₂
    where
  toFun x := if (x.1 : ℝ) ≤ 1 / 2 then F.extend (2 * x.1) x.2 else G.extend (2 * x.1 - 1) x.2
  continuous_toFun :=
    by
    refine'
      continuous_if_le (continuous_induced_dom.comp continuous_fst) continuous_const
        (F.continuous.comp (by continuity)).ContinuousOn
        (G.continuous.comp (by continuity)).ContinuousOn _
    rintro x hx
    norm_num [hx]
  map_zero_left' x := by norm_num
  map_one_left' x := by norm_num
#align continuous_map.homotopy.trans ContinuousMap.Homotopy.trans
-/

#print ContinuousMap.Homotopy.trans_apply /-
theorem trans_apply {f₀ f₁ f₂ : C(X, Y)} (F : Homotopy f₀ f₁) (G : Homotopy f₁ f₂) (x : I × X) :
    (F.trans G) x =
      if h : (x.1 : ℝ) ≤ 1 / 2 then
        F (⟨2 * x.1, (unitInterval.mul_pos_mem_iff zero_lt_two).2 ⟨x.1.2.1, h⟩⟩, x.2)
      else
        G (⟨2 * x.1 - 1, unitInterval.two_mul_sub_one_mem_iff.2 ⟨(not_le.1 h).le, x.1.2.2⟩⟩, x.2) :=
  show ite _ _ _ = _ by
    split_ifs <;> · rw [extend, ContinuousMap.coe_IccExtend, Set.IccExtend_of_mem]; rfl
#align continuous_map.homotopy.trans_apply ContinuousMap.Homotopy.trans_apply
-/

#print ContinuousMap.Homotopy.symm_trans /-
theorem symm_trans {f₀ f₁ f₂ : C(X, Y)} (F : Homotopy f₀ f₁) (G : Homotopy f₁ f₂) :
    (F.trans G).symm = G.symm.trans F.symm := by
  ext x
  simp only [symm_apply, trans_apply]
  split_ifs with h₁ h₂
  · change (x.1 : ℝ) ≤ _ at h₂ 
    change (1 : ℝ) - x.1 ≤ _ at h₁ 
    have ht : (x.1 : ℝ) = 1 / 2 := by linarith
    norm_num [ht]
  · congr 2
    apply Subtype.ext
    simp only [unitInterval.coe_symm_eq, Subtype.coe_mk]
    linarith
  · congr 2
    apply Subtype.ext
    simp only [unitInterval.coe_symm_eq, Subtype.coe_mk]
    linarith
  · change ¬(x.1 : ℝ) ≤ _ at h 
    change ¬(1 : ℝ) - x.1 ≤ _ at h₁ 
    exfalso; linarith
#align continuous_map.homotopy.symm_trans ContinuousMap.Homotopy.symm_trans
-/

#print ContinuousMap.Homotopy.cast /-
/-- Casting a `homotopy f₀ f₁` to a `homotopy g₀ g₁` where `f₀ = g₀` and `f₁ = g₁`.
-/
@[simps]
def cast {f₀ f₁ g₀ g₁ : C(X, Y)} (F : Homotopy f₀ f₁) (h₀ : f₀ = g₀) (h₁ : f₁ = g₁) : Homotopy g₀ g₁
    where
  toFun := F
  map_zero_left' := by simp [← h₀]
  map_one_left' := by simp [← h₁]
#align continuous_map.homotopy.cast ContinuousMap.Homotopy.cast
-/

#print ContinuousMap.Homotopy.hcomp /-
/-- If we have a `homotopy f₀ f₁` and a `homotopy g₀ g₁`, then we can compose them and get a
`homotopy (g₀.comp f₀) (g₁.comp f₁)`.
-/
@[simps]
def hcomp {f₀ f₁ : C(X, Y)} {g₀ g₁ : C(Y, Z)} (F : Homotopy f₀ f₁) (G : Homotopy g₀ g₁) :
    Homotopy (g₀.comp f₀) (g₁.comp f₁)
    where
  toFun x := G (x.1, F x)
  map_zero_left' := by simp
  map_one_left' := by simp
#align continuous_map.homotopy.hcomp ContinuousMap.Homotopy.hcomp
-/

end Homotopy

#print ContinuousMap.Homotopic /-
/-- Given continuous maps `f₀` and `f₁`, we say `f₀` and `f₁` are homotopic if there exists a
`homotopy f₀ f₁`.
-/
def Homotopic (f₀ f₁ : C(X, Y)) : Prop :=
  Nonempty (Homotopy f₀ f₁)
#align continuous_map.homotopic ContinuousMap.Homotopic
-/

namespace homotopic

#print ContinuousMap.Homotopic.refl /-
@[refl]
theorem refl (f : C(X, Y)) : Homotopic f f :=
  ⟨Homotopy.refl f⟩
#align continuous_map.homotopic.refl ContinuousMap.Homotopic.refl
-/

#print ContinuousMap.Homotopic.symm /-
@[symm]
theorem symm ⦃f g : C(X, Y)⦄ (h : Homotopic f g) : Homotopic g f :=
  h.map Homotopy.symm
#align continuous_map.homotopic.symm ContinuousMap.Homotopic.symm
-/

#print ContinuousMap.Homotopic.trans /-
@[trans]
theorem trans ⦃f g h : C(X, Y)⦄ (h₀ : Homotopic f g) (h₁ : Homotopic g h) : Homotopic f h :=
  h₀.map2 Homotopy.trans h₁
#align continuous_map.homotopic.trans ContinuousMap.Homotopic.trans
-/

#print ContinuousMap.Homotopic.hcomp /-
theorem hcomp {f₀ f₁ : C(X, Y)} {g₀ g₁ : C(Y, Z)} (h₀ : Homotopic f₀ f₁) (h₁ : Homotopic g₀ g₁) :
    Homotopic (g₀.comp f₀) (g₁.comp f₁) :=
  h₀.map2 Homotopy.hcomp h₁
#align continuous_map.homotopic.hcomp ContinuousMap.Homotopic.hcomp
-/

#print ContinuousMap.Homotopic.equivalence /-
theorem equivalence : Equivalence (@Homotopic X Y _ _) :=
  ⟨refl, symm, trans⟩
#align continuous_map.homotopic.equivalence ContinuousMap.Homotopic.equivalence
-/

end homotopic

#print ContinuousMap.HomotopyWith /-
/--
The type of homotopies between `f₀ f₁ : C(X, Y)`, where the intermediate maps satisfy the predicate
`P : C(X, Y) → Prop`
-/
structure HomotopyWith (f₀ f₁ : C(X, Y)) (P : C(X, Y) → Prop) extends Homotopy f₀ f₁ where
  prop' :
    ∀ t,
      P
        ⟨fun x => to_fun (t, x),
          Continuous.comp continuous_to_fun (continuous_const.prod_mk continuous_id')⟩
#align continuous_map.homotopy_with ContinuousMap.HomotopyWith
-/

namespace HomotopyWith

section

variable {f₀ f₁ : C(X, Y)} {P : C(X, Y) → Prop}

instance : CoeFun (HomotopyWith f₀ f₁ P) fun _ => I × X → Y :=
  ⟨fun F => F.toFun⟩

#print ContinuousMap.HomotopyWith.coeFn_injective /-
theorem coeFn_injective : @Function.Injective (HomotopyWith f₀ f₁ P) (I × X → Y) coeFn :=
  by
  rintro ⟨⟨⟨F, _⟩, _⟩, _⟩ ⟨⟨⟨G, _⟩, _⟩, _⟩ h
  congr 3
#align continuous_map.homotopy_with.coe_fn_injective ContinuousMap.HomotopyWith.coeFn_injective
-/

#print ContinuousMap.HomotopyWith.ext /-
@[ext]
theorem ext {F G : HomotopyWith f₀ f₁ P} (h : ∀ x, F x = G x) : F = G :=
  coeFn_injective <| funext h
#align continuous_map.homotopy_with.ext ContinuousMap.HomotopyWith.ext
-/

#print ContinuousMap.HomotopyWith.Simps.apply /-
/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
because it is a composition of multiple projections. -/
def Simps.apply (F : HomotopyWith f₀ f₁ P) : I × X → Y :=
  F
#align continuous_map.homotopy_with.simps.apply ContinuousMap.HomotopyWith.Simps.apply
-/

initialize_simps_projections HomotopyWith (to_homotopy_to_continuous_map_to_fun → apply,
  -to_homotopy_to_continuous_map)

#print ContinuousMap.HomotopyWith.continuous /-
@[continuity]
protected theorem continuous (F : HomotopyWith f₀ f₁ P) : Continuous F :=
  F.continuous_toFun
#align continuous_map.homotopy_with.continuous ContinuousMap.HomotopyWith.continuous
-/

#print ContinuousMap.HomotopyWith.apply_zero /-
@[simp]
theorem apply_zero (F : HomotopyWith f₀ f₁ P) (x : X) : F (0, x) = f₀ x :=
  F.map_zero_left' x
#align continuous_map.homotopy_with.apply_zero ContinuousMap.HomotopyWith.apply_zero
-/

#print ContinuousMap.HomotopyWith.apply_one /-
@[simp]
theorem apply_one (F : HomotopyWith f₀ f₁ P) (x : X) : F (1, x) = f₁ x :=
  F.map_one_left' x
#align continuous_map.homotopy_with.apply_one ContinuousMap.HomotopyWith.apply_one
-/

#print ContinuousMap.HomotopyWith.coe_toContinuousMap /-
@[simp]
theorem coe_toContinuousMap (F : HomotopyWith f₀ f₁ P) : ⇑F.toContinuousMap = F :=
  rfl
#align continuous_map.homotopy_with.coe_to_continuous_map ContinuousMap.HomotopyWith.coe_toContinuousMap
-/

#print ContinuousMap.HomotopyWith.coe_toHomotopy /-
@[simp]
theorem coe_toHomotopy (F : HomotopyWith f₀ f₁ P) : ⇑F.toHomotopy = F :=
  rfl
#align continuous_map.homotopy_with.coe_to_homotopy ContinuousMap.HomotopyWith.coe_toHomotopy
-/

#print ContinuousMap.HomotopyWith.prop /-
theorem prop (F : HomotopyWith f₀ f₁ P) (t : I) : P (F.toHomotopy.curry t) :=
  F.prop' t
#align continuous_map.homotopy_with.prop ContinuousMap.HomotopyWith.prop
-/

#print ContinuousMap.HomotopyWith.extendProp /-
theorem extendProp (F : HomotopyWith f₀ f₁ P) (t : ℝ) : P (F.toHomotopy.extend t) :=
  by
  by_cases ht₀ : 0 ≤ t
  · by_cases ht₁ : t ≤ 1
    · convert F.prop ⟨t, ht₀, ht₁⟩
      ext
      rw [F.to_homotopy.extend_apply_of_mem_I ⟨ht₀, ht₁⟩, F.to_homotopy.curry_apply]
    · convert F.prop 1
      ext
      rw [F.to_homotopy.extend_apply_of_one_le (le_of_not_le ht₁), F.to_homotopy.curry_apply,
        F.to_homotopy.apply_one]
  · convert F.prop 0
    ext
    rw [F.to_homotopy.extend_apply_of_le_zero (le_of_not_le ht₀), F.to_homotopy.curry_apply,
      F.to_homotopy.apply_zero]
#align continuous_map.homotopy_with.extend_prop ContinuousMap.HomotopyWith.extendProp
-/

end

variable {P : C(X, Y) → Prop}

#print ContinuousMap.HomotopyWith.refl /-
/-- Given a continuous function `f`, and a proof `h : P f`, we can define a `homotopy_with f f P` by
`F (t, x) = f x`
-/
@[simps]
def refl (f : C(X, Y)) (hf : P f) : HomotopyWith f f P :=
  { Homotopy.refl f with prop' := fun t => by convert hf; cases f; rfl }
#align continuous_map.homotopy_with.refl ContinuousMap.HomotopyWith.refl
-/

instance : Inhabited (HomotopyWith (ContinuousMap.id X) (ContinuousMap.id X) fun f => True) :=
  ⟨HomotopyWith.refl _ trivial⟩

#print ContinuousMap.HomotopyWith.symm /-
/--
Given a `homotopy_with f₀ f₁ P`, we can define a `homotopy_with f₁ f₀ P` by reversing the homotopy.
-/
@[simps]
def symm {f₀ f₁ : C(X, Y)} (F : HomotopyWith f₀ f₁ P) : HomotopyWith f₁ f₀ P :=
  { F.toHomotopy.symm with prop' := fun t => by simpa using F.prop (σ t) }
#align continuous_map.homotopy_with.symm ContinuousMap.HomotopyWith.symm
-/

#print ContinuousMap.HomotopyWith.symm_symm /-
@[simp]
theorem symm_symm {f₀ f₁ : C(X, Y)} (F : HomotopyWith f₀ f₁ P) : F.symm.symm = F :=
  ext <| Homotopy.congr_fun <| Homotopy.symm_symm _
#align continuous_map.homotopy_with.symm_symm ContinuousMap.HomotopyWith.symm_symm
-/

#print ContinuousMap.HomotopyWith.trans /-
/--
Given `homotopy_with f₀ f₁ P` and `homotopy_with f₁ f₂ P`, we can define a `homotopy_with f₀ f₂ P`
by putting the first homotopy on `[0, 1/2]` and the second on `[1/2, 1]`.
-/
def trans {f₀ f₁ f₂ : C(X, Y)} (F : HomotopyWith f₀ f₁ P) (G : HomotopyWith f₁ f₂ P) :
    HomotopyWith f₀ f₂ P :=
  { F.toHomotopy.trans G.toHomotopy with
    prop' := fun t => by
      simp only [Homotopy.trans]
      change P ⟨fun _ => ite ((t : ℝ) ≤ _) _ _, _⟩
      split_ifs
      · exact F.extend_prop _
      · exact G.extend_prop _ }
#align continuous_map.homotopy_with.trans ContinuousMap.HomotopyWith.trans
-/

#print ContinuousMap.HomotopyWith.trans_apply /-
theorem trans_apply {f₀ f₁ f₂ : C(X, Y)} (F : HomotopyWith f₀ f₁ P) (G : HomotopyWith f₁ f₂ P)
    (x : I × X) :
    (F.trans G) x =
      if h : (x.1 : ℝ) ≤ 1 / 2 then
        F (⟨2 * x.1, (unitInterval.mul_pos_mem_iff zero_lt_two).2 ⟨x.1.2.1, h⟩⟩, x.2)
      else
        G (⟨2 * x.1 - 1, unitInterval.two_mul_sub_one_mem_iff.2 ⟨(not_le.1 h).le, x.1.2.2⟩⟩, x.2) :=
  Homotopy.trans_apply _ _ _
#align continuous_map.homotopy_with.trans_apply ContinuousMap.HomotopyWith.trans_apply
-/

#print ContinuousMap.HomotopyWith.symm_trans /-
theorem symm_trans {f₀ f₁ f₂ : C(X, Y)} (F : HomotopyWith f₀ f₁ P) (G : HomotopyWith f₁ f₂ P) :
    (F.trans G).symm = G.symm.trans F.symm :=
  ext <| Homotopy.congr_fun <| Homotopy.symm_trans _ _
#align continuous_map.homotopy_with.symm_trans ContinuousMap.HomotopyWith.symm_trans
-/

#print ContinuousMap.HomotopyWith.cast /-
/-- Casting a `homotopy_with f₀ f₁ P` to a `homotopy_with g₀ g₁ P` where `f₀ = g₀` and `f₁ = g₁`.
-/
@[simps]
def cast {f₀ f₁ g₀ g₁ : C(X, Y)} (F : HomotopyWith f₀ f₁ P) (h₀ : f₀ = g₀) (h₁ : f₁ = g₁) :
    HomotopyWith g₀ g₁ P :=
  { F.toHomotopy.cast h₀ h₁ with prop' := F.Prop }
#align continuous_map.homotopy_with.cast ContinuousMap.HomotopyWith.cast
-/

end HomotopyWith

#print ContinuousMap.HomotopicWith /-
/-- Given continuous maps `f₀` and `f₁`, we say `f₀` and `f₁` are homotopic with respect to the
predicate `P` if there exists a `homotopy_with f₀ f₁ P`.
-/
def HomotopicWith (f₀ f₁ : C(X, Y)) (P : C(X, Y) → Prop) : Prop :=
  Nonempty (HomotopyWith f₀ f₁ P)
#align continuous_map.homotopic_with ContinuousMap.HomotopicWith
-/

namespace HomotopicWith

variable {P : C(X, Y) → Prop}

#print ContinuousMap.HomotopicWith.refl /-
@[refl]
theorem refl (f : C(X, Y)) (hf : P f) : HomotopicWith f f P :=
  ⟨HomotopyWith.refl f hf⟩
#align continuous_map.homotopic_with.refl ContinuousMap.HomotopicWith.refl
-/

#print ContinuousMap.HomotopicWith.symm /-
@[symm]
theorem symm ⦃f g : C(X, Y)⦄ (h : HomotopicWith f g P) : HomotopicWith g f P :=
  ⟨h.some.symm⟩
#align continuous_map.homotopic_with.symm ContinuousMap.HomotopicWith.symm
-/

#print ContinuousMap.HomotopicWith.trans /-
@[trans]
theorem trans ⦃f g h : C(X, Y)⦄ (h₀ : HomotopicWith f g P) (h₁ : HomotopicWith g h P) :
    HomotopicWith f h P :=
  ⟨h₀.some.trans h₁.some⟩
#align continuous_map.homotopic_with.trans ContinuousMap.HomotopicWith.trans
-/

end HomotopicWith

#print ContinuousMap.HomotopyRel /-
/--
A `homotopy_rel f₀ f₁ S` is a homotopy between `f₀` and `f₁` which is fixed on the points in `S`.
-/
abbrev HomotopyRel (f₀ f₁ : C(X, Y)) (S : Set X) :=
  HomotopyWith f₀ f₁ fun f => ∀ x ∈ S, f x = f₀ x ∧ f x = f₁ x
#align continuous_map.homotopy_rel ContinuousMap.HomotopyRel
-/

namespace HomotopyRel

section

variable {f₀ f₁ : C(X, Y)} {S : Set X}

#print ContinuousMap.HomotopyRel.eq_fst /-
theorem eq_fst (F : HomotopyRel f₀ f₁ S) (t : I) {x : X} (hx : x ∈ S) : F (t, x) = f₀ x :=
  (F.Prop t x hx).1
#align continuous_map.homotopy_rel.eq_fst ContinuousMap.HomotopyRel.eq_fst
-/

#print ContinuousMap.HomotopyRel.eq_snd /-
theorem eq_snd (F : HomotopyRel f₀ f₁ S) (t : I) {x : X} (hx : x ∈ S) : F (t, x) = f₁ x :=
  (F.Prop t x hx).2
#align continuous_map.homotopy_rel.eq_snd ContinuousMap.HomotopyRel.eq_snd
-/

#print ContinuousMap.HomotopyRel.fst_eq_snd /-
theorem fst_eq_snd (F : HomotopyRel f₀ f₁ S) {x : X} (hx : x ∈ S) : f₀ x = f₁ x :=
  F.eq_fst 0 hx ▸ F.eq_snd 0 hx
#align continuous_map.homotopy_rel.fst_eq_snd ContinuousMap.HomotopyRel.fst_eq_snd
-/

end

variable {f₀ f₁ f₂ : C(X, Y)} {S : Set X}

#print ContinuousMap.HomotopyRel.refl /-
/-- Given a map `f : C(X, Y)` and a set `S`, we can define a `homotopy_rel f f S` by setting
`F (t, x) = f x` for all `t`. This is defined using `homotopy_with.refl`, but with the proof
filled in.
-/
@[simps]
def refl (f : C(X, Y)) (S : Set X) : HomotopyRel f f S :=
  HomotopyWith.refl f fun x hx => ⟨rfl, rfl⟩
#align continuous_map.homotopy_rel.refl ContinuousMap.HomotopyRel.refl
-/

#print ContinuousMap.HomotopyRel.symm /-
/--
Given a `homotopy_rel f₀ f₁ S`, we can define a `homotopy_rel f₁ f₀ S` by reversing the homotopy.
-/
@[simps]
def symm (F : HomotopyRel f₀ f₁ S) : HomotopyRel f₁ f₀ S :=
  { HomotopyWith.symm F with prop' := fun t x hx => by simp [F.eq_snd _ hx, F.fst_eq_snd hx] }
#align continuous_map.homotopy_rel.symm ContinuousMap.HomotopyRel.symm
-/

#print ContinuousMap.HomotopyRel.symm_symm /-
@[simp]
theorem symm_symm (F : HomotopyRel f₀ f₁ S) : F.symm.symm = F :=
  HomotopyWith.symm_symm F
#align continuous_map.homotopy_rel.symm_symm ContinuousMap.HomotopyRel.symm_symm
-/

#print ContinuousMap.HomotopyRel.trans /-
/-- Given `homotopy_rel f₀ f₁ S` and `homotopy_rel f₁ f₂ S`, we can define a `homotopy_rel f₀ f₂ S`
by putting the first homotopy on `[0, 1/2]` and the second on `[1/2, 1]`.
-/
def trans (F : HomotopyRel f₀ f₁ S) (G : HomotopyRel f₁ f₂ S) : HomotopyRel f₀ f₂ S :=
  { Homotopy.trans F.toHomotopy G.toHomotopy with
    prop' := fun t => by
      intro x hx
      simp only [Homotopy.trans]
      change (⟨fun _ => ite ((t : ℝ) ≤ _) _ _, _⟩ : C(X, Y)) _ = _ ∧ _ = _
      split_ifs
      · simp [(homotopy_with.extend_prop F (2 * t) x hx).1, F.fst_eq_snd hx, G.fst_eq_snd hx]
      · simp [(homotopy_with.extend_prop G (2 * t - 1) x hx).1, F.fst_eq_snd hx, G.fst_eq_snd hx] }
#align continuous_map.homotopy_rel.trans ContinuousMap.HomotopyRel.trans
-/

#print ContinuousMap.HomotopyRel.trans_apply /-
theorem trans_apply (F : HomotopyRel f₀ f₁ S) (G : HomotopyRel f₁ f₂ S) (x : I × X) :
    (F.trans G) x =
      if h : (x.1 : ℝ) ≤ 1 / 2 then
        F (⟨2 * x.1, (unitInterval.mul_pos_mem_iff zero_lt_two).2 ⟨x.1.2.1, h⟩⟩, x.2)
      else
        G (⟨2 * x.1 - 1, unitInterval.two_mul_sub_one_mem_iff.2 ⟨(not_le.1 h).le, x.1.2.2⟩⟩, x.2) :=
  Homotopy.trans_apply _ _ _
#align continuous_map.homotopy_rel.trans_apply ContinuousMap.HomotopyRel.trans_apply
-/

#print ContinuousMap.HomotopyRel.symm_trans /-
theorem symm_trans (F : HomotopyRel f₀ f₁ S) (G : HomotopyRel f₁ f₂ S) :
    (F.trans G).symm = G.symm.trans F.symm :=
  HomotopyWith.ext <| Homotopy.congr_fun <| Homotopy.symm_trans _ _
#align continuous_map.homotopy_rel.symm_trans ContinuousMap.HomotopyRel.symm_trans
-/

#print ContinuousMap.HomotopyRel.cast /-
/-- Casting a `homotopy_rel f₀ f₁ S` to a `homotopy_rel g₀ g₁ S` where `f₀ = g₀` and `f₁ = g₁`.
-/
@[simps]
def cast {f₀ f₁ g₀ g₁ : C(X, Y)} (F : HomotopyRel f₀ f₁ S) (h₀ : f₀ = g₀) (h₁ : f₁ = g₁) :
    HomotopyRel g₀ g₁ S :=
  { Homotopy.cast F.toHomotopy h₀ h₁ with
    prop' := fun t x hx => by simpa [← h₀, ← h₁] using F.prop t x hx }
#align continuous_map.homotopy_rel.cast ContinuousMap.HomotopyRel.cast
-/

end HomotopyRel

#print ContinuousMap.HomotopicRel /-
/-- Given continuous maps `f₀` and `f₁`, we say `f₀` and `f₁` are homotopic relative to a set `S` if
there exists a `homotopy_rel f₀ f₁ S`.
-/
def HomotopicRel (f₀ f₁ : C(X, Y)) (S : Set X) : Prop :=
  Nonempty (HomotopyRel f₀ f₁ S)
#align continuous_map.homotopic_rel ContinuousMap.HomotopicRel
-/

namespace HomotopicRel

variable {S : Set X}

#print ContinuousMap.HomotopicRel.refl /-
@[refl]
theorem refl (f : C(X, Y)) : HomotopicRel f f S :=
  ⟨HomotopyRel.refl f S⟩
#align continuous_map.homotopic_rel.refl ContinuousMap.HomotopicRel.refl
-/

#print ContinuousMap.HomotopicRel.symm /-
@[symm]
theorem symm ⦃f g : C(X, Y)⦄ (h : HomotopicRel f g S) : HomotopicRel g f S :=
  h.map HomotopyRel.symm
#align continuous_map.homotopic_rel.symm ContinuousMap.HomotopicRel.symm
-/

#print ContinuousMap.HomotopicRel.trans /-
@[trans]
theorem trans ⦃f g h : C(X, Y)⦄ (h₀ : HomotopicRel f g S) (h₁ : HomotopicRel g h S) :
    HomotopicRel f h S :=
  h₀.map2 HomotopyRel.trans h₁
#align continuous_map.homotopic_rel.trans ContinuousMap.HomotopicRel.trans
-/

#print ContinuousMap.HomotopicRel.equivalence /-
theorem equivalence : Equivalence fun f g : C(X, Y) => HomotopicRel f g S :=
  ⟨refl, symm, trans⟩
#align continuous_map.homotopic_rel.equivalence ContinuousMap.HomotopicRel.equivalence
-/

end HomotopicRel

end ContinuousMap

