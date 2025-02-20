/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module tactic.algebra
! leanprover-community/mathlib commit 045fc4438e2f3b0c35283d3e937eb465d5b31ec3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Core

/-!
# Recording typeclass ancestors

The "old" structure command currently does not record the parent typeclasses. This file defines the
`ancestor` attribute to remedy this. This information is notably used by `to_additive` to map
structure fields and constructors of a multiplicative structure to its additive counterpart.
-/


open Lean.Parser

namespace Tactic

section Performance

-- see Note [user attribute parameters]
attribute [local semireducible] reflected

@[local instance 9000]
private unsafe def reflect_name_list : has_reflect (List Name)
  | ns => q((id $(expr.mk_app q(Prop) <| ns.map flip expr.const []) : List Name))

private unsafe def parse_name_list (e : expr) : List Name :=
  e.app_arg.get_app_args.map expr.const_name

/-- The `ancestor` attributes is used to record the names of structures which appear in the
extends clause of a `structure` or `class` declared with `old_structure_cmd` set to true.

As an example:
```
set_option old_structure_cmd true

structure base_one := (one : ℕ)

structure base_two (α : Type*) := (two : ℕ)

@[ancestor base_one base_two]
structure bar extends base_one, base_two α
```

The list of ancestors should be in the order they appear in the `extends` clause, and should
contain only the names of the ancestor structures, without any arguments.
-/
@[user_attribute]
unsafe def ancestor_attr : user_attribute Unit (List Name)
    where
  Name := `ancestor
  descr := "ancestor of old structures"
  parser := many ident
#align tactic.ancestor_attr tactic.ancestor_attr

add_tactic_doc
  { Name := "ancestor"
    category := DocCategory.attr
    declNames := [`tactic.ancestor_attr]
    tags := ["transport", "environment"] }

end Performance

/-- Returns the parents of a structure added via the `ancestor` attribute.

On failure, the empty list is returned.
-/
unsafe def get_tagged_ancestors (cl : Name) : tactic (List Name) :=
  parse_name_list <$> ancestor_attr.get_param_untyped cl <|> pure []
#align tactic.get_tagged_ancestors tactic.get_tagged_ancestors

/-- Returns the parents of a structure added via the `ancestor` attribute, as well as subobjects.

On failure, the empty list is returned.
-/
unsafe def get_ancestors (cl : Name) : tactic (List Name) :=
  (· ++ ·) <$> (Prod.fst <$> subobject_names cl <|> pure []) <*> get_tagged_ancestors cl
#align tactic.get_ancestors tactic.get_ancestors

/-- Returns the (transitive) ancestors of a structure added via the `ancestor`
attribute (or reachable via subobjects).

On failure, the empty list is returned.
-/
unsafe def find_ancestors : Name → expr → tactic (List expr)
  | cl, arg => do
    let cs ← get_ancestors cl
    let r ← cs.mapM fun c => List.ret <$> (mk_app c [arg] >>= mk_instance) <|> find_ancestors c arg
    return r
#align tactic.find_ancestors tactic.find_ancestors

end Tactic

