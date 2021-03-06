#!/usr/bin/perl -w

use strict;

if ((scalar @ARGV != 1) || ((lc($ARGV[0]) ne "mask") && (lc($ARGV[0]) ne "no_mask"))) {
	print "usage: $0 {mask|no_mask}\n";
	print "where no_mask does not employ an extra mask (recommended: mask should be encoded in the image)\n";
	exit(1);
}

print "# generated with $0 $ARGV[0]\n";

my $input = '/net/cv/illum/multi_michael/gt_pw/';
my $output_GW = '/disks/data1/riess/mimorem/table_michael/single/gw/';
my $output_TAN = '/disks/data1/riess/mimorem/table_michael/single/tan/';

my $mask_dir = '/net/cv/illum/multi_michael/mask/';

my $bin1 = '/disks/data1/riess/code/build/bin/vole gwOrig';
my $bin2 = '/disks/data1/riess/code/build/bin/vole tanOrig';

my @image = `ls ${input}/*_norm.png`;

my @N = (0, 1, 2);
my @P = (-1, 1, 2);
my @S = (0, 1);

foreach my $img_full(@image) {
	chomp($img_full);
	my $img = $img_full;
	$img =~ s/^.*\/(.+?\.png)$/$1/;

	my ($mask) = getSegAndMask($img);

	my $out = getOutput2($img);
	if (lc($ARGV[0]) eq "mask") {
		print "$bin2 --img.image $img_full --mask $mask -O $out\n";
	} else {
		print "$bin2 --img.image $img_full -O $out\n";
	}

	foreach my $n(@N) {
		foreach my $p(@P) {
			foreach my $s(@S) {
				$out = getOutput($img, $n, $p, $s);
				if (lc($ARGV[0]) eq "mask") {
					print "$bin1 --img.image $img_full --mask $mask --n $n --p $p --sigma $s -O $out\n";
				} else {
					print "$bin1 --img.image $img_full --n $n --p $p --sigma $s -O $out\n";
				}
			}
		}
	}
}

sub getSegAndMask {
	my $img = shift;

	my ($scene) = ($img =~ /^([^_]+)_/);
	return ($mask_dir . "/" . $scene ."_mask.pbm");
}

sub getOutput {
	my ($img, $n, $p, $s) = @_;
	my ($without_extension) = ($img =~ /^([^\.]+)\./);
	return $output_GW . '/' . $without_extension . '_' . $n . '_'. $p . '_' . $s . ".png";
}

sub getOutput2 {
	my ($img) = @_;
	my ($without_extension) = ($img =~ /^([^\.]+)\./);
	return $output_TAN . '/' . $without_extension . ".png";
}



