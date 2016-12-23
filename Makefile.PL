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

sub try
{
  my($name) = @_;

  foreach my $cmd (qw( pkgconf pkg-config ppkg-config pkg-config.pl ))
  {
    do {
      no warnings 'exec';
      system $cmd, '--exists', $name;
    };
    if($? == 0)
    {
      return eval {
        my $cflags = `$cmd --cflags $name`;
        die if $?;
        my $libs   = `$cmd --libs   $name`;
        die if $?;
        print "Probe with $cmd\n";
        chomp $cflags;
        chomp $libs;
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
  
  if(eval { require ExtUtils::PkgConfig; 1 })
  {
    # ick.  EU::PC cannot be required unconditionally
    # because it doesn't install without pkg-config.
    # also it is very unecessarily noisy!
    my %info = eval { ExtUtils::PkgConfig->find($name) };
    if(!$@)
    {
      print "Probe with ExtUtils::PkgConfig\n";
      return ($info{cflags}, $info{libs});
    }
  }
    
  print STDERR "unable to find pkgconf, pkg-config, PkgConfig.pm, ExtUtils::PkgConfig or $name\n";
  exit;
}

my($ccflags, $ldflags) = try 'libpkgconf';
print "($ccflags, $ldflags)\n";

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

my %args = (
  ABSTRACT           => 'Perl bindings for libpkgconf',
  AUTHOR             => [ 'Graham Ollis <plicease@cpan.org>' ],
  DISTNAME           => 'PkgConfig-LibPkgConf',
  LICENSE            => 'perl',
  MIN_PERL_VERSION   => '5.008001',
  NAME               => 'PkgConfig::LibPkgConf',
  VERSION_FROM       => 'lib/PkgConfig/LibPkgConf.pm',

  CCFLAGS            => $ccflags,
  LIBS               => $ldflags,
  LDDLFLAGS          => $lddlflags,
  OPTIMIZE           => $optimize,

  CONFIGURE_REQUIRES => {
    "ExtUtils::MakeMaker" => 0,
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
      repository => "http://github.com/plicease/PkgConfig-LibPkgConf",
      bugtracker => "http://github.com/plicease/PkgConfig-LibPkgConf/issues",
      x_MailingList => "https://groups.google.com/forum/#!forum/perl5-alien",
      x_IRC => "irc://irc.perl.org/#native",
    },
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
