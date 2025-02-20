/-
Copyright (c) 2020 Bryan Gin-ge Chen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bryan Gin-ge Chen

! This file was ported from Lean 3 source module tactic.reserved_notation
! leanprover-community/mathlib commit a0735864ba72769da4b378673d3dbe2453924fde
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/

/-!
# Reserved notation

This file is imported by `logic.basic` and `logic.relator` to place it at the top of the
import graph.

We place all of `mathlib`'s reserved notation in this file so that users will know not to
use them as e.g. variable names without needing to import the specific file where they
are defined.

-/


/- ./././Mathport/Syntax/Translate/Command.lean:687:29: warning: unsupported: precedence command -/
/- ./././Mathport/Syntax/Translate/Command.lean:583:11: warning: suppressing unsupported reserve notation -/
/- ./././Mathport/Syntax/Translate/Command.lean:583:11: warning: suppressing unsupported reserve notation -/
/- ./././Mathport/Syntax/Translate/Command.lean:583:11: warning: suppressing unsupported reserve notation -/
/- ./././Mathport/Syntax/Translate/Command.lean:583:11: warning: suppressing unsupported reserve notation -/
/- ./././Mathport/Syntax/Translate/Command.lean:583:11: warning: suppressing unsupported reserve notation -/
/- ./././Mathport/Syntax/Translate/Command.lean:583:11: warning: suppressing unsupported reserve notation -/
/- ./././Mathport/Syntax/Translate/Command.lean:583:11: warning: suppressing unsupported reserve notation -/
/- ./././Mathport/Syntax/Translate/Command.lean:583:11: warning: suppressing unsupported reserve notation -/
/- ./././Mathport/Syntax/Translate/Command.lean:687:29: warning: unsupported: precedence command -/
/- ./././Mathport/Syntax/Translate/Command.lean:687:29: warning: unsupported: precedence command -/
/- ./././Mathport/Syntax/Translate/Command.lean:583:11: warning: suppressing unsupported reserve notation -/
-- used in `logic/relator.lean`
-- used in `tactic/core.lean`
-- used in `tactic/localized.lean`
-- used in `tactic/lint/frontend.lean`
-- used in `tactic/where.lean`
-- used in `tactic/simps.lean`
-- used in `tactic/lift.lean`
-- used in `tactic/rcases.lean`
-- used in `tactic/induction.lean`
-- used in `order/lattice.lean`
-- These priorities are chosen to be above `+`, `∑`, and `∏`, but below `*`. There is no particular
-- reason for this choice.
-- used in `algebra/module/linear_map.lean`
-- used in `data/matrix/notation.lean`
