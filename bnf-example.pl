#!/usr/bin/perl

# This deal I was coded on C++ when I was study in Moscow, try to remember this stuff...

use strict;
use warnings;
use experimental 'smartmatch';
use 5.022;
use Data::Dumper;

my $math = "sin(100)/20+2+2*sin(66)/cos(123)";

my $tracer = new VectorTracer;
my $graf = $tracer->parse($math);
say Dumper $graf;

package VectorTracer;

sub new {
	my $class = shift;
	return bless {}, $class;
}

# Hack method for fix math priority: setup brackets to multi and div
sub prepare_multi_and_div {
	my $self = shift;
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
	my $self = shift;
	my $str  = shift;
	$str = $self->prepare_multi_and_div($str);
	return $self->_depack($self->_parse ($str));
}

sub _depack {
	my $self = shift;
	my $node = shift;
	if (ref $node eq 'HASH') {
		my ($key, $value) = each %$node;
		$node = {$key => $self->_depack ($value)};
	} elsif (ref $node eq 'ARRAY') {
		if (scalar (@$node) == 1) {
			$node = $node->[0];
			return $self->_depack($node) ;
		} else {
			for (@$node) {
				$_ = $self->_depack ($_);
			}
		}
	} 
	return $node;
}

sub _parse {
	my $self = shift;
	my $str  = shift;
	my $node = [];
	
	my @s = split //, $str;
	my $sl = scalar (@s);
	
	my $function = '';
	my $digit = '';
	my @expression = ();
	
	my $value = {};
	
	my $func;
	
	for (my $i = 0; $i < @s; $i++) {
		my $c = $s[$i];
		
		if ($c ~~ ['+', '-', '*', '/']) {
			my $op = $c;
			#warn "op = $op";
			if ($digit) {
				push @expression, $digit;
				$digit = '';
			}
			$node = {$op => [$node]};
			#push @$node, {$op => [@expression]};
			
			my $j;
			my $buff = '';
			my $cnt = 0;
			
			for ($j = $i + 1; $j < @s ; $j ++) {
				my $o = $s[$j];
				if ($o eq '(') {
					$cnt ++;
					#next;
				}
				if ($o eq ')') {
					$cnt --;
				} 
				
				
				
				$buff .= $o;
				#warn "$cnt, $buff";
				
				if ($cnt < 0 || $j == ($sl-1)) {
					#die $buff;
					#push @{$node->[-1]->{$op}}, $self->_parse ($buff);
					push @{$node->{$op}}, $self->_parse ($buff);
					last;
				} 
			}
			$i = $j;
			
			#@expression = ();
		} elsif ($c eq '(') {
			my $j;
			my $buff = '';
			for ($j = $i + 0; $j < @s ; $j ++) {
				my $o = $s[$j];
				#warn $o;
				$buff .= $o;
				my $cnt = 0;
				if ($o eq '(') {
					$cnt ++;
					next;
				}
				if ($o eq ')' || $j == scalar (@s) - 1) {
					#warn "$cnt , cnt00";
					$cnt --;
					if ($cnt == -1) {
						#warn "Buff sub = $buff";
						#die $function;
						push @$node, $self->_parse(substr($buff,1,-1));
						#$node->{$function} = $self->_parse($buff);
						last;
					}
				}
			}
			$i = $j;
			$function = '';
			next;
		} elsif ($c =~ /[a-z]/) { # fuction processiong
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
					#$buff =~ s/^(.+).$/$1/;
					$j = $j2;
					last;
				} elsif ($func_end == 0) {
					$func .= $o;
				}
				
				
			}
			$i = $j;	
			
			#warn "Found function = $func, buff = $buff";
			push @$node, {$func => $self->_parse($buff)};
		} elsif ($c =~ /[0-9]/) {
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
				$digit = substr($buff, 0, length ($buff) );
				#warn "Found digit = $digit";
				push @$node, $digit;
			} else {
				$i = $j;
				$digit = $buff;
				#warn "Found digit = $digit";
				push @$node, $digit;
			}
		}
	}
		
	return $node;
}
