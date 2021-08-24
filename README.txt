Reproduction Instructions by Colin Wessels

This folder is what I kept all my files in while working on this project. In the scripts folder,
you will find all of the perl scripts you can use. Some make .kml files which can be opened with
google earth, and some make data files intended to be read by a graphing program. In the data folder,
you will find mostly nothing. This is where I kept all of my raw data. Each date had it's own folder
in yyyymmdd format, and inside each date folder were the two data files. In the results folder, 
you will again find mostly nothing. I've left the folders which contain different results, some 
graphing scripts which will read from the output of the scripts, and most importantly, some makefiles 
to simplify the process of parsing the raw data. If you prefer, you don't have to use
this same file structure. Directories are not hard coded into the scripts, but they are for the 
makefiles. If you want to use the makefiles, you'll need to have the same file structure as I used.

*REQUIRED SOFTWARE*

Perl:		Needed to run the perl scripts
Wget:		Needed to download data. This command is called for in download.pl
Gnuplot:	Needed to make graphs of data
Convert:	Needed to convert .png graphs into .gif graphs
Gifsicle:	Needed to animate all .gif graphs into one file.
Google Earth:	Needed to view .kml files.

*QUICK START*

If you want to hop right into making graphs or .kml files, follow these step-by-step instructions.
You'll need to be using the same file structure I used, so I'd suggest doing these
instructions right in this directory.

1. In the same directory this file is in, you'll find a folder called scripts. Open it.
2. Type the following command: '$ perl download.pl --directory ../data -d -h 20200511 20200511'
** If you want to make a .kml file to open in Google Earth, contiune to step 3. Otherwise, step 4.
3. Type this command: '$ perl hvb-atc.pl ../data ../results/20200511.kml 10'
4. Navigate up one directory, then to the results folder.
5. If you did step 3, your .kml file will be here for you to open in google earth. Otherwise, contiune.
6. Navigate to the folder called betterhisto.
7. You should see a .png, .gif, and .dat file, all starting with 20200511. Open the png or gif file
in your favorite image viewer.
8. Enjoy the graph! If you want to see a graph of the altitude distribution, go back 
to the results/ folder and open the altdist/ folder. Open that png or gif file.

*FILETYPES*

What I like to call raw data files are ADS-B transmissions detected by a HP-WREN reciever in
southern California. These transmissions contain airplane data such as altitude, coordinates,
callsign, etc. Each day of transmissions is held in a new file. To see the data for yourself
or download it, visit https://hpwren.ucsd.edu/TM/Sensors/Data/ and navigate the directories.
Any date after around 2020/01/01, you should see a file ending in MW-ADSB:x:1:0, where x
is a number 1 through 8. For this project you need files 1 and 3 and they should be downloaded
in the same directory, seperate from other dates.

.dat files (counterintuitively) are files that have results from scripts. They are text files and are
often read by graphing programs. Some default names are:
/betterhisto/{DATE}.dat		holds airplane counts at different altitudes to be graphed
/altdist/{DATE}.dat		holds atitude distributions to be graphed
{DATE1-DATE2}count.dat		holds the cmd line output of count.pl (with formatted date)
{DATE}-alts.dat			list of all detected altitude values for a day

.kml files are openable with google earth. These contain waypoints of all the detected air traffic.
You can use the timeline in google earth to watch them move around and see the path behind them.

.pl files are scripts. =)

*SCRIPTS*

hvb-atc.pl
==========

usage: perl hvb-atc.pl input_dir output_file.kml [minutes]

This script was not originally written by me. It was written by Hans-Werner Braun. His goal was to
read through a raw data file and be able to view the airplanes in google earth. The kml file can 
be opened in google earth to do just that. The input_dir argument is simply the directory with
both data files (1:1:0 and 3:1:0). The output_file.kml argument is where you want the output kml file
to end up. Minutes is an optional argument which specifies how many minutes long the kml file will
be. Google earth doesn't like large files, so I'd keep this under an hour depending on your specs.
The default value is 30. This script has been editied by me to change the colors of the lines 
in google earth. The path will be red if the aircraft is under 5000 meters, green if it's between
5000 and 8500, and blue if it's above 8500. If you're having trouble running this script, I've
included the original one writen by Hans-Werner Braun. It's called sbs1-id.pl

sbs1-id.pl
==========

Hans-Werner Braun's original script of hvb-atc.pl. See above for more details.


count.pl
========

usage: perl count.pl [a=eval altitude] startdate enddate data_dir output_file

Count.pl will parse the data files and return some info, specifically: Date, day of week, count of
unique airplanes, planes near Sandiego airport. If you want it will also return the minimum,
maximum, and average altitude of each day, though this info may not be very helpful.
To get this info, add an 'a' as the first command line argument. Regarding the other command
line arguments, count.pl takes a range of dates, so you must provide two dates. In addition it
needs the directory holding the data, and an output file location. It expects your data to look
like /{data dir}/{date}/, with the 2 raw data files in this folder. It prints the results to
the cmd line, but will also write them in the output file specified in the cmd line arguments.


download.pl
===========

usage: perl download.pl [--increment=n] [--directory=path] [-t=test] [-d=distribution] [-h=histogram] startdate enddate

This was the most important script to me. It made it much easier to work will all this data and all the
types of files. It runs wget in the command line to download raw data files to a specified directory.
It has an increment option which is the number of days to skip. If set to two, for example, it will download every
other date. The test option will not download any files, but will check if they exist. Like count.pl, it
needs a date range, not just one date. The -d and -h options are complex, but don't worry about them now.
If you insist on worrying about it now, check the descriptions for /results/altdist/makefile and 
/results/betterhisto/makefile.


getalts.pl
==========

usage: perl getalts.pl startdate enddate data_directory output_file-alts.dat

This script will read through a data file and return the average altitude value for each unique
hardware id. It doesn't return the hardware ids, just the altitudes. This file ({DATE}-alts.dat)
will be read by the next script...


getdistribution.pl
==================

This file takes the output of getalts.pl directly from STDIN and will bin the altitude values.
The binsize is a variable that can be edited in the script. This script is intended to be used like so:

	$ perl getdistribution.pl < ../resutlts/{DATE}-alts.dat > ../results/altdist/{DATE}.dat

This will take the altitude list produced by getalts.pl and feed it to this script via STDIN.
The output of this script (STDOUT) will be put into the file {DATE}.dat, inside of the altdist/ folder.
The next script will read this output file.


/results/altdist/altdistro.gnuplot
==================================

This script is not inside the scritps folder. It will read the output of getdistribution.pl ({DATE}.dat)
and will produce a png graph of the data. This script should be run like this:

	$ gnuplot -c altdistro.gnuplot ${DATE}.dat ${DATE} > {DATE}.png

The first argument is the input file for the script to read from. The second is the date to print
on the title of the graph. The final arg, after the >, is the output file.


/results/altdist/Makefile
=========================

IMPORTANT: This makefile will not work if you are not using my file structure. To see an example, just look
at the file structure of this project folder. 
This makefile will do everything the last three scripts do, but all at once. 
It has 5 targets:{DATE}.gif, the graph converted to gif format; {DATE}.png, the graph produced by the 
gnuplot script;{DATE}.dat, the altitude distribution data produced by getdistribution.pl; {DATE}-alts.dat, 
the altitudesproduced by getalts.pl; and finally animate, which runs a gifsicle command to make an animated 
gif file (anim.gif)from all of the individual .gif files. You run this file like so: 

	$ make DATE=yyyymmdd
 
Provided you have thedata file for that day, it will go through all of the scripts to make a graph of it.
To make an animated graph with all of the gif files present, type 'make animate'. If you add a -d option
when running download.pl, it will automatically run this makefile for each date in the date range after
downloading the data files.


better_histo.pl
===============

usage: perl better_histo.pl startdate enddate data_directory output_file.dat

Now were are back in the scripts folder. This perl script will produce data for a different graph. It 
reads the data files just like getalts.pl. It takes a date range and also needs the data directory and a
file to output to. This script will output many rows in the following format:

Time	number of unique planes in altitude bin 1	number of unique planes in altitude bin 2 ...

The time binsize and altitude binsize can be changed in this program, but you will probably want to change the next
script to fix the labels on the graph.


/results/betterhisto/graph.gnuplot
==================================

We have left the scripts folder once again. This gnuplot script will make a different looking graph from the data 
coming from better_histo.pl. This graph is a stacked histogram. It should be run like this:

	$ gnuplot -c graph.gnuplot {DATE}.dat {DATE} > {DATE}.png

This is exactly the same usage as the other gnuplot script except for the script name itself, so check up there
for more detail on the command line arguments.


/results/betterhisto/Makefile
=============================

The betterhisto makefile has 4 targets: {DATE}.gif, the graph converted into gif format; {DATE}.png, the graph
which comes from the gnuplot script; {DATE}.dat, the data file produced by better_histo.pl; and animate, which will
run a gifsicle command to make an animated gif of all the graphs. It runs the exact same way as the previous makefile.
Remember, it won't work if you use a different file strucutre. If you add a -h option when running download.pl, it
will automatically run this makefile for each date in the date range after downloading the data files.

