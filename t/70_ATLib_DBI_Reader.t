#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 50;
use Test::Exception;

use ATLib::Std;
use ATLib::DBI::Connection;
use ATLib::DBI::Parameter;

#1
SKIP: {
    eval { require DBD::SQLite };
    skip 'DBD::SQLite is not installed', 1, if defined $@;
}

#2
my $class = 'ATLib::DBI::Reader';
use_ok($class);

# Prepare Table for Unit test
my $db_file_path = './70_ATLib_DBI_Reader.sqlite';
my $conn_string = ATLib::Std::String->from("dbi:SQLite:dbname=$db_file_path");
my $conn = ATLib::DBI::Connection->create($conn_string);
my $attr_of = {AutoCommit => 1};
$conn->_set__attr_of($attr_of);
$conn->open();
my $sql = ATLib::Std::String->from(q{
CREATE TABLE T_READER
(
  ID           NUMERIC NOT NULL
 ,NAME         TEXT
 ,NUMBER_VALUE NUMERIC
 ,STRING_VALUE TEXT
 ,CONSTRAINT T_READER_PK PRIMARY KEY (ID)
)
});

my $cmd = $conn->create_command();
$cmd->command_text($sql);
$cmd->execute_non_query();

$conn->begin_transaction();
$sql = ATLib::Std::String->from(q{
INSERT INTO T_READER
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
$cmd->parameters->add("STRING_VALUE", ATLib::DBI::Parameter->DB_TYPE_STRING, ATLib::Std::String->from('Hello, reader!!'));
$cmd->execute_non_query();

$conn->commit();

#3
$sql = ATLib::Std::String->from(q{
SELECT
  ID
 ,NAME
 ,NUMBER_VALUE
 ,STRING_VALUE
FROM
  T_READER TR
WHERE
  TR.ID >  \P_ID\
ORDER BY
  TR.ID ASC
});
$cmd->command_text($sql);
$cmd->parameters->clear();
$cmd->parameters->add("P_ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(7));
my $reader = $cmd->execute_reader();
isa_ok($reader, $class);

#4
ok($reader->is_closed);

#5
ok(!$reader->has_rows);

#6
my $exists_row = $reader->read();
ok(!$exists_row);

#7
$cmd->parameters->clear();
$cmd->parameters->add("P_ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(0));
$reader = $cmd->execute_reader();
ok($reader->has_rows);

#8 Read row where ID = 1
$exists_row = $reader->read();
ok($exists_row);

#9
ok(!$reader->is_closed);

#10
is($reader->get_int('ID'), 1);

#11
ok($reader->get_bool('ID'));

#12
ok(!$reader->is_db_null('ID'));

#13
isa_ok($reader->get_string('NAME'), 'ATLib::Std::String');

#14
is($reader->get_string('NAME'), '#1');

#15
ok($reader->is_db_null('NUMBER_VALUE'));

#16
my $message = ATLib::Std::String->from('The specified method invalids to this column type');
throws_ok { $reader->get_number('NUMBER_VALUE'); } qr/$message/, 'Confirm null before read column value.';

#17
ok($reader->is_db_null('STRING_VALUE'));

#18
throws_ok { $reader->get_string('STRING_VALUE'); } qr/$message/, 'Confirm null before read column value.';

#19 Read row where ID = 2
$exists_row = $reader->read();
ok($exists_row);

#20
ok(!$reader->is_closed);

#21
isa_ok($reader->get_int('ID'), 'ATLib::Std::Int');

#22
is($reader->get_int('ID'), 2);

#23
isa_ok($reader->get_int('NUMBER_VALUE'), 'ATLib::Std::Number');

#24
ok(!$reader->get_bool('NUMBER_VALUE'));

#25
ok(!$reader->is_db_null('NUMBER_VALUE'));

#26
is($reader->get_number('NUMBER_VALUE'), 0);

#27
ok($reader->is_db_null('STRING_VALUE'));

#28 Read row where ID = 3
$exists_row = $reader->read();
ok($exists_row);

#29
is($reader->get_int(ATLib::Std::String->from('ID')), 3);

#30
is($reader->get_number(ATLib::Std::String->from('NUMBER_VALUE')), 1);

#31
ok($reader->is_db_null(ATLib::Std::String->from('STRING_VALUE')));

#32 Read row where ID = 4
$exists_row = $reader->read();
ok($exists_row);

#33
is($reader->get_int('ID'), 4);

#34
is($reader->get_int('NUMBER_VALUE'), -125);

#35
is($reader->get_number('NUMBER_VALUE'), -125);

#36
ok($reader->is_db_null('STRING_VALUE'));

#37 Read row where ID = 5
$exists_row = $reader->read();
ok($exists_row);

#38
is($reader->get_int('ID'), 5);

#39
is($reader->get_number('NUMBER_VALUE'), 1.125);

#40
ok($reader->is_db_null('STRING_VALUE'));

#41 Read row where ID = 6
$exists_row = $reader->read();
ok($exists_row);

#42
is($reader->get_int('ID'), 6);

#43
ok($reader->is_db_null('NUMBER_VALUE'));

#44
isa_ok($reader->get_string('STRING_VALUE'), 'ATLib::Std::String');

#45
is($reader->get_string('STRING_VALUE'), "Hello, reader!!");

#46 Read row when not exists row
$exists_row = $reader->read();
ok(!$exists_row);

#47
$message = ATLib::Std::String->from('Reader read all of rows, Or Not call read\(\) yet');
throws_ok { $reader->is_db_null('ID'); } qr/$message/, 'Confirm EOF before check column value.';

#48
throws_ok { $reader->get_int('ID'); } qr/$message/, 'Confirm EOF before read column value.';

#49
throws_ok { $reader->get_number('NUMBER_VALUE'); } qr/$message/, 'Confirm EOF before read column value.';

#50
throws_ok { $reader->get_string('STRING_VALUE'); } qr/$message/, 'Confirm EOF before read column value.';

done_testing();
__END__
