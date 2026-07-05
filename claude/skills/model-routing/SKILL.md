---
name: model-routing
description: タスクに応じてClaudeモデル（Fable/Opus/Sonnet/Haiku）を賢く使い分け、コストと品質を最適化する。サブエージェント委譲・並列探索・一括処理・レビュー検証など、モデル選択が絡む場面で使用。「安く済ませたい」「大量に処理したい」「もっと賢いモデルで」等の要望時にも参照。
---

# Model Routing — モデルの賢い使い分け

メインセッションのモデルは変えず、**サブエージェント（Agent tool / Workflow / agents定義）に安い・速いモデルを割り当てる**のが基本戦略。モデル切り替えはキャッシュを無効化するため、メインループは固定し、委譲先で使い分ける。

## モデル早見表（2026-06時点）

| モデル | model指定 | Input/Output ($/1M) | 特性 |
|---|---|---|---|
| Fable 5 | `fable` | $10 / $50 | 最高知能。長時間の自律作業・最難関の推論。thinking常時ON |
| Opus 4.8 | `opus` | $5 / $25 | 高知能の主力。設計・難しいデバッグ・検証。fast mode対応 |
| Sonnet 5 | `sonnet` | $3 / $15 | コーディングの実用最強コスパ。Opus級の実装力 |
| Haiku 4.5 | `haiku` | $1 / $5 | 最速・最安。機械的作業の並列実行に最適 |

コスト比はおおよそ **Haiku 1 : Sonnet 3 : Opus 5 : Fable 10**（output側で 1 : 3 : 5 : 10）。

## 使い分けの判断基準

### haiku に委譲するタスク
- ファイル探索・grep的な網羅調査（Explore agentのfan-out）
- 大量ファイルの要約・分類・一覧化
- 定型的な変換（フォーマット統一、単純な一括置換の下調べ）
- 「どこにあるか」を探すだけで「正しいか」の判断が不要な作業

### sonnet に委譲するタスク
- 標準的な実装・リファクタリング・テスト作成
- コードレビューの一次パス（機械的チェック）
- ドキュメント生成
- 単一ファイル〜数ファイル規模の独立した修正

### opus に委譲するタスク
- アーキテクチャ設計・技術選定（→ `architect`, `planner` agent）
- 複雑なデバッグ・原因調査（複数ファイル横断の推論）
- セキュリティ分析（→ `security-reviewer` agent）
- findingの敵対的検証（本当にバグか反証を試みる）

### fable / メインセッション（model指定なし=継承）
- 最終的な統合・判断・ユーザーへの報告
- 委譲するか迷うタスク → **modelを省略**（セッションのモデルを継承。これがデフォルトで正解）

## 実行手段

### 1. Agent tool の `model` パラメータ
```
Agent(subagent_type: "Explore", model: "haiku", prompt: "...")   // 探索は安く
Agent(subagent_type: "general-purpose", model: "sonnet", prompt: "実装タスク...")
Agent(model: "opus", prompt: "この失敗の根本原因を特定して...")
```
独立したタスクは**1メッセージで複数並列起動**する。

### 2. Workflow の `agent()` オプション
```js
agent(prompt, {model: "haiku", effort: "low"})    // 機械的ステージ
agent(prompt, {model: "opus", effort: "high"})    // 検証・判定ステージ
```
- 探索/収集ステージ → `model: "haiku"`, `effort: "low"`
- 実装/変換ステージ → `model: "sonnet"`
- 検証/judge/合議ステージ → `model: "opus"` または省略（継承）

### 3. agents/*.md の frontmatter（設定済み）
| agent | model | 理由 |
|---|---|---|
| architect / code-reviewer / security-reviewer | opus | 深い推論が必要 |
| planner / tdd-guide | sonnet | 構造化作業でコスパ重視 |

### 4. effort パラメータ（モデル選択と直交する第2のレバー）
モデルを落とす前に effort を落とすことも検討する:
- `low`: サブエージェントの機械的作業
- `high`: 標準（省略時のデフォルト相当）
- `xhigh`: コーディング・エージェント作業の最難関部分のみ

## 典型パターン

**並列探索 → 統合**: haiku×N で候補箇所を洗い出し → メインモデルが読んで判断

**実装 → レビュー**: sonnet で実装 → opus (`code-reviewer`) でレビュー → メインが修正判断

**find → verify**: sonnet でfinding収集 → opus で敵対的検証（偽陽性を落とす）→ 確定分のみ報告

**一括移行**: 対象リストをメインが作成 → sonnet×N が worktree分離で並列変換 → opus が抜き取り検証

## アンチパターン

- ❌ ファイル横断の推論が必要なタスクを haiku に落とす（安物買いの銭失い。やり直しで高くつく）
- ❌ grep で済む探索に opus を使う
- ❌ 迷ったときに無理にモデルを指定する → **省略して継承が正解**
- ❌ 「コスト削減のため」メインセッションの判断・統合まで安いモデルに委譲する
- ❌ 検証なしで haiku/sonnet の出力をそのまま最終成果物にする（安いモデルの出力ほど検証を挟む）

## API直接利用時の注意

Claude API のコードを書く場合のモデルIDは `claude-opus-4-8` / `claude-sonnet-5` / `claude-haiku-4-5` / `claude-fable-5`（日付サフィックス不要）。詳細は claude-api skill を参照。API利用ではユーザーが明示しない限り `claude-opus-4-8` がデフォルト。
