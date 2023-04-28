#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use YAML::LibYAML::API;
use YAML::LibYAML::API::FFI;

my @exp_events;
subtest parse_string_events => sub {
    my $dir = YAML::LibYAML::API::FFI::version_dir->new(major => 1, minor => 2);
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$dir], ['dir']);
    my $major = $dir->major;
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$major], ['major']);
    my $minor = $dir->minor;
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$minor], ['minor']);
    diag "!!!!!!!!!! $dir";

#    my $type = YAML::LibYAML::API::FFI::event_type->new(1);
    my $event = YAML::LibYAML::API::FFI::event->new(
        type => 1,
    );
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$event], ['event']);
    my $type = $event->type;
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$type], ['type']);
    return;
};

subtest libyaml_version => sub {
    my $libyaml_version = YAML::LibYAML::API::FFI::libyaml_version();
    diag "libyaml version = $libyaml_version";
    cmp_ok($libyaml_version, '=~', qr{^\d+\.\d+(?:\.\d+)$}, "libyaml_version ($libyaml_version)");
};

done_testing;

