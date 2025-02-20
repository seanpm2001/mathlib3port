/-
Copyright (c) 2022 Abby J. Goldberg. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Abby J. Goldberg

! This file was ported from Lean 3 source module tactic.linear_combination
! leanprover-community/mathlib commit 540b766a64a8cc1e4b013f43a31e3b0b09787937
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Ring

/-!

# linear_combination Tactic
In this file, the `linear_combination` tactic is created.  This tactic, which
works over `ring`s, attempts to simplify the target by creating a linear combination
of a list of equalities and subtracting it from the target.  This file also includes a
definition for `linear_combination_config`.  A `linear_combination_config`
object can be passed into the tactic, allowing the user to specify a
normalization tactic.

## Implementation Notes

This tactic works by creating a weighted sum of the given equations with the
given coefficients.  Then, it subtracts the right side of the weighted sum
from the left side so that the right side equals 0, and it does the same with
the target.  Afterwards, it sets the goal to be the equality between the
lefthand side of the new goal and the lefthand side of the new weighted sum.
Lastly, calls a normalization tactic on this target.

## References

* <https://leanprover.zulipchat.com/#narrow/stream/239415-metaprogramming-.2F.20tactics/topic/Linear.20algebra.20tactic/near/213928196>

-/


namespace LinearCombo

open Tactic

/-! ### Lemmas -/


theorem left_mul_both_sides {α} [h : Mul α] {x y : α} (z : α) (h1 : x = y) : z * x = z * y :=
  congr_arg (Mul.mul z) h1
#align linear_combo.left_mul_both_sides LinearCombo.left_mul_both_sides

theorem sum_two_equations {α} [h : Add α] {x1 y1 x2 y2 : α} (h1 : x1 = y1) (h2 : x2 = y2) :
    x1 + x2 = y1 + y2 :=
  congr (congr_arg Add.add h1) h2
#align linear_combo.sum_two_equations LinearCombo.sum_two_equations

theorem left_minus_right {α} [h : AddGroup α] {x y : α} (h1 : x = y) : x - y = 0 :=
  sub_eq_zero.mpr h1
#align linear_combo.left_minus_right LinearCombo.left_minus_right

theorem all_on_left_equiv {α} [h : AddGroup α] (x y : α) : (x = y) = (x - y = 0) :=
  propext ⟨left_minus_right, sub_eq_zero.mp⟩
#align linear_combo.all_on_left_equiv LinearCombo.all_on_left_equiv

theorem replace_eq_expr {α} [h : Zero α] {x y : α} (h1 : x = 0) (h2 : y = x) : y = 0 := by rwa [h2]
#align linear_combo.replace_eq_expr LinearCombo.replace_eq_expr

theorem eq_zero_of_sub_eq_zero {α} [AddGroup α] {x y : α} (h : y = 0) (h2 : x - y = 0) : x = 0 := by
  rwa [h, sub_zero] at h2 
#align linear_combo.eq_zero_of_sub_eq_zero LinearCombo.eq_zero_of_sub_eq_zero

/-! ### Configuration -/


/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/-- A configuration object for `linear_combination`.

`normalize` describes whether or not the normalization step should be used.

`normalization_tactic` describes the tactic used for normalization when
checking if the weighted sum is equivalent to the goal (when `normalize` is `tt`).
-/
unsafe structure linear_combination_config : Type where
  normalize : Bool := true
  normalization_tactic : tactic Unit := sorry
  exponent : ℕ := 1
#align linear_combo.linear_combination_config linear_combo.linear_combination_config

/-! ### Part 1: Multiplying Equations by Constants and Adding Them Together -/


-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      Given that `lhs = rhs`, this tactic returns an `expr` proving that
        `coeff * lhs = coeff * rhs`.
      
      * Input:
        * `h_equality` : an `expr`, whose type should be an equality between terms of
            type `α`, where there is an instance of `has_mul α`
        * `coeff` : a `pexpr`, which should be a value of type `α`
      
      * Output: an `expr`, which proves that the result of multiplying both sides
          of `h_equality` by the `coeff` holds
      -/
    unsafe
  def
    mul_equality_expr
    ( h_equality : expr ) ( coeff : pexpr ) : tactic expr
    :=
      do
        let q( $ ( lhs ) = $ ( rhs ) ) ← infer_type h_equality
          let left_type ← infer_type lhs
          let coeff_expr ← to_expr ` `( ( $ ( coeff ) : $ ( left_type ) ) )
          mk_app ` ` left_mul_both_sides [ coeff_expr , h_equality ]
#align linear_combo.mul_equality_expr linear_combo.mul_equality_expr

/-- Given two hypotheses that `a = b` and `c = d`, this tactic returns an `expr` proving
  that `a + c = b + d`.

* Input:
  * `h_equality1` : an `expr`, whose type should be an equality between terms of
      type `α`, where there is an instance of `has_add α`
  * `h_equality2` : an `expr`, whose type should be an equality between terms of
      type `α`

* Output: an `expr`, which proves that the result of adding the two
    equalities holds
-/
unsafe def sum_equalities (h_equality1 h_equality2 : expr) : tactic expr :=
  mk_app `` sum_two_equations [h_equality1, h_equality2]
#align linear_combo.sum_equalities linear_combo.sum_equalities

/-- Given that `a = b` and `c = d`, along with a coefficient, this tactic returns an
  `expr` proving that `a + coeff * c = b + coeff * d`.

* Input:
  * `h_equality1` : an `expr`, whose type should be an equality between terms of
      type `α`, where there are instances of `has_add α` and `has_mul α`
  * `h_equality2` : an `expr`, whose type should be an equality between terms of
      type `α`
  * `coeff_for_eq2` : a `pexpr`, which should be a value of type `α`

* Output: an `expr`, which proves that the result of adding the first
  equality to the result of multiplying `coeff_for_eq2` by the second equality
  holds
-/
unsafe def sum_two_hyps_one_mul_helper (h_equality1 h_equality2 : expr) (coeff_for_eq2 : pexpr) :
    tactic expr :=
  mul_equality_expr h_equality2 coeff_for_eq2 >>= sum_equalities h_equality1
#align linear_combo.sum_two_hyps_one_mul_helper linear_combo.sum_two_hyps_one_mul_helper

/-- Given that `l_sum1 = r_sum1`, `l_h1 = r_h1`, ..., `l_hn = r_hn`, and given
  coefficients `c_1`, ..., `c_n`, this tactic returns an `expr` proving that
    `l_sum1 + (c_1 * l_h1) + ... + (c_n * l_hn)`
  `= r_sum1 + (c_1 * r_h1) + ... + (c_n * r_hn)`

* Input:
  * `expected_tp`: the type of the terms being compared in the target equality
  * an `option (tactic expr)` : `none`, if there is no sum to add to yet, or
      `some` containing the base summation equation
  * a `list name` : a list of names, referring to equalities in the local context
  * a `list pexpr` : a list of coefficients to be multiplied with the
      corresponding equalities in the list of names

* Output: an `expr`, which proves that the weighted sum of the given
    equalities added to the base equation holds
-/
unsafe def make_sum_of_hyps_helper (expected_tp : expr) :
    Option (tactic expr) → List expr → List pexpr → tactic expr
  | none, [], [] => to_expr ``((rfl : (0 : $(expected_tp)) = 0))
  | some tactic_hcombo, [], [] => do
    tactic_hcombo
  | none, h_equality :: h_eqs_names, coeff :: coeffs => do
    let-- This is the first equality, and we do not have anything to add to it
      -- h_equality ← get_local h_equality_nam,
      q(@Eq $(eqtp) _ _)
      ← infer_type h_equality |
      throwError "{← h_equality} is expected to be a proof of an equality"
    is_def_eq eqtp expected_tp <|>
        throwError
          "{(←
            h_equality)} is an equality between terms of type {(←
            eqtp)}, but is expected to be between terms of type {← expected_tp}"
    make_sum_of_hyps_helper (some (mul_equality_expr h_equality coeff)) h_eqs_names coeffs
  | some tactic_hcombo, h_equality :: h_eqs_names, coeff :: coeffs => do
    let hcombo
      ←-- h_equality ← get_local h_equality_nam,
        tactic_hcombo
    -- We want to add this weighted equality to the current equality in
        --   the hypothesis
        make_sum_of_hyps_helper
        (some (sum_two_hyps_one_mul_helper hcombo h_equality coeff)) h_eqs_names coeffs
  | _, _, _ => do
    fail
        ("The length of the input list of equalities should be the " ++
          "same as the length of the input list of coefficients")
#align linear_combo.make_sum_of_hyps_helper linear_combo.make_sum_of_hyps_helper

/-- Given a list of names referencing equalities and a list of pexprs representing
  coefficients, this tactic proves that a weighted sum of the equalities
  (where each equation is multiplied by the corresponding coefficient) holds.

* Input:
  * `expected_tp`: the type of the terms being compared in the target equality
  * `h_eqs_names` : a list of names, referring to equalities in the local
      context
  * `coeffs` : a list of coefficients to be multiplied with the corresponding
      equalities in the list of names

* Output: an `expr`, which proves that the weighted sum of the equalities
    holds
-/
unsafe def make_sum_of_hyps (expected_tp : expr) (h_eqs_names : List expr) (coeffs : List pexpr) :
    tactic expr :=
  make_sum_of_hyps_helper expected_tp none h_eqs_names coeffs
#align linear_combo.make_sum_of_hyps linear_combo.make_sum_of_hyps

/-! ### Part 2: Simplifying -/


/-- This tactic proves that the result of moving all the terms in an equality to
  the left side of the equals sign by subtracting the right side of the
  equation from the left side holds.  In other words, given `lhs = rhs`,
  this tactic proves that `lhs - rhs = 0`.

* Input:
  * `h_equality` : an `expr`, whose type should be an equality between terms of
      type `α`, where there is an instance of `add_group α`

* Output: an `expr`, which proves that `lhs - rhs = 0`, where `lhs` and `rhs` are
   the left and right sides of `h_equality` respectively
-/
unsafe def move_to_left_side (h_equality : expr) : tactic expr :=
  mk_app `` left_minus_right [h_equality]
#align linear_combo.move_to_left_side linear_combo.move_to_left_side

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      This tactic replaces the target with the result of moving all the terms in the
        target to the left side of the equals sign by subtracting the right side of
        the equation from the left side.  In other words, when the target is
        lhs = rhs, this tactic proves that `lhs - rhs = 0` and replaces the target
        with this new equality.
      Note: The target must be an equality when this tactic is called, and the
        equality must have some type `α` on each side, where there is an instance of
        `add_group α`.
      
      * Input: N/A
      
      * Output: N/A
      -/
    unsafe
  def
    move_target_to_left_side
    : tactic Unit
    :=
      do
        let target ← target
          let ( targ_lhs , targ_rhs ) ← match_eq target
          let target_left_eq ← to_expr ` `( $ ( targ_lhs ) - $ ( targ_rhs ) = 0 )
          mk_app ` ` all_on_left_equiv [ targ_lhs , targ_rhs ] >>= replace_target target_left_eq
#align linear_combo.move_target_to_left_side linear_combo.move_target_to_left_side

/-! ### Part 3: Matching the Linear Combination to the Target -/


/-- This tactic changes the goal to be that the lefthand side of the target minus the
  lefthand side of the given expression is equal to 0.  For example,
  if `hsum_on_left` is `5*x - 5*y = 0`, and the target is `-5*y + 5*x = 0`, this
  tactic will change the target to be `-5*y + 5*x - (5*x - 5*y) = 0`.

This tactic only should be used when the target's type is an equality whose
  right side is 0.

* Input:
  * `hsum_on_left` : expr, whose type should be an equality with 0 on the right
      side of the equals sign

* Output: N/A
-/
unsafe def set_goal_to_hleft_sub_tleft (hsum_on_left : expr) : tactic Unit := do
  to_expr ``(eq_zero_of_sub_eq_zero $(hsum_on_left)) >>= apply
  skip
#align linear_combo.set_goal_to_hleft_sub_tleft linear_combo.set_goal_to_hleft_sub_tleft

/-- If an exponent `n` is provided, changes the goal from `t = 0` to `t^n = 0`.
* Input:
  * `exponent : ℕ`, the power to raise the goal by. If `1`, this tactic is a no-op.

* Output: N/A
-/
unsafe def raise_goal_to_power : ℕ → tactic Unit
  | 1 => skip
  | n => refine ``(@pow_eq_zero _ _ _ _ $(q(n)) _)
#align linear_combo.raise_goal_to_power linear_combo.raise_goal_to_power

/-- This tactic attempts to prove the goal by normalizing the target if the
`normalize` field of the given configuration is true.

* Input:
  * `config` : a `linear_combination_config`, which determines the tactic used
      for normalization if normalization is done

* Output: N/A
-/
unsafe def normalize_if_desired (config : linear_combination_config) : tactic Unit :=
  when config.normalize config.normalization_tactic
#align linear_combo.normalize_if_desired linear_combo.normalize_if_desired

/-! ### Part 4: Completed Tactic -/


/-- This is a tactic that attempts to simplify the target by creating a linear combination
  of a list of equalities and subtracting it from the target.
  (If the `normalize` field of the
  configuration is set to ff, then the tactic will simply set the user up to
  prove their target using the linear combination instead of normalizing the subtraction.)

Note: The left and right sides of all the equalities should have the same
  ring type, and the coefficients should also have this type.  There must be
  instances of `has_mul` and `add_group` for this type.  Also note that the
  target must involve at least one variable.

* Input:
  * `h_eqs_names` : a list of names, referring to equations in the local
      context
  * `coeffs` : a list of coefficients to be multiplied with the corresponding
    equations in the list of names
  * `config` : a `linear_combination_config`, which determines the tactic used
      for normalization; by default, this value is the standard configuration
      for a `linear_combination_config`

* Output: N/A
-/
unsafe def linear_combination (h_eqs_names : List pexpr) (coeffs : List pexpr)
    (config : linear_combination_config := { }) : tactic Unit := do
  let q(@Eq $(ext) _ _) ← target |
    fail "linear_combination can only be used to prove equality goals"
  let h_eqs ← h_eqs_names.mapM to_expr
  let hsum ← make_sum_of_hyps ext h_eqs coeffs
  let hsum_on_left ← move_to_left_side hsum
  move_target_to_left_side
  raise_goal_to_power config
  set_goal_to_hleft_sub_tleft hsum_on_left
  normalize_if_desired config
#align linear_combo.linear_combination linear_combo.linear_combination

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/-- `mk_mul [p₀, p₁, ..., pₙ]` produces the pexpr `p₀ * p₁ * ... * pₙ`. -/ unsafe
  def
    mk_mul
    : List pexpr → pexpr
    | [ ] => ` `( 1 ) | [ e ] => e | e :: es => ` `( $ ( e ) * $ ( mk_mul es ) )
#align linear_combo.mk_mul linear_combo.mk_mul

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      `as_linear_combo neg ms e` is used to parse the argument to `linear_combination`.
      This argument is a sequence of literals `x`, `-x`, or `c*x` combined with `+` or `-`,
      given by the pexpr `e`.
      The `neg` and `ms` arguments are used recursively; called at the top level, its usage should be
      `as_linear_combo ff [] e`.
      -/
    unsafe
  def
    as_linear_combo
    : Bool → List pexpr → pexpr → List ( pexpr × pexpr )
    |
      neg , ms , e
      =>
      let
        ( head , args ) := pexpr.get_app_fn_args e
        match
          head . get_frozen_name , args
          with
          | ` ` Add.add , [ e1 , e2 ] => as_linear_combo neg ms e1 ++ as_linear_combo neg ms e2
            |
              ` ` Sub.sub , [ e1 , e2 ]
              =>
              as_linear_combo neg ms e1 ++ as_linear_combo ( not neg ) ms e2
            | ` ` Mul.mul , [ e1 , e2 ] => as_linear_combo neg ( e1 :: ms ) e2
            | ` ` Div.div , [ e1 , e2 ] => as_linear_combo neg ( ` `( $ ( e2 ) ⁻¹ ) :: ms ) e1
            | ` ` Neg.neg , [ e1 ] => as_linear_combo ( not neg ) ms e1
            | _ , _ => let m := mk_mul ms [ ( e , if neg then ` `( - $ ( m ) ) else m ) ]
#align linear_combo.as_linear_combo linear_combo.as_linear_combo

section InteractiveMode

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- `linear_combination` attempts to simplify the target by creating a linear combination
  of a list of equalities and subtracting it from the target.
  The tactic will create a linear
  combination by adding the equalities together from left to right, so the order
  of the input hypotheses does matter.  If the `normalize` field of the
  configuration is set to false, then the tactic will simply set the user up to
  prove their target using the linear combination instead of normalizing the subtraction.

Users may provide an optional `with { exponent := n }`. This will raise the goal to the power `n`
  before subtracting the linear combination.

Note: The left and right sides of all the equalities should have the same
  type, and the coefficients should also have this type.  There must be
  instances of `has_mul` and `add_group` for this type.

* Input:
  * `input` : the linear combination of proofs of equalities, given as a sum/difference
      of coefficients multiplied by expressions. The coefficients may be arbitrary
      pre-expressions; if a coefficient is an application of `+` or `-` it should be
      surrounded by parentheses. The expressions can be arbitrary proof terms proving
      equalities. Most commonly they are hypothesis names `h1, h2, ...`.

      If a coefficient is omitted, it is taken to be `1`.
  * `config` : a `linear_combination_config`, which determines the tactic used
      for normalization; by default, this value is the standard configuration
      for a linear_combination_config.  In the standard configuration,
      `normalize` is set to tt (meaning this tactic is set to use
      normalization), and `normalization_tactic` is set to  `ring_nf SOP`.

Example Usage:
```
example (x y : ℤ) (h1 : x*y + 2*x = 1) (h2 : x = y) :
  x*y = -2*y + 1 :=
by linear_combination 1*h1 - 2*h2

example (x y : ℤ) (h1 : x*y + 2*x = 1) (h2 : x = y) :
  x*y = -2*y + 1 :=
by linear_combination h1 - 2*h2

example (x y : ℤ) (h1 : x*y + 2*x = 1) (h2 : x = y) :
  x*y = -2*y + 1 :=
begin
 linear_combination -2*h2,
 /- Goal: x * y + x * 2 - 1 = 0 -/
end

example (x y z : ℝ) (ha : x + 2*y - z = 4) (hb : 2*x + y + z = -2)
    (hc : x + 2*y + z = 2) :
  -3*x - 3*y - 4*z = 2 :=
by linear_combination ha - hb - 2*hc

example (x y : ℚ) (h1 : x + y = 3) (h2 : 3*x = 7) :
  x*x*y + y*x*y + 6*x = 3*x*y + 14 :=
by linear_combination x*y*h1 + 2*h2

example (x y : ℤ) (h1 : x = -3) (h2 : y = 10) :
  2*x = -6 :=
begin
  linear_combination 2*h1 with {normalize := ff},
  simp,
  norm_cast
end

example (x y z : ℚ) (h : x = y) (h2 : x * y = 0) : x + y*z = 0 :=
by linear_combination (-y * z ^ 2 + x) * h + (z ^ 2 + 2 * z + 1) * h2 with { exponent := 2 }

constants (qc : ℚ) (hqc : qc = 2*qc)

example (a b : ℚ) (h : ∀ p q : ℚ, p = q) : 3*a + qc = 3*b + 2*qc :=
by linear_combination 3 * h a b + hqc
```
-/
unsafe def _root_.tactic.interactive.linear_combination
    (input : parse (as_linear_combo false [] <$> texpr)?) (_ : parse (tk "with")?)
    (config : linear_combination_config := { }) : tactic Unit :=
  let (h_eqs_names, coeffs) := List.unzip (input.getD [])
  linear_combination h_eqs_names coeffs config
#align tactic.interactive.linear_combination tactic.interactive.linear_combination

add_tactic_doc
  { Name := "linear_combination"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.linear_combination]
    tags := ["arithmetic"] }

end InteractiveMode

end LinearCombo

