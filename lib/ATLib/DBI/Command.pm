package ATLib::DBI::Command;
use Mouse;
extends 'ATLib::Std::Any';
with 'ATLib::DBI::Role::Command';

use DBI;
use ATLib::Std;
use ATLib::DBI::Utils::SQL;
use ATLib::DBI::Role::Connection;
use ATLib::DBI::Reader;
use ATLib::DBI::ParameterList;
use ATLib::DBI::Exception;

# Attributes
has '_sth'          => (is => 'ro', isa => 'Item', required => 0, writer => '_set__sth');
has '_prepared_sql' => (is => 'ro', isa => 'ATLib::Std::String', required => 0, writer => '_set__prepared_sql');
has '_prefix'       => (is => 'ro', isa => 'ATLib::Std::String', required => 1, writer => '_set__prefix');
has '_suffix'       => (is => 'ro', isa => 'ATLib::Std::String', required => 1, writer => '_set__suffix');

# Builder
sub BUILDARGS
{
    my ($class, $args_ref) = @_;

    $class->SUPER::BUILDARGS($args_ref);

    $args_ref->{command_type} = ATLib::DBI::Role::Command->COMMAND_TYPE_TEXT;
    $args_ref->{parameters} = ATLib::DBI::ParameterList->_create();
    $args_ref->{_prefix} = ATLib::Std::String->from('\\');
    $args_ref->{_suffix} = ATLib::Std::String->from('\\');

    return $args_ref;
}

# Instance Methods
sub execute_non_query
{
    my $self = shift;

    if (!defined $self->connection
        || !$self->connection->state->equals(ATLib::DBI::Role::Connection->STATE_OPEN))
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'Connection is not specified, Or connection is not opened yet.'
        })->throw();
    }

    if (!defined $self->command_text || $self->command_text->get_length() == 0)
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'Command text is not specified.'
        })->throw();
    }

    $self->prepare();

    my $rv = $self->_sth->execute();
    if (!defined $rv)
    {
        ATLib::DBI::Exception->new({
            message      => q{The command cannot be execute.},
            error_string => $DBI::errstr,
        })->throw();
    }

    return ATLib::Std::Number->from($rv);
}

sub execute_reader
{
    my $self = shift;

    if (!defined $self->connection
        || !$self->connection->state->equals(ATLib::DBI::Role::Connection->STATE_OPEN))
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'Connection is not specified, Or connection is not already opened.'
        })->throw();
    }

    if (!defined $self->command_text || $self->command_text->get_length() == 0)
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'Command text is not specified.'
        })->throw();
    }

    $self->prepare();

    return ATLib::DBI::Reader->new({_command => $self});
}

sub prepare
{
    my $self = shift;

    if (!defined $self->command_text || $self->command_text->get_length() == 0)
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'Command text is not specified.'
        })->throw();
    }

    if ($self->parameters->count == 0)
    {
        my $sql = ATLib::Std::String->from($self->command_text);
        my $sth = $self->connection->_dbh->prepare($sql->as_string());
        $self->_set__sth($sth);

        if (!defined $sth)
        {
            ATLib::DBI::Exception->new({
                message      => q{Fail to prepare SQL statement.},
                error_string => $DBI::errstr,
            })->throw();
        }

        return;
    }

    my $params = ATLib::DBI::Utils::SQL->parse_bind_variable(
        $self->_prefix,
        $self->_suffix,
        $self->command_text
    );

    my $sql = ATLib::Std::String->from($self->command_text);
    for my $i (0 .. $params->count - 1)
    {
        my $old_param = $self->_prefix . $params->item($i) . $self->_suffix;
        $sql = $sql->replace($old_param, ATLib::Std::String->from(q{?}));
    }

    my $sth = $self->connection->_dbh->prepare($sql->as_string());
    $self->_set__sth($sth);
    if (!defined $sth)
    {
        ATLib::DBI::Exception->new({
            message      => q{Fail to prepare SQL statement.},
            error_string => $DBI::errstr,
        })->throw();
    }

    for my $i (0 .. $params->count - 1)
    {
        if ($i >= $self->parameters->count)
        {
            my $param_name = $params->items($i)->name;
            ATLib::Std::Exception::InvalidOperation->new({
                message => qq{The parameter `$param_name` is not specified.}
            })->throw();
        }

        if ($self->parameters->item($i)->value->has_value)
        {
            $sth->bind_param($i + 1, $self->parameters->item($i)->value);
        }
        else
        {
            $sth->bind_param($i + 1, undef);
        }
    }

    return;
}

__PACKAGE__->meta->make_immutable();
no Mouse;
1;
__END__

=encoding utf8

=head1 名前

ATLib::DBI::Command - SQL ステートメント

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

    use ATLib::DBI;
    use ATLib::Std;

    my $conn = ATLib::DBI::Connection->create();

    # For example; SQLite
    my $db_path = '/path/to/example.sqlite3';
    $conn->_set__attr_of({
        AutoCommit => 1
    });
    $conn->connection_string("dbi:SQLite:dbname=$db_path");
    $conn->open();

    my $cmd = $conn->create_command();
    my $sql = ATLib::Std::String->from(q{
      INSERT INTO TABLE_A
      (
        ID
       ,VALUE
      )
      VALUES
      (
        1
       ,'TEST_VALUE'
    });

    my $cmd = $conn->create_command();
    my $sql = ATLib::Std::String->from(q{
      INSERT INTO TABLE_A
      (
        ID
       ,VALUE
      )
      VALUES
      (
        1
       ,'TEST_VALUE'
    });

    $cmd->command_text($sql);
    my $num_affected_rows = $cmd->execute_non_query();

    $sql = ATLib::Std::String->from(q{
      SELECT
        TA.ID
       ,TA.VALUE
      FROM
        TABLE_A TA
      WHERE
        TA.ID   = \P_ID\
    });

    $cmd->command_text($sql);
    $cmd->parameters->add('P_ID', ATLib::DBI::Parameter->DB_TYPE_DECIMAL, 1);
    my $reader = $cmd->execute_reader();

=head1 基底クラス

L<< ATLib::Std::Any >>

=head1 インターフェース

L<< ATLib::DBI::Role::Command >>

=head1 説明

ATLib::DBI::Command は、SQL ステートメントを表す型です。

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

コマンドが不正な場合、または実行に失敗した場合は、例外 L<< ATLib::DBI::Exception >> が発生します。

=head2 C<< $reader = $instance->execute_reader(); >> -E<gt> L<< ATLib::DBI::Reader >>

C<< $instance->command_text >> で指定されたコマンドを実行して、L<< ATLib::DBI::Reader >> オブジェクトを返します。

コマンドを実行できない場合、例外 L<< ATLib::Std::Exception::InvalidOperation >> が発生します。

=head2 C<< $instance->prepare(); >>

SQL 文またはコマンドを実行する前に内部的に呼び出されて、内部オブジェクトを初期化します。
このメソッドを手動で呼び出す必要はありません。

=head1 AUTHOR

atdev01 E<lt>mine_t7 at hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
