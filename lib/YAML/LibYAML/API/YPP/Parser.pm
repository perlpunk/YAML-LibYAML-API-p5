package YAML::LibYAML::API::YPP::Parser;
use strict;
use warnings;

use YAML::LibYAML::API::Parser;
use Scalar::Util qw/ openhandle /;
use base 'YAML::PP::Parser';
use Carp qw/ croak /;

sub parse {
    my ($self) = @_;
    my $reader = $self->reader;
    my $parser = YAML::LibYAML::API::Parser->new;
    if ($reader->can('open_handle')) {
        if (openhandle($reader->input)) {
            $parser->set_input_filehandle($reader->input);
        }
        else {
            croak "Currently parsing a file is not supported, see documentation of YAML::LibYAML::API::Parser";
        }
    }
    else {
        my $yaml = $reader->read;
        $parser->set_input_string($yaml);
    }
    while (my $event = $parser->parse) {
        $self->callback->( $self, $event->{name} => $event );
    }
}

1;
