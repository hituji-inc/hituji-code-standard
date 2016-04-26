# phpcs を実行するスクリプト

# 実行バイナリ
phpcs_bin="${PHPCS_BIN:-phpcs}"

"$phpcs_bin" \
  --report=emacs --no-colors --encoding=utf-8 \
  $@

# phpcs が実行できたので正常終了
exit 0
