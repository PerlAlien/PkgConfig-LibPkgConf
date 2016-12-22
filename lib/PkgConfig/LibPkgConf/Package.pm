package PkgConfig::LibPkgConf::Package;

use strict;
use warnings;
use PkgConfig::LibPkgConf::XS;

our $VERSION = '0.01';

=head1 NAME

PkgConfig::LibPkgConf::Package - Represents a package

=head1 SYNOPSIS

 use PkgConfig::LibPkgConf::Client;
 
 my $client = PkgConfig::LibPkgConf::Client->new;
 $client->env;
 
 my $pkg = $client->find('libarchive');
 my $cflags = $pkg->cflags;
 my $libs = $pkg->libs;

=head1 DESCRIPTION

The L<PkgConfig::LibPkgConf::Package> object stores package information.

=head1 ATTRIBUTES

=head2 refcount

Internal reference count used by C<pkgconf>.

=head2 id

The id of the package.

=head2 filename

The filename of the C<.pc> file.

=head2 realname

The real name for the package.

=head2 version

The version of the package.

=head2 description

Description of the package.

=head2 url

URL for the package.

=head2 pc_filedir

TODO

=head2 libs

Library flags.  This usually includes things like C<-L/foo/lib> and C<-lfoo>.

=cut

sub libs
{
  my($self) = @_;
  $self->_libs($self->{client});
}

=head2 libs_private

Private library flags.

=cut

sub libs_private
{
  my($self) = @_;
  $self->_libs_private($self->{client});
}

=head2 cflags

Compiler flags.  This usually includes things like C<-I/foo/include> and C<-DFOO=1>.

=cut

sub cflags
{
  my($self) = @_;
  $self->_cflags($self->{client});
}

=head2 cflags_private

Private compiler flags.

=cut

sub cflags_private
{
  my($self) = @_;
  $self->_cflags_private($self->{client});
}

=head1 SUPPORT

IRC #native on irc.perl.org

Project GitHub tracker:

L<https://github.com/plicease/PkgConfig-LibPkgConf/issues>

If you want to contribute, please open a pull request on GitHub:

L<https://github.com/plicease/PkgConfig-LibPkgConf/pulls>

=head1 SEE ALSO

For additional related modules, see L<PkgConfig::LibPkgConf>

=head1 AUTHOR

Graham Ollis

For additional contributors see L<PkgConfig::LibPkgConf>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 Graham Ollis.

This is free software; you may redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
 
1;
