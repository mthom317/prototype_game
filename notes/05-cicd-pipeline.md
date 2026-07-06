# CI/CD Pipeline

Defined in [`.github/workflows/ci.yml`](../.github/workflows/ci.yml).
Triggers on every push to `main` and every pull request targeting `main`.
Two independent jobs:

## Job 1: `lint`

Runs on plain `ubuntu-latest` (no Docker needed — it's a cheap, fast job).
Installs `gdtoolkit` via pip and runs:

- `gdformat --check --diff scripts/` — fails if any script isn't formatted
  to the standard GDScript style, and shows the diff of what would change.
- `gdlint scripts/` — static style/lint checks (unused variables, naming
  conventions, etc.).

**Reading a failure:** the `gdformat` step's diff output shows exactly what
it wants reformatted — run `gdformat scripts/` locally and commit the
result. `gdlint` failures print the specific rule and line; fix and repush.

## Job 2: `export`

Runs inside the `barichello/godot-ci:4.3` Docker container — a
community-maintained image with Godot 4.3 and its export templates
pre-installed, so CI doesn't need to download/install Godot itself. This is
the **only** place Docker is used in this project; local development is
still just the normal Godot editor GUI.

Steps:

1. **Checkout with `lfs: true`** — critical. Without this flag, LFS-tracked
   binaries check out as small pointer-file stubs, not real assets.
2. **Import project resources** — runs the Godot editor headlessly once to
   warm up the resource import cache. This step exists because `.godot/`
   (Godot's local cache, including import data) is gitignored, so every CI
   run starts completely cold. Skipping this step is a common cause of
   broken/incomplete headless exports.
3. **Validate scenes load without errors** — boots the project headlessly,
   captures the log, and fails the job if `SCRIPT ERROR`, `Parse Error`, or
   `Failed to load` appear anywhere in it.
4. **Export Linux/X11 build** — runs `godot --headless --export-release`
   using the `Linux/X11` preset defined in `export_presets.cfg` (committed
   to the repo — Godot won't create this file automatically in headless
   mode). Linux/X11 is used because it needs no code-signing setup, unlike
   Windows/macOS exports.
5. **Upload build artifact** — the resulting binary is uploaded via
   `actions/upload-artifact`, downloadable from the Actions run summary.
   `if-no-files-found: error` makes an empty/silent export failure loud
   instead of a false "success."

## Known gotchas

- **Pin the Docker image tag exactly** (`barichello/godot-ci:4.3`, never
  `:latest`). The image's bundled export templates must match the
  project's Godot version — if the local editor is ever upgraded, bump this
  tag deliberately in the same change.
- **Cold `.godot/` cache every run** — this is why the "Import project
  resources" step exists; it's a known pain point with headless Godot CI in
  general, not something specific to this project.
- **`export_presets.cfg` must be committed** — it's not a secrets file
  (unlike a hypothetical Android/iOS signing config would be), so there's no
  reason to gitignore it.
- **CI failures on a fresh repo with no `scripts/` content** would make
  `gdformat`/`gdlint` no-op harmlessly; once real gameplay scripts exist,
  actual formatting/lint issues will surface here first, before a PR is
  even reviewed by a human.
