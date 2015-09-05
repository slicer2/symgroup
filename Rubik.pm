package Rubik;

use strict;
use warnings;
use Exporter;
use Data::Dumper;
use List::Util;
use List::MoreUtils;

our @ISA = qw(Exporter);
our @EXPORT = qw();

our $size = 3;

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

#sub Dface {
#	my $face = shift;
#	return "l" if ($face eq "b");
#	return "b" if ($face eq "r");
#	return "r" if ($face eq "f");
#	return "f" if ($face eq "l");
#
#	return $face;
#}
#
#sub Dxyz {
#	my ($x, $y, $z) = @_;
#
#	if ($z == 1) {
#		$x = $size+1-$y;
#		$y = 1;
#	}
#	else {
#		return "$x-$y-$z";
#	}
#}
#
#sub Dy {
#}
#
## Given an oc, calculate the oc under action D
#sub D {
#	my $oc = shift;
#	my @f = split ' ', $oc;
#	if (@f == 1) {
#		# corner piece
#		return Dface(substr($oc, 0, 1)).Dface(substr($oc, 1, 1)).Dface(substr($oc, 2, 1));
#	}
#	else {
#		return join("-", Dx(f[0]), Dy(f[1]), f[2], Dface(substr($oc, 0, 1)).Dface(substr($oc, 1, 1)).Dface(substr($oc, 2, 1)));
#	}
#}

sub test {
	my $pieceOrientCode = generatePieceOrientCode;
	#print Dumper( $pieceOrientCode );

	my ($oc2n, $n2oc) = getOrientCodeNumber($pieceOrientCode);

	print Dumper( $oc2n );

	print Dumper( $n2oc );
}

test;
1;
