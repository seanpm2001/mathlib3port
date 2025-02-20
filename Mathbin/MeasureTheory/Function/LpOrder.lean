/-
Copyright (c) 2021 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne

! This file was ported from Lean 3 source module measure_theory.function.lp_order
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Normed.Order.Lattice
import Mathbin.MeasureTheory.Function.LpSpace

/-!
# Order related properties of Lp spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

### Results

- `Lp E p μ` is an `ordered_add_comm_group` when `E` is a `normed_lattice_add_comm_group`.

### TODO

- move definitions of `Lp.pos_part` and `Lp.neg_part` to this file, and define them as
  `has_pos_part.pos` and `has_pos_part.neg` given by the lattice structure.

-/


open TopologicalSpace MeasureTheory LatticeOrderedCommGroup

open scoped ENNReal

variable {α E : Type _} {m : MeasurableSpace α} {μ : Measure α} {p : ℝ≥0∞}

namespace MeasureTheory

namespace Lp

section Order

variable [NormedLatticeAddCommGroup E]

#print MeasureTheory.Lp.coeFn_le /-
theorem coeFn_le (f g : Lp E p μ) : f ≤ᵐ[μ] g ↔ f ≤ g := by
  rw [← Subtype.coe_le_coe, ← ae_eq_fun.coe_fn_le, ← coeFn_coeBase, ← coeFn_coeBase]
#align measure_theory.Lp.coe_fn_le MeasureTheory.Lp.coeFn_le
-/

#print MeasureTheory.Lp.coeFn_nonneg /-
theorem coeFn_nonneg (f : Lp E p μ) : 0 ≤ᵐ[μ] f ↔ 0 ≤ f :=
  by
  rw [← coe_fn_le]
  have h0 := Lp.coe_fn_zero E p μ
  constructor <;> intro h <;> filter_upwards [h, h0] with _ _ h2
  · rwa [h2]
  · rwa [← h2]
#align measure_theory.Lp.coe_fn_nonneg MeasureTheory.Lp.coeFn_nonneg
-/

instance : CovariantClass (Lp E p μ) (Lp E p μ) (· + ·) (· ≤ ·) :=
  by
  refine' ⟨fun f g₁ g₂ hg₁₂ => _⟩
  rw [← coe_fn_le] at hg₁₂ ⊢
  filter_upwards [coe_fn_add f g₁, coe_fn_add f g₂, hg₁₂] with _ h1 h2 h3
  rw [h1, h2, Pi.add_apply, Pi.add_apply]
  exact add_le_add le_rfl h3

instance : OrderedAddCommGroup (Lp E p μ) :=
  { Subtype.partialOrder _, AddSubgroup.toAddCommGroup _ with
    add_le_add_left := fun f g => add_le_add_left }

#print MeasureTheory.Memℒp.sup /-
theorem MeasureTheory.Memℒp.sup {f g : α → E} (hf : Memℒp f p μ) (hg : Memℒp g p μ) :
    Memℒp (f ⊔ g) p μ :=
  Memℒp.mono' (hf.norm.add hg.norm) (hf.1.sup hg.1)
    (Filter.eventually_of_forall fun x => norm_sup_le_add (f x) (g x))
#align measure_theory.mem_ℒp.sup MeasureTheory.Memℒp.sup
-/

#print MeasureTheory.Memℒp.inf /-
theorem MeasureTheory.Memℒp.inf {f g : α → E} (hf : Memℒp f p μ) (hg : Memℒp g p μ) :
    Memℒp (f ⊓ g) p μ :=
  Memℒp.mono' (hf.norm.add hg.norm) (hf.1.inf hg.1)
    (Filter.eventually_of_forall fun x => norm_inf_le_add (f x) (g x))
#align measure_theory.mem_ℒp.inf MeasureTheory.Memℒp.inf
-/

#print MeasureTheory.Memℒp.abs /-
theorem MeasureTheory.Memℒp.abs {f : α → E} (hf : Memℒp f p μ) : Memℒp (|f|) p μ :=
  hf.sup hf.neg
#align measure_theory.mem_ℒp.abs MeasureTheory.Memℒp.abs
-/

instance : Lattice (Lp E p μ) :=
  Subtype.lattice
    (fun f g hf hg => by
      rw [mem_Lp_iff_mem_ℒp] at *
      exact (mem_ℒp_congr_ae (ae_eq_fun.coe_fn_sup _ _)).mpr (hf.sup hg))
    fun f g hf hg => by
    rw [mem_Lp_iff_mem_ℒp] at *
    exact (mem_ℒp_congr_ae (ae_eq_fun.coe_fn_inf _ _)).mpr (hf.inf hg)

#print MeasureTheory.Lp.coeFn_sup /-
theorem coeFn_sup (f g : Lp E p μ) : ⇑(f ⊔ g) =ᵐ[μ] ⇑f ⊔ ⇑g :=
  AEEqFun.coeFn_sup _ _
#align measure_theory.Lp.coe_fn_sup MeasureTheory.Lp.coeFn_sup
-/

#print MeasureTheory.Lp.coeFn_inf /-
theorem coeFn_inf (f g : Lp E p μ) : ⇑(f ⊓ g) =ᵐ[μ] ⇑f ⊓ ⇑g :=
  AEEqFun.coeFn_inf _ _
#align measure_theory.Lp.coe_fn_inf MeasureTheory.Lp.coeFn_inf
-/

#print MeasureTheory.Lp.coeFn_abs /-
theorem coeFn_abs (f : Lp E p μ) : ⇑(|f|) =ᵐ[μ] fun x => |f x| :=
  AEEqFun.coeFn_abs _
#align measure_theory.Lp.coe_fn_abs MeasureTheory.Lp.coeFn_abs
-/

noncomputable instance [Fact (1 ≤ p)] : NormedLatticeAddCommGroup (Lp E p μ) :=
  { Lp.instLattice,
    Lp.instNormedAddCommGroup with
    add_le_add_left := fun f g => add_le_add_left
    solid := fun f g hfg => by
      rw [← coe_fn_le] at hfg 
      simp_rw [Lp.norm_def, ENNReal.toReal_le_toReal (Lp.snorm_ne_top f) (Lp.snorm_ne_top g)]
      refine' snorm_mono_ae _
      filter_upwards [hfg, Lp.coe_fn_abs f, Lp.coe_fn_abs g] with x hx hxf hxg
      rw [hxf, hxg] at hx 
      exact HasSolidNorm.solid hx }

end Order

end Lp

end MeasureTheory

