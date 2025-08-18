#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 10;
use Test::Exception;

use ATLib::Std;
use ATLib::DBI::Connection;

#1
SKIP: {
    eval { require DBD::SQLite };
    skip 'DBD::SQLite is not installed', 1, if defined $@;
}

#2
my $class = 'ATLib::DBI::Command';
use_ok($class);

#3
my $db_file_path = './60_ATLib_DBI_Command.sqlite';
my $conn_string = ATLib::Std::String->from("dbi:SQLite:dbname=$db_file_path");
my $conn = ATLib::DBI::Connection->create($conn_string);
my $attr_of = {AutoCommit => 1};
$conn->_set__attr_of($attr_of);
$conn->open();
my $instance = $conn->create_command();
isa_ok($instance, $class);

#4
my $message = ATLib::Std::String->from('Connection is not specified, Or connection is not opened yet');
$conn->close();
throws_ok { $instance->execute_non_query(); } qr/$message/, 'Cannot execute command because the connection is not opened.';

#5
$conn = undef;
throws_ok { $instance->execute_non_query(); } qr/$message/, 'Cannot execute command because the connection is not opened.';

#6
$message = ATLib::Std::String->from('Command text is not specified');
$conn = ATLib::DBI::Connection->create($conn_string);
$conn->_set__attr_of($attr_of);
$conn->open();
$instance = $conn->create_command();
my $sql = ATLib::Std::String->from('');
$instance->command_text($sql);
throws_ok { $instance->execute_non_query(); } qr/$message/, 'Cannot execute command because the command is not specified.';

#7
$message = ATLib::Std::String->from('Fail to prepare SQL statement');
$sql = ATLib::Std::String->from('abcdefg');
$instance->command_text($sql);
throws_ok { $instance->execute_non_query(); } qr/$message/, 'Cannot execute command because the command is illegal.';

#8
$sql = ATLib::Std::String->from(q{
CREATE TABLE T_COMMAND
(
  ID   NUMERIC NOT NULL
 ,NAME TEXT
 ,CONSTRAINT T_COMMAND_PK PRIMARY KEY ( ID )
)
});
$instance->command_text($sql);
my $num_affect_rows = $instance->execute_non_query();
is($num_affect_rows, 0);

#9
$conn->begin_transaction();
$sql = ATLib::Std::String->from(q{
INSERT INTO T_COMMAND
(
  ID
 ,NAME
)
VALUES
(
  \ID\
 ,\NAME\
)
});
$instance->command_text($sql);
$instance->parameters->add("ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(9));
$instance->parameters->add("NAME", ATLib::DBI::Parameter->DB_TYPE_STRING, ATLib::Std::String->from('The command of INSERT!'));
$num_affect_rows = $instance->execute_non_query();
is($num_affect_rows, 1);

#10
$sql = ATLib::Std::String->from(q{
SELECT
  COUNT(*) CNT
FROM
  T_COMMAND TC
WHERE
  TC.ID = \ID\
});
$instance->parameters->clear();
$instance->parameters->add("ID", ATLib::DBI::Parameter->DB_TYPE_DECIMAL, ATLib::Std::Int->from(9));
$instance->command_text($sql);
my $reader = $instance->execute_reader();
isa_ok($reader, "ATLib::DBI::Reader");

$conn->commit();

done_testing();
__END__
