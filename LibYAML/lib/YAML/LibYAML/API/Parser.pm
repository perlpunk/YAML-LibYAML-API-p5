package YAML::LibYAML::API::Parser;
use strict;
use warnings;

our $VERSION = '0.000'; # VERSION

use YAML::LibYAML::API::XS;
use Scalar::Util qw/ openhandle /;

sub set_input_file {
    my ($self, $file) = @_;
    open my $fh, '<', $file or die "Could not open file '$file': $!";
    $self->set_input_filehandle($fh);
    $self->{fh} = $fh;
}

sub DESTROY {
    my ($self) = @_;
    if (my $fh = $self->{fh}) {
        openhandle($fh) and close $fh;
    }
    DESTROY_($self);
}

1;

__END__

=pod

=head1 NAME

YAML::LibYAML::API::Parser - Object oriented wrapper around the C libyaml parser

=head1 SYNOPSIS

    use YAML::LibYAML::API::Parser;
    my $parser = YAML::LibYAML::API::Parser->new;

    $parser->set_input_string($yaml);
    # $parser->set_input_filehandle($fh);
    # $parser->set_input_file($filename); # leaks

    while (my $event = $parser->parse) {
        say $event->{name};
    }

=head1 DESCRIPTION

With this module you can parse a YAML string or filehandle and receive each parsing event
in a loop.

Parsing a file has a memory leak currently.

It is using the C library libyaml.

Emitting is not yet implemented.

=cut
