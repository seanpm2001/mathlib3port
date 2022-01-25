import Mathbin.SetTheory.Pgame
import Mathbin.Tactic.Abel

/-!
# Combinatorial games.

In this file we define the quotient of pre-games by the equivalence relation `p ≈ q ↔ p ≤ q ∧ q ≤
p`, and construct an instance `add_comm_group game`, as well as an instance `partial_order game`
(although note carefully the warning that the `<` field in this instance is not the usual relation
on combinatorial games).

## Multiplication on pre-games

We define the operations of multiplication and inverse on pre-games, and prove a few basic theorems
about them. Multiplication is not well-behaved under equivalence of pre-games i.e. `x.equiv y` does
not imply `(x*z).equiv (y*z)`. Hence, multiplication is not a well-defined operation on games.
Nevertheless, the abelian group structure on games allows us to simplify many proofs for pre-games.
-/


universe u

local infixl:0 " ≈ " => Pgame.Equiv

instance Pgame.setoid : Setoidₓ Pgame :=
  ⟨fun x y => x ≈ y, fun x => Pgame.equiv_refl _, fun x y => Pgame.equiv_symm, fun x y z => Pgame.equiv_trans⟩

/-- The type of combinatorial games. In ZFC, a combinatorial game is constructed from
  two sets of combinatorial games that have been constructed at an earlier
  stage. To do this in type theory, we say that a combinatorial pre-game is built
  inductively from two families of combinatorial games indexed over any type
  in Type u. The resulting type `pgame.{u}` lives in `Type (u+1)`,
  reflecting that it is a proper class in ZFC.
  A combinatorial game is then constructed by quotienting by the equivalence
  `x ≈ y ↔ x ≤ y ∧ y ≤ x`. -/
abbrev Game :=
  Quotientₓ Pgame.setoid

open Pgame

namespace Game

/-- The relation `x ≤ y` on games. -/
def le : Game → Game → Prop :=
  Quotientₓ.lift₂ (fun x y => x ≤ y) fun x₁ y₁ x₂ y₂ hx hy => propext (le_congr hx hy)

instance : LE Game where
  le := le

theorem le_reflₓ : ∀ x : Game, x ≤ x := by
  rintro ⟨x⟩
  apply Pgame.le_refl

theorem le_transₓ : ∀ x y z : Game, x ≤ y → y ≤ z → x ≤ z := by
  rintro ⟨x⟩ ⟨y⟩ ⟨z⟩
  apply Pgame.le_trans

theorem le_antisymmₓ : ∀ x y : Game, x ≤ y → y ≤ x → x = y := by
  rintro ⟨x⟩ ⟨y⟩ h₁ h₂
  apply Quot.sound
  exact ⟨h₁, h₂⟩

/-- The relation `x < y` on games. -/
def lt : Game → Game → Prop :=
  Quotientₓ.lift₂ (fun x y => x < y) fun x₁ y₁ x₂ y₂ hx hy => propext (lt_congr hx hy)

theorem not_leₓ : ∀ {x y : Game}, ¬x ≤ y ↔ lt y x := by
  rintro ⟨x⟩ ⟨y⟩
  exact not_leₓ

instance : Zero Game :=
  ⟨⟦0⟧⟩

instance : Inhabited Game :=
  ⟨0⟩

instance : One Game :=
  ⟨⟦1⟧⟩

/-- The negation of `{L | R}` is `{-R | -L}`. -/
def neg : Game → Game :=
  Quot.lift (fun x => ⟦-x⟧) fun x y h => Quot.sound (@neg_congr x y h)

instance : Neg Game where
  neg := neg

/-- The sum of `x = {xL | xR}` and `y = {yL | yR}` is `{xL + y, x + yL | xR + y, x + yR}`. -/
def add : Game → Game → Game :=
  Quotientₓ.lift₂ (fun x y : Pgame => ⟦x + y⟧) fun x₁ y₁ x₂ y₂ hx hy => Quot.sound (Pgame.add_congr hx hy)

instance : Add Game :=
  ⟨add⟩

theorem add_assocₓ : ∀ x y z : Game, x + y + z = x + (y + z) := by
  rintro ⟨x⟩ ⟨y⟩ ⟨z⟩
  apply Quot.sound
  exact add_assoc_equiv

instance : AddSemigroupₓ Game.{u} :=
  { Game.hasAdd with add_assoc := add_assocₓ }

theorem add_zeroₓ : ∀ x : Game, x + 0 = x := by
  rintro ⟨x⟩
  apply Quot.sound
  apply add_zero_equiv

theorem zero_addₓ : ∀ x : Game, 0 + x = x := by
  rintro ⟨x⟩
  apply Quot.sound
  apply zero_add_equiv

instance : AddMonoidₓ Game :=
  { Game.hasZero, Game.addSemigroup with add_zero := add_zeroₓ, zero_add := zero_addₓ }

theorem add_left_negₓ : ∀ x : Game, -x + x = 0 := by
  rintro ⟨x⟩
  apply Quot.sound
  apply add_left_neg_equiv

instance : AddGroupₓ Game :=
  { Game.hasNeg, Game.addMonoid with add_left_neg := add_left_negₓ }

theorem add_commₓ : ∀ x y : Game, x + y = y + x := by
  rintro ⟨x⟩ ⟨y⟩
  apply Quot.sound
  exact add_comm_equiv

instance : AddCommSemigroupₓ Game :=
  { Game.addSemigroup with add_comm := add_commₓ }

instance : AddCommGroupₓ Game :=
  { Game.addCommSemigroup, Game.addGroup with }

theorem add_le_add_left : ∀ a b : Game, a ≤ b → ∀ c : Game, c + a ≤ c + b := by
  rintro ⟨a⟩ ⟨b⟩ h ⟨c⟩
  apply Pgame.add_le_add_left h

/-- The `<` operation provided by this partial order is not the usual `<` on games! -/
def game_partial_order : PartialOrderₓ Game :=
  { Game.hasLe with le_refl := le_reflₓ, le_trans := le_transₓ, le_antisymm := le_antisymmₓ }

/-- The `<` operation provided by this `ordered_add_comm_group` is not the usual `<` on games! -/
def ordered_add_comm_group_game : OrderedAddCommGroup Game :=
  { Game.addCommGroup, game_partial_order with add_le_add_left := add_le_add_left }

end Game

namespace Pgame

@[simp]
theorem quot_neg (a : Pgame) : ⟦-a⟧ = -⟦a⟧ :=
  rfl

@[simp]
theorem quot_add (a b : Pgame) : ⟦a + b⟧ = ⟦a⟧ + ⟦b⟧ :=
  rfl

@[simp]
theorem quot_sub (a b : Pgame) : ⟦a - b⟧ = ⟦a⟧ - ⟦b⟧ :=
  rfl

theorem quot_eq_of_mk_quot_eq {x y : Pgame} (L : x.left_moves ≃ y.left_moves) (R : x.right_moves ≃ y.right_moves)
    (hl : ∀ i : x.left_moves, ⟦x.move_left i⟧ = ⟦y.move_left (L i)⟧)
    (hr : ∀ j : y.right_moves, ⟦x.move_right (R.symm j)⟧ = ⟦y.move_right j⟧) : ⟦x⟧ = ⟦y⟧ := by
  simp only [Quotientₓ.eq] at hl hr
  apply Quotientₓ.sound
  apply equiv_of_mk_equiv L R hl hr

/-! Multiplicative operations can be defined at the level of pre-games,
but to prove their properties we need to use the abelian group structure of games.
Hence we define them here. -/


/-- The product of `x = {xL | xR}` and `y = {yL | yR}` is
`{xL*y + x*yL - xL*yL, xR*y + x*yR - xR*yR | xL*y + x*yR - xL*yR, x*yL + xR*y - xR*yL }`. -/
def mul (x y : Pgame) : Pgame := by
  induction' x with xl xr xL xR IHxl IHxr generalizing y
  induction' y with yl yr yL yR IHyl IHyr
  have y := mk yl yr yL yR
  refine' ⟨Sum (xl × yl) (xr × yr), Sum (xl × yr) (xr × yl), _, _⟩ <;> rintro (⟨i, j⟩ | ⟨i, j⟩)
  · exact IHxl i y + IHyl j - IHxl i (yL j)
    
  · exact IHxr i y + IHyr j - IHxr i (yR j)
    
  · exact IHxl i y + IHyr j - IHxl i (yR j)
    
  · exact IHxr i y + IHyl j - IHxr i (yL j)
    

instance : Mul Pgame :=
  ⟨mul⟩

/-- An explicit description of the moves for Left in `x * y`. -/
def left_moves_mul (x y : Pgame) :
    (x * y).LeftMoves ≃ Sum (x.left_moves × y.left_moves) (x.right_moves × y.right_moves) := by
  cases x
  cases y
  rfl

/-- An explicit description of the moves for Right in `x * y`. -/
def right_moves_mul (x y : Pgame) :
    (x * y).RightMoves ≃ Sum (x.left_moves × y.right_moves) (x.right_moves × y.left_moves) := by
  cases x
  cases y
  rfl

@[simp]
theorem mk_mul_move_left_inl {xl xr yl yr} {xL xR yL yR} {i j} :
    (mk xl xr xL xR * mk yl yr yL yR).moveLeft (Sum.inl (i, j)) =
      xL i * mk yl yr yL yR + mk xl xr xL xR * yL j - xL i * yL j :=
  rfl

@[simp]
theorem mul_move_left_inl {x y : Pgame} {i j} :
    (x * y).moveLeft ((left_moves_mul x y).symm (Sum.inl (i, j))) =
      x.move_left i * y + x * y.move_left j - x.move_left i * y.move_left j :=
  by
  cases x
  cases y
  rfl

@[simp]
theorem mk_mul_move_left_inr {xl xr yl yr} {xL xR yL yR} {i j} :
    (mk xl xr xL xR * mk yl yr yL yR).moveLeft (Sum.inr (i, j)) =
      xR i * mk yl yr yL yR + mk xl xr xL xR * yR j - xR i * yR j :=
  rfl

@[simp]
theorem mul_move_left_inr {x y : Pgame} {i j} :
    (x * y).moveLeft ((left_moves_mul x y).symm (Sum.inr (i, j))) =
      x.move_right i * y + x * y.move_right j - x.move_right i * y.move_right j :=
  by
  cases x
  cases y
  rfl

@[simp]
theorem mk_mul_move_right_inl {xl xr yl yr} {xL xR yL yR} {i j} :
    (mk xl xr xL xR * mk yl yr yL yR).moveRight (Sum.inl (i, j)) =
      xL i * mk yl yr yL yR + mk xl xr xL xR * yR j - xL i * yR j :=
  rfl

@[simp]
theorem mul_move_right_inl {x y : Pgame} {i j} :
    (x * y).moveRight ((right_moves_mul x y).symm (Sum.inl (i, j))) =
      x.move_left i * y + x * y.move_right j - x.move_left i * y.move_right j :=
  by
  cases x
  cases y
  rfl

@[simp]
theorem mk_mul_move_right_inr {xl xr yl yr} {xL xR yL yR} {i j} :
    (mk xl xr xL xR * mk yl yr yL yR).moveRight (Sum.inr (i, j)) =
      xR i * mk yl yr yL yR + mk xl xr xL xR * yL j - xR i * yL j :=
  rfl

@[simp]
theorem mul_move_right_inr {x y : Pgame} {i j} :
    (x * y).moveRight ((right_moves_mul x y).symm (Sum.inr (i, j))) =
      x.move_right i * y + x * y.move_left j - x.move_right i * y.move_left j :=
  by
  cases x
  cases y
  rfl

theorem quot_mul_comm : ∀ x y : Pgame.{u}, ⟦x * y⟧ = ⟦y * x⟧
  | mk xl xr xL xR, mk yl yr yL yR => by
    let x := mk xl xr xL xR
    let y := mk yl yr yL yR
    refine' quot_eq_of_mk_quot_eq _ _ _ _
    apply Equivₓ.sumCongr (Equivₓ.prodComm _ _) (Equivₓ.prodComm _ _)
    calc Sum (xl × yr) (xr × yl) ≃ Sum (xr × yl) (xl × yr) := Equivₓ.sumComm _ _ _ ≃ Sum (yl × xr) (yr × xl) :=
        Equivₓ.sumCongr (Equivₓ.prodComm _ _) (Equivₓ.prodComm _ _)
    · rintro (⟨i, j⟩ | ⟨i, j⟩)
      · change ⟦xL i * y⟧ + ⟦x * yL j⟧ - ⟦xL i * yL j⟧ = ⟦yL j * x⟧ + ⟦y * xL i⟧ - ⟦yL j * xL i⟧
        rw [quot_mul_comm (xL i) y, quot_mul_comm x (yL j), quot_mul_comm (xL i) (yL j)]
        abel
        
      · change ⟦xR i * y⟧ + ⟦x * yR j⟧ - ⟦xR i * yR j⟧ = ⟦yR j * x⟧ + ⟦y * xR i⟧ - ⟦yR j * xR i⟧
        rw [quot_mul_comm (xR i) y, quot_mul_comm x (yR j), quot_mul_comm (xR i) (yR j)]
        abel
        
      
    · rintro (⟨j, i⟩ | ⟨j, i⟩)
      · change ⟦xR i * y⟧ + ⟦x * yL j⟧ - ⟦xR i * yL j⟧ = ⟦yL j * x⟧ + ⟦y * xR i⟧ - ⟦yL j * xR i⟧
        rw [quot_mul_comm (xR i) y, quot_mul_comm x (yL j), quot_mul_comm (xR i) (yL j)]
        abel
        
      · change ⟦xL i * y⟧ + ⟦x * yR j⟧ - ⟦xL i * yR j⟧ = ⟦yR j * x⟧ + ⟦y * xL i⟧ - ⟦yR j * xL i⟧
        rw [quot_mul_comm (xL i) y, quot_mul_comm x (yR j), quot_mul_comm (xL i) (yR j)]
        abel
        
      

/-- `x * y` is equivalent to `y * x`. -/
theorem mul_comm_equiv (x y : Pgame) : x * y ≈ y * x :=
  Quotientₓ.exact $ quot_mul_comm _ _

/-- `x * 0` has exactly the same moves as `0`. -/
def mul_zero_relabelling : ∀ x : Pgame, relabelling (x * 0) 0
  | mk xl xr xL xR =>
    ⟨by
      fconstructor <;> rintro (⟨_, ⟨⟩⟩ | ⟨_, ⟨⟩⟩), by
      fconstructor <;> rintro (⟨_, ⟨⟩⟩ | ⟨_, ⟨⟩⟩), by
      rintro (⟨_, ⟨⟩⟩ | ⟨_, ⟨⟩⟩), by
      rintro ⟨⟩⟩

/-- `x * 0` is equivalent to `0`. -/
theorem mul_zero_equiv (x : Pgame) : x * 0 ≈ 0 :=
  (mul_zero_relabelling x).Equiv

@[simp]
theorem quot_mul_zero (x : Pgame) : ⟦x * 0⟧ = ⟦0⟧ :=
  @Quotientₓ.sound _ _ (x * 0) _ x.mul_zero_equiv

/-- `0 * x` has exactly the same moves as `0`. -/
def zero_mul_relabelling : ∀ x : Pgame, relabelling (0 * x) 0
  | mk xl xr xL xR =>
    ⟨by
      fconstructor <;> rintro (⟨⟨⟩, _⟩ | ⟨⟨⟩, _⟩), by
      fconstructor <;> rintro (⟨⟨⟩, _⟩ | ⟨⟨⟩, _⟩), by
      rintro (⟨⟨⟩, _⟩ | ⟨⟨⟩, _⟩), by
      rintro ⟨⟩⟩

/-- `0 * x` is equivalent to `0`. -/
theorem zero_mul_equiv (x : Pgame) : 0 * x ≈ 0 :=
  (zero_mul_relabelling x).Equiv

@[simp]
theorem quot_zero_mul (x : Pgame) : ⟦0 * x⟧ = ⟦0⟧ :=
  @Quotientₓ.sound _ _ (0 * x) _ x.zero_mul_equiv

@[simp]
theorem quot_neg_mul : ∀ x y : Pgame, ⟦-x * y⟧ = -⟦x * y⟧
  | mk xl xr xL xR, mk yl yr yL yR => by
    let x := mk xl xr xL xR
    let y := mk yl yr yL yR
    refine' quot_eq_of_mk_quot_eq _ _ _ _
    · fconstructor <;>
        rintro (⟨_, _⟩ | ⟨_, _⟩) <;> solve_by_elim(config := { max_depth := 4 }) [Sum.inl, Sum.inr, Prod.mk]
      
    · fconstructor <;>
        rintro (⟨_, _⟩ | ⟨_, _⟩) <;> solve_by_elim(config := { max_depth := 4 }) [Sum.inl, Sum.inr, Prod.mk]
      
    · rintro (⟨i, j⟩ | ⟨i, j⟩)
      · change ⟦-xR i * y + -x * yL j - -xR i * yL j⟧ = ⟦-(xR i * y + x * yL j - xR i * yL j)⟧
        simp only [quot_add, quot_sub, quot_neg_mul]
        simp
        abel
        
      · change ⟦-xL i * y + -x * yR j - -xL i * yR j⟧ = ⟦-(xL i * y + x * yR j - xL i * yR j)⟧
        simp only [quot_add, quot_sub, quot_neg_mul]
        simp
        abel
        
      
    · rintro (⟨i, j⟩ | ⟨i, j⟩)
      · change ⟦-xL i * y + -x * yL j - -xL i * yL j⟧ = ⟦-(xL i * y + x * yL j - xL i * yL j)⟧
        simp only [quot_add, quot_sub, quot_neg_mul]
        simp
        abel
        
      · change ⟦-xR i * y + -x * yR j - -xR i * yR j⟧ = ⟦-(xR i * y + x * yR j - xR i * yR j)⟧
        simp only [quot_add, quot_sub, quot_neg_mul]
        simp
        abel
        
      

@[simp]
theorem quot_mul_neg (x y : Pgame) : ⟦x * -y⟧ = -⟦x * y⟧ := by
  rw [quot_mul_comm, quot_neg_mul, quot_mul_comm]

@[simp]
theorem quot_left_distrib : ∀ x y z : Pgame, ⟦x * (y + z)⟧ = ⟦x * y⟧ + ⟦x * z⟧
  | mk xl xr xL xR, mk yl yr yL yR, mk zl zr zL zR => by
    let x := mk xl xr xL xR
    let y := mk yl yr yL yR
    let z := mk zl zr zL zR
    refine' quot_eq_of_mk_quot_eq _ _ _ _
    · fconstructor
      · rintro (⟨_, _ | _⟩ | ⟨_, _ | _⟩) <;> solve_by_elim(config := { max_depth := 5 }) [Sum.inl, Sum.inr, Prod.mk]
        
      · rintro (⟨⟨_, _⟩ | ⟨_, _⟩⟩ | ⟨_, _⟩ | ⟨_, _⟩) <;>
          solve_by_elim(config := { max_depth := 5 }) [Sum.inl, Sum.inr, Prod.mk]
        
      · rintro (⟨_, _ | _⟩ | ⟨_, _ | _⟩) <;> rfl
        
      · rintro (⟨⟨_, _⟩ | ⟨_, _⟩⟩ | ⟨_, _⟩ | ⟨_, _⟩) <;> rfl
        
      
    · fconstructor
      · rintro (⟨_, _ | _⟩ | ⟨_, _ | _⟩) <;> solve_by_elim(config := { max_depth := 5 }) [Sum.inl, Sum.inr, Prod.mk]
        
      · rintro (⟨⟨_, _⟩ | ⟨_, _⟩⟩ | ⟨_, _⟩ | ⟨_, _⟩) <;>
          solve_by_elim(config := { max_depth := 5 }) [Sum.inl, Sum.inr, Prod.mk]
        
      · rintro (⟨_, _ | _⟩ | ⟨_, _ | _⟩) <;> rfl
        
      · rintro (⟨⟨_, _⟩ | ⟨_, _⟩⟩ | ⟨_, _⟩ | ⟨_, _⟩) <;> rfl
        
      
    · rintro (⟨i, j | k⟩ | ⟨i, j | k⟩)
      · change ⟦xL i * (y + z) + x * (yL j + z) - xL i * (yL j + z)⟧ = ⟦xL i * y + x * yL j - xL i * yL j + x * z⟧
        simp [quot_left_distrib]
        abel
        
      · change ⟦xL i * (y + z) + x * (y + zL k) - xL i * (y + zL k)⟧ = ⟦x * y + (xL i * z + x * zL k - xL i * zL k)⟧
        simp [quot_left_distrib]
        abel
        
      · change ⟦xR i * (y + z) + x * (yR j + z) - xR i * (yR j + z)⟧ = ⟦xR i * y + x * yR j - xR i * yR j + x * z⟧
        simp [quot_left_distrib]
        abel
        
      · change ⟦xR i * (y + z) + x * (y + zR k) - xR i * (y + zR k)⟧ = ⟦x * y + (xR i * z + x * zR k - xR i * zR k)⟧
        simp [quot_left_distrib]
        abel
        
      
    · rintro (⟨⟨i, j⟩ | ⟨i, j⟩⟩ | ⟨i, k⟩ | ⟨i, k⟩)
      · change ⟦xL i * (y + z) + x * (yR j + z) - xL i * (yR j + z)⟧ = ⟦xL i * y + x * yR j - xL i * yR j + x * z⟧
        simp [quot_left_distrib]
        abel
        
      · change ⟦xR i * (y + z) + x * (yL j + z) - xR i * (yL j + z)⟧ = ⟦xR i * y + x * yL j - xR i * yL j + x * z⟧
        simp [quot_left_distrib]
        abel
        
      · change ⟦xL i * (y + z) + x * (y + zR k) - xL i * (y + zR k)⟧ = ⟦x * y + (xL i * z + x * zR k - xL i * zR k)⟧
        simp [quot_left_distrib]
        abel
        
      · change ⟦xR i * (y + z) + x * (y + zL k) - xR i * (y + zL k)⟧ = ⟦x * y + (xR i * z + x * zL k - xR i * zL k)⟧
        simp [quot_left_distrib]
        abel
        
      

/-- `x * (y + z)` is equivalent to `x * y + x * z.`-/
theorem left_distrib_equiv (x y z : Pgame) : x * (y + z) ≈ x * y + x * z :=
  Quotientₓ.exact $ quot_left_distrib _ _ _

@[simp]
theorem quot_left_distrib_sub (x y z : Pgame) : ⟦x * (y - z)⟧ = ⟦x * y⟧ - ⟦x * z⟧ := by
  change ⟦x * (y + -z)⟧ = ⟦x * y⟧ + -⟦x * z⟧
  rw [quot_left_distrib, quot_mul_neg]

@[simp]
theorem quot_right_distrib (x y z : Pgame) : ⟦(x + y) * z⟧ = ⟦x * z⟧ + ⟦y * z⟧ := by
  simp only [quot_mul_comm, quot_left_distrib]

/-- `(x + y) * z` is equivalent to `x * z + y * z.`-/
theorem right_distrib_equiv (x y z : Pgame) : (x + y) * z ≈ x * z + y * z :=
  Quotientₓ.exact $ quot_right_distrib _ _ _

@[simp]
theorem quot_right_distrib_sub (x y z : Pgame) : ⟦(y - z) * x⟧ = ⟦y * x⟧ - ⟦z * x⟧ := by
  change ⟦(y + -z) * x⟧ = ⟦y * x⟧ + -⟦z * x⟧
  rw [quot_right_distrib, quot_neg_mul]

@[simp]
theorem quot_mul_one : ∀ x : Pgame, ⟦x * 1⟧ = ⟦x⟧
  | mk xl xr xL xR => by
    let x := mk xl xr xL xR
    refine' quot_eq_of_mk_quot_eq _ _ _ _
    · fconstructor
      · rintro (⟨_, ⟨⟩⟩ | ⟨_, ⟨⟩⟩)
        assumption
        
      · rintro i
        exact Sum.inl (i, PUnit.unit)
        
      · rintro (⟨_, ⟨⟩⟩ | ⟨_, ⟨⟩⟩)
        rfl
        
      · rintro i
        rfl
        
      
    · fconstructor
      · rintro (⟨_, ⟨⟩⟩ | ⟨_, ⟨⟩⟩)
        assumption
        
      · rintro i
        exact Sum.inr (i, PUnit.unit)
        
      · rintro (⟨_, ⟨⟩⟩ | ⟨_, ⟨⟩⟩)
        rfl
        
      · rintro i
        rfl
        
      
    · rintro (⟨i, ⟨⟩⟩ | ⟨i, ⟨⟩⟩)
      change ⟦xL i * 1 + x * 0 - xL i * 0⟧ = ⟦xL i⟧
      simp [quot_mul_one]
      
    · rintro i
      change ⟦xR i * 1 + x * 0 - xR i * 0⟧ = ⟦xR i⟧
      simp [quot_mul_one]
      

/-- `x * 1` is equivalent to `x`. -/
theorem mul_one_equiv (x : Pgame) : x * 1 ≈ x :=
  Quotientₓ.exact $ quot_mul_one _

@[simp]
theorem quot_one_mul (x : Pgame) : ⟦1 * x⟧ = ⟦x⟧ := by
  rw [quot_mul_comm, quot_mul_one x]

/-- `1 * x` is equivalent to `x`. -/
theorem one_mul_equiv (x : Pgame) : 1 * x ≈ x :=
  Quotientₓ.exact $ quot_one_mul _

theorem quot_mul_assoc : ∀ x y z : Pgame, ⟦x * y * z⟧ = ⟦x * (y * z)⟧
  | mk xl xr xL xR, mk yl yr yL yR, mk zl zr zL zR => by
    let x := mk xl xr xL xR
    let y := mk yl yr yL yR
    let z := mk zl zr zL zR
    refine' quot_eq_of_mk_quot_eq _ _ _ _
    · fconstructor
      · rintro (⟨⟨_, _⟩ | ⟨_, _⟩, _⟩ | ⟨⟨_, _⟩ | ⟨_, _⟩, _⟩) <;>
          solve_by_elim(config := { max_depth := 7 }) [Sum.inl, Sum.inr, Prod.mk]
        
      · rintro (⟨_, ⟨_, _⟩ | ⟨_, _⟩⟩ | ⟨_, ⟨_, _⟩ | ⟨_, _⟩⟩) <;>
          solve_by_elim(config := { max_depth := 7 }) [Sum.inl, Sum.inr, Prod.mk]
        
      · rintro (⟨⟨_, _⟩ | ⟨_, _⟩, _⟩ | ⟨⟨_, _⟩ | ⟨_, _⟩, _⟩) <;> rfl
        
      · rintro (⟨_, ⟨_, _⟩ | ⟨_, _⟩⟩ | ⟨_, ⟨_, _⟩ | ⟨_, _⟩⟩) <;> rfl
        
      
    · fconstructor
      · rintro (⟨⟨_, _⟩ | ⟨_, _⟩, _⟩ | ⟨⟨_, _⟩ | ⟨_, _⟩, _⟩) <;>
          solve_by_elim(config := { max_depth := 7 }) [Sum.inl, Sum.inr, Prod.mk]
        
      · rintro (⟨_, ⟨_, _⟩ | ⟨_, _⟩⟩ | ⟨_, ⟨_, _⟩ | ⟨_, _⟩⟩) <;>
          solve_by_elim(config := { max_depth := 7 }) [Sum.inl, Sum.inr, Prod.mk]
        
      · rintro (⟨⟨_, _⟩ | ⟨_, _⟩, _⟩ | ⟨⟨_, _⟩ | ⟨_, _⟩, _⟩) <;> rfl
        
      · rintro (⟨_, ⟨_, _⟩ | ⟨_, _⟩⟩ | ⟨_, ⟨_, _⟩ | ⟨_, _⟩⟩) <;> rfl
        
      
    · rintro (⟨⟨i, j⟩ | ⟨i, j⟩, k⟩ | ⟨⟨i, j⟩ | ⟨i, j⟩, k⟩)
      · change
          ⟦(xL i * y + x * yL j - xL i * yL j) * z + x * y * zL k - (xL i * y + x * yL j - xL i * yL j) * zL k⟧ =
            ⟦xL i * (y * z) + x * (yL j * z + y * zL k - yL j * zL k) - xL i * (yL j * z + y * zL k - yL j * zL k)⟧
        simp [quot_mul_assoc]
        abel
        
      · change
          ⟦(xR i * y + x * yR j - xR i * yR j) * z + x * y * zL k - (xR i * y + x * yR j - xR i * yR j) * zL k⟧ =
            ⟦xR i * (y * z) + x * (yR j * z + y * zL k - yR j * zL k) - xR i * (yR j * z + y * zL k - yR j * zL k)⟧
        simp [quot_mul_assoc]
        abel
        
      · change
          ⟦(xL i * y + x * yR j - xL i * yR j) * z + x * y * zR k - (xL i * y + x * yR j - xL i * yR j) * zR k⟧ =
            ⟦xL i * (y * z) + x * (yR j * z + y * zR k - yR j * zR k) - xL i * (yR j * z + y * zR k - yR j * zR k)⟧
        simp [quot_mul_assoc]
        abel
        
      · change
          ⟦(xR i * y + x * yL j - xR i * yL j) * z + x * y * zR k - (xR i * y + x * yL j - xR i * yL j) * zR k⟧ =
            ⟦xR i * (y * z) + x * (yL j * z + y * zR k - yL j * zR k) - xR i * (yL j * z + y * zR k - yL j * zR k)⟧
        simp [quot_mul_assoc]
        abel
        
      
    · rintro (⟨i, ⟨j, k⟩ | ⟨j, k⟩⟩ | ⟨i, ⟨j, k⟩ | ⟨j, k⟩⟩)
      · change
          ⟦(xL i * y + x * yL j - xL i * yL j) * z + x * y * zR k - (xL i * y + x * yL j - xL i * yL j) * zR k⟧ =
            ⟦xL i * (y * z) + x * (yL j * z + y * zR k - yL j * zR k) - xL i * (yL j * z + y * zR k - yL j * zR k)⟧
        simp [quot_mul_assoc]
        abel
        
      · change
          ⟦(xL i * y + x * yR j - xL i * yR j) * z + x * y * zL k - (xL i * y + x * yR j - xL i * yR j) * zL k⟧ =
            ⟦xL i * (y * z) + x * (yR j * z + y * zL k - yR j * zL k) - xL i * (yR j * z + y * zL k - yR j * zL k)⟧
        simp [quot_mul_assoc]
        abel
        
      · change
          ⟦(xR i * y + x * yL j - xR i * yL j) * z + x * y * zL k - (xR i * y + x * yL j - xR i * yL j) * zL k⟧ =
            ⟦xR i * (y * z) + x * (yL j * z + y * zL k - yL j * zL k) - xR i * (yL j * z + y * zL k - yL j * zL k)⟧
        simp [quot_mul_assoc]
        abel
        
      · change
          ⟦(xR i * y + x * yR j - xR i * yR j) * z + x * y * zR k - (xR i * y + x * yR j - xR i * yR j) * zR k⟧ =
            ⟦xR i * (y * z) + x * (yR j * z + y * zR k - yR j * zR k) - xR i * (yR j * z + y * zR k - yR j * zR k)⟧
        simp [quot_mul_assoc]
        abel
        
      

/-- `x * y * z` is equivalent to `x * (y * z).`-/
theorem mul_assoc_equiv (x y z : Pgame) : x * y * z ≈ x * (y * z) :=
  Quotientₓ.exact $ quot_mul_assoc _ _ _

/-- Because the two halves of the definition of `inv` produce more elements
on each side, we have to define the two families inductively.
This is the indexing set for the function, and `inv_val` is the function part. -/
inductive inv_ty (l r : Type u) : Bool → Type u
  | zero : inv_ty ff
  | left₁ : r → inv_ty ff → inv_ty ff
  | left₂ : l → inv_ty tt → inv_ty ff
  | right₁ : l → inv_ty ff → inv_ty tt
  | right₂ : r → inv_ty tt → inv_ty tt

/-- Because the two halves of the definition of `inv` produce more elements
of each side, we have to define the two families inductively.
This is the function part, defined by recursion on `inv_ty`. -/
def inv_val {l r} (L : l → Pgame) (R : r → Pgame) (IHl : l → Pgame) (IHr : r → Pgame) : ∀ {b}, inv_ty l r b → Pgame
  | _, inv_ty.zero => 0
  | _, inv_ty.left₁ i j => (1 + (R i - mk l r L R) * inv_val j) * IHr i
  | _, inv_ty.left₂ i j => (1 + (L i - mk l r L R) * inv_val j) * IHl i
  | _, inv_ty.right₁ i j => (1 + (L i - mk l r L R) * inv_val j) * IHl i
  | _, inv_ty.right₂ i j => (1 + (R i - mk l r L R) * inv_val j) * IHr i

/-- The inverse of a positive surreal number `x = {L | R}` is
given by `x⁻¹ = {0,
  (1 + (R - x) * x⁻¹L) * R, (1 + (L - x) * x⁻¹R) * L |
  (1 + (L - x) * x⁻¹L) * L, (1 + (R - x) * x⁻¹R) * R}`.
Because the two halves `x⁻¹L, x⁻¹R` of `x⁻¹` are used in their own
definition, the sets and elements are inductively generated. -/
def inv' : Pgame → Pgame
  | ⟨l, r, L, R⟩ =>
    let l' := { i // 0 < L i }
    let L' : l' → Pgame := fun i => L i.1
    let IHl' : l' → Pgame := fun i => inv' (L i.1)
    let IHr := fun i => inv' (R i)
    ⟨inv_ty l' r ff, inv_ty l' r tt, inv_val L' R IHl' IHr, inv_val L' R IHl' IHr⟩

/-- The inverse of a surreal number in terms of the inverse on positive surreals. -/
noncomputable def inv (x : Pgame) : Pgame := by
  classical <;> exact if x = 0 then 0 else if 0 < x then inv' x else inv' (-x)

noncomputable instance : HasInv Pgame :=
  ⟨inv⟩

noncomputable instance : Div Pgame :=
  ⟨fun x y => x * y⁻¹⟩

end Pgame

