#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <pkgconf/libpkgconf.h>

MODULE = PkgConfig::LibPkgConf  PACKAGE = PkgConfig::LibPkgConf::Client

pkgconf_client_t*
new(class)
    const char *class
  CODE:
    RETVAL = pkgconf_client_new(NULL);
  OUTPUT:
    RETVAL


const char *
sysroot_dir(self, ...)
    pkgconf_client_t *self
  CODE:
    if(items > 1)
    {
      pkgconf_client_set_sysroot_dir(self, SvPV_nolen(ST(1)));
    }
    RETVAL = pkgconf_client_get_sysroot_dir(self);
  OUTPUT:
    RETVAL


const char *
buildroot_dir(self, ...)
    pkgconf_client_t *self
  CODE:
    if(items > 1)
    {
      pkgconf_client_set_buildroot_dir(self, SvPV_nolen(ST(1)));
    }
    RETVAL = pkgconf_client_get_buildroot_dir(self);
  OUTPUT:
    RETVAL


void
DESTROY(self)
    pkgconf_client_t *self
  CODE:
    pkgconf_client_free(self);
    
