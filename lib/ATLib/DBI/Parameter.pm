package ATLib::DBI::Parameter;
use Mouse;
extends 'ATLib::Std::Any';

use ATLib::Utils qw{as_type_of};
use ATLib::Std;

# Constants
sub DB_TYPE_STRING   { shift; return ATLib::Std::Int->from(16); }
sub DB_TYPE_DECIMAL  { shift; return ATLib::Std::Int->from(7); }
sub DB_TYPE_DATE     { shift; return ATLib::Std::Int->from(5); }
sub DB_TYPE_DATETIME { shift; return ATLib::Std::Int->from(6); }

sub DIRECTION_INPUT        { shift; return ATLib::Std::Int->from(1); }
sub DIRECTION_OUTPUT       { shift; return ATLib::Std::Int->from(2); }
sub DIRECTION_INPUT_OUTPUT { shift; return ATLib::Std::Int->from(3); }

# Attributes
has name      => (is => 'ro', isa => 'ATLib::Std::String', required => 1);
has db_type   => (is => 'ro', isa => 'ATLib::Std::Int', required => 1);
has direction => (is => 'ro', isa => 'ATLib::Std::Int', required => 1);
has value     => (is => 'ro', isa => 'ATLib::Std::Maybe', required => 1);

# Builder
sub BUILDARGS
{
    my ($class, $args_ref) = @_;

    $class->SUPER::BUILDARGS($args_ref);

    if (!exists $args_ref->{db_type})
    {
        $args_ref->{db_type} = $class->DB_TYPE_STRING;
    }
    if (!exists $args_ref->{direction})
    {
        $args_ref->{direction} = $class->DIRECTION_INPUT;
    }

    return $args_ref;
}

# Class Methods
sub _create
{
    my $class = shift;
    my $args_ref = shift;

    my $name = ATLib::Std::String->from($args_ref->{name});

    my $db_type = $class->DB_TYPE_STRING;
    $db_type = $args_ref->{db_type} if (exists $args_ref->{db_type});

    my $value = undef;
    my $param_value = $args_ref->{value} if (exists $args_ref->{value});

    if ($db_type == $class->DB_TYPE_STRING)
    {
        if (!defined $param_value)
        {
            $value = ATLib::Std::Maybe->of(q{ATLib::Std::String}, undef);
        }
        elsif (!as_type_of(q{ATLib::Std::String}, $param_value))
        {
            $param_value = ATLib::Std::String->from($param_value);
            $value = ATLib::Std::Maybe->of(q{ATLib::Std::String}, $param_value);
        }
        else
        {
            $value = ATLib::Std::Maybe->of(q{ATLib::Std::String}, $param_value);
        }
    }
    elsif ($db_type == $class->DB_TYPE_DECIMAL)
    {
        if (!defined $param_value)
        {
            $value = ATLib::Std::Maybe->of(q{ATLib::Std::Number}, undef);
        }
        elsif (!as_type_of(q{ATLib::Std::Number}, $param_value))
        {
            $param_value = ATLib::Std::Number->from($param_value);
            $value = ATLib::Std::Maybe->of(q{ATLib::Std::Number}, $param_value);
        }
        else
        {
            $value = ATLib::Std::Maybe->of(q{ATLib::Std::Number}, $param_value);
        }
    }
    elsif ($db_type == $class->DB_TYPE_DATE || $db_type == $class->DB_TYPE_DATETIME)
    {
        if (!defined $param_value)
        {
            $value = ATLib::Std::Maybe->of(q{ATLib::Std::DateTime}, undef);
        }
        elsif (!as_type_of(q{ATLib::Std::DateTime}, $param_value))
        {
            ATLib::Std::Exception::Argument->new({
                message    => q{Type mismatch.},
                param_name => '$args_ref->{value}',
            })->throw();
        }
        else
        {
            $value = ATLib::Std::Maybe->of(q{ATLib::Std::DateTime}, $param_value);
        }
    }
    else
    {
        $value = ATLib::Std::Maybe->of('ATLib::Std::Any', $param_value);
    }

    my $direction = $class->DIRECTION_INPUT;
    $direction = $args_ref->{direction} if (exists $args_ref->{direction});

    my $instance = $class->new({
        name      => $name,
        db_type   => $db_type,
        value     => $value,
        direction => $direction,
    });

    return $instance;
}

__PACKAGE__->meta->make_immutable();
no Mouse;
1;
__END__

=encoding utf8

=head1 名前

ATLib::DBI::Parameter - SQL バインド変数へのマッピング

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

    use ATLib::DBI;


=head1 基底クラス

L<< ATLib::Std::Any >>

=head1 説明

ATLib::DBI::Parameter は、SQL バインド変数へのマッピングを表します。
通常、本クラスが単独でインスタンス化されることはなく、L<< ATLib::DBI::ParameterList >> への追加操作で自動生成されます。

=head1 プロパティ

=head2 C<< $name = $instance->name; >> -E<gt> L<< ATLib::Std::String >>

SQL バインド変数の名前を取得します。

=head2 C<< $db_type = $instance->db_type; >> -E<gt> L<< ATLib::Std::Int >>

SQL バインド変数の型を取得します。

=over 4

=item *

C<< $class->DB_TYPE_STRING >> (10) 文字列型 (既定値)

=item *

C<< $class->DB_TYPE_DECIMAL >> (7) 数値型

=item *

C<< $class->DB_TYPE_DATE >> (5) 日付型

=item *

C<< $class->DB_TYPE_DATETIME >> (6) 日付時刻型

=back

=head2 C<< $direction = $instance->direction; >> -E<gt> L<< ATLib::Std::Int >>

SQL バインド変数の入出力方向を指定します。

=over 4

=item *

C<< $class->DIRECTION_INPUT >> (1) 入力

=item *

C<< $class->DIRECTION_OUTPUT >> (2) 出力

=item *

C<< $class->DIRECTION_INPUT_OUTPUT >> (3) 入出力

=back

=head2 C<< $instance->value >> -E<gt> L<< ATLib::Std::Maybe >> E<lt>TE<gt>

SQL バインド変数の値を取得します。

=head1 AUTHOR

atdev01 E<lt>mine_t7 at hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
