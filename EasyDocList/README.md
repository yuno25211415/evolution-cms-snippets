# EasyDocList

リストを簡単に作成するためのスニペット。
現状は最低限と思える部分のみで、未完成なものもあるので、気が向いたらとりかかろうと思う。

## パラメーター

### parents

- 必須

基準となる親リソースのIDを指定する。
指定した親リソース直下のリソースをリストとして作成する。

```html
[[EasyDocList? &parents=`13`]]
```

`documents`パラメーターが指定されていた場合はこの`parents`パラメーターが優先される。

### documents

- 必須

繰り返すリソースのIDを指定する。
指定したリソースをリストとして作成する。
複数指定する場合はカンマ区切りで指定する。

```html
[[EasyDocList? &documents=`5,117,26`]]
```

`parents`パラメーターが指定されていた場合はこの`documents`パラメーターが優先される。

### filters

条件を指定してリストにするリソースを絞り込む。

値は`AND(条件式)`または`OR(条件式)`で指定し、`AND()`は条件式に全て一致、`OR()`は条件式の何れかに一致する。

条件式は`変数名:演算子:比較する値`という書式で指定する。
変数名はリソース変数、テンプレート変数に対応。
次のコード例は使用テンプレートが`5`の場合のリソースを対象にする。

```html
[[EasyDocList? &parents=`3` &filters=`AND(template:=:5)`]]
```

条件式はセミコロンで区切ることで複数の条件を指定することができる。
次のコード例は使用テンプレートが`5`か`6`の場合のリソースを対象にする。

```html
[[EasyDocList? &parents=`3` &filters=`OR(template:=:5;template:=:6)`]]
```

- ※ **現状は`AND`か`OR`のどちらかしか指定することができない**
- ※ **現状は`AND`と`OR`を入れ子にして使用することはできない**

### maxDepth

- 初期値: `1`

サブリソースを含めてリストを作成する場合、そのサブリソースの最大の深さを指定する。
1を最初の階層として指定。
`-1`で無制限。

```html
[[EasyDocList? &parents=`3` &maxDepth=`2`]]
```

### publicState

- 初期値: `1`

公開を対象とするか非公開を対象とするかを指定する。
`1`を指定すると公開のみ、`0`を指定すると非公開のみ、`-1`を指定すると公開・非公開問わず対象とする。

```html
[[EasyDocList? &parents=`3` &publicState=`-1`]]
```

### ignoreHidden

- 初期値: `1`

「メニューに表示」項目で非表示としているリソースを除外するかどうかを指定する。
`1`を指定すると除外、`0`を指定すると除外しない。

```html
[[EasyDocList? &parents=`3` &publicState=`0`]]
```

### sort

- 初期値: `menuindex ASC, id ASC`

リストの並び順を指定する。
`変数名 順序`で指定し、変数名はリソース変数とテンプレート変数に対応、順序は昇順は`ASC`、降順は`DESC`を指定できる。

```html
[[EasyDocList? &parents=`3` &sort=`pub_date DESC`]]
```

複数の条件を指定する場合は、カンマ区切りで指定する。

```html
[[EasyDocList? &parents=`3` &sort=`pub_date DESC, id ASC`]]
```

### display

- 初期値: `-1`

表示する件数を指定する。
`-1`ですべて表示する。

```html
[[EasyDocList? &parents=`3` &display=`3`]]
```

### tvPrefix

- 初期値: `tv.`

HTMLテンプレートでテンプレート変数を扱う場合のテンプレート変数の接頭辞を指定する。
HTMLテンプレートで扱う場合は接頭辞 + テンプレート変数名で使用する。

```html
[[EasyDocList?
  &parents=`3`
  &tvPrefix=`foo.`
  &rowTpl=`@CODE:<li>
    <time>[+foo.open_date+]</time>
    <a href="[+url+]">[+title+]</a>
  </li>`
]]
```

### outerTpl

- 初期値: `@CODE:<ul>[+wrap+]</ul>`

リストアイテムを囲うHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[EasyDocList? &parents=`3` &outerTpl=`@CODE:<div>[+wrap+]</div>`]]
```

チャンクを指定する場合はチャンク名をそのまま指定する。

```html
<!--@- チャンク側: list_container_html -@-->
<div>[+wrap+]</div>
```

```html
<!--@- スニペット側 -@-->
[[EasyDocList? &parents=`3` &outerTpl=`list_container_html`]]
```

次のプレースホルダーを使用できる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| wrap | 展開されるリストアイテム。 | `[+wrap+]` |

### rowTpl

- 初期値: `@CODE:<li><a href="[+url+]">[+title+]</a>[+wrap+]</li>`

リストアイテムのHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[EasyDocList?
  &parents=`3`
  &outerTpl=`@CODE:<div>[+wrap+]</div>`
  &rowTpl=`@CODE:<a href="[+url+]">[+title+]</a>`
]]
```

チャンクを指定する場合はチャンク名をそのまま指定する。

```html
<!--@- チャンク側: list_item_html -@-->
<a href="[+url+]">[+title+]</a>
```

```html
<!--@- スニペット側 -@-->
[[EasyDocList? &parents=`3` &outerTpl=`list_container_html` &rowTpl=`list_item_html`]]
```

プレースホルダ―は基本的なリソース変数に加え、テンプレート変数を使用することができる。
また、次の特殊なプレースホルダーも使用することができる。

| プレースホルダー名 | 説明 | 使用例 |
|--|--|--|
| title | リソース変数`pagetitle`。 | `[+title+]` |
| url | リソースのルート相対パス。 | `[+url+]` |
| wrap | 展開されるサブリソース。 | `[+wrap+]` |

### noResults

表示するリソースが1つも見つからなかった場合に表示するHTMLコードまたはチャンクを指定する。

HTMLコードを直接記述する場合は、先頭に`@CODE:`を指定する。

```html
[[EasyDocList?
  &parents=`3`
  &noResults=`@CODE:<p>表示する内容が見つかりませんでした。</p>`
]]
```

チャンクを指定する場合はチャンク名をそのまま指定する。

```html
<!--@- チャンク側: list_no_results_html -@-->
<p>表示する内容が見つかりませんでした。</p>
```

```html
<!--@- スニペット側 -@-->
[[EasyDocList? &parents=`3` &noResults=`list_no_results_html`]]
```

## 動作確認済み

| 項目 | バージョン |
|--|--|
| PHP | 8.2 |
| Evolution CMS | Community Edition 3.1.27<br>Community Edition 3.1.29 |
