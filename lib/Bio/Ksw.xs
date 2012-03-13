#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdint.h>
#include "ksw.h"

typedef kswq_t*         Bio__Ksw__Query;
typedef kswr_t*         Bio__Ksw__Match;

MODULE = Bio::Ksw PACKAGE = Bio::Ksw::Query  PREFIX=kswquery_

Bio::Ksw::Query
kswquery_new(self, size, qlen, query, m, mat)
    char*               pack
    int                 size
    int                 qlen
    const uint8_t*      query
    int                 m
    const int8_t*       mat
    PROTOTYPE: $$$$$$
    CODE:
        RETVAL = ksw_qinit(size, qlen, *query, m, *mat);
    OUTPUT:
        RETVAL

MODULE = Bio::Ksw PACKAGE = Bio::Ksw::Match  PREFIX=kswmatch_
