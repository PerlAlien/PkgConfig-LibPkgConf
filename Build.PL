use strict;
use warnings;
use Module::Build;

sub try
{
  my($flag, $package) = @_;
  my $flags = `pkgconf $flag $package`;
  return $flags unless $?;
  $flags = `pkg-config $flag $package`;
  return $flags unless $?;
  die "unable to find pkgconf, pkg-config or $package";
}

my $ccflags = try '--cflags', 'libpkgconf';
my $ldflags = try '--libs',   'libpkgconf';

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

