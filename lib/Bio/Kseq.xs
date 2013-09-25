#ifdef PERL_CAPI
#define WIN32IO_IS_STDIO
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef USE_SFIO
  #include <config.h>
#else
  #include <stdio.h>
#endif
#include <perlio.h>

#include "ppport.h"

#include <zlib.h>
#include "kseq.h"

/* TODO: rework in terms of kseq_t, kstream_t and kstring_t struct interfaces, these are very likely source of mem leaks */

/* TODO: define error checking, and clean up possible stdio/PerlIO issues */

KSEQ_INIT(gzFile, gzread)

typedef gzFile          Bio__Kseq__Fh;
typedef kseq_t*         Bio__Kseq__Iterator;
typedef kstream_t*      Bio__Kseq__Kstream;
typedef kstring_t*      Bio__Kseq__Kstring;

MODULE = Bio::Kseq PACKAGE = Bio::Kseq  PREFIX=kseq_

Bio::Kseq::Fh
kseq_new(pack, filename, mode="r")
    char *pack
    char *filename
    char *mode
    PROTOTYPE: $$$
    CODE:
        RETVAL = gzopen(filename, mode);
    OUTPUT:
        RETVAL

Bio::Kseq::Fh
kseq_newfh(pack, fh, mode="r")
    char *pack
    PerlIO* fh
    char *mode
    PROTOTYPE: $$$
    CODE:
        RETVAL = gzdopen(PerlIO_fileno(fh), mode);
    OUTPUT:
        RETVAL

MODULE = Bio::Kseq PACKAGE = Bio::Kseq::Fh  PREFIX=file_

Bio::Kseq::Iterator
file_iterator(fp)
    Bio::Kseq::Fh fp
    PROTOTYPE: $
    CODE:
        RETVAL = kseq_init(fp);
    OUTPUT:
        RETVAL

void
file_DESTROY(fp)
    Bio::Kseq::Fh fp
    PROTOTYPE: $
    CODE:
        gzclose(fp);

#MODULE = Bio::Kseq PACKAGE = Bio::Kseq::Kstring   PREFIX=kstr_
#
#size_t
#kstr_l(kstr)
#    Bio::Kseq::Kstring kstr
#    PROTOTYPE: $
#    CODE:
#        RETVAL = kstr->l;
#    OUTPUT:
#        RETVAL
#
#size_t
#kstr_m(kstr)
#    Bio::Kseq::Kstring kstr
#    PROTOTYPE: $
#    CODE:
#        RETVAL = kstr->m;
#    OUTPUT:
#        RETVAL
#
#char*
#kstr_s(kstr)
#    Bio::Kseq::Kstring kstr
#    PROTOTYPE: $
#    CODE:
#        RETVAL = kstr->s;
#    OUTPUT:
#        RETVAL

MODULE = Bio::Kseq PACKAGE = Bio::Kseq::Kstream   PREFIX=kstream_

Bio::Kseq::Kstream
kstream_new(package, fh)
    char *package
    Bio::Kseq::Fh fh
    PROTOTYPE: $$
    CODE:
        RETVAL = ks_init(fh);
    OUTPUT:
        RETVAL

int
kstream_begin(kstr)
    Bio::Kseq::Kstream kstr
    PROTOTYPE: $
    CODE:
        RETVAL = kstr->begin;
    OUTPUT:
        RETVAL

int
kstream_end(kstr)
    Bio::Kseq::Kstream kstr
    PROTOTYPE: $
    CODE:
        RETVAL = kstr->end;
    OUTPUT:
        RETVAL

int
kstream_is_eof(kstr)
    Bio::Kseq::Kstream kstr
    PROTOTYPE: $
    CODE:
        RETVAL = kstr->is_eof;
    OUTPUT:
        RETVAL

char *
kstream_buffer(kstr)
    Bio::Kseq::Kstream kstr
    PROTOTYPE: $
    CODE:
        RETVAL = (char *)kstr->buf;
    OUTPUT:
        RETVAL

Bio::Kseq::Fh
kstream_fh(kstr)
    Bio::Kseq::Kstream kstr
    PROTOTYPE: $
    CODE:
        RETVAL = kstr->f;
    OUTPUT:
        RETVAL

void
kstream_DESTROY(kstr)
    Bio::Kseq::Kstream kstr
    PROTOTYPE: $
    CODE:
        ks_destroy(kstr);

MODULE = Bio::Kseq PACKAGE = Bio::Kseq::Iterator   PREFIX=it_

SV *
it_next_seq(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    INIT:
        HV * results;
    CODE:
        results = (HV *)sv_2mortal((SV *)newHV());
        if (kseq_read(it) >= 0) {
            hv_stores(results, "name", newSVpvn(it->name.s, it->name.l));
            hv_stores(results, "desc", newSVpvn(it->comment.s, it->comment.l));
            hv_stores(results, "seq", newSVpvn(it->seq.s, it->seq.l));
            hv_stores(results, "qual", newSVpvn(it->qual.s, it->qual.l));
            RETVAL = newRV((SV *)results);
        } else {
            XSRETURN_UNDEF;
        }
    OUTPUT:
        RETVAL

int
it_read(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    INIT:
    CODE:
        RETVAL = kseq_read(it);
    OUTPUT:
        RETVAL

void
it_rewind(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    CODE:
        /* kseq_rewind() doesn't completely rewind the file,
          just resets markers */
        kseq_rewind(it);
        /* use zlib to do so */
        gzrewind(it->f->f);

Bio::Kseq::Kstream
it_kstream(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = it->f;
    OUTPUT:
        RETVAL

char *
it_name(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = it->name.s;
    OUTPUT:
        RETVAL

char *
it_comment(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = it->comment.s;
    OUTPUT:
        RETVAL

char *
it_seq(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = it->seq.s;
    OUTPUT:
        RETVAL

char *
it_qual(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = it->qual.s;
    OUTPUT:
        RETVAL

int
it_last_char(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = it->last_char;
    OUTPUT:
        RETVAL

void
it_DESTROY(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    CODE:
        kseq_destroy(it);
