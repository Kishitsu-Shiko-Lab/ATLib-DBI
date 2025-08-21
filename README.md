# 名前

ATLib::DBI - ATLib 標準型システムの [Mouse](https://metacpan.org/pod/Mouse) によるデータベース操作クラス

# バージョン

この文書は ATLib::DBI version v0.4.0 について説明しています。

# 概要

それぞれのクラスのドキュメントを参照してください。

# 説明

ATLib::DBI は、Perlでのデータベース操作を扱う開発に .NET Frameworkのような共通型を [Mouse](https://metacpan.org/pod/Mouse) による実装で導入します。

# インターフェース

## [ATLib::DBI::Role::Connection](https://metacpan.org/pod/ATLib%3A%3ADBI%3A%3ARole%3A%3AConnection)

データベースセッションを表す型で定義ためのインターフェースです。

## [ATLib::DBI::Role::Command](https://metacpan.org/pod/ATLib%3A%3ADBI%3A%3ARole%3A%3ACommand)

SQL ステートメントの動作を定義するためのインターフェースです。

## [ATLib::DBI::Role::Adapter](https://metacpan.org/pod/ATLib%3A%3ADBI%3A%3ARole%3A%3AAdapter)

マトリクス構造にデータを格納するための動作を定義するためのインターフェースです。

# クラス

## [ATLib::DBI::Exception](https://metacpan.org/pod/ATLib%3A%3ADBI%3A%3AException)

DBIのエラーをラッピングした ATLib:DBIで発生する例外を表す型です。

## [ATLib::DBI::Connection](https://metacpan.org/pod/ATLib%3A%3ADBI%3A%3AConnection)

データベースへの接続を表す型です。

## [ATLib::DBI::Command](https://metacpan.org/pod/ATLib%3A%3ADBI%3A%3ACommand)

SQL ステートメントを表す型です。

## [ATLib::DBI::Parameter](https://metacpan.org/pod/ATLib%3A%3ADBI%3A%3AParameter)

SQL バインド変数へのマッピングを表す型です。

## [ATLib::DBI::ParameterList](https://metacpan.org/pod/ATLib%3A%3ADBI%3A%3AParameterList)

SQL バインド変数へのマッピングを表す型のリストです。

## [ATLib::DBI::Reader](https://metacpan.org/pod/ATLib%3A%3ADBI%3A%3AReader)

前方参照専用の表の行を読み取る型です。

# インストール方法

    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-Utils.git
    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-Std.git
    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-Data.git
    $cpanm DBD::SQLite
    $cpanm https://github.com/Kishitsu-Shiko-Lab/ATLib-DBI.git

    Or

    $cpm https://github.com/Kishitsu-Shiko-Lab/ATLib-DBI.git

# AUTHOR

atdev01 &lt;mine\_t7 at hotmail.com>

# COPYRIGHT AND LICENSE

(C) 2020-2025 atdev01.

This library is free software; you can redistribute it and/or modify
it under the same terms of the Artistic License 2.0. For details,
see the full text of the license in the file LICENSE.
