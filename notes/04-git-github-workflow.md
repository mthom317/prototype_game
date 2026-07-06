# Git & GitHub Workflow (2-person team)

## One-time machine setup (each developer, each machine)

```bash
brew install git-lfs   # or your OS package manager equivalent
git lfs install        # registers the LFS filter/hooks for this machine
```

`git lfs install` sets up local git hooks and must be run once per machine
(not just once per repo) — if a teammate clones this repo on a new device
without having run it, LFS-tracked files will silently check out as tiny
text "pointer" files instead of the real binaries.

## Branching model: GitHub Flow

- `main` is always stable/deployable.
- All work happens on short-lived branches: `feature/player-attack`,
  `fix/wall-collision-gap`, etc.
- Open a PR into `main` when ready for review/merge.
- CI (lint + headless export validation, see
  [05-cicd-pipeline.md](05-cicd-pipeline.md)) must pass before merging.
- Prefer squash-merge to keep `main`'s history linear and readable for a
  2-person team — one commit per feature/fix, not a pile of "wip" commits.

This is intentionally lightweight (no release branches, no gitflow
ceremony) because it's two people on one game, not a large team needing
strict release trains.

## Git LFS: what's tracked and why

`.gitattributes` tracks these binary types through LFS:
`png, jpg, jpeg, ogg, wav, mp3, ttf, otf`. Scene files (`.tscn`), resource
files (`.tres`), and scripts (`.gd`) are plain text and are **not**
LFS-tracked — they diff and merge normally in git, which is actually
valuable (you can see exactly what changed in a scene file's text diff).

**Ordering matters:** `git lfs track` must be set up *before* the first
commit of a matching file. If a `.png` is committed as a normal git blob
before LFS tracking existed for it, it's now baked into git history as a
regular (large) object — fixing that after the fact requires rewriting
history, which is disruptive on a shared repo. If you ever add a new binary
type not already covered (e.g. `.psd`, `.aseprite`, `.mp4`), add a
`git lfs track "*.ext"` line *before* committing the first file of that
type.

## LFS storage quota (watch this)

GitHub's free tier includes 1 GB of LFS storage and 1 GB/month of LFS
bandwidth per repository. Pixel-art sprites are small, but full music
tracks, voiceover, or recorded gameplay clips/gifs for devlogs can burn
through this quickly. There are no assets in the repo yet, so this isn't a
blocker today — but once real art/audio starts flowing in, keep an eye on
usage (Settings → Billing → Git LFS Data on the GitHub repo). If it becomes
a problem, GitHub sells additional data packs, or self-hosted/alternate LFS
storage backends are an option.

## Text vs binary scene format

Godot saves `.tscn`/`.tres` files in a human-readable text format by
default (not binary) — this is already the case in this project and should
stay that way. It's what makes git diffs of scene changes meaningful and
merge conflicts (mostly) resolvable by hand, instead of being an opaque
binary blob conflict. Don't switch this to binary format in Project
Settings.
