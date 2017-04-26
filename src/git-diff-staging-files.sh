# ステージ上にあるパターンに名前が一致するファイルと HEAD との変更差分を出力する

# 利用するファイル名パターン
file_pattern="\.\(php\|inc\)"

git_diff_cached="${GIT_BIN:-git} diff --cached"

# Linux と BSD では xargs の振る舞いに違いがあることに対応
# see http://aligach.net/diary/20111107.html
XARGS_OPTIONS='--no-run-if-empty'

# BSD では引数を与えなくてもからの標準入力で実行しない
if [ $(uname) = 'Darwin' ]; then
    XARGS_OPTIONS=''
fi

# git diff からステージ上のファイル名一覧を得て
# ファイル名パターンに一致するものだけの行数情報を取得
$git_diff_cached --name-only \
  | grep -i -e "$file_pattern$" -e "^\".+$file_pattern\"$" \
  | tr '\n' '\0' \
  | xargs -0 $XARGS_OPTIONS \
    $git_diff_cached --no-color --diff-filter=ACMR --unified=0 --
