use strict;
use warnings;
use Test::More;
use PkgConfig::LibPkgConf::Package;
use PkgConfig::LibPkgConf::Client;

subtest 'dump' => sub {

  my $client = PkgConfig::LibPkgConf::Client->new(
    path => [ 'corpus/lib1' ],
    filter_lib_dirs => [],
    filter_include_dirs => [],
  );

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

  my @libs           = $pkg->list_libs;
  my @cflags         = $pkg->list_cflags;
  my @cflags_private = $pkg->list_cflags_private;
  
  is_deeply [map { ref $_ } @libs], [map { 'PkgConfig::LibPkgConf::Fragment' } 1..2 ];
  is_deeply [map { ref $_ } @cflags], [map { 'PkgConfig::LibPkgConf::Fragment' } 1..2 ];
  is_deeply [map { ref $_ } @cflags_private], ['PkgConfig::LibPkgConf::Fragment'];
  
  is $libs[0]->type, 'L';
  is $libs[0]->data, '/test/lib';
  is $libs[1]->type, 'l';
  is $libs[1]->data, 'foo';
  is $cflags[0]->type, 'f';
  is $cflags[0]->data, 'PIC';
  is $cflags[1]->type, 'I';
  is $cflags[1]->data, '/test/include/foo';
  is $cflags_private[0]->type, 'D';
  is $cflags_private[0]->data, 'FOO_STATIC';

  is_deeply [$pkg->variable('prefix')], ['/test'];
  is_deeply [$pkg->variable('prefixx')], [];
  
};

subtest 'filte sys' => sub {

  my $client = PkgConfig::LibPkgConf::Client->new(
    path => [ 'corpus/lib1' ],
    filter_lib_dirs => [ '/test/lib' ],
    filter_include_dirs => [ '/test/include/foo' ],
  );
  
  my $pkg = $client->find('foo');

  is $pkg->libs,   '-lfoo ', 'libs';  
  is $pkg->cflags, '-fPIC ', 'cflags';

};

done_testing;

