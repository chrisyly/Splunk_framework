#!/usr/bin/perl

use strict;
use warnings;
use Switch; #** switch dependency for switch()
use File::Slurp; #** @brief File::Slurp dependency for reading large file
use Text::Table::Tiny 0.04 qw/ generate_table /; #** @brief table generator dependency
use Text::Table::CSV; #** @brief CSV file generator dependency
use Term::ANSIColor qw(:constants);
local $Term::ANSIColor::AUTORESET = 1;

use lib "../../lib";
use SAuto::SAuto;
use SAuto::Devices;
use Splunk::MovieAPI;

###################### Constants #######################

#################### Test Execution ######################
#** @brief execute the test!!!!!!!!
exit(&pretest & &test & &posttest);


###################### Test Body ########################
#** @method public pretest
# @brief set up environment before test
#*
sub pretest {
	#** remove/create the logs if necessary
	#** set up environment or loading necessary data
	return 0;
}

############################################################
#** @method public test
# @brief execute the test
#*
sub test {
	SAuto::debug("=============== Test Start ==================");
	#** TODO: add test steps here
	SAuto::debug("=============== Test Finished ================");
	return 0;
}

############################################################
#** @method public posttest
# @brief teardown the test environment
#*
sub posttest {
	my $result = SAuto::getSummary();
	SAuto::debug("======================= End of Test ======================");
	return $result;
}
