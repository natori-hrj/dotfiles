# skills/backend-patterns.md
---
name: backend-patterns
description: バックエンド開発パターンとベストプラクティス
---

## アーキテクチャパターン

### レイヤードアーキテクチャ
```
┌─────────────────────────────┐
│      Presentation Layer     │  ← Controller, Routes
├─────────────────────────────┤
│       Business Layer        │  ← Services, Use Cases
├─────────────────────────────┤
│      Persistence Layer      │  ← Repositories, DAOs
├─────────────────────────────┤
│        Database Layer       │  ← Database, ORM
└─────────────────────────────┘
```

### クリーンアーキテクチャ
```
src/
├── domain/           # エンティティ、ビジネスルール
│   ├── entities/
│   └── repositories/ # インターフェース定義
├── application/      # ユースケース
│   └── usecases/
├── infrastructure/   # 外部依存の実装
│   ├── database/
│   └── external/
└── presentation/     # API、UI
    ├── controllers/
    └── routes/
```

---

## API設計パターン

### RESTful設計
```
# リソース指向のエンドポイント
GET    /users           # 一覧取得
GET    /users/:id       # 単体取得
POST   /users           # 作成
PUT    /users/:id       # 全体更新
PATCH  /users/:id       # 部分更新
DELETE /users/:id       # 削除

# ネストしたリソース
GET    /users/:id/posts # ユーザーの投稿一覧
POST   /users/:id/posts # ユーザーの投稿作成
```

### レスポンス形式
```json
// 成功レスポンス
{
  "data": {
    "id": "123",
    "name": "John"
  },
  "meta": {
    "timestamp": "2024-01-01T00:00:00Z"
  }
}

// エラーレスポンス
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}

// ページネーション
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "perPage": 20,
    "totalPages": 5
  }
}
```

### ステータスコード
| コード | 用途 |
|-------|------|
| 200 | 成功（GET, PUT, PATCH） |
| 201 | 作成成功（POST） |
| 204 | 成功（DELETE、レスポンスボディなし） |
| 400 | バリデーションエラー |
| 401 | 認証エラー |
| 403 | 認可エラー |
| 404 | リソースが見つからない |
| 409 | 競合（重複など） |
| 500 | サーバーエラー |

---

## 認証・認可パターン

### JWT認証
```typescript
// トークン生成
const token = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.JWT_SECRET,
  { expiresIn: '1h' }
);

// トークン検証ミドルウェア
const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};
```

### RBAC（Role-Based Access Control）
```typescript
// 権限チェックミドルウェア
const requireRole = (...roles: string[]) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
};

// 使用例
router.delete('/users/:id',
  authMiddleware,
  requireRole('admin'),
  deleteUser
);
```

---

## キャッシュパターン

### Cache-Aside パターン
```typescript
async function getUser(id: string): Promise<User> {
  // 1. キャッシュを確認
  const cached = await cache.get(`user:${id}`);
  if (cached) {
    return JSON.parse(cached);
  }

  // 2. DBから取得
  const user = await db.users.findById(id);

  // 3. キャッシュに保存
  await cache.set(`user:${id}`, JSON.stringify(user), 'EX', 3600);

  return user;
}

// キャッシュ無効化
async function updateUser(id: string, data: Partial<User>): Promise<User> {
  const user = await db.users.update(id, data);
  await cache.del(`user:${id}`);
  return user;
}
```

### キャッシュキー設計
```
# 命名規則: {entity}:{id}:{optional-suffix}
user:123
user:123:profile
user:123:posts:page:1
```

---

## エラーハンドリング

### カスタムエラークラス
```typescript
class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string
  ) {
    super(message);
    this.name = 'AppError';
  }
}

class ValidationError extends AppError {
  constructor(message: string, public details?: any[]) {
    super(400, 'VALIDATION_ERROR', message);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super(404, 'NOT_FOUND', `${resource} not found`);
  }
}
```

### グローバルエラーハンドラー
```typescript
const errorHandler = (err, req, res, next) => {
  logger.error({
    error: err.message,
    stack: err.stack,
    path: req.path,
  });

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: { code: err.code, message: err.message }
    });
  }

  return res.status(500).json({
    error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' }
  });
};
```

---

## ロギング

### 構造化ログ
```typescript
// Good: 構造化されたログ
logger.info('User created', {
  userId: user.id,
  email: user.email,
  source: 'registration',
});

// Bad: 文字列連結
logger.info('User created: ' + user.id);
```

### ログレベル
| レベル | 用途 |
|-------|------|
| error | エラー、例外 |
| warn | 警告、潜在的な問題 |
| info | 重要なイベント |
| debug | デバッグ情報 |
