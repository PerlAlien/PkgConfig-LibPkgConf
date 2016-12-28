use strict;
use warnings;
use Test::More;
use PkgConfig::LibPkgConf::Util qw( argv_split compare_version path_sep );

subtest 'argv_split' => sub {

 is_deeply [argv_split("foo bar baz")], [qw( foo bar baz )];

};

subtest 'compare_version' => sub {

  is compare_version('1.2.3', '1.2.3'), 0;
  isnt compare_version('1.2.3', '1.2.4'), 0;

};

subtest 'path_sep' => sub {

  like path_sep(), qr{^[;:]$};

};

done_testing;
