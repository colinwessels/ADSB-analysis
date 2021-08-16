#!/usr/bin/perl
use strict;
use warnings;

my $binsize = 1000;
my @dist;
while (<>) {
	chomp;
	next if ($_ eq "");
	next if ($_ < 0);
	my $bin = int($_/$binsize);
	$dist[$bin]++;
}

for my $i (0..$#dist) {
	$dist[$i] += 0;
	printf "%d %d\n", $i*$binsize, $dist[$i];
}