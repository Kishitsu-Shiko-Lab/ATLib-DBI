#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 6;

use ATLib::Utils qw{as_type_of};
use ATLib::Std;

#1
my $class = 'ATLib::DBI::Parameter';
use_ok($class);

#2
my $param_name = 'P_ID';
my $instance = $class->_create({
    name    => $param_name,
    db_type => ATLib::DBI::Parameter->DB_TYPE_STRING,
});
isa_ok($instance, $class);

#3
is($instance->name, $param_name);

#4
is($instance->db_type, ATLib::DBI::Parameter->DB_TYPE_STRING);

#5
is($instance->direction, ATLib::DBI::Parameter->DIRECTION_INPUT);

#6
ok(!$instance->value->has_value);

done_testing();
__END__
