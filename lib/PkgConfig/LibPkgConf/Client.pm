package PkgConfig::LibPkgConf::Client;

use strict;
use warnings;
use PkgConfig::LibPkgConf;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

sub new
{
  my $class = shift;
  my $args = ref $_[0] eq 'HASH' ? shift : { @_ };
  my $self = bless {}, $class;
  _init($self, $args);
  $self;
}

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
