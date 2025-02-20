/-
Copyright (c) 2022 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module model_theory.direct_limit
! leanprover-community/mathlib commit f53b23994ac4c13afa38d31195c588a1121d1860
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Order
import Mathbin.Algebra.DirectLimit
import Mathbin.ModelTheory.Quotients
import Mathbin.ModelTheory.FinitelyGenerated

/-!
# Direct Limits of First-Order Structures
This file constructs the direct limit of a directed system of first-order embeddings.

## Main Definitions
* `first_order.language.direct_limit G f`  is the direct limit of the directed system `f` of
  first-order embeddings between the structures indexed by `G`.
-/


universe v w u₁ u₂

open scoped FirstOrder

namespace FirstOrder

namespace Language

open Structure Set

variable {L : Language} {ι : Type v} [Preorder ι]

variable {G : ι → Type w} [∀ i, L.Structure (G i)]

variable (f : ∀ i j, i ≤ j → G i ↪[L] G j)

namespace DirectedSystem

/-- A copy of `directed_system.map_self` specialized to `L`-embeddings, as otherwise the
`λ i j h, f i j h` can confuse the simplifier. -/
theorem map_self [DirectedSystem G fun i j h => f i j h] (i x h) : f i i h x = x :=
  DirectedSystem.map_self (fun i j h => f i j h) i x h
#align first_order.language.directed_system.map_self FirstOrder.Language.DirectedSystem.map_self

/-- A copy of `directed_system.map_map` specialized to `L`-embeddings, as otherwise the
`λ i j h, f i j h` can confuse the simplifier. -/
theorem map_map [DirectedSystem G fun i j h => f i j h] {i j k} (hij hjk x) :
    f j k hjk (f i j hij x) = f i k (le_trans hij hjk) x :=
  DirectedSystem.map_map (fun i j h => f i j h) hij hjk x
#align first_order.language.directed_system.map_map FirstOrder.Language.DirectedSystem.map_map

variable {G' : ℕ → Type w} [∀ i, L.Structure (G' i)] (f' : ∀ n : ℕ, G' n ↪[L] G' (n + 1))

/-- Given a chain of embeddings of structures indexed by `ℕ`, defines a `directed_system` by
composing them. -/
def natLeRec (m n : ℕ) (h : m ≤ n) : G' m ↪[L] G' n :=
  Nat.leRecOn h (fun k g => (f' k).comp g) (Embedding.refl L _)
#align first_order.language.directed_system.nat_le_rec FirstOrder.Language.DirectedSystem.natLeRec

@[simp]
theorem coe_natLeRec (m n : ℕ) (h : m ≤ n) :
    (natLeRec f' m n h : G' m → G' n) = Nat.leRecOn h fun n => f' n :=
  by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  ext x
  induction' k with k ih
  · rw [nat_le_rec, Nat.leRecOn_self, embedding.refl_apply, Nat.leRecOn_self]
  ·
    rw [Nat.leRecOn_succ le_self_add, nat_le_rec, Nat.leRecOn_succ le_self_add, ← nat_le_rec,
      embedding.comp_apply, ih]
#align first_order.language.directed_system.coe_nat_le_rec FirstOrder.Language.DirectedSystem.coe_natLeRec

instance natLeRec.directedSystem : DirectedSystem G' fun i j h => natLeRec f' i j h :=
  ⟨fun i x h => congr (congr rfl (Nat.leRecOn_self _)) rfl, fun i j k ij jk => by
    simp [Nat.leRecOn_trans ij jk]⟩
#align first_order.language.directed_system.nat_le_rec.directed_system FirstOrder.Language.DirectedSystem.natLeRec.directedSystem

end DirectedSystem

namespace DirectLimit

/-- Raises a family of elements in the `Σ`-type to the same level along the embeddings. -/
def unify {α : Type _} (x : α → Σ i, G i) (i : ι) (h : i ∈ upperBounds (range (Sigma.fst ∘ x)))
    (a : α) : G i :=
  f (x a).1 i (h (mem_range_self a)) (x a).2
#align first_order.language.direct_limit.unify FirstOrder.Language.DirectLimit.unify

variable [DirectedSystem G fun i j h => f i j h]

@[simp]
theorem unify_sigma_mk_self {α : Type _} {i : ι} {x : α → G i} :
    (unify f (Sigma.mk i ∘ x) i fun j ⟨a, hj⟩ => trans (le_of_eq hj.symm) (refl _)) = x :=
  by
  ext a
  simp only [unify, DirectedSystem.map_self]
#align first_order.language.direct_limit.unify_sigma_mk_self FirstOrder.Language.DirectLimit.unify_sigma_mk_self

theorem comp_unify {α : Type _} {x : α → Σ i, G i} {i j : ι} (ij : i ≤ j)
    (h : i ∈ upperBounds (range (Sigma.fst ∘ x))) :
    f i j ij ∘ unify f x i h = unify f x j fun k hk => trans (mem_upperBounds.1 h k hk) ij :=
  by
  ext a
  simp [unify, DirectedSystem.map_map]
#align first_order.language.direct_limit.comp_unify FirstOrder.Language.DirectLimit.comp_unify

end DirectLimit

variable (G)

namespace DirectLimit

/-- The directed limit glues together the structures along the embeddings. -/
def setoid [DirectedSystem G fun i j h => f i j h] [IsDirected ι (· ≤ ·)] : Setoid (Σ i, G i)
    where
  R := fun ⟨i, x⟩ ⟨j, y⟩ => ∃ (k : ι) (ik : i ≤ k) (jk : j ≤ k), f i k ik x = f j k jk y
  iseqv :=
    ⟨fun ⟨i, x⟩ => ⟨i, refl i, refl i, rfl⟩, fun ⟨i, x⟩ ⟨j, y⟩ ⟨k, ik, jk, h⟩ =>
      ⟨k, jk, ik, h.symm⟩, fun ⟨i, x⟩ ⟨j, y⟩ ⟨k, z⟩ ⟨ij, hiij, hjij, hij⟩ ⟨jk, hjjk, hkjk, hjk⟩ =>
      by
      obtain ⟨ijk, hijijk, hjkijk⟩ := directed_of (· ≤ ·) ij jk
      refine' ⟨ijk, le_trans hiij hijijk, le_trans hkjk hjkijk, _⟩
      rw [← DirectedSystem.map_map, hij, DirectedSystem.map_map]
      symm
      rw [← DirectedSystem.map_map, ← hjk, DirectedSystem.map_map]⟩
#align first_order.language.direct_limit.setoid FirstOrder.Language.DirectLimit.setoid

/-- The structure on the `Σ`-type which becomes the structure on the direct limit after quotienting.
 -/
noncomputable def sigmaStructure [IsDirected ι (· ≤ ·)] [Nonempty ι] : L.Structure (Σ i, G i)
    where
  funMap n F x :=
    ⟨_,
      funMap F
        (unify f x (Classical.choose (Fintype.bddAbove_range fun a => (x a).1))
          (Classical.choose_spec (Fintype.bddAbove_range fun a => (x a).1)))⟩
  rel_map n R x :=
    RelMap R
      (unify f x (Classical.choose (Fintype.bddAbove_range fun a => (x a).1))
        (Classical.choose_spec (Fintype.bddAbove_range fun a => (x a).1)))
#align first_order.language.direct_limit.sigma_structure FirstOrder.Language.DirectLimit.sigmaStructure

end DirectLimit

/-- The direct limit of a directed system is the structures glued together along the embeddings. -/
def DirectLimit [DirectedSystem G fun i j h => f i j h] [IsDirected ι (· ≤ ·)] :=
  Quotient (DirectLimit.setoid G f)
#align first_order.language.direct_limit FirstOrder.Language.DirectLimit

attribute [local instance] direct_limit.setoid

instance [DirectedSystem G fun i j h => f i j h] [IsDirected ι (· ≤ ·)] [Inhabited ι]
    [Inhabited (G default)] : Inhabited (DirectLimit G f) :=
  ⟨⟦⟨default, default⟩⟧⟩

namespace DirectLimit

variable [IsDirected ι (· ≤ ·)] [DirectedSystem G fun i j h => f i j h]

theorem equiv_iff {x y : Σ i, G i} {i : ι} (hx : x.1 ≤ i) (hy : y.1 ≤ i) :
    x ≈ y ↔ (f x.1 i hx) x.2 = (f y.1 i hy) y.2 :=
  by
  cases x
  cases y
  refine' ⟨fun xy => _, fun xy => ⟨i, hx, hy, xy⟩⟩
  obtain ⟨j, _, _, h⟩ := xy
  obtain ⟨k, ik, jk⟩ := directed_of (· ≤ ·) i j
  have h := congr_arg (f j k jk) h
  apply (f i k ik).Injective
  rw [DirectedSystem.map_map, DirectedSystem.map_map] at *
  exact h
#align first_order.language.direct_limit.equiv_iff FirstOrder.Language.DirectLimit.equiv_iff

theorem funMap_unify_equiv {n : ℕ} (F : L.Functions n) (x : Fin n → Σ i, G i) (i j : ι)
    (hi : i ∈ upperBounds (range (Sigma.fst ∘ x))) (hj : j ∈ upperBounds (range (Sigma.fst ∘ x))) :
    (⟨i, funMap F (unify f x i hi)⟩ : Σ i, G i) ≈ ⟨j, funMap F (unify f x j hj)⟩ :=
  by
  obtain ⟨k, ik, jk⟩ := directed_of (· ≤ ·) i j
  refine' ⟨k, ik, jk, _⟩
  rw [(f i k ik).map_fun, (f j k jk).map_fun, comp_unify, comp_unify]
#align first_order.language.direct_limit.fun_map_unify_equiv FirstOrder.Language.DirectLimit.funMap_unify_equiv

theorem relMap_unify_equiv {n : ℕ} (R : L.Relations n) (x : Fin n → Σ i, G i) (i j : ι)
    (hi : i ∈ upperBounds (range (Sigma.fst ∘ x))) (hj : j ∈ upperBounds (range (Sigma.fst ∘ x))) :
    RelMap R (unify f x i hi) = RelMap R (unify f x j hj) :=
  by
  obtain ⟨k, ik, jk⟩ := directed_of (· ≤ ·) i j
  rw [← (f i k ik).map_rel, comp_unify, ← (f j k jk).map_rel, comp_unify]
#align first_order.language.direct_limit.rel_map_unify_equiv FirstOrder.Language.DirectLimit.relMap_unify_equiv

variable [Nonempty ι]

theorem exists_unify_eq {α : Type _} [Fintype α] {x y : α → Σ i, G i} (xy : x ≈ y) :
    ∃ (i : ι) (hx : i ∈ upperBounds (range (Sigma.fst ∘ x))) (hy :
      i ∈ upperBounds (range (Sigma.fst ∘ y))), unify f x i hx = unify f y i hy :=
  by
  obtain ⟨i, hi⟩ := Fintype.bddAbove_range (Sum.elim (fun a => (x a).1) fun a => (y a).1)
  rw [sum.elim_range, upperBounds_union] at hi 
  simp_rw [← Function.comp_apply Sigma.fst _] at hi 
  exact ⟨i, hi.1, hi.2, funext fun a => (equiv_iff G f _ _).1 (xy a)⟩
#align first_order.language.direct_limit.exists_unify_eq FirstOrder.Language.DirectLimit.exists_unify_eq

theorem funMap_equiv_unify {n : ℕ} (F : L.Functions n) (x : Fin n → Σ i, G i) (i : ι)
    (hi : i ∈ upperBounds (range (Sigma.fst ∘ x))) :
    @funMap _ _ (sigmaStructure G f) _ F x ≈ ⟨_, funMap F (unify f x i hi)⟩ :=
  funMap_unify_equiv G f F x (Classical.choose (Fintype.bddAbove_range fun a => (x a).1)) i _ hi
#align first_order.language.direct_limit.fun_map_equiv_unify FirstOrder.Language.DirectLimit.funMap_equiv_unify

theorem relMap_equiv_unify {n : ℕ} (R : L.Relations n) (x : Fin n → Σ i, G i) (i : ι)
    (hi : i ∈ upperBounds (range (Sigma.fst ∘ x))) :
    @RelMap _ _ (sigmaStructure G f) _ R x = RelMap R (unify f x i hi) :=
  relMap_unify_equiv G f R x (Classical.choose (Fintype.bddAbove_range fun a => (x a).1)) i _ hi
#align first_order.language.direct_limit.rel_map_equiv_unify FirstOrder.Language.DirectLimit.relMap_equiv_unify

/-- The direct limit `setoid` respects the structure `sigma_structure`, so quotienting by it
  gives rise to a valid structure. -/
noncomputable instance prestructure : L.Prestructure (DirectLimit.setoid G f)
    where
  toStructure := sigmaStructure G f
  fun_equiv n F x y xy := by
    obtain ⟨i, hx, hy, h⟩ := exists_unify_eq G f xy
    refine'
      Setoid.trans (fun_map_equiv_unify G f F x i hx)
        (Setoid.trans _ (Setoid.symm (fun_map_equiv_unify G f F y i hy)))
    rw [h]
  rel_equiv n R x y xy := by
    obtain ⟨i, hx, hy, h⟩ := exists_unify_eq G f xy
    refine'
      trans (rel_map_equiv_unify G f R x i hx) (trans _ (symm (rel_map_equiv_unify G f R y i hy)))
    rw [h]
#align first_order.language.direct_limit.prestructure FirstOrder.Language.DirectLimit.prestructure

/-- The `L.Structure` on a direct limit of `L.Structure`s. -/
noncomputable instance structure : L.Structure (DirectLimit G f) :=
  Language.quotientStructure
#align first_order.language.direct_limit.Structure FirstOrder.Language.DirectLimit.structure

@[simp]
theorem funMap_quotient_mk'_sigma_mk' {n : ℕ} {F : L.Functions n} {i : ι} {x : Fin n → G i} :
    (funMap F fun a => (⟦⟨i, x a⟩⟧ : DirectLimit G f)) = ⟦⟨i, funMap F x⟩⟧ :=
  by
  simp only [Function.comp_apply, fun_map_quotient_mk, Quotient.eq']
  obtain ⟨k, ik, jk⟩ :=
    directed_of (· ≤ ·) i (Classical.choose (Fintype.bddAbove_range fun a : Fin n => i))
  refine' ⟨k, jk, ik, _⟩
  simp only [embedding.map_fun, comp_unify]
  rfl
#align first_order.language.direct_limit.fun_map_quotient_mk_sigma_mk FirstOrder.Language.DirectLimit.funMap_quotient_mk'_sigma_mk'

@[simp]
theorem relMap_quotient_mk'_sigma_mk' {n : ℕ} {R : L.Relations n} {i : ι} {x : Fin n → G i} :
    (RelMap R fun a => (⟦⟨i, x a⟩⟧ : DirectLimit G f)) = RelMap R x :=
  by
  rw [rel_map_quotient_mk]
  obtain ⟨k, ik, jk⟩ :=
    directed_of (· ≤ ·) i (Classical.choose (Fintype.bddAbove_range fun a : Fin n => i))
  rw [rel_map_equiv_unify G f R (fun a => ⟨i, x a⟩) i, unify_sigma_mk_self]
#align first_order.language.direct_limit.rel_map_quotient_mk_sigma_mk FirstOrder.Language.DirectLimit.relMap_quotient_mk'_sigma_mk'

theorem exists_quotient_mk'_sigma_mk'_eq {α : Type _} [Fintype α] (x : α → DirectLimit G f) :
    ∃ (i : ι) (y : α → G i), x = Quotient.mk' ∘ Sigma.mk i ∘ y :=
  by
  obtain ⟨i, hi⟩ := Fintype.bddAbove_range fun a => (x a).out.1
  refine' ⟨i, unify f (Quotient.out ∘ x) i hi, _⟩
  ext a
  rw [Quotient.eq_mk_iff_out, Function.comp_apply, unify, equiv_iff G f _]
  · simp only [DirectedSystem.map_self]
  · rfl
#align first_order.language.direct_limit.exists_quotient_mk_sigma_mk_eq FirstOrder.Language.DirectLimit.exists_quotient_mk'_sigma_mk'_eq

variable (L ι)

/-- The canonical map from a component to the direct limit. -/
def of (i : ι) : G i ↪[L] DirectLimit G f
    where
  toFun := Quotient.mk' ∘ Sigma.mk i
  inj' x y h := by
    simp only [Quotient.eq'] at h 
    obtain ⟨j, h1, h2, h3⟩ := h
    exact (f i j h1).Injective h3
#align first_order.language.direct_limit.of FirstOrder.Language.DirectLimit.of

variable {L ι G f}

@[simp]
theorem of_apply {i : ι} {x : G i} : of L ι G f i x = ⟦⟨i, x⟩⟧ :=
  rfl
#align first_order.language.direct_limit.of_apply FirstOrder.Language.DirectLimit.of_apply

@[simp]
theorem of_f {i j : ι} {hij : i ≤ j} {x : G i} : of L ι G f j (f i j hij x) = of L ι G f i x :=
  by
  simp only [of_apply, Quotient.eq']
  refine' Setoid.symm ⟨j, hij, refl j, _⟩
  simp only [DirectedSystem.map_self]
#align first_order.language.direct_limit.of_f FirstOrder.Language.DirectLimit.of_f

/-- Every element of the direct limit corresponds to some element in
some component of the directed system. -/
theorem exists_of (z : DirectLimit G f) : ∃ i x, of L ι G f i x = z :=
  ⟨z.out.1, z.out.2, by simp⟩
#align first_order.language.direct_limit.exists_of FirstOrder.Language.DirectLimit.exists_of

@[elab_as_elim]
protected theorem induction_on {C : DirectLimit G f → Prop} (z : DirectLimit G f)
    (ih : ∀ i x, C (of L ι G f i x)) : C z :=
  let ⟨i, x, h⟩ := exists_of z
  h ▸ ih i x
#align first_order.language.direct_limit.induction_on FirstOrder.Language.DirectLimit.induction_on

variable {P : Type u₁} [L.Structure P] (g : ∀ i, G i ↪[L] P)

variable (Hg : ∀ i j hij x, g j (f i j hij x) = g i x)

variable (L ι G f)

/-- The universal property of the direct limit: maps from the components to another module
that respect the directed system structure (i.e. make some diagram commute) give rise
to a unique map out of the direct limit. -/
def lift : DirectLimit G f ↪[L] P
    where
  toFun :=
    Quotient.lift (fun x : Σ i, G i => (g x.1) x.2) fun x y xy =>
      by
      simp only
      obtain ⟨i, hx, hy⟩ := directed_of (· ≤ ·) x.1 y.1
      rw [← Hg x.1 i hx, ← Hg y.1 i hy]
      exact congr_arg _ ((equiv_iff _ _ _ _).1 xy)
  inj' x y xy :=
    by
    rw [← Quotient.out_eq x, ← Quotient.out_eq y, Quotient.lift_mk, Quotient.lift_mk] at xy 
    obtain ⟨i, hx, hy⟩ := directed_of (· ≤ ·) x.out.1 y.out.1
    rw [← Hg x.out.1 i hx, ← Hg y.out.1 i hy] at xy 
    rw [← Quotient.out_eq x, ← Quotient.out_eq y, Quotient.eq', equiv_iff G f hx hy]
    exact (g i).Injective xy
  map_fun' n F x := by
    obtain ⟨i, y, rfl⟩ := exists_quotient_mk_sigma_mk_eq G f x
    rw [fun_map_quotient_mk_sigma_mk, ← Function.comp.assoc, Quotient.lift_comp_mk]
    simp only [Quotient.lift_mk, embedding.map_fun]
  map_rel' n R x := by
    obtain ⟨i, y, rfl⟩ := exists_quotient_mk_sigma_mk_eq G f x
    rw [rel_map_quotient_mk_sigma_mk G f, ← (g i).map_rel R y, ← Function.comp.assoc,
      Quotient.lift_comp_mk]
#align first_order.language.direct_limit.lift FirstOrder.Language.DirectLimit.lift

variable {L ι G f}

@[simp]
theorem lift_quotient_mk'_sigma_mk' {i} (x : G i) : lift L ι G f g Hg ⟦⟨i, x⟩⟧ = (g i) x :=
  by
  change (lift L ι G f g Hg).toFun ⟦⟨i, x⟩⟧ = _
  simp only [lift, Quotient.lift_mk]
#align first_order.language.direct_limit.lift_quotient_mk_sigma_mk FirstOrder.Language.DirectLimit.lift_quotient_mk'_sigma_mk'

theorem lift_of {i} (x : G i) : lift L ι G f g Hg (of L ι G f i x) = g i x := by simp
#align first_order.language.direct_limit.lift_of FirstOrder.Language.DirectLimit.lift_of

theorem lift_unique (F : DirectLimit G f ↪[L] P) (x) :
    F x =
      lift L ι G f (fun i => F.comp <| of L ι G f i)
        (fun i j hij x => by rw [F.comp_apply, F.comp_apply, of_f]) x :=
  DirectLimit.induction_on x fun i x => by rw [lift_of] <;> rfl
#align first_order.language.direct_limit.lift_unique FirstOrder.Language.DirectLimit.lift_unique

/-- The direct limit of countably many countably generated structures is countably generated. -/
theorem cG {ι : Type _} [Encodable ι] [Preorder ι] [IsDirected ι (· ≤ ·)] [Nonempty ι]
    {G : ι → Type w} [∀ i, L.Structure (G i)] (f : ∀ i j, i ≤ j → G i ↪[L] G j)
    (h : ∀ i, Structure.CG L (G i)) [DirectedSystem G fun i j h => f i j h] :
    Structure.CG L (DirectLimit G f) :=
  by
  refine' ⟨⟨⋃ i, direct_limit.of L ι G f i '' Classical.choose (h i).out, _, _⟩⟩
  · exact Set.countable_iUnion fun i => Set.Countable.image (Classical.choose_spec (h i).out).1 _
  · rw [eq_top_iff, substructure.closure_Union]
    simp_rw [← embedding.coe_to_hom, substructure.closure_image]
    rw [le_iSup_iff]
    intro S hS x hx
    let out := @Quotient.out _ (direct_limit.setoid G f)
    refine' hS (out x).1 ⟨(out x).2, _, _⟩
    · rw [(Classical.choose_spec (h (out x).1).out).2]
      simp only [substructure.coe_top]
    · simp only [embedding.coe_to_hom, direct_limit.of_apply, Sigma.eta, Quotient.out_eq]
#align first_order.language.direct_limit.cg FirstOrder.Language.DirectLimit.cG

instance cg' {ι : Type _} [Encodable ι] [Preorder ι] [IsDirected ι (· ≤ ·)] [Nonempty ι]
    {G : ι → Type w} [∀ i, L.Structure (G i)] (f : ∀ i j, i ≤ j → G i ↪[L] G j)
    [h : ∀ i, Structure.CG L (G i)] [DirectedSystem G fun i j h => f i j h] :
    Structure.CG L (DirectLimit G f) :=
  cG f h
#align first_order.language.direct_limit.cg' FirstOrder.Language.DirectLimit.cg'

end DirectLimit

end Language

end FirstOrder

