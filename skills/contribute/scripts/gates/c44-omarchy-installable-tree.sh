#!/usr/bin/env bash
# Catalog: C44 - agent instruction files accidentally shipped inside an
# installable Omarchy plugin tree.
#
# Omarchy installs the repository as the plugin. AGENTS.md and CLAUDE.md are
# operator instructions, not runtime assets. Keeping them in the plugin tree
# enlarges the shipment and exposes workspace-only instructions to end users.
source "$(dirname "$0")/lib/preamble.sh"

gate_read_input
gate_resolve_tree

if [[ -z "$GATE_TREE_DIR" || ! -f "$GATE_TREE_DIR/manifest.json" ]]; then
  gate_skip "not an Omarchy plugin tree"
fi
if ! jq -e '.entryPoints' "$GATE_TREE_DIR/manifest.json" >/dev/null 2>&1; then
  gate_skip "manifest.json declares no entryPoints; not an Omarchy plugin"
fi

HITS=$(gate_tree_files '(^|/)(AGENTS|CLAUDE)\.[mM][dD]$' || true)
if [[ -n "$HITS" ]]; then
  FILES=$(printf '%s\n' "$HITS" | LC_ALL=C sort | paste -sd ', ' -)
  gate_block "agent instruction file in installable plugin tree: $FILES" "keep operator and AI instructions in the containing workspace; do not ship AGENTS.md or CLAUDE.md with an Omarchy plugin"
fi

gate_pass "installable plugin tree excludes agent instruction files"
