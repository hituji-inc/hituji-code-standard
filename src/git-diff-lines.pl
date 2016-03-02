use utf8;
use strict;
use warnings;

# diff テキストから変更された行を返す
sub get_changed_lines {
  my ($diff_text) = @_;

  # 変更された行番号を検出する
  my $line_info_pattern = qr/^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/m;

  # 複数の変更行があり得るので配列で結果を返す
  my @result = ();

  # すべての変更の情報を取得
  while ($diff_text =~ m/$line_info_pattern/g) {
    my ($start, $count) = ($1, $2);

    $count = 1 unless defined($count);

    # 新しく書かれた行がない
    next if ($count == 0);

    push @result, [$start, $count];
  }

  # 配列参照として返す
  return \@result
}

# diff テキストから変更されたファイル名とその行を返す
sub get_changed_file_lines {
  my ($diff_text) = @_;

  # diff の開始場所とマッチ
  my $diff_start_pattern = qr/(?=^diff --git)/m;
  # インデックス
  my $index_pattern = qr{^index \w+\.\.(\w+)}m;

  # diff テキストからファイル名を取得して返す
  my $get_file = sub {
    my ($diff) = @_;

    my $file_pattern = qr{^\+{3} (.+)$}m;

    return unless $diff =~ $file_pattern;

    my $file = $1;

    # ダブルクオートで囲われていたら取り除く
    $file =~ s/\A"(.+)"\Z/$1/;

    # ファイル名が 'b/' で始まっているので取り除く
    $file =~ s{^b/}{};

    return $file
  };

  my @result = ();

  # diff されたファイルごとに処理
  foreach my $one_file_diff (split($diff_start_pattern, $diff_text)) {
    next unless $one_file_diff =~ $index_pattern;

    my $index = $1;

    # split されると最初の要素は空文字列になるので飛ばす
    my $file = $get_file->($one_file_diff);

    next unless $file;

    # ファイルの情報を追加
    push @result, {
      file => $file,
      index => $index,
      lines => get_changed_lines($one_file_diff),
    };
  }

  # 配列参照として返す
  return \@result
}

1;
