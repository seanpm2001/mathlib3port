Tracking mathlib commit: [`9240e8be927a0955b9a82c6c85ef499ee3a626b8`](https://github.com/leanprover-community/mathlib/commit/9240e8be927a0955b9a82c6c85ef499ee3a626b8)

You should use this repository to inspect the Lean 4 files that `mathport` has generated from mathlib3.
Please run `lake build` first, to download a copy of the generated `.olean` files.
After that, you should be able to open any of the `.lean` files under the `Mathbin` directory.
These will use binported `.olean`s for the imports, and there is a synported `.lean` file for each file in mathlib3.
Please expect *many* errors at this stage.

Although the `Mathbin` directory is committed in the repository,
at this stage you should not attempt to make any changes on the master branch.

It's fine, however, to make branches containing "by-hand" edits,
if you want to be able to link to diffs when reporting issues in `mathport`.
