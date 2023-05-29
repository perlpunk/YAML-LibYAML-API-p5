package YAML::LibYAML::API::YPP;
use strict;
use warnings;

use base qw/ YAML::PP Exporter /;
our @EXPORT_OK = qw/ Load Dump LoadFile DumpFile /;

use YAML::LibYAML::API::YPP::Parser;

sub new {
    my ($class, %args) = @_;

    my $self = $class->SUPER::new(
        parser => YAML::LibYAML::API::YPP::Parser->new,
        %args,
    );
    return $self;
}

1;
