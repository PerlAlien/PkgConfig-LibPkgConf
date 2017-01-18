use strict;
use warnings;

BEGIN {
  unless(eval q{ use 5.008001; 1 })
  {
    print "Sorry!  Perl 5.8.1 or better required\n";
    exit;
  }
}

use ExtUtils::MakeMaker;
use Config;

my $cc = $Config{cc};
my $ld = $Config{ld};
my $alien = 0;
my $alien_ver = '0.05';

sub try
{
  my($name) = @_;

  if(eval q{ use Alien::pkgconf $alien_ver; 1 })
  {
    print "Probe with Alien::pkgconf\n";
    return (Alien::pkgconf->cflags, Alien::pkgconf->libs, Alien::pkgconf->version);
  }
  
  foreach my $cmd (qw( pkgconf pkg-config ppkg-config pkg-config.pl ))
  {
    do {
      no warnings 'exec';
      system $cmd, '--exists', $name;
    };
    if($? == 0)
    {
      my @l = eval {
        my $cflags = `$cmd --cflags $name`;
        die if $?;
        my $libs   = `$cmd --libs   $name`;
        die if $?;
        my $version   = `$cmd --modversion   $name`;
        die if $?;
        chomp $version;
        print "Probe with $cmd\n";
        chomp $cflags;
        chomp $libs;
        ($cflags, $libs, $version);
      };
      return @l unless $@;
    }
  }

  if(eval { require PkgConfig; 1 })
  {
    my $package = PkgConfig->find($name);
    if(!$package->errmsg)
    {
      print "Probe with PkgConfig.pm\n";
      return ($package->get_cflags, $package->get_ldflags, $package->pkg_version);
    }
  }
  
  if(eval { require ExtUtils::PkgConfig; 1 })
  {
    # ick.  EU::PC cannot be required unconditionally
    # because it doesn't install without pkg-config.
    # also it is very unecessarily noisy!
    my %info = eval { ExtUtils::PkgConfig->find($name) };
    if(!$@)
    {
      print "Probe with ExtUtils::PkgConfig\n";
      return ($info{cflags}, $info{libs}, $info{modversion});
    }
  }

  $alien = 1;
  $cc = '$(FULLPERL) script/cc_wrapper.pl';
  $ld = '$(FULLPERL) script/ld_wrapper.pl';
  return ('','');
}

my($ccflags, $ldflags, $version) = try 'libpkgconf';

unless($alien)
{
  $ccflags .= "-DMY_PKGCONF_VERSION=$version";
}

print "($ccflags, $ldflags, $version)\n";

my $lddlflags = $Config{lddlflags};
my $optimize  = $Config{optimize};

# This is not Platypus, but lets honor the debug env
if($ENV{FFI_PLATYPUS_DEBUG})
{
  print "-lddlflags=$lddlflags\n";
  $lddlflags =~ s/-O[0-9]?/-g3/g;
  print "+lddlflags=$lddlflags\n";

  print "-optimize=$optimize\n";
  $optimize =~ s/-O[0-9]?/-g3/g;
  print "+optimize=$optimize\n";
}

if($^O eq 'freebsd' || $^O eq 'dragonfly')
{
  if($lddlflags =~ m{-L/usr/local/lib})
  {
    require Text::ParseWords;
    my %seen;
    foreach my $flag (Text::ParseWords::shellwords($ldflags))
    {
      next if $seen{$flag};
      $seen{$flag}++;
      next unless $flag =~ /^-L/;

      print "-lddlflags=$lddlflags\n";
      $lddlflags =~ s{(-L/usr/local/lib)}{$flag $1}g;
      print "+lddlflags=$lddlflags\n";

    }
  }
}

my %args = (
  ABSTRACT           => 'Perl bindings for libpkgconf',
  AUTHOR             => [ 'Graham Ollis <plicease@cpan.org>' ],
  DISTNAME           => 'PkgConfig-LibPkgConf',
  LICENSE            => 'perl',
  MIN_PERL_VERSION   => '5.008001',
  NAME               => 'PkgConfig::LibPkgConf',
  VERSION_FROM       => 'lib/PkgConfig/LibPkgConf.pm',

  CC                 => $cc,
  LD                 => $ld,

  CCFLAGS            => $ccflags,
  LIBS               => $ldflags,
  LDDLFLAGS          => $lddlflags,
  OPTIMIZE           => $optimize,

  CONFIGURE_REQUIRES => {
    "ExtUtils::MakeMaker" => 0,
  },
  BUILD_REQUIRES     => {
    ($alien ? ('Alien::pkgconf' => $alien_ver) : ()),
  },
  TEST_REQUIRES      => {
    'Test::More' => '0.94',
  },
  PREREQ_PM          => {
    #
  },

  META_MERGE => {
    'meta-spec' => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url  => "http://github.com/plicease/PkgConfig-LibPkgConf.git",
        web  => "http://github.com/plicease/PkgConfig-LibPkgConf",
      },
      bugtracker => {
        web => "http://github.com/plicease/PkgConfig-LibPkgConf/issues",
      },
      homepage => "https://metacpan.org/pod/PkgConfig-LibPkgConf",
      x_MailingList => "https://groups.google.com/forum/#!forum/perl5-alien",
      x_IRC => "irc://irc.perl.org/#native",
    },
    dynamic_config => 1,
  },

  clean => {
    FILES => '*.log *.bak',
  }
);

my %fallback = (
  %{ $args{TEST_REQUIRES} },
  %{ $args{PREREQ_PM} },
);

unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  $args{PREREQ_PM} = \%fallback;
  delete $args{TEST_REQUIRES};
  delete $args{BUILD_REQUIRES};
}

delete $args{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%args);
