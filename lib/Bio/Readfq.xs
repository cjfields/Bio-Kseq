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

//typedef kseq_t         Bio::Readfq::Iterator;

MODULE = Bio::Readfq PACKAGE = Bio::Readfq   PREFIX=readfq_

Bio::Readfq::Iterator
readfq_gzopen(filename, mode="r")
    char * filename
    char * mode
    gzFile fp
    PROTOTYPE: $$
    CODE:
        fp = gzdopen(filename, mode)
        RETVAL = seq = kseq_init(fp)
    OUTPUT:
        RETVAL

MODULE = Bio::Readfq PACKAGE = Bio::Readfq::Iterator   PREFIX=iterator

MODULE = Bio::Readfq PACKAGE = Bio::Readfq::Seq
