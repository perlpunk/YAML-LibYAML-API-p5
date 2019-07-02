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
cmp_ok($ok, '==', 1, '1. delete returns 1');
ok(! exists $xsparser->{uid}, 'uid was deleted');

$ok = $xsparser->parser_delete();
cmp_ok($ok, '==', 0, '2. delete returns 0');

$xsparser->{uid} = undef;
$ok = $xsparser->parser_delete();
cmp_ok($ok, '==', 0, '3. delete returns 0');

$xsparser->{uid} = 0;
$ok = $xsparser->parser_delete();
cmp_ok($ok, '==', 0, '4. delete returns 0');

ok(1);

done_testing;
