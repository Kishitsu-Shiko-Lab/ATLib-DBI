package ATLib::DBI::Role::Reader;
use Mouse::Role;
use ATLib::Std;

# Attributes
has 'has_rows'  => (is => 'ro', isa => 'ATLib::Std::Bool', required => 0);
has 'is_closed' => (is => 'ro', isa => 'ATLib::Std::Bool', required => 0, writer => '_set_is_closed');

# Methods
requires qw { item read is_db_null get_bool get_int get_number get_string };

no Mouse::Role;
1;
__END__

=encoding utf8

=head1 名前

ATLib::DBI::Role::Reader - 前方参照用の行の行を読み取るインターフェース

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

    use Mouse;
    with 'ATLib::DBI::Role::Reader';

    ...

=head1 説明

ATLib::DBI::Role::Reader は 前方参照用の行を読み取る型を作成する上で定義すべき操作を定義するインターフェースです。

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

(C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
