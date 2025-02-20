import Lake
open Lake DSL System

-- Usually the `tag` will be of the form `nightly-2021-11-22`.
-- If you would like to use an artifact from a PR build,
-- it will be of the form `pr-branchname-sha`.
def tag : String := "nightly-2023-06-30-19"
def releaseRepo : String := "leanprover-community/mathport"
def oleanTarName : String := "mathlib3-binport.tar.gz"

def download (url : String) (to : FilePath) : BuildM PUnit := Lake.proc
{ -- We use `curl -O` to ensure we clobber any existing file.
  cmd := "curl",
  args := #["-L", "-O", url]
  cwd := to }

def untar (file : FilePath) : BuildM PUnit := Lake.proc
{ cmd := "tar",
  args := #["-xzf", file.fileName.getD "."] -- really should throw an error if `file.fileName = none`
  cwd := file.parent }

def getReleaseArtifact (repo tag artifact : String) (to : FilePath) : BuildM PUnit :=
download s!"https://github.com/{repo}/releases/download/{tag}/{artifact}" to

def untarReleaseArtifact (repo tag artifact : String) (to : FilePath) : BuildM PUnit := do
  getReleaseArtifact repo tag artifact to
  untar (to / artifact)

package mathlib3port where
  extraDepTargets := #[`fetchOleans]

target fetchOleans (_pkg : Package) : Unit := do
  let libDir : FilePath := __dir__ / "build" / "lib"
  IO.FS.createDirAll libDir
  let oldTrace := Hash.ofString tag
  let _ ← buildFileUnlessUpToDate (libDir / oleanTarName) oldTrace do
    logInfo "Fetching oleans for Mathbin"
    untarReleaseArtifact releaseRepo tag oleanTarName libDir
  return .nil

require lean3port from git "https://github.com/leanprover-community/lean3port.git"@"248dee5c15dd3ce4477ed6c7be239b3f974b0bf3"

@[default_target]
lean_lib Mathbin where
  roots := #[]
  globs := #[`Mathbin]
