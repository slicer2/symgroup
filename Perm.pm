package Perm;

use strict;
use warnings;
use Exporter;
use Data::Dumper;
use List::Util;
use List::MoreUtils;

our @ISA = qw(Exporter);
our @EXPORT = qw(isCanonicalPerm normalize pretty mult);

# Test if a given perm is a valid canonical permutation
# A canonical form consists of disjoint cycles with distinct elements
# A single empty cycle is identity, also canonical

sub isCanonicalPerm {
	my $perm = shift;

	return 1 if ($#$perm == -1);

	for my $cyc (@$perm) {
		return 0 if (@$cyc < 2);
	}

	my %elems = ();
	for my $cyc (@$perm) {
		for my $elem (@$cyc) {
			return 0 if (exists $elems{$elem});
			$elems{$elem} = 1;
		}
	}

	return 1;
}

# pretty text book cycle representation
sub pretty {
	my $perm = shift;

	if ($#$perm == -1) {
		return "()";
	}

	my $prettyForm;
	for my $cyc (@$perm) {
		$prettyForm .= "($cyc->[0]";
		for (my $i=1; $i<=$#$cyc; $i++) {
			$prettyForm .= " $cyc->[$i]";
		}
		$prettyForm .= ")";
	}

	return $prettyForm;
}

# normalize a permutation in canonical form
# such that each cycle begins with the smallest 
# number in it and all cycles sorted in ascending order 
# of each cycle's first number
#
# Can call it on noncanonical form permutation
# following the above rules but it is less
# useful and not recommended
sub normalize {
	my $perm = shift;
	#isCanonicalPerm($perm) || { print "Perm "; print Dumper($perm); die "not valid."; }

	for my $cyc (@$perm) {
		my $cycMin = List::Util::min(@$cyc);
		my $cycMinIdx = List::MoreUtils::first_index {$_ == $cycMin} @$cyc;
		$cyc = [ @$cyc[$cycMinIdx .. $#$cyc, 0 .. $cycMinIdx-1 ] ];
	}

	$perm = [ sort { $a->[0] <=> $b->[0] } @$perm ];
}

sub isUnit {
	my $perm = toCanonical( shift );
	return 1 if ($#$perm == -1);
	return 0;
}

# Generate a hash based on a canonical form
# Attn: later may want to change its behavior 
# to return a reference

sub toHash {
	my $perm = shift;
	my %t = ();

	for my $cyc (@$perm) {
		for (my $i=0; $i<@$cyc; $i++) {
			$t{$cyc->[$i]} = $cyc->[($i+1) % @$cyc];
		}
	}

	return %t;
}

# Multiply two permutations based on their canonical forms
# Permutations act on natural numbers from left

sub mult {
	my ($a, $b) = @_;
	my $r = [];

	return $b if (isUnit($a));
	return $a if (isUnit($b));

	my %ta = toHash($a);
	my %tb = toHash($b);
	my %t = %ta;


	for my $k (keys %tb) {
		if (exists $ta{$tb{$k}}) {
			$t{$k} = $ta{$tb{$k}};
		}
		else {
			$t{$k} = $tb{$k};
		}
	}

	for my $k (keys %t) {
		if ($t{$k} != -1) {
			my $curr = $k;
			my @cyc;

			while ($t{$curr} != -1) {
				push @cyc, $curr;
				($curr, $t{$curr}) = ($t{$curr}, -1);
			}

			push @$r, [ @cyc ] if (@cyc > 1);
		}
	}

	return $r;
}

# Canonical form of disjoint cycles
sub toCanonical {
	my $perm = shift;

	# if $perm is unit
	return [] if (! @$perm);

	my @separateCyc = map { [$_] } @$perm;

	return List::Util::reduce { mult($a, $b) } @separateCyc;
}

sub inv {
	my $perm = shift;
	my @cycles = map { [reverse @$_] } reverse @$perm;
	return [ @cycles ];
}

sub isEqual {
	my ($a, $b) = @_;
	return isUnit( mult(toCanonical($a), inv(toCanonical($b))) );
}

sub order {
	my $perm = toCanonical( shift );
	my $prod = [ @$perm ];
	my $ord = 1;

	while (!isUnit($prod)) {
		$prod = mult($perm, $prod);
		$ord++;
	}

	return $ord;
}

sub test {
	# test isCanonicalPerm

	my $p = [[1, 2], [3, 4]];
	print pretty($p), " is ", (isCanonicalPerm($p)? "canonical":"non-canonical"), "\n";

	$p = [[1, 2], [3, 1]];
	print pretty($p), " is ", (isCanonicalPerm($p)? "canonical":"non-canonical"), "\n";

	$p = [[1, 2], [4]];
	print pretty($p), " is ", (isCanonicalPerm($p)? "canonical":"non-canonical"), "\n";

	$p = [[3, 4]];
	print pretty($p), " is ", (isCanonicalPerm($p)? "canonical":"non-canonical"), "\n";

	$p = [];
	print pretty($p), " is ", (isCanonicalPerm($p)? "canonical":"non-canonical"), "\n";

	# test normalize
	$p = [[3, 4], [1, 2]];
	$p = normalize($p);
	print "Normalizing ", pretty($p), " = ", pretty($p), "\n";

	$p = [[3, 4], [2, 5, 1]];
	$p = normalize($p);
	print "Normalizing ", pretty($p), " = ", pretty($p), "\n";

	# test toHash
	$p = [[3, 4], [2, 5, 1]];
	my %t = toHash($p);
	print "Testing toHash() on ", pretty($p), ":\n";
	for my $k (keys %t) {
		print "$k -> $t{$k}\n";
	}

	# test multiplication
	my $a = [[1, 2, 3]];
	my $b = [[2, 3, 4, 5]];
	my $r = mult($a, $b);
	print pretty($a), " * ", pretty($b), " = ", pretty($r), "\n";

	$b = [[1, 2, 3]];
	$a = [[2, 3, 4, 5]];
	$r = mult($a, $b);
	print pretty($a)." * ".pretty($b)." = ".pretty($r)."\n";

	my $c;
	($a, $b, $c) = ([[1, 2]], [[1, 3]], [[1, 4]]);
	$r = mult($b, $c);
	$r = mult($a, $r);
	print pretty($a), " * ", pretty($b), " * ", pretty($c), " = ", pretty($r), "\n";

	($a, $b) = ([[1, 2]], [[3, 4]]);
	$r = mult($a, $b);
	print pretty($a), " * ", pretty($b), " = ", pretty($r), "\n";

	($a, $b) = ([[1, 2]], [[1, 3, 2, 4]]);
	$r = mult($a, $b);
	print pretty($a), " * ", pretty($b), " = ", pretty($r), "\n";
	
	($a, $b) = ([], [[1, 3, 2, 4]]);
	$r = mult($a, $b);
	print pretty($a), " * ", pretty($b), " = ", pretty($r), "\n";

	($a, $b) = ([[1, 2]], []);
	$r = mult($a, $b);
	print pretty($a), " * ", pretty($b), " = ", pretty($r), "\n";

	($a, $b) = ([[1, 2, 3, 4]], [[4, 3, 2, 1]]);
	$r = mult($a, $b);
	print pretty($a), " * ", pretty($b), " = ", pretty($r), "\n";
	
	# test toCanonical
	$a = [[1, 2], [1, 3], [1, 4]];
	print "Canonical form of ", pretty($a), " = ", pretty(toCanonical($a)), "\n";

	$a = [[4, 1], [1, 4]];
	print "Canonical form of ", pretty($a), " = ", pretty(toCanonical($a)), "\n";

	$a = [[1, 2], [1, 3], [1, 4], [1, 2, 3, 4]];
	print "Canonical form of ", pretty($a), " = ", pretty(toCanonical($a)), "\n";

	$a = [];
	print "Canonical form of ", pretty($a), " = ", pretty(toCanonical($a)), "\n";

	# test inv
	$a = [[1, 2, 3]];
	print pretty($a), "^(-1) = ", pretty(inv($a)), "\n";

	$a = [[1, 2], [3, 4]];
	print pretty($a), "^(-1) = ", pretty(inv($a)), "\n";

	$a = [[1, 2], [1, 3], [1, 4]];
	print pretty($a), "^(-1) = ", pretty(inv($a)), "\n";

	$a = [];
	print pretty($a), "^(-1) = ", pretty(inv($a)), "\n";

	# test isEqual
	$a = [[1, 2], [1, 3], [1, 4]];
	$b = [[4, 3, 2, 1]];
	if (isEqual($a, $b)) {
		print pretty($a), " == ", pretty($b), "\n";
	}
	else {
		print pretty($a), " != ", pretty($b), "\n";
	}

	# test order
	$a = [[1, 2, 3]];
	print "Order of ", pretty($a), " is ", order($a), "\n";

	$a = [[1, 2], [1, 3], [1, 4]];
	print "Order of ", pretty($a), " is ", order($a), "\n";



}

1;
