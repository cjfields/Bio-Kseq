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
        fprintf(stderr, "Destroying Fh\n");
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
        fprintf(stderr, "Destroying Kstream\n");
        ks_destroy(kstr);

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
        fprintf(stderr, "Destroying Kseq\n");
		ks_destroy(ks->f);
		free(ks);
        kseq_destroy(it);
