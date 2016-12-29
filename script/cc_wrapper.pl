use strict;
use warnings;
use Config;
use Text::ParseWords qw( shellwords );
use Alien::pkgconf;

exec $Config{cc}, shellwords(Alien::pkgconf->cflags), @ARGV;
