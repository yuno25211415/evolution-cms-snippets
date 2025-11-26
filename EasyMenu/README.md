# EasyMenu

メニューを簡単に作るためのスニペット。
スニペット「DLMenu」のメモリリークを解消するために開発を開始。
現状は最低限と思える部分のみで、未完成なものもあるので、気が向いたらとりかかろうと思う。

## パラメーター

基本的にDLMenuのパラメーターをベースにはしているが、一部変更していたり未実装な部分がある。

### parents

- 必須

基準となる親リソースのIDを指定する。
指定した親リソース配下のリソースをメニューとして作成する。

```html
[[EasyMenu? &parents=`3`]]
```

`documents`パラメーターが指定されていた場合はこの`parents`パラメーターが優先される。

### documents

- 必須

繰り返すリソースのIDを指定する。
指定したリソースをメニューとして作成する。
複数指定する場合はカンマ区切りで指定する。

```html
[[EasyMenu? &documents=`5,117,26`]]
```

`parents`パラメーターが指定されていた場合はこの`documents`パラメーターが優先される。

### where

- 初期値: 空

追加の条件をSQLの`WHERE`句と同じ書き方で指定する。
ただしリソース変数は先頭に`c.`を付ける必要がある。

```html
[[EasyMenu? &parents=`3` &where=`NOT c.id = 5`]]
```

### maxDepth

- 初期値: `-1`

サブリソースを含めてメニューを作成する場合、そのサブリソースの最大の深さを指定する。
1を最初の階層として指定。
`-1`で無制限。

```html
[[EasyMenu? &parents=`3` &maxDepth=`2`]]
```

### publicState

- 初期値: `1`

公開を対象とするか非公開を対象とするかを指定する。
`1`を指定すると公開のみ、`0`を指定すると非公開のみを対象とする。

```html
[[EasyMenu? &parents=`3` &publicState=`0`]]
```

### hideSubMenus

- 初期値: `0`

現在のページ以外のサブメニューを表示するかどうかを指定する。
`0`は現在のページの場合のみサブメニューを表示し、`1`はそれに関係なくサブメニューを表示する。

```html
[[EasyMenu? &parents=`3` &hideSubMenus=`1`]]
```


### ignoreHidden

- 初期値: `1`

「メニューに表示」項目で非表示としているリソースを除外するかどうかを指定する。
`1`を指定すると除外、`0`を指定すると除外しない。

```html
[[EasyMenu? &parents=`3` &ignoreHidden=`0`]]
```

### sortBy

- 初期値: `menuindex`

メニューの並び順の基準となる変数を指定する。
`orderBy`パラメーターと組み合わせて使用する。

```html
[[EasyMenu? &parents=`3` &sortBy=`pub_date`]]

[[EasyMenu? &parents=`3` &sortBy=`pub_date` &orderBy=`DESC`]]
```

- ※ 複数指定することはできない

### orderBy

- 初期値: `ASC`

メニューの並び順の方向を指定する。
昇順は`ASC`、降順は`DESC`を指定できる。
`sortBy`パラメーターと組み合わせて使用する。

```html
[[EasyMenu? &parents=`3` &orderBy=`DESC`]]

[[EasyMenu? &parents=`3` &sortBy=`pub_date` &orderBy=`DESC`]]
```

- ※ 複数指定することはできない

### tvList

- 初期値: 空

`rowTpl`パラメーターまたは`innerRowTpl`パラメーター内で使用可能にするテンプレート変数を指定する。
複数ある場合はカンマ区切りで指定する。

```html
[[EasyMenu? &parents=`3` &sortBy=`group,tag`]]
```

### outerTpl

- 初期値: `@CODE:<ul>[+wrap+]</ul>`

一番上（階層）のメニューアイテムを囲うHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[EasyMenu? &parents=`3` &outerTpl=`@CODE:<div>[+wrap+]</div>`]]
```

チャンクを指定する場合はチャンク名をそのまま指定する。

```html
<!--@- チャンク側: navigation_container_html -@-->
<div>[+wrap+]</div>
```

```html
<!--@- スニペット側 -@-->
[[EasyMenu? &parents=`3` &outerTpl=`navigation_container_html`]]
```

次のプレースホルダーを使用できる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| wrap | 展開されるメニューアイテム。 | `[+wrap+]` |

### rowTpl

- 初期値: `@CODE:<li[+classes+]><a href="[+url+]">[+title+]</a>[+wrap+]</li>`

メニューアイテムのHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[EasyMenu?
  &parents=`3`
  &outerTpl=`@CODE:<div>[+wrap+]</div>`
  &rowTpl=`@CODE:<a href="[+url+]"[+classes+]>[+title+]</a>`
]]
```

チャンクを指定する場合はチャンク名をそのまま指定する。

```html
<!--@- チャンク側: navigation_item_html -@-->
<a href="[+url+]">[+title+]</a>
```

```html
<!--@- スニペット側 -@-->
[[EasyMenu? &parents=`3` &outerTpl=`navigation_container_html` &rowTpl=`navigation_item_html`]]
```

プレースホルダ―は基本的なリソース変数に加え、テンプレート変数を使用することができる。
また、次の特殊なプレースホルダーも使用することができる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| title | リソース変数`pagetitle`。 | `[+title+]` |
| url | リソースのルート相対パス。 | `[+url+]` |
| classes |  | `[+classes+]` |
| wrap | 展開されるサブリソース。 | `[+wrap+]` |

### innerTpl

- 初期値: `outerTpl`パラメーターの内容

サブメニューアイテムを囲うHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[EasyMenu? &parents=`3` &innerTpl=`@CODE:<div>[+wrap+]</div>`]]
```

チャンクを指定する場合はチャンク名をそのまま指定する。

```html
<!--@- チャンク側: sub_navigation_container_html -@-->
<div>[+wrap+]</div>
```

```html
<!--@- スニペット側 -@-->
[[EasyMenu? &parents=`3` &innerTpl=`sub_navigation_container_html`]]
```

次のプレースホルダーを使用できる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| wrap | 展開されるメニューアイテム。 | `[+wrap+]` |

### innerRowTpl

- 初期値: `rowTpl`パラメーターの内容

サブメニューアイテムのHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[EasyMenu?
  &parents=`3`
  &innerTpl=`@CODE:<div>[+wrap+]</div>`
  &innerRowTpl=`@CODE:<a href="[+url+]"[+classes+]>[+title+]</a>`
]]
```

チャンクを指定する場合はチャンク名をそのまま指定する。

```html
<!--@- チャンク側: sub_navigation_item_html -@-->
<a href="[+url+]">[+title+]</a>
```

```html
<!--@- スニペット側 -@-->
[[EasyMenu? &parents=`3` &innerTpl=`sub_navigation_container_html` &innerRowTpl=`sub_navigation_item_html`]]
```

プレースホルダ―は基本的なリソース変数に加え、テンプレート変数を使用することができる。
また、次の特殊なプレースホルダーも使用することができる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| title | リソース変数`pagetitle`。 | `[+title+]` |
| url | リソースのルート相対パス。 | `[+url+]` |
| classes |  | `[+classes+]` |
| wrap | 展開されるサブリソース。 | `[+wrap+]` |

### hereClass

- 初期値: `active`

現在位置（カレント）の場合のクラス名を指定する。
クラス名を付与しない場合は空を指定する。

```html
[[EasyMenu? &parents=`3` &hereClass=`current`]]
```

### openClass

- 初期値: `open`

現在位置（カレント）が含まれる親の展開されている状態となるクラス名を指定する。
クラス名を付与しない場合は空を指定する。

```html
[[EasyMenu? &parents=`3` &openClass=`current`]]
```

### parentClass

- 初期値: 空

サブメニューが存在する親メニューアイテムのクラス名を指定する。
クラス名を付与しない場合は空を指定する。

```html
[[EasyMenu? &parents=`3` &parentClass=`parent`]]
```

### rowClass

- 初期値: 空

全てのメニューアイテムのクラス名を指定する。
クラス名を付与しない場合は空を指定する。

```html
[[EasyMenu? &parents=`3` &rowClass=`item`]]
```

## 動作確認済み

| 項目 | バージョン |
|--|--|
| PHP | 8.2 |
| Evolution CMS | Community Edition 3.1.27<br>Community Edition 3.1.29 |
