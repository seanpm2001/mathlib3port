/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

! This file was ported from Lean 3 source module topology.order
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Tactic

/-!
# Ordering on topologies and (co)induced topologies

Topologies on a fixed type `α` are ordered, by reverse inclusion.
That is, for topologies `t₁` and `t₂` on `α`, we write `t₁ ≤ t₂`
if every set open in `t₂` is also open in `t₁`.
(One also calls `t₁` finer than `t₂`, and `t₂` coarser than `t₁`.)

Any function `f : α → β` induces
       `induced f : topological_space β → topological_space α`
and  `coinduced f : topological_space α → topological_space β`.
Continuity, the ordering on topologies and (co)induced topologies are
related as follows:
* The identity map (α, t₁) → (α, t₂) is continuous iff t₁ ≤ t₂.
* A map f : (α, t) → (β, u) is continuous
    iff             t ≤ induced f u   (`continuous_iff_le_induced`)
    iff coinduced f t ≤ u             (`continuous_iff_coinduced_le`).

Topologies on α form a complete lattice, with ⊥ the discrete topology
and ⊤ the indiscrete topology.

For a function f : α → β, (coinduced f, induced f) is a Galois connection
between topologies on α and topologies on β.

## Implementation notes

There is a Galois insertion between topologies on α (with the inclusion ordering)
and all collections of sets in α. The complete lattice structure on topologies
on α is defined as the reverse of the one obtained via this Galois insertion.

## Tags

finer, coarser, induced topology, coinduced topology

-/


open Function Set Filter

open Classical TopologicalSpace Filter

universe u v w

namespace TopologicalSpace

variable {α : Type u}

/-- The open sets of the least topology containing a collection of basic sets. -/
inductive GenerateOpen (g : Set (Set α)) : Set α → Prop
  | basic : ∀ s ∈ g, generate_open s
  | univ : generate_open univ
  | inter : ∀ s t, generate_open s → generate_open t → generate_open (s ∩ t)
  | sUnion : ∀ k, (∀ s ∈ k, generate_open s) → generate_open (⋃₀k)
#align topological_space.generate_open TopologicalSpace.GenerateOpen

/-- The smallest topological space containing the collection `g` of basic sets -/
def generateFrom (g : Set (Set α)) :
    TopologicalSpace α where 
  IsOpen := GenerateOpen g
  is_open_univ := GenerateOpen.univ
  is_open_inter := GenerateOpen.inter
  is_open_sUnion := GenerateOpen.sUnion
#align topological_space.generate_from TopologicalSpace.generateFrom

theorem is_open_generate_from_of_mem {g : Set (Set α)} {s : Set α} (hs : s ∈ g) :
    @IsOpen _ (generateFrom g) s :=
  GenerateOpen.basic s hs
#align topological_space.is_open_generate_from_of_mem TopologicalSpace.is_open_generate_from_of_mem

theorem nhds_generate_from {g : Set (Set α)} {a : α} :
    @nhds α (generateFrom g) a = ⨅ s ∈ { s | a ∈ s ∧ s ∈ g }, 𝓟 s := by
  rw [nhds_def] <;>
    exact
      le_antisymm (binfi_mono fun s ⟨as, sg⟩ => ⟨as, generate_open.basic _ sg⟩)
        (le_infi fun s =>
          le_infi fun ⟨as, hs⟩ => by 
            revert as; clear_; induction hs
            case basic s hs => exact fun as => infi_le_of_le s <| infi_le _ ⟨as, hs⟩
            case univ => 
              rw [principal_univ]
              exact fun _ => le_top
            case inter s t hs' ht' hs ht =>
              exact fun ⟨has, hat⟩ =>
                calc
                  _ ≤ 𝓟 s ⊓ 𝓟 t := le_inf (hs has) (ht hat)
                  _ = _ := inf_principal
                  
            case sUnion k hk' hk =>
              exact fun ⟨t, htk, hat⟩ =>
                calc
                  _ ≤ 𝓟 t := hk t htk hat
                  _ ≤ _ := le_principal_iff.2 <| subset_sUnion_of_mem htk
                  )
#align topological_space.nhds_generate_from TopologicalSpace.nhds_generate_from

theorem tendsto_nhds_generate_from {β : Type _} {m : α → β} {f : Filter α} {g : Set (Set β)} {b : β}
    (h : ∀ s ∈ g, b ∈ s → m ⁻¹' s ∈ f) : Tendsto m f (@nhds β (generateFrom g) b) := by
  rw [nhds_generate_from] <;>
    exact
      tendsto_infi.2 fun s => tendsto_infi.2 fun ⟨hbs, hsg⟩ => tendsto_principal.2 <| h s hsg hbs
#align topological_space.tendsto_nhds_generate_from TopologicalSpace.tendsto_nhds_generate_from

/-- Construct a topology on α given the filter of neighborhoods of each point of α. -/
protected def mkOfNhds (n : α → Filter α) :
    TopologicalSpace α where 
  IsOpen s := ∀ a ∈ s, s ∈ n a
  is_open_univ x h := univ_mem
  is_open_inter := fun s t hs ht x ⟨hxs, hxt⟩ => inter_mem (hs x hxs) (ht x hxt)
  is_open_sUnion := fun s hs a ⟨x, hx, hxa⟩ =>
    mem_of_superset (hs x hx _ hxa) (Set.subset_sUnion_of_mem hx)
#align topological_space.mk_of_nhds TopologicalSpace.mkOfNhds

theorem nhds_mk_of_nhds (n : α → Filter α) (a : α) (h₀ : pure ≤ n)
    (h₁ : ∀ {a s}, s ∈ n a → ∃ t ∈ n a, t ⊆ s ∧ ∀ a' ∈ t, s ∈ n a') :
    @nhds α (TopologicalSpace.mkOfNhds n) a = n a := by
  letI := TopologicalSpace.mkOfNhds n
  refine' le_antisymm (fun s hs => _) fun s hs => _
  · have h₀ : { b | s ∈ n b } ⊆ s := fun b hb => mem_pure.1 <| h₀ b hb
    have h₁ : { b | s ∈ n b } ∈ 𝓝 a := by
      refine' IsOpen.mem_nhds (fun b (hb : s ∈ n b) => _) hs
      rcases h₁ hb with ⟨t, ht, hts, h⟩
      exact mem_of_superset ht h
    exact mem_of_superset h₁ h₀
  · rcases(@mem_nhds_iff α (TopologicalSpace.mkOfNhds n) _ _).1 hs with ⟨t, hts, ht, hat⟩
    exact (n a).sets_of_superset (ht _ hat) hts
#align topological_space.nhds_mk_of_nhds TopologicalSpace.nhds_mk_of_nhds

theorem nhds_mk_of_nhds_single [DecidableEq α] {a₀ : α} {l : Filter α} (h : pure a₀ ≤ l) (b : α) :
    @nhds α (TopologicalSpace.mkOfNhds <| update pure a₀ l) b =
      (update pure a₀ l : α → Filter α) b :=
  by 
  refine' nhds_mk_of_nhds _ _ (le_update_iff.mpr ⟨h, fun _ _ => le_rfl⟩) fun a s hs => _
  rcases eq_or_ne a a₀ with (rfl | ha)
  · refine' ⟨s, hs, subset.rfl, fun b hb => _⟩
    rcases eq_or_ne b a with (rfl | hb)
    · exact hs
    · rwa [update_noteq hb]
  · have hs' := hs
    rw [update_noteq ha] at hs⊢
    exact ⟨{a}, rfl, singleton_subset_iff.mpr hs, forall_eq.2 hs'⟩
#align topological_space.nhds_mk_of_nhds_single TopologicalSpace.nhds_mk_of_nhds_single

theorem nhds_mk_of_nhds_filter_basis (B : α → FilterBasis α) (a : α) (h₀ : ∀ (x), ∀ n ∈ B x, x ∈ n)
    (h₁ : ∀ (x), ∀ n ∈ B x, ∃ n₁ ∈ B x, n₁ ⊆ n ∧ ∀ x' ∈ n₁, ∃ n₂ ∈ B x', n₂ ⊆ n) :
    @nhds α (TopologicalSpace.mkOfNhds fun x => (B x).filter) a = (B a).filter := by
  rw [TopologicalSpace.nhds_mk_of_nhds] <;> intro x n hn <;>
    obtain ⟨m, hm₁, hm₂⟩ := (B x).mem_filter_iff.mp hn
  · exact hm₂ (h₀ _ _ hm₁)
  · obtain ⟨n₁, hn₁, hn₂, hn₃⟩ := h₁ x m hm₁
    refine'
      ⟨n₁, (B x).mem_filter_of_mem hn₁, hn₂.trans hm₂, fun x' hx' => (B x').mem_filter_iff.mp _⟩
    obtain ⟨n₂, hn₄, hn₅⟩ := hn₃ x' hx'
    exact ⟨n₂, hn₄, hn₅.trans hm₂⟩
#align topological_space.nhds_mk_of_nhds_filter_basis TopologicalSpace.nhds_mk_of_nhds_filter_basis

end TopologicalSpace

section Lattice

variable {α : Type u} {β : Type v}

/-- The inclusion ordering on topologies on α. We use it to get a complete
   lattice instance via the Galois insertion method, but the partial order
   that we will eventually impose on `topological_space α` is the reverse one. -/
def tmpOrder :
    PartialOrder (TopologicalSpace
        α) where 
  le t s := t.IsOpen ≤ s.IsOpen
  le_antisymm t s h₁ h₂ := topological_space_eq <| le_antisymm h₁ h₂
  le_refl t := le_refl t.IsOpen
  le_trans a b c h₁ h₂ := @le_trans _ _ a.IsOpen b.IsOpen c.IsOpen h₁ h₂
#align tmp_order tmpOrder

attribute [local instance] tmpOrder

-- We'll later restate this lemma in terms of the correct order on `topological_space α`.
private theorem generate_from_le_iff_subset_is_open {g : Set (Set α)} {t : TopologicalSpace α} :
    TopologicalSpace.generateFrom g ≤ t ↔ g ⊆ { s | t.IsOpen s } :=
  Iff.intro (fun ht s hs => ht _ <| TopologicalSpace.GenerateOpen.basic s hs) fun hg s hs =>
    hs.recOn (fun v hv => hg hv) t.is_open_univ (fun u v _ _ => t.is_open_inter u v) fun k _ =>
      t.is_open_sUnion k
#align generate_from_le_iff_subset_is_open generate_from_le_iff_subset_is_open

/-- If `s` equals the collection of open sets in the topology it generates,
  then `s` defines a topology. -/
protected def mkOfClosure (s : Set (Set α))
    (hs : { u | (TopologicalSpace.generateFrom s).IsOpen u } = s) :
    TopologicalSpace α where 
  IsOpen u := u ∈ s
  is_open_univ := hs ▸ TopologicalSpace.GenerateOpen.univ
  is_open_inter := hs ▸ TopologicalSpace.GenerateOpen.inter
  is_open_sUnion := hs ▸ TopologicalSpace.GenerateOpen.sUnion
#align mk_of_closure mkOfClosure

theorem mk_of_closure_sets {s : Set (Set α)}
    {hs : { u | (TopologicalSpace.generateFrom s).IsOpen u } = s} :
    mkOfClosure s hs = TopologicalSpace.generateFrom s :=
  topological_space_eq hs.symm
#align mk_of_closure_sets mk_of_closure_sets

/-- The Galois insertion between `set (set α)` and `topological_space α` whose lower part
  sends a collection of subsets of α to the topology they generate, and whose upper part
  sends a topology to its collection of open subsets. -/
def giGenerateFrom (α : Type _) :
    GaloisInsertion TopologicalSpace.generateFrom fun t : TopologicalSpace α =>
      { s | t.IsOpen
          s } where 
  gc g t := generate_from_le_iff_subset_is_open
  le_l_u ts s hs := TopologicalSpace.GenerateOpen.basic s hs
  choice g hg :=
    mkOfClosure g (Subset.antisymm hg <| generate_from_le_iff_subset_is_open.1 <| le_rfl)
  choice_eq s hs := mk_of_closure_sets
#align gi_generate_from giGenerateFrom

theorem generate_from_mono {α} {g₁ g₂ : Set (Set α)} (h : g₁ ⊆ g₂) :
    TopologicalSpace.generateFrom g₁ ≤ TopologicalSpace.generateFrom g₂ :=
  (giGenerateFrom _).gc.monotone_l h
#align generate_from_mono generate_from_mono

theorem generate_from_set_of_is_open (t : TopologicalSpace α) :
    TopologicalSpace.generateFrom { s | t.IsOpen s } = t :=
  (giGenerateFrom α).l_u_eq t
#align generate_from_set_of_is_open generate_from_set_of_is_open

theorem left_inverse_generate_from :
    LeftInverse TopologicalSpace.generateFrom fun t : TopologicalSpace α => { s | t.IsOpen s } :=
  (giGenerateFrom α).left_inverse_l_u
#align left_inverse_generate_from left_inverse_generate_from

theorem generate_from_surjective :
    Surjective (TopologicalSpace.generateFrom : Set (Set α) → TopologicalSpace α) :=
  (giGenerateFrom α).l_surjective
#align generate_from_surjective generate_from_surjective

theorem set_of_is_open_injective : Injective fun t : TopologicalSpace α => { s | t.IsOpen s } :=
  (giGenerateFrom α).u_injective
#align set_of_is_open_injective set_of_is_open_injective

/-- The "temporary" order `tmp_order` on `topological_space α`, i.e. the inclusion order, is a
complete lattice.  (Note that later `topological_space α` will equipped with the dual order to
`tmp_order`). -/
def tmpCompleteLattice {α : Type u} : CompleteLattice (TopologicalSpace α) :=
  (giGenerateFrom α).liftCompleteLattice
#align tmp_complete_lattice tmpCompleteLattice

instance : LE (TopologicalSpace α) where le t s := s.IsOpen ≤ t.IsOpen

protected theorem TopologicalSpace.le_def {α} {t s : TopologicalSpace α} :
    t ≤ s ↔ s.IsOpen ≤ t.IsOpen :=
  Iff.rfl
#align topological_space.le_def TopologicalSpace.le_def

theorem IsOpen.mono {α} {t₁ t₂ : TopologicalSpace α} {s : Set α} (hs : @IsOpen α t₂ s)
    (h : t₁ ≤ t₂) : @IsOpen α t₁ s :=
  h s hs
#align is_open.mono IsOpen.mono

theorem IsClosed.mono {α} {t₁ t₂ : TopologicalSpace α} {s : Set α} (hs : @IsClosed α t₂ s)
    (h : t₁ ≤ t₂) : @IsClosed α t₁ s :=
  (@is_open_compl_iff α t₁ s).mp <| hs.is_open_compl.mono h
#align is_closed.mono IsClosed.mono

/-- The ordering on topologies on the type `α`.
  `t ≤ s` if every set open in `s` is also open in `t` (`t` is finer than `s`). -/
instance : PartialOrder (TopologicalSpace α) :=
  { TopologicalSpace.hasLe with
    le_antisymm := fun t s h₁ h₂ => topological_space_eq <| le_antisymm h₂ h₁
    le_refl := fun t => le_refl t.IsOpen
    le_trans := fun a b c h₁ h₂ => TopologicalSpace.le_def.mpr (le_trans h₂ h₁) }

theorem le_generate_from_iff_subset_is_open {g : Set (Set α)} {t : TopologicalSpace α} :
    t ≤ TopologicalSpace.generateFrom g ↔ g ⊆ { s | t.IsOpen s } :=
  generate_from_le_iff_subset_is_open
#align le_generate_from_iff_subset_is_open le_generate_from_iff_subset_is_open

/-- Topologies on `α` form a complete lattice, with `⊥` the discrete topology
  and `⊤` the indiscrete topology. The infimum of a collection of topologies
  is the topology generated by all their open sets, while the supremum is the
  topology whose open sets are those sets open in every member of the collection. -/
instance : CompleteLattice (TopologicalSpace α) :=
  @OrderDual.completeLattice _ tmpCompleteLattice

theorem is_open_implies_is_open_iff {a b : TopologicalSpace α} :
    (∀ s, a.IsOpen s → b.IsOpen s) ↔ b ≤ a :=
  Iff.rfl
#align is_open_implies_is_open_iff is_open_implies_is_open_iff

/-- The only open sets in the indiscrete topology are the empty set and the whole space. -/
theorem TopologicalSpace.is_open_top_iff {α} (U : Set α) :
    (⊤ : TopologicalSpace α).IsOpen U ↔ U = ∅ ∨ U = univ :=
  ⟨fun h => by 
    induction' h with V h _ _ _ _ ih₁ ih₂ _ _ ih
    · cases h; · exact Or.inr rfl
    · obtain ⟨rfl | rfl, rfl | rfl⟩ := ih₁, ih₂ <;> simp
    · rw [sUnion_eq_empty, or_iff_not_imp_left]
      intro h
      push_neg  at h
      obtain ⟨U, hU, hne⟩ := h
      have := (ih U hU).resolve_left hne
      subst this
      refine' sUnion_eq_univ_iff.2 fun a => ⟨_, hU, trivial⟩,
    by 
    rintro (rfl | rfl)
    exacts[@is_open_empty _ ⊤, @is_open_univ _ ⊤]⟩
#align topological_space.is_open_top_iff TopologicalSpace.is_open_top_iff

/- ./././Mathport/Syntax/Translate/Command.lean:379:30: infer kinds are unsupported in Lean 4: #[`eq_bot] [] -/
/-- A topological space is discrete if every set is open, that is,
  its topology equals the discrete topology `⊥`. -/
class DiscreteTopology (α : Type _) [t : TopologicalSpace α] : Prop where
  eq_bot : t = ⊥
#align discrete_topology DiscreteTopology

instance (priority := 100) discreteTopologyBot (α : Type _) :
    @DiscreteTopology α ⊥ where eq_bot := rfl
#align discrete_topology_bot discreteTopologyBot

@[simp]
theorem is_open_discrete [TopologicalSpace α] [DiscreteTopology α] (s : Set α) : IsOpen s :=
  (DiscreteTopology.eq_bot α).symm ▸ trivial
#align is_open_discrete is_open_discrete

@[simp]
theorem is_closed_discrete [TopologicalSpace α] [DiscreteTopology α] (s : Set α) : IsClosed s :=
  is_open_compl_iff.1 <| (DiscreteTopology.eq_bot α).symm ▸ trivial
#align is_closed_discrete is_closed_discrete

@[nontriviality]
theorem continuous_of_discrete_topology [TopologicalSpace α] [DiscreteTopology α]
    [TopologicalSpace β] {f : α → β} : Continuous f :=
  continuous_def.2 fun s hs => is_open_discrete _
#align continuous_of_discrete_topology continuous_of_discrete_topology

theorem nhds_bot (α : Type _) : @nhds α ⊥ = pure := by
  refine' le_antisymm _ (@pure_le_nhds α ⊥)
  intro a s hs
  exact @IsOpen.mem_nhds α ⊥ a s trivial hs
#align nhds_bot nhds_bot

theorem nhds_discrete (α : Type _) [TopologicalSpace α] [DiscreteTopology α] : @nhds α _ = pure :=
  (DiscreteTopology.eq_bot α).symm ▸ nhds_bot α
#align nhds_discrete nhds_discrete

theorem mem_nhds_discrete [TopologicalSpace α] [DiscreteTopology α] {x : α} {s : Set α} :
    s ∈ 𝓝 x ↔ x ∈ s := by rw [nhds_discrete, mem_pure]
#align mem_nhds_discrete mem_nhds_discrete

theorem le_of_nhds_le_nhds {t₁ t₂ : TopologicalSpace α} (h : ∀ x, @nhds α t₁ x ≤ @nhds α t₂ x) :
    t₁ ≤ t₂ := fun s =>
  show @IsOpen α t₂ s → @IsOpen α t₁ s by
    simp only [is_open_iff_nhds, le_principal_iff]
    exact fun hs a ha => h _ <| hs _ ha
#align le_of_nhds_le_nhds le_of_nhds_le_nhds

theorem eq_of_nhds_eq_nhds {t₁ t₂ : TopologicalSpace α} (h : ∀ x, @nhds α t₁ x = @nhds α t₂ x) :
    t₁ = t₂ :=
  le_antisymm (le_of_nhds_le_nhds fun x => le_of_eq <| h x)
    (le_of_nhds_le_nhds fun x => le_of_eq <| (h x).symm)
#align eq_of_nhds_eq_nhds eq_of_nhds_eq_nhds

theorem eq_bot_of_singletons_open {t : TopologicalSpace α} (h : ∀ x, t.IsOpen {x}) : t = ⊥ :=
  bot_unique fun s hs => bUnion_of_singleton s ▸ is_open_bUnion fun x _ => h x
#align eq_bot_of_singletons_open eq_bot_of_singletons_open

theorem forall_open_iff_discrete {X : Type _} [TopologicalSpace X] :
    (∀ s : Set X, IsOpen s) ↔ DiscreteTopology X :=
  ⟨fun h =>
    ⟨by 
      ext U
      show IsOpen U ↔ True
      simp [h U]⟩,
    fun a => @is_open_discrete _ _ a⟩
#align forall_open_iff_discrete forall_open_iff_discrete

theorem singletons_open_iff_discrete {X : Type _} [TopologicalSpace X] :
    (∀ a : X, IsOpen ({a} : Set X)) ↔ DiscreteTopology X :=
  ⟨fun h => ⟨eq_bot_of_singletons_open h⟩, fun a _ => @is_open_discrete _ _ a _⟩
#align singletons_open_iff_discrete singletons_open_iff_discrete

/-- This lemma characterizes discrete topological spaces as those whose singletons are
neighbourhoods. -/
theorem discrete_topology_iff_nhds [TopologicalSpace α] :
    DiscreteTopology α ↔ ∀ x : α, 𝓝 x = pure x := by
  constructor <;> intro h
  · intro x
    rw [nhds_discrete]
  · constructor
    apply eq_of_nhds_eq_nhds
    simp [h, nhds_discrete]
#align discrete_topology_iff_nhds discrete_topology_iff_nhds

theorem discrete_topology_iff_nhds_ne [TopologicalSpace α] :
    DiscreteTopology α ↔ ∀ x : α, 𝓝[≠] x = ⊥ := by
  rw [discrete_topology_iff_nhds]
  apply forall_congr' fun x => _
  rw [nhdsWithin, inf_principal_eq_bot, compl_compl]
  constructor <;> intro h
  · rw [h]
    exact singleton_mem_pure
  · exact le_antisymm (le_pure_iff.mpr h) (pure_le_nhds x)
#align discrete_topology_iff_nhds_ne discrete_topology_iff_nhds_ne

end Lattice

section GaloisConnection

variable {α : Type _} {β : Type _} {γ : Type _}

/-- Given `f : α → β` and a topology on `β`, the induced topology on `α` is the collection of
  sets that are preimages of some open set in `β`. This is the coarsest topology that
  makes `f` continuous. -/
def TopologicalSpace.induced {α : Type u} {β : Type v} (f : α → β) (t : TopologicalSpace β) :
    TopologicalSpace α where 
  IsOpen s := ∃ s', t.IsOpen s' ∧ f ⁻¹' s' = s
  is_open_univ := ⟨univ, t.is_open_univ, preimage_univ⟩
  is_open_inter := by
    rintro s₁ s₂ ⟨s'₁, hs₁, rfl⟩ ⟨s'₂, hs₂, rfl⟩ <;>
      exact ⟨s'₁ ∩ s'₂, t.is_open_inter _ _ hs₁ hs₂, preimage_inter⟩
  is_open_sUnion s h := by 
    simp only [Classical.skolem] at h
    cases' h with f hf
    apply Exists.intro (⋃ (x : Set α) (h : x ∈ s), f x h)
    simp only [sUnion_eq_bUnion, preimage_Union, fun x h => (hf x h).right]; refine' ⟨_, rfl⟩
    exact
      (@is_open_Union β _ t _) fun i =>
        show IsOpen (⋃ h, f i h) from (@is_open_Union β _ t _) fun h => (hf i h).left
#align topological_space.induced TopologicalSpace.induced

theorem is_open_induced_iff [t : TopologicalSpace β] {s : Set α} {f : α → β} :
    @IsOpen α (t.induced f) s ↔ ∃ t, IsOpen t ∧ f ⁻¹' t = s :=
  Iff.rfl
#align is_open_induced_iff is_open_induced_iff

theorem is_open_induced_iff' [t : TopologicalSpace β] {s : Set α} {f : α → β} :
    (t.induced f).IsOpen s ↔ ∃ t, IsOpen t ∧ f ⁻¹' t = s :=
  Iff.rfl
#align is_open_induced_iff' is_open_induced_iff'

theorem is_closed_induced_iff [t : TopologicalSpace β] {s : Set α} {f : α → β} :
    @IsClosed α (t.induced f) s ↔ ∃ t, IsClosed t ∧ f ⁻¹' t = s := by
  simp only [← is_open_compl_iff, is_open_induced_iff]
  exact compl_surjective.exists.trans (by simp only [preimage_compl, compl_inj_iff])
#align is_closed_induced_iff is_closed_induced_iff

/-- Given `f : α → β` and a topology on `α`, the coinduced topology on `β` is defined
  such that `s:set β` is open if the preimage of `s` is open. This is the finest topology that
  makes `f` continuous. -/
def TopologicalSpace.coinduced {α : Type u} {β : Type v} (f : α → β) (t : TopologicalSpace α) :
    TopologicalSpace β where 
  IsOpen s := t.IsOpen (f ⁻¹' s)
  is_open_univ := by rw [preimage_univ] <;> exact t.is_open_univ
  is_open_inter s₁ s₂ h₁ h₂ := by rw [preimage_inter] <;> exact t.is_open_inter _ _ h₁ h₂
  is_open_sUnion s h := by
    rw [preimage_sUnion] <;>
      exact
        (@is_open_Union _ _ t _) fun i =>
          show IsOpen (⋃ H : i ∈ s, f ⁻¹' i) from (@is_open_Union _ _ t _) fun hi => h i hi
#align topological_space.coinduced TopologicalSpace.coinduced

theorem is_open_coinduced {t : TopologicalSpace α} {s : Set β} {f : α → β} :
    @IsOpen β (TopologicalSpace.coinduced f t) s ↔ IsOpen (f ⁻¹' s) :=
  Iff.rfl
#align is_open_coinduced is_open_coinduced

theorem preimage_nhds_coinduced [TopologicalSpace α] {π : α → β} {s : Set β} {a : α}
    (hs : s ∈ @nhds β (TopologicalSpace.coinduced π ‹_›) (π a)) : π ⁻¹' s ∈ 𝓝 a := by
  letI := TopologicalSpace.coinduced π ‹_›
  rcases mem_nhds_iff.mp hs with ⟨V, hVs, V_op, mem_V⟩
  exact mem_nhds_iff.mpr ⟨π ⁻¹' V, Set.preimage_mono hVs, V_op, mem_V⟩
#align preimage_nhds_coinduced preimage_nhds_coinduced

variable {t t₁ t₂ : TopologicalSpace α} {t' : TopologicalSpace β} {f : α → β} {g : β → α}

theorem Continuous.coinduced_le (h : @Continuous α β t t' f) : t.coinduced f ≤ t' := fun s hs =>
  (continuous_def.1 h s hs : _)
#align continuous.coinduced_le Continuous.coinduced_le

theorem coinduced_le_iff_le_induced {f : α → β} {tα : TopologicalSpace α}
    {tβ : TopologicalSpace β} : tα.coinduced f ≤ tβ ↔ tα ≤ tβ.induced f :=
  Iff.intro (fun h s ⟨t, ht, hst⟩ => hst ▸ h _ ht) fun h s hs =>
    show tα.IsOpen (f ⁻¹' s) from h _ ⟨s, hs, rfl⟩
#align coinduced_le_iff_le_induced coinduced_le_iff_le_induced

theorem Continuous.le_induced (h : @Continuous α β t t' f) : t ≤ t'.induced f :=
  coinduced_le_iff_le_induced.1 h.coinduced_le
#align continuous.le_induced Continuous.le_induced

theorem gc_coinduced_induced (f : α → β) :
    GaloisConnection (TopologicalSpace.coinduced f) (TopologicalSpace.induced f) := fun f g =>
  coinduced_le_iff_le_induced
#align gc_coinduced_induced gc_coinduced_induced

theorem induced_mono (h : t₁ ≤ t₂) : t₁.induced g ≤ t₂.induced g :=
  (gc_coinduced_induced g).monotone_u h
#align induced_mono induced_mono

theorem coinduced_mono (h : t₁ ≤ t₂) : t₁.coinduced f ≤ t₂.coinduced f :=
  (gc_coinduced_induced f).monotone_l h
#align coinduced_mono coinduced_mono

@[simp]
theorem induced_top : (⊤ : TopologicalSpace α).induced g = ⊤ :=
  (gc_coinduced_induced g).u_top
#align induced_top induced_top

@[simp]
theorem induced_inf : (t₁ ⊓ t₂).induced g = t₁.induced g ⊓ t₂.induced g :=
  (gc_coinduced_induced g).u_inf
#align induced_inf induced_inf

@[simp]
theorem induced_infi {ι : Sort w} {t : ι → TopologicalSpace α} :
    (⨅ i, t i).induced g = ⨅ i, (t i).induced g :=
  (gc_coinduced_induced g).u_infi
#align induced_infi induced_infi

@[simp]
theorem coinduced_bot : (⊥ : TopologicalSpace α).coinduced f = ⊥ :=
  (gc_coinduced_induced f).l_bot
#align coinduced_bot coinduced_bot

@[simp]
theorem coinduced_sup : (t₁ ⊔ t₂).coinduced f = t₁.coinduced f ⊔ t₂.coinduced f :=
  (gc_coinduced_induced f).l_sup
#align coinduced_sup coinduced_sup

@[simp]
theorem coinduced_supr {ι : Sort w} {t : ι → TopologicalSpace α} :
    (⨆ i, t i).coinduced f = ⨆ i, (t i).coinduced f :=
  (gc_coinduced_induced f).l_supr
#align coinduced_supr coinduced_supr

theorem induced_id [t : TopologicalSpace α] : t.induced id = t :=
  topological_space_eq <|
    funext fun s => propext <| ⟨fun ⟨s', hs, h⟩ => h ▸ hs, fun hs => ⟨s, hs, rfl⟩⟩
#align induced_id induced_id

theorem induced_compose [tγ : TopologicalSpace γ] {f : α → β} {g : β → γ} :
    (tγ.induced g).induced f = tγ.induced (g ∘ f) :=
  topological_space_eq <|
    funext fun s =>
      propext <|
        ⟨fun ⟨s', ⟨s, hs, h₂⟩, h₁⟩ => h₁ ▸ h₂ ▸ ⟨s, hs, rfl⟩, fun ⟨s, hs, h⟩ =>
          ⟨preimage g s, ⟨s, hs, rfl⟩, h ▸ rfl⟩⟩
#align induced_compose induced_compose

theorem induced_const [t : TopologicalSpace α] {x : α} : (t.induced fun y : β => x) = ⊤ :=
  le_antisymm le_top (@continuous_const β α ⊤ t x).le_induced
#align induced_const induced_const

theorem coinduced_id [t : TopologicalSpace α] : t.coinduced id = t :=
  topological_space_eq rfl
#align coinduced_id coinduced_id

theorem coinduced_compose [tα : TopologicalSpace α] {f : α → β} {g : β → γ} :
    (tα.coinduced f).coinduced g = tα.coinduced (g ∘ f) :=
  topological_space_eq rfl
#align coinduced_compose coinduced_compose

theorem Equiv.induced_symm {α β : Type _} (e : α ≃ β) :
    TopologicalSpace.induced e.symm = TopologicalSpace.coinduced e := by
  ext (t U)
  constructor
  · rintro ⟨V, hV, rfl⟩
    change t.is_open (e ⁻¹' _)
    rwa [← preimage_comp, ← Equiv.coe_trans, Equiv.self_trans_symm]
  · intro hU
    refine' ⟨e ⁻¹' U, hU, _⟩
    rw [← preimage_comp, ← Equiv.coe_trans, Equiv.symm_trans_self, Equiv.coe_refl, preimage_id]
#align equiv.induced_symm Equiv.induced_symm

theorem Equiv.coinduced_symm {α β : Type _} (e : α ≃ β) :
    TopologicalSpace.coinduced e.symm = TopologicalSpace.induced e := by
  rw [← e.symm.induced_symm, e.symm_symm]
#align equiv.coinduced_symm Equiv.coinduced_symm

end GaloisConnection

-- constructions using the complete lattice structure
section Constructions

open TopologicalSpace

variable {α : Type u} {β : Type v}

instance inhabitedTopologicalSpace {α : Type u} : Inhabited (TopologicalSpace α) :=
  ⟨⊤⟩
#align inhabited_topological_space inhabitedTopologicalSpace

instance (priority := 100) Subsingleton.uniqueTopologicalSpace [Subsingleton α] :
    Unique (TopologicalSpace α) where 
  default := ⊥
  uniq t :=
    eq_bot_of_singletons_open fun x =>
      Subsingleton.set_cases (@is_open_empty _ t) (@is_open_univ _ t) ({x} : Set α)
#align subsingleton.unique_topological_space Subsingleton.uniqueTopologicalSpace

instance (priority := 100) Subsingleton.discreteTopology [t : TopologicalSpace α] [Subsingleton α] :
    DiscreteTopology α :=
  ⟨Unique.eq_default t⟩
#align subsingleton.discrete_topology Subsingleton.discreteTopology

instance : TopologicalSpace Empty :=
  ⊥

instance : DiscreteTopology Empty :=
  ⟨rfl⟩

instance : TopologicalSpace PEmpty :=
  ⊥

instance : DiscreteTopology PEmpty :=
  ⟨rfl⟩

instance : TopologicalSpace PUnit :=
  ⊥

instance : DiscreteTopology PUnit :=
  ⟨rfl⟩

instance : TopologicalSpace Bool :=
  ⊥

instance : DiscreteTopology Bool :=
  ⟨rfl⟩

instance : TopologicalSpace ℕ :=
  ⊥

instance : DiscreteTopology ℕ :=
  ⟨rfl⟩

instance : TopologicalSpace ℤ :=
  ⊥

instance : DiscreteTopology ℤ :=
  ⟨rfl⟩

instance sierpinskiSpace : TopologicalSpace Prop :=
  generateFrom {{True}}
#align sierpinski_space sierpinskiSpace

theorem continuous_empty_function [TopologicalSpace α] [TopologicalSpace β] [IsEmpty β]
    (f : α → β) : Continuous f :=
  letI := Function.isEmpty f
  continuous_of_discrete_topology
#align continuous_empty_function continuous_empty_function

theorem le_generate_from {t : TopologicalSpace α} {g : Set (Set α)} (h : ∀ s ∈ g, IsOpen s) :
    t ≤ generateFrom g :=
  le_generate_from_iff_subset_is_open.2 h
#align le_generate_from le_generate_from

theorem induced_generate_from_eq {α β} {b : Set (Set β)} {f : α → β} :
    (generateFrom b).induced f = TopologicalSpace.generateFrom (preimage f '' b) :=
  le_antisymm (le_generate_from <| ball_image_iff.2 fun s hs => ⟨s, GenerateOpen.basic _ hs, rfl⟩)
    (coinduced_le_iff_le_induced.1 <|
      le_generate_from fun s hs => GenerateOpen.basic _ <| mem_image_of_mem _ hs)
#align induced_generate_from_eq induced_generate_from_eq

theorem le_induced_generate_from {α β} [t : TopologicalSpace α] {b : Set (Set β)} {f : α → β}
    (h : ∀ a : Set β, a ∈ b → IsOpen (f ⁻¹' a)) : t ≤ induced f (generateFrom b) := by
  rw [induced_generate_from_eq]
  apply le_generate_from
  simp only [mem_image, and_imp, forall_apply_eq_imp_iff₂, exists_imp]
  exact h
#align le_induced_generate_from le_induced_generate_from

/-- This construction is left adjoint to the operation sending a topology on `α`
  to its neighborhood filter at a fixed point `a : α`. -/
def nhdsAdjoint (a : α) (f : Filter α) :
    TopologicalSpace α where 
  IsOpen s := a ∈ s → s ∈ f
  is_open_univ s := univ_mem
  is_open_inter := fun s t hs ht ⟨has, hat⟩ => inter_mem (hs has) (ht hat)
  is_open_sUnion := fun k hk ⟨u, hu, hau⟩ => mem_of_superset (hk u hu hau) (subset_sUnion_of_mem hu)
#align nhds_adjoint nhdsAdjoint

theorem gc_nhds (a : α) : GaloisConnection (nhdsAdjoint a) fun t => @nhds α t a := fun f t => by
  rw [le_nhds_iff]
  exact ⟨fun H s hs has => H _ has hs, fun H s has hs => H _ hs has⟩
#align gc_nhds gc_nhds

theorem nhds_mono {t₁ t₂ : TopologicalSpace α} {a : α} (h : t₁ ≤ t₂) :
    @nhds α t₁ a ≤ @nhds α t₂ a :=
  (gc_nhds a).monotone_u h
#align nhds_mono nhds_mono

theorem le_iff_nhds {α : Type _} (t t' : TopologicalSpace α) :
    t ≤ t' ↔ ∀ x, @nhds α t x ≤ @nhds α t' x :=
  ⟨fun h x => nhds_mono h, le_of_nhds_le_nhds⟩
#align le_iff_nhds le_iff_nhds

theorem nhds_adjoint_nhds {α : Type _} (a : α) (f : Filter α) :
    @nhds α (nhdsAdjoint a f) a = pure a ⊔ f := by
  ext U
  rw [mem_nhds_iff]
  constructor
  · rintro ⟨t, htU, ht, hat⟩
    exact ⟨htU hat, mem_of_superset (ht hat) htU⟩
  · rintro ⟨haU, hU⟩
    exact ⟨U, subset.rfl, fun h => hU, haU⟩
#align nhds_adjoint_nhds nhds_adjoint_nhds

theorem nhds_adjoint_nhds_of_ne {α : Type _} (a : α) (f : Filter α) {b : α} (h : b ≠ a) :
    @nhds α (nhdsAdjoint a f) b = pure b := by
  apply le_antisymm
  · intro U hU
    rw [mem_nhds_iff]
    use {b}
    simp only [and_true_iff, singleton_subset_iff, mem_singleton]
    refine' ⟨hU, fun ha => (h.symm ha).elim⟩
  · exact @pure_le_nhds α (nhdsAdjoint a f) b
#align nhds_adjoint_nhds_of_ne nhds_adjoint_nhds_of_ne

theorem is_open_singleton_nhds_adjoint {α : Type _} {a b : α} (f : Filter α) (hb : b ≠ a) :
    @IsOpen α (nhdsAdjoint a f) {b} := by
  rw [is_open_singleton_iff_nhds_eq_pure]
  exact nhds_adjoint_nhds_of_ne a f hb
#align is_open_singleton_nhds_adjoint is_open_singleton_nhds_adjoint

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (b «expr ≠ » a) -/
theorem le_nhds_adjoint_iff' {α : Type _} (a : α) (f : Filter α) (t : TopologicalSpace α) :
    t ≤ nhdsAdjoint a f ↔ @nhds α t a ≤ pure a ⊔ f ∧ ∀ (b) (_ : b ≠ a), @nhds α t b = pure b := by
  rw [le_iff_nhds]
  constructor
  · intro h
    constructor
    · specialize h a
      rwa [nhds_adjoint_nhds] at h
    · intro b hb
      apply le_antisymm _ (pure_le_nhds b)
      specialize h b
      rwa [nhds_adjoint_nhds_of_ne a f hb] at h
  · rintro ⟨h, h'⟩ b
    by_cases hb : b = a
    · rwa [hb, nhds_adjoint_nhds]
    · simp [nhds_adjoint_nhds_of_ne a f hb, h' b hb]
#align le_nhds_adjoint_iff' le_nhds_adjoint_iff'

theorem le_nhds_adjoint_iff {α : Type _} (a : α) (f : Filter α) (t : TopologicalSpace α) :
    t ≤ nhdsAdjoint a f ↔ @nhds α t a ≤ pure a ⊔ f ∧ ∀ b, b ≠ a → t.IsOpen {b} := by
  change _ ↔ _ ∧ ∀ b : α, b ≠ a → IsOpen {b}
  rw [le_nhds_adjoint_iff', and_congr_right_iff]
  apply fun h => forall_congr' fun b => _
  rw [@is_open_singleton_iff_nhds_eq_pure α t b]
#align le_nhds_adjoint_iff le_nhds_adjoint_iff

theorem nhds_infi {ι : Sort _} {t : ι → TopologicalSpace α} {a : α} :
    @nhds α (infi t) a = ⨅ i, @nhds α (t i) a :=
  (gc_nhds a).u_infi
#align nhds_infi nhds_infi

theorem nhds_Inf {s : Set (TopologicalSpace α)} {a : α} :
    @nhds α (inf s) a = ⨅ t ∈ s, @nhds α t a :=
  (gc_nhds a).u_Inf
#align nhds_Inf nhds_Inf

theorem nhds_inf {t₁ t₂ : TopologicalSpace α} {a : α} :
    @nhds α (t₁ ⊓ t₂) a = @nhds α t₁ a ⊓ @nhds α t₂ a :=
  (gc_nhds a).u_inf
#align nhds_inf nhds_inf

theorem nhds_top {a : α} : @nhds α ⊤ a = ⊤ :=
  (gc_nhds a).u_top
#align nhds_top nhds_top

theorem is_open_sup {t₁ t₂ : TopologicalSpace α} {s : Set α} :
    @IsOpen α (t₁ ⊔ t₂) s ↔ @IsOpen α t₁ s ∧ @IsOpen α t₂ s :=
  Iff.rfl
#align is_open_sup is_open_sup

-- mathport name: exprcont
local notation "cont" => @Continuous _ _

-- mathport name: exprtspace
local notation "tspace" => TopologicalSpace

open TopologicalSpace

variable {γ : Type _} {f : α → β} {ι : Sort _}

theorem continuous_iff_coinduced_le {t₁ : tspace α} {t₂ : tspace β} :
    cont t₁ t₂ f ↔ coinduced f t₁ ≤ t₂ :=
  continuous_def.trans Iff.rfl
#align continuous_iff_coinduced_le continuous_iff_coinduced_le

theorem continuous_iff_le_induced {t₁ : tspace α} {t₂ : tspace β} :
    cont t₁ t₂ f ↔ t₁ ≤ induced f t₂ :=
  Iff.trans continuous_iff_coinduced_le (gc_coinduced_induced f _ _)
#align continuous_iff_le_induced continuous_iff_le_induced

theorem continuous_generated_from {t : tspace α} {b : Set (Set β)} (h : ∀ s ∈ b, IsOpen (f ⁻¹' s)) :
    cont t (generateFrom b) f :=
  continuous_iff_coinduced_le.2 <| le_generate_from h
#align continuous_generated_from continuous_generated_from

@[continuity]
theorem continuous_induced_dom {t : tspace β} : cont (induced f t) t f := by
  rw [continuous_def]
  intro s h
  exact ⟨_, h, rfl⟩
#align continuous_induced_dom continuous_induced_dom

theorem continuous_induced_rng {g : γ → α} {t₂ : tspace β} {t₁ : tspace γ} :
    cont t₁ (induced f t₂) g ↔ cont t₁ t₂ (f ∘ g) := by
  simp only [continuous_iff_le_induced, induced_compose]
#align continuous_induced_rng continuous_induced_rng

theorem continuous_coinduced_rng {t : tspace α} : cont t (coinduced f t) f := by
  rw [continuous_def]
  intro s h
  exact h
#align continuous_coinduced_rng continuous_coinduced_rng

theorem continuous_coinduced_dom {g : β → γ} {t₁ : tspace α} {t₂ : tspace γ} :
    cont (coinduced f t₁) t₂ g ↔ cont t₁ t₂ (g ∘ f) := by
  simp only [continuous_iff_coinduced_le, coinduced_compose]
#align continuous_coinduced_dom continuous_coinduced_dom

theorem continuous_le_dom {t₁ t₂ : tspace α} {t₃ : tspace β} (h₁ : t₂ ≤ t₁) (h₂ : cont t₁ t₃ f) :
    cont t₂ t₃ f := by 
  rw [continuous_def] at h₂⊢
  intro s h
  exact h₁ _ (h₂ s h)
#align continuous_le_dom continuous_le_dom

theorem continuous_le_rng {t₁ : tspace α} {t₂ t₃ : tspace β} (h₁ : t₂ ≤ t₃) (h₂ : cont t₁ t₂ f) :
    cont t₁ t₃ f := by 
  rw [continuous_def] at h₂⊢
  intro s h
  exact h₂ s (h₁ s h)
#align continuous_le_rng continuous_le_rng

theorem continuous_sup_dom {t₁ t₂ : tspace α} {t₃ : tspace β} :
    cont (t₁ ⊔ t₂) t₃ f ↔ cont t₁ t₃ f ∧ cont t₂ t₃ f := by
  simp only [continuous_iff_le_induced, sup_le_iff]
#align continuous_sup_dom continuous_sup_dom

theorem continuous_sup_rng_left {t₁ : tspace α} {t₃ t₂ : tspace β} :
    cont t₁ t₂ f → cont t₁ (t₂ ⊔ t₃) f :=
  continuous_le_rng le_sup_left
#align continuous_sup_rng_left continuous_sup_rng_left

theorem continuous_sup_rng_right {t₁ : tspace α} {t₃ t₂ : tspace β} :
    cont t₁ t₃ f → cont t₁ (t₂ ⊔ t₃) f :=
  continuous_le_rng le_sup_right
#align continuous_sup_rng_right continuous_sup_rng_right

theorem continuous_Sup_dom {T : Set (tspace α)} {t₂ : tspace β} :
    cont (sup T) t₂ f ↔ ∀ t ∈ T, cont t t₂ f := by simp only [continuous_iff_le_induced, Sup_le_iff]
#align continuous_Sup_dom continuous_Sup_dom

theorem continuous_Sup_rng {t₁ : tspace α} {t₂ : Set (tspace β)} {t : tspace β} (h₁ : t ∈ t₂)
    (hf : cont t₁ t f) : cont t₁ (sup t₂) f :=
  continuous_iff_coinduced_le.2 <| le_Sup_of_le h₁ <| continuous_iff_coinduced_le.1 hf
#align continuous_Sup_rng continuous_Sup_rng

theorem continuous_supr_dom {t₁ : ι → tspace α} {t₂ : tspace β} :
    cont (supr t₁) t₂ f ↔ ∀ i, cont (t₁ i) t₂ f := by
  simp only [continuous_iff_le_induced, supr_le_iff]
#align continuous_supr_dom continuous_supr_dom

theorem continuous_supr_rng {t₁ : tspace α} {t₂ : ι → tspace β} {i : ι} (h : cont t₁ (t₂ i) f) :
    cont t₁ (supr t₂) f :=
  continuous_Sup_rng ⟨i, rfl⟩ h
#align continuous_supr_rng continuous_supr_rng

theorem continuous_inf_rng {t₁ : tspace α} {t₂ t₃ : tspace β} :
    cont t₁ (t₂ ⊓ t₃) f ↔ cont t₁ t₂ f ∧ cont t₁ t₃ f := by
  simp only [continuous_iff_coinduced_le, le_inf_iff]
#align continuous_inf_rng continuous_inf_rng

theorem continuous_inf_dom_left {t₁ t₂ : tspace α} {t₃ : tspace β} :
    cont t₁ t₃ f → cont (t₁ ⊓ t₂) t₃ f :=
  continuous_le_dom inf_le_left
#align continuous_inf_dom_left continuous_inf_dom_left

theorem continuous_inf_dom_right {t₁ t₂ : tspace α} {t₃ : tspace β} :
    cont t₂ t₃ f → cont (t₁ ⊓ t₂) t₃ f :=
  continuous_le_dom inf_le_right
#align continuous_inf_dom_right continuous_inf_dom_right

theorem continuous_Inf_dom {t₁ : Set (tspace α)} {t₂ : tspace β} {t : tspace α} (h₁ : t ∈ t₁) :
    cont t t₂ f → cont (inf t₁) t₂ f :=
  continuous_le_dom <| Inf_le h₁
#align continuous_Inf_dom continuous_Inf_dom

theorem continuous_Inf_rng {t₁ : tspace α} {T : Set (tspace β)} :
    cont t₁ (inf T) f ↔ ∀ t ∈ T, cont t₁ t f := by
  simp only [continuous_iff_coinduced_le, le_Inf_iff]
#align continuous_Inf_rng continuous_Inf_rng

theorem continuous_infi_dom {t₁ : ι → tspace α} {t₂ : tspace β} {i : ι} :
    cont (t₁ i) t₂ f → cont (infi t₁) t₂ f :=
  continuous_le_dom <| infi_le _ _
#align continuous_infi_dom continuous_infi_dom

theorem continuous_infi_rng {t₁ : tspace α} {t₂ : ι → tspace β} :
    cont t₁ (infi t₂) f ↔ ∀ i, cont t₁ (t₂ i) f := by
  simp only [continuous_iff_coinduced_le, le_infi_iff]
#align continuous_infi_rng continuous_infi_rng

@[continuity]
theorem continuous_bot {t : tspace β} : cont ⊥ t f :=
  continuous_iff_le_induced.2 <| bot_le
#align continuous_bot continuous_bot

@[continuity]
theorem continuous_top {t : tspace α} : cont t ⊤ f :=
  continuous_iff_coinduced_le.2 <| le_top
#align continuous_top continuous_top

theorem continuous_id_iff_le {t t' : tspace α} : cont t t' id ↔ t ≤ t' :=
  @continuous_def _ _ t t' id
#align continuous_id_iff_le continuous_id_iff_le

theorem continuous_id_of_le {t t' : tspace α} (h : t ≤ t') : cont t t' id :=
  continuous_id_iff_le.2 h
#align continuous_id_of_le continuous_id_of_le

-- 𝓝 in the induced topology
theorem mem_nhds_induced [T : TopologicalSpace α] (f : β → α) (a : β) (s : Set β) :
    s ∈ @nhds β (TopologicalSpace.induced f T) a ↔ ∃ u ∈ 𝓝 (f a), f ⁻¹' u ⊆ s := by
  simp only [mem_nhds_iff, is_open_induced_iff, exists_prop, Set.mem_setOf_eq]
  constructor
  · rintro ⟨u, usub, ⟨v, openv, ueq⟩, au⟩
    exact ⟨v, ⟨v, Set.Subset.refl v, openv, by rwa [← ueq] at au⟩, by rw [ueq] <;> exact usub⟩
  rintro ⟨u, ⟨v, vsubu, openv, amem⟩, finvsub⟩
  exact ⟨f ⁻¹' v, Set.Subset.trans (Set.preimage_mono vsubu) finvsub, ⟨⟨v, openv, rfl⟩, amem⟩⟩
#align mem_nhds_induced mem_nhds_induced

theorem nhds_induced [T : TopologicalSpace α] (f : β → α) (a : β) :
    @nhds β (TopologicalSpace.induced f T) a = comap f (𝓝 (f a)) := by
  ext s
  rw [mem_nhds_induced, mem_comap]
#align nhds_induced nhds_induced

theorem induced_iff_nhds_eq [tα : TopologicalSpace α] [tβ : TopologicalSpace β] (f : β → α) :
    tβ = tα.induced f ↔ ∀ b, 𝓝 b = comap f (𝓝 <| f b) :=
  ⟨fun h a => h.symm ▸ nhds_induced f a, fun h =>
    eq_of_nhds_eq_nhds fun x => by rw [h, nhds_induced]⟩
#align induced_iff_nhds_eq induced_iff_nhds_eq

theorem map_nhds_induced_of_surjective [T : TopologicalSpace α] {f : β → α} (hf : Surjective f)
    (a : β) : map f (@nhds β (TopologicalSpace.induced f T) a) = 𝓝 (f a) := by
  rw [nhds_induced, map_comap_of_surjective hf]
#align map_nhds_induced_of_surjective map_nhds_induced_of_surjective

end Constructions

section Induced

open TopologicalSpace

variable {α : Type _} {β : Type _}

variable [t : TopologicalSpace β] {f : α → β}

theorem is_open_induced_eq {s : Set α} :
    @IsOpen _ (induced f t) s ↔ s ∈ preimage f '' { s | IsOpen s } :=
  Iff.rfl
#align is_open_induced_eq is_open_induced_eq

theorem is_open_induced {s : Set β} (h : IsOpen s) : (induced f t).IsOpen (f ⁻¹' s) :=
  ⟨s, h, rfl⟩
#align is_open_induced is_open_induced

theorem map_nhds_induced_eq (a : α) : map f (@nhds α (induced f t) a) = 𝓝[range f] f a := by
  rw [nhds_induced, Filter.map_comap, nhdsWithin]
#align map_nhds_induced_eq map_nhds_induced_eq

theorem map_nhds_induced_of_mem {a : α} (h : range f ∈ 𝓝 (f a)) :
    map f (@nhds α (induced f t) a) = 𝓝 (f a) := by rw [nhds_induced, Filter.map_comap_of_mem h]
#align map_nhds_induced_of_mem map_nhds_induced_of_mem

theorem closure_induced [t : TopologicalSpace β] {f : α → β} {a : α} {s : Set α} :
    a ∈ @closure α (TopologicalSpace.induced f t) s ↔ f a ∈ closure (f '' s) := by
  simp only [mem_closure_iff_frequently, nhds_induced, frequently_comap, mem_image, and_comm']
#align closure_induced closure_induced

theorem is_closed_induced_iff' [t : TopologicalSpace β] {f : α → β} {s : Set α} :
    @IsClosed α (t.induced f) s ↔ ∀ a, f a ∈ closure (f '' s) → a ∈ s := by
  simp only [← closure_subset_iff_is_closed, subset_def, closure_induced]
#align is_closed_induced_iff' is_closed_induced_iff'

end Induced

section Sierpinski

variable {α : Type _} [TopologicalSpace α]

@[simp]
theorem is_open_singleton_true : IsOpen ({True} : Set Prop) :=
  TopologicalSpace.GenerateOpen.basic _ (mem_singleton _)
#align is_open_singleton_true is_open_singleton_true

@[simp]
theorem nhds_true : 𝓝 True = pure True :=
  le_antisymm (le_pure_iff.2 <| is_open_singleton_true.mem_nhds <| mem_singleton _) (pure_le_nhds _)
#align nhds_true nhds_true

@[simp]
theorem nhds_false : 𝓝 False = ⊤ :=
  TopologicalSpace.nhds_generate_from.trans <| by simp [@and_comm (_ ∈ _)]
#align nhds_false nhds_false

theorem continuous_Prop {p : α → Prop} : Continuous p ↔ IsOpen { x | p x } :=
  ⟨fun h : Continuous p => by
    have : IsOpen (p ⁻¹' {True}) := is_open_singleton_true.Preimage h
    simpa [preimage, eq_true_iff] using this, fun h : IsOpen { x | p x } =>
    continuous_generated_from fun s (hs : s = {True}) => by simp [hs, preimage, eq_true_iff, h]⟩
#align continuous_Prop continuous_Prop

theorem is_open_iff_continuous_mem {s : Set α} : IsOpen s ↔ Continuous fun x => x ∈ s :=
  continuous_Prop.symm
#align is_open_iff_continuous_mem is_open_iff_continuous_mem

end Sierpinski

section infi

variable {α : Type u} {ι : Sort v}

theorem generate_from_union (a₁ a₂ : Set (Set α)) :
    TopologicalSpace.generateFrom (a₁ ∪ a₂) =
      TopologicalSpace.generateFrom a₁ ⊓ TopologicalSpace.generateFrom a₂ :=
  @GaloisConnection.l_sup _ (TopologicalSpace α)ᵒᵈ a₁ a₂ _ _ _ _ fun g t =>
    generate_from_le_iff_subset_is_open
#align generate_from_union generate_from_union

theorem set_of_is_open_sup (t₁ t₂ : TopologicalSpace α) :
    { s | (t₁ ⊔ t₂).IsOpen s } = { s | t₁.IsOpen s } ∩ { s | t₂.IsOpen s } :=
  @GaloisConnection.u_inf _ (TopologicalSpace α)ᵒᵈ t₁ t₂ _ _ _ _ fun g t =>
    generate_from_le_iff_subset_is_open
#align set_of_is_open_sup set_of_is_open_sup

theorem generate_from_Union {f : ι → Set (Set α)} :
    TopologicalSpace.generateFrom (⋃ i, f i) = ⨅ i, TopologicalSpace.generateFrom (f i) :=
  @GaloisConnection.l_supr _ (TopologicalSpace α)ᵒᵈ _ _ _ _ _
    (fun g t => generate_from_le_iff_subset_is_open) f
#align generate_from_Union generate_from_Union

theorem set_of_is_open_supr {t : ι → TopologicalSpace α} :
    { s | (⨆ i, t i).IsOpen s } = ⋂ i, { s | (t i).IsOpen s } :=
  @GaloisConnection.u_infi _ (TopologicalSpace α)ᵒᵈ _ _ _ _ _
    (fun g t => generate_from_le_iff_subset_is_open) t
#align set_of_is_open_supr set_of_is_open_supr

theorem generate_from_sUnion {S : Set (Set (Set α))} :
    TopologicalSpace.generateFrom (⋃₀S) = ⨅ s ∈ S, TopologicalSpace.generateFrom s :=
  @GaloisConnection.l_Sup _ (TopologicalSpace α)ᵒᵈ _ _ _ _
    (fun g t => generate_from_le_iff_subset_is_open) S
#align generate_from_sUnion generate_from_sUnion

theorem set_of_is_open_Sup {T : Set (TopologicalSpace α)} :
    { s | (sup T).IsOpen s } = ⋂ t ∈ T, { s | (t : TopologicalSpace α).IsOpen s } :=
  @GaloisConnection.u_Inf _ (TopologicalSpace α)ᵒᵈ _ _ _ _
    (fun g t => generate_from_le_iff_subset_is_open) T
#align set_of_is_open_Sup set_of_is_open_Sup

theorem generate_from_union_is_open (a b : TopologicalSpace α) :
    TopologicalSpace.generateFrom ({ s | a.IsOpen s } ∪ { s | b.IsOpen s }) = a ⊓ b :=
  @GaloisInsertion.l_sup_u _ (TopologicalSpace α)ᵒᵈ _ _ _ _ (giGenerateFrom α) a b
#align generate_from_union_is_open generate_from_union_is_open

theorem generate_from_Union_is_open (f : ι → TopologicalSpace α) :
    TopologicalSpace.generateFrom (⋃ i, { s | (f i).IsOpen s }) = ⨅ i, f i :=
  @GaloisInsertion.l_supr_u _ (TopologicalSpace α)ᵒᵈ _ _ _ _ (giGenerateFrom α) _ f
#align generate_from_Union_is_open generate_from_Union_is_open

theorem generate_from_inter (a b : TopologicalSpace α) :
    TopologicalSpace.generateFrom ({ s | a.IsOpen s } ∩ { s | b.IsOpen s }) = a ⊔ b :=
  @GaloisInsertion.l_inf_u _ (TopologicalSpace α)ᵒᵈ _ _ _ _ (giGenerateFrom α) a b
#align generate_from_inter generate_from_inter

theorem generate_from_Inter (f : ι → TopologicalSpace α) :
    TopologicalSpace.generateFrom (⋂ i, { s | (f i).IsOpen s }) = ⨆ i, f i :=
  @GaloisInsertion.l_infi_u _ (TopologicalSpace α)ᵒᵈ _ _ _ _ (giGenerateFrom α) _ f
#align generate_from_Inter generate_from_Inter

theorem generate_from_Inter_of_generate_from_eq_self (f : ι → Set (Set α))
    (hf : ∀ i, { s | (TopologicalSpace.generateFrom (f i)).IsOpen s } = f i) :
    TopologicalSpace.generateFrom (⋂ i, f i) = ⨆ i, TopologicalSpace.generateFrom (f i) :=
  @GaloisInsertion.l_infi_of_ul_eq_self _ (TopologicalSpace α)ᵒᵈ _ _ _ _ (giGenerateFrom α) _ f hf
#align generate_from_Inter_of_generate_from_eq_self generate_from_Inter_of_generate_from_eq_self

variable {t : ι → TopologicalSpace α}

theorem is_open_supr_iff {s : Set α} : @IsOpen _ (⨆ i, t i) s ↔ ∀ i, @IsOpen _ (t i) s :=
  show s ∈ setOf (supr t).IsOpen ↔ s ∈ { x : Set α | ∀ i : ι, (t i).IsOpen x } by
    simp [set_of_is_open_supr]
#align is_open_supr_iff is_open_supr_iff

theorem is_closed_supr_iff {s : Set α} : @IsClosed _ (⨆ i, t i) s ↔ ∀ i, @IsClosed _ (t i) s := by
  simp [← is_open_compl_iff, is_open_supr_iff]
#align is_closed_supr_iff is_closed_supr_iff

end infi

