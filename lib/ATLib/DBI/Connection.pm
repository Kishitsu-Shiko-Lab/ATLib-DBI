package ATLib::DBI::Connection;
use Mouse;
extends 'ATLib::Std::Any';
with 'ATLib::DBI::Role::Connection';

use DBI;
use ATLib::Std;
use ATLib::DBI::Exception;
use ATLib::DBI::Command;

# Attributes
has '_user_name' => (is => 'ro', isa => 'ATLib::Std::String', required => 0, writer => '_set__user_name');
has '_auth'      => (is => 'ro', isa => 'ATLib::Std::String', required => 0, writer => '_set__auth');
has '_attr_of'   => (is => 'ro', isa => 'HashRef', required => 0, writer => '_set__attr_of');
has '_dbh'       => (is => 'ro', isa => 'Item', required => 0, writer => '_set__dbh');

has 'in_transaction' => (is => 'ro', isa => 'ATLib::Std::Bool', required => 1, writer => '_set_in_transaction');

# Class Methods
sub create
{
    my $class = shift;
    my $conn_string = shift if scalar(@_) > 0;

    my $instance = $class->new({
        state          => $class->STATE_CLOSE,
        in_transaction => ATLib::Std::Bool->false,
    });

    if (defined $conn_string)
    {
        $instance->connection_string(ATLib::Std::String->from($conn_string));
    }

    return $instance;
}

# Instance Methods
sub open
{
    my $self = shift;

    if ($self->state->equals($self->STATE_OPEN)
        || ATLib::Std::String->is_undef_or_empty($self->connection_string))
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'This connection is already opened or connection string is not specified.'
        })->throw();
    }

    $self->_set_state($self->STATE_CONNECTING);

    my $dbh = DBI->connect($self->connection_string, $self->_user_name, $self->_auth, $self->_attr_of);
    $self->_set__dbh($dbh);
    if (defined $dbh)
    {
        $self->_set_state($self->STATE_OPEN);
    }
    else
    {
        $self->_set_state($self->STATE_CLOSE);
        ATLib::DBI::Exception->new({
            message      => "Fail to connect the database.",
            error_string => $DBI::errstr,
        })->throw();
    }

    $self->_set_in_transaction(ATLib::Std::Bool->false);

    return;
}

sub begin_transaction
{
    my $self = shift;

    if (!$self->state->equals($self->STATE_OPEN)
        || $self->in_transaction)
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'A transaction is already began, or the connection was closed.',
        })->throw();
    }

    my $rc = $self->_dbh->begin_work();
    if ($rc != 1)
    {
        $self->_set_state($self->STATE_BROKEN);
        ATLib::DBI::Exception->new({
            message      => ATLib::Std::String->from('Fail to begin transaction.'),
            error_string => ATLib::Std::String->from($DBI::errstr),
        })->throw();
    }

    $self->_set_in_transaction(ATLib::Std::Bool->true);

    return;
}

sub commit
{
    my $self = shift;

    if (!$self->state->equals($self->STATE_OPEN)
        || !$self->in_transaction)
    {
        ATLib::Std::Exception::InvalidOperation->new({
           message => 'The transaction was commited or rollback, or the connection was closed.',
        })->throw();
    }

    my $rc = $self->_dbh->commit();
    if ($rc != 1)
    {
        $self->_set_state($self->STATE_BROKEN);
        ATLib::DBI::Exception->new({
            message      => 'Fail to commit transaction',
            error_string => $DBI::errstr,
        })->throw();
    }

    $self->_set_in_transaction(ATLib::Std::Bool->false);

    return;
}

sub rollback
{
    my $self = shift;

    if (!$self->state->equals($self->STATE_OPEN)
        || !$self->in_transaction)
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'The transaction was commited or rollback, or the connection was closed.',
        })->throw();
    }

    my $rc = $self->_dbh->rollback();
    if ($rc != 1)
    {
        $self->_set_state($self->STATE_BROKEN);
        ATLib::DBI::Exception->new({
            message      => 'Fail to commit transaction.',
            error_string => $DBI::errstr,
        })->throw();
    }

    $self->_set_in_transaction(ATLib::Std::Bool->false);

    return;
}

sub create_command
{
    my $self = shift;

    return ATLib::DBI::Command->new({
        command_type => ATLib::DBI::Command->COMMAND_TYPE_TEXT,
        connection   => $self,
        parameters   => ATLib::DBI::ParameterList->_create(),
    });
}

sub close
{
    my $self = shift;
    if ($self->state->equals($self->STATE_OPEN))
    {
        if ($self->in_transaction)
        {
            $self->rollback();
        }

        my $rc = $self->_dbh->disconnect();
        if ($rc != 1)
        {
            $self->_set_state($self->STATE_BROKEN);
            ATLib::DBI::Exception->new({
                message      => 'Fail to disconnect the connection.',
                error_string => $DBI::errstr,
            })->throw();
        }
    }

    $self->_set_state($self->STATE_CLOSE);
    $self->_set__dbh(undef);

    return;
}

__PACKAGE__->meta->make_immutable();
no Mouse;
1;
__END__

=encoding utf8

=head1 名前

ATLib::DBI::Connection - データベースセッション

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

    $conn->begin_transaction();

    $conn->commit();
    # or
    $conn->rollback();

    $conn->close();

=head1 基底クラス

L<< ATLib::Std::Any >>

=head1 インターフェース

L<< ATLib::DBI::Role::Connection >>

=head1 説明

ATLib::DBI::Connection は、データベースへの接続を表す型です。

通常、このクラスを継承したそれぞれのデータベース専用のクラスを使用して接続を行います。

=head1 コンストラクタ

=head2 C<< $instance = ATLib::DBI::Connection->create(); >>

ATLib::DBI::Connectionを生成します。

=head1 プロパティ

=head2 C<< $state = $instance->state; >> -E<gt> L<< ATLib::Std::Int >>

データベースセッションの現在の状態を取得します。

=over 4

=item *

$class->STATE_CLOSE (0) データベースセッションは切断されています。

=item *

$class->STATE_OPEN (1) データベースセッションは接続されています。

=item *

$class->STATE_CONNECTING (2) データベースセッションは接続を試行中です。

=item *

$class->STATE_EXECUTING (4) データベースセッションはコマンドを実行中です。

=item *

$class->STATE_BROKEN (16) データベースセッションは接続が壊れています。

=back

=head2 C<< $connection_string = $instance->connection_string; >> -E<gt> L<< ATLib::Std::String >>

データベースセッションを確立する際に用いる接続文字列を取得します。

=head2 C<< $in_transaction = $instance->in_transaction; >> -E<gt> L<< ATLib::Std::Bool >>

このセッションにおいてトランザクション中かどうかを取得します。

=head1 インスタンスメソッド

=head2 C<< $instance->open(); >>

接続文字列 C<< connection_string >> で指定した情報を使って、データベースへの接続を行います。

すでに接続されている場合、または C<< connection_string >> が設定されていない場合は、
例外 C<< ATLib::Std::Exception::InvalidOperation >> をスローします。

また、接続が失敗した場合は例外 C<< ATLib::DBI::Exception >> をスローします。

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

=head1 AUTHOR

atdev01 E<lt>mine_t7 at hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
