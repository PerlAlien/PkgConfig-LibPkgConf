package PkgConfig::LibPkgConf::Client;

use strict;
use warnings;
use PkgConfig::LibPkgConf;

our $VERSION = '0.01';

# PKG_CONFIG_PATH
# PKG_CONFIG_LIBDIR
# PKG_CONFIG_SYSTEM_LIBRARY_PATH
# PKG_CONFIG_SYSTEM_INCLUDE_PATH
# PKG_CONFIG_DEBUG_SPEW
# PKG_CONFIG_IGNORE_CONFLICTS
# PKG_CONFIG_PURE_DEPGRAPH
# PKG_CONFIG_DISABLE_UNINSTALLED
# PKG_CONFIG_ALLOW_SYSTEM_CFLAGS
# PKG_CONFIG_ALLOW_SYSTEM_LIBS
# PKG_CONFIG_TOP_BUILD_DIR
# PKG_CONFIG_SYSROOT_DIR
# PKG_CONFIG_LOG

sub new
{
  my $class = shift;
  my $args = ref $_[0] eq 'HASH' ? { %{$_[0]} } : { @_ };
  my $self = bless {}, $class;
  _init($self, $args);
  $self;
}

sub env
{
  my($self) = @_;
  if($ENV{PKG_CONFIG_LOG})
  {
    $self->audit_set_log($ENV{PKG_CONFIG_LOG}, "w");
  } 
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
