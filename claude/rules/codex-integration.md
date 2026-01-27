# rules/codex-integration.md
---
name: codex-integration
description: Codex CLI自動呼び出しルール
---

## 自動発動条件

以下のキーワードが含まれる依頼では、Codex CLIを使用する:

- 「codexにレビュー」「codexでレビュー」
- 「codexに聞いて」「codexに相談」
- 「codexの意見」「codexに確認」
- 「Codex」（大文字始まりも同様）

## 実行方法

### コードレビューの場合
```bash
# 未コミットの変更がある場合
codex review --uncommitted

# 特定ファイルの場合
codex exec "以下のコードをレビューして:

$(cat <対象ファイル>)

<レビュー観点があれば追加>"
```

### 技術相談の場合
```bash
codex exec "<相談内容を整理して渡す>"
```

## 使わないケース

- 単純な質問（Claudeで十分回答可能）
- Web検索が必要（ask-geminiを使用）
- 50行未満の簡単なコード

## 結果の扱い

1. Codexの回答をそのまま表示
2. 必要に応じてClaudeの見解も追加
3. 意見が異なる場合は両方の視点を提示
