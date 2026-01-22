# CLAUDE.md - プロジェクト設定

## プロジェクト概要
このファイルはClaude Codeの動作を制御するメイン設定です。

## 基本原則

### コード品質
- シンプルで読みやすいコードを書く
- 過度な抽象化を避ける
- 既存のコードスタイルに従う
- 不要な機能を追加しない

### セキュリティ
- APIキーやシークレットをハードコードしない
- ユーザー入力を必ず検証する
- 環境変数を使用する
- SQLインジェクション、XSS等のOWASP Top 10を防ぐ

### テスト
- ビジネスロジックにはユニットテスト必須
- APIにはインテグレーションテスト
- 重要なフローにはE2Eテスト
- テストカバレッジ80%以上を目標

## エージェント使用ガイドライン

### 以下の場合はエージェントに委譲
- 複雑な計画が必要なタスク → `planner`
- アーキテクチャ設計 → `architect`
- コードレビュー → `code-reviewer`
- セキュリティ分析 → `security-reviewer`
- TDD実践 → `tdd-guide`

### 直接対応するケース
- 単純なバグ修正
- 小規模なリファクタリング
- ドキュメント更新
- 設定ファイルの変更

## コマンド一覧
- `/plan` - 機能の実装計画を作成
- `/code-review` - コードレビューを実行
- `/tdd` - TDDサイクルで実装

## ファイル構成

```
claude/
├── CLAUDE.md          # このファイル（メイン設定）
├── agents/            # エージェント定義
│   ├── planner.md
│   ├── architect.md
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   └── tdd-guide.md
├── commands/          # スラッシュコマンド
│   ├── plan.md
│   ├── code-review.md
│   └── tdd.md
└── rules/             # 常に適用されるルール
    ├── security.md
    ├── testing.md
    ├── coding-style.md
    ├── git-workflow.md
    └── agents.md
```

## コンテキスト管理
- MCPサーバーは必要なもののみ有効化（10個以下推奨）
- 長いコンテキストでは要約を活用
- 関連ファイルのみを読み込む
