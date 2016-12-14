package PkgConfig::LibPkgConf::Client;

use strict;
use warnings;
use PkgConfig::LibPkgConf;

sub find
{
  my($self, $name, $flags) = @_;
  my $ptr = _find($self, $name, $flags||0);
  $ptr ? bless { client => $self, name => $name, ptr => $ptr }, 'PkgConfig::LibPkgConf::Package' : ();
}

sub error
{
  my($self, $msg) = @_;
  require Carp;
  Carp::carp($msg);
  1;
}

1;
