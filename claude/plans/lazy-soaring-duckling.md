# サンプルページ作成プラン

## 目標

以下のページを作成し、ユーザーが自分で編集できるサンプルコンテンツを用意する:
1. **Blog** - Markdown形式で記事を書ける仕組み
2. **Projects** - プロジェクト紹介ページ
3. **Tech Stack** - 技術スタック紹介ページ
4. **Uses** - 開発環境・ツール紹介ページ

## 実装アプローチ

### 1. Markdown Blog機能の実装

**使用ツール:** mdsvex (SvelteKit向けMarkdownプロセッサ)

**理由:**
- SvelteKitとの完璧な統合
- Markdownファイル内でSvelteコンポーネントが使用可能
- フロントマター（メタデータ）のサポート
- 既に`@tailwindcss/typography`がインストール済みなので、Markdownのスタイリングが簡単

**実装手順:**

#### ステップ1.1: 依存関係のインストール
```bash
npm install -D mdsvex
```

#### ステップ1.2: svelte.config.jsの更新
mdsvexプリプロセッサを追加:
```javascript
import { mdsvex } from 'mdsvex';

const config = {
  extensions: ['.svelte', '.md'],
  preprocess: [vitePreprocess(), mdsvex()],
  // ...
};
```

#### ステップ1.3: ブログ記事ディレクトリ構造の作成
```
src/routes/blog/
├── +page.svelte              # ブログ一覧ページ（既存）
├── +page.ts                  # 記事メタデータを取得
├── [slug]/
│   ├── +page.svelte          # 個別記事ページ
│   └── +page.ts              # 記事データをロード
└── posts/
    ├── hello-world.md        # サンプル記事1
    └── sveltekit-guide.md    # サンプル記事2
```

#### ステップ1.4: サンプルMarkdown記事の作成
各記事にフロントマターを含める:
```markdown
---
title: "記事タイトル"
date: "2026-01-10"
description: "記事の説明"
tags: ["SvelteKit", "Markdown"]
published: true
---

# 記事内容

本文...
```

#### ステップ1.5: ブログ一覧ページの更新
動的に記事を読み込むように`blog/+page.svelte`を更新

#### ステップ1.6: 個別記事ページの作成
`blog/[slug]/+page.svelte`でMarkdownを表示

### 2. Projectsページの作成

**ファイル:** `src/routes/projects/+page.svelte`

**内容:**
- プロジェクトカード（タイトル、説明、技術スタック、リンク）
- サンプルプロジェクト3つ程度
- グリッドレイアウト
- ダークモード対応

**データ構造例:**
```typescript
{
  title: "プロジェクト名",
  description: "プロジェクトの説明",
  technologies: ["Python", "PostgreSQL", "Docker"],
  github: "https://github.com/...",
  demo: "https://..."
}
```

### 3. Tech Stackページの作成

**ファイル:** `src/routes/tech-stack/+page.svelte`

**内容:**
- カテゴリ別の技術リスト（言語、フレームワーク、データベース、インフラ、ツール）
- アイコン付き（lucide-svelteを活用）
- スキルレベル表示（オプション）
- ダークモード対応

**カテゴリ例:**
- バックエンド言語
- データベース
- インフラ・クラウド
- 開発ツール
- アジャイル・プロジェクト管理

### 4. Usesページの作成

**ファイル:** `src/routes/uses/+page.svelte`

**内容:**
- 開発環境のセクション分け（エディタ、ターミナル、ツール、ハードウェア）
- 各項目の説明
- シンプルなリストレイアウト
- ダークモード対応

**セクション例:**
- エディタ・IDE
- ターミナル環境
- 開発ツール
- ブラウザ拡張機能
- ハードウェア

### 5. ナビゲーションの更新

**ファイル:** `src/routes/+layout.svelte`

現在のナビゲーション:
- Blog ✅
- About ✅

追加するリンク:
- Projects
- Tech Stack (または Skills)
- Uses

レスポンシブ対応を考慮（モバイルでは省略またはハンバーガーメニュー）

## 影響を受けるファイル

### 新規作成
- `src/routes/blog/+page.ts` - ブログ一覧データ
- `src/routes/blog/[slug]/+page.svelte` - 個別記事ページ
- `src/routes/blog/[slug]/+page.ts` - 記事データローダー
- `src/routes/blog/posts/hello-world.md` - サンプル記事1
- `src/routes/blog/posts/sveltekit-guide.md` - サンプル記事2
- `src/routes/projects/+page.svelte` - プロジェクトページ
- `src/routes/tech-stack/+page.svelte` - 技術スタックページ
- `src/routes/uses/+page.svelte` - 開発環境ページ

### 変更
- `package.json` - mdsvex追加
- `svelte.config.js` - mdsvex設定
- `src/routes/blog/+page.svelte` - 動的データ読み込みに更新
- `src/routes/+layout.svelte` - ナビゲーションリンク追加（必要に応じて）

## 検証方法

### 1. Markdown Blogのテスト
```bash
npm run dev
```

- http://localhost:5173/blog にアクセス
- サンプル記事が一覧表示されるか確認
- 記事をクリックして個別ページが表示されるか確認
- Markdownが正しくレンダリングされているか確認
- ダークモードで見やすいか確認

### 2. 各ページのテスト
- http://localhost:5173/projects
- http://localhost:5173/tech-stack
- http://localhost:5173/uses

各ページで:
- レイアウトが崩れていないか
- ダークモード切り替えが正常に動作するか
- サンプルデータが表示されているか
- 編集しやすい構造になっているか

### 3. ナビゲーションのテスト
- ヘッダーのナビゲーションリンクがすべて動作するか
- モバイル表示でも問題ないか

## ユーザー編集ガイド

実装後、ユーザーが編集する際のポイント:

### Blogの編集方法
1. `src/routes/blog/posts/` に新しい `.md` ファイルを作成
2. フロントマターに必要な情報を記載
3. Markdown形式で本文を記述
4. ファイル名がURLのslugになる（例: `my-post.md` → `/blog/my-post`）

### Projects/Tech Stack/Usesの編集方法
1. 各ページの`.svelte`ファイルを開く
2. `<script>`タグ内のデータ配列を編集
3. 項目を追加・削除・修正

## 参考資料

- [mdsvex Documentation](https://mdsvex.pngwn.io/)
- [SvelteKit Routing](https://kit.svelte.dev/docs/routing)
- [Tailwind Typography Plugin](https://tailwindcss.com/docs/typography-plugin)
