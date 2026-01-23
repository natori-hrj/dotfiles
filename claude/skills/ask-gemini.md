---
name: ask-gemini
description: Web検索専用。Gemini CLIで最新情報を検索。機密情報は自動的にブロック。公式ドキュメント、ライブラリ情報、技術トレンドの調査に使用。
---

# Gemini Web Search

Gemini CLIで**Web検索専用**。機密情報は絶対に送信しない。

## セキュリティルール

**絶対に送信禁止**:
- 社内プロジェクト固有の情報
- データベース名、テーブル名
- API Key、パスワード
- 社員メール、個人情報

**安全な検索**:
- GCP/AWS公式ドキュメント
- ライブラリのベストプラクティス
- 技術トレンド

## 使い方

```bash
# 基本的な使い方
gemini -p "search for: <public topic>"

# 例（安全）
gemini -p "search for: GCP Cloud Run best practices 2025"
gemini -p "search for: Svelte 5 new features"
gemini -p "search for: Python asyncio patterns"
```

> CLIのコマンド形式は変更される可能性あり。`gemini --help`で最新を確認。

## いつ使うか

✅ 最新のドキュメントが必要
✅ 新しいライブラリを調査
✅ エラーメッセージを検索

❌ 社内情報を含む質問
❌ コードレビュー（ask-codexを使う）

## コスト

無料（Gemini API無料枠: 60リクエスト/分、1,000リクエスト/日）
