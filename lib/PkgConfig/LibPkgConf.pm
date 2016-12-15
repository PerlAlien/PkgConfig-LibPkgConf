package PkgConfig::LibPkgConf;

use strict;
use warnings;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('PkgConfig::LibPkgConf', $VERSION);

1;

=head1 NAME

PkgConfig::LibPkgConf - Interface to .pc file interface via libpkgconf

=head1 SYNOPSIS

 use PkgConfig::LibPkgConf;

=head1 DESCRIPTION

Many libraries in compiled languages such as C or C++ provide C<.pc> 
files to specify the flags required for compiling and linking against 
those libraries.  Traditionally, the command line program C<pkg-config> 
is used to query these files.  This module provides a Perl level API
using C<libpkgconf> to these files.

=head1 SUPPORT

IRC #native on irc.perl.org

Project GitHub tracker:

L<https://github.com/plicease/PkgConfig-LibPkgConf/issues>

If you want to contribute, please open a pull request on GitHub:

L<https://github.com/plicease/PkgConfig-LibPkgConf/pulls>

=head1 SEE ALSO

The best entry point to the low level C<pkgconf> interface can be found 
via L<PkgConfig::LibPkgConf::Client>.

Alternatives include:

=over 4

=item L<PkgConfig>

Pure Perl implementation of C<pkg-config> which can be used from the 
command line, or as an API from Perl.  Does not require pkg-config in 
your path, so is a safe dependency for CPAN modules.

=item L<ExtUtils::PkgConfig>

Wrapper for the C<pkg-config> command line interface.  This module will 
fail to install if C<pkg-config> cannot be found in the C<PATH>, so it 
is not safe to use a dependency if you want your CPAN module to work on 
platforms where C<pkg-config> is not installed.

=item L<Alien::Base>

Provides tools for building non-Perl libraries and making them 
dependencies for your CPAN modules, even on platforms where the non-Perl 
libraries aren't already installed.  Includes hooks for probing 
C<pkg-config> C<.pc> files using either C<pkg-config> or L<PkgConfig>.

=back

=head1 ACKNOWLEDGMENTS

Thanks to the C<pkgconf> developers for their efforts:

L<https://github.com/pkgconf/pkgconf/graphs/contributors>

=head1 AUTHOR

Graham Ollis 

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 Graham Ollis.

This is free software; you may redistribute it and/or modify it under 
the same terms as the Perl 5 programming language system itself.

=cut
