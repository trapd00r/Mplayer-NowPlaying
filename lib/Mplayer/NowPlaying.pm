#!/usr/bin/perl
package Mplayer::NowPlaying;
use vars qw($VERSION);

$VERSION = '0.015';

BEGIN {
  require Exporter;
  use vars qw(@ISA @EXPORT_OK);
  @ISA    = 'Exporter';
  @EXPORT = qw(now_playing);
}

use strict;
use Carp;
use Mplayer::NowPlaying::Genres;

sub now_playing {
  my($log, $mode) = @_;
  not defined $log and croak("No logfile specified");

  if(!defined($mode)) {
    $mode = 'default'; # mplayer *.mp3
  }

  my @content;
  if(!ref($log)) {
    open(my $fh, '<', $log) or croak("Can not open $log for reading: $!");
    chomp(@content = <$fh>);
  }
  else {
    @content = <$log>;
    chomp(@content);
  }

  my %mplayer_internals = (
    ID_CLIP_INFO_VALUE0 => 'title',
    ID_CLIP_INFO_VALUE1 => 'artist',
    ID_CLIP_INFO_VALUE2 => 'album',
    ID_CLIP_INFO_VALUE3 => 'year',
    ID_CLIP_INFO_VALUE4 => 'comment',
    ID_CLIP_INFO_VALUE5 => 'genre',
    ID_AUDIO_BITRATE    => 'bitrate',
    ID_AUDIO_CODEC      => 'codec',
    ID_AUDIO_FORMAT     => 'format',
    ID_AUDIO_ID         => 'id',
    ID_AUDIO_NCH        => 'channels',
    ID_CHAPTERS         => 'chapters',
    ID_AUDIO_RATE       => 'audio',
    ID_DEMUXER          => 'demuxer',
    ID_LENGTH           => 'length',
    ID_SEEKABLE         => 'seekable', # 1,0
    ID_START_TIME       => 'start',
    ID_FILENAME         => 'file',
  );


  my $regex;
  if($mode eq 'default') {
    $regex = qr/\s*
      (
          codec
        | Bitrate
        | File
        | chapters
        | demuxer
        | seekable
        | id
        | channels
        | genre
        | Artist
        | Album
        | length
        | Comment
        | format
        | Title
        | Year
        | start
      )[=:](.+)\b
    /x;
  }

  elsif($mode eq 'identify') { # mplayer -msglevel identify=4
    my $id = join('|', keys(%mplayer_internals));
    $regex = qr/\b($id\S+)=(.+)\b/o;
  }

  my %information;

  CONTENT:
  for my $l(@content) {
    if($l =~ m/$regex/) {
      my($tag, $value) = ($1, $2);

      if(exists($mplayer_internals{$tag})) { # identify used
        $tag = $mplayer_internals{$tag};
        if($tag eq 'genre') {
          $value = get_genre($value);
        }
      }

      $value =~ s/^\s+|\s+$//;
      $information{$tag} = $value;
      next CONTENT;
    }
  }
  return \%information;
}


1;


__END__

=pod

=head1 NAME

Mplayer::NowPlaying - query a running mplayer process for now playing metadata

=head1 SYNOPSIS

    use Mplayer::NowPlaying;

    ...

    my $current = now_playing;

    if(exists($current->{artist})) {
      print "Current artist is $current->{artist}\n";
    }

=head1 DESCRIPTION

B<Mplayer::NowPlaying> was born because the author runs B<mplayer> daemonized,
controlling it via named pipes. I wanted a simple way to retrieve various 'now
playing' metadata for the currently playing media.

Mplayer::NowPlaying supports two modes:

=head2 Normal

Start mplayer in normal mode and redirect STDOUT to a file:

  mplayer *.mp3 > ./mplayer_log

Get the current title:

  # 'normal' argument optional; this is the default
  my $now_playing = now_playing("$ENV{HOME}/mplayer.log", 'normal');

  printf("Current title is %s\n", $now_playing->{title});

Mplayer produces a lot of output in normal mode, effectively making our metadata
retrieval slow very fast (10 files played or so). Therefore it's really
recommended to use B<identify> mode.

=head2 Identify

Start mplayer with the -identify switch:

  mplayer -identify *.mp3 > mplayer_log

or the preferred

  mplayer -quiet -msglevel all=0 -identify *.mp3 > mplayer_log

Get the current title:

  # note 'identify' argument
  my $now_playing = now_playing("$ENV{HOME}/mplayer.log", 'identify');

  printf("Current title is %s\n", $now_playing->{title});

By using B<-msglevel all=0 -identify> the amount of output from mplayer is
reduced to a minimum, making the retrieval very fast. This is recommended.

=head1 EXPORTS

=head2 now_playing()

Parameters: ($logfile | $filehandle), ($mode)

Returns:    \%metadata

  my %metadata = %{ now_playing($logfile, 'identify'); };
  my $artist = $metadata{artist};

B<now_playing()> takes two arguments (the last one optional):

* The logfile (or filehandle) output from mplayer is directed to

* 'normal' or 'identify' mode. Normal is the default.

The hash will be filled with the available metadata for the current media.
A typical result might look like:

  album    => "Me and Simon",
  artist   => "Laleh",
  audio    => 44100,
  bitrate  => 128000,
  channels => 2,
  chapters => 0,
  codec    => "mp3",
  demuxer  => "audio",
  file     => "~/Laleh-Me_and_Simon/01-big_city_love.mp3",
  format   => 85,
  genre    => 1,
  id       => 0,
  length   => "1288.00",
  seekable => 1,
  start    => "0.00",
  title    => "Big city love",
  year     => 2009

Possible keys include:

  title
  artist
  album
  year
  comment
  genre
  bitrate
  codec
  format
  id
  channels
  chapters
  audio
  demuxer
  length
  seekable,
  start
  file

=head1 AUTHOR

  Magnus Woldrich
  CPAN ID: WOLDRICH
  magnus@trapd00r.se
  http://japh.se

=cut

=head1 COPYRIGHT

Copyright 2011 Magnus Woldrich <magnus@trapd00r.se>. This program is free
software; you may redistribute it and/or modify it under the same terms as Perl
itself.

=head1 SEE ALSO

L<Mplayer::NowPlaying::Genres>

=cut
