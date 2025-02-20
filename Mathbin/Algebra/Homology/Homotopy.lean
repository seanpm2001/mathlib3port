/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module algebra.homology.homotopy
! leanprover-community/mathlib commit 86d1873c01a723aba6788f0b9051ae3d23b4c1c3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Homology.Additive
import Mathbin.Tactic.Abel

/-!
# Chain homotopies

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define chain homotopies, and prove that homotopic chain maps induce the same map on homology.
-/


universe v u

open scoped Classical

noncomputable section

open CategoryTheory CategoryTheory.Limits HomologicalComplex

variable {ι : Type _}

variable {V : Type u} [Category.{v} V] [Preadditive V]

variable {c : ComplexShape ι} {C D E : HomologicalComplex V c}

variable (f g : C ⟶ D) (h k : D ⟶ E) (i : ι)

section

#print dNext /-
/-- The composition of `C.d i i' ≫ f i' i` if there is some `i'` coming after `i`,
and `0` otherwise. -/
def dNext (i : ι) : (∀ i j, C.pt i ⟶ D.pt j) →+ (C.pt i ⟶ D.pt i) :=
  AddMonoidHom.mk' (fun f => C.d i (c.next i) ≫ f (c.next i) i) fun f g =>
    Preadditive.comp_add _ _ _ _ _ _
#align d_next dNext
-/

#print fromNext /-
/-- `f i' i` if `i'` comes after `i`, and 0 if there's no such `i'`.
Hopefully there won't be much need for this, except in `d_next_eq_d_from_from_next`
to see that `d_next` factors through `C.d_from i`. -/
def fromNext (i : ι) : (∀ i j, C.pt i ⟶ D.pt j) →+ (C.xNext i ⟶ D.pt i) :=
  AddMonoidHom.mk' (fun f => f (c.next i) i) fun f g => rfl
#align from_next fromNext
-/

#print dNext_eq_dFrom_fromNext /-
@[simp]
theorem dNext_eq_dFrom_fromNext (f : ∀ i j, C.pt i ⟶ D.pt j) (i : ι) :
    dNext i f = C.dFrom i ≫ fromNext i f :=
  rfl
#align d_next_eq_d_from_from_next dNext_eq_dFrom_fromNext
-/

#print dNext_eq /-
theorem dNext_eq (f : ∀ i j, C.pt i ⟶ D.pt j) {i i' : ι} (w : c.Rel i i') :
    dNext i f = C.d i i' ≫ f i' i := by obtain rfl := c.next_eq' w; rfl
#align d_next_eq dNext_eq
-/

#print dNext_comp_left /-
@[simp]
theorem dNext_comp_left (f : C ⟶ D) (g : ∀ i j, D.pt i ⟶ E.pt j) (i : ι) :
    (dNext i fun i j => f.f i ≫ g i j) = f.f i ≫ dNext i g :=
  (f.comm_assoc _ _ _).symm
#align d_next_comp_left dNext_comp_left
-/

#print dNext_comp_right /-
@[simp]
theorem dNext_comp_right (f : ∀ i j, C.pt i ⟶ D.pt j) (g : D ⟶ E) (i : ι) :
    (dNext i fun i j => f i j ≫ g.f j) = dNext i f ≫ g.f i :=
  (Category.assoc _ _ _).symm
#align d_next_comp_right dNext_comp_right
-/

#print prevD /-
/-- The composition of `f j j' ≫ D.d j' j` if there is some `j'` coming before `j`,
and `0` otherwise. -/
def prevD (j : ι) : (∀ i j, C.pt i ⟶ D.pt j) →+ (C.pt j ⟶ D.pt j) :=
  AddMonoidHom.mk' (fun f => f j (c.prev j) ≫ D.d (c.prev j) j) fun f g =>
    Preadditive.add_comp _ _ _ _ _ _
#align prev_d prevD
-/

#print toPrev /-
/-- `f j j'` if `j'` comes after `j`, and 0 if there's no such `j'`.
Hopefully there won't be much need for this, except in `d_next_eq_d_from_from_next`
to see that `d_next` factors through `C.d_from i`. -/
def toPrev (j : ι) : (∀ i j, C.pt i ⟶ D.pt j) →+ (C.pt j ⟶ D.xPrev j) :=
  AddMonoidHom.mk' (fun f => f j (c.prev j)) fun f g => rfl
#align to_prev toPrev
-/

#print prevD_eq_toPrev_dTo /-
@[simp]
theorem prevD_eq_toPrev_dTo (f : ∀ i j, C.pt i ⟶ D.pt j) (j : ι) :
    prevD j f = toPrev j f ≫ D.dTo j :=
  rfl
#align prev_d_eq_to_prev_d_to prevD_eq_toPrev_dTo
-/

#print prevD_eq /-
theorem prevD_eq (f : ∀ i j, C.pt i ⟶ D.pt j) {j j' : ι} (w : c.Rel j' j) :
    prevD j f = f j j' ≫ D.d j' j := by obtain rfl := c.prev_eq' w; rfl
#align prev_d_eq prevD_eq
-/

#print prevD_comp_left /-
@[simp]
theorem prevD_comp_left (f : C ⟶ D) (g : ∀ i j, D.pt i ⟶ E.pt j) (j : ι) :
    (prevD j fun i j => f.f i ≫ g i j) = f.f j ≫ prevD j g :=
  Category.assoc _ _ _
#align prev_d_comp_left prevD_comp_left
-/

#print prevD_comp_right /-
@[simp]
theorem prevD_comp_right (f : ∀ i j, C.pt i ⟶ D.pt j) (g : D ⟶ E) (j : ι) :
    (prevD j fun i j => f i j ≫ g.f j) = prevD j f ≫ g.f j := by dsimp [prevD];
  simp only [category.assoc, g.comm]
#align prev_d_comp_right prevD_comp_right
-/

#print dNext_nat /-
theorem dNext_nat (C D : ChainComplex V ℕ) (i : ℕ) (f : ∀ i j, C.pt i ⟶ D.pt j) :
    dNext i f = C.d i (i - 1) ≫ f (i - 1) i :=
  by
  dsimp [dNext]
  cases i
  ·
    simp only [shape, ChainComplex.next_nat_zero, ComplexShape.down_Rel, Nat.one_ne_zero,
      not_false_iff, zero_comp]
  · dsimp only [Nat.succ_eq_add_one]
    have : (ComplexShape.down ℕ).next (i + 1) = i + 1 - 1 := by rw [ChainComplex.next_nat_succ]; rfl
    congr 2
#align d_next_nat dNext_nat
-/

#print prevD_nat /-
theorem prevD_nat (C D : CochainComplex V ℕ) (i : ℕ) (f : ∀ i j, C.pt i ⟶ D.pt j) :
    prevD i f = f i (i - 1) ≫ D.d (i - 1) i :=
  by
  dsimp [prevD]
  cases i
  ·
    simp only [shape, CochainComplex.prev_nat_zero, ComplexShape.up_Rel, Nat.one_ne_zero,
      not_false_iff, comp_zero]
  · dsimp only [Nat.succ_eq_add_one]
    have : (ComplexShape.up ℕ).prev (i + 1) = i + 1 - 1 := by rw [CochainComplex.prev_nat_succ]; rfl
    congr 2
#align prev_d_nat prevD_nat
-/

#print Homotopy /-
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic obviously' -/
/-- A homotopy `h` between chain maps `f` and `g` consists of components `h i j : C.X i ⟶ D.X j`
which are zero unless `c.rel j i`, satisfying the homotopy condition.
-/
@[ext, nolint has_nonempty_instance]
structure Homotopy (f g : C ⟶ D) where
  Hom : ∀ i j, C.pt i ⟶ D.pt j
  zero' : ∀ i j, ¬c.Rel j i → hom i j = 0 := by obviously
  comm : ∀ i, f.f i = dNext i hom + prevD i hom + g.f i := by
    run_tac
      obviously'
#align homotopy Homotopy
-/

variable {f g}

namespace Homotopy

restate_axiom Homotopy.zero'

#print Homotopy.equivSubZero /-
/-- `f` is homotopic to `g` iff `f - g` is homotopic to `0`.
-/
def equivSubZero : Homotopy f g ≃ Homotopy (f - g) 0
    where
  toFun h :=
    { Hom := fun i j => h.Hom i j
      zero' := fun i j w => h.zero _ _ w
      comm := fun i => by simp [h.comm] }
  invFun h :=
    { Hom := fun i j => h.Hom i j
      zero' := fun i j w => h.zero _ _ w
      comm := fun i => by simpa [sub_eq_iff_eq_add] using h.comm i }
  left_inv := by tidy
  right_inv := by tidy
#align homotopy.equiv_sub_zero Homotopy.equivSubZero
-/

#print Homotopy.ofEq /-
/-- Equal chain maps are homotopic. -/
@[simps]
def ofEq (h : f = g) : Homotopy f g where
  Hom := 0
  zero' _ _ _ := rfl
  comm _ := by simp only [AddMonoidHom.map_zero, zero_add, h]
#align homotopy.of_eq Homotopy.ofEq
-/

#print Homotopy.refl /-
/-- Every chain map is homotopic to itself. -/
@[simps, refl]
def refl (f : C ⟶ D) : Homotopy f f :=
  ofEq (rfl : f = f)
#align homotopy.refl Homotopy.refl
-/

#print Homotopy.symm /-
/-- `f` is homotopic to `g` iff `g` is homotopic to `f`. -/
@[simps, symm]
def symm {f g : C ⟶ D} (h : Homotopy f g) : Homotopy g f
    where
  Hom := -h.Hom
  zero' i j w := by rw [Pi.neg_apply, Pi.neg_apply, h.zero i j w, neg_zero]
  comm i := by
    rw [AddMonoidHom.map_neg, AddMonoidHom.map_neg, h.comm, ← neg_add, ← add_assoc, neg_add_self,
      zero_add]
#align homotopy.symm Homotopy.symm
-/

#print Homotopy.trans /-
/-- homotopy is a transitive relation. -/
@[simps, trans]
def trans {e f g : C ⟶ D} (h : Homotopy e f) (k : Homotopy f g) : Homotopy e g
    where
  Hom := h.Hom + k.Hom
  zero' i j w := by rw [Pi.add_apply, Pi.add_apply, h.zero i j w, k.zero i j w, zero_add]
  comm i := by rw [AddMonoidHom.map_add, AddMonoidHom.map_add, h.comm, k.comm]; abel
#align homotopy.trans Homotopy.trans
-/

#print Homotopy.add /-
/-- the sum of two homotopies is a homotopy between the sum of the respective morphisms. -/
@[simps]
def add {f₁ g₁ f₂ g₂ : C ⟶ D} (h₁ : Homotopy f₁ g₁) (h₂ : Homotopy f₂ g₂) :
    Homotopy (f₁ + f₂) (g₁ + g₂) where
  Hom := h₁.Hom + h₂.Hom
  zero' i j hij := by rw [Pi.add_apply, Pi.add_apply, h₁.zero' i j hij, h₂.zero' i j hij, add_zero]
  comm i :=
    by
    simp only [HomologicalComplex.add_f_apply, h₁.comm, h₂.comm, AddMonoidHom.map_add]
    abel
#align homotopy.add Homotopy.add
-/

#print Homotopy.compRight /-
/-- homotopy is closed under composition (on the right) -/
@[simps]
def compRight {e f : C ⟶ D} (h : Homotopy e f) (g : D ⟶ E) : Homotopy (e ≫ g) (f ≫ g)
    where
  Hom i j := h.Hom i j ≫ g.f j
  zero' i j w := by rw [h.zero i j w, zero_comp]
  comm i := by
    simp only [h.comm i, dNext_comp_right, preadditive.add_comp, prevD_comp_right, comp_f]
#align homotopy.comp_right Homotopy.compRight
-/

#print Homotopy.compLeft /-
/-- homotopy is closed under composition (on the left) -/
@[simps]
def compLeft {f g : D ⟶ E} (h : Homotopy f g) (e : C ⟶ D) : Homotopy (e ≫ f) (e ≫ g)
    where
  Hom i j := e.f i ≫ h.Hom i j
  zero' i j w := by rw [h.zero i j w, comp_zero]
  comm i := by simp only [h.comm i, dNext_comp_left, preadditive.comp_add, prevD_comp_left, comp_f]
#align homotopy.comp_left Homotopy.compLeft
-/

#print Homotopy.comp /-
/-- homotopy is closed under composition -/
@[simps]
def comp {C₁ C₂ C₃ : HomologicalComplex V c} {f₁ g₁ : C₁ ⟶ C₂} {f₂ g₂ : C₂ ⟶ C₃}
    (h₁ : Homotopy f₁ g₁) (h₂ : Homotopy f₂ g₂) : Homotopy (f₁ ≫ f₂) (g₁ ≫ g₂) :=
  (h₁.compRight _).trans (h₂.compLeft _)
#align homotopy.comp Homotopy.comp
-/

#print Homotopy.compRightId /-
/-- a variant of `homotopy.comp_right` useful for dealing with homotopy equivalences. -/
@[simps]
def compRightId {f : C ⟶ C} (h : Homotopy f (𝟙 C)) (g : C ⟶ D) : Homotopy (f ≫ g) g :=
  (h.compRight g).trans (ofEq <| Category.id_comp _)
#align homotopy.comp_right_id Homotopy.compRightId
-/

#print Homotopy.compLeftId /-
/-- a variant of `homotopy.comp_left` useful for dealing with homotopy equivalences. -/
@[simps]
def compLeftId {f : D ⟶ D} (h : Homotopy f (𝟙 D)) (g : C ⟶ D) : Homotopy (g ≫ f) g :=
  (h.compLeft g).trans (ofEq <| Category.comp_id _)
#align homotopy.comp_left_id Homotopy.compLeftId
-/

/-!
Null homotopic maps can be constructed using the formula `hd+dh`. We show that
these morphisms are homotopic to `0` and provide some convenient simplification
lemmas that give a degreewise description of `hd+dh`, depending on whether we have
two differentials going to and from a certain degree, only one, or none.
-/


#print Homotopy.nullHomotopicMap /-
/-- The null homotopic map associated to a family `hom` of morphisms `C_i ⟶ D_j`.
This is the same datum as for the field `hom` in the structure `homotopy`. For
this definition, we do not need the field `zero` of that structure
as this definition uses only the maps `C_i ⟶ C_j` when `c.rel j i`. -/
def nullHomotopicMap (hom : ∀ i j, C.pt i ⟶ D.pt j) : C ⟶ D
    where
  f i := dNext i hom + prevD i hom
  comm' i j hij :=
    by
    have eq1 : prevD i hom ≫ D.d i j = 0 := by
      simp only [prevD, AddMonoidHom.mk'_apply, category.assoc, d_comp_d, comp_zero]
    have eq2 : C.d i j ≫ dNext j hom = 0 := by
      simp only [dNext, AddMonoidHom.mk'_apply, d_comp_d_assoc, zero_comp]
    rw [dNext_eq hom hij, prevD_eq hom hij, preadditive.comp_add, preadditive.add_comp, eq1, eq2,
      add_zero, zero_add, category.assoc]
#align homotopy.null_homotopic_map Homotopy.nullHomotopicMap
-/

#print Homotopy.nullHomotopicMap' /-
/-- Variant of `null_homotopic_map` where the input consists only of the
relevant maps `C_i ⟶ D_j` such that `c.rel j i`. -/
def nullHomotopicMap' (h : ∀ i j, c.Rel j i → (C.pt i ⟶ D.pt j)) : C ⟶ D :=
  nullHomotopicMap fun i j => dite (c.Rel j i) (h i j) fun _ => 0
#align homotopy.null_homotopic_map' Homotopy.nullHomotopicMap'
-/

#print Homotopy.nullHomotopicMap_comp /-
/-- Compatibility of `null_homotopic_map` with the postcomposition by a morphism
of complexes. -/
theorem nullHomotopicMap_comp (hom : ∀ i j, C.pt i ⟶ D.pt j) (g : D ⟶ E) :
    nullHomotopicMap hom ≫ g = nullHomotopicMap fun i j => hom i j ≫ g.f j :=
  by
  ext n
  dsimp [null_homotopic_map, fromNext, toPrev, AddMonoidHom.mk'_apply]
  simp only [preadditive.add_comp, category.assoc, g.comm]
#align homotopy.null_homotopic_map_comp Homotopy.nullHomotopicMap_comp
-/

#print Homotopy.nullHomotopicMap'_comp /-
/-- Compatibility of `null_homotopic_map'` with the postcomposition by a morphism
of complexes. -/
theorem nullHomotopicMap'_comp (hom : ∀ i j, c.Rel j i → (C.pt i ⟶ D.pt j)) (g : D ⟶ E) :
    nullHomotopicMap' hom ≫ g = nullHomotopicMap' fun i j hij => hom i j hij ≫ g.f j :=
  by
  ext n
  erw [null_homotopic_map_comp]
  congr
  ext i j
  split_ifs
  · rfl
  · rw [zero_comp]
#align homotopy.null_homotopic_map'_comp Homotopy.nullHomotopicMap'_comp
-/

#print Homotopy.comp_nullHomotopicMap /-
/-- Compatibility of `null_homotopic_map` with the precomposition by a morphism
of complexes. -/
theorem comp_nullHomotopicMap (f : C ⟶ D) (hom : ∀ i j, D.pt i ⟶ E.pt j) :
    f ≫ nullHomotopicMap hom = nullHomotopicMap fun i j => f.f i ≫ hom i j :=
  by
  ext n
  dsimp [null_homotopic_map, fromNext, toPrev, AddMonoidHom.mk'_apply]
  simp only [preadditive.comp_add, category.assoc, f.comm_assoc]
#align homotopy.comp_null_homotopic_map Homotopy.comp_nullHomotopicMap
-/

#print Homotopy.comp_nullHomotopicMap' /-
/-- Compatibility of `null_homotopic_map'` with the precomposition by a morphism
of complexes. -/
theorem comp_nullHomotopicMap' (f : C ⟶ D) (hom : ∀ i j, c.Rel j i → (D.pt i ⟶ E.pt j)) :
    f ≫ nullHomotopicMap' hom = nullHomotopicMap' fun i j hij => f.f i ≫ hom i j hij :=
  by
  ext n
  erw [comp_null_homotopic_map]
  congr
  ext i j
  split_ifs
  · rfl
  · rw [comp_zero]
#align homotopy.comp_null_homotopic_map' Homotopy.comp_nullHomotopicMap'
-/

#print Homotopy.map_nullHomotopicMap /-
/-- Compatibility of `null_homotopic_map` with the application of additive functors -/
theorem map_nullHomotopicMap {W : Type _} [Category W] [Preadditive W] (G : V ⥤ W) [G.Additive]
    (hom : ∀ i j, C.pt i ⟶ D.pt j) :
    (G.mapHomologicalComplex c).map (nullHomotopicMap hom) =
      nullHomotopicMap fun i j => G.map (hom i j) :=
  by
  ext i
  dsimp [null_homotopic_map, dNext, prevD]
  simp only [G.map_comp, functor.map_add]
#align homotopy.map_null_homotopic_map Homotopy.map_nullHomotopicMap
-/

#print Homotopy.map_nullHomotopicMap' /-
/-- Compatibility of `null_homotopic_map'` with the application of additive functors -/
theorem map_nullHomotopicMap' {W : Type _} [Category W] [Preadditive W] (G : V ⥤ W) [G.Additive]
    (hom : ∀ i j, c.Rel j i → (C.pt i ⟶ D.pt j)) :
    (G.mapHomologicalComplex c).map (nullHomotopicMap' hom) =
      nullHomotopicMap' fun i j hij => G.map (hom i j hij) :=
  by
  ext n
  erw [map_null_homotopic_map]
  congr
  ext i j
  split_ifs
  · rfl
  · rw [G.map_zero]
#align homotopy.map_null_homotopic_map' Homotopy.map_nullHomotopicMap'
-/

#print Homotopy.nullHomotopy /-
/-- Tautological construction of the `homotopy` to zero for maps constructed by
`null_homotopic_map`, at least when we have the `zero'` condition. -/
@[simps]
def nullHomotopy (hom : ∀ i j, C.pt i ⟶ D.pt j) (zero' : ∀ i j, ¬c.Rel j i → hom i j = 0) :
    Homotopy (nullHomotopicMap hom) 0 :=
  { Hom
    zero'
    comm := by intro i; rw [HomologicalComplex.zero_f_apply, add_zero]; rfl }
#align homotopy.null_homotopy Homotopy.nullHomotopy
-/

#print Homotopy.nullHomotopy' /-
/-- Homotopy to zero for maps constructed with `null_homotopic_map'` -/
@[simps]
def nullHomotopy' (h : ∀ i j, c.Rel j i → (C.pt i ⟶ D.pt j)) : Homotopy (nullHomotopicMap' h) 0 :=
  by
  apply null_homotopy fun i j => dite (c.rel j i) (h i j) fun _ => 0
  intro i j hij
  dsimp
  rw [dite_eq_right_iff]
  intro hij'
  exfalso
  exact hij hij'
#align homotopy.null_homotopy' Homotopy.nullHomotopy'
-/

/-! This lemma and the following ones can be used in order to compute
the degreewise morphisms induced by the null homotopic maps constructed
with `null_homotopic_map` or `null_homotopic_map'` -/


#print Homotopy.nullHomotopicMap_f /-
@[simp]
theorem nullHomotopicMap_f {k₂ k₁ k₀ : ι} (r₂₁ : c.Rel k₂ k₁) (r₁₀ : c.Rel k₁ k₀)
    (hom : ∀ i j, C.pt i ⟶ D.pt j) :
    (nullHomotopicMap hom).f k₁ = C.d k₁ k₀ ≫ hom k₀ k₁ + hom k₁ k₂ ≫ D.d k₂ k₁ := by
  dsimp only [null_homotopic_map]; rw [dNext_eq hom r₁₀, prevD_eq hom r₂₁]
#align homotopy.null_homotopic_map_f Homotopy.nullHomotopicMap_f
-/

#print Homotopy.nullHomotopicMap'_f /-
@[simp]
theorem nullHomotopicMap'_f {k₂ k₁ k₀ : ι} (r₂₁ : c.Rel k₂ k₁) (r₁₀ : c.Rel k₁ k₀)
    (h : ∀ i j, c.Rel j i → (C.pt i ⟶ D.pt j)) :
    (nullHomotopicMap' h).f k₁ = C.d k₁ k₀ ≫ h k₀ k₁ r₁₀ + h k₁ k₂ r₂₁ ≫ D.d k₂ k₁ :=
  by
  simp only [← null_homotopic_map']
  rw [null_homotopic_map_f r₂₁ r₁₀ fun i j => dite (c.rel j i) (h i j) fun _ => 0]
  dsimp
  split_ifs
  rfl
#align homotopy.null_homotopic_map'_f Homotopy.nullHomotopicMap'_f
-/

#print Homotopy.nullHomotopicMap_f_of_not_rel_left /-
@[simp]
theorem nullHomotopicMap_f_of_not_rel_left {k₁ k₀ : ι} (r₁₀ : c.Rel k₁ k₀)
    (hk₀ : ∀ l : ι, ¬c.Rel k₀ l) (hom : ∀ i j, C.pt i ⟶ D.pt j) :
    (nullHomotopicMap hom).f k₀ = hom k₀ k₁ ≫ D.d k₁ k₀ :=
  by
  dsimp only [null_homotopic_map]
  rw [prevD_eq hom r₁₀, dNext, AddMonoidHom.mk'_apply, C.shape, zero_comp, zero_add]
  exact hk₀ _
#align homotopy.null_homotopic_map_f_of_not_rel_left Homotopy.nullHomotopicMap_f_of_not_rel_left
-/

#print Homotopy.nullHomotopicMap'_f_of_not_rel_left /-
@[simp]
theorem nullHomotopicMap'_f_of_not_rel_left {k₁ k₀ : ι} (r₁₀ : c.Rel k₁ k₀)
    (hk₀ : ∀ l : ι, ¬c.Rel k₀ l) (h : ∀ i j, c.Rel j i → (C.pt i ⟶ D.pt j)) :
    (nullHomotopicMap' h).f k₀ = h k₀ k₁ r₁₀ ≫ D.d k₁ k₀ :=
  by
  simp only [← null_homotopic_map']
  rw [null_homotopic_map_f_of_not_rel_left r₁₀ hk₀ fun i j => dite (c.rel j i) (h i j) fun _ => 0]
  dsimp
  split_ifs
  rfl
#align homotopy.null_homotopic_map'_f_of_not_rel_left Homotopy.nullHomotopicMap'_f_of_not_rel_left
-/

#print Homotopy.nullHomotopicMap_f_of_not_rel_right /-
@[simp]
theorem nullHomotopicMap_f_of_not_rel_right {k₁ k₀ : ι} (r₁₀ : c.Rel k₁ k₀)
    (hk₁ : ∀ l : ι, ¬c.Rel l k₁) (hom : ∀ i j, C.pt i ⟶ D.pt j) :
    (nullHomotopicMap hom).f k₁ = C.d k₁ k₀ ≫ hom k₀ k₁ :=
  by
  dsimp only [null_homotopic_map]
  rw [dNext_eq hom r₁₀, prevD, AddMonoidHom.mk'_apply, D.shape, comp_zero, add_zero]
  exact hk₁ _
#align homotopy.null_homotopic_map_f_of_not_rel_right Homotopy.nullHomotopicMap_f_of_not_rel_right
-/

#print Homotopy.nullHomotopicMap'_f_of_not_rel_right /-
@[simp]
theorem nullHomotopicMap'_f_of_not_rel_right {k₁ k₀ : ι} (r₁₀ : c.Rel k₁ k₀)
    (hk₁ : ∀ l : ι, ¬c.Rel l k₁) (h : ∀ i j, c.Rel j i → (C.pt i ⟶ D.pt j)) :
    (nullHomotopicMap' h).f k₁ = C.d k₁ k₀ ≫ h k₀ k₁ r₁₀ :=
  by
  simp only [← null_homotopic_map']
  rw [null_homotopic_map_f_of_not_rel_right r₁₀ hk₁ fun i j => dite (c.rel j i) (h i j) fun _ => 0]
  dsimp
  split_ifs
  rfl
#align homotopy.null_homotopic_map'_f_of_not_rel_right Homotopy.nullHomotopicMap'_f_of_not_rel_right
-/

#print Homotopy.nullHomotopicMap_f_eq_zero /-
@[simp]
theorem nullHomotopicMap_f_eq_zero {k₀ : ι} (hk₀ : ∀ l : ι, ¬c.Rel k₀ l)
    (hk₀' : ∀ l : ι, ¬c.Rel l k₀) (hom : ∀ i j, C.pt i ⟶ D.pt j) :
    (nullHomotopicMap hom).f k₀ = 0 :=
  by
  dsimp [null_homotopic_map, dNext, prevD]
  rw [C.shape, D.shape, zero_comp, comp_zero, add_zero] <;> apply_assumption
#align homotopy.null_homotopic_map_f_eq_zero Homotopy.nullHomotopicMap_f_eq_zero
-/

#print Homotopy.nullHomotopicMap'_f_eq_zero /-
@[simp]
theorem nullHomotopicMap'_f_eq_zero {k₀ : ι} (hk₀ : ∀ l : ι, ¬c.Rel k₀ l)
    (hk₀' : ∀ l : ι, ¬c.Rel l k₀) (h : ∀ i j, c.Rel j i → (C.pt i ⟶ D.pt j)) :
    (nullHomotopicMap' h).f k₀ = 0 :=
  by
  simp only [← null_homotopic_map']
  exact null_homotopic_map_f_eq_zero hk₀ hk₀' fun i j => dite (c.rel j i) (h i j) fun _ => 0
#align homotopy.null_homotopic_map'_f_eq_zero Homotopy.nullHomotopicMap'_f_eq_zero
-/

/-!
`homotopy.mk_inductive` allows us to build a homotopy of chain complexes inductively,
so that as we construct each component, we have available the previous two components,
and the fact that they satisfy the homotopy condition.

To simplify the situation, we only construct homotopies of the form `homotopy e 0`.
`homotopy.equiv_sub_zero` can provide the general case.

Notice however, that this construction does not have particularly good definitional properties:
we have to insert `eq_to_hom` in several places.
Hopefully this is okay in most applications, where we only need to have the existence of some
homotopy.
-/


section MkInductive

variable {P Q : ChainComplex V ℕ}

#print Homotopy.prevD_chainComplex /-
@[simp]
theorem prevD_chainComplex (f : ∀ i j, P.pt i ⟶ Q.pt j) (j : ℕ) :
    prevD j f = f j (j + 1) ≫ Q.d _ _ := by
  dsimp [prevD]
  have : (ComplexShape.down ℕ).prev j = j + 1 := ChainComplex.prev ℕ j
  congr 2
#align homotopy.prev_d_chain_complex Homotopy.prevD_chainComplex
-/

#print Homotopy.dNext_succ_chainComplex /-
@[simp]
theorem dNext_succ_chainComplex (f : ∀ i j, P.pt i ⟶ Q.pt j) (i : ℕ) :
    dNext (i + 1) f = P.d _ _ ≫ f i (i + 1) :=
  by
  dsimp [dNext]
  have : (ComplexShape.down ℕ).next (i + 1) = i := ChainComplex.next_nat_succ _
  congr 2
#align homotopy.d_next_succ_chain_complex Homotopy.dNext_succ_chainComplex
-/

#print Homotopy.dNext_zero_chainComplex /-
@[simp]
theorem dNext_zero_chainComplex (f : ∀ i j, P.pt i ⟶ Q.pt j) : dNext 0 f = 0 :=
  by
  dsimp [dNext]
  rw [P.shape, zero_comp]
  rw [ChainComplex.next_nat_zero]; dsimp; decide
#align homotopy.d_next_zero_chain_complex Homotopy.dNext_zero_chainComplex
-/

variable (e : P ⟶ Q) (zero : P.pt 0 ⟶ Q.pt 1) (comm_zero : e.f 0 = zero ≫ Q.d 1 0)
  (one : P.pt 1 ⟶ Q.pt 2) (comm_one : e.f 1 = P.d 1 0 ≫ zero + one ≫ Q.d 2 1)
  (succ :
    ∀ (n : ℕ)
      (p :
        Σ' (f : P.pt n ⟶ Q.pt (n + 1)) (f' : P.pt (n + 1) ⟶ Q.pt (n + 2)),
          e.f (n + 1) = P.d (n + 1) n ≫ f + f' ≫ Q.d (n + 2) (n + 1)),
      Σ' f'' : P.pt (n + 2) ⟶ Q.pt (n + 3),
        e.f (n + 2) = P.d (n + 2) (n + 1) ≫ p.2.1 + f'' ≫ Q.d (n + 3) (n + 2))

#print Homotopy.mkInductiveAux₁ /-
/-- An auxiliary construction for `mk_inductive`.

Here we build by induction a family of diagrams,
but don't require at the type level that these successive diagrams actually agree.
They do in fact agree, and we then capture that at the type level (i.e. by constructing a homotopy)
in `mk_inductive`.

At this stage, we don't check the homotopy condition in degree 0,
because it "falls off the end", and is easier to treat using `X_next` and `X_prev`,
which we do in `mk_inductive_aux₂`.
-/
@[simp, nolint unused_arguments]
def mkInductiveAux₁ :
    ∀ n,
      Σ' (f : P.pt n ⟶ Q.pt (n + 1)) (f' : P.pt (n + 1) ⟶ Q.pt (n + 2)),
        e.f (n + 1) = P.d (n + 1) n ≫ f + f' ≫ Q.d (n + 2) (n + 1)
  | 0 => ⟨zero, one, comm_one⟩
  | 1 => ⟨one, (succ 0 ⟨zero, one, comm_one⟩).1, (succ 0 ⟨zero, one, comm_one⟩).2⟩
  | n + 2 =>
    ⟨(mk_inductive_aux₁ (n + 1)).2.1, (succ (n + 1) (mk_inductive_aux₁ (n + 1))).1,
      (succ (n + 1) (mk_inductive_aux₁ (n + 1))).2⟩
#align homotopy.mk_inductive_aux₁ Homotopy.mkInductiveAux₁
-/

section

#print Homotopy.mkInductiveAux₂ /-
/-- An auxiliary construction for `mk_inductive`.
-/
@[simp]
def mkInductiveAux₂ :
    ∀ n, Σ' (f : P.xNext n ⟶ Q.pt n) (f' : P.pt n ⟶ Q.xPrev n), e.f n = P.dFrom n ≫ f + f' ≫ Q.dTo n
  | 0 => ⟨0, zero ≫ (Q.xPrevIso rfl).inv, by simpa using comm_zero⟩
  | n + 1 =>
    let I := mkInductiveAux₁ e zero comm_zero one comm_one succ n
    ⟨(P.xNextIso rfl).Hom ≫ I.1, I.2.1 ≫ (Q.xPrevIso rfl).inv, by simpa using I.2.2⟩
#align homotopy.mk_inductive_aux₂ Homotopy.mkInductiveAux₂
-/

#print Homotopy.mkInductiveAux₃ /-
theorem mkInductiveAux₃ (i j : ℕ) (h : i + 1 = j) :
    (mkInductiveAux₂ e zero comm_zero one comm_one succ i).2.1 ≫ (Q.xPrevIso h).Hom =
      (P.xNextIso h).inv ≫ (mkInductiveAux₂ e zero comm_zero one comm_one succ j).1 :=
  by subst j <;> rcases i with (_ | _ | i) <;> · dsimp; simp
#align homotopy.mk_inductive_aux₃ Homotopy.mkInductiveAux₃
-/

#print Homotopy.mkInductive /-
/-- A constructor for a `homotopy e 0`, for `e` a chain map between `ℕ`-indexed chain complexes,
working by induction.

You need to provide the components of the homotopy in degrees 0 and 1,
show that these satisfy the homotopy condition,
and then give a construction of each component,
and the fact that it satisfies the homotopy condition,
using as an inductive hypothesis the data and homotopy condition for the previous two components.
-/
def mkInductive : Homotopy e 0
    where
  Hom i j :=
    if h : i + 1 = j then
      (mkInductiveAux₂ e zero comm_zero one comm_one succ i).2.1 ≫ (Q.xPrevIso h).Hom
    else 0
  zero' i j w := by rwa [dif_neg]
  comm i := by
    dsimp; simp only [add_zero]
    convert (mk_inductive_aux₂ e zero comm_zero one comm_one succ i).2.2
    · cases i
      · dsimp [fromNext]; rw [dif_neg]
        simp only [ChainComplex.next_nat_zero, Nat.one_ne_zero, not_false_iff]
      · dsimp [fromNext]; rw [dif_pos]; swap; · simp only [ChainComplex.next_nat_succ]
        have aux : (ComplexShape.down ℕ).next i.succ = i := ChainComplex.next_nat_succ i
        rw [mk_inductive_aux₃ e zero comm_zero one comm_one succ ((ComplexShape.down ℕ).next i.succ)
            (i + 1) (by rw [aux])]
        dsimp [X_next_iso]; erw [category.id_comp]
    · dsimp [toPrev]; rw [dif_pos]; swap; · simp only [ChainComplex.prev]
      dsimp [X_prev_iso]; erw [category.comp_id]
#align homotopy.mk_inductive Homotopy.mkInductive
-/

end

end MkInductive

/-!
`homotopy.mk_coinductive` allows us to build a homotopy of cochain complexes inductively,
so that as we construct each component, we have available the previous two components,
and the fact that they satisfy the homotopy condition.
-/


section MkCoinductive

variable {P Q : CochainComplex V ℕ}

#print Homotopy.dNext_cochainComplex /-
@[simp]
theorem dNext_cochainComplex (f : ∀ i j, P.pt i ⟶ Q.pt j) (j : ℕ) :
    dNext j f = P.d _ _ ≫ f (j + 1) j := by
  dsimp [dNext]
  have : (ComplexShape.up ℕ).next j = j + 1 := CochainComplex.next ℕ j
  congr 2
#align homotopy.d_next_cochain_complex Homotopy.dNext_cochainComplex
-/

#print Homotopy.prevD_succ_cochainComplex /-
@[simp]
theorem prevD_succ_cochainComplex (f : ∀ i j, P.pt i ⟶ Q.pt j) (i : ℕ) :
    prevD (i + 1) f = f (i + 1) _ ≫ Q.d i (i + 1) :=
  by
  dsimp [prevD]
  have : (ComplexShape.up ℕ).prev (i + 1) = i := CochainComplex.prev_nat_succ i
  congr 2
#align homotopy.prev_d_succ_cochain_complex Homotopy.prevD_succ_cochainComplex
-/

#print Homotopy.prevD_zero_cochainComplex /-
@[simp]
theorem prevD_zero_cochainComplex (f : ∀ i j, P.pt i ⟶ Q.pt j) : prevD 0 f = 0 :=
  by
  dsimp [prevD]
  rw [Q.shape, comp_zero]
  rw [CochainComplex.prev_nat_zero]; dsimp; decide
#align homotopy.prev_d_zero_cochain_complex Homotopy.prevD_zero_cochainComplex
-/

variable (e : P ⟶ Q) (zero : P.pt 1 ⟶ Q.pt 0) (comm_zero : e.f 0 = P.d 0 1 ≫ zero)
  (one : P.pt 2 ⟶ Q.pt 1) (comm_one : e.f 1 = zero ≫ Q.d 0 1 + P.d 1 2 ≫ one)
  (succ :
    ∀ (n : ℕ)
      (p :
        Σ' (f : P.pt (n + 1) ⟶ Q.pt n) (f' : P.pt (n + 2) ⟶ Q.pt (n + 1)),
          e.f (n + 1) = f ≫ Q.d n (n + 1) + P.d (n + 1) (n + 2) ≫ f'),
      Σ' f'' : P.pt (n + 3) ⟶ Q.pt (n + 2),
        e.f (n + 2) = p.2.1 ≫ Q.d (n + 1) (n + 2) + P.d (n + 2) (n + 3) ≫ f'')

#print Homotopy.mkCoinductiveAux₁ /-
/-- An auxiliary construction for `mk_coinductive`.

Here we build by induction a family of diagrams,
but don't require at the type level that these successive diagrams actually agree.
They do in fact agree, and we then capture that at the type level (i.e. by constructing a homotopy)
in `mk_coinductive`.

At this stage, we don't check the homotopy condition in degree 0,
because it "falls off the end", and is easier to treat using `X_next` and `X_prev`,
which we do in `mk_inductive_aux₂`.
-/
@[simp, nolint unused_arguments]
def mkCoinductiveAux₁ :
    ∀ n,
      Σ' (f : P.pt (n + 1) ⟶ Q.pt n) (f' : P.pt (n + 2) ⟶ Q.pt (n + 1)),
        e.f (n + 1) = f ≫ Q.d n (n + 1) + P.d (n + 1) (n + 2) ≫ f'
  | 0 => ⟨zero, one, comm_one⟩
  | 1 => ⟨one, (succ 0 ⟨zero, one, comm_one⟩).1, (succ 0 ⟨zero, one, comm_one⟩).2⟩
  | n + 2 =>
    ⟨(mk_coinductive_aux₁ (n + 1)).2.1, (succ (n + 1) (mk_coinductive_aux₁ (n + 1))).1,
      (succ (n + 1) (mk_coinductive_aux₁ (n + 1))).2⟩
#align homotopy.mk_coinductive_aux₁ Homotopy.mkCoinductiveAux₁
-/

section

#print Homotopy.mkCoinductiveAux₂ /-
/-- An auxiliary construction for `mk_inductive`.
-/
@[simp]
def mkCoinductiveAux₂ :
    ∀ n, Σ' (f : P.pt n ⟶ Q.xPrev n) (f' : P.xNext n ⟶ Q.pt n), e.f n = f ≫ Q.dTo n + P.dFrom n ≫ f'
  | 0 => ⟨0, (P.xNextIso rfl).Hom ≫ zero, by simpa using comm_zero⟩
  | n + 1 =>
    let I := mkCoinductiveAux₁ e zero comm_zero one comm_one succ n
    ⟨I.1 ≫ (Q.xPrevIso rfl).inv, (P.xNextIso rfl).Hom ≫ I.2.1, by simpa using I.2.2⟩
#align homotopy.mk_coinductive_aux₂ Homotopy.mkCoinductiveAux₂
-/

#print Homotopy.mkCoinductiveAux₃ /-
theorem mkCoinductiveAux₃ (i j : ℕ) (h : i + 1 = j) :
    (P.xNextIso h).inv ≫ (mkCoinductiveAux₂ e zero comm_zero one comm_one succ i).2.1 =
      (mkCoinductiveAux₂ e zero comm_zero one comm_one succ j).1 ≫ (Q.xPrevIso h).Hom :=
  by subst j <;> rcases i with (_ | _ | i) <;> · dsimp; simp
#align homotopy.mk_coinductive_aux₃ Homotopy.mkCoinductiveAux₃
-/

#print Homotopy.mkCoinductive /-
/-- A constructor for a `homotopy e 0`, for `e` a chain map between `ℕ`-indexed cochain complexes,
working by induction.

You need to provide the components of the homotopy in degrees 0 and 1,
show that these satisfy the homotopy condition,
and then give a construction of each component,
and the fact that it satisfies the homotopy condition,
using as an inductive hypothesis the data and homotopy condition for the previous two components.
-/
def mkCoinductive : Homotopy e 0
    where
  Hom i j :=
    if h : j + 1 = i then
      (P.xNextIso h).inv ≫ (mkCoinductiveAux₂ e zero comm_zero one comm_one succ j).2.1
    else 0
  zero' i j w := by rwa [dif_neg]
  comm i := by
    dsimp
    rw [add_zero, add_comm]
    convert (mk_coinductive_aux₂ e zero comm_zero one comm_one succ i).2.2 using 2
    · cases i
      · dsimp [toPrev]; rw [dif_neg]
        simp only [CochainComplex.prev_nat_zero, Nat.one_ne_zero, not_false_iff]
      · dsimp [toPrev]; rw [dif_pos]; swap; · simp only [CochainComplex.prev_nat_succ]
        have aux : (ComplexShape.up ℕ).prev i.succ = i := CochainComplex.prev_nat_succ i
        rw [mk_coinductive_aux₃ e zero comm_zero one comm_one succ ((ComplexShape.up ℕ).prev i.succ)
            (i + 1) (by rw [aux])]
        dsimp [X_prev_iso]; erw [category.comp_id]
    · dsimp [fromNext]; rw [dif_pos]; swap; · simp only [CochainComplex.next]
      dsimp [X_next_iso]; erw [category.id_comp]
#align homotopy.mk_coinductive Homotopy.mkCoinductive
-/

end

end MkCoinductive

end Homotopy

#print HomotopyEquiv /-
/-- A homotopy equivalence between two chain complexes consists of a chain map each way,
and homotopies from the compositions to the identity chain maps.

Note that this contains data;
arguably it might be more useful for many applications if we truncated it to a Prop.
-/
structure HomotopyEquiv (C D : HomologicalComplex V c) where
  Hom : C ⟶ D
  inv : D ⟶ C
  homotopyHomInvId : Homotopy (hom ≫ inv) (𝟙 C)
  homotopyInvHomId : Homotopy (inv ≫ hom) (𝟙 D)
#align homotopy_equiv HomotopyEquiv
-/

namespace HomotopyEquiv

#print HomotopyEquiv.refl /-
/-- Any complex is homotopy equivalent to itself. -/
@[refl]
def refl (C : HomologicalComplex V c) : HomotopyEquiv C C
    where
  Hom := 𝟙 C
  inv := 𝟙 C
  homotopyHomInvId := by simp
  homotopyInvHomId := by simp
#align homotopy_equiv.refl HomotopyEquiv.refl
-/

instance : Inhabited (HomotopyEquiv C C) :=
  ⟨refl C⟩

#print HomotopyEquiv.symm /-
/-- Being homotopy equivalent is a symmetric relation. -/
@[symm]
def symm {C D : HomologicalComplex V c} (f : HomotopyEquiv C D) : HomotopyEquiv D C
    where
  Hom := f.inv
  inv := f.Hom
  homotopyHomInvId := f.homotopyInvHomId
  homotopyInvHomId := f.homotopyHomInvId
#align homotopy_equiv.symm HomotopyEquiv.symm
-/

#print HomotopyEquiv.trans /-
/-- Homotopy equivalence is a transitive relation. -/
@[trans]
def trans {C D E : HomologicalComplex V c} (f : HomotopyEquiv C D) (g : HomotopyEquiv D E) :
    HomotopyEquiv C E where
  Hom := f.Hom ≫ g.Hom
  inv := g.inv ≫ f.inv
  homotopyHomInvId := by
    simpa using
      ((g.homotopy_hom_inv_id.comp_right_id f.inv).compLeft f.hom).trans f.homotopy_hom_inv_id
  homotopyInvHomId := by
    simpa using
      ((f.homotopy_inv_hom_id.comp_right_id g.hom).compLeft g.inv).trans g.homotopy_inv_hom_id
#align homotopy_equiv.trans HomotopyEquiv.trans
-/

#print HomotopyEquiv.ofIso /-
/-- An isomorphism of complexes induces a homotopy equivalence. -/
def ofIso {ι : Type _} {V : Type u} [Category.{v} V] [Preadditive V] {c : ComplexShape ι}
    {C D : HomologicalComplex V c} (f : C ≅ D) : HomotopyEquiv C D :=
  ⟨f.Hom, f.inv, Homotopy.ofEq f.3, Homotopy.ofEq f.4⟩
#align homotopy_equiv.of_iso HomotopyEquiv.ofIso
-/

end HomotopyEquiv

variable [HasEqualizers V] [HasCokernels V] [HasImages V] [HasImageMaps V]

#print homology_map_eq_of_homotopy /-
/-- Homotopic maps induce the same map on homology.
-/
theorem homology_map_eq_of_homotopy (h : Homotopy f g) (i : ι) :
    (homologyFunctor V c i).map f = (homologyFunctor V c i).map g :=
  by
  dsimp [homologyFunctor]
  apply eq_of_sub_eq_zero
  ext
  simp only [homology.π_map, comp_zero, preadditive.comp_sub]
  dsimp [kernel_subobject_map]
  simp_rw [h.comm i]
  simp only [zero_add, zero_comp, dNext_eq_dFrom_fromNext, kernel_subobject_arrow_comp_assoc,
    preadditive.comp_add]
  rw [← preadditive.sub_comp]
  simp only [CategoryTheory.Subobject.factorThru_add_sub_factorThru_right]
  erw [subobject.factor_thru_of_le (D.boundaries_le_cycles i)]
  · simp
  · rw [prevD_eq_toPrev_dTo, ← category.assoc]
    apply image_subobject_factors_comp_self
#align homology_map_eq_of_homotopy homology_map_eq_of_homotopy
-/

#print homologyObjIsoOfHomotopyEquiv /-
/-- Homotopy equivalent complexes have isomorphic homologies. -/
def homologyObjIsoOfHomotopyEquiv (f : HomotopyEquiv C D) (i : ι) :
    (homologyFunctor V c i).obj C ≅ (homologyFunctor V c i).obj D
    where
  Hom := (homologyFunctor V c i).map f.Hom
  inv := (homologyFunctor V c i).map f.inv
  hom_inv_id' := by
    rw [← functor.map_comp, homology_map_eq_of_homotopy f.homotopy_hom_inv_id,
      CategoryTheory.Functor.map_id]
  inv_hom_id' := by
    rw [← functor.map_comp, homology_map_eq_of_homotopy f.homotopy_inv_hom_id,
      CategoryTheory.Functor.map_id]
#align homology_obj_iso_of_homotopy_equiv homologyObjIsoOfHomotopyEquiv
-/

end

namespace CategoryTheory

variable {W : Type _} [Category W] [Preadditive W]

#print CategoryTheory.Functor.mapHomotopy /-
/-- An additive functor takes homotopies to homotopies. -/
@[simps]
def Functor.mapHomotopy (F : V ⥤ W) [F.Additive] {f g : C ⟶ D} (h : Homotopy f g) :
    Homotopy ((F.mapHomologicalComplex c).map f) ((F.mapHomologicalComplex c).map g)
    where
  Hom i j := F.map (h.Hom i j)
  zero' i j w := by rw [h.zero i j w, F.map_zero]
  comm i := by
    dsimp [dNext, prevD] at *
    rw [h.comm i]
    simp only [F.map_add, ← F.map_comp]
    rfl
#align category_theory.functor.map_homotopy CategoryTheory.Functor.mapHomotopy
-/

#print CategoryTheory.Functor.mapHomotopyEquiv /-
/-- An additive functor preserves homotopy equivalences. -/
@[simps]
def Functor.mapHomotopyEquiv (F : V ⥤ W) [F.Additive] (h : HomotopyEquiv C D) :
    HomotopyEquiv ((F.mapHomologicalComplex c).obj C) ((F.mapHomologicalComplex c).obj D)
    where
  Hom := (F.mapHomologicalComplex c).map h.Hom
  inv := (F.mapHomologicalComplex c).map h.inv
  homotopyHomInvId :=
    by
    rw [← (F.map_homological_complex c).map_comp, ← (F.map_homological_complex c).map_id]
    exact F.map_homotopy h.homotopy_hom_inv_id
  homotopyInvHomId :=
    by
    rw [← (F.map_homological_complex c).map_comp, ← (F.map_homological_complex c).map_id]
    exact F.map_homotopy h.homotopy_inv_hom_id
#align category_theory.functor.map_homotopy_equiv CategoryTheory.Functor.mapHomotopyEquiv
-/

end CategoryTheory

