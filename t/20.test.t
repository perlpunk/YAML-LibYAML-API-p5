#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin '$Bin';

use Encode;
use Data::Dumper;
use YAML::LibYAML::API;
use YAML::LibYAML::API::XS;

my $xsparser = YAML::LibYAML::API::XS->new;
my $parser = YAML::LibYAML::API::XS->new;
eval {
    my $id = $xsparser->parser_create;
};
my $error = $@;
if ($error) {
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([$error], ['error']);
}

my $yaml = <<'EOM';
---
a: b
EOM

$xsparser->parser_init_string($yaml);

my $cb = sub {
    my ($event) = @_;
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([$event], ['event']);
};

$xsparser->set_parse_callback($cb);
$xsparser->parse_callback();

my $ok = $xsparser->parser_delete();

ok(1);

done_testing;
