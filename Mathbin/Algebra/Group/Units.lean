import Mathbin.Algebra.Group.Basic
import Mathbin.Logic.Nontrivial

/-!
# Units (i.e., invertible elements) of a monoid

An element of a `monoid` is a unit if it has a two-sided inverse.

## Main declarations

* `units M`: the group of units (i.e., invertible elements) of a monoid.
* `is_unit x`: a predicate asserting that `x` is a unit (i.e., invertible element) of a monoid.

For both declarations, there is an additive counterpart: `add_units` and `is_add_unit`.

## Notation

We provide `Mˣ` as notation for `units M`,
resembling the notation $R^{\times}$ for the units of a ring, which is common in mathematics.

-/


universe u

variable {α : Type u}

/-- Units of a `monoid`, bundled version. Notation: `αˣ`.

An element of a `monoid` is a unit if it has a two-sided inverse.
This version bundles the inverse element so that it can be computed.
For a predicate see `is_unit`. -/
structure Units (α : Type u) [Monoidₓ α] where
  val : α
  inv : α
  val_inv : val * inv = 1
  inv_val : inv * val = 1

postfix:1025 "ˣ" => Units

/-- Units of an `add_monoid`, bundled version.

An element of an `add_monoid` is a unit if it has a two-sided additive inverse.
This version bundles the inverse element so that it can be computed.
For a predicate see `is_add_unit`. -/
structure AddUnits (α : Type u) [AddMonoidₓ α] where
  val : α
  neg : α
  val_neg : val + neg = 0
  neg_val : neg + val = 0

attribute [to_additive AddUnits] Units

section HasElem

@[to_additive]
theorem unique_has_one {α : Type _} [Unique α] [One α] : default = (1 : α) :=
  Unique.default_eq 1

end HasElem

namespace Units

variable [Monoidₓ α]

@[to_additive]
instance : Coe (α)ˣ α :=
  ⟨val⟩

@[to_additive]
instance : HasInv (α)ˣ :=
  ⟨fun u => ⟨u.2, u.1, u.4, u.3⟩⟩

/-- See Note [custom simps projection] -/
@[to_additive " See Note [custom simps projection] "]
def simps.coe (u : (α)ˣ) : α :=
  u

/-- See Note [custom simps projection] -/
@[to_additive " See Note [custom simps projection] "]
def simps.coe_inv (u : (α)ˣ) : α :=
  ↑u⁻¹

initialize_simps_projections Units (val → coe as_prefix, inv → coeInv as_prefix)

initialize_simps_projections AddUnits (val → coe as_prefix, neg → coeNeg as_prefix)

@[simp, to_additive]
theorem coe_mk (a : α) b h₁ h₂ : ↑Units.mk a b h₁ h₂ = a :=
  rfl

@[ext, to_additive]
theorem ext : Function.Injective (coe : (α)ˣ → α)
  | ⟨v, i₁, vi₁, iv₁⟩, ⟨v', i₂, vi₂, iv₂⟩, e => by
    change v = v' at e <;> subst v' <;> congr <;> simpa only [iv₂, vi₁, one_mulₓ, mul_oneₓ] using mul_assoc i₂ v i₁

@[norm_cast, to_additive]
theorem eq_iff {a b : (α)ˣ} : (a : α) = b ↔ a = b :=
  ext.eq_iff

@[to_additive]
theorem ext_iff {a b : (α)ˣ} : a = b ↔ (a : α) = b :=
  eq_iff.symm

@[to_additive]
instance [DecidableEq α] : DecidableEq (α)ˣ := fun a b => decidableOfIff' _ ext_iff

@[simp, to_additive]
theorem mk_coe (u : (α)ˣ) y h₁ h₂ : mk (u : α) y h₁ h₂ = u :=
  ext rfl

/-- Copy a unit, adjusting definition equalities. -/
@[to_additive "Copy an `add_unit`, adjusting definitional equalities.", simps]
def copy (u : (α)ˣ) (val : α) (hv : val = u) (inv : α) (hi : inv = ↑u⁻¹) : (α)ˣ :=
  { val, inv, inv_val := hv.symm ▸ hi.symm ▸ u.inv_val, val_inv := hv.symm ▸ hi.symm ▸ u.val_inv }

@[to_additive]
theorem copy_eq (u : (α)ˣ) val hv inv hi : u.copy val hv inv hi = u :=
  ext hv

/-- Units of a monoid form a group. -/
@[to_additive]
instance : Groupₓ (α)ˣ where
  mul := fun u₁ u₂ =>
    ⟨u₁.val * u₂.val, u₂.inv * u₁.inv, by
      rw [mul_assoc, ← mul_assoc u₂.val, val_inv, one_mulₓ, val_inv], by
      rw [mul_assoc, ← mul_assoc u₁.inv, inv_val, one_mulₓ, inv_val]⟩
  one := ⟨1, 1, one_mulₓ 1, one_mulₓ 1⟩
  mul_one := fun u => ext $ mul_oneₓ u
  one_mul := fun u => ext $ one_mulₓ u
  mul_assoc := fun u₁ u₂ u₃ => ext $ mul_assoc u₁ u₂ u₃
  inv := HasInv.inv
  mul_left_inv := fun u => ext u.inv_val

variable (a b : (α)ˣ) {c : (α)ˣ}

@[simp, norm_cast, to_additive]
theorem coe_mul : (↑(a * b) : α) = a * b :=
  rfl

@[simp, norm_cast, to_additive]
theorem coe_one : ((1 : (α)ˣ) : α) = 1 :=
  rfl

@[simp, norm_cast, to_additive]
theorem coe_eq_one {a : (α)ˣ} : (a : α) = 1 ↔ a = 1 := by
  rw [← Units.coe_one, eq_iff]

@[simp, to_additive]
theorem inv_mk (x y : α) h₁ h₂ : mk x y h₁ h₂⁻¹ = mk y x h₂ h₁ :=
  rfl

@[simp, to_additive]
theorem val_eq_coe : a.val = (↑a : α) :=
  rfl

@[simp, to_additive]
theorem inv_eq_coe_inv : a.inv = ((a⁻¹ : (α)ˣ) : α) :=
  rfl

@[simp, to_additive]
theorem inv_mul : (↑a⁻¹ * a : α) = 1 :=
  inv_val _

@[simp, to_additive]
theorem mul_inv : (a * ↑a⁻¹ : α) = 1 :=
  val_inv _

@[to_additive]
theorem inv_mul_of_eq {u : (α)ˣ} {a : α} (h : ↑u = a) : ↑u⁻¹ * a = 1 := by
  rw [← h, u.inv_mul]

@[to_additive]
theorem mul_inv_of_eq {u : (α)ˣ} {a : α} (h : ↑u = a) : a * ↑u⁻¹ = 1 := by
  rw [← h, u.mul_inv]

@[simp, to_additive]
theorem mul_inv_cancel_left (a : (α)ˣ) (b : α) : (a : α) * (↑a⁻¹ * b) = b := by
  rw [← mul_assoc, mul_inv, one_mulₓ]

@[simp, to_additive]
theorem inv_mul_cancel_leftₓ (a : (α)ˣ) (b : α) : (↑a⁻¹ : α) * (a * b) = b := by
  rw [← mul_assoc, inv_mul, one_mulₓ]

@[simp, to_additive]
theorem mul_inv_cancel_rightₓ (a : α) (b : (α)ˣ) : a * b * ↑b⁻¹ = a := by
  rw [mul_assoc, mul_inv, mul_oneₓ]

@[simp, to_additive]
theorem inv_mul_cancel_right (a : α) (b : (α)ˣ) : a * ↑b⁻¹ * b = a := by
  rw [mul_assoc, inv_mul, mul_oneₓ]

@[to_additive]
instance : Inhabited (α)ˣ :=
  ⟨1⟩

@[to_additive]
instance {α} [CommMonoidₓ α] : CommGroupₓ (α)ˣ :=
  { Units.group with mul_comm := fun u₁ u₂ => ext $ mul_comm _ _ }

@[to_additive]
instance [HasRepr α] : HasRepr (α)ˣ :=
  ⟨reprₓ ∘ val⟩

@[simp, to_additive]
theorem mul_right_injₓ (a : (α)ˣ) {b c : α} : (a : α) * b = a * c ↔ b = c :=
  ⟨fun h => by
    simpa only [inv_mul_cancel_leftₓ] using congr_argₓ ((· * ·) (↑(a⁻¹ : (α)ˣ))) h, congr_argₓ _⟩

@[simp, to_additive]
theorem mul_left_injₓ (a : (α)ˣ) {b c : α} : b * a = c * a ↔ b = c :=
  ⟨fun h => by
    simpa only [mul_inv_cancel_rightₓ] using congr_argₓ (· * ↑(a⁻¹ : (α)ˣ)) h, congr_argₓ _⟩

@[to_additive]
theorem eq_mul_inv_iff_mul_eq {a b : α} : a = b * ↑c⁻¹ ↔ a * c = b :=
  ⟨fun h => by
    rw [h, inv_mul_cancel_right], fun h => by
    rw [← h, mul_inv_cancel_rightₓ]⟩

@[to_additive]
theorem eq_inv_mul_iff_mul_eq {a c : α} : a = ↑b⁻¹ * c ↔ ↑b * a = c :=
  ⟨fun h => by
    rw [h, mul_inv_cancel_left], fun h => by
    rw [← h, inv_mul_cancel_leftₓ]⟩

@[to_additive]
theorem inv_mul_eq_iff_eq_mul {b c : α} : ↑a⁻¹ * b = c ↔ b = a * c :=
  ⟨fun h => by
    rw [← h, mul_inv_cancel_left], fun h => by
    rw [h, inv_mul_cancel_leftₓ]⟩

@[to_additive]
theorem mul_inv_eq_iff_eq_mul {a c : α} : a * ↑b⁻¹ = c ↔ a = c * b :=
  ⟨fun h => by
    rw [← h, inv_mul_cancel_right], fun h => by
    rw [h, mul_inv_cancel_rightₓ]⟩

theorem inv_eq_of_mul_eq_oneₓ {u : (α)ˣ} {a : α} (h : ↑u * a = 1) : ↑u⁻¹ = a :=
  calc
    ↑u⁻¹ = ↑u⁻¹ * 1 := by
      rw [mul_oneₓ]
    _ = ↑u⁻¹ * ↑u * a := by
      rw [← h, ← mul_assoc]
    _ = a := by
      rw [u.inv_mul, one_mulₓ]
    

theorem inv_unique {u₁ u₂ : (α)ˣ} (h : (↑u₁ : α) = ↑u₂) : (↑u₁⁻¹ : α) = ↑u₂⁻¹ :=
  inv_eq_of_mul_eq_oneₓ $ by
    rw [h, u₂.mul_inv]

end Units

/-- For `a, b` in a `comm_monoid` such that `a * b = 1`, makes a unit out of `a`. -/
@[to_additive "For `a, b` in an `add_comm_monoid` such that `a + b = 0`, makes an add_unit\nout of `a`."]
def Units.mkOfMulEqOne [CommMonoidₓ α] (a b : α) (hab : a * b = 1) : (α)ˣ :=
  ⟨a, b, hab, (mul_comm b a).trans hab⟩

@[simp, to_additive]
theorem Units.coe_mk_of_mul_eq_one [CommMonoidₓ α] {a b : α} (h : a * b = 1) : (Units.mkOfMulEqOne a b h : α) = a :=
  rfl

section Monoidₓ

variable [Monoidₓ α] {a b c : α}

/-- Partial division. It is defined when the
  second argument is invertible, and unlike the division operator
  in `division_ring` it is not totalized at zero. -/
def divp (a : α) u : α :=
  a * (u⁻¹ : (α)ˣ)

infixl:70 " /ₚ " => divp

@[simp]
theorem divp_self (u : (α)ˣ) : (u : α) /ₚ u = 1 :=
  Units.mul_inv _

@[simp]
theorem divp_one (a : α) : a /ₚ 1 = a :=
  mul_oneₓ _

theorem divp_assoc (a b : α) (u : (α)ˣ) : a * b /ₚ u = a * (b /ₚ u) :=
  mul_assoc _ _ _

@[simp]
theorem divp_inv (u : (α)ˣ) : a /ₚ u⁻¹ = a * u :=
  rfl

@[simp]
theorem divp_mul_cancel (a : α) (u : (α)ˣ) : a /ₚ u * u = a :=
  (mul_assoc _ _ _).trans $ by
    rw [Units.inv_mul, mul_oneₓ]

@[simp]
theorem mul_divp_cancel (a : α) (u : (α)ˣ) : a * u /ₚ u = a :=
  (mul_assoc _ _ _).trans $ by
    rw [Units.mul_inv, mul_oneₓ]

@[simp]
theorem divp_left_inj (u : (α)ˣ) {a b : α} : a /ₚ u = b /ₚ u ↔ a = b :=
  Units.mul_left_inj _

theorem divp_divp_eq_divp_mul (x : α) (u₁ u₂ : (α)ˣ) : x /ₚ u₁ /ₚ u₂ = x /ₚ (u₂ * u₁) := by
  simp only [divp, mul_inv_rev, Units.coe_mul, mul_assoc]

theorem divp_eq_iff_mul_eq {x : α} {u : (α)ˣ} {y : α} : x /ₚ u = y ↔ y * u = x :=
  u.mul_left_inj.symm.trans $ by
    rw [divp_mul_cancel] <;> exact ⟨Eq.symm, Eq.symm⟩

theorem divp_eq_one_iff_eq {a : α} {u : (α)ˣ} : a /ₚ u = 1 ↔ a = u :=
  (Units.mul_left_inj u).symm.trans $ by
    rw [divp_mul_cancel, one_mulₓ]

@[simp]
theorem one_divp (u : (α)ˣ) : 1 /ₚ u = ↑u⁻¹ :=
  one_mulₓ _

end Monoidₓ

section CommMonoidₓ

variable [CommMonoidₓ α]

theorem divp_eq_divp_iff {x y : α} {ux uy : (α)ˣ} : x /ₚ ux = y /ₚ uy ↔ x * uy = y * ux := by
  rw [divp_eq_iff_mul_eq, mul_comm, ← divp_assoc, divp_eq_iff_mul_eq, mul_comm y ux]

theorem divp_mul_divp (x y : α) (ux uy : (α)ˣ) : x /ₚ ux * (y /ₚ uy) = x * y /ₚ (ux * uy) := by
  rw [← divp_divp_eq_divp_mul, divp_assoc, mul_comm x, divp_assoc, mul_comm]

end CommMonoidₓ

/-!
# `is_unit` predicate

In this file we define the `is_unit` predicate on a `monoid`, and
prove a few basic properties. For the bundled version see `units`. See
also `prime`, `associated`, and `irreducible` in `algebra/associated`.

-/


section IsUnit

variable {M : Type _} {N : Type _}

/-- An element `a : M` of a monoid is a unit if it has a two-sided inverse.
The actual definition says that `a` is equal to some `u : Mˣ`, where
`Mˣ` is a bundled version of `is_unit`. -/
@[to_additive IsAddUnit
      "An element `a : M` of an add_monoid is an `add_unit` if it has\na two-sided additive inverse. The actual definition says that `a` is equal to some\n`u : add_units M`, where `add_units M` is a bundled version of `is_add_unit`."]
def IsUnit [Monoidₓ M] (a : M) : Prop :=
  ∃ u : (M)ˣ, (u : M) = a

@[nontriviality, to_additive is_add_unit_of_subsingleton]
theorem is_unit_of_subsingleton [Monoidₓ M] [Subsingleton M] (a : M) : IsUnit a :=
  ⟨⟨a, a, Subsingleton.elimₓ _ _, Subsingleton.elimₓ _ _⟩, rfl⟩

attribute [nontriviality] is_add_unit_of_subsingleton

@[to_additive]
instance [Monoidₓ M] : CanLift M (M)ˣ where
  coe := coe
  cond := IsUnit
  prf := fun _ => id

@[to_additive]
instance [Monoidₓ M] [Subsingleton M] : Unique (M)ˣ where
  default := 1
  uniq := fun a => Units.coe_eq_one.mp $ Subsingleton.elimₓ (a : M) 1

@[simp, to_additive is_add_unit_add_unit]
protected theorem Units.is_unit [Monoidₓ M] (u : (M)ˣ) : IsUnit (u : M) :=
  ⟨u, rfl⟩

@[simp, to_additive is_add_unit_zero]
theorem is_unit_one [Monoidₓ M] : IsUnit (1 : M) :=
  ⟨1, rfl⟩

@[to_additive is_add_unit_of_add_eq_zero]
theorem is_unit_of_mul_eq_one [CommMonoidₓ M] (a b : M) (h : a * b = 1) : IsUnit a :=
  ⟨Units.mkOfMulEqOne a b h, rfl⟩

@[to_additive IsAddUnit.exists_neg]
theorem IsUnit.exists_right_inv [Monoidₓ M] {a : M} (h : IsUnit a) : ∃ b, a * b = 1 := by
  rcases h with ⟨⟨a, b, hab, _⟩, rfl⟩
  exact ⟨b, hab⟩

@[to_additive IsAddUnit.exists_neg']
theorem IsUnit.exists_left_inv [Monoidₓ M] {a : M} (h : IsUnit a) : ∃ b, b * a = 1 := by
  rcases h with ⟨⟨a, b, _, hba⟩, rfl⟩
  exact ⟨b, hba⟩

@[to_additive is_add_unit_iff_exists_neg]
theorem is_unit_iff_exists_inv [CommMonoidₓ M] {a : M} : IsUnit a ↔ ∃ b, a * b = 1 :=
  ⟨fun h => h.exists_right_inv, fun ⟨b, hab⟩ => is_unit_of_mul_eq_one _ b hab⟩

@[to_additive is_add_unit_iff_exists_neg']
theorem is_unit_iff_exists_inv' [CommMonoidₓ M] {a : M} : IsUnit a ↔ ∃ b, b * a = 1 := by
  simp [is_unit_iff_exists_inv, mul_comm]

@[to_additive]
theorem IsUnit.mul [Monoidₓ M] {x y : M} : IsUnit x → IsUnit y → IsUnit (x * y) := by
  rintro ⟨x, rfl⟩ ⟨y, rfl⟩
  exact ⟨x * y, Units.coe_mul _ _⟩

/-- Multiplication by a `u : Mˣ` on the right doesn't affect `is_unit`. -/
@[simp,
  to_additive is_add_unit_add_add_units "Addition of a `u : add_units M` on the right doesn't\naffect `is_add_unit`."]
theorem Units.is_unit_mul_units [Monoidₓ M] (a : M) (u : (M)ˣ) : IsUnit (a * u) ↔ IsUnit a :=
  Iff.intro
    (fun ⟨v, hv⟩ => by
      have : IsUnit (a * ↑u * ↑u⁻¹) := by
        exists v * u⁻¹ <;> rw [← hv, Units.coe_mul]
      rwa [mul_assoc, Units.mul_inv, mul_oneₓ] at this)
    fun v => v.mul u.is_unit

/-- Multiplication by a `u : Mˣ` on the left doesn't affect `is_unit`. -/
@[simp,
  to_additive is_add_unit_add_units_add "Addition of a `u : add_units M` on the left doesn't\naffect `is_add_unit`."]
theorem Units.is_unit_units_mul {M : Type _} [Monoidₓ M] (u : (M)ˣ) (a : M) : IsUnit (↑u * a) ↔ IsUnit a :=
  Iff.intro
    (fun ⟨v, hv⟩ => by
      have : IsUnit (↑u⁻¹ * (↑u * a)) := by
        exists u⁻¹ * v <;> rw [← hv, Units.coe_mul]
      rwa [← mul_assoc, Units.inv_mul, one_mulₓ] at this)
    u.is_unit.mul

@[to_additive is_add_unit_of_add_is_add_unit_left]
theorem is_unit_of_mul_is_unit_left [CommMonoidₓ M] {x y : M} (hu : IsUnit (x * y)) : IsUnit x :=
  let ⟨z, hz⟩ := is_unit_iff_exists_inv.1 hu
  is_unit_iff_exists_inv.2
    ⟨y * z, by
      rwa [← mul_assoc]⟩

@[to_additive]
theorem is_unit_of_mul_is_unit_right [CommMonoidₓ M] {x y : M} (hu : IsUnit (x * y)) : IsUnit y :=
  @is_unit_of_mul_is_unit_left _ _ y x $ by
    rwa [mul_comm]

@[simp, to_additive]
theorem IsUnit.mul_iff [CommMonoidₓ M] {x y : M} : IsUnit (x * y) ↔ IsUnit x ∧ IsUnit y :=
  ⟨fun h => ⟨is_unit_of_mul_is_unit_left h, is_unit_of_mul_is_unit_right h⟩, fun h => IsUnit.mul h.1 h.2⟩

@[to_additive]
theorem IsUnit.mul_right_inj [Monoidₓ M] {a b c : M} (ha : IsUnit a) : a * b = a * c ↔ b = c := by
  cases' ha with a ha <;> rw [← ha, Units.mul_right_inj]

@[to_additive]
theorem IsUnit.mul_left_inj [Monoidₓ M] {a b c : M} (ha : IsUnit a) : b * a = c * a ↔ b = c := by
  cases' ha with a ha <;> rw [← ha, Units.mul_left_inj]

/-- The element of the group of units, corresponding to an element of a monoid which is a unit. -/
@[to_additive
      "The element of the additive group of additive units, corresponding to an element of\nan additive monoid which is an additive unit."]
noncomputable def IsUnit.unit [Monoidₓ M] {a : M} (h : IsUnit a) : (M)ˣ :=
  (Classical.some h).copy a (Classical.some_spec h).symm _ rfl

@[to_additive]
theorem IsUnit.unit_spec [Monoidₓ M] {a : M} (h : IsUnit a) : ↑h.unit = a :=
  rfl

@[to_additive]
theorem IsUnit.coe_inv_mul [Monoidₓ M] {a : M} (h : IsUnit a) : ↑h.unit⁻¹ * a = 1 :=
  Units.mul_inv _

@[to_additive]
theorem IsUnit.mul_coe_inv [Monoidₓ M] {a : M} (h : IsUnit a) : a * ↑h.unit⁻¹ = 1 := by
  convert Units.mul_inv _
  simp [h.unit_spec]

end IsUnit

section NoncomputableDefs

variable {M : Type _}

/-- Constructs a `group` structure on a `monoid` consisting only of units. -/
noncomputable def groupOfIsUnit [hM : Monoidₓ M] (h : ∀ a : M, IsUnit a) : Groupₓ M :=
  { hM with inv := fun a => ↑(h a).Unit⁻¹,
    mul_left_inv := fun a => by
      change ↑(h a).Unit⁻¹ * a = 1
      rw [Units.inv_mul_eq_iff_eq_mul, (h a).unit_spec, mul_oneₓ] }

/-- Constructs a `comm_group` structure on a `comm_monoid` consisting only of units. -/
noncomputable def commGroupOfIsUnit [hM : CommMonoidₓ M] (h : ∀ a : M, IsUnit a) : CommGroupₓ M :=
  { hM with inv := fun a => ↑(h a).Unit⁻¹,
    mul_left_inv := fun a => by
      change ↑(h a).Unit⁻¹ * a = 1
      rw [Units.inv_mul_eq_iff_eq_mul, (h a).unit_spec, mul_oneₓ] }

end NoncomputableDefs

