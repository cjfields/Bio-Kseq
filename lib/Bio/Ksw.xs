#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include "ksw.h"

/* TODO: define error checking, and clean up possible stdio/PerlIO issues */

typedef ksw_t*         Bio__Ksw;

MODULE = Bio::Kseq PACKAGE = Bio::Kseq  PREFIX=kseq_
