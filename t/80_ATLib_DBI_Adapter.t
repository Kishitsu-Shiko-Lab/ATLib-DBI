#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 59;

use ATLib::Std;
use ATLib::Data;
use ATLib::DBI::Connection;
use ATLib::DBI::Parameter;

#1
SKIP: {
    eval { require DBD::SQLite };
    skip 'DBD::SQLite is not installed', 1, if defined $@;
}

#2
my $class = 'ATLib::DBI::Adapter';
use_ok($class);

# Prepare Table for Unit test
my $db_file_path = './80_ATLib_DBI_Adapter.sqlite';
my $conn_string = ATLib::Std::String->from("dbi:SQLite:dbname=$db_file_path");
my $conn = ATLib::DBI::Connection->create($conn_string);
my $attr_of = {AutoCommit => 1};
$conn->_set__attr_of($attr_of);
$conn->open();
my $sql = ATLib::Std::String->from(q{
CREATE TABLE T_ADAPTER
(
  ID           NUMERIC NOT NULL
 ,NAME         TEXT
 ,NUMBER_VALUE NUMERIC
 ,STRING_VALUE TEXT
 ,CONSTRAINT T_ADAPTER_PK PRIMARY KEY (ID)
)
});

my $cmd = $conn->create_command();
$cmd->command_text($sql);
$cmd->execute_non_query();

$conn->begin_transaction();
$sql = ATLib::Std::String->from(q{
INSERT INTO T_ADAPTER
(
  ID
 ,NAME
 ,NUMBER_VALUE
 ,STRING_VALUE
)
VALUES
(
  \ID\
 ,\NAME\
 ,\NUMBER_VALUE\
 ,\STRING_VALUE\
)
});

$cmd->command_text($sql);
$cmd->parameters->add("ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(1));
$cmd->parameters->add("NAME", ATLib::DBI::Parameter->DB_TYPE_STRING, ATLib::Std::String->from('#1'));
$cmd->parameters->add("NUMBER_VALUE", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, undef);
$cmd->parameters->add("STRING_VALUE", ATLib::DBI::Parameter->DB_TYPE_STRING, undef);
$cmd->execute_non_query();

$cmd->parameters->clear();
$cmd->parameters->add("ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(2));
$cmd->parameters->add("NAME", ATLib::DBI::Parameter->DB_TYPE_STRING, ATLib::Std::String->from('#2'));
$cmd->parameters->add("NUMBER_VALUE", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(0));
$cmd->parameters->add("STRING_VALUE", ATLib::DBI::Parameter->DB_TYPE_STRING, undef);
$cmd->execute_non_query();

$cmd->parameters->clear();
$cmd->parameters->add("ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(3));
$cmd->parameters->add("NAME", ATLib::DBI::Parameter->DB_TYPE_STRING, ATLib::Std::String->from('#3'));
$cmd->parameters->add("NUMBER_VALUE", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(1));
$cmd->parameters->add("STRING_VALUE", ATLib::DBI::Parameter->DB_TYPE_STRING, undef);
$cmd->execute_non_query();

$cmd->parameters->clear();
$cmd->parameters->add("ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(4));
$cmd->parameters->add("NAME", ATLib::DBI::Parameter->DB_TYPE_STRING, ATLib::Std::String->from('#4'));
$cmd->parameters->add("NUMBER_VALUE", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(-125));
$cmd->parameters->add("STRING_VALUE", ATLib::DBI::Parameter->DB_TYPE_STRING, undef);
$cmd->execute_non_query();

$cmd->parameters->clear();
$cmd->parameters->add("ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(5));
$cmd->parameters->add("NAME", ATLib::DBI::Parameter->DB_TYPE_STRING, ATLib::Std::String->from('#5'));
$cmd->parameters->add("NUMBER_VALUE", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Number->from(1.125));
$cmd->parameters->add("STRING_VALUE", ATLib::DBI::Parameter->DB_TYPE_STRING, undef);
$cmd->execute_non_query();

$cmd->parameters->clear();
$cmd->parameters->add("ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(6));
$cmd->parameters->add("NAME", ATLib::DBI::Parameter->DB_TYPE_STRING, ATLib::Std::String->from('#6'));
$cmd->parameters->add("NUMBER_VALUE", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, undef);
$cmd->parameters->add("STRING_VALUE", ATLib::DBI::Parameter->DB_TYPE_STRING, ATLib::Std::String->from('Hello, adapter!!'));
$cmd->execute_non_query();

$conn->commit();

#3 SELECT all rows and columns from table.
$sql = ATLib::Std::String->from(q{
SELECT
  TA.*
FROM
  T_ADAPTER TA
ORDER BY
  TA.ID ASC
});
$cmd->command_text($sql);
my $dt = undef;
my $adapter = $class->create($cmd);
isa_ok($adapter, $class);

#4
$dt = $adapter->fill();
isa_ok($dt, 'ATLib::Data::Table');

#5
isa_ok($dt->columns, 'ATLib::Data::Columns');

#6
is($dt->columns->count, 4);

#7
ok($dt->columns->contains('ID'));

#8
ok($dt->columns->contains('NAME'));

#9
ok($dt->columns->contains('NUMBER_VALUE'));

#10
ok($dt->columns->contains('STRING_VALUE'));

#11
is($dt->columns->item('ID')->column_name, 'ID');

#12
isa_ok($dt->columns->item('ID')->table, 'ATLib::Data::Table');

#13
is($dt->columns->item('ID')->table, $dt);

#14
is($dt->columns->item('ID')->data_type, 'ATLib::Std::String');

#15
is($dt->columns->item('NAME')->data_type, 'ATLib::Std::String');

#16
is($dt->columns->item('NUMBER_VALUE')->data_type, 'ATLib::Std::String');

#17
is($dt->columns->item('STRING_VALUE')->data_type, 'ATLib::Std::String');

#18
is($dt->rows->count, 6);

#19 Inspect row where ID = 1
my $row = $dt->rows->item(0);
is($row->item('ID'), 1);

#20
is($row->item('NAME'), '#1');

#21
is($row->item('NUMBER_VALUE'), undef);

#22
is($row->item('STRING_VALUE'), undef);

#23 Inspect row where ID = 2
$row = $dt->rows->item(1);
is($row->item('ID'), 2);

#24
is($row->item('NAME'), '#2');

#25
is($row->item('NUMBER_VALUE'), 0);

#26
is($row->item('STRING_VALUE'), undef);

#27 Inspect row where ID = 3
$row = $dt->rows->item(2);
is($row->item('ID'), 3);

#28
is($row->item('NAME'), '#3');

#29
is($row->item('NUMBER_VALUE'), 1);

#30
is($row->item('STRING_VALUE'), undef);

#31 Inspect row where ID = 4
$row = $dt->rows->item(3);
is($row->item('ID'), 4);

#32
is($row->item('NAME'), '#4');

#33
is($row->item('NUMBER_VALUE'), -125);

#34
is($row->item('STRING_VALUE'), undef);

#35 Inspect row where ID = 5
$row = $dt->rows->item(4);
is($row->item('ID'), 5);

#36
is($row->item('NAME'), '#5');

#37
is($row->item('NUMBER_VALUE'), 1.125);

#38
is($row->item('STRING_VALUE'), undef);

#39 Inspect row where ID = 6
$row = $dt->rows->item(5);
is($row->item('ID'), 6);

#40
is($row->item('NAME'), '#6');

#41
is($row->item('NUMBER_VALUE'), undef);

#42
is($row->item('STRING_VALUE'), 'Hello, adapter!!');

#43 SELECT two rows and specified columns from table.
$sql = ATLib::Std::String->from(q{
SELECT
  TA.ID
 ,TA.STRING_VALUE
 ,TA.NUMBER_VALUE
FROM
  T_ADAPTER TA
WHERE
  TA.ID     IN (5, 6)
ORDER BY
  TA.ID ASC
});
$cmd->command_text($sql);
$adapter = $class->create($cmd);
isa_ok($adapter, $class);

#44
$dt = $adapter->fill();
isa_ok($dt, 'ATLib::Data::Table');

#45
is($dt->columns->count, 3);

#46
ok($dt->columns->contains('ID'));

#47
ok($dt->columns->contains('STRING_VALUE'));

#48
ok($dt->columns->contains('NUMBER_VALUE'));

#49
is($dt->rows->count, 2);

#50 Inspect row where ID = 5
$row = $dt->rows->item(0);
is($row->item('ID'), 5);

#51
is($row->item('NUMBER_VALUE'), 1.125);

#52
is($row->item('STRING_VALUE'), undef);

#53 Inspect row where ID = 6
$row = $dt->rows->item(1);
is($row->item('ID'), 6);

#54
is($row->item('NUMBER_VALUE'), undef);

#55
is($row->item('STRING_VALUE'), 'Hello, adapter!!');

#56 SELECT no match rows.
$sql = ATLib::Std::String->from(q{
SELECT
  TA.ID
FROM
  T_ADAPTER TA
WHERE
  TA.ID     = -1
ORDER BY
  TA.ID ASC
});
$cmd->command_text($sql);
$adapter = $class->create($cmd);
isa_ok($adapter, $class);

#57
$dt = $adapter->fill();
isa_ok($dt, 'ATLib::Data::Table');

#58
is($dt->columns->count, 0);

#59
is($dt->rows->count, 0);

done_testing();
__END__
