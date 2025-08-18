#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 26;
use Test::Exception;

use ATLib::Std;

#1
SKIP: {
    eval { require DBD::SQLite };
    skip 'DBD::SQLite is not installed', 1, if defined $@;
}

#2
my $class = 'ATLib::DBI::Connection';
use_ok($class);

#3
my $instance = $class->create();
isa_ok($instance, $class);

#4
is($instance->type_name, $class);

#5
is($instance->state, $class->STATE_CLOSE);

#6
ok(!$instance->in_transaction);

#7
my $message = 'the connection was closed.';
throws_ok { $instance->begin_transaction(); } qr/$message/, 'Cannot begin a transaction because the connection is not opened.';

#8
throws_ok { $instance->commit(); } qr/$message/, 'Cannot commit a transaction because the connection is not opened.';

#9
throws_ok { $instance->rollback(); } qr/$message/, 'Cannot rollback a transaction because the connection is not opened.';

#10
$instance->close();
ok(!$instance->in_transaction);

#11
is($instance->state, $class->STATE_CLOSE);

#12
ok(ATLib::Std::String->is_undef_or_empty($instance->connection_string));

#13
$message = 'connection is already opened or connection string is not specified.';
throws_ok { $instance->open(); } qr/$message/, 'Cannot open a connection because connection string is not specified.';

#14
my $db_file_path = './30_ATLib_DBI_Connection.sqlite';
my $connection_string = ATLib::Std::String->from("dbi:SQLite:dbname=$db_file_path");
$instance->connection_string($connection_string);
is($instance->connection_string, $connection_string);

#15
my $attr_of = {AutoCommit => 1};
$instance->_set__attr_of($attr_of);
$instance->open();
is($instance->state, $class->STATE_OPEN);

#16
ok(!$instance->in_transaction);

#17
my $db_file_is_exists = ATLib::Std::Bool->false;
if (-e $db_file_path)
{
    $db_file_is_exists = ATLib::Std::Bool->true;
}
ok($db_file_is_exists);

#18
throws_ok { $instance->open(); } qr/$message/, 'Cannot re-open the connection.';

#19
$instance->begin_transaction();
ok($instance->in_transaction);

#20
$instance->rollback();
ok(!$instance->in_transaction);

#21
$message = "The transaction was commited or rollback, or the connection was closed.";
throws_ok { $instance->commit(); } qr/$message/, 'Cannot commit a transaction because the connection is not opened.';

#22
throws_ok { $instance->rollback(); } qr/$message/, 'Cannot rollback a transaction because the connection is not opened.';

#23
$instance->begin_transaction();
ok($instance->in_transaction);

#24
$instance->commit();
ok(!$instance->in_transaction);

#25
throws_ok { $instance->commit(); } qr/$message/, 'Cannot commit a transaction because the connection is not opened.';

#26
throws_ok { $instance->rollback(); } qr/$message/, 'Cannot rollback a transaction because the connection is not opened.';

done_testing();
__END__
