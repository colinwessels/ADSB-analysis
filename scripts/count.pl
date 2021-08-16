#!/usr/local/bin/perl
use strict;
use warnings;
use Date::Parse;
use POSIX;

#usage: perl count.pl [a=eval altitude] startdate enddate data_dir output_file
#example: perl count.pl a 20200101 20200101 /home/colin/example-project/data/ /home/colin/example-project/results/count.dat

#This program requires the 3:0:1 file and will count how many unique hardware identifiers are recieved.

my @dates; #Array holding all dates to count
my $total = 0; #just the total number of hwids in the time period
my $totalalts = 0; #for averaging the averages.
my $totaltotalairportplanes = 0; #number of airport planes from each day summed.
my %dayofweek; #Holds the date in yyyymmdd format as key and the corresponding day of week as value
my $counter = 0; #Counter of what to divide totalalt by to get avg alt

my $doaltitude = "x";
if ($ARGV[0] eq "a") {$doaltitude = shift};

if ($ARGV[0] eq "") {die "enter date range"};
if ($ARGV[1] eq "") {die "enter end date"};
my $Sdate = $ARGV[0]; #This block adds each day in the start and end date range to an array.
my $Stime = str2time($Sdate); #srt2time converts the date into unix timestamp $Stime
my $Edate = $ARGV[1];
my $Etime = str2time($Edate);
my $datadir = $ARGV[2];
my $output = $ARGV[3];
if (-d $output) {$output = "$output/${Sdate}-${Edate}count.dat";}

while($Stime <= $Etime) {
	my $ymd = POSIX::strftime('%Y%m%d', localtime($Stime)); #converts $Stime back into yyyymmdd format
	push @dates, $ymd;
	$dayofweek{$ymd} = POSIX::strftime('%a', localtime($Stime)); #Assigns the day of week corresponding to $Stime to the hash
	$Stime = $Stime +24*60*60; #Adds one day to unix timestamp
}

sub count {
	my $date = shift;
	my $if = "$datadir/$date/198.202.124.3-HPWREN:MW-ADSB:3:1:0"; #WON'T WORK WITH wc-adsb
	my %list; #This hash holdes the hwID as a key and 1 as the value
	my %AirportPlanes;
	my $totalalt = 0;
	my $maxalt = 0;
	my $minalt = 0;
	my $avgalt = 0;
	my %results;

	open(my $data, "<", $if) or die("Failed to open 3:1:0 data file for $date\n");
	while(<$data>) {
		my @pieces = split(" ", $_);
		my $msg = $pieces[3];
		@pieces = split(",", $msg);	
		my $hardwareID = $pieces[4];
		my $alt = $pieces[11];
		my $lat = $pieces[14];
		my $lon = $pieces[15];
		
		unless($AirportPlanes{$hardwareID}) {
			if ($alt && $lat && $lon) {
				if($lon > -117.208267 and $lon < -117.171544 and $lat > 32.728620 and $lat < 32.739223 and $alt < 700) { #Check if plane is inside SAN airspace
					$AirportPlanes{$hardwareID} = "SAN";
				}
			}
		}
		
		$list{$hardwareID} = 1; #When a hwID is repeated, it overwrites the old one so none are duplicated.
		
		if ($doaltitude eq 'a' and $alt ne "") {
			$totalalt = $alt + $totalalt;
			$counter++;
	
			if ($counter == 1 or $alt < $minalt) {$minalt = $alt};
			if ($alt > $maxalt) {$maxalt = $alt};
		}
	}
	
	if ($doaltitude eq 'a') {$avgalt = ($totalalt / $counter)};
	close $data;

	foreach my $airport (values %AirportPlanes) {
		$results{"number-of-$airport-planes"}++;
		$results{'number-of-any-airport-planes'}++; #This assumes a plane is at only one airport
	}
	
	$results{'total-number-of-planes'} = scalar(keys %list);
	$results{'minalt'} = $minalt;
	$results{'maxalt'} = $maxalt;
	$results{'avgalt'} = $avgalt;
	
	return %results
}

printf "%8s : %-13s : %7s : %20s", "[Date]", "[Day of week]", "[Count]", "[Planes at airports]";
if ($doaltitude eq 'a') {printf " : %8s : %8s : %8s", "[MinAlt]", "[MaxAlt]", "[AvgAlt]"};
print "\n";
open(my $OF, ">", $output) or die "Failed to open output file: $!";
foreach my $date (@dates) {
	my %results = count($date);
	my $tally = $results{'total-number-of-planes'};
	my $maxalt = $results{'maxalt'};
	my $avgalt = $results{'avgalt'};
	my $minalt = $results{'minalt'};
	my $totalairportplanes = $results{'number-of-any-airport-planes'};
	
	#Printing to cmd line
	printf "%8d : %-13s : %7d : %20d", $date, $dayofweek{$date}, $tally, $totalairportplanes;
	if ($doaltitude eq 'a') {printf " : %8d : %8d : %8d", $minalt, $maxalt, $avgalt};
	print "\n";
	
	#Printing to resutls file
	my $dateformatted = POSIX::strftime('%Y-%m-%d', localtime(str2time($date))); #converts date to unix time, then back to normal date but with -dashes-
	print $OF "$dateformatted,$dayofweek{$date},$tally,$totalairportplanes";
	if ($doaltitude eq 'a') {print $OF ",$minalt,$maxalt,$avgalt"};
	print $OF "\n";
	
	$total = $total + $tally;
	$totalalts = $totalalts + $avgalt;
	$totaltotalairportplanes = $totaltotalairportplanes + $totalairportplanes;
}

my $days = scalar (@dates);
my $finalavgalt = $totalalts / $days;
my $avgairportplanes = $totaltotalairportplanes / $days;
print "Total: $days days, $total planes, $avgairportplanes planes at airports on average";
if ($doaltitude eq 'a') {printf ", average altitude of %d", $finalavgalt};
print "\n";