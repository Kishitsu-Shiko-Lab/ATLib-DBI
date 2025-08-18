#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;
use Test::Exception;

use ATLib::Std;

#1
my $class = 'ATLib::DBI::Exception';
use_ok($class);

#2
my $error_string = ATLib::Std::String->from('Value of DBI::errstr');
my $instance = $class->new({
    message      => ATLib::Std::String->from('This is exception of unit test.'),
    error_string => $error_string,
});
isa_ok($instance, $class);

#3
is($instance->type_name, $class);

#4
throws_ok { $instance->throw(); } qr/$error_string/, 'ATLib::DBI::Exception thrown.';

done_testing();
__END__
