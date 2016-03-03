use utf8;
use strict;
use warnings;
use open ':std', ':encoding(utf8)';
use Test::More tests => 19;

# モジュールファイルが正しく読み込まれるか
require_ok('src/phpcs-emacs.pl');

my $sample_error1 = 'STDIN:1:100: error - message';
my $sample_error2 = 'STDIN:23:3: warning - message2';

# error_within_line
{
  ok(error_within_line($sample_error1, [1, 1]), '行範囲内のときは true');
  ok(error_within_line($sample_error2, [23, 1]), '行範囲内のときは true');
  ok(error_within_line($sample_error2, [23, 10]), '行範囲内のときは true');
  ok(error_within_line($sample_error2, [21, 3]), '行範囲内のときは true');

  ok(!error_within_line($sample_error1, [23, 1]), '行範囲に含まれていないときは false');
  ok(!error_within_line($sample_error1, [1, 0]), '行範囲に含まれていないときは false');
  ok(!error_within_line($sample_error2, [1, 1]), '行範囲に含まれていないときは false');
  ok(!error_within_line($sample_error2, [21, 2]), '行範囲に含まれていないときは false');
  ok(!error_within_line($sample_error2, [24, 10]), '行範囲に含まれていないときは false');

  ok(!error_within_line($sample_error1), '行指定がないときは false');

  ok(
    error_within_line($sample_error1, [23, 1], [1, 1], [2, 100]),
    '複数指定のいずれかの行範囲内のときは true');
  ok(
    error_within_line($sample_error2, [1, 1], [1, 1], [1, 1], [2, 100]),
    '複数指定のいずれかの行範囲内のときは true');

  ok(
    !error_within_line($sample_error1, [2, 1], [1, 0], [23, 100]),
    '複数指定のいずれも行範囲に含まれていないときは false');
  ok(
    !error_within_line($sample_error2, [1, 22], [24, 100], [1, 1]),
    '複数指定のいずれも行範囲に含まれていないときは false');

}

# replace_error_file_name
{
  is_deeply(
    [replace_error_file_name('path/to/file', $sample_error1)],
    ['path/to/file:1:100: error - message'],
    '名前が置きかわる');
  is_deeply(
    [replace_error_file_name('path/to/file2', $sample_error1)],
    ['path/to/file2:1:100: error - message'],
    '名前が置きかわる');
  is_deeply(
    [replace_error_file_name('path/to/file', $sample_error2)],
    ['path/to/file:23:3: warning - message2'],
    '名前だけが置きかわる');

  is_deeply(
    [replace_error_file_name('path/to/file', $sample_error1, $sample_error2)],
    ['path/to/file:1:100: error - message', 'path/to/file:23:3: warning - message2'],
    '複数指定で複数を置きかえる');
}
