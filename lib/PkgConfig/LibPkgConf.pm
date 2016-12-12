package PkgConfig::LibPkgConf;

use strict;
use warnings;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

require XSLoader;
XSLoader::load('PkgConfig::LibPkgConf', $VERSION);

1;
