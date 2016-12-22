use strict;
use warnings;
use Test::More;
use File::Temp ();
use PkgConfig::LibPkgConf::Client;

subtest 'basic create and destroy' => sub {

  my $client = PkgConfig::LibPkgConf::Client->new;
  isa_ok $client, 'PkgConfig::LibPkgConf::Client';

  my $sysroot = $client->sysroot_dir;
  $sysroot = 'undef' unless defined $sysroot;

  note "sysroot = $sysroot";

  my $buildroot = $client->buildroot_dir;
  $buildroot = 'undef' unless defined $buildroot;
  
  note "buildroot = $buildroot";

  if(eval { require YAML; 1 })
  {
    note YAML::Dump("$client", $client);
  }
  
  undef $client;
  
  ok 1, 'did not crash on undef';

};

subtest 'set sysroot' => sub {

  my $client = PkgConfig::LibPkgConf::Client->new;
  
  my $dir = File::Temp::tempdir( CLEANUP => 1 );
  
  is $client->sysroot_dir($dir), $dir;
  is $client->sysroot_dir, $dir;
  
};

subtest 'set buildroot' => sub {

  my $client = PkgConfig::LibPkgConf::Client->new;
  
  my $dir = File::Temp::tempdir( CLEANUP => 1 );
  
  is $client->buildroot_dir($dir), $dir;
  is $client->buildroot_dir, $dir;
  
};

subtest 'subclass client' => sub {

  {
    package
      MyClient;
    
    use base qw( PkgConfig::LibPkgConf::Client );
  }

  my $client = MyClient->new;
  
  isa_ok $client, 'MyClient';
  isa_ok $client, 'PkgConfig::LibPkgConf::Client';

  undef $client;
  
  ok 1, 'did not crash on undef';
};

subtest 'find' => sub {

  my $client = PkgConfig::LibPkgConf::Client->new( path => 'corpus/lib1' );

  is( $client->find('completely-bogus-non-existent'), undef);
  
  isa_ok( $client->find('foo'), 'PkgConfig::LibPkgConf::Package' );

};

subtest 'error' => sub {

  plan tests => 2;

  use PkgConfig::LibPkgConf::Test qw( send_error );

  no warnings 'redefine';
  local *PkgConfig::LibPkgConf::Client::error = sub {
    my($self, $msg) = @_;
    isa_ok $self, 'PkgConfig::LibPkgConf::Client';
    is $msg, 'this is an error sent';
  };
  
  my $client = PkgConfig::LibPkgConf::Client->new;
  eval { send_error($client, "this is an error sent") };
  note "exception: $@" if $@;

};

subtest 'error in subclass' => sub {

  plan tests => 3;
  
  use PkgConfig::LibPkgConf::Test qw( send_error );

  {
    package
      MyClient2;
    
    use base qw( PkgConfig::LibPkgConf::Client );
    
    sub error {
      my($self, $msg) = @_;
      Test::More::isa_ok $self, 'PkgConfig::LibPkgConf::Client';
      Test::More::isa_ok $self, 'MyClient2';
      Test::More::is $msg, 'this is an error sent2';
      
    }
  }

  my $client = MyClient2->new;
  eval { send_error($client, "this is an error sent2") };
  note "exception: $@" if $@;

};

subtest 'audit log' => sub {

  use PkgConfig::LibPkgConf::Test qw( send_log );

  my $client = PkgConfig::LibPkgConf::Client->new;
  $client->audit_set_log("test.log", "w");
  
  send_log $client, "line1\n";
  send_log $client, "line2\n";
  
  undef $client;

  open my $fh, '<', 'test.log';
  my $data = do { local $/; <$fh> };
  close $fh;
  
  note "[data]$data\n";
  ok $data;
  
};

subtest 'scan all' => sub {

  my $client = PkgConfig::LibPkgConf::Client->new( path => 'corpus/lib1' );
  
  # er.  Just make sure.
  is_deeply [$client->path], [qw( corpus/lib1 )] if $client->can('path');
  
  my %p;
  
  $client->scan_all(sub {
    my($client, $package) = @_;
    $p{$package->id}++;
    0;
  });

  is_deeply \%p, { foo => 1, foo1 => 1, foo1a => 1 };

};

subtest 'path attributes' => sub {

  my $sep = PkgConfig::LibPkgConf::Client->path_sep;

  subtest 'search path' => sub {
  
    local $ENV{PKG_CONFIG_PATH} = join $sep, '/foo', '/bar';
    local $ENV{PKG_CONFIG_LIBDIR} = join $sep, '/baz', '/ralph';

    is_deeply 
      [PkgConfig::LibPkgConf::Client->new->path], 
      [qw( /foo /bar /baz /ralph )];
    is_deeply
      [PkgConfig::LibPkgConf::Client->new(path => join($sep, qw( /trans /formers )))->path], 
      [qw( /trans /formers )];
    is_deeply
      [PkgConfig::LibPkgConf::Client->new(path => [qw( /trans /formers )])->path], 
      [qw( /trans /formers )];
  
  };
  
  subtest 'filter lib dirs' => sub {

    local $ENV{PKG_CONFIG_SYSTEM_LIBRARY_PATH} = join $sep, '/foo/lib', '/bar/lib';

    is_deeply
      [PkgConfig::LibPkgConf::Client->new->filter_lib_dirs],
      [qw( /foo/lib /bar/lib )];
    is_deeply
      [PkgConfig::LibPkgConf::Client->new(filter_lib_dirs => [qw( /trans/lib /formers/lib )])->filter_lib_dirs], 
      [qw( /trans/lib /formers/lib )];

  };

  subtest 'filter include dirs' => sub {

    local $ENV{PKG_CONFIG_SYSTEM_INCLUDE_PATH} = join $sep, '/foo/include', '/bar/include';

    is_deeply
      [PkgConfig::LibPkgConf::Client->new->filter_include_dirs],
      [qw( /foo/include /bar/include )];
    is_deeply
      [PkgConfig::LibPkgConf::Client->new(filter_include_dirs => [qw( /trans/include /formers/include )])->filter_include_dirs], 
      [qw( /trans/include /formers/include )];

  };

};

done_testing;
