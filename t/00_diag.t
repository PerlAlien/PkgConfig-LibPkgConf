use strict;
use warnings;
use Test::More tests => 1;
use PkgConfig::LibPkgConf::Client;

diag '';
diag '';
diag '';

diag "[pkg-config search path]";
foreach my $dir (PkgConfig::LibPkgConf::Client->new->dirlist)
{
  diag $dir;
}

diag '';
diag '';
diag '';

ok 1;
done_testing;
