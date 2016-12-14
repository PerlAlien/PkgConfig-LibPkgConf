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

  $ENV{PKG_CONFIG_PATH} = 'corpus/lib1';
  my $client = PkgConfig::LibPkgConf::Client->new;

  is( $client->find('completely-bogus-non-existent'), undef);
  
  isa_ok( $client->find('foo'), 'PkgConfig::LibPkgConf::Package' );

};

subtest 'error' => sub {

  plan skip_all => 'borked';

  use PkgConfig::LibPkgConf::Test qw( send_error );
  
  my $client = PkgConfig::LibPkgConf::Client->new;
  send_error($client, "this is an error sent");

  ok 1;
};

done_testing;
