use strict;
use warnings;
use Test::More;
use PkgConfig::LibPkgConf::Package;
use PkgConfig::LibPkgConf::Client;

subtest dump => sub {

  $ENV{PKG_CONFIG_PATH} = 'corpus/lib1';
  my $client = PkgConfig::LibPkgConf::Client->new;

  my $pkg = $client->find('foo');
  
  ok $pkg, "pkg = $pkg";

  note "refcount    = @{[ $pkg->refcount ]}";
  note "id          = @{[ $pkg->id ]}";
  note "filename    = @{[ $pkg->filename ]}";
  note "realname    = @{[ $pkg->realname ]}";
  note "version     = @{[ $pkg->version ]}";
  note "description = @{[ $pkg->description ]}";

  # TODO:
  #note "url         = @{[ $pkg->url ]}";
  #note "pc_filedir  = @{[ $pkg->pc_filedir ]}";

  is $pkg->refcount, 2, 'refcount';
  is $pkg->id, 'foo', 'id';
  is $pkg->filename, 'corpus/lib1/foo.pc', 'filename';
  is $pkg->realname, 'foo', 'realname';
  is $pkg->version, '1.2.3', 'version';
  is $pkg->description, 'A testing pkg-config file', 'description';
};

done_testing;
