package PkgConfig::LibPkgConf::FFI;

use strict;
use warnings;
use FFI::Platypus 0.43;
use FFI::CheckLib 0.15 qw( find_lib_or_exit );
use constant PKGCONF_PKG_PKGF_NONE     => 0x000;
use constant PKGCONF_PKG_PKGF_ENV_ONLY => 0x002;

#####
##### !!!! WARNING: This FFI version is highly experimental, unstable, and may be removed at any time !!!!
#####

our $VERSION = '0.01';

$PkgConfig::LibPkgConf::impl =
$PkgConfig::LibPkgConf::impl = 'FFI';

my $ffi = FFI::Platypus->new;
$ffi->lib(find_lib_or_exit lib => 'pkgconf');

##
## TYPES
##

$ffi->type('(string,opaque,opaque)->int' => 'error_handler_func_t');
$ffi->type('(opaque,opaque)->int' => 'pkgconf_pkg_iteration_func_t');
$ffi->type('opaque' => 'pkgconf_client_t');
$ffi->type('opaque' => 'pkgconf_pkg_t');
$ffi->type('opaque' => 'FILE');

$ffi->attach(
  [ pkgconf_client_new => 'PkgConfig::LibPkgConf::Client::_init' ],
  [ 'error_handler_func_t', 'opaque' ] => 'opaque',
  sub {
    my($sub, $object, $args, $error_handler) = @_;
    my $self = $object->{ffi} = {};
    $self->{auditf} = undef;
    $self->{flags}  = 0;
    $self->{error_handler} = $error_handler;
    # TODO:
    #$self->{ptr} = $sub->($self->{error_handler}, undef);
    $object->{ptr} = $sub->(undef, undef);
    ();
  }
);

$ffi->attach(fclose => [ 'FILE' ] => 'int');
$ffi->attach(fopen  => [ 'string', 'string' ] => 'FILE');

##
## PkgConfig::LibPkgConf::Client
##

$ffi->attach(
  [ pkgconf_audit_set_log => 'PkgConfig::LibPkgConf::Client::audit_set_log' ],
  [ 'pkgconf_client_t', 'FILE' ] => 'void',
  sub {
    my($sub, $object, $filename, $mode) = @_;
    my $self = $object->{ffi};
    my $ptr  = $object->{ptr};
    if($self->{auditf})
    {
      fclose($self->{auditf});
      $self->{auditf} = undef;
    }
    $self->{auditf} = fopen($filename, $mode);
    if($self->{auditf})
    {
      $sub->($ptr, $self->{auditf});
    }
    else
    {
      # TODO: call error ?
    }
  }
);

$ffi->attach( pkgconf_client_set_sysroot_dir   => [ 'pkgconf_client_t', 'string' ] => 'void' );
$ffi->attach( pkgconf_client_set_buildroot_dir => [ 'pkgconf_client_t', 'string' ] => 'void' );

$ffi->attach(
  [ 'pkgconf_client_get_sysroot_dir' => 'PkgConfig::LibPkgConf::Client::sysroot_dir' ],
  [ 'pkgconf_client_t' ] => 'string',
  sub {
    my($sub, $object, $value) = @_;
    my $self = $object->{ffi};
    my $ptr  = $object->{ptr};
    if(@_ > 2)
    {
      pkgconf_client_set_sysroot_dir($ptr, $value);
    }
    $sub->($ptr);
  }
);

$ffi->attach(
  [ 'pkgconf_client_get_buildroot_dir' => 'PkgConfig::LibPkgConf::Client::buildroot_dir' ],
  [ 'pkgconf_client_t' ] => 'string',
  sub {
    my($sub, $object, $value) = @_;
    my $self = $object->{ffi};
    my $ptr  = $object->{ptr};
    if(@_ > 2)
    {
      pkgconf_client_set_buildroot_dir($ptr, $value);
    }
    $sub->($ptr);
  }
);

$ffi->attach(
  [ 'pkgconf_client_free' => 'PkgConfig::LibPkgConf::Client::DESTROY' ],
  [ 'pkgconf_client_t' ] => 'void',
  sub {
    my($sub, $object) = @_;
    my $self = $object->{ffi};
    my $ptr  = $object->{ptr};
    if($self->{auditf})
    {
      fclose($self->{auditf});
      $self->{auditf} = undef;
    }
    $sub->($ptr);
  }
);

$ffi->attach(
  [ pkgconf_pkg_find => 'PkgConfig::LibPkgConf::Client::_find' ],
  [ 'pkgconf_client_t', 'string' ] => 'pkgconf_pkg_t',
  sub {
    my($sub, $object, $string) = @_;
    my $ptr  = $object->{ptr};
    $sub->($ptr, $string);
  },
);

$ffi->attach(
  [ 'pkgconf_scan_all' => 'PkgConfig::LibPkgConf::Client::_scan_all' ],
  [ 'pkgconf_client_t', 'opaque', 'pkgconf_pkg_iteration_func_t' ] => 'void', # actually returns pkgconf_pkg_t
  sub {
    my($sub, $object, $callback) = @_;
    my $self = $object->{ffi};
    my $ptr  = $object->{ptr};
    # TODO:
    #$sub->($ptr, undef, $callback);
  }
);

$ffi->attach( pkgconf_pkg_dir_list_build => [ 'pkgconf_client_t', 'int' ] => 'void' );

sub PkgConfig::LibPkgConf::Client::_env
{
  my($object) = @_;
  my $ptr  = $object->{ptr};
  pkgconf_pkg_dir_list_build($ptr, PKGCONF_PKG_PKGF_NONE);
}

sub PkgConfig::LibPkgConf::Client::_dir_list_build
{
  my($object) = @_;
  my $ptr  = $object->{ptr};
  pkgconf_pkg_dir_list_build($ptr, PKGCONF_PKG_PKGF_ENV_ONLY);
}

# TODO: dir_list

##
## PkgConfig::LibPkgConf::Package
##

sub PkgConfig::LibPkgConf::Package::refcount       {}
sub PkgConfig::LibPkgConf::Package::id             {}
sub PkgConfig::LibPkgConf::Package::filename       {}
sub PkgConfig::LibPkgConf::Package::realname       {}
sub PkgConfig::LibPkgConf::Package::version        {}
sub PkgConfig::LibPkgConf::Package::description    {}
sub PkgConfig::LibPkgConf::Package::url            {}
sub PkgConfig::LibPkgConf::Package::pc_filedir     {}

sub PkgConfig::LibPkgConf::Package::libs           {}
sub PkgConfig::LibPkgConf::Package::libs_private   {}
sub PkgConfig::LibPkgConf::Package::cflags         {}
sub PkgConfig::LibPkgConf::Package::cflags_private {}

##
## PkgConfig::LibPkgConf::Util
##

$ffi->attach_cast("opaque_to_string" => 'opaque' => 'string');

$ffi->attach(
  [ 'pkgconf_argv_split' => 'PkgConfig::LibPkgConf::Util::argv_split' ],
  [ 'string', 'opaque*', 'int*' ] => 'int',
  sub {
    my($sub, $src) = @_;
    my($argc, $argv);
    my $ret = $sub->($src, \$argc, \$argv);
    if($ret == 0)
    {
      return map { opaque_to_string($_) } @{ $ffi->cast('opaque' => "opaque[$argc]", $argv) };
    }
    else
    {
      require Carp;
      Carp::croak("error in argv_split");
    }
  }
);

$ffi->attach(
  [ pkgconf_compare_version => 'PkgConfig::LibPkgConf::Util::compare_version' ],
  [ 'string', 'string' ] => 'int',
);

##
## PkgConfig::LibPkgConf::Test
##

$ffi->attach(
  [ 'pkgconf_error' => 'PkgConfig::LibPkgConf::Test::send_error' ],
  [ 'pkgconf_client_t', 'string', 'string' ],
  sub {
    my($sub, $object, $message) = @_;
    my $ptr = $object->{ptr};
    $sub->($ptr, "%s", $message);
  }
);

$ffi->attach(
  [ 'pkgconf_audit_log' => 'PkgConfig::LibPkgConf::Test::send_log' ],
  [ 'pkgconf_client_t', 'string', 'string' ],
  sub {
    my($sub, $object, $message) = @_;
    my $ptr = $object->{ptr};
    $sub->($ptr, "%s", $message);
  }
);

1;
