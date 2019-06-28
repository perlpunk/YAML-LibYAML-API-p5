#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin '$Bin';

use Encode;
use Data::Dumper;
use YAML::LibYAML::API;
use YAML::LibYAML::API::XS;

my $parser = YAML::LibYAML::API::XS->new;
my $id;
eval {
    $id = $parser->create_parser;
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([$parser], ['parser']);
};
my $error = $@;
if ($error) {
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([$error], ['error']);
}


my $yaml = <<'EOM';
---
a: b
EOM

$parser->init_string($yaml);

my $cb = sub {
    my ($type) = @_;
    warn __PACKAGE__.':'.__LINE__.": !!!!! callback($type)\n";
};

$parser->parse_callback($cb);

$parser->delete_parser();

ok(1);

done_testing;
