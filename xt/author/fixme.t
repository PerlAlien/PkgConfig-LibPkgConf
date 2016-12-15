use strict;
use warnings;
use Test::Fixme 0.14;
use Test::More;

run_tests(
  match => qr/(FIXME|TODO)/,
  where => [ qw( lib t Build.PL ) ],
  warn  => 1,
);
