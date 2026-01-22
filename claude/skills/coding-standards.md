# skills/coding-standards.md
---
name: coding-standards
description: 言語別コーディング標準とベストプラクティス
---

## TypeScript / JavaScript

### 型安全性
```typescript
// Good: 明示的な型定義
interface User {
  id: string;
  name: string;
  email: string;
}

function getUser(id: string): Promise<User | null> {
  // ...
}

// Bad: any型の使用
function getUser(id: any): any {
  // ...
}
```

### Null安全
```typescript
// Good: Optional chaining と Nullish coalescing
const userName = user?.profile?.name ?? 'Anonymous';

// Bad: 深いネストの条件分岐
const userName = user && user.profile && user.profile.name
  ? user.profile.name
  : 'Anonymous';
```

### 非同期処理
```typescript
// Good: async/await
async function fetchData() {
  try {
    const response = await fetch(url);
    return await response.json();
  } catch (error) {
    handleError(error);
  }
}

// Bad: ネストしたPromise
function fetchData() {
  return fetch(url)
    .then(response => response.json())
    .then(data => process(data))
    .catch(error => handleError(error));
}
```

### インポート順序
```typescript
// 1. 外部ライブラリ
import React from 'react';
import { useState } from 'react';

// 2. 内部モジュール（絶対パス）
import { Button } from '@/components/ui';
import { useAuth } from '@/hooks';

// 3. 相対パス
import { helper } from './utils';
import styles from './styles.module.css';
```

---

## Python

### 型ヒント
```python
# Good: 型ヒントを活用
from typing import Optional, List

def get_users(limit: int = 10) -> List[dict]:
    ...

def find_user(user_id: str) -> Optional[User]:
    ...

# Bad: 型情報なし
def get_users(limit=10):
    ...
```

### コンテキストマネージャー
```python
# Good: with文でリソース管理
with open('file.txt', 'r') as f:
    content = f.read()

# Bad: 手動でのclose
f = open('file.txt', 'r')
content = f.read()
f.close()
```

### リスト内包表記
```python
# Good: 簡潔なリスト内包表記
squares = [x ** 2 for x in range(10) if x % 2 == 0]

# Bad: 冗長なループ
squares = []
for x in range(10):
    if x % 2 == 0:
        squares.append(x ** 2)
```

### 例外処理
```python
# Good: 具体的な例外をキャッチ
try:
    result = process_data(data)
except ValueError as e:
    logger.error(f"Invalid data: {e}")
    raise
except ConnectionError as e:
    logger.error(f"Connection failed: {e}")
    return None

# Bad: 汎用的なException
try:
    result = process_data(data)
except Exception:
    pass
```

---

## Go

### エラーハンドリング
```go
// Good: エラーを適切に処理
func GetUser(id string) (*User, error) {
    user, err := db.FindUser(id)
    if err != nil {
        return nil, fmt.Errorf("failed to get user %s: %w", id, err)
    }
    return user, nil
}

// Bad: エラーを無視
func GetUser(id string) *User {
    user, _ := db.FindUser(id)
    return user
}
```

### インターフェース
```go
// Good: 小さなインターフェース
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// 必要に応じて組み合わせ
type ReadWriter interface {
    Reader
    Writer
}
```

### 構造体の初期化
```go
// Good: 明示的なフィールド名
user := User{
    ID:    "123",
    Name:  "John",
    Email: "john@example.com",
}

// Bad: 順序依存
user := User{"123", "John", "john@example.com"}
```

---

## 共通原則

### DRY（Don't Repeat Yourself）
- 同じロジックを3回以上書いたら抽象化を検討
- ただし早すぎる抽象化は避ける

### KISS（Keep It Simple, Stupid）
- シンプルな解決策を優先
- 複雑さは必要になってから追加

### YAGNI（You Ain't Gonna Need It）
- 将来必要になるかもしれない機能を先に実装しない
- 現在の要件に集中

### 可読性優先
- コードは書く時間より読む時間の方が長い
- 明確な命名、適切なコメント、一貫したフォーマット
