use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Time::Duration::Concise::Localize',
    AUTHOR           => q{Binary.com <perl@binary.com>},
    VERSION_FROM     => 'lib/Time/Duration/Concise/Localize.pm',
    ABSTRACT_FROM    => 'lib/Time/Duration/Concise/Localize.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
	'Test::NoWarnings'   => 0,
        'Test::More'         => 0,
        'Test::FailWarnings' => 0,
        'Test::Exception'    => 0,
    },
    PREREQ_PM => {
        'Tie::Hash::LRU'     => 0,
        'Carp'               => 0,
        'Module::Runtime'    => 0,
        'POSIX' 	         => 0,
        'Time::Seconds'      => 1.27,
    },
    (! eval { ExtUtils::MakeMaker->VERSION(6.46) } ? () :
        (META_ADD => {
            resources => {
                homepage   => 'https://github.com/binary-com/perl-Time-Duration-Concise-Localize',
                repository => 'git@github.com:binary-com/perl-Time-Duration-Concise-Localize.git',
                bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Time-Duration-Concise-Localize',
            },
        })
    ),
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Time-Duration-Concise-Localize-*' },
);
