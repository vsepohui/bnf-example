#!/usr/bin/perl

use strict;
use warnings;
use 5.022;
use lib 'lib';
use VectorTracer::Perl;

use Data::Dumper;

my $code = q[say 123; print 0000000000000];


my $tracer = new VectorTracer::Perl(debug => 0);
my $node = $tracer->parse($code);
say $tracer->trace($node);

1;
