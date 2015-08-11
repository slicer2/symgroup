package Perm;

use strict;
use warnings;
use Exporter;
use Data::Dumper;
use List::Util;
use List::MoreUtils;

our @ISA = qw(Exporter);
our @EXPORT = qw(isValid normalize pretty mult);

sub isValid {
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

sub normalize {
	my $perm = shift;
	#isValid($perm) || { print "Perm "; print Dumper($perm); die "not valid."; }

	for my $cyc (@$perm) {
		my $cycMin = List::Util::min(@$cyc);
		my $cycMinIdx = List::MoreUtils::first_index {$_ == $cycMin} @$cyc;
		$cyc = [ @$cyc[$cycMinIdx .. $#$cyc, 0 .. $cycMinIdx-1 ] ];
	}

	$perm = [ sort { $a->[0] <=> $b->[0] } @$perm ];
}

sub isUnit {
	my $perm = shift;
	return 1 if ($#$perm == -1);
	return 0;
}

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

sub test {
	# test isValid

	my $p = [[1, 2], [3, 4]];
	print pretty($p), " is ", isValid($p), "\n";

	$p = [[1, 2], [3, 1]];
	print pretty($p), " is ", isValid($p), "\n";

	$p = [[1, 2], [4]];
	print pretty($p), " is ", isValid($p), "\n";

	$p = [[3, 4]];
	print pretty($p), " is ", isValid($p), "\n";

	$p = [];
	print pretty($p), " is ", isValid($p), "\n";

	# test normalize
	$p = [[3, 4], [1, 2]];
	$p = normalize($p);
	print pretty($p), "\n";

	$p = [[3, 4], [2, 5, 1]];
	$p = normalize($p);
	print pretty($p), "\n";

	# test toHash
	$p = [[3, 4], [2, 5, 1]];
	my %t = toHash($p);
	for my $k (keys %t) {
		print "$k -> $t{$k}\n";
	}

	# test multiplication
	my $a = [[1, 2, 3]];
	my $b = [[2, 3, 4, 5]];
	my $r = mult($a, $b);
	print pretty($a), " * ", pretty($b), " = ", pretty($r), "\n";

	my $b = [[1, 2, 3]];
	my $a = [[2, 3, 4, 5]];
	my $r = mult($a, $b);
	print pretty($a)." * ".pretty($b)." = ".pretty($r)."\n";

	my $c;
	($a, $b, $c) = ([[1, 2]], [[1, 3]], [[1, 4]]);
	$r = mult($b, $c);
	$r = mult($a, $r);
	print pretty($a), " * ", pretty($b), " * ", pretty($c), " = ", pretty($r), "\n";

}

1;
