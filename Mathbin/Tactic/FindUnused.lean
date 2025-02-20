/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module tactic.find_unused
! leanprover-community/mathlib commit e68fcf8dede813727dd0a47c873938ade3f90ef1
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Bool.Basic
import Mathbin.Meta.RbMap
import Mathbin.Tactic.Core

/-!
# list_unused_decls

`#list_unused_decls` is a command used for theory development.
When writing a new theory one often tries
multiple variations of the same definitions: `foo`, `foo'`, `foo₂`,
`foo₃`, etc. Once the main definition or theorem has been written,
it's time to clean up and the file can contain a lot of dead code.
Mark the main declarations with `@[main_declaration]` and
`#list_unused_decls` will show the declarations in the file
that are not needed to define the main declarations.

Some of the so-called "unused" declarations may turn out to be useful
after all. The oversight can be corrected by marking those as
`@[main_declaration]`. `#list_unused_decls` will revise the list of
unused declarations. By default, the list of unused declarations will
not include any dependency of the main declarations.

The `@[main_declaration]` attribute should be removed before submitting
code to mathlib as it is merely a tool for cleaning up a module.
-/


namespace Tactic

/-- Attribute `main_declaration` is used to mark declarations that are featured
in the current file.  Then, the `#list_unused_decls` command can be used to
list the declaration present in the file that are not used by the main
declarations of the file. -/
@[user_attribute]
unsafe def main_declaration_attr : user_attribute
    where
  Name := `main_declaration
  descr := "tag essential declarations to help identify unused definitions"
#align tactic.main_declaration_attr tactic.main_declaration_attr

/-- `update_unsed_decls_list n m` removes from the map of unneeded declarations those
referenced by declaration named `n` which is considerred to be a
main declaration -/
private unsafe def update_unsed_decls_list :
    Name → name_map declaration → tactic (name_map declaration)
  | n, m => do
    let d ← get_decl n
    if m n then do
        let m := m n
        let ns := d d
        ns m update_unsed_decls_list
      else pure m

/-- In the current file, list all the declaration that are not marked as `@[main_declaration]` and
that are not referenced by such declarations -/
unsafe def all_unused (fs : List (Option String)) : tactic (name_map declaration) := do
  let ds ← get_decls_from fs
  let ls ← ds.keys.filterM (succeeds ∘ user_attribute.get_param_untyped main_declaration_attr)
  let ds ← ls.foldlM (flip update_unsed_decls_list) ds
  ds fun n d => do
      let e ← get_env
      return <| !d e
#align tactic.all_unused tactic.all_unused

/-- expecting a string literal (e.g. `"src/tactic/find_unused.lean"`)
-/
unsafe def parse_file_name (fn : pexpr) : tactic (Option String) :=
  some <$> (to_expr fn >>= eval_expr String) <|> fail "expecting: \"src/dir/file-name\""
#align tactic.parse_file_name tactic.parse_file_name

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- The command `#list_unused_decls` lists the declarations that that
are not used the main features of the present file. The main features
of a file are taken as the declaration tagged with
`@[main_declaration]`.

A list of files can be given to `#list_unused_decls` as follows:

```lean
#list_unused_decls ["src/tactic/core.lean","src/tactic/interactive.lean"]
```

They are given in a list that contains file names written as Lean
strings. With a list of files, the declarations from all those files
in addition to the declarations above `#list_unused_decls` in the
current file will be considered and their interdependencies will be
analyzed to see which declarations are unused by declarations marked
as `@[main_declaration]`. The files listed must be imported by the
current file. The path of the file names is expected to be relative to
the root of the project (i.e. the location of `leanpkg.toml` when it
is present).

Neither `#list_unused_decls` nor `@[main_declaration]` should appear
in a finished mathlib development. -/
@[user_command]
unsafe def unused_decls_cmd (_ : parse <| tk "#list_unused_decls") : lean.parser Unit := do
  let fs ← pexpr_list
  show tactic Unit from do
      let fs ← fs parse_file_name
      let ds ← all_unused <| none :: fs
      ds fun ⟨n, _⟩ =>
          ← do
            dbg_trace "#print {← n}"
#align tactic.unused_decls_cmd tactic.unused_decls_cmd

add_tactic_doc
  { Name := "#list_unused_decls"
    category := DocCategory.cmd
    declNames := [`tactic.unused_decls_cmd]
    tags := ["debugging"] }

end Tactic

