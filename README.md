# hituji-code-standard

Git にステージングされている変更箇所がコード規約に則っているか検証します。

コード規約の検証は、ファイルの拡張子が `.php` であるものに対して [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer) で行われます。

## 使い方

`bin/phpcs` を実行します。コードに問題がなく検証に合格するとなにも出力されず終了します。検証に不合格だと、該当の部分が出力されます。

この `bin/phpcs` を `.git/hooks/pre-commit` で実行するようにすることで、コミット直前にソースコードを検証するようになります。検証に不合格だと、コミットが拒否されるようになります。詳しくは「インストール」項目を見てください。

## インストール

`bin/install` を実行することで、git のコミット時にコード検証を行うようになります。インストール方法は 2 つあります。ひとつめはインストール先の git リポジトリに移動してインストールスクリプトを実行します。以下に例を示します。

```
$ cd /some/repository
$ /home/my/hituji-code-standard/bin/install
```

ふたつめはインストール先を指定する方法です。

```
$ /home/my/hituji-code-standard/bin/install /some/repository
```

2種類の方法はどちらも同じように動作します。その git リポジトリの pre-commit フックで `bin/phpcs` が実行されるように登録されます。

PHP_CodeSniffer のインストールも行われます。PHP_CodeSniffer は git サブモジュールとして `lib/PHP_CodeSniffer` に置かれます。

アンインストールするには `.git/hooks/pre-commit` を編集します。`## START hituji-code-standard` から `## END hituji-code-standard` までのすべてのコードを削除してください。

インストール後に pre-commit フックを無視させたいときは `--no-verify` または `-n` オプションをコミット時に与えます。

```
git commit --no-verify
```


## 検証規則

PHP_CodeSniffer の実行には `lib/PHP_CodeSniffer/scripts/phpcs` を使います。git サブモジュールです。環境変数 `PHPCS_BIN` で指定することができます。

`phpcs` は標準で付属の `phpcs-standard.xml` ファイルの内容で検証を行います。規則ファイルは環境変数 `PHPCS_STANDARD` で指定ができます。

### 検証の例外

検証を無視させたいときは、アノテーションを使います。

一行だけ無視させたいときは `@codingStandardsIgnoreLine` を与えます。

```
// @codingStandardsIgnoreLine
this_will_be_ignored();
this_will_not_be_ignored();

this_will_be_ignored(); // @codingStandardsIgnoreLine
```

複数行で無視させたいときは `@codingStandardsIgnoreStart` と `@codingStandardsIgnoreEnd` で挟みます。

```
// @codingStandardsIgnoreStart
this_will_be_ignored();
this_one_too();
// @codingStandardsIgnoreEnd
```

## Testing

```
# prove
```
