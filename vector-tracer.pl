#!/usr/bin/perl

use strict;
use warnings;
use 5.022;
use lib 'lib';
use VectorTracer;

use Data::Dumper;

my $math = "2**4";


my $tracer = new VectorTracer(debug => 1);
my $node = $tracer->parse($math);
say Dumper $node;
say $tracer->trace();

1;
