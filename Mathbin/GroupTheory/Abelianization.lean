import Mathbin.GroupTheory.QuotientGroup
import Mathbin.Tactic.Group

/-!
# The abelianization of a group

This file defines the commutator and the abelianization of a group. It furthermore prepares for the
result that the abelianization is left adjoint to the forgetful functor from abelian groups to
groups, which can be found in `algebra/category/Group/adjunctions`.

## Main definitions

* `commutator`: defines the commutator of a group `G` as a subgroup of `G`.
* `abelianization`: defines the abelianization of a group `G` as the quotient of a group by its
  commutator subgroup.
* `abelianization.map`: lifts a group homomorphism to a homomorphism between the abelianizations
* `mul_equiv.abelianization_congr`: Equivalent groups have equivalent abelianizations

-/


universe u v w

variable (G : Type u) [Groupₓ G]

/-- The commutator subgroup of a group G is the normal subgroup
  generated by the commutators [p,q]=`p*q*p⁻¹*q⁻¹`. -/
def commutator : Subgroup G :=
  Subgroup.normalClosure { x | ∃ p q, p * q * p⁻¹ * q⁻¹ = x }deriving Subgroup.Normal

/-- The abelianization of G is the quotient of G by its commutator subgroup. -/
def Abelianization : Type u :=
  G ⧸ commutator G

namespace Abelianization

attribute [local instance] QuotientGroup.leftRel

instance : CommGroupₓ (Abelianization G) :=
  { QuotientGroup.Quotient.group _ with
    mul_comm := fun x y =>
      Quotientₓ.induction_on₂' x y $ fun a b => by
        apply Quotientₓ.sound
        apply Subgroup.subset_normal_closure
        use b⁻¹
        use a⁻¹
        group }

instance : Inhabited (Abelianization G) :=
  ⟨1⟩

instance [Fintype G] [DecidablePred (· ∈ commutator G)] : Fintype (Abelianization G) :=
  QuotientGroup.fintype (commutator G)

variable {G}

/-- `of` is the canonical projection from G to its abelianization. -/
def of : G →* Abelianization G where
  toFun := QuotientGroup.mk
  map_one' := rfl
  map_mul' := fun x y => rfl

@[simp]
theorem mk_eq_of (a : G) : Quot.mk _ a = of a :=
  rfl

section lift

variable {A : Type v} [CommGroupₓ A] (f : G →* A)

theorem commutator_subset_ker : commutator G ≤ f.ker := by
  apply Subgroup.normal_closure_le_normal
  rintro x ⟨p, q, rfl⟩
  simp [MonoidHom.mem_ker, mul_right_commₓ (f p) (f q)]

/-- If `f : G → A` is a group homomorphism to an abelian group, then `lift f` is the unique map from
  the abelianization of a `G` to `A` that factors through `f`. -/
def lift : (G →* A) ≃ (Abelianization G →* A) where
  toFun := fun f => QuotientGroup.lift _ f fun x h => f.mem_ker.2 $ commutator_subset_ker _ h
  invFun := fun F => F.comp of
  left_inv := fun f => MonoidHom.ext $ fun x => rfl
  right_inv := fun F => MonoidHom.ext $ fun x => QuotientGroup.induction_on x $ fun z => rfl

@[simp]
theorem lift.of (x : G) : lift f (of x) = f x :=
  rfl

theorem lift.unique (φ : Abelianization G →* A) (hφ : ∀ x : G, φ (of x) = f x) {x : Abelianization G} :
    φ x = lift f x :=
  QuotientGroup.induction_on x hφ

@[simp]
theorem lift_of : lift of = MonoidHom.id (Abelianization G) :=
  lift.apply_symm_apply $ MonoidHom.id _

end lift

variable {A : Type v} [Monoidₓ A]

/-- See note [partially-applied ext lemmas]. -/
@[ext]
theorem hom_ext (φ ψ : Abelianization G →* A) (h : φ.comp of = ψ.comp of) : φ = ψ :=
  MonoidHom.ext $ fun x => QuotientGroup.induction_on x $ MonoidHom.congr_fun h

section Map

variable {H : Type v} [Groupₓ H] (f : G →* H)

/-- The map operation of the `abelianization` functor -/
def map : Abelianization G →* Abelianization H :=
  lift (of.comp f)

@[simp]
theorem map_of (x : G) : map f (of x) = of (f x) :=
  rfl

@[simp]
theorem map_id : map (MonoidHom.id G) = MonoidHom.id (Abelianization G) :=
  hom_ext _ _ rfl

@[simp]
theorem map_comp {I : Type w} [Groupₓ I] (g : H →* I) : (map g).comp (map f) = map (g.comp f) :=
  hom_ext _ _ rfl

@[simp]
theorem map_map_apply {I : Type w} [Groupₓ I] {g : H →* I} {x : Abelianization G} :
    map g (map f x) = map (g.comp f) x :=
  MonoidHom.congr_fun (map_comp _ _) x

end Map

end Abelianization

section AbelianizationCongr

variable {G} {H : Type v} [Groupₓ H] (e : G ≃* H)

/-- Equivalent groups have equivalent abelianizations -/
def MulEquiv.abelianizationCongr : Abelianization G ≃* Abelianization H where
  toFun := Abelianization.map e.to_monoid_hom
  invFun := Abelianization.map e.symm.to_monoid_hom
  left_inv := by
    rintro ⟨a⟩
    simp
  right_inv := by
    rintro ⟨a⟩
    simp
  map_mul' := MonoidHom.map_mul _

@[simp]
theorem abelianization_congr_of (x : G) : e.abelianization_congr (Abelianization.of x) = Abelianization.of (e x) :=
  rfl

@[simp]
theorem abelianization_congr_refl : (MulEquiv.refl G).abelianizationCongr = MulEquiv.refl (Abelianization G) :=
  MulEquiv.to_monoid_hom_injective Abelianization.lift_of

@[simp]
theorem abelianization_congr_symm : e.abelianization_congr.symm = e.symm.abelianization_congr :=
  rfl

@[simp]
theorem abelianization_congr_trans {I : Type v} [Groupₓ I] (e₂ : H ≃* I) :
    e.abelianization_congr.trans e₂.abelianization_congr = (e.trans e₂).abelianizationCongr :=
  MulEquiv.to_monoid_hom_injective (Abelianization.hom_ext _ _ rfl)

end AbelianizationCongr

