use strict;
use warnings;
use Module::Build;

my $ccflags = '';
my $ldflags = '';

# TODO: this is to work around pre-release issues.
#       should be fixed before release to CPAN!
if($ENV{TRAVIS})
{
  $ccflags  = '-I/tmp/pkgconf/include -I/tmp/pkgconf/src';
  $ldflags = '-L/tmp/pkgconf/lib -lpkgconf';
}
else
{
  $ccflags  = '-I/home/ollisg/opt/pkgconf/include -I/home/ollisg/dev/pkgconf';
  $ldflags = '-L/home/ollisg/opt/pkgconf/lib -lpkgconf';
}

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

$builder->create_build_script;
