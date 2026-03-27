#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# install.sh — install orchestrator into the current system
#
# What it does:
#   1. Symlinks bin/letsgo → ~/.local/bin/letsgo
#   2. Symlinks commands/*.md → ~/.claude/commands/
# -------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="${HOME}/.local/bin"
CLAUDE_COMMANDS_DIR="${HOME}/.claude/commands"

echo "Installing orchestrator from: $SCRIPT_DIR"
echo ""

# --- bin/letsgo ---
mkdir -p "$BIN_DIR"
ln -sf "$SCRIPT_DIR/bin/letsgo" "$BIN_DIR/letsgo"
chmod +x "$SCRIPT_DIR/bin/letsgo"
echo "  ✓ letsgo → $BIN_DIR/letsgo"

# --- commands ---
mkdir -p "$CLAUDE_COMMANDS_DIR"
for cmd in "$SCRIPT_DIR/commands/"*.md; do
  name=$(basename "$cmd")
  ln -sf "$cmd" "$CLAUDE_COMMANDS_DIR/$name"
  echo "  ✓ /$( echo "$name" | sed 's/\.md$//' ) → $CLAUDE_COMMANDS_DIR/$name"
done

# --- reviewers ---
REVIEWERS_DIR="${HOME}/.claude/letsgo/reviewers"
mkdir -p "$REVIEWERS_DIR"
for rev in "$SCRIPT_DIR/reviewers/"*.md; do
  name=$(basename "$rev")
  ln -sf "$rev" "$REVIEWERS_DIR/$name"
  echo "  ✓ reviewer: $( echo "$name" | sed 's/\.md$//' ) → $REVIEWERS_DIR/$name"
done

echo ""

# Check PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "⚠  $BIN_DIR is not in your PATH. Add it:"
  echo ""
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  echo "  Add this to your ~/.zshrc or ~/.bashrc."
else
  echo "✓ $BIN_DIR is in PATH"
fi

echo ""
echo "Done. Run 'letsgo' from any git repo to start a feature."
