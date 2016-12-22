use strict;
use warnings;
use Test::More;
use PkgConfig::LibPkgConf;

$ENV{PKG_CONFIG_PATH} = 'corpus/lib1';
$ENV{PKG_CONFIG_LIBDIR} = '';
$ENV{PKG_CONFIG_SYSTEM_LIBRARY_PATH} = '';
$ENV{PKG_CONFIG_SYSTEM_INCLUDE_PATH} = '';

ok pkgconf_exists('foo');
ok !pkgconf_exists('bogus');

is pkgconf_version('foo'), '1.2.3';
eval { pkgconf_version('bogus') };
like $@, qr{package bogus not found};

is pkgconf_cflags('foo'), '-fPIC -I/test/include/foo ';
eval { pkgconf_cflags('bogus') };
like $@, qr{package bogus not found};

is pkgconf_libs('foo'), '-L/test/lib -lfoo ';
eval { pkgconf_libs('bogus') };
like $@, qr{package bogus not found};

done_testing;
