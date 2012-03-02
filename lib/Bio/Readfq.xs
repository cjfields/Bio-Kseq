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

MODULE = Bio::Readfq PACKAGE = Bio::Readfq  PREFIX=readfq_

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

Bio::Readfq::Iterator
file_iterator(fp)
    Bio::Readfq::File fp
    PROTOTYPE: $
    CODE:
        RETVAL = kseq_init(fp);

## Bio::Readfq::Iterator
## readfq_iterator(fp)
## kseq_init(fp)

MODULE = Bio::Readfq PACKAGE = Bio::Readfq::File   PREFIX=file_



MODULE = Bio::Readfq PACKAGE = Bio::Readfq::Iterator   PREFIX=it_

