# commands/issue.md
---
name: issue
description: 踏んだバグを、そのプロジェクトの流儀に沿ったissue本文に仕上げる（投稿は本人）
---

# Issue Reporting

OSSツールでバグを踏んだとき、**受け入れられるissue**に仕上げる。

引数でリポジトリを指定できる（例: `/issue neovim/neovim`）。省略時は、直前の会話・作業ログから対象ツールとバグを特定する。特定できなければユーザーに聞く。

**投稿はしない。** 本文を出力して終わる。`gh issue create` はユーザーが実行する。

## 手順

### 1. 対象リポジトリを確定する

バグを踏んだツールと、**issueを出すべきリポジトリ**は一致しないことがある。

- プラグイン/拡張が原因ではないか（無効化して再現するか確認）
- モノレポや関連リポジトリに分かれていないか（`CONTRIBUTING.md` の "Related Projects" 等を確認）
- 上流ライブラリのバグではないか

```bash
gh repo view <owner>/<repo> --json name,description,hasIssuesEnabled
```

Issuesが無効なら、どこに報告すべきかを探して報告する。

### 2. 最小再現を作る

これが無いissueは高確率で `needs:repro` を付けられて放置される。

- 設定なし・プラグインなしの状態で再現するか（`nvim --clean`、`code --disable-extensions` など）
- 最小のコード/コマンド列まで削る
- 再現しないなら「自分の環境固有」の可能性を先に潰す

再現できなかった場合は、**その事実も含めて**書く（「クリーン環境では再現せず、〜の設定下でのみ発生」は有益な情報）。

### 3. 重複を検索する（**closedも含める**）

```bash
gh search issues --repo <owner>/<repo> "<キーワード>" --state all --limit 30
gh search prs --repo <owner>/<repo> "<キーワード>" --state all --limit 20
```

- 同じ現象のissueが既にあれば、**新規作成せず**そのissueに情報を追加する形を提案する
- closedのissueが「修正済み」なら、最新版/nightlyで再確認してから「再発」として報告する
- 既にopen PRがあるなら、issueではなくそのPRにコメントする方が早い

### 4. 最新版で再現するか確認する

古いバージョンのバグ報告は即クローズされる。

- 可能なら最新リリース、できればnightly/masterで確認
- 確認したバージョンを本文に明記する

### 5. そのプロジェクトの流儀に合わせる

**必ず読む:**

```bash
gh api repos/<owner>/<repo>/contents/.github/ISSUE_TEMPLATE --jq '.[].name'
gh api repos/<owner>/<repo>/contents/CONTRIBUTING.md --jq '.content' | base64 -d
```

- ISSUE_TEMPLATE（yml形式のフォーム含む）があれば**その項目に厳密に従う**
- CONTRIBUTING.md に報告前のチェックリストがあれば全部消化する
- プロジェクト固有の作法を拾う
  - 例: Neovimは `Problem:` / `Expected behavior:` の構造、`nvim --clean` での再現が必須
  - 例: VS Codeは拡張を全無効化しての再現確認が必須
- 既存の「よく書けているissue」を1〜2本読んで、粒度とトーンを合わせる

### 6. 本文を書く

必須要素:

- **Problem** — 何が起きるか。事実のみ。推測は分けて書く
- **Steps to reproduce** — 番号付き。コピペで実行できる形
- **Expected behavior** — 何を期待したか
- **Actual behavior** — 実際に何が起きたか（エラーメッセージは全文、省略しない）
- **Environment** — バージョン、OS、関連する設定。`nvim --version` 等の出力をそのまま
- **調査済みの内容** — 原因の当たりが付いていれば該当ソースの行を `path/to/file.c:123` やpermalinkで示す

避けること:

- 複数のバグを1つのissueに混ぜる
- 「〜すべき」という要望と、バグ報告を混ぜる
- 再現手順のないスクリーンショットのみ
- 冗長な前置き・謝辞。メンテナは大量のissueを捌いている
- AI生成特有の水増し（箇条書きの過剰、同じことの言い換え）。**簡潔に、情報密度高く**

### 7. 出力

そのまま貼れる状態で本文を出す。加えて:

- 想定される **重複候補のissue番号**（あれば）
- 付けるべきラベルの候補（プロジェクトの慣習に沿って）
- 投稿用コマンドを提示する（**実行はしない**）

```bash
gh issue create --repo <owner>/<repo> --title "<title>" --body-file <path>
```

## 注意

- 機密情報（トークン、社内パス、顧客データ）が再現手順やログに混ざっていないか、出力前に必ず確認する
- 日本語で書かれた本文をそのまま出さない。**issueは対象プロジェクトの言語（通常は英語）で書く**
- セキュリティ脆弱性は公開issueにしない。`SECURITY.md` の報告手順に従うようユーザーに伝える
