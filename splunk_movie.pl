#!/usr/bin/perl

use strict;
use warnings;
use Switch; #** switch dependency for switch()
use File::Slurp; #** @brief File::Slurp dependency for reading large file
use Text::Table::Tiny 0.04 qw/ generate_table /; #** @brief table generator dependency
use Text::Table::CSV; #** @brief CSV file generator dependency
use Term::ANSIColor qw(:constants);
local $Term::ANSIColor::AUTORESET = 1;

use lib "lib";
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
	#** remove the old logs
	return 1;
}

############################################################
#** @method public test
# @brief execute the test
#*
sub test {
	SAuto::debug("=============== Test Start ==================");
	MovieAPI::postMovie('{"name":"superman", "description":"the best movie ever made"}');
	## MovieAPI::getResponseCode();
	## MovieAPI::getResponseContent();
	SAuto::checkPass(MovieAPI::checkCode(200),1,"Post Request expect return code 200");
	SAuto::checkPass(MovieAPI::checkCode(400),0,"Post Request expect not return 400");
	SAuto::checkPass(MovieAPI::checkCode(400),1,"Post Request expect return 400");
	## MovieAPI::getMovie('hello', 1);
	## SAuto::logging('	Return code: ['.MovieAPI::getResponseCode().']');
	## SAuto::logging("	Return content:\n".MovieAPI::getResponseContent());
	SAuto::debug("=============== Test Finished ================");
	return 1;
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
