---
name: ask-codex
description: コードレビューと技術相談。Codex CLIを使用。アーキテクチャ設計、リファクタリング判断、パフォーマンス最適化の相談役。
---

# Codex Consultation & Review

Codex CLIで**コードレビューと技術相談**。

> モデルは環境設定に依存（`~/.codex/config.toml`で確認）

## いつ使うか

✅ **実装前**: アーキテクチャ設計のレビュー
✅ **実装中**: 技術的な判断に迷ったとき
✅ **実装後**: コードレビュー

❌ 簡単な実装（50行未満、単純なCRUD、既知パターン → Claudeだけで十分）
❌ Web検索（ask-geminiを使う）

## 使い方

### アーキテクチャレビュー
```bash
codex exec "このシステム設計をレビューして:
- TinySwallow (on-device) for quick analysis
- OpenAI API for detailed review
- Cloud Run deployment

懸念点は？"
```

### 技術相談
```bash
codex exec "オンデバイスLLMとクラウドLLMを
切り替える最適な設計パターンは？
要件: レスポンス1秒以内"
```

### コードレビュー
```bash
# 特定ファイルのレビュー
codex exec "以下のコードをレビューして:

$(cat app.py)

特にセキュリティとパフォーマンスの観点で"

# 未コミットの変更をレビュー
codex review --uncommitted
```

## Codexとの付き合い方

1. **コンテキストを明確に**: 背景、制約を具体的に
2. **具体的な質問**: 「これ良い？」ではなく「この設計の懸念点は？」
3. **鵜呑みにしない**: なぜその提案なのか理解する
4. **比較検討**: 自分の考えとCodexの意見を両方評価
5. **最終判断は自分**: AIの意見は参考、決めるのは自分

**重要**: ClaudeとCodexが意見が違うときは、両方の視点を考える良い機会。

## コスト（目安）

- 簡単な相談: ~$0.02/回
- アーキテクチャレビュー: ~$0.08/回
- 月間想定: $2-3（週10回使用）

> 最新の料金は [OpenAI Pricing](https://openai.com/pricing) を参照
