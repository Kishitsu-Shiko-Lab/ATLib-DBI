package ATLib::DBI::Reader;
use Mouse;
extends 'ATLib::Std::Any';
with 'ATLib::DBI::Role::Reader';

use DBI;
use ATLib::Std;
use ATLib::DBI::Exception;

# Attributes
has '_command'  => (is => 'ro', isa => 'ATLib::DBI::Command', required => 1);
has '_row_data' => (is => 'ro', isa => 'ATLib::Std::Collections::Dictionary', required => 0, writer => '_set__row_data');
has '_has_current_row' => (is => 'ro', isa => 'ATLib::Std::Bool', required => 1, writer => '_set__has_current_row');

sub item
{
    my $self = shift;
    my $column_name = shift;
    return $self->_row_data->items(ATLib::Std::String::from($column_name)->to_upper());
}

# Builder
sub BUILDARGS
{
    my ($class, $args_ref) = @_;

    $class->SUPER::BUILDARGS($args_ref);

    $args_ref->{_has_current_row} = ATLib::Std::Bool->false;
    $args_ref->{has_rows} = ATLib::Std::Bool->false;
    $args_ref->{is_closed} = ATLib::Std::Bool->true;

    my $cmd = $args_ref->{_command};
    my $sth = $cmd->_sth;
    if (defined $sth)
    {
        my $rv = $sth->execute();
        if ($rv != 0)
        {
            ATLib::DBI::Exception->new({
                message      => q{Fail to read row of table.},
                error_string => $DBI::errstr,
            })->throw();
        }

        my $hash_ref = $sth->fetchrow_hashref();
        if (defined $hash_ref)
        {
            $args_ref->{has_rows} = ATLib::Std::Bool->true;
        }

        # Reset $sth
        $sth->finish();
        $cmd->prepare();
    }

    return $args_ref;
}

# Instance Methods
sub read
{
    my $self = shift;

    my $cmd = $self->_command;
    my $conn = $cmd->connection;

    if (!defined $conn
        || !$conn->state->equals(ATLib::DBI::Role::Connection->STATE_OPEN))
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'Connection is not specified, Or connection is not already opened.'
        })->throw();
    }

    if (!$self->has_rows)
    {
        return ATLib::Std::Bool->false;
    }

    my $sth = $self->_command->_sth;
    if ($self->is_closed)
    {
        my $rv = $sth->execute();
        if ($rv != 0)
        {
            ATLib::DBI::Exception->new({
                message      => q{Fail to read row of table.},
                error_string => $DBI::errstr,
            })->throw();
        }
    }

    my $hash_ref = $sth->fetchrow_hashref();
    if (defined $DBI::err)
    {
        ATLib::DBI::Exception->new({
            message      => q{Fail to read row of table.},
            error_string => $DBI::errstr,
        })->throw();
    }

    if (!defined $hash_ref)
    {
        $self->_set__has_current_row(ATLib::Std::Bool->false);
        return ATLib::Std::Bool->false;
    }

    my $row = ATLib::Std::Collections::Dictionary->of(q{ATLib::Std::String}, q{ATLib::Std::String});

    for my $key (keys %{$hash_ref})
    {
        my $column_name = ATLib::Std::String->from($key)->to_upper();
        my $column_value = undef;
        if (defined $hash_ref->{$key})
        {
            $column_value = ATLib::Std::String->from($hash_ref->{$key});
        }
        $row->add($column_name, $column_value);
    }

    $self->_set__row_data($row);
    $self->_set__has_current_row(ATLib::Std::Bool->true);
    $self->_set_is_closed(ATLib::Std::Bool->false);

    return ATLib::Std::Bool->true;
}

sub is_db_null
{
    my $self = shift;
    my $column_name = shift;

    $column_name = ATLib::Std::String->from($column_name);

    $self->_check_before_get_column_value($column_name);
    $self->_check_has_current_row();

    return ATLib::Std::Bool->false if defined $self->_row_data->item($column_name);
    return ATLib::Std::Bool->true;
}

sub get_bool
{
    my $self = shift;
    my $column_name = shift;

    $column_name = ATLib::Std::String->from($column_name);

    $self->_check_before_get_column_value($column_name);
    $self->_check_has_current_row();
    $self->_check_defined_value($column_name);

    return ATLib::Std::Bool->false if $self->_row_data->item($column_name) eq '0';
    return ATLib::Std::Bool->true;
}

sub get_int
{
    my $self = shift;
    my $column_name = shift;

    $column_name = ATLib::Std::String->from($column_name);

    $self->_check_before_get_column_value($column_name);
    $self->_check_has_current_row();
    $self->_check_defined_value($column_name);

    return ATLib::Std::Int->from($self->_row_data->item($column_name));
}

sub get_number
{
    my $self = shift;
    my $column_name = shift;

    $column_name = ATLib::Std::String->from($column_name);

    $self->_check_before_get_column_value($column_name);
    $self->_check_has_current_row();
    $self->_check_defined_value($column_name);

    return ATLib::Std::Number->from($self->_row_data->item($column_name));
}

sub get_string
{
    my $self = shift;
    my $column_name = shift;

    $column_name = ATLib::Std::String->from($column_name);

    $self->_check_before_get_column_value($column_name);
    $self->_check_has_current_row();
    $self->_check_defined_value($column_name);

    return ATLib::Std::String->from($self->_row_data->item($column_name));
}

sub _check_before_get_column_value
{
    my $self = shift;
    my $column_name = shift;

    my $cmd = $self->_command;
    my $conn = $cmd->connection;

    if (!$conn->state->equals(ATLib::DBI::Connection->STATE_OPEN)
        || $self->is_closed
        || !defined $self->_row_data)
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => q{Connection or reader is closed, Or Not call read() yet.},
        })->throw();
    }

    if (ATLib::Std::String->is_undef_or_empty($column_name))
    {
        ATLib::Std::Exception::Argument->new({
            message    => q{The $column_name is not specified.},
            param_name => q{$column_name},
        })->throw();
    }

    if (!defined $self->_row_data || !$self->_row_data->contains_key($column_name))
    {
        ATLib::Std::Exception::Argument->new({
            message    => qq{The column name `$column_name` doesn't belong to row.},
            param_name => q{$column_name},
        })->throw();
    }
    return;
}

sub _check_has_current_row
{
    my $self = shift;

    if (!$self->_has_current_row)
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => q{Reader read all of rows, Or Not call read() yet.},
        })->throw();
    }
    return;
}

sub _check_defined_value
{
    my $self = shift;
    my $column_name = shift;

    if (!defined $self->_row_data->item($column_name))
    {
        ATLib::Std::Exception::InvalidCast->new({
            message => q{The specified method invalids to this column type, or the column value is NULL.},
        })->throw();
    }
    return;
}

__PACKAGE__->meta->make_immutable();
no Mouse;
1;
__END__

=encoding utf8

=head1 名前

ATLib::DBI::Reader - 前方参照専用の表の行を読み取る

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

    use ATLib::DBI;

    my $conn = ATLib::DBI::Connection->create();

    # For example; SQLite
    my $db_path = '/path/to/example.sqlite3';
    $conn->_set__attr_of({
        AutoCommit => 1
    });
    $conn->connection_string("dbi:SQLite:dbname=$db_path");
    $conn->open();

    my $sql = ATLib::Std::String->from(q{
      SELECT
        TA.ID
       ,TA.VALUE
      FROM
        TABLE_A TA
      WHERE
        TA.ID   = \P_ID\
    });

    my $cmd = $conn->create_command();
    $cmd->command_text($sql);
    $cmd->parameters->add('P_ID', ATLib::DBI::Parameter->DB_TYPE_DECIMAL, 1);
    my $reader = $cmd->execute_reader();

=head1 基底クラス

L<< ATLib::Std::Any >>

=head1 説明

ATLib::DBI::Reader は、指定された SQL ステートメントから前方参照で行を読み取ります。

=head1 プロパティ

=head2 C<< $result = $instance->has_rows; >> -E<gt> L<< ATLib::Std::Bool >>

インスタンスに行が含まれているかどうかを示す値を返します。この値が現在の行の位置によって変化することはありません。

=head2 C<< $result = $instance->is_closed; >> -E<gt> L<< ATLib::Std::Bool >>

インスタンスがクローズ状態の場合は、C<< ATLib::Std::Bool->true >> を返します。
それ以外は、C<< ATLib::Std::Bool->false >> を返します。

=head2 C<< $value = $instance->item($column_name); >> -E<gt> L<< ATLib::Std::Collections::Dictionary >>E<lt>L<< ATLib::Std::String >>, L<< ATLib::Std::Maybe >>E<lt>L<< ATLib::Std::String >>E<gt>E<gt>

インスタンスの現在の行の列 $column_name を取得します。

=head1 インスタンスメソッド

=head2 C<< $result = $instance->read() >> -E<gt> L<< ATLib::Std::Bool >>

インスタンスの現在の行の次の行を読み取ります。
初期の行位置は、最初の行の前です。

次の行が存在する場合は、C<< ATLib::Std::Bool->true >> を返します。
それ以外は、C<< ATLib::Std::Bool->false >> を返します。

=head2 C<< $result = $instance->is_db_null($column_name) >> -E<gt> L<< ATLib::Std::Bool >>

列 $column_name が NULL の場合は、C<< ATLib::Std::Bool->true >> を返します。
それ以外は、C<< ATLib::Std::Bool->false >> を返します。

アクセッサ C<< $instance->get_xxxx($column_name) >> を呼び出す前に、本メソッドで NULL を確認してください。

=head2 C<< $value = $instance->get_bool($column_name) >> -E<gt> L<< ATLib::Std::Bool >>

列 $column_name の値をブール値で返します。
列値が 0 の場合は、C<< ATLib::Std::Bool->false >> を返します。
それ以外は、C<< ATLib::Std::Bool->false >> を返します。

呼び出し前に C<< $instance->is_db_null($column_name) >> で、NULL を確認してください。

=head2 C<< $value = $instance->get_int($column_name) >> -E<gt> L<< ATLib::Std::Int >>

列 $column_name の値を L<< ATLib::Std::Int >> 型で返します。

呼び出し前に C<< $instance->is_db_null($column_name) >> で、NULL を確認してください。

=head2 C<< $value = $instance->get_number($column_name) >> -E<gt> L<< ATLib::Std::Number >>

列 $column_name の値を L<< ATLib::Std::Number >> 型で返します。

呼び出し前に C<< $instance->is_db_null($column_name) >> で、NULL を確認してください。

=head2 C<< $value = $instance->get_string($column_name) >> -E<gt> L<< ATLib::Std::String >>

列 $column_name の値を L<< ATLib::Std::String >> 型で返します。

呼び出し前に C<< $instance->is_db_null($column_name) >> で、NULL を確認してください。

=head1 AUTHOR

atdev01 E<lt>mine_t7 at hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
