#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use YAML::LibYAML::API;
use YAML::LibYAML::API::FFI;

my @exp_events;
subtest parse_string_events => sub {
    my $dir = YAML::LibYAML::API::FFI::version_dir->new({major => 1, minor => 2});
    diag "directive: $dir";
    is "$dir", '[major:1 minor:2]';

    my $str = YAML::LibYAML::API::FFI::event_type::YAML_STREAM_END_EVENT;
    my $mark = YAML::LibYAML::API::FFI::YamlMark->new({ index => 1, line => 1, column => 23 });
    diag "$mark";

    my $u = YAML::LibYAML::API::FFI::EventData->new({ stream_start => 42 });
    diag $u->stream_start;

    my $scalar = YAML::LibYAML::API::FFI::EventData->new({
        scalar => { length => 3, plain_implicit => 1 } },
    );
    diag $scalar->scalar->length;
    diag $scalar->scalar->plain_implicit;


    my $event = YAML::LibYAML::API::FFI::Event->new({
        type => YAML::LibYAML::API::FFI::event_type::YAML_SCALAR_EVENT,
        start_mark => {
            index => 1,
            line => 1,
            column => 23,
        },
        end_mark => {
            index => 1,
            line => 1,
            column => 23,
        },
        data => {
            scalar => {
                length => 3,
                plain_implicit => 1,
                tag => 'abc',
            },
        },
    });
    diag $event->type;
    diag $event->start_mark->column;
    diag $event->end_mark->column;
    diag $event->data;
    diag $event->data->scalar->length;
    diag $event->data->scalar->plain_implicit;
    diag $event->data->scalar->tag;


};

subtest libyaml_version => sub {
    my $libyaml_version = YAML::LibYAML::API::FFI::libyaml_version();
    diag "libyaml version = $libyaml_version";
    cmp_ok($libyaml_version, '=~', qr{^\d+\.\d+(?:\.\d+)$}, "libyaml_version ($libyaml_version)");
};

done_testing;

