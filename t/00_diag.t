use strict;
use warnings;
use Test::More tests => 1;
use PkgConfig::LibPkgConf::Client;

diag '';
diag '';
diag '';

foreach my $method (qw( dir_list filter_libdirs filter_includedirs ))
{
  if(PkgConfig::LibPkgConf::Client->can($method))
  {
    # delete local $ENV{FOO} is the modern way to do this
    # but apparently only works in Perl 5.12 or better.
    local %ENV = %ENV;
    delete $ENV{$_} 
      for qw( PKG_CONFIG_PATH 
              PKG_CONFIG_LIBDIR 
              PKG_CONFIG_SYSTEM_LIBRARY_PATH 
              PKG_CONFIG_SYSTEM_INCLUDE_PATH );
    diag "[pkgconf $method]";
    foreach my $dir (PkgConfig::LibPkgConf::Client->new->env->$method)
    {
      diag $dir;
    }

    diag '';
    diag '';
  }
}

diag '[impl]';
diag $PkgConfig::LibPkgConf::impl;

diag '';
diag '';
diag '';


ok 1;
done_testing;
