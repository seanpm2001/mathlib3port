/-
Copyright (c) 2020 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module linear_algebra.multilinear.basic
! leanprover-community/mathlib commit 78fdf68dcd2fdb3fe64c0dd6f88926a49418a6ea
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Basic
import Mathbin.Algebra.Algebra.Basic
import Mathbin.Algebra.BigOperators.Order
import Mathbin.Algebra.BigOperators.Ring
import Mathbin.Data.List.FinRange
import Mathbin.Data.Fintype.BigOperators
import Mathbin.Data.Fintype.Sort

/-!
# Multilinear maps

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define multilinear maps as maps from `Π(i : ι), M₁ i` to `M₂` which are linear in each
coordinate. Here, `M₁ i` and `M₂` are modules over a ring `R`, and `ι` is an arbitrary type
(although some statements will require it to be a fintype). This space, denoted by
`multilinear_map R M₁ M₂`, inherits a module structure by pointwise addition and multiplication.

## Main definitions

* `multilinear_map R M₁ M₂` is the space of multilinear maps from `Π(i : ι), M₁ i` to `M₂`.
* `f.map_smul` is the multiplicativity of the multilinear map `f` along each coordinate.
* `f.map_add` is the additivity of the multilinear map `f` along each coordinate.
* `f.map_smul_univ` expresses the multiplicativity of `f` over all coordinates at the same time,
  writing `f (λi, c i • m i)` as `(∏ i, c i) • f m`.
* `f.map_add_univ` expresses the additivity of `f` over all coordinates at the same time, writing
  `f (m + m')` as the sum over all subsets `s` of `ι` of `f (s.piecewise m m')`.
* `f.map_sum` expresses `f (Σ_{j₁} g₁ j₁, ..., Σ_{jₙ} gₙ jₙ)` as the sum of
  `f (g₁ (r 1), ..., gₙ (r n))` where `r` ranges over all possible functions.

We also register isomorphisms corresponding to currying or uncurrying variables, transforming a
multilinear function `f` on `n+1` variables into a linear function taking values in multilinear
functions in `n` variables, and into a multilinear function in `n` variables taking values in linear
functions. These operations are called `f.curry_left` and `f.curry_right` respectively
(with inverses `f.uncurry_left` and `f.uncurry_right`). These operations induce linear equivalences
between spaces of multilinear functions in `n+1` variables and spaces of linear functions into
multilinear functions in `n` variables (resp. multilinear functions in `n` variables taking values
in linear functions), called respectively `multilinear_curry_left_equiv` and
`multilinear_curry_right_equiv`.

## Implementation notes

Expressing that a map is linear along the `i`-th coordinate when all other coordinates are fixed
can be done in two (equivalent) different ways:

* fixing a vector `m : Π(j : ι - i), M₁ j.val`, and then choosing separately the `i`-th coordinate
* fixing a vector `m : Πj, M₁ j`, and then modifying its `i`-th coordinate

The second way is more artificial as the value of `m` at `i` is not relevant, but it has the
advantage of avoiding subtype inclusion issues. This is the definition we use, based on
`function.update` that allows to change the value of `m` at `i`.

Note that the use of `function.update` requires a `decidable_eq ι` term to appear somewhere in the
statement of `multilinear_map.map_add'` and `multilinear_map.map_smul'`. Three possible choices
are:

1. Requiring `decidable_eq ι` as an argument to `multilinear_map` (as we did originally).
2. Using `classical.dec_eq ι` in the statement of `map_add'` and `map_smul'`.
3. Quantifying over all possible `decidable_eq ι` instances in the statement of `map_add'` and
   `map_smul'`.

Option 1 works fine, but puts unecessary constraints on the user (the zero map certainly does not
need decidability). Option 2 looks great at first, but in the common case when `ι = fin n` it
introduces non-defeq decidability instance diamonds within the context of proving `map_add'` and
`map_smul'`, of the form `fin.decidable_eq n = classical.dec_eq (fin n)`. Option 3 of course does
something similar, but of the form `fin.decidable_eq n = _inst`, which is much easier to clean up
since `_inst` is a free variable and so the equality can just be substituted.
-/


open Function Fin Set

open scoped BigOperators

universe u v v' v₁ v₂ v₃ w u'

variable {R : Type u} {ι : Type u'} {n : ℕ} {M : Fin n.succ → Type v} {M₁ : ι → Type v₁}
  {M₂ : Type v₂} {M₃ : Type v₃} {M' : Type v'}

#print MultilinearMap /-
/-- Multilinear maps over the ring `R`, from `Πi, M₁ i` to `M₂` where `M₁ i` and `M₂` are modules
over `R`. -/
structure MultilinearMap (R : Type u) {ι : Type u'} (M₁ : ι → Type v) (M₂ : Type w) [Semiring R]
    [∀ i, AddCommMonoid (M₁ i)] [AddCommMonoid M₂] [∀ i, Module R (M₁ i)] [Module R M₂] where
  toFun : (∀ i, M₁ i) → M₂
  map_add' :
    ∀ [DecidableEq ι] (m : ∀ i, M₁ i) (i : ι) (x y : M₁ i),
      to_fun (update m i (x + y)) = to_fun (update m i x) + to_fun (update m i y)
  map_smul' :
    ∀ [DecidableEq ι] (m : ∀ i, M₁ i) (i : ι) (c : R) (x : M₁ i),
      to_fun (update m i (c • x)) = c • to_fun (update m i x)
#align multilinear_map MultilinearMap
-/

namespace MultilinearMap

section Semiring

variable [Semiring R] [∀ i, AddCommMonoid (M i)] [∀ i, AddCommMonoid (M₁ i)] [AddCommMonoid M₂]
  [AddCommMonoid M₃] [AddCommMonoid M'] [∀ i, Module R (M i)] [∀ i, Module R (M₁ i)] [Module R M₂]
  [Module R M₃] [Module R M'] (f f' : MultilinearMap R M₁ M₂)

instance : CoeFun (MultilinearMap R M₁ M₂) fun f => (∀ i, M₁ i) → M₂ :=
  ⟨toFun⟩

initialize_simps_projections MultilinearMap (toFun → apply)

#print MultilinearMap.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe : f.toFun = f :=
  rfl
#align multilinear_map.to_fun_eq_coe MultilinearMap.toFun_eq_coe
-/

#print MultilinearMap.coe_mk /-
@[simp]
theorem coe_mk (f : (∀ i, M₁ i) → M₂) (h₁ h₂) : ⇑(⟨f, h₁, h₂⟩ : MultilinearMap R M₁ M₂) = f :=
  rfl
#align multilinear_map.coe_mk MultilinearMap.coe_mk
-/

#print MultilinearMap.congr_fun /-
theorem congr_fun {f g : MultilinearMap R M₁ M₂} (h : f = g) (x : ∀ i, M₁ i) : f x = g x :=
  congr_arg (fun h : MultilinearMap R M₁ M₂ => h x) h
#align multilinear_map.congr_fun MultilinearMap.congr_fun
-/

#print MultilinearMap.congr_arg /-
theorem congr_arg (f : MultilinearMap R M₁ M₂) {x y : ∀ i, M₁ i} (h : x = y) : f x = f y :=
  congr_arg (fun x : ∀ i, M₁ i => f x) h
#align multilinear_map.congr_arg MultilinearMap.congr_arg
-/

#print MultilinearMap.coe_injective /-
theorem coe_injective : Injective (coeFn : MultilinearMap R M₁ M₂ → (∀ i, M₁ i) → M₂) := by
  intro f g h; cases f; cases g; cases h; rfl
#align multilinear_map.coe_injective MultilinearMap.coe_injective
-/

#print MultilinearMap.coe_inj /-
@[simp, norm_cast]
theorem coe_inj {f g : MultilinearMap R M₁ M₂} : (f : (∀ i, M₁ i) → M₂) = g ↔ f = g :=
  coe_injective.eq_iff
#align multilinear_map.coe_inj MultilinearMap.coe_inj
-/

#print MultilinearMap.ext /-
@[ext]
theorem ext {f f' : MultilinearMap R M₁ M₂} (H : ∀ x, f x = f' x) : f = f' :=
  coe_injective (funext H)
#align multilinear_map.ext MultilinearMap.ext
-/

#print MultilinearMap.ext_iff /-
theorem ext_iff {f g : MultilinearMap R M₁ M₂} : f = g ↔ ∀ x, f x = g x :=
  ⟨fun h x => h ▸ rfl, fun h => ext h⟩
#align multilinear_map.ext_iff MultilinearMap.ext_iff
-/

#print MultilinearMap.mk_coe /-
@[simp]
theorem mk_coe (f : MultilinearMap R M₁ M₂) (h₁ h₂) : (⟨f, h₁, h₂⟩ : MultilinearMap R M₁ M₂) = f :=
  by ext; rfl
#align multilinear_map.mk_coe MultilinearMap.mk_coe
-/

#print MultilinearMap.map_add /-
@[simp]
protected theorem map_add [DecidableEq ι] (m : ∀ i, M₁ i) (i : ι) (x y : M₁ i) :
    f (update m i (x + y)) = f (update m i x) + f (update m i y) :=
  f.map_add' m i x y
#align multilinear_map.map_add MultilinearMap.map_add
-/

#print MultilinearMap.map_smul /-
@[simp]
protected theorem map_smul [DecidableEq ι] (m : ∀ i, M₁ i) (i : ι) (c : R) (x : M₁ i) :
    f (update m i (c • x)) = c • f (update m i x) :=
  f.map_smul' m i c x
#align multilinear_map.map_smul MultilinearMap.map_smul
-/

#print MultilinearMap.map_coord_zero /-
theorem map_coord_zero {m : ∀ i, M₁ i} (i : ι) (h : m i = 0) : f m = 0 := by
  classical
  have : (0 : R) • (0 : M₁ i) = 0 := by simp
  rw [← update_eq_self i m, h, ← this, f.map_smul, zero_smul]
#align multilinear_map.map_coord_zero MultilinearMap.map_coord_zero
-/

#print MultilinearMap.map_update_zero /-
@[simp]
theorem map_update_zero [DecidableEq ι] (m : ∀ i, M₁ i) (i : ι) : f (update m i 0) = 0 :=
  f.map_coord_zero i (update_same i 0 m)
#align multilinear_map.map_update_zero MultilinearMap.map_update_zero
-/

#print MultilinearMap.map_zero /-
@[simp]
theorem map_zero [Nonempty ι] : f 0 = 0 :=
  by
  obtain ⟨i, _⟩ : ∃ i : ι, i ∈ Set.univ := Set.exists_mem_of_nonempty ι
  exact map_coord_zero f i rfl
#align multilinear_map.map_zero MultilinearMap.map_zero
-/

instance : Add (MultilinearMap R M₁ M₂) :=
  ⟨fun f f' =>
    ⟨fun x => f x + f' x, fun m i x y => by simp [add_left_comm, add_assoc], fun _ m i c x => by
      simp [smul_add]⟩⟩

#print MultilinearMap.add_apply /-
@[simp]
theorem add_apply (m : ∀ i, M₁ i) : (f + f') m = f m + f' m :=
  rfl
#align multilinear_map.add_apply MultilinearMap.add_apply
-/

instance : Zero (MultilinearMap R M₁ M₂) :=
  ⟨⟨fun _ => 0, fun _ m i x y => by simp, fun _ m i c x => by simp⟩⟩

instance : Inhabited (MultilinearMap R M₁ M₂) :=
  ⟨0⟩

#print MultilinearMap.zero_apply /-
@[simp]
theorem zero_apply (m : ∀ i, M₁ i) : (0 : MultilinearMap R M₁ M₂) m = 0 :=
  rfl
#align multilinear_map.zero_apply MultilinearMap.zero_apply
-/

section SMul

variable {R' A : Type _} [Monoid R'] [Semiring A] [∀ i, Module A (M₁ i)] [DistribMulAction R' M₂]
  [Module A M₂] [SMulCommClass A R' M₂]

instance : SMul R' (MultilinearMap A M₁ M₂) :=
  ⟨fun c f =>
    ⟨fun m => c • f m, fun _ m i x y => by simp [smul_add], fun _ l i x d => by
      simp [← smul_comm x c]⟩⟩

#print MultilinearMap.smul_apply /-
@[simp]
theorem smul_apply (f : MultilinearMap A M₁ M₂) (c : R') (m : ∀ i, M₁ i) : (c • f) m = c • f m :=
  rfl
#align multilinear_map.smul_apply MultilinearMap.smul_apply
-/

#print MultilinearMap.coe_smul /-
theorem coe_smul (c : R') (f : MultilinearMap A M₁ M₂) : ⇑(c • f) = c • f :=
  rfl
#align multilinear_map.coe_smul MultilinearMap.coe_smul
-/

end SMul

instance : AddCommMonoid (MultilinearMap R M₁ M₂) :=
  coe_injective.AddCommMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

#print MultilinearMap.sum_apply /-
@[simp]
theorem sum_apply {α : Type _} (f : α → MultilinearMap R M₁ M₂) (m : ∀ i, M₁ i) :
    ∀ {s : Finset α}, (∑ a in s, f a) m = ∑ a in s, f a m := by
  classical
  apply Finset.induction
  · rw [Finset.sum_empty]; simp
  · intro a s has H; rw [Finset.sum_insert has]; simp [H, has]
#align multilinear_map.sum_apply MultilinearMap.sum_apply
-/

#print MultilinearMap.toLinearMap /-
/-- If `f` is a multilinear map, then `f.to_linear_map m i` is the linear map obtained by fixing all
coordinates but `i` equal to those of `m`, and varying the `i`-th coordinate. -/
@[simps]
def toLinearMap [DecidableEq ι] (m : ∀ i, M₁ i) (i : ι) : M₁ i →ₗ[R] M₂
    where
  toFun x := f (update m i x)
  map_add' x y := by simp
  map_smul' c x := by simp
#align multilinear_map.to_linear_map MultilinearMap.toLinearMap
-/

#print MultilinearMap.prod /-
/-- The cartesian product of two multilinear maps, as a multilinear map. -/
@[simps]
def prod (f : MultilinearMap R M₁ M₂) (g : MultilinearMap R M₁ M₃) : MultilinearMap R M₁ (M₂ × M₃)
    where
  toFun m := (f m, g m)
  map_add' _ m i x y := by simp
  map_smul' _ m i c x := by simp
#align multilinear_map.prod MultilinearMap.prod
-/

#print MultilinearMap.pi /-
/-- Combine a family of multilinear maps with the same domain and codomains `M' i` into a
multilinear map taking values in the space of functions `Π i, M' i`. -/
@[simps]
def pi {ι' : Type _} {M' : ι' → Type _} [∀ i, AddCommMonoid (M' i)] [∀ i, Module R (M' i)]
    (f : ∀ i, MultilinearMap R M₁ (M' i)) : MultilinearMap R M₁ (∀ i, M' i)
    where
  toFun m i := f i m
  map_add' _ m i x y := funext fun j => (f j).map_add _ _ _ _
  map_smul' _ m i c x := funext fun j => (f j).map_smul _ _ _ _
#align multilinear_map.pi MultilinearMap.pi
-/

section

variable (R M₂)

#print MultilinearMap.ofSubsingleton /-
/-- The evaluation map from `ι → M₂` to `M₂` is multilinear at a given `i` when `ι` is subsingleton.
-/
@[simps]
def ofSubsingleton [Subsingleton ι] (i' : ι) : MultilinearMap R (fun _ : ι => M₂) M₂
    where
  toFun := Function.eval i'
  map_add' _ m i x y := by rw [Subsingleton.elim i i'];
    simp only [Function.eval, Function.update_same]
  map_smul' _ m i r x := by rw [Subsingleton.elim i i'];
    simp only [Function.eval, Function.update_same]
#align multilinear_map.of_subsingleton MultilinearMap.ofSubsingleton
-/

variable (M₁) {M₂}

#print MultilinearMap.constOfIsEmpty /-
/-- The constant map is multilinear when `ι` is empty. -/
@[simps (config := { fullyApplied := false })]
def constOfIsEmpty [IsEmpty ι] (m : M₂) : MultilinearMap R M₁ M₂
    where
  toFun := Function.const _ m
  map_add' _ m := isEmptyElim
  map_smul' _ m := isEmptyElim
#align multilinear_map.const_of_is_empty MultilinearMap.constOfIsEmpty
-/

end

#print MultilinearMap.restr /-
/-- Given a multilinear map `f` on `n` variables (parameterized by `fin n`) and a subset `s` of `k`
of these variables, one gets a new multilinear map on `fin k` by varying these variables, and fixing
the other ones equal to a given value `z`. It is denoted by `f.restr s hk z`, where `hk` is a
proof that the cardinality of `s` is `k`. The implicit identification between `fin k` and `s` that
we use is the canonical (increasing) bijection. -/
def restr {k n : ℕ} (f : MultilinearMap R (fun i : Fin n => M') M₂) (s : Finset (Fin n))
    (hk : s.card = k) (z : M') : MultilinearMap R (fun i : Fin k => M') M₂
    where
  toFun v := f fun j => if h : j ∈ s then v ((s.orderIsoOfFin hk).symm ⟨j, h⟩) else z
  map_add' _ v i x y := by
    erw [dite_comp_equiv_update, dite_comp_equiv_update, dite_comp_equiv_update]; simp
  map_smul' _ v i c x := by erw [dite_comp_equiv_update, dite_comp_equiv_update]; simp
#align multilinear_map.restr MultilinearMap.restr
-/

variable {R}

#print MultilinearMap.cons_add /-
/-- In the specific case of multilinear maps on spaces indexed by `fin (n+1)`, where one can build
an element of `Π(i : fin (n+1)), M i` using `cons`, one can express directly the additivity of a
multilinear map along the first variable. -/
theorem cons_add (f : MultilinearMap R M M₂) (m : ∀ i : Fin n, M i.succ) (x y : M 0) :
    f (cons (x + y) m) = f (cons x m) + f (cons y m) := by
  rw [← update_cons_zero x m (x + y), f.map_add, update_cons_zero, update_cons_zero]
#align multilinear_map.cons_add MultilinearMap.cons_add
-/

#print MultilinearMap.cons_smul /-
/-- In the specific case of multilinear maps on spaces indexed by `fin (n+1)`, where one can build
an element of `Π(i : fin (n+1)), M i` using `cons`, one can express directly the multiplicativity
of a multilinear map along the first variable. -/
theorem cons_smul (f : MultilinearMap R M M₂) (m : ∀ i : Fin n, M i.succ) (c : R) (x : M 0) :
    f (cons (c • x) m) = c • f (cons x m) := by
  rw [← update_cons_zero x m (c • x), f.map_smul, update_cons_zero]
#align multilinear_map.cons_smul MultilinearMap.cons_smul
-/

#print MultilinearMap.snoc_add /-
/-- In the specific case of multilinear maps on spaces indexed by `fin (n+1)`, where one can build
an element of `Π(i : fin (n+1)), M i` using `snoc`, one can express directly the additivity of a
multilinear map along the first variable. -/
theorem snoc_add (f : MultilinearMap R M M₂) (m : ∀ i : Fin n, M i.cast_succ) (x y : M (last n)) :
    f (snoc m (x + y)) = f (snoc m x) + f (snoc m y) := by
  rw [← update_snoc_last x m (x + y), f.map_add, update_snoc_last, update_snoc_last]
#align multilinear_map.snoc_add MultilinearMap.snoc_add
-/

#print MultilinearMap.snoc_smul /-
/-- In the specific case of multilinear maps on spaces indexed by `fin (n+1)`, where one can build
an element of `Π(i : fin (n+1)), M i` using `cons`, one can express directly the multiplicativity
of a multilinear map along the first variable. -/
theorem snoc_smul (f : MultilinearMap R M M₂) (m : ∀ i : Fin n, M i.cast_succ) (c : R)
    (x : M (last n)) : f (snoc m (c • x)) = c • f (snoc m x) := by
  rw [← update_snoc_last x m (c • x), f.map_smul, update_snoc_last]
#align multilinear_map.snoc_smul MultilinearMap.snoc_smul
-/

section

variable {M₁' : ι → Type _} [∀ i, AddCommMonoid (M₁' i)] [∀ i, Module R (M₁' i)]

variable {M₁'' : ι → Type _} [∀ i, AddCommMonoid (M₁'' i)] [∀ i, Module R (M₁'' i)]

#print MultilinearMap.compLinearMap /-
/-- If `g` is a multilinear map and `f` is a collection of linear maps,
then `g (f₁ m₁, ..., fₙ mₙ)` is again a multilinear map, that we call
`g.comp_linear_map f`. -/
def compLinearMap (g : MultilinearMap R M₁' M₂) (f : ∀ i, M₁ i →ₗ[R] M₁' i) : MultilinearMap R M₁ M₂
    where
  toFun m := g fun i => f i (m i)
  map_add' _ m i x y := by
    skip
    have : ∀ j z, f j (update m i z j) = update (fun k => f k (m k)) i (f i z) j := fun j z =>
      Function.apply_update (fun k => f k) _ _ _ _
    · simp [this]
  map_smul' _ m i c x := by
    skip
    have : ∀ j z, f j (update m i z j) = update (fun k => f k (m k)) i (f i z) j := fun j z =>
      Function.apply_update (fun k => f k) _ _ _ _
    · simp [this]
#align multilinear_map.comp_linear_map MultilinearMap.compLinearMap
-/

#print MultilinearMap.compLinearMap_apply /-
@[simp]
theorem compLinearMap_apply (g : MultilinearMap R M₁' M₂) (f : ∀ i, M₁ i →ₗ[R] M₁' i)
    (m : ∀ i, M₁ i) : g.compLinearMap f m = g fun i => f i (m i) :=
  rfl
#align multilinear_map.comp_linear_map_apply MultilinearMap.compLinearMap_apply
-/

#print MultilinearMap.compLinearMap_assoc /-
/-- Composing a multilinear map twice with a linear map in each argument is
the same as composing with their composition. -/
theorem compLinearMap_assoc (g : MultilinearMap R M₁'' M₂) (f₁ : ∀ i, M₁' i →ₗ[R] M₁'' i)
    (f₂ : ∀ i, M₁ i →ₗ[R] M₁' i) :
    (g.compLinearMap f₁).compLinearMap f₂ = g.compLinearMap fun i => f₁ i ∘ₗ f₂ i :=
  rfl
#align multilinear_map.comp_linear_map_assoc MultilinearMap.compLinearMap_assoc
-/

#print MultilinearMap.zero_compLinearMap /-
/-- Composing the zero multilinear map with a linear map in each argument. -/
@[simp]
theorem zero_compLinearMap (f : ∀ i, M₁ i →ₗ[R] M₁' i) :
    (0 : MultilinearMap R M₁' M₂).compLinearMap f = 0 :=
  ext fun _ => rfl
#align multilinear_map.zero_comp_linear_map MultilinearMap.zero_compLinearMap
-/

#print MultilinearMap.compLinearMap_id /-
/-- Composing a multilinear map with the identity linear map in each argument. -/
@[simp]
theorem compLinearMap_id (g : MultilinearMap R M₁' M₂) :
    (g.compLinearMap fun i => LinearMap.id) = g :=
  ext fun _ => rfl
#align multilinear_map.comp_linear_map_id MultilinearMap.compLinearMap_id
-/

#print MultilinearMap.compLinearMap_injective /-
/-- Composing with a family of surjective linear maps is injective. -/
theorem compLinearMap_injective (f : ∀ i, M₁ i →ₗ[R] M₁' i) (hf : ∀ i, Surjective (f i)) :
    Injective fun g : MultilinearMap R M₁' M₂ => g.compLinearMap f := fun g₁ g₂ h =>
  ext fun x => by
    simpa [fun i => surj_inv_eq (hf i)] using ext_iff.mp h fun i => surj_inv (hf i) (x i)
#align multilinear_map.comp_linear_map_injective MultilinearMap.compLinearMap_injective
-/

#print MultilinearMap.compLinearMap_inj /-
theorem compLinearMap_inj (f : ∀ i, M₁ i →ₗ[R] M₁' i) (hf : ∀ i, Surjective (f i))
    (g₁ g₂ : MultilinearMap R M₁' M₂) : g₁.compLinearMap f = g₂.compLinearMap f ↔ g₁ = g₂ :=
  (compLinearMap_injective _ hf).eq_iff
#align multilinear_map.comp_linear_map_inj MultilinearMap.compLinearMap_inj
-/

#print MultilinearMap.comp_linearEquiv_eq_zero_iff /-
/-- Composing a multilinear map with a linear equiv on each argument gives the zero map
if and only if the multilinear map is the zero map. -/
@[simp]
theorem comp_linearEquiv_eq_zero_iff (g : MultilinearMap R M₁' M₂) (f : ∀ i, M₁ i ≃ₗ[R] M₁' i) :
    (g.compLinearMap fun i => (f i : M₁ i →ₗ[R] M₁' i)) = 0 ↔ g = 0 :=
  by
  set f' := fun i => (f i : M₁ i →ₗ[R] M₁' i)
  rw [← zero_comp_linear_map f', comp_linear_map_inj f' fun i => (f i).Surjective]
#align multilinear_map.comp_linear_equiv_eq_zero_iff MultilinearMap.comp_linearEquiv_eq_zero_iff
-/

end

#print MultilinearMap.map_piecewise_add /-
/-- If one adds to a vector `m'` another vector `m`, but only for coordinates in a finset `t`, then
the image under a multilinear map `f` is the sum of `f (s.piecewise m m')` along all subsets `s` of
`t`. This is mainly an auxiliary statement to prove the result when `t = univ`, given in
`map_add_univ`, although it can be useful in its own right as it does not require the index set `ι`
to be finite.-/
theorem map_piecewise_add [DecidableEq ι] (m m' : ∀ i, M₁ i) (t : Finset ι) :
    f (t.piecewise (m + m') m') = ∑ s in t.powerset, f (s.piecewise m m') :=
  by
  revert m'
  refine' Finset.induction_on t (by simp) _
  intro i t hit Hrec m'
  have A : (insert i t).piecewise (m + m') m' = update (t.piecewise (m + m') m') i (m i + m' i) :=
    t.piecewise_insert _ _ _
  have B : update (t.piecewise (m + m') m') i (m' i) = t.piecewise (m + m') m' :=
    by
    ext j
    by_cases h : j = i
    · rw [h]; simp [hit]
    · simp [h]
  let m'' := update m' i (m i)
  have C : update (t.piecewise (m + m') m') i (m i) = t.piecewise (m + m'') m'' :=
    by
    ext j
    by_cases h : j = i
    · rw [h]; simp [m'', hit]
    · by_cases h' : j ∈ t <;> simp [h, hit, m'', h']
  rw [A, f.map_add, B, C, Finset.sum_powerset_insert hit, Hrec, Hrec, add_comm]
  congr 1
  apply Finset.sum_congr rfl fun s hs => _
  have : (insert i s).piecewise m m' = s.piecewise m m'' :=
    by
    ext j
    by_cases h : j = i
    · rw [h]; simp [m'', Finset.not_mem_of_mem_powerset_of_not_mem hs hit]
    · by_cases h' : j ∈ s <;> simp [h, m'', h']
  rw [this]
#align multilinear_map.map_piecewise_add MultilinearMap.map_piecewise_add
-/

#print MultilinearMap.map_add_univ /-
/-- Additivity of a multilinear map along all coordinates at the same time,
writing `f (m + m')` as the sum  of `f (s.piecewise m m')` over all sets `s`. -/
theorem map_add_univ [DecidableEq ι] [Fintype ι] (m m' : ∀ i, M₁ i) :
    f (m + m') = ∑ s : Finset ι, f (s.piecewise m m') := by
  simpa using f.map_piecewise_add m m' Finset.univ
#align multilinear_map.map_add_univ MultilinearMap.map_add_univ
-/

section ApplySum

variable {α : ι → Type _} (g : ∀ i, α i → M₁ i) (A : ∀ i, Finset (α i))

open Fintype Finset

#print MultilinearMap.map_sum_finset_aux /-
/-- If `f` is multilinear, then `f (Σ_{j₁ ∈ A₁} g₁ j₁, ..., Σ_{jₙ ∈ Aₙ} gₙ jₙ)` is the sum of
`f (g₁ (r 1), ..., gₙ (r n))` where `r` ranges over all functions with `r 1 ∈ A₁`, ...,
`r n ∈ Aₙ`. This follows from multilinearity by expanding successively with respect to each
coordinate. Here, we give an auxiliary statement tailored for an inductive proof. Use instead
`map_sum_finset`. -/
theorem map_sum_finset_aux [DecidableEq ι] [Fintype ι] {n : ℕ} (h : ∑ i, (A i).card = n) :
    (f fun i => ∑ j in A i, g i j) = ∑ r in piFinset A, f fun i => g i (r i) :=
  by
  letI := fun i => Classical.decEq (α i)
  induction' n using Nat.strong_induction_on with n IH generalizing A
  -- If one of the sets is empty, then all the sums are zero
  by_cases Ai_empty : ∃ i, A i = ∅
  · rcases Ai_empty with ⟨i, hi⟩
    have : ∑ j in A i, g i j = 0 := by rw [hi, Finset.sum_empty]
    rw [f.map_coord_zero i this]
    have : pi_finset A = ∅ :=
      by
      apply Finset.eq_empty_of_forall_not_mem fun r hr => _
      have : r i ∈ A i := mem_pi_finset.mp hr i
      rwa [hi] at this 
    rw [this, Finset.sum_empty]
  push_neg at Ai_empty 
  -- Otherwise, if all sets are at most singletons, then they are exactly singletons and the result
  -- is again straightforward
  by_cases Ai_singleton : ∀ i, (A i).card ≤ 1
  · have Ai_card : ∀ i, (A i).card = 1 := by
      intro i
      have pos : Finset.card (A i) ≠ 0 := by simp [Finset.card_eq_zero, Ai_empty i]
      have : Finset.card (A i) ≤ 1 := Ai_singleton i
      exact le_antisymm this (Nat.succ_le_of_lt (_root_.pos_iff_ne_zero.mpr Pos))
    have :
      ∀ r : ∀ i, α i, r ∈ pi_finset A → (f fun i => g i (r i)) = f fun i => ∑ j in A i, g i j :=
      by
      intro r hr
      unfold_coes
      congr with i
      have : ∀ j ∈ A i, g i j = g i (r i) := by
        intro j hj
        congr
        apply Finset.card_le_one_iff.1 (Ai_singleton i) hj
        exact mem_pi_finset.mp hr i
      simp only [Finset.sum_congr rfl this, Finset.mem_univ, Finset.sum_const, Ai_card i, one_nsmul]
    simp only [sum_congr rfl this, Ai_card, card_pi_finset, prod_const_one, one_nsmul,
      Finset.sum_const]
  -- Remains the interesting case where one of the `A i`, say `A i₀`, has cardinality at least 2.
  -- We will split into two parts `B i₀` and `C i₀` of smaller cardinality, let `B i = C i = A i`
  -- for `i ≠ i₀`, apply the inductive assumption to `B` and `C`, and add up the corresponding
  -- parts to get the sum for `A`.
  push_neg at Ai_singleton 
  obtain ⟨i₀, hi₀⟩ : ∃ i, 1 < (A i).card := Ai_singleton
  obtain ⟨j₁, j₂, hj₁, hj₂, j₁_ne_j₂⟩ : ∃ j₁ j₂, j₁ ∈ A i₀ ∧ j₂ ∈ A i₀ ∧ j₁ ≠ j₂ :=
    Finset.one_lt_card_iff.1 hi₀
  let B := Function.update A i₀ (A i₀ \ {j₂})
  let C := Function.update A i₀ {j₂}
  have B_subset_A : ∀ i, B i ⊆ A i := by
    intro i
    by_cases hi : i = i₀
    · rw [hi]; simp only [B, sdiff_subset, update_same]
    · simp only [hi, B, update_noteq, Ne.def, not_false_iff, Finset.Subset.refl]
  have C_subset_A : ∀ i, C i ⊆ A i := by
    intro i
    by_cases hi : i = i₀
    · rw [hi]; simp only [C, hj₂, Finset.singleton_subset_iff, update_same]
    · simp only [hi, C, update_noteq, Ne.def, not_false_iff, Finset.Subset.refl]
  -- split the sum at `i₀` as the sum over `B i₀` plus the sum over `C i₀`, to use additivity.
  have A_eq_BC :
    (fun i => ∑ j in A i, g i j) =
      Function.update (fun i => ∑ j in A i, g i j) i₀ (∑ j in B i₀, g i₀ j + ∑ j in C i₀, g i₀ j) :=
    by
    ext i
    by_cases hi : i = i₀
    · rw [hi]
      simp only [Function.update_same]
      have : A i₀ = B i₀ ∪ C i₀ :=
        by
        simp only [B, C, Function.update_same, Finset.sdiff_union_self_eq_union]
        symm
        simp only [hj₂, Finset.singleton_subset_iff, Finset.union_eq_left_iff_subset]
      rw [this]
      apply Finset.sum_union
      apply Finset.disjoint_right.2 fun j hj => _
      have : j = j₂ := by dsimp [C] at hj ; simpa using hj
      rw [this]
      dsimp [B]
      simp only [mem_sdiff, eq_self_iff_true, not_true, not_false_iff, Finset.mem_singleton,
        update_same, and_false_iff]
    · simp [hi]
  have Beq :
    Function.update (fun i => ∑ j in A i, g i j) i₀ (∑ j in B i₀, g i₀ j) = fun i =>
      ∑ j in B i, g i j :=
    by
    ext i
    by_cases hi : i = i₀
    · rw [hi]; simp only [update_same]
    · simp only [hi, B, update_noteq, Ne.def, not_false_iff]
  have Ceq :
    Function.update (fun i => ∑ j in A i, g i j) i₀ (∑ j in C i₀, g i₀ j) = fun i =>
      ∑ j in C i, g i j :=
    by
    ext i
    by_cases hi : i = i₀
    · rw [hi]; simp only [update_same]
    · simp only [hi, C, update_noteq, Ne.def, not_false_iff]
  -- Express the inductive assumption for `B`
  have Brec : (f fun i => ∑ j in B i, g i j) = ∑ r in pi_finset B, f fun i => g i (r i) :=
    by
    have : ∑ i, Finset.card (B i) < ∑ i, Finset.card (A i) :=
      by
      refine'
        Finset.sum_lt_sum (fun i hi => Finset.card_le_of_subset (B_subset_A i))
          ⟨i₀, Finset.mem_univ _, _⟩
      have : {j₂} ⊆ A i₀ := by simp [hj₂]
      simp only [B, Finset.card_sdiff this, Function.update_same, Finset.card_singleton]
      exact Nat.pred_lt (ne_of_gt (lt_trans Nat.zero_lt_one hi₀))
    rw [h] at this 
    exact IH _ this B rfl
  -- Express the inductive assumption for `C`
  have Crec : (f fun i => ∑ j in C i, g i j) = ∑ r in pi_finset C, f fun i => g i (r i) :=
    by
    have : ∑ i, Finset.card (C i) < ∑ i, Finset.card (A i) :=
      Finset.sum_lt_sum (fun i hi => Finset.card_le_of_subset (C_subset_A i))
        ⟨i₀, Finset.mem_univ _, by simp [C, hi₀]⟩
    rw [h] at this 
    exact IH _ this C rfl
  have D : Disjoint (pi_finset B) (pi_finset C) :=
    haveI : Disjoint (B i₀) (C i₀) := by simp [B, C]
    pi_finset_disjoint_of_disjoint B C this
  have pi_BC : pi_finset A = pi_finset B ∪ pi_finset C :=
    by
    apply Finset.Subset.antisymm
    · intro r hr
      by_cases hri₀ : r i₀ = j₂
      · apply Finset.mem_union_right
        apply mem_pi_finset.2 fun i => _
        by_cases hi : i = i₀
        · have : r i₀ ∈ C i₀ := by simp [C, hri₀]
          convert this
        · simp [C, hi, mem_pi_finset.1 hr i]
      · apply Finset.mem_union_left
        apply mem_pi_finset.2 fun i => _
        by_cases hi : i = i₀
        · have : r i₀ ∈ B i₀ := by simp [B, hri₀, mem_pi_finset.1 hr i₀]
          convert this
        · simp [B, hi, mem_pi_finset.1 hr i]
    ·
      exact
        Finset.union_subset (pi_finset_subset _ _ fun i => B_subset_A i)
          (pi_finset_subset _ _ fun i => C_subset_A i)
  rw [A_eq_BC]
  simp only [MultilinearMap.map_add, Beq, Ceq, Brec, Crec, pi_BC]
  rw [← Finset.sum_union D]
#align multilinear_map.map_sum_finset_aux MultilinearMap.map_sum_finset_aux
-/

#print MultilinearMap.map_sum_finset /-
/-- If `f` is multilinear, then `f (Σ_{j₁ ∈ A₁} g₁ j₁, ..., Σ_{jₙ ∈ Aₙ} gₙ jₙ)` is the sum of
`f (g₁ (r 1), ..., gₙ (r n))` where `r` ranges over all functions with `r 1 ∈ A₁`, ...,
`r n ∈ Aₙ`. This follows from multilinearity by expanding successively with respect to each
coordinate. -/
theorem map_sum_finset [DecidableEq ι] [Fintype ι] :
    (f fun i => ∑ j in A i, g i j) = ∑ r in piFinset A, f fun i => g i (r i) :=
  f.map_sum_finset_aux _ _ rfl
#align multilinear_map.map_sum_finset MultilinearMap.map_sum_finset
-/

#print MultilinearMap.map_sum /-
/-- If `f` is multilinear, then `f (Σ_{j₁} g₁ j₁, ..., Σ_{jₙ} gₙ jₙ)` is the sum of
`f (g₁ (r 1), ..., gₙ (r n))` where `r` ranges over all functions `r`. This follows from
multilinearity by expanding successively with respect to each coordinate. -/
theorem map_sum [DecidableEq ι] [Fintype ι] [∀ i, Fintype (α i)] :
    (f fun i => ∑ j, g i j) = ∑ r : ∀ i, α i, f fun i => g i (r i) :=
  f.map_sum_finset g fun i => Finset.univ
#align multilinear_map.map_sum MultilinearMap.map_sum
-/

#print MultilinearMap.map_update_sum /-
theorem map_update_sum {α : Type _} [DecidableEq ι] (t : Finset α) (i : ι) (g : α → M₁ i)
    (m : ∀ i, M₁ i) : f (update m i (∑ a in t, g a)) = ∑ a in t, f (update m i (g a)) := by
  classical
  induction' t using Finset.induction with a t has ih h
  · simp
  · simp [Finset.sum_insert has, ih]
#align multilinear_map.map_update_sum MultilinearMap.map_update_sum
-/

end ApplySum

#print MultilinearMap.codRestrict /-
/-- Restrict the codomain of a multilinear map to a submodule.

This is the multilinear version of `linear_map.cod_restrict`. -/
@[simps]
def codRestrict (f : MultilinearMap R M₁ M₂) (p : Submodule R M₂) (h : ∀ v, f v ∈ p) :
    MultilinearMap R M₁ p where
  toFun v := ⟨f v, h v⟩
  map_add' _ v i x y := Subtype.ext <| MultilinearMap.map_add _ _ _ _ _
  map_smul' _ v i c x := Subtype.ext <| MultilinearMap.map_smul _ _ _ _ _
#align multilinear_map.cod_restrict MultilinearMap.codRestrict
-/

section RestrictScalar

variable (R) {A : Type _} [Semiring A] [SMul R A] [∀ i : ι, Module A (M₁ i)] [Module A M₂]
  [∀ i, IsScalarTower R A (M₁ i)] [IsScalarTower R A M₂]

#print MultilinearMap.restrictScalars /-
/-- Reinterpret an `A`-multilinear map as an `R`-multilinear map, if `A` is an algebra over `R`
and their actions on all involved modules agree with the action of `R` on `A`. -/
def restrictScalars (f : MultilinearMap A M₁ M₂) : MultilinearMap R M₁ M₂
    where
  toFun := f
  map_add' _ := f.map_add
  map_smul' _ m i := (f.to_linear_map m i).map_smul_of_tower
#align multilinear_map.restrict_scalars MultilinearMap.restrictScalars
-/

#print MultilinearMap.coe_restrictScalars /-
@[simp]
theorem coe_restrictScalars (f : MultilinearMap A M₁ M₂) : ⇑(f.restrictScalars R) = f :=
  rfl
#align multilinear_map.coe_restrict_scalars MultilinearMap.coe_restrictScalars
-/

end RestrictScalar

section

variable {ι₁ ι₂ ι₃ : Type _}

#print MultilinearMap.domDomCongr /-
/-- Transfer the arguments to a map along an equivalence between argument indices.

The naming is derived from `finsupp.dom_congr`, noting that here the permutation applies to the
domain of the domain. -/
@[simps apply]
def domDomCongr (σ : ι₁ ≃ ι₂) (m : MultilinearMap R (fun i : ι₁ => M₂) M₃) :
    MultilinearMap R (fun i : ι₂ => M₂) M₃
    where
  toFun v := m fun i => v (σ i)
  map_add' _ v i a b := by
    skip; letI := σ.injective.decidable_eq
    simp_rw [Function.update_apply_equiv_apply v]; rw [m.map_add]
  map_smul' _ v i a b := by
    skip; letI := σ.injective.decidable_eq
    simp_rw [Function.update_apply_equiv_apply v]; rw [m.map_smul]
#align multilinear_map.dom_dom_congr MultilinearMap.domDomCongr
-/

#print MultilinearMap.domDomCongr_trans /-
theorem domDomCongr_trans (σ₁ : ι₁ ≃ ι₂) (σ₂ : ι₂ ≃ ι₃)
    (m : MultilinearMap R (fun i : ι₁ => M₂) M₃) :
    m.domDomCongr (σ₁.trans σ₂) = (m.domDomCongr σ₁).domDomCongr σ₂ :=
  rfl
#align multilinear_map.dom_dom_congr_trans MultilinearMap.domDomCongr_trans
-/

#print MultilinearMap.domDomCongr_mul /-
theorem domDomCongr_mul (σ₁ : Equiv.Perm ι₁) (σ₂ : Equiv.Perm ι₁)
    (m : MultilinearMap R (fun i : ι₁ => M₂) M₃) :
    m.domDomCongr (σ₂ * σ₁) = (m.domDomCongr σ₁).domDomCongr σ₂ :=
  rfl
#align multilinear_map.dom_dom_congr_mul MultilinearMap.domDomCongr_mul
-/

#print MultilinearMap.domDomCongrEquiv /-
/-- `multilinear_map.dom_dom_congr` as an equivalence.

This is declared separately because it does not work with dot notation. -/
@[simps apply symm_apply]
def domDomCongrEquiv (σ : ι₁ ≃ ι₂) :
    MultilinearMap R (fun i : ι₁ => M₂) M₃ ≃+ MultilinearMap R (fun i : ι₂ => M₂) M₃
    where
  toFun := domDomCongr σ
  invFun := domDomCongr σ.symm
  left_inv m := by ext; simp
  right_inv m := by ext; simp
  map_add' a b := by ext; simp
#align multilinear_map.dom_dom_congr_equiv MultilinearMap.domDomCongrEquiv
-/

#print MultilinearMap.domDomCongr_eq_iff /-
/-- The results of applying `dom_dom_congr` to two maps are equal if
and only if those maps are. -/
@[simp]
theorem domDomCongr_eq_iff (σ : ι₁ ≃ ι₂) (f g : MultilinearMap R (fun i : ι₁ => M₂) M₃) :
    f.domDomCongr σ = g.domDomCongr σ ↔ f = g :=
  (domDomCongrEquiv σ : _ ≃+ MultilinearMap R (fun i => M₂) M₃).apply_eq_iff_eq
#align multilinear_map.dom_dom_congr_eq_iff MultilinearMap.domDomCongr_eq_iff
-/

end

end Semiring

end MultilinearMap

namespace LinearMap

variable [Semiring R] [∀ i, AddCommMonoid (M₁ i)] [AddCommMonoid M₂] [AddCommMonoid M₃]
  [AddCommMonoid M'] [∀ i, Module R (M₁ i)] [Module R M₂] [Module R M₃] [Module R M']

#print LinearMap.compMultilinearMap /-
/-- Composing a multilinear map with a linear map gives again a multilinear map. -/
def compMultilinearMap (g : M₂ →ₗ[R] M₃) (f : MultilinearMap R M₁ M₂) : MultilinearMap R M₁ M₃
    where
  toFun := g ∘ f
  map_add' m i x y := by simp
  map_smul' m i c x := by simp
#align linear_map.comp_multilinear_map LinearMap.compMultilinearMap
-/

#print LinearMap.coe_compMultilinearMap /-
@[simp]
theorem coe_compMultilinearMap (g : M₂ →ₗ[R] M₃) (f : MultilinearMap R M₁ M₂) :
    ⇑(g.compMultilinearMap f) = g ∘ f :=
  rfl
#align linear_map.coe_comp_multilinear_map LinearMap.coe_compMultilinearMap
-/

#print LinearMap.compMultilinearMap_apply /-
@[simp]
theorem compMultilinearMap_apply (g : M₂ →ₗ[R] M₃) (f : MultilinearMap R M₁ M₂) (m : ∀ i, M₁ i) :
    g.compMultilinearMap f m = g (f m) :=
  rfl
#align linear_map.comp_multilinear_map_apply LinearMap.compMultilinearMap_apply
-/

#print LinearMap.subtype_compMultilinearMap_codRestrict /-
/-- The multilinear version of `linear_map.subtype_comp_cod_restrict` -/
@[simp]
theorem subtype_compMultilinearMap_codRestrict (f : MultilinearMap R M₁ M₂) (p : Submodule R M₂)
    (h) : p.Subtype.compMultilinearMap (f.codRestrict p h) = f :=
  MultilinearMap.ext fun v => rfl
#align linear_map.subtype_comp_multilinear_map_cod_restrict LinearMap.subtype_compMultilinearMap_codRestrict
-/

#print LinearMap.compMultilinearMap_codRestrict /-
/-- The multilinear version of `linear_map.comp_cod_restrict` -/
@[simp]
theorem compMultilinearMap_codRestrict (g : M₂ →ₗ[R] M₃) (f : MultilinearMap R M₁ M₂)
    (p : Submodule R M₃) (h) :
    (g.codRestrict p h).compMultilinearMap f =
      (g.compMultilinearMap f).codRestrict p fun v => h (f v) :=
  MultilinearMap.ext fun v => rfl
#align linear_map.comp_multilinear_map_cod_restrict LinearMap.compMultilinearMap_codRestrict
-/

variable {ι₁ ι₂ : Type _}

#print LinearMap.compMultilinearMap_domDomCongr /-
@[simp]
theorem compMultilinearMap_domDomCongr (σ : ι₁ ≃ ι₂) (g : M₂ →ₗ[R] M₃)
    (f : MultilinearMap R (fun i : ι₁ => M') M₂) :
    (g.compMultilinearMap f).domDomCongr σ = g.compMultilinearMap (f.domDomCongr σ) := by ext; simp
#align linear_map.comp_multilinear_map_dom_dom_congr LinearMap.compMultilinearMap_domDomCongr
-/

end LinearMap

namespace MultilinearMap

section CommSemiring

variable [CommSemiring R] [∀ i, AddCommMonoid (M₁ i)] [∀ i, AddCommMonoid (M i)] [AddCommMonoid M₂]
  [∀ i, Module R (M i)] [∀ i, Module R (M₁ i)] [Module R M₂] (f f' : MultilinearMap R M₁ M₂)

#print MultilinearMap.map_piecewise_smul /-
/-- If one multiplies by `c i` the coordinates in a finset `s`, then the image under a multilinear
map is multiplied by `∏ i in s, c i`. This is mainly an auxiliary statement to prove the result when
`s = univ`, given in `map_smul_univ`, although it can be useful in its own right as it does not
require the index set `ι` to be finite. -/
theorem map_piecewise_smul [DecidableEq ι] (c : ι → R) (m : ∀ i, M₁ i) (s : Finset ι) :
    f (s.piecewise (fun i => c i • m i) m) = (∏ i in s, c i) • f m :=
  by
  refine' s.induction_on (by simp) _
  intro j s j_not_mem_s Hrec
  have A :
    Function.update (s.piecewise (fun i => c i • m i) m) j (m j) =
      s.piecewise (fun i => c i • m i) m :=
    by
    ext i
    by_cases h : i = j
    · rw [h]; simp [j_not_mem_s]
    · simp [h]
  rw [s.piecewise_insert, f.map_smul, A, Hrec]
  simp [j_not_mem_s, mul_smul]
#align multilinear_map.map_piecewise_smul MultilinearMap.map_piecewise_smul
-/

#print MultilinearMap.map_smul_univ /-
/-- Multiplicativity of a multilinear map along all coordinates at the same time,
writing `f (λi, c i • m i)` as `(∏ i, c i) • f m`. -/
theorem map_smul_univ [Fintype ι] (c : ι → R) (m : ∀ i, M₁ i) :
    (f fun i => c i • m i) = (∏ i, c i) • f m := by
  classical simpa using map_piecewise_smul f c m Finset.univ
#align multilinear_map.map_smul_univ MultilinearMap.map_smul_univ
-/

#print MultilinearMap.map_update_smul /-
@[simp]
theorem map_update_smul [DecidableEq ι] [Fintype ι] (m : ∀ i, M₁ i) (i : ι) (c : R) (x : M₁ i) :
    f (update (c • m) i x) = c ^ (Fintype.card ι - 1) • f (update m i x) :=
  by
  have :
    f ((finset.univ.erase i).piecewise (c • update m i x) (update m i x)) =
      (∏ i in finset.univ.erase i, c) • f (update m i x) :=
    map_piecewise_smul f _ _ _
  simpa [← Function.update_smul c m] using this
#align multilinear_map.map_update_smul MultilinearMap.map_update_smul
-/

section DistribMulAction

variable {R' A : Type _} [Monoid R'] [Semiring A] [∀ i, Module A (M₁ i)] [DistribMulAction R' M₂]
  [Module A M₂] [SMulCommClass A R' M₂]

instance : DistribMulAction R' (MultilinearMap A M₁ M₂)
    where
  one_smul f := ext fun x => one_smul _ _
  mul_smul c₁ c₂ f := ext fun x => mul_smul _ _ _
  smul_zero r := ext fun x => smul_zero _
  smul_add r f₁ f₂ := ext fun x => smul_add _ _ _

end DistribMulAction

section Module

variable {R' A : Type _} [Semiring R'] [Semiring A] [∀ i, Module A (M₁ i)] [Module A M₂]
  [AddCommMonoid M₃] [Module R' M₃] [Module A M₃] [SMulCommClass A R' M₃]

/-- The space of multilinear maps over an algebra over `R` is a module over `R`, for the pointwise
addition and scalar multiplication. -/
instance [Module R' M₂] [SMulCommClass A R' M₂] : Module R' (MultilinearMap A M₁ M₂)
    where
  add_smul r₁ r₂ f := ext fun x => add_smul _ _ _
  zero_smul f := ext fun x => zero_smul _ _

instance [NoZeroSMulDivisors R' M₃] : NoZeroSMulDivisors R' (MultilinearMap A M₁ M₃) :=
  coe_injective.NoZeroSMulDivisors _ rfl coe_smul

variable (M₂ M₃ R' A)

#print MultilinearMap.domDomCongrLinearEquiv /-
/-- `multilinear_map.dom_dom_congr` as a `linear_equiv`. -/
@[simps apply symm_apply]
def domDomCongrLinearEquiv {ι₁ ι₂} (σ : ι₁ ≃ ι₂) :
    MultilinearMap A (fun i : ι₁ => M₂) M₃ ≃ₗ[R'] MultilinearMap A (fun i : ι₂ => M₂) M₃ :=
  {
    (domDomCongrEquiv σ :
      MultilinearMap A (fun i : ι₁ => M₂) M₃ ≃+ MultilinearMap A (fun i : ι₂ => M₂) M₃) with
    map_smul' := fun c f => by ext; simp }
#align multilinear_map.dom_dom_congr_linear_equiv MultilinearMap.domDomCongrLinearEquiv
-/

variable (R M₁)

#print MultilinearMap.domDomCongrLinearEquiv' /-
/-- The dependent version of `multilinear_map.dom_dom_congr_linear_equiv`. -/
@[simps apply symm_apply]
def domDomCongrLinearEquiv' {ι' : Type _} (σ : ι ≃ ι') :
    MultilinearMap R M₁ M₂ ≃ₗ[R] MultilinearMap R (fun i => M₁ (σ.symm i)) M₂
    where
  toFun f :=
    { toFun := f ∘ (σ.piCongrLeft' M₁).symm
      map_add' := fun _ m i => by
        skip
        letI := σ.decidable_eq
        rw [← σ.apply_symm_apply i]
        intro x y
        simp only [comp_app, Pi_congr_left'_symm_update, f.map_add]
      map_smul' := fun _ m i c => by
        skip
        letI := σ.decidable_eq
        rw [← σ.apply_symm_apply i]
        intro x
        simp only [comp_app, Pi_congr_left'_symm_update, f.map_smul] }
  invFun f :=
    { toFun := f ∘ σ.piCongrLeft' M₁
      map_add' := fun _ m i => by
        skip
        letI := σ.symm.decidable_eq
        rw [← σ.symm_apply_apply i]
        intro x y
        simp only [comp_app, Pi_congr_left'_update, f.map_add]
      map_smul' := fun _ m i c => by
        skip
        letI := σ.symm.decidable_eq
        rw [← σ.symm_apply_apply i]
        intro x
        simp only [comp_app, Pi_congr_left'_update, f.map_smul] }
  map_add' f₁ f₂ := by ext; simp only [comp_app, coe_mk, add_apply]
  map_smul' c f := by ext; simp only [comp_app, coe_mk, smul_apply, RingHom.id_apply]
  left_inv f := by ext; simp only [comp_app, coe_mk, Equiv.symm_apply_apply]
  right_inv f := by ext; simp only [comp_app, coe_mk, Equiv.apply_symm_apply]
#align multilinear_map.dom_dom_congr_linear_equiv' MultilinearMap.domDomCongrLinearEquiv'
-/

#print MultilinearMap.constLinearEquivOfIsEmpty /-
/-- The space of constant maps is equivalent to the space of maps that are multilinear with respect
to an empty family. -/
@[simps]
def constLinearEquivOfIsEmpty [IsEmpty ι] : M₂ ≃ₗ[R] MultilinearMap R M₁ M₂
    where
  toFun := MultilinearMap.constOfIsEmpty R _
  map_add' x y := rfl
  map_smul' t x := rfl
  invFun f := f 0
  left_inv _ := rfl
  right_inv f := ext fun x => MultilinearMap.congr_arg f <| Subsingleton.elim _ _
#align multilinear_map.const_linear_equiv_of_is_empty MultilinearMap.constLinearEquivOfIsEmpty
-/

end Module

section

variable (R ι) (A : Type _) [CommSemiring A] [Algebra R A] [Fintype ι]

#print MultilinearMap.mkPiAlgebra /-
/-- Given an `R`-algebra `A`, `mk_pi_algebra` is the multilinear map on `A^ι` associating
to `m` the product of all the `m i`.

See also `multilinear_map.mk_pi_algebra_fin` for a version that works with a non-commutative
algebra `A` but requires `ι = fin n`. -/
protected def mkPiAlgebra : MultilinearMap R (fun i : ι => A) A
    where
  toFun m := ∏ i, m i
  map_add' m i x y := by simp [Finset.prod_update_of_mem, add_mul]
  map_smul' m i c x := by simp [Finset.prod_update_of_mem]
#align multilinear_map.mk_pi_algebra MultilinearMap.mkPiAlgebra
-/

variable {R A ι}

#print MultilinearMap.mkPiAlgebra_apply /-
@[simp]
theorem mkPiAlgebra_apply (m : ι → A) : MultilinearMap.mkPiAlgebra R ι A m = ∏ i, m i :=
  rfl
#align multilinear_map.mk_pi_algebra_apply MultilinearMap.mkPiAlgebra_apply
-/

end

section

variable (R n) (A : Type _) [Semiring A] [Algebra R A]

#print MultilinearMap.mkPiAlgebraFin /-
/-- Given an `R`-algebra `A`, `mk_pi_algebra_fin` is the multilinear map on `A^n` associating
to `m` the product of all the `m i`.

See also `multilinear_map.mk_pi_algebra` for a version that assumes `[comm_semiring A]` but works
for `A^ι` with any finite type `ι`. -/
protected def mkPiAlgebraFin : MultilinearMap R (fun i : Fin n => A) A
    where
  toFun m := (List.ofFn m).Prod
  map_add' := by
    intro dec m i x y
    rw [Subsingleton.elim dec (by infer_instance)]
    have : (List.finRange n).indexOfₓ i < n := by
      simpa using List.indexOf_lt_length.2 (List.mem_finRange i)
    simp [List.ofFn_eq_map, (List.nodup_finRange n).map_update, List.prod_set, add_mul, this,
      mul_add, add_mul]
  map_smul' := by
    intro dec m i c x
    rw [Subsingleton.elim dec (by infer_instance)]
    have : (List.finRange n).indexOfₓ i < n := by
      simpa using List.indexOf_lt_length.2 (List.mem_finRange i)
    simp [List.ofFn_eq_map, (List.nodup_finRange n).map_update, List.prod_set, this]
#align multilinear_map.mk_pi_algebra_fin MultilinearMap.mkPiAlgebraFin
-/

variable {R A n}

#print MultilinearMap.mkPiAlgebraFin_apply /-
@[simp]
theorem mkPiAlgebraFin_apply (m : Fin n → A) :
    MultilinearMap.mkPiAlgebraFin R n A m = (List.ofFn m).Prod :=
  rfl
#align multilinear_map.mk_pi_algebra_fin_apply MultilinearMap.mkPiAlgebraFin_apply
-/

#print MultilinearMap.mkPiAlgebraFin_apply_const /-
theorem mkPiAlgebraFin_apply_const (a : A) :
    (MultilinearMap.mkPiAlgebraFin R n A fun _ => a) = a ^ n := by simp
#align multilinear_map.mk_pi_algebra_fin_apply_const MultilinearMap.mkPiAlgebraFin_apply_const
-/

end

#print MultilinearMap.smulRight /-
/-- Given an `R`-multilinear map `f` taking values in `R`, `f.smul_right z` is the map
sending `m` to `f m • z`. -/
def smulRight (f : MultilinearMap R M₁ R) (z : M₂) : MultilinearMap R M₁ M₂ :=
  (LinearMap.smulRight LinearMap.id z).compMultilinearMap f
#align multilinear_map.smul_right MultilinearMap.smulRight
-/

#print MultilinearMap.smulRight_apply /-
@[simp]
theorem smulRight_apply (f : MultilinearMap R M₁ R) (z : M₂) (m : ∀ i, M₁ i) :
    f.smul_right z m = f m • z :=
  rfl
#align multilinear_map.smul_right_apply MultilinearMap.smulRight_apply
-/

variable (R ι)

#print MultilinearMap.mkPiRing /-
/-- The canonical multilinear map on `R^ι` when `ι` is finite, associating to `m` the product of
all the `m i` (multiplied by a fixed reference element `z` in the target module). See also
`mk_pi_algebra` for a more general version. -/
protected def mkPiRing [Fintype ι] (z : M₂) : MultilinearMap R (fun i : ι => R) M₂ :=
  (MultilinearMap.mkPiAlgebra R ι R).smul_right z
#align multilinear_map.mk_pi_ring MultilinearMap.mkPiRing
-/

variable {R ι}

#print MultilinearMap.mkPiRing_apply /-
@[simp]
theorem mkPiRing_apply [Fintype ι] (z : M₂) (m : ι → R) :
    (MultilinearMap.mkPiRing R ι z : (ι → R) → M₂) m = (∏ i, m i) • z :=
  rfl
#align multilinear_map.mk_pi_ring_apply MultilinearMap.mkPiRing_apply
-/

#print MultilinearMap.mkPiRing_apply_one_eq_self /-
theorem mkPiRing_apply_one_eq_self [Fintype ι] (f : MultilinearMap R (fun i : ι => R) M₂) :
    MultilinearMap.mkPiRing R ι (f fun i => 1) = f :=
  by
  ext m
  have : m = fun i => m i • 1 := by ext j; simp
  conv_rhs => rw [this, f.map_smul_univ]
  rfl
#align multilinear_map.mk_pi_ring_apply_one_eq_self MultilinearMap.mkPiRing_apply_one_eq_self
-/

#print MultilinearMap.mkPiRing_eq_iff /-
theorem mkPiRing_eq_iff [Fintype ι] {z₁ z₂ : M₂} :
    MultilinearMap.mkPiRing R ι z₁ = MultilinearMap.mkPiRing R ι z₂ ↔ z₁ = z₂ :=
  by
  simp_rw [MultilinearMap.ext_iff, mk_pi_ring_apply]
  constructor <;> intro h
  · simpa using h fun _ => 1
  · intro x; simp [h]
#align multilinear_map.mk_pi_ring_eq_iff MultilinearMap.mkPiRing_eq_iff
-/

#print MultilinearMap.mkPiRing_zero /-
theorem mkPiRing_zero [Fintype ι] : MultilinearMap.mkPiRing R ι (0 : M₂) = 0 := by
  ext <;> rw [mk_pi_ring_apply, smul_zero, MultilinearMap.zero_apply]
#align multilinear_map.mk_pi_ring_zero MultilinearMap.mkPiRing_zero
-/

#print MultilinearMap.mkPiRing_eq_zero_iff /-
theorem mkPiRing_eq_zero_iff [Fintype ι] (z : M₂) : MultilinearMap.mkPiRing R ι z = 0 ↔ z = 0 := by
  rw [← mk_pi_ring_zero, mk_pi_ring_eq_iff]
#align multilinear_map.mk_pi_ring_eq_zero_iff MultilinearMap.mkPiRing_eq_zero_iff
-/

end CommSemiring

section RangeAddCommGroup

variable [Semiring R] [∀ i, AddCommMonoid (M₁ i)] [AddCommGroup M₂] [∀ i, Module R (M₁ i)]
  [Module R M₂] (f g : MultilinearMap R M₁ M₂)

instance : Neg (MultilinearMap R M₁ M₂) :=
  ⟨fun f => ⟨fun m => -f m, fun _ m i x y => by simp [add_comm], fun _ m i c x => by simp⟩⟩

#print MultilinearMap.neg_apply /-
@[simp]
theorem neg_apply (m : ∀ i, M₁ i) : (-f) m = -f m :=
  rfl
#align multilinear_map.neg_apply MultilinearMap.neg_apply
-/

instance : Sub (MultilinearMap R M₁ M₂) :=
  ⟨fun f g =>
    ⟨fun m => f m - g m, fun _ m i x y => by
      simp only [MultilinearMap.map_add, sub_eq_add_neg, neg_add]; cc, fun _ m i c x => by
      simp only [MultilinearMap.map_smul, smul_sub]⟩⟩

#print MultilinearMap.sub_apply /-
@[simp]
theorem sub_apply (m : ∀ i, M₁ i) : (f - g) m = f m - g m :=
  rfl
#align multilinear_map.sub_apply MultilinearMap.sub_apply
-/

instance : AddCommGroup (MultilinearMap R M₁ M₂) :=
  {
    MultilinearMap.addCommMonoid with
    zero := (0 : MultilinearMap R M₁ M₂)
    add := (· + ·)
    neg := Neg.neg
    sub := Sub.sub
    add_left_neg := fun a => MultilinearMap.ext fun v => add_left_neg _
    sub_eq_add_neg := fun a b => MultilinearMap.ext fun v => sub_eq_add_neg _ _
    zsmul := fun n f =>
      { toFun := fun m => n • f m
        map_add' := fun _ m i x y => by simp [smul_add]
        map_smul' := fun _ l i x d => by simp [← smul_comm x n] }
    zsmul_zero' := fun a => MultilinearMap.ext fun v => AddCommGroup.zsmul_zero' _
    zsmul_succ' := fun z a => MultilinearMap.ext fun v => AddCommGroup.zsmul_succ' _ _
    zsmul_neg' := fun z a => MultilinearMap.ext fun v => AddCommGroup.zsmul_neg' _ _ }

end RangeAddCommGroup

section AddCommGroup

variable [Semiring R] [∀ i, AddCommGroup (M₁ i)] [AddCommGroup M₂] [∀ i, Module R (M₁ i)]
  [Module R M₂] (f : MultilinearMap R M₁ M₂)

#print MultilinearMap.map_neg /-
@[simp]
theorem map_neg [DecidableEq ι] (m : ∀ i, M₁ i) (i : ι) (x : M₁ i) :
    f (update m i (-x)) = -f (update m i x) :=
  eq_neg_of_add_eq_zero_left <| by
    rw [← MultilinearMap.map_add, add_left_neg, f.map_coord_zero i (update_same i 0 m)]
#align multilinear_map.map_neg MultilinearMap.map_neg
-/

#print MultilinearMap.map_sub /-
@[simp]
theorem map_sub [DecidableEq ι] (m : ∀ i, M₁ i) (i : ι) (x y : M₁ i) :
    f (update m i (x - y)) = f (update m i x) - f (update m i y) := by
  rw [sub_eq_add_neg, sub_eq_add_neg, MultilinearMap.map_add, map_neg]
#align multilinear_map.map_sub MultilinearMap.map_sub
-/

end AddCommGroup

section CommSemiring

variable [CommSemiring R] [∀ i, AddCommMonoid (M₁ i)] [AddCommMonoid M₂] [∀ i, Module R (M₁ i)]
  [Module R M₂]

#print MultilinearMap.piRingEquiv /-
/-- When `ι` is finite, multilinear maps on `R^ι` with values in `M₂` are in bijection with `M₂`,
as such a multilinear map is completely determined by its value on the constant vector made of ones.
We register this bijection as a linear equivalence in `multilinear_map.pi_ring_equiv`. -/
protected def piRingEquiv [Fintype ι] : M₂ ≃ₗ[R] MultilinearMap R (fun i : ι => R) M₂
    where
  toFun z := MultilinearMap.mkPiRing R ι z
  invFun f := f fun i => 1
  map_add' z z' := by ext m; simp [smul_add]
  map_smul' c z := by ext m; simp [smul_smul, mul_comm]
  left_inv z := by simp
  right_inv f := f.mkPiRing_apply_one_eq_self
#align multilinear_map.pi_ring_equiv MultilinearMap.piRingEquiv
-/

end CommSemiring

end MultilinearMap

section Currying

/-!
### Currying

We associate to a multilinear map in `n+1` variables (i.e., based on `fin n.succ`) two
curried functions, named `f.curry_left` (which is a linear map on `E 0` taking values
in multilinear maps in `n` variables) and `f.curry_right` (wich is a multilinear map in `n`
variables taking values in linear maps on `E 0`). In both constructions, the variable that is
singled out is `0`, to take advantage of the operations `cons` and `tail` on `fin n`.
The inverse operations are called `uncurry_left` and `uncurry_right`.

We also register linear equiv versions of these correspondences, in
`multilinear_curry_left_equiv` and `multilinear_curry_right_equiv`.
-/


open MultilinearMap

variable {R M M₂} [CommSemiring R] [∀ i, AddCommMonoid (M i)] [AddCommMonoid M'] [AddCommMonoid M₂]
  [∀ i, Module R (M i)] [Module R M'] [Module R M₂]

/-! #### Left currying -/


#print LinearMap.uncurryLeft /-
/-- Given a linear map `f` from `M 0` to multilinear maps on `n` variables,
construct the corresponding multilinear map on `n+1` variables obtained by concatenating
the variables, given by `m ↦ f (m 0) (tail m)`-/
def LinearMap.uncurryLeft (f : M 0 →ₗ[R] MultilinearMap R (fun i : Fin n => M i.succ) M₂) :
    MultilinearMap R M M₂ where
  toFun m := f (m 0) (tail m)
  map_add' dec m i x y := by
    rw [Subsingleton.elim dec (by infer_instance)]
    by_cases h : i = 0
    · subst i
      rw [update_same, update_same, update_same, f.map_add, add_apply, tail_update_zero,
        tail_update_zero, tail_update_zero]
    · rw [update_noteq (Ne.symm h), update_noteq (Ne.symm h), update_noteq (Ne.symm h)]
      revert x y
      rw [← succ_pred i h]
      intro x y
      rw [tail_update_succ, MultilinearMap.map_add, tail_update_succ, tail_update_succ]
  map_smul' dec m i c x := by
    rw [Subsingleton.elim dec (by infer_instance)]
    by_cases h : i = 0
    · subst i
      rw [update_same, update_same, tail_update_zero, tail_update_zero, ← smul_apply, f.map_smul]
    · rw [update_noteq (Ne.symm h), update_noteq (Ne.symm h)]
      revert x
      rw [← succ_pred i h]
      intro x
      rw [tail_update_succ, tail_update_succ, MultilinearMap.map_smul]
#align linear_map.uncurry_left LinearMap.uncurryLeft
-/

#print LinearMap.uncurryLeft_apply /-
@[simp]
theorem LinearMap.uncurryLeft_apply (f : M 0 →ₗ[R] MultilinearMap R (fun i : Fin n => M i.succ) M₂)
    (m : ∀ i, M i) : f.uncurryLeft m = f (m 0) (tail m) :=
  rfl
#align linear_map.uncurry_left_apply LinearMap.uncurryLeft_apply
-/

#print MultilinearMap.curryLeft /-
/-- Given a multilinear map `f` in `n+1` variables, split the first variable to obtain
a linear map into multilinear maps in `n` variables, given by `x ↦ (m ↦ f (cons x m))`. -/
def MultilinearMap.curryLeft (f : MultilinearMap R M M₂) :
    M 0 →ₗ[R] MultilinearMap R (fun i : Fin n => M i.succ) M₂
    where
  toFun x :=
    { toFun := fun m => f (cons x m)
      map_add' := fun dec m i y y' => by rw [Subsingleton.elim dec (by infer_instance)]; simp
      map_smul' := fun dec m i y c => by rw [Subsingleton.elim dec (by infer_instance)]; simp }
  map_add' x y := by ext m; exact cons_add f m x y
  map_smul' c x := by ext m; exact cons_smul f m c x
#align multilinear_map.curry_left MultilinearMap.curryLeft
-/

#print MultilinearMap.curryLeft_apply /-
@[simp]
theorem MultilinearMap.curryLeft_apply (f : MultilinearMap R M M₂) (x : M 0)
    (m : ∀ i : Fin n, M i.succ) : f.curryLeft x m = f (cons x m) :=
  rfl
#align multilinear_map.curry_left_apply MultilinearMap.curryLeft_apply
-/

#print LinearMap.curry_uncurryLeft /-
@[simp]
theorem LinearMap.curry_uncurryLeft
    (f : M 0 →ₗ[R] MultilinearMap R (fun i : Fin n => M i.succ) M₂) : f.uncurryLeft.curryLeft = f :=
  by
  ext m x
  simp only [tail_cons, LinearMap.uncurryLeft_apply, MultilinearMap.curryLeft_apply]
  rw [cons_zero]
#align linear_map.curry_uncurry_left LinearMap.curry_uncurryLeft
-/

#print MultilinearMap.uncurry_curryLeft /-
@[simp]
theorem MultilinearMap.uncurry_curryLeft (f : MultilinearMap R M M₂) :
    f.curryLeft.uncurryLeft = f := by ext m; simp
#align multilinear_map.uncurry_curry_left MultilinearMap.uncurry_curryLeft
-/

variable (R M M₂)

#print multilinearCurryLeftEquiv /-
/-- The space of multilinear maps on `Π(i : fin (n+1)), M i` is canonically isomorphic to
the space of linear maps from `M 0` to the space of multilinear maps on
`Π(i : fin n), M i.succ `, by separating the first variable. We register this isomorphism as a
linear isomorphism in `multilinear_curry_left_equiv R M M₂`.

The direct and inverse maps are given by `f.uncurry_left` and `f.curry_left`. Use these
unless you need the full framework of linear equivs. -/
def multilinearCurryLeftEquiv :
    (M 0 →ₗ[R] MultilinearMap R (fun i : Fin n => M i.succ) M₂) ≃ₗ[R] MultilinearMap R M M₂
    where
  toFun := LinearMap.uncurryLeft
  map_add' f₁ f₂ := by ext m; rfl
  map_smul' c f := by ext m; rfl
  invFun := MultilinearMap.curryLeft
  left_inv := LinearMap.curry_uncurryLeft
  right_inv := MultilinearMap.uncurry_curryLeft
#align multilinear_curry_left_equiv multilinearCurryLeftEquiv
-/

variable {R M M₂}

/-! #### Right currying -/


#print MultilinearMap.uncurryRight /-
/-- Given a multilinear map `f` in `n` variables to the space of linear maps from `M (last n)` to
`M₂`, construct the corresponding multilinear map on `n+1` variables obtained by concatenating
the variables, given by `m ↦ f (init m) (m (last n))`-/
def MultilinearMap.uncurryRight
    (f : MultilinearMap R (fun i : Fin n => M i.cast_succ) (M (last n) →ₗ[R] M₂)) :
    MultilinearMap R M M₂ where
  toFun m := f (init m) (m (last n))
  map_add' dec m i x y := by
    rw [Subsingleton.elim dec (by infer_instance)]
    by_cases h : i.val < n
    · have : last n ≠ i := Ne.symm (ne_of_lt h)
      rw [update_noteq this, update_noteq this, update_noteq this]
      revert x y
      rw [(cast_succ_cast_lt i h).symm]
      intro x y
      rw [init_update_cast_succ, MultilinearMap.map_add, init_update_cast_succ,
        init_update_cast_succ, LinearMap.add_apply]
    · revert x y
      rw [eq_last_of_not_lt h]
      intro x y
      rw [init_update_last, init_update_last, init_update_last, update_same, update_same,
        update_same, LinearMap.map_add]
  map_smul' dec m i c x := by
    rw [Subsingleton.elim dec (by infer_instance)]
    by_cases h : i.val < n
    · have : last n ≠ i := Ne.symm (ne_of_lt h)
      rw [update_noteq this, update_noteq this]
      revert x
      rw [(cast_succ_cast_lt i h).symm]
      intro x
      rw [init_update_cast_succ, init_update_cast_succ, MultilinearMap.map_smul,
        LinearMap.smul_apply]
    · revert x
      rw [eq_last_of_not_lt h]
      intro x
      rw [update_same, update_same, init_update_last, init_update_last, map_smul]
#align multilinear_map.uncurry_right MultilinearMap.uncurryRight
-/

#print MultilinearMap.uncurryRight_apply /-
@[simp]
theorem MultilinearMap.uncurryRight_apply
    (f : MultilinearMap R (fun i : Fin n => M i.cast_succ) (M (last n) →ₗ[R] M₂)) (m : ∀ i, M i) :
    f.uncurryRight m = f (init m) (m (last n)) :=
  rfl
#align multilinear_map.uncurry_right_apply MultilinearMap.uncurryRight_apply
-/

#print MultilinearMap.curryRight /-
/-- Given a multilinear map `f` in `n+1` variables, split the last variable to obtain
a multilinear map in `n` variables taking values in linear maps from `M (last n)` to `M₂`, given by
`m ↦ (x ↦ f (snoc m x))`. -/
def MultilinearMap.curryRight (f : MultilinearMap R M M₂) :
    MultilinearMap R (fun i : Fin n => M (Fin.castSucc i)) (M (last n) →ₗ[R] M₂)
    where
  toFun m :=
    { toFun := fun x => f (snoc m x)
      map_add' := fun x y => by rw [f.snoc_add]
      map_smul' := fun c x => by simp only [f.snoc_smul, RingHom.id_apply] }
  map_add' dec m i x y := by
    rw [Subsingleton.elim dec (by infer_instance)]
    ext z
    change f (snoc (update m i (x + y)) z) = f (snoc (update m i x) z) + f (snoc (update m i y) z)
    rw [snoc_update, snoc_update, snoc_update, f.map_add]
  map_smul' dec m i c x := by
    rw [Subsingleton.elim dec (by infer_instance)]
    ext z
    change f (snoc (update m i (c • x)) z) = c • f (snoc (update m i x) z)
    rw [snoc_update, snoc_update, f.map_smul]
#align multilinear_map.curry_right MultilinearMap.curryRight
-/

#print MultilinearMap.curryRight_apply /-
@[simp]
theorem MultilinearMap.curryRight_apply (f : MultilinearMap R M M₂) (m : ∀ i : Fin n, M i.cast_succ)
    (x : M (last n)) : f.curryRight m x = f (snoc m x) :=
  rfl
#align multilinear_map.curry_right_apply MultilinearMap.curryRight_apply
-/

#print MultilinearMap.curry_uncurryRight /-
@[simp]
theorem MultilinearMap.curry_uncurryRight
    (f : MultilinearMap R (fun i : Fin n => M i.cast_succ) (M (last n) →ₗ[R] M₂)) :
    f.uncurryRight.curryRight = f := by
  ext m x
  simp only [snoc_last, MultilinearMap.curryRight_apply, MultilinearMap.uncurryRight_apply]
  rw [init_snoc]
#align multilinear_map.curry_uncurry_right MultilinearMap.curry_uncurryRight
-/

#print MultilinearMap.uncurry_curryRight /-
@[simp]
theorem MultilinearMap.uncurry_curryRight (f : MultilinearMap R M M₂) :
    f.curryRight.uncurryRight = f := by ext m; simp
#align multilinear_map.uncurry_curry_right MultilinearMap.uncurry_curryRight
-/

variable (R M M₂)

#print multilinearCurryRightEquiv /-
/-- The space of multilinear maps on `Π(i : fin (n+1)), M i` is canonically isomorphic to
the space of linear maps from the space of multilinear maps on `Π(i : fin n), M i.cast_succ` to the
space of linear maps on `M (last n)`, by separating the last variable. We register this isomorphism
as a linear isomorphism in `multilinear_curry_right_equiv R M M₂`.

The direct and inverse maps are given by `f.uncurry_right` and `f.curry_right`. Use these
unless you need the full framework of linear equivs. -/
def multilinearCurryRightEquiv :
    MultilinearMap R (fun i : Fin n => M i.cast_succ) (M (last n) →ₗ[R] M₂) ≃ₗ[R]
      MultilinearMap R M M₂
    where
  toFun := MultilinearMap.uncurryRight
  map_add' f₁ f₂ := by ext m; rfl
  map_smul' c f := by ext m; rw [smul_apply]; rfl
  invFun := MultilinearMap.curryRight
  left_inv := MultilinearMap.curry_uncurryRight
  right_inv := MultilinearMap.uncurry_curryRight
#align multilinear_curry_right_equiv multilinearCurryRightEquiv
-/

namespace MultilinearMap

variable {ι' : Type _} {R M₂}

#print MultilinearMap.currySum /-
/-- A multilinear map on `Π i : ι ⊕ ι', M'` defines a multilinear map on `Π i : ι, M'`
taking values in the space of multilinear maps on `Π i : ι', M'`. -/
def currySum (f : MultilinearMap R (fun x : Sum ι ι' => M') M₂) :
    MultilinearMap R (fun x : ι => M') (MultilinearMap R (fun x : ι' => M') M₂)
    where
  toFun u :=
    { toFun := fun v => f (Sum.elim u v)
      map_add' := fun _ v i x y => by
        skip; letI := Classical.decEq ι
        simp only [← Sum.update_elim_inr, f.map_add]
      map_smul' := fun _ v i c x => by
        skip; letI := Classical.decEq ι
        simp only [← Sum.update_elim_inr, f.map_smul] }
  map_add' _ u i x y :=
    ext fun v => by
      skip; letI := Classical.decEq ι'
      simp only [MultilinearMap.coe_mk, add_apply, ← Sum.update_elim_inl, f.map_add]
  map_smul' _ u i c x :=
    ext fun v => by
      skip; letI := Classical.decEq ι'
      simp only [MultilinearMap.coe_mk, smul_apply, ← Sum.update_elim_inl, f.map_smul]
#align multilinear_map.curry_sum MultilinearMap.currySum
-/

#print MultilinearMap.currySum_apply /-
@[simp]
theorem currySum_apply (f : MultilinearMap R (fun x : Sum ι ι' => M') M₂) (u : ι → M')
    (v : ι' → M') : f.currySum u v = f (Sum.elim u v) :=
  rfl
#align multilinear_map.curry_sum_apply MultilinearMap.currySum_apply
-/

#print MultilinearMap.uncurrySum /-
/-- A multilinear map on `Π i : ι, M'` taking values in the space of multilinear maps
on `Π i : ι', M'` defines a multilinear map on `Π i : ι ⊕ ι', M'`. -/
def uncurrySum (f : MultilinearMap R (fun x : ι => M') (MultilinearMap R (fun x : ι' => M') M₂)) :
    MultilinearMap R (fun x : Sum ι ι' => M') M₂
    where
  toFun u := f (u ∘ Sum.inl) (u ∘ Sum.inr)
  map_add' _ u i x y := by
    skip
    letI := (@Sum.inl_injective ι ι').DecidableEq
    letI := (@Sum.inr_injective ι ι').DecidableEq
    cases i <;>
      simp only [MultilinearMap.map_add, add_apply, Sum.update_inl_comp_inl,
        Sum.update_inl_comp_inr, Sum.update_inr_comp_inl, Sum.update_inr_comp_inr]
  map_smul' _ u i c x := by
    skip
    letI := (@Sum.inl_injective ι ι').DecidableEq
    letI := (@Sum.inr_injective ι ι').DecidableEq
    cases i <;>
      simp only [MultilinearMap.map_smul, smul_apply, Sum.update_inl_comp_inl,
        Sum.update_inl_comp_inr, Sum.update_inr_comp_inl, Sum.update_inr_comp_inr]
#align multilinear_map.uncurry_sum MultilinearMap.uncurrySum
-/

#print MultilinearMap.uncurrySum_aux_apply /-
@[simp]
theorem uncurrySum_aux_apply
    (f : MultilinearMap R (fun x : ι => M') (MultilinearMap R (fun x : ι' => M') M₂))
    (u : Sum ι ι' → M') : f.uncurrySum u = f (u ∘ Sum.inl) (u ∘ Sum.inr) :=
  rfl
#align multilinear_map.uncurry_sum_aux_apply MultilinearMap.uncurrySum_aux_apply
-/

variable (ι ι' R M₂ M')

#print MultilinearMap.currySumEquiv /-
/-- Linear equivalence between the space of multilinear maps on `Π i : ι ⊕ ι', M'` and the space
of multilinear maps on `Π i : ι, M'` taking values in the space of multilinear maps
on `Π i : ι', M'`. -/
def currySumEquiv :
    MultilinearMap R (fun x : Sum ι ι' => M') M₂ ≃ₗ[R]
      MultilinearMap R (fun x : ι => M') (MultilinearMap R (fun x : ι' => M') M₂)
    where
  toFun := currySum
  invFun := uncurrySum
  left_inv f := ext fun u => by simp
  right_inv f := by ext; simp
  map_add' f g := by ext; rfl
  map_smul' c f := by ext; rfl
#align multilinear_map.curry_sum_equiv MultilinearMap.currySumEquiv
-/

variable {ι ι' R M₂ M'}

#print MultilinearMap.coe_currySumEquiv /-
@[simp]
theorem coe_currySumEquiv : ⇑(currySumEquiv R ι M₂ M' ι') = currySum :=
  rfl
#align multilinear_map.coe_curry_sum_equiv MultilinearMap.coe_currySumEquiv
-/

#print MultilinearMap.coe_currySumEquiv_symm /-
@[simp]
theorem coe_currySumEquiv_symm : ⇑(currySumEquiv R ι M₂ M' ι').symm = uncurrySum :=
  rfl
#align multilinear_map.coe_curr_sum_equiv_symm MultilinearMap.coe_currySumEquiv_symm
-/

variable (R M₂ M')

#print MultilinearMap.curryFinFinset /-
/-- If `s : finset (fin n)` is a finite set of cardinality `k` and its complement has cardinality
`l`, then the space of multilinear maps on `λ i : fin n, M'` is isomorphic to the space of
multilinear maps on `λ i : fin k, M'` taking values in the space of multilinear maps
on `λ i : fin l, M'`. -/
def curryFinFinset {k l n : ℕ} {s : Finset (Fin n)} (hk : s.card = k) (hl : sᶜ.card = l) :
    MultilinearMap R (fun x : Fin n => M') M₂ ≃ₗ[R]
      MultilinearMap R (fun x : Fin k => M') (MultilinearMap R (fun x : Fin l => M') M₂) :=
  (domDomCongrLinearEquiv M' M₂ R R (finSumEquivOfFinset hk hl).symm).trans
    (currySumEquiv R (Fin k) M₂ M' (Fin l))
#align multilinear_map.curry_fin_finset MultilinearMap.curryFinFinset
-/

variable {R M₂ M'}

#print MultilinearMap.curryFinFinset_apply /-
@[simp]
theorem curryFinFinset_apply {k l n : ℕ} {s : Finset (Fin n)} (hk : s.card = k) (hl : sᶜ.card = l)
    (f : MultilinearMap R (fun x : Fin n => M') M₂) (mk : Fin k → M') (ml : Fin l → M') :
    curryFinFinset R M₂ M' hk hl f mk ml =
      f fun i => Sum.elim mk ml ((finSumEquivOfFinset hk hl).symm i) :=
  rfl
#align multilinear_map.curry_fin_finset_apply MultilinearMap.curryFinFinset_apply
-/

#print MultilinearMap.curryFinFinset_symm_apply /-
@[simp]
theorem curryFinFinset_symm_apply {k l n : ℕ} {s : Finset (Fin n)} (hk : s.card = k)
    (hl : sᶜ.card = l)
    (f : MultilinearMap R (fun x : Fin k => M') (MultilinearMap R (fun x : Fin l => M') M₂))
    (m : Fin n → M') :
    (curryFinFinset R M₂ M' hk hl).symm f m =
      f (fun i => m <| finSumEquivOfFinset hk hl (Sum.inl i)) fun i =>
        m <| finSumEquivOfFinset hk hl (Sum.inr i) :=
  rfl
#align multilinear_map.curry_fin_finset_symm_apply MultilinearMap.curryFinFinset_symm_apply
-/

#print MultilinearMap.curryFinFinset_symm_apply_piecewise_const /-
@[simp]
theorem curryFinFinset_symm_apply_piecewise_const {k l n : ℕ} {s : Finset (Fin n)} (hk : s.card = k)
    (hl : sᶜ.card = l)
    (f : MultilinearMap R (fun x : Fin k => M') (MultilinearMap R (fun x : Fin l => M') M₂))
    (x y : M') :
    (curryFinFinset R M₂ M' hk hl).symm f (s.piecewise (fun _ => x) fun _ => y) =
      f (fun _ => x) fun _ => y :=
  by
  rw [curry_fin_finset_symm_apply]; congr
  · ext i; rw [finSumEquivOfFinset_inl, Finset.piecewise_eq_of_mem]
    apply Finset.orderEmbOfFin_mem
  · ext i; rw [finSumEquivOfFinset_inr, Finset.piecewise_eq_of_not_mem]
    exact Finset.mem_compl.1 (Finset.orderEmbOfFin_mem _ _ _)
#align multilinear_map.curry_fin_finset_symm_apply_piecewise_const MultilinearMap.curryFinFinset_symm_apply_piecewise_const
-/

#print MultilinearMap.curryFinFinset_symm_apply_const /-
@[simp]
theorem curryFinFinset_symm_apply_const {k l n : ℕ} {s : Finset (Fin n)} (hk : s.card = k)
    (hl : sᶜ.card = l)
    (f : MultilinearMap R (fun x : Fin k => M') (MultilinearMap R (fun x : Fin l => M') M₂))
    (x : M') : ((curryFinFinset R M₂ M' hk hl).symm f fun _ => x) = f (fun _ => x) fun _ => x :=
  rfl
#align multilinear_map.curry_fin_finset_symm_apply_const MultilinearMap.curryFinFinset_symm_apply_const
-/

#print MultilinearMap.curryFinFinset_apply_const /-
@[simp]
theorem curryFinFinset_apply_const {k l n : ℕ} {s : Finset (Fin n)} (hk : s.card = k)
    (hl : sᶜ.card = l) (f : MultilinearMap R (fun x : Fin n => M') M₂) (x y : M') :
    (curryFinFinset R M₂ M' hk hl f (fun _ => x) fun _ => y) =
      f (s.piecewise (fun _ => x) fun _ => y) :=
  by
  refine' (curry_fin_finset_symm_apply_piecewise_const hk hl _ _ _).symm.trans _
  -- `rw` fails
  rw [LinearEquiv.symm_apply_apply]
#align multilinear_map.curry_fin_finset_apply_const MultilinearMap.curryFinFinset_apply_const
-/

end MultilinearMap

end Currying

namespace MultilinearMap

section Submodule

variable {R M M₂} [Ring R] [∀ i, AddCommMonoid (M₁ i)] [AddCommMonoid M'] [AddCommMonoid M₂]
  [∀ i, Module R (M₁ i)] [Module R M'] [Module R M₂]

#print MultilinearMap.map /-
/-- The pushforward of an indexed collection of submodule `p i ⊆ M₁ i` by `f : M₁ → M₂`.

Note that this is not a submodule - it is not closed under addition. -/
def map [Nonempty ι] (f : MultilinearMap R M₁ M₂) (p : ∀ i, Submodule R (M₁ i)) : SubMulAction R M₂
    where
  carrier := f '' {v | ∀ i, v i ∈ p i}
  smul_mem' := fun c _ ⟨x, hx, hf⟩ => by
    let ⟨i⟩ := ‹Nonempty ι›
    letI := Classical.decEq ι
    refine' ⟨update x i (c • x i), fun j => if hij : j = i then _ else _, hf ▸ _⟩
    · rw [hij, update_same]; exact (p i).smul_mem _ (hx i)
    · rw [update_noteq hij]; exact hx j
    · rw [f.map_smul, update_eq_self]
#align multilinear_map.map MultilinearMap.map
-/

#print MultilinearMap.map_nonempty /-
/-- The map is always nonempty. This lemma is needed to apply `sub_mul_action.zero_mem`. -/
theorem map_nonempty [Nonempty ι] (f : MultilinearMap R M₁ M₂) (p : ∀ i, Submodule R (M₁ i)) :
    (map f p : Set M₂).Nonempty :=
  ⟨f 0, 0, fun i => (p i).zero_mem, rfl⟩
#align multilinear_map.map_nonempty MultilinearMap.map_nonempty
-/

#print MultilinearMap.range /-
/-- The range of a multilinear map, closed under scalar multiplication. -/
def range [Nonempty ι] (f : MultilinearMap R M₁ M₂) : SubMulAction R M₂ :=
  f.map fun i => ⊤
#align multilinear_map.range MultilinearMap.range
-/

end Submodule

end MultilinearMap

