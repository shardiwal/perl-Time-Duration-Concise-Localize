#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Time::Duration::Concise::Localize' ) || print "Bail out!\n";
}

diag( "Testing Time::Duration::Concise::Localize $Time::Duration::Concise::Localize::VERSION, Perl $], $^X" );
