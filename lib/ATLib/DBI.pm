package ATLib::DBI v0.4.0;
use 5.016_001;
use strict;
use warnings;

sub import
{
    use ATLib::DBI::Role::Connection;
    use ATLib::DBI::Role::Command;
    use ATLib::DBI::Role::Adapter;
    use ATLib::DBI::Utils::SQL;
    use ATLib::DBI::Exception;
    use ATLib::DBI::Connection;
    use ATLib::DBI::Command;
    use ATLib::DBI::Parameter;
    use ATLib::DBI::ParameterList;
    use ATLib::DBI::Reader;
}

1;
__END__

=encoding utf-8

=head1 名前

ATLib::DBI - ATLib 標準型システムの L<< Mouse >> によるデータベース操作クラス

=head1 バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

=head1 概要

それぞれのクラスのドキュメントを参照してください。

=head1 説明

ATLib::DBI は、Perlでのデータベース操作を扱う開発に .NET Frameworkのような共通型を L<< Mouse >> による実装で導入します。

=head1 インターフェース

=head2 L<< ATLib::DBI::Role::Connection >>

データベースセッションを表す型で定義ためのインターフェースです。

=head2 L<< ATLib::DBI::Role::Command >>

SQL ステートメントの動作を定義するためのインターフェースです。

=head2 L<< ATLib::DBI::Role::Adapter >>

マトリクス構造にデータを格納するための動作を定義するためのインターフェースです。

=head2 L<< ATLib::DBI::Exception >>

DBIのエラーをラッピングした ATLib:DBIで発生する例外を表す型です。

=head2 L<< ATLib::DBI::Connection >>

データベースへの接続を表す型です。

=head2 L<< ATLib::DBI::Command >>

SQL ステートメントを表す型です。

=head2 L<< ATLib::DBI::Parameter >>

SQL バインド変数へのマッピングを表す型です。

=head2 L<< ATLib::DBI::ParameterList >>

SQL バインド変数へのマッピングを表す型のリストです。

=head2 L<< ATLib::DBI::Reader >>

前方参照専用の表の行を読み取る型です。

=head1 インストール方法

    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-Utils.git
    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-Std.git
    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-Data.git
    $cpanm DBD::SQLite
    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-DBI.git

    Or

    $cpm https://github.com/Kishitsu-Shiko-Lab/ATLib-DBI.git

=head1 AUTHOR

atdev01 E<lt>mine_t7 at hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

(C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.

=cut
