#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <pkgconf/libpkgconf.h>

MODULE = PkgConfig::LibPkgConf  PACKAGE = PkgConfig::LibPkgConf::Client

IV
_new()
  CODE:
    RETVAL = PTR2IV(pkgconf_client_new(NULL));
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


IV
_find(self, name, flags)
    pkgconf_client_t *self
    const char *name
    unsigned int flags
  CODE:
    RETVAL = PTR2IV(pkgconf_pkg_find(self, name, flags));
  OUTPUT:
    RETVAL
    

MODULE = PkgConfig::LibPkgConf  PACKAGE = PkgConfig::LibPkgConf::Util

void
argv_split(src)
    const char *src
  INIT:
    int argc, ret, i;
    char **argv;
  PPCODE:
    ret = pkgconf_argv_split(src, &argc, &argv);
    if(ret == 0)
    {
      for(i=0; i<argc; i++)
      {
        XPUSHs(sv_2mortal(newSVpv(argv[i],0)));
      }
      pkgconf_argv_free(argv);
    }
    else
    {
      croak("error in argv_split");
    }


int
compare_version(a,b)
    const char *a
    const char *b
  CODE:
    /* TODO: this isn't documented yet, so make sure   **
    **       that it is really part of the API before  **
    **       exposing it.                              **/
    RETVAL = pkgconf_compare_version(a,b);
  OUTPUT:
    RETVAL
