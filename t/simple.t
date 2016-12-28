use strict;
use warnings;
use Test::More;
use PkgConfig::LibPkgConf;

$ENV{PKG_CONFIG_PATH} = 'corpus/lib1';
$ENV{PKG_CONFIG_LIBDIR} = '';
$ENV{PKG_CONFIG_SYSTEM_LIBRARY_PATH} = '';
$ENV{PKG_CONFIG_SYSTEM_INCLUDE_PATH} = '';

ok pkgconf_exists('foo'),    'pkgconf_exists found';
ok !pkgconf_exists('bogus'), 'pkgconf_exists not found';

is pkgconf_version('foo'), '1.2.3', 'pkgconf_version found';
eval { pkgconf_version('bogus') };
like $@, qr{package bogus not found}, 'pkgconf_version not found';

is pkgconf_cflags('foo'), '-fPIC -I/test/include/foo ', 'pkgconf_cflags found';
eval { pkgconf_cflags('bogus') };
like $@, qr{package bogus not found}, 'pkgconf_cflags not found';

is pkgconf_libs('foo'), '-L/test/lib -lfoo ', 'pkgconf_libs found';
eval { pkgconf_libs('bogus') };
like $@, qr{package bogus not found}, 'pkgconf_libs not found';

done_testing;
