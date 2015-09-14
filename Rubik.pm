#!/usr/bin/perl
package Rubik;

use strict;
use warnings;
use Exporter;
use Data::Dumper;
use List::Util;
#use List::MoreUtils;
use Perm;

our @ISA = qw(Exporter);
our @EXPORT = qw();

our $size = 3;
our ($oc2n, $n2oc);
our $pieceOrientCode;

sub rol {
	return substr($_[0], 1, 2).substr($_[0], 0, 1);
}

sub generatePieceOrientCode {
	my @orientCode = ();
	my @oc1 = ();

	# corner pieces
	my @oc2 = ("dlf", "ufl", "dbl", "ulb", "dfr", "urf", "drb", "ubr");
	for my $l (0 .. 7) {
		my $postfix = $oc2[$l];
		push @orientCode, $postfix;

		for my $m (1 .. $size-1) {
			$postfix = rol($postfix);
			push @orientCode, $postfix;
		}
	}

	# edge and face pieces
	for my $i (1 .. $size) {
		for my $j (1 .. $size) {
			for my $k (1 .. $size) {
				if ( ($i != 1 && $i != $size) || ($j != 1 && $j != $size) || ($k != 1 && $k != $size) ) {
					push @oc1, [$i, $j, $k];
				}
			}
		}
	}
	
	PREFIX: for my $prefix (@oc1) {
		# on U
		if ($prefix->[2] == $size) {
			my $oc = "$prefix->[0]-$prefix->[1]-$prefix->[2]-";
			my $postfix = "u";
			
			# on L
			if ($prefix->[0] == 1) {
				$postfix .= "l";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# on R
			if ($prefix->[0] == $size) {
				$postfix .= "r";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# on F
			if ($prefix->[1] == 1) {
				$postfix .= "f";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# on B
			if ($prefix->[1] == $size) {
				$postfix .= "b";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# face piece on U
			push @orientCode, $oc.$postfix;
			next PREFIX;
		}

		# on D
		if ($prefix->[2] == 1) {
			my $oc = "$prefix->[0]-$prefix->[1]-$prefix->[2]-";
			my $postfix = "d";
			
			# on L
			if ($prefix->[0] == 1) {
				$postfix .= "l";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# on R
			if ($prefix->[0] == $size) {
				$postfix .= "r";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# on F
			if ($prefix->[1] == 1) {
				$postfix .= "f";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# on B
			if ($prefix->[1] == $size) {
				$postfix .= "b";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# face piece on D
			push @orientCode, $oc.$postfix;
			next PREFIX;
		}

		# on F, away from U, D
		if ($prefix->[1] == 1) {
			my $oc = "$prefix->[0]-$prefix->[1]-$prefix->[2]-";
			my $postfix = "f";

			# on L
			if ($prefix->[0] == 1) {
				$postfix .= "l";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# on R
			if ($prefix->[0] == $size) {
				$postfix.= "r";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# face piece on F
			push @orientCode, $oc.$postfix;
			next PREFIX;
		}

		# on B, away from U, D
		if ($prefix->[1] == $size) {
			my $oc = "$prefix->[0]-$prefix->[1]-$prefix->[2]-";
			my $postfix = "b";

			# on L
			if ($prefix->[0] == 1) {
				$postfix .= "l";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# on R
			if ($prefix->[0] == $size) {
				$postfix .= "r";
				push @orientCode, $oc.$postfix;
				$postfix = rol($postfix);
				push @orientCode, $oc.$postfix;
				next PREFIX;
			}

			# face piece on B
			push @orientCode, $oc.$postfix;
			next PREFIX;
		}

		if ($prefix->[0] == 1) {
			push @orientCode, "$prefix->[0]-$prefix->[1]-$prefix->[2]-l";
			next PREFIX;
		}

		if ($prefix->[0] == $size) {
			push @orientCode, "$prefix->[0]-$prefix->[1]-$prefix->[2]-r";
			next PREFIX;
		}
	}

	return \@orientCode;
}

sub getOrientCodeNumber {
	my $oc = shift;
	my (%mapoc2n, %mapn2oc);

	for my $i (0 .. $#$oc) {
		$mapoc2n{$oc->[$i]} = $i;
		$mapn2oc{$i} = $oc->[$i];
	}

	return \%mapoc2n, \%mapn2oc;
} # seems ok

sub faceRotZ {
	my $face = shift;
	return "l" if ($face eq "b");
	return "b" if ($face eq "r");
	return "r" if ($face eq "f");
	return "f" if ($face eq "l");

	return $face;
}

sub faceRotZi {
	my $face = shift;
	return "b" if ($face eq "l");
	return "r" if ($face eq "b");
	return "f" if ($face eq "r");
	return "l" if ($face eq "f");

	return $face;
}

sub faceRotY {
	my $face = shift;
	return "l" if ($face eq "d");
	return "d" if ($face eq "r");
	return "r" if ($face eq "u");
	return "u" if ($face eq "l");

	return $face;
}

sub faceRotYi {
	my $face = shift;
	return "d" if ($face eq "l");
	return "r" if ($face eq "d");
	return "u" if ($face eq "r");
	return "l" if ($face eq "u");

	return $face;
}

sub faceRotX {
	my $face = shift;
	return "b" if ($face eq "d");
	return "d" if ($face eq "f");
	return "f" if ($face eq "u");
	return "u" if ($face eq "b");

	return $face;
}

sub faceRotXi {
	my $face = shift;
	return "d" if ($face eq "b");
	return "f" if ($face eq "d");
	return "u" if ($face eq "f");
	return "b" if ($face eq "u");

	return $face;
}

sub RotZ {
	my ($x, $y, $z) = @_;
	($x, $y) = ($size + 1 - $y, $x);

	return ($x, $y, $z);
}

sub RotZi {
	my ($x, $y, $z) = @_;
	($x, $y) = ($y, $size + 1 - $x);

	return ($x, $y, $z);
}

sub RotY {
	my ($x, $y, $z) = @_;
	return RotZ($z, $x, $y);
}

sub RotYi {
	my ($x, $y, $z) = @_;
	return RotZi($z, $x, $y);
}

sub RotX {
	my ($x, $y, $z) = @_;
	return RotZ($y, $z, $x);
}

sub RotXi {
	my ($x, $y, $z) = @_;
	return RotZi($y, $z, $x);
}


# Given an oc, calculate the oc under action D
sub D {
	my $oc = shift;
	my @f = split '-', $oc;

	return $oc if ($f[-1] !~ /d/);

	if (@f == 1) {
		# corner piece
		return faceRotZ(substr($oc, 0, 1)).faceRotZ(substr($oc, 1, 1)).faceRotZ(substr($oc, 2, 1));
	}
	else {
		# coords
		my $newoc = join("-", RotZ(@f[0, 1, 2]))."-";

		# faces
		for (my $i = 0; $i < length($f[-1]); $i++) {
			$newoc .= faceRotZ( substr($f[-1], $i, 1) );
		}

		return $newoc;
	}
}

sub U {
	my $oc = shift;
	my @f = split '-', $oc;

	return $oc if ($f[-1] !~ /u/);

	if (@f == 1) {
		return faceRotZi(substr($oc, 0, 1)).faceRotZi(substr($oc, 1, 1)).faceRotZi(substr($oc, 2, 1));
	}
	else {
		# coords
		my $newoc = join("-", RotZi(@f[0, 1, 2]))."-";

		# faces
		for (my $i = 0; $i < length($f[-1]); $i++) {
			$newoc .= faceRotZi( substr($f[-1], $i, 1) );
		}

		return $newoc;
	}
}

sub L {
	my $oc = shift;
	my @f = split '-', $oc;

	return $oc if ($f[-1] !~ /l/);

	if (@f == 1) {
		# corner piece
		return faceRotX(substr($oc, 0, 1)).faceRotX(substr($oc, 1, 1)).faceRotX(substr($oc, 2, 1));
	}
	else {
		# coords
		my $newoc = join("-", RotX(@f[0, 1, 2]))."-";

		# faces
		for (my $i = 0; $i < length($f[-1]); $i++) {
			$newoc .= faceRotX( substr($f[-1], $i, 1) );
		}

		return $newoc;
	}
}

sub R {
	my $oc = shift;
	my @f = split '-', $oc;

	return $oc if ($f[-1] !~ /r/);

	if (@f == 1) {
		return faceRotXi(substr($oc, 0, 1)).faceRotXi(substr($oc, 1, 1)).faceRotXi(substr($oc, 2, 1));
	}
	else {
		# coords
		my $newoc = join("-", RotXi(@f[0, 1, 2]))."-";

		# faces
		for (my $i = 0; $i < length($f[-1]); $i++) {
			$newoc .= faceRotXi( substr($f[-1], $i, 1) );
		}

		return $newoc;
	}
}

sub F {
	my $oc = shift;
	my @f = split '-', $oc;

	return $oc if ($f[-1] !~ /f/);

	if (@f == 1) {
		# corner piece
		return faceRotY(substr($oc, 0, 1)).faceRotY(substr($oc, 1, 1)).faceRotY(substr($oc, 2, 1));
	}
	else {
		# coords
		my $newoc = join("-", RotY(@f[0, 1, 2]))."-";

		# faces
		for (my $i = 0; $i < length($f[-1]); $i++) {
			$newoc .= faceRotY( substr($f[-1], $i, 1) );
		}

		return $newoc;
	}
}

sub B {
	my $oc = shift;
	my @f = split '-', $oc;

	return $oc if ($f[-1] !~ /b/);

	if (@f == 1) {
		return faceRotYi(substr($oc, 0, 1)).faceRotYi(substr($oc, 1, 1)).faceRotYi(substr($oc, 2, 1));
	}
	else {
		# coords
		my $newoc = join("-", RotYi(@f[0, 1, 2]))."-";

		# faces
		for (my $i = 0; $i < length($f[-1]); $i++) {
			$newoc .= faceRotYi( substr($f[-1], $i, 1) );
		}

		return $newoc;
	}
}

sub strList {
	my $f = shift;
	my $s = "(";
	for (my $i = 0; $i < @$f; $i++) {
		if ($i < $#$f) {
			$s .= "$f->[$i], ";
		}
		else {
			$s .= "$f->[$i]";
		}
	}

	$s .= ")";

	return $s;
}

sub printTest {
	my $strTest = shift;
	my $totalSpace = 60;
	my $leftSpace = int(($totalSpace - length($strTest))/2);
	my $rightSpace = $totalSpace - length($strTest) - $leftSpace;

	my $title = "*" x $leftSpace;
	$title .= $strTest;
	$title .= "*" x $rightSpace;

	print $title, "\n";
}

sub validMove {
	my $move = shift;

	if ($move eq "U" || $move eq "D" ||
	    $move eq "L" || $move eq "R" ||
		$move eq "F" || $move eq "B") {

		return 1;
	}
	else {
		return 0;
	}
}

sub getPerm {
	my $move = shift;
	die "$move is not a valid move!\n" if (! validMove($move));

	my %visited;
	my ($perm, $cyc) = ([], []);

	for my $oc (@$pieceOrientCode) {
		my $currOc = $oc;

		while (! $visited{$currOc}) {
			push @$cyc, $oc2n->{$currOc};
			$visited{$currOc} = 1;

			$currOc = U($currOc) if ($move eq "U");
			$currOc = D($currOc) if ($move eq "D");
			$currOc = L($currOc) if ($move eq "L");
			$currOc = R($currOc) if ($move eq "R");
			$currOc = F($currOc) if ($move eq "F");
			$currOc = B($currOc) if ($move eq "B");
		}

		if (@$cyc > 1) {
			push @$perm, $cyc;
			$cyc = [];
		}
	}

	return $perm;
}

sub test {
	# generatePieceOrientCode
	printTest("generatePieceOrientCode");
	$pieceOrientCode = generatePieceOrientCode;
	print Dumper( $pieceOrientCode );

	# getOrientCodeNumber
	printTest("getOrientCodeNumber");
	($oc2n, $n2oc) = getOrientCodeNumber($pieceOrientCode);
	print Dumper( $oc2n );
	print Dumper( $n2oc );

	# strList
	printTest("strList");
	my @f = (1, 2, 3);
	print strList(\@f), "\n";

	# RotZ
	printTest("RotZ");
	print strList(\@f), "-->", strList([RotZ(@f)]), "\n";
	@f = (1, 1, 1);
	print strList(\@f), "-->", strList([RotZ(@f)]), "\n";
	@f = (2, 1, 3);
	print strList(\@f), "-->", strList([RotZ(@f)]), "\n";
	$size = 4;
	@f = (2, 4, 3);
	print strList(\@f), "-->", strList([RotZ(@f)]), "\n";
	@f = (2, 2, 4);
	print strList(\@f), "-->", strList([RotZ(@f)]), "\n";
	@f = (2, 3, 1);
	print strList(\@f), "-->", strList([RotZ(@f)]), "\n";
	$size = 3;
	@f = (1, 2, 3);
	print strList(\@f), "-->", strList([RotZ(@f)]), "-->", strList([RotZ(RotZ(@f))]), "-->", strList([RotZ(RotZ(RotZ(@f)))]), "-->", strList([RotZ(RotZ(RotZ(RotZ(@f))))]), "\n";

	# RotZi
	printTest("RotZi");
	print strList(\@f), "-->", strList([RotZi(@f)]), "\n";
	@f = (1, 1, 1);
	print strList(\@f), "-->", strList([RotZi(@f)]), "\n";
	$size = 4;
	@f = (2, 4, 3);
	print strList(\@f), "-->", strList([RotZi(@f)]), "\n";
	@f = (2, 2, 4);
	print strList(\@f), "-->", strList([RotZi(@f)]), "\n";
	@f = (2, 3, 1);
	print strList(\@f), "-->", strList([RotZi(@f)]), "\n";
	$size = 3;
	@f = (1, 2, 3);
	print strList(\@f), "-->", strList([RotZi(@f)]), "-->", strList([RotZi(RotZi(@f))]), "-->", strList([RotZi(RotZi(RotZi(@f)))]), "-->", strList([RotZi(RotZi(RotZi(RotZi(@f))))]), "\n";

	# D
	printTest("D");
	my $oc = "ufl";
	print $oc, "--D-->", D($oc), "\n";
	$oc = "2-1-3-fu";
	print $oc, "--D-->", D($oc), "\n";
	$oc = "3-1-2-fr";
	print $oc, "--D-->", D($oc), "\n";
	$oc = "2-3-2-b";
	print $oc, "--D-->", D($oc), "\n";

	# U
	printTest("U");
	$oc = "ufl";
	print $oc, "--U-->", U($oc), "\n";
	$oc = "2-1-3-fu";
	print $oc, "--U-->", U($oc), "\n";
	$oc = "3-1-2-fr";
	print $oc, "--U-->", U($oc), "\n";
	$oc = "2-3-2-b";
	print $oc, "--U-->", U($oc), "\n";

	# L
	printTest("L");
	$oc = "ufl";
	print $oc, "--L-->", L($oc), "\n";
	$oc = "2-1-3-fu";
	print $oc, "--L-->", L($oc), "\n";
	$oc = "3-1-2-fr";
	print $oc, "--L-->", L($oc), "\n";
	$oc = "2-3-2-b";
	print $oc, "--L-->", L($oc), "\n";

	# R
	printTest("R");
	$oc = "ufl";
	print $oc, "--R-->", R($oc), "\n";
	$oc = "2-1-3-fu";
	print $oc, "--R-->", R($oc), "\n";
	$oc = "3-1-2-fr";
	print $oc, "--R-->", R($oc), "\n";
	$oc = "2-3-2-b";
	print $oc, "--R-->", R($oc), "\n";

	# F
	printTest("F");
	$oc = "ufl";
	print $oc, "--F-->", F($oc), "\n";
	$oc = "2-1-3-fu";
	print $oc, "--F-->", F($oc), "\n";
	$oc = "3-1-2-fr";
	print $oc, "--F-->", F($oc), "\n";
	$oc = "2-3-2-b";
	print $oc, "--F-->", F($oc), "\n";

	# B
	printTest("B");
	$oc = "ufl";
	print $oc, "--B-->", B($oc), "\n";
	$oc = "2-1-3-fu";
	print $oc, "--B-->", B($oc), "\n";
	$oc = "3-1-2-fr";
	print $oc, "--B-->", B($oc), "\n";
	$oc = "2-3-2-b";
	print $oc, "--B-->", B($oc), "\n";

	my $permd = getPerm("D");
	print pretty($permd), "\n";
}

test;
1;
