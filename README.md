# note2rss

[note.com](https://note.com) のフォローユーザーのRSSフィードコレクションファイル（OPMLファイル）を生成する

## 使い方

まず、このリポジトリをクローンします。

```sh
git clone https://github.com/yudukikun5120/note2rss.git
```

`Note2rss.write/2` 関数を実行することで、フォロー先となるユーザー群のRSSフィードコレクションファイルを生成することができます。
第一引数にはフォロー元となるユーザー名、第二引数には取得するページ数の最大数を指定します。

> [!TIP]
> フォロー一覧ページのURLは `https://note.com/{ユーザー名}/followings?pages=1` であり、ページ数の最大値は、フォロー一覧ページのページネーションの最大値（`pages` パラメータの最大値）です。

### 例

以下の例は、フォロー元となるユーザー名 `yudukikun5120` およびフォロイーページの最大値であるページ `5` を指定し、RSSフィードコレクションファイルを生成します。

```sh
mix run -e "Note2rss.write('yudukikun5120', 5)"
```

RSSフィードコレクションファイルは、`note2rss` ディレクトリに `note.opml` という名前で保存され、次のような形式で記述されます。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:opml="http://opml.org/spec2">
  <head>
    <title>Note2rss</title>
  </head>
  <body>
    <outline title="note" text="note">
      <outline htmlUrl="https://note.com/info" text="note公式" title="note公式" type="rss" xmlUrl="https://note.com/info/rss"/>
    </outline>
  </body>
</opml>
```
