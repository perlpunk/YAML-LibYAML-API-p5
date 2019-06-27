#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin '$Bin';

use Encode;
use Data::Dumper;
use YAML::LibYAML::API;
use YAML::LibYAML::API::XS;

my $id;
eval {
    $id = YAML::LibYAML::API::XS::create_parser();
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([$id], ['id']);
};
my $error = $@;
if ($error) {
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([$error], ['error']);
}


my $yaml = <<'EOM';
---
a: b
EOM

YAML::LibYAML::API::XS::init_string($id, $yaml);

YAML::LibYAML::API::XS::delete_parser($id);

ok(1);

done_testing;
