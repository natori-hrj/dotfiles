#!/bin/bash
# git の書き込み系操作をブロックする。commit/push/merge/rebase は本人が実行する。
# 例外: ALLOWED_REPOS 配下で作業している場合のみ commit/push を許可する（merge/rebase は引き続きブロック）。
# PreToolUse(Bash) から呼ばれ、stdin にツール入力の JSON を受け取る。

# commit/push を許可するリポジトリのルート。追加する場合は1行1パスで足す。
ALLOWED_REPOS=(
  "/Users/natori/work/life"
)

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')

# 作業ディレクトリが許可リポジトリ配下かどうか
allowed=false
for repo in "${ALLOWED_REPOS[@]}"; do
  if [[ "$cwd" == "$repo" || "$cwd" == "$repo"/* ]]; then
    allowed=true
    break
  fi
done

# 許可リポジトリでは commit/push を素通しし、merge/rebase だけ残す。
# ブロック対象が変わるので、拒否メッセージの文言も分岐に合わせる。
if [[ "$allowed" == true ]]; then
  blocked_ops='merge|rebase'
  reason_ops='merge/rebase'
else
  blocked_ops='commit|push|merge|rebase'
  reason_ops='commit/push/merge/rebase'
fi

if printf '%s' "$cmd" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+($blocked_ops)([[:space:]]|$)"; then
  jq -n --arg c "$cmd" --arg ops "$reason_ops" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("git の " + $ops + " は本人が実行します。ここまでの作業を完了させて報告してください。ブロックしたコマンド: " + $c)
    }
  }'
  exit 0
fi
exit 0
