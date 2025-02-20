/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module set_theory.ordinal.cantor_normal_form
! leanprover-community/mathlib commit 991ff3b5269848f6dd942ae8e9dd3c946035dc8b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.SetTheory.Ordinal.Arithmetic
import Mathbin.SetTheory.Ordinal.Exponential

/-!
# Cantor Normal Form

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The Cantor normal form of an ordinal is generally defined as its base `ω` expansion, with its
non-zero exponents in decreasing order. Here, we more generally define a base `b` expansion
`ordinal.CNF` in this manner, which is well-behaved for any `b ≥ 2`.

# Implementation notes

We implement `ordinal.CNF` as an association list, where keys are exponents and values are
coefficients. This is because this structure intrinsically reflects two key properties of the Cantor
normal form:

- It is ordered.
- It has finitely many entries.

# Todo

- Add API for the coefficients of the Cantor normal form.
- Prove the basic results relating the CNF to the arithmetic operations on ordinals.
-/


noncomputable section

universe u

open List

namespace Ordinal

#print Ordinal.CNFRec /-
/-- Inducts on the base `b` expansion of an ordinal. -/
@[elab_as_elim]
noncomputable def CNFRec (b : Ordinal) {C : Ordinal → Sort _} (H0 : C 0)
    (H : ∀ o, o ≠ 0 → C (o % b ^ log b o) → C o) : ∀ o, C o
  | o =>
    if ho : o = 0 then by rwa [ho]
    else
      let hwf := mod_opow_log_lt_self b ho
      H o ho (CNF_rec (o % b ^ log b o))
#align ordinal.CNF_rec Ordinal.CNFRec
-/

#print Ordinal.CNFRec_zero /-
@[simp]
theorem CNFRec_zero {C : Ordinal → Sort _} (b : Ordinal) (H0 : C 0)
    (H : ∀ o, o ≠ 0 → C (o % b ^ log b o) → C o) : @CNFRec b C H0 H 0 = H0 := by
  rw [CNF_rec, dif_pos rfl]; rfl
#align ordinal.CNF_rec_zero Ordinal.CNFRec_zero
-/

#print Ordinal.CNFRec_pos /-
theorem CNFRec_pos (b : Ordinal) {o : Ordinal} {C : Ordinal → Sort _} (ho : o ≠ 0) (H0 : C 0)
    (H : ∀ o, o ≠ 0 → C (o % b ^ log b o) → C o) :
    @CNFRec b C H0 H o = H o ho (@CNFRec b C H0 H _) := by rw [CNF_rec, dif_neg ho]
#align ordinal.CNF_rec_pos Ordinal.CNFRec_pos
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Ordinal.CNF /-
/-- The Cantor normal form of an ordinal `o` is the list of coefficients and exponents in the
base-`b` expansion of `o`.

We special-case `CNF 0 o = CNF 1 o = [(0, o)]` for `o ≠ 0`.

`CNF b (b ^ u₁ * v₁ + b ^ u₂ * v₂) = [(u₁, v₁), (u₂, v₂)]` -/
@[pp_nodot]
def CNF (b o : Ordinal) : List (Ordinal × Ordinal) :=
  CNFRec b [] (fun o ho IH => (log b o, o / b ^ log b o)::IH) o
#align ordinal.CNF Ordinal.CNF
-/

#print Ordinal.CNF_zero /-
@[simp]
theorem CNF_zero (b : Ordinal) : CNF b 0 = [] :=
  CNFRec_zero b _ _
#align ordinal.CNF_zero Ordinal.CNF_zero
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Ordinal.CNF_ne_zero /-
/-- Recursive definition for the Cantor normal form. -/
theorem CNF_ne_zero {b o : Ordinal} (ho : o ≠ 0) :
    CNF b o = (log b o, o / b ^ log b o)::CNF b (o % b ^ log b o) :=
  CNFRec_pos b ho _ _
#align ordinal.CNF_ne_zero Ordinal.CNF_ne_zero
-/

#print Ordinal.zero_CNF /-
theorem zero_CNF {o : Ordinal} (ho : o ≠ 0) : CNF 0 o = [⟨0, o⟩] := by simp [CNF_ne_zero ho]
#align ordinal.zero_CNF Ordinal.zero_CNF
-/

#print Ordinal.one_CNF /-
theorem one_CNF {o : Ordinal} (ho : o ≠ 0) : CNF 1 o = [⟨0, o⟩] := by simp [CNF_ne_zero ho]
#align ordinal.one_CNF Ordinal.one_CNF
-/

#print Ordinal.CNF_of_le_one /-
theorem CNF_of_le_one {b o : Ordinal} (hb : b ≤ 1) (ho : o ≠ 0) : CNF b o = [⟨0, o⟩] :=
  by
  rcases le_one_iff.1 hb with (rfl | rfl)
  · exact zero_CNF ho
  · exact one_CNF ho
#align ordinal.CNF_of_le_one Ordinal.CNF_of_le_one
-/

#print Ordinal.CNF_of_lt /-
theorem CNF_of_lt {b o : Ordinal} (ho : o ≠ 0) (hb : o < b) : CNF b o = [⟨0, o⟩] := by
  simp [CNF_ne_zero ho, log_eq_zero hb]
#align ordinal.CNF_of_lt Ordinal.CNF_of_lt
-/

#print Ordinal.CNF_foldr /-
/-- Evaluating the Cantor normal form of an ordinal returns the ordinal. -/
theorem CNF_foldr (b o : Ordinal) : (CNF b o).foldr (fun p r => b ^ p.1 * p.2 + r) 0 = o :=
  CNFRec b (by rw [CNF_zero]; rfl)
    (fun o ho IH => by rw [CNF_ne_zero ho, foldr_cons, IH, div_add_mod]) o
#align ordinal.CNF_foldr Ordinal.CNF_foldr
-/

#print Ordinal.CNF_fst_le_log /-
/-- Every exponent in the Cantor normal form `CNF b o` is less or equal to `log b o`. -/
theorem CNF_fst_le_log {b o : Ordinal.{u}} {x : Ordinal × Ordinal} : x ∈ CNF b o → x.1 ≤ log b o :=
  by
  refine' CNF_rec b _ (fun o ho H => _) o
  · simp
  · rw [CNF_ne_zero ho, mem_cons_iff]
    rintro (rfl | h)
    · exact le_rfl
    · exact (H h).trans (log_mono_right _ (mod_opow_log_lt_self b ho).le)
#align ordinal.CNF_fst_le_log Ordinal.CNF_fst_le_log
-/

#print Ordinal.CNF_fst_le /-
/-- Every exponent in the Cantor normal form `CNF b o` is less or equal to `o`. -/
theorem CNF_fst_le {b o : Ordinal.{u}} {x : Ordinal × Ordinal} (h : x ∈ CNF b o) : x.1 ≤ o :=
  (CNF_fst_le_log h).trans <| log_le_self _ _
#align ordinal.CNF_fst_le Ordinal.CNF_fst_le
-/

#print Ordinal.CNF_lt_snd /-
/-- Every coefficient in a Cantor normal form is positive. -/
theorem CNF_lt_snd {b o : Ordinal.{u}} {x : Ordinal × Ordinal} : x ∈ CNF b o → 0 < x.2 :=
  by
  refine' CNF_rec b _ (fun o ho IH => _) o
  · simp
  · rw [CNF_ne_zero ho]
    rintro (rfl | h)
    · exact div_opow_log_pos b ho
    · exact IH h
#align ordinal.CNF_lt_snd Ordinal.CNF_lt_snd
-/

#print Ordinal.CNF_snd_lt /-
/-- Every coefficient in the Cantor normal form `CNF b o` is less than `b`. -/
theorem CNF_snd_lt {b o : Ordinal.{u}} (hb : 1 < b) {x : Ordinal × Ordinal} :
    x ∈ CNF b o → x.2 < b := by
  refine' CNF_rec b _ (fun o ho IH => _) o
  · simp
  · rw [CNF_ne_zero ho]
    rintro (rfl | h)
    · simpa using div_opow_log_lt o hb
    · exact IH h
#align ordinal.CNF_snd_lt Ordinal.CNF_snd_lt
-/

#print Ordinal.CNF_sorted /-
/-- The exponents of the Cantor normal form are decreasing. -/
theorem CNF_sorted (b o : Ordinal) : ((CNF b o).map Prod.fst).Sorted (· > ·) :=
  by
  refine' CNF_rec b _ (fun o ho IH => _) o
  · simp
  · cases' le_or_lt b 1 with hb hb
    · simp [CNF_of_le_one hb ho]
    · cases' lt_or_le o b with hob hbo
      · simp [CNF_of_lt ho hob]
      · rw [CNF_ne_zero ho, List.map_cons, List.sorted_cons]
        refine' ⟨fun a H => _, IH⟩
        rw [List.mem_map] at H 
        rcases H with ⟨⟨a, a'⟩, H, rfl⟩
        exact (CNF_fst_le_log H).trans_lt (log_mod_opow_log_lt_log_self hb ho hbo)
#align ordinal.CNF_sorted Ordinal.CNF_sorted
-/

end Ordinal

