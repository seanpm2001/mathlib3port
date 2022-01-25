import Mathbin.Algebra.Algebra.Basic

/-!
# Subfields

Let `K` be a field. This file defines the "bundled" subfield type `subfield K`, a type
whose terms correspond to subfields of `K`. This is the preferred way to talk
about subfields in mathlib. Unbundled subfields (`s : set K` and `is_subfield s`)
are not in this file, and they will ultimately be deprecated.

We prove that subfields are a complete lattice, and that you can `map` (pushforward) and
`comap` (pull back) them along ring homomorphisms.

We define the `closure` construction from `set R` to `subfield R`, sending a subset of `R`
to the subfield it generates, and prove that it is a Galois insertion.

## Main definitions

Notation used here:

`(K : Type u) [field K] (L : Type u) [field L] (f g : K →+* L)`
`(A : subfield K) (B : subfield L) (s : set K)`

* `subfield R` : the type of subfields of a ring `R`.

* `instance : complete_lattice (subfield R)` : the complete lattice structure on the subfields.

* `subfield.closure` : subfield closure of a set, i.e., the smallest subfield that includes the set.

* `subfield.gi` : `closure : set M → subfield M` and coercion `coe : subfield M → set M`
  form a `galois_insertion`.

* `comap f B : subfield K` : the preimage of a subfield `B` along the ring homomorphism `f`

* `map f A : subfield L` : the image of a subfield `A` along the ring homomorphism `f`.

* `prod A B : subfield (K × L)` : the product of subfields

* `f.field_range : subfield B` : the range of the ring homomorphism `f`.

* `eq_locus_field f g : subfield K` : given ring homomorphisms `f g : K →+* R`,
     the subfield of `K` where `f x = g x`

## Implementation notes

A subfield is implemented as a subring which is is closed under `⁻¹`.

Lattice inclusion (e.g. `≤` and `⊓`) is used rather than set notation (`⊆` and `∩`), although
`∈` is defined as membership of a subfield's underlying set.

## Tags
subfield, subfields
-/


open_locale BigOperators

universe u v w

variable {K : Type u} {L : Type v} {M : Type w} [Field K] [Field L] [Field M]

/-- `subfield R` is the type of subfields of `R`. A subfield of `R` is a subset `s` that is a
  multiplicative submonoid and an additive subgroup. Note in particular that it shares the
  same 0 and 1 as R. -/
structure Subfield (K : Type u) [Field K] extends Subring K where
  inv_mem' : ∀, ∀ x ∈ carrier, ∀, x⁻¹ ∈ carrier

/-- Reinterpret a `subfield` as a `subring`. -/
add_decl_doc Subfield.toSubring

namespace Subfield

/-- The underlying `add_subgroup` of a subfield. -/
def to_add_subgroup (s : Subfield K) : AddSubgroup K :=
  { s.to_subring.to_add_subgroup with }

/-- The underlying submonoid of a subfield. -/
def to_submonoid (s : Subfield K) : Submonoid K :=
  { s.to_subring.to_submonoid with }

instance : SetLike (Subfield K) K :=
  ⟨Subfield.Carrier, fun p q h => by
    cases p <;> cases q <;> congr⟩

@[simp]
theorem mem_carrier {s : Subfield K} {x : K} : x ∈ s.carrier ↔ x ∈ s :=
  Iff.rfl

@[simp]
theorem mem_mk {S : Set K} {x : K} h₁ h₂ h₃ h₄ h₅ h₆ : x ∈ (⟨S, h₁, h₂, h₃, h₄, h₅, h₆⟩ : Subfield K) ↔ x ∈ S :=
  Iff.rfl

@[simp]
theorem coe_set_mk (S : Set K) h₁ h₂ h₃ h₄ h₅ h₆ : ((⟨S, h₁, h₂, h₃, h₄, h₅, h₆⟩ : Subfield K) : Set K) = S :=
  rfl

@[simp]
theorem mk_le_mk {S S' : Set K} h₁ h₂ h₃ h₄ h₅ h₆ h₁' h₂' h₃' h₄' h₅' h₆' :
    (⟨S, h₁, h₂, h₃, h₄, h₅, h₆⟩ : Subfield K) ≤ (⟨S', h₁', h₂', h₃', h₄', h₅', h₆'⟩ : Subfield K) ↔ S ⊆ S' :=
  Iff.rfl

/-- Two subfields are equal if they have the same elements. -/
@[ext]
theorem ext {S T : Subfield K} (h : ∀ x, x ∈ S ↔ x ∈ T) : S = T :=
  SetLike.ext h

/-- Copy of a subfield with a new `carrier` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (S : Subfield K) (s : Set K) (hs : s = ↑S) : Subfield K :=
  { S.to_subring.copy s hs with Carrier := s, inv_mem' := hs.symm ▸ S.inv_mem' }

@[simp]
theorem coe_copy (S : Subfield K) (s : Set K) (hs : s = ↑S) : (S.copy s hs : Set K) = s :=
  rfl

theorem copy_eq (S : Subfield K) (s : Set K) (hs : s = ↑S) : S.copy s hs = S :=
  SetLike.coe_injective hs

@[simp]
theorem coe_to_subring (s : Subfield K) : (s.to_subring : Set K) = s :=
  rfl

@[simp]
theorem mem_to_subring (s : Subfield K) (x : K) : x ∈ s.to_subring ↔ x ∈ s :=
  Iff.rfl

end Subfield

/-- A `subring` containing inverses is a `subfield`. -/
def Subring.toSubfield (s : Subring K) (hinv : ∀, ∀ x ∈ s, ∀, x⁻¹ ∈ s) : Subfield K :=
  { s with inv_mem' := hinv }

namespace Subfield

variable (s t : Subfield K)

/-- A subfield contains the ring's 1. -/
theorem one_mem : (1 : K) ∈ s :=
  s.one_mem'

/-- A subfield contains the ring's 0. -/
theorem zero_mem : (0 : K) ∈ s :=
  s.zero_mem'

/-- A subfield is closed under multiplication. -/
theorem mul_mem : ∀ {x y : K}, x ∈ s → y ∈ s → x * y ∈ s :=
  s.mul_mem'

/-- A subfield is closed under addition. -/
theorem add_mem : ∀ {x y : K}, x ∈ s → y ∈ s → x + y ∈ s :=
  s.add_mem'

/-- A subfield is closed under negation. -/
theorem neg_mem : ∀ {x : K}, x ∈ s → -x ∈ s :=
  s.neg_mem'

/-- A subfield is closed under subtraction. -/
theorem sub_mem {x y : K} : x ∈ s → y ∈ s → x - y ∈ s :=
  s.to_subring.sub_mem

/-- A subfield is closed under inverses. -/
theorem inv_mem : ∀ {x : K}, x ∈ s → x⁻¹ ∈ s :=
  s.inv_mem'

/-- A subfield is closed under division. -/
theorem div_mem {x y : K} (hx : x ∈ s) (hy : y ∈ s) : x / y ∈ s := by
  rw [div_eq_mul_inv]
  exact s.mul_mem hx (s.inv_mem hy)

/-- Product of a list of elements in a subfield is in the subfield. -/
theorem list_prod_mem {l : List K} : (∀, ∀ x ∈ l, ∀, x ∈ s) → l.prod ∈ s :=
  s.to_submonoid.list_prod_mem

/-- Sum of a list of elements in a subfield is in the subfield. -/
theorem list_sum_mem {l : List K} : (∀, ∀ x ∈ l, ∀, x ∈ s) → l.sum ∈ s :=
  s.to_add_subgroup.list_sum_mem

/-- Product of a multiset of elements in a subfield is in the subfield. -/
theorem multiset_prod_mem (m : Multiset K) : (∀, ∀ a ∈ m, ∀, a ∈ s) → m.prod ∈ s :=
  s.to_submonoid.multiset_prod_mem m

/-- Sum of a multiset of elements in a `subfield` is in the `subfield`. -/
theorem multiset_sum_mem (m : Multiset K) : (∀, ∀ a ∈ m, ∀, a ∈ s) → m.sum ∈ s :=
  s.to_add_subgroup.multiset_sum_mem m

/-- Product of elements of a subfield indexed by a `finset` is in the subfield. -/
theorem prod_mem {ι : Type _} {t : Finset ι} {f : ι → K} (h : ∀, ∀ c ∈ t, ∀, f c ∈ s) : (∏ i in t, f i) ∈ s :=
  s.to_submonoid.prod_mem h

/-- Sum of elements in a `subfield` indexed by a `finset` is in the `subfield`. -/
theorem sum_mem {ι : Type _} {t : Finset ι} {f : ι → K} (h : ∀, ∀ c ∈ t, ∀, f c ∈ s) : (∑ i in t, f i) ∈ s :=
  s.to_add_subgroup.sum_mem h

theorem pow_mem {x : K} (hx : x ∈ s) (n : ℕ) : x ^ n ∈ s :=
  s.to_submonoid.pow_mem hx n

theorem zsmul_mem {x : K} (hx : x ∈ s) (n : ℤ) : n • x ∈ s :=
  s.to_add_subgroup.zsmul_mem hx n

theorem coe_int_mem (n : ℤ) : (n : K) ∈ s := by
  simp only [← zsmul_one, zsmul_mem, one_mem]

instance : Ringₓ s :=
  s.to_subring.to_ring

instance : Div s :=
  ⟨fun x y => ⟨x / y, s.div_mem x.2 y.2⟩⟩

instance : HasInv s :=
  ⟨fun x => ⟨x⁻¹, s.inv_mem x.2⟩⟩

/-- A subfield inherits a field structure -/
instance to_field : Field s :=
  Subtype.coe_injective.Field coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) fun _ _ => rfl

/-- A subfield of a `linear_ordered_field` is a `linear_ordered_field`. -/
instance to_linear_ordered_field {K} [LinearOrderedField K] (s : Subfield K) : LinearOrderedField s :=
  Subtype.coe_injective.LinearOrderedField coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) fun _ _ => rfl

@[simp, norm_cast]
theorem coe_add (x y : s) : (↑(x + y) : K) = ↑x + ↑y :=
  rfl

@[simp, norm_cast]
theorem coe_sub (x y : s) : (↑(x - y) : K) = ↑x - ↑y :=
  rfl

@[simp, norm_cast]
theorem coe_neg (x : s) : (↑(-x) : K) = -↑x :=
  rfl

@[simp, norm_cast]
theorem coe_mul (x y : s) : (↑(x * y) : K) = ↑x * ↑y :=
  rfl

@[simp, norm_cast]
theorem coe_div (x y : s) : (↑(x / y) : K) = ↑x / ↑y :=
  rfl

@[simp, norm_cast]
theorem coe_inv (x : s) : (↑x⁻¹ : K) = (↑x)⁻¹ :=
  rfl

@[simp, norm_cast]
theorem coe_zero : ((0 : s) : K) = 0 :=
  rfl

@[simp, norm_cast]
theorem coe_one : ((1 : s) : K) = 1 :=
  rfl

/-- The embedding from a subfield of the field `K` to `K`. -/
def Subtype (s : Subfield K) : s →+* K :=
  { s.to_submonoid.subtype, s.to_add_subgroup.subtype with toFun := coe }

instance to_algebra : Algebra s K :=
  RingHom.toAlgebra s.subtype

@[simp]
theorem coeSubtype : ⇑s.subtype = coe :=
  rfl

theorem to_subring.subtype_eq_subtype (F : Type _) [Field F] (S : Subfield F) : S.to_subring.subtype = S.subtype :=
  rfl

/-! # Partial order -/


variable (s t)

@[simp]
theorem mem_to_submonoid {s : Subfield K} {x : K} : x ∈ s.to_submonoid ↔ x ∈ s :=
  Iff.rfl

@[simp]
theorem coe_to_submonoid : (s.to_submonoid : Set K) = s :=
  rfl

@[simp]
theorem mem_to_add_subgroup {s : Subfield K} {x : K} : x ∈ s.to_add_subgroup ↔ x ∈ s :=
  Iff.rfl

@[simp]
theorem coe_to_add_subgroup : (s.to_add_subgroup : Set K) = s :=
  rfl

/-! # top -/


/-- The subfield of `K` containing all elements of `K`. -/
instance : HasTop (Subfield K) :=
  ⟨{ (⊤ : Subring K) with inv_mem' := fun x _ => Subring.mem_top x }⟩

instance : Inhabited (Subfield K) :=
  ⟨⊤⟩

@[simp]
theorem mem_top (x : K) : x ∈ (⊤ : Subfield K) :=
  Set.mem_univ x

@[simp]
theorem coe_top : ((⊤ : Subfield K) : Set K) = Set.Univ :=
  rfl

/-! # comap -/


variable (f : K →+* L)

/-- The preimage of a subfield along a ring homomorphism is a subfield. -/
def comap (s : Subfield L) : Subfield K :=
  { s.to_subring.comap f with
    inv_mem' := fun x hx =>
      show f (x⁻¹) ∈ s by
        rw [f.map_inv]
        exact s.inv_mem hx }

@[simp]
theorem coe_comap (s : Subfield L) : (s.comap f : Set K) = f ⁻¹' s :=
  rfl

@[simp]
theorem mem_comap {s : Subfield L} {f : K →+* L} {x : K} : x ∈ s.comap f ↔ f x ∈ s :=
  Iff.rfl

theorem comap_comap (s : Subfield M) (g : L →+* M) (f : K →+* L) : (s.comap g).comap f = s.comap (g.comp f) :=
  rfl

/-! # map -/


/-- The image of a subfield along a ring homomorphism is a subfield. -/
def map (s : Subfield K) : Subfield L :=
  { s.to_subring.map f with
    inv_mem' := by
      rintro _ ⟨x, hx, rfl⟩
      exact ⟨x⁻¹, s.inv_mem hx, f.map_inv x⟩ }

@[simp]
theorem coe_map : (s.map f : Set L) = f '' s :=
  rfl

@[simp]
theorem mem_map {f : K →+* L} {s : Subfield K} {y : L} : y ∈ s.map f ↔ ∃ x ∈ s, f x = y :=
  Set.mem_image_iff_bex

theorem map_map (g : L →+* M) (f : K →+* L) : (s.map f).map g = s.map (g.comp f) :=
  SetLike.ext' $ Set.image_image _ _ _

theorem map_le_iff_le_comap {f : K →+* L} {s : Subfield K} {t : Subfield L} : s.map f ≤ t ↔ s ≤ t.comap f :=
  Set.image_subset_iff

theorem gc_map_comap (f : K →+* L) : GaloisConnection (map f) (comap f) := fun S T => map_le_iff_le_comap

end Subfield

namespace RingHom

variable (g : L →+* M) (f : K →+* L)

/-! # range -/


/-- The range of a ring homomorphism, as a subfield of the target. See Note [range copy pattern]. -/
def field_range : Subfield L :=
  ((⊤ : Subfield K).map f).copy (Set.Range f) Set.image_univ.symm

@[simp]
theorem coe_field_range : (f.field_range : Set L) = Set.Range f :=
  rfl

@[simp]
theorem mem_field_range {f : K →+* L} {y : L} : y ∈ f.field_range ↔ ∃ x, f x = y :=
  Iff.rfl

theorem field_range_eq_map : f.field_range = Subfield.map f ⊤ := by
  ext
  simp

theorem map_field_range : f.field_range.map g = (g.comp f).fieldRange := by
  simpa only [field_range_eq_map] using (⊤ : Subfield K).map_map g f

/-- The range of a morphism of fields is a fintype, if the domain is a fintype.

Note that this instance can cause a diamond with `subtype.fintype` if `L` is also a fintype.-/
instance fintype_field_range [Fintype K] [DecidableEq L] (f : K →+* L) : Fintype f.field_range :=
  Set.fintypeRange f

end RingHom

namespace Subfield

/-! # inf -/


/-- The inf of two subfields is their intersection. -/
instance : HasInf (Subfield K) :=
  ⟨fun s t =>
    { s.to_subring⊓t.to_subring with
      inv_mem' := fun x hx =>
        Subring.mem_inf.mpr ⟨s.inv_mem (Subring.mem_inf.mp hx).1, t.inv_mem (Subring.mem_inf.mp hx).2⟩ }⟩

@[simp]
theorem coe_inf (p p' : Subfield K) : ((p⊓p' : Subfield K) : Set K) = p ∩ p' :=
  rfl

@[simp]
theorem mem_inf {p p' : Subfield K} {x : K} : x ∈ p⊓p' ↔ x ∈ p ∧ x ∈ p' :=
  Iff.rfl

instance : HasInfₓ (Subfield K) :=
  ⟨fun S =>
    { Inf (Subfield.toSubring '' S) with
      inv_mem' := by
        rintro x hx
        apply subring.mem_Inf.mpr
        rintro _ ⟨p, p_mem, rfl⟩
        exact p.inv_mem (subring.mem_Inf.mp hx p.to_subring ⟨p, p_mem, rfl⟩) }⟩

@[simp, norm_cast]
theorem coe_Inf (S : Set (Subfield K)) : ((Inf S : Subfield K) : Set K) = ⋂ s ∈ S, ↑s :=
  show ((Inf (Subfield.toSubring '' S) : Subring K) : Set K) = ⋂ s ∈ S, ↑s by
    ext x
    rw [Subring.coe_Inf, Set.mem_Inter, Set.mem_Inter]
    exact
      ⟨fun h s s' ⟨s_mem, s'_eq⟩ => h s.to_subring _ ⟨⟨s, s_mem, rfl⟩, s'_eq⟩,
        fun h s s' ⟨⟨s'', s''_mem, s_eq⟩, (s'_eq : ↑s = s')⟩ =>
        h s'' _
          ⟨s''_mem, by
            simp [← s_eq, ← s'_eq]⟩⟩

theorem mem_Inf {S : Set (Subfield K)} {x : K} : x ∈ Inf S ↔ ∀, ∀ p ∈ S, ∀, x ∈ p :=
  Subring.mem_Inf.trans ⟨fun h p hp => h p.to_subring ⟨p, hp, rfl⟩, fun h p ⟨p', hp', p_eq⟩ => p_eq ▸ h p' hp'⟩

@[simp]
theorem Inf_to_subring (s : Set (Subfield K)) : (Inf s).toSubring = ⨅ t ∈ s, Subfield.toSubring t := by
  ext x
  rw [mem_to_subring, mem_Inf]
  erw [Subring.mem_Inf]
  exact
    ⟨fun h p ⟨p', hp⟩ => hp ▸ subring.mem_Inf.mpr fun p ⟨hp', hp⟩ => hp ▸ h _ hp', fun h p hp =>
      h p.to_subring
        ⟨p,
          Subring.ext fun x =>
            ⟨fun hx => subring.mem_Inf.mp hx _ ⟨hp, rfl⟩, fun hx =>
              subring.mem_Inf.mpr fun p' ⟨hp, p'_eq⟩ => p'_eq ▸ hx⟩⟩⟩

theorem is_glb_Inf (S : Set (Subfield K)) : IsGlb S (Inf S) := by
  refine' IsGlb.of_image (fun s t => show (s : Set K) ≤ t ↔ s ≤ t from SetLike.coe_subset_coe) _
  convert is_glb_binfi
  exact coe_Inf _

/-- Subfields of a ring form a complete lattice. -/
instance : CompleteLattice (Subfield K) :=
  { completeLatticeOfInf (Subfield K) is_glb_Inf with top := ⊤, le_top := fun s x hx => trivialₓ, inf := ·⊓·,
    inf_le_left := fun s t x => And.left, inf_le_right := fun s t x => And.right,
    le_inf := fun s t₁ t₂ h₁ h₂ x hx => ⟨h₁ hx, h₂ hx⟩ }

/-! # subfield closure of a subset -/


-- ././Mathport/Syntax/Translate/Basic.lean:825:4: unsupported set replacement {(«expr / »(x, y)) | (x «expr ∈ » subring.closure s) (y «expr ∈ » subring.closure s)}
/-- The `subfield` generated by a set. -/
def closure (s : Set K) : Subfield K where
  Carrier :=
    "././Mathport/Syntax/Translate/Basic.lean:825:4: unsupported set replacement {(«expr / »(x, y)) | (x «expr ∈ » subring.closure s) (y «expr ∈ » subring.closure s)}"
  zero_mem' := ⟨0, Subring.zero_mem _, 1, Subring.one_mem _, div_one _⟩
  one_mem' := ⟨1, Subring.one_mem _, 1, Subring.one_mem _, div_one _⟩
  neg_mem' := fun x ⟨y, hy, z, hz, x_eq⟩ => ⟨-y, Subring.neg_mem _ hy, z, hz, x_eq ▸ neg_div _ _⟩
  inv_mem' := fun x ⟨y, hy, z, hz, x_eq⟩ => ⟨z, hz, y, hy, x_eq ▸ inv_div.symm⟩
  add_mem' := fun x y x_mem y_mem => by
    obtain ⟨nx, hnx, dx, hdx, rfl⟩ := id x_mem
    obtain ⟨ny, hny, dy, hdy, rfl⟩ := id y_mem
    by_cases' hx0 : dx = 0
    · rwa [hx0, div_zero, zero_addₓ]
      
    by_cases' hy0 : dy = 0
    · rwa [hy0, div_zero, add_zeroₓ]
      
    exact
      ⟨nx * dy + dx * ny, Subring.add_mem _ (Subring.mul_mem _ hnx hdy) (Subring.mul_mem _ hdx hny), dx * dy,
        Subring.mul_mem _ hdx hdy, (div_add_div nx ny hx0 hy0).symm⟩
  mul_mem' := fun x y x_mem y_mem => by
    obtain ⟨nx, hnx, dx, hdx, rfl⟩ := id x_mem
    obtain ⟨ny, hny, dy, hdy, rfl⟩ := id y_mem
    exact ⟨nx * ny, Subring.mul_mem _ hnx hny, dx * dy, Subring.mul_mem _ hdx hdy, (div_mul_div _ _ _ _).symm⟩

theorem mem_closure_iff {s : Set K} {x} : x ∈ closure s ↔ ∃ y ∈ Subring.closure s, ∃ z ∈ Subring.closure s, y / z = x :=
  Iff.rfl

theorem subring_closure_le (s : Set K) : Subring.closure s ≤ (closure s).toSubring := fun x hx =>
  ⟨x, hx, 1, Subring.one_mem _, div_one x⟩

/-- The subfield generated by a set includes the set. -/
@[simp]
theorem subset_closure {s : Set K} : s ⊆ closure s :=
  Set.Subset.trans Subring.subset_closure (subring_closure_le s)

theorem not_mem_of_not_mem_closure {s : Set K} {P : K} (hP : P ∉ closure s) : P ∉ s := fun h => hP (subset_closure h)

theorem mem_closure {x : K} {s : Set K} : x ∈ closure s ↔ ∀ S : Subfield K, s ⊆ S → x ∈ S :=
  ⟨fun ⟨y, hy, z, hz, x_eq⟩ t le =>
    x_eq ▸ t.div_mem (Subring.mem_closure.mp hy t.to_subring le) (Subring.mem_closure.mp hz t.to_subring le), fun h =>
    h (closure s) subset_closure⟩

/-- A subfield `t` includes `closure s` if and only if it includes `s`. -/
@[simp]
theorem closure_le {s : Set K} {t : Subfield K} : closure s ≤ t ↔ s ⊆ t :=
  ⟨Set.Subset.trans subset_closure, fun h x hx => mem_closure.mp hx t h⟩

/-- Subfield closure of a set is monotone in its argument: if `s ⊆ t`,
then `closure s ≤ closure t`. -/
theorem closure_mono ⦃s t : Set K⦄ (h : s ⊆ t) : closure s ≤ closure t :=
  closure_le.2 $ Set.Subset.trans h subset_closure

theorem closure_eq_of_le {s : Set K} {t : Subfield K} (h₁ : s ⊆ t) (h₂ : t ≤ closure s) : closure s = t :=
  le_antisymmₓ (closure_le.2 h₁) h₂

/-- An induction principle for closure membership. If `p` holds for `1`, and all elements
of `s`, and is preserved under addition, negation, and multiplication, then `p` holds for all
elements of the closure of `s`. -/
@[elab_as_eliminator]
theorem closure_induction {s : Set K} {p : K → Prop} {x} (h : x ∈ closure s) (Hs : ∀, ∀ x ∈ s, ∀, p x) (H1 : p 1)
    (Hadd : ∀ x y, p x → p y → p (x + y)) (Hneg : ∀ x, p x → p (-x)) (Hinv : ∀ x, p x → p (x⁻¹))
    (Hmul : ∀ x y, p x → p y → p (x * y)) : p x :=
  (@closure_le _ _ _ ⟨p, H1, Hmul, @add_neg_selfₓ K _ 1 ▸ Hadd _ _ H1 (Hneg _ H1), Hadd, Hneg, Hinv⟩).2 Hs h

variable (K)

/-- `closure` forms a Galois insertion with the coercion to set. -/
protected def gi : GaloisInsertion (@closure K _) coe where
  choice := fun s _ => closure s
  gc := fun s t => closure_le
  le_l_u := fun s => subset_closure
  choice_eq := fun s h => rfl

variable {K}

/-- Closure of a subfield `S` equals `S`. -/
theorem closure_eq (s : Subfield K) : closure (s : Set K) = s :=
  (Subfield.gi K).l_u_eq s

@[simp]
theorem closure_empty : closure (∅ : Set K) = ⊥ :=
  (Subfield.gi K).gc.l_bot

@[simp]
theorem closure_univ : closure (Set.Univ : Set K) = ⊤ :=
  @coe_top K _ ▸ closure_eq ⊤

theorem closure_union (s t : Set K) : closure (s ∪ t) = closure s⊔closure t :=
  (Subfield.gi K).gc.l_sup

theorem closure_Union {ι} (s : ι → Set K) : closure (⋃ i, s i) = ⨆ i, closure (s i) :=
  (Subfield.gi K).gc.l_supr

theorem closure_sUnion (s : Set (Set K)) : closure (⋃₀s) = ⨆ t ∈ s, closure t :=
  (Subfield.gi K).gc.l_Sup

theorem map_sup (s t : Subfield K) (f : K →+* L) : (s⊔t).map f = s.map f⊔t.map f :=
  (gc_map_comap f).l_sup

theorem map_supr {ι : Sort _} (f : K →+* L) (s : ι → Subfield K) : (supr s).map f = ⨆ i, (s i).map f :=
  (gc_map_comap f).l_supr

theorem comap_inf (s t : Subfield L) (f : K →+* L) : (s⊓t).comap f = s.comap f⊓t.comap f :=
  (gc_map_comap f).u_inf

theorem comap_infi {ι : Sort _} (f : K →+* L) (s : ι → Subfield L) : (infi s).comap f = ⨅ i, (s i).comap f :=
  (gc_map_comap f).u_infi

@[simp]
theorem map_bot (f : K →+* L) : (⊥ : Subfield K).map f = ⊥ :=
  (gc_map_comap f).l_bot

@[simp]
theorem comap_top (f : K →+* L) : (⊤ : Subfield L).comap f = ⊤ :=
  (gc_map_comap f).u_top

/-- The underlying set of a non-empty directed Sup of subfields is just a union of the subfields.
  Note that this fails without the directedness assumption (the union of two subfields is
  typically not a subfield) -/
theorem mem_supr_of_directed {ι} [hι : Nonempty ι] {S : ι → Subfield K} (hS : Directed (· ≤ ·) S) {x : K} :
    (x ∈ ⨆ i, S i) ↔ ∃ i, x ∈ S i := by
  refine' ⟨_, fun ⟨i, hi⟩ => (SetLike.le_def.1 $ le_supr S i) hi⟩
  suffices x ∈ closure (⋃ i, (S i : Set K)) → ∃ i, x ∈ S i by
    simpa only [closure_Union, closure_eq]
  refine' fun hx => closure_induction hx (fun x => set.mem_Union.mp) _ _ _ _ _
  · exact hι.elim fun i => ⟨i, (S i).one_mem⟩
    
  · rintro x y ⟨i, hi⟩ ⟨j, hj⟩
    obtain ⟨k, hki, hkj⟩ := hS i j
    exact ⟨k, (S k).add_mem (hki hi) (hkj hj)⟩
    
  · rintro x ⟨i, hi⟩
    exact ⟨i, (S i).neg_mem hi⟩
    
  · rintro x ⟨i, hi⟩
    exact ⟨i, (S i).inv_mem hi⟩
    
  · rintro x y ⟨i, hi⟩ ⟨j, hj⟩
    obtain ⟨k, hki, hkj⟩ := hS i j
    exact ⟨k, (S k).mul_mem (hki hi) (hkj hj)⟩
    

theorem coe_supr_of_directed {ι} [hι : Nonempty ι] {S : ι → Subfield K} (hS : Directed (· ≤ ·) S) :
    ((⨆ i, S i : Subfield K) : Set K) = ⋃ i, ↑S i :=
  Set.ext $ fun x => by
    simp [mem_supr_of_directed hS]

theorem mem_Sup_of_directed_on {S : Set (Subfield K)} (Sne : S.nonempty) (hS : DirectedOn (· ≤ ·) S) {x : K} :
    x ∈ Sup S ↔ ∃ s ∈ S, x ∈ s := by
  have : Nonempty S := Sne.to_subtype
  simp only [Sup_eq_supr', mem_supr_of_directed hS.directed_coe, SetCoe.exists, Subtype.coe_mk]

theorem coe_Sup_of_directed_on {S : Set (Subfield K)} (Sne : S.nonempty) (hS : DirectedOn (· ≤ ·) S) :
    (↑Sup S : Set K) = ⋃ s ∈ S, ↑s :=
  Set.ext $ fun x => by
    simp [mem_Sup_of_directed_on Sne hS]

end Subfield

namespace RingHom

variable {s : Subfield K}

open Subfield

/-- Restrict the codomain of a ring homomorphism to a subfield that includes the range. -/
def cod_restrict_field (f : K →+* L) (s : Subfield L) (h : ∀ x, f x ∈ s) : K →+* s where
  toFun := fun x => ⟨f x, h x⟩
  map_add' := fun x y => Subtype.eq $ f.map_add x y
  map_zero' := Subtype.eq f.map_zero
  map_mul' := fun x y => Subtype.eq $ f.map_mul x y
  map_one' := Subtype.eq f.map_one

/-- Restriction of a ring homomorphism to a subfield of the domain. -/
def restrict_field (f : K →+* L) (s : Subfield K) : s →+* L :=
  f.comp s.subtype

@[simp]
theorem restrict_field_apply (f : K →+* L) (x : s) : f.restrict_field s x = f x :=
  rfl

/-- Restriction of a ring homomorphism to its range interpreted as a subfield. -/
def range_restrict_field (f : K →+* L) : K →+* f.field_range :=
  f.srange_restrict

@[simp]
theorem coe_range_restrict_field (f : K →+* L) (x : K) : (f.range_restrict_field x : L) = f x :=
  rfl

/-- The subfield of elements `x : R` such that `f x = g x`, i.e.,
the equalizer of f and g as a subfield of R -/
def eq_locus_field (f g : K →+* L) : Subfield K :=
  { (f : K →+* L).eqLocus g with
    inv_mem' := fun x hx : f x = g x =>
      show f (x⁻¹) = g (x⁻¹) by
        rw [f.map_inv, g.map_inv, hx],
    Carrier := { x | f x = g x } }

/-- If two ring homomorphisms are equal on a set, then they are equal on its subfield closure. -/
theorem eq_on_field_closure {f g : K →+* L} {s : Set K} (h : Set.EqOn f g s) : Set.EqOn f g (closure s) :=
  show closure s ≤ f.eq_locus_field g from closure_le.2 h

theorem eq_of_eq_on_subfield_top {f g : K →+* L} (h : Set.EqOn f g (⊤ : Subfield K)) : f = g :=
  ext $ fun x => h trivialₓ

theorem eq_of_eq_on_of_field_closure_eq_top {s : Set K} (hs : closure s = ⊤) {f g : K →+* L} (h : s.eq_on f g) :
    f = g :=
  eq_of_eq_on_subfield_top $ hs ▸ eq_on_field_closure h

theorem field_closure_preimage_le (f : K →+* L) (s : Set L) : closure (f ⁻¹' s) ≤ (closure s).comap f :=
  closure_le.2 $ fun x hx => SetLike.mem_coe.2 $ mem_comap.2 $ subset_closure hx

/-- The image under a ring homomorphism of the subfield generated by a set equals
the subfield generated by the image of the set. -/
theorem map_field_closure (f : K →+* L) (s : Set K) : (closure s).map f = closure (f '' s) :=
  le_antisymmₓ
    (map_le_iff_le_comap.2 $ le_transₓ (closure_mono $ Set.subset_preimage_image _ _) (field_closure_preimage_le _ _))
    (closure_le.2 $ Set.image_subset _ subset_closure)

end RingHom

namespace Subfield

open RingHom

/-- The ring homomorphism associated to an inclusion of subfields. -/
def inclusion {S T : Subfield K} (h : S ≤ T) : S →+* T :=
  S.subtype.cod_restrict_field _ fun x => h x.2

@[simp]
theorem field_range_subtype (s : Subfield K) : s.subtype.field_range = s :=
  SetLike.ext' $ (coe_srange _).trans Subtype.range_coe

end Subfield

namespace RingEquiv

variable {s t : Subfield K}

/-- Makes the identity isomorphism from a proof two subfields of a multiplicative
    monoid are equal. -/
def subfield_congr (h : s = t) : s ≃+* t :=
  { Equivₓ.setCongr $ SetLike.ext'_iff.1 h with map_mul' := fun _ _ => rfl, map_add' := fun _ _ => rfl }

end RingEquiv

namespace Subfield

variable {s : Set K}

theorem closure_preimage_le (f : K →+* L) (s : Set L) : closure (f ⁻¹' s) ≤ (closure s).comap f :=
  closure_le.2 $ fun x hx => SetLike.mem_coe.2 $ mem_comap.2 $ subset_closure hx

end Subfield

