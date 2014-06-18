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
        'Test::More'        => 0,
        'Time::Seconds'     => 0,
        'Moo'               => 0,
        'Carp'              => 0,
        'Module::Runtime'   => 0,
        'POSIX' 	        => 0
    },
    PREREQ_PM => {
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Time-Duration-Concise-Localize-*' },
);
