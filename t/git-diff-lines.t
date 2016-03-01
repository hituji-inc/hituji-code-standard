use utf8;
use strict;
use warnings;
use open ':std', ':encoding(utf8)';
use Test::More tests => 14;
use FindBin;

# モジュールファイルが正しく読み込まれるか
require_ok('src/git-diff-lines.pl');

# テスト用の diff 結果ファイルを読み込んで内容を返します
sub read_diff_file {
  my ($file_name) = @_;

  # このテストファイルから相対的な位置でのファイル
  my $input = "$FindBin::Bin/diff-samples/$file_name";

  open(my $input_fh, "<", $input) || die "Can't open $input: $!";

  my $text = join('', <$input_fh>);

  close($input_fh);

  return $text;
}

# get_changed_lines
{
  is_deeply(
    get_changed_lines(""),
    [],
    'なにもないときは空の配列を返す');

  is_deeply(
    get_changed_lines(read_diff_file('insertion1.diff')),
    [[4, 1]],
    '追加された行を返す');

  is_deeply(
    get_changed_lines(read_diff_file('insertion2.diff')),
    [[65, 3]],
    '追加された行を返す（複数行）');

  is_deeply(
    get_changed_lines(read_diff_file('change1.diff')),
    [[134, 1]],
    '変更で追加された行を返す');

  is_deeply(
    get_changed_lines(read_diff_file('change2.diff')),
    [[200, 2]],
    '変更で追加された行を返す（複数行）');

  is_deeply(
    get_changed_lines(read_diff_file('deletion1.diff')),
    [],
    '削除では空の行を返す');
  is_deeply(
    get_changed_lines(read_diff_file('deletion2.diff')),
    [],
    '削除では空の行を返す');

  is_deeply(
    get_changed_lines(read_diff_file('multi_change.diff')),
    [[20, 1], [63, 2]],
    '複数の変更を返す');
}

# get_changed_file_lines
{
  is_deeply(
    get_changed_file_lines(""),
    [],
    'なにもないときは空の配列を返す');

  is_deeply(
    get_changed_file_lines(read_diff_file('insertion1.diff')),
    [
      {
        file => 'example/file.txt',
        lines => [[4, 1]],
      }
    ],
    'ファイル名と変更箇所を返す');

  is_deeply(
    get_changed_file_lines(read_diff_file('deletion1.diff')),
    [
      {
        file => 'example/deletion.txt',
        lines => [],
      }
    ],
    'ファイル名と変更箇所を返す');

  is_deeply(
    get_changed_file_lines(read_diff_file('multi_files.diff')),
    [
      {
        file => 'example/file.txt',
        lines => [[4, 1]],
      }, {
        file => 'example/deletion.txt',
        lines => [],
      }
    ],
    '複数のファイルを配列で返す');

  is(
    get_changed_file_lines(read_diff_file('special_filename.diff'))->[0]->{file},
    'special \" .txt',
    '特別な文字列をつかったファイル名も正しく取り扱う');

}
