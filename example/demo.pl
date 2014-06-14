#!/usr/bin/perl

use Time::Duration::Concise::Localize;

my $time_duration = Time::Duration::Concise::Localize->new(
    'interval' => '1.5h',
    'localize_class' => 'i18n',
    'localize_method' => sub {
         i18n->new( 'language' => 'hin-hin' )->translate_time_duration(@_);
     }
);

print $time_duration->as_string(), "\n";

$time_duration = Time::Duration::Concise::Localize->new(
    'interval' => '1.5h',
    'localize_class' => 'i18n',
    'localize_method' => sub {
         i18n->new( 'language' => 'ms-my' )->translate_time_duration(@_);
     }
);

print $time_duration->as_string(), "\n";

