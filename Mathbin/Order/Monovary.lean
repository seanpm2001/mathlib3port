import Mathbin.Order.Monotone

/-!
# Monovariance of functions

Two functions *vary together* if a strict change in the first implies a change in the second.

This is in some sense a way to say that two functions `f : ι → α`, `g : ι → β` are "monotone
together", without actually having an order on `ι`.

This condition comes up in the rearrangement inequality. See `algebra.order.rearrangement`.

## Main declarations

* `monovary f g`: `f` monovaries with `g`. If `g i < g j`, then `f i ≤ f j`.
* `antivary f g`: `f` antivaries with `g`. If `g i < g j`, then `f j ≤ f i`.
* `monovary_on f g s`: `f` monovaries with `g` on `s`.
* `monovary_on f g s`: `f` antivaries with `g` on `s`.
-/


open Function Set

variable {ι ι' α β γ : Type _}

section Preorderₓ

variable [Preorderₓ α] [Preorderₓ β] {f : ι → α} {g : ι → β} {s t : Set ι}

/-- `f` monovaries with `g` if `g i < g j` implies `f i ≤ f j`. -/
def Monovary (f : ι → α) (g : ι → β) : Prop :=
  ∀ ⦃i j⦄, g i < g j → f i ≤ f j

/-- `f` antivaries with `g` if `g i < g j` implies `f j ≤ f i`. -/
def Antivary (f : ι → α) (g : ι → β) : Prop :=
  ∀ ⦃i j⦄, g i < g j → f j ≤ f i

/-- `f` monovaries with `g` on `s` if `g i < g j` implies `f i ≤ f j` for all `i, j ∈ s`. -/
def MonovaryOn (f : ι → α) (g : ι → β) (s : Set ι) : Prop :=
  ∀ ⦃i⦄ hi : i ∈ s ⦃j⦄ hj : j ∈ s, g i < g j → f i ≤ f j

/-- `f` antivaries with `g` on `s` if `g i < g j` implies `f j ≤ f i` for all `i, j ∈ s`. -/
def AntivaryOn (f : ι → α) (g : ι → β) (s : Set ι) : Prop :=
  ∀ ⦃i⦄ hi : i ∈ s ⦃j⦄ hj : j ∈ s, g i < g j → f j ≤ f i

protected theorem Monovary.monovary_on (h : Monovary f g) (s : Set ι) : MonovaryOn f g s := fun i j _ _ hij => h hij

protected theorem Antivary.antivary_on (h : Antivary f g) (s : Set ι) : AntivaryOn f g s := fun i j _ _ hij => h hij

@[simp]
theorem monovary_on_univ : MonovaryOn f g univ ↔ Monovary f g :=
  ⟨fun h i j => h trivialₓ trivialₓ, fun h i j _ _ hij => h hij⟩

@[simp]
theorem antivary_on_univ : AntivaryOn f g univ ↔ Antivary f g :=
  ⟨fun h i j => h trivialₓ trivialₓ, fun h i j _ _ hij => h hij⟩

protected theorem MonovaryOn.subset (hst : s ⊆ t) (h : MonovaryOn f g t) : MonovaryOn f g s := fun i hi j hj =>
  h (hst hi) (hst hj)

protected theorem AntivaryOn.subset (hst : s ⊆ t) (h : AntivaryOn f g t) : AntivaryOn f g s := fun i hi j hj =>
  h (hst hi) (hst hj)

theorem monovary_const_left (g : ι → β) (a : α) : Monovary (const ι a) g := fun i j _ => le_rfl

theorem antivary_const_left (g : ι → β) (a : α) : Antivary (const ι a) g := fun i j _ => le_rfl

theorem monovary_const_right (f : ι → α) (b : β) : Monovary f (const ι b) := fun i j h => (h.ne rfl).elim

theorem antivary_const_right (f : ι → α) (b : β) : Antivary f (const ι b) := fun i j h => (h.ne rfl).elim

theorem monovary_self (f : ι → α) : Monovary f f := fun i j => le_of_ltₓ

theorem monovary_on_self (f : ι → α) (s : Set ι) : MonovaryOn f f s := fun i j _ _ => le_of_ltₓ

theorem Subsingleton.monovary [Subsingleton ι] (f : ι → α) (g : ι → β) : Monovary f g := fun i j h =>
  (ne_of_apply_ne _ h.ne $ Subsingleton.elimₓ _ _).elim

theorem Subsingleton.antivary [Subsingleton ι] (f : ι → α) (g : ι → β) : Antivary f g := fun i j h =>
  (ne_of_apply_ne _ h.ne $ Subsingleton.elimₓ _ _).elim

theorem Subsingleton.monovary_on [Subsingleton ι] (f : ι → α) (g : ι → β) (s : Set ι) : MonovaryOn f g s :=
  fun i j _ _ h => (ne_of_apply_ne _ h.ne $ Subsingleton.elimₓ _ _).elim

theorem Subsingleton.antivary_on [Subsingleton ι] (f : ι → α) (g : ι → β) (s : Set ι) : AntivaryOn f g s :=
  fun i j _ _ h => (ne_of_apply_ne _ h.ne $ Subsingleton.elimₓ _ _).elim

theorem monovary_on_const_left (g : ι → β) (a : α) (s : Set ι) : MonovaryOn (const ι a) g s := fun i j _ _ _ => le_rfl

theorem antivary_on_const_left (g : ι → β) (a : α) (s : Set ι) : AntivaryOn (const ι a) g s := fun i j _ _ _ => le_rfl

theorem monovary_on_const_right (f : ι → α) (b : β) (s : Set ι) : MonovaryOn f (const ι b) s := fun i j _ _ h =>
  (h.ne rfl).elim

theorem antivary_on_const_right (f : ι → α) (b : β) (s : Set ι) : AntivaryOn f (const ι b) s := fun i j _ _ h =>
  (h.ne rfl).elim

theorem Monovary.comp_right (h : Monovary f g) (k : ι' → ι) : Monovary (f ∘ k) (g ∘ k) := fun i j hij => h hij

theorem Antivary.comp_right (h : Antivary f g) (k : ι' → ι) : Antivary (f ∘ k) (g ∘ k) := fun i j hij => h hij

section OrderDual

open OrderDual

theorem Monovary.dual (h : Monovary f g) : Monovary (to_dual ∘ f) (to_dual ∘ g) := fun i j hij => h hij

theorem Antivary.dual (h : Antivary f g) : Antivary (to_dual ∘ f) (to_dual ∘ g) := fun i j hij => h hij

theorem Monovary.dual_left (h : Monovary f g) : Antivary (to_dual ∘ f) g := fun i j hij => h hij

theorem Antivary.dual_left (h : Antivary f g) : Monovary (to_dual ∘ f) g := fun i j hij => h hij

theorem Monovary.dual_right (h : Monovary f g) : Antivary f (to_dual ∘ g) := fun i j hij => h hij

theorem Antivary.dual_right (h : Antivary f g) : Monovary f (to_dual ∘ g) := fun i j hij => h hij

theorem MonovaryOn.dual (h : MonovaryOn f g s) : MonovaryOn (to_dual ∘ f) (to_dual ∘ g) s := fun i hi j hj => h hj hi

theorem AntivaryOn.dual (h : AntivaryOn f g s) : AntivaryOn (to_dual ∘ f) (to_dual ∘ g) s := fun i hi j hj => h hj hi

theorem MonovaryOn.dual_left (h : MonovaryOn f g s) : AntivaryOn (to_dual ∘ f) g s :=
  h

theorem AntivaryOn.dual_left (h : AntivaryOn f g s) : MonovaryOn (to_dual ∘ f) g s :=
  h

theorem MonovaryOn.dual_right (h : MonovaryOn f g s) : AntivaryOn f (to_dual ∘ g) s :=
  h.dual

theorem AntivaryOn.dual_right (h : AntivaryOn f g s) : MonovaryOn f (to_dual ∘ g) s :=
  h.dual

end OrderDual

section PartialOrderₓ

variable [PartialOrderₓ ι]

@[simp]
theorem monovary_id_iff : Monovary f id ↔ Monotone f :=
  monotone_iff_forall_lt.symm

@[simp]
theorem antivary_id_iff : Antivary f id ↔ Antitone f :=
  antitone_iff_forall_lt.symm

@[simp]
theorem monovary_on_id_iff : MonovaryOn f id s ↔ MonotoneOn f s :=
  monotone_on_iff_forall_lt.symm

@[simp]
theorem antivary_on_id_iff : AntivaryOn f id s ↔ AntitoneOn f s :=
  antitone_on_iff_forall_lt.symm

end PartialOrderₓ

variable [LinearOrderₓ ι]

protected theorem Monotone.monovary (hf : Monotone f) (hg : Monotone g) : Monovary f g := fun i j hij =>
  hf (hg.reflect_lt hij).le

protected theorem Monotone.antivary (hf : Monotone f) (hg : Antitone g) : Antivary f g :=
  (hf.monovary hg.dual_right).dual_right

protected theorem Antitone.monovary (hf : Antitone f) (hg : Antitone g) : Monovary f g :=
  (hf.dual_right.antivary hg).dual_left

protected theorem Antitone.antivary (hf : Antitone f) (hg : Monotone g) : Antivary f g :=
  (hf.monovary hg.dual_right).dual_right

protected theorem MonotoneOn.monovary_on (hf : MonotoneOn f s) (hg : MonotoneOn g s) : MonovaryOn f g s :=
  fun i hi j hj hij => hf hi hj (hg.reflect_lt hi hj hij).le

protected theorem MonotoneOn.antivary_on (hf : MonotoneOn f s) (hg : AntitoneOn g s) : AntivaryOn f g s :=
  (hf.monovary_on hg.dual_right).dual_right

protected theorem AntitoneOn.monovary_on (hf : AntitoneOn f s) (hg : AntitoneOn g s) : MonovaryOn f g s :=
  (hf.dual_right.antivary_on hg).dual_left

protected theorem AntitoneOn.antivary_on (hf : AntitoneOn f s) (hg : MonotoneOn g s) : AntivaryOn f g s :=
  (hf.monovary_on hg.dual_right).dual_right

end Preorderₓ

section LinearOrderₓ

variable [Preorderₓ α] [LinearOrderₓ β] {f : ι → α} {g : ι → β} {s : Set ι}

protected theorem Monovary.symm (h : Monovary f g) : Monovary g f := fun i j hf =>
  le_of_not_ltₓ $ fun hg => hf.not_le $ h hg

protected theorem Antivary.symm (h : Antivary f g) : Antivary g f := fun i j hf =>
  le_of_not_ltₓ $ fun hg => hf.not_le $ h hg

protected theorem MonovaryOn.symm (h : MonovaryOn f g s) : MonovaryOn g f s := fun i hi j hj hf =>
  le_of_not_ltₓ $ fun hg => hf.not_le $ h hj hi hg

protected theorem AntivaryOn.symm (h : AntivaryOn f g s) : AntivaryOn g f s := fun i hi j hj hf =>
  le_of_not_ltₓ $ fun hg => hf.not_le $ h hi hj hg

end LinearOrderₓ

section LinearOrderₓ

variable [LinearOrderₓ α] [LinearOrderₓ β] {f : ι → α} {g : ι → β} {s : Set ι}

protected theorem monovary_comm : Monovary f g ↔ Monovary g f :=
  ⟨Monovary.symm, Monovary.symm⟩

protected theorem antivary_comm : Antivary f g ↔ Antivary g f :=
  ⟨Antivary.symm, Antivary.symm⟩

protected theorem monovary_on_comm : MonovaryOn f g s ↔ MonovaryOn g f s :=
  ⟨MonovaryOn.symm, MonovaryOn.symm⟩

protected theorem antivary_on_comm : AntivaryOn f g s ↔ AntivaryOn g f s :=
  ⟨AntivaryOn.symm, AntivaryOn.symm⟩

end LinearOrderₓ

