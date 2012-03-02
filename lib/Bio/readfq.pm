package Bio::Readfq;
use strict;
use warnings;
# ABSTRACT: low-level XS-based FASTQ/FASTA parser

use base qw(DynaLoader);
bootstrap Bio::Readfq;

sub new {
    my ($class, %args) = @_;
    if (ref $class) {
        $class = ref $class;
    }
    my $self = bless \%args, $class;
    $self->_init();
    $self;
}

sub file_name {
    my $self = shift;
    $self->{file}
}

# convenience method
sub next_seq {
    my $self = shift;
    return $self->{_it}->next_seq();
}

sub _init {
    my $self = shift;
    $self->{_fp} = $self->open($self->file_name);
    $self->{_it} = $self->init_iterator($self->{_fp});
}

sub _fp {
    my $self = shift;
    $self->{_fp}
}

1;
