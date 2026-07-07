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

## Issues, Milestones, and the Project board

Work is tracked as one [GitHub Issue](https://github.com/mthom317/prototype_game/issues)
per feature (coarse-grained, with an acceptance-criteria checklist inside —
not split into many tiny sub-issues). Issues are grouped into Milestones
that mirror `06-roadmap.md`'s M1–M5, and surfaced on the
[Project board](https://github.com/users/mthom317/projects/1) so both of you
can see who's working on what without syncing live, which matters more when
you're remote from each other.

- Name feature branches after the issue: `feature/4-hitbox-hurtbox` for
  issue #4.
- Reference the issue in the PR description with `Closes #4` — GitHub
  auto-closes the issue and moves the Project board card when the PR
  merges.
- Pick issues from the current milestone's column on the Project board;
  drag your card to "In Progress" when you start so your teammate can see
  it at a glance.

## Category labels: a third, orthogonal axis

Every issue carries labels along three independent axes, which answer three
different questions and shouldn't be conflated:

- **`area: *`** (blue) — *where* in the game a task lives: `area: combat`,
  `area: player`, `area: world`, `area: ui`, `area: art-integration`,
  `area: audio`, `area: tooling`.
- **Type** (`bug`, `enhancement`, `chore`, etc.) — *what kind* of change it
  is.
- **`category: *`** — *which part of the overall project workstream* the
  task belongs to, regardless of area or type:
  - `category: game-dev` — actual gameplay features, content, or bugs in
    the game itself. Most issues fall here (e.g. #4-7, #9, #10, #20).
  - `category: testing` — testing infrastructure, QA process, or
    playtesting work, as distinct from the game feature being tested.
    Nothing currently uses this label, but it exists so future
    testing-harness/QA work has a home.
  - `category: chore` — maintenance or admin work that isn't building a
    feature (e.g. #8's asset-licensing check: it's a compliance/legal
    research task with no game code or content as output, so it's a chore
    even though it's a hard blocker for M2).
  - `category: ai-tooling` — meta-tooling specifically about how Claude
    Code operates in this repo, as opposed to tooling that ships with the
    game (e.g. #17 CLAUDE.md, #18 the `/session-start` skill).

Every issue should get exactly one `category:` label alongside its `area:`
and type labels — apply it when the issue is filed, the same way `area:`
and type labels are applied.

On the Project board, this is also modeled as a single-select **Category**
field (Game/Dev, Testing, Chore, AI/Claude Tooling), kept in sync with the
label, so the board can be grouped by workstream in addition to filtering
by label.

## This is enforced, not just a convention

A GitHub branch protection rule on `main` enforces the above:

- Direct pushes to `main` are blocked for everyone, including repo admins —
  all changes must go through a PR.
- Both CI jobs (`Lint GDScript`, `Headless Export Validation`) must report
  success on the PR's head commit before the merge button unlocks.
- The PR branch must be up to date with `main` before merging.
- No mandatory human review is required (`required_approving_review_count`
  is 0) — either developer can self-merge once CI is green. This can be
  raised to require the other teammate's approval later if the team wants
  more oversight, at the cost of blocking merges when only one person is
  available.
- Force-pushes and deletion of `main` are disabled.

To change these settings, go to the repo's Settings → Branches → the rule
on `main`, or use `gh api repos/mthom317/prototype_game/branches/main/protection`.

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
