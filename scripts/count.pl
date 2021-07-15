#!/usr/local/bin/perl
use strict;
use warnings;
use Date::Parse;
use POSIX;

#This program requires the 1:0:1 file and will count how many unique hardware identifiers are recieved.

my %tallys; #Tallys holds the date as the key and the count as the value
my @dates; #Array holding all dates to count
my $total = 0; #just the total number of hwids in the time period
my $totalalts = 0; #for averaging the averages.
my %dayofweek; #Holds the date in yyyymmdd format as key and the corresponding day of week as value
my $counter = 0; #Counter of what to divide totalalt by to get avg alt

my $doaltitude = shift; #just add "a" to end of perl command to evaluate altitude data.
$doaltitude = "x" unless defined $doaltitude;

print "Enter start date (yyyymmdd):"; #This block querys for the start and end dates and adds each day in the range to an array.
my $Sdate = <STDIN>;
chomp $Sdate;
my $Stime = str2time($Sdate); #srt2time converts the date into unix timestamp $Stime
print "Enter end date:";
my $Edate = <STDIN>;
chomp $Edate;
my $Etime = str2time($Edate);


while($Stime <= $Etime) {
	my $ymd = POSIX::strftime('%Y%m%d', localtime($Stime)); #converts $Stime back into yyyymmdd format
	push @dates, $ymd;
	$dayofweek{$ymd} = POSIX::strftime('%a', localtime($Stime)); #Assigns the day of week corresponding to $Stime to the hash
	$Stime = $Stime +24*60*60; #Adds one day to unix timestamp
}

sub count {
	my $date = shift;
	my $if = "/home/colin/example-project/data/$date/198.202.124.3-HPWREN:MW-ADSB:1:1:0"; #WON'T WORK WITH wc-adsb
	my %list; #This hash holdes the hwID as a key and 1 as the value
	my $totalalt = 0;
	my $maxalt = 0;
	my $minalt = 0;
	my $avgalt = 0;

	open(my $data, "<", $if) or die("Failed to open 1:1:0 data file for $date\n");
	while(<$data>) {
		my @pieces = split(" ", $_);
		my $msg = $pieces[3];
		@pieces = split(",", $msg);	
		my $hardwareID = $pieces[4];
		$list{$hardwareID} = 1; #When a hwID is repeated, it overwrites the old one so none are duplicated.	
	}
	close $data;
	
	if ($doaltitude eq 'a') {
		$if = "/home/colin/example-project/data/$date/198.202.124.3-HPWREN:MW-ADSB:3:1:0";
		open(my $data3, "<", $if) or die("Failed to open 3:1:0 data file for $date\n");
		while(<$data3>) {
			my @pieces = split(" ", $_);
			my $msg = $pieces[3];
			@pieces = split(",", $msg);
			my $alt = $pieces[11];
			next if ($pieces[11] eq "");
			
			$totalalt = $alt + $totalalt;
			$counter++;
	
			if ($counter == 1 or $alt < $minalt) {$minalt = $alt};
			if ($alt > $maxalt) {$maxalt = $alt};
		}
		$avgalt = ($totalalt / $counter);
		close $data3;
	}
	return
		scalar (keys %list), #scalar countes the length of array, keys returns an array of all the keys in list.
		$maxalt,
		$minalt,
		$avgalt;
}

print '[Date] : [Day of week] : [Count]';
if ($doaltitude eq 'a') {print ' : [MinAlt] : [MaxAlt] : [AvgAlt]'};
print "\n";
open(my $OF, ">", "/home/colin/example-project/results/count.txt") or die "Failed to open output file: $!";
foreach my $date (@dates) {
	my ($tally, $maxalt, $minalt, $avgalt) = count($date); #$tally and $tallys are very similar
	$tallys{$date} = $tally; #Stores the count for that date in the hash, I don't think this is actually necessary.
	
	#Printing to cmd line
	print "$date : $dayofweek{$date} : $tally";
	if ($doaltitude eq 'a') {printf " : %d : %d : %d", $minalt, $maxalt, $avgalt};
	print "\n";
	
	#Printing to resutls file
	my $dateformatted = POSIX::strftime('%Y-%m-%d', localtime(str2time($date))); #converts date to unix time, then back to normal date but with -dashes-
	print $OF "$dateformatted,$dayofweek{$date},$tally";
	if ($doaltitude eq 'a') {print $OF ",$minalt,$maxalt,$avgalt"};
	print $OF "\n";
	
	$total = $total + $tally;
	$totalalts = $totalalts + $avgalt;
}

my $days = scalar (@dates);
my $finalavgalt = $totalalts / $days;
print "Total ($days days) : $total";
if ($doaltitude eq 'a') {printf " : Average altitude of %d", $finalavgalt};
print "\n";