use strict;
use warnings;
use utf8;
use Test::More;
use Test::Spelling;

add_stopwords(<DATA>);
all_pod_files_spelling_ok;

__DATA__
Ollis
awilfox
libpkgconf
pc
