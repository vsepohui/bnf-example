#!/usr/bin/perl

use strict;
use warnings;
use 5.022;
use lib 'lib';
use VectorTracer;

use constant TESTS => [
	"2-2*cos(10)*10",
	"2+2",
	"-2",
	"sin(123)*214.4-1/2",
];

use Test::More tests => scalar @{TESTS()};

my $tracer = new VectorTracer;

for my $t (@{TESTS()}) {
	ok (test_expression($t),  "Test $t... ");
}

sub test_expression {
	my $str = shift;
	$tracer->parse($str);
	my $result = $tracer->trace();
	return ($result == (eval $str));
	
}

1;
