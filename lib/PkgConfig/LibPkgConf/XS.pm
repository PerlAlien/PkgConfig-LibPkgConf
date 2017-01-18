package PkgConfig::LibPkgConf::XS;

use strict;
use warnings;

our $VERSION = '0.03';

require XSLoader;
XSLoader::load('PkgConfig::LibPkgConf', $VERSION);

$PkgConfig::LibPkgConf::impl = 
$PkgConfig::LibPkgConf::impl = 'XS';

1;
