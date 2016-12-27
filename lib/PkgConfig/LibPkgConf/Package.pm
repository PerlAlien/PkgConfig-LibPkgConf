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

=head1 METHODS

=head2 libs

Library flags.  This usually includes things like C<-L/foo/lib> and C<-lfoo>.

=cut

sub libs
{
  my($self) = @_;
  $self->_get_string($self->{client}, 0);
}

=head2 libs_private

Private library flags.

=cut

sub libs_private
{
  my($self) = @_;
  $self->_get_string($self->{client}, 1);
}

=head2 cflags

Compiler flags.  This usually includes things like C<-I/foo/include> and C<-DFOO=1>.

=cut

sub cflags
{
  my($self) = @_;
  $self->_get_string($self->{client}, 2);
}

=head2 cflags_private

Private compiler flags.

=cut

sub cflags_private
{
  my($self) = @_;
  $self->_get_string($self->{client}, 3);
}

=head2 list_libs

 my @fragments = $package->list_libs;

Library flags as a list of fragments L<PkgConfig::LibPkgConf::Fragment>.  This is similar
to the C<libs> method above, but since it returns a list instead of a single string, it can
be used to filter for specific flags.  For example:

 # equivalent to pkgconf --libs-only-L
 my @lib_dirs = grep { $_->type eq 'L' } $package->list_libs;
 # equivalent to pkgconf --libs-only-l
 my @libs = grep { $_->type eq 'l' } $package->list_libs;

=cut

sub list_libs
{
  my($self) = @_;
  require PkgConfig::LibPkgConf::Fragment;
  map { bless $_, 'PkgConfig::LibPkgConf::Fragment' } $self->_get_list($self->{client}, 0);
}

=head2 list_libs_private

 my @fragments = $package->list_libs_private;

Similar to C<list_libs>, but for the private libs flags.

=cut

sub list_libs_private
{
  my($self) = @_;
  require PkgConfig::LibPkgConf::Fragment;
  map { bless $_, 'PkgConfig::LibPkgConf::Fragment' } $self->_get_list($self->{client}, 1);
}

=head2 list_cflags

 my @fragments = $package->list_cflags;

Compiler flags as a list of fragments L<PkgConfig::LibPkgConf::Fragment>.  This is similar
to the C<cflags> method above, but since it returns a list instead of a single string, it
can be used to filter for specific flags.  For example:

 # equivalent to pkgconf --cflags-only-I
 my @include_dirs = grep { $_->type eq 'I' } $package->list_cflags;
 # equivalent to pkgconf --cflags-only-other
 my @other_cflags = grep { $_->type ne 'I' } $package->list_cflags;

=cut

sub list_cflags
{
  my($self) = @_;
  require PkgConfig::LibPkgConf::Fragment;
  map { bless $_, 'PkgConfig::LibPkgConf::Fragment' } $self->_get_list($self->{client}, 2);
}

=head2 list_cflags_private

 my @fragments = $package->list_cflags_private;

Similar to C<list_cflags>, but for the private compiler flags.

=cut

sub list_cflags_private
{
  my($self) = @_;
  require PkgConfig::LibPkgConf::Fragment;
  map { bless $_, 'PkgConfig::LibPkgConf::Fragment' } $self->_get_list($self->{client}, 3);
}

=head2 variable

 my $value = $package->variable($key);

Look up the value for the given variable.  Returns the value if found,
otherwise it will return undef (technically empty list).

=cut

sub variable
{
  my($self, $name) = @_;
  $self->_get_variable($self->{client}, $name);
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
