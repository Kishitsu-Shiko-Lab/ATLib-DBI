package ATLib::DBI::ParameterList;
use Mouse;
extends 'ATLib::Std::Collections::List';

use ATLib::Utils qw{ is_int as_type_of };
use ATLib::Std;
use ATLib::DBI::Parameter;

# Builder
sub BUILDARGS
{
    my ($class, $args_ref) = @_;
    $class->SUPER::BUILDARGS($args_ref);
    return $args_ref;
}

# Class Method
sub _create
{
    my $class = shift;
    my $instance = $class->SUPER::of('ATLib::DBI::Parameter');
    return $instance;
}

# Instance Methods
sub contains
{
    my $self = shift;
    my ($name) = @_;

    if (!defined $name || $self->count == 0)
    {
        return ATLib::Std::Bool->false;
    }

    for my $i (0 .. $self->count - 1)
    {
        my $param = $self->item($i);
        if ($param->name->equals($name))
        {
            return ATLib::Std::Bool->true;
        }
    }

    return ATLib::Std::Bool->false;
}

sub add
{
    my $self = shift;
    my ($name_or_param, $db_type, $value, $direction) = @_;

    if (scalar(@_) == 1 && as_type_of(q{ATLib::DBI::Parameter}, $name_or_param))
    {
        $self->SUPER::add($name_or_param);
        return $self;
    }

    if (ATLib::Std::String->is_undef_or_empty($name_or_param))
    {
        ATLib::Std::Exception::Argument->new({
            message    => qw{Must be defined.},
            param_name => qw{$name},
        })->throw();
    }

    if ($self->contains($name_or_param))
    {
        ATLib::Std::Exception::Argument->new({
            message    => qq{The `$name_or_param` was already added.},
            param_name => qw{$name},
        })->throw();
    }

    if (!defined $db_type)
    {
        ATLib::Std::Exception::Argument->new({
            message    => qw{Must be defined.},
            param_name => qw{$db_type},
        })->throw();
    }

    if (!ATLib::DBI::Parameter->DB_TYPE_STRING->equals($db_type)
        && !ATLib::DBI::Parameter->DB_TYPE_DECIMAL->equals($db_type)
        && !ATLib::DBI::Parameter->DB_TYPE_DATE->equals($db_type)
        && !ATLib::DBI::Parameter->DB_TYPE_DATETIME->equals($db_type))
    {
        ATLib::Std::Exception::Argument->new({
            message    => qw{Invalid value was specified.},
            param_name => qw{$db_type},
        })->throw();
    }

    if (!defined $direction)
    {
        $direction = ATLib::DBI::Parameter->DIRECTION_INPUT;
    }

    if (!ATLib::DBI::Parameter->DIRECTION_INPUT->equals($direction)
        && !ATLib::DBI::Parameter->DIRECTION_OUTPUT->equals($direction)
        && !ATLib::DBI::Parameter->DIRECTION_INPUT_OUTPUT->equals($direction))
    {
        ATLib::Std::Exception::Argument->new({
            message    => qw{Invalid value was specified.},
            param_name => qw{$direction},
        })->throw();
    }

    my $parameter = ATLib::DBI::Parameter->_create({
        name       => $name_or_param,
        db_type    => $db_type,
        value      => $value,
        direction  => $direction,
    });

    $self->SUPER::add($parameter);

    return $self;
}

sub remove_at
{
    my $self = shift;
    my $index_or_name_or_param = shift;

    if (is_int($index_or_name_or_param))
    {
        $self->SUPER::remove_at($index_or_name_or_param);
    }
    elsif (as_type_of(q{Str}, $index_or_name_or_param) || as_type_of(q{ATLib::Std::String}, $index_or_name_or_param))
    {
        if (!$self->contains($index_or_name_or_param))
        {
            ATLib::Std::Exception::Argument->new({
                message    => q{Parameter $index_or_name_or_param is not found.},
                param_name => q{$index_or_name_or_param},
            })->throw();
        }

        for my $i (0 .. $self->count - 1)
        {
            my $param = $self->item($i);
            if ($param->name->equals($index_or_name_or_param))
            {
                $self->SUPER::remove_at($i);
                last;
            }
        }
    }
    else
    {
        if (!$self->SUPER::remove($index_or_name_or_param))
        {
            ATLib::Std::Exception::Argument->new({
                message    => q{Parameter $index_or_name_or_param is not found.},
                param_name => q{$index_or_name_or_param},
            })->throw();
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

ATLib::DBI::ParameterList - SQL バインド変数マッピングのリスト

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

    use ATLib::DBI;


=head1 基底クラス

L<< ATLib::Std::Any >> E<lt>- L<< ATLib::Std::Collections::List >>

=head1 説明

ATLib::DBI::ParameterList は、L<< ATLib::DBI::Parameter >> のコレクションです。
通常、本クラスが単独でインスタンス化されることはなく、 L<< ATLib::DBI::Command >> などの所属クラスで自動生成されます。

=head1 プロパティ

=head2 C<< $count = $instance->count; -E<gt> >> L<< ATLib::Std::Int >>

インスタンスに格納されている要素数を取得します。

=head1 インスタンスメソッド

=head2 C<< $result = $instance->contains($name); >> -E<gt> L<< ATLib::Std::Bool >>

パラメータ名$nameがインスタンスに追加されているかどうかを判定して返します。

=head2 C<< $instance = $instance->clear(); >>

インスタンスに格納されているすべての要素を削除します。
また、操作結果のインスタンスを返します。

=head2 C<< $instance = $instance->add($name_or_param, $db_type, $value, $direction); >>

$name_or_paramのみを設定して L<< ATLib::DBI::Parameter >> を設定した場合は、本インスタンスに直接追加されます。

バインド変数名を $name_or_param、データベースの型を $db_type、バインド値を $valueとする、
新しいバインド変数 L<< ATLib::DBI::Parameter >> が生成されて、本インスタンスに追加されます。

$db_type は、L<< ATLib::DBI::Parameter >> で定義されている C<< DB_TYPE_ >> で始まる定数を設定します。

$direction はバインド変数の方向を設定しますが、省略可能です。既定値は C<< DIRECTION_INPUT >> です。
L<< ATLib::DBI::Parameter >> で定義されている C<< DIRECTION_ >> で始まる定数を設定します。

また、操作結果のインスタンスを返します。

=head2 C<< $instance = $instance->remove_at($index_or_name_or_param);  >>

$index_or_name_or_paramに索引が設定された場合は、その位置にある要素を削除します。
名前が設定された場合は、該当する L<< ATLib::DBI::Parameter >> の要素を削除します。
L<< ATLib::DBI::Parameter >> が指定された場合は、等価なインスタンスの要素を削除します。
削除できなかった場合は、例外 L<< ATLib::Std::Exception::Argument >> が発生します。

=head2 C<< $result = $instance->remove($param); >> -E<gt> L<< ATLib::Std::Bool >>

インスタンスの要素から最初に見つかった要素$paramを削除します。
要素が削除できたかどうかを示す真偽値を返します。

=head1 AUTHOR

atdev01 E<lt>mine_t7 at hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

(C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
