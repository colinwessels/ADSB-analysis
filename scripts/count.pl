#!/usr/local/bin/perl
use strict;
use warnings;
use Date::Parse;
use POSIX;

#This program requires the 1:0:1 file and will count how many unique hardware identifiers are recieved.

my %tallys; #Tallys holds the date as the key and the count as the value
my @dates; #Array holding all dates to count
my $total = 0; #just the total number of hwids in the time period
my %dayofweek; #Holds the date in yyyymmdd format as key and the corresponding day of week as value

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

	open(my $data, "<", $if) or die("Failed to open data file for $date\n");
	while(<$data>) {
		my @pieces = split(" ", $_);
		my $msg = $pieces[3];
		@pieces = split(",", $msg);
		my $hardwareID = $pieces[4];
		$list{$hardwareID} = 1; #When a hwID is repeated, it overwrites the old one so none are duplicated.
	}
	
	return scalar (keys %list); #scalar countes the length of array, keys returns an array of all the keys in list.
}

print '[Date] : [Day of week] : [Count]';
print "\n";
print "______________\n";
foreach my $date (@dates) {
	my $tally = count($date); #$tally and $tallys are very similar
	$tallys{$date} = $tally; #Stores the count for that date in the hash
	print "$date : $dayofweek{$date} : $tally\n";
	$total = $total + $tally;
}

my $days = scalar (@dates);
print "Total ($days days) : $total\n";