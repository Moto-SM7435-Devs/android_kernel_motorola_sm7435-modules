#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

REPO="https://github.com/MotorolaMobilityLLC/kernel-msm-5.4-techpack-display.git"
TAG="MMI-W1UUI36H.110-53"
DEST="$ROOT/qcom/opensource/techpack-display"

echo "=============================================="
echo " Motorola Techpack Display Import"
echo "=============================================="
echo "Repo : $REPO"
echo "Tag  : $TAG"
echo "Dest : $DEST"
echo

mkdir -p "$(dirname "$DEST")"

# ----------------------------------------------------------
# Clone into temporary directory
# ----------------------------------------------------------
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Cloning $TAG..."

git clone \
    --branch "$TAG" \
    --single-branch \
    "$REPO" \
    "$TMP/source"

# ----------------------------------------------------------
# Remove existing destination if it is a gitlink/nested repo
# ----------------------------------------------------------
if [ -d "$DEST" ]; then
    echo "Destination already exists."

    if git ls-files --stage -- "$DEST" | grep -q '^160000'; then
        echo "Removing existing gitlink..."
        git rm --cached -r -- "$DEST"
    fi

    rm -rf "$DEST"
fi

mkdir -p "$DEST"

# ----------------------------------------------------------
# Copy source WITHOUT the nested .git
# ----------------------------------------------------------
echo "Copying actual source files..."

cp -a "$TMP/source"/. "$DEST"/

rm -rf "$DEST/.git"

# ----------------------------------------------------------
# Stage as normal files
# ----------------------------------------------------------
git add -- "$DEST"

# ----------------------------------------------------------
# Verify
# ----------------------------------------------------------
echo
echo "=============================================="
echo " Verification"
echo "=============================================="

if git ls-files --stage -- "$DEST" | grep -q '^160000'; then
    echo "ERROR: Gitlink still exists!"
    exit 1
fi

if [ -e "$DEST/.git" ]; then
    echo "ERROR: Nested .git still exists!"
    exit 1
fi

echo "OK: No gitlink."
echo "OK: No nested .git."
echo "OK: Source is staged as normal files."

echo
echo "Status:"
git status --short -- "$DEST"

echo
echo "=============================================="
echo " Finished"
echo "=============================================="
echo
echo "Commit:"
echo
echo 'git commit -m "Import MSM 5.4 techpack display"'
echo
echo "Push:"
echo
echo "git push"