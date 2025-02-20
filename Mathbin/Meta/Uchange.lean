/-
Copyright (c) 2020 Gabriel Ebner. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner

! This file was ported from Lean 3 source module meta.uchange
! leanprover-community/mathlib commit 3710744b411550474ecf27d3c50d92156b5ffc95
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/

/-!
# Changing universes of types in meta-code

This file defines the meta type `uchange (α : Type v) : Type u`, which
permits us to change the universe of a type analogously to `ulift`.
However since `uchange` is meta, it can both lift and lower the universe.

The implementation of `uchange` is efficient. Both `uchange.up` and
`uchange.down` compile to no-ops.
-/


universe u v

/-- `unchecked_cast' a : β` performs an unchecked cast of `(a : α)` to `β`.

Unlike `unchecked_cast`, it can cast across universes. The VM implementation
is guaranteed to be the identity.
-/
@[inline]
unsafe irreducible_def unchecked_cast' {α : Sort u} {β : Sort v} (a : α) : β :=
  PLift.down <|
    @cast (α → β → PLift β) (β → α → PLift β) undefined (fun _ a => PLift.up a)
      (cast undefined PUnit.unit) a
#align unchecked_cast' unchecked_cast'

/-- `uchange (α : Sort v) : Sort u` is an equivalent type in a different universe.

In the VM, both `α` and `uchange α` have the same representation.

This definition is `meta` because it collapses the universe hierarchy; if pure code could do
this then one could derive Girard's paradox.
-/
unsafe def uchange (α : Type v) : Type u :=
  unchecked_cast' α
#align uchange uchange

namespace Uchange

variable {α : Type v} (a : α)

unsafe instance [DecidableEq α] : DecidableEq (uchange α) :=
  unchecked_cast' (by infer_instance : DecidableEq α)

/-- `uchange.down` embeds `α` to `uchange α`.

The VM implementation is guaranteed to be the identity.
-/
@[inline]
unsafe def down {α} (a : α) : uchange α :=
  unchecked_cast' a
#align uchange.down uchange.down

/-- `uchange.up` extracts from `uchange α` an `α`.

The VM implementation is guaranteed to be the identity.
-/
@[inline]
unsafe def up {α} (a : uchange α) : α :=
  unchecked_cast' a
#align uchange.up uchange.up

end Uchange

-- Sanity check
#eval do
  guard <| (uchange.down.{0} 42).up = 42
  tactic.skip

