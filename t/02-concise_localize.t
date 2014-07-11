#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::FailWarnings;
use Test::Exception;
use Time::Duration::Concise::Localize;

use lib 't';

plan tests => 16;

my $duration = Time::Duration::Concise::Localize->new(
    interval => '1d1.5h',
    'localize_class' => 'i18n',
    'localize_method' => sub {
         i18n->new( 'language' => 'ms-my' )->translate_time_duration(@_);
     }
);

is ( ref $duration->localize_method, 'CODE', 'Localize anonymous method');
is ( $duration->days, 1.0625, 'Days');
is ( $duration->hours, 25.5, 'Hours');
is ( $duration->minutes, 1530, 'Minutes');
is ( $duration->as_string, '1 hari 1 jam 30 minit', 'As string');
is ( $duration->as_string(1), '1 hari', 'As string precision 1');
is ( $duration->as_string(2), '1 hari 1 jam', 'As string precision 2');
is ( $duration->as_string(3), '1 hari 1 jam 30 minit', 'As string precision 3');
is ( $duration->as_concise_string, '1d1h30m', 'Concise format');
is ( scalar @{$duration->duration_array(3)}, '3', 'Duration array precision 3');
is ( scalar @{$duration->duration_array(1)}, '1', 'Duration array precision 1');
is ( $duration->minimum_number_of('seconds'), 91800, 'Minimum number of seconds');
is ( $duration->minimum_number_of('s'), 91800, 'Minimum number of unt s');

is ( $duration->duration->{'pretty'}, '1 days, 1 hours, 30 minutes, 0 seconds', 'Time::Seconds prettfies good');
is ( $duration->normalized_code, '1530m', 'normalized code is good');

subtest "concise format input require" => sub {
    plan tests => 3;
    my $duration;
    throws_ok { $duration = Time::Duration::Concise::Localize->new() } qr/Missing required arguments/, "missing required argument test";
    throws_ok {
        $duration = Time::Duration::Concise::Localize->new( interval => '1d1.5h' )
    } qr/Missing required arguments/, "missing required localize class";
    throws_ok {
        $duration = Time::Duration::Concise::Localize->new( interval => '1d1.5h', 'localize_class' => 'i18n' )
    } qr/Missing required arguments/, "missing required localize method";

};

