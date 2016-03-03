use utf8;

# phpcs の emacs フォーマットで出力されるテキストに関する関数ファイル
use strict;
use warnings;

use List::Util qw(any);
use Data::Dumper;

# emacs 書式の phpcs のエラーが指定の行範囲に入っているかを返します
sub error_within_line {
  my ($emacs_error_report, @filter_lines) = @_;

  # エラーのあった行番号を得る
  $emacs_error_report =~ m/^.+?:(\d+)/;
  my $line_num = $1;

  # 行範囲に含まれているかを検証
  any {
    my $start = $_->[0];
    my $end = $start + $_->[1];

    return $start <= $line_num && $line_num < $end
  } @filter_lines
}

# STDIN となっている phpcs エラーのファイル名を置き換えます
sub replace_error_file_name {
  my ($new_name, @errors) = @_;

  map { s/^STDIN/$new_name/; $_ } @errors
}

1;
