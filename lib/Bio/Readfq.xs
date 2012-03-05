#ifdef PERL_CAPI
#define WIN32IO_IS_STDIO
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <zlib.h>
#include <stdio.h>
#include <perlio.h>
#include <kseq.h>

KSEQ_INIT(gzFile, gzread)

typedef kseq_t*         Bio__Readfq__Iterator;
typedef gzFile          Bio__Readfq;

MODULE = Bio::Readfq PACKAGE = Bio::Readfq  PREFIX=readfq_

Bio::Readfq
readfq_new(pack, filename, mode="r")
    char *pack
    char *filename
    char *mode
    PROTOTYPE: $$$
    CODE:
        RETVAL = gzopen(filename, mode);
    OUTPUT:
        RETVAL

Bio::Readfq::Iterator
readfq_iterator(fp)
    Bio::Readfq fp
    PROTOTYPE: $
    CODE:
        RETVAL = kseq_init(fp);
    OUTPUT:
        RETVAL

void
readfq_DESTROY(fp)
    Bio::Readfq fp
    PROTOTYPE: $
    CODE:
        gzclose(fp);

MODULE = Bio::Readfq PACKAGE = Bio::Readfq::Iterator   PREFIX=it_

SV *
it_next_seq(it)
    Bio::Readfq::Iterator it
    PROTOTYPE: $
    INIT:
        HV * results;
    CODE:
        ST(0) = sv_newmortal();
        if (kseq_read(it) >= 0) {
            results = (HV *)sv_2mortal((SV *)newHV());
            hv_store(results, "name", 4, newSVpv(it->name.s, it->name.l), 0);
            hv_store(results, "desc", 4, newSVpv(it->comment.s, it->comment.l), 0);
            hv_store(results, "seq", 3, newSVpv(it->seq.s, it->seq.l), 0);
            hv_store(results, "qual", 4, newSVpv(it->qual.s, it->qual.l), 0);
            ST(0) = newRV_inc((SV *)results);
        }

SV *
it_pos(it)
    Bio::Readfq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = newSViv(it->f->begin);
    OUTPUT:
        RETVAL

void
it_rewind(it)
    Bio::Readfq::Iterator it
    PROTOTYPE: $
    CODE:
        /* kseq_rewind() doesn't completely rewind the file,
          just resets markers */
        kseq_rewind(it);
        /* use zlib to do so */
        gzrewind(it->f->f);

int
it_gzrewind(it)
    Bio::Readfq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = gzrewind(it->f->f);
    OUTPUT:
        RETVAL

z_off_t
it_gzseek(it, offset, whence)
    Bio::Readfq::Iterator it
    z_off_t             offset
    int                 whence
    PROTOTYPE: $$$
    CODE:
        /*
           note this is supposed to be very slow with zipped, not sure about
           uncompressed...
        */
        RETVAL = gzseek(it->f->f, offset, whence);
    OUTPUT:
        RETVAL

z_off_t
it_gztell(it)
    Bio::Readfq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = gztell(it->f->f);
    OUTPUT:
        RETVAL

z_off_t
it_gzoffset(it)
    Bio::Readfq::Iterator it
    PROTOTYPE: $
    CODE:
        RETVAL = gzoffset(it->f->f);
    OUTPUT:
        RETVAL

void
it_DESTROY(it)
    Bio::Readfq::Iterator it
    PROTOTYPE: $
    CODE:
        kseq_destroy(it);
