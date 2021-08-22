#!/usr/bin/perl
use strict;
use warnings;
use Date::Parse;
use POSIX;
# End of setup

#usage: perl better_histo.pl startdate enddate data_directory output_file.dat

my @dates; #Array holding all dates to count
my $total = 0; #just the total number of hwids in the time period
my $totalalts = 0; #for averaging the averages.
my $totaltotalairportplanes = 0; #number of airport planes from each day summed.
my %dayofweek; #Holds the date in yyyymmdd format as key and the corresponding day of week as value
my $counter = 0; #Counter of what to divide totalalt by to get avg alt
my $timebinsize = 86400; #in sec
my $altbinsize = 10000; #in ft
my $timebinoffset = 0; #works for daylight savings time, 8 hrs for std time.

my $date = $ARGV[0];  #eg. 20200101
my $datadir = $ARGV[1];
my $output = $ARGV[2];

$ENV{TZ}="US/Pacific";

if ($timebinsize == 86400) { #calculates time bin offset
	die unless $date =~ /(\d\d\d\d)(\d\d)(\d\d)/;
	my $t1 = str2time("$1-$2-$3 00:00:00 UTC");
	my $t2 = str2time("$1-$2-$3 00:00:00 ");
	$timebinoffset = $t2-$t1;
	print STDERR "timebinoffset is $timebinoffset\n";
}

sub count {
	my $date = shift;
	if (-d $output) {$output = "$output/$date.dat"} #if no filename is specified, create a .dat file
	my $if = "$datadir/$date/198.202.124.3-HPWREN:MW-ADSB:3:1:0"; #WON'T WORK WITH wc-adsb
	my $list;
	my %AirportPlanes;
	my $totalalt = 0;
	my $maxalt = 0;
	my $minalt = 0;
	my $avgalt = 0; 
	my %alts;

	open(my $OF, ">", $output) or die "Failed to open output file: $!";
	open(my $data, "<", $if) or die("Failed to open 3:1:0 data file '$if'\n");
	while(<$data>) {
		my @pieces = split(" ", $_);
		my $msg = $pieces[3];
		my $timestamp = int(($pieces[2]-$timebinoffset)/$timebinsize)*$timebinsize+$timebinoffset;
		
		@pieces = split(",", $msg);	
		next if $pieces[11] eq "";
		my $alt = int($pieces[11]/$altbinsize)*$altbinsize;
		my $hardwareID = $pieces[4];
		#print STDERR "line $.\n" if $. %1000 == 0;
		
		$list->{$timestamp}->{$hardwareID}=$alt;
		$alts{$alt}=1;
	}
	close $data;
	
	my $altsbyhwid;
	
	foreach my $t (keys %$list) {
		foreach my $id (keys %{$list->{$t}}) {
			my $alt = $list->{$t}->{$id};
			$altsbyhwid->{$t}->{$alt}++;
		}
	}
	
	foreach my $t (sort {$a<=>$b} keys %$altsbyhwid) {
		printf $OF "%s", POSIX::strftime("%H:%M",localtime($t));
		foreach my $alt (sort {$a<=>$b} keys %alts) {
			$altsbyhwid->{$t}->{$alt} += 0;
			printf $OF "\t%d", $altsbyhwid->{$t}->{$alt};
		}
		print $OF "\n";
	}
}

count($date);