/-
Copyright (c) 2019 Johannes Hölzl, Zhouhang Zhou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Zhouhang Zhou

! This file was ported from Lean 3 source module measure_theory.function.ae_eq_fun
! leanprover-community/mathlib commit a87d22575d946e1e156fc1edd1e1269600a8a282
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Integral.Lebesgue
import Mathbin.Order.Filter.Germ
import Mathbin.Topology.ContinuousFunction.Algebra
import Mathbin.MeasureTheory.Function.StronglyMeasurable.Basic

/-!

# Almost everywhere equal functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We build a space of equivalence classes of functions, where two functions are treated as identical
if they are almost everywhere equal. We form the set of equivalence classes under the relation of
being almost everywhere equal, which is sometimes known as the `L⁰` space.
To use this space as a basis for the `L^p` spaces and for the Bochner integral, we consider
equivalence classes of strongly measurable functions (or, equivalently, of almost everywhere
strongly measurable functions.)

See `l1_space.lean` for `L¹` space.

## Notation

* `α →ₘ[μ] β` is the type of `L⁰` space, where `α` is a measurable space, `β` is a topological
  space, and `μ` is a measure on `α`. `f : α →ₘ β` is a "function" in `L⁰`.
  In comments, `[f]` is also used to denote an `L⁰` function.

  `ₘ` can be typed as `\_m`. Sometimes it is shown as a box if font is missing.

## Main statements

* The linear structure of `L⁰` :
    Addition and scalar multiplication are defined on `L⁰` in the natural way, i.e.,
    `[f] + [g] := [f + g]`, `c • [f] := [c • f]`. So defined, `α →ₘ β` inherits the linear structure
    of `β`. For example, if `β` is a module, then `α →ₘ β` is a module over the same ring.

    See `mk_add_mk`,  `neg_mk`,     `mk_sub_mk`,  `smul_mk`,
        `add_to_fun`, `neg_to_fun`, `sub_to_fun`, `smul_to_fun`

* The order structure of `L⁰` :
    `≤` can be defined in a similar way: `[f] ≤ [g]` if `f a ≤ g a` for almost all `a` in domain.
    And `α →ₘ β` inherits the preorder and partial order of `β`.

    TODO: Define `sup` and `inf` on `L⁰` so that it forms a lattice. It seems that `β` must be a
    linear order, since otherwise `f ⊔ g` may not be a measurable function.

## Implementation notes

* `f.to_fun`     : To find a representative of `f : α →ₘ β`, use the coercion `(f : α → β)`, which
                 is implemented as `f.to_fun`.
                 For each operation `op` in `L⁰`, there is a lemma called `coe_fn_op`,
                 characterizing, say, `(f op g : α → β)`.
* `ae_eq_fun.mk` : To constructs an `L⁰` function `α →ₘ β` from an almost everywhere strongly
                 measurable function `f : α → β`, use `ae_eq_fun.mk`
* `comp`         : Use `comp g f` to get `[g ∘ f]` from `g : β → γ` and `[f] : α →ₘ γ` when `g` is
                 continuous. Use `comp_measurable` if `g` is only measurable (this requires the
                 target space to be second countable).
* `comp₂`        : Use `comp₂ g f₁ f₂ to get `[λ a, g (f₁ a) (f₂ a)]`.
                 For example, `[f + g]` is `comp₂ (+)`


## Tags

function space, almost everywhere equal, `L⁰`, ae_eq_fun

-/


noncomputable section

open scoped Classical ENNReal Topology

open Set Filter TopologicalSpace ENNReal Emetric MeasureTheory Function

variable {α β γ δ : Type _} [MeasurableSpace α] {μ ν : Measure α}

namespace MeasureTheory

section MeasurableSpace

variable [TopologicalSpace β]

variable (β)

#print MeasureTheory.Measure.aeEqSetoid /-
/-- The equivalence relation of being almost everywhere equal for almost everywhere strongly
measurable functions. -/
def Measure.aeEqSetoid (μ : Measure α) : Setoid { f : α → β // AEStronglyMeasurable f μ } :=
  ⟨fun f g => (f : α → β) =ᵐ[μ] g, fun f => ae_eq_refl f, fun f g => ae_eq_symm, fun f g h =>
    ae_eq_trans⟩
#align measure_theory.measure.ae_eq_setoid MeasureTheory.Measure.aeEqSetoid
-/

variable (α)

#print MeasureTheory.AEEqFun /-
/-- The space of equivalence classes of almost everywhere strongly measurable functions, where two
    strongly measurable functions are equivalent if they agree almost everywhere, i.e.,
    they differ on a set of measure `0`.  -/
def AEEqFun (μ : Measure α) : Type _ :=
  Quotient (μ.aeEqSetoid β)
#align measure_theory.ae_eq_fun MeasureTheory.AEEqFun
-/

variable {α β}

notation:25 α " →ₘ[" μ "] " β => AEEqFun α β μ

end MeasurableSpace

namespace AeEqFun

variable [TopologicalSpace β] [TopologicalSpace γ] [TopologicalSpace δ]

#print MeasureTheory.AEEqFun.mk /-
/-- Construct the equivalence class `[f]` of an almost everywhere measurable function `f`, based
    on the equivalence relation of being almost everywhere equal. -/
def mk {β : Type _} [TopologicalSpace β] (f : α → β) (hf : AEStronglyMeasurable f μ) : α →ₘ[μ] β :=
  Quotient.mk'' ⟨f, hf⟩
#align measure_theory.ae_eq_fun.mk MeasureTheory.AEEqFun.mk
-/

/-- A measurable representative of an `ae_eq_fun` [f] -/
instance : CoeFun (α →ₘ[μ] β) fun _ => α → β :=
  ⟨fun f =>
    AEStronglyMeasurable.mk _ (Quotient.out' f : { f : α → β // AEStronglyMeasurable f μ }).2⟩

#print MeasureTheory.AEEqFun.stronglyMeasurable /-
protected theorem stronglyMeasurable (f : α →ₘ[μ] β) : StronglyMeasurable f :=
  AEStronglyMeasurable.stronglyMeasurable_mk _
#align measure_theory.ae_eq_fun.strongly_measurable MeasureTheory.AEEqFun.stronglyMeasurable
-/

#print MeasureTheory.AEEqFun.aestronglyMeasurable /-
protected theorem aestronglyMeasurable (f : α →ₘ[μ] β) : AEStronglyMeasurable f μ :=
  f.StronglyMeasurable.AEStronglyMeasurable
#align measure_theory.ae_eq_fun.ae_strongly_measurable MeasureTheory.AEEqFun.aestronglyMeasurable
-/

#print MeasureTheory.AEEqFun.measurable /-
protected theorem measurable [PseudoMetrizableSpace β] [MeasurableSpace β] [BorelSpace β]
    (f : α →ₘ[μ] β) : Measurable f :=
  AEStronglyMeasurable.measurable_mk _
#align measure_theory.ae_eq_fun.measurable MeasureTheory.AEEqFun.measurable
-/

#print MeasureTheory.AEEqFun.aemeasurable /-
protected theorem aemeasurable [PseudoMetrizableSpace β] [MeasurableSpace β] [BorelSpace β]
    (f : α →ₘ[μ] β) : AEMeasurable f μ :=
  f.Measurable.AEMeasurable
#align measure_theory.ae_eq_fun.ae_measurable MeasureTheory.AEEqFun.aemeasurable
-/

#print MeasureTheory.AEEqFun.quot_mk_eq_mk /-
@[simp]
theorem quot_mk_eq_mk (f : α → β) (hf) :
    (Quot.mk (@Setoid.r _ <| μ.aeEqSetoid β) ⟨f, hf⟩ : α →ₘ[μ] β) = mk f hf :=
  rfl
#align measure_theory.ae_eq_fun.quot_mk_eq_mk MeasureTheory.AEEqFun.quot_mk_eq_mk
-/

#print MeasureTheory.AEEqFun.mk_eq_mk /-
@[simp]
theorem mk_eq_mk {f g : α → β} {hf hg} : (mk f hf : α →ₘ[μ] β) = mk g hg ↔ f =ᵐ[μ] g :=
  Quotient.eq''
#align measure_theory.ae_eq_fun.mk_eq_mk MeasureTheory.AEEqFun.mk_eq_mk
-/

#print MeasureTheory.AEEqFun.mk_coeFn /-
@[simp]
theorem mk_coeFn (f : α →ₘ[μ] β) : mk f f.AEStronglyMeasurable = f :=
  by
  conv_rhs => rw [← Quotient.out_eq' f]
  set g : { f : α → β // ae_strongly_measurable f μ } := Quotient.out' f with hg
  have : g = ⟨g.1, g.2⟩ := Subtype.eq rfl
  rw [this, ← mk, mk_eq_mk]
  exact (ae_strongly_measurable.ae_eq_mk _).symm
#align measure_theory.ae_eq_fun.mk_coe_fn MeasureTheory.AEEqFun.mk_coeFn
-/

#print MeasureTheory.AEEqFun.ext /-
@[ext]
theorem ext {f g : α →ₘ[μ] β} (h : f =ᵐ[μ] g) : f = g := by
  rwa [← f.mk_coe_fn, ← g.mk_coe_fn, mk_eq_mk]
#align measure_theory.ae_eq_fun.ext MeasureTheory.AEEqFun.ext
-/

#print MeasureTheory.AEEqFun.ext_iff /-
theorem ext_iff {f g : α →ₘ[μ] β} : f = g ↔ f =ᵐ[μ] g :=
  ⟨fun h => by rw [h], fun h => ext h⟩
#align measure_theory.ae_eq_fun.ext_iff MeasureTheory.AEEqFun.ext_iff
-/

#print MeasureTheory.AEEqFun.coeFn_mk /-
theorem coeFn_mk (f : α → β) (hf) : (mk f hf : α →ₘ[μ] β) =ᵐ[μ] f :=
  by
  apply (ae_strongly_measurable.ae_eq_mk _).symm.trans
  exact @Quotient.mk_out' _ (μ.ae_eq_setoid β) (⟨f, hf⟩ : { f // ae_strongly_measurable f μ })
#align measure_theory.ae_eq_fun.coe_fn_mk MeasureTheory.AEEqFun.coeFn_mk
-/

#print MeasureTheory.AEEqFun.induction_on /-
@[elab_as_elim]
theorem induction_on (f : α →ₘ[μ] β) {p : (α →ₘ[μ] β) → Prop} (H : ∀ f hf, p (mk f hf)) : p f :=
  Quotient.inductionOn' f <| Subtype.forall.2 H
#align measure_theory.ae_eq_fun.induction_on MeasureTheory.AEEqFun.induction_on
-/

#print MeasureTheory.AEEqFun.induction_on₂ /-
@[elab_as_elim]
theorem induction_on₂ {α' β' : Type _} [MeasurableSpace α'] [TopologicalSpace β'] {μ' : Measure α'}
    (f : α →ₘ[μ] β) (f' : α' →ₘ[μ'] β') {p : (α →ₘ[μ] β) → (α' →ₘ[μ'] β') → Prop}
    (H : ∀ f hf f' hf', p (mk f hf) (mk f' hf')) : p f f' :=
  induction_on f fun f hf => induction_on f' <| H f hf
#align measure_theory.ae_eq_fun.induction_on₂ MeasureTheory.AEEqFun.induction_on₂
-/

#print MeasureTheory.AEEqFun.induction_on₃ /-
@[elab_as_elim]
theorem induction_on₃ {α' β' : Type _} [MeasurableSpace α'] [TopologicalSpace β'] {μ' : Measure α'}
    {α'' β'' : Type _} [MeasurableSpace α''] [TopologicalSpace β''] {μ'' : Measure α''}
    (f : α →ₘ[μ] β) (f' : α' →ₘ[μ'] β') (f'' : α'' →ₘ[μ''] β'')
    {p : (α →ₘ[μ] β) → (α' →ₘ[μ'] β') → (α'' →ₘ[μ''] β'') → Prop}
    (H : ∀ f hf f' hf' f'' hf'', p (mk f hf) (mk f' hf') (mk f'' hf'')) : p f f' f'' :=
  induction_on f fun f hf => induction_on₂ f' f'' <| H f hf
#align measure_theory.ae_eq_fun.induction_on₃ MeasureTheory.AEEqFun.induction_on₃
-/

#print MeasureTheory.AEEqFun.comp /-
/-- Given a continuous function `g : β → γ`, and an almost everywhere equal function `[f] : α →ₘ β`,
    return the equivalence class of `g ∘ f`, i.e., the almost everywhere equal function
    `[g ∘ f] : α →ₘ γ`. -/
def comp (g : β → γ) (hg : Continuous g) (f : α →ₘ[μ] β) : α →ₘ[μ] γ :=
  Quotient.liftOn' f (fun f => mk (g ∘ (f : α → β)) (hg.comp_aestronglyMeasurable f.2))
    fun f f' H => mk_eq_mk.2 <| H.fun_comp g
#align measure_theory.ae_eq_fun.comp MeasureTheory.AEEqFun.comp
-/

#print MeasureTheory.AEEqFun.comp_mk /-
@[simp]
theorem comp_mk (g : β → γ) (hg : Continuous g) (f : α → β) (hf) :
    comp g hg (mk f hf : α →ₘ[μ] β) = mk (g ∘ f) (hg.comp_aestronglyMeasurable hf) :=
  rfl
#align measure_theory.ae_eq_fun.comp_mk MeasureTheory.AEEqFun.comp_mk
-/

#print MeasureTheory.AEEqFun.comp_eq_mk /-
theorem comp_eq_mk (g : β → γ) (hg : Continuous g) (f : α →ₘ[μ] β) :
    comp g hg f = mk (g ∘ f) (hg.comp_aestronglyMeasurable f.AEStronglyMeasurable) := by
  rw [← comp_mk g hg f f.ae_strongly_measurable, mk_coe_fn]
#align measure_theory.ae_eq_fun.comp_eq_mk MeasureTheory.AEEqFun.comp_eq_mk
-/

#print MeasureTheory.AEEqFun.coeFn_comp /-
theorem coeFn_comp (g : β → γ) (hg : Continuous g) (f : α →ₘ[μ] β) : comp g hg f =ᵐ[μ] g ∘ f := by
  rw [comp_eq_mk]; apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_comp MeasureTheory.AEEqFun.coeFn_comp
-/

section CompMeasurable

variable [MeasurableSpace β] [PseudoMetrizableSpace β] [BorelSpace β] [MeasurableSpace γ]
  [PseudoMetrizableSpace γ] [OpensMeasurableSpace γ] [SecondCountableTopology γ]

#print MeasureTheory.AEEqFun.compMeasurable /-
/-- Given a measurable function `g : β → γ`, and an almost everywhere equal function `[f] : α →ₘ β`,
    return the equivalence class of `g ∘ f`, i.e., the almost everywhere equal function
    `[g ∘ f] : α →ₘ γ`. This requires that `γ` has a second countable topology. -/
def compMeasurable (g : β → γ) (hg : Measurable g) (f : α →ₘ[μ] β) : α →ₘ[μ] γ :=
  Quotient.liftOn' f
    (fun f' => mk (g ∘ (f' : α → β)) (hg.comp_aemeasurable f'.2.AEMeasurable).AEStronglyMeasurable)
    fun f f' H => mk_eq_mk.2 <| H.fun_comp g
#align measure_theory.ae_eq_fun.comp_measurable MeasureTheory.AEEqFun.compMeasurable
-/

#print MeasureTheory.AEEqFun.compMeasurable_mk /-
@[simp]
theorem compMeasurable_mk (g : β → γ) (hg : Measurable g) (f : α → β)
    (hf : AEStronglyMeasurable f μ) :
    compMeasurable g hg (mk f hf : α →ₘ[μ] β) =
      mk (g ∘ f) (hg.comp_aemeasurable hf.AEMeasurable).AEStronglyMeasurable :=
  rfl
#align measure_theory.ae_eq_fun.comp_measurable_mk MeasureTheory.AEEqFun.compMeasurable_mk
-/

#print MeasureTheory.AEEqFun.compMeasurable_eq_mk /-
theorem compMeasurable_eq_mk (g : β → γ) (hg : Measurable g) (f : α →ₘ[μ] β) :
    compMeasurable g hg f = mk (g ∘ f) (hg.comp_aemeasurable f.AEMeasurable).AEStronglyMeasurable :=
  by rw [← comp_measurable_mk g hg f f.ae_strongly_measurable, mk_coe_fn]
#align measure_theory.ae_eq_fun.comp_measurable_eq_mk MeasureTheory.AEEqFun.compMeasurable_eq_mk
-/

#print MeasureTheory.AEEqFun.coeFn_compMeasurable /-
theorem coeFn_compMeasurable (g : β → γ) (hg : Measurable g) (f : α →ₘ[μ] β) :
    compMeasurable g hg f =ᵐ[μ] g ∘ f := by rw [comp_measurable_eq_mk]; apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_comp_measurable MeasureTheory.AEEqFun.coeFn_compMeasurable
-/

end CompMeasurable

#print MeasureTheory.AEEqFun.pair /-
/-- The class of `x ↦ (f x, g x)`. -/
def pair (f : α →ₘ[μ] β) (g : α →ₘ[μ] γ) : α →ₘ[μ] β × γ :=
  Quotient.liftOn₂' f g (fun f g => mk (fun x => (f.1 x, g.1 x)) (f.2.prod_mk g.2))
    fun f g f' g' Hf Hg => mk_eq_mk.2 <| Hf.prod_mk Hg
#align measure_theory.ae_eq_fun.pair MeasureTheory.AEEqFun.pair
-/

#print MeasureTheory.AEEqFun.pair_mk_mk /-
@[simp]
theorem pair_mk_mk (f : α → β) (hf) (g : α → γ) (hg) :
    (mk f hf : α →ₘ[μ] β).pair (mk g hg) = mk (fun x => (f x, g x)) (hf.prod_mk hg) :=
  rfl
#align measure_theory.ae_eq_fun.pair_mk_mk MeasureTheory.AEEqFun.pair_mk_mk
-/

#print MeasureTheory.AEEqFun.pair_eq_mk /-
theorem pair_eq_mk (f : α →ₘ[μ] β) (g : α →ₘ[μ] γ) :
    f.pair g = mk (fun x => (f x, g x)) (f.AEStronglyMeasurable.prod_mk g.AEStronglyMeasurable) :=
  by simp only [← pair_mk_mk, mk_coe_fn]
#align measure_theory.ae_eq_fun.pair_eq_mk MeasureTheory.AEEqFun.pair_eq_mk
-/

#print MeasureTheory.AEEqFun.coeFn_pair /-
theorem coeFn_pair (f : α →ₘ[μ] β) (g : α →ₘ[μ] γ) : f.pair g =ᵐ[μ] fun x => (f x, g x) := by
  rw [pair_eq_mk]; apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_pair MeasureTheory.AEEqFun.coeFn_pair
-/

#print MeasureTheory.AEEqFun.comp₂ /-
/-- Given a continuous function `g : β → γ → δ`, and almost everywhere equal functions
    `[f₁] : α →ₘ β` and `[f₂] : α →ₘ γ`, return the equivalence class of the function
    `λ a, g (f₁ a) (f₂ a)`, i.e., the almost everywhere equal function
    `[λ a, g (f₁ a) (f₂ a)] : α →ₘ γ` -/
def comp₂ (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    α →ₘ[μ] δ :=
  comp _ hg (f₁.pair f₂)
#align measure_theory.ae_eq_fun.comp₂ MeasureTheory.AEEqFun.comp₂
-/

#print MeasureTheory.AEEqFun.comp₂_mk_mk /-
@[simp]
theorem comp₂_mk_mk (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α → β) (f₂ : α → γ)
    (hf₁ hf₂) :
    comp₂ g hg (mk f₁ hf₁ : α →ₘ[μ] β) (mk f₂ hf₂) =
      mk (fun a => g (f₁ a) (f₂ a)) (hg.comp_aestronglyMeasurable (hf₁.prod_mk hf₂)) :=
  rfl
#align measure_theory.ae_eq_fun.comp₂_mk_mk MeasureTheory.AEEqFun.comp₂_mk_mk
-/

#print MeasureTheory.AEEqFun.comp₂_eq_pair /-
theorem comp₂_eq_pair (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β)
    (f₂ : α →ₘ[μ] γ) : comp₂ g hg f₁ f₂ = comp _ hg (f₁.pair f₂) :=
  rfl
#align measure_theory.ae_eq_fun.comp₂_eq_pair MeasureTheory.AEEqFun.comp₂_eq_pair
-/

#print MeasureTheory.AEEqFun.comp₂_eq_mk /-
theorem comp₂_eq_mk (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β)
    (f₂ : α →ₘ[μ] γ) :
    comp₂ g hg f₁ f₂ =
      mk (fun a => g (f₁ a) (f₂ a))
        (hg.comp_aestronglyMeasurable (f₁.AEStronglyMeasurable.prod_mk f₂.AEStronglyMeasurable)) :=
  by rw [comp₂_eq_pair, pair_eq_mk, comp_mk] <;> rfl
#align measure_theory.ae_eq_fun.comp₂_eq_mk MeasureTheory.AEEqFun.comp₂_eq_mk
-/

#print MeasureTheory.AEEqFun.coeFn_comp₂ /-
theorem coeFn_comp₂ (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β)
    (f₂ : α →ₘ[μ] γ) : comp₂ g hg f₁ f₂ =ᵐ[μ] fun a => g (f₁ a) (f₂ a) := by rw [comp₂_eq_mk];
  apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_comp₂ MeasureTheory.AEEqFun.coeFn_comp₂
-/

section

variable [MeasurableSpace β] [PseudoMetrizableSpace β] [BorelSpace β] [SecondCountableTopology β]
  [MeasurableSpace γ] [PseudoMetrizableSpace γ] [BorelSpace γ] [SecondCountableTopology γ]
  [MeasurableSpace δ] [PseudoMetrizableSpace δ] [OpensMeasurableSpace δ] [SecondCountableTopology δ]

#print MeasureTheory.AEEqFun.comp₂Measurable /-
/-- Given a measurable function `g : β → γ → δ`, and almost everywhere equal functions
    `[f₁] : α →ₘ β` and `[f₂] : α →ₘ γ`, return the equivalence class of the function
    `λ a, g (f₁ a) (f₂ a)`, i.e., the almost everywhere equal function
    `[λ a, g (f₁ a) (f₂ a)] : α →ₘ γ`. This requires `δ` to have second-countable topology. -/
def comp₂Measurable (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α →ₘ[μ] β)
    (f₂ : α →ₘ[μ] γ) : α →ₘ[μ] δ :=
  compMeasurable _ hg (f₁.pair f₂)
#align measure_theory.ae_eq_fun.comp₂_measurable MeasureTheory.AEEqFun.comp₂Measurable
-/

#print MeasureTheory.AEEqFun.comp₂Measurable_mk_mk /-
@[simp]
theorem comp₂Measurable_mk_mk (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α → β)
    (f₂ : α → γ) (hf₁ hf₂) :
    comp₂Measurable g hg (mk f₁ hf₁ : α →ₘ[μ] β) (mk f₂ hf₂) =
      mk (fun a => g (f₁ a) (f₂ a))
        (hg.comp_aemeasurable (hf₁.AEMeasurable.prod_mk hf₂.AEMeasurable)).AEStronglyMeasurable :=
  rfl
#align measure_theory.ae_eq_fun.comp₂_measurable_mk_mk MeasureTheory.AEEqFun.comp₂Measurable_mk_mk
-/

#print MeasureTheory.AEEqFun.comp₂Measurable_eq_pair /-
theorem comp₂Measurable_eq_pair (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α →ₘ[μ] β)
    (f₂ : α →ₘ[μ] γ) : comp₂Measurable g hg f₁ f₂ = compMeasurable _ hg (f₁.pair f₂) :=
  rfl
#align measure_theory.ae_eq_fun.comp₂_measurable_eq_pair MeasureTheory.AEEqFun.comp₂Measurable_eq_pair
-/

#print MeasureTheory.AEEqFun.comp₂Measurable_eq_mk /-
theorem comp₂Measurable_eq_mk (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α →ₘ[μ] β)
    (f₂ : α →ₘ[μ] γ) :
    comp₂Measurable g hg f₁ f₂ =
      mk (fun a => g (f₁ a) (f₂ a))
        (hg.comp_aemeasurable (f₁.AEMeasurable.prod_mk f₂.AEMeasurable)).AEStronglyMeasurable :=
  by rw [comp₂_measurable_eq_pair, pair_eq_mk, comp_measurable_mk] <;> rfl
#align measure_theory.ae_eq_fun.comp₂_measurable_eq_mk MeasureTheory.AEEqFun.comp₂Measurable_eq_mk
-/

#print MeasureTheory.AEEqFun.coeFn_comp₂Measurable /-
theorem coeFn_comp₂Measurable (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α →ₘ[μ] β)
    (f₂ : α →ₘ[μ] γ) : comp₂Measurable g hg f₁ f₂ =ᵐ[μ] fun a => g (f₁ a) (f₂ a) := by
  rw [comp₂_measurable_eq_mk]; apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_comp₂_measurable MeasureTheory.AEEqFun.coeFn_comp₂Measurable
-/

end

#print MeasureTheory.AEEqFun.toGerm /-
/-- Interpret `f : α →ₘ[μ] β` as a germ at `μ.ae` forgetting that `f` is almost everywhere
    strongly measurable. -/
def toGerm (f : α →ₘ[μ] β) : Germ μ.ae β :=
  Quotient.liftOn' f (fun f => ((f : α → β) : Germ μ.ae β)) fun f g H => Germ.coe_eq.2 H
#align measure_theory.ae_eq_fun.to_germ MeasureTheory.AEEqFun.toGerm
-/

#print MeasureTheory.AEEqFun.mk_toGerm /-
@[simp]
theorem mk_toGerm (f : α → β) (hf) : (mk f hf : α →ₘ[μ] β).toGerm = f :=
  rfl
#align measure_theory.ae_eq_fun.mk_to_germ MeasureTheory.AEEqFun.mk_toGerm
-/

#print MeasureTheory.AEEqFun.toGerm_eq /-
theorem toGerm_eq (f : α →ₘ[μ] β) : f.toGerm = (f : α → β) := by rw [← mk_to_germ, mk_coe_fn]
#align measure_theory.ae_eq_fun.to_germ_eq MeasureTheory.AEEqFun.toGerm_eq
-/

#print MeasureTheory.AEEqFun.toGerm_injective /-
theorem toGerm_injective : Injective (toGerm : (α →ₘ[μ] β) → Germ μ.ae β) := fun f g H =>
  ext <| Germ.coe_eq.1 <| by rwa [← to_germ_eq, ← to_germ_eq]
#align measure_theory.ae_eq_fun.to_germ_injective MeasureTheory.AEEqFun.toGerm_injective
-/

#print MeasureTheory.AEEqFun.comp_toGerm /-
theorem comp_toGerm (g : β → γ) (hg : Continuous g) (f : α →ₘ[μ] β) :
    (comp g hg f).toGerm = f.toGerm.map g :=
  induction_on f fun f hf => by simp
#align measure_theory.ae_eq_fun.comp_to_germ MeasureTheory.AEEqFun.comp_toGerm
-/

#print MeasureTheory.AEEqFun.compMeasurable_toGerm /-
theorem compMeasurable_toGerm [MeasurableSpace β] [BorelSpace β] [PseudoMetrizableSpace β]
    [PseudoMetrizableSpace γ] [SecondCountableTopology γ] [MeasurableSpace γ]
    [OpensMeasurableSpace γ] (g : β → γ) (hg : Measurable g) (f : α →ₘ[μ] β) :
    (compMeasurable g hg f).toGerm = f.toGerm.map g :=
  induction_on f fun f hf => by simp
#align measure_theory.ae_eq_fun.comp_measurable_to_germ MeasureTheory.AEEqFun.compMeasurable_toGerm
-/

#print MeasureTheory.AEEqFun.comp₂_toGerm /-
theorem comp₂_toGerm (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β)
    (f₂ : α →ₘ[μ] γ) : (comp₂ g hg f₁ f₂).toGerm = f₁.toGerm.zipWith g f₂.toGerm :=
  induction_on₂ f₁ f₂ fun f₁ hf₁ f₂ hf₂ => by simp
#align measure_theory.ae_eq_fun.comp₂_to_germ MeasureTheory.AEEqFun.comp₂_toGerm
-/

#print MeasureTheory.AEEqFun.comp₂Measurable_toGerm /-
theorem comp₂Measurable_toGerm [PseudoMetrizableSpace β] [SecondCountableTopology β]
    [MeasurableSpace β] [BorelSpace β] [PseudoMetrizableSpace γ] [SecondCountableTopology γ]
    [MeasurableSpace γ] [BorelSpace γ] [PseudoMetrizableSpace δ] [SecondCountableTopology δ]
    [MeasurableSpace δ] [OpensMeasurableSpace δ] (g : β → γ → δ) (hg : Measurable (uncurry g))
    (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    (comp₂Measurable g hg f₁ f₂).toGerm = f₁.toGerm.zipWith g f₂.toGerm :=
  induction_on₂ f₁ f₂ fun f₁ hf₁ f₂ hf₂ => by simp
#align measure_theory.ae_eq_fun.comp₂_measurable_to_germ MeasureTheory.AEEqFun.comp₂Measurable_toGerm
-/

#print MeasureTheory.AEEqFun.LiftPred /-
/-- Given a predicate `p` and an equivalence class `[f]`, return true if `p` holds of `f a`
    for almost all `a` -/
def LiftPred (p : β → Prop) (f : α →ₘ[μ] β) : Prop :=
  f.toGerm.LiftPred p
#align measure_theory.ae_eq_fun.lift_pred MeasureTheory.AEEqFun.LiftPred
-/

#print MeasureTheory.AEEqFun.LiftRel /-
/-- Given a relation `r` and equivalence class `[f]` and `[g]`, return true if `r` holds of
    `(f a, g a)` for almost all `a` -/
def LiftRel (r : β → γ → Prop) (f : α →ₘ[μ] β) (g : α →ₘ[μ] γ) : Prop :=
  f.toGerm.LiftRel r g.toGerm
#align measure_theory.ae_eq_fun.lift_rel MeasureTheory.AEEqFun.LiftRel
-/

#print MeasureTheory.AEEqFun.liftRel_mk_mk /-
theorem liftRel_mk_mk {r : β → γ → Prop} {f : α → β} {g : α → γ} {hf hg} :
    LiftRel r (mk f hf : α →ₘ[μ] β) (mk g hg) ↔ ∀ᵐ a ∂μ, r (f a) (g a) :=
  Iff.rfl
#align measure_theory.ae_eq_fun.lift_rel_mk_mk MeasureTheory.AEEqFun.liftRel_mk_mk
-/

#print MeasureTheory.AEEqFun.liftRel_iff_coeFn /-
theorem liftRel_iff_coeFn {r : β → γ → Prop} {f : α →ₘ[μ] β} {g : α →ₘ[μ] γ} :
    LiftRel r f g ↔ ∀ᵐ a ∂μ, r (f a) (g a) := by rw [← lift_rel_mk_mk, mk_coe_fn, mk_coe_fn]
#align measure_theory.ae_eq_fun.lift_rel_iff_coe_fn MeasureTheory.AEEqFun.liftRel_iff_coeFn
-/

section Order

instance [Preorder β] : Preorder (α →ₘ[μ] β) :=
  Preorder.lift toGerm

#print MeasureTheory.AEEqFun.mk_le_mk /-
@[simp]
theorem mk_le_mk [Preorder β] {f g : α → β} (hf hg) : (mk f hf : α →ₘ[μ] β) ≤ mk g hg ↔ f ≤ᵐ[μ] g :=
  Iff.rfl
#align measure_theory.ae_eq_fun.mk_le_mk MeasureTheory.AEEqFun.mk_le_mk
-/

#print MeasureTheory.AEEqFun.coeFn_le /-
@[simp, norm_cast]
theorem coeFn_le [Preorder β] {f g : α →ₘ[μ] β} : (f : α → β) ≤ᵐ[μ] g ↔ f ≤ g :=
  liftRel_iff_coeFn.symm
#align measure_theory.ae_eq_fun.coe_fn_le MeasureTheory.AEEqFun.coeFn_le
-/

instance [PartialOrder β] : PartialOrder (α →ₘ[μ] β) :=
  PartialOrder.lift toGerm toGerm_injective

section Lattice

section Sup

variable [SemilatticeSup β] [ContinuousSup β]

instance : Sup (α →ₘ[μ] β) where sup f g := AEEqFun.comp₂ (· ⊔ ·) continuous_sup f g

#print MeasureTheory.AEEqFun.coeFn_sup /-
theorem coeFn_sup (f g : α →ₘ[μ] β) : ⇑(f ⊔ g) =ᵐ[μ] fun x => f x ⊔ g x :=
  coeFn_comp₂ _ _ _ _
#align measure_theory.ae_eq_fun.coe_fn_sup MeasureTheory.AEEqFun.coeFn_sup
-/

#print MeasureTheory.AEEqFun.le_sup_left /-
protected theorem le_sup_left (f g : α →ₘ[μ] β) : f ≤ f ⊔ g := by rw [← coe_fn_le];
  filter_upwards [coe_fn_sup f g] with _ ha; rw [ha]; exact le_sup_left
#align measure_theory.ae_eq_fun.le_sup_left MeasureTheory.AEEqFun.le_sup_left
-/

#print MeasureTheory.AEEqFun.le_sup_right /-
protected theorem le_sup_right (f g : α →ₘ[μ] β) : g ≤ f ⊔ g := by rw [← coe_fn_le];
  filter_upwards [coe_fn_sup f g] with _ ha; rw [ha]; exact le_sup_right
#align measure_theory.ae_eq_fun.le_sup_right MeasureTheory.AEEqFun.le_sup_right
-/

#print MeasureTheory.AEEqFun.sup_le /-
protected theorem sup_le (f g f' : α →ₘ[μ] β) (hf : f ≤ f') (hg : g ≤ f') : f ⊔ g ≤ f' :=
  by
  rw [← coe_fn_le] at hf hg ⊢
  filter_upwards [hf, hg, coe_fn_sup f g] with _ haf hag ha_sup
  rw [ha_sup]
  exact sup_le haf hag
#align measure_theory.ae_eq_fun.sup_le MeasureTheory.AEEqFun.sup_le
-/

end Sup

section Inf

variable [SemilatticeInf β] [ContinuousInf β]

instance : Inf (α →ₘ[μ] β) where inf f g := AEEqFun.comp₂ (· ⊓ ·) continuous_inf f g

#print MeasureTheory.AEEqFun.coeFn_inf /-
theorem coeFn_inf (f g : α →ₘ[μ] β) : ⇑(f ⊓ g) =ᵐ[μ] fun x => f x ⊓ g x :=
  coeFn_comp₂ _ _ _ _
#align measure_theory.ae_eq_fun.coe_fn_inf MeasureTheory.AEEqFun.coeFn_inf
-/

#print MeasureTheory.AEEqFun.inf_le_left /-
protected theorem inf_le_left (f g : α →ₘ[μ] β) : f ⊓ g ≤ f := by rw [← coe_fn_le];
  filter_upwards [coe_fn_inf f g] with _ ha; rw [ha]; exact inf_le_left
#align measure_theory.ae_eq_fun.inf_le_left MeasureTheory.AEEqFun.inf_le_left
-/

#print MeasureTheory.AEEqFun.inf_le_right /-
protected theorem inf_le_right (f g : α →ₘ[μ] β) : f ⊓ g ≤ g := by rw [← coe_fn_le];
  filter_upwards [coe_fn_inf f g] with _ ha; rw [ha]; exact inf_le_right
#align measure_theory.ae_eq_fun.inf_le_right MeasureTheory.AEEqFun.inf_le_right
-/

#print MeasureTheory.AEEqFun.le_inf /-
protected theorem le_inf (f' f g : α →ₘ[μ] β) (hf : f' ≤ f) (hg : f' ≤ g) : f' ≤ f ⊓ g :=
  by
  rw [← coe_fn_le] at hf hg ⊢
  filter_upwards [hf, hg, coe_fn_inf f g] with _ haf hag ha_inf
  rw [ha_inf]
  exact le_inf haf hag
#align measure_theory.ae_eq_fun.le_inf MeasureTheory.AEEqFun.le_inf
-/

end Inf

instance [Lattice β] [TopologicalLattice β] : Lattice (α →ₘ[μ] β) :=
  { AEEqFun.instPartialOrder with
    sup := Sup.sup
    le_sup_left := AEEqFun.le_sup_left
    le_sup_right := AEEqFun.le_sup_right
    sup_le := AEEqFun.sup_le
    inf := Inf.inf
    inf_le_left := AEEqFun.inf_le_left
    inf_le_right := AEEqFun.inf_le_right
    le_inf := AEEqFun.le_inf }

end Lattice

end Order

variable (α)

#print MeasureTheory.AEEqFun.const /-
/-- The equivalence class of a constant function: `[λ a:α, b]`, based on the equivalence relation of
    being almost everywhere equal -/
def const (b : β) : α →ₘ[μ] β :=
  mk (fun a : α => b) aestronglyMeasurable_const
#align measure_theory.ae_eq_fun.const MeasureTheory.AEEqFun.const
-/

#print MeasureTheory.AEEqFun.coeFn_const /-
theorem coeFn_const (b : β) : (const α b : α →ₘ[μ] β) =ᵐ[μ] Function.const α b :=
  coeFn_mk _ _
#align measure_theory.ae_eq_fun.coe_fn_const MeasureTheory.AEEqFun.coeFn_const
-/

variable {α}

instance [Inhabited β] : Inhabited (α →ₘ[μ] β) :=
  ⟨const α default⟩

@[to_additive]
instance [One β] : One (α →ₘ[μ] β) :=
  ⟨const α 1⟩

#print MeasureTheory.AEEqFun.one_def /-
@[to_additive]
theorem one_def [One β] : (1 : α →ₘ[μ] β) = mk (fun a : α => 1) aestronglyMeasurable_const :=
  rfl
#align measure_theory.ae_eq_fun.one_def MeasureTheory.AEEqFun.one_def
#align measure_theory.ae_eq_fun.zero_def MeasureTheory.AEEqFun.zero_def
-/

#print MeasureTheory.AEEqFun.coeFn_one /-
@[to_additive]
theorem coeFn_one [One β] : ⇑(1 : α →ₘ[μ] β) =ᵐ[μ] 1 :=
  coeFn_const _ _
#align measure_theory.ae_eq_fun.coe_fn_one MeasureTheory.AEEqFun.coeFn_one
#align measure_theory.ae_eq_fun.coe_fn_zero MeasureTheory.AEEqFun.coeFn_zero
-/

#print MeasureTheory.AEEqFun.one_toGerm /-
@[simp, to_additive]
theorem one_toGerm [One β] : (1 : α →ₘ[μ] β).toGerm = 1 :=
  rfl
#align measure_theory.ae_eq_fun.one_to_germ MeasureTheory.AEEqFun.one_toGerm
#align measure_theory.ae_eq_fun.zero_to_germ MeasureTheory.AEEqFun.zero_toGerm
-/

-- Note we set up the scalar actions before the `monoid` structures in case we want to
-- try to override the `nsmul` or `zsmul` fields in future.
section SMul

variable {𝕜 𝕜' : Type _}

variable [SMul 𝕜 γ] [ContinuousConstSMul 𝕜 γ]

variable [SMul 𝕜' γ] [ContinuousConstSMul 𝕜' γ]

instance : SMul 𝕜 (α →ₘ[μ] γ) :=
  ⟨fun c f => comp ((· • ·) c) (continuous_id.const_smul c) f⟩

#print MeasureTheory.AEEqFun.smul_mk /-
@[simp]
theorem smul_mk (c : 𝕜) (f : α → γ) (hf : AEStronglyMeasurable f μ) :
    c • (mk f hf : α →ₘ[μ] γ) = mk (c • f) (hf.const_smul _) :=
  rfl
#align measure_theory.ae_eq_fun.smul_mk MeasureTheory.AEEqFun.smul_mk
-/

#print MeasureTheory.AEEqFun.coeFn_smul /-
theorem coeFn_smul (c : 𝕜) (f : α →ₘ[μ] γ) : ⇑(c • f) =ᵐ[μ] c • f :=
  coeFn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_smul MeasureTheory.AEEqFun.coeFn_smul
-/

#print MeasureTheory.AEEqFun.smul_toGerm /-
theorem smul_toGerm (c : 𝕜) (f : α →ₘ[μ] γ) : (c • f).toGerm = c • f.toGerm :=
  comp_toGerm _ _ _
#align measure_theory.ae_eq_fun.smul_to_germ MeasureTheory.AEEqFun.smul_toGerm
-/

instance [SMulCommClass 𝕜 𝕜' γ] : SMulCommClass 𝕜 𝕜' (α →ₘ[μ] γ) :=
  ⟨fun a b f => induction_on f fun f hf => by simp_rw [smul_mk, smul_comm]⟩

instance [SMul 𝕜 𝕜'] [IsScalarTower 𝕜 𝕜' γ] : IsScalarTower 𝕜 𝕜' (α →ₘ[μ] γ) :=
  ⟨fun a b f => induction_on f fun f hf => by simp_rw [smul_mk, smul_assoc]⟩

instance [SMul 𝕜ᵐᵒᵖ γ] [IsCentralScalar 𝕜 γ] : IsCentralScalar 𝕜 (α →ₘ[μ] γ) :=
  ⟨fun a f => induction_on f fun f hf => by simp_rw [smul_mk, op_smul_eq_smul]⟩

end SMul

section Mul

variable [Mul γ] [ContinuousMul γ]

@[to_additive]
instance : Mul (α →ₘ[μ] γ) :=
  ⟨comp₂ (· * ·) continuous_mul⟩

#print MeasureTheory.AEEqFun.mk_mul_mk /-
@[simp, to_additive]
theorem mk_mul_mk (f g : α → γ) (hf : AEStronglyMeasurable f μ) (hg : AEStronglyMeasurable g μ) :
    (mk f hf : α →ₘ[μ] γ) * mk g hg = mk (f * g) (hf.mul hg) :=
  rfl
#align measure_theory.ae_eq_fun.mk_mul_mk MeasureTheory.AEEqFun.mk_mul_mk
#align measure_theory.ae_eq_fun.mk_add_mk MeasureTheory.AEEqFun.mk_add_mk
-/

#print MeasureTheory.AEEqFun.coeFn_mul /-
@[to_additive]
theorem coeFn_mul (f g : α →ₘ[μ] γ) : ⇑(f * g) =ᵐ[μ] f * g :=
  coeFn_comp₂ _ _ _ _
#align measure_theory.ae_eq_fun.coe_fn_mul MeasureTheory.AEEqFun.coeFn_mul
#align measure_theory.ae_eq_fun.coe_fn_add MeasureTheory.AEEqFun.coeFn_add
-/

#print MeasureTheory.AEEqFun.mul_toGerm /-
@[simp, to_additive]
theorem mul_toGerm (f g : α →ₘ[μ] γ) : (f * g).toGerm = f.toGerm * g.toGerm :=
  comp₂_toGerm _ _ _ _
#align measure_theory.ae_eq_fun.mul_to_germ MeasureTheory.AEEqFun.mul_toGerm
#align measure_theory.ae_eq_fun.add_to_germ MeasureTheory.AEEqFun.add_toGerm
-/

end Mul

instance [AddMonoid γ] [ContinuousAdd γ] : AddMonoid (α →ₘ[μ] γ) :=
  toGerm_injective.AddMonoid toGerm zero_toGerm add_toGerm fun _ _ => smul_toGerm _ _

instance [AddCommMonoid γ] [ContinuousAdd γ] : AddCommMonoid (α →ₘ[μ] γ) :=
  toGerm_injective.AddCommMonoid toGerm zero_toGerm add_toGerm fun _ _ => smul_toGerm _ _

section Monoid

variable [Monoid γ] [ContinuousMul γ]

instance : Pow (α →ₘ[μ] γ) ℕ :=
  ⟨fun f n => comp _ (continuous_pow n) f⟩

#print MeasureTheory.AEEqFun.mk_pow /-
@[simp]
theorem mk_pow (f : α → γ) (hf) (n : ℕ) :
    (mk f hf : α →ₘ[μ] γ) ^ n = mk (f ^ n) ((continuous_pow n).comp_aestronglyMeasurable hf) :=
  rfl
#align measure_theory.ae_eq_fun.mk_pow MeasureTheory.AEEqFun.mk_pow
-/

#print MeasureTheory.AEEqFun.coeFn_pow /-
theorem coeFn_pow (f : α →ₘ[μ] γ) (n : ℕ) : ⇑(f ^ n) =ᵐ[μ] f ^ n :=
  coeFn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_pow MeasureTheory.AEEqFun.coeFn_pow
-/

#print MeasureTheory.AEEqFun.pow_toGerm /-
@[simp]
theorem pow_toGerm (f : α →ₘ[μ] γ) (n : ℕ) : (f ^ n).toGerm = f.toGerm ^ n :=
  comp_toGerm _ _ _
#align measure_theory.ae_eq_fun.pow_to_germ MeasureTheory.AEEqFun.pow_toGerm
-/

@[to_additive]
instance : Monoid (α →ₘ[μ] γ) :=
  toGerm_injective.Monoid toGerm one_toGerm mul_toGerm pow_toGerm

#print MeasureTheory.AEEqFun.toGermMonoidHom /-
/-- `ae_eq_fun.to_germ` as a `monoid_hom`. -/
@[to_additive "`ae_eq_fun.to_germ` as an `add_monoid_hom`.", simps]
def toGermMonoidHom : (α →ₘ[μ] γ) →* μ.ae.Germ γ
    where
  toFun := toGerm
  map_one' := one_toGerm
  map_mul' := mul_toGerm
#align measure_theory.ae_eq_fun.to_germ_monoid_hom MeasureTheory.AEEqFun.toGermMonoidHom
#align measure_theory.ae_eq_fun.to_germ_add_monoid_hom MeasureTheory.AEEqFun.toGermAddMonoidHom
-/

end Monoid

@[to_additive]
instance [CommMonoid γ] [ContinuousMul γ] : CommMonoid (α →ₘ[μ] γ) :=
  toGerm_injective.CommMonoid toGerm one_toGerm mul_toGerm pow_toGerm

section Group

variable [Group γ] [TopologicalGroup γ]

section Inv

@[to_additive]
instance : Inv (α →ₘ[μ] γ) :=
  ⟨comp Inv.inv continuous_inv⟩

#print MeasureTheory.AEEqFun.inv_mk /-
@[simp, to_additive]
theorem inv_mk (f : α → γ) (hf) : (mk f hf : α →ₘ[μ] γ)⁻¹ = mk f⁻¹ hf.inv :=
  rfl
#align measure_theory.ae_eq_fun.inv_mk MeasureTheory.AEEqFun.inv_mk
#align measure_theory.ae_eq_fun.neg_mk MeasureTheory.AEEqFun.neg_mk
-/

#print MeasureTheory.AEEqFun.coeFn_inv /-
@[to_additive]
theorem coeFn_inv (f : α →ₘ[μ] γ) : ⇑f⁻¹ =ᵐ[μ] f⁻¹ :=
  coeFn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_inv MeasureTheory.AEEqFun.coeFn_inv
#align measure_theory.ae_eq_fun.coe_fn_neg MeasureTheory.AEEqFun.coeFn_neg
-/

#print MeasureTheory.AEEqFun.inv_toGerm /-
@[to_additive]
theorem inv_toGerm (f : α →ₘ[μ] γ) : f⁻¹.toGerm = f.toGerm⁻¹ :=
  comp_toGerm _ _ _
#align measure_theory.ae_eq_fun.inv_to_germ MeasureTheory.AEEqFun.inv_toGerm
#align measure_theory.ae_eq_fun.neg_to_germ MeasureTheory.AEEqFun.neg_toGerm
-/

end Inv

section Div

@[to_additive]
instance : Div (α →ₘ[μ] γ) :=
  ⟨comp₂ Div.div continuous_div'⟩

#print MeasureTheory.AEEqFun.mk_div /-
@[simp, to_additive]
theorem mk_div (f g : α → γ) (hf : AEStronglyMeasurable f μ) (hg : AEStronglyMeasurable g μ) :
    mk (f / g) (hf.div hg) = (mk f hf : α →ₘ[μ] γ) / mk g hg :=
  rfl
#align measure_theory.ae_eq_fun.mk_div MeasureTheory.AEEqFun.mk_div
#align measure_theory.ae_eq_fun.mk_sub MeasureTheory.AEEqFun.mk_sub
-/

#print MeasureTheory.AEEqFun.coeFn_div /-
@[to_additive]
theorem coeFn_div (f g : α →ₘ[μ] γ) : ⇑(f / g) =ᵐ[μ] f / g :=
  coeFn_comp₂ _ _ _ _
#align measure_theory.ae_eq_fun.coe_fn_div MeasureTheory.AEEqFun.coeFn_div
#align measure_theory.ae_eq_fun.coe_fn_sub MeasureTheory.AEEqFun.coeFn_sub
-/

#print MeasureTheory.AEEqFun.div_toGerm /-
@[to_additive]
theorem div_toGerm (f g : α →ₘ[μ] γ) : (f / g).toGerm = f.toGerm / g.toGerm :=
  comp₂_toGerm _ _ _ _
#align measure_theory.ae_eq_fun.div_to_germ MeasureTheory.AEEqFun.div_toGerm
#align measure_theory.ae_eq_fun.sub_to_germ MeasureTheory.AEEqFun.sub_toGerm
-/

end Div

section Zpow

#print MeasureTheory.AEEqFun.instPowInt /-
instance instPowInt : Pow (α →ₘ[μ] γ) ℤ :=
  ⟨fun f n => comp _ (continuous_zpow n) f⟩
#align measure_theory.ae_eq_fun.has_int_pow MeasureTheory.AEEqFun.instPowInt
-/

#print MeasureTheory.AEEqFun.mk_zpow /-
@[simp]
theorem mk_zpow (f : α → γ) (hf) (n : ℤ) :
    (mk f hf : α →ₘ[μ] γ) ^ n = mk (f ^ n) ((continuous_zpow n).comp_aestronglyMeasurable hf) :=
  rfl
#align measure_theory.ae_eq_fun.mk_zpow MeasureTheory.AEEqFun.mk_zpow
-/

#print MeasureTheory.AEEqFun.coeFn_zpow /-
theorem coeFn_zpow (f : α →ₘ[μ] γ) (n : ℤ) : ⇑(f ^ n) =ᵐ[μ] f ^ n :=
  coeFn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_zpow MeasureTheory.AEEqFun.coeFn_zpow
-/

#print MeasureTheory.AEEqFun.zpow_toGerm /-
@[simp]
theorem zpow_toGerm (f : α →ₘ[μ] γ) (n : ℤ) : (f ^ n).toGerm = f.toGerm ^ n :=
  comp_toGerm _ _ _
#align measure_theory.ae_eq_fun.zpow_to_germ MeasureTheory.AEEqFun.zpow_toGerm
-/

end Zpow

end Group

instance [AddGroup γ] [TopologicalAddGroup γ] : AddGroup (α →ₘ[μ] γ) :=
  toGerm_injective.AddGroup toGerm zero_toGerm add_toGerm neg_toGerm sub_toGerm
    (fun _ _ => smul_toGerm _ _) fun _ _ => smul_toGerm _ _

instance [AddCommGroup γ] [TopologicalAddGroup γ] : AddCommGroup (α →ₘ[μ] γ) :=
  toGerm_injective.AddCommGroup toGerm zero_toGerm add_toGerm neg_toGerm sub_toGerm
    (fun _ _ => smul_toGerm _ _) fun _ _ => smul_toGerm _ _

@[to_additive]
instance [Group γ] [TopologicalGroup γ] : Group (α →ₘ[μ] γ) :=
  toGerm_injective.Group _ one_toGerm mul_toGerm inv_toGerm div_toGerm pow_toGerm zpow_toGerm

@[to_additive]
instance [CommGroup γ] [TopologicalGroup γ] : CommGroup (α →ₘ[μ] γ) :=
  toGerm_injective.CommGroup _ one_toGerm mul_toGerm inv_toGerm div_toGerm pow_toGerm zpow_toGerm

section Module

variable {𝕜 : Type _}

instance [Monoid 𝕜] [MulAction 𝕜 γ] [ContinuousConstSMul 𝕜 γ] : MulAction 𝕜 (α →ₘ[μ] γ) :=
  toGerm_injective.MulAction toGerm smul_toGerm

instance [Monoid 𝕜] [AddMonoid γ] [ContinuousAdd γ] [DistribMulAction 𝕜 γ]
    [ContinuousConstSMul 𝕜 γ] : DistribMulAction 𝕜 (α →ₘ[μ] γ) :=
  toGerm_injective.DistribMulAction (toGermAddMonoidHom : (α →ₘ[μ] γ) →+ _) fun c : 𝕜 =>
    smul_toGerm c

instance [Semiring 𝕜] [AddCommMonoid γ] [ContinuousAdd γ] [Module 𝕜 γ] [ContinuousConstSMul 𝕜 γ] :
    Module 𝕜 (α →ₘ[μ] γ) :=
  toGerm_injective.Module 𝕜 (toGermAddMonoidHom : (α →ₘ[μ] γ) →+ _) smul_toGerm

end Module

open ENNReal

#print MeasureTheory.AEEqFun.lintegral /-
/-- For `f : α → ℝ≥0∞`, define `∫ [f]` to be `∫ f` -/
def lintegral (f : α →ₘ[μ] ℝ≥0∞) : ℝ≥0∞ :=
  Quotient.liftOn' f (fun f => ∫⁻ a, (f : α → ℝ≥0∞) a ∂μ) fun f g => lintegral_congr_ae
#align measure_theory.ae_eq_fun.lintegral MeasureTheory.AEEqFun.lintegral
-/

#print MeasureTheory.AEEqFun.lintegral_mk /-
@[simp]
theorem lintegral_mk (f : α → ℝ≥0∞) (hf) : (mk f hf : α →ₘ[μ] ℝ≥0∞).lintegral = ∫⁻ a, f a ∂μ :=
  rfl
#align measure_theory.ae_eq_fun.lintegral_mk MeasureTheory.AEEqFun.lintegral_mk
-/

#print MeasureTheory.AEEqFun.lintegral_coeFn /-
theorem lintegral_coeFn (f : α →ₘ[μ] ℝ≥0∞) : ∫⁻ a, f a ∂μ = f.lintegral := by
  rw [← lintegral_mk, mk_coe_fn]
#align measure_theory.ae_eq_fun.lintegral_coe_fn MeasureTheory.AEEqFun.lintegral_coeFn
-/

#print MeasureTheory.AEEqFun.lintegral_zero /-
@[simp]
theorem lintegral_zero : lintegral (0 : α →ₘ[μ] ℝ≥0∞) = 0 :=
  lintegral_zero
#align measure_theory.ae_eq_fun.lintegral_zero MeasureTheory.AEEqFun.lintegral_zero
-/

#print MeasureTheory.AEEqFun.lintegral_eq_zero_iff /-
@[simp]
theorem lintegral_eq_zero_iff {f : α →ₘ[μ] ℝ≥0∞} : lintegral f = 0 ↔ f = 0 :=
  induction_on f fun f hf => (lintegral_eq_zero_iff' hf.AEMeasurable).trans mk_eq_mk.symm
#align measure_theory.ae_eq_fun.lintegral_eq_zero_iff MeasureTheory.AEEqFun.lintegral_eq_zero_iff
-/

#print MeasureTheory.AEEqFun.lintegral_add /-
theorem lintegral_add (f g : α →ₘ[μ] ℝ≥0∞) : lintegral (f + g) = lintegral f + lintegral g :=
  induction_on₂ f g fun f hf g hg => by simp [lintegral_add_left' hf.ae_measurable]
#align measure_theory.ae_eq_fun.lintegral_add MeasureTheory.AEEqFun.lintegral_add
-/

#print MeasureTheory.AEEqFun.lintegral_mono /-
theorem lintegral_mono {f g : α →ₘ[μ] ℝ≥0∞} : f ≤ g → lintegral f ≤ lintegral g :=
  induction_on₂ f g fun f hf g hg hfg => lintegral_mono_ae hfg
#align measure_theory.ae_eq_fun.lintegral_mono MeasureTheory.AEEqFun.lintegral_mono
-/

section Abs

#print MeasureTheory.AEEqFun.coeFn_abs /-
theorem coeFn_abs {β} [TopologicalSpace β] [Lattice β] [TopologicalLattice β] [AddGroup β]
    [TopologicalAddGroup β] (f : α →ₘ[μ] β) : ⇑(|f|) =ᵐ[μ] fun x => |f x| :=
  by
  simp_rw [abs_eq_sup_neg]
  filter_upwards [ae_eq_fun.coe_fn_sup f (-f), ae_eq_fun.coe_fn_neg f] with x hx_sup hx_neg
  rw [hx_sup, hx_neg, Pi.neg_apply]
#align measure_theory.ae_eq_fun.coe_fn_abs MeasureTheory.AEEqFun.coeFn_abs
-/

end Abs

section PosPart

variable [LinearOrder γ] [OrderClosedTopology γ] [Zero γ]

#print MeasureTheory.AEEqFun.posPart /-
/-- Positive part of an `ae_eq_fun`. -/
def posPart (f : α →ₘ[μ] γ) : α →ₘ[μ] γ :=
  comp (fun x => max x 0) (continuous_id.max continuous_const) f
#align measure_theory.ae_eq_fun.pos_part MeasureTheory.AEEqFun.posPart
-/

#print MeasureTheory.AEEqFun.posPart_mk /-
@[simp]
theorem posPart_mk (f : α → γ) (hf) :
    posPart (mk f hf : α →ₘ[μ] γ) =
      mk (fun x => max (f x) 0)
        ((continuous_id.max continuous_const).comp_aestronglyMeasurable hf) :=
  rfl
#align measure_theory.ae_eq_fun.pos_part_mk MeasureTheory.AEEqFun.posPart_mk
-/

#print MeasureTheory.AEEqFun.coeFn_posPart /-
theorem coeFn_posPart (f : α →ₘ[μ] γ) : ⇑(posPart f) =ᵐ[μ] fun a => max (f a) 0 :=
  coeFn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_pos_part MeasureTheory.AEEqFun.coeFn_posPart
-/

end PosPart

end AeEqFun

end MeasureTheory

namespace ContinuousMap

open MeasureTheory

variable [TopologicalSpace α] [BorelSpace α] (μ)

variable [TopologicalSpace β] [SecondCountableTopologyEither α β] [PseudoMetrizableSpace β]

#print ContinuousMap.toAEEqFun /-
/-- The equivalence class of `μ`-almost-everywhere measurable functions associated to a continuous
map. -/
def toAEEqFun (f : C(α, β)) : α →ₘ[μ] β :=
  AEEqFun.mk f f.Continuous.AEStronglyMeasurable
#align continuous_map.to_ae_eq_fun ContinuousMap.toAEEqFun
-/

#print ContinuousMap.coeFn_toAEEqFun /-
theorem coeFn_toAEEqFun (f : C(α, β)) : f.toAEEqFun μ =ᵐ[μ] f :=
  AEEqFun.coeFn_mk f _
#align continuous_map.coe_fn_to_ae_eq_fun ContinuousMap.coeFn_toAEEqFun
-/

variable [Group β] [TopologicalGroup β]

#print ContinuousMap.toAEEqFunMulHom /-
/-- The `mul_hom` from the group of continuous maps from `α` to `β` to the group of equivalence
classes of `μ`-almost-everywhere measurable functions. -/
@[to_additive
      "The `add_hom` from the group of continuous maps from `α` to `β` to the group of\nequivalence classes of `μ`-almost-everywhere measurable functions."]
def toAEEqFunMulHom : C(α, β) →* α →ₘ[μ] β
    where
  toFun := ContinuousMap.toAEEqFun μ
  map_one' := rfl
  map_mul' f g :=
    AEEqFun.mk_mul_mk _ _ f.Continuous.AEStronglyMeasurable g.Continuous.AEStronglyMeasurable
#align continuous_map.to_ae_eq_fun_mul_hom ContinuousMap.toAEEqFunMulHom
#align continuous_map.to_ae_eq_fun_add_hom ContinuousMap.toAEEqFunAddHom
-/

variable {𝕜 : Type _} [Semiring 𝕜]

variable [TopologicalSpace γ] [PseudoMetrizableSpace γ] [AddCommGroup γ] [Module 𝕜 γ]
  [TopologicalAddGroup γ] [ContinuousConstSMul 𝕜 γ] [SecondCountableTopologyEither α γ]

#print ContinuousMap.toAEEqFunLinearMap /-
/-- The linear map from the group of continuous maps from `α` to `β` to the group of equivalence
classes of `μ`-almost-everywhere measurable functions. -/
def toAEEqFunLinearMap : C(α, γ) →ₗ[𝕜] α →ₘ[μ] γ :=
  { toAEEqFunAddHom μ with
    map_smul' := fun c f => AEEqFun.smul_mk c f f.Continuous.AEStronglyMeasurable }
#align continuous_map.to_ae_eq_fun_linear_map ContinuousMap.toAEEqFunLinearMap
-/

end ContinuousMap

-- Guard against import creep
assert_not_exists InnerProductSpace

