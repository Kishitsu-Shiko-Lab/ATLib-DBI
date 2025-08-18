package ATLib::DBI::Adapter;
use Mouse;
extends 'ATLib::Std::Any';
with 'ATLib::DBI::Role::Adapter';

use DBI;
use ATLib::Std;
use ATLib::Data;
use ATLib::DBI::Connection;
use ATLib::DBI::Command;
use ATLib::DBI::Exception;

# Class Methods
sub create
{
    my $class = shift;
    my $cmd = shift;
    my $instance = $class->new({
        command => $cmd
    });
    return $instance;
}

# Builder
sub BUILDARGS
{
    my ($class, $args_ref) = @_;
    $class->SUPER::BUILDARGS($args_ref);
    return $args_ref;
}

# Instance Methods
sub fill
{
    my $self = shift;

    my $cmd = $self->command;
    my $conn = $cmd->connection;

    if (!defined $conn
        || !$conn->state->equals(ATLib::DBI::Role::Connection->STATE_OPEN))
    {
        ATLib::Std::Exception::InvalidOperation->new({
            message => 'Connection is not specified, Or connection is not already opened.'
        })->throw();
    }

    my $dt = ATLib::Data::Table->create();

    $cmd->prepare();
    my $sth = $cmd->_sth;
    my $rv = $sth->execute();
    if ($rv != 0)
    {
        ATLib::DBI::Exception->new({
            message      => q{Fail to read row of table.},
            error_string => $sth->errstr,
        })->throw();
    }

    my $column_name_list = ATLib::Std::Collections::List->of('ATLib::Std::String');
    while (my $hash_ref = $sth->fetchrow_hashref())
    {
        if ($sth->err)
        {
            ATLib::DBI::Exception->new({
                message      => q{Fail to read row of table.},
                error_string => $sth->errstr,
            })->throw();
        }

        if ($dt->columns->count == 0)
        {
            for my $key (keys %{$hash_ref})
            {
                my $column_name = ATLib::Std::String->from($key)->to_upper();
                $dt->columns->add(ATLib::Data::Column->create($column_name, 'ATLib::Std::String'));
                $column_name_list->add(ATLib::Std::String->from($key));
            }
        }

        my $row = $dt->create_new_row();
        for my $i (0 .. $column_name_list->count - 1)
        {
            my $column_name = $column_name_list->item($i);
            my $column_value = undef;
            if (defined $hash_ref->{$column_name})
            {
                $column_value = ATLib::Std::String->from($hash_ref->{$column_name});
            }
            $row->item($column_name->to_upper(), $column_value)
        }
        $dt->rows->add($row);
    }

    return $dt;
}

__PACKAGE__->meta->make_immutable();
no Mouse;
1;
__END__

=encoding utf8

=head1 名前

ATLib::DBI::Adapter - マトリクス構造にデータベースのデータを反映する

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

    use ATLib::DBI;
    use ATLib::Data;
    use ATLib::Std::String;

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
      SELECT
        ID
       ,VALUE
      FROM
        TABLE_A
      WHERE
        ID =  \ID\
    });

    $cmd->command_text($sql);
    my $dt;
    my $adapter = ATLib::DBI::Adapter->create($cmd);
    $dt = $adapter->fill();

=head1 説明

ATLib::DBI::Adapter は、マトリクス構造にデータベースのデータを反映します。

=head1 基底クラス

L<< ATLib::Std::Any >>

=head1 インターフェース

L<< ATLib::DBI::Role::Adapter >>

=head1 コンストラクタ

=head2 C<< $instance = ATLib::DBI::Adapter->create($command): >>

コマンド $command を使用する ATLib::DBI::Adapterを生成します。

=head1 プロパティ

=head2 C<< $command = $instance->command; >> -E<gt> L<< ATLib::DBI::Command >>

インスタンスに関連付けられたコマンドを取得します。

=head1 インスタンスメソッド

=head2 C<<  $dt = $instance-> fill(); >> -E<gt> L<< ATLib::Data:Table >>

インスタンスに関連付けられた $command を実行して、$dt (L<< ATLib::Data::Table >>) として返却します。

現在、レコードが存在しない場合は $dt にスキーマ情報は生成されません。

また、C<<$dt->columns->item($index)>> は使用できません。SELECT ステートメントとは異なる索引に対応するためです。

代わりに C<< $dt->columns->item($column_name) >> を使用してください。

=cut
