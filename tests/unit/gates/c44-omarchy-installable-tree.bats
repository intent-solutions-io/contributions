#!/usr/bin/env bats

load '../test_helper'
bats_require_minimum_version 1.5.0

setup() {
  TREE=$(mktemp -d)
  /usr/bin/git -C "$TREE" init -q .
  /usr/bin/git -C "$TREE" -c user.email=test@example.com -c user.name=test \
    commit -q --allow-empty -m init
  printf '%s\n' '{"name":"t","version":"1.0.0","entryPoints":{"bar":"Bar.qml"}}' \
    > "$TREE/manifest.json"
}

teardown() { rm -rf "$TREE"; }

run_gate() {
  local input_json
  input_json=$(jq -nc --arg t "$TREE" \
    '{candidate:$t,dossier:"",action:"pr_open",env:{repo:"o/r",branch:"main"}}')
  run --separate-stderr bash -c 'printf "%s" "$1" | "$2"' _ "$input_json" \
    "$GATES_DIR/c44-omarchy-installable-tree.sh"
}

sev() { printf '%s' "$output" | jq -r '.severity'; }

@test "c44 passes a clean installable plugin tree" {
  run_gate
  [ "$status" -eq 0 ]
  [ "$(sev)" = "PASS" ]
}

@test "c44 blocks an untracked root AGENTS.md" {
  printf '%s\n' '# Local agent notes' > "$TREE/AGENTS.md"
  run_gate
  [ "$(sev)" = "BLOCK" ]
  [[ "$output" == *"AGENTS.md"* ]]
}

@test "c44 blocks a nested CLAUDE.md" {
  mkdir -p "$TREE/internal/agent"
  printf '%s\n' '# Local agent notes' > "$TREE/internal/agent/CLAUDE.md"
  run_gate
  [ "$(sev)" = "BLOCK" ]
  [[ "$output" == *"internal/agent/CLAUDE.md"* ]]
}
