# git blob ファイルを phpcs にかける

# インデックスされたファイル
blob_index=${1:?"index of first argument missing"}

# phpcs 規則定義
standard_file=$2

# ファイルのパス
file_path=${3:+--stdin-path="$3"}

# 実行バイナリ
git_bin="${GIT_BIN:-git}"

# 規則定義が指定されている時のパラメーター
phpcs_standard_param="${standard_file:+--standard=$standard_file}"
phpcs_script="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )/phpcs.sh"

# 実行
$git_bin cat-file blob "$blob_index" | \
  bash "$phpcs_script" $phpcs_standard_param $file_path
