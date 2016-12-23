use strict;
use warnings;
use Module::Build;
use Config;

sub try
{
  my($name) = @_;

  foreach my $cmd (qw( pkgconf pkg-config ))
  {
    system $cmd, '--exists', $name;
    if($? == 0)
    {
      return eval {
        my $cflags = `$cmd --cflags $name`;
        die if $?;
        my $libs   = `$cmd --libs   $name`;
        die if $?;
        print "Probe with $cmd\n";
        ($cflags, $libs);
      }
    }
  }

  if(eval { require PkgConfig; 1 })
  {
    my $package = PkgConfig->find($name);
    if(!$package->errmsg)
    {
      my $cflags = $package->get_cflags;
      my $libs   = $package->get_ldflags;
      print "Probe with PkgConfig.pm\n";
      return ($cflags, $libs);
    }
  }

  die "unable to find pkgconf, pkg-config, PkgConfig.pm or $name";
}

my($ccflags, $ldflags) = try 'libpkgconf';

my $builder = Module::Build->new(
  module_name        => 'PkgConfig::LibPkgConf',
  dist_abstract      => 'Perl bindings for libpkgconf',
  dist_author        => [ 'Graham Ollis <plicease@cpan.org>' ],
  license            => 'perl',
  configure_requires => {
    'Module::Build' => '0.38',
  },
  test_requires => {
    'Test::More' => '0.94',
  },
  build_requires => {},
  requires => {
    'perl' => '5.008001',
  },
  extra_compiler_flags => $ccflags,
  extra_linker_flags   => $ldflags,
  meta_merge => {
    resources => {
      repository => "http://github.com/plicease/PkgConfig-LibPkgConf",
      bugtracker => "http://github.com/plicease/PkgConfig-LibPkgConf/issues",
      x_MailingList => "https://groups.google.com/forum/#!forum/perl5-alien",
      x_IRC => "irc://irc.perl.org/#native",
    },
  },
);

# This is not Platypus, but lets honor the debug env
if($ENV{FFI_PLATYPUS_DEBUG})
{
  my $config = $builder->config;
  foreach my $key (keys %Config)
  {
    my $value = $Config{$key};
    next unless defined $value;
    if($value =~ s/-O[0-9]?/-g3/g)
    {
      $builder->config($key, $value);
      print "-$key = @{[ $config->{$key} ]}\n";
      print "+$key = $value\n";
    }
  }
}

$builder->add_to_cleanup( '*.log' );
$builder->add_to_cleanup( '*.bak' );
$builder->create_build_script;


