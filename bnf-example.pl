#!/usr/bin/perl

# This deal I was coded on C++ when I was study in Moscow, try to remember this stuff...

use strict;
use warnings;
use 5.022;

my $math = "sin(cos(200)+5+(2*2))+5";

use Data::Dumper;
say Dumper (parse($math, {}));

sub parse {
	my $str  = shift;
	my $node = shift;
	
	warn "Parse $str";
	
	my @s = split //, $str;
	
	my $function = '';
	my $digit = '';
	my @expression = ();
	
	my $value = {};
	
	my $func;
	
	for (my $i = 0; $i < @s; $i++) {
		warn "\$i = $i";
		my $c = $s[$i];
		
		
		if ($c =~ /[a-z]/) { # fuction processiong
			my $j;
			my $func_end = 0;
			my $buff = '';
			
			for ($j = $i; $j < @s ; $j ++) {
				
				my $o = $s[$j];
				if ($o eq '(') {
					$func_end = 1;
					my $j2;
					
					my $cnt = 1;
					for ($j2 = $j + 1; $j2 < @s ; $j2 ++) {
						my $o = $s[$j2];
						$buff .= $o;
						if ($o eq '(') {
							$cnt ++;
							next;
						}
						if ($o eq ')') {
							$cnt --;
							if ($cnt == 0) {
								last;
							}
						}
						
					}
					$buff =~ s/^(.+).$/$1/;
					$j = $j2;
					last;
				} elsif ($func_end == 0) {
					$func .= $o;
				}
				
				
			}
			$i = $j;	
			
			warn "Found function = $func, buff = $buff";
			push @expression, {$func => parse($buff)};
		} elsif ($c eq '(') {
			my $j;
			my $buff = '';
			for ($j = $i + 1; $j < @s ; $j ++) {
				my $o = $s[$j];
				$buff .= $o;
				my $cnt = 1;
				if ($o eq '(') {
					$cnt ++;
					next;
				}
				if ($o eq ')') {
					$cnt --;
					if ($cnt == 0) {
						warn "Buff = $buff";
					#	$node->{$function} = parse($buff);
						last;
					}
				}
			}
			$i = $j;
			$function = '';
			next;
		} elsif ($c =~ /[0-9]/) {
			$digit .= $c;
			my $j;
			my $buff = $digit;
			for ($j = $i + 1; $j < @s ; $j ++) {
				my $o = $s[$j];
				if ($o =~ /[0-9]/) {
					$buff .= $o;
				} else {
					last;
				}
			}
			#warn "j = $j";
			$i = $j;
			$digit = $buff;
			warn "Found digit = $digit";
			push @expression, $digit;
			last;
		} elsif ($c ~~ ['+','-','/','*']) {
			my $op = $c;			
			if ($digit) {
				push @expression, $digit;
				$digit = '';
			}
			$node->{$op} = \@expression;
		}
	}
	
	
	if (@expression && !keys %$node) {
		return \@expression;
	}
	
	return $node;
}
