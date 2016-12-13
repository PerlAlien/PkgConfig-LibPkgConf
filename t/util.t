use strict;
use warnings;
use Test::More;
use PkgConfig::LibPkgConf::Util qw( argv_split );

subtest 'argv_split' => sub {

 is_deeply [argv_split("foo bar baz")], [qw( foo bar baz )];

};

done_testing;
