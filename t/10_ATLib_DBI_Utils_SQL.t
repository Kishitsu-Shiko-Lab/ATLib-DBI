#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 6;

use ATLib::Std;

my $class = q{ATLib::DBI::Utils::SQL};

#1
use_ok($class);

# parse_bind_variable()
#2
my $sql = ATLib::Std::String->from(q{
SELECT
  TA.ID
 ,TA.VALUE
 ,TA.NOTE
 ,TA.FLAG
 ,|V_FIXED_FIELD|||  AS FIXED_FIELD
 ,|V_FIXED_FIELD2||| AS FIXED_FIELD2
FROM
  TABLE_A TA
WHERE
  TA.ID   =  |P_ID|||
AND
  TA.FLAG =  |P_FLAG|||
});
my $prefix = ATLib::Std::String->from('|');
my $suffix = ATLib::Std::String->from('|||');
my $bind_variable_list = $class->parse_bind_variable($prefix, $suffix, $sql);
is($bind_variable_list->count, 4);

#3
ok($bind_variable_list->item(0)->equals('V_FIXED_FIELD'));

#4
ok($bind_variable_list->item(1)->equals('V_FIXED_FIELD2'));

#5
ok($bind_variable_list->item(2)->equals('P_ID'));

#6
ok($bind_variable_list->item(3)->equals('P_FLAG'));

done_testing();

__END__