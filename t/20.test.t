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
    $id = $parser->parser_create;
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

$parser->parser_init_string($yaml);

my $cb = sub {
    my ($event) = @_;
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([$event], ['event']);
};

$parser->set_parse_callback($cb);
$parser->parse_callback();

my $ok = $parser->parser_delete();

ok(1);

done_testing;
