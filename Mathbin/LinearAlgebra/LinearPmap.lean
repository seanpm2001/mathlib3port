/-
Copyright (c) 2020 Yury Kudryashov All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov, Moritz Doll

! This file was ported from Lean 3 source module linear_algebra.linear_pmap
! leanprover-community/mathlib commit 8b981918a93bc45a8600de608cde7944a80d92b9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Basic
import Mathbin.LinearAlgebra.Prod

/-!
# Partially defined linear maps

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A `linear_pmap R E F` or `E →ₗ.[R] F` is a linear map from a submodule of `E` to `F`.
We define a `semilattice_inf` with `order_bot` instance on this this, and define three operations:

* `mk_span_singleton` defines a partial linear map defined on the span of a singleton.
* `sup` takes two partial linear maps `f`, `g` that agree on the intersection of their
  domains, and returns the unique partial linear map on `f.domain ⊔ g.domain` that
  extends both `f` and `g`.
* `Sup` takes a `directed_on (≤)` set of partial linear maps, and returns the unique
  partial linear map on the `Sup` of their domains that extends all these maps.

Moreover, we define
* `linear_pmap.graph` is the graph of the partial linear map viewed as a submodule of `E × F`.

Partially defined maps are currently used in `mathlib` to prove Hahn-Banach theorem
and its variations. Namely, `linear_pmap.Sup` implies that every chain of `linear_pmap`s
is bounded above.
They are also the basis for the theory of unbounded operators.

-/


open Set

universe u v w

#print LinearPMap /-
/-- A `linear_pmap R E F` or `E →ₗ.[R] F` is a linear map from a submodule of `E` to `F`. -/
structure LinearPMap (R : Type u) [Ring R] (E : Type v) [AddCommGroup E] [Module R E] (F : Type w)
    [AddCommGroup F] [Module R F] where
  domain : Submodule R E
  toFun : domain →ₗ[R] F
#align linear_pmap LinearPMap
-/

notation:25 E " →ₗ.[" R:25 "] " F:0 => LinearPMap R E F

variable {R : Type _} [Ring R] {E : Type _} [AddCommGroup E] [Module R E] {F : Type _}
  [AddCommGroup F] [Module R F] {G : Type _} [AddCommGroup G] [Module R G]

namespace LinearPMap

open Submodule

instance : CoeFun (E →ₗ.[R] F) fun f : E →ₗ.[R] F => f.domain → F :=
  ⟨fun f => f.toFun⟩

#print LinearPMap.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe (f : E →ₗ.[R] F) (x : f.domain) : f.toFun x = f x :=
  rfl
#align linear_pmap.to_fun_eq_coe LinearPMap.toFun_eq_coe
-/

#print LinearPMap.ext /-
@[ext]
theorem ext {f g : E →ₗ.[R] F} (h : f.domain = g.domain)
    (h' : ∀ ⦃x : f.domain⦄ ⦃y : g.domain⦄ (h : (x : E) = y), f x = g y) : f = g :=
  by
  rcases f with ⟨f_dom, f⟩
  rcases g with ⟨g_dom, g⟩
  obtain rfl : f_dom = g_dom := h
  obtain rfl : f = g := LinearMap.ext fun x => h' rfl
  rfl
#align linear_pmap.ext LinearPMap.ext
-/

#print LinearPMap.map_zero /-
@[simp]
theorem map_zero (f : E →ₗ.[R] F) : f 0 = 0 :=
  f.toFun.map_zero
#align linear_pmap.map_zero LinearPMap.map_zero
-/

#print LinearPMap.ext_iff /-
theorem ext_iff {f g : E →ₗ.[R] F} :
    f = g ↔
      ∃ domain_eq : f.domain = g.domain,
        ∀ ⦃x : f.domain⦄ ⦃y : g.domain⦄ (h : (x : E) = y), f x = g y :=
  ⟨fun EQ => EQ ▸ ⟨rfl, fun x y h => by congr; exact_mod_cast h⟩, fun ⟨deq, feq⟩ => ext deq feq⟩
#align linear_pmap.ext_iff LinearPMap.ext_iff
-/

#print LinearPMap.ext' /-
theorem ext' {s : Submodule R E} {f g : s →ₗ[R] F} (h : f = g) : mk s f = mk s g :=
  h ▸ rfl
#align linear_pmap.ext' LinearPMap.ext'
-/

#print LinearPMap.map_add /-
theorem map_add (f : E →ₗ.[R] F) (x y : f.domain) : f (x + y) = f x + f y :=
  f.toFun.map_add x y
#align linear_pmap.map_add LinearPMap.map_add
-/

#print LinearPMap.map_neg /-
theorem map_neg (f : E →ₗ.[R] F) (x : f.domain) : f (-x) = -f x :=
  f.toFun.map_neg x
#align linear_pmap.map_neg LinearPMap.map_neg
-/

#print LinearPMap.map_sub /-
theorem map_sub (f : E →ₗ.[R] F) (x y : f.domain) : f (x - y) = f x - f y :=
  f.toFun.map_sub x y
#align linear_pmap.map_sub LinearPMap.map_sub
-/

#print LinearPMap.map_smul /-
theorem map_smul (f : E →ₗ.[R] F) (c : R) (x : f.domain) : f (c • x) = c • f x :=
  f.toFun.map_smul c x
#align linear_pmap.map_smul LinearPMap.map_smul
-/

#print LinearPMap.mk_apply /-
@[simp]
theorem mk_apply (p : Submodule R E) (f : p →ₗ[R] F) (x : p) : mk p f x = f x :=
  rfl
#align linear_pmap.mk_apply LinearPMap.mk_apply
-/

#print LinearPMap.mkSpanSingleton' /-
/-- The unique `linear_pmap` on `R ∙ x` that sends `x` to `y`. This version works for modules
over rings, and requires a proof of `∀ c, c • x = 0 → c • y = 0`. -/
noncomputable def mkSpanSingleton' (x : E) (y : F) (H : ∀ c : R, c • x = 0 → c • y = 0) : E →ₗ.[R] F
    where
  domain := R ∙ x
  toFun :=
    have H : ∀ c₁ c₂ : R, c₁ • x = c₂ • x → c₁ • y = c₂ • y :=
      by
      intro c₁ c₂ h
      rw [← sub_eq_zero, ← sub_smul] at h ⊢
      exact H _ h
    { toFun := fun z => Classical.choose (mem_span_singleton.1 z.Prop) • y
      map_add' := fun y z => by
        rw [← add_smul]
        apply H
        simp only [add_smul, sub_smul, Classical.choose_spec (mem_span_singleton.1 _)]
        apply coe_add
      map_smul' := fun c z => by
        rw [smul_smul]
        apply H
        simp only [mul_smul, Classical.choose_spec (mem_span_singleton.1 _)]
        apply coe_smul }
#align linear_pmap.mk_span_singleton' LinearPMap.mkSpanSingleton'
-/

#print LinearPMap.domain_mkSpanSingleton /-
@[simp]
theorem domain_mkSpanSingleton (x : E) (y : F) (H : ∀ c : R, c • x = 0 → c • y = 0) :
    (mkSpanSingleton' x y H).domain = R ∙ x :=
  rfl
#align linear_pmap.domain_mk_span_singleton LinearPMap.domain_mkSpanSingleton
-/

#print LinearPMap.mkSpanSingleton'_apply /-
@[simp]
theorem mkSpanSingleton'_apply (x : E) (y : F) (H : ∀ c : R, c • x = 0 → c • y = 0) (c : R) (h) :
    mkSpanSingleton' x y H ⟨c • x, h⟩ = c • y :=
  by
  dsimp [mk_span_singleton']
  rw [← sub_eq_zero, ← sub_smul]
  apply H
  simp only [sub_smul, one_smul, sub_eq_zero]
  apply Classical.choose_spec (mem_span_singleton.1 h)
#align linear_pmap.mk_span_singleton'_apply LinearPMap.mkSpanSingleton'_apply
-/

#print LinearPMap.mkSpanSingleton'_apply_self /-
@[simp]
theorem mkSpanSingleton'_apply_self (x : E) (y : F) (H : ∀ c : R, c • x = 0 → c • y = 0) (h) :
    mkSpanSingleton' x y H ⟨x, h⟩ = y := by
  convert mk_span_singleton'_apply x y H 1 _ <;> rwa [one_smul]
#align linear_pmap.mk_span_singleton'_apply_self LinearPMap.mkSpanSingleton'_apply_self
-/

#print LinearPMap.mkSpanSingleton /-
/-- The unique `linear_pmap` on `span R {x}` that sends a non-zero vector `x` to `y`.
This version works for modules over division rings. -/
@[reducible]
noncomputable def mkSpanSingleton {K E F : Type _} [DivisionRing K] [AddCommGroup E] [Module K E]
    [AddCommGroup F] [Module K F] (x : E) (y : F) (hx : x ≠ 0) : E →ₗ.[K] F :=
  mkSpanSingleton' x y fun c hc =>
    (smul_eq_zero.1 hc).elim (fun hc => by rw [hc, zero_smul]) fun hx' => absurd hx' hx
#align linear_pmap.mk_span_singleton LinearPMap.mkSpanSingleton
-/

#print LinearPMap.mkSpanSingleton_apply /-
theorem mkSpanSingleton_apply (K : Type _) {E F : Type _} [DivisionRing K] [AddCommGroup E]
    [Module K E] [AddCommGroup F] [Module K F] {x : E} (hx : x ≠ 0) (y : F) :
    mkSpanSingleton x y hx ⟨x, (Submodule.mem_span_singleton_self x : x ∈ Submodule.span K {x})⟩ =
      y :=
  LinearPMap.mkSpanSingleton'_apply_self _ _ _ _
#align linear_pmap.mk_span_singleton_apply LinearPMap.mkSpanSingleton_apply
-/

#print LinearPMap.fst /-
/-- Projection to the first coordinate as a `linear_pmap` -/
protected def fst (p : Submodule R E) (p' : Submodule R F) : E × F →ₗ.[R] E
    where
  domain := p.Prod p'
  toFun := (LinearMap.fst R E F).comp (p.Prod p').Subtype
#align linear_pmap.fst LinearPMap.fst
-/

#print LinearPMap.fst_apply /-
@[simp]
theorem fst_apply (p : Submodule R E) (p' : Submodule R F) (x : p.Prod p') :
    LinearPMap.fst p p' x = (x : E × F).1 :=
  rfl
#align linear_pmap.fst_apply LinearPMap.fst_apply
-/

#print LinearPMap.snd /-
/-- Projection to the second coordinate as a `linear_pmap` -/
protected def snd (p : Submodule R E) (p' : Submodule R F) : E × F →ₗ.[R] F
    where
  domain := p.Prod p'
  toFun := (LinearMap.snd R E F).comp (p.Prod p').Subtype
#align linear_pmap.snd LinearPMap.snd
-/

#print LinearPMap.snd_apply /-
@[simp]
theorem snd_apply (p : Submodule R E) (p' : Submodule R F) (x : p.Prod p') :
    LinearPMap.snd p p' x = (x : E × F).2 :=
  rfl
#align linear_pmap.snd_apply LinearPMap.snd_apply
-/

instance : Neg (E →ₗ.[R] F) :=
  ⟨fun f => ⟨f.domain, -f.toFun⟩⟩

#print LinearPMap.neg_apply /-
@[simp]
theorem neg_apply (f : E →ₗ.[R] F) (x) : (-f) x = -f x :=
  rfl
#align linear_pmap.neg_apply LinearPMap.neg_apply
-/

instance : LE (E →ₗ.[R] F) :=
  ⟨fun f g => f.domain ≤ g.domain ∧ ∀ ⦃x : f.domain⦄ ⦃y : g.domain⦄ (h : (x : E) = y), f x = g y⟩

#print LinearPMap.apply_comp_ofLe /-
theorem apply_comp_ofLe {T S : E →ₗ.[R] F} (h : T ≤ S) (x : T.domain) :
    T x = S (Submodule.ofLe h.1 x) :=
  h.2 rfl
#align linear_pmap.apply_comp_of_le LinearPMap.apply_comp_ofLe
-/

#print LinearPMap.exists_of_le /-
theorem exists_of_le {T S : E →ₗ.[R] F} (h : T ≤ S) (x : T.domain) :
    ∃ y : S.domain, (x : E) = y ∧ T x = S y :=
  ⟨⟨x.1, h.1 x.2⟩, ⟨rfl, h.2 rfl⟩⟩
#align linear_pmap.exists_of_le LinearPMap.exists_of_le
-/

#print LinearPMap.eq_of_le_of_domain_eq /-
theorem eq_of_le_of_domain_eq {f g : E →ₗ.[R] F} (hle : f ≤ g) (heq : f.domain = g.domain) :
    f = g :=
  ext HEq hle.2
#align linear_pmap.eq_of_le_of_domain_eq LinearPMap.eq_of_le_of_domain_eq
-/

#print LinearPMap.eqLocus /-
/-- Given two partial linear maps `f`, `g`, the set of points `x` such that
both `f` and `g` are defined at `x` and `f x = g x` form a submodule. -/
def eqLocus (f g : E →ₗ.[R] F) : Submodule R E
    where
  carrier := {x | ∃ (hf : x ∈ f.domain) (hg : x ∈ g.domain), f ⟨x, hf⟩ = g ⟨x, hg⟩}
  zero_mem' := ⟨zero_mem _, zero_mem _, f.map_zero.trans g.map_zero.symm⟩
  add_mem' := fun x y ⟨hfx, hgx, hx⟩ ⟨hfy, hgy, hy⟩ =>
    ⟨add_mem hfx hfy, add_mem hgx hgy, by
      erw [f.map_add ⟨x, hfx⟩ ⟨y, hfy⟩, g.map_add ⟨x, hgx⟩ ⟨y, hgy⟩, hx, hy]⟩
  smul_mem' := fun c x ⟨hfx, hgx, hx⟩ =>
    ⟨smul_mem _ c hfx, smul_mem _ c hgx, by erw [f.map_smul c ⟨x, hfx⟩, g.map_smul c ⟨x, hgx⟩, hx]⟩
#align linear_pmap.eq_locus LinearPMap.eqLocus
-/

instance : Inf (E →ₗ.[R] F) :=
  ⟨fun f g => ⟨f.eqLocus g, f.toFun.comp <| ofLe fun x hx => hx.fst⟩⟩

instance : Bot (E →ₗ.[R] F) :=
  ⟨⟨⊥, 0⟩⟩

instance : Inhabited (E →ₗ.[R] F) :=
  ⟨⊥⟩

instance : SemilatticeInf (E →ₗ.[R] F) where
  le := (· ≤ ·)
  le_refl f := ⟨le_refl f.domain, fun x y h => Subtype.eq h ▸ rfl⟩
  le_trans := fun f g h ⟨fg_le, fg_eq⟩ ⟨gh_le, gh_eq⟩ =>
    ⟨le_trans fg_le gh_le, fun x z hxz =>
      have hxy : (x : E) = ofLe fg_le x := rfl
      (fg_eq hxy).trans (gh_eq <| hxy.symm.trans hxz)⟩
  le_antisymm f g fg gf := eq_of_le_of_domain_eq fg (le_antisymm fg.1 gf.1)
  inf := (· ⊓ ·)
  le_inf := fun f g h ⟨fg_le, fg_eq⟩ ⟨fh_le, fh_eq⟩ =>
    ⟨fun x hx =>
      ⟨fg_le hx, fh_le hx, by refine' (fg_eq _).symm.trans (fh_eq _) <;> [exact ⟨x, hx⟩; rfl; rfl]⟩,
      fun x ⟨y, yg, hy⟩ h => by apply fg_eq; exact h⟩
  inf_le_left f g := ⟨fun x hx => hx.fst, fun x y h => congr_arg f <| Subtype.eq <| h⟩
  inf_le_right f g :=
    ⟨fun x hx => hx.snd.fst, fun ⟨x, xf, xg, hx⟩ y h => hx.trans <| congr_arg g <| Subtype.eq <| h⟩

instance : OrderBot (E →ₗ.[R] F) where
  bot := ⊥
  bot_le f :=
    ⟨bot_le, fun x y h => by
      have hx : x = 0 := Subtype.eq ((mem_bot R).1 x.2)
      have hy : y = 0 := Subtype.eq (h.symm.trans (congr_arg _ hx))
      rw [hx, hy, map_zero, map_zero]⟩

#print LinearPMap.le_of_eqLocus_ge /-
theorem le_of_eqLocus_ge {f g : E →ₗ.[R] F} (H : f.domain ≤ f.eqLocus g) : f ≤ g :=
  suffices f ≤ f ⊓ g from le_trans this inf_le_right
  ⟨H, fun x y hxy => ((inf_le_left : f ⊓ g ≤ f).2 hxy.symm).symm⟩
#align linear_pmap.le_of_eq_locus_ge LinearPMap.le_of_eqLocus_ge
-/

#print LinearPMap.domain_mono /-
theorem domain_mono : StrictMono (@domain R _ E _ _ F _ _) := fun f g hlt =>
  lt_of_le_of_ne hlt.1.1 fun heq => ne_of_lt hlt <| eq_of_le_of_domain_eq (le_of_lt hlt) HEq
#align linear_pmap.domain_mono LinearPMap.domain_mono
-/

private theorem sup_aux (f g : E →ₗ.[R] F)
    (h : ∀ (x : f.domain) (y : g.domain), (x : E) = y → f x = g y) :
    ∃ fg : ↥(f.domain ⊔ g.domain) →ₗ[R] F,
      ∀ (x : f.domain) (y : g.domain) (z), (x : E) + y = ↑z → fg z = f x + g y :=
  by
  choose x hx y hy hxy using fun z : f.domain ⊔ g.domain => mem_sup.1 z.Prop
  set fg := fun z => f ⟨x z, hx z⟩ + g ⟨y z, hy z⟩
  have fg_eq :
    ∀ (x' : f.domain) (y' : g.domain) (z' : f.domain ⊔ g.domain) (H : (x' : E) + y' = z'),
      fg z' = f x' + g y' :=
    by
    intro x' y' z' H
    dsimp [fg]
    rw [add_comm, ← sub_eq_sub_iff_add_eq_add, eq_comm, ← map_sub, ← map_sub]
    apply h
    simp only [← eq_sub_iff_add_eq] at hxy 
    simp only [AddSubgroupClass.coe_sub, coe_mk, coe_mk, hxy, ← sub_add, ← sub_sub, sub_self,
      zero_sub, ← H]
    apply neg_add_eq_sub
  refine' ⟨{ toFun := fg .. }, fg_eq⟩
  · rintro ⟨z₁, hz₁⟩ ⟨z₂, hz₂⟩
    rw [← add_assoc, add_right_comm (f _), ← map_add, add_assoc, ← map_add]
    apply fg_eq
    simp only [coe_add, coe_mk, ← add_assoc]
    rw [add_right_comm (x _), hxy, add_assoc, hxy, coe_mk, coe_mk]
  · intro c z
    rw [smul_add, ← map_smul, ← map_smul]
    apply fg_eq
    simp only [coe_smul, coe_mk, ← smul_add, hxy, RingHom.id_apply]

#print LinearPMap.sup /-
/-- Given two partial linear maps that agree on the intersection of their domains,
`f.sup g h` is the unique partial linear map on `f.domain ⊔ g.domain` that agrees
with `f` and `g`. -/
protected noncomputable def sup (f g : E →ₗ.[R] F)
    (h : ∀ (x : f.domain) (y : g.domain), (x : E) = y → f x = g y) : E →ₗ.[R] F :=
  ⟨_, Classical.choose (sup_aux f g h)⟩
#align linear_pmap.sup LinearPMap.sup
-/

#print LinearPMap.domain_sup /-
@[simp]
theorem domain_sup (f g : E →ₗ.[R] F)
    (h : ∀ (x : f.domain) (y : g.domain), (x : E) = y → f x = g y) :
    (f.sup g h).domain = f.domain ⊔ g.domain :=
  rfl
#align linear_pmap.domain_sup LinearPMap.domain_sup
-/

#print LinearPMap.sup_apply /-
theorem sup_apply {f g : E →ₗ.[R] F} (H : ∀ (x : f.domain) (y : g.domain), (x : E) = y → f x = g y)
    (x y z) (hz : (↑x : E) + ↑y = ↑z) : f.sup g H z = f x + g y :=
  Classical.choose_spec (sup_aux f g H) x y z hz
#align linear_pmap.sup_apply LinearPMap.sup_apply
-/

#print LinearPMap.left_le_sup /-
protected theorem left_le_sup (f g : E →ₗ.[R] F)
    (h : ∀ (x : f.domain) (y : g.domain), (x : E) = y → f x = g y) : f ≤ f.sup g h :=
  by
  refine' ⟨le_sup_left, fun z₁ z₂ hz => _⟩
  rw [← add_zero (f _), ← g.map_zero]
  refine' (sup_apply h _ _ _ _).symm
  simpa
#align linear_pmap.left_le_sup LinearPMap.left_le_sup
-/

#print LinearPMap.right_le_sup /-
protected theorem right_le_sup (f g : E →ₗ.[R] F)
    (h : ∀ (x : f.domain) (y : g.domain), (x : E) = y → f x = g y) : g ≤ f.sup g h :=
  by
  refine' ⟨le_sup_right, fun z₁ z₂ hz => _⟩
  rw [← zero_add (g _), ← f.map_zero]
  refine' (sup_apply h _ _ _ _).symm
  simpa
#align linear_pmap.right_le_sup LinearPMap.right_le_sup
-/

#print LinearPMap.sup_le /-
protected theorem sup_le {f g h : E →ₗ.[R] F}
    (H : ∀ (x : f.domain) (y : g.domain), (x : E) = y → f x = g y) (fh : f ≤ h) (gh : g ≤ h) :
    f.sup g H ≤ h :=
  have Hf : f ≤ f.sup g H ⊓ h := le_inf (f.left_le_sup g H) fh
  have Hg : g ≤ f.sup g H ⊓ h := le_inf (f.right_le_sup g H) gh
  le_of_eqLocus_ge <| sup_le Hf.1 Hg.1
#align linear_pmap.sup_le LinearPMap.sup_le
-/

#print LinearPMap.sup_h_of_disjoint /-
/-- Hypothesis for `linear_pmap.sup` holds, if `f.domain` is disjoint with `g.domain`. -/
theorem sup_h_of_disjoint (f g : E →ₗ.[R] F) (h : Disjoint f.domain g.domain) (x : f.domain)
    (y : g.domain) (hxy : (x : E) = y) : f x = g y :=
  by
  rw [disjoint_def] at h 
  have hy : y = 0 := Subtype.eq (h y (hxy ▸ x.2) y.2)
  have hx : x = 0 := Subtype.eq (hxy.trans <| congr_arg _ hy)
  simp [*]
#align linear_pmap.sup_h_of_disjoint LinearPMap.sup_h_of_disjoint
-/

section Smul

variable {M N : Type _} [Monoid M] [DistribMulAction M F] [SMulCommClass R M F]

variable [Monoid N] [DistribMulAction N F] [SMulCommClass R N F]

instance : SMul M (E →ₗ.[R] F) :=
  ⟨fun a f =>
    { domain := f.domain
      toFun := a • f.toFun }⟩

#print LinearPMap.smul_domain /-
@[simp]
theorem smul_domain (a : M) (f : E →ₗ.[R] F) : (a • f).domain = f.domain :=
  rfl
#align linear_pmap.smul_domain LinearPMap.smul_domain
-/

#print LinearPMap.smul_apply /-
theorem smul_apply (a : M) (f : E →ₗ.[R] F) (x : (a • f).domain) : (a • f) x = a • f x :=
  rfl
#align linear_pmap.smul_apply LinearPMap.smul_apply
-/

#print LinearPMap.coe_smul /-
@[simp]
theorem coe_smul (a : M) (f : E →ₗ.[R] F) : ⇑(a • f) = a • f :=
  rfl
#align linear_pmap.coe_smul LinearPMap.coe_smul
-/

instance [SMulCommClass M N F] : SMulCommClass M N (E →ₗ.[R] F) :=
  ⟨fun a b f => ext' <| smul_comm a b f.toFun⟩

instance [SMul M N] [IsScalarTower M N F] : IsScalarTower M N (E →ₗ.[R] F) :=
  ⟨fun a b f => ext' <| smul_assoc a b f.toFun⟩

instance : MulAction M (E →ₗ.[R] F) where
  smul := (· • ·)
  one_smul := fun ⟨s, f⟩ => ext' <| one_smul M f
  mul_smul a b f := ext' <| mul_smul a b f.toFun

end Smul

section Vadd

instance : VAdd (E →ₗ[R] F) (E →ₗ.[R] F) :=
  ⟨fun f g =>
    { domain := g.domain
      toFun := f.comp g.domain.Subtype + g.toFun }⟩

#print LinearPMap.vadd_domain /-
@[simp]
theorem vadd_domain (f : E →ₗ[R] F) (g : E →ₗ.[R] F) : (f +ᵥ g).domain = g.domain :=
  rfl
#align linear_pmap.vadd_domain LinearPMap.vadd_domain
-/

#print LinearPMap.vadd_apply /-
theorem vadd_apply (f : E →ₗ[R] F) (g : E →ₗ.[R] F) (x : (f +ᵥ g).domain) :
    (f +ᵥ g) x = f x + g x :=
  rfl
#align linear_pmap.vadd_apply LinearPMap.vadd_apply
-/

#print LinearPMap.coe_vadd /-
@[simp]
theorem coe_vadd (f : E →ₗ[R] F) (g : E →ₗ.[R] F) : ⇑(f +ᵥ g) = f.comp g.domain.Subtype + g :=
  rfl
#align linear_pmap.coe_vadd LinearPMap.coe_vadd
-/

instance : AddAction (E →ₗ[R] F) (E →ₗ.[R] F)
    where
  vadd := (· +ᵥ ·)
  zero_vadd := fun ⟨s, f⟩ => ext' <| zero_add _
  add_vadd := fun f₁ f₂ ⟨s, g⟩ => ext' <| LinearMap.ext fun x => add_assoc _ _ _

end Vadd

section

variable {K : Type _} [DivisionRing K] [Module K E] [Module K F]

#print LinearPMap.supSpanSingleton /-
/-- Extend a `linear_pmap` to `f.domain ⊔ K ∙ x`. -/
noncomputable def supSpanSingleton (f : E →ₗ.[K] F) (x : E) (y : F) (hx : x ∉ f.domain) :
    E →ₗ.[K] F :=
  f.sup (mkSpanSingleton x y fun h₀ => hx <| h₀.symm ▸ f.domain.zero_mem) <|
    sup_h_of_disjoint _ _ <| by simpa [disjoint_span_singleton]
#align linear_pmap.sup_span_singleton LinearPMap.supSpanSingleton
-/

#print LinearPMap.domain_supSpanSingleton /-
@[simp]
theorem domain_supSpanSingleton (f : E →ₗ.[K] F) (x : E) (y : F) (hx : x ∉ f.domain) :
    (f.supSpanSingleton x y hx).domain = f.domain ⊔ K ∙ x :=
  rfl
#align linear_pmap.domain_sup_span_singleton LinearPMap.domain_supSpanSingleton
-/

#print LinearPMap.supSpanSingleton_apply_mk /-
@[simp]
theorem supSpanSingleton_apply_mk (f : E →ₗ.[K] F) (x : E) (y : F) (hx : x ∉ f.domain) (x' : E)
    (hx' : x' ∈ f.domain) (c : K) :
    f.supSpanSingleton x y hx
        ⟨x' + c • x, mem_sup.2 ⟨x', hx', _, mem_span_singleton.2 ⟨c, rfl⟩, rfl⟩⟩ =
      f ⟨x', hx'⟩ + c • y :=
  by
  erw [sup_apply _ ⟨x', hx'⟩ ⟨c • x, _⟩, mk_span_singleton'_apply]
  rfl
  exact mem_span_singleton.2 ⟨c, rfl⟩
#align linear_pmap.sup_span_singleton_apply_mk LinearPMap.supSpanSingleton_apply_mk
-/

end

private theorem Sup_aux (c : Set (E →ₗ.[R] F)) (hc : DirectedOn (· ≤ ·) c) :
    ∃ f : ↥(sSup (domain '' c)) →ₗ[R] F, (⟨_, f⟩ : E →ₗ.[R] F) ∈ upperBounds c :=
  by
  cases' c.eq_empty_or_nonempty with ceq cne; · subst c; simp
  have hdir : DirectedOn (· ≤ ·) (domain '' c) := directedOn_image.2 (hc.mono domain_mono.monotone)
  have P : ∀ x : Sup (domain '' c), { p : c // (x : E) ∈ p.val.domain } :=
    by
    rintro x
    apply Classical.indefiniteDescription
    have := (mem_Sup_of_directed (cne.image _) hdir).1 x.2
    rwa [bex_image_iff, SetCoe.exists'] at this 
  set f : Sup (domain '' c) → F := fun x => (P x).val.val ⟨x, (P x).property⟩
  have f_eq : ∀ (p : c) (x : Sup (domain '' c)) (y : p.1.1) (hxy : (x : E) = y), f x = p.1 y :=
    by
    intro p x y hxy
    rcases hc (P x).1.1 (P x).1.2 p.1 p.2 with ⟨q, hqc, hxq, hpq⟩
    refine' (hxq.2 _).trans (hpq.2 _).symm
    exacts [of_le hpq.1 y, hxy, rfl]
  refine' ⟨{ toFun := f .. }, _⟩
  · intro x y
    rcases hc (P x).1.1 (P x).1.2 (P y).1.1 (P y).1.2 with ⟨p, hpc, hpx, hpy⟩
    set x' := of_le hpx.1 ⟨x, (P x).2⟩
    set y' := of_le hpy.1 ⟨y, (P y).2⟩
    rw [f_eq ⟨p, hpc⟩ x x' rfl, f_eq ⟨p, hpc⟩ y y' rfl, f_eq ⟨p, hpc⟩ (x + y) (x' + y') rfl,
      map_add]
  · intro c x
    simp [f_eq (P x).1 (c • x) (c • ⟨x, (P x).2⟩) rfl, ← map_smul]
  · intro p hpc
    refine' ⟨le_sSup <| mem_image_of_mem domain hpc, fun x y hxy => Eq.symm _⟩
    exact f_eq ⟨p, hpc⟩ _ _ hxy.symm

#print LinearPMap.sSup /-
/-- Glue a collection of partially defined linear maps to a linear map defined on `Sup`
of these submodules. -/
protected noncomputable def sSup (c : Set (E →ₗ.[R] F)) (hc : DirectedOn (· ≤ ·) c) : E →ₗ.[R] F :=
  ⟨_, Classical.choose <| sSup_aux c hc⟩
#align linear_pmap.Sup LinearPMap.sSup
-/

#print LinearPMap.le_sSup /-
protected theorem le_sSup {c : Set (E →ₗ.[R] F)} (hc : DirectedOn (· ≤ ·) c) {f : E →ₗ.[R] F}
    (hf : f ∈ c) : f ≤ LinearPMap.sSup c hc :=
  Classical.choose_spec (sSup_aux c hc) hf
#align linear_pmap.le_Sup LinearPMap.le_sSup
-/

#print LinearPMap.sSup_le /-
protected theorem sSup_le {c : Set (E →ₗ.[R] F)} (hc : DirectedOn (· ≤ ·) c) {g : E →ₗ.[R] F}
    (hg : ∀ f ∈ c, f ≤ g) : LinearPMap.sSup c hc ≤ g :=
  le_of_eqLocus_ge <|
    sSup_le fun _ ⟨f, hf, Eq⟩ =>
      Eq ▸
        have : f ≤ LinearPMap.sSup c hc ⊓ g := le_inf (LinearPMap.le_sSup _ hf) (hg f hf)
        this.1
#align linear_pmap.Sup_le LinearPMap.sSup_le
-/

#print LinearPMap.sSup_apply /-
protected theorem sSup_apply {c : Set (E →ₗ.[R] F)} (hc : DirectedOn (· ≤ ·) c) {l : E →ₗ.[R] F}
    (hl : l ∈ c) (x : l.domain) :
    (LinearPMap.sSup c hc) ⟨x, (LinearPMap.le_sSup hc hl).1 x.2⟩ = l x :=
  by
  symm
  apply (Classical.choose_spec (Sup_aux c hc) hl).2
  rfl
#align linear_pmap.Sup_apply LinearPMap.sSup_apply
-/

end LinearPMap

namespace LinearMap

#print LinearMap.toPMap /-
/-- Restrict a linear map to a submodule, reinterpreting the result as a `linear_pmap`. -/
def toPMap (f : E →ₗ[R] F) (p : Submodule R E) : E →ₗ.[R] F :=
  ⟨p, f.comp p.Subtype⟩
#align linear_map.to_pmap LinearMap.toPMap
-/

#print LinearMap.toPMap_apply /-
@[simp]
theorem toPMap_apply (f : E →ₗ[R] F) (p : Submodule R E) (x : p) : f.toPMap p x = f x :=
  rfl
#align linear_map.to_pmap_apply LinearMap.toPMap_apply
-/

#print LinearMap.toPMap_domain /-
@[simp]
theorem toPMap_domain (f : E →ₗ[R] F) (p : Submodule R E) : (f.toPMap p).domain = p :=
  rfl
#align linear_map.to_pmap_domain LinearMap.toPMap_domain
-/

#print LinearMap.compPMap /-
/-- Compose a linear map with a `linear_pmap` -/
def compPMap (g : F →ₗ[R] G) (f : E →ₗ.[R] F) : E →ₗ.[R] G
    where
  domain := f.domain
  toFun := g.comp f.toFun
#align linear_map.comp_pmap LinearMap.compPMap
-/

#print LinearMap.compPMap_apply /-
@[simp]
theorem compPMap_apply (g : F →ₗ[R] G) (f : E →ₗ.[R] F) (x) : g.compPMap f x = g (f x) :=
  rfl
#align linear_map.comp_pmap_apply LinearMap.compPMap_apply
-/

end LinearMap

namespace LinearPMap

#print LinearPMap.codRestrict /-
/-- Restrict codomain of a `linear_pmap` -/
def codRestrict (f : E →ₗ.[R] F) (p : Submodule R F) (H : ∀ x, f x ∈ p) : E →ₗ.[R] p
    where
  domain := f.domain
  toFun := f.toFun.codRestrict p H
#align linear_pmap.cod_restrict LinearPMap.codRestrict
-/

#print LinearPMap.comp /-
/-- Compose two `linear_pmap`s -/
def comp (g : F →ₗ.[R] G) (f : E →ₗ.[R] F) (H : ∀ x : f.domain, f x ∈ g.domain) : E →ₗ.[R] G :=
  g.toFun.compPMap <| f.codRestrict _ H
#align linear_pmap.comp LinearPMap.comp
-/

#print LinearPMap.coprod /-
/-- `f.coprod g` is the partially defined linear map defined on `f.domain × g.domain`,
and sending `p` to `f p.1 + g p.2`. -/
def coprod (f : E →ₗ.[R] G) (g : F →ₗ.[R] G) : E × F →ₗ.[R] G
    where
  domain := f.domain.Prod g.domain
  toFun :=
    (f.comp (LinearPMap.fst f.domain g.domain) fun x => x.2.1).toFun +
      (g.comp (LinearPMap.snd f.domain g.domain) fun x => x.2.2).toFun
#align linear_pmap.coprod LinearPMap.coprod
-/

#print LinearPMap.coprod_apply /-
@[simp]
theorem coprod_apply (f : E →ₗ.[R] G) (g : F →ₗ.[R] G) (x) :
    f.coprod g x = f ⟨(x : E × F).1, x.2.1⟩ + g ⟨(x : E × F).2, x.2.2⟩ :=
  rfl
#align linear_pmap.coprod_apply LinearPMap.coprod_apply
-/

#print LinearPMap.domRestrict /-
/-- Restrict a partially defined linear map to a submodule of `E` contained in `f.domain`. -/
def domRestrict (f : E →ₗ.[R] F) (S : Submodule R E) : E →ₗ.[R] F :=
  ⟨S ⊓ f.domain, f.toFun.comp (Submodule.ofLe (by simp))⟩
#align linear_pmap.dom_restrict LinearPMap.domRestrict
-/

#print LinearPMap.domRestrict_domain /-
@[simp]
theorem domRestrict_domain (f : E →ₗ.[R] F) {S : Submodule R E} :
    (f.domRestrict S).domain = S ⊓ f.domain :=
  rfl
#align linear_pmap.dom_restrict_domain LinearPMap.domRestrict_domain
-/

#print LinearPMap.domRestrict_apply /-
theorem domRestrict_apply {f : E →ₗ.[R] F} {S : Submodule R E} ⦃x : S ⊓ f.domain⦄ ⦃y : f.domain⦄
    (h : (x : E) = y) : f.domRestrict S x = f y :=
  by
  have : Submodule.ofLe (by simp) x = y := by ext; simp [h]
  rw [← this]
  exact LinearPMap.mk_apply _ _ _
#align linear_pmap.dom_restrict_apply LinearPMap.domRestrict_apply
-/

#print LinearPMap.domRestrict_le /-
theorem domRestrict_le {f : E →ₗ.[R] F} {S : Submodule R E} : f.domRestrict S ≤ f :=
  ⟨by simp, fun x y hxy => domRestrict_apply hxy⟩
#align linear_pmap.dom_restrict_le LinearPMap.domRestrict_le
-/

/-! ### Graph -/


section Graph

#print LinearPMap.graph /-
/-- The graph of a `linear_pmap` viewed as a submodule on `E × F`. -/
def graph (f : E →ₗ.[R] F) : Submodule R (E × F) :=
  f.toFun.graph.map (f.domain.Subtype.Prod_map (LinearMap.id : F →ₗ[R] F))
#align linear_pmap.graph LinearPMap.graph
-/

#print LinearPMap.mem_graph_iff' /-
theorem mem_graph_iff' (f : E →ₗ.[R] F) {x : E × F} : x ∈ f.graph ↔ ∃ y : f.domain, (↑y, f y) = x :=
  by simp [graph]
#align linear_pmap.mem_graph_iff' LinearPMap.mem_graph_iff'
-/

#print LinearPMap.mem_graph_iff /-
@[simp]
theorem mem_graph_iff (f : E →ₗ.[R] F) {x : E × F} :
    x ∈ f.graph ↔ ∃ y : f.domain, (↑y : E) = x.1 ∧ f y = x.2 := by cases x;
  simp_rw [mem_graph_iff', Prod.mk.inj_iff]
#align linear_pmap.mem_graph_iff LinearPMap.mem_graph_iff
-/

#print LinearPMap.mem_graph /-
/-- The tuple `(x, f x)` is contained in the graph of `f`. -/
theorem mem_graph (f : E →ₗ.[R] F) (x : domain f) : ((x : E), f x) ∈ f.graph := by simp
#align linear_pmap.mem_graph LinearPMap.mem_graph
-/

variable {M : Type _} [Monoid M] [DistribMulAction M F] [SMulCommClass R M F] (y : M)

#print LinearPMap.smul_graph /-
/-- The graph of `z • f` as a pushforward. -/
theorem smul_graph (f : E →ₗ.[R] F) (z : M) :
    (z • f).graph =
      f.graph.map ((LinearMap.id : E →ₗ[R] E).Prod_map (z • (LinearMap.id : F →ₗ[R] F))) :=
  by
  ext x; cases x
  constructor <;> intro h
  · rw [mem_graph_iff] at h 
    rcases h with ⟨y, hy, h⟩
    rw [LinearPMap.smul_apply] at h 
    rw [Submodule.mem_map]
    simp only [mem_graph_iff, LinearMap.prodMap_apply, LinearMap.id_coe, id.def,
      LinearMap.smul_apply, Prod.mk.inj_iff, Prod.exists, exists_exists_and_eq_and]
    use x_fst, y
    simp [hy, h]
  rw [Submodule.mem_map] at h 
  rcases h with ⟨x', hx', h⟩
  cases x'
  simp only [LinearMap.prodMap_apply, LinearMap.id_coe, id.def, LinearMap.smul_apply,
    Prod.mk.inj_iff] at h 
  rw [mem_graph_iff] at hx' ⊢
  rcases hx' with ⟨y, hy, hx'⟩
  use y
  rw [← h.1, ← h.2]
  simp [hy, hx']
#align linear_pmap.smul_graph LinearPMap.smul_graph
-/

#print LinearPMap.neg_graph /-
/-- The graph of `-f` as a pushforward. -/
theorem neg_graph (f : E →ₗ.[R] F) :
    (-f).graph = f.graph.map ((LinearMap.id : E →ₗ[R] E).Prod_map (-(LinearMap.id : F →ₗ[R] F))) :=
  by
  ext; cases x
  constructor <;> intro h
  · rw [mem_graph_iff] at h 
    rcases h with ⟨y, hy, h⟩
    rw [LinearPMap.neg_apply] at h 
    rw [Submodule.mem_map]
    simp only [mem_graph_iff, LinearMap.prodMap_apply, LinearMap.id_coe, id.def,
      LinearMap.neg_apply, Prod.mk.inj_iff, Prod.exists, exists_exists_and_eq_and]
    use x_fst, y
    simp [hy, h]
  rw [Submodule.mem_map] at h 
  rcases h with ⟨x', hx', h⟩
  cases x'
  simp only [LinearMap.prodMap_apply, LinearMap.id_coe, id.def, LinearMap.neg_apply,
    Prod.mk.inj_iff] at h 
  rw [mem_graph_iff] at hx' ⊢
  rcases hx' with ⟨y, hy, hx'⟩
  use y
  rw [← h.1, ← h.2]
  simp [hy, hx']
#align linear_pmap.neg_graph LinearPMap.neg_graph
-/

#print LinearPMap.mem_graph_snd_inj /-
theorem mem_graph_snd_inj (f : E →ₗ.[R] F) {x y : E} {x' y' : F} (hx : (x, x') ∈ f.graph)
    (hy : (y, y') ∈ f.graph) (hxy : x = y) : x' = y' :=
  by
  rw [mem_graph_iff] at hx hy 
  rcases hx with ⟨x'', hx1, hx2⟩
  rcases hy with ⟨y'', hy1, hy2⟩
  simp only at hx1 hx2 hy1 hy2 
  rw [← hx1, ← hy1, SetLike.coe_eq_coe] at hxy 
  rw [← hx2, ← hy2, hxy]
#align linear_pmap.mem_graph_snd_inj LinearPMap.mem_graph_snd_inj
-/

#print LinearPMap.mem_graph_snd_inj' /-
theorem mem_graph_snd_inj' (f : E →ₗ.[R] F) {x y : E × F} (hx : x ∈ f.graph) (hy : y ∈ f.graph)
    (hxy : x.1 = y.1) : x.2 = y.2 := by cases x; cases y; exact f.mem_graph_snd_inj hx hy hxy
#align linear_pmap.mem_graph_snd_inj' LinearPMap.mem_graph_snd_inj'
-/

#print LinearPMap.graph_fst_eq_zero_snd /-
/-- The property that `f 0 = 0` in terms of the graph. -/
theorem graph_fst_eq_zero_snd (f : E →ₗ.[R] F) {x : E} {x' : F} (h : (x, x') ∈ f.graph)
    (hx : x = 0) : x' = 0 :=
  f.mem_graph_snd_inj h f.graph.zero_mem hx
#align linear_pmap.graph_fst_eq_zero_snd LinearPMap.graph_fst_eq_zero_snd
-/

#print LinearPMap.mem_domain_iff /-
theorem mem_domain_iff {f : E →ₗ.[R] F} {x : E} : x ∈ f.domain ↔ ∃ y : F, (x, y) ∈ f.graph :=
  by
  constructor <;> intro h
  · use f ⟨x, h⟩
    exact f.mem_graph ⟨x, h⟩
  cases' h with y h
  rw [mem_graph_iff] at h 
  cases' h with x' h
  simp only at h 
  rw [← h.1]
  simp
#align linear_pmap.mem_domain_iff LinearPMap.mem_domain_iff
-/

#print LinearPMap.mem_domain_of_mem_graph /-
theorem mem_domain_of_mem_graph {f : E →ₗ.[R] F} {x : E} {y : F} (h : (x, y) ∈ f.graph) :
    x ∈ f.domain := by rw [mem_domain_iff]; exact ⟨y, h⟩
#align linear_pmap.mem_domain_of_mem_graph LinearPMap.mem_domain_of_mem_graph
-/

#print LinearPMap.image_iff /-
theorem image_iff {f : E →ₗ.[R] F} {x : E} {y : F} (hx : x ∈ f.domain) :
    y = f ⟨x, hx⟩ ↔ (x, y) ∈ f.graph := by
  rw [mem_graph_iff]
  constructor <;> intro h
  · use ⟨x, hx⟩
    simp [h]
  rcases h with ⟨⟨x', hx'⟩, ⟨h1, h2⟩⟩
  simp only [Submodule.coe_mk] at h1 h2 
  simp only [← h2, h1]
#align linear_pmap.image_iff LinearPMap.image_iff
-/

#print LinearPMap.mem_range_iff /-
theorem mem_range_iff {f : E →ₗ.[R] F} {y : F} : y ∈ Set.range f ↔ ∃ x : E, (x, y) ∈ f.graph :=
  by
  constructor <;> intro h
  · rw [Set.mem_range] at h 
    rcases h with ⟨⟨x, hx⟩, h⟩
    use x
    rw [← h]
    exact f.mem_graph ⟨x, hx⟩
  cases' h with x h
  rw [mem_graph_iff] at h 
  cases' h with x h
  rw [Set.mem_range]
  use x
  simp only at h 
  rw [h.2]
#align linear_pmap.mem_range_iff LinearPMap.mem_range_iff
-/

#print LinearPMap.mem_domain_iff_of_eq_graph /-
theorem mem_domain_iff_of_eq_graph {f g : E →ₗ.[R] F} (h : f.graph = g.graph) {x : E} :
    x ∈ f.domain ↔ x ∈ g.domain := by simp_rw [mem_domain_iff, h]
#align linear_pmap.mem_domain_iff_of_eq_graph LinearPMap.mem_domain_iff_of_eq_graph
-/

#print LinearPMap.le_of_le_graph /-
theorem le_of_le_graph {f g : E →ₗ.[R] F} (h : f.graph ≤ g.graph) : f ≤ g :=
  by
  constructor
  · intro x hx
    rw [mem_domain_iff] at hx ⊢
    cases' hx with y hx
    use y
    exact h hx
  rintro ⟨x, hx⟩ ⟨y, hy⟩ hxy
  rw [image_iff]
  refine' h _
  simp only [Submodule.coe_mk] at hxy 
  rw [hxy] at hx 
  rw [← image_iff hx]
  simp [hxy]
#align linear_pmap.le_of_le_graph LinearPMap.le_of_le_graph
-/

#print LinearPMap.le_graph_of_le /-
theorem le_graph_of_le {f g : E →ₗ.[R] F} (h : f ≤ g) : f.graph ≤ g.graph :=
  by
  intro x hx
  rw [mem_graph_iff] at hx ⊢
  cases' hx with y hx
  use y
  · exact h.1 y.2
  simp only [hx, Submodule.coe_mk, eq_self_iff_true, true_and_iff]
  convert hx.2
  refine' (h.2 _).symm
  simp only [hx.1, Submodule.coe_mk]
#align linear_pmap.le_graph_of_le LinearPMap.le_graph_of_le
-/

#print LinearPMap.le_graph_iff /-
theorem le_graph_iff {f g : E →ₗ.[R] F} : f.graph ≤ g.graph ↔ f ≤ g :=
  ⟨le_of_le_graph, le_graph_of_le⟩
#align linear_pmap.le_graph_iff LinearPMap.le_graph_iff
-/

#print LinearPMap.eq_of_eq_graph /-
theorem eq_of_eq_graph {f g : E →ₗ.[R] F} (h : f.graph = g.graph) : f = g := by ext;
  exact mem_domain_iff_of_eq_graph h; exact (le_of_le_graph h.le).2
#align linear_pmap.eq_of_eq_graph LinearPMap.eq_of_eq_graph
-/

end Graph

end LinearPMap

namespace Submodule

section SubmoduleToLinearPmap

#print Submodule.existsUnique_from_graph /-
theorem existsUnique_from_graph {g : Submodule R (E × F)}
    (hg : ∀ {x : E × F} (hx : x ∈ g) (hx' : x.fst = 0), x.snd = 0) {a : E}
    (ha : a ∈ g.map (LinearMap.fst R E F)) : ∃! b : F, (a, b) ∈ g :=
  by
  refine' existsUnique_of_exists_of_unique _ _
  · convert ha; simp
  intro y₁ y₂ hy₁ hy₂
  have hy : ((0 : E), y₁ - y₂) ∈ g := by
    convert g.sub_mem hy₁ hy₂
    exact (sub_self _).symm
  exact sub_eq_zero.mp (hg hy (by simp))
#align submodule.exists_unique_from_graph Submodule.existsUnique_from_graph
-/

#print Submodule.valFromGraph /-
/-- Auxiliary definition to unfold the existential quantifier. -/
noncomputable def valFromGraph {g : Submodule R (E × F)}
    (hg : ∀ (x : E × F) (hx : x ∈ g) (hx' : x.fst = 0), x.snd = 0) {a : E}
    (ha : a ∈ g.map (LinearMap.fst R E F)) : F :=
  (ExistsUnique.exists (existsUnique_from_graph hg ha)).some
#align submodule.val_from_graph Submodule.valFromGraph
-/

#print Submodule.valFromGraph_mem /-
theorem valFromGraph_mem {g : Submodule R (E × F)}
    (hg : ∀ (x : E × F) (hx : x ∈ g) (hx' : x.fst = 0), x.snd = 0) {a : E}
    (ha : a ∈ g.map (LinearMap.fst R E F)) : (a, valFromGraph hg ha) ∈ g :=
  (ExistsUnique.exists (existsUnique_from_graph hg ha)).choose_spec
#align submodule.val_from_graph_mem Submodule.valFromGraph_mem
-/

#print Submodule.toLinearPMap /-
/-- Define a `linear_pmap` from its graph. -/
noncomputable def toLinearPMap (g : Submodule R (E × F))
    (hg : ∀ (x : E × F) (hx : x ∈ g) (hx' : x.fst = 0), x.snd = 0) : E →ₗ.[R] F
    where
  domain := g.map (LinearMap.fst R E F)
  toFun :=
    { toFun := fun x => valFromGraph hg x.2
      map_add' := fun v w =>
        by
        have hadd := (g.map (LinearMap.fst R E F)).add_mem v.2 w.2
        have hvw := val_from_graph_mem hg hadd
        have hvw' := g.add_mem (val_from_graph_mem hg v.2) (val_from_graph_mem hg w.2)
        rw [Prod.mk_add_mk] at hvw' 
        exact (exists_unique_from_graph hg hadd).unique hvw hvw'
      map_smul' := fun a v =>
        by
        have hsmul := (g.map (LinearMap.fst R E F)).smul_mem a v.2
        have hav := val_from_graph_mem hg hsmul
        have hav' := g.smul_mem a (val_from_graph_mem hg v.2)
        rw [Prod.smul_mk] at hav' 
        exact (exists_unique_from_graph hg hsmul).unique hav hav' }
#align submodule.to_linear_pmap Submodule.toLinearPMap
-/

#print Submodule.mem_graph_toLinearPMap /-
theorem mem_graph_toLinearPMap (g : Submodule R (E × F))
    (hg : ∀ (x : E × F) (hx : x ∈ g) (hx' : x.fst = 0), x.snd = 0)
    (x : g.map (LinearMap.fst R E F)) : (x.val, g.toLinearPMap hg x) ∈ g :=
  valFromGraph_mem hg x.2
#align submodule.mem_graph_to_linear_pmap Submodule.mem_graph_toLinearPMap
-/

#print Submodule.toLinearPMap_graph_eq /-
@[simp]
theorem toLinearPMap_graph_eq (g : Submodule R (E × F))
    (hg : ∀ (x : E × F) (hx : x ∈ g) (hx' : x.fst = 0), x.snd = 0) :
    (g.toLinearPMap hg).graph = g := by
  ext
  constructor <;> intro hx
  · rw [LinearPMap.mem_graph_iff] at hx 
    rcases hx with ⟨y, hx1, hx2⟩
    convert g.mem_graph_to_linear_pmap hg y
    rw [Subtype.val_eq_coe]
    exact Prod.ext hx1.symm hx2.symm
  rw [LinearPMap.mem_graph_iff]
  cases x
  have hx_fst : x_fst ∈ g.map (LinearMap.fst R E F) :=
    by
    simp only [mem_map, LinearMap.fst_apply, Prod.exists, exists_and_right, exists_eq_right]
    exact ⟨x_snd, hx⟩
  refine' ⟨⟨x_fst, hx_fst⟩, Subtype.coe_mk x_fst hx_fst, _⟩
  exact (exists_unique_from_graph hg hx_fst).unique (val_from_graph_mem hg hx_fst) hx
#align submodule.to_linear_pmap_graph_eq Submodule.toLinearPMap_graph_eq
-/

end SubmoduleToLinearPmap

end Submodule

