package PkgConfig::LibPkgConf::Client;

use strict;
use warnings;
use PkgConfig::LibPkgConf;

sub new
{
  my($class) = @_;
  my $ptr = _new();
  bless \$ptr, $class;
}

1;
