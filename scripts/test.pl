#!/usr/bin/perl
use strict;
use warnings;
use Date::Parse;
use POSIX;
# End of setup

my @dates; #Array holding all dates to count
my $total = 0; #just the total number of hwids in the time period
my $totalalts = 0; #for averaging the averages.
my $totaltotalairportplanes = 0; #number of airport planes from each day summed.
my %dayofweek; #Holds the date in yyyymmdd format as key and the corresponding day of week as value
my $counter = 0; #Counter of what to divide totalalt by to get avg alt

#print STDERR "Enter start date (yyyymmdd):"; #This block querys for the start and end dates and adds each day in the range to an array.
my $Sdate = "20200205";
chomp $Sdate;
my $Stime = str2time($Sdate); #srt2time converts the date into unix timestamp $Stime
#print STDERR "Enter end date:";
my $Edate = "20200205";
chomp $Edate;
my $Etime = str2time($Edate);
#print STDERR "\n";


while($Stime <= $Etime) {
	my $ymd = POSIX::strftime('%Y%m%d', localtime($Stime)); #converts $Stime back into yyyymmdd format
	push @dates, $ymd;
	$dayofweek{$ymd} = POSIX::strftime('%a', localtime($Stime)); #Assigns the day of week corresponding to $Stime to the hash
	$Stime = $Stime +24*60*60; #Adds one day to unix timestamp
}

sub count {
	my $date = shift;
	my $if = "/home/colin/example-project/data/$date/198.202.124.3-HPWREN:MW-ADSB:3:1:0"; #WON'T WORK WITH wc-adsb
	my %list; #This hash holdes the hwID as a key and 1 as the value
	my %AirportPlanes;
	my $totalalt = 0;
	my $maxalt = 0;
	my $minalt = 0;
	my $avgalt = 0;
	my %results;

	open(my $OF, ">", "/home/colin/example-project/results/count.txt") or die "Failed to open output file: $!";
	open(my $data, "<", $if) or die("Failed to open 3:1:0 data file for $date\n");
	while(<$data>) {
		my @pieces = split(" ", $_);
		my $msg = $pieces[3];
		@pieces = split(",", $msg);	
		my $alt = $pieces[11];
		print $OF "$alt\n";
		#print "$alt\n";
	}
	close $data;
	
#	if ($doaltitude eq 'a') {
#		$if = "/home/colin/example-project/data/$date/198.202.124.3-HPWREN:MW-ADSB:3:1:0";
#		open(my $data3, "<", $if) or die("Failed to open 3:1:0 data file for $date\n");
#		while(<$data3>) {
#			my @pieces = split(" ", $_);
#			my $msg = $pieces[3];
#			@pieces = split(",", $msg);
#			my $alt = $pieces[11];
#			next if ($pieces[11] eq "");
#			
#			$totalalt = $alt + $totalalt;
#			$counter++;
#	
#			if ($counter == 1 or $alt < $minalt) {$minalt = $alt};
#			if ($alt > $maxalt) {$maxalt = $alt};
#		}
#		$avgalt = ($totalalt / $counter);
#		close $data3;
#	}
}
foreach my $date (@dates) {
	count($date);
}