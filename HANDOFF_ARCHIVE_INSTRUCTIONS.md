# Commit-Preserving Handoff Archive

Use Git patches instead of manually assembled source ZIPs.

## Archive structure

```text
[project-name]-handoff-<base>-<head>.zip
├── manifest.json
├── patches/
│   ├── 0001-....patch
│   └── 0002-....patch
├── verification/
│   ├── git-status.txt
│   ├── test-results.txt
│   └── changed-files.txt
└── README.txt
```

## Create patches

From a clean repository, generate binary-safe patches for every commit after the agreed base:

```bash
git format-patch --binary <base-commit>..HEAD -o patches/
```

Include the base commit, head commit, branch, and summary in `manifest.json`. Add the latest Git status, verification results, and changed-file list under `verification/`, then ZIP the package using the required filename.

## Apply patches

From the repository root:

```bash
git am --3way patches/*.patch
```

If Git reports a conflict, stop and resolve or abort with:

```bash
git am --abort
```

This format preserves commit authorship and messages, additions, deletions, renames, binary files, exact repository paths, and commit order. It is safer than copying files because Git detects divergence and conflicts instead of silently overwriting newer work.
