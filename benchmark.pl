#!/usr/bin/perl

#!/usr/bin/perl

use strict;
use warnings;
use 5.022;
use lib 'lib';
use VectorTracer;
use Benchmark qw(:all) ;

use constant TESTS => [
	"2-2*cos(10)*10",
	"2+2",
	"-2",
	"sin(123)*214.4-1/2",
	"cos(-1)-1",
	"2**4",
	"2**4+4**2/1",
];

my $tracer = new VectorTracer;

sub run {
	my $code = shift;
	for my $t (@{TESTS()}) {
		$code->($t);
	}
}


my $t0 = Benchmark->new;
for (1..10_000) {
	run sub {
		$tracer->parse(shift); $tracer->trace();
	};
}
my $t1 = Benchmark->new;
for (1..10_000) {
	run (sub {eval ("my \$s = " . shift. "; my \$x = ".rand().';')});
}
my $t2 = Benchmark->new;

my $td = timediff($t1, $t0);
say "The Vector Trace code time:" . timestr($td);
$td = timediff($t2, $t1);
say "The Perl Eval code time:" . timestr($td);







1;
