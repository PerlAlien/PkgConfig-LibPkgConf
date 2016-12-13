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

sub find
{
  my($self, $name, $flags) = @_;
  my $ptr = _find($self, $name, $flags||0);
  $ptr ? bless { client => $self, name => $name, ptr => $ptr }, 'PkgConfig::LibPkgConf::Package' : ();
}

1;
