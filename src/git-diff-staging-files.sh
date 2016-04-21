# ステージ上にあるパターンに名前が一致するファイルと HEAD との変更差分を出力する

# 利用するファイル名パターン
file_pattern="\.\(php\|inc\)"

git_diff_cached="${GIT_BIN:-git} diff --cached"

# git diff からステージ上のファイル名一覧を得て
# ファイル名パターンに一致するものだけの行数情報を取得
$git_diff_cached --name-only \
  | grep -i -e "$file_pattern$" -e "^\".+$file_pattern\"$" \
  | tr '\n' '\0' \
  | xargs -0 \
    $git_diff_cached --no-color --diff-filter=ACMR --unified=0 --
