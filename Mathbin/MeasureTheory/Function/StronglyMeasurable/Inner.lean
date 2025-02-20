/-
Copyright (c) 2021 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne, Sébastien Gouëzel

! This file was ported from Lean 3 source module measure_theory.function.strongly_measurable.inner
! leanprover-community/mathlib commit 0b7c740e25651db0ba63648fbae9f9d6f941e31b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Function.StronglyMeasurable.Basic
import Mathbin.Analysis.InnerProductSpace.Basic

/-!
# Inner products of strongly measurable functions are strongly measurable.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


variable {α : Type _}

namespace MeasureTheory

/-! ## Strongly measurable functions -/


namespace StronglyMeasurable

#print MeasureTheory.StronglyMeasurable.inner /-
protected theorem inner {𝕜 : Type _} {E : Type _} [IsROrC 𝕜] [NormedAddCommGroup E]
    [InnerProductSpace 𝕜 E] {m : MeasurableSpace α} {f g : α → E} (hf : StronglyMeasurable f)
    (hg : StronglyMeasurable g) : StronglyMeasurable fun t => @inner 𝕜 _ _ (f t) (g t) :=
  Continuous.comp_stronglyMeasurable continuous_inner (hf.prod_mk hg)
#align measure_theory.strongly_measurable.inner MeasureTheory.StronglyMeasurable.inner
-/

end StronglyMeasurable

namespace AeStronglyMeasurable

variable {m : MeasurableSpace α} {μ : Measure α} {𝕜 : Type _} {E : Type _} [IsROrC 𝕜]
  [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]

local notation "⟪" x ", " y "⟫" => @inner 𝕜 _ _ x y

#print MeasureTheory.AEStronglyMeasurable.re /-
protected theorem re {f : α → 𝕜} (hf : AEStronglyMeasurable f μ) :
    AEStronglyMeasurable (fun x => IsROrC.re (f x)) μ :=
  IsROrC.continuous_re.comp_aestronglyMeasurable hf
#align measure_theory.ae_strongly_measurable.re MeasureTheory.AEStronglyMeasurable.re
-/

#print MeasureTheory.AEStronglyMeasurable.im /-
protected theorem im {f : α → 𝕜} (hf : AEStronglyMeasurable f μ) :
    AEStronglyMeasurable (fun x => IsROrC.im (f x)) μ :=
  IsROrC.continuous_im.comp_aestronglyMeasurable hf
#align measure_theory.ae_strongly_measurable.im MeasureTheory.AEStronglyMeasurable.im
-/

#print MeasureTheory.AEStronglyMeasurable.inner /-
protected theorem inner {m : MeasurableSpace α} {μ : Measure α} {f g : α → E}
    (hf : AEStronglyMeasurable f μ) (hg : AEStronglyMeasurable g μ) :
    AEStronglyMeasurable (fun x => ⟪f x, g x⟫) μ :=
  continuous_inner.comp_aestronglyMeasurable (hf.prod_mk hg)
#align measure_theory.ae_strongly_measurable.inner MeasureTheory.AEStronglyMeasurable.inner
-/

end AeStronglyMeasurable

end MeasureTheory

