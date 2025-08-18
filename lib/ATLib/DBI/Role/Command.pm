package ATLib::DBI::Role::Command;
use Mouse::Role;

use ATLib::Std;

# Constants
sub COMMAND_TYPE_TEXT { shift; return ATLib::Std::Int->from(1); }

# Attributes
has 'command_type' => (is => 'rw', isa => 'ATLib::Std::Int', required => 1);
has 'command_text' => (is => 'rw', isa => 'ATLib::Std::String', required => 0);
has 'connection'   => (is => 'ro', isa => 'ATLib::DBI::Connection', required => 1);
has 'parameters'   => (is => 'ro', isa => 'ATLib::DBI::ParameterList', required => 1);

# Methods
requires qw { execute_non_query execute_reader };

no Mouse::Role;
1;
__END__

=encoding utf8

=head1 名前

ATLib::DBI::Role::Command - SQL ステートメントの動作を定義するインターフェース

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

    use Mouse;
    with 'ATLib::DBI::Role::Command';

    ...

=head1 説明

ATLib::DBI::Role::Command は SQL ステートメントの動作を表す型を作る上で定義すべき操作を定義するインターフェースです。

=head1 プロパティ

=head2 C<< $instance->command_type($command_type); >> -E<gt> L<< ATLib::Std::Int >>

プロパティ C<< $instance->command_text >> の解析方法を示す定数値を設定、または取得します。

=over 4

=item *

$class->COMMAND_TYPE_TEXT (1) SQL コマンド。既定値です。

=back

=head2 C<< $instance->command_text($command_text); >> -E<gt> L<< ATLib::Std::String >>

実行する SQL 文またはストアドプロシージャを設定、または取得します。

=head2 C<< $connection = $instance->connection; >> -E<gt> L<< ATLib::DBI::Connection >>

SQL 文またはコマンドを実行する際に使用するセッションを取得します。

=head2 C<< $params = $instance->parameters; >> -E<gt> L<< ATLib::DBI::ParameterList >>

SQL 文またはストアドプロシージャのバインド変数のリストを取得します。バインド変数がある場合は、このリストに追加します。

=head1 インスタンスメソッド

=head2 C<< $num_affected_rows = $instance->execute_non_query(); >> -E<gt> L<< ATLib::Std::Int >>

C<< $instance->command_text >> を使用して SQL 文またはコマンドを実行して、影響を受けた行数を返します。

コマンドを実行できない場合、例外 L<< ATLib::Std::Exception::InvalidOperation >> が発生します。

=head2 C<< $reader = $instance->execute_reader(); >> -E<gt> L<< ATLib::DBI::Reader >>

C<< $instance->command_text >> で指定されたコマンドを実行して、L<< ATLib::DBI::Reader >> オブジェクトを返します。

コマンドを実行できない場合、例外 L<< ATLib::Std::Exception::InvalidOperation >> が発生します。

=head2 C<< $instance->prepare(); >>

SQL 文またはコマンドを実行する前に内部的に呼び出されて、内部オブジェクトを初期化します。
このメソッドを手動で呼び出す必要はありません。

=head1 AUTHOR

atdev01 E<lt>mine_t7 at hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

(C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
