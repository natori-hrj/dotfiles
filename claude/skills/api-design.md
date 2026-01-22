# skills/api-design.md
---
name: api-design
description: API設計パターンとベストプラクティス
---

## RESTful API設計

### URL設計
```
# リソース名は複数形の名詞
GET    /users              # ユーザー一覧
GET    /users/:id          # ユーザー詳細
POST   /users              # ユーザー作成
PUT    /users/:id          # ユーザー更新（全体）
PATCH  /users/:id          # ユーザー更新（部分）
DELETE /users/:id          # ユーザー削除

# ネストは2階層まで
GET    /users/:id/posts    # ユーザーの投稿一覧
POST   /users/:id/posts    # ユーザーの投稿作成

# 3階層以上はクエリパラメータ
GET    /comments?postId=123&userId=456

# アクションが必要な場合は動詞を使用
POST   /users/:id/activate
POST   /orders/:id/cancel
```

### クエリパラメータ
```
# フィルタリング
GET /users?status=active&role=admin

# ソート
GET /users?sort=created_at&order=desc
GET /users?sort=-created_at  # -で降順

# ページネーション
GET /users?page=2&limit=20
GET /users?cursor=abc123&limit=20

# フィールド選択
GET /users?fields=id,name,email

# 検索
GET /users?q=john
GET /users?search=john@example.com
```

---

## リクエスト/レスポンス設計

### リクエストボディ
```json
// POST /users
{
  "email": "user@example.com",
  "name": "John Doe",
  "password": "securePassword123"
}

// PATCH /users/:id
{
  "name": "Jane Doe"
}
```

### 成功レスポンス
```json
// 単一リソース
{
  "data": {
    "id": "123",
    "type": "user",
    "attributes": {
      "email": "user@example.com",
      "name": "John Doe",
      "createdAt": "2024-01-15T10:00:00Z"
    }
  }
}

// コレクション
{
  "data": [
    { "id": "1", "name": "User 1" },
    { "id": "2", "name": "User 2" }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "perPage": 20,
    "totalPages": 5
  },
  "links": {
    "self": "/users?page=1",
    "next": "/users?page=2",
    "last": "/users?page=5"
  }
}
```

### エラーレスポンス
```json
// バリデーションエラー (400)
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力内容に問題があります",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "有効なメールアドレスを入力してください"
      },
      {
        "field": "password",
        "code": "TOO_SHORT",
        "message": "パスワードは8文字以上必要です"
      }
    ]
  }
}

// 認証エラー (401)
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "認証が必要です"
  }
}

// リソース未発見 (404)
{
  "error": {
    "code": "NOT_FOUND",
    "message": "ユーザーが見つかりません",
    "resource": "user",
    "resourceId": "123"
  }
}
```

---

## バージョニング

### 方式比較
```
# URLパス（推奨）
GET /v1/users
GET /v2/users

# ヘッダー
Accept: application/vnd.api+json; version=1

# クエリパラメータ
GET /users?version=1
```

### バージョン管理のポリシー
```
- メジャーバージョン変更: 破壊的変更がある場合
- 旧バージョンは最低6ヶ月サポート
- 非推奨の告知は3ヶ月前に実施
- レスポンスヘッダーで非推奨を通知
  Deprecation: true
  Sunset: Sat, 31 Dec 2024 23:59:59 GMT
```

---

## 認証・認可

### Bearer Token
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

# レスポンス例（認証成功）
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "dGhpcyBpcyBhIHJlZnJl..."
}
```

### API Key
```
# ヘッダーで送信
X-API-Key: your-api-key-here

# または クエリパラメータ（非推奨）
GET /users?api_key=your-api-key-here
```

### スコープベースの認可
```json
// トークンのペイロード
{
  "sub": "user-123",
  "scopes": ["users:read", "users:write", "posts:read"]
}

// 必要なスコープをエンドポイントで定義
// GET /users requires: users:read
// POST /users requires: users:write
```

---

## レート制限

### ヘッダー
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705312800

# 制限超過時 (429 Too Many Requests)
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "リクエスト数が上限に達しました",
    "retryAfter": 60
  }
}
```

### 制限設計
```
# エンドポイント別
/auth/login    : 5 req/min（ブルートフォース対策）
/api/*         : 100 req/min（一般API）
/api/search    : 30 req/min（重い処理）

# ユーザー種別
無料プラン     : 100 req/hour
有料プラン     : 1000 req/hour
エンタープライズ: 無制限
```

---

## ドキュメント

### OpenAPI (Swagger)
```yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0

paths:
  /users:
    get:
      summary: ユーザー一覧を取得
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserList'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        name:
          type: string
      required:
        - id
        - email
        - name
```

---

## セキュリティ

### 必須ヘッダー
```
# CORS
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization

# セキュリティ
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

### 入力検証
```typescript
// すべての入力を検証
const createUserSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100),
  password: z.string().min(8).max(100),
});

// IDの形式を検証
const uuidSchema = z.string().uuid();
```
