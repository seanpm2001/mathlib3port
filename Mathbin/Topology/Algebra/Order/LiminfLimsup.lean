/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Yury Kudryashov

! This file was ported from Lean 3 source module topology.algebra.order.liminf_limsup
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Intervals
import Mathbin.Order.LiminfLimsup
import Mathbin.Order.Filter.Archimedean
import Mathbin.Topology.Order.Basic

/-!
# Lemmas about liminf and limsup in an order topology.
-/


open Filter

open TopologicalSpace Classical

universe u v

variable {α : Type u} {β : Type v}

section LiminfLimsup

section OrderClosedTopology

variable [SemilatticeSup α] [TopologicalSpace α] [OrderTopology α]

theorem is_bounded_le_nhds (a : α) : (𝓝 a).IsBounded (· ≤ ·) :=
  (isTop_or_exists_gt a).elim (fun h => ⟨a, eventually_of_forall h⟩) fun ⟨b, hb⟩ =>
    ⟨b, ge_mem_nhds hb⟩
#align is_bounded_le_nhds is_bounded_le_nhds

theorem Filter.Tendsto.is_bounded_under_le {f : Filter β} {u : β → α} {a : α}
    (h : Tendsto u f (𝓝 a)) : f.IsBoundedUnder (· ≤ ·) u :=
  (is_bounded_le_nhds a).mono h
#align filter.tendsto.is_bounded_under_le Filter.Tendsto.is_bounded_under_le

theorem Filter.Tendsto.bdd_above_range_of_cofinite {u : β → α} {a : α}
    (h : Tendsto u cofinite (𝓝 a)) : BddAbove (Set.range u) :=
  h.is_bounded_under_le.bdd_above_range_of_cofinite
#align filter.tendsto.bdd_above_range_of_cofinite Filter.Tendsto.bdd_above_range_of_cofinite

theorem Filter.Tendsto.bdd_above_range {u : ℕ → α} {a : α} (h : Tendsto u atTop (𝓝 a)) :
    BddAbove (Set.range u) :=
  h.is_bounded_under_le.bdd_above_range
#align filter.tendsto.bdd_above_range Filter.Tendsto.bdd_above_range

theorem is_cobounded_ge_nhds (a : α) : (𝓝 a).IsCobounded (· ≥ ·) :=
  (is_bounded_le_nhds a).is_cobounded_flip
#align is_cobounded_ge_nhds is_cobounded_ge_nhds

theorem Filter.Tendsto.is_cobounded_under_ge {f : Filter β} {u : β → α} {a : α} [NeBot f]
    (h : Tendsto u f (𝓝 a)) : f.IsCoboundedUnder (· ≥ ·) u :=
  h.is_bounded_under_le.is_cobounded_flip
#align filter.tendsto.is_cobounded_under_ge Filter.Tendsto.is_cobounded_under_ge

theorem is_bounded_le_at_bot (α : Type _) [hα : Nonempty α] [Preorder α] :
    (atBot : Filter α).IsBounded (· ≤ ·) :=
  is_bounded_iff.2 ⟨Set.iic hα.some, mem_at_bot _, hα.some, fun x hx => hx⟩
#align is_bounded_le_at_bot is_bounded_le_at_bot

theorem Filter.Tendsto.is_bounded_under_le_at_bot {α : Type _} [Nonempty α] [Preorder α]
    {f : Filter β} {u : β → α} (h : Tendsto u f atBot) : f.IsBoundedUnder (· ≤ ·) u :=
  (is_bounded_le_at_bot α).mono h
#align filter.tendsto.is_bounded_under_le_at_bot Filter.Tendsto.is_bounded_under_le_at_bot

theorem bdd_above_range_of_tendsto_at_top_at_bot {α : Type _} [Nonempty α] [SemilatticeSup α]
    {u : ℕ → α} (hx : Tendsto u atTop atBot) : BddAbove (Set.range u) :=
  (Filter.Tendsto.is_bounded_under_le_at_bot hx).bdd_above_range
#align bdd_above_range_of_tendsto_at_top_at_bot bdd_above_range_of_tendsto_at_top_at_bot

end OrderClosedTopology

section OrderClosedTopology

variable [SemilatticeInf α] [TopologicalSpace α] [OrderTopology α]

theorem is_bounded_ge_nhds (a : α) : (𝓝 a).IsBounded (· ≥ ·) :=
  @is_bounded_le_nhds αᵒᵈ _ _ _ a
#align is_bounded_ge_nhds is_bounded_ge_nhds

theorem Filter.Tendsto.is_bounded_under_ge {f : Filter β} {u : β → α} {a : α}
    (h : Tendsto u f (𝓝 a)) : f.IsBoundedUnder (· ≥ ·) u :=
  (is_bounded_ge_nhds a).mono h
#align filter.tendsto.is_bounded_under_ge Filter.Tendsto.is_bounded_under_ge

theorem Filter.Tendsto.bdd_below_range_of_cofinite {u : β → α} {a : α}
    (h : Tendsto u cofinite (𝓝 a)) : BddBelow (Set.range u) :=
  h.is_bounded_under_ge.bdd_below_range_of_cofinite
#align filter.tendsto.bdd_below_range_of_cofinite Filter.Tendsto.bdd_below_range_of_cofinite

theorem Filter.Tendsto.bdd_below_range {u : ℕ → α} {a : α} (h : Tendsto u atTop (𝓝 a)) :
    BddBelow (Set.range u) :=
  h.is_bounded_under_ge.bdd_below_range
#align filter.tendsto.bdd_below_range Filter.Tendsto.bdd_below_range

theorem is_cobounded_le_nhds (a : α) : (𝓝 a).IsCobounded (· ≤ ·) :=
  (is_bounded_ge_nhds a).is_cobounded_flip
#align is_cobounded_le_nhds is_cobounded_le_nhds

theorem Filter.Tendsto.is_cobounded_under_le {f : Filter β} {u : β → α} {a : α} [NeBot f]
    (h : Tendsto u f (𝓝 a)) : f.IsCoboundedUnder (· ≤ ·) u :=
  h.is_bounded_under_ge.is_cobounded_flip
#align filter.tendsto.is_cobounded_under_le Filter.Tendsto.is_cobounded_under_le

theorem is_bounded_ge_at_top (α : Type _) [hα : Nonempty α] [Preorder α] :
    (atTop : Filter α).IsBounded (· ≥ ·) :=
  is_bounded_le_at_bot αᵒᵈ
#align is_bounded_ge_at_top is_bounded_ge_at_top

theorem Filter.Tendsto.is_bounded_under_ge_at_top {α : Type _} [Nonempty α] [Preorder α]
    {f : Filter β} {u : β → α} (h : Tendsto u f atTop) : f.IsBoundedUnder (· ≥ ·) u :=
  (is_bounded_ge_at_top α).mono h
#align filter.tendsto.is_bounded_under_ge_at_top Filter.Tendsto.is_bounded_under_ge_at_top

theorem bdd_below_range_of_tendsto_at_top_at_top {α : Type _} [Nonempty α] [SemilatticeInf α]
    {u : ℕ → α} (hx : Tendsto u atTop atTop) : BddBelow (Set.range u) :=
  (Filter.Tendsto.is_bounded_under_ge_at_top hx).bdd_below_range
#align bdd_below_range_of_tendsto_at_top_at_top bdd_below_range_of_tendsto_at_top_at_top

end OrderClosedTopology

section ConditionallyCompleteLinearOrder

variable [ConditionallyCompleteLinearOrder α]

theorem lt_mem_sets_of_Limsup_lt {f : Filter α} {b} (h : f.IsBounded (· ≤ ·)) (l : f.limsup < b) :
    ∀ᶠ a in f, a < b :=
  let ⟨c, (h : ∀ᶠ a in f, a ≤ c), hcb⟩ := exists_lt_of_cInf_lt h l
  (mem_of_superset h) fun a hac => lt_of_le_of_lt hac hcb
#align lt_mem_sets_of_Limsup_lt lt_mem_sets_of_Limsup_lt

theorem gt_mem_sets_of_Liminf_gt :
    ∀ {f : Filter α} {b}, f.IsBounded (· ≥ ·) → b < f.liminf → ∀ᶠ a in f, b < a :=
  @lt_mem_sets_of_Limsup_lt αᵒᵈ _
#align gt_mem_sets_of_Liminf_gt gt_mem_sets_of_Liminf_gt

variable [TopologicalSpace α] [OrderTopology α]

/-- If the liminf and the limsup of a filter coincide, then this filter converges to
their common value, at least if the filter is eventually bounded above and below. -/
theorem le_nhds_of_Limsup_eq_Liminf {f : Filter α} {a : α} (hl : f.IsBounded (· ≤ ·))
    (hg : f.IsBounded (· ≥ ·)) (hs : f.limsup = a) (hi : f.liminf = a) : f ≤ 𝓝 a :=
  tendsto_order.2 <|
    And.intro (fun b hb => gt_mem_sets_of_Liminf_gt hg <| hi.symm ▸ hb) fun b hb =>
      lt_mem_sets_of_Limsup_lt hl <| hs.symm ▸ hb
#align le_nhds_of_Limsup_eq_Liminf le_nhds_of_Limsup_eq_Liminf

theorem Limsup_nhds (a : α) : limsup (𝓝 a) = a :=
  cInf_eq_of_forall_ge_of_forall_gt_exists_lt (is_bounded_le_nhds a)
    (fun a' (h : { n : α | n ≤ a' } ∈ 𝓝 a) => show a ≤ a' from @mem_of_mem_nhds α _ a _ h)
    fun b (hba : a < b) =>
    show ∃ (c : _)(h : { n : α | n ≤ c } ∈ 𝓝 a), c < b from
      match dense_or_discrete a b with
      | Or.inl ⟨c, hac, hcb⟩ => ⟨c, ge_mem_nhds hac, hcb⟩
      | Or.inr ⟨_, h⟩ => ⟨a, (𝓝 a).sets_of_superset (gt_mem_nhds hba) h, hba⟩
#align Limsup_nhds Limsup_nhds

theorem Liminf_nhds : ∀ a : α, liminf (𝓝 a) = a :=
  @Limsup_nhds αᵒᵈ _ _ _
#align Liminf_nhds Liminf_nhds

/-- If a filter is converging, its limsup coincides with its limit. -/
theorem Liminf_eq_of_le_nhds {f : Filter α} {a : α} [NeBot f] (h : f ≤ 𝓝 a) : f.liminf = a :=
  have hb_ge : IsBounded (· ≥ ·) f := (is_bounded_ge_nhds a).mono h
  have hb_le : IsBounded (· ≤ ·) f := (is_bounded_le_nhds a).mono h
  le_antisymm
    (calc
      f.liminf ≤ f.limsup := Liminf_le_Limsup hb_le hb_ge
      _ ≤ (𝓝 a).limsup := Limsup_le_Limsup_of_le h hb_ge.is_cobounded_flip (is_bounded_le_nhds a)
      _ = a := Limsup_nhds a
      )
    (calc
      a = (𝓝 a).liminf := (Liminf_nhds a).symm
      _ ≤ f.liminf := Liminf_le_Liminf_of_le h (is_bounded_ge_nhds a) hb_le.is_cobounded_flip
      )
#align Liminf_eq_of_le_nhds Liminf_eq_of_le_nhds

/-- If a filter is converging, its liminf coincides with its limit. -/
theorem Limsup_eq_of_le_nhds : ∀ {f : Filter α} {a : α} [NeBot f], f ≤ 𝓝 a → f.limsup = a :=
  @Liminf_eq_of_le_nhds αᵒᵈ _ _ _
#align Limsup_eq_of_le_nhds Limsup_eq_of_le_nhds

/-- If a function has a limit, then its limsup coincides with its limit. -/
theorem Filter.Tendsto.limsup_eq {f : Filter β} {u : β → α} {a : α} [NeBot f]
    (h : Tendsto u f (𝓝 a)) : limsup u f = a :=
  Limsup_eq_of_le_nhds h
#align filter.tendsto.limsup_eq Filter.Tendsto.limsup_eq

/-- If a function has a limit, then its liminf coincides with its limit. -/
theorem Filter.Tendsto.liminf_eq {f : Filter β} {u : β → α} {a : α} [NeBot f]
    (h : Tendsto u f (𝓝 a)) : liminf u f = a :=
  Liminf_eq_of_le_nhds h
#align filter.tendsto.liminf_eq Filter.Tendsto.liminf_eq

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic is_bounded_default -/
/-- If the liminf and the limsup of a function coincide, then the limit of the function
exists and has the same value -/
theorem tendsto_of_liminf_eq_limsup {f : Filter β} {u : β → α} {a : α} (hinf : liminf u f = a)
    (hsup : limsup u f = a)
    (h : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h' : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    Tendsto u f (𝓝 a) :=
  le_nhds_of_Limsup_eq_Liminf h h' hsup hinf
#align tendsto_of_liminf_eq_limsup tendsto_of_liminf_eq_limsup

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic is_bounded_default -/
/-- If a number `a` is less than or equal to the `liminf` of a function `f` at some filter
and is greater than or equal to the `limsup` of `f`, then `f` tends to `a` along this filter. -/
theorem tendsto_of_le_liminf_of_limsup_le {f : Filter β} {u : β → α} {a : α} (hinf : a ≤ liminf u f)
    (hsup : limsup u f ≤ a)
    (h : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h' : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    Tendsto u f (𝓝 a) :=
  if hf : f = ⊥ then hf.symm ▸ tendsto_bot
  else
    haveI : ne_bot f := ⟨hf⟩
    tendsto_of_liminf_eq_limsup (le_antisymm (le_trans (liminf_le_limsup h h') hsup) hinf)
      (le_antisymm hsup (le_trans hinf (liminf_le_limsup h h'))) h h'
#align tendsto_of_le_liminf_of_limsup_le tendsto_of_le_liminf_of_limsup_le

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic is_bounded_default -/
/-- Assume that, for any `a < b`, a sequence can not be infinitely many times below `a` and
above `b`. If it is also ultimately bounded above and below, then it has to converge. This even
works if `a` and `b` are restricted to a dense subset.
-/
theorem tendsto_of_no_upcrossings [DenselyOrdered α] {f : Filter β} {u : β → α} {s : Set α}
    (hs : Dense s) (H : ∀ a ∈ s, ∀ b ∈ s, a < b → ¬((∃ᶠ n in f, u n < a) ∧ ∃ᶠ n in f, b < u n))
    (h : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h' : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    ∃ c : α, Tendsto u f (𝓝 c) := by 
  by_cases hbot : f = ⊥;
  · rw [hbot]
    exact ⟨Inf ∅, tendsto_bot⟩
  haveI : ne_bot f := ⟨hbot⟩
  refine' ⟨limsup u f, _⟩
  apply tendsto_of_le_liminf_of_limsup_le _ le_rfl h h'
  by_contra' hlt
  obtain ⟨a, ⟨⟨la, au⟩, as⟩⟩ : ∃ a, (f.liminf u < a ∧ a < f.limsup u) ∧ a ∈ s :=
    dense_iff_inter_open.1 hs (Set.ioo (f.liminf u) (f.limsup u)) is_open_Ioo
      (Set.nonempty_Ioo.2 hlt)
  obtain ⟨b, ⟨⟨ab, bu⟩, bs⟩⟩ : ∃ b, (a < b ∧ b < f.limsup u) ∧ b ∈ s :=
    dense_iff_inter_open.1 hs (Set.ioo a (f.limsup u)) is_open_Ioo (Set.nonempty_Ioo.2 au)
  have A : ∃ᶠ n in f, u n < a := frequently_lt_of_liminf_lt (is_bounded.is_cobounded_ge h) la
  have B : ∃ᶠ n in f, b < u n := frequently_lt_of_lt_limsup (is_bounded.is_cobounded_le h') bu
  exact H a as b bs ab ⟨A, B⟩
#align tendsto_of_no_upcrossings tendsto_of_no_upcrossings

end ConditionallyCompleteLinearOrder

end LiminfLimsup

section Monotone

variable {ι R S : Type _} {F : Filter ι} [NeBot F] [CompleteLinearOrder R] [TopologicalSpace R]
  [OrderTopology R] [CompleteLinearOrder S] [TopologicalSpace S] [OrderTopology S]

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
/-- An antitone function between complete linear ordered spaces sends a `filter.Limsup`
to the `filter.liminf` of the image if it is continuous at the `Limsup`. -/
theorem Antitone.map_Limsup_of_continuous_at {F : Filter R} [NeBot F] {f : R → S}
    (f_decr : Antitone f) (f_cont : ContinuousAt f F.limsup) : f F.limsup = F.liminf f := by
  apply le_antisymm
  · have A : { a : R | ∀ᶠ n : R in F, n ≤ a }.Nonempty := ⟨⊤, by simp⟩
    rw [Limsup, f_decr.map_Inf_of_continuous_at' f_cont A]
    apply le_of_forall_lt
    intro c hc
    simp only [liminf, Liminf, lt_Sup_iff, eventually_map, Set.mem_setOf_eq, exists_prop,
      Set.mem_image, exists_exists_and_eq_and] at hc⊢
    rcases hc with ⟨d, hd, h'd⟩
    refine' ⟨f d, _, h'd⟩
    filter_upwards [hd] with x hx using f_decr hx
  · rcases eq_or_lt_of_le (bot_le : ⊥ ≤ F.Limsup) with (h | Limsup_ne_bot)
    · rw [← h]
      apply liminf_le_of_frequently_le
      apply frequently_of_forall
      intro x
      exact f_decr bot_le
    by_cases h' : ∃ c, c < F.Limsup ∧ Set.ioo c F.Limsup = ∅
    · rcases h' with ⟨c, c_lt, hc⟩
      have B : ∃ᶠ n in F, F.Limsup ≤ n := by
        apply
          (frequently_lt_of_lt_Limsup
              (by
                run_tac
                  is_bounded_default)
              c_lt).mono
        intro x hx
        by_contra'
        have : (Set.ioo c F.Limsup).Nonempty := ⟨x, ⟨hx, this⟩⟩
        simpa [hc]
      apply liminf_le_of_frequently_le
      exact B.mono fun x hx => f_decr hx
    by_contra' H
    obtain ⟨l, l_lt, h'l⟩ : ∃ l < F.Limsup, Set.ioc l F.Limsup ⊆ { x : R | f x < F.liminf f }
    exact exists_Ioc_subset_of_mem_nhds ((tendsto_order.1 f_cont.tendsto).2 _ H) ⟨⊥, Limsup_ne_bot⟩
    obtain ⟨m, l_m, m_lt⟩ : (Set.ioo l F.Limsup).Nonempty := by
      contrapose! h'
      refine' ⟨l, l_lt, by rwa [Set.not_nonempty_iff_eq_empty] at h'⟩
    have B : F.liminf f ≤ f m := by 
      apply liminf_le_of_frequently_le
      apply
        (frequently_lt_of_lt_Limsup
            (by
              run_tac
                is_bounded_default)
            m_lt).mono
      intro x hx
      exact f_decr hx.le
    have I : f m < F.liminf f := h'l ⟨l_m, m_lt.le⟩
    exact lt_irrefl _ (B.trans_lt I)
#align antitone.map_Limsup_of_continuous_at Antitone.map_Limsup_of_continuous_at

/-- A continuous antitone function between complete linear ordered spaces sends a `filter.limsup`
to the `filter.liminf` of the images. -/
theorem Antitone.map_limsup_of_continuous_at {f : R → S} (f_decr : Antitone f) (a : ι → R)
    (f_cont : ContinuousAt f (F.limsup a)) : f (F.limsup a) = F.liminf (f ∘ a) :=
  f_decr.map_Limsup_of_continuous_at f_cont
#align antitone.map_limsup_of_continuous_at Antitone.map_limsup_of_continuous_at

/-- An antitone function between complete linear ordered spaces sends a `filter.Liminf`
to the `filter.limsup` of the image if it is continuous at the `Liminf`. -/
theorem Antitone.map_Liminf_of_continuous_at {F : Filter R} [NeBot F] {f : R → S}
    (f_decr : Antitone f) (f_cont : ContinuousAt f F.liminf) : f F.liminf = F.limsup f :=
  @Antitone.map_Limsup_of_continuous_at (OrderDual R) (OrderDual S) _ _ _ _ _ _ _ _ f f_decr.dual
    f_cont
#align antitone.map_Liminf_of_continuous_at Antitone.map_Liminf_of_continuous_at

/-- A continuous antitone function between complete linear ordered spaces sends a `filter.liminf`
to the `filter.limsup` of the images. -/
theorem Antitone.map_liminf_of_continuous_at {f : R → S} (f_decr : Antitone f) (a : ι → R)
    (f_cont : ContinuousAt f (F.liminf a)) : f (F.liminf a) = F.limsup (f ∘ a) :=
  f_decr.map_Liminf_of_continuous_at f_cont
#align antitone.map_liminf_of_continuous_at Antitone.map_liminf_of_continuous_at

/-- A monotone function between complete linear ordered spaces sends a `filter.Limsup`
to the `filter.limsup` of the image if it is continuous at the `Limsup`. -/
theorem Monotone.map_Limsup_of_continuous_at {F : Filter R} [NeBot F] {f : R → S}
    (f_incr : Monotone f) (f_cont : ContinuousAt f F.limsup) : f F.limsup = F.limsup f :=
  @Antitone.map_Limsup_of_continuous_at R (OrderDual S) _ _ _ _ _ _ _ _ f f_incr f_cont
#align monotone.map_Limsup_of_continuous_at Monotone.map_Limsup_of_continuous_at

/-- A continuous monotone function between complete linear ordered spaces sends a `filter.limsup`
to the `filter.limsup` of the images. -/
theorem Monotone.map_limsup_of_continuous_at {f : R → S} (f_incr : Monotone f) (a : ι → R)
    (f_cont : ContinuousAt f (F.limsup a)) : f (F.limsup a) = F.limsup (f ∘ a) :=
  f_incr.map_Limsup_of_continuous_at f_cont
#align monotone.map_limsup_of_continuous_at Monotone.map_limsup_of_continuous_at

/-- A monotone function between complete linear ordered spaces sends a `filter.Liminf`
to the `filter.liminf` of the image if it is continuous at the `Liminf`. -/
theorem Monotone.map_Liminf_of_continuous_at {F : Filter R} [NeBot F] {f : R → S}
    (f_incr : Monotone f) (f_cont : ContinuousAt f F.liminf) : f F.liminf = F.liminf f :=
  @Antitone.map_Liminf_of_continuous_at R (OrderDual S) _ _ _ _ _ _ _ _ f f_incr f_cont
#align monotone.map_Liminf_of_continuous_at Monotone.map_Liminf_of_continuous_at

/-- A continuous monotone function between complete linear ordered spaces sends a `filter.liminf`
to the `filter.liminf` of the images. -/
theorem Monotone.map_liminf_of_continuous_at {f : R → S} (f_incr : Monotone f) (a : ι → R)
    (f_cont : ContinuousAt f (F.liminf a)) : f (F.liminf a) = F.liminf (f ∘ a) :=
  f_incr.map_Liminf_of_continuous_at f_cont
#align monotone.map_liminf_of_continuous_at Monotone.map_liminf_of_continuous_at

end Monotone

section InfiAndSupr

open TopologicalSpace

open Filter Set

variable {ι : Type _} {R : Type _} [CompleteLinearOrder R] [TopologicalSpace R] [OrderTopology R]

theorem infi_eq_of_forall_le_of_tendsto {x : R} {as : ι → R} (x_le : ∀ i, x ≤ as i) {F : Filter ι}
    [Filter.NeBot F] (as_lim : Filter.Tendsto as F (𝓝 x)) : (⨅ i, as i) = x := by
  refine' infi_eq_of_forall_ge_of_forall_gt_exists_lt (fun i => x_le i) _
  apply fun w x_lt_w => ‹Filter.NeBot F›.nonempty_of_mem (eventually_lt_of_tendsto_lt x_lt_w as_lim)
#align infi_eq_of_forall_le_of_tendsto infi_eq_of_forall_le_of_tendsto

theorem supr_eq_of_forall_le_of_tendsto {x : R} {as : ι → R} (le_x : ∀ i, as i ≤ x) {F : Filter ι}
    [Filter.NeBot F] (as_lim : Filter.Tendsto as F (𝓝 x)) : (⨆ i, as i) = x :=
  @infi_eq_of_forall_le_of_tendsto ι (OrderDual R) _ _ _ x as le_x F _ as_lim
#align supr_eq_of_forall_le_of_tendsto supr_eq_of_forall_le_of_tendsto

theorem Union_Ici_eq_Ioi_of_lt_of_tendsto {ι : Type _} (x : R) {as : ι → R} (x_lt : ∀ i, x < as i)
    {F : Filter ι} [Filter.NeBot F] (as_lim : Filter.Tendsto as F (𝓝 x)) :
    (⋃ i : ι, ici (as i)) = ioi x := by
  have obs : x ∉ range as := by 
    intro maybe_x_is
    rcases mem_range.mp maybe_x_is with ⟨i, hi⟩
    simpa only [hi, lt_self_iff_false] using x_lt i
  rw [← infi_eq_of_forall_le_of_tendsto (fun i => (x_lt i).le) as_lim] at *
  exact Union_Ici_eq_Ioi_infi obs
#align Union_Ici_eq_Ioi_of_lt_of_tendsto Union_Ici_eq_Ioi_of_lt_of_tendsto

theorem Union_Iic_eq_Iio_of_lt_of_tendsto {ι : Type _} (x : R) {as : ι → R} (lt_x : ∀ i, as i < x)
    {F : Filter ι} [Filter.NeBot F] (as_lim : Filter.Tendsto as F (𝓝 x)) :
    (⋃ i : ι, iic (as i)) = iio x :=
  @Union_Ici_eq_Ioi_of_lt_of_tendsto (OrderDual R) _ _ _ ι x as lt_x F _ as_lim
#align Union_Iic_eq_Iio_of_lt_of_tendsto Union_Iic_eq_Iio_of_lt_of_tendsto

end InfiAndSupr

section Indicator

open BigOperators

theorem limsup_eq_tendsto_sum_indicator_nat_at_top (s : ℕ → Set α) :
    limsup s atTop =
      { ω |
        Tendsto (fun n => ∑ k in Finset.range n, (s (k + 1)).indicator (1 : α → ℕ) ω) atTop
          atTop } :=
  by 
  ext ω
  simp only [limsup_eq_infi_supr_of_nat, ge_iff_le, Set.supr_eq_Union, Set.infi_eq_Inter,
    Set.mem_Inter, Set.mem_Union, exists_prop]
  constructor
  · intro hω
    refine'
      tendsto_at_top_at_top_of_monotone'
        (fun n m hnm =>
          Finset.sum_mono_set_of_nonneg (fun i => Set.indicator_nonneg (fun _ _ => zero_le_one) _)
            (Finset.range_mono hnm))
        _
    rintro ⟨i, h⟩
    simp only [mem_upper_bounds, Set.mem_range, forall_exists_index, forall_apply_eq_imp_iff'] at h
    induction' i with k hk
    · obtain ⟨j, hj₁, hj₂⟩ := hω 1
      refine'
        not_lt.2 (h <| j + 1)
          (lt_of_le_of_lt (finset.sum_const_zero.symm : 0 = ∑ k in Finset.range (j + 1), 0).le _)
      refine'
        Finset.sum_lt_sum (fun m _ => Set.indicator_nonneg (fun _ _ => zero_le_one) _)
          ⟨j - 1, Finset.mem_range.2 (lt_of_le_of_lt (Nat.sub_le _ _) j.lt_succ_self), _⟩
      rw [Nat.sub_add_cancel hj₁, Set.indicator_of_mem hj₂]
      exact zero_lt_one
    · rw [imp_false] at hk
      push_neg  at hk
      obtain ⟨i, hi⟩ := hk
      obtain ⟨j, hj₁, hj₂⟩ := hω (i + 1)
      replace hi : (∑ k in Finset.range i, (s (k + 1)).indicator 1 ω) = k + 1 :=
        le_antisymm (h i) hi
      refine' not_lt.2 (h <| j + 1) _
      rw [← Finset.sum_range_add_sum_Ico _ (i.le_succ.trans (hj₁.trans j.le_succ)), hi]
      refine' lt_add_of_pos_right _ _
      rw [(finset.sum_const_zero.symm : 0 = ∑ k in Finset.ico i (j + 1), 0)]
      refine'
        Finset.sum_lt_sum (fun m _ => Set.indicator_nonneg (fun _ _ => zero_le_one) _)
          ⟨j - 1,
            Finset.mem_Ico.2
              ⟨(Nat.le_sub_iff_right (le_trans ((le_add_iff_nonneg_left _).2 zero_le') hj₁)).2 hj₁,
                lt_of_le_of_lt (Nat.sub_le _ _) j.lt_succ_self⟩,
            _⟩
      rw [Nat.sub_add_cancel (le_trans ((le_add_iff_nonneg_left _).2 zero_le') hj₁),
        Set.indicator_of_mem hj₂]
      exact zero_lt_one
  · rintro hω i
    rw [Set.mem_setOf_eq, tendsto_at_top_at_top] at hω
    by_contra hcon
    push_neg  at hcon
    obtain ⟨j, h⟩ := hω (i + 1)
    have : (∑ k in Finset.range j, (s (k + 1)).indicator 1 ω) ≤ i := by
      have hle : ∀ j ≤ i, (∑ k in Finset.range j, (s (k + 1)).indicator 1 ω) ≤ i := by
        refine' fun j hij =>
          (Finset.sum_le_card_nsmul _ _ _ _ : _ ≤ (Finset.range j).card • 1).trans _
        · exact fun m hm => Set.indicator_apply_le' (fun _ => le_rfl) fun _ => zero_le_one
        · simpa only [Finset.card_range, smul_eq_mul, mul_one]
      by_cases hij : j < i
      · exact hle _ hij.le
      · rw [← Finset.sum_range_add_sum_Ico _ (not_lt.1 hij)]
        suffices (∑ k in Finset.ico i j, (s (k + 1)).indicator 1 ω) = 0 by
          rw [this, add_zero]
          exact hle _ le_rfl
        rw [Finset.sum_eq_zero fun m hm => _]
        exact Set.indicator_of_not_mem (hcon _ <| (Finset.mem_Ico.1 hm).1.trans m.le_succ) _
    exact not_le.2 (lt_of_lt_of_le i.lt_succ_self <| h _ le_rfl) this
#align limsup_eq_tendsto_sum_indicator_nat_at_top limsup_eq_tendsto_sum_indicator_nat_at_top

theorem limsup_eq_tendsto_sum_indicator_at_top (R : Type _) [StrictOrderedSemiring R]
    [Archimedean R] (s : ℕ → Set α) :
    limsup s atTop =
      { ω |
        Tendsto (fun n => ∑ k in Finset.range n, (s (k + 1)).indicator (1 : α → R) ω) atTop
          atTop } :=
  by 
  rw [limsup_eq_tendsto_sum_indicator_nat_at_top s]
  ext ω
  simp only [Set.mem_setOf_eq]
  rw [(_ :
      (fun n => ∑ k in Finset.range n, (s (k + 1)).indicator (1 : α → R) ω) = fun n =>
        ↑(∑ k in Finset.range n, (s (k + 1)).indicator (1 : α → ℕ) ω))]
  · exact tendsto_coe_nat_at_top_iff.symm
  · ext n
    simp only [Set.indicator, Pi.one_apply, Finset.sum_boole, Nat.cast_id]
#align limsup_eq_tendsto_sum_indicator_at_top limsup_eq_tendsto_sum_indicator_at_top

end Indicator

