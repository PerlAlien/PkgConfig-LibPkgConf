#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <libpkgconf/libpkgconf.h>

struct my_client_t {
  pkgconf_client_t client;
  FILE *auditf;
  unsigned int flags;
  SV *error_handler;
};

typedef struct my_client_t my_client_t;

static bool
my_error_handler(const char *msg, const pkgconf_client_t *_, const void *data)
{
  dSP;

  int count;
  bool value;
  const my_client_t *client = (const my_client_t*)data;
    
  ENTER;
  SAVETMPS;
  
  PUSHMARK(SP);
  EXTEND(SP, 1);
  PUSHs(sv_2mortal(newSVpv(msg, 0)));
  PUTBACK;
  
  count = call_sv(client->error_handler, G_SCALAR);
  
  SPAGAIN;
  
  value = count > 0 && POPi;
  
  PUTBACK;
  FREETMPS;
  LEAVE;

  return value;
}

static bool
my_pkg_iterator(const pkgconf_pkg_t *pkg, void *data)
{
  dSP;
  
  int count;
  bool value;
  SV *callback = (SV*)data;
  
  ENTER;
  SAVETMPS;
  
  PUSHMARK(SP);
  EXTEND(SP,1);
  PUSHs(sv_2mortal(newSViv(PTR2IV(pkg))));
  PUTBACK;
  
  count = call_sv(callback, G_SCALAR);
  
  SPAGAIN;
  
  value = count > 0 && POPi;
  
  PUTBACK;
  FREETMPS;
  LEAVE;
  
  return value;
}

static bool
directory_filter(const pkgconf_client_t *client, const pkgconf_fragment_t *frag, unsigned int flags)
{
  if(pkgconf_fragment_has_system_dir(client, frag))
    return false;
  return true;
}

static pkgconf_list_t *
which_list(pkgconf_pkg_t *package, int type)
{
  switch(type)
  {
    case 0: return &package->libs;
    case 1: return &package->libs_private;
    case 2: return &package->cflags;
    case 3: return &package->cflags_private;
    default: croak("invalid type: %d", type);
  }
}

MODULE = PkgConfig::LibPkgConf  PACKAGE = PkgConfig::LibPkgConf::Client


void
_init(object, args, error_handler)
    SV *object
    SV *args
    SV *error_handler;
  INIT:
    my_client_t *self;
  CODE:
    Newxz(self, 1, my_client_t);
    self->auditf = NULL;
    self->flags  = PKGCONF_PKG_PKGF_NONE;
    self->error_handler = SvREFCNT_inc(error_handler);
    pkgconf_client_init(&self->client, my_error_handler, self);
    hv_store((HV*)SvRV(object), "ptr", 3, newSViv(PTR2IV(self)), 0);


void
audit_set_log(self, filename, mode)
    my_client_t *self
    const char *filename
    const char *mode
  CODE:
    if(self->auditf != NULL)
    {
      fclose(self->auditf);
      self->auditf = NULL;
    }
    self->auditf = fopen(filename, mode);
    if(self->auditf != NULL)
    {
      pkgconf_audit_set_log(&self->client, self->auditf);
    }
    else
    {
      /* TODO: call error ? */
    }


const char *
sysroot_dir(self, ...)
    my_client_t *self
  CODE:
    if(items > 1)
    {
      pkgconf_client_set_sysroot_dir(&self->client, SvPV_nolen(ST(1)));
    }
    RETVAL = pkgconf_client_get_sysroot_dir(&self->client);
  OUTPUT:
    RETVAL


const char *
buildroot_dir(self, ...)
    my_client_t *self
  CODE:
    if(items > 1)
    {
      pkgconf_client_set_buildroot_dir(&self->client, SvPV_nolen(ST(1)));
    }
    RETVAL = pkgconf_client_get_buildroot_dir(&self->client);
  OUTPUT:
    RETVAL


void
path(self)
    my_client_t *self
  INIT:
    pkgconf_node_t *n;
    pkgconf_pkg_t *pkg;
    pkgconf_path_t *pnode;
    int count = 0;
  CODE:
    PKGCONF_FOREACH_LIST_ENTRY(self->client.dir_list.head, n)
    {
      pnode = n->data;
      ST(count++) = sv_2mortal(newSVpv(pnode->path, 0));
    }
    XSRETURN(count);


void
filter_lib_dirs(self)
    my_client_t *self
  INIT:
    pkgconf_node_t *n;
    pkgconf_pkg_t *pkg;
    pkgconf_path_t *pnode;
    int count = 0;
  CODE:
    PKGCONF_FOREACH_LIST_ENTRY(self->client.filter_libdirs.head, n)
    {
      pnode = n->data;
      ST(count++) = sv_2mortal(newSVpv(pnode->path, 0));
    }
    XSRETURN(count);    


void
filter_include_dirs(self)
    my_client_t *self
  INIT:
    pkgconf_node_t *n;
    pkgconf_pkg_t *pkg;
    pkgconf_path_t *pnode;
    int count = 0;
  CODE:
    PKGCONF_FOREACH_LIST_ENTRY(self->client.filter_includedirs.head, n)
    {
      pnode = n->data;
      ST(count++) = sv_2mortal(newSVpv(pnode->path, 0));
    }
    XSRETURN(count);    


char *
path_sep(class)
    SV *class
  CODE:
    RETVAL = PKG_CONFIG_PATH_SEP_S;
  OUTPUT:
    RETVAL

void
DESTROY(self)
    my_client_t *self;
  CODE:
    if(self->auditf != NULL)
    {
      fclose(self->auditf);
      self->auditf = NULL;
    }
    pkgconf_client_deinit(&self->client);
    SvREFCNT_dec(self->error_handler);
    Safefree(self);

IV
_find(self, name)
    my_client_t *self
    const char *name
  CODE:
    RETVAL = PTR2IV(pkgconf_pkg_find(&self->client, name, self->flags));
  OUTPUT:
    RETVAL


void
_scan_all(self, sub)
    my_client_t *self
    SV* sub
  CODE:
    pkgconf_scan_all(&self->client, sub, my_pkg_iterator);
        

void
_dir_list_build(self, env_only)
    my_client_t *self
    int env_only
  CODE:
    pkgconf_pkg_dir_list_build(&self->client, env_only ? PKGCONF_PKG_PKGF_ENV_ONLY : PKGCONF_PKG_PKGF_NONE);

MODULE = PkgConfig::LibPkgConf  PACKAGE = PkgConfig::LibPkgConf::Package

int
refcount(self)
    pkgconf_pkg_t* self
  CODE:
    RETVAL = self->refcount;
  OUTPUT:
    RETVAL


const char *
id(self)
    pkgconf_pkg_t* self
  CODE:
    RETVAL = self->id;
  OUTPUT:
    RETVAL


const char *
filename(self)
    pkgconf_pkg_t* self
  CODE:
    RETVAL = self->filename;
  OUTPUT:
    RETVAL


const char *
realname(self)
    pkgconf_pkg_t* self
  CODE:
    RETVAL = self->realname;
  OUTPUT:
    RETVAL


const char *
version(self)
    pkgconf_pkg_t* self
  CODE:
    RETVAL = self->version;
  OUTPUT:
    RETVAL


const char *
description(self)
    pkgconf_pkg_t* self
  CODE:
    RETVAL = self->description;
  OUTPUT:
    RETVAL


const char *
url(self)
    pkgconf_pkg_t* self
  CODE:
    RETVAL = self->url;
  OUTPUT:
    RETVAL


const char *
pc_filedir(self)
    pkgconf_pkg_t* self
  CODE:
    RETVAL = self->pc_filedir;
  OUTPUT:
    RETVAL


SV *
_get_string(self, client, type)
    pkgconf_pkg_t *self
    my_client_t *client
    int type
  INIT:
    pkgconf_list_t *list;
    pkgconf_list_t filtered_list = PKGCONF_LIST_INITIALIZER;
    size_t len;
  CODE:
    list = which_list(self, type); 
    pkgconf_fragment_filter(&client->client, &filtered_list, list, directory_filter, client->flags);
    len = pkgconf_fragment_render_len(&filtered_list);
    RETVAL = newSV(len == 1 ? len : len-1);
    SvPOK_on(RETVAL);
    SvCUR_set(RETVAL, len-1);
    pkgconf_fragment_render_buf(&filtered_list, SvPVX(RETVAL), len);
    pkgconf_fragment_free(&filtered_list);
  OUTPUT:
    RETVAL


void
_get_list(self, client, type)
    pkgconf_pkg_t *self
    my_client_t *client
    int type
  INIT:
    pkgconf_list_t *list;
    pkgconf_list_t filtered_list = PKGCONF_LIST_INITIALIZER;
    pkgconf_node_t *node;
    pkgconf_fragment_t *frag;
    int count = 0;
    HV *h;
  CODE:
    list = which_list(self, type); 
    pkgconf_fragment_filter(&client->client, &filtered_list, list, directory_filter, client->flags);
    PKGCONF_FOREACH_LIST_ENTRY(filtered_list.head, node)
    {
      h = newHV();
      frag = node->data;
      if(frag->type)
        hv_store(h, "type", 4, newSVpvf("%c", frag->type), 0);
      else
        hv_store(h, "type",  4, newSVsv(&PL_sv_undef), 0);
      if(frag->data)
        hv_store(h, "data", 4, newSVpv(frag->data, strlen(frag->data)), 0);
      else
        hv_store(h, "data",  4, newSVsv(&PL_sv_undef), 0);
      ST(count++) = newRV_noinc((SV*) h);
    }
    pkgconf_fragment_free(&filtered_list);
    XSRETURN(count);
    

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
    RETVAL = pkgconf_compare_version(a,b);
  OUTPUT:
    RETVAL


MODULE = PkgConfig::LibPkgConf  PACKAGE = PkgConfig::LibPkgConf::Test


IV
send_error(client, msg)
    my_client_t *client
    const char *msg
  CODE:
    RETVAL = pkgconf_error(&client->client, "%s", msg);
  OUTPUT:
    RETVAL
  

void
send_log(client, msg)
    my_client_t *client
    const char *msg
  CODE:
    pkgconf_audit_log(&client->client, "%s", msg);

