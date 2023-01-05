/-
Copyright (c) 2021 Jordan Brown, Thomas Browning, Patrick Lutz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jordan Brown, Thomas Browning, Patrick Lutz

! This file was ported from Lean 3 source module group_theory.solvable
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fin.VecNotation
import Mathbin.GroupTheory.Abelianization
import Mathbin.GroupTheory.Perm.ViaEmbedding
import Mathbin.SetTheory.Cardinal.Basic

/-!
# Solvable Groups

In this file we introduce the notion of a solvable group. We define a solvable group as one whose
derived series is eventually trivial. This requires defining the commutator of two subgroups and
the derived series of a group.

## Main definitions

* `derived_series G n` : the `n`th term in the derived series of `G`, defined by iterating
    `general_commutator` starting with the top subgroup
* `is_solvable G` : the group `G` is solvable
-/


open Subgroup

variable {G G' : Type _} [Group G] [Group G'] {f : G →* G'}

section derivedSeries

variable (G)

/-- The derived series of the group `G`, obtained by starting from the subgroup `⊤` and repeatedly
  taking the commutator of the previous subgroup with itself for `n` times. -/
def derivedSeries : ℕ → Subgroup G
  | 0 => ⊤
  | n + 1 => ⁅derivedSeries n, derivedSeries n⁆
#align derived_series derivedSeries

@[simp]
theorem derived_series_zero : derivedSeries G 0 = ⊤ :=
  rfl
#align derived_series_zero derived_series_zero

@[simp]
theorem derived_series_succ (n : ℕ) :
    derivedSeries G (n + 1) = ⁅derivedSeries G n, derivedSeries G n⁆ :=
  rfl
#align derived_series_succ derived_series_succ

theorem derived_series_normal (n : ℕ) : (derivedSeries G n).Normal :=
  by
  induction' n with n ih
  · exact (⊤ : Subgroup G).normal_of_characteristic
  · exact Subgroup.commutator_normal (derivedSeries G n) (derivedSeries G n)
#align derived_series_normal derived_series_normal

@[simp]
theorem derived_series_one : derivedSeries G 1 = commutator G :=
  rfl
#align derived_series_one derived_series_one

end derivedSeries

section CommutatorMap

section DerivedSeriesMap

variable (f)

theorem map_derived_series_le_derived_series (n : ℕ) :
    (derivedSeries G n).map f ≤ derivedSeries G' n :=
  by
  induction' n with n ih
  · exact le_top
  · simp only [derived_series_succ, map_commutator, commutator_mono, ih]
#align map_derived_series_le_derived_series map_derived_series_le_derived_series

variable {f}

theorem derived_series_le_map_derived_series (hf : Function.Surjective f) (n : ℕ) :
    derivedSeries G' n ≤ (derivedSeries G n).map f :=
  by
  induction' n with n ih
  · exact (map_top_of_surjective f hf).ge
  · exact commutator_le_map_commutator ih ih
#align derived_series_le_map_derived_series derived_series_le_map_derived_series

theorem map_derived_series_eq (hf : Function.Surjective f) (n : ℕ) :
    (derivedSeries G n).map f = derivedSeries G' n :=
  le_antisymm (map_derived_series_le_derived_series f n) (derived_series_le_map_derived_series hf n)
#align map_derived_series_eq map_derived_series_eq

end DerivedSeriesMap

end CommutatorMap

section Solvable

variable (G)

/-- A group `G` is solvable if its derived series is eventually trivial. We use this definition
  because it's the most convenient one to work with. -/
class IsSolvable : Prop where
  solvable : ∃ n : ℕ, derivedSeries G n = ⊥
#align is_solvable IsSolvable

theorem is_solvable_def : IsSolvable G ↔ ∃ n : ℕ, derivedSeries G n = ⊥ :=
  ⟨fun h => h.solvable, fun h => ⟨h⟩⟩
#align is_solvable_def is_solvable_def

instance (priority := 100) CommGroup.is_solvable {G : Type _} [CommGroup G] : IsSolvable G :=
  ⟨⟨1, le_bot_iff.mp (Abelianization.commutator_subset_ker (MonoidHom.id G))⟩⟩
#align comm_group.is_solvable CommGroup.is_solvable

theorem is_solvable_of_comm {G : Type _} [hG : Group G] (h : ∀ a b : G, a * b = b * a) :
    IsSolvable G := by
  letI hG' : CommGroup G := { hG with mul_comm := h }
  cases hG
  exact CommGroup.is_solvable
#align is_solvable_of_comm is_solvable_of_comm

theorem is_solvable_of_top_eq_bot (h : (⊤ : Subgroup G) = ⊥) : IsSolvable G :=
  ⟨⟨0, h⟩⟩
#align is_solvable_of_top_eq_bot is_solvable_of_top_eq_bot

instance (priority := 100) is_solvable_of_subsingleton [Subsingleton G] : IsSolvable G :=
  is_solvable_of_top_eq_bot G (by ext <;> simp at *)
#align is_solvable_of_subsingleton is_solvable_of_subsingleton

variable {G}

theorem solvable_of_ker_le_range {G' G'' : Type _} [Group G'] [Group G''] (f : G' →* G)
    (g : G →* G'') (hfg : g.ker ≤ f.range) [hG' : IsSolvable G'] [hG'' : IsSolvable G''] :
    IsSolvable G := by
  obtain ⟨n, hn⟩ := id hG''
  obtain ⟨m, hm⟩ := id hG'
  refine' ⟨⟨n + m, le_bot_iff.mp (map_bot f ▸ hm ▸ _)⟩⟩
  clear hm
  induction' m with m hm
  ·
    exact
      f.range_eq_map ▸
        ((derivedSeries G n).map_eq_bot_iff.mp
              (le_bot_iff.mp ((map_derived_series_le_derived_series g n).trans hn.le))).trans
          hfg
  · exact commutator_le_map_commutator hm hm
#align solvable_of_ker_le_range solvable_of_ker_le_range

theorem solvable_of_solvable_injective (hf : Function.Injective f) [h : IsSolvable G'] :
    IsSolvable G :=
  solvable_of_ker_le_range (1 : G' →* G) f ((f.ker_eq_bot_iff.mpr hf).symm ▸ bot_le)
#align solvable_of_solvable_injective solvable_of_solvable_injective

instance subgroup_solvable_of_solvable (H : Subgroup G) [h : IsSolvable G] : IsSolvable H :=
  solvable_of_solvable_injective H.subtype_injective
#align subgroup_solvable_of_solvable subgroup_solvable_of_solvable

theorem solvable_of_surjective (hf : Function.Surjective f) [h : IsSolvable G] : IsSolvable G' :=
  solvable_of_ker_le_range f (1 : G' →* G) ((f.range_top_of_surjective hf).symm ▸ le_top)
#align solvable_of_surjective solvable_of_surjective

instance solvable_quotient_of_solvable (H : Subgroup G) [H.Normal] [h : IsSolvable G] :
    IsSolvable (G ⧸ H) :=
  solvable_of_surjective (QuotientGroup.mk'_surjective H)
#align solvable_quotient_of_solvable solvable_quotient_of_solvable

instance solvable_prod {G' : Type _} [Group G'] [h : IsSolvable G] [h' : IsSolvable G'] :
    IsSolvable (G × G') :=
  solvable_of_ker_le_range (MonoidHom.inl G G') (MonoidHom.snd G G') fun x hx =>
    ⟨x.1, Prod.ext rfl hx.symm⟩
#align solvable_prod solvable_prod

end Solvable

section IsSimpleGroup

variable [IsSimpleGroup G]

theorem IsSimpleGroup.derived_series_succ {n : ℕ} : derivedSeries G n.succ = commutator G :=
  by
  induction' n with n ih
  · exact derived_series_one G
  rw [derived_series_succ, ih]
  cases' (commutator.normal G).eq_bot_or_eq_top with h h
  · rw [h, commutator_bot_left]
  · rwa [h]
#align is_simple_group.derived_series_succ IsSimpleGroup.derived_series_succ

theorem IsSimpleGroup.comm_iff_is_solvable : (∀ a b : G, a * b = b * a) ↔ IsSolvable G :=
  ⟨is_solvable_of_comm, fun ⟨⟨n, hn⟩⟩ => by
    cases n
    · intro a b
      refine' (mem_bot.1 _).trans (mem_bot.1 _).symm <;>
        · rw [← hn]
          exact mem_top _
    · rw [IsSimpleGroup.derived_series_succ] at hn
      intro a b
      rw [← mul_inv_eq_one, mul_inv_rev, ← mul_assoc, ← mem_bot, ← hn, commutator_eq_closure]
      exact subset_closure ⟨a, b, rfl⟩⟩
#align is_simple_group.comm_iff_is_solvable IsSimpleGroup.comm_iff_is_solvable

end IsSimpleGroup

section PermNotSolvable

theorem not_solvable_of_mem_derived_series {g : G} (h1 : g ≠ 1)
    (h2 : ∀ n : ℕ, g ∈ derivedSeries G n) : ¬IsSolvable G :=
  mt (is_solvable_def _).mp
    (not_exists_of_forall_not fun n h =>
      h1 (Subgroup.mem_bot.mp ((congr_arg (Membership.Mem g) h).mp (h2 n))))
#align not_solvable_of_mem_derived_series not_solvable_of_mem_derived_series

theorem Equiv.Perm.fin_5_not_solvable : ¬IsSolvable (Equiv.Perm (Fin 5)) :=
  by
  let x : Equiv.Perm (Fin 5) := ⟨![1, 2, 0, 3, 4], ![2, 0, 1, 3, 4], by decide, by decide⟩
  let y : Equiv.Perm (Fin 5) := ⟨![3, 4, 2, 0, 1], ![3, 4, 2, 0, 1], by decide, by decide⟩
  let z : Equiv.Perm (Fin 5) := ⟨![0, 3, 2, 1, 4], ![0, 3, 2, 1, 4], by decide, by decide⟩
  have key : x = z * ⁅x, y * x * y⁻¹⁆ * z⁻¹ := by decide
  refine' not_solvable_of_mem_derived_series (show x ≠ 1 by decide) fun n => _
  induction' n with n ih
  · exact mem_top x
  · rw [key, (derived_series_normal _ _).mem_comm_iff, inv_mul_cancel_left]
    exact commutator_mem_commutator ih ((derived_series_normal _ _).conj_mem _ ih _)
#align equiv.perm.fin_5_not_solvable Equiv.Perm.fin_5_not_solvable

theorem Equiv.Perm.not_solvable (X : Type _) (hX : 5 ≤ Cardinal.mk X) :
    ¬IsSolvable (Equiv.Perm X) := by
  intro h
  have key : Nonempty (Fin 5 ↪ X) := by
    rwa [← Cardinal.lift_mk_le, Cardinal.mk_fin, Cardinal.lift_nat_cast, Nat.cast_bit1,
      Nat.cast_bit0, Nat.cast_one, Cardinal.lift_id]
  exact
    Equiv.Perm.fin_5_not_solvable
      (solvable_of_solvable_injective (Equiv.Perm.viaEmbeddingHom_injective (Nonempty.some key)))
#align equiv.perm.not_solvable Equiv.Perm.not_solvable

end PermNotSolvable

