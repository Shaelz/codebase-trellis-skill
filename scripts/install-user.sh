#!/usr/bin/env bash
# install-user.sh - installs codebase-trellis skill to the user-level Claude Code skills directory
#
# Usage:
#   ./scripts/install-user.sh
#   ./scripts/install-user.sh --force

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/../skills/codebase-trellis" && pwd)"
EXPECTED_PARENT_DIR="$HOME/.claude/skills"
DEST_DIR="$EXPECTED_PARENT_DIR/codebase-trellis"

FORCE=false
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

echo "Source : $SOURCE_DIR"
echo "Dest   : $DEST_DIR"

if [ -e "$DEST_DIR" ] || [ -L "$DEST_DIR" ]; then
    if [ "$FORCE" = false ]; then
        echo "Error: destination already exists: $DEST_DIR" >&2
        echo "Re-run with --force to overwrite." >&2
        exit 1
    fi
    if [ "$(dirname "$DEST_DIR")" != "$EXPECTED_PARENT_DIR" ] || [ "$(basename "$DEST_DIR")" != "codebase-trellis" ]; then
        echo "Error: refusing to remove unexpected destination: $DEST_DIR" >&2
        exit 1
    fi
    echo "[--force] Removing existing installation."
    rm -rf -- "$DEST_DIR"
fi

mkdir -p "$DEST_DIR"

cp -rf "$SOURCE_DIR/." "$DEST_DIR/"
echo "  Copied skill contents."

echo ""
echo "Installation complete."
echo ""
echo "Verification:"
echo "  1. Restart Claude Code if it is currently running."
echo "  2. Open any project and type: /codebase-trellis"
echo "  3. The skill should activate and begin the trellis workflow."
