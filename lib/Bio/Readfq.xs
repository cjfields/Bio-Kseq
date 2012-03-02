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

KSEQ_INIT(gzFile, gzRead)

typedef kseq_t*         Bio__Readfq__Iterator;
typedef gzFile          Bio__Readfq__File;

MODULE = Bio::Readfq PACKAGE = Bio::Readfq::File  PREFIX=readfq_

Bio::Readfq::File
readfq_open(filename, mode="r")
    char * filename
    char * mode
    PROTOTYPE: $$
    CODE:
        RETVAL = gzdopen(*filename, mode);
    OUTPUT:
        RETVAL

void
readfq_DESTROY(fp)
    Bio::Readfq::File fp
    PROTOTYPE: $
    CODE:
        gzclose(fp);

MODULE = Bio::Readfq PACKAGE = Bio::Readfq::Iterator   PREFIX=it_

