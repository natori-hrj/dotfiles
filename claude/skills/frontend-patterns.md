# skills/frontend-patterns.md
---
name: frontend-patterns
description: フロントエンド開発パターンとベストプラクティス
---

## React パターン

### コンポーネント設計

#### 関数コンポーネント
```tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
}

export function Button({
  variant = 'primary',
  size = 'md',
  children,
  onClick,
  disabled = false,
}: ButtonProps) {
  return (
    <button
      className={cn(styles.button, styles[variant], styles[size])}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

#### Compound Components
```tsx
<Card>
  <Card.Header>
    <Card.Title>タイトル</Card.Title>
  </Card.Header>
  <Card.Body>コンテンツ</Card.Body>
  <Card.Footer>
    <Button>アクション</Button>
  </Card.Footer>
</Card>
```

### カスタムフック

#### データフェッチ
```tsx
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchUser() {
      try {
        setLoading(true);
        const data = await api.getUser(userId);
        if (!cancelled) setUser(data);
      } catch (err) {
        if (!cancelled) setError(err as Error);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchUser();
    return () => { cancelled = true; };
  }, [userId]);

  return { user, loading, error };
}
```

---

## 状態管理

### Context + useReducer
```tsx
interface AppState {
  user: User | null;
  theme: 'light' | 'dark';
}

type Action =
  | { type: 'SET_USER'; payload: User }
  | { type: 'LOGOUT' }
  | { type: 'TOGGLE_THEME' };

function appReducer(state: AppState, action: Action): AppState {
  switch (action.type) {
    case 'SET_USER':
      return { ...state, user: action.payload };
    case 'LOGOUT':
      return { ...state, user: null };
    case 'TOGGLE_THEME':
      return { ...state, theme: state.theme === 'light' ? 'dark' : 'light' };
    default:
      return state;
  }
}
```

### サーバー状態管理（TanStack Query）
```tsx
// データ取得
function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.getUsers(),
    staleTime: 5 * 60 * 1000,
  });
}

// データ更新
function useCreateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateUserInput) => api.createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

---

## パフォーマンス最適化

### メモ化
```tsx
// useMemo: 計算結果のメモ化
const expensiveValue = useMemo(() => {
  return items.filter(item => item.active).sort((a, b) => a.order - b.order);
}, [items]);

// useCallback: 関数のメモ化
const handleClick = useCallback((id: string) => {
  setSelectedId(id);
}, []);

// React.memo: コンポーネントのメモ化
const ListItem = memo(function ListItem({ item, onClick }: ListItemProps) {
  return <li onClick={() => onClick(item.id)}>{item.name}</li>;
});
```

### 遅延ロード
```tsx
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <HeavyComponent />
    </Suspense>
  );
}
```

### 仮想化
```tsx
import { FixedSizeList } from 'react-window';

function VirtualList({ items }: { items: Item[] }) {
  return (
    <FixedSizeList
      height={400}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>{items[index].name}</div>
      )}
    </FixedSizeList>
  );
}
```

---

## フォーム設計

### バリデーション（Zod）
```tsx
const userSchema = z.object({
  email: z.string().email('有効なメールアドレスを入力'),
  password: z
    .string()
    .min(8, '8文字以上')
    .regex(/[A-Z]/, '大文字を含める')
    .regex(/[0-9]/, '数字を含める'),
});
```

### アクセシビリティ
```tsx
<form onSubmit={handleSubmit}>
  <div>
    <label htmlFor="email">メールアドレス</label>
    <input
      id="email"
      type="email"
      aria-describedby="email-error"
      aria-invalid={!!errors.email}
    />
    {errors.email && (
      <span id="email-error" role="alert">{errors.email}</span>
    )}
  </div>
</form>
```

---

## ディレクトリ構成

### Feature-based構成
```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── api/
│   │   └── index.ts
│   └── users/
│       ├── components/
│       ├── hooks/
│       ├── api/
│       └── index.ts
├── components/          # 共通コンポーネント
│   └── ui/
├── hooks/               # 共通フック
├── lib/                 # ユーティリティ
└── styles/              # グローバルスタイル
```

---

## スタイリング

### Tailwind CSS
```tsx
// ユーティリティクラスの使用
<button className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
  ボタン
</button>

// cn()で条件付きクラス
<div className={cn(
  "p-4 rounded",
  isActive && "bg-blue-100",
  isDisabled && "opacity-50 cursor-not-allowed"
)}>
```

### CSS Modules
```tsx
import styles from './Button.module.css';

<button className={styles.button}>ボタン</button>
```
