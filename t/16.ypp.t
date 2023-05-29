#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin '$Bin';
use Encode;

use YAML::LibYAML::API::YPP;
my $yaml = <<'EOM';
foö: &ALIAS bar
'alias': *ALIAS
tag: !!int 23
list:
- "doublequoted"
- >
  folded
- |-
  literal
...
%YAML 1.1
---
a: b
EOM

my $exp = [
  {
      decode_utf8("foö") => 'bar',
      alias => 'bar',
      tag => 23,
      list => [
        "doublequoted",
        "folded\n",
        "literal",
      ],
    },
    { a => "b" },
];

my $ypp = YAML::LibYAML::API::YPP->new;
my @data = $ypp->load_string($yaml);
is_deeply \@data, $exp, "load_string ok";

open my $fh, "<", "$Bin/data/simple.yaml" or die $!;
my $data = $ypp->load_file($fh);
$exp = { a => "b" };
is_deeply $data, $exp, "load_file (filehandle) ok";

eval {
    my $data = $ypp->load_file("$Bin/data/simple.yaml");
};
my $err = $@;
like $err, qr{Currently parsing a file is not supported}, "load_file (file) dies";

done_testing;
