#!/bin/bash
# 破壊的なコマンドを自動承認させず、必ず確認を挟む。
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

if printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])(rm|rmdir)[[:space:]]+[^;&|]*-[a-zA-Z]*[rf]'; then
  jq -n --arg c "$cmd" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: ("削除コマンドです。対象を確認してください: " + $c)
    }
  }'
fi
exit 0
