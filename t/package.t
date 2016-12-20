use strict;
use warnings;
use Test::More;
use PkgConfig::LibPkgConf::Package;
use PkgConfig::LibPkgConf::Client;

subtest dump => sub {

  my $client = PkgConfig::LibPkgConf::Client->new( path => 'corpus/lib1' );

  my $pkg = $client->find('foo');
  
  ok $pkg, "pkg = $pkg";

  note "refcount       = @{[ $pkg->refcount ]}";
  note "id             = @{[ $pkg->id ]}";
  note "filename       = @{[ $pkg->filename ]}";
  note "realname       = @{[ $pkg->realname ]}";
  note "version        = @{[ $pkg->version ]}";
  note "description    = @{[ $pkg->description ]}";
  note "libs           = @{[ $pkg->libs ]}";
  note "libs_private   = @{[ $pkg->libs_private ]}";
  note "cflags         = @{[ $pkg->cflags ]}";
  note "cflags_private = @{[ $pkg->cflags_private ]}";

  # TODO:
  #note "url         = @{[ $pkg->url ]}";
  #note "pc_filedir  = @{[ $pkg->pc_filedir ]}";

  is $pkg->refcount, 2, 'refcount';
  is $pkg->id, 'foo', 'id';
  is $pkg->filename, 'corpus/lib1/foo.pc', 'filename';
  is $pkg->realname, 'foo', 'realname';
  is $pkg->version, '1.2.3', 'version';
  is $pkg->description, 'A testing pkg-config file', 'description';

  is $pkg->libs, '-L/test/lib -lfoo ', 'libs';
  is $pkg->cflags, '-fPIC -I/test/include/foo ', 'cflags';
  is $pkg->cflags_private, '-DFOO_STATIC ', 'cflags_private';
  
};

done_testing;

