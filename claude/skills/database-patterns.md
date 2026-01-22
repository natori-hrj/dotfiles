# skills/database-patterns.md
---
name: database-patterns
description: データベース設計パターンとベストプラクティス
---

## スキーマ設計

### 命名規則
```sql
-- テーブル名: 複数形、スネークケース
CREATE TABLE users (...)
CREATE TABLE order_items (...)

-- カラム名: スネークケース
user_id, created_at, is_active

-- 主キー: id または {table}_id
id SERIAL PRIMARY KEY
-- または
user_id UUID PRIMARY KEY

-- 外部キー: {referenced_table}_id
user_id REFERENCES users(id)
```

### 基本テーブル構造
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE  -- ソフトデリート用
);

-- 更新日時の自動更新トリガー
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

## リレーション設計

### 1対多（One-to-Many）
```sql
-- ユーザーと投稿
CREATE TABLE posts (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  content TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_posts_user_id ON posts(user_id);
```

### 多対多（Many-to-Many）
```sql
-- ユーザーとロール
CREATE TABLE roles (
  id UUID PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE user_roles (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);
```

### 自己参照
```sql
-- カテゴリの階層構造
CREATE TABLE categories (
  id UUID PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  parent_id UUID REFERENCES categories(id),
  depth INT DEFAULT 0
);
```

---

## インデックス戦略

### インデックスを作成すべきケース
```sql
-- 外部キー
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- 頻繁に検索するカラム
CREATE INDEX idx_users_email ON users(email);

-- 複合インデックス（検索順序を考慮）
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- 部分インデックス
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';
```

### インデックスを避けるケース
- カーディナリティが低いカラム（boolean等）
- 頻繁に更新されるカラム
- 小さなテーブル

---

## クエリパターン

### ページネーション
```sql
-- オフセットベース（シンプルだが大量データで遅い）
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 20 OFFSET 40;

-- カーソルベース（推奨）
SELECT * FROM posts
WHERE created_at < :last_created_at
ORDER BY created_at DESC
LIMIT 20;
```

### 集計
```sql
-- グループ化と集計
SELECT
  DATE_TRUNC('day', created_at) AS date,
  COUNT(*) AS count,
  SUM(amount) AS total
FROM orders
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY date;
```

### ウィンドウ関数
```sql
-- ランキング
SELECT
  user_id,
  score,
  RANK() OVER (ORDER BY score DESC) AS rank
FROM leaderboard;

-- 累計
SELECT
  date,
  amount,
  SUM(amount) OVER (ORDER BY date) AS running_total
FROM daily_sales;
```

---

## ORM パターン

### Repository パターン
```typescript
interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  create(data: CreateUserInput): Promise<User>;
  update(id: string, data: UpdateUserInput): Promise<User>;
  delete(id: string): Promise<void>;
}

class PrismaUserRepository implements UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async create(data: CreateUserInput): Promise<User> {
    return this.prisma.user.create({ data });
  }
  // ...
}
```

### トランザクション
```typescript
// Prisma
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });
  await tx.profile.create({
    data: { ...profileData, userId: user.id }
  });
  return user;
});

// Drizzle
await db.transaction(async (tx) => {
  const [user] = await tx.insert(users).values(userData).returning();
  await tx.insert(profiles).values({ ...profileData, userId: user.id });
  return user;
});
```

---

## マイグレーション

### 命名規則
```
YYYYMMDDHHMMSS_description.sql

例:
20240115120000_create_users_table.sql
20240115130000_add_email_to_users.sql
20240116100000_create_posts_table.sql
```

### 安全なマイグレーション
```sql
-- カラム追加（安全）
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- カラム削除（2段階で）
-- Step 1: コードから参照を削除
-- Step 2: カラムを削除
ALTER TABLE users DROP COLUMN old_column;

-- NOT NULL制約の追加（3段階で）
-- Step 1: カラム追加
ALTER TABLE users ADD COLUMN new_col VARCHAR(100);
-- Step 2: データ移行
UPDATE users SET new_col = 'default' WHERE new_col IS NULL;
-- Step 3: NOT NULL制約追加
ALTER TABLE users ALTER COLUMN new_col SET NOT NULL;
```

---

## パフォーマンス

### N+1問題の回避
```typescript
// Bad: N+1クエリ
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({
    where: { userId: user.id }
  });
}

// Good: Eager loading
const users = await prisma.user.findMany({
  include: { posts: true }
});
```

### クエリ最適化
```sql
-- EXPLAIN ANALYZEで実行計画を確認
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';

-- 不要なカラムを取得しない
SELECT id, name FROM users;  -- SELECT * を避ける

-- 存在確認はEXISTSを使用
SELECT EXISTS(SELECT 1 FROM users WHERE email = 'test@example.com');
```
