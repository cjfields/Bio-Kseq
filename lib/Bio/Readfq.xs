#ifdef PERL_CAPI
#define WIN32IO_IS_STDIO
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <zlib.h>
#include <stdio.h>
#include <perlio.h>
#include <kseq.h>

KSEQ_INIT(gzFile, gzread)

typedef kseq_t*         Bio__Readfq__Iterator;
typedef gzFile          Bio__Readfq__File;

MODULE = Bio::Readfq PACKAGE = Bio::Readfq  PREFIX=readfq_

Bio::Readfq::File
readfq_fqopen(pack, filename, mode="r")
    char *pack
    char *filename
    char *mode
    PROTOTYPE: $$
    CODE:
        RETVAL = gzdopen(*filename, mode);
    OUTPUT:
        RETVAL

MODULE = Bio::Readfq PACKAGE = Bio::Readfq::File   PREFIX=file_

Bio::Readfq::Iterator
file_iterator(fp)
    Bio::Readfq::File fp
    PROTOTYPE: $
    CODE:
        RETVAL = kseq_init(fp);
    OUTPUT:
        RETVAL

void
readfq_DESTROY(fp)
    Bio::Readfq::File fp
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
            hv_store(results, "comment", 7, newSVpv(it->comment.s, it->comment.l), 0);
            hv_store(results, "seq", 3, newSVpv(it->seq.s, it->seq.l), 0);
            hv_store(results, "qual", 4, newSVpv(it->qual.s, it->qual.l), 0);
            ST(0) = newRV((SV *)results);
        }

void
it_DESTROY(it)
    Bio::Readfq::Iterator it
    PROTOTYPE: $
    CODE:
        kseq_destroy(it);
