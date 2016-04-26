# git blob ファイルを phpcs にかける

# インデックスされたファイル
blob_index=${1:?"index of first argument missing"}

# 第 2 以降の引数はそのまま phpcs.sh に渡す
shift

# 実行バイナリ
git_bin="${GIT_BIN:-git}"

# phpcs 実行スクリプトの相対パス
phpcs_script="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )/phpcs.sh"

# 実行
$git_bin cat-file blob "$blob_index" | \
  bash "$phpcs_script" $@
