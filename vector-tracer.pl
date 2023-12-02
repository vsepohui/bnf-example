#!/usr/bin/perl

# This deal I was coded on C++ when I was study in Moscow, try to remember this stuff...

use strict;
use warnings;

use 5.022;
use Data::Dumper;

my $math = "2-2*cos(10)*10";

my $tracer = new VectorTracer(debug => 0);
my $node = $tracer->parse($math);
say $tracer->trace();

package VectorTracer;

use strict;
use warnings;
use experimental 'smartmatch';

use Data::Dumper;

sub new {
	my $class = shift;
	my %opts  = (
		debug => 0,
		@_,
	);
	
	my $self = bless {
		node	=> undef,
		digit 	=> '',
		debug   => $opts{debug},
	}, $class;
	
	return $self;
}


sub debug {
	my $self = shift;
	my $msg  = shift;
	
	if ($self->{debug}) {
		warn '['.scalar(localtime).'] '. $msg . "\n";
	}
	return;
}

sub trace {
	my $self = shift;
	my $node = shift // $self->{node};
	
	if (ref $node eq 'HASH') {
		my ($key, $value) = each %$node;
		if ($key ~~ [qw/sin cos/]) {
			my $a = $self->trace($value);
			return sin($a) if ($key eq 'sin');
			return cos($a) if ($key eq 'cos');
		} elsif ($key ~~ ['+', '-', '*', '/']) {
			my ($a, $b) = @$value;
			$a = $self->trace($a);
			$b = $self->trace($b);
			return $a + $b if ($key eq '+');
			return $a - $b if ($key eq '-');
			return $a * $b if ($key eq '*');
			return $a / $b if ($key eq '/');
		}
	} elsif (ref $node eq 'ARRAY') {
		
	}
	return int $node;
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
	my $node = $self->_depack($self->_parse ($str));
	$self->{node} = $node;
	return $node;
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
	
	$self->debug("Parse $str");
	
	my @s = split //, $str;
	my $sl = scalar (@s);
	
	my $function = '';
	my @expression = ();
	
	my $value = {};
	
	my $func;
	
	for (my $i = 0; $i < @s; $i++) {
		my $c = $s[$i];
		$self->debug($c);
		if ($c ~~ ['+', '-', '*', '/']) {
			my $op = $c;
			$self->debug("op = $op");
			if ($self->{digit}) {
				push @expression, $self->{digit};
				$self->{digit} = '';
			}
			if (@$node) {
				$node = {$op => $node};
			} else {
				if ($op ~~ ['+', '-']) {
					my ($n, $idx) = $self->_parse_digit([@s[$i..$sl - 1]]);
					#push @$node, $n;
					$self->{digit} = $n;
					#push @expression, $self->{digit};
					push @$node, $self->{digit};
					$self->{digit} = '';
					$i = $i + $idx;
					
					#die $i;
					next;
					
				}
			}
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
				$self->debug("$cnt, $buff");
				
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
				$self->debug($o);
				$buff .= $o;
				my $cnt = 0;
				if ($o eq '(') {
					$cnt ++;
					next;
				}
				if ($o eq ')' || $j == scalar (@s) - 1) {
					$self->debug("$cnt , cnt00");
					$cnt --;
					if ($cnt == -1) {
						$self->debug("Buff sub = $buff");
						#die $function;
						push @$node, $self->_parse(substr($buff,1));
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
					warn $buff;
					$j = $j2;
					last;
				} elsif ($func_end == 0) {
					$func .= $o;
				}
				
				
			}
			$i = $j;	
			
			$self->debug("Found function = $func, buff = $buff");
			push @$node, {$func => $self->_parse($buff)};
		} elsif ($c =~ /[0-9\.]/) {
			my ($n, $idx) = $self->_parse_digit([@s[$i..$sl - 1]]);
			$i = $idx + $i;
			push @$node, $n;
		}
	}
		
	return $node;
}

sub _parse_digit {
	my $self = shift;
	my $s = shift;
	my @s = @$s;
	
	my $i = 0;
	my $c = $s[0];
	
	my $node = [];
	
	$self->{digit} .= $c;
	my $j;
	my $buff = $self->{digit};
	my $had_non_digit = 0;
	for ($j = $i + 1; $j < @s ; $j ++) {
		my $o = $s[$j];
		if ($o =~ /[0-9\.]/) {
			$buff .= $o;
		} else {
			$had_non_digit = 1;
			last;
		}
	}
	
	if ($had_non_digit) {
		$i = $j - 1;
		$self->{digit} = substr($buff, 0, length ($buff) );
		$self->debug("Found digit = ".$self->{digit});
		push @$node, $self->{digit};
	} else {
		$i = $j;
		$self->{digit} = $buff;
		$self->debug("Found digit = ".$self->{digit});
		push @$node, $self->{digit};
	}
	return ($node, $i);
}
