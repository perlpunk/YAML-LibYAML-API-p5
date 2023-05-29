package YAML::LibYAML::API::Parser;
use strict;
use warnings;

our $VERSION = '0.000'; # VERSION

use YAML::LibYAML::API::XS;

1;

__END__

=pod

=head1 NAME

YAML::LibYAML::API::Parser - Object oriented wrapper around the C libyaml parser

=head1 SYNOPSIS

    use YAML::LibYAML::API::XS;
    my $parser = YAML::LibYAML::API::Parser->new;
    $parser->set_input_string($yaml);
    # $parser->set_input_filehandle($fh);
    # $parser->set_input_file($filename); # leaks
    while (my $event = $p->parse) {
        say $event->{name};
    }

=head1 DESCRIPTION

With this module you can parse a YAML string or filehandle and receive each parsing event
in a loop.

Parsing a file has a memory leak currently.

It is using the C library libyaml.

Emitting is not yet implemented.

=cut
