# IterateTVOptions

テンプレート変数の選択肢を繰り返すスニペット。
入力タイプが「DropDown List Menu」など、選択肢が存在するテンプレート変数を繰り返して処理することができる。
テンプレート変数の「オプション」項目で入力されている内容を繰り返して処理をする。

## パラメーター

### tvName

- 必須

- 初期値: 空

対象となるテンプレート変数名を指定する。

```html
[[IterateTVOptions? &tvName=`news-labels`]]
```

### delimiter

- 任意

- 初期値: '||'

選択肢間の区切り文字を指定する。

```html
[[IterateTVOptions? &tvName=`news-labels` &delimiter=`,`]]
```

### outerTpl

- 任意

- 初期値: '@CODE:<ul>[+wrap+]</ul>'


アイテムを囲う外側の内容をHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。


```html
[[IterateTVOptions?
  &tvName=`news-labels`
  &outerTpl=`@CODE:<div class="list">[+wrap+]</div>`
]]
```

次のプレースホルダーを使用できる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| wrap | 展開されるメニューアイテム。 | `[+wrap+]` |

### rowTpl

- 任意

- 初期値: '@CODE:<li>[+label+]</li>'

繰り返すアイテムのHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[IterateTVOptions?
  &tvName=`news-labels`
  &rowTpl=`<div class="item">[+label+]: [+value+]</div>`]]
```

次のプレースホルダーを使用できる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| label | 選択肢の項目名。テンプレート変数の設定で「項目名||項目名」や「項目名==値」となっている部分。 | `[+label+]` |
| value | 選択肢の項目名。テンプレート変数の設定で「項目名==値」となっている部分。値の指定がない「項目名||項目名」となっていた場合は項目名を出力する。 | `[+value+]` |
| tvName | テンプレート変数名。。 | `[+tvName+]` |
| index | 繰り返されているアイテムのインデックス番号。 | `[+index+]` |

## 動作確認済み

| 項目 | バージョン |
|--|--|
| PHP | 8.2 |
| Evolution CMS | Community Edition 3.1.30 |
