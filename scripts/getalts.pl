#!/usr/bin/perl 
use strict;
use warnings;
use Date::Parse;
use POSIX;
use Statistics::Descriptive;
# End of setup

#usage: perl getalts.pl startdate enddate data_directory output_file-alts.dat

my @dates; #Array holding all dates to count
my $total = 0; #just the total number of hwids in the time period
my $totalalts = 0; #for averaging the averages.
my $totaltotalairportplanes = 0; #number of airport planes from each day summed.
my %dayofweek; #Holds the date in yyyymmdd format as key and the corresponding day of week as value
my $counter = 0; #Counter of what to divide totalalt by to get avg alt

#print STDERR "Enter start date (yyyymmdd):"; #This block adds each day in the range to an array.
my $Sdate = $ARGV[0];
chomp $Sdate;
my $Stime = str2time($Sdate); #srt2time converts the date into unix timestamp $Stime
#print STDERR "Enter end date:";
my $Edate = $ARGV[1];
chomp $Edate;
my $Etime = str2time($Edate);
#print STDERR "\n";
my $datadir = $ARGV[2];
my $output = $ARGV[3];

unless (defined $Sdate and defined $Edate and defined $datadir and defined $output) {die "usage: perl getalts.pl startdate enddate data_directory output_file-alts.dat"};

while($Stime <= $Etime) {
	my $ymd = POSIX::strftime('%Y%m%d', localtime($Stime)); #converts $Stime back into yyyymmdd format
	push @dates, $ymd;
	$dayofweek{$ymd} = POSIX::strftime('%a', localtime($Stime)); #Assigns the day of week corresponding to $Stime to the hash
	$Stime = $Stime +24*60*60; #Adds one day to unix timestamp
}

sub count {
	my $date = shift;
	if (-d $output) {$output = "$output/$date-alts.dat"} #if no filename is specified, create a .dat file
	my $if = "$datadir/$date/198.202.124.3-HPWREN:MW-ADSB:3:1:0"; #WON'T WORK WITH wc-adsb
	my $list;
	my %AirportPlanes;
	my $totalalt = 0;
	my $maxalt = 0;
	my $minalt = 0;
	my $avgalt = 0; 
	my %results;

	open(my $OF, ">", $output) or die "Failed to open output file: $!";
	open(my $data, "<", $if) or die("Failed to open 3:1:0 data file for $date\n");
	while(<$data>) {
		my @pieces = split(" ", $_);
		my $msg = $pieces[3];
		@pieces = split(",", $msg);	
		my $alt = $pieces[11];
		my $hardwareID = $pieces[4];
		#print STDERR "line $.\n" if $. %1000 == 0;
		next if $alt eq "";
		if (not defined $list->{$hardwareID}) {$list->{$hardwareID}=Statistics::Descriptive::Full->new();}
		$list->{$hardwareID}->add_data($alt);
	}
	close $data;
	
	foreach my $k (keys %$list) {
		print $OF $list->{$k}->mean."\n";
	}
}
foreach my $date (@dates) {
	count($date);
}