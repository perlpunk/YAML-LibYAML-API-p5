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
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$str], ['str']);
    my $mark = YAML::LibYAML::API::FFI::YamlMark->new({
        index => 1,
        line => 1,
        column => 23,
    });
    my $event = YAML::LibYAML::API::FFI::event->new({
        type => $str,
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
    });
    diag explain $event->type;
    diag explain $event->start_mark->column;
    diag explain $event->end_mark->column;
};

subtest libyaml_version => sub {
    my $libyaml_version = YAML::LibYAML::API::FFI::libyaml_version();
    diag "libyaml version = $libyaml_version";
    cmp_ok($libyaml_version, '=~', qr{^\d+\.\d+(?:\.\d+)$}, "libyaml_version ($libyaml_version)");
};

done_testing;

