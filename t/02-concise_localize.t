#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';

use Test::More;
use Time::Duration::Concise::Localize;
use File::Basename;

plan tests => 12;

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
is ( $duration->as_string, '1 hari, 1 jam, 30 minit', 'As string');
is ( $duration->as_string(1), '1 hari', 'As string precision 1');
is ( $duration->as_string(2), '1 hari, 1 jam', 'As string precision 2');
is ( $duration->as_string(3), '1 hari, 1 jam, 30 minit', 'As string precision 3');
is ( scalar @{$duration->duration_array(3)}, '3', 'Duration array precision 3');
is ( scalar @{$duration->duration_array(1)}, '1', 'Duration array precision 1');
is ( $duration->minimum_number_of('seconds'), 91800, 'Minimum number of seconds');
is ( $duration->minimum_number_of('s'), 91800, 'Minimum number of unt s');
