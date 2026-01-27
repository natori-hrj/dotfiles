# データベース設計・接続 実装計画

## 概要
PostgreSQL + async SQLAlchemy によるデータベース層の実装

## 前提条件
- 依存関係インストール済み: SQLAlchemy 2.0+, asyncpg, alembic
- DATABASE_URL設定済み: `postgresql+asyncpg://postgres:postgres@localhost:5432/code_review_db`
- Firebase認証実装済み（firebase_uidでユーザー識別）

---

## ファイル構成

```
backend/
├── alembic/                    # NEW: マイグレーション
│   ├── versions/
│   ├── env.py
│   └── script.py.mako
├── alembic.ini                 # NEW
├── app/
│   ├── db/                     # NEW: データベースモジュール
│   │   ├── __init__.py
│   │   └── session.py          # Async session factory
│   ├── models/
│   │   ├── __init__.py         # 更新: エクスポート
│   │   ├── base.py             # NEW: Base + SoftDeleteMixin
│   │   ├── user.py             # NEW
│   │   ├── chat_session.py     # NEW
│   │   ├── message.py          # NEW
│   │   └── code_review.py      # NEW
│   └── main.py                 # 更新: lifespan
└── tests/
    ├── conftest.py             # 更新: DB fixtures
    └── unit/
        └── test_models.py      # NEW
```

---

## データモデル

### ER図
```
User (1) ──────< (N) ChatSession (1) ──────< (N) Message
  │                      │
  │                      └── code_review_id (FK, optional)
  │                              │
  └──────< (N) CodeReview ──────┘
```

### テーブル定義

| Model | 主要フィールド | 特記事項 |
|-------|--------------|---------|
| User | firebase_uid (UQ), email, display_name | Firebase Auth と同期 |
| ChatSession | user_id (FK), title, status | Soft delete対応 |
| Message | session_id (FK), role, content, sequence | セッションに紐づく |
| CodeReview | user_id (FK), code_content, review_response | Soft delete対応 |

### 共通フィールド (Base)
- `id`: UUID (PK)
- `created_at`: timestamp with timezone
- `updated_at`: timestamp with timezone

### SoftDeleteMixin
- `deleted_at`: timestamp (nullable)

---

## 実装ステップ

### Step 1: Docker PostgreSQL起動
```bash
docker run --name postgres-dev \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=code_review_db \
  -p 5432:5432 -d postgres:15
```

### Step 2: データベース接続 (`app/db/session.py`)
- async engine作成 (pool_size=5, max_overflow=10)
- `get_db()` FastAPI dependency
- `close_db()` シャットダウン処理

### Step 3: モデル実装
1. `app/models/base.py` - Base, SoftDeleteMixin
2. `app/models/user.py` - User
3. `app/models/chat_session.py` - ChatSession, SessionStatus
4. `app/models/message.py` - Message, MessageRole
5. `app/models/code_review.py` - CodeReview, ReviewStatus

### Step 4: Alembic設定
```bash
alembic init -t async alembic
# env.py を非同期対応に修正
alembic revision --autogenerate -m "Initial models"
alembic upgrade head
```

### Step 5: main.py更新
- lifespan に `close_db()` 追加

### Step 6: テスト
- `tests/conftest.py` に async DB fixtures 追加
- `tests/unit/test_models.py` 作成

---

## 追加依存関係

```txt
# requirements-dev.txt に追加
aiosqlite>=0.19.0,<1.0.0
```

---

## 検証方法

1. **PostgreSQL接続確認**
   ```bash
   docker exec -it postgres-dev psql -U postgres -d code_review_db -c "\dt"
   ```

2. **マイグレーション確認**
   ```bash
   alembic upgrade head
   alembic downgrade -1
   alembic upgrade head
   ```

3. **テスト実行**
   ```bash
   pytest tests/ --cov=app --cov-report=term-missing
   ```

4. **API動作確認**
   ```bash
   uvicorn app.main:app --reload
   # http://localhost:8000/docs でSwagger UI確認
   ```

---

## 修正対象ファイル

| ファイル | 操作 |
|---------|------|
| `app/db/__init__.py` | 新規作成 |
| `app/db/session.py` | 新規作成 |
| `app/models/base.py` | 新規作成 |
| `app/models/user.py` | 新規作成 |
| `app/models/chat_session.py` | 新規作成 |
| `app/models/message.py` | 新規作成 |
| `app/models/code_review.py` | 新規作成 |
| `app/models/__init__.py` | 更新 |
| `app/main.py` | 更新 |
| `alembic.ini` | 新規作成 |
| `alembic/env.py` | 新規作成 |
| `tests/conftest.py` | 更新 |
| `tests/unit/test_models.py` | 新規作成 |
| `requirements-dev.txt` | 更新 |
