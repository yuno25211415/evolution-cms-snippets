# IterateValues

文字列を分割して繰り返すスニペット。  
例えば"foo,bar,baz"といった区切り文字がある文字列を、その区切り文字で分割し、繰り返してHTMLにして返すことができる。

## 例

keywordsというテンプレート変数に"foo,bar,baz"が入力されている時。

before:

```html
[[IterateValues?
  &value=`[*keywords*]`
  &outerTpl=`@CODE:<ul class="keywords">[+wrap+]</ul>`
  &rowTpl=`@CODE:<li>[+value+]</li>`
]]
```

after:

```html
<ul class="keywords">
  <li>foo</li>
  <li>bar</li>
  <li>baz</li>
</ul>
```

## パラメーター

### value

- 必須
- 初期値: 空

対象となる文字列を指定する。

```html
[[IterateValues? &value=`[*keywords*]`]]
```

### delimiter

- 任意
- 初期値: ','

`value`パラメーターで分割とする区切り文字を指定する。

```html
[[IterateValues? &value=`[*keywords*]` &delimiter=`,`]]
```

### outerTpl

- 任意
- 初期値: '@CODE:[+wrap+]'

アイテムを囲う外側の内容をHTMLコードまたはチャンクを指定する。  
HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[IterateValues?
  &value=`[*keywords*]`
  &outerTpl=`@CODE:<div class="list">[+wrap+]</div>`
]]
```

次のプレースホルダーを使用できる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| wrap | 展開されるメニューアイテム。 | `[+wrap+]` |
| count | アイテムの総数。 | `[+count+]` |

### rowTpl

- 任意
- 初期値: '@CODE:[+value+]'

繰り返すアイテムのHTMLコードまたはチャンクを指定する。  
HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[IterateValues?
  &value=`[*keywords*]`
  &rowTpl=`<div class="item">[+value+]</div>`]]
```

次のプレースホルダーを使用できる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| value | 区切り文字で区切った文字列。 | `[+value+]` |
| index | アイテムのインデックス番号。 | `[+index+]` |

## 動作確認済み

| 項目 | バージョン |
|--|--|
| PHP | 8.2 |
| Evolution CMS | Community Edition 3.1.30 |
