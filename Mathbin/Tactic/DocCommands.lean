/-
Copyright (c) 2020 Robert Y. Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Y. Lewis

! This file was ported from Lean 3 source module tactic.doc_commands
! leanprover-community/mathlib commit bc40b44c260045cc3e7ea7e29a9080cd8e92bd57
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/

/-!
# Documentation commands

We generate html documentation from mathlib. It is convenient to collect lists of tactics, commands,
notes, etc. To facilitate this, we declare these documentation entries in the library
using special commands.

* `library_note` adds a note describing a certain feature or design decision. These can be
  referenced in doc strings with the text `note [name of note]`.
* `add_tactic_doc` adds an entry documenting an interactive tactic, command, hole command, or
  attribute.

Since these commands are used in files imported by `tactic.core`, this file has no imports.

## Implementation details

`library_note note_id note_msg` creates a declaration `` `library_note.i `` for some `i`.
This declaration is a pair of strings `note_id` and `note_msg`, and it gets tagged with the
`library_note` attribute.

Similarly, `add_tactic_doc` creates a declaration `` `tactic_doc.i `` that stores the provided
information.
-/


#print String.hash /-
/-- A rudimentary hash function on strings. -/
def String.hash (s : String) : ℕ :=
  s.fold 1 fun h c => (33 * h + c.val) % unsignedSz
#align string.hash String.hash
-/

/-- Get the last component of a name, and convert it to a string. -/
unsafe def name.last : Name → String
  | Name.mk_string s _ => s
  | Name.mk_numeral n _ => repr n
  | anonymous => "[anonymous]"
#align name.last name.last

open Tactic

/-- `copy_doc_string fr to` copies the docstring from the declaration named `fr`
to each declaration named in the list `to`. -/
unsafe def tactic.copy_doc_string (fr : Name) (to : List Name) : tactic Unit := do
  let fr_ds ← doc_string fr
  to fun tgt => add_doc_string tgt fr_ds
#align tactic.copy_doc_string tactic.copy_doc_string

open Lean Lean.Parser Interactive

/-- `copy_doc_string source → target_1 target_2 ... target_n` copies the doc string of the
declaration named `source` to each of `target_1`, `target_2`, ..., `target_n`.
 -/
@[user_command]
unsafe def copy_doc_string_cmd (_ : parse (tk "copy_doc_string")) : parser Unit := do
  let fr ← parser.ident
  tk "->"
  let to ← parser.many parser.ident
  let expr.const fr _ ← resolve_name fr
  let to ← parser.of_tactic (to.mapM fun n => expr.const_name <$> resolve_name n)
  tactic.copy_doc_string fr to
#align copy_doc_string_cmd copy_doc_string_cmd

/-! ### The `library_note` command -/


/-- A user attribute `library_note` for tagging decls of type `string × string` for use in note
output. -/
@[user_attribute]
unsafe def library_note_attr : user_attribute
    where
  Name := `library_note
  descr := "Notes about library features to be included in documentation"
  parser := failed
#align library_note_attr library_note_attr

/-- `mk_reflected_definition name val` constructs a definition declaration by reflection.

Example: ``mk_reflected_definition `foo 17`` constructs the definition
declaration corresponding to `def foo : ℕ := 17`
-/
unsafe def mk_reflected_definition (decl_name : Name) {type} [reflected _ type] (body : type)
    [reflected _ body] : declaration :=
  mk_definition decl_name (reflect type).collect_univ_params (reflect type) (reflect body)
#align mk_reflected_definition mk_reflected_definition

/--
If `note_name` and `note` are strings, `add_library_note note_name note` adds a declaration named
`library_note.<note_name>` with `note` as the docstring and tags it with the `library_note`
attribute.
-/
unsafe def tactic.add_library_note (note_name note : String) : tactic Unit := do
  let decl_name := .str `library_note note_name
  add_decl <| mk_reflected_definition decl_name ()
  add_doc_string decl_name note
  library_note_attr decl_name () tt none
#align tactic.add_library_note tactic.add_library_note

open Tactic

/-- A command to add library notes. Syntax:
```
/--
note message
-/
library_note "note id"
```
-/
@[user_command]
unsafe def library_note (mi : interactive.decl_meta_info) (_ : parse (tk "library_note")) :
    parser Unit := do
  let note_name ← parser.pexpr
  let note_name ← eval_pexpr String note_name
  let some doc_string ← pure mi.doc_string |
    fail "library_note requires a doc string"
  add_library_note note_name doc_string
#align library_note library_note

/-- Collects all notes in the current environment.
Returns a list of pairs `(note_id, note_content)` -/
unsafe def tactic.get_library_notes : tactic (List (String × String)) :=
  attribute.get_instances `library_note >>=
    List.mapM fun dcl => Prod.mk dcl.getLast <$> doc_string dcl
#align tactic.get_library_notes tactic.get_library_notes

/-! ### The `add_tactic_doc_entry` command -/


/-- The categories of tactic doc entry. -/
inductive DocCategory
  | tactic
  | cmd
  | hole_cmd
  | attr
  deriving DecidableEq, has_reflect
#align doc_category DocCategory

/-- Format a `doc_category` -/
unsafe def doc_category.to_string : DocCategory → String
  | DocCategory.tactic => "tactic"
  | DocCategory.cmd => "command"
  | DocCategory.hole_cmd => "hole_command"
  | DocCategory.attr => "attribute"
#align doc_category.to_string doc_category.to_string

unsafe instance : has_to_format DocCategory :=
  ⟨↑doc_category.to_string⟩

/-- The information used to generate a tactic doc entry -/
structure TacticDocEntry where
  Name : String
  category : DocCategory
  declNames : List Name
  tags : List String := []
  inheritDescriptionFrom : Option Name := none
  deriving has_reflect
#align tactic_doc_entry TacticDocEntry

/-- Turns a `tactic_doc_entry` into a JSON representation. -/
unsafe def tactic_doc_entry.to_json (d : TacticDocEntry) (desc : String) : json :=
  json.object
    [("name", d.Name), ("category", d.category.toString),
      ("decl_names", d.declNames.map (json.of_string ∘ toString)),
      ("tags", d.tags.map json.of_string), ("description", desc)]
#align tactic_doc_entry.to_json tactic_doc_entry.to_json

unsafe instance tactic_doc_entry.has_to_string : ToString (TacticDocEntry × String) :=
  ⟨fun ⟨doc, desc⟩ => json.unparse (doc.to_json desc)⟩
#align tactic_doc_entry.has_to_string tactic_doc_entry.has_to_string

/-- A user attribute `tactic_doc` for tagging decls of type `tactic_doc_entry`
for use in doc output -/
@[user_attribute]
unsafe def tactic_doc_entry_attr : user_attribute
    where
  Name := `tactic_doc
  descr := "Information about a tactic to be included in documentation"
  parser := failed
#align tactic_doc_entry_attr tactic_doc_entry_attr

/-- Collects everything in the environment tagged with the attribute `tactic_doc`. -/
unsafe def tactic.get_tactic_doc_entries : tactic (List (TacticDocEntry × String)) :=
  attribute.get_instances `tactic_doc >>=
    List.mapM fun dcl => Prod.mk <$> (mk_const dcl >>= eval_expr TacticDocEntry) <*> doc_string dcl
#align tactic.get_tactic_doc_entries tactic.get_tactic_doc_entries

/-- `add_tactic_doc tde` adds a declaration to the environment
with `tde` as its body and tags it with the `tactic_doc`
attribute. If `tde.decl_names` has exactly one entry `` `decl`` and
if `tde.description` is the empty string, `add_tactic_doc` uses the doc
string of `decl` as the description. -/
unsafe def tactic.add_tactic_doc (tde : TacticDocEntry) (doc : Option String) : tactic Unit := do
  let desc ←
    doc <|> do
        let inh_id ←
          match tde.inheritDescriptionFrom, tde.declNames with
            | some inh_id, _ => pure inh_id
            | none, [inh_id] => pure inh_id
            | none, _ =>
              fail
                "A tactic doc entry must either:\n 1. have a description written as a doc-string for the `add_tactic_doc` invocation, or\n 2. have a single declaration in the `decl_names` field, to inherit a description from, or\n 3. explicitly indicate the declaration to inherit the description from using\n    `inherit_description_from`."
        doc_string inh_id <|> fail (toString inh_id ++ " has no doc string")
  let decl_name := .str (.str `tactic_doc tde.category.toString) tde.Name
  add_decl <| mk_definition decl_name [] q(TacticDocEntry) (reflect tde)
  add_doc_string decl_name desc
  tactic_doc_entry_attr decl_name () tt none
#align tactic.add_tactic_doc tactic.add_tactic_doc

/-- A command used to add documentation for a tactic, command, hole command, or attribute.

Usage: after defining an interactive tactic, command, or attribute,
add its documentation as follows.
```lean
/--
describe what the command does here
-/
add_tactic_doc
{ name := "display name of the tactic",
  category := cat,
  decl_names := [`dcl_1, `dcl_2],
  tags := ["tag_1", "tag_2"] }
```

The argument to `add_tactic_doc` is a structure of type `tactic_doc_entry`.
* `name` refers to the display name of the tactic; it is used as the header of the doc entry.
* `cat` refers to the category of doc entry.
  Options: `doc_category.tactic`, `doc_category.cmd`, `doc_category.hole_cmd`, `doc_category.attr`
* `decl_names` is a list of the declarations associated with this doc. For instance,
  the entry for `linarith` would set ``decl_names := [`tactic.interactive.linarith]``.
  Some entries may cover multiple declarations.
  It is only necessary to list the interactive versions of tactics.
* `tags` is an optional list of strings used to categorize entries.
* The doc string is the body of the entry. It can be formatted with markdown.
  What you are reading now is the description of `add_tactic_doc`.

If only one related declaration is listed in `decl_names` and if this
invocation of `add_tactic_doc` does not have a doc string, the doc string of
that declaration will become the body of the tactic doc entry. If there are
multiple declarations, you can select the one to be used by passing a name to
the `inherit_description_from` field.

If you prefer a tactic to have a doc string that is different then the doc entry,
you should write the doc entry as a doc string for the `add_tactic_doc` invocation.

Note that providing a badly formed `tactic_doc_entry` to the command can result in strange error
messages.

-/
@[user_command]
unsafe def add_tactic_doc_command (mi : interactive.decl_meta_info)
    (_ : parse <| tk "add_tactic_doc") : parser Unit := do
  let pe ← parser.pexpr
  let e ← eval_pexpr TacticDocEntry pe
  tactic.add_tactic_doc e mi
#align add_tactic_doc_command add_tactic_doc_command

/-- At various places in mathlib, we leave implementation notes that are referenced from many other
files. To keep track of these notes, we use the command `library_note`. This makes it easy to
retrieve a list of all notes, e.g. for documentation output.

These notes can be referenced in mathlib with the syntax `Note [note id]`.
Often, these references will be made in code comments (`--`) that won't be displayed in docs.
If such a reference is made in a doc string or module doc, it will be linked to the corresponding
note in the doc display.

Syntax:
```
/--
note message
-/
library_note "note id"
```

An example from `meta.expr`:

```
/--
Some declarations work with open expressions, i.e. an expr that has free variables.
Terms will free variables are not well-typed, and one should not use them in tactics like
`infer_type` or `unify`. You can still do syntactic analysis/manipulation on them.
The reason for working with open types is for performance: instantiating variables requires
iterating through the expression. In one performance test `pi_binders` was more than 6x
quicker than `mk_local_pis` (when applied to the type of all imported declarations 100x).
-/
library_note "open expressions"
```

This note can be referenced near a usage of `pi_binders`:


```
-- See Note [open expressions]
/-- behavior of f -/
def f := pi_binders ...
```
-/
add_tactic_doc
  { Name := "library_note"
    category := DocCategory.cmd
    declNames := [`library_note, `tactic.add_library_note]
    tags := ["documentation"]
    inheritDescriptionFrom := `library_note }

add_tactic_doc
  { Name := "add_tactic_doc"
    category := DocCategory.cmd
    declNames := [`add_tactic_doc_command, `tactic.add_tactic_doc]
    tags := ["documentation"]
    inheritDescriptionFrom := `add_tactic_doc_command }

add_tactic_doc
  { Name := "copy_doc_string"
    category := DocCategory.cmd
    declNames := [`copy_doc_string_cmd, `tactic.copy_doc_string]
    tags := ["documentation"]
    inheritDescriptionFrom := `copy_doc_string_cmd }

-- add docs to core tactics
/-- The congruence closure tactic `cc` tries to solve the goal by chaining
equalities from context and applying congruence (i.e. if `a = b`, then `f a = f b`).
It is a finishing tactic, i.e. it is meant to close
the current goal, not to make some inconclusive progress.
A mostly trivial example would be:

```lean
example (a b c : ℕ) (f : ℕ → ℕ) (h: a = b) (h' : b = c) : f a = f c := by cc
```

As an example requiring some thinking to do by hand, consider:

```lean
example (f : ℕ → ℕ) (x : ℕ)
  (H1 : f (f (f x)) = x) (H2 : f (f (f (f (f x)))) = x) :
  f x = x :=
by cc
```

The tactic works by building an equality matching graph. It's a graph where
the vertices are terms and they are linked by edges if they are known to
be equal. Once you've added all the equalities in your context, you take
the transitive closure of the graph and, for each connected component
(i.e. equivalence class) you can elect a term that will represent the
whole class and store proofs that the other elements are equal to it.
You then take the transitive closure of these equalities under the
congruence lemmas.

The `cc` implementation in Lean does a few more tricks: for example it
derives `a=b` from `nat.succ a = nat.succ b`, and `nat.succ a !=
nat.zero` for any `a`.

* The starting reference point is Nelson, Oppen, [Fast decision procedures based on congruence
closure](http://www.cs.colorado.edu/~bec/courses/csci5535-s09/reading/nelson-oppen-congruence.pdf),
Journal of the ACM (1980)

* The congruence lemmas for dependent type theory as used in Lean are described in
[Congruence closure in intensional type theory](https://leanprover.github.io/papers/congr.pdf)
(de Moura, Selsam IJCAR 2016).
-/
add_tactic_doc
  { Name := "cc (congruence closure)"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.cc]
    tags := ["core", "finishing"] }

/-- `conv {...}` allows the user to perform targeted rewriting on a goal or hypothesis,
by focusing on particular subexpressions.

See <https://leanprover-community.github.io/extras/conv.html> for more details.

Inside `conv` blocks, mathlib currently additionally provides
* `erw`,
* `ring`, `ring2` and `ring_exp`,
* `norm_num`,
* `norm_cast`,
* `apply_congr`, and
* `conv` (within another `conv`).

`apply_congr` applies congruence lemmas to step further inside expressions,
and sometimes gives better results than the automatically generated
congruence lemmas used by `congr`.

Using `conv` inside a `conv` block allows the user to return to the previous
state of the outer `conv` block after it is finished. Thus you can continue
editing an expression without having to start a new `conv` block and re-scoping
everything. For example:
```lean
example (a b c d : ℕ) (h₁ : b = c) (h₂ : a + c = a + d) : a + b = a + d :=
by conv
{ to_lhs,
  conv
  { congr, skip,
    rw h₁ },
  rw h₂, }
```
Without `conv`, the above example would need to be proved using two successive
`conv` blocks, each beginning with `to_lhs`.

Also, as a shorthand, `conv_lhs` and `conv_rhs` are provided, so that
```lean
example : 0 + 0 = 0 :=
begin
  conv_lhs { simp }
end
```
just means
```lean
example : 0 + 0 = 0 :=
begin
  conv { to_lhs, simp }
end
```
and likewise for `to_rhs`.
-/
add_tactic_doc
  { Name := "conv"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.conv]
    tags := ["core"] }

add_tactic_doc
  { Name := "simp"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.simp]
    tags := ["core", "simplification"] }

/-- Accepts terms with the type `component tactic_state string` or `html empty` and
renders them interactively.
Requires a compatible version of the vscode extension to view the resulting widget.

### Example:

```lean
/-- A simple counter that can be incremented or decremented with some buttons. -/
meta def counter_widget {π α : Type} : component π α :=
component.ignore_props $ component.mk_simple int int 0 (λ _ x y, (x + y, none)) (λ _ s,
  h "div" [] [
    button "+" (1 : int),
    html.of_string $ to_string $ s,
    button "-" (-1)
  ]
)

#html counter_widget
```
-/
add_tactic_doc
  { Name := "#html"
    category := DocCategory.cmd
    declNames := [`show_widget_cmd]
    tags := ["core", "widgets"] }

/-- The `add_decl_doc` command is used to add a doc string to an existing declaration.

```lean
def foo := 5

/--
Doc string for foo.
-/
add_decl_doc foo
```
-/
@[user_command]
unsafe def add_decl_doc_command (mi : interactive.decl_meta_info) (_ : parse <| tk "add_decl_doc") :
    parser Unit := do
  let n ← parser.ident
  let n ← resolve_constant n
  let some doc ← pure mi.doc_string |
    fail "add_decl_doc requires a doc string"
  add_doc_string n doc
#align add_decl_doc_command add_decl_doc_command

add_tactic_doc
  { Name := "add_decl_doc"
    category := DocCategory.cmd
    declNames := [`` add_decl_doc_command]
    tags := ["documentation"] }

