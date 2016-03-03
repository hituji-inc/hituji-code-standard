# hituji-code-standard

Git にステージングされている変更箇所が `phpcs-standard.xml` に則っているか検証します。

## 使い方

`bin/phpcs` を実行します。 pre-commit フックに登録すると、コミット直前にソースコード検証するようになります。

`bin/install_to_pre-commit` を実行することで、現在のディレクトリにある git リポジトリの  pre-commit フック `bin/phpcs` が登録されます。

## 検証規則

`phpcs` は `phpcs-standard.xml` ファイルの内容を参照します

## Testing

```
# prove
```
