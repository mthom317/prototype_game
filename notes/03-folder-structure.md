# Folder Structure

```
prototype/
├── .github/workflows/ci.yml     # CI/CD pipeline (see 05-cicd-pipeline.md)
├── addons/                      # vendored/AssetLib plugins, committed to git
├── assets/                      # raw source art & audio (LFS-tracked)
│   ├── sprites/
│   ├── audio/{sfx,music}/
│   └── fonts/
├── resources/                   # Godot .tres data resources (not raw binaries)
├── scenes/
│   ├── main/                    # top-level/room scenes (TestRoom.tscn lives here)
│   └── player/                  # Player.tscn
├── scripts/
│   ├── player/                  # Player.gd
│   └── autoloads/               # singleton scripts (GameManager.gd)
├── notes/                       # this documentation
├── export_presets.cfg
└── project.godot
```

## Rationale

- **`scenes/` mirrors `scripts/` by domain** (player, and later enemies,
  items, ui, world), rather than nesting scripts inside scene folders or vice
  versa. This is the most common Godot 4 convention and scales cleanly —
  scanning either tree top-to-bottom tells you every gameplay domain in the
  project.
- **`assets/` vs `resources/` is a deliberate split.** `assets/` holds raw
  imported binaries (art, audio, fonts) — these are what Git LFS tracks.
  `resources/` holds Godot-native `.tres` files (e.g. a future `ItemData`
  resource describing a sword's damage/icon/name) — these are small text
  files that diff and merge fine in plain git, so they should **not** be
  dumped into an LFS-tracked directory.
- **`addons/` is committed, not gitignored.** It's a Godot-recognized special
  folder for the AssetLib plugin system. Plugins placed here are typically
  small GDScript files, not large binaries, so both developers and CI should
  get identical versions without a separate install step.
- **Autoloads are a `project.godot` setting, not a folder.** The *scripts*
  for autoloaded singletons live in `scripts/autoloads/`; the `[autoload]`
  section in `project.godot` is what actually registers them as globally
  accessible singletons.

## Directories created on demand

We deliberately did **not** pre-create empty future-scoped folders like
`scenes/enemies/`, `scenes/items/`, `scenes/ui/`, `resources/items/`, etc.
Git doesn't track empty directories anyway, and pre-creating them just adds
noise before there's anything to put in them. When you pick up a milestone
from [06-roadmap.md](06-roadmap.md) that needs one of these, create it then,
following the same domain-based naming pattern shown above.
