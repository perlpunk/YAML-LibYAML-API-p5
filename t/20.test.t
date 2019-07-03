#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin '$Bin';

use Encode;
use Data::Dumper;
use YAML::LibYAML::API;
use YAML::LibYAML::API::XS;
use YAML::PP::Common;

my $xsparser = YAML::LibYAML::API::XS->new;
my $parser = YAML::LibYAML::API::XS->new;
my $id = $xsparser->parser_create;
cmp_ok($xsparser->{uid}, '==', $id, "Parser uid ok");

my $yaml = <<'EOM';
---
a: b
EOM

$xsparser->parser_init_string($yaml);

my @expected = (
    '+STR',
    '+DOC ---',
    '+MAP',
    '=VAL :a',
    '=VAL :b',
    '-MAP',
    '-DOC',
    '-STR',
);

my @events;
my $cb = sub {
    my ($event) = @_;
    YAML::LibYAML::API::_numeric_to_string([$event]);
    push @events, YAML::PP::Common::event_to_test_suite($event);
};

$xsparser->set_parse_callback($cb);
$xsparser->parse_callback();
is_deeply(\@events, \@expected, "Events from first parse ok");

@events = ();
$xsparser->parser_create;
$xsparser->parser_init_string($yaml);
$xsparser->parse_callback();
is_deeply(\@events, \@expected, "Events from second parse ok");

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
