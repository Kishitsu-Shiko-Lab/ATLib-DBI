package ATLib::DBI::Role::Connection;
use Mouse::Role;

use ATLib::Std;

# Constants
sub STATE_CLOSE      { shift; return ATLib::Std::Int->from(0); }
sub STATE_OPEN       { shift; return ATLib::Std::Int->from(1); }
sub STATE_CONNECTING { shift; return ATLib::Std::Int->from(2); }
sub STATE_EXECUTING  { shift; return ATLib::Std::Int->from(4); }
sub STATE_FETCHING  { shift; return ATLib::Std::Int->from(8); }
sub STATE_BROKEN     { shift; return ATLib::Std::Int->from(16); }

# Attributes
has 'state'             => (is => 'ro', isa => 'ATLib::Std::Int', required => 1, writer => '_set_state');
has 'connection_string' => (is => 'rw', isa => 'ATLib::Std::String', required => 0);

# Methods
requires qw{ create open close begin_transaction commit rollback create_command };

no Mouse::Role;
1;
__END__

=encoding utf8

=head1 名前

ATLib::DBI::Role::Connection - データベースセッションの動作を定義するインターフェース

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

    use Mouse;
    with 'ATLib::DBI::Role::Connection';

    ...

=head1 説明

ATLib::DBI::Role::Connectionは、データベースセッション型を定義する上で定義すべき操作を定義するインターフェースです。

=head1 コンストラクタ

=head2 C<< $instance = ATLib::DBI::Connection->create(); >> -E<gt> L<< ATLib::DBI::Connection >>

データベースセッションのインスタンスを生成します。

=head2 C<< $instance = ATLib::DBI::Connection->create($conn_string); >> -E<gt> L<< ATLib::DBI::Connection >>

接続文字列 $conn_string を接続文字列 C<< $instance->connection_string >> とするデータベースセッションのインスタンスを生成します。

=head1 プロパティ

=head2 C<< $state = $instance->state; >> -E<gt> L<< ATLib::Std::Int >>

データベースセッションの現在の状態を取得します。

=over 4

=item *

C<< $class->STATE_CLOSE >> (0) データベースセッションは切断されています。

=item *

C<< $class->STATE_OPEN >> (1) データベースセッションは接続されています。

=item *

C<< class->STATE_CONNECTING >>$ (2) データベースセッションは接続を試行中です。

=item *

C<< $class->STATE_EXECUTING >> (4) データベースセッションはコマンドを実行中です。

=item *

$class->STATE_BROKEN (16) データベースセッションは接続が壊れています。

=back

=head2 C<< $connection_string = $instance->connection_string >> -E<gt> L<< ATLib::Std::String >>

データベースセッションを確立する際に用いる接続文字列を取得します。

=head1 インスタンスメソッド

=head2 C<< $instance->open(); >>

接続文字列を使用して、データベース接続をオープンします。

=head2 C<< $instance->begin_transaction(); >>

トランザクションを開始します。

データベースへ接続していないか、またはすでにトランザクションが開始されている場合は、
例外 C<< ATLib::Std::Exception::InvalidOperation >> をスローします。

また、トランザクションの開始が失敗した場合は例外 C<< ATLib::DBI::Exception >> をスローします。

=head2 C<< $instance->commit(); >>

トランザクションを確定します。

データベースへ接続していないか、トランザクションが開始されていない場合は、
例外 C<< ATLib::Std::Exception::InvalidOperation >> をスローします。

また、トランザクションの確定が失敗した場合は例外 C<< ATLib::DBI::Exception >> をスローします。

=head2 C<< $instance->rollback(); >>

トランザクションを破棄します。

データベースへ接続していないか、トランザクションが開始されていない場合は、
例外 C<< ATLib::Std::Exception::InvalidOperation >> をスローします。

また、トランザクションの破棄が失敗した場合は例外 C<< ATLib::DBI::Exception >> をスローします。

=head2 C<< $cmd = $instance->create_command(); >> -E<gt> L<< ATLib::DBI::Command >>

本インスタンスのデータベース接続に関連付けられた L<< ATLib::DBI::Command >> を生成して返します。

=head2 C<< $instance->close(); >>

データベースへの接続を閉じます。

確定されていないトランザクションは破棄されます。

接続のクローズ処理が失敗した場合は、 C<< ATLib::DBI::Exception >> を生成してスローします。

=head1 インストール方法

    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-Utils.git
    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-Std.git
    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-Data.git
    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-DBI.git

=head1 AUTHOR

atdev01 E<lt>mine_t7 at hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

(C) 2020-2023 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
