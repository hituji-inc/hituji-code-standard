# phpcs を実行するスクリプト

# 実行バイナリ
phpcs_bin="${PHPCS_BIN:-phpcs}"

# 見つからないときはエラーで終了
if ! hash "$phpcs_bin" 2>/dev/null; then
  echo '$PHPCS_BIN must be specified.' "$phpcs_bin": not found 1>&2
  exit 1;
fi

"$phpcs_bin" \
  --report=emacs --no-colors --encoding=utf-8 \
  $@
