#!/usr/bin/perl

# This deal I was coded on C++ when I was study in Moscow, try to remember this stuff...

use strict;
use warnings;
use experimental 'smartmatch';
use 5.022;

my $math = "sin(cos(200)+5+cos(1)*2+2)+5+5*sin(444)+5/2";


use Data::Dumper;
say Dumper (parse($math, {}));

# Hack method for fix math priority: setup brackets to multi and div
sub prepare_multi_and_div {
	my $str = shift;

	my @s = split //, $str;
	my $l = scalar (@s);
		
	for (my $i = 0 ; $i < $l ; $i ++) {
		my $c = $s[$i];
		if ($c ~~ ['*', '/']) {
			# Go back
			for (my $j = $i - 1; $j >= 0 ; $j --) {
				my $cnt = 0;
				if ($j eq ')') {
					$cnt ++;
					next;
				} 
				if ($j eq '(') {
					$cnt --;
				}
				last if $cnt == -1;
				if (($j == 0) || ($c ~~ ['+','-','/','*'])) {
					# Setup brackets
					# Go backward
					for (my $k = $j -1 ; $k >= 0 ; $k --) {
						if ($k == 0) {
							@s = ('(', @s);
							$i ++;
							$j ++;
							$k ++;
							$l ++;
							last;
						} 
						
						if ($s[$k] ~~ ['+','-','*','/']) {
							my @s1 = splice(@s, 0, $k+1);
							@s = (@s1, '(', @s);
							$i ++;
							$j ++;
							$k ++;
							$l ++;
							last;
						}
					}
					# Go forward
					for (my $k = $i + 1 ; $k < $l ; $k ++) {
						if ($k == $l - 1) {
							push @s, ')';
							$i ++;
							$j ++;
							$k ++;
							$l ++;
							last;
						} 
						if ($s[$k] ~~ ['+','-','*','/']) {
							my @s1 = splice(@s, 0, $k);
							@s = (@s1, ')', @s);
							$i ++;
							$j ++;
							$k ++;
							$l ++;
							last;
						}
					}
					
					last;
				}
			}
		}
	}
	
	return (scalar (@s) >= length ($str)) ? join '', @s : $str;
}

sub parse {
	my $str  = shift;
	my $node = shift;
	
	$str = prepare_multi_and_div($str);
	warn "Parse $str";
	
	my @s = split //, $str;
	my $sl = scalar (@s);
	
	my $function = '';
	my $digit = '';
	my @expression = ();
	
	my $value = {};
	
	my $func;
	
	for (my $i = 0; $i < @s; $i++) {
		my $c = $s[$i];
		
		if ($c =~ /[a-z]/) { # fuction processiong
			warn "Starting function processing";
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
			warn "Starting expression processing";
			my $j;
			my $buff = '';
			for ($j = $i + 0; $j < @s ; $j ++) {
				my $o = $s[$j];
				warn $o;
				$buff .= $o;
				my $cnt = 0;
				if ($o eq '(') {
					$cnt ++;
					next;
				}
				if ($o eq ')') {
					warn "$cnt , cnt00";
					$cnt --;
					if ($cnt == 0) {
						warn "Buff sub = $buff";
					#	$node->{$function} = parse($buff);
						last;
					}
				}
			}
			$i = $j;
			$function = '';
			next;
		} elsif ($c =~ /[0-9]/) {
			warn "Starting digit processing";
			$digit .= $c;
			my $j;
			my $buff = $digit;
			my $had_non_digit = 0;
			for ($j = $i + 1; $j < @s ; $j ++) {
				my $o = $s[$j];
				if ($o =~ /[0-9]/) {
					$buff .= $o;
				} else {
					$had_non_digit = 1;
					last;
				}
			}
			
			if ($had_non_digit) {
				$i = $j - 1;
				next;
				#$digit = $buff;
				#warn "Found digit = $digit";
				#push @expression, $digit;
			} else {
				$i = $j;
				$digit = $buff;
				warn "Found digit = $digit";
				push @expression, $digit;
			}
		} elsif ($c ~~ ['+', '-', '*', '/']) {
			my $op = $c;
			warn "op = $op";
			if ($digit) {
				push @expression, $digit;
				$digit = '';
			}
			$node->{$op} = \@expression;
			
			my $j;
			my $buff = '';
			my $cnt = 0;
			
			for ($j = $i + 1; $j < @s ; $j ++) {
				my $o = $s[$j];
				if ($o eq '(') {
					$cnt ++;
					next;
				}
				if ($o eq ')') {
					$cnt --;
				} 
				
				
				
				$buff .= $o;
				warn "$cnt, $buff";
				
				if ($cnt < 0 || $j == ($sl-1)) {
#					if ($o eq ')') {
#						$buff = substr($buff, 0, length($buff)-1);
#					}
					push @expression, parse ($buff);
					last;
				} 
			}
			$i = $j;
		}
	}
	
	
	if (@expression && !keys %$node) {
		return \@expression;
	}
	
	return $node;
}
