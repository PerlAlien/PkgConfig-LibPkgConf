use strict;
use warnings;
use Config;
use Text::ParseWords qw( shellwords );
use Alien::pkgconf;

my @list = (
  $Config{cc},
  @ARGV,
  shellwords(Alien::pkgconf->libs),
);

#print "+@list\n";

exec @list;
