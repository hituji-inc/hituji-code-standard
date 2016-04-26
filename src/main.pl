use utf8;
use strict;
use warnings;
use autodie;
use v5.10;

use FindBin qw($Bin);
use lib "$Bin", "$Bin/../lib";

use Data::Dumper;
use Getopt::Long;

require('git-diff-lines.pl');
require('phpcs-emacs.pl');

local $Data::Dumper::Indent = 1;

# 途中の結果を出力するか
my $verbose;
# phpcs の standard ファイルオプション
my $phpcs_standard = '';

# 変数とオプション処理
GetOptions(
  "verbose" => \$verbose,
  "standard=s" => \$phpcs_standard);

# 指定した git のインデックスの phpcs 結果を返します
sub phpcs_by_blob_index {
  my ($blob_index) = @_;

  my $command = "bash '$Bin/phpcs-git-blob.sh' '$blob_index' '$phpcs_standard'";

  say $command if ($verbose);

  my @result = `$command`;

  # phpcs の実行に失敗したら終了
  exit 1 if ($? != 0);

  if ($verbose) {
    local $Data::Dumper::Varname = 'phpcs_by_blob_index';
    print Dumper(\@result);
  }

  return @result
}

# diff の情報から phpcs を実行して結果を返します
sub phpcs_by_diff {
  my ($file_path, $blob_index, $diff_lines) = @_;

  # blob を phpcs にかける
  my @phpcs_result = phpcs_by_blob_index($blob_index);

  # 変更された範囲のエラーを抽出
  @phpcs_result = grep { error_within_line($_, @$diff_lines) } @phpcs_result;

  # 標準入力での phpcs でファイル名が STDIN となっているのを本来の名前に置き換え
  @phpcs_result = replace_error_file_name($file_path, @phpcs_result);

  if ($verbose) {
    local $Data::Dumper::Varname = 'filtered_phpcs_result';
    print Dumper(\@phpcs_result);
  }

  @phpcs_result
}

# 標準入力から diff 情報を受ける
my $no_unified_diff_text = do { local $/; <STDIN> };

# 引数で指定されたファイルを git diff して変更箇所に phpcs
my @phpcs_errors =
  map { phpcs_by_diff($_->{file}, $_->{index}, $_->{lines}) }
  @{get_changed_file_lines($no_unified_diff_text)};

# エラーを出力
if (@phpcs_errors) {
  # エラー内容をメッセージとして出力
  print {*STDOUT} "Error: PHP_CodeSniffer Validation Failure\n";
  print {*STDOUT} @phpcs_errors;

  exit 1;
}

1;
