# To run from perl cmd, do 'perl hvb-atc.pl [date] [minutes]

#!/usr/local/bin/perl

# ./sbs1-id.pl 20200511 MW-ADSB
use POSIX;

my $date = shift;
my $minutes = shift;

$dirname="/home/colin/example-project/data/$date";
#die "$dirname: $!" unless -d $dirname;

$site='MW-ADSB';
if($site eq ""){die "use sbs1-id.pl directory site"};

if($date eq "") {
	print "Enter date: \n";
	$date = <STDIN>;
	chomp $date;
}

$idtstamp=0;
$maxage=20;     # max age in seconds
$cw=0.0001;     # down column width/2
$sampnum=400;	# numbers of samples per object, tail length
#$timespanduration=40;	# lenght of red squares
$timespanduration=10;	# lenght of red squares
$dtime=10;	# delta time for clustering

#optional rectangle, or comment out all four min/max lines
#$minlat=34.073;
#$maxlat=34.077;
#$minlon=-118.63;
#$maxlon=-118.62;

$starttime=7*3600;		# number of seconds from beginning of file
$endtime=$starttime+($minutes*60);	# number of seconds from beginning of file


unless (open(ID,"$dirname/198.202.124.3-HPWREN:${site}:1:1:0")) { #Prompts user to change $site to wc-adsb if it fails to open file
 $site = 'wc-adsb';
 open(ID,"$dirname/198.202.124.3-HPWREN:${site}:1:1:0") || die("Cannot open input file $dirname/198.202.124.3-HPWREN:${site}:3:1:0");
}
open(IC,"$dirname/198.202.124.3-HPWREN:${site}:3:1:0") || die("Cannot open input file $dirname/198.202.124.3-HPWREN:${site}:3:1:0");

$OF = "/home/colin/example-project/results/$date.kml";
open(O,">$OF") || die "$OF: $!";
printf O "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
printf O "<kml xmlns=\"http://earth.google.com/kml/2.0\">\n";
printf O " <Document>\n";
printf O "  <description>Flight tracking data</description>\n";
printf O "\n";
printf O "  <LookAt id=\"ID\">\n";
printf O "   <longitude>-117.3</longitude>\n";
printf O "   <latitude>33.5</latitude>\n";
printf O "   <altitude>600000</altitude>\n";
printf O "   <heading>0</heading>\n";
printf O "   <tilt>0</tilt>\n";
printf O "   <range></range>\n";
printf O "   <altitudeMode>absolute</altitudeMode>\n";
printf O "  </LookAt>\n";
printf O "\n";
printf O "  <StyleMap id=\"561107\">\n";
printf O "   <Pair>\n";
printf O "    <key>normal</key>\n";
printf O "    <styleUrl>#E</styleUrl>\n";
printf O "   </Pair>\n";
printf O "   <Pair>\n";
printf O "    <key>highlight</key>\n";
printf O "    <styleUrl>#F</styleUrl>\n";
printf O "   </Pair>\n";
printf O "  </StyleMap>\n";
printf O "\n";
printf O "  <Style id=\"E\">\n";
printf O "   <IconStyle>\n";
printf O "    <scale>0.4</scale>\n";
printf O "    <Icon><href>http://hpwren.ucsd.edu/KML/Icons/8x8_s-red.png</href></Icon>\n";
printf O "   </IconStyle>\n";
printf O "   <LabelStyle>\n";
#printf O "    <scale>0</scale>\n";
printf O "   </LabelStyle>\n";
printf O "   <BalloonStyle>\n";
printf O "    <text>\$[description]</text>\n";
printf O "   </BalloonStyle>\n";
printf O "   <LineStyle>\n";
printf O "    <color>00000000</color>\n";
printf O "    <antialias>0</antialias>\n";
printf O "   </LineStyle>\n";
printf O "   <PolyStyle>\n";
printf O "    <color>00000000</color>\n";
printf O "    <fill>0</fill>\n";
printf O "    <outline>0</outline>\n";
printf O "   </PolyStyle>\n";
printf O "  </Style>\n";
printf O "\n";
printf O "  <Style id=\"F\">\n";
printf O "   <IconStyle>\n";
printf O "    <scale>1.0</scale>\n";
printf O "     <Icon><href>http://hpwren.ucsd.edu/KML/Icons/8x8_s-red.png</href></Icon>\n";
printf O "   </IconStyle>\n";
printf O "   <LabelStyle>\n";
printf O "   </LabelStyle>\n";
printf O "   <BalloonStyle>\n";
printf O "    <text>\$[description]</text>\n";
printf O "   </BalloonStyle>\n";
printf O "   <LineStyle>\n";
printf O "    <color>00000000</color>\n";
printf O "    <antialias>0</antialias>\n";
printf O "   </LineStyle>\n";
printf O "   <PolyStyle>\n";
printf O "    <color>00000000</color>\n";
printf O "    <fill>0</fill>\n";
printf O "    <outline>0</outline>\n";
printf O "   </PolyStyle>\n";
printf O "  </Style>\n";
printf O "\n";
printf O "  <Style id=\"ToGroundLow\">\n"; #diffeernt styles have different colors
printf O "   <LineStyle>\n";
printf O "    <color>7f0000ff</color>\n";
printf O "    <width>2</width>\n";
printf O "   </LineStyle>\n";
printf O "   <PolyStyle>\n";
printf O "    <color>5f0000ff</color>\n";
printf O "   </PolyStyle>\n";
printf O "  </Style>\n";
printf O "\n";
printf O "  <Style id=\"ToGroundMid\">\n";
printf O "   <LineStyle>\n";
printf O "    <color>7f00ff0d</color>\n";
printf O "    <width>2</width>\n";
printf O "   </LineStyle>\n";
printf O "   <PolyStyle>\n";
printf O "    <color>5f00ff0d</color>\n";
printf O "   </PolyStyle>\n";
printf O "  </Style>\n";
printf O "\n";
printf O "  <Style id=\"ToGroundHigh\">\n";
printf O "   <LineStyle>\n";
printf O "    <color>7fff0000</color>\n";
printf O "    <width>2</width>\n";
printf O "   </LineStyle>\n";
printf O "   <PolyStyle>\n";
printf O "    <color>5fff0000</color>\n";
printf O "   </PolyStyle>\n";
printf O "  </Style>\n";
printf O "\n";
printf O "  <Style id=\"AirToAir\">\n";
printf O "   <LineStyle>\n";
printf O "    <color>7f00ffff</color>\n";
printf O "    <width>4</width>\n";
printf O "   </LineStyle>\n";
printf O "   <PolyStyle>\n";
printf O "    <color>5f00ffff</color>\n";
printf O "   </PolyStyle>\n";
printf O "  </Style>\n";

sub StyleFromAltitude
{
	my $alt = shift;
 if($alt > 8500) {	#sets style based on alt -cw
   return "ToGroundHigh";
 } elsif($alt >= 5000 && $alt <= 8500) {
   return "ToGroundMid";
 } else {
   return "ToGroundLow";
 }
}

my $ICLINECNT = 0;
my $IDLINECNT = 0;
while(<IC>) {
	$ICLINECNT++;
#	printf STDERR "program line %d, IC line %d\n", __LINE__, $ICLINECNT;
 ($icorig,$icid,$ictstamp,$icparm,@r)=split(" ",$_);
 if($orgictstamp eq ""){
	 $orgictstamp=$ictstamp;
	 print STDERR "start time: ", POSIX::strftime('%F %T', localtime($orgictstamp)), "\n";
	 print STDERR "end time: ", POSIX::strftime('%F %T', localtime($orgictstamp+$endtime)), "\n";
	 }
 ($MSG,$TTP,$SID,$AID,$IDT,$FID,
  $GDT,$GTM,$LDT,$LTM,$CSN,$ALT,$GSP,$TRK,
  $LAT,$LON,$VRT,$SQK,$ALE,$EMG,$SPI,$IOG,@r)=split(",",$icparm); 
  	printf STDERR "\rIC %s ID %s", POSIX::strftime("%F %T", localtime($ictstamp)), POSIX::strftime("%F %T", localtime($ictstamp));


 if($ictstamp > $idtstamp){
  while(<ID>) {
	  $IDLINECNT++;
#	  printf STDERR "program line %d, ID line %d\n", __LINE__, $IDLINECNT;
   ($idorig,$idid,$idtstamp,$idparm,@r)=split(" ",$_);
   ($idMSG,$idTTP,$idSID,$idAID,$idIDT,$idFID,
    $idGDT,$idGTM,$idLDT,$idLTM,$idCSN,$idALT,$idGSP,$idTRK,
    $idLAT,$idLON,$idVRT,$idSQK,$idALE,$idEMG,$idSPI,$idIOG,@r)=split(",",$idparm);
	printf STDERR "\rIC %s ID %s", POSIX::strftime("%F %T", localtime($ictstamp)), POSIX::strftime("%F %T", localtime($ictstamp));
   if(($idTTP == 1)&&($idCSN ne "")){
    if($callsign{$idIDT} eq ""){
#     printf"new call sign for $idIDT: $idCSN\n";
     $callsign{$idIDT}=$idCSN;
    }elsif($callsign{$idIDT} ne $idCSN){
#     printf"new call sign for $idIDT, now: $idCSN was %s\n",$callsign{$idIDT};
     $callsign{$idIDT}=$idCSN;
    }
   if($idtstamp > $ictstamp){last;}
   }
  }
 }

#
 if($ictstamp < ($orgictstamp+$starttime)){next;}
 $ALT=$ALT*0.305;
 if($TTP == 3){
  if(($LAT ne "")&&($LON ne "")&&($ALT ne "")){
#    printf"1 $minlat : $LAT : $maxlat - $minlon : $LON : $maxlon\n";
   if((not defined $minlat)||(($LAT >= $minlat)&&($LAT <= $maxlat)&&($LON >= $minlon)&&($LON <= $maxlon))){
#    printf"$_";
#    printf"2 $minlat : $LAT : $maxlat - $minlon : $LON : $maxlon\n";
    $ix{$IDT}=++$ix{$IDT}%$sampnum;
    $latitude{$IDT,$ix{$IDT}}=$LAT;
    $longitude{$IDT,$ix{$IDT}}=$LON;
    $altitude{$IDT,$ix{$IDT}}=$ALT;
    $T{$IDT}=$ictstamp;
   }
  }
#  printf"$ictstamp - $IDT: $LAT - $LON - $ALT\n";
 }
 






 if($ictstamp >= ($oictstamp+$dtime)){
  foreach $key (sort(keys %T)){
#	  next unless($callsign{$key} eq 'FFT1150');
   if($T{$key} > ($ictstamp-$maxage)){
#    printf"$ictstamp - %s %s: %s, %s, %s\n",
#     $key,$callsign{$key},$latitude{$key,$ix{$key}},$longitude{$key,$ix{$key}},$altitude{$key,$ix{$key}};

    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat) = localtime($T{$key});
    $tstring=sprintf"%0.4d-%0.2d-%0.2dT%0.2d:%0.2d:%0.2d",
                     $year+1900,$mon+1,$mday, $hour,$min,$sec;
#printf"%s :  %s :\n", $T{$key}, $tstring;
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdat) = localtime($T{$key}+$timespanduration);
    $tstringend=sprintf"%0.4d-%0.2d-%0.2dT%0.2d:%0.2d:%0.2d",
                     $year+1900,$mon+1,$mday, $hour,$min,$sec;

    $pcnt++;
    if(($latitude{$key,$ix{$key}} ne "") && ($longitude{$key,$ix{$key}} ne "")){
     if($callsign{$key} eq ""){$callsign{$key}="unkn"};
#
    
#red line to ground
#place plus yellow line via old value(s)
     printf O "\n";
     printf O "  <Placemark>\n";
#     printf O "   <name>%s %s</name>\n",$callsign{$key},$altitude{$key,$ix{$key}}/0.305;
     printf O "   <name>%s</name>\n",$callsign{$key};
     printf O "   <TimeSpan>\n";
     printf O "   <begin>$tstring</begin>\n";
     printf O "   <end>$tstringend</end>\n";
     printf O "   </TimeSpan>\n";
     printf O "   <styleUrl>#561107</styleUrl>\n";
     printf O "   <Point>\n";
     printf O "    <altitudeMode>absolute</altitudeMode>\n";
     printf O "    <coordinates>%s,%s,%s</coordinates>\n",$longitude{$key,$ix{$key}},$latitude{$key,$ix{$key}},$altitude{$key,$ix{$key}};
     printf O "   </Point>\n";
     printf O "  </Placemark>\n";
#

     printf O "\n";
     printf O "  <Placemark>\n";
#	 printf STDERR "%s %f %s\n", $callsign{$key}, $altitude{$key,$ix{$key}}, StyleFromAltitude($altitude{$key,$ix{$key}});
     printf O "   <styleUrl>#%s</styleUrl>\n", StyleFromAltitude($altitude{$key,$ix{$key}});
     printf O "   <TimeSpan>\n";
     printf O "   <begin>$tstring</begin>\n";
     printf O "   <end>$tstringend</end>\n";
     printf O "   </TimeSpan>\n";
     printf O "   <Polygon>\n";
     printf O "    <extrude>1</extrude>\n";
     printf O "    <altitudeMode>absolute</altitudeMode>\n";
     printf O "    <outerBoundaryIs>\n";
     printf O "     <LinearRing>\n";
     printf O "      <extrude>1</extrude>\n";
     printf O "      <coordinates>\n";
     printf O "       %s,%s,%s\n",$longitude{$key,$ix{$key}}-$cw,$latitude{$key,$ix{$key}}-$cw,$altitude{$key,$ix{$key}};
     printf O "       %s,%s,%s\n",$longitude{$key,$ix{$key}}+$cw,$latitude{$key,$ix{$key}}-$cw,$altitude{$key,$ix{$key}};
     printf O "       %s,%s,%s\n",$longitude{$key,$ix{$key}}+$cw,$latitude{$key,$ix{$key}}+$cw,$altitude{$key,$ix{$key}};
     printf O "       %s,%s,%s\n",$longitude{$key,$ix{$key}}-$cw,$latitude{$key,$ix{$key}}+$cw,$altitude{$key,$ix{$key}};
     printf O "       %s,%s,%s\n",$longitude{$key,$ix{$key}}-$cw,$latitude{$key,$ix{$key}}-$cw,$altitude{$key,$ix{$key}};
     printf O "      </coordinates>\n";
     printf O "     </LinearRing>\n";
     printf O "    </outerBoundaryIs>\n";
     printf O "   </Polygon>\n";
     printf O "  </Placemark>\n";
#
     printf O "\n";
     printf O "  <Placemark>\n";
     printf O "   <styleUrl>#AirToAir</styleUrl>\n";
     printf O "   <TimeSpan>\n";
     printf O "   <begin>$tstring</begin>\n";
     printf O "   <end>$tstringend</end>\n";
     printf O "   </TimeSpan>\n";
     printf O "   <LineString>\n";
     printf O "    <extrude>0</extrude>\n";
     printf O "    <altitudeMode>absolute</altitudeMode>\n";
     printf O "    <coordinates>";
     for($i=0; $i<=($sampnum-1); $i++){
      $lix=$ix{$key}-$i;
      if($lix < 0){$lix=$lix+$sampnum;}
      if(($latitude{$key,$lix} ne "") && ($longitude{$key,$lix} ne "") && ($altitude{$key,$lix} ne "")){
       printf O " %s,%s,%s",$longitude{$key,$lix},$latitude{$key,$lix},$altitude{$key,$lix};
      }
     }
     printf O "    </coordinates>\n";
     printf O "   </LineString>\n";
     printf O "  </Placemark>\n";
#
    }
   }else{
    undef($T{$key});
    for($i=0; $i<=($sampnum-1); $i++){
     undef($latitude{$key,$i});
     undef($longitude{$key,$i});
     undef($altitude{$key,$i});
    }
   }
  }
  $oictstamp=$ictstamp;
 }
 
# terminate the program after n second
 if($ictstamp > ($orgictstamp+$endtime)){
	 print STDERR "reached endtime\n";
	 last;
	 }
}
#
printf O "\n";
printf O "  <!-- HPWREN Logo -->\n";
printf O "  <ScreenOverlay>\n";
printf O "   <name>HPWREN Logo</name>\n";
printf O "   <Icon>\n";
printf O "    <href>http://hpwren.ucsd.edu/images/hpwrenlogo-small.png</href>\n";
printf O "   </Icon>\n";
printf O "   <overlayXY x=\"1\" y=\"0\" xunits=\"fraction\" yunits=\"pixels\"/>\n";
printf O "   <screenXY x=\"0.82\" y=\"20\" xunits=\"fraction\" yunits=\"pixels\"/>\n";
printf O "   <rotationXY x=\"0\" y=\"0\" xunits=\"pixels\" yunits=\"pixels\"/>\n";
printf O "   <size x=\"0\" y=\"0\" xunits=\"pixels\" yunits=\"pixels\"/>\n";
printf O "  </ScreenOverlay>\n";

printf O " </Document>\n";
printf O "</kml>\n";
   
close(O);    
#system("/bin/zip -q new-sbs12all.kmz sbs12all.kml");

open(CS,">callsignmap.txt") || die("Cannot open output callsign file");
foreach $key (sort  (keys %callsign)){
 printf CS "%s\t%s\n",$key, $callsign{$key};
}
printf STDERR "Read %d lines from IC and %d lines from ID.\n", $ICLINECNT, $IDLINECNT;