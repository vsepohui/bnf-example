#!/usr/bin/perl

use strict;
use warnings;
use 5.022;
use lib 'lib';
use VectorTracer;

use Data::Dumper;

my $math = "sin(123)*214.4-1/2";


my $tracer = new VectorTracer(debug => 0);
my $node = $tracer->parse($math);
#say Dumper $node;
say $tracer->trace();

1;
