# phpcs を実行するスクリプト

# 第 1 引数は phpcs 規則定義
phpcs_standard_param="${1:+--standard=$1}"
shift

# 第 2 引数はファイルのパス
file_path=${1:+--stdin-path="$1"}
shift

# 実行バイナリ
phpcs_bin="${PHPCS_BIN:-phpcs}"

"$phpcs_bin" \
  --report=emacs --no-colors --encoding=utf-8 \
  $phpcs_standard_param $file_path $@

# phpcs が実行できたので正常終了
exit 0
