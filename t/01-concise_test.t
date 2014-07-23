#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::FailWarnings;
use Test::Exception;
use Time::Duration::Concise;

plan tests => 16;

my $duration = Time::Duration::Concise->new(
    interval => '1d1.5h'
);

is ( $duration->seconds, 91800, 'Seconds');
is ( $duration->days, 1.0625, 'Days');
is ( $duration->hours, 25.5, 'Hours');
is ( $duration->minutes, 1530, 'Minutes');
is ( $duration->as_string, '1 day 1 hour 30 minutes', 'As string');
is ( $duration->as_string(1), '1 day', 'As string precision 1');
is ( $duration->as_string(2), '1 day 1 hour', 'As string precision 2');
is ( $duration->as_string(3), '1 day 1 hour 30 minutes', 'As string precision 3');
is ( scalar @{$duration->duration_array(3)}, '3', 'Duration array precision 3');
is ( scalar @{$duration->duration_array(1)}, '1', 'Duration array precision 1');
is ( $duration->minimum_number_of('seconds'), 91800, 'Minimum number of seconds');
is ( $duration->minimum_number_of('s'), 91800, 'Minimum number of units');
is ( $duration->minimum_number_of('s'), 91800, 'Minimum number of units s');
is ( $duration->duration->{'time'}->pretty, '1 days, 1 hours, 30 minutes, 0 seconds', 'Time::Seconds prettfies good');

subtest "concise format input require" => sub {
    plan tests => 1;
    my $duration;
    throws_ok { Time::Duration::Concise->new() } qr/Missing required arguments/, "missing required argument test";
};

subtest "general concise format check" => sub {
    plan tests => 2;
    my $duration;
    lives_ok { $duration = Time::Duration::Concise->new( interval => '1y1d1.5h' ) } "object initilized";
    throws_ok { $duration->seconds() } qr/Bad format supplied/, "concise format supplied wrong";
};
