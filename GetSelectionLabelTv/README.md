# GetSelectionLabelTv

## パラメーター

### tvName

- 必須

- 初期値: なし

対象となるテンプレート変数名を指定する。

```html
[[GetSelectionLabelTv? &tvName=`tags`]]
```

### searchVal

- 必須

- 初期値: なし

検索する値を指定する。

```html
[[GetSelectionLabelTv? &tvName=`tags` &searchVal=`[*tags*]`]]
```

### docId

- 任意

- 初期値: 現在のリソースID

対象のリソースIDを指定する。
省略した場合は現在のリソースIDを対象とする。

```html
[[GetSelectionLabelTv? &docId=`3`]]
```

### delimiter

- 任意

- 初期値: '||'

選択肢間の区切り文字を指定する。

```html
[[GetSelectionLabelTv? &tvName=`tags` &searchVal=`[*tags*]` &delimiter=`,`]]
```

### outDelimiter

- 任意

- 初期値: ','

出力するラベルで複数ある場合の区切り文字を指定する。
`tpl`パラメーターの内容を結合する。

```html
[[GetSelectionLabelTv? &tvName=`tags` &searchVal=`[*tags*]` &outDelimiter=`|`]]
```

### tpl

- 任意

- 初期値: '@CODE:[+label+]'

出力するラベルの内容をHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[GetSelectionLabelTv? &tvName=`tags` &searchVal=`[*tags*]` &tpl=`@CODE:<span class="label">[+label+]</span>`]]
```

次のプレースホルダーを使用できる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| label | 選択肢の項目名。テンプレート変数の設定で「項目名||項目名」や「項目名==値」となっている部分。 | `[+label+]` |

### outerTpl

- 任意

- 初期値: '@CODE:[+wrap+]'


項目を囲う外側の内容をHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[GetSelectionLabelTv? &tvName=`tags` &searchVal=`[*tags*]` &outerTpl=`@CODE:<p class="labels">[+wrap+]</p>`]]
```

次のプレースホルダーを使用できる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| wrap | 展開される項目。 | `[+wrap+]` |

## 動作確認済み

| 項目 | バージョン |
|--|--|
| PHP | 8.2 |
| Evolution CMS | Community Edition 3.1.30 |
