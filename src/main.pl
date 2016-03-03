use utf8;
use strict;
use warnings;
use autodie;
use v5.10;

use FindBin qw($Bin);
use lib "$Bin", "$Bin/../lib";

use List::Util qw(any);

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
  "standard=s" => sub { $phpcs_standard = sprintf('--standard="%s"', $_[1]) });

# 行ごとに処理のしやすように出力する phpcs コマンド
my $phpcs_command = <<"END_COMMAND";
  phpcs \\
    --report=emacs --no-colors --encoding=utf-8 \\
    $phpcs_standard \\
END_COMMAND

# ステージ上のファイルと HEAD との変更差分を得る git diff コマンド
my $git_diff_command = <<"END_COMMAND";
  git diff \\
    --cached --no-color --diff-filter=ACMR --unified=0 \\
END_COMMAND


# git でステージングに上がっているファイルの変更差分のファイルと行の情報を返します
sub get_staging_diff {
  print $git_diff_command if ($verbose);

  my $diff_result = `$git_diff_command`;
  my $lines_map = get_changed_file_lines($diff_result);

  if ($verbose) {
    local $Data::Dumper::Varname = 'git_diff_lines';
    print Dumper($lines_map);
  }

  return @$lines_map
}

# 指定した git のインデックスの phpcs 結果を返します
sub phpcs_by_blob_index {
  my ($blob_index) = @_;

  my $staged_file = "git cat-file blob $blob_index";
  my $command =
    "$staged_file |\\\n" .
    "  $phpcs_command";

  print $command if ($verbose);

  `$command`
}

# diff の情報から phpcs を実行して結果を返します
sub phpcs_by_diff {
  my ($diff) = @_;

  my $blob_index = $diff->{index};
  my @diff_lines = @{$diff->{lines}};
  my $file_path = $diff->{file};

  # blob を phpcs にかける
  my @phpcs_result = phpcs_by_blob_index($blob_index);

  if ($verbose) {
    local $Data::Dumper::Varname = 'original_phpcs_result';
    print Dumper(\@phpcs_result);
  }

  # 変更された範囲のエラーを抽出
  @phpcs_result = grep { error_within_line($_, @diff_lines) } @phpcs_result;

  # 標準入力での phpcs でファイル名が STDIN となっているのを本来の名前に置き換え
  @phpcs_result = replace_error_file_name($file_path, @phpcs_result);

  if ($verbose) {
    local $Data::Dumper::Varname = 'filtered_phpcs_result';
    print Dumper(\@phpcs_result);
  }

  @phpcs_result
}

# git diff で得られた範囲に phpcs
my @phpcs_errors = map { phpcs_by_diff($_) } get_staging_diff();

# エラーを出力
if (@phpcs_errors) {
  # エラー内容をメッセージとして出力
  print {*STDOUT} "Error: PHP_CodeSniffer Validation Failure\n";
  print {*STDOUT} @phpcs_errors;

  exit 1;
}

1;