# commands/codex.md
---
name: codex
description: Codex CLIでコードレビュー・技術相談を実行
---

# Codex Consultation

Codex CLIを使用してコードレビューまたは技術相談を行う。

## 実行手順

1. ユーザーの依頼内容を確認
2. 適切なcodexコマンドを選択して実行
3. 結果をユーザーに報告

## コマンド例

### コードレビュー
```bash
# 未コミットの変更をレビュー
codex review --uncommitted

# 特定ファイルのレビュー
codex exec "以下のコードをレビューして:

$(cat <ファイルパス>)

特にセキュリティとパフォーマンスの観点で"
```

### 技術相談
```bash
codex exec "<質問内容>"
```

## 注意事項

- 簡単な実装（50行未満、単純なCRUD）はClaude単独で対応
- Web検索が必要な場合はask-geminiを使用
- Codexの回答は参考意見として扱い、最終判断はユーザーに委ねる
