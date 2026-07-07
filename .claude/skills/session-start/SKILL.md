---
name: session-start
description: Reviews the current repo and GitHub issue-tracker state and proposes what to work on this coding session, before any implementation starts. Invoke as a manual slash command (/session-start) at the beginning of a session on this project.
---

# Session Start Briefing

Run this at the start of a coding session on this project, before writing any code, so both developers get a consistent "where did we leave off, what's next" briefing regardless of who's picking up the work.

## Why this exists

Two people are working on this game from different devices. Without a shared ritual, each session starts cold: was there uncommitted work left on a branch? Did the other person already close out the issue you were about to pick up? Which open issue actually unblocks the most other work right now? This skill answers those before any code gets written, so effort doesn't get wasted on stale assumptions.

## Steps

### 1. Check git state

Run, in order:
- `git status` — uncommitted changes, current branch.
- `git fetch origin --prune`, then `git log HEAD..origin/main --oneline` and `git log origin/main..HEAD --oneline` — is local `main` behind or ahead of the remote? `--prune` also clears out local refs for branches already deleted upstream, which otherwise pile up and make the next check noisier than it needs to be.
- `git branch -a` — any remaining feature branches that look abandoned or superseded? For each one, don't rely on `git branch --merged` to tell you it's safe — this repo squash-merges PRs, so a squash-merged branch's commits never show as an ancestor of `main` even though it's fully landed. Check `gh pr list --state merged --head <branch-name>` instead; if that returns a merged PR, the branch is just stale cleanup, not in-progress work. If it returns nothing, check `git log -1 <branch>` for recent activity from the other developer before assuming it's abandoned.

If there's uncommitted work or a branch with an open (not merged) PR, surface it prominently — it's quite possibly where the previous session actually left off, and just needs finishing rather than a fresh issue picked.

### 2. Check the issue tracker

Run `gh issue list --state open --json number,title,labels,milestone` for the full picture. Also check `gh pr list --state open` — an open PR against an issue means someone's already mid-flight on it; don't recommend picking it up again.

The Project board reflects manual drag-and-drop status the issue list alone won't show — check it too if you have access (e.g. `gh project item-list`), so an "In Progress" card doesn't get recommended as if it were untouched.

### 3. Read for context

Skim `notes/06-roadmap.md` (milestone order and dependencies) and `notes/07-design-questions.md` (open decisions that might block a piece of work). If an open issue's natural next step depends on an unanswered design question, that's worth flagging rather than silently working around it.

### 4. Recommend the next priority

Pick the issue(s) that are actually unblocked (their dependencies are closed) and match the milestone's natural order — not just the lowest issue number. Explain the reasoning in one sentence per pick: what it unblocks, why it's next rather than some other open issue. (Past example from this project: issue #5, player attack, was picked over #7, basic enemy, because #5 is what makes the combat loop testable end-to-end once #7 lands — even though both were unblocked at the same time.)

### 5. Flag anything needing a decision

Before recommending "just start coding," check whether the top pick is actually blocked on something only the user can resolve — an unanswered design question, a licensing/asset question, an ambiguous acceptance criterion. Say so plainly rather than guessing and building the wrong thing.

### 6. Present as a short briefing, not a report

Keep the whole thing scannable — a few lines on git/PR state, the recommendation with its one-line reasoning, and any flags — then end by asking the user to confirm the pick or redirect. Don't start implementing until they've responded; the point is to align before spending effort, not to produce a document for its own sake.
