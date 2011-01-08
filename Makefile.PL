use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Mplayer::NowPlaying',
    AUTHOR              => q{Magnus Woldrich <trapd00r@trapd00r.se>},
    VERSION_FROM        => 'lib/Mplayer/NowPlaying.pm',
    ABSTRACT_FROM       => 'lib/Mplayer/NowPlaying.pm',

    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),

    PL_FILES            => {},

    PREREQ_PM           => {
      'Test::More' =>     0,
    },

    EXE_FILES           => [
                          ],

    MAN1PODS            => {
    },

    MIN_PERL_VERSION    => 0,

    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Mplayer::NowPlaying-*' },
);
