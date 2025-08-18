#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 29;
use Test::Exception;

use ATLib::Std;
use ATLib::DBI::Parameter;

#1
my $class = 'ATLib::DBI::ParameterList';
use_ok($class);

#2
my $instance = $class->_create();
isa_ok($instance, $class);

#3
is($instance->count, 0);

#4
my @param_name = ('P_TEST');
my @param_db_type = (ATLib::DBI::Parameter->DB_TYPE_DECIMAL);
my @param_value = (rand(1000));
my @param_direction = (ATLib::DBI::Parameter->DIRECTION_INPUT_OUTPUT);
ok(!$instance->contains($param_name[0]));

#5
my $result = $instance->add(
    $param_name[0],
    $param_db_type[0],
    $param_value[0],
    $param_direction[0]
);
isa_ok($result, $class);

#6
is($instance->count, scalar(@param_name));

#7
ok($instance->contains($param_name[0]));

#8
my $param = $instance->item(0);
isa_ok($param, 'ATLib::DBI::Parameter');

#9
is($param->name, $param_name[0]);

#10
is($param->db_type, $param_db_type[0]);

#11
is($param->direction, $param_direction[0]);

#12
is($param->value->value, $param_value[0]);

#13
my $message = q{Out of range};
my $i = $instance->count;
throws_ok { $instance->remove_at($i); } qr/$message/, 'Cannot remove param because index is overflowed.';

#14
$param_name[scalar(@param_name)] = 'P_TEST2';
$param_db_type[scalar(@param_value)] = ATLib::DBI::Parameter->DB_TYPE_STRING;
$param_value[scalar(@param_value)] = q{TEST2_STRING_VALUE};
$param_direction[scalar(@param_direction)] = ATLib::DBI::Parameter->DIRECTION_INPUT;
$instance->add(
    $param_name[1],
    $param_db_type[1],
    $param_value[1],
    $param_direction[1]
);

is($instance->count, scalar(@param_name));

#15
ok($instance->contains($param_name[1]));

#16
$param = $instance->item(1);
isa_ok($param, 'ATLib::DBI::Parameter');

#17
is($param->name, $param_name[1]);

#18
is($param->db_type, $param_db_type[1]);

#19
is($param->direction, $param_direction[1]);

#20
is($param->value->value, $param_value[1]);

#21
$instance->remove_at($param_name[1]);
is($instance->count, scalar(@param_name) - 1);

#22
ok(!$instance->contains($param_name[1]));

#23
ok($instance->contains($param_name[0]));

#24
my $param_list = $instance->clear();
isa_ok($param_list, $class);

#25
is($instance->count, 0);

#26
$param = ATLib::DBI::Parameter->_create({
    name      => $param_name[0],
    db_type   => $param_db_type[0],
    direction => $param_db_type[0],
    value     => $param_value[0],
});
$instance->add($param);
is($instance->count, 1);

#27
$instance->remove_at($param);
is($instance->count, 0);

#28
$result = $instance->remove($param);
ok(!$result);

#29
$param = ATLib::DBI::Parameter->_create({
    name      => $param_name[0],
    db_type   => $param_db_type[0],
    direction => $param_db_type[0],
    value     => $param_value[0],
});
$instance->add($param);
$result = $instance->remove($param);
ok($result);

done_testing();
__END__
