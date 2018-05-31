#!/usr/bin/perl

use strict;
use warnings;
use Switch; #** switch dependency for switch()
use File::Slurp; #** @brief File::Slurp dependency for reading large file
use Text::Table::Tiny 0.04 qw/ generate_table /; #** @brief table generator dependency
use Text::Table::CSV; #** @brief CSV file generator dependency
use DateTime; #** @brief DateTime dependency, getting date object
use JSON; #** @brief JSON dependency
use Term::ANSIColor qw(:constants); #** @brief Colored print out in console
local $Term::ANSIColor::AUTORESET = 1;

my %regex_hash; #** @brief hashmap holding all regex for parsing

my @result; #** @brief array holding the filtered reuslt

## TEMP my @diagnostic; #** @brief a double array holding the report
## TEMP my @routing; #** @brief a double array holding the report
## TEMP my @guidance; #** @brief a double array holding the report
## TEMP my @angles; #** @brief a double array holding the report

###################### Constents #######################
our $city = 'Los_Angels';
our $city_boundary = 'la_boundary';
## our $city = 'Dallas'; #** Testing data input
## our $city_boundary = 'dallas_boundary'; #** Testing data input

###################### Test section ########################

#** @method public pretest
# @brief set up environment before test
# can input filter hash here...
#*

sub pretest {
	#** remove the old logs
	system("mv $city-report.log $city-report.log.bak");
	system("mv $city-report.csv $city-report.csv.bak");
	system("mv $city-report.json $city-report.json.bak");
	$regex_hash{$city} = $city_boundary . '\] .*\) '; #** @brief set filters for Los Angels
	$regex_hash{'Dallas'} = 'dallas_boundary\] .*\) ';
	return 0;
}

#** @method public test
# @brief execute the test
#*

sub test {
	debug("=============== Start Valhalla Log Parsing ==================");
	@result = read_valhalla($ARGV[0], hash_to_array(\%regex_hash));
	debug("=============== Valhalla Log Parsing Finished ================");
	return 0;
}

#** @method public posttest
# @brief teardown the test environment
#*

sub posttest {
	open(my $logfile, '>>', "$city-report.log");
	open(my $csvfile, '>>', "$city-report.csv");
	open(my $jsonfile, '>>', "$city-report.json");
	#** print to console and log file the result
	foreach my $line (@result) {
		my @results;
		switch ($line) {
			case /Diagnostic/	{
				@results = report_generator($line, '^.*\] .*\) +(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*)');
				debug("===== Valhalla Diagnostic =====");
			}
			case /Routing/		{
				@results = report_generator($line, '^.*\] .*\) +(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*)');
				debug("===== Routing =====");
			}
			case /Guidance/		{
				@results = report_generator($line, '^.*\] .*\) +(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*)');
				debug("===== Guidance =====");
			}
			case /Angles/		{
				@results = report_generator($line, '^.*\] .*\) +(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*) +\| *(.*): *(.*)');
				debug("===== Angles =====");
			}
			else				{error("No entry found in the report!"); die;}
		}
		logging("[RESULT]$line");
		logging("\n".generate_table(rows => \@results, header_row => 1, separate_rows => 1));	
		print $logfile $line;
		print $logfile generate_table(rows => \@results, header_row => 1, separate_rows => 1)."\n";
		print $csvfile Text::Table::CSV::table(rows => \@results, header_row => 1);
		print $jsonfile encode_json(\@results)."\n";
	}
	debug("======================= End of Test ======================");
	return 0;
}

#** @brief execute the test!!!!!!!!
exit(&pretest & &test & &posttest);

#################### Library and models section #########################

#** @method public read_valhalla ($filename, @filiters)
# @brief Read the input file and apply filter(s)
# @params $input the name of file
# @params @regs the regex for filtering the file
# @return @result the result from the filter
#*

sub read_valhalla {
	my $input = shift @_;
	my @regs = @_;
	my @lines = read_file($input) or die "File not Found!";
	my @result;
	foreach my $line (@lines) {
		foreach my $reg (@regs) {
			if ($line =~ m/$reg/) {
				push @result, $line;
			}
		}
	}
	return @result;
};

#** @method public hash_to_array (%hash)
# @brief return the array value of an input hash
# @return @array
#*

sub hash_to_array {
	my $array = shift;
	my @array = values %{$array};
	return @array;
}

#** @method public report_generator ($input_result_line)
# @brief return the double array for generating the report
# @return @report double arrary
#*

sub report_generator {
	my $line = shift @_;
	my $regex_string = shift @_;
	my @report;
	my @matches = ($line =~ /$regex_string/);
	my $j = 0;
	for (my $i = 0; $i < @matches; $i = ($i+2)) {
		$report[0][$j] = $matches[$i];
		$report[1][$j] = $matches[$i+1];
		$j++;
	}
	return @report;
}

####################### Utilities ######################
sub logging {
	my $line = shift @_;
	my $date = DateTime->now;
	print BOLD BLUE "[$date][LOG] $line\n";
}

sub warning {
	my $line = shift @_;
	my $date = DateTime->now;
	print BOLD YELLOW "[$date][WARNING] $line\n";
}

sub error {
	my $line = shift @_;
	my $date = DateTime->now;
	print BOLD RED "[$date][ERROR] $line\n";
}

sub debug {
	my $line = shift @_;
	my $date = DateTime->now;
	print "[$date][DEBUG] $line\n";
}
