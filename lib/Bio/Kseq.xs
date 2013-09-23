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

typedef kseq_t*         Bio__Kseq__Iterator;
typedef gzFile          Bio__Kseq;

MODULE = Bio::Kseq PACKAGE = Bio::Kseq  PREFIX=kseq_

Bio::Kseq
kseq_new(pack, filename, mode="r")
    char *pack
    char *filename
    char *mode
    PROTOTYPE: $$$
    CODE:
        RETVAL = gzopen(filename, mode);
    OUTPUT:
        RETVAL

Bio::Kseq
kseq_newfh(pack, fh, mode="r")
    char *pack
    PerlIO* fh
    char *mode
    PROTOTYPE: $$$
    CODE:
        RETVAL = gzdopen(PerlIO_fileno(fh), mode);
    OUTPUT:
        RETVAL

Bio::Kseq::Iterator
kseq_iterator(fp)
    Bio::Kseq fp
    PROTOTYPE: $
    CODE:
        RETVAL = kseq_init(fp);
    OUTPUT:
        RETVAL

void
kseq_DESTROY(fp)
    Bio::Kseq fp
    PROTOTYPE: $
    CODE:
        gzclose(fp);

MODULE = Bio::Kseq PACKAGE = Bio::Kseq::Iterator   PREFIX=it_

SV *
it_next_seq(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    INIT:
        HV * results;
        SV ** stuff;
    CODE:
        ST(0) = sv_newmortal();
        if (kseq_read(it) >= 0) {
            results = (HV *)sv_2mortal((SV *)newHV());
            stuff = hv_store(results, "name", 4, newSVpv(it->name.s, it->name.l), 0);
            stuff = hv_store(results, "desc", 4, newSVpv(it->comment.s, it->comment.l), 0);
            stuff = hv_store(results, "seq", 3, newSVpv(it->seq.s, it->seq.l), 0);
            stuff = hv_store(results, "qual", 4, newSVpv(it->qual.s, it->qual.l), 0);
            ST(0) = newRV_inc((SV *)results);
        }

#SV *
#it_pos(it)
#    Bio::Kseq::Iterator it
#    PROTOTYPE: $
#    CODE:
#        RETVAL = newSViv(it->f->begin);
#    OUTPUT:
#        RETVAL

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

#int
#it_gzrewind(it)
#    Bio::Kseq::Iterator it
#    PROTOTYPE: $
#    CODE:
#        RETVAL = gzrewind(it->f->f);
#    OUTPUT:
#        RETVAL
#
#z_off_t
#it_gzseek(it, offset, whence)
#    Bio::Kseq::Iterator it
#    z_off_t             offset
#    int                 whence
#    PROTOTYPE: $$$
#    CODE:
#        /*
#           note this is supposed to be very slow with zipped, not sure about
#           uncompressed...
#        */
#        RETVAL = gzseek(it->f->f, offset, whence);
#    OUTPUT:
#        RETVAL
#
#z_off_t
#it_gztell(it)
#    Bio::Kseq::Iterator it
#    PROTOTYPE: $
#    CODE:
#        RETVAL = gztell(it->f->f);
#    OUTPUT:
#        RETVAL

void
it_DESTROY(it)
    Bio::Kseq::Iterator it
    PROTOTYPE: $
    CODE:
        kseq_destroy(it);
