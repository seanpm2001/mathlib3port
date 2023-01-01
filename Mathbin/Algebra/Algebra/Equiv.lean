/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Yury Kudryashov

! This file was ported from Lean 3 source module algebra.algebra.equiv
! leanprover-community/mathlib commit 9aba7801eeecebb61f58a5763c2b6dd1b47dc6ef
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Hom

/-!
# Isomorphisms of `R`-algebras

This file defines bundled isomorphisms of `R`-algebras.

## Main definitions

* `alg_equiv R A B`: the type of `R`-algebra isomorphisms between `A` and `B`.

## Notations

* `A ≃ₐ[R] B` : `R`-algebra equivalence from `A` to `B`.
-/


open BigOperators

universe u v w u₁ v₁

/-- An equivalence of algebras is an equivalence of rings commuting with the actions of scalars. -/
structure AlgEquiv (R : Type u) (A : Type v) (B : Type w) [CommSemiring R] [Semiring A] [Semiring B]
  [Algebra R A] [Algebra R B] extends A ≃ B, A ≃* B, A ≃+ B, A ≃+* B where
  commutes' : ∀ r : R, to_fun (algebraMap R A r) = algebraMap R B r
#align alg_equiv AlgEquiv

attribute [nolint doc_blame] AlgEquiv.toRingEquiv

attribute [nolint doc_blame] AlgEquiv.toEquiv

attribute [nolint doc_blame] AlgEquiv.toAddEquiv

attribute [nolint doc_blame] AlgEquiv.toMulEquiv

-- mathport name: «expr ≃ₐ[ ] »
notation:50 A " ≃ₐ[" R "] " A' => AlgEquiv R A A'

/-- `alg_equiv_class F R A B` states that `F` is a type of algebra structure preserving
  equivalences. You should extend this class when you extend `alg_equiv`. -/
class AlgEquivClass (F : Type _) (R A B : outParam (Type _)) [CommSemiring R] [Semiring A]
  [Semiring B] [Algebra R A] [Algebra R B] extends RingEquivClass F A B where
  commutes : ∀ (f : F) (r : R), f (algebraMap R A r) = algebraMap R B r
#align alg_equiv_class AlgEquivClass

-- `R` becomes a metavariable but that's fine because it's an `out_param`
attribute [nolint dangerous_instance] AlgEquivClass.toRingEquivClass

namespace AlgEquivClass

-- See note [lower instance priority]
instance (priority := 100) toAlgHomClass (F R A B : Type _) [CommSemiring R] [Semiring A]
    [Semiring B] [Algebra R A] [Algebra R B] [h : AlgEquivClass F R A B] : AlgHomClass F R A B :=
  { h with
    coe := coeFn
    coe_injective' := FunLike.coe_injective
    map_zero := map_zero
    map_one := map_one }
#align alg_equiv_class.to_alg_hom_class AlgEquivClass.toAlgHomClass

instance (priority := 100) toLinearEquivClass (F R A B : Type _) [CommSemiring R] [Semiring A]
    [Semiring B] [Algebra R A] [Algebra R B] [h : AlgEquivClass F R A B] :
    LinearEquivClass F R A B :=
  { h with map_smulₛₗ := fun f => map_smulₛₗ f }
#align alg_equiv_class.to_linear_equiv_class AlgEquivClass.toLinearEquivClass

instance (F R A B : Type _) [CommSemiring R] [Semiring A] [Semiring B] [Algebra R A] [Algebra R B]
    [h : AlgEquivClass F R A B] : CoeTC F (A ≃ₐ[R] B)
    where coe f :=
    { (f : A ≃+* B) with
      toFun := f
      invFun := EquivLike.inv f
      commutes' := AlgHomClass.commutes f }

end AlgEquivClass

namespace AlgEquiv

variable {R : Type u} {A₁ : Type v} {A₂ : Type w} {A₃ : Type u₁}

section Semiring

variable [CommSemiring R] [Semiring A₁] [Semiring A₂] [Semiring A₃]

variable [Algebra R A₁] [Algebra R A₂] [Algebra R A₃]

variable (e : A₁ ≃ₐ[R] A₂)

instance : AlgEquivClass (A₁ ≃ₐ[R] A₂) R A₁ A₂
    where
  coe := toFun
  inv := invFun
  coe_injective' f g h₁ h₂ := by
    cases f
    cases g
    congr
  map_add := map_add'
  map_mul := map_mul'
  commutes := commutes'
  left_inv := left_inv
  right_inv := right_inv

/-- Helper instance for when there's too many metavariables to apply
`fun_like.has_coe_to_fun` directly. -/
instance : CoeFun (A₁ ≃ₐ[R] A₂) fun _ => A₁ → A₂ :=
  ⟨AlgEquiv.toFun⟩

@[simp, protected]
theorem coe_coe {F : Type _} [AlgEquivClass F R A₁ A₂] (f : F) : ⇑(f : A₁ ≃ₐ[R] A₂) = f :=
  rfl
#align alg_equiv.coe_coe AlgEquiv.coe_coe

@[ext]
theorem ext {f g : A₁ ≃ₐ[R] A₂} (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align alg_equiv.ext AlgEquiv.ext

protected theorem congr_arg {f : A₁ ≃ₐ[R] A₂} {x x' : A₁} : x = x' → f x = f x' :=
  FunLike.congr_arg f
#align alg_equiv.congr_arg AlgEquiv.congr_arg

protected theorem congr_fun {f g : A₁ ≃ₐ[R] A₂} (h : f = g) (x : A₁) : f x = g x :=
  FunLike.congr_fun h x
#align alg_equiv.congr_fun AlgEquiv.congr_fun

protected theorem ext_iff {f g : A₁ ≃ₐ[R] A₂} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align alg_equiv.ext_iff AlgEquiv.ext_iff

theorem coe_fun_injective : @Function.Injective (A₁ ≃ₐ[R] A₂) (A₁ → A₂) fun e => (e : A₁ → A₂) :=
  FunLike.coe_injective
#align alg_equiv.coe_fun_injective AlgEquiv.coe_fun_injective

instance hasCoeToRingEquiv : Coe (A₁ ≃ₐ[R] A₂) (A₁ ≃+* A₂) :=
  ⟨AlgEquiv.toRingEquiv⟩
#align alg_equiv.has_coe_to_ring_equiv AlgEquiv.hasCoeToRingEquiv

@[simp]
theorem coe_mk {to_fun inv_fun left_inv right_inv map_mul map_add commutes} :
    ⇑(⟨to_fun, inv_fun, left_inv, right_inv, map_mul, map_add, commutes⟩ : A₁ ≃ₐ[R] A₂) = to_fun :=
  rfl
#align alg_equiv.coe_mk AlgEquiv.coe_mk

@[simp]
theorem mk_coe (e : A₁ ≃ₐ[R] A₂) (e' h₁ h₂ h₃ h₄ h₅) :
    (⟨e, e', h₁, h₂, h₃, h₄, h₅⟩ : A₁ ≃ₐ[R] A₂) = e :=
  ext fun _ => rfl
#align alg_equiv.mk_coe AlgEquiv.mk_coe

@[simp]
theorem to_fun_eq_coe (e : A₁ ≃ₐ[R] A₂) : e.toFun = e :=
  rfl
#align alg_equiv.to_fun_eq_coe AlgEquiv.to_fun_eq_coe

@[simp]
theorem to_equiv_eq_coe : e.toEquiv = e :=
  rfl
#align alg_equiv.to_equiv_eq_coe AlgEquiv.to_equiv_eq_coe

@[simp]
theorem to_ring_equiv_eq_coe : e.toRingEquiv = e :=
  rfl
#align alg_equiv.to_ring_equiv_eq_coe AlgEquiv.to_ring_equiv_eq_coe

@[simp, norm_cast]
theorem coe_ring_equiv : ((e : A₁ ≃+* A₂) : A₁ → A₂) = e :=
  rfl
#align alg_equiv.coe_ring_equiv AlgEquiv.coe_ring_equiv

theorem coe_ring_equiv' : (e.toRingEquiv : A₁ → A₂) = e :=
  rfl
#align alg_equiv.coe_ring_equiv' AlgEquiv.coe_ring_equiv'

theorem coe_ring_equiv_injective : Function.Injective (coe : (A₁ ≃ₐ[R] A₂) → A₁ ≃+* A₂) :=
  fun e₁ e₂ h => ext <| RingEquiv.congr_fun h
#align alg_equiv.coe_ring_equiv_injective AlgEquiv.coe_ring_equiv_injective

protected theorem map_add : ∀ x y, e (x + y) = e x + e y :=
  map_add e
#align alg_equiv.map_add AlgEquiv.map_add

protected theorem map_zero : e 0 = 0 :=
  map_zero e
#align alg_equiv.map_zero AlgEquiv.map_zero

protected theorem map_mul : ∀ x y, e (x * y) = e x * e y :=
  map_mul e
#align alg_equiv.map_mul AlgEquiv.map_mul

protected theorem map_one : e 1 = 1 :=
  map_one e
#align alg_equiv.map_one AlgEquiv.map_one

@[simp]
theorem commutes : ∀ r : R, e (algebraMap R A₁ r) = algebraMap R A₂ r :=
  e.commutes'
#align alg_equiv.commutes AlgEquiv.commutes

@[simp]
theorem map_smul (r : R) (x : A₁) : e (r • x) = r • e x := by
  simp only [Algebra.smul_def, map_mul, commutes]
#align alg_equiv.map_smul AlgEquiv.map_smul

theorem map_sum {ι : Type _} (f : ι → A₁) (s : Finset ι) : e (∑ x in s, f x) = ∑ x in s, e (f x) :=
  e.toAddEquiv.map_sum f s
#align alg_equiv.map_sum AlgEquiv.map_sum

theorem map_finsupp_sum {α : Type _} [Zero α] {ι : Type _} (f : ι →₀ α) (g : ι → α → A₁) :
    e (f.Sum g) = f.Sum fun i b => e (g i b) :=
  e.map_sum _ _
#align alg_equiv.map_finsupp_sum AlgEquiv.map_finsupp_sum

/-- Interpret an algebra equivalence as an algebra homomorphism.

This definition is included for symmetry with the other `to_*_hom` projections.
The `simp` normal form is to use the coercion of the `alg_hom_class.has_coe_t` instance. -/
def toAlgHom : A₁ →ₐ[R] A₂ :=
  { e with
    map_one' := e.map_one
    map_zero' := e.map_zero }
#align alg_equiv.to_alg_hom AlgEquiv.toAlgHom

@[simp]
theorem to_alg_hom_eq_coe : e.toAlgHom = e :=
  rfl
#align alg_equiv.to_alg_hom_eq_coe AlgEquiv.to_alg_hom_eq_coe

@[simp, norm_cast]
theorem coe_alg_hom : ((e : A₁ →ₐ[R] A₂) : A₁ → A₂) = e :=
  rfl
#align alg_equiv.coe_alg_hom AlgEquiv.coe_alg_hom

theorem coe_alg_hom_injective : Function.Injective (coe : (A₁ ≃ₐ[R] A₂) → A₁ →ₐ[R] A₂) :=
  fun e₁ e₂ h => ext <| AlgHom.congr_fun h
#align alg_equiv.coe_alg_hom_injective AlgEquiv.coe_alg_hom_injective

/-- The two paths coercion can take to a `ring_hom` are equivalent -/
theorem coe_ring_hom_commutes : ((e : A₁ →ₐ[R] A₂) : A₁ →+* A₂) = ((e : A₁ ≃+* A₂) : A₁ →+* A₂) :=
  rfl
#align alg_equiv.coe_ring_hom_commutes AlgEquiv.coe_ring_hom_commutes

protected theorem map_pow : ∀ (x : A₁) (n : ℕ), e (x ^ n) = e x ^ n :=
  map_pow _
#align alg_equiv.map_pow AlgEquiv.map_pow

protected theorem injective : Function.Injective e :=
  EquivLike.injective e
#align alg_equiv.injective AlgEquiv.injective

protected theorem surjective : Function.Surjective e :=
  EquivLike.surjective e
#align alg_equiv.surjective AlgEquiv.surjective

protected theorem bijective : Function.Bijective e :=
  EquivLike.bijective e
#align alg_equiv.bijective AlgEquiv.bijective

/-- Algebra equivalences are reflexive. -/
@[refl]
def refl : A₁ ≃ₐ[R] A₁ :=
  { (1 : A₁ ≃+* A₁) with commutes' := fun r => rfl }
#align alg_equiv.refl AlgEquiv.refl

instance : Inhabited (A₁ ≃ₐ[R] A₁) :=
  ⟨refl⟩

@[simp]
theorem refl_to_alg_hom : ↑(refl : A₁ ≃ₐ[R] A₁) = AlgHom.id R A₁ :=
  rfl
#align alg_equiv.refl_to_alg_hom AlgEquiv.refl_to_alg_hom

@[simp]
theorem coe_refl : ⇑(refl : A₁ ≃ₐ[R] A₁) = id :=
  rfl
#align alg_equiv.coe_refl AlgEquiv.coe_refl

/-- Algebra equivalences are symmetric. -/
@[symm]
def symm (e : A₁ ≃ₐ[R] A₂) : A₂ ≃ₐ[R] A₁ :=
  { e.toRingEquiv.symm with
    commutes' := fun r =>
      by
      rw [← e.to_ring_equiv.symm_apply_apply (algebraMap R A₁ r)]
      congr
      change _ = e _
      rw [e.commutes] }
#align alg_equiv.symm AlgEquiv.symm

/-- See Note [custom simps projection] -/
def Simps.symmApply (e : A₁ ≃ₐ[R] A₂) : A₂ → A₁ :=
  e.symm
#align alg_equiv.simps.symm_apply AlgEquiv.Simps.symmApply

initialize_simps_projections AlgEquiv (toFun → apply, invFun → symmApply)

@[simp]
theorem coe_apply_coe_coe_symm_apply {F : Type _} [AlgEquivClass F R A₁ A₂] (f : F) (x : A₂) :
    f ((f : A₁ ≃ₐ[R] A₂).symm x) = x :=
  EquivLike.right_inv f x
#align alg_equiv.coe_apply_coe_coe_symm_apply AlgEquiv.coe_apply_coe_coe_symm_apply

@[simp]
theorem coe_coe_symm_apply_coe_apply {F : Type _} [AlgEquivClass F R A₁ A₂] (f : F) (x : A₁) :
    (f : A₁ ≃ₐ[R] A₂).symm (f x) = x :=
  EquivLike.left_inv f x
#align alg_equiv.coe_coe_symm_apply_coe_apply AlgEquiv.coe_coe_symm_apply_coe_apply

@[simp]
theorem inv_fun_eq_symm {e : A₁ ≃ₐ[R] A₂} : e.invFun = e.symm :=
  rfl
#align alg_equiv.inv_fun_eq_symm AlgEquiv.inv_fun_eq_symm

@[simp]
theorem symm_symm (e : A₁ ≃ₐ[R] A₂) : e.symm.symm = e :=
  by
  ext
  rfl
#align alg_equiv.symm_symm AlgEquiv.symm_symm

theorem symm_bijective : Function.Bijective (symm : (A₁ ≃ₐ[R] A₂) → A₂ ≃ₐ[R] A₁) :=
  Equiv.bijective ⟨symm, symm, symm_symm, symm_symm⟩
#align alg_equiv.symm_bijective AlgEquiv.symm_bijective

@[simp]
theorem mk_coe' (e : A₁ ≃ₐ[R] A₂) (f h₁ h₂ h₃ h₄ h₅) :
    (⟨f, e, h₁, h₂, h₃, h₄, h₅⟩ : A₂ ≃ₐ[R] A₁) = e.symm :=
  symm_bijective.Injective <| ext fun x => rfl
#align alg_equiv.mk_coe' AlgEquiv.mk_coe'

@[simp]
theorem symm_mk (f f') (h₁ h₂ h₃ h₄ h₅) :
    (⟨f, f', h₁, h₂, h₃, h₄, h₅⟩ : A₁ ≃ₐ[R] A₂).symm =
      {
        (⟨f, f', h₁, h₂, h₃, h₄, h₅⟩ :
            A₁ ≃ₐ[R] A₂).symm with
        toFun := f'
        invFun := f } :=
  rfl
#align alg_equiv.symm_mk AlgEquiv.symm_mk

@[simp]
theorem refl_symm : (AlgEquiv.refl : A₁ ≃ₐ[R] A₁).symm = AlgEquiv.refl :=
  rfl
#align alg_equiv.refl_symm AlgEquiv.refl_symm

--this should be a simp lemma but causes a lint timeout
theorem to_ring_equiv_symm (f : A₁ ≃ₐ[R] A₁) : (f : A₁ ≃+* A₁).symm = f.symm :=
  rfl
#align alg_equiv.to_ring_equiv_symm AlgEquiv.to_ring_equiv_symm

@[simp]
theorem symm_to_ring_equiv : (e.symm : A₂ ≃+* A₁) = (e : A₁ ≃+* A₂).symm :=
  rfl
#align alg_equiv.symm_to_ring_equiv AlgEquiv.symm_to_ring_equiv

/-- Algebra equivalences are transitive. -/
@[trans]
def trans (e₁ : A₁ ≃ₐ[R] A₂) (e₂ : A₂ ≃ₐ[R] A₃) : A₁ ≃ₐ[R] A₃ :=
  { e₁.toRingEquiv.trans e₂.toRingEquiv with
    commutes' := fun r => show e₂.toFun (e₁.toFun _) = _ by rw [e₁.commutes', e₂.commutes'] }
#align alg_equiv.trans AlgEquiv.trans

@[simp]
theorem apply_symm_apply (e : A₁ ≃ₐ[R] A₂) : ∀ x, e (e.symm x) = x :=
  e.toEquiv.apply_symm_apply
#align alg_equiv.apply_symm_apply AlgEquiv.apply_symm_apply

@[simp]
theorem symm_apply_apply (e : A₁ ≃ₐ[R] A₂) : ∀ x, e.symm (e x) = x :=
  e.toEquiv.symm_apply_apply
#align alg_equiv.symm_apply_apply AlgEquiv.symm_apply_apply

@[simp]
theorem symm_trans_apply (e₁ : A₁ ≃ₐ[R] A₂) (e₂ : A₂ ≃ₐ[R] A₃) (x : A₃) :
    (e₁.trans e₂).symm x = e₁.symm (e₂.symm x) :=
  rfl
#align alg_equiv.symm_trans_apply AlgEquiv.symm_trans_apply

@[simp]
theorem coe_trans (e₁ : A₁ ≃ₐ[R] A₂) (e₂ : A₂ ≃ₐ[R] A₃) : ⇑(e₁.trans e₂) = e₂ ∘ e₁ :=
  rfl
#align alg_equiv.coe_trans AlgEquiv.coe_trans

@[simp]
theorem trans_apply (e₁ : A₁ ≃ₐ[R] A₂) (e₂ : A₂ ≃ₐ[R] A₃) (x : A₁) : (e₁.trans e₂) x = e₂ (e₁ x) :=
  rfl
#align alg_equiv.trans_apply AlgEquiv.trans_apply

@[simp]
theorem comp_symm (e : A₁ ≃ₐ[R] A₂) : AlgHom.comp (e : A₁ →ₐ[R] A₂) ↑e.symm = AlgHom.id R A₂ :=
  by
  ext
  simp
#align alg_equiv.comp_symm AlgEquiv.comp_symm

@[simp]
theorem symm_comp (e : A₁ ≃ₐ[R] A₂) : AlgHom.comp ↑e.symm (e : A₁ →ₐ[R] A₂) = AlgHom.id R A₁ :=
  by
  ext
  simp
#align alg_equiv.symm_comp AlgEquiv.symm_comp

theorem left_inverse_symm (e : A₁ ≃ₐ[R] A₂) : Function.LeftInverse e.symm e :=
  e.left_inv
#align alg_equiv.left_inverse_symm AlgEquiv.left_inverse_symm

theorem right_inverse_symm (e : A₁ ≃ₐ[R] A₂) : Function.RightInverse e.symm e :=
  e.right_inv
#align alg_equiv.right_inverse_symm AlgEquiv.right_inverse_symm

/-- If `A₁` is equivalent to `A₁'` and `A₂` is equivalent to `A₂'`, then the type of maps
`A₁ →ₐ[R] A₂` is equivalent to the type of maps `A₁' →ₐ[R] A₂'`. -/
def arrowCongr {A₁' A₂' : Type _} [Semiring A₁'] [Semiring A₂'] [Algebra R A₁'] [Algebra R A₂']
    (e₁ : A₁ ≃ₐ[R] A₁') (e₂ : A₂ ≃ₐ[R] A₂') : (A₁ →ₐ[R] A₂) ≃ (A₁' →ₐ[R] A₂')
    where
  toFun f := (e₂.toAlgHom.comp f).comp e₁.symm.toAlgHom
  invFun f := (e₂.symm.toAlgHom.comp f).comp e₁.toAlgHom
  left_inv f := by
    simp only [AlgHom.comp_assoc, to_alg_hom_eq_coe, symm_comp]
    simp only [← AlgHom.comp_assoc, symm_comp, AlgHom.id_comp, AlgHom.comp_id]
  right_inv f := by
    simp only [AlgHom.comp_assoc, to_alg_hom_eq_coe, comp_symm]
    simp only [← AlgHom.comp_assoc, comp_symm, AlgHom.id_comp, AlgHom.comp_id]
#align alg_equiv.arrow_congr AlgEquiv.arrowCongr

theorem arrow_congr_comp {A₁' A₂' A₃' : Type _} [Semiring A₁'] [Semiring A₂'] [Semiring A₃']
    [Algebra R A₁'] [Algebra R A₂'] [Algebra R A₃'] (e₁ : A₁ ≃ₐ[R] A₁') (e₂ : A₂ ≃ₐ[R] A₂')
    (e₃ : A₃ ≃ₐ[R] A₃') (f : A₁ →ₐ[R] A₂) (g : A₂ →ₐ[R] A₃) :
    arrowCongr e₁ e₃ (g.comp f) = (arrowCongr e₂ e₃ g).comp (arrowCongr e₁ e₂ f) :=
  by
  ext
  simp only [arrow_congr, Equiv.coe_fn_mk, AlgHom.comp_apply]
  congr
  exact (e₂.symm_apply_apply _).symm
#align alg_equiv.arrow_congr_comp AlgEquiv.arrow_congr_comp

@[simp]
theorem arrow_congr_refl : arrowCongr AlgEquiv.refl AlgEquiv.refl = Equiv.refl (A₁ →ₐ[R] A₂) :=
  by
  ext
  rfl
#align alg_equiv.arrow_congr_refl AlgEquiv.arrow_congr_refl

@[simp]
theorem arrow_congr_trans {A₁' A₂' A₃' : Type _} [Semiring A₁'] [Semiring A₂'] [Semiring A₃']
    [Algebra R A₁'] [Algebra R A₂'] [Algebra R A₃'] (e₁ : A₁ ≃ₐ[R] A₂) (e₁' : A₁' ≃ₐ[R] A₂')
    (e₂ : A₂ ≃ₐ[R] A₃) (e₂' : A₂' ≃ₐ[R] A₃') :
    arrowCongr (e₁.trans e₂) (e₁'.trans e₂') = (arrowCongr e₁ e₁').trans (arrowCongr e₂ e₂') :=
  by
  ext
  rfl
#align alg_equiv.arrow_congr_trans AlgEquiv.arrow_congr_trans

@[simp]
theorem arrow_congr_symm {A₁' A₂' : Type _} [Semiring A₁'] [Semiring A₂'] [Algebra R A₁']
    [Algebra R A₂'] (e₁ : A₁ ≃ₐ[R] A₁') (e₂ : A₂ ≃ₐ[R] A₂') :
    (arrowCongr e₁ e₂).symm = arrowCongr e₁.symm e₂.symm :=
  by
  ext
  rfl
#align alg_equiv.arrow_congr_symm AlgEquiv.arrow_congr_symm

/-- If an algebra morphism has an inverse, it is a algebra isomorphism. -/
def ofAlgHom (f : A₁ →ₐ[R] A₂) (g : A₂ →ₐ[R] A₁) (h₁ : f.comp g = AlgHom.id R A₂)
    (h₂ : g.comp f = AlgHom.id R A₁) : A₁ ≃ₐ[R] A₂ :=
  { f with
    toFun := f
    invFun := g
    left_inv := AlgHom.ext_iff.1 h₂
    right_inv := AlgHom.ext_iff.1 h₁ }
#align alg_equiv.of_alg_hom AlgEquiv.ofAlgHom

theorem coe_alg_hom_of_alg_hom (f : A₁ →ₐ[R] A₂) (g : A₂ →ₐ[R] A₁) (h₁ h₂) :
    ↑(ofAlgHom f g h₁ h₂) = f :=
  AlgHom.ext fun _ => rfl
#align alg_equiv.coe_alg_hom_of_alg_hom AlgEquiv.coe_alg_hom_of_alg_hom

@[simp]
theorem of_alg_hom_coe_alg_hom (f : A₁ ≃ₐ[R] A₂) (g : A₂ →ₐ[R] A₁) (h₁ h₂) :
    ofAlgHom (↑f) g h₁ h₂ = f :=
  ext fun _ => rfl
#align alg_equiv.of_alg_hom_coe_alg_hom AlgEquiv.of_alg_hom_coe_alg_hom

theorem of_alg_hom_symm (f : A₁ →ₐ[R] A₂) (g : A₂ →ₐ[R] A₁) (h₁ h₂) :
    (ofAlgHom f g h₁ h₂).symm = ofAlgHom g f h₂ h₁ :=
  rfl
#align alg_equiv.of_alg_hom_symm AlgEquiv.of_alg_hom_symm

/-- Promotes a bijective algebra homomorphism to an algebra equivalence. -/
noncomputable def ofBijective (f : A₁ →ₐ[R] A₂) (hf : Function.Bijective f) : A₁ ≃ₐ[R] A₂ :=
  { RingEquiv.ofBijective (f : A₁ →+* A₂) hf, f with }
#align alg_equiv.of_bijective AlgEquiv.ofBijective

@[simp]
theorem coe_of_bijective {f : A₁ →ₐ[R] A₂} {hf : Function.Bijective f} :
    (AlgEquiv.ofBijective f hf : A₁ → A₂) = f :=
  rfl
#align alg_equiv.coe_of_bijective AlgEquiv.coe_of_bijective

theorem of_bijective_apply {f : A₁ →ₐ[R] A₂} {hf : Function.Bijective f} (a : A₁) :
    (AlgEquiv.ofBijective f hf) a = f a :=
  rfl
#align alg_equiv.of_bijective_apply AlgEquiv.of_bijective_apply

/-- Forgetting the multiplicative structures, an equivalence of algebras is a linear equivalence. -/
@[simps apply]
def toLinearEquiv (e : A₁ ≃ₐ[R] A₂) : A₁ ≃ₗ[R] A₂ :=
  { e with
    toFun := e
    map_smul' := e.map_smul
    invFun := e.symm }
#align alg_equiv.to_linear_equiv AlgEquiv.toLinearEquiv

@[simp]
theorem to_linear_equiv_refl :
    (AlgEquiv.refl : A₁ ≃ₐ[R] A₁).toLinearEquiv = LinearEquiv.refl R A₁ :=
  rfl
#align alg_equiv.to_linear_equiv_refl AlgEquiv.to_linear_equiv_refl

@[simp]
theorem to_linear_equiv_symm (e : A₁ ≃ₐ[R] A₂) : e.toLinearEquiv.symm = e.symm.toLinearEquiv :=
  rfl
#align alg_equiv.to_linear_equiv_symm AlgEquiv.to_linear_equiv_symm

@[simp]
theorem to_linear_equiv_trans (e₁ : A₁ ≃ₐ[R] A₂) (e₂ : A₂ ≃ₐ[R] A₃) :
    (e₁.trans e₂).toLinearEquiv = e₁.toLinearEquiv.trans e₂.toLinearEquiv :=
  rfl
#align alg_equiv.to_linear_equiv_trans AlgEquiv.to_linear_equiv_trans

theorem to_linear_equiv_injective : Function.Injective (toLinearEquiv : _ → A₁ ≃ₗ[R] A₂) :=
  fun e₁ e₂ h => ext <| LinearEquiv.congr_fun h
#align alg_equiv.to_linear_equiv_injective AlgEquiv.to_linear_equiv_injective

/-- Interpret an algebra equivalence as a linear map. -/
def toLinearMap : A₁ →ₗ[R] A₂ :=
  e.toAlgHom.toLinearMap
#align alg_equiv.to_linear_map AlgEquiv.toLinearMap

@[simp]
theorem to_alg_hom_to_linear_map : (e : A₁ →ₐ[R] A₂).toLinearMap = e.toLinearMap :=
  rfl
#align alg_equiv.to_alg_hom_to_linear_map AlgEquiv.to_alg_hom_to_linear_map

@[simp]
theorem to_linear_equiv_to_linear_map : e.toLinearEquiv.toLinearMap = e.toLinearMap :=
  rfl
#align alg_equiv.to_linear_equiv_to_linear_map AlgEquiv.to_linear_equiv_to_linear_map

@[simp]
theorem to_linear_map_apply (x : A₁) : e.toLinearMap x = e x :=
  rfl
#align alg_equiv.to_linear_map_apply AlgEquiv.to_linear_map_apply

theorem to_linear_map_injective : Function.Injective (toLinearMap : _ → A₁ →ₗ[R] A₂) :=
  fun e₁ e₂ h => ext <| LinearMap.congr_fun h
#align alg_equiv.to_linear_map_injective AlgEquiv.to_linear_map_injective

@[simp]
theorem trans_to_linear_map (f : A₁ ≃ₐ[R] A₂) (g : A₂ ≃ₐ[R] A₃) :
    (f.trans g).toLinearMap = g.toLinearMap.comp f.toLinearMap :=
  rfl
#align alg_equiv.trans_to_linear_map AlgEquiv.trans_to_linear_map

section OfLinearEquiv

variable (l : A₁ ≃ₗ[R] A₂) (map_mul : ∀ x y : A₁, l (x * y) = l x * l y)
  (commutes : ∀ r : R, l (algebraMap R A₁ r) = algebraMap R A₂ r)

/-- Upgrade a linear equivalence to an algebra equivalence,
given that it distributes over multiplication and action of scalars.
-/
@[simps apply]
def ofLinearEquiv : A₁ ≃ₐ[R] A₂ :=
  { l with
    toFun := l
    invFun := l.symm
    map_mul' := map_mul
    commutes' := commutes }
#align alg_equiv.of_linear_equiv AlgEquiv.ofLinearEquiv

@[simp]
theorem of_linear_equiv_symm :
    (ofLinearEquiv l map_mul commutes).symm =
      ofLinearEquiv l.symm (ofLinearEquiv l map_mul commutes).symm.map_mul
        (ofLinearEquiv l map_mul commutes).symm.commutes :=
  rfl
#align alg_equiv.of_linear_equiv_symm AlgEquiv.of_linear_equiv_symm

@[simp]
theorem of_linear_equiv_to_linear_equiv (map_mul) (commutes) :
    ofLinearEquiv e.toLinearEquiv map_mul commutes = e :=
  by
  ext
  rfl
#align alg_equiv.of_linear_equiv_to_linear_equiv AlgEquiv.of_linear_equiv_to_linear_equiv

@[simp]
theorem to_linear_equiv_of_linear_equiv : toLinearEquiv (ofLinearEquiv l map_mul commutes) = l :=
  by
  ext
  rfl
#align alg_equiv.to_linear_equiv_of_linear_equiv AlgEquiv.to_linear_equiv_of_linear_equiv

end OfLinearEquiv

section OfRingEquiv

/-- Promotes a linear ring_equiv to an alg_equiv. -/
@[simps]
def ofRingEquiv {f : A₁ ≃+* A₂} (hf : ∀ x, f (algebraMap R A₁ x) = algebraMap R A₂ x) :
    A₁ ≃ₐ[R] A₂ :=
  { f with
    toFun := f
    invFun := f.symm
    commutes' := hf }
#align alg_equiv.of_ring_equiv AlgEquiv.ofRingEquiv

end OfRingEquiv

@[simps (config := { attrs := [] }) mul one]
instance aut : Group (A₁ ≃ₐ[R] A₁) where
  mul ϕ ψ := ψ.trans ϕ
  mul_assoc ϕ ψ χ := rfl
  one := refl
  one_mul ϕ := ext fun x => rfl
  mul_one ϕ := ext fun x => rfl
  inv := symm
  mul_left_inv ϕ := ext <| symm_apply_apply ϕ
#align alg_equiv.aut AlgEquiv.aut

@[simp]
theorem one_apply (x : A₁) : (1 : A₁ ≃ₐ[R] A₁) x = x :=
  rfl
#align alg_equiv.one_apply AlgEquiv.one_apply

@[simp]
theorem mul_apply (e₁ e₂ : A₁ ≃ₐ[R] A₁) (x : A₁) : (e₁ * e₂) x = e₁ (e₂ x) :=
  rfl
#align alg_equiv.mul_apply AlgEquiv.mul_apply

/-- An algebra isomorphism induces a group isomorphism between automorphism groups -/
@[simps apply]
def autCongr (ϕ : A₁ ≃ₐ[R] A₂) : (A₁ ≃ₐ[R] A₁) ≃* A₂ ≃ₐ[R] A₂
    where
  toFun ψ := ϕ.symm.trans (ψ.trans ϕ)
  invFun ψ := ϕ.trans (ψ.trans ϕ.symm)
  left_inv ψ := by
    ext
    simp_rw [trans_apply, symm_apply_apply]
  right_inv ψ := by
    ext
    simp_rw [trans_apply, apply_symm_apply]
  map_mul' ψ χ := by
    ext
    simp only [mul_apply, trans_apply, symm_apply_apply]
#align alg_equiv.aut_congr AlgEquiv.autCongr

@[simp]
theorem aut_congr_refl : autCongr AlgEquiv.refl = MulEquiv.refl (A₁ ≃ₐ[R] A₁) :=
  by
  ext
  rfl
#align alg_equiv.aut_congr_refl AlgEquiv.aut_congr_refl

@[simp]
theorem aut_congr_symm (ϕ : A₁ ≃ₐ[R] A₂) : (autCongr ϕ).symm = autCongr ϕ.symm :=
  rfl
#align alg_equiv.aut_congr_symm AlgEquiv.aut_congr_symm

@[simp]
theorem aut_congr_trans (ϕ : A₁ ≃ₐ[R] A₂) (ψ : A₂ ≃ₐ[R] A₃) :
    (autCongr ϕ).trans (autCongr ψ) = autCongr (ϕ.trans ψ) :=
  rfl
#align alg_equiv.aut_congr_trans AlgEquiv.aut_congr_trans

/-- The tautological action by `A₁ ≃ₐ[R] A₁` on `A₁`.

This generalizes `function.End.apply_mul_action`. -/
instance applyMulSemiringAction : MulSemiringAction (A₁ ≃ₐ[R] A₁) A₁
    where
  smul := (· <| ·)
  smul_zero := AlgEquiv.map_zero
  smul_add := AlgEquiv.map_add
  smul_one := AlgEquiv.map_one
  smul_mul := AlgEquiv.map_mul
  one_smul _ := rfl
  mul_smul _ _ _ := rfl
#align alg_equiv.apply_mul_semiring_action AlgEquiv.applyMulSemiringAction

@[simp]
protected theorem smul_def (f : A₁ ≃ₐ[R] A₁) (a : A₁) : f • a = f a :=
  rfl
#align alg_equiv.smul_def AlgEquiv.smul_def

instance apply_has_faithful_smul : FaithfulSMul (A₁ ≃ₐ[R] A₁) A₁ :=
  ⟨fun _ _ => AlgEquiv.ext⟩
#align alg_equiv.apply_has_faithful_smul AlgEquiv.apply_has_faithful_smul

instance apply_smul_comm_class : SMulCommClass R (A₁ ≃ₐ[R] A₁) A₁
    where smul_comm r e a := (e.map_smul r a).symm
#align alg_equiv.apply_smul_comm_class AlgEquiv.apply_smul_comm_class

instance apply_smul_comm_class' : SMulCommClass (A₁ ≃ₐ[R] A₁) R A₁
    where smul_comm e r a := e.map_smul r a
#align alg_equiv.apply_smul_comm_class' AlgEquiv.apply_smul_comm_class'

@[simp]
theorem algebra_map_eq_apply (e : A₁ ≃ₐ[R] A₂) {y : R} {x : A₁} :
    algebraMap R A₂ y = e x ↔ algebraMap R A₁ y = x :=
  ⟨fun h => by simpa using e.symm.to_alg_hom.algebra_map_eq_apply h, fun h =>
    e.toAlgHom.algebra_map_eq_apply h⟩
#align alg_equiv.algebra_map_eq_apply AlgEquiv.algebra_map_eq_apply

end Semiring

section CommSemiring

variable [CommSemiring R] [CommSemiring A₁] [CommSemiring A₂]

variable [Algebra R A₁] [Algebra R A₂] (e : A₁ ≃ₐ[R] A₂)

theorem map_prod {ι : Type _} (f : ι → A₁) (s : Finset ι) : e (∏ x in s, f x) = ∏ x in s, e (f x) :=
  map_prod _ f s
#align alg_equiv.map_prod AlgEquiv.map_prod

theorem map_finsupp_prod {α : Type _} [Zero α] {ι : Type _} (f : ι →₀ α) (g : ι → α → A₁) :
    e (f.Prod g) = f.Prod fun i a => e (g i a) :=
  map_finsupp_prod _ f g
#align alg_equiv.map_finsupp_prod AlgEquiv.map_finsupp_prod

end CommSemiring

section Ring

variable [CommSemiring R] [Ring A₁] [Ring A₂]

variable [Algebra R A₁] [Algebra R A₂] (e : A₁ ≃ₐ[R] A₂)

protected theorem map_neg (x) : e (-x) = -e x :=
  map_neg e x
#align alg_equiv.map_neg AlgEquiv.map_neg

protected theorem map_sub (x y) : e (x - y) = e x - e y :=
  map_sub e x y
#align alg_equiv.map_sub AlgEquiv.map_sub

end Ring

end AlgEquiv

namespace MulSemiringAction

variable {M G : Type _} (R A : Type _) [CommSemiring R] [Semiring A] [Algebra R A]

section

variable [Group G] [MulSemiringAction G A] [SMulCommClass G R A]

/-- Each element of the group defines a algebra equivalence.

This is a stronger version of `mul_semiring_action.to_ring_equiv` and
`distrib_mul_action.to_linear_equiv`. -/
@[simps]
def toAlgEquiv (g : G) : A ≃ₐ[R] A :=
  { MulSemiringAction.toRingEquiv _ _ g, MulSemiringAction.toAlgHom R A g with }
#align mul_semiring_action.to_alg_equiv MulSemiringAction.toAlgEquiv

theorem to_alg_equiv_injective [FaithfulSMul G A] :
    Function.Injective (MulSemiringAction.toAlgEquiv R A : G → A ≃ₐ[R] A) := fun m₁ m₂ h =>
  eq_of_smul_eq_smul fun r => AlgEquiv.ext_iff.1 h r
#align mul_semiring_action.to_alg_equiv_injective MulSemiringAction.to_alg_equiv_injective

end

end MulSemiringAction

