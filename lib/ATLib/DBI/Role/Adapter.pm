package ATLib::DBI::Role::Adapter;
use Mouse::Role;

# Attributes
has 'command' => (is => 'ro', isa => 'ATLib::DBI::Command', required => 1);

# Methods
requires qw { fill };

no Mouse::Role;
1;
__END__

=encoding utf8

=head1 名前

ATLib::DBI::Role::Adapter - マトリクス構造にデータを格納するための動作を定義するインターフェース

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

    use Mouse;
    with 'ATLib::DBI::Role::Adapter';

    ...

=head1 説明

ATLib::DBI::Role::Adapter は SQL ステートメントからマトリクス構造にデータを格納するための動作を表す型を作る上で定義すべきインターフェースです。

=head1 プロパティ

=head2 C<< $command = $instance->command; >> -E<gt> L<< ATLib::DBI::Command >>

インスタンスに関連付けられたコマンドを取得します。

=head1 インスタンスメソッド

=head2 C<<  $num_affected_rows = $instance-> fill($dt); >> -E<gt> L<< ATLib::Std::Int >>

インスタンスに関連付けられた $command を実行して、$dt (L<< ATLib::Data::Table >>) へレコードを追加します。

また、$dt へ追加したレコード数を返します。

=head1 AUTHOR

atdev01 E<lt>mine_t7 at hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

(C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
