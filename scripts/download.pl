use strict;
use warnings;
use Date::Parse;
use POSIX;
use Getopt::Long;
#usage: perl download.pl [--increment=n] [--directory=path] [-t=test] [-d=distribution] [-h=histogram] startdate enddate

#default variables
my $increment = 1;
my $dir = "/home/colin/example-project/data";
my $test = 0;
my $dodistro;
my $dobetterhisto;

GetOptions ("increment=i" => \$increment,
			"directory=s" => \$dir,
			"t" => \$test,
			"d" => \$dodistro,
			"h" => \$dobetterhisto)
or die("usage: $0 [--increment=n] [--directory=path] [-t=test] [-d=distribution] [-h=histogram] startdate enddate\n");

my $startdate = shift;
my $enddate = shift;
unless (defined $startdate and defined $enddate) {die "usage: $0 [--increment=n] [--directory=path] [-t=test] [-d=distribution] [-h=histogram] startdate enddate\n"};
unless ($startdate <= $enddate) {die "End date is after start date";}

chdir($dir) or die;
print STDERR "Downloading to "; 
system('pwd');

sub get_file {
	my $date = shift;
	my $file = shift;
	my $year = POSIX::strftime('%Y', localtime(str2time($date)));
	my $url = "https://hpwren.ucsd.edu/TM/Sensors/Data/$year/$date/$file";
	my $path = "$date/$file";

	print STDERR "checking for $path... ";
	if (-s $path) {print STDERR "file already exists.\n"; return;} #end sub if file exists
	print STDERR "no file.\n";
	unless (-d "$date") {mkdir "$date" or die;}
	
	if ($year >= 2021) {$url = "https://hpwren.ucsd.edu/TM/Sensors/Data/$date/$file"}; # effective 2021/01/01, year is removed from url
	print STDERR "command: wget --compression=auto -P $date/ $url\n";
	if ($test) {print STDERR "Test complete, skipping download\n"; return;}
	system "wget --compression=auto -P $date/ $url";
}

my $curtime = str2time($startdate);
my $endtime = str2time($enddate);

while ($curtime <= $endtime) {
	my $curdate = POSIX::strftime('%Y%m%d', localtime($curtime));
	get_file($curdate, '198.202.124.3-HPWREN:MW-ADSB:1:1:0');
	get_file($curdate, '198.202.124.3-HPWREN:MW-ADSB:3:1:0');
	if (not $test and $dodistro) {system "cd $dir/../results/altdist && make DATE=$curdate";}
	if (not $test and $dobetterhisto) {system "cd $dir/../results/betterhisto && make DATE=$curdate";}
} continue {
	$curtime = $curtime + $increment*86400;
}